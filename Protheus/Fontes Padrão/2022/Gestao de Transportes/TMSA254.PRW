#Include "TMSA254.CH"
#Include "Protheus.ch"
#Include "FWMVCDEF.ch" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ModelDef   ³ Autor ³ Valdemar Roberto  ³ Data ³ 05.04.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Define modelo para consulta da tabela DJC em MVC           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ModelDef()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ModelDef()
Local oModel	:= Nil
Local oStruCDT6 := Nil
Local oStruIDJC := Nil

oStruCDT6 := FwFormStruct(1,"DT6",{|x| AllTrim(x) $ "DT6_FILDOC,DT6_DOC,DT6_SERIE"})
oStruIDJC := FwFormStruct(1,"DJC")

oModel := MPFormModel():New("TMSA254",/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/)
oModel:SetDescription(STR0001) //-- "Consulta Custo dos Documentos"

//-- Campos dos documentos
oModel:AddFields("MdFieldCDT6",/*cOwner*/,oStruCDT6,/*bPre*/,/*bPost*/,/*bLoad*/)

oModel:SetPrimaryKey({"DT6_FILIAL","DT6_FILDOC","DT6_DOC","DT6_SERIE"})

//-- Viagens dos documentos
oModel:AddGrid("MdGridIDJC","MdFieldCDT6" /*cOwner*/,oStruIDJC,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridIDJC",{{"DJC_FILIAL","xFilial('DJC')"},;
								 {"DJC_FILDOC","DT6_FILDOC"},;
								 {"DJC_DOC","DT6_DOC"},;
								 {"DJC_SERIE","DT6_SERIE"}},;
								 DJC->(IndexKey(1)))

oModel:GetModel("MdGridIDJC"):SetUseOldGrid(.F.)

oModel:AddCalc("TMSA254TOT","MdFieldCDT6","MdGridIDJC","DJC_VLRCST",STR0004,"SUM") //--Custo Total Doc.

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ViewDef    ³ Autor ³ Valdemar Roberto  ³ Data ³ 05.04.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Define tela para consulta da tabela DJC em MVC             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ViewDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ViewDef()
Local oModel 	:= FwLoadModel("TMSA254")
Local oView 	:= Nil
Local oStruCDT6 := Nil
Local oStruIDJC := Nil
Local oCalc := Nil

oStruCDT6 := FwFormStruct(2,"DT6",{|x| AllTrim(x) $ "DT6_FILDOC,DT6_DOC,DT6_SERIE"})
oStruIDJC := FwFormStruct(2,"DJC")
oCalc 		:= FwCalcStruct( oModel:GetModel( "TMSA254TOT" ) )

oStruIDJC:RemoveField("DJC_FILDOC")
oStruIDJC:RemoveField("DJC_DOC")
oStruIDJC:RemoveField("DJC_SERIE")

oView := FwFormView():New()
oView:SetModel(oModel)

oView:CreateHorizontalBox("Superior",35)
oView:CreateHorizontalBox("Inferior",50)
oView:CreateHorizontalBox("Totais",15)

oView:AddField("VwFieldCDT6",oStruCDT6,"MdFieldCDT6")
oView:AddGrid("VwGridIDJC",oStruIDJC,"MdGridIDJC")
oView:AddField("VwFieldCalc",oCalc,"TMSA254TOT")

oView:EnableTitleView("VwFieldCDT6",STR0002) //--"Dados do Documento" 
oView:EnableTitleView("VwGridIDJC", STR0003) //--"Viagens do Documento"

oView:SetOwnerView("VwFieldCDT6","Superior")
oView:SetOwnerView("VwGridIDJC","Inferior")
oView:SetOwnerView("VwFieldCalc","Totais")

oView:SetViewProperty("VwGridIDJC", "ENABLENEWGRID")

Return oView
