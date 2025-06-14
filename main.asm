###################################################################
#   Projeto de Gerenciamento de Apartamentos em Assembly MIPS
#   Discentes:
#               Guilherme Oliveira Aroucha
#               Kleber Barbosa de Fraga
#               Pedro Henrique Apolinario da Silva
#
####################################################################

# ================================== CONSTANTES DA ESTRUTURA DE DADOS ================================== #
#   Será usado .eqv, para deixar o código mais fácil de ser lido.
.eqv TAMANHO_AP_BLOCO 256 # Espaço reservado para um único apartamento
.eqv TAMANHO_NOME_MORADOR 32 # Espaço reservado para o nome de um morador.

# --- Deslocamento de Memória para separar os bytes de um apartamento --- #

.eqv OFFSET_MORADOR1 0  # -------------------
.eqv OFFSET_MORADOR2 32 # Cada morador possui 32 bytes de nome
.eqv OFFSET_MORADOR3 64 # Então será reservados 128 bys para ser dividido
.eqv OFFSET_MORADOR4 96 # Entre os 5 moradores, dentro os 256 bytes de cada AP
.eqv OFFSET_MORADOR5 128 # -------------------
.eqv OFFSET_VEICULO1 160 # Cada veiculo terá 40 bytes, onde estarão armazenados o tipo, cor, modelo
.eqv OFFSET_VEICULO2 200 # --------------
.eqv OFFSET_STATUS_AP 240 # Somente um byte, será usado para representar se o AP esta vazio ou cheio
.eqv OFFSET_NUM_MORADORES 241 # Representa a quantidade de moradores.


.eqv OFFSET_VEICULO1_TIPO 160 # 1 byte para o tipo, sera C ou M
.eqv OFFSET_VEICULO1_MODELO 161 # 20 bytes para o modelo do veiculo
.eqv OFFSET_VEICULO1_COR 181 # 19 bytes para a cor do veiculo

.eqv OFFSET_VEICULO2_TIPO 200  # 1 byte para o tipo, sera C ou M
.eqv OFFSET_VEICULO2_MODELO 201  # 20 bytes para o modelo do veiculo
.eqv OFFSET_VEICULO2_COR 221 # 19 bytes para a cor do veiculo
# ----- Macros ------ #
.macro PRINT_STRING (%str)
    li $v0, 4          # Código de serviço para imprimir string
    la $a0, %str       # Carrega o endereço da string
    syscall             # Chama o sistema
.end_macro

.macro PRINT_INT (%valor)
    li $v0, 1          # Código de serviço para imprimir inteiro
    move $a0, %valor   # Move o valor para $a0
    syscall             # Chama o sistema
.end_macro
.macro COMPARAR_CMD  (%str_addr, %len, %handler)
    la $a0, input_buffer      # Carrega o buffer de entrada
    la $a1, %str_addr         # Carrega o endereço da string de comando
    li $a2, %len              # Tamanho máximo de caracteres a comparar
    jal strncmp               # Chama a função de comparação de strings
    beq $v0, $zero, %handler  # Se igual, salta para o handler
.end_macro

.data
banner: .asciiz "KGP-shell>> "
apartamentos: .space 10240 # quantidade de apartamentos * 256 bytes

ap_string: .space 10 #
nome_string: .space 50 #

# -------------- Mensagens de Erro --------------- #
msg_ap_invalido:.asciiz                 "Falha: AP invalido\n"
msg_ap_cheio:.asciiz                    "Falha: AP com numero max de moradores\n"
msg_comando_malformado:.asciiz          "Falha: Comando mal formado.\n"
msg_sucesso_ad_morador:.asciiz          "Morador adicionado com sucesso!\n"
msg_morador_nao_encontrado: .asciiz     "Falha: morador nao encontrado\n"
msg_tipo_automovel_invalido: .asciiz    "Falha: tipo invalido\n"
msg_automovel_nao_encontrado: .asciiz   "Falha: automóvel nao encontrado\n"
msg_apartamento_limpo: .asciiz          "Apartamento vazio\n"
msg_principal: .asciiz                  "Bem-vindo ao sistema de gerenciamento de apartamentos!\n"


# -------------- Strings para comparação no menu --------------- #
str_ad_morador:     "ad_morador"
str_rm_morador:     "rm_morador"
str_ad_auto:        "ad_auto"
str_rm_auto:        "rm_auto"
str_info_ap:        "info_ap"
str_info_geral:     "info_geral"
str_limpar_ap:      "limpar_ap"
str_salvar:         "salvar"
str_recarregar:     "recarregar"
str_formatar:       "formatar"
str_sair:           "sair"
str_ajuda:          "ajuda"

# -------------- Tamanho máximo de caracteres para comparação --------------- #
input_buffer: .space 128
nome_buffer: .space 50
ap_buffer: .space 10

# -------------- Mensagens de Teste --------------- #
msg_funcao_adicionar: .asciiz "Função adicionar chamada com sucesso!\n"
msg_funcao_remover: .asciiz "Função remover chamada com sucesso!\n"
msg_funcao_info_ap: .asciiz "Função info_ap chamada com sucesso!\n"
msg_funcao_info_geral: .asciiz "Função info_geral chamada com sucesso!\n"
msg_funcao_limpar_ap: .asciiz "Função limpar_ap chamada com sucesso!\n"
msg_funcao_salvar: .asciiz "Função salvar chamada com sucesso!\n"
msg_funcao_recarregar: .asciiz "Função recarregar chamada com sucesso!\n"
msg_funcao_formatar: .asciiz "Função formatar chamada com sucesso!\n"
msg_funcao_sair: .asciiz "Função sair chamada com sucesso!\n"
msg_lista_funcoes: .asciiz "Comandos disponíveis:\nad_morador - Adicionar morador\n rm_morador - Remover morador\n ad_auto - Adicionar automóvel\n rm_auto - Remover automóvel\ninfo_ap - Informações do apartamento\ninfo_geral - Informações gerais\nlimpar_ap - Limpar apartamento\nsalvar - Salvar dados\nrecarregar - Recarregar dados\nformatar - Formatar sistema\nsair - Sair do sistema\n"
msg_limpa_terminal: .asciiz "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" # Sequência de escape para limpar o terminal


.text
# -------------- Função Principal -------------- #
main:
    #inicia o loop principal
    PRINT_STRING msg_principal
    PRINT_STRING msg_lista_funcoes
loop_inteface:
    PRINT_STRING msg_limpa_terminal # Limpa o terminal
    PRINT_STRING banner #Imprime o banner
    # Listar funções

    # Leitura do comando do usuário
    la $a0, input_buffer  # Carrega o endereço do buffer
    li $a1, 128           # Tamanho máximo do buffer
    li $v0, 8            # Código de serviço para ler string
    syscall

    # Remove o caractere de nova linha ('\n') do final da string lida
    la $t0, input_buffer
    remove_newline:
        lb $t1, 0($t0)
        beq $t1, $zero, end_remove_newline
        li $t2, 10           # ASCII de '\n'
        beq $t1, $t2, set_zero
        addi $t0, $t0, 1
        j remove_newline

    set_zero:
        sb $zero, 0($t0)     # Substitui '\n' por '\0'

    end_remove_newline:

    # Inicia a cadeia de comparações para identificar o comando.
    #    A ordem é:
    #       Preparar argumentos para strncmp ($a0=input, $a1=cmd, $a3=tamanho)
    #       Chamar strncmp
    #       Se for igual (v0=0), salta para o handler. Senão, vai para a próxima verificação.
    COMPARAR_CMD str_ad_morador, 10, adicionar_morador
    COMPARAR_CMD str_rm_morador, 10, remover_morador
    COMPARAR_CMD str_ad_auto,    7,  adicionar_automovel
    COMPARAR_CMD str_rm_auto,    7,  remover_automovel
    COMPARAR_CMD str_info_ap,    7,  info_ap
    COMPARAR_CMD str_limpar_ap,  9,  limpar_ap

    # Para comandos sem argumentos, usamos String Compare diretamente, já que recebe menos argumentos
    #Info geral
    la $a0, input_buffer
    la $a1, str_info_geral
    jal strcmp
    beq $v0, $zero, info_geral

    # Salvar
    la $a0, input_buffer
    la $a1, str_salvar
    jal strcmp
    beq $v0, $zero, salvar
    
    # Recarregar
    la $a0, input_buffer
    la $a1, str_recarregar
    jal strcmp
    beq $v0, $zero, recarregar
    
    # formatar
    la $a0, input_buffer
    la $a1, str_formatar
    jal strcmp
    beq $v0, $zero, formatar

    # ajuda
    la $a0, input_buffer
    la $a1, str_ajuda
    jal strcmp
    beq $v0, $zero, ajuda

    # sair
    la $a0, input_buffer
    la $a1, str_sair
    jal strcmp
    beq $v0, $zero, sair
    # Se nenhum comando foi reconhecido, imprime mensagem de erro
    PRINT_STRING msg_comando_malformado
    j loop_inteface  # Volta para o início do loop

ajuda:
    PRINT_STRING msg_lista_funcoes  # Imprime a lista de comandos disponíveis
    j loop_inteface  # Volta para o início do loop


adicionar_morador:
    PRINT_STRING msg_limpa_terminal
    # Boa prática: Salvar os registradores que serão usados na pilha
    addi $sp, $sp, -28
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)   # $s0: ponteiro para o endereço base do AP alvo
    sw   $s1, 8($sp)   # $s1: ponteiro para o início da string do AP
    sw   $s2, 12($sp)  # $s2: ponteiro para o início da string do Nome
    sw   $s3, 16($sp)  # $s3: índice do AP (0-39)
    sw   $s4, 20($sp)  # $s4: número do AP como inteiro
    sw   $s5, 24($sp)  # $s5: usado para o contador de loop

    move $s0, $a0  # Ponteiro do inicio da string de entrada

    # Guardar o numero do apartamento em $s4 e converter a string para inteiro
    # Aqui, $s0 já aponta para o início da string do AP
    # vamos então, encontrar o primeiro hifen, salvar o que vem depois dele
    # e então salvar o que vem depois do segundo hifen

    move $a0, $s0  # Passa o endereço da string do AP para $a0 
    li $a1, '-'  # Caractere a ser encontrado
    jal encontrar_caracter  # Chama a função para encontrar o primeiro '-' 
    beq $v0, $zero, comando_invalido  # Se não encontrou, o comando deve ser inválido
    addi $s1, $v0, 1  # Avança para o próximo caractere após o '-'

    # Agora, encontrar o segundo '-'
    move $a0, $s1  # Passa o endereço da string do AP para $a0
    li $a1, '-'  # Caractere a ser encontrado
    jal encontrar_caracter  # Chama a função para encontrar o segundo '-'
    beq $v0, $zero, comando_invalido  # Se não encontrou, o comando deve ser inválido
    move $s2, $v0  # Salva o endereço do segundo '-' em $s2

    # agora, vamos extrair o numero do apartamento e o nome do morador
    # primeiro, o numero do apartamento
    sb $zero, 0($s2)  # Substitui o segundo '-' por '\0' para terminar a string do AP
    la $a0, input_buffer  # Carrega o endereço do buffer de entrada
    move $a1, $s1
    jal strcpy  # Copia a string do AP para o buffer de entrada
    li $t0, '-'
    sb $t0, 0($s2)  # Restaura o segundo '-' na string original

    # segundo, o nome do morador
    la $a0, nome_buffer  # Carrega o endereço do buffer de nome
    addi $a1, $s2, 1  # Avança o ponteiro para o início do nome
    jal strcpy  # Copia o nome do morador para o buffer de nome


    # agora, validar todos os dados
    # verificar se o número do apartamento é válido
    la $a0, input_buffer  # Carrega o endereço do buffer de entrada
    jal string_to_int  # Converte a string do AP para inteiro
    move $s4, $v0  # Salva o número do apartamento convertido em $s4

    move $a0, $s4  # Passa o número do apartamento para $a0
    jal ap_valido  # Verifica se o número do apartamento é válido
    
    move $a0, $s4  # Passa o número do apartamento para $a0
    jal calcular_indice_ap  # Calcula o índice do apartamento
    move $s3, $v0  # Salva o índice do apartamento em $s3

    # Após a verificação da validade do ap, vamos a regra de negocio
    # Não se pode adicionar morador se o apartamento já tiver 5 moradores
    
    li $t0, TAMANHO_AP_BLOCO  # Tamanho de cada bloco de apartamento
    mul $t1, $s3, $t0 # Calcula o deslocamento do apartamento na memoria
    la $t2, apartamentos  # Carrega o endereço base dos apartamentos
    add $s0, $t2, $t1  # Calcula o endereço base do apartamento

    # verificar o limite de moradores
    lb $t5, OFFSET_NUM_MORADORES($s0)  # Carrega o endereço do número de moradores
    li $t6, 5 # numero maximo de moradores
    # bge = branch if greater or equal, se o número de moradores for maior ou igual a 5, pula para msg_ap_cheio
    bge $t5, $t6, msg_ap_cheio  # Se o número de moradores for maior ou igual a 5, pula para msg_ap_cheio

    # se o numero de moradores for menor que 5, podemos adicionar ele
    # mas antes, vamos ter que caminhar pelo apartamento
    # para encontrar o primeiro espaço vazio

    li $s5, 0  # Inicializa o contador de moradores

    encontrar_lugar:
    beq $s5, 5, ap_cheio
    
    # Calcula o endereço do morador atual
    li $t0, TAMANHO_NOME_MORADOR  # Tamanho de cada nome de morador
    mul $t1, $s5, $t0  # Calcula o deslocamento do morador
    add $a0, $s0, $t1  # Calcula o endereço do morador atual, $a0 = apartamentos + (índice * tamanho do morador)

    lb $t2, 0($a0)  # Lê o status do morador atual
    bne $t2, $0, incrementa_i  # Se o morador não estiver vazio, incrementa o contador
    
    # se não foi pro incrementa_i, então está vazio e pode adicionar
    la $a1, buffer_nome  # Carrega o endereço do buffer de nome
    jal strcpy  # Copia o nome do morador para o buffer de nome

    # incrementar a contagem de moradores do ap
    addi $t5, $t5, 1
    sb $t5, OFFSET_NUM_MORADORES($s0)  # Atualiza o número de moradores no apartamento

    li $t6, 1
    sb $t6, OFFSET_STATUS_AP($s0)  # Marca o apartamento como cheio
    PRINT_STRING msg_sucesso_ad_morador  # Imprime mensagem de sucesso
    j fim_adicionar_morador  # Salta para o fim da função
    
    incrementa_i:
    addi $s5, $s5, 1  # Incrementa o contador de moradores
    j encontrar_lugar

    fim_adicionar_morador:
    # restaura os registradores da pilha
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    lw   $s3, 16($sp)
    lw   $s4, 20($sp)
    lw   $s5, 24($sp)
    addi $sp, $sp, 28 # Libera o espaço da pilha
    j loop_inteface  # Volta para o início do loop

remover_morador:
    PRINT_STRING msg_limpa_terminal
    # Boa prática: Salvar os registradores que serão usados na pilha
    addi $sp, $sp, -28
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)   # $s0: ponteiro para o endereço base do AP alvo
    sw   $s1, 8($sp)   # $s1: ponteiro para a string do nome a procurar
    sw   $s2, 12($sp)  # $s2: ponteiro temporário para parsing
    sw   $s3, 16($sp)  # $s3: índice do AP (0-39)
    sw   $s4, 20($sp)  # $s4: número do AP como inteiro
    sw   $s5, 24($sp)  # $s5: usado para o contador de loop
    
    move $s0, $a0  # Ponteiro do início da string de entrada
    
    # PRIMEIRA ETAPA - Validar o comando, ap e indice
    li $a1, '-'  # Caractere a ser encontrado
    jal encontrar_caracter  # Chama a função para encontrar o primeiro '-' 
    beq $v0, $zero, comando_invalido  # Se não encontrou, o comando deve ser inválido
    addi $s1, $v0, 1  # Avança para o próximo caractere após o '-'

    # Agora, encontrar o segundo '-'
    move $a0, $s1  # Passa o endereço da string do AP para $a0
    li $a1, '-'  # Caractere a ser encontrado
    jal encontrar_caracter  # Chama a função para encontrar o segundo '-'
    beq $v0, $zero, comando_invalido  # Se não encontrou, o comando deve ser inválido
    move $s2, $v0  # Salva o endereço do segundo '-' em $s2

    # agora, vamos extrair o numero do apartamento e o nome do morador
    # primeiro, o numero do apartamento
    sb $zero, 0($s2)  # Substitui o segundo '-' por '\0' para terminar a string do AP
    la $a0, input_buffer  # Carrega o endereço do buffer de entrada
    move $a1, $s1
    jal strcpy  # Copia a string do AP para o buffer de entrada
    li $t0, '-'
    sb $t0, 0($s2)  # Restaura o segundo '-' na string original

    # segundo, o nome do morador
    la $a0, nome_buffer  # Carrega o endereço do buffer de nome
    addi $a1, $s2, 1  # Avança o ponteiro para o início do nome
    jal strcpy  # Copia o nome do morador para o buffer de nome


    # agora, validar todos os dados
    # verificar se o número do apartamento é válido
    la $a0, input_buffer  # Carrega o endereço do buffer de entrada
    jal string_to_int  # Converte a string do AP para inteiro
    move $s4, $v0  # Salva o número do apartamento convertido em $s4

    move $a0, $s4  # Passa o número do apartamento para $a0
    jal ap_valido  # Verifica se o número do apartamento é válido
    
    move $a0, $s4  # Passa o número do apartamento para $a0
    jal encontrar_indice_ap  # Calcula o índice do apartamento
    move $s3, $v0  # Salva o índice do apartamento em $s3
    
    # SEGUNDA ETAPA - Regras de Negócio
    li $t0, TAMANHO_AP_BLOCO  # Tamanho de cada bloco de apartamento
    mul $t1, $s3, $t0 # Calcula o deslocamento do apartamento na memória
    la $t2, apartamentos  # Carrega o endereço base dos apartamentos
    add $s0, $t2, $t1  # Calcula o endereço base do apartamento

    # Verificar se o apartamento está vazio
    lb $t5, OFFSET_NUM_MORADORES($s0)  # Carrega o status do apartamento
    beq $t5, $zero, ap_vazio  # Se o status for zero, o apartamento está vazio
    
    # TERCEIRA ETAPA - Procurar o morador
    li $s5, 0  # Inicializa o contador de moradores
    loop_morador:
    beq $s5, 5, morador_nao_encontrado  # Se o contador de moradores for 5, não encontrou o morador

    # Calcula o endereço do morador atual
    li $t0, TAMANHO_NOME_MORADOR  # Tamanho de cada nome de morador
    mul $t1, $s5, $t0  # Calcula o deslocamento do morador
    add $a0, $s0, $t1  # Calcula o endereço do morador atual, $a0 = apartamentos + (índice * tamanho do morador)

    la $a1, nome_buffer  # Passa o endereço do nome do morador a ser removido
    jal strcmp  # Compara o nome do morador atual com o nome a ser removido

    beq $v0, $zero, morador_encontrado  # Se o nome for igual, salta para morador_encontrado

    addi $s5, $s5, 1  # Incrementa o contador de moradores
    j loop_morador  # Volta para o início do loop

   
morador_encontrado:
  # QUARTA ETAPA: Se chegou aqui, o morador foi encontrrado e deve ser removido
  sb $0, 0($a0)  # Marca o morador como vazio (substitui o nome por '\0')

  # Decrementa o número de moradores do apartamento
  lb  $t5, OFFSET_NUM_MORADORES($s0)  # Carrega o número de moradores
  addi $t5, $t5, -1  # Decrementa o número de moradores
  sb $t5, OFFSET_NUM_MORADORES($s0)  # Atualiza o número de moradores no apartamento

 # Verifica se o apartamento ficou vazio 
 bne $t5, $0, sucesso_remocao
 
 # se o contador de moradores for zero, o apartamento deve ser marcado como vazio
 sb $0, OFFSET_STATUS_AP($s0)  # Marca o apartamento como vazio

 # deve ser removido todos os veiculos do apartamento
li $t0, OFFSET_VEICULO1
add $a0, $s0, $t0
jal limpar_veiculos  # Limpa os veículos do apartamento

li $t0, OFFSET_VEICULO2
add $a0, $s0, $t0
jal limpar_veiculos  # Limpa os veículos do apartamento


 sucesso_remocao:
 PRINT_STRING msg_funcao_remover # mensagem de sucesso
 j fim_remover_morador
 
 # recuperar os registradores da pilha
 fim_remover_morador:
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    lw   $s3, 16($sp)
    lw   $s4, 20($sp)
    lw   $s5, 24($sp)
    addi $sp, $sp, 28
    j loop_inteface  # Volta para o início do loop

limpar_veiculos:
    # loop que pecorre 40 bytes marcando 0
    li $t1, 40

    loop_limpar_veiculos:
    beq $t1, $zero, fim_limpar_veiculos  # Se $t1 for zero, sai do loop
    sb $zero, 0($a0)  # Marca o veículo como vazio
    addi $a0, $a0, 1  # Avança para o próximo byte
    addi $t1, $t1, -1  # Decrementa o contador
    j loop_limpar_veiculos  # Volta para o início do loop
fim_limpar_veiculos:
    jr $ra  # Retorna da função
   
adicionar_automovel:
    # Salva registradores na pilha
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)   # endereço base do AP
    sw $s1, 8($sp)   # número do AP
    sw $s2, 12($sp)  # ponteiro para dados do automóvel
    sw $s3, 16($sp)  # contador/auxiliar
    sw $s4, 20($sp)  # offset do automóvel
    
    la $t0, input_buffer    # Carrega o endereço do buffer de entrada
    li $t1, 8
    add $s1, $t0, $t1       # Avança o ponteiro para o início do comando

    # 2. Encontrar o próximo '-' (fim do número do AP)
    move $a0, $s1           # Passa o endereço da string do AP para $a0
    li $a1, '-'             # Caractere a ser encontrado
    jal encontrar_caracter  # Chama a função para encontrar o próximo '-'
    beq $v0, $zero, comando_invalido  # Se não encontrou, o comando deve ser inválido
    move $s2, $v0           # Salva o endereço do próximo '-' em $s2

    # 3. Substituir '-' por '\0' para isolar o número do AP
    sb $zero, 0($s2)  # Substitui o '-' por '\0' para isolar o número do AP

    # 4. Converter número do AP (string) para inteiro
    move $a0, $s1       # Passa o endereço da string do AP para $a0
    jal string_to_int   # Chama a função para converter a string do AP para inteiro
    move $s5, $v0       # Salva o número do AP convertido em $s5

    # 5. $s2 = início do tipo (logo após o '-')
    addi $s2, $s2, 1  # Avança o ponteiro para o início do tipo do automóvel
    
    # 6. Encontrar próximo '-' (fim do tipo)
    move $a0, $s2       # Passa o endereço do tipo do automóvel para $a0
    li $a1, '-'         # Caractere a ser encontrado
    jal encontrar_caracter  # Chama a função para encontrar o próximo '-'
    beq $v0, $zero, comando_invalido  # Se não encontrou, o comando deve ser inválido
    move $t3, $v0       # Salva o endereço do próximo '-' em $t3
    sb $zero, 0($t3)    # Substitui o '-' por '\0' para isolar o tipo do automóvel
    addi $t3, $t3, 1    # Avança o ponteiro para o início da cor do automóvel
    
    # 7. Encontrar próximo '-' (fim do modelo)
    move $a0, $t3           # Passa o endereço da cor do automóvel para $a0
    li $a1, '-'             # Caractere a ser encontrado
    jal encontrar_caracter  # Chama a função para encontrar o próximo '-'
    beq $v0, $zero, comando_invalido  # Se não encontrou, o comando deve ser inválido
    move $t4, $v0           # Salva o endereço do próximo '-' em $t4

    sb $zero, 0($t4)  # Substitui o '-' por '\0' para isolar o modelo do automóvel
    addi $t4, $t4, 1  # Avança o ponteiro para o início do modelo do automóvel
    
    # 8. Calcular endereço base do AP
    la $t5, apartamentos        # Carrega o endereço base dos apartamentos
    li $t6, TAMANHO_AP_BLOCO    # Tamanho de cada bloco de apartamento
    mul $t7, $s5, $t6           # Calcula o deslocamento do apartamento
    add $s0, $t5, $t7           # Calcula o endereço base do apartamento

    # 9. Verificar vaga para automóvel
    addi $t8, $s0, OFFSET_VEICULO1      # Endereço do primeiro veículo no apartamento
    lb $t9, 0($t8)                      # Lê o status do primeiro veículo
    beqz $t9, slot1_vazio  # Se o primeiro veículo estiver vazio, pula para slot1_vazio

    addi $t8, $s0, OFFSET_VEICULO2      # Endereço do segundo veículo no apartamento
    lb $t9, 0($t8)                      # Lê o status do segundo veículo
    beqz $t9, slot2_vazio  # Se o segundo veículo estiver vazio, pula para slot2_vazio

    PRINT_STRING msg_ap_cheio   # Imprime mensagem de apartamento cheio
    j fim_adicionar_auto        # Salta para o fim da função
    
    slot1_vazio:
        addi $t8, $s0, OFFSET_VEICULO1  # Endereço do primeiro veículo no apartamento
        j salvar_auto
    
    slot2_vazio:
        addi $t8, $s0, OFFSET_VEICULO2  # Endereço do segundo veículo no apartamento
    
    salvar_auto:
        # copia tipo (até 12 bytes)
        move $a0, $s2  # Passa o endereço do tipo do automóvel para $a0
        li
        
    
    j loop_inteface  # Volta para o início do loop
remover_automovel:
    # Salva registradores na pilha
    addi $sp, $sp, -32
    sw $ra, 0($sp)
    sw $s0, 4($sp)   # endereço base do AP
    sw $s1, 8($sp)   # número do AP
    sw $s2, 12($sp)  # tipo do automóvel
    sw $s3, 16($sp)  # modelo
    sw $s4, 20($sp)  # cor
    sw $s5, 24($sp)  # contador/auxiliar
    sw $s6, 28($sp)  # offset do automóvel

   # --- ETAPA 1: PARSING ROBUSTO DA STRING DE ENTRADA ---
    # Esta é a correção mais importante. O parsing é feito passo a passo.
    # $s0: ponteiro que avança na string de entrada.
    move $s0, $a0

    # 1.1: Saltar o nome do comando "rm_auto"
    li   $t0, 8 # Comprimento de "rm_auto-"
    add  $s0, $s0, $t0

    # 1.2: Extrair AP
    move $a0, $s0
    li   $a1, '-'
    jal  find_char
    beq  $v0, $zero, comando_malformado_handler
    move $s1, $v0       # $s1 aponta para o hífen depois do AP
    sb   $zero, 0($s1)   # Coloca um nulo temporário
    la   $a0, buffer_ap_string
    move $a1, $s0
    jal  strcpy
    li   $t0, '-'
    sb   $t0, 0($s1)     # Restaura o hífen

    # 1.3: Extrair TIPO
    addi $s0, $s1, 1    # Avança para depois do hífen do AP
    move $a0, $s0
    jal  find_char
    beq  $v0, $zero, comando_malformado_handler
    move $s1, $v0       # $s1 aponta para o hífen depois do TIPO
    sb   $zero, 0($s1)
    la   $a0, buffer_tipo_string
    move $a1, $s0
    jal  strcpy
    li   $t0, '-'
    sb   $t0, 0($s1)

    # 1.4: Extrair MODELO
    addi $s0, $s1, 1
    move $a0, $s0
    jal  find_char
    beq  $v0, $zero, comando_malformado_handler
    move $s1, $v0       # $s1 aponta para o hífen depois do MODELO
    sb   $zero, 0($s1)
    la   $a0, buffer_modelo_string
    move $a1, $s0
    jal  strcpy
    li   $t0, '-'
    sb   $t0, 0($s1)

    # 1.5: Extrair COR (é o resto da string)
    addi $s0, $s1, 1
    la   $a0, buffer_cor_string
    move $a1, $s0
    jal  strcpy

    # --- ETAPA 2: VALIDAÇÃO DOS DADOS DE ENTRADA ---
    # 2.1: Validar AP
    la   $a0, buffer_ap_string
    jal  string_to_int
    move $s1, $v0
    move $a0, $s1
    jal  eh_ap_valido
    beq  $v0, $zero, ap_invalido_handler

    # 2.2: Validar TIPO
    la   $t0, buffer_tipo_string
    lb   $s2, 0($t0) # Carrega o caractere do tipo ('c' ou 'm')
    li   $t1, 'c'
    li   $t2, 'm'
    beq  $s2, $t1, tipo_ok
    beq  $s2, $t2, tipo_ok
    j    tipo_invalido_handler
tipo_ok:

    # --- ETAPA 3: PROCURAR O AUTOMÓVEL ---
    # 3.1: Calcular endereço base do AP
    move $a0, $s1
    jal  calcular_indice
    li   $t0, TAMANHO_AP_BLOCO
    mul  $t1, $v0, $t0
    la   $t2, apartamentos
    add  $s0, $t2, $t1 # $s0 = endereço base do AP

    # 3.2: Verificar Slot 1
    addi  $s3, $s0, OFFSET_VEICULO1 # $s3 = endereço do slot 1
    jal  verificar_slot_veiculo
    bne  $v0, $zero, veiculo_encontrado_handler # Se v0=1, encontrou!

    # 3.3: Se não encontrou no slot 1, verificar Slot 2
    addi  $s3, $s0, OFFSET_VEICULO2 # $s3 = endereço do slot 2
    jal  verificar_slot_veiculo
    bne  $v0, $zero, veiculo_encontrado_handler

    # 3.4: Se não encontrou em nenhum slot, falha.
    j    auto_nao_encontrado_handler

veiculo_encontrado_handler:
    # --- ETAPA 4: REMOÇÃO ---
    # O endereço do slot a ser removido está em $s3.
    # "Remover" significa zerar todo o bloco de 40 bytes.
    move $a0, $s3
    jal  limpar_bloco_veiculo
    la   $a0, msg_sucesso
    li   $v0, 4
    syscall
    j    fim_rm_auto

# --- SUB-ROTINA: verificar_slot_veiculo ---
# Verifica se o veículo num determinado slot corresponde ao procurado.
# $a0: endereço do slot do veículo.
# Retorna: $v0 = 1 se corresponde, $v0 = 0 caso contrário.
verificar_slot_veiculo:
    # Compara o TIPO
    lb   $t0, OFFSET_VEICULO_TIPO($a0)
    bne  $t0, $s2, nao_corresponde # $s2 tem o tipo procurado

    # Compara o MODELO
    addi  $a1, $a0, OFFSET_VEICULO_MODELO
    la   $a0, buffer_modelo_string
    # Troca $a0 e $a1 para a chamada de strcmp
    move $t5, $a0; move $a0, $a1
    move $a1, $t5
    jal  strcmp
    bne  $v0, $zero, nao_corresponde

    # Compara a COR
    addi  $a1, $a0, OFFSET_VEICULO_COR
    la   $a0, buffer_cor_string
    move $t5, $a0
    move $a0, $a1
    move $a1, $t5
    jal  strcmp
    bne  $v0, $zero, nao_corresponde

    # Se tudo correspondeu:
    li   $v0, 1
    jr   $ra
nao_corresponde:
    li   $v0, 0
    jr   $ra

# --- SUB-ROTINA PARA LIMPAR MEMÓRIA ---
limpar_bloco_veiculo:
    li $t1, TAMANHO_VEICULO
limpar_loop:
    beq $t1, $zero, fim_limpar
    sb  $zero, 0($a0)
    addi $a0, $a0, 1
    addi $t1, $t1, -1
    j limpar_loop
fim_limpar:
    jr $ra

# --- HANDLERS DE ERRO ---
comando_malformado_handler: 
la $a0, msg_comando_malformado
li $v0, 4
syscall
j fim_rm_auto

ap_invalido_handler:
la $a0, msg_ap_invalido
li $v0, 4
syscall
j fim_rm_auto
tipo_invalido_handler:
la $a0, msg_tipo_invalido
li $v0, 4
syscall
j fim_rm_auto

auto_nao_encontrado_handler:
la $a0, msg_auto_nao_encontrado
li $v0, 4
syscall
j fim_rm_auto

# --- EPÍLOGO ---
fim_rm_auto:
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    lw   $s3, 16($sp)
    lw   $s4, 20($sp)
    lw   $s5, 24($sp)
    lw   $s6, 28($sp)
    addi $sp, $sp, 32
    j loop_inteface  # Volta para o início do loop

info_ap:
    PRINT_STRING str_info_ap
    j loop_inteface  # Volta para o início do loop
info_geral:
    PRINT_STRING str_info_geral
    j loop_inteface  # Volta para o início do loop
limpar_ap:
    PRINT_STRING str_limpar_ap
    j loop_inteface  # Volta para o início do loop
salvar:
    PRINT_STRING str_salvar
    j loop_inteface  # Volta para o início do loop
recarregar:
    PRINT_STRING str_recarregar
    j loop_inteface  # Volta para o início do loop
formatar:
    PRINT_STRING str_formatar
    j loop_inteface  # Volta para o início do loop
sair:  
    PRINT_STRING str_sair
    addi $v0, $zero, 10  # Código de serviço para sair
    syscall
ap_valido:
# registradores:

    # $t0: Número do apartamento (N)
    # $t1: Andar
    # $t2: Unidade
    # $t3: Número reconstruído
    # $t4: Temporário para constantes

    # primeiramente, veificar se o andar é válido
    # andar = N / 100, onde 1 <= andar <= 10
    li $t4, 100  # Constante para divisão
    div $t0, $t4  # Divide o número do apartamento por 100
    mflo $t1  # Move o quociente (andar) para $t1

    blt $t1, 1, ap_invalido # Se andar < 1, AP inválido
    bgt $t1, 10, ap_invalido # Se andar > 10, AP inválido
    
    # agora, verificar se a unidade é válida
    # para isso, vamos reconstruir o numero do apartamento
    # numero reconstrudido = andar * 100 + unidade
    li $t4, 100  # Constante para multiplicação
    mul $t3, $t1, $t4  # Multiplica o andar por 100
    add $t3, $t3, $t0  # Adiciona a unidade ao número reconstruído
    
    bne $t3, $t0, ap_invalido  # Se o número reconstruído não é igual ao original, AP inválido

    # se sobreviveu até aqui, o apartamento é valido
    li $v0, 1  # Retorna 1 (verdadeiro)
    jr $ra  # Retorna da função

ap_invalido:
    li $v0, 0  # Retorna 0 (falso)
    PRINT_STRING msg_ap_invalido  # Imprime mensagem de apartamento inválido
    jr $ra  # Retorna da função
ap_vazio:
    PRINT_STRING msg_ap_vazio  # Imprime mensagem de apartamento vazio
    j loop_inteface  # Volta para o início do loop

encontrar_indice_ap:
    # Registadores usados:
    # $t0: Número do apartamento (N)
    # $t1: Andar
    # $t2: Unidade
    # $t3: Parte do cálculo (andar - 1) * 4
    # $t4: Temporário para constantes

    move $t0, $a0  # Passa o número do apartamento para $t0
    
    # Extraindo qual o andar é
    li $t4, 100  # Constante para divisão
    div $t0, $t4  # Divide o número do apartamento por 100
    mflo $t1 # Move o quociente (andar) para $t1

    # Extraindo qual a unidade é
    li $t4, 10  # Constante para divisão
    div $t0, $t4  # Divide o número do apartamento por 10
    mfhi $t2  # Move o resto (unidade) para $t2

    #calcular o índice do apartamento
    # Índice = (andar - 1) * 4 + (unidade - 1)
    addi $t1, $t1, -1  # (andar - 1)
    li $t4, 4  # Constante para multiplicação
    mul $t3, $t1, $t4  # Multiplica (andar - 1) por 4
    addi $t2, $t2, -1  # (unidade - 1)
    add $v0, $t3, $t2  # Índice = (andar - 1) * 4 + (unidade - 1)
    jr $ra  # Retorna da função

ap_cheio:
    PRINT_STRING msg_ap_cheio  # Imprime mensagem de apartamento cheio
    j loop_inteface  # Volta para o início do loop

comando_invalido:
    PRINT_STRING msg_comando_malformado  # Imprime mensagem de comando mal formado
    j loop_inteface  # Volta para o início do loop
# -------------- Funções auxiliares -------------- #
strncmp:
        beq     $a3, $zero, finish_strncmp   # Se o número máximo de caracteres for 0, retorna 0

    loop_strncmp:
        lb      $t0, 0($a0)     # Carrega o byte atual da primeira string
        lb      $t1, 0($a1)     # Carrega o byte atual da segunda string

        bne     $t0, $t1, diferentes_strncmp   # Se os bytes forem diferentes, vai para "diferentes"
        beq     $t0, $zero, finish_strncmp  # Se encontrou o caractere nulo, as strings são iguais até aqui

        addi    $a3, $a3, -1    # Decrementa o contador de caracteres a comparar
        beq     $a3, $zero, finish_strncmp  # Se atingiu o número máximo de caracteres, termina a comparação

        addi    $a0, $a0, 1     # Incrementa o ponteiro da primeira string
        addi    $a1, $a1, 1     # Incrementa o ponteiro da segunda string

        j       loop_strncmp    # Continua o loop

    diferentes_strncmp:
        sub     $v0, $t0, $t1   # Calcula a diferença entre os valores ASCII dos caracteres diferentes
        jr      $ra             # Retorna para a função que chamou

    finish_strncmp:
        li      $v0, 0          # Retorna 0 (strings consideradas iguais até o número comparado de caracteres)
        jr      $ra

strcmp:
    loop_strcmp:
        lb   $t0, 0($a0)    # Carrega o byte atual da string 1
        lb   $t1, 0($a1)    # Carrega o byte atual da string 2

        bne  $t0, $t1, diferentes_strcmp  # Se os bytes forem diferentes, pula para 'diferentes'
        beq  $t0, $zero, finish_strcmp  # Se encontrou caractere nulo, as strings são iguais

        # Incrementa os ponteiros e continua a comparação
        addi $a0, $a0, 1
        addi $a1, $a1, 1
        j    loop_strcmp

    diferentes_strcmp:
        # Calcula a diferença dos valores ASCII
        sub  $v0, $t0, $t1
        jr   $ra            # Retorna para a função chamadora

    finish_strcmp:
        li   $v0, 0        # Retorna 0 se as strings são iguais
        jr   $ra

strcpy:
# como funciona a cópia de uma string:
# Nossa função recebe uma string de entrada em $a1
# Então, através de um loop, vamos iterando toda a string com uma váriavel
# Salvando o seu caracter naquele momento em outra váriavel
# E assim, incremetamos simultaneamente ambas as váriaveis
# O laço vai continuar se repetindo até a string acabar
# ao mesmo tempo que uma cópia da string é feita.

# Salvando do endereço de destino original em $vo, dado que $a0 será modificado
# durante a execução do loop.

# Definição do StringCopy para poder ser chamado pelo arquivo main.
# Salvando o denreço original de a0 em v0, visto que ele será modificado
# durante a execução do laço
move $v0, $a0

loop_principal:

# Carrega em t1 o byte atual de $a1 ( string origem )
# Armazena t1 em a0 ( string destino ).
lb $t1, 0($a1)
sb $t1, 0($a0)

# veficica se t1 é igual a 0, se for
# significa que chegamos ao fim da string
# então podemos encerrar o incremento das variaveis.
beq $t1, $0, fimDoLoop

# Caso não seja o fim da string, incremetamos a0 e a1
# O incremento é unitário porque iremos pecorrer caracter a caracter
addiu $a0, $a0, 1
addiu $a1, $a1, 1

# retorno ao loop.
j loop_principal

fimDoLoop:

# Não precisamos colocar nada antes do retorno
# Porque logo no inicio da função, salvamos em $v0
# o endereço base de $a0 ( string cópia )

jr $ra

encontrar_caracter:
# Registradores:
# $t0 - caracter atual
# #a0 - ponteiro que avança pela string
# $a1 - caracter a ser encontrado
# $v0 - 1 se encontrado, 0 se não encontrado

    li $v0, 0          # Inicializa $v0 como 0 (não encontrado)
    loop_encontrar:
        lb $t0, 0($a0) #carrega o primeiro caracter da string
        beq $t0, $zero, nao_encontrado  # Se for nulo, a string acabou e a busca termina
        
        beq $t0, $a1, encontrado # se t0 é igual a a1, o caracter foi encontrado

        addi $a0, $a0, 1  # Avança para o próximo caracter
        j loop_encontrar  # Continua o loop

    encontrado:
       move $v0, $a0      # Se o caracter for encontrado, salva o endereço em $v0
       jr $ra             # Retorna da função

   nao_encontrado:
   # Como não foi encontrado, retorna 0
   li $v0, 0          # Marca como não encontrado
    jr $ra          # Retorna da função
