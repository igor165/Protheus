#INCLUDE "JURA163.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE INCLUIR		1
#DEFINE ALTERAR		2
#DEFINE EXCLUIR		3
#DEFINE SALVAR		4
#DEFINE CANCELAR	5
#DEFINE VISUALIZAR	6
#DEFINE UP			1
#DEFINE DOWN		2
#DEFINE LEFT		3
#DEFINE RIGHT		4

Static lAddRef	:= .F.
Static lActive	:= .F.
Static oCmbConfig
Static aConfPesq	:= {}

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA163
Configuração da Pesquisa de Processos

@author Felipe Bonvicini Conti
@since 04/09/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function JURA163()
	Local oDlg
	Local aSize := {}
	
	If JurTabEmpt('NVG') .And. JurTabEmpt('NVH')
		Processa( {|| JurCpoPesq() } , STR0082, STR0083, .F. ) // 'Aguarde', 'Gerando...'
	EndIf

	Processa( {|| JurLoadAsJ() } , STR0082, STR0083, .F. ) // 'Aguarde', 'Gerando...'

	JA158AjPsq()
	JA158ANmCp()

	Private lPesquisa := .T.

	INCLUI := .F. // Serve para o REGTOMEMORY da 'NVK'
	ALTERA := .T. //   "     "         "           "

	aSize := FwGetDialogSize( oMainWnd )
	REGTOMEMORY('NVH', .F.)
	REGTOMEMORY('NVK', .T.,,.F.)
	
	lActive := .T.

	DEFINE MSDIALOG oDlg TITLE STR0007 FROM aSize[1], aSize[2] TO aSize[3], aSize[4] OF oDlg PIXEL //"Configuração da Pesquisa"

	ACTIVATE MSDIALOG oDlg CENTER ON INIT ( JA163Dlg(oDlg) )

	lActive := .F.

Return NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} JA163Dlg
Redenrização da tela de configuração Pesquisas

@author Felipe Bonvicini Conti
@since 04/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static function JA163Dlg(oDlg)
	Local oPnlLPesq, oPnlRPesq, oPnlRPesqC, oPnlRPesqR, oGet/*, oGetC*/
	Local oPnlLPesqC, oPnlLPesqR, oPnlLPesqS
	Local oPnlCpoLst, oPnlCpoSRL, oPnlCpoSRR, oSplCampo, oSplCampoL
	Local oSplCampoR, oDescTable, oListTable, oDescCampo, oListCampo
	Local nIDTable, nIDCampo, oLstNVH, aListaHC
	Local oPnlCposC, oPnlCposR, oEnchoice, oBar
	Local oCmbLstTp, oBtnNova, oBtnCancel, oBtnSalvar, oBtnApagar, oBtnClear, oBtnSair, oBtnGrid
	Local oFld, aDadosCmps, oCmbCampos, oBtnAdd, oBtnDel, oBtnDelAll
	Local oBtnAddAll, oDescInfo, cDescCampo, aDesCampos
	Local cDescConf := CriaVar('NVG_DESC', .F.)
	Local oPnlRelaC, oPnlGrupos
	Local aObj		:= {}
	Local nSelect	:= 0
	Local aPosTela	:= {}
	Local aDescConf	:= ""
	Local nClickNVH, oDescSetas, oBtnTop, oBtnLeft, oBtnRight, oBtnDown
	Local oSubCpoRRL, oSubCpoRRR, oDescDet, oDescObs
	Local oBrowse, oBrowsePrincipal, oBrowseGru
	Local cTextHtml
	Local aTabSort	:= {}
	Local lNewCfg	:= .F.
	Local lNZXInDic  := FWAliasInDic("NZX") // GRUPO DE USUÁRIOS
	Local lNZYInDic  := FWAliasInDic("NZY") // USUÁRIOS X GRUPO
	Local nI
	Local cCodCampo

	oFld := TFolder():New( 0, 0, , , oDlg,,,, .T., , 200, 200 )
	oFld:Align := CONTROL_ALIGN_ALLCLIENT
	oFld:AddItem(STR0076) //"&Principal"
	oFld:AddItem(STR0008) //"&Configura Pesquisa"
	oFld:AddItem(STR0009) //"&Configura Campo"
	If lNZXInDic .And. lNZYInDic // Proteção referente ao requisito PCREQ-10944 - Grupo de usuários
		oFld:AddItem(STR0110 + STR0137) //"&Grupos" ##  " - Carregando..."
		oFld:aDialogs[4]:bChange := {|| onChangeGrupo(oBrowseGru)}
	EndIf
	oFld:AddItem(STR0010) //"&Relaciona Pesquisa"
	oFld:nOption := 1
	oFld:nCLRPANE:= RGB(255,255,255)

	oFld:aEnable(4,.F.)

	oFld:aDialogs[2]:bChange := {|| RefCmbCampos(oCmbLstTp,@aDadosCmps, @aDesCampos, oCmbCampos, @aObj, @lNewCfg)}
	oFld:aDialogs[3]:bChange := {|| oLstNVH:goTop()}

	//Atualiza o combo de campos quando na tela de configuração de pesquisa e move a lista de campos para o topo quando aberta a tela de configuração de campo
	oFld:bChange := {|x| Eval(oFld:aDialogs[x]:bChange) }

	//************************************************************ Aba Principal *****************************************************************
	oFld:aDialogs[1]:ReadClientCoors(.T.,.T.)
	oPnlRelaP	:= tPanel():New(0,0,'',oFld:aDialogs[1],,,,,,0,0)
	oPnlRelaP:Align 	:= CONTROL_ALIGN_ALLCLIENT
	oBrowsePrincipal:= FWMBrowse():New()
	oBrowsePrincipal:SetAlias('NYB')
	oBrowsePrincipal:SetOwner(oPnlRelaP)
	oBrowsePrincipal:SetMenuDef( 'JURA158' )
	oBrowsePrincipal:SetLocate()
	oBrowsePrincipal:SetWalkThru(.F.)
	oBrowsePrincipal:SetAmbiente(.F.)
	oBrowsePrincipal:ForceQuitButton(.T.)
	oBrowsePrincipal:Activate()

//************************************************************ Fim Aba Principal ****************************************************************


//************************************************************ Configura Pesquisa *****************************************************************
	oPnlLPesq := tPanel():New(0,0,'',oFld:aDialogs[2],,,,,,0,0)
	oPnlLPesq:nWidth := 100
	oPnlLPesq:Align := CONTROL_ALIGN_LEFT
	oPnlLPesq:nCLRPANE := RGB(240,240,240)

	oPnlRPesq := tPanel():New(0,0,'',oFld:aDialogs[2],,,,,,0,0)
	oPnlRPesq:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlRPesq:nCLRPANE := RGB(255,255,255)

	oPnlRPesqC := tPanel():New(0,0,'',oPnlRPesq,,,,,,0,0)
	oPnlRPesqC:nHeight := 25
	oPnlRPesqC:Align := CONTROL_ALIGN_TOP
	oPnlRPesqC:nCLRPANE := RGB(240,240,240)

	oPnlRPesqR := TScrollArea():New(oPnlRPesq,0,0,0,0,.T.,.T.,.T.)
	oPnlRPesqR:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlRPesqR:nCLRPANE := RGB(255,255,255)
	oPnlRPesqR:ReadClientCoors(.T.,.T.)

	oPnlLPesqR := tPanel():New(0,0,'',oPnlRPesqR,,,,,,0,0)
	oPnlLPesqR:nHeight := oPnlRPesqR:nHeight
	oPnlLPesqR:nWidth  := oPnlRPesqR:nWidth
	oPnlRPesqR:SetFrame( oPnlLPesqR )
	oPnlLPesqR:nCLRPANE := RGB(255,255,255)

	oPnlLPesqC := tPanel():New(0,0,'',oPnlLPesq,,,,,,0,0)
	oPnlLPesqC:nHeight := 205
	oPnlLPesqC:Align := CONTROL_ALIGN_TOP
	oPnlLPesqC:nCLRPANE := RGB(240,240,240)

	oPnlLPesqS := tPanel():New(0,0,'',oPnlLPesq,,,,,,0,0)
	oPnlLPesqS:nHeight := 80
	oPnlLPesqS:Align := CONTROL_ALIGN_TOP
	oPnlLPesqS:nCLRPANE := RGB(240,240,240)

//*************** Panel Botôes (oPnlLPesqC) *******************
	oGet := TGet():New(10,10,{|u| if(Pcount()>0, cDescConf := u, cDescConf)},;
		oPnlLPesqC,10,10,,,,,,,,.T.,,,,,,,,,,'cDescConf')
	oGet:Align := CONTROL_ALIGN_TOP
	oGet:lVisible := .F.

// Combo de lista de tipos: 1 - Processo / 2 - Follow-Up / 3 - Garantia / 4 - Andamentos / 5 - Despesas e Custas / 6 - Documentos
	oCmbLstTp := TJurCmbBox():New(10,10,10,10,oPnlLPesqC,LstPesq("A"),{||J163LstTpChange(oCmbConfig, oCmbCampos, oCmbLstTp, @aDadosCmps, @aDesCampos)})

	oCmbLstTp :SetAlign(CONTROL_ALIGN_TOP)
	aDescConf := GetNomesConf(oCmbLstTp)

	oCmbConfig := TJurCmbBox():New(30,10,10,10,oPnlLPesqC,GetNomesConf(oCmbLstTp),;
		{|| RefazTela(aObj, oBtnDelAll, oBtnAdd, oCmbCampos, oCmbConfig,oCmbLstTp, @lNewCfg)  })
	oCmbConfig:SetAlign(CONTROL_ALIGN_TOP)

	oBtnNova := tButton():New(10,10,STR0001,oPnlLPesqC,{|| RefCmbCampos(oCmbLstTp,@aDadosCmps, @aDesCampos, oCmbCampos, @aObj) ,;
		NovaConf(oGet, oCmbConfig, oCmbLstTp), lNewCfg := .T. },10,10,,,,.T.,,,,{|| !lNewCfg } /* When  */)


	oBtnNova:Align := CONTROL_ALIGN_TOP

	oBtnCancel := tButton():New(10,10,STR0002,oPnlLPesqC,{|| CancelConf(oGet,oCmbConfig, oCmbLstTp, oBtnDelAll:bAction), AtuCmbConfig(oCmbConfig,oCmbLstTp), lNewCfg := .F. },10,10,,,,.T.) //"Cancelar"

	oBtnCancel:Align := CONTROL_ALIGN_TOP

	oBtnSalvar := tButton():New(10,10,STR0003,;
		oPnlLPesqC,;
		{|| Eval({|| Processa({|| lNewCfg := !SalvaConf(oGet, aPosTela, aObj, oCmbConfig:aItems[oCmbConfig:GetnAt()],oCmbLstTp) ,;
		AtuCmbConfig(oCmbConfig,oCmbLstTp)},STR0033)}) },;
		10,10,,,,.T.) //"Salvar"

	oBtnSalvar:Align := CONTROL_ALIGN_TOP

	oBtnApagar := tButton():New(10,10,STR0004,oPnlLPesqC,;
		{||ApagaConf(oCmbConfig:aItems[oCmbConfig:GetnAt()],.F.),;
		AtuCmbConfig(oCmbConfig,oCmbLstTp)},10,10,,,,.T.) //"Apagar"
	oBtnApagar:Align := CONTROL_ALIGN_TOP

	oBtnGrid := tButton():New(10,10,STR0074,oPnlLPesqC,{|| JCall160(oCmbLstTp)},10,10,,,,.T.) //"Grid"
	oBtnGrid:Align := CONTROL_ALIGN_TOP

	oBtnClear := tButton():New(10,10,STR0005,oPnlLPesqC,{|| LimpaPesq(aObj)},10,10,,,,.T.) //"Limpar"
	oBtnClear:Align := CONTROL_ALIGN_TOP

	If Existblock( 'J163RBUT' )
		aBotoes := Execblock('J163RBUT', .F., .F.)

		If ( !Empty(aBotoes) .And. Valtype( aBotoes ) == 'A' .And. Len(aBotoes) >= 1 )
			For nI := 1 to Len(aBotoes)
				If Len(aBotoes[nI]) == 2
					&("oBtn"+StrZero(nI,2)) := tButton():New(10,10,aBotoes[nI][1],oPnlLPesqC,&(aBotoes[nI][2]),10,10,,,,.T.)
					&("oBtn"+StrZero(nI,2)+":Align") := CONTROL_ALIGN_TOP
				EndIf
			Next nI
		EndIf

	EndIf

	oBtnSair := tButton():New(10,10,STR0006,oPnlLPesqC,{|| oDlg:End()},10,10,,,,.T.) //"Sair"
	oBtnSair:Align := CONTROL_ALIGN_TOP

	RefazScroll(@oPnlLPesqR,oCmbLstTp,oCmbConfig)

//*************** Fim Panel Botôes (oPnlLPesqC) ***************

//*************** Panel Setas (oPnlLPesqS) *******************
	oDescSetas := tSay():New(1,1, {|| STR0077 },oPnlLPesqS,,,,,,.T.,,,0,10) //"Movimenta campos:"
	oDescSetas:Align := CONTROL_ALIGN_TOP
	oDescSetas:lWordWrap  	:= .T.
	oDescSetas:lTransparent := .T.
	oBtnTop   := TBtnBmp2():New(0,0,10,20,"UP",,,,{|| MoveCampo(@aPosTela, @aObj, nSelect, UP)},oPnlLPesqS,,,.T.)
	oBtnLeft  := TBtnBmp2():New(0,0,30,10,"LEFT",,,,{|| MoveCampo(@aPosTela, @aObj, nSelect, LEFT)},oPnlLPesqS,,,.T.)
	oBtnRight := TBtnBmp2():New(0,0,30,10,"RIGHT",,,,{|| MoveCampo(@aPosTela, @aObj, nSelect, RIGHT)},oPnlLPesqS,,,.T.)
	oBtnDown  := TBtnBmp2():New(0,0,10,20,"DOWN",,,,{|| MoveCampo(@aPosTela, @aObj, nSelect, DOWN)},oPnlLPesqS,,,.T.)
	oBtnTop:Align   := CONTROL_ALIGN_TOP
	oBtnDown:Align  := CONTROL_ALIGN_BOTTOM
	oBtnLeft:Align  := CONTROL_ALIGN_LEFT
	oBtnRight:Align := CONTROL_ALIGN_RIGHT
//*************** Fim Panel Setas (oPnlLPesqS) ***************

//*************** Panel Cabeçalho (oPnlRPesqC) ***************

//AtualizaCPOS(oCmbLstTp,@aDadosCmps, @aDesCampos)
	AtualizaCPOS(oCmbLstTp,@aDadosCmps, @aDesCampos, aObj)

	oCmbCampos := TComboBox():New(10,10,{|u|if(PCount()>0,cDescCampo:=u,cDescCampo)}, ;
		aDesCampos,105,20,oPnlRPesqC,, ;
		{||/*Ação*/},,,,.T.,,,, ;
		{|| lNewCfg .And. !Empty(aDesCampos) } ,,,,,'cDescCampo')

	oCmbCampos:Align := CONTROL_ALIGN_LEFT

	oBtnAdd := tButton():New(10,10,STR0011,oPnlRPesqC, ; //"Adiciona Campo"
	{|oBtnAdd, cCodCampo| Add(oPnlLPesqR,@aObj,@nSelect,@aDesCampos,aDadosCmps,cDescCampo,@aPosTela,oCmbConfig,oCmbLstTp,cCodCampo), oCmbCampos:SetItems(aDesCampos)},;
		50,10,,,,.T.,,,,{|| lNewCfg } /* When  */)

	oBtnAdd:Align := CONTROL_ALIGN_LEFT


	oBtnDel := tButton():New(10,10,STR0012,oPnlRPesqC, ; //"Deleta Campo"
	{|| Del(aObj,@nSelect, @aDesCampos, @aPosTela), oCmbCampos:SetItems(aDesCampos)},50,10,,,,.T.,,,,{|| lNewCfg } /* When  */)
	oBtnDel:Align := CONTROL_ALIGN_LEFT


	oBtnAddAll := tButton():New(10,10,STR0013,oPnlRPesqC, ; //"Adiciona todos Campos"
	{|| AddAll(oPnlLPesqR,@aObj,@nSelect,@aDesCampos,aDadosCmps,@cDescCampo,@aPosTela,oCmbCampos,oCmbConfig,oCmbLstTp)},;
		80,10,,,,.T.,,,,{|| lNewCfg } /* When  */)

	oBtnAddAll:Align := CONTROL_ALIGN_LEFT

//<-  "Deleta todos Campos"
	oBtnDelAll := tButton():New(10,10,STR0014,oPnlRPesqC, ;
		{|| DelAll(@aObj,@nSelect,@aDesCampos,@aPosTela,oCmbCampos,oCmbConfig),;
		oCmbCampos:SetItems(aDesCampos),;
		RefazScroll(@oPnlLPesqR,oCmbLstTp,oCmbConfig)},80,10,,,,.T.,,,,{|| lNewCfg } /* When  */)

	oBtnDelAll:Align := CONTROL_ALIGN_LEFT

//*************** Fim Panel Cabeçalho (oPnlRPesqC) ***************

//************************************************************ Fim Configura Pesquisa *************************************************************


//*************************************************************** Configura Campo *****************************************************************
	oPnlCposC  := tPanel():New(0,0,'',oFld:aDialogs[3],,,,,,0,0)
	oPnlCposR  := tPanel():New(0,0,'',oFld:aDialogs[3],,,,,,0,0)
	oPnlCpoLst := tPanel():New(0,0,'',oFld:aDialogs[3],,,,,,0,0)

	oPnlCposC:nHeight := 50
	oPnlCposR:nHeight := 320
	oPnlCposC:Align  := CONTROL_ALIGN_TOP
	oPnlCposR:Align  := CONTROL_ALIGN_TOP
	oPnlCpoLst:Align := CONTROL_ALIGN_ALLCLIENT
	oPnlCposC:nCLRPANE  := RGB(240,240,240)
	oPnlCpoLst:nCLRPANE := RGB(255,255,255)

//oPnlCposC
	oBar := FWButtonBar():New()
	oBar:Init( oPnlCposC , 20 , 20 , CONTROL_ALIGN_TOP , .F. )

	oBar:AddBtnImage( "ADICIONAR_001.PNG" 		,STR0015,{|| AtuMsMGet(oEnchoice,INCLUIR,oLstNVH,@oBar:aItems) } ,, .T., CONTROL_ALIGN_LEFT )
	oBar:AddBtnImage( "ALTERA.PNG"        		,STR0016,{|| AtuMsMGet(oEnchoice,ALTERAR,oLstNVH,@oBar:aItems) } ,, .T., CONTROL_ALIGN_LEFT )
	oBar:AddBtnImage( "EXCLUIR.PNG"       		,STR0017,{|| AtuMsMGet(oEnchoice,EXCLUIR,oLstNVH,@oBar:aItems) } ,, .T., CONTROL_ALIGN_LEFT )
	oBar:AddBtnImage( "SALVAR.PNG"        		,STR0003,{|| AtuMsMGet(oEnchoice,SALVAR,oLstNVH,@oBar:aItems) } ,{|| .F.}, .T., CONTROL_ALIGN_LEFT )
	oBar:AddBtnImage( "CANCEL.PNG"        		,STR0002,{|| AtuMsMGet(oEnchoice,CANCELAR,oLstNVH,@oBar:aItems) } ,{|| .F.}, .T., CONTROL_ALIGN_LEFT )
	oBar:AddBtnImage( "LOCALIZA.PNG"        	,STR0090,{|| J163PsqCpo(@oListCampo) } ,{|| .F.}, .T., CONTROL_ALIGN_LEFT ) //'Pesquisa de campos'
	oBar:AddBtnImage( "FINAL.PNG"        		,STR0006,{|| Eval({||oDlg:End()}) } ,, .T., CONTROL_ALIGN_LEFT )
//Fim oPnlCposC

//oPnlCpoLst
	aListaHC := Array(2)
	aListaHC := ListaHead()
	oLstNVH  := MsNewGetDados():New(000,000,000,000,0,,,,,,,,,,oPnlCpoLst,aListaHC[1],{})
	oLstNVH:nMAx  := 100000
	oLstNVH:aCols := aClone(aListaHC[2])
	oLstNVH:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oLstNVH:oBrowse:bChange := {|| AtuMsMGet(oEnchoice, VISUALIZAR, oLstNVH, @oBar:aItems)}
	oLstNVH:oBrowse:bHeaderClick := {|| }
	oLstNVH:oBrowse:oMother:oBrowse:bHeaderClick := {|oBrw,nCol,Adim| nClickNVH := ClickHead(oLstNVH, nCol, nClickNVH)}
	oLstNVH:Refresh()
//Fim oPnlCpoLst

//oPnlCposR
	oPnlCposRL := tPanel():New(0,0,'',oPnlCposR,,,,,,0,0)
	oPnlCposRR := tPanel():New(0,0,'',oPnlCposR,,,,,,0,0)

	oPnlCposRL:nWidth := 300
	oPnlCposRL:Align := CONTROL_ALIGN_LEFT
	oPnlCposRR:Align := CONTROL_ALIGN_ALLCLIENT

	oSplCampo := tSplitter():Create(oPnlCposRL)
	oSplCampo:setOrient(2)
	oSplCampo:SetOpaqueResize(.T.)
	oSplCampo:Align := CONTROL_ALIGN_ALLCLIENT
	oSplCampoL := tPanel():New(0,0,'',oSplCampo,,,,,,64,30)
	oSplCampoL:Align := CONTROL_ALIGN_LEFT
	oSplCampoR := tPanel():New(0,0,'',oSplCampo,,,,,,0,0)
	oSplCampoR:Align := CONTROL_ALIGN_ALLCLIENT

//*************** Panel Right (oPnlCposRR) *******************
	oSubCpoRRL := tPanel():New(0,0,'',oPnlCposRR,,,,,,0,0)
	oSubCpoRRR := tPanel():New(0,0,'',oPnlCposRR,,,,,,0,0)


	oSubCpoRRR:nWidth := 300
	oSubCpoRRL:Align  := CONTROL_ALIGN_ALLCLIENT
	oSubCpoRRR:Align  := CONTROL_ALIGN_RIGHT

	oDescDet := tSay():New(1,1, {|| STR0035 },oSubCpoRRL,,,,,,.T.,,,5,8) // "Detalhes do Campo:"
	oDescDet:Align := CONTROL_ALIGN_TOP
	oDescDet:lWordWrap    := .T.
	oDescDet:lTransparent := .T.

	oEnchoice := MsMGet():New('NVH',,4,,,,,{0, 0, 0, 0},,,,,,oSubCpoRRL,,,.F.)
	oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	oEnchoice:lActive    := .F.

	oDescObs := tSay():New(1,1, {|| STR0036 },oSubCpoRRR,,,,,,.T.,,,5,8) // "Observações:"
	oDescObs:Align := CONTROL_ALIGN_TOP
	oDescObs:lWordWrap    := .T.
	oDescObs:lTransparent := .T.

// "Identificações no campo 'Condição':"
// "#DADO# - Serve para utilizar a entrada de dado do campo;"
// "#DADO_LIKE# - Serve para efetuar pesquisa em campos Memo onde não é acrecentado o caracter ' ao final da expressão "
// "#***_FILIAL# - Serve para identificar aonde o sistema ira trocar pelo valor da filial da tabela, sendo *** a tabela."
// "#NSZ_NUMCAS# - Se for necessário na condição é possivel utilizar o valor de outro campo da tela, apenas indicando o nome
//								 do campo(Ex: NSZ_NUMCAS) entre ##, então o sistema irá troca-lo pelo valor em memória do mesmo."
//
// "(O SQL da condição deve estar no padrão ANSI 99)"
	oDescInfo := tSay():New(1,1, {|| } ,oSubCpoRRR,,,,,,.T.,,,5,8,,,,,.T.,.T./*lHtml*/)
	oDescInfo:Align := CONTROL_ALIGN_ALLCLIENT
	oDescInfo:lWordWrap    := .T.
	oDescInfo:lTransparent := .T.
	oDescInfo:lTransparent := .F.

	cTextHtml := " <b>"+ STR0018 +"</b><br>"+;
		" - #"+ STR0019 + "# " + STR0038 +"<br>"+ ;
		" - "+ STR0069 +"<br>"+ ;
		" - "+ STR0039 +"<br>"+ ;
		" - "+ STR0040 +"<br>"+ ;
		" - "+ STR0073 +"<br>"+ ;
		"<br>" + STR0020

	oDescInfo:SetText(cTextHtml)

//************* Fim Panel Right (oPnlCposRR) *****************

//*************** Panel Left (oPnlCposRL) *******************
	oDescTable := tSay():New(01,01,{|| STR0021},oSplCampoL,,,,,,.T.,,,8,8) //"Tabelas:"
	oDescTable:Align := CONTROL_ALIGN_TOP
	oDescTable:lTransparent := .F.

	aTabSort := JURRELASX9('NSZ')
	aTabSort := aSort(aTabSort)

	oListTable := tListBox():New(0,0,{|u| if(Pcount()>0,nIDTable:=u,nIDTable)},aTabSort         ,0,0,,oSplCampoL)
	oListTable:BCHANGE := {|| AtuCampos(oListTable, oListCampo, @oBar:aItems)}
	oListTable:Align := CONTROL_ALIGN_ALLCLIENT

	oDescCampo := tSay():New(01,01,{|| STR0022},oSplCampoR,,,,,,.T.,,,8,8) //"Campos:"
	oDescCampo:Align := CONTROL_ALIGN_TOP
	oDescCampo:lTransparent := .F.

	oListCampo := tListBox():New(0,0,{|u| if(Pcount()>0,nIDCampo:=u,nIDCampo)},,0,0,,oSplCampoR)
	oListCampo:BCHANGE := {|| oBar:aItems[6]:lActive := .T.}
	oListCampo:bLDBLClick := {|| SetCampo(oListCampo:aItems[oListCampo:nAt], oBar:aItems[SALVAR]:lActive, oEnchoice )}
	oListCampo:Align := CONTROL_ALIGN_ALLCLIENT
//************* Fim Panel Left (oPnlCposRL) *****************
//Fim oPnlCposR

	If lNZXInDic .And. lNZYInDic // Proteção referente ao requisito PCREQ-10944 - Grupo de usuários
		//Inicio Aba de grupos de usuarios
		oFld:aDialogs[4]:ReadClientCoors(.T.,.T.)
		oPnlGrupos	:= tPanel():New(0,0,'',oFld:aDialogs[4],,,,,,0,0)
		oPnlGrupos:Align 	:= CONTROL_ALIGN_ALLCLIENT
		oBrowseGru:= FWMBrowse():New()
		oBrowseGru:SetAlias('NZX')
		oBrowseGru:SetMenuDef( 'JURA218' )
		oBrowseGru:SetOwner(oPnlGrupos)
		oBrowseGru:SetLocate()
		oBrowseGru:SetWalkThru(.F.)
		oBrowseGru:SetAmbiente(.F.)
		oBrowseGru:ForceQuitButton(.T.)
		oBrowseGru:Activate()

		oFld:aDialogs[4]:cTitle := STR0110 //Grupos
		oFld:aDialogs[4]:CCAPTION := STR0110//Grupos
		oFld:aEnable(4,.T.)
		//Fim Aba de grupos de usuarios

		//Inicio Aba Usuários x Pesquisas
		oFld:aDialogs[5]:ReadClientCoors(.T.,.T.)
		oPnlRelaC	:= tPanel():New(0,0,'',oFld:aDialogs[5],,,,,,0,0)

	Else

		//Inicio Aba Usuários x Pesquisas
		oFld:aDialogs[4]:ReadClientCoors(.T.,.T.)
		oPnlRelaC	:= tPanel():New(0,0,'',oFld:aDialogs[4],,,,,,0,0)

	EndIf

//Continuação Aba Usuários x Pesquisas
	oPnlRelaC:Align 	:= CONTROL_ALIGN_ALLCLIENT
	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias('NVK')
	oBrowse:SetOwner(oPnlRelaC)
	oBrowse:SetLocate()
	oBrowse:SetWalkThru(.F.)
	oBrowse:SetAmbiente(.F.)
	oBrowse:ForceQuitButton(.T.)
	oBrowse:SetFilterDefault( "NVK_CPESQ <> ' '" )
	oBrowse:Activate()

//Fim Aba Usuários x Pesquisas

	// Força abrir na primeira página
	oFld:SetOption(1)
	oFld:ShowPage(1)

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 -
8 - Imprimir
9 - Copiar
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Juliana Iwayama Velho
@since 21/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
Local lNZXInDic := .F.
Local lNZYInDic := .F.
	
	aAdd( aRotina, { STR0043, "VIEWDEF.JURA163", 0, 2, 0, .F. } ) //"Visualizar"
	aAdd( aRotina, { STR0015, "VIEWDEF.JURA163", 0, 3, 0, .F. } ) //"Incluir"
	aAdd( aRotina, { STR0016, "VIEWDEF.JURA163", 0, 4, 0, .F. } ) //"Alterar"
	aAdd( aRotina, { STR0017, "VIEWDEF.JURA163", 0, 5, 0, .F. } ) //"Excluir"

	If SELECT('SX2') > 0
		lNZXInDic := FWAliasInDic("NZX") // GRUPO DE USUÁRIOS
		lNZYInDic := FWAliasInDic("NZY") // USUÁRIOS X GRUPO

		If lNZXInDic .And. lNZYInDic
			aAdd( aRotina, { STR0107, "J163CrComo", 0, 3, 0, NIL } ) // "Criar Como..."
			aAdd( aRotina, { STR0108, "JURR163()", 0, 2, 0, NIL } ) // "Relatório"
			aAdd( aRotina, { STR0127 , 'J163EXPUSR("")'	   , 0, 3, 0, NIL } ) // "Relatório de Usuario"

		EndIf

	EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} Modeldef
Modelo de dados de Usuário X Pesquisa

@author Juliana Iwayama Velho
@since 21/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oModel     := NIL
	Local oStructNVK := FWFormStruct( 1, "NVK" )
	Local oStructNY2 := NIL
	Local oStructNYK := NIL
	Local oStructNYL := NIL
	Local oStructNWO := FWFormStruct( 1, "NWO" )
	Local oStructNWP := FWFormStruct( 1, "NWP" )
	Local lWSTLegal  := JModRst()

	oStructNY2 := FWFormStruct( 1, "NY2" )
	oStructNY2:RemoveField( "NY2_CCONF" )// No model, remove a informação

	oStructNYK := FWFormStruct( 1, "NYK" )
	oStructNYK:RemoveField( "NYK_CCONF" )// No model, remove a informação

	oStructNYL := FWFormStruct( 1, "NYL" )
	oStructNYL:RemoveField( "NYL_CCONF" )// No model, remove a informação

	oStructNWO:RemoveField( "NWO_CCONF" )
	oStructNWP:RemoveField( "NWP_CCONF" )

	oStructNVK:SetProperty( "NVK_CPESQ", MODEL_FIELD_OBRIGAT, !lWSTLegal) // Se a chamada estiver vindo do TOTVS Legal
	oStructNVK:SetProperty( "NVK_PESQ", MODEL_FIELD_OBRIGAT, !lWSTLegal) // Se a chamada estiver vindo do TOTVS Legal

	oModel:= MPFormModel():New( "JURA163", /*Pre-Validacao*/, {|oX| JURA163TOK(oX)}, {|oX| J163COMMIT(oX,.T.)}, /*Cancel*/)
	oModel:SetDescription( STR0012 ) //Deleta campo

	oModel:AddFields( "NVKMASTER", NIL, oStructNVK, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:GetModel( "NVKMASTER" ):SetDescription( STR0044 ) //Usuário X Pesquisa
	oModel:GetModel( "NVKMASTER" ):SetFldNoCopy( { 'NVK_CUSER', 'NVK_DUSER' } )  //Na opcao de Copiar o registro, nao deverá copiar estes campos.
	oModel:AddGrid( "NWODETAIL", "NVKMASTER" /*cOwner*/, oStructNWO, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
	oModel:AddGrid( "NWPDETAIL", "NVKMASTER" /*cOwner*/, oStructNWP, /*bLinePre*/,  {|oX|J163VlRot(oX)} /*bLinePost*/,/*bPre*/, /*bPost*/ )

	oModel:GetModel( "NWODETAIL" ):SetUniqueLine( { "NWO_CCLIEN","NWO_CLOJA" } )
	oModel:GetModel( "NWPDETAIL" ):SetUniqueLine( { "NWP_CROT" } )

	oModel:SetRelation( "NWODETAIL", { { "NWO_FILIAL", "XFILIAL('NWO')" }, { "NWO_CCONF", "NVK_COD" } }, NWO->( IndexKey( 1 ) ) )
	oModel:SetRelation( "NWPDETAIL", { { "NWP_FILIAL", "XFILIAL('NWP')" }, { "NWP_CCONF", "NVK_COD" } }, NWP->( IndexKey( 1 ) ) )

	oModel:AddGrid( "NY2DETAIL", "NVKMASTER" /*cOwner*/, oStructNY2, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
	oModel:GetModel( "NY2DETAIL" ):SetUniqueLine( { "NY2_CGRUP" } )  // Não permite duplicação de códigos do grupo
	oModel:SetRelation( "NY2DETAIL", { { "NY2_FILIAL", "XFILIAL('NY2')" }, { "NY2_CCONF", "NVK_COD" } }, NY2->( IndexKey( 1 ) ) )
	oModel:GetModel( "NY2DETAIL" ):SetDescription( STR0057 ) // "Restrição - Grupo de Clientes"
	oModel:SetOptional( "NY2DETAIL" , .T. )
	oModel:GetModel( "NY2DETAIL" ):SetDelAllLine( .T. )
	JurSetRules( oModel, "NY2DETAIL",, "NY2",,  )

	oModel:AddGrid( "NYKDETAIL", "NVKMASTER" /*cOwner*/, oStructNYK, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
	oModel:GetModel( "NYKDETAIL" ):SetUniqueLine( { "NYK_CESCR" } )  // Não permite duplicação de códigos do escritorio
	oModel:SetRelation( "NYKDETAIL", { { "NYK_FILIAL", "XFILIAL('NYK')" }, { "NYK_CCONF", "NVK_COD" } }, NYK->( IndexKey( 1 ) ) )
	oModel:GetModel( "NYKDETAIL" ):SetDescription( STR0079 ) // "Restrição - Escritótio"
	oModel:SetOptional( "NYKDETAIL" , .T. )
	oModel:GetModel( "NYKDETAIL" ):SetDelAllLine( .T. )
	JurSetRules( oModel, "NYKDETAIL",, "NYK",,  )

	oModel:AddGrid( "NYLDETAIL", "NVKMASTER" /*cOwner*/, oStructNYL, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
	oModel:GetModel( "NYLDETAIL" ):SetUniqueLine( { "NYL_CAREA" } )  // Não permite duplicação de códigos da area
	oModel:SetRelation( "NYLDETAIL", { { "NYL_FILIAL", "XFILIAL('NYL')" }, { "NYL_CCONF", "NVK_COD" } }, NYL->( IndexKey( 1 ) ) )
	oModel:GetModel( "NYLDETAIL" ):SetDescription( STR0080 ) // "Restrição - Área"
	oModel:SetOptional( "NYLDETAIL" , .T. )
	oModel:GetModel( "NYLDETAIL" ):SetDelAllLine( .T. )
	JurSetRules( oModel, "NYLDETAIL",, "NYL",,  )

	oModel:GetModel( "NWODETAIL" ):SetDescription( STR0046 ) // "Restrição - Clientes"
	oModel:GetModel( "NWPDETAIL" ):SetDescription( STR0052 ) // "Acesso Rotinas"

	oModel:SetOptional( "NWODETAIL" , .T. )
	oModel:SetOptional( "NWPDETAIL" , .T. )

	oModel:GetModel( "NWODETAIL" ):SetDelAllLine( .T. )
	oModel:GetModel( "NWPDETAIL" ):SetDelAllLine( .T. )

	JurSetRules( oModel, "NVKMASTER",, "NVK",,  )
	JurSetRules( oModel, "NWODETAIL",, "NWO",,  )
	JurSetRules( oModel, "NWPDETAIL",, "NWP",,  )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Usuário X Pesquisa

@author Juliana Iwayama Velho
@since 21/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView
	Local oModel  := ModelDef()
	Local oStructNVK := FWFormStruct( 2, "NVK" )
	Local oStructNY2 := Nil
	Local oStructNWO := FWFormStruct( 2, "NWO" )
	Local oStructNWP := FWFormStruct( 2, "NWP" )

	oStructNVK:RemoveField( "NVK_COD" )

	oStructNY2:= FWFormStruct( 2, "NY2" )
	oStructNY2:RemoveField( "NY2_CCONF" )

	oStructNYK:= FWFormStruct( 2, "NYK" )
	oStructNYK:RemoveField( "NYK_CCONF" )

	// Campo para uso exclusivo TOTVS Legal
	If oStructNVK:HasField("NVK_CASJUR")
		oStructNVK:RemoveField( "NVK_CASJUR" )
	EndIf

	oStructNYL:= FWFormStruct( 2, "NYL" )
	oStructNYL:RemoveField( "NYL_CCONF" )

	oStructNWO:RemoveField( "NWO_CCONF" )
	oStructNWP:RemoveField( "NWP_CCONF" )

	If oStructNVK:HasField("NVK_DGRUP")
		oStructNVK:SetProperty('NVK_DGRUP',MVC_VIEW_INSERTLINE,.T.)
		oStructNVK:SetProperty('NVK_DUSER',MVC_VIEW_INSERTLINE,.T.)
	EndIf

	JurSetAgrp( 'NVK',, oStructNVK )

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "JURA163_NVK", oStructNVK, "NVKMASTER" )
	oView:AddGrid(  "JURA163_NWP", oStructNWP, "NWPDETAIL" )
	oView:AddGrid(  "JURA163_NWO", oStructNWO, "NWODETAIL" )
	oView:AddGrid(  "JURA163_NY2", oStructNY2, "NY2DETAIL" )
	oView:AddGrid(  "JURA163_NYK", oStructNYK, "NYKDETAIL" )
	oView:AddGrid(  "JURA163_NYL", oStructNYL, "NYLDETAIL" )

//Formatos em tela.
	oView:CreateHorizontalBox( "FORMFIELD" , 50 )
	oView:CreateHorizontalBox( "FORMFOLDER", 50 )

	oView:CreateFolder("FOLDER_01","FORMFOLDER")
	oView:AddSheet("FOLDER_01", "ABA_NWP", STR0052 ) //"Acesso Rotinas"
	oView:AddSheet("FOLDER_01", "ABA_NWO", STR0046 ) //"Restrição - Clientes"
	oView:AddSheet("FOLDER_01", "ABA_NY2", STR0057 ) //"Restrição - Grupo de Clientes"
	oView:AddSheet("FOLDER_01", "ABA_NYK", STR0079 ) //"Restrição - Escritório"
	oView:AddSheet("FOLDER_01", "ABA_NYL", STR0080 ) //"Restrição - Área"

	oView:CreateHorizontalBox("FORMFOLDERNWP",100,,,'FOLDER_01',"ABA_NWP")
	oView:CreateHorizontalBox("FORMFOLDERNWO",100,,,'FOLDER_01',"ABA_NWO")
	oView:createHorizontalBox("FORMFOLDERNY2",100,,,"FOLDER_01","ABA_NY2")
	oView:createHorizontalBox("FORMFOLDERNYK",100,,,"FOLDER_01","ABA_NYK")
	oView:createHorizontalBox("FORMFOLDERNYL",100,,,"FOLDER_01","ABA_NYL")

	oView:SetOwnerView( "JURA163_NVK", "FORMFIELD" 	   )
	oView:SetOwnerView( "JURA163_NY2", "FORMFOLDERNY2" )
	oView:SetOwnerView( "JURA163_NYK", "FORMFOLDERNYK" )
	oView:SetOwnerView( "JURA163_NYL", "FORMFOLDERNYL" )
	oView:SetOwnerView( "JURA163_NWO", "FORMFOLDERNWO" )
	oView:SetOwnerView( "JURA163_NWP", "FORMFOLDERNWP" )

	oView:SetDescription( STR0044 ) //"Usuário X Pesquisa"
	oView:SetUseCursor(.F.)

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} AtuCmbConfig(oCmbConfig)
Função utilizada para Atualizar o combo de comfiguração.
Uso Geral.

@Param	oCmbConfig	Objeto combo.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuCmbConfig(oCmbConfig,oCmbLstTp)

	oCmbConfig:SetItems({""})
	oCmbConfig:SetItems(GetNomesConf(oCmbLstTp))

	oCmbConfig:Refresh()
	oCmbConfig:Enable()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} AtualizaCPOS(oCmbLstTp,aDadosCmps, aDesCampos)
Função utilizada para Atualizar o combo de comfiguração.
Uso Geral.
@Param	oCmbLstTp   Objeto contem  o tipo de pesquisa
@Param	aDadosCmps	Array com os dados dos campos(codigo, descrição).
@Param	aDesCampos	Array com as descrições dos campos.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtualizaCPOS(oCmbLstTp,	aDadosCmps, aDesCampos, aObj)
	Local nI :=0
	Default aObj := {}

	aDesCampos := {}
	aSize(aDesCampos,0)

	aDadosCmps := GetCposNVH(oCmbLstTp)

	//Varre os campos que estão na tela para não exibir no combo os mesmos.
	For nI := 1 to len(aDadosCmps)
		if (aScan(aObj,{|x| (x != NIL .And. x:aDadosCPONVH[2] == aDadosCmps[nI][1])}) == 0)
			aAdd(aDesCampos,aDadosCmps[nI][2])
		Endif
	Next

	aSort(aDesCampos)
Return NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} Add(oPnlLPesqR,aObj,nSelect,aDesCampos,aDadosCmps,cDescCampo,aPosTela,oCmbConfig)
Função utilizada para adicionar um objeto de campo na tela.
Uso Geral.

@Param	oPnlLPesqR	Objeto tela.
@Param	aObj				Array que contem todos os campo de filtro.
@Param	nSelect			Variavél que controla qual objeto esta em foco.
@Param	aDesCampos	Array com as descrições dos campos.
@Param	aDadosCmps  Array que contem todos os dados dos campos de filtro.
@Param	cDescCampo	Descrição do campo.
@Param	aPosTela		Matriz que controla a posição dos campos na tela.
@Param	oCmbConfig  Combo das configurações.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Add(oPnlLPesqR,aObj,nSelect,aDesCampos,aDadosCmps,cDescCampo,aPosTela,oCmbConfig,oCmbLstTp,cCodCampo)

	Local nI          := 0
	Local cDescCmpAdd := ""
	Local aPOS        := {}
	Local nAltNova    := 0
	Local nAltura     := 0
	Local nFind       := 0

	Default cCodCampo := ""

	If LEN(aDesCampos) > 0 .And. LEN(aDadosCmps) > 0

		//Verifica se foi passado o codigo do campo
		If Empty(cCodCampo)
			nFind := aScan(aDadosCmps, { |aX| ALLTRIM(aX[2]) == alltrim(cDescCampo)})
		Else
			nFind := aScan(aDadosCmps, { |aX| ALLTRIM(aX[1]) == alltrim(cCodCampo)})
		EndIf

		If nFind > 0

			cCodCampo   := aDadosCmps[nFind][1]
			cDescCampo  := aDadosCmps[nFind][2]
			cDescCmpAdd := aDadosCmps[nFind][3]
	
			aDel(aDesCampos, aScan(aDesCampos, { |aX| ALLTRIM(aX) == Alltrim(cDescCampo)}) )
			aSize(aDesCampos, LEN(aDesCampos)-1)

			nI := LEN(aObj)+1
			aPOS := PosTela(@aPosTela,nI)
			aAdd(aObj, TJurPnlCampo():New(aPOS[1],aPOS[2],50,22,oPnlLPesqR,cDescCmpAdd,cCodCampo,{||nSelect := nI},;
				{|| SetCpoMemory(aObj)},;
				J163GetSug(J163GetPesq(),cCodCampo),.T.,.T.) )

			If aObj[nI]:IsF3Multi()
				aObj[nI]:EnableF3Multi()
			EndIf

			//Atualização da altura do scroll conforme adiciona mais campos
			If Len(aPosTela) > 0
				If lAddRef
					lAddRef := .F.
				Else
					nAltura  := JA163CalAl(oPnlLPesqR,oCmbLstTp,oCmbConfig)
					nAltNova := Len(aPosTela) * 25 * 2
					If nAltura > 0 .And. nAltura / 25 < Len(aPosTela)
						If nAltNova > oPnlLPesqR:oParent:nHeight
							oPnlLPesqR:nHeight := nAltNova
						Else
							oPnlLPesqR:nHeight := oPnlLPesqR:oParent:nHeight
						EndIf
					EndIf
				EndIf
			EndIf

		EndIf

	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddAll(oPnlLPesqR, aObj, nSelect,aDesCampos,aDadosCmps,cDescCampo,aPosTela,oCmbCampos,oCmbConfig)
Função utilizada para adicionar todos os objetos de campos na tela.
Uso Geral.

@Param	oPnlLPesqR	Objeto tela.
@Param	aObj				Array que contem todos os campo de filtro.
@Param	nSelect			Variavél que controla qual objeto esta em foco.
@Param	aDesCampos	Array com as descrições dos campos.
@Param	aDadosCmps  Array que contem todos os dados dos campos de filtro.
@Param	cDescCampo	Descrição do campo.
@Param	aPosTela		Matriz que controla a posição dos campos na tela.
@Param	oCmbCampos	Combo dos campos.
@Param	oCmbConfig  Combo das configurações.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AddAll(oPnlLPesqR, aObj, nSelect,aDesCampos,aDadosCmps,cDescCampo,aPosTela,oCmbCampos,oCmbConfig,oCmbLstTp)
	Local nI
	Local nTotal := LEN(aDesCampos)

	MsgRun(STR0033,STR0034,{|| }) //"Atualizando..." e "Configurador"
	For nI := 1 to nTotal
		Add(oPnlLPesqR,@aObj,@nSelect,@aDesCampos,aDadosCmps,@cDescCampo,@aPosTela,oCmbConfig,oCmbLstTp)
		oCmbCampos:SetItems(aDesCampos)
	Next
	SetFocusCpo(aObj)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} Del(aObj, nSelect, aDesCampos, aPosTela)
Função utilizada para deletar um objeto de campo da tela.
Uso Geral.

@Param	aObj       Array que contem todos os campo de filtro.
@Param	nSelect    Variavél que controla qual objeto esta em foco.
@Param	aDesCampos Array com as descrições dos campos.
@Param	aPosTela   Matriz que controla a posição dos campos na tela.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Del(aObj, nSelect, aDesCampos, aPosTela)

	If Len(aObj) > 0
		If (nSelect != 0) .And.(aObj[nSelect] != NIL)
			If (aScan(aDesCampos, aObj[nSelect]:cCodCampo + ' - ' + aObj[nSelect]:cDescCampo) == 0)

				aAdd(aDesCampos, aObj[nSelect]:cCodCampo + ' - ' + aObj[nSelect]:cDescCampo)
				aSort(aDesCampos)
				DelPosTela(@aPosTela, nSelect)
				aObj[nSelect]:Destroy()
			EndIf
		ElseIf nSelect == 0 .AND. !Empty(aObj)
			nSelect := Len(aObj)
			If (aScan(aDesCampos, aObj[nSelect]:cCodCampo + ' - ' + aObj[nSelect]:cDescCampo) == 0)
				aAdd(aDesCampos, aObj[nSelect]:cCodCampo + ' - ' + aObj[nSelect]:cDescCampo)
				aSort(aDesCampos)

				DelPosTela(@aPosTela, nSelect)

				If aObj[nSelect] != NIL
					aObj[nSelect]:Destroy()
				EndIf
			EndIf
		Endif
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DelAll(aObj,nSelect, aDesCampos, aPosTela, oCmbCampos, oCmbConfig)
Função utilizada para deletar todos os objetos de campos da tela.
Uso Geral.

@Param	aObj				Array que contem todos os campo de filtro.
@Param	aDesCampos	Array com as descrições dos campos.
@Param	aPosTela		Matriz que controla a posição dos campos na tela.
@Param	oCmbCampos	Combo dos campos.
@Param	oCmbConfig  Combo das configurações.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DelAll(aObj, nSelect,aDesCampos, aPosTela, oCmbCampos, oCmbConfig)
	Local nTotal := LEN(aObj)
	Local nI
	For nI := 1 to nTotal
		Del(aObj, nI, @aDesCampos, @aPosTela)
	Next

	//Atualização do array de posições dos campos
	aPosTela := {}
	aSize(aPosTela,0) // Altera o tamanho de um array já existente diminuindo-o.

	aObj := {}
	aSize(aObj,0) // Altera o tamanho de um array já existente diminuindo-o.
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCposNVH(oCmbLstTp)
Função utilizada para retornar todos os campos da NVH
Uso Geral.
@Param  oCmbLstTp   Objeto contem o tipo de Pesquisa
@Return	aCmpDesc	Array com todos os campos da NVH(Código e Descrição)

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetCposNVH(oCmbLstTp)

	Local aArea		 := GetArea()
	Local aCmpDesc	 := {}
	Local cDescricao := ""
	Local cQuery	 := ""
	Local aSQL		 := {}
	Local nCont		 := 0

	cQuery := " SELECT NVH_COD, NVH_DESC, NVH_CAMPO"
	cQuery += " FROM " + RetSQLName("NVH")
	cQuery += " WHERE NVH_FILIAL = '" + xFilial("NVH")   + "' "
	cQuery += 	" AND NVH_TPPESQ = '" + oCmbLstTp:cValor + "' "
	cQuery += 	" AND D_E_L_E_T_ = ' ' "

	aSQL := JurSQL(cQuery, "*")

	For nCont:=1 To Len(aSQL)

		If __Language == 'PORTUGUESE'
			cDescricao := aSQL[nCont][2]
		Else
			cDescricao := JA160X3Des(aSQL[nCont][3])
		EndIf

		Aadd(aCmpDesc, {aSQL[nCont][1], aSQL[nCont][1] + ' - ' + cDescricao, cDescricao} )
	Next nCont

	aSize(aSQL, 0)
	RestArea(aArea)

Return aCmpDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} PosTela(aPosTela, nSelect)
Função utilizada para determinar aonde serão colocados os objetos de campos na tela.
Uso Geral.

@Param		aPosTela	Matriz que controla a posição dos campos na tela.
@Param		nSelect		Variavél com a posição do objeto no array aOBJ.
@Return		aRet			Array com as posições para o objeto(Top, Left)

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PosTela(aPosTela, nSelect)
	Local nX,nY
	Local lLivre := .F.
	Local aRet := {,}

	For nX:=1 to LEN(aPosTela)
		For nY := 1 to 6
			if aPosTela[nX][nY] == ''
				lLivre := .T.
				aRet[1] := (nX*25)-25
				aRet[2] := (nY*60)-59
				aPosTela[nX][ny] := AllTrim(STR(nSelect))
				Exit
			EndIf
		Next
		IF lLivre
			Exit
		EndIf
	Next

	IF !(lLivre)
		aAdd( aPosTela, {AllTrim(STR(nSelect)),'','','','',''} )
		aRet[1] := (LEN(aPosTela)*25)-25
		aRet[2] := 1
	EndIF

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DelPosTela(aPosTela, nSelect)
Função utilizada para deletar o objeto de campo da tela.
Uso Geral.

@Param		aPosTela	Matriz que controla a posição dos campos na tela.
@Param		nSelect		Variavél que indica qual objeto esta em foco para ser deletado.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DelPosTela(aPosTela, nSelect)
	Local nX,nY

	For nX:=1 to LEN(aPosTela)
		For nY := 1 to 6
			if aPosTela[nX][nY] == AllTrim(STR(nSelect))
				aPosTela[nX][ny] := ''
				EXIT
			EndIf
		Next
	Next

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GetNomesConf()
Função utilizada para pegar as configurações de layout.
Uso Geral.

@Return		aRet	configurações de layout.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetNomesConf(oCmbLstTp)
	Local nX, nY, aRet := {}
	Local nQtdReg	:= JurQtdReg('NVG')
	Local cDesc
	Local cCod

	aConfPesq := {}

	If Empty(aRet) .Or. aScan(aRet,PADR('',  LEN(NVG->NVG_CPESQ)+LEN(NVG->NVG_DESC))) == 0
		aAdd(aRet, '')
		aAdd(aConfPesq, {'',''})
	EndIF

	DbSelectArea("NVG")
	NVG->(DBSetOrder(1))
	NVG->(dbGoTop())
	For nX := 1 to nQtdReg
		cDesc		:= NVG->NVG_DESC
		cCod		:= NVG->NVG_CPESQ
		lPossui := .F.

		For nY := 1 to LEN(aRet)
			IF aRet[nY] == cCod+'-'+cDesc
				lPossui := .T.
			EndIf
		Next
		If oCmbLstTp:cValor==NVG->NVG_TPPESQ
			if !(lPossui)
				aAdd(aRet,cCod+'-'+cDesc)
				aAdd(aConfPesq, {cCod, cDesc})
			EndIf
		Endif
		NVG->(dbSkip())
	Next

	/*If Empty(aRet) .Or. aScan(aRet,PADR('',  LEN(NVG->NVG_CPESQ)+LEN(NVG->NVG_DESC))) == 0
		aAdd(aRet, '')
		aAdd(aConfPesq, {'',''})
EndIF*/

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NovaConf(oGet, oCmbConfig)
Função utilizada para habilitar a inclusão de uma nova configuração.
Uso Geral.

@Param	oGet				Campo para informar o nome da configuração.
@Param	oCmbConfig	Combo das configurações.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function NovaConf(oGet, oCmbConfig, oCmbLstTp)

	oCmbConfig:Select(1)

	oCmbLstTp:Disable()
	oCmbConfig:Disable()

	oGet:cText := PADR('', LEN(oGet:cText))
	oGet:Refresh()
	oGet:lVisible := .T.

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} CancelConf(oGet, oCmbConfig)
Função utilizada para cancelar a nova configuração.
Uso Geral.

@Param	oGet				Campo para informar o nome da configuração.
@Param	oCmbConfig	Combo das configurações.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CancelConf(oGet, oCmbConfig, oCmbLstTp, bDelAll)

	//Apaga todos os campos que estão na tela.
	MsgRun(STR0033,STR0034,{|| Eval(bDelAll) }) //"Atualizando..." e "Configurador"

	oGet:lVisible := .F.
	oCmbLstTp:Enable()
	oCmbConfig:Enable()
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} SalvaConf(oGet, aPosTela, aObj, cDescConf)
Função utilizada para salvar a configuração.
Uso Geral.

@Param	oGet				Campo para informar o nome da configuração.
@Param	aPosTela		Array com o numero do objeto.
@Param	aObj				Array com todos os campos de filtro da tela.
@Param	oCmbConfig	Combo das configurações.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SalvaConf(oGet, aPosTela, aObj, cDescConf, oCmbLstTp/*, oGetC*/)
	Local nX, nY, nObjeto
	Local cTpPesq 	:= oCmbLstTp:cValor
	Local cNewReg 	:= ''
	Local cNewCPesq := ''
	Local cAntCPesq	:= ''
	Local lGetNext  := .T.
	Local cPesq		:= J163GetPesq()
	Local lRet		:= .T.
	Local nCnt		:= 0 //contador dos campos em geral

	ProcRegua(Len(aObj))


	NVG->(DBSetOrder(1))
	NVG->(dbGoTop())
	If NVG->( dbSeek( XFILIAL('NVG') + cPesq ))
		cAntCPesq := cPesq
	EndIf

	If !oGet:lVisible .Or. !Empty(oGet:cText)
		If !ExisteConfg(IIF(oGet:lVisible, oGet:cText, cDescConf))

			If Empty(Alltrim(cAntCPesq))
				NVG->(DBSetOrder(1))
				NVG->(dbGoTop())
				While .T.
					cNewCPesq	:= JA163NewCPq()
					If !NVG->( dbSeek( XFILIAL('NVG') + cNewCPesq ))
						Exit
					EndIf
				End
			Else
				cNewCPesq := cAntCPesq
			EndIf

			cPesq := J163GetPesq(2) //retirado do loop para diminuir as chamadas da função que preenche o campo NVG-NVG_DESC.

			For nX:= 1 to LEN(aPosTela)
				For nY:= 1 to LEN(aPosTela[nX])
					nObjeto := Val(aPosTela[nX][nY])
					If !Empty(nObjeto) .And. !(aObj[nObjeto] == NIL)
						lGetNext := .T.
						NVG->(DBSetOrder(3))
						While lGetNext
							cNewReg := GetSXEnum("NVG","NVG_COD",,2)

							If !(NVG->( dbSeek( XFILIAL('NVG') + cNewReg )))
								lGetNext := .F.
							EndIf

							If lGetNext
								ConfirmSX8()
							EndIf
						EndDo

						RecLock( 'NVG', .T. )
						NVG->NVG_COD	:= cNewReg
						NVG->NVG_CPESQ	:= cNewCPesq//IIF(!(oGetC:cText == PADR('', LEN(oGetC:cText))) .And. oGetC:lVisible, oGetC:cText, cNewCPesq)
						NVG->NVG_DESC	:= IIF(!(oGet:cText == PADR('', LEN(oGet:cText))) .And. oGet:lVisible, oGet:cText, cPesq)
						NVG->NVG_CCAMPO	:= aObj[nObjeto]:cCodCampo
						NVG->NVG_SUGEST	:= TransValor(aObj[nObjeto])
						NVG->NVG_VISIVE	:= aObj[nObjeto]:lVisible
						NVG->NVG_ENABLE	:= aObj[nObjeto]:lEnable
						NVG->NVG_TPPESQ	:= cTpPesq
						NVG->(MsUnlock())

						IF __lSX8
							ConfirmSX8()
						Else
							RollBackSX8()
						EndIf
					EndIf

					nCnt := nCnt+1
					IncProc(I18N(STR0095,{AllTrim(str(nCnt)),Alltrim(str(Len(aObj)))} )) //"Processando registro #1 de #2"
				Next nY
			Next nX

			oGet:lVisible := .F.
			oCmbLstTp:Enable()
		Else
			oGet:lVisible := .F.
			oCmbLstTp:Enable()
		EndIf

	Else
		Alert(STR0023) //"A descrição da configuração deve ser informada!"
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TransValor(oObj)
Função utilizada para transformar o valor em string para que seja
possível montar a Query.
Uso Geral.

@Param	oObj	Variável de objeto de campo filtro.
@Return	cRet	Valor da convertida para ser rodada na Query.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TransValor(oObj)
	Local cRet := ''
	Local cTipo := oObj:AINFOCAMPO[2]

	Do case
	Case cTipo == 'D'
		cRet := DToC(oObj:Valor)
	Case cTipo == 'N'
		cRet := STR(oObj:Valor)
	Case cTipo == 'C' .Or. cTipo == 'M'
		cRet := oObj:Valor
	End Case

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ExisteConfg(cDescConfi)
Função utilizada para verificar se já existe a configuração.
Uso Geral.

@Param	cDescConfi	Descrição da configuração.
@Return	lExiste			Indica se existe ou não.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ExisteConfg(cDescConf)
	Local lExiste := .F.
	Local cPesq   := J163GetPesq()

	NVG->(DBSetOrder(1))
	NVG->(dbGoTop())

	if !Empty(Alltrim(cPesq)) .And. NVG->( DBSeek(XFILIAL('NVG') + cPesq) )
		if ApmsgYesNo(STR0024, STR0025) //"Este nome de configuração já existe! Deseja sobrescrever?" e "Alerta"
			ApagaConf(cDescConf, .T.)
			lExiste := .F.
		Else
			lExiste := .T.
		EndIF

	ElseIf Empty(cPesq).and.DuplPesq(cDescConf) //<-Verifica na inclusão, possivel duplicidade de acordo com o perfil de pesq ->
		JurMsgErro(STR0086)//"Configuração já existente. Verifique! "
		lExiste := .T.
	EndIf

Return lExiste

//-------------------------------------------------------------------
/*/{Protheus.doc} ApagaConf(cDescConfig, lApagarDireto)
Função utilizada para apagar configuração.
Uso Geral.

@Param	cDescConfig		Descrição da configuração.
@Param	lApagarDireto	Indica se será apagado direto.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ApagaConf(cDescConf, lApagarDireto)
	Local cPesq   := J163GetPesq()
	Local lExiste := .F.

	Default lApagarDireto := .F.

	If !Empty(cDescConf)
		If lApagarDireto .Or. ApmsgYesNo(STR0026, STR0025) //"Realmente deseja apagar a Configuração?" e "Alerta"

			NVK->(dbsetorder(3))
			If !lApagarDireto .And. NVK->( DBSeek(XFILIAL('NVK') + cPesq) )
				lExiste := .T.
				Alert(STR0070)//"Existe configuração de Usuários x Pesquisa vinculada a está pesquisa. Verifique! Operação cancelada!"
			EndIf

			If !lExiste
				NVJ->(dbsetorder(2))
				If !lApagarDireto .And. NVJ->( DBSeek(XFILIAL('NVJ') + cPesq) )
					lExiste := .T.
					Alert(STR0071)//"Existe configuração de Assuntos Juridicos x Pesquisa vinculada a está pesquisa. Verifique! Operação cancelada!"
				EndIf
			EndIf

			If !lExiste
				NVG->(DBSetOrder(1))
				NVG->(dbGoTop())
				While NVG->( DBSeek(XFILIAL('NVG') + cPesq ) )
					RecLock( 'NVG',.F. )
					DBDelete()
					MsUnlock()
					IIF(__lSX8, ConfirmSX8(), )
				End
			EndIf
		EndIf
	Else
		Alert(STR0042) //Selecione a pesquisa a ser apagada, operação abortada!
	Endif

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} RefazTela(aObj, oBtnDelAll, oBtnAdd, oCmbCampos, oCmbConfig,oCmbLstTp)
Função utilizada para refazer o layout de tela.
Uso Geral.

@Param		aObj				Array que contem todos os campo de filtro.
@Param		oBtnDelAll  Botão para remover todos os objetos de campo da tela.
@Param		oBtnAdd			Botão para adicionar objetos de campo na tela.
@Param		oCmbCampos	Combo com as descrições de campos.
@Param		oCmbConfig	Combo que contém as configurações de Layout.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RefazTela(aObj, oBtnDelAll, oBtnAdd, oCmbCampos, oCmbConfig,oCmbLstTp, lNewCfg)
	Local nI
	Local nItem
	Local cDescConf
	Local aCampos 	:= {}
	Local cCodCampo := ""

	Default lNewCfg := .F.

	nItem := oCmbConfig:GetnAt()

	if LEN(oCmbConfig:aItems) > 0 .And. nItem > 0
		cDescConf := oCmbConfig:aItems[nItem]

		MsgRun(STR0033,STR0034,{|| Eval(oBtnDelAll:bAction) }) //"Atualizando..." e "Configurador"

		If !(cDescConf == PADR('', LEN(cDescConf))) //Valida se foi selecionada alguma configuração

			//<- Edição ou uma nova configuração de pesquisa. ->
			lNewCfg := .T.

			NVG->(DBSetOrder(4))
			NVG->(dbGoTop())
			IF NVG->( DBSeek(XFILIAL('NVG') + J163GetPesq()))

				NVH->(DBSetOrder(1))
				While !(NVG->(Eof())) .And. (Alltrim(NVG->NVG_DESC) == Alltrim(J163GetPesq(2)))
					If Alltrim(oCmbLstTp:cValor)==Alltrim(NVG->NVG_TPPESQ)
						IF NVH->( DBSeek(XFILIAL('NVH') + NVG->NVG_CCAMPO) )
							aADD( aCampos, { NVH->NVH_COD, NVH->NVH_DESC } )
						EndIf
					Endif
					NVG->(dbSkip())
				End

				If LEN(aCampos) > 0
					For nI := 1 to LEN(aCampos)
						lAddRef   := .T.
						cCodCampo := aCampos[nI][1]	//Pega o codigo do campo
						oCmbCampos:Select(aScan(oCmbCampos:aItems, JA163ReFormat(aCampos[nI][2],oCmbLstTp:cValor)))
						oCmbCampos:Refresh()
						Eval(oBtnAdd:bAction, , cCodCampo)	//Passa o codigo do campo para o bloco de codigo
					Next
				EndIf

			EndIf

		EndIF
		SetFocusCpo(aObj)
	EndIF

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} AtuCampos(oListTable, oListCampo)
Função utilizada para atualizar os campos referente a tabela selecionada
no oListTable.
Uso Geral.

@Param		oListTable	Lista com tabelas relacionadas a NSZ.
@Param		oListCampo	Campos relacionada na tabela selecionada.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuCampos(oListTable, oListCampo, aBtnBar)
	Local nAt := Iif(oListTable:nAt == 0, 1, oListTable:nAt)
	Local cTabela := SUBSTRING(oListTable:aItems[nAt],1,3)
	Local bBloco  := &( '{ || '+cTabela+'->( DbStruct() ) }' )
	Local nI

	dbSelectArea( cTabela )
	aStruct := eval( bBloco )

	aStruct := ASORT(aStruct, , , { | x,y | x[1] < y[1] } )

	oListCampo:Reset()
	oListCampo:aItems := {}
	aSize(oListCampo:aItems, 0)

	For nI := 1 to LEN(aStruct)
		oListCampo:Add( aStruct[nI][1]+' ('+AllTrim(rettitle(aStruct[nI][1]))+')', LEN(oListCampo:aItems) )
	Next
	oListCampo:Select(1)

	aBtnBar[6]:lActive := .T.

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} ListaHead()
Função utilizada para atualizar o cabeçalho e os registros da lista(Grid)
Uso Geral.

@Return	aRet	Array com o cabeçlho e os registros das colunas.(aHeader e aCol)

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ListaHead()
	Local aRet   := {,}
	Local aHead  := {}
	Local aCol   := {}
	Local aArea  := GetArea()
	Local aAreaSx3 := SX3->(GetArea())
	Local nX     := 0
	Local nUsado := 0
	Local nCols  := 0

	aRet := Array(2)

	dbSelectArea( 'SX3' )
	SX3->( dbSetOrder( 1 ) )
	SX3->( dbSeek( 'NVH' ) )

	aStru := NVH->( dbStruct() )

	While !SX3->( EOF() ) .AND. SX3->X3_ARQUIVO == 'NVH'
		If X3USO( SX3->X3_USADO ) .AND. cNivel >= SX3->X3_NIVEL
			nUsado++
			aAdd( aHead, { ;
				AllTrim( X3Titulo() ), ;  // 01 - Titulo
			SX3->X3_CAMPO      , ;    // 02 - Campo
			SX3->X3_PICTURE    , ;    // 03 - Picture
			SX3->X3_TAMANHO    , ;    // 04 - Tamanho
			SX3->X3_DECIMAL    , ;    // 05 - Decimal
			SX3->X3_VALID      , ;    // 06 - Valid
			SX3->X3_USADO      , ;    // 07 - Usado
			SX3->X3_TIPO       , ;    // 08 - Tipo
			SX3->X3_F3         , ;    // 09 - F3
			SX3->X3_CONTEXT   , ;    // 10 - Contexto
			""                  , ;    // 11 - ComboBox // SX3->X3_CBOX
			SX3->X3_RELACAO    , ;    // 12 - Relacao
			SX3->X3_WHEN       , ;    // 13 - Alterar
			SX3->X3_VISUAL     , ;    // 14 - Visual
			SX3->X3_VLDUSER      } )  // 15 - Valid Usuario

		EndIf
		SX3->( dbSkip() )
	End

	dbSelectArea('NVH')
	NVH->( dbSetOrder(2) )
	NVH->(dbGoTop())

	While NVH->(!Eof())
		aAdd(aCol,Array(nUsado+1))
		nCols ++

		For nX := 1 To nUsado
			If ( aHead[nX][10] != "V")
				aCol[nCols][nX] := NVH->(FieldGet(FieldPos(aHead[nX][2])))
			Else
				aCol[nCols][nX] := CriaVar(aHead[nX][2],.T.)
			Endif
		Next nX

		aCol[nCols][nUsado+1] := .F.
		NVH->(dbSkip())
	End

	aRet[1] := aHead
	aRet[2] := aCol

	RestArea( aArea )
	RestArea( aAreaSx3 )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetCampo(cTexto, lAlteracao, oEnchoice)
Função utilizada para setar valorer no oEnchoice.
Uso Geral.

@Param	cTexto			Valor do campo selecionado na lista de campos.
@Param	lAlteracao	Indica se o Botão salvar esta habilitado.
@Param	oEnchoice		Objeto Enchoice.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetCampo(cTexto, lAlteracao, oEnchoice)
	Local cTabela := SUBSTRING(cTexto,1,3)
	Local cCampo  := SUBSTRING(cTexto,1,aT('(',cTexto)-2)

	if lAlteracao
		M->NVH_TABELA := RetSqlName(cTabela)
		M->NVH_CAMPO  := PADR(cCampo, LEN(NVH->NVH_CAMPO),'')
		If Empty(M->NVH_DESC)
			M->NVH_DESC := PADR(StrTran(SUBSTR(cTexto, aT('(',cTexto)+1 ), ')',''), LEN(NVH->NVH_DESC))
		EndIf
		If Empty(M->NVH_WHERE)
			M->NVH_WHERE := 'AND '+RetSqlName(cTabela)+'.'+cCampo+' = #'+STR0019+'#' //"DADO"
		EndIf
	EndIf
	oEnchoice:Refresh()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} BtnsAlteracao(lAlteracao, aBtnBar)
Função utilizada para controlar os botões de ação.
Uso Geral.

@Param	lAlteracao	Indica se esta em alteração.
@Param	aBtnBar			Array com todos os botões da barra de botões.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BtnsAlteracao(lAlteracao, aBtnBar)

	aBtnBar[INCLUIR]:bWhen  := {|| !(lAlteracao)}
	aBtnBar[ALTERAR]:bWhen  := {|| !(lAlteracao)}
	aBtnBar[EXCLUIR]:bWhen  := {|| !(lAlteracao)}
	aBtnBar[SALVAR]:bWhen   := {|| lAlteracao}
	aBtnBar[CANCELAR]:bWhen := {|| lAlteracao}
	aBtnBar[INCLUIR]:Refresh()
	aBtnBar[ALTERAR]:Refresh()
	aBtnBar[EXCLUIR]:Refresh()
	aBtnBar[SALVAR]:Refresh()
	aBtnBar[CANCELAR]:Refresh()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuMsMGet(oEnchoice, nAcao, oLstNVH, aBtnBar)
Função utilizada para controlar as ações de INCLUIR, ALTERAR,
EXCLUIR, SALVAR, CANCELAR e VISUALIZAR.
Uso Geral.

@Param	oEnchoice	Objeto Enchoice.
@Param	nAcao			Tipo de ação(INCLUIR=1;ALTERAR=2;EXCLUIR=3;SALVAR=4;CANCELAR=5;VISUALIZAR=6)
@Param	oLstNVH		Objeto de lista(Grid)
@Param	aBtnBar		Array com todos os botões da barra de botões.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuMsMGet(oEnchoice, nAcao, oLstNVH, aBtnBar)
Local cCod		:= GetVlrCol(oLstNVH, 1) //Código
Local lCancel	:= .F.
Local aListaHC
Local lIncluiAltera
Local nSaveSX8	:= GetSX8Len()		// Número q registrará qtos elementos devera ser salvos na SX8
Local lNVHLabel := .F.

	DbSelectArea("NVH")
	lNVHLabel := FieldPos("NVH_LABEL") > 0
//INCLUIR = 1; ALTERAR = 2; EXCLUIR = 3; SALVAR = 4; CANCELAR = 5; VISUALIZAR = 6
	if aBtnBar[INCLUIR]:lActive .Or. nAcao == SALVAR .Or. nAcao == CANCELAR .Or. (aBtnBar[INCLUIR]:lActive .And. nAcao == VISUALIZAR)

		Do Case
		Case nAcao == INCLUIR // Incluir
			M->NVH_COD    := GetSXENUM('NVH', 'NVH_COD')
			M->NVH_DESC   := CriaVAR('NVH_DESC')
			M->NVH_TABELA := CriaVAR('NVH_TABELA')
			M->NVH_CAMPO  := CriaVAR('NVH_CAMPO')
			M->NVH_WHERE  := CriaVAR('NVH_WHERE')
			M->NVH_F3DIF  := CriaVAR('NVH_F3DIF')
			M->NVH_F3CONS := CriaVAR('NVH_F3CONS')
			M->NVH_RETF3  := CriaVAR('NVH_RETF3')
			M->NVH_F3MULT := CriaVAR('NVH_F3MULT')
			M->NVH_TPPESQ  := CriaVAR('NVH_TPPESQ')
			If lNVHLabel
				M->NVH_CHAVE  := CriaVAR('NVH_CHAVE')
				M->NVH_LABEL  := CriaVAR('NVH_LABEL')
			EndIf
			BtnsAlteracao(.T., @aBtnBar)

		Case nAcao == VISUALIZAR .Or. nAcao == ALTERAR .Or. nAcao == CANCELAR //Visualizar, Alterar e Cancelar
			If !Empty(cCod)
				NVH->(dbsetorder(1))
				NVH->( DBSeek(XFILIAL('NVH') + cCod) )
				M->NVH_COD    := NVH->NVH_COD
				M->NVH_DESC   := NVH->NVH_DESC
				M->NVH_TABELA := NVH->NVH_TABELA
				M->NVH_CAMPO  := NVH->NVH_CAMPO
				M->NVH_WHERE  := NVH->NVH_WHERE
				M->NVH_F3DIF  := NVH->NVH_F3DIF
				M->NVH_F3CONS := NVH->NVH_F3CONS
				M->NVH_RETF3  := GetRetornoF3(NVH->NVH_CAMPO, NVH->NVH_F3DIF, NVH->NVH_F3CONS)
				M->NVH_TPPESQ := NVH->NVH_TPPESQ
				M->NVH_F3MULT := NVH->NVH_F3MULT
				If lNVHLabel
					M->NVH_CHAVE  := NVH->NVH_CHAVE
					M->NVH_LABEL  := NVH->NVH_LABEL
				EndIf
				BtnsAlteracao((nAcao == ALTERAR), @aBtnBar)
			Else
				lCancel := .T.
			EndIf

		Case nAcao == EXCLUIR //Excluir

			if VerifNVG(cCod)
				NVH->(dbsetorder(1))
				NVH->( DBSeek(XFILIAL('NVH') + cCod) )

				If NVH->NVH_PROPRI == .F.
					RecLock( 'NVH',.F. )
					DBDelete()
					NVH->( MsUnlock() )

					//<- ConfirmSx8 somente dos códigos que foram efetuados no escopo da função 'AtuMsMGet' ->
					If __lSX8
						While ( GetSX8Len() > nSaveSx8 )
							ConfirmSx8()
						End
					EndIf
				Else
					lCancel := .T.
					Alert(STR0027) //"Esta configuração de campo não pode ser alterada(Uso interno). Operação cancelada!"
				EndIf
			Else
				lCancel := .F.
			EndIf

		Case nAcao == SALVAR // Salvar
			If !(Empty(M->NVH_DESC) .Or. Empty(M->NVH_TABELA) .Or. Empty(M->NVH_CAMPO) /* .Or. Empty(M->NVH_WHERE)*/)

				If M->NVH_CAMPO <> "NT9_ENTIDA"

					DbSelectArea("NVH")
					NVH->(dbsetorder(1))
					If NVH->( DBSeek(XFILIAL('NVH') + M->NVH_COD) ) .Or. !(ExisteDesc(M->NVH_DESC, M->NVH_TPPESQ)) //.Or. !(ExisteDesc(M->NVH_TPPESQ))

						If M->NVH_F3MULT
							//<- Valida se há a existência da expressão 'IN' dentro do campo NVH_WHERE ->
							If AT(" IN", UPPER( M->NVH_WHERE ) ) < 1
								lCancel := .T.
								JurMsgErro( STR0072+CRLF+CRLF+STR0073) // "Atenção!" e " Ao utilizar o F3 com retorno multiplo, a condição do campo deverá conter os operadores IN (#DADO#) ou NOT IN (#DADO#)"
							EndIf
						EndIf

						//<- Valição da expressão 'LIKE' dentro do campo NVH_WHERE ->
						If AT(" LIKE", UPPER( M->NVH_WHERE ) ) > 0
							If AT("DADO_LIKE", UPPER( M->NVH_WHERE ) ) < 1 // Não encontrado a expressão DADO_LIKE
								lCancel := .T.
								JurMsgErro( STR0072+CRLF+CRLF+ STR0089 ) //"Atenção" e " Ao utilizar a expressão 'LIKE' no campo Condição é obrigatório o uso de 'DADO_LIKE' "
							EndIf
						EndiF

						If !( lCancel )
							NVH->(dbsetorder(1))
							lIncluiAltera := !NVH->( DBSeek(XFILIAL('NVH') + M->NVH_COD) )

							If !(NVH->NVH_PROPRI == .T.)
								RecLock( 'NVH', lIncluiAltera ) // Inclui := .T. || Altera := .F.
								NVH->NVH_COD    := M->NVH_COD
								NVH->NVH_DESC   := M->NVH_DESC
								NVH->NVH_TABELA := M->NVH_TABELA
								NVH->NVH_CAMPO  := M->NVH_CAMPO
								NVH->NVH_WHERE  := M->NVH_WHERE
								NVH->NVH_F3DIF  := M->NVH_F3DIF
								NVH->NVH_F3CONS := M->NVH_F3CONS
								NVH->NVH_TPPESQ := M->NVH_TPPESQ
								NVH->NVH_F3MULT := M->NVH_F3MULT
								If lNVHLabel
									NVH->NVH_CHAVE := M->NVH_CHAVE
									NVH->NVH_LABEL := M->NVH_LABEL
								EndIf
								NVH->( MsUnlock() )

								//<- ConfirmSx8 somente dos códigos que foram efetuados no escopo da função 'AtuMsMGet' ->
								If __lSX8
									While ( GetSX8Len() > nSaveSx8 )
										ConfirmSx8()
									End
								EndIf

								BtnsAlteracao(.F., @aBtnBar)
							Else
								lCancel := .T.
								Alert(STR0027) //"Esta configuração de campo não pode ser alterada(Uso interno). Operação cancelada!"
							EndIf
						EndIf
					Else
						lCancel := .T.
						Alert(STR0028) //"A descrição informada já existe este tipo de pesquisa!"
					Endif
				Else
					lCancel := .T.
					Alert(STR0124) //"Este campo é usado para diferentes pesquisas por entidades, portanto ele não pode ser configurado por Assunto Jurídico."
				Endif
			Else
				lCancel := .T.
				Alert(STR0029) //"Todos os campos devem ser preenchidos! Verifique."
			EndIf
		End Case

		If !(lCancel) .And. oEnchoice <> NIL

			IF nAcao == EXCLUIR .Or. nAcao == SALVAR
				aListaHC := ListaHead()
				oLstNVH:ACOLS   := aClone(aListaHC[2])
				If nAcao == SALVAR
					oLstNVH:nAt   := aScan(oLstNVH:ACOLS, { |aX| ALLTRIM(aX[1]) == NVH->NVH_COD})
				EndIf
				oLstNVH:Refresh()
				oLstNVH:goTop()
			EndIf

			oEnchoice:lActive := !(nAcao == VISUALIZAR .Or. nAcao == SALVAR .Or. nAcao == CANCELAR .Or. nAcao == EXCLUIR)
			oEnchoice:Refresh()

			IF nAcao == EXCLUIR .Or. nAcao == SALVAR
				AtuMsMGet(oEnchoice, VISUALIZAR, oLstNVH, @aBtnBar)
			EndIf

		EndIf

	Endif

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} ExisteDesc(cDesc)
Função utilizada para verificar se a descrição de campo já existe.
Uso Geral.

@Param	cDesc		Descrição do campo.
@Return	Boolean	Indica se existe ou não .T./.F.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ExisteDesc(cDesc, cTipo)
	NVH->(dbsetorder(2))
Return NVH->( DBSeek(XFILIAL('NVH') + cDesc + cTipo) )

//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} VerifNVG(cCod)
Função utilizada para verificar se o campo esta sendo utilizado em alguma
configuração de layout.
Uso Geral.

@Param	cCod	código do campo.
@Return	lRet	Indica se esta sendo utilizado ou não .T./.F.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VerifNVG(cCod)
	Local lRet := .T., lExiste := .F.
	Local nQtdReg := JurQtdReg('NVG')
	Local nI
	Local cConfigs := ''

	If !cCod == ''
		NVG->( DBSetOrder(1) )
		NVG->(dbGoTop())
		For nI := 1 to nQtdReg

			if NVG->NVG_CCAMPO == cCod
				lExiste := .T.
				IF cConfigs == ''
					cConfigs := Alltrim(NVG->NVG_DESC)
				Else
					cConfigs += ', ' + Alltrim(NVG->NVG_DESC)
				EndIf
			endif
			NVG->(dbSkip())

		Next

		IF lExiste
			//"Este campo configurado é utilizado nas seguintes configurações de tela:"
			//"Realmente deseja excluir o campo configurado?" e "Alerta"
			lRet := ApmsgYesNo(STR0030 +' '+ cConfigs+CRLF + STR0031, STR0025)
		Else
			lRet := ApmsgYesNo(STR0031, STR0025) //"Realmente deseja excluir o campo configurado?" e "Alerta"
		EndIF
	Else
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetCpoMemory(aObj)
Função utilizada para setar todos as variáveis de memória referente
aos campos de filtro da tela.
Uso Geral.

@Param	aObj	Array que contem todos os campo de filtro.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetCpoMemory(aObj)
	Local nI

	For nI := 1 to LEN(aObj)
		If !(aObj[nI] == NIL)
			M->&(aObj[nI]:cNomeCampo) := aObj[nI]:Valor
		EndIf
	Next

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} LimpaPesq(aObj)
Função utilizada para limpar todos os campos de filtro e voltar o
valor padrão se tiver.
Uso Geral.

@Param	aObj			Array que contem todos os campo de filtro.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LimpaPesq(aObj)
	Local nI
	For nI := 1 to LEN(aObj)
		if !(aObj[nI] == NIL) .And. !(aObj[nI]:Valor == aObj[nI]:VlrDefault)
			aObj[nI]:Valor := aObj[nI]:VlrDefault
		EndIF
	Next
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GetVlrCol(oLst, nCol)
Função utilizada para pegar o valor de certa coluna da lista(Grid).
Uso Geral.

@Param	oLst		Lista(Grid)
@Param	nCol		Numero da coluna.
@Return	Valor		Valor da coluna.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetVlrCol(oLst, nCol)
Return IIF(oLst:NAT == 0 .Or. oLst:NAT == NIL .Or. LEN(oLst:aCols) == 0, '', oLst:aCols[oLst:NAT][nCol])

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR163F3PESQ
Customiza a consulta padrão do
Uso na configuração de pesquisa

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Felipe Bonvicini Conti
@since 14/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR163F3PESQ()
	Local lRet := .F.
	Local cQuery, cTabela := RetSqlName('NVG')
	Local uRetorno

	cQuery := " SELECT NVG_CPESQ, NVG_DESC, MAX( R_E_C_N_O_ ) NVGRECNO "
	cQuery += "   From " + cTabela+ " NVG "
	cQuery += "  Where NVG_FILIAL = '" +xFilial('NVG')+ "' "
	cQuery += "    AND NVG.D_E_L_E_T_ = ' ' "
	cQuery += "  GROUP BY NVG_FILIAL, NVG_CPESQ, NVG_DESC"
	cQuery += "  ORDER BY NVG_FILIAL, NVG_CPESQ, NVG_DESC"

	cQuery := ChangeQuery(cQuery, .F.)

	uRetorno := ''
	NVG->(DBSetOrder(1))
	If JurF3Qry( cQuery, 'JUR163F3PESQ', 'NVGRECNO', @uRetorno,,,,,,,'NVG')
		NVG->( dbGoto( uRetorno ) )
		lRet := .T.
	EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR163F3CP
Customiza a consulta padrão do
Uso na configuração de pesquisa

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Felipe Bonvicini Conti
@since 14/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR163F3CP()
	Local lRet := .F.
	Local cQuery, cTabela := RetSqlName('NVG')
	Local uRetorno

	cQuery := " SELECT NVG_CPESQ, NVG_DESC, MAX( R_E_C_N_O_ ) NVGRECNO "
	cQuery += "   FROM " + cTabela+ " NVG "
	cQuery += "  WHERE NVG_FILIAL = '" +xFilial('NVG')+ "' "
	cQuery += "    AND NVG.D_E_L_E_T_ = ' ' "
	cQuery += "  GROUP BY NVG_FILIAL, NVG_CPESQ, NVG_DESC"
	cQuery += "  ORDER BY NVG_FILIAL, NVG_CPESQ, NVG_DESC"

	cQuery := ChangeQuery(cQuery, .F.)

	uRetorno := ''
	NVG->(DBSetOrder(1))
	If JurF3Qry( cQuery, 'JUR163F3CP', 'NVGRECNO', @uRetorno,,,,,,,'NVG')
		NVG->( dbGoto( uRetorno ) )
		lRet := .T.
	EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetXY(aPosTela, nSelect)
Função utilizada para pegar a posição do objeto no array que controla as
posições dos objetos de campo na tela.
Uso Geral

@Param	aPosTela	Matriz que controla a posição dos campos na tela.
@Param	nSelect		Variavél que controla qual objeto esta em foco.
@Return aRet			Posição do Objeto de campo.

@author Felipe Bonvicini Conti
@since 14/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetXY(aPosTela, nSelect)
	Local nX, nY, aRet := {,}
	Local lAchou := .F.

	For nX := 1 to LEN(aPosTela)
		For nY := 1 to LEN(aPosTela[nX])
			IF aPosTela[nX][nY] == Alltrim(nSelect)
				aRet[1] := nX
				aRet[2] := nY
				lAchou := .T.
				Exit
			EndIf
		Next

		If lAchou
			Exit
		EndIf
	Next

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TrocaPos(aPosTela, aObj, aXY, aXYDest)
Função utilizada para trocar a posição do objeto de campo na tela.
Uso Geral

@Param	aPosTela	Matriz que controla a posição dos campos na tela.
@Param	aObj			Array que contem todos os campo de filtro.
@Param	aXY				Array com a posição do objeto a ser movido.
@Param	aXYDest		Array com a posição do objeto de destino.

@author Felipe Bonvicini Conti
@since 14/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static function TrocaPos(aPosTela, aObj, aXY, aXYDest)
	Local cOrigem := aPosTela[aXY[1]][aXY[2]]
	Local cDest := aPosTela[aXYDest[1]][aXYDest[2]]
	Local nRowAux, nColAux

	aPosTela[aXYDest[1]][aXYDest[2]] := cOrigem
	aPosTela[aXY[1]][aXY[2]] 				 := cDest

	nRowAux := aObj[VAL(cOrigem)]:nRow
	nColAux := aObj[VAL(cOrigem)]:nCol
	aObj[VAL(cOrigem)]:nRow := aObj[VAL(cDest)]:nRow
	aObj[VAL(cOrigem)]:nCol	:= aObj[VAL(cDest)]:nCol
	aObj[VAL(cDest)]:nRow 	:= nRowAux
	aObj[VAL(cDest)]:nCol	  := nColAux
	aObj[Val(cOrigem)]:Refresh()
	aObj[Val(cDest)]:Refresh()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MoveCampo(aPosTela, aObj, nSelect, nAcao)
Função utilizada para mover o campo na tela.
Uso Geral

@Param	aPosTela	Matriz que controla a posição dos campos na tela.
@Param	aObj			Array que contem todos os campo de filtro.
@Param	nSelect		Variavél que controla qual objeto esta em foco.
@Param	nAcao			Ação da movimentação que será feita.(UP, DOWN, LEFT e RIGHT)

@author Felipe Bonvicini Conti
@since 14/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MoveCampo(aPosTela, aObj, nSelect, nAcao)
	Local aXY 		:= GetXY(aPosTela, STR(nSelect))
	Local aXYDest := {,}
	Local nSelectDest

	If !(aXY[1] == NIL .Or. aXY[1] == NIL)

		Do Case
		Case nAcao == UP
			aXYDest[1] := aXY[1]-1
			aXYDest[2] := aXY[2]

		Case nAcao == DOWN
			aXYDest[1] := aXY[1]+1
			aXYDest[2] := aXY[2]

		Case nAcao == LEFT
			aXYDest[1] := aXY[1]
			aXYDest[2] := aXY[2]-1

		Case nAcao == RIGHT
			aXYDest[1] := aXY[1]
			aXYDest[2] := aXY[2]+1
		End Case

		If !(aXYDest[1] == 0 .Or. aXYDest[2] == 0 .Or.;
				aXYDest[1] > LEN(aPosTela) .Or. aXYDest[2] > LEN(aPosTela[1]) ) .And.;
				!aPosTela[aXYDest[1]][aXYDest[2]] == ''
			nSelectDest := aPosTela[aXYDest[1]][aXYDest[2]]
			TrocaPos(@aPosTela, @aObj, aXY, aXYDest)
		EndIf

	EndIF

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RefazScroll
Função utilizada para recriar panel.
Uso Geral

@Param	oPnl		Panel que será refeito.
@Param	oCmbLstTp   Objeto contem  o tipo de pesquisa
@Param	oCmbConfig	Objeto combo.

@author Felipe Bonvicini Conti
@since 14/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function RefazScroll(oPnl,oCmbLstTp,oCmbConfig)

	Local oParent  := oPnl:oParent
	Local nTam     := 0
	Local nItem    := 0
	Local aDados   := {}
	Local aPos     := {}
	Local aPosTela := {}
	Local nI       := 0

	nItem := oCmbConfig:GetnAt()

	if LEN(oCmbConfig:aItems) > 0 .And. nItem > 0
		aDados := GetCposNVH(oCmbLstTp)

		For nI := 1 to LEN(aDados)
			aPOS := PosTela(@aPosTela,nI)
		Next

		If Len(aPosTela) > 0
			nTam := Len(aPosTela) * 25
		EndIf

		aPosTela := {}
		aPos     := {}

	EndIf

	oParent:ReadClientCoors(.T.,.T.)
	oPnl:FreeChildren()
	If nTam * 2 < oParent:nHeight
		oPnl:nHeight := oParent:nHeight
	Else
		oPnl:nHeight := nTam * 2
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFocusCpo(aObj)
Função utilizada para setar o foco no primeiro campo da tela.
Uso Geral

@Param	aObj	Array com os objetos de campos da tela.

@author Felipe Bonvicini Conti
@since 24/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetFocusCpo(aObj)
	Local nI
	For nI:=1 to LEN(aObj)
		If !aObj[nI] == NIL
			aObj[nI]:oCampo:SetFocus()
			Exit
		EndIf
	Next
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRetornoF3(cCampo, lF3, cF3)
Função utilizada para informar o retorno da consulta padrão do campo selecionado.
Uso Geral

@Param	cCampo	Nome do campo.
@Param	lF3			Indica se será utilizado F3 diferenciado.
@Param	cF3			Nome da consulta padrão diferenciada.

@author Felipe Bonvicini Conti
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetRetornoF3(cCampo, lF3, cF3)
	Local cConsulta := ""
	Local cRet 		  := ""

	If !lF3
		cConsulta := getSx3Cache(cCampo,"X3_F3")
	Else
		cConsulta	:= cF3
	EndIf

	If !Empty(cConsulta)

		cRet := AllTrim(cConsulta) +":"+ CRLF

		dbSelectArea('SXB')
		SXB->( dbSetOrder(1) )
		If SXB->( dbSeek(cConsulta) )

			While SXB->(!Eof()) .And. SXB->XB_ALIAS == cConsulta

				If SXB->XB_TIPO == '5'
					cRet += SXB->XB_CONTEM + CRLF
				EndIf

				SXB->(dbSkip())
			End

		EndIf

	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ClickHead(oLstPesq, nCol, nClicked)
Função utilizada para ordenar o grid.
Uso Geral

@Param	oLstPesq	Objeto lista(Grid).
@Param	nCol			Numero da coluna selecionada.
@Param	nClicked	Numero da ultima coluna selecionada.

@author Felipe Bonvicini Conti
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ClickHead(oLst, nCol, nClicked)
	Local nRet

	If nClicked == nCol
		aSort(oLst:aCols, , , {|x,y| x[nCol] > y[nCol]})
		nRet := 0
	Else
		aSort(oLst:aCols, , , {|x,y| x[nCol] < y[nCol]})
		nRet := nCol
	EndIf
	oLst:Refresh()

Return nRet

Function LstPesq(cRet)
	Local nCont  :=0
	Local aLstPesq:={}
	Local cLstPesq:=""
	Default cRet:="C"

	aAdd(aLstPesq,STR0065) //"1=Processo"
	aAdd(aLstPesq,STR0066) //"2=Follow-Up"
	aAdd(aLstPesq,STR0067) //"3=Garantias"
	aAdd(aLstPesq,STR0068) //"4=Andamento"
	aAdd(aLstPesq,STR0112) //"5=Despesa"
	aAdd(aLstPesq,STR0125) //"6=Documentos"

	For nCont:=1 To Len(aLstPesq)
		cLstPesq+=aLstPesq[nCont]+";"
	Next
	cLstPesq:=Substr(cLstPesq,1,Len(cLstPesq)-1)
Return Iif(Upper(cRet)=="C",cLstPesq,aLstPesq)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA163NewCPq()
Função utilizada para devolver o ultimo reigstro do banco
Uso Geral
@author Clóvis Eduardo Teixeira
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA163NewCPq()
	Local aArea     := GetArea()
	Local cNextCode := '001'
	Local cAliasQry := GetNextAlias()

	BeginSql Alias cAliasQry

    SELECT MAX(NVG_CPESQ) NVG_MAX
      FROM %table:NVG% NVG
     WHERE NVG.NVG_FILIAL = %xFilial:NVG%
       AND NVG.%notDEL%

	EndSql
	dbSelectArea(cAliasQry)

	if !Empty((cAliasQry)->NVG_MAX)
		cNextCode := PadL((Val((cAliasQry)->NVG_MAX) + 1),3,'0')
	Endif

	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)

Return cNextCode

//-------------------------------------------------------------------
/*/{Protheus.doc} JA163Reformat(cDesCampo, nTpPesq)
Função utilizada para reformatar o campo com código e descrição.
Uso Geral
@author Clóvis Eduardo Teixeira
@since 07/04/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA163Reformat(cDesCampo, nTpPesq)
	Local aArea      := GetArea()
	Local cAlias     := GetNextAlias()
	Local cDesReForm := ''
	Local cSQL       := ''

	cSQL  := "SELECT NVH.NVH_COD"
	cSQL  += " FROM "+ RetSqlname('NVH') +" NVH "+CRLF
	cSQL  += " WHERE NVH.NVH_DESC = '"+cDesCampo+"' " +CRLF
	cSQL  += " AND NVH.NVH_FILIAL = '" + xFilial('NVH') + "'"+CRLF
	cSQL  += " AND NVH.NVH_TPPESQ = '"+nTpPesq+"' " +CRLF
	cSQL  += " AND NVH.D_E_L_E_T_ = ' ' ";

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlias, .T., .F.)

	If !Empty((cAlias)->NVH_COD)
		cDesReForm := (cAlias)->NVH_COD + ' - ' + cDesCampo
	Else
		cDesReForm := cDesCampo
	Endif
	(cAlias)->( dbcloseArea() )
	RestArea(aArea)

Return cDesReForm

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA163TOK
Valida informações ao salvar.
Uso no cadastro Usuário X Pesquisa

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 20/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA163TOK(oModel)
	Local aArea     := GetArea()
	Local lRet      := .T.
	Local nOpc      := oModel:GetOperation()
	Local oModelNY2 := Nil
	Local oModelNWO := oModel:GetModel('NWODETAIL')
	Local nCt       := 0
	Local nNWO      := 0
	Local nNY2      := 0
	Local nNYK      := 0
	Local nNYL      := 0
	Local cRestUsu  := ""
	
	Local lNZXInDic := FWAliasInDic("NZX") // GRUPO DE USUÁRIOS
	Local lNZYInDic := FWAliasInDic("NZY") // USUÁRIOS X GRUPO

	If lNZXInDic .And. lNZYInDic .And. oModel:GetModel("NVKMASTER"):HasField("NVK_TIPOA")// Proteção referente ao requisito PCREQ-10944 - Grupo de usuários
			cRestUsu := JTrataCbox('NVK_TIPOA', FWFLDGET('NVK_TIPOA'))
	Else
		cRestUsu := JurGrpRest(FWFLDGET('NVK_CUSER'))
	EndIf

	oModelNY2 := oModel:GetModel('NY2DETAIL')
	oModelNYK := oModel:GetModel('NYKDETAIL')

	oModelNYL := oModel:GetModel('NYLDETAIL')

	If nOpc == 3 .Or. nOpc == 4

		If lNZXInDic .And. lNZYInDic .And. oModel:GetModel("NVKMASTER"):HasField("NVK_CGRUP")// Proteção referente ao requisito PCREQ-10944 - Grupo de usuários
			//Valida preenchimento do usuario ou grupo
			If Empty( FwFldGet('NVK_CUSER') ) .And. Empty( FwFldGet('NVK_CGRUP') )
				JurMsgErro(STR0109)		//"Informe o Grupo ou Usuário para continuar"
				lRet := .F.
			EndIf
		EndIf

		// Laço para restrição de cliente
		For nCt := 1 To oModelNWO:GetQtdLine()
			oModelNWO:GoLine( nCt )
			If !Empty(oModelNWO:GetValue('NWO_CCLIEN')) .And. !oModelNWO:IsDeleted(nCt)
				nNWO++
			EndIf
		Next
		oModelNWO:GoLine( 1 )

		// Laço para restrição de Grupo de clientes
		For nCt := 1 To oModelNY2:GetQtdLine()
			oModelNY2:GoLine( nCt )
			If !Empty(oModelNY2:GetValue('NY2_CGRUP')) .And. !oModelNY2:IsDeleted(nCt)
				nNY2++
			EndIf
		Next
		oModelNY2:GoLine( 1 )

		// Laço para restrição de Escritório
		For nCt := 1 To oModelNYK:GetQtdLine()
			oModelNYK:GoLine( nCt )
			If !Empty(oModelNYK:GetValue('NYK_CESCR')) .And. !oModelNYK:IsDeleted(nCt)
				nNYK++
			EndIf
		Next
		oModelNYK:GoLine( 1 )

		// Laço para restrição de Área
		For nCt := 1 To oModelNYL:GetQtdLine()
			oModelNYL:GoLine( nCt )
			If !Empty(oModelNYL:GetValue('NYL_CAREA')) .And. !oModelNYL:IsDeleted(nCt)
				nNYL++
			EndIf
		Next
		oModelNYL:GoLine( 1 )

		//Verifica se tem restricao de clientes e correspondente ao mesmo tempo
		If lRet .And. (nNY2 + nNWO > 0) .And. ( !Empty(FWFLDGET('NVK_CCORR')) .Or. !Empty(FWFLDGET('NVK_CLOJA')) )
			If !Empty(FWFLDGET('NVK_CUSER'))
				JurMsgErro(STR0060)		//"O usuário não pode ser configurado com restrição de 'Correspondente' e 'Clientes' ao tempo!"
			ElseIf !Empty(FWFLDGET('NVK_CGRUP'))
				JurMsgErro(STR0111) //"O grupo não pode ser configurado com restrição de 'Correspondente' e 'Clientes' ao tempo!"
			EndIf
			lRet := .F.
		EndIf

		//Analisa se já não há cadastro para o Usuário com a Pesquisa selecionada
		//If lRet	//.And. oModel:IsFieldUpdated("NVKMASTER","NVK_CPESQ") - Precisa validar caso mude o usuario ou grupo de usuarios
		If lRet .And. (oModel:IsFieldUpdated("NVKMASTER","NVK_CPESQ") .OR. oModel:IsFieldUpdated("NVKMASTER","NVK_CUSER");
				.OR. (lNZXInDic .AND. oModel:IsFieldUpdated("NVKMASTER","NVK_CGRUP")))
			lRet :=	JA163UsrPsq()
		EndIf

		//Valida tipos de acessos
		If lRet

			Do Case

			Case 'CLIENTES' $ cRestUsu

				If (nNY2 + nNWO == 0)
					JurMsgErro(STR0105)		//"Preencha a restrição de Clientes ou Grupos de Clientes, para continuar."
					lRet := .F.
				EndIf

			Case 'CORRESPONDENTES' $ cRestUsu

				If Empty(FWFLDGET('NVK_CCORR')) .Or. Empty(FWFLDGET('NVK_CLOJA'))
					JurMsgErro(STR0048 + AllTrim(RetTitle('NVK_CCORR')) + ' / ' + AllTrim(RetTitle('NVK_CLOJA')))	 //"Preencher os campos:"
					lRet := .F.
				EndIf

			Case 'MATRIZ' $ cRestUsu

				If (nNWO + nNY2 > 0) .Or. !Empty(FWFLDGET('NVK_CCORR')) .Or. !Empty(FWFLDGET('NVK_CLOJA'))
					JurMsgErro(STR0104 + cRestUsu + STR0056)	//"O tipo de acesso:" + cRestUsu + " so permitir restringir o acesso a rotinas."
					lRet := .F.
				EndIf
			EndCase
		EndIf

		If lRet .And. lNZXInDic .And. lNZYInDic 
			lRet := J218VldUsr(FWFLDGET('NVK_CUSER'),FWFLDGET('NVK_CGRUP'))
		EndIf

	EndIf

	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA163CalAl
Calcula o tamanho da altura da tela com os campos

@Param	oPnl		Panel que será refeito.
@Param	oCmbLstTp   Objeto contem  o tipo de pesquisa
@Param	oCmbConfig	Objeto combo.

@author Juliana Iwayama Velho
@since 20/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA163CalAl(oPnl,oCmbLstTp,oCmbConfig)
	Local nTam     := 0
	Local nItem    := 0
	Local aDados   := {}
	Local aPos     := {}
	Local nI       := 0
	Local cDescConf:= ''
	Local aPosTela := {}

	nItem := oCmbConfig:GetnAt()

	If LEN(oCmbLstTp:aItems) > 0 .And. nItem > 0 .And. LEN(oCmbConfig:aItems) > 0

		cDescConf := oCmbConfig:cValor

		If !(cDescConf == PADR('', LEN(cDescConf)))
			NVG->(DBSetOrder(1))
			NVG->(dbGoTop())
			IF NVG->( DBSeek(XFILIAL('NVG') + J163GetPesq() ))

				NVH->(DBSetOrder(1))
				While !(NVG->(Eof())) .And. (Alltrim(NVG->NVG_DESC) == Alltrim(cDescConf))
					If Alltrim(oCmbLstTp:cValor)==Alltrim(NVG->NVG_TPPESQ)
						IF NVH->( DBSeek(XFILIAL('NVH') + NVG->NVG_CCAMPO) )
							aADD( aDados, { NVH->NVH_COD, NVH->NVH_DESC } )
						EndIf
					Endif
					NVG->(dbSkip())
				End

			EndIf

		EndIF

		For nI := 1 to LEN(aDados)
			aPOS := PosTela(@aPosTela,nI)
		Next

		If Len(aPosTela) > 0
			nTam := Len(aPosTela) * 25
		EndIf

		aPosTela := {}
		aPos     := {}

	EndIf

Return nTam

//-------------------------------------------------------------------
/*/{Protheus.doc} JA163UsrPsq()
Valida se o usuário já está cadastrado com a pesquisa

@author Tiago Martins
@since 10/01/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA163UsrPsq()
	Local aArea      := GetArea()
	Local cTmp       := GetNextAlias()
	Local cQuery     := ''
	Local cAssJur    := ''
	Local cPesquisa  := ''
	Local lWSTLegal  := .F.
	Local lNVKNvCmp  := .F.
	Local lRet       := .T.
	Local lCpoGrupo  := .F.
	Local lGrupo     := .F.
	Local oModel     := Nil
	
	Local lNZXInDic := FWAliasInDic("NZX") // GRUPO DE USUÁRIOS
	Local lNZYInDic := FWAliasInDic("NZY") // USUÁRIOS X GRUPO

	DbSelectArea("NVK") // Proteção referente ao requisito PCREQ-10944 - Grupo de usuários
	lCpoGrupo := ColumnPos("NVK_CGRUP") > 0

	If lNZXInDic .And. lNZYInDic .And. lCpoGrupo // Proteção referente ao requisito PCREQ-10944 - Grupo de usuários

		lGrupo     := !Empty(M->NVK_CGRUP)
		cPesquisa  := AllTrim(M->NVK_CPESQ)

		oModel     := FWModelActive()

		//Verifica se o campo NVK_CASJUR existe no dicionário
		If Select("NVK") > 0
			lNVKNvCmp := (NVK->(FieldPos('NVK_CASJUR')) > 0)
		Else
			DBSelectArea("NVK")
			lNVKNvCmp := (NVK->(FieldPos('NVK_CASJUR')) > 0)
			NVK->( DBCloseArea() )
		EndIf

		lWSTLegal := lNVKNvCmp .And. JModRst()

		If lWSTLegal
			cAssJur := AllTrim(oModel:GetValue('NVKMASTER','NVK_CASJUR'))
		EndIf

		//Verifica se ja existe o usuario ou grupo cadastrado com esta pesquisa
		cQuery := " SELECT NVK_CUSER, NVK_CGRUP"
		cQuery += " FROM " + RetSQLName("NVK")
		cQuery += " WHERE  D_E_L_E_T_ = ' ' "
		cQuery += " AND NVK_FILIAL = '" + xFilial('NVK') + "'"

		If lWSTLegal
			cQuery += " AND NVK_CASJUR = '" + cAssJur + "'"
		Else
			cQuery += " AND NVK_CPESQ = '" + cPesquisa + "'"
		EndIf

		//Tira o proprio registro alterado
		If oModel:GetOperation() == 4
			cQuery += " AND R_E_C_N_O_ <> " + cValToChar( NVK->(Recno()) ) + " "
		EndIf

		If lGrupo
			cQuery+= " AND NVK_CGRUP = '" + M->NVK_CGRUP + "'"
		Else
			cQuery+= " AND NVK_CUSER = '" + M->NVK_CUSER + "'"
		EndIf

		cQuery+= " UNION "

		cQuery += " SELECT NVK_CUSER, NVK_CGRUP"
		cQuery += " FROM " + RetSqlName("NVK")
		cQuery += " WHERE  D_E_L_E_T_ = ' '"
		cQuery +=    " AND NVK_FILIAL = '" + xFilial('NVK') + "'"

		If lWSTLegal
			cQuery += " AND NVK_CASJUR = '" + cAssJur + "'"
		Else
			cQuery += " AND NVK_CPESQ = '" + cPesquisa + "'"
		EndIf

		//Tira o proprio registro alterado
		If oModel:GetOperation() == 4
			cQuery += " AND R_E_C_N_O_ <> " + cValToChar( NVK->(Recno()) ) + " "
		EndIf

		If lGrupo
			//Verifica se algum usuario do grupo ja esta cadastrado com esta pesquisa
			cQuery+=	" AND NVK_CUSER IN (SELECT NZY_CUSER"
			cQuery+=					  " FROM " + RetSqlName("NZY")
			cQuery+=					  " WHERE D_E_L_E_T_ = ' '"
			cQuery+=					  	" AND NZY_FILIAL = '" + xFilial("NZY")+ "'"
			cQuery+=					    " AND NZY_CGRUP = '" + M->NVK_CGRUP + "')"
		Else
			//Verifica se algum grupo do usuario já esta cadastrado com esta pesquisa
			cQuery+=	" AND NVK_CGRUP IN (SELECT NZY_CGRUP
			cQuery+=					  " FROM " + RetSqlName("NZY")
			cQuery+=					  " WHERE D_E_L_E_T_ = ' '"
			cQuery+=					  	" AND NZY_FILIAL = '" + xFilial("NZY")+ "'"
			cQuery+=						" AND NZY_CUSER = '" + M->NVK_CUSER + "')"
		EndIf

		If lGrupo
			cQuery+= " UNION"

			//Verifica se algum usuario do grupo digitado esta em algum outro grupo ja relacionado a esta pesquisa
			cQuery+= " SELECT NZY_CUSER, NZY_CGRUP"
			cQuery+= " FROM " + RetSqlName("NZY")
			cQuery+= " WHERE  D_E_L_E_T_ = ' '"
			cQuery+=	" AND NZY_FILIAL = '" + xFilial("NZY") + "'"
			cQuery+=	" AND NZY_CGRUP  = '" + M->NVK_CGRUP + "'"
			cQuery+=	" AND NZY_CUSER IN (  SELECT NZY_CUSER"
			cQuery+=						" FROM " + RetSqlName("NZY")
			cQuery+=						" WHERE D_E_L_E_T_ = ' '"
			cQuery+=						  " AND NZY_FILIAL = '" + xFilial("NZY") + "'"
			cQuery+=						  " AND NZY_CGRUP IN ( SELECT NVK_CGRUP"
			cQuery+=										" FROM " + RetSqlName("NVK")
			cQuery+=											" WHERE D_E_L_E_T_ = ' '"
			cQuery+=											" AND NVK_FILIAL = '" + xFilial("NVK") + "'"

			If lWSTLegal
				cQuery += " AND NVK_CASJUR = '" + cAssJur + "'"
			Else
				cQuery += " AND NVK_CPESQ = '" + cPesquisa + "'"
			EndIf

			//Tira o proprio registro alterado
			If oModel:GetOperation() == 4
				cQuery +=										" AND R_E_C_N_O_ <> " + cValToChar( NVK->(Recno()) ) + " "
			EndIf

			cQuery+=											" AND NVK_CGRUP <> ' ' )"
			cQuery+=					")"
		EndIf
	Else
		cQuery := "SELECT NVK_CUSER"
		cQuery += " FROM " + RetSQLName( 'NVK' )
		cQuery +=  " WHERE NVK_FILIAL = '" + xFilial('NVK') + "'"
		cQuery +=    " AND NVK_CUSER = '" + M->NVK_CUSER + "'"
		cQuery +=    " AND NVK_CPESQ    = '" + AllTrim(M->NVK_CPESQ) + "'"
		cQuery +=    " AND D_E_L_E_T_ = ' ' "
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cTmp, .T., .T. )

	If !(cTmp)->( EOF() )
		lRet := .F.

		If lNZXInDic .And. lNZYInDic // Proteção referente ao requisito PCREQ-10944 - Grupo de usuários
			If lGrupo
				If !lWSTLegal
					JurMsgErro(STR0102)//"Já existe vinculo do grupo com a pesquisa. Ou de usuário(s) do grupo com a pesquisa."
				EndIf
			Else
				JurMsgErro(STR0103)//"Já existe vinculo do usuário com a pesquisa"
			EndIf
		Else
			JurMsgErro(STR0055)//"Cadastro deste usuário com esta pesquisa já foi realizada"
		EndIf
	EndIf

	(cTmp)->( dbCloseArea() )
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J163GetSug()
Trás a sugestão do campo na montagem da pesquisa configurada

@author Jorge Luis Branco Martins Junior
@since 24/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J163GetSug(cPesq, cCampo)
	Local cSugest	:= ""

	NVG->(DBSetOrder(1))
	If NVG->( dbSeek( XFILIAL('NVG') + cPesq + cCampo))
		cSugest := NVG->NVG_SUGEST
	EndIf

Return cSugest

//-------------------------------------------------------------------
/*/{Protheus.doc} J163Active
Retorna se a tela está ativa

@author Jorge Luis Branco Martins Junior
@since 28/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function J163Active()
Return lActive

//-------------------------------------------------------------------
/*/{Protheus.doc} J163GetPesq
Retorna se a tela está ativa

@author Jorge Luis Branco Martins Junior
@since 28/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function J163GetPesq(nTipo)
	Local cPesq := ""
	Local nAt   := oCmbConfig:GetnAt()
	Local nLen  := Len(aConfPesq)

	Default nTipo := 1

	If J163Active()
		If nLen > 0 .And. (nAt > 0 .And. nAt <= nLen) .And. (nTipo == 1 .Or. nTipo == 2)
			cPesq := aConfPesq[nAt][nTipo]
		EndIf
	EndIf

Return cPesq

//-------------------------------------------------------------------
/*/{Protheus.doc} J163LstTpChange
Atualiza o combo de pesquisa e atualiza os campos em tela

@author
@since
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J163LstTpChange(oCmbConfig, oCmbCampos, oCmbLstTp, aDadosCmps, aDesCampos)
	Local lRet := .T.

	AtuCmbConfig(oCmbConfig,oCmbLstTp)

	AtualizaCPOS(oCmbLstTp,@aDadosCmps, @aDesCampos)

	oCmbCampos:SetItems({""})
	oCmbCampos:SetItems(aDesCampos)
	oCmbCampos:Refresh()

	oCmbConfig:Select(1)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  JCall160(cPesq,nTipo)
Função chamar a rotina JURA160 sem carregar as configurações de botão do XNU.
@param nOperacao - Operação que será executada no fonte 160. 3 - Inclusao, 5 - Exclusão

@author André Spirigoni Pinto
@since 20/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall160(oCmbLstTp)
	Local cAceAnt  := AcBrowse
	Local cFunName := FunName()
	Local cPesq := J163GetPesq()

	If !Empty(cPesq)

		// JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA153 inserida no XNU.
		AcBrowse := Replicate("x",10)
		SetFunName( 'JURA160' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA160

		JURA160(cPesq,oCmbLstTp:cValor)

		SetFunName( cFunName )
		AcBrowse := cAceAnt

	Else
		JurMsgErro(STR0075) //"É preciso selecionar a pesquisa para configurar o grid."
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J163Where(cCampo)
Função utilizada para indicar clausula WHERE para campos da Configuração
Uso Geral.

@Param	cCampo			Campo para montagem da clausula Where
@Param	nTipo			  Indica se será comparativo de data >= (1) ou <= (2)

@Return cWhere    Clausula Where

@author Jorge Luis Branco Martins Junior
@since 03/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J163Where(cCampo, nTipo)
	Local cTabela := SUBSTRING(cCampo,1,3)
	Local cWhere  := 'AND '+RetSqlName(cTabela)+'.'+cCampo+' = #'+STR0019+'#' //"DADO"
	Local cTipo	:= JURX3INFO( cCampo, "X3_TIPO" )

	Default nTipo := 0

	Do Case
	Case cCampo == 'NSZ_SIGLA1'
		cWhere := ' AND EXISTS (SELECT 1 FROM ' + RetSqlName("RD0") + ' WHERE RD0_CODIGO = NSZ_CPART1 AND RD0_SIGLA = #DADO#)

	Case cCampo == 'NSZ_SIGLA2'
		cWhere := ' AND EXISTS (SELECT 1 FROM ' + RetSqlName("RD0") + ' WHERE RD0_CODIGO = NSZ_CPART2 AND RD0_SIGLA = #DADO#)

	Case cCampo == 'NTE_SIGLA'
		cWhere := ' AND EXISTS (SELECT 1 FROM ' + RetSqlName("RD0") + ' WHERE RD0_CODIGO = NTE_CPART AND RD0_SIGLA = #DADO#)

	Case cCampo == 'NTA_DTFLWP'
		If nTipo == 1
			cWhere  := 'AND '+RetSqlName(cTabela)+'.'+cCampo+' >= #'+STR0019+'#' //"DADO"
		ElseIf nTipo == 2
			cWhere  := 'AND '+RetSqlName(cTabela)+'.'+cCampo+' <= #'+STR0019+'#' //"DADO"
		EndIf

	Case cTipo == 'M'	 //<- Campos do tipo MEMO deverá ser pesquisados pelo like->
		cWhere  := "AND "+RetSqlName(cTabela)+"."+cCampo+" LIKE '%#DADO_LIKE#%' "
	End Case

Return cWhere


//-------------------------------------------------------------------
/*/{Protheus.doc} JurTabEmpt
Indica se existe registros com a descrição indicada na tabela indicada

@Param	cTab			  Indica a tabela para contagem de registros

@Return lVazio    Indica se a tabela não possui registros

@author Jorge Luis Branco Martins Junior
@since 04/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurTabEmpt(cTab)
	Local lVazio    := .T.
	Local cQuery    := ""
	Local cAliasQry

	cQuery := " SELECT COUNT(*) CAMPOS "
	cQuery += 		" FROM " + RetSqlName(cTab) + " TAB "
	cQuery += " WHERE TAB."+cTab+"_FILIAL  = '" + xFilial(cTab) + "' " + CRLF
	cQuery +=   "	AND TAB.D_E_L_E_T_ = ' ' " + CRLF

	cQuery := ChangeQuery(cQuery)
	cAliasQry	:= GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	(cAliasQry)->( dbGoTop() )

	If !(cAliasQry)->( EOF())
		If (cAliasQry)->CAMPOS > 0
			lVazio := .F.
		EndIF
	EndIf

	(cAliasQry)->( dbCloseArea())

Return lVazio

//-------------------------------------------------------------------
/*/{Protheus.doc} J163AjuNVH
Ajusta os dados de tabela e where dos filtros dos campos com o valor
correto para consultas nas tabelas.
Ex: Caso os registros tenham sido importados e o campo de tabela tenha
vindo NSZ010, porém a empresa usada tem nomenclatura NSZ990, esta
funcionalidade realiza o ajuste nos registros da tabela NVH.

@author Jorge Luis Branco Martins Junior
@since 14/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J163AjuNVH()
	Local aArea     := GetArea()
	Local aAreaNVH  := NVH->( GetArea() )
	Local cWhere    := ""
	Local cWhereFin := ""
	Local cTab      := ""
	Local cTabFin   := ""

	If ApMsgYesNo(STR0084, STR0025) //"Serão ajustados os dados dos campos já cadastrados, para que as tabelas tenham seus nomes conforme Empresa/Filial. Deseja continuar?" - "Aguarde"

		NVH->(DBSetOrder(2))
		NVH->(dbGoTop())
		While !NVH->(EOF())
			cTabFin := RetSqlName( SUBSTR( NVH->NVH_TABELA, 1, 3 ) )
			If cTabFin != NVH->NVH_TABELA
				cWhereFin := NVH->NVH_WHERE
				cTab := NVH->NVH_TABELA
				While RAT(NVH->NVH_TABELA, cWhereFin) > 0
					cWhere := SUBSTR( cWhereFin, 1, AT( cTab, cWhereFin) -1 )
					cWhere += cTabFin
					cWhere += SUBSTR( cWhereFin, AT( SubStr(cTab, 4, 6)+'.', cWhereFin)+3, LEN(cWhereFin))
					cWhereFin := cWhere
				End
				RecLock( 'NVH', .F. )
				NVH->NVH_TABELA := cTabFin
				NVH->NVH_WHERE  := cWhereFin
				MsUnlock()
				IIF(__lSX8, ConfirmSX8(), )
			EndIf
			NVH->(dbSkip())
		End

		ApMsgInfo(STR0088) //'Atualização de tabelas concluida. É necessário sair e entrar novamente na tela para que as atualizações sejam visualizadas corretamente'

	EndIf

	RestArea(aAreaNVH)
	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RefCmbCampos(oCmbLstTp,aDadosCmps, aDesCampos, oCmbCampos)
Função utilizada para Atualizar o combo de campos quando a aba é mudada para que não
seja preciso reabrir a tela.
Uso Geral.
@Param	oCmbLstTp   Objeto contem  o tipo de pesquisa
@Param	aDadosCmps	Array com os dados dos campos(codigo, descrição).
@Param	aDesCampos	Array com as descrições dos campos.

@author André Spirigoni Pinto
@since 16/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RefCmbCampos(oCmbLstTp,	aDadosCmps, aDesCampos, oCmbCampos, aObj, lNewCfg)

	//Refaz a configuração para pegar alguma mudança no nomes dos campos
	AtuCmbConfig(oCmbConfig,oCmbLstTp)

	AtualizaCPOS(oCmbLstTp,@aDadosCmps, @aDesCampos, @aObj)
	oCmbCampos:SetItems({""})
	oCmbCampos:SetItems(aDesCampos)

	oCmbCampos:Refresh()
	lNewCfg := .F.

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} DuplPesq()

Valida se há duplicidade de perfis de pesquisa
@author Rafael Rezende Costa
@since 19/05/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DuplPesq(cDescr)
	Local aArea  := GetArea()
	Local cQuery := ''
	Local aSQL   :={}

	Default cDescr := ''

	cDescr:= ALLTRIM(UPPER(cDescr))

	cQuery := " SELECT DISTINCT UPPER(NVG_DESC) NVG_DESC "+ CRLF
	cQuery += "  FROM " + RetSQLName( 'NVG' ) + " NVG " + CRLF
	cQuery += "   WHERE NVG.NVG_FILIAL = '" +xFilial('NVG')+ "' "+ CRLF
	cQuery += "   AND NVG.D_E_L_E_T_ = ' ' "+ CRLF

	aSQL := JurSQL(cQuery, "NVG_DESC")

	restArea(aArea)
Return aScan( aSQL , { |aX| Alltrim(aX[1]) == cDescr } ) > 0

//-------------------------------------------------------------------
/*/{Protheus.doc} J163VlRot

Valida o grid de funcionalidades da aba de acesso a rotinas

@author Rafael Rezende Costa
@since 19/05/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J163VlRot(oModelNWP)
	Local lRet			:= .T.
	Local cCodRot		:= ''

	If ( oModelNWP:GetOperation() == 3 .Or. oModelNWP:GetOperation() == 4 ) .And. !oModelNWP:IsDeleted()
		cCodRot := oModelNWP:GetValue("NWP_CROT")

		If !Empty( cCodRot ).And. ( !Empty(oModelNWP:GetValue('NWP_CINCLU')) .And. !Empty(oModelNWP:GetValue('NWP_CALTER')) .And. !Empty(oModelNWP:GetValue('NWP_CEXCLU')) )
			Do Case
			Case cCodRot == '09' .And. oModelNWP:GetValue("NWP_CEXCLU") == '1'
				lRet := .F.
				JurMsgErro(STR0054) //"A funcionalidade de Excluir não está disponível para a rotina de Contrato Correspondente. Verifique."

			Case cCodRot $ '11/13' .And. ( (oModelNWP:GetValue('NWP_CINCLU') == '1' .Or. oModelNWP:GetValue('NWP_CALTER') == '1' .Or. oModelNWP:GetValue('NWP_CEXCLU') == '1' ) )
				lRet := .F.
				JurMsgErro(STR0087 + oModelNWP:GetValue("NWP_DROT") ) // 'As funcionalidades de Incluir, Alterar e Excluir não estão disponíveis para a rotina de ' + oModelNWP:GetValue("NWP_DROT")

			Case cCodRot $ '18' .And. ( (oModelNWP:GetValue('NWP_CVISU') == '1' .Or. oModelNWP:GetValue('NWP_CALTER') == '1' .Or. oModelNWP:GetValue('NWP_CEXCLU') == '1' ) )
				lRet := .F.
				JurMsgErro(STR0100) //"As funcionalidades de Visualizar, Alterar e Excluir não estão disponíveis para a rotina de alteração em lote. Verifique."

			EndCase
		Endif
	EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J163PsqCpo
Rotina de pesquisa dos campos na aba Configura Campo

@author Reginaldo N Soares / Jorge Martins
@since 13/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J163PsqCpo(oListCampo)
	Local lRet       := .F.
	Local aArea      := GetArea()
	Local cGetCampo  := ''
	Local oGetCampo, oDlg

	//DEFINE MSDIALOG oDlg TITLE 'Pesquisa de campos' FROM 233,200 TO 270,510 PIXEL //Pesquisa de campos
	DEFINE MSDIALOG oDlg TITLE STR0090 FROM 233,200 TO 370,510 PIXEL //Pesquisa de campos

	oGetCampo := TJurPnlCampo():New(02,16,50,22,oDlg,STR0091,,{|| },{|| cGetCampo := oGetCampo:Valor},PadR("", 12),,,) //Campo
	//oGetCampo:oCampo:bValid := {|| Empty(Alltrim(oCliente:Valor)) .OR. ExistCpo('SA1',oCliente:Valor,1)}


	@ 039,016 Button STR0092 Size 050,015 PIXEL OF oDlg  Action ( J163Proximo(@cGetCampo, @oListCampo, @oGetCampo) ) //'Próximo'
	@ 039,095 Button STR0093 Size 050,015 PIXEL OF oDlg  Action oDlg:End() //Fechar

	ACTIVATE MSDIALOG oDlg CENTERED

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J163Proximo
Realiza a pesquisa dos campos

@author Reginaldo N Soares / Jorge Martins
@since 13/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J163Proximo(cGetCampo, oListCampo, oGetCampo)
	Local nPosIni    := 0
	Local nPosAtu    := 0
	Local nPos       := 0

	If oListCampo <> NIL

		nPosIni := oListCampo:nAt

		If !Empty( cGetCampo )

			If (nPosAtu := aScan( oListCampo:aItems, { |x| Upper( Alltrim( cGetCampo ) ) $ Upper( x ) } , nPosIni + 1) ) <> 0

				oListCampo:nAt := nPosAtu
				nPosIni        := nPosAtu

			Else
				If (nPos := aScan( oListCampo:aItems, { |x| Upper( Alltrim( cGetCampo ) ) $ Upper( x ) } ) ) <> 0
					oListCampo:nAt := nPos
				Else
					JurMsgErro(STR0094) //"Nenhum campo encontrado"
					oGetCampo:Valor := PadR("", 12)
				EndIf
			EndIf

		EndIf

	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J163Commit
Realiza o commit do modelo

@author Andre Lago
@since 03/06/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function J163Commit(oModel, lShowErr)
	Local lRet      := .T.
	Local cPesq     := oModel:GetValue("NVKMASTER", "NVK_CPESQ")
	Local cTipoAce  := oModel:GetValue("NVKMASTER", "NVK_TIPOA")
	Local cGrupoAnt := Space( TamSx3("NVK_CGRUP")[1]  )
	Local cUserAnt  := Space( TamSx3("NVK_CUSER")[1]  )
	Local nOpc      := oModel:GetOperation()

//Carrega grupo e usuario antes da alteração
	If nOpc <> MODEL_OPERATION_INSERT
		cGrupoAnt := NVK->NVK_CGRUP
		cUserAnt  := NVK->NVK_CUSER
	EndIf

	If SuperGetMV('MV_JDOCUME',,'2') == '3'
		If (cTipoAce == "3")
			Processa( {|| JRemPermFl(oModel:GetValue("NVKMASTER", "NVK_COD")) } , STR0113, , .F.) //"Atualizando usuários no Fluig"
		EndIf
	EndIf

	lRet := FWFormCommit( oModel )

	If lRet
		//Atualiza dados de usuarios no fluig
		IF SuperGetMV('MV_JDOCUME',,"2") == "3"
			AtuFluig(oModel, cGrupoAnt, cUserAnt, cPesq)
		EndIf
	Else
		If lShowErr
			JurShowErro( oModel:GetModel():GetErrormessage() )
		EndIf
	EndIf

	oModel:Activate()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuFluig
Chama rotina que atualiza permissões dos usuarios no Fluig.

@author  Rafael Tenorio da Costa
@since   21/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuFluig(oModel, cGrupoAnt, cUserAnt, cPesq)
	Local aArea      := GetArea()
	Local aUsuarios  := {}
	Local nCont      := 0
	Local aCampos    := {}
	Local lContinua  := .F.
	Local lWSTLegal  := .F.
	Local lNVKNvCmp  := .F.
	Local lMostraMsg := .T.
	Local nOpc       := oModel:GetOperation()
	Local cRestUsu   := oModel:GetValue("NVKMASTER", "NVK_TIPOA")
	Local cCodAsJur  := ''

	//Verifica se o campo NVK_CASJUR existe no dicionário
	If Select("NVK") > 0
		lNVKNvCmp := (NVK->(FieldPos('NVK_CASJUR')) > 0)
	Else
		DBSelectArea("NVK")
		lNVKNvCmp := (NVK->(FieldPos('NVK_CASJUR')) > 0)
		NVK->( DBCloseArea() )
	EndIf

	lWSTLegal := lNVKNvCmp .And. JModRst()

	If lWSTLegal
		aCampos   := {"NVK_CGRUP", "NVK_CUSER", "NVK_CPESQ", "NVK_CCORR", "NVK_CLOJA",'NVK_CASJUR'}
		cCodAsJur := oModel:GetValue("NVKMASTER", "NVK_CASJUR")
	Else
		aCampos := {"NVK_CGRUP", "NVK_CUSER", "NVK_CPESQ", "NVK_CCORR", "NVK_CLOJA"}
	EndIf

	For nCont:=1 To Len(aCampos)
		If nOpc == MODEL_OPERATION_DELETE .Or. oModel:IsFieldUpdated("NVKMASTER", aCampos[nCont])
			lContinua := .T.
			Exit
		EndIf
	Next nCont

	If lContinua

		//Carrega os usuarios dos grupos
		If !Empty(NVK->NVK_CGRUP) .Or. !Empty(cGrupoAnt)
			aUsuarios := JA163GrUsu(NVK->NVK_CGRUP, cGrupoAnt)
		EndIf

		//Carrega usuario atual
		If !Empty(NVK->NVK_CUSER) .And. Ascan(aUsuarios, {|x| AllTrim(x[1]) == AllTrim(NVK->NVK_CUSER)} ) == 0
			Aadd(aUsuarios, {NVK->NVK_CUSER})
		EndIf

		//Carrega usuario anterior
		If !Empty(cUserAnt) .And. Ascan(aUsuarios, {|x| AllTrim(x[1]) == AllTrim(cUserAnt)} ) == 0
			Aadd(aUsuarios, {cUserAnt})
		EndIf

		//Faz as devidas alterações no Fluig
		If Len(aUsuarios) > 0

			Do Case
			Case cRestUsu == "1"
				cRestUsu := "MATRIZ"
			Case cRestUsu == "2"
				cRestUsu := "CLIENTES"
			Case cRestUsu == "3"
				lMostraMsg := .F.
				cRestUsu   := "CORRESPONDENTES"
			End Case

			Processa( {|| J163PFluig(aUsuarios, cPesq, cRestUsu, nOpc, lMostraMsg, , cCodAsJur) } , STR0113, , .F.) //"Atualizando usuários no Fluig"
		EndIf
	EndIf

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J163PFluig(aUserAlt, cPesq, cRestUsu, nOpc, lMostraMsg, aAdicMsg)
Cria ou altera a seguranca das pastas relacionadas ao usuario incluido ou alterado.

@param  aUserAlt   - Lista dos usuários alterados.
@param  cPesq      - Código da configuração de pesquisa.
@param  cRestUsu   - Qual é a restrição do usuário, 1 = Matriz, 2 = Cliente e 3 = Correspondente.
@param  nOpc       - Operação que está sendo realizada.
@param  lMostraMsg - Define se JCOLID mostra mensagem, .T. ou .F.
@param  aAdicMsg   - Lista dos usuários excluídos no grupo de usuários.
@param  cCodAsJur  - Código do assunto jurídico

@since 10/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J163PFluig(aUserAlt, cPesq, cRestUsu, nOpc, lMostraMsg, aAdicMsg, cCodAsJur)
	Local aArea      := GetArea()
	Local cAliasNVK  := Nil
	Local aCasos     := {}
	Local aAssuntos  := {} //Guarda a lista de assuntos jurídicos que um usuário possui após o commit.
	Local aGuardaUsu := {}
	Local cQuery     := ""
	Local cErro      := ""
	Local cAviso     := ""
	Local cQuant     := ""
	Local cTotal     := ""
	Local cPasta     := ""
	Local cColId     := ""
	Local cEndEmail  := ""
	Local cUserAlt   := ""
	Local cXmlAux    := ""
	Local cXml       := ""
	Local cCampos    := "NSZ_CCLIEN, NSZ_LCLIEN, NSZ_NUMCAS, NSZ_TIPOAS, NZ7_LINK"
	Local cPathCab   := ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETCOLLEAGUEGROUPSBYCOLLEAGUEIDRESPONSE:_RESULT:_ITEM" // Informa o caminho para acessar o cabecalho da msg XML
	Local cPathCab1  := ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_DELETECOLLEAGUEGROUPRESPONSE" // Informa o caminho para acessar o cabecalho da msg XML
	Local cPathCab2  := ":_SOAP_ENVELOPE:_SOAP_BODY:_NS1_CREATECOLLEAGUEGROUPRESPONSE"
	Local cUsuario   := AllTrim(SuperGetMV('MV_ECMUSER',,""))
	Local cSenha     := AllTrim(SuperGetMV('MV_ECMPSW' ,,""))
	Local nEmpresa   := AllTrim(SuperGetMV('MV_ECMEMP' ,,0))
	Local ni         := 0
	Local nT         := 0
	Local nUser      := 0
	Local nCont      := 0
	Local nXml       := 1
	Local lArray     := .F.
	Local lPrimeiro  := .T.

	Default aAdicMsg   := {}
	Default aUserAlt   := { {NVK->NVK_CUSER} }
	Default cPesq      := NVK->NVK_CPESQ
	Default cRestUsu   := ""
	Default cCodAsJur  := ""
	Default nOpc       := 3
	Default lMostraMsg := .T.

	ProcRegua(0)
	IncProc()

	For nUser:=1 To Len(aUserAlt)

		cUserAlt  := aUserAlt[nUser][1]
		cRestUsu  := IIF(Empty(cRestUsu), JurGrpRest(cUserAlt), cRestUsu)
		cEndEmail := AllTrim( UsrRetMail(cUserAlt) )
		cErro     := ""

		IncProc( cEndEmail )

		//Usuário Interno
		If !('CORRESPONDENTES' $ cRestUsu .Or. 'CLIENTES' $ cRestUsu )

			//Inclui a lista de assuntos jurídicos que o usuário possui
			cTipAssJur := JurTpAsJr(cUserAlt, .T.)
			cTipAssJur := AllTrim( StrTran(cTipAssJur, "'", "") )
			cTipAssJur := IIF(cTipAssJur == "00", "", cTipAssJur)
			aAssuntos  := StrToKarr(cTipAssJur, ",")

			//Função que retorna os grupos em que o usuário pertence, no Fluig.
			xRet := JGtCGrp( cEndEmail )

			oXmlJGtCGrp := XmlParser( xRet, "_", @cErro, @cAviso )

			If oXmlJGtCGrp <> Nil

				nXml := 1
				cXml := "oXmlJGtCGrp" + cPathCab

				If ( lArray := ValType( &(cXml) ) == "A" )
					nXml := Len( &(cXml) )
				EndIf

				For ni:=1 to nXml

					//Tratamento para prever retorno sendo array
					cXmlAux := IIF(lArray, cXml + "[" + StrZero(ni,3) + "]", cXml)

					If XmlChildEx(&(cXmlAux),"_GROUPID") <> Nil
						cTexto := &(cXmlAux + ":_GROUPID:TEXT")
						If "JUR_" $ cTexto .And. val(Substr(cTexto,5,3))>0 .And. !Empty(Posicione("NYB",1,XFILIAL("NYB")+Substr(cTexto,5,3), "NYB_DESC"))

							//Verifica se o usuario deve ter mesmo acesso a este grupo
							if (nT := aScan(aAssuntos,{|x| IIF(x!=Nil,AT("JUR_" + x,cTexto) == 1,.F.)})) > 0

								aDel(aAssuntos, nT)
								aSize(aAssuntos, Len(aAssuntos)-1)

								If lArray
									Loop
								Else
									Exit
								EndIf
							Endif

							//Deleto usuario do Grupo
							xRet := JDelCGrp( cEndEmail, cTexto )
							oXmlJDelCGrp := XmlParser( xRet, "_", @cErro, @cAviso )

							If oXmlJDelCGrp <> Nil .And. At("soap:Fault",xRet)==0
								If XmlChildEx(&("oXmlJDelCGrp" + cPathCab1),"_RETURN") <> Nil
									If &("oXmlJDelCGrp" + cPathCab1 + ":_RETURN:TEXT") <> "ok"
										cErro := STR0096+ cEndEmail + STR0097		//"Usuario "##" nao deletado"
									Else
										cTexto := StrTran(cTexto, "JUR_","VER_")
									EndIf
								EndIf
							Else
								//³Retorna falha no parser do XML³
								cErro := STR0098 + CRLF + cErro		//"Objeto XML nao criado, verificar a estrutura do XML"
							EndIf
						EndIf
					EndIf

				Next ni
				FwFreeObj(oXmlJGtCGrp)

			Else
				//³Retorna falha no parser do XML³
				cErro := STR0098 + CRLF + cErro		//"Objeto XML nao criado, verificar a estrutura do XML"
			EndIf

			//Grava novas permissoes para cada assunto jurídico.
			If Empty(cErro)

				For ni:=1 to Len(aAssuntos)

					//Valida se o assunto deve ou não ser vinculado ao usuário.
					NYB->( dbsetorder(1) )
					If NYB->( DBSeek(XFILIAL('NYB') + aAssuntos[ni]) )

						//Função para criar um usuario no grupo, no Fluig.
						xRet := JMkCGrp(cEndEmail, AllTrim(FwNoAccent(NYB->NYB_IDGRP)), AllTrim(NYB->NYB_COD) )

						If "RESULTXML" $ Upper(xRet)
							//Localizo o id da pasta craida
							oXmlJMkCGrp := XmlParser( xRet, "_", @cErro, @cAviso )

							If oXmlJMkCGrp <> Nil
								If XmlChildEx(&("oXmlJMkCGrp" + cPathCab2),"_RESULTXML") <> Nil
									If &("oXmlJMkCGrp" + cPathCab2 + ":_RESULTXML:TEXT") <> "ok" .And. At('Colaborador ja existe',&("oXmlJMkCGrp" + cPathCab2 + ":_RESULTXML:TEXT"))==0 ;
											.And. At('nok',&("oXmlJMkCGrp" + cPathCab2 + ":_RESULTXML:TEXT")) == 0
										cErro := STR0096 + cEndEmail + STR0099		//"Usuario "##" nao criado"
									EndIf
								EndIf
							Else
								//³Retorna falha no parser do XML³
								cErro := STR0098 + CRLF + cErro		//"Objeto XML nao criado, verificar a estrutura do XML"
							EndIf

							FwFreeObj(oXmlJMkCGrp)
						EndIf
					EndIf

				Next ni
			EndIf

			//Correspodente ou Cliente
		Else

			If lMostraMsg .Or. (!Empty(cEndEmail) .And. aScan( aGuardaUsu, {|x| AllTrim(x[1]) == AllTrim(cEndEmail)} ) == 0)

				//Carrega o Id do usuario no fluig
				cColId := JColId(cUsuario, cSenha, nEmpresa, cEndEmail, @cErro, lMostraMsg)

				If !lMostraMsg .And. Empty(cColId) .And. !Empty(cErro)
					Aadd(aGuardaUsu, {cEndEmail, cColId, cErro})
					loop
				EndIf


				//Carrega apenas para o primeiro usuario porque os demais fazem parte do mesmo Correspondente ou Cliente
				If Empty(cErro) .And. lPrimeiro

					lPrimeiro := .F.

					//Na exclusão do acesso não busca os casos relacionados a pesquisa porque já foram excluidos
					If nOpc <> MODEL_OPERATION_DELETE

						//Pega as pastas(Casos) no protheus que o usuario tem permissão
						cAliasNVK := GetNextAlias()
						cQuery    := JGSQLPesq(cCampos, cUserAlt, cPesq, cCodAsJur)

						DbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAliasNVK, .T., .T.)

						While !(cAliasNVK)->( Eof() )

							If aScan(aCasos,{|x| x[3] == (cAliasNVK)->NSZ_NUMCAS}) == 0

								cPasta := SubStr((cAliasNVK)->NZ7_LINK, 1, At(";", (cAliasNVK)->NZ7_LINK) - 1)

								aAdd(aCasos,{(cAliasNVK)->NSZ_CCLIEN, (cAliasNVK)->NSZ_LCLIEN, (cAliasNVK)->NSZ_NUMCAS, (cAliasNVK)->NSZ_TIPOAS, (cAliasNVK)->RECNSZ, cPasta})
							EndIf

							(cAliasNVK)->(dbSkip())
						EndDo

						(cAliasNVK)->( DbCloseArea() )
					EndIf
				EndIF

				If Empty(cErro)
					//Inclui permissão
					cTotal := cValToChar( Len(aCasos) )

					For nCont:=1 To Len(aCasos)

						cQuant := cValToChar(nCont)
						IncProc( I18n(STR0114, {cQuant, cTotal, cEndEmail}) ) //"Incluindo Casos: #1/#2 #3"

						//Atribui permissões nas pastas do fluig
						//removida a função que pegava a diferença das pastas pois dependendo da quantidade de pastas, o fluig não consegue retornar tudo de um usuário, o que inviabiliza este processo.
						J163SetPer(aCasos[nCont][6], cUsuario, cSenha, nEmpresa, "1", cColId, .T.)
					Next nCont
				EndIf

				If !lMostraMsg
					Aadd(aGuardaUsu, {cEndEmail, cColId, ""})
				EndIf
			Else
				If !lMostraMsg .And. Empty(cEndEmail)
					cEndEmail := UsrRetName( cUserAlt )
					Aadd(aGuardaUsu, {cEndEmail, cEndEmail , I18n(STR0134, { cEndEmail }) })//"Usuário(s) #1 não está ativo no Fluig!"
				EndIf
			EndIf
		EndIf
	Next nUser

	If Len(aAdicMsg) > 0
		For nI := 1 to Len(aAdicMsg)
			Aadd(aGuardaUsu, {aAdicMsg[nI][1], aAdicMsg[nI][2], aAdicMsg[nI][3]})
		next
	EndIf

	If !lMostraMsg .And. Len(aGuardaUsu) > 0 .And. aScan( aGuardaUsu, {|x| !Empty(x[3])} ) > 0
		cEndEmail := ""
		cErro     := ""

		For nI := 1 to Len(aGuardaUsu)
			If !Empty(aGuardaUsu[nI][3])
				If STR0098 $ aGuardaUsu[nI][3]
					cErro := STR0098 //"Objeto XML nao criado, verificar a estrutura do XML"
				Else
					cEndEmail += aGuardaUsu[nI][1] + ", "
				EndIf
			EndIf
		Next

		If !Empty(cEndEmail)
			cEndEmail := Substr(cEndEmail,1,Rat(',', cEndEmail)-1)

			cErro := CRLF + I18n(STR0134, {cEndEmail}) //"Usuário(s) #1 não está ativo no Fluig!"
		EndIf
	EndIf

	If !Empty(cErro)
		JurMsgErro( I18n(STR0116, {cErro}) )//"Erro nas permissões no Fluig: #1"
	EndIf

	aSize(aCasos, 0)

	RestArea(aArea)

Return cErro

//-------------------------------------------------------------------
/*/{Protheus.doc} J163VldGru()
Valida campo NVK_CGRUP e gatilha campo 	NVK_TIPOA

@Return lRet

@author Wellington Coelho
@since 24/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J163VldGru()
	Local lRet      := .F.
	Local cTipoA    := ''
	Local oModel    := FWModelActive()
	Local oModelNVK := oModel:GetModel("NVKMASTER")

	If oModel <> Nil
		If !Empty(oModelNVK:GetValue("NVK_CGRUP"))
			If ExistCpo('NZX',oModelNVK:GetValue("NVK_CGRUP"),1)

				cTipoA    := JurGetDados('NZX', 1, xFilial('NZX') + oModelNVK:GetValue("NVK_CGRUP"), 'NZX_TIPOA')
				If cTipoA == '4'
					lRet := .F.
					
					JurMsgErro(STR0135,,STR0136) //'Tipo de acesso do grupo ínvalido para o relacionamento'##"Selecione um grupo que não seja do tipo 4=Subsídio"
				Else
					oModelNVK:LoadValue('NVK_CCORR', "")
					oModelNVK:LoadValue('NVK_CLOJA', "")
					oModelNVK:LoadValue('NVK_DCORR', "")
					oModelNVK:LoadValue('NVK_TIPOA', cTipoA)
					lRet := .T.
				Endif
			Else
				lRet := .F.
			EndIf
		Else
			oModelNVK:LoadValue('NVK_CCORR', "")
			oModelNVK:LoadValue('NVK_CLOJA', "")
			oModelNVK:LoadValue('NVK_DCORR', "")
			oModelNVK:LoadValue('NVK_TIPOA', "")
			lRet := .T.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J163VldUsu()
Valida campo NVK_CUSER e gatilha campo 	NVK_CCORR

@Return lRet

@author Wellington Coelho
@since 24/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J163VldUsu()
	Local lRet      := .F.
	Local oModel    := FWModelActive()
	Local oModelNVK := oModel:GetModel("NVKMASTER")

	If oModel <> Nil
		If !Empty(oModelNVK:GetValue("NVK_CUSER"))
			If UsrExist(oModelNVK:GetValue("NVK_CUSER"))
				lRet := .T.
			EndIf
		Else
			oModelNVK:LoadValue('NVK_CCORR', "")
			oModelNVK:LoadValue('NVK_CLOJA', "")
			oModelNVK:LoadValue('NVK_DCORR', "")
			oModelNVK:LoadValue('NVK_TIPOA', "")
			lRet := .T.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J163VldTpA()
Valida campo NVK_TIPOA e gatilha campo 	NVK_CCORR e NVK_CLOJA

@Return lRet

@author Wellington Coelho
@since 24/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J163VldTpA()
	Local lRet      := .F.
	Local oModel    := FWModelActive()
	Local oModelNVK := oModel:GetModel("NVKMASTER")

	If oModel <> Nil
		If !Empty(oModelNVK:GetValue("NVK_TIPOA"))
			If oModelNVK:GetValue("NVK_TIPOA") $ "123"
				oModelNVK:LoadValue('NVK_CCORR', "")
				oModelNVK:LoadValue('NVK_CLOJA', "")
				oModelNVK:LoadValue('NVK_DCORR', "")
				lRet := .T.
			EndIf
		Else
			oModelNVK:LoadValue('NVK_CCORR', "")
			oModelNVK:LoadValue('NVK_CLOJA', "")
			oModelNVK:LoadValue('NVK_DCORR', "")
			lRet := .T.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J163CrComo()
Função que copia a linha selecionada e cria um item igual para facilitar a criação

@Return lRet

@author André Spirigoni Pinto
@since 06/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J163CrComo()
	Local oM163old
	Local oM163new
	Local nI := 0
	Local oMNWO
	Local oMNWP
	Local oMNY2
	Local oMNYK
	Local oMNYL

	if !Empty(NVK->NVK_COD) //valida se estamos posicionados em algum registro da NVK.
		//carrega as informações da linha origem
		oM163old := FWLoadModel("JURA163")
		oM163old:SetOperation( 1 )
		oM163old:Activate()

		oM163new := FWLoadModel("JURA163")
		oM163new:SetOperation( 3 )
		oM163new:Activate()

		oMNWO := oM163new:GetModel("NWODETAIL")
		oMNWP := oM163new:GetModel("NWPDETAIL")
		oMNY2 := oM163new:GetModel("NY2DETAIL")
		oMNYK := oM163new:GetModel("NYKDETAIL")
		oMNYL := oM163new:GetModel("NYLDETAIL")

		If oM163old:GetModel("NVKMASTER"):HasField("NVK_CGRUP") .And. !Empty(oM163old:GetValue("NVKMASTER","NVK_CGRUP"))
			oM163new:SetValue("NVKMASTER","NVK_CGRUP",oM163old:GetValue("NVKMASTER","NVK_CGRUP"))
		Else
			oM163new:SetValue("NVKMASTER","NVK_CUSER",oM163old:GetValue("NVKMASTER","NVK_CUSER"))
			if oM163new:GetModel("NVKMASTER"):HasField("NVK_TIPOA")
				oM163new:SetValue("NVKMASTER","NVK_TIPOA",oM163old:GetValue("NVKMASTER","NVK_TIPOA"))
			Endif
		Endif

		oM163new:SetValue("NVKMASTER","NVK_CPESQ",oM163old:GetValue("NVKMASTER","NVK_CPESQ"))

		//restrição clientes
		For nI := 1 to oM163old:GetModel("NWODETAIL"):Length()
			if nI > 1
				oMNWO:AddLine()
			Endif
			oMNWO:SetValue("NWO_CCLIEN",oM163old:GetModel("NWODETAIL"):GetValue("NWO_CCLIEN",nI))
			oMNWO:SetValue("NWO_CLOJA",oM163old:GetModel("NWODETAIL"):GetValue("NWO_CLOJA",nI))
		Next

		//restrição rotinas
		For nI := 1 to oM163old:GetModel("NWPDETAIL"):Length()
			if nI > 1
				oMNWP:AddLine()
			Endif
			oMNWP:SetValue("NWP_CROT",oM163old:GetModel("NWPDETAIL"):GetValue("NWP_CROT",nI))
			oMNWP:SetValue("NWP_CVISU",oM163old:GetModel("NWPDETAIL"):GetValue("NWP_CVISU",nI))
			oMNWP:SetValue("NWP_CINCLU",oM163old:GetModel("NWPDETAIL"):GetValue("NWP_CINCLU",nI))
			oMNWP:SetValue("NWP_CALTER",oM163old:GetModel("NWPDETAIL"):GetValue("NWP_CALTER",nI))
			oMNWP:SetValue("NWP_CEXCLU",oM163old:GetModel("NWPDETAIL"):GetValue("NWP_CEXCLU",nI))
		Next

		//restrição grupos
		For nI := 1 to oM163old:GetModel("NY2DETAIL"):Length()
			if nI > 1
				oMNY2:AddLine()
			Endif
			oMNY2:SetValue("NY2_CGRUP",oM163old:GetModel("NY2DETAIL"):GetValue("NY2_CGRUP",nI))
		Next

		//restrição escritório
		For nI := 1 to oM163old:GetModel("NYKDETAIL"):Length()
			if nI > 1
				oMNYK:AddLine()
			Endif
			oMNYK:SetValue("NYK_CESCR",oM163old:GetModel("NYKDETAIL"):GetValue("NYK_CESCR",nI))
		Next

		//restrição área
		For nI := 1 to oM163old:GetModel("NYLDETAIL"):Length()
			if nI > 1
				oMNYL:AddLine()
			Endif
			oMNYL:SetValue("NYL_CAREA",oM163old:GetModel("NYLDETAIL"):GetValue("NYL_CAREA",nI))
		Next

		//Desativa o modelo usado para carregar os dados.
		oM163old:deActivate()
		oM163old:Destroy()

		//Abre rotina com o modelo novo preenchido
		MsgRun(STR0083,STR0044,{|| nRet:=FWExecView(STR0015,"JURA163",3,,,,,,,,,oM163new )}) //"Carregando..." e "Pesquisa de Processos"

	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA163GrUsu
Retorna os usuários pertentecentes ao grupo.

@param	cGrupo	  - Grupo que terá os usuários retornados
@param	cGrupoOld - Grupo antes da alteração
@return	aRetorno  - Códigos dos usuários do grupo
@author Rafael Tenorio da Costa
@since  20/03/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA163GrUsu(cGrupo, cGrupoOld)

	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local cQuery	:= ""

	Default cGrupo	  := ""
	Default cGrupoOld := ""

	cQuery	:= " SELECT DISTINCT NZY_CUSER"
	cQuery	+= " FROM " + RetSqlName("NZY")
	cQuery	+= " WHERE NZY_FILIAL = '" + xFilial("NZY") + "'"
	cQuery	+= 	" AND ( NZY_CGRUP = '" + cGrupo + "' OR NZY_CGRUP = '" + cGrupoOld + "' )"
	cQuery	+= 	" AND D_E_L_E_T_ = ' '"

	aRetorno := JurSQL(cQuery, "NZY_CUSER")

	RestArea(aArea)

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} J163SetPer()
Efetua alteração nas permissões das pastas do Fluig,

@author  Rafael Tenorio da Costa
@since   08/07/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J163SetPer(cPasta, cUsuario, cSenha, cEmpresa, cTipo, cColIdGrp, lInclui)

	Local xRet   	:= Nil
	Local cErro  	:= ""
	Local cAviso 	:= ""
	Local cJUpPst	:= "oXmlJUpPst:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_UPDATEFOLDERRESPONSE:_RESULT:_ITEM"
	Local cDescTipo	:= IIF(cTipo == "1", STR0117, STR0118)	//"usuário"		//"grupo"

	Private oXmlJUpPst := Nil		//Necessario por causa da macro execução

	//Se o processo não estiver encerrado altera permissão
	If !J70CasoEnc(cPasta)

		//Altera as permissões nas pastas
		xRet := JUpPst(cPasta, cUsuario, cSenha, cEmpresa, cTipo, cColIdGrp, lInclui)

		If "WEBSERVICEMESSAGE" $ Upper(xRet)

			//Localizo o id da pasta criada
			oXmlJUpPst := XmlParser(xRet, "_", @cErro, @cAviso)

			If oXmlJUpPst <> Nil

				If XmlChildEx( &(cJUpPst), "_WEBSERVICEMESSAGE") <> Nil

					xRet := &(cJUpPst + ":_WEBSERVICEMESSAGE:TEXT")

					If xRet <> "ok"
						cErro := I18n(STR0119, {cDescTipo, cColIdGrp, cPasta}) + CRLF	//"Não foi possível incluir permissão ao #1 #2, na pasta #3."
						cErro += I18n(STR0120, {xRet})									//"Retorno Fluig: #1"
					EndIf
				EndIf

			Else
				//³Retorna falha no parser do XML³
				cErro := STR0098	//"Objeto XML nao criado, verificar a estrutura do XML"
			EndIf

			FwFreeObj(oXmlJUpPst)
		Else
			if xRet != "ok"
				cErro := I18n(STR0121, {"JUpPst", xRet})	//"Retorno desconhecido (#1): #2"
			Endif
		EndIf

		If !Empty(cErro)
			JurConOut(cErro)
		EndIf
	EndIf

Return cErro

//-------------------------------------------------------------------
/*/{Protheus.doc} J163AtPeCo(cPesquisa, aCaso, aDelCorres, aIncCorres, cCodAsJur, cRotina)
Atualiza permissões de correspondentes por Caso Utilizado para Correspondentes

@Param cPesquisa  - Código da Configuração de Pesquisa
@Param aCaso      - Lista dos Casos para permitir ou remover permissão.
@Param aDelCorres - Lista dos Correspondentes que serão removidos da permissão da pasta.
@Param aIncCorres - Lista dos Correspondentes que serão adicionados na permissão de pasta.
@Param cCodAsJur  - Código do Tipo de Assunto Jurídico.
@Param cRotina    - Informa a Rotina que está chamando a J163AtPeCo().

@since   09/07/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J163AtPeCo(cPesquisa, aCaso, aDelCorres, aIncCorres, cCodAsJur, cRotina)
	Local aArea      := GetArea()
	Local cQuery     := ""
	Local cErro      := ""
	Local cNomeUseId := ""
	Local cColId     := ""
	Local cEndEmail  := ""
	Local cWhere     := ""
	Local nVezes     := 0
	Local nRegs      := 0
	Local nCont      := 0
	Local aUsuarios  := {}
	Local aRetorno   := {}
	Local aGuardaUsu := {}
	Local lInclui    := .T.
	Local cUsuario   := AllTrim( SuperGetMV('MV_ECMUSER',,"") )
	Local cSenha     := AllTrim( SuperGetMV('MV_ECMPSW' ,,"") )
	Local cEmpresa   := AllTrim( SuperGetMV('MV_ECMEMP' ,,"") )
	Local cPasta     := JurGetDados("NZ7", 1, xFilial("NZ7") + aCaso[1] + aCaso[2] + aCaso[3], "NZ7_LINK") 	//NZ7_FILIAL+NZ7_CCLIEN+NZ7_LCLIEN+NZ7_NUMCAS

	Default cCodAsJur  := ""
	Default cRotina    := ""

	ProcRegua(0)
	IncProc()
	IncProc()

	//Pega codigo da pasta do fluig
	cPasta := SubStr(cPasta, 1, At(";", cPasta) - 1)

	If !Empty(cPasta)

		DbSelectArea("NVK")
		NVK->( DbSetOrder(1) )

		For nVezes:=1 To 2

			lInclui	:= .F.
			cWhere	:= ""
			aRetorno:= {}

			//Carrega where de correspondente que terão a permissão excluida
			If Len(aDelCorres) > 0
				lInclui := .F.
				cWhere  := " AND ( "

				For nCont:=1 To Len(aDelCorres)
					cWhere += "(NVK_CCORR = '" +aDelCorres[nCont][1]+ "' AND NVK_CLOJA = '" +aDelCorres[nCont][2]+ "') OR"
				Next nCont

				cWhere     := SubStr(cWhere, 1, Len(cWhere) - 2) + " )"
				aDelCorres := {}
			EndIf

			//Carrega where de correspondente que terão a permissão incluida
			If Empty(cWhere) .And. Len(aIncCorres) > 0
				lInclui := .T.
				cWhere 	:= " AND ( "

				For nCont:=1 To Len(aIncCorres)
					cWhere += "(NVK_CCORR = '" +aIncCorres[nCont][1]+ "' AND NVK_CLOJA = '" +aIncCorres[nCont][2]+ "') OR"
				Next nCont

				cWhere 	   := SubStr(cWhere, 1, Len(cWhere) - 2) + " )"
				aIncCorres := {}
			EndIf

			//Não tem mais correspondentes a processar
			If Empty(cWhere)
				Exit
			EndIf

			//Busca os usuario relacionados aos correspondentes
			cQuery := " SELECT NVK_CGRUP, NVK_CUSER "
			cQuery += " FROM " + RetSqlName("NVK") + " NVK "
			cQuery += " INNER JOIN " + RetSqlName("NVJ") + " NVJ ON NVK_CPESQ = NVJ_CPESQ "
			cQuery +=              "AND NVK_FILIAL = NVJ_FILIAL "
			cQuery += " WHERE NVK_FILIAL = '" + xFilial("NVK") + "'"

			If !Empty(cPesquisa)
				cQuery += " AND NVK_CPESQ = '" + cPesquisa + "'"
			Else
				cQuery += " AND NVJ_CASJUR = '" + cCodAsJur + "'"
			EndIf

			cQuery += 	" AND NVK.D_E_L_E_T_ = ' '"
			cQuery += 	" AND NVJ.D_E_L_E_T_ = ' '"
			cQuery += 	cWhere
			cQuery += " GROUP BY NVK_CGRUP, NVK_CUSER"

			aRetorno := JurSQL(cQuery, {"NVK_CGRUP", "NVK_CUSER"})

			For nRegs:=1 To Len(aRetorno)

				aUsuarios := {}

				//Carrega os usuarios dos grupos
				If !Empty(aRetorno[nRegs][1])
					aUsuarios := JA163GrUsu(aRetorno[nRegs][1], aRetorno[nRegs][1])

					//Carrega usuario
				Else
					Aadd(aUsuarios, {aRetorno[nRegs][2]})
				EndIf

				For nCont := 1 To Len(aUsuarios)

					cEndEmail := AllTrim( UsrRetMail(aUsuarios[nCont][1]) )

					IncProc( I18n(STR0122, {cEndEmail}) ) //"Atualizando. (#1)"

					If !Empty(cEndEmail) .And. aScan( aGuardaUsu, {|x| AllTrim(x[1]) == AllTrim(cEndEmail)} ) == 0

						//Carrega o Id do usuario no fluig
						cColId := JColId(cUsuario, cSenha, cEmpresa, cEndEmail, @cErro, .F.)

						If Empty(cColId) .And. !Empty(cErro)
							Aadd(aGuardaUsu, {cEndEmail, cColId, cErro})
							loop
						EndIf

						//Altera permissão dos correspondentes
						J163SetPer(cPasta, cUsuario, cSenha, cEmpresa, "1", cColId, lInclui)

						Aadd(aGuardaUsu, {cEndEmail, cColId, ""})
					Else
						If Empty(cEndEmail)
							cEndEmail := UsrRetName( aUsuarios[nCont][1] )

							If Len(aGuardaUsu) > 0 .And. aScan(aGuardaUsu, { |x| cEndEmail == x[2] }) == 0
								Aadd(aGuardaUsu, {cEndEmail, cEndEmail, I18n(STR0134, {cEndEmail})})
							EndIf
						EndIf
					EndIf

				Next nCont
			Next nRegs
		Next nVezes

		If cRotina == "TJurAnxFluig" .And. Len(aGuardaUsu) > 0
			cErro      := ""
			cEndEmail  := ""
			cNomeUseId := AllTrim( UsrRetMail(__cUserID) )

			If Empty(cNomeUseId)
				cNomeUseId := UsrRetName( __cUserID )
			EndIf

			If aScan( aGuardaUsu, { |x| !Empty(x[3]) } ) > 0
				For nCont := 1 to Len(aGuardaUsu)
					If !Empty(aGuardaUsu[nCont][3])
						If STR0098 $ aGuardaUsu[nCont][3]
							cErro := STR0098 //"Objeto XML nao criado, verificar a estrutura do XML"
						Else
							If (cNomeUseId == aGuardaUsu[nCont][1])
								cEndEmail := aGuardaUsu[nCont][1] + CRLF
								Exit
							EndIf
						EndIf
					EndIf
				Next

				If !Empty(cEndEmail)
					cErro := I18n(STR0134, {cEndEmail}) //"Usuário #1 não está ativo no Fluig!"
				EndIf

				If !Empty(cErro) .And. !JurAuto()
					JurMsgErro('JColId: ' + cErro)
				EndIf
			EndIf
		EndIf
	Else
		JurConOut(STR0123, {"NZ7_LINK"})	//"Caso sem link com o Fluig: #1"
	EndIf

	aSize(aRetorno , 0)
	aSize(aUsuarios, 0)

	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J163RelUsr
Relatório simplificado de Usuario

@author Brenno Gomes
@since 16/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J163EXPUSR(cArquivo)
	Local oExcel    := FWMSEXCEL():New()
	Local aDados    := J163QRLUSR()
	Local nI,nX     := 0
	Local cExtens   := "Arquivo " + " XLS | *.xls"  //"Arquivo"
	Local lHtml     := (GetRemoteType() == 5)  //Valida se o ambiente é SmartClientHtml
	Local cFunction := "CpyS2TW"
	Local cPathS    := "\SPOOL\"  //Caminho onde o arquivo será gerado no servidor
	Local aColumn   := {}
	local cArq      := cPathS + JurTimeStamp(1) + "_" + STR0127 + "_" + RetCodUsr() +".xls"//arquivo temporario gerado no \spool\, se for HTML o arquivo se mantém

	DEFAULT cArquivo := ""
	//Escolha o local para salvar o arquivo
	//Se for o html, não precisa escolher o arquivo
	If Empty(cArquivo)
		If !lHtml
			cArquivo := cGetFile(cExtens, STR0128, , 'C:\', .F., nOr(GETF_LOCALHARD, GETF_NETWORKDRIVE), .F.)	//"Salvar como"
		Endif
	EndIf

	If At(".xls",cArquivo) == 0
		cArquivo += ".xls"
	Endif

	aAdd(aColumn,{ "GRUPO", "PESQUISA" , "NOME", "E-MAIL", "CPF", "USUARIO"})
	//Gerando o arquivo

	oExcel:AddworkSheet(STR0126) //"Usuarios"
	oExcel:AddTable (STR0126,STR0127)// Usuarios / "Relatório de Usuario"

	//gerando as colunas
	For nX := 1 to Len(aColumn[1])
		oExcel:AddColumn(STR0126,STR0127,aColumn[1][nX],1,1,.F.)
	End
	//gerando as linhas
	For nI := 1 To Len(aDados)
		oExcel:AddRow(STR0126,STR0127,aDados[nI])
	End

	oExcel:Activate()

	If oExcel:GetXMLFile(cArq)
		If !lHtml
			If File(cArq)
				If __copyfile( cArq, cArquivo ) //copia o arquivo local
					FErase(cArq)
					If !IsBlind() .And. ApMsgYesNo(I18n(STR0129,{cArquivo}))	//"Deseja abrir o arquivo #1 ?"
						nRet := ShellExecute('open', cArquivo , '', "C:\", 1)
					EndIf
				EndIf
			else
				JurMsgErro(I18n(STR0130,{cArq}))	//"O arquivo #1 não pode ser aberto "
			EndIf

		ElseIf FindFunction(cFunction)
			//Executa o download no navegador do cliente
			nRet := CpyS2TW(cArq,.T.)
			If nRet == 0
				If !IsBlind()
					MsgAlert(STR0131 )	//"Download feito com sucesso"
				EndIf
			Else
				JurMsgErro(STR0132)	//"Erro ao efetuar o download do arquivo"
			EndIf
		Endif
	Else
		JurMsgErro(STR0133)	//"Erro ao gerar arquivo"
	EndIf

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} J163QRLUSR
Monta a query para o relatório simplicado de usuario

@author Brenno Gomes
@since 16/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J163QRLUSR()
	Local aDados    := {}
	Local cQuery    := ''
	Local cSelect   := ''
	Local cWhere    := ''
	Local cFrom     := ''
	Local aArea		:= GetArea()
	Local cAlias    := GetNextAlias()

	cSelect := "SELECT DISTINCT ( RTRIM(NZX_COD) || ' - ' || RTRIM(NZX_DESC) || ' - ' ||"
	cSelect +=                   "(CASE (NZX_TIPOA) WHEN '1' THEN 'INTERNO' WHEN '2' THEN 'CLIENTE' ELSE 'ESCRITÓRIO' END) ) GRUPO, "
	cSelect +=       " NVG_DESC PESQUISA, "
	cSelect +=       " RD0_NOME NOME, "
	cSelect +=       " RD0_EMAIL EMAIL, "
	cSelect +=       " RD0_CIC CPF, "
	cSelect +=       " NZY_CUSER ID_USUARIO "
	cFrom   := "FROM " + RetSqlName("NVK") + " NVK "
	cFrom   +=       " JOIN " + RetSqlName("NVG") + " NVG "
	cFrom   +=         " ON ( NVK.NVK_CPESQ = NVG.NVG_CPESQ ) "
	cFrom   +=       " JOIN " + RetSqlName("NZX") + " NZX
	cFrom   +=         " ON ( NZX.NZX_FILIAL ='" + xFilial("NZX") + "'"
	cFrom   +=              " AND NVK.NVK_CGRUP = NZX.NZX_COD "
	cFrom   +=              " AND NZX.D_E_L_E_T_ = ' ' ) "
	cFrom   +=        " JOIN " + RetSqlName("NZY") + " NZY"
	cFrom   +=          " ON ( NZY.NZY_CGRUP = NZX.NZX_COD"
	cFrom   +=               " AND NZY.D_E_L_E_T_ = ' '"
	cFrom   +=               " AND NZY.NZY_FILIAL = '" + xFilial("NZY") + "' )"
	cFrom   +=        " JOIN " + RetSqlName("RD0") + " RD0 "
	cFrom   +=          " ON ( RD0.RD0_USER = NZY.NZY_CUSER "
	cFrom   +=               " AND RD0.D_E_L_E_T_ = ' ' ) "
	cWhere  := "WHERE  NVG.NVG_FILIAL = '" + xFilial("NVG") + "'"
	cWhere  +=       " AND NVK.NVK_FILIAL = '" + xFilial("NVK") + "'"
	cWhere  +=       " AND NVG.D_E_L_E_T_ = ''"
	cWhere  +=       " AND NVK.D_E_L_E_T_ = '' "
	cWhere  += "UNION "
	cWhere  += "SELECT DISTINCT ( 'USUÁRIO - ' || COALESCE(RTRIM(RD0_NOME),NVK_CUSER) || ' - ' || ( CASE (NVK_TIPOA) "
	cWhere  +=                   " WHEN '1' THEN 'INTERNO' "
	cWhere  +=                   " WHEN '2' THEN 'CLIENTE' "
	cWhere  +=                   " ELSE 'ESCRITÓRIO' END ) ) GRUPO, "
	cWhere  +=                " NVG_DESC PESQUISA, RD0_NOME NOME, "
	cWhere  +=                " RD0_EMAIL EMAIL, RD0_CIC CPF, NVK_CUSER ID_USUARIO "
	cWhere  += "FROM " + RetSqlName("NVK") + " NVK "
	cWhere  +=      " JOIN " + RetSqlName("NVG") + " NVG "
	cWhere  +=        " ON ( NVK.NVK_CPESQ = NVG.NVG_CPESQ ) "
	cWhere  +=      " JOIN " + RetSqlName("RD0") + " RD0 "
	cWhere  +=        " ON ( RD0.RD0_USER = NVK.NVK_CUSER "
	cWhere  +=             " AND RD0.D_E_L_E_T_ = ' ' ) "
	cWhere  += "WHERE  NVG.NVG_FILIAL = '" + xFilial("NVG") + "'"
	cWhere  +=       " AND NVK.NVK_FILIAL = '" + xFilial("NVK") + "'"
	cWhere  +=       " AND NVG.D_E_L_E_T_ = ' '"
	cWhere  +=       " AND NVK.D_E_L_E_T_ = ' '"
	cWhere  +=       " AND NVK.NVK_CUSER > ' ' "
	cWhere  += "ORDER  BY GRUPO, PESQUISA, NOME "

	cQuery := cSelect + cFrom + cWhere

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery ), cAlias,.T.,.T.)

	While !(cAlias)->( Eof() )

		aAdd(aDados,{ Alltrim((cAlias)->GRUPO), Alltrim((cAlias)->PESQUISA), Alltrim((cAlias)->NOME), Alltrim((cAlias)->EMAIL), Alltrim((cAlias)->CPF), Alltrim(USRRETNAME((cAlias)->ID_USUARIO))})

		(cAlias)->( dbSkip() )
	End
	restArea(aArea)
Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} J163Obriga
Função criada para ser utilizada no X3_WHEN do campo NUZ_OBRIGA.
Verifica a obrigatoriedade do campo(NUZ_CAMPO) no SX3 e utiliza o
retorno para preencher a flag de obrigatoriedade ao adicionar um
campo na configuração de pesquisa por assunto jurídico

@Return lRet (T/F)
@since 12/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J163Obriga()

	Local lRet
	Local oModel := FwModelActive()
	Local cCampo := oModel:GetValue('NUZDETAIL','NUZ_CAMPO')

	lRet := !X3Obrigat(cCampo)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JRemPermFl(cCodNVK)
Remove a permissão de Pasta do Fluig

@param cCodNVK - Código da Relação

@since 22/01/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function JRemPermFl(cCodNVK)
	Local cAliasNVK  := Nil
	Local aGuardaUsu := {}
	Local cQrySel    := ""
	Local cQryFrm    := ""
	Local cQryWhr    := ""
	Local cQryOrd    := ""
	Local cQuery     := ""
	Local cCodPasta  := ""
	Local cColIdRem  := ""
	Local cUsuRem    := ""
	Local cErro      := ""
	Local cUsuario   := AllTrim(SuperGetMV('MV_ECMUSER',,""))
	Local cSenha     := AllTrim(SuperGetMV('MV_ECMPSW' ,,""))
	Local nEmpresa   := AllTrim(SuperGetMV('MV_ECMEMP' ,,0))

	ProcRegua(0)
	IncProc()

	cQrySel := " SELECT NSZ.NSZ_NUMCAS, "
	cQrySel +=        " NVK.NVK_CUSER, "
	cQrySel +=        " NZY.NZY_CUSER, "
	cQrySel +=        " NVK.NVK_TIPOA, "
	cQrySel +=        " NZ7.NZ7_LINK "
	cQryFrm := " FROM " + RetSqlName("NVK") + " NVK INNER JOIN " + RetSqlName("NUQ") + " NUQ ON (NUQ.NUQ_CCORRE = NVK.NVK_CCORR "
	cQryFrm +=                                                                             " AND NUQ.NUQ_LCORRE = NVK.NVK_CLOJA "
	cQryFrm +=                                                                             " AND NUQ.D_E_L_E_T_ = ' ') "
	cQryFrm +=                                    " INNER JOIN " + RetSqlName("NSZ") + " NSZ ON (NSZ.NSZ_COD = NUQ.NUQ_CAJURI "
	cQryFrm +=                                                                             " AND NSZ.NSZ_FILIAL = NUQ.NUQ_FILIAL "
	cQryFrm +=                                                                             " AND NSZ.D_E_L_E_T_ = ' ') "
	cQryFrm +=                                    " INNER JOIN " + RetSqlName("NZ7") + " NZ7 ON (NZ7.NZ7_CCLIEN = NSZ.NSZ_CCLIEN
	cQryFrm +=                                                                             " AND NZ7.NZ7_LCLIEN = NSZ.NSZ_LCLIEN "
	cQryFrm +=                                                                             " AND NZ7.NZ7_NUMCAS = NSZ.NSZ_NUMCAS "
	cQryFrm +=                                                                             " AND NZ7.D_E_L_E_T_ = ' ') "
	cQryFrm +=                                    " LEFT JOIN  " + RetSqlName("NZY") + " NZY ON (NZY.NZY_CGRUP = NVK.NVK_CGRUP "
	cQryFrm +=                                                                             " AND NZY.D_E_L_E_T_ = ' ') "
	cQryWhr := " WHERE NVK.NVK_COD = '" + cCodNVK + "' "
	cQryWhr +=   " AND NVK.D_E_L_E_T_ = ' ' "
	cQryOrd := " ORDER BY NZ7.NZ7_LINK, NVK.NVK_CUSER, NZY.NZY_CUSER "

	cAliasNVK := GetNextAlias()
	cQuery := ChangeQuery(cQrySel + cQryFrm + cQryWhr)

	DbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAliasNVK, .T., .T.)

	While(cAliasNVK)->(!Eof())
		If Empty((cAliasNVK)->NVK_CUSER)
			cUsuRem := (cAliasNVK)->NZY_CUSER
		Else
			cUsuRem := (cAliasNVK)->NVK_CUSER
		Endif

		cEndEmail := AllTrim( UsrRetMail(cUsuRem) )

		IncProc( cEndEmail )

		cCodPasta := SubStr((cAliasNVK)->NZ7_LINK, 1, At(";", (cAliasNVK)->NZ7_LINK) - 1)

		If !Empty(cEndEmail) .And. aScan( aGuardaUsu, {|x| AllTrim(x[1]) == AllTrim(cEndEmail) .And. x[4] == cCodPasta} ) == 0

			//Carrega o Id do usuario no fluig
			cColIdRem := JColId(cUsuario, cSenha, nEmpresa, cEndEmail, @cErro, .F.)

			If Empty(cColIdRem) .And. !Empty(cErro)
				If aScan(aGuardaUsu, { |x| cColIdRem == x[2] .And. !Empty(x[3]) }) == 0
					Aadd(aGuardaUsu, {cEndEmail, cColIdRem, cErro, cCodPasta})
				EndIf

				(cAliasNVK)->( DbSkip())
				loop
			EndIf

			J163SetPer( cCodPasta, cUsuario, cSenha, nEmpresa, "1", cColIdRem, .F.)

			Aadd(aGuardaUsu, {cEndEmail, cColIdRem, "", cCodPasta})
		Else
			If Empty(cEndEmail)
				cEndEmail := UsrRetName( cUsuRem )

				If Len(aGuardaUsu) > 0 .And. aScan(aGuardaUsu, { |x| cEndEmail == x[2] }) == 0
					Aadd(aGuardaUsu, {cEndEmail, cEndEmail, I18n(STR0134, {cEndEmail})})
				EndIf
			EndIf
		EndIf

		(cAliasNVK)->( DbSkip())
	EndDo

	(cAliasNVK)->( DbCloseArea() )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} onChangeGrupo(oBrw)
Recarrega o browse de grupos na primeira linha
@param oBrw - Browse dos grupos
@since 10/12/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function onChangeGrupo(oBrw)
	oBrw:oData:GoTop()
	oBrw:Refresh()
Return 
