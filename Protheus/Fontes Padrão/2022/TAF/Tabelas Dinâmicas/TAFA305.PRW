#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA305.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA305
Cadastro MVC Motivo de Estabilidade            

@author Leandro Prado
@since 17/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA305()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Motivo de Estabilidade"
oBrw:SetAlias("CUR")
oBrw:SetMenuDef("TAFA305")
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Leandro Prado
@since 17/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return(xFunMnuTAF("TAFA305"))

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Leandro Prado
@since 17/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCUR := FwFormStruct(1,"CUR")
Local oModel   := MpFormModel():New("TAFA305")

oModel:AddFields("MODEL_CUR",/*cOwner*/,oStruCUR)
oModel:GetModel("MODEL_CUR"):SetPrimaryKey({"CUR_FILIAL","CUR_ID"})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Leandro Prado
@since 17/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA305")
Local oStruCUR := FwFormStruct(2,"CUR")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_CUR",oStruCUR,"MODEL_CUR")

oView:EnableTitleView("VIEW_CUR",STR0001) //"Motivo de Estabilidade"
oView:CreateHorizontalBox("FIELDSCUR",100)
oView:SetOwnerView("VIEW_CUR","FIELDSCUR")

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
	aAdd( aHeader, "CUR_FILIAL" )
	aAdd( aHeader, "CUR_ID" )
	aAdd( aHeader, "CUR_CODIGO" )
	aAdd( aHeader, "CUR_DESCRI" )
	aAdd( aHeader, "CUR_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "ACIDENTE DE TRABALHO", "" } )
	aAdd( aBody, { "", "000002", "02", "MANDATO SINDICAL", "" } )
	aAdd( aBody, { "", "000003", "03", "MANDATO ELEITORAL", "" } )
	aAdd( aBody, { "", "000004", "04", "GRAVIDEZ", "" } )
	aAdd( aBody, { "", "000005", "05", "PRESTACAO DE SERVICO MILITAR", "" } )
	aAdd( aBody, { "", "000006", "06", "CONVENCAO COLETIVA DE TRABALHO", "" } )
	aAdd( aBody, { "", "000007", "07", "CANDIDATO DA CIPA", "" } )
	aAdd( aBody, { "", "000008", "08", "ELEITO TITULAR CIPA", "" } )
	aAdd( aBody, { "", "000009", "09", "ELEITO SUPLENTE CIPA", "" } )
	aAdd( aBody, { "", "000010", "10", "MEMBRO DO CONSELHO NACIONAL DA PREVIDENCIA SOCIAL (CNPS)", "" } )
	aAdd( aBody, { "", "000011", "11", "MEMBRO DE COMISSAO DE CONCILIACAO PREVIA", "" } )
	aAdd( aBody, { "", "000012", "12", "EMPREGADOS ELEITOS DIRETORES DE SOCIEDADES COOPERATIVAS", "" } )
	aAdd( aBody, { "", "000013", "13", "MEMBROS DO CONSELHO CURADOR DO FGTS", "" } )
	aAdd( aBody, { "", "000014", "99", "OUTROS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )