#INCLUDE "JURA141.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA141
Inclusão de WO - Fatura

@author David Gonçalves Fernandes
@since 29/12/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA141()
Local lVldUser     := IIf(FindFunction("JurVldUxP"), JurVldUxP(), .T.)
Local lJura074     := FWIsInCallStack("JURA074") // Cadastro de Protocolos 
Local cFiltro      := J141Filter(lJura074)

Private oBrowse
Private lMarcar    := .F.

If lVldUser
	oBrowse := FWMarkBrowse():New()
	If lJura074
		oBrowse:SetDescription( STR0016 ) //"Geração Automática" - Protocolo de fatura
		oBrowse:SetMenuDef('JURA141')
	Else
		oBrowse:SetDescription( STR0007 ) //"Inclusão de WO - Fatura"
	EndIf
	oBrowse:SetAlias( "NXA" )
	oBrowse:SetLocate()
	oBrowse:SetFilterDefault( cFiltro )
	oBrowse:SetFieldMark( 'NXA_OK' )
	oBrowse:bAllMark := { ||  JurMarkALL(oBrowse, "NXA", 'NXA_OK', lMarcar := !lMarcar,, .F.), oBrowse:Refresh() }
	JurSetLeg( oBrowse, "NXA" )
	JurSetBSize( oBrowse )
	oBrowse:Activate()
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J141Filter
Monta query para filtro do browse de WO de fatruas

@param  lJura074, Se verdadeiro a chamada foi executada através da JURA074
                  (Cadastro de Protocolos)

@return cFilter , Query para filtro do Browse de WO de Faturas

@author  Jonatas Martins
@since   25/11/2019
/*/
//-------------------------------------------------------------------
Static Function J141Filter(lJura074)
Local cFilter := ""

	If lJura074 // Cadastro de Protocolos
		cFilter := "NXA_TIPO == 'FT' .And. NXA_SITUAC == '1'"
	Else
		cFilter := "@ NXA_TIPO = 'FT' AND NXA_SITUAC = '1' AND NXA_NFGER <> '1'"
		cFilter += " AND NOT EXISTS (" + J141FilSE1() + ")" // Filtra SE1/SE5
	EndIf

Return (cFilter)

//-------------------------------------------------------------------
/*/{Protheus.doc} J141FilSE1
Complementa filtro para ignorar faturas com pagamentos

@return cFilterSE1, Complemento da query de filtro para desconsiderar faturas com baixas

@author  Jonatas Martins/fabiana.silva
@since   08/09/2021
@Obs     Trecho separado da função J141Filter para execução do "ChangeQuery"
/*/
//-------------------------------------------------------------------
Static Function J141FilSE1()
Local cFilterSE1 := ""
Local nTamFil    := TamSX3("NXA_FILIAL")[1]
Local nTamEsc    := TamSX3("NXA_CESCR")[1]
Local cTamFilial := cValToChar(nTamFil)
Local cIniEscr   := cValToChar(nTamFil+2)
Local cTamEscr   := cValToChar(nTamEsc)
Local cIniFatur  := cValToChar(nTamFil+1+nTamEsc+2)
Local cTamFatur  := cValToChar(TamSX3("NXA_COD")[1])

	cFilterSE1 := " SELECT 1"
	cFilterSE1 +=   " FROM " + RetSqlName("SE5") + " SE5, " + RetSqlName("SE1") + " SE1"
	cFilterSE1 +=  " WHERE SE1.D_E_L_E_T_ = ' '"
	cFilterSE1 +=    " AND SUBSTRING(SE1.E1_JURFAT, 1, " + cTamFilial + ") = NXA_FILIAL"
	cFilterSE1 +=    " AND SUBSTRING(SE1.E1_JURFAT, " + cIniEscr + ", " + cTamEscr + ") = NXA_CESCR"
	cFilterSE1 +=    " AND SUBSTRING(SE1.E1_JURFAT, " + cIniFatur + ", " + cTamFatur + ") = NXA_COD"
	cFilterSE1 +=    " AND SE1.E1_CLIENTE = NXA_CLIPG"
	cFilterSE1 +=    " AND SE1.E1_LOJA = NXA_LOJPG"
	cFilterSE1 +=    " AND SE1.E1_FILIAL = SE5.E5_FILIAL"
	cFilterSE1 +=    " AND SE1.E1_PREFIXO = SE5.E5_PREFIXO"
	cFilterSE1 +=    " AND SE1.E1_NUM = SE5.E5_NUMERO "
	cFilterSE1 +=    " AND SE1.E1_PARCELA = SE5.E5_PARCELA"
	cFilterSE1 +=    " AND SE1.E1_TIPO = SE5.E5_TIPO"
	cFilterSE1 +=    " AND SE1.E1_CLIENTE = SE5.E5_CLIFOR"
	cFilterSE1 +=    " AND SE1.E1_LOJA = SE5.E5_LOJA"
	cFilterSE1 +=    " AND SE5.E5_TIPODOC <> 'CP'"
	cFilterSE1 +=    " AND SE5.E5_DTCANBX = '        '"
	cFilterSE1 +=    " AND SE5.D_E_L_E_T_ = ' '"
	cFilterSE1 +=    " AND NOT EXISTS(SELECT 1" 
	cFilterSE1 +=                     " FROM " + RetSqlName("SE5") + " B"
	cFilterSE1 +=                    " WHERE B.E5_FILIAL = SE5.E5_FILIAL" 
	cFilterSE1 +=                      " AND B.R_E_C_N_O_ = SE5.R_E_C_N_O_"
	cFilterSE1 +=                      " AND B.E5_TIPODOC = 'ES'"
	cFilterSE1 +=                      " AND B.D_E_L_E_T_ = ' ')"

	cFilterSE1 := ChangeQuery(cFilterSE1)

Return (cFilterSE1)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Felipe Bonvicini Conti
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0001, "PesqBrw", 0, 1, 0, .T. } ) // "Pesquisar"
	
	If IsInCallStack( 'JURA074' )
		aAdd( aRotina, { STR0015, "JA074SET(oBrowse)", 0, 6, 0, NIL } ) // "Gerar" //Protocolo de fatura - JURA074	
		aAdd( aRotina, { STR0002, "VIEWDEF.JURA204", 0, 2, 0, NIL } ) // "Visualizar"
	Else
		aAdd( aRotina, { STR0002, "VIEWDEF.JURA141", 0, 2, 0, NIL } ) // "Visualizar"
		aAdd( aRotina, { "WO", "JA141SET(oBrowse)", 0, 6, 0, NIL } ) // "WO"
	EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Fatura dos Profissionais

@author Felipe Bonvicini Conti
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( "JURA141" )
Local oStructNXA := FWFormStruct( 2, "NXA" )

	JurSetAgrp( 'NXA',, oStructNXA )
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "JURA141_NXA", oStructNXA, "NXAMASTER"  )
	oView:CreateHorizontalBox( "NXAFIELDS", 100 )
	oView:SetOwnerView( "JURA141_NXA", "NXAFIELDS" )
	
	oView:SetDescription( STR0007 ) // "Fatura dos Profissionais"
	oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Fatura dos Profissionais

@author Felipe Bonvicini Conti
@since 17/06/09
@version 1.0

@obs NXAMASTER - Dados do Fatura dos Profissionais
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNXA := FWFormStruct( 1, "NXA" )

	oModel:= MPFormModel():New( "JURA141", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:AddFields( "NXAMASTER", NIL, oStructNXA, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription( STR0008 ) // "Modelo de Dados de Fatura dos Profissionais"
	oModel:GetModel( "NXAMASTER" ):SetDescription( STR0009 ) // "Dados de Fatura dos Profissionais"
	JurSetRules( oModel, "NXAMASTER",, "NXA",,  )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA141SET
Envia os Lançamentos para WO: Cria um registro na Tabela de WO,
vincula os lançamentos ao número do WO e
atualiza o valor dos lançamentos na tabela WO Caso

@param 	cTipo  	Tipo da alteração a ser executada nos time-Sheets

@author David Gonçalves Fernandes
@since 07/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA141SET(oBrowse)
	Local lRet       := .T.
	Local cMarca     := oBrowse:Mark()
	Local aArea      := GetArea()
	Local aAreaNXA   := NXA->( GetArea() )
	Local cFiltro    := "(NXA_OK == '" + cMarca + "')"
	Local cMsg       := ''
	Local aOBS       := {}
	Local aRetNXA    := {}
	
	If (lRet := JURA203G( 'FT', Date(), 'FATCAN' )[2]) //Testa se há período de fechamento, caso contrário, a fatura não poderá ser cancelada e nem ser realizado o WO
		aOBS := JurMotWO('NUF_OBSEMI', STR0007, STR0014, "4") // "Inclusão de WO - Fatura" - "Observação - WO"
		If !Empty(aOBS)
			FWMsgRun(, {|| aRetNXA := JAWOFATURA(cFiltro, aOBS)}, STR0007, STR0018) // Inclusão de WO - Faturas # Processando, aguarde..."
			If aRetNXA[1] > 0
				cMsg := Alltrim(Str(aRetNXA[1])) + " " + STR0012 + CRLF // "Fatura Enviada para WO "
				cMsg += STR0013 + Str(aRetNXA[2]) + CRLF + CRLF // "Nº de Lançamentos: "
			EndIf
			cMsg += aRetNXA[3]
		EndIf
	EndIf
	
	If !Empty(cMsg)
		ApMsgInfo( cMsg )
	EndIf
	
	RestArea( aAreaNXA )
	RestArea( aArea )

Return lRet
