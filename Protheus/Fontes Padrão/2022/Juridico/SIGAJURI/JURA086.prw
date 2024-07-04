#INCLUDE "JURA086.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA086
Grupo de Empresa

@author Juliana Iwayama Velho
@since 16/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA086()
Local oBrowse

// Eh criado o alias NST_SXB para utilizacao na consulta padrao para nao desposicionar a 
// tabela NST pois eh feita uma referencia para ela mesma

If Select( 'NST_SXB' ) > 0
	NST_SXB->( dbCloseArea() )
EndIf

ChkFile( 'NST',,'NST_SXB' )

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NST" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NST" )
JurSetBSize( oBrowse )
oBrowse:Activate()

NST_SXB->( dbCloseArea() )

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

@author Juliana Iwayama Velho
@since 16/03/10

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA086", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA086", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA086", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA086", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA086", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Grupo de Empresa

@author Juliana Iwayama Velho
@since 16/03/10

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA086" )
Local oStruct := FWFormStruct( 2, "NST" )

JurSetAgrp( 'NST',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA086_VIEW", oStruct, "NSTMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA086_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) 
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Grupo de Empresa

@author Juliana Iwayama Velho
@since 16/03/10
@version 1.0

@obs NSTMASTER - Dados do Grupo de Empresa

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NST" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA086", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NSTMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) 
oModel:GetModel( "NSTMASTER" ):SetDescription( STR0009 ) 

JurSetRules( oModel, 'NSTMASTER',, 'NST' )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} JA086NST            
Monta a query de grupo para não listar o próprio registro e o mãe

@param cCodigo	    Código do grupo
@Return cQuery	 	Query montada

@author Juliana Iwayama Velho
@since 16/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA086NST(cCodigo)
Local cQuery   := "" 

cQuery += "SELECT NST_COD, NST_DESC,NST.R_E_C_N_O_ NSTRECNO "
cQuery += " FROM "+RetSqlName("NST")+" NST"
cQuery += " WHERE NST_FILIAL = '"+xFilial("NST")+"'"
cQuery += " AND NST.D_E_L_E_T_ = ' '"
If !Empty(cCodigo)
    cQuery += " AND NST_COD <> NST_CEMPM "
	cQuery += " AND NST_COD <> '"+cCodigo+"'"
	cQuery += " AND NST_CEMPM <> '"+cCodigo+"'"	
EndIf

Return cQuery        

//-------------------------------------------------------------------
/*/{Protheus.doc} JA086VNST            
Verifica se o valor do campo de empresa mãe é válido

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 16/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA086VNST()
Local lRet     := .F.
Local aArea    := GetArea()
Local cQuery   := JA086NST( FwFldGet("NST_COD") )
Local cAlias   := GetNextAlias()

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

(cAlias)->( dbSelectArea( cAlias ) )
(cAlias)->( dbGoTop() )

While !(cAlias)->( EOF() )
	If (cAlias)->NST_COD == FwFldGet('NST_CEMPM')
		lRet := .T.
		Exit
	EndIf
	(cAlias)->( dbSkip() )
End

If !lRet
	JurMsgErro(STR0010)
EndIf

(cAlias)->( dbcloseArea() )
RestArea(aArea)

Return lRet              
         
//-------------------------------------------------------------------
/*/{Protheus.doc} JA086NST             
Customiza a consulta padrão de grupos de empresa

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 16/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA086F3NST()
Local lRet     := .F.
Local aArea    := GetArea()
Local cQuery   := ''     
Local aPesq    := {"NST_COD","NST_DESC"}

IF INCLUI .Or. ALTERA
	
	
	If INCLUI
		cQuery:= JA086NST( FwFldGet("NST_COD") )
	Else
		cQuery:= JA086NST( NST->NST_COD )
	EndIf
	//EndIf
	
	cQuery := ChangeQuery(cQuery, .F.)
	
	uRetorno := ''
	
	RestArea( aArea )
	//JurF3Qry( cQuery, cCodCon, cCpoRecno, uRetorno, aCoord, aSearch, cTela, lInclui, lAltera, lVisualiza, cTabela )
	If JurF3Qry( cQuery, 'JURA086F3', 'NSTRECNO', @uRetorno,,aPesq,,,,,'NST' )
		NST_SXB->( dbGoto( uRetorno ) )
		lRet := .T.
	EndIf
	
EndIf

Return lRet 

 