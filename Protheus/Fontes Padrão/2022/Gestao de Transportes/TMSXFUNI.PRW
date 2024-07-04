#INCLUDE "protheus.ch"
#INCLUDE "TMSXFUNI.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSDadCRT ³ Autor ³ Richard Anderson      ³ Data ³23.11.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna dados do CRT                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Campo                                              ³±±
±±³          ³ ExpC2 - Filial do Documento                                ³±±
±±³          ³ ExpC3 - Numero do Documento                                ³±±
±±³          ³ ExpC4 - Serie do Documento                                 ³±±
±±³          ³ ExpL5 - Lote da Nota Fiscal                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS - Transporte Internacional                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSDadCRT(cCampo,cFilDoc,cDoc,cSerie,lLotNfc)

Local   nA,nI
Local   aRet      := {}
Local   cMemo     := ''
Local   cMsMM     := ''
Local   nDados    := 0
Local   xRet      := ''
Local   nRet      := 0
Local   nPict     := 0
Local   aPicts    := {}
Local   aPictsUsr := {}
Local   cCodReg   := ''
Local   cFilCol   := ''
Local   cAliasQry := GetNextAlias()
Local   cAliasDIB := GetNextAlias()
Local   aAreaDTC  := DTC->(GetArea())
Local   aAreaSYA  := SYA->(GetArea())        
Local   cSimbMd   := ''                       
Local   lTemDIB   := .F.
Local   nValTot   := 0
Local   nTamSYP   := TamSX3('YP_TEXTO')[1]
Local   nTam      := nTamSYP
Local   nCnt      := 0
Local   nDif      := 0
Local   lDTCFound := .F.

Default cFilDoc   := ''
Default cDoc      := ''
Default cSerie    := ''
Default lLotNfc   := .F.

//--Se o status for cancelado, o DT6 foi excluido, precisa ativar os deletados
If DIK->DIK_STATUS == "9" //--Cancelado
	dbSelectArea("DT6")
	SET DELETED OFF
EndIf

//-- Se nao enviar o documento, considera que jah esteja posicionado
If lLotNfc
	DTC->(dbSetOrder(1))
	If DTC->(dbSeek(xFilial('DTC')+cFilDoc+cDoc))
		cSimbMd := Padr(GetMv('MV_SIMB'+Str(DTC->DTC_MOEDA,1),,1),4)
		lDTCFound := .T.
	EndIf
Else
	If !Empty(cDoc)
		DT6->(dbSetOrder(1))
		DTC->(dbSetOrder(3))
		DIK->(DbSetOrder(1))
		If DT6->(dbSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie))
			If DIK->(dbSeek(xFilial('DIK')+DT6->DT6_FILORI+DT6->DT6_LOTNFC))
				If Empty(DT6->DT6_DOCDCO) //--Carregamento Total
					DTC->(MsSeek(xFilial('DTC')+cFilDoc+cDoc+cSerie))
				Else //--Carregamento Parcial
					DTC->(MsSeek(xFilial('DTC')+DT6->DT6_FILDCO+DT6->DT6_DOCDCO+DT6->DT6_SERDCO))
				EndIf
				If DTC->(Found())
					cSimbMd := Padr(GetMv('MV_SIMB'+Str(DTC->DTC_MOEDA,1),,1),4)
					lDTCFound := .T.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf	

//-- Estrutura do Array aPicts
//-- [1] Campo
//-- [2] Picture para 1o. conteudo
//-- [3] Picture para 2o. conteudo
//-- [4] Qtde. de espaços entre o 1o conteudo e o 2o conteudo
Aadd(aPicts,{ '18', '', '', 0 })
Aadd(aPicts,{ '19', '', '@E 999,999.99', 1 })
Aadd(aPicts,{ '22', '', '@E 999,999.99', 1 })

If ExistBlock('TMPICCRT')
	aPictsUsr := ExecBlock('TMPICCRT',.F.,.F.,{ cCampo, aPicts })
	If ValType(aPictsUsr) == 'A' .And. Len(aPictsUsr) == Len(aPicts)
		aPicts := AClone(aPictsUsr)
	EndIf
EndIf

//-- Pesquisa o ultimo Sequencia de Alteracao do Campo
If !Empty(cDoc)
	DIB->(dbSetOrder(1))
	cQuery := "SELECT DIB_CODINF FROM "
	cQuery += RetSqlName("DIB")+" DIB "
	cQuery += " WHERE DIB.DIB_FILIAL = '"+xFilial("DIB")+"'"
	cQuery += "   AND DIB.DIB_FILDOC = '"+cFilDoc+"'"
	cQuery += "   AND DIB.DIB_DOC    = '"+cDoc   +"'"
	cQuery += "   AND DIB.DIB_SERIE  = '"+cSerie +"'"
	cQuery += "   AND DIB.DIB_CPODOC = '"+cCampo +"'"	
	cQuery += "   AND DIB.D_E_L_E_T_ = ' '" 
	cQuery += " ORDER BY DIB_FILDOC,DIB_DOC,DIB_SERIE,DIB_CPODOC,DIB_SEQUEN DESC"	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDIB)
	If (cAliasDIB)->(!Eof())
		lTemDIB := .T.
	Else
		lTemDIB := .F.
	EndIf	
Else
	lTemDIB := .F.
EndIf	
If cCampo == '01' //-- Dados do Remetente
	nDados := 4
	nTam   := TamSX3('DIK_DADREM')[1]
	If lTemDIB
		cMemo:= (cAliasDIB)->DIB_CODINF
	Else 
		aRet := TMSDadCli(DT6->DT6_CLIREM,DT6->DT6_LOJREM)
	EndIf
	
ElseIf cCampo == '04' //-- Dados do Destinatario
	nDados := 4
	nTam   := TamSX3('DIK_DADDES')[1]
	If lTemDIB
		cMemo:= (cAliasDIB)->DIB_CODINF
	Else
		aRet := TMSDadCli(DT6->DT6_CLIDES,DT6->DT6_LOJDES,2)
	EndIf
	
ElseIf cCampo == '05' //-- Localidade e Pais
	nDados := 1
	nTam   := TamSX3('DIK_LCPAIS')[1]
	If lTemDIB
		cMemo:= (cAliasDIB)->DIB_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		xRet := ''
		If lDTCFound
			xRet := AllTrim(Posicione('DUY',1,xFilial('DUY')+DTC->DTC_CDRORI,'DUY_DESCRI'))+"/"+DUY->DUY_EST+' '+;
				AllTrim(E_Field('DUY_PAIS','YA_DESCR'))
		EndIf
		nPict:= Ascan(aPicts,{ | e | e[1] == cCampo })
		If nPict > 0 .And. !Empty(aPicts[nPict,2])
			xRet := Transform(xRet,aPicts[nPict,2])
		EndIf
		aRet[1] := xRet
	EndIf		
	
ElseIf cCampo == '06' //-- Dados do Consignatario
	nDados := 4
	nTam   := TamSX3('DIK_DADCON')[1]
	If lTemDIB
		cMemo:= (cAliasDIB)->DIB_CODINF
	Else
		aRet := TMSDadCli(DT6->DT6_CLICON,DT6->DT6_LOJCON,2)
	EndIf
	
ElseIf cCampo == '07' //-- Localidade Mercadoria
	nDados := 1
	nTam   := TamSX3('DIK_LCMERC')[1]
	If lTemDIB
		cMemo:= (cAliasDIB)->DIB_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		If lDTCFound
			If !Empty(DTC->DTC_FILCFS)
				cFilCol := DTC->DTC_FILCFS
			Else
				cFilCol := DTC->DTC_FILORI
			EndIf
			aRet[1] := TMSDadLMe(DTC->DTC_DATENT,cFilCol,DTC->DTC_NUMSOL,DTC->DTC_CLIREM,DTC->DTC_LOJREM)
		EndIf		
	EndIf		
	
ElseIf cCampo == '08' //-- Localidade de Entrega
	nDados := 1
	nTam   := TamSX3('DIK_LCENTR')[1]
	If lTemDIB
		cMemo:= (cAliasDIB)->DIB_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		aRet[1] := TMSDadLEt(DT6->DT6_CLIDES,DT6->DT6_LOJDES)
	EndIf		
	
ElseIf cCampo == '09' //-- Cliente a Notificar
	nDados := 5
	nTam   := TamSX3('DIK_DADNOT')[1]
	aRet := Array(nDados)
	Afill(aRet,'')
	If lTemDIB
		cMemo:= (cAliasDIB)->DIB_CODINF
	ElseIf lDTCFound
		aRet := TMSDadCli(DTC->DTC_CLINOT,DTC->DTC_LOJNOT,2)
	EndIf
	
ElseIf cCampo == '11' //-- Descricao das Mercadorias
	nDados := 12
	nTam   := TamSX3('DIK_DADMER')[1]
	cMemo  := ""
	If lTemDIB
		cMemo:= (cAliasDIB)->DIB_CODINF
	ElseIf lDTCFound
		cMemo:= DTC->DTC_CODOBS
	EndIf                                            
	
ElseIf cCampo == '12' //--  Peso bruto em Kg
	nDados := 2
	aRet   := Array(nDados)
	Afill(aRet,'')
	//--Utilizar o DIK pois no parcial o DT6 e proporcional
	aRet[1] := DIK->DIK_PESO
	aRet[2] := DIK->DIK_PESLIQ
	
ElseIf cCampo == '13' //--Metro3
	nDados := 1
	aRet   := Array(nDados)
	Afill(aRet,'')
	//--Utilizar o DIK pois no parcial o DT6 e proporcional
	aRet[1] := Transform(DIK->DIK_METRO3,"@E 9999,999.999")

ElseIf cCampo == '14' //--  Valor
	nDados := 2
	aRet   := Array(nDados)
	Afill(aRet,'')
	aRet[1] := Transform(DIK->DIK_VALOR,"@E 999,999,999.99")
	aRet[2] := cSimbMd

ElseIf cCampo == '16' //--Declarao da Mercadoria
	nDados := 2
	aRet   := Array(nDados)
	Afill(aRet,'')
	aRet[1] := Transform(DIK->DIK_VALMER,"@E 999,999,999.99")
	aRet[2] := cSimbMd

ElseIf cCampo == '17' //-- Documentos Anexos
	nDados := 4
	nTam   := TamSX3('DIK_DOCANE')[1]
	If lTemDIB
		cMemo:= (cAliasDIB)->DIB_CODINF
	Else	
		DIB->(dbSetOrder(1))
		cAliasDIB := GetNextAlias()
		cQuery := "SELECT DIB_CODINF FROM "
		cQuery += RetSqlName("DIB")+" DIB "
		cQuery += " WHERE DIB.DIB_FILIAL = '"+xFilial("DIB")+"'"
		If !Empty(DT6->DT6_DOCDCO) //--Carregamento Parcial
			cQuery += "   AND DIB.DIB_FILDOC = '"+DT6->DT6_FILDCO+"'"
			cQuery += "   AND DIB.DIB_DOC    = '"+DT6->DT6_DOCDCO+"'"
			cQuery += "   AND DIB.DIB_SERIE  = '"+DT6->DT6_SERDCO +"'"
		Else //--Carregamento Total
			cQuery += "   AND DIB.DIB_FILDOC = '"+cFilDoc+"'"
			cQuery += "   AND DIB.DIB_DOC    = '"+cDoc+"'"
			cQuery += "   AND DIB.DIB_SERIE  = '"+cSerie+"'"
		EndIf
		cQuery += "   AND DIB.DIB_CPODOC = '"+cCampo +"'"	
		cQuery += "   AND DIB.D_E_L_E_T_ = ' '" 
		cQuery += " ORDER BY DIB_FILDOC,DIB_DOC,DIB_SERIE,DIB_CPODOC,DIB_SEQUEN DESC"	
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDIB)
		If (cAliasDIB)->(!Eof())
			cMemo:= (cAliasDIB)->DIB_CODINF
		EndIf
	EndIf
	
ElseIf cCampo == '18' //-- Instrucoes de Alfandega
	nDados := 3
	nTam   := TamSX3('DIK_DADIAF')[1]
	If lTemDIB .And. Empty(DIK->DIK_CODADU)
		cMemo:= (cAliasDIB)->DIB_CODINF
	Else
	 	aRet     := Array(4)
		If lDTCFound 
			aRet := TMSDadIAF(DTC->DTC_ROTA)
		EndIf
	EndIf
	
ElseIf cCampo == '19' //-- Valor do Frete Externo
	nDados := 1
	If lTemDIB
		cMemo:= (cAliasDIB)->DIB_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		nPict:= Ascan(aPicts,{ | e | e[1] == '19' })
   	If nPict > 0 .And. !Empty(aPicts[nPict,2])
   		xRet := Transform(xRet,aPicts[nPict,2])
   		If aPicts[nPict,4] > 0
  				xRet += Space(aPicts[nPict,4])
			EndIf 
		EndIf
		aRet[1] := xRet
		xRet    := ''
		If lDTCFound
			xRet    := Posicione("DIK",1,xFilial("DIK")+DTC->(DTC_FILORI+DTC_LOTNFC),"DIK_VALFEX")
		EndIf
		If nPict > 0 .And. !Empty(aPicts[nPict,3])
			xRet := Transform(xRet,aPicts[nPict,3])
		EndIf   		
		aRet[1] += xRet                                               
	EndIf		
	
ElseIf cCampo == '21' //-- Nome e assinatura do remetente
	nDados := 1
	nTam   := TamSX3('DIK_NOMREM')[1]
	If lTemDIB
		cMemo:= (cAliasDIB)->DIB_CODINF
	Else
		aRet := Array(nDados)
		aRet[1] := Space(TamSX3('DIK_NOMREM')[1])
	EndIf
	
ElseIf cCampo == '22' //-- Declaracoes e Observacoes
	nDados := 7
	nTam   := TamSX3('DIK_DADDCL')[1]
	If lTemDIB
		cMemo:= (cAliasDIB)->DIB_CODINF
	Else
		aRet := Array(nDados)
		nI   := 2
		Afill(aRet,'')
		If TMSCfgCRT(cFilDoc,cDoc,cSerie,'22') != "2" //-- Nao Imprime
			If lDTCFound .And. (DTC->DTC_INCOTE == "DAF" .Or. DTC->DTC_INCOTE == "DDU")
				aRet[1] := "FLETE PAGADERO EN ORIGEM E DESTINO"
			ElseIf lDTCFound .And. DTC->DTC_TIPFRE == "1" //-- CIF
				aRet[1] := "FLETE PAGADERO EN ORIGEM"
			Else
				aRet[1] := "FLETE PAGADERO EN DESTINO"
			EndIf
			If lDTCFound .And. TMSCfgCRT(cFilDoc,cDoc,cSerie,'22') != "3" //-- Somente Frete
				cAliasQry := GetNextAlias()
				DI9->(dbSetOrder(1))
				cQuery := "SELECT DI3_DESFRT, DI9_VALTOT FROM "
				cQuery += RetSqlName("DI9")+" DI9 "
				cQuery += "  LEFT JOIN "
				cQuery += RetSqlName("DI3")+" DI3 "
				cQuery += "    ON DI3.DI3_FILIAL = '"+xFilial("DI3") +"'"
				cQuery += "   AND DI3.DI3_PAIS   = DI9_PAIS"
				cQuery += "   AND DI3.D_E_L_E_T_ = ' '"
				cQuery += " WHERE DI9.DI9_FILIAL = '"+xFilial("DI9") +"'"
				If !Empty(DTC->DTC_DOC) .And. DTC->DTC_SERIE != 'PED' 
					cQuery += "AND DI9.DI9_FILDOC = '"+DTC->DTC_FILDOC+"'"
					cQuery += "AND DI9.DI9_DOC    = '"+DTC->DTC_DOC   +"'"
					cQuery += "AND DI9.DI9_SERIE  = '"+DTC->DTC_SERIE +"'"
				Else
					cQuery += "AND DI9.DI9_FILORI = '"+DTC->DTC_FILORI+"' "
					cQuery += "AND DI9.DI9_LOTNFC = '"+DTC->DTC_LOTNFC+"' "
				EndIF					
				cQuery += "   AND DI9.D_E_L_E_T_ = ' '"
				cQuery += " ORDER BY "+SqlOrder(DI9->(IndexKey()))
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
				TcSetField(cAliasQry,"DI9_VALTOT","N",TamSX3("DI9_VALTOT")[1],TamSX3("DI9_VALTOT")[2])
				nPict  := Ascan(aPicts,{ | e | e[1] == '22' })
				While (cAliasQry)->(!Eof())
					If nI > 4
						Exit
					EndIf					
					xRet := Padr(AllTrim((cAliasQry)->DI3_DESFRT),Len(DI3->DI3_DESFRT),".")+cSimbMd
					If nPict > 0 .And. !Empty(aPicts[nPict,2])
						xRet := Transform(xRet,aPicts[nPict,2])
						If aPicts[nPict,4] > 0
			  				xRet += Space(aPicts[nPict,4])
						EndIf 
					EndIf						
					aRet[nI] := xRet
					If nPict > 0 .And. !Empty(aPicts[nPict,3])
						xRet  := Transform((cAliasQry)->DI9_VALTOT,aPicts[nPict,3])
					Else
						xRet  := (cAliasQry)->DI9_VALTOT 			   		
					EndIf
					aRet[nI] += xRet
					nValTot  += (cAliasQry)->DI9_VALTOT
					nI += 1
					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())
				aRet[nI] := Replicate(".",Len(DI3->DI3_DESFRT)+Len(xRet)+4)
				nI += 1
				xRet := Padr("TOTAL DEL FLETE",Len(DI3->DI3_DESFRT),".")+cSimbMd
				If nPict > 0 .And. !Empty(aPicts[nPict,2])
					xRet := Transform(xRet,aPicts[nPict,2])
					If aPicts[nPict,4] > 0
		  				xRet += Space(aPicts[nPict,4])
					EndIf 
				EndIf						
				aRet[nI] := xRet
				If nPict > 0 .And. !Empty(aPicts[nPict,3])
					xRet  := Transform(nValTot,aPicts[nPict,3])
				Else
					xRet  := nValTot
				EndIf
				aRet[nI] += xRet
			EndIf					
		EndIf				
	EndIf			
EndIf
If !Empty(cMemo)
	If nTam >= nTamSYP
		nTam := nTamSYP
	EndIf
	aRet := Array(nDados)
	xRet := ''
	nI   := 1
	cMsMM:= MsMM(cMemo,nTam)
	Afill(aRet,'')
	For nRet := 1 To Len(cMsMM)
		If Substr(cMsMM,nRet,1) == Chr(13) .Or. Len(xRet) > nTam
			If Substr(cMsMM,nRet,1) == Chr(13)		
				nRet += 2			
			ElseIf !Empty(Substr(cMsMM,nRet,1))
				For nCnt:= Len(xRet) To 1 Step -1
					If Empty(Substr(xRet,nCnt,1))
						nDif := (nTam - nCnt)+1
						xRet := Substr(xRet,1,(nTam - nDif))
						nRet -= nDif
						Exit
					EndIf
				Next nCnt
			EndIf
			aRet[nI] := xRet
			xRet := ''
			nI   += 1
			If nI > nDados
				Exit
			ElseIf Substr(cMsMM,nRet,1) == Chr(13)
				//-- Se o proximo caracter foi <enter> não soma na string xRet
				nRet -= 1
				Loop
			EndIf
		EndIf
		xRet += Substr(cMsMM,nRet,1)
	Next nRet
	If !Empty(xRet) .And. nI <= nDados
		If Len(xRet) < nTam .And. ValType(xRet) == "C"
			xRet += Replicate(' ',nTam-Len(xRet))
		EndIf
		aRet[nI] := xRet
	EndIf
ElseIf Len(aRet) == 0
	aRet := Array(nDados)
	Afill(aRet,'')
EndIf

If ExistBlock('TMDADCRT')
	aRetUsr := ExecBlock('TMDADCRT',.F.,.F.,{ cCampo, aRet, cFilDoc, cDoc, cSerie })
	If ValType(aRetUsr) == 'A'
		aRet := AClone(aRetUsr)
	EndIf
EndIf

If Select((cAliasDIB)) > 0
	(cAliasDIB)->(dbCloseArea())
EndIf

//--Apos a utilizacao, voltar os deletados ao estado normal
If DIK->DIK_STATUS == "9" //--Cancelado
	dbSelectArea("DT6")
	SET DELETED ON
EndIf

RestArea(aAreaDTC)
RestArea(aAreaSYA)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSDadMIC ³ Autor ³ Richard Anderson      ³ Data ³31.10.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna dados do MIC/DTA                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Nome do Campo                                      ³±±
±±³          ³ ExpC2 - Alias da Query                                     ³±±
±±³          ³ ExpC3 - Filial do MIC/DTA                                  ³±±
±±³          ³ ExpC4 - Numero do MIC/DTA                                  ³±±
±±³          ³ ExpC5 - Codigo do Veiculo                                  ³±±
±±³          ³ ExpC6 - Item do MIC/DTA                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS - Transporte Internacional                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSDadMIC(cCampo,cAliasQry,cFilMIC,cNumMIC,cCodVei,cIteMIC)

Local   nA,nI
Local   aRet      := {}
Local   aLacres   := {}
Local   cCdaOri   := ''
Local   cCdaDes   := ''
Local   aAreaDA3  := DA3->(GetArea())
Local   aAreaDA8  := DA8->(GetArea())
Local   aAreaDTC  := DTC->(GetArea())
Local   aAreaDTQ  := DTQ->(GetArea())
Local   aAreaDTR  := DTR->(GetArea())
Local   aAreaDID  := DID->(GetArea())
Local   aAreaDII  := DII->(GetArea())
Local   aAreaDIJ  := DIJ->(GetArea())
Local   aAreaSA2  := SA2->(GetArea())
Local   aAreaSYA  := SYA->(GetArea())
Local   cMemo     := ''
Local   cMsMM     := ''
Local   nDados    := 0
Local   cRota     := ''
Local   cFilOri   := ''
Local   cViagem   := ''
Local   cCdrDes   := ''
Local   cCodFor   := ''
Local   cLojFor   := ''
Local   nMoeda    := 0
Local   nValSeg   := 0
Local   nQtdVol   := 0
Local   cFilDoc   := ''
Local   cDoc      := ''
Local   cSerie    := ''
Local   xRet      := ''
Local   nRet      := 0
Local   nPict     := 0
Local   aPicts    := {}
Local   aPictsUsr := {} 
Local   cAliasQr1 := GetNextAlias()
Local   cAliasQr2 := GetNextAlias()
Local   lVal      := .F.
Local   nTamSYP   := TamSX3('YP_TEXTO')[1]
Local   nTam      := nTamSYP
Local   nDif      := 0
Local   nCnt      := 0

Default cAliasQry := ''
Default cFilMIC   := ''
Default cNumMIC   := ''
Default cCodVei   := ''
Default cIteMIC   := ''

//-- Estrutura do Array aPicts
//-- [1] Campo
//-- [2] Picture para 1o. conteudo
//-- [3] Picture para 2o. conteudo
//-- [4] Qtde. de espaços entre o 1o conteudo e o 2o conteudo
Aadd(aPicts,{ '07', '', '', 1 })
Aadd(aPicts,{ '08', '', '', 1 })
Aadd(aPicts,{ '09', '', '', 0 })
Aadd(aPicts,{ '10', PesqPict('SA2','A2_CGC')    , '', 0 })
Aadd(aPicts,{ '11', PesqPict('DA3','DA3_PLACA') , '', 0 })
Aadd(aPicts,{ '12', '', '', 1 })
Aadd(aPicts,{ '13', PesqPict('DA3','DA3_CAPACN'), '', 0 })
Aadd(aPicts,{ '14', '', '', 1 })
Aadd(aPicts,{ '15', '', '', 1 })
Aadd(aPicts,{ '24', '', '@R X X X X X X X', 0 })
Aadd(aPicts,{ '25', '', '', 0 })
Aadd(aPicts,{ '26', '', '', 1 }) //'@R X X X', 1 })
Aadd(aPicts,{ '27', '@E 9,999,999.99', '', 0 })
Aadd(aPicts,{ '29', '@E 9,999,999.99', '', 0 })
Aadd(aPicts,{ '31', '@E 99,999', '', 0 })
Aadd(aPicts,{ '32', '@E 999,999.9999', '', 0 })
Aadd(aPicts,{ '41', '@E 999,999.9999', '', 0 })

If ExistBlock('TMPICMIC')
	aPictsUsr := ExecBlock('TMPICMIC',.F.,.F.,{ cCampo, aPicts })
	If ValType(aPictsUsr) == 'A' .And. Len(aPictsUsr) == Len(aPicts)
		aPicts := AClone(aPictsUsr)
	EndIf
EndIf			
//-- Pesquisa o ultimo Sequencia de Alteracao do Campo
cQuery := "SELECT DIJ_CODINF FROM "
cQuery += RetSqlName("DIJ")+" DIJ "
cQuery += " WHERE DIJ.DIJ_FILIAL = '"+xFilial("DIJ")+"'"
cQuery += "   AND DIJ.DIJ_FILMIC = '"+cFilMIC+"' "
cQuery += "   AND DIJ.DIJ_NUMMIC = '"+cNumMIC+"' "
cQuery += "   AND DIJ.DIJ_CODVEI = '"+cCodVei+"' "
cQuery += "   AND DIJ.DIJ_ITEMIC = '"+cIteMIC+"' "	
cQuery += "   AND DIJ.DIJ_CPOMIC = '"+cCampo +"' "	
cQuery += "   AND DIJ.D_E_L_E_T_  = ' '" 
cQuery += " ORDER BY DIJ_FILMIC,DIJ_NUMMIC,DIJ_CODVEI,DIJ_ITEMIC,DIJ_CPOMIC,DIJ_SEQUEN DESC"	
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQr2)

If cCampo == '06' //-- Data de Emissao do MIC
	nDados := 1
	nTam   := TamSX3('DIJ_DATMIC')[1]
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		DID->(dbSetOrder(1))
		If DID->(dbSeek(xFilial('DID')+cFilMIC+cNumMIC+cCodVei))
			xRet := DID->DID_DATMIC
			aRet[1] := xRet
		EndIf
	EndIf
ElseIf cCampo == '07' //-- Alfândega
	nDados := 2
	nTam   := TamSX3('DIJ_DADAFP')[1]
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		If !Empty(cAliasQry)
			cCdaOri := (cAliasQry)->DII_CDAORI
		Else		
			DII->(dbSetOrder(1))		
			If DII->(dbSeek(xFilial('DII')+cFilMIC+cNumMIC+cCodVei+cIteMIC))
				cCdaOri := DII->DII_CDAORI
			EndIf
		EndIf
		nPict := Ascan(aPicts,{ | e | e[1] == '07' })
		xRet  := AllTrim(Posicione('DI1',1,xFilial('DI1')+cCdaOri,'DI1_NOME'))+" / "+;
   	         AllTrim(Posicione('SYA',1,xFilial('SYA')+DI1->DI1_PAIS,'YA_DESCR'))
   	If nPict > 0 .And. !Empty(aPicts[nPict,2])
   		xRet := Transform(xRet,aPicts[nPict,2])
   		If aPicts[nPict,4] > 0
   			xRet += Space(aPicts[nPict,4])
			EndIf 
		EndIf
		aRet[1] := xRet
		If nPict > 0 .And. !Empty(aPicts[nPict,3])
			xRet := Transform(AllTrim(DI1->DI1_CODADU),aPicts[nPict,3])
		Else
			xRet := AllTrim(DI1->DI1_CODADU)					
		EndIf			
		aRet[2] := xRet
	EndIf
ElseIf cCampo == '08' //-- Cidade e pais de destino final
	nTam   := TamSX3('DIJ_DADCDF')[1]
	nDados := 4
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		DII->(dbSetOrder(1))
		DT6->(DbSetOrder(1))
		If DII->(dbSeek(xFilial('DII')+cFilMIC+cNumMIC+cCodVei+cIteMIC))
			DT6->(dbSeek(xFilial('DT6')+DII->(DII_FILDOC+DII_DOC+DII_SERIE)))
			nPict   := Ascan(aPicts,{ | e | e[1] == '08' })
   		xRet    := TMSDadLet(DT6->DT6_CLIDES,DT6->DT6_LOJDES,.T.)
			aRet[1] += xRet
		EndIf
	EndIf		
ElseIf cCampo == '09' //-- Caminhão Original
	nDados := 4
	nTam   := TamSX3('DIJ_DADPRC')[1]
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')		
		DA3->(dbSetOrder(1))
		DA3->(dbSeek(xFilial('DA3')+cCodVei))
		//--Campos do Permissionado, criado para o Internacional
		//--Se o permissionado estiver preenchido, ele vai aparecer no MIC/DTA
		If DA3->(FieldPos('DA3_CODPER')) > 0 .And. DA3->(FieldPos('DA3_LOJPER')) > 0
			If !Empty(DA3->DA3_CODPER) .And. !Empty(DA3->DA3_LOJPER)
				cCodFor := DA3->DA3_CODPER
				cLojFor := DA3->DA3_LOJPER
		   Else
				cCodFor := DA3->DA3_CODFOR
				cLojFor := DA3->DA3_LOJFOR
		   EndIf
		Else
			cCodFor := DA3->DA3_CODFOR
			cLojFor := DA3->DA3_LOJFOR
		EndIf		
		SA2->(dbSetOrder(1))
		SA2->(dbSeek(xFilial('SA2')+cCodFor+cLojFor))
		//--Linha 1
		xRet := AllTrim(SA2->A2_NOME)		
		nPict   := Ascan(aPicts,{ | e | e[1] == '09' })
   	If nPict > 0 .And. !Empty(aPicts[nPict,2])
   		xRet := Transform(xRet,aPicts[nPict,2])
   		If aPicts[nPict,4] > 0
  				xRet += Space(aPicts[nPict,4])
			EndIf 
		EndIf   		
		aRet[1] := xRet
		//--Linha 2
		xRet    := AllTrim(SA2->A2_END)+"/"+SA2->A2_MUN
   	If nPict > 0 .And. !Empty(aPicts[nPict,3])
   		xRet := Transform(xRet,aPicts[nPict,3])
		EndIf   		
		aRet[2] := xRet
		//--Linha 3
		xRet    := AllTrim(SA2->A2_EST)+" - "+Posicione("SYA",1,xFilial("SYA")+SA2->A2_PAIS,"YA_DESCR")
   	If nPict > 0 .And. !Empty(aPicts[nPict,3])
   		xRet := Transform(xRet,aPicts[nPict,3])
		EndIf
		aRet[3] := xRet
	EndIf			
ElseIf cCampo == '10' //-- Cadastro geral do contribuinte
	nDados := 1
	nTam   := TamSX3('DIJ_DADCTB')[1]
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')		
		DA3->(dbSetOrder(1))
		DA3->(dbSeek(xFilial('DA3')+cCodVei))
		//--Campos do Permissionado, criado para o Internacional
		//--Se o permissionado estiver preenchido, ele vai aparecer no MIC/DTA
		If DA3->(FieldPos('DA3_CODPER')) > 0 .And. DA3->(FieldPos('DA3_LOJPER')) > 0
			If !Empty(DA3->DA3_CODPER) .And. !Empty(DA3->DA3_LOJPER)
				cCodFor := DA3->DA3_CODPER
				cLojFor := DA3->DA3_LOJPER
		   Else
				cCodFor := DA3->DA3_CODFOR
				cLojFor := DA3->DA3_LOJFOR
		   EndIf
		Else
			cCodFor := DA3->DA3_CODFOR
			cLojFor := DA3->DA3_LOJFOR
		EndIf		
		SA2->(dbSetOrder(1))
		SA2->(dbSeek(xFilial('SA2')+cCodFor+cLojFor))
		xRet := AllTrim(SA2->A2_CGC)		
		aRet[1] := xRet
	EndIf		
ElseIf cCampo == '11' //-- Placa do caminhão
	nDados := 1
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		nPict:= Ascan(aPicts,{ | e | e[1] == '11' })
		xRet := Posicione('DA3',1,xFilial('DA3')+cCodVei,'DA3_PLACA')
   	If nPict > 0 .And. !Empty(aPicts[nPict,2])
   		xRet := Transform(xRet,aPicts[nPict,2])
   		If aPicts[nPict,4] > 0
  				xRet += Space(aPicts[nPict,4])
			EndIf 
		EndIf   		
		aRet[1] := xRet
	EndIf		
ElseIf cCampo == '12' //-- Marca e numero
	nDados := 2
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		nPict:= Ascan(aPicts,{ | e | e[1] == '12' })
		xRet := Tabela('M6',Posicione('DA3',1,xFilial('DA3')+cCodVei,'DA3_MARVEI'),.F.)
   	If nPict > 0 .And. !Empty(aPicts[nPict,2])
   		xRet := Transform(xRet,aPicts[nPict,2])
   		If aPicts[nPict,4] > 0
  				xRet += Space(aPicts[nPict,4])
			EndIf 
		EndIf   		
		aRet[1] := xRet
		xRet    := DA3->DA3_CHASSI
   	If nPict > 0 .And. !Empty(aPicts[nPict,3])
   		xRet := Transform(xRet,aPicts[nPict,3])
		EndIf   		
		aRet[2] := xRet
	EndIf		
ElseIf cCampo == '13' //-- Capacidade de tração
	nDados := 1
	lVal   := .T.
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		nPict:= Ascan(aPicts,{ | e | e[1] == '13' })
		xRet := Posicione('DA3',1,xFilial('DA3')+cCodVei,'DA3_CAPACN')
   	If nPict > 0 .And. !Empty(aPicts[nPict,2])
   		xRet := Transform(xRet,aPicts[nPict,2])
   		If aPicts[nPict,4] > 0
  				xRet += Space(aPicts[nPict,4])
			EndIf 
		EndIf   		
		aRet[1] := xRet
	EndIf		
ElseIf cCampo == '14' //-- Ano
	nDados := 1
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		nPict:= Ascan(aPicts,{ | e | e[1] == '14' })
		xRet := Posicione('DA3',1,xFilial('DA3')+cCodVei,'DA3_ANOFAB')
   	If nPict > 0 .And. !Empty(aPicts[nPict,2])
   		xRet := Transform(xRet,aPicts[nPict,2])
   		If aPicts[nPict,4] > 0
  				xRet += Space(aPicts[nPict,4])
			EndIf 
		EndIf   		
		aRet[1] := xRet
	EndIf
ElseIf cCampo == '15' //-- Reboque
	nDados := 1
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		If !Empty(cAliasQry)
			cFilOri := (cAliasQry)->DID_FILORI
			cViagem := (cAliasQry)->DID_VIAGEM
		Else 
			cFilOri := Posicione('DID',1,xFilial('DID')+cFilMIC+cNumMIC+cCodVei,'DID_FILORI')
			cViagem := DID->DID_VIAGEM
		EndIf			
		DTR->(dbSetOrder(3))
		If DTR->(dbSeek(xFilial('DTR')+cFilOri+cViagem+cCodVei)) .And. !Empty(DTR->DTR_CODRB1)
			xRet := Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODRB1,'DA3_PLACA')
		EndIf
		nPict := Ascan(aPicts,{ | e | e[1] == '15' })
   	If nPict > 0 .And. !Empty(aPicts[nPict,2])
   		xRet := Transform(xRet,aPicts[nPict,2])
   		If aPicts[nPict,4] > 0
  				xRet += Space(aPicts[nPict,4])
			EndIf 
		EndIf   		
		aRet[1] := xRet
	EndIf		
ElseIf cCampo == '16' //-- Caminhão Substituto
	nDados := 4
	nTam   := TamSX3('DIJ_DADPR2')[1]
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
   Else
		aRet := Array(nDados)
		Afill(aRet,'')
	EndIf			
ElseIf cCampo == '17' //-- Cadastro geral do contribuinte
	nDados := 1
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
   Else
		aRet := Array(nDados)
		Afill(aRet,'')
	EndIf		
ElseIf cCampo == '18' //-- Placa do caminhao
	nDados := 1
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
   Else
		aRet := Array(nDados)
		Afill(aRet,'')	
	EndIf		
ElseIf cCampo == '19' //-- Marca e numero
	nDados := 2
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
   Else
		aRet := Array(nDados)
		Afill(aRet,'')
	EndIf		
ElseIf cCampo == '20' //-- Capacidade de tracao
	nDados := 1
	lVal   := .T.	
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
   Else
		aRet := Array(nDados)
		Afill(aRet,'')
	EndIf		
ElseIf cCampo == '21' //-- Ano
	nDados := 1
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
   Else
		aRet := Array(nDados)
		Afill(aRet,'')
	EndIf
ElseIf cCampo == '22' 
	nDados := 1
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
   Else
		aRet := Array(nDados)
		Afill(aRet,'')
		If !Empty(cAliasQry)
			cFilOri := (cAliasQry)->DID_FILORI
			cViagem := (cAliasQry)->DID_VIAGEM
		Else 
			cFilOri := Posicione('DID',1,xFilial('DID')+cFilMIC+cNumMIC+cCodVei,'DID_FILORI')
			cViagem := DID->DID_VIAGEM
		EndIf			
		DTR->(dbSetOrder(3))
		If DTR->(dbSeek(xFilial('DTR')+cFilOri+cViagem+cCodVei)) .And. !Empty(DTR->DTR_CODRB2)
			xRet := Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODRB2,'DA3_PLACA')
		EndIf
		nPict := Ascan(aPicts,{ | e | e[1] == '22' })
   		If nPict > 0 .And. !Empty(aPicts[nPict,2])
   			xRet := Transform(xRet,aPicts[nPict,2])
   			If aPicts[nPict,4] > 0
  				xRet += Space(aPicts[nPict,4])
			EndIf 
		EndIf   		
		aRet[1] := xRet
	EndIf

ElseIf cCampo == '24' //-- Alfandega de destino  
	nDados := 2
	nTam   := TamSX3('DIJ_DADAFD')[1]
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		If !Empty(cAliasQry)
			cCdaDes := (cAliasQry)->DII_CDADES
		Else
			DII->(dbSetOrder(1))		
			If DII->(dbSeek(xFilial('DII')+cFilMIC+cNumMIC+cCodVei+cIteMIC))
				cCdaDes := DII->DII_CDADES
			EndIf
		EndIf		
	If !Empty(cAliasQry) .And. (cAliasQry)->(FieldPos('DT6_LOTNFC')) > 0
		If DIK->(dbSeek(xFilial('DIK')+(cAliasQry)->DID_FILORI+(cAliasQry)->DT6_LOTNFC))
			cCdaDes := Iif(!Empty(DIK->DIK_CODADU), DIK->DIK_CODADU, cCdaDes) 		
		EndIf
	EndIf 	
		nPict := Ascan(aPicts,{ | e | e[1] == '24' })
		xRet  := AllTrim(Posicione('DI1',1,xFilial('DI1')+cCdaDes,'DI1_NOME'))
   	If nPict > 0 .And. !Empty(aPicts[nPict,2])
   		xRet := Transform(xRet,aPicts[nPict,2])
   		If aPicts[nPict,4] > 0
  				xRet += Space(aPicts[nPict,4])
			EndIf 
		EndIf   		
		aRet[1] := xRet
		xRet    := DI1->DI1_CODADU
   	If nPict > 0 .And. !Empty(aPicts[nPict,3])
   		xRet := Transform(xRet,aPicts[nPict,3])
		EndIf   		
		aRet[2] := xRet
	EndIf		
ElseIf cCampo == '25' //-- Moeda
	nDados := 1
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		If !Empty(cAliasQry)
			nMoeda := (cAliasQry)->DT6_MOEDA
		Else
			DII->(dbSetOrder(1))		
			If DII->(dbSeek(xFilial('DII')+cFilMIC+cNumMIC+cCodVei+cIteMIC))
				nMoeda := Posicione('DT6',1,xFilial('DT6')+DII->(DII_FILDOC+DII_DOC+DII_SERIE),'DT6_MOEDA')
			EndIf
		EndIf							
		nPict := Ascan(aPicts,{ | e | e[1] == '25' })
		xRet  := GetMv('MV_SIMB'+Str(nMoeda,1),,'')
   	If nPict > 0 .And. !Empty(aPicts[nPict,2])
   		xRet := Transform(xRet,aPicts[nPict,2])
   		If aPicts[nPict,4] > 0
  				xRet += Space(aPicts[nPict,4])
			EndIf 
		EndIf   		
		aRet[1] := xRet
	EndIf      
ElseIf cCampo == '26' //-- Origem das Mercadorias
	nDados := 1
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		If !Empty(cAliasQry)
			cRota   := (cAliasQry)->DTQ_ROTA
		Else
			cFilOri := Posicione('DID',1,xFilial('DID')+cFilMIC+cNumMIC+cCodVei,'DID_FILORI')
			cViagem := DID->DID_VIAGEM
			cRota   := Posicione('DTQ',2,xFilial('DTQ')+cFilOri+cViagem,'DTQ_ROTA')			
		EndIf			
		cCdrOri := Posicione('DA8',1,xFilial('DA8')+cRota,'DA8_CDRORI')
		nPict   := Ascan(aPicts,{ | e | e[1] == '26' })
		xRet    := Posicione('SYA',1,xFilial('SYA')+Posicione('DUY',1,xFilial('DUY')+cCdrOri,'DUY_PAIS'),'YA_DESCR')+" "
   	If nPict > 0 .And. !Empty(aPicts[nPict,2])
   		xRet := Transform(xRet,aPicts[nPict,2])
   		If aPicts[nPict,4] > 0
  				xRet += Space(aPicts[nPict,4])
			EndIf 
		EndIf   		
		aRet[1] := xRet
		xRet    := SYA->YA_CODGI
   	If nPict > 0 .And. !Empty(aPicts[nPict,3])
   		xRet := Transform(xRet,aPicts[nPict,3])
		EndIf   		
		aRet[1] += xRet
	EndIf		
ElseIf cCampo == '27' //-- Valor FOT
	nDados := 1
	lVal   := .T.
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		If !Empty(cAliasQry)
			nValMer := (cAliasQry)->DT6_VALMER
		Else
			DII->(dbSetOrder(1))		
			If DII->(dbSeek(xFilial('DII')+cFilMIC+cNumMIC+cCodVei+cIteMIC))
				nValMer := Posicione('DT6',1,xFilial('DT6')+DII->(DII_FILDOC+DII_DOC+DII_SERIE),'DT6_VALMER')
			EndIf
		EndIf
		nPict   := Ascan(aPicts,{ | e | e[1] == '27' })
		xRet    := nValMer
   	If nPict > 0 .And. !Empty(aPicts[nPict,2])
   		xRet := Transform(xRet,aPicts[nPict,2])
   		If aPicts[nPict,4] > 0
  				xRet += Space(aPicts[nPict,4])
			EndIf 
		EndIf   		
		aRet[1] := xRet
	EndIf
	
ElseIf cCampo == '28' //--Valor do Frete
	nDados := 1
	nTam   := TamSX3('DIJ_VALTOT')[1]
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
		lVal := .T.
	Else
		aRet := Array(nDados)
		Afill(aRet,'')	

		DII->(dbSetOrder(1))	
		DII->(dbSeek(xFilial('DII')+cFilMIC+cNumMIC+cCodVei+cIteMIC))

		DT6->(dbSeek(xFilial('DT6')+DII->(DII_FILDOC+DII_DOC+DII_SERIE)))
		If DT6->DT6_VOLORI == DT6->DT6_QTDVOL
			xRet := DT6->DT6_VALTOT
		Else
			DTA->(dbSetOrder(1))
			If DTA->(dbSeek(xFilial('DTA')+DII->(DII_FILDOC+DII_DOC+DII_SERIE)))
				xRet := DTA->DTA_VALFRE //--Valor do Frete Carregado
			EndIf
		EndIf
		aRet[1] := xRet
	EndIf

ElseIf cCampo == '29' //-- Seguro
	nDados := 1
	lVal   := .T.
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		If !Empty(cAliasQry)
			cFilDoc := (cAliasQry)->DT6_FILDOC
			cDoc    := (cAliasQry)->DT6_DOC
			cSerie  := (cAliasQry)->DT6_SERIE
		Else
			DII->(dbSetOrder(1))		
			If DII->(dbSeek(xFilial('DII')+cFilMIC+cNumMIC+cCodVei+cIteMIC))
				cFilDoc := DII->DII_FILDOC
				cDoc    := DII->DII_DOC
				cSerie  := DII->DII_SERIE
			EndIf
		EndIf
		DT6->(DbSetOrder(1))
		If DT6->(dbSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie))
			//--Se for o documento parcial, pesquisar a nota com a serie do documento original
			If !Empty(DT6->DT6_SERDCO)
				cSerie := DT6->DT6_SERDCO
			EndIf
		EndIf
		DTC->(dbSetOrder(3))
		DTC->(dbSeek(cSeekDTC := xFilial('DTC')+cFilDoc+cDoc+cSerie))
		While DTC->(!Eof()) .And. DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE) == cSeekDTC
			nValSeg += DTC->DTC_VALSEG
			DTC->(dbSkip())
		EndDo
		nPict   := Ascan(aPicts,{ | e | e[1] == '29' })
		xRet    := nValSeg
   	If nPict > 0 .And. !Empty(aPicts[nPict,2])
   		xRet := Transform(xRet,aPicts[nPict,2])
   		If aPicts[nPict,4] > 0
  				xRet += Space(aPicts[nPict,4])
			EndIf 
		EndIf   		
		aRet[1] := xRet
	EndIf		
	
ElseIf cCampo == '30' //-- Tipo de Volumes
	nDados := 1
	nTam   := TamSX3('DIJ_DADEMB')[1]
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		DII->(dbSetOrder(1))
		DT6->(DbSetOrder(1))
		DTC->(dbSetOrder(3))
		If DII->(dbSeek(xFilial('DII')+cFilMIC+cNumMIC+cCodVei+cIteMIC))
			If DT6->(dbSeek(xFilial('DT6')+DII->(DII_FILDOC+DII_DOC+DII_SERIE)))
				//--Se nao encontrou o DTC e Carregamento Parcial, posicionar pelo documento original
				If !Empty(DT6->DT6_DOCDCO)
					DTC->(MsSeek(xFilial('DTC')+DT6->(DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO)))
				Else
					DTC->(MsSeek(xFilial('DTC')+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)))
				EndIf
				If DTC->(Found()) 
					aRet[1] := Tabela('MG',DTC->DTC_CODEMB,.F.)
				EndIf
			EndIf
		EndIf
	EndIf
	
ElseIf cCampo == '31' //-- Qtde.de Volumes
	nDados := 1                            
	lVal   := .T.
	If (cAliasQr2)->(!EOF())              
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		If !Empty(cAliasQry)
			nQtdVol := (cAliasQry)->DT6_QTDVOL
		Else
			DII->(dbSetOrder(1))
			If DII->(dbSeek(xFilial('DII')+cFilMIC+cNumMIC+cCodVei+cIteMIC))
				nQtdVol := Posicione('DT6',1,xFilial('DT6')+DII->(DII_FILDOC+DII_DOC+DII_SERIE),'DT6_QTDVOL')
			EndIf
		EndIf
		nPict := Ascan(aPicts,{ | e | e[1] == '31' })
		xRet  := nQtdVol
   	If nPict > 0 .And. !Empty(aPicts[nPict,2])
   		xRet := Transform(xRet,aPicts[nPict,2])
   		If aPicts[nPict,4] > 0
  				xRet += Space(aPicts[nPict,4])
			EndIf 
		EndIf
		aRet[1] := xRet
	EndIf
	
ElseIf cCampo == '32' //-- Peso
	nDados := 1                            
	lVal   := .T.
	nTam   := TamSX3('DIJ_PESO')[1]
	If (cAliasQr2)->(!EOF())              
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		DII->(dbSetOrder(1))		
		If DII->(dbSeek(xFilial('DII')+cFilMIC+cNumMIC+cCodVei+cIteMIC))			
			DT6->(DbSetOrder(1))
			If DT6->(dbSeek(xFilial('DT6')+DII->(DII_FILDOC+DII_DOC+DII_SERIE)))		
				xRet := DT6->DT6_PESO
			EndIf
		EndIf
		nPict := Ascan(aPicts,{ | e | e[1] == '32' })
   	If nPict > 0 .And. !Empty(aPicts[nPict,2])
   		xRet := Transform(xRet,aPicts[nPict,2])
   		If aPicts[nPict,4] > 0
  				xRet += Space(aPicts[nPict,4])
			EndIf 
		EndIf
		aRet[1] := xRet
	EndIf
	
ElseIf cCampo == '33' //-- Dados do Remetente
	nDados := 4
	nTam   := TamSX3('DIJ_DADREM')[1]
	If (cAliasQr2)->(!Eof())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		DII->(dbSetOrder(1))
		If DII->(dbSeek(xFilial('DII')+cFilMIC+cNumMIC+cCodVei+cIteMIC))
			DT6->(dbSetOrder(1))
			DT6->(dbSeek(xFilial('DT6')+DII->(DII_FILDOC+DII_DOC+DII_SERIE)))
			aRet := TMSDadCli(DT6->DT6_CLIREM,DT6->DT6_LOJREM)
		EndIf
	EndIf
	
ElseIf cCampo == '34' //-- Dados do Destinatario
	nDados := 4
	nTam   := TamSX3('DIJ_DADDES')[1]
	If (cAliasQr2)->(!Eof())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		DII->(dbSetOrder(1))
		If DII->(dbSeek(xFilial('DII')+cFilMIC+cNumMIC+cCodVei+cIteMIC))
			DT6->(dbSetOrder(1))
			DT6->(dbSeek(xFilial('DT6')+DII->(DII_FILDOC+DII_DOC+DII_SERIE)))
			aRet := TMSDadCli(DT6->DT6_CLIDES,DT6->DT6_LOJDES,2)
		EndIf
	EndIf
	
ElseIf cCampo == '35' //-- Dados do Consignatario
	nDados := 4
	nTam   := TamSX3('DIJ_DADCON')[1]
	If (cAliasQr2)->(!Eof())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		DII->(dbSetOrder(1))
		If DII->(dbSeek(xFilial('DII')+cFilMIC+cNumMIC+cCodVei+cIteMIC))
			DT6->(dbSetOrder(1))
			DT6->(dbSeek(xFilial('DT6')+DII->(DII_FILDOC+DII_DOC+DII_SERIE)))
			aRet := TMSDadCli(DT6->DT6_CLICON,DT6->DT6_LOJCON,2)
		EndIf
	EndIf
	
ElseIf cCampo == '36' //-- Documentos Anexos
	nDados := 5
	nTam   := TamSX3('DIJ_DOCANE')[1]
	If (cAliasQr2)->(!Eof())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		DII->(dbSetOrder(1))
		If DII->(dbSeek(xFilial('DII')+cFilMIC+cNumMIC+cCodVei+cIteMIC))
			DTC->(dbSetOrder(3))
			DT6->(dbSetOrder(1))
			If DT6->(dbSeek(xFilial('DT6')+DII->(DII_FILDOC+DII_DOC+DII_SERIE)))
				If Empty(DT6->DT6_DOCDCO)
					DTC->(MsSeek(xFilial('DTC')+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)))
				Else
					DTC->(MsSeek(xFilial('DTC')+DT6->(DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO)))
				EndIf
				If DTC->(Found())
					cMemo := DTC->DTC_CODDCA
				EndIf
			EndIf
		EndIf
	EndIf
	
ElseIf cCampo == '37' //-- Numero dos Lacres
	nTam   := TamSX3('DIJ_DADLAC')[1]
	nDados := 1
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		
		cQuery := "SELECT DVB_LACRE FROM "
		cQuery += RetSqlName("DVB")+" DVB "
		cQuery += " JOIN " + RetSqlName("DII")+ " DII "
		cQuery += "  ON DII_FILIAL = '"+xFilial("DII")+"' "
		cQuery += "   AND DII.DII_FILMIC = '"+cFilMIC+"' "
		cQuery += "   AND DII.DII_NUMMIC = '"+cNumMIC+"' "
		cQuery += "   AND DII.DII_CODVEI = '"+cCodVei+"' "
		cQuery += "   AND DII.DII_ITEMIC = '"+cIteMIC+"' "
		cQuery += "   AND DII.D_E_L_E_T_ = ' '"	
		cQuery += " JOIN " + RetSqlName("DT6")+ " DT6 "
		cQuery += "  ON DT6_FILIAL = '"+xFilial("DT6")+"' "
		cQuery += "   AND DT6.DT6_FILDOC = DII.DII_FILDOC "
		cQuery += "   AND DT6.DT6_DOC    = DII.DII_DOC "
		cQuery += "   AND DT6.DT6_SERIE  = DII.DII_SERIE "
		cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "		
		cQuery += " WHERE DVB.DVB_FILIAL = '"+xFilial("DVB")+"'"
		cQuery += "   AND DVB.DVB_FILORI = DT6.DT6_FILVGA "
		cQuery += "   AND DVB.DVB_VIAGEM = DT6.DT6_NUMVGA "
		cQuery += "   AND DVB.DVB_CODVEI = '"+cCodVei+"' "
		cQuery += "   AND DVB.D_E_L_E_T_  = ' '"
		cQuery += " ORDER BY DVB_FILIAL, DVB_FILORI, DVB_VIAGEM, DVB_CODVEI, DVB_ITEM "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQr1)
		While (cAliasQr1)->(!Eof())
			Aadd(aLacres,AllTrim((cAliasQr1)->DVB_LACRE))
			(cAliasQr1)->(dbSkip())
		EndDo
		(cAliasQr1)->(dbCloseArea())
		                            
		//--Conta os Lacres para mandar um array padronizado
		For nA := 1 To Len(aLacres)
			aRet[1] += aLacres[nA] + IIf(nA==Len(aLacres),'','/')
		Next nA
		
	EndIf
	
ElseIf cCampo == '38' //-- Descricao das Mercadorias
	nDados := 16
	nTam   := TamSX3('DIJ_DADMER')[1]
	If (cAliasQr2)->(!Eof())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		DII->(dbSetOrder(1))
		If DII->(dbSeek(xFilial('DII')+cFilMIC+cNumMIC+cCodVei+cIteMIC))
			DTC->(dbSetOrder(3))
			If DTC->(MsSeek(xFilial('DTC')+DII->(DII_FILDOC+DII_DOC+DII_SERIE)))
				cMemo := DTC->DTC_CODOBS
			EndIf
		EndIf
	EndIf
	
ElseIf cCampo == '40' //-- Rota e prazo de transporte
	nDados := 8
	nTam   := TamSX3('DIJ_PERCUR')[1]
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		DID->(dbSetOrder(1))
		If DID->(dbSeek(xFilial('DII')+cFilMIC+cNumMIC+cCodVei))
			cMemo := Posicione('DIL',1,xFilial('DIL')+DID->DID_CODPCI,'DIL_CODPER')
		EndIf
	EndIf
ElseIf cCampo == '41' //--Peso Liquido
	lVal   := .T.
	nDados := 1
	nTam   := TamSX3('DIJ_PESLIQ')[1]
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else		
		aRet := Array(nDados)
		Afill(aRet,'')
		DII->(dbSetOrder(1))		
		If DII->(dbSeek(xFilial('DII')+cFilMIC+cNumMIC+cCodVei+cIteMIC))			
			DT6->(DbSetOrder(1))
			If DT6->(dbSeek(xFilial('DT6')+DII->(DII_FILDOC+DII_DOC+DII_SERIE)))		
				xRet := DT6->DT6_PESLIQ
			EndIf
		EndIf
		nPict := Ascan(aPicts,{ | e | e[1] == '41' })
   	If nPict > 0 .And. !Empty(aPicts[nPict,2])
   		xRet := Transform(xRet,aPicts[nPict,2])
   		If aPicts[nPict,4] > 0
  				xRet += Space(aPicts[nPict,4])
			EndIf 
		EndIf
		aRet[1] := xRet
	EndIf
ElseIf cCampo == '42' .And. DTR->(ColumnPos('DTR_CODRB3')) > 0 //-- 3° Reboque	
	nDados := 1
	If (cAliasQr2)->(!EOF())
		cMemo:= (cAliasQr2)->DIJ_CODINF
	Else
		aRet := Array(nDados)
		Afill(aRet,'')
		If !Empty(cAliasQry)
			cFilOri := (cAliasQry)->DID_FILORI
			cViagem := (cAliasQry)->DID_VIAGEM
		Else 
			cFilOri := Posicione('DID',1,xFilial('DID')+cFilMIC+cNumMIC+cCodVei,'DID_FILORI')
			cViagem := DID->DID_VIAGEM
		EndIf			
		DTR->(dbSetOrder(3))
		If DTR->(dbSeek(xFilial('DTR')+cFilOri+cViagem+cCodVei)) .And. !Empty(DTR->DTR_CODRB3)
			xRet := Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODRB3,'DA3_PLACA')
		EndIf
		nPict := Ascan(aPicts,{ | e | e[1] == '42' })
		If nPict > 0 .And. !Empty(aPicts[nPict,2])
			xRet := Transform(xRet,aPicts[nPict,2])
			If aPicts[nPict,4] > 0
  				xRet += Space(aPicts[nPict,4])
			EndIf 
		EndIf   		
		aRet[1] := xRet
	EndIf		
EndIf
If !Empty(cMemo)
	If nTam >= nTamSYP
		nTam := nTamSYP
	EndIf		
	aRet := Array(nDados)
	xRet := ''
	nI   := 1
	cMsMM:= MsMM(cMemo,80)
	Afill(aRet,'')
	For nRet := 1 To Len(cMsMM)
		If Substr(cMsMM,nRet,1) == Chr(13) .Or. Len(xRet) > nTam
			If Substr(cMsMM,nRet,1) == Chr(13)		
				nRet += 2			
			ElseIf !Empty(Substr(cMsMM,nRet,1))
				For nCnt:= Len(xRet) To 1 Step -1
					If Empty(Substr(xRet,nCnt,1))
						nDif := (nTam - nCnt)+1
						xRet := Substr(xRet,1,(nTam - nDif))
						nRet -= nDif
						Exit
					EndIf
				Next nCnt
			EndIf
			aRet[nI] := xRet
			xRet := ''
			nI   += 1
			If nI > nDados
				Exit
			ElseIf Substr(cMsMM,nRet,1) == Chr(13)
				//-- Se o proximo caracter foi <enter> não soma na string xRet
				nRet -= 1
				Loop
			EndIf
		EndIf
		xRet += Substr(cMsMM,nRet,1)
	Next nRet
	If !Empty(xRet) .And. nI <= nDados
		If Len(xRet) < nTam .And. ValType(xRet) == "C"
			xRet += Replicate(' ',nTam-Len(xRet))
		EndIf
		aRet[nI] := xRet
	EndIf
ElseIf Len(aRet) == 0
	aRet := Array(nDados)
	Afill(aRet,'')
EndIf
If lVal
	For nRet:= 1 To Len(aRet)
		xRet := StrTran(aRet[1],'.','')
		xRet := Val(StrTran(xRet,',','.'))
		aRet[nRet] := xRet
	Next nRet
EndIf
(cAliasQr2)->(dbCloseArea())

If ExistBlock('TMDADMIC')
	aRetUsr := ExecBlock('TMDADMIC',.F.,.F.,{ cCampo, aRet, cFilMIC, cNumMIC, cCodVei, cIteMIC })
	If ValType(aRetUsr) == 'A'
		aRet := AClone(aRetUsr)
	EndIf
EndIf				

RestArea(aAreaDA3)
RestArea(aAreaDA8)
RestArea(aAreaDTC)
RestArea(aAreaDTQ)
RestArea(aAreaDTR)
RestArea(aAreaDID)
RestArea(aAreaDII)
RestArea(aAreaDIJ)
RestArea(aAreaSA2)
RestArea(aAreaSYA)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSDadCli ³ Autor ³ Richard Anderson      ³ Data ³22.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorno dados do cliente                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - 1 = Dados do Cliente Remetente                     ³±±
±±³          ³         2 = Dados do Cliente Destinatario                  ³±±
±±³          ³         3 = Dados do Cliente Consignatario                 ³±±
±±³          ³         4 = Dados do Cliente a Notificar                   ³±±
±±³          ³ ExpC2 - Loja do Cliente                                    ³±±
±±³          ³ ExpN3 - Tipo da Chamada                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS - Transporte Internacional                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSDadCli(cCliente,cLoja,nTipo)

Local   aAreaSA1 := SA1->(GetArea())
Local   aAreaDUY := DUY->(GetArea())
Local   aDadCli  := Array(5)

Default nTipo    := 1

Afill(aDadCli,'')

SA1->(dbSetOrder(1))
If	SA1->(dbSeek(xFilial('SA1')+cCliente+cLoja))
	DUY->(dbSetOrder(1))
	DUY->(dbSeek(xFilial('DUY')+SA1->A1_CDRDES))
	aDadCli[1] := SA1->A1_NOME
	If nTipo == 1
		aDadCli[2] := AllTrim(SA1->A1_END)+' '+AllTrim(SA1->A1_BAIRRO)
		aDadCli[3] := Iif(Empty(SA1->A1_CEP),'',AllTrim(Transform(SA1->A1_CEP,"@R 99999-999"))+' - ')+;
	   	           AllTrim(SA1->A1_MUN)+Iif(Empty(SA1->A1_MUN),'',' ')+;
				        AllTrim(SA1->A1_EST)+Iif(Empty(SA1->A1_EST),'',' ')+;
			   	     AllTrim(E_Field('DUY_PAIS','YA_DESCR'))
	Else		
		aDadCli[2] := SA1->A1_END
		aDadCli[3] := Iif(Empty(SA1->A1_CEP),'',AllTrim(Transform(SA1->A1_CEP,"@R 99999-999"))+' - ')+;
	      		     AllTrim(SA1->A1_MUN)+Iif(Empty(SA1->A1_MUN),'',' ')+;
				        AllTrim(E_Field('DUY_PAIS','YA_DESCR'))
	EndIf
	If AllTrim(DUY->DUY_PAIS) == '105' .And. !Empty(SA1->A1_CGC)
		aDadCli[4] := Transform(SA1->A1_CGC,PesqPict('SA1','A1_CGC'))
	EndIf	
	If !Empty(SA1->A1_TEL)
		aDadCli[5] := Iif(Empty(SA1->A1_DDI),'',AllTrim(SA1->A1_DDI)+' - ')+Iif(Empty(SA1->A1_DDD),'',AllTrim(SA1->A1_DDD)+' - ')+AllTrim(SA1->A1_TEL)
	EndIf	
EndIf

RestArea(aAreaSA1)
RestArea(aAreaDUY)

Return aDadCli

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSDadReg ³ Autor ³ Richard Anderson      ³ Data ³19.11.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorno dados da regiao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - C0digo da Regiao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS - Transporte Internacional                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSDadReg(cCodReg)

Local   xRet    := ''
Default cCodReg := ''

xRet := AllTrim(Posicione('DUY',1,xFilial('DUY')+cCodReg,'DUY_DESCRI'))+"/"+DUY->DUY_EST+' '+;
        AllTrim(E_Field('DUY_PAIS','YA_DESCR'))
        
Return xRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSDadIAF ³ Autor ³ Richard Anderson      ³ Data ³19.11.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorno dados da fronteira                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Rota                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS - Transporte Internacional                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSDadIAF(cRota)

Local nDados   := 4
Local aRet     := Array(nDados)
Local xRet     := ''
Local nI       := 0
Local nIns     := 1
Local aAreaDI5 := DI5->(GetArea())

Afill(aRet,'')

If !Empty(DIK->DIK_CODADU)
	aRet[4] := AllTrim(Posicione("DI1",1,xFilial("DI1")+DIK->DIK_CODADU,"DI1_NOME"))
EndIf
	
DI5->(dbSetOrder(1))
DI5->(dbSeek(xFilial("DI5")+cRota))
While DI5->(!Eof()) .And. DI5->(DI5_FILIAL+DI5_ROTA) == xFilial("DI5")+cRota
	If !Empty(xRet)
		xRet += " / "
	EndIf
	If nI > 3
		aRet[nIns] := xRet
		xRet := ''
		nI   := 1
		nIns += 1
		If nIns > nDados
			Exit
		EndIf			
	EndIf
	DUY->(dbSetOrder(1))
   	If DUY->(dbSeek(xFilial("DUY")+DI5->DI5_CDRFRO))
   		xRet += AllTrim(DUY->DUY_EST ) + "-" +  AllTrim(DUY->DUY_DESCRI)
   		nI   += 1
   	EndIf
   		
	DI5->(dbSkip())
EndDo
If nIns <= nDados
	aRet[nIns] := xRet
EndIf			

RestArea(aAreaDI5)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSDadLMe ³ Autor ³ Richard Anderson      ³ Data ³19.11.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorno dados do local da mercadoria                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 - Data de Entrega                                    ³±±
±±³          ³ ExpC2 - Filial da Solicitacao                              ³±±
±±³          ³ ExpC3 - Numero da Solicitacao                              ³±±
±±³          ³ ExpC4 - Cliente Remetente                                  ³±±
±±³          ³ ExpC5 - Loja Remetente                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS - Transporte Internacional                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSDadLMe(dDatEnt,cFilCol,cNumSol,cCliRem,cLojRem)

Local cRet     := ''
Local cCodReg  := ''
Local aArea    := GetArea()
Local aAreaDT5 := {}
Local aAreaDUY := {}
Local aAreaDUE := {}

aAreaDT5 := DT5->(GetArea())
aAreaDUY := DUY->(GetArea())
DbSelectArea("DUE")
aAreaDUE := DUE->(GetArea())

If !Empty(cNumSol)
	DT5->(dbSetOrder(1))
	If DT5->(dbSeek(xFilial('DT5')+cFilCol+cNumSol))
		If !Empty(DT5->DT5_SEQEND)                                       
			cCodReg := Posicione("DUL",1,xFilial("DUL")+DT5->DT5_DDD+DT5->DT5_TEL+DT5->DT5_SEQEND,"DUL_CDRDES")
		Else
			cCodReg := Posicione("DUE",1,xFilial("DUE")+DT5->DT5_DDD+DT5->DT5_TEL,"DUE_CDRSOL")
		EndIf
		cRet := AllTrim(Posicione('DUY',1,xFilial('DUY')+cCodReg,'DUY_DESCRI'))+' - '+DUY->DUY_EST+' - '
		cRet += AllTrim(E_Field('DUY_PAIS','YA_DESCR'))+' - '
		cRet += Dtoc(DT5->DT5_DATSOL)
	EndIf
EndIf
If Empty(cRet)
	cCodReg := Posicione('SA1',1,xFilial('SA1')+cCliRem+cLojRem,'A1_CDRDES')
	cRet    := AllTrim(Posicione('DUY',1,xFilial('DUY')+cCodReg,'DUY_DESCRI'))+' - '+DUY->DUY_EST+' - '
	cRet    += AllTrim(E_Field('DUY_PAIS','YA_DESCR'))+' - '
	cRet    += Dtoc(dDatEnt)
EndIf			

RestArea(aAreaDT5)
RestArea(aAreaDUY)
RestArea(aAreaDUE)
RestARea(aArea)

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TMSDadLEt³ Autor ³ Richard Anderson      ³ Data ³19.11.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorno dados do local da mercadoria                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Cliente Destinatario                               ³±±
±±³          ³ ExpC2 - Loja Destinatario                                  ³±±
±±³          ³ ExpL3 - MIC                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS - Transporte Internacional                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSDadLEt(cCliDes,cLojDes,lMic)

Local cRet     := ''
Local aAreaSA1 := SA1->(GetArea())
Local aAreaDUY := DUY->(GetArea())

Default lMic   := .F.

SA1->(dbSetOrder(1))
DUY->(dbSetOrder(1))
SA1->(dbSeek(xFilial('SA1')+cCliDes+cLojDes))
DUY->(dbSeek(xFilial('DUY')+SA1->A1_CDRDES))
If !Empty(SA1->A1_MUNE)
	cRet := AllTrim(SA1->A1_MUNE)+' - '+AllTrim(E_Field('DUY_PAIS','YA_DESCR'))
Else		
	cRet := AllTrim(DUY->DUY_DESCRI)+' - '+AllTrim(E_Field('DUY_PAIS','YA_DESCR'))
EndIf

If lMic
	cRet += '   '+DUY->DUY_PAIS
EndIf

RestArea(aAreaSA1)
RestArea(aAreaDUY)

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSRotDes ³ Autor ³ Richard Anderson     ³ Data ³ 22/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtem as rotas a partir do destino                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo da Regiao de Destino                        ³±±
±±³          ³ ExpC2 - Codigo da Rota                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSRotDes(cCdrDes,cRota)

Local   cCdrOri   := ''
Local   cQuery    := ''
Local   cAliasQry := GetNextAlias()
Local   aRotas    := {}
Local   aRegOri   := {}
Local   cRegOri   := ''
Local   aRegDes   := {}
Local   cRegDes   := ''
Local   lRet      := .T.
Local   nCnt      := 0
Local   cSerTms	  := ''

Default cRota     := ''

If Type("M->DT4_CDRORI") == "C"
	cCdrOri := M->DT4_CDRORI
ElseIf Type("M->DTC_CDRORI") == "C"
	cCdrOri := M->DTC_CDRORI
ElseIf Type("M->DIK_CDRORI") == "C"
	cCdrOri := M->DIK_CDRORI
EndIf
If Empty(cCdrOri)	
	cCdrOri := GetMv('MV_CDRORI',,'')
EndIf
If !Empty(cCdrOri)
	aRegOri := TmsNivSup(cCdrOri)
	For nCnt:= 1 To Len(aRegOri)
		If !Empty(cRegOri)
			cRegOri += "',"
		EndIf
		cRegOri += "'"+aRegOri[nCnt]
	Next nCnt
	If !Empty(cRegOri)
		cRegOri += "'"
	EndIf
EndIf	
	If Type("M->DT4_CDRDES") == "C"
		cCdrDes := M->DT4_CDRDES
        cSerTms	:= M->DT4_SERTMS
	ElseIf Type("M->DTC_CDRDES") == "C"
		cCdrDes := M->DTC_CDRDES
        cSerTms	:= M->DTC_SERTMS
	ElseIf Type("M->DIK_CDRCAL") == "C"
		cCdrDes := M->DIK_CDRCAL
        cSerTms	:= M->DIK_SERTMS
	Else
		cCdrDes := ''
	EndIf

If !Empty(cCdrDes)
	aRegDes := TmsNivSup(cCdrDes)
	For nCnt:= 1 To Len(aRegDes)
		If !Empty(cRegDes)
			cRegDes += "',"
		EndIf
		cRegDes += "'"+aRegDes[nCnt]
	Next nCnt
	If !Empty(cRegDes)
		cRegDes += "'"
	EndIf
EndIf	
cQuery := "SELECT DA8_COD, MIN(DA8_DESC) DA8_DESC FROM "
cQuery += RetSqlName('DA8')+" DA8 "
If cSerTms = '2'
	cQuery += ", " + RetSqlName('DUN')+" DUN  "
EndIf
cQuery += " WHERE DA8.DA8_FILIAL  = '"+xFilial("DA8")+"'"
cQuery += "   AND DA8.DA8_CDRORI IN ( "+cRegOri+" )"
cQuery += "   AND DA8.D_E_L_E_T_  = ' '"

If cSerTms = '2'
	cQuery += "   AND DUN.DUN_FILIAL  = '"+xFilial("DUN")+"'"
	cQuery += "   AND DUN.DUN_ROTEIR  = DA8_COD "
	If !Empty(cRegDes)
		cQuery += "AND DUN.DUN_CDRDES IN ( "+cRegDes+" )"
	EndIf	
	cQuery += "   AND DUN.D_E_L_E_T_  = ' '"
EndIf

cQuery += " GROUP BY DA8_COD "
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
While (cAliasQry)->(!Eof())
	Aadd( aRotas, { .F., (cAliasQry)->DA8_COD, (cAliasQry)->DA8_DESC })
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbCloseArea())
If Len(aRotas) > 0
	If Empty(cRota)
		lRet := TMSABrowse(aRotas,STR0001,,,,.T.) //-- Rotas para o Destino
		If lRet
			cRota := aRotas[Ascan(aRotas,{ | e | e[1] == .T. })][2]
			DA8->(dbSetOrder(1))
			DA8->(dbSeek(xFilial('DA8')+cRota))
		EndIf
	Else	
		lRet := (Ascan(aRotas,{ | e | e[2] == cRota }) > 0)
		If !lRet
			MsgAlert(STR0002) //-- Rota inválida para o destino informado
		EndIf
	EndIf
Else
	MsgAlert(STR0003) //-- Rotas não localizadas para o destino informado
	lRet := .F.
EndIf
dbSelectArea("DA8")

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSFrtPais³ Autor ³ Richard Anderson     ³ Data ³ 22/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtem os percentuais de frete por pais                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo da Rota                                     ³±±
±±³          ³ ExpC2 - Codigo do Incoterm                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSFrtPais(cRota,cIncote)

Local   aArea     := GetArea()
Local   cQuery    := ''
Local   cAliasQry := GetNextAlias()
Local   aFrtPais  := {}
Local   nI        := 0

Default cRota     := ''
Default cIncote   := ''

For nI := 1 To 2
	DI4->(dbSetOrder(1))
	cQuery := "SELECT  DI4_ITEM, DI4_PAIS, YA_DESCR, DI4_PERFRE FROM "
	cQuery += RetSqlName('DI4')+" DI4, "
	cQuery += RetSqlName('SYA')+" SYA  "
	cQuery += " WHERE  DI4.DI4_FILIAL = '"+xFilial("DI4")+"'"
	cQuery += "   AND  DI4.DI4_ROTA   = '"+cRota+"' "
	If Empty(cIncote)
		cQuery += "AND  DI4.DI4_INCOTE = ' '"
	Else
		cQuery += "AND  DI4.DI4_INCOTE = '"+cIncote+"'"
	EndIf	
	cQuery += "   AND  DI4.D_E_L_E_T_ = ' '"
	cQuery += "   AND  SYA.YA_FILIAL  = '"+xFilial("SYA")+"'"
	cQuery += "   AND  SYA.YA_CODGI   = DI4_PAIS"
	cQuery += "   AND  SYA.D_E_L_E_T_ = ' '"
	cQuery += " ORDER  BY "+SqlOrder(DI4->(IndexKey()))
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
	While (cAliasQry)->(!Eof())
		Aadd( aFrtPais, { (cAliasQry)->DI4_ITEM, (cAliasQry)->DI4_PAIS, (cAliasQry)->YA_DESCR, (cAliasQry)->DI4_PERFRE, 0 })
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	If Len(aFrtPais) == 0 .And. !Empty(cIncote)
		cIncote := ''
	Else
		Exit		
	EndIf		 
Next nI	

RestArea(aArea)

Return aFrtPais

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSFrtDAF ³ Autor ³ Richard Anderson     ³ Data ³ 22/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtem os percentuais de frete CIF/FOB                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Cliente Remetente                                  ³±±
±±³          ³ ExpC2 - Loja do Remetente                                  ³±±
±±³          ³ ExpC3 - Cliente Destinatario                               ³±±
±±³          ³ ExpC4 - Loja do Destinatario                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSFrtDAF(cCliRem,cLojRem,cCliDes,cLojDes)

Local   aAreaDI6  := DI6->(GetArea())
Local   aFrtDAF   := {}
Local   cChaveDI6 := ''  
Local   cCliGen   := GetMv('MV_CLIGEN',,'')

Default cCliRem   := Substr(cCliGen,1,Len(SA1->A1_COD))
Default cLojRem   := Substr(cCliGen,Len(SA1->A1_COD)+1,Len(SA1->A1_LOJA))
Default cCliDes   := Substr(cCliGen,1,Len(SA1->A1_COD))
Default cLojDes   := Substr(cCliGen,Len(SA1->A1_COD)+1,Len(SA1->A1_LOJA))

If cCliRem == NIL .Or. Empty(cCliRem)
	cCliRem := Substr(cCliGen,1,Len(SA1->A1_COD))
	cLojRem := Substr(cCliGen,Len(SA1->A1_COD)+1,Len(SA1->A1_LOJA))
EndIf
If cCliDes == NIL .Or. Empty(cCliDes)
	cCliDes := Substr(cCliGen,1,Len(SA1->A1_COD))
	cLojDes := Substr(cCliGen,Len(SA1->A1_COD)+1,Len(SA1->A1_LOJA))
EndIf	

cChaveDI6 := cCliRem+cLojRem+cCliDes+cLojDes
DI6->(dbSetOrder(1))
If DI6->(!dbSeek(xFilial("DI6")+cChaveDI6))
	cChaveDI6 := cCliRem+cLojRem+cCliGen
	If DI6->(!dbSeek(xFilial("DI6")+cChaveDI6))
		cChaveDI6 := cCliGen+cCliDes+cLojDes
		If DI6->(!dbSeek(xFilial("DI6")+cChaveDI6))
			cChaveDI6 := cCliGen+cCliGen
			DI6->(dbSeek(xFilial("DI6")+cChaveDI6))
		EndIf
	EndIf
EndIf
While DI6->(!Eof()) .And. DI6->(DI6_FILIAL+DI6_CLIREM+DI6_LOJREM+DI6_CLIDES+DI6_LOJDES) == xFilial("DI6")+cChaveDI6
	Aadd(aFrtDAF,{ DI6->DI6_CODPAS, Posicione("DT3",1,xFilial("DT3")+DI6->DI6_CODPAS,"DT3_DESCRI"), DI6->DI6_PERCIF, DI6->DI6_PERFOB, 0, 0 })
	DI6->(dbSkip())
EndDo	
If Len(aFrtDAF) > 0
	Aadd(aFrtDAF,{ "TF", STR0014, 0, 0, 0, 0 }) //"TOTAL DO FRETE"
EndIf

RestArea(aAreaDI6)

Return aFrtDAF

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSCfgCRT ³ Autor ³ Richard Anderson     ³ Data ³ 22/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtem os percentuais de frete CIF/FOB                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento                                ³±±
±±³          ³ ExpC2 - Documento                                          ³±±
±±³          ³ ExpC3 - Serie                                              ³±±
±±³          ³ ExpC4 - Nome do Campo                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSCfgCRT(cFilDoc,cDoc,cSerie,cCampo)

Local   aAreaDT6 := DT6->(GetArea())
Local   aAreaDIG := DIG->(GetArea())
Local   cCliGen  := AllTrim(GetMv('MV_CLIGEN',,''))
Local   cCdpDes  := ''
Local   xRet     := ''
Local   cNomeCpo := ''

Default cCampo   := ''

If !Empty(cDoc)
	DT6->(dbSetOrder(1))
	DT6->(MsSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie))
	cCdpDes := Posicione('DUY',1,xFilial('DUY')+DT6->DT6_CDRDES,'DUY_PAIS')

	DIG->(dbSetOrder(1))
	If DIG->(dbSeek(xFilial('DIG')+cCdpDes+DT6->(DT6_CLIREM+DT6->DT6_LOJREM))) .Or. ;
   	DIG->(dbSeek(xFilial('DIG')+cCdpDes+cCliGen))
	   cNomeCpo := 'DIG_CPO'+cCampo
   	If DIG->(FieldPos(cNomeCpo)) > 0
   		cNomeCpo := 'DIG->'+cNomeCpo
	   	xRet     := &cNomeCpo
		EndIf   	
	EndIf
EndIf	

RestArea(aAreaDT6)
RestArea(aAreaDIG)

Return xRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsVisMIC  ³ Autor ³ Richard Anderson     ³ Data ³04.03.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta uma lista com todos MIC/DTA da Viagem            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial de origem da viagem                         ³±±
±±³          ³ ExpC2 = Viagem                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsVisMIC(cFilOri,cViagem)

Local cCampo  := ''
Local nCntFor := 0
Local nItem	  := 0
//-- Dialog
Local aBtnMIC := {}
Local oDlgEsp

SaveInter()

//-- GetDados
Private aHeader	:= {}
Private aCols		:= {}
Private oGetD

DID->(DbSetOrder(2))
If	DID->(MsSeek(xFilial('DID') + cFilOri + cViagem))

	aHeader:= ApBuildHeader("DID")
	
	//-- Preenche aCols
	While DID->( ! Eof() .And. DID->DID_FILIAL + DID->DID_FILORI + DID->DID_VIAGEM == xFilial('DID') + cFilOri + cViagem )

		Aadd( aCols, Array( Len( aHeader ) + 1 ) )
		nItem := Len(aCols)
		RegToMemory('DID',.F.)

		For nCntFor := 1 To Len(aHeader)
			cCampo := aHeader[nCntFor,2]
			GDFieldPut( cCampo, M->&(cCampo), nItem )
      Next
      
  		aCols[ nItem, Len( aHeader ) + 1 ] := .F.

		DID->(DbSkip())
	EndDo

	cCadastro := STR0004 //"MIC/DTA"
	Aadd(aBtnMIC,{'RELATORIO',{|| DID->(DbSetOrder(1)),Iif(DID->(dbSeek(xFilial('DID')+GDFieldGet('DID_FILMIC',n)+GDFieldGet('DID_NUMMIC',n))),TMAI45Mnt('DID',DID->(Recno()),2),.F.) } ,STR0004 , STR0005 }) //"Visualiza MIC/DTA"

	DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM 9,0 TO 27.5,80 OF oMainWnd

	oGetD := MSGetDados():New(35,3,138,314,2,'AllwaysTrue()','AllwaysTrue()') 

	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||oDlgEsp:End()},{||oDlgEsp:End()},, aBtnMIC ) CENTERED
EndIf

RestInter()

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsCAltCRT³ Autor ³ Richard Anderson      ³ Data ³14.08.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta Aleracoes no CRT                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento                                ³±±
±±³          ³ ExpC2 - Numero do Documento                                ³±±
±±³          ³ ExpC3 - Serie do Documento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS - Internacional                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsCAltCRT(cFilDoc,cDoc,cSerie)

Local cCadastro := STR0006 //-- Alterações do CRT
Local aRotOld   := Iif(Type('aRotina') == 'A',AClone(aRotina),{})
Local aCampos   := NIL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa               ³
//³ ----------- Elementos contidos por dimensao ------------              ³
//³ 1. Nome a aparecer no cabecalho                                       ³
//³ 2. Nome da Rotina associada                                           ³
//³ 3. Usado pela rotina                                                  ³
//³ 4. Tipo de Transa‡„o a ser efetuada                                   ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados                      ³
//³    2 - Simplesmente Mostra os Campos                                  ³
//³    3 - Inclui registros no Bancos de Dados                            ³
//³    4 - Altera o registro corrente                                     ³
//³    5 - Remove o registro corrente do Banco de Dados                   ³
//³    6 - Alteracao sem inclusao de registro                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina   := {}
Local aIndexDIB := {}
Local cFiltraDIB:= '' 
Local bFiltraDIB

Default cFilDoc := DT6->DT6_FILDOC
Default cDoc    := DT6->DT6_DOC
Default cSerie  := DT6->DT6_SERIE 

//-- Finaliza Teclas de Atalhos
If Type('aSetKey') == 'A'
	TmsKeyOff(aSetKey)
EndIf	

Aadd( aRotina, { STR0007,"TMAI35Mnt",0,2,,,.F.} ) // "&Visualizar

aIndexDIB  := {}
cFiltraDIB := "DIB_FILIAL == '"+xFilial('DIB')+"' .And. DIB_FILDOC == '"+cFilDoc+"' .And. DIB_DOC == '"+cDoc+"'"
cFiltraDIB += " .And. DIB_SERIE == '"+cSerie+"'"
bFiltraDIB := {|| FilBrowse("DIB",@aIndexDIB,@cFiltraDIB) }
Eval(bFiltraDIB)

MaWndBrowse(0,0,300,600,cCadastro,"DIB",aCampos,aRotina,,,,.T.)
aRotina := AClone(aRotOld)
EndFilBrw("DIB",aIndexDIB)

//-- Inicializa Teclas de Atalhos
If Type('aSetKey') == 'A'
	TmsKeyOn(aSetKey)
EndIf	

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsCAltMIC³ Autor ³ Richard Anderson      ³ Data ³14.08.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta Alerações no CRT                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do MIC                                      ³±±
±±³          ³ ExpN2 - Numero do MIC                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS - Internacional                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsCAltMIC(cFilMIC,cNumMIC)

Local aRotOld   := Iif(Type('aRotina') == 'A',AClone(aRotina),{})
Local aCampos   := {}
Local IncluOld  := INCLUI
Local AlterOld  := ALTERA
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa               ³
//³ ----------- Elementos contidos por dimensao ------------              ³
//³ 1. Nome a aparecer no cabecalho                                       ³
//³ 2. Nome da Rotina associada                                           ³
//³ 3. Usado pela rotina                                                  ³
//³ 4. Tipo de Transa‡„o a ser efetuada                                   ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados                      ³
//³    2 - Simplesmente Mostra os Campos                                  ³
//³    3 - Inclui registros no Bancos de Dados                            ³
//³    4 - Altera o registro corrente                                     ³
//³    5 - Remove o registro corrente do Banco de Dados                   ³
//³    6 - Alteracao sem inclusao de registro                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina   := {}
Local aIndexDIJ := {}
Local cFiltraDIJ:= '' 
Local bFiltraDIJ
Local aNoFields	:= {"DIJ_FILORI","DIJ_FILMIC","DIJ_NUMMIC","DIJ_CODVEI","DIJ_ITEMIC","DIJ_FILDOC","DIJ_DOC","DIJ_SERIE"}
Local aCampos   := {}
Local aFldDIJ   := {}
Local nI        := 0

Private cCadastro := STR0008 //-- "Alterações do MIC/DTA"

Default cFilMIC := DII->DII_FILMIC
Default cNumMIC := DII->DII_NUMMIC

Aadd( aRotina, { STR0007,"TmsVisDIJ",0,2,,,.F.} ) //-- "Visualizar"

//-- Preenche aCampos
aFldDIJ := ApBuildHeader("DIJ",aNoFields)

For nI := 1 To Len(aFldDIJ)
	If aFldDIJ[nI][10]  <> 'V'
		aAdd(aCampos, aFldDIJ[nI][2] )
	EndIf
Next
aSize(aFldDIJ, 0)
aFldDIJ := Nil

aIndexDIJ  := {}
cFiltraDIJ := "DIJ_FILIAL == '"+xFilial('DIJ')+"' .And. DIJ_FILMIC == '"+cFilMIC+"' .And. DIJ_NUMMIC == '"+cNumMIC+"'"
bFiltraDIJ := {|| FilBrowse("DIJ",@aIndexDIJ,@cFiltraDIJ) }
Eval(bFiltraDIJ)

MaWndBrowse(0,0,500,900,cCadastro,"DIJ",aCampos,aRotina,,,,.T.)
aRotina := AClone(aRotOld)
EndFilBrw("DIJ",aIndexDIJ)

Inclui := IncluOld
Altera := AlterOld

Return NIL
                             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsVisDIJ ³ Autor ³ Telso Carneiro        ³ Data ³ 27/11/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualizacao do historico e alteracao do MIC/DTA           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Tabela a ser utilizada (Alias)                     ³±±
±±³          ³ ExpN2 - Numero do Recno                                    ³±±
±±³          ³ ExpN3 - Opcao do aRotina                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS - Internacional                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsVisDIJ(cAlias,nRec,nOpcx)

Local aVisual := {}
Local nI      := 0
Local aFldDIJ := {}

INCLUI :=.F.
ALTERA :=.F.                  
nOpcx := aRotina[nOpcx,4]

aRotina	:= {{ '' , "AxPesqui"  , 0, 1 },; 
				{ ''  , "AxVisual" , 0, 2 },; 
				{ ''  , "AxInclui" , 0, 3 },; 
				{ ''  , "AxAltera" , 0, 4 },; 
				{ ''  , "AxDeleta" , 0, 5 }} 
			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Variaveis de Memoria da Enchoice                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFldDIJ := ApBuildHeader("DIJ")
For nI := 1 To Len(aFldDIJ)
	If aFldDIJ[nI][10]  <> 'V' .Or. (aFldDIJ[nI][2] $ 'DIJ_CPOMIC,DIJ_NOMUSR.DIJ_INFORM') 
		aAdd(aVisual, aFldDIJ[nI][2] )
	EndIf
Next
aSize(aFldDIJ, 0)
aFldDIJ := Nil

AxVisual(cAlias,nRec,nOpcx,aVisual)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsConDIL ³ Autor ³ Richard Anderson      ³ Data ³14.08.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta os percursos Internacionais                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS - Internacional                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsConDIL()

Local cCadastro  := STR0009 //-- "Percurso Internacional"
Local aRotOld    := Iif(Type('aRotina') == 'A',AClone(aRotina),{})
Local aCampos    := {} 

//-- Variaveis para filtro do Browse no DUD
Local aIndexDIL  := {}
Local cFiltraDIL := ""
Local bFiltraBrw := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa               ³
//³ ----------- Elementos contidos por dimensao ------------              ³
//³ 1. Nome a aparecer no cabecalho                                       ³
//³ 2. Nome da Rotina associada                                           ³
//³ 3. Usado pela rotina                                                  ³
//³ 4. Tipo de Transa‡„o a ser efetuada                                   ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados                      ³
//³    2 - Simplesmente Mostra os Campos                                  ³
//³    3 - Inclui registros no Bancos de Dados                            ³
//³    4 - Altera o registro corrente                                     ³
//³    5 - Remove o registro corrente do Banco de Dados                   ³
//³    6 - Alteracao sem inclusao de registro                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nOpcSel  := 0
Private aRotina  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os campos do Browse.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aRotina, { STR0010,"AxPesqui"  ,0, 1 } ) //-- "Pesquisar"
Aadd( aRotina, { STR0007,"AxVisual"  ,0, 2 } ) //-- "Visualizar"
Aadd( aRotina, { STR0011,"TMAI75Mnt" ,0, 3 } ) //-- "Incluir" 
Aadd( aRotina, { STR0012,"TMAI75Mnt" ,0, 4 } ) //-- "Alterar" 
Aadd( aRotina, { STR0013,"TMSConfSel",0, 5 } ) //-- "Confirmar"

//-- Verifica se devera apresentar a tela para marcar documentos.
bFiltraBrw := {|| FilBrowse("DIL",@aIndexDIL,@cFiltraDIL) }
Eval(bFiltraBrw)

MaWndBrowse(0,0,300,600,cCadastro,"DIL",,aRotina,,,,.T.,,,,,,,,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

EndFilBrw("DIL",aIndexDIL)

If Len(aRotOld) > 0
   aRotina := AClone(aRotOld)
EndIf     

Return( nOpcSel == 1 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSFrtCRT ³ Autor ³ Richard Anderson      ³ Data ³25.11.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna composicao do frete do CRT                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 - Filial de Origem do Lote                          ³±±
±±³          ³ ExpC02 - Numero do Lote                                    ³±±
±±³          ³ ExpC03 - Tipo de Frete                                     ³±±
±±³          ³ ExpC04 - Tabela de Frete                                   ³±±
±±³          ³ ExpC05 - Tipo da Tabela                                    ³±±
±±³          ³ ExpC06 - Sequencia da Tabela                               ³±±
±±³          ³ ExpC07 - Codigo do Produto                                 ³±±
±±³          ³ ExpC08 - Codigo da Regiao de Origem                        ³±±
±±³          ³ ExpC09 - Codigo da Regiao de Destino                       ³±±
±±³          ³ ExpA10 - Componentes de Frete                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS - Internacional                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSFrtCRT(cFilOri,cLotNFC,cTipFre,cTabFre,cTipTab,cSeqTab,cCodPro,cCdrOri,cCdrDes,aCmpFrt)

Local   cOrdem   := ''
Local   lRet	  := .T.
Local   nCntFor  := 0
Local   cSeekDIA := ''
Local   cDscComp := ''
Local   nDesc    := 0
Local   nAcresc  := 0
Local   cCalMin  := '2' //-- Nao calculou pelo minimo
Local   nValFre  := 0
Local   nValImp  := 0

Default cTabFre  := ''
Default cTipTab  := ''
Default cSeqTab  := ''
Default cCodPro  := ''
Default cCdrOri  := ''
Default cCdrDes  := ''

If ValType(aCmpFrt)=='A'
	aFrete := AClone(aCmpFrt)
EndIf

cSeqTab := StrZero(0,Len(DVC->DVC_SEQTAB))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formato do vetor aFrete                                               ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ aFrete[01] = Descricao do componente                                  ³
//³ aFrete[02] = Valor do componente                                      ³
//³ aFrete[03] = Codigo do componente                                     ³
//³ aFrete[04] = Item SD2. Atualizado pelas funcoes que geram o SD2       ³
//³ aFrete[05] = Na cotacao eh gravado o valor do imposto do componente   ³
//³ aFrete[06] = Total do componente ( valor + imposto )                  ³
//³ aFrete[07] = Codigo da regiao origem                                  ³
//³ aFrete[08] = Codigo da regiao destino                                 ³
//³ aFrete[09] = Tabela de Frete                                          ³
//³ aFrete[10] = Tipo da Tabela                                           ³
//³ aFrete[11] = Sequencia                                                ³			 
//³ aFrete[12] = Linha Totalizadora                                       ³						 
//³ aFrete[13] = Desconto dado ao valor do componente                     ³						
//³ aFrete[14] = Acrescimo dado ao valor do componente                    ³												
//³ aFrete[15] = Indica se o componente esta com o valor minimo da tabela,|
//³              1=Sim,2=Nao                                              |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DIA->(dbSetOrder(1))
DIA->(dbSeek(cSeekDIA := xFilial('DIA')+cFilOri+cLotNFC))
While DIA->(!Eof()) .And. DIA->(DIA_FILIAL+DIA_FILORI+DIA_LOTNFC) == cSeekDIA

	cOrdem := '00'
	
	If	DIA->DIA_CODPAS == 'TF'
		cDscComp := STR0008 //"Total do Frete"
		cOrdem	:= 'ZZ'
	Else
		cDscComp := Posicione('DT3', 1, xFilial('DT3') + DIA->DIA_CODPAS, 'DT3_DESCRI')
	EndIf

	nValFre := DIA->(DIA_VALCIF+DIA_VALFOB)
	
	Aadd(aFrete,{ cDscComp,;
					  nValFre ,;       
					  DIA->DIA_CODPAS,;
					  '',;
					  nValImp ,;
					  nValFre ,;
					  cCdrOri ,;
					  cCdrDes ,;
					  cTabFre ,;
					  cTipTab ,;
					  cSeqTab ,;
					  cOrdem  ,;
					  nDesc   ,; 
					  nAcresc ,;
					  cCalMin })
						
	DIA->(dbSkip())
EndDo
If	Empty( aFrete )
	AAdd(aFrete,{Space(Len(DT3->DT3_DESCRI)),0,'','',0,0,'','','','','','00',0,0, StrZero(2,Len(DT8->DT8_CALMIN)) })
EndIf
ASort(aFrete,,,{|x,y| x[12] + x[3] < y[12] + y[3] })

If ValType(aCmpFrt)=='A'
	aCmpFrt:=AClone(aFrete)
EndIf

Return(lRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSVldHora
Valida a Hora Informada, semelhande a função AtVldHora porém sem usar a mensagem de help.
@type function
@author Marlon Augusto Heiber
@version 12.1.17
@since 22/06/2018
/*/
//-------------------------------------------------------------------------------------------------
Function TMSVldHora(cHorario,lMinutos)
Local cHora    := SubStr(cHorario,1,2)
Local cMinuto  := ""
Local lRetorno := .F.
Local nAchou :=  At( ":", cHorario )  //Verificar se a hora foi passada no formato 99:99 ou 9999
Local nPosMin := If(nAchou>0,nAchou+1,3)
	
	cMinuto  := SubStr(cHorario,nPosMin,2)
	lMinutos := If( ValType( lMinutos ) == "L", lMinutos, .F. )
	
	If ( If( lMinutos, .T., ( cHora >= "00" .AND. cHora < "24" ) ) .AND.;
	        cMinuto >= "00" .AND. cMinuto < "60" )
	    lRetorno := .T.
	EndIf
	
	If Empty(cHora) .AND. Empty(cMinuto)
		lRetorno := .T.
	EndIf
	
	//Verifica se o Horario e positivo
	If lRetorno
	    lRetorno := Val( StrTran( cHorario, ":", "" ) ) >= 0
	EndIf

Return(lRetorno)