#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA296.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA296
Cadastro MVC Relação Fonte Pagadora

@author Evandro dos Santos Oliveira
@since 23/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA296()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Tipo de Rendimento"
oBrw:SetAlias("CUC")
oBrw:SetMenuDef("TAFA296")
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
Return(xFunMnuTAF("TAFA296"))

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

Local oStruCUC := FwFormStruct(1,"CUC")
Local oModel   := MpFormModel():New("TAFA296")

oModel:AddFields("MODEL_CUC",/*cOwner*/,oStruCUC)
oModel:GetModel("MODEL_CUC"):SetPrimaryKey({"CUC_FILIAL","CUC_ID"})

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

Local oModel   := FwLoadModel("TAFA296")
Local oStruCUC := FwFormStruct(2,"CUC")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_CUC",oStruCUC,"MODEL_CUC")

oView:EnableTitleView("VIEW_CUC",STR0001) //"Tipo de Rendimento"
oView:CreateHorizontalBox("FIELDSCUC",100)
oView:SetOwnerView("VIEW_CUC","FIELDSCUC")

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

nVerAtu := 1021.04

If nVerEmp < nVerAtu
	aAdd( aHeader, "CUC_FILIAL" )
	aAdd( aHeader, "CUC_ID" )
	aAdd( aHeader, "CUC_CODIGO" )
	aAdd( aHeader, "CUC_DESCRI" )
	aAdd( aHeader, "CUC_VALIDA" )

	aAdd( aBody, { "", "000001", "0100", "RENDAS DE PROPRIEDADE IMOBILIARIA", "" } )
	aAdd( aBody, { "", "000002", "0110", "RENDAS DO TRANSPORTE INTERNACIONAL", "" } )
	aAdd( aBody, { "", "000003", "0120", "LUCROS E DIVIDENDOS DISTRIBUIDOS", "" } )
	aAdd( aBody, { "", "000004", "0130", "JUROS", "" } )
	aAdd( aBody, { "", "000005", "0140", "ROYALTIES", "" } )
	aAdd( aBody, { "", "000006", "0150", "GANHOS DE CAPITAL", "" } )
	aAdd( aBody, { "", "000007", "0160", "RENDAS DO TRABALHO SEM VINCULO EMPREGATICIO", "" } )
	aAdd( aBody, { "", "000008", "0170", "RENDA DO TRABALHO COM VINCULO EMPREGATICIO", "" } )
	aAdd( aBody, { "", "000009", "0180", "REMUNERACAO DE ADMINISTRADORES", "" } )
	aAdd( aBody, { "", "000010", "0190", "RENDAS DE ARTISTAS E DE ESPORTISTAS", "" } )
	aAdd( aBody, { "", "000011", "0200", "PENSOES", "" } )
	aAdd( aBody, { "", "000012", "0210", "PAGAMENTOS GOVERNAMENTAIS", "" } )
	aAdd( aBody, { "", "000013", "0220", "RENDAS DE PROFESSORES E PESQUISADORES", "" } )
	aAdd( aBody, { "", "000014", "0230", "RENDAS DE ESTUDANTES E APRENDIZES", "" } )
	aAdd( aBody, { "", "000015", "0240", "RENDIMENTOS DE EMPREGADOS OU CONTRATADOS - COPA", "" } )
	aAdd( aBody, { "", "000016", "0250", "PREMIOS DE ARBITROS, JOGADORES DE FUTEBOL E OUTROS MEMBROS DAS DELEGACOES - COPA", "" } )
	aAdd( aBody, { "", "000017", "0300", "OUTRAS RENDAS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )