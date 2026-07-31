#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Resolvedor central de Controle da AMC IA (SOL-0007, `.claude/rules/decisoes-tecnicas.md`).

Mecanismo único de deduplicação e decisão de pipeline para abertura de Controle no
CaptaHub, reutilizado por `/descricao-edital`, `/editais-pasta-processar` e
`/edital-minerar`, para que as três origens (CaptaHub, Web avulsa, Pasta Local e
mineração) apliquem exatamente a mesma regra de negócio. Só decide, não executa
nenhuma escrita no CaptaHub (quem cria ou atualiza o Controle é o comando chamador,
com `scripts/captahub-api.py controle-criar` / `projeto-atualizar`).

Regra de negócio (SOL-0007):
  1. Dedup obrigatório antes de qualquer criação, por edital_id (exato, quando
     conhecido) ou por título normalizado (fuzzy, limiar 0,82) contra os Controles
     já existentes. Um edital nunca gera dois Controles.
  2. Compatibilidade com a carteira de OSCs só é calculada quando o edital é
     realmente novo (não passou no dedup).
  3. Edital novo + OSC compatível (aderência ALTA) -> Controle nasce vinculado,
     etapa "selecionado". Edital novo sem OSC compatível -> etapa "encontrar_cliente",
     sem vínculo. Edital já existente -> não cria, sinaliza o Controle para o
     comando atualizar (e sugere backfill de edital_id quando aplicável).

Limite conhecido: o Controle (`GET /v1/projetos`) só expõe `nome`, não guarda a
instituição nem o link separadamente (ver `docs/integracao-captahub-api.md`, seção
3.4), então o dedup por título usa só o nome do Controle, um sinal mais fraco que o
usado por `editais-pasta-checar-duplicado.py` (que compara título+órgão contra o
catálogo de editais, uma pergunta diferente: "esse edital já existe no catálogo?").

Uso:
  python3 scripts/controle-resolver.py --titulo "..." [--edital-id <uuid>]
      [--category "..."] [--scope "Estadual"] [--uf "MG"] [--description "..."]
      [--tags "tag1,tag2"] [--cliente-id <uuid>] [--sem-carteira]

  --cliente-id: avalia compatibilidade só com esse cliente (uso do /edital-minerar,
    que já opera na OSC ativa, não precisa varrer a carteira inteira). Sem isso,
    varre toda a carteira (`clientes --all`), uso do /descricao-edital e do
    /editais-pasta-processar.
  --sem-carteira: pula a etapa de compatibilidade (só resolve duplicidade).

Saída: bloco `=== JSON ===` com {duplicado, acao, controle_existente,
motivo_duplicidade, sugerir_backfill_edital_id, candidato_osc,
vincular_automaticamente, status_sugerido}.
"""

import argparse
import json
import re
import subprocess
import sys
import unicodedata
from difflib import SequenceMatcher
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")
sys.stderr.reconfigure(encoding="utf-8")

RAIZ = Path(__file__).resolve().parent.parent
CAPTAHUB_API = RAIZ / "scripts" / "captahub-api.py"

LIMIAR_SIMILARIDADE_CONTROLE = 0.82

# Pesos da pontuação de compatibilidade edital -> OSC (mesma lógica de
# tema + território de `scripts/minerar-editais.py`, na direção inversa:
# lá se pontua editais para uma OSC; aqui se pontua OSCs para um edital).
PESO_CATEGORIA_EXATA = 3
PESO_CATEGORIA_APROXIMADA = 2
PESO_PALAVRA_CHAVE = 1
TETO_PALAVRAS_CHAVE = 3
PESO_TERRITORIO_LOCAL = 4
PESO_TERRITORIO_ABRANGENTE = 1
PENALIDADE_FORA_TERRITORIO = -6

BANDA_ALTA_MIN = 6
BANDA_MEDIA_MIN = 3
BANDA_MINIMA_PARA_VINCULO_AUTOMATICO = "ALTA"

PALAVRAS_COMUNS = {
    "de", "da", "do", "das", "dos", "e", "a", "o", "as", "os", "para", "em",
    "chamada", "publica", "publico", "edital", "n", "no", "numero",
}


def normalizar(texto):
    if not texto:
        return ""
    texto = unicodedata.normalize("NFKD", texto).encode("ascii", "ignore").decode("ascii")
    texto = texto.lower()
    texto = re.sub(r"[^a-z0-9\s]", " ", texto)
    palavras = [p for p in texto.split() if p not in PALAVRAS_COMUNS]
    return " ".join(palavras)


MARCADOR_BLOCO = re.compile(r"^=== .+ ===\s*$", re.MULTILINE)


def _chamar_api(args_cli):
    """Roda captahub-api.py e devolve o bloco machine-readable decodificado, ou None se falhar.

    O rótulo do bloco muda por comando (=== PROJETOS ===, === CLIENTES ===,
    === CLIENTE ===...), por isso a busca é pelo padrão "=== ... ===", não por
    um marcador fixo (bug real encontrado aqui: uma versão anterior de
    `editais-pasta-checar-duplicado.py` procurava um marcador fixo "=== JSON ==="
    que não existe, e por isso a consulta ao vivo ao CaptaHub sempre falhava
    em silêncio, caindo para "sem duplicata" sem avisar).
    """
    try:
        resultado = subprocess.run(
            [sys.executable, str(CAPTAHUB_API)] + args_cli,
            capture_output=True, text=True, encoding="utf-8", timeout=30,
        )
    except Exception:
        return None
    if resultado.returncode != 0:
        return None
    saida = resultado.stdout or ""
    m = MARCADOR_BLOCO.search(saida)
    if not m:
        return None
    try:
        return json.loads(saida[m.end():])
    except json.JSONDecodeError:
        return None


def listar_controles():
    dados = _chamar_api(["projetos", "--all"])
    if dados is None:
        return None
    return dados if isinstance(dados, list) else (dados.get("data") or [])


def listar_clientes(cliente_id=None):
    if cliente_id:
        dados = _chamar_api(["cliente", "--id", cliente_id])
        if dados is None:
            return None
        return [dados]
    dados = _chamar_api(["clientes", "--all"])
    if dados is None:
        return None
    return dados if isinstance(dados, list) else (dados.get("data") or [])


def achar_controle_existente(titulo, edital_id, controles):
    if edital_id:
        for c in controles:
            if c.get("edital_id") == edital_id:
                return c, "edital_id identico"

    alvo = normalizar(titulo)
    if not alvo:
        return None, None
    melhor, melhor_score = None, 0.0
    for c in controles:
        nome_norm = normalizar(c.get("nome", ""))
        if not nome_norm:
            continue
        razao = SequenceMatcher(None, alvo, nome_norm).ratio()
        if razao >= LIMIAR_SIMILARIDADE_CONTROLE and razao > melhor_score:
            melhor, melhor_score = c, razao
    if melhor:
        return melhor, f"titulo muito similar ({melhor_score:.0%})"
    return None, None


def pontuar_cliente(edital, cliente):
    score = 0
    hits = []

    categoria_edital = str(edital.get("category") or "").strip().lower()
    areas = [str(a).strip().lower() for a in (cliente.get("areas_tematicas") or [])]
    if categoria_edital and categoria_edital in areas:
        score += PESO_CATEGORIA_EXATA
        hits.append(f"categoria:{edital.get('category')}")
    elif categoria_edital and any(categoria_edital in a or a in categoria_edital for a in areas if a):
        score += PESO_CATEGORIA_APROXIMADA
        hits.append(f"categoria~:{edital.get('category')}")

    texto_edital = " ".join(
        str(edital.get(c) or "") for c in ("title", "description")
    ).lower()
    tags = [str(t).strip().lower() for t in (edital.get("tags") or [])]
    termos = set(a for a in areas if a) | set(t for t in tags if t)
    kw = sum(1 for termo in termos if termo and termo in texto_edital)
    if kw:
        score += min(kw, TETO_PALAVRAS_CHAVE) * PESO_PALAVRA_CHAVE
        hits.append(f"palavra-chave:{kw}")

    escopo = str(edital.get("scope") or "").strip()
    uf_edital = str(edital.get("uf") or "").strip().upper()
    uf_cliente = str(cliente.get("uf") or "").strip().upper()
    territorios_cliente = [str(t).strip().upper() for t in (cliente.get("territorios") or [])]

    if escopo in ("Municipal", "Estadual"):
        if uf_edital and (uf_edital == uf_cliente or uf_edital in territorios_cliente):
            score += PESO_TERRITORIO_LOCAL
            hits.append("territorio-local")
        elif uf_edital and uf_cliente and uf_edital != uf_cliente:
            score += PENALIDADE_FORA_TERRITORIO
            hits.append("fora-territorio")
    elif escopo in ("Nacional", "Internacional"):
        score += PESO_TERRITORIO_ABRANGENTE
        hits.append("alcance-abrangente")

    return score, hits


def banda(score):
    if score >= BANDA_ALTA_MIN:
        return "ALTA"
    if score >= BANDA_MEDIA_MIN:
        return "MEDIA"
    return "BAIXA"


def melhor_candidato(edital, clientes):
    avaliados = []
    for cliente in clientes:
        score, hits = pontuar_cliente(edital, cliente)
        avaliados.append((score, cliente, hits))
    if not avaliados:
        return None
    avaliados.sort(key=lambda item: (-item[0], str(item[1].get("nome") or "")))
    score, cliente, hits = avaliados[0]
    return {
        "id": cliente.get("id"),
        "nome": cliente.get("nome"),
        "score": score,
        "banda": banda(score),
        "motivos": hits,
    }


def main():
    p = argparse.ArgumentParser(
        description="Resolve duplicidade de Controle e compatibilidade de OSC para um edital (SOL-0007)."
    )
    p.add_argument("--titulo", required=True)
    p.add_argument("--edital-id", dest="edital_id", default=None)
    p.add_argument("--category", default=None)
    p.add_argument("--scope", default=None)
    p.add_argument("--uf", default=None)
    p.add_argument("--description", default=None)
    p.add_argument("--tags", default=None, help="lista separada por vírgula")
    p.add_argument("--cliente-id", dest="cliente_id", default=None,
                    help="Avalia compatibilidade só com este cliente (uso do /edital-minerar).")
    p.add_argument("--sem-carteira", dest="sem_carteira", action="store_true",
                    help="Pula a checagem de compatibilidade, só resolve duplicidade.")
    args = p.parse_args()

    controles = listar_controles()
    if controles is None:
        print("Falha ao consultar o CaptaHub para checar duplicidade de Controle.")
        print("=== JSON ===")
        print(json.dumps({"erro": "captahub_indisponivel"}, ensure_ascii=False))
        sys.exit(1)

    controle_existente, motivo = achar_controle_existente(args.titulo, args.edital_id, controles)

    if controle_existente:
        sugerir_backfill = bool(args.edital_id) and not controle_existente.get("edital_id")
        print(f"Controle já existe para este edital: {motivo}")
        print(f"  ID: {controle_existente.get('id')} | Status: {controle_existente.get('status')}")
        saida = {
            "duplicado": True,
            "acao": "atualizar",
            "controle_existente": {
                "id": controle_existente.get("id"),
                "nome": controle_existente.get("nome"),
                "status": controle_existente.get("status"),
                "cliente_id": controle_existente.get("cliente_id"),
                "edital_id": controle_existente.get("edital_id"),
            },
            "motivo_duplicidade": motivo,
            "sugerir_backfill_edital_id": sugerir_backfill,
            "candidato_osc": None,
            "vincular_automaticamente": False,
            "status_sugerido": None,
        }
        print("=== JSON ===")
        print(json.dumps(saida, ensure_ascii=False))
        return

    print("Nenhum Controle existente encontrado para este edital. Candidato a novo.")

    candidato_osc = None
    vincular = False
    status_sugerido = "encontrar_cliente"

    if not args.sem_carteira:
        clientes = listar_clientes(args.cliente_id)
        if clientes is None:
            print("Aviso: não foi possível consultar a carteira de OSCs. Controle nasce sem vínculo.")
        else:
            edital = {
                "title": args.titulo,
                "category": args.category,
                "scope": args.scope,
                "uf": args.uf,
                "description": args.description,
                "tags": [t.strip() for t in args.tags.split(",")] if args.tags else [],
            }
            candidato_osc = melhor_candidato(edital, clientes)
            if candidato_osc and candidato_osc["banda"] == BANDA_MINIMA_PARA_VINCULO_AUTOMATICO:
                vincular = True
                status_sugerido = "selecionado"
                print(f"OSC compatível (aderência {candidato_osc['banda']}): "
                      f"{candidato_osc['nome']} (score {candidato_osc['score']}) -> etapa Selecionado.")
            elif candidato_osc:
                print(f"Melhor OSC candidata tem aderência {candidato_osc['banda']} "
                      f"(score {candidato_osc['score']}), abaixo do piso para vínculo automático "
                      f"({BANDA_MINIMA_PARA_VINCULO_AUTOMATICO}). Controle nasce sem vínculo.")
            else:
                print("Nenhuma OSC na carteira para comparar. Controle nasce sem vínculo.")

    print(f"Etapa sugerida: {status_sugerido}")

    saida = {
        "duplicado": False,
        "acao": "criar",
        "controle_existente": None,
        "motivo_duplicidade": None,
        "sugerir_backfill_edital_id": False,
        "candidato_osc": candidato_osc,
        "vincular_automaticamente": vincular,
        "status_sugerido": status_sugerido,
    }
    print("=== JSON ===")
    print(json.dumps(saida, ensure_ascii=False))


if __name__ == "__main__":
    main()
