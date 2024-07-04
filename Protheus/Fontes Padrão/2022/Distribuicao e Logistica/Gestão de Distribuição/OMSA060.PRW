#INCLUDE "PROTHEUS.CH"
#INCLUDE "OMSA060.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"

#DEFINE VE_QTDCOL 2
#DEFINE VE_CODVEI 1
#DEFINE VE_RECNO  2

Static oModelAuto	:= Nil
Static lRestRepom	:= SuperGetMV( 'MV_VSREPOM',, '1' ) == '2.2'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OMSA060  ³ Autor ³ Waldemiro L. Lustosa  ³ Data ³ 17.06.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nome Orig.³ DFATA06  ³                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Veículos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico (DISTRIBUIDORES)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Revisao  ³ Cristiane Moreto - Conversao p/ Protheus ³ Data ³ 19.01.00 ³±±
±±³          ³ CISA060.                                 ³      ³          ³±±
±±³          ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Caio Murakami   - Conversao p/ MVC       ³ Data ³ 21.06.12 ³±±
±±³          ³        .                                 ³      ³          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function OMSA060(aRotAuto, nOpcAuto, aItensAuto)
Local lTMSOPdg := SuperGetMV('MV_TMSOPDG',,'0') == '2'
Local aSetKey  := {}
Local lSetKey  := .F.
Local lRastre  := AliasInDic("DAW") .And. nModulo == 43
Local oBrowse  := Nil

	If Type("Inclui") == "U"
		Inclui := .F.
	EndIf

	If Type("Altera") == "U"
		Altera := .F.
	EndIf

	If aRotAuto == NIL

		If lTMSOPdg
			aSetKey  := {{VK_F12 , {|| Pergunte("OMS060",.T.)}}}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega as perguntas selecionadas                            ³
			//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
			//³ MV_PAR01 - Atualiza dados com a Operadora?                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Pergunte('OMS060',.F.)
			lSetKey  := .T.
		EndIf

		If lSetKey
			TmsKeyOn(aSetKey)
		EndIf

		oBrowse := FWmBrowse():New()
		oBrowse:SetAlias( 'DA3' )
		oBrowse:SetMenuDef( 'OMSA060' )
		oBrowse:SetDescription( STR0001 )
		oBrowse:Activate()

		If lSetKey
			TmsKeyOff(aSetKey)
		EndIf

	Else

		If oModelAuto == Nil
			oModelAuto := FwLoadModel("OMSA060")
		EndIf

		If IsInCallStack("IntegDef")
			//-- IntegDef não considera módulo, por isso a verificação deve ser feita apenas com AliasInDic("DAW")
			lRastre := AliasInDic("DAW")
		EndIf

		If lRastre .And. aItensAuto <> NIL .And. !Empty(aItensAuto) .And. !__lPyme
			FwMvcRotAuto(oModelAuto,"DA3",nOpcAuto,{{"OMSA060_DA3",aRotAuto},{"MdGridDAW", aItensAuto}},.T.,.T.)  //Chamada da rotina automatica através do MVC
		Else
			FwMvcRotAuto(oModelAuto,"DA3",nOpcAuto,{{"OMSA060_DA3",aRotAuto}},.T.,.T.)  //Chamada da rotina automatica através do MVC
		EndIf

		aRotAuto := Nil
		aItensAuto := Nil

	EndIf

Return

//-------------------------------------
/*  MenuDef
@author     Caio Murakami
@since      09/04/2012
@return         aRotina    */
//-------------------------------------
Static Function MenuDef()
Local aRotina  := {}
Local lContVei := GetMV('MV_CONTVEI',,.T.)
Local aSubRot  := {}
Local lTMSOPdg := SuperGetMV('MV_TMSOPDG',,'0') == '2'

	aAdd( aRotina, { STR0017  , 'PesqBrw'        , 0, 1, 0, .T. } ) //-- Pesquisar
	aAdd( aRotina, { STR0018  , 'VIEWDEF.OMSA060', 0, 2, 0, NIL } ) //-- Visualizar
	aAdd( aRotina, { STR0019  , 'VIEWDEF.OMSA060', 0, 3, 0, NIL } ) //-- Incluir
	aAdd( aRotina, { STR0020  , 'VIEWDEF.OMSA060', 0, 4, 0, NIL } ) //-- Alterar
	aAdd( aRotina, { STR0021  , 'VIEWDEF.OMSA060', 0, 5, 0, NIL } ) //-- Excluir
	aAdd( aRotina, { STR0022  , 'VIEWDEF.OMSA060', 0, 8, 0, NIL } ) //-- Imprimir
	aAdd( aRotina, { STR0023  , 'VIEWDEF.OMSA060', 0, 9, 0, NIL } ) //-- Copiar

	If lTMSOPdg
		AAdd(aRotina,{STR0003, "OMS060AtOp()",0 ,6}) // 'DadosXOperad.'
	EndIf

	If nModulo == 43 .And. !lContVei
		AAdd(aRotina, { STR0010, aSubRot                          , 0, 1 } )
		/* Chamada descontinuada, após a nova versão do TMSA146 
	    AAdd(aRotina, { STR0011, "TMSA146PVe( DA3->DA3_COD, .T. , '" +STR0001+"' )", 0, 2 } )  
		*/
		AAdd( aSubRot, { STR0012, "OMS060Bloq('B')"                , 0, 1 } )
		AAdd( aSubRot, { STR0013, "OMS060Bloq('L')"                , 0, 2 } )
	EndIf

	//-- Ponto de Entrada OM060BRW - utilizado para adicionar items no Menu da mBrowse
	If ExistBlock("OM060BRW")
		aRotPE := ExecBlock("OM060BRW",.F.,.F.)
		If ValType(aRotPE) == "A"
			AEval(aRotPE,{|x| aAdd(aRotina,x)})
		EndIf
	EndIf

Return aRotina

//-------------------------------------
/*  Modelo de Dados
@author     Leandro Paulino / Jefferson Tomaz
@version    P10 R1.4
@build      7.00.101202A
@since      04/04/2011
@return         oModel Objeto do Modelo*/
//-------------------------------------
Static Function ModelDef()
Local oModel     := Nil
Local oStrMdlDA3 := Nil
Local oStrMdlDAW := Nil
Local oStrMdlCmp := Nil
Local oStrMdlDJ8 := Nil
Local oStrMdlDMG := Nil
Local lIntGFE    := SuperGetMv('MV_INTGFE',,.F.)
Local lRastre    := AliasInDic("DAW") .And. nModulo == 43
Local cTMSRre    := SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza
Local lDCLNew    := SuperGetMv('MV_DCLNEW',,.F.) .And. AliasInDic("DHF")
Local lTemplate  := FindFunction("TCCheck") .And. TCCheck('DCL') .And. AliasInDic("LBT")
Local lTabDMG    := AliasInDic("DMG") .And. nModulo == 43

	oStrMdlDA3 := FwFormStruct(1,"DA3")
	oStrMdlDAW := FwFormStruct(1,"DAW")
	oStrMdlDJ8 := FwFormStruct(1,"DJ8")
	If lTabDMG
		oStrMdlDMG := FwFormStruct(1,"DMG")
	EndIf

	If lDCLNew
		oStrMdlCmp := FwFormStruct(1,"DHF",{|cCampo| AllTrim(cCampo)+"|" $"DHF_NROCOM|DHF_CAPAC|DHF_NROLAC|"})
	ElseIf lTemplate
		oStrMdlCmp := FwFormStruct(1,"LBT",{|cCampo| AllTrim(cCampo)+"|" $"LBT_NROCOM|LBT_CAPAC|LBT_NROLAC|"})
	EndIf

	If lIntGFE

		oStrMdlDA3:AddField( ;                      // Ord. Tipo Desc.
			"CGC Propri"                     , ;      // [01]  C   Titulo do campo
			"CGC Propri"                     , ;      // [02]  C   ToolTip do campo
			"DA3_CGCFOR"                     , ;      // [03]  C   Id do Field
			'C'                              , ;      // [04]  C   Tipo do campo
			14                               , ;      // [05]  N   Tamanho do campo
			0                                , ;      // [06]  N   Decimal do campo
			NIL                              , ;      // [07]  B   Code-block de validação do campo
			NIL                              , ;      // [08]  B   Code-block de validação When do campo
			NIL                              , ;      // [09]  A   Lista de valores permitido do campo
			NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
			FwBuildFeature( STRUCT_FEATURE_INIPAD,'IF(!Inclui,Posicione("SA2",1,xFilial("SA2")+DA3->DA3_CODFOR+DA3->DA3_LOJFOR,"A2_CGC"),"")' ), ;      // [11]  B   Code-block de inicializacao do campo
			NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
			NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
			.T.                              )        // [14]  L   Indica se o campo é virtual

		oStrMdlDA3:AddTrigger( ;
			"DA3_LOJFOR", ;                                                    // [01] Id do campo de origem
			"DA3_CGCFOR" , ;                                                   // [02] Id do campo de destino
			{|| .T. }   , ;                                                    // [03] Bloco de codigo de validação da execução do gatilho
			&( ' { | oModel | Posicione("SA2",1,xFilial("SA2")+M->DA3_CODFOR+M->DA3_LOJFOR,"A2_CGC") } ' ) )   // [04] Bloco de codigo de execução do gatilho
	EndIf

	oModel:= MpFormModel():New("OMSA060",/*bPreValid*/,{|oModel| PosVldMdl(oModel) },{|oModel|CommitMdL(oModel)},/*Cancel*/)
	oModel:AddFields("OMSA060_DA3",Nil,oStrMdlDA3,/**/,/*bPosValid*/,/*Carga*/)

	If lRastre .And. !__lPyme
		oModel:AddGrid('MdGridDAW','OMSA060_DA3', oStrMdlDAW,,{|oModel|PosVldDAW(oModel)},/*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
		oModel:SetRelation('MdGridDAW',{ {'DAW_FILIAL','xFilial("DAW")'},{'DAW_CODVEI','DA3_COD'} }, DAW->( IndexKey(1) ) )
		oModel:GetModel( 'MdGridDAW' ):SetOptional(.T.) //-- Permite grid sem dados
		oModel:GetModel( 'MdGridDAW' ):SetDescription(STR0024) //-- "Rastreadores"
	EndIf

	If lDCLNew
		oModel:AddGrid("MdGridCmp","OMSA060_DA3", oStrMdlCmp,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
		oModel:SetRelation("MdGridCmp",{ {"DHF_FILIAL","xFilial('DHF')"},{"DHF_CODVEI","DA3_COD"} }, DHF->( IndexKey(1) ) )
		oModel:GetModel( "MdGridCmp" ):SetOptional(.T.) //-- Permite grid sem dados
		oModel:GetModel( "MdGridCmp" ):SetDescription(STR0042) //-- Compartimentos
	ElseIf lTemplate
		oModel:AddGrid("MdGridCmp","OMSA060_DA3", oStrMdlCmp,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
		oModel:SetRelation("MdGridCmp",{ {"LBT_FILIAL","xFilial('LBT')"},{"LBT_CODVEI","DA3_COD"} }, LBT->( IndexKey(1) ) )
		oModel:GetModel( "MdGridCmp" ):SetOptional(.T.) //-- Permite grid sem dados
		oModel:GetModel( "MdGridCmp" ):SetDescription(STR0042) //-- Compartimentos
	EndIf

	If !Empty(cTMSRre) .And. cTMSRre <> "0"
		oModel:AddGrid('MdGridDJ8',"OMSA060_DA3", oStrMdlDJ8,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/, /*bPosVal*/, /*BLoad*/  )
		oModel:SetRelation('MdGridDJ8',{ {'DJ8_FILIAL','xFilial("DJ8")'},{'DJ8_CODVEI','DA3_COD'} }, DJ8->( IndexKey(1) ) )
		oModel:GetModel( "MdGridDJ8" ):SetOptional(.T.) //-- Permite grid sem dados
		oModel:GetModel( 'MdGridDJ8' ):SetDescription(STR0037) //-- "Veiculos x Caracteristicas"
		oModel:GetModel( 'MdGridDJ8' ):SetUniqueLine( {"DJ8_CODCAR"} )
	EndIf

	If lTabDMG .And. !__lPyme
		oModel:AddGrid('MdGridDMG','OMSA060_DA3', oStrMdlDMG,,{|oModel|PosVldDMG(oModel)},/*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
		oModel:SetRelation('MdGridDMG',{ {'DMG_FILIAL','xFilial("DMG")'},{'DMG_CODVEI','DA3_COD'} }, DMG->( IndexKey(1) ) )
		oModel:GetModel( 'MdGridDMG' ):SetOptional(.T.) //-- Permite grid sem dados
		oModel:GetModel( 'MdGridDMG' ):SetDescription(STR0043) //-- "Pagto Pedagio - TAG
		oModel:GetModel( 'MdGridDMG' ):SetUniqueLine( {"DMG_CODTAG"} )
	EndIf

	oModel:SetDescription(STR0001) //-- Cadastro de veículos
	oModel:GetModel("OMSA060_DA3"):SetDescription(STR0001)//-- Cadastro de veículos
	oModel:SetPrimaryKey({"DA3_COD"})

Return ( oModel )

//-------------------------------------
/*  ViewDef
@author     Caio Murakami
@return         oView  View do Cadastro*/
//-------------------------------------
Static Function ViewDef()
Local lDCLNew    := SuperGetMv("MV_DCLNEW" ,.F.,"") .And. AliasInDic("DHF")
Local lTemplate  := FindFunction("TCCheck") .And. TCCheck('DCL') .And. AliasInDic("LBT")
Local oStrViwDA3 := FwFormStruct(2,'DA3')
Local oStrViwDAW := FwFormStruct(2,'DAW')
Local oStrViwCmp := Nil
Local oStrViwDJ8 := FWFormStruct(2,"DJ8")
Local oStrViwDMG := Nil
Local oModel     := FwLoadModel('OMSA060')
Local oView      := FwFormView():New()
Local nCount     := 0
Local nTam1      := 0 //-- Tamanho da View
Local nTam2      := 0
Local nTam3      := 0
Local lRastre    := AliasInDic("DAW") .And. nModulo == 43
Local cTitle     := ""
Local cResource  := ""
Local bBloco
Local cTMSRre := SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza
Local aButtons := {}
Local lTabDMG  := AliasInDic("DMG") .And. nModulo == 43

	If lTabDMG
		oStrViwDMG := FwFormStruct(2,'DMG')
	EndIf

	If lDCLNew
		oStrViwCmp := FWFormStruct(2,"DHF",{|cCampo| AllTrim(cCampo)+"|" $ "DHF_NROCOM|DHF_CAPAC|DHF_NROLAC|"})
		oStrViwCmp:SetProperty('DHF_NROCOM',MVC_VIEW_ORDEM,'01')
		oStrViwCmp:SetProperty('DHF_CAPAC' ,MVC_VIEW_ORDEM,'02')
		oStrViwCmp:SetProperty('DHF_NROLAC',MVC_VIEW_ORDEM,'03')
	ElseIf lTemplate
		oStrViwCmp := FWFormStruct(2,"LBT",{|cCampo| AllTrim(cCampo)+"|" $ "LBT_NROCOM|LBT_CAPAC|LBT_NROLAC|"})
	EndIf

	oStrViwDJ8:RemoveField ('DJ8_CODVEI')

	//-- Ponto de Entrada OM060BUT - utilizado para incluir botoes especificos
	// Este ponto de entrada deverá ser retirado no futuro - Usar o padrão do MVC
	// http://tdn.totvs.com/x/FvJc
	If ExistBlock( "OM060BUT" )
		If Valtype( aUsrBut := Execblock( "OM060BUT", .F., .F. ) ) == "A"
			AEval( aUsrBut, { |x| AAdd( aButtons, x ) } )
		EndIf
	EndIf

	For nCount := 1 To Len(aButtons)
		cResource:= aButtons[nCount,1]
		bBloco   := aButtons[nCount,2]
		cTitle   := aButtons[nCount,3]
		oView:AddUserButton(cTitle,cResource,bBloco)
	Next nCount

	oView:SetModel(oModel)

	If nModulo == 43 .And. !__lPyme .And. ((!Empty(cTMSRre) .And. cTMSRre <> '0') .Or. lTabDMG )

		oView:CreateHorizontalBox( "Field" , 060 )
		oView:CreateHorizontalBox( "FOLDER", 040 )

		oView:AddField('VwFieldDA3', oStrViwDA3 , 'OMSA060_DA3')
		oView:SetOwnerView('VwFieldDA3','Field')
		oView:EnableTitleView('VwFieldDA3',STR0001) //-- Cadastro de veiculos

		oView:CreateFolder( "PASTA", "FOLDER" )
		
		//--- Rastreadores
		If lRastre
			oView:AddGrid( "VwGridDAW", oStrViwDAW, "MdGridDAW" )
			oView:AddSheet( "PASTA", "ABA02", STR0024 ) // Rastreadores
			oView:CreateHorizontalBox( "GridDAW"  , 100,,,"PASTA","ABA02" )
			oView:SetOwnerView("VwGridDAW", "GridDAW" )
			oView:AddIncrementView( "VwGridDAW", "DAW_ITEM" )
		EndIf

		//--- RRE
		If (!Empty(cTMSRre) .And. cTMSRre <> '0') 
			oView:AddGrid( "VwGridDJ8", oStrViwDJ8, "MdGridDJ8" )
			oView:AddSheet( "PASTA", "ABA01", STR0037 )  //Veiculo x Caracteristicas
			oView:CreateHorizontalBox( "GridDJ8"  , 100,,,"PASTA","ABA01" )
			oView:SetOwnerView("VwGridDJ8", "GridDJ8" )
			oView:AddIncrementView( "VwGridDJ8", "DJ8_ITEM" )
		EndIf

		//--- TAG Pedagio
		If lTabDMG
			oView:AddGrid( "VwGridDMG", oStrViwDMG, "MdGridDMG" )
			oView:AddSheet( "PASTA", "ABA03", STR0043 ) //Pagto Pedagio - TAG
			oView:CreateHorizontalBox( "GridDMG"  , 100,,,"PASTA","ABA03" )
			oView:SetOwnerView("VwGridDMG", "GridDMG" )
			oView:AddIncrementView( "VwGridDMG", "DMG_ITEM" )
		EndIf
			

	ElseIf lRastre .And. !__lPyme

		nTam2 := 20

		If lDCLNew .Or. lTemplate
			nTam3 := 20
		EndIf

		nTam1 := 100 - nTam2 - nTam3

		oView:AddField('VwFieldDA3', oStrViwDA3 , 'OMSA060_DA3')
		oView:CreateHorizontalBox('TELA',nTam1)
		oView:EnableTitleView('VwFieldDA3',STR0001) //-- Cadastro de veiculos
		oView:SetOwnerView('VwFieldDA3','TELA')

		If lRastre .And. !__lPyme
			oView:AddGrid( 'VwGridDAW', oStrViwDAW , 'MdGridDAW')
			oView:CreateHorizontalBox('GRID',nTam2)
			oView:SetOwnerView('VwGridDAW','GRID')
			oView:AddIncrementField('VwGridDAW','DAW_ITEM')
			oView:EnableTitleView('VwGridDAW',STR0024) //-- Rastreadores
		EndIf

		If lDCLNew
			oView:AddGrid( "VwGridCmp", oStrViwCmp , "MdGridCmp")
			oView:CreateHorizontalBox("GRID",nTam3)
			oView:SetOwnerView("VwGridCmp","GRID")
			oView:AddIncrementField("VwGridCmp","DHF_NROCOM")
			oView:EnableTitleView("VwGridCmp",STR0042) //-- Compartimentos
		ElseIf lTemplate
			oView:AddGrid( "VwGridCmp", oStrViwCmp , "MdGridCmp")
			oView:CreateHorizontalBox("GRID",nTam3)
			oView:SetOwnerView("VwGridCmp","GRID")
			oView:AddIncrementField("VwGridCmp","LBT_NROCOM")
			oView:EnableTitleView("VwGridCmp",STR0042) //-- Compartimentos
		EndIf
	
	Else

		If lDCLNew .Or. lTemplate
			oView:CreateHorizontalBox( "Field"  , 70 )
		Else
			oView:CreateHorizontalBox( "Field"  , 100 )
		EndIf

		oView:AddField('VwFieldDA3', oStrViwDA3 , 'OMSA060_DA3')
		oView:SetOwnerView('VwFieldDA3','Field')
		oView:EnableTitleView('VwFieldDA3',STR0001) //-- Cadastro de veiculos

		If lDCLNew .Or. lTemplate
			oView:AddGrid( "VwGridCmp", oStrViwCmp , "MdGridCmp")
			oView:CreateHorizontalBox("GRID",30)
			oView:SetOwnerView("VwGridCmp","GRID")
			If lDCLNew
				oView:AddIncrementField("VwGridCmp","DHF_NROCOM")
			Else
				oView:AddIncrementField("VwGridCmp","LBT_NROCOM")
			EndIf
			oView:EnableTitleView("VwGridCmp",STR0042) //-- Compartimentos
		EndIf

	EndIf

Return oView

//-------------------------------------
/*PosVldMdl - Pos valid do Model
Validações da antiga TudoOk

@author     Caio Murakami
@since      08/02/2013
@return         lRet                            */
//-------------------------------------
Static Function PosVldMdl(oModel)
Local lRet       :=.T.
Local aArea      := GetArea()
Local aAreaDA3   := DA3->( GetArea())
Local aAreaDAK   := DAK->(GetArea())
Local nOperation := oModel:GetOperation()
Local lContVei   := .F.
Local cQuery     := ''
Local cAliasTRB  := ''
Local lMntTms    := (GetMV('MV_NGMNTMS',,'N') == 'S') //Ativa integracao TMS X MNT
Local lIntGFE    := SuperGetMv("MV_INTGFE",.F.,.F.)
Local cIntGFE2   := SuperGetMv("MV_INTGFE2",.F.,"2")

	If nOperation <> MODEL_OPERATION_DELETE

		If !Empty(M->DA3_CODFOR+M->DA3_LOJFOR)//nModulo == 43 .Or. nModulo == 39
			If !ExistCpo("SA2",M->DA3_CODFOR+M->DA3_LOJFOR,1)
				Help("",1,"OMSA06011")
				lRet := .F.
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Integracao com o Modulo de Transporte (TMS)                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If IntTms()
			If Empty(M->DA3_PLACA)
				Help(" ",1,"OMSA06001") // Campo Placa deve ser Preenchido !!!
				lRet := .F.
			EndIf
		EndIf

		If nModulo == 43 .and. IntTMS() .And. lRet .And. !__lPyme
			If Empty(M->DA3_FROVEI)
				lRet := .F.
				Help(" ",1,"OMSA06012")  //-- Preenchimento do campo Frota, obrigatório para o módulo SIGATMS.
			ElseIf Empty(M->DA3_CODFOR)
				lRet := .F.
				Help(" ",1,"OMSA06013") //-- Preenchimento do campo Codigo do Proprietario obrigatório para o módulo SIGATMS
			ElseIf Empty(M->DA3_LOJFOR)
				lRet := .F.
				Help(" ",1,"OMSA06014") //-- Preenchimento do campo Loja do Proprietario obrigatório para o módulo SIGATMS.
			EndIf
		EndIf

		If lRet
			// Este ponto de entrada deverá ser retirado no futuro - Usar o padrão do MVC
			// http://tdn.totvs.com/x/9jwPE
			If ExistBlock( "OM060VLD" )
				lRet := ExecBlock( "OM060VLD", .F., .F. )
			EndIf
		EndIf

	Else

		DbSelectArea("DA8")
		DbSetOrder(2)
		If DbSeek(xFilial("DA8")+DA3->DA3_COD)
			lRet := .F.
			Help(" ",1,"DS0600611",,DA8->DA8_COD,05,24) //"Veículo utilizado em Rotas de Entregas, exclusão não permitida.        Roteiro de Entregas:"
		EndIf

		If IntTms() .And. lMntTms
			If lRet
				DbSelectArea("STF")
				STF->(DbSetOrder(1))
				If !Empty(DA3->DA3_CODBEM) .And. MsSeek(xFilial("STF")+AllTrim(DA3->DA3_CODBEM))
					Help(" ",1,"OMSA06004") //"Existe ordem de servico para o bem, nao e permitido a exclusao"
					lRet := .F.
				EndIf
			EndIf

			If lRet
				DbSelectArea("STJ")
				STJ->(DbSetOrder(2))
				If !Empty(DA3->DA3_CODBEM) .And. MsSeek(xFilial("STJ")+ "B" +AllTrim(DA3->DA3_CODBEM))
					Help(" ",1,"OMSA06004") //"Existe ordem de servico para o bem, nao e permitido a exclusao"
					lRet := .F.
				ElseIf lRet .And. !Empty(DA3->DA3_CODBEM) .And. MsSeek(xFilial("STJ")+ "L" +AllTrim(DA3->DA3_CODBEM))
					Help(" ",1,"OMSA06004") //"Existe ordem de servico para o bem, nao e permitido a exclusao"
					lRet := .F.
				EndIf
			EndIf
		EndIf

		If lRet
			// Este ponto de entrada deverá ser retirado no futuro - Usar o padrão do MVC
			// http://tdn.totvs.com/x/F-Jc
			If ExistBlock( "OM060DEL" )
				lRet := ExecBlock( "OM060DEL", .F., .F. )
			EndIf
		EndIf

		If lRet
			DbSelectArea("DAE")
			DAE->(DbSetOrder(1))
			DAE->(DbGoTop())
			While !Eof()
				If  xFilial("DAE") == DAE->DAE_FILIAL .And.;
					DA3->DA3_COD   == DAE->DAE_CODVEI
					Help(" ",1,"OMSA06006") //"O veiculo esta em uso no cadastro de regras, nao pode ser excluido.
					lRet := .F.
					Exit
				EndIf
				DAE->(DbSkip())
			EndDo
		EndIf

		//-- Nao permite a exclusao do veiculo quando o mesmo esta amarrado a uma montagem de cargas.
		If  lRet
			cAliasTRB:=GetNextAlias()
			cQuery := " SELECT DAK_FILIAL "
			cQuery += " FROM "+RetSqlName("DAK")+" WHERE"
			If  !Empty(xFilial("DA3"))
				cQuery += " DAK_FILIAL = '"+xFilial("DAK")+"' AND"
			EndIf
			cQuery += " DAK_CAMINH = '"+DA3->DA3_COD+"' AND"
			cQuery += " D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTRB,.F.,.T.)
			If (cAliasTRB)->(!Eof())
				Help(" ",1,"OMSA06007") //-- O veiculo esta em uso no Cadastro de Montagem de Carga,exclusao nao permitida.
				lRet := .F.
			EndIf
			(cAliasTRB)->(dbCloseArea())
		EndIf

		If lRet
			DbSelectArea("SC5")
			SC5->(DbSetOrder(1))
			cAliasTRB:=GetNextAlias()
			cQuery := " SELECT C5_FILIAL "
			cQuery += " FROM "+RetSqlName("SC5")+" WHERE"
			cQuery += " C5_FILIAL = '"+xFilial("SC5")+"' AND"
			cQuery += " C5_VEICULO = '"+DA3->DA3_COD+"' AND"
			cQuery += " D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTRB,.F.,.T.)
			If (cAliasTRB)->(!Eof())
				Help(" ",1,"OMSA06015") //-- O veiculo esta em uso no Cadastro de Pedido de Venda,exclusao nao permitida.
				lRet := .F.
			EndIf
			(cAliasTRB)->(dbCloseArea())
		EndIf

		If  lRet .And. IntTms() //-- Integracao com o TMS
			lContVei := GetMV('MV_CONTVEI',,.T.) //-- Verifica se o sistema controla veiculo/motorista
			//--Verifica se o veiculo esta relacionado a uma viagem antes de excluir
			cAliasTRB:=GetNextAlias()
			cQuery := " SELECT DTR_FILORI, DTR_VIAGEM "
			cQuery += "  FROM "+RetSqlName("DTR")
			cQuery += " WHERE DTR_FILIAL = '"+xFilial("DTR")+"'"
			cQuery += "   AND ( DTR_CODVEI = '" + DA3->DA3_COD + "'"
			cQuery += "      OR DTR_CODRB1 = '" + DA3->DA3_COD + "'"
			cQuery += "      OR DTR_CODRB2 = '" + DA3->DA3_COD + "' ) "
			cQuery += "   AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTRB,.F.,.T.)
			If (cAliasTRB)->(!Eof())
				MsgAlert(STR0007+AllTrim(DA3->DA3_COD)+STR0008+(cAliasTRB)->DTR_FILORI+"-"+(cAliasTRB)->DTR_VIAGEM) //"O Veiculo "###" nao pode ser excluido pois esta sendo utilizado na Viagem "
				lRet := .F.
			EndIf
			(cAliasTRB)->(dbCloseArea())
			If lRet .And. lContVei
				DTU->(DbSetOrder(2))
				If DTU->(MsSeek(xFilial("DTU")+DA3->DA3_COD))
					MsgAlert(STR0007+AllTrim(DA3->DA3_COD)+STR0009+DTU->DTU_NUMENT) //"O Veiculo "###" nao pode ser excluido pois esta sendo utilizado no Movimento de Veiculos "
					lRet := .F.
				EndIf
			EndIf
		EndIf

		//Altera a categoria do bem para nao integrado ao TMS.
		If IntTms() .And. lMntTms .And. lRet
			dbSelectArea("ST9")
			dbSetOrder(1)
			If dbSeek(xFilial("ST9")+DA3->DA3_CODBEM)
				RecLock("ST9",.F.)
				ST9->T9_CATBEM := "4"
				ST9->T9_CODTMS := Space(Len(ST9->T9_CODTMS))
				MsUnlock("ST9")
			EndIf
		EndIf
		DbSelectArea("DA8")
		DbSetOrder(1)

		RestArea( aAreaDA3 )
		RestArea( aArea )
	EndIf

	//Integração Protheus com SIGAGFE
	If lRet .And. lIntGFE == .T. .And. cIntGFE2 $ "1S"
		If !InterGU8(nOperation,.F.,oModel)
			lRet := .F.
		EndIf
	EndIf

RestArea(aAreaDAK)
RestArea(aAreaDA3)
RestArea(aArea   )
Return( lRet )

//-------------------------------------
/*  PosVldDAW()
Pós Valid do grid
Valida se o modelo possui mais de 2 rastreadores vinculados

@author     Caio Murakami
@since      21/05/2012
@return         lRet
 */
//-------------------------------------
Static Function PosVldDAW(oModel)
Local lRet      := .T.
Local lVeiRas   := .F.
Local aSaveLine := FWSaveRows()
Local aArea     := GetArea()
Local nCount    := 0
Local nX        := 0
Local oModelDA3 := oModel:GetModel('OMSA060_DA3')

	For nCount := 1 To oModel:Length()
		oModel:GoLine(nCount)
		If !oModel:IsDeleted()
			If !OMS060Fabr()
				lRet := .F.
				Exit
			EndIf
			If oModel:GetValue("DAW_MSBLQL") == '2'
				lVeiRas := .T.
			EndIf
			nX ++
		EndIf
	Next nCount

	If nX > 2
		lRet := .F.
		Help(" ",,'OMSA06010') //--Não é permitido mais de 2 rastreadores por veículo
	EndIf

	If lRet .And. lVeiRas
		oModelDA3:SetValue('OMSA060_DA3','DA3_VEIRAS','1')
	Else
		If !lVeiRas
			oModelDA3:SetValue('OMSA060_DA3','DA3_VEIRAS','2')
		EndIf
	EndIf

FWRestRows( aSaveLine )
RestArea(aArea)
Return lRet

//-------------------------------------
/*CommitMdL - Gravação manual do Model
Complemento da gravação

@author     Caio Murakami
@since      08/02/2013
@return         lRet                            */
//-------------------------------------
Static Function CommitMdL(oModel)
Local aArea		:= GetArea()
Local lRet		:= .T.
Local nOpc		:= 0
Local lIntGFE	:= SuperGetMv("MV_INTGFE",.F.,.F.)
Local cIntGFE2	:= SuperGetMv("MV_INTGFE2",.F.,"2")
Local cData		:= dDataBase
Local cHora		:= StrTran(Left(Time(),5),':','')
Local cCodVei	:= oModel:GetValue("OMSA060_DA3","DA3_COD")
Local lFrotaTer	:= oModel:GetValue("OMSA060_DA3","DA3_FROVEI") == "2" //Terceiro
Local cFrotaTer	:= oModel:GetValue("OMSA060_DA3","DA3_FROVEI") //Terceiro
Local lTMSOPdg  := SuperGetMV('MV_TMSOPDG',,'0') == '2'
Local lPagBem	:= FindFunction("TMSIntgPB") .AND. DA3->(FieldPos("DA3_CODMUN")) > 0 .AND. DA3->(FieldPos("DA3_RODAGE")) > 0 .AND. DA3->(FieldPos("DA3_INTOPE")) > 0 .AND. DA3->(FieldPos("DA3_INTEGR")) > 0
Local cIntegra	:= If( lPagBem, oModel:GetValue("OMSA060_DA3","DA3_INTOPE"), "1" )

	//-- Obtem operacao que o Model esta realizando
	nOpc := oModel:GetOperation()

	If nOpc == MODEL_OPERATION_DELETE .AND. lRestRepom .AND. lFrotaTer
		lRepom := TMSVeiLoc( cCodVei, .T., "Delete" )
	EndIf

	//DLOGTMS01-3186 - Alimentar Data e Hora do Status com Data e Hora Corrente.
	If nOpc == MODEL_OPERATION_INSERT .And. DA3->(ColumnPos("DA3_DATSTS")) > 0 .And. DA3->(ColumnPos("DA3_HORSTS")) > 0
		If Empty(oModel:GetModel("OMSA060_DA3"):GetValue("DA3_DATSTS"))
			oModel:SetValue("OMSA060_DA3","DA3_DATSTS",cData)
		EndIf
		If Empty(oModel:GetModel("OMSA060_DA3"):GetValue("DA3_HORSTS"))
			oModel:SetValue("OMSA060_DA3","DA3_HORSTS",cHora)
		EndIf
	ElseIf nOpc == MODEL_OPERATION_INSERT .And. oModel:GetValue("OMSA060_DA3","DA3_STATUS") == '3'
		oModel:LoadValue("OMSA060_DA3","DA3_STATUS",Iif(nModulo == 43,"1","2"))
	EndIf

	Begin Transaction
		If FwFormCommit(oModel)
			// Este ponto de entrada deverá ser retirado no futuro - Usar o padrão do MVC
			// http://tdn.totvs.com/x/XvJc
			If ExistBlock("OS060GRV")
				ExecBlock("OS060GRV", .F., .F., {nOpc} )
			EndIf

			//Integração Protheus com SIGAGFE
			If lRet .And. lIntGFE == .T. .And. cIntGFE2 $ "1S"
				If !InterGU8(nOpc,.T.,oModel)
					lRet := .F.
				EndIf
			EndIf
		EndIf
	End Transaction

	If lRet .AND. lRestRepom .AND. nOpc <> MODEL_OPERATION_DELETE .AND. lFrotaTer
		lRepom := TMSVehic( cCodVei )
		If lPagBem
			Begin Transaction
				RecLock( "DA3", .F.)
					DA3->DA3_INTEGR := If( lRepom, "1", "2" )
				DA3->( MsUnlock() )
			End Transaction
		EndIf
	EndIf

	If lRet .AND. lPagBem .AND. lTMSOPdg .AND. nOpc <> MODEL_OPERATION_DELETE .AND. cFrotaTer $ '2|3' .AND. cIntegra $ '3|4'
		TMSIntgPB( , , cCodVei )
	EndIf

RestArea(aArea)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A060Vld   ³ Autor ³ Rodolfo K. Rosseto    ³ Data ³ 22.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao Geral                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A060Vld()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function A060Vld(nOpc)
Local lRet     :=.T.
Local cCampo   := ReadVar()
Local aArea    := GetArea()
Local lMntTms  := (GetMV('MV_NGMNTMS',,'N') == 'S') //Ativa integracao TMS X MNT
Local lContVei := GetMV('MV_CONTVEI',,.T.) //-- Verifica se o sistema controla veiculo/motorista
Default nOpc   := 3

	If cCampo == "M->DA3_CODFOR"
		If !Empty(M->DA3_CODFOR) .And. !Empty(M->DA3_LOJFOR)
			SA2->(DbSetOrder(1))
			If SA2->(MsSeek(xFilial("SA2")+M->DA3_CODFOR+M->DA3_LOJFOR))
				If SA2->A2_MSBLQL == "1"
					HELP(" ",1,"REGBLOQ")
					lRet := .F.
				EndIf
			Else
				HELP(" ",1,"REGNOIS")
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If IntTms()
		If cCampo $ 'M->DA3_ATIVO'
			//verifica se o usuario esta tentando desativar o veiculo com ele em uso
			If M->DA3_ATIVO == StrZero(2,Len(DA3->DA3_ATIVO) ) .And. nOpc == 4
				If  lContVei
					DTU->( DbSetOrder(2) )
					If  DTU->( MsSeek( xFilial("DTU") + M->DA3_COD + StrZero(1,Len(DTU->DTU_STATUS) ) ) ) .Or. ;    //verifica se existe status aberto
						DTU->( MsSeek( xFilial("DTU") + M->DA3_COD + StrZero(2,Len(DTU->DTU_STATUS) ) ) ) .Or. ;    //verifica se existe status liberado
						DTU->( MsSeek( xFilial("DTU") + M->DA3_COD + StrZero(3,Len(DTU->DTU_STATUS) ) ) )           //verifica se existe status reservado
						lRet := .F.
						Help(" ",1,"OMSA06005") //"O veiculo esta em uso no movimento de veiculos, não pode ser desativado
					EndIf
				EndIf
				If lRet
					lRet := TmsEmViag(,,M->DA3_COD,1,.T.)
				EndIf
			EndIf
		ElseIf cCampo $ 'M->DJ8_CODCAR'
			lRet:= ExistCpo("DJ0",M->DJ8_CODCAR,1)
			If lRet
				If Posicione("DJ0",1,xFilial("DJ0")+M->DJ8_CODCAR,"DJ0_TIPO") <> StrZero(1,Len(DJ0->DJ0_TIPO)) //Veiculos
					Help(" ",1,"OMSA06016") //"Codigo de Caracteristica invalido para Veiculos.
					lRet:= .F.
				EndIf
			EndIf
		EndIf

		If lRet .And. lMntTms
			DbSelectArea("SIX")
			SIX->(DbSetOrder(1))
			If SIX->(MsSeek('DA35')) .And. "DA3_CODBEM" $ SIX->CHAVE //Validar a existencia do indice 5, criado recentemente
				If cCampo $ 'M->DA3_CODBEM'
					DbSelectArea("DA3")
					DbSetOrder(5)
					If !Empty(M->DA3_CODBEM) .And. MsSeek(xFilial("DA3")+AllTrim(M->DA3_CODBEM))
						Help(" ",1,"OMSA06002") //"Codigo do Bem ja utilizado em outro veiculo"
						lRet := .F.
					EndIf
				EndIf
			Else
				Final(STR0002) //"Favor rodar o u_updtms49 para criacao do indice necessario para esta rotina"
				lRet := .F.
			EndIf
			If cCampo $ 'M->DA3_CODBEM'
				If lRet
					DbSelectArea("STF")
					DbSetOrder(1)
					If !Inclui .And. !Empty(DA3->DA3_CODBEM) .And. MsSeek(xFilial("STF")+AllTrim(DA3->DA3_CODBEM))
						Help(" ",1,"OMSA06003") //"Existe ordem de servico para o bem, nao e permitido a alteracao"
						lRet := .F.
					EndIf
				EndIf
				If lRet
					DbSelectArea("STJ")
					DbSetOrder(2)
					If !Inclui .And. !Empty(DA3->DA3_CODBEM) .And. MsSeek(xFilial("STJ")+ "B" +AllTrim(DA3->DA3_CODBEM))
						Help(" ",1,"OMSA06003") //"Existe ordem de servico para o bem, nao e permitido a alteracao"
						lRet := .F.
					ElseIf lRet .And. !Inclui .And. !Empty(DA3->DA3_CODBEM) .And. MsSeek(xFilial("STJ")+ "L" +AllTrim(DA3->DA3_CODBEM))
						Help(" ",1,"OMSA06003") //"Existe ordem de servico para o bem, nao e permitido a alteracao"
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf

	EndIf

RestArea( aArea )
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS060AtOp ³ Autor ³ Vitor Raspa          ³ Data ³ 07.Ago.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza os dados do Veiculo no Cadastro da Operadora      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OMS060AtOp()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OMS060AtOp(lAxCad)
Local aCodigos   := {}
Local nOpcao     := 0
Local cTipVei    := ''
Local lProcess   := .T.
Local lTMSOPdg   := SuperGetMV('MV_TMSOPDG',,'0') == '2'
Local oDlg

Private cCodOpe  := CriaVar('DEG->DEG_CODOPE',.F.)
Private cNomOpe  := CriaVar('DEG->DEG_NOMOPE',.F.)

Default lAxCad   := .F.

	If lAxCad .And. MV_PAR01 == 2
		lProcess := .F.
	ElseIf (lAxCad .And. MV_PAR01 == 1) .Or. !lAxCad
		lProcess := .T.
	EndIf

	If lProcess .And. lTMSOPdg

		DEFINE MSDIALOG oDlg FROM 00,00 TO 090,350 PIXEL TITLE STR0004 //-- 'Atualiza Dados na Operadora'

		@ 011,005 SAY Posicione( 'SX3',2,'DEG_CODOPE','X3_TITULO') SIZE 100,15 COLOR CLR_HBLUE PIXEL
		@ 010,045 MSGET cCodOpe  F3 "DEG" PICTURE  PesqPict("DEG","DEG_CODOPE") SIZE 6,9  ;
					VALID TMSValField(,.T.,'DEG_NOMOPE') .And. TMSValField(,.F.,'cNomOpe') PIXEL
		@ 010,070 MSGET cNomOpe WHEN .F. SIZE 100,9 PIXEL
		DEFINE SBUTTON FROM 30,115 TYPE 1 OF oDlg ENABLE ACTION (nOpcao := 1,oDlg:End())
		DEFINE SBUTTON FROM 30,145 TYPE 2 OF oDlg ENABLE ACTION (nOpcao := 0,oDlg:End())

		ACTIVATE MSDIALOG oDlg CENTERED

		If nOpcao == 1
			cTipVei := Posicione('DUT',1,xFilial('DUT') + DA3->DA3_TIPVEI, 'DUT_CATVEI')
			If cTipVei == '3' //-- Carreta
				AAdd( aCodigos, {'','','',DA3->DA3_COD} )
			Else
				AAdd( aCodigos, {'','',DA3->DA3_COD,''} )
			EndIf

			CursorWait()
			MsgRun( STR0005,; //-- Realizando comunicacao com a Operadora...
					STR0006,; //-- Aguarde
					{|| TMSAtualOp( cCodOpe, IF(cTipVei <> '3', '3', '4'), aCodigos, .T. ) } )
			CursorArrow()
		EndIf
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OMS060BloqºAutor  ³Marcelo C. Coutinho º Data ³  19/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Bloqueio e Desbloqueio de veículos na Filial               º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OMS060Bloq( cTpMov )
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local cQuery    := ""

Private cCadastro := STR0041

	If Posicione('DUT',1,xFilial('DUT')+DA3->DA3_TIPVEI,'DUT_CATVEI') == '3' //-- Carreta
		cQuery := " SELECT DTR_CODRB1 AS DTR_CODVEI FROM "
		cQuery += RetSqlName('DTR') + " DTR, "
		cQuery += RetSqlName('DTQ') + " DTQ  "
		cQuery += "  WHERE DTR.DTR_FILIAL = '" + xFilial('DTR') + "'"
		cQuery += "    AND DTR.DTR_CODRB1 = '" + DA3->DA3_COD   + "'"
		cQuery += "    AND DTR.D_E_L_E_T_ = ' ' "
		cQuery += "    AND DTQ.DTQ_FILIAL = '" + xFilial('DTQ') + "' "
		cQuery += "    AND DTQ.DTQ_FILORI = DTR_FILORI"
		cQuery += "    AND DTQ.DTQ_VIAGEM = DTR_VIAGEM"
		cQuery += "    AND DTQ.DTQ_STATUS NOT IN ( '3', '9' )"
		cQuery += "    AND DTQ.D_E_L_E_T_ = ' '"
		cQuery += "  UNION "
		cQuery += " SELECT DTR_CODRB2 AS DTR_CODVEI FROM "
		cQuery += RetSqlName('DTR') + " DTR, "
		cQuery += RetSqlName('DTQ') + " DTQ  "
		cQuery += "  WHERE DTR.DTR_FILIAL = '" + xFilial('DTR') + "'"
		cQuery += "    AND DTR.DTR_CODRB2 = '" + DA3->DA3_COD   + "'"
		cQuery += "    AND DTR.D_E_L_E_T_ = ' ' "
		cQuery += "    AND DTQ.DTQ_FILIAL = '" + xFilial('DTQ') + "' "
		cQuery += "    AND DTQ.DTQ_FILORI = DTR_FILORI"
		cQuery += "    AND DTQ.DTQ_VIAGEM = DTR_VIAGEM"
		cQuery += "    AND DTQ.DTQ_STATUS NOT IN ( '3', '9' )"
		cQuery += "    AND DTQ.D_E_L_E_T_ = ' '"
	Else
		cQuery := " SELECT DTR_CODVEI AS DTR_CODVEI FROM "
		cQuery += RetSqlName('DTR') + " DTR, "
		cQuery += RetSqlName('DTQ') + " DTQ  "
		cQuery += "  WHERE DTR.DTR_FILIAL = '" + xFilial('DTR') + "' "
		cQuery += "    AND DTR.DTR_CODVEI = '" + DA3->DA3_COD   + "'"
		cQuery += "    AND DTR.D_E_L_E_T_ = ' '"
		cQuery += "    AND DTQ.DTQ_FILIAL = '" + xFilial('DTQ') + "' "
		cQuery += "    AND DTQ.DTQ_FILORI = DTR_FILORI"
		cQuery += "    AND DTQ.DTQ_VIAGEM = DTR_VIAGEM"
		cQuery += "    AND DTQ.DTQ_STATUS NOT IN ( '3', '9' )"
		cQuery += "    AND DTQ.D_E_L_E_T_ = ' '"
	EndIf
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

	If (cAliasQry)->(Eof())

		If __lAutoma .Or. axVisual("DA3", DA3->(Recno()), 2 ) == 1

			RecLock('DA3', .F.)

			DA3->DA3_FILATU := cFilAnt
			DA3->DA3_STATUS := Iif( cTpMov == 'L', '2', '1' )

			MsUnLock()

			If !__lAutoma
				MsgAlert( STR0014 + Iif( cTpMov == 'L', STR0015, STR0016 ) )
			EndIf

		EndIf

	Else

		If !__lAutoma
			MsgAlert( STR0027 + Chr(13)+Chr(13) + STR0028 )  //-- Opção Inválida + Veículo em viagem
		EndIf

	EndIf

	(cAliasQry)->(dbCloseArea())

RestArea( aArea )
Return Nil
//-------------------------------------------------------------------
/*OMS060Fabr
Validacao se o fornecedor selecionado é um fabricante de rastreador

@author  Caio Murakami
@since   21/05/2012
@version 1.0
*/
//-------------------------------------------------------------------
Function OMS060Fabr()
Local lRet      := .T.
Local aSaveLine := FWSaveRows()
Local aArea     := GetArea()
Local oModel    := FwModelActive()
Local cSegAtiv  := SuperGetMv("MV_SATVGER",,"")

	oModel := oModel:GetModel("MdGridDAW")

	SA2->(dbSetOrder(1))
	If SA2->( dbSeek( xFilial("SA2") + oModel:GetValue("DAW_CODRAS") + oModel:GetValue("DAW_LOJRAS")) )
	   If SA2->A2_SATIV1 $ cSegAtiv
		lRet := .T.
		Else
			lRet := .F.
			Help(" ",,'OMSA06009') //-- Fabricante escolhido nao é uma empresa  de rastreamento. As empresas de rastreamento devem ter o campo  Segmentacao de Ativid. 1  (A2_SATIV1)="Gerenciamento de risco".
		EndIf
	ElseIf Empty(oModel:GetValue("DAW_CODRAS"))
		lRet := .F.
	Else
		lRet := .F.
		Help(" ",1,"REGNOIS") //Nao existe registro relacionado a este codigo.
	EndIf

FwRestRows( aSaveLine )
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*IntegDef

@author  Caio Murakami
@since   19/06/2012
@version 1.0
*/
//-------------------------------------------------------------------

Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local aRet := {}

	aRet := OMSI060( cXML , nTypeTrans , cTypeMessage )

Return aRet

//-----------------------------------------------------
/*/ Integra a tabela DA3(Protheus) com GU8(SIGAGFE) a cada registro novo
@author Felipe Machado de Oliveira
@version P11
@since 18/04/2013
/*/
//------------------------------------------------------
Static Function InterGU8(nOperation,lCommit,oModel)
Local lRet       :=  .T.
Local aError     := {}
Local aAreaGU8   := GU8->( GetArea() )
Local oModelGFE  := FWLoadModel("GFEA046")
Local oModelGU8  := oModelGFE:GetModel("GFEA046_GU8")
	GU8->( dbSetOrder(1) )
	If GU8->( dbSeek( xFilial("GU8")+M->DA3_COD ) )
		If nOperation <> MODEL_OPERATION_DELETE
			oModelGFE:SetOperation( MODEL_OPERATION_UPDATE )
		Else
			oModelGFE:SetOperation( MODEL_OPERATION_DELETE )
		EndIf
	Else
		// Se é exclusão e não encontrou no GFE, não faz nada
		If nOperation == MODEL_OPERATION_DELETE
			Return lRet
		EndIf
		oModelGFE:SetOperation( MODEL_OPERATION_INSERT )
	EndIf

	oModelGFE:Activate()

	If nOperation <> MODEL_OPERATION_DELETE
		// De preferência NÃO alterar a ordem de preenchimento dos campos, pois existe um gatilho que é disparado
		// a partir do campo GU8_CDTPVC e que preenche as informações de altura, largura, comprimento
		// tara, etc, o que pode causar sobreposição de informações na inclusão do registro.
		If oModelGFE:GetOperation() == MODEL_OPERATION_INSERT
			oModelGU8:SetValue('GU8_FILIAL', xFilial("GU8"))
			oModelGU8:SetValue('GU8_CDVEIC', M->DA3_COD    )
		EndIf

		oModelGU8:SetValue('GU8_CDTPVC', M->DA3_TIPVEI )
		oModelGU8:SetValue('GU8_PLACA' , M->DA3_PLACA  )
		oModelGU8:SetValue('GU8_UFPLAC', M->DA3_ESTPLA )
		oModelGU8:SetValue('GU8_ALTUR' , M->DA3_ALTEXT )
		oModelGU8:SetValue('GU8_LARGUR', M->DA3_LAREXT )
		oModelGU8:SetValue('GU8_COMPRI', M->DA3_COMEXT )
		oModelGU8:SetValue('GU8_VOLUT' , M->DA3_VOLMAX )
		oModelGU8:SetValue('GU8_CARGUT', M->DA3_CAPACM )
		oModelGU8:SetValue('GU8_PBT'   , M->DA3_CAPACN )
		oModelGU8:SetValue('GU8_TPPROP', IIF(M->DA3_FROVEI == "1","2","1"))
		oModelGU8:SetValue('GU8_CDPROP', FindCdProp(M->DA3_CODFOR,M->DA3_LOJFOR))
		oModelGU8:SetValue('GU8_TARA'  , M->DA3_TARA )
		oModelGU8:SetValue('GU8_MMOD'  , M->DA3_DESC )
		oModelGU8:SetValue('GU8_ANOFAB', M->DA3_ANOFAB)
		oModelGU8:SetValue('GU8_RENAVA', PadR(M->DA3_RENAVA,Len(GU8->GU8_RENAVA)))

		If GU8->(FieldPos('GU8_CIV')) > 0 .And. DA3->(FieldPos('DA3_CIV')) > 0
			oModelGU8:SetValue('GU8_CIV' , M->DA3_CIV)
		EndIf
		If GU8->(FieldPos('GU8_CIPP')) > 0 .And. DA3->(FieldPos('DA3_CIPP')) > 0
			oModelGU8:SetValue('GU8_CIPP', M->DA3_CIPP)
		EndIf

		If M->DA3_ATIVO == "2"
			oModelGU8:LoadValue("GU8_SIT" , "2")
			oModelGU8:SetValue("GU8_DSSIT", STR0034) // "Veículo Inativo"
		Else
			oModelGU8:LoadValue("GU8_SIT" , "1")
			oModelGU8:SetValue("GU8_DSSIT", STR0038)
		EndIf
	EndIf

	If oModelGFE:VldData()
		If lCommit
			oModelGFE:CommitData()
		EndIf
	Else
		aError := oModelGFE:GetErrorMessage()
		oModel:SetErrorMessage(aError[MODEL_MSGERR_IDFORM], aError[MODEL_MSGERR_IDFIELD] , aError[MODEL_MSGERR_IDFORMERR] , aError[MODEL_MSGERR_IDFIELDERR] , aError[MODEL_MSGERR_ID], STR0036+FWX3Titulo(aError[MODEL_MSGERR_IDFIELDERR])+" ("+aError[MODEL_MSGERR_IDFIELDERR]+")"+CRLF+CRLF+aError[MODEL_MSGERR_MESSAGE], aError[MODEL_MSGERR_SOLUCTION])
		lRet := .F.
	EndIf

	oModelGFE:DeActivate()
	oModelGFE:Destroy()
	aError := Nil

RestArea( aAreaGU8 )
Return lRet
//-----------------------------------------------------
/*/{Protheus.doc} FindCdProp
Função que busca o código do proprietário do veículo
@author	SQUAD GFE
@version	1.0
@since		09/10/2019
@return cCodProp, Characters, código do proprietário
@param cFornec, characters, Código do fornecedor
@param cLojForn, characters, Loja do fornecedor
@type function
@sample    Esta função tem por objetivo buscar o código
 proprietário do véiculo
/*/
//------------------------------------------------------
Static Function FindCdProp(cFornec,cLojForn)
Local cCodProp := ""

Default cFornec  := ""
Default cLojForn := ""
Default cCgcForn := ""
		// Busca os dados do proprietário
		If FindFunction("GFEXINPROP")
			cCodProp := GFEXINPROP(cFornec,cLojForn)
		Else
			If !Empty(cFornec+cLojForn)
				If GFEXIEMITM()
					cCodProp := Posicione('GU3',12,xFilial('GU3')+cFornec+cLojForn,'GU3_CDEMIT')
				Else
					cCodProp := Posicione("SA2",1,xFilial("SA2")+cFornec+cLojForn,"A2_CGC")
				EndIf
			EndIf
		EndIf
Return cCodProp

//-----------------------------------------------------
/*/{Protheus.doc} OMS060Auto
Função para setar FLAG que indica se o programa está sendo chamado via Automação
@author	aluizio
@version	1.0
@since		20/11/2020
@return cCodProp, Characters, código do proprietário
@param cFornec, characters, Código do fornecedor
@param cLojForn, characters, Loja do fornecedor
@type function
@sample    Esta função tem por objetivo buscar o código
 proprietário do véiculo
/*/
//------------------------------------------------------
Static __lAutoma := 0
Function OMS060Auto(lAutoma)
	If lAutoma != Nil
		__lAutoma := lAutoma
	EndIf
Return


//-------------------------------------
/*  PosVldDMG()
Pós Valid do grid
Valida a Grid de Pagto de Pedagio TAG

@author     Katia Tiemi
@since      30/03/2021
@return         lRet
 */
//-------------------------------------
Static Function PosVldDMG(oModel)
Local lRet      := .T.
Local aSaveLine := FWSaveRows()
Local nCount    := 0
Local nX        := 0

	For nCount := 1 To oModel:Length()
		oModel:GoLine(nCount)
		If !oModel:IsDeleted()
			If oModel:GetValue("DMG_ATIVO") == '1'  //Sim
				nX ++
			EndIf
		EndIf
	Next nCount

	If nX > 1
		lRet := .F.
		Help(" ",,'OMSA06017') //--Não é permitido mais de uma Tag ativa para o Veiculo
	EndIf

FWRestRows( aSaveLine )
Return lRet
