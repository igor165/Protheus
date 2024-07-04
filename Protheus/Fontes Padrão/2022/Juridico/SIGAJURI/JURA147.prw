#INCLUDE 'JURA147.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA147
Tipos de Assuntos JurÌdicos x Campos NSZ

@author ClÛvis Eduardo Teixeira
@since 18/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA147()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( 'NUZ' )
oBrowse:SetLocate()

oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de TransaÁ„o a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - AlteraÁ„o sem inclus„o de registros
7 - CÛpia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Ernani Forastieri
@since 18/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, 'PesqBrw'        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, 'VIEWDEF.JURA147', 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, 'VIEWDEF.JURA147', 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, 'VIEWDEF.JURA147', 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, 'VIEWDEF.JURA147', 0, 5, 0, NIL } ) // "Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipos de Assuntos JurÌdicos x Campos NSZ

@author ClÛivs Eduardo Teixeira
@since 18/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( 'JURA147' )
Local oStruct := FWFormStruct( 2, 'NUZ' )

JurSetAgrp( 'NUZ',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'JURA147_VIEW', oStruct, 'NUZMASTER'  )
oView:CreateHorizontalBox( 'FORMFIELD', 100 )
oView:SetOwnerView( 'JURA147_VIEW', 'FORMFIELD' )
oView:SetDescription( STR0007 ) // "Campos para Processo e Caso Juridico"
oView:EnableControlBar( .T. )

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipos de Assuntos JurÌdicos x Campos NSZ

@author ClÛvis Eduardo Teixeira
@since 18/06/09
@version 1.0                                                   

@obs NUZMASTER - Dados do Campos Tipos de Assuntos JurÌdicos x Campos NSZ
/*/
//-------------------------------------------------------------------
Static Function Modeldef()  
Local oModel     := NIL
Local oStructNUZ := FWFormStruct( 1, 'NUZ' )

oModel:= MPFormModel():New( 'JURA147',, { |oM| JURA147TOK( oM ) } )
//oModel:AddFields( 'NUZMASTER', NIL, oStructNUZ, , )   
oModel:AddFields( 'NUZMASTER', NIL/*cOwner*/, oStructNUZ,/*bPreValidacao*/,/**/,ˇ/**/, /*bCarga*/ )    

oModel:SetDescription( STR0007 ) // "Modelo de Dados de Tipos de Assuntos JurÌdicos x Campos NSZ"
oModel:GetModel('NUZMASTER'):SetDescription( STR0008 ) // "Dados de Campos para Tipos de Assuntos JurÌdicos x Campos NSZ"
JurSetRules( oModel, 'NUZMASTER',, 'NUZ' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA147TOK
Validacao Pos Model

@author Ernani Forastieri
@since 18/06/09
@version 1.0

@obs NUZMASTER - Dados do Campos para Processo e Caso Juridico
/*/
//-------------------------------------------------------------------
Static Function JURA147TOK( oModel )  
Local lRet := .T.

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J147VALD
Valida campo NUZ_CAMPO para acetar somente campos das tabelas  NSZ,NUQ,NT9

@author Wellington Coelho
@since 26/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J147VALD()
Local aArea := GetArea()
Local lRet  := SubStr(M->NUZ_CAMPO,1,3) $ 'NSZ|NUQ|NT9|NTA|NT4|'

If	!lRet
	JurMsgErro(STR0011) //"Campo inv†lido. Selecione um campo das tabelas NSZ,NUQ,NT9."	
EndIf
			
If	lRet 
	If !(lRet := JurExistSX3(M->NUZ_CAMPO))
		JurMsgErro(STR0012) //"O campo n∆o existe. Selecione um campo existente."
	EndIf	
EndIf

RestArea(aArea)

Return lRet

