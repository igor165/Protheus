#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA284.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA284
Cadastro MVC Tipo de cond. dif. de Trabalho          

@author Evandro dos Santos Oliveira
@since 27/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA284()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Tipos de Isenção"
oBrw:SetAlias("CMY")
oBrw:SetMenuDef("TAFA284")
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
Return(xFunMnuTAF("TAFA284"))

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

Local oStruCMY := FwFormStruct(1,"CMY")
Local oModel   := MpFormModel():New("TAFA284")

oModel:AddFields("MODEL_CMY",/*cOwner*/,oStruCMY)
oModel:GetModel("MODEL_CMY"):SetPrimaryKey({"CMY_FILIAL","CMY_ID"})

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

Local oModel   := FwLoadModel("TAFA284")
Local oStruCMY := FwFormStruct(2,"CMY")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_CMY",oStruCMY,"MODEL_CMY")

oView:EnableTitleView("VIEW_CMY",STR0001) //"Tipos de Isenção"
oView:CreateHorizontalBox("FIELDSCMY",100)
oView:SetOwnerView("VIEW_CMY","FIELDSCMY")

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
	aAdd( aHeader, "CMY_FILIAL" )
	aAdd( aHeader, "CMY_ID" )
	aAdd( aHeader, "CMY_CODIGO" )
	aAdd( aHeader, "CMY_DESCRI" )
	aAdd( aHeader, "CMY_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "PARCELA ISENTA 65 ANOS", "" } )
	aAdd( aBody, { "", "000002", "02", "DIARIA E AJUDA DE CUSTO", "" } )
	aAdd( aBody, { "", "000003", "03", "INDENIZACAO E RESCISAO DE CONTRATO, INCLUSIVE A TITULO DE PDV.", "" } )
	aAdd( aBody, { "", "000004", "04", "ABONO PECUNIARIO", "" } )
	aAdd( aBody, { "", "000005", "05", "OUTROS", "" } )
	aAdd( aBody, { "", "000006", "06", "LUCROS E DIVIDENDOS PAGOS A PARTIR DE 1996", "" } )
	aAdd( aBody, { "", "000007", "07", "VALORES PAGOS A TITULAR OU SOCIO DE MICROEMPRESA OU EMPRESA DE PEQUENO PORTE, EXCETO PRO-LABORE E ALUGUEIS.", "" } )
	aAdd( aBody, { "", "000008", "08", "PENSAO, APOSENTADORIA OU REFORMA POR MOLESTIA GRAVE OU ACIDENTE EM SERVICOS.", "" } )
	aAdd( aBody, { "", "000009", "09", "BENEFICIOS INDIRETOS E/OU REEMBOLSO DE DESPESAS RECEBIDAS POR VOLUNTARIO DA COPA DO MUNDO OU DA COPA DAS CONFEDERACOES", "" } )
	aAdd( aBody, { "", "000010", "10", "BOLSA DE ESTUDO RECEBIDA POR MEDICO-RESIDENTE", "" } )
	aAdd( aBody, { "", "000011", "11", "COMPLEMENTACAO DE APOSENTADORIA, CORRESPONDENTE AS CONTRIBUICOES EFETUADAS NO PERIODO DE 01/01/1989 A 31/12/1995.", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )