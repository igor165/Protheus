#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPA110.CH"
#DEFINE PULALINHA CHR(13)+CHR(10)  

Function PCPA110()
	Local oDlgUpd, oCheckAll
	Local aCoors   := FWGetDialogSize( oMainWnd )
	Local nLargura := aCoors[4]
	Local nHeight  := aCoors[3]
	Local lIntgSFC := Iif(SuperGetMV("MV_INTSFC",.F.,0)==1,.T.,.F.)
	Local nI
	Private oMemo
	Private cMemo := ""
	//Private oOk:= LoadBitmap( GetResources(), "LBOK" )
	//Private oNOk:= LoadBitmap( GetResources(), "LBNO" )
	Private lFilial	 := .F.
	Private aTabelas := {}
	Private aAllReg	 := {}
	Private aChecks	 := {}
	Private aTabsFil := {}
	Private lChange  := .F.
	Default lAutoMacao := .F.

	//Lista de opções que aparecerão... Para adicionar, basta colocar mais uma posição no array. NENHUMA OUTRA ALTERAÇÃO NECESSARIA
	aAdd(aTabsFil, {"SB1",STR0001,"MATA010PPI(Iif(EncodeUtf8(SOF->OF_XML)==Nil,DecodeUtf8(SOF->OF_XML),SOF->OF_XML), SOF->OF_REGIST)"}) //"Produto"
	aAdd(aTabsFil, {"NNR",STR0002,"AGRA045PPI(Iif(EncodeUtf8(SOF->OF_XML)==Nil,DecodeUtf8(SOF->OF_XML),SOF->OF_XML), SOF->OF_REGIST)"}) //"Local de Estoque"
	If lIntgSFC
		aAdd(aTabsFil, {"CYH",STR0003,"SFCA006PPI(Iif(EncodeUtf8(SOF->OF_XML)==Nil,DecodeUtf8(SOF->OF_XML),SOF->OF_XML), SOF->OF_REGIST, , .F., .T.)"}) //"Recurso"
		aAdd(aTabsFil, {"CYB",STR0053,"mata610PPI(Iif(EncodeUtf8(SOF->OF_XML)==Nil,DecodeUtf8(SOF->OF_XML),SOF->OF_XML), SOF->OF_REGIST)"}) //"Máquina"
	Else
		aAdd(aTabsFil, {"SH1",STR0003,"mata610PPI(Iif(EncodeUtf8(SOF->OF_XML)==Nil,DecodeUtf8(SOF->OF_XML),SOF->OF_XML), SOF->OF_REGIST)"}) //"Recurso"
		aAdd(aTabsFil, {"SH4",STR0054,"MATA620PPI(Iif(EncodeUtf8(SOF->OF_XML)==Nil,DecodeUtf8(SOF->OF_XML),SOF->OF_XML), SOF->OF_REGIST,.F.,.F.,.T.)"}) //"Ferramenta"
	EndIf
	aAdd(aTabsFil, {"SC2",STR0004,"mata650PPI(Iif(EncodeUtf8(SOF->OF_XML)==Nil,DecodeUtf8(SOF->OF_XML),SOF->OF_XML), SOF->OF_REGIST, .T., .T.)"}) //"Ordem de Produção"
	aAdd(aTabsFil, {"SG2",STR0052,"PCPA124PPI(Iif(EncodeUtf8(SOF->OF_XML)==Nil,DecodeUtf8(SOF->OF_XML),SOF->OF_XML), SOF->OF_REGIST, .F., .F., .T.)"}) //"Roteiros"
	aAdd(aTabsFil, {"SG1",STR0051,"PCPA200PPI(Iif(EncodeUtf8(SOF->OF_XML)==Nil,DecodeUtf8(SOF->OF_XML),SOF->OF_XML), SOF->OF_REGIST, 4, .F., .T.)"}) //"Estrutura"
	aAdd(aTabsFil, {"SBE",STR0055,"MATA015PPI(Iif(EncodeUtf8(SOF->OF_XML)==Nil,DecodeUtf8(SOF->OF_XML),SOF->OF_XML), SOF->OF_REGIST, .F., .F., .T.)"}) //"Endereços"
	aAdd(aTabsFil, {"SB2",STR0056,"MATA225PPI(SOF->OF_REGIST,,,,,,,,,,,,,Iif(EncodeUtf8(SOF->OF_XML)==Nil,DecodeUtf8(SOF->OF_XML),SOF->OF_XML))"}) //"Saldos"

	aFiltEsp := {}

	IF !lAutoMacao
		DEFINE DIALOG oDlgUpd TITLE STR0005 FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL //"Gerenciamento de Pendências"

		//-----------------------
		//Painel Lateral esquerdo
		//-----------------------
		oPanelLat := TPanel():New( 01, 01, ,oDlgUpd, , , , , , 100, (nHeight/2) - 20, .T.,.T. )

		@ 15, 05 CHECKBOX oCheckAll VAR lChange PROMPT STR0057 WHEN PIXEL OF oPanelLat SIZE 100,015 MESSAGE "" //"Marca/Desmarca todos"
		oCheckAll:bChange := {|| ChangCheck(lChange)}

		For nI := 1 To Len(aTabsFil)
			//Checkbox Filtro
			aAdd(aChecks,PCPA110C():New(oPanelLat,aTabsFil[nI][1],aTabsFil[nI][2],(nI+1) * 15,05,{|| FiltraInfo()}) )
			aAdd(aFiltEsp,PCPA110F():New(oPanelLat,aTabsFil[nI][1],aTabsFil[nI][2],(nI+1) * 15,82,{|| FiltraInfo()}) )
		Next

		//----------------
		//Painel Principal
		//----------------
		oPanelPrinc := TPanel():New( 01, 100, ,oDlgUpd, , , , , , (nLargura/2)-100, (nHeight/2) - 20, .T.,.T. )
	ENDIF

	aColunas := {}
	
	aAdd(aColunas," ")
	
	If FWModeAccess('SOF',3) == "E" .Or. FWModeAccess('SOF',2) == "E"  .Or. FWModeAccess('SOF',1) == "E" 
		lFilial := .T.
		aAdd(aColunas,STR0006)//"Filial"
	EndIf	
	
	aAdd(aColunas,STR0007)//"Transação"
	aAdd(aColunas,STR0008)//"Status"
	aAdd(aColunas,STR0009)//"Identificador"
	aAdd(aColunas,STR0010)//"Data Envio"
	aAdd(aColunas,STR0011)//"Hora Envio"
	aAdd(aColunas,STR0012)//"Usuário"
	aAdd(aColunas,STR0044)//"Programa"
	aAdd(aColunas,STR0045)//"Data Reprocessamento"
	aAdd(aColunas,STR0046)//"Hora Reprocessamento"

	IF !lAutoMacao
		oList := TWBrowse():New( 05, 05, (nLargura/2)-110,(((nHeight/2)-5) * 0.6)-20,,aColunas,,oPanelPrinc,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		
		lToggleCheckBox := .T.
		
		@ 06, 06 CHECKBOX oCheckBox VAR lToggleCheckBox PROMPT "" WHEN PIXEL OF oPanelPrinc SIZE 015,015 MESSAGE ""
		oCheckBox:bChange := {|| MarcaTodos(oList) }

		//PreencheDados()
		ValRegVazio()

		oList:SetArray(aTabelas)
		oList:bLine := {|| rbLine(oList:nAt,Len(aColunas)) }
		oList:bChange := {|| AlteraMemo(oList:nAt)}
		oList:bLDblClick := {|| TrocaCheck(oList:nAt)}

		@ ((((nHeight/2)-5) * 0.6)-8), 05 SAY oAcao VAR STR0013 + ":" OF oPanelPrinc PIXEL //"Detalhes da Transação"
		oMemo := tMultiget():new( (((nHeight/2)-5) * 0.6), 05, {|u| If( PCount() == 0, cMemo, cMemo := u )}, oPanelPrinc, (nLargura/2)-110, (((nHeight/2)-5) * 0.4)-20, , , , , , .T., /*13*/,/*14*/,{||.T.},/*16*/,/*17*/,.T. )

		//-----------------------
		//Painel Inferior
		//-----------------------
		oPanelInf := TPanel():New( (nHeight/2) - 20, 01, ,oDlgUpd, , , , , , (nLargura/2), 19, .T.,.T. )

		@ 05,(nLargura/2)-325 BUTTON oBtnAvanca PROMPT STR0050 SIZE 60,12 WHEN (.T.) ACTION (buscaDados(),FiltraInfo())   OF oPanelInf PIXEL //"Atualizar"
		@ 05,(nLargura/2)-260 BUTTON oBtnAvanca PROMPT STR0014 SIZE 60,12 WHEN (.T.) ACTION (Reprocessar()) OF oPanelInf PIXEL //"Reprocessar"
		@ 05,(nLargura/2)-195 BUTTON oBtnAvanca PROMPT STR0015 SIZE 60,12 WHEN (.T.) ACTION (ExcluiSOF())   OF oPanelInf PIXEL //"Excluir"
		@ 05,(nLargura/2)-130 BUTTON oBtnAvanca PROMPT STR0016 SIZE 60,12 WHEN (.T.) ACTION (SalvarXML())   OF oPanelInf PIXEL //"Salvar XML"
		@ 05,(nLargura/2)-65  BUTTON oBtnAvanca PROMPT STR0017 SIZE 60,12 WHEN (.T.) ACTION (oDlgUpd:End()) OF oPanelInf PIXEL //"Sair"

		ACTIVATE MSDIALOG oDlgUpd CENTERED ON INIT (/*buscaDados()*/, oList:Refresh(),AlteraMemo(oList:nAt))
	ENDIF

Return Nil

Static Function buscaDados()
	Local oDlgMet

	Private nMeter := 0
	Private oMeter, oSayMtr

	DEFINE MSDIALOG oDlgMet FROM 0,0 TO 5,60 TITLE STR0058 //"Executando consulta"

	oSayMtr := tSay():New(10,10,{||STR0059/*"Processando, aguarde..."*/},oDlgMet,,,,,,.T.,,,220,20) //"Processando, aguarde..."
	oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlgMet,220,10,,.T.) // cria a régua

	ACTIVATE MSDIALOG oDlgMet CENTERED ON INIT (PreencheDados(), oDlgMet:End())
Return .T.

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcTot

Incrementa a barra de progresso.

@author  Lucas Konrad França
@version P118
@since   13/10/2015
/*/
//-------------------------------------------------------------------------------------------------
Static Function ProcInc()
	If Type("oMeter") != "U"
		nMeter++
		oMeter:Set(nMeter)
		oSayMtr:SetText(STR0060 + cValToChar(nMeter) + STR0061 + cValToChar(oMeter:nTotal) + STR0062) //"Consultando...  1 de 100 registros "
		oMeter:Refresh()
		oSayMtr:CtrlRefresh()
		SysRefresh()
	EndIf   
Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcTot

Define o valor total da barra de progresso

@param nTotal - Quantidade total da barra de progresso.

@author  Lucas Konrad França
@version P12
@since   13/10/2015
/*/
//-------------------------------------------------------------------------------------------------
Static Function ProcTot(nTotal)
   If Type("oMeter") != "U"
      oMeter:SetTotal(nTotal)
   EndIf
Return

//---------------------------------------------------------
Static Function PreencheDados()
	Local nI        := 0
	Local cAliasTop := "SOFORDER"
	Local cAliasCnt := "SOFCNT"
	Local cQuery    := ""
	Local cQueryCnt := ""
	Local nTotal    := 0
	Local cTransac  := ""
	Local cFilName  := AllTrim(FWFilialName(cEmpAnt,cFilAnt))
	Local nPos      := 0
	Local aUsers    := {}
	Local cTranIn   := ""
	Local cFiltro   := ""
	Local lAddVirgu := .F.
	
	aSize(aAllReg,0)
	aSize(aTabelas,0)

	For nI := 1 To Len(aChecks)
		lAddVirgu := .F.
		If aChecks[nI]:lValue
			If Empty(cTranIn)
				cTranIn := " '" + aChecks[nI]:cId + "' "
				If AllTrim(aChecks[nI]:cId) == "SB2"
					cFiltro := " ((SOF.OF_TRANSAC IN ('SB2','SBF','SB8')  "
				Else
					cFiltro := " ((SOF.OF_TRANSAC = '"+aChecks[nI]:cId+"' "
				EndIf
				If !Empty(aFiltEsp[nI]:dDtAte) 
					cFiltro += " AND SOF.OF_DTENVIO <= '" + DtoS(aFiltEsp[nI]:dDtAte) + "' "
				EndIf
				If !Empty(aFiltEsp[nI]:dDtDe)
					cFiltro += " AND SOF.OF_DTENVIO >= '" + DtoS(aFiltEsp[nI]:dDtDe) + "' "
				EndIf
				If aFiltEsp[nI]:lOk .Or. aFiltEsp[nI]:lPend .Or. aFiltEsp[nI]:lError
				   cFiltro += " AND SOF.OF_STATUS IN ("
				   If aFiltEsp[nI]:lOk
				      cFiltro += "'1'"
				      lAddVirgu := .T.
				   EndIf
				   If aFiltEsp[nI]:lPend
				      cFiltro += Iif(lAddVirgu,","," ") + "'2'"
				      lAddVirgu := .T.
				   EndIf
				   If aFiltEsp[nI]:lError
				      cFiltro += Iif(lAddVirgu,","," ") + "'3'"
				      lAddVirgu := .T.
				   EndIf
				   cFiltro += ")"
				Else
				   cFiltro += " AND SOF.OF_STATUS = ' ' "
				EndIf
				If !Empty(aFiltEsp[nI]:cCodCP)
				   cFiltro += " AND SOF.OF_REGIST = '" + aFiltEsp[nI]:cCodCP + "' "
				EndIf
				If !Empty(aFiltEsp[nI]:cProg)
				   cFiltro += " AND SOF.OF_PROGRAM = '" + aFiltEsp[nI]:cProg + "' "
				EndIf
				cFiltro += ")"  
			Else
				cTranIn += ", '" + aChecks[nI]:cId + "' "
				
				If AllTrim(aChecks[nI]:cId) == "SB2"
					cFiltro += " OR (SOF.OF_TRANSAC IN ('SB2','SBF','SB8') "
				Else
					cFiltro += " OR (SOF.OF_TRANSAC = '"+aChecks[nI]:cId+"' "
				EndIf
				
				If !Empty(aFiltEsp[nI]:dDtAte) 
					cFiltro += " AND SOF.OF_DTENVIO <= '" + DtoS(aFiltEsp[nI]:dDtAte) + "' "
				EndIf
				If !Empty(aFiltEsp[nI]:dDtDe)
					cFiltro += " AND SOF.OF_DTENVIO >= '" + DtoS(aFiltEsp[nI]:dDtDe) + "' "
				EndIf
				If aFiltEsp[nI]:lOk .Or. aFiltEsp[nI]:lPend .Or. aFiltEsp[nI]:lError
				   cFiltro += " AND SOF.OF_STATUS IN ("
				   If aFiltEsp[nI]:lOk
				      cFiltro += "'1'"
				      lAddVirgu := .T.
				   EndIf
				   If aFiltEsp[nI]:lPend
				      cFiltro += Iif(lAddVirgu,","," ") + "'2'"
				      lAddVirgu := .T.
				   EndIf
				   If aFiltEsp[nI]:lError
				      cFiltro += Iif(lAddVirgu,","," ") + "'3'"
				      lAddVirgu := .T.
				   EndIf
				   cFiltro += ")"
				Else
				   cFiltro += " AND SOF.OF_STATUS = ' ' "
				EndIf
				If !Empty(aFiltEsp[nI]:cCodCP)
				   cFiltro += " AND SOF.OF_REGIST = '" + aFiltEsp[nI]:cCodCP + "' "
				EndIf
				If !Empty(aFiltEsp[nI]:cProg)
				   cFiltro += " AND SOF.OF_PROGRAM = '" + aFiltEsp[nI]:cProg + "' "
				EndIf
				cFiltro += ")"
			EndIf
		EndIf
	Next nI
	If !Empty(cFiltro)
		cFiltro := " AND " + cFiltro + ")"
	EndIf

	cQuery := " SELECT SOF.R_E_C_N_O_ RECSOF " 
	cQuery +=   " FROM " + RetSqlName("SOF") + " SOF "
	cQuery +=  " WHERE SOF.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SOF.OF_FILIAL  = '" + xFilial("SOF") + "' "
	If Empty(cTranIn)
		cQuery += " AND SOF.OF_TRANSAC IN ('')"
	EndIf
	cQuery += cFiltro
	
	cQueryCnt := "SELECT COUNT(*) TOTAL FROM (" + ChangeQuery(cQuery) + ") t "
	
	cQuery +=  " ORDER BY SOF.OF_FILIAL ASC, "
	cQuery +=     " (CASE SOF.OF_DATPROC WHEN '' THEN SOF.OF_DTENVIO ELSE SOF.OF_DATPROC END) DESC, "
	cQuery +=     " (CASE SOF.OF_HORPROC WHEN '' THEN SOF.OF_HRENVIO ELSE SOF.OF_HORPROC END) DESC, "
	cQuery +=     " SOF.OF_TRANSAC ASC "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCnt),cAliasCnt,.T.,.T.)
	nTotal := (cAliasCnt)->(TOTAL)
	(cAliasCnt)->(dbCloseArea())

	ProcTot(nTotal)

	dbSelectArea("SOF")
	SOF->(dbGoTop())
	While !(cAliasTop)->(Eof())
		
		ProcInc()
	
		SOF->(dbGoTo((cAliasTop)->RECSOF))

		For nI := 1 To Len(aTabsFil)
			cTransac := Iif(AllTrim(SOF->OF_TRANSAC)$"SB2|SB8|SBF","SB2",AllTrim(SOF->OF_TRANSAC))
			If AllTrim(cTransac) == aTabsFil[nI][1]
				aAdd(aTabelas,{})

				aAdd(aTabelas[Len(aTabelas)], LoadBitmap( GetResources(), "LBOK" ) )

				If lFilial
					aAdd(aTabelas[Len(aTabelas)],AllTrim(SOF->OF_FILIAL) + " - " + cFilName )
				EndIf

				aAdd(aTabelas[Len(aTabelas)],aTabsFil[nI][2] + Space(10) )
				//aAdd(aTabelas[Len(aTabelas)],cTransac )

				Do Case
		           Case SOF->OF_STATUS == "1"
		           	aAdd(aTabelas[Len(aTabelas)],STR0018)//"Integrado com sucesso"
		           Case SOF->OF_STATUS == "2"
		           	aAdd(aTabelas[Len(aTabelas)],STR0019)//"Pendente de envio"
		           Case SOF->OF_STATUS == "3"
		           	aAdd(aTabelas[Len(aTabelas)],STR0020)//"Pendente com erro"
		           Otherwise
		           	aAdd(aTabelas[Len(aTabelas)],"")
				End

				nPos := aScan(aUsers, {|x| x[1] == SOF->OF_USU})
				If nPos > 0 
					cNameUsr := aUsers[nPos,2]
				Else
					cNameUsr := UsrRetName(SOF->OF_USU)
					aAdd(aUsers,{SOF->OF_USU, cNameUsr})
				EndIf

				aAdd(aTabelas[Len(aTabelas)],AllTrim(SOF->OF_REGIST))
				aAdd(aTabelas[Len(aTabelas)],SOF->OF_DTENVIO)
				aAdd(aTabelas[Len(aTabelas)],SOF->OF_HRENVIO)
				aAdd(aTabelas[Len(aTabelas)],cNameUsr)
				aAdd(aTabelas[Len(aTabelas)],AllTrim(SOF->OF_PROGRAM))
				aAdd(aTabelas[Len(aTabelas)],SOF->OF_DATPROC)
				aAdd(aTabelas[Len(aTabelas)],SOF->OF_HORPROC)

				//Colunas que não aparecerão no Grid (Caso adicione alguma informação, ponha sempre no final e acesse utilizando Len(aColunas)+x e adicionar na função ValRegVazio() )
				aAdd(aTabelas[Len(aTabelas)],AllTrim(SOF->OF_MSGRET))	//Len(aColunas)+1
				aAdd(aTabelas[Len(aTabelas)],AllTrim(SOF->OF_STATUS))	//Len(aColunas)+2
				aAdd(aTabelas[Len(aTabelas)],AllTrim(cTransac))	//Len(aColunas)+3
				aAdd(aTabelas[Len(aTabelas)],AllTrim(SOF->OF_FILIAL))	//Len(aColunas)+4
				aAdd(aTabelas[Len(aTabelas)],.T.)							//Len(aColunas)+5 //Refere ao checkbox de marcação da linha
				aAdd(aTabelas[Len(aTabelas)],SOF->(RecNo()))				//Len(aColunas)+6 //Chave na banco de dados
				aAdd(aTabelas[Len(aTabelas)],AllTrim(SOF->OF_NOMEXML))	//Len(aColunas)+7
				aAdd(aTabelas[Len(aTabelas)],SOF->OF_DTENVIO)				//Len(aColunas)+8
				aAdd(aTabelas[Len(aTabelas)],SOF->OF_HRENVIO)				//Len(aColunas)+9
				aAdd(aTabelas[Len(aTabelas)],AllTrim(SOF->OF_REGIST))	//Len(aColunas)+10

				Exit

			EndIf
		Next

		(cAliasTop)->(dbSkip())
	End

	aAllReg := aClone(aTabelas)

	(cAliasTop)->(dbCloseArea())
Return Nil
//---------------------------------------------------------
Static Function FiltraInfo()
	Local nI, nJ
	Local aFiltros := {}
	Local aFilEsp  := {}
	Local cCod     := ""
	Default lAutoMacao := .F.
	
	For nI := 1 To Len(aChecks)
		If aChecks[nI]:lValue
			aAdd(aFiltros,aChecks[nI]:cId)
			aAdd(aFilEsp,aFiltEsp[nI])
		EndIf
	Next
	
	aSize(aTabelas,0)
	
	For nI := 1 To Len(aAllReg)
		For nJ := 1 To Len(aFiltros)
			If aAllReg[nI][Len(aColunas)+3] == aFiltros[nJ]
			
				If !((aFilEsp[nJ]:lOk .And. aAllReg[nI][Len(aColunas)+2] == "1") .Or. (aFilEsp[nJ]:lPend .And. aAllReg[nI][Len(aColunas)+2] == "2") .Or. (aFilEsp[nJ]:lError .And. aAllReg[nI][Len(aColunas)+2] == "3"))
					Exit
				EndIf

				If lFilial
					If aAllReg[nI][Len(aColunas)+3] == "SB2"
						If AT("+",aAllReg[nI][5]) > 0
							cCod := StrTokArr(aAllReg[nI][5],"+")[1]
							If !(Empty(aFilEsp[nJ]:cCodCP)) .And. (Len(AllTrim(cCod)) != Len(AllTrim(aFilEsp[nJ]:cCodCP)) .Or. AllTrim(aFilEsp[nJ]:cCodCP) != AllTrim(cCod))
								Exit
							EndIf
						Else
							cCod := aAllReg[nI][5]
							If !(Empty(aFilEsp[nJ]:cCodCP)) .And. (Len(AllTrim(cCod)) != Len(AllTrim(aFilEsp[nJ]:cCodCP)) .Or. AllTrim(aFilEsp[nJ]:cCodCP) != AllTrim(cCod))
								Exit
							EndIf
						EndIf
					Else
						cCod := aAllReg[nI][5]
						If !(Empty(aFilEsp[nJ]:cCodCP)) .And. (Len(AllTrim(cCod)) != Len(AllTrim(aFilEsp[nJ]:cCodCP)) .Or. AllTrim(aFilEsp[nJ]:cCodCP) != AllTrim(cCod))
							Exit
						EndIf
					EndIf

					If !(Empty(aFilEsp[nJ]:cProg)) .And. AllTrim(aFilEsp[nJ]:cProg) != aAllReg[nI][9]
						Exit
					EndIf

					IF (Empty(aFilEsp[nJ]:dDtDe) .Or. aFilEsp[nJ]:dDtDe <= aAllReg[nI][6]) .And. ;
					   (Empty(aFilEsp[nJ]:dDtAte) .Or. aFilEsp[nJ]:dDtAte >= aAllReg[nI][6])
						aAdd(aTabelas,aClone(aAllReg[nI]))
					EndIf
				Else
					
					If aAllReg[nI][Len(aColunas)+3] == "SB2"
						If AT("+",aAllReg[nI][4]) > 0
							cCod := aAllReg[nI][4]
							If !(Empty(aFilEsp[nJ]:cCodCP)) .And. (Len(AllTrim(cCod)) != Len(AllTrim(aFilEsp[nJ]:cCodCP)) .Or. AllTrim(aFilEsp[nJ]:cCodCP) != AllTrim(cCod))
								Exit
							EndIf
						Else
							cCod := aAllReg[nI][4]
							If !(Empty(aFilEsp[nJ]:cCodCP)) .And. (Len(AllTrim(cCod)) != Len(AllTrim(aFilEsp[nJ]:cCodCP)) .Or. AllTrim(aFilEsp[nJ]:cCodCP) != AllTrim(cCod))
								Exit
							EndIf
						EndIf
					Else
						cCod := aAllReg[nI][4]
						If !(Empty(aFilEsp[nJ]:cCodCP)) .And. (Len(AllTrim(cCod)) != Len(AllTrim(aFilEsp[nJ]:cCodCP)) .Or. AllTrim(aFilEsp[nJ]:cCodCP) != AllTrim(cCod))
							Exit
						EndIf
					EndIf

					If !(Empty(aFilEsp[nJ]:cProg)) .And. AllTrim(aFilEsp[nJ]:cProg) != aAllReg[nI][8]
						Exit
					EndIf

					IF aFilEsp[nJ]:dDtDe <= aAllReg[nI][5] .And. aFilEsp[nJ]:dDtAte >= aAllReg[nI][5]
						aAdd(aTabelas,aClone(aAllReg[nI]))
					EndIf
				EndIf

				Exit
			EndIf
		Next
	Next
	
	ValRegVazio()
	
	IF !lAutoMacao
		oList:Refresh()
		AlteraMemo(oList:nAt)
	ENDIF
	
Return Nil
//---------------------------------------------------------
Static Function rbLine(nAt,nColunas)
	Local nI
	Local aRet := {}

	For nI := 1 To nColunas
		aAdd(aRet,aTabelas[nAt][nI])
	Next

Return aRet
//---------------------------------------------------------
Static Function TrocaCheck(nAt)
	Local nI
	
	//Inverte o valor do check
	aTabelas[nAt][Len(aColunas)+5] := !aTabelas[nAt][Len(aColunas)+5]

	If aTabelas[nAt][Len(aColunas)+5]
		aTabelas[nAt][1] := LoadBitmap( GetResources(), "LBOK" )
	Else
		aTabelas[nAt][1] := LoadBitmap( GetResources(), "LBNO" )
	EndIf

	For nI := 1 To Len(aAllReg)
		If aAllReg[nI][Len(aColunas)+6] == aTabelas[nAt][Len(aColunas)+6]

			//Inverte o valor do check
			aAllReg[nI][Len(aColunas)+5] := aTabelas[nAt][Len(aColunas)+5]

			If aTabelas[nAt][Len(aColunas)+5]
				aAllReg[nI][1] := LoadBitmap( GetResources(), "LBOK" )
			Else
				aAllReg[nI][1] := LoadBitmap( GetResources(), "LBNO" )
			EndIf
		
			Exit
		EndIf
	Next
	
Return Nil
//---------------------------------------------------------
Static Function MarcaTodos(oBrw)
	Local nI
	Default lAutoMacao := .F.
	
	If lToggleCheckBox
		For nI := 1 To Len(aTabelas)
			aTabelas[nI][1] := LoadBitmap( GetResources(), "LBOK" )
			aTabelas[nI][Len(aColunas)+5] := .T.
		Next
		
		For nI := 1 To Len(aAllReg)
			aAllReg[nI][1] := LoadBitmap( GetResources(), "LBOK" )
			aAllReg[nI][Len(aColunas)+5] := .T.
		Next
	Else
		For nI := 1 To Len(aTabelas)
			aTabelas[nI][1] := LoadBitmap( GetResources(), "LBNO" )
			aTabelas[nI][Len(aColunas)+5] := .F.
		Next
		
		For nI := 1 To Len(aAllReg)
			aAllReg[nI][1] := LoadBitmap( GetResources(), "LBNO" )
			aAllReg[nI][Len(aColunas)+5] := .F.
		Next
	EndIf
	
	IF !lAutoMacao
		oBrw:Refresh()
	ENDIF
	
Return Nil
//---------------------------------------------------------
Static Function AlteraMemo(nAt)
	cMemo := aTabelas[nAt][Len(aColunas)+1]

	SetFocus(oMemo:HWND)
	SetFocus(oList:HWND)
Return Nil
//---------------------------------------------------------
Static Function Reprocessar()
	Local nI
	Local nQtdReg := 0
	Local nQtdOK  := 0
	
	Private oDlgProg
	Private nAtuTotal
	Private oMtTotal, oProg
	Private nProg := 0
	Private cProg := Space(100)
	Default lAutoMacao := .F.
	
	dbSelectArea("SOD")
	If SOD->(dbSeek(xFilial("SOD")))
		If SOD->OD_ATIVO != "1"
			Alert(STR0043)//"A integração não está ativa. Ative a integração partir da tela de parâmetros para reprocessar."
			Return Nil
		EndIf
	Else
		Alert(STR0043)//"A integração não está ativa. Ative a integração partir da tela de parâmetros para reprocessar."
		Return Nil
	EndIf

	If ValType(aTabelas[1][Len(aColunas)+5]) != "L"
		Alert(STR0021)//"Nenhum registro selecionado para reprocessar."
		Return Nil
	EndIf

	For nI := 1 To Len(aTabelas)		
		If aTabelas[nI][Len(aColunas)+5]
			nQtdReg := nQtdReg + 1
			If aTabelas[nI][Len(aColunas)+2] == "1"
				nQtdOK := nQtdOK + 1
			EndIf
		EndIf
	Next

	If nQtdReg == 0
		Alert(STR0021)//"Nenhum registro selecionado para reprocessar."
		Return Nil
	ElseIf nQtdReg == nQtdOK
		Alert(STR0022)//"Todos registros selecionados já foram integrados com sucesso."
		Return Nil
	ElseIf nQtdReg > 1 .And. nQtdOK > 0
		If !MsgYesNo( STR0023 + " " + AllTrim(Str(nQtdReg)) + " " + STR0024 + " (" + AllTrim(Str(nQtdOK)) + " " + STR0025 + ")", STR0026) //"Deseja reprocessar os " + x + " registros selecionados? (" + x + " registros já estão integrados e não serão reprocessados)" - "Aviso" 
			Return Nil	
		EndIf
	ElseIf nQtdReg > 1
		If !MsgYesNo( STR0023 + " " + AllTrim(Str(nQtdReg)) + " " + STR0024, STR0026)//"Deseja reprocessar os " + x + " registros selecionados?" - "Aviso"
			Return Nil	
		EndIf
	EndIf
	
	IF !lAutoMacao
		DEFINE DIALOG oDlgProg TITLE STR0027 FROM 0, 0 TO 22, 75 SIZE 410, 150 PIXEL //"Carregando..."
		
		@ 010,010 SAY oSay VAR STR0028 + ":" OF oDlgProg PIXEL FONT (TFont():New('Arial', 0, -11, .T., .T.)) //"Registros reprocessados:"
		@ 020,010 METER oMtTotal VAR nAtuTotal TOTAL 1000 SIZE 190, 15 OF oDlgProg UPDATE PIXEL
		@  40,010 SAY oProg VAR cProg OF oDlgProg PIXEL

		oMtTotal:nTotal := nQtdReg
		oMtTotal:Set(nProg)
		SysRefresh()

		ACTIVATE MSDIALOG oDlgProg CENTER ON INIT SelecReprocessa()
	ENDIF
	
	buscaDados()
	//PreencheDados()
	FiltraInfo()
	lToggleCheckBox := .T.
Return Nil
//---------------------------------------------------------
Static Function SelecReprocessa()
	Local nI, nJ
	Default lAutoMacao := .F.
	
	dbSelectArea("SOF")
	
	For nI := 1 To Len(aTabelas)		
		If aTabelas[nI][Len(aColunas)+5]

			IF !lAutoMacao
				If lFilial
					oProg:cCaption := STR0029 + " " + AllTrim(aTabelas[nI][3]) + " " + AllTrim(aTabelas[nI][5]) + "." //"Reprocessando"
				Else
					oProg:cCaption := STR0029 + " " + AllTrim(aTabelas[nI][2]) + " " + AllTrim(aTabelas[nI][4]) + "." //"Reprocessando"
				EndIf
				nProg := nProg + 1
				oMtTotal:Set(nProg)
			ENDIF

			SysRefresh()
			
			If aTabelas[nI][Len(aColunas)+2] != "1"
				For nJ := 1 To Len(aTabsFil)
					If aTabelas[nI][Len(aColunas)+3] == aTabsFil[nJ][1]
						SOF->(dbGoTo(aTabelas[nI][Len(aColunas)+6]))
						&(aTabsFil[nJ][3])
						Exit
					EndIf
				Next
			EndIf

		EndIf
	Next
	
	IF !lAutoMacao
		oDlgProg:End()
	ENDIF
Return Nil
//---------------------------------------------------------
Static Function ExcluiSOF()
	Local nI
	Local nQtdReg := 0
	Default lAutoMacao := .F.

	If ValType(aTabelas[1][Len(aColunas)+5]) != "L"
		Alert(STR0030)//"Nenhum registro selecionado para excluir."
		Return Nil
	EndIf

	For nI := 1 To Len(aTabelas)
		If aTabelas[nI][Len(aColunas)+5]
			nQtdReg := nQtdReg + 1
		EndIf
	Next

	If nQtdReg > 1
		If MsgYesNo(STR0031 + " " + AllTrim(Str(nQtdReg)) + " " + STR0032, STR0026)//"Deseja excluir os " + x + "registros selecionados?" - "Aviso"
			ExcluiRegs()
		EndIf
	ElseIf nQtdReg == 1
		IF !lAutoMacao
			If MsgYesNo(STR0033, STR0026)//"Deseja excluir o registro selecionado?" - "Aviso"
				ExcluiRegs()
			EndIf
		ENDIF
	Else
		Alert(STR0034)//"Nenhum registro selecionado para excluir."
	EndIf

Return Nil
//---------------------------------------------------------
Static Function SalvarXML()
	Local nI
	Local nQtdReg := 0
	Local cTemp
	Default lAutoMacao := .F.

	If ValType(aTabelas[1][Len(aColunas)+5]) != "L"
		Alert(STR0035)//"Nenhum registro selecionado para gerar xml."
		Return Nil
	EndIf

	For nI := 1 To Len(aTabelas)		
		If aTabelas[nI][Len(aColunas)+5]
			nQtdReg := nQtdReg + 1
		EndIf
	Next

	If nQtdReg == 0
		Alert(STR0035)//"Nenhum registro selecionado para gerar xml."
		Return Nil
	EndIf
	
	cTemp := SelectFile("diretorio.xml")
		
	If !(Empty(cTemp))
		GravaXMLs(cTemp)
		MsgInfo(STR0064 + cTemp) //"Arquivos gerados com sucesso na pasta "
	Else
		Alert(STR0065) //"Diretório não foi selecionado."
	EndIf

Return Nil
//-------------------------------------------------------------------
Static Function GravaXMLs(cCaminho)
	Local nI
	Local nHandle
	
	dbSelectArea("SOF")

	For nI := 1 To Len(aTabelas)
		If aTabelas[nI][Len(aColunas)+5]
			SOF->(dbGoTo(aTabelas[nI][Len(aColunas)+6]))
			
			If !Empty(aTabelas[nI][Len(aColunas)+7])
				nHandle := fCreate(cCaminho + aTabelas[nI][Len(aColunas)+7]) 
			Else
				nHandle := fCreate(cCaminho + aTabelas[nI][Len(aColunas)+3] + "_" + aTabelas[nI][Len(aColunas)+10] + "_" + DToS(aTabelas[nI][Len(aColunas)+8]) + StrTran(aTabelas[nI][Len(aColunas)+9],":","") + ".xml" )
			EndIf
 
			If nHandle = -1  
		        //conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
			Else
		        fWrite(nHandle, SOF->OF_XML)
		        fClose(nHandle)
			EndIf
		EndIf
	Next

Return Nil
//-------------------------------------------------------------------
Static Function SelectFile(cFormatFile)
Default lAutoMacao := .F. 
	IF !lAutoMacao
		cFile := cGetFile("|" + cFormatFile + "|",STR0036,0,,.F.,,.T.,.T.)//"Selecione uma pasta para gravar o arquivo"
	ENDIF

	aChave := StrTokArr(cFile,"\")
	If Len(aChave) > 1
		aDel(aChave,Len(aChave))
		aSize(aChave,Len(aChave)-1)
		cFile := ArrTokStr(aChave,"\") + "\"
	EndIf
Return cFile
//---------------------------------------------------------
Static Function ValRegVazio()
	Local nI

	If Len(aTabelas) == 0
		aAdd(aTabelas,{})
		
		For nI := 1 To Len(aColunas)
			If nI == 1
				aAdd(aTabelas[1],LoadBitmap( GetResources(), "LBOK" ))
			Else
				aAdd(aTabelas[1],"")
			EndIf
		Next
		
		//Colunas que não aparecerão no Grid
		For nI := 1 To 7
			aAdd(aTabelas[1],"")
		Next
	EndIf
Return
//---------------------------------------------------------
Static Function ExcluiRegs()
	Local nI := 1 
	Local nJ
	Default lAutoMacao := .F.
	
	dbSelectArea("SOF")
	SOF->(dbSetOrder(1))

	While nI <= Len(aTabelas)		
		If aTabelas[nI][Len(aColunas)+5]
			SOF->(dbGoTo(aTabelas[nI][Len(aColunas)+6]))

			IF !lAutoMacao
				RecLock("SOF", .F.)
				SOF->(dbDelete())
				SOF->(MsUnLock())
			ENDIF

			dbSelectArea("SOD")
			SOD->(dbSeek(xFilial("SOD")))
			
			//Apaga XML
			If aTabelas[nI][Len(aColunas)+2] == "1" .And. ExistDir(SOD->OD_DIRENV)
				FErase(AllTrim(SOD->OD_DIRENV)+aTabelas[nI][Len(aColunas)+7])
				
			ElseIf ExistDir(SOD->OD_DIRPEND)
				FErase(AllTrim(SOD->OD_DIRPEND)+aTabelas[nI][Len(aColunas)+7])
				
			EndIf

			For nJ := 1 To Len(aAllReg)
				If aAllReg[nJ][Len(aColunas)+6] == aTabelas[nI][Len(aColunas)+6]
					aDel(aAllReg,nJ)
					aSize(aAllReg,Len(aAllReg)-1)
					Exit
				EndIf
			Next

			IF !lAutoMacao
				aDel(aTabelas,nI)
				aSize(aTabelas,Len(aTabelas)-1)
			ENDIF
		Else
			nI := nI + 1
		EndIf
	End
	
	ValRegVazio()
	
	IF !lAutoMacao
		oList:Refresh()
		AlteraMemo(oList:nAt)
	ENDIF
Return Nil
//---------------------------------------------------------
// Classe construtura de checkbox dinamico
//---------------------------------------------------------
Class PCPA110C
	//Método construtor da classe
	Method New(oDlg,cId,cDesc,nPosAlt,nPosLar,bChange) Constructor
	
	//Propriedades
	Data lValue
	Data oCheckBox
	Data cId
EndClass
//---------------------------------------------------------
Method New(oDlg,cId,cDesc,nPosAlt,nPosLar,bChange) Class PCPA110C
	Default bChange := {|| }

	Self:cId := cId

	Self:lValue := .F.
	@ nPosAlt, nPosLar CHECKBOX Self:oCheckBox VAR Self:lValue PROMPT cDesc WHEN PIXEL OF oDlg SIZE 100,015 MESSAGE ""
	Self:oCheckBox:bChange := bChange

	//@ nPosAlt, nPosLar + 8 SAY oAcao VAR cDesc OF oDlg PIXEL

Return Self
//---------------------------------------------------------
// Classe construtura dos filtros especificos dinamicos
Class PCPA110F
	//Método construtor da classe
	Method New(oDlg,cId,cDesc,nPosAlt,nPosLar,bOk) Constructor
	
	//Propriedades
	Data cId
	Data cDesc
	Data bOk
	Data oDlgFil
	Data dDtDe
	Data dDtAte
	Data cCodCP
	Data lOk
	Data lPend
	Data lError
	Data oCheckBox1
	Data oCheckBox2
	Data oCheckBox3
	Data cProg

	//Métodos
	Method Dialog()
EndClass
//---------------------------------------------------------
Method New(oDlg,cId,cDesc,nPosAlt,nPosLar,bOk) Class PCPA110F
	Local oBtn

	Self:cId := cId
	Self:cDesc := cDesc
	Self:bOk := bOk
	Self:dDtDe := SToD("20000101")
	Self:dDtAte := SToD("29990101")
	Self:cCodCP := Space(255)
	Self:lOk := .T.
	Self:lPend := .T.
	Self:lError := .T.
	Self:cProg := Space(255)

	@ nPosAlt-2,nPosLar BUTTON oBtn PROMPT "..."  SIZE 12,10 WHEN (.T.) ACTION (Self:Dialog()) OF oDlg PIXEL
	
Return Self
//---------------------------------------------------------
Method Dialog() Class PCPA110F
	Local oGet
	Local cConPad := Self:cId
	
	DEFINE DIALOG Self:oDlgFil TITLE Self:cDesc FROM 0,0 TO 250,500 PIXEL

	//Faixa data +3
	@ 10, 09 SAY oAcao VAR STR0037 + ":" OF Self:oDlgFil PIXEL //"Data Envio:"
	
	@ 22, 09 SAY oAcao VAR STR0038 + ":" OF Self:oDlgFil PIXEL //"De:"
	TGet():New(018,025,{|u| If(PCount()==0,Self:dDtDe,Self:dDtDe:=u)}  ,Self:oDlgFil,060,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"Self:dDtDe",,,,.T.  )
	
	@ 22, 85 SAY oAcao VAR STR0039 + ":" OF Self:oDlgFil PIXEL //"Até:"
	TGet():New(018,100,{|u| If(PCount()==0,Self:dDtAte,Self:dDtAte:=u)},Self:oDlgFil,060,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"Self:dDtAte",,,,.T.  )

	//Checkbox Status +3
	@ 35, 09 SAY oAcao VAR STR0040 + ":" OF Self:oDlgFil PIXEL //"Status:"

	@ 43, 09 CHECKBOX Self:oCheckBox1 VAR Self:lOk    PROMPT STR0018 /*"Integrado com sucesso"*/ WHEN PIXEL OF Self:oDlgFil SIZE 070,015 MESSAGE ""
	//@ 43, 009 + 8 SAY oAcao VAR STR0018 OF Self:oDlgFil PIXEL //"Integrado com sucesso"

	@ 43, 90 CHECKBOX Self:oCheckBox2 VAR Self:lPend  PROMPT STR0019 /*"Pendente de envio"*/ WHEN PIXEL OF Self:oDlgFil SIZE 070,015 MESSAGE ""
	//@ 43, 090 + 8 SAY oAcao VAR STR0019 OF Self:oDlgFil PIXEL //"Pendente de envio"

	@ 43, 170 CHECKBOX Self:oCheckBox3 VAR Self:lError PROMPT STR0020 /*"Pendente com erro"*/ WHEN PIXEL OF Self:oDlgFil SIZE 070,015 MESSAGE ""
	//@ 43, 170 + 8 SAY oAcao VAR STR0020 OF Self:oDlgFil PIXEL //"Pendente com erro"

	If Self:cId == "SB2"
		cConPad := "SB1"
	ElseIf Self:cId == "CYB"
		cConPad := "CYB001"
	EndIf

	//F3 - Consulta Padrão + 3
	@ 58, 09 SAY oAcao VAR STR0041 + ":" OF Self:oDlgFil PIXEL //"Registro Específico:"
	@ 66, 09 MSGET Self:cCodCP SIZE 120,010 OF Self:oDlgFil F3 cConPad PIXEL VALID (vldRegEsp(Self:cId,@Self:cCodCP))

	//Programa + 3
	@ 83, 09 SAY oAcao VAR STR0044 + ":" OF Self:oDlgFil PIXEL //"Programa:"
	@ 91, 09 MSGET Self:cProg SIZE 120,010 OF Self:oDlgFil PIXEL

	//Botão Confirmar
	@ 106, 30 BUTTON oBtn PROMPT STR0048 SIZE 60,12 WHEN (.T.) ACTION {||Replicar(Self),Eval(Self:bOk),Self:oDlgFil:End()} OF Self:oDlgFil PIXEL //"Replicar"
	//Botão Confirmar
	@ 106, 95 BUTTON oBtn PROMPT STR0042 SIZE 60,12 WHEN (.T.) ACTION {||Eval(Self:bOk),Self:oDlgFil:End()} OF Self:oDlgFil PIXEL //"Confirmar"
	//Botão Cancelar
	@ 106, 160 BUTTON oBtn PROMPT STR0049 SIZE 60,12 WHEN (.T.) ACTION {||Self:oDlgFil:End()} OF Self:oDlgFil PIXEL //"Cancelar"

	ACTIVATE MSDIALOG Self:oDlgFil CENTERED

Return Nil

Static Function vldRegEsp(cId, cCod)
	Local aRegs := {{"SBE","SBE->BE_LOCAL","A"},;
	                {"SG2","SG2->G2_PRODUTO","D"}}
	Local nPos  := 0
	
	nPos := aScan(aRegs, {|x| x[1] == AllTrim(cId)})
	
	If nPos > 0 .And. !Empty(cCod) .And. &(AllTrim(cId)+"->(!Eof())") .And. AT("+",cCod) < 1
		If aRegs[nPos,3] == "A"
			cCod := AllTrim(&(aRegs[nPos,2])) + "+" + cCod
		Else
			cCod := Padr(AllTrim(cCod) + "+" + AllTrim(&(aRegs[nPos,2])),255)
		EndIf
	EndIf
return .T.

Static Function Replicar(Obj)
	Local nI

	For nI := 1 To Len(aFiltEsp)
		
		aFiltEsp[nI]:dDtDe  := Obj:dDtDe
		aFiltEsp[nI]:dDtAte := Obj:dDtAte
		aFiltEsp[nI]:lOk    := Obj:lOk
		aFiltEsp[nI]:lPend  := Obj:lPend
		aFiltEsp[nI]:lError := Obj:lError
		
	Next
	
Return Nil

Static Function ChangCheck(lTipo)
	//lTipo: .T. = Marcar todos, .F. = Desmarcar todos
	Local nI := 0
	
	For nI := 1 To Len(aChecks)
		aChecks[nI]:lValue := lTipo
	Next
	
	FiltraInfo()
Return .T.
