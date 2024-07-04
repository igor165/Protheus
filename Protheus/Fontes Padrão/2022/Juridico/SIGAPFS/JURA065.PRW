#INCLUDE "JURA065.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//----------------------------------------------------------------------
/*/{Protheus.doc} JURA065
Saldo de Adiantamentos

@author Clóvis Eduardo Teixeira
@since 08/12/2010
@version 1.0
/*/
//----------------------------------------------------------------------
Function JURA065()
Local oBrowse  := Nil
Local cPrefixo := GETMV("MV_JADTPRF")
Local cTipo    := GETMV("MV_JADTTP")

ALTERA := .T.

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "SE1" )
oBrowse:SetLocate()

If !Empty(cPrefixo) .And. !Empty(cTipo)
	oBrowse:SetFilterDefault( "E1_PREFIXO =='" + Alltrim(cPrefixo) + "' .And. E1_TIPO =='" + Alltrim(cTipo) +;
	"' .And. E1_SALDO > 0 .And. E1_ORIGEM == 'JURA069'" )
EndIf

JurSetLeg( oBrowse, "SE1" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL

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

@author Clóvis Eduardo Teixeira
@since 27/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA065", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0006, "JA065LIST()"    , 0, 8, 0, NIL } ) // "Mostra Saldo"

If ExistBlock("J065MENU")
	aRotNew := ExecBlock( "J065MENU", .F., .F., { NIL , "MENUDEF", "J065MENU" } )
	If ValType( aRotNew ) == "A"
		aEval( aRotNew, { |aX| aAdd( aRotina, aX ) } )
	Endif
Endif

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Saldo de Adiantamentos

@author Felipe Bonvicini Conti
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA065" )
Local oStruct := FWFormStruct( 2, "SE1" )

JurSetAgrp( 'SE1',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA065_VIEW", oStruct, "SE1MASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA065_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Saldo de Adiantamentos"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Saldo de Adiantamentos

@author Felipe Bonvicini Conti
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "SE1" )

oModel:= MPFormModel():New( "JURA065", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "SE1MASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0013 ) // "Modelo de Dados de Saldo de Adiantamentos"
oModel:GetModel( "SE1MASTER" ):SetDescription( STR0014 ) // "Dados de Saldo de Adiantamentos"

JurSetRules( oModel, 'SE1MASTER',, 'SE1' )

Return oModel

//----------------------------------------------------------------------
/*/{Protheus.doc} JA065LIST
Mostra Saldo de Adiantamento.

@author Clóvis Eduardo Teixeira
@since 08/12/2010
@version 1.0
/*/
//----------------------------------------------------------------------
Function JA065LIST()
Local aArea    := GetArea()
Local aResult  := {}
Local nSaldo   := 0
Local cPref    := Alltrim(GETMV("MV_JADTPRF"))
Local cTip     := Alltrim(GETMV("MV_JADTTP"))
Local cMoeda   := ""
Local cCliente := ""
Local cLoja    := ""
Local cNomCli  := ""
Local cQuery   := ""
Local cQryRes  := GetNextAlias()

//--- Objetos do ListBox
Local oDlgRes  := Nil
Local oLbx     := Nil
Local oLayer   := FWLayer():New()
Local cTitle   := STR0007  // "Saldo por Cliente"

//---Header do ListBox
Local cStr01   := STR0008  // "Codigo"
Local cStr02   := STR0012  // "Loja"
Local cStr03   := STR0009  // "Razao Social"
Local cStr04   := STR0010  // "Moeda"
Local cStr05   := STR0011  // "Saldo"
Local cStr06   := STR0015  // "Caso"
Local cStr07   := STR0016  // "Título"
Local cStr08   := STR0017  // "Tipo Adiant."
Local aButtons :={}

cCliente       := SE1->E1_CLIENTE
cLoja          := SE1->E1_LOJA

cQuery := " SELECT SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NOMCLI, SE1.E1_MOEDA, SUM(E1_SALDO) E1_SALDO, "
cQuery += " NWF.NWF_CCASO, NVE.NVE_TITULO, NWF.NWF_TPADI "
cQuery += " FROM " + RetSqlName('SE1') + " SE1, "
cQuery +=      " " + RetSqlName('NWF') + " NWF, "
cQuery +=      " " + RetSqlName('NVE') + " NVE "
cQuery += " WHERE NVE.NVE_FILIAL ='" + xFilial("NVE") + "'"
cQuery += " AND NWF.NWF_FILIAL ='" + xFilial("NWF") + "'"
cQuery += " AND SE1.E1_CLIENTE = '" + cCliente + "' "
cQuery += " AND SE1.E1_LOJA = '" + cLoja + "' "
cQuery += " AND SE1.E1_PREFIXO = '" + cPref + "' "
cQuery += " AND SE1.E1_TIPO = '" + cTip + "' "
cQuery += " AND SE1.E1_SALDO > 0 "
cQuery += " AND SE1.E1_NUM = NWF.NWF_TITULO "
cQuery += " AND NVE.NVE_LCLIEN = NWF.NWF_CLOJA "
cQuery += " AND NVE.NVE_CCLIEN = NWF.NWF_CCLIEN "
cQuery += " AND NVE.NVE_NUMCAS = NWF.NWF_CCASO "
cQuery += " AND SE1.E1_ORIGEM = 'JURA069' "
cQuery += " AND SE1.D_E_L_E_T_ = ' ' "
cQuery += " AND NWF.D_E_L_E_T_ = ' ' "
cQuery += " AND NVE.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_MOEDA, NWF_CCASO, NVE_TITULO, NWF_TPADI "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cQryRes, .F., .T.)

While !(cQryRes)->(Eof())
	Aadd( aResult, { (cQryRes)->E1_CLIENTE, (cQryRes)->E1_LOJA, (cQryRes)->E1_NOMCLI, ;
						JurGetDados('CTO', 1, xFilial('CTO') + StrZero((cQryRes)->E1_MOEDA, 2), 'CTO_SIMB'),;
						Transform( (cQryRes)->E1_SALDO, "@E 999,999,999.99" ),;
						(cQryRes)->NWF_CCASO,Transform((cQryRes)->NVE_TITULO, "@R XXXXXXXXXXXXXXXXXXXXXXXXXXXXX" ),;
						Transform(JurInfBox('NWF_TPADI', (cQryRes)->NWF_TPADI) ,"@R XXXXXXXXXX" )  })
	(cQryRes)->(dbSkip())
Enddo

(cQryRes)->(dbCloseArea())

DEFINE FONT oFont NAME "Ms Sans Serif" BOLD

DEFINE MSDIALOG oDlgRes FROM 0, 0 TO 417, 844 TITLE cTitle PIXEL

//Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
oLayer:init(oDlgRes, .F.)

oLayer:addCollumn("MainColl", 100, .F.) //Cria as colunas do Layer

@ 01,01 LISTBOX oLbx FIELDS HEADER cStr01, cStr02, cStr03, cStr04, cStr05, cStr06, cStr07, cStr08 SIZE 424, 176 OF oLayer:GetColPanel( 'MainColl' ) PIXEL

oLbx:SetArray(aResult)
oLbx:bLine:={||{aResult[oLbx:nAt][1],;
                aResult[oLbx:nAt][2],;
                aResult[oLbx:nAt][3],;
                aResult[oLbx:nAt][4],;
                aResult[oLbx:nAt][5],;
                aResult[oLbx:nAt][6],;
                aResult[oLbx:nAt][7],;
                aResult[oLbx:nAt][8] }}

ACTIVATE MSDIALOG oDlgRes CENTERED ON INIT EnchoiceBar( oDlgRes, {|| oDlgRes:End() }, {|| oDlgRes:End() },, aButtons,/*nRecno*/,/*cAlias*/, .F., .F.,.T.,.F.,.F. )

oFont:End()
DeleteObject( oDlgRes )
DeleteObject( oLbx )

RestArea( aArea )

Return Nil
