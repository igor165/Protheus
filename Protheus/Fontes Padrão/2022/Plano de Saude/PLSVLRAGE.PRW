
#include "PLSMGER.CH"
#include "PLSA627.CH"
#include "PROTHEUS.CH"
     
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSVLRACU³ Autor ³ Daher		            ³ Data ³ 16.05.05 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Rotina para valorizar o acumulado						  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLRACU(dDatPro,cAno,cMes,cFaiDes,aTotLan,nItem)

LOCAL nTaxDes   := 0
LOCAL nVlrMax   := 0
LOCAL nVlrAdi 	 := 0
LOCAL nSalario  := 0             
LOCAL nSalAdic	 := 0         
LOCAL aMatRet	 := {}          
LOCAL aVetAux	 := {}        
LOCAL nUtiliza  := aTotLan[nItem][2]   
LOCAL nAcumu1   := aTotLan[nItem][3]
LOCAL nAcumu2	 := aTotLan[nItem][4]
LOCAL nVlrPag   := 0             
LOCAL nVlrAc1	 := 0
LOCAL nVlrAc2	 := 0
LOCAL lFouSRA   := .F.
LOCAL lCalcula  := .T.
LOCAL aAcertos  := {}
LOCAL aRetPto	 := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no funcionario                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aTotLan[nItem][6] <> "1" // se for debito   
     Return({})
Endif            
If Len(aTotLan[nItem]) >= 7
	lCalcula := aTotLan[nItem][7]
Endif 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Altera os totais			                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
If Existblock("PLMONSAL")                                         
	aAcertos := PLSINPBFQ(BA3->BA3_CODINT,{|| !Empty(BFQ_LANACE)})
	aRetPto  := Execblock("PLMONSAL",.F.,.F.,{aTotLan,aAcertos,nItem,nUtiliza,nAcumu1,nAcumu2})       
	nUtiliza := aRetPto[1]                                                                       
	nAcumu1  := aRetPto[2]
	nAcumu2  := aRetPto[3]
	lCalcula := aRetPto[4]
Endif
                
If Empty(BA3->(BA3_AGFTFU+BA3_AGMTFU))
	lFouSRA  := .F.  
	lCalcula := .F.
Endif

SRA->(DbSetOrder(1))
if SRA->(DbSeek(BA3->BA3_AGFTFU+BA3->BA3_AGMTFU))
    lFouSRA := .T.
endif
    
if BA3->(FieldPos("BA3_VALSAL")) > 0 .and. BA3->BA3_VALSAL > 0 
	nSalario := BA3->BA3_VALSAL                       
	nSalAdic := &(GetNewPar("MV_PLCOMS1",'0'))    
else                 
	if lFouSRA
      	nSalario := &(GetNewPar("MV_PLCOMSA",'0'))
      	nSalAdic := &(GetNewPar("MV_PLCOMS1",'0'))    
    endif
endif              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o percentual padrao a ser descontado							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTaxDes := PLSFAIDE(cFaiDes,nSalario,dDatPro)
nVlrMax := (nTaxDes/100)*nSalario

nTaxDes := PLSFAIDE(cFaiDes,nSalario+nSalAdic,dDatPro)
nVlrAdi := (nTaxDes/100)*(nSalario+nSalAdic)
                
If lCalcula   

	If nAcumu1 > 0
	
	   If nAcumu2 > 0
	
	   		If  nAcumu1 > nVlrMax                   
	   			nVlrPag   := nVlrMax          
		   		nVlrAc1   := nAcumu1 - nVlrMax             
	   		Else                    
	   			nVlrPag  := nAcumu1
		   		nVlrAc1  := 0      
	   		Endif
	   		                         
		   	If (nAcumu2+nUtiliza) > (nVlrAdi-nVlrMax) 
			    nVlrPag  += nVlrAdi-nVlrMax                       
			   	nVlrAc2  := (nAcumu2+nUtiliza) - (nVlrAdi-nVlrMax)
		   	Else
			   	nVlrPag  += nAcumu2+nUtiliza                       
			   	nVlrAc2  := 0
		   	Endif
	   		
	   Else
			If nSalAdic > 0 //tem periculosidade?
			
				If nUtiliza > 0   
				
					   If nAcumu1 > nVlrMax                      
					   		nVlrPag := nVlrMax                       
					   		nVlrAc1 := nAcumu1 - nVlrMax	   
					   Else                    
					   		nVlrPag := nAcumu1                       
					   		nVlrAc1 := 0		   
					   Endif
					   
			 		   If nUtiliza > (nVlrAdi - nVlrMax)                      
						    nVlrPag += (nVlrAdi - nVlrMax)                      
						   	nVlrAc2 := nUtiliza - (nVlrAdi - nVlrMax)	   
				       Else                    
						   	nVlrPag += nUtiliza                       
						   	nVlrAc2 := 0		   
				       Endif
					   
				Else //ele tem periculosidade e nao usou e tem saldo 1 e nao tem saldo 2
				   
					   If nAcumu1 > nVlrMax                      
					   		nVlrPag := nVlrMax                       
					   		nVlrAc1 := nAcumu1 - nVlrMax
					   Else                    
					   		nVlrPag := nAcumu1                       
					   		nVlrAc1 := 0		   
					   Endif    
				   
				Endif                            
				
			Else // nao tem periculosidade  
			
			   If nAcumu1 + nUtiliza > nVlrMax
			   		nVlrPag := nVlrMax                       
			   		nVlrAc1 := (nAcumu1 + nUtiliza) - nVlrMax
			   Else                
					nVlrPag := nAcumu1 + nUtiliza	   
					nVlrAc1 := 0
			   Endif   
			   
	   		Endif
	   Endif
	
	Elseif nAcumu2 > 0	
	                     
	 	If (nVlrAdi-nVlrMax) > 0//se ele tem periculosidade
	 	
			   	If nAcumu2 + nUtiliza > nVlrAdi
					nVlrPag  := nVlrAdi
					nVlrAc2  := (nAcumu2 + nUtiliza) - nVlrPag
			   	Else
			   		nVlrPag := nAcumu2 + nUtiliza
			   		nVlrAc2 := 0
			   	Endif
	  	
	  	Else                         
		
			    If nAcumu2 + nUtiliza > nVlrMax
			   		nVlrPag := nVlrMax                       
			   		nVlrAc2 := (nAcumu2 + nUtiliza) - nVlrPag
			    Else                
					nVlrPag := nAcumu2 + nUtiliza	   
					nVlrAc2 := 0
			    Endif
		
		Endif   
		
	Else                
	
		If  nUtiliza > nVlrMax
			
			nVlrPag  := nVlrMax
			
			If (nVlrAdi-nVlrMax) > 0//se ele tem periculosidade
		   		
		   		If (nUtiliza-nVlrMax) > (nVlrAdi-nVlrMax) 
			   		nVlrPag  += nVlrAdi-nVlrMax                       
			   		nVlrAc2  := nUtiliza - nVlrPag
		   		Else
			   		nVlrPag  += nUtiliza-nVlrMax                       
			   		nVlrAc2  := 0
		   		Endif
		   		
	  		Else                                       
	   				nVlrAc1     := nUtiliza-nVlrMax
	   		Endif                       
	   	
		Else  
		              
			nVlrPag := nUtiliza	   
			nVlrAc1 := 0
			nVlrAc2 := 0
		
		Endif
	Endif
Else
	nVlrPag := nUtiliza	   
	nVlrAc1 := nAcumu1
	nVlrAc2 := nAcumu2
Endif	

           
aadd(aMatRet,{nVlrPag,nVlrAc1,nVlrAc2})
//[1] valor que estou pagando no mes
//[2] valor que estou acumlando no mes
//[3] valor que estou acumlando no mes   
Return(aMatRet)                          

/*/
