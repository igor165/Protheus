#Include "Protheus.ch"
#Include "FWMVCDEF.CH"
#Include "OMSA100.CH"
#Include "FOLDER.CH"

Static aDataMdl  := {}
Static lNewLine  := .F.
Static lRestRepom:= SuperGetMV( 'MV_VSREPOM',, '1' ) == '2.2'

Static oBrowseDA9	:= Nil
Static oBrowseDA7	:= Nil
Static oBrowseDA6	:= Nil
Static oBrowseDA5	:= Nil
Static oBrowseDUN	:= Nil
Static oBrowseDIQ	:= Nil
Static oBrowseDU2	:= Nil
Static oBrowseDTZ	:= Nil
Static oBrowseDU0	:= Nil
Static oBrowseDEK	:= Nil
Static oRelacDA9	:= Nil
Static oRelacDA7	:= Nil
Static oRelacDA6	:= Nil
Static oRelacDA5	:= Nil
Static oRelacDUN	:= Nil
Static oRelacDIQ	:= Nil
Static oRelacDU2	:= Nil
Static oRelacDTZ	:= Nil
Static oRelacDU0	:= Nil
Static oRelacDEK	:= Nil
Static oFolders		:= Nil
Static aRotAnt		:= {}

#Define STR0037 "Registro não localizado."

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OMSA100  ³ Autor ³ Henry Fila            ³ Data ³ 28.06.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Rotas                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APDL                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³  DATA    ³ BOPS ³  MOTIVO DA ALTERACAO                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Alex Egydio  ³27/01/2000³      ³ Conversao PROTHEUS  (OMSA100.PRW)    ³±±
±±³Mauro Paladini³30/09/2013³      ³ Conversao para o padrao MVC          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OMSA100()

Local oBrowse		:= Nil

//-- Variáveis para montagem dos browses
Local aCoors   := FWGetDialogSize(oMainWnd)
Local aFolders := {}
Local oFWLayerUp,oFWLayerDw,oInferior
Local oPanelUp

Private aRotina   	:= MenuDef()
Private lOMS100    	:= .T.
Private	nPosFDca   	:= 0
Private	nPosFDes   	:= 0
Private cCdrIni    	:= ''
Private cCdrFim    	:= ''

//-- Variáveis para montagem dos browses
Private oDlgPrinc
Private oBrowseUp

DbSelectArea("DA8")
DbSetOrder(1)

DEFINE MSDIALOG oDlgPrinc TITLE STR0001 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] PIXEL	//-- Cadastro de Rotas

	//-- Cria novo Layer	
	oFWLayerUp := FWLayer():New()
	oFWLayerUp:Init(oDlgPrinc,.F.,.T.)

	//-- Cria as linhas do Layer
	oFWLayerUp:AddLine("UP",50,.F.)	//-- Adiciona linha superior
	oFWLayerUp:AddLine("DOWN",50,.F.)	//-- Adiciona linha inferior

	//-- Browse superior das rotas
	oFWLayerUp:AddCollumn("ALL",100,.T.,"UP")	//-- Adiciona coluna das rotas
	oPanelUp := oFWLayerUP:GetColPanel("ALL","UP")  
	oBrowseUp:= FWmBrowse():New()
	oBrowseUp:SetOwner(oPanelUp)
	oBrowseUp:SetDescription(STR0001)
	oBrowseUp:SetAlias("DA8")
	oBrowseUp:SetMenuDef("OMSA100")
	oBrowseUp:DisableDetails() 
	oBrowseUp:SetProfileID("1") 
	oBrowseUp:ForceQuitButton()
	oBrowseUp:SetMainProc("OMSA100")

	aRotAnt := Aclone(aRotina)
	
	//-- Cria os Folders da linha inferior
	aFolders  := {STR0042,STR0043,STR0044,STR0045}	//-- "Zonas por Rota" # "Pontos por Setor" # "Setores por Zona" # "Zonas"
	
	If nModulo == 43
		Aadd(aFolders,STR0046)	//-- "Transferência"
		Aadd(aFolders,STR0047)	//-- "Percursos do MDF-e"
		Aadd(aFolders,STR0048)	//-- "Rotas por Rodovia"
		Aadd(aFolders,STR0049)	//-- "Rodovias"
		Aadd(aFolders,STR0050)	//-- "Praças de Pedágio"
		Aadd(aFolders,STR0051)	//-- "Rotas por Operadora"
	EndIf

	oInferior := oFWLayerUp:GetLinePanel("DOWN")
	oFolders  := TFolder():New(0,0,aFolders,aFolders,oInferior,,,,.T.,,oInferior:nClientWidth / 2,oInferior:nClientHeight / 2)
	oFolders:bChange := { |nFolder| CriaBrow( nFolder ), Atualiza(nFolder) }

	//-- Cria novo Layer para as pastas
	oFWLayerDw := FWLayer():New()
	oFWLayerDw:Init(oFolders:aDialogs[1],.F.,.T.)
	//-- Cria linha do Layer inferior
	oFWLayerDw:AddLine("DETALHE",100,.F.)
	//-- Cria coluna das zonas por rota
	oFWLayerDw:AddCollumn("COLZONAROT",100,.T.,"DETALHE")
	//-- Cria coluna dos pontos por setor
	oFWLayerDw:AddCollumn("COLPTOSSET",100,.T.,"DETALHE")
	//-- Cria coluna dos setores por zona
	oFWLayerDw:AddCollumn("COLSETZONA",100,.T.,"DETALHE")
	//-- Cria coluna das zonas
	oFWLayerDw:AddCollumn("COLZONASET",100,.T.,"DETALHE")

	If nModulo == 43
		//-- Cria coluna das regiões de transferência
		oFWLayerDw:AddCollumn("COLREGTRAN",100,.T.,"DETALHE")
		//-- Cria coluna dos percursos do MDF-e
		oFWLayerDw:AddCollumn("COLPERMDFE",100,.T.,"DETALHE")
		//-- Cria coluna das rotas por rodovia
		oFWLayerDw:AddCollumn("COLROTRODV",100,.T.,"DETALHE")
		//-- Cria coluna das rodovias
		oFWLayerDw:AddCollumn("COLRODOVS",100,.T.,"DETALHE")
		//-- Cria coluna das praças de pedágio
		oFWLayerDw:AddCollumn("COLPRACAS",100,.T.,"DETALHE")
		//-- Cria coluna das rotas por operadora de frota
		oFWLayerDw:AddCollumn("COLROTOPER",100,.T.,"DETALHE")
	EndIf

	//-- Browse inferior das zonas por rota
	aRotina := {}
	oBrowseDA9:= FWMBrowse():New()
	oBrowseDA9:SetOwner(oFolders:aDialogs[1])
	oBrowseDA9:SetDescription(STR0042)	//-- "Zonas por Rota"
	oBrowseDA9:SetMenuDef("")
	oBrowseDA9:DisableDetails()
	oBrowseDA9:SetAlias("DA9")
	oBrowseDA9:SetProfileID("2")
	oBrowseDA9:SetIgnoreaRotina(.T.)
	oBrowseDA9:Activate()

	//-- Realiza relacionamento das zonas com a rota
	oRelacDA9:= FWBrwRelation():New()
	oRelacDA9:AddRelation(oBrowseUp,oBrowseDA9,{{"DA9_FILIAL","xFilial('DA9')"},{"DA9_ROTEIR","DA8_COD"}})
	oRelacDA9:Activate()

	//-- Browse inferior dos pontos por setor
	aRotina := {}
	oBrowseDA7:= FWMBrowse():New()
	oBrowseDA7:SetOwner(oFolders:aDialogs[2])
	oBrowseDA7:SetDescription(STR0043)	//-- "Pontos por Setor"
	oBrowseDA7:SetMenuDef("OMSA090")
	oBrowseDA7:DisableDetails()
	oBrowseDA7:SetAlias("DA7")
	oBrowseDA7:SetProfileID("3")
	oBrowseDA7:SetMainProc("OMSA090")
	oBrowseDA7:Activate()

	//-- Realiza relacionamento dos pontos com o setor
	oRelacDA7:= FWBrwRelation():New()
	oRelacDA7:AddRelation(oBrowseDA9,oBrowseDA7,{{"DA7_FILIAL","xFilial('DA7')"},{"DA7_PERCUR","DA9_PERCUR"},{"DA7_ROTA","DA9_ROTA"}})
	oRelacDA7:Activate()

	//-- Browse inferior dos setores por zona
	aRotina := {}
	oBrowseDA6:= FWMBrowse():New()
	oBrowseDA6:SetOwner(oFolders:aDialogs[3])
	oBrowseDA6:SetDescription(STR0044)	//-- "Setores por Zona"
	oBrowseDA6:SetMenuDef("OMSA080")
	oBrowseDA6:DisableDetails()
	oBrowseDA6:SetAlias("DA6")
	oBrowseDA6:SetProfileID("4")
	oBrowseDA6:SetMainProc("OMSA080")
	oBrowseDA6:Activate()

	//-- Realiza relacionamento dos setores com a zona
	oRelacDA6:= FWBrwRelation():New()
	oRelacDA6:AddRelation(oBrowseDA7,oBrowseDA6,{{"DA6_FILIAL","xFilial('DA6')"},{"DA6_PERCUR","DA7_PERCUR"},{"DA6_ROTA","DA7_ROTA"}})
	oRelacDA6:Activate()

	//-- Browse inferior das zonas
	aRotina := {}
	oBrowseDA5:= FWMBrowse():New()
	oBrowseDA5:SetOwner(oFolders:aDialogs[4])
	oBrowseDA5:SetDescription(STR0045)	//-- "Zonas"
	oBrowseDA5:SetMenuDef("OMSA070")
	oBrowseDA5:DisableDetails()
	oBrowseDA5:SetAlias("DA5")
	oBrowseDA5:SetProfileID("5")
	oBrowseDA5:SetMainProc("OMSA070")
	oBrowseDA5:Activate()

	//-- Realiza relacionamento das zonas com os setores por zona
	oRelacDA5:= FWBrwRelation():New()
	oRelacDA5:AddRelation(oBrowseDA6,oBrowseDA5,{{"DA5_FILIAL","xFilial('DA5')"},{"DA5_COD","DA6_PERCUR"}})
	oRelacDA5:Activate()

	oBrowseUp:Activate()
    
	aRotina := Aclone(aRotAnt)
	
ACTIVATE MSDIALOG oDlgPrinc CENTER 

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ModelDef ³ Autor ³ Mauro Paladini        ³ Data ³23.08.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Modelo de dados                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oModel Objeto do Modelo                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ModelDef()

Local oModel	:= Nil
Local lMile     := IsInCallStack("CFG600LMdl") .Or. IsInCallStack("FWMILEIMPORT") .Or. IsInCallStack("FWMILEEXPORT")

// Estrutura de campos do cabecalho
Local oStruCDA8 := Nil
Local cX2Unico  := Posicione('SX2',1,'DA8','X2_UNICO')

Local oStruDA9F1:= Nil
Local oStruDUNF2:= Nil
Local oStruDI5F3:= Nil
Local oStruDEKF4:= Nil
Local oStruDIQF5:= Nil
Local oStruDJHF6:= Nil
Local oStruDJGF6:= Nil
Local oStruDDJG1:= Nil
Local oStruDIQG2:= Nil

Local bInitRote := Nil
Local bInitPerc := Nil

// Variaveis com as funcoes de validacao
Local bPreValid	:= Nil
Local bPosValid := { |oMdl| PosVldMdl(oMdl) }
Local bCommit 	:= Nil
Local bCancel	:= Nil

// Validacoes da Grid
Local bLinePost1	:= { |oMdl| PosVldDA9(oMdl,1) }
Local bLinePost2	:= { |oMdl| PosVldDUN(oMdl,2) }
Local bLinePost3	:= Nil
Local bLinePost4	:= Nil
Local bLinePost5	:= { |oMdl| PosVldDIQ(oMdl) }

Local aCpoCheck1    := {}
Local aCpoCheck2  	:= {}
Local aCpoCheck3	:= { 'DI5_CDRFRO' }
Local aCpoCheck4	:= If( DEK->(FieldPos('DEK_FROVEI')) > 0, {'DEK_CODOPE','DEK_FROVEI'}, {'DEK_CODOPE'} )
Local aCpoCheck6	:= { 'DJH_ROTA','DJH_ROTEIR' } //--, 'DDJ_CLIENT', 'DDJ_LOJA'
Local lIsTMS		:= nModulo == 43	// Verifica se modulo utilizado eh TMS
Local lUsaPerMDFe	:= AliasInDic("DIQ")
Local lTabDJH  		:= AliasIndic("DJH")
Local bMDJHPre   	:= {|oModel,nLine,cAction,cFieldID,xNewValue,xOldValue| OMA100Pre1(oModel,nLine,cAction,cFieldID,xNewValue,xOldValue) }
Local bMDJHPos		:= {|oModel,nLine| OMA100Pos2(oModel,nLine)}

oStruCDA8 := FwFormStruct( 1, "DA8" )

// Estrutura de campos do Grid - Folder 1
oStruDA9F1:= FwFormStruct( 1, "DA9" )

If lIsTMS .OR. IsInCallStack("GTPA810") //GTP
	// Estrutura de campos do Grid - Folder 2
	oStruDUNF2:= FwFormStruct( 1, "DUN" , { |cCampo|  !AllTrim( cCampo ) + "|" $ "DUN_ROTEIR|DUN_FILIAL|" } )

	// Estrutura de campos do Grid - Folder 3
	oStruDI5F3:= FwFormStruct( 1, "DI5" , { |cCampo|  !AllTrim( cCampo ) + "|" $ "DI5_ROTA|" } )

	// Estrutura de campos do Grid - Folder 4
	oStruDEKF4:= FwFormStruct( 1, "DEK" , { |cCampo|  !AllTrim( cCampo ) + "|" $ "DEK_ROTA|DEK_DESROT|" } )

	If !INCLUI
		bInitPerc := FWBuildFeature(STRUCT_FEATURE_INIPAD,"OMS100INIP()")
		oStruDEKF4:SetProperty("DEK_DESPER",MODEL_FIELD_INIT,bInitPerc)
	EndIf

	If lUsaPerMDFe
		// Estrtura de campos do field de Percurso - Folder 5
		oStruDIQF5 := FwFormStruct( 1, "DIQ")
	EndIf

	// Estrutura de campos do Grid - Folder 5
	oStruDJGF6 := FwFormStruct(1, "DJG", { |cCampo| AllTrim(cCampo) $ "DJG_DESCRI"         })
	oStruDJHF6 := FwFormStruct(1, "DJH", { |cCampo| AllTrim(cCampo) $ "DJH_ROTA|DJH_ROTEIR"})
	oStruDJHF6:AddField("DJG_DESCRI"  ,"" ,"DJG_DESCRI"  ,"C",GetSx3Cache("DJG_DESCRI","X3_TAMANHO"), 0, {|| .T.},{|| .T. } ,{},,FwBuildFeature(STRUCT_FEATURE_INIPAD,"OMA100Ini('DJH_ROTEIR')"),,,.F.)

	// Estrutura de campos do Grid - Folder 6 - Pontos do Roteiro
	oStruDDJG1:= FwFormStruct (1, "DDJ", { |cCampo| AllTrim(cCampo) + "|" $ "DDJ_SEQUEN|DDJ_CLIENT|DDJ_LOJA|DDJ_SEQEND|DDJ_NOME|DDJ_MUN|DDJ_EST|DDJ_END|DDJ_BAIRRO|"})

	// Estrutura de campos do Grid - Folder 6 - Percurso MDF-e
	oStruDIQG2:= FwFormStruct( 1, "DIQ")

	oStruDIQG2:SetProperty( 'DIQ_ROTEIR' , MODEL_FIELD_INIT ,{|| FwFldGet("DJH_ROTEIR")  })
EndIf


oModel:= MpFormMOdel():New("OMSA100",  /*bPreValid*/ , bPosValid , { |oModel| CommitMdl(oModel) } ,/*bCancel*/ )
oModel:SetDescription(STR0001) 		// "Cadastro de Rotas"

oModel:AddFields("MdFieldCDA8",Nil,oStruCDA8,/*prevalid*/,,/*bCarga*/)

If Empty(AllTrim(cX2Unico))
	oModel:SetPrimaryKey({ "DA8_FILIAL","DA8_COD" })
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ	ÄÄÄÄÄÄÄÄ¿
//³ Folder 1 - Distribuicao                  - DA9   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oModel:AddGrid("MdGridDA9F1", "MdFieldCDA8" /*cOwner*/, oStruDA9F1 , /*bLinePre*/ , bLinePost1 , /*bPre*/ , /*bPost*/, /*bLoad*/)
oModel:SetRelation( "MdGridDA9F1", { { "DA9_FILIAL", "xFilial('DA9')" }, { "DA9_ROTEIR", "DA8_COD" } }, DA9->( IndexKey( 1 ) ) )
oModel:GetModel( "MdGridDA9F1" ):SetOptional( .T. )
oModel:GetModel("MdGridDA9F1"):SetUseOldGrid()
oModel:GetModel("MdGridDA9F1"):SetMaxLine(9999)

If lIsTMS  .OR. IsInCallStack("GTPA810") //GTP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder 2 - Transferencias                - DUN   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oModel:AddGrid("MdGridDUNF2", "MdFieldCDA8" /*cOwner*/, oStruDUNF2 , /*bLinePre*/ , bLinePost2 , /*bPre*/ , /*bPost*/,/*bLoad*/)
	oModel:SetRelation( "MdGridDUNF2", { { "DUN_FILIAL", "xFilial('DUN')" }, { "DUN_ROTEIR", "DA8_COD" } }, DUN->( IndexKey( 2 ) ) )
	oModel:GetModel( "MdGridDUNF2" ):SetOptional( .T. )
	oModel:GetModel("MdGridDUNF2"):SetUseOldGrid()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder 3 - Região de Fronteira           - DI5   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oModel:AddGrid("MdGridDI5F3", "MdFieldCDA8" /*cOwner*/, oStruDI5F3 , /*bLinePre*/ , bLinePost3 , /*bPre*/ , /*bPost*/,/*bLoad*/)
	oModel:SetRelation( "MdGridDI5F3", { { "DI5_FILIAL", "xFilial('DI5')" }, { "DI5_ROTA", "DA8_COD" } }, DI5->( IndexKey( 1 ) ) )
	oModel:GetModel( "MdGridDI5F3" ):SetUniqueLine( aCpoCheck3 )
	oModel:GetModel( "MdGridDI5F3" ):SetOptional( .T. )
	oModel:GetModel("MdGridDI5F3"):SetUseOldGrid()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder 4 - Rota x Operadora de Frotas    - DEK   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oModel:AddGrid("MdGridDEKF4", "MdFieldCDA8" /*cOwner*/, oStruDEKF4 , /*bLinePre*/ , bLinePost4 , /*bPre*/ , /*bPost*/,/*bLoad*/)
	oModel:SetRelation( "MdGridDEKF4" , { { "DEK_FILIAL", "xFilial('DEK')" }, { "DEK_ROTA", "DA8_COD" } }, DEK->( IndexKey( 1 ) ) )
	oModel:GetModel( "MdGridDEKF4" ):SetUniqueLine( aCpoCheck4 )
	oModel:GetModel( "MdGridDEKF4" ):SetOptional( .T. )
	oModel:GetModel("MdGridDEKF4"):SetUseOldGrid()


	If lUsaPerMDFe

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Folder 5 - Percuros MDF-e                - DIQ   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		oModel:AddGrid("MdFieldDIQF5", "MdFieldCDA8", oStruDIQF5)
		If lTabDJH
			oModel:SetRelation( "MdFieldDIQF5" , { { "DIQ_FILIAL", "xFilial('DIQ')" }, { "DIQ_ROTA", "DA8_COD" },{ "DIQ_ROTEIR", "Space(TamSx3('DA8_COD')[1])" } }, DIQ->( IndexKey( 2 ) ) )
		Else
			oModel:SetRelation( "MdFieldDIQF5" , { { "DIQ_FILIAL", "xFilial('DIQ')" }, { "DIQ_ROTA", "DA8_COD" } }, DIQ->( IndexKey( 1 ) ) )
		EndIf
		oModel:GetModel( "MdFieldDIQF5" ):SetOptional( .T. )
		oModel:GetModel("MdFieldDIQF5"):SetUseOldGrid()

	EndIf

	If lTabDJH
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Folder 6 - Roteiros - DJH						    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oModel:addGrid("MdGridDJHF6", "MdFieldCDA8", oStruDJHF6, {|oModelGrid,nLine,cAction| PreVldDJH(oModelGrid,nLine,cAction)}, bMDJHPos/*bLinePos*/, bMDJHPre /*bPre*/, /*bPost*/, /*bLoad*/)
		oModel:SetRelation("MdGridDJHF6" , { { "DJH_FILIAL", "Fwxfilial('DJH')"}, {"DJH_ROTA", "DA8_COD"} }, DJH->( IndexKey( 1 ) ) )
		oModel:GetModel( "MdGridDJHF6" ):SetUniqueLine( aCpoCheck6 )
		oModel:GetModel( "MdGridDJHF6" ):SetOptional( .T.)
		oModel:GetModel( "MdGridDJHF6" ):SetUseOldGrid()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Folder 6/Grid1 - Roteiros - DDJ						    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oModel:addGrid("MdGridDDJG1", "MdGridDJHF6", oStruDDJG1, /*bLinePre*/, /*bLinePos*/, /*bPre*/, /*bPost*/, /*bLoad*/)
		oModel:SetRelation("MdGridDDJG1" , { { "DDJ_FILIAL", "FwxFilial('DDJ')"}, {"DDJ_ROTEIR", "DJH_ROTEIR"} }, DDJ->( IndexKey( 1 ) ) )
		oModel:GetModel( "MdGridDDJG1" ):SetOptional( .T.)
		oModel:GetModel( "MdGridDDJG1" ):SetUseOldGrid()

		oModel:GetModel( "MdGridDDJG1" ):SetOnlyQuery( .T. )
		oModel:GetModel( "MdGridDDJG1" ):SetNoInsertLine( .T. )
		oModel:GetModel( "MdGridDDJG1" ):SetNoUpdateLine( .T. )
		oModel:GetModel( "MdGridDDJG1" ):SetNoDeleteLine( .T. )

		If lUsaPerMDFe
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder 6/Grid2 - Percurso MDF-e - DIQ					    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oModel:addGrid("MdGridDIQG2", "MdGridDJHF6", oStruDIQG2, /*bLinePre*/, /*bLinePos*/, /*bPre*/, /*bPost*/, /*bLoad*/)
			oModel:SetRelation("MdGridDIQG2" , { { "DIQ_FILIAL", "FwxFilial('DIQ')"}, {"DIQ_ROTA", "DJH_ROTA"},{"DIQ_ROTA", "DA8_COD"},{"DIQ_ROTEIR", "DJH_ROTEIR"} }, DIQ->( IndexKey( 2 ) ) )
			oModel:GetModel( "MdGridDIQG2" ):SetOptional( .T.)
			oModel:GetModel( "MdGridDIQG2" ):SetUseOldGrid()
		EndIf
	EndIf
EndIf

If !lMile
	oModel:SetVldActivate( { |oModel| Oms100Vld() } )
Endif

Return ( oModel )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ViewDef  ³ Autor ³ Mauro Paladini        ³ Data ³23.08.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe browse de acordo com a estrutura                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oView do objeto oView                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ViewDef()

Local oModel 	:= FwLoadModel("OMSA100")
Local oView 	:= Nil
Local aOpc		:= { MODEL_OPERATION_VIEW,MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE,MODEL_OPERATION_DELETE }
Local nI        	:= 0
Local lTMSInter	:= FindFunction("ALIASINDIC") .And. AliasInDic("DI0")

Local oStruCDA8 := Nil
Local oStruDA9F1:= Nil
Local oStruDUNF2:= Nil
Local oStruDI5F3:= Nil
Local oStruDEKF4:= Nil
Local oStruDIQF5:= Nil
Local oStruDJHF6:= Nil
Local oStruDDJG1:= Nil
Local oStruDIQG2:= Nil

Local lIsTMS		:= nModulo == 43	// Verifica se modulo utilizado eh TMS
Local lUsaPerMDFe	:= AliasInDic("DIQ")
Local lTabDJH  	:= AliasIndic("DJH")
Local lOMS100BUT  := ExistBlock("OMS100BUT")

// Estrutura de campos do cabecalho
oStruCDA8 := FwFormStruct( 2, "DA8" )
// Estrutura de campos do Grid - Folder 1
oStruDA9F1:= FwFormStruct( 2, "DA9" )

If lIsTMS
	// Estrutura de campos do Grid - Folder 2
	oStruDUNF2:= FwFormStruct( 2, "DUN" , { |cCampo|  !AllTrim( cCampo ) + "|" $ "DUN_FILIAL|DUN_ROTEIR|" })
	// Estrutura de campos do Grid - Folder 3
	oStruDI5F3:= FwFormStruct( 2, "DI5" , { |cCampo|  !AllTrim( cCampo ) + "|" $ "DI5_FILIAL|DI5_ROTA|" } )
	// Estrutura de campos do Grid - Folder 4
	oStruDEKF4:= FwFormStruct( 2, "DEK" , { |cCampo|  !AllTrim( cCampo ) + "|" $ "DEK_ROTA|DEK_DESROT|" })

	If lUsaPerMDFe
		// Estrtura de campos do field de Percurso - Folder 5
		oStruDIQF5 := FwFormStruct( 2, "DIQ", { |cCampo|  !AllTrim( cCampo ) + "|" $ "DIQ_FILIAL|DIQ_ROTA|DIQ_ROTEIR|" })
	EndIf

	If lTabDJH
		oStruDJGF6 := FwFormStruct(2, "DJG", { |cCampo| AllTrim(cCampo) $ "DJG_DESCRI"})
		oStruDJHF6 := FwFormStruct(2, "DJH", { |cCampo| AllTrim(cCampo) $ "DJH_ROTEIR"})
		Aadd(oStruDJHF6:aFields,oStruDJGF6:aFields[1])
		oStruDJHF6:SetProperty( "DJG_DESCRI" , MVC_VIEW_ORDEM, "99") //-- ORDEM_CAMPO

		oStruDDJG1 := FwFormStruct (2, "DDJ", { |cCampo| AllTrim(cCampo) + "|" $ "DDJ_SEQUEN|DDJ_CLIENT|DDJ_LOJA|DDJ_SEQEND|DDJ_NOME|DDJ_MUN|DDJ_EST|DDJ_END|DDJ_BAIRRO|"})

		oStruDIQG2 := FwFormStruct( 2, "DIQ", { |cCampo|  !AllTrim( cCampo ) + "|" $ "DIQ_FILIAL|DIQ_ROTA|DIQ_ROTEIR|" })
	EndIf
EndIf

oView := FwFormView():New()
oView:SetModel(oModel)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes de acoes relacionadas         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Adiciona os botoes
For nI := 1 To Len(aOpc)

	// Adiciona os botoes de usuario
	If lOMS100BUT
		If ValType( aUsrButtons := ExecBlock( "OMS100BUT" , .F.,.F., { aOpc[nI] } ) ) == "A"
			AEval( aUsrButtons, { |x| oView:AddUserButton( x[3], x[1], x[2] ,NIL,NIL, {aOpc[nI]}) } )
		EndIf
	Endif

Next nI

If lIsTMS .AND. lTabDJH
	oView:CreateHorizontalBox("SUPERIOR",20)
	oView:CreateHorizontalBox("INFERIOR",80)
	oView:SetContinuousForm()
Else
	oView:CreateHorizontalBox("SUPERIOR",34)
	oView:CreateHorizontalBox("MEIO",3)
	oView:CreateHorizontalBox("INFERIOR",63)
EndIf

oView:CreateFolder('FOLDER_01',"INFERIOR")

oView:AddSheet('FOLDER_01','ABA_01', "&Distribuicao" 					, Nil )
If lIsTMS
	oView:AddSheet('FOLDER_01','ABA_02', "&Transferencia" 					, Nil )
	oView:AddSheet('FOLDER_01','ABA_03', "&Região de Fronteira" 			, Nil )
	oView:AddSheet('FOLDER_01','ABA_04', "Rota x &Operadora de Frotas" 		, Nil )
	If lUsaPerMDFe
		oView:AddSheet('FOLDER_01','ABA_05', "Percursos MDF-e" 		, Nil )
	EndIf
	If lTabDJH
		oView:AddSheet('FOLDER_01','ABA_06', "Rote&iro"	, Nil)
	EndIf
EndIf

oView:SetVldFolder({|cID,nOldSheet, nSelSheet| OMA100Muda(cID,nOldSheet,nSelSheet)})

oView:CreateHorizontalBox("PANELFOLDER_01",100,,,'FOLDER_01','ABA_01')
If lIsTMS
	oView:CreateHorizontalBox("PANELFOLDER_02",100,,,'FOLDER_01','ABA_02')
	oView:CreateHorizontalBox("PANELFOLDER_03",100,,,'FOLDER_01','ABA_03')
	oView:CreateHorizontalBox("PANELFOLDER_04",100,,,'FOLDER_01','ABA_04')
	If lUsaPerMDFe
		oView:CreateHorizontalBox("PANELFOLDER_05",100,,,'FOLDER_01','ABA_05')
	EndIf
	If lTabDJH
		oView:CreateHorizontalBox("PANELFOLDER_06",33.3,,,'FOLDER_01', 'ABA_06')
		oView:CreateHorizontalBox("PANELGRID_01",33.3,,,'FOLDER_01', 'ABA_06')
		oView:CreateHorizontalBox("PANELGRID_02",33.3,,,'FOLDER_01', 'ABA_06')
	EndIf
EndIf

oView:AddField('VwFieldCDA8', oStruCDA8 	, 'MdFieldCDA8')
oView:AddGrid( 'VwGridDA9F1', oStruDA9F1 	, 'MdGridDA9F1')
If lIsTMS
	oView:AddGrid( 'VwGridDUNF2', oStruDUNF2 	, 'MdGridDUNF2')
	oView:AddGrid( 'VwGridDI5F3', oStruDI5F3 	, 'MdGridDI5F3')
	oView:AddGrid( 'VwGridDEKF4', oStruDEKF4 	, 'MdGridDEKF4')
	If lUsaPerMDFe
		oView:AddGrid( 'VwGridDIQF5', oStruDIQF5 	, 'MdFieldDIQF5')
	EndIf
	If lTabDJH
		oView:AddGrid( 'VwGridDJHF6', oStruDJHF6 , 'MdGridDJHF6')
		oView:AddGrid( 'VwGridDDJG1', oStruDDJG1 , 'MdGridDDJG1')
		oView:AddGrid( 'VwGridDIQG2', oStruDIQG2 , 'MdGridDIQG2')
	EndIf
EndIf

oView:EnableTitleView('VwFieldCDA8')

// Cabecalho
oView:SetOwnerView('VwFieldCDA8',"SUPERIOR")

// Folder 1 - Clientes
oView:SetOwnerView('VwGridDA9F1',"PANELFOLDER_01")
oView:AddIncrementField( 'VwGridDA9F1' , 'DA9_SEQUEN' )

If lIsTMS
	// Folder 2 - Codigos de Enderecamento Postal
	oView:SetOwnerView('VwGridDUNF2',"PANELFOLDER_02")
	oView:AddIncrementField( 'VwGridDUNF2' , 'DUN_SEQUEN' )

	// Folder 3 - Regiao de Fronteira
	oView:SetOwnerView('VwGridDI5F3',"PANELFOLDER_03")
	oView:AddIncrementField( 'VwGridDI5F3' , 'DI5_ITEM' )

	// Folder 4 - Rota x Operadora de Frotas
	oView:SetOwnerView('VwGridDEKF4',"PANELFOLDER_04")
	oView:AddIncrementField( 'VwGridDEKF4' , 'DEK_ITEM' )

	If lUsaPerMDFe
		// Folder 5 - Percursos MDF-e
		oView:SetOwnerView('VwGridDIQF5',"PANELFOLDER_05")
		oView:AddIncrementField( 'VwGridDIQF5' , 'DIQ_SEQUEN' )
	EndIf

	If lTabDJH
		// Folder 6 - Roteiros
		oView:EnableTitleView('VwGridDJHF6','Roteiros')
		oView:SetOwnerView('VwGridDJHF6',"PANELFOLDER_06")

		oView:EnableTitleView('VwGridDDJG1','Trechos do Roteiros')
		//--Grid dos trechos do roteiros
		oView:SetOwnerView('VwGridDDJG1',"PANELGRID_01")

		oView:SetFieldAction( 'DJH_ROTEIR'		, { |oView,cIdForm,cIdCampo,cValue| A100LdRote(oView,cIdForm,cIdCampo,cValue) } )

		oView:EnableTitleView('VwGridDIQG2','Percurso MDF-e')
		//--Grid dos trechos do roteiros
		oView:SetOwnerView('VwGridDIQG2',"PANELGRID_02")
		oView:AddIncrementField( 'VwGridDIQG2' , 'DIQ_SEQUEN' )
	EndIf
EndIf

oView:bAfterViewActivate := { |oView| Oms100Atv() }

Return(oView)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Oms100Atv³ Autor ³ Mauro Paladini        ³ Data ³ 09.10.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa acoes necessarias apos ativar o Model              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³  DATA    ³ BOPS ³  MOTIVO DA ALTERACAO                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³          ³      ³                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Oms100Atv()

	Local oModel	:= FwModelActive()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao com o Modulo de Transporte (TMS)                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nModulo == 43 .And. IntTMS() .And. !INCLUI // oModel:GetOperation <>  MODEL_OPERATION_INSERT
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica de acordo com o Servico de Transporte Informado qual Folder devera³
		//³ficar Ativo.                                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		OMA100VldFol()
	EndIf

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Mauro Paladini        ³ Data ³14.08.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ MenuDef com as rotinas do Browse                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina array com as rotina do MenuDef                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()

Private aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION "PesqBrw"         OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.OMSA100" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.OMSA100" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.OMSA100" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.OMSA100" OPERATION 5 ACCESS 0 //"Excluir"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ExistBlock("OM100MNU")
	ExecBlock("OM100MNU",.F.,.F.)
EndIf

Return ( aRotina )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Oms100Vld³ Autor ³ Mauro Paladini        ³ Data ³ 28.06.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Faz as validacoes necessarias antes de ativar o Model      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico (DISTRIBUIDORES)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³  DATA    ³ BOPS ³  MOTIVO DA ALTERACAO                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³          ³      ³                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function Oms100Vld()

	Local lRet	:= .T.

	If Altera
		If nModulo != 43 .And. DA8->(FieldPos("DA8_SERTMS")) > 0 .And. !Empty(DA8->DA8_SERTMS)
			Aviso(STR0008,STR0007,{"OK"}) //"Esta Rota foi Implantada no Modulo de Transporte ..." //"AVISO"
			Return .F.
		ElseIf nModulo == 43 .And. DA8->(FieldPos("DA8_SERTMS")) > 0 .And. Empty(DA8->DA8_SERTMS)
			Aviso(STR0008,STR0009,{"OK"}) //"AVISO"###"Esta Rota Nao foi Implantada no Modulo de Transporte ..."
			Return .F.
		EndIf
	EndIf

Return lREt
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PosVldDA9 ³ Autor ³ Mauro Paladini       ³ Data ³ 04.10.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de Linha da GetDados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAOMS / SIGATMS                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³  DATA    ³ BOPS ³  MOTIVO DA ALTERACAO                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³          ³      ³                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function PosVldDA9(oMdl,nFolAtu,lMudaPasta)

	Local lRet       	:= .T.
	Local cZona			:= ""
	Local cSetor		:= ""
	Local ny         	:= 0
	Local aHeader		:= oMdl:aHeader
	Local aCols			:= oMdl:aCols
	Local nPosZona   	:= Ascan( aHeader,{|x| Alltrim(x[2]) == "DA9_PERCUR"})
	Local nPosSetor  	:= Ascan( aHeader,{|x| Alltrim(x[2]) == "DA9_ROTA"})

	Default lMudaPasta := .F.

	If !oMdl:IsDeleted()

		//-- Se nao for mudanca de pasta, checa o preenchimento dos campos obrigatorios
		If !lMudaPasta .And. !MaCheckCols(aHeader,aCols,n)
			Return( .F. )
		EndIf

		If nFolAtu == 1 .And. nPosZona  > 0 .And. nPosSetor > 0

			cZona  := GdFieldGet("DA9_PERCUR",n)
			cSetor := GdFieldGet("DA9_ROTA",n)

			If	!Empty(cZona) .And. !Empty(cSetor)

				DbSelectArea("DA6")
				DbSetOrder(1) //DA6_FILIAL+DA6_PERCUR+DA6_ROTA
				If	!MsSeek(xFilial("DA6")+cZona+cSetor)
					Help(" ",1,"DS1001131") //Este Setor nesta Zona não existe no Cadastro de Setores por Zona.
					lRet := .F.
				EndIf
				If	lRet .And. !(nModulo == 43 .And. IntTMS())
					If	!OmsVldCal(M->DA8_CODCAL,DA6->DA6_CODCAL)
						Help(" ", 1,"OMS100CAL") //Existem calendários nas zonas e setores da rota que estão incompatíveis com o calendário selecionado.
						lRet := .F.
					EndIf
				EndIf
			EndIf

			If	lRet
				For ny := 1 to Len(aCols)
					If ny != n .And. !aCols[ny][Len(aCols[ny])]
						If aCols[ny][nPosZona]+aCols[ny][nPosSetor] == cZona+cSetor
							Help(" ",1,"DS1001141") //Zona e Setor já cadastrados nesta Rota de Entregas.
							lRet := .F.
							Exit
						EndIf
					EndIf
				Next ny
			Endif

		EndIf

	EndIf

Return( lRet )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PosVldDUN ³ Autor ³ Mauro Paladini       ³ Data ³ 04.10.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de Linha da GetDados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAOMS / SIGATMS                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³  DATA    ³ BOPS ³  MOTIVO DA ALTERACAO                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³          ³      ³                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function PosVldDUN(oMdl,nFolAtu,lMudaPasta)

	Local lRet       	:= .T.
	Local cZona			:= ""
	Local cSetor		:= ""

	Local aHeader		:= oMdl:aHeader
	Local aCols			:= oMdl:aCols
	Local nPosRedesp 	:= 0
	Local lRedesp    	:= GetMV("MV_REDESP",,.T.) //-- Controla Redespacho ? (Utilizacao Modulo de Transporte)

	Local nPosFDca 		:= ( IIF ( nModulo == 43 .and. IntTMS() , Ascan( aHeader,{|x| Alltrim(x[2]) == "DUN_FILDCA"}) , 0 ) )
	Local nPosFDes 		:= ( IIF ( nModulo == 43 .and. IntTMS() , Ascan( aHeader,{|x| Alltrim(x[2]) == "DUN_FILDES"}) , 0 ) )

	Default lMudaPasta := .F.

	If !oMdl:IsDeleted()

		//-- Se nao for mudanca de pasta, checa o preenchimento dos campos obrigatorios
		If !lMudaPasta .And. !MaCheckCols(aHeader,aCols,n)
			Return( .F. )
		EndIf

		If nFolAtu == 2

			nSeek := IIf(lRet,Ascan(aCols,{|x| !x[Len(x)] .And. x[GdFieldPos('DUN_CDRDES')] == GDFieldGet( 'DUN_CDRDES', n ) }),  0)
			If	nSeek > 0 .And. nSeek != n
				Aviso(STR0010, STR0011,{"OK"} ) //"Atencao"###"Codigo da Regiao Destino ja informado ..."
				lRet := .F.
			EndIf

			nSeek := IIf(lRet,Ascan(aCols,{|x| !x[Len(x)] .And. ( (!Empty(GdFieldGet('DUN_FILDES',n)) .And. Empty(GdFieldGet('DUN_FILDCA',n)) ) .Or.;
			                              (Empty(GdFieldGet('DUN_FILDES',n)) .And. !Empty(GdFieldGet('DUN_FILDCA',n)) ) ) }),  0)
			If	lRet .And. nSeek > 0 .And. nSeek != n
				Aviso(STR0010, STR0012,{"OK"} )  //"Se a Filial de Destino for informada, a Filial de Descarga tambem devera ser informada e vice-versa."
				lRet := .F.
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Integracao Modulo de Transporte (TMS)                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nModulo == 43 .And. IntTMS() .And. lRedesp
				nPosRedesp:= Ascan(aHeader,{|x| Alltrim(x[2]) == "DUN_REDESP"})
					If !Empty(aCols[n,nPosFDca]) .And. aCols[n,nPosFDca] <> aCols[n,nPosFDes]
					If aCols[n,nPosRedesp] == "0"
						Aviso(STR0008,STR0017,{"OK"})  //"Aviso"###"Tipo de Redespacho deve ser informado quando a filial de descarga for diferente do destino."
						lRet := .F.
					EndIf
				EndIf
			EndIf

		EndIf

	EndIf

Return( lRet )

/*/{Protheus.doc} PosVldDIQ
Validação de linha da grid DIQ referente aos Percursos do MDF-e.

@author Wanderley.ramos
@since 16/06/2014

@param oMdl, Objeto, Componente de grid referente aos Percursos do MDF-e
/*/
Function PosVldDIQ(oMdl)
Local lRet := .T.

If Empty(oMdl:GetValue('DIQ_EST'))
	Help('',1,"OBRIGAT",,RetTitle('DIQ_EST'),04,01) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse
	lRet := .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Oms100LOk³ Autor ³ Waldemiro L. Lustosa  ³ Data ³ 28.06.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡Æo de Linha da GetDados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAOMS / SIGATMS                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³  DATA    ³ BOPS ³  MOTIVO DA ALTERACAO                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Mauro Paladini³30/09/2013³      ³ Conversao para o padrao MVC          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function Oms100lOk(nFolAtu, lMudaPasta)

// Obtem o folder posicionado e o Grid atual
Local oView 	:= FwViewActive()
Local nFolder 	:= oView:GetFolderActive("FOLDER_01",2)[1]  // 1-Retorna o ID do folder, 2-Retorna o titulo do folder.
Local oModel	:= FwModelActive()
Local oModelAtu	:= Nil

Local lRet      := .T.
Local cZona		:= ""
lOCAL cSetor	:= ""
Local nCntfor   := 0
Local ny        := 0

Local nPosZona   := 0
Local nPosSetor  := 0
Local nPosRedesp := 0
Local lRedesp    := GetMV("MV_REDESP",,.T.) //-- Controla Redespacho ? (Utilizacao Modulo de Transporte)
Local lMVRotAut  := FindFunction("F11RotRote") .AND. F11RotRote(M->DA8_COD)

Default lMudaPasta := .F.



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 1 - Distribuicao                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nFolAtu == 1

	oModelAtu 	:= oModel:GetModel("MdGridDA9F1")
	aCols 		:= oModelAtu:aCols
	aHeader	:= oModelAtu:aHeader
	n			:= oModelAtu:nLine
	nPosZona   	:= Ascan(aHeader,{|x| Alltrim(x[2]) == "DA9_PERCUR"})
	nPosSetor  	:= Ascan(aHeader,{|x| Alltrim(x[2]) == "DA9_ROTA"})

	//-- Se nao for mudanca de pasta, checa o preenchimento dos campos obrigatorios
	If !lMudaPasta .And. !MaCheckCols(aHeader,aCols,n)
		If lMVRotAut
			Return( .T. )
		Else
			Return( .F. )
		EndIf
	EndIf

	If !oModelAtu:IsDeleted()

		If nPosZona  > 0 .And. nPosSetor > 0

			cZona  := GdFieldGet("DA9_PERCUR",n)
			cSetor := GdFieldGet("DA9_ROTA",n)

			If	!Empty(cZona) .And. !Empty(cSetor)
				DbSelectArea("DA6")
				DbSetOrder(1) //DA6_FILIAL+DA6_PERCUR+DA6_ROTA
				If	!MsSeek(xFilial("DA6")+cZona+cSetor)
					Help(" ",1,"DS1001131") //Este Setor nesta Zona não existe no Cadastro de Setores por Zona.
					lRet := .F.
				EndIf
				If	lRet .And. !(nModulo == 43 .And. IntTMS())
					If	!OmsVldCal(M->DA8_CODCAL,DA6->DA6_CODCAL)
						Help(" ", 1,"OMS100CAL") //Existem calendários nas zonas e setores da rota que estão incompatíveis com o calendário selecionado.
						lRet := .F.
					EndIf
				EndIf
			EndIf
			If	lRet
				For ny := 1 to Len(aCols)
					If ny != n .And. !aCols[ny][Len(aCols[ny])]
						If aCols[ny][nPosZona]+aCols[ny][nPosSetor] == cZona+cSetor
							Help(" ",1,"DS1001141") //Zona e Setor já cadastrados nesta Rota de Entregas.
							lRet := .F.
							Exit
						EndIf
					EndIf
				Next ny
			Endif

		Endif

	Endif

ElseIf nFolAtu == 2


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder 2 - Transferencias                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oModelAtu 	:= oModel:GetModel("MdGridDUNF2")
	aCols 		:= oModelAtu:aCols
	aHeader		:= oModelAtu:aHeader
	n			:= oModelAtu:nLine
	nPosFDca 	:= ( IIF ( nModulo == 43 .and. IntTMS() , Ascan( aHeader,{|x| Alltrim(x[2]) == "DUN_FILDCA"}) , 0 ) )
	nPosFDes 	:= ( IIF ( nModulo == 43 .and. IntTMS() , Ascan( aHeader,{|x| Alltrim(x[2]) == "DUN_FILDES"}) , 0 ) )

	//-- Se nao for mudanca de pasta, checa o preenchimento dos campos obrigatorios
	If !lMudaPasta .And. !MaCheckCols(aHeader,aCols,n)
		If lMVRotAut
			Return( .T. )
		Else
			Return( .F. )
		EndIf
	EndIf

	If !oModelAtu:IsDeleted()

		nSeek := IIf(lRet,Ascan(aCols,{|x| !x[Len(x)] .And. x[GdFieldPos('DUN_CDRDES')] == GDFieldGet( 'DUN_CDRDES', n ) }),  0)
		If	nSeek > 0 .And. nSeek != n
			Aviso(STR0010, STR0011,{"OK"} ) //"Atencao"###"Codigo da Regiao Destino ja informado ..."
			lRet := .F.
		EndIf

		nSeek := IIf(lRet,Ascan(aCols,{|x| !x[Len(x)] .And. ( (!Empty(GdFieldGet('DUN_FILDES',n)) .And. Empty(GdFieldGet('DUN_FILDCA',n)) ) .Or.;
		                              (Empty(GdFieldGet('DUN_FILDES',n)) .And. !Empty(GdFieldGet('DUN_FILDCA',n)) ) ) }),  0)
		If	lRet .And. nSeek > 0 .And. nSeek != n
			Aviso(STR0010, STR0012,{"OK"} )  //"Se a Filial de Destino for informada, a Filial de Descarga tambem devera ser informada e vice-versa."
			lRet := .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Integracao Modulo de Transporte (TMS)                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nModulo == 43 .And. IntTMS() .And. lRedesp

			nPosRedesp:= Ascan(aHeader,{|x| Alltrim(x[2]) == "DUN_REDESP"})
			If nPosRedesp > 0 .And. nPosFDca > 0 .And. nPosFDes > 0
				If !Empty(aCols[n,nPosFDca]) .And. aCols[n,nPosFDca] <> aCols[n,nPosFDes]
					If aCols[n,nPosRedesp] == "0"
						Aviso(STR0008,STR0017,{"OK"})  //"Aviso"###"Tipo de Redespacho deve ser informado quando a filial de descarga for diferente do destino."
						lRet := .F.
					EndIf
				EndIf
			Endif
		EndIf

	Endif

EndIf

Return( lRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PosVldMdl ³ Autor ³ Mauro Paladini        ³ Data ³10/10/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da model (compatibilizacao)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³EXPL1 - .T./.F. Logico                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³<oModel>                                                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PosVldMdl(oMdl)

Local lRet := .T.

If oMdl <> Nil

	IF oMdl:GetOperation() == MODEL_OPERATION_INSERT .Or. oMdl:GetOperation() == MODEL_OPERATION_UPDATE .Or. oMdl:GetOperation() == MODEL_OPERATION_DELETE
		lRet := OMS100TOk( oMdl , oMdl:GetOperation())
	Endif

Endif

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OMS100TOk³ Autor ³ Patricia A. Salomao   ³ Data ³ 29.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao Geral                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OMS100TOk(ExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OMSA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OMS100TOk( oModel , nOpc )

Local lRet       := .T.

// Obtem o folder posicionado e o Grid atual
Local oView 	:= FwViewActive()
Local nFolder 	:= Nil
Local oModelAtu	:= Nil
Local oModelDA8	:= Nil
Local aCols		:= {}
Local aHeader	:= {}
Local lMile     := IsInCallStack("CFG600LMdl") .Or. IsInCallStack("FWMILEIMPORT") .Or. IsInCallStack("FWMILEEXPORT")
Local oModelView := Nil
Local lValida := .F. 

If !Empty(oView)
	oModelView := oView:GetModel()
	lValida := oModelView:GetID() == oModel:GetId()
EndIf

If !lMile .And. lValida .And. !IsInCallStack("TMSAF76") .And. !IsInCallStack("TMSAF12Inc") .And. !IsInCallStack("TMSAF12Alt") .And. !IsInCallStack("GTPA810")

	nFolder := oView:GetFolderActive("FOLDER_01",2)[1]  // 1-Retorna o ID do folder, 2-Retorna o titulo do folder.

	IF nFolder == 1
		oModelAtu 	:= oModel:GetModel("MdGridDA9F1")
		aCols 		:= oModelAtu:aCols
		aHeader		:= oModelAtu:aHeader
	Elseif nFolder == 2
		oModelAtu 	:= oModel:GetModel("MdGridDUNF2")
		aCols 		:= oModelAtu:aCols
		aHeader		:= oModelAtu:aHeader
	Elseif nFolder == 3
		oModelAtu 	:= oModel:GetModel("MdGridDI5F3")
		aCols 		:= oModelAtu:aCols
		aHeader		:= oModelAtu:aHeader
	Elseif nFolder == 4
		oModelAtu 	:= oModel:GetModel("MdGridDEKF4")
		aCols 		:= oModelAtu:aCols
		aHeader		:= oModelAtu:aHeader
	Elseif nFolder == 5
		oModelAtu 	:= oModel:GetModel("MdFieldDIQF5")
		aCols 		:= oModelAtu:aCols
		aHeader		:= oModelAtu:aHeader
	Elseif nFolder == 6
		oModelAtu 	:= oModel:GetModel("MdGridDJHF6")
		aCols 		:= oModelAtu:aCols
		aHeader		:= oModelAtu:aHeader
	Endif

	lRet:= IIf(nOpc == 3 .Or. nOpc == 4, OMS100LOk(nFolder),.T.)

	//-- Analisa se todos os itens da GetDados estao deletados.
	If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
		If !nFolder == 5 .And. !nFolder == 3  .And. !nFolder == 4
			Help( ' ', 1, 'OBRIGAT2')
			lRet := .F.
		EndIf
	EndIf

Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Integracao Modulo de Transporte (TMS)                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. nModulo == 43 .And. IntTMS()

	If nOpc == 5
		DU2->(DbSetOrder(1))
		If DU2->(MsSeek(xFilial()+M->DA8_COD) )
			Aviso(STR0008,STR0013,{"OK"}) //"Aviso"###"Esta Rota e utilizada no Cadastro de Pca. Pedagio Rota"
			lRet := .F.
		EndIf

		DTQ->(DbSetOrder(4))
		If lRet .And. DTQ->(MsSeek(xFilial()+M->DA8_COD) )
			Help( ,, 'HELP',, STR0014 + DTQ->DTQ_VIAGEM,1,0)  //"Aviso"###"Esta Rota e utilizada na Viagem "
			lRet := .F.
		EndIf

	ElseIf nOpc == MODEL_OPERATION_INSERT;
			.Or. nOpc == MODEL_OPERATION_UPDATE

		oModelDA8 := oModel:GetModel('MdFieldCDA8')

		// Verifica se campos obrigatorios foram informados
		// >> A obrigatoriedade foi retirada do dicionário devido a rotina
		// >>  ser utilizada em diversos módulos
		If Empty(oModelDA8:GetValue('DA8_TIPROT'))
			Help('',1,"OBRIGAT",,RetTitle('DA8_TIPROT'),04,01) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse
			lRet := .F.
		EndIf

		If Empty(oModelDA8:GetValue('DA8_TIPTRA'))
			Help('',1,"OBRIGAT",,RetTitle('DA8_TIPTRA'),04,01) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse
			lRet := .F.
		EndIf

		If lRet .And. Empty(oModelDA8:GetValue('DA8_CDRORI'))
			Help('',1,"OBRIGAT",,RetTitle('DA8_CDRORI'),04,01) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse
			lRet := .F.
		EndIf

		If lRet .And. Empty(oModelDA8:GetValue('DA8_SERVIC'))
			Help('',1,"OBRIGAT",,RetTitle('DA8_SERVIC'),04,01) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse
			lRet := .F.
		EndIf

		If lRet .And. Empty(oModelDA8:GetValue('DA8_SERTMS'))
			Help('',1,"OBRIGAT",,RetTitle('DA8_SERTMS'),04,01) //Um ou alguns campos obrigatorios nao foram preenchidos no Browse
			lRet := .F.
		EndIf

	EndIf
EndIf

If lRet
	If ExistBlock("OM100TOK")
		lRet := ExecBlock("OM100TOK",.F.,.F.,{nOpc})
	Endif
Endif

Return( lRet )



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ D100SEQ  ³ Autor ³ Waldemiro L. Lustosa  ³ Data ³ 28.06.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nome Orig.³ DFATA112 ³                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializador Padrao 								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico (DISTRIBUIDORES)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³  DATA    ³ BOPS ³  MOTIVO DA ALTERACAO                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Mauro Paladini³30/09/2013³      ³ Conversao para o padrao MVC          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function D100SEQ()

Local nNumSeq    := 0, nx, nMaxArray, ny
Local nPosSeq    := Ascan(aHeader,{|x| Alltrim(x[2]) == "DA9_SEQUEN"})

	nMaxArray := Len(aCols)

	For ny := 1 to nMaxArray
		If !aCols[ny][Len(aCols[ny])]
			If Val(aCols[ny][nPosSeq]) > nNumSeq
				nNumSeq := Val(aCols[ny][nPosSeq])
			EndIf
		EndIf
	Next ny

Return( StrZero(nNumSeq+10,6) )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OMS100INIP  ³ Autor ³ Katia Bianchi         ³ Data ³ 11.08.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nome Orig.³ OMSA100³                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializador Padrao 								          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function OMS100INIP()

Local lFalha     := .F.
Local aRotPerc01 := {}
Local cRet	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa a Descricao do Roteiro/Percurso³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(DEK->DEK_CODOPE)
	If lRestRepom
		cRet:= TM15DesPer(DEK->DEK_ROTA, DEK->DEK_ROTEIR, DEK->DEK_CODPER)
	Else
		TMSRotPerc(.F.,DEK->DEK_CODOPE, DA8->DA8_CDRORI, @lFalha, @aRotPerc01)
		If !Empty(aRotPerc01)
			nAchou := AScan(aRotPerc01, {|x| AllTrim(x[1]) + AllTrim(x[2]) == AllTrim(DEK->DEK_ROTEIR) + AllTrim(DEK->DEK_CODPER)})
			If nAchou > 0
				cRet :=aRotPerc01[nAchou,3]
			EndIf
		EndIf
	EndIf
EndIf

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ D100ROTA ³ Autor ³ Waldemiro L. Lustosa  ³ Data ³ 28.06.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nome Orig.³ DFATA113 ³                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡Æo do Campo DA9_ROTA na GetDados                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico (DISTRIBUIDORES)                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function D100Rota()

Local aArea        := GetArea()
Local aAreaDA6     := DA6->(GetArea())
Local lRet         := .T.
Local nx           := 0
Local nPosPercurso := Ascan(aHeader,{|x| Alltrim(x[2]) == "DA9_PERCUR"})

cPercurso := aCols[n][nPosPercurso]
cRota := &(ReadVar())

DbSelectArea("DA6")
DbSetOrder(1) //DA6_FILIAL+DA6_PERCUR+DA6_ROTA
If !dbSeek(xFilial("DA6")+cPercurso+cRota)
	Help(" ",1,"DS1001131") //Este Setor nesta Zona não existe no Cadastro de Setores por Zona.
	lRet := .F.
EndIf

If lRet .And. !(nModulo == 43 .And. IntTMS())
	If !OmsVldCal(M->DA8_CODCAL,DA6->DA6_CODCAL)
		Help(" ", 1,"OMS100CAL") //Existem calendários nas zonas e setores da rota que estão incompatíveis com o calendário selecionado.
		lRet := .F.
	Endif
Endif

RestArea( aAreaDA6 )
RestArea( aArea    )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Oms100Cal ³ Autor ³ Henry Fila            ³ Data ³ 28.06.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nome Orig.³ DFATA113 ³                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida‡Æo do Campo DA8_CODCAL                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico (OMS)                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Oms100Cal()
Local aArea    := GetArea()
Local aAreaDA6 := DA6->(GetArea())
Local lRet     := .T.
Local nX       := 0
Local nPosZona := 0
Local nPosSetor:= 0

// Obtem o folder posicionado e o Grid atual
Local oView 	:= FwViewActive()
Local nFolder 	:= oView:GetFolderActive("FOLDER_01",2)[1]  // 1-Retorna o ID do folder, 2-Retorna o titulo do folder.
Local oModel	:= FwModelActive()
Local oModelAtu	:= Nil

oModelAtu 	:= oModel:GetModel("MdGridDA9F1")
aCols 		:= oModelAtu:aCols
aHeader	:= oModelAtu:aHeader
n			:= oModelAtu:nLine
nPosZona   	:= Ascan(aHeader,{|x| Alltrim(x[2]) == "DA9_PERCUR"})
nPosSetor  	:= Ascan(aHeader,{|x| Alltrim(x[2]) == "DA9_ROTA"})

For nX := 1 to Len(aCols)
	If !GdDeleted(n)
		DbSelectArea("DA6")
		DbSetOrder(1) //DA6_FILIAL+DA6_PERCUR+DA6_ROTA
		If MsSeek(xFilial("DA6")+aCols[nX][nPosZona]+aCols[nX][nPosSetor])
			If lRet .And. !(nModulo == 43 .And. IntTMS())
				If !OmsVldCal(M->DA8_CODCAL,DA6->DA6_CODCAL)
					Help(" ", 1,"OMS100CAL") //Existem calendários nas zonas e setores da rota que estão incompatíveis com o calendário selecionado.
					lRet := .F.
					Exit
				EndIf
			EndIf
		EndIf
	EndIf
Next
RestArea( aAreaDA6 )
RestArea( aArea    )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OmsA100Whe³ Autor ³ Patricia A. Salomao   ³ Data ³ 28.06.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorno do campo When                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico (TMS) campos DA8_SERTMS - DA8_TIPTRA            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OMSA100Whe()

Local cCampo 		:= ReadVar()
Local lRet			:= .T.
Local lIsTMS		:= nModulo == 43
Local nPosFDca 	:= 0
Local nPosFDes	:= 0

// Obtem o folder posicionado e o Grid atual
Local oView 		:= FwViewActive()
Local oModel		:= FwModelActive()
Local oModelAtu		:= Nil
Local oModelIDEK	:= Nil 

If lIsTMS .and. IntTMS()
	oModelAtu 	:= oModel:GetModel("MdGridDUNF2")
	aCols 		:= oModelAtu:aCols
	aHeader	    := oModelAtu:aHeader
	n			:= oModelAtu:nLine
	nPosFDca    := Ascan(aHeader,{|x| Alltrim(x[2]) == "DUN_FILDCA"})
	nPosFDes  	:= Ascan(aHeader,{|x| Alltrim(x[2]) == "DUN_FILDES"})
EndIf


IF RTrim(cCampo) == "M->DUN_REDESP"
	If lIsTMS
		lRet := Acols[n,nPosFDca] <> Acols[n,nPosFDes]
	EndIf
Else
	lRet := Empty(M->DA8_SERVIC)
Endif
If (cCampo) == "M->DEK_CODPER" .And. lIsTMS
	oModelIDEK := oModel:GetModel("MdGridDEKF4")
	If oModelIDEK:GetValue('DEK_CODOPE') == "01"
		lRet := .T.
	Else 
		lRet := .F.  
	EndIf  
EndIf 

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMA100Muda³ Autor ³Patricia A. Salomao    ³ Data ³11.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Checa a mudanca de pasta no Objeto Folder                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OMA100Muda(ExpN1,ExpN2,ExpO1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero do Folder que se deseja ir.                 ³±±
±±³			 ³ ExpN2 = Numero do Folder Atual                             ³±±
±±³			 ³ Exp01 = Dialog                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMSA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function OMA100Muda(cID,nOldSheet,nSelSheet)

// Obtem o folder posicionado e o Grid atual
Local oView 		:= FwViewActive()
Local nIndo 		:= 0
Local nEstou		:= 0
Local lRet			:=.T.
Local nFldCorreto	:= 0
Local oModel	    := FwModelActive()
Local oMdlGrdDJH    := oModel:GetModel("MdGridDJHF6")
Local oMdlGrdDA9    := oModel:GetModel("MdGridDA9F1")
Local oMdlGrdDUN    := oModel:GetModel("MdGridDUNF2")
Local oMdlGrdDIQ    := oModel:GetModel("MdFieldDIQF5")
Local nLinVDJH      := 0
Local nLinVDA9      := 0
Local nLinVDUN      := 0
Local nLinVDIQ      := 0

If oView == Nil .Or. !oView:lModify .Or. IsInCallStack("OMA100VLDFOL")
	Return
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida a linha antes de mudar o Folder                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nIndo 	:= nSelSheet
nEstou	:= nOldSheet

If nIndo == 3
	If M->DA8_SERTMS != StrZero(2,Len(DA8->DA8_SERTMS)) .And. M->DA8_TIPTRA != StrZero(4,Len(DA8->DA8_TIPTRA))
		MsgAlert("Regiões de Fronteira somente é habilitada para o transporte internacional")
		lRet := .F.
	EndIf
Endif

If lRet
	IF M->DA8_SERTMS == '2'
		nFldCorreto := 2
	Elseif M->DA8_SERTMS == '1'
		nFldCorreto := 1
	Endif

	IF nEstou > 2
		lRet := Oms100lOk(nFldCorreto, .T.)
	Else
		lRet := Oms100lOk(nEstou, .T.)
	Endif
Endif

If lRet
	If nModulo == 43 .And. IntTMS()


		If  ( (M->DA8_SERTMS == '2' .And. nIndo == 1 ) .Or. (M->DA8_SERTMS <> '2'.And. nIndo == 2 ) )
			lRet := .F.
			Help("",1,"OMSA100NO")	// Pasta Invalida para o Servico de Transporte Informado ...
		ElseIf nIndo == 1 .OR.  nIndo == 2 .OR.  nIndo == 5

			nLinVDJH := LinValida(oMdlGrdDJH,1,.T.)
			If nLinVDJH == 0
				nLinVDJH := Iif (oMdlGrdDJH:IsDeleted(),0,1 )
			EndIf

			If oMdlGrdDJH:Length(.T.) > 0 .AND. (nLinVDJH > 0 .AND. Iif(nLinVDJH > 0, !Empty(oMdlGrdDJH:GetValue("DJH_ROTEIR",nLinVDJH)),.F.) )
				lRet := .F.
				Help("",1,"OMSA10012")	// Pasta invalida para rota de roteiro.
			EndIf

		ElseIf  nIndo == 6
				nLinVDA9 := LinValida(oMdlGrdDA9,1,.T.)
				nLinVDUN := LinValida(oMdlGrdDUN,1,.T.)
				nLinVDIQ := LinValida(oMdlGrdDIQ,1,.T.)

				If nLinVDA9 == 0
					nLinVDA9 := Iif (oMdlGrdDA9:IsDeleted(),0,1 )
				EndIf
				If nLinVDUN == 0
					nLinVDUN := Iif (oMdlGrdDUN:IsDeleted(),0,1 )
				EndIf
				If nLinVDIQ == 0
					nLinVDIQ := Iif (oMdlGrdDIQ:IsDeleted(),0,1 )
				EndIf

				If 	(oMdlGrdDA9:Length(.T.) > 0 .AND.  (nLinVDA9 > 0 .AND. Iif( nLinVDA9 > 0, !Empty(oMdlGrdDA9:GetValue("DA9_PERCUR",nLinVDA9)),.F.) )) .OR.;
					(oMdlGrdDUN:Length(.T.) > 0 .AND.  (nLinVDUN > 0 .AND. Iif( nLinVDUN > 0, !Empty(oMdlGrdDUN:GetValue("DUN_CDRDES",nLinVDUN)),.F.) )) .OR.;
					(oMdlGrdDIQ:Length(.T.) > 0 .AND.  (nLinVDIQ > 0 .AND. Iif( nLinVDIQ > 0, !Empty(oMdlGrdDIQ:GetValue("DIQ_EST"   ,nLinVDIQ)),.F.) ))
					Help("",1,"OMSA10013")	//Pasta invalida para a pasta atual preenchida.
					lRet := .F.

				EndIf
		EndIf
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMA100Vld ³ Autor ³Patricia A. Salomao    ³ Data ³16.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao dos Campos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OMA100Vld()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMSA100                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³  DATA    ³ BOPS ³  MOTIVO DA ALTERACAO                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Mauro Paladini³30/09/2013³      ³ Conversao para o padrao MVC          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function OMA100Vld()

Local lRet       := .T.
Local lFalha     := .F.
Local aRotPerc01 := {}
Local cCampo     := ReadVar()
Local nAchou     := 0
Local nPosFroVei := ''
Local nPosCodOpe := ''
Local nPosNome	 := 0
Local nPosDesp	 := 0
Local lRepom     := SuperGetMV( 'MV_VSREPOM',, '0' ) <> '0' //-- Comunicacao com Operadora de Frota
Local lTmsopdg   := SuperGetMV( 'MV_TMSOPDG',, '0' ) <> '0' //-- Comunicacao com Operadora de Frota
Local lIsTMS	 := nModulo == 43
Local oModel   	 := FWModelActive()
Local lAchou     := .F.
Local lPagBem	 := FindFunction("TMSIntgPB") .AND. DA3->(FieldPos("DA3_CODMUN")) > 0

Local oModelIDEK := Nil
Local oModelIDUN := Nil
Local oModelIDI5 := Nil
Local oObj, aRetOpe,cMsgError //-- Pagbem: só atribui valor se for desta operadora

If lIsTMS
	oModelIDEK := oModel:GetModel("MdGridDEKF4")
	oModelIDUN := oModel:GetModel("MdGridDUNF2")
	oModelIDI5 := oModel:GetModel("MdGridDI5F3")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integracao com o Modulo de Transporte (TMS) : Verifica de acordo com o    ³
//³ Servico de Transporte Informado, qual Folder devera ficar Ativo           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cCampo == 'M->DA8_SERVIC'

	// Verificar metodo disponivel para controlar os folders
	lRet := OMA100VldFol(&(ReadVar()))

	If lRet .And. !Empty(M->DA8_SERVIC)
		DC5->(DbSetOrder(1))
		If DC5->( !MsSeek( xFilial('DC5')+M->DA8_SERVIC ) )
			Help('',1,'REGNOIS')
			lRet := .F.
		ElseIf DC5->DC5_CATSER == StrZero( 1, Len( DC5->DC5_CATSER ) ) //-- Negociacao
			Help('',1,'DLA70NOSER') //-- Servico invalido, informe um servico operacional
			lRet := .F.
		EndIf
	EndIf
ElseIf cCampo == 'M->DUN_CDRDCA'

	cFilDes := Posicione('DUY',1,xFilial('DUY')+M->DUN_CDRDCA,'DUY_FILDES')
	If Empty(cFilDes)
		Help('',1,'OMS100NREG') // Nao Existe Filial de Destino cadastrada para esta Regiao de Descarga ...
		lRet := .F.
	EndIf

ElseIf cCampo == 'M->DUN_FILDES'

	If Empty(M->DUN_FILDES)
		Help('',1,'OMSA10001')	//-- Filial deve pertencer ao grupo de regioes ou ao cadastro de filial alianca
		lRet := .F.
	EndIf
	If	lRet
		cCdrIni := GdFieldGet('DUN_CDRDES',n)
		cCdrFim := cCdrIni
		//-- A filial deve ser padrao ou alianca
		DUY->(DbSetOrder(5))
		If	DUY->( ! MsSeek(xFilial('DUY')+M->DUN_FILDES) )
			DVK->(DbSetOrder(1))
			If	DVK->( ! MsSeek(xFilial('DVK')+cCdrIni+M->DUN_FILDES) )
				Help('',1,'OMSA10001')		//-- Filial deve pertencer ao grupo de regioes ou ao cadastro de filial alianca
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If	lRet
		DUN->(DbSetOrder(3))
		DUN->(MsSeek(xFilial('DUN')+cCdrIni))
	EndIf

ElseIf cCampo == 'M->DUN_FILDCA'

	If Empty(M->DUN_FILDCA)
		Help('',1,'OMSA10001')	//-- Filial deve pertencer ao grupo de regioes ou ao cadastro de filial alianca
		lRet := .F.
	EndIf
	If	lRet
		cCdrIni := oModelIDUN:GetValue('DUN_CDRDCA')
		cCdrFim := cCdrIni
		//-- A filial deve ser padrao ou alianca
		DUY->(DbSetOrder(5))
		If	DUY->( ! MsSeek(xFilial('DUY')+M->DUN_FILDCA) )
			DVK->(DbSetOrder(1))
			If	DVK->( ! MsSeek(xFilial('DVK')+cCdrIni+M->DUN_FILDCA) )
				Help('',1,'OMSA10001')	//-- Filial deve pertencer ao grupo de regioes ou ao cadastro de filial alianca
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If	lRet
		DUN->(DbSetOrder(4))
		DUN->(MsSeek(xFilial('DUN')+cCdrIni))
	EndIf

ElseIf cCampo == 'M->DEK_CODOPE'

	nPosNome 	:= Ascan( oModelIDEK:aHeader,{|x| Alltrim(x[2]) == 'DEK_NOMOPE' })

	If M->DEK_CODOPE <> '02'      //Gilson - Projeto Pamcard

		lRet := TMSValField('M->DEK_CODOPE',.T.,'DEK_NOMOPE')
		If lRet
			DEG->(DbSetOrder(1))
			If DEG->(MsSeek(xFilial('DEG')+M->DEK_CODOPE))
				If nPosNome > 0
					oModelIDEK:SetValue( 'DEK_NOMOPE'  , PadR(TMSValField('M->DEK_CODOPE',.F.,'DEK_NOMOPE'),TamSX3("DEK_NOMOPE")[1]) )
				EndIf
			Else
				Help('',1,'OMSA10002') //-"O cadastro desta Operadora não foi realizado!"
				lRet := .F.
			EndIf
		EndIf

	Else
   		Help('',1,'TMSAE6007') //-"Opção não disponível para","essa operadora."
		lRet := .F.
	EndIf

ElseIf cCampo == 'M->DEK_ROTEIR' 
	cMsgError := ""
	If oModelIDEK:GetValue('DEK_CODOPE') == "01" //-- Repom
		If !lRestRepom
			TMSRotPerc(.F., oModelIDEK:GetValue('DEK_CODOPE') , If(FunName() == 'OMSA100', M->DA8_CDRORI, DA8->DA8_CDRORI), @lFalha, @aRotPerc01)

			If !Empty(aRotPerc01)
				nAchou := AScan(aRotPerc01, {|x| AllTrim( x[1] ) == AllTrim( M->DEK_ROTEIR )})
				lAchou := nAchou > 0
			Else
				lFalha := .T.
			EndIf
		Else  //lRestRepom
			lAchou:= TM15RotPer(M->DEK_ROTEIR,oModelIDEK:GetValue('DEK_CODPER'),@lFalha)
		EndIf
	ElseIf oModelIDEK:GetValue('DEK_CODOPE') == "03" .And. lPagBem //-- PagBem
		If !Empty(M->DEK_ROTEIR)
			oObj := TMSBCAPagBem():New()
			oObj:Auth()
			aRetOpe := oObj:GetRoute( @aRotPerc01, M->DEK_ROTEIR ) 
			FwFreeObj( oObj )
			lFalha    := !aRetOpe[1]
			cMsgError := aRetOpe[2]
			lAchou    := Len(aRotPerc01) == 1
			lRet      := !lFalha .And. lAchou
		Else
			lAchou := .F.
		EndIf
	EndIf
	If lFalha
		Help('',1,'OMSA10004') //-- "Problemas na Comunicação com a Operadora impedem a Validação do Campo!"
	ElseIf !lAchou
		Help('',1,'OMSA10003') //--"Roteiro Invalido!"
		lRet := .F.
	EndIf

ElseIf cCampo == 'M->DEK_CODPER' .And. lRepom .And. lTmsopdg

	If oModelIDEK:GetValue('DEK_CODOPE') == "01"
		nPosDesp 	:= Ascan( oModelIDEK:aHeader,{|x| Alltrim(x[2]) == 'DEK_DESPER' })

		If !lRestRepom
			TMSRotPerc(.F., oModelIDEK:GetValue('DEK_CODOPE'), If(FunName() == 'OMSA100', M->DA8_CDRORI, DA8->DA8_CDRORI), @lFalha, @aRotPerc01)

			If !Empty(aRotPerc01) .And. !Empty( oModelIDEK:GetValue('DEK_ROTEIR') )

				nAchou := AScan(aRotPerc01, {|x| AllTrim(x[1]) + AllTrim(x[2]) == AllTrim( oModelIDEK:GetValue('DEK_ROTEIR') ) + AllTrim(M->DEK_CODPER)})
				If nAchou > 0
					If nPosDesp > 0
						oModelIDEK:SetValue( 'DEK_DESPER'  , PadR(aRotPerc01[nAchou,3], TamSx3("DEK_DESPER")[1]) )
					EndIf
				Else
					lAchou:= .F.			
				EndIf
			Else
				If Empty( oModelIDEK:GetValue('DEK_ROTEIR') )
					Help('',1,'OMSA10003') //--"Informe um Roteiro válido!"
				Else
					lFalha := .T.
				EndIf
			EndIf

		Else  //lRestRepom

			cDesc:= TM15DesPer(oModelIDEK:GetValue('DEK_ROTEIR'),M->DEK_CODPER)	
			If !Empty(cDesc)
				oModelIDEK:SetValue( 'DEK_DESPER'  , PadR(cDesc, TamSx3("DEK_DESPER")[1]) )  
				lAchou:= .T.
			EndIf

			If Empty( oModelIDEK:GetValue('DEK_ROTEIR') )
				Help('',1,'OMSA10003') //--"Informe um Roteiro válido!"
			EndIf
		EndIf
		
		If lFalha
			Help('',1,'OMSA10004') //-- "Problemas na Comunicação com a Operadora impedem a Validação do Campo!"
		ElseIf !lAchou
			Help('',1,'OMSA10005') //--"Roteiro Invalido!"
			lRet := .F.
		EndIf
	EndIf

ElseIf cCampo == 'M->DEK_FROVEI'

	nPosCodOpe := Ascan( oModelIDEK:aHeader,{|x| Alltrim(x[2]) == 'DEK_CODOPE' })
	nPosFroVei := Ascan( oModelIDEK:aHeader,{|x| Alltrim(x[2]) == 'DEK_FROVEI' })

	If n == 1
		If M->DEK_FROVEI <> '0'
			nAchou := AScan( aCols, {|x| !x[Len(aHeader)+1] .And. AllTrim(x[nPosCodOpe]) == oModelIDEK:GetValue('DEK_CODOPE') .And. (AllTrim(x[nPosFroVei]) == '0' .Or. AllTrim(x[nPosFroVei]) == M->DEK_FROVEI) }, 2 )
		Else
			nAchou := AScan( aCols, {|x| !x[Len(aHeader)+1] .And. AllTrim(x[nPosCodOpe]) == oModelIDEK:GetValue('DEK_CODOPE') .And. (AllTrim(x[nPosFroVei]) <> '0' .Or. AllTrim(x[nPosFroVei]) == M->DEK_FROVEI) }, 2 )
		EndIf

	ElseIf n = Len( aCols )
		If M->DEK_FROVEI <> '0'
			nAchou := AScan( aCols, {|x| !x[Len(aHeader)+1] .And. AllTrim(x[nPosCodOpe]) == oModelIDEK:GetValue('DEK_CODOPE') .And. (AllTrim(x[nPosFroVei]) == '0' .Or. AllTrim(x[nPosFroVei]) == M->DEK_FROVEI) }, 1, Len( aCols ) - 1 )
		Else
			nAchou := AScan( aCols, {|x| !x[Len(aHeader)+1] .And. AllTrim(x[nPosCodOpe]) == oModelIDEK:GetValue('DEK_CODOPE') .And. (AllTrim(x[nPosFroVei]) <> '0' .Or. AllTrim(x[nPosFroVei]) == M->DEK_FROVEI) }, 1, Len( aCols ) - 1 )
		EndIf

	Else
		If M->DEK_FROVEI <> '0'
			nAchou := AScan( aCols, {|x| !x[Len(aHeader)+1] .And. AllTrim(x[nPosCodOpe]) == oModelIDEK:GetValue('DEK_CODOPE') .And. (AllTrim(x[nPosFroVei]) == '0' .Or. AllTrim(x[nPosFroVei]) == M->DEK_FROVEI) }, 1, n - 1 )
			If nAchou == 0
				nAchou := AScan( aCols, {|x| !x[Len(aHeader)+1] .And. AllTrim(x[nPosCodOpe]) == oModelIDEK:GetValue('DEK_CODOPE') .And. (AllTrim(x[nPosFroVei]) == '0' .Or. AllTrim(x[nPosFroVei]) == M->DEK_FROVEI) }, n + 1 )
			EndIf
		Else
			nAchou := AScan( aCols, {|x| !x[Len(aHeader)+1] .And. AllTrim(x[nPosCodOpe]) == oModelIDEK:GetValue('DEK_CODOPE') .And. (AllTrim(x[nPosFroVei]) <> '0' .Or. AllTrim(x[nPosFroVei]) == M->DEK_FROVEI) }, 1, n - 1 )
			If nAchou == 0
				nAchou := AScan( aCols, {|x| !x[Len(aHeader)+1] .And. AllTrim(x[nPosCodOpe]) == oModelIDEK:GetValue('DEK_CODOPE') .And. (AllTrim(x[nPosFroVei]) <> '0' .Or. AllTrim(x[nPosFroVei]) == M->DEK_FROVEI) }, n + 1 )
			EndIf
		EndIf
	EndIf

	If nAchou <> 0
		lRet := .F.
		Help('',1,'OMSA10010') //-- "A configuracao realizada e invalida!"
	EndIf

ElseIf cCampo == 'M->DI5_CDRFRO'

	lRet := ExistCpo("DUY",M->DI5_CDRFRO,1)
	If lRet
		oModelIDI5:SetValue(  'DI5_REGFRO' , Posicione("DUY",1,xFilial("DUY")+M->DI5_CDRFRO,"DUY_DESCRI") )
		oModelIDI5:SetValue(  'DI5_FILDCA' , DUY->DUY_FILDES)
	EndIf

ElseIf cCampo == 'M->DI5_FILDCA'

	lRet := TMSValidEmp(cEmpAnt+M->DI5_FILDCA)

EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMA100VldF³ Autor ³Patricia A. Salomao    ³ Data ³16.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica de acordo com o Servico de Transporte Informado    ³±±
±±³          ³qual Folder devera ficar Ativo:                             ³±±
±±³          ³Serv. Transporte == 2 (Transporte)    - Folder Transferencia³±±
±±³          ³Serv. Transporte <> 2 (Entrega/Coleta)- Folder Distribuicao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OMA100VldFol()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Servico de Transporte Informado                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMSA100 - Integracao com o Modulo de Transporte (TMS)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³  DATA    ³ BOPS ³  MOTIVO DA ALTERACAO                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Mauro Paladini³10/10/2013³      ³ Conversao para o padrao MVC          ³±±
±±³Mauro Paladini³13/12/2013³      ³ Ajuste para funcionamento do Mile    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function OMA100VldFol(cServic)

Local cSerTms	:= ''
Local nX		:= 0
// Obtem o folder posicionado e o Grid atual
Local oView 	:= FwViewActive()
Local nFolder 	:= Nil
Local oModel    := FWModelActive()
Local lMile     := IsInCallStack("CFG600LMdl") .Or. IsInCallStack("FWMILEIMPORT") .Or. IsInCallStack("FWMILEEXPORT")
Local lIsTMS	  := nModulo == 43
Local lTabDJH   := AliasIndic("DJH")
Local aArea	  := GetArea()
Local oModelView := Nil
Local lValida := .F. 

	If !Empty(oView)
		oModelView := oView:GetModel()
		lValida := oModelView:GetID() == oModel:GetId()  // "OMSA100"
	EndIf

	Default cServic := M->DA8_SERVIC

	cSerTMS := Posicione('DC5',1,xFilial('DC5')+cServic,'DC5_SERTMS')

    If !lMile .And. lValida .And. !IsINCallStack('TMSAF76') .And. !IsInCallStack("TMSAF12Inc") .And. !IsInCallStack("TMSAF12Alt")
		nFolder := oView:GetFolderActive("FOLDER_01",2)[1]  // 1-Retorna o ID do folder, 2-Retorna o titulo do folder.
		oModel  := FWModelActive()

		If lTabDJH .AND. FindFunction("F11RotRote") .AND. F11RotRote(M->DA8_COD)
			oView:SelectFolder("FOLDER_01",6,2)
		Else

			If cSerTMS == '2'  // Servico de Transporte

				// Deleta os Dados do aCols do Folder de Distribuicao
				If nFolder == 1

					oModelAtu	:= oModel:GetModel( "MdGridDA9F1" )
					// SelectFolder( <Nome do Folder> , <pasta desejada> , <tipo 1-view ou 2-folder manual> )
					oView:SelectFolder("FOLDER_01",2,2)

					If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE

						For nX := 1 To oModelAtu:Length()

							oModelAtu:GoLine(nX)
							If !oModelAtu:IsDeleted()
								oModelAtu:DeleteLine()
							Endif

						Next nX

						// Deixa ativo os registros do Folder que vai ser utilizado
						oModelAtu	:= oModel:GetModel( "MdGridDUNF2" )

						For nX := 1 To oModelAtu:Length()

							oModelAtu:GoLine(nX)
							If oModelAtu:IsDeleted()
								oModelAtu:UnDeleteLine()
							Endif

						Next nX

					EndIf
				EndIf



			Else  // Servico de Entrega/Coleta

				// Deleta os Dados do aCols do Folder de Transferencia
				If nFolder == 2 .And. lIsTMS

					oModelAtu	:= oModel:GetModel( "MdGridDUNF2" )

					If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE

						For nX := 1 To oModelAtu:Length()

							oModelAtu:GoLine(nX)
							If !oModelAtu:IsDeleted()
								oModelAtu:DeleteLine()
							Endif

						Next nX

						// Deixa ativo os registros do Folder que vai ser utilizado

						oModelAtu	:= oModel:GetModel( "MdGridDA9F1" )
						For nX := 1 To oModelAtu:Length()

							oModelAtu:GoLine(nX)
							If oModelAtu:IsDeleted()
								oModelAtu:UnDeleteLine()
							Endif

						Next nX

					Endif

					// SelectFolder( <Nome do Folder> , <pasta desejada> , <tipo 1-view ou 2-folder manual> )
					oView:SelectFolder("FOLDER_01",1,2)

				EndIf

			EndIf
		EndIf
		oView:Refresh()

	Endif

RestArea(aArea)
Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OMA100ARed ³ Autor ³ Eduardo de Souza    ³ Data ³ 30/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o Tipo de Redespacho para (Nao Tem) qdo filial    ³±±
±±³          ³ descarga for igual a filial destino.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OMA100ARed()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OMSA100                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OMA100ARed()

Local oModel	 := FwModelActive()
Local oModelIDUN := Nil
Local lIsTMS	 := nModulo == 43

If lIsTMS

	oModelIDUN := oModel:GetModel("MdGridDUNF2")

	If	oModelIDUN:GetValue('DUN_FILDES') == oModelIDUN:GetValue('DUN_CDRDCA')
		oModelIDUN:SetValue('MdGridDUNF2','DUN_REDESP',StrZero(0,Len(DUN->DUN_REDESP) ))
	EndIf

EndIf

Return( .T. )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS100Ope ³ Autor ³Vitor Raspa            ³ Data ³ 14.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Amarracao - ROTA x OPERADORES DE FROTA/VALE PEDAGIO         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OMS100Ope( nOpc )                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMSA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OMS100Ope( nOpc )
Local oDlgEsp
Local oGetDados
Local nAux
Local lOk			:= .F.

If Empty(M->DA8_CDRORI)
	Help('',1,'OMSA10006') //--'Regiao de Origem nao Informada.'
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva as variaveis utilizadas na GetDados Anterior.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SaveInter()

	n       := 1
	aHeader := aClone(aHeaderDEK)
	aCols	  := {}
	If Len(aColsDEK)  > 0
		aCols	:= aClone(aColsDEK)
		AEval( aCols, {|x| x[Len(x)] := .F. }) // Os Itens do aCols	nao poderao estar deletados
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem de uma linha em branco no aCols.              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd(aCols,Array(Len(aHeader)+1))
		For nAux := 1 to Len(aHeader)
			If Trim(aHeader[nAux][2]) <> "DEK_ALI_WT" .And. Trim(aHeader[nAux][2]) <> "DEK_REC_WT"
				aCols[1][nAux] := CriaVar(aHeader[nAux][2])
				aCols[1][Len(aHeader)+1] := .F.
			EndIf
		Next nAux

		GDFieldPut('DEK_ITEM',StrZero(1,Len(DEK->DEK_ITEM)),1)
	EndIf

	DEFINE MSDIALOG oDlgEsp FROM 94 ,104 TO 310,650 TITLE STR0020 Of oMainWnd PIXEL //"Rota X Operadora de Frotas"
	//
	@ 18,003 SAY Posicione('SX3', 2, 'DA8_COD', 'X3Titulo()') Of oDlgEsp PIXEL SIZE 80 ,9
	@ 18,020 SAY AllTrim(M->DA8_COD) + ' / ' + M->DA8_DESC Of oDlgEsp PIXEL SIZE 110,9
	@ 18,170 SAY Posicione('SX3', 2, 'DA8_CDRORI', 'X3Titulo()') Of oDlgEsp PIXEL SIZE 35,9 // Cod.Reg.Ori
	@ 18,210 SAY M->DA8_CDRORI Of oDlgEsp PIXEL SIZE 20,9
	//
	oGetDados := MSGetDados():New(30,2,105,270,nOpc,'OS100OpLOk()','AllwaysTrue()'/*TUDOK*/,'+DEK_ITEM',IIf(nOpc==3.Or.nOpc==4,.T.,Nil))
	//-- Esta Funcao corrige uma falha da GetDados ao mostrar os itens deletados
	TMSA011AjuMin(aColsDEK, aCols)
	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||IIF(oGetDados:TudoOk(),(lOk:=.T.,oDlgEsp:End()),(lOk:=.F.))},{||oDlgEsp:End()} ) CENTERED

	If lOk
		aColsDEK := aClone(aCols)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura as Variaveis da GetDados Anterior                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestInter()
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OS100OpLOk³ Autor ³Vitor Raspa            ³ Data ³ 14.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao da Linha                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OS100OpLOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMSA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OS100OpLOk()
Local lRet       := .T.
Local aCpoCheck  := If( DEK->(FieldPos('DEK_FROVEI')) > 0, {'DEK_CODOPE','DEK_FROVEI'}, {'DEK_CODOPE'} )

If !GDDeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- Analisa se ha itens duplicados na GetDados.
	lRet := GDCheckKey(aCpoCheck,4)
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS100DEK ³ Autor ³Vitor Raspa            ³ Data ³ 14.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza aHeader e aCols referente a tabela DEK - Amarracao ³±±
±±³          ³ROTA x OPERADORES DE FROTA/VALE PEDAGIO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OMS100DEK( nOpc )                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMSA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OMS100DEK( nOpc )
Local nAux
Local nPosCodOpe
Local nPosRoteir
Local nPosCodPer
Local nPosDesPer
Local nAchou
Local aNoFields := {"DEK_ROTA","DEK_DESROT"}
Local lTmsopdg  := SuperGetMV( 'MV_TMSOPDG',, '0' ) <> '0' //-- Comunicacao com Operadora de Frota


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader e aCols da Amarracao Rota x Opera-³
//³ dores de Frota.                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SaveInter()
aHeader:= {}
aCols  := {}

DbSelectArea("DEK")
cSeek  := xFilial('DEK')+DA8->DA8_COD
cWhile := "DEK_FILIAL+DEK_ROTA"
FillGetDados(nOPc,"DEK",1,cSeek,{|| &cWhile },{||.T.},aNoFields,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/)
aHeaderDEK := aClone(aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aColsDEK ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> 3 .And. lTmsopdg

	aColsDEK := aClone(aCols)
	lFalha   := .T.

	nPosCodOpe := AScan(aHeaderDEK,{|x| AllTrim(x[2]) == "DEK_CODOPE"})
	nPosRoteir := AScan(aHeaderDEK,{|x| AllTrim(x[2]) == "DEK_ROTEIR"})
	nPosCodPer := AScan(aHeaderDEK,{|x| AllTrim(x[2]) == "DEK_CODPER"})
	nPosDesPer := AScan(aHeaderDEK,{|x| AllTrim(x[2]) == "DEK_DESPER"})

	DEK->(DbSetOrder(1))
	DEK->( MsSeek(xFilial('DEK')+DA8->DA8_COD) )
	If DEK->(!Eof())
		For nAux := 1 To Len(aColsDEK)
			TMSRotPerc(.F.,aColsDEK[nAux,nPosCodOpe], DA8->DA8_CDRORI, @lFalha, @aRotPerc01)
			If !Empty(aRotPerc01)
				nAchou := AScan(aRotPerc01, {|x| AllTrim(x[1]) + AllTrim(x[2]) == AllTrim(aColsDEK[nAux,nPosRoteir]) + AllTrim(aColsDEK[nAux,nPosCodPer]) })
				If nAchou > 0
					If AScan(aHeaderDEk, {|x| AllTrim(x[2]) == "DEK_DESPER"}) > 0
						aColsDEK[nAux,nPosDesPer] := aRotPerc01[nAchou,3]
					EndIf
				EndIf
			Else
				Help('',1,'OMSA10004') //-- "Problemas na Comunicação com a Operadora impedem a Validação do Campo!"
				lFalha := .T.
			EndIf
		Next
	Else
		GDFieldPut('DEK_ITEM',StrZero(1,Len(DEK->DEK_ITEM)),1)
		aColsDEK   := {} //aClone(aCols)
	EndIf

EndIf

RestInter()

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMSA100Chk³ Autor ³ Vitor Raspa          ³ Data ³ 20.Jun.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se houve modificacao na Regiao de Origem para refa_³±±
±±³          ³o vetor de Roteiros/Percursos                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³OMSA100Chk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³OMSA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OMSA100Chk( cCdrOri )
Local lRet := .F.
Static _cCdrOri := ''

Default cCdrOri := M->DA8_CDRORI

//-- Regiao Destino
If !lRet
	If _cCdrOri <> cCdrOri
		lRet := .T.
	EndIf
EndIf
_cCdrOri := cCdrOri

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSRotPerc³ Autor ³ Vitor Raspa           ³ Data ³ 12.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta F3( DEK ) para visualizar os Roteiros/Percursos da³±±
±±³          ³ Operadora (Gerenciador de Frotas)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSRotPerc(lF3,cCodOpe)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Define a exbicao da tela da consulta padrao <F3>   ³±±
±±³          ³ ExpC1 - Codigo da Operadora                                ³±±
±±³          ³ ExpC2 - Codigo da Regiao de Origem                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMSA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSRotPerc(lF3, cCodOpe, cCdrOri,lFalha,aRotPerc01,cCdrCal)
Local cTitulo
Local nTMSItem
Local lRet			:= .T.
Local oView			:= FwViewActive()
Local oModel		:= FWModelActive()
Local oModelIDEK	:= Nil
Local aNewButton	:= {}
Local aTitulos		:= {}
Local oObj, aRetOpe,cMsgError //-- Pagbem: só atribui valor se for desta operadora
Local lPagBem 		:= FindFunction("TMSIntgPB") .AND. DA3->(FieldPos("DA3_CODMUN")) > 0

If nModulo == 43
	oModelIDEK := oModel:GetModel("MdGridDEKF4")
	Default cCodOpe	:= oModelIDEK:GetValue('DEK_CODOPE')
Else
	Default cCodOpe	:= ""
EndIf

Default lF3    		:= .T.
Default cCdrOri		:= If(FunName() == 'OMSA100', M->DA8_CDRORI, DA8->DA8_CDRORI)
Default lFalha 		:= .F.
Default aRotPerc01 	:= {}
Default cCdrCal		:= If(FunName() == 'OMSA100', M->DA8_CDRCAL, DA8->DA8_CDRCAL)

lRotPerc := OMSA100Chk(cCdrOri)

If !Empty(cCodOpe)
	If (lRotPerc .Or. lFalha) .Or. Empty(aRotPerc01)  
		If !lRestRepom
			MsgRun( STR0021 , STR0022 , {|| CursorWait(), aRotPerc01 := F3TMSRotPerc(cCodOpe,cCdrOri,aRotPerc01, @lFalha,lF3), CursorArrow()}) //"Realizando comunicação com a Operadora..." ### "Aguarde..."
		Else
			If lF3 
				MsgRun( STR0021 , STR0022 , {|| CursorWait(), aRotPerc01 := F3TMSRotPerc(cCodOpe,cCdrOri,aRotPerc01, @lFalha,lF3,@nTMSItem), CursorArrow()}) //"Realizando comunicação com a Operadora..." ### "Aguarde..."
			EndIf
		EndIf
	EndIf

	If !Empty( aRotPerc01 ) .And. !Empty(aRotPerc01[1][1]) .And. lF3
		//-- Apresenta a tela para selecao do item.
		cTitulo	:= Posicione('SX3', 2, 'DEK_ROTEIR', 'X3Titulo()')
		
		If cCodOpe == "01"
			AAdd( aNewButton, { 4, { |nAt| RepSolicRt( M->DA8_COD, If( FunName() == 'OMSA100', M->DA8_CDRORI, DA8->DA8_CDRORI ) ) } } )
		ElseIf cCodOpe == "03" .And. lPagBem 
			AAdd( aNewButton, { 4, { |nAt| PagBIncRot( M->DA8_COD, cCdrOri, cCdrCal ) } } )
		EndIf
		
		If lRestRepom .And. cCodOpe == '01'
			If Len(aRotPerc01) > 0
				nTMSItem:= TMSRGetSt('nSelItem')
			EndIf
		Else
			aTitulos := { STR0023, STR0024, PadR(STR0025,25), STR0026, STR0028, STR0027, STR0028, STR0031 }	//"Roteiro"###'Percurso'###"Descricao"###"Cidade Origem"###"UF"###"Cidade Destino"###"UF"#"Frota"
			nTMSItem	:= 	TMSF3Array( aTitulos, aRotPerc01, cTitulo, , aNewButton )
		EndIf
		

		If	nTMSItem > 0
			//-- VAR_IXB eh utilizada como retorno da consulta F3 DEJ.
			VAR_IXB 	:= PadR(aRotPerc01[ nTMSItem, 1 ], TamSX3("DEK_ROTEIR")[1])
			If Ascan( oModelIDEK:aHeader,{|x| Alltrim(x[2]) == 'DEK_CODPER' })  > 0
				oModelIDEK:LoadValue( 'DEK_CODPER'  ,  PadR(aRotPerc01[ nTMSItem, 2 ], TamSX3("DEK_CODPER")[1]) )
			EndIf

			If Ascan( oModelIDEK:aHeader,{|x| Alltrim(x[2]) == 'DEK_DESPER' }) > 0
				oModelIDEK:LoadValue( 'DEK_DESPER'  ,  PadR(aRotPerc01[ nTMSItem, 3 ], TamSX3("DEK_DESPER")[1]) )
			EndIf

			oView:Refresh()
		Else
			lRet := .F.
		EndIf
    Else
    	If lF3
			//-- Solicita Rota
			If cCodOpe == "01"
				RepSolicRt( M->DA8_COD, cCdrOri, cCdrCal )
			ElseIf cCodOpe == "03" .And. lPagBem 
				PagBIncRot( M->DA8_COD, cCdrOri, cCdrCal )
			EndIf
		EndIf
		lRet := .F.
	EndIf
Else
	Help('',1,'OMSA10007') //--"Informe o código do Operador de Frotas/Vale-Pedágio"
	lRet := .F.
	lFalha := .T. //-Houve falha na execucao do WS
EndIf


Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ F3TMSRotPerc³ Autor ³ Vitor Raspa        ³ Data ³ 12.Jun.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acessa o WebService para obter os Roteiros/Percursos da    ³±±
±±³          ³ Operadora                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array contendo o Roteiro, Percurso e Descricao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMSA100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function F3TMSRotPerc(cCodOpe, cCdrOri, aRotPerc01, lFalha, lF3, nTMSItem,cCdrCal)
Local lPagBem := FindFunction("TMSIntgPB") .AND. DA3->(FieldPos("DA3_CODMUN")) > 0

Default lFalha  := .F.
Default lF3     := .F.
Default nTMSItem:= 0
Default cCdrCal := ""

If cCodOpe == '01' .And. FindFunction("RepConsRt") //REPOM
	RepConsRt(@cCodOpe, @cCdrOri, @aRotPerc01, @lFalha, lF3, @nTMSItem)
ElseIf cCodOpe == '03'.And. lPagBem
	If Empty(cCdrCal) .And. Type("M->DA8_CDRCAL") != "U" .And. !Empty(M->DA8_CDRCAL)
		cCdrCal  := M->DA8_CDRCAL
	EndIf
	oObj := TMSBCAPagBem():New()
	oObj:Auth()
	aRetOpe := oObj:GetRoute( @aRotPerc01, /*cIdRota*/, cCdrOri, cCdrCal ) 
	lFalha    := !aRetOpe[1]
EndIf

Return( aRotPerc01 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Oms100Rec ³ Autor ³ Marco Bianchi         ³ Data ³18/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao disparada para validar cada registro da tabela      ³±±
±±³          ³ DA9/DUN e verificar se conseguiu travar DA9/DUN.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da Tabela a ser manipulada                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms100Rec(cTabela)

If cTabela == 'DA9'
	AAdd(aRecnoDA9,DA9->(Recno()))
EndIf
If cTabela == 'DUN'
	AAdd(aRecnoDUN,DUN->(Recno()))
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMARegLOk ³ Autor ³ Richard Anderson      ³ Data ³22.11.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao de digitacao de linha                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMSA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OMARegLOk()

Local lRet := .T.
//-- Nao avalia linhas deletadas.
If	!GDDeleted( n )
   If lRet := MaCheckCols(aHeader,aCols,n)
	   //-- Analisa se ha itens duplicados na GetDados.
	   lRet := GDCheckKey( { 'DI5_CDRFRO' }, 4 )
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMARegTOk ³ Autor ³ Richard Anderson      ³ Data ³22.11.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao de confirmacao para gravacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OMARegTOk()

Local lRet := .T.

//-- Analisa se os campos obrigatorios da GetDados foram informados.
If	lRet
	lRet := oGetD:ChkObrigat( n )
EndIf

//-- Analisa o linha ok.
If lRet
	lRet := OMARegLOk()
EndIf

Return( lRet )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CommitMdl ³ Autor ³ Katia Bianchi         ³ Data ³30.07.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Confirmação da Gravação dos dados                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function CommitMdl( oModel )
Local aArea		 := GetArea() // Recebe a area ativa
Local lRet		 := .T. // Recebe o Retorno
Local nCntFor2	 := 0
Local nCntFor	 := 0
Local oMdlGridDUN:= oModel:GetModel( "MdGridDUNF2" )
Local lIntTms	 := IntTMS() 

 // Salva os Dados
lRet:= FWFormCommit( oModel )

If lRet	
	If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		
		MSMM(DA8->DA8_CODPER,,, oModel:GetValue('MdFieldCDA8',"DA8_PERCUR"),1,,,"DA8","DA8_CODPER")  //Grava o campo MEMO

		If nModulo == 43 .And. lIntTms .And. M->DA8_SERTMS == '2'
			//Apaga o Cadastro de Regiões da Rota de Transferência
			DVM->(DbSetOrder(1))
			If	DVM->(MsSeek(cSeek:=xFilial('DVM') + M->DA8_COD))
				While DVM->(!Eof() .And. DVM->DVM_FILIAL + DVM->DVM_ROTEIR == cSeek)
					RecLock('DVM',.F.)
					DVM->(DbDelete())
					DVM->(MsUnLock())
					DVM->(DbSkip())
				EndDo
			EndIf

			For nCntFor := 1 To oMdlGridDUN:Length()
				oMdlGridDUN:GoLine( nCntFor )
				If !oMdlGridDUN:IsDeleted()

					//-- Obtem as regioes atendidas pela rota
					aNivInf := {}
					cCdrDes := oMdlGridDUN:GetValue( "DUN_CDRDES" )
					AAdd(aNivInf,{cCdrDes,1})
					TmsNivInf(cCdrDes,@aNivInf,1)

					For nCntFor2 := 1 To Len(aNivInf)
						RecLock('DVM',.T.)
						DVM->DVM_FILIAL := xFilial('DVM')
						DVM->DVM_ROTEIR := M->DA8_COD
						DVM->DVM_CDRDES := aNivInf[nCntFor2,1]
						MsUnLock()
					Next
				EndIf
			Next nCntFor		
		EndIf	


	ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE
		MSMM(DA8->DA8_CODPER,,, M->DA8_PERCUR,2,,,"DA8","DA8_CODPER")  //Estorna o campo MEMO		
		
		If nModulo == 43 .And. lIntTms .And. M->DA8_SERTMS == '2'
			//Apaga o Cadastro de Regiões da Rota de Transferência
			DVM->(DbSetOrder(1))
			If	DVM->(MsSeek(cSeek:=xFilial('DVM') + M->DA8_COD))
				While DVM->(!Eof() .And. DVM->DVM_FILIAL + DVM->DVM_ROTEIR == cSeek)
					RecLock('DVM',.F.)
					DVM->(DbDelete())
					DVM->(MsUnLock())
					DVM->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
EndIf

RestArea( aArea )
Return( lRet )


/*/-----------------------------------------------------------
{Protheus.doc} A100LdRote
Realiza a Reordenação do Grid de Roteiros

Uso: OMSA100

@sample
//A100LdRote(oView,cIdForm,cIdCampo,cValue)

@author Paulo Henrique Corrêa Cardoso.
@since 09/09/2016
@version 1.0
-----------------------------------------------------------/*/
Function A100LdRote(oView,cIdForm,cIdCampo,cValue)
Local aArea      := GetArea()      // Recebe a Area Atual
Local oModel     := NIL            // Recebe o modelo
Local nLine      := 0
Local aModels    := {}
Local nY         := 0
Local nX         := 0
Local oModelGrid := NIL
Local oViewObj   := NIL
Local nCntModel  := 0
Local oMdlGrdDDJ := NIL
Local oMdlGrdDIQ := NIL
Local aEst		 := {}
Local cEstOld    := ""
Local nNewLine   := 0
Local lInserted  := .F.

Default oView    := FwViewActive() // Recebe a View ativa
Default cIdForm  := ""             // Recebe o Id do formulario
Default cIdCampo := ""             // Recebe o Id do Campo
Default cValue   := ""             // Recebe o valor do campo

// Monta o objeto do ModelGrid
oModel := oView:GetModel()
oViewObj := oView:GetViewObj(cIdForm)
oModelGrid := oModel:GetModel( oViewObj[6] )
nLine := oModelGrid:GetLine()
lInserted := oModelGrid:IsInserted(nLine)

aModels   := oModelGrid:oFormModel:GetDependency("MdGridDJHF6")

cDescri := Posicione("DJG",1, FwxFilial("DJG")+cValue, "DJG_DESCRI" )

If !Empty(cDescri)
	oModelGrid:LoadValue("DJG_DESCRI", cDescri)

	For nY := 1 To Len(aModels)

		If aModels[nY][MODEL_STRUCT_ID] != "MdGridDIQG2"   .OR. lInserted
			nCntModel := 	aModels[nY][MODEL_STRUCT_MODEL]:Length()

			aModels[nY][MODEL_STRUCT_MODEL]:DeActivate()
			aModels[nY][MODEL_STRUCT_MODEL]:SetForceLoad(.T.)
			aModels[nY][MODEL_STRUCT_MODEL]:Activate()

			//-- Verifica Se Primeira Linha Está Vazia
			If aModels[nY][MODEL_STRUCT_ID] != "MdGridDIQG2" .AND. ValType(aModels[nY][MODEL_STRUCT_MODEL]:aDataModel) == "A" .And. Len(aModels[nY][MODEL_STRUCT_MODEL]:aDataModel) >= 1
				aDataMdl := aModels[nY][MODEL_STRUCT_MODEL]:aDataModel    //-- Copia Array Para Variavel Static Para Testar Se a Posição Existe No Vetor

				For nX := 1 To nCntModel
					//-- Deleta Linha Em Branco Da Grid
					aDel(aModels[nY][MODEL_STRUCT_MODEL]:aDataModel , 1 )
					// Atualiza o tamanha do array
					aSize(aModels[nY][MODEL_STRUCT_MODEL]:aDataModel , Len(aModels[nY][MODEL_STRUCT_MODEL]:aDataModel) - 1 )
				Next nX

				aDataMdl := {}
			ElseIf aModels[nY][MODEL_STRUCT_ID] == "MdGridDIQG2"
				aModels[nY][MODEL_STRUCT_MODEL]:ClearData()
			EndIf
			oView:Refresh("VwGridDDJG1") //Atualiza a tela
		EndIf
	Next nY
Else
	Help( ,, 'HELP',, STR0037,1,0) //-- ### "Registro #### não localizado."
	//oModelGrid:LoadValue(cIdCampo,Space(GetSx3Cache(cIdCampo,"X3_TAMANHO")))
Endif

oMdlGrdDDJ := oModel:GetModel('MdGridDDJG1')
oMdlGrdDIQ := oModel:GetModel('MdGridDIQG2')

If lInserted
	// Recebe os Estados
	For nY := 1 To oMdlGrdDDJ:Length()

		If !oMdlGrdDDJ:IsDeleted()
			oMdlGrdDDJ:GoLine(nY)
			cCliente := oMdlGrdDDJ:GetValue("DDJ_CLIENT")
			cLoja    := oMdlGrdDDJ:GetValue("DDJ_LOJA")
			cSeqEnd  := oMdlGrdDDJ:GetValue("DDJ_SEQEND")

			AADD(aEst,TmsSqEnd(cCliente,cLoja,cSeqEnd,"DDJ_EST"))
		EndIf
	Next  nY
	oMdlGrdDDJ:GoLine(1)

	// Recebe Grava os Pontos MDF-e
	cEstOld := ""
	For nY := 1 To Len(aEst)
		If cEstOld !=  aEst[nY]
			If nY > 1
				nNewLine := oMdlGrdDIQ:AddLine()
			Else
				nNewLine := oMdlGrdDIQ:GetLine()
			EndIf
			oMdlGrdDIQ:GoLine(nNewLine)
			oMdlGrdDIQ:LoadValue("DIQ_EST", aEst[nY])
			oMdlGrdDIQ:LoadValue("DIQ_ROTEIR", cValue)
			cEstOld :=  aEst[nY]
		EndIf
	Next  nY
	oMdlGrdDIQ:GoLine(1)
	oView:Refresh("VwGridDIQG2") //Atualiza a tela
	oView:Refresh("VwGridDJHF6") //Atualiza a tela
EndIf

//Atualiza a tela
oView:GoLine(oModelGrid:getId(),nLine)
oView:Refresh("VwGridDDJG1") //Atualiza a tela

RestArea(aArea)
Return

Function OMA100Ini(cCampo)
Local oModel  := FWModelActive() 
Local xRes	  := Nil
	
    If oModel:GetID() == "OMSA100" .And. oModel:IsActive()
        If Upper(cCampo) == "DJH_ROTEIR"
			If lNewLine .Or. INCLUI
				xRes := Space(GetSx3Cache("DJG_DESCRI","X3_TAMANHO"))
				lNewLine := .F.
			Else
				xRes := Posicione('DJG',1,xFilial('DJG')+ DJH->DJH_ROTEIR,'DJG_DESCRI')
			EndIf
        EndIf
    EndIf

Return xRes

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function OMA100Pre1(oModel,nLine,cAction,cFieldID,xNewValue,xOldValue)
 Local lRet			:= .T.
 Local oFmodel		:= FwModelActive()
 Local oView		:= FWViewActive()
 Local cRoteiro		:= oModel:GetValue("DJH_ROTEIR")
 Local nLine		:= 1
 
	 If cAction == "SETVALUE"
		If cFieldID = "DJH_ROTEIR"
			If Empty(Posicione('DJG',1,xFilial('DJG')+ xNewValue,'DJG_DESCRI'))
				lRet := .F.
			EndIf
		EndIf
	 ElseIf cAction == "CANSETVALUE" 

	 ElseIf cAction == "ADDLINE"
		lNewLine := .T.
	 ElseIf cAction == "DELETE"

	 ElseIf cAction == "UNDELETE"

	 EndIf

Return lRet

/*/{Protheus.doc} OMA100Pos2(oModel,nLine)
	(long_description)
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function OMA100Pos2(oModel,nLine)
Local lResult := .T.

	
Return lResult

/*/-----------------------------------------------------------
{Protheus.doc} PreVldDJH
Pré-valida a Linha do grid

Uso: OMSA100

@sample
//PreVldDJH(oModelGrid,nLine,cAction)

@author Paulo Henrique Corrêa Cardoso.
@since 09/09/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function PreVldDJH(oModelGrid,nLine,cAction)
Local lRet       := .T.               // Recebe o Retorno
Local aAreaDDJ   := DDJ->(GetArea())  // Recebe a Area da tebela DDJ
Local oView      := FwViewActive()    // Recebe a View Ativa
Local aAreaDJF   := DJF->(GetArea())  // Recebe a Area da DJF

oModelGrid:GoLine(nLine)

If cAction == 'DELETE' .OR. cAction == 'CANSETVALUE'
	dbSelectArea("DJF")
	DJF->(dbSetOrder(2)) // Filial + Codigo Roteiro

	If DJF->( dbSeek( FwxFilial("DJF")+ oModelGrid:GetValue("DJH_ROTA")+ oModelGrid:GetValue("DJH_ROTEIR") ) )
		Help('',1,'OMSA10011',,,3,01) // 'Roteiro no poderá ser modificado, pois já esta sendo utilizado em uma viagem'
		lRet := .F.
	EndIf

EndIf

RestArea(aAreaDJF)
RestArea(aAreaDDJ)

Return lRet

/*{Protheus.doc} Atualiza
Atualiza os browses inferiores
@type Function
@author Valdemar Roberto Mognon
@since 19/04/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
Static Function Atualiza(nFolder)

Default nFolder := 1

Do Case
	Case nFolder == 1
		oBrowseDA9:Refresh()
	Case nFolder == 2
		oBrowseDA7:Refresh()
	Case nFolder == 3
		oBrowseDA6:Refresh()
	Case nFolder == 4
		oBrowseDA5:Refresh()
	Case nFolder == 5
		oBrowseDUN:Refresh()
	Case nFolder == 6
		oBrowseDIQ:Refresh()
	Case nFolder == 7
		oBrowseDU2:Refresh()
	Case nFolder == 8
		oBrowseDTZ:Refresh()
	Case nFolder == 9
		oBrowseDU0:Refresh()
	Case nFolder == 10
		oBrowseDEK:Refresh()
EndCase

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} CriaBrow
Cria o Browse ao clicar no folder
@type Static Function
@author Rodrigo Pirolo
@since 15/06/2021
@version P12 R12.1.29
@param nFolder
@return logico
*/
//-------------------------------------------------------------------

Static Function CriaBrow( nFolder )

Local aLegBrw	:= {}
Local aColsDFV  := {}
Local nI		:= 0

Default nFolder := 1

If nModulo == 43
	Do Case
		Case nFolder == 5 .AND. Valtype(oBrowseDUN) == "U"
			//-- Browse inferior das regiões de transferência 5
			aRotina := {}
			oBrowseDUN:= FWMBrowse():New()
			oBrowseDUN:SetOwner(oFolders:aDialogs[5])
			oBrowseDUN:SetDescription(STR0046)	//-- "Transferência"
			oBrowseDUN:SetMenuDef("")
			oBrowseDUN:DisableDetails()
			oBrowseDUN:SetAlias("DUN")
			oBrowseDUN:SetProfileID("6")
			oBrowseDUN:SetIgnoreaRotina(.T.)
			oBrowseDUN:Activate()
		
			//-- Realiza relacionamento das regiões de transferência com a rota 
			oRelacDUN:= FWBrwRelation():New()
			oRelacDUN:AddRelation(oBrowseUp,oBrowseDUN,{{"DUN_FILIAL","xFilial('DUN')"},{"DUN_ROTEIR","DA8_COD"}})
			oRelacDUN:Activate()

		Case nFolder == 6 .AND. Valtype(oBrowseDIQ) == "U"
			//-- Browse inferior dos percursos do MDF-e 6
			aRotina := {}
			oBrowseDIQ:= FWMBrowse():New()
			oBrowseDIQ:SetOwner(oFolders:aDialogs[6])
			oBrowseDIQ:SetDescription(STR0047)	//-- "Percursos do MDF-e"
			oBrowseDIQ:SetMenuDef("")
			oBrowseDIQ:DisableDetails()
			oBrowseDIQ:SetAlias("DIQ")
			oBrowseDIQ:SetProfileID("7")
			oBrowseDIQ:SetIgnoreaRotina(.T.)
			oBrowseDIQ:Activate()
		
			//-- Realiza relacionamento dos percursos do MDF-3 com a rota
			oRelacDIQ:= FWBrwRelation():New()
			oRelacDIQ:AddRelation(oBrowseUp,oBrowseDIQ,{{"DIQ_FILIAL","xFilial('DIQ')"},{"DIQ_ROTA","DA8_COD"}})
			oRelacDIQ:Activate()

		Case ( nFolder == 7 .OR. nFolder == 8 .OR. nFolder == 9 ) .AND. Valtype(oBrowseDTZ) == "U"
			//-- Browse inferior das rotas por rodovia 7
			aRotina := {}
			oBrowseDU2:= FWMBrowse():New()
			oBrowseDU2:SetOwner(oFolders:aDialogs[7])
			oBrowseDU2:SetDescription(STR0048)	//-- "Rotas por Rodovia"
			oBrowseDU2:SetMenuDef("TMSA280")
			oBrowseDU2:DisableDetails()
			oBrowseDU2:SetAlias("DU2")
			oBrowseDU2:SetProfileID("8")
			oBrowseDU2:SetMainProc("TMSA280")
			oBrowseDU2:Activate()
		
			//-- Realiza relacionamento das rotas por rodovia com a rota
			oRelacDU2:= FWBrwRelation():New()
			oRelacDU2:AddRelation(oBrowseUp,oBrowseDU2,{{"DU2_FILIAL","xFilial('DU2')"},{"DU2_ROTA","DA8_COD"}})
			oRelacDU2:Activate()

			//-- Browse inferior das rodovias 8
			aRotina := {}
			oBrowseDTZ:= FWMBrowse():New()
			oBrowseDTZ:SetOwner(oFolders:aDialogs[8])
			oBrowseDTZ:SetDescription(STR0049)	//-- "Rodovias"
			oBrowseDTZ:SetMenuDef("TMSA260")
			oBrowseDTZ:DisableDetails()
			oBrowseDTZ:SetAlias("DTZ")
			oBrowseDTZ:SetProfileID("9")
			oBrowseDTZ:SetMainProc("TMSA260")
			oBrowseDTZ:Activate()
		
			//-- Realiza relacionamento das rotas por rodovia com as rotas por rodovia
			oRelacDTZ:= FWBrwRelation():New()
			oRelacDTZ:AddRelation(oBrowseDU2,oBrowseDTZ,{{"DTZ_FILIAL","xFilial('DTZ')"},{"DTZ_CODROD","DU2_CODROD"}})
			oRelacDTZ:Activate()
		
			//-- Browse inferior das praças de pedágio 9
			aRotina := {}
			oBrowseDU0:= FWMBrowse():New()
			oBrowseDU0:SetOwner(oFolders:aDialogs[9])
			oBrowseDU0:SetDescription(STR0050)	//-- "Praças de Pedágio"
			oBrowseDU0:SetMenuDef("TMSA270")
			oBrowseDU0:DisableDetails()
			oBrowseDU0:SetAlias("DU0")
			oBrowseDU0:SetProfileID("10")
			oBrowseDU0:SetMainProc("TMSA270")
			oBrowseDU0:Activate()
		
			//-- Realiza relacionamento das praças de pedágio com as rotas por rodovia
			oRelacDU0:= FWBrwRelation():New()
			oRelacDU0:AddRelation(oBrowseDU2,oBrowseDU0,{{"DU0_FILIAL","xFilial('DU0')"},{"DU0_CODROD","DU2_CODROD"},{"DU0_SEQPDG","DU2_SEQPDG"}})
			oRelacDU0:Activate()
		Case nFolder == 10 .AND. Valtype(oBrowseDEK) == "U"
			//-- Browse inferior das rotas por operadora de frota 10
			aRotina := {}
			oBrowseDEK:= FWMBrowse():New()
			oBrowseDEK:SetOwner(oFolders:aDialogs[10])
			oBrowseDEK:SetDescription(STR0051)	//-- "Rotas por Operadora de Frota"
			oBrowseDEK:SetMenuDef("")
			oBrowseDEK:DisableDetails()
			oBrowseDEK:SetAlias("DEK")
			oBrowseDEK:SetProfileID("11")
			oBrowseDEK:SetIgnoreaRotina(.T.)
			oBrowseDEK:Activate()
		
			//-- Realiza relacionamento das praças de pedágio com as rotas por rodovia
			oRelacDEK:= FWBrwRelation():New()
			oRelacDEK:AddRelation(oBrowseUp,oBrowseDEK,{{"DEK_FILIAL","xFilial('DEK')"},{"DEK_ROTA","DA8_COD"}})
			oRelacDEK:Activate()
	EndCase
EndIf

aRotina := AClone(aRotAnt)

Return .T.
