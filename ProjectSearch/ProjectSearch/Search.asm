.386 
.model flat,stdcall 
option casemap:none 
include \masm32\include\windows.inc 
include \masm32\include\user32.inc 
includelib \masm32\lib\user32.lib
include \masm32\include\kernel32.inc 
includelib \masm32\lib\kernel32.lib
include \masm32\include\masm32.inc
include \masm32\include\masm32rt.inc ;hace llamada a la hora del sistema
; librerias
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
include \masm32\macros\macros.asm
; incluir macros
include \Macros\macros.lib

.DATA
bytesRead DWORD ?
FileName db "C:\keylogger\test.txt",NULL
BadText db "Its not ok",0
OkText db "Its ok",0
BytesRead dd 30
BytesWritten dd 20
contador dd 0
contador2 dd 0,0
vueltas DWORD 200
;format db 'You pressed %s',10,0
thechar DWORD 0, 0
.DATA?
fileHandle HANDLE ?
hFile HANDLE ?
hFile2 HANDLE ?
hReadFrom dd ?
hWriteTo dd ?
Buffer Byte 5000 DUP(?)
NumberOfBytesWritten DWORD ?
NumberOfBytesRead DWORD ?
fechabuf DB 10 DUP (?)
lecturabuf DW 50 dup(0)
entradabuf DW 50 dup(0)
letra DWORD 0
Sfile HANDLE 0
temp DWORD ?
temp2 DWORD ?
temp3 DWORD ?
num1 DB ?
XYPos COORD <0,0>
XPos WORD ?
YPos WORD ?
consoleInfo CONSOLE_SCREEN_BUFFER_INFO <>
cont DD 0
cellsWritten DWORD ?
horabuf DB 10 DUP (?)
	num DWORD ?
	valor DWORD ?
.const
MEMORYSIZE equ 65535

;---------------------------------escribir apend archivo----------------------------------------------------------
	
;--------------------------------crear Archivo-----------------------------------------------------------------------------
crearArchivo macro contenido1
    invoke CreateFile,addr FileName,GENERIC_READ OR GENERIC_WRITE,FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
    mov hFile,eax
	Invoke WriteFile, hFile, addr contenido1, BytesRead, Addr BytesWritten, NULL	; escribir en el archivo 
	endm


.CODE
start: 


main PROC
	XOR ESI, ESI
	XOR EBX, EBX
	MOV hFile, EBX
	MOV BytesRead, 200

	;Lectura del archivo
	invoke CreateFile,addr FileName,GENERIC_READ OR GENERIC_WRITE,FILE_SHARE_READ OR FILE_SHARE_WRITE, NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
    mov hFile,eax
	invoke GetFileSize,eax,0
	MOV BytesRead, EAX
	invoke ReadFile, hFile, OFFSET Buffer, BytesRead, ADDR NumberOfBytesRead,0
	invoke CloseHandle,hFile

	;Obtencion del Handle de la consola
	INVOKE GetStdHandle,STD_OUTPUT_HANDLE
	mov hFile2,eax
	XOR EAX, EAX

	;Obtencion de los valores de la posicion del cursor de consola
	INVOKE GetConsoleScreenBufferInfo, hFile2, ADDR consoleInfo
	MOV AX, consoleInfo.dwCursorPosition.x
	MOV XPos, AX
	XOR EAX, EAX
	MOV AX, consoleInfo.dwCursorPosition.y
	MOV YPos, AX

	;Opcion de ver o no el contenido del archivo
	print "Desea ver los Contenidos del Archivo? (y/n)", 13, 10
	invoke crt__getch
	mov thechar, eax
	printf("%c",eax,eax)
	MOV EAX, thechar
	CMP eax, 110
	JE SaltarEscritura
	CMP eax, 121
	JE HacerEscritura
	JNE TeclaIncorrecta
	TeclaIncorrecta:
	print "La tecla ingresada no es y/n", 13, 10
	JMP Fin
	HacerEscritura:
	printf("\n",eax,eax)
	imprimirArreglo Buffer, BytesRead
	SaltarEscritura:
	;INVOKE WriteConsoleOutputCharacter,
	;hFile2, ADDR Buffer, BytesRead,
	;xyPos, ADDR cellsWritten

	;Ingreso de la palabra clave a buscar
	printf("\n",eax,eax)
	print "Ingrese la cadena que desea buscar", 13, 10
	LEA ESI, entradabuf
	XOR EBX, EBX
    @@:
        invoke crt__getch
		mov thechar, eax
		MOV [ESI], eax
		printf("%c",eax,eax)
		INC ESI
		INC cont
		xor eax,eax
		MOV eax, thechar
		CMP eax, 13
		JE Seguir
    jmp @B
    ret
	
	;Comparacion de arreglos de lectura de archivo y entrada de palabra clave
	Seguir:
	printf("\n",eax,eax)
	XOR ESI, ESI
	XOR EDI, EDI
	XOR EBX, EBX
	XOR EAX, EAX
	MOV EDI, OFFSET Buffer
	LEA ESI, entradabuf
	MOVZX EAX, BYTE PTR [EDI]
	MOV temp2, EAX
	MOVZX EBX, BYTE PTR [ESI]
	MOV temp, EBX
	CMP EBX, temp2
	JE Iguales
	JNE Siguiente

	Iguales:
	XOR EBX, EBX
	INC ESI
	MOVZX EBX, BYTE PTR [ESI]
	MOV temp, EBX
	MOV EBX, temp
	CMP EBX, 13
	JE FinCadena
	XOR EAX, EAX
	INC EDI
	MOVZX EAX, BYTE PTR [EDI]
	MOV temp2, EAX
	XOR EAX, EAX
	MOV EAX, temp2
	CMP temp, EAX
	JE Iguales
	JNE Reiniciar

	Siguiente:
	INC EDI
	MOVZX EAX, BYTE PTR [EDI]
	MOV temp2, EAX
	CMP EAX, 0
	JE Paso2
	CMP EAX, 32
	JE Paso2
	CMP EAX, 27
	JE FinBuf
	CMP EAX, temp
	JE Iguales
	JNE Siguiente

	Reiniciar:
	XOR ESI, ESI
	LEA ESI, entradabuf
	MOVZX EBX, BYTE PTR [ESI]
	MOV temp, EBX
	JMP Siguiente

	FinCadena:
	INC EDI
	MOVZX EAX, BYTE PTR [EDI]
	CMP EAX, 13
	JE EscribirFH
	JNE FinCadena

	Paso2:
	INC EDI
	MOVZX EAX, BYTE PTR [EDI]
	MOV temp2, EAX
	CMP EAX, 13
	JE Paso3
	CMP EAX, temp
	JE Iguales
	JNE Siguiente

	Paso3:
	INC EDI
	MOVZX EAX, BYTE PTR [EDI]
	MOV temp2, EAX
	CMP EAX, 27
	JE FinBuf
	CMP EAX, temp
	JE Iguales
	JNE Siguiente

	FinBuf:
	printf("\n",eax,eax)
	print "No se ha encontrado la cadena", 13, 10
	JMP Fin

	EscribirFH:
	XOR EAX, EAX
	print "La cadena :"
	INVOKE GetConsoleScreenBufferInfo, hFile2, ADDR consoleInfo
	MOV AX, consoleInfo.dwCursorPosition.x
	MOV XPos, AX
	XOR EAX, EAX
	MOV AX, consoleInfo.dwCursorPosition.y
	MOV YPos, AX
	imprimirArreglo3 entradabuf, cont
	print "Fue ingresada el", 13, 10
	INC EDI
	XOR EAX, EAX
	INVOKE GetConsoleScreenBufferInfo, hFile2, ADDR consoleInfo
	MOV AX, consoleInfo.dwCursorPosition.x
	MOV XPos, AX
	XOR EAX, EAX
	MOV AX, consoleInfo.dwCursorPosition.y
	MOV YPos, AX
	escribirFechaBusqueda
	JMP Fin
	
	Fin:
	INVOKE StdIn, ADDR entradabuf, 50
	INVOKE ExitProcess, 0
	main ENDP
end start