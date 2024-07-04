#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWBrowse.ch'
#Include 'FwMvcDef.ch'
#include 'OGAA880.ch'

Static __oFolder  := Nil
Static __oDlg	  := Nil
Static __nOpcX	  := 1
Static __lMarcAllD	:= .T.
	
/*/{Protheus.doc} OGAA880()
Função do painel de acompanhamento do plano de vendas
@type Function
@author rafael.kleestadt
@since 10/08/2018
@version 1.0
@param cSafra, caractere, safra do plano de vendas
@param cPlano, caractere, código do plano de vendas
@return True, Logycal, True or False
@example
(example)
@see (links_or_references)
/*/
Function OGAA880()
    Local aCoors      := FWGetDialogSize(oMainWnd)
	Local oSize1      := Nil
	Local oPnlWnd1    := Nil
	Local aTitulo    := {STR0029, STR0031 }
	Local aRefere    := {'Pasta1','Pasta2' }
	Local cTitle   := ''
	
	Private _cUniNeg := N8Y->N8Y_FILIAL 
	Private _cGrProd := N8Y->N8Y_GRPROD 
	Private _cSafra  := N8Y->N8Y_SAFRA  
	Private _cProd   := N8Y->N8Y_CODPRO 
	Private _cCodPla := N8Y->N8Y_CODPLA
	Private _cAliasQry := ""
	Private _oFWL		  := Nil
	Private _oViewVOL		:= Nil // View referente a tela dos itens do plano
	Private _oViewPRE		:= Nil // View referente a tela de componentes de preço
	Private _oModelVOL		:= Nil // Model referente a tela dos itens do plano
	Private _oModelPRE		:= Nil // Model referente a tela dos itens do plano
	Private _oPnlVVOL		:= Nil // Panel referente a tela dos itens do plano
	Private _oPnlVPRE		:= Nil // Panel referente a tela dos componentes de preço
	Private _aUnidNeg       := {}  //Array das unidades de negócio
	Private _aAllFill       := FWLoadSM0() //Array com dados de todas as filiais 
		
	 
    /************* TELA PRINCIPAL ************************/
	//aSize := MsAdvSize()

	//tamanho da tela principal
	oSize1 := FWDefSize():New(.T.)
	oSize1:AddObject('DLG',100,100,.T.,.T.)
	oSize1:SetWindowSize(aCoors)
	oSize1:lProp 	:= .T.
	oSize1:aMargins := {0,0,0,0}
	oSize1:Process()

	__oDlg := TDialog():New(oSize1:aWindSize[1], oSize1:aWindSize[2], oSize1:aWindSize[3], oSize1:aWindSize[4], STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .T.) //"Painel de Acompanhamento do Plano de Vendas"

	// Desabilita o fechamento da tela através da tela ESC.
	__oDlg:lEscClose := .F.

	// Instancia o layer
	_oFWL := FWLayer():New()

	// Inicia o Layer
	_oFWL:init( __oDlg, .F. )

	// Cria as divisões horizontais
	_oFWL:addLine('MASTER', 100, .F.)
	_oFWL:addCollumn('ALL',  100, .F., 'MASTER')
	
	//cria as janelas
	_oFWL:addWindow('ALL', 'Wnd1', STR0002, 100, .F., .T.,, 'MASTER') //"Plano de Vendas: "### " 
	
	//Título da janela
	cTitle += AllTrim(_cUniNeg) + " | " + Alltrim(_cSafra) + " | " + AllTrim(Posicione("SBM", 1, FwxFilial("SBM")+_cGrProd, "BM_DESC"))
	If !Empty(_cProd)
		cTitle += " | " + AllTrim(Posicione("SB1", 1, FwxFilial("SB1")+_cProd, "B1_DESC"))
	EndIf

	_oFWL:setWinTitle( 'ALL', 'Wnd1', STR0002+cTitle,"MASTER")
    // Recupera os Paineis das divisões do Layer
	oPnlWnd1 := _oFWL:getWinPanel('ALL',  'Wnd1', 'MASTER')
	
    //---------------------------------Tree de Filtragem---------------------------------//
    //Cria Folder
	__oFolder := TFolder():New(0,0,aTitulo,aRefere,oPnlWnd1,,,,.t.,.f.,oPnlWnd1:NWIDTH/2, oPnlWnd1:NHEIGHT)
	
	//----------------------------- Programar Volumes - Itens do Plano de Vendas -----------------------------//
	oScr2 := TScrollBox():New(__oFolder:aDialogs[1],0,0, oPnlWnd1:NHEIGHT * 0.47, oPnlWnd1:NWIDTH * 0.50 ,.T.,.T.,.T.)
	ScrFolder2(oScr2)
	
	//----------------------------- Gestão de Preços  -----------------------------//
	oScr3 := TScrollBox():New(__oFolder:aDialogs[2],0,0, oPnlWnd1:NHEIGHT * 0.47, oPnlWnd1:NWIDTH * 0.50 ,.T.,.T.,.T.)
	ScrFolder3(oScr3)
	
	//Ativa Dialog
	__oDlg:Activate(,,,.T.,{||fValGrV()},,{||.T.} )
	
Return .T.

/*/{Protheus.doc} ScrFolder2
//TODO Função responsavel por criar a estrutura da aba de Programar Volumes - Folder 2
@author claudineia.reinert
@since 15/01/2019
@version 1.0
@return ${return}, ${return_description}
@param oPanel, object, descricao
@type function
/*/
Static Function ScrFolder2(oPanel)
	Local nWidth   		:= oPanel:NWIDTH*0.4
	Local nHeight  		:= oPanel:NHEIGHT*0.4
	Local oPnlBtn  		:= Nil
	Local oBtnOK	   	:= Nil
	Local oBtnCancel	:= Nil
	Local oBtnConPRE	:= Nil
	Local oBtnDSTSLD	:= Nil
	Local oBtnCContr    := Nil
	
	oPnlBtn   := tPanel():New(0 , 0,, oPanel,,,,,, nWidth, 30,.F.,.T.)
	_oPnlVVOL  := tPanel():New(30, 0,, oPanel,,,,,, nWidth, nHeight)
	
	oPnlBtn:align:= CONTROL_ALIGN_TOP
	_oPnlVVOL:align:= CONTROL_ALIGN_ALLCLIENT
	
	OGA880VVOL()
	
	oBtnOK := TButton():New(010,010,STR0036,oPnlBtn,{|| Processa({|| GRVVVOLBTN() }, STR0036) },50,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Confirmar"
    oBtnOK:SetCss("QPushButton{ border-radius: 3px; border: 1px solid #1C9DBD; background-color: #1C9DBD; COLOR:#FFFFFF; font-weight: bold; }")
	
	oBtnCancel := TButton():New(010,070,STR0035,oPnlBtn,{|| Processa({|| OGA880RFRBT()}, STR0035) },50,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"
	oBtnDSTSLD := TButton():New(010,130,STR0037,oPnlBtn,{|| Processa({|| DSTSLDBTN()  }, STR0037) },50,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //"distribuir Preços"
	oBtnCopiar := TButton():New(010,190,STR0041,oPnlBtn,{|| Processa({|| COPIARN8W()  }, STR0041) },50,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Copiar"
	oBtnConPRE := TButton():New(010,250,STR0034,oPnlBtn,{|| Processa({|| CONSPREBTN() }, STR0034) },50,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Consultar Preços"
	oBtnCContr := TButton():New(010,310,STR0056,oPnlBtn,{|| Processa({|| OGA880CONTR()}, STR0056) },50,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Contrato"
	
Return .T.

/*/{Protheus.doc} ScrFolder3
//TODO Função responsavel por criar a estrutura da aba de Gestão de Preço - Folder 3
@author claudineia.reinert
@since 15/01/2019
@version 1.0
@return ${return}, ${return_description}
@param oPanel, object, descricao
@type function
/*/
Static Function ScrFolder3(oPanel)
	Local nWidth   		:= oPanel:NWIDTH*0.4
	Local nHeight  		:= oPanel:NHEIGHT*0.4
	Local oPnlBtn  		:= Nil
	Local oBtnOK	   		:= Nil
	Local oBtnCancel	:= Nil
	
	
	oPnlBtn   := tPanel():New(0 , 0,, oPanel,,,,,, nWidth, 30,.F.,.T.)
	_oPnlVPRE  := tPanel():New(30, 0,, oPanel,,,,,, nWidth, nHeight)
	
	oPnlBtn:align:= CONTROL_ALIGN_TOP
	_oPnlVPRE:align:= CONTROL_ALIGN_ALLCLIENT
	
	OGA880VPRE()
	
	oBtnOK := TButton():New(010,010,STR0036,oPnlBtn,{|| Processa({|| GRVVPREBTN() }, STR0036) },50,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Confirmar"
    oBtnOK:SetCss("QPushButton{ border-radius: 3px; border: 1px solid #1C9DBD; background-color: #1C9DBD; COLOR:#FFFFFF; font-weight: bold; }")
    
    oBtnCancel := TButton():New(010,070,STR0035,oPnlBtn,{|| Processa({|| OGA880RFRBT() }, STR0035) },50,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"
    oBtnCancel := TButton():New(010,130,STR0053,oPnlBtn,{|| AtuPreco()},50,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Atualizar Preço"
	
Return .T.

/*{Protheus.doc} OGA880VVOL
(Função que cria a View resposável pela Grid de Programar Volumes - Itens do Plano de Vendas
@type function
@author tamyris.g
@since 21/12/2018
@version 1.0
@param oPnlOwner, objeto, (Objeto Owner-Pai que irá ser construido a View)
*/
Static Function OGA880VVOL()
    
    //funcao para carregar moeda no campo novo se esta estiver vazio
    OGA880Moe()
    
	If _oViewVOL != Nil 
		_oViewVOL:DeActivate()
		_oViewVOL:Destroy()
	EndIf
	
	FreeObj(_oViewVOL)
	_oViewVOL := FWLoadView("OGA830")
	_oViewVOL:SetOperation(MODEL_OPERATION_UPDATE)
	
	_oViewVOL:SetOwner(_oPnlVVOL) // Seta o objeto pai que sera construido a view
	_oViewVOL:activate()
	
Return .T.

/*{Protheus.doc} OGA880VPRE
(Função que cria a View resposável pela Grid de Componentes de Preço
@type function
@author tamyris.g
@since 21/12/2018
@version 1.0
@param oPnlOwner, objeto, (Objeto Owner-Pai que irá ser construido a View)
*/
Static Function OGA880VPRE()
	
	If _oViewPRE != Nil 
		_oViewPRE:DeActivate()
		_oViewPRE:Destroy()
	EndIf
	
	FreeObj(_oViewPRE)
	
	_oViewPRE := FWLoadView("OGA860")
	_oViewPRE:SetOperation(MODEL_OPERATION_UPDATE)
	_oViewPRE:SetOwner(_oPnlVPRE) // Seta o objeto pai que sera construido a view
	_oViewPRE:GetModel():GetModel( 'NCXUNICO' ):SetLoadFilter( , OGA860Filt() ) //Expressão SQL
	_oViewPRE:activate()
	
Return .t.

/*/{Protheus.doc} GRVVVOLBTN
//TODO Botão para gravar os dados na aba de Volumes
@author claudineia.reinert
@since 15/01/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function GRVVVOLBTN()
	Local lRet := .T.
	Local cMsg := ''
	Local oModel := _oViewVOL:GetModel()
	
	If oModel:VldData() .and. oModel:CommitData()
		lRet := .T.
		
		gravaTotais()
		
		MSGINFO(STR0039,STR0036)//##"Registro Salvo com sucesso!" ##"Confirmar"
		IF .NOT. IsInCallStack("fValGrV")
			OGA880VVOL()//refresh dos dados após inclusão
			OGA880VPRE()//refresh dos dados após inclusão
		EndIf
	Else
		cMsg := oModel:GetErrorMessage()[6] + oModel:GetErrorMessage()[7]
		Help( ,,STR0038,, oModel:GetErrorMessage()[6], 1, 0,,,,,,{oModel:GetErrorMessage()[7]} )
		lRet := .F.			     
	EndIf
		
Return lRet

/*/{Protheus.doc} GRVVPREBTN
//TODO Botão para gravar os dados na aba de Gestão de Preço
@author claudineia.reinert
@since 15/01/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function GRVVPREBTN()
	Local lRet := .T.
	Local cMsg := ''
	Local oModel := _oViewPRE:GetModel()
	
	If oModel:GetModel("N8ZUNICO"):IsModified()
		If oModel:VldData() .and. oModel:CommitData()
			lRet := .T.
			MSGINFO(STR0039,STR0036) //##"Registro Salvo com sucesso!" ##"Confirmar"
			IF .NOT. IsInCallStack("fValGrV")
				OGA880VVOL()//refresh dos dados após inclusão
				OGA880VPRE()//refresh dos dados após inclusão
			EndIf
		Else
			cMsg := oModel:GetErrorMessage()[6] + oModel:GetErrorMessage()[7]
			Help( ,,STR0038,, oModel:GetErrorMessage()[6], 1, 0,,,,,,{oModel:GetErrorMessage()[7]} )
			lRet := .F.			     
		EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} OGA880RFRBT
//TODO Botão de refreh dos dados das abas de Volume e Gestão de Preço
@author claudineia.reinert
@since 15/01/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OGA880RFRBT(pAtuItem)
	
	IF .NOT. IsInCallStack("fValGrV")
		OGA880VVOL()//refresh dos dados após inclusão
		OGA880VPRE()//refresh dos dados após inclusão
	EndIf
	
Return .T.

/*/{Protheus.doc} CONSPREBTN
//TODO Botão de consulta de preço na aba de Volumes conforme itens do plano de venda posicionado
@author claudineia.reinert
@since 15/01/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function CONSPREBTN()
	Local oModel := _oViewVOL:GetModel()
	
	OGA830CPRE(oModel)
	
Return .T.

/*/{Protheus.doc} DSTSLDBTN
//TODO Botão de distribuir saldos aba de programar volumes 
@author claudineia.reinert
@since 18/01/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function DSTSLDBTN()
	Local oModel := _oViewVOL:GetModel()
	
	OGA830DSLD(oModel)//distribui o saldo da N8Y para a N8W
	 _oViewVOL:Refresh()
	
Return .T.

/*/{Protheus.doc} COPIARN8W
//Botão para realizar a cópia dos itens do plano para outras fazendas 
@author tamyris.g
@since 22/01/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function COPIARN8W()
	Local aArea     := GetArea()
	Local oDlg	    := Nil
	Local oFwLayer  := Nil
	Local oSize     := Nil
	Local aButtons  := {}
	Local nOpcX     := 0
	Local cFiltro   := ""
	Local nItem     := 1
	Local aCampos   := { 'N8W_GRPROD', 'N8W_DGRPRO', 'N8W_CODPRO', 'N8W_DESPRO', 'N8W_TIPMER', 'N8W_MOEDA', 'N8W_DESMOE', 'N8W_MESANO', 'N8W_PERVEN', 'N8W_QTPRVE', 'N8W_PERREC', 'N8W_QTPRRE','N8W_MOEDA2'}
	Local lMarkAll	:= .f.
		
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4],STR0042,,,,,CLR_BLACK,CLR_WHITE,,, .t. ) //"Copiar Itens do Plano de Vendas"  
		
	// Instancia o layer
	oFwLayer := FWLayer():New()

	// Inicia o Layer
	oFwLayer:init( oDlg, .F. )

	// Cria as divisões horizontais
	oFwLayer:addLine('CAB' , 13, .F.)
	oFwLayer:addLine('UP'  , 50, .F.)
	oFwLayer:addLine('DOWN', 30, .F.)
	
	oFwLayer:addCollumn('ALL', 100, .F., 'CAB')
	oFwLayer:addCollumn('ALL', 100, .F., 'UP')
	oFwLayer:addCollumn('ALL', 100, .F., 'DOWN')

	//cria as janelas
	oFwLayer:addWindow('ALL', 'WndCab' , STR0043, 100, .F., .T.,, 'CAB')  //"Dados para cópia" 
	oFwLayer:addWindow('ALL', 'WndUp'  , STR0044, 100, .F., .T.,, 'UP')   //"Selecionar registros que serão copiados "  
	oFwLayer:addWindow('ALL', 'WndDown', STR0045, 100, .F., .T.,, 'DOWN') //"Selecionar Unid. Negócio para cópia"

	// Recupera os Paineis das divisões do Layer
	oPnlCabec := oFwLayer:getWinPanel('ALL' , 'WndCab' , 'CAB')
	oPnlLeft  := oFwLayer:getWinPanel('ALL' , 'WndUp'  , 'UP')
	oPnlRight := oFwLayer:getWinPanel('ALL' , 'WndDown', 'DOWN')
	
	/***** DADOS PARA CÓPIA *****/
    aItems:= {STR0046,STR0047,STR0048} //'Faturamento','Financeiro','Ambos'
    cCombo1:= aItems[1]
    oCombo1 := TComboBox():New(02,02,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aItems,100,15,oPnlCabec,,{ || nItem := oCombo1:nAt },,,,.T.,,,,,,,,,'cCombo1') 
					
	/**** ITENS DO PLANO - ORIGEM *****/
	
	cFiltro := " N8W_FILIAL='" + N8Y->N8Y_FILIAL + "' "
	cFiltro += " .And. N8W_SAFRA ='" + N8Y->N8Y_SAFRA  + "' "
	cFiltro += " .And. N8W_CODPLA='" + N8Y->N8Y_CODPLA + "' "
				
	oBrwMrk:=FWMarkBrowse():NEW()   // Cria o objeto oMark - MarkBrowse
	oBrwMrk:SetFilterDefault(cFiltro)
	oBrwMrk:SetAlias("N8W") 
	oBrwMrk:SetOnlyFields( aCampos )
	oBrwMrk:SetFieldMark("N8W_OK")	
	oBrwMrk:SetCustomMarkRec({|| fmarcar( oBrwMrk ) })
	oBrwMrk:bAllMark := { ||SetMarkAll(oBrwMrk, lMarkAll := ! lMarkAll ), oBrwMrk:Refresh(.T.)    }
	oBrwMrk:SetSemaphore(.F.)
	oBrwMrk:DisableFilter()
	oBrwMrk:DisableReport()
	oBrwMrk:DisableDetails()
	oBrwMrk:DisableSeek()
	oBrwMrk:DisableSaveConfig()
	oBrwMrk:SetMenuDef("")
	oBrwMrk:Activate(oPnlLeft)	// Ativa o MarkBrowse
	
	/***** FILIAIS - DESTINO *****/
	If Empty(_aUnidNeg)
		CarregaFil()
	EndIF
	
	oBrowseFil := FWBrowse():New(oPnlRight)
    oBrowseFil:SetDataArray(.T.)
    oBrowseFil:DisableFilter(.T.) 
    oBrowseFil:DisableReport(.T.) 
    oBrowseFil:DisableSeek(.T.) 
    oBrowseFil:SetArray(_aUnidNeg)
    oBrowseFil:SetProfileID("OGAA880FIL")
    oBrowseFil:AddMarkColumns( { ||Iif( !Empty( _aUnidNeg[oBrowseFil:nAt,1] = "1" ),"LBOK","LBNO" ) }, { || OGAA880UP(oBrowseFil, .f.)}  )     
    oBrowseFil:AddColumn( {STR0007 , { || _aUnidNeg[oBrowseFil:nAt,2] } ,"C","@!",1,,,.f.,,,} )
    oBrowseFil:AddColumn( {STR0049 , { || _aUnidNeg[oBrowseFil:nAt,3] } ,"C","@!",1,,,.f.,,,} )
	
	oBrowseFil:bHeaderClick := {|| MarcaTudo( oBrowseFil, _aUnidNeg, oBrowseFil:nAt, @__lMarcAllD, .F. ) }
	
	oBrowseFil:Activate()		
	
	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( oDlg, {|| nOpcX := 1, oDlg:End() },{|| nOpcX := 0, oDlg:End() },, @aButtons ) } )
	
	If nOpcX = 1  
		MsgRun( STR0051, STR0052, {|| CopiarReg(oBrwMrk,AllTrim(Str(nItem))) } ) //Copiando registros... ## AGUARDE
	EndIf
	
	N8Y->(DbCloseArea())
		
	DbSelectArea("N8Y")
	N8Y->(DbSetOrder(2))
	N8Y->(DbSeek(_cUniNeg + _cSafra + _cGrProd + _cProd ))

	RestArea(aArea)
Return .T.

/*/{Protheus.doc} OGA880DMOE
//TODO Função para trazer a descrição da moeda, necessario no dicionario no campo N8Y_DESMOE 
@author claudineia.reinert
@since 02/01/2019
@version 1.0
@return cDesMoe, Caracter, descrição da moeda
@param nMoeda, numeric, codigo da moeda
@type function
/*/
Function OGA880DMOE(nMoeda)

	cDesMoe := SuperGetMv("MV_MOEDA"+AllTrim(Str(nMoeda,2)))

Return(cDesMoe)

/*{Protheus.doc} carregaFil
//Função para carregar array com todas as unidades de negocio
@author tamyris.g
@since 23/01/2019
@version undefined
@param objBrowser, object, descricao
@type function
*/
static function carregaFil()	
	Local nX := 0
	Local cUnidNeg := ""
	
	//Percorre array com dados de todas as filiais
	For nX := 1  to Len(_aAllFill)
		
		If cUnidNeg <> _aAllFill[nX][3]+_aAllFill[nX][4] //Empresa + Unidade de Negócio
			
			cUnidNeg := _aAllFill[nX][3]+_aAllFill[nX][4]
			
			aADD(_aUnidNeg, {"2", cUnidNeg , _aAllFill[nX][20] /*Desc Unid Neg*/ })
			
		EndIf
	
	Next nX
Return .T.

/*{Protheus.doc} OGAA880UP
//TODO Descrição auto-gerada.
@author tamyris.g
@since 23/01/2019
@version undefined
@param objBrowser, object, descricao
@type function
*/
static function OGAA880UP(objBrowser, lUpdAll, nLine) //tratamento de refresh	
	Default lUpdAll := .t.
	Default nLine   := 0
	
	_aUnidNeg[objBrowser:nAt,1] := IIF(_aUnidNeg[objBrowser:nAt,1] == "1", "2", "1")
	
	if lUpdAll
        
		objBrowser:UpdateBrowse() //reconstroi tudo	
		
		if nLine > 0 //posiciona na linha
			objBrowser:GoTo(nLine)
		endif
	else	
		objBrowser:LineRefresh() //só refaz a linha
	endif
	
	objBrowser:GoColumn(1)	
	
return .t.

/*/{Protheus.doc} MarcaTudo
//Rotina para marcar/desmarcar todos os itens.
@author tamyris.g
@since 23/01/2019
@version undefined
@param oBrwMrk, object, descricao
@param aItsMrk, array, descricao
@param nLinMrk, numeric, descricao
@param lMark, logical, descricao
@param lDir, logical, descricao
@type function
/*/
Static Function MarcaTudo( oBrwMrk, aItsMrk, nLinMrk, lMark, lDir )
	Local nX	 := 0
	
	Default lMark := .T.
	For nX := 1 to Len( aItsMrk )                 

		If aItsMrk[ nX, 1 ] $ "1|2"
			aItsMrk[ nX, 1 ] := If(lMark, "1", "2")
		EndIf
	Next nX

	oBrwMrk:Refresh()
	lMark := !lMark
	
Return


/*{Protheus.doc} fMarcar(oMrkBrowse)
Marca ou desmarca itens do Browse Inferior
@param     Objeto do Browse inferior
@sample    fMarcar(oMrkBrowse)
@return    Linha do Browse Recebe ou retira a Marca
@author    tamyris.g
@since      25/01/2019
@version    P11
*/
Static Function fMarcar( oMrkBrowse )
	Local aAreaAtu	:= GetArea()

	If ( !oMrkBrowse:IsMark() )
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->N8W_OK  := oMrkBrowse:Mark()
		(oMrkBrowse:Alias())->(MsUnLock())
	Else
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->N8W_OK  := ""
		(oMrkBrowse:Alias())->(MsUnLock())
	EndIf

	RestArea( aAreaAtu )
Return( .T. )

/*{Protheus.doc} SetMarkAll
Função q Marca ou desmarca todos os Registros da N8W 
@param     	objeto Browse da N8W	
Flag de Marcar ou Desmarcar
@return    Itens Marcados ou Desmarcados no Browse
@author    tamyris.g
@since      25/01/2019
/*/
Static Function SetMarkAll(oMrkBrowse,lMarcar )

	(oMrkBrowse:Alias())->( DbGotop() )
	While !( oMrkBrowse:Alias() )->( Eof() )
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->N8W_OK  :=  IIf( lMarcar, oMrkBrowse:Mark(), "" )
		(oMrkBrowse:Alias())->(MsUnLock())
		(oMrkBrowse:Alias())->(DbSkip() )
	EndDo

Return .T.

/*/{Protheus.doc} CopiarReg()
Realiza a cópia dos Itens do Plano (N8W) e Sdo Disponível (N8Y)
@type  Static Function
@author tamyris.g	
@since 09/07/2018
@version 1.0
/*/
Static Function CopiarReg(oBrwMrk,nItem)
	Local aArea     := GetArea()
	Local nY   := 0
	Local cFilBkP  := ""	
	Local cCodPla := ""
	Local aN8Y := {}
	Local aN8W := {}
	
	// INICIA A CÓPIA - grava no array os dados que serão copiados *** 
	OG880DTCPY(oBrwMrk, @aN8Y, @aN8W)
				
	//EFETUA A CÓPIA - grava os registros destino                 *** 
	Begin Transaction 
		cFilBkp  := cFilAnt
		
		For nY := 1 to Len( _aUnidNeg)                 
			
			//Somente filiais marcadas
			If _aUnidNeg[nY][1] == '1'
			
				cFilAnt  := _aUnidNeg[nY][2]
				
				//Realiza cópia da N8Y - Volumes Disponíveis
				OG880CPN8Y(aN8Y, @cCodPla)
				
				//Realiza a cópia da N8W - Itens do Plano
				OG880CPN8W (aN8W,cCodPla,nItem)
			EndIf
		Next nY
	End Transaction
	
	cFilAnt := cFilBkp
	
	RestArea(aArea)
Return .T.

/*/{Protheus.doc} OG880DTCPY()
Gravar no array os registros que serão copiados
@type  Static Function
@author tamyris.g	
@since 09/07/2018
@version 1.0
/*/
Function OG880DTCPY (oBrwMrk,aN8Y,aN8W)
	Local aAux := {}
	Local aAuxPai := {}
	Local aNCU := {}
	Local nIt  := 0
	
	Local aStructN8Y := N8Y->(dBStruct()) // Obtém a estrutura
	Local aStructN8W := N8W->(dBStruct()) // Obtém a estrutura
	Local aStructNCU := NCU->(dBStruct()) // Obtém a estrutura
	
	//N8Y - Volumes Disponíveis - (Registro posicionado)
	aAux:={}
	For nIt := 1 To Len(aStructN8Y)
		AADD(aAux,{ aStructN8Y[nIt][1] , N8Y->&(AllTrim(aStructN8Y[nIt][1]))  } )
	Next nIt
	AADD(aN8Y,aAux)
			
	//N8W - Itens do Plano de Vendas (Registros marcados)	
	dbSelectArea('N8W')
	N8W->(DbGoTop()) 
	N8W->(DbSetOrder(1))
	If N8W->(dbSeek(N8Y->N8Y_FILIAL + N8Y->N8Y_CODPLA))
		While N8W->( !Eof() .And. N8W->N8W_FILIAL+N8W->N8W_CODPLA == N8Y->N8Y_FILIAL+N8Y->N8Y_CODPLA   )

			//Verifica se produtor foi selecionado
			If Empty(oBrwMrk) .Or. oBrwMrk:IsMark()
				
				aAuxPai:={}
				For nIt := 1 To Len(aStructN8W)
					AADD(aAuxPai,{ aStructN8W[nIt][1] , N8W->&(AllTrim(aStructN8W[nIt][1]))  } )
				Next nIt
				
				//NCU - Condições de Recebimento dos itens do plano de venda
				aNCU := {}
				DbSelectArea("NCU")
				NCU->(DbGoTop())
				NCU->(DbSetOrder(1))//NCU_FILIAL+NCU_CODPLA+NCU_SEQITE+NCU_MESANO
				If NCU->(DbSeek(N8Y->N8Y_FILIAL + N8Y->N8Y_CODPLA + N8W->N8W_SEQITE ))
					While NCU->(!EOF()) .And. NCU->(NCU_FILIAL+NCU_CODPLA+NCU_SEQITE) == N8Y->(N8Y_FILIAL + N8Y_CODPLA) +  N8W->N8W_SEQITE
							
						aAux:={}
						For nIt := 1 To Len(aStructNCU)
							AADD(aAux,{ aStructNCU[nIt][1] , NCU->&(AllTrim(aStructNCU[nIt][1]))  } )
						Next nIt
						AADD(aNCU,aAux)
									
						DbSelectArea("NCU")					
						NCU->(DbSkip())
					EndDo
				EndIf
				NCU->(DbCloseArea())
				
				AAux := {}
				AADD(aAux,aAuxPai )
				AADD(aAux,aNCU )
				
				AADD(aN8W,aAux)
  
			Endif
			DbSelectArea("N8W")
			N8W->(dbSkip())
		EndDo
	EndIF
Return .T.
	
/*/{Protheus.doc} OG880CPN8Y()
Realiza a cópia da N8Y - Volumes disponíveis
@type  Static Function
@author tamyris.g	
@since 25/01/2019
@version 1.0
/*/
Function OG880CPN8Y(aN8Y,cCodPla)
	Local nX  := 0
	Local nIt := 0
	Local aDados := {}
	Local lAltTree := .F.
	
	For nX := 1 To Len(aN8Y)
		aDados := aN8Y[nX]
		
		N8Y->(DbCloseArea())
		
		DbSelectArea("N8Y")
		N8Y->(DbGoTop())
		N8Y->(DbSetOrder(2))
		If N8Y->(DbSeek(cFilAnt + _cSafra + _cGrProd + _cProd + '1'))
			cCodPla := N8Y->N8Y_CODPLA
		Else
			cCopy := "N8Y_SAFRA|N8Y_GRPROD|N8Y_CODPRO|N8Y_UM1PRO|N8Y_MOEDA|N8Y_TIPVOL|"
			cCodPla :=  GetSXENum("N8Y","N8Y_CODPLA") //pega sequencial conforme a filial N8W para o campo
			ConfirmSX8()
			
			If RecLock("N8Y", .T.) // Se for inclusão, então grava os dados
				N8Y->N8Y_DTATUA := dDataBase
				N8Y->N8Y_HRATUA := Substr( Time(), 1, 5 )
				N8Y->N8Y_FILIAL := cFilAnt
				N8Y->N8Y_CODPLA := cCodPla
				N8Y->N8Y_STAFAT := '1'
				N8Y->N8Y_STAFIN := '1'
				N8Y->N8Y_STAPRE := '1'
				N8Y->N8Y_STAPLA := '1'
				N8Y->N8Y_ATIVO  := '1'
				For nIt := 1 To Len(aDados)
					If (AllTrim(aDados[nIt][1]) $ cCopy) 
						N8Y->&(aDados[nIt][1]) := aDados[nIt][2]
					EndIF								
				Next nIt
				lAltTree := .T.
				N8Y->(MsUnlock())
			EndIf
		EndIf
	Next nX
	
Return lAltTree

/*/{Protheus.doc} OG880CPN8W()
Realiza a cópia da N8W - Itens do Plano
@type  Static Function
@author tamyris.g	
@since 25/01/2019
@version 1.0
/*/
Function OG880CPN8W(aN8W,cCodPla,nItem)
	
	Local nx   := 0
	Local nz   := 0
	Local nPos := 0
	Local nIt  := 0
	Local cSeq := '0000000001'
	Local cCopy := ""
	Local cSafra  := N8Y->N8Y_SAFRA 
	Local cGrProd := N8Y->N8Y_GRPROD
	Local cCodPro := N8Y->N8Y_CODPRO
	Local cTipMer := ""
	Local cMoeda  := ""
	Local cCont := ""
	Local lCreate  := .F.
	
	For nX := 1 To Len(aN8W)
					
		aDados := aN8W[nX][1]
		
		//Verifica se já existe o registro
		cSeq := ""
		lCreate := .F.
		
		cAliasQry  := GetNextAlias()
		cQuery := "SELECT N8W_SEQITE, N8W.R_E_C_N_O_ AS N8W_RECNO "
		cQuery += " FROM " + RetSqlName("N8W") + " N8W "
		cQuery += " WHERE N8W.N8W_FILIAL = '" +cFilAnt + " '"
		cQuery += " AND   N8W.N8W_SAFRA  = '" + cSafra + "' "
		cQuery += " AND   N8W.N8W_CODPLA = '" + cCodPla + "' "
		cQuery += " AND   N8W.N8W_GRPROD = '" + cGrProd + "' "
		cQuery += " AND   N8W.N8W_CODPRO = '" + cCodPro + "' "
		
		If (nPos := aScan(aDados, {|x| AllTrim(x[1]) == "N8W_TIPMER" })) > 0
			cCont := aDados[nPos][2]
		EndIf
		cQuery += " AND   N8W.N8W_TIPMER = '" + cCont + "' "
		
		If (nPos := aScan(aDados, {|x| AllTrim(x[1]) == "N8W_MOEDA" })) > 0
			cCont := aDados[nPos][2]
		EndIf
		cQuery += " AND   N8W.N8W_MOEDA  = '" + AllTrim(Str(cCont)) + "' "
		
		If (nPos := aScan(aDados, {|x| AllTrim(x[1]) == "N8W_MESANO" })) > 0
			cCont := aDados[nPos][2]
		EndIf
		cQuery += " AND   N8W.N8W_MESANO = '" + cCont + "' "
		
		cQuery += " AND   N8W.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		If (cAliasQry)->(!Eof() )
			cSeq := (cAliasQry)->N8W_SEQITE
			
			N8W->(DbCloseArea())
		
			DbSelectArea("N8W")
			N8W->(DbGoTop())
			N8W->(dbGoTo( (cAliasQry)->N8W_RECNO ) )
			
			
		EndIf
		(cAliasQry)->(DbcloseArea())
	
		If Empty(cSeq)
			cSeq :=  GetSXENum("N8W","N8W_SEQITE") //pega sequencial conforme a filial N8W para o campo
			ConfirmSX8()	
			 
			If RecLock("N8W", .T.) // Se for inclusão, então grava os dados
				
				N8W->N8W_FILIAL := cFilAnt
				N8W->N8W_SAFRA  := cSafra
				N8W->N8W_CODPLA := cCodPla
				N8W->N8W_SEQITE := cSeq
				N8W->(MsUnlock())
				lCreate := .T.
			EndIF
		EndIF	
		
		If RecLock("N8W", .F.)
				
			N8W->N8W_DTATUA := dDataBase
			N8W->N8W_HRATUA := Substr( Time(), 1, 5 )
			
			cCopy := "N8W_GRPROD|N8W_CODPRO|N8W_UM1PRO|N8W_TIPMER|N8W_MOEDA|N8W_CODREG|N8W_MESANO|N8W_TAXCON|N8W_DTINIC|N8W_DTFINA|N8W_PERCON|"
			
			//Só altera o Percentual se for maior ou igual período atual
			If (nPos := aScan(aDados, {|x| AllTrim(x[1]) == "N8W_DTFINA" })) > 0
				cCont := aDados[nPos][2]
			EndIf
					
			If AnoMes(cCont) >= AnoMes(dDataBase)
				If nItem $ '1|3'  
					cCopy += "N8W_PERVEN|"
				EndIF
				If nItem $ '2|3'
					cCopy += "N8W_PERREC|"
				EndIf
			EndIF
			
			For nIt := 1 To Len(aDados)
				If (AllTrim(aDados[nIt][1]) $ cCopy) 
					N8W->&(aDados[nIt][1]) := aDados[nIt][2]
				EndIF								
			Next nIt
			
			cTipMer := N8W->N8W_TIPMER
			cMoeda  := PadR(Alltrim(Str(N8W->N8W_MOEDA)),TamSx3('N8Z_MOEDA')[1] ) 
			
			N8W->(MsUnlock())
			
			//Realiza a cópia da NCU
			aDadosNCU := aN8W[nX][2]
			
			For nZ := 1 To Len(aDadosNCU)
				
				aDados := aDadosNCU[nZ]
				
				lFind  := .F.
				
				//Verifica se já existe o registro
				If !lCreate //Se criou o registro de N8W, não existe NCU
					
					If (nPos := aScan(aDados, {|x| AllTrim(x[1]) == "NCU_MESANO" })) > 0
						cCont := aDados[nPos][2]
					EndIf
					
					DbSelectArea("NCU")
					NCU->(DbSetOrder(1))//NCU_FILIAL+NCU_SEQITE+NCU_MESANO
					If NCU->(DbSeek(N8Y->N8Y_FILIAL+N8Y->N8Y_CODPLA+cSeq+cCont ))
						lFind := .T.
					EndIf
					
				EndIf
				
				If !lFind
					If RecLock("NCU", .T.) // Se for inclusão, então grava os dados
						NCU->NCU_FILIAL := cFilAnt
						NCU->NCU_SAFRA  := cSafra
						NCU->NCU_CODPLA := cCodPla
						NCU->NCU_SEQITE := cSeq
						NCU->(MsUnlock())
					EndIF
				EndIF	
				
				
				If RecLock("NCU", .F.)
						
					NCU->NCU_DTATUA := dDataBase
											
					cCopy := "NCU_MESANO|NCU_PERREC|NCU_QTPRRE|"
					
					For nIt := 1 To Len(aDados)
						If (AllTrim(aDados[nIt][1]) $ cCopy) 
							NCU->&(aDados[nIt][1]) := aDados[nIt][2]
						EndIF								
					Next nIt
				EndIF
				NCU->(MsUnlock())
				NCU->(dbCloseArea())
			Next nZ
		EndIF
		N8W->(dbCloseArea())
	Next nX
	
Return .T.


/*/{Protheus.doc} atuPreco
//Botão para atualizar preço 
@author tamyris.g
@since 29/01/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function atuPreco()
	Local aArea     := GetArea()
	Local oDlg	    := Nil
	Local oFwLayer  := Nil
	Local oSize     := Nil
	Local aButtons  := {}
	Local nOpcX     := 0
	Local nCont  		:= 0
	Local oModelNCX	:= _oViewPRE:GetModel():GetModel("NCXUNICO")	
	Local cTudoOk := "AllwaysTrue"
	Local cSuperDel := ""
	Local nx := 0	
	
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4],STR0053,,,,,CLR_BLACK,CLR_WHITE,,, .t. ) //"Atualizar Preço"  
		
	// Instancia o layer
	oFwLayer := FWLayer():New()

	// Inicia o Layer
	oFwLayer:init( oDlg, .F. )

	// Cria as divisões horizontais
	oFwLayer:addLine('CAB' , 15, .F.)
	oFwLayer:addLine('UP'  , 25, .F.)
	oFwLayer:addLine('DOWN', 60, .F.)
	
	oFwLayer:addCollumn('ALL', 100, .F., 'CAB')
	oFwLayer:addCollumn('ALL', 100, .F., 'UP')
	oFwLayer:addCollumn('ALL', 100, .F., 'DOWN')

	//cria as janelas
	oFwLayer:addWindow('ALL', 'WndCab' , STR0002, 100, .F., .T.,, 'CAB')  //"Plano de Vendas" 
	oFwLayer:addWindow('ALL', 'WndUp'  , STR0054, 100, .F., .T.,, 'UP')   //"Preços Globais"  
	oFwLayer:addWindow('ALL', 'WndDown', STR0055, 100, .F., .T.,, 'DOWN') //"Preços Específicos"

	// Recupera os Paineis das divisões do Layer
	oPnlCabec := oFwLayer:getWinPanel('ALL' , 'WndCab' , 'CAB')
	oPnlLeft  := oFwLayer:getWinPanel('ALL' , 'WndUp'  , 'UP')
	oPnlRight := oFwLayer:getWinPanel('ALL' , 'WndDown', 'DOWN')
				
	/***** CABEÇALHO - PLANO DE VENDAS *****/
    TSay():New( 006, 5, {|| OemToAnsi(STR0032) + ":" } , oPnlCabec, , , , , , .t., CLR_BLACK, CLR_WHITE, 150, 030 ) //Safra
	_oGet1 := TGet():New( 04, 25,bSetGet(AllTrim(N8Y->N8Y_SAFRA)), oPnlCabec,090,010,PesqPict( "NCX", "NCX_SAFRA" ), { || .t. },,,, .f., , .t., , .f., { || .f. }, .f., .f.,, .f., .f., ,"NCX_SAFRA")
	
	TSay():New( 006, 130, {|| OemToAnsi(STR0008) + ":" } , oPnlCabec, , , , , , .t., CLR_BLACK, CLR_WHITE, 150, 030 ) //Grp. Prod.
	_oGet1 := TGet():New( 04, 155,bSetGet(AllTrim(Posicione("SBM",1,FwxFilial("SBM")+N8Y->N8Y_GRPROD,"BM_DESC"))), oPnlCabec,090,010,PesqPict( "NCX", "NCX_DGRPRO" ), { || .t. },,,, .f., , .t., , .f., { || .f. }, .f., .f.,, .f., .f., ,"NCX_DGRPRO")
	
	TSay():New( 006, 258, {|| OemToAnsi(STR0040) + ":" } , oPnlCabec, , , , , , .t., CLR_BLACK, CLR_WHITE, 150, 030 ) //Produto
	_oGet1 := TGet():New( 04, 280,bSetGet(AllTrim(Posicione("SB1", 1, FwxFilial("SB1")+N8Y->N8Y_CODPRO, "B1_DESC"))), oPnlCabec,090,010,PesqPict( "NCX", "NCX_DESPRO" ), { || .t. },,,, .f., , .t., , .f., { || .f. }, .f., .f.,, .f., .f., ,"NCX_DESPRO")
	
	TSay():New( 006, 380, {|| OemToAnsi(STR0009) + ":" } , oPnlCabec, , , , , , .t., CLR_BLACK, CLR_WHITE, 150, 030 ) //Mercado
	_oGet1 := TGet():New( 04, 405,bSetGet(IIF(oModelNCX:GetValue("NCX_TIPMER")=="1","Interno","Externo")), oPnlCabec,090,010,PesqPict( "NCX", "NCX_TIPMER" ), { || .t. },,,, .f., , .t., , .f., { || .f. }, .f., .f.,, .f., .f., ,"NCX_TIPMER")
	
	TSay():New( 006, 510, {|| OemToAnsi(STR0010) + ":" } , oPnlCabec, , , , , , .t., CLR_BLACK, CLR_WHITE, 150, 030 ) //Moeda
	_oGet1 := TGet():New( 04, 530,bSetGet(AllTrim(AGRMVMOEDA(oModelNCX:GetValue("NCX_MOEDA")))), oPnlCabec,090,010,PesqPict( "NCX", "NCX_DESMOE" ), { || .t. },,,, .f., , .t., , .f., { || .f. }, .f., .f.,, .f., .f., ,"NCX_DESMOE")
		 
	/***** SALVA ARRAY COM COMPONENTES DE PREÇO DA SAFRA / PRODUTO / MERCADO E MOEDA *****/ 
	aListGlob   := {}
	aN8WGlob    := {}
	aHeaderGlob := {}
	aAlterGlob  := {"T_DATVIG"}
	aColsGlob   := {}
	nContGlob   := 1
	lFirstGlob  := .T.
	
	aListEspe   := {}
	aN8WEspe    := {}
	aHeaderEsp  := {}
	aAlterEsp   := {"T_FILIAL","T_DATVIG"}
	aColsEsp    := {}
	nContEspe   := 1
	lFirstEsp  := .T.
	
	cPict  := PesqPict("N8Z","N8Z_VALFIX")
	nTam   := TamSX3("N8Z_VALFIX")[1]
	nDec   := TamSX3("N8Z_VALFIX")[2]
	cUsado := posicione("SX3",2,"N8Z_VALFIX","X3_USADO")
	
	AADD(aHeaderGlob,{STR0062,"T_DATVIG",PesqPict("NCV","NCV_DATVIG"),TamSX3("NCV_DATVIG")[1],TamSX3("NCV_DATVIG")[2],"AllwaysTrue()",cUsado,"D",,"","",0,"","A"} ) //Vigência
	
	AADD(aHeaderEsp,{STR0061,"T_FILIAL",PesqPict("NCV","NCV_FILCOM"),TamSX3("NCV_FILCOM")[1],TamSX3("NCV_FILCOM")[2],"AllwaysTrue()",cUsado,"C","SM0","","",0,"","A"} )//Filial
	AADD(aHeaderEsp,{STR0062,"T_DATVIG",PesqPict("NCV","NCV_DATVIG"),TamSX3("NCV_DATVIG")[1],TamSX3("NCV_DATVIG")[2],"AllwaysTrue()",cUsado,"D",,"","",0,"","A"} )//Vigência
	
	_cAliasQry  := GetNextAlias()
	cQuery := "SELECT N8Z_CODCOM, N8Z_TIPVAL, N8Z_VALFIX, N8Z_MOEDA, N8Z_MOEDA2, N8Z_UNIMED, N8Z_TIPMER, N8Z.R_E_C_N_O_ AS N8Z_RECNO "
	cQuery += " FROM " + RetSqlName("N8Z") + " N8Z "
	cQuery += " WHERE N8Z.N8Z_FILIAL  = '" + xFilial("N8Z") + "' "
	cQuery += "   AND N8Z.N8Z_SAFRA  = '" + N8Y->N8Y_SAFRA + "' "
	cQuery += "   AND N8Z.N8Z_GRPROD = '" + N8Y->N8Y_GRPROD + "' "
	cQuery += "   AND N8Z.N8Z_CODPRO = '" + N8Y->N8Y_CODPRO + "' "
	cQuery += "   AND N8Z.N8Z_TIPMER = '" + oModelNCX:GetValue("NCX_TIPMER") + "' "
	cQuery += "   AND N8Z.N8Z_MOEDA  = '" + AllTrim(Str(oModelNCX:GetValue("NCX_MOEDA"))) + "' "
	cQuery += "   AND N8Z.N8Z_CALCUL <> 'R' AND N8Z.N8Z_CALCUL <> 'T' " //Componentes de Resultado ou Produto são calculados automaticamente
	cQuery += "   AND N8Z.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY N8Z_SAFRA, N8Z_GRPROD, N8Z_CODPRO, N8Z_TIPMER, N8Z_MOEDA, N8Z_CODCOM "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),_cAliasQry,.F.,.T.)

	dbSelectArea(_cAliasQry)
	(_cAliasQry)->(dbGoTop())
	If (_cAliasQry)->(!Eof() )
		While ( _cAliasQry )->( !Eof() )
			
			cTitle :=  AllTrim(Posicione("NK7", 1, xFilial("NK7") + (_cAliasQry)->N8Z_CODCOM, "NK7_DESCRI"))
			cTitle += " (" + AllTrim(AGRMVMOEDA((_cAliasQry)->N8Z_MOEDA2)) + "/" + AllTrim((_cAliasQry)->N8Z_UNIMED) + ")"
			
			If (_cAliasQry)->N8Z_TIPVAL == '1' //Preço Global
				
				cNome  := "T_COMP" + AllTrim(Str(nContGlob))
				
				AADD(aHeaderGlob, {cTitle,cNome,cPict,nTam,nDec,"AllwaysTrue()",cUsado,"N",,"","",0,"","A"} )
				AADD(aAlterGlob , cNome )
				AADD(aListGlob  , (_cAliasQry)->N8Z_CODCOM )
				
			Else //Preço Específico
			
				cNome  := "T_COMP" + AllTrim(Str(nContEspe))
				
				AADD(aHeaderEsp,{cTitle,cNome,cPict,nTam,nDec,"AllwaysTrue()",cUsado,"N",,"","",0,"","A"} )
				AADD(aAlterEsp , cNome )
				AADD(aListEspe , (_cAliasQry)->N8Z_CODCOM )
				
			EndIF
			
			nCont := 0
			cAliasQry2  := GetNextAlias()
			cQuery2 := "SELECT NCV_DATVIG, NCV_VALOR, NCV_FILCOM  "
			cQuery2 += " FROM " + RetSqlName("NCV") + " NCV "
			cQuery2 += " WHERE NCV.NCV_FILIAL  = '" + xFilial("NCV") + "' "
			cQuery2 += "   AND NCV.NCV_SAFRA  = '" + N8Y->N8Y_SAFRA + "' "
			cQuery2 += "   AND NCV.NCV_GRPROD = '" + N8Y->N8Y_GRPROD + "' "
			cQuery2 += "   AND NCV.NCV_CODPRO = '" + N8Y->N8Y_CODPRO + "' "
			cQuery2 += "   AND NCV.NCV_TIPMER = '" + (_cAliasQry)->N8Z_TIPMER + "' "
			cQuery2 += "   AND NCV.NCV_MOEDA  = '" + AllTrim(Str((_cAliasQry)->N8Z_MOEDA)) + "' "
			cQuery2 += "   AND NCV.NCV_CODCOM = '" + (_cAliasQry)->N8Z_CODCOM + "' "
			cQuery2 += "   AND NCV.D_E_L_E_T_ = ' ' "
			If (_cAliasQry)->N8Z_TIPVAL == '1' //Preço Global
				cQuery2 += " ORDER BY NCV_DATVIG "
			Else
				cQuery2 += " ORDER BY NCV_FILCOM, NCV_DATVIG "
			EndIf
			cQuery2 := ChangeQuery(cQuery2)
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery2),cAliasQry2,.F.,.T.)
		
			dbSelectArea(cAliasQry2)
			(cAliasQry2)->(dbGoTop())
			If (cAliasQry2)->(!Eof() )
				While ( cAliasQry2 )->( !Eof() )
					
					nCont++
					
					If (_cAliasQry)->N8Z_TIPVAL == '1' //Preço Global
						
						If lFirstGlob .Or. Empty(aColsGlob) //Primeiro componente cria matriz com as filiais e vigências
							
							If nContGlob == 1 //Primeiro componente tem valores
								AADD(aColsGlob, {StoD((cAliasQry2)->NCV_DATVIG), (cAliasQry2)->NCV_VALOR })
							Else 
								aAux := { StoD((cAliasQry2)->NCV_DATVIG) }
								
								//Senão precisa inicializar os componentes anteriores com valor zero
								For nX := 1 To nContGlob - 1
									AADD(aAux, 0)
								Next nX
								
								AADD(aAux, (cAliasQry2)->NCV_VALOR)
								
								AADD(aColsGlob, aAux)
							EndIF
						Else
							AADD(aColsGlob[nCont], (cAliasQry2)->NCV_VALOR )
						EndIF
					Else
						If lFirstEsp .Or. Empty(aColsEsp) //Primeiro componente cria matriz com as filiais e vigências
							
							If nContEspe == 1 //Primeiro componente tem valores
								AADD(aColsEsp, {(cAliasQry2)->NCV_FILCOM, StoD((cAliasQry2)->NCV_DATVIG), (cAliasQry2)->NCV_VALOR })
							Else
								
								aAux := { (cAliasQry2)->NCV_FILCOM, StoD((cAliasQry2)->NCV_DATVIG) }
								
								//Senão precisa inicializar os componentes anteriores com valor zero
								For nX := 1 To nContEspe - 1
									AADD(aAux, 0)
								Next nX
								
								AADD(aAux, (cAliasQry2)->NCV_VALOR)
								
								AADD(aColsEsp, aAux)
								
							EndIf
							
						Else
							AADD(aColsEsp[nCont], (cAliasQry2)->NCV_VALOR )
						EndIF
					EndIF
					
				(cAliasQry2)->( DbSkip() )
				EndDo
			EndIf
			(cAliasQry2)->(DbcloseArea())
			
			If (_cAliasQry)->N8Z_TIPVAL == '1' //Preço Global
				If nCont == 0 //Não tem tabela específica, então inicializa com 0
					For nX := 1 to Len(aColsGlob)
						AADD(aColsGlob[nX], 0)
					next nX
				EndIF
				
				If !empty(aColsGlob)
					lFirstGlob := .F.
				EndIF
				
				nContGlob++
			
			Else
				If nCont == 0 //Não tem tabela específica, então inicializa com 0
					For nX := 1 to Len(aColsEsp)
						AADD(aColsEsp[nX], 0)
					next nX
				EndIF
				
				If !empty(aColsGlob)
					lFirstEsp := .F.
				EndIF
				
				nContEspe++
			EndIf
			
            
			(_cAliasQry)->( DbSkip() )
		EndDo
	EndIf
	
	
	If !Empty(aColsGlob)
		For nCont := 1 to Len(aColsGlob)
			AADD(aColsGlob[nCont], .F.)
		Next nCont
	EndIF
	
	If !Empty(aColsEsp)
		For nCont := 1 to Len(aColsEsp)
			AADD(aColsEsp[nCont], .F.)
		Next nCont
	EndIF
	
	oSize2 := FwDefSize():New(.T.)
	oSize2:AddObject( "PANEL1",  100,100, .T., .T. ) // Totalmente dimensionavel
	oSize2:SetWindowSize({0,0,oPnlLeft:NHEIGHT,oPnlLeft:NWIDTH})
	oSize2:lProp 	:= .T.
	oSize2:aMargins  := { 3, 3, 3, 3 }
	oSize2:Process()
	
	oSize3 := FwDefSize():New(.T.)
	oSize3:AddObject( "PANEL2",  100,100, .T., .T. ) // Totalmente dimensionavel
	oSize3:SetWindowSize({0,0,oPnlRight:NHEIGHT,oPnlRight:NWIDTH})
	oSize3:lProp 	:= .T.
	oSize3:aMargins  := { 3, 3, 3, 3 }
	oSize3:Process()
	
	/**** PREÇOS GLOBAIS *****/
	oGetGlob:= MsNewGetDados():New(0,0,oSize2:aPosObj[1,3],oSize2:aPosObj[1,4],GD_INSERT+GD_UPDATE+GD_DELETE,cTudoOk,cTudoOk,"T_COMP1",;
	                              aAlterGlob,000,999,cTudoOk,cSuperDel,cTudoOk,oPnlLeft,aHeaderGlob,aColsGlob)
	oGetGlob:SetEditLine( .T. )
			    
	/***** PREÇOS ESPECÍFICOS *****/
	oGetEsp:= MsNewGetDados():New(0,0,oSize3:aPosObj[1,3],oSize3:aPosObj[1,4],GD_INSERT+GD_UPDATE+GD_DELETE,cTudoOk,cTudoOk,"T_COMP1",;
	                              aAlterEsp,000,999,cTudoOk,cSuperDel,cTudoOk,oPnlRight,aHeaderEsp,aColsEsp)
	oGetEsp:SetEditLine( .T. )
			
	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( oDlg, {|| nOpcX := 1, IIf(fVldDate(oGetGlob,oGetEsp),oDlg:End(),nOpcX := 0)  },{|| nOpcX := 0, oDlg:End() },, @aButtons ) } )
	
	If nOpcX = 1 
		salvarPreco(oGetGlob:aCols,oGetEsp:aCols,aListGlob,aListEspe)
	EndIf
	
	(_cAliasQry)->(DbcloseArea())
	
	RestArea(aArea)
Return .T.

/*/{Protheus.doc} salvarPreco()
Função para salvar os dados de preços globais e específicos
@type  Static Function
@author tamyris.g
@since 30/01/2019
@version 1.0
@param param, param_type, param_descr
@return True, Logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function salvarPreco(aColsGlob,aColsEspec,aCompsGlob,aCompsEspec)
	Local nx := 0
	Local aDados := {}

	 	dbSelectArea(_cAliasQry)
		(_cAliasQry)->(dbGoTop())
		If (_cAliasQry)->(!Eof() )
			While ( _cAliasQry )->( !Eof() )
		
				//Elimina todos os valores
				DbSelectArea("NCV") 
				NCV->(DbGoTop()) 
				NCV->(DbSetOrder(1)) //NCV_FILIAL+NCV_SAFRA+NCV_GRPROD+NCV_CODPRO+NCV_TIPMER+STR(NCV_MOEDA)+NCV_CODCOM+NCV_FILCOM+DTOS(NCV_DATVIG)
				If NCV->(DbSeek(xFilial("NCV")+N8Y->(N8Y_SAFRA+N8Y_GRPROD+N8Y_CODPRO)+(_cAliasQry)->N8Z_TIPMER+PadR(Alltrim(Str((_cAliasQry)->N8Z_MOEDA)),TamSx3('N8Z_MOEDA')[1] )+(_cAliasQry)->N8Z_CODCOM))
					While NCV->(!EOF()) .And. NCV->(NCV_FILIAL+NCV_SAFRA+NCV_GRPROD+NCV_CODPRO+NCV_TIPMER) == xFilial("NCV")+N8Y->(N8Y_SAFRA+N8Y_GRPROD+N8Y_CODPRO)+(_cAliasQry)->N8Z_TIPMER ;
					                    .And. NCV->NCV_MOEDA == (_cAliasQry)->N8Z_MOEDA .And. AllTrim(NCV->NCV_CODCOM) == AllTrim((_cAliasQry)->N8Z_CODCOM) 
			            If RecLock("NCV", .F.)					
							NCV->(DbDelete())						
							NCV->(MsUnlock())
						EndIf		
			    		
			            NCV->(dbSkip())
			    	EndDo
				EndIf
				NCV->(DbCloseArea())
				
				If (_cAliasQry)->N8Z_TIPVAL == '1' //Preço Global
				
					nPos := Ascan(aCompsGlob,(_cAliasQry)->N8Z_CODCOM) + 1
					
					//Recria com base 					nas colunas
					For nX := 1 to Len(aColsGlob)
						
						aDados := aColsGlob[nX]
						
						If !aDados[Len(aDados)] //Se não foi eliminado 
							
							If RecLock("NCV", .T.) // Se for inclusão, então grava os dados
								NCV->NCV_FILIAL := xFilial("NCV")
								NCV->NCV_SAFRA  := N8Y->N8Y_SAFRA
								NCV->NCV_GRPROD := N8Y->N8Y_GRPROD
								NCV->NCV_CODPRO := N8Y->N8Y_CODPRO
								NCV->NCV_TIPMER := (_cAliasQry)->N8Z_TIPMER
								NCV->NCV_MOEDA  := (_cAliasQry)->N8Z_MOEDA
								NCV->NCV_CODCOM := (_cAliasQry)->N8Z_CODCOM
								NCV->NCV_FILCOM := ""
								NCV->NCV_DATVIG := aDados[1]
								NCV->NCV_VALOR  := aDados[nPos]
								NCV->(MsUnlock())
							EndIF
							
						EndIF
					Next nX
					
				Else //Preço Específico
					nPos := Ascan(aCompsEspec,(_cAliasQry)->N8Z_CODCOM) + 2
					
					//Recria com base 					nas colunas
					For nX := 1 to Len(aColsEspec)
						
						aDados := aColsEspec[nX]
						
						If !aDados[Len(aDados)] //Se não foi eliminado 
							
							If RecLock("NCV", .T.) // Se for inclusão, então grava os dados
								NCV->NCV_FILIAL := xFilial("NCV")
								NCV->NCV_SAFRA  := N8Y->N8Y_SAFRA
								NCV->NCV_GRPROD := N8Y->N8Y_GRPROD
								NCV->NCV_CODPRO := N8Y->N8Y_CODPRO
								NCV->NCV_TIPMER := (_cAliasQry)->N8Z_TIPMER
								NCV->NCV_MOEDA  := (_cAliasQry)->N8Z_MOEDA
								NCV->NCV_CODCOM := (_cAliasQry)->N8Z_CODCOM
								NCV->NCV_FILCOM := aDados[1]
								NCV->NCV_DATVIG := aDados[2]
								NCV->NCV_VALOR  := aDados[nPos]
								NCV->(MsUnlock())
							EndIF
							
						EndIF
					Next nX
				EndIf
			(_cAliasQry)->( DbSkip() )
			EndDo
		EndIf
Return .T.

/** {Protheus.doc} GravaTotais()
Função que grava os totalizadores da N8Y
@author: 	tamyris.g	
@since: 	04/02/2019
*/
Static Function GravaTotais( )
	Local oModel840 := FWLoadModel( "OGA840" )
	Local oModelN8Y	:= _oViewVOL:GetModel():GetModel("N8YVISUL")
	Local lRet := .T.
			
	oModel840:SetOperation( MODEL_OPERATION_UPDATE )
	oModel840:Activate()

	oN8Y:= oModel840:GetModel( "N8YUNICO" )
	lRet:= oN8Y:SetValue( "N8Y_PERVEN"  ,  oModelN8Y:GetValue('N8Y_PERVEN')	)
	lRet:= oN8Y:SetValue( "N8Y_QTDVEN"  ,  oModelN8Y:GetValue('N8Y_QTDVEN')	)
	lRet:= oN8Y:SetValue( "N8Y_PERSAL"  ,  oModelN8Y:GetValue('N8Y_PERSAL')	)
	lRet:= oN8Y:SetValue( "N8Y_QTDSAL"  ,  oModelN8Y:GetValue('N8Y_QTDSAL')	)
	lRet:= oN8Y:SetValue( "N8Y_PERCON"  ,  oModelN8Y:GetValue('N8Y_PERCON')	)
	lRet:= oN8Y:SetValue( "N8Y_QTDCON"  ,  oModelN8Y:GetValue('N8Y_QTDCON')	)

	If ( lRet:=oModel840:VldData() )
		oModel840:CommitData()
	EndIf
		
	oModel840:DeActivate()

Return .T.

/*/{Protheus.doc} OGA880CONTR
//TODO Descrição auto-gerada.
@author vanilda.moggio
@since 15/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OGA880CONTR()
	Local oModel := _oViewVOL:GetModel()
	
	OG830CONTR(oModel)
	
Return .T.

/*/{Protheus.doc} OGA880Moe
//TODO Descrição auto-gerada.
@author vanilda.moggio
@since 15/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OGA880Moe()    
	dbSelectArea('N8W')
	N8W->(DbGoTop()) 
	N8W->(DbSetOrder(1))
	If N8W->(dbSeek(N8Y->N8Y_FILIAL + N8Y->N8Y_CODPLA))
		While N8W->( !Eof() .And. N8W->N8W_FILIAL+N8W->N8W_CODPLA == N8Y->N8Y_FILIAL+N8Y->N8Y_CODPLA )
			
			If Empty(N8W->N8W_MOEDA2) 
			   IF  RecLock("N8W", .F.)
			       N8W->N8W_MOEDA2 := cValtochar(N8W->N8W_MOEDA)
			       N8W->(MSUNLOCK())
			   EndIF
		EndIF   		 
		N8W->(dbSkip())
		EndDo
	EndIf	
return .T.

/*/{Protheus.doc} fValGrV()
Verifica se os dados alterados foram salvos, se não questiona o usuário
@type  Static Function
@author rafael.kleestadt
@since 18/03/2019
@version 1.0
@param param, param_type, param_descr
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function fValGrV()
	Local cGrids  := ""
	Local nOpc	  := 0
	Local lRet := .T.
	
	If _oViewVOL:GetModel("N8WUNICO"):IsModified()
		cGrids += AllTrim(FWX2Nome( "N8W" ))
	EndIf

	If _oViewVOL:GetModel("NCUUNICO"):IsModified()
		cGrids += ", " + AllTrim(FWX2Nome( "NCU" ))
	EndIf

	If _oViewPRE:GetModel("N8ZUNICO"):IsModified()
		cGrids +=  ", " + AllTrim(FWX2Nome( "N8Z" ))
	EndIf

	If !Empty(cGrids)
		nOpc := Aviso( STR0002, STR0057+cGrids+STR0058, { STR0059, STR0060 }, ;
					   1, STR0001,, 'UPDWARNING', .F., /* 5000 */) //"Plano de Vendas" ### "A(s) Grid(s) de "### " possuí(em) itens não salvos." ###  "Descartar" ### "Salvar" ### "Painel de Acompanhamento do Plano de Vendas" ### 

		If nOpc == 1
			Return .T.
		ElseIf nOpc == 2

			BEGIN TRANSACTION

				If _oViewPRE:GetModel():VldData() .And. _oViewVOL:GetModel():VldData()
 					GRVVVOLBTN()
					GRVVPREBTN()
				Else
					// Se os dados não foram validados obtemos a descrição do erro para gerar
					// LOG ou mensagem de aviso
					AutoGrLog(_oViewPRE:GetModel():GetErrorMessage()[6])
					AutoGrLog(_oViewPRE:GetModel():GetErrorMessage()[7])
					If !Empty(_oViewPRE:GetModel():GetErrorMessage()[2]) .AND. !Empty(_oViewPRE:GetModel():GetErrorMessage()[9]) .AND.;
						Valtype(_oViewPRE:GetModel():GetErrorMessage()[2]) == "C" .AND. Valtype(_oViewPRE:GetModel():GetErrorMessage()[9]) == "C" // estava apresentando erros de typemismatch, includo proteção caso venha nil
						AutoGrLog(_oViewPRE:GetModel():GetErrorMessage()[2] + " = " + _oViewPRE:GetModel():GetErrorMessage()[9])
					EndIf
					
					AutoGrLog(_oViewVOL:GetModel():GetErrorMessage()[6])
					AutoGrLog(_oViewVOL:GetModel():GetErrorMessage()[7])
					If !Empty(_oViewVOL:GetModel():GetErrorMessage()[2]) .AND. !Empty(_oViewVOL:GetModel():GetErrorMessage()[9]) .AND.;
						Valtype(_oViewVOL:GetModel():GetErrorMessage()[2]) == "C" .AND. Valtype(_oViewVOL:GetModel():GetErrorMessage()[9]) == "C" // estava apresentando erros de typemismatch, includo proteção caso venha nil
						AutoGrLog(_oViewVOL:GetModel():GetErrorMessage()[2] + " = " + _oViewVOL:GetModel():GetErrorMessage()[9])
					EndIf

					MostraErro()
					DisarmTransaction()
					lRet := .F.
				EndIf
				
			END TRANSACTION

		Endif
	Endif

Return lRet

/*/{Protheus.doc} fVldDate()
Verifica se foi informada datas idênticas no atualiza preço
@type  Static Function
@author gustavo.pereira
@since 18/04/2019
@version 1.0
@param param, param_type, param_descr
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function fVldDate(oGetGlob,oGetEsp)

	Local nX  	     as numeric
	Local aAuxGlob   as array
	Local aAuxEspec  as array

	aAuxGlob  := {}
	aAuxEspec := {}
	
	For nX := 1	To Len(oGetGlob:aCols) 		
		If !oGetGlob:aCols[nX][len(oGetGlob:aCols[nX])] 

			If AScan(aAuxGlob, { |x| x[1] == oGetGlob:aCols[nX][1] }) > 0
				AGRHELP(STR0065,STR0066,STR0064) //"Ajuda" Problema: "Não é possível inserir Preços Globais com a mesma data" Solução: "Inserir datas diferentes"
				Return .F.
			Endif
			
			aAdd(aAuxGlob, {oGetGlob:aCols[nX][1]})
		Endif
	Next Nx

	For nX := 1	To Len(oGetEsp:aCols) 		
		If !oGetEsp:aCols[nX][len(oGetEsp:aCols[nX])] 

			If AScan(aAuxEspec, { |x| x[1]+DToS(x[2]) == oGetEsp:aCols[nX][1]+DToS(oGetEsp:aCols[nX][2]) }) > 0
				AGRHELP(STR0065,STR0063,STR0064) //"Ajuda" Problema: "Não é possível inserir Preços Globais com a mesma data" Solução: "Inserir datas diferentes"
				Return .F.	
			Endif			
			
			aAdd(aAuxEspec, {oGetEsp:aCols[nX][1],oGetEsp:aCols[nX][2]})
		Endif
	Next Nx

Return .T.
