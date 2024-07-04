#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PCPA124.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TbIconn.ch"
#INCLUDE "FWADAPTEREAI.CH"

Static lConfLista	:= .F.
Static slPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)

/*/{Protheus.doc} PCPA124
Manutenção de Processos Produtivos
@author Carlos Alexandre da Silveira
@since 07/05/2018
@version 1.0
@return NIL
/*/
Function PCPA124()
	Local aArea := GetArea()
	Local oBrowse

	Private lBrowse := .T.

	oBrowse := BrowseDef()
	oBrowse:Activate()

	RestArea(aArea)
Return Nil

Static Function BrowseDef()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SG2")
	oBrowse:SetDescription(STR0011) //STR0011 - Manutenção de processos produtivos
Return oBrowse

/*/{Protheus.doc} MenuDef
Definição do Menu
@author Carlos Alexandre da Silveira
@since 07/05/2018
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
Static Function MenuDef()
	Private aRotina := {}

	ADD OPTION aRotina TITLE STR0012 ACTION 'PCPA124MNU(2)' OPERATION OP_VISUALIZAR ACCESS 0 //STR0012 - Visualizar
	ADD OPTION aRotina TITLE STR0013 ACTION 'PCPA124MNU(3)' OPERATION OP_INCLUIR ACCESS 0    //STR0013 - Incluir
	ADD OPTION aRotina TITLE STR0014 ACTION 'PCPA124MNU(4)' OPERATION OP_ALTERAR ACCESS 0    //STR0014 - Alterar
	ADD OPTION aRotina TITLE STR0015 ACTION 'PCPA124MNU(5)' OPERATION OP_EXCLUIR ACCESS 0    //STR0015 - Excluir
	ADD OPTION aRotina TITLE STR0020 ACTION 'PCPA124RSM()'  OPERATION 9 ACCESS 0 			 //STR0020 - Roteiro Similar

	//Ponto de entrada utilizado para inserir novas opcoes no array aRotina
	If ExistBlock("MTA630MNU")
		ExecBlock("MTA630MNU",.F.,.F.)
	EndIf
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author Carlos Alexandre da Silveira
@since 07/05/2018
@version 1.0
@return oModel
/*/
Static Function ModelDef()
	Local oModel
	Local oStruCab	:= Nil
	Local oStruSG2	:= Nil
	Local oStruSH3R	:= Nil
	Local oStruSH3F	:= Nil
	Local oStruSGFC	:= Nil
	Local oStruSGFG	:= Nil
	Local oStruSHJ  := Nil
	Local oStruSVH	:= FWFormStruct(1, "SVH")
	Local oStruSGR  := Nil
	Local oStruOPs  := Nil
	Local oStruSMX	:= Nil
	Local lUniLin	:= SuperGetMV("MV_UNILIN",.F.,.F.)
	Local oEvent	:= PCPA124EVDEF():New()
	Local cAddFields:= ""

	If Type("Inclui") == "U"
		Private Inclui := .F.
	EndIf	
	
	If ExistBlock("M632ADDFLD")
		cAddFields := ExecBlock("M632ADDFLD",.F.,.F.)
		If ValType(cAddFields) != "C"
			cAddFields := ""
		EndIf
	EndIf

	If lUniLin
		oStruCab := FWFormStruct(1,"SG2",{|cCampo|   A124FormVa(cCampo) $ "|G2_CODIGO|G2_PRODUTO|G2_REFGRD|G2_LINHAPR|G2_TPLINHA|" + AllTrim(cAddFields) + "|"})
		oStruSG2 := FWFormStruct(1,"SG2",{|cCampo| ! A124FormVa(cCampo) $ "|G2_CODIGO|G2_PRODUTO|"})
	Else
		oStruCab := FWFormStruct(1,"SG2",{|cCampo|   A124FormVa(cCampo) $ "|G2_CODIGO|G2_PRODUTO|G2_REFGRD|" + AllTrim(cAddFields) + "|"})
		oStruSG2 := FWFormStruct(1,"SG2",{|cCampo| ! A124FormVa(cCampo) $ "|G2_CODIGO|G2_PRODUTO|"})
	EndIf

	oStruSH3R := FWFormStruct(1,"SH3") //Define estrutura de dados de recursos alternativos/secundarios
	oStruSH3R:RemoveField("H3_FERRAM")
	oStruSH3R:RemoveField("H3_DESCFER")

	oStruSH3F := FWFormStruct(1,"SH3",{|cCampo| A124FormVa(cCampo) $ "|H3_FERRAM|H3_DESCFER|"})
	oStruSGFC := FWFormStruct(1,"SGF",{|cCampo| A124FormVa(cCampo) $ "|SGF_CHECK|"})
	oStruSGFG := FWFormStruct(1,"SGF",{|cCampo| !A124FormVa(cCampo) $ "|GF_FUNCION|GF_DSPROD|"})
    CamposCom(.T., @oStruSGFG, @oStruSGFC)

	oStruSHJ := FWFormStruct(1,"SHJ") //Define estrutura de dados de recursos restritivos (integração Drummer)

	oStruSMX := FWFormStruct(1,"SMX",{|cCampo| A124FormVa(cCampo) $ "|MX_CODIGO|MX_DESCRI|"})

	oStruSGR := FWFormStruct(1,"SGR",{|cCampo| ! A124FormVa(cCampo) $ "|GR_PRODUTO|GR_ROTEIRO|GR_OPERAC|GR_DESCOP|"}) //Define estrutura de dados do Checklist

	oStruCab:SetProperty( "G2_CODIGO",  MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"A124VldCod()"))
	oStruCab:SetProperty( "G2_PRODUTO", MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"A124VldPrd()"))
	If lUniLin
		oStruCab:SetProperty("G2_TPLINHA", MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"A124TpLin(1)"))
		oStruCab:SetProperty("G2_LINHAPR", MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"A124LinPr()"))
	EndIf
	oStruSG2:SetProperty( "G2_OPERAC",  MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"A124ValOpe()"))
	oStruSG2:SetProperty( "G2_RECURSO", MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"(Vazio() .Or. ExistCpo('SH1')) .And. A124Recur()"))
	oStruSG2:SetProperty( "G2_FERRAM",  MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"(Vazio().Or.ExistCpo('SH4')).And.A124Ferram()"))
	oStruSG2:SetProperty( "G2_TPLINHA", MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"A124TpLin(2)"))
	oStruSG2:SetProperty( "G2_ROTALT",  MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"(Vazio().Or.ExistCpo('SG2',FwFldGet('G2_PRODUTO')+FwFldGet('G2_ROTALT'))).And.A124RotAlt()"))
	oStruSG2:SetProperty( "G2_TPALOCF", MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"Vazio().or.(Pertence('123').And.A124TPFer())"))
	oStruSG2:SetProperty( "G2_SETUP",   MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"Positivo().And.A124Tempo()"))
	oStruSG2:SetProperty( "G2_TEMPAD",  MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"Positivo().And.A124Tempo()"))
	oStruSG2:SetProperty( "G2_TEMPSOB", MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"Positivo().And.A124Tempo()"))
	oStruSG2:SetProperty( "G2_TEMPDES", MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"Positivo().And.A124Tempo()"))
	oStruSG2:SetProperty( "G2_TEMPEND", MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"Positivo().And.A124Tempo()"))

	oStruSH3R:SetProperty("H3_RECALTE", MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"ExistCpo('SH1').And.A124RecAlt()"))
	oStruSH3F:SetProperty("H3_FERRAM",  MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"ExistCpo('SH4').And.A124FerAlt()"))
	oStruSHJ:SetProperty( "HJ_RECURSO", MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"ExistCpo('SH1').And.A124RecRes()"))
	oStruSHJ:SetProperty( "HJ_DESCREC", MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD,"IF(!INCLUI,Posicione('SH1',1,xFilial('SH1')+SHJ->HJ_RECURSO,'H1_DESCRI') , '')"))
	oStruSMX:SetProperty( "MX_CODIGO",  MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"A124VldLis()"))
	oStruSMX:SetProperty( "MX_CODIGO",  MODEL_FIELD_OBRIGAT,.F.)
	oStruSMX:SetProperty( "MX_DESCRI",  MODEL_FIELD_OBRIGAT,.F.)

	oStruSGFG:SetProperty("GF_OPERAC",  MODEL_FIELD_OBRIGAT, .F.)
	CamposCab(.T.,@oStruCab,oModel) //Carrega campos de roteiro similar

	//Campos para integração com ordens de produção.
	oStruOPs := FWFormModelStruct():New()
	A124FldOrd(@oStruOPs,.T.)

	oModel:= MPFormModel():New("PCPA124",/*Premodel*/,,,/*bCancel*/)

	oModel:InstallEvent("PCPA124EVDEF", /*cOwner*/, oEvent)

	oModel:AddFields("PCPA124_CAB",/*cOwner*/,oStruCab)
	oModel:AddGrid("PCPA124_SG2"  ,"PCPA124_CAB",oStruSG2,,)
	oModel:AddGrid("PCPA124_SH3_R","PCPA124_SG2",oStruSH3R)
	oModel:AddGrid("PCPA124_SH3_F","PCPA124_SG2",oStruSH3F)
	oModel:AddGrid("PCPA124_SHJ"  ,"PCPA124_SG2",oStruSHJ)
	oModel:AddGrid("PCPA124_SGR"  ,"PCPA124_SG2",oStruSGR)

	//-- Lista de Operações
	oModel:AddFields("PCPA124_SMX","PCPA124_CAB",oStruSMX, , ,{|| A124LoadX(oModel)})
	oModel:AddGrid("PCPA124_SVH"  ,"PCPA124_SMX",oStruSVH, , , , ,)

	oModel:AddFields("PCPA124_SGF_C","PCPA124_CAB",oStruSGFC)
	oModel:AddGrid("PCPA124_SGF_G"  ,"PCPA124_CAB",oStruSGFG, , , , ,{|| A124LoadG(oModel)})

	oModel:AddGrid("PCPA124_ORD","PCPA124_CAB",oStruOPs)

	If !INCLUI .And. Empty(SG2->G2_PRODUTO)
		oModel:SetRelation("PCPA124_SG2"  ,{{"G2_FILIAL","xFilial('SG2')"},{"G2_PRODUTO","G2_PRODUTO"},{"G2_REFGRD" ,"G2_REFGRD"} ,{"G2_CODIGO","G2_CODIGO"}},SG2->(IndexKey(7)))
		oModel:SetRelation("PCPA124_SH3_R",{{"H3_FILIAL","xFilial('SH3')"},{"H3_PRODUTO","G2_REFGRD" },{"H3_CODIGO" ,"G2_CODIGO"} ,{"H3_OPERAC","G2_OPERAC"},{"H3_RECPRIN","G2_RECURSO"}},SH3->(IndexKey(1)))
		oModel:SetRelation("PCPA124_SH3_F",{{"H3_FILIAL","xFilial('SH3')"},{"H3_PRODUTO","G2_REFGRD" },{"H3_CODIGO" ,"G2_CODIGO"} ,{"H3_OPERAC","G2_OPERAC"}},SH3->(IndexKey(1)))
		oModel:SetRelation("PCPA124_SGR"  ,{{"GR_FILIAL","xFilial('SGR')"},{"GR_PRODUTO","G2_CODIGO" },{"GR_ROTEIRO","G2_REFGRD"} ,{"GR_OPERAC","G2_OPERAC"}},SGR->(IndexKey(1)))
		oModel:SetRelation("PCPA124_SHJ"  ,{{"HJ_FILIAL","xFilial('SHJ')"},{"HJ_ROTEIRO","G2_CODIGO" },{"HJ_PRODUTO","G2_REFGRD"} ,{"HJ_OPERAC","G2_OPERAC"},{"HJ_CTRAB","G2_CTRAB"}/*,{"HJ_RECURSO","G2_RECURSO"}*/},SHJ->(IndexKey(1)))
	Else
		oModel:SetRelation("PCPA124_SG2"  ,{{"G2_FILIAL","xFilial('SG2')"},{"G2_PRODUTO","G2_PRODUTO"},{"G2_REFGRD" ,"G2_REFGRD"} ,{"G2_CODIGO","G2_CODIGO"}},SG2->(IndexKey(1)))
		oModel:SetRelation("PCPA124_SH3_R",{{"H3_FILIAL","xFilial('SH3')"},{"H3_PRODUTO","G2_PRODUTO"},{"H3_CODIGO" ,"G2_CODIGO"} ,{"H3_OPERAC","G2_OPERAC"},{"H3_RECPRIN","G2_RECURSO"}},SH3->(IndexKey(1)))
		oModel:SetRelation("PCPA124_SH3_F",{{"H3_FILIAL","xFilial('SH3')"},{"H3_PRODUTO","G2_PRODUTO"},{"H3_CODIGO" ,"G2_CODIGO"} ,{"H3_OPERAC","G2_OPERAC"}},SH3->(IndexKey(1)))
		oModel:SetRelation("PCPA124_SGR"  ,{{"GR_FILIAL","xFilial('SGR')"},{"GR_PRODUTO","G2_PRODUTO"},{"GR_ROTEIRO","G2_CODIGO"} ,{"GR_OPERAC","G2_OPERAC"}},SGR->(IndexKey(1)))
		oModel:SetRelation("PCPA124_SHJ"  ,{{"HJ_FILIAL","xFilial('SHJ')"},{"HJ_ROTEIRO","G2_CODIGO" },{"HJ_PRODUTO","G2_PRODUTO"},{"HJ_OPERAC","G2_OPERAC"},{"HJ_CTRAB","G2_CTRAB"}/*,{"HJ_RECURSO","G2_RECURSO"}*/},SHJ->(IndexKey(1)))
	EndIf

	oModel:SetRelation("PCPA124_SGF_G",{{"GF_FILIAL","xFilial('SGF')"},{"GF_PRODUTO","G2_PRODUTO"},{"GF_ROTEIRO","G2_CODIGO"}},SGF->(IndexKey(1)))

	oModel:GetModel("PCPA124_CAB"  ):SetDescription(STR0001) //STR0001 - Roteiro de Operações
	oModel:GetModel("PCPA124_SG2"  ):SetDescription(STR0002) //STR0002 - Operações
	oModel:GetModel("PCPA124_SH3_R"):SetDescription(STR0018) //STR0018 - Recursos Alternativos / Secundários
	oModel:GetModel("PCPA124_SH3_F"):SetDescription(STR0019) //STR0019 - Ferramentas Alternativas
	oModel:GetModel("PCPA124_SGF_C"):SetDescription(STR0021) //STR0021 - Componentes
	oModel:GetModel("PCPA124_SGF_G"):SetDescription(STR0021) //STR0021 - Componentes
	oModel:GetModel("PCPA124_SHJ"  ):SetDescription(STR0026) //STR0026 - Recursos Restritivos do Centro de Trabalho
	oModel:GetModel("PCPA124_SGR"  ):SetDescription(STR0027) //STR0027 - Checklist
	oModel:GetModel("PCPA124_ORD"  ):SetDescription(STR0033) //"Ordens de produção do roteiro alterado"

	oModel:GetModel("PCPA124_SG2"  ):SetUniqueLine({"G2_OPERAC" })
	oModel:GetModel("PCPA124_SH3_R"):SetUniqueLine({"H3_RECALTE"})
	oModel:GetModel("PCPA124_SH3_F"):SetUniqueLine({"H3_FERRAM" })
	oModel:GetModel("PCPA124_SHJ"  ):SetUniqueLine({"HJ_RECURSO"})
	oModel:GetModel("PCPA124_SGR"  ):SetUniqueLine({"GR_ITCHK"  })

	oModel:GetModel("PCPA124_SH3_R"):SetOptional(.T.)
	oModel:GetModel("PCPA124_SH3_F"):SetOptional(.T.)
	oModel:GetModel("PCPA124_SGF_C"):SetOptional(.T.)
	oModel:GetModel("PCPA124_SGF_G"):SetOptional(.T.)
	oModel:GetModel("PCPA124_SHJ"  ):SetOptional(.T.)
	oModel:GetModel("PCPA124_SGR"  ):SetOptional(.T.)
	oModel:GetModel("PCPA124_ORD"  ):SetOptional(.T.)
	oModel:GetModel("PCPA124_SMX"  ):SetOptional(.T.)
	oModel:GetModel("PCPA124_SVH"  ):SetOptional(.T.)

	oModel:GetModel("PCPA124_ORD"):SetNoInsertLine(.T.)
	oModel:GetModel("PCPA124_ORD"):SetNoDeleteLine(.T.)

	oModel:GetModel("PCPA124_SGF_G"):SetOnlyView()
	oModel:GetModel("PCPA124_SGF_G"):SetOnlyQuery()
	oModel:GetModel("PCPA124_SGF_C"):SetOnlyQuery()
	oModel:GetModel("PCPA124_SMX"  ):SetOnlyQuery()
	oModel:GetModel("PCPA124_SVH"  ):SetOnlyView()
	oModel:GetModel("PCPA124_SVH"  ):SetOnlyQuery()

	oModel:GetModel("PCPA124_ORD"):SetOnlyQuery(.T.)
	oModel:GetModel("PCPA124_ORD"):SetMaxLine(9999)

	oModel:SetPrimaryKey({})

	oModel:GetModel('PCPA124_SH3_R'):SetLoadFilter({{'H3_RECALTE',"'"+CriaVar("H3_RECALTE")+"'",2}}) //MVC_LOADFILTER_NOT_EQUAL
	oModel:GetModel('PCPA124_SH3_F'):SetLoadFilter({{'H3_FERRAM' ,"'"+CriaVar("H3_FERRAM" )+"'",2}}) //MVC_LOADFILTER_NOT_EQUAL

	oModel:GetModel("PCPA124_SG2"):SetUseOldGrid()
	oModel:GetModel("PCPA124_SH3_R"):SetUseOldGrid()
	oModel:GetModel("PCPA124_SH3_F"):SetUseOldGrid()

	oStruSG2:AddField(	RetTitle("G2_OPERAC")					,;	// [01]  C   Titulo do campo  - Produto
						RetTitle("G2_OPERAC")					,;	// [02]  C   ToolTip do campo - Código do Produto
						"COPERAC"		   						,;	// [03]  C   Id do Field
						"C"										,;	// [04]  C   Tipo do campo
						GetSx3Cache("G2_OPERAC","X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
						0										,;	// [06]  N   Decimal do campo
						NIL										,;	// [07]  B   Code-block de validação do campo
						NIL							   			,;	// [08]  B   Code-block de validação When do campo
						NIL										,; 	// [09]  A   Lista de valores permitido do campo
						.F.										,; 	// [10]  L   Indica se o campo tem preenchimento obrigatório
																,;	// [11]  B   Code-block de inicializacao do campo
						NIL										,;	// [12]  L   Indica se trata-se de um campo chave
						NIL										,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.										)   // [14]  L   Indica se o campo é virtual

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@author Carlos Alexandre da Silveira
@since 07/05/2018
@version 1.0
@return oView
@param cRotina, characters, nome da rotina chamadora
@param oView, object, oView criado na rotina chamadora
@param cIdFormPai, characters, id do Box Pai para utilização
/*/
Static Function ViewDef(cRotina, oView, cIdFormPai)
	Local oStruCab  	:= Nil
	Local oStruSG2  	:= Nil
	Local oStruSH3R		:= Nil
	Local oStruSH3F		:= Nil
	Local oStruSGFC		:= Nil
	Local oStruSGFG		:= Nil
	Local oStruSHJ		:= Nil
	Local oStruSGR		:= Nil
	Local oModel		:= Nil
	Local oModelSG2  	:= Nil
	Local oModelSH3R 	:= Nil
	Local oModelSH3F 	:= Nil
	Local lUniLin		:= SuperGetMV("MV_UNILIN",.F.,.F.)
	Local cAddFields	:= ""
	Local nTamCam		:= 75
	
	DEFAULT	oView 		:= FWFormView():New()
	DEFAULT cIdFormPai	:= NIL

	If ExistBlock("M632ADDFLD")
		cAddFields := ExecBlock("M632ADDFLD",.F.,.F.)
		If ValType(cAddFields) != "C"
			cAddFields := ""
		EndIf
		If !Empty(cAddFields)
			nTamCam += 60  //Caso sejam adicionados campos no cabeçalho, aumenta o tamanho do BOX para exibi-los
		EndIf
	EndIf

	If lUniLin
		oStruCab := FWFormStruct(2,"SG2",{|cCampo|   A124FormVa(cCampo) $ "|G2_CODIGO|G2_PRODUTO|G2_LINHAPR|G2_TPLINHA|" + AllTrim(cAddFields) + "|"})
		oStruSG2 := FWFormStruct(2,"SG2",{|cCampo| ! A124FormVa(cCampo) $ "|G2_CODIGO|G2_PRODUTO|G2_LINHAPR|G2_TPLINHA|" + AllTrim(cAddFields) + "|"})
		//Aumenta tamanho do box para exibir os campos de Linha Produção
		nTamCam += 60
	Else
		oStruCab := FWFormStruct(2,"SG2",{|cCampo|   A124FormVa(cCampo) $ "|G2_CODIGO|G2_PRODUTO|" + AllTrim(cAddFields) + "|"})
		oStruSG2 := FWFormStruct(2,"SG2",{|cCampo| ! A124FormVa(cCampo) $ "|G2_CODIGO|G2_PRODUTO|G2_REFGRD|" + AllTrim(cAddFields) + "|"})
	EndIf

	If cIdFormPai == NIL
		oModel := FWLoadModel("PCPA124")
		oView:SetModel(oModel)
	Else
		oModel := oView:GetModel()
	EndIf

	oModelSG2  	:= oModel:GetModel('PCPA124_SG2')
	oModelSH3R 	:= oModel:GetModel('PCPA124_SH3_R')
	oModelSH3F 	:= oModel:GetModel('PCPA124_SH3_F')

	oStruSH3R := FWFormStruct(2,"SH3")
	oStruSH3R:RemoveField("H3_FERRAM")
	oStruSH3R:RemoveField("H3_DESCFER")

	oStruSH3F := FWFormStruct(2,"SH3",{|cCampo|   A124FormVa(cCampo) $ "|H3_FERRAM|H3_DESCFER|"})
	oStruSGFC := FWFormStruct(2,"SGF",{|cCampo|   A124FormVa(cCampo) $ "|SGF_CHECK|"})
	oStruSGFG := FWFormStruct(2,"SGF",{|cCampo| ! A124FormVa(cCampo) $ "|GF_PRODUTO|GF_ROTEIRO|GF_DSPROD|GF_TRT|"})
	CamposCom(.F., @oStruSGFG, @oStruSGFC)

	oStruSG2:SetProperty('G2_OPERAC',MVC_VIEW_LOOKUP,'SVI')
	oStruSG2:SetProperty('G2_ROTALT',MVC_VIEW_LOOKUP,'SG2001')

	CamposCab(.F., @oStruCab, oModel)

	oView:SetAfterViewActivate({|oView| a124AftAct(oView)})
	oView:SetUseCursor(.F.)
	oView:EnableControlBar(.T.)
	oView:AddField("HEADER_SG2" ,oStruCab ,"PCPA124_CAB")
	oView:AddGrid ("GRID_SG2"   ,oStruSG2 ,"PCPA124_SG2")
	oView:AddGrid ("GRID_SH3_R" ,oStruSH3R,"PCPA124_SH3_R")
	oView:AddGrid ("GRID_SH3_F" ,oStruSH3F,"PCPA124_SH3_F")
	oView:AddField("FIELD_SGF_C",oStruSGFC,"PCPA124_SGF_C")
	oView:AddGrid ("GRID_SGF_G" ,oStruSGFG,"PCPA124_SGF_G")

	oView:SetViewProperty("GRID_SGF_G", "ONLYVIEW")

	If FunName() != "PCPA129"
		oView:CreateHorizontalBox("CABEC", nTamCam, cIdFormPai, .T.)
	EndIf
	oView:CreateHorizontalBox("MEIO",     60, cIdFormPai)
	oView:CreateHorizontalBox("INFERIOR", 40, cIdFormPai)

	//Cria Folder na view
	oView:CreateFolder("PASTAS","INFERIOR")

	//Cria pastas nas folders
	oView:AddSheet("PASTAS","ABA_SH3_R",STR0018) //STR0018 - Recursos Alternativos / Secundários
	oView:AddSheet("PASTAS","ABA_SH3_F",STR0019) //STR0019 - Ferramentas Alternativas
	oView:AddSheet("PASTAS","ABA_SGF"  ,STR0021) //STR0021 - Componentes

	//Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox("BOX_ABA_SH3_R",100,,   ,"PASTAS","ABA_SH3_R")
	oView:CreateHorizontalBox("BOX_ABA_SH3_F",100,,   ,"PASTAS","ABA_SH3_F")
	oView:CreateHorizontalBox("BOX_ABA_SGF_C", 45,,.T.,"PASTAS","ABA_SGF"  )
	oView:CreateHorizontalBox("BOX_ABA_SGF_G",100,,   ,"PASTAS","ABA_SGF"  )

	If FunName() != "PCPA129"
		oView:SetOwnerView("HEADER_SG2" ,"CABEC")
	EndIf
	oView:SetOwnerView("GRID_SG2"   ,"MEIO" )
	oView:SetOwnerView("GRID_SH3_R" ,"BOX_ABA_SH3_R")
	oView:SetOwnerView("GRID_SH3_F" ,"BOX_ABA_SH3_F")
	oView:SetOwnerView("FIELD_SGF_C","BOX_ABA_SGF_C")
	oView:SetOwnerView("GRID_SGF_G" ,"BOX_ABA_SGF_G")

	If SuperGetMV("MV_CHKOPER",.F.,.F.)
		oStruSGR := FWFormStruct(2,"SGR",{|cCampo| ! A124FormVa(cCampo) $ "|GR_PRODUTO|GR_ROTEIRO|GR_OPERAC|GR_DESCOP|"})
		oStruSGR:SetProperty('GR_ITCHK',MVC_VIEW_CANCHANGE,.T.)

		oView:AddGrid("GRID_SGR",oStruSGR,"PCPA124_SGR")
		oView:AddSheet("PASTAS","ABA_SGR",STR0027) //STR0027 - Checklist
		oView:CreateHorizontalBox("BOX_ABA_SGR",100,,,"PASTAS","ABA_SGR")
		oView:SetOwnerView("GRID_SGR","BOX_ABA_SGR")
	EndIf

	If TipoAps(.F.,"DRUMMER")
		oStruSHJ := FWFormStruct(2,"SHJ")

		oView:AddGrid("GRID_SHJ",oStruSHJ,"PCPA124_SHJ")
		oView:AddSheet("PASTAS","ABA_SHJ",STR0026) //STR0026 - Recursos Restritivos do Centro de Trabalho
		oView:CreateHorizontalBox("BOX_ABA_SHJ",100,,,"PASTAS","ABA_SHJ")
		oView:SetOwnerView("GRID_SHJ","BOX_ABA_SHJ")
	EndIf

	oView:AddUserButton(STR0022, "", {|oModel| A124VisCo(oModel) }, , , MODEL_OPERATION_VIEW)  // STR0022 - Altera Visual. Componentes
	If cIdFormPai == NIL
		oView:AddUserButton(STR0051, "", {|oView| A124LisOp(oView) }, , ,{MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} )  // STR0051 - Lista de Operações
	Else//PCPA129
		oView:AddUserButton(STR0051, "", {|oView| A124LisOp(oView) }, , ,{MODEL_OPERATION_VIEW,MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} )  // STR0051 - Lista de Operações
	EndIf

	//-- Botao para exportar dados para EXCEL
	If RemoteType() == 1
		oView:AddUserButton(PmsBExcel()[3],PmsBExcel()[1],{|| ExpToExel(oModel)},PmsBExcel()[2])
	EndIf

Return oView

/*/{Protheus.doc} a124AftAct
Função chamada após a criação da view (com todos os modelos ativos)
@author Marcelo Neumann
@since 05/06/2018
@version 1.0
/*/
Static Function a124AftAct(oView)

	//Função para ser chamada a cada troca de linha (em qualquer operação)
	oView:GetViewObj("PCPA124_SG2")[3]:bChangeLine := {|| A124ChLin()}
	oView:GetViewObj("PCPA124_SG2")[3]:bAfterLinOk := {|| PermiteSH3() }

	//Garantir o Load do folder "Componentes"
 	If oView:GetOperation() == 1 .Or. oView:GetOperation() == 5
		A124Check()
	EndIf

	If oView:GetOperation() == 3 .Or. oView:GetOperation() == 4 .Or. oView:GetOperation() == 9
		A124ChLin()
	EndIf

Return oView

/*/{Protheus.doc} A124VldPrd
Valida produto digitado quando não referencia de grade
@author Carlos Alexandre da Silveira
@since 08/05/2018
@version 1.0
/*/
Function A124VldPrd()
	Local lRet     	:= .T.
	Local oModel   	:= FWModelActive()
	Local cRefGrd	:= oModel:GetValue("PCPA124_CAB","G2_PRODUTO")
	Local aSaveArea	:= GetArea()

	//STR0003 - Família de Produtos
	//STR0004 - O código digitado é referência de uma família de produtos. Deseja cadastrar para qual entidade?
	//STR0005 - Família
	//STR0006 - Produto
	If A093IsGrade(cRefGrd) .And. AllTrim(cRefGrd) == AllTrim(A093VldBase(cRefGrd)) .And. Aviso(STR0003,STR0004,{STR0005,STR0006}) == 2
		A093Prod( , "M->G2_PRODUTO")
		cRefGrd	:= oModel:GetValue("PCPA124_CAB","G2_PRODUTO")
	EndIf

	If MatGrdPrrf(@cRefGrd) .And. AllTrim(cRefGrd) == AllTrim(oModel:GetValue("PCPA124_CAB","G2_PRODUTO"))
		lRet := ExistChav("SG2",PadR(cRefGrd,GetSx3Cache("G2_REFGRD","X3_TAMANHO"))+oModel:GetModel("PCPA124_CAB"):GetValue("G2_CODIGO"),7)
	Else
		lRet := Vazio() .Or. ExistCpo("SB1")
	EndIf

	If SG2->(dbSeek(xFilial("SG2")+oModel:GetModel("PCPA124_CAB"):GetValue("G2_PRODUTO")+oModel:GetModel("PCPA124_CAB"):GetValue("G2_CODIGO")))
		Help(" ",1,"JAGRAVADO")
		lRet:= .F.
	EndIf

	//Se a variável private não tiver sido declarada, atribui padrão .F.
	lBrowse := If(Type("lBrowse")=="U", .F., lBrowse)

	If lRet .And. lBrowse .And. IsProdProt(oModel:GetValue("PCPA124_CAB","G2_PRODUTO"))
		Help(" ",1,"ISPRODPROT") //Este produto é um protótipo e de uso reservado do módulo Desenvolvedor de Produtos (DPR).
		lRet := .F.
	EndIf

	//Gatilha descricao
	If lRet
		oModel:LoadValue("PCPA124_CAB","CDESCPROD",PadR(A124IniDes(cRefGrd,.T.),GetSx3Cache("B1_DESC","X3_TAMANHO")))
	EndIf

	RestArea(aSaveArea)
Return lRet

/*/{Protheus.doc} A124VldCod
Valida a digitação do código do roteiro
@author Carlos Alexandre da Silveira
@since 08/05/2018
@version 1.0
/*/
Function A124VldCod()
	Local lRet 		:= .T.
	Local oModel   	:= FWModelActive()
	Local cRefGrd	:= oModel:GetValue("PCPA124_CAB","G2_PRODUTO")
	Local cRoteiro  := oModel:GetModel("PCPA124_CAB"):GetValue("G2_CODIGO")

	If !Empty(cRefGrd)
		If MatGrdPrrf(@cRefGrd) .And. AllTrim(cRefGrd) == AllTrim(oModel:GetValue("PCPA124_CAB","G2_PRODUTO"))
			lRet := ExistChav("SG2",PadR(cRefGrd,GetSx3Cache("G2_REFGRD","X3_TAMANHO"))+oModel:GetModel("PCPA124_CAB"):GetValue("G2_CODIGO"),7)
		Else
			lRet := Vazio() .Or. ExistChav("SG2",cRefGrd+cRoteiro,1)
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} A124IniDes
Inicializa campo da descrição do produto
@author Carlos Alexandre da Silveira
@since 08/05/2018
@version 1.0
/*/
Static Function A124IniDes(cProduto,lIniProd)
	Local cRet 	     := ""
	Default lIniProd := .F.

	If lIniProd
		If MatGrdPrrf(ALlTrim(cProduto)) //Referencia
			cRet := MaGetDescGrd(cProduto)
		Else	//Produto
			cRet := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
		EndIf
	ElseIf !Inclui
		If MatGrdPrrf(AllTrim(SG2->G2_REFGRD)) //Referencia
			cRet := MaGetDescGrd(SG2->G2_REFGRD)
		Else	//Produto
			cRet := Posicione("SB1",1,xFilial("SB1")+SG2->G2_PRODUTO,"B1_DESC")
		EndIf
	EndIf
Return cRet

/*/{Protheus.doc} A124ValOpe
Função para verificar se o código da operação já está cadastrado.
@author Carlos Alexandre da Silveira
@since 08/05/2018
@version 1.0
/*/
Function A124ValOpe()
	Local oModel	:= FWModelActive()
	Local oModSG2	:= oModel:GetModel("PCPA124_SG2")
	Local cOperac	:= oModSG2:GetValue("G2_OPERAC")
	Local nLine		:= oModSG2:GetLine()
	Local lRet		:= .T.
	Local nX		:= 0

	For nX := 1 To oModSG2:Length()
		If nX == nLine 
			Loop
		EndIf
		If cOperac == oModSG2:GetValue("COPERAC",nX) .And. oModSG2:GetValue("G2_OPERAC",nX) != oModSG2:GetValue("COPERAC",nX)
			Help( ,  , STR0074, ,  "Operação não pode ser alterada pois o código digitado já existe ou foi alterado e não salvo", 1, 0, , , , , , {"Salve a alteração antes de reutilizar o código da operação"})
			lRet := .F.
			Exit
		EndIf	
	Next nX
	
	If lRet
		SVI->(DbSetOrder(1))
		If SVI->(dbSeek(xFilial("SVI")+oModSG2:GetValue("G2_OPERAC")))
			oModSG2:SetValue("G2_DESCRI",SVI->VI_DESCRI)
		EndIf
	EndIf

	
Return lRet

/*/{Protheus.doc} A124Recur
Realiza busca no cadastro de Recurso alternativo e verifica se existe alguma ocorrencia do mesmo recurso.
@author Carlos Alexandre da Silveira
@since 09/05/2018
@version 1.0
/*/
Function A124Recur()
	Local oModel		:= FWModelActive()
	Local oGridSH3		:= oModel:GetModel("PCPA124_SH3_R")
	Local nX			:= 0
	Local lRet			:= .T.
	Local aSaveLines	:= FWSaveRows(oModel)
	Local cRecursoAtu   := oModel:GetValue("PCPA124_SG2","G2_RECURSO")

	If !Empty(cRecursoAtu)
		//Verifica se Recurso Principal já foi cadastrado como Alternativo.
		For nX := 1 To oGridSH3:Length()
			If !oGridSH3:IsDeleted(nX);
			   .And. cRecursoAtu == oGridSH3:GetValue("H3_RECALTE", nX)
				If oGridSH3:GetValue("H3_TIPO", nX) == "S"
					Help(" ",1,"A630JAS")
				Else
					Help(" ",1,"A630JAA")
				EndIf
				lRet:=.F.
				Exit
			EndIf
		Next nX
	EndIf

	FWRestRows(aSaveLines)
Return lRet

/*/{Protheus.doc} A124Ferram
Efetua validações da ferramenta informada
@author Carlos Alexandre da Silveira
@since 09/05/2018
@version 1.0
/*/
Function A124Ferram()
	Local oModel		:= FWModelActive()
	Local oGridSG2	 	:= oModel:GetModel("PCPA124_SG2")
	Local oGridSH3		:= oModel:GetModel("PCPA124_SH3_F")
	Local nX			:= 0
	Local lRet			:= .T.
	Local aSaveLines	:= FWSaveRows(oModel)
	Local cFerramAtu    := oGridSG2:GetValue("G2_FERRAM")

	//Verifica se Ferramenta Principal já foi cadastrada como Alternativa.
	If !Empty(cFerramAtu)
		For nX := 1 To oGridSH3:Length(.T.)
			If !oGridSH3:IsDeleted(nX);
			   .And. cFerramAtu == oGridSH3:GetValue("H3_FERRAM", nX)
				Help(" ",1,"A124FERJA") //A124FERJA - Ferramenta já cadastrada nesta Operação.
				lRet:=.F.
				Exit
			EndIf
		Next nX
	EndIf

	FWRestRows(aSaveLines)
Return lRet

/*/{Protheus.doc} CamposCab
Monta estrutura de campo para modelo e view.
@author Carlos Alexandre da Silveira
@since 10/05/2018
@version 1.0
/*/
Static Function CamposCab(lModel,oStru,oModel)

	If lModel //Instância de modelo
		//Descrição do produto
		oStru:AddField(	RetTitle("B1_DESC")					,;	// [01]  C   Titulo do campo  - Produto
						RetTitle("B1_DESC")					,;	// [02]  C   ToolTip do campo - Código do Produto
						"CDESCPROD"		   					,;	// [03]  C   Id do Field
						"C"									,;	// [04]  C   Tipo do campo
						GetSx3Cache("B1_DESC","X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
						0									,;	// [06]  N   Decimal do campo
						NIL									,;	// [07]  B   Code-block de validação do campo
						NIL							   		,;	// [08]  B   Code-block de validação When do campo
						NIL									,; 	// [09]  A   Lista de valores permitido do campo
						.F.									,; 	// [10]  L   Indica se o campo tem preenchimento obrigatório
						{|| A124IniDes()}					,;	// [11]  B   Code-block de inicializacao do campo
						NIL									,;	// [12]  L   Indica se trata-se de um campo chave
						NIL									,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.									)   // [14]  L   Indica se o campo é virtual
	Else //Instância de view
		//Descrição do produto
		oStru:AddField(	"CDESCPROD"			,;	// [01]  C   Nome do Campo
						"04"				,;	// [02]  C   Ordem
						RetTitle("B1_DESC") ,;	// [03]  C   Titulo do campo
						RetTitle("B1_DESC")	,;	// [04]  C   Descricao do campo
						NIL					,;	// [05]  A   Array com Help
						"C"					,; 	// [06]  C   Tipo do campo
						""					,;	// [07]  C   Picture
						NIL					,;	// [08]  B   Bloco de Picture Var
						NIL					,;	// [09]  C   Consulta F3
						.F.					,;	// [10]  L   Indica se o campo é alteravel
						NIL					,;	// [11]  C   Pasta do campo
						NIL					,;	// [12]  C   Agrupamento do campo
						NIL					,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL					,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL					,;	// [15]  C   Inicializador de Browse
						.T.					,;	// [16]  L   Indica se o campo é virtual
						NIL					,;	// [17]  C   Picture Variavel
						NIL					)	// [18]  L   Indica pulo de linha após o campo

		If FunName() == "PCPA129"
			oStru:SetProperty("G2_PRODUTO", MVC_VIEW_CANCHANGE, .F.)
			oStru:SetProperty("G2_CODIGO", MVC_VIEW_TITULO, STR0048) //Roteiro
		EndIf
	EndIf
Return

/*/{Protheus.doc} CamposCom
Monta estrutura de campo para modelo e view.
@author Marcelo Neumann
@since 05/06/2018
@version 1.0
/*/
Static Function CamposCom(lModel, oStru, oStruCheck)

	If lModel
		oStruCheck:AddField(STR0023			,;	// [01]  C   Titulo do campo  - Produto
							STR0023			,;	// [02]  C   ToolTip do campo - Código do Produto
							"SGF_CHECK"		,;	// [03]  C   Id do Field
							"L", 1, 0		,;
							{|| A124Check()},;	// [07]  B   Code-block de validação do campo
							{|| StaticCall(PCPA129, ModoCheck) }, NIL, .F., NIL, NIL, NIL, .T.)

		//Descrição da Operação
		oStru:AddField(	RetTitle("G2_DESCRI")					,;	// [01]  C   Titulo do campo  - Produto
						RetTitle("G2_DESCRI")					,;	// [02]  C   ToolTip do campo - Código do Produto
						"SGF_DESCOP"	   						,;	// [03]  C   Id do Field
						"C"										,;	// [04]  C   Tipo do campo
						GetSx3Cache("G2_DESCRI","X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
						0, NIL, NIL, NIL, .F., NIL, NIL, NIL, .T.)

		//Descrição do Componente
		oStru:AddField(	RetTitle("B1_DESC")					,;	// [01]  C   Titulo do campo  - Produto
						RetTitle("B1_DESC")					,;	// [02]  C   ToolTip do campo - Código do Produto
						"SGF_DESCCOMP"						,;	// [03]  C   Id do Field
						"C"									,;	// [04]  C   Tipo do campo
						GetSx3Cache("B1_DESC","X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
						0, NIL, NIL, NIL, .F., NIL, NIL, NIL, .T.)

		//Sequência do Componente na estrutura
		oStru:AddField(	RetTitle("G1_TRT")					,;	// [01]  C   Titulo do campo  - Produto
						RetTitle("G1_TRT")					,;	// [02]  C   ToolTip do campo - Código do Produto
						"SGF_TRTCOMP"						,;	// [03]  C   Id do Field
						"C"									,;	// [04]  C   Tipo do campo
						GetSx3Cache("G1_TRT","X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
						0, NIL, NIL, NIL, .F., NIL, NIL, NIL, .T.)

		//Quantidade do Componente
		oStru:AddField(	RetTitle("G1_QUANT")				,;	// [01]  C   Titulo do campo  - Produto
						RetTitle("G1_QUANT")				,;	// [02]  C   ToolTip do campo - Código do Produto
						"SGF_QTDCOMP"	   					,;	// [03]  C   Id do Field
						"N"									,;	// [04]  C   Tipo do campo
						GetSx3Cache("G1_QUANT","X3_TAMANHO"),;	// [05]  N   Tamanho do campo
						GetSx3Cache("G1_QUANT","X3_DECIMAL"),;	// [06]  N   Decimal do campo
						NIL, NIL, NIL, .F., NIL, NIL, NIL, .T.)
	Else
		oStruCheck:AddField("SGF_CHECK"		,;	// [01]  C   Nome do Campo
							"01"			,;	// [02]  C   Ordem
							STR0023  		,;	// [03]  C   Titulo do campo
							STR0023			,;	// [04]  C   Descricao do campo
							NIL				,;
							"Check"			,; 	// [06]  C   Tipo do campo
							"", NIL, NIL	,;
							.T.				,;	// [10]  L   Indica se o campo é alteravel
							NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

		//Descrição da Operação
		oStru:AddField(	"SGF_DESCOP"							    ,;	// [01]  C   Nome do Campo
						"04"									,;	// [02]  C   Ordem
						RetTitle("G2_DESCRI") 					,;	// [03]  C   Titulo do campo
						RetTitle("G2_DESCRI")					,;	// [04]  C   Descricao do campo
						NIL										,;
						"C"										,; 	// [06]  C   Tipo do campo
						"", NIL, NIL							,;
						.F.										,;	// [10]  L   Indica se o campo é alteravel
						NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

		//Descrição do Componente
		oStru:AddField(	"SGF_DESCCOMP"		    				,;	// [01]  C   Nome do Campo
						"06"									,;	// [02]  C   Ordem
						RetTitle("B1_DESC")  					,;	// [03]  C   Titulo do campo
						RetTitle("B1_DESC")	 					,;	// [04]  C   Descricao do campo
						NIL										,;
						"C"										,; 	// [06]  C   Tipo do campo
						"", NIL, NIL							,;
						.F.										,;	// [10]  L   Indica se o campo é alteravel
						NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

		//Sequência do Componente na estrutura
		oStru:AddField(	"SGF_TRTCOMP"		    				,;	// [01]  C   Nome do Campo
						"07"									,;	// [02]  C   Ordem
						RetTitle("G1_TRT")  					,;	// [03]  C   Titulo do campo
						RetTitle("G1_TRT")	 					,;	// [04]  C   Descricao do campo
						NIL										,;
						"C"										,; 	// [06]  C   Tipo do campo
						"", NIL, NIL							,;
						.F.										,;	// [10]  L   Indica se o campo é alteravel
						NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

		//Quantidade do Componente
		oStru:AddField(	"SGF_QTDCOMP"						    ,;	// [01]  C   Nome do Campo
						"08"									,;	// [02]  C   Ordem
						RetTitle("G1_QUANT")  					,;	// [03]  C   Titulo do campo
						RetTitle("G1_QUANT")					,;	// [04]  C   Descricao do campo
						NIL										,;
						"N"										,; 	// [06]  C   Tipo do campo
						"", NIL, NIL							,;
						.F.										,;	// [10]  L   Indica se o campo é alteravel
						NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)
	EndIf
Return

/*/{Protheus.doc} A124TpLin
Valida campo G2_TPLINHA
@author Carlos Alexandre da Silveira
@since 16/05/2018
@param nTipo	- Identifica se está executando o valid para o campo do cabeçalho ou da grid do PCPA124.
@version 1.0
/*/
Function A124TpLin(nTipo)
	Local lRet	 	:= .T.
	Local nIndex	:= 0
	Local nLinAnt   := 0
	Local oModel 	:= FWModelActive()
	Local oModCab   := oModel:GetModel("PCPA124_CAB")
	Local oModSG2	:= oModel:GetModel("PCPA124_SG2")
	Local oSubModel

	If nTipo == 1
		oSubModel := oModCab
	ElseIf nTipo == 2
		oSubModel := oModSG2
	EndIf

	If oSubModel:GetValue("G2_TPLINHA") == "D"
		If !SuperGetMV("MV_UNILIN",.F.,.F.) .And. oModSG2:nLine # 1
			If Empty(oModSG2:GetValue("G2_LINHAPR",oModSG2:nLine - 1))
				//A124TPLIND - Quando o Campo Tipo de Linha estiver preenchido com Dependente, é obrigatório preenchimento do Campo Linha de Produção da Operação anterior.
				Help(" ",1,"A124TPLIND")
				lRet := .F.
			Else
				oModSG2:SetValue("G2_LINHAPR",oModSG2:GetValue("G2_LINHAPR",oModSG2:nLine - 1))
			EndIf
		ElseIf Empty(oSubModel:GetValue("G2_LINHAPR"))
			//A124TPLINO - Para que o Tipo de Linha seja Obrigatório, Preferencial ou Dependente é necessário realizar o preenchimento do campo Linha de Produção.
			Help(" ",1,"A124TPLINO")
			lRet := .F.
		EndIf
	ElseIf oSubModel:GetValue("G2_TPLINHA") $ "OP"
		If Empty(oSubModel:GetValue("G2_LINHAPR"))
			//A124TPLINO - Para que o Tipo de Linha seja Obrigatório, Preferencial ou Dependente é necessário realizar o preenchimento do campo Linha de Produção.
			Help(" ",1,"A124TPLINO")
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. !PermAltLiP(oModel,oSubModel:GetValue("G2_LINHAPR"),oSubModel:GetValue("G2_TPLINHA"),"G2_TPLINHA")
		lRet := .F.
	EndIf

	If lRet .And. nTipo == 1 //Execução pelo cabeçalho do PCPA124
		nLinAnt := oModSG2:GetLine()
		//Atualiza todas as operações.
		For nIndex := 1 To oModSG2:Length()
			If oModSG2:IsDeleted(nIndex)
				Loop
			EndIf
			oModSG2:GoLine(nIndex)
			oModSG2:LoadValue("G2_LINHAPR",oModCab:GetValue("G2_LINHAPR"))
			oModSG2:LoadValue("G2_TPLINHA",oModCab:GetValue("G2_TPLINHA"))
		Next nIndex
		oModSG2:GoLine(nLinAnt)
	EndIf
Return lRet

/*/{Protheus.doc} A124LinPr
Faz a validação da Linha de Produção informada. (G2_LINHAPR)
@type  Function
@author lucas.franca
@since 16/01/2019
@version P12
@return lRet, Logical, Indica se o valor informado está válido
/*/
Function A124LinPr()
	Local lRet    := .T.
	Local nLinAnt := 0
	Local nIndex  := 0
	Local oModel  := FWModelActive()
	Local oModCab := oModel:GetModel("PCPA124_CAB")
	Local oModSG2 := oModel:GetModel("PCPA124_SG2")

	If lRet .And. !PermAltLiP(oModel,oModCab:GetValue("G2_LINHAPR"),oModCab:GetValue("G2_TPLINHA"),"G2_LINHAPR")
		lRet := .F.
	EndIf

	If lRet //Execução pelo cabeçalho do PCPA124
		nLinAnt := oModSG2:GetLine()
		//Atualiza todas as operações.
		For nIndex := 1 To oModSG2:Length()
			If oModSG2:IsDeleted(nIndex)
				Loop
			EndIf
			oModSG2:GoLine(nIndex)
			oModSG2:LoadValue("G2_LINHAPR",oModCab:GetValue("G2_LINHAPR"))
			oModSG2:LoadValue("G2_TPLINHA",oModCab:GetValue("G2_TPLINHA"))
		Next nIndex
		oModSG2:GoLine(nLinAnt)
	EndIf
Return lRet

/*/{Protheus.doc} A124RotAlt
Efetua validações do roteiro alternativo informado
@author Carlos Alexandre da Silveira
@since 21/05/2018
@version 1.0
/*/
Function A124RotAlt()
	Local lRet	:= .T.

	If FwFldGet("G2_ROTALT") == FwFldGet("G2_CODIGO")
		Help(,,'Help',,STR0016,1,0)  //STR0016 - Roteiro não pode ser alternativo dele mesmo.
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} A124TPFer
Valida campo que define o tipo de alocacao da ferramenta
@author Carlos Alexandre da Silveira
@since 21/05/2018
@version 1.0
/*/
Function A124TPFer()
	Local lRet := .T.

	If Empty(FwFldGet("G2_FERRAM"))
		If !IsBlind()
			Help(" ",1,"VAZIO",,STR0017,1) //"O campo ferramenta nao foi informado"
		EndIf
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} A124Tempo
Valida campo que define o tipo de alocacao da ferramenta
@author Carlos Alexandre da Silveira
@since 21/05/2018
@version 1.0
/*/
Function A124Tempo(cCampo)
	Local nVal      := 0
	Local cTipo     := GetMV("MV_TPHR")
	Local nPrecisao := GetMV("MV_PRECISA")
	Local nDec      := 0
	Local lValid    := .F.
	Local oModel    := FWModelActive()
	Local oModSG2   := oModel:GetModel("PCPA124_SG2")
	Default cCampo  := ReadVar()

	If cCampo == "M->G2_TEMPAD"
		nVal := oModSG2:GetValue("G2_TEMPAD")
	ElseIf cCampo == "M->G2_SETUP"
		nVal := oModSG2:GetValue("G2_SETUP")
	ElseIf cCampo == "M->G2_TEMPSOB"
		nVal := oModSG2:GetValue("G2_TEMPSOB")
	ElseIf cCampo == "M->G2_TEMPDES"
		nVal := oModSG2:GetValue("G2_TEMPDES")
	ElseIf cCampo == "M->G2_TEMPEND"
		nVal := oModSG2:GetValue("G2_TEMPEND")
	EndIf

	nDec := ( nVal - Int( nVal ) ) * 100
	nPrecisao := 60 / nPrecisao

	If cCampo == "M->G2_TEMPSOB"
		lValid := oModSG2:GetValue("G2_TPSOBRE") == "3"
	ElseIf cCampo == "M->G2_TEMPDES"
		lValid := oModSG2:GetValue("G2_TPDESD") == "2"
	ElseIf cCampo == "M->G2_TEMPAD" .Or. cCampo == "M->G2_SETUP" .Or. cCampo == "M->G2_TEMPEND"
		lValid := .T.
	Endif

	If nDec >= 60 .And. cTipo == "N" .And. lValid
		Help(" ",1,"NAOMINUTO")
		Return .F.
	EndIf

	If cCampo $ "M->G2_TEMPAD/M->G2_SETUP/M->G2_TEMPEND"
		If cTipo == "N"
			If nVal < 1
				If cCampo == "M->G2_TEMPAD"
					nDec += (oModSG2:GetValue("G2_SETUP") - Int(oModSG2:GetValue("G2_SETUP"))) * 100
				ElseIf cCampo == "M->G2_SETUP"
					nDec += (oModSG2:GetValue("G2_TEMPAD") - Int(oModSG2:GetValue("G2_TEMPAD"))) * 100
				ElseIf cCampo == "M->G2_TEMPEND"
					nDec += (oModSG2:GetValue("G2_TEMPEND") - Int(oModSG2:GetValue("G2_TEMPEND"))) * 100
				EndIf
				If NoRound(nDec,2) < NoRound(nPrecisao,2)
					Help(" ",1,"MENORPREC")
					If (oModSG2:GetValue("G2_TPOPER")) == "2" .Or. (oModSG2:GetValue("G2_TPOPER")) == "3"
						Return .F.
					EndIf
				EndIf
			EndIf
		ElseIf cTipo == "C"
			If nVal < 1
				nDec := ( nVal - Int( nVal ) ) * 60
				If cCampo == "M->G2_TEMPAD"
					nDec += (oModSG2:GetValue("G2_SETUP") - Int(oModSG2:GetValue("G2_SETUP"))) * 60
				ElseIf cCampo == "M->G2_SETUP"
					nDec += (oModSG2:GetValue("G2_TEMPAD") - Int(oModSG2:GetValue("G2_TEMPAD"))) * 60
				ElseIf cCampo == "M->G2_TEMPEND"
					nDec += (oModSG2:GetValue("G2_TEMPEND") - Int(oModSG2:GetValue("G2_TEMPEND"))) * 60
				EndIf
				If NoRound(nDec,2) < NoRound(nPrecisao,2)
					Help(" ",1,"MENORPREC")
					If (oModSG2:GetValue("G2_TPOPER")) == "2" .Or. (oModSG2:GetValue("G2_TPOPER")) == "3"
						Return .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return .T.

/*/{Protheus.doc} A124RecAlt
Verifica se Recurso Alternativo já foi cadastrado como Principal.
@author Carlos Alexandre da Silveira
@since 25/05/2018
@version 1.0
/*/
Function A124RecAlt()
	Local oModel	  := FWModelActive()
	Local oGridSG2	  := oModel:GetModel("PCPA124_SG2")
	Local oGridSH3	  := oModel:GetModel("PCPA124_SH3_R")
	Local nX          := 0
	Local lRet        := .T.
	Local aSaveLines  := FWSaveRows(oModel)
	Local cOperAtu    := oGridSG2:GetValue("G2_OPERAC")
	Local cRecursoAtu := oGridSH3:GetValue("H3_RECALTE")

	//Verifica se Recurso Alternativo já foi cadastrado como Principal.
	If !Empty(cRecursoAtu)
		For nX := 1 To oGridSG2:Length()
			If !oGridSG2:IsDeleted(nX);
			.And. cRecursoAtu == oGridSG2:GetValue("G2_RECURSO", nX);
			.And. cOperAtu    == oGridSG2:GetValue("G2_OPERAC" , nX)
				HELP(" ",1,STR0087 ,,STR0086,2,0,,,,,, {STR0088})//Recurso já cadastrado como Recurso Principal nesta Operação
				lRet := .F.
				Exit
			EndIf
		Next nX
	EndIf

	FWRestRows(aSaveLines)

	//Inicializa descricao do recurso
	If lRet
		oGridSH3:SetValue("H3_DESC",PadR(Posicione("SH1",1,xFilial("SH1")+FwFldGet("H3_RECALTE"),"H1_DESCRI"),GetSx3Cache("H3_DESC","X3_TAMANHO")))
	EndIf
Return lRet

/*/{Protheus.doc} A124FerAlt
Efetua validações da ferramenta informada
@author Carlos Alexandre da Silveira
@since 25/05/2018
@version 1.0
/*/
Function A124FerAlt()
	Local oModel     := FWModelActive()
	Local oGridSG2   := oModel:GetModel("PCPA124_SG2")
	Local oGridSH3   := oModel:GetModel("PCPA124_SH3_F")
	Local nX         := 0
	Local lRet       := .T.
	Local aSaveLines := FWSaveRows(oModel)
	Local cFerramAtu := oGridSH3:GetValue("H3_FERRAM")

	//Verifica se Ferramenta Alternativa já foi cadastrada como Principal.
	If !Empty(cFerramAtu)
		For nX := 1 To oGridSG2:Length()
			If !oGridSG2:IsDeleted(nX);
			   .AND. cFerramAtu == oGridSG2:GetValue("G2_FERRAM", nX)
				Help(" ",1,"A124FERJA") //A124FERJA - Ferramenta já cadastrada nesta Operação.
				lRet := .F.
				Exit
			EndIf
		Next nX
	EndIf

	FWRestRows(aSaveLines)

	//Inicializa descricao da ferramenta
	If lRet
		oGridSH3:SetValue("H3_DESCFER",PadR(Posicione("SH4",1,xFilial("SH4")+FwFldGet("H3_FERRAM"),"H4_DESCRI"),GetSx3Cache("H3_DESCFER","X3_TAMANHO")))
	EndIf
Return lRet

/*/{Protheus.doc} PCPA124RSM
Função responsável pela opção "Roteiro Similar" do menu (Cópia)
@author Carlos Alexandre da Silveira
@since 25/05/2018
@version 1.0
/*/
Function PCPA124RSM(oModel, lSoMontaModel)
	Local oStruSG2
	Local oStruSH3R
	Local oStruSH3F
	Local oStruSGR
	Local oStruSHJ
	Local aStructSG2    := {}
	Local aStructSH3    := {}
	Local aStructSGR    := {}
	Local aStructSHJ    := {}
	Local nI            := 1
	Local nSH3_R        := 1
	Local nSH3_F        := 1
	Local nSGR          := 1
	Local nSHJ          := 1
	Local nCampoTam     := 0
	Local lMvChkOper    := SuperGetMV("MV_CHKOPER",.F.,.F.)
	Local lUniLin		:= SuperGetMv("MV_UNILIN",.F.,.F.)
	Local nRet

	DEFAULT oModel        := FwLoadModel("PCPA124")
	DEFAULT lSoMontaModel := .F.

	oStruSG2 	:= oModel:Getmodel("PCPA124_SG2")
	oStruSH3R	:= oModel:GetModel("PCPA124_SH3_R")
	oStruSH3F	:= oModel:GetModel("PCPA124_SH3_F")
	oStruSGR	:= oModel:GetModel("PCPA124_SGR")
	oStruSHJ	:= oModel:GetModel("PCPA124_SHJ")

	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	cProdAux := SG2->G2_PRODUTO
	cCodAux := SG2->G2_CODIGO

	oModel:LoadValue("PCPA124_CAB","CDESCPROD"," ")

	//Pega estrutura da tabela Filho
	aStructSG2 := SG2->(dbStruct())
	aStructSH3 := SH3->(dbStruct())
	aStructSGR := SGR->(dbStruct())
	aStructSHJ := SHJ->(dbStruct())

	//Faz a consulta na tabela filho
	dbSelectArea( "SG2" )

	if MatGrdPrrf(cProdAux) //Verifica se o produto é referência grade
		SG2->( DbSetOrder(7) )
		nCampoTam := GetSx3Cache("G2_REFGRD","X3_TAMANHO")
	else
		SG2->( DbSetOrder(1) )
		nCampoTam := GetSx3Cache("G2_PRODUTO","X3_TAMANHO")
	EndIf

	If SG2->( dbSeek( xFilial( "SG2" )+PadR(cProdAux,nCampoTam)+cCodAux))

		//Carrega SH3 - recursos e ferramentas alternativos
		dbSelectArea( "SH3" )
		SH3->( DbSetOrder(1) )

		//Enquanto houver registros filhos, vai adicionando no grid
		While SG2->(!Eof()) .and. xFilial("SG2") == SG2->G2_FILIAL .and. (cProdAux == SG2->G2_PRODUTO .Or. PadR(cProdAux,nCampoTam) == SG2->G2_REFGRD) .and. cCodAux == SG2->G2_CODIGO
			//Verifica se precisa gerar mais um linha(se for a primeira não precisa)
			If !Empty(oStruSG2:GetValue('G2_OPERAC')) .OR. oStruSG2:IsDeleted()
				oStruSG2:AddLine()
			EndIf

			//Adiciona o valor pra cada campo do grid
			For nI := 1 To Len(aStructSG2)
				If !( A124FormVa(aStructSG2[nI][1]) $ "|G2_FILIAL|G2_PRODUTO|G2_CODIGO|G2_REVIPRD|" ) .And. oStruSG2:HasField(aStructSG2[nI][1])
					oStruSG2:LoadValue(aStructSG2[nI][1],SG2->&(aStructSG2[nI][1]))
				EndIf
			Next

			If !oStruSG2:VldLineData()
				MsgStop(STR0034+oModel:GetErrorMessage()[6],'') //'Não foi possível incluir a operação. Motivo: '
				Exit
			EndIf

			nSH3_R := 1
			nSH3_F := 1

			If SH3->( dbSeek( xFilial( "SH3" )+cProdAux+cCodAux+SG2->G2_OPERAC))
				//Enquanto houver registros filhos, vai adicionando no grid
				While SH3->(!Eof()) .and. xFilial("SH3") == SH3->H3_FILIAL .and. cProdAux == SH3->H3_PRODUTO .and. cCodAux == SH3->H3_CODIGO .and. SG2->G2_OPERAC == SH3->H3_OPERAC
					If Empty(SH3->H3_FERRAM)
						//Verifica se precisa gerar mais um linha(se for a primeira não precisa)
						If nSH3_R != 1
							oStruSH3R:AddLine()
						EndIf

						//Adiciona o valor pra cada campo do grid
						For nI := 1 To Len(aStructSH3)
							If !( A124FormVa(aStructSH3[nI][1]) $ "|H3_FILIAL|H3_PRODUTO|H3_CODIGO|H3_OPERAC|H3_FERRAM|H3_DESCFER|H3_RECPRIN|" )
								oStruSH3R:LoadValue(aStructSH3[nI][1],SH3->&(aStructSH3[nI][1]))
							EndIf
						Next

						//Carrega descrição do recurso
						oStruSH3R:SetValue("H3_DESC",PadR(Posicione("SH1",1,xFilial("SH1")+FwFldGet("H3_RECALTE"),"H1_DESCRI"),GetSx3Cache("H3_DESC","X3_TAMANHO")))
						nSH3_R++
					Else
						//Verifica se precisa gerar mais um linha(se for a primeira não precisa)
						If nSH3_F != 1
							oStruSH3F:AddLine()
						EndIf

						//Adiciona o valor pra cada campo do grid
						For nI := 1 To Len(aStructSH3)
							If !( A124FormVa(aStructSH3[nI][1]) $ "|H3_FILIAL|H3_PRODUTO|H3_CODIGO|H3_OPERAC|H3_RECPRIN|H3_RECALTE|H3_TIPO|H3_EFICIEN|H3_DESC|")
								oStruSH3F:LoadValue(aStructSH3[nI][1],SH3->&(aStructSH3[nI][1]))
							EndIf
						Next

						//Carrega descrição da ferramenta
						oStruSH3F:SetValue("H3_DESCFER",PadR(Posicione("SH4",1,xFilial("SH4")+FwFldGet("H3_FERRAM"),"H4_DESCRI"),GetSx3Cache("H3_DESCFER","X3_TAMANHO")))
						nSH3_F++
					endif
					//Pula pro próximo registro filho
					SH3->(DbSkip())
				EndDo
			EndIf

			//Carrega SGR - Checklist das operações
			If lMvChkOper
				SGR->( DbSetOrder(1) )

				nSGR := 1

				If SGR->( dbSeek( xFilial( "SGR" )+cProdAux+cCodAux+SG2->G2_OPERAC))
					//Enquanto houver registros filhos, vai adicionando no grid
					While SGR->(!Eof()) .and. xFilial("SGR") == SGR->GR_FILIAL .and. cProdAux == SGR->GR_PRODUTO .and. cCodAux == SGR->GR_ROTEIRO .and. SG2->G2_OPERAC == SGR->GR_OPERAC
						//Verifica se precisa gerar mais um linha(se for a primeira não precisa)
						If nSGR != 1
							oStruSGR:AddLine()
						EndIf
						//Adiciona o valor pra cada campo do grid
						For nI := 1 To Len(aStructSGR)
							If !( A124FormVa(aStructSGR[nI][1]) $ "|GR_FILIAL|GR_ROTEIRO|GR_PRODUTO|GR_OPERAC|GR_DESCOP|" )
								oStruSGR:LoadValue(aStructSGR[nI][1],SGR->&(aStructSGR[nI][1]))
							EndIf
						Next
						nSGR++
						//Pula pro próximo registro filho
						SGR->(DbSkip())
					EndDo
				EndIf
			EndIf

			//Carrega SHJ - Integração com o Drummer
			If TipoAps(.F.,"DRUMMER")
				SHJ->( DbSetOrder(1) )

				nSHJ := 1

				If SHJ->( dbSeek( xFilial( "SHJ" )+cCodAux+cProdAux+SG2->G2_OPERAC))
					//Enquanto houver registros filhos, vai adicionando no grid
					While SHJ->(!Eof()) .and. xFilial("SHJ") == SHJ->HJ_FILIAL .and. cProdAux == SHJ->HJ_PRODUTO .and. cCodAux == SHJ->HJ_ROTEIRO .and. SG2->G2_OPERAC == SHJ->HJ_OPERAC
						//Verifica se precisa gerar mais um linha(se for a primeira não precisa)
						If nSHJ != 1
							oStruSHJ:AddLine()
						EndIf
						//Adiciona o valor pra cada campo do grid
						For nI := 1 To Len(aStructSHJ)
							If !( A124FormVa(aStructSHJ[nI][1]) $ "|HJ_FILIAL|HJ_ROTEIRO|HJ_PRODUTO|HJ_OPERAC|HJ_CTRAB|" )
								oStruSHJ:LoadValue(aStructSHJ[nI][1],SHJ->&(aStructSHJ[nI][1]))
								oStruSHJ:SetValue("HJ_DESCREC",PadR(Posicione("SH1",1,xFilial("SH1")+FwFldGet("HJ_RECURSO"),"H1_DESCRI"),TamSX3("HJ_DESCREC")[1]))
							EndIf
						Next
						nSHJ++
						//Pula pro próximo registro filho
						SHJ->(DbSkip())
					EndDo
				EndIf
			EndIf

			//Pula pro próximo registro filho
			SG2->(DbSkip())
		EndDo
		If lUniLin
			oModel:GetModel("PCPA124_CAB"):LoadValue("G2_LINHAPR",oModel:GetModel("PCPA124_SG2"):GetValue("G2_LINHAPR",1))
			oModel:GetModel("PCPA124_CAB"):LoadValue("G2_TPLINHA",oModel:GetModel("PCPA124_SG2"):GetValue("G2_TPLINHA",1))
		EndIf
	EndIf

	oStruSG2:GoLine(1)

	If !lSoMontaModel
		nRet := FWExecView(STR0013, "PCPA124", OP_INCLUIR, /*oDlg*/, {|| .T. }, /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel)
	EndIf
Return oModel

/*/{Protheus.doc} A124LoadG
Função para carregar o folder  "Componentes"
@author Marcelo Neumann
@since 05/06/2018
@version 1.0
/*/
Static Function A124LoadG(oModel)
	Local aLoad      := {}
	Local cAlias     := GetNextAlias()
	Local cQuery     := ""
	Local cProduto   := ""
	Local cRoteiro   := ""
	Local cOperac    := ""
	Local cRevAtuPai := ""
	Local cDenBranco := ""
	Local cDenOperac := ""
	Local cFilSGF    := xFilial("SGF")
	Local nIndex     := 0
	Local nTotal     := 0
	Local lUsaOperac := .F.
	Local oMdlSG2    := Nil
	Local oModelSGFG := oModel:GetModel("PCPA124_SGF_G")
	Local aFields 	 := oModelSGFG:oFormModelStruct:aFields
	Local nLenFields := Len(aFields)
	Local aAux       := {}
	Local nIndCps    := 0
	Local cAliasSX3  := ''

	If oModel != Nil
		oMdlSG2    := oModel:GetModel("PCPA124_SG2")
		cProduto   := oModel:GetModel("PCPA124_CAB"):GetValue("G2_PRODUTO")
		cRoteiro   := oModel:GetModel("PCPA124_CAB"):GetValue("G2_CODIGO")
		cOperac    := oMdlSG2:GetValue("G2_OPERAC")
		lUsaOperac := oModel:GetModel('PCPA124_SGF_C'):GetValue('SGF_CHECK')
		cDenBranco := Space(Len(oModel:GetModel("PCPA124_SG2"):GetValue("G2_DESCRI")))
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+cProduto))
		cRevAtuPai := IIF(slPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)

		nTotal := oMdlSG2:Length()

		cQuery := " SELECT SG1.G1_COMP, "
		cQuery +=        " SB1.B1_DESC, "
		cQuery +=        " SG1.G1_TRT, "
		cQuery +=        " SG1.G1_QUANT "
		For nIndCps := 1 To Len(aFields)
			If !Empty(RetTitle(aFields[nIndCps][3]))
				cAliasSX3 := GetSx3Cache(AllTrim(aFields[nIndCps][3]), 'X3_ARQUIVO') + '.'
				If aFields[nIndCps][4] == "M" //Se for campo memo tem que ter tratamento especial
					cCampoMemo := AllTrim(aFields[nIndCps][3])
					cQuery += ", ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), " + cAliasSX3 + cCampoMemo + ")),'') AS " + cCampoMemo
				ElseIf aFields[nIndCps][14] == .F. //Se é um campo do tipo Virtual, não adiciona na Query
					cQuery += "," + cAliasSX3 + AllTrim(aFields[nIndCps][3])
				EndIf
			EndIf
		Next nIndCps
		cQuery +=   " FROM " + RetSqlName("SB1") + " SB1, "
		cQuery +=              RetSqlName("SG1") + " SG1 LEFT OUTER JOIN " 
		cQuery +=              RetSqlName("SGF") + " SGF "
		cQuery +=     " ON SGF.GF_FILIAL  = '" + xFilial("SGF") + "' "
		cQuery +=    " AND SGF.GF_PRODUTO = '" + cProduto + "' "
		cQuery +=    " AND SGF.GF_COMP    = SG1.G1_COMP "
		cQuery +=    " AND SGF.GF_TRT     = SG1.G1_TRT "
		cQuery +=    " AND SGF.GF_ROTEIRO = '" + cRoteiro + "' "
		cQuery +=    " AND SGF.D_E_L_E_T_ = ' ' "
		cQuery +=  " WHERE SG1.G1_FILIAL  = '" + xFilial("SG1") + "' "
		cQuery +=    " AND SG1.G1_COD     = '" + cProduto + "' "
		cQuery +=    " AND SG1.G1_REVINI  <= '" + cRevAtuPai + "' "
		cQuery +=    " AND SG1.G1_REVFIM  >= '" + cRevAtuPai + "' "
		cQuery +=    " AND SG1.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
		cQuery +=    " AND SB1.B1_COD     = SG1.G1_COMP "
		cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
		cQuery +=  " ORDER BY SGF.GF_OPERAC, SG1.G1_COMP, SG1.G1_TRT "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

		While (cAlias)->(!Eof())
			
			If !Empty((cAlias)->(GF_OPERAC))
				If !lUsaOperac .Or. (lUsaOperac .And. (cAlias)->GF_OPERAC == cOperac)
					//Busca a descrição da operação.
					cDenOperac := cDenBranco
					For nIndex := 1 To nTotal
						If oMdlSG2:GetValue("G2_OPERAC", nIndex) == (cAlias)->(GF_OPERAC)
							cDenOperac := oMdlSG2:GetValue("G2_DESCRI", nIndex)
							Exit
						EndIf
					Next nIndex

					aAux := {}
					For nIndex := 1 To nLenFields
						Do Case
							Case aFields[nIndex][3] == "GF_FILIAL"
								aadd(aAux, cFilSGF)
							Case aFields[nIndex][3] == "GF_PRODUTO"
								aadd(aAux, cProduto)
							Case aFields[nIndex][3] == "GF_ROTEIRO"
								aadd(aAux,cRoteiro )
							Case aFields[nIndex][3] == "GF_COMP"
								aadd(aAux, (cAlias)->G1_COMP)
							Case aFields[nIndex][3] == "GF_TRT"
								aadd(aAux, (cAlias)->G1_TRT)
							Case aFields[nIndex][3] == "GF_OPERAC"
								aadd(aAux, (cAlias)->GF_OPERAC)
							Case aFields[nIndex][3] == "SGF_DESCOP"
								aadd(aAux, cDenOperac)//OPERAÇÃO
							Case aFields[nIndex][3] == "SGF_DESCCOMP"
								aadd(aAux, (cAlias)->B1_DESC )//COMPONENTE
							Case aFields[nIndex][3] == "SGF_TRTCOMP"
								aadd(aAux, (cAlias)->G1_TRT)//Sequência do componente
							Case aFields[nIndex][3] == "SGF_QTDCOMP"
								aadd(aAux, (cAlias)->G1_QUANT)//QUANTIDADE
							Otherwise
								If aFields[nIndex][14] == .F. //Se é um campo do tipo virtual não utiliza o cAlias
									aadd(aAux, (cAlias)->&(aFields[nIndex][3]))
								Else
									aadd(aAux, &(getSx3Cache(aFields[nIndex][3], "X3_INIBRW")))
								EndIf
						EndCase
 				  Next nIndex
					aAdd(aLoad, {0, aAux})//Carrega registro no array de load
				EndIf
			ElseIf !lUsaOperac

				aAux := {}
				For nIndex := 1 To nLenFields
					Do Case
						Case aFields[nIndex][3] == "GF_FILIAL"
							aadd(aAux, cFilSGF)
						Case aFields[nIndex][3] == "GF_PRODUTO"
							aadd(aAux, cProduto)
						Case aFields[nIndex][3] == "GF_ROTEIRO"
							aadd(aAux,cRoteiro )
						Case aFields[nIndex][3] == "GF_COMP"
							aadd(aAux, (cAlias)->G1_COMP)
						Case aFields[nIndex][3] == "GF_TRT"
							aadd(aAux, (cAlias)->G1_TRT)
						Case aFields[nIndex][3] == "GF_OPERAC"
							aadd(aAux, (cAlias)->GF_OPERAC)
						Case aFields[nIndex][3] == "SGF_DESCOP"
							aadd(aAux, cDenBranco)//OPERAÇÃO
						Case aFields[nIndex][3] == "SGF_DESCCOMP"
							aadd(aAux, (cAlias)->B1_DESC )//COMPONENTE
						Case aFields[nIndex][3] == "SGF_TRTCOMP"
							aadd(aAux, (cAlias)->G1_TRT)//Sequência do componente
						Case aFields[nIndex][3] == "SGF_QTDCOMP"
							aadd(aAux, (cAlias)->G1_QUANT)//QUANTIDADE
						Otherwise
							If aFields[nIndex][14] == .F. //Se é um campo do tipo virtual não utiliza o cAlias
								aadd(aAux, (cAlias)->&(aFields[nIndex][3]))
							Else
								aadd(aAux, &(getSx3Cache(aFields[nIndex][3], "X3_INIBRW")))
							EndIf
					EndCase
				Next nIndex

				aAdd(aLoad, {0, aAux})//Carrega registro no array de load
			EndIf

			(cAlias)->(dbSkip())
		End
		(cAlias)->(dbCloseArea())
	EndIf

Return aLoad

/*/{Protheus.doc} A124Check
Dispara ao clicar no Check
@author Marcelo Neumann
@since 05/06/2018
@version 1.0
/*/
Static Function A124Check()
	Local oView := FwViewActive()
	Local oModel:= FWModelActive()

	oModel:GetModel('PCPA124_SGF_G'):ClearData( .F., .F. )
	oModel:GetModel('PCPA124_SGF_G'):DeActivate()
	oModel:GetModel('PCPA124_SGF_G'):Activate()

	oView:Refresh("GRID_SGF_G")
Return .T.

/*/{Protheus.doc} A124VisCo
Função para alterar o Check na visualização (OUTRAS AÇÕES > Altera Visual. Componentes)
@author Marcelo Neumann
@since 05/06/2018
@version 1.0
/*/
Static Function A124VisCo(oModel)
	Local lCheck := oModel:GetModel('PCPA124_SGF_C'):GetValue('SGF_CHECK')

	oModel:GetModel('PCPA124_SGF_C'):LoadValue('SGF_CHECK', !lCheck )

	A124Check()
Return .T.

/*/{Protheus.doc} A124ChLin
Função chamada na troca de linha do array de operações (PCPA124_SG2)
@author Marcelo Neumann
@since 05/06/2018
@version 1.0
/*/
Static Function A124ChLin()

	Local lRet        := .T.
	Local oModel      := FWModelActive()
	local oModelSG2   := oModel:GetModel("PCPA124_SG2")
	Local oModelSH3R  := oModel:GetModel("PCPA124_SH3_R")
	Local oModelSH3F  := oModel:GetModel("PCPA124_SH3_F")

	//Atualiza o array com os componentes de acordo com o checkbox e operação selecionada
	A124Check()

	A124HabLin(oModelSG2, oModelSH3R, oModelSH3F)

Return lRet

/*/{Protheus.doc} A124FormVa
Função para formatar a variável para utilização do operador $
@author Marcelo Neumann
@since 07/06/2018
@version 1.0
/*/
Static Function A124FormVa(cVar)

	cVar := "|" + AlLTrim(cVar) + "|"
Return cVar

/*/{Protheus.doc} A124RecRes
Efetua validações do recurso restritivo
@author Carlos Alexandre da Silveira
@since 07/06/2018
@version 1.0
/*/
Function A124RecRes()
	Local oModel	:= FWModelActive()
	Local oGridSHJ	:= oModel:GetModel("PCPA124_SHJ")

	//Inicializa descrição do recurso
	oGridSHJ:SetValue("HJ_DESCREC",PadR(Posicione("SH1",1,xFilial("SH1")+FwFldGet("HJ_RECURSO"),"H1_DESCRI"),TamSX3("HJ_DESCREC")[1]))
Return .T.

/*/{Protheus.doc} PCPA124View
//TODO Retorna ViewDef
@author brunno.costa
@since 26/06/2018
@version 6
@return oView, objeto, modelo da View
@param cRotinaChamadora, characters, nome da rotina chamadora
@param oView, object, oView criado na rotina chamadora
@param cIdFormPai, characters, id do Box Pai para utilização
@type function
/*/
Function PCPA124View(cRotinaChamadora, oView, cIdFormPai)
Return ViewDef(cRotinaChamadora, oView, cIdFormPai)

/*/{Protheus.doc} PCPA124PPI

Realiza a integração com o PC-Factory - PPI Multitask (TOTVS MES)

@param cXml      - XML que será enviado. Caso não seja passado esse parametro, será realizada
                   a chamada do Adapter para criação do XML.
                   Se for passado esse parâmetro, não será exibida a mensagem de erro caso exista,
                   nem será considerado o filtro da tabela SOE.
@param cRotProd  - Obrigatório quando utilizado o parâmetro cXml. Contém o código do produto e o código do roteiro. (RR+PRODUTO)
@param lExclusao - Indica se está chamando para rotina de exclusão de produto.
@param lFiltra   - Identifica se será realizado ou não o filtro do registro.
@param lPendAut  - Indica se será gerada a pendência sem realizar a pergunta para o usuário, caso ocorra algum erro.

@author  Lucas Konrad França
@since   25/06/2018
@return  lRet  - Indica se a integração com o PC-Factory foi realizada.
           .T. -> Integração Realizada
           .F. -> Integração não realizada.
/*/
Function PCPA124PPI(cXml, cRotProd, lExclusao, lFiltra, lPendAut)
	Local aArea     := GetArea()
	Local aAreaSG2  := SG2->(GetArea())
	Local lRet      := .T.
	Local aRetXML   := {}
	Local aRetWS    := {}
	Local aRetData  := {}
	Local aRetArq   := {}
	Local cNomeXml  := ""
	Local cProduto  := ""
	Local cRoteiro  := ""
	Local cGerouXml := ""
	Local lProc     := .F.

	//Variável utilizada para identificar que está sendo executada a integração para o PPI dentro do MATI200.
	Private lRunPPI := .T.

	Default cXml      := ""
	Default cRotProd  := ""
	Default lExclusao := .F.
	Default lFiltra   := .T.
	Default lPendAut  := .F.

	If !Empty(cXml) .And. PCPEvntXml(cXml) == "delete"
		lExclusao := .T.
	EndIf

	If Empty(cXml)
		cProduto := SG2->G2_PRODUTO
		cRoteiro := SG2->G2_CODIGO
	Else
		cRoteiro := PadR(StrTokArr(cRotProd,"+")[1], TAMSX3("G2_CODIGO")[1])
		cProduto := PadR(StrTokArr(cRotProd,"+")[2], TAMSX3("G2_PRODUTO")[1])
	EndIf

	//Realiza filtro na tabela SOE, para verificar se o produto entra na integração.
	If lFiltra
		//Faz o filtro posicionando em todas as operações. Se qualquer operação
		//entrar na integração, será realizado o processamento.
		SG2->(dbSetOrder(1))
		If SG2->(dbSeek(xFilial("SG2")+cProduto+cRoteiro))
			While SG2->(!Eof()) .And. xFilial("SG2")+cProduto+cRoteiro == SG2->(G2_FILIAL+G2_PRODUTO+G2_CODIGO)
				If PCPFiltPPI("SG2", AllTrim(cRoteiro)+"+"+AllTrim(cProduto), "SG2")
					lProc := .T.
					Exit
				EndIf
				SG2->(dbSkip())
			End
			SG2->(RestArea(aAreaSG2))
		EndIf
	Else
		lProc := .T.
	EndIf
	If lProc
		//Adapter para criação do XML
		If Empty(cXml)
			aRetXML := MATI632("", TRANS_SEND, EAI_MESSAGE_BUSINESS)
		Else
			aRetXML := {.T.,cXml}
		EndIf
		/*
			aRetXML[1] - Status da criação do XML
			aRetXML[2] - String com o XML
		*/
		If aRetXML[1]
			//Retira os caracteres especiais
			aRetXML[2] := EncodeUTF8(aRetXML[2])

			//Busca a data/hora de geração do XML
			aRetData := PCPxDtXml(aRetXML[2])
			/*
				aRetData[1] - Data de geração AAAAMMDD
				aRetData[1] - Hora de geração HH:MM:SS
			*/

			//Envia o XML para o PCFactory
			aRetWS := PCPWebsPPI(aRetXML[2])
			/*
				aRetWS[1] - Status do envio (1 - OK, 2 - Pendente, 3 - Erro.)
				aRetWS[2] - Mensagem de retorno do PPI
			*/

			If aRetWS[1] != "1" .And. Empty(cXml)
				If lPendAut
					lRet := .T.
				EndIf
			EndIf

			If lRet
				//Cria o XML fisicamente no diretório parametrizado
				aRetArq := PCPXmLPPI(aRetWS[1],"SG2",AllTrim(cRoteiro)+"+"+AllTrim(cProduto),aRetData[1],aRetData[2],aRetXML[2])
				/*
					aRetArq[1] Status da criação do arquivo. .T./.F.
					aRetArq[2] Nome do XML caso tenha criado. Mensagem de erro caso não tenha criado o XML.
				*/
				If !aRetArq[1]
					If Empty(cXml) .And. !lPendAut
						Alert(aRetArq[2])
					EndIf
				Else
					cNomeXml := aRetArq[2]
				EndIf
				If Empty(cNomeXml)
					cGerouXml := "2"
				Else
					cGerouXml := "1"
				EndIf

				//Cria a tabela SOF
				PCPCriaSOF("SG2",AllTrim(cRoteiro)+"+"+AllTrim(cProduto),aRetWS[1],cGerouXml,cNomeXml,aRetData[1],aRetData[2],__cUserId,aRetWS[2],aRetXML[2])
				//Array com os componentes que tiveram erro.
				If Type('aIntegPPI') == "A" .And. aRetWS[1] != "1"
					aAdd(aIntegPPI,{cProduto,aRetWS[2]})
				EndIf
			EndIf
		EndIf
	EndIf

	//Tratativa para retornar .F. mesmo quando é pendência automática;
	//Utilizado apenas para o programa de sincronização.
	If (AllTrim(FunName()) $ "PCPA111|MATA632|PCPA124") .And. Len(aRetWs) > 0 .And. aRetWS[1] != "1"
		lRet := .F.
	EndIf
	RestArea(aArea)
	SG2->(RestArea(aAreaSG2))
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A124LisOp()
A opção "Lista de Operações" irá carregar as operações da lista para a tela de roteiro
@author Carlos Alexandre da Silveira
@since 08/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A124LisOp(oViewPai)

	Local oStruSVH  	:= FWFormStruct(2, "SVH", {|cCampo| A124FormVa(cCampo) $ "|VH_OPERAC|VH_DESCOP|VH_RECURSO|VH_TEMPAD|VH_LOTEPAD|"})
	Local oStruSMX  	:= FWFormStruct(2,"SMX",{|cCampo| A124FormVa(cCampo) $ "|MX_CODIGO|MX_DESCRI|"})
	Local oView 		:= Nil
	Local oViewExec 	:= FWViewExec():New()
	Local oModel		:= oViewPai:GetModel()
	Local lRet 			:= .T.
	Local lCancelar 	:= .F.

	//Se em Visualização, não abre lista
	If oViewPai:GetOperation() == 1
		//Help - Recurso indisponível durante visualização. - Edite um roteiro para utilizar o recurso.
		Help( , , STR0074, , STR0072 , 1, 0, , , , , , { STR0073 } )
		Return lRet
	EndIf

	If oModel:GetModel("PCPA124_SG2"):IsUpdated()
		If !oModel:GetModel("PCPA124_SG2"):VldLineData(.F.)
			//Help - Verifique a operação
			Help( , , STR0074, , oModel:GetErrorMessage()[6] , ;
			     1, 0, , , , , , ;
			     { STR0069 + oModel:GetModel("PCPA124_SG2"):GetValue("G2_OPERAC") })
			Return .F.
		EndIf
	EndIf

	oModel:GetModel("PCPA124_SG2"):GoLine( oModel:GetModel("PCPA124_SG2"):Length(.F.) )

	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel)
	oView:SetOperation(oViewPai:GetOperation())

	oStruSMX:SetProperty("MX_DESCRI",MVC_VIEW_CANCHANGE,.F.)
	oStruSMX:SetProperty('MX_CODIGO',MVC_VIEW_LOOKUP,'SMX')

	oView:AddField("HEADER_SMX",oStruSMX ,"PCPA124_SMX")
	oView:AddGrid("GRID_SVH" , oStruSVH, "PCPA124_SVH")

	oView:CreateHorizontalBox("BOX_GRID_CAB",60,,.T.)
	oView:CreateHorizontalBox("BOX_GRID_SMX",100)

	oView:SetOwnerView("HEADER_SMX", 'BOX_GRID_CAB')
	oView:SetOwnerView("GRID_SVH", 'BOX_GRID_SMX')

	oView:SetOnlyView("GRID_SVH")

	lCancelar	:= .F.

	oView:AddUserButton(STR0054,"",{|| lConfLista := .F., lCancelar := .T., oView:CloseOwner() }, STR0054,,,.T.) // STR0054 - Cancelar

	//Proteção para execução com View ativa.
	If oModel != Nil .And. oModel:isActive()
	 	oViewExec:setModel(oModel)
	  	oViewExec:setView(oView)
	  	oViewExec:setTitle(STR0051) // STR0051 - Lista de Operações
	  	oViewExec:setOperation(oViewPai:GetOperation())
	  	oViewExec:setReduction(70)
	  	oViewExec:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0053},{.F.,""},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}) // STR0053 - Confirmar
	  	oViewExec:SetCloseOnOk({|oViewPai| A124CloseT(oViewPai)})
	  	oViewExec:SetModal(.T.)
	  	oViewExec:openView(.F.)

	  	If lCancelar .Or. !lConfLista
	  		A124Cancel(oView, oViewPai, oViewExec)
	  	Else
	    	lConfLista := .F.
	  		A124Cancel(oView, oViewPai, oViewExec)
	  	Endif
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A124Cancel()
Função para cancelar a opção da lista de operações
@author Carlos Alexandre da Silveira
@since 17/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A124Cancel(oView, oViewPai, oViewExec)

	Local lRet := .F.

	oViewExec:DeActivate()
	oView:DeActivate()
	oView:Destroy()
	oViewPai:GetModel("PCPA124_SVH"):ClearData(.F., .T.)
	oViewPai:GetModel("PCPA124_SMX"):LoadValue("MX_CODIGO"," ")
	oViewPai:GetModel("PCPA124_SMX"):LoadValue("MX_DESCRI"," ")
	oViewPai:GetModel("PCPA124_SG2"):GoLine(1)

 Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A124LoadX()
Função para carregar a lista de Operações
@author Carlos Alexandre da Silveira
@since 11/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A124LoadX(oModel)

	Local aLoad := {CriaVar("MX_CODIGO",.F.),CriaVar("MX_DESCRI",.F.)}

Return aLoad

//--------------------------------------------------------------------
/*/{Protheus.doc} A124VldLis()
Valida se o código da lista já existe
@author Carlos Alexandre da Silveira
@since 11/06/2018
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Function A124VldLis()

	Local oModel    := FWModelActive()
	Local oModelSMX := oModel:GetModel("PCPA124_SMX")
	Local oModelSVH := oModel:GetModel("PCPA124_SVH")
	Local aArea 	:= GetArea()
	Local lRet		:= .T.
	Local cCodSMX  	:= oModelSMX:GetValue("MX_CODIGO")
	Local oView 	:= FwViewActive()

	If Empty(oModelSMX:GetValue("MX_CODIGO"))
		oModelSMX:LoadValue("MX_DESCRI","")
		oModelSVH:ClearData(.F.,.T.)
	Else
		oModelSVH:ClearData(.F.,.F.)
		oModelSVH:DeActivate()
		oModelSVH:LFORCELOAD := .T.
		oModelSVH:Activate()
	EndIf

	oView:Refresh("GRID_SVH")

	dbSelectArea("SMX")
	SMX->(DbSetOrder(1))
	If !SMX->(DbSeek(xFilial("SMX") + cCodSMX))
		oModelSMX:LoadValue("MX_DESCRI","")
	Else
		oModelSMX:LoadValue("MX_DESCRI",SMX->MX_DESCRI)
	EndIf

	A124LoadH(oModel)

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A124LoadH()
Função para carregar o grid da tabela SVH
@author Carlos Alexandre da Silveira
@since 12/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A124LoadH(oModel)
	Local oView  		:= FwViewActive()
	Local oModelSVH 	:= oModel:GetModel("PCPA124_SVH")
	Local cCodigo 		:= ""
	Local aFields 		:= oModelSVH:oFormModelStruct:aFields
	Local nIndFields	:= 0

	If oView != Nil .And. oModel != Nil .And. oView:IsActive()
		cCodigo	:= oModel:GetModel("PCPA124_SMX"):GetValue("MX_CODIGO")

		dbSelectArea("SVH")
		SVH->(dbSetOrder(1))
		If SVH->(DbSeek(xFilial("SVH") + cCodigo))
			oModelSVH:SetNoUpdateLine(.F.)
			oModelSVH:SetNoDeleteLine(.F.)
			oModelSVH:SetNoInsertLine(.F.)
			oModelSVH:ClearData(.F.,.F.)
			While 	!SVH->(Eof()).And.SVH->VH_FILIAL  == xFilial("SVH").And.SVH->VH_CODIGO  == cCodigo
				oModelSVH:AddLine()
				For nIndFields := 1  to Len(aFields)
					oModelSVH:LoadValue(aFields[nIndFields][3], SVH->(&(aFields[nIndFields][3])))
				Next nIndFields
				SVH->(DbSkip())
			EndDo
			oModelSVH:GoLine(1)
			oModelSVH:SetNoUpdateLine(.T.)
			oModelSVH:SetNoDeleteLine(.T.)
			oModelSVH:SetNoInsertLine(.T.)
		Endif
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} A124CloseT()
Função para verificar se a tela da Lista de Operações será fechada ou não após a mensagem
@author Carlos Alexandre da Silveira
@since 14/06/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function A124CloseT(oViewPai)

	Local oModel	:= oViewPai:GetModel()
	Local oModelAux	:= FWLoadModel("PCPA124") //Carrega um novo modelo para fazer as validações
	Local nX		:= 0
	Local nSH3		:= 0
	Local lRet 		:= .T.
	Local aError	:= {}
	Local cOper     := ""
	Local cLoadXML	:= ""
	Local lUniLin   := SuperGetMV("MV_UNILIN",.F.,.F.)

	//Copia para o modelo auxiliar os dados do modelo atual
	cLoadXML := oModel:GetXMLData( .T. /*lDetail*/, ;
	                               oViewPai:GetOperation() /*nOperation*/, ;
	                               /*lXSL*/           , ;
	                               /*lVirtual*/       , ;
	                               /*lDeleted*/       , ;
	                               .T. /*lEmpty*/     , ;
	                               .F. /*lDefinition*/, ;
	                               /*cXMLFile*/ )
	If !oModelAux:LoadXMLData( cLoadXML, .T. )
		lRet := .F.
    	Help( , , 'Help', , STR0070, 1, 0) //STR0070 - "Ocorreu um erro ao realizar o backup dos dados."
	Else
 		lConfLista	:= .T.

		nQtdGrid := oModel:GetModel("PCPA124_SVH"):Length(.F.)
		For nX := 1 To nQtdGrid
		  	If oModel:GetModel("PCPA124_SG2"):SeekLine( {{"G2_OPERAC", oModel:GetModel("PCPA124_SVH"):GetValue("VH_OPERAC", nX)}}, .F., .F. )
		  		If !Empty(oModel:GetModel("PCPA124_SVH"):GetValue("VH_OPERAC"))
		  		    lConfLista := .F.
		  			If !Empty(cOper)
		  				cOper += ", "
		  			EndIf
		  			cOper += oModel:GetModel("PCPA124_SVH"):GetValue("VH_OPERAC", nX)
		  			lRet := .F.
		  		EndIf
		 	EndIf
		Next nX

		If lRet = .F.
			Help(,,'Help',,STR0052 + " (" + cOper + ")",1,0) // STR0052 - Esta operação já está cadastrada no roteiro (01, 02...).
		EndIf

	    If Empty(oModel:GetModel("PCPA124_SVH"):GetValue("VH_OPERAC"))
	    	Help(,,'Help',,STR0055,1,0) // STR0055 - A lista selecionada não existe.
			lRet := .F.
	    EndIf

		If lRet .And. lUniLin .And. SuperGetMV("MV_PCPRLPP",.F.,2) == 1
			If oModelAux:GetModel("PCPA124_CAB"):GetValue("G2_LINHAPR") != oModel:GetModel("PCPA124_SVH"):GetValue("VH_LINHAPR") .Or. ;
			   oModelAux:GetModel("PCPA124_CAB"):GetValue("G2_TPLINHA") != oModel:GetModel("PCPA124_SVH"):GetValue("VH_TPLINHA")
				If Empty(oModelAux:GetModel("PCPA124_CAB"):GetValue("G2_LINHAPR")) .And.;
				   Empty(oModelAux:GetModel("PCPA124_CAB"):GetValue("G2_TPLINHA")) .And.;
				   oModelAux:GetModel("PCPA124_SG2"):IsEmpty()
					lRet := oModelAux:GetModel("PCPA124_CAB"):SetValue("G2_LINHAPR",oModel:GetModel("PCPA124_SVH"):GetValue("VH_LINHAPR"))
					If lRet
						lRet := oModelAux:GetModel("PCPA124_CAB"):SetValue("G2_TPLINHA",oModel:GetModel("PCPA124_SVH"):GetValue("VH_TPLINHA"))
					EndIf
				Else
					lRet := .F.
					Help(,,'Help',,STR0076,1,0) //"Esta lista não poderá ser importada, pois as informações de Linha Produção/Tipo Linha estão diferentes das informações do roteiro."
				EndIf
			EndIf
		EndIf

		If lRet
			oModelAux:GetModel("PCPA124_SG2"):SetNoUpdateLine(.F.)
			oModelAux:GetModel("PCPA124_SG2"):SetNoDeleteLine(.F.)

			nQtdGrid := oModel:GetModel("PCPA124_SVH"):Length(.F.)

			For nX := 1 To nQtdGrid
				If !( nX == 1 .And. ;
				      oModelAux:GetModel("PCPA124_SG2"):Length() == 1 .And. ;
				      Empty(oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_OPERAC")) .And. ;
				      Empty(oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_TEMPAD")) .And. ;
				      !oModelAux:GetModel("PCPA124_SG2"):IsDeleted() )

					oModelAux:GetModel("PCPA124_SG2"):AddLine()
				EndIf

				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_OPERAC",  oModel:GetModel("PCPA124_SVH"):GetValue("VH_OPERAC",  nX))
				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_RECURSO", oModel:GetModel("PCPA124_SVH"):GetValue("VH_RECURSO", nX))
				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_FERRAM",  oModel:GetModel("PCPA124_SVH"):GetValue("VH_FERRAM",  nX))
				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_TPALOCF", oModel:GetModel("PCPA124_SVH"):GetValue("VH_TPALOCF", nX))
				If lUniLin
					oModelAux:GetModel("PCPA124_SG2"):LoadValue("G2_LINHAPR", oModel:GetModel("PCPA124_SVH"):GetValue("VH_LINHAPR", nX))
					oModelAux:GetModel("PCPA124_SG2"):LoadValue("G2_TPLINHA", oModel:GetModel("PCPA124_SVH"):GetValue("VH_TPLINHA", nX))
				Else
					oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_LINHAPR", oModel:GetModel("PCPA124_SVH"):GetValue("VH_LINHAPR", nX))
					oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_TPLINHA", oModel:GetModel("PCPA124_SVH"):GetValue("VH_TPLINHA", nX))
				EndIf
				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_DESCRI",  oModel:GetModel("PCPA124_SVH"):GetValue("VH_DESCOP",  nX))
				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_MAOOBRA", oModel:GetModel("PCPA124_SVH"):GetValue("VH_MAOOBRA", nX))
				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_DEPTO",   oModel:GetModel("PCPA124_SVH"):GetValue("VH_DEPTO",   nX))
				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_SETUP",   oModel:GetModel("PCPA124_SVH"):GetValue("VH_SETUP",   nX))
				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_FORMSTP", oModel:GetModel("PCPA124_SVH"):GetValue("VH_FORMSTP", nX))
				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_LOTEPAD", oModel:GetModel("PCPA124_SVH"):GetValue("VH_LOTEPAD", nX))
				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_TEMPAD",  oModel:GetModel("PCPA124_SVH"):GetValue("VH_TEMPAD",  nX))
				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_TPOPER",  oModel:GetModel("PCPA124_SVH"):GetValue("VH_TPOPER",  nX))
				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_TPSOBRE", oModel:GetModel("PCPA124_SVH"):GetValue("VH_TPSOBRE", nX))
				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_TEMPSOB", oModel:GetModel("PCPA124_SVH"):GetValue("VH_TEMPSOB", nX))
				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_TEMPDES", oModel:GetModel("PCPA124_SVH"):GetValue("VH_TEMPDES", nX))
				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_TPDESD",  oModel:GetModel("PCPA124_SVH"):GetValue("VH_TPDESD",  nX))
				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_DESPROP", oModel:GetModel("PCPA124_SVH"):GetValue("VH_DESPROP", nX))
				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_CTRAB",   oModel:GetModel("PCPA124_SVH"):GetValue("VH_CTRAB",   nX))
				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_TEMPEND", oModel:GetModel("PCPA124_SVH"):GetValue("VH_TEMPEND", nX))
				oModelAux:GetModel("PCPA124_SG2"):SetValue("G2_LISTA",   oModel:GetModel("PCPA124_SVH"):GetValue("VH_CODIGO",  nX))

				If !oModelAux:GetModel("PCPA124_SG2"):VldLineData(.F.)
			    	aError := oModelAux:GetErrorMessage()
			    	cOper  := oModel:GetModel("PCPA124_SVH"):GetValue("VH_OPERAC", nX)
			    	lRet   := .F.
					Exit
				EndIf

				dbSelectArea("SMY")
				SMY->(DbSetOrder(1))
				SMY->(DbSeek(xFilial("SMY") + oModel:GetModel("PCPA124_SVH"):GetValue("VH_CODIGO",nX) + oModel:GetModel("PCPA124_SVH"):GetValue("VH_OPERAC", nX)))

				oModelAux:GetModel("PCPA124_SH3_R"):SetNoUpdateLine(.F.)
				oModelAux:GetModel("PCPA124_SH3_R"):SetNoDeleteLine(.F.)
				oModelAux:GetModel("PCPA124_SH3_R"):SetNoInsertLine(.F.)
				oModelAux:GetModel("PCPA124_SH3_F"):SetNoUpdateLine(.F.)
				oModelAux:GetModel("PCPA124_SH3_F"):SetNoDeleteLine(.F.)
				oModelAux:GetModel("PCPA124_SH3_F"):SetNoInsertLine(.F.)

				While SMY->(!Eof()) .And. xFilial("SMY") == SMY->MY_FILIAL .And. ;
					  oModel:GetModel("PCPA124_SVH"):GetValue("VH_CODIGO", nX) == SMY->MY_CODIGO .And. ;
					  oModel:GetModel("PCPA124_SVH"):GetValue("VH_OPERAC", nX) == SMY->MY_OPERAC

					If !Empty(SMY->MY_RECALTE)
						If !Empty(oModelAux:GetModel("PCPA124_SH3_R"):GetValue("H3_RECALTE"))
					    	oModelAux:GetModel("PCPA124_SH3_R"):AddLine()
						EndIf
						oModelAux:GetModel("PCPA124_SH3_R"):SetValue("H3_RECALTE", SMY->MY_RECALTE)
						oModelAux:GetModel("PCPA124_SH3_R"):SetValue("H3_TIPO",    SMY->MY_TIPO)
						oModelAux:GetModel("PCPA124_SH3_R"):SetValue("H3_EFICIEN", SMY->MY_EFICIEN)

						If !oModelAux:GetModel("PCPA124_SH3_R"):VldLineData(.F.)
					    	aError := oModelAux:GetErrorMessage()
					    	cOper  := oModel:GetModel("PCPA124_SVH"):GetValue("VH_OPERAC", nX)
					    	lRet := .F.
							Exit
						EndIf
					EndIf

					If !Empty(SMY->MY_FERRAM)
						If !Empty(oModelAux:GetModel("PCPA124_SH3_F"):GetValue("H3_FERRAM"))
					    	oModelAux:GetModel("PCPA124_SH3_F"):AddLine()
						EndIf
						oModelAux:GetModel("PCPA124_SH3_F"):SetValue("H3_FERRAM", SMY->MY_FERRAM)

						If !oModelAux:GetModel("PCPA124_SH3_F"):VldLineData(.F.)
					    	aError := oModelAux:GetErrorMessage()
					    	cOper  := oModel:GetModel("PCPA124_SVH"):GetValue("VH_OPERAC", nX)
					    	lRet := .F.
							Exit
						EndIf
					EndIf
					SMY->(dbSkip())
				End

				If !lRet
					Exit
				EndIf
			Next nX

			//Se a lista está correta, carrega os dados do modelo Auxiliar no modelo Atual
			If lRet .And. lUniLin .And. SuperGetMV("MV_PCPRLPP",.F.,2) == 1
				If oModel:GetModel("PCPA124_CAB"):GetValue("G2_LINHAPR") != oModel:GetModel("PCPA124_SVH"):GetValue("VH_LINHAPR") .Or. ;
				oModel:GetModel("PCPA124_CAB"):GetValue("G2_TPLINHA") != oModel:GetModel("PCPA124_SVH"):GetValue("VH_TPLINHA")
					If Empty(oModel:GetModel("PCPA124_CAB"):GetValue("G2_LINHAPR")) .And.;
					Empty(oModel:GetModel("PCPA124_CAB"):GetValue("G2_TPLINHA")) .And.;
					oModel:GetModel("PCPA124_SG2"):IsEmpty()
						lRet := oModel:GetModel("PCPA124_CAB"):SetValue("G2_LINHAPR",oModel:GetModel("PCPA124_SVH"):GetValue("VH_LINHAPR"))
						If lRet
							lRet := oModel:GetModel("PCPA124_CAB"):SetValue("G2_TPLINHA",oModel:GetModel("PCPA124_SVH"):GetValue("VH_TPLINHA"))
						EndIf
					Else
						lRet := .F.
						Help(,,'Help',,STR0076,1,0) //"Esta lista não poderá ser importada, pois as informações de Linha Produção/Tipo Linha estão diferentes das informações do roteiro."
					EndIf
				EndIf
			EndIf

			//Se a lista está correta, carrega os dados do modelo Auxiliar no modelo Atual
			If lRet
				oModel:GetModel("PCPA124_SG2"  ):SetNoUpdateLine(.F.)
				oModel:GetModel("PCPA124_SG2"  ):SetNoDeleteLine(.F.)
				oModel:GetModel("PCPA124_SH3_R"):SetNoUpdateLine(.F.)
				oModel:GetModel("PCPA124_SH3_R"):SetNoDeleteLine(.F.)
				oModel:GetModel("PCPA124_SH3_R"):SetNoInsertLine(.F.)
				oModel:GetModel("PCPA124_SH3_F"):SetNoUpdateLine(.F.)
				oModel:GetModel("PCPA124_SH3_F"):SetNoDeleteLine(.F.)
				oModel:GetModel("PCPA124_SH3_F"):SetNoInsertLine(.F.)

				//Se a linha posicionada está válida
				If oModel:GetModel("PCPA124_SG2"):IsLineValidate(oModel:GetModel("PCPA124_SG2"):GetLine()) .Or. ;
				   oModel:GetModel("PCPA124_SG2"):IsDeleted(oModel:GetModel("PCPA124_SG2"):GetLine())
					oModel:GetModel("PCPA124_SG2"):AddLine()
				EndIf

				For nX := oModel:GetModel("PCPA124_SG2"):Length(.F.) To oModelAux:GetModel("PCPA124_SG2"):Length(.F.)
					oModel:GetModel("PCPA124_SG2"  ):SetNoUpdateLine(.F.)
					oModel:GetModel("PCPA124_SG2"  ):SetNoDeleteLine(.F.)
					oModel:GetModel("PCPA124_SH3_R"):SetNoUpdateLine(.F.)
					oModel:GetModel("PCPA124_SH3_R"):SetNoDeleteLine(.F.)
					oModel:GetModel("PCPA124_SH3_R"):SetNoInsertLine(.F.)
					oModel:GetModel("PCPA124_SH3_F"):SetNoUpdateLine(.F.)
					oModel:GetModel("PCPA124_SH3_F"):SetNoDeleteLine(.F.)
					oModel:GetModel("PCPA124_SH3_F"):SetNoInsertLine(.F.)

					oModel:GetModel("PCPA124_SG2"):SetValue("G2_OPERAC",  oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_OPERAC",  nX))
					oModel:GetModel("PCPA124_SG2"):SetValue("G2_RECURSO", oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_RECURSO", nX))
					oModel:GetModel("PCPA124_SG2"):SetValue("G2_FERRAM",  oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_FERRAM",  nX))
					oModel:GetModel("PCPA124_SG2"):SetValue("G2_TPALOCF", oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_TPALOCF", nX))
					If lUniLin
						oModel:GetModel("PCPA124_SG2"):LoadValue("G2_LINHAPR", oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_LINHAPR", nX))
						oModel:GetModel("PCPA124_SG2"):LoadValue("G2_TPLINHA", oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_TPLINHA", nX))
					Else
						oModel:GetModel("PCPA124_SG2"):SetValue("G2_LINHAPR", oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_LINHAPR", nX))
						oModel:GetModel("PCPA124_SG2"):SetValue("G2_TPLINHA", oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_TPLINHA", nX))
					EndIf
					oModel:GetModel("PCPA124_SG2"):SetValue("G2_DESCRI",  oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_DESCRI",  nX))
					oModel:GetModel("PCPA124_SG2"):SetValue("G2_MAOOBRA", oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_MAOOBRA", nX))
					oModel:GetModel("PCPA124_SG2"):SetValue("G2_DEPTO",   oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_DEPTO",   nX))
					oModel:GetModel("PCPA124_SG2"):SetValue("G2_SETUP",   oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_SETUP",   nX))
					oModel:GetModel("PCPA124_SG2"):SetValue("G2_FORMSTP", oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_FORMSTP", nX))
					oModel:GetModel("PCPA124_SG2"):SetValue("G2_LOTEPAD", oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_LOTEPAD", nX))
					oModel:GetModel("PCPA124_SG2"):SetValue("G2_TEMPAD",  oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_TEMPAD",  nX))
					oModel:GetModel("PCPA124_SG2"):SetValue("G2_TPOPER",  oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_TPOPER",  nX))
					oModel:GetModel("PCPA124_SG2"):SetValue("G2_TPSOBRE", oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_TPSOBRE", nX))
					oModel:GetModel("PCPA124_SG2"):SetValue("G2_TEMPSOB", oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_TEMPSOB", nX))
					oModel:GetModel("PCPA124_SG2"):SetValue("G2_TPDESD",  oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_TPDESD",  nX))
					oModel:GetModel("PCPA124_SG2"):SetValue("G2_TEMPDES", oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_TEMPDES", nX))
					oModel:GetModel("PCPA124_SG2"):SetValue("G2_DESPROP", oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_DESPROP", nX))
					oModel:GetModel("PCPA124_SG2"):SetValue("G2_CTRAB",   oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_CTRAB",   nX))
					oModel:GetModel("PCPA124_SG2"):SetValue("G2_TEMPEND", oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_TEMPEND", nX))
					oModel:GetModel("PCPA124_SG2"):SetValue("G2_LISTA",   oModelAux:GetModel("PCPA124_SG2"):GetValue("G2_LISTA",   nX))

					oModelAux:GetModel("PCPA124_SG2"):GoLine(nX)
					For nSH3 := 1 To oModelAux:GetModel("PCPA124_SH3_R"):Length(.F.)
						If nSH3 != 1
							oModel:GetModel("PCPA124_SH3_R"):AddLine()
						EndIf
						oModel:GetModel("PCPA124_SH3_R"):SetValue("H3_RECALTE", oModelAux:GetModel("PCPA124_SH3_R"):GetValue("H3_RECALTE", nSH3))
						oModel:GetModel("PCPA124_SH3_R"):SetValue("H3_TIPO",    oModelAux:GetModel("PCPA124_SH3_R"):GetValue("H3_TIPO",    nSH3))
						oModel:GetModel("PCPA124_SH3_R"):SetValue("H3_EFICIEN", oModelAux:GetModel("PCPA124_SH3_R"):GetValue("H3_EFICIEN", nSH3))
					Next nSH3

					For nSH3 := 1 To oModelAux:GetModel("PCPA124_SH3_F"):Length(.F.)
						If nSH3 != 1
							oModel:GetModel("PCPA124_SH3_F"):AddLine()
						EndIf
						oModel:GetModel("PCPA124_SH3_F"):SetValue("H3_FERRAM", oModelAux:GetModel("PCPA124_SH3_F"):GetValue("H3_FERRAM", nSH3))
					Next nSH3

					If nX != oModelAux:GetModel("PCPA124_SG2"):Length(.F.)
						oModel:GetModel("PCPA124_SG2"):AddLine()
					EndIf
				Next nX
			Else
				Help( , , aError[MODEL_MSGERR_ID] + " (" + aError[MODEL_MSGERR_IDFORMERR] + ")", , ;
				     STR0067 + CHR(13) + CHR(10) + ; //"Existem erros que impedem a importação da lista:"
				     AllTrim(RetTitle("G2_OPERAC")) + " " + AllTrim(cOper) + ": " + AllTrim(aError[MODEL_MSGERR_MESSAGE]), ;
					 1, 0, , , , , , { STR0068 }) //STR0068 - "Verifique o Cadastro da Lista de Operações."
			EndIf

			oModelAux:DeActivate()

 			oModel:GetModel("PCPA124_SH3_R"):SetNoUpdateLine(.T.)
			oModel:GetModel("PCPA124_SH3_R"):SetNoDeleteLine(.T.)
			oModel:GetModel("PCPA124_SH3_R"):SetNoInsertLine(.T.)
			oModel:GetModel("PCPA124_SH3_F"):SetNoUpdateLine(.T.)
			oModel:GetModel("PCPA124_SH3_F"):SetNoDeleteLine(.T.)
			oModel:GetModel("PCPA124_SH3_F"):SetNoInsertLine(.T.)

			A124HabLin(oModel:GetModel("PCPA124_SG2"), oModel:GetModel("PCPA124_SH3_R"), oModel:GetModel("PCPA124_SH3_F"))
		EndIf
	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} A124HabLin()
Função para verificar se habilita a linha para edição/exclusão
@author Carlos Alexandre da Silveira
@since 14/06/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function A124HabLin(oModelSG2, oModelSH3R, oModelSH3F)
	Local lRet 		:= .T.
	Local lEditln	:= SuperGetMV("MV_PCPRLPP",.F., 2 )

	If !Empty(oModelSG2:GetValue("G2_LISTA")) .and. lEditln == 1
		oModelSH3R:SetNoDeleteLine( .T. )
		oModelSH3R:SetNoInsertLine( .T. )
		oModelSH3F:SetNoDeleteLine( .T. )
		oModelSH3F:SetNoInsertLine( .T. )
	Else
		PermiteSH3(oModelSG2, oModelSH3R, oModelSH3F)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A124DPCod()
Codigo que retorna o proximo numero de roteiro disponivel conforme o produto
@author Douglas Heydt
@since 25/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function A124DPCod(cProduto)
	Local cCodigo	:= '01'
	Local aArea     := GetArea()
	Local cAliasSG2 := GetNextAlias()
	Local cQuery := ""

	cQuery :="SELECT MAX (G2_CODIGO) G2_CODIGO FROM "+RetSqlName("SG2")+" "
	cQuery +="WHERE G2_FILIAL ='"+xFilial("SG2")+"'"+" AND G2_PRODUTO = '"+cProduto+"' AND D_E_L_E_T_ = ' '"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSG2,.T.,.T.)

	If (cAliasSG2)->(!Eof())
		cCodigo:= Soma1((cAliasSG2)->(G2_CODIGO))
	EndIf

	(cAliasSG2)->(dbCloseArea())

	RestArea(aArea)

Return cCodigo

/*/{Protheus.doc} A124FldOrd
Monta o Struct para exibição da modal de integração de Roteiro x Ordens de produção.

@author lucas.franca
@since 16/07/2018
@version 1.0
@return Nil
@param oStruct	- Struct para criar os campos. Deve ser passado por referência.
@param lModel	- Indica se o struct é do ModelDef (.T.), ou do ViewDef(.F.)
/*/
Function A124FldOrd(oStruct,lModel)
	Local aTamQtd := {}

	If lModel
		aTamQtd := TamSX3("C2_QUANT")

		//Campos do ModelDef
		oStruct:AddField(''	,;	// 	[01]  C   Titulo do campo
						STR0030					,;	// 	[02]  C   ToolTip do campo //'Seleciona ordem'
						"ORDSELEC"				,;	// 	[03]  C   Id do Field
						"L"						,;	// 	[04]  C   Tipo do campo
						1						,;	// 	[05]  N   Tamanho do campo
						0						,;	// 	[06]  N   Decimal do campo
						NIL						,;	// 	[07]  B   Code-block de validação do campo
						NIL						,;	// 	[08]  B   Code-block de validação When do campo
						{}						,;	//	[09]  A   Lista de valores permitido do campo
						.F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
						Nil						,;	//	[11]  B   Code-block de inicializacao do campo
						NIL						,;	//	[12]  L   Indica se trata-se de um campo chave
						NIL						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.)						// 	[14]  L   Indica se o campo é virtual
		oStruct:AddField(STR0031				,;	// 	[01]  C   Titulo do campo //'Ordem de produção'
						STR0031					,;	// 	[02]  C   ToolTip do campo //'Ordem de produção'
						"ORDOP"					,;	// 	[03]  C   Id do Field
						"C"						,;	// 	[04]  C   Tipo do campo
						TamSX3("H6_OP")[1]		,;	// 	[05]  N   Tamanho do campo
						0						,;	// 	[06]  N   Decimal do campo
						NIL						,;	// 	[07]  B   Code-block de validação do campo
						NIL						,;	// 	[08]  B   Code-block de validação When do campo
						{}						,;	//	[09]  A   Lista de valores permitido do campo
						.F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
						Nil						,;	//	[11]  B   Code-block de inicializacao do campo
						NIL						,;	//	[12]  L   Indica se trata-se de um campo chave
						NIL						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.)						// 	[14]  L   Indica se o campo é virtual
		oStruct:AddField(STR0006				,;	// 	[01]  C   Titulo do campo //'Produto'
						STR0006					,;	// 	[02]  C   ToolTip do campo //'Produto'
						"ORDPROD"				,;	// 	[03]  C   Id do Field
						"C"						,;	// 	[04]  C   Tipo do campo
						TamSX3("B1_DESC")[1]	,;	// 	[05]  N   Tamanho do campo
						0						,;	// 	[06]  N   Decimal do campo
						NIL						,;	// 	[07]  B   Code-block de validação do campo
						NIL						,;	// 	[08]  B   Code-block de validação When do campo
						{}						,;	//	[09]  A   Lista de valores permitido do campo
						.F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
						Nil						,;	//	[11]  B   Code-block de inicializacao do campo
						NIL						,;	//	[12]  L   Indica se trata-se de um campo chave
						NIL						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.)						// 	[14]  L   Indica se o campo é virtual
		oStruct:AddField(STR0001				,;	// 	[01]  C   Titulo do campo //'Roteiro de operações'
						STR0001					,;	// 	[02]  C   ToolTip do campo //'Roteiro de operações'
						"ORDROTEIRO"			,;	// 	[03]  C   Id do Field
						"C"						,;	// 	[04]  C   Tipo do campo
						TamSX3("G2_CODIGO")[1]	,;	// 	[05]  N   Tamanho do campo
						0						,;	// 	[06]  N   Decimal do campo
						NIL						,;	// 	[07]  B   Code-block de validação do campo
						NIL						,;	// 	[08]  B   Code-block de validação When do campo
						{}						,;	//	[09]  A   Lista de valores permitido do campo
						.F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
						Nil						,;	//	[11]  B   Code-block de inicializacao do campo
						NIL						,;	//	[12]  L   Indica se trata-se de um campo chave
						NIL						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.)						// 	[14]  L   Indica se o campo é virtual
		oStruct:AddField(STR0032				,;	// 	[01]  C   Titulo do campo //'Data Entrega'
						STR0032					,;	// 	[02]  C   ToolTip do campo //'Data Entrega'
						"ORDENTREGA"			,;	// 	[03]  C   Id do Field
						"D"						,;	// 	[04]  C   Tipo do campo
						10						,;	// 	[05]  N   Tamanho do campo
						0						,;	// 	[06]  N   Decimal do campo
						NIL						,;	// 	[07]  B   Code-block de validação do campo
						NIL						,;	// 	[08]  B   Code-block de validação When do campo
						{}						,;	//	[09]  A   Lista de valores permitido do campo
						.F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
						Nil						,;	//	[11]  B   Code-block de inicializacao do campo
						NIL						,;	//	[12]  L   Indica se trata-se de um campo chave
						NIL						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.)						// 	[14]  L   Indica se o campo é virtual
		oStruct:AddField(STR0056				,;	// 	[01]  C   Titulo do campo //"Quantidade"
						STR0056					,;	// 	[02]  C   ToolTip do campo //"Quantidade"
						"ORDQUANT"				,;	// 	[03]  C   Id do Field
						"N"						,;	// 	[04]  C   Tipo do campo
						aTamQtd[1]				,;	// 	[05]  N   Tamanho do campo
						aTamQtd[2]				,;	// 	[06]  N   Decimal do campo
						NIL						,;	// 	[07]  B   Code-block de validação do campo
						NIL						,;	// 	[08]  B   Code-block de validação When do campo
						{}						,;	//	[09]  A   Lista de valores permitido do campo
						.F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
						Nil						,;	//	[11]  B   Code-block de inicializacao do campo
						NIL						,;	//	[12]  L   Indica se trata-se de um campo chave
						NIL						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.)						// 	[14]  L   Indica se o campo é virtual
	Else
		//Campos do ViewDef
		oStruct:AddField("ORDSELEC"					,;	// [01]  C   Nome do Campo
						"01"						,;	// [02]  C   Ordem
						""							,;	// [03]  C   Titulo do campo
						STR0030						,;	// [04]  C   Descricao do campo //"Seleciona ordem"
						NIL							,;	// [05]  A   Array com Help
						"L"							,;	// [06]  C   Tipo do campo
						NIL							,;	// [07]  C   Picture
						NIL							,;	// [08]  B   Bloco de PictTre Var
						NIL							,;	// [09]  C   Consulta F3
						.T.							,;	// [10]  L   Indica se o campo é alteravel
						NIL							,;	// [11]  C   Pasta do campo
						NIL							,;	// [12]  C   Agrupamento do campo
						NIL							,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL							,;	// [15]  C   Inicializador de Browse
						.T.							,;	// [16]  L   Indica se o campo é virtual
						NIL							,;	// [17]  C   Picture Variavel
						NIL							)	// [18]  L   Indica pulo de linha após o campo
		oStruct:AddField("ORDOP"						,;	// [01]  C   Nome do Campo
						"10"						,;	// [02]  C   Ordem
						STR0031						,;	// [03]  C   Titulo do campo //"Ordem de produção"
						STR0031						,;	// [04]  C   Descricao do campo //"Ordem de produção"
						NIL							,;	// [05]  A   Array com Help
						"C"							,;	// [06]  C   Tipo do campo
						"@!"						,;	// [07]  C   Picture
						NIL							,;	// [08]  B   Bloco de PictTre Var
						NIL							,;	// [09]  C   Consulta F3
						.F.							,;	// [10]  L   Indica se o campo é alteravel
						NIL							,;	// [11]  C   Pasta do campo
						NIL							,;	// [12]  C   Agrupamento do campo
						NIL							,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL							,;	// [15]  C   Inicializador de Browse
						.T.							,;	// [16]  L   Indica se o campo é virtual
						NIL							,;	// [17]  C   Picture Variavel
						NIL							)	// [18]  L   Indica pulo de linha após o campo
		oStruct:AddField("ORDPROD"					,;	// [01]  C   Nome do Campo
						"20"						,;	// [02]  C   Ordem
						STR0006						,;	// [03]  C   Titulo do campo //"Produto"
						STR0006						,;	// [04]  C   Descricao do campo //"Produto"
						NIL							,;	// [05]  A   Array com Help
						"C"							,;	// [06]  C   Tipo do campo
						"@!"						,;	// [07]  C   Picture
						NIL							,;	// [08]  B   Bloco de PictTre Var
						NIL							,;	// [09]  C   Consulta F3
						.F.							,;	// [10]  L   Indica se o campo é alteravel
						NIL							,;	// [11]  C   Pasta do campo
						NIL							,;	// [12]  C   Agrupamento do campo
						NIL							,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL							,;	// [15]  C   Inicializador de Browse
						.T.							,;	// [16]  L   Indica se o campo é virtual
						NIL							,;	// [17]  C   Picture Variavel
						NIL							)	// [18]  L   Indica pulo de linha após o campo
		oStruct:AddField("ORDROTEIRO"				,;	// [01]  C   Nome do Campo
						"30"						,;	// [02]  C   Ordem
						STR0001						,;	// [03]  C   Titulo do campo //"Roteiro de operações"
						STR0001						,;	// [04]  C   Descricao do campo //"Roteiro de operações"
						NIL							,;	// [05]  A   Array com Help
						"C"							,;	// [06]  C   Tipo do campo
						"@!"						,;	// [07]  C   Picture
						NIL							,;	// [08]  B   Bloco de PictTre Var
						NIL							,;	// [09]  C   Consulta F3
						.F.							,;	// [10]  L   Indica se o campo é alteravel
						NIL							,;	// [11]  C   Pasta do campo
						NIL							,;	// [12]  C   Agrupamento do campo
						NIL							,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL							,;	// [15]  C   Inicializador de Browse
						.T.							,;	// [16]  L   Indica se o campo é virtual
						NIL							,;	// [17]  C   Picture Variavel
						NIL							)	// [18]  L   Indica pulo de linha após o campo
		oStruct:AddField("ORDENTREGA"				,;	// [01]  C   Nome do Campo
						"40"						,;	// [02]  C   Ordem
						STR0032						,;	// [03]  C   Titulo do campo //"Data Entrega"
						STR0032						,;	// [04]  C   Descricao do campo //"Data Entrega"
						NIL							,;	// [05]  A   Array com Help
						"D"							,;	// [06]  C   Tipo do campo
						NIL							,;	// [07]  C   Picture
						NIL							,;	// [08]  B   Bloco de PictTre Var
						NIL							,;	// [09]  C   Consulta F3
						.F.							,;	// [10]  L   Indica se o campo é alteravel
						NIL							,;	// [11]  C   Pasta do campo
						NIL							,;	// [12]  C   Agrupamento do campo
						NIL							,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL							,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL							,;	// [15]  C   Inicializador de Browse
						.T.							,;	// [16]  L   Indica se o campo é virtual
						NIL							,;	// [17]  C   Picture Variavel
						NIL							)	// [18]  L   Indica pulo de linha após o campo
	EndIf
Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} PCPA123MNU()
Função que executa a view do programa.
Necessário desvio da abertura re-executando sempre a MenuDef e ViewDef

@param nOpcao	- Identifica a operação que está sendo executada (inclusão/exclusão/alteração/visualização)

@author brunno.costa
@since 30/10/2018
@version 1.0
@return nOK	- Identifica se o usuário confirmou (nOk==0) ou cancelou (nOk==1) a operação.
/*/
//--------------------------------------------------------------------
Function PCPA124MNU(nOpcao)
	Local nOpc   := 2
	Local nOk    := 0
	Local cTexto := ""

	Do Case
		Case nOpcao == 2
			nOpc   := MODEL_OPERATION_VIEW
			cTexto := STR0012 //Visualizar
		Case nOpcao == 3
			nOpc   := MODEL_OPERATION_INSERT
			cTexto := STR0013 //Incluir
		Case nOpcao == 4
			nOpc   := MODEL_OPERATION_UPDATE
			cTexto := STR0014 //Alterar
		Case nOpcao == 5
			nOpc   := MODEL_OPERATION_DELETE
			cTexto := STR0015 //Excluir
	EndCase
	nOk := FWExecView(cTexto, "PCPA124", nOpc,,,,,,,,,)
Return nOk

//--------------------------------------------------------------------
/*/{Protheus.doc} PCPA123MNU()
Função para reativar funções dos modelos relacionados da SH3
@author brunno.costa
@since 30/10/2018
@version 1.0
@return .T.
/*/
//--------------------------------------------------------------------
Static Function PermiteSH3(oModelSG2, oModelSH3R, oModelSH3F)
	Local oModel := FWModelActive()

	Default oModelSG2   := oModel:GetModel("PCPA124_SG2")
	Default oModelSH3R  := oModel:GetModel("PCPA124_SH3_R")
	Default oModelSH3F  := oModel:GetModel("PCPA124_SH3_F")

 	oModelSG2:SetNoUpdateLine( .F. )
	oModelSH3R:SetNoUpdateLine( .F. )
	oModelSH3R:SetNoDeleteLine( .F. )
	oModelSH3R:SetNoInsertLine( .F. )
	oModelSH3F:SetNoUpdateLine( .F. )
	oModelSH3F:SetNoDeleteLine( .F. )
	oModelSH3F:SetNoInsertLine( .F. )
Return .T.

/*/{Protheus.doc} PermAltLiP
Verifica se poderá ser alterada a linha de produção e tipo de linha, de acordo com as parametrizações.

@author lucas.franca
@since 16/01/2019
@version 1.0
@param  oModel		- Objeto do modelo de dados.
@param  cLinhaPr	- Linha de produção que será utilizada.
@param  cTpLinha	- Tipo de linha que será utilizada.
@return lRet		- .T. se for permitido alterar a linha de produto/tipo de linha.
/*/
Static Function PermAltLiP(oModel, cLinhaPr, cTpLinha, cField)
	Local lRet     := .T.
	Local lUniLin  := SuperGetMV("MV_UNILIN",.F.,.F.)
	Local nReplica := SuperGetMV("MV_PCPRLPP",.F., 2 )
	Local nIndex   := 0
	Local oMdlSG2  := oModel:GetModel("PCPA124_SG2")

	//Se estiver com o parâmetro MV_UNILIN ativado, e parametrizado para replicar as listas de operações
	//verifica se será possível utilizar a Linha de Produção / Tipo de linha.
	If lUniLin == .T. .And. nReplica == 1
		For nIndex := 1 To oMdlSG2:Length()
			If oMdlSG2:IsDeleted(nIndex)
				Loop
			EndIf
			If !Empty(oMdlSG2:GetValue("G2_LISTA",nIndex)) .And. ;
			   (oMdlSG2:GetValue("G2_LINHAPR",nIndex) != cLinhaPr .Or. oMdlSG2:GetValue("G2_TPLINHA",nIndex) != cTpLinha)
				lRet := .F.
				cTitle := RetTitle(cField)
				HELP(' ',1,"Help" ,,STR0077+AllTrim(cTitle)+STR0078,;//"O campo '" XXX "' não poderá ser alterado pois existem operações importadas de uma Lista de Operações neste roteiro."
				     2,0, , , , , ,{STR0079+AllTrim(cTitle)+STR0080+AllTrim(cTitle)+STR0081}) //"Faça a alteração do campo '"XXX"' na Lista de Operações, ou remova a Lista de Operações deste roteiro para alterar o campo '"XXX"' diretamente no cadastro do Roteiro."
				Exit
			EndIf
		Next nIndex
	EndIf

Return lRet

/*/{Protheus.doc} ExpToExel
Ajusta os arrays antes de enviar para a função de geração do arquivo MS excel
@type  Static Function
@author rafael.kleestadt
@since 02/02/2021
@version 1.0
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see https://tdn.totvs.com/x/LoJdAg
/*/
Static Function ExpToExel(oModel)
Local oModelSG2  := oModel:GetModel("PCPA124_SG2")
Local oModelSH3R := oModel:GetModel("PCPA124_SH3_R")
Local oModelSH3F := oModel:GetModel("PCPA124_SH3_F")
Local aColSG2BKP := ACLONE(oModelSG2:aCols)
Local aHeadSG2   := oModelSG2:aHeader
Local aColsSG2   := oModelSG2:aCols
Local nX         := 0

FOR nX := Len(aColsSG2) TO 1 step -1
	IF aColsSG2[nX, LEN(aColsSG2[nX])] //Linha deletada
		ADEL(aColsSG2, nX)
		ASIZE(aColsSG2, LEN(aColsSG2)-1)
	ELSE
		ASIZE(aColsSG2[nX], LEN(aHeadSG2)) 
	ENDIF 
NEXT nX

DlgToExcel({;
			{"CABECALHO",STR0001,{STR0058,STR0006},{FwFldGet("G2_CODIGO"),FwFldGet("G2_PRODUTO")}},;
			{"GETDADOS", STR0059, aHeadSG2, aColsSG2},;
			{"GETDADOS", STR0018,oModelSH3R:aHeader,oModelSH3R:aCols},;
			{"GETDADOS", STR0019,oModelSH3F:aHeader,oModelSH3F:aCols}})

oModelSG2:aCols := aColSG2BKP
	
Return NIL
