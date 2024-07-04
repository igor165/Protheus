#INCLUDE "TECA011A.CH"
#INCLUDE "Protheus.CH"
#INCLUDE "FWMVCDEF.CH"
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA011A()

Caracteristicas do atendente

/*/
//----------------------------------------------------------------------------------------------------------------------
Function TECA011A()

Local oBrowse

Private aRotina 	:= MenuDef() 
Private cCadastro	:= STR0001 //"Características do Atendente"
 
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('AA1')
oBrowse:SetDescription(STR0001) //"Características do Atendente"
oBrowse:Activate()

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

Definição do MenuDef

@return ExpO:aRotina
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw' 		   OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TECA011A' OPERATION 4 ACCESS 0 //"Manutenção"

Return (aRotina)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Definição do Model 

@return ExpO:oModel
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStruAA1	:= FWFormStruct(1,'AA1',{|cCampo| AllTrim(cCampo)+"|" $ "AA1_CODTEC|AA1_NOMTEC|"})
Local oStruTDU 	:= FWFormStruct(1,'TDU')
Local aAux := {}
oModel := MPFormModel():New('TECA011A',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)

oModel:AddFields('AA1MASTER',/*cOwner*/,oStruAA1,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/,/*bFieldAbp*/)
oStruAA1:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
oStruTDU:SetProperty("TDU_CODTEC", MODEL_FIELD_OBRIGAT, .F.)

aAux := FwStruTrigger("TDU_CODTCZ","TDU_DESTCZ","Posicione('TCZ',1,xFilial('TCZ')+M->TDU_CODTCZ,'TCZ_DESC')",.F.,Nil,Nil,Nil)
oStruTDU:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

oModel:AddGrid( 'TDUGRID','AA1MASTER',oStruTDU,/*bPreValidacao*/,/*bLinePost*/,/*bCarga*/,/*bPost*/,/*bLoadABU*/)

oModel:SetRelation("TDUGRID",{{"TDU_FILIAL",'xFilial("TDU")'},{"TDU_CODTEC","AA1_CODTEC"}},TDU->(IndexKey(2)))

oModel:GetModel("TDUGRID"):SetUniqueLine({"TDU_CODTCZ"})

oModel:GetModel('AA1MASTER'):SetOnlyView(.T.)
oModel:GetModel('AA1MASTER'):SetOnlyQuery(.T.)
oModel:GetModel('TDUGRID'):SetOptional(.T.)

oModel:SetDescription(STR0001) //"Características do Atendente"

Return(oModel)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

Definição da View 

@return ExpO:oView
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel   	:= FWLoadModel('TECA011A')
Local oStruAA1 	:= FWFormStruct(2,'AA1',{|cCampo| AllTrim(cCampo)+"|" $ "AA1_CODTEC|AA1_NOMTEC|"})
Local oStruTDU	:= FWFormStruct(2,'TDU')
Local oMdlGrid	:= oModel:GetModel('TDUGRID')

oStruAA1:SetNoFolder()

oStruTDU:RemoveField("TDU_COD")					 
oStruTDU:RemoveField("TDU_CODTEC")

oView:= FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_CAB',oStruAA1,'AA1MASTER')
oView:AddGrid('VIEW_GRID',oStruTDU,'TDUGRID' )
 
oView:CreateHorizontalBox('SUPERIOR',25)
oView:CreateHorizontalBox('INFERIOR',75)

oView:SetOwnerView( 'VIEW_CAB','SUPERIOR' )
oView:SetOwnerView( 'VIEW_GRID','INFERIOR' )

Return(oView)