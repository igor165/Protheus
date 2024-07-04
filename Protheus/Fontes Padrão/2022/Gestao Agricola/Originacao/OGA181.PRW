#include "protheus.ch"
#include "fwmvcdef.ch"
#include "OGA181.CH"

/** {Protheus.doc} OGA181
Rotina de Tipos de Amostras Avulsas

@param: 	Nil
@author: 	Vinícius Becher Pagung
@since: 	25/11/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA181()
Local oMBrowse	:= Nil

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "NKI" )
oMBrowse:SetDescription( STR0001 ) //"Tipos de Amostras Avulsas"
oMBrowse:SetMenuDef( "OGA181" )
oMBrowse:DisableDetails()
oMBrowse:Activate()

Return( Nil )


/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Vinícius Becher Pagung
@since: 	25/11/2015 
@Uso: 		OGA181 - Tipos de Amostras Avulsas
*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002    , "PesqBrw"       , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003    , "ViewDef.OGA181", 0, 2, 0, Nil } ) //"Visualizar"
aAdd( aRotina, { STR0004  	, "ViewDef.OGA181", 0, 3, 0, Nil } ) //"Incluir"
aAdd( aRotina, { STR0005  	, "ViewDef.OGA181", 0, 4, 0, Nil } ) //"Alterar"
aAdd( aRotina, { STR0006   	, "ViewDef.OGA181", 0, 5, 0, Nil } ) //"Excluir"
aAdd( aRotina, { STR0007  	, "ViewDef.OGA181", 0, 8, 0, Nil } ) //"Imprimir"
aAdd( aRotina, { STR0008    , "ViewDef.OGA181", 0, 9, 0, Nil } ) //"Copiar"

Return( aRotina )


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Vinícius Becher Pagung
@since: 	25/11/2015 
@Uso: 		OGA181 - Tipos de Amostras Avulsas
*/

Static Function ModelDef()
Local oStruNKI := FWFormStruct( 1, "NKI" )
Local oModel := MPFormModel():New( "OGA181")//, , /*{| oModel | PosModelo( oModel ) }*/, {| oModel | OG181GRVMD( oModel ) } )


oModel:AddFields( "NKIUNICO", Nil, oStruNKI )
oModel:SetDescription( STR0009  ) //"Tipo da Amostra Avulsa"
oModel:GetModel( "NKIUNICO" ):SetDescription( STR0010  ) //"Dados da Amostra Avulsa"
oModel:SetVldActivate( { | oModel | IniModelo( oModel, oModel:GetOperation() ) } )
oStruNKI:SetProperty( "NKI_TIPREL" , MODEL_FIELD_WHEN   , {||OGA181WHEN()})
Return( oModel )

FUNCTION OGA181WHEN ()
Local lRet:= .T.
Local oModel   := FWLoadModel( "OGA181" )

If oModel:GetOperation()= 1 
	if NKI->NKI_TIPREL == '2'
		lRet := .f.
	endif
EndIf
RETURN(lRet)

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Vinícius Becher Pagung
@since: 	25/11/2015 
@Uso: 		OGA181 - Tipos de Amostras Avulsas
*/
Static Function ViewDef()
	Local oStruNKI := FWFormStruct( 2, "NKI" )
	Local oModel   := FWLoadModel( "OGA181" )
	Local oView    := FWFormView():New()
	
	oView:SetModel( oModel )
	oView:AddField( "VIEW_NKI", oStruNKI, "NKIUNICO" )
	oView:CreateHorizontalBox( "UM"  , 100 )
	oView:SetOwnerView( "VIEW_NKI", "UM"   )
	oView:SetCloseOnOk( {||.t.} )

Return( oView )

/** {Protheus.doc} 7
Função que Inicializa o modelo de dados

@param:  oModel - Modelo de dados
@param:  nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return: lRetorno - verdadeiro ou falso
@author:  E Coelho
@since:  17/01/2015
@Uso:   AgroIndustria
*/

Static Function IniModelo( oModel , nOperation )
	Local lRetorno	:= .T.
	
   dbSelectArea('NJF')
 	NJF->( dbSetOrder( 4 ) )
 	If nOperation == MODEL_OPERATION_DELETE	
		If NJF->(dbSeek( xFilial( "NJF" ) + NKI->NKI_TIPAMO))
			Help( , , STR0011, , STR0013, 1, 0 ) //"Ajuda"###"Existem amostras cadastradas para este Tipo."
			lRetorno := .f.
		EndIf 
	Endif
	
Return( lRetorno )

