# Modelo de configuracao da sincronizacao da pasta _82.
#
# COMO USAR: copie este arquivo para "config.local.ps1" (na mesma pasta) e
# preencha com os caminhos reais da maquina. O config.local.ps1 esta no
# .gitignore e NUNCA vai para o GitHub, porque o repositorio e publico e
# esses valores identificam pastas pessoais e do Google Drive.

# Pasta mae, no computador. E a fonte da verdade: so ela altera o Drive.
$Desktop = "C:\Users\SEU_USUARIO\Desktop\NOME DA SUA PASTA"

# Pasta de destino dentro da unidade do Google Drive para computador.
# Para descobrir: abra a pasta no Explorador de Arquivos e copie o caminho da barra de enderecos.
$Drive = "G:\Meu Drive\NOME DA SUA PASTA"

# Onde ficam os registros de execucao e o arquivo de estado.
# Fica fora do repositorio de proposito: sao dados de execucao, nao codigo.
$DadosDir = "C:\Users\SEU_USUARIO\Scripts\sincronizar-pasta-82"

# Arquivo de alerta criado quando a sincronizacao para de acontecer.
$AlertaFile = "C:\Users\SEU_USUARIO\Desktop\ALERTA - SINCRONIZACAO PASTA 82.txt"

# Horas sem sincronizar ate o vigia considerar que ha problema.
$LimiteHoras = 24
