#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA242.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA242

Cadastro MVC de Niveis dos Agentes Nocivos do eSocial

@author Felipe C. Seolin
@since 13/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA242()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Cadastro de Níveis dos Agentes Nocivos"
oBrw:SetAlias("C96")
oBrw:SetMenuDef("TAFA242")
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
Return(xFunMnuTAF("TAFA242"))

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

Local oStruC96 := FwFormStruct(1,"C96")
Local oModel   := MpFormModel():New("TAFA242")

oModel:AddFields("MODEL_C96",/*cOwner*/,oStruC96)
oModel:GetModel("MODEL_C96"):SetPrimaryKey({"C96_FILIAL","C96_ID"})

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

Local oModel   := FwLoadModel("TAFA242")
Local oStruC96 := FwFormStruct(2,"C96")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_C96",oStruC96,"MODEL_C96")

oView:EnableTitleView("VIEW_C96",STR0001) //"Cadastro de Níveis dos Agentes Nocivos"
oView:CreateHorizontalBox("FIELDSC96",100)
oView:SetOwnerView("VIEW_C96","FIELDSC96")

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
	aAdd( aHeader, "C96_FILIAL" )
	aAdd( aHeader, "C96_ID" )
	aAdd( aHeader, "C96_IDFAM" )
	aAdd( aHeader, "C96_IDGRU" )
	aAdd( aHeader, "C96_CODIGO" )
	aAdd( aHeader, "C96_DESCRI" )
	aAdd( aHeader, "C96_VALIDA" )

	aAdd( aBody, { "", "000001", "000001", "000002", "F2.1", "FRIO", "" } )
	aAdd( aBody, { "", "000002", "000001", "000002", "F2.2", "CALOR", "" } )
	aAdd( aBody, { "", "000003", "000001", "000004", "F4.1", "HIPOBERISMO", "" } )
	aAdd( aBody, { "", "000004", "000001", "000004", "F4.2", "HIPERBARISMO", "" } )
	aAdd( aBody, { "", "000005", "000001", "000005", "F5.1", "CONTINUO OU INTERMITENTE", "" } )
	aAdd( aBody, { "", "000006", "000001", "000005", "F5.2", "IMPACTO", "" } )
	aAdd( aBody, { "", "000007", "000001", "000006", "F6.1", "CORPO INTEIRO", "" } )
	aAdd( aBody, { "", "000008", "000001", "000006", "F6.2", "LOCALIZADA", "" } )
	aAdd( aBody, { "", "000009", "000001", "000007", "F7.1", "ELETROMAGNETICA", "" } )
	aAdd( aBody, { "", "000010", "000001", "000007", "F7.2", "CORPUSCULAR", "" } )
	aAdd( aBody, { "", "000011", "000001", "000008", "F8.1", "LASER", "" } )
	aAdd( aBody, { "", "000012", "000001", "000008", "F8.2", "ULTRAVIOLETA", "" } )
	aAdd( aBody, { "", "000013", "000001", "000008", "F8.3", "RADIOFREQUENCIA E MICROONDAS", "" } )
	aAdd( aBody, { "", "000014", "000001", "000008", "F8.4", "RADIACAO VISIVEL E INFRAVERMELHO", "" } )
	aAdd( aBody, { "", "000015", "000001", "000008", "F8.5", "OUTROS", "" } )
	aAdd( aBody, { "", "000016", "000002", "000015", "Q6.1", "POEIRAS", "" } )
	aAdd( aBody, { "", "000017", "000002", "000015", "Q6.2", "FUMOS", "" } )
	aAdd( aBody, { "", "000018", "000002", "000015", "Q6.3", "FUMACAS", "" } )
	aAdd( aBody, { "", "000019", "000002", "000015", "Q6.4", "NEVOA", "" } )
	aAdd( aBody, { "", "000020", "000002", "000015", "Q6.5", "NEBLINA", "" } )
	aAdd( aBody, { "", "000021", "000004", "000026", "E1.1", "IMPOSICAO DE RITMOS EXCESSIVOS", "" } )
	aAdd( aBody, { "", "000022", "000004", "000026", "E1.2", "ESFORCO FISICO INTENSO", "" } )
	aAdd( aBody, { "", "000023", "000004", "000026", "E1.3", "LEVANTAMENTO E TRANSPORTE MANUAL DE PESO", "" } )
	aAdd( aBody, { "", "000024", "000004", "000026", "E1.4", "EXIGENCIA DE POSTURA INADEQUADA", "" } )
	aAdd( aBody, { "", "000025", "000004", "000026", "E1.5", "OUTROS", "" } )
	aAdd( aBody, { "", "000026", "000004", "000027", "E2.1", "TRABALHO EM TURNO E NOTURNO", "" } )
	aAdd( aBody, { "", "000027", "000004", "000027", "E2.2", "MONOTONIA E REPETIVIDADE", "" } )
	aAdd( aBody, { "", "000028", "000004", "000027", "E2.3", "SITUACOES DE STRESS", "" } )
	aAdd( aBody, { "", "000029", "000004", "000027", "E2.4", "CONTROLE RIGIDO DE PRODUTIVIDADE", "" } )
	aAdd( aBody, { "", "000030", "000004", "000027", "E2.5", "OUTROS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
