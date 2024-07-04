#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA304.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA301
Cadastro MVC Monitorização Biológica            

@author Leandro Prado
@since 13/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA304()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Resultado de Monitorização Biológica"
oBrw:SetAlias("CUQ")
oBrw:SetMenuDef("TAFA304")
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Leandro Prado
@since 13/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return(xFunMnuTAF("TAFA304"))

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Leandro Prado
@since 13/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCUQ := FwFormStruct(1,"CUQ")
Local oModel   := MpFormModel():New("TAFA304")

oModel:AddFields("MODEL_CUQ",/*cOwner*/,oStruCUQ)
oModel:GetModel("MODEL_CUQ"):SetPrimaryKey({"CUQ_FILIAL","CUQ_ID"})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Leandro Prado
@since 13/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA304")
Local oStruCUQ := FwFormStruct(2,"CUQ")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_CUQ",oStruCUQ,"MODEL_CUQ")

oView:EnableTitleView("VIEW_CUQ",STR0001)//"Resultado de Monitorização Biológica" 
oView:CreateHorizontalBox("FIELDSCUQ",100)
oView:SetOwnerView("VIEW_CUQ","FIELDSCUQ")

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
	aAdd( aHeader, "CUQ_FILIAL" )
	aAdd( aHeader, "CUQ_ID" )
	aAdd( aHeader, "CUQ_CODIGO" )
	aAdd( aHeader, "CUQ_CODAGE" )
	aAdd( aHeader, "CUQ_MATBIO" )
	aAdd( aHeader, "CUQ_CODBIO" )
	aAdd( aHeader, "CUQ_VALIDA" )

	aAdd( aBody, { "", "000001", "111.1", "000001",   "1", "000001", "" } )
	aAdd( aBody, { "", "000002", "111.2", "000001",   "1", "000002", "" } )
	aAdd( aBody, { "", "000003", "111.3", "000001",   "1", "000003", "" } )
	aAdd( aBody, { "", "000004", "121.1", "000001",   "2", "000001", "" } )
	aAdd( aBody, { "", "000005", "121.2", "000001",   "2", "000002", "" } )
	aAdd( aBody, { "", "000006", "121.3", "000001",   "2", "000003", "" } )
	aAdd( aBody, { "", "000007", "212.1", "000002",   "1", "000004", "" } )
	aAdd( aBody, { "", "000008", "313.1", "000003",   "1", "000005", "" } )
	aAdd( aBody, { "", "000009", "414.1", "000004",   "1", "000006", "" } )
	aAdd( aBody, { "", "000010", "424.1", "000004",   "2", "000006", "" } )
	aAdd( aBody, { "", "000011", "424.2", "000004",   "2", "000007", "" } )
	aAdd( aBody, { "", "000012", "515.1", "000005",   "1", "000008", "" } )
	aAdd( aBody, { "", "000013", "616.1", "000006",   "1", "000009", "" } )
	aAdd( aBody, { "", "000014", "727.1", "000007",   "2", "000010", "" } )
	aAdd( aBody, { "", "000015", "818.1", "000008",   "1", "000011", "" } )
	aAdd( aBody, { "", "000016", "919.1", "000009",   "1", "000012", "" } )
	aAdd( aBody, { "", "000017", "10210.1", "000010", "2", "000013", "" } )
	aAdd( aBody, { "", "000018", "10210.2", "000010", "2", "000014", "" } )
	aAdd( aBody, { "", "000019", "10210.3", "000010", "2", "000015", "" } )
	aAdd( aBody, { "", "000020", "11111.1", "000011", "1", "000016", "" } )
	aAdd( aBody, { "", "000021", "11111.2", "000011", "1", "000017", "" } )
	aAdd( aBody, { "", "000022", "11111.3", "000011", "1", "000018", "" } )
	aAdd( aBody, { "", "000023", "12112.1", "000012", "1", "000019", "" } )
	aAdd( aBody, { "", "000024", "13113.1", "000013", "1", "000020", "" } )
	aAdd( aBody, { "", "000025", "14114.1", "000014", "1", "000021", "" } )
	aAdd( aBody, { "", "000026", "15115.1", "000015", "1", "000022", "" } )
	aAdd( aBody, { "", "000027", "16116.1", "000016", "1", "000023", "" } )
	aAdd( aBody, { "", "000028", "17117.1", "000017", "1", "000024", "" } )
	aAdd( aBody, { "", "000029", "18218.1", "000018", "2", "000025", "" } )
	aAdd( aBody, { "", "000030", "19119.1", "000019", "1", "000026", "" } )
	aAdd( aBody, { "", "000031", "20220.1", "000020", "2", "000027", "" } )
	aAdd( aBody, { "", "000032", "21121.1", "000021", "1", "000028", "" } )
	aAdd( aBody, { "", "000033", "22122.1", "000022", "1", "000029", "" } )
	aAdd( aBody, { "", "000034", "23123.1", "000023", "1", "000030", "" } )
	aAdd( aBody, { "", "000035", "24124.1", "000024", "1", "000031", "" } )
	aAdd( aBody, { "", "000036", "25125.1", "000025", "1", "000032", "" } )
	aAdd( aBody, { "", "000037", "26126.1", "000026", "1", "000033", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
