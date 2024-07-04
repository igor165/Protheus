#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA241.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA241

Cadastro MVC de Grupos dos Agentes Nocivos do eSocial

@author Felipe C. Seolin
@since 13/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA241()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Cadastro de Grupos dos Agentes Nocivos"
oBrw:SetAlias("C95")
oBrw:SetMenuDef("TAFA241")
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
Return(xFunMnuTAF("TAFA241"))

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

Local oStruC95 := FwFormStruct(1,"C95")
Local oModel   := MpFormModel():New("TAFA241")

oModel:AddFields("MODEL_C95",/*cOwner*/,oStruC95)
oModel:GetModel("MODEL_C95"):SetPrimaryKey({"C95_FILIAL","C95_ID"})

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

Local oModel   := FwLoadModel("TAFA241")
Local oStruC95 := FwFormStruct(2,"C95")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_C95",oStruC95,"MODEL_C95")

oView:EnableTitleView("VIEW_C95",STR0001) //"Cadastro de Grupos dos Agentes Nocivos"
oView:CreateHorizontalBox("FIELDSC95",100)
oView:SetOwnerView("VIEW_C95","FIELDSC95")

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
	aAdd( aHeader, "C95_FILIAL" )
	aAdd( aHeader, "C95_ID" )
	aAdd( aHeader, "C95_IDFAM" )
	aAdd( aHeader, "C95_CODIGO" )
	aAdd( aHeader, "C95_DESCRI" )
	aAdd( aHeader, "C95_VALIDA" )

	aAdd( aBody, { "", "000001", "000001", "F1", "ELETRICIDADE", "" } )
	aAdd( aBody, { "", "000002", "000001", "F2", "TEMPERATURAS ANORMAIS", "" } )
	aAdd( aBody, { "", "000003", "000001", "F3", "UMIDADE", "" } )
	aAdd( aBody, { "", "000004", "000001", "F4", "PRESSAO ATMOSFERICA", "" } )
	aAdd( aBody, { "", "000005", "000001", "F5", "RUIDO", "" } )
	aAdd( aBody, { "", "000006", "000001", "F6", "VIBRACAO", "" } )
	aAdd( aBody, { "", "000007", "000001", "F7", "RADIACAO IONIZANTE", "" } )
	aAdd( aBody, { "", "000008", "000001", "F8", "RADIACAO NAO IONIZANTE", "" } )
	aAdd( aBody, { "", "000009", "000001", "F9", "OUTROS", "" } )
	aAdd( aBody, { "", "000010", "000002", "Q1", "GAS", "" } )
	aAdd( aBody, { "", "000011", "000002", "Q2", "VAPOR", "" } )
	aAdd( aBody, { "", "000012", "000002", "Q3", "OLEO", "" } )
	aAdd( aBody, { "", "000013", "000002", "Q4", "GRAXAS", "" } )
	aAdd( aBody, { "", "000014", "000002", "Q5", "SOLVENTES", "" } )
	aAdd( aBody, { "", "000015", "000002", "Q6", "AERODISPERSOIDES", "" } )
	aAdd( aBody, { "", "000016", "000002", "Q7", "OUTROS", "" } )
	aAdd( aBody, { "", "000017", "000003", "B1", "BACTERIA", "" } )
	aAdd( aBody, { "", "000018", "000003", "B2", "FUNGO", "" } )
	aAdd( aBody, { "", "000019", "000003", "B3", "PROTOZOARIO", "" } )
	aAdd( aBody, { "", "000020", "000003", "B4", "PARASITAS", "" } )
	aAdd( aBody, { "", "000021", "000003", "B5", "VIRUS", "" } )
	aAdd( aBody, { "", "000022", "000003", "B6", "CULTURAS DE CELULAS", "" } )
	aAdd( aBody, { "", "000023", "000003", "B7", "TOXINAS", "" } )
	aAdd( aBody, { "", "000024", "000003", "B8", "PRIONS", "" } )
	aAdd( aBody, { "", "000025", "000003", "B9", "OUTRAS", "" } )
	aAdd( aBody, { "", "000026", "000004", "E1", "BIOMECANICOS", "" } )
	aAdd( aBody, { "", "000027", "000004", "E2", "ORGANIZACIONAIS, INCLUSIVE PSICOSSOCIAIS", "" } )
	aAdd( aBody, { "", "000028", "000005", "M1", "TRABALHA EM ALTURA", "" } )
	aAdd( aBody, { "", "000029", "000005", "M2", "ILUMINACAO INADEQUADA", "" } )
	aAdd( aBody, { "", "000030", "000005", "M3", "CHOQUE ELETRICO", "" } )
	aAdd( aBody, { "", "000031", "000005", "M4", "CHOQUE MECANICO", "" } )
	aAdd( aBody, { "", "000032", "000005", "M5", "ARRANJO FISICO INADEQUADO", "" } )
	aAdd( aBody, { "", "000033", "000005", "M6", "INCENDIO E EXPLOSAO (PROBABILIDADE)", "" } )
	aAdd( aBody, { "", "000034", "000005", "M7", "MAQUINAS E EQUIPAMENTOS SEM PROTECAO", "" } )
	aAdd( aBody, { "", "000035", "000005", "M8", "ARMAZENAMENTO INADEQUADO", "" } )
	aAdd( aBody, { "", "000036", "000005", "M9", "ANIMAIS PECONHENTOS", "" } )
	aAdd( aBody, { "", "000037", "000005", "M10", "FERRAMENTAS INADEQUADAS OU DEFEITUOSAS", "" } )
	aAdd( aBody, { "", "000038", "000005", "M11", "SOTERRAMENTO", "" } )
	aAdd( aBody, { "", "000039", "000005", "M12", "CORTES E PERFURACOES", "" } )
	aAdd( aBody, { "", "000040", "000005", "M13", "QUEIMADURAS", "" } )
	aAdd( aBody, { "", "000041", "000005", "M14", "ACIDENTES DE TRANSITO", "" } )
	aAdd( aBody, { "", "000042", "000005", "M15", "OUTRAS SITUACOES DE RISCO", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
