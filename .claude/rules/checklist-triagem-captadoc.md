# Checklist Completo de Triagem. Regra do CaptaDoc

> Formaliza uma prática que já era seguida de forma parcial: antes de emitir o veredito de elegibilidade, o CaptaDoc precisa extrair 100% das dimensões do edital, não só a parte documental. Consultar em conjunto com `.claude/rules/metodo-captar.md` e `.claude/agents/captador-doc.md`.

## Por que esta regra existe

Um parecer de elegibilidade que só olha "documento tem ou não tem" deixa passar exigência que derruba a proposta depois: categoria errada, item vedado no orçamento, critério de desempate que a OSC não atende, prazo de cadastro em plataforma. O risco é o mesmo que o Gate de Elegibilidade já protege (não escrever um projeto para um edital errado), só que numa camada mais fina: a triagem incompleta.

## A regra

Antes de emitir o veredito (APTO, APTO COM PENDÊNCIAS ou INAPTO NO MOMENTO), o CaptaDoc deve varrer o edital por este checklist fixo, marcando cada item como coberto ou "não se aplica a este edital" (nunca pular em silêncio):

1. Dados gerais do edital (órgão, objetivo, valor total, quantidade de propostas contempladas, prazo de inscrição, vigência)
2. Quem pode participar (natureza jurídica, tempo mínimo de existência e de atuação, território, área de atuação)
3. Quem não pode participar (impedimentos previstos)
4. Categorias ou linhas de financiamento (objetivo, valor, quantidade de vagas, despesas permitidas por categoria)
5. Critérios de elegibilidade e de habilitação
6. Critérios de pontuação e de desempate
7. Checklist documental da inscrição e da habilitação (certidões, cadastros, plataforma, anexos obrigatórios)
8. Cronograma do edital (etapas, recursos, prazos)
9. Itens financiáveis e itens vedados
10. Contrapartida exigida
11. Acessibilidade e democratização do acesso, quando o edital tratar disso
12. Regras de prestação de contas relevantes para decidir se a OSC consegue cumprir
13. Principais riscos de inabilitação

Só depois de percorrer os 13 pontos o CaptaDoc monta as perguntas de validação ao proponente e emite o diagnóstico. Se algum ponto não puder ser respondido porque o edital não trouxe a informação, isso é registrado como lacuna do edital, não pulado.

## Efeito no handoff para o CaptaBuilder

O `elegibilidade.md` gerado com este checklist já cobre categorias, itens vedados e critérios de pontuação, além da parte documental. O CaptaBuilder deve reaproveitar essa leitura (não reinterpretar do zero se a OSC pode ou não participar); ele volta ao `edital.md` para o que é da sua função: objetivos, metodologia, critérios de nota e estrutura da proposta.
