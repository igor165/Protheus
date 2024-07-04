#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPA112.CH"
#DEFINE PULALINHA CHR(13)+CHR(10)

Function PCPA112()
	Local oDlgUpd, oCheckAll
	Local aCoors  := FWGetDialogSize( oMainWnd )
	Local nLargura:= aCoors[4]
	Local nHeight := aCoors[3]
	Local nI
	Private oMemo
	Private cMemo := ""
	//Private oOk:= LoadBitmap( GetResources(), "LBOK" )
	//Private oNOk:= LoadBitmap( GetResources(), "LBNO" )
	Private lFilial	:= .F.
	Private aTabelas:= {}
	Private aAllReg	:= {}
	Private aChecks	:= {}
	Private lChange := .F.
	Private aTabsFil := {}
	Default lAutoMacao := .F.
	
	//Lista de opções que aparecerão... Para adicionar, basta colocar mais uma posição no array. NENHUMA OUTRA ALTERAÇÃO NECESSARIA
	aAdd(aTabsFil, {""       ,STR0001,""}) //"Dados inconsistentes"
	aAdd(aTabsFil, {"MATI681",STR0002,""}) //"Apontamento de Produção"
	aAdd(aTabsFil, {"MATI682",STR0003,""}) //"Apontamento de Parada"
	aAdd(aTabsFil, {"MATI685",STR0059,""}) //"Apontamento de Perda"
	aAdd(aTabsFil, {"SFCI003",STR0043,""}) //"Motivo de Refugo"
	aAdd(aTabsFil, {"SFCI004",STR0044,""}) //"Motivo de Parada"
	aAdd(aTabsFil, {"MATI240",STR0045,""}) //"Movimentações Avulsas"
	aAdd(aTabsFil, {"MATI261",STR0046,""}) //"Transferências"
	
	aFiltEsp := {}

	IF !lAutoMacao
		DEFINE DIALOG oDlgUpd TITLE STR0005 FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL //"Log de Importação"

		//-----------------------
		//Painel Lateral esquerdo
		//-----------------------
		oPanelLat := TPanel():New( 01, 01, ,oDlgUpd, , , , , , 100, (nHeight/2) - 20, .T.,.T. )
		
		@ 15, 05 CHECKBOX oCheckAll VAR lChange PROMPT STR0047 WHEN PIXEL OF oPanelLat SIZE 100,015 MESSAGE "" //"Marca/Desmarca todos"
		oCheckAll:bChange := {|| ChangCheck(lChange)}
		
		For nI := 1 To Len(aTabsFil)
			//Checkbox Filtro
			aAdd(aChecks,PCPA110C():New(oPanelLat,aTabsFil[nI][1],aTabsFil[nI][2],(nI+1) * 15,05,{|| FiltraInfo()}) )
			aAdd(aFiltEsp,PCPA112F():New(oPanelLat,aTabsFil[nI][1],aTabsFil[nI][2],(nI+1) * 15,82,{|| FiltraInfo()}) )
		Next

		//----------------
		//Painel Principal
		//----------------
		oPanelPrinc := TPanel():New( 01, 100, ,oDlgUpd, , , , , , (nLargura/2)-100, (nHeight/2) - 20, .T.,.T. )
	ENDIF

	aColunas := {} //Colunas
	aTamanhos := {} //Tamanho das colunas

	aAdd(aColunas," ")
	aAdd(aTamanhos,10)

	If FWModeAccess('SOG',3) == "E" .Or. FWModeAccess('SOG',2) == "E"  .Or. FWModeAccess('SOG',1) == "E"
		lFilial := .T.
		aAdd(aColunas,STR0006)//"Filial"
		aAdd(aTamanhos,20)
	EndIf

	aAdd(aColunas,STR0007)//"Transação"
	aAdd(aTamanhos,30)
	aAdd(aColunas,STR0008)//"Status"
	aAdd(aTamanhos,20)
	aAdd(aColunas,STR0009)//"OP"
	aAdd(aTamanhos,35)
	aAdd(aColunas,STR0039)//"Operação"
	aAdd(aTamanhos,30)
	aAdd(aColunas,STR0040)//"Estorno"
	aAdd(aTamanhos,30)
	aAdd(aColunas,STR0010)//"Recurso"
	aAdd(aTamanhos,35)
	aAdd(aColunas,STR0011)//"Produto"
	aAdd(aTamanhos,60)
	aAdd(aColunas,STR0012)//"Quantidade"
	aAdd(aTamanhos,40)
	aAdd(aColunas,STR0013)//"Data Ini"
	aAdd(aTamanhos,35)
	aAdd(aColunas,STR0014)//"Hora Ini"
	aAdd(aTamanhos,35)
	aAdd(aColunas,STR0015)//"Data Fim"
	aAdd(aTamanhos,35)
	aAdd(aColunas,STR0016)//"Hora Fim"
	aAdd(aTamanhos,35)
	aAdd(aColunas,STR0017)//"Data Processamento"
	aAdd(aTamanhos,60)
	aAdd(aColunas,STR0018)//"Hora Processamento"
	aAdd(aTamanhos,60)
	aAdd(aColunas,STR0048) //"Motivo"
	aAdd(aTamanhos,30)
	aAdd(aColunas,STR0049) //"Tipo movimento"
	aAdd(aTamanhos,50)
	aAdd(aColunas,STR0050) //"Produto origem"
	aAdd(aTamanhos,60)
	aAdd(aColunas,STR0051) //"Local origem"
	aAdd(aTamanhos,50)
	aAdd(aColunas,STR0052) //"Produto destino"
	aAdd(aTamanhos,60)
	aAdd(aColunas,STR0053) //"Local destino"
	aAdd(aTamanhos,50)
	SX3->(dbSetOrder(2))
	SX3->(dbSeek("OG_IDMES"))
	aAdd(aColunas,X3Titulo())
	aAdd(aTamanhos,200)

	IF !lAutoMacao
		oList := TWBrowse():New( 05, 05, (nLargura/2)-110,(((nHeight/2)-5) * 0.6)-20,,aColunas,aTamanhos,oPanelPrinc,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

		lToggleCheckBox := .T.

		@ 06, 06 CHECKBOX oCheckBox VAR lToggleCheckBox PROMPT "" WHEN PIXEL OF oPanelPrinc SIZE 015,015 MESSAGE ""
		oCheckBox:bChange := {|| MarcaTodos(oList) }

		//PreencheDados()
		ValRegVazio()

		oList:SetArray(aTabelas)
		oList:bLine := {|| rbLine(oList:nAt,Len(aColunas)) }
		oList:bChange := {|| AlteraMemo(oList:nAt)}
		oList:bLDblClick := {|| TrocaCheck(oList:nAt)}

		@ ((((nHeight/2)-5) * 0.6)-8), 05 SAY oAcao VAR STR0019 + ":" OF oPanelPrinc PIXEL //"Detalhes da Transação"
		oMemo := tMultiget():new( (((nHeight/2)-5) * 0.6), 05, {|u| If( PCount() == 0, cMemo, cMemo := u )}, oPanelPrinc, (nLargura/2)-110, (((nHeight/2)-5) * 0.4)-20, , , , , , .T., /*13*/,/*14*/,{||.T.},/*16*/,/*17*/,.T. )

		//-----------------------
		//Painel Inferior
		//-----------------------
		oPanelInf := TPanel():New( (nHeight/2) - 20, 01, ,oDlgUpd, , , , , , (nLargura/2), 19, .T.,.T. )

		@ 05,(nLargura/2)-325 BUTTON oBtnAvanca PROMPT STR0038 SIZE 60,12 WHEN (.T.) ACTION (buscaDados(),FiltraInfo())   OF oPanelInf PIXEL //"Atualizar"
		@ 05,(nLargura/2)-260 BUTTON oBtnAvanca PROMPT STR0020 SIZE 60,12 WHEN (.T.) ACTION (ExcluiSOG())   OF oPanelInf PIXEL //"Excluir"
		@ 05,(nLargura/2)-195 BUTTON oBtnAvanca PROMPT STR0021 SIZE 60,12 WHEN (.T.) ACTION (SalvarXML())   OF oPanelInf PIXEL //"Salvar XML"
		@ 05,(nLargura/2)-130 BUTTON oBtnAvanca PROMPT STR0060 SIZE 60,12 WHEN (.T.) ACTION (exibeSOH())    OF oPanelInf PIXEL //"Em processamento"
		@ 05,(nLargura/2)-65  BUTTON oBtnAvanca PROMPT STR0022 SIZE 60,12 WHEN (.T.) ACTION (oDlgUpd:End()) OF oPanelInf PIXEL //"Sair"

		ACTIVATE MSDIALOG oDlgUpd CENTERED ON INIT (/*buscaDados(),*/ oList:Refresh(),AlteraMemo(oList:nAt))
	ENDIF

Return Nil

Static Function buscaDados()
	Local oDlgMet

	Private nMeter := 0
	Private oMeter, oSayMtr

	DEFINE MSDIALOG oDlgMet FROM 0,0 TO 5,60 TITLE STR0054 //"Executando consulta"

	oSayMtr := tSay():New(10,10,{||STR0055 /*"Processando, aguarde..."*/},oDlgMet,,,,,,.T.,,,220,20) //"Processando, aguarde..."
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
		oSayMtr:SetText(STR0056 + cValToChar(nMeter) + STR0057 + cValToChar(oMeter:nTotal) + STR0058) //"Consultando... 1 de 100 registros "
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
	Local nI
	Local cAliasTop := "SOGORDER"
	Local cAliasCnt := "SOGCNT"
	Local cQuery    := ""
	Local cQueryCnt := ""
	Local nTotal    := 0
	Local cFilName  := AllTrim(FWFilialName(cEmpAnt,cFilAnt))
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
				If AllTrim(aChecks[nI]:cId) == "MATI240"
					cFiltro := " ((SOG.OG_TRANSAC IN ('MATI240','MATI250')  "
				Else
					cFiltro := " ((SOG.OG_TRANSAC = '"+aChecks[nI]:cId+"' "
				EndIf
				If !Empty(aFiltEsp[nI]:dDtAte) 
					cFiltro += " AND SOG.OG_DATA <= '" + DtoS(aFiltEsp[nI]:dDtAte) + "' "
				EndIf
				If !Empty(aFiltEsp[nI]:dDtDe)
					cFiltro += " AND SOG.OG_DATA >= '" + DtoS(aFiltEsp[nI]:dDtDe) + "' "
				EndIf
				If !Empty(aFiltEsp[nI]:cOrdem)
					cFiltro += " AND SOG.OG_OP = '" + aFiltEsp[nI]:cOrdem + "' " 
				EndIf
				If aFiltEsp[nI]:lOk .Or. aFiltEsp[nI]:lError
				   cFiltro += " AND SOG.OG_STATUS IN ("
				   If aFiltEsp[nI]:lOk
				      cFiltro += "'1'"
				      lAddVirgu := .T.
				   EndIf
				   If aFiltEsp[nI]:lError
				      cFiltro += Iif(lAddVirgu,","," ") + "'2'"
				      lAddVirgu := .T.
				   EndIf
				   cFiltro += ")"
				Else
				   cFiltro += " AND SOG.OG_STATUS = ' ' "
				EndIf
				cFiltro += ")"  
			Else
				cTranIn += ", '" + aChecks[nI]:cId + "' "
				If AllTrim(aChecks[nI]:cId) == "MATI240"
					cFiltro += " OR (SOG.OG_TRANSAC IN ('MATI240','MATI250')  "
				Else
					cFiltro += " OR (SOG.OG_TRANSAC = '"+aChecks[nI]:cId+"' "
				EndIf
				If !Empty(aFiltEsp[nI]:dDtAte) 
					cFiltro += " AND SOG.OG_DATA <= '" + DtoS(aFiltEsp[nI]:dDtAte) + "' "
				EndIf
				If !Empty(aFiltEsp[nI]:dDtDe)
					cFiltro += " AND SOG.OG_DATA >= '" + DtoS(aFiltEsp[nI]:dDtDe) + "' "
				EndIf
				If !Empty(aFiltEsp[nI]:cOrdem)
					cFiltro += " AND SOG.OG_OP = '" + aFiltEsp[nI]:cOrdem + "' " 
				EndIf
				If aFiltEsp[nI]:lOk .Or. aFiltEsp[nI]:lError
				   cFiltro += " AND SOG.OG_STATUS IN ("
				   If aFiltEsp[nI]:lOk
				      cFiltro += "'1'"
				      lAddVirgu := .T.
				   EndIf
				   If aFiltEsp[nI]:lError
				      cFiltro += Iif(lAddVirgu,","," ") + "'2'"
				      lAddVirgu := .T.
				   EndIf
				   cFiltro += ")"
				Else
				   cFiltro += " AND SOG.OG_STATUS = ' ' "
				EndIf
				cFiltro += ")"
			EndIf
		EndIf
	Next nI
	
	If !Empty(cFiltro)
		cFiltro := " AND " + cFiltro + ")"
	EndIf

	cQuery := " SELECT SOG.R_E_C_N_O_ OGREC "
	cQuery +=   " FROM " + RetSqlName("SOG") + " SOG "
	cQuery +=  " WHERE SOG.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SOG.OG_FILIAL  = '" + xFilial("SOG") + "' "
	If Empty(cTranIn)
		cQuery += " AND SOG.OG_TRANSAC IN ('')"
	EndIf
	cQuery += cFiltro
	
	cQueryCnt := "SELECT COUNT(*) TOTAL FROM (" + ChangeQuery(cQuery) + ") t "
	
	cQuery += " ORDER BY SOG.OG_FILIAL  ASC, "
	cQuery +=          " SOG.OG_TRANSAC ASC, "
	cQuery +=          " SOG.OG_DATA    DESC, "
	cQuery +=          " SOG.OG_HORA    DESC  "

	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCnt),cAliasCnt,.T.,.T.)
	nTotal := (cAliasCnt)->(TOTAL)
	(cAliasCnt)->(dbCloseArea())

	ProcTot(nTotal)

/*
	BeginSql Alias cAliasTop

		SELECT R_E_C_N_O_ FROM %table:SOG% SOG
		WHERE SOG.%NotDel%
		ORDER BY SOG.OG_FILIAL ASC,
		SOG.OG_TRANSAC ASC,
		SOG.OG_DATA DESC,
		SOG.OG_HORA DESC

	EndSql
*/
	dbSelectArea("SOG")
	SOG->(dbGoTop())
	While !(cAliasTop)->(Eof())
		ProcInc()
		SOG->(dbGoTo((cAliasTop)->OGREC))
		
		cTransac := Iif(AllTrim(SOG->OG_TRANSAC)$"MATI240|MATI250","MATI240",AllTrim(SOG->OG_TRANSAC))
		
		For nI := 1 To Len(aTabsFil)
			If AllTrim(cTransac) == AllTrim(aTabsFil[nI][1])

				aAdd(aTabelas,{})

				aAdd(aTabelas[Len(aTabelas)], LoadBitmap( GetResources(), "LBOK" ) )

				If lFilial
					aAdd(aTabelas[Len(aTabelas)],AllTrim(SOG->OG_FILIAL) + " - " + AllTrim(cFilName) )
				EndIf

				aAdd(aTabelas[Len(aTabelas)],aTabsFil[nI][2] + Space(10) )

				Do Case
		           Case SOG->OG_STATUS == "1"
		           	aAdd(aTabelas[Len(aTabelas)],STR0023)//"Integrado com sucesso"
		           Case SOG->OG_STATUS == "2"
		           	aAdd(aTabelas[Len(aTabelas)],STR0024)//"Ocorreram erros"
		           Otherwise
		           	aAdd(aTabelas[Len(aTabelas)],"")
				End

				aAdd(aTabelas[Len(aTabelas)],AllTrim(SOG->OG_OP))
				aAdd(aTabelas[Len(aTabelas)],AllTrim(SOG->OG_OPERAC))
				If SOG->OG_ESTORNO == "1"
              aAdd(aTabelas[Len(aTabelas)],STR0041) //"Sim"
				Else
              aAdd(aTabelas[Len(aTabelas)],STR0042) //"Não"
				EndIf

				aAdd(aTabelas[Len(aTabelas)],AllTrim(SOG->OG_RECURSO))
				aAdd(aTabelas[Len(aTabelas)],AllTrim(SOG->OG_PRODUTO))
				aAdd(aTabelas[Len(aTabelas)],SOG->OG_QUANTID)
				aAdd(aTabelas[Len(aTabelas)],SOG->OG_DTAPONT)
				aAdd(aTabelas[Len(aTabelas)],AllTrim(SOG->OG_HRAPONT))
				aAdd(aTabelas[Len(aTabelas)],SOG->OG_DTFIMAP)
				aAdd(aTabelas[Len(aTabelas)],AllTrim(SOG->OG_HRFIMAP))
				aAdd(aTabelas[Len(aTabelas)],SOG->OG_DATA)
				aAdd(aTabelas[Len(aTabelas)],SOG->OG_HORA)
				
				aAdd(aTabelas[Len(aTabelas)],SOG->OG_MOTIVO)
				If cTransac=="MATI240"
					If AllTrim(SOG->OG_TPMV) == "E"
						aAdd(aTabelas[Len(aTabelas)],"Entrada")
					ElseIf AllTrim(SOG->OG_TPMV) == "S"
						aAdd(aTabelas[Len(aTabelas)],"Saída")
					Else
						aAdd(aTabelas[Len(aTabelas)],SOG->OG_TPMV)
					EndIf
				Else
					aAdd(aTabelas[Len(aTabelas)],SOG->OG_TPMV)
				EndIf
				aAdd(aTabelas[Len(aTabelas)],SOG->OG_PROORG)
				aAdd(aTabelas[Len(aTabelas)],SOG->OG_LOCORG)
				aAdd(aTabelas[Len(aTabelas)],SOG->OG_PRODST)
				aAdd(aTabelas[Len(aTabelas)],SOG->OG_LOCDST)				
				aAdd(aTabelas[Len(aTabelas)],SOG->OG_IDMES)
				
				//Colunas que não aparecerão no Grid (Caso adicione alguma informação, ponha sempre no final e acesse utilizando Len(aColunas)+x e adicionar na função ValRegVazio() )
				aAdd(aTabelas[Len(aTabelas)],AllTrim(SOG->OG_MSGRET))	//Len(aColunas)+1
				aAdd(aTabelas[Len(aTabelas)],AllTrim(SOG->OG_STATUS))	//Len(aColunas)+2
				aAdd(aTabelas[Len(aTabelas)],AllTrim(cTransac))	//Len(aColunas)+3
				aAdd(aTabelas[Len(aTabelas)],AllTrim(SOG->OG_FILIAL))	//Len(aColunas)+4
				aAdd(aTabelas[Len(aTabelas)],.T.)							//Len(aColunas)+5 //Refere ao checkbox de marcação da linha
				aAdd(aTabelas[Len(aTabelas)],SOG->(RecNo()))				//Len(aColunas)+6 //Chave na banco de dados
				aAdd(aTabelas[Len(aTabelas)],"")							//Len(aColunas)+7
				aAdd(aTabelas[Len(aTabelas)],SOG->OG_DATA)				//Len(aColunas)+8
				aAdd(aTabelas[Len(aTabelas)],SOG->OG_HORA)				//Len(aColunas)+9
				aAdd(aTabelas[Len(aTabelas)],AllTrim(SOG->OG_OP) + AllTrim(SOG->OG_RECURSO) + AllTrim(SOG->OG_PRODUTO) )	//Len(aColunas)+10

				Exit

			EndIf
		Next

		(cAliasTop)->(dbSkip())
	End

	aAllReg := aClone(aTabelas)

	(cAliasTop)->(dbCloseArea())
	ValRegVazio()
Return Nil
//---------------------------------------------------------
Static Function FiltraInfo()
	Local nI, nJ
	Local aFiltros := {}
	Local aFilEsp  := {}
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

				If !((aFilEsp[nJ]:lOk .And. aAllReg[nI][Len(aColunas)+2] == "1") .Or. (aFilEsp[nJ]:lError .And. aAllReg[nI][Len(aColunas)+2] == "2"))
					Exit
				EndIf

				IF ( Empty(aFilEsp[nJ]:dDtDe) .Or. aFilEsp[nJ]:dDtDe <= aAllReg[nI][Len(aColunas)+8]) .And.;
				   ( Empty(aFilEsp[nJ]:dDtAte) .Or. aFilEsp[nJ]:dDtAte >= aAllReg[nI][Len(aColunas)+8]) .And. ;
				   ( Empty(aFilEsp[nJ]:cOrdem) .Or. AllTrim(aFilEsp[nJ]:cOrdem) == AllTrim(aAllReg[nI][Iif(lFilial,5,4)]))
					aAdd(aTabelas,aClone(aAllReg[nI]))
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
Static Function ExcluiSOG()
	Local nI
	Local nQtdReg := 0
	Default lAutoMacao := .F.

	If ValType(aTabelas[1][Len(aColunas)+5]) != "L"
		Alert(STR0025)//"Nenhum registro selecionado para excluir."
		Return Nil
	EndIf

	For nI := 1 To Len(aTabelas)
		If aTabelas[nI][Len(aColunas)+5]
			nQtdReg := nQtdReg + 1
		EndIf
	Next

	If nQtdReg > 1
		If MsgYesNo(STR0026 + " " + AllTrim(Str(nQtdReg)) + " " + STR0027, STR0028)//"Deseja excluir os " + x + "registros selecionados?" - "Aviso"
			ExcluiRegs()
		EndIf
	ElseIf nQtdReg == 1
		IF !lAutoMacao
			If MsgYesNo(STR0029, STR0030)//"Deseja excluir o registro selecionado?" - "Aviso"
				ExcluiRegs()
			EndIf
		ENDIF
	Else
		Alert(STR0025)//"Nenhum registro selecionado para excluir."
	EndIf

Return Nil
//---------------------------------------------------------
Static Function SalvarXML()
	Local nI
	Local nQtdReg := 0
	Local cTemp

	If ValType(aTabelas[1][Len(aColunas)+5]) != "L"
		Alert(STR0032)//"Nenhum registro selecionado para gerar xml."
		Return Nil
	EndIf

	For nI := 1 To Len(aTabelas)
		If aTabelas[nI][Len(aColunas)+5]
			nQtdReg := nQtdReg + 1
		EndIf
	Next

	If nQtdReg == 0
		Alert(STR0032)//"Nenhum registro selecionado para gerar xml."
		Return Nil
	EndIf

	cTemp := SelectFile("diretorio.xml")

	If !(Empty(cTemp))
		GravaXMLs(cTemp)
		MsgInfo(STR0068 + cTemp) //"Arquivos gerados com sucesso na pasta "
	Else
		Alert(STR0069) //"Diretório não foi selecionado."
	EndIf

Return Nil
//-------------------------------------------------------------------
Static Function GravaXMLs(cCaminho)
	Local nI
	Local nHandle

	dbSelectArea("SOG")

	For nI := 1 To Len(aTabelas)
		If aTabelas[nI][Len(aColunas)+5]
			SOG->(dbGoTo(aTabelas[nI][Len(aColunas)+6]))
			If !Empty(aTabelas[nI][Len(aColunas)+7])
				nHandle := fCreate(cCaminho + aTabelas[nI][Len(aColunas)+7])
			Else
				nHandle := fCreate(cCaminho + AllTrim(SOG->OG_TRANSAC) + "_" + AllTrim(SOG->OG_OP) + AllTrim(SOG->OG_RECURSO) + AllTrim(SOG->OG_PRODUTO) + "_" + DToS(SOG->OG_DATA) + StrTran(AllTrim(SOG->OG_HORA),":","") + "_" + cValToChar(SOG->(Recno())) + ".xml" )
			EndIf

			If nHandle = -1
		        //conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
			Else
		        fWrite(nHandle, SOG->OG_XML)
		        fClose(nHandle)
			EndIf
		EndIf
	Next

Return Nil
//-------------------------------------------------------------------
Static Function SelectFile(cFormatFile)
Default lAutoMacao := .F.

	IF !lAutoMacao
		cFile := cGetFile("|" + cFormatFile + "|",STR0033,0,,.F.,,.T.,.T.)//"Selecione uma pasta para gravar o arquivo"
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
	Local nTamId := TamSX3("OH_IDMES")[1]
	Local cQuery := ""
	Local cAliasCnt := "SOGCNT"
	Default lAutoMacao := .F.
	
	dbSelectArea("SOG")
	SOG->(dbSetOrder(1))

	While nI <= Len(aTabelas)
		If aTabelas[nI][Len(aColunas)+5]
			SOG->(dbGoTo(aTabelas[nI][Len(aColunas)+6]))
			
			If !Empty(SOG->OG_IDMES)
				cQuery := " SELECT COUNT(*) TOTAL " +;
				            " FROM " + RetSqlName("SOG") + " SOG " +;
				           " WHERE SOG.OG_FILIAL  = '" + xFilial("SOG") + "' " +;
				             " AND SOG.D_E_L_E_T_ = ' ' " +;
				             " AND SOG.OG_IDMES   = '" + AllTrim(SOG->OG_IDMES) + "' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCnt,.T.,.T.)
				If (cAliasCnt)->(TOTAL) <= 1 
					If SOH->(dbSeek(xFilial("SOH")+PadR(cValToChar(SOG->OG_IDMES),nTamId)))
						RecLock("SOH",.F.)
						SOH->(dbDelete())
						SOH->(MsUnLock())
					EndIf
				EndIf
				(cAliasCnt)->(dbCloseArea())
			EndIf
			
			IF !lAutoMacao
				RecLock("SOG", .F.)
				SOG->(dbDelete())
				SOG->(MsUnLock())
			ENDIF

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
// Classe construtura dos filtros especificos dinamicos
Class PCPA112F
	//Método construtor da classe
	Method New(oDlg,cId,cDesc,nPosAlt,nPosLar,bOk) Constructor

	//Propriedades
	Data cId
	Data cDesc
	Data bOk
	Data oDlgFil
	Data dDtDe
	Data dDtAte
	Data cOrdem
	Data lOk
	Data lError
	Data oCheckBox1
	Data oCheckBox2
	Data oCheckBox3

	//Métodos
	Method Dialog()
EndClass
//---------------------------------------------------------
Method New(oDlg,cId,cDesc,nPosAlt,nPosLar,bOk) Class PCPA112F
	Local oBtn
	Default lAutoMacao := .F.

	Self:cId := cId
	Self:cDesc := cDesc
	Self:bOk := bOk
	Self:dDtDe := SToD("20000101")
	Self:dDtAte := SToD("29990101")
	Self:cOrdem := Space(TamSX3("H6_OP")[1])
	Self:lOk := .T.
	Self:lError := .T.

	IF !lAutoMacao
		@ nPosAlt-2,nPosLar BUTTON oBtn PROMPT "..."  SIZE 12,10 WHEN (.T.) ACTION (Self:Dialog()) OF oDlg PIXEL
	ENDIF

Return Self
//---------------------------------------------------------
Method Dialog() Class PCPA112F

	DEFINE DIALOG Self:oDlgFil TITLE Self:cDesc FROM 0,0 TO 220,500 PIXEL

	//Faixa data +3
	@ 10, 09 SAY oAcao VAR STR0017 + ":" OF Self:oDlgFil PIXEL //"Data Processamento:"

	@ 22, 09 SAY oAcao VAR STR0031 + ":" OF Self:oDlgFil PIXEL //"De:"
	TGet():New(018,025,{|u| If(PCount()==0,Self:dDtDe,Self:dDtDe:=u)}  ,Self:oDlgFil,060,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"Self:dDtDe",,,,.T.  )

	@ 22, 85 SAY oAcao VAR STR0034 + ":" OF Self:oDlgFil PIXEL //"Até:"
	TGet():New(018,100,{|u| If(PCount()==0,Self:dDtAte,Self:dDtAte:=u)},Self:oDlgFil,060,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"Self:dDtAte",,,,.T.  )

	//Checkbox Status +3
	@ 35, 09 SAY oAcao VAR STR0008 + ":" OF Self:oDlgFil PIXEL //"Status:"

	@ 43, 09 CHECKBOX Self:oCheckBox1 VAR Self:lOk PROMPT STR0023 /*"Integrado com sucesso"*/ WHEN PIXEL OF Self:oDlgFil SIZE 070,015 MESSAGE ""
	//@ 43, 009 + 8 SAY oAcao VAR STR0023 OF Self:oDlgFil PIXEL //"Integrado com sucesso"

	@ 43, 90 CHECKBOX Self:oCheckBox2 VAR Self:lError PROMPT STR0024 /*"Ocorreram erros"*/ WHEN PIXEL OF Self:oDlgFil SIZE 070,015 MESSAGE ""
	//@ 43, 090 + 8 SAY oAcao VAR STR0024 OF Self:oDlgFil PIXEL //"Ocorreram erros"

	If Self:cId $ "MATI681|MATI685"
		@ 58, 09 SAY oAcao VAR STR0071 OF Self:oDlgFil PIXEL // "Ordem de produção:"
		@ 66, 09 MSGET Self:cOrdem SIZE 120,010 OF Self:oDlgFil F3 "SC2" PIXEL VALID (vldOrdem(Self:cOrdem))
	EndIf

	//Botão Confirmar
	@ 83, 30 BUTTON oBtn PROMPT STR0035 SIZE 60,12 WHEN (.T.) ACTION {||Replicar(Self),Eval(Self:bOk),Self:oDlgFil:End()} OF Self:oDlgFil PIXEL //"Replicar"
	//Botão Confirmar
	@ 83, 95 BUTTON oBtn PROMPT STR0036 SIZE 60,12 WHEN (.T.) ACTION {||Eval(Self:bOk),Self:oDlgFil:End()} OF Self:oDlgFil PIXEL //"Confirmar"
	//Botão Cancelar
	@ 83, 160 BUTTON oBtn PROMPT STR0037 SIZE 60,12 WHEN (.T.) ACTION {||Self:oDlgFil:End()} OF Self:oDlgFil PIXEL //"Cancelar"

	ACTIVATE MSDIALOG Self:oDlgFil CENTERED

Return Nil

Static Function Replicar(Obj)
	Local nI

	For nI := 1 To Len(aFiltEsp)

		aFiltEsp[nI]:dDtDe  := Obj:dDtDe
		aFiltEsp[nI]:dDtAte := Obj:dDtAte
		aFiltEsp[nI]:lOk    := Obj:lOk
		aFiltEsp[nI]:lError := Obj:lError
		
		If aFiltEsp[nI]:cId $ "MATI681|MATI685" .And. Obj:cId $ "MATI681|MATI685"
			aFiltEsp[nI]:cOrdem := Obj:cOrdem
		EndIf

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

/*
	Busca os registros da tabela SOH, que estão com status Em processamento (OH_STATUS = 0)
*/
Static Function exibeSOH()
	Local oDlgProc, oBtn
	Local aColumns := {} 
	Local aTamanho := {}
	
	Private aSOH			:= {{LoadBitmap( GetResources(), "LBNO" ),'','','','',.F.}}
	Private lCheckAll	:= .F.
	Private oListSOH, oCheckAll
	
	aColumns := {" ","ID",STR0007,STR0061,STR0062} // Transação/Data início/Tempo
	aTamanho := {20 ,140 ,100        , 65          , 50 }
	
	DEFINE DIALOG oDlgProc TITLE STR0063 FROM 0,0 TO 497,800 PIXEL //"Mensagens em processamento"

	oListSOH := TWBrowse():New( 05, 05, 393,220,,aColumns,aTamanho,oDlgProc,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

	@ 06, 06 CHECKBOX oCheckAll VAR lCheckAll PROMPT "" WHEN PIXEL OF oDlgProc SIZE 015,015 MESSAGE ""
	oCheckAll:bChange := {|| marcaSOH(oListSOH) }

	oListSOH:SetArray(aSOH)
	oListSOH:bLine := {|| {aSOH[oListSOH:nAT,1],;
                          aSOH[oListSOH:nAT,2],;
                          aSOH[oListSOH:nAT,3],;
                          aSOH[oListSOH:nAT,4],;
                          aSOH[oListSOH:nAT,5]} }
	oListSOH:bLDblClick := {|| SOHClick(oListSOH:nAt)}
	
	//Botão Atualizar
	@ 230, 208 BUTTON oBtn PROMPT STR0038 SIZE 60,12 WHEN (.T.) ACTION {|| cargaSOH()} OF oDlgProc PIXEL //"Atualizar"
	//Botão Excluir
	@ 230, 273 BUTTON oBtn PROMPT STR0064 SIZE 60,12 WHEN (.T.) ACTION {|| excluiSOH()} OF oDlgProc PIXEL //"Excluir"
	//Botão Cancelar
	@ 230, 338 BUTTON oBtn PROMPT STR0022 SIZE 60,12 WHEN (.T.) ACTION {||oDlgProc:End()} OF oDlgProc PIXEL //"Cancelar"

	ACTIVATE MSDIALOG oDlgProc CENTERED on init cargaSOH()
	
Return 

Static Function cargaSOH()
	Local cQuery    := ""
	Local cAliasSOH := GetNextAlias()
	Local cTrans    := ""
	Default lAutoMacao := .F.

	aSOH := {}
	
	cQuery := " SELECT SOH.R_E_C_N_O_ RECSOH "
	cQuery +=   " FROM " + RetSqlName("SOH") + " SOH "
	cQuery +=  " WHERE SOH.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SOH.OH_STATUS  = '0' "
	cQuery +=    " AND SOH.OH_FILIAL  = '" + xFilial("SOH") + "' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSOH,.T.,.T.)
	
	While (cAliasSOH)->(!Eof())
		SOH->(dbGoTo((cAliasSOH)->(RECSOH)))
		If AllTrim(SOH->OH_TRANSAC) == "PRODUCTIONAPPOINTMENT"
			cTrans := STR0002 //"Apontamento de Produção"
		ElseIf AllTrim(SOH->OH_TRANSAC) == "TRANSFERWAREHOUSE"
			cTrans := STR0046 //"Transferências"
		ElseIf AllTrim(SOH->OH_TRANSAC) == "REFUSAL"
			cTrans := STR0059 //"Apontamento de Perda"
		ElseIf AllTrim(SOH->OH_TRANSAC) == "MOVEMENTSINTERNAL"
			cTrans := STR0045 //"Movimentações Avulsas"
		ElseIf AllTrim(SOH->OH_TRANSAC) == "STOPREPORT"
			cTrans := STR0003 //"Apontamento de Parada"
		ElseIf AllTrim(SOH->OH_TRANSAC) == "WASTEREASON"
			cTrans := STR0043 //"Motivo de Refugo"
		ElseIf AllTrim(SOH->OH_TRANSAC) == "STOPREASON"
			cTrans := STR0044 //"Motivo de Parada"
		Else
			cTrans := AllTrim(SOH->OH_TRANSAC)
		EndIf
		
		aAdd(aSOH,{LoadBitmap( GetResources(), "LBNO" ),;
			        AllTrim(SOH->OH_IDMES),;
			        cTrans,;
			        DtoC(SOH->OH_DATA) + " - " + SOH->OH_HORA,;
			        difHora(SOH->OH_DATA,SOH->OH_HORA),;
			        .F.})
		
		(cAliasSOH)->(dbSkip())
	End
	(cAliasSOH)->(dbCloseArea())
	
	If Len(aSOH) < 1
		aSOH := {{LoadBitmap( GetResources(), "LBNO" ),'','','','',.F.}}
	Else
		aSort(aSOH,,, {|x,y| y[2] > x[2]})
	EndIf
	
	IF !lAutoMacao
		oListSOH:SetArray(aSOH)
		oListSOH:bLine := {|| {aSOH[oListSOH:nAT,1],;
							aSOH[oListSOH:nAT,2],;
							aSOH[oListSOH:nAT,3],;
							aSOH[oListSOH:nAT,4],;
							aSOH[oListSOH:nAT,5]} }
		oListSOH:Refresh()
	ENDIF
Return .T.

Static Function marcaSOH(oBrw)
	Local nI := 0
	Default lAutoMacao := .F.
	
	If lCheckAll
		For nI := 1 To Len(aSOH)
			aSOH[nI][1] := LoadBitmap( GetResources(), "LBOK" )
			aSOH[nI][6] := .T.
		Next
	Else
		For nI := 1 To Len(aSOH)
			aSOH[nI][1] := LoadBitmap( GetResources(), "LBNO" )
			aSOH[nI][6] := .T.
		Next
	EndIf

	IF !lAutoMacao
		oBrw:Refresh()
	ENDIF
Return .T.

Static Function SOHClick(nLinha)
	aSOH[nLinha][6] := !aSOH[nLinha][6]
	
	If aSOH[nLinha][6]
		aSOH[nLinha][1] := LoadBitmap( GetResources(), "LBOK" )
	Else
		aSOH[nLinha][1] := LoadBitmap( GetResources(), "LBNO" )
	EndIf
Return .T.

Static Function difHora(dData,cHora)
	Local nDifDias  := 0
	Local cDifHora  := " "
	Local nDifHoras := 0
	Local cDif      := " "
	
	If Empty(dData) .Or. Empty(cHora)
		cDif := "00:00:00"
	Else
		nDifDias  := Date() - dData
		cDifHora  := ElapTime(Iif(cHora > Time(),Time(),cHora),Iif(cHora > Time(),cHora,Time()))
		nDifHoras := nDifDias * 24
		cDif      := IncTime(cDifHora,nDifHoras)
	EndIf
Return cDif

Static Function excluiSOH()
	Local nI   := 0
	Local cSql := ""
	If MSGYESNO(STR0065,STR0066) //"Deseja excluir os registros selecionados?" / "Confirmação"
		BeginTran()
		For nI := 1 To Len(aSOH)
			If aSOH[nI,6]
				cSql := " DELETE FROM " + RetSqlName("SOH") + " WHERE OH_IDMES = '" + aSOH[nI,2] + "' "
				If TcSqlExec(cSql) < 0 
					Help( ,, 'Help',, STR0067 + TCSQLError() , 1, 0 )
					DisarmTransaction()
					Exit 
				EndIf
			EndIf
		Next nI
		EndTran()
		cargaSOH()
	EndIf
Return

Static Function vldOrdem(cOrdemProd)
	Local lRet := .T.
	cOrdemProd := PadR(cOrdemProd,TamSX3("C2_NUM")[1]+TamSX3("C2_ITEM")[1]+TamSX3("C2_SEQUEN")[1])
	SC2->(dbSetOrder(1))
	If !Empty(cOrdemProd) .And. !SC2->(dbSeek(xFilial("SC2")+cOrdemProd))
		Help( ,, 'Help',, STR0070 , 1, 0 ) //"Ordem de produção não cadastrada."
		lRet := .F.
	EndIf
Return lRet
