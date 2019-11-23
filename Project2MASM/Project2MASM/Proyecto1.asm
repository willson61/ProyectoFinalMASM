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
; incluir macros
include \Macros\macros.lib

.DATA
FileName db "C:\keylogger\test.txt",NULL
BadText db "Its not ok",0
OkText db "Its ok",0
BytesRead dd 30
BytesWritten dd 20
contador dd 0
contador2 dd 0,0
thechar DWORD 0, 0
enterT db 0,13
enterT2 db 13
formatofecha DB "dd/MM/yyyy",0
formatohora DB " hh:mm:ss",0
.DATA?
fileHandle HANDLE ?
hFile HANDLE ?
hFile2 HANDLE ?
hReadFrom dd ?
hWriteTo dd ?
Buffer BYTE 1000 DUP(?)
NumberOfBytesRead DWORD ?
NumberOfBytesWritten DWORD ?
fechabuf DB 10 DUP (?)
letrasbuf DW 50 dup(0)
letra DW 0
horabuf DB 10 DUP (?)
	num DWORD ?
	valor DWORD ?
.const
MEMORYSIZE equ 65535


.CODE
start: 


main PROC
	XOR ESI, ESI
	XOR EBX, EBX
    @@:
		;Espera entrada del teclado
        invoke crt__getch
		mov thechar, eax
		xor eax,eax
		xor edx,edx
		xor ecx,ecx
		xor ebx,ebx
		;Verifica si se ingreso Enter
		MOV eax, thechar
		CMP eax, 13
		JE Imprimir
		JNE Seguir
		;DEC ESI

		;Imprime la fecha y hora en caso de que se imprimio enter
		Imprimir:
		XOR EBX, EBX
		MOV thechar, 0
		escribirArchivoEnter enterT
		GenerarFecha fechabuf, horabuf
		MOV BytesRead, 10
		MOV BytesWritten, 10
		escribirArchivoFechaHora fechabuf, BytesRead, BytesWritten
		MOV BytesRead, 9
		MOV BytesWritten, 9
		escribirArchivoFechaHora horabuf, BytesRead, BytesWritten
		escribirArchivoEnter enterT

		;Verifica si se presiono espacio
		Seguir:
		MOV eax, thechar
		CMP eax, 32
		JE Imprimir2
		JNE Seguir2

		;Imprime fecha y hora en caso de que se presiono espacio
		Imprimir2:
		XOR EBX, EBX
		MOV thechar, 0
		escribirArchivoEnter enterT
		GenerarFecha fechabuf, horabuf
		MOV BytesRead, 10
		MOV BytesWritten, 10
		escribirArchivoFechaHora fechabuf, BytesRead, BytesWritten
		MOV BytesRead, 9
		MOV BytesWritten, 9
		escribirArchivoFechaHora horabuf, BytesRead, BytesWritten
		escribirArchivoEnter enterT

		;Solo imprime el caracter al archivo en caso de que no haya sido enter o espacio
		Seguir2:
		MOV EAX, thechar
		CMP EAX, 0
		JE Seguir3
		escribirArchivoCaracter thechar
		;Se sale del programa cuando presiona Esc
		MOV EAX, thechar
		CMP EAX, 27
		JE Fin

		Seguir3:
    jmp @B
    ret
	Fin:
	print "Fin del programa", 13, 10	
	INVOKE StdIn, ADDR num, 50
	INVOKE ExitProcess, 0
	main ENDP
end start
