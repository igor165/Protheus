#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA056.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA056
Cadastro de Natureza da Operacao/Prestacao

@author Luccas Curcio
@since 07/11/2012
@version 1.0

/*/

//-------------------------------------------------------------------
Function FISA056()
Local oBrowse
		
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("CD1")
	oBrowse:SetDescription(STR0001) //"Natureza da Operacao/Prestacao"
	oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return FWMVCMenu - Opcoes de menu

@author Luccas Curcio
@since 07/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu ("FISA056")

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Luccas Curcio
@since 07/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStruct := FWFormStruct(1, "CD1")

oModel	:=	MPFormModel():New('MODEL_CD1', ,{ |oModel| PosValModel(oModel) }  )
oModel:AddFields( 'MODEL_CD1' ,, oStruct )
oModel:SetPrimaryKey({"CD1_FILIAL","CD1_CODNAT"})		
oModel:SetDescription(STR0001)//"Natureza da Operacao/Prestacao"
oModel:GetModel( 'MODEL_CD1' ):SetDescription(STR0001)//"Natureza da Operacao/Prestacao"

//Define que os campos podem ser editados apenas em uma operação de inclusao
oStruct:SetProperty( 'CD1_CODNAT' 	, MODEL_FIELD_WHEN	, {|| (oModel:GetOperation()==3) })

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Luccas Curcio
@since 07/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local	oModel	:=	FWLoadModel( "FISA056" )
Local	oStruct	:=	FWFormStruct(2, "CD1" )
Local	oView

oView	:=	FWFormView():New()
oView:SetModel(oModel)
oView:AddField( 'VIEW_CD1', oStruct, 'MODEL_CD1' )
oView:CreateHorizontalBox( "PAINEL_PRINC" , 100 )
oView:SetOwnerView( 'VIEW_CD1', "PAINEL_PRINC" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PosValModel
Funcao utilizada para validar o modelo de dados

@return lRet - Retorna valor boleano
				.T. - Informacoes do modelo OK
				.F. - Informacoes do modelo com problemas, apresenta Help do problema
			
@author Luccas Curcio
@since 07/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PosValModel(oModel)
Local	lRet		:=	.T.
Local 	nOperation	:=	oModel:GetOperation()
Local	cCodNat		:=	oModel:GetValue( 'MODEL_CD1','CD1_CODNAT' )

If nOperation == 3
	If CD1->(MsSeek(xFilial("CD1")+cCodNat))
		Help(,,"A056DUPL",,"Código de Natureza da Operação/Prestação já cadastrado",1,0)
		lRet	:= 	.F.
	Endif
Endif

Return lRet 