#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA240.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA240

Cadastro MVC de Familias dos Agentes Nocivos do eSocial

@author Felipe C. Seolin
@since 13/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA240()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Cadastro de Famílias dos Agentes Nocivos"
oBrw:SetAlias("C94")
oBrw:SetMenuDef("TAFA240")
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Felipe C. Seolin
@since 13/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return(xFunMnuTAF("TAFA240"))

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Felipe C. Seolin
@since 13/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruC94 := FwFormStruct(1,"C94")
Local oModel   := MpFormModel():New("TAFA240")

oModel:AddFields("MODEL_C94",/*cOwner*/,oStruC94)
oModel:GetModel("MODEL_C94"):SetPrimaryKey({"C94_FILIAL","C94_ID"})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Felipe C. Seolin
@since 13/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA240")
Local oStruC94 := FwFormStruct(2,"C94")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_C94",oStruC94,"MODEL_C94")

oView:EnableTitleView("VIEW_C94",STR0001) //"Cadastro de Famílias dos Agentes Nocivos"
oView:CreateHorizontalBox("FIELDSC94",100)
oView:SetOwnerView("VIEW_C94","FIELDSC94")

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

nVerAtu := 1023.36

If nVerEmp < nVerAtu
	aAdd( aHeader, "C94_FILIAL" )
	aAdd( aHeader, "C94_ID" )
	aAdd( aHeader, "C94_CODIGO" )
	aAdd( aHeader, "C94_DESCRI" )
	aAdd( aHeader, "C94_VALIDA" )

	aAdd( aBody, { "", "000001", "F", "FISICO", "" } )
	aAdd( aBody, { "", "000002", "Q", "QUIMICO", "" } )
	aAdd( aBody, { "", "000003", "B", "BIOLOGICO", "" } )
	aAdd( aBody, { "", "000004", "E", "ERGONOMICO", "" } )
	aAdd( aBody, { "", "000005", "M", "MECANICO/ACIDENTES", "" } )
	aAdd( aBody, { "", "000006", "P", "PERICULOSO", "" } )
	aAdd( aBody, { "", "000007", "A", "ASSOCIACAO DE FATORES DE RISCO", "" } )
	aAdd( aBody, { "", "000008", "O", "OUTROS FATORES DE RISCO", "" } )
	aAdd( aBody, { "", "000009", "U", "AUSENCIA DE FATORES DE RISCO", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )