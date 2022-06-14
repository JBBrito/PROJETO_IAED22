; *********************************************************************************
; * IST-UL
; * Modulo:    grupo27.asm
; * Membros do grupo:
; * 102503 Artur Vasco de Almeida Martins
; * 102612 Gonçalo José Marques de Novais Cruz
; * 102733 João Bernardo Lima Abrantes Brito
; * Descrição: Este projeto intermédio ilustra o movimento de uma nave do ecrã, sob controlo
; *			do teclado, em que a nave só se movimenta um pixel por cada
; *			tecla carregada (produzindo também um efeito sonoro), também se encontra no ecrã
; *			um meteoro que só se movimenta um pixel por cada tecla carregada (produzindo
; *			também um efeito sonoro). Quando esse meteoro chega ao fim do ecrã volta a reaparecer na
; *			sua posição original. Encontramos um display hexadecimal que por cada tecla defenida
; *			aumenta ou diminui o valor no display.
; *********************************************************************************

; *********************************************************************************
; * Constantes
; *********************************************************************************
TEC_LIN				EQU 0C000H	; endereço das linhas do teclado (periférico POUT-2)
TEC_COL				EQU 0E000H	; endereço das colunas do teclado (periférico PIN)
LINHA_TECLADO			EQU 8		; linha a testar (4ª linha, 1000b)
MASCARA				EQU 0FH		; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TECLA_ESQUERDA			EQU 000CH		; tecla na primeira coluna do teclado (tecla C)
TECLA_DIREITA			EQU 000DH		; tecla na segunda coluna do teclado (tecla D)
TECLA_DESCER_METEORO	EQU 000EH		; tecla na terceira coluna do teclado (tecla E)
LIMITE_MAX_DISPLAY_LINHA	EQU  30		; limite máximo das linhas do ecrã
DISPLAY					EQU 0A000H		; endereço do display (periférico DISPLAY)
DISPLAY_INICIAL			EQU 0100H		; valor inicial apresentado no display
MAX_ENERGIA			EQU 0064H		; valor inicial da energia em hex

DEFINE_LINHA    		EQU 600AH      ; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 600CH      ; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU 6012H      ; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU 6040H      ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 		EQU 6002H      ; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  EQU 6042H      ; endereço do comando para selecionar uma imagem de fundo
TOCA_SOM				EQU 605AH      ; endereço do comando para tocar um som

LINHA        		EQU  28      ; linha do boneco (no fundo do ecrã)
COLUNA			EQU  30        ; coluna do boneco (a meio do ecrã)

LINHA_METEORO_MAIOR		EQU 5		; linha do meteoro
COLUNA_METEORO_MAIOR	EQU 15		; coluna do meteoro

MIN_COLUNA		EQU  0		; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		EQU  63        ; número da coluna mais à direita que o objeto pode ocupar
ATRASO			EQU	400H		; atraso para limitar a velocidade de movimento do boneco

LARGURA		EQU	5			; largura do boneco
ALTURA		EQU 4			;altura do boneco
COR_PIXEL_VERMELHO		EQU	0FF00H		; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)
COR_PIXEL_AMARELO		EQU	0FFF0H		; cor do pixel: amarelo em ARGB (opaco, vermelho e verde no máximo, azul a 0)

N_BONECOS			EQU  8		; número de bonecos (até 8)
COLUNA_BONECO_0		EQU  0		; linha do boneco 0
COLUNA_BONECO_1		EQU  8		; linha do boneco 1
COLUNA_BONECO_2		EQU  16	    ; linha do boneco 2
COLUNA_BONECO_3		EQU  24		; linha do boneco 3
COLUNA_BONECO_4		EQU  32		; linha do boneco 4
COLUNA_BONECO_5		EQU  40	    ; linha do boneco 5
COLUNA_BONECO_6		EQU  48	    ; linha do boneco 6
COLUNA_BONECO_7		EQU  56	    ; linha do boneco 7			
LINHA_INICIAL		EQU 0

LARGURA_METEORO_MAIOR	EQU 5		; largura do meteoro maior e da nave inimiga maior
ALTURA_METEORO_MAIOR	EQU 5		; altura do meteoro maior e da nave inimiga maior

LARGURA_METEORO_4	EQU 4		; largura do quarto meteoro e da quarta nave inimiga
ALTURA_METEORO_4	EQU 4		; altura do quarto meteoro e da quarta nave inimiga

LARGURA_METEORO_3	EQU 3		; largura do terceiro meteoro e da terceira nave inimiga
ALTURA_METEORO_3	EQU 3		; altura do terceiro meteoro e da terceira nave inimiga

COR_PIXEL_VERDE			EQU 0F0F0H		; cor do pixel: verde em ARGB (opaco e verde no máximo, vermelho e azul a 0)

LARGURA_METEORO_2	EQU 2		; largura do segundo meteoro e da segunda nave inimiga
ALTURA_METEORO_2	EQU 2		; altura do segundo meteoro e da segunda nave inimiga

LARGURA_METEORO_MENOR	EQU 1		; largura do primeiro meteoro e da primeira nave inimiga
ALTURA_METEORO_MENOR	EQU 1		; altura do primeiro meteoro e da primeira nave inimiga

COR_PIXEL_TRANSPARENTE		EQU 0400H		; cor do pixel: transparent (opaco a 26% , verdde, vermelho e azul a 0)

LARGURA_MISSIL			EQU 1		; largura do missil disparado pela nave
ALTURA_MISSIL			EQU 1		; altura do missil disparado pela nave
COR_PIXEL_ROXO			EQU 0FF1FH		; cor do pixel: roxo em ARGB (opaco, vermelho e azul no máximo, verde a 0)

LARGURA_EXPLOSAO		EQU 5		; largura da explosão de um objeto
ALTURA_EXPLOSAO			EQU 5		; altura da explosão de um objeto
COR_PIXEL_AZUL_TURQUESA			EQU 0F0FFH		; cor do pixel: azul turquesa em ARGB (opaco ,verde e azul no máximo, vermelho a 0)
; *********************************************************************************
; * Dados 
; *********************************************************************************
	PLACE       1000H
; Reserva do espaço para as pilhas dos processos
	STACK 100H			; espaço reservado para a pilha do processo "programa principal"
SP_inicial_prog_princ:		; este é o endereço com que o SP deste processo deve ser inicializado
							
	STACK 100H			; espaço reservado para a pilha do processo "teclado"
SP_inicial_teclado:			; este é o endereço com que o SP deste processo deve ser inicializado
							
; SP inicial de cada processo "boneco"
	STACK 100H			; espaço reservado para a pilha do processo "boneco", instância 0
SP_inicial_boneco_0:		; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H			; espaço reservado para a pilha do processo "boneco", instância 1
SP_inicial_boneco_1:		; este é o endereço com que o SP deste processo deve ser inicializado
							
	STACK 100H			; espaço reservado para a pilha do processo "boneco", instância 2
SP_inicial_boneco_2:		; este é o endereço com que o SP deste processo deve ser inicializado
							
	STACK 100H			; espaço reservado para a pilha do processo "boneco", instância 3
SP_inicial_boneco_3:		; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H			; espaço reservado para a pilha do processo "boneco", instância 4
SP_inicial_boneco_4:		; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H			; espaço reservado para a pilha do processo "boneco", instância 5
SP_inicial_boneco_5:		; este é o endereço com que o SP deste processo deve ser inicializado
							
	STACK 100H			; espaço reservado para a pilha do processo "boneco", instância 6
SP_inicial_boneco_6:		; este é o endereço com que o SP deste processo deve ser inicializado
							
	STACK 100H			; espaço reservado para a pilha do processo "boneco", instância 7
SP_inicial_boneco_7:		; este é o endereço com que o SP deste processo deve ser inicializado	
						
; tabela com os SP iniciais de cada processo "boneco"
boneco_SP_tab:
	WORD	SP_inicial_boneco_0
	WORD	SP_inicial_boneco_1
	WORD	SP_inicial_boneco_2
	WORD	SP_inicial_boneco_3
	WORD	SP_inicial_boneco_4
	WORD	SP_inicial_boneco_5
	WORD	SP_inicial_boneco_6
	WORD	SP_inicial_boneco_7
							
DEF_BONECO:					; tabela que define o boneco (cor, largura, altura, pixels)
	WORD		LARGURA
	WORD		ALTURA
	WORD		0, 0, COR_PIXEL_AMARELO, 0, 0		; __#__   as cores podem ser diferentes
	WORD		COR_PIXEL_AMARELO, 0, COR_PIXEL_AMARELO, 0, COR_PIXEL_AMARELO		; #_#_#   as cores podem ser diferentes
	WORD		COR_PIXEL_AMARELO, COR_PIXEL_AMARELO, COR_PIXEL_AMARELO, COR_PIXEL_AMARELO, COR_PIXEL_AMARELO		; #####   as cores podem ser diferentes
	WORD		0, COR_PIXEL_AMARELO, 0, COR_PIXEL_AMARELO, 0		; _#_#_   as cores podem ser diferentes
	
DEF_METEORO_MAIOR_VERDE:			; tabela  que define o meteoro maior verde (cor, largura, altura, pixels)
	WORD		LARGURA_METEORO_MAIOR
	WORD		ALTURA_METEORO_MAIOR
	WORD		0, COR_PIXEL_VERDE, COR_PIXEL_VERDE, COR_PIXEL_VERDE, 0		; _###_   as cores podem ser diferentes
	WORD		COR_PIXEL_VERDE, COR_PIXEL_VERDE, COR_PIXEL_VERDE, COR_PIXEL_VERDE, COR_PIXEL_VERDE			; #####	   as cores podem ser diferentes
	WORD		COR_PIXEL_VERDE, COR_PIXEL_VERDE, COR_PIXEL_VERDE, COR_PIXEL_VERDE, COR_PIXEL_VERDE			; #####	   as cores podem ser diferentes
	WORD		COR_PIXEL_VERDE, COR_PIXEL_VERDE, COR_PIXEL_VERDE, COR_PIXEL_VERDE, COR_PIXEL_VERDE			; #####	   as cores podem ser diferentes
	WORD		0, COR_PIXEL_VERDE, COR_PIXEL_VERDE, COR_PIXEL_VERDE, 0			; _###_   as cores podem ser diferentes

DEF_METEORO_4_VERDE:			; tabela  que define o meteoro 4 verde (cor, largura, altura, pixels)
	WORD		LARGURA_METEORO_4
	WORD		ALTURA_METEORO_4
	WORD		0, COR_PIXEL_VERDE, COR_PIXEL_VERDE, 0		; _##_   as cores podem ser diferentes
	WORD		COR_PIXEL_VERDE, COR_PIXEL_VERDE, COR_PIXEL_VERDE, COR_PIXEL_VERDE		; ####	   as cores podem ser diferentes
	WORD		COR_PIXEL_VERDE, COR_PIXEL_VERDE, COR_PIXEL_VERDE, COR_PIXEL_VERDE		; ####	   as cores podem ser diferentes
	WORD		0, COR_PIXEL_VERDE, COR_PIXEL_VERDE, 0			; _##_	   as cores podem ser diferentes

DEF_METEORO_3_VERDE:			; tabela  que define o meteoro 3 verde (cor, largura, altura, pixels)
	WORD		LARGURA_METEORO_3
	WORD		ALTURA_METEORO_3
	WORD		0, COR_PIXEL_VERDE, 0		; _#_   as cores podem ser diferentes
	WORD		COR_PIXEL_VERDE, COR_PIXEL_VERDE, COR_PIXEL_VERDE		; ###	   as cores podem ser diferentes
	WORD		0, COR_PIXEL_VERDE, 0			; _#_	   as cores podem ser diferentes

DEF_METEORO_2_VERDE:			; tabela  que define o meteoro 2 verde (cor, largura, altura, pixels)
	WORD		LARGURA_METEORO_2
	WORD		ALTURA_METEORO_2
	WORD		COR_PIXEL_TRANSPARENTE, COR_PIXEL_TRANSPARENTE	; ##   as cores podem ser diferentes
	WORD		COR_PIXEL_TRANSPARENTE, COR_PIXEL_TRANSPARENTE		; ##	   as cores podem ser diferentes

DEF_METEORO_MENOR_VERDE:			; tabela  que define o meteoro 1 verde (cor, largura, altura, pixels)
	WORD		LARGURA_METEORO_MENOR
	WORD		ALTURA_METEORO_MENOR
	WORD		COR_PIXEL_TRANSPARENTE  ; ##   as cores podem ser diferentes

DEF_NAVE_MAIOR_VERMELHA:			; tabela  que define a nave maior vermelha (cor, largura, altura, pixels)
	WORD		LARGURA_METEORO_MAIOR
	WORD		ALTURA_METEORO_MAIOR
	WORD		COR_PIXEL_VERMELHO, 0, 0, 0, COR_PIXEL_VERMELHO	; #___#  as cores podem ser diferentes
	WORD		COR_PIXEL_VERMELHO, 0, COR_PIXEL_VERMELHO, 0, COR_PIXEL_VERMELHO	; #_#_#  as cores podem ser diferentes
	WORD		0, COR_PIXEL_VERMELHO, COR_PIXEL_VERMELHO, COR_PIXEL_VERMELHO, 0			; _###_	   as cores podem ser diferentes
	WORD		COR_PIXEL_VERMELHO, 0, COR_PIXEL_VERMELHO, 0, COR_PIXEL_VERMELHO	; #_#_#  as cores podem ser diferentes
	WORD		COR_PIXEL_VERMELHO, 0, 0, 0, COR_PIXEL_VERMELHO	; #___#  as cores podem ser diferentes

DEF_NAVE_4_VERMELHA:			; tabela  que define a nave 4 vermelha (cor, largura, altura, pixels)
	WORD		LARGURA_METEORO_4
	WORD		ALTURA_METEORO_4
	WORD		COR_PIXEL_VERMELHO, 0, 0, COR_PIXEL_VERMELHO		; #__#   as cores podem ser diferentes
	WORD		COR_PIXEL_VERMELHO, 0, 0, COR_PIXEL_VERMELHO		; #__#   as cores podem ser diferentes
	WORD		0, COR_PIXEL_VERMELHO, COR_PIXEL_VERMELHO, 0		; _##_   as cores podem ser diferentes
	WORD		COR_PIXEL_VERMELHO, 0, 0, COR_PIXEL_VERMELHO		; #__#   as cores podem ser diferentes

DEF_NAVE_3_VERMELHA:			; tabela  que define a nave 3 vermelha (cor, largura, altura, pixels)
	WORD		LARGURA_METEORO_3
	WORD		ALTURA_METEORO_3
	WORD		COR_PIXEL_VERMELHO, 0, COR_PIXEL_VERMELHO		; #_#   as cores podem ser diferentes
	WORD		0, COR_PIXEL_VERMELHO, 0		; _#_	   as cores podem ser diferentes
	WORD		COR_PIXEL_VERMELHO, 0, COR_PIXEL_VERMELHO		; #_#   as cores podem ser diferentes	

DEF_NAVE_2_VERMELHA:			; tabela  que define a nave 2 vermelha (cor, largura, altura, pixels)
	WORD		LARGURA_METEORO_2
	WORD		ALTURA_METEORO_2
	WORD		COR_PIXEL_TRANSPARENTE, COR_PIXEL_TRANSPARENTE	; ##   as cores podem ser diferentes
	WORD		COR_PIXEL_TRANSPARENTE, COR_PIXEL_TRANSPARENTE		; ##	   as cores podem ser diferentes

DEF_NAVE_MENOR_VERMELHA:			; tabela  que define a nave 1 vermelha (cor, largura, altura, pixels)
	WORD		LARGURA_METEORO_MENOR
	WORD		ALTURA_METEORO_MENOR
	WORD		COR_PIXEL_TRANSPARENTE  ; #   as cores podem ser diferentes

DEF_MISSIL:			; tabela  que define o míssil (cor, largura, altura, pixels)
	WORD		LARGURA_MISSIL
	WORD		ALTURA_MISSIL
	WORD		COR_PIXEL_ROXO  ; #   as cores podem ser diferentes

DEF_EXPLOSAO:	      ; tabela  que define a explosão (cor, largura, altura, pixels)
	WORD		LARGURA_EXPLOSAO
	WORD		ALTURA_EXPLOSAO
	WORD		0, COR_PIXEL_AZUL_TURQUESA, 0, COR_PIXEL_AZUL_TURQUESA, 0	; _#_#_  as cores podem ser diferentes
	WORD		COR_PIXEL_AZUL_TURQUESA, 0, COR_PIXEL_AZUL_TURQUESA, 0, COR_PIXEL_AZUL_TURQUESA	; #_#_#  as cores podem ser diferentes
	WORD		0, COR_PIXEL_AZUL_TURQUESA, 0, COR_PIXEL_AZUL_TURQUESA, 0	; _#_#_  as cores podem ser diferentes
	WORD		COR_PIXEL_AZUL_TURQUESA, 0, COR_PIXEL_AZUL_TURQUESA, 0, COR_PIXEL_AZUL_TURQUESA	; #_#_#  as cores podem ser diferentes
	WORD		0, COR_PIXEL_AZUL_TURQUESA, 0, COR_PIXEL_AZUL_TURQUESA, 0	; _#_#_  as cores podem ser diferentes
	
linha_boneco:				; linha em que cada boneco está (inicializada com a linha inicial)
	WORD LINHA_INICIAL
	WORD LINHA_INICIAL
	WORD LINHA_INICIAL
	WORD LINHA_INICIAL
	WORD LINHA_INICIAL
	WORD LINHA_INICIAL
	WORD LINHA_INICIAL
	WORD LINHA_INICIAL
                              
coluna_boneco:				; coluna em que cada boneco está (inicializada com a coluna inicial)
	WORD COLUNA_BONECO_0
	WORD COLUNA_BONECO_1
	WORD COLUNA_BONECO_2
	WORD COLUNA_BONECO_3
	WORD COLUNA_BONECO_4
	WORD COLUNA_BONECO_5
	WORD COLUNA_BONECO_6
	WORD COLUNA_BONECO_7
                              
sentido_movimento:			; sentido movimento de cada boneco (+1 para a direita, -1 para a esquerda)
	WORD 1
	WORD 1
	WORD 1
	WORD 1
	WORD 1
	WORD 1
	WORD 1
	WORD 1
                              
; Tabela das rotinas de interrupção
tab:
	WORD rot_int_0			; rotina de atendimento da interrupção 0
	WORD rot_int_1			; rotina de atendimento da interrupção 1
	WORD rot_int_2			; rotina de atendimento da interrupção 2

evento_int_bonecos:			; LOCKs para cada rotina de interrupção comunicar ao processo
						; boneco respetivo que a interrupção ocorreu
	LOCK 0				; LOCK para a rotina de interrupção 0
	LOCK 0				; LOCK para a rotina de interrupção 1
	LOCK 0				; LOCK para a rotina de interrupção 2
; *********************************************************************************
; * Código
; *********************************************************************************
PLACE   0                     ; o código tem de começar em 0000H
inicio:
	MOV  SP, SP_inicial		; inicializa SP para a palavra a seguir
						; à última da pilha
                            
     MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
     MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	R1, 0			; cenário de fundo número 0
     MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
	MOV	R7, 1			; valor a somar à coluna do boneco, para o movimentar
     MOV R11, DISPLAY
	 MOV R9, DISPLAY_INICIAL
	 MOV [R11], R9
	 MOV R9, MAX_ENERGIA                 ; valor 100 em hex
posição_boneco:
     MOV  R1, LINHA			; linha do boneco
     MOV  R2, COLUNA		; coluna do boneco
	MOV	R4, DEF_BONECO		; endereço da tabela que define o boneco
	
posição_meteoro_maior:
	MOV  R5, DEF_METEORO_MAIOR_VERDE	; endereço da tabela que define o meteoro
	MOV  R8, LINHA_METEORO_MAIOR		; linha do meteoro

	
mostra_meteoro_maior:
	CALL	desenha_meteoro_maior		; desenha o meteoro maior a partir da tabela


mostra_boneco:
	CALL	desenha_boneco			; desenha o boneco a partir da tabela
	CALL 	atraso					; facilita a visualizaçao do movimento
	

; **********************************************************************
; Processo
;
; TECLADO - Processo que deteta quando se carrega numa tecla
;		  do teclado e escreve o valor da tecla num LOCK.
;
; **********************************************************************


PROCESS SP_inicial_teclado
	
teclado_processo:	
	MOV  R6, LINHA_TECLADO
	MOV R0, 0
	
	
espera_nao_tecla:			; neste ciclo espera-se até NÃO haver nenhuma tecla premida
	WAIT
							;
							;
	MOV  R6, LINHA_TECLADO	; linha a testar no teclado
	CALL	teclado			; leitura às teclas
	CMP	R0, 0
	JNZ	espera_nao_tecla	; espera, enquanto houver tecla uma tecla carregada

espera_tecla:						; neste ciclo espera-se até uma tecla ser premida
	WAIT
									;
									;
	MOV [tecla_carregada], R0
	MOV  R6, LINHA_TECLADO			; linha a testar no teclado
	CALL	teclado					; leitura às teclas
	CMP	R0, 0
	JZ	espera_tecla	; espera, enquanto não houver tecla
	SHR R6, 5
	MOV [tecla_carregada], R0
	SUB R0, 1						; retorna o vavlor obtido para o valor real da tecla
	JZ diminui_display				; diminui o valor do display em 5
	CMP R0, 1	
	JZ aumenta_display				; aumenta o valor do display em 5
	MOV R6, TECLA_DESCER_METEORO	; verifica se a tecla que controla a altura do asteroide foi precionada
	CMP R0, R6
	JZ desce_meteoro				; desce o asteroide 1 linha
	MOV R6 , TECLA_ESQUERDA			; verifica se a tecla precionada deverá mexer o rover para a esquerda
	CMP	R0, R6						
	JNZ	testa_direita				; verifica se a tecla precionada deverá mexer o rover para a direita
	MOV	R7, -1						; mexe o rover para a esquerda
	JMP	ve_limites					; verifica se os limites da tela foram alcancados
	
diminui_display:
	call diminui_display_rotina		; diminui o valor do display por 5
	JMP espera_nao_tecla
aumenta_display:
	call aumenta_display_rotina		; aumenta o valr do display por 5
	JMP espera_nao_tecla
testa_direita:
	MOV R6, TECLA_DIREITA			; verifica se a tecla precionada devera mexer o rover para a direita
	CMP	R0, R6
	JNZ espera_tecla
	MOV	R7, +1						; vai deslocar para a direita
	JMP ve_limites
	

RESET_R8:
	CALL RESET_R8_rotina		;rotina para R8 ficar com o seu valor original
	JMP desce_meteoro

ve_limites:
	MOV	R6, [R4]			; obtém a largura do boneco
	CALL testa_limites		; vê se chegou aos limites do ecrã e se sim força R7 a 0
	CMP	R7, 0
	JZ	espera_tecla		; se não é para movimentar o objeto, vai ler o teclado de novo

move_boneco:
	MOV	R10, 0			; som com número 0 (som do rover)
	MOV [TOCA_SOM], R10
	CALL apaga_boneco		; apaga o boneco na sua posição corrente
	
coluna_seguinte:
	ADD	R2, R7			; para desenhar objeto na coluna seguinte (direita ou esquerda)
	CALL desenha_boneco
	CALL atraso
	JMP	espera_tecla		; vai desenhar o boneco de novo

desce_meteoro:
	CALL apaga_meteoro_maior	 	; remove o meteoro da posição original
	MOV R6, LIMITE_MAX_DISPLAY_LINHA		; verificar se o meteoro já chegou ao fundo do ecrã
	CMP R8, R6
	JZ RESET_R8			; se sim, o meteoro volta à posição inicial 
	MOV	R10, 1			; som com número 1 (som do meteoro)
	MOV [TOCA_SOM], R10		; comando para tocar o som	; vai deslocar para a esquerda
	ADD R8, 1				; move o meteoro uma unidade para baixo
	CALL desenha_meteoro_maior		; insere o meteoro na nova posição 
	JMP espera_nao_tecla


; **********************************************************************
; DESENHA_BONECO- Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
desenha_boneco:
	PUSH    R1
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	PUSH	R8
	MOV	R5, [R4]			; obtém a largura da nave
	ADD	R4, 2	; endereço da altura da nave (2 porque a largura é uma word)
	MOV R8, [R4]	; obtém a altura da nave
	ADD	R4, 2	; endereço da cor do 1º pixel (2 porque a largura é uma word)
desenha_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]			; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel		; escreve cada pixel do boneco
	ADD	R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R2, 1               ; próxima coluna
    SUB  R5, 1			; menos uma coluna para tratar
    JNZ  desenha_pixels      ; continua até percorrer toda a largura do objeto
	MOV R5, LARGURA			; reiniciar a largura
	SUB R2, LARGURA			; voltar à coluna inicial
	ADD R1, 1			; proxima linha
	SUB R8, 1			; menos uma linha para tratar
	JNZ  desenha_pixels		; continua até percorrer todo o objeto
	POP R8
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	POP R1
	RET

; **********************************************************************
; DESENHA_METEORO_MAIOR- Desenha um meteoro na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R8 - linha
;               R2 - coluna
;               R5 - tabela que define o boneco
;
; **********************************************************************	
desenha_meteoro_maior:
	PUSH    R1
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	PUSH	R8
	MOV R2, COLUNA_METEORO_MAIOR	; obtém a posição do meteoro(coluna)
	MOV	R4, [R5]			; obtém a largura do meteoro
	ADD	R5, 2	; endereço da altura do meteoro maior (2 porque a largura é uma word)
	MOV R1, R5				; obtém a altura do meteoro
	ADD	R5, 2	; endereço da cor do 1º pixel (2 porque a largura é uma word)
desenha_pixels_meteoro:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R5]			; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel_meteoro		; escreve cada pixel do boneco
	ADD	R5, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R2, 1               ; próxima coluna
    SUB  R4, 1			; menos uma coluna para tratar
    JNZ  desenha_pixels_meteoro      ; continua até percorrer toda a largura do objeto
	MOV R4, LARGURA_METEORO_MAIOR			; reiniciar a largura
	SUB R2, LARGURA_METEORO_MAIOR	; voltar à coluna inicial
	ADD R8, 1			; proxima linha
	SUB R1, 1			; menos uma linha para tratar
	JNZ  desenha_pixels_meteoro		; continua até percorrer todo o objeto
	POP R8
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	POP R1
	RET

; **********************************************************************
; APAGA_BONECO- Apaga um boneco na linha e coluna indicadas
;			  com a forma definida na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
apaga_boneco:
	PUSH    R1
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	PUSH	R8
	MOV	R5, [R4]			; obtém a largura do boneco
	ADD	R4, 2	; endereço da altura da nave (2 porque a largura é uma word)
	MOV R8, [R4]	; obtém a altura da nave
	ADD	R4, 2			; endereço da cor do 1º pixel (2 porque a largura é uma word)
apaga_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, 0			; cor para apagar o próximo pixel do boneco
	CALL	escreve_pixel		; escreve cada pixel do boneco
	ADD	R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R2, 1               ; próxima coluna
    SUB  R5, 1			; menos uma coluna para tratar
    JNZ  apaga_pixels      ; continua até percorrer toda a largura do objeto
	MOV R5, LARGURA			; reiniciar a largura			
	SUB R2, LARGURA			; voltar à coluna inicial
	ADD R1, 1			; próxima linha
	SUB R8, 1			; menos uma linha para tratar
	JNZ  apaga_pixels	;  continua até percorrer todo o objeto
	POP R8
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	POP R1
	RET

; **********************************************************************
; APAGA_METEORO_MAIOR- Apaga um meteoro na linha e coluna indicadas
;			  com a forma definida na tabela indicada.
; Argumentos:   R8 - linha
;               R2 - coluna
;               R5 - tabela que define o boneco
;
; **********************************************************************
apaga_meteoro_maior:
	PUSH    R1
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	PUSH	R8
	MOV R2, COLUNA_METEORO_MAIOR	; obtém a posição do meteoro(coluna)
	MOV	R4, [R5]			; obtém a largura do meteoro
	ADD	R5, 2	; endereço da altura do meteoro maior (2 porque a largura é uma word)
	MOV R1, R5				; obtém a altura do meteoro
	ADD	R5, 2	; endereço da cor do 1º pixel (2 porque a largura é uma word)
apaga_pixels_meteoro:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, 0			; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel_meteoro		; escreve cada pixel do boneco
	ADD	R5, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R2, 1               ; próxima coluna
    SUB  R4, 1			; menos uma coluna para tratar
    JNZ  apaga_pixels_meteoro      ; continua até percorrer toda a largura do objeto
	MOV R4, LARGURA_METEORO_MAIOR		; reiniciar a largura
	SUB R2, LARGURA_METEORO_MAIOR		; voltar à coluna inicial
	ADD R8, 1			; proxima linha
	SUB R1, 1			; menos uma linha para tratar
	JNZ  apaga_pixels_meteoro		; continua até percorrer todo o objeto
	POP R8
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	POP R1
	RET

; **********************************************************************
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; **********************************************************************
escreve_pixel:
	MOV  [DEFINE_LINHA], R1		; seleciona a linha
	MOV  [DEFINE_COLUNA], R2		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
	RET

escreve_pixel_meteoro:
	MOV  [DEFINE_LINHA], R8		; seleciona a linha
	MOV  [DEFINE_COLUNA], R2		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
	RET
; **********************************************************************
; ATRASO - Executa um ciclo para implementar um atraso.
; Argumentos:   R11 - valor que define o atraso
;
; **********************************************************************
atraso:
	PUSH	R11
ciclo_atraso:
	SUB	R11, 1
	JNZ	ciclo_atraso
	POP	R11
	RET

; **********************************************************************
; TESTA_LIMITES - Testa se o boneco chegou aos limites do ecrã e nesse caso
;			   impede o movimento (força R7 a 0)
; Argumentos:	R2 - coluna em que o objeto está
;			R6 - largura do boneco
;			R7 - sentido de movimento do boneco (valor a somar à coluna
;				em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna: 	R7 - 0 se já tiver chegado ao limite, inalterado caso contrário	
; **********************************************************************
testa_limites:
	PUSH	R5
	PUSH	R6
testa_limite_esquerdo:		; vê se o boneco chegou ao limite esquerdo
	MOV	R5, MIN_COLUNA
	CMP	R2, R5
	JGT	testa_limite_direito
	CMP	R7, 0			; passa a deslocar-se para a direita
	JGE	sai_testa_limites
	JMP	impede_movimento	; entre limites. Mantém o valor do R7
testa_limite_direito:		; vê se o boneco chegou ao limite direito
	ADD	R6, R2			; posição a seguir ao extremo direito do boneco
	MOV	R5, MAX_COLUNA
	CMP	R6, R5
	JLE	sai_testa_limites	; entre limites. Mantém o valor do R7
	CMP	R7, 0			; passa a deslocar-se para a direita
	JGT	impede_movimento
	JMP	sai_testa_limites
impede_movimento:
	MOV	R7, 0			; impede o movimento, forçando R7 a 0
sai_testa_limites:	
	POP	R6
	POP	R5
	RET

; **********************************************************************
; TECLADO - Faz uma leitura às teclas de uma linha do teclado e retorna o valor lido
; Argumentos:	R6 - linha a testar (em formato 1, 2, 4 ou 8)
;
; Retorna: 	R0 - valor lido das colunas do teclado (0, 1, 2, 4, ou 8)	
; **********************************************************************
teclado:
	PUSH	R2
	PUSH	R3
	PUSH	R5
	CALL teclado_inicio
	POP	R5
	POP	R3
	POP	R2
	RET
teclado_inicio:
	MOV R2, TEC_LIN
teclado_rotina:
	MOV  R3, TEC_COL   			; endereço do periférico das colunas
	MOV  R5, MASCARA  			; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOVB [R2], R6     			; escrever no periférico de saída (linhas)
	MOVB R0, [R3]      			; ler do periférico de entrada (colunas)
	AND  R0, R5        			; elimina bits para além dos bits 0-3
	CMP R0, 0
	JNE teclado_arranja_tecla	; se R0 tiver valor retorna o valor da tecla
	SHR R6, 1					; se nao existir nenhum valor associado a coluna, esta transforma-se na metade
	JZ teclado_fim				; se R6 = 0, entao ja percorremos a totalidade do teclado
	JMP teclado_rotina			; se R6 != 0, entao ainda ha linhas que ainda nao foram analisadas

teclado_fim:
	RET
	
teclado_arranja_tecla:
	CALL arranja_linha			; transforma o valor da linha num correspondente de 0-3
	CALL arranja_coluna			; transforma o valor da coluna num correspondete de 0-3
	CALL get_valor				; recebe o valor ja trabalhado das linhas e colunas e devolve o valor real da tecla
	RET
	
	
; **********************************************************************
; arranja_linha - Tranforma no valor da linha no correspondete de 0-3
; Argumentos:	R6 - valor da linha 
;
; Retorna: 	R6 - valor real da linha	
; **********************************************************************

arranja_linha:
	PUSH R5 
	MOV R5, 0
	CALL ciclo_linhas
	POP R5
	RET
	
ciclo_linhas:
	ADD R5, 1					; contador de divisoes possiveis por dois do valor da linha
	SHR R6, 1					; divisao do valor da linhas por 2
	JNZ ciclo_linhas
	SUB R5, 1					; obtem o valor real da tecla
	MOV R6,R5
	RET

; **********************************************************************
; arranja_coluna - Tranforma no valor da coluna no correspondete de 0-3
; Argumentos:	R0 - valor da coluna 
;
; Retorna: 	R0 - valor real da coluna	
; **********************************************************************


arranja_coluna:
	PUSH R5
	MOV R5, 0
	CALL ciclo_coluna
	POP R5
	RET
	
ciclo_coluna:
	ADD R5, 1					; contador de divisoes possiveis por dois do valor da coluna
	SHR R0, 1					; divisao do valor da coluna por 2
	JNZ ciclo_coluna
	SUB R5, 1					; obtem o valor real da tecla
	MOV R0, R5
	RET
	
; **********************************************************************
; arranja_coluna - Tranforma no valor da coluna no correspondete de 0-3
; Argumentos:	R0 - valor real da linha (0-3)	
;				R6 - valor real da coluna (0-3)
;
; Retorna: 	R0 - valor real da tecla
; **********************************************************************

get_valor:
	PUSH R6						; o valor real da coluna e dado pela formula
	SHL R6, 2					; 4*L + C
	ADD R6, R0
	MOV R0, R6
	ADD R0, 1					; valor inflacionado para facilitar a verificaçao da tecla precionada
	POP R6
	RET

; **********************************************************************
; aumenta_display_rotina - aumenta o valor demonstrado no display por 5
; Argumentos:	R9 - valor do display
;
; Retorna: 	R9 - valor transformado do display
; **********************************************************************

aumenta_display_rotina:
	call maior_100				; verifica se o novo valor do display sera maior que 100H
	ADD R9, 5
	CALL display_hex_para_dec
	RET
	
maior_100:
	PUSH R9
	PUSH R1
	MOV R1,MAX_ENERGIA
	;SHR R9, 8					; shift left de 100H resulta em 1
	CMP R9, R1
	JNE	NOT_IGUAL_100
	JMP IGUAL_100

NOT_IGUAL_100:
	POP R1
	POP R9
	RET

IGUAL_100:
	;MOV R1, DISPLAY_INICIAL
	;MOV [R11],R1
	POP R1
	POP R9
	SUB R9, 5					; reduz o valor em 5 para compensar a adicao que decorre seguidamente
	RET
	

; **********************************************************************
; diminui_display_rotina - diminui o valor demonstrado no display por 5
; Argumentos:	R9 - valor do display
;
; Retorna: 	R9 - valor transformado do display
; **********************************************************************


diminui_display_rotina:
	call menor_0				; verifica se o novo valor do valor do display sera menor que 0
	SUB R9, 5					; obtem o novo valor do display
	CALL display_hex_para_dec
	RET

menor_0:
	CMP R9, 0
	JZ IGUAL_0
	JMP NOT_IGUAL_0
	
IGUAL_0:
	ADD R9, 5					; aumenta o valor em 5 para compensar a subtracao que decorre seguidamente
	RET

NOT_IGUAL_0:
	RET


; **********************************************************************
; display_hex_para_dec: - converte números hex para dec e mostra-os no display
; Argumentos:	R9 - o número em hex
;
; Retorna: 	R3 - o número em dec no display
; **********************************************************************

display_hex_para_dec:
	PUSH R1				; fator
	PUSH R2				; primeiro digíto do número
	PUSH R3				; resultado em decimal
	PUSH R4				; 10 (valor para realizar comparações)
	PUSH R5				; resto do número
	PUSH R6				; 100 (valor para realizar comparações)
	PUSH R9				; numero em hex
	PUSH R10				; 00A0 (valor para realizar comparações)
	MOV R4,10
	MOV R1,1000
	MOV R3,0000H
	MOV R2,R9
	MOV R6,0100
	MOV R10,00A0H
	ciclo_display:
		MOV R2,R9
		MOV R5,R9
		DIV R1,R4				; fator
		DIV R2,R1				; digito
		MOD R5,R4
		SHl R2,4
		CMP R1,R6
		JGE ciclo_display
	OR R3,R5			; junta o ultimo digito ao resultado final do display
	OR R3,R2			; junta o primeiro digito ao resultado final do display
	CMP R3,R10
	JGE igual_a_100
	MOV [R11], R3			; transfere o novo valor para o display em decimal
	POP R10
	POP R9
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET

igual_a_100:
	MOV R3,DISPLAY_INICIAL
	MOV [R11], R3
	POP R10
	POP R9
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET

; **********************************************************************
; diminui_display_rotina - retorna a linha de um asteroide fora de limites para o seu valor original
; Argumentos:	R8 - linha atual do asteroide que se encontra fora dos limites da tecla
;
; Retorna: 	R8 - linha inicial do asteroide
; **********************************************************************



RESET_R8_rotina:
	MOV R8, LINHA_METEORO_MAIOR
	RET
