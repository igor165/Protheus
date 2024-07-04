#INCLUDE "JURA216.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

#DEFINE DEFAULTSPACE 10
#DEFINE DS_MODALFRAME 128
#DEFINE JUR_COLOR_BUTTON RGB(0,0,0)

Static __oListInd := nil
Static __aIndVal  := nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA216
Log de Atualiza��o de �ndices

@author Jorge Luis Branco Martins Junior
@since 06/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA216()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) // Log de Atualiza��o de �ndices
oBrowse:SetAlias( "NZW" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NZW" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@Return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transa��o a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Altera��o sem inclus�o de registros
7 - C�pia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Jorge Luis Branco Martins Junior
@since 06/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA216", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA216", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA216", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Log de Importa��o de Publica��es

@author Jorge Luis Branco Martins Junior
@since 06/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA216" )
Local oStruct := FWFormStruct( 2, "NZW" )

JurSetAgrp( 'NZW',, oStruct )

oStruct:RemoveField("NZW_COD")
oStruct:RemoveField("NZW_CINDIC")
oStruct:RemoveField("NZW_CUSER")

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA216_VIEW", oStruct, "NZWMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA216_VIEW", "FORMFIELD" )
oView:SetDescription( STR0001 ) //"Log de Atualiza��o de �ndices"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Natureza Juridica

@author Jorge Luis Branco Martins Junior
@since 06/04/16
@version 1.0

@obs NZWMASTER - Dados do Natureza Juridica

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNZW := FWFormStruct( 1, "NZW" )

//-----------------------------------------
//Monta o modelo do formul�rio
//-----------------------------------------
oModel:= MPFormModel():New( "JURA216", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NZWMASTER", NIL, oStructNZW, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0006 ) //"Modelo de Dados de Log de Atualiza��o de �ndices"
oModel:GetModel( "NZWMASTER" ):SetDescription( STR0007 ) //"Dados de Log de Atualiza��o de �ndices"

JurSetRules( oModel, 'NZWMASTER',, 'NZW' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA216SetLog
Insere o registro de Log da atualiza��o

@author Jorge Luis Branco Martins Junior
@since 06/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA216SetLog(cCodIndice, cTime)
Local aArea    := GetArea()
Local lRet     := .T.
Local oModel

If FWAliasInDic("NZW") //Verifica se existe a tabela NZW - Log Importa��o Publica��es (Prote��o)

	oModel := FWLoadModel("JURA216")
	oModel:SetOperation( 3 )
	oModel:Activate()
	
	IIF( lRet, lRet := oModel:SetValue("NZWMASTER","NZW_CINDIC" , cCodIndice ), )
	IIF( lRet, lRet := oModel:SetValue("NZWMASTER","NZW_DATA"   , Date()     ), )
	IIF( lRet, lRet := oModel:SetValue("NZWMASTER","NZW_HORA"   , cTime      ), )
	IIF( lRet, lRet := oModel:SetValue("NZWMASTER","NZW_CUSER"  , __CUSERID  ), )
	
	If !(lRet .And. oModel:VldData() .And. oModel:CommitData())
		If IsBlind()
			ConOut(STR0008)
		Else
			Alert(STR0008) // Houve um erro na gera��o do Log.
		EndIf
	EndIf
	
	oModel:DeActivate()
	oModel:Destroy()
	
	RestArea( aArea )

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA216AtuAut
Atualiza��o autom�tica de �ndices

@param cCodIndice - C�digo do indice, se n�o informado, aplica para todos os �ndices
@param lTodos - Informa se deve conferir de forma individual ou todos
@author Jorge Luis Branco Martins Junior
@since 04/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA216AtuAut(cCodIndice,lTodos)
Local aIndices := JA216Indices()
Local aAreaNW5 := NW5->( GetArea() )
Local nI       := 0
Local lAuto    := JurAuto()

Default cCodIndice := ""
Default lTodos     := .F.

If Len(aIndices) > 0
	If !lAuto
		ProcRegua(0)
	Endif

	If Empty(AllTrim(cCodIndice))
		
		If !lTodos .and. (lAuto .or. ApMsgYesNo(STR0009)) //Deseja conferir cada �ndice antes da atualiza��o?
	
			For nI := 1 to Len(aIndices)
	
				cCodIndice := AllTrim(aIndices[nI][1])
				cDesIndice := AllTrim(aIndices[nI][2])
		
				If NW5->(dbSeek(xFilial("NW5") + cCodIndice))

					aValueIndex := JA216ValInd(cCodIndice,cDesIndice)
		
					If Len(aValueIndex) > 0
						JA216Grid(AllTrim(cCodIndice), aIndices, aValueIndex)	//Imprime todos os �ndices na tela (indice a indice).
					EndIf
		
				EndIf
	
			Next
			
			JA216Novos(aIndices)
	
		Else
			aValueIndex := JA216ValAll(aIndices)
			If Len(aValueIndex) > 0
				JA216Grid("", aIndices, aValueIndex)	//Imprime um resumo de todos os �ndices juntos.
			EndIf
		EndIf
	Else
		aValueIndex := JA216ValInd(cCodIndice,,aIndices)
		If Len(aValueIndex) > 0
			JA216Grid(AllTrim(cCodIndice), aIndices, aValueIndex)
		Else
			MsgAlert(STR0028 + JurGetDados("NW5", 1, xFilial("NW5") + cCodIndice, "NW5_DESC")) //"N�o existem valores para o �ndice "
		EndIf
	EndIf

EndIf

RestArea(aAreaNW5)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA216Grid
Exibe grid com valores para confer�ncia
@param cCodIndice - C�digo do �ndice
@param aIndices - Lista dos �ndices 
@param aValueIndex - valores do �ndice
@author Jorge Luis Branco Martins Junior
@since 04/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA216Grid(cCodIndice, aIndices, aValueIndex)

Local aHeader 	:= {}
Local aCols   	:= {}
Local oGet	  	:= Nil 
Local lAtualiou	:= .F.
Local lJurAuto  := JurAuto()

Default cCodIndice := ""

	If !lJurAuto
		If Type("oMainWnd") == "U"
			RPCSetType(3)
			RPCSetEnv("99","01")
			aSize := {0, 0, 650, 1000}
		Else
			aSize := FWGetDialogSize( oMainWnd ) 
		EndIf

		Aadd(aHeader,{STR0010, STR0010, "",30,0,"","","C","","" }) // "�ndice"
		Aadd(aHeader,{STR0011, STR0011, "",15,0,"","","D","","" }) // "Data"
		Aadd(aHeader,{STR0012, STR0012, "",30,0,"","","C","","" }) // "Valor"
		Aadd(aHeader,{STR0032, STR0032, "",30,0,"","","C","","" }) // "Valor Absoluto"

		oDlg := MSDIALOG():Create()
		oDlg:cName     := "oDlg"
		oDlg:cCaption  := STR0013 //"Atualiza��o de �ndices"
		oDlg:nTop      := aSize[1]
		oDlg:nLeft     := aSize[2]
		oDlg:nHeight   := aSize[3]
		oDlg:nWidth    := aSize[4]
		oDlg:lCentered := .T.

		oPanelSearch := TPanel():Create(oDlg,02,,,,,,,/*CLR_RED*/,,35)
		oPanelSearch:Align := CONTROL_ALIGN_TOP

		oPanelGrid := TPanel():Create(oDlg,02,,,,,,,/*CLR_BLUE*/)
		oPanelGrid:Align := CONTROL_ALIGN_ALLCLIENT

		oGet := MsNewGetDados():New(0,0,0,0,,,,,,,9999,,,,oPanelGrid,aHeader,aCols)
		oGet:oBrowse:Align  	:= CONTROL_ALIGN_ALLCLIENT
		oGet:oBrowse:blDblClick := {|| .T.}		//Desabilita a edi��o de celula	

		oGet:aCols  := aValueIndex
		oGet:nAt    := Len(aValueIndex)
		oGet:Refresh()
		oGet:oBrowse:SetFocus() 
		oGet:Goto(1)	
		oGet:oBrowse:oMother:oBrowse:Enable()

		oBtnUpdate := TButton():Create(oPanelSearch)
		oBtnUpdate:cName    := "oBtnUpdate"
		oBtnUpdate:cCaption := STR0014 //"Atualizar SIGAJURI"

		//Atualiza todos os indices
		If Empty(cCodIndice) 
			oBtnUpdate:blClicked := {|| JA216AtuAll(aIndices)						  , lAtualiou:=.T., oDlg:End() }
		//Atualiza indice posicionado
		Else
			oBtnUpdate:blClicked := {|| JA216AtuInd(cCodIndice, aValueIndex, aIndices), lAtualiou:=.T., oDlg:End() }
		EndIf
		oBtnUpdate:nTop 	:= 10
		oBtnUpdate:nLeft 	:= 05
		oBtnUpdate:nWidth 	:= 250
		oBtnUpdate:nHeight	:= 30

		oBtnClose := TButton():Create(oPanelSearch)
		oBtnClose:cName := "oBtnClose"
		oBtnClose:cCaption := STR0015 //"Sair"
		oBtnClose:blClicked := {|| oDlg:End() }
		oBtnClose:nTop := 10
		oBtnClose:nLeft := aSize[4] - 110
		oBtnClose:nWidth := 90
		oBtnClose:nHeight := 30

		Activate MsDialog oDlg Centered
	Else 
		lAtualiou:=.T.
		If Empty(cCodIndice)
			JA216AtuAll(aIndices)
		Else
			JA216AtuInd(cCodIndice, aValueIndex, aIndices)
		EndIf
	Endif

	//Busca novos indices caso tenha atualizados todos os indices
	If lAtualiou .And. Empty(cCodIndice)
		JA216Novos(aIndices)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA216AtuAll
Realiza a atualiza��o de todos os �ndices

@author Jorge Luis Branco Martins Junior
@since 04/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA216AtuAll(aIndices)
local aArea       := GetArea()
Local aAreaNW5    := NW5->( GetArea() )
Local nI          := 0
Local aValueIndex := {}
Local cCodIndice  := ""
Local cDesIndice  := ""

	// Imprime um resumo de todos os �ndices juntos.
		
	dbSelectArea("NW5")
	NW5->(dbSetOrder(1))
	
	For nI := 1 to Len(aIndices)

		cCodIndice := AllTrim(aIndices[nI][1])
		cDesIndice := AllTrim(aIndices[nI][2])

		If NW5->(dbSeek(xFilial("NW5") + cCodIndice))

			aValueIndex := JA216ValInd(cCodIndice,cDesIndice)
			If Len(aValueIndex) > 0
				MsgRun(STR0021 + NW5->NW5_DESC/*"Atualizando os valores do �ndice : "*/, ;
				       STR0022/*"TOTVS | SIGAJURI"*/, ;
				       {|| JA216NW6(NW5->NW5_COD, aValueIndex) })
			EndIf
		EndIf

	Next
	
	ApMsgInfo(STR0023) // "Atualiza��o finalizada!"

	NW5->(dbcloseArea())
	RestArea(aAreaNW5)
	RestArea(aArea)	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA216AtuInd
Realiza a atualiza��o do �ndice selecionado

@author Jorge Luis Branco Martins Junior
@since 04/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA216AtuInd(cCodIndice, aValueIndex, aIndices)
local aArea := GetArea()
Local aAreaNW5 := NW5->( GetArea() )

	If !Empty(cCodIndice)
		dbSelectArea("NW5")
		NW5->(dbSetOrder(1))

		If NW5->(dbSeek(xFilial("NW5") + AllTrim(cCodIndice)))
			MsgRun(STR0021 + NW5->NW5_DESC/*"Atualizando os valores do �ndice : "*/, ;
			       STR0022/*"TOTVS | SIGAJURI"*/, ;
			       {|| JA216NW6(NW5->NW5_COD, aValueIndex) })
		
			ApMsgInfo(STR0023) // "Atualiza��o finalizada!"
		
		Else
		
			If !(JA216NewInd(cCodIndice, aValueIndex, aIndices))
				Return Nil	
			Else
				ApMsgInfo(STR0030) // "Inclus�o finalizada!"
			EndIf

		EndIf

	EndIf

	NW5->(dbcloseArea())
	RestArea(aAreaNW5)
	RestArea(aArea)	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA216NW6
Faz a inclus�o dos valores na tabela de valores dos �ndices

@param cCodIndice - C�digo do indice que ser� ajustado
@param aValueIndex - Valores do indice 
@since 04/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA216NW6(cCodIndice, aValueIndex)
Local aArea      := GetArea()
Local aAreaNW6   := NW6->( GetArea() )
Local nI         := 0
Local lRetorno   := .T.
Local cSqlUpdate := ""

	while !LockByName("JA216NW6_" + cCodIndice, .T., .F.)
		sleep(15000)
	EndDo

	If Len(aValueIndex) > 0
		DbSelectArea("NW6")

		cSqlUpdate := " UPDATE "+RetSqlName('NW6')
		cSqlUpdate += " SET D_E_L_E_T_ = '*', "
		cSqlUpdate += " R_E_C_D_E_L_ = R_E_C_N_O_"
		cSqlUpdate += " WHERE NW6_FILIAL = '"+xFilial('NW6')+"' " 
		cSqlUpdate += " AND NW6_CINDIC = '" + PADR(cCodIndice,TamSX3('NW6_CINDIC')[1]) + "' "
		cSqlUpdate += " AND  D_E_L_E_T_ = ' ' "

		If (TCSQLExec(cSqlUpdate) < 0) 
			JurLogMsg( TCSQLError() )
			lRetorno := .F.
		EndIf

		If lRetorno

			//Inclui valores
			For nI := 1 to Len(aValueIndex)

				RecLock("NW6", .T.)
					NW6->NW6_CINDIC	:= cCodIndice
					NW6->NW6_COD	:= NextNumero("NW6" ,1 ,"NW6_COD" ,.T.)
					NW6->NW6_VALOR	:= Val( Replace(aValueIndex[nI][4], ',', '.') )
					NW6->NW6_DTINDI	:= aValueIndex[nI][2]
					NW6->NW6_DTLANC	:= dDataBase
					NW6->NW6_PVALOR	:= aValueIndex[nI][3]
				NW6->(MsUnlock())
				ConfirmSX8()

			Next nI

			//Grava log de atualiza��o
			JA216SetLog(cCodIndice, Time())
		EndIf
	EndIf
		
	UnlockByName("JA216NW6_" + cCodIndice, .T., .F. )
		
	RestArea(aAreaNW6)	
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA216ValInd
Retorna um array com valores de um determinado �ndice

@author Jorge Luis Branco Martins Junior
@since 04/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA216ValInd(cCodIndice,cDesIndice,aIndices)
local oValueIndexList
Local aValueIndex     := {}	
local nJ, nI

Default cDesIndice := ""
Default cCodIndice := ""
Default aIndices     := {}


	If Len(aIndices) > 0
		nI := aScan(aIndices, {|x| x[1] == cCodIndice})
		If nI > 0
			cDesIndice := aIndices[nI][2]
		EndIf
	EndIf

	oValueIndexList := JA216ListInd(cCodIndice,cDesIndice)
	For nJ := 1 to Len(oValueIndexList)
		aAux := {}
		Aadd(aAux,AllTrim(oValueIndexList[nJ]:cDescricao))
		Aadd(aAux,STOD(AllTrim(oValueIndexList[nJ]:cData)))
		Aadd(aAux,AllTrim(oValueIndexList[nJ]:cValor))
		Aadd(aAux,AllTrim(oValueIndexList[nJ]:cValorAbsoluto))
		Aadd(aAux,.F.)
		
		Aadd(aValueIndex,aAux)
	Next nJ

Return aValueIndex

//-------------------------------------------------------------------
/*/{Protheus.doc} JA216ValAll
Retorna os valores quando ser�o atualizados todos os �ndices.
Exibe a tela de confer�ncia com os �ltimos 3 valores de cada �ndice e
atualiza todos.

@author Jorge Luis Branco Martins Junior
@since 04/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA216ValAll(aIndices)
Local aAreaNW5     := NW5->( GetArea() )
Local aValueIndex  := {}
Local cCodIndice   := ""
Local cDesIndice   := ""
Local oValueIndexList
Local nI, nJ, nX

	DbSelectArea("NW5")
	NW5->(dbSetOrder(1))

	For nI := 1 to Len(aIndices)
	
		cCodIndice := AllTrim(aIndices[nI][1])
		cDesIndice := AllTrim(aIndices[nI][2])

		If NW5->(dbSeek(xFilial("NW5") + cCodIndice))
			oValueIndexList := JA216ListInd(cCodIndice,cDesIndice)
		
			nX := Len(oValueIndexList)
			If nX > 3
				aAux := {}
				nJ := 2
				While nJ > -1
					aAux := {}
					Aadd(aAux,AllTrim(oValueIndexList[nX-nJ]:cDescricao))
					Aadd(aAux,AllTrim(oValueIndexList[nX-nJ]:cData))
					Aadd(aAux,AllTrim(oValueIndexList[nX-nJ]:cValor))
					Aadd(aAux,AllTrim(oValueIndexList[nX-nJ]:cValorAbsoluto))
					Aadd(aAux,.F.)
					Aadd(aValueIndex,aAux)
					nJ--
				End
				
			EndIf	
		EndIf
	Next

RestArea(aAreaNW5)
	
Return aValueIndex
//-------------------------------------------------------------------
/*/{Protheus.doc} JA216Indices
Indica os nomes de todos os �ndices disponibilizados pelo BPO

@author Jorge Luis Branco Martins Junior
@since 04/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA216Indices()
Local aIndex := {}
Local nI
Local oIndexList := JA216Lista()

	For nI := 1 to Len(oIndexList)

		aADD(aIndex, { AllTrim(oIndexList[nI]:cCODIGO),;
		               AllTrim(oIndexList[nI]:cDESCRICAO) ,;
		               AllTrim(oIndexList[nI]:cATUALIZATAB) ,;
		               AllTrim(oIndexList[nI]:cTIPO) })
	Next 
	
Return aIndex
//-------------------------------------------------------------------
/*/{Protheus.doc} JA216Novos
Busca os �ndices disponibilizados pelo BPO que n�o est�o cadastrados
no sistema e chama a rotina de atualiza��o dos �ndices
@param aIndices - Indices retornados do servi�os
@author Jorge Luis Branco Martins Junior
@since 04/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA216Novos(aIndices)
Local aAreaNW5    := NW5->( GetArea() )
Local nI          := 0
Local nQtdNovos   := 0
Local aNovos      := {}
Local cCodIndice  := ""
Local cDesIndice  := ""
Local aValueIndex := {}
Local cIndsNovos  := ""
Local lJurAuto    := JurAuto()

Default aIndices := JA216Indices()

	If Len(aIndices) > 0

		DbSelectArea("NW5")
		NW5->(dbSetOrder(1))
		
		For nI := 1 to Len(aIndices)
			
			cCodIndice := AllTrim(aIndices[nI][1])
			cDesIndice := AllTrim(aIndices[nI][2])
			
			If !(NW5->(dbSeek(xFilial("NW5") + cCodIndice )))
				cIndsNovos += "	" + cCodIndice + " - " + cDesIndice + CRLF 
				Aadd(aNovos, {cCodIndice, aIndices[nI], cDesIndice} )
			EndIf
		Next nI

		nQtdNovos := Len(aNovos)
		
		If nQtdNovos > 0

			If lJurAuto .or. ApMsgYesNo( I18n(STR0031, {CRLF + cIndsNovos + CRLF}) ) //"Os �ndices abaixo n�o foram cadastrados, deseja cadastra-los ? #1 Observa��o: Esta atualiza��o pode demorar."

				For nI := 1 to nQtdNovos
					aValueIndex := JA216ValInd(aNovos[nI][1],aNovos[nI][3])
					If Len(aValueIndex) > 0
						JA216AtuInd(aNovos[nI][1], aValueIndex, aNovos[nI][2])
					EndIf
				Next
			EndIf
		EndIf

	EndIf
	RestArea(aAreaNW5)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA216NewInd
Faz a inclus�o do novo �ndice
@param cCodIndice - C�digo do �ndice
@param aValueIndex - Valores do �ndice
@param aIndices - Lista de �ndices
@author Jorge Luis Branco Martins Junior
@since 04/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA216NewInd(cCodIndice, aValueIndex, aIndices)
Local aArea      := GetArea()
Local aAreaNW5   := NW5->( GetArea() )
Local oModel     := FWLoadModel('JURA059')
Local oNW5Model  := oModel:GetModel('NW5MASTER')
Local lNovo      := .F.
Local cDesIndice := ""
Local cTipo      := "2"
Local cUpdTable  := "2"
Local nI         := 0

	If Len(aIndices) <> 4
		nI := aScan(aIndices, {|x| x[1] == cCodIndice})
		If nI > 0
			aIndices := aIndices[nI]
		EndIf
	EndIf

	If Len(aIndices) == 4
		cDesIndice := aIndices[2]
		cUpdTable  := aIndices[3]
		cTipo      := aIndices[4]
	EndIf
	
	oModel:SetOperation(3)
	oModel:Activate()

	oNW5Model:SetValue('NW5_COD'   , cCodIndice)
	oNW5Model:SetValue('NW5_DESC'  , cDesIndice)
	oNW5Model:SetValue('NW5_TIPO'  , cTipo)
	oNW5Model:SetValue('NW5_ATUTAB', cUpdTable)

	If oModel:VldData()
		oModel:CommitData()
		
		If __lSX8
			ConfirmSX8()
		EndIf
		
		MsgRun(STR0029 + cDesIndice/*"Incluindo os valores do �ndice : "*/, ;
		       STR0022/*"TOTVS | SIGAJURI"*/, ;
		       {|| JA216NW6(cCodIndice, aValueIndex) })

		lNovo := .T.

	Else

		If __lSX8	
			RollBackSX8()
		EndIf	

		varinfo('GetError', oModel:GetErrorMessage())	
	
		ApMsgInfo(I18N(STR0026, { oModel:GetErrorMessage()[6]})) // "Erro ao incluir o �ndice selecionado! - #1"
		
	EndIf
	
	oModel:DeActivate()	

	RestArea(aAreaNW5)
	RestArea(aArea)

Return lNovo

//-------------------------------------------------------------------
/*/{Protheus.doc} JA216Lista
Lista de �ndices (sem datas e valores) disponibilizados pelo BPO

@author Jorge Luis Branco Martins Junior
@since 08/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static function JA216Lista()
Local cUsuario    := SuperGetMV('MV_JINDUSR',, '')
Local cSenha      := SuperGetMV('MV_JINDPSW',, '') 
Local oWS         := JURA217():New()
Local cSoapFDescr := ''
	
	oWS:cUsuario := cUsuario
	oWS:cSenha := cSenha
	
	oWS:MTIndices()
	If oWS:oWSMTINDICESRESULT:OWSDADOS != Nil
		oLista := oWS:oWSMTINDICESRESULT:OWSDADOS:OWSSTRUDADOSINDICE
	ElseIf __oListInd != Nil
		oLista := __oListInd
	Else
		oLista := {}
		cSoapFDescr := GetWSCError(3) // Soap Fault Description

		If Empty(cSoapFDescr)
			MsgAlert(STR0027) //"N�o existem �ndices a serem atualizados"
		Else
			MsgAlert(cSoapFDescr) 
		EndIf
	EndIf
	
	oWS := Nil

Return oLista

//-------------------------------------------------------------------
/*/{Protheus.doc} JA216ListInd
Retorna um objeto com os �ndices (com datas e valores) disponibilizados 
pelo BPO no webservice
@param cCodIndice - C�digo do �ndice
@param cDesIndice - Descri��o do �ndice
@author Jorge Luis Branco Martins Junior
@since 04/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA216ListInd(cCodIndice,cDesIndice)
Local oWS      := JURA217():New()
Local cUsuario := SuperGetMV('MV_JINDUSR',, '')
Local cSenha   := SuperGetMV('MV_JINDPSW',, '')
Local oLista   := {}
Local nPos     := 0
	
	oWS:cUsuario   := cUsuario
	oWS:cSenha     := cSenha
	oWS:cDesIndice := cDesIndice
	oWS:cCodIndice := cCodIndice
	
	oWS:MTValIndices()
	If oWS:oWSMTVALINDICESRESULT:OWSDADOS != Nil
		oLista := oWS:oWSMTVALINDICESRESULT:OWSDADOS:oWSSTRUDADOSVALINDICE
	ElseIf __aIndVal != Nil
		If (nPos := aScan(__aIndVal,{|x| x[1] == cCodIndice})) > 0
			oLista := __aIndVal[nPos][2]
		Endif
	EndIf
	
	oWS := Nil

Return oLista

//-------------------------------------------------------------------
/*/{Protheus.doc} J216SetStatic
Fun��o responsavel por setar as variaveis estaticas

@param oListInd - Objeto contendo a listagem de indices retornados pelo servi�o
@param aIndVal - Array contendo os valores dos indices retornados pelo servi�o

@since 30/04/21
@version 1.0
/*/
//-------------------------------------------------------------------
Function J216SetStatic(oListInd,aIndVal)
Default oListInd := nil
Default aIndVal  := nil
__oListInd := oListInd
__aIndVal  := aIndVal
return
