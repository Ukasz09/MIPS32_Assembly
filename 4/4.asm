.data    
    opertaionChooseMsg: 	.asciiz "\n\nPodaj wybrana operacje: "
    menuMsg:			.asciiz "\n\n1) Wprowadzanie macierzy, \n2) Drukowanie macierzy, \n3) Dodawanie macierzy, \n4) Odejmowanie macierzy, \n5) Skalowanie macierzy \n6) Transpozycja macierzy \n7) Mnozenie macierzy"
    howManyMatrixMsg:		.asciiz "\nPodaj ilosc macierzy do dodania: "
    wrongDecisionMsg:		.asciiz "\nPodano bledne dane"
    closeDecisionMsg:		.asciiz "\nCzy chcesz zakonczyc program (0-nie): "
    howManyRowMsg:		.asciiz "\nPodaj ilosc wierszy: "
    howManyColumnsMsg:		.asciiz "Podaj ilosc kolumn: "
    readNumberMsg:		.asciiz "Podaj liczbe: "
    numberOfRowsMsg: 		.asciiz "\nWiersz nr. "
    numberOfMatrixMsg:		.asciiz "\nMacierz nr. "
    newLineMsg:			.asciiz "\n"
    leftBracketMsg:		.asciiz "["
    rightBracketMsg:		.asciiz "]"
    matrixChooseMsg:		.asciiz "Podaj numer macierzy: "
    scalarMsg:			.asciiz "Podaj skalar: "
    noOneMatrixMsg:		.asciiz "\nNie ma zadnych zapisanych macierzy"
    notEnoughMatrixMsg:		.asciiz "\nNie mozna wykonac operacji. Potrzeba minimum 2 maicerzy"
    incorectSizeMatrixMsg: 	.asciiz "\nNie mozna wykonac. Macierze maja rozne rozmiary"
    maxNumberOfMatrixMsg:	.asciiz "\nNie mozna dodac przekroczona ilosc macierzy do dodania"
    notCorrectMatrixesSizeMsg: .asciiz "\nNie mozna pomnozyc. Macierze maja rozne rozmiary"
    notAtLeastTwoMatrixMsg:	.asciiz "\nNie ma zapisanych przynajmniej dwoch macierzy"
    
    zero: .double 0.0 
.text
.globl _main

.macro print(%comunicate)    
    li $v0, 4       		
    la $a0, %comunicate 	
    syscall         		    
.end_macro

.macro println()
	li $v0, 4
	la $a0, newLineMsg
	syscall
.end_macro

_main:
	li $s0, 0 #ilsc wprowadzonych macierzy
	
   	_mainToRepete:
		li $t0, 1
		li $t1, 2
		li $t2, 3
		li $t3, 4
		li $t4, 5
		li $t5, 6
		li $t6, 7
	
		print(menuMsg)
		print(opertaionChooseMsg)
		jal _readIntNumber
	
		beq $v0, $t0, _writeMatrixesToStack
		beq $v0, $t1, _readMatrixesFromStack
		beq $v0, $t2, _addMatrixes
		beq $v0, $t3, _subMatrixes
		beq $v0, $t4, _scalingMatrix
		beq $v0, $t5, _transposeMatrix
		beq $v0, $t6, _multiplyMatrixes
		j _wrongDecision
		
#################################################################################################################

_readMatrixesFromStack:
	bnez $s0, atLeastOneMatrix
	
	noOneMatrix:
		print(noOneMatrixMsg)
	j _closeProgramDecision

	atLeastOneMatrix:
		bne $s0, 1, moreMatrix
	
		oneMatrix:
			li $t0, 0
			jal _moveStackPointerUp
			jal _readMatrix
			jal _moveStackPointerDown
			
		j _closeProgramDecision
	
		moreMatrix:
			print(matrixChooseMsg)
			jal _readIntNumber
			move $t0, $v0				#$t0 - numer macierzy
		
			bltz $t0, incorectNumberOfMatrix	#kontrola ujemnych
			bge $t0, $s0, incorectNumberOfMatrix	#kontrola numeru wiekszego niz dostepny
	
			jal _moveStackPointerUp
			jal _readMatrix
			jal _moveStackPointerDown

		j _closeProgramDecision
		
	incorectNumberOfMatrix:	
		print(wrongDecisionMsg)
	j _closeProgramDecision
	
#Uzywa t0
_moveStackPointerUp:
	li $t7, 0 		#t7 - ilosc bitow do ominiecia
	la $t6, ($ra) 		#t6 - tmp na ra
	sub $t1,$s0,$t0
	sub $t1, $t1,1		#t1 -ilosc matrixow do ominiecia
	
	#ominiecie odpowiedniej ilosci matrixow
	li $t4, 0 		#t4- iterator
	beqz $t1, endFor_stackUp	#nic nie przeskakujemy
	for_stackUp:
		lw $t2, ($sp) 	#t2 - ilosc kolumn
		add $sp, $sp, 4
		lw $t3, ($sp) 	#t3- ilosc wierszy
		add $sp, $sp, 4
		
			add $t7, $t7, 8
		
		mul $t5, $t2, $t3
		mul $t5, $t5, 4 	
		add $sp, $sp, $t5 #t5 -przesuniecie wskaznika stosu poprzedniego matrixa
		
			add $t7, $t7, $t5	
		
		add $t4, $t4, 1
		blt $t4, $t1, for_stackUp
	endFor_stackUp:
	
	la $ra, ($t6)
	jr $ra

#Uzywa: $t7
_moveStackPointerDown:
	la $t6, ($ra)		#t6 - tmp na ra
	
	sub $sp, $sp, $t7
	
	la $ra, ($t6)
	jr $ra

_readMatrix:
	la $t6, ($ra)

	lw $t0, ($sp) 	#t0 - ilosc kolumn
	add $sp, $sp, 4
	
	lw $t1, ($sp) 	#t1- ilosc wierszy
		
	mul $t3, $t0, $t1
	mul $t3, $t3, 4 	#t3 - ilosc bitow na stosie do przeskoczenia
	add $sp, $sp, $t3	#przesuniecie wskaznika stosu na poczatek matrixa

	li $t4, 0 	#t4 - iterator wierszy
	li $t5, 0 	#t5 - iterator kolumn
	for_readRows:
    		li $t5, 0
    		println()
    		
    		for_readColumns:
    			print(leftBracketMsg)
    			l.s $f12, ($sp)
    			add $sp, $sp, -4
    			jal _printFloatNumber
    			print(rightBracketMsg)
    	
    			add $t5, $t5, 1
    			blt $t5, $t0, for_readColumns
    		
    		add $t4, $t4, 1
    	blt $t4,$t1,for_readRows
	
	add $sp, $sp, -4 #powrot na ostatnio dodany element
	
	la $ra, ($t6)
	jr $ra

 _writeMatrixesToStack:
 	bge $s0, 10, maxNumberOfMatrix	#kontrola ilosci macierzy 
 
 	print(howManyMatrixMsg)
	jal _readIntNumber
	move $t0,$v0			#t0 - ilosc macierzy do wczytania	
	
	
	bltz $t0, _wrongDecision		#kontrola ujemnych wartosci	
	beqz $t0, _closeProgramDecision		#kontrola zerowych wartosci
	
	add $t1, $t0, $s0			#kontrola ilosci macierzy
	bgt $t1, 10, maxNumberOfMatrix
	
	li $t1, 0 			#t1 -iterator
	for_main:
		print(numberOfMatrixMsg)
		la $a0, ($s0)
		jal _printIntNumber
		println()
		
	  	jal _writeMatrix	
       		add $t1, $t1, 1
		blt $t1, $t0, for_main
	j _closeProgramDecision
	
	maxNumberOfMatrix:
		print(maxNumberOfMatrixMsg)
	j _closeProgramDecision
	
_writeMatrix:
	la $t6, ($ra)			# t6 - tmp na ra

  	print(howManyRowMsg)
  	jal _readIntNumber  	
	move $t2, $v0			#t2 - ilosc wierszy
	ble $t2, 0, _wrongDecision	#kontrola danych
    	
    	print(howManyColumnsMsg)
    	jal _readIntNumber
    	move $t3, $v0			#t3 - ilosc kolumn
    	ble $t3, 0, _wrongDecision	#kontrola danych
    	
    	li $t4, 0			#t4 -iterator wierszy
    	li $t5, 0			#t5 -iterator kolumn
    	for_writeRows:
    		li $t5, 0
    		
    		print(numberOfRowsMsg)
    		move $a0,$t4
    		jal _printIntNumber
    		println()
    		
    		for_writeColumns:
    			print(readNumberMsg)
    			jal _readFloatNumber
    			add $sp, $sp, -4
    			swc1 $f0, ($sp)
    			
    			add $t5, $t5, 1
    			blt $t5, $t3, for_writeColumns
    		
    		add $t4, $t4, 1
    	blt $t4,$t2,for_writeRows
    	
    	#wrzucenie na stos ilosc wierszy i kolumn
    	add $sp, $sp, -4
    	sw $t2, ($sp)
    	add $sp, $sp, -4
    	sw $t3, ($sp)
    	
add $s0, $s0, 1    #inc ilosc matrixow	
la $ra, ($t6)    			
jr $ra

_scalingMatrix:
	bnez $s0, atLeastOneMatrixScal
	
	noOneMatrixScal:
		print(noOneMatrixMsg)
	j _closeProgramDecision
	
	atLeastOneMatrixScal:
		li $t0, 0
		beq $s0, 1, oneMatrixScal
		
		moreMatrixScal:
			print(matrixChooseMsg)
			jal _readIntNumber
			move $t0, $v0			#$t0 - numer macierzy
			
			bltz $t0, incorectNumberOfMatrix	#kontrola ujemnych
			bge $t0, $s0, incorectNumberOfMatrix	#kontrola numeru wiekszego niz dostepny
			
		oneMatrixScal:
			print(scalarMsg)
			jal _readFloatNumber
		
			jal _moveStackPointerUp
			jal _mulByScalar
			jal _moveStackPointerDown
	j _closeProgramDecision
	
#Uzywa f0
_mulByScalar:
	la $t6, ($ra)	#t6 - tmp na ra

	lw $t0, ($sp) 	#t0 - ilosc kolumn
	add $sp, $sp, 4
	
	lw $t1, ($sp) 	#t1- ilosc wierszy
		
	mul $t3, $t0, $t1
	mul $t3, $t3, 4 	#t3 - ilosc bitow na stosie do przeskoczenia
	add $sp, $sp, $t3	#przesuniecie wskaznika stosu na poczatek matrixa

	li $t4, 0 	#t4 - iterator wierszy
	li $t5, 0 	#t5 - iterator kolumn
	for_scalarRows:
    		li $t5, 0
    		println()
    		
    		for_scalarColumns:
    			print(leftBracketMsg)
    			
    			l.s $f12, ($sp)
    			mul.s $f12, $f12, $f0
    			swc1 $f12, ($sp)
    			jal _printFloatNumber
    			print(rightBracketMsg)
    			add $sp, $sp, -4
    	
    			add $t5, $t5, 1
    			blt $t5, $t0, for_scalarColumns
    		
    		add $t4, $t4, 1
    	blt $t4,$t1,for_scalarRows
	
	println()
	add $sp, $sp, -4 #powrot na ostatnio dodany element
	
	la $ra, ($t6)
	jr $ra

_addMatrixes:	
	blt $s0,2,notEnoughMatrix			#kontrola wymaganej ilosc matrixow

	print(matrixChooseMsg)
	jal _readIntNumber
	move $s1, $v0					#$s1 - numer macierzy 1
	
		bltz $s1, incorectNumberOfMatrix	#kontrola ujemnych
		bge $s1, $s0, incorectNumberOfMatrix	#kontrola numeru wiekszego niz dostepny
	
		move $t0,$s1				#TMP do kontroli wielkosci macierzy
		jal _moveStackPointerUp
		lw $s3, ($sp)					
		lw $s4, 4($sp)						
		jal _moveStackPointerDown	
																																																																																			
	print(matrixChooseMsg)
	jal _readIntNumber
	move $s2, $v0					#s2 - numer macierzy 2
	
		bltz $s2, incorectNumberOfMatrix	#kontrola ujemnych
		bge $s2, $s0, incorectNumberOfMatrix	#kontrola numeru wiekszego niz dostepny
	
	move $t0,$s2
	jal _moveStackPointerUp
	lw $s5, ($sp)					#s5 - ilosc kolumn
	lw $s6, 4($sp)					#s6 - ilosc wierszy
	jal _moveStackPointerDown
	
		bne $s3, $s5, incorectSize		#kontrola wielkosci macierzy
		bne $s4, $s6, incorectSize		#kontrola wielkosci macierzy
	
	li $s3, 0					#s3 - iterator wierszy, s4 - iterator kolumn, 
	li $s4, 0
	mul $t8, $s5, $s6
	mul $t8, $t8, 4
	add $t8, $t8, 4					#t8 -tmp 	
	for_addRows:
		println()
		li $s4, 0
		for_addColumns:	
			move $t0, $s1
			jal _moveStackPointerUp
			add $sp, $sp, $t8
			l.s $f12, ($sp)
			sub $sp, $sp, $t8
			jal _moveStackPointerDown
			
			move $t0, $s2
			jal _moveStackPointerUp
			add $sp, $sp, $t8
			l.s $f1, ($sp)			#f1 -tmp
			add.s $f12, $f12, $f1
			sub $sp, $sp, $t8
			jal _moveStackPointerDown
			
			print(leftBracketMsg)
			jal _printFloatNumber
			print(rightBracketMsg)
		
			add $t8, $t8, -4
			add $s4, $s4, 1
			blt $s4,$s5, for_addColumns
		
		add $s3, $s3, 1
		blt $s3,$s6,for_addRows
												
	j _closeProgramDecision
	
	notEnoughMatrix:
		print(notEnoughMatrixMsg)
	j _closeProgramDecision
	
	incorectSize:
		print(incorectSizeMatrixMsg)
	j _closeProgramDecision	
	
_subMatrixes:
	blt $s0,2,notEnoughMatrix			#kontrola wymaganej ilosc matrixow

	print(matrixChooseMsg)
	jal _readIntNumber
	move $s1, $v0					#$s1 - numer macierzy 1
	
		bltz $s1, incorectNumberOfMatrix	#kontrola ujemnych
		bge $s1, $s0, incorectNumberOfMatrix	#kontrola numeru wiekszego niz dostepny
	
		move $t0,$s1				#TMP do kontroli wielkosci macierzy
		jal _moveStackPointerUp
		lw $s3, ($sp)					
		lw $s4, 4($sp)						
		jal _moveStackPointerDown	
	
	print(matrixChooseMsg)
	jal _readIntNumber
	move $s2, $v0					#s2 - numer macierzy 2
	
		bltz $s2, incorectNumberOfMatrix	#kontrola ujemnych
		bge $s2, $s0, incorectNumberOfMatrix	#kontrola numeru wiekszego niz dostepny
	
	move $t0,$s2
	jal _moveStackPointerUp
	lw $s5, ($sp)					#s5 - ilosc kolumn
	lw $s6, 4($sp)					#s6 - ilosc wierszy
	jal _moveStackPointerDown
	
		bne $s3, $s5, incorectSize		#kontrola wielkosci macierzy
		bne $s4, $s6, incorectSize		#kontrola wielkosci macierzy
	
	li $s3, 0					#s3 - iterator wierszy, s4 - iterator kolumn, 
	li $s4, 0
	mul $t8, $s5, $s6
	mul $t8, $t8, 4
	add $t8, $t8, 4					#t8 -tmp 	
	for_subRows:
		println()
		li $s4, 0
		for_subColumns:	
			#mtc1 $s1, $f1	#mtc1
			#mtc1 $s2, $f2	#mtc1
			move $t0, $s1
			jal _moveStackPointerUp
			add $sp, $sp, $t8
			l.s $f12, ($sp)
			sub $sp, $sp, $t8
			jal _moveStackPointerDown
			
			move $t0, $s2
			jal _moveStackPointerUp
			add $sp, $sp, $t8
			l.s $f1, ($sp)			#f1 -tmp
			sub.s $f12, $f12, $f1
			sub $sp, $sp, $t8
			jal _moveStackPointerDown
			
			print(leftBracketMsg)
			jal _printFloatNumber
			print(rightBracketMsg)
		
			add $t8, $t8, -4
			add $s4, $s4, 1
			blt $s4,$s5, for_subColumns
		
		add $s3, $s3, 1
		blt $s3,$s6,for_subRows
												
	j _closeProgramDecision	
###########################
_transposeMatrix:
	bnez $s0, atLeastOneMatrixTrans
	
	noOneMatrixTrans:
		print(noOneMatrixMsg)
	j _closeProgramDecision
	
	atLeastOneMatrixTrans:
		li $t0, 0
		beq $s0, 1, oneMatrixTrans
		
		moreMatrixTrans:
			print(matrixChooseMsg)
			jal _readIntNumber
			move $t0, $v0			#$t0 - numer macierzy
			
			bltz $t0, incorectNumberOfMatrix	#kontrola ujemnych
			bge $t0, $s0, incorectNumberOfMatrix	#kontrola numeru wiekszego niz dostepny
			
		oneMatrixTrans:
			jal _moveStackPointerUp
			jal transpose
			jal _moveStackPointerDown
	j _closeProgramDecision
	
#Uzywa f0
transpose:
	la $t6, ($ra)	#t6 - tmp na ra

	lw $t0, ($sp) 	#t0 - ilosc kolumn
	move $s6, $t0	#s6 - ilosc kolumn
	add $sp, $sp, 4
	
	lw $t1, ($sp) 	#t1- ilosc wierszy
		
	mul $t3, $t0, $t1
	mul $t3, $t3, 4 	#t3 - ilosc bitow na stosie do przeskoczenia
	add $sp, $sp, $t3	#przesuniecie wskaznika stosu na poczatek matrixa

	li $t4, 0 	#t4 - iterator wierszy
	li $t5, 0 	#t5 - iterator kolumn
	for_transposeColumns:
    		li $t4, 0
    		println()
    		
    		for_transposeRows:
    			print(leftBracketMsg)
    			mul $s7, $t4, $s6								#s7 - ilosc bajtow do przesunieca
    			add $s7, $s7, $t5
    			mul $s7, $s7, 4
    			
    			sub $sp, $sp, $s7								#przesuniecie na odpowiednia komorke
    			
    			l.s $f12, ($sp)
    			jal _printFloatNumber
    			print(rightBracketMsg)
    			
    			add $sp, $sp, $s7								#powrot na poczatek
    	
    			add $t4, $t4, 1
    			blt $t4, $t1, for_transposeRows
    		
    		add $t5, $t5, 1
    	blt $t5,$t0,for_transposeColumns
	
	println()
	sub $sp, $sp, $t3 #powrot na ostatnio dodany element
	sub $sp, $sp, 4
	
	la $ra, ($t6)
	jr $ra
#############################################################33
		
# s4 -nr pierwszej, s5 - nr drugiej 		
_multiplyMatrixes:
	bge $s0, 2, atLeastTwoMatrixMul
	
	lessThanTwoMatrixMul:
		print(notAtLeastTwoMatrixMsg)
	j _closeProgramDecision

	atLeastTwoMatrixMul:
		li $s4, 0
		li $s5, 1
		beq $s0, 2, mulMatrix
		
		moreMatrixMul:
			print(matrixChooseMsg)
			jal _readIntNumber
			move $s4, $v0
			
			bltz $s4, incorectNumberOfMatrix	#kontrola ujemnych
			bge $s4, $s0, incorectNumberOfMatrix	#kontrola numeru wiekszego niz dostepny
	
			print(matrixChooseMsg)
			jal _readIntNumber
			move $s5, $v0
			
			bltz $s5, incorectNumberOfMatrix	#kontrola ujemnych
			bge $s5, $s0, incorectNumberOfMatrix	#kontrola numeru wiekszego niz dostepny
			
			

mulMatrix:
	move $t0, $s4
	jal _moveStackPointerUp
	lw $s6, ($sp) 	#s6 - ilosc kolumn1
	add $sp, $sp, 4
	lw $s2, ($sp) 	#s2- ilosc wierszy1
	sub $sp, $sp, 4
	jal _moveStackPointerDown
	
	move $t0, $s5
	jal _moveStackPointerUp
	lw $s3, ($sp) 	#s3 - ilosc kolumn2		
	add $sp, $sp, 4
	lw $t9, ($sp) 	#t9- ilosc wierszy2	
	sub $sp, $sp, 4
	jal _moveStackPointerDown
	
	bne $s6, $t9, notCorrectSize
	
	
	li $s7, 0 #iterator row1
	li $t8, 0 #iterator columns2
	li $s1, 0 #iterator columns1
	forRows1:
		li $t8, 0
		forColumns2:
		    li $s1,0
		    lwc1 $f26, zero
			forColumns1:
				la $t0, ($s4)
				jal _moveStackPointerUp
				add $sp, $sp, 4
				
				#przesuniecie na poczatek matrixa
				mul $t3, $s6, $s2
				mul $t3, $t3, 4 	#t3 - ilosc bitow na stosie do przeskoczenia by byc na gorze 
				add $sp, $sp, $t3	
			
				#przesuniecie wskaznika matrixa1 na odpowiednia komorke
				mul $t4, $s7, $s6
				add $t4, $t4, $s1
				mul $t4, $t4, 4
				sub $sp, $sp, $t4
				
				l.s $f30, ($sp)	# f30 - matrix 1
				
				add $sp, $sp, $t4
				sub $sp, $sp, $t3
				sub $sp, $sp, 4
				jal _moveStackPointerDown
				
				####
				la $t0, ($s5)
				jal _moveStackPointerUp
				add $sp, $sp, 4
		
				mul $t3, $t9, $s3
				mul $t3, $t3, 4 	#t3 - ilosc bitow na stosie do przeskoczenia by byc na gorze 
				add $sp, $sp, $t3	
			
				#przesuniecie wskaznika matrixa1 na odpowiednia komorke
				mul $t4, $s1, $s3
				add $t4, $t4, $t8
				mul $t4, $t4, 4
				sub $sp, $sp, $t4
				
				l.s $f28, ($sp)	# f28 - matrix2
				
				add $sp, $sp, $t4
				sub $sp, $sp, $t3
				sub $sp, $sp, 4
				
				jal _moveStackPointerDown
				
				mul.s $f24, $f30, $f28
				add.s $f26, $f26, $f24	#f26 - wynik mnozenia
				
			add $s1, $s1, 1	
			blt $s1, $s6, forColumns1
			
			print(leftBracketMsg)
			mov.s $f12, $f26
			jal _printFloatNumber
    		print(rightBracketMsg)
			
			add $t8, $t8, 1	
			blt $t8, $s3, forColumns2
	println()
	add $s7, $s7, 1		
	blt $s7, $s2, forRows1			
	j _closeProgramDecision				
	
	notCorrectSize:
		print(notCorrectMatrixesSizeMsg)
		j _closeProgramDecision																																							
##################################################################################
						
 #Wczytana liczba do f0
 _readFloatNumber:
    li $v0, 6     	
    syscall       	
    jr $ra

#Wczytana liczba do v0
 _readIntNumber:
    li $v0, 5     	
    syscall       	
    jr $ra

#Uzywa f12
_printFloatNumber:
	li $v0, 2
	#l.s $f12, ($t7)
	syscall
	jr $ra

_printIntNumber:
	li $v0, 1
	#la $a0, ($t7)
	syscall
	jr $ra

#Uzywa: t0
_closeProgramDecision:
	print(closeDecisionMsg)
	jal  _readIntNumber
	beq  $v0, 0, _mainToRepete
	j _endProcess

_wrongDecision:
	print(wrongDecisionMsg)
	j _closeProgramDecision

_endProcess:
   li $v0,10
   syscall

###############################################################################      
.kdata 
 
  arithmeticOverflowMsg:	.asciiz "==== Arithmetic Overflow ===="
  unhandledExceptionMsg: 	.asciiz "==== Unhandled Exception ===="
  syscallExceptionMsg:		.asciiz "==== Syscall Exception ====="
  floatingPointExceptionMsg:.asciiz "==== FloatingPoint Exception ====="
  
.ktext 0x80000180
.macro print(%comunicate)    
    li $v0, 4       		
    la $a0, %comunicate 	
    syscall         		    
.end_macro

mfc0 $k0, $13
andi $k1, $k0, 0x00007c
srl $k1, $k1, 2

beq $k1, 12, _arithmeticOverflow
beq $k1, 8, _syscallException
beq $k1, 14, _floatingPointException

_unhandledException:
	print(unhandledExceptionMsg)
	j _endProcessKDATA

_arithmeticOverflow:
	print(arithmeticOverflowMsg)
	j _endProcessKDATA  

_syscallException:
	print(syscallExceptionMsg)
	j _endProcessKDATA	

_floatingPointException:
	print(floatingPointExceptionMsg)
	j _endProcessKDATA

_endProcessKDATA:
	li $v0, 10
	syscall	
	 