#Include "Protheus.Ch"          


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSSINAL  ³ Autor ³Katia                  ³ Data ³ 29.12.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³PROCESSA DADOS PARA IMPORTACAO DE ARQUIVO TMSSINAL - SUFRAMA³±±
±±³          ³Cargas Transportadas atraves da Zona Franca de Manaus       ³±±
±±³          ³WS SINAL 6.0  															  ³±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSSINProc(cFilMan, cNumMan,cSerman)
Local aTrbs		:= {} 
Local lRet     := .F.

Private lEnd	:=	.F.
Private nHandle

Static lDTX_SERMAN := DTX->(FieldPos("DTX_SERMAN")) > 0
Static oTempMA	:= Nil
Static otempNF	:= Nil
Static oTempCT	:= Nil

Default cSerman := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivos temporarios            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTrbs := TMSSINTmp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Registros                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet:= TMSSINReg(cFilMan, cNumMan,cSerman)
    
    
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSSINReg  ³ Autor ³Katia                  ³ Data ³ 29.12.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa os documentos contidos nas Cargas                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TMSSINReg(cFilMan, cNumMan,cSerman)

Local aDtx     := {"DTX",""}
Local nItem		:= 0
Local cCPFMot	:= ''   
Local cUFDes   := ''    
Local lRet     := .F.
Local cEstDes  := ''
Local nItemNF	 	:= 0     
Local nItemCHC	:= 0
Local cTipDoc  	:= ''
Local lTMSSINTD	:= ExistBlock('TMSSINTD')
Local lTMSSIVLD	:= ExistBlock('TMSSIVLD')	// PE para validar se o documento sera informado no arquivo
Local lTMSSINFE 	:= ExistBlock('TMSSINFE')
Local lRetNFE := .T.
Local lRetPE	:= .T.
Local nValMer	:= 0
Local nPeso   := 0

Default cSerman := ""

DTX->(dbSetOrder(3))
If lDTX_SERMAN
	FsQuery(aDtx,1,"DTX_FILIAL='"+ xFilial("DTX")+"' AND DTX_FILMAN='" + cFilMan + "' AND DTX_MANIFE='"+ cNumMan + "' AND DTX_SERMAN='"+ cSerman +"' ",DTX->(IndexKey()))
Else
	FsQuery(aDtx,1,"DTX_FILIAL='"+ xFilial("DTX")+"' AND DTX_FILMAN='" + cFilMan + "' AND DTX_MANIFE='"+ cNumMan +"'",DTX->(IndexKey()))
EndIf
DTX->(dbGotop())
 			
If !DTX->(Eof ()) 	
	nItemNF:= 0
   
	DUP->(DbSetOrder(1))
	DA4->(DbSetOrder(1))
	If DUP->(MsSeek(xFilial("DUP")+DTX->DTX_FILORI+DTX->DTX_VIAGEM))
		While DUP->(!Eof()) .And. DUP->DUP_FILIAL + DUP->DUP_FILORI + DUP->DUP_VIAGEM == xFilial("DUP") + DTX->DTX_FILORI + DTX->DTX_VIAGEM
			If DA4->(MsSeek(xFilial("DA4")+DUP->DUP_CODMOT)) 
				 cCPFMot:= DA4->DA4_CGC
			EndIf
			DUP->(DbSkip())
		EndDo
	EndIf

	cAliasDUD := GetNextAlias()
	cQuery := " SELECT DUD_FILDOC, DUD_DOC, DUD_SERIE "
	cQuery += " FROM " + RetSqlName("DUD")
	cQuery += " WHERE DUD_FILIAL ='" + xFilial("DUD") + "'"
	cQuery += "   AND DUD_FILORI ='" + DTX->DTX_FILORI + "'"
	cQuery += "   AND DUD_VIAGEM ='" + DTX->DTX_VIAGEM + "'"
	cQuery += "   AND DUD_FILMAN ='" + DTX->DTX_FILMAN + "'"
	cQuery += "   AND DUD_MANIFE ='" + DTX->DTX_MANIFE + "'"
	If lDTX_SERMAN
		cQuery += "   AND DUD_SERMAN ='" + DTX->DTX_SERMAN + "'"	
	EndIf
	cQuery += "   AND DUD_STATUS <>'" + StrZero(9,Len(DUD->DUD_STATUS)) + "'"   //Cancelado
	cQuery += "   AND D_E_L_E_T_=' '"   
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDUD, .F., .T.)	
	While (cAliasDUD)->(!Eof())
   
   	lRet:= .F.
                                                       
      //--- Sera selecionado apenas CTRC cujo Destino seja Zona Franca de Manaus                                                    
		DT6->(dbSetOrder(1))
		If DT6->(MsSeek(xFilial('DT6') + (cAliasDUD)->DUD_FILDOC + (cAliasDUD)->DUD_DOC + (cAliasDUD)->DUD_SERIE))
			cEstDes := Posicione('SA1',1,xFilial('SA1')+DT6->DT6_CLIDES+DT6->DT6_LOJDES,'A1_EST')
				           
			lRet:=  AllTrim(cEstDes) $ "AM|AC|AP|RO|RR"				
			
			//--- Ponto de Entrada para validar os Tipos de Documentos a serem gerados
			If lRet 
				If lTMSSINTD
					cTipDoc:= ExecBlock('TMSSINTD',.F.,.F.)
					If ValType(cTipDoc) <> 'C' 
						cTipDoc := StrZero(2,Len(DT6->DT6_DOCTMS))   //CTRC
					EndIf
				Else
					cTipDoc := StrZero(2,Len(DT6->DT6_DOCTMS))      //CTRC
				EndIf	
			EndIf			      
			
			lRet:= DT6->DT6_DOCTMS $ cTipDoc
			If lRet .And. lTMSSIVLD
				lRetPE := ExecBlock('TMSSIVLD',.F.,.F., {DT6->DT6_FILDOC, DT6->DT6_DOC, DT6->DT6_SERIE})
				
				If ValType(lRetPE) == "L"
					lRet := lRetPE
				EndIf
			EndIf
		EndIf	

		If lRet
		   	nItem:= 0
			DTC->(DbSetOrder(3))
			If	DTC->(MsSeek( cSeek := xFilial('DTC') + (cAliasDUD)->DUD_FILDOC+ (cAliasDUD)->DUD_DOC + (cAliasDUD)->DUD_SERIE ))
				While DTC->( ! Eof() .And. DTC->DTC_FILIAL + DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE == cSeek )
					
					If lTMSSINFE
						lRetNFE := ExecBlock('TMSSINFE',.F.,.F., {DTC->DTC_FILDOC, DTC->DTC_DOC, DTC->DTC_SERIE, DTC->DTC_NUMNFC, DTC->DTC_SERNFC, DTC->DTC_NFEID })
				
						If ValType(lRetNFE) == "L"
							If lRetNFE = .F.
								DTC->(DbSkip()) 
								Loop
							EndIf
						EndIf
					EndIf
					//--- Nota Fiscal   
					DbSelectArea("NFC")                                                                                           
					NFC->(DbSetOrder(1))
 					If NFC->(MsSeek(DTC->DTC_FILDOC + DTC->DTC_DOC + DTC->DTC_SERIE + DTC->DTC_NUMNFC + DTC->DTC_SERNFC ))
						RecLock("NFC",.F.)
						NFC->QTDVOL += DTC->DTC_QTDVOL
						NFC->VALOR  += DTC->DTC_VALOR
 					Else 
						RecLock("NFC",.T.) 					
						NFC->NUMNFC:= DTC->DTC_NUMNFC
						NFC->SERNFC:= DTC->DTC_SERNFC
						NFC->CLIREM:= DTC->DTC_CLIREM
						NFC->LOJREM:= DTC->DTC_LOJREM
						NFC->CODPRO:= DTC->DTC_CODPRO
						NFC->FILDOC:= DTC->DTC_FILDOC
						NFC->DOC   := DTC->DTC_DOC
						NFC->SERIE := DTC->DTC_SERIE
						NFC->QTDVOL:= DTC->DTC_QTDVOL
						NFC->VALOR := DTC->DTC_VALOR
						NFC->EMINFC:= DTC->DTC_EMINFC
						NFC->CLIDES:= DTC->DTC_CLIDES
						NFC->LOJDES:= DTC->DTC_LOJDES     
						If DTC->(FieldPos("DTC_NFEID")) > 0
							NFC->NFEID := DTC->DTC_NFEID    
						EndIf	
						nItem++ 
						nItemNF++
						
						SA1->(dbSetOrder(1))
						If SA1->(dbSeek(xFilial("SA1")+DTC->DTC_CLIREM+DTC->DTC_LOJREM))
							NFC->CGCREM:= SA1->A1_CGC
						EndIf
						SA1->(dbSetOrder(1))
						If SA1->(dbSeek(xFilial("SA1")+DTC->DTC_CLIDES+DTC->DTC_LOJDES))
							NFC->CGCDES:= SA1->A1_CGC
						EndIf					
					EndIf
					
					MsUnlock()	
								
					DTC->(DbSkip()) 
					lRetNFE := .T.
				EndDo  
					
				dbSelectArea("SF3") 
				SF3->(DbSetOrder(4))
				If nItem > 0 .And. SF3->(DbSeek(xFilial("SF3")+DT6->DT6_CLIDEV+DT6->DT6_LOJDEV+DT6->DT6_DOC+DT6->DT6_SERIE)) 		
				
					//-- Conhecimento
					RecLock("CHC",.T.)
					CHC->DOC    := DT6->DT6_DOC			
					CHC->DATEMI := DT6->DT6_DATEMI
					CHC->VALTOT := DT6->DT6_VALTOT
					CHC->VALMER := DT6->DT6_VALMER
					CHC->QTDNF  := nItem
					CHC->PESO   := DT6->DT6_PESO
					CHC->CFO    := SF3->F3_CFO
					CHC->TIPFRE := DT6->DT6_TIPFRE
					CHC->BASEICM:= SF3->F3_BASEICM
					CHC->VALICM := SF3->F3_VALICM
					CHC->VALFRE := DT6->DT6_VALFRE
					MsUnlock()
					nItemCHC++		
					nValMer += DT6->DT6_VALMER
					nPeso   += DT6->DT6_PESO			
				EndIf
			EndIf

		EndIf	
		(cAliasDUD)->(dbSkip())      
		
	EndDo			
	(cAliasDUD)->(DbCloseArea())
   
	//---- Se gerou algum Documento
	If nItemNF > 0                 
		lRet:= .T.
	EndIf
	
	If lRet      
		DTR->( DbSetOrder( 1 ) )
		If DTR->( MsSeek( xFilial("DTR") + DTX->DTX_FILORI  + DTX->DTX_VIAGEM ) )
			DA3->(DbSetOrder(1))
			lRet:= DA3->(MsSeek(xFilial("DA3")+DTR->DTR_CODRB1)) 
			If !lRet
				lRet:= DA3->(MsSeek(xFilial("DA3")+DTR->DTR_CODVEI)) 
			EndIf 		
		Else
			lRet:= .F.
		EndIf
   EndIf
   
   If lRet      
		aAreaSM0 := SM0->(GetArea())
		SM0->(dbSeek(cEmpAnt+DTX->DTX_FILDCA))
		cUFDes:= SM0->M0_ESTENT
		RestArea(aAreaSM0)
      
		//-- Manifesto
		DbSelectArea("MAN")
		RecLock("MAN",.T.)
		MAN->MANIFE:= DTX->DTX_MANIFE
		MAN->VALMER:= nValMer
		MAN->PESO  := nPeso
		MAN->QTDDOC:= nItemCHC
		MAN->QTDNF := nItemNF
		MAN->CGC   := cCPFMot
		MAN->PLACA := DA3->DA3_PLACA
		MAN->ESTPLA:= DA3->DA3_ESTPLA					
		MAN->UFDES := cUFDes 
		MsUnlock()  	
	EndIf		

	DTX->(dbSkip())
EndIf

FsQuery (aDtx,2,) 

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSSINTmp  ³ Autor ³Katia                  ³ Data ³ 29.12.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos temporarios                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TMSSINTMP()

Local cArqTrbMA	:= "" 
Local cArqTrbNF	:= ""   
Local cArqTrbCT	:= ""   
Local aCampMAN	:= {}          
Local aCampNFC	:= {}     
Local aCampCHC 	:= {}          
Local aTrbs    	:= {}
Local cIndNFC1 	:= ""


//---- Tabela Temporaria Dados Manifesto ------//
aTam	:= TAMSX3("DTX_MANIFE")
AADD(aCampMAN,{"MANIFE","C",aTam[1],aTam[2]})

aTam	:= TAMSX3("DTX_VALMER")
AADD(aCampMAN,{"VALMER","N",aTam[1],aTam[2]})

aTam	:= TAMSX3("DTX_PESO")
AADD(aCampMAN,{"PESO","N",aTam[1],aTam[2]})

aTam	:= TAMSX3("DTX_QTDDOC")
AADD(aCampMAN,{"QTDDOC","N",aTam[1],aTam[2]})

aTam	:= TAMSX3("DTX_QTDNF")
AADD(aCampMAN,{"QTDNF","N",10,0})

aTam	:= TAMSX3("DA4_CGC")
AADD(aCampMAN,{"CGC","C",aTam[1],aTam[2]})

aTam	:= TAMSX3("DA3_PLACA")
AADD(aCampMAN,{"PLACA","C",aTam[1],aTam[2]})

aTam	:= TAMSX3("DA3_ESTPLA")
AADD(aCampMAN,{"ESTPLA","C",aTam[1],aTam[2]})

AADD(acampMAN,{"UFDES","C",002,0})	 

//---- Tabela Temporaria Dados Nota Fiscal ------//
aTam	:= TAMSX3("DTC_NUMNFC")
AADD(aCampNFC,{"NUMNFC","C",aTam[1],aTam[2]})

aTam	:= TAMSX3("DTC_SERNFC")
AADD(aCampNFC,{"SERNFC","C",aTam[1],aTam[2]})

aTam	:= TAMSX3("DTC_CLIREM")
AADD(aCampNFC,{"CLIREM","C",aTam[1],aTam[2]})

aTam	:= TAMSX3("DTC_LOJREM")
AADD(aCampNFC,{"LOJREM","C",aTam[1],aTam[2]})

aTam	:= TAMSX3("DTC_CODPRO")
AADD(aCampNFC,{"CODPRO","C",aTam[1],aTam[2]})

aTam	:= TAMSX3("DTC_FILDOC")
AADD(aCampNFC,{"FILDOC","C",aTam[1],aTam[2]})

aTam	:= TAMSX3("DTC_DOC")
AADD(aCampNFC,{"DOC","C",aTam[1],aTam[2]})

aTam	:= TAMSX3("DTC_SERIE")
AADD(aCampNFC,{"SERIE","C",aTam[1],aTam[2]})

aTam	:= TAMSX3("DTC_QTDVOL")
AADD(aCampNFC,{"QTDVOL","N",aTam[1],aTam[2]})

aTam	:= TAMSX3("DTC_VALOR")
AADD(aCampNFC,{"VALOR","N",aTam[1],aTam[2]})

aTam	:= TAMSX3("DTC_EMINFC")
AADD(aCampNFC,{"EMINFC","D",aTam[1],aTam[2]})   

aTam	:= TAMSX3("DTC_CLIDES")
AADD(aCampNFC,{"CLIDES","C",aTam[1],aTam[2]})

aTam	:= TAMSX3("DTC_LOJDES")
AADD(aCampNFC,{"LOJDES","C",aTam[1],aTam[2]})

AADD(aCampNFC,{"NFEID","C",44,0})   

aTam	:= TAMSX3("A1_CGC")
AADD(aCampNFC,{"CGCREM","C",aTam[1],aTam[2]})   

aTam	:= TAMSX3("A1_CGC")
AADD(aCampNFC,{"CGCDES","C",aTam[1],aTam[2]})   

//---- Tabela Temporaria Dados Conhecimento ------//
aTam	:= TAMSX3("DT6_DOC")
AADD(aCampCHC,{"DOC","C",aTam[1],aTam[2]})

aTam	:= TAMSX3("DT6_DATEMI")
AADD(aCampCHC,{"DATEMI","D",aTam[1],aTam[2]})

aTam	:= TAMSX3("DT6_VALTOT")
AADD(aCampCHC,{"VALTOT","N",aTam[1],aTam[2]})

aTam	:= TAMSX3("DT6_VALFRE")
AADD(aCampCHC,{"VALFRE","N",aTam[1],aTam[2]})

aTam	:= TAMSX3("DT6_VALMER")
AADD(aCampCHC,{"VALMER","N",aTam[1],aTam[2]})

aTam	:= TAMSX3("DT6_QTDNF")
AADD(aCampCHC,{"QTDNF","N",10,0})

aTam	:= TAMSX3("F3_CFO")
AADD(aCampCHC,{"CFO","C",aTam[1],aTam[2]})

aTam	:= TAMSX3("DT6_PESO")
AADD(aCampCHC,{"PESO","N",aTam[1],aTam[2]})

aTam	:= TAMSX3("DT6_TIPFRE")
AADD(aCampCHC,{"TIPFRE","C",aTam[1],aTam[2]})

aTam	:= TAMSX3("F3_BASEICM")
AADD(aCampCHC,{"BASEICM","N",aTam[1],aTam[2]})

aTam	:= TAMSX3("F3_VALICM")
AADD(aCampCHC,{"VALICM","N",aTam[1],aTam[2]})

//-- Tabela temporária MAN
oTempMA	:= FwTemporaryTable():New("MAN")
oTempMA:SetFields(aCampMAN)
oTempMA:Create()

cArqTrbMA	:= oTempMA:GetRealName()

//-- Tabela temporária NFC
oTempNF	:= FwTemporaryTable():New("NFC")
oTempNF:SetFields(aCampNFC)
oTempNF:AddIndex("01",{"FILDOC","DOC","SERIE","NUMNFC","SERNFC"})
oTempNF:Create()

cArqTrbNF	:= oTempNF:GetRealName()

//-- Tabela temporária CHC
oTempCT	:= FwTemporaryTable():New("CHC")
oTempCT:SetFields(aCampCHC)
oTempCT:Create()

cArqTrbCT	:= oTempCT:GetRealName()

AADD(aTrbs,{cArqTrbMA,"MAN"})
AADD(aTrbs,{cArqTrbNF,"NFC"})
AADD(aTrbs,{cArqTrbCT,"CHC"})

Return (aTrbs)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSSINClos  ºAutor  ³Katia               º Data ³ 29.12.2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta os arquivos temporarios processados                    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TWSSIDel                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/        
Function TMSSINClos (cArqTmp)
Local aSaveArea	:= GetArea()

Default cArqTmp   := ""

If cArqTmp == "MAN"
	oTempMA:Delete()
ElseIf cArqTmp == "NFC"
	oTempNF:Delete()
ElseIf cArqTmp == "CHC"
	oTempCT:Delete()
EndIf

RestArea(aSaveArea)
Return
