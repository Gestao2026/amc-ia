# Editais Avulsos. Análises técnicas sem OSC vinculada

Esta pasta guarda editais já analisados nos 8 pontos padrão (o mesmo formato produzido por `/edital-analisar`), mas que ainda não têm uma OSC definida, seja porque:

- o edital foi analisado antes de escolher a organização;
- a OSC ativa no momento da análise não é elegível para aquele edital (ex: exige natureza de OSC e a organização é uma empresa; ou não atende ao território, área ou tempo de existência exigido);
- o captador quer manter a análise disponível para oferecer a um cliente futuro da carteira.

## Diferença para os outros dois lugares onde um edital pode existir

| Onde | Formato | Para quê |
|---|---|---|
| `editais-avulsos/{slug}.md` (aqui) | `.md`, 8 pontos | Alimenta os agentes (CaptaDoc, CaptaBuilder, CaptaBudget, CaptaScore) assim que uma OSC for definida. Não é um documento de entrega ao cliente. |
| `Descrição Editais/{slug}.doc` (`/descricao-edital`) | `.doc`, 15 pontos | Ficha de consulta pronta para leitura humana (o captador ou um cliente), mais detalhada, não alimenta os agentes diretamente. |
| `minhas-oscs/{osc}/projetos/{slug}/edital.md` (`/edital-analisar`) | `.md`, 8 pontos | Mesma extração desta pasta, mas já dentro do contexto de uma OSC, pronta para seguir para `/projeto-elegibilidade`. |

## Como usar

1. Rode `/edital-analisar-avulso` para gerar uma nova análise aqui.
2. Quando decidir qual OSC vai buscar aquele edital, copie o arquivo para `minhas-oscs/{osc}/projetos/{edital-slug}/edital.md` e siga o fluxo normal (`/projeto-elegibilidade` primeiro, sempre).
3. Como os demais fluxos de edital novo (`/descricao-edital`, `/editais-pasta-processar`, `/edital-minerar`), cada análise aqui também abre ou atualiza um **Controle** no pipeline do CaptaHub (nunca duplica; ver `.claude/rules/decisoes-tecnicas.md`, SOL-0007), usando `scripts/controle-resolver.py`.

## Checklist de documentos (opcional, por edital)

Para um edital desta pasta, é possível montar também um checklist visual de documentos, anexos e manuais, a partir do molde `modelos-analise-edital/MODELO-checklist-documentos-edital.html`. Preencher os campos `{{ }}` com os dados do `edital.md` já salvo, seguindo as instruções no comentário do próprio molde (nunca apagar uma linha só porque não se aplica a este edital, trocar a pílula para "Não se aplica a este edital"). Salvar como `{edital-slug}-checklist-documentos.html`, nesta mesma pasta. Como a OSC ainda não está definida, os campos de proponente (nome, sede) ficam marcados como "OSC ainda não definida".
