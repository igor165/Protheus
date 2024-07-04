#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FINA918.CH"

Static __cFilTef := ""

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA918
Conciliacao de Pagamentos

@author Totvs
@since 07/12/2020
/*/
//-------------------------------------------------------------------
Function FINA918()

	Local oBrowse 		As Object

	Private cCadastro	As Character
	Private cString 	As Character

	cCadastro := STR0020	
	cString   := "FIF"
	__cFilTef := cFilAnt //salva a filial logada para gerar o mov. de lote no fina110.
	
	dbSelectArea(cString)
	dbSetOrder(1)

	SetKey(019, {||}) //Desabilita CTRL+S para prevenir error.log

	oBrowse := BrowseDef()
	oBrowse:Activate()

	__cFilTef := ""
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Definicoes do Browse

@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Static Function BrowseDef() As Object
    Local oBrowse As Object
	Local cFiltro As Character

    oBrowse := FwMBrowse():New()

    oBrowse:SetAlias("FIF")

    oBrowse:SetDescription(STR0020)		//"Conciliacao Pagamentos"
	/*-------------------------------------------------------------------
		Legendas
	-------------------------------------------------------------------*/
    oBrowse:AddLegend("FIF_STATUS $ '1'", "BR_VERDE"	, 	STR0006	)		//#"Não Processado"
    oBrowse:AddLegend("FIF_STATUS $ '2'", "BR_VERMELHO"	, 	STR0007	)		//#"Conciliado Normal"
    oBrowse:AddLegend("FIF_STATUS $ '3'", "BR_AMARELO"	,	STR0008	)		//#"Divergente"
    oBrowse:AddLegend("FIF_STATUS $ '4'", "BR_AZUL"		, 	STR0009	)		//#"Conciliado Manual"
    oBrowse:AddLegend("FIF_STATUS $ '5'", "BR_BRANCO"	, 	STR0010	)		//#"Descartado"
    oBrowse:AddLegend("FIF_STATUS $ '6'", "BR_LARANJA"	, 	STR0018	)		//#"Ant. Nao Processada"
    oBrowse:AddLegend("FIF_STATUS $ '7'", "BR_PINK"		, 	STR0019	)		//#"Antecipado"
	oBrowse:AddLegend("FIF_STATUS $ '8'", "BR_AZUL_CLARO", 	STR0021	)		//#"Antecipação Conciliada Manual"

	cFiltro := " FIF_STATUS  <> ' ' "
	
	oBrowse:SetFilterDefault(cFiltro)

Return oBrowse


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} A918VISUAL
Rotina para visualização do registro posicionado
@type Function
@author Rogério Melônio
@since 18/01/2018
@version 12
/*/
//-------------------------------------------------------------------------------------
Function A918VISUAL()
Local nRecno := FIF->(Recno())

A918ALTERA("FIF", nRecno, 2)

Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} A918EDITA
Rotina para ediçao do registro posicionado

@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------------------------
Function A918Edita()
Local nRecno := FIF->(Recno())

A918ALTERA("FIF", nRecno, 4)

Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} A918ALTERA
Rotina para visualização ou alteração do registro posicionado
@type Function
@author Unknown
@since 06/08/2009
@version 12
/*/
//-------------------------------------------------------------------------------------
Function A918ALTERA(cAlias,nReg,nOpc)                                                          		
Local aCpoEnch		:= {}
Local aAlterEnch	:= {}
Local nModelo		:= 3	// Se for diferente de 1 desabilita execucao de gatilhos estrangeiros                           
Local lF3			:= .F.	// Indica se a enchoice esta sendo criada em uma consulta F3 para utilizar variaveis de memoria 
Local lMemoria		:= .T.	// Indica se a enchoice utilizara variaveis de memoria ou os campos da tabela na edicao         
Local lColumn		:= .F.	// Indica se a apresentacao dos campos sera em forma de coluna                                  
Local caTela		:= ""	// Nome da variavel tipo "private" que a enchoice utilizara no lugar da propriedade aTela       
Local lNoFolder		:= .F.	// Indica se a enchoice nao ira utilizar as Pastas de Cadastro (SXA)                            
Local lProperty		:= .T.	// Indica se a enchoice nao utilizara as variaveis aTela e aGets, somente suas propriedades com os mesmos nomes
Local aButtons		:= {}
Local lRet			:= .F.
Local nI			:= 0
Local oDlg			// Dialog Principal
Local aSize			:= MsAdvSize()
Local aPos  		:= {}
Local oSize 		:= FWDefSize():New(.T.)

//Monto os campos da Enchoice deixando somente os campos customizados e o FIF_STATUS para alterar
dbSelectArea("SX3")
dbSetOrder(1)
If SX3->( dbSeek( cAlias ) )
	While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == cAlias
		aAdd(aCpoEnch,SX3->X3_CAMPO)
		If (Alltrim(SX3->X3_PROPRI) == "U" .Or. Alltrim(SX3->X3_CAMPO) == "FIF_STATUS") .And. nOpc <> 2
			aAdd(aAlterEnch,SX3->X3_CAMPO)
		EndIf
		SX3->( dbSkip() )
	End
EndIf

oSize:AddObject( "ENCHOICE", 100,100, .T., .T. )
oSize:Process()
aPos := {oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI"),oSize:GetDimension("ENCHOICE","LINEND"),oSize:GetDimension("ENCHOICE","COLEND")}

DEFINE MSDIALOG oDlg TITLE STR0011 + " - " + If(ALTERA,STR0016,STR0015) FROM aSize[7],0 to aSize[6],aSize[5] Of oMainWnd PIXEL // ##"Conciliador TEF" ##"Alterar" ##"Visualizar"
	RegToMemory(cAlias, INCLUI, .F.)
	Enchoice(cAlias,,nOpc,,,,aCpoEnch,aPos,aAlterEnch,nModelo,,,,oDlg,lF3,lMemoria,lColumn,caTela,lNoFolder,lProperty)

ACTIVATE MSDIALOG oDlg CENTERED  ON INIT EnchoiceBar(oDlg, {|| lRet := .T.,oDlg:End()},{||lRet := .F.,oDlg:End()},,aButtons)

If lRet .And. nOpc <> 2 .And. Len(aAlterEnch) > 0
	RecLock(cAlias,.F.)
	For nI := 1 to Len(aAlterEnch)
		(cAlias)->&(aAlterEnch[nI]) :=  M->&(aAlterEnch[nI])
	Next nI
	(cAlias)->( MsUnLock() )
EndIf

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc}F918BxLote
Retornar a filial em que será gerada o movimento totalizador de baixa por lote

@author Sivaldo Oliveira
@since  18/02/2017
@version 12
/*/
//-------------------------------------------------------------------------------------
Function F918BxLote()

Return __cFilTef

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definicoes de Menu

@author Totvs
@since 07/12/2020

/*/
//-------------------------------------------------------------------
Static Function MenuDef() As Array
	Local aRotina As Array

	aRotina := {}

	ADD OPTION aRotina TITLE STR0012 	ACTION 'AxPesqui'  	OPERATION 1 	ACCESS 0 //Pesquisar
	ADD OPTION aRotina TITLE STR0014	ACTION "F920View"	OPERATION 2   	ACCESS 0 //"Conciliação"
	ADD OPTION aRotina TITLE STR0016	ACTION "A918EDITA"	OPERATION 4   	ACCESS 0 //"Alterar"		
	ADD OPTION aRotina TITLE STR0015	ACTION "A918Visual"	OPERATION 2   	ACCESS 0 //"Visualizar"	
	ADD OPTION aRotina TITLE STR0017	ACTION "FINA910C"	OPERATION 1   	ACCESS 0 //"Listagem Reg"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} F918AtuTPD
Avalia se o ambiente possui os pré-requisitos para utilizar
a conciliação de pagamentos via carteiras digitais (TPD - Totvs Pagamentos Digitais)

@author Totvs
@since 06/10/2021

/*/
//-------------------------------------------------------------------
Function F918AtuTPD() As Logical

	Local lRetorno 	as Logical
	Local oPerg As Object
	Local aPergunte As Array

	lRetorno := .F.
	
	If FIF->(ColumnPos("FIF_MODPAG")) > 0 .And. FJU->(ColumnPos("FJU_DOCTEF")) > 0 .And. TamSX3("FIF_NUCOMP")[1] >= 100	
		//Verifica se existe o novo grupo de perguntas
		oPerg := FwSx1Util():New()
		oPerg:AddGroup("FINA918")
		oPerg:SearchGroup()
		aPergunte := oPerg:GetGroup("FINA918")
		If LEN(aPergunte) > 1 .AND. !Empty(aPergunte[2])
			lRetorno := .T.
			FwFreeArray(aPergunte)
		Endif
		FWFReeObj(oPerg)
	Endif

Return lRetorno
