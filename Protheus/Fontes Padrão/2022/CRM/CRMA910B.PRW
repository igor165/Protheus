#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "CRMA910.CH"

Static _oTree	 := Nil
Static aRetGrid  := {}
Static lMarkUniq := .F.
Static oMdlOpor  := NIL
Static lReleaseV12 := Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA910B
Monta modelo de dados do Níveis do Agrupador Dinamico.
@sample		CRMA910B()
@return		ExpO - Array com niveis selecionados
@author		SI2901 - Cleyton F.Alves
@since		11/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA910B()

Local oMdlProp	:= FwModelActivate()	
Local oModel 	:= Nil
Local oMdlAOL	:= Nil
Local oMdlAOM	:= Nil
Local oMdlAZK	:= Nil
Local oMdlAZL	:= Nil
Local oView		:= Nil
Local oExecView := Nil
Local aButtons  := {}
Local aReturn   := {} 
Local lC910BUNQ	:= ExistBlock("CR910BUNQ")

AD1->(dbSetOrder(1))
ADJ->(dbSetOrder(6))
ADZ->(dbSetOrder(4))
AOL->(dbSetOrder(1))
AOM->(dbSetOrder(1))
AZ0->(dbSetOrder(1))
AZ1->(dbSetOrder(1))
AZ2->(dbSetOrder(1))
SU1->(DbSetOrder(1))
SUG->(DbSetOrder(2))

checkV1227()

If lReleaseV12
	AZN->(dbSetOrder(1))
	AZO->(dbSetOrder(1))
EndIf

If oMdlProp <> nil 
	oMdlOpor :=	FT600MdlOport( oMdlProp )
EndIf

oModel   := FWLoadModel("CRMA910B")
oMdlAOL  := oModel:GetModel('AOLDETAIL')
oMdlAOM  := oModel:GetModel('AOMDETAIL')
oMdlSB1  := oModel:GetModel('SB1DETAIL')

If lReleaseV12
	oMdlAZL  := oModel:GetModel('AZLDETAIL')
	oMdlAZK  := oModel:GetModel('AZKDETAIL')
EndIF

If lC910BUNQ
	lMarkUniq := ExecBlock("CR910BUNQ",.F.,.F.,{oModel})
EndIf

oModel:SetOperation(MODEL_OPERATION_UPDATE)

oMdlAOL:SetNoDeleteLine(.T.)
oMdlAOL:SetNoInsertLine(.T.)
oMdlAOL:SetNoUpdateLine(.F.)
		
oMdlAOM:SetNoDeleteLine(.T.)
oMdlAOM:SetNoInsertLine(.T.)
oMdlAOM:SetNoUpdateLine(.F.)

oMdlSB1:SetNoDeleteLine(.T.)
oMdlSB1:SetNoInsertLine(.T.)

If lReleaseV12
	oMdlAZL:SetNoDeleteLine(.T.)
	oMdlAZL:SetNoInsertLine(.T.)
	oMdlAZK:SetNoDeleteLine(.T.)
	oMdlAZK:SetNoInsertLine(.T.)
EndIf

oModel:Activate()

If oModel:IsActive()		
	aButtons := { {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}	,;
				  {.F.,Nil},{.T.,STR0020},{.T.,STR0021},{.F.,Nil}	,;
				  {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }

	oView := FWLoadView("CRMA910B")
	oView:SetModel(oModel)

	oMdlAOL  := oModel:GetModel("AOLDETAIL")
	oMdlAOM  := oModel:GetModel("AOMDETAIL")
	
	If !oMdlAOL:IsEmpty()				
		oExecView := FWViewExec():New()
		oExecView:SetTitle(STR0023) //"Proposta"
		oExecView:SetView(oView)
		oExecView:SetModal(.F.)
		oExecView:SetOperation(MODEL_OPERATION_UPDATE)
		oExecView:SetButtons(aButtons)
		oExecView:OpenView(.F.)
	Else
		MsgAlert(STR0015) //"Não existem regras de comercialização configuradas para agrupadores de produtos"
	EndIf
	
	aReturn := aClone(aRetGrid)
	oModel:DeActivate()
	aRetGrid := {}		

	FwModelActivate(oMdlProp)
EndIf

Return(aReturn)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Monta modelo de dados do Níveis do Agrupador Dinamico.
@sample		ModelDef()
@return		ExpO - Modelo de Dados
@author		SI2901 - Cleyton F.Alves
@since		11/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel 	 := Nil
Local oMdlAOL    := Nil
Local oMdlAOM    := Nil

Local oStructCAB := FWFormModelStruct():New()
Local oStructAOL := FWFormStruct(1,"AOL"  ,{|cCampo| AllTrim(cCampo) $ "AOL_CODAGR|AOL_RESUMO|AOL_ENTIDA|AOL_DSCENT|AOL_TIPO|"},/*lViewUsado*/)
Local oStructAOM := FWFormStruct(1,"AOM"  ,/*bAvalCampo*/,/*lViewUsado*/)

Local oStructAZL := Nil
Local oStructAZK := Nil

Local oStructSB1 := FWFormStruct(1,"SB1"  ,{|cCampo| AllTrim(cCampo) $ "B1_COD|B1_DESC|B1_TIPO|B1_UM|B1_GRUPO|"},/*lViewUsado*/)
Local bCarga	 := {||{xFilial("AOL")}}

checkV1227()

If lReleaseV12
	oStructAZL := FWFormStruct(1,"AZL"  ,/*bAvalCampo*/,/*lViewUsado*/)
	oStructAZK := FWFormStruct(1,"AZK"  ,/*bAvalCampo*/,/*lViewUsado*/)
EndIf

oStructCAB:AddField("","","CABEC_FILIAL" ,"C",FwSizeFilial(),0)
oStructAOL:AddField("","","AOL_MARK"	 ,"L",1 ,0,{|oMdlAOL| CRMMarkAOL(oMdlAOL)},Nil,Nil,Nil,Nil,Nil,Nil,.T.)
oStructAOM:AddField("","","AOM_MARK"	 ,"L",1 ,0,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)
oStructSB1:AddField("","","B1_MARK"	 ,"L",1 ,0,{|oMdlSB1| CRMMarkSB1(oMdlSB1)}, Nil,Nil,Nil,Nil,Nil,Nil,.T.)
oStructSB1:AddField("","","B1_DSCGRU"	 ,"C",TamSX3('B1_DESC')[1] ,TamSX3('B1_DESC')[2],Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)
oStructSB1:AddField("","","B1_CODAGR"	 ,"C",TamSX3('AOL_CODAGR')[1] ,TamSX3('AOL_CODAGR')[2],Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)
oStructSB1:AddField("","","B1_CODNIV"	 ,"C",TamSX3('AOM_CODNIV')[1],TamSX3('AOM_CODNIV')[2],Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.) 
oStructSB1:AddField("","","B1_CARGA"	 ,"C",1,0,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.) 

If lReleaseV12
	oStructAZK:AddField("","","AZK_MARK"	 ,"L",1 ,0,FwBuildFeature(STRUCT_FEATURE_VALID,"CRMMarkAZK()"),Nil,Nil,Nil,Nil,Nil,Nil,.T.)
	oStructSB1:AddField("","","B1_CODOFE"	 ,"C",TamSX3('AZK_CODIGO')[1],TamSX3('AZK_CODIGO')[2],Nil,Nil,Nil,Nil,{||"''"},Nil,Nil,.T.)
	oStructSB1:AddField("","","B1_ITOFER"	 ,"C",TamSX3('AZK_ITOFER')[1],TamSX3('AZK_ITOFER')[2],Nil,Nil,Nil,Nil,{||"''"},Nil,Nil,.T.)
EndIf

oStructSB1:SetProperty('*'  	 ,MODEL_FIELD_WHEN,{||.F.})
oStructSB1:SetProperty('B1_MARK',MODEL_FIELD_WHEN,{||.T.})

If lReleaseV12
	oStructAZK:SetProperty('*'  	 ,MODEL_FIELD_WHEN,{||.F.})
	oStructAZK:SetProperty('AZK_MARK',MODEL_FIELD_WHEN,{||.T.})
EndIf

oModel := MPFormModel():New("CRMA910B",/*bPreValidacao*/,/*bPosVldMdl*/,/*bCommitMdl*/,/*bCancel*/)

oModel:AddFields("CABMASTER",/*cOwner*/,oStructCAB,/*bPreValidacao*/,/*bPosVldMdl*/,bCarga)
oModel:AddGrid("AOLDETAIL" ,"CABMASTER",oStructAOL,/*bPreValid*/    ,/*bPosVldMdl*/,/*bLoad*/  )
oModel:AddGrid("AOMDETAIL" ,"AOLDETAIL",oStructAOM,/*bLinPre  */    ,/*bLinePost */,/*bPreVal*/,/*bPosVldGrid*/,/*bLoad*/)

If lReleaseV12
	oModel:AddGrid("AZLDETAIL" ,"AOMDETAIL",oStructAZL,/*bLinPre  */    ,/*bLinePost */,/*bPreVal*/,/*bPosVldGrid*/,/*bLoad*/)
	oModel:AddGrid("AZKDETAIL" ,"AZLDETAIL",oStructAZK,/*bLinPre  */    ,/*bLinePost */,/*bPreVal*/,/*bPosVldGrid*/,/*bLoad*/)
EndIf

oModel:AddGrid("SB1DETAIL" ,"AOMDETAIL",oStructSB1,/*bLinPre  */    ,/*bLinePost */,/*bPreVal*/,/*bPosVldGrid*/,/*bLoad*/)

oModel:SetRelation("AOLDETAIL",{{"AOL_FILIAL","xFilial('AOL')"}},AOL->(IndexKey(1)))
oModel:SetRelation("AOMDETAIL",{{"AOM_FILIAL","xFilial('AOM')"},{"AOM_CODAGR","AOL_CODAGR"}},AOM->(IndexKey(1)))

If lReleaseV12
	oModel:SetRelation("AZLDETAIL",{{"AZL_FILIAL","xFilial('AZL')"},{"AZL_CODAGR","AOL_CODAGR"},{"AZL_CODNIV","AOM_CODNIV"}},AZL->(IndexKey(1)))
	oModel:SetRelation("AZKDETAIL",{{"AZK_FILIAL","xFilial('AZK')"},{"AZK_CODIGO","AZL_CODOFE"}},AZK->(IndexKey(1)))
EndIf

oModel:SetRelation("SB1DETAIL",{{"B1_FILIAL" ,"xFilial('SB1')"},{"B1_CODAGR","AOL_CODAGR"},{"B1_CODNIV","AOM_CODNIV"}},"B1_FILIAL+B1_CODAGR+B1_CODNIV")

oModel:GetModel("AOLDETAIL"):bLoad:={|oMdlAOL| CRM910BOL(oMdlAOL) }
oModel:GetModel("AOLDETAIL"):SetOptional(.T.)
oModel:GetModel("AOLDETAIL"):SetOnlyQuery(.T.)

oModel:GetModel("AOMDETAIL"):bLoad:={|oMdlAOM| CRM910BOM(oMdlAOM,oModel:GetModel("AOLDETAIL"):GetValue("AOL_CODAGR")) }
oModel:GetModel("AOMDETAIL"):SetOptional(.T.)
oModel:GetModel("AOMDETAIL"):SetOnlyQuery(.T.)

If lReleaseV12
	oModel:GetModel("AZLDETAIL"):bLoad:={|oMdlAZL| CRM910BZL(oMdlAZL,oModel:GetModel("AOMDETAIL"),oModel:GetModel("AOLDETAIL"))}
	oModel:GetModel("AZLDETAIL"):SetOptional(.T.)
	oModel:GetModel("AZLDETAIL"):SetOnlyQuery(.T.)
	oModel:GetModel("AZKDETAIL"):SetOptional(.T.)
	oModel:GetModel("AZKDETAIL"):SetOnlyQuery(.T.)
EndIf

oModel:GetModel("SB1DETAIL"):bLoad:={|oMdlSB1| CRM910BB1(oMdlSB1,oModel:GetModel("AOMDETAIL"),oModel:GetModel("AOLDETAIL"))}
oModel:GetModel("SB1DETAIL"):SetOptional(.T.)
oModel:GetModel("SB1DETAIL"):SetOnlyQuery(.T.)

oModel:SetPrimaryKey({""})

oModel:GetModel("CABMASTER"):SetDescription(STR0002) //"Agrupador de Registros"
oModel:GetModel("AOLDETAIL"):SetDescription(STR0003) //"Agrupadores"
oModel:GetModel("AOMDETAIL"):SetDescription(STR0004) //"Níveis do Agrupador"

If lReleaseV12
	oModel:GetModel("AZLDETAIL"):SetDescription(STR0031) //"Regras com x ofertas"
	oModel:GetModel("AZKDETAIL"):SetDescription(STR0032) //"Pacotes da oferta"
EndIf

oModel:GetModel("SB1DETAIL"):SetDescription(STR0016) //"Produtos"

oModel:SetDescription(STR0001) //"Regras de Comercialização"

oModel:bCommit := {|oModel| (CRM910BGRV(oModel),.T.) }

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Monta interface do Níveis do Agrupador Dinamico.

@sample	ViewDef()
@param		Nenhum

@return	ExpO - Interface do Agrupador de Registros
@author	SI2901 - Cleyton F.Alves
@since		11/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
 
Local oStructAOL	:= FWFormStruct(2,"AOL",{|cCampo| AllTrim(cCampo) $ "AOL_CODAGR|AOL_RESUMO|AOL_ENTIDA|AOL_DSCENT|AOL_TIPO|"},/*lViewUsado*/)
Local oStructAOM	:= FWFormStruct(2,"AOM",/*bAvalCampo*/,/*lViewUsado*/)
Local oStructAZL	:= Nil
Local oStructAZK	:= Nil
Local oStructSB1	:= FWFormStruct(2,"SB1",{|cCampo| AllTrim(cCampo) $ "B1_COD|B1_DESC|B1_TIPO|B1_UM|B1_GRUPO|"},/*lViewUsado*/)
Local oModel		:= FWLoadModel('CRMA910B')
Local oView			:= Nil
Local oPanel		:= Nil

If lReleaseV12
	oStructAZL	:= FWFormStruct(2,"AZL",/*bAvalCampo*/,/*lViewUsado*/)
	oStructAZK	:= FWFormStruct(2,"AZK",/*bAvalCampo*/,/*lViewUsado*/)
EndIf

oStructAOL:AddField("AOL_MARK"   ,"01","","",{},"L","@BMP",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)
oStructAOM:AddField("AOM_MARK"   ,"01","","",{},"L","@BMP",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)

If lReleaseV12
	oStructAZK:AddField("AZK_MARK"   ,"01","","",{},"L","@BMP",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)
EndIf
oStructSB1:AddField("B1_MARK"   ,"01","","",{},"L","@BMP",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)
oStructSB1:AddField("B1_DSCGRU" ,"30",STR0017,STR0017,{},"C",""    ,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.) //"Desc.Agrup"

oView:=FWFormView():New()
oView:SetModel(oModel)

If CRM910BIsOffer()  // verifica se há ofertas vinculadas,  se não, monta view simplificada
	oView:AddGrid("VIEW_AOL",oStructAOL,"AOLDETAIL")

	If lReleaseV12
		oView:AddGrid("VIEW_AZL",oStructAZL,"AZLDETAIL")
		oView:AddGrid("VIEW_AZK",oStructAZK,"AZKDETAIL")
	EndIf

	oView:AddGrid("VIEW_SB1",oStructSB1,"SB1DETAIL")
	
	oView:AddOtherObject ("OBJ_TREE",{|oPanel| CRMA910BTree(oPanel,oView,oView:GetModel())})
	oView:SetViewProperty('VIEW_AOL',"CHANGELINE",{ { || CRM910BLdTree(Nil,oView:GetModel(),oView)}})
	
	oView:CreateHorizontalBox("SUPERIOR",26)
	oView:CreateHorizontalBox("CENTRAL" ,37)
	oView:CreateHorizontalBox("INFERIOR",37)

	oView:CreateVerticalBox("SUP_ESQ",50,"SUPERIOR")
	oView:CreateVerticalBox("SUP_DIR",50,"SUPERIOR")
	
	oView:CreateVerticalBox("CEN_ESQ",50,"CENTRAL")
	oView:CreateVerticalBox("CEN_DIR",50,"CENTRAL")
	
	//Painel Superior Esquerdo
	oView:SetOwnerView("VIEW_AOL","SUP_ESQ")
	oView:EnableTitleView("VIEW_AOL",STR0003) //"Agrupadores"
	
	//Painel Central Esquerdo
	oView:SetOwnerView("OBJ_TREE","CEN_ESQ" )
	oView:EnableTitleView("OBJ_TREE",STR0004) //"Niveis do Agrupador"

	If lReleaseV12
		//Painel Inferior Esquerdo
		oView:SetOwnerView("VIEW_AZL","SUP_DIR")
		oView:EnableTitleView("VIEW_AZL",STR0031) //"Ofertas"

		//Painel Superior Direito
		oView:SetOwnerView("VIEW_AZK","CEN_DIR")
		oView:EnableTitleView("VIEW_AZK",STR0032) //"Pacotes"
	EndIf
	
	//Painel Inferior Esquerdo
	oView:SetOwnerView("VIEW_SB1","INFERIOR")
	oView:EnableTitleView("VIEW_SB1",STR0016) //"Produtos"
	
	//Habilita a pesquisa de produtos no grid
	oView:SetViewProperty( "VIEW_SB1", "GRIDSEEK", { .T. } )
	
	//Habilita o filtro da grid
	oView:SetViewProperty( "VIEW_SB1", "GRIDFILTER", { .T. } )
Else
	oView:AddGrid("VIEW_AOL",oStructAOL,"AOLDETAIL")
	oView:AddGrid("VIEW_SB1",oStructSB1,"SB1DETAIL")
	
	oView:CreateHorizontalBox("SUPERIOR",35)
	oView:CreateHorizontalBox("INFERIOR",65)
	
	oView:CreateVerticalBox("INF_ESQ",35,"INFERIOR")
	oView:CreateVerticalBox("INF_DIR",65,"INFERIOR")
	
	oView:AddOtherObject ("OBJ_TREE",{|oPanel| CRMA910BTree(oPanel,oView,oView:GetModel())})
	oView:SetViewProperty('VIEW_AOL',"CHANGELINE",{ { || CRM910BLdTree(Nil,oView:GetModel(),oView)}})
	
	//Painel Superior
	oView:SetOwnerView("VIEW_AOL","SUPERIOR")
	oView:EnableTitleView("VIEW_AOL",STR0003) //"Agrupadores"
	
	//Painel Inferior Direito
	oView:SetOwnerView("OBJ_TREE","INF_ESQ" )
	oView:EnableTitleView("OBJ_TREE",STR0004) //"Niveis do Agrupador"
	
	//Painel Inferior Esquerdo
	oView:SetOwnerView("VIEW_SB1","INF_DIR")
	oView:EnableTitleView("VIEW_SB1",STR0016) //"Produtos"
	
	//Habilita a pesquisa de produtos no grid
	oView:SetViewProperty( "VIEW_SB1", "GRIDSEEK", { .T. } )
	
	//Habilita o filtro da grid
	oView:SetViewProperty( "VIEW_SB1", "GRIDFILTER", { .T. } )
EndIf

oView:ShowUpdateMsg(.F.)

Return oView

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA910BTree

Cria o objeto DbTree.

@sample		(oPanel,oViewActive,oMdlActive)

@param		ExpO1 - Panel AddOtherObject
ExpO2 - FWFormView Ativa
ExpO3 - MPFormModel Ativo

@return		Nenhum

@author		Cleyton F.Alves
@since		11/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA910BTree(oPanel,oViewActive,oMdlActive)
	
Local oTree	 		:= Nil
Local oMdlAOLGrid	:= oMdlActive:GetModel("AOLDETAIL")
Local oMdlAOMGrid	:= oMdlActive:GetModel("AOMDETAIL")
local oMldSB1Grid   := oMdlActive:GetModel("SB1DETAIL")
Local cAOLResumo	:= AOL->AOL_RESUMO

oTree := DbTree():New(0,0,000,000,oPanel,{|| .T. },{|| .T. },.T.)	// Adiciona a tree na view
oTree:Align := CONTROL_ALIGN_ALLCLIENT
oTree:AddItem(cAOLResumo+Space(200),CRMA580Root(),"FOLDER12","FOLDER13",,,1)  // RAIZ //"Entidades

// carregando a tree com os dados
If !oMdlAOMGrid:IsEmpty()
	CRM910BLdTree(oTree,oMdlActive,oViewActive)
EndIf

//Clique com botao esquerdo do mouse
oTree:BLDblClick := {|| CRM910BTClick(oTree,oViewActive,oMdlActive) }
oTree:bChange    := {|| CRM910BChg(oTree,oViewActive,oMdlActive) }

oTree:EndTree()
CRMA580DSTree(oTree)

oViewActive:Refresh()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM910BTClick
Funcao que marca e desmarca o DbTree

@param oTree, objeto, Componente DBTree
@param oViewActive, objeto, FwFormView do Agrupador de Registros
@param oMdlActive, objeto, MPFormModel do Agrupador de Registros

@author		Cleyton F.Alves
@since		10/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM910BTClick(oTree,oViewActive,oMdlActive)
	
Local oMdlAOMGrid	:= oMdlActive:GetModel("AOMDETAIL")
Local cIdTree		:= AllTrim(oTree:GetCargo())
Local nLinAtu		:= 0
Local nx			:= 0
Local cCodAgr       := ""
Local cCodNiv       := ""
Local nTamGrid		:= 1

If cIdTree <> CRMA580Root() .AND. oMdlAOMGrid:SeekLine({{"AOM_CODNIV",cIdTree}})
	If oMdlAOMGrid:GetValue("AOM_MSBLQL") <> "1"
		nLinAtu	:= oMdlAOMGrid:GetLine()
		
		For nX := 1 To nTamGrid
			
			If lMarkUniq
				oMdlAOMGrid:GoLine(nX)
			Else
				oMdlAOMGrid:GoLine(nLinAtu)
			EndIf
			
			cCodAgr	:= oMdlAOMGrid:GetValue("AOM_CODAGR")
			cCodNiv	:= oMdlAOMGrid:GetValue("AOM_CODNIV")
	
			If 	ADJ->(dbSeek(xFilial("ADJ")+AD1->AD1_NROPOR+AD1->AD1_REVISA+cCodAgr+cCodNiv)) 
				If lMarkUniq
					If nX == nLinAtu
						oTree:ChangeBmp("LBOK","LBOK",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
						oMdlAOMGrid:SetValue("AOM_MARK",.T.)
					Else
						oTree:ChangeBmp("LBNO","LBNO",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
						oMdlAOMGrid:SetValue("AOM_MARK",.F.)
					EndIf
				Else
					If oMdlAOMGrid:GetValue("AOM_MARK")
						oTree:ChangeBmp("LBNO","LBNO",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
						oMdlAOMGrid:SetValue("AOM_MARK",.F.)
					Else
						oTree:ChangeBmp("LBOK","LBOK",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
						oMdlAOMGrid:SetValue("AOM_MARK",.T.)
					EndIf
				EndIf
			Else
				oTree:ChangeBmp("","",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
				oMdlAOMGrid:SetValue("AOM_MARK",.F.)
			EndIf
			
		Next nX
		
		oMdlAOMGrid:GoLine(nLinAtu)
		
	Else
		MsgAlert(STR0005) //"Registro Bloqueado!"
	EndIf
	
EndIf
	
oViewActive:Refresh()
	
Return Nil

//------------------------------------------------------------------------------
/*/	{Protheus.doc}

Carrega o componente DbTree com os Níveis do Agrupador.

@sample		CRM910BLdTree(oTree,oMdlActive)

@param		ExpO1 - Componente DBTree
ExpO2 - MPFormModel do agrupador de registros

@return		Nenhum

@author		Cleyton F.Alves
@since		10/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM910BLdTree(oTree,oMdlActive,oViewActive)
	
Local oMdlAOLGrid	:= Nil
Local oMdlAOMGrid	:= Nil
Local oStructAOM	:= Nil
Local oMdlADJ		:= Nil
Local aCampos		:= {}
Local cCargoPos		:= ""
Local cAOLResumo	:= ""
Local cIdTree		:= ""
Local nX			:= 0
Local nCount		:= 0
Local aDataADJ		:= {}
Local cFilAOM		:= xFilial( "AOM" )

//Campos especificos para Tree da TDI
Local lCustomTree	:= Findfunction( "P_A910BCustomTree" ) 
Local aTree 		:= {}
Local aCustom		:= {}
Local cDscAgr		:= ""
Local cNivelPai 	:= ""
Local cLastNode		:= ""

Default oMdlActive 	:= FwModelActive()
Default oTree		:= CRMA580DGTree()

oMdlAOMGrid 	:= oMdlActive:GetModel("AOMDETAIL")

If !lCustomTree
	
	oMdlAOLGrid 	:= oMdlActive:GetModel("AOLDETAIL")

	oMdlSB1Grid 	:= oMdlActive:GetModel("SB1DETAIL")
	oStructAOM		:= oMdlAOMGrid:GetStruct()
	aCampos		:= oStructAOM:GetFields()
	
	//----------------------------------------------------------------------------------------------
	// Verifica os agrupadores e níveis inseridos na oportunidade
	//----------------------------------------------------------------------------------------------
	AOL->( DbSetOrder( 1 ) )
	oMdlADJ := oMdlOpor:GetModel( "ADJDETAIL" )
	For nCount := 1 To oMdlADJ:Length()
		oMdlADJ:GoLine( nCount )
		aAdd( aDataADJ, { oMdlADJ:GetValue( "ADJ_CODAGR" ), oMdlADJ:GetValue( "ADJ_CODNIV" ) } )
	Next( nCount )
	
	cAOLResumo 	:= oMdlAOLGrid:GetValue("AOL_RESUMO")
	
	oTree:Reset()
	oTree:AddItem(cAOLResumo+Space(200),CRMA580Root(),"FOLDER12","FOLDER13",,,1)  // RAIZ //"Entidades
	cIdTree		:= AllTrim(oTree:GetCargo())
	
	cCargoPos := oMdlAOMGrid:GetValue("AOM_CODNIV")
	For nX := 1 To oMdlAOMGrid:Length()
		oMdlAOMGrid:GoLine(nX)
		If oMdlAOMGrid:GetValue("AOM_NIVPAI") == CRMA580Root()
			oTree:TreeSeek(CRMA580Root())
			CRM910BMTree(oTree,oMdlAOMGrid,aCampos,oMdlAOMGrid:GetValue("AOM_CODNIV"), aDataADJ)
		EndIf
	Next nX
	oMdlAOMGrid:GoLine(1)
	
	oTree:TreeSeek(cCargoPos)

Else
	
	aCustom := P_A910BCustomTree()
	
	If Len( aCustom ) != 0
		
		aTree := A910BTreeTDI( aCustom[1], aCustom[2], oMdlAOMGrid )

		For nX := 1 To Len( aTree )
			
			oTree:TreeSeek( aTree[nX][3] )
			cDscAgr := Posicione( "AOM", 1, cFilAOM + aTree[nX][1] + aTree[nX][2], "AOM_DESCRI" )
			oTree:AddItem( cDscAgr, aTree[nx][2],"","",,,2 )
						
		Next( nX )

		// Posiciona no último nó da árvore
		oTree:TreeSeek( aTree[Len(aTree)][2] )
		oMdlAOMGrid:SeekLine({	{"AOM_FILIAL" ,cFilAOM},{"AOM_CODAGR",FwFldGet("AOL_CODAGR")},{"AOM_CODNIV",oTree:GetCargo()} })

	Else
		Help( ,, 'A910BCustomTree',, STR0034, 1, 0 )// "Não há dados válidos retornados através do ponto de entrada, sendo assim, a funcionalidade de regras de comercialização não será executada."
	EndIf
EndIf

oViewActive:Refresh()

Return Nil

//------------------------------------------------------------------------------
/*/ {Protheus.doc} CRM910BMTree

Funcao recursiva para montar os níveis do DBTree.

@sample		CRM910BMTree(oTree,oMdlAOMGrid,aCampos,cNivelPai)

@param		ExpO1 - Componente DBTree
ExpO2 - ModelGrid Nível do Agrupador
ExpC3 - Campos da tabela AOM
ExpC4 - Codigo do Nível Pai.

@return		Verdadeiro

@author		Cleyton F.Alves
@since		10/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM910BMTree(oTree,oMdlAOMGrid,aCampos,cNivelPai, aDataADJ)

Local nLinha	:= 0
Local nX		:= 0
Local nz		:= 0
Local nLinAtu	:= 0
Local nCount	:= 0
Local cCodAgr	:= oMdlAOMGrid:GetValue("AOM_CODAGR")
Local cCodNiv	:= oMdlAOMGrid:GetValue("AOM_CODNIV")
Local oMdlADJ	:= FWLoadModel( "ADJDETAIL" )
Local cCodTab	:= GetNextAlias()
Local cCodUsu	:= If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
Local cQuery	:= ""
Local lAcess	:= .T.

lAcess := CRM910Access( cCodAgr, cCodNiv )

//-----------------------------------------------------------------------------------------------------------
// Verifica se possui acesso ao nível, se sim, adiciona na tree
//-----------------------------------------------------------------------------------------------------------
If ( lAcess )
	For nCount := 1 To Len( aDataADJ )
		If aDataADJ[nCount][1] == oMdlAOMGrid:GetValue( "AOM_CODAGR" ) .And. aDataADJ[nCount][2] == oMdlAOMGrid:Getvalue( "AOM_CODNIV" )
			oTree:AddItem( AllTrim( oMdlAOMGrid:GetValue("AOM_CODNIV") ) + " - " + oMdlAOMGrid:GetValue("AOM_DESCRI"),oMdlAOMGrid:GetValue("AOM_CODNIV"),"","",,,2)
		EndIf
	Next( nCount )

//-----------------------------------------------------------------------------------------------------------
// Senão, verifica se o item possui filhos, se sim, adiciona os itens
//-----------------------------------------------------------------------------------------------------------
Else
	If lReleaseV12
		AOM->( DbSetOrder( 3 ) ) //AOM_FILIAL+AOM_CODAGR+AOM_NIVPAI                                                                                                                                
		If AOM->( DbSeek( xFilial( "AOM" ) + 	oMdlAOMGrid:GetValue("AOM_CODAGR" ) + oMdlAOMGrid:GetValue("AOM_CODNIV") ) )
			oTree:AddItem( AllTrim( oMdlAOMGrid:GetValue("AOM_CODNIV") )  + " - " +  oMdlAOMGrid:GetValue("AOM_DESCRI"),oMdlAOMGrid:GetValue("AOM_CODNIV"),"","",,,2)
		EndIf
	EndIf
EndIf

If lAcess
	If oMdlAOMGrid:GetValue("AOM_MARK")
		oTree:ChangeBmp("LBOK","LBOK",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
	Else
		oTree:ChangeBmp("LBNO","LBNO",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
	EndIf
Endif

//-----------------------------------------------------------------------------------------------------------
// Percorre os itens do agrupador para continuar adicionando os itens
//-----------------------------------------------------------------------------------------------------------
If oMdlAOMGrid:SeekLine({{"AOM_NIVPAI",cNivelPai}})
	nLinha := oMdlAOMGrid:GetLine()
	For nX := nLinha To oMdlAOMGrid:Length()
		oMdlAOMGrid:GoLine(nX)
		If oMdlAOMGrid:GetValue("AOM_NIVPAI") == cNivelPai
			oTree:TreeSeek(cNivelPai)
				CRM910BMTree(oTree,oMdlAOMGrid,aCampos,oMdlAOMGrid:GetValue("AOM_CODNIV"), aDataADJ)				
			oMdlAOMGrid:GoLine(nX)
		EndIf
	Next nX
EndIf

Return(.T.)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRM910BOL
Retorna os agrupador selecionado pelo usuario.

@sample	CRM910BOL(oMdlAOL,aCodAgrup,aFilEnt)

@param		Nenhum
@return	ExpC - String dos Agrupadores Selecionados.

@author	SI2901 - Cleyton F.Alves
@since		10/06/2015
@version	12
/*/
//-----------------------------------------------------------------------------
Static Function CRM910BOL(oMdlAOL)

Local aAreaAOL		:= AOL->(GetArea())
Local aLoadAOL   	:= {}
Local oStructAOL 	:= oMdlAOL:GetStruct()
Local aCampos    	:= oStructAOL:GetFields()
Local cMacro     	:= ""
Local cCodAgr    	:= ""
Local cAliasAgr  	:= GetNextAlias()
Local nX         	:= 0
Local nY			:= 0
Local cQuery     	:= ""
Local lMarcado   	:= .T.
Local lCustomTree	:= Findfunction( "P_A910BCustomTree" ) //Ponto de entrada específico para o TDI para montar um tree customizado
Local aCustom		:= {}

If lCustomTree

	aCustom := P_A910BCustomTree()
	
	If !Empty( aCustom ) 
		AOL->( DbSetOrder( 1 ) )
		If AOL->( DbSeek( xFilial( "AOL" ) + aCustom[1] ) )
			aAdd(aLoadAOL,{AOL->(Recno()) ,{} })
			For nY := 1 To Len(aCampos)
				If !aCampos[nY][MODEL_FIELD_VIRTUAL]
					cMacro := "AOL->"+ALlTrim(aCampos[nY][MODEL_FIELD_IDFIELD])
				Else
					If aCampos[nY][MODEL_FIELD_IDFIELD] == "AOL_DSCENT"
						cMacro := "AllTrim(Posicione('SX2',1,AOL->AOL_ENTIDA,'X2NOME()'))"
					ElseIf aCampos[nY][MODEL_FIELD_IDFIELD] == "AOL_MARK"
						cMacro := Iif(lMarcado,".T.",".F.")
						lMarcado := .F.
					Else
						cMacro := AllTrim(aCampos[nY][MODEL_FIELD_INIT])
					EndIf
				EndIf
				
				aAdd(aLoadAOL[Len(aLoadAOL),2] , &cMacro )
			Next nY
			
		EndIf
	EndIf
Else
	
	BeginSQL Alias cAliasAgr
		SELECT DISTINCT AOL.R_E_C_N_O_ AS RECNUM
		FROM
		%Table:AOL%  AOL,
		%Table:ADJ%  ADJ
		WHERE
		AOL.AOL_FILIAL  = %xFilial:AOL% AND
		ADJ.ADJ_FILIAL  = %xFilial:ADJ% AND
		AOL.AOL_CODAGR  = ADJ.ADJ_CODAGR AND
		ADJ.ADJ_NROPOR  = %Exp:AD1->AD1_NROPOR% AND
		ADJ.ADJ_REVISA  = %Exp:AD1->AD1_REVISA% AND
		AOL.AOL_MSBLQL <> '1' AND
		ADJ.%NotDel%  AND
		AOL.%NotDel%
	EndSql
	
	While (cAliasAgr)->(!Eof())
		
		AOL->(DBGoTo( (cAliasAgr)->RECNUM) )
		
		aAdd(aLoadAOL,{AOL->(Recno()) ,{} })
		
		For nY := 1 To Len(aCampos)
			If !aCampos[nY][MODEL_FIELD_VIRTUAL]
				cMacro := "AOL->"+ALlTrim(aCampos[nY][MODEL_FIELD_IDFIELD])
			Else
				If aCampos[nY][MODEL_FIELD_IDFIELD] == "AOL_DSCENT"
					cMacro := "AllTrim(Posicione('SX2',1,AOL->AOL_ENTIDA,'X2NOME()'))"
				ElseIf aCampos[nY][MODEL_FIELD_IDFIELD] == "AOL_MARK"
					cMacro := Iif(lMarcado,".T.",".F.")
					lMarcado := .F.
				Else
					cMacro := AllTrim(aCampos[nY][MODEL_FIELD_INIT])
				EndIf
			EndIf
			
			aAdd(aLoadAOL[Len(aLoadAOL),2] , &cMacro )
		Next nY
		
		(cAliasAgr)->(DBSkip())
		
	EndDo
	
	(cAliasAgr)->(DBCloseArea())
	
EndIf

RestArea(aAreaAOL)

Return(aLoadAOL)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRM910BOM

Retorna os agrupador selecionado pelo usuario.

@sample	CRM910BOM(oMdlAOL,aCodAgrup)

@param		Nenhum
@return	ExpC - String dos Agrupadores Selecionados.

@author	SI2901 - Cleyton F.Alves
@since		10/06/2015
@version	12
/*/
//-----------------------------------------------------------------------------
Static Function CRM910BOM(oMdlAOM,cCodAgr)

Local aLoadAOM   := {}
Local oStructAOM := oMdlAOM:GetStruct()
Local aCampos    := oStructAOM:GetFields()
Local cMacro     := ""
Local nY         := 0

If AOM->(dbSeek(xFilial("AOM")+cCodAgr))
	WHile AOM->(!Eof()) .And. AOM->AOM_FILIAL == xFilial("AOM") .And. AllTrim(AOM->AOM_CODAGR) == AllTrim(cCodAgr)
		aAdd(aLoadAOM,{AOM->(Recno()) ,{} })	
		For nY := 1 To Len(aCampos)	
			If !aCampos[nY][MODEL_FIELD_VIRTUAL]
				cMacro := "AOM->"+ALlTrim(aCampos[nY][MODEL_FIELD_IDFIELD])
			Else
				If aCampos[nY][MODEL_FIELD_IDFIELD] == "AOM_MARK"
					cMacro := ".F."
				Else
					cMacro := AllTrim(aCampos[nY][MODEL_FIELD_INIT])
				EndIf
			EndIf

			aAdd(aLoadAOM[Len(aLoadAOM),2] , &cMacro )
		Next nY
		AOM->(dbSkip())
	EndDo	
EndIf

Return(aLoadAOM)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRM910BB1

Retorna os Produtos vinculados ao agrupador e/ou a Oferta

@sample	CRM910BB1(oMdlSB1,oMdlAOM,oMdlAOL)

@param		oMdlAOL - Modelo da tabela AOL - Agrupador x Entidade
			oMdlAOM - Modelo da tabela AOM - Niveis do Agrupador
			oMdlSB1 - Modelo da tabela AOL - Cadastro de Produtos 
@return	ExpC - String dos Agrupadores Selecionados.

@author	SI2901 - Cleyton F.Alves
@since		10/06/2015
@version	12
/*/
//-----------------------------------------------------------------------------
Static Function CRM910BB1(oMdlSB1,oMdlAOM,oMdlAOL)
Local oStructSB1:= oMdlSB1:GetStruct()
Local aField	:= oStructSB1:GetFields()
Local cTemp		:= GetNextAlias()
Local aLoad		:= {}
Local aPackages	:= {}
Local cMacro	:= ""
Local cPool		:= ""
Local cLevel	:= ""
Local cType		:= ""
Local cEntity	:= ""
Local cQuery	:= ""
Local cBkpQuery	:= ""
Local cOffer	:= ""
Local cType		:= ""
Local nField	:= 0
Local lIniPad 	:= .F.

Local oMdlOff	:= Nil
Local oMdlAZN	:= Nil
Local oMdlAZk	:= Nil

Local lC910BQRY	:= ExistBlock("C910BQRY")

	checkV1227()

	If Empty(cOffer) .AND. Empty(cType)
		If lReleaseV12
			cOffer := AZN->AZN_CODIGO
			cType := AZK->AZK_AGREGA
		EndIf
	EndIf
		  
	cPool		:= oMdlAOL:GetValue("AOL_CODAGR")
	cType		:= oMdlAOL:GetValue("AOL_TIPO")
	cEntity		:= oMdlAOL:GetValue("AOL_ENTIDA")
	cLevel		:= oMdlAOM:GetValue("AOM_CODNIV")
					
	If ( ADJ->( DBSeek( xFilial("ADJ") + AD1->AD1_NROPOR + AD1->AD1_REVISA + cPool + cLevel ) ) )
		//-------------------------------------------------------------------
		// Recupera a instrução SQL no nível do agrupador.  
		//-------------------------------------------------------------------			
		cQuery 	:= CRMA580GetSQL( cPool, cLevel ) 
		
		If lC910BQRY
			
			cBkpQuery := cQuery
			
			cQuery := ExecBlock("C910BQRY",.F.,.F.,{cQuery})
			
			If ValType(cQuery) <> "C" .or. Empty(cQuery)
				
				cQuery := cBkpQuery
			
			EndIf
			
		EndIf
		
		If CRM910BIsOffer() // aki
			aPackages :=  CRM910LdOoffer()
			cQuery := CRM910OfQr(cQuery,cType,cOffer,aPackages)
		EndIf
		
		//-------------------------------------------------------------------
		// Executa a instrução SQL.  
		//-------------------------------------------------------------------	
		DBUseArea( .T., "TOPCONN", TCGenQry( ,, ChangeQuery( cQuery ) ), cTemp, .F., .T. )

		While (cTemp)->( ! Eof() )	
			SB1->( DBGoTo( (cTemp)->R_E_C_N_O_ ) )
		
			aAdd( aLoad, { SB1->( Recno() ), {} } )	
		
			For nField := 1 To Len( aField )	
				lIniPad := .F.
				
				If ! ( aField[nField][MODEL_FIELD_VIRTUAL] )
					cMacro := "SB1->" + ALlTrim( aField[nField][MODEL_FIELD_IDFIELD] )
				Else
					If ( aField[nField][MODEL_FIELD_IDFIELD] == "B1_MARK" )
						cMacro := ".F."
					ElseIf ( aField[nField][MODEL_FIELD_IDFIELD] == "B1_CODAGR" )
						cMacro := "cPool"
					ElseIf ( aField[nField][MODEL_FIELD_IDFIELD] == "B1_CODNIV" )
						cMacro := "cLevel"
					ElseIf ( aField[nField][MODEL_FIELD_IDFIELD] == "B1_DSCGRU" )
						cMacro := "Posicione('SBM',1,xFilial('SBM')+SB1->B1_GRUPO,'BM_DESC')"
					Else
						cMacro := AllTrim(aField[nField][MODEL_FIELD_INIT])
						lIniPad := .T.
					EndIf
				EndIf
		
				If ! ( lIniPad )
					aAdd( aLoad[ Len(aLoad), 2 ] , &cMacro )
				Else
					aAdd( aLoad[ Len(aLoad), 2 ] , cMacro )
				EndIf
			Next nField
		
			(cTemp)->( DBSkip() )
		EndDo	
		
		(cTemp)->( DBCloseArea() )
	EndIf
Return ( aLoad ) 
//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRM910BZL

Retorna as ofertas vinculadas 

@sample	CRM910BZL(oMdlAZL,oMdlAOM,oMdlAOL)

@param		Nenhum
@return	ExpC - String dos Agrupadores Selecionados.

@author	SI2901 - Cleyton F.Alves
@since		10/06/2015
@version	12
/*/
//-----------------------------------------------------------------------------
Static Function CRM910BZL(oMdlAZL,oMdlAOM,oMdlAOL)

Local aLoadAZL	:= {}

Local oStructAZL:= oMdlAZL:GetStruct()
Local aCampos	:= oStructAZL:GetFields()
Local aLoadAZL  := {}
Local cMacro	:= ""
Local nY		:= 0
Local dDataAtu  := dDataBase
Local lValLog	:= .T.

Local cCodAgr	:= oMdlAOL:GetValue("AOL_CODAGR")
Local cCodNiv	:= oMdlAOM:GetValue("AOM_CODNIV")
Local lMacro 	:= .F.
Local cFilAZL	:= xFilial("AZL")
Local cFilAZJ	:= xFilial("AZJ")

If AZL->(dbSeek(cFilAZJ+cCodAgr+cCodNiv))
	While AZL->(!Eof()) .And. AZL->AZL_FILIAL == cFilAZL .And. ;
		  AllTrim(AZL->AZL_CODAGR) == AllTrim(cCodAgr) .And. ;
		  AllTrim(AZL->AZL_CODNIV) == AllTrim(cCodNiv)
		
		If AZJ->(dbSeek(cFilAZJ+AZL->AZL_CODOFE))
			If dDataAtu >= AZJ->AZJ_VIGDE .And. dDataAtu <= AZJ->AZJ_VIGATE
				If lValLog
					aAdd(aLoadAZL,{AZL->(Recno()) ,{} })	
					For nY := 1 To Len(aCampos)
						lMacro := .T.	
						If !aCampos[nY][MODEL_FIELD_VIRTUAL]
							cMacro := "AZL->"+ALlTrim(aCampos[nY][MODEL_FIELD_IDFIELD])
						ElseIf aCampos[nY][MODEL_FIELD_IDFIELD] == "AZL_MARK"
							cMacro := ".F."
						ElseIF aCampos[nY][MODEL_FIELD_IDFIELD] == "AZL_DESCRI"
							cMacro := 'POSICIONE("AZJ",1,XFILIAL("AZJ")+AZL->AZL_CODOFE,"AZJ_DESCRI")'
						else
							cMacro := aCampos[nY][MODEL_FIELD_INIT]
						EndIf

						aAdd(aLoadAZL[Len(aLoadAZL),2] , &cMacro )

					Next nY
				EndIf
			EndIf
		EndIf
		AZL->(dbSkip())
	EndDo	
EndIf

Return(aLoadAZL)
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMMarkAOL

Controla o campo AOL_MARK do GRID AOL para permitir apenas uma linha marcada.

@sample	CRMVMarkSB1(oMdlAOL)

@param		oMdlAOL	- Objeto do modelo de dados atual.
@return	.T.			- Sempre retorna verdadeiro para efetivar a validacao.

@author	Cleyton F.Alves
@since		10/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRMMarkAOL(oMdlAOL)

Local oView		:= FwViewActive()
Local nLinAtu	:= oMdlAOL:GetLine()  
Local lMark	 	:= oMdlAOL:GetValue("AOL_MARK")
Local nX		:= 0

If lMarkUniq
	For nX := 1 To oMdlAOL:Length()
		oMdlAOL:GoLine(nX)
		oMdlAOL:LoadValue("AOL_MARK",.F.)
	Next nX

	oMdlAOL:GoLine(nLinAtu)
	oMdlAOL:LoadValue("AOL_MARK",.T.)
Else
	oMdlAOL:GoLine(nLinAtu)
	lMark := oMdlAOL:GetValue("AOL_MARK")
	oMdlAOL:LoadValue("AOL_MARK",lMark)
EndIf

oView:Refresh()

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMMarkAZK

Controla o campo AOL_MARK do GRID AOL para permitir apenas uma linha marcada.

@sample	CRMMarkAZK(oMdlAZK)

@param		oMdlAZK	- Objeto do modelo de dados atual.
@return	.T.			- Sempre retorna verdadeiro para efetivar a validacao.

@author	Cleyton F.Alves
@since		10/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMMarkAZK()

Local oModelPr  := FwModelActivate()

Local oMdlAZK	  := oModelPr:GetModel("AZKDETAIL")
Local lMark	 	:= oMdlAZK:GetValue("AZK_MARK")
Local cCodOfer	:= oMdlAZK:GetValue("AZK_CODIGO")
Local cItOfer	:= oMdlAZK:GetValue("AZK_ITOFER")

Local oMdlSB1	:= oModelPr:GetModel("SB1DETAIL")

Local oMdlAOM	:= oModelPr:GetModel("AOMDETAIL")
Local cCodAgr	:= oMdlAOM:GetValue("AOM_CODAGR")
Local cCodNiv	:= oMdlAOM:GetValue("AOM_CODNIV")

Local oView		:= FwViewActive()
Local nY		:= 0
Local oTree		:= CRMA580DGTree()
Local cFilAZN	:= xFilial("AZN")
Local cFilAZO	:= xFilial("AZO")
Local cFilSB1   := xFilial("SB1")
Local cFilSBM	:= xFilial('SBM')

AZN->(DbSetOrder(1))
AZO->(DbSetOrder(1))

oMdlSB1:SetNoDeleteLine(.F.)
oMdlSB1:SetNoInsertLine(.F.)

If lMark
	If AZN->(dbSeek(cFilAZN+cCodOfer+cItOfer))

		While AZN->(!Eof()) .And. AZN->AZN_FILIAL == cFilAZN .And. AZN_CODIGO == cCodOfer .And. AZN_ITOFER == cItOfer 
			
			If SB1->(dbSeek(cFilSB1+AZN->AZN_PRODUT))

				If oMdlSB1:SeekLine({{"B1_COD",AllTrim(AZN->AZN_PRODUT)}},.T.)
					If oMdlSB1:IsDeleted()
						oMdlSB1:UndeleteLine()
					EndIf
				Else
					If !oMdlSB1:IsEmpty() 
						oMdlSB1:AddLine()
					EndIf 
					oMdlSB1:LoadValue("B1_CARGA","S")
					oMdlSB1:LoadValue("B1_MARK"   ,.F.)
					oMdlSB1:LoadValue("B1_COD"     ,SB1->B1_COD)
					oMdlSB1:LoadValue("B1_DESC"    ,SB1->B1_DESC)
					oMdlSB1:LoadValue("B1_TIPO"    ,SB1->B1_TIPO)
					oMdlSB1:LoadValue("B1_UM"      ,SB1->B1_UM) 
					oMdlSB1:LoadValue("B1_GRUPO"   ,SB1->B1_GRUPO)
					oMdlSB1:LoadValue("B1_DSCGRU" ,AllTrim(Posicione('SBM',1,cFilSBM+SB1->B1_GRUPO,'BM_DESC')))
				EndIf
				
				If AZN->AZN_OBRIGA == "1"
					oMdlSB1:LoadValue("B1_MARK",.T.)
					oMdlAOM:LoadValue("AOM_MARK",.T.)
					oTree:ChangeBmp("LBOK","LBOK",,,oMdlAOM:GetValue("AOM_CODNIV"))
					
				EndIf
				oMdlSB1:LoadValue("B1_CODAGR" ,cCodagr)
				oMdlSB1:LoadValue("B1_CODNIV" ,cCodNiv)
				oMdlSB1:LoadValue("B1_CODOFE" ,cCodOfer)
				oMdlSB1:LoadValue("B1_ITOFER" ,cItOfer)
				
			EndIf
			
			AZN->(dbSkip())
		EndDo
	EndIf

	If AZO->(dbSeek(xFilial("AZO")+cCodOfer+cItOfer))

		While AZO->(!Eof()) .And. ( AZO->AZO_FILIAL == cFilAZO .And. AZO->AZO_CODIGO == cCodOfer .And. AZO->AZO_ITOFER == cItOfer )
					
			If SB1->(dbSeek(xFilial("SB1")+AZO->AZO_ACESSO))

				If oMdlSB1:SeekLine({{"B1_COD",AllTrim(AZO->AZO_ACESSO)}},.T.)
					If oMdlSB1:IsDeleted()
						oMdlSB1:UndeleteLine()
					EndIf
				Else
					If !oMdlSB1:IsEmpty() 
						oMdlSB1:AddLine()
					EndIf 
					oMdlSB1:LoadValue("B1_CARGA","S")
					oMdlSB1:LoadValue("B1_MARK"   ,.F.)
					oMdlSB1:LoadValue("B1_COD"     ,SB1->B1_COD)
					oMdlSB1:LoadValue("B1_DESC"    ,SB1->B1_DESC)
					oMdlSB1:LoadValue("B1_TIPO"    ,SB1->B1_TIPO)
					oMdlSB1:LoadValue("B1_UM"      ,SB1->B1_UM) 
					oMdlSB1:LoadValue("B1_GRUPO"   ,SB1->B1_GRUPO)
					oMdlSB1:LoadValue("B1_DSCGRU" ,AllTrim(Posicione('SBM',1,cFilSBM+SB1->B1_GRUPO,'BM_DESC')))
										
				EndIf
				
				oMdlSB1:LoadValue("B1_MARK",.T.)				
				oMdlSB1:LoadValue("B1_CODAGR" ,cCodagr)
				oMdlSB1:LoadValue("B1_CODNIV" ,cCodNiv)
				oMdlSB1:LoadValue("B1_CODOFE" ,cCodOfer)
				oMdlSB1:LoadValue("B1_ITOFER" ,cItOfer)
				
			EndIf
			
			AZO->(dbSkip())
			
		EndDo
	EndIf

Else
	For nY:=1 To oMdlSB1:Length()

		oMdlSB1:GoLine(nY)
		
		If oMdlSB1:GetValue("B1_CODOFE") == cCodOfer .And. oMdlSB1:GetValue("B1_ITOFER") == cItOfer
			If oMdlSB1:GetValue("B1_CARGA") == "S"
				oMdlSB1:LoadValue("B1_MARK"  ,.F.)
				If !oMdlSB1:IsDeleted()
					oMdlSB1:DeleteLine()
				EndIf
			Else
				oMdlSB1:LoadValue("B1_CODOFE","")
				oMdlSB1:LoadValue("B1_ITOFER","")
			EndIf
		EndIf
	Next nY
EndIf

oMdlSB1:SetNoDeleteLine(.T.)
oMdlSB1:SetNoInsertLine(.T.)

oView:Refresh()
Return ( .T. )
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMMarkSB1

Controla o campo AOL_MARK do GRID AOL para permitir apenas uma linha marcada.

@sample	CRMMarkSB1(oMdlAOL)

@param		oMdlAOL	- Objeto do modelo de dados atual.
@return	.T.			- Sempre retorna verdadeiro para efetivar a validacao.

@author	Cleyton F.Alves
@since		10/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRMMarkSB1(oMdlSB1)
	Local oModelPr  := FwModelActivate()
	Local oView		:= FwViewActive()
	Local oMdlAOM	:= oModelPr:GetModel("AOMDETAIL")
	Local nLinAtu	:= oMdlSB1:GetLine()  
	Local lMark	 	:= oMdlSB1:GetValue("B1_MARK")
	Local nX		:= 0
	Local oTree		:= CRMA580DGTree()
	Local lRet		:= .T.
	
	If !( Empty( oMdlSB1:GetValue("B1_COD") ) )
		If( oMdlSB1:SeekLine( { {"B1_MARK",.T. } } ) )
			oMdlAOM:LoadValue("AOM_MARK", .T. )
			oTree:ChangeBmp("LBOK","LBOK",,,oMdlAOM:GetValue("AOM_CODNIV"))
		Else
			oMdlAOM:LoadValue("AOM_MARK", .F. )
			oTree:ChangeBmp("LBNO","LBNO",,,oMdlAOM:GetValue("AOM_CODNIV"))		

			If lReleaseV12
				If AZN->(dbSeek(xFilial("AZN")+oMdlSB1:GetValue("B1_CODOFE")+oMdlSB1:GetValue("B1_ITOFER")+oMdlSB1:GetValue("B1_COD")))
					If AZN->AZN_OBRIGA == "1"
						oMdlSB1:LoadValue("B1_MARK",.T.)
						Help( ,,'CRMA910OBRIGAT',,STR0033,1,0)//"Item obrigatório na seleção da oferta"
					EndIf	
				EndIf
			EndIf
		EndIf 

	Else
		lRet := .F.
		oModelPr:SetErrorMessage(,, oModelPr:GetId(),, "CRMMarkSB1", STR0037, STR0038,, ) //"Não contém dados na linha!"###"Selecione outro nível."
	EndIf
Return ( lRet )

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRM910Bgrv

Retorna os agrupador selecionado pelo usuario.

@sample	CRM910BGRV(oMdlAOL,aCodAgrup)

@param		Nenhum

@return	ExpC - String dos Agrupadores Selecionados.

@author	SI2901 - Cleyton F.Alves
@since		10/06/2015
@version	12
/*/
//-----------------------------------------------------------------------------
Static Function CRM910BGRV(oModel)

Local aReturn   := {}
Local oMdlAOL   := oModel:GetModel("AOLDETAIL")
Local oMdlAOM   := oModel:GetModel("AOMDETAIL")
Local oMdlSB1   := oModel:GetModel("SB1DETAIL")
Local nz        := 0
Local nx        := 0
Local ny		:= 0
Local cCodProd  := ""
Local cDescProd := ""
Local cUnidade  := ""
Local cTES      := ""
Local cTabPrc	  := ""	
Local nQuant    := 1

For nz := 1 To oMdlAOL:Length()
	oMdlAOL:GoLine(nz)
	If oMdlAOL:GetValue("AOL_MARK")

		For nx := 1 To oMdlAOM:Length()
			oMdlAOM:GoLine(nx)
			If oMdlAOM:GetValue("AOM_MARK")

				For ny := 1 To oMdlSB1:Length() 
					oMdlSB1:GoLine(ny)
					If oMdlSB1:GetValue("B1_MARK")
						
						AZ0->( DbSetOrder( 1 ) )//AZ0_FILIAL+AZ0_CODAGR+AZ0_CODNIV+AZ0_ENTIDA+AZ0_CAMPO+AZ0_CONDIC+AZ0_DE
						If AZ0->( DbSeek( xFilial( "AZ0" ) + oMdlAOL:GetValue( "AOL_CODAGR" ) + oMdlAOM:GetValue( "AOM_CODNIV" ) + "DA0" ) )
							cTabPrc := AllTrim( AZ0->AZ0_DE )
						EndIf
						If lReleaseV12
							aAdd(aReturn,{oMdlSB1:GetValue("B1_COD"),oMdlAOL:GetValue("AOL_CODAGR"),oMdlAOM:GetValue("AOM_CODNIV"),oMdlSB1:GetValue("B1_CODOFE"),oMdlSB1:GetValue("B1_ITOFER"),oMdlSB1:GetValue("B1_CARGA"), cTabPrc })
						Else
							aAdd(aReturn,{oMdlSB1:GetValue("B1_COD"),oMdlAOL:GetValue("AOL_CODAGR"),oMdlAOM:GetValue("AOM_CODNIV") })
						EndIf
						cTabPrc := ""
					EndIf
				Next ny

			EndIf
		Next nx

	EndIf
Next nz

aRetGrid := aClone(aReturn)

Return(aReturn)


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM910BChg

Funcao que marca e desmarca o DbTree

@sample		CRM910BChg(oTree,oViewActive,oMdlActive)

@param		ExpO1 - Componente DBTree
			ExpO2 - FwFormView do Agrupador de Registros
			ExpO3 - MPFormModel do Agrupador de Registros

@return		Nenhum

@author		Cleyton F.Alves
@since		10/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM910BChg(oTree,oViewActive,oMdlActive)
	
Local oMdlAOMGrid	:= oMdlActive:GetModel("AOMDETAIL")
Local cIdTree		:= AllTrim(oTree:GetCargo())

If cIdTree <> CRMA580Root()
	oMdlAOMGrid:SeekLine({{"AOM_CODNIV",cIdTree}})
EndIf
	
oViewActive:Refresh()
	
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA910BVLD

CRMA910BVLD - Valida o OK do modelo

@sample		CRMA910BVLD()

@return		Verdadeiro ou Falso

@author		Cleyton F.Alves
@since		10/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRMA910BVLD(oModel)

Local oMdlAOL   := oModel:GetModel("AOLDETAIL")
Local oMdlAOM   := oModel:GetModel("AOMDETAIL")
Local oMdlSB1   := oModel:GetModel("SB1DETAIL")
Local oMdlAZK   := oModel:GetModel("AZKDETAIL")
Local oMdlAZL   := oModel:GetModel("AZLDETAIL")
Local nzAtu     := oMdlAOL:GetLine()
Local nxAtu     := oMdlAOM:GetLine()
Local nyAtu		:= oMdlSB1:GetLine()
Local nwAtu     := oMdlAZK:GetLine()
Local nz        := 0
Local nx        := 0
Local ny		:= 0
Local nw		:= 0
Local nPos		:= 0
Local lRet		:= .T.
Local aReturn	:= {}
Local cFilAZK 	:= xFilial("AZK")

For nz := 1 To oMdlAOL:Length()
	oMdlAOL:GoLine(nz)

	If oMdlAOL:GetValue("AOL_MARK")

		For nx := 1 To oMdlAOM:Length()
			oMdlAOM:GoLine(nx)

			If oMdlAOM:GetValue("AOM_MARK")

				For ny := 1 To oMdlSB1:Length() 
					oMdlSB1:GoLine(ny)

					If oMdlSB1:GetValue("B1_MARK")

						If oMdlAZK:SeekLine({{"AZK_CODIGO",oMdlSB1:GetValue("B1_CODOFE")},{"AZK_ITOFER",oMdlSB1:GetValue("B1_ITOFER")}})
							If oMdlAZK:GetValue("AZK_MARK")
					
								nPos := aScan(aReturn,{|x| x[1]+x[2] == oMdlSB1:GetValue("B1_CODOFE")+oMdlSB1:GetValue("B1_ITOFER")})
					
								If nPos == 0
									aAdd(aReturn,{oMdlSB1:GetValue("B1_CODOFE"),oMdlSB1:GetValue("B1_ITOFER"),0,0})
									nPos := Len(aReturn)
								EndIf

								aReturn[nPos,3] += 1

							EndIf
						EndIf

					EndIf

				Next ny

			EndIf

		Next nx

	EndIf

Next nz

For nx:=1 To Len(aReturn)
	If AZK->(dbSeek(cFilAZK+aReturn[nx,1]+aReturn[nx,2]))
		If aReturn[nx,3] < AZK->AZK_SELMIN .Or. aReturn[nx,3] > AZK->AZK_SELMAX
			lRet := .F.
		EndIf
	EndIf
Next nx

oMdlAOL:GoLine(nzAtu)
oMdlAOM:GoLine(nxAtu)
oMdlSB1:GoLine(nyAtu)
oMdlAZK:GoLine(nwAtu)

If !lRet
	Help(,,"AT600VLO",,"Verifique a quantidade mínima e máxima de marcações nas ofertas selecionadas.",1,0)
EndIf

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} A910BTreeTDI

**Específico para a TOTVS TDI**

Monta uma tree específica na proposta a partir do código do agrupador + nível
informado pela TDI através de execução de Ponto do Entrada A910BCustomTree() 
**Mostra apenas parte da estrutura.

@sample	A910BTreeTDI( cCodAgr, cCodNiv, oMdlAOMGrid )

@param		ExpC1 - Código do agrupador
			ExpC2 - Código do nível
			ExpO1 - Objeto do modelo da grid da AOM
			
@return	ExpA - Array contendo as informações ordenadas para montar a tree.

@author	Thamara Villa
@since		14/10/2015
@version	12.1.7
/*/
//------------------------------------------------------------------------------
Static Function A910BTreeTDI( cCodAgr, cCodNiv, oMdlAOMGrid )

Local aTree   := {}
Local nCount	:= 0

Default cCodAgr := ""
Default cCodNiv := ""

AOM->( DbSetOrder( 1 ) ) //AOM_FILIAL+AOM_CODAGR+AOM_CODNIV
If AOM->( DbSeek( xFilial( "AOM" ) + cCodAgr + cCodNiv ) )
	For nCount := 1 To  oMdlAOMGrid:Length()
		If oMdlAOMGrid:SeekLine( { { "AOM_CODAGR", cCodAgr }, { "AOM_CODNIV", cCodNiv } } )
			oMdlAOMGrid:GoLine( oMdlAOMGrid:GetLine() )
			aAdd( aTree, { oMdlAOMGrid:GetValue( "AOM_CODAGR" ), oMdlAOMGrid:GetValue( "AOM_CODNIV" ), oMdlAOMGrid:GetValue( "AOM_NIVPAI" ) }  )
			cCodNiv := oMdlAOMGrid:GetValue( "AOM_NIVPAI" ) 
		EndIf		
	Next( nCount )
	
	aSort( aTree, , , { |x,y| x[3] < y[3] } )
	
Else
	Help( ,, 'A910BTreeTDI',, STR0035, 1, 0 ) //'Não foi encontrado o agrupador/nível informado, por favor verifique.'	
EndIf

Return( aTree )
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM910BIsOffer

**Específico para a TOTVS TDI**

Valida se a View do agrupador de produtos da proposta comercial deverá ser a versão completa (com oferta)
ou simplificada (apenas produtos). Caso algum dos agrupadores envolvidos na oportunidade de negócio possuam uma oferta,
o sistema carrega uma view mais detalhada com janelas para pacotes e ofertas.

@sample	CRM910BIsOffer( )

@return	lRet

@author	Renato da Cunha
@since		28/12/2015
@version	12.1.7
/*/
//------------------------------------------------------------------------------
Static Function CRM910BIsOffer()

Local lRet	 	:= .F.
Local nX	 	:= 0
Local oMdlADJ 	:= Nil
Local cFilAZL	:= xFilial("AZL")

checkV1227()

If lReleaseV12

	DbSelectArea("AZL")
	AZL->(DbSetOrder(1)) //AZL_FILIAL+AZL_CODAGR+AZL_CODNIV+AZL_CODOFE
	
	If ValType("oMdlOpor") <> "U"
		oMdlADJ := oMdlOpor:GetModel("ADJDETAIL")
		For nX := 1 To oMdlADJ:Length()
			oMdlADJ:GoLine(nX)
			cCodAgr := oMdlADJ:GetValue("ADJ_CODAGR")
			If !Empty( cCodAgr )
				If AZL->( DbSeek( cFilAZL + oMdlADJ:GetValue("ADJ_CODAGR") + oMdlADJ:GetValue("ADJ_CODNIV")  ) )
					lRet := .T.
					Exit
				EndIf
			EndIf
		Next nX
	EndIf
EndIf

Return ( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM910OfQr


Valida se a View do agrupador de produtos da proposta comercial deverá ser a versão completa (com oferta)
ou simplificada (apenas produtos). Caso algum dos agrupadores envolvidos na oportunidade de negócio possuam
uma oferta, o sistema carrega uma view mais detalhada com janelas para pacotes e ofertas.

@sample	CRM910OfQr( )

@param cQuery - Query utilizada para retornar os produtos do agrupador
@param nType - Tipo de query a ser executada
@param cOffer - Código da oferta
@return	cNewQuery - Query com 1) Union  ou 3) Exist

@author	Renato da Cunha
@since		01/06/2016
@version	12.1.7 
/*/
//------------------------------------------------------------------------------

Static Function CRM910OfQr(cQuery,cType,cOffer, aPackages)

Local cNewQuery	:=	""
Local nX		:= 0
Local nLenPack	:= 0

Default aPackages	:= {}
Default cQuery		:= ""
Default cType		:= ""
Default cOffer		:= ""

	If cType $ "1|2" 
			
		cNewQuery += cQuery + " UNION"
		cNewQuery += " SELECT SB1.R_E_C_N_O_"
		cNewQuery += " FROM "
		cNewQuery +=  RetSQLName( "SB1" )+" SB1 INNER JOIN "
		cNewQuery +=  RetSQLName( "AZN" )+" AZN ON B1_COD = AZN.AZN_PRODUT"	
		cNewQuery += " WHERE"
		cNewQuery += " B1_FILIAL = '" + xFilial( "SB1" ) + "' "
		cNewQuery += " AND AZN.AZN_FILIAL = '" + xFilial( "AZN" ) + "'"
		cNewQuery += " AND AZN.AZN_CODIGO = '" + cOffer + "'"
		cNewQuery += " AND SB1.D_E_L_E_T_ = ' ' "
		cNewQuery += " AND AZN.D_E_L_E_T_ = ' ' "
		cNewQuery += " UNION"
		cNewQuery += " SELECT SB1.R_E_C_N_O_"
		cNewQuery += " FROM "
		cNewQuery +=  RetSQLName( "SB1" )+" SB1 INNER JOIN "
		cNewQuery +=  RetSQLName( "AZO" )+" AZO ON B1_COD = AZO.AZO_ACESSO"	
		cNewQuery += " WHERE"
		cNewQuery += " B1_FILIAL = '" + xFilial( "SB1" ) + "'"
		cNewQuery += " AND AZO.AZO_FILIAL = '" + xFilial( "AZO" ) + "'"
		
		cNewQuery  += " AND ( "
		
		nLenPack := Len (aPackages)
			
		For nX:= 1 To nLenPack 
			
			cNewQuery += " AZO.AZO_CODIGO = '" + aPackages[nX] + "'"
			
			If nX <> nLenPack
				cNewQuery += " OR "
			EndIF 
					
		Next nX
		
		cNewQuery += "  ) "
		cNewQuery += " AND SB1.D_E_L_E_T_ = ' ' "
		cNewQuery += " AND AZO.D_E_L_E_T_ = ' ' "
		
	Elseif cType == "3"
		
		cNewQuery += " SELECT SB1.R_E_C_N_O_"
		cNewQuery += " FROM "
		cNewQuery +=  RetSQLName( "SB1" )+" SB1 INNER JOIN "
		cNewQuery +=  RetSQLName( "AZN" )+" AZN ON B1_COD = AZN.AZN_PRODUT"	
		cNewQuery += " WHERE"
		cNewQuery += " B1_FILIAL = '" + xFilial( "SB1" ) + "' AND "
		cNewQuery += " AZN.AZN_FILIAL = '" + xFilial( "AZN" ) + "' AND "
		cNewQuery += " AZN.AZN_CODIGO = '" + cOffer + "' AND"
		cNewQuery += " SB1.D_E_L_E_T_ = ' ' AND"
		cNewQuery += " AZN.D_E_L_E_T_ = ' ' AND"
		cNewQuery += " Exists( " + cQuery + ")"
	Else 
		cNewQuery := cQuery
	EndIf

Return ( cNewQuery )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM910LdOoffer()

Retorna todos os pacotes da oferta vinculada ao agrupador

@sample	CRM910LdOoffer()

@return	aPackages

@author	Renato da Cunha
@since		02/06/2016
@version	12.1.7 
/*/
//------------------------------------------------------------------------------
Static Function CRM910LdOoffer()

Local aPackages	:= {}
Local aAreaAZL	:= {} 
Local nX	 	:= 0
Local oMdlADJ	:= Nil
Local cFilAZL	:= xFilial("AZL")

aAreaAZL := AZL->(GetArea())

DbSelectArea("AZL")
AZL->(DbSetOrder(1)) //AZL_FILIAL+AZL_CODAGR+AZL_CODNIV+AZL_CODOFE

If ValType("oMdlOpor") <> "U"
	
	oMdlADJ := oMdlOpor:GetModel("ADJDETAIL")
	cAgrup	:= oMdlADJ:GetValue("ADJ_CODAGR") 
	cCodNiv	:= oMdlADJ:GetValue("ADJ_CODNIV")
	
	If AZL->( DbSeek( cFilAZL + cAgrup + cCodNiv ) )

		While AZL->(!Eof()) .AND. AZL->AZL_FILIAL == cFilAZL .AND. ;
		  		AZL->AZL_CODAGR == cAgrup .AND. AZL->AZL_CODNIV == cCodNiv
			
				 Aadd(aPackages, AZL->AZL_CODOFE )
				 AZL->(DbSkip())		
		EndDo

	EndIf

EndIf

RestArea( aAreaAZL )

Return ( aPackages )

//-----------------------------------------------------------------------
/*/{Protheus.doc} checkV1227()
Verifica a existência das tabelas AZK, AZL, AZM, AZN, AZO referente a
descida dos fontes do projeto v12 na TOTVS para o release 12.1.27

@sample checkV1227()

@author Squad CRM & Faturamento
@since  22/07/2020

@version 12.1.27
/*/
//-----------------------------------------------------------------------
Static Function checkV1227()
Local aTables := {'AZK','AZL','AZM','AZN','AZO'}
Local nX := 0

If lReleaseV12 == Nil
	If ( GetRPORelease() < "12.1.027" )
		For nX := 1 to Len( aTables )
			lReleaseV12 := AliasInDic( aTables[nX] )
			If !lReleaseV12
				Exit
			EndIf
		Next nX
	Else
		lReleaseV12 := .T.
	EndIf
EndIf

Return lReleaseV12
