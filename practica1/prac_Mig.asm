.586
.MODEL FLAT, C


; Funcions definides en C
printChar_C PROTO C, value:SDWORD
printInt_C PROTO C, value:SDWORD
clearscreen_C PROTO C
printMenu_C PROTO C
gotoxy_C PROTO C, value:SDWORD, value1: SDWORD
getch_C PROTO C
victory_C PROTO C
printBoard_C PROTO C, value: DWORD
initialPosition_C PROTO C


TECLA_S EQU 115   ;ASCII letra s es el 115


.data          
teclaSalir DB 0




.code   
   
;;Macros que guardan y recuperan de la pila los registros de proposito general de la arquitectura de 32 bits de Intel    
Push_all macro
	
	push eax
   	push ebx
    push ecx
    push edx
    push esi
    push edi
endm


Pop_all macro

	pop edi
   	pop esi
   	pop edx
   	pop ecx
   	pop ebx
   	pop eax
endm
   
   
public C posCurScreen, getMove, moveCursor, moveCursorContinuo, moveTile, playTile
                         

extern C opc: SDWORD, row:SDWORD, col: BYTE, carac: BYTE, carac2: BYTE, puzzle: BYTE, indexMat: SDWORD, rowEmpty: SDWORD, colEmpty: BYTE, victory: SDWORD, moves: SDWORD
extern C rowScreen: SDWORD, colScreen: SDWORD, RowScreenIni: SDWORD, ColScreenIni: SDWORD
extern C rowIni: SDWORD, colIni: BYTE, indexMatIni: SDWORD


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Situar el cursor en una fila i una columna de la pantalla
; en funci� de la fila i columna indicats per les variables colScreen i rowScreen
; cridant a la funci� gotoxy_C.
;
; Variables utilitzades: 
; Cap
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;gotoxy:
gotoxy proc
   push ebp
   mov  ebp, esp
   Push_all

   ; Quan cridem la funci� gotoxy_C(int row_num, int col_num) des d'assemblador 
   ; els par�metres s'han de passar per la pila
      
   mov eax, [colScreen]
   push eax
   mov eax, [rowScreen]
   push eax
   call gotoxy_C
   pop eax
   pop eax 
   
   Pop_all

   mov esp, ebp
   pop ebp
   ret
gotoxy endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar un car�cter, guardat a la variable carac
; en la pantalla en la posici� on est� el cursor,  
; cridant a la funci� printChar_C.
; 
; Variables utilitzades: 
; carac : variable on est� emmagatzemat el caracter a treure per pantalla
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;printch:
printch proc
   push ebp
   mov  ebp, esp
   ;guardem l'estat dels registres del processador perqu�
   ;les funcions de C no mantenen l'estat dels registres.
   
   
   Push_all
   

   ; Quan cridem la funci�  printch_C(char c) des d'assemblador, 
   ; el par�metre (carac) s'ha de passar per la pila.
 
   xor eax,eax
   mov  al, [carac]
   push eax 
   call printChar_C
 
   pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret
printch endp
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un car�cter de teclat   
; cridant a la funci� getch_C
; i deixar-lo a la variable carac2.
;
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el caracter llegit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;getch:
getch proc
   push ebp
   mov  ebp, esp
    
   ;push eax
   Push_all

   call getch_C
   
   mov [carac2],al
   
   ;pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret
getch endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la pantalla, dins el tauler, en funci� de
; les variables (row) fila (int) i (col) columna (char), a partir dels
; valors de les constants RowScreenIni i ColScreenIni.
; Primer cal convertir el char de la columna (A..D) a un n�mero
; entre 0 i 3, i el int de la fila (1..4) a un n�mero entre 0 i 3.
; Per calcular la posici� del cursor a pantalla (rowScreen) i 
; (colScreen) utilitzar aquestes f�rmules:
; rowScreen=rowScreenIni+(row*2)
; colScreen=colScreenIni+(col*4)
; Per a posicionar el cursor cridar a la subrutina gotoxy.
;
; Variables utilitzades:	
;	row       : fila per a accedir a la matriu sea
;	col       : columna per a accedir a la matriu sea
;	rowScreen : fila on volem posicionar el cursor a la pantalla.
;	colScreen : columna on volem posicionar el cursor a la pantalla.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;posCurScreen:
posCurScreen proc
    push ebp
	mov  ebp, esp

	xor eax, eax
	mov eax, [row]

	dec eax
	shl eax, 1
	add eax, rowScreenIni
	mov [rowScreen], eax
	
	mov al, [col]
	sub al, 'A'
	shl al, 2
	cbw ;convert byte to word (de al a ax)
	cwd ;convert word to double (de ax a eax)
	add eax, colScreenIni
	mov [colScreen], eax
	call gotoxy
	
	pop eax

	mov esp, ebp
	pop ebp
	ret

posCurScreen endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un car�cter de teclat   
; cridant a la subrutina getch
; Verificar que solament es pot introduir valors entre 'i' i 'l', 
; o les tecles espai 'm' o 's' i deixar-lo a la variable carac2.
; 
; Variables utilitzades: 
;	carac2 : Variable on s'emmagatzema el car�cter llegit
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;getMove:
getMove proc
   push ebp
   mov  ebp, esp

   inici: call getch ;saber que retorna
  ; mov al, [carac2]

  cmp carac2, 'l'
   je fi
   cmp carac2, 'm'
   je fi	
   cmp carac2, 's'
   je fi
   cmp carac2, 'i'
   je fi
    cmp carac2, 'k'
   je fi
   cmp carac2, 'j'
   je fi
   cmp carac2, ' '
   je fi
   jmp inici

fi:;mov [carac2], al

   mov esp, ebp
   pop ebp
   ret

getMove endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Calcular l'�ndex per a accedir a les matrius en assemblador.
; puzzle[row][col] en C, �s [puzzle+indexMat] en assemblador.
; on indexMat = row*4 + col (col convertir a n�mero).
;
; Variables utilitzades:	
;	row       : fila per a accedir a la matriu puzzle
;	col       : columna per a accedir a la matriu puzzle
;	indexMat  : �ndex per a accedir a la matriu puzzle
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;calcIndex: proc endp
calcIndex proc
	push ebp
	mov  ebp, esp
	
	mov ebx, [row]
	dec ebx
	shl ebx, 2

	xor eax, eax

	mov al, [col]
	sub al, 'A'
	cbw
	cwd
	add eax,ebx
	mov [indexMat], eax


	mov esp, ebp
	pop ebp
	ret

calcIndex endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Actualitzar les variables (row) i (col) en funci� de 
; la tecla premuda que tenim a la variable (carac2)
; (i: amunt, j:esquerra, k:avall, l:dreta).
; Comprovar que no sortim del taulell, (row) i (col) nom�s poden 
; prendre els valors [1..4] i [A..D]. Si al fer el moviment es surt 
; del tauler, no fer el moviment.
; No posicionar el cursor a la pantalla, es fa a posCurScreenP1.
; 
; Variables utilitzades: 
;	carac2 : car�cter llegit de teclat
;          'i': amunt, 'j':esquerra, 'k':avall, 'l':dreta
;	row : fila del cursor a la matriu puzzle.
;	col : columna del cursor a la matriu puzzle.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;moveCursor: proc endp
moveCursor proc
   push ebp
   mov  ebp, esp 

   mov cl, [col]
				   mov ebx, [row]
				   mov al, [carac2]
   
				   cmp al, "i"
				   jne cmp_j
				   cmp ebx, 1 
				   jle abans_moveCursor
				   dec ebx
				   jmp fi_moveCursor

cmp_j:             cmp al, "j"
                   jne cmp_k
		           cmp cl, 65
		           jle abans_moveCursor
		           dec cl
		           jmp fi_moveCursor

cmp_k:             cmp al, "k"
                   jne cmp_l
		           cmp ebx, 4
		           jge abans_moveCursor
		           inc ebx
		           jmp fi_moveCursor

cmp_l:             cmp al, "l"
				   jne abans_moveCursor
				   cmp cl, 68
				   jge abans_moveCursor
				   inc cl 
				   jmp fi_moveCursor

abans_moveCursor:  call posCurScreen
                   jmp final_moveCursor

fi_moveCursor:     mov [carac2], al
			       mov [row], ebx
			       mov [col], cl

final_moveCursor:

   mov esp, ebp
   pop ebp
   ret

moveCursor endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continuo. 
;
; Variables utilitzades: 
;	carac2   : variable on s�emmagatzema el car�cter llegit
;	row      : Fila per a accedir a la matriu puzzle
;	col      : Columna per a accedir a la matriu puzzle
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;moveCursorContinuo: proc endp
moveCursorContinuo proc
	push ebp
	mov  ebp, esp

	bucle:		call getMove
				cmp [carac2], "s"
				je fi
				cmp [carac2], "m"
				je fi

				call moveCursor
				mov eax, [row]
				mov bl, [col]
				mov [row], eax
				mov [col], bl
				call posCurScreen
				jmp bucle

fi:
	mov esp, ebp
	pop ebp
	ret

moveCursorContinuo endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Despla�ar una fitxa cap al forat. La fitxa ha despla�ar ser� la que
; indiquin les variables (row) i (col) i primerament s'ha de comprovar
; si �s una posici� v�lida per ser despla�ada. Una posici� v�lida vol
; dir que �s contigua al forat, sense comptar diagonals. Si no �s una
; posici� v�lida no fer el moviment.
; Tamb� s'ha de despla�ar el forat cap a la casella que s'ha mogut. I
; incrementar la variable moves si el moviment ha estat v�lid.
;
; Variables utilitzades: 
;	carac2 : car�cter llegit de teclat
;          'i': amunt, 'j':esquerra, 'k':avall, 'l':dreta
;	row : fila del cursor a la matriu puzzle.
;	col : columna del cursor a la matriu puzzle.
;	rowEmpty : fila de la casella buida
;	colEmpty : columna de la casella buida
;	puzzle : matriu on es guarda l'estat del joc.
;   moves : enter que guarda el nombre de moviments fets.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;moveTile:
moveTile proc
	push ebp
	mov  ebp, esp

	inici:
			cmp [carac2], 's'
			je fi
			mov eax, [rowEmpty]
			cmp eax, [row] 
			jl restaRow
			sub eax, [row]
			jmp cmp1

restaRow:	 mov eax, [row]
			 sub eax, [rowEmpty] 

cmp1:		cmp eax, 0 
			mov edx, eax
			je obtenirCol
			cmp eax, 1
			mov edx, eax
			je obtenirCol
			jmp bucle

			
obtenirCol:	xor eax,eax 
			mov al, [colEmpty]
			cmp al, [col]
			jl restaCol
			sub al, [col]
			jmp cmp2

restaCol:	 xor eax, eax
			  mov al, [col]
			  sub al, [colEmpty]

cmp2:		cmp eax, 0
			je obtenirXor
			cmp eax, 1
			je obtenirXor
			jmp bucle
			

obtenirXor: xor eax, edx 
			cmp eax, 1
			jne bucle

Moviment:	
			
			xor ecx,ecx
			call calcIndex 
			mov edx,[indexMat]
			mov cl,[puzzle+edx]  
			mov [puzzle+edx], ' '
			mov [carac], ' '
			call printch
			

			xor eax,eax 
			mov al, [col]
			xor ebx, ebx
			mov bl,[colEmpty]
			mov [colEmpty], al	
			mov [col], bl

			mov eax, [row]
			mov ebx, [rowEmpty]
			mov [rowEmpty], eax
			mov [row],ebx

			call calcIndex 

			mov edx,[indexMat] 
			xor eax,eax
			mov [puzzle+edx], cl
			call posCurScreen
			mov [carac], cl
			inc moves
			call printch
			jmp fi
			

bucle:
		call moveCursorContinuo 
		jmp inici

fi:	

	mov esp, ebp
	pop ebp
	ret

moveTile endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continuo de fitxes. S'ha
; d'utilitzar la tecla 'm' per moure una fitxa i la tecla 's' per
; sortir del joc. 
;
; Variables utilitzades: 
;	carac2   : variable on s�emmagatzema el car�cter llegit
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;playTile:
playTile proc
	push ebp
	mov  ebp, esp

bucle:
call posCurScreen
call moveCursorContinuo
cmp [carac2], 's'
	je fi
	cmp	[carac2], 'm'
	jne bucle
	call MoveTile
	call updateMovements
	call checkVictory
	jmp bucle
fi: 
	mov esp, ebp
	pop ebp
	ret

playTile endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Comprovar si s'ha guanyat el joc. Es considera una vict�ria si totes
; les lletres estan ordenades i el forat est� al final.
;
; Si es compleixen les condicions de vict�ria, cridar a la funci� victory_C,
; que s'encarrega d'imprimir el missatge de vict�ria per pantalla.
;
; Variables utilitzades: 
; puzzle : matriu on es guarda l'estat del joc.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;checkVictory:
checkVictory proc
	push ebp
	mov  ebp, esp

	mov al, 'A'	
	mov esi, 0

bucle:	cmp puzzle[esi], al
		jne fi
		inc esi
		inc al
		cmp al, 'P'
		jne bucle
		call victory_C

fi:

	mov esp, ebp
	pop ebp
	ret

checkVictory endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Actualitzar el nombre de moviments realitzats, �s a dir, imprimir el 
; nou valor de la variable moves.
; Imprimir el nou valor a la posici� indicada (rowScreen = 3, colScreen = 57), 
; per� s'ha d'imprimir amb dues xifres (amb un zero davant si �s menor a 10).
; Per poder dividir saber les dues xifres del n�mero us recomanem usar la 
; instrucci� div.
;
; Variables utilitzades: 
; rowScreen : Fila de la pantalla
; colScreen : Columna de la pantalla
; moves : Comptador de moviments
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;updateMovements:
updateMovements proc
	push ebp
	mov  ebp, esp

	mov eax, [row]
	push eax
	mov al, [col]
	push eax

	mov [rowScreen], 2
	mov [colScreen], 59
	call gotoxy
	mov eax, [moves]
	mov edx, 0
	mov ecx, 10
	div ecx
	add dx, '0'
	mov [carac], dl
	call printch

	mov [rowScreen], 2
	mov [colScreen], 58
	call gotoxy
	add ax, '0'
	mov [carac], al
	call printch

	pop eax
	mov [col], al
	pop eax
	mov [row], eax


	mov esp, ebp
	pop ebp
	ret

updateMovements endp

END