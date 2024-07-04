#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "GPEA111ARG.CH"
 
Static cTitulo := STR0001

Function GPEA111ARG()
    Local aArea   := GetArea()
    Local oBrowse
     
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("SRA")
    oBrowse:SetDescription(cTitulo)
    oBrowse:Activate()
     
    RestArea(aArea)
Return Nil
 

 
Static Function MenuDef()
    Local aRot := {}
     
    ADD OPTION aRot TITLE STR0002 ACTION 'VIEWDEF.GPEA111ARG' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
 
Return aRot
 
Static Function ModelDef()

		Local bAvalCampo          := {|cCampo| AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_NASC|"}

    Local oModel        := Nil
    Local oStPai        := FWFormStruct(1, 'SRA',bAvalCampo,)
    Local oStFilho  		:= FWFormStruct(1, 'SR9')
    Local aSR9Rel       := {}
     
    oModel := MPFormModel():New('GPEA111ARG')
    oModel:AddFields('SRAMASTER',/*cOwner*/,oStPai)
    oModel:AddGrid('SR9DETAIL','SRAMASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
     
    aAdd(aSR9Rel, {'R9_FILIAL', 'RA_FILIAL'} )
    aAdd(aSR9Rel, {'R9_MAT',  'RA_MAT'}) 
     
    oModel:SetRelation('SR9DETAIL', aSR9Rel, SR9->(IndexKey(1)))
    oModel:GetModel('SR9DETAIL'):SetUniqueLine({"R9_MAT","R9_CAMPO"})  //Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
    oModel:SetPrimaryKey({})
     
    oModel:SetDescription(STR0003)
    oModel:GetModel('SRAMASTER'):SetDescription(STR0004)
    oModel:GetModel('SR9DETAIL'):SetDescription(STR0005)
Return oModel
 
Static Function ViewDef()
		Local bAvalCampo          := {|cCampo| AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_NASC|"}
	
    Local oView     := Nil
    Local oModel        := FWLoadModel('GPEA111ARG')
    Local oStPai        := FWFormStruct(2, 'SRA',bAvalCampo)
    Local oStFilho  := FWFormStruct(2, 'SR9')
     
    //Criando a View
    oView := FWFormView():New()
    oView:SetModel(oModel)
   
    //Adicionando os campos do cabeçalho e o grid dos filhos
    oView:AddField('VIEW_SRA',oStPai,'SRAMASTER')
    oView:AddGrid('VIEW_SR9',oStFilho,'SR9DETAIL')
    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CABEC',20)
    oView:CreateHorizontalBox('GRID',80)
     
    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_SRA','CABEC')
    oView:SetOwnerView('VIEW_SR9','GRID')

Return oView