#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA302.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA302
Cadastro MVC Tipo de cond. dif. de Trabalho          

@author Evandro dos Santos Oliveira
@since 27/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA302()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Tipo de cond. dif. de Trabalho"
oBrw:SetAlias("CUN")
oBrw:SetMenuDef("TAFA302")
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Evandro dos Santos Oliveira
@since 27/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return(xFunMnuTAF("TAFA302"))

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Evandro dos Santos Oliveira
@since 27/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCUN := FwFormStruct(1,"CUN")
Local oModel   := MpFormModel():New("TAFA302")

oModel:AddFields("MODEL_CUN",/*cOwner*/,oStruCUN)
oModel:GetModel("MODEL_CUN"):SetPrimaryKey({"CUN_FILIAL","CUN_ID"})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Evandro dos Santos Oliveira
@since 27/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA302")
Local oStruCUN := FwFormStruct(2,"CUN")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_CUN",oStruCUN,"MODEL_CUN")

oView:EnableTitleView("VIEW_CUN",STR0001) //"Tipo de cond. dif. de Trabalho"
oView:CreateHorizontalBox("FIELDSCUN",100)
oView:SetOwnerView("VIEW_CUN","FIELDSCUN")

Return(oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1003

If nVerEmp < nVerAtu
	aAdd( aHeader, "CUN_FILIAL" )
	aAdd( aHeader, "CUN_ID" )
	aAdd( aHeader, "CUN_CODIGO" )
	aAdd( aHeader, "CUN_DESCRI" )
	aAdd( aHeader, "CUN_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "INSALUBRIDADE", "" } )
	aAdd( aBody, { "", "000002", "02", "PERICULOSIDADE", "" } )
	aAdd( aBody, { "", "000003", "03", "FATOR DE RISCO", "" } )
	aAdd( aBody, { "", "000004", "04", "MEMBRO DO SESMT", "" } )
	aAdd( aBody, { "", "000005", "05", "DESIGNADO DA CIPA", "" } )
	aAdd( aBody, { "", "000006", "06", "TRABALHADOR TREINADO PARA UTILIZACAO DE MATERIAL DE PRIMEIROS SOCORROS", "" } )
	aAdd( aBody, { "", "000007", "07", "AUTORIZADO A TRABALHAR EM INSTALACOES ELETRICAS", "" } )
	aAdd( aBody, { "", "000008", "08", "AUTORIZADO A OPERAR E INTERVIR EM MAQUINAS", "" } )
	aAdd( aBody, { "", "000009", "09", "RESPONSAVEL TECNICO PELA SEGURANCA EM ESPACO CONFINADO", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )