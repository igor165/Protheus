#INCLUDE 'JURA118.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA118
Manutenção dos Agrupamentos de campos nas telas das rotinas

@author Ernani Forastieri
@since 01/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA118()
Local oBrowse
Local aArea    := GetArea()
Local aAreaSX3 := SX3->( GetArea() )
Local aAreaSXA := SXA->( GetArea() )

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0008 )
oBrowse:SetAlias( 'NVX' )
oBrowse:SetLocate()
//oBrowse:AddLegend( 'NVX_PROPRI == "S"', 'RED'   , STR0006 ) // "Não Permite Alteração"
//oBrowse:AddLegend( 'NVX_PROPRI <> "S"', 'GREEN' , STR0007 ) // "Permite Alteração"
JurSetLeg( oBrowse, 'NVX' )
oBrowse:Activate()

RestArea( aAreaSX3 )
RestArea( aAreaSXA )
RestArea( aArea )
Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@Return aRotina - Estrutura
[n, 1] Nome a aparecer no cabecalho
[n, 2] Nome da Rotina associada
[n, 3] Reservado
[n, 4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n, 5] Nivel de acesso
[n, 6] Habilita Menu Funcional

@author Ernani Forastieri
@since 01/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, 'PesqBrw'        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, 'VIEWDEF.JURA118', 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, 'VIEWDEF.JURA118', 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, 'VIEWDEF.JURA118', 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, 'VIEWDEF.JURA118', 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0014, 'JA118INIC()'    , 0, 3, 0, NIL } ) // "Carga Inicial"
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Natureza Juridica

@author Ernani Forastieri
@since 01/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( 'JURA118' )
Local oStructNVX := FWFormStruct( 2, 'NVX' )
Local oStructNUX := FWFormStruct( 2, 'NUX' )
Local oStructNUY := FWFormStruct( 2, 'NUY' )

oStructNUX:RemoveField( 'NUX_TABELA' )
oStructNUX:RemoveField( 'NUX_FUNCAO' )
oStructNUY:RemoveField( 'NUY_TABELA' )
oStructNUY:RemoveField( 'NUY_FUNCAO' )
oStructNUY:RemoveField( 'NUY_CODGRP' )
 
JurSetAgrp( 'NVX',, oStructNVX )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'JURA118_CAB'  , oStructNVX, 'NVXMASTER' )
oView:AddGrid(  'JURA118_ITEM' , oStructNUX, 'NUX2NIVEL' )
oView:AddGrid(  'JURA118_ITEM2', oStructNUY, 'NUY3NIVEL' )

oView:AddIncrementField( 'NUX2NIVEL', 'NUX_CODGRP'  )
oView:AddIncrementField( 'NUX2NIVEL', 'NUX_SEQ'     )

oView:CreateHorizontalBox( 'MASTER' , 15 )
oView:CreateHorizontalBox( 'DETAIL' , 20 )
oView:CreateHorizontalBox( 'DETAIL2', 65 )

oView:SetOwnerView( 'JURA118_CAB'  , 'MASTER'  )
oView:SetOwnerView( 'JURA118_ITEM' , 'DETAIL'  )
oView:SetOwnerView( 'JURA118_ITEM2', 'DETAIL2' )

oView:SetDescription( STR0008 ) // "Agrupamentos de Campos de Rotinas"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Legendas de Rotinas

@author Ernani Forastieri
@since 01/09/09
@version 1.0

@obs NVXMASTER - Dados do Legendas de Rotinas
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNVX := FWFormStruct( 1, 'NVX' )
Local oStructNUX := FWFormStruct( 1, 'NUX' )
Local oStructNUY := FWFormStruct( 1, 'NUY' )

oStructNUX:RemoveField( 'NUX_TABELA' )
oStructNUX:RemoveField( 'NUX_FUNCAO' )
oStructNUY:RemoveField( 'NUY_TABELA' )
oStructNUY:RemoveField( 'NUY_FUNCAO' )
oStructNUY:RemoveField( 'NUY_CODGRP' )

oModel := MPFormModel():New( 'JURA118',,,, )

oModel:AddFields( 'NVXMASTER', NIL, oStructNVX )
oModel:AddGrid( 'NUX2NIVEL', 'NVXMASTER', oStructNUX, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid( 'NUY3NIVEL', 'NUX2NIVEL', oStructNUY, /*bLinePre*/, { |oGrid| JUR118LOK1( oGrid ) }, /*bPre*/, /*bPost*/ )

oModel:SetDescription( STR0009 ) // "Modelo de Dados de Agrupamentos de Campos de Rotinas"

oModel:GetModel( 'NVXMASTER' ):SetDescription( STR0010 ) // "Cabecalho Agrupamentos de Campos de Rotinas"
oModel:GetModel( 'NUX2NIVEL' ):SetDescription( STR0008 ) // "Agrupamentos de Campos de Rotinas"
oModel:GetModel( 'NUY3NIVEL' ):SetDescription( STR0011 ) // "Campos dos Agrupamentos de Campos de Rotinas"

oModel:SetRelation( 'NUX2NIVEL', { { 'NUX_FILIAL', "xFilial( 'NUX' )" } , { 'NUX_TABELA', 'NVX_TABELA' }, { 'NUX_FUNCAO', 'NVX_FUNCAO' } } , NUX->( IndexKey( 1 ) ) )
oModel:SetRelation( 'NUY3NIVEL', { { 'NUY_FILIAL', "xFilial( 'NUY' )" } , { 'NUY_TABELA', 'NVX_TABELA' }, { 'NUY_FUNCAO', 'NVX_FUNCAO' }, { 'NUY_CODGRP', 'NUX_CODGRP' } } , NUY->( IndexKey( 1 ) ) )

oModel:GetModel( 'NUX2NIVEL' ):SetUniqueLine( { 'NUX_CODGRP' } )
oModel:GetModel( 'NUY3NIVEL' ):SetUniqueLine( { 'NUY_CAMPO'  } )

JurSetRules( oModel, 'NVXMASTER',, 'NVX' )
JurSetRules( oModel, 'NUX2NIVEL',, 'NUX' )
JurSetRules( oModel, 'NUY3NIVEL',, 'NUY' )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} JUR118VAL
Validacao dos campos

@author Ernani Forastieri
@since 01/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR118VAL( cCampo )
Local lRet    := .T.
Local cTabela := FwFldGet( 'NVX_TABELA' )

cCampo := Alltrim( cCampo )

If   SubStr( cCampo,1, 3 ) <> cTabela
	lRet := .F.
	JurMsgErro( STR0012 ) // "Campo não pertence a tabela selecionada."
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JUR118LOK1
Validacao de bLinePos do NUY Campos

@author Ernani Forastieri
@since 01/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JUR118LOK1( oGrid )
Local lRet      := .T.
Local oModel    := FwModelActive()
Local oGridAgrp := oModel:GetModel( 'NUX2NIVEL' )
Local nLinAgrp  := oGridAgrp:nLine
Local nLinCpos  := oGrid:nLine
Local nI        := 0
Local nJ        := 0
Local cCampo    := PadR( oGrid:GetValue( 'NUY_CAMPO', nLinCpos ), 10 )

//
// Verifica se o campo ja consta em outro agrupamento
//
If lRet
	
	For nI := 1 To oGridAgrp:GetQtdLine()
		oGridAgrp:GoLine( nI )
		
		If !oGridAgrp:IsDeleted()
			
			oGridCpos := oModel:GetModel( 'NUY3NIVEL' )
			
			For nJ := 1 To oGridCpos:GetQtdLine()
				                                                      	
				oGridCpos:GoLine( nJ )
				
				If !oGridCpos:IsDeleted() .AND. nLinAgrp <> nI //.AND. nLinCpos <> nJ // nao é ela mesma
					
					If PadR( oGridCpos:GetValue( 'NUY_CAMPO' ), 10 ) == cCampo
						JurMsgErro( STR0013 + oGridAgrp:GetValue( 'NUX_SEQ' ) + ' ' +  oGridAgrp:GetValue( 'NUX_GRUPO' ) ) // "Campo ja utilizado no agrupamento "
						lRet := .F.
						Exit
					EndIf
					
				EndIf
				
			Next
			
		EndIf
		
		If   !lRet
			Exit
		EndIf
		
	Next

	oGridAgrp:GoLine( nLinAgrp )
	oGrid:GoLine( nLinCpos )	

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR118INIC
Carga Inicial

@Param  lMigrador, Se .T. a excução é chamada pelo Migrador

@author Marcelo Araujo Dente
@since 22/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA118INIC(lMigrador)

	Local aTab  := {'NT4','NTA','NVE','NT2','NSY','NT3','NT0','NVK','NWU','NUF'}
	Local nI    := 0
	Local aArea := GetArea()
	Local cMsg  := ''
	
	Default lMigrador := .F. // Indica se a execução é via migrador
	
	DbSelectArea("NVX")
	NVX->( DbGoTop() )
		
	If !NVX->( Eof() )
		cMsg:= STR0015		//"A carga inicial irá processar os campos do idioma: "
	Else
		cMsg:= STR0017		//"Todos os campos da carga inicial estarão no idioma : "
	EndIf

	If lMigrador .Or. ApMsgYesNo(cMsg + __Language + CRLF + STR0018, STR0014 + " - " + STR0008)	//"Deseja continuar? "	//"Carga Inicial"	//"Agrupamentos de Campos de Rotinas"

		For nI:=1 To Len(aTab)
			JurLoadAgp( aTab[nI],, .T. )
		Next nI

		If !lMigrador
			MsgInfo(STR0016) //"Concluído"
		EndIF
	EndIf
	RestArea( aArea )

Return .T.
