#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA230.CH"

/*/{Protheus.doc} VEIA230
	Cadastro Troca de Frota dos Clientes

	@author Andre Luis Almeida
	@since 18/01/2021
/*/
Function VEIA230()

Local oVEIA230
Local oTPanSA1
Local oTPanVK3
Local aSize     := FWGetDialogSize( oMainWnd )

cCadastro := STR0001 // Troca de Frota dos Clientes

oVEIA230 := MSDIALOG() :New(aSize[1],aSize[2],aSize[3],aSize[4],STR0001,,,,128,,,,,.t.) // Troca de Frota dos Clientes

	oTPanSA1 := TPanel():New(0,0,"",oVEIA230,NIL,.T.,.F.,NIL,NIL,100,(oVEIA230:nClientHeight/4)-10,.F.,.F.)
	oTPanSA1:Align := CONTROL_ALIGN_TOP

	oTPanVK3 := TPanel():New(0,0,"",oVEIA230,NIL,.T.,.F.,NIL,NIL,100,(oVEIA230:nClientHeight/4)-10,.F.,.F.)
	oTPanVK3:Align := CONTROL_ALIGN_BOTTOM 

	oBrwSA1 := FWMBrowse():New()
	oBrwSA1:SetAlias('SA1')
	oBrwSA1:SetOwner(oTPanSA1)
	oBrwSA1:SetDescription(STR0002) // Clientes
	oBrwSA1:AddFilter(STR0003,"@ EXISTS (SELECT VK3.R_E_C_N_O_ FROM " + RetSQLName("VK3") + " VK3 WHERE VK3.VK3_FILIAL = A1_FILIAL AND VK3.VK3_CODCLI = A1_COD AND VK3.VK3_LOJCLI = A1_LOJA AND VK3.D_E_L_E_T_ = ' ') ",.f.,.f.,) // Clientes COM Troca de Frota Cadastrada
	oBrwSA1:AddFilter(STR0004,"@ NOT EXISTS (SELECT VK3.R_E_C_N_O_ FROM " + RetSQLName("VK3") + " VK3 WHERE VK3.VK3_FILIAL = A1_FILIAL AND VK3.VK3_CODCLI = A1_COD AND VK3.VK3_LOJCLI = A1_LOJA AND VK3.D_E_L_E_T_ = ' ') ",.f.,.f.,) // Clientes SEM Troca de Frota Cadastrada
	oBrwSA1:DisableReport()
	oBrwSA1:DisableDetails()
	oBrwSA1:ForceQuitButton()
	oBrwSA1:Activate()

	oBrwVK3 := FWMBrowse():New()
	oBrwVK3:SetAlias('VK3')
	oBrwVK3:SetOwner(oTPanVK3)
	oBrwVK3:SetMenuDef('')
	oBrwVK3:SetDescription(STR0005) // Media de Anos para Troca da Frota
	oBrwVK3:DisableDetails()
	oBrwVK3:SetAmbiente(.F.)
	oBrwVK3:SetWalkthru(.F.)
	oBrwVK3:SetUseFilter()
	oBrwVK3:Activate()

	oRelacVK3:= FWBrwRelation():New() 
	oRelacVK3:AddRelation( oBrwSA1 , oBrwVK3 , { { "VK3_FILIAL" , "A1_FILIAL" }, { "VK3_CODCLI" , "A1_COD" }, { "VK3_LOJCLI" , "A1_LOJA" } }) 
	oRelacVK3:Activate()

oVEIA230:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.VEIA230' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0007 Action 'VIEWDEF.VEIA230' OPERATION 4 ACCESS 0 // Incluir/Alterar/Excluir a Média de Anos
	ADD OPTION aRotina TITLE STR0008 ACTION 'VEIC090( .f. , "" , SA1->A1_COD , SA1->A1_LOJA , "" , "" , "" )'	OPERATION 2 ACCESS 0 // Consultar Frota do Cliente/Loja
	ADD OPTION aRotina TITLE STR0009 ACTION 'VEIC090( .f. , "" , SA1->A1_COD , "" , "" , "" , "" )'				OPERATION 2 ACCESS 0 // Consultar Frotas Individualizadas do Cliente (todas Lojas)
	ADD OPTION aRotina TITLE STR0010 ACTION 'VEIC090( .t. , "" , SA1->A1_COD , "" , "" , "" , "" )'				OPERATION 2 ACCESS 0 // Consultar Frotas Agrupadas do Cliente (todas Lojas)

Return aRotina

Static Function ModelDef()
Local oModel
Local oStrTmp := FWFormModelStruct():New()
Local oStrVK3 := FWFormStruct(1, "VK3")

oStrTmp:AddTable("SA1",{'A1_COD','A1_LOJA','A1_NOME'},STR0011) // Cliente

oStrTmp:AddField(STR0012,STR0012, "A1_COD" , "C", GetSX3Cache("A1_COD","X3_TAMANHO")  , 0,, ,{},.t., , .T.,.F.,.F.) // Codigo Cliente
oStrTmp:AddField(STR0013,STR0013, "A1_LOJA", "C", GetSX3Cache("A1_LOJA","X3_TAMANHO") , 0,, ,{},.t., , .T.,.F.,.F.) // Loja Cliente
oStrTmp:AddField(STR0014,STR0014, "A1_NOME", "C", GetSX3Cache("A1_NOME","X3_TAMANHO") , 0,, ,{},.t., , .T.,.F.,.F.) // Nome Cliente

oModel := MPFormModel():New('VEIA230',,,,)

oStrTmp:SetProperty("A1_COD" , MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD,'SA1->A1_COD'))
oStrTmp:SetProperty("A1_LOJA", MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD,'SA1->A1_LOJA'))
oStrTmp:SetProperty("A1_NOME", MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD,'SA1->A1_NOME'))

oStrVK3:SetProperty("VK3_CODCLI", MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD,'SA1->A1_COD'))
oStrVK3:SetProperty("VK3_LOJCLI", MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD,'SA1->A1_LOJA'))
oStrVK3:SetProperty("VK3_NOMCLI", MODEL_FIELD_INIT , FWBuildFeature( STRUCT_FEATURE_INIPAD,'SA1->A1_NOME'))

oModel:AddFields('TMPMASTER',/*cOwner*/ , oStrTmp)
oModel:AddGrid("VK3DETAIL","TMPMASTER",oStrVK3)
oModel:SetRelation( 'VK3DETAIL', { { 'VK3_FILIAL', 'xFilial( "VK3" )' }, { 'VK3_CODCLI', 'SA1->A1_COD' }, { 'VK3_LOJCLI', 'SA1->A1_LOJA' } }, VK3->( IndexKey( 1 ) ) )
oModel:SetPrimaryKey( {} )

oModel:GetModel( 'VK3DETAIL' ):SetOptional(.T.) // Permite deixar o em branco a grid filho

oModel:GetModel('TMPMASTER'):SetDescription( STR0011 ) // Cliente
oModel:GetModel('VK3DETAIL'):SetDescription( STR0005 ) // Media de Anos para Troca da Frota

oModel:AddRules( 'VK3DETAIL', 'VK3_GRUMOD', 'VK3DETAIL', 'VK3_CODMAR', 3)

oModel:GetModel( 'VK3DETAIL' ):SetUniqueLine( { "VK3_CODMAR", "VK3_GRUMOD" } )

Return oModel

Static Function ViewDef()

Local oView
Local oModel  := ModelDef()
Local oStrTmp := FWFormViewStruct():New()
Local oStrVK3 := FWFormStruct(2, "VK3" , { |cCampo| !ALLTRIM(cCampo) $ "VK3_FILIAL/VK3_CODCLI/VK3_LOJCLI/VK3_NOMCLI" } )

oView := FWFormView():New()

oView:SetModel(oModel)

oStrTmp:AddField("A1_COD" ,"01",STR0012,STR0012,, "C","@!" , ,,.f.,,,,,,,,) // Codigo Cliente
oStrTmp:AddField("A1_LOJA","02",STR0013,STR0013,, "C","@!" , ,,.f.,,,,,,,,) // Loja Cliente
oStrTmp:AddField("A1_NOME","03",STR0014,STR0014,, "C","@!" , ,,.f.,,,,,,,,) // Nome Cliente

oView:CreateHorizontalBox( 'BOXTMP', 25)
oView:AddField('VIEW_TMP', oStrTMP, 'TMPMASTER')
oView:EnableTitleView('VIEW_TMP', STR0011 ) // Cliente
oView:SetOwnerView('VIEW_TMP','BOXTMP')

oView:CreateHorizontalBox( 'BOXVK3', 75)
oView:AddGrid("VIEW_VK3",oStrVK3, 'VK3DETAIL')
oView:EnableTitleView('VIEW_VK3', STR0005 ) // Media de Anos para Troca da Frota
oView:SetOwnerView('VIEW_VK3','BOXVK3')

Return oView