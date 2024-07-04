#INCLUDE 'PROTHEUS.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'TMSA153.ch'

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA153 
Estrutura da tela gestão de demandas
@type function
@author Ruan Ricardo Salvador
@version 12.1.17
@since 06/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA153()
Private oBrwDeman  := nil
Private oBrwPlan   := nil
Private oBrwCrtDmd := nil
Private oBrwMeta   := nil
Private cTM154Ret := ''
Private cRetF3Esp := ''
Private aDl7Area   := {}
Private aTipVeiDL7 := {}
Private aTipVeiDLE := {}
Private aDbTipVei1 := {}
Private aDbTipVei2 := {}

//Variaveis para tratativa dos refresh dos browse
Private nPosDL8 
Private nPosDL9
Private nPosDL7  
Private lCanPLN := .F.
Private nRfDMD  := 0 //1 - Demanda 2 - Planejamento 3 - Demanda/Planejamento 
Private aRotina := {} // Variável usada para chamar a função TmsConsDTO Quando do o MV_CONTVEI está ativo

	//Abertura da rotina se inicia por meio de um pergunte para filtro inicial
	If !TMA153Par(.T.)
		Return
	EndIf
	
Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados 
@type function
@author Ruan Ricardo Salvador
@version 12.1.17
@since 06/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oStruT01 := FWFormModelStruct():New()
Local oModel   := MPFormModel():New('TMSA153', /*bPre*/, /* bPost*/, /*bACommit*/, /*bCancel*/) 
	
	//Campo necessarios para criacao do model
	oStruT01:AddField('T01', 'T01','T01_DEMAN' , 'L',1 ,0 ,{||.T.},Nil,Nil,Nil,Nil,Nil,Nil,.T.) //Gestao de demandas
	
	//Descricao
	oModel:SetDescription(STR0002) //"Painel"
	
	//Field master
	oModel:addFields('MASTER',nil,oStruT01 , , ,{||{{0} , 0}} )
	oModel:GetModel('MASTER'):SetDescription(STR0001) //"Gestão de Demanda"
	
	oModel:SetPrimaryKey( {} ) 

Return oModel

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Estrutura de dados 
@type function
@author Ruan Ricardo Salvador
@version 12.1.17
@since 06/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oView   := FWFormView():New()
Local oModel  := ModelDef()
Local lMVITMSDMD := SuperGetMv("MV_ITMSDMD",,.F.)
	
	//Seta o model para a view
	oView:SetModel(oModel)
	
	//Criacao do folder principal
	oView:CreateFolder('MAIN')
	
	//Criacao das abas
	oView:AddSheet('MAIN','SHTDEMAN' ,STR0003,{||T153ABADEM()}) //Demandas
	oView:AddSheet('MAIN','SHTCRTDMD',STR0004,{||T153ABACRT()}) //Contrato de demanda
		
	//Divide a aba Demandas em dois box, BOX_ESQ para os botoes laterais e BOX_DIR para os browse
	oView:CreateVerticalBox('BOX_ESQ', 3 ,,/*lPixel*/, 'MAIN', 'SHTDEMAN')
	oView:CreateVerticalBox('BOX_DIR', 97,,/*lPixel*/, 'MAIN', 'SHTDEMAN')
	
	//Divide o BOX_DIR em dois para serem ocupados pelos browse
	oView:CreateHorizontalBox('BOX_DEMAN', 50,'BOX_DIR',/*lPixel*/, 'MAIN', 'SHTDEMAN')
	oView:CreateHorizontalBox('BOX_PLAN' , 50,'BOX_DIR',/*lPixel*/, 'MAIN', 'SHTDEMAN')
	
	//Divide o BOX_ESQ em tres para serem ocupados pelas barras e botoes laterais
	oView:CreateHorizontalBox('BOX_UP', 40,'BOX_ESQ',/*lPixel*/, 'MAIN', 'SHTDEMAN')
	oView:CreateHorizontalBox('BOX_MD', 20,'BOX_ESQ',/*lPixel*/, 'MAIN', 'SHTDEMAN')
	oView:CreateHorizontalBox('BOX_DW', 40,'BOX_ESQ',/*lPixel*/, 'MAIN', 'SHTDEMAN')
	
	//Cria o box BOX_SHTCRT para ocupar a aba Contrato
	oView:CreateVerticalBox('BOX_SHTCRT', 100,,/*lPixel*/, 'MAIN', 'SHTCRTDMD')
	
	//Divide a aba Contrato em box BOX_CRTDMD e BOX_META
	oView:CreateHorizontalBox('BOX_CRTDMD', 50,'BOX_SHTCRT',/*lPixel*/, 'MAIN', 'SHTCRTDMD')
	oView:CreateHorizontalBox('BOX_META'  , 50,'BOX_SHTCRT',/*lPixel*/, 'MAIN', 'SHTCRTDMD')
			
	//Criacao dos browses como OtherObject 
	oView:AddOtherObject('BRW_DEMAN'  ,{|oBrwDeman  |t153CriBrw(oBrwDeman ,1,oModel)})
	oView:AddOtherObject('BRW_PLAN'   ,{|oBrwPlan   |t153CriBrw(oBrwPlan  ,2,oModel)})
	oView:AddOtherObject('BRW_CRTDMD' ,{|oBrwCrtDmd |t153CriBrw(oBrwCrtDmd,3,oModel)})
	oView:AddOtherObject('BRW_META'   ,{|oBrwMeta   |t153CriBrw(oBrwMeta  ,4,oModel)})
	
	//Criacao das barras e botoes laterais 
	oView:AddOtherObject('BOX_UP_TB',{|oTBar|t153CrTBar(oTBar,1)})
	oView:AddOtherObject('BOX_MD_TB',{|oTBar|t153CrTBar(oTBar,2)})
	oView:AddOtherObject('BOX_DW_TB',{|oTBar|t153CrTBar(oTBar,3)})
	
	//Vincula as barras e botoes laterias aos box
	oView:SetOwnerView( 'BOX_UP_TB', 'BOX_UP')
	oView:SetOwnerView( 'BOX_MD_TB', 'BOX_MD')
	oView:SetOwnerView( 'BOX_DW_TB', 'BOX_DW')
	
	//Adiciona botoes em 'Outras acoes' da rotina
	oView:AddUserButton(STR0021,STR0021,{|oView| TMA153Par(.F.)},STR0021) //Parametros
	oView:AddUserButton(STR0025,STR0025,{||Pergunte('TMSA1531', .T.), Pergunte('TMSA153', .F.)},STR0025) //"Configurações (F12)"
	
	If lMVITMSDMD
		SetKey(VK_F12,{ ||Pergunte('TMSA1531', .T.), Pergunte('TMSA153', .F.)} )
	EndIf
	SetKey(VK_F5,{ ||TMA153Par(.F.)} )

	//Vincula os browses aos box			
	oView:SetOwnerView( 'BRW_DEMAN' , 'BOX_DEMAN'  )	
	oView:SetOwnerView( 'BRW_PLAN'  , 'BOX_PLAN'   )
	oView:SetOwnerView( 'BRW_CRTDMD', 'BOX_CRTDMD' )
	oView:SetOwnerView( 'BRW_META'  , 'BOX_META'   )
	
Return oView


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} t153CriBrw()
Criação dos browse Demanda, Planejamento de demanda, Contrato de demanda 
@type function
@author Ruan Ricardo Salvador
@version 12.1.17
@since 06/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function t153CriBrw(oDlg, nOpc, oModel)
	Local lMVITMSDMD := SuperGetMv("MV_ITMSDMD",,.F.)
	Local aArea      := GetArea()

  	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlg, .F., .T. )
	
	oFWLayer:AddLine( 'UP', 100, .F. )             // Cria uma "linha" com 100% do box
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )   // Na "linha" criada cria uma coluna com 100% da tamanho dela
	oPanel := oFWLayer:GetColPanel( 'ALL', 'UP' )  // Pego o objeto desse pedaco do container
  
  	If nOpc == 1
	  	oBrwDeman:= FWMarkBrowse():New()
		oBrwDeman:SetOwner( oPanel )                // Associa o browse ao componente de tela
		oBrwDeman:SetDescription(STR0003)           // Demandas	
		oBrwDeman:SetAlias( 'DL8' )
		DL8->(DbSetOrder(3))
		oBrwDeman:SetMenuDef( 'TMSA153A' )         // Define de onde virao os botoes deste browse
		oBrwDeman:SetFieldMark('DL8_MARK')          // Campo que sera utilizado para marcar/desmarcar 
		oBrwDeman:DisableDetails()  
		oBrwDeman:SetCustomMarkRec({||TMA153MkUn(1)}) //marcar o regisro selecionado
		oBrwDeman:bAllMark:={|| .F.}
		oBrwDeman:SetCacheView(.F.)
		oBrwDeman:Activate()
	ElseIf nOpc == 2
		oBrwPlan:= FWMarkBrowse():New()
		oBrwPlan:SetOwner( oPanel )               // Aqui se associa o browse ao componente de tela
		oBrwPlan:SetDescription(STR0006)          // Planejamento de demanda
		oBrwPlan:SetAlias( 'DL9' )
		oBrwPlan:SetMenuDef( 'TMSA153B' )          // Define de onde virao os botoes deste browse
		oBrwPlan:SetFieldMark('DL9_MARK')         // Campo que sera utilizado para marcar/desmarcar
		oBrwPlan:DisableDetails()
		oBrwPlan:SetCustomMarkRec({||TMA153MkUn(2)}) //marcar o regisro selecionado
		oBrwPlan:bAllMark:={||.F.}
		
		//Legendas do browse Planejamento
		oBrwPlan:AddLegend('DL9_STATUS == "1"',"BR_VERDE"       ,STR0016)   //"Aberto"
		oBrwPlan:AddLegend('DL9_STATUS == "2"',"BR_VERDE_ESCURO",STR0017)	//"Aberto com Demanda"
		If lMVITMSDMD
			oBrwPlan:AddLegend('DL9_STATUS == "6"',"BR_LARANJA"	    ,STR0023)	//"Em Programação"
			oBrwPlan:AddLegend('DL9_STATUS == "3"',"BR_VIOLETA"     ,STR0018)	//"Em Viagem"
		EndIf
		oBrwPlan:AddLegend('DL9_STATUS == "7"',"BR_AMARELO"	    ,STR0039)   //"Em Trânsito"
		oBrwPlan:AddLegend('DL9_STATUS == "8"',"BR_PRETO"       ,STR0066)	//"Cancelado"
		oBrwPlan:AddLegend('DL9_STATUS == "4"',"BR_AZUL"        ,STR0019)	//"Encerrado"	
		oBrwPlan:Activate()
	ElseIf nOpc == 3
		oBrwCrtDmd := FWMBrowse():New()
		oBrwCrtDmd:SetOwner( oPanel )               // Aqui se associa o browse ao componente de tela
		oBrwCrtDmd:SetDescription(STR0004)          // Contrato de demanda
		oBrwCrtDmd:SetAlias( 'DL7' )
		oBrwCrtDmd:SetMenuDef( 'TMSA153C' )         // Define de onde virao os botoes deste browse
		oBrwCrtDmd:DisableDetails()
		oBrwCrtDmd:AddStatusColumns({||T153StatC(DL7->DL7_STATUS)}, {||T153LEGC()})
		oBrwCrtDmd:Activate()	
	ElseIf nOpc == 4
		oBrwMeta := FWMBrowse():New()
		oBrwMeta:SetOwner( oPanel )       // Aqui se associa o browse ao componente de tela
		oBrwMeta:SetDescription(STR0032)  // Metas x Grupo de Regioes da Demanda
		oBrwMeta:SetAlias( 'DLE' )
		oBrwMeta:SetMenuDef( 'TMSA153D' ) // Define de onde virao os botoes deste browse
		oBrwMeta:DisableDetails()
		oBrwMeta:AddStatusColumns({||T153StatD(DLE->DLE_CRTDMD,DLE->DLE_CODGRD)}, {||T153LEGD()})
		oBrwMeta:SetCacheView(.F.)
		oBrwMeta:Activate()	
		
		//Cria relacionamento entre o browse de contrato e browse de Metas
		oRelacDLE:= FWBrwRelation():New() 
		oRelacDLE:AddRelation( oBrwCrtDmd  , oBrwMeta , { { 'DLE_FILIAL', 'xFilial( "DLE" )' }, { 'DLE_CRTDMD' , 'DL7_COD'  } } )
		oRelacDLE:Activate()
	EndIf
	
	RestArea(aArea)
Return 

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} t153CrTBar()
Criação das barras laterais e botões da tela
@type function
@author Ruan Ricardo Salvador
@version 12.1.17
@since 06/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Static function t153CrTBar(oDlg, nOpc)

	Local lMVITMSDMD := SuperGetMv("MV_ITMSDMD",,.F.)

	If nOpc == 1
		oPnlBtn1 := TPanel():New(00,00,,oDlg,,,,,RGB(192,192,192),15,300,.F.,.F.)
		TBtnBmp2():New( 110,02,26,26,'PRODUTO',,,,{||T153AFrDMD()} ,oPnlBtn1,STR0007,,.T. )  //Fracionar
		TBtnBmp2():New( 80,02,26,26,'cancel'  ,,,,{||T153RecDmd()} ,oPnlBtn1,STR0008,,.T. ) //Recusar Demanda
	ElseIf nOpc == 2
		oPnlBtn1 := TPanel():New(00,00,,oDlg,,,,,RGB(192,192,192),15,300,.F.,.F.)
		TBtnBmp2():New( 10,02,26,26,'mdirun'     ,,,,{|| TMS153ADD()},oPnlBtn1,STR0009,,.T. ) //Adicionar
		TBtnBmp2():New( 40,02,26,26,'PMSSETADOWN',,,,{||T153BNovo()} ,oPnlBtn1,STR0010,,.T. ) //"Novo Planejamento"
	ElseIf nOpc == 3
		oPnlBtn1 := TPanel():New(00,00,,oDlg,,,,,RGB(192,192,192),15,300,.F.,.F.) 
		If lMVITMSDMD
			TBtnBmp2():New( 34,02,26,26,'AVGARMAZEM',,,,{|| TMSA153G()} ,oPnlBtn1,STR0011,,.T. ) //"Integra TMS"
			TBtnBmp2():New( 64,02,26,26,'AVGBOX1'   ,,,,{||TMSGETF146()},oPnlBtn1,STR0012,,.T. )//"Programação de Carregamento"
			TBtnBmp2():New( 94,02,26,26,'carga'     ,,,,{||TMSGETF144()},oPnlBtn1,STR0013,,.T. ) //"Visualizar viagem"
		Else  // Botões que somente podem ser usados sem integração com TMS: 
			TBtnBmp2():New(  34,02,26,26,'AVGARMAZEM',,,,{|| TM153NoTMS(1)},oPnlBtn1,STR0014,,.T. ) //"Em transito""
			TBtnBmp2():New(  64,02,26,26,'estomovi'  ,,,,{|| TM153NoTMS(2)},oPnlBtn1,STR0056,,.T. ) //"Estornar Em Transito"
			TBtnBmp2():New(  94,02,26,26,'CHECKED'   ,,,,{|| TM153NoTMS(3)},oPnlBtn1,STR0057,,.T. ) //"Encerrar Planejamento"
			TBtnBmp2():New( 124,02,26,26,'devolnf'   ,,,,{|| TM153NoTMS(4)},oPnlBtn1,STR0058,,.T. ) //"EEstornar Encerramento"
		EndIf
		TBtnBmp2():New( 04,02,26,26,'cancel',,,,{||T153RECPL()},oPnlBtn1,STR0015,,.T. ) //"Recusar Planejamento de Demanda"
	EndIf
	
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TMA153Filt
Função de filtro conforme pergunte Tela Gestão Demanda (Grid Contratos de Demandas, Demandas e Planejamento de Demandas)
@author  Marlon Augusto Heiber	
@since   13/04/2018
@version 12.1.21
/*/
//-------------------------------------------------------------------
Function TMA153Filt(cAlias)
	Local cRet  	:= " "
	Local cQuery 	:= " "
	Local nY
	Local cFilDL8	:= ""
	Local cFilDL9	:= ""
	Local lFilCli   := .F.	

	cRet := "@"+cAlias+"_FILIAL = '" + xFilial(cAlias) + "' "
	If cAlias <> "DL7"
		If !Empty(MV_PAR01) .And. Trim(MV_PAR01) != 'Todos'
			aFiliais := StrTokArr(AllTrim(MV_PAR01),";")
			For nY := 1 to Len(aFiliais)
				If !Empty(aFiliais[nY])
					If cAlias == "DL8"
						IIF(nY == 1, cFilDL8 += "'" + PadR(aFiliais[nY],Len(DL8->DL8_FILEXE)) + "'" , cFilDL8 += ", '" + PadR(aFiliais[nY],Len(DL8->DL8_FILEXE)) + "' " )
					ElseIf cAlias == "DL9"
						IIF(nY == 1, cFilDL9 += "'" + PadR(aFiliais[nY],Len(DL9->DL9_FILEXE)) + "'" , cFilDL9 += ", '" + PadR(aFiliais[nY],Len(DL9->DL9_FILEXE)) + "' " )
					EndIf
					
				EndIf
			Next nY
		EndIf
	EndIf

	If cAlias == "DL8"
		cRet += " AND "+cAlias+"_PLNDMD = ' ' AND "+cAlias+"_STATUS = '1' "
		If !Empty(cFilDL8)
			cRet += "AND DL8_FILEXE IN (" + cFilDL8 +  ") "
		EndIf
	Endif
	
	If !Empty(MV_PAR02) .AND. !Empty(MV_PAR03) .OR. Empty(MV_PAR02) .AND. !Empty(MV_PAR03) .OR. !Empty(MV_PAR02) .AND. Empty(MV_PAR03)
		IF cAlias == "DL7"
			cRet += " AND DL7_COD BETWEEN '" + MV_PAR02 + "' "
			cRet += " AND '" + MV_PAR03 + "' "
		ElseIf cAlias == "DL8" .OR.   cAlias == "DL9"
			cRet += " AND DL8_CRTDMD BETWEEN '" + MV_PAR02 + "' "
			cRet += " AND '" + MV_PAR03 + "' "
			lFilCli := .T.
		Endif
	EndIf

	If !Empty(MV_PAR04) .AND. !Empty(MV_PAR06) .OR. Empty(MV_PAR04) .AND. !Empty(MV_PAR06) .OR. !Empty(MV_PAR04) .AND. Empty(MV_PAR06)
		cRet += " AND "+cAlias+"_CLIDEV BETWEEN '" + MV_PAR04 + "' "
		cRet += " AND '" + MV_PAR06 + "' "
		lFilCli := .T.
	EndIf
	If !Empty(MV_PAR05) .AND. !Empty(MV_PAR07) .OR. Empty(MV_PAR05) .AND. !Empty(MV_PAR07) .OR. !Empty(MV_PAR05) .AND. Empty(MV_PAR07)
		cRet += " AND "+cAlias+"_LOJDEV BETWEEN '" + MV_PAR05 + "' "
		cRet += " AND '" + MV_PAR07 + "' "
		lFilCli := .T.
	EndIf
	
	If cAlias == "DL9"
		cQuery := "@DL9_FILIAL = '" + xFilial("DL9") + "' )"
		If !Empty(cFilDL9)
			cQuery += " AND  DL9_FILEXE IN (" + cFilDL9 +  ")"
		EndIf
		If lFilCli
			cQuery += " AND EXISTS (SELECT NULL FROM " + RetSqlName("DL8") + " DL8 WHERE D_E_L_E_T_ = ' ' "
			cQuery += " AND DL8_PLNDMD <> ' ' AND DL9_COD = DL8_PLNDMD AND  "
			cRet   := Strtran(cRet,"@","")
			cRet   := Strtran(cRet,"DL9","DL8")
			cQuery += cRet 
			cQuery += "Union (SELECT NULL FROM " + RetSqlName("DL9") + " XDL9 WHERE DL9_FILIAL = '" + xFilial("DL9") + "' AND D_E_L_E_T_ = ' ' "
			cQuery += "AND DL9_STATUS = '1' AND " + RetSqlName("DL9") + ".R_E_C_N_O_ = XDL9.R_E_C_N_O_ ) "
		Else
			cQuery += "AND (DL9_STATUS <> '5' "  // Não traz os Planejamentos recusados.
		EndIf
		cRet := cQuery
	EndIf
		
Return cRet

/*/{Protheus.doc} TMA153Par
//Executa o pergunte, chama o filtro e Executa a View em modo de visualizacao
@author  Marlon Augusto Heiber	
@since   13/04/2018
@version 12.1.21
/*/
Function TMA153Par(lView)
	Local lRet
	Local aButtons
	Default lView := .F. //Quando .T. inicial da rotina. Quando .F. chamado do botão parametro ou F12
	
	lRet := Pergunte('TMSA153', .T.)
	
	If lRet 
		If lView
			SetKey(VK_F5,{ ||TMA153Par(.F.)} )
			// Executa a View em modo de visualizacao no início da rotina 	 
			aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0024/*Fechar*/},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}  	 
			FWExecView(STR0001,'TMSA153',MODEL_OPERATION_VIEW,, { || .T. },{ || .T.  },,aButtons,{ || .T. })  
		Else
			oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
			oBrwPlan:SetFilterDefault(TMA153Filt("DL9"))
			oBrwCrtDmd:SetFilterDefault(TMA153Filt("DL7"))
		EndIf
	Endif
   	
   	
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T153LEGC
Exibe a legenda conforme status do contrato de demanda
@type function
@author Gustavo Henrique Baptista
@version 12.1.17
@since 20/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function T153LEGC()

	Local   oLegend  :=  FWLegend():New()

	oLegend:Add("","BR_VERDE", STR0016) 	 //Aberto
	oLegend:Add("","BR_BRANCO", STR0005) //"Suspenso"
	oLegend:Add("","BR_AZUL", STR0019)    //Encerrado 
	oLegend:Add("","BR_CINZA", STR0022)    //Inativo 

	oLegend:Activate()
	oLegend:View()
	oLegend:DeActivate()

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T153StatC()
Função retorna as cores conforme o status do contrato de demanda
@type function
@author Gustavo Henrique Baptista
@version 12.1.17
@since 20/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function T153StatC(cStatus)
	Do Case
	Case cStatus=="1"; cStatus := 'BR_VERDE'
	Case cStatus=="2"; cStatus := 'BR_BRANCO'
	Case cStatus=="3"; cStatus := 'BR_AZUL'
	Case cStatus=="4"; cStatus := 'BR_CINZA'
	
	EndCase
Return cStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} TMA153MkUn()
description Função para marcar/desmarcar um único registro
@author  Gustavo Krug
@since   01/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function TMA153MkUn(nOpc)
Local aArea := GetArea()
Local aRet := {}

	If nOpc == 1
		DL8->(DbSetOrder(1))
		If DL8->(MsSeek(xFilial("DL8") + DL8->DL8_COD + DL8->DL8_SEQ ))
			If DL8->DL8_MARK <> oBrwDeman:Mark()
				aRet := TMLockDmd('TMSA153A_' + DL8->(DL8_FILIAL+DL8_COD+DL8_SEQ))
				If aRet[1]
					RecLock("DL8",.F.)
					DL8->DL8_MARK := oBrwDeman:Mark()
					MsUnlock()
				Else
					Help( ,, 'Help',, aRet[2], 1, 0 ) //Registro bloqueado pelo usuário XXXX.
				EndIf
			Else
				TMUnLockDmd('TMSA153A_' + DL8->(DL8_FILIAL+DL8_COD+DL8_SEQ), .T.)
				RecLock("DL8",.F.)
				DL8->DL8_MARK := ''
				MsUnlock() 
			EndIf			
		EndIf

	ElseIf nOpc == 2	
		DL9->(DbSetOrder(1))		
		aRet := TMLockDmd("TMSA153B_" + DL9->DL9_FILIAL + DL9->DL9_COD,.T.)
		If aRet[1] .And. DL9->(MsSeek(xFilial("DL9") + DL9->DL9_COD ))
			RecLock("DL9",.F.)
				DL9->DL9_MARK := IIF(Vazio(DL9->DL9_MARK), oBrwPlan:Mark(), '')
				 If Vazio(DL9->DL9_MARK)
				 	TMUnLockDmd("TMSA153B_" + DL9->DL9_FILIAL + DL9->DL9_COD,.T.) //elimina o semáforo criado pela LockByName
				 Endif 
			MsUnlock()
		Else
			Help( ,, 'HELP',, aRet[2], 1, 0 ) //Registro bloqueado pelo usuário XXXX.
			lRet := .F.
		EndIf
	EndIf
	RestArea(aArea)	
Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TDLEStat()
Função retorna as cores conforme cadastro de metas
@type function
@author Ruan Ricardo Salvador
@version 12.1.17
@since 04/06/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function T153StatD(cCodCRT,cCodGRD)
	Local cStatus := ''
	Local lVei := .T.
	
	DLG->(DbSetOrder(1))
	If DLG->(dbSeek(xFilial('DLG')+cCodCRT+cCodGRD))
		DLF->(DbSetOrder(1))
		If DLF->(dbSeek(xFilial('DLF')+cCodCRT+cCodGRD))
			While DLF->(!EOF()) .And. DLF->DLF_CRTDMD == cCodCRT .And. DLF->DLF_CODGRD == cCodGRD 
				Iif(!DLG->(dbSeek(xFilial('DLG')+cCodCRT+cCodGRD+DLF->DLF_TIPVEI)), lVei := .F.,)
				DLF->(DbSkip())
			EndDo
			If lVei
				cStatus := 'BR_VERDE'
			Else
				cStatus := 'BR_AMARELO'
			EndIf
		Else
			cStatus := 'BR_VERDE'
		EndIf
	Else
		cStatus := 'BR_CINZA'
	EndIf
	
Return cStatus

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TDLELEG
Exibe a legenda conforme cadastro de metas 
@type function
@author Ruan Ricardo Salvador
@version 12.1.17
@since 04/06/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function T153LEGD()

	Local   oLegend  :=  FWLegend():New()

	oLegend:Add("","BR_CINZA",   STR0033) //Meta nao cadastrada
	oLegend:Add("","BR_AMARELO", STR0034) //Meta parcialmente cadastrada
	oLegend:Add("","BR_VERDE",   STR0035) //Meta cadastrada
	
	oLegend:Activate()
	oLegend:View()
	oLegend:DeActivate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} T153ABACRT()
Troca de abas Demandas -> Contrato de demandas
@author  Ruan Ricardo Salvador
@since   18/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function T153ABACRT()

	Pergunte('TMSA153', .F.)
	
	//Verifica se está posicionado no ultimo registro e declara como NIL para nao usar mais um SetFilterDefault
	nPosDL8 := oBrwDeman:At() 
	If Type('nPosDL8') == 'N'  
		oBrwDeman:GoBottom()
		If nPosDL8 == oBrwDeman:At()
			nPosDL8 := NIL
		Else
			oBrwDeman:GoTo(nPosDL8)
		EndIf
	EndIf
	
	//Verifica se está posicionado no ultimo registro e declara como NIL para nao usar mais um SetFilterDefault
	nPosDL9 := oBrwPlan:At()
	If Type('nPosDL9') == 'N'  
		oBrwPlan:GoBottom()
		If nPosDL9 == oBrwPlan:At()
			nPosDL9 := NIL
		Else
			oBrwPlan:GoTo(nPosDL9)
		EndIf
	EndIf

	If Type('nPosDL7') == 'N' .And. nPosDL7 >= 1  
		oBrwCrtDmd:= FwLoadModel('TMSA153C')  
		oBrwCrtDmd:Activate()		
	Else
	 	oBrwCrtDmd:SetFilterDefault(TMA153Filt("DL7"))
		oBrwCrtDmd:onchange()		
	EndIf
	oBrwMeta:Refresh()

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T153ABADEM
Troca de abas Contrato de demandas -> Demandas
@type function
@author Aluizio Fernando Habizenreuter
@version 12.1.17
@since 15/06/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function T153ABADEM()
Local nIndexDL8	:= DL8->(IndexOrd())
Local nIndexDL9	:= DL9->(IndexOrd())
Local nPosDL8Tmp:= oBrwDeman:At()
Local nPosDL9Tmp:= oBrwPlan:At()

	Pergunte('TMSA153', .F.)

	
	//Tratamento para primeiro acesso filtrando range de contratos para nao usar mais um SetFilterDefault
	
	oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
		
	If Type('nPosDL8') == 'N'
		If !Empty(DL8->DL8_COD)
			oBrwDeman:GoTo(nPosDL8)
			DL8->(DbSetOrder(1))
			If !DL8->(dbSeek(xFilial('DL8')+DL8->DL8_COD+DL8->DL8_SEQ))
				oBrwDeman:GoTop(.T.)
			EndIf
			DL8->(DbSetOrder(nIndexDL8))
		EndIF
		oBrwDeman:Refresh()
	Else //Tratamento para nao usar mais um SetFilterDefault
		If !Empty(DL8->DL8_COD) // Necessário verificar se está vazil para primeira entrara da rotina com filtro que não existe
			oBrwDeman:GoBottom()
			nPosDL8 := oBrwDeman:At() 
			If Type('nPosDL8') == 'N'  
				If nPosDL8 <> nPosDL8Tmp //Verifica se estava posicionado no ultimo registro.
					oBrwDeman:GoTo(nPosDL8Tmp)
					nPosDL8 := nPosDL8Tmp
					oBrwDeman:Refresh()
				EndIf
			EndIf
		EndIf
	EndIf 
	
	oBrwPlan:SetFilterDefault(TMA153Filt("DL9"))
	
	If Type('nPosDL9') == 'N'
		If !Empty(DL9->DL9_COD)
			oBrwPlan:GoTo(nPosDL9)
			DL9->(DbSetOrder(1))
			If !DL9->(dbSeek(xFilial('DL9')+DL9->DL9_COD))
				oBrwPlan:GoTop(.T.)
			EndIf
			DL9->(DbSetOrder(nIndexDL9))
		EndIf
		oBrwPlan:Refresh()
	Else //Tratamento para nao usar mais um SetFilterDefault
		If !Empty(DL9->DL9_COD) // Necessário verificar se está vazil para primeira entrara da rotina com filtro que não existe
			oBrwPlan:GoBottom()
			nPosDL9 := oBrwPlan:At() 
			If Type('nPosDL9') == 'N'  
				If nPosDL9 <> nPosDL9Tmp //Verifica se estava posicionado no ultimo registro.
					oBrwPlan:GoTo(nPosDL9Tmp) 
					nPosDL9 := nPosDL9Tmp
					oBrwPlan:Refresh()
				EndIf
			EndIf
		EndIf
	EndIf

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSGETF146
Chama a função do fonte TMSA146 para acionar a programação de carregamento.
@type function
@author Natalia Maria Neves
@version 12.1.17
@since 01/08/2018
/*/
//-------------------------------------------------------------------------------------------------
Function TMSGETF146()
	Local cRetorno 	:= TMSA153FPC(.T.)	//Filtro para mostrar em tela apenas os planejamentos selecionados na gestão de demandas.
	Local lRet		:= .F.

	nPosDL9 := oBrwPlan:At()  
	
	If !Empty(cRetorno)
		TClearFKey()

		TMSA146()

		SetKey(VK_F5,{ ||TMA153Par(.F.)} )
		SetKey(VK_F12,{ ||Pergunte('TMSA1531', .T.), Pergunte('TMSA153', .F.)} )
			
		Pergunte('TMSA153', .F.)
		oBrwPlan:SetFilterDefault(TMA153Filt("DL9"))
		
		If Len(oBrwPlan:FWFilter():GetFilter(.F.)) = 1
			oBrwPlan:GoTo(nPosDL9) 
		Else
			oBrwPlan:GoTop(.T.)
		EndIf

		lRet := .T.	
	EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA153FPC
Filtro para mostrar em tela apenas os planejamentos selecionados na gestão de demandas.
@type function
@author Natalia Maria Neves
@version 12.1.17
@since 23/07/2018
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA153FPC(lValid)

	Local cRet		:= ''
	Local cQuery	:= ''
	Local cCodPln	:= ''
	Local cTempDL9	:= GetNextAlias()
	Local cMarkPln	:= oBrwPlan:Mark()
	Local cPlnErro	:= " "
	Local aCodPln	:= {}
	Local nContErro	:= 0
	Local nX		:= 0
	Local lRet		:= .T.
	Local lMark := .T.
	Local lEmptyMark := .T.
	Local nIndexDL9	:= DL9->(IndexOrd())
	Local aAreaDL9 := GetArea()


	cQuery:= " SELECT DL9.DL9_COD, DL9_MARK, DL9_STATUS    "
	cQuery+= " FROM   "+RetSqlName('DL9')+ " DL9 "
	cQuery+= " WHERE  DL9.DL9_FILIAL = '" + xFilial('DL9') + "'"
	cQuery+= " AND    DL9.DL9_MARK = '" + cMarkPln + "'"  
	cQuery+= " AND    DL9.D_E_L_E_T_ = ' ' "  
	
	cQuery := ChangeQuery( cQuery )
       
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTempDL9, .F., .T. )
	
	If lRet
		While !(cTempDL9)->(EOF()) .AND. cMarkPln == (cTempDL9)->DL9_MARK
			/*Varre o alias da query com os registros marcados e verifica 
			se eles estão dentro do filtro de tela efetuando DbSeek*/
			DL9->(DbSetOrder(1))
			lMark := DL9->(DbSeek(xFilial('DL9') + (cTempDL9)->(DL9_COD)) )
			If lMark
				//Se rotina passou por aqui, significa que registro está marcado(retorno da query) 
				//e está no filtro vigente(DbSeek)
				lEmptyMark := .F.
				If (cTempDL9)->DL9_STATUS == '1' .OR. (cTempDL9)->DL9_STATUS == '2' .AND. lValid		
					AADD(aCodPln,(cTempDL9)->DL9_COD)
					nContErro++
					lRet := .F.
				Else
					lRet := .T.
				EndIf
				If lRet
					If Len(cCodPln) > 2
						cCodPln += ";"
					EndIf
					cCodPln += (cTempDL9)->DL9_COD	
				EndIf	
			EndIf
			(cTempDL9)->(DbSkip())
		EndDo
		
		If !Empty(aCodPln)
			cPlnErro += aCodPln[1]
			For nX := 2 to Len(aCodPln)
				cPlnErro += Iif( nX == Len(aCodPln) ,  " e " , ", ") + aCodPln[nX]
			Next nX
		EndIf
		
		Do Case
			Case nContErro = 1; Help(,,'Help',,STR0040+ " " + cPlnErro + " " + STR0041,1,0,,,,,,)//O planejamento xxxxxx está em aberto e não possui programação de carregamento.
			Case nContErro > 1; Help(,,'Help',,STR0042+ " " + cPlnErro + " " + STR0043,1,0,,,,,,)//Os planejamentos xxxxxx estão em aberto e não possuem programação de carregamento.
		EndCase
		
		If !Empty(cCodPln)
			cRet := "DF8_PLNDMD $ '" + cCodPln +"' .AND. DF8_STATUS <> '9' "	//Status 9=Cancelado
		EndIf
		
	EndIf			
	
	If lEmptyMark .AND. lValid
		Help(,,'Help',,STR0036,1,0,,,,,,)//" Selecionar ao menos um planejamento."
		lRet := .F.
	EndIf
	(cTempDL9)->(DbCloseArea())
	RestArea(aAreaDL9)
	DL9->(DbSetOrder(nIndexDL9))	
Return cRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} TMSGETF144
Executa a tela de viagem de acordo com os planejamentos selecionados
@type function
@author Ruan Ricardo Salvador
@version 12.1.17
@since 02/08/2018
/*/
//-----------------------------------------------------------------------------
Function TMSGETF144()
	Local cSerTran 	:= ''
	Local lRet 		:= .F.

	//Executa as validacoes necessarias para abrir a tela de viagem
	//e retorna servico de transporte se tudo ok
	cSerTran := TMSA153FVG(.T.)[2]

	nPosDL9 := oBrwPlan:At()  

	If !Empty(cSerTran)
		TClearFKey()
		
		Do Case
			Case cSerTran == '1' //Viagem de coleta 
				TMSA144A()
			Case cSerTran == '2' //Viagem de transporte
				TMSA144B()
			Case cSerTran == '3' //Viagem de entrega  
				TMSA144D()
		EndCase

		SetKey(VK_F5,{ ||TMA153Par(.F.)} )
		SetKey(VK_F12,{ ||Pergunte('TMSA1531', .T.), Pergunte('TMSA153', .F.)} )
			
		Pergunte('TMSA153', .F.)
		oBrwPlan:SetFilterDefault(TMA153Filt("DL9"))

		If Len(oBrwPlan:FWFilter():GetFilter(.F.)) = 1
			oBrwPlan:GoTo(nPosDL9) 
		Else
			oBrwPlan:GoTop(.T.)
		EndIf

		lRet := .T.
	EndIf

Return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} TMSA153FVG
Monta o filtro das viagens de acordo com os planejamentos selecionados 
@type function
@author Ruan Ricardo Salvador
@version 12.1.17
@since 02/08/2018
/*/
//-----------------------------------------------------------------------------
Function TMSA153FVG(lValid)
	
	Local cMarkPln := oBrwPlan:mark()
	Local cTempDL9 := GetNextAlias()
	Local cTempDTQ := GetNextAlias()
	Local cPlnErro := ''
	Local cViagem := ''
	Local cQuery := ''
	
	Local nIndexDL9	:= DL9->(IndexOrd())
	Local nX := 0
	
	Local aAreaDL9 := GetArea()
	Local aFilt := {'',''}
	Local aDifViag := {}
	Local aCodPln := {}
	
	Local lEmptyMark := .T.
	Local lMark := .T.
	Local lRet := .T.
		
	cQuery := " SELECT DL9.DL9_COD, DL9_MARK, DL9_STATUS "
	cQuery += "   FROM "+RetSqlName('DL9')+ " DL9 "
	cQuery += "  WHERE DL9.DL9_FILIAL = '" + xFilial('DL9') + "'"
	cQuery += "    AND DL9.DL9_MARK = '" + cMarkPln + "'"  
	cQuery += "    AND DL9.D_E_L_E_T_ = '' "  
		
	cQuery := ChangeQuery( cQuery )     
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTempDL9, .F., .T. )
	
	While !(cTempDL9)->(EOF()) .and. cMarkPln == (cTempDL9)->DL9_MARK
		/*Varre o alias da query com os registros marcados e verifica 
		se eles estão dentro do filtro de tela efetuando DbSeek*/
		DL9->(DBSetOrder(1))
		lMark := DL9->(DbSeek(xFilial('DL9') + (cTempDL9)->(DL9_COD)) )
		If lMark
			//Se rotina passou por aqui, significa que registro está marcado(retorno da query) 
			//e está no filtro vigente(DbSeek)
			lEmptyMark := .F.
			If ((cTempDL9)->DL9_STATUS == '1' .OR. (cTempDL9)->DL9_STATUS == '2' .OR. (cTempDL9)->DL9_STATUS == '6') .AND. lValid
				AADD(aCodPln,(cTempDL9)->DL9_COD)
			Else		
				cQuery:= " SELECT DTQ.DTQ_VIAGEM, DTQ.DTQ_SERTMS, DF8.DF8_PLNDMD "
				cQuery+= "   FROM "+RetSqlName('DTQ')+ " DTQ "
				cQuery+= "        LEFT JOIN "+RetSqlName('DF8')+ " DF8 "
				cQuery+= "          ON DF8.DF8_FILIAL = '" + xFilial('DF8') + "'"
				cQuery+= "         AND DF8.DF8_PLNDMD = '" + (cTempDL9)->DL9_COD + "'"
				cQuery+= "         AND DF8.D_E_L_E_T_= ' ' "
				cQuery+= "  WHERE DTQ.DTQ_FILIAL = '" + xFilial('DTQ') + "'"
				cQuery+= "    AND DTQ.DTQ_FILORI = DF8.DF8_FILORI "
				cQuery+= "    AND DTQ.DTQ_VIAGEM = DF8.DF8_VIAGEM "
				cQuery+= "    AND DTQ.D_E_L_E_T_ = ' ' "
				
				cQuery := ChangeQuery( cQuery )     
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTempDTQ, .F., .T. )
				
				aFilt[2] := (cTempDTQ)->DTQ_SERTMS
			
				If !(cTempDTQ)->(EOF())
					cViagem += Iif(!Empty(cViagem), ', ','') + "'" + (cTempDTQ)->DTQ_VIAGEM + "'"
					aadd(aDifViag, {STR0048 +(cTempDTQ)->DF8_PLNDMD + ; //Planejamento: 
								    STR0049 +(cTempDTQ)->DTQ_VIAGEM + ; //Viagem:  
								    STR0050 + Iif((cTempDTQ)->DTQ_SERTMS == '1', STR0051, Iif((cTempDTQ)->DTQ_SERTMS == '2', STR0052, STR0053)) ,;   //Servico de transporte: 1 Coleta 2 Transporte 3 Entrega
								    00,''})
					If aFilt[2] != (cTempDTQ)->DTQ_SERTMS .And. lValid
						lRet := .F.
					EndIf
				EndIf
				(cTempDTQ)->(DbCloseArea())
			EndIf	
		EndIf	
		(cTempDL9)->(DbSkip())
	EndDo
		
	If !Empty(aDifViag) .And. !lRet
		Help(,,'Help',,STR0044,1,0,,,,,,{STR0045}) //Nao foi possivel abrir tela de viagem pois foi selecionado planejamentos com viagem de servico de transporte diferentes.
		TmsMsgErr(aDifViag,STR0046) //Viagens com servicos de transportes diferentes.
		aFilt[2] := ''
	EndIf
	
	If !Empty(aCodPln)
		cPlnErro += aCodPln[1]
		For nX := 2 to len(aCodPln)
				cPlnErro += Iif( nX == len(aCodPln) ,  " e " , ", ") + aCodPln[nX]
		Next
	EndIf
		
	If !Empty(cPlnErro) .And. lRet
		If len(aCodPln)>1
				Help(,,'Help',,STR0042 + " " + cPlnErro + " " + STR0047,1,0,,,,,,) //Os planejamentos: xxxxxxx nao possuem viagem cadastrada.
		Else
				Help(,,'Help',,STR0040 + " " + cPlnErro + " " + STR0054,1,0,,,,,,) //O planejamento: xxxxxxx nao possui viagem cadastrada.
		EndIf
		
		aFilt[1] := '0'
		lRet := .F.
	EndIf
	
	If !Empty(cViagem) .And. lRet	
		aFilt[1] := " AND DTQ_VIAGEM IN (" + cViagem + ")"	
	EndIf 
				
	If lEmptyMark .AND. lValid
		Help(,,'Help',,STR0036,1,0,,,,,,)//" Selecionar ao menos um planejamento."
		lRet := .F.
	EndIf
	
	(cTempDL9)->(DbCloseArea())	
	RestArea(aAreaDL9)
	DL9->(DbSetOrder(nIndexDL9))
	
Return aFilt 


//-----------------------------------------------------------------------------
/*/{Protheus.doc} TM153NoTMS
Função para permitir finalizar o ciclo da demanda sem integração com TMS. 
@type function
@author Marlon Augusto Heiber
@version 12.1.17
@param nOperacao  = 1 (Em Transito)          ; nOperacao = 2 (Estornar Em Transito); 
@param nOperacao  = 3 (Encerrar Planejamento); nOperacao = 3 (Estornar Encerrar Planejamento)
@param lMVITMSDMD = Garantir que não será chamada a função quando não há integração com o TMS
@since 29/10/2018
/*/
//-----------------------------------------------------------------------------
Function TM153NoTMS(nOperacao)

	Local lBlind    := IsBlind()
	Local cMarkPln	:= IIF(lBlind,'MK',oBrwPlan:Mark())
	Local cQryPln 	:= GetNextAlias()
	Local cQuery 	:= ''
	Local cMensagem := ''
	Local cStaPlnTmp:= ''
	Local cFiltDL9	:= DL9->(DbFilter()) 
	Local lRet		:= .T.
	Local lFiltDL9	:= IIF(lBlind,'',Len(oBrwPlan:FWFilter():GetFilter(.F.)) > 1) //Está usando filtro adicional no planejamento
	Local nX 		:= 0
	Local nIndexDL9	:= DL9->(IndexOrd())
	Local nPosDL8 	:= IIF(lBlind,'',oBrwDeman:At()) 
	Local aDL9Area	:= DL9->(GetArea())
	Local aPlanej	:= {}
	Local aErro		:= {}

	//Query para verificar os registros marcados
	cQuery := " SELECT DL9_FILIAL, DL9_COD "
	cQuery += " FROM "+RetSqlName('DL9')+ " DL9 "
	cQuery += " WHERE DL9.DL9_FILIAL = '" + xFilial('DL9') + "'"
	cQuery += " AND DL9.DL9_MARK = '"+cMarkPln+"' "
	cQuery += " AND DL9.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryPln, .F., .T. )				

	DL9->(DbSetOrder(1))
	//Monta o array aPlanej e busca somente planejamentos que estão sendo apresentados no filtro.
	While (cQryPln)->(!EOF()) .AND. lRet
		If DL9->(DbSeek(xFilial('DL9') + (cQryPln)->(DL9_COD)) )
			aAdd(aPlanej, DL9->DL9_COD)
			If !Empty(cStaPlnTmp) .AND. !(DL9->DL9_STATUS == cStaPlnTmp)
				Help( ,,'HELP',,STR0065, 1, 0 ) // "Para esta operação, selecione apenas planejamentos com status iguais"
				lRet := .F.
				aSize(aPlanej,0)
				Exit 
			EndIf
			If Empty(cStaPlnTmp)
				cStaPlnTmp := DL9->DL9_STATUS
			EndIf
		EndIf
		(cQryPln)->(DbSkip())
	EndDo
		
	For nX := 1 To Len(aPlanej)
		BEGIN TRANSACTION
			If lRet
				If DL9->(DbSeek(xFilial("DL9")+aPlanej[nX]))
					Do Case
						Case nOperacao = 1 .AND. DL9->DL9_STATUS == '2'
							If T153SldDmd(aPlanej[nX],@aErro,13) //Atualiza saldo de aberto com demanda para em viagem
								RecLock('DL9',.F.)
									DL9->DL9_STATUS := '7'
									DL9->DL9_MARK := ''
								MsUnlock()
								TmIncTrk('3', xFilial("DL9"), aPlanej[nX],/*cSeqDoc*/,/*cDocPai*/,'Y',/*cCodMotOpe*/,/*cObs*/,/*cTpRecusa*/)
								cMensagem := STR0059 //"Em Trânsito efetuado com sucesso."
							Else
								lRet := .F.
							EndIf
						Case nOperacao = 2 .AND. DL9->DL9_STATUS == '7'
							If T153SldDmd(aPlanej[nX],@aErro,14) //Estorna saldo de aberto com demanda para em viagem
								RecLock('DL9',.F.)
									DL9->DL9_STATUS := '2'
									DL9->DL9_MARK := ''
								MsUnlock()
								TmIncTrk('3', xFilial("DL9"), aPlanej[nX],/*cSeqDoc*/,/*cDocPai*/,'W',/*cCodMotOpe*/,/*cObs*/,/*cTpRecusa*/)
								cMensagem := STR0060 //"Estorno de Em Trânsito efetuado com sucesso."  
							Else
								lRet := .F.
							EndIf
						Case nOperacao = 3 .AND. DL9->DL9_STATUS == '7'
							If T153SldDmd(aPlanej[nX],@aErro,11) //Atualiza saldo de viagem para Encerrado
								RecLock('DL9',.F.)
									DL9->DL9_STATUS := '4'	
									DL9->DL9_MARK := ''		
								MsUnlock()
								TmIncTrk('3', xFilial("DL9"), aPlanej[nX],/*cSeqDoc*/,/*cDocPai*/,'E',/*cCodMotOpe*/,/*cObs*/,/*cTpRecusa*/)
								cMensagem := STR0061 //"Encerramento efetuado com sucesso."
							Else
								lRet := .F.
							EndIf		
						Case nOperacao = 4 .AND. DL9->DL9_STATUS == '4'
							If T153SldDmd(aPlanej[nX],@aErro,12) //Estorna saldo de viagem para Encerrado
								RecLock('DL9',.F.)
									DL9->DL9_STATUS := '7'
									DL9->DL9_MARK := ''
								MsUnlock()	
								TmIncTrk('3', xFilial("DL9"), aPlanej[nX],/*cSeqDoc*/,/*cDocPai*/,'Y',/*cCodMotOpe*/,/*cObs*/,/*cTpRecusa*/)
								cMensagem := STR0062 //"Estorno de Encerramento efetuado com sucesso."  
							Else
								lRet := .F.
							EndIf	
						OTHERWISE
							Help( ,,'HELP',, STR0067, 1, 0, )	//'A operação selecionada não está de acordo com o status do Planejamento.'
							lRet := .F.
					EndCase
				EndIf
			EndIf
			
			If !lRet
				Iif(!Empty(aErro),TmsMsgErr(aErro,STR0064),) //Inconsistências
				aSize(aErro,0)
				DisarmTransaction()
				Break
			EndIf
			aSize(aErro,0)
		END TRANSACTION
	Next nX
	
	If lRet .AND. !Empty(cMensagem) 
		MsgInfo(cMensagem,STR0063)  // "Planejamento(s):"  
		cMensagem := ''
	EndIf
	
	TClearFKey()
	SetKey(VK_F5,{ ||TMA153Par(.F.)} )
	
	Pergunte('TMSA153',.F.)

	If !lBlind
		DL9->(DbSetOrder(nIndexDL9))
		oBrwPlan:SetFilterDefault(TMA153Filt("DL9"))

		If !Empty(aPlanej)
			oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
			
			If Type('nPosDL8') == 'N'  
				oBrwDeman:GoTo(nPosDL8)
				oBrwDeman:Refresh()
			EndIf
		EndIf
	EndIf
	
	If !lBlind
		If lFiltDL9
			If !Empty( cFiltDL9 )
				Set Filter to &cFiltDL9
			EndIf	
			RestArea(aDL9Area)
			DL9->(dbGoTop())
			oBrwPlan:Refresh(.T.)
		Else
			RestArea(aDL9Area)
			oBrwPlan:Refresh()
		EndIf

		//Fecha a tabela temporaria
		(cQryPln)->(DbCloseArea())
		RestArea(aDL9Area)
	EndIf
	
Return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} T153SldDmd
Função para Atualizar o saldo do contrato de demandas e gravar tracking no ciclo da demanda sem integração com TMS. 
@type function
@author Marlon Augusto Heiber
@version 12.1.17
@param nOperaDmd  = 13 (Em Transito)          ; nOperacao = 14 (Estornar Em Transito); 
@param nOperacao  = 11 (Encerrar Planejamento); nOperacao = 12 (Estornar Encerrar Planejamento)
@since 29/10/2018
/*/
//-----------------------------------------------------------------------------
Static Function T153SldDmd(cCodPln, aErro, nOperaDmd)
	Local cQryDmd	:= GetNextAlias()
	Local cQuery	:= ''
	Local aRet		:= {}
	Local lRet		:= .T.
	Local nIndexDL8	:= DL8->(IndexOrd())
	Local aDL8Area	:= DL8->(GetArea())
	
	cQuery := " SELECT DL8_FILIAL, DL8_COD, DL8_SEQ, DL8_CRTDMD, DL8_CODGRD, DL8_TIPVEI, DL8_SEQMET, DL8_QTD "
	cQuery += "   FROM  " + RetSqlName('DL8') + " "
	cQuery += "  WHERE DL8_FILIAL = '" +  xFilial('DL8') + "'" 
	cQuery += "    AND DL8_PLNDMD = '" + cCodPln + "'" 
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryDmd, .F., .T. )
    
	While !(cQryDmd)->(Eof()) .AND. lRet
		If !Empty((cQryDmd)->DL8_CRTDMD) 
			aRet := TMUpQtMDmd(xFilial('DL8'), (cQryDmd)->DL8_CRTDMD, (cQryDmd)->DL8_CODGRD, (cQryDmd)->DL8_TIPVEI, (cQryDmd)->DL8_SEQMET, (cQryDmd)->DL8_QTD, nOperaDmd)
	    	lRet := aRet[1]
	    	If !Empty(aRet[2])
	    		aAdd(aErro, aRet[2])
	    	EndIf
		EndIf
		DL8->(DbClearFilter()) //Comando para limpar o filtro da tela principal. Ao efetuar o RestArea no fim desta função, o filtro volta.
		DL8->(DbCloseArea())
		DL8->(DbSetOrder(1))
		If lRet .AND. DL8->(DbSeek((cQryDmd)->DL8_FILIAL + (cQryDmd)->DL8_COD + (cQryDmd)->DL8_SEQ))
			Do Case
				Case nOperaDmd = 11 .AND. DL8->DL8_STATUS == '2'
					RecLock('DL8',.F.)
						DL8->DL8_STATUS := '4'		
					MsUnlock()
					TmIncTrk('2', DL8->DL8_FILIAL, DL8->DL8_COD, DL8->DL8_SEQ, DL8->DL8_PLNDMD,'F',/*cCodMotOpe*/,/*cObs*/)
				Case nOperaDmd = 12 .AND. DL8->DL8_STATUS == '4'
					RecLock('DL8',.F.)
						DL8->DL8_STATUS := '2'		
					MsUnlock()
					TmIncTrk('2', DL8->DL8_FILIAL, DL8->DL8_COD, DL8->DL8_SEQ, DL8->DL8_PLNDMD,'B',/*cCodMotOpe*/,/*cObs*/)
			EndCase
		EndIf
		(cQryDmd)->(DbSkip())
	EndDo

	DL8->(DbSetOrder(nIndexDL8))
	(cQryDmd)->(DbCloseArea())  
	RestArea(aDL8Area)
	
Return lRet
