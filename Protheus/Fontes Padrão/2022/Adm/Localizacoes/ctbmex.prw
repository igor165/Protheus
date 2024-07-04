#INCLUDE "PROTHEUS.CH"


// 17/08/2009 -- Filial com mais de 2 caracteres



//CTBR516 - Hace la division de la Utilidade  Base COeficiente por la Ing. Nominales
User Function FCTR516()
Local aArea:=GetArea()
Local nValor:=0 
Local nvalor2:=0  
Local nValor3:=0

dbSelectArea("cArqTmp")
dbSetOrder(1)	

If MsSeek("UTBASE")      // Hace la pesquisa de la cuente de Utilidad
	If mv_par05 = 2
 		nvalor:=cArqTmp->MOVIMENTO
	Else
		nvalor:=cArqTmp->SALDOATU
	EndIf
EndIf

If MsSeek("INGNOM")  // Hace la pesquisa de Ing.
	If mv_par05 = 2
 		nvalor2:=cArqTmp->MOVIMENTO
	Else
		nvalor2:=cArqTmp->SALDOATU
	EndIf
EndIf

nValor3:=nvalor / nValor2    // Hace la division para sacar el coeficiente de Utilidad
RestArea(aARea)

Return(nvalor3)



//CTBR267 - Hace la division de la Utilidade  Base COeficiente por la Ing. Nominales
User Function FR267INA(cConta)
Local aArea:=GetArea() 
Local nValor:=0 
Local nvalor2:=0  
Local nValor3:=0
Local aValores:={}
Local nVez:=1

Default cConta :=""

dbSelectArea("cArqTmp")
dbSetOrder(1)	

If MsSeek(cConta)      // Hace la pesquisa de la cuente de Utilidad

	For nVez	:= 1 to  12
		   Aadd(aValores,&("COLUNA"+Alltrim(Str(nVez,2))))
	Next

	For nVez	:= 2 to  12
		   aValores[nVez]:=aValores[nVez] + aValores[nVez-1]
	Next   
	RestArea(aArea)           
	RecLock( "cArqTmp", .f. )
	For nVez	:= 1 to  12

	 &("COLUNA"+Alltrim(Str(nVez,2))):=aValores[nVez]

	Next      
	MsUnlock()
	cTexto:=("cArqTmp")->DESCCTA
EndIf 
RestArea(aArea)
Return(cTexto)




User Function FR267PE(cConta)
Local aArea:=GetArea() 
Local nValor:=0 
Local nvalor2:=0  
Local nValor3:=0
Local aValores:={}
Local nVez:=1     
Local cTexto:=""

Default cConta:=""
dbSelectArea("cArqTmp")
dbSetOrder(1)	

If MsSeek(cConta)      // Hace la pesquisa de la cuente de Utilidad

	For nVez	:= 1 to  12
		   Aadd(aValores,&("COLUNA"+Alltrim(Str(nVez,2))))
	Next


	aValor:=aValores
	aValor[1]:=0
	aValor[2]:=aValor[1]+aValores[1]
	aValor[3]:=aValor[2]+aValores[2]
	aValor[4]:=aValor[3]+aValores[4]
	aValor[5]:=aValor[4]+aValores[4]
	aValor[6]:=aValor[5]+aValores[5]
	aValor[7]:=aValor[6]+aValores[6]
	aValor[8]:=aValor[7]+aValores[7]
	aValor[9]:=aValor[8]+aValores[8]
	aValor[10]:=aValor[9]+aValores[9]
	aValor[11]:=aValor[10]+aValores[10]
	aValor[12]:=aValor[11]+aValores[11]
	RestArea(aArea)
	RecLock( "cArqTmp", .f. )
	For nVez	:= 1 to  12    
		&("COLUNA"+Alltrim(Str(nVez,2))) := aValor[nVez]

	Next
	MsUnlock()
	cTexto:=("cArqTmp")->DESCCTA
EndIf 
RestArea(aArea)
Return(cTexto)

// PARA O CTBR518


User Function F518IPM(cConta,nMes)
Local aArea:=GetArea()
Local nValor:=0
Local nValor1:= 0
Default cConta:="" 

dbSelectArea("cArqTmp")
dbSetOrder(1)	

If MsSeek(cConta)      // Hace la pesquisa de la cuente de Utilidad
	If mv_par05 = 2
 		nvalor:=cArqTmp->MOVIMENTO
	Else
		nvalor:=cArqTmp->SALDOATU
	EndIf
EndIf

RestArea(aARea)
nValor1:=nvalor / nMes    // Hace la division para sacar el coeficiente de Utilidad


Return(nValor1)




User Function F272ATU(cConta,cConta1)
Local aArea:=GetArea()
Local nValor:=0
Local nValor1:= 0   
Local nVez:=1
Local aValores:={}
Local aValores1:={}
Local cTexto:=""
Default cConta:=""  
Default cConta1:=""


dbSelectArea("cArqTmp")
dbSetOrder(1)	
If MsSeek(cConta)      // Hace la pesquisa de la cuente de Utilidad
   	For nVez	:= 1 to  12
		   Aadd(aValores,&("COLUNA"+Alltrim(Str(nVez,2))))
	Next
	If !Empty(cConta1)  //Cuenta del valor actualizado
		If MsSeek(cConta1)    // Hace la actualizacion  del saldo Efecto del Mes, no fue possible hacer en la vision,
								// pos el array de los valores no es actualizado
			For nVez	:= 1 to  12
		   		Aadd(aValores1,&("COLUNA"+Alltrim(Str(nVez,2))))
   			Next
   			RestArea(aArea)
	  			RecLock( "cArqTmp", .f. )
			 	For nVez	:= 1 to  Len(aFatorAtu)    
					&("COLUNA"+Alltrim(Str(nVez,2))) := (aValores1[nVez] - aValores[nVez] ) //Actualizacion
				Next 
		EndIf
   	Else
	   	RestArea(aArea)
	   	RecLock( "cArqTmp", .f. )
	 	For nVez	:= 1 to  Len(aFatorAtu)    
			&("COLUNA"+Alltrim(Str(nVez,2))) := NoRound((aValores[nVez] *aFatorAtu[nVez][2]),2) //Actualiza con el indice mensual
		Next  
	EndIf                                                                                  
EndIf
RestArea(aArea)

Return(cTexto)	


User Function F273ATU(cTipo,cConta)
Local aArea:=GetArea()
Local nValor:=0
Local nValor1:= 0   
Local nVez:=1
Local aValores:={}  
Local cTexto:=""
Default cTipo:=  "M"
Default cConta:=""

//Se for M e informar a conta , atualiza a conta com o valor da conta x  % Mensal 
//Se for C e informar a conta , atualiza a conta com o valor da conta x  % Encerramento

dbSelectArea("cArqTmp")
dbSetOrder(1)	
If MsSeek(cConta)      // Hace la pesquisa de la cuente de Utilidad
   	For nVez	:= 1 to  12
		   Aadd(aValores,&("COLUNA"+Alltrim(Str(nVez,2))))
	Next
   	RestArea(aArea)
   	RecLock( "cArqTmp", .f. )
 	If cTipo=="M"
		For nVez	:= 1 to  Len(aFatorAtu)    
			&("COLUNA"+Alltrim(Str(nVez,2))) := (aValores[nVez]*aFatorAtu[nVez][2])
		Next
   	ElseIf cTipo=="C"
		For nVez	:= 1 to  Len(aFatorEnc)    
			&("COLUNA"+Alltrim(Str(nVez,2))) := (aValores[nVez]*aFatorEnc[nVez])
    	Next
	EndIf
	MsUnlock()	                                     
 
Else
	RestArea(aArea)
EndIf

Return(cTexto)	
	
