#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'Oga430a.ch'

Static __StPend		:= ''   //	Irá Conter Status de Pendencias Separados por ';'
Static __cCodCtr	:= ''	// 	Irá Conter Codigo do Contrato
Static __cItemFix	:= ''	//  Irá Conter Codigo da Fixação
Static __lCtrVnd	:= nil  //  Irá indicar se é um ctrato de venda ( senao é pq é um ctrato de compra)

/*{Protheus.doc} OGA430A
Função Responsavel por Listar as Pendencias
dos romaneios vinculados a uma vixação;

@param     cCodCtr -> Contrato do romaenio
cItemFix-> Item da Fixação que os romaneios stão vinculados
@sample    OG430A('000324', '001')
@return    // Não se aplicar
@author    Emerson Coelho
@since      01/07/2016
@version    P11
*/
Function OGA430A(cCodCtr, cItemFix)
	Local   aAreaNJR	:= NJR->( GetArea() )
	Local 	aCords		:= FWGetDialogSize( oMainWnd )
	Local 	oLayTel		:= Nil

	Private _oDlg		:= Nil
	Private _oBrwUP		:= nil
	Private _oMRKDown	:= nil
    	
	Default cCodCtr 	:= ''
	Default cItemFix	:= ''

	// Inacializando Vars. Static
	__cStPend	:= OG430STAT(nil,2) 	//Encontranto o Status que são de Pendencia
	__cCodCtr	:= cCodCtr	
	__cItemFix	:= cItemFix
	__lCtrVnd	:= IIF( Posicione( "NJR", 1, xFilial( "NJR" ) + NN8->NN8_CODCTR, "NJR_TIPO" ) == '2', .t., .f. ) //1 Cpra , 2 Venda

	RestArea( aAreaNJR )

	//*------------------------------------------------------------+
	//! Monta tela para seleção dos arquivos contidos no diretório !
	//*------------------------------------------------------------+	
    _oDlg := TDialog():New( aCords[ 1 ], aCords[ 2 ], aCords[ 3 ]/1.001, aCords[ 4 ]/1.5, STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //#"Informações de Pendencias Fiscais / Financeiras"
    _oDlg:lEscClose := .F.

    //Inicializa o objeto e nao apresenta botão de fechar
    oLayTel := FwLayer():New()
    oLayTel	:Init(_oDlg, .F.)

    //Adiciona Linhas
    oLayTel:addLine('L01', 35, .F.)
    oLayTel:addLine('L02', 65, .F.)

    oPanelL01	:=  oLayTel:GetLinePanel('L02') 

    //Adiciona Colunas nas Linhas
    oLayTel:addCollumn('C01_L01', 100, .F., 'L01')
    ///EMEoLayTel:addCollumn('C01_L02', 100, .F., 'L02')

    //Adiciona Janelas na linha 01 Coluna 01
    oLayTel:addWindow('C01_L01', 'C01_L01_W01', OemToAnsi(STR0002), 100, .F., .F., /* bAction */, 'L01', /* bFocus */) //'Pendencias  das Entregas'

    //--<< pega o Painel das Janela da Linha 01	
    oPnC01_L01 := oLayTel:getWinPanel('C01_L01', 'C01_L01_W01','L01')  // Get panel da Janela de cima

    GenBrwUP( oPnC01_L01 )
    GenBrwDown( oPanelL01 )

    _oBrwUP:Activate()
    _oMRKDown:Activate()

    _oDlg:Activate( , , , .t., { || .t. }, , { || } )	

RETURN (.T.)

/*{Protheus.doc} GenBrwUP
Função Responsavel por  Criar o Browse Superior
que mostra resumo de pendencias e descrição delas

@param     Panel -> Onde o Browse deve Ancorar
@sample    GenBrwUP( oPnC01_L01 )
@return    // Objeto FwBrowse foi Criado
@author    Emerson Coelho
@since      01/07/2016
@version    P11
*/
Static Function GenBrwUP( oPanel )
	Local 	cAliasBrw   := GetNextAlias()
	Local 	cQryBrw     := ''
	Local	aColBrw	    := {}
	Local 	nX			:= 0
	Local cFiltroPen	:= ''
	Local aAux			:= {}
	Local cContrato		:= __cCodCtr
	Local cItemFix		:= __cItemFix

	//Criando o filtro de Pendencias	
	aAux :=  separa(__cStPend , ';')
	cFiltroPen:="("
	For nX:=1 to Len( aAux ) sTep 1
		IF !Empty( Trim( aAux[ nX ] ) )
			cFiltroPen += "'" + Trim( aAux[ nX ] ) + "'"
			IF ! nX = Len( aAux )
				cFiltroPen+=" , "
			EndIF
		endIF
	next nI
	cFiltroPen +=")"

	// Montando a Query Para trazer as Pendencias //
	cQryBrw :='' 
	cQryBrw += " SELECT  Count(NNC_STATUS) AS NR_PENDENC, NNC_STATUS, '' AS DESCR_PEND"
	cQryBrw += " FROM " + RetSqlName('NNC')
	cQryBrw += " WHERE	NNC_CODCTR = '" + cContrato		+ "'"
	cQryBrw += " AND	NNC_ITEMFX = '" + cItemFix		+ "'"
	cQryBrw += " AND 	NNC_STATUS IN " + cFiltroPen	
	cQryBrw += " AND D_E_L_E_T_ = ' ' "
	cQryBrw += " GROUP BY NNC_STATUS "
	cQryBrw:= ChangeQuery( cQryBrw )

	//Montando as Colunas do Browse
	//Define as colunas do Browse de Acordo com SX3 Para Buscar Tamanho,decimais Etc;
	//Definindo as colunas do Browse
	nX := 1
	AAdd(aColBrw,FWBrwColumn():New())
	aColBrw[Len(aColBrw)]:SetData( {||NR_PENDENC} )
	aColBrw[Len(aColBrw)]:SetTitle( STR0003 ) 				//#'Pendencias'
	aColBrw[Len(aColBrw)]:SetSize( 6 )
	aColBrw[Len(aColBrw)]:SetDecimal( 0  )
	aColBrw[Len(aColBrw)]:SetPicture('@E999999'  )
	aColBrw[ Len(aColBrw) ]:SetAlign( CONTROL_ALIGN_RIGHT)	//Define alinhamento

	nX := 2
	AAdd(aColBrw,FWBrwColumn():New())
	aColBrw[Len(aColBrw)]:SetData( {||FDescrPend()})
	aColBrw[Len(aColBrw)]:SetTitle( STR0004 ) 				// #'Desc. Pendencia'
	aColBrw[Len(aColBrw)]:SetSize( 40 )
	aColBrw[Len(aColBrw)]:SetDecimal( 0  )
	aColBrw[Len(aColBrw)]:SetPicture('@!'  )
	aColBrw[ Len(aColBrw) ]:SetAlign( CONTROL_ALIGN_LEFT)	//Define alinhamento

	_oBrwUP    := fwBrowse():New()
	_oBrwUP:SetOwner( oPanel )
	_oBrwUP:SetDataQuery(.T.)           
	_oBrwUP:SetAlias(cAliasBrw)
	_oBrwUP:SetQuery(cQryBrw)
	_oBrwUP:SetColumns(aColBrw)
	_oBrwUP:SetDescription( STR0005 )						//#'Pendencias Ref. entregas da Fixação'
	_oBrwUP:SetChange ({|| fRefreDown()/*,,_oMRKDown:Refresh(  )*/ })
	_oBrwUP:DisableConfig(.t.)
	_oBrwUP:SetProfileID( "1" )

Return (.t.)

/*{Protheus.doc} GenBrwDown
Função Responsavel por  Criar o Browse Inferior
listando os romaneios vinculados ref a Pendencias 
selecionada no Browse superior

@param     Panel -> Onde o Browse deve Ancorar
@sample    GenBrwDown( oPnC01_L01 )
@return    // Objeto FwBrowse foi Criado
@author    Emerson Coelho
@since      01/07/2016
@version    P11
*/
Static Function GenBrwDown( oPanel )
	Local aCposBrowse 	:= {"NNC_CODROM","NNC_ITEROM","NNC_NUMDOC","NNC_SERDOC","NNC_QTDENT","NNC_VLENT","NNC_QTDFIX","NNC_VRENPF",'NNC_VLCMPL'}
	Local lMarkAll		:= .f.

	_oMRKDown := FwMarkBrowse():New() 
	_oMRKDown:SetOwner( oPanel )
	_oMRKDown:SetAlias( "NNC" )
	_oMRKDown:SetFieldMark("NNC_OK")
	_oMRKDown:SetMenuDef( "OGA430A" )
	_oMRKDown:SetDescription( 'Pendencias' ) 
	_oMRKDown:SetOnlyFields( aCposBrowse )
	_oMRKDown:SetProfileID( "2" )
	_oMRKDown:DisableDetails()
	_oMRKDown:SetCustomMarkRec({|| fmarcar( _oMRKDown ) })
	_oMRKDown:bAllMark := { ||SetMarkAll(_oMRKDown, lMarkAll := ! lMarkAll ), _oMRKDown:Refresh(.T.)    }
	_oMRKDown:SetWalkThru(.F.)
	_oMRKDown:DisableConfig(.t.)
	_oMRKDown:DisableSeek(.t.)
	_oMRKDown:DisableFilter(.t.)
	_oMRKDown:SetAmbiente(.f.)
	_oMRKDown:ForceQuitButton(.t.)

Return(.t.)

/*{Protheus.doc} fRefreDown
Função Responsavel por  fazer refresh do Browse Inferior
acionada no changeLine	do Browse Superior

@param     Não se aplica
@sample    fRefreDown()
@return    Browse Inferior terá os dados atualizados
@author    Emerson Coelho
@since      01/07/2016
@version    P11
*/
Static function fRefreDown()
	Local cSTatus 	:= ( _oBrwUP:Alias() )->NNC_STATUS
	Local cFiltro	:= ''

	cFiltro := "NNC->NNC_STATUS == '" + 	cSTatus + "' .and. NNC->NNC_CODCTR == '" + __cCodCtr +"' .and. NNC->NNC_ITEMFX == '" + __cItemFix + "'"

	_oMRKDown:oBrowse:CleanFilter()
	_oMRKDown:oBrowse:SetFilterDefault( cFiltro )
	_oMRKDown:oBrowse:UpdateBrowse()
	_oMRKDown:Refresh(.t.)						// Fazendo o Refresh do Browse
Return( .t. )

/*{Protheus.doc} fMarcar(oMrkBrowse)
Marca ou desmarca itens do Browse Inferior

@param     Objeto do Browse inferior
@sample    fMarcar(oMrkBrowse)
@return    Linha do Browse Recebe ou retira a Marca
@author    Emerson Coelho
@since      27/01/2015
@version    P11
*/
Static Function fMarcar( oMrkBrowse )
	Local aAreaAtu	:= GetArea()
	
	If ( !oMrkBrowse:IsMark() )
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->NNC_OK  := oMrkBrowse:Mark()
		(oMrkBrowse:Alias())->(MsUnLock())
	Else
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->NNC_OK  := ""
		(oMrkBrowse:Alias())->(MsUnLock())
	EndIf	

	RestArea( aAreaAtu )
Return( .T. )

/*{Protheus.bdoc} FDescrPend
Função que retorna a descrição da Pendencia

@param     nil
@sample    FDescrPend()
@return    Descrição da Pendencia
@author    Emerson coelho
@since      01/07/206
@version    P11
*/
Static Function FDescrPend()
	Local aPendencia	:= {}
	Local nColPend		:= 2
	Local nLinPend		:= 0

	aPendencia := OG430STAT(nil,1)

	nLinPend:= Ascan(aPendencia,{ |x| x[1] == (_oBrwUP:Alias())->NNC_STATUS})
	cDescrPend:=  aPendencia[ nLinPend, nColPend ]

Return ( cDescrPend )

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Emerson Coelho
@since: 	01/07/2016
@version    P11
*/
Static Function MenuDef()
	Local aRotina 	:= {}

	aAdd( aRotina, { STR0006		,"Staticcall(OGA430A,fAjustar)"			, 0, 3, 0, Nil } ) //#'Ajustar Pendencia'
	aAdd( aRotina, { STR0007		,"Staticcall(OGA430A,fParam)"			, 0, 3, 0, Nil } ) //#'Parametros de Ajustes'

Return( aRotina )

/*{Protheus.doc} fAjustar()
Função responsavel por chamar rotina
que irá procesar o Ajuste (qdo . necessario )
@param     nil
@sample    fAjustar() 
@return    Pendencias Ajustadas
@author    Emerson coelho
@since      01/07/206
@version    P11
*/
Static Function fAjustar()
	Local aAreaAtu 		:= GetArea()
	Local cFiltro		:= ''
	Local lContinua 	:= .t.
	Local cShowMens		:= ''
	Local nAjustes		:= 0

	// -- Verificando Se Existe Registros Marcados, Para Ajustar
	cFiltro := "NNC_OK == '" + 	_oMRKDown:Mark()  + "'"
	NNC->( DBSetFilter ( {|| &cFiltro}, cFiltro) )
	NNC->( dbGoTop() )
	IF NNC->( eof() )
		lContinua := .f.
		Help(,,STR0008 ,,STR0009, 1,0) //#Ajuda#"Não Existe Romaneios Selecionados, favor Selecionar; "
		lcontinua := .f.
	EndIF

	IF lContinua
		cFiltro := " NNC->NNC_STATUS == '" 	+ 	( _oBrwUP:Alias() )->NNC_STATUS + "' .and. "
		cFiltro += " NNC->NNC_CODCTR == '"	+ __cCodCtr 						+ "' .and. "
		cFiltro += " NNC->NNC_ITEMFX == '"	+ __cItemFix 						+ "' .and. "
		cFiltro += " NNC->NNC_OK == '" 		+  _oMRKDown:Mark()  				+ "'"

		IF Alltrim( (_oBrwUP:Alias())->NNC_STATUS ) == '5'  //Requer Ajuste Financeiro Decrescimo

			OGA430D( cFiltro, @nAjustes, @cShowMens )
			IF nAjustes > 0
				_oBrwUP:UpdateBrowse()
				_oBrwUP:Refresh()					// Fazendo o Refresh do Browse Superior pode ser q essa pendencia já não exista mais apos o ajuste

				Aviso('Aviso',cShowmens,{'OK'},3) //#Aviso
			Else
				Aviso('Aviso' ,cShowmens,{'OK'}) //Aviso
			EndIF
		ElseIF Alltrim( (_oBrwUP:Alias())->NNC_STATUS ) == '1'  //Requer Docto Fiscal Proprio

			OGA430B( cFiltro, @nAjustes, @cShowMens,__lCtrVnd, __cCodCtr )
			IF nAjustes > 0
				_oBrwUP:UpdateBrowse()
				_oBrwUP:Refresh()					// Fazendo o Refresh do Browse Superior pode ser q essa pendencia já não exista mais apos o ajuste
				Aviso('Aviso',cShowmens,{'OK'},3) //#Aviso
				/*Else
				//Aviso('Aviso' ,cShowmens,{'OK'}) //Aviso  */
			EndIF

		ElseIF Alltrim( (_oBrwUP:Alias())->NNC_STATUS ) == '2'  //Requer Docto Fiscal Produtor
			
			If fMarcado() = 1		
				OGA430C( cFiltro, __cCodCtr, __cItemFix )
				_oBrwUP:UpdateBrowse()
				_oBrwUP:Refresh()	
			Else			 
				//"Para pendências do tipo ## é permitido marcar somente um (01) romaneio."
				MsgAlert(STR0013+FDescrPend()+STR0014)				
			EndIf
		
		EndIF

		cFiltro := " NNC->NNC_STATUS == '" 	+ 	( _oBrwUP:Alias() )->NNC_STATUS + "' .and. "
		cFiltro += " NNC->NNC_CODCTR == '"	+ __cCodCtr 						+ "' .and. "
		cFiltro += " NNC->NNC_ITEMFX == '"	+ __cItemFix 						+ "'"

		NNC->( DBClearFilter() )	//Retirando o Filtro
		NNC->( DBSetFilter ( {|| &cFiltro}, cFiltro) )  // Retorna o filtro Inicial
		NNC->( dbGoTop() )

		_oMRKDown:oBrowse:UpdateBrowse()	// Fazendo o Refresh do Browse Inferior 
		_oMRKDown:Refresh()

	EndIF

	RestArea( aAreaAtu )

Return()

/*/{Protheus.doc} fMarcado()
	Verifica quantos registros estão marcados.
	@type  Static Function
	@author mauricio.joao
	@since 24/03/2020
	@version 1.0
/*/
Static Function fMarcado()
Local nMarcado:= 0

(_oMRKDown:GoTop(.T.))				
While (_oMRKDown:Alias())->(!Eof())
	If (_oMRKDown:IsMark())
		nMarcado++				
	EndIf
	(_oMRKDown:Alias())->(DbSkip())
EndDo

Return nMarcado


/** {Protheus.doc} fParam
Funcãl de Ajuste dos Parametros de emissao da Nf de Cpl prc

@param: 	nil.
@return:	ni.
@author: 	Emerson Coelho
@since: 	29/01/2015
@Uso: 		OGA430
*/
Static function fParam()
	// Para nfs. de saida(venda) temos que utilizar uma Tes Tributando cfe. a Tes da Venda Irei Utilizar a TES DA vENDA
	Pergunte('OGA430',.t.)
Return

/*{Protheus.doc} SetMarkAll
Função q Marca ou desmarca todos os Registros da NNC 

@param     	objeto Browse da NNC	
Flag de Marcar ou Desmarcar
@return    Itens Marcados ou Desmarcados no Browse
@author    Emerson coelho
/*/
Static Function SetMarkAll(oMrkBrowse,lMarcar )

	(oMrkBrowse:Alias())->( DbGotop() )
	While !( oMrkBrowse:Alias() )->( Eof() )
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->NNC_OK  :=  IIf( lMarcar, oMrkBrowse:Mark(), "" )
		(oMrkBrowse:Alias())->(MsUnLock())
		(oMrkBrowse:Alias())->(DbSkip() )
	EndDo

Return .T.