#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Extrator de texto de Word (.docx) e Excel (.xlsx) da AMC IA.

PDF e imagem são lidos diretamente pelo Claude (leitura nativa). Word e Excel
não, então este script extrai o texto puro de dentro do arquivo (que é um zip
de XML) usando só biblioteca padrão, no mesmo padrão dos outros scripts do
projeto. Não preserva formatação, só o conteúdo textual, o suficiente para
identificar título, órgão, prazo, valor e link do edital.

Uso:
  python3 scripts/editais-pasta-extrair-texto.py <arquivo.docx|arquivo.xlsx>
"""

import sys
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET

sys.stdout.reconfigure(encoding="utf-8")
sys.stderr.reconfigure(encoding="utf-8")

NS_WORD = {"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}
NS_SS = {"s": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}


def extrair_docx(caminho):
    with zipfile.ZipFile(caminho) as z:
        xml = z.read("word/document.xml")
    raiz = ET.fromstring(xml)
    partes = []
    for paragrafo in raiz.iter(f"{{{NS_WORD['w']}}}p"):
        texto = "".join(
            (t.text or "") for t in paragrafo.iter(f"{{{NS_WORD['w']}}}t")
        )
        if texto.strip():
            partes.append(texto)
    return "\n".join(partes)


def extrair_xlsx(caminho):
    with zipfile.ZipFile(caminho) as z:
        nomes = z.namelist()
        strings_compartilhadas = []
        if "xl/sharedStrings.xml" in nomes:
            xml = z.read("xl/sharedStrings.xml")
            raiz = ET.fromstring(xml)
            for si in raiz.iter(f"{{{NS_SS['s']}}}si"):
                texto = "".join(
                    (t.text or "") for t in si.iter(f"{{{NS_SS['s']}}}t")
                )
                strings_compartilhadas.append(texto)

        planilhas = sorted(
            n for n in nomes if n.startswith("xl/worksheets/sheet") and n.endswith(".xml")
        )
        linhas = []
        for nome_planilha in planilhas:
            xml = z.read(nome_planilha)
            raiz = ET.fromstring(xml)
            for linha in raiz.iter(f"{{{NS_SS['s']}}}row"):
                valores = []
                for celula in linha.iter(f"{{{NS_SS['s']}}}c"):
                    tipo = celula.get("t")
                    valor_el = celula.find(f"{{{NS_SS['s']}}}v")
                    if valor_el is None or valor_el.text is None:
                        continue
                    if tipo == "s":
                        idx = int(valor_el.text)
                        if 0 <= idx < len(strings_compartilhadas):
                            valores.append(strings_compartilhadas[idx])
                    else:
                        valores.append(valor_el.text)
                if valores:
                    linhas.append(" | ".join(valores))
        return "\n".join(linhas)


def main():
    if len(sys.argv) != 2:
        sys.exit("Uso: python3 scripts/editais-pasta-extrair-texto.py <arquivo.docx|arquivo.xlsx>")
    caminho = Path(sys.argv[1])
    if not caminho.exists():
        sys.exit(f"Arquivo não encontrado: {caminho}")

    sufixo = caminho.suffix.lower()
    try:
        if sufixo == ".docx":
            print(extrair_docx(caminho))
        elif sufixo == ".xlsx":
            print(extrair_xlsx(caminho))
        else:
            sys.exit(f"Formato não suportado por este extrator: {sufixo}. Use .docx ou .xlsx.")
    except (zipfile.BadZipFile, KeyError, ET.ParseError) as erro:
        sys.exit(f"Não foi possível ler o arquivo (formato antigo .doc/.xls ou corrompido?): {erro}")


if __name__ == "__main__":
    main()
