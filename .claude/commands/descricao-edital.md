---
description: Gerar uma ficha descritiva avulsa de um edital, em .doc para download, sem vincular a nenhuma OSC. Cobre execução, prestação de contas e comunicação.
---

# /descricao-edital

Produz uma ficha descritiva completa de um edital específico, avulsa e sem vínculo com nenhuma OSC ativa, entregue como documento `.doc` pronto para baixar. Diferente do `/edital-analisar` (que alimenta os 4 agentes na pasta da OSC), este comando serve para consulta rápida e independente: por exemplo, quando o captador só quer entender as regras de um edital antes de decidir se vale a pena buscar uma OSC para ele, ou quando precisa checar rapidamente as regras de execução e prestação de contas.

## Passo 0. Sem contexto de OSC

Não leia `minhas-oscs/.ativa` nem nenhum `perfil-osc.md`. Este comando é intencionalmente desvinculado de qualquer organização.

## Passo 1. Obter o edital

Pergunte como o captador vai fornecer o edital:
1. Colar o texto.
2. Caminho de um PDF na máquina (leia o arquivo).
3. Link do edital (use a leitura de página; se indisponível, peça o texto ou o PDF).

## Passo 2. Anúncio

```
🔍 Próximo passo: montar a ficha descritiva do edital (12 pontos). Tempo estimado: 2 a 4 minutos.
```

## Passo 3. Extração

Consulte `.claude/skills/editais-fundamentos/SKILL.md`. Extraia e organize, sempre ancorado no texto do edital (marque "verificar no edital" quando algo for ambíguo):

1. **Identificação.** Órgão, número do edital, objeto, modalidade, categorias.
2. **Quem pode participar.** Natureza jurídica ou pessoal aceita, tempo de existência, território, área temática, quem está impedido.
3. **Documentos exigidos** para inscrição e para habilitação.
4. **Valores.** Teto total, teto por item ou categoria, percentuais, contrapartida exigida, tributos.
5. **Despesas permitidas e vedadas.**
6. **Critérios de pontuação** e seus pesos. O que mais pontua e o que derruba. Critérios de desempate.
7. **Prazos.** Submissão, resultado, recurso, habilitação, pagamento, execução, prestação de contas.
8. **Forma de submissão.** Plataforma, cadastros complementares exigidos, formato dos anexos.
9. **Execução e contratação.** O que pode e não pode ser pago com o recurso, limites de remanejamento, regras de readequação.
10. **Prestação de contas.** O que precisa ser apresentado, prazo, canal oficial, tempo de guarda dos documentos.
11. **Comunicação e divulgação.** Exigências de menção ao apoio recebido, uso de logomarca, prazos de aprovação de material, penalidade por descumprimento.
12. **Pontos de atenção e detalhes críticos.** Releia o edital procurando especificamente por regras que não saltam aos olhos numa leitura corrida, mas que custam pontos, desclassificam ou inabilitam. Procure em particular por:
    - Exigências de **comprovante de residência/domicílio/sede**: quantos documentos, janela de validade de cada um, de quem deve estar em nome, e se o município do comprovante prevalece sobre o que foi apenas declarado (risco de perda de pontos ou desclassificação por divergência).
    - Critérios de pontuação que funcionam ao **contrário do intuitivo** (ex: quanto menor o IDHM ou a população, mais pontos).
    - Valores que precisam **fechar exatamente** (sem margem de arredondamento) em vez de "até o teto".
    - Limites de **quantidade de propostas simultâneas ou por ano** por proponente.
    - Itens cuja **ausência sozinha já desclassifica** (ex: contrapartida não indicada quando obrigatória).
    - Regras sobre **onde o recurso pode circular** (conta exclusiva, vedação de mistura de fontes).
    - Quando a inscrição é por **MEI, empresário individual ou CNPJ de fachada**, se os requisitos pessoais (idade, tempo de atuação, gênero, domicílio) recaem sobre o titular pessoa física ou sobre a empresa.
    - Situações cadastrais externas (SIAFI, Cadin, CAFIMP e similares) que travam a habilitação mesmo com documentação pessoal em ordem.
    Se não encontrar nenhum item desse tipo, registre isso explicitamente ("nenhum ponto de atenção adicional identificado além dos já cobertos nas seções 1 a 11") em vez de omitir a seção.

## Passo 4. Geração do documento

1. Monte o conteúdo em markdown com as 12 seções acima.
2. Converta para `.doc` reaproveitando as funções `md_para_html` e `doc_word` de `scripts/exportar-projeto.py` (importe o módulo via `importlib`, não copie o código).
3. Garanta que a pasta `Descrição Editais/` exista na raiz do projeto (crie se não existir).
4. Salve o arquivo em `Descrição Editais/{edital-slug}.doc`.

## Passo 5. Entrega

Informe o caminho absoluto do arquivo salvo. Não sugira `/projeto-elegibilidade` nem qualquer fluxo de OSC, a menos que o captador peça.

## Regras

- Não invente exigência que não esteja no edital.
- Português correto, sem travessão.
- Nunca leia nem grave nada dentro de `minhas-oscs/`.