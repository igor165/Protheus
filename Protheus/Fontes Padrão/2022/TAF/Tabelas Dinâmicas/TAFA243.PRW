#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA243.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA243

Cadastro MVC de Itens dos Agentes Nocivos do eSocial

@author Felipe C. Seolin
@since 13/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA243()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Cadastro de Itens dos Agentes Nocivos"
oBrw:SetAlias("C97")
oBrw:SetMenuDef("TAFA243")
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
Return(xFunMnuTAF("TAFA243"))

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

Local oStruC97 := FwFormStruct(1,"C97")
Local oModel   := MpFormModel():New("TAFA243")

oModel:AddFields("MODEL_C97",/*cOwner*/,oStruC97)
oModel:GetModel("MODEL_C97"):SetPrimaryKey({"C97_FILIAL","C97_ID"})

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

Local oModel   := FwLoadModel("TAFA243")
Local oStruC97 := FwFormStruct(2,"C97")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_C97",oStruC97,"MODEL_C97")

oView:EnableTitleView("VIEW_C97",STR0001) //"Cadastro de Itens dos Agentes Nocivos"
oView:CreateHorizontalBox("FIELDSC97",100)
oView:SetOwnerView("VIEW_C97","FIELDSC97")

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

nVerAtu := 1032.00

If nVerEmp < nVerAtu
	aAdd( aHeader, "C97_FILIAL" )
	aAdd( aHeader, "C97_ID" )
	aAdd( aHeader, "C97_IDFAM" )
	aAdd( aHeader, "C97_IDGRU" )
	aAdd( aHeader, "C97_IDNIV" )
	aAdd( aHeader, "C97_CODIGO" )
	aAdd( aHeader, "C97_DESCRI" )
	aAdd( aHeader, "C97_VALIDA" )

	aAdd( aBody, { "", "000001", "000001", "000004", "000004", "F4.2.1", "HIPERBARISMO EM TRABALHO SOB AR COMPRIMIDO", "" } )
	aAdd( aBody, { "", "000002", "000001", "000004", "000004", "F4.2.2", "HIPERBARISMO EM TRABALHO SUBMERSO", "" } )
	aAdd( aBody, { "", "000003", "000001", "000007", "000009", "F7.1.1", "RAIO X", "" } )
	aAdd( aBody, { "", "000004", "000001", "000007", "000009", "F7.1.2", "GAMA", "" } )
	aAdd( aBody, { "", "000005", "000001", "000007", "000010", "F7.2.1", "ALFA", "" } )
	aAdd( aBody, { "", "000006", "000001", "000007", "000010", "F7.2.2", "BETA", "" } )
	aAdd( aBody, { "", "000007", "000001", "000007", "000010", "F7.2.3", "NEUTRONS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
