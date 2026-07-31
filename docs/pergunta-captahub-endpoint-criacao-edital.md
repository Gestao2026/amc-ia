# Pergunta para o CaptaHub. Endpoint de criação de edital

> ⚠️ **Pergunta ficou sem necessidade em 30/07/2026 (SOL-0006, `.claude/rules/decisoes-tecnicas.md`).** Um teste real mostrou que a resposta certa não depende do CaptaHub abrir um endpoint de criação de edital: a base de editais é mesmo administrada só por eles, por desenho, e o fluxo correto é abrir um **Controle** no pipeline (`controle-criar`, já implementado). Não é mais necessário enviar esta pergunta. Mantida aqui como registro histórico; se quiser enviar mesmo assim (por exemplo, para perguntar sobre o campo `edital` do Controle não ser persistido), o texto abaixo ainda é tecnicamente correto sobre o que foi observado.

---

Gostaria de integrar o AMC-IA ao CaptaHub para inserir automaticamente editais identificados pela minha equipe. Atualmente verifiquei que a API permite autenticação e consulta de editais, porém não encontrei nenhuma operação de escrita e o POST /v1/editais retorna 404. Essa funcionalidade existe para parceiros ou administradores? Caso não exista, existe algum fluxo oficial de importação ou integração para inclusão de novos editais na base do CaptaHub?

---

## Depois de enviar

Quando a resposta chegar, atualizar:
- `docs/especificacao-endpoint-criacao-edital.md`, com o que foi confirmado (endpoint real, escopo necessário, ou fluxo de importação oficial).
- `.claude/rules/decisoes-tecnicas.md`, SOL-0003, fechando a pendência.
