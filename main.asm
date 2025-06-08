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
    li $a3, %len              # Tamanho máximo de caracteres a comparar
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
str_ad_morador:     "ad_morador\n"
str_rm_morador:     "rm_morador\n"
str_ad_auto:        "ad_auto\n"
str_rm_auto:        "rm_auto\n"
str_info_ap:        "info_ap\n"
str_info_geral:     "info_geral\n"
str_limpar_ap:      "limpar_ap\n"
str_salvar:         "salvar\n"
str_recarregar:     "recarregar\n"
str_formatar:       "formatar\n"
str_sair:           "sair\n"

# -------------- Tamanho máximo de caracteres para comparação --------------- #
input_buffer: .space 128 

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
msg_lista_funçoes: .asciiz "Comandos disponíveis:\nad_morador - Adicionar morador\n rm_morador - Remover morador\n ad_auto - Adicionar automóvel\n rm_auto - Remover automóvel\ninfo_ap - Informações do apartamento\ninfo_geral - Informações gerais\nlimpar_ap - Limpar apartamento\nsalvar - Salvar dados\nrecarregar - Recarregar dados\nformatar - Formatar sistema\nsair - Sair do sistema\n"
msg_limpa_terminal: .asciiz "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" # Sequência de escape para limpar o terminal


.text
# -------------- Função Principal -------------- #
main:
    #inicia o loop principal
    PRINT_STRING msg_principal
    PRINT_STRING msg_lista_funçoes
loop_inteface:
    PRINT_STRING msg_limpa_terminal # Limpa o terminal
    PRINT_STRING msg_lista_funçoes
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
    COMPARAR_CMD str_ad_auto, 7, adicionar_automovel
    COMPARAR_CMD str_rm_auto, 7, remover_automovel
    COMPARAR_CMD str_info_ap, 7, info_ap
    COMPARAR_CMD str_info_geral, 10, info_geral
    COMPARAR_CMD str_limpar_ap, 9, limpar_ap
    COMPARAR_CMD str_salvar, 6, salvar
    COMPARAR_CMD str_recarregar, 10, recarregar
    COMPARAR_CMD str_formatar, 8, formatar
    COMPARAR_CMD str_sair, 4, sair
    
    # Se nenhum comando foi reconhecido, imprime mensagem de erro
    PRINT_STRING msg_comando_malformado
    j loop_inteface  # Volta para o início do loop

adicionar_morador:
    PRINT_STRING str_ad_morador
    j loop_inteface  # Volta para o início do loop
remover_morador:
    PRINT_STRING str_rm_morador
    j loop_inteface  # Volta para o início do loop
adicionar_automovel:
    PRINT_STRING str_ad_auto
    j loop_inteface  # Volta para o início do loop
remover_automovel:
    PRINT_STRING str_rm_auto
    j loop_inteface  # Volta para o início do loopj 
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
