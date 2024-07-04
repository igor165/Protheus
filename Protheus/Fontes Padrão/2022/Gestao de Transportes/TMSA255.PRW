#Include "TMSA255.CH"
#Include "Protheus.ch"
#Include "FWMVCDEF.ch" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ModelDef   ³ Autor ³ Valdemar Roberto  ³ Data ³ 05.05.2016 ³±±
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
Local oStruCDTY := Nil
Local oStruIDJC := Nil

oStruCDTY := FwFormStruct(1,"DTY",{|x| AllTrim(x) $ "DTY_FILORI,DTY_VIAGEM,DTY_NUMCTC,DTY_DATCTC,DTY_HORCTC,DTY_CODFOR,DTY_LOJFOR,DTY_NOMFOR"})
oStruIDJC := FwFormStruct(1,"DJC")

oModel := MPFormModel():New("TMSA255",/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/)
oModel:SetDescription(STR0001) //-- "Consulta Custo dos Documentos da Viagem"

//-- Campos dos documentos
oModel:AddFields("MdFieldCDTY",/*cOwner*/,oStruCDTY,/*bPre*/,/*bPost*/,/*bLoad*/)

oModel:SetPrimaryKey({"DTY_FILIAL","DTY_FILORI","DTY_VIAGEM","DTY_NUMCTC"})

//-- Viagens dos documentos
oModel:AddGrid("MdGridIDJC","MdFieldCDTY" /*cOwner*/,oStruIDJC,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridIDJC",{{"DJC_FILIAL","xFilial('DJC')"},;
								 {"DJC_FILORI","DTY_FILORI"},;
								 {"DJC_VIAGEM","DTY_VIAGEM"},;
								 {"DJC_NUMCTC","DTY_NUMCTC"}},;
								 DJC->(IndexKey(1)))

oModel:GetModel("MdGridIDJC"):SetUseOldGrid(.F.)

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ViewDef    ³ Autor ³ Valdemar Roberto  ³ Data ³ 05.05.2016 ³±±
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
Local oModel 	:= FwLoadModel("TMSA255")
Local oView 	:= Nil
Local oStruCDTY := Nil
Local oStruIDJC := Nil

oStruCDTY := FwFormStruct(2,"DTY",{|x| AllTrim(x) $ "DTY_FILORI,DTY_VIAGEM,DTY_NUMCTC,DTY_DATCTC,DTY_HORCTC,DTY_CODFOR,DTY_LOJFOR,DTY_NOMFOR"})
oStruIDJC := FwFormStruct(2,"DJC")

oStruIDJC:RemoveField("DJC_FILORI")
oStruIDJC:RemoveField("DJC_VIAGEM")
oStruIDJC:RemoveField("DJC_NUMCTC")

oView := FwFormView():New()
oView:SetModel(oModel)

oView:CreateHorizontalBox("Superior",050)
oView:CreateHorizontalBox("Inferior",050)

oView:AddField("VwFieldCDTY",oStruCDTY,"MdFieldCDTY")

oView:AddGrid("VwGridIDJC",oStruIDJC,"MdGridIDJC")

oView:EnableTitleView("VwFieldCDTY",STR0002) //-- "Dados do Contrato"
oView:EnableTitleView("VwGridIDJC" ,STR0003) //-- "Documentos do Contrato"

oView:SetOwnerView("VwFieldCDTY","Superior")
oView:SetOwnerView("VwGridIDJC","Inferior")

oView:SetViewProperty("VwGridIDJC", "ENABLENEWGRID")

Return oView
