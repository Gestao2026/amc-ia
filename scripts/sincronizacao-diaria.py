#!/usr/bin/env python3
"""Confirma e sincroniza automaticamente as alteracoes do dia com o GitHub.

Disparado pelo Agendador de Tarefas do Windows, todos os dias a meia-noite.
So confirma o que passa numa checagem tecnica basica (sintaxe Python valida,
JSON valido). O que falha fica de fora do commit e vai para o relatorio do
dia, em logs/sincronizacao-diaria/. Essa checagem nao substitui revisao
humana de conteudo, so pega quebra tecnica.
"""
import json
import subprocess
import sys
from datetime import datetime
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")
sys.stderr.reconfigure(encoding="utf-8")

RAIZ = Path(__file__).resolve().parent.parent
PASTA_RELATORIOS = RAIZ / "logs" / "sincronizacao-diaria"


def git(*args, check=True):
    resultado = subprocess.run(
        ["git", *args], cwd=RAIZ, capture_output=True, text=True, encoding="utf-8"
    )
    if check and resultado.returncode != 0:
        raise RuntimeError(resultado.stderr.strip() or resultado.stdout.strip())
    return resultado.stdout.strip()


def listar_alteracoes():
    # -z evita que nomes de arquivo com acentuacao (comuns neste projeto em
    # pt_BR) venham escapados em octal pelo git (ex: Patroc\303\255nio.pdf),
    # o que quebraria o "git add" depois.
    resultado = subprocess.run(
        ["git", "status", "--porcelain", "--untracked-files=all", "-z"],
        cwd=RAIZ, capture_output=True, text=True, encoding="utf-8",
    )
    tokens = resultado.stdout.split("\0")
    alteracoes = []
    i = 0
    while i < len(tokens):
        entrada = tokens[i]
        if not entrada:
            i += 1
            continue
        status = entrada[:2]
        caminho = entrada[3:]
        if "R" in status or "C" in status:
            i += 1  # pula o token seguinte (nome antigo, antes da renomeacao)
        alteracoes.append((status, caminho))
        i += 1
    return alteracoes


def checar_python(caminho: Path):
    resultado = subprocess.run(
        [sys.executable, "-m", "py_compile", str(caminho)],
        capture_output=True, text=True, encoding="utf-8",
    )
    if resultado.returncode != 0:
        return (resultado.stderr.strip() or "erro de sintaxe").splitlines()[-1]
    return None


def checar_json(caminho: Path):
    try:
        json.loads(caminho.read_text(encoding="utf-8"))
    except Exception as erro:
        return f"JSON invalido: {erro}"
    return None


def avaliar(status, caminho):
    if status.strip() == "D":
        return None
    caminho_completo = RAIZ / caminho
    if not caminho_completo.exists() or caminho_completo.is_dir():
        return None
    if caminho.endswith(".py"):
        return checar_python(caminho_completo)
    if caminho.endswith(".json"):
        return checar_json(caminho_completo)
    return None


def escrever_relatorio(agora, incluidos, pendentes, erro_push):
    PASTA_RELATORIOS.mkdir(parents=True, exist_ok=True)
    caminho = PASTA_RELATORIOS / f"{agora:%Y-%m-%d}.md"
    linhas = [f"# Sincronizacao automatica - {agora:%d/%m/%Y as %H:%M}", ""]

    if not incluidos and not pendentes:
        linhas.append("Nenhuma alteracao encontrada. Nada foi confirmado ou sincronizado hoje.")
    else:
        linhas.append(f"## Confirmado e sincronizado ({len(incluidos)})")
        linhas += [f"- {c}" for c in incluidos] if incluidos else ["- (nenhum)"]
        linhas.append("")
        linhas.append(f"## Pendente. Precisa de ajuste antes de confirmar ({len(pendentes)})")
        if pendentes:
            for caminho_arq, erro in pendentes:
                linhas.append(f"- **{caminho_arq}**: {erro}")
        else:
            linhas.append("- (nenhum)")

    if erro_push:
        linhas.append("")
        linhas.append("## Atencao. A sincronizacao com o GitHub falhou")
        linhas.append(
            "O commit foi feito localmente, mas o envio para o GitHub nao "
            f"funcionou: {erro_push}"
        )
        linhas.append("Sincronize manualmente assim que possivel (Confirmar e Sincronizar).")

    caminho.write_text("\n".join(linhas), encoding="utf-8")
    return caminho


def principal():
    agora = datetime.now()
    alteracoes = listar_alteracoes()

    if not alteracoes:
        relatorio = escrever_relatorio(agora, [], [], None)
        print(f"Nada para sincronizar hoje. Relatorio: {relatorio}")
        return

    incluidos = []
    pendentes = []
    for status, caminho in alteracoes:
        erro = avaliar(status, caminho)
        if erro:
            pendentes.append((caminho, erro))
        else:
            incluidos.append(caminho)

    erro_push = None
    if incluidos:
        git("add", "--", *incluidos)
        mensagem = f"chore: sincronizacao automatica {agora:%Y-%m-%d %H:%M}"
        git("commit", "-m", mensagem)
        try:
            git("push")
        except RuntimeError as erro:
            erro_push = str(erro)

    relatorio = escrever_relatorio(agora, incluidos, pendentes, erro_push)
    print(
        f"Confirmados e sincronizados: {len(incluidos)}. "
        f"Pendentes: {len(pendentes)}. Relatorio: {relatorio}"
    )


if __name__ == "__main__":
    principal()
