---meta
documento: MODELO. CHECKLIST DE DOCUMENTOS
titulo: Checklist de documentos, anexos e manuais
subtitulo: Modelo em branco do levantamento documental de um edital
chamada: Tudo que o edital exige anexar, em um lugar só
rotulo_orgao: Agente responsável
orgao: CaptaDoc, apoio à submissão
base_legal: Checklist de 13 pontos do CaptaDoc e fonte única de documentos dos clientes
prazo: Preencher com a data e a hora do prazo final de envio
plataforma: Preencher com a plataforma de submissão do edital
data: Preencher com a data de elaboração do checklist
arquivo: MODELO-checklist-documentos-edital
nota_capa: Este é um modelo em branco. Cada quadradinho é um item para conferir. O que ficar sem marcar é o que ainda falta resolver. Substitua todo texto entre chaves duplas pelo dado real do edital e da OSC.
fecho: Modelo do sistema AMC IA. Documento de apoio à submissão, não substitui a leitura integral do edital e dos seus anexos.
---

## 0. Como usar este modelo

Cinco regras que valem para todo checklist gerado a partir deste modelo.

1. Substitua todo texto entre chaves duplas pelo dado real do edital e da OSC.
2. Cada linha de quadro tem uma situação. Use sempre uma destas cinco: Resolvido, Pendente, Bloqueador (eliminatório), Fase de celebração ou Não se aplica a este edital. Nunca apague uma linha só porque não se aplica: troque a situação para "Não se aplica" e explique o motivo em uma frase. É o mesmo princípio do checklist de 13 pontos do CaptaDoc, nunca pular em silêncio.
3. As seções 3 a 9 são modulares. Um edital pequeno pode não ter anexos técnicos complexos nem comprovações físicas. Nesse caso deixe só uma linha na seção dizendo "este edital não exige", em vez de apagar a seção inteira. Isso preserva o registro de que o ponto foi checado, não ignorado.
4. A seção 10 (manuais e fontes) é o lugar de reunir Manual do Proponente, portaria, instrução normativa, FAQ e contato do órgão. Preencha sempre que o edital tiver mais de um documento normativo, o que é comum em edital complexo.
5. Antes de marcar qualquer documento como pendente, é obrigatório conferir a pasta real do cliente, conforme `.claude/rules/fonte-documentos-clientes.md`. Link de Drive e descrição no perfil da OSC não são fonte válida de documento.

### As cinco situações possíveis

| Situação | Quando usar |
| --- | --- |
| Resolvido | Documento já anexado ou emitido, dentro da validade |
| Pendente | Falta providenciar, mas tem caminho conhecido |
| Bloqueador (eliminatório) | Item eliminatório: sem este documento, a proposta é inabilitada |
| Fase de celebração | Só exigido se a OSC for selecionada, não trava o envio |
| Não se aplica | Checado, não vale para este edital, com o motivo em uma frase |

## 1. Identificação e prazo

| Campo | Preencher com |
| --- | --- |
| Proponente | {{OSC_NOME}} ({{OSC_MUNICIPIO_UF}}) |
| Projeto | {{NOME_DO_PROJETO}} |
| Edital | {{EDITAL_NOME_COMPLETO}} ({{EDITAL_IDENTIFICACAO}}) |
| Objeto resumido | {{EDITAL_OBJETO_RESUMIDO_UMA_LINHA}} |
| Plataforma de submissão | {{PLATAFORMA_SUBMISSAO}} |
| Data de elaboração deste checklist | {{DATA_ATUALIZACAO}} |
| Documentos conferidos na pasta do cliente em | {{DATA_LEVANTAMENTO}} |

!> **Prazo final de envio: {{DATA_HORA_PRAZO_FINAL}}** (item {{ITEM_EDITAL_PRAZO}} do edital). Depois desse horário nenhum documento ou complemento é aceito.

## 2. Painel geral do edital

Dados administrativos que orientam a leitura do restante do checklist. Preencher sempre, mesmo em edital pequeno.

| Campo | Conteúdo |
| --- | --- |
| Órgão ou instituição financiadora | {{ORGAO_FINANCIADOR}} |
| Objeto do edital | {{OBJETO_DO_EDITAL}} |
| Valor total e por proposta | {{VALOR_TOTAL}} no total, até {{VALOR_MAXIMO_POR_PROPOSTA}} por proposta |
| Quantidade de propostas contempladas | {{QUANTIDADE_PROPOSTAS_PREVISTA}} |
| Vigência do instrumento | {{VIGENCIA_MESES_OU_DATAS}} |
| Instrumento jurídico | {{TIPO_INSTRUMENTO: termo de fomento, termo de colaboração, contrato de repasse, outorga}} |

## 3. Declarações e anexos do próprio edital

Modelos oficiais fornecidos pelo edital, em geral para preencher e assinar sem alteração de formato.

| ☐ | Documento | Observação | Referência | Situação |
| --- | --- | --- | --- | --- |
| ☐ | {{ANEXO_1_NOME}} | {{ANEXO_1_OBSERVACAO}} | {{ITEM_EDITAL_ANEXO_1}} | {{Pendente}} |
| ☐ | {{ANEXO_2_NOME}} | {{ANEXO_2_OBSERVACAO}} | {{ITEM_EDITAL_ANEXO_2}} | {{Bloqueador}} |
| ☐ | {{ANEXO_N_NOME}} | Repita esta linha para cada anexo declaratório do edital | {{ITEM_EDITAL_ANEXO_N}} | {{Não se aplica}} |

## 4. Anexos técnicos do projeto

Diferente da seção 3: aqui o conteúdo é redigido pela OSC dentro de um modelo, não apenas assinado. Comum em edital complexo com roteiro de proposta próprio. Em edital simples pode se resumir a um ou dois itens.

| ☐ | Documento | Observação | Referência | Situação |
| --- | --- | --- | --- | --- |
| ☐ | Plano de trabalho no modelo oficial | Metas, etapas, indicadores e prazos no formato exigido pelo edital | {{ITEM_EDITAL_PLANO_TRABALHO}} | {{Bloqueador}} |
| ☐ | Planilha orçamentária detalhada por meta ou etapa | Anexar como arquivo separado, não só descrever no texto da proposta | {{ITEM_EDITAL_ORCAMENTO}} | {{Pendente}} |
| ☐ | {{ANEXO_TECNICO_ADICIONAL: termo de referência de equipamentos, cronograma físico-financeiro}} | {{OBSERVACAO}} | {{ITEM_EDITAL}} | {{Não se aplica}} |

## 5. Cadastros, certidões e regularidade institucional

Documentos emitidos por terceiros (Receita Federal, prefeitura, órgãos ambientais, plataformas de governo). Verificar sempre a validade na data do envio, não só a existência do documento.

| ☐ | Documento | Observação | Referência | Situação |
| --- | --- | --- | --- | --- |
| ☐ | Comprovante de inscrição no CNPJ | Emitido pela Receita Federal, dentro do prazo de validade do edital | {{ITEM_EDITAL_CNPJ}} | {{Pendente}} |
| ☐ | Certidões negativas de débitos (federal, estadual, municipal, FGTS e trabalhista) | Conferir se o edital exige todas ou apenas parte delas | {{ITEM_EDITAL_CERTIDOES}} | {{Bloqueador}} |
| ☐ | {{CADASTRO_OU_LICENCA_ESPECIFICA: SINIR, licença ambiental, CEBAS, alvará}} | {{OBSERVACAO_DE_VALIDADE}} | {{ITEM_EDITAL}} | {{Pendente}} |
| ☐ | Comprovante de endereço da sede | Precisa estar em nome da própria OSC, não de pessoa física | {{ITEM_EDITAL}} | {{Pendente}} |
| ☐ | Documento de identificação do representante legal | Conferir se o edital aceita a versão digital | {{ITEM_EDITAL}} | {{Pendente}} |

## 6. Comprovações físicas, fotográficas e territoriais

Só se aplica quando o edital pede evidência do espaço físico, da infraestrutura ou do território de atuação. Marque "Não se aplica" quando o edital não exigir nada disto.

| ☐ | Comprovação | Observação | Referência | Situação |
| --- | --- | --- | --- | --- |
| ☐ | Relatório fotográfico da sede ou do espaço de execução | Área interna, externa e equipamentos já existentes | {{ITEM_EDITAL}} | {{Não se aplica}} |
| ☐ | {{COMPROVACAO_TERRITORIAL: mapa de abrangência, declaração de funcionamento no território}} | {{OBSERVACAO}} | {{ITEM_EDITAL}} | {{Não se aplica}} |

## 7. Levantamentos internos que a OSC precisa produzir

Não vêm prontos de nenhum órgão externo: nascem de um levantamento feito pela própria organização (listas nominais, dados de beneficiários, autodeclarações). Costuma ser o gargalo de tempo, não de burocracia.

| ☐ | O que levantar | Para que serve | Referência | Situação |
| --- | --- | --- | --- | --- |
| ☐ | {{LEVANTAMENTO_1: lista nominal de beneficiários, autodeclaração de gênero e raça}} | {{PARA_QUE_SERVE}} | {{REFERENCIA}} | {{Pendente}} |
| ☐ | {{LEVANTAMENTO_2}} | {{PARA_QUE_SERVE}} | {{REFERENCIA}} | {{Pendente}} |

## 8. Só se a OSC for selecionada

Fase de celebração. Não trava o envio da proposta hoje. Vale adiantar o que já estiver pronto, mas não é motivo para atrasar a submissão.

| ☐ | Documento | Referência | Situação |
| --- | --- | --- | --- |
| ☐ | Estatuto social registrado e alterações | {{ITEM_EDITAL}} | {{Fase de celebração}} |
| ☐ | Ata de eleição da diretoria atual | {{ITEM_EDITAL}} | {{Fase de celebração}} |
| ☐ | {{DOCUMENTO_CELEBRACAO: comprovante de experiência prévia, certidões adicionais}} | {{ITEM_EDITAL}} | {{Fase de celebração}} |

## 9. Pendência com risco jurídico ou de divergência

Reservado para o tipo de problema que não é "falta o documento", e sim "o documento existe mas tem uma inconsistência": vencido, nome divergente, órgão errado, dado que não bate com o cartão CNPJ. Preencher só quando existir um caso assim.

!> **{{NOME_DO_DOCUMENTO_COM_PROBLEMA}}**: {{DESCRICAO_DA_DIVERGENCIA_OU_VENCIMENTO}}.
!> Encaminhamento: {{ENCAMINHAMENTO_PARA_RESOLVER}}. Prazo necessário: {{PRAZO_ESTIMADO}}.

Quando não houver nenhum caso, escrever aqui: {{Nenhuma divergência documental identificada neste levantamento.}}

## 10. Manuais, normas e fontes de apoio do edital

Documentos normativos que não entram na submissão, mas orientam a leitura de todos os itens acima. Em edital simples pode se resumir ao próprio texto do edital. Em edital complexo costuma haver manual do proponente, portaria, instrução normativa e FAQ separados.

| Fonte | Onde encontrar |
| --- | --- |
| Edital publicado | {{LINK_OU_LOCAL_DO_EDITAL}} |
| Manual do proponente | {{LINK_MANUAL_PROPONENTE}} |
| Portaria ou instrução normativa de base | {{NORMA_DE_BASE}} |
| Perguntas frequentes (FAQ) do órgão | {{LINK_FAQ}} |
| Tutorial da plataforma de submissão | {{LINK_TUTORIAL_PLATAFORMA}} |
| Contato do órgão para dúvidas | {{EMAIL_OU_TELEFONE_ORGAO}} |
| Prazo do canal de dúvidas | {{PRAZO_PARA_ENVIAR_DUVIDA}} |
