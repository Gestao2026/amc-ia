# Tipo de Proponente. Primeiro Filtro da Triagem

> Regra de processo. Define que a natureza jurídica do cliente (sem fins lucrativos, com fins lucrativos, MEI ou pessoa física) é a primeira pergunta de qualquer elegibilidade e de qualquer indicação de edital. Consultar junto com `.claude/rules/checklist-triagem-captadoc.md` (item 2, quem pode participar) e `.claude/rules/fonte-documentos-clientes.md`.

## Onde estão os dados da carteira

A classificação cliente a cliente fica em `minhas-oscs/_carteira/naturezas-juridicas.md`, **fora do controle de versão**, porque traz nome de cliente, natureza jurídica e vínculo com pessoas reais, e este repositório é público. Nenhum nome de cliente, CNPJ, CPF ou nome de representante deve ser escrito neste arquivo de regra.

Se aquele arquivo não existir, monte a classificação a partir dos `perfil-osc.md` da carteira e grave-o lá, no mesmo formato.

## Por que esta regra existe

O tipo de proponente é o filtro que derruba mais rápido: edital exclusivo para entidade sem fins lucrativos elimina de saída toda empresa da carteira, por melhor que seja a aderência temática. Antes desta regra, essa informação vivia espalhada dentro de cada `perfil-osc.md` e precisava ser redescoberta a cada triagem, com risco real de indicar edital incompatível ou de gastar um parecer de elegibilidade inteiro num caso já perdido. Consolidado com a captadora em 12/08/2026.

## A regra

1. **Antes de indicar um edital a um cliente**, cheque o tipo de proponente exigido pelo edital contra a classificação da carteira. Incompatibilidade de tipo é INAPTO NO MOMENTO, não pendência sanável: diga isso de saída, em vez de percorrer o parecer inteiro.
2. **Antes de emitir o veredito de elegibilidade**, confirme a natureza jurídica no `perfil-osc.md` do cliente. O arquivo da carteira é o mapa rápido; o perfil e o documento oficial (cartão CNPJ, contrato social, estatuto) continuam sendo a fonte.
3. **Divergência entre contrato de assessoria e documento oficial: manda o documento oficial.** É o que a banca lê. Registrar a divergência no perfil e seguir pelo documento, sem esperar a correção do contrato.
4. **Cliente com mais de uma via de proponente** (por exemplo um coletivo que pode concorrer pelo MEI da representante, pelo CPF dela ou como coletivo sem CNPJ): definir qual via será usada ANTES de montar o checklist documental, porque cada via exige documentos e certidões diferentes. MEI é pessoa jurídica com fins lucrativos e nunca substitui uma OSC.

## O que cada tipo alcança

| Tipo de proponente | Alcança | Está fechado para |
|---|---|---|
| Sem fins lucrativos (associação, fundação, OSCIP) | Edital exclusivo de OSC, MROSC (termo de fomento e de colaboração), fundo público, assistência social, chamada que exige CEBAS ou inscrição em conselho, além de leis de incentivo | Praticamente nada por tipo; as barreiras são documentais |
| Com fins lucrativos (LTDA, Empresário Individual, MEI) | Leis de incentivo (Rouanet, Audiovisual, incentivo estadual), fomento cultural com proponente empresarial, patrocínio direto, fundo empresarial | Fundo público, MROSC, assistência social e todo edital exclusivo de entidade sem fins lucrativos |
| Pessoa física e coletivo sem CNPJ | Edital com categoria de proponente pessoa física ou coletivo, comum em fomento cultural municipal, estadual, PNAB/Aldir Blanc e Funarte | Todo edital que exige CNPJ de associação, tempo mínimo de existência como pessoa jurídica ou inscrição em conselho |

## Manutenção

Ao cadastrar cliente novo (`/osc-nova` ou `/osc-importar`), acrescentar a linha dele ao arquivo da carteira, no bloco correspondente. Ao descobrir divergência entre contrato de assessoria e documento oficial, registrar lá e no `perfil-osc.md`, sempre a favor do documento oficial.
