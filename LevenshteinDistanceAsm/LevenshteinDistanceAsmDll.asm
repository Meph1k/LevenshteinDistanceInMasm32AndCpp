;-------------------------------------------------------------------------
.686
.MODEL FLAT, STDCALL
OPTION CaseMap:None
.MMX
.XMM
OPTION CASEMAP:NONE
INCLUDE \masm32\include\windows.inc

.data
cost_array1 DWORD 0, 1, 1
registers_array DWORD 3 dup (?)

.CODE
DllEntry PROC hInstDLL:HINSTANCE, reason:DWORD, reserved1:DWORD
 mov eax, TRUE
 ret
DllEntry ENDP
;-------------------------------------------------------------------------
; This is a macro which is used to determine
; which one of the three values is the lowest one
;-------------------------------------------------------------------------
FindMinimum macro x, y, z
mov eax, x
mov ecx, y
mov ebx, z

cmp eax, ecx
jle eaxless
cmp ecx, ebx
jle ecxless
jmp ebxleast

ecxless:
cmp ecx, eax
jle ecxleast
jmp eaxleast

eaxless:
cmp eax, ebx
jle eaxleast
jmp ebxleast

eaxleast:
jmp endleast

ecxleast:
mov eax, ecx
jmp endleast

ebxleast:
mov eax, ebx

endleast:

endm

;---------------------------------------------------------------
; This is a simple macro used to determine
; which one of the three values is the lowest one
; It is the same as above but we have to use it twice in the
; main function so this one also exists
;---------------------------------------------------------------

FindMinimum2 macro x, y, z
mov eax, x
mov ecx, y
mov ebx, z

cmp eax, ecx
jle eaxless2
cmp ecx, ebx
jle ecxless2
jmp ebxleast2

ecxless2:
cmp ecx, eax
jle ecxleast2
jmp eaxleast2

eaxless2:
cmp eax, ebx
jle eaxleast2
jmp ebxleast2

eaxleast2:
jmp endleast2

ecxleast2:
mov eax, ecx
jmp endleast2

ebxleast2:
mov eax, ebx

endleast2:

endm

;--------------------------------------------------------------------------------------
; This is a function which is used to initialize the matrix with 0..n in the first row
; and 0..n in the first column
;--------------------------------------------------------------------------------------

initializeLevMatrix proc levTab: PTR DWORD, len1: DWORD, len2: DWORD
mov edi, levTab
xor eax, eax
mov [edi], eax
mov ebx, eax
mov ecx, len2
mov edx, len1
inc ecx
init1:
cmp eax, edx
jge init2
inc eax
mov ebx, eax
imul ebx, ecx
imul ebx, 4
mov  [edi + ebx], eax
jmp init1
init2:
xor eax, eax
mov ecx, len2
mov edi, levTab
loop1:
cmp eax, ecx
jge finish
inc eax
mov ebx, eax
mov  [edi + ebx * 4], eax
jmp loop1
finish:

ret
initializeLevMatrix endp

;---------------------------------------------------------
; This function is used to count diagonally in the matrix
;---------------------------------------------------------

countDiagonally proc levTab: PTR DWORD, index: DWORD, s1: PTR DWORD, s2: PTR DWORD, len1: DWORD

LOCAL index_local: DWORD, len1_local: DWORD

mov edi, OFFSET cost_array1
mov dword ptr [edi], 0

mov edi, levTab
mov edx, len1
mov len1_local, edx
inc edx
mov ecx, index
mov index_local, ecx
dec ecx
imul edx, 4
;first
imul edx, ecx
imul ecx, 4
add edx, ecx
mov eax, [edi + edx]
;count cost--------------------
mov edx, index
dec edx

mov esi, s1
mov ebx, [esi + edx * 4]
mov edi, s2
mov ecx, [edi + edx * 4]
cmp ebx, ecx
je equal
mov edi, OFFSET cost_array1
mov dword ptr [edi], 1

equal:

mov edi, levTab

;second
;--setup before inserting
mov edx, len1_local
inc edx
mov ecx, index
dec ecx
imul edx, 4
imul edx, ecx
imul ecx, 4
add edx, ecx
add edx, 4
;--end setup
mov ebx, [edi + edx]

;third
;--setup before inserting
mov edx, len1_local
inc edx
imul edx, 4
mov ecx, index
imul edx, ecx
imul ecx, 4
add edx, ecx
sub edx, 4
;--end setup
mov ecx, [edi + edx]


mov edi, offset registers_array
mov dword ptr [edi], eax
mov dword ptr [edi + 4], ebx
mov dword ptr [edi + 8], ecx
lea edx, [edi]
movups xmm0, [edx]
mov edi, offset cost_array1
lea edx, [edi]
movups xmm1, [edx]
paddd xmm0, xmm1
mov edx, edi
mov edx, offset registers_array
movups [edx], xmm0

FindMinimum [edx], [edx + 4], [edx + 8]
mov edi, levTab

mov edx, len1_local
inc edx
imul edx, 4
mov ecx, index_local
imul edx, ecx
imul ecx, 4
add edx, ecx

mov [edi + edx], eax

ret
countDiagonally endp

;-------------------------------------------------------------------------------
; This is the main function. It is used to calculate the Levenshtein values
; in rows and columns
;-------------------------------------------------------------------------------

countLevenshteinDistance proc levTable: PTR DWORD, s1: PTR DWORD, s2: PTR DWORD, dir: DWORD, index: DWORD, len1: DWORD, len2: DWORD

LOCAL len1tmp: DWORD, len2tmp: DWORD, tmpIndex: DWORD, index_local: DWORD, edxTmp: DWORD, len1_local: DWORD, len2_local: DWORD

mov edi, OFFSET cost_array1
mov dword ptr [edi], 0

mov eax, len1
mov len1_local, eax
imul eax, 4
mov len1tmp, eax
mov eax, len2
mov len2_local, eax
mov eax, index
mov index_local, eax
dec eax
mov tmpIndex, eax
mov edi, levTable

mov eax, dir
cmp eax, 1
jne columns
mov edx, index_local

loop1:
cmp edx, len1_local
jge finish

;first value
mov edxTmp, edx

mov edx, index_local
dec edx
mov ecx, len1tmp
add ecx, 4
imul edx, ecx
mov ecx, edxTmp
imul ecx, 4
add edx, ecx
mov eax, [edi + edx]

mov edx, edxTmp
;count cost------------------------
mov edi, s1
mov edxTmp, edx
mov edx, tmpIndex
mov ebx, [edi + edx * 4]
mov edi, s2
mov edx, edxTmp
mov ecx, [edi + edx * 4]
mov edi, OFFSET cost_array1
mov dword ptr [edi], 0
cmp ebx, ecx
je equal
mov edi, OFFSET cost_array1
mov dword ptr [edi], 1
equal:
mov edi, levTable
;end count cost--------------------

;second
mov edxTmp, edx

mov edx, index_local
dec edx
mov ecx, len1tmp
add ecx, 4
imul edx, ecx
mov ecx, edxTmp
imul ecx, 4
add edx, ecx
mov ebx, [edi + edx]

mov ebx, [edi + edx]
mov edx, edxTmp

;third
mov edxTmp, edx

mov edx, len1tmp
add edx, 4
mov ecx, index_local
imul edx, ecx
mov ecx, edxTmp
imul ecx, 4
add edx, ecx

mov ecx, [edi + edx]
mov edx, edxTmp

mov edi, offset registers_array
mov dword ptr [edi], eax
mov dword ptr [edi + 4], ebx
mov dword ptr [edi + 8], ecx
lea edx, [edi]
movups xmm0, [edx]
mov edi, offset cost_array1
lea edx, [edi]
movups xmm1, [edx]
paddd xmm0, xmm1
mov edx, edi
mov edx, offset registers_array
movups [edx], xmm0

FindMinimum [edx], [edx + 4], [edx + 8]

mov edx, edxTmp

;put values-------------------------
mov edxTmp, edx

mov ebx, len1tmp
add ebx, 4
mov ecx, index_local
imul ebx, ecx
mov ecx, edxTmp
imul ecx, 4
add ebx, ecx
add ebx, 4

mov edi, levTable
;mov eax, ebx ;for now
mov [edi + ebx], eax
mov edx, edxTmp
;end putting values ----------------
inc edx
jmp loop1

;----------------cols----------------
columns:

mov eax, len2_local
imul eax, 4
mov len2tmp, eax

mov edx, index_local

loop2:
cmp edx, len2_local
jge finish

;first value
mov edxTmp, edx

mov edx, len1tmp
add edx, 4
mov ecx, edxTmp
imul edx, ecx
mov ecx, index
dec ecx
imul ecx, 4
add edx, ecx

mov eax, [edi + edx]
mov edx, edxTmp
;count cost------------------------
mov edi, s2
mov edxTmp, edx
mov edx, tmpIndex
mov ebx, [edi + edx * 4]
mov edi, s1
mov edx, edxTmp
mov ecx, [edi + edx * 4]
mov edi, OFFSET cost_array1
mov dword ptr [edi], 0
cmp ebx, ecx
je equal2
mov edi, OFFSET cost_array1
mov dword ptr [edi], 1
equal2:
mov edi, levTable
;end count cost--------------------


mov edx, edxTmp

;second
mov edxTmp, edx

mov edx, len1tmp
add edx, 4
mov ecx, edxTmp
imul edx, ecx
mov ecx, index
dec ecx
imul ecx, 4
add edx, ecx
add edx, 4

mov ebx, [edi + edx]
mov edx, edxTmp

;third
mov edxTmp, edx

mov edx, len1tmp
add edx, 4
imul edx, edxTmp
mov ecx, index
imul ecx, 4
add edx, ecx
add edx, len1tmp

mov ecx, [edi + edx]
mov edx, edxTmp

mov edi, offset registers_array
mov dword ptr [edi], eax
mov dword ptr [edi + 4], ebx
mov dword ptr [edi + 8], ecx
lea edx, [edi]
movups xmm0, [edx]
mov edi, offset cost_array1
lea edx, [edi]
movups xmm1, [edx]
paddd xmm0, xmm1
mov edx, edi
mov edx, offset registers_array
movups [edx], xmm0

FindMinimum2 [edx], [edx + 4], [edx + 8]


mov edx, edxTmp

;put values-------------------------
mov edxTmp, edx

mov edx, len1tmp
add edx, 4
imul edx, edxTmp
mov ecx, index
imul ecx, 4
add edx, ecx
add edx, len1tmp
add edx, 4

mov edi, levTable
mov [edi + edx], eax
mov edx, edxTmp
;end putting values ----------------
inc edx
jmp loop2

;-----end cols------------

finish:

ret
countLevenshteinDistance endp

END DllEntry
;-------------------------------------------------------------------------