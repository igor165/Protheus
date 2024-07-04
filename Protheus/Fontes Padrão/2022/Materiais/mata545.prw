#INCLUDE "MATA545.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static aFreteP := {}
Static lDV9TIPCAR //-- TMS10R134 - Campo Modelo da Carga

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMATA545   บAutor  ณVendas Clientes     บ Data ณ  31/01/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de Pauta de Frete.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFAT                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function MATA545()

Private aRotina := MenuDef()

If ValType(lDV9TIPCAR) == "U"
	lDV9TIPCAR := DV9->(ColumnPos("DV9_TIPCAR")) > 0
EndIf

dbSelectArea("DV9")

If lDV9TIPCAR
	dbSetOrder(2) //DV9_FILIAL+STR(DV9_KM,7,0)+DV9_TIPCAR
Else
	dbSetOrder(1) //DV9_FILIAL+DV9_TARIFA
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("DV9")
oBrowse:SetMenuDef("MATA545")
oBrowse:SetDescription(STR0001) //"Cadastro de Pauta de Frete"
oBrowse:Activate()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณVendas Clientes     บ Data ณ  31/01/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina usada para realizar manueten็ใo na tabela DV9.      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMATA545                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"         OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.MATA545" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.MATA545" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.MATA545" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.MATA545" OPERATION 5 ACCESS 0
Return (aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณModelDef  บAutor  ณVendas Clientes     บ Data ณ  31/01/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefine o modelo de dados em MVC                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMATA545                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelDef()

Local oModel 	:= Nil
Local oStruDV91 := FWFormStruct( 1, "DV9", {|cCampo| AllTrim(cCampo)+"|" $ "DV9_KM|"} )
Local oStruDV92 := FWFormStruct( 1, "DV9", {|cCampo| AllTrim(cCampo)+"|" $ "DV9_TARIFA|DV9_TIPCAR|DV9_DESCAR|DV9_VALOR|DV9_TIPVAL|DV9_ICBASE|DV9_PERCEN|DV9_CARGAE|"} )
Local lDMC 		:= AliasIndic("DMC")
Local oStruDV93 := IIf(lDMC, FWFormStruct( 1, "DMD", {|cCampo| AllTrim(cCampo)+"|" $ "DMD_UF|DMD_TIPCAR|DMD_KM|DMD_TARIFA|DMD_INDICE|DMD_DESCIN|DMD_OPERAD|"} ), "")
Local bCommit	:= { |oMdl| CommitMdl(oMdl) }
Local bPosVld   := { |oMdl| A545PosVld(oMdl)}

If DV9->(ColumnPos("DV9_UF")) > 0
	oStruDV92 := FWFormStruct( 1, "DV9", {|cCampo| AllTrim(cCampo)+"|" $ "DV9_TARIFA|DV9_TIPCAR|DV9_DESCAR|DV9_VALOR|DV9_TIPVAL|DV9_ICBASE|DV9_PERCEN|DV9_CARGAE|DV9_UF|DV9_FAIXAP|DV9_UFERMS|DV9_PERUFE|"} )
Else
	oStruDV92 := FWFormStruct( 1, "DV9", {|cCampo| AllTrim(cCampo)+"|" $ "DV9_TARIFA|DV9_TIPCAR|DV9_DESCAR|DV9_VALOR|DV9_TIPVAL|DV9_ICBASE|DV9_PERCEN|DV9_CARGAE|"} )
EndIf

oModel:= MpFormModel():New("MATA545", /*bPreVld*/, bPosVld, bCommit, /*Cancel*/)
oModel:SetDescription(STR0001) //"Cadastro de Pauta de Frete"

If lDV9TIPCAR
	oModel:AddFields("DV9MASTER",/*cOwner*/,oStruDV91, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ ) 

	If DV9->(ColumnPos("DV9_UF")) > 0
		oModel:SetPrimaryKey( { "DV9_FILIAL", "DV9_TARIFA", "STR(DV9_KM,7,0)", "DV9_TIPCAR", "DV9_UF" } )
	Else
		oModel:SetPrimaryKey( { "DV9_FILIAL", "DV9_TARIFA", "STR(DV9_KM,7,0)", "DV9_TIPCAR" } )
	EndIf
	oModel:AddGrid("DV9DETAIL","DV9MASTER"/*cOwner*/,oStruDV92, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	oModel:SetRelation("DV9DETAIL",{ {"DV9_FILIAL", "xFilial('DV9')"}, {"DV9_KM", "DV9_KM"} }, DV9->(IndexKey()) ) 
	If DV9->(ColumnPos("DV9_UF")) > 0
		oModel:GetModel("DV9DETAIL"):SetUniqueLine({"DV9_TIPCAR","DV9_UF","DV9_FAIXAP"})
	Else
		oModel:GetModel("DV9DETAIL"):SetUniqueLine({"DV9_TIPCAR"})
	EndIf

	If lDMC
		oModel:AddGrid("DV9DETIND","DV9DETAIL"/*cOwner*/,oStruDV93, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
		oModel:SetRelation("DV9DETIND",{ {"DMD_FILIAL", "xFilial('DV9')"}, {"DMD_KM", "DV9_KM"},  {"DMD_UF", "DV9_UF"},  {"DMD_TIPCAR", "DV9_TIPCAR"}, {"DMD_TARIFA", "DV9_TARIFA"} }, DMD->(IndexKey()) ) 
		oModel:GetModel('DV9DETIND'):SetOptional( .T. )
		oModel:GetModel("DV9DETIND"):SetMaxLine(1)
	EndIf
Else
	oModel:AddFields("DV9MASTER",/*cOwner*/,oStruDV92, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:SetPrimaryKey( { "DV9_FILIAL", "DV9_TARIFA" } )
EndIf
Return(oModel)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณViewDef   บAutor  ณVendas Clientes     บ Data ณ  31/01/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefine a interface para cadastro de Componentes em MVC.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณMATA545                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewDef()
Local oView     := Nil
Local oModel    := FwLoadModel("MATA545")
Local oStruDV91 := FWFormStruct( 2, "DV9", {|cCampo| AllTrim(cCampo)+"|" $ "DV9_KM|"} )
Local oStruDV92 := FWFormStruct( 2, "DV9", {|cCampo| AllTrim(cCampo)+"|" $ "DV9_TARIFA|DV9_TIPCAR|DV9_DESCAR|DV9_VALOR|DV9_TIPVAL|DV9_ICBASE|DV9_PERCEN|DV9_CARGAE|"} )
Local lDMC 		:= AliasIndic("DMC")
Local oStruDV93 := IIf(lDMC, FWFormStruct( 2, "DMD", {|cCampo| AllTrim(cCampo)+"|" $ "DMD_INDICE|DMD_DESCIN|DMD_OPERAD|"} ), "")

If ValType(lDV9TIPCAR) == "U"
	lDV9TIPCAR := DV9->(ColumnPos("DV9_TIPCAR")) > 0
EndIf

If DV9->(ColumnPos("DV9_UF")) > 0
	oStruDV92 := FWFormStruct( 2, "DV9", {|cCampo| AllTrim(cCampo)+"|" $ "DV9_TARIFA|DV9_TIPCAR|DV9_DESCAR|DV9_VALOR|DV9_TIPVAL|DV9_ICBASE|DV9_PERCEN|DV9_CARGAE|DV9_UF|DV9_FAIXAP|DV9_UFERMS|DV9_PERUFE|"} )
Else
	oStruDV92 := FWFormStruct( 2, "DV9", {|cCampo| AllTrim(cCampo)+"|" $ "DV9_TARIFA|DV9_TIPCAR|DV9_DESCAR|DV9_VALOR|DV9_TIPVAL|DV9_ICBASE|DV9_PERCEN|DV9_CARGAE|"} )
EndIf

oView:= FWFormView():New()
oView:SetModel(oModel)

If lDV9TIPCAR
	oView:AddField( "VIEW_DV91", oStruDV91, "DV9MASTER")
	oView:AddGrid ( "VIEW_DV92", oStruDV92, "DV9DETAIL")
	If lDMC
		oView:AddGrid ( "VIEW_DV93", oStruDV93, "DV9DETIND")
	EndIf

	If lDMC
		oView:CreateHorizontalBox("CABECALHO", 10)
		oView:CreateHorizontalBox("GRID"	 , 60)
		oView:CreateHorizontalBox("INDICE"	 , 30)
	Else
		oView:CreateHorizontalBox("CABECALHO", 10)
		oView:CreateHorizontalBox("GRID"	 , 90)
	EndIf

	oView:SetOwnerView("VIEW_DV91", "CABECALHO")
	oView:SetOwnerView("VIEW_DV92", "GRID"     )

	If lDMC
		oView:SetOwnerView("VIEW_DV93", "INDICE"   )
	EndIf
Else
	oView:AddField( "VIEW_DV91", oStruDV92, "DV9MASTER")
	oView:CreateHorizontalBox("CABECALHO", 100)
	oView:SetOwnerView("VIEW_DV91", "CABECALHO")
EndIf
	oView:AddIncrementField( 'VIEW_DV92', 'DV9_TARIFA' )
Return(oView)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณA545Vld   ณ Autor ณVendas Clientes        ณ Data ณ07/09/2013 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณEsta funcao valida o campo Informado                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณNenhum                                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณNenhum                                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณSIGATMS                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function A545Vld()
Local aAreaAnt  := GetArea()
Local oModel    := FWModelActive()
Local oModelDV9 := oModel:GetModel("DV9DETAIL")
Local nOpc      := oModel:GetOperation()
Local cVar      := If(!(Type("__ReadVar")=="U"),__ReadVar,"")
Local lRet      := .T.
Local cTipCar   := ""
Local cDesCar   := ""
Local nTarifa   := 0

If ValType(lDV9TIPCAR) == "U"
	lDV9TIPCAR := DV9->(ColumnPos("DV9_TIPCAR")) > 0
EndIf

If cVar == "M->DV9_KM"
	If nOpc == MODEL_OPERATION_INSERT // Se for inclusao
		If lDV9TIPCAR
			DV9->(dbSetOrder(2)) //DV9_FILIAL+STR(DV9_KM,7,0)+DV9_TIPCAR
			If DV9->(dbSeek(xFilial("DV9")+STR(FwFldGet("DV9_KM"),7,0)))
				lRet := .F.
			EndIf
		EndIf
	EndIf
ElseIf cVar == "M->DV9_TARIFA"
	nTarifa := Val(M->DV9_TARIFA)
	If nTarifa == 0
		nTarifa := 1
	EndIf
	M->DV9_TARIFA := StrZero(nTarifa,Len(DV9->DV9_TARIFA))
	oModelDV9:SetValue("DV9_TARIFA", M->DV9_TARIFA)
ElseIf cVar == "M->DV9_TIPCAR"
	cTipCar   := oModelDV9:GetValue("DV9_TIPCAR")
	cDesCar := Posicione("DB0",1,xFilial("DB0")+cTipCar,"DB0_DESMOD")
	If DB0->(EOF())
		lRet := .F.
	Else
		M->DV9_DESCAR := cDesCar
		oModelDV9:SetValue("DV9_DESCAR", cDesCar)
	EndIf
ElseIf cVar == "M->DV9_UFERMS"
	If oModelDV9:GetValue("DV9_UFERMS") = '2'
		If oModelDV9:GetValue("DV9_TIPVAL") $ '2/3/4/5'
			Help('',1,'MATA54502') //Op็ใo nใo Disponํvel para o calculo do UFERMS.			
			lRet := .F.
		EndIf
	EndIf
ElseIf cVar == "M->DV9_TIPVAL"
	If oModelDV9:GetValue("DV9_UFERMS") = '2'
		If oModelDV9:GetValue("DV9_TIPVAL") $ '2/3/4/5'
			Help('',1,'MATA54502') //Op็ใo nใo Disponํvel para o calculo do UFERMS.			
			lRet := .F.
		EndIf
	EndIf

EndIf
RestArea(aAreaAnt)
Return lRet

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณa545FretePณ Autor ณVendas Clientes        ณ Data ณ07/09/2013 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณEsta funcao efetua o calculo do frete pauta.                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Modelo da Carga                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณNenhum                                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณSIGATMS                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function a545FreteP(cTipCar, cEstOri, nQtdEixo)

Default cTipCar	:= ""
Default cEstOri	:= ""
Default nQtdEixo:= ""

If ExistFunc("TMSXFreteP")
	TMSXFreteP(cTipCar, cEstOri, nQtdEixo)	
EndIf

Return Nil


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    CommitMdl Autor ณ Felipe Barbiere          ณ Data ณ01/03/2021 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณEsta funcao efetua o commit do modelo                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Modelo da Carga                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณNenhum                                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณSIGATMS                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function CommitMdl(oModel)

Begin Transaction

	FwFormCommit(oModel/*oModel*/,/*bBefore*/,/*bAfter*/,/*bAfterSTTS*/)
		
End Transaction

Return .T.

//-------------------------------------------------------------------
/* PosVldMdl
Fun็ใo A545PosVld (Tudo Ok) 
@author  Felipe Barbiere
@since   01/03/2021
@version 1.0      
*/
//-------------------------------------------------------------------
Static Function A545PosVld(oModel)
Local lDMC			:= AliasIndic("DMC")
Local oModelDMD     := IIf(lDMC, oModel:GetModel("DV9DETIND"), '')
Local nOperation	:= oModel:GetOperation()
Local lRet          := .T.
Local nCntFor1      := 0

If lDMC .And. (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)
	For nCntFor1 := 1 To oModelDMD:Length()
		If lRet .And. !oModelDMD:IsDeleted() .And. !Empty(oModelDMD:GetValue("DMD_INDICE",nCntFor1)) .And. Empty(oModelDMD:GetValue("DMD_OPERAD",nCntFor1))			
			Help('',1,'MATA54501') //Preenchimento do campo Operador (DMD_OPERAD) obrigat๓rio quando preenchido o campo อndice (DMD_INDICE).			
			lRet := .F.		
		EndIf
	Next nCntFor1
EndIf

Return lRet
