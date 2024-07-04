#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PCPA103.CH'

#DEFINE  CABECALHO "CZF_TPMP/CZF_DSTPMP/CZF_CDGRIV/CZF_DSGRIV/CZF_CDRC/CZF_DSRC/CZF_CDFATD/CZF_DSFATD/"
//-----------------------------------------------------------------
/*/{Protheus.doc} PCPA103
Tela de alocação de template

@author Lucas Konrad França
@since 10/09/2013
@version P12
/*/
//-----------------------------------------------------------------
Function PCPA103()
	Local oBrowse
	Private aCoors     := FWGetDialogSize( oMainWnd )
	Private aTempDisp  := { }
	Private aAtrDisp   := { }
	Private aTempSelec := { }
	Private aAtrSel    := { }
	Private cTipoCad   := ""
	Private oBrwAtrSel, oBrowseTmp, oBrwAtrDis, oBrwTmpSel

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('CZF') 
	oBrowse:SetMenuDef( 'PCPA103' )
	oBrowse:SetDescription( STR0001 ) //Alocação de template
	oBrowse:Activate()

Return NIL

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Camada Model do MVC.

@author  Lucas Konrad França
@since   17/09/2013
@version 1.0s
/*/
//---------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruCZF := FWFormStruct( 1, 'CZF', { |cCampo|  AllTrim( cCampo ) + '/' $ CABECALHO } ,/*lViewUsado*/ )
	Local oStruDet := FWFormStruct( 1, 'CZF', { |cCampo| !AllTrim( cCampo ) + '/' $ CABECALHO } ,/*lViewUsado*/ )
	Local oModel
	oModel := MPFormModel():New( 'PCPA103', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'CZFMASTER', /*cOwner*/, oStruCZF )
	oModel:AddGrid( 'CZFDETAIL', 'CZFMASTER', oStruDet)
	oModel:SetRelation( 'CZFDETAIL', { { 'CZF_FILIAL', "xFilial( 'CZF' )" } , { 'CZF_CDGRIV', 'CZF_CDGRIV' } , { 'CZF_TPMP', 'CZF_TPMP' }, { 'CZF_CDRC', 'CZF_CDRC' }, {'CZF_CDFATD','CZF_CDFATD'} }, CZF->( IndexKey( 1 ) ) )
	oModel:SetDescription( STR0001 ) //Alocação de template

	oModel:GetModel( 'CZFDETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'CZFMASTER' ):SetDescription( STR0002 ) //Materiais/Recursos
	oModel:SetPrimaryKey({"CZF_CDGRIV", "CZF_TPMP", "CZF_CDRC", "CZF_CDFATD", "CZF_CDMD"})
Return oModel

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu de Operações MVC

@author  Lucas Konrad França
@since   17/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina := {}
	ADD OPTION aRotina Title STR0003 Action 'PCPA103CTL(2)' OPERATION 2 ACCESS 0 //Visualizar
	ADD OPTION aRotina Title STR0004 Action 'PCPA103CTL(3)' OPERATION 3 ACCESS 0 //Incluir
	ADD OPTION aRotina Title STR0005 Action 'PCPA103CTL(4)' OPERATION 4 ACCESS 0 //Alterar
	ADD OPTION aRotina Title STR0006 Action 'PCPA103CTL(5)' OPERATION 5 ACCESS 0 //Excluir
	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.PCPA103' OPERATION 8 ACCESS 0 //Imprimir
Return aRotina

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA103CTL
Função para criação da tela para edição/visualização/inclusão dos dados.

@author  Lucas Konrad França
@since   18/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA103CTL(nOp)

	Local nWidth, nHeight, nLinIni, nColIni, nCalcWidth, nCalcHeight, nCalcLinIni, nCalcColIni
	Local nPerc
	Local aChoice   := {}
	Local aNoFields := {}
	Local aTam      := {}
	Local nRecNo    := 0
	Local oPnlMst, oPnlDetE, oPnlDetC, oPnlDetD
	Local nOpca
	Private nOpcao := nOp
	Private oEnch

	cTipoCad := ""
	
	nLinIni := 0
	nColIni := 5
	nHeight := aCoors[3]
	nWidth  := aCoors[4]
	
	DEFINE MSDIALOG oDlg FROM nLinIni, 0 TO nHeight, nWidth TITLE STR0001 PIXEL//Dialog de alocação

	If Val(getVersao(.F.)) < 12
		If FlatMode()
			nLinIni := aCoors[1]+10
		Else
			nLinIni := 10
		EndIf
	EndIf
	
	//Cria o painel mestre que irá conter os painels.
	nWidth  := nWidth*0.50
	
	oPnlMst := tPanel():Create(oDlg, nLinIni, nColIni,,,,,,/*CLR_RED*/,nWidth,/*nHeight*/)
	oPnlMst:Align := CONTROL_ALIGN_ALLCLIENT

	If nOp == 3
		nRecNo := Nil
	Else
		nRecNo := CZF->(RecNo())
	EndIf

	Aadd(aNoFields,"CZF_CDMD")
	Aadd(aNoFields,"CZF_NMMD")
	aChoice := addCampos("CZF",aNoFields)

	DbSelectArea("CZF")
	If nOp == 3
		RegtoMemory("CZF",.T.)
		aTempDisp := {{'',''}}
		aTempSelec := {{'',''}}
	Else
		RegtoMemory("CZF",.F.)
		cargaDados()
	EndIf
	
	nCalcHeight := Round((nHeight*0.1)/2, 0)
	nCalcWidth  := Round(nWidth * 0.1, 0)
	
	aAdd(aTam, nLinIni)
	aAdd(aTam, nColIni)
	aAdd(aTam, nCalcWidth)
	aAdd(aTam, nCalcHeight)
	
	//Cria o enchoice dos campos superiores.
		
	oEnch := MsMGet():New("CZF",nRecNo,nOp,,,,aChoice,aTam,,,,,,oPnlMst,,,.F.)
	oEnch:oBox:Align := CONTROL_ALIGN_TOP

	//cria o grupo de campos para os templates disponíveis
	nCalcLinIni := nCalcWidth + 5
	nCalcHeight := Round(nHeight * 0.45, 0)
	nCalcWidth  := Round(nWidth * 0.43, 0)
	nCalcColIni := nColIni
	
	oGroupD := TGroup():New(nCalcLinIni, nCalcColIni, nCalcHeight, nCalcWidth, STR0031, oPnlMst,,,.T.)
	 
	//cria o painel para os templates disponíveis
	nCalcWidth  := Round(nWidth * 0.40, 0)
	nCalcHeight := Round(nHeight * 0.32, 0)
	nCalcColIni := nCalcColIni + 5
	nCalcLinIni := nCalcLinIni + 10
	
	oPnlDetE := tPanel():Create(oPnlMst, nCalcLinIni, nCalcColIni,,,,,,/*CLR_BLUE*/, nCalcWidth, nCalcHeight)

	//cria as grids do template disponível
	nCalcHeight := Round(nHeight * 0.28, 0)
	criaGridD(oPnlDetE, nCalcLinIni, nCalcColIni, nCalcWidth, nCalcHeight)
	
	//cria o painel para os botões de controle.
	nCalcColIni := nCalcColIni+nCalcWidth + 15
	nCalcWidth  := Round(nWidth  * 0.10, 0)
	nCalcHeight := Round(nHeight * 0.15, 0)
	If(nCalcHeight < 140, nCalcHeight := 140, Nil)
	oPnlDetC := tPanel():Create(oPnlMst, nCalcLinIni, nCalcColIni,,,,,,/*CLR_YELLOW*/, nCalcWidth, nCalcHeight)

	//cria os botões de controle
	criaBotoes(oPnlDetC)

	//cria o grupo de campos para os templates selecionados	
	nCalcLinIni := nCalcWidth + 5
	nCalcColIni := nCalcColIni+nCalcWidth + 5
	nCalcHeight := Round(nHeight * 0.45, 0)
	nCalcWidth  := Round(nWidth  * retVersion(0.98, 0.98, 0.98), 0)
	
	oGroupS := TGroup():New(nCalcLinIni, nCalcColIni, nCalcHeight, nCalcWidth, STR0030,oPnlMst,,,.T.)	

	//cria o painel para os templates selecionados
	nCalcWidth  := Round(nWidth  * 0.40, 0)
	nCalcHeight := Round(nHeight * 0.32, 0)
	nCalcColIni := nCalcColIni + 5
	nCalcLinIni := nCalcLinIni + 10
	
	oPnlDetD := tPanel():Create(oPnlMst, nCalcLinIni, nCalcColIni,,,,,, /*CLR_BLUE*/, nCalcWidth, nCalcHeight)

	//cria as grids dos templates selecioados	
	nCalcHeight := Round(nHeight * 0.28, 0)
	criaGridS(oPnlDetD,nCalcLinIni,nCalcColIni,nCalcWidth,nCalcHeight)
	
	ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,{|| nOpca := 1, If(PCPA103CFR(oDlg, nOp),oDlg:End(),)},{|| nOpca := 2,oDlg:End()}) CENTERED

Return .T.

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} criaGridS
Criação das grids de templates e atributos que estão selecionados.

@param   oPanel       Container onde seram criados os componentes

@author  Lucas Konrad França
@since   19/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function criaGridS(oPanel,nLinIni,nColIni,nWidth,nHeight)

	//array carregado antes da chamada desta função. (função cargaDados() )
	If Len(aTempSelec) < 1
		aTempSelec:={{'',''}}
	EndIf

	//Browse dos templates selecionados
	oBrwTmpSel := TWBrowse():New(0,0,nWidth,(nHeight*0.70),,{STR0009,STR0010},{60,100},oPanel,,,,{||cargaAtr("S")},,,,,,,,.F.,,.T.,,.F.,,.T.,.F.)
	oBrwTmpSel:SetArray(aTempSelec)
	oBrwTmpSel:bLine := {||{ aTempSelec[oBrwTmpSel:nAt][1],aTempSelec[oBrwTmpSel:nAt][2] }}
	aAtrSel:= { {'','',''} }

	//Browse dos Atributos dos templates selecionados
	oBrwAtrSel := TWBrowse():New((nHeight*0.70)+1,0,nWidth,(nWidth*0.30),,{STR0011,STR0010,STR0012},{60,100,30},oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,.T.,.F.)
	oBrwAtrSel:SetArray(aAtrSel)
	oBrwAtrSel:bLine := {||{aAtrSel[oBrwAtrSel:nAT,1],aAtrSel[oBrwAtrSel:nAt,02],aAtrSel[oBrwAtrSel:nAt,03]}}

Return .T.
//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} criaGridD
Criação das grids de templates e atributos que estão disponíveis para seleção.

@param   oPanel       Container onde seram criados os componentes

@author  Lucas Konrad França
@since   19/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function criaGridD(oPanel,nLinIni,nColIni,nWidth,nHeight)

	//array carregado antes da chamada desta função. (função cargaDados() )	
	If Len(aTempDisp) < 1
		aTempDisp := {{'',''}}
	EndIf
	//Browse dos templates disponíveis
	oBrowseTmp := TWBrowse():New(0,0,nWidth,(nHeight*0.70),,{STR0009,STR0010},{60,100},oPanel,,,,{||cargaAtr("D")},,,,,,,,.F.,,.T.,,.F.,,.T.,.F.)
	oBrowseTmp:SetArray(aTempDisp)
	oBrowseTmp:bLine := {||{ aTempDisp[oBrowseTmp:nAT,1],aTempDisp[oBrowseTmp:nAt,02]}}

	aAtrDisp:= {{'','',''}}

	//Browse dos Atributos dos templates disponíveis
	oBrwAtrDis := TWBrowse():New((nHeight*0.70)+1,0,nWidth,(nWidth*0.30),,{STR0011,STR0010,STR0012},{60,100,30},oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,.T.,.F.)
	oBrwAtrDis:SetArray(aAtrDisp)
	oBrwAtrDis:bLine := {||{ aAtrDisp[oBrwAtrDis:nAT,1],aAtrDisp[oBrwAtrDis:nAt,02],aAtrDisp[oBrwAtrDis:nAt,03]}}

Return .T.

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} criaBotoes
Criação dos botões de controle das grids

@param   oPanel       Container onde seram criados os componentes

@author  Lucas Konrad França
@since   19/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function criaBotoes(oPanel)
	Local nColuna := ((aCoors[4]*0.07)/2)

	@ 25, nColuna BTNBMP oBtUp01 Resource "RIGHT"  Size 29,29 Pixel Of oPanel Noborder Pixel Action moveSel('ADD',@aTempSelec, @aTempDisp, @oBrowseTmp, @oBrwTmpSel)
	oBtUp01:cToolTip := STR0026 // "Adicionar selecionado"
	@ 60, nColuna BTNBMP oBtUp02 Resource "LEFT"   Size 29,29 Pixel Of oPanel Noborder Pixel Action moveSel('RMV',@aTempSelec, @aTempDisp, @oBrowseTmp, @oBrwTmpSel)
	oBtUp02:cToolTip := STR0027 //"Remover selecionado"
	@ 95,nColuna BTNBMP oBtUp03 Resource "PGNEXT" Size 29,29 Pixel Of oPanel Noborder Pixel Action moveSel('ADDALL',@aTempSelec, @aTempDisp, @oBrowseTmp, @oBrwTmpSel)
	oBtUp03:cToolTip := STR0028 //"Adicionar todos"
	@ 130,nColuna BTNBMP oBtUp04 Resource "PGPREV" Size 29,29 Pixel Of oPanel Noborder Pixel Action moveSel('RMVALL',@aTempSelec, @aTempDisp, @oBrowseTmp, @oBrwTmpSel)
	oBtUp04:cToolTip := STR0029 //"Remover todos"
Return .T.

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} cargaAtr
Função de carga dos atributos do template selecionado.

@param cBrowse   Identifica em qual browse serão carregadas as informações
	'D' - Browse dos atributos disponíveis
	'S' - Browse dos atributos selecionados

@author  Lucas Konrad França
@since   19/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function cargaAtr(cBrowse)
	Local nLinha
	Local cObrigatorio
	Local aDados := { }
	Local aTemplate := { }
	Local aArea := getArea()

	dbSelectArea("CZE")
	CZE->(dbSetOrder(3))
	CZE->(dbGoTop())
	If cBrowse == 'D'
		aTemplate := ACLONE(aTempDisp)
		nLinha    := oBrowseTmp:nAt
	Else
		aTemplate := ACLONE(aTempSelec)
		nLinha    := oBrwTmpSel:nAt
	EndIf
	If Len(aTemplate) >= 1
		CZE->(dbSeek(xFilial("CZE")+aTemplate[nLinha,1]))
		While CZE->(!EOF()) .AND. CZE->CZE_CDMD == aTemplate[nLinha,1]
			dbSelectArea("CZB")
			CZB->(dbSetOrder(1))
			CZB->(dbSeek(xFilial("CZB")+CZE->CZE_CDAB))
			If CZE->CZE_LGOB == "1"
				cObrigatorio := STR0013
			Else
				cObrigatorio := STR0014
			EndIf
			AADD(aDados,{CZE->CZE_CDAB,CZB->CZB_DSAB,cObrigatorio})
			CZE->(dbSkip())
		End
	Else
		aDados := {{'','',''}}
	EndIf

	If Len(aDados) < 1
		aDados := {{'','',''}}
	EndIf

	If cBrowse == 'D'
		aAtrDisp := ACLONE(aDados)
		oBrwAtrDis:SetArray(aAtrDisp)
		oBrwAtrDis:bLine := {||{ aAtrDisp[oBrwAtrDis:nAT,1],aAtrDisp[oBrwAtrDis:nAt,02],aAtrDisp[oBrwAtrDis:nAt,03]}}
		oBrwAtrDis:Refresh()
	Else
		aAtrSel  := ACLONE(aDados)
		oBrwAtrSel:SetArray(aAtrSel)
		oBrwAtrSel:bLine := {||aAtrSel[oBrwAtrSel:nAT]}
		oBrwAtrSel:Refresh()
	EndIf
	RestArea(aArea)
Return .T.

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} moveSel
Função de movimentação dos templates.

@param cMove     Identificador da movimentação que será realizada
	'RMVALL' Remover todos os templates
	'ADDALL' Adicionar todos os templates
	'ADD'    Adiciona o template selecionado
	'RMV'    Remove o template selecionado

@author  Lucas Konrad França
@since   19/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function moveSel(cMove,aTempSelec, aTempDisp, oBrowseTmp, oBrwTmpSel)
	If nOpcao != 3 .AND. nOpcao != 4
		Return .T.
	EndIf

	If cMove == 'RMVALL' .OR. cMove == 'RMV'
		If Len(aTempSelec) < 1
			Return .T.
		EndIf
	Else
		If Len(aTempDisp) < 1
			Return .T.
		EndIf
	EndIf

	Do Case
		Case cMove == 'RMVALL'
			While( Len(aTempSelec) > 0 )
				If aTempSelec[1][1] != ""
					AADD(aTempDisp,aTempSelec[1])
					ADEL(aTempSelec,1)
					ASIZE(aTempSelec, Len(aTempSelec)-1)
				EndIf
			End
		Case cMove == 'ADDALL'
			While( Len(aTempDisp) > 0 )
				If aTempDisp[1][1] != ""
					AADD(aTempSelec,aTempDisp[1])
					ADEL(aTempDisp,1)
					ASIZE(aTempDisp, Len(aTempDisp)-1)
				EndIf
			End
		Case cMove == 'ADD'
			If aTempDisp[oBrowseTmp:nAt][1] != ""
				AADD(aTempSelec,aTempDisp[oBrowseTmp:nAt])
				ADEL(aTempDisp, oBrowseTmp:nAt)
	        	ASIZE(aTempDisp, Len(aTempDisp)-1)
			EndIf
		Case cMove == 'RMV'
			If aTempSelec[oBrwTmpSel:nAt][1] != ""
				AADD(aTempDisp,aTempSelec[oBrwTmpSel:nAt])
				ADEL(aTempSelec, oBrwTmpSel:nAt)
	        	ASIZE(aTempSelec, Len(aTempSelec)-1)
			EndIf
	End Case
	If Len(aTempSelec) > 0
		If aTempSelec[1,1] == ''
			ADEL(aTempSelec,1)
			ASIZE(aTempSelec, Len(aTempSelec)-1)
		EndIf
	EndIf
	If Len(aTempDisp) > 0
		If aTempDisp[1,1] == ''
			ADEL(aTempDisp,1)
			ASIZE(aTempDisp, Len(aTempDisp)-1)
		EndIf
	EndIf
	oBrowseTmp:Refresh()
	oBrwTmpSel:Refresh()
	cargaAtr('D')
	cargaAtr('S')
Return .T.

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA103VGE
Função de validação do grupo de estoque.

@author  Lucas Konrad França
@since   24/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA103VGE()

	Local lRet := .T.
	If empty(M->CZF_CDGRIV)
		lRet := .T.
	Else
		dbSelectArea("SBM")
		SBM->(dbSetOrder(1))
		If !(SBM->(dbSeek(xFilial("SBM")+M->CZF_CDGRIV)))
			Help( ,, 'Help',, STR0015, 1, 0 ) //Grupo de estoque não cadastrado
			lRet := .F.
		EndIf
	EndIf
	If lRet
		buscaTemp()
	EndIf
Return lRet

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA103VTM
Função de validação do tipo de material.

@author  Lucas Konrad França
@since   25/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA103VTM()
	Local lRet := .T.
	If empty(M->CZF_TPMP)
		lRet := .T.
	Else
		dbSelectArea("SX5")
		SX5->(dbSetOrder(1))
		If !(SX5->(dbSeek(xFilial("SX5")+"02"+M->CZF_TPMP)))
			Help( ,, 'Help',, STR0016, 1, 0 ) //Tipo de material não cadastrado.
			lRet := .F.
		EndIf
	EndIf
	If lRet
		buscaTemp()
	EndIf
Return lRet

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA103VRC
Função de validação do recurso.

@author  Lucas Konrad França
@since   30/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA103VRC()
	Local lRet   := .T.

	If !empty(M->CZF_CDRC)
		dbSelectArea("SH1")
		SH1->(dbSetOrder(1))
		If !(SH1->(dbSeek(xFilial("SH1")+M->CZF_CDRC)))
			Help( ,, 'Help',, STR0017, 1, 0 ) //Recurso não cadastrado.
			lRet := .F.
		EndIf
	EndIf
	If lRet
		buscaTemp()
	EndIf
Return lRet

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA103VRC
Função de validação da familia técnica

@author  Lucas Konrad França
@since   22/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA103VFT()
	Local lRet := .T.

	If !empty(M->CZF_CDFATD)
		DbSelectArea("CZL")
		CZL->(dbSetOrder(1))
		If !(CZL->(dbSeek(xFilial("CZL")+M->CZF_CDFATD)))
			Help( ,, 'Help',, STR0034, 1, 0 ) //Família técnica não cadastrada.
			lRet := .F.
		EndIf
	EndIf
	If lRet
		buscaTemp()
	EndIf
Return lRet

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} cargaDados
Função de carga dos dados dos templates.

@author  Lucas Konrad França
@since   25/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function cargaDados()
	Local nI
	Local cTipo     := Nil
	Local aOldArea  := GetArea()

	aTempSelec := {}
	aTempDisp  := {}
	cTipoCad   := ""
	If nOpcao != 3
		cTipo = tipoCad()
		dbSelectArea("CZF")
		CZF->(dbSetOrder(1))
		CZF->(dbSeek(xFilial("CZF")+M->CZF_CDGRIV;
									+M->CZF_TPMP;
									+M->CZF_CDRC;
									+M->CZF_CDFATD))

		While CZF->(!Eof());
				.AND. CZF->CZF_CDGRIV == M->CZF_CDGRIV;
				.AND. CZF->CZF_TPMP   == M->CZF_TPMP;
				.AND. CZF->CZF_CDRC   == M->CZF_CDRC;
				.AND. CZF->CZF_CDFATD == M->CZF_CDFATD
			dbSelectArea("CZD")
			CZD->(dbSetOrder(1))
			CZD->(dbSeek(xFilial("CZD")+CZF->CZF_CDMD))
			aAdd(aTempSelec,{CZF->CZF_CDMD,CZD->CZD_NMMD})
			CZD->(dbCloseArea())
			CZF->(dbSkip())
		End
		dbSelectArea("CZD")
		CZD->(dbSetOrder(1))
		CZD->(dbGotop())
		While !Eof()
			If aScan(aTempSelec,{|x| AllTrim( x[1] ) == AllTrim(CZD->CZD_CDMD) } ) <= 0
				If cTipo == CZD->CZD_TPMD
					AADD(aTempDisp,{CZD->CZD_CDMD,CZD->CZD_NMMD})
				EndIf
			EndIf
			CZD->(dbSkip())
		End
		CZD->(dbCloseArea())
	EndIf
	RestArea(aOldArea)
Return .T.

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} buscaTemp
Função de carga dos templates possíveis para seleção.

@author  Lucas Konrad França
@since   30/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function buscaTemp()
	Local cTipo    := Nil

	If cTipoCad == "" .OR. cTipoCad != tipoCad()
		If tipoCad() == ""
			limpaGrid()
		EndIf
		aTempDisp := {}
		cTipo = tipoCad()

		dbSelectArea('CZD')
		CZD->(dbSetOrder(2))
		CZD->(dbGoTop())
		CZD->(dbSeek(xFilial("CZD")+cTipo))
		While CZD->(!Eof())
			If CZD->CZD_TPMD == cTipo .AND. aScan(aTempSelec,{|x| AllTrim( x[1] ) == AllTrim(CZD->CZD_CDMD) } ) <= 0
				aAdd(aTempDisp, {CZD->CZD_CDMD, CZD->CZD_NMMD})
			EndIf
			CZD->(dbSkip())
		End
		If len(aTempDisp) < 1
			aTempDisp := {{'',''}}
		EndIf
		oBrowseTmp:SetArray(aTempDisp)
		oBrowseTmp:bLine := {||{ aTempDisp[oBrowseTmp:nAT,1],aTempDisp[oBrowseTmp:nAt,02]}}
		oBrowseTmp:Refresh()
		cargaAtr("D")

		aTempSelec:={{'',''}}

		oBrwTmpSel:SetArray(aTempSelec)
		oBrwTmpSel:bLine := {||{ aTempSelec[oBrwTmpSel:nAt][1],aTempSelec[oBrwTmpSel:nAt][2] }}
		oBrwTmpSel:Refresh()
		cargaAtr("S")

		cTipoCad = tipoCad()
	EndIf
Return .T.

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} tipoCad
Função de verificação do tipo do cadastro. 1 - Produto, 2 - Recurso, 3 - Todos

@author  Lucas Konrad França
@since   03/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function tipoCad()
	Local cTipo    := ""

	If (!empty(M->CZF_TPMP) .OR. !empty(M->CZF_CDGRIV)) .AND. ;
		(empty(M->CZF_CDRC) .AND. empty(M->CZF_CDFATD))
		cTipo := "1"
	Else
		If !empty(M->CZF_CDRC) .AND. ;
			(empty(M->CZF_TPMP) .AND. empty(M->CZF_CDGRIV) .AND. empty(M->CZF_CDFATD))
			cTipo := "2"
		Else
			If !empty(M->CZF_CDRC) .AND. (!empty(M->CZF_TPMP) .OR. !empty(M->CZF_CDGRIV)) .AND. ;
				empty(M->CZF_CDFATD)
				cTipo := "3"
			Else
				If !empty(M->CZF_CDFATD) .AND. ;
					(empty(M->CZF_CDRC) .AND. empty(M->CZF_TPMP) .AND. empty(M->CZF_CDGRIV))
					cTipo := "4"
				Else
					If (!empty(M->CZF_CDFATD) .AND. !empty(M->CZF_CDRC)) .AND.;
						(empty(M->CZF_TPMP) .AND. empty(M->CZF_CDGRIV))
						cTipo := "5"
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return cTipo

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} limpaGrid
Função para inicialização das grids da tela.

@author  Lucas Konrad França
@since   03/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function limpaGrid()

	aTempDisp := {{'',''}}
	oBrowseTmp:SetArray(aTempDisp)
	oBrowseTmp:bLine := {||{ aTempDisp[oBrowseTmp:nAT,1],aTempDisp[oBrowseTmp:nAt,02]}}
	oBrowseTmp:Refresh()
	cargaAtr("D")

	aTempSelec:={{'',''}}

	oBrwTmpSel:SetArray(aTempSelec)
	oBrwTmpSel:bLine := {||{ aTempSelec[oBrwTmpSel:nAt][1],aTempSelec[oBrwTmpSel:nAt][2] }}
	oBrwTmpSel:Refresh()
	cargaAtr("S")

Return .T.

//--------------------------------------------------------------------//
Static Function addCampos(cVALIAS,vVNCAMPO,lBROWSE, lUser, lTodo)
	Local vCAMPOSX3 := {}
	local aCZF      := FWFormStruct( 3,(cVALIAS))
	Local aArea     := GetArea()
	Local nCount      := 0

	Default cVALIAS  := Alias()
	Default vVNCAMPO := {}
	Default lBROWSE  := .F.
	Default lUser    := .T.
	Default lTodo    := .F.


	For nCount := 1 To Len(aCZF[3])
	
	    If ( cNivel >= GetSx3Cache(aCZF[3,nCount,1],'X3_NIVEL' )) .Or. lTodo
	       If Ascan(vVNCAMPO,{|x| Alltrim(Upper(x)) == Alltrim(aCZF[3,nCount,1])}) == 0
	     
	           if AllTrim(aCZF[3,nCount,15]) /*'X3_BROWSE'*/ != 'S' .And. lBROWSE
	     	   else
	     	   		if GetSx3Cache(aCZF[3,nCount,1],'X3_PROPRI') == 'U' .And. !lUser     	   		
	     	   		else
	     	   		 	aAdd(vCAMPOSX3,AllTrim(aCZF[3,nCount,1]))
	     	   	    end if 
	           end if 
	       end if     
		EndIf
	Next nCount
		
	RestArea(aArea)

Return vCAMPOSX3

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA103CFR
Função para validação dos dados.

@param oDlg	referência da Dialog
@param nOp		Operação que está sendo efetuada.

@author  Lucas Konrad França
@since   18/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA103CFR(oDlg, nOp)
	Local nI
	Local cTipo      := Nil
	Local cMens      := Nil

	If nOp == 2
		Return .T.
	EndIf

	If empty(M->CZF_CDGRIV) .AND.;
	   empty(M->CZF_TPMP)   .AND.;
	   empty(M->CZF_CDRC)   .AND.;
	   empty(M->CZF_CDFATD)
		Help( ,, 'Help',, STR0018, 1, 0 ) //Informe o Grupo de estoque, Tipo material, Recurso ou Família técnica.
		Return .F.
	EndIf

	If oBrwTmpSel:nLen < 1 .OR. (oBrwTmpSel:nLen == 1 .AND. aTempSelec[1][1] == "")
		Help( ,, 'Help',, STR0019, 1, 0 ) //Necessário selecionar ao menos um template
		Return .F.
	EndIf

	If nOp != 5 .AND. nOp != 4 //diferente de alteração e exclusão
		dbSelectArea("CZF")
		CZF->(dbSetOrder(1))
		If CZF->(dbSeek(xFilial("CZF")+M->CZF_CDGRIV+M->CZF_TPMP+M->CZF_CDRC+M->CZF_CDFATD))
			Help( ,, 'Help',, STR0020, 1, 0 ) //Já existe uma alocação de template cadastrada para este Grupo de estoque/Tipo material/Recurso/Família técnica.
			Return .F.
		EndIf
	EndIf

	If nOp != 5 //diferente de exclusão
		cTipo = tipoCad()
		For nI := 1 To oBrwTmpSel:nLen
			If !empty(aTempSelec[nI][1])
				dbSelectArea("CZD")
				CZD->(dbSetOrder(1))
				If CZD->(dbSeek(xFilial("CZD")+aTempSelec[nI][1]))
					If CZD->CZD_TPMD != cTipo
						Do Case
							Case cTipo == "1"
								cDescTipo := STR0021
							Case cTipo == "2"
								cDescTipo := STR0022
							Case cTipo == "3"
								cDescTipo := STR0023
							Case cTipo == "4"
								cDescTipo := STR0032
							Case cTipo == "5"
								cDescTipo := STR0033
						EndCase
						cMens := STR0024 + cDescTipo + STR0025 + ". " + STR0009 + " " + aTempSelec[nI][1]
						Help( ,, 'Help',, cMens, 1, 0 ) //Template de cDescTipo inválido para este tipo de cadastro. Template XXX
						Return .F.
					EndIf
				EndIf
			EndIf
		Next
	EndIf

	If nOp == 3 //Inclusão
		inserir(.T.)
	EndIf

	If nOp == 4 //Alteração
		alterar()
	EndIf

	If nOp == 5 //Exclusão
		excluir()
	EndIf

Return .T.

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} inserir
Efetua a inclusão dos dados na tabela CZF.

@param lTransac	Indica se será ou não utilizada a transação durante a operação.

@author  Lucas Konrad França
@since   23/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function inserir(lTransac)

	If ( lTransac == .T. )
		BEGIN TRANSACTION
		execInsere()
		END TRANSACTION
	Else
		execInsere()
	EndIf

Return Nil

Static Function execInsere()
	Local nI := 0

	For nI := 1 To oBrwTmpSel:nLen
		If !empty(aTempSelec[nI][1])
			RecLock("CZF",.T.)
			CZF->CZF_FILIAL := xFilial("CZF")
			CZF->CZF_CDGRIV := M->CZF_CDGRIV
			CZF->CZF_TPMP   := M->CZF_TPMP
			CZF->CZF_CDRC   := M->CZF_CDRC
			CZF->CZF_CDMD   := aTempSelec[nI][1]
			CZF->CZF_CDFATD := M->CZF_CDFATD
			CZF->(MsUnlock())
		EndIf
	Next
Return Nil

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} alterar
Efetua a alteração dos dados da tabela CZF.

@author  Lucas Konrad França
@since   23/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function alterar()
	Local cAliasQry, cQuery

	BEGIN TRANSACTION
	cAliasQry := GetNextAlias()
	cQuery := "DELETE "
	cQuery +=  " FROM " + RetSQLName( 'CZF' )
	cQuery += " WHERE CZF_CDGRIV = '"+M->CZF_CDGRIV+"'"
	cQuery +=   " AND CZF_TPMP   = '"+M->CZF_TPMP+"'"
	cQuery +=   " AND CZF_CDRC   = '"+M->CZF_CDRC+"'"
	cQuery +=   " AND CZF_CDFATD = '"+M->CZF_CDFATD+"'"
	TcSqlExec(cQuery)

	inserir(.F.)
	END TRANSACTION
Return Nil

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} excluir
Efetua a exclusão dos dados da tabela CZF.

@author  Lucas Konrad França
@since   23/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function excluir()
	Local nI

	BEGIN TRANSACTION
	dbSelectArea("CZF")
	CZF->(dbSetOrder(1))
	For nI := 1 To oBrwTmpSel:nLen
		If !empty(aTempSelec[nI][1])
			If CZF->(dbSeek(xFilial("CZF")+M->CZF_CDGRIV+M->CZF_TPMP+M->CZF_CDRC+M->CZF_CDFATD+aTempSelec[nI][1]))
				RecLock("CZF",.F.)
				dbDelete()
				MsUnlock()
			EndIf
		EndIf
	Next
	END TRANSACTION
Return Nil

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA103WHE
Função de modo de edição dos campos.

@param nCampo	Campo que será verificado.

@author  Lucas Konrad França
@since   22/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA103WHE(nCampo)

	If empty(M->CZF_CDGRIV) .AND.;
	   empty(M->CZF_TPMP)   .AND.;
	   empty(M->CZF_CDRC)   .AND.;
	   empty(M->CZF_CDFATD)
		Return .T.
	EndIf

	Do Case
		Case nCampo == 1
			If !empty(M->CZF_CDFATD)
				Return .F.
			EndIf
		Case nCampo == 2
			If !empty(M->CZF_CDFATD)
				Return .F.
			EndIf
		Case nCampo == 3
			Return .T.
		Case nCampo == 4
			If !empty(M->CZF_CDGRIV) .OR. !empty(M->CZF_TPMP)
				Return .F.
			EndIf
	End Case

Return .T.
//---------------------------------------------------------------------------------------------
// Retorna um dos valores enviados por parâmetro de acordo com o layout do sistema.
Function retVersion(nClassic, nStandard, nV12)

	Local nResult := 1

	If Val(getVersao(.F.)) < 12
		If FlatMode()
			nResult := nStandard//HERE
		Else
			nResult := nClassic
		EndIf
	Else
		nResult := nV12
	EndIf

Return nResult