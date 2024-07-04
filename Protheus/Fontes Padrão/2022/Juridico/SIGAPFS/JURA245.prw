#INCLUDE "JURA245.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA245
Responsaveis x C.Custo

@author Luciano Pereira dos Santos
@since 25/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA245(nOperacao)
Default nOperacao := MODEL_OPERATION_UPDATE

If FWAliasInDic("OHE")
	FWExecView( STR0001, 'JURA245', nOperacao, , { || .T. }, , , ) //"Responsáveis x C.Custo"
Else
	JurMsgError( STR0004 ) //"Dicionário de dados desatualizado, tabela OHE não econtrada!"
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Responsáveis x C.Custo

@author Luciano Pereira dos Santos
@since 25/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructCTT := FWFormStruct( 1, "CTT", {|cCampo| J245CtCpo(cCampo)})
Local oStructOHE := FWFormStruct( 1, "OHE" )

oModel:= MPFormModel():New( "JURA245", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "CTTMASTER", NIL, oStructCTT, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:GetModel( "CTTMASTER" ):SetDescription( STR0002 ) //"Centro de Custo"
oModel:AddGrid("OHEDETAIL", "CTTMASTER", oStructOHE)
oModel:GetModel( "OHEDETAIL" ):SetDescription( STR0003 ) //"Responsáveis"
oModel:SetRelation("OHEDETAIL", {{"OHE_FILIAL","xFilial('OHE')"},{"OHE_CCCUST","CTT_CUSTO"}}, OHE->(IndexKey(1)))
oModel:GetModel( "OHEDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "OHEDETAIL" ):SetOptional( .T. )

oStructCTT:SetProperty("*", MODEL_FIELD_WHEN, {||.F.})

oModel:GetModel("OHEDETAIL"):SetUniqueLine( {"OHE_CPART"} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Responsáveis x C.Custo

@author Luciano Pereira dos Santos
@since 25/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local oModel     := FWLoadModel( "JURA245" )
Local oStructCTT := FWFormStruct( 2, "CTT", {|cCampo| J245CtCpo(cCampo)})
Local oStructOHE := FWFormStruct( 2, "OHE" )

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("JURA245_CTT", oStructCTT, "CTTMASTER")
oView:AddGrid("JURA245_OHE" , oStructOHE, "OHEDETAIL")

oView:CreateHorizontalBox("FORMFIELD", 30)
oView:CreateHorizontalBox("FORMGRID",  70)

oView:SetOwnerView("JURA245_CTT", "FORMFIELD")
oView:SetOwnerView("JURA245_OHE", "FORMGRID")

oView:EnableTitleView("JURA245_OHE")

oStructOHE:RemoveField('OHE_CCCUST')
oStructOHE:RemoveField('OHE_CPART')

oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} J245CtCpo(cCampo)
Função para selecionar os campos do Model e View da tabela CTT

@param cCampo campo da estrutura.

@Return .T. para campos que ope

@author Luciano Pereira dos Santos
@since 25/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J245CtCpo(cCampo)
Local lRet     := .F.
Local cNomeCpo := AllTrim(cCampo)

If cNomeCpo $ "CTT_FILIAL|CTT_CUSTO|CTT_DESC01|CTT_DESC02|CTT_DESC03|CTT_DESC04|"+;
				"CTT_DESC05|CTT_CESCRI|CTT_DESCRI|CTT_SIGLA|CTT_DPART|CTT_EMAIL|CTT_BLOQ"
	lRet := .T.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J245Exclui(cCCusto)
Função para excluir os Responsáveis do C. Custo quando o mesmo for excluido

@Param  cCCusto Código de Centro de Custo.

@Obs Função chamada pela rotina Ctba030Del() - CTBA030.PRW

@author Luciano Pereira dos Santos
@since 25/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J245Exclui(cCCusto)
Local aArea      := GetArea()
Local cOHE_Fil   := ''

If FWAliasInDic("OHE") //Proteção para o modulo SIGACTB
	cOHE_Fil := xFilial("OHE")
	OHE->(DbSetOrder(1)) //OHE_FILIAL + OHE_CCCUST + OHE_CPART

	If OHE->(dbSeek( xFilial("OHE") + cCCusto ))
		While !OHE->(Eof()) .And. (OHE->OHE_FILIAL + OHE->OHE_CCCUST == cOHE_Fil + cCCusto )
			RecLock("OHE",.F.,.T.)
			OHE->(dbDelete())
			OHE->(MsUnlock())
			OHE->(dbSkip())
		EndDo
	EndIf
EndIf

RestArea(aArea)

Return