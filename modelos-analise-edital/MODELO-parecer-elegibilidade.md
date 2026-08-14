---meta
documento: MODELO. PARECER DE ELEGIBILIDADE
titulo: Parecer de elegibilidade
subtitulo: Modelo em branco do CaptaDoc, primeira estação da linha de montagem
chamada: O sinal verde ou vermelho antes de escrever qualquer proposta
rotulo_orgao: Agente responsável
orgao: CaptaDoc
base_legal: Gate de Elegibilidade (CLAUDE.md) e checklist de 13 pontos do CaptaDoc
prazo: Preencher com o prazo final de inscrição do edital
plataforma: Preencher com a plataforma de submissão do edital
data: Preencher com a data de elaboração do parecer
arquivo: MODELO-parecer-elegibilidade
nota_capa: Este é um modelo em branco. Substitua todo texto entre chaves duplas pelo dado real do edital e da OSC. Nenhuma seção pode ficar vazia: quando o edital não trouxer a informação, registre "o edital não especifica" em vez de deixar em branco.
fecho: Modelo do sistema AMC IA, agente CaptaDoc. Gate de Elegibilidade: nenhuma proposta deve ser escrita antes deste parecer.
---

## 0. Como usar este modelo

Seis regras que valem para todo parecer gerado a partir deste modelo.

1. Substitua todo texto entre chaves duplas pelo dado real do edital e da OSC.
2. Este documento só pode ser gerado depois de rodar o checklist de 13 pontos (`.claude/rules/checklist-triagem-captadoc.md`). As seções 4 a 11 mapeiam direto para esses 13 pontos, e nenhuma pode ficar em branco, mesmo quando a resposta é "este edital não traz esta informação". Lacuna do edital é registro, não é lacuna do parecer.
3. O veredito usa exatamente a linguagem do Gate de Elegibilidade: APTO, APTO COM PENDÊNCIAS ou INAPTO NO MOMENTO. Nunca troque por sinônimo.
4. A seção 9 (quadro de aderência) é o coração do documento: cada requisito do edital vira uma linha comparada com a situação real da OSC. A coluna "Como tornar elegível" só fica vazia quando o status for Atende. Todo "Não atende" ou "Atende parcialmente" precisa de uma solução concreta, viável e legal, nunca um genérico "regularizar".
5. A seção 12 (caminhos para elegibilidade) agrupa as soluções da seção 9 por prazo de resolução. É o que direciona o próximo passo do captador quando o veredito não é APTO.
6. Antes de declarar qualquer documento como faltando, é obrigatório conferir a pasta real do cliente, conforme `.claude/rules/fonte-documentos-clientes.md`. O perfil da OSC sozinho não é fonte de documento.

> Vocabulário das pílulas de situação, usado em todos os quadros deste parecer: **Atende**, **Atende parcialmente**, **Não atende** e **Não se aplica**. Nunca apague uma linha porque não se aplica: troque a marcação e explique o motivo em uma frase.

## 1. Identificação do parecer

| Campo | Preencher com |
| --- | --- |
| OSC avaliada | {{OSC_NOME}} ({{OSC_MUNICIPIO_UF}}) |
| Natureza jurídica | {{NATUREZA_JURIDICA_DA_OSC}} |
| Edital | {{EDITAL_NOME_COMPLETO}} ({{EDITAL_IDENTIFICACAO}}) |
| Órgão financiador | {{ORGAO_FINANCIADOR}} |
| Categoria ou linha pretendida | {{CATEGORIA_OU_LINHA}} |
| Data de elaboração | {{DATA_ATUALIZACAO}} |
| Documentos conferidos na pasta do cliente em | {{DATA_LEVANTAMENTO}} |

## 2. Veredito

| Veredito | Justificativa | Pode avançar para a proposta? |
| --- | --- | --- |
| {{VEREDITO: APTO, APTO COM PENDÊNCIAS ou INAPTO NO MOMENTO}} | {{JUSTIFICATIVA_DO_VEREDITO_EM_UMA_OU_DUAS_FRASES}} | {{RESPOSTA_DO_GATE}} |

### As três respostas possíveis do Gate de Elegibilidade

- **APTO.** Sim, caminho livre.
- **APTO COM PENDÊNCIAS.** Sim, em paralelo, mas a submissão depende de regularizar as pendências listadas na seção 12.
- **INAPTO NO MOMENTO.** Não. Resolver antes de escrever qualquer proposta.

!> Regra de ouro do sistema: nunca elabore a proposta antes deste parecer existir para aquele edital e aquela OSC. A dor número um do captador é gastar semanas escrevendo um projeto e descobrir, depois de submeter, que a organização nunca foi elegível.

## 3. Resumo em números

| Indicador | Quantidade |
| --- | --- |
| Requisitos atendidos | {{N_ATENDE}} de {{N_TOTAL}} |
| Pendências regularizáveis | {{N_PENDENTE_REGULARIZAVEL}} |
| Bloqueadores sem solução no momento | {{N_BLOQUEADOR_SEM_SOLUCAO}} |

## 4. O edital em síntese

Base para todo o resto do parecer. Se algum destes campos não estiver claro no texto do edital, registre "o edital não especifica" em vez de deixar em branco.

| Campo | Conteúdo |
| --- | --- |
| Objeto do edital | {{OBJETO_DO_EDITAL}} |
| Justificativa ou problema que o edital busca resolver | {{JUSTIFICATIVA_DO_EDITAL}} |
| Eixos, linhas temáticas ou categorias | {{EIXOS_OU_LINHAS_TEMATICAS}} |
| Valor total e por proposta | {{VALOR_TOTAL}} no total, até {{VALOR_MAXIMO_POR_PROPOSTA}} por proposta |
| Quantidade de propostas contempladas | {{QUANTIDADE_PROPOSTAS_PREVISTA}} |
| Prazo de inscrição | {{PRAZO_INSCRICAO}} |
| Vigência do instrumento | {{VIGENCIA}} |
| Instrumento jurídico | {{TIPO_INSTRUMENTO}} |

## 5. Quem pode e quem não pode participar

Requisitos gerais de participação e impedimentos previstos no edital, antes de qualquer critério de pontuação.

| Exigência do edital | O que o edital pede | Referência | Situação real da OSC | Atende? |
| --- | --- | --- | --- | --- |
| Natureza jurídica exigida | {{NATUREZA_JURIDICA_EXIGIDA}} | {{ITEM_EDITAL}} | {{NATUREZA_JURIDICA_DA_OSC}} | {{Atende}} |
| Tempo mínimo de existência do CNPJ | {{TEMPO_MINIMO_CNPJ_EXIGIDO}} | {{ITEM_EDITAL}} | {{IDADE_REAL_DO_CNPJ}} | {{Atende}} |
| Tempo mínimo de atuação na área | {{TEMPO_MINIMO_ATUACAO_EXIGIDO}} | {{ITEM_EDITAL}} | {{TEMPO_REAL_DE_ATUACAO}} | {{Atende parcialmente}} |
| Território elegível | {{TERRITORIO_EXIGIDO}} | {{ITEM_EDITAL}} | {{TERRITORIO_DA_OSC}} | {{Atende}} |
| Área de atuação exigida (estatutária ou de fato) | {{AREA_ATUACAO_EXIGIDA}} | {{ITEM_EDITAL}} | {{AREA_ATUACAO_DA_OSC}} | {{Não atende}} |
| Impedimentos previstos | {{IMPEDIMENTOS_LISTADOS_NO_EDITAL}} | {{ITEM_EDITAL}} | {{SITUACAO_DA_OSC_QUANTO_A_IMPEDIMENTOS}} | {{Atende}} |

> **Primeiro filtro, sempre.** O tipo de proponente (sem fins lucrativos, com fins lucrativos, MEI ou pessoa física) é a pergunta que derruba mais rápido. Incompatibilidade de tipo é INAPTO NO MOMENTO, não é pendência sanável: diga isso de saída, sem percorrer o parecer inteiro. Ver `.claude/rules/naturezas-juridicas-carteira.md`.

## 6. Categorias ou linhas de financiamento

Quando o edital divide o financiamento em categorias com regras próprias (valor, público, despesas permitidas), identifique qual categoria se aplica à OSC antes de seguir. Se o edital tiver categoria única, registre isso e siga.

| Campo | Conteúdo |
| --- | --- |
| Categoria recomendada para esta OSC | {{CATEGORIA_RECOMENDADA}} |
| Por que esta categoria | {{JUSTIFICATIVA_DA_ESCOLHA_DE_CATEGORIA}} |
| Valor e regras específicas desta categoria | {{REGRAS_DA_CATEGORIA}} |
| Despesas permitidas nesta categoria | {{DESPESAS_PERMITIDAS_NA_CATEGORIA}} |
| Vagas previstas nesta categoria | {{VAGAS_NA_CATEGORIA}} |

## 7. Base de cálculo externa e variável

Alguns editais pontuam ou desempatam por um índice externo ao próprio edital (IDHM do município, faixa de população do IBGE, renda per capita). Quando existir, extraia a tabela real de faixas e valores, nunca uma direção genérica do tipo "quanto menor, mais pontua". Quando não existir, registre isso explicitamente.

| Índice ou faixa | Valor em {{MUNICIPIO_OU_TERRITORIO_DA_OSC}} | Pontuação correspondente |
| --- | --- | --- |
| {{NOME_DO_INDICE, por exemplo IDHM}} | {{VALOR_DO_INDICE_NO_TERRITORIO}} | {{PONTOS_OU_EFEITO_NA_ELEGIBILIDADE}} |
| {{FAIXA_2}} | {{VALOR_2}} | {{PONTOS_2}} |

Quando não houver base externa, escrever aqui: {{Este edital não utiliza nenhuma base de cálculo externa.}}

Documento ou fonte que prevalece para apurar o índice: {{FONTE_OFICIAL_DO_INDICE}}

## 8. Contrapartida, prestação de contas e acessibilidade

Exigências que não eliminam a proposta na largada, mas que a OSC precisa confirmar que consegue cumprir ao longo da execução.

| Campo | Conteúdo |
| --- | --- |
| Contrapartida exigida | {{CONTRAPARTIDA_EXIGIDA}} |
| A OSC tem condições de cumprir? | {{AVALIACAO_DA_CAPACIDADE_DE_CONTRAPARTIDA}} |
| Regras de prestação de contas relevantes | {{REGRAS_PRESTACAO_CONTAS}} |
| Acessibilidade e democratização do acesso | {{EXIGENCIAS_DE_ACESSIBILIDADE_SE_HOUVER}} |

## 9. Quadro de aderência, requisito a requisito

Coração do parecer. Todo requisito de elegibilidade e habilitação do edital, comparado com a situação real da OSC. Todo "Não atende" ou "Atende parcialmente" precisa de uma solução concreta na última coluna, nunca ficar vazia.

| Requisito | Situação real da OSC | Referência | Status | Como tornar elegível |
| --- | --- | --- | --- | --- |
| {{REQUISITO_1}} | {{SITUACAO_REAL_DA_OSC_1}} | {{ITEM_EDITAL_1}} | {{Atende}} | {{vazio quando atende}} |
| {{REQUISITO_2}} | {{SITUACAO_REAL_DA_OSC_2}} | {{ITEM_EDITAL_2}} | {{Atende parcialmente}} | {{SOLUCAO_VIAVEL_E_LEGAL_2, por exemplo protocolar a certidão em atraso ainda dentro do prazo do edital}} |
| {{REQUISITO_3}} | {{SITUACAO_REAL_DA_OSC_3}} | {{ITEM_EDITAL_3}} | {{Não atende}} | {{SOLUCAO_VIAVEL_E_LEGAL_3, por exemplo formalizar parceria em rede com entidade que atenda ao tempo mínimo de atuação, como executora conjunta}} |
| {{REQUISITO_N}} | Repita esta linha para cada requisito relevante do edital | {{ITEM_EDITAL_N}} | {{Não se aplica}} | {{OBSERVACAO}} |

## 10. Itens financiáveis e vedados que afetam a elegibilidade

Não é o orçamento técnico completo, que é tarefa do CaptaBudget. São os limites que, se ignorados agora, eliminam a proposta depois.

!> **Atenção na elaboração.** {{DESPESAS_VEDADAS_RELEVANTES_PARA_ESTA_OSC}}
!> {{TETO_OU_PERCENTUAL_POR_CATEGORIA_RELEVANTE}}
!> {{EXIGENCIA_DE_TRES_COTACOES_OU_REGRA_DE_COMPRA_SE_HOUVER}}

## 11. Riscos de inabilitação

Priorizados do maior para o menor risco real, considerando o perfil desta OSC especificamente, não uma lista genérica de riscos do edital.

| Risco | Por que existe para esta OSC | Gravidade |
| --- | --- | --- |
| {{RISCO_1}} | {{POR_QUE_SE_APLICA_1}} | {{Alto}} |
| {{RISCO_2}} | {{POR_QUE_SE_APLICA_2}} | {{Médio}} |
| {{RISCO_3}} | {{POR_QUE_SE_APLICA_3}} | {{Baixo}} |

## 12. Caminhos para tornar a OSC elegível

Reúne as soluções da seção 9, organizadas por prazo de resolução. É o plano de ação quando o veredito não é APTO. Cada item precisa ser uma ação concreta e legal, nunca uma orientação vaga.

### Regularização imediata (dias)

- [ ] {{ACAO_IMEDIATA_1}}: {{DETALHE_E_ONDE_PROVIDENCIAR}}
- [ ] {{ACAO_IMEDIATA_2}}: {{DETALHE_E_ONDE_PROVIDENCIAR}}

### Ajuste formal (semanas)

- [ ] {{AJUSTE_FORMAL_1, por exemplo alteração de estatuto, ata ou endereço}}: {{DETALHE_DO_PROCEDIMENTO}}

### Solução de médio prazo (meses)

- [ ] {{SOLUCAO_MEDIO_PRAZO_1, por exemplo aguardar o tempo mínimo de existência ou formar parceria em rede com entidade mais madura}}: {{DETALHE_E_PRAZO_ESTIMADO}}

### Alternativa estratégica

- [ ] {{ALTERNATIVA_ESTRATEGICA, por exemplo mudar de categoria dentro do mesmo edital, ou buscar outro edital mais alinhado ao perfil atual da OSC}}: {{JUSTIFICATIVA}}

## 13. Recomendação final

> **Recomendação do CaptaDoc.** {{RECOMENDACAO_FINAL_EM_LINGUAGEM_DIRETA}}
> {{CHECKLIST_DOCUMENTAL_RESUMIDO}}. Ver checklist completo em {{CAMINHO_DO_ARQUIVO_DE_CHECKLIST}}.
> Próximo comando recomendado: {{PROXIMO_COMANDO, por exemplo /projeto-escrever quando o veredito for APTO}}.
