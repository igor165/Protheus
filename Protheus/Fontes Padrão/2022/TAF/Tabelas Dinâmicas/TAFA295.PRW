#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA295.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA295
Cadastro MVC Relação Fonte Pagadora

@author Evandro dos Santos Oliveira
@since 23/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA295()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Relação Fonte Pagadora"
oBrw:SetAlias("CUB")
oBrw:SetMenuDef("TAFA295")
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Evandro dos Santos Oliveira
@since 23/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return(xFunMnuTAF("TAFA295"))

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Evandro dos Santos Oliveira
@since 23/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCUB := FwFormStruct(1,"CUB")
Local oModel   := MpFormModel():New("TAFA295")

oModel:AddFields("MODEL_CUB",/*cOwner*/,oStruCUB)
oModel:GetModel("MODEL_CUB"):SetPrimaryKey({"CUB_FILIAL","CUB_ID"})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Evandro dos Santos Oliveira
@since 23/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA295")
Local oStruCUB := FwFormStruct(2,"CUB")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_CUB",oStruCUB,"MODEL_CUB")

oView:EnableTitleView("VIEW_CUB",STR0001) //"Relação Fonte Pagadora"
oView:CreateHorizontalBox("FIELDSCUB",100)
oView:SetOwnerView("VIEW_CUB","FIELDSCUB")

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
	aAdd( aHeader, "CUB_FILIAL" )
	aAdd( aHeader, "CUB_ID" )
	aAdd( aHeader, "CUB_CODIGO" )
	aAdd( aHeader, "CUB_DESCRI" )
	aAdd( aHeader, "CUB_VALIDA" )

	aAdd( aBody, { "", "000001", "500", "A FONTE PAGADORA E MATRIZ DA BENEFICIARIA NO EXTERIOR.", "" } )
	aAdd( aBody, { "", "000002", "510", "A FONTE PAGADORA E FILIAL, SUCURSAL OU AGENCIA DE BENEFICIARIA NO EXTERIOR.", "" } )
	aAdd( aBody, { "", "000003", "520", "A FONTE PAGADORA E CONTROLADA OU COLIGADA DA BENEFICIARIA NO EXTERIOR, NA FORMA DOS §§ 1º E 2º DO ART. 243 DA LEI Nº 6.404, DE 15 DE DEZEMBRO DE 1976.", "" } )
	aAdd( aBody, { "", "000004", "530", "A FONTE PAGADORA E CONTROLADORA OU COLIGADA DA BENEFICIARIA NO EXTERIOR, NA FORMA DOS §§ 1º E 2º DO ART. 243 DA LEI Nº 6.404, DE 1976.", "" } )
	aAdd( aBody, { "", "000005", "540", "A FONTE PAGADORA E A BENEFICIARIA NO EXTERIOR ESTAO SOB CONTROLE SOCIETARIO OU ADMINISTRATIVO COMUM OU QUANDO PELO MENOS 10% DO CAPITAL DE CADA UMA, PERTENCER A UMA MESMA PESSOA FISICA OU JURIDICA.", "" } )
	aAdd( aBody, { "", "000006", "550", "A FONTE PAGADORA E A BENEFICIARIA NO EXTERIOR TEM PARTICIPACAO SOCIETARIA NO CAPITAL DE UMA TERCEIRA PESSOA JURIDICA, CUJA SOMA AS CARACTERIZE COMO CONTROLADORAS OU COLIGADAS NA FORMA DOS §§ 1º E 2º DO ART. 243 DA LEI Nº", "" } )
	aAdd( aBody, { "", "000007", "560", "A FONTE PAGADORA OU A BENEFICIARIA NO EXTERIOR MANTENHA CONTRATO DE EXCLUSIVIDADE COMO AGENTE, COMO DISTRIBUIDOR OU COMO CONCESSIONARIO NAS OPERACOES COM BENS, SERVICOS E DIREITOS.", "" } )
	aAdd( aBody, { "", "000008", "570", "A FONTE PAGADORA E A BENEFICIARIA MANTEM ACORDO DE ATUACAO CONJUNTA.", "" } )
	aAdd( aBody, { "", "000009", "900", "NAO HA RELACAO ENTRE A FONTE PAGADORA E A BENEFICIARIA NO EXTERIOR.", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )