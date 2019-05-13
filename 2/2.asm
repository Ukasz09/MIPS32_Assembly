.data    
    howManyNumbersComunicate:	.asciiz		"Podaj ilosc liczb: "
    inputNumberComunicate:	.asciiz      	"Podaj liczbe: "
    menuComunicate:       	.asciiz      	"\nWybierz z menu: \n1 => dodawanie, \n2 => odejmowanie or \n3 => mnozenie: \n4 => Dzielenie \n5 => Wyjscie\n\nDecyzja: "
    resultComunicate: 		.asciiz      	"Wynik: "
    wrongDecisionComunicate: 	.asciiz      	"\nWybrano niewlasciwa liczbe!"
    divByZeroComunicate:	.asciiz	     	"Nie mozna dzielic przez zero"
    tooLittleArgComunicate:	.asciiz		"Podano niewlasciwa liczbe parametrow"
.text
.globl _main

.macro showComunicate(%comunicate)    
    li $v0, 4       		
    la $a0, %comunicate 	
    syscall         		    
.end_macro
 
_main:

    li $t2, 1    
    li $t3, 2    
    li $t4, 3
    li $t5, 4 
    li $t6, 5
    li $t7, 6

    #t2 - wybor z menu	
    showComunicate(menuComunicate)
    jal _readNumber
    move $t1, $v0    
    
    #jesli wczytujemy dowolna ilosc liczb na stos
    ble $t1, $t4, _inputNumbers      
    bgt $t1, $t7, _wrongDecision
    
    	#jesli wczytujemy dwie liczby                                                
    	li $s1,2
    	j _writeNumbersToStack
    			
_inputNumbers:
    showComunicate(howManyNumbersComunicate)
    jal _readNumber
    move $s1, $v0
  
    jal _checkIsMoreThanOne
    j _writeNumbersToStack            

 #Uzywa $s1, alokuje rejestr $t0
_checkIsMoreThanOne:
     li $t0, 2
     blt $s1, $t0, _invalidParameter
     jr $ra

_readNumber:
    li $v0, 5     	
    syscall       	
    jr $ra 	

#Uzywa $s1 - ilosc liczb do wczytania
_writeNumbersToStack:
    li $t0,0 #iterator      
    while:
    	showComunicate(inputNumberComunicate)           
    	jal _readNumber
    	
    	add $sp, $sp, -4
    	sw $v0, ($sp)  
    	add $t0, $t0, 1
    	blt $t0, $s1, while	
    endWhile:	
    j _chooseDecision
        
#Uzywa $t1 - wybor z menu, oraz $t2-$t7        
_chooseDecision:
     beq $t1, $t2, _addProcess    
     beq $t1, $t3, _subtractProcess 
    #beq $t1, $t4, _multiplyProcess
    #beq $t1, $t5, _divideProcess 
    #beq $t1, $t6, _powerProcess
    #beq $t1, $t7, _sqrtProcess
    j _wrongDecision        
       
_wrongDecision:
     showComunicate(wrongDecisionComunicate)
     j _endProcess

_addProcess:
     jal _checkIsMoreThanOne

     li $t3,0 #wynik
     li $t2,0 #iterator
 	
     addWhile:
 	jal _readNumberStackUp
 	add $t3,$t3,$t1
 	add $t2, $t2,1
 	blt $t2,$s1,addWhile

     add $sp, $sp, -4
     sw $t3, ($sp) 	 	
     showComunicate(resultComunicate)
     jal _showResult
     j _endProcess
 	             	        	          	           	        	      
_invalidParameter:
    showComunicate(tooLittleArgComunicate)
    j _endProcess 
             	        	          	           	        	                  	        	          	           	        	                  	        	          	           	        	                   	        	          	           	        	                  	        	          	           	        	                  	        	          	           	        	      
#Wczytuje liczbe ze stosu do $t1 i cofa wskaznik (idzie w gore odwroconego stosu)
_readNumberStackUp:
     lw $t1, ($sp)
     add $sp,$sp,4
     jr $ra     
       
#Uzywa $s2       
_showResult:    
    li $v0, 1      	
    lw $a0, ($sp) 
    add $sp,$sp,4
    syscall         	
    jr $ra


_subtractProcess:
     jal _checkIsMoreThanOne
     jal _setPointerToFirstAddedNumber
     
     li $t3,0 #wynik
     
     jal _readNumberStackDown
     add $t3,$t3,$t1
     li $t2,1 #iterator
 	
     subWhile:
        jal _readNumberStackDown
        sub $t3, $t3,$t1 
 	add $t2, $t2,1
 	blt $t2,$s1,subWhile

     jal _setPointerToFirstAddedNumber
     add $sp, $sp, 4
     sw $t3, ($sp) 	 	
     showComunicate(resultComunicate)
     jal _showResult
     j _endProcess 	 		        	        	         	        	           	        	        

#Alokuje $t4, uzywa $s1, zmienia wskaznik stosu
_setPointerToFirstAddedNumber:
    mul $t4, $s1, 4
    sub $t4, $t4, 4
    add $sp, $sp, $t4	
    jr $ra

#Wczytuje liczbe ze stosu do $t1 i przesowa do przodu wskaznik (idzie w dol odwroconego stosu)
_readNumberStackDown:
     lw $t1, ($sp)
     add $sp,$sp,-4
     jr $ra      	 		        	        	         	        	           	        	            	 		        	        	         	        	           	        	            	 		        	        	         	        	           	        	        
    	 		        	        	         	        	           	        	            	 		        	        	         	        	           	        	            	 		        	        	         	        	           	        	            	 		        	        	         	        	           	        	            	 		        	        	         	        	           	        	            	 		        	        	         	        	           	        	            	 		        	        	         	        	           	        	            	 		        	        	         	        	           	        	            	 		        	        	         	        	           	        	        
_endProcess:
    li $v0,10
    syscall  
