#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWBROWSE.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "CRMA910.CH"

Static _oTree	 := Nil
Static lAliasAZL := Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Monta modelo de dados do Regras de Comercialização.
@sample		CRMA910()
@param		Nenhum
@return		ExpO - Array com niveis selecionados
@author		SI2901 - Cleyton F.Alves
@since		11/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA910()
	
Local oBrowse	:= Nil

AZ0->(dbSetOrder(1))
AZ1->(dbSetOrder(1))
AZ2->(dbSetOrder(1))

If lAliasAZL == Nil
	lAliasAZL := AliasInDic("AZL")
EndIf

If lAliasAZL
	AZL->(dbSetOrder(1))
EndIf

If lAliasAZL
	AZP->(dbSetOrder(1))
EndIf

AO3->(dbSetOrder(1))
ACA->(dbSetOrder(1))

oBrowse:=FWMBrowse():New()
oBrowse:SetCanSaveArea(.T.) 
oBrowse:SetAlias('AOL')
oBrowse:SetDescription(STR0001) //"Regras de Comercialização"
oBrowse:DisableReport()
oBrowse:SetMenuDef('CRMA910')
oBrowse:SetFilterDefault("AOL_MSBLQL <> '1' .And. AOL_ENTIDA == 'SB1'")
oBrowse:Activate()
	
Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MENUDEF  ³ Autor ³ Cleyton Alves         ³ Data ³ 27.04.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	
Local aRotina := {}
	
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.CRMA910" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0008 ACTION "CRMA910Update" OPERATION 4 ACCESS 0 //"Atualizar"
ADD OPTION aRotina TITLE STR0036 ACTION "CRMA580NAgru" 	  OPERATION 4 ACCESS 0 //"Níveis do Agrupador"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA910Update
Chamada para atualizar a regra de comercialização.
@sample	CRMA910Update()
@param		Nenhum
@return	ExpO - Modelo de Dados
@author	SI2901 - Cleyton F.Alves
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA910Update()

FwMsgRun( Nil,{ || FWExecView(Upper(STR0008),"CRMA910",MODEL_OPERATION_UPDATE,/*oDlg*/,/*bCloseOnOK*/,/*bOk*/,;
					 /*nPercReducao*/,/*aButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/,/*oModelAct*/) },Nil,STR0047) //"Atualizar"#"Aguarde, carregando os níveis..."
Return Nil
	
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Monta modelo de dados do Níveis do Agrupador Dinamico.
@sample		ModelDef()
@param		Nenhum
@return		ExpO - Modelo de Dados
@author		SI2901 - Cleyton F.Alves
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel 	 := Nil
Local oStructAOL := FWFormStruct(1,"AOL"  ,/*bAvalCampo*/,/*lViewUsado*/)
Local oStructAZP := Nil
Local oStructAOM := FWFormStruct(1,"AOM"  ,/*bAvalCampo*/,/*lViewUsado*/)
Local oStructAZ0 := FWFormStruct(1,"AZ0"  ,/*bAvalCampo*/,/*lViewUsado*/)

Local oStructDOT	:= FWFormStruct(1,"AZ1"  ,/*bAvalCampo*/,/*lViewUsado*/)
Local oStructUSU	:= FWFormStruct(1,"AZ2"  ,/*bAvalCampo*/,/*lViewUsado*/)
Local oStructEQU	:= FWFormStruct(1,"AZ2"  ,/*bAvalCampo*/,/*lViewUsado*/)
Local oStructNEG	:= FWFormStruct(1,"AZA"  ,/*bAvalCampo*/,/*lViewUsado*/)
Local oStructAZL	:= Nil
Local bLoadUSU	:= { || CRMA910SZ2( oModel, oModel:GetModel( "FOL_USU" ),"AO3" ) }
Local bLoadEQU	:= { || CRMA910SZ2( oModel, oModel:GetModel( "FOL_EQU" ),"ACA" ) }
Local bLoadREG	:= { || CRMA910Load( oModel, oModel:GetModel( "FOL_AZ0" ), "AZ0" ) }
Local bLoadDOT	:= { || CRMA910Load( oModel, oModel:GetModel( "FOL_DOT" ), "AZ1" ) }
Local bLoadUND	:= { || CRMA910Load( oModel, oModel:GetModel( "FOL_NEG" ), "AZA" ) }
Local bLoadOFE	:= { || CRMA910Load( oModel, oModel:GetModel( "AZLDETAIL" ), "AZL" ) }
Local lCtrlUsr	:=  ExistBlock("CRM910MDL")

If lAliasAZL == Nil
	lAliasAZL := AliasInDic("AZL")
EndIf

If lAliasAZL
	oStructAZP := FWFormStruct(1,"AZP"  ,/*bAvalCampo*/,/*lViewUsado*/)
	oStructAZL := FWFormStruct(1,"AZL"  ,/*bAvalCampo*/,/*lViewUsado*/)
EndIF

oStructUSU:SetProperty('AZ2_ENTIDA',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, "'AO3'" ))
oStructEQU:SetProperty('AZ2_ENTIDA',MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, "'ACA'" ))

oModel := MPFormModel():New("CRMA910",/*bPreValidacao*/,/*bPosVldMdl*/,/*bCommitMdl*/,/*bCancel*/)

oModel:AddFields("AOLMASTER" ,/*cOwner*/ ,oStructAOL,/*bPreValid*/,/*bPosVldMdl*/,/*bLoad*/  )
If lAliasAZL
	oModel:AddFields("AZPDETAIL" ,"AOLMASTER",oStructAZP,/*bPreValid*/,/*bPosVldMdl*/, /*bLoadAZP*/ )
EndIf
oModel:AddGrid("AOMDETAIL" ,"AOLMASTER",oStructAOM,/*bLinPre  */,/*bLinePost */,/*bPreVal*/,/*bPosVldGrid*/,/*bLoad*/)

If lAliasAZL
	oModel:AddGrid("AZLDETAIL" ,"AOMDETAIL",oStructAZL,/*bLinPre  */,/*bLinePost */,/*bPreVal*/,/*bPosVldGrid*/, bLoadOFE)
EndIf

oModel:AddGrid  ("FOL_AZ0" 	 ,"AOMDETAIL",oStructAZ0,/*bLinPre  */,/*bLinePost */,/*bPreVal*/,/*bPosVldGrid*/, bLoadREG )
oModel:AddGrid  ("FOL_DOT"   ,"AOMDETAIL",oStructDOT,/*bLinPre  */,/*bLinePost */,/*bPreVal*/,/*bPosVldGrid*/, bLoadDOT )
oModel:AddGrid  ("FOL_USU"   ,"AOMDETAIL",oStructUSU,/*bLinPre  */,/*bLinePost */,/*bPreVal*/,/*bPosVldGrid*/, bLoadUSU )
oModel:AddGrid  ("FOL_EQU"   ,"AOMDETAIL",oStructEQU,/*bLinPre  */,/*bLinePost */,/*bPreVal*/,/*bPosVldGrid*/, bLoadEQU )
oModel:AddGrid  ("FOL_NEG"   ,"AOMDETAIL",oStructNEG,/*bLinPre  */,/*bLinePost */,/*bPreVal*/,/*bPosVldGrid*/, bLoadUND)

If lAliasAZL
	oModel:SetRelation("AZPDETAIL",{{"AZP_FILIAL","xFilial('AZP')"},{"AZP_CODAGR","AOL_CODAGR"}},AZP->(IndexKey(1)))
EndIf
oModel:SetRelation("AOMDETAIL",{{"AOM_FILIAL","xFilial('AOM')"},{"AOM_CODAGR","AOL_CODAGR"}	},AOM->(IndexKey(1)))

If lAliasAZL
	oModel:SetRelation("AZLDETAIL",{{"AZL_FILIAL","xFilial('AZL')"},{"AZL_CODAGR","AOM_CODAGR"},{"AZL_CODNIV","AOM_CODNIV"}},AZL->(IndexKey(1)))
EndIF
oModel:SetRelation("FOL_AZ0"  ,{{"AZ0_FILIAL","xFilial('AZ0')"},{"AZ0_CODAGR","AOM_CODAGR"},{"AZ0_CODNIV","AOM_CODNIV"}},AZ0->(IndexKey(1)))
oModel:SetRelation("FOL_DOT"  ,{{"AZ1_FILIAL","xFilial('AZ1')"},{"AZ1_CODAGR","AOM_CODAGR"},{"AZ1_CODNIV","AOM_CODNIV"}},AZ1->(IndexKey(1)))

oModel:SetRelation("FOL_USU"  ,{{"AZ2_FILIAL","xFilial('AZ2')"},{"AZ2_CODAGR","AOM_CODAGR"},{"AZ2_CODNIV","AOM_CODNIV"}},AZ2->(IndexKey(1)))
oModel:SetRelation("FOL_EQU"  ,{{"AZ2_FILIAL","xFilial('AZ2')"},{"AZ2_CODAGR","AOM_CODAGR"},{"AZ2_CODNIV","AOM_CODNIV"}},AZ2->(IndexKey(1)))
oModel:SetRelation("FOL_NEG"  ,{{"AZA_FILIAL","xFilial('AZA')"},{"AZA_CODAGR","AOM_CODAGR"},{"AZA_CODNIV","AOM_CODNIV"}},AZA->(IndexKey(1)))

oModel:SetPrimaryKey({""})

If lAliasAZL
	oModel:GetModel("AZLDETAIL"):SetOptional(.T.)
EndIf
oModel:GetModel("FOL_AZ0"):SetOptional(.T.)
oModel:GetModel("FOL_DOT"):SetOptional(.T.)
oModel:GetModel("FOL_USU"):SetOptional(.T.)
oModel:GetModel("FOL_EQU"):SetOptional(.T.)
oModel:GetModel("FOL_NEG"):SetOptional(.T.)

If lAliasAZL
	oModel:GetModel("AZLDETAIL"):SetUniqueLine({'AZL_CODOFE'})
EndIf

oModel:GetModel("FOL_DOT"):SetUniqueLine({'AZ1_CODDOT'})
oModel:GetModel("FOL_USU"):SetUniqueLine({'AZ2_CODENT'})
oModel:GetModel("FOL_EQU"):SetUniqueLine({'AZ2_CODENT'})
oModel:GetModel("FOL_NEG"):SetUniqueLine({'AZA_COD'   })

oModel:SetDescription(STR0001) //"Regras de Comercialização"

oModel:GetModel("AOLMASTER"):SetDescription(STR0009) //"Agrupador"
If lAliasAZL
	oModel:GetModel("AZPDETAIL"):SetDescription(STR0030) //"Proposta"
EndIf
oModel:GetModel("AOMDETAIL"):SetDescription(STR0004) //"Níveis do Agrupador"
If lAliasAZL
	oModel:GetModel("AZLDETAIL"):SetDescription(STR0031)	//"Oferta"
EndIF
oModel:GetModel("FOL_AZ0"  ):SetDescription(STR0010) //"Regras"
oModel:GetModel("FOL_DOT"  ):SetDescription(STR0011) //"Arquivos .DOT"
oModel:GetModel("FOL_USU"  ):SetDescription(STR0012) //"Usuários"
oModel:GetModel("FOL_EQU"  ):SetDescription(STR0013) //"Equipes"
oModel:GetModel("FOL_NEG"  ):SetDescription(STR0014) //"Unidades de Negocio"

oStructDOT:SetProperty('AZ1_CODDOT', MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID,'ExistCpo( "AG1" )' ) )

oStructUSU:SetProperty('AZ2_CODENT', MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID,'Empty( FwFldGet( "AZ2_CODENT" ) ) .Or. AO3->( dbSeek( xFilial( "AO3" )+ FwFldGet( "AZ2_CODENT" ) ) )' ) )
oStructUSU:SetProperty('AZ2_CODENT', MODEL_FIELD_OBRIGAT, .T.)//Campo obrigatório em caso de preenchimento de usuário

oStructEQU:SetProperty('AZ2_CODENT', MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID,'Empty( FwFldGet( "AZ2_CODENT" ) ) .Or. ACA->( dbSeek( xFilial( "ACA" )+ FwFldGet( "AZ2_CODENT" ) ) )' ) )
oStructEQU:SetProperty('AZ2_CODENT', MODEL_FIELD_OBRIGAT, .T.)//Campo obrigatório em caso de preenchimento de Equipe

oStructNEG:SetProperty('AZA_COD', MODEL_FIELD_OBRIGAT, .T.)// Campo obrigatório em caso de preenchimento de Unidade de Negócio
//------------------------------------------------------------------------------
// Trigger USU
//------------------------------------------------------------------------------
aAux := FwStruTrigger(	'AZ2_CODENT'	 	 ,; 
						'AZ2_DSCENT'			 ,; 
						'AllTrim( CRMXLoadUser(AZ2->AZ2_CODENT)[4] )' ,; 
						.F.						 ,; 
						''						 ,; 
						0						 ,;  
						''						 )  

oStructUSU:AddTrigger( 	aAux[1]  , ;  // [01] identificador (ID) do campo de origem 
						aAux[2]  , ;  // [02] identificador (ID) do campo de destino 
						aAux[3]  , ;  // [03] Bloco de código de validação da execução do gatilho 
						aAux[4]  )    // [04] Bloco de código de execução do gatilho 

//------------------------------------------------------------------------------
// Trigger EQU
//------------------------------------------------------------------------------
aAux := FwStruTrigger(	'AZ2_CODENT'	  ,; 
						'AZ2_DSCENT'	  ,; 
						'ACA->ACA_DESCRI' ,; 
						.T.				  ,; 
						'ACA'			  ,; 
						1				  ,;  
						'xFilial("ACA")+M->AZ2_CODENT')  

oStructEQU:AddTrigger( 	aAux[1]  , ;  // [01] identificador (ID) do campo de origem 
						aAux[2]  , ;  // [02] identificador (ID) do campo de destino 
						aAux[3]  , ;  // [03] Bloco de código de validação da execução do gatilho 
						aAux[4]  )    // [04] Bloco de código de execução do gatilho 

If lCtrlUsr
	ExecBlock("CRM910MDL",.F.,.F.,{oModel})	
EndIf

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Monta interface do Níveis do Agrupador Dinamico.

@sample	ViewDef()
@param		Nenhum

@return	ExpO - Interface do Agrupador de Registros
@author	SI2901 - Cleyton F.Alves
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oStructAOL	:= FWFormStruct(2,"AOL",{|cCampo| AllTrim(cCampo) $ "AOL_CODAGR|AOL_RESUMO|AOL_ENTIDA|AOL_DSCENT|AOL_TIPO|"},/*lViewUsado*/)
Local oStructAZP 	:= Nil
Local oStructAOM	:= FWFormStruct(2,"AOM",/*bAvalCampo*/,/*lViewUsado*/)
Local oStructAZ0	:= FWFormStruct(2,"AZ0",/*bAvalCampo*/,/*lViewUsado*/)
Local oStructDOT	:= FWFormStruct(2,"AZ1",/*bAvalCampo*/,/*lViewUsado*/)
Local oStructUSU	:= FWFormStruct(2,"AZ2",/*bAvalCampo*/,/*lViewUsado*/)
Local oStructEQU	:= FWFormStruct(2,"AZ2",/*bAvalCampo*/,/*lViewUsado*/)
Local oStructNEG	:= FWFormStruct(2,"AZA",/*bAvalCampo*/,/*lViewUsado*/)
Local oStructAZL	:= Nil
Local oModel   		:= FWLoadModel('CRMA910')
Local oView			:= Nil
Local oPanel		:= Nil
Local aAux          := {}
Local lCtrlUsr   	:=  ExistBlock("CRM910VIEW")

If lAliasAZL == Nil
	lAliasAZL := AliasInDic("AZL")
EndIf
If lAliasAZL
	oStructAZP := FWFormStruct(2,"AZP",/*bAvalCampo*/,/*lViewUsado*/)
	oStructAZL:= FWFormStruct(2,"AZL",/*bAvalCampo*/,/*lViewUsado*/)
EndIf

oView:= FWFormView():New()
oView:SetModel(oModel)

If lAliasAZL
	oView:AddField("VIEW_AZP",oStructAZP,"AZPDETAIL")
EndIf

oView:AddGrid("VIEW_AZ0",oStructAZ0,"FOL_AZ0")
oView:AddGrid("VIEW_DOT",oStructDOT,"FOL_DOT")
oView:AddGrid("VIEW_USU",oStructUSU,"FOL_USU")
oView:AddGrid("VIEW_EQU",oStructEQU,"FOL_EQU")
oView:AddGrid("VIEW_NEG",oStructNEG,"FOL_NEG")

If lAliasAZL
	oView:AddGrid ("VIEW_AZL",oStructAZL,"AZLDETAIL")
	oStructAZP:RemoveField("AZP_CODAGR")
	
	oStructAZL:RemoveField("AZL_CODAGR")
	oStructAZL:RemoveField("AZL_CODNIV")
EndIF

oStructAZ0:RemoveField("AZ0_CODAGR")
oStructAZ0:RemoveField("AZ0_CODNIV")
oStructAZ0:RemoveField("AZ0_DESAGR")
oStructAZ0:RemoveField("AZ0_DESNIV")
oStructAZ0:RemoveField("AZ0_CAMPO")
oStructAZ0:RemoveField("AZ0_EXPRES")
oStructAZ0:RemoveField("AZ0_CONENT")

oStructDOT:RemoveField("AZ1_CODAGR")
oStructDOT:RemoveField("AZ1_CODNIV")

oStructUSU:RemoveField("AZ2_CODAGR")
oStructUSU:RemoveField("AZ2_CODNIV")
oStructUSU:RemoveField("AZ2_ENTIDA")
oStructEQU:RemoveField("AZ2_CODAGR")
oStructEQU:RemoveField("AZ2_CODNIV")
oStructEQU:RemoveField("AZ2_ENTIDA")

oStructNEG:RemoveField("AZA_CODAGR")
oStructNEG:RemoveField("AZA_CODNIV")

oStructUSU:SetProperty('AZ2_CODENT', MVC_VIEW_LOOKUP,'AO3REG') 
oStructEQU:SetProperty('AZ2_CODENT', MVC_VIEW_LOOKUP,'ACAREG') 

oView:CreateVerticalBox("ESQUERDA",40)
oView:CreateVerticalBox("DIREITA" ,60)
If lAliasAZL
	oView:CreateHorizontalBox("ESQ_SUP" ,18,"ESQUERDA")
	oView:CreateHorizontalBox("ESQ_INF" ,82,"ESQUERDA")
	oView:CreateHorizontalBox("DIR_SUP" ,50,"DIREITA")
	oView:CreateHorizontalBox("DIR_INF" ,50,"DIREITA")
Else
	oView:CreateHorizontalBox("ESQ_INF" ,100,"ESQUERDA")
	oView:CreateHorizontalBox("DIR_SUP" ,100,"DIREITA")
EndIF

//Painel Esquerdo
oView:AddOtherObject ("OBJ_TREE",{|oPanel| CRMA910Tree(oPanel,oView,oView:GetModel())})

oView:SetOwnerView("OBJ_TREE","ESQ_INF" )

//Painel Direito Superior
oView:CreateFolder('FOLDER','DIR_SUP')

oView:AddSheet('FOLDER','SHEET0',STR0010) //'Regras'
oView:AddSheet('FOLDER','SHEET1',STR0011) //'Arquivos'
oView:AddSheet('FOLDER','SHEET2',STR0012) //'Usuários'
oView:AddSheet('FOLDER','SHEET3',STR0013) //'Equipes'
oView:AddSheet('FOLDER','SHEET4',STR0014) //'Unidades de Negócio'

oView:CreateHorizontalBox( 'BOXFORM0', 100,,, 'FOLDER', 'SHEET0')
oView:CreateHorizontalBox( 'BOXFORM1', 100,,, 'FOLDER', 'SHEET1')
oView:CreateHorizontalBox( 'BOXFORM2', 100,,, 'FOLDER', 'SHEET2')
oView:CreateHorizontalBox( 'BOXFORM3', 100,,, 'FOLDER', 'SHEET3')
oView:CreateHorizontalBox( 'BOXFORM4', 100,,, 'FOLDER', 'SHEET4')

If lAliasAZL
	oView:SetOwnerView("VIEW_AZP","ESQ_SUP" )
	oView:SetOwnerView("VIEW_AZL","DIR_INF" )
EndIf
oView:SetOwnerView("VIEW_AZ0","BOXFORM0")
oView:SetOwnerView("VIEW_DOT","BOXFORM1")

oView:SetOwnerView("VIEW_USU","BOXFORM2")
oView:SetOwnerView("VIEW_EQU","BOXFORM3")
oView:SetOwnerView("VIEW_NEG","BOXFORM4")

If lAliasAZL
	oView:EnableTitleView("VIEW_AZP",STR0009)	//"Ofertas"
	oView:EnableTitleView("VIEW_AZL",STR0031)	//"Ofertas"
EndIf
oView:EnableTitleView("VIEW_AZ0",STR0010) //"Regras"
oView:EnableTitleView("VIEW_DOT",STR0019) //".DOT"
oView:EnableTitleView("VIEW_USU",STR0018) //"Permissões"
oView:EnableTitleView("VIEW_EQU",STR0018) //"Permissões"
oView:EnableTitleView("VIEW_NEG",STR0014) //"Unidades de Negócio"

oView:AddUserButton( STR0039,"",{ || CRMA910C() } ) //"Vincular Unidades/Usuários"

If lCtrlUsr
	ExecBlock("CRM910VIEW",.F.,.F.,{oView})	 
EndIf

Return ( oView )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA910Tree

Cria o objeto DbTree.

@sample		(oPanel,oViewActive,oMdlActive)

@param		ExpO1 - Panel AddOtherObject
ExpO2 - FWFormView Ativa
ExpO3 - MPFormModel Ativo

@return		Nenhum

@author		Cleyton F.Alves
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA910Tree(oPanel,oViewActive,oMdlActive)
	
Local oTree	 		:= Nil
Local oMdlAOLField	:= oMdlActive:GetModel("AOLMASTER")
Local oMdlAOMGrid	:= oMdlActive:GetModel("AOMDETAIL")
Local cAOLResumo	:= AOL->AOL_RESUMO

oTree := DbTree():New(0,0,000,000,oPanel,{|| .T. },{|| .T. },.T.)	// Adiciona a tree na view
oTree:Align := CONTROL_ALIGN_ALLCLIENT
oTree:AddItem(cAOLResumo+Space(200),CRMA580Root(),"FOLDER12","FOLDER13",,,1)  // RAIZ //"Entidades"

// carregando a tree com os dados
If !oMdlAOMGrid:IsEmpty()
	Processa( { || CRMA910LdTree(oTree,oMdlActive) }, STR0045, "" ) //"Carregando níveis do agrupador..."
EndIf

//Clique com botao esquerdo do mouse
oTree:BLClicked	:= {|| CRMA910TClick(oTree,oViewActive,oMdlActive) }

oTree:EndTree()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA910TClick

Funcao que marca e desmarca o DbTree

@sample		CRMA910TClick(oTree,oViewActive,oMdlActive)

@param		ExpO1 - Componente DBTree
ExpO2 - FwFormView do Agrupador de Registros
ExpO3 - MPFormModel do Agrupador de Registros

@return		Nenhum

@author		Cleyton F.Alves
@since		31/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRMA910TClick(oTree,oViewActive,oMdlActive)

Local oMdlAOMGrid	:= oMdlActive:GetModel("AOMDETAIL")
Local cIdTree		:= AllTrim(oTree:GetCargo())
Local cCodIntPos	:= ""
Local nLinAtu		:= 0
Local cCodAgr       := ""
Local cCodNiv       := ""

If cIdTree <> CRMA580Root() .AND. oMdlAOMGrid:SeekLine({{"AOM_CODNIV",cIdTree}})
	
	If oMdlAOMGrid:GetValue("AOM_MSBLQL") == "2"
		
		nLinAtu	:= oMdlAOMGrid:GetLine()
		
		cCodIntPos	:= AllTrim(oMdlAOMGrid:GetValue("AOM_IDINT"))
		cCodAgr		:= oMdlAOMGrid:GetValue("AOM_CODAGR")
		cCodNiv		:= oMdlAOMGrid:GetValue("AOM_CODNIV")
		
		If 	AZ0->(dbSeek(xFilial("AZ0")+cCodAgr+cCodNiv)) .Or. ;
			AZ1->(dbSeek(xFilial("AZ1")+cCodAgr+cCodNiv)) .Or. ;
			AZ2->(dbSeek(xFilial("AZ2")+cCodAgr+cCodNiv)) .Or. ;
			AZA->(dbSeek(xFilial("AZA")+cCodAgr+cCodNiv))
			
			oTree:ChangeBmp("CHECKOK","CHECKOK",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
		Else
			oTree:ChangeBmp("","",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
		EndIf
		
		oMdlAOMGrid:GoLine(nLinAtu)
		
	Else
		MsgAlert(STR0005) //"Registro Bloqueado!"
	EndIf
	
EndIf

oViewActive:Refresh()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA910LdTree

Carrega o componente DbTree com os Níveis do Agrupador.

@sample	CRMA910LdTree( oTree, oActive )

@param		oTree, objeto, Objeto do DBTree.
@param		oActive, objeto, Modelo de dados ativo. 

@return	Nenhum

@author	Cleyton F.Alves
@since		31/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRMA910LdTree( oTree, oActive )

Local oAOMGrid	:= Nil 
Local oAOLCab		:= Nil
Local cImage		:= ""
Local cFather		:= ""
Local nLevel		:= 0
Local cFilAZ0		:= xFilial( "AZ0" )
Local cFilAZ1		:= xFilial( "AZ1" )
Local cFilAZA		:= xFilial( "AZA" )

Default oActive 	:= FWModelActive()
Default oTree 	:= CRMA580DGTree()
	
//-------------------------------------------------------------------
// Recupera o modelo de dados.    
//-------------------------------------------------------------------
oAOMGrid 	:= oActive:GetModel("AOMDETAIL")
oAOLCab	:= oActive:GetModel("AOLMASTER")

//-------------------------------------------------------------------
// Inicia a montagem de árvore.    
//-------------------------------------------------------------------
oTree:Reset()
oTree:AddItem( oAOLCab:GetValue("AOL_RESUMO") + Space(200) , CRMA580Root(), "FOLDER12" , "FOLDER13",,,1 )

//-------------------------------------------------------------------
// Define o tamanho da régua de processamento.    
//-------------------------------------------------------------------
ProcRegua( oAOMGrid:Length() )

//-------------------------------------------------------------------
// Percorre todos os níveis do agrupador.    
//-------------------------------------------------------------------
For nLevel := 1 To oAOMGrid:Length()
	oAOMGrid:GoLine( nLevel )

	//-------------------------------------------------------------------
	// Incrementa a régua de processamento.    
	//-------------------------------------------------------------------
	IncProc( oAOMGrid:GetValue("AOM_DESCRI") )

	//-------------------------------------------------------------------
	// Localiza o nó pai.    
	//-------------------------------------------------------------------			
	If ! ( cFather == oAOMGrid:GetValue("AOM_NIVPAI") )	
		cFather := oAOMGrid:GetValue("AOM_NIVPAI")
		oTree:TreeSeek( cFather )
	EndIf 
			
	//-------------------------------------------------------------------
	// Define a imagem de acordo com o status do nó.    
	//-------------------------------------------------------------------
	If 	AZ0->( dbSeek( cFilAZ0 + oAOMGrid:GetValue( "AOM_CODAGR" ) + oAOMGrid:GetValue( "AOM_CODNIV" ) ) ) .Or. ;
		AZ1->( dbSeek( cFilAZ1 + oAOMGrid:GetValue( "AOM_CODAGR" ) + oAOMGrid:GetValue( "AOM_CODNIV" ) ) ) .Or. ;
		AZ1->( dbSeek( cFilAZ1 + oAOMGrid:GetValue( "AOM_CODAGR" ) + oAOMGrid:GetValue( "AOM_CODNIV" ) ) ).Or. ;
		AZA->( dbSeek( cFilAZA + oAOMGrid:GetValue( "AOM_CODAGR" ) + oAOMGrid:GetValue( "AOM_CODNIV" ) ) )
				
		cImage := "CHECKOK"
	Else
		cImage := ""
	EndIf
			
	//-------------------------------------------------------------------
	// Adiciona o nó filho.    
	//-------------------------------------------------------------------	
	oTree:AddItem( AllTrim( oAOMGrid:GetValue("AOM_CODNIV") ) + " - " + oAOMGrid:GetValue("AOM_DESCRI"), oAOMGrid:GetValue("AOM_CODNIV"), cImage, cImage,,,2 )
Next nLevel	
	
//------------------------------------------------------
// Posiciona na primeira linha do Nivel do Agrupador.    
//------------------------------------------------------	
oAOMGrid:GoLine( 1 )
	
Return Nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRMA910SZ2

Faz a carga dos dados de usuários e equipe.

@sample	CRMA910SZ2(oMdlAOL,cCodAgrup)

@param	Nenhum
@return	ExpC - String dos Agrupadores Selecionados.

@author	SI2901 - Cleyton F.Alves
@since		05/04/2015
@version	12
/*/
//-----------------------------------------------------------------------------
Static Function CRMA910SZ2(oModel,oMdlSZ2,cEntidade)

Local aLoadAZ2	:= {}
Local oStructSZ2	:= oMdlSZ2:GetStruct()
Local aCampos		:= aClone(oStructSZ2:GetFields())
Local uValue		:= Nil
Local nLinha		:= 0
Local nY			:= 0
Local oMdlAOMGrid	:= oModel:GetModel("AOMDETAIL")
Local cCodAgr    	:= oMdlAOMGrid:GetValue("AOM_CODAGR")
Local cCodNiv    	:= oMdlAOMGrid:GetValue("AOM_CODNIV")
Local cTime 		:= Time()
Local cFilAZ2		:= xFilial("AZ2")
Local cFilACA		:= xFilial("ACA")

AZ2->(dbSeek(cFilAZ2+cCodAgr+cCodNiv+cEntidade))

While 	AZ2->(!Eof()) .And. ;
		AZ2->AZ2_FILIAL == cFilAZ2 .And. ;
		AZ2->AZ2_CODAGR == cCodAgr .And. ;
		AZ2->AZ2_CODNIV == cCodNiv .And. ;
		AllTrim(AZ2->AZ2_ENTIDA) = AllTrim(cEntidade)
			
	aAdd(aLoadAZ2,{AZ2->( RECNO() ),Array(Len(aCampos))})
	
	nLinha++
	
	For nY := 1 To Len(aCampos)
		If ALlTrim(aCampos[nY][MODEL_FIELD_IDFIELD]) == 'AZ2_DSCENT' 
			If cEntidade == "ACA"
				uValue := AllTrim( Posicione("ACA",1,cFilACA+AZ2->AZ2_CODENT,"ACA_DESCRI") )
			Else
				uValue := AllTrim( CRMXLoadUser( AZ2->AZ2_CODENT )[4] )
			EndIf
		ElseIf !aCampos[nY][MODEL_FIELD_VIRTUAL]
			uValue := AZ2->( FieldGet( FieldPos( aCampos[nY][MODEL_FIELD_IDFIELD] ) ) )
		Else
			uValue := CriaVar( aCampos[nY][MODEL_FIELD_IDFIELD] , .T. )
		EndIf
		
		aLoadAZ2[nLinha][2][nY] := uValue
		
	Next nY
	
	AZ2->(DbSkip())
EndDo

Return(aLoadAZ2)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRMA910AZ0

Retorna os agrupador selecionado pelo usuario.

@sample	CRMA910AZ0()

@param	Nenhum
@return	ExpC - String dos Agrupadores Selecionados.

@author	SI2901 - Cleyton F.Alves
@since		05/04/2015
@version	12
/*/
//-----------------------------------------------------------------------------
Function CRMA910AZ0()

Local oMdlAct := FwModelActive()
Local oMdlAZ0 := oMdlAct:GetModel("FOL_AZ0")
Local cEntidade := oMdlAZ0:GetValue("AZ0_ENTIDA")
Local cCodRet := ""

If !Empty(cEntidade)
	
	If cEntidade == "SA1"
		cCodRet := "SA1AZ0"
	ElseIf cEntidade == "AO3"
		cCodRet := "AO3AZO"
	Else
		cCodRet := cEntidade
	EndIf
	
EndIf

Return(cCodRet)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRMA910LOOK

Retorna os agrupador selecionado pelo usuario.

@sample	CRMA910LAOOK()

@param	Nenhum
@return	ExpC - String dos Agrupadores Selecionados.

@author	SI2901 - Cleyton F.Alves
@since		05/04/2015
@version	12
/*/
//-----------------------------------------------------------------------------
Function CRMA910LOOK()

Local oMdlAct := FwModelActive()
Local cConPad := ""
Local cAlCPad := ""
Local cCodRet := ""
Local lRet    := .F.
Local aDadSX2 := {}

Static cRetConPad := ""

If oMdlAct <> Nil 

	cConPad	:= FwFldGet("AZ0_CONENT")
	cAlCPad	:= FwFldGet("AZ0_ENTIDA")

	If !Empty(cConPad)

		lRet := ConPad1(,,,cConPad)
		If lRet
			cCodRet := (cAlCPad)->&(CRMA910F3(cConPad))
		EndIf
	EndIf

	cRetConPad := AllTrim(cCodRet) 
EndIf

Return(lRet)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRMA910RET

Retorna os agrupador selecionado pelo usuario.

@sample	CRMA910RET(oMdlAOL,cCodAgrup)

@param	Nenhum
@return	ExpC - String dos Agrupadores Selecionados.

@author	SI2901 - Cleyton F.Alves
@since		05/04/2015
@version	12
/*/
//-----------------------------------------------------------------------------
Function CRMA910RET()
Return(cRetConPad)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRMA910F3

Retorna a chave da consulta F3 para utilizar na macro do LOOKUP

@sample	CRMA910F3(cCodConPad)

@param	Nenhum
@return	ExpC - String dos Agrupadores Selecionados.

@author	SI2901 - Cleyton F.Alves
@since		05/04/2015
@version	12
/*/
//-----------------------------------------------------------------------------
Function CRMA910F3(cCodConPad)

aSave      := SXB->(GetArea())
cCodConPad := PadR(cCodConPad,6)
cRetConPad := ""

SXB->(dbSetOrder(1))
SXB->(dbSeek(cCodConPad+"5"))
While SXB->(!Eof()) .And. SXB->(XB_ALIAS+XB_TIPO) == cCodConPad+"5"

	If !Empty(cRetConPad)
		cRetConPad += " + "
	EndIf 
	cRetConPad += AllTrim(SXB->XB_CONTEM)
	
	SXB->(dbSkip())
EndDo

RestArea(aSave)

Return(cRetConPad)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA910Load()
 
Faz a carga dos dados antes de exibir a interface.

*Utilizado load, pois o SetRelation onera o carregamento.
 
@sample      CRMA910Load( oModel, oMdlSZ2, cTable )
 
@param       oModel,	Objeto,	Modelo de Dados
@param		  oMdlGet, Objeto, 	Get do Modelo de dados específico
@param		  cTable,	Caractere, Alias da tabela de load
			 
 
@Return      aLoad , array , Retorna os dados de load
                [1][1] R_E_C_N_O
            	[1][2] Array do GetFiels da estrutura
    
@author      Thamara Villa
@since       13/01/2015
@version     12.1.7
/*/
//------------------------------------------------------------------------------
Static Function CRMA910Load( oModel, oMdlGet, cTable )

Local oStruPad	:= oMdlGet:GetStruct()
Local aField		:= oStruPad:GetFields()
Local aLoad		:= {}
Local nLine		:= 0
Local nY			:= 0
Local oMdlAOM		:= oModel:GetModel( "AOMDETAIL" )
Local cCodAgr    	:= oMdlAOM:GetValue( "AOM_CODAGR" )
Local cCodNiv    	:= oMdlAOM:GetValue( "AOM_CODNIV" )
Local cFilCtab		:= xFilial( cTable )

If ( cTable )->( DbSeek( cFilCtab + cCodAgr + cCodNiv ) )

	While ( !( cTable )->( Eof() ) ) .And. ;
			( cTable )->&( cTable + "_FILIAL" ) == cFilCtab .And. ;
			( cTable )->&( cTable + "_CODAGR" ) == cCodAgr .And. ;
			( cTable )->&( cTable + "_CODNIV" ) == cCodNiv
			
		nLine++
		
		aAdd( aLoad,{ ( cTable )->( RECNO() ), Array( Len( aField ) ) } )
		
		For nY := 1 To Len( aField )
			If !aField[nY][MODEL_FIELD_VIRTUAL]
				aLoad[nLine][2][nY] := (cTable)->( FieldGet( FieldPos( aField[nY][MODEL_FIELD_IDFIELD] ) ) )//&( cTable +"->"+ ( AllTrim( aField[nY][MODEL_FIELD_IDFIELD] ) ) )
			Else
				aLoad[nLine][2][nY] := CriaVar( aField[nY][MODEL_FIELD_IDFIELD], .T. )
			EndIf
			
		Next( nY )
		
		( cTable )->( DbSkip() )
	EndDo
	
EndIf

Return( aLoad )