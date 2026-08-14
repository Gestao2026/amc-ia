---meta
documento: MODELO. AUDITORIA DE BANCA
titulo: Auditoria de banca
subtitulo: Modelo em branco do CaptaScore, última estação antes da submissão
chamada: A nota que o projeto tira hoje, a que ele pode tirar e o teto real
rotulo_orgao: Agente responsável
orgao: CaptaScore
base_legal: Critérios de julgamento do próprio edital, com os pesos publicados
prazo: Preencher com o prazo final de submissão
plataforma: Preencher com a plataforma de submissão do edital
data: Preencher com a data da avaliação
arquivo: MODELO-auditoria-banca
nota_capa: Este é um modelo em branco. Ele só faz sentido depois da proposta (CaptaBuilder) e do orçamento (CaptaBudget) estarem prontos. É a última estação antes da submissão.
fecho: Modelo do sistema AMC IA, agente CaptaScore. A nota projetada só se confirma se as pendências listadas forem efetivamente resolvidas antes do envio.
---

## 0. Como usar este modelo

Seis regras que valem para toda auditoria gerada a partir deste modelo.

1. Substitua todo texto entre chaves duplas pelo dado real do edital, da proposta e do orçamento.
2. Este documento só faz sentido depois da proposta e do orçamento estarem prontos. Rodar antes disso produz uma nota sem lastro.
3. As três notas do topo respondem a três perguntas diferentes: onde o projeto está hoje, onde ele chega se as pendências listadas forem resolvidas, e qual é o teto que ele alcança mesmo com tudo resolvido. Alguns critérios travam por natureza do projeto, não por documento faltando, e é isso que o teto revela.
4. Os pesos do quadro de critérios devem somar 100. Se o edital trouxer critérios e pesos próprios, use exatamente os dele. Só recorra aos critérios genéricos do Método Captar quando o edital não especificar os seus.
5. Os quatro grupos do plano de regularização (bloqueia, decide a nota, leva ao teto, só na contratação) são a saída mais acionável do documento. Cada item precisa ser uma tarefa concreta, com responsável e prazo, nunca uma orientação vaga.
6. Toda nota atribuída precisa estar ancorada em um trecho da proposta ou do orçamento. Nota sem lastro no texto é palpite, e palpite não sobrevive à banca.

> **Critérios genéricos, só quando o edital não trouxer os seus:** aderência ao edital, capacidade técnica, potencial de impacto, coerência metodológica, clareza de objetivos, orçamento, cronograma, inovação e sustentabilidade institucional.

## 1. Identificação da avaliação

| Campo | Preencher com |
| --- | --- |
| Projeto avaliado | {{NOME_DO_PROJETO}} |
| Cliente | {{OSC_NOME}} |
| Edital | {{EDITAL_NOME_COMPLETO}} ({{EDITAL_IDENTIFICACAO}}) |
| Categoria ou linha | {{CATEGORIA_OU_LINHA}} |
| Instrumento jurídico | {{TIPO_INSTRUMENTO}} |
| Valor solicitado | {{VALOR_SOLICITADO}} |
| Documentos avaliados | proposta de {{DATA_DA_PROPOSTA}} e orçamento de {{DATA_DO_ORCAMENTO}} |
| Data desta avaliação | {{DATA_ATUALIZACAO}} |

## 2. As três notas

| Leitura | Nota | O que ela significa |
| --- | --- | --- |
| Sem regularização | {{NOTA_ATUAL}} de 10 | Situação hoje, com a proposta como está |
| Com regularização | {{NOTA_PROJETADA}} de 10 | Se as pendências da seção 5 forem resolvidas |
| Teto real do projeto | {{NOTA_TETO}} de 10 | {{EXPLICACAO_CURTA_DO_TETO: por que não chega a 10 mesmo com tudo resolvido}} |

### Chance de aprovação por fase

| Fase | Chance estimada | Justificativa |
| --- | --- | --- |
| Habilitação (eliminatória) | {{CHANCE_HABILITACAO}} | {{JUSTIFICATIVA_HABILITACAO}} |
| Avaliação técnica | {{CHANCE_TECNICA}} | {{JUSTIFICATIVA_TECNICA}} |
| Contemplação final | {{CHANCE_CONTEMPLACAO}} | {{JUSTIFICATIVA_CONTEMPLACAO, considerando o número de vagas e a concorrência esperada}} |

## 3. Critérios de avaliação, peso a peso

Use os critérios e os pesos do próprio edital sempre que ele os especificar. A soma da coluna de peso precisa fechar em 100.

Leitura das colunas de nota: **Hoje** é a nota sem regularização, **Reg.** é a nota com as pendências resolvidas, **Teto** é o limite real daquele critério.

| Critério | Peso | Hoje | Reg. | Teto | Situação | O que falta para o teto |
| --- | --- | --- | --- | --- | --- | --- |
| {{critério 1}} | {{15}} | {{7,0}} | {{8,5}} | {{9,0}} | {{Aprovado}} | {{o que falta neste critério}} |
| {{critério 2}} | {{20}} | {{4,0}} | {{7,0}} | {{8,0}} | {{Reprovado}} | {{o que falta neste critério}} |
| {{critério 3}} | {{15}} | {{8,0}} | {{9,0}} | {{9,5}} | {{Aprovado}} | {{o que falta neste critério}} |
| {{critério N}} | {{50}} | {{nota}} | {{nota}} | {{nota}} | {{Aprovado}} | {{repetir a linha para cada critério do edital}} |
| **Total** | **100** | {{6,2}} | {{8,1}} | {{8,8}} | | |

## 4. Corte eliminatório e explicação do teto

!> **{{CRITERIO_COM_CORTE_MINIMO}}**: {{EXPLICACAO_DO_CORTE_ELIMINATORIO_SE_HOUVER}}.

> **Por que o teto não é 10.** {{EXPLICACAO_DO_TETO_GERAL: quais critérios travam por leitura interpretativa da banca ou por dado que só existe depois da execução, não por documento faltando}}.

### Inconsistências internas encontradas

| Onde | Inconsistência | Efeito na nota |
| --- | --- | --- |
| {{ONDE_1: seção da proposta ou rubrica do orçamento}} | {{INCONSISTENCIA_1, por exemplo atividade sem item correspondente no orçamento}} | {{EFEITO_1}} |
| {{ONDE_2}} | {{INCONSISTENCIA_2}} | {{EFEITO_2}} |

Quando não houver nenhuma, escrever aqui: {{Nenhuma inconsistência interna entre proposta, orçamento e cronograma.}}

## 5. O que regularizar, com prazo

Cada item é uma tarefa concreta, com responsável e prazo. Os quatro grupos estão em ordem de urgência.

### Bloqueia a submissão

- [ ] {{ACAO_BLOQUEADORA_1}}. Responsável: {{RESPONSAVEL}}. Prazo: {{PRAZO}}.
- [ ] {{ACAO_BLOQUEADORA_2}}. Responsável: {{RESPONSAVEL}}. Prazo: {{PRAZO}}.

### Não bloqueia, mas decide a nota

- [ ] {{ACAO_DECISIVA_1}}. Responsável: {{RESPONSAVEL}}. Prazo: {{PRAZO}}.
- [ ] {{ACAO_DECISIVA_2}}. Responsável: {{RESPONSAVEL}}. Prazo: {{PRAZO}}.

### Leva ao teto real

- [ ] {{ACAO_TETO_1}}. Responsável: {{RESPONSAVEL}}. Prazo: {{PRAZO}}.

### Recomendado, só exigido na contratação

- [ ] {{ACAO_RECOMENDADA_1}}. Responsável: {{RESPONSAVEL}}. Prazo: {{PRAZO}}.

## 6. Pontos fortes e fragilidades

| Pontos fortes, o que sustenta a nota | Fragilidades, o que a derruba |
| --- | --- |
| {{PONTO_FORTE_1}} | {{FRAGILIDADE_1}} |
| {{PONTO_FORTE_2}} | {{FRAGILIDADE_2}} |
| {{PONTO_FORTE_3}} | {{FRAGILIDADE_3}} |

## 7. Reescrita dos campos críticos

Versão nota 9,5. Indicar quais campos da proposta foram reescritos pelo CaptaScore e onde encontrar a versão revisada.

| Campo reescrito | Motivo da reescrita | Onde está a versão revisada |
| --- | --- | --- |
| {{CAMPO_1, por exemplo objetivos específicos}} | {{MOTIVO_1}} | {{CAMINHO_E_SECAO}} |
| {{CAMPO_2, por exemplo metodologia}} | {{MOTIVO_2}} | {{CAMINHO_E_SECAO}} |

> **Veredito do CaptaScore.** {{RECOMENDACAO_FINAL: submeter como está, submeter depois de resolver os itens bloqueadores, ou não submeter neste ciclo}}. {{JUSTIFICATIVA_EM_UMA_OU_DUAS_FRASES}}.
