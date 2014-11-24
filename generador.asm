
;~#######################################MACROS############################################################
%macro Escribir 2 
                        ;este macro es el encargado de imprimir en pantalla toma dos argumentos el contenido y el largo
      push  ecx
      push  edx
      mov   eax, 4
      mov   ebx, 1
      mov   ecx, %1
      mov   edx, %2
      pop   edx
      pop   ecx
  
      int   80h
      
   %endmacro
;##############################################section DATA ##############################3
SECTION     .data
Texto1:          db      "Ingrese la letra",10,"A para 100 bases",10, "B para 1000 bases",10,"C para 20000 bases",10, "D para 1000000 bases",10
Texto1Len:        equ     $-Texto1
filename_msg: db 'Ingrese el nombre del archivo a crear: ', 0
filename_msg_Len:  equ		$-filename_msg
;###########################################section buffer ########################################
SECTION     .bss
Buffer        resb  1     ;guarda la letra del largo
BuffLen         equ     $-Buffer
Texto        resb 10000000   ;guarda el texto generado aleatoriamente
TextoLen   equ  $-Texto
Time		resd	1				; salva el ciclo del procesador
Random1		resd	1	  ;numero random
filename resb 10                  ;guarda el nombre en bruto
filenameLen equ     $-filename
nombreAux resb 10                 ;contiene el nombre final con el .adn
nombreAuxLen equ $-nombreAux
;############################################ section text #########################################
SECTION     .text
global      _start
     
_start:
  ;imprime el texto de inicio
     mov ecx, filename_msg   
     mov edx, filename_msg_Len
     Escribir ecx, edx           ;imprime el mensaje inicial  
     
     mov eax, 3
     mov ebx, 0
     mov ecx, filename              ;captura el nombre del archivo
     mov edx, filenameLen
     int 80h
     mov ecx,filename      ;prepara para agregar el .adn  
     mov ebx,eax
     dec ebx
     xor edi,edi
     mov edi,0
     call cicloNom     ;agrega el .adn
    
     
     xor edi, edi
    mov     ecx, Texto1      ;imprime el texto de inicio
    mov     edx, Texto1Len
    Escribir ecx, edx         
    call ReadText            ;Lee el numero de bases dependiendo la letra salta al largo necesario 
    cmp byte[Buffer],"A"
    je EntradaA
    cmp byte[Buffer],"B"
    je EntradaB
    cmp byte[Buffer],"C"
    je EntradaC
    cmp byte[Buffer],"D"
    je EntradaD
    jmp Exit
cicloNom:
       cmp ebx,0
       je moverADN   ;condicion de terminacion
       mov ah,byte [ecx+edi]   ;copia el caracter al ah
       mov byte[nombreAux+edi], ah
       inc edi ;aumenta el contador
       dec ebx  ;sin esto hacia un caracter no ascii irreconocible asi que con esto se elimina 
       jmp cicloNom
       
moverADN:   ;le mueve el .adn al nombre
     
     mov byte[nombreAux+edi],"."
     inc edi
     mov byte[nombreAux+edi],"a"
     inc edi
     mov byte[nombreAux+edi],"d"
     inc edi
     mov byte[nombreAux+edi],"n"
     ret
   
    
EntradaA:  ;dependiendo la letra que se ingrese se le mueve al edi contador un numero diferente asi para todas las letras A,B,C,D
 mov edi,100   ;si es a le mueve 100
 mov esi,0
 mov byte[Texto+esi],"^"  ;este caracter es necesario para el programa 2 va en el inicio del archivo
 inc esi
 jmp Random
    
EntradaB:
  mov edi,1000
  mov esi,0
  mov byte[Texto+esi],"^"
  inc esi
  jmp Random
    
EntradaC:
 mov edi,20000
  mov esi,0
  mov byte[Texto+esi],"^"
  inc esi
  jmp Random
    
EntradaD:
    mov edi,1000000
    mov esi,0
    mov byte[Texto+esi],"^"
    inc esi

    jmp Random 
;###########################GENERADOR random#############################    
generadorRnd:		
; genera aleatoriamente del 0 al 52 ;;
	call	Tiempo						; agrra la variable
	mov	eax, 3						;guarda 3 en el eax sirve para decir cuantos valores difetentes se quieren desde 0 hasta el numero
	and	eax, [Time]					; hace un and entre 3 y el tiempo para tener 0,1,2,3 aleatoriamente
	mov	[Random1], eax				; guarda esa variable en random1

 ret
Tiempo:

	rdtsc                      ;devuelve en el eax el ciclo del procesador
	mov	[Time], eax					; mueve el valor al buffer time			
	ret
	
Random:
cmp edi,0                    ;cmp el edi contador con 0 para saber si ya se tiene el numero de bases deseado
je Archivo                   ;si es asi salta a archivo
call generadorRnd            ;si no genera un nuevo numero aleatorio
mov eax,[Random1]            ;mueve el numero al eax
cmp eax,0                    ;compara el eax con 0,1,2,3 dependiendo el valor salta a un cargar diferente
je cargarA
cmp eax,1
je cargarC
cmp eax,2
je cargarT
cmp eax,3
je cargarG
jmp Random

cargarA:
mov byte[Texto+esi],"A"  ;mueve a texto un buffer la letra A C T O G dependiendo el cargar que sea incrementa el contador de buffer y decrementa el contador general 
inc esi
dec edi
jmp Random
cargarC:
mov byte[Texto+esi],"C"
inc esi
dec edi
jmp Random
cargarT:
mov byte[Texto+esi],"T"
inc esi
dec edi
jmp Random
cargarG:
mov byte[Texto+esi],"G"
inc esi
dec edi
jmp Random

Archivo:
  

	mov eax, 8                        ;interrupcion 8 es para escribir archivos 
	mov ebx, nombreAux                ;nombre aux contiene el nombre del archivo a crear .adn
	mov ecx, 644O                   ;los permisos necesarios para crear el archivo
	int 80h          
		
	mov ebx, eax                      ;mueve a el ebx el nombre del archivo o mejor dicho su direccion
	mov eax, 4                        ;la interrupcion 4 que es de escribir
	mov ecx, Texto                    ;mueve al archivo el buffer texto el cual contiene las bases aleatorias
	mov edx, TextoLen
	int 80h
		
	mov eax, 6
	int 80h
    
        jmp Exit
 

ReadText:
	
        mov eax, 3
	mov ebx, 0
	mov ecx, Buffer
	mov edx, BuffLen
	int 80h
        ret  
Exit: 
    mov     eax, 1
    xor     ebx, ebx
    int     80H
