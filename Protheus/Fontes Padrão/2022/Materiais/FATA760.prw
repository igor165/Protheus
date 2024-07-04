#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FATA760.CH" 

//-------------------------------------------------------------------
/*/	{Protheus.doc} Fata760
Programa de Cadastro de Intermediadores
@param		nOpcAuto	-	identificador da operação
			aA1UMaster	-	array de dados para execauto 
@autor  	Squad CRM/Fat
@data 		03/02/2021
@return 	
/*/
//-------------------------------------------------------------------

Function FATA760()

Private aRotina 	:= MenuDef()

If cPaisLoc == "BRA"
	DEFINE FWMBROWSE oMBrowse ALIAS "A1U"
	oMBrowse:DisableDetails()
	ACTIVATE FWMBROWSE oMBrowse
EndIf

Return

//-------------------------------------------------------------------
/*/	{Protheus.doc} MenuDef
Definicao do MenuDef para o MVC
@autor  	Squad CRM/Fat
@data 		03/02/2021
@return 	aRotina - Array de Operações da Rotina
/*/
//-------------------------------------------------------------------
Static Function Menudef()

aRotina := {}
ADD OPTION aRotina Title STR0001	Action 'VIEWDEF.FATA760'		OPERATION MODEL_OPERATION_VIEW   ACCESS 0	//'Visualizar'
ADD OPTION aRotina Title STR0002	Action 'VIEWDEF.FATA760'		OPERATION MODEL_OPERATION_INSERT ACCESS 0	//'Incluir'
ADD OPTION aRotina Title STR0003	Action 'VIEWDEF.FATA760'		OPERATION MODEL_OPERATION_UPDATE ACCESS 0 	//'Alterar'
ADD OPTION aRotina Title STR0004	Action 'VIEWDEF.FATA760'		OPERATION MODEL_OPERATION_DELETE ACCESS 0	//'Excluir'


Return aRotina

//-------------------------------------------------------------------
/*/	{Protheus.doc} ModelDef
Modelo de Dados para o MVC
@autor  	Squad CRM/Fat
@data 		03/02/2021
@return 	oModel - Objeto do Modelo
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruA1U := FWFormStruct( 1, 'A1U')
Local oModel   := MPFormModel():New('FATA760',/*bPreValid*/,/*bPosValid*/,/*Commit*/,/*Cancel*/)   

oModel:AddFields( 'A1UMASTER',, oStruA1U)
oModel:SetDescription(STR0005) //'Cadastro de Intermediadores'
oModel:SetPrimaryKey( { 'A1U_CODIGO'} )

Return oModel

//-------------------------------------------------------------------
/*/	{Protheus.doc} ViewDef
Interface da aplicacao
@autor  	Squad CRM/Fat
@data 		03/02/2021
@return 	oView - Objeto da Interface
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'FATA760' )
Local oStruA1U := FWFormStruct( 2, 'A1U')
Local oView     

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_A1U',oStruA1U,'A1UMASTER')

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} FT760CGC
Validacao do CNPJ do Intermediador (Utilizado no Valid do campo A1U_CGC)
@sample 	FT760CGC( cCgc )
@param		cCgc 	-  CNPJ do registro posicionado
@return   	lRet    - Verdadeiro ou Falso
@author		Squad CRM/Fat
@since		03/02/21 
@version	12
/*/
//------------------------------------------------------------------------------

Function FT760CGC( cCgc )

Local aArea    := GetArea()
Local lRet     := .T.   

Default cCgc   := M->A1U_CGC

If Len(AllTrim(cCgc)) < 14
	lRet := .F.
	Help( , , /*Texto do Help*/, , STR0006, 1, 0, , , , , , {STR0007}) //'Inválido'#'Informe um CNPJ válido'
Else
	lRet := CGC( cCgc ) //Validação de CPF/CNPJ
	If lRet
		A1U->(DBSetOrder(2))	
		If A1U->(dbSeek(xFilial('A1U')+cCgc))
			lRet := .F.
			Help( , , /*Texto do Help*/, , STR0008, 1, 0, , , , , , {STR0009 + " " + A1U->A1U_CODIGO}) //'CNPJ Já cadastrado como intermediador.'#'Verifique o registro'
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return( lRet )
