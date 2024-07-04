#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA216.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA216

Cadastro MVC dos Graus de Instrucao do eSocial

@author Felipe C. Seolin
@since 09/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA216()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Cadastro dos Graus de Instrução"
oBrw:SetAlias("CMH")
oBrw:SetMenuDef("TAFA216")
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Felipe C. Seolin
@since 09/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return(xFunMnuTAF("TAFA216"))

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Felipe C. Seolin
@since 09/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCMH := FwFormStruct(1,"CMH")
Local oModel   := MpFormModel():New("TAFA216")

oModel:AddFields("MODEL_CMH",/*cOwner*/,oStruCMH)
oModel:GetModel("MODEL_CMH"):SetPrimaryKey({"CMH_FILIAL","CMH_ID"})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Felipe C. Seolin
@since 09/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA216")
Local oStruCMH := FwFormStruct(2,"CMH")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_CMH",oStruCMH,"MODEL_CMH")

oView:EnableTitleView("VIEW_CMH",STR0001) //"Cadastro do Grau de Instrução"
oView:CreateHorizontalBox("FIELDSCMH",100)
oView:SetOwnerView("VIEW_CMH","FIELDSCMH")

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

nVerAtu := 1005

If nVerEmp < nVerAtu
	aAdd( aHeader, "CMH_FILIAL" )
	aAdd( aHeader, "CMH_ID" )
	aAdd( aHeader, "CMH_CODIGO" )
	aAdd( aHeader, "CMH_DESCRI" )
	aAdd( aHeader, "CMH_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "ANALFABETO", "20150625" } )
	aAdd( aBody, { "", "000002", "02", "ATE A 4ª SERIE INCOMPLETA DO ENSINO FUNDAMENTAL (ANTIGO 1º GRAU OU PRIMARIO), OU QUE TENHA SE ALFABETIZADO SEM TER FREQUENTADO ESCOLA REGULAR.", "20150625" } )
	aAdd( aBody, { "", "000003", "03", "4ª SERIA COMPLETA DO ENSINO FUNDAMENTAL (ANTIGO 1º GRAU OU PRIMARIO)", "20150625" } )
	aAdd( aBody, { "", "000004", "04", "DA 5ª A 8ª SERIE DO ENSINO FUNDAMENTAL (ANTIGO 1º GRAU OU GINASIO)", "20150625" } )
	aAdd( aBody, { "", "000005", "05", "ENSINO FUNDAMENTAL COMPLETO (ANTIGO 1º GRAU, PRIMARIO OU GINASIO)", "20150625" } )
	aAdd( aBody, { "", "000006", "06", "ENSINO MEDIO INCOMPLETO (ANTIGO 2º GRAU, SECUNDARIO OU COLEGIAL)", "20150625" } )
	aAdd( aBody, { "", "000007", "07", "ENSINO MEDIO COMPLETO (ANTIGO 2º GRAU, SECUNDARIO OU COLEGIAL)", "20150625" } )
	aAdd( aBody, { "", "000008", "08", "EDUCACAO SUPERIOR INCOMPLETA", "20150625" } )
	aAdd( aBody, { "", "000009", "09", "EDUCACAO SUPERIOR COMPLETA", "20150625" } )
	aAdd( aBody, { "", "000010", "10", "POS GRADUACAO", "20150625" } )
	aAdd( aBody, { "", "000011", "11", "MESTRADO", "20150625" } )
	aAdd( aBody, { "", "000012", "12", "DOUTORADO", "20150625" } )
	aAdd( aBody, { "", "000013", "01", "ANALFABETO, INCLUSIVE O QUE, EMBORA TENHA RECEBIDO INSTRUCAO, NAO SE ALFABETIZOU", "" } )
	aAdd( aBody, { "", "000014", "02", "ATE O 5º ANO INCOMPLETO DO ENSINO FUNDAMENTAL (ANTIGA 4ª SERIE) OU QUE SE TENHA ALFABETIZADO SEM TER FREQUENTADO ESCOLA REGULAR", "" } )
	aAdd( aBody, { "", "000015", "03", "5º ANO COMPLETO DO ENSINO FUNDAMENTAL", "" } )
	aAdd( aBody, { "", "000016", "04", "DO 6º AO 9º ANO DO ENSINO FUNDAMENTAL INCOMPLETO (ANTIGA 5ª A 8ª SERIE)", "" } )
	aAdd( aBody, { "", "000017", "05", "ENSINO FUNDAMENTAL COMPLETO", "" } )
	aAdd( aBody, { "", "000018", "06", "ENSINO MEDIO INCOMPLETO", "" } )
	aAdd( aBody, { "", "000019", "07", "ENSINO MEDIO COMPLETO", "" } )
	aAdd( aBody, { "", "000020", "08", "EDUCACAO SUPERIOR INCOMPLETA", "" } )
	aAdd( aBody, { "", "000021", "09", "EDUCACAO SUPERIOR COMPLETA", "" } )
	aAdd( aBody, { "", "000022", "10", "POS-GRADUACAO COMPLETA", "" } )
	aAdd( aBody, { "", "000023", "11", "MESTRADO COMPLETO", "" } )
	aAdd( aBody, { "", "000024", "12", "DOUTORADO COMPLETO", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )