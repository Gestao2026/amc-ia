#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Checador de duplicidade de edital da AMC IA.

Recebe título, órgão e (opcional) link de um edital candidato e verifica se ele
já existe na base local (cache do CaptaHub) e, se houver conexão configurada,
também ao vivo no CaptaHub (`captahub-api.py editais --q`). A comparação é por
link exato (mais confiável) ou por título+órgão normalizados (remove acento,
caixa e palavras muito comuns), com limiar de similaridade.

Uso:
  python3 scripts/editais-pasta-checar-duplicado.py --titulo "..." --orgao "..." [--url "..."] [--sem-captahub]

Saída: bloco === JSON === com {"duplicado": bool, "motivo": str, "correspondente": {...}|null}
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
BASE_INDICE = RAIZ / "base-editais" / "editais-index.json"
BASE_COMPLETA = RAIZ / "base-editais" / "editais-abertos.json"
LIMIAR_SIMILARIDADE = 0.82

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


def carregar_base_local():
    caminho = BASE_COMPLETA if BASE_COMPLETA.exists() else BASE_INDICE
    if not caminho.exists():
        return []
    dados = json.loads(caminho.read_text(encoding="utf-8-sig"))
    if isinstance(dados, dict) and "editais" in dados:
        return dados["editais"]
    if isinstance(dados, list):
        return dados
    return []


def buscar_captahub(titulo):
    try:
        resultado = subprocess.run(
            [sys.executable, str(RAIZ / "scripts" / "captahub-api.py"), "editais", "--q", titulo, "--limit", "10"],
            capture_output=True, text=True, timeout=20,
        )
    except Exception:
        return []
    saida = resultado.stdout or ""
    marcador = "=== JSON ==="
    if marcador not in saida:
        return []
    bloco = saida.split(marcador, 1)[1]
    try:
        dados = json.loads(bloco)
    except json.JSONDecodeError:
        return []
    return dados.get("data") or dados.get("editais") or []


def comparar(candidato_titulo, candidato_orgao, candidato_url, editais):
    alvo_norm = normalizar(f"{candidato_titulo} {candidato_orgao}")
    for edital in editais:
        url_existente = (edital.get("url") or "").strip().rstrip("/")
        url_candidata = (candidato_url or "").strip().rstrip("/")
        if url_candidata and url_existente and url_candidata == url_existente:
            return edital, "url identica"

        existente_norm = normalizar(f"{edital.get('title', '')} {edital.get('institution', '')}")
        if not existente_norm or not alvo_norm:
            continue
        razao = SequenceMatcher(None, alvo_norm, existente_norm).ratio()
        if razao >= LIMIAR_SIMILARIDADE:
            return edital, f"titulo e orgao muito similares ({razao:.0%})"
    return None, None


def main():
    p = argparse.ArgumentParser(description="Verifica se um edital candidato já existe (local ou CaptaHub).")
    p.add_argument("--titulo", required=True)
    p.add_argument("--orgao", default="")
    p.add_argument("--url", default="")
    p.add_argument("--sem-captahub", action="store_true", help="Não consulta o CaptaHub ao vivo, só a base local.")
    args = p.parse_args()

    base_local = carregar_base_local()
    correspondente, motivo = comparar(args.titulo, args.orgao, args.url, base_local)

    fonte = "base local"
    if not correspondente and not args.sem_captahub:
        editais_captahub = buscar_captahub(args.titulo)
        correspondente, motivo = comparar(args.titulo, args.orgao, args.url, editais_captahub)
        if correspondente:
            fonte = "CaptaHub (ao vivo)"

    duplicado = correspondente is not None

    if duplicado:
        print(f"⚠️  Possível duplicado encontrado em {fonte}: {motivo}")
        print(f"   Já existente: {correspondente.get('title')}, de {correspondente.get('institution')}")
    else:
        print("✅ Não encontrado nem na base local nem no CaptaHub. Candidato a edital novo.")

    print("=== JSON ===")
    print(json.dumps({
        "duplicado": duplicado,
        "motivo": motivo,
        "fonte": fonte if duplicado else None,
        "correspondente": correspondente,
    }, ensure_ascii=False))


if __name__ == "__main__":
    main()
