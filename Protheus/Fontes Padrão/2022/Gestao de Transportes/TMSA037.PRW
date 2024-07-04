#Include "Protheus.ch"
#Include "FWMVCDEF.ch" 
#Include "TMSA037.ch"

/*
-----------------------------------------------------------
{Protheus.doc} TMSA037()
Consulta Chave CTE Subcontratação - ModelDef

Uso: SIGATMS

@sample
//TMSA037()

@author Rafael Souza
@since 01/02/2019
@version 1.0
-----------------------------------------------------------
*/

Static Function ModelDef()
Local oModel	:= Nil
Local oStruDT6  := Nil
Local oStruIDLR := Nil

oStruDT6 := FwFormStruct(1,"DT6",{|x| AllTrim(x) $ "DT6_FILDOC,DT6_DOC,DT6_SERIE"})
oStruIDLR := FwFormStruct(1,"DLR")

oModel := MPFormModel():New("TMSA037",/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/)
oModel:SetDescription(STR0001) //-- "Consulta Chave CTE Subcontratação"

//-- Campos dos documentos
oModel:AddFields("MdFieldDT6",/*cOwner*/,oStruDT6,/*bPre*/,/*bPost*/,/*bLoad*/)

oModel:SetPrimaryKey({"DT6_FILIAL","DT6_FILDOC","DT6_DOC","DT6_SERIE"})

//-- Viagens dos documentos
oModel:AddGrid("MdGridIDLR","MdFieldDT6" /*cOwner*/,oStruIDLR,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridIDLR",{{"DLR_FILIAL","xFilial('DLR')"},;
								 {"DLR_FILDOC","DT6_FILDOC"},;
								 {"DLR_DOC","DT6_DOC"},;
								 {"DLR_SERIE","DT6_SERIE"}},;
								 DLR->(IndexKey(1)))

oModel:GetModel("MdGridIDLR"):SetUseOldGrid(.F.)


Return oModel

/*
-----------------------------------------------------------
{Protheus.doc} TMSA037()
Consulta Chave CTE Subcontratação - ViewDef

Uso: SIGATMS

@sample
//TMSA037()

@author Rafael Souza
@since 01/02/2019
@version 1.0
-----------------------------------------------------------
*/

Static Function ViewDef()
Local oModel 	:= FwLoadModel("TMSA037")
Local oView 	:= Nil
Local oStruDT6 := Nil
Local oStruIDLR:= Nil

oStruDT6 := FwFormStruct(2,"DT6",{|x| AllTrim(x) $ "DT6_FILDOC,DT6_DOC,DT6_SERIE"})
oStruIDLR := FwFormStruct(2,"DLR")


oView := FwFormView():New()
oView:SetModel(oModel)

oStruIDLR:RemoveField("DLR_FILDOC")
oStruIDLR:RemoveField("DLR_DOC")
oStruIDLR:RemoveField("DLR_SERIE")

oView:CreateHorizontalBox("Superior",35)
oView:CreateHorizontalBox("Inferior",65)

oView:AddField("VwFieldDT6",oStruDT6,"MdFieldDT6")
oView:AddGrid("VwGridIDLR",oStruIDLR,"MdGridIDLR")

oView:EnableTitleView("VwFieldDT6", STR0002) //--"Dados do Documento" 
oView:EnableTitleView("VwGridIDLR", STR0003) //--"Chave do CT-e Contratante"

oView:SetOwnerView("VwFieldDT6","Superior")
oView:SetOwnerView("VwGridIDLR","Inferior")

oView:SetViewProperty("VwGridIDLR", "ENABLENEWGRID")

Return oView
