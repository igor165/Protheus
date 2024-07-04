#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA306.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA306
Cadastro de Tipos de Despesa        

@author Denis R. de Oliveira
@since 06/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA306()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Códigos de Tipos de Despesa"
oBrw:SetAlias("CUV")
oBrw:SetMenuDef("TAFA306")
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Denis R. de Oliveira
@since 06/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return(xFunMnuTAF("TAFA306"))

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis R. de Oliveira
@since 06/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCUV := FwFormStruct(1,"CUV")
Local oModel   := MpFormModel():New("TAFA306")

oModel:AddFields("MODEL_CUV",/*cOwner*/,oStruCUV)
oModel:GetModel("MODEL_CUV"):SetPrimaryKey({"CUV_FILIAL","CUV_ID"})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis R. de Oliveira
@since 06/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA306")
Local oStruCUV := FwFormStruct(2,"CUV")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_CUV",oStruCUV,"MODEL_CUV")

oView:EnableTitleView("VIEW_CUV",STR0001) //"Códigos de Tipos de Despesa"
oView:CreateHorizontalBox("FIELDSCUV",100)
oView:SetOwnerView("VIEW_CUV","FIELDSCUV")

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
	aAdd( aHeader, "CUV_FILIAL" )
	aAdd( aHeader, "CUV_ID" )
	aAdd( aHeader, "CUV_CODIGO" )
	aAdd( aHeader, "CUV_DESCRI" )
	aAdd( aHeader, "CUV_VALIDA" )

	aAdd( aBody, { "", "000001", "1", "SEGURO", "" } )
	aAdd( aBody, { "", "000002", "2", "CONFECCAO DOS INGRESSOS", "" } )
	aAdd( aBody, { "", "000003", "3", "ALUGUEL DO CAMPO", "" } )
	aAdd( aBody, { "", "000004", "4", "REMUNERACAO DE ARBITROS E AUXILIARES E CONTRIBUICAO PREVIDENCIARIA INCIDENTE", "" } )
	aAdd( aBody, { "", "000005", "5", "REMUNERACAO DE MAO DE OBRA UTILIZADA PARA EXAME ANTIDOPING E CONTRIBUICAO PREVIDENCIARIA INCIDENTE", "" } )
	aAdd( aBody, { "", "000006", "6", "REMUNERACAO DO PESSOAL QUE COMPOE O QUADRO MOVEL DO EVENTO E CONTRIBUICAO PREVIDENCIARIA INCIDENTE", "" } )
	aAdd( aBody, { "", "000007", "7", "REMUNERACAO DE ESTRANGEIROS – ARBITROS E AUXILIARES E CONTRIBUICAO PREVIDENCIARIA INCIDENTE", "" } )
	aAdd( aBody, { "", "000008", "8", "REMUNERACAO DE ESTRANGEIROS – MAO DE OBRA UTILIZADA PARA EXAME ANTIDOPING E CONTRIBUICAO PREVIDENCIARIA", "" } )
	aAdd( aBody, { "", "000009", "9", "REMUNERACAO DE ESTRANGEIROS – PESSOAL QUE COMPOE O QUADRO MOVEL DO EVENTO E CONTRIBUICAO PREVIDENCIARIA INCIDENTE", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )