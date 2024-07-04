#Include "Protheus.Ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIAP      ³ Autor ³Sueli Santos           ³ Data ³07.02.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna os valores para a DIAP-AP                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Diap()

Local aCampos	:=	{}
Local cAls 		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Arquivo do Registro tipo OC ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aCampos,{"CODIGO"		,"C"	,003,0})
AADD(aCampos,{"VALOR"	,"N"	,015,2})
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"ROC",.T.,.F.)
IndRegua("ROC",cAls,"CODIGO")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Arquivo do Registro tipo BENEFICIAMENTO ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
aCampos	:=	{}
AADD(aCampos,{"CODIGO"	,"C"	,003,0})
AADD(aCampos,{"VALOR"	,"N"	,015,2})
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"RBN",.T.,.F.)
IndRegua("RBN",cAls,"CODIGO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Arquivo do Registro tipo Reducao Isencao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
aCampos	:=	{}
AADD(aCampos,{"CODIGO"	,"C"	,003,0})
AADD(aCampos,{"VALOR"	,"N"	,015,2})
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"RRI",.T.,.F.)
IndRegua("RRI",cAls,"CODIGO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Arquivo do Registro Apuracao			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   

aCampos	:=	{}  

AADD(aCampos,{"DebSaid"	,"N"	,015,2})
AADD(aCampos,{"OutDeb"	,"N"	,015,2})
AADD(aCampos,{"EstCred"	,"N"	,015,2})
AADD(aCampos,{"CredEntr","N"	,015,2})
AADD(aCampos,{"OutCred"	,"N"	,015,2})
AADD(aCampos,{"EstDeb"	,"N"	,015,2})
AADD(aCampos,{"SdCdAnt"	,"N"	,015,2})
AADD(aCampos,{"SdDev"	,"N"	,015,2})
AADD(aCampos,{"SdCred"	,"N"	,015,2})
AADD(aCampos,{"ImpRec"  ,"N"	,015,2})
AADD(aCampos,{"DOutDeb" ,"C"	,900,0})
AADD(aCampos,{"DEstDeb"	,"C"	,900,0})
AADD(aCampos,{"DEstCred","C"	,900,0})
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"RAP",.T.,.F.)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Arquivo do Registro Estoque			   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   

aCampos	:=	{}
AADD(aCampos,{"CODIGO"		,"C"	,010,0})
AADD(aCampos,{"EstMPIT"		,"N"	,015,2})
AADD(aCampos,{"EstMPII"		,"N"	,015,2})  
AADD(aCampos,{"EstMPIO"		,"N"	,015,2})
AADD(aCampos,{"EstMPFT"		,"N"	,015,2})
AADD(aCampos,{"EstMPFI"		,"N"	,015,2})
AADD(aCampos,{"EstMPFO"		,"N"	,015,2})
AADD(aCampos,{"EstMEIT"		,"N"	,015,2})
AADD(aCampos,{"EstMEII"		,"N"	,015,2})
AADD(aCampos,{"EstMEIO"		,"N"	,015,2})
AADD(aCampos,{"EstMEFT"		,"N"	,015,2})
AADD(aCampos,{"EstMEFI"		,"N"	,015,2})
AADD(aCampos,{"EstMEFO"		,"N"	,015,2})
AADD(aCampos,{"EstMPAIT"	,"N"	,015,2})
AADD(aCampos,{"EstMPAII"	,"N"	,015,2})
AADD(aCampos,{"EstMPAIO"	,"N"	,015,2})
AADD(aCampos,{"EstMPAFT"	,"N"	,015,2})
AADD(aCampos,{"EstMPAFI"	,"N"	,015,2})
AADD(aCampos,{"EstMPAFO"	,"N"	,015,2})
AADD(aCampos,{"EstMMCIO"	,"N"	,015,2})
AADD(aCampos,{"EstMMCFO"	,"N"	,015,2})
AADD(aCampos,{"EstMATIO"	,"N"	,015,2})
AADD(aCampos,{"EstMATFO"	,"N"	,015,2})
AADD(aCampos,{"EstTEIO"		,"N"	,015,2})
AADD(aCampos,{"EstTEFO"		,"N"	,015,2})
cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"RET",.T.,.F.)
IndRegua("RET",cAls,"CODIGO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes referentes a Outros Creditos		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
OutrosCred()
IsenRed ()  
RetEst ()

Return(.t.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetEst    ³ Autor ³Sueli Santos           ³ Data ³07.02.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna os valores de estoque para a DIAP-AP                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±    
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetEst ()
    
Local   cCodProd  := "" 
Local	aEstMPIT  := {}
Local	aEstMPII  := {}
Local   aEstMPIO  := {}
Local   aEstMPFT  := {}
Local   aEstMPFI  := {}
Local   aEstMPFO  := {}
Local	aEstMEIT  := {}
Local	aEstMEII  := {}
Local	aEstMEIO  := {}
Local	aEstMEFT  := {}
Local	aEstMEFI  := {}
Local	aEstMEFO  := {}
Local 	aEstMPAIT := {} 
Local 	aEstMPAII := {} 
Local 	aEstMPAIO := {}
Local 	aEstMPAFT := {}
Local 	aEstMPAFI := {}
Local 	aEstMPAFO := {}
Local 	aEstMMCIO := {}
Local 	aEstMMCFO := {}
Local 	aEstMATIO := {}
Local 	aEstMATFO := {}
Local 	nEstTEIO  := 0
Local 	nEstTEFO  := 0

                     
Private	dDtIni	:=	mv_par01
Private	dDtFim	:=	mv_par02
     If Month(dDtFim) == 1
	     dDataFinal:= StoD(strzero(YEAR(dDtFim)-1,4)+"1231")                
    Else
 		dDataFinal := LastDay(CTOD(StrZero(Day(dDtFim),2) + "/" + StrZero(Month(dDataIni)-1,2) + "/" + Substr(StrZero(Year(dDtFim),4),3,2)))
	EndIf					   
   
   dbSelectArea("SB1")
   dbSetOrder(1)
   DbGoTop()

   While SB1->(!eof())
   		cCodProd := SB1->B1_COD                                                                                                              
        //Inicial MP
        aEstMPIT := IIF(SB1->B1_TIPO == "MP" .AND. SB1->B1_CLASFIS $ "00/10",FsPrdInv(cCodProd,.F.,dDataFinal),"")
        aEstMPII := IIF(SB1->B1_TIPO == "MP" .AND. SB1->B1_CLASFIS $ "30/40",FsPrdInv(cCodProd,.F.,dDataFinal),"")
        aEstMPIO := IIF(SB1->B1_TIPO == "MP" .AND. SB1->B1_CLASFIS $ "90",FsPrdInv(cCodProd,.F.,dDataFinal),"")
         //Final MP
        aEstMPFT := IIF(SB1->B1_TIPO == "MP" .AND. SB1->B1_CLASFIS $ "00/10",FsPrdInv(cCodProd,.F.,dDataFinal),"")
        aEstMPFI := IIF(SB1->B1_TIPO == "MP" .AND. SB1->B1_CLASFIS $ "30/40",FsPrdInv(cCodProd,.F.,dDataFinal),"")
        aEstMPFO := IIF(SB1->B1_TIPO == "MP" .AND. SB1->B1_CLASFIS $ "90",FsPrdInv(cCodProd,.F.,dDataFinal),"")

            //Inicial MERCADORIA
        aEstMEIT := IIF(SB1->B1_TIPO == "ME" .AND. SB1->B1_CLASFIS $ "00/10",FsPrdInv(cCodProd,.F.,dDataFinal),"")
        aEstMEII := IIF(SB1->B1_TIPO == "ME" .AND. SB1->B1_CLASFIS $ "30/40",FsPrdInv(cCodProd,.F.,dDataFinal),"")
        aEstMEIO := IIF(SB1->B1_TIPO == "ME" .AND. SB1->B1_CLASFIS $ "90",FsPrdInv(cCodProd,.F.,dDataFinal),"")
         //Final mercadoria
        aEstMEFT := IIF(SB1->B1_TIPO == "ME" .AND. SB1->B1_CLASFIS $ "00/10",FsPrdInv(cCodProd,.F.,dDataFinal),"")
        aEstMEFI := IIF(SB1->B1_TIPO == "ME" .AND. SB1->B1_CLASFIS $ "30/40",FsPrdInv(cCodProd,.F.,dDataFinal),"")
        aEstMEFO := IIF(SB1->B1_TIPO == "ME" .AND. SB1->B1_CLASFIS $ "90",FsPrdInv(cCodProd,.F.,dDataFinal),"")

 		 //Inicial PA
        aEstMPAIT := IIF(SB1->B1_TIPO == "PA" .AND. SB1->B1_CLASFIS $ "00/10",FsPrdInv(cCodProd,.F.,dDataFinal),"")
        aEstMPAII := IIF(SB1->B1_TIPO == "PA" .AND. SB1->B1_CLASFIS $ "30/40",FsPrdInv(cCodProd,.F.,dDataFinal),"")
        aEstMPAIO := IIF(SB1->B1_TIPO == "PA" .AND. SB1->B1_CLASFIS $ "90",FsPrdInv(cCodProd,.F.,dDataFinal),"")
         //Final PA
        aEstMPAFT := IIF(SB1->B1_TIPO == "PA" .AND. SB1->B1_CLASFIS $ "00/10",FsPrdInv(cCodProd,.F.,dDataFinal),"")
        aEstMPAFI := IIF(SB1->B1_TIPO == "PA" .AND. SB1->B1_CLASFIS $ "30/40",FsPrdInv(cCodProd,.F.,dDataFinal),"")
        aEstMPAFO := IIF(SB1->B1_TIPO == "PA" .AND. SB1->B1_CLASFIS $ "90",FsPrdInv(cCodProd,.F.,dDataFinal),"")
		
		 //Inicial CONSUMO
         aEstMMCIO := IIF(SB1->B1_TIPO == "MC" .AND. SB1->B1_CLASFIS $ "90",FsPrdInv(cCodProd,.F.,dDataFinal),"")
         //Final CONSUMO
         aEstMMCFO := IIF(SB1->B1_TIPO == "MC" .AND. SB1->B1_CLASFIS $ "90",FsPrdInv(cCodProd,.F.,dDataFinal),"")
            
         //Inicial ATIVO
         aEstMATIO := IIF(SB1->B1_ATIVO == "S" .AND. SB1->B1_CLASFIS $ "90",FsPrdInv(cCodProd,.F.,dDataFinal),"")
         //Final ATIVO
         aEstMATFO := IIF(SB1->B1_ATIVO == "S" .AND. SB1->B1_CLASFIS $ "90",FsPrdInv(cCodProd,.F.,dDataFinal),"")
                
	 	If !RET->(Dbseek( 'ESTOQUE'))                         
			RecLock("RET",.T.)  
	        RET->CODIGO:='ESTOQUE'
		Else                    
			RecLock("RET",.F.)  
		EndIf	
		
		IIF(valtype(aEstMPIT)=="A" .And. Len(aEstMPIT)>0,RET->ESTMPIT+=aEstMPIT[1][2],.T.) //Valor de Estoque Materia Prima Inicial Tributada
	    IIF(valtype(aEstMPII)=="A" .And. Len(aEstMPII)>0,RET->ESTMPII+=aEstMPII[1][2],.T.) //Valor de Estoque Materia Prima Inicial Isenta
	    IIF(valtype(aEstMPIO)=="A" .And. Len(aEstMPIO)>0,RET->ESTMPIO+=aEstMPIO[1][2],.T.) //Valor de Estoque Materia Prima Inicial Outras

	    IIF(valtype(aEstMPFT)=="A" .And. Len(aEstMPFT)>0,RET->ESTMPFT+=aEstMPFT[1][2],.T.) //Valor de Estoque Materia Prima Final Tributada
	    IIF(valtype(aEstMPFI)=="A" .And. Len(aEstMPFI)>0,RET->ESTMPFI+=aEstMPFI[1][2],.T.) //Valor de Estoque Materia Prima Final Isenta
	    IIF(valtype(aEstMPFO)=="A" .And. Len(aEstMPFO)>0,RET->ESTPFO+=aEstMPFO[1][2],.T.) //Valor de Estoque Materia Prima Final Outras
	    
	    IIF(valtype(aEstMEIT)=="A" .And. Len(aEstMEIT)>0,RET->ESTMEIT+=aEstMEIT[1][2],.T.) //Valor de Estoque Mercadoria Inicial Tributada
	    IIF(valtype(aEstMEII)=="A" .And. Len(aEstMEII)>0,RET->ESTMEII+=aEstMEII[1][2],.T.) //Valor de Estoque Mercadoria Inicial Isenta
		IIF(valtype(aEstMEIO)=="A" .And. Len(aEstMEIO)>0,RET->ESTMEIO+=aEstMEIO[1][2],.T.) //Valor de Estoque Mercadoria Inicial Outras
	    
	    IIF(valtype(aEstMEFT)=="A" .And. Len(aEstMEFT)>0,RET->ESTMEFT+=aEstMEFT[1][2],.T.) //Valor de Estoque Mercadoria Final Tributada 
	    IIF(valtype(aEstMEFI)=="A" .And. Len(aEstMEFI)>0,RET->ESTMEFI+=aEstMEFI[1][2],.T.) //Valor de Estoque Mercadoria Final Isenta
	    IIF(valtype(aEstMEFO)=="A" .And. Len(aEstMEFO)>0,RET->ESTMEFO+=aEstMEFO[1][2],.T.) //Valor de Estoque Mercadoria Final Outras 
	    
 	    IIF(valtype(aEstMPAIT)=="A" .And. Len(aEstMPAIT)>0,RET->ESTMPAIT+=aEstMPAIT[1][2],.T.) //Valor de Estoque Produto Acabado Inicial Tributada
	    IIF(valtype(aEstMPAII)=="A" .And. Len(aEstMPAII)>0,RET->ESTMPAII+=aEstMPAII[1][2],.T.) //Valor de Estoque Produto Acabado Inicial Isenta
		IIF(valtype(aEstMPAIO)=="A" .And. Len(aEstMPAIO)>0,RET->ESTMPAIO+=aEstMPAIO[1][2],.T.) //Valor de Estoque Produto Acabado Inicial Outras
	    
	    IIF(valtype(aEstMPAFT)=="A" .And. Len(aEstMPAFT)>0,RET->ESTMPAFT+=aEstMPAFT[1][2],.T.) //Valor de Estoque Produto Acabado Final Tributada 
	    IIF(valtype(aEstMPAFI)=="A" .And. Len(aEstMPAFI)>0,RET->ESTMPAFI+=aEstMPAFI[1][2],.T.) //Valor de Estoque Produto Acabado Final Isenta
	    IIF(valtype(aEstMPAFO)=="A" .And. Len(aEstMPAFO)>0,RET->ESTMPAFO+=aEstMPAFO[1][2],.T.) //Valor de Estoque Produto Acabado Final Outras   
        
        IIF(valtype(aEstMMCIO)=="A" .And. Len(aEstMMCIO)>0,RET->ESTMMCIO+=aEstMMCIO[1][2],.T.) //Valor de Estoque Material de Consumo Inicial Outras
	    IIF(valtype(aEstMMCFO)=="A" .And. Len(aEstMMCFO)>0,RET->ESTMMCFO+=aEstMMCFO[1][2],.T.) //Valor de Estoque Material de Consumo Final Outras
		
		IIF(valtype(aEstMATIO)=="A".And. Len(aEstMATIO)>0,RET->ESTMATIO+=aEstMATIO[1][2],.T.) //Valor de Estoque Inicial Ativo imobilizado
	    IIF(valtype(aEstMATFO)=="A".And. Len(aEstMATFO)>0,RET->ESTMATFO+=aEstMATFO[1][2],.T.) //Valor de Estoque Final Ativo imobilizado 
       
       //	IIF(nEstTEIO>0,RET->ESTTEIO+=nEstTEIO,.T.) //Valor do Estoque Inicial  de Terceiro coluna outras
//	    IIF(nEstTEFO>0,RET->ESTTEFO+=nEstTEFO,.T.) //Valor do Estoque Final de Terceiro coluna outras
 	    
 	    RET->(MsUnLock()) 
	    SB1->(DbSkip())
 	EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processando o Inventário Inicial      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		aEst := {"EST",""}
		FsEstInv(aEst,1,.T.,.F.,dDtIni,.F.,.F.)
				
		EST->(dbGoTop())
		Do While ! EST->(Eof())
			If EST->SITUACA == "3" .AND. EST->CLASSFIS $ "90" 
				nEstTEIO	+= EST->CUSTO
			EndIf
			EST->(dbSkip())			
		End
	
		// Excluindo area aberta pela funcao FsEstInv
		FsEstInv(aEst,2,,,dDtIni,.F.,.F.)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processando o saldo final do periodo  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FsEstInv(aEst,1,.T.,.F.,dDtFim,.F.,.F.)
	
		EST->(dbGoTop())
		Do While ! EST->(Eof())
			If EST->SITUACA == "3" .AND. EST->CLASSFIS $ "90" 
				nEstTEFO	+= EST->CUSTO
			EndIf
			EST->(dbSkip())			
		End                       
	
		// Excluindo area aberta pela funcao FsEstInv
		FsEstInv(aEst,2,,,MV_PAR02,.F.,.F.)
    
	
		If !RET->(Dbseek( 'ESTOQUE'))                         
			RecLock("RET",.T.)  
	        RET->CODIGO:='ESTOQUE'
		Else                    
			RecLock("RET",.F.)  
		EndIf			
    
   		IIF(nEstTEIO>0,RET->ESTTEIO+=nEstTEIO,.T.) //Valor do Estoque Inicial  de Terceiro coluna outras
	    IIF(nEstTEFO>0,RET->ESTTEFO+=nEstTEFO,.T.) //Valor do Estoque Final de Terceiro coluna outras
 	    
 	    RET->(MsUnLock()) 
	
Return(.t.)      
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OutrosCred ³ Autor ³Sueli Santos           ³ Data ³07.02.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna os valores de outros creditos                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador    ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function OutrosCred()

Local nI	   :=0     
Local nDebSaid :=0
Local nOutDeb  :=0
Local nEstCred :=0
Local nCredEntr:=0
LOCAL nOutCred :=0
Local nEstDeb  :=0
Local nSdCdAnt :=0 
Local nSdDev   :=0
Local nSdCred  :=0
Local nImpRec  :=0
Local cOutDeb  :=""
Local cEstCred :=""
Local cEstDeb  :=""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes referentes a Outros Creditos		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
aOutCred :=FisApur("IC",val(Substr(DTOS(MV_PAR02),1,4)),val(Substr(DTOS(MV_PAR02),5,2)),2,0,"*",.F.,{},1,.F.,"")


For nI := 1 To Len(aOutCred)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Creditos    	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
	Do Case	
		Case aOutCred[nI,1] == "006" .And. aOutCred[nI,4] == "200"
	    	If !ROC->(Dbseek("200"))
	        	 RecLock("ROC",.T.)
	         	ROC->CODIGO		:="200"
	      	Else
	        	 RecLock("ROC",.F.)
	      	Endif
	        ROC->VALOR		+=aOutCred[nI,3]
	        ROC->(MsUnLock())             
	
		Case aOutCred[nI,1] == "006" .And. aOutCred[nI,4] == "201"
	      	If !ROC->(Dbseek("201"))
	        	RecLock("ROC",.T.)
	         	ROC->CODIGO		:="201"
		    Else
	    	    RecLock("ROC",.F.)
		    Endif
	        ROC->VALOR		+=aOutCred[nI,3]
	        ROC->(MsUnLock())        
	     
	     Case aOutCred[nI,1] == "006" .And. aOutCred[nI,4] == "202"
	      	If !ROC->(Dbseek("202"))
	        	RecLock("ROC",.T.)
	         	ROC->CODIGO		:="202"
	      	Else
	        	RecLock("ROC",.F.)
	      	Endif
	      	ROC->VALOR		+=aOutCred[nI,3]
	      	ROC->(MsUnLock())    
	                  
	     Case aOutCred[nI,1] == "006" .And. aOutCred[nI,4] == "203"
	      	If !ROC->(Dbseek("203"))
	        	RecLock("ROC",.T.)
	         	ROC->CODIGO		:="203"
	      	Else
	        	RecLock("ROC",.F.)
	      	Endif
	      	ROC->VALOR		+=aOutCred[nI,3]
	      	ROC->(MsUnLock())     
	
	     Case aOutCred[nI,1] == "006" .And. aOutCred[nI,4] == "204"
	      	If !ROC->(Dbseek("204"))
	        	RecLock("ROC",.T.)
		        ROC->CODIGO		:="204"
	    	Else
	        	RecLock("ROC",.F.)
	      	Endif
	      	ROC->VALOR		+=aOutCred[nI,3]
	      	ROC->(MsUnLock())    
	
	     Case aOutCred[nI,1] == "006" .And. aOutCred[nI,4] == "205"
	      	If !ROC->(Dbseek("205"))
	        	RecLock("ROC",.T.)
	         	ROC->CODIGO		:="205"
	      	Else
	        	RecLock("ROC",.F.)
	      	Endif
	        ROC->VALOR		+=aOutCred[nI,3]
	        ROC->(MsUnLock())             
	                              
	     Case aOutCred[nI,1] == "006" .And. aOutCred[nI,4] == "206"
	      	If !ROC->(Dbseek("206"))
	        	RecLock("ROC",.T.)
	         	ROC->CODIGO		:="206"
	      	Else
	        	RecLock("ROC",.F.)
	      	Endif
	        ROC->VALOR		+=aOutCred[nI,3]
	        ROC->(MsUnLock())    
	
	     Case aOutCred[nI,1] == "006" .And. aOutCred[nI,4] == "207"
	      	If !ROC->(Dbseek("207"))
	        	RecLock("ROC",.T.)
	         	ROC->CODIGO		:="207"
	      	Else
	        	RecLock("ROC",.F.)
	      	Endif
	        ROC->VALOR		+=aOutCred[nI,3]
	        ROC->(MsUnLock())    
	
	     Case aOutCred[nI,1] == "006" .And. aOutCred[nI,4] == "208"
	      	If !ROC->(Dbseek("208"))
	        	RecLock("ROC",.T.)
	         	ROC->CODIGO		:="208"
	      	Else
	        	RecLock("ROC",.F.)
	      	Endif
	        ROC->VALOR		+=aOutCred[nI,3]
	        ROC->(MsUnLock())    
	
	     Case aOutCred[nI,1] == "006" .And. aOutCred[nI,4] == "299"
	      	If !ROC->(Dbseek("299"))
	        	RecLock("ROC",.T.)
	         	ROC->CODIGO		:="299"
	      	Else
	        	RecLock("ROC",.F.)
	      	Endif
	        ROC->VALOR		+=aOutCred[nI,3]
	        ROC->(MsUnLock())    

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Arquivo de Beneficiamento   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	     Case aOutCred[nI,1] == "012" .And. aOutCred[nI,4] == "300"
	      	If !RBN->(Dbseek("300"))
	        	RecLock("RBN",.T.)
	         	RBN->CODIGO		:="300"
	      	Else
	        	RecLock("ROC",.F.)
	      	Endif
	        RBN->VALOR		+=aOutCred[nI,3]
	        RBN->(MsUnLock())    
	EndCase         
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Informacoes ao registro principal        	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
    nDebSaid += Iif(Substr(Alltrim(aOutCred[nI,1]),1,3)=="001" ,aOutCred[nI,3],0) //Valor Total das Saidas (debito)                        
    nOutDeb  := Iif(Substr(Alltrim(aOutCred[nI,1]),1,3)=="002" ,aOutCred[nI,3],nOutDeb) //Valor "Outros Débitos"    
	cOutDeb  += Iif(Substr(Alltrim(aOutCred[nI,1]),1,3)=="002" ,Iif(cOutDeb<>"","/ "+aOutCred[nI,2],aOutCred[nI,2]),"")    
   	nEstCred := Iif(Substr(Alltrim(aOutCred[nI,1]),1,3)=="003" ,aOutCred[nI,3],nEstCred) //Valor "Estorno de Crédito"
	cEstCred += Iif(Substr(Alltrim(aOutCred[nI,1]),1,3)=="003" ,Iif(cEstCred<>"","/ "+aOutCred[nI,2],aOutCred[nI,2]),"")
	nCredEntr+= Iif(Substr(Alltrim(aOutCred[nI,1]),1,3)=="005" ,aOutCred[nI,3],0) //Valor Total do Credito do Imposto	   	                       
	nOutCred := Iif(Substr(Alltrim(aOutCred[nI,1]),1,3)=="006" ,aOutCred[nI,3],nOutCred) //Valor "Outros Créditos"
	nEstDeb  := Iif(Substr(Alltrim(aOutCred[nI,1]),1,3)=="007" ,aOutCred[nI,3],nEstDeb) //Valor "Estorno de Débito"    
	cEstDeb  += Iif(Substr(Alltrim(aOutCred[nI,1]),1,3)=="007" ,Iif(cEstDeb<>"","/ "+aOutCred[nI,2],aOutCred[nI,2]),"")
	nSdCdAnt += Iif(Substr(Alltrim(aOutCred[nI,1]),1,3)=="009" ,aOutCred[nI,3],0) //Valor "Saldo Credor Período Anterior"					
	nSdDev   += Iif(Substr(Alltrim(aOutCred[nI,1]),1,3)=="011" ,aOutCred[nI,3],0) //Valor "Saldo Devedor"					
	nSdCred  += Iif(Substr(Alltrim(aOutCred[nI,1]),1,3)=="014" ,aOutCred[nI,3],0) //Valor "Saldo Credor "		
	nImpRec  += Iif(Substr(Alltrim(aOutCred[nI,1]),1,3)=="013" ,aOutCred[nI,3],0) //Valor "Impoosto a Recolher "		
Next        
    
	RecLock("RAP",.T.)
   	RAP->DebSaid:= nDebSaid
   	RAP->OutDeb:= nOutDeb
  	RAP->DOutDeb:= cOutDeb
   	RAP->EstCred:= nEstCred
   	RAP->DEstCred:= cEstCred
   	RAP->CredEntr:= nCredEntr
   	RAP->OutCred:= nOutCred
   	RAP->EstDeb:= nEstDeb
   	RAP->DEstDeb:= cEstDeb
   	RAP->SdCdAnt:= nSdCdAnt
   	RAP->SdDev := nSdDev
   	RAP->SdCred := nSdCred 
   	RAP->ImpRec := nImpRec
   	RAP->(MsUnLock())
   	
Return(.t.)     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³IsenRed   ³ Autor ³Sueli Santos           ³ Data ³07.02.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna os valores da tabela Isento e Redução de Base       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function IsenRed()                                              

Local	aRegra	:=	{}
Local   nI := 0      
Local	cLetra		:=	""
Local	cRegra		:=	""
Local	cDireita	:=	""
Local	cEsquerda	:=	""
Local 	cAliasSF3 	:= "SF3" 
Local   nSf3        := 0

	DbSelectArea ("SX6")
	SX6->(DbSetOrder (1))
	If SX6->(DbSeek (xFilial ("SX6")+"MV_REDISEN"))
		Do While !SX6->(Eof ()) .And. xFilial ("SX6")==SX6->X6_FIL .And. "MV_REDISEN"$SX6->X6_VAR
			cVar	:=	AllTrim (SX6->X6_CONTEUD)		

			For nI := 1 To Len (cVar)
				cLetra	:=	SubStr (cVar, nI, 1)

				If (";"$cLetra)
					cDireita	:=	cRegra
					cRegra	:=	""
				ElseIf ("="$cLetra)
					cEsquerda	:=	cRegra
					cRegra	:=	""
				Else
					cRegra	+=	cLetra			
				EndIf

				If (";"$cLetra)
					aAdd (aRegra, {cEsquerda, cDireita})
				EndIf
                                              

			Next (nI)

			SX6->(DbSkip ())
		EndDo    
	Endif	

	If (Len (aRegra)>0)
		#IFDEF TOP
			If TcSrvType() <> "AS/400"
			    cAliasSF3:= "aMontTrab"
			   	lQuery    := .T.
				aStruSF3  := SF3->(dbStruct())		
				cQuery := "SELECT * "
				cQuery += "FROM "
				cQuery += RetSqlName("SF3") + " SF3 "
				cQuery += "WHERE "
				cQuery += "SF3.F3_FILIAL = '"+xFilial("SF3")+"' AND "		
				cQuery += "SF3.F3_ENTRADA >= '"+DTOS(MV_PAR01)+"' AND "
				cQuery += "SF3.F3_ENTRADA <= '"+DTOS(MV_PAR02)+"' AND "
		    	cQuery += "SF3.F3_DTCANC='' AND "
				cQuery += "SF3.D_E_L_E_T_ = ' '"
		
				cQuery := ChangeQuery(cQuery)
		    	
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
		
				For nSF3 := 1 To Len(aStruSF3)
					If aStruSF3[nSF3][2] <> "C" .and. FieldPos(aStruSF3[nSF3][1]) > 0
						TcSetField(cAliasSF3,aStruSF3[nSF3][1],aStruSF3[nSF3][2],aStruSF3[nSF3][3],aStruSF3[nSF3][4])
					EndIf
				Next nSF3
			    
			Else
		#ENDIF	 
				dbSelectArea(cAliasSF3)
				
				cIndSF3	:=	CriaTrab(NIL,.F.)
				cChave	:=	IndexKey()
				cFiltro	:=	"F3_FILIAL=='"+xFilial("SF3")+"'"
				cFiltro	+=	".And. DTOS(F3_ENTRADA)>='"+DTOS(MV_PAR01)+"'.AND.DTOS(F3_ENTRADA)<='"+DTOS(MV_PAR02)+"'"
		       	cFiltro	+=	".And. Empty(F3_DTCANC)"
		       	
				IndRegua(cAliasSF3,cIndSF3,cChave,,cFiltro,"")
		#IFDEF TOP
			Endif
		#ENDIF	
		
		(cAliasSF3)->(DbGoTop ()) 

		SD1->(DbSetOrder(3))
		SD2->(DbSetOrder(3))
					
		While !(cAliasSF3)->(Eof ()) 
			If SUBSTR((cAliasSF3)->F3_CFO,1,1)< "5"

				SD1->(DbSeek(xFilial("SD1")+dtos((cAliasSF3)->F3_ENTRADA)+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			   
				While !SD1->(Eof ()) 
					SF4->(DbSetOrder(1))			
				    SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES)) 				                        
				
					If (aScan (aRegra, {|x| SF4->F4_CODIGO $x[1]})>0) 
						cCodigo:= aRegra[aScan (aRegra, {|x| SF4->F4_CODIGO$x[1]})][2] 						
						If !RRI->(Dbseek(cCodigo))
			    		   	RecLock("RRI",.T.)
			       			RRI->CODIGO		:= cCodigo
					   	Else
					       	RecLock("RRI",.F.)
			   			Endif
				    	RRI->VALOR		+=SD1->D1_VALICM
				    	RRI->(MsUnLock())    	                  
			    	EndIf				
			  	
				  	SD1->(dbSkip())  
				End  
			Else	  
				SD2->(DbSeek(xFilial("SD2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
		        
		        cChaveF3:=xFilial("SD2")+dtos((cAliasSF3)->F3_ENTRADA)+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA
				
				While !SD2->(Eof ()) .AND. cChaveF3 == SD2->D2_FILIAL+dtos(SD2->D2_EMISSAO)+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
				
					SF4->(DbSetOrder(1))			
				    SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES)) //.And. Empty(SD2->D2_CODISS)
				   
					If (aScan (aRegra, {|x| SF4->F4_CODIGO $x[1]})>0)
				   		cCodigo:= aRegra[aScan (aRegra, {|x| SF4->F4_CODIGO$x[1]})][2] 
				   		If !RRI->(Dbseek(cCodigo))
			    		   	RecLock("RRI",.T.)
			       			RRI->CODIGO		:= cCodigo
					   	Else
					       	RecLock("RRI",.F.)
			   			Endif
				    	RRI->VALOR		+=SD2->D2_VALICM
				    	RRI->(MsUnLock())    	
			    	EndIf				
			  	
				  	SD2->(dbSkip())  
				End  
			EndIf	   
			
			(cAliasSF3)->(dbSkip())	
		End
		
	EndIf	
Return (.t.)