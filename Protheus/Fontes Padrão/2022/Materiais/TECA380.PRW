#INCLUDE "TECA380.CH"
#INCLUDE "Protheus.CH"
#INCLUDE "FWMVCDEF.CH"
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA380()

Região de Atendimento do Atendente - ABU

/*/
//----------------------------------------------------------------------------------------------------------------------
Function TECA380()

Local oBrowse

Private aRotina 	:= MenuDef() 
Private cCadastro	:= STR0001 //"Cadastro de Região de Atendimento"
 
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('ABU')
oBrowse:SetDescription(STR0001) // Cadastro de Região de Atendimento
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

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw' 		 OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TECA380' OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.TECA380' OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.TECA380' OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.TECA380' OPERATION 5 ACCESS 0 //"Excluir"

Return (aRotina)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Definição do Model 

@return ExpO:oModel
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStruABU		:= FWFormStruct(1,'ABU',{|cCampo| AllTrim(cCampo)+"|" $ "ABU_CODTEC|ABU_NOMTEC|"})
Local oStruGrid  	:= FWFormStruct(1,'ABU')
Local aAux			:= {}
Local aAux1			:= {}

oStruGrid:RemoveField("ABU_CODTEC")
oStruGrid:RemoveField("ABU_NOMTEC")

//Inicializa a descrição da região selecionada, somente no momento da carga dos itens
oStruGrid:SetProperty("ABU_DESREG",MODEL_FIELD_INIT,{|| TA380InitDes() })

aAux := FwStruTrigger("ABU_CODTEC","ABU_NOMTEC","TA380Atend()",.F.,Nil,Nil,Nil)
oStruABU:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux1 := FwStruTrigger("ABU_REGIAO","ABU_DESREG","TA380Regiao()",.F.,Nil,Nil,Nil)
oStruGrid:AddTrigger(aAux1[1],aAux1[2],aAux1[3],aAux1[4])

oModel := MPFormModel():New('TECA380',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)

oModel:AddFields('ABUMASTER',/*cOwner*/,oStruABU,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/,/*bFieldAbp*/)
oModel:AddGrid( 'ABUGRID','ABUMASTER',oStruGrid,/*bPreValidacao*/,/*bLinePost*/,/*bCarga*/,/*bPost*/,/*bLoadABU*/)

oModel:SetRelation("ABUGRID",{{"ABU_FILIAL",'xFilial("ABU")'},{"ABU_CODTEC","ABU_CODTEC"}},ABU->(IndexKey(1)))

oModel:GetModel("ABUGRID"):SetUniqueLine({"ABU_REGIAO"})

oModel:SetPrimaryKey({"ABU_FILIAL","ABU_CODTEC"}) 

Return(oModel)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

Definição da View 

@return ExpO:oView
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel   	:= FWLoadModel('TECA380')
Local oStruABU 	:= FWFormStruct(2,'ABU',{|cCampo| AllTrim(cCampo)+"|" $ "ABU_CODTEC|ABU_NOMTEC|"})
Local oStruGrid	:= FWFormStruct(2,'ABU')
Local oMdlGrid	:= oModel:GetModel('ABUGRID')
					 
oStruGrid:RemoveField("ABU_CODTEC")
oStruGrid:RemoveField("ABU_NOMTEC")

oView:= FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_CAB',oStruABU,'ABUMASTER')
oView:AddGrid('VIEW_GRID',oStruGrid,'ABUGRID' )
oView:AddIncrementField('VIEW_GRID','ABU_ITEM')
 
oView:CreateHorizontalBox('SUPERIOR',10)
oView:CreateHorizontalBox('INFERIOR',90)

oView:SetOwnerView( 'VIEW_CAB','SUPERIOR' )
oView:SetOwnerView( 'VIEW_GRID','INFERIOR' )

Return(oView)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TA380Atend()

Trigger para a descrição do atendente

@return ExpC:cNome
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TA380Atend()

Local cNome 	:= ""
Local oMdl 		:= FwModelActive()
Local oMdlABU	:= oMdl:GetModel("ABUMASTER")

cNome := Alltrim( Posicione("AA1",1,xFilial("AA1")+oMdlABU:GetValue("ABU_CODTEC"),"AA1_NOMTEC") )

Return(cNome)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TA380Regiao()

Trigger para a descrição da região de atendimento

@return ExpC:cNome
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TA380Regiao()

Local cNome 	:= ""
Local oMdl 		:= FwModelActive()
Local oMdlABU	:= oMdl:GetModel("ABUGRID")

cNome := Alltrim( Posicione("SX5",1,xFilial("SX5")+"A2"+oMdlABU:GetValue("ABU_REGIAO"),"X5_DESCRI") )

Return(cNome)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TA380InitDes()

Inicializa a descrição da regiao

@sample 	TA380IniItDes() 
@since		05/09/2013       
@version	P11.80
@return 	cDescricao, CHARACTER, conteúdo da descrição 
/*/
//--------------------------------------------------------------------------------------------------------------------

Function TA380InitDes()

Local cNome    := ""
Local oMdl 	 := FwModelActive()
Local oMdlGrid := Nil

If oMdl:GetId()=="TECA380"
	
	oMdlGrid := oMdl:GetModel( "ABUGRID" )	
	
	If oMdlGrid:GetOperation()!=MODEL_OPERATION_INSERT .And. oMdlGrid:GetLine()==0
		cNome := Alltrim( Posicione("SX5",1,xFilial("SX5")+"A2"+ABU->ABU_REGIAO,"X5_DESCRI") )			     		
	EndIf

EndIf

Return(cNome)