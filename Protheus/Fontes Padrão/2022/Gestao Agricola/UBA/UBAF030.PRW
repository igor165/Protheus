#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "UBAF030.CH"
#INCLUDE "FWMVCDEF.CH"

/*====================={Protheus.doc} UBAF030====================
FUNCAO DA ROTINA UBAA030
	-REALIZA VINCULO DE MALAS 					- UBAA030VIN
	-GERA NOTA FISCAL DE SAIDA					- UBAF030NFS
	-GERA NOTA FISCAL DE DEVOLUCAO - ENTRADA	- UBAF030NFD
	-REALIZA RECEBIMENTO DA REMESSA OU MALA		- UBAF030REC
	-REALIZA O CANCELAMENTO DA REMESSA			- UBAF030CAN
===============================================================*/
/*{Protheus.doc} UBAA030VIN
(Tela - Viculo de Malas)

@author 	roney.maia
@since 		08/02/2017
@version 	1.0
@param 		oView, objeto, (View Ativa)
*/
Function UBAA030VIN(oView)
	Static oOK 			:= LoadBitmap(GetResources(),'LBOK')
	Static oNo     		:= LoadBitmap(GetResources(),'LBNO')

	Local oModel 	    := FWModelActive()
	Local oModelN72		:= oModel:GetModel('N72UBAA030')
	Local oAuxN73	    := oModel:GetModel( 'N73UBAA030' )
	Local oSize2 	    := FWDefSize():New(.F.)
	Local oSize3 	    := FWDefSize():New(.F.)
	Local oSize4 	    := FWDefSize():New(.F.)
	Local oDlg		   := Nil
	Local oFWLayer		:= Nil
	Local oBtBarEsq	   	:= Nil
	Local oBtBarDir	   	:= Nil
	Local aCoors	      	:= FWGetDialogSize( oMainWnd )
	Local aCombo 	    := {}
	Local cChavEsq	   	:= Space(10)
	Local cChavDir	   	:= Space(10)
	Local cPesqEsq 	   	:= Space(TamSX3("DXI_ETIQ")[1])
	Local cPesqDir 	   	:= cPesqEsq
	Local cTipoClas		:= oModelN72:GetValue('N72_TIPO')
	Local cSafra		:= oModelN72:GetValue('N72_SAFRA')
	Local cCodCli		:= oModelN72:GetValue('N72_CODCLI')
	Local lRet		    := .T.
	Local nOpcA 	    := 0
	
	Static __lMarcAllD 	:= .T.
	Static __lMarcAllE 	:= .T.
	
	Private _aItsEsq	:= {}
	Private _aItsDir	:= {}
	Private _nQtde		:= 0
	Private _oBrwEsq	:= Nil
	Private _oBrwDir	:= Nil
	
	If oModel:GetOperation() =  MODEL_OPERATION_VIEW
		Help( , , STR0039, , STR0040, 1, 0 ) // Atenção # "O modo de visualização não permite o vínculo de malas."
		Return
	EndIf
	
	If Empty(cSafra)
		Help( , , STR0039, , STR0041, 1, 0 ) // Atenção # "Favor informar o campo Safra."
		Return
	EndIf
	
	If cTipoClas != '1' .AND. cTipoClas != '2' // Atenção # "Favor informar o tipo de classificação."
		Help( , , STR0039, , STR0042, 1, 0 )
		Return
	EndIf
	
	If Empty(cCodCli)
		Help( , , STR0039, , STR0043, 1, 0 ) // Atenção # "Favor preencher o campo Cod.Cliente."
		Return
	EndIf

	If lRet
		AADD(aCombo, STR0044 ) //"Cod.Mala"
		AADD(aCombo, STR0045 ) //"Safra"
	EndIf

	If lRet
		//----- TELA PARA SELECIONAR MALAS
		//- Coordenadas da area total da Dialog
		aCoors[3] -= (aCoors[3] * 0.20) // Redimensiona o tamanho vertical do Dialog em - 20%
		aCoors[4] -= (aCoors[3] * 0.25) // Redimensiona o tamanho horizontal do Dialog em - 25%
		
		oSize:= FWDefSize():New(.T.)
		oSize:AddObject("DLG",100,100,.T.,.T.)
		oSize:SetWindowSize(aCoors)
		oSize:lProp		:= .T.
		oSize:aMargins	:= {0,0,0,0}
		oSize:Process()

		DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1],0 TO oSize:aWindSize[3],oSize:aWindSize[4] TITLE STR0046 OF oMainWnd PIXEL //"Vínculo de Malas"

		oPnl1:= tPanel():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],,oDlg,,,,,,oSize:aPosObj[1,4],oSize:aPosObj[1,3])
		// Cria instancia do fwlayer
		oFWLayer := FWLayer():New()
		oFWLayer:init( oPnl1, .F. )

		oFWLayer:AddCollumn( 'ESQ' , 45, .F.)
		oFWLayer:AddCollumn( 'MEIO', 10, .F.)
		oFWLayer:AddCollumn( 'DIR' , 45, .F.)

		oFWLayer:addWindow( "ESQ" , "Wnd1", STR0047, 90, .F., .T.) //"Malas Sem Vínculo"
		oFWLayer:addWindow( "DIR" , "Wnd2", STR0048, 90, .F., .T.) //"Malas Vínculadas"

		oPnl2 := oFWLayer:getWinPanel( "ESQ", "Wnd1")
		oPnl3 := oFWLayer:GetColPanel( 'MEIO')
		oPnl4 := oFWLayer:getWinPanel( "DIR", "Wnd2")

		oSize4:AddObject("PNL4",100,100,.T.,.T.)
		oSize4:SetWindowSize({0,0,oPnl4:NHEIGHT,oPnl4:NWIDTH})
		oSize4:lProp    := .T.
		oSize4:aMargins := {0,0,1,0}
		oSize4:Process()

		// Cria barra de botoes
		oBtBarDir := TBar():New( oPnl4,0,0,.T.,,,,.F. )
		@ 0, 0 COMBOBOX cChavDir ITEMS aCombo SIZE 40,07 PIXEL OF oBtBarDir
		@ 0, 0 MSGET cPesqDir SIZE 100,10 PIXEL OF oBtBarDir PICTURE "@x"
		TButton():New(0,0, STR0049,oBtBarDir,{|| Pesquisa(cChavDir,Alltrim(cPesqDir),@_oBrwDir)},Len(STR0049)*4,10,,,,.T.,,) //"Pesquisa"###'Pesquisa'

		//Carrega os itens na Grid de malas já vinculados
		_aItsDir := LoadFarDir()
		
		_oBrwDir := TCBrowse():New( oSize4:aPosObj[1,1], oSize4:aPosObj[1,2], oSize4:aPosObj[1,3], oSize4:aPosObj[1,4], , , , oPnl4, , , , {|| }, {|| }, , , , , , , .f., , .t., , .f., , , )
		_oBrwDir:AddColumn( TCColumn():New(""	  , { || IIf( _aItsDir[_oBrwDir:nAt,1] == "1", oOK, oNo  ) },,,,"CENTER",010,.t.,.t.,,,,.f., ) )
		_oBrwDir:AddColumn( TCColumn():New(STR0044, { || _aItsDir[_oBrwDir:nAt,2] }	, , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Cod.Mala"
		_oBrwDir:AddColumn( TCColumn():New(STR0045, { || _aItsDir[_oBrwDir:nAt,3] }	, , , , "LEFT" , 060, .f., .t., , , , .f., ) ) //"Safra"
		
		_oBrwDir:SetArray( _aItsDir )
		_oBrwDir:bLDblClick 		:= {|| MarcaUm( _oBrwDir, _aItsDir, _oBrwDir:nAt, .F. )}
		_oBrwDir:bHeaderClick 	:= {|| MarcaTudo( _oBrwDir, _aItsDir, _oBrwDir:nAt, @__lMarcAllD, .F. ) }
		_oBrwDir:Align := CONTROL_ALIGN_ALLCLIENT
		_oBrwDir:Refresh(.T.)

		// Dimenssionamento da area
		oSize2:AddObject("PNL2",100,100,.T.,.T.)
		oSize2:SetWindowSize({0,0,oPnl2:NHEIGHT,oPnl2:NWIDTH})
		oSize2:lProp 	:= .T.
		oSize2:aMargins := {0,0,1,0}
		oSize2:Process()
		
		// Cria barra de botoes
		oBtBarEsq := TBar():New( oPnl2,0,0,.T.,,,,.F. )
		@ 0, 0 COMBOBOX cChavEsq ITEMS aCombo SIZE 40,07 PIXEL OF oBtBarEsq
		@ 0, 0 MSGET cPesqEsq SIZE 100,10 PIXEL OF oBtBarEsq PICTURE "@x"
		TButton():New(0,0, STR0049 ,oBtBarEsq,{|| Pesquisa(cChavEsq,Alltrim(cPesqEsq),@_oBrwEsq)},Len(STR0049)*4,10,,,,.T.,,) 	//"Pesquisa"###'Pesquisa'

		_aItsEsq := LoadFardos()
		
		_oBrwEsq := TCBrowse():New( oSize2:aPosObj[1,1], oSize2:aPosObj[1,2], oSize2:aPosObj[1,3], oSize2:aPosObj[1,4], , , , oPnl2, , , , {|| }, {|| }, , , , , , , .f., , .t., , .f., , , )
		_oBrwEsq:AddColumn( TCColumn():New(""	 , { || IIf( _aItsEsq[_oBrwEsq:nAt,1] == "1", oOK, oNo ) },,,,"CENTER",010,.t.,.t.,,,,.f., ) )
		_oBrwEsq:AddColumn( TCColumn():New(STR0044, { || _aItsEsq[_oBrwEsq:nAt,2] }, , , , "LEFT" , 030, .f., .t., , , , .f., ) ) 	//"Cod.Mala"
		_oBrwEsq:AddColumn( TCColumn():New(STR0045, { || _aItsEsq[_oBrwEsq:nAt,3] }, , , , "LEFT" , 060, .f., .t., , , , .f., ) ) 	//"Safra"
	
		_oBrwEsq:SetArray( _aItsEsq )
		_oBrwEsq:bLDblClick 		:= {|| MarcaUm( _oBrwEsq, _aItsEsq, _oBrwEsq:nAt, .F. )}
		_oBrwEsq:bHeaderClick 	:= {|| MarcaTudo( _oBrwEsq, _aItsEsq, _oBrwEsq:nAt, @__lMarcAllE, .F. ) }
		_oBrwEsq:Align := CONTROL_ALIGN_ALLCLIENT
		_oBrwEsq:Refresh(.T.)

		//Caso uma mala seja adicionada na tela principal e a funcao Vincular Malas seja acionada novamente. 
		//Estas malas que já foram adicionados aparecerao ao lado direito novamente
		UpdFardos(oAuxN73, @_oBrwEsq, @_oBrwDir)

		// Dimenssionamento da area
		oSize3:AddObject("PNL3",100,100,.T.,.T.)
		oSize3:SetWindowSize({0,0,oPnl3:NHEIGHT,oPnl3:NWIDTH})
		oSize3:lProp 	:= .T.
		oSize3:aMargins := {0,0,0,0}
		oSize3:Process()

		// Define a fonte
		oFont := TFont():New('Arial',,-12,.T.)
		
		// Cria botoes vincular ou desvincular as malas
		TButton():New( (oSize3:APOSOBJ[1][3]/2)-44, oSize3:APOSOBJ[1][1]+5, ">>" , oPnl3, {|| MovMalas( ">", @_oBrwEsq, @_oBrwDir ) }, oSize3:APOSOBJ[1][4]-10, 15, , /**oFont*/, , .t., , STR0050 ) //"Vincular Marcados"
		TButton():New( (oSize3:APOSOBJ[1][3]/2)-28, oSize3:APOSOBJ[1][1]+5, "<<" , oPnl3, {|| MovMalas( "<", @_oBrwEsq, @_oBrwDir ) }, oSize3:APOSOBJ[1][4]-10, 15, , /**oFont*/, , .t., , STR0051 ) //"Desvincular Marcados"

		_nQtde := len(_aItsDir)

		// Apresenta a quantidade de malas vinculadas na tela
		oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)-5,oSize3:APOSOBJ[1][1]+5,{|| Transform( STR0052 , "@!" )},oPnl3,,oFont,,,,.T.,,,oSize3:APOSOBJ[1][4]-10,10) //"Quantidade"
		oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)+5,oSize3:APOSOBJ[1][1]+5,{||  Alltrim(Transform( _nQtde, '@E 99999') )},oPnl3,,oFont,,,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)

		ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| nOpcA:= 1, ExecGrav(oDlg, @_oBrwDir)},{|| nOpcA:= 2, oDlg:End()})
	EndIf	
Return


/*{Protheus.doc} LoadFarDir
(Função responsável por carregar as malas no browse esquerdo)

@author 	roney.maia
@since 		08/02/2017
@version 	1.0
@return 	${return}, ${Array com as malas filtradas}
*/
Static Function LoadFardos()
	Local oModel	   	:= FwModelActive()
	Local oAuxN72		:= oModel:GetModel('N72UBAA030')
	Local aArea			:= GetArea()
	Local aColsLoad		:= {}
	Local cAliasQry  	:= ""
	Local cQry 			:= ""
	Local cTipoClas		:= oAuxN72:GetValue('N72_TIPO')
	Local cSafra		:= oAuxN72:GetValue('N72_SAFRA')
	cAliasQry := GetNextAlias()
	
	If cTipoClas == '1'		//**Visual
		nTipoUm 	:= '1'		//Visual - Pendente
	ElseIf cTipoClas == '2'	//**HVI
		nTipoUm 	:= '4'		//HVI - Pendente
	EndIf
	
	cQry := "SELECT DXJ_CODIGO, DXJ_SAFRA"
	cQry += " FROM "+ RetSqlName("DXJ") + " DXJ"
	cQry += " WHERE D_E_L_E_T_ <> '*'
	cQry += " AND DXJ_FILIAL 	= '"+xFilial("DXJ")+"'"
	cQry += " AND DXJ_SAFRA 	= '"+cSafra+"'"
	cQry += " AND DXJ_TIPO 	= '"+cTipoClas+"'"
	cQry += " AND DXJ_DATENV 	= ''"
	cQry += " AND DXJ_DATREC 	= ''"
	cQry += " AND DXJ_STATUS = '"+nTipoUm+"'"
	cQry += " AND NOT EXISTS (SELECT * FROM "+ retSqlName('N73')+" N73"+", "+retSqlName('N72')+" N72" 
	cQry +=                    " WHERE N73.D_E_L_E_T_ <> '*'"
	cQry +=                    "   AND N73_CODMAL = DXJ_CODIGO "
    cQry +=                    "   AND N73_CODSAF = DXJ_SAFRA "	
    cQry +=                    "   AND N73_TIPO = DXJ_TIPO "	
    cQry +=                    "   AND N72_FILIAL = N73_FILIAL "	
    cQry +=                    "   AND N72_SAFRA = N73_CODSAF "
    cQry +=                    "   AND N72_CODREM = N73_CODREM "
    cQry +=                    "   AND N72.D_E_L_E_T_ <> '*'"    	 
	cQry +=                    "   AND N72_STATUS <> '5') "
	cQry := ChangeQuery(cQry)
	
	If Select(cAliasQry) > 0
		(cAliasQry)->( dbCloseArea() )
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	//Seleciona a tabela 
	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof())
		aAdd( aColsLoad, { "2", (cAliasQry)->DXJ_CODIGO, (cAliasQry)->DXJ_SAFRA})
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return(aColsLoad)


/*{Protheus.doc} LoadFarDir
(Função responsável por carregar as malas no browse direito)
@type function
@author 	roney.maia
@since 		08/02/2017
@version 	1.0
@return 	${return}, ${Array com as malas filtradas}
*/
Static Function LoadFarDir()
	Local oModel	   	:= FwModelActive()
	Local oAuxN72		:= oModel:GetModel('N72UBAA030')
	Local aArea			:= GetArea()
	Local aColsLoad		:= {}
	Local cAliasQry  	:= ""
	Local cQry 			:= ""
	Local cCodRem		:= oAuxN72:GetValue('N72_CODREM')

	cAliasQry := GetNextAlias()
		
	cQry := "SELECT N73_CODMAL, N73_CODSAF"
	cQry += " FROM "+ RetSqlName("N73") + " N73"
	cQry += " WHERE D_E_L_E_T_ <> '*'"
	cQry += " AND N73_CODREM = '" + cCodRem + "'"
	cQry := ChangeQuery(cQry)
	If Select(cAliasQry) > 0
		(cAliasQry)->( dbCloseArea() )
	EndIf	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof())
		aAdd( aColsLoad, { "2", (cAliasQry)->N73_CODMAL, (cAliasQry)->N73_CODSAF})
		(cAliasQry)->(DbSkip())
	End

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)	
Return(aColsLoad)


/*{Protheus.doc} Pesquisa
(Permite pesquisar Cod.Malas ou Safra no Browse)
@type 		function
@author 	roney.maia
@since 		08/02/2017
@version 	1.0
@param 		cChave, character, (Chave da Pesquisa)
@param 		cPesquisa, character, (Texto informado para a pesquisa)
@param 		oBrowse, objeto, (Browse que chamou a pesquisa)
@return 	${return}, ${NIL}
*/
Static Function Pesquisa(cChave, cPesquisa, oBrowse)
	Local nX 		:= 0
	Local nPosAc	:= 0

	If Alltrim(Upper(cChave)) == Upper(STR0044)
		For nX := 1 To Len(oBrowse:AARRAY)
			If oBrowse:AARRAY[nX][2] == cPesquisa
				nPosAc := nX
				Exit
			EndIf
		Next
	Else
		For nX := 1 To Len(oBrowse:AARRAY)
			If oBrowse:AARRAY[nX][3] == cPesquisa
				nPosAc := nX
				Exit
			EndIf
		Next
	EndIf

	If nPosAc > 0
		oBrowse:GoPosition(nPosAc)
	EndIf	
Return


/*{Protheus.doc} MarcaTudo
(Função responsavel por marcar um dos itens do Browse passado)
@type 		function
@author 	roney.maia
@since 		08/02/2017
@version 	1.0
@param 		oBrwMrk, objeto, (Browse Esquerdo ou Direito da Tela de Vinculo)
@param 		aItsMrk, array, (Array de Itens Marcados)
@param 		nLinMrk, numérico, (Quantidade de Itens Marcados)
@param 		lMark, ${param_type}, (.T. - Marca, .F. - Desmarca)
@param 		lDir, ${param_type}, (*)
@return 	${return}, ${NIL}
*/
Static Function MarcaUm( oBrwMrk, aItsMrk, nLinMrk, lDir)
	Local lMarca := .T.

	//Marca caso o fardo nÃ£o tenha sido embarcado
	If lDir .And. !Empty(aItsMrk[ nLinMrk, 6 ])
		lMarca := .F.
	EndIf
	If lMarca
		DO CASE
			CASE aItsMrk[ nLinMrk, 1 ] == "1"
				aItsMrk[ nLinMrk, 1 ] := "2"
			CASE aItsMrk[ nLinMrk, 1 ] == "2"
				aItsMrk[ nLinMrk, 1 ] := "1"
		ENDCASE
	EndIf
	oBrwMrk:Refresh()	
Return


/*{Protheus.doc} MarcaTudo
(Função responsavel por marcar todos os itens do Browse passado)
@type function
@author 	roney.maia
@since 		08/02/2017
@version 	1.0
@param 		oBrwMrk, objeto, (Browse Esquerdo ou Direito da Tela de Vinculo)
@param 		aItsMrk, array, (Array de Itens Marcados)
@param 		nLinMrk, numérico, (Quantidade de Itens Marcados)
@param 		lMark, ${param_type}, (.T. - Marca, .F. - Desmarca)
@param 		lDir, ${param_type}, (*)
@return 	${return}, ${NIL}
*/
Static Function MarcaTudo( oBrwMrk, aItsMrk, nLinMrk, lMark, lDir )
	Local nX			:= 0
	Default lMark 		:= .T.

	For nX := 1 to Len( aItsMrk )
		If aItsMrk[ nX, 1 ] $ "1|2"
			aItsMrk[ nX, 1 ] := If(lMark, "1", "2")
		EndIf
	Next nX

	oBrwMrk:Refresh()
	lMark := !lMark	
Return()


/*{Protheus.doc} MovMalas
(Função responsavel por mover as malas entre browsers)
@type function
@author 	roney.maia
@since 		08/02/2017
@version 	1.0
@param 		cSeta, character, (Sentido da Movimentação, < ou >)
@param 		_oBrwEsq, objeto, (Browse Esquerdo da tela de Vinculo)
@param 		_oBrwDir, objeto, (Browse Direito da tela de Vinculo)
@return 	${return}, ${.T. = Valida, .F. = Não Valida}
*/
Static Function MovMalas( cSeta, _oBrwEsq, _oBrwDir )
	Local aItsOrig 	:= {}
	Local aItsDest 	:= {}
	Local nX		:= 0
	Local lRet		:= .T.
	Local lMarc		:= .F.

	If INCLUI .Or. ALTERA
		If cSeta == ">"
			aItsOrig 	:= aClone( _aItsEsq )
			aItsDest 	:= aClone( _aItsDir )
		EndIf
		If cSeta == "<"
			aItsOrig 	:= aClone( _aItsDir )
			aItsDest 	:= aClone( _aItsEsq )
		EndIf

		For nX := 1 to Len( aItsOrig )
			If nX > Len( aItsOrig )
				Exit
			EndIf
			If aItsOrig[ nX, 1 ] = "1"
				lMarc := .T.
				aAdd( aItsDest, aItsOrig[ nX ] )
				aItsDest[ Len( aItsDest ), 1 ] := "2"

				aDel( aItsOrig, nX )
				aSize( aItsOrig, Len( aItsOrig )-1 )
				nX--
			EndIf
		Next nX

		If lRet .And. lMarc
			aItsOrig := ASort( aItsOrig, , , { | x, y | x[ 1 ] + x[ 2 ] < y[ 1 ] + y[ 2 ]})
			aItsDest := ASort( aItsDest, , , { | x, y | x[ 1 ] + x[ 2 ] < y[ 1 ] + y[ 2 ]})
			If cSeta == ">"
				_aItsEsq 	:= aClone( aItsOrig )
				_aItsDir 	:= aClone( aItsDest )
				__lMarcAllE := .T.
				__lMarcAllE := .T.
			EndIf
			If cSeta == "<"
				_aItsEsq 	:= aClone( aItsDest )
				_aItsDir 	:= aClone( aItsOrig )
				__lMarcAllE := .T.
				__lMarcAllE := .T.
			EndIf

			_oBrwEsq:SetArray( _aItsEsq )
			_oBrwDir:SetArray( _aItsDir )
			_oBrwEsq:Refresh()
			_oBrwDir:Refresh()
		EndIf
		If !lMarc
			Help( , , STR0039, , STR0053, 1, 0 ) //"Atenção"###"Favor selecionar malas."
		EndIf
	EndIf

	_nQtde := Len(_oBrwDir:AARRAY) // Total de Malas	
Return(lRet)


/*{Protheus.doc} UpdFardos
(Permite atualizar as malas marcadas)
@type function
@author 	roney.maia
@since 		08/02/2017
@version 	1.0
@param 		oAuxN73, objeto, (Submodelo da grid no caso UBAA030N73)
@param 		_oBrwEsq, objeto, (Browse Esquerdo que apresenta as malas disponíveis)
@param 		_oBrwDir, objeto, (Browse Direito que apresenta as malas vinculadas)
@return 	${return}, ${NIL}
*/
Static Function UpdFardos(oAuxN73, _oBrwEsq, _oBrwDir)
	Local aAuxN73 	:= oAuxN73:adatamodel
	Local nI	  	:= 0
	Local nX		:= 0
	Local aItsEsq 	:= _oBrwEsq:AARRAY
	Local lSelec  	:= .F.

	For nI := 1 To Len(aAuxN73)
		If !Empty(aAuxN73[nI][1][1][2])
			For nX := 1 To Len(aItsEsq)
				If aAuxN73[nI][1][1][2] = aItsEsq[nX][2]
					//marca para transferir
					aItsEsq[nX][1] := "1"
					lSelec := .T.
				Endif
			Next nX
		Endif
	Next nI

	If lSelec
		MovMalas( ">", @_oBrwEsq, @_oBrwDir )
	EndIf
Return


/*{Protheus.doc} ExecGrav
(Função responsavel por apresentar barra de progresso e chamar a função
de carga de dados da tela de vinculo de malas para a grid UBAA030N73)
@type function
@author 	roney.maia
@since 		08/02/2017
@version 	1.0
@param 		oDlg, objeto, (Dialog da Tela)
@param 		_oBrwDir, objeto, (Browser Direito da Tela de Vinculo)
@return 	${return}, ${NIL}
*/
Static Function ExecGrav(oDlg, _oBrwDir)
	Local oModel	:= FWModelActive()
	Local lRet 		:= .T.
	Begin Transaction
		oProcess := MsNewProcess():New( { | lEnd | lRet := A030GRAV(@_oBrwDir,@oModel)}, STR0054, STR0055, .F. ) //"Aguarde"###"Atualizando tabela de dados de malas da remessa"
		oProcess:Activate()
		If !lRet
			DisarmTransaction()
		EndIf
	End Transaction
	oDlg:End()
Return


/*{Protheus.doc} A030GRAV
(Função que trata a carga de dados da tela de vinculo de fardos para
a Grid UBAA030N73)
@type function
@author 	roney.maia
@since 		08/02/2017
@version 	1.0
@param 		oBrowse, objeto, (Objeto do Browse)
@param 		oModel, objeto, (Model Ativo)
@return 	${return}, ${.T. = Valida, .F. = Não Valida}
*/
Static Function A030GRAV(oBrowse, oModel)
	Local oView			:= FwViewActive()
	Local oAuxN73		:= oModel:GetModel( 'N73UBAA030' )
	Local oAuxN72		:= oModel:GetModel( 'N72UBAA030' )
	Local cTipoMal		:= oAuxN72:GetValue('N72_TIPO')
	Local aRRRAY		:= oBrowse:AARRAY
	Local aAuxN73		:= oAuxN73:aDataModel
	Local aSaveLine		:= FWSaveRows()	
	Local nTotMalas 	:= 0
	Local nQtClass		:= 0	
	Local nX			:= 0
	Local nI        	:= 0
	Local lCria     	:= .F.
	Local lExclui   	:= .T.
	Local lRet			:= .T.
	Local cAliasQry 	:= GetNextAlias()
	Local cQry 			:= ""
	
	//Verifica se a tabela esta aberta 
	If Select(cAliasQry) > 0
		//se estiver fecha
		(cAliasQry)->( dbCloseArea() )
	EndIf
	
	/***** Exclui os registros que não foram mantidos na inclusao de fardos ****/
	For nI := 1 To Len(aAuxN73)
		lExclui := .F.	
		If !Empty(aAuxN73[nI][1][1][2])
			For nX := 1 To Len(aRRRAY)
				//Se encontrar o registro, mantem a linha
				If aAuxN73[nI][1][1][2] = aRRRAY[nX][2]
					exit
				Endif
				
				//Se for o ultimo registro e nao encontrar, deleta a linha no grid
				If nX == Len(aRRRAY) .And. aAuxN73[nI][1][1][2] <> aRRRAY[nX][2]
					lExclui := .T.
				EndIf				
			Next nX		
			//O registro sera excluido pq foi removido da selecao da direita
			If lExclui .and. oModel:GetOperation() !=  MODEL_OPERATION_DELETE
				oAuxN73:GoLine(nI)
				oAuxN73:DeleteLine()
			Endif
		Endif
	Next nI
	
	/*Cria as linhas na tela***********************************************************************/
	For nX:= 1 To Len(aRRRAY)
		lCria 	 := .t.
		For nI := 1 To Len(aAuxN73)
			If !Empty(aAuxN73[nI][1][1][2])
				//Se o fardo esta deletado, mas foi adicionado novamente. 
				//Alterar a situacao da linha
				If aAuxN73[nI][1][1][2] = aRRRAY[nX][2] .And. oAuxN73:IsDeleted(nI)
					oAuxN73:Goline(nI)
					oAuxN73:UnDeleteLine()
					lCria := .f.
				EndIf
				//Se é uma mala que já existe no grid e não foi deletado, nao adicionar novamente
				If aAuxN73[nI][1][1][2] = aRRRAY[nX][2] .And. !oAuxN73:IsDeleted(nI)
					lCria := .f.
				Endif
			EndIf
		Next nI

		If lCria
			//Inicio do somatorio com as malas que aparecerao em tela
			nTotMalas++
			//Final do somatorio
		
			//Se o código da mala está em branco na ultima linha do grid, então deve-se alterar esta
			If Empty(aAuxN73[oAuxN73:Length()][1][1][2])
				oAuxN73:Goline(oAuxN73:Length())
			//Senao, adiciona-se uma linha e altera-se esta				
			Else
				oAuxN73:AddLine()
				oAuxN73:Goline(oAuxN73:Length())
			EndIf
							
			If lRet
				lRet := oAuxN73:LoadValue("N73_CODMAL",aRRRAY[nX,2])
			EndIf
			
			If lRet
				lRet := oAuxN73:LoadValue("N73_CODSAF",aRRRAY[nX,3])
			EndIf
			
			If lRet
				lRet := oAuxN73:LoadValue("N73_TIPO", cTipoMal)
			EndIf
			
			If lRet			
				If cTipoMal == '1'
					nQtClass := 0
					
					cQry := "SELECT COUNT(DXK_CLAVIS) AS Total"
					cQry += " FROM "+ RetSqlName("DXK") + " DXK"
					cQry += " WHERE D_E_L_E_T_ <> '*'"
					cQry += " AND DXK_FILIAL = '"+xFilial("DXK")+"'"
					cQry += " AND DXK_CODROM = '"+aRRRAY[nX,2]+"'"
					cQry += " AND DXK_SAFRA = '"+aRRRAY[nX,3]+"'"
					cQry += " AND DXK_TIPO = '" + cTipoMal + "'"
					cQry += " AND DXK_CLAVIS <> ''" 		
					cQry := ChangeQuery(cQry)			
					dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	
					//Seleciona a tabela 
					dbSelectArea(cAliasQry)
					lRet := oAuxN73:LoadValue("N73_QTDCLA", (cAliasQry)->Total)
					(cAliasQry)->(DbCloseArea())				
					
				ElseIf cTipoMal == '2'
					nQtClass := 0
									
					cQry := "SELECT COUNT(DX7.DX7_ATIVO) AS Total"
					cQry += " FROM "+ RetSqlName("DX7") + " DX7"
					cQry += " INNER JOIN " + retSqlName('DXK')+" DXK" +" ON "
					cQry += " DX7_SAFRA = DXK_SAFRA"
					cQry += " AND DX7_ETIQ = DXK_ETIQ" 
					cQry += " WHERE DX7.D_E_L_E_T_ <> '*'"
					cQry += " AND DXK.D_E_L_E_T_ <> '*'"
					cQry += " AND DX7_FILIAL = '"+xFilial("DXJ")+"'"
					cQry += " AND DX7_ATIVO = '1'"
					cQry += " AND DX7_SAFRA = '"+aRRRAY[nX,3]+"'"
					cQry += " AND DXK_CODROM = '"+aRRRAY[nX,2]+"'"
					cQry += " AND DXK_SAFRA = '"+aRRRAY[nX,3]+"'"
					cQry += " AND DXK_TIPO = '" + cTipoMal + "'"	
					cQry := ChangeQuery(cQry)	
					dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	
					//Seleciona a tabela 
					dbSelectArea(cAliasQry)
					lRet := oAuxN73:LoadValue("N73_QTDCLA", (cAliasQry)->Total)
					(cAliasQry)->(DbCloseArea())	
				EndIf
			EndIf
		Endif
	Next nX

	For nX := 1 to nTotMalas
		oModel:LoadValue('UBAA030CALC','TOTFDI'  ,nTotMalas)
	Next nX
	
	// Faz validação dos dados
	lRet := oModel:VldData()

	//Apresenta Help de Erro
	If !lRet
		Help(,, STR0056,, oModel:GetErrorMessage()[6],1,0) //"Incluir Malas"
	EndIf

	__lMarcAllE	:= .T.
	__lMarcAllD	:= .T.
	oView:SetModified()
	FWRestRows( aSaveLine )
Return(lRet)


/*{Protheus.doc} UBAF030NFS
Gera documento fiscal de saida

@author 	ana.olegini
@since 		15/02/2017
@version 	1.0
@param 		cSafra		, character, Informação da rotina UBAA030	- SAFRA
@param 		cCodRem		, character, Informação da rotina UBAA030	- REMESSA
@param 		cTipo		, character, Informação da rotina UBAA030	- TIPO VISUAL/HVI
@param 		cCForCli	, character, Informação da rotina UBAA030	- CLIENTE
@param 		cLForCli	, character, Informação da rotina UBAA030	- LOJA CLIENTE
@param		cStatus		, charecter, Informação da rotina UBAA030	- STATUS DA REMESSA
@return 	${return}, ${return_description}
*/
Function UBAF030NFS(cSafra,cCodRem,cTipo,cCForCli,cLForCli,cStatus)
	Local aCab				:= {}	//*Cabeçalho Pedido	- SC5
	Local aItens			:= {}	//*Itens Pedido 	- SC6
	Local aGerouDoc			:= {}
	Local cAliasDXK 		:= GetNextAlias()
	Local cItemSeq			:= ""
	Local cQueryDXK			:= ""
	Local cTipoPed			:= ""
	Local cPedN73			:= ""
	Local cNfGerada			:= ""
	Local cSerie			:= ""
	Local cUm				:= ""	
	Local cLocal			:= ""
	Local lRetorno 			:= .T.
	Local nQuant			:= 0
	Local nItens			:= 1
	Local oFWSX1			:= nil
	Local aPergunte			:= {}
	
	//*Variavel Privada da rotina MATA410 não pode ser modificada
	Private lMsErroAuto 	:= .F.
	Private _cPedido		:= ""		//*Numero do Pedido de Venda
    Private _cModAtu    	:= cModulo	//*Salvando Modulo Atual
    Private _nModAtu    	:= nModulo  //*Salvando Modulo Atual
    	
	//*Parametros - SX1 - UBAA030I/UBAA030E
	Private _cTipoDct		:= ""	//*Tipo do Pedido 				- parametro mv_par01
	Private _cProduto		:= ""	//*Produto 						- parametro mv_par02
	Private _cLoteCtl		:= ""	//*Lote 						- parametro mv_par03
	Private _cNumLote		:= ""	//*Sub-Lote						- parametro mv_par04
	Private _cLocaliz		:= ""	//*Endereço						- parametro mv_par05
	Private _cCondPgt		:= ""	//*Condição de Pagamento		- parametro mv_par06
	Private _cEspecie		:= ""	//*Especie 						- parametro mv_par07
	Private _cNatureza       := ""   //*Natureza Financeira
	Private _cOperFis       := ""   //*Operação Fiscal
	Private _cTes			:= ""	//*Tipo Entrada Saída			- parametro mv_par08
	Private _nVlrUnit		:= 0	//*Valor Unitário				- parametro mv_par09
	Private _cTipQtd		:= ""	//*Tipo da Quantidade			- parametro mv_par10	
	Private _cSerie			:= ""	//**Série da Nota Fiscal		- parametro mv_par11
	Private _nQuant         := 0    //Quantidade                    - parametro mv_par12      
	Private _ClVl           := ""     

	If cStatus $ '2|3|4|5'
		Help( ,, STR0039,, STR0002 , 1, 0,)	//"Atenção"#"Somente Remessas com status de -Iniciadas- podem ser -Emitidas-." 
		Return( .F. )		
	EndIf

   	DbSelectArea("N73")	//Malas
   	DbSetOrder(1)
   	If .Not. DbSeek( xFilial("N73") + cSafra + cCodRem )
		Help( ,, STR0039,, STR0066, 1, 0,)	//"Atenção"#"Não há malas vinculadas! Não será possível gerar documento fiscal."
		Return( .F. )
	EndIf				//Fim Malas

	//**"Confirma a geração da NF?"
	If !IsBlind() .AND. !MsgYesNo( STR0005 ) //"Confirma a Geração do Documento Fiscal?" 
		MsgInfo( STR0006 ) //"Operação abortada!"
		Return( .F. )
	EndIf
	
	If cTipo == '1'			//Visual
		If ExistBlock('UB030001')
			cPergunta := ExecBlock('UB030001',.F.,.F.) //Retorna nome do pergunte especifico
			Pergunte(cPergunta,.F.)	//Pergunte Especifico para expedição de amostras visuais
		Else
			cPergunte := "UBAA030I"
			PERGUNTE(cPergunte,.F.)
		EndIf		
	ElseIf cTipo == '2'		//HVI
		If ExistBlock('UB030002')
			cPergunta := ExecBlock('UB030002',.F.,.F.) //Retorna nome do pergunte especifico
			Pergunte(cPergunta,.F.)	//Pergunte Especifico para expedição de amostras visuais
		Else
			cPergunte := "UBAA030E"
			PERGUNTE(cPergunte,.F.)
		EndIf
	EndIf

	oFWSX1 := FWSX1Util():New()
	oFWSX1:AddGroup(cPergunte)
	oFWSX1:SearchGroup()
	aPergunte := oFWSX1:GetGroup(cPergunte)	

	If Len(aPergunte) = 2 .and. Len(aPergunte[2]) >= 15 // proteção de campo para rodar abaixo de 12.1.25
		_cTipoDct	:= mv_par01		//*Tipo do Pedido
		_cProduto	:= mv_par02		//*Produto
		_cLoteCtl	:= mv_par03		//*Lote
		_cNumLote	:= mv_par04 	//*Sub-Lote
		_cLocaliz	:= mv_par05		//*Endereço
		_cCondPgt	:= mv_par06		//*Condição de Pagamento
		_cEspecie	:= mv_par07		//*Especie 
		_cNatureza  := mv_par08     //*Natureza Financeira
		_OperFis    := mv_par09     //*Operação Fiscal
		_cTes		:= mv_par10		//*Tipo Entrada Saída	
		_nVlrUnit	:= mv_par11		//*Valor Unitário
		_cTipQtd	:= mv_par12		//*Tipo da Quantidade
		_cSerie		:= mv_par13		//*Série da Nota Fiscal
		_nQuant     := mv_par14		//Quantidade
		_ClVl       := mv_par15     //Classe Valor
	Else
		_cTipoDct	:= mv_par01		//*Tipo do Pedido
		_cProduto	:= mv_par02		//*Produto
		_cLoteCtl	:= mv_par03		//*Lote
		_cNumLote	:= mv_par04 	//*Sub-Lote
		_cLocaliz	:= mv_par05		//*Endereço
		_cCondPgt	:= mv_par06		//*Condição de Pagamento
		_cEspecie	:= mv_par07		//*Especie 
		_cTes		:= mv_par08		//*Tipo Entrada Saída	
		_nVlrUnit	:= mv_par09		//*Valor Unitário
		_cTipQtd	:= mv_par10		//*Tipo da Quantidade
		_cSerie		:= mv_par11		//*Série da Nota Fiscal
		_nQuant     := mv_par12		//Quantidade

	EndIf

	If Empty(_cProduto)
		Help( ,, STR0039,, STR0058 , 1, 0,) //"Atenção"#"Não foi possível gerar o documento fiscal de saída. Favor verificar parâmetros de NF em ações relacionadas."
		Return(.F.)
	ElseIf Empty(_cCondPgt)
		Help( ,, STR0039,, STR0058 , 1, 0,) //"Atenção"#"Não foi possível gerar o documento fiscal de saída. Favor verificar parâmetros de NF em ações relacionadas."
		Return(.F.)	
	ElseIf Empty(_cEspecie)
		Help( ,, STR0039,, STR0058 , 1, 0,) //"Atenção"#"Não foi possível gerar o documento fiscal de saída. Favor verificar parâmetros de NF em ações relacionadas."
		Return(.F.)	
	ElseIf Empty(_cTes)
		Help( ,, STR0039,, STR0058 , 1, 0,) //"Atenção"#"Não foi possível gerar o documento fiscal de saída. Favor verificar parâmetros de NF em ações relacionadas."
		Return(.F.)	
	ElseIf Empty(_nVlrUnit)
		Help( ,, STR0039,, STR0058 , 1, 0,) //"Atenção"#"Não foi possível gerar o documento fiscal de saída. Favor verificar parâmetros de NF em ações relacionadas."
		Return(.F.)	
	ElseIf Empty(_cSerie)
		Help( ,, STR0039,, STR0058 , 1, 0,) //"Atenção"#"Não foi possível gerar o documento fiscal de saída. Favor verificar parâmetros de NF em ações relacionadas."
		Return(.F.)			
	EndIf 
		
	//**Tipo do pedido de venda 
	If _cTipoDct == 1
		cTipoPed := "N"		//N-Normal
		
		//**Verifica existencia do cliente
		DbSelectArea("SA1")	//Cliente
		DbSetOrder(1)
		If .not. DbSeek( xFilial("SA1")+cCForCli+cLForCli )
			Help( ,, STR0057,, STR0003+cCForCli+" "+cLForCli+STR0004 , 1, 0,) //"Ajuda""Não foi encontrado o Cliente "#" na tabela SA1." 
			Return( .F. )
		EndIf				//Fim - Cliente
		SA1->(DbCloseArea())
	ElseIf _cTipoDct == 2
		cTipoPed := "B"		//B-Utiliza Fornecedor
		
		//**Verifica existencia do fornecedor
		DbSelectArea("SA2")	//Fornecedor
		DbSetOrder(1)
		If .not. DbSeek( xFilial("SA2")+cCForCli+cLForCli )
			Help( ,, STR0057,, STR0090+cCForCli+" "+cLForCli+STR0091 , 1, 0,) //"Ajuda""Não foi encontrado o Fornecedor "#" na tabela SA2." 
			Return( .F. )
		EndIf				//Fim - Fornecedor
		SA2->(DbCloseArea())
	EndIf 

	//*----------- CABEÇALHO PEDIDO DE VENDA	- 	SC5
    aAdd( aCab, {"C5_TIPO"          , cTipoPed     	, Nil } )
    aAdd( aCab, {"C5_CLIENTE"       , cCForCli      , Nil } )
    aAdd( aCab, {"C5_LOJACLI"       , cLForCli     	, Nil } )
    aAdd( aCab, {"C5_CLIENT"    	, cCForCli      , Nil } )
    aAdd( aCab, {"C5_LOJAENT"   	, cLForCli     	, Nil } )
    
	//*Verifica condição de pagamento [nao pode ser igual a tipo 9]
	DbSelectArea("SE4")	//CONDIÇÃO DE PAGAMENTO
    DbSetOrder(1)
    If DbSeek( xFilial( "SE4" )+ _cCondPgt )
        If SE4->E4_TIPO <> "9" 
			aAdd( aCab, {"C5_CONDPAG" , _cCondPgt   , Nil } )
		EndIf
    EndIf				//Fim - CONDIÇÃO DE PAGAMENTO
    SE4->(DbCloseArea())
  
   
    aadd( aCab, { "C5_EMISSAO"		, dDataBase		, Nil } )
	aadd( aCab, { "C5_TPFRETE"	 	, "S"			, Nil } )	//**C=CIF;F=FOB;T=Por conta terceiros;S=Sem frete                                                                                   
	aAdd( aCab, { "C5_TIPLIB" 		, "2"			, Nil } )	//**1=Libera por item; 2=Libera por pedido
	aAdd( aCab, { "C5_LIBEROK"		, "S"			, Nil } )	//**Pedido liberado total
	aAdd( aCab, { "C5_ESPECI1" 		, _cEspecie		, Nil } )	
	aAdd( aCab, { "C5_ORIGEM"		, "UBAA030"		, Nil } )	//*Gravar Origem do Dcto Fiscal
	
	If !Empty(_cNatureza)
		aAdd( aCab, { "C5_NATUREZ", _cNatureza	, Nil } )
	Endif
	
	If _nQuant > 0
		nQuant := _nQuant 
	Else
		//*----------- ITENS PEDIDO DE VENDA	-	SC6
	   	If _cTipQtd == 1		//*AMOSTRAS
			cQueryDXK += " SELECT COUNT(DXK.DXK_CODROM) AS QTIDADE "
			cQueryDXK +=   " FROM " + RetSqlName('N73') + " N73 "
			cQueryDXK +=  " INNER JOIN " + RetSqlName('DXK')+ " DXK ON DXK.D_E_L_E_T_ = '' "
			cQueryDXK +=    									 " AND DXK.DXK_FILIAL = N73.N73_FILIAL "
			cQueryDXK +=    									 " AND DXK.DXK_CODROM = N73.N73_CODMAL " 
			cQueryDXK +=    									 " AND DXK.DXK_SAFRA  = N73.N73_CODSAF "
			cQueryDXK +=    									 " AND DXK.DXK_TIPO   = N73.N73_TIPO   "
			cQueryDXK +=  " WHERE N73.D_E_L_E_T_ = '' "
			cQueryDXK +=    " AND N73.N73_FILIAL = '" + FwXFilial("N73") + "' " 
			cQueryDXK +=    " AND N73.N73_CODREM = '" + cCodRem	+ "' " 
			cQueryDXK +=    " AND N73.N73_CODSAF = '" + cSafra 	+ "' " 
			cQueryDXK +=    " AND N73.N73_TIPO	 = '" + cTipo	+ "' "		
			cQueryDXK := ChangeQuery( cQueryDXK )
			If select(cAliasDXK) <> 0
				(cAliasDXK)->(dbCloseArea())	
			EndIf
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryDXK),cAliasDXK,.T.,.T.)   
				   	
		   	nQuant += (cAliasDXK)->QTIDADE
			   	
		   	(cAliasDXK)->(dbCloseArea())
	
		ElseIf _cTipQtd == 2	//*MALAS
		   	DbSelectArea("N73")	//Malas
		   	DbSetOrder(1)
		   	If DbSeek( FwXFilial("N73") + cSafra + cCodRem )
		   		While .Not. N73->(Eof())                   .AND.;
		   		      N73->N73_FILIAL ==  FwXFilial("N73") .AND.;
		   		      N73->N73_CODSAF == cSafra            .AND.;
		   		      N73->N73_CODREM == cCodRem
		   			nQuant	++ 
		   			dbSkip()
		   		EndDo 
		   	EndIf
		EndIf
	EndIf	
	
	//**Verifica se produto existe 
    DbSelectArea("SB1")		//Produtos
    DbSetOrder(1)
    If DbSeek( xFilial("SB1") + _cProduto )
    	If .NOT. Empty(SB1->B1_UM) .AND. .NOT. Empty(SB1->B1_LOCPAD)
    		cLocal 	:= SB1->B1_LOCPAD
    		cUm		:= SB1->B1_UM
   		Else 
   			Help( ,, STR0057,, "" , 1, 0,) //"Ajuda""Não foi encontrado o Cliente "#" na tabela SA1." 
			Return( .F. )
   		EndIf 
    EndIf					//Fim - Produtos
	SB1->(DbCloseArea())       

	cItemSeq    := StrZero( nItens, TamSX3( "C6_ITEM" )[1] )
	nPreco      := _nVlrUnit
	nTotal      := A410Arred( nQuant*nPreco , "C6_VALOR" )

	aLinha := {}	                        
	aAdd( aLinha, { "C6_ITEM"       , cItemSeq     	, Nil } )
	aAdd( aLinha, { "C6_PRODUTO"    , _cProduto     , Nil } )
	
	If !Empty(_ClVl)
		aAdd( aLinha, { "C6_CLVL" , _ClVl     , Nil } )
	Endif
	
	If Rastro(_cProduto)
		if .NOT. empty(_cLoteCtl)
			aAdd(aLinha, {"C6_LOTECTL" , _cLoteCtl      , Nil }	)
		endIf
		
		if .NOT. empty(_cNumLote)
			aAdd(aLinha, {"C6_NUMLOTE" , _cNumLote      , Nil }	)
		endIf
		
		if .NOT. empty(_cLocaliz)
			aAdd(aLinha, {"C6_LOCALIZ" , _cLocaliz      , Nil }	)
		endIf
	EndIf
	
	aAdd( aLinha, { "C6_UM"			, cUm			, Nil } )
			
	If !Empty(_cOperFis)
		aAdd( aLinha, { "C6_OPER"        , _cOperFis         , Nil } )
	Endif
	     
	aAdd( aLinha, { "C6_TES"        , _cTes         , Nil } )
	aAdd( aLinha, { "C6_QTDVEN"     , nQuant        , Nil } )
	aAdd( aLinha, { "C6_QTDLIB"     , nQuant        , Nil } )
	aAdd( aLinha, { "C6_PRCVEN"     , nPreco        , "alwaystrue()" } )
	aAdd( aLinha, { "C6_VALOR"      , nTotal        , Nil } )
	aAdd( aLinha, { "C6_LOCAL"      , cLocal        , Nil } )
	aAdd( aLinha, { "C6_ENTREG"     , dDataBase     , Nil } )
	aAdd( aItens, aLinha )	

	DbSelectArea("N73")	//Malas
	DbSetOrder(1)
	If DbSeek( xFilial("N73") + cSafra + cCodRem )	
		cPedN73 := Alltrim(N73->N73_PEDREM)	
	EndIf 
	
   	//**------ PEDIDO DE VENDA	-- EXECAUTO MATA410
    If Len( aCab ) > 0 .And. Len( aItens ) > 0        
		If Empty(cPedN73)
			//*Add C5_NUM Somente momentos antes do Execauto//
			_cPedido :=  GetSxeNum("SC5","C5_NUM")
			aAdd( aCab, { "C5_NUM"     , _cPedido   , UBAA030C5N() } )
			
			//*Ordena conforme o dicionário para uso em rotinas de MSExecAuto.
			aCab 	:= FWVetByDic(aCab		, 'SC5',	.F. )
			aItens 	:= FWVetByDic(aItens	, 'SC6',	.T.	 )
			
	        /*Necessitamos alterar o modulo para a utilização através do SIGAAGR*/
	        cModulo := "FAT"
	        nModulo := 5
			
			//---EXECAUTO MATA410   
			If !IsBLind()    
	 			MsgRun( STR0007, STR0008	, {|| MSExecAuto({ | a, b, c | Mata410( a, b, c ) }, aCab, aItens, 3 ) } )	//"Gerando Documento Fiscal de Saída" # "AGUARDE..."
			Endif
	 
	        /*Retornando o modulo do SIGAAGR*/
	        cModulo := _cModAtu
	        nModulo := _nModAtu
	    	
	    	//*RETORNO DE ERROS DO EXECAUTO
			If lMsErroAuto
				MostraErro()
				RollBackSX8()
				Return(.F.)
			Else //*CONFIRMACAO DO PEDIDO DE VENDA 
				ConfirmSX8() 
				
				lRetorno := UBAF030ATU("ENV", cSafra, cCodRem, cTipo, _cPedido, cNfGerada, cSerie)
				If .NOT. lRetorno
					Help( ,, STR0057,, STR0062 , 1, 0,) //"Ajuda""Não foi possivel gravar o pedido na tabela de malas da remessa (N73)."  
					Return( .F. )
				EndIf				
			EndIf
		Else 
			_cPedido := cPedN73
		EndIf
	EndIf 		
	
	// -- Funçao do AGRXFUN1 - Gera Dcto Fiscal Saída --//
	aGerouDoc := {}
	aGerouDoc := AgrGeraNFS( _cPedido, _cSerie )			
	If ValType(aGerouDoc) == "A" .And. Len(aGerouDoc) > 0
		cNfGerada 	:= aGerouDoc[1]
		cSerie		:= aGerouDoc[2]
		lRetorno	:= .T.
	Else
		lRetorno 	:= .F.
	EndIF

	//**FUNCAO ATUALIZA N72 E N73 / DXJ
	If lRetorno
		lRetorno := UBAF030ATU("ENV", cSafra, cCodRem, cTipo, _cPedido, cNfGerada, cSerie)	
	
		If lRetorno
			AGRGRAVAHIS(,,,,{"N72",xFilial("N72")+cSaFra+cCodRem,"4",STR0061}) 	//"Nota Fiscal Gerada"
			MSGINFO(STR0009 + Chr(13) + Chr(10) + STR0081+cNfGerada +" / " +STR0075+cSerie) //"Documento Fiscal Gerado com Sucesso! Número do documento: 000000 / Série:000"
		Else
        	Return(.F.) 
    	EndIf
    Else
    	Return(.F.) 
    EndIf 
Return(lRetorno)

/*{Protheus.doc} UBAF030NFD
Gera documento de devolvucao - documento fiscal de entrada 

@author 	ana.olegini
@since 		15/02/2017
@version 	1.0
@param 		cSafra		, character, Informação da rotina UBAA030	- SAFRA
@param 		cCodRem		, character, Informação da rotina UBAA030	- REMESSA
@param 		cTipo		, character, Informação da rotina UBAA030	- TIPO VISUAL/HVI
@param 		cCForCli	, character, Informação da rotina UBAA030	- CLIENTE
@param 		cLForCli	, character, Informação da rotina UBAA030	- LOJA CLIENTE
@param		cStatus		, charecter, Informação da rotina UBAA030	- STATUS DA REMESSA
@return 	${return}, ${return_description}
*/
Function UBAF030NFD(cSafra,cCodRem,cTipo,cCForCli,cLForCli,cStatus)
	Local aCab				:= {}	//*Cabeçalho	- SF1
	Local aItens			:= {}	//*Itens		- SD1
	Local aLinha			:= {}	//*Auxiliar 	- aItens
	Local cAliasSD2 		:= GetNextAlias()
	Local cQuerySD2			:= ""
	Local cItemSeq			:= ""
	Local cNumero			:= ''	
	Local lRetorno 			:= .T.
	Local nItens			:= 1
	Local cPergunta         := ""
	
	//*Variavel Privada da rotina MATA103 não pode ser modificada
	Private lMsErroAuto 	:= .F.
    Private _cModAtu    	:= cModulo	//*Salvando Modulo Atual
    Private _nModAtu    	:= nModulo  //*Salvando Modulo Atual
    	
	//*Parametros - SX1 - UBAA030I/UBAA030E
	Private _cTipoDct		:= ""	//*Tipo do Pedido 				- parametro mv_par01
	Private _cProduto		:= ""	//*Produto 						- parametro mv_par02
	Private _cCondPgt		:= ""	//*Condição de Pagamento		- parametro mv_par06
	Private _cEspecie		:= ""	//*Especie 						- parametro mv_par07
	Private _cTes			:= ""	//*Tipo Entrada Saída			- parametro mv_par08
	Private _nVlrUnit		:= 0	//*Valor Unitário				- parametro mv_par09
	Private _cTipQtd		:= ""	//*Tipo da Quantidade			- parametro mv_par10	
	Private _cSerie			:= ""	//**Série da Nota Fiscal		- parametro mv_par11

	If cStatus $ '1|3|4|5'
		Help( ,, STR0039,,STR0080, 1, 0,)	//"Atenção"#"Somente Remessas com status de -Enviadas- podem ser -Estornadas-." 
		Return( .F. )		
	EndIf

	//*"Confirma a devolução da NFS?"
	If !MsgYesNo( STR0010 )	//"Confirma a Devolução do Documento Fiscal?" 
		MsgInfo( STR0006 ) //"Operação abortada!"
		Return( .F. )
	EndIf	

	If cTipo == '1'			//Visual
		If ExistBlock('UB030001')
			cPergunta := ExecBlock('UB030001',.F.,.F.) //Retorna nome do pergunte especifico
			Pergunte(cPergunta,.F.)	//Pergunte Especifico para expedição de amostras visuais
		Else
			PERGUNTE("UBAA030I",.F.)
		EndIf			
	ElseIf cTipo == '2'		//HVI
		If ExistBlock('UB030002')
			cPergunta := ExecBlock('UB030002',.F.,.F.) //Retorna nome do pergunte especifico
			Pergunte(cPergunta,.F.)	//Pergunte Especifico para expedição de amostras visuais
		Else
			PERGUNTE("UBAA030E",.F.)
		EndIf
	EndIf
	
	_cTipoDct	:= mv_par01		//*Tipo do Pedido
	_cProduto	:= mv_par02		//*Produto
	_cCondPgt	:= mv_par06		//*Condição de Pagamento
	_cEspecie	:= mv_par07		//*Especie 
	_cTes		:= mv_par10		//*Tipo Entrada Saída	
	_nVlrUnit	:= mv_par11		//*Valor Unitário
	_cTipQtd	:= mv_par12		//*Tipo da Quantidade
	_cSerie		:= mv_par13		//*Série da Nota Fiscal
	
	If Empty(_cProduto)
		Help( ,, STR0039,, STR0058 , 1, 0,) //"Atenção"#"Não foi possível gerar o documento fiscal de saída. Favor verificar parâmetros de NF em ações relacionadas."
		Return(.F.)
	ElseIf Empty(_cCondPgt)
		Help( ,, STR0039,, STR0058 , 1, 0,) //"Atenção"#"Não foi possível gerar o documento fiscal de saída. Favor verificar parâmetros de NF em ações relacionadas."
		Return(.F.)	
	ElseIf Empty(_cEspecie)
		Help( ,, STR0039,, STR0058 , 1, 0,) //"Atenção"#"Não foi possível gerar o documento fiscal de saída. Favor verificar parâmetros de NF em ações relacionadas."
		Return(.F.)	
	ElseIf Empty(_cTes)
		Help( ,, STR0039,, STR0058 , 1, 0,) //"Atenção"#"Não foi possível gerar o documento fiscal de saída. Favor verificar parâmetros de NF em ações relacionadas."
		Return(.F.)	
	ElseIf Empty(_nVlrUnit)
		Help( ,, STR0039,, STR0058 , 1, 0,) //"Atenção"#"Não foi possível gerar o documento fiscal de saída. Favor verificar parâmetros de NF em ações relacionadas."
		Return(.F.)	
	ElseIf Empty(_cSerie)
		Help( ,, STR0039,, STR0058 , 1, 0,) //"Atenção"#"Não foi possível gerar o documento fiscal de saída. Favor verificar parâmetros de NF em ações relacionadas."
		Return(.F.)		
	EndIf 
	
	//**COM AS MALAS DA N73 - É POSSIVEL IDENTIFICAR O DOCUMENTO - SERIE E PEDIDO GERADO
	//**QUERY REALIZA A BUSCA DA N73 - MALAS COM SD2 - DCTO FISCAL SAIDA
	cQuerySD2 += " SELECT DISTINCT SD2.D2_COD, SD2.D2_DOC,   SD2.D2_SERIE,  SD2.D2_ITEM,  SD2.D2_TES, 
	cQuerySD2 +=                 " SD2.D2_QUANT, SD2.D2_PRCVEN, SD2.D2_TOTAL, SD2.D2_LOCAL, SD2.D2_LOTECTL, "
	cQuerySD2 +=                 " SD2.D2_NUMLOTE, SD2.D2_LOCALIZ "
	cQuerySD2 +=   " FROM " + RetSqlName('N73')+ " N73 "
	cQuerySD2 +=  " INNER JOIN " + RetSqlName('SD2')+ " SD2 ON SD2.D_E_L_E_T_	= '' "
	cQuerySD2 +=                                         " AND SD2.D2_FILIAL	= '" + xFilial("SD2") 	+ "' "          
	cQuerySD2 +=                                         " AND SD2.D2_DOC		= N73.N73_DOCREM "
	cQuerySD2 +=                                         " AND SD2.D2_SERIE		= N73.N73_SERREM "
	cQuerySD2 +=                                         " AND SD2.D2_PEDIDO	= N73.N73_PEDREM "	  
	cQuerySD2 += " WHERE N73.D_E_L_E_T_	= '' "
	cQuerySD2 +=   " AND N73.N73_FILIAL = '" + xFilial("N73") + "' " 
	cQuerySD2 +=   " AND N73.N73_CODSAF	= '" + cSafra 	+ "' " 	
	cQuerySD2 +=   " AND N73.N73_CODREM	= '" + cCodRem 	+ "' " 
	cQuerySD2 +=   " AND N73.N73_TIPO	= '" + cTipo 	+ "' "
	cQuerySD2 := ChangeQuery( cQuerySD2 )
	If select("cAliasSD2") <> 0
		cAliasSD2->( dbCloseArea() )	
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuerySD2),cAliasSD2,.T.,.T.)
   	
   	DbSelectArea(cAliasSD2)
   	(cAliasSD2)->(dbGoTop())
	While .Not. (cAliasSD2)->(Eof())
		
		cItemSeq    := StrZero( nItens, TamSX3( "D1_ITEM" )[1] )
	
		aAdd( aLinha, { "D1_ITEM"       , cItemSeq          		, Nil } )
		aAdd( aLinha, { "D1_COD"        , (cAliasSD2)->D2_COD      	, Nil } )
		
		if .NOT. empty((cAliasSD2)->D2_LOTECTL)
			aAdd( aLinha, { "D1_LOTECTL"    , (cAliasSD2)->D2_LOTECTL  	, Nil } )
		endIf
		
		if .NOT. empty((cAliasSD2)->D2_NUMLOTE)
			aAdd( aLinha, { "D1_NUMLOTE"    , (cAliasSD2)->D2_NUMLOTE  	, Nil } )
		endIf
		
		if .NOT. empty((cAliasSD2)->D2_LOCALIZ)
			aAdd( aLinha, { "D1_LOCALIZ"    , (cAliasSD2)->D2_LOCALIZ  	, Nil } )
		endIf	
		
		aAdd( aLinha, { "D1_QUANT"      , (cAliasSD2)->D2_QUANT  	, Nil } )
		aAdd( aLinha, { "D1_VUNIT"      , (cAliasSD2)->D2_PRCVEN  	, Nil } )
		aAdd( aLinha, { "D1_TOTAL"      , (cAliasSD2)->D2_TOTAL    	, Nil } )
		aAdd( aLinha, { "D1_LOCAL"      , (cAliasSD2)->D2_LOCAL   	, Nil } )
		
		//*Verifica condição de pagamento [nao pode ser igual a tipo 9]
		DbSelectArea("SF4")	//TES
	    DbSetOrder(1)
	    If DbSeek( xFilial( "SF4" )+ (cAliasSD2)->D2_TES )
			If .NOT. Empty(SF4->F4_TESDV)
				aAdd( aLinha, { "D1_TES"    , SF4->F4_TESDV	, Nil } )		//*Busca a TES de devolução da NFS
	    	Else 
				Help( ,, STR0057,, "TES de devolução não informada! Verifique a TES utilizada para a saída ( TES: "+Alltrim((cAliasSD2)->D2_TES)+") ." , 1, 0,) //
				Return( .F. )	    		
	    	EndIf
	    EndIf				//Fim - TES
	    SF4->(DbCloseArea())
		
		aAdd( aLinha, { "D1_NFORI"      , (cAliasSD2)->D2_DOC      	, Nil } )
		aAdd( aLinha, { "D1_SERIORI"    , (cAliasSD2)->D2_SERIE		, Nil } )
		aAdd( aLinha, { "D1_ITEMORI"    , (cAliasSD2)->D2_ITEM     	, Nil } )
		
		nItens ++
		(cAliasSD2)->( dbSkip() )
	EndDo
	aAdd( aItens, aLinha )
	
	If Empty(cNumero)
		cNumero := ''
	EndIf 
	
	//***CABEÇALHO DA NOTA DE ENTRADA
    aAdd( aCab, { "F1_TIPO"     , "D"		} )	//*Nota de Devolução
    aAdd( aCab, { "F1_FORMUL"   , "S"		} ) //*Formulário Proprio = SIM
    aAdd( aCab, { "F1_SERIE"    , _cSerie  	} )	//*Serie - parametro
    aAdd( aCab, { "F1_DOC"      , cNumero	} )
    aAdd( aCab, { "F1_EMISSAO"  , dDataBase } )

	//**Quando for nota de entrada tipo Devolução - o MATA103 trata como cliente
	//**pois gera-se de um pedido de venda e dcto fiscal de saída
	DbSelectArea("SA1")		//Cliente
	DbSetOrder(1)
	If .not. DbSeek( xFilial("SA1")+cCForCli+cLForCli )
		Help( ,, STR0057,, STR0003+cCForCli+" "+cLForCli+STR0004 , 1, 0,) //"Não foi encontrado o Cliente "#" na tabela SA1." 
		Return( .F. )
	EndIf					//Fim - Cliente
	//**busca o estado do cliente
	cUF := SA1->A1_EST
	SA2->(DbCloseArea())  	//Fecha Alias Cliente  
        
    aAdd( aCab, { "F1_FORNECE"  , cCForCli  } )
    aAdd( aCab, { "F1_LOJA"     , cLForCli  } )
    aAdd( aCab, { "F1_UF"       , cUF		} )
    aAdd( aCab, { "F1_ESPECIE"  , _cEspecie } )
 
 	//*Verifica condição de pagamento [nao pode ser igual a tipo 9]
	DbSelectArea("SE4")	//CONDIÇÃO DE PAGAMENTO
    DbSetOrder(1)
    If DbSeek( xFilial( "SE4" )+ _cCondPgt )
        If SE4->E4_TIPO <> "9" 
			aAdd( aCab, { "F1_COND"     , _cCondPgt } )
		EndIf
    EndIf				//Fim - CONDIÇÃO DE PAGAMENTO
    SE4->(DbCloseArea())
    
    //*Ordena conforme o dicionário para uso em rotinas de MSExecAuto.
	aCab	:= FWVetByDic(aCab,   'SF1')
	aItens	:= FWVetByDic(aItens, 'SD1',.T.)
	
	/*Necessitamos alterar o modulo para a utilização através do SIGAAGR*/        
	cModulo := "COM"
	nModulo := 2
        
    //---EXECAUTO MATA410       
 	MsgRun(STR0011, STR0008	, {||MSExecAuto( { | x, y, z | Mata103( x, y, z ) }, aCab, aItens, 3 ) }) //"Gerando Documento de Devolução "#"AGUARDE..."
        
    //Retornando o modulo do SIGAAGR
    cModulo := _cModAtu
    nModulo := _nModAtu
     
    //*RETORNO DE ERROS DO EXECAUTO  
    If lMsErroAuto
    	MostraErro()
   		Return( .f. )
    EndIf

	//**FUNCAO ATUALIZA N72 E N73 / DXJ
	lRetorno := UBAF030ATU("DEV", cSafra, cCodRem, cTipo, '', '', '')
	
	If lRetorno
		AGRGRAVAHIS(,,,,{"N72",xFilial("N72")+cSaFra+cCodRem,"4",STR0063}) 	//"Nota Fiscal Devolução"
		MSGINFO(STR0012)	//"Documento de Devolução Gerado com Sucesso!"
	EndIf 
	
Return(lRetorno)


/*{Protheus.doc} Og430C5NUM()
Função auxiliar de valição do C5_NUM para evitar pular de 2 em 2 o numero.
Sua principal função eh executar um RollbackSX8() (para evitar que se fique pulando o numero.)
sendo executado somente quando o MATA410, estiver validando o numero.
@param     nil
@return    Sempre Verdadeiro
@author    Emerson coelho
@since     24/08/2015
*/
Function UBAA030C5N()
	Local lOk := .T.
	ROLLBACKSX8()
	lok := ExistChav("SC5",fWxFilial('SC5'+_cPedido))
Return( lOk )

/*{Protheus.doc} UBAF030ATU
Atualiza informações de status, data, hora e usuario o qual 
realizou nota de saida e devolução

@author 	ana.olegini
@since 		15/02/2017
@version 	1.0
@param 		cTipoNF		, character, Tipos: ENV(Enviada) ou DEV(Devolução) 
@param 		cSafra		, character, Informação da rotina UBAA030	- SAFRA
@param 		cCodRem		, character, Informação da rotina UBAA030	- REMESSA
@param 		cPedido		, character, Pedido gerado
@param 		cDcto		, character, Documento fiscal gerado
@param 		cSerie		, character, Serie do documento fiscal gerado
@return 	lRetorno	, logico   , Retorno verdadeiro .T. ou falso .F.
*/
Function UBAF030ATU(cTipoNF, cSafra, cCodRem, cTipoRem,cPedido, cDcto, cSerie)
	Local aCab		:= {}
	Local aItens	:= {}
	Local aLinha	:= {}
	Local aModelo	:= {}
	Local cAliasDXJ	:= GetNextAlias()
	Local cQueryDXJ	:= ""
	Local cChave	:= ""
	Local lRetorno 	:= .T. 

	If cTipoNF == "ENV"
		cChave 	:= cSafra + cCodRem
		nIndice := 1
		//**Informar o modelo para gravar via validaçoes MVC
		aAdd( aModelo, { 'UBAA030'		, 'Rotina'		} )	
		aAdd( aModelo, { 'N72UBAA030'	, 'Model Field'	} )	
		aAdd( aModelo, { 'N73UBAA030'	, 'Model Grid'	} )
		
		If .NOT. Empty(cDcto) .AND. .NOT. Empty(cSerie)
			//**N72 - Remessa
			aAdd( aCab, { 'N72_STATUS'	, '2' } )		//*2-ENVIADA
			
			DbSelectArea("N72")
			N72->(DbSetOrder(1)) // N72_FILIAL+N72_SAFRA+N72_CODREM		
			If N72->(DbSeek(FWxFilial("N72")+cSafra+cCodRem))
				
				If N72->N72_TIPO == "1" // Visual					
					// Informa a data e hora de ataulização no envio da remessa para análise
					// para incluir a remessa no aplicativo do Beneficiamento 
					aAdd(aCab, {'N72_DATATU', dDatabase})
					aAdd(aCab, {'N72_HORATU', Time()})
				EndIf				
			EndIf										
			
			//**N73 - Malas
		   	DbSelectArea("N73")	//Malas
		   	DbSetOrder(1)
		   	If DbSeek( xFilial("N73") + cSafra + cCodRem )
		   		While .Not. N73->(Eof()) .AND. N73->N73_CODSAF == cSafra .AND. N73->N73_CODREM == cCodRem
		   			aLinha := {}
		   			aAdd( aLinha, { 'N73_DATENV'	, dDatabase 				} )		
		   			aAdd( aLinha, { 'N73_HORENV'	, Time() 					} )
		   			aAdd( aLinha, { 'N73_USRENV'	, UsrRetName(RetCodUsr())	} )
		   			aAdd( aLinha, { 'N73_DOCREM'	, cDcto 					} )
		   			aAdd( aLinha, { 'N73_SERREM'	, cSerie					} )	   			
		   			aAdd( aCab,   { 'N72_DOCREM'	, cDcto                     } )
		   			aAdd( aCab,   { 'N72_SERREM'	, cSerie                    } )
		   			aAdd( aCab,   { 'N72_DATENV'	, dDatabase                    } )
		   			aAdd( aCab,   { 'N72_HORENV'	,  Time()                   } )
	   			 	aAdd( aItens, aLinha )
	   			 	
	   			 	N73->(dbSkip())
		   		EndDo 	
			EndIf				//Fim Malas
			//**Função grava via validações MVC
			lRetorno := UBAA030MVC( 'N72', 'N73', aCab, aItens, cChave, nIndice, aModelo )		
		
		Else 	//*Empty doc e serie
			DbSelectArea("N73")	//Malas
		   	DbSetOrder(1)
		   	If DbSeek( xFilial("N73") + cSafra + cCodRem )
		   		While .Not. N73->(Eof()) .AND. N73->N73_CODSAF == cSafra .AND. N73->N73_CODREM == cCodRem
		   			aLinha := {}
		   			aAdd( aLinha, { 'N73_PEDREM'	, cPedido } )	
		   			aAdd( aCab,   { 'N72_PEDREM'	, cPedido } )
	   			 	aAdd( aItens, aLinha )
	   			 	N73->(dbSkip())
		   		EndDo 	
			EndIf				//Fim Malas					
			//**Função grava via validações MVC
			lRetorno := UBAA030MVC( 'N72', 'N73', aCab, aItens, cChave, nIndice, aModelo )		
			If .NOT. lRetorno
				lRetorno := .F.
			EndIf	//*lretorno
		EndIf	//*Empty doc e serie
		
		If .NOT. Empty(cDcto) .AND. .NOT. Empty(cSerie)		
			If lRetorno 
				aModelo	:= {}
				aItens 	:= {}
				//**Informar o modelo para gravar via validaçoes MVC
				aAdd( aModelo, { 'AGRA630'		, 'Rotina'		} )	
				aAdd( aModelo, { 'MdFieldDXJ'	, 'Model Field'	} )	
				aAdd( aModelo, { 'MdGridDXK'	, 'Model Grid'	} )
						
				//**DXJ - Romaneio de Classificação
				cQueryDXJ += " SELECT DXJ.DXJ_CODIGO, DXJ.DXJ_SAFRA, DXJ.DXJ_CODUNB, N73.N73_CODREM "
				cQueryDXJ +=   " FROM " + RetSqlName('N73')+ " N73 " 			
				cQueryDXJ +=  " INNER JOIN " + RetSqlName('DXJ')+ " DXJ ON DXJ.D_E_L_E_T_ 	= ' ' "
				cQueryDXJ +=                                         " AND DXJ.DXJ_CODIGO	= N73.N73_CODMAL "
				cQueryDXJ +=                                         " AND DXJ.DXJ_SAFRA	= N73.N73_CODSAF "
				cQueryDXJ +=                                         " AND DXJ.DXJ_TIPO 	= N73.N73_TIPO "
				cQueryDXJ +=   " WHERE N73.D_E_L_E_T_	= ' ' "
				cQueryDXJ +=     " AND N73.N73_CODREM	= '" + cCodRem 	+ "' " 
				cQueryDXJ +=     " AND N73.N73_CODSAF	= '" + cSafra 	+ "' " 
				cQueryDXJ +=     " AND N73.N73_TIPO		= '" + cTipoRem + "' "
				cQueryDXJ := ChangeQuery( cQueryDXJ )
				If select("cAliasDXJ") <> 0
					cAliasDXJ->( dbCloseArea() )	
				EndIf
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryDXJ),cAliasDXJ,.T.,.T.)
			   	
			   	//**Percorrer Todas as Malas da DXJ
				While .Not. (cAliasDXJ)->(Eof())
					aCab   := {}
			   		aLinha := {}
			   		aAdd( aLinha, { 'DXJ_CODUNB', (cAliasDXJ)->DXJ_CODUNB	} )	
			   		aAdd( aLinha, { 'DXJ_DATENV', dDatabase 				} )		
			   		aAdd( aLinha, { 'DXJ_HORENV', Time() 					} )
			   		aAdd( aLinha, { 'DXJ_USRENV', UsrRetName(RetCodUsr()) 	} )				
					aAdd( aCab, aLinha )
					
					cChave 	:= cSafra + (cAliasDXJ)->DXJ_CODIGO + cTipoRem
					nIndice	:= 3
										
					dbSelectArea( "DXJ" )
					dbSetOrder( nIndice )
					If DbSeek( xFilial( "DXJ" ) + cChave )
						RecLock("DXJ")
							DXJ->DXJ_DATENV	:= dDatabase
							DXJ->DXJ_HORENV := Time()
							DXJ->DXJ_USRENV	:= UsrRetName(RetCodUsr())
																					
							DXJ->DXJ_DATATU	:= dDatabase
							DXJ->DXJ_HORATU := Time()							
	                	MsUnLock()
					EndIf
					(cAliasDXJ)->(dbSkip())
				EndDo
			Else
				lRetorno := .F.
			EndIf		//*lretorno
		EndIf	//*Empty doc e serie
		 
	ElseIf cTipoNF == "DEV"

		cChave 	:= cSafra + cCodRem
		nIndice := 1
		//**Informar o modelo para gravar via validaçoes MVC
		aAdd( aModelo, { 'UBAA030'		, 'Rotina'		} )	
		aAdd( aModelo, { 'N72UBAA030'	, 'Model Field'	} )	
		aAdd( aModelo, { 'N73UBAA030'	, 'Model Grid'	} )

		//**N72 - Remessa
		aAdd( aCab, { 'N72_STATUS'	, '5' } )		//*5 - CANCELADA
		
		DbSelectArea("N72")
		N72->(DbSetOrder(1)) // N72_FILIAL+N72_SAFRA+N72_CODREM			
		If N72->(DbSeek(FWxFilial("N72")+cSafra+cCodRem))
			
			If N72->N72_TIPO == "1" // Visual				
				// Informa a data e hora de ataulização no envio da remessa para análise
				// para excluir a remessa no aplicativo do Beneficiamento 
				aAdd(aCab, {'N72_DATATU', dDatabase})
				aAdd(aCab, {'N72_HORATU', Time()})
			EndIf				
		EndIf
		
		//**N73 - Malas
	   	DbSelectArea("N73")	//Malas
	   	DbSetOrder(1)
	   	If DbSeek( xFilial("N73") + cSafra + cCodRem )
	   		While .Not. N73->(Eof()) .AND. N73->N73_CODSAF == cSafra .AND. N73->N73_CODREM == cCodRem
	   			aLinha := {}
	   			aAdd( aLinha, { 'N73_DATENV'	, CToD("  /  /    ") } )		
	   			aAdd( aLinha, { 'N73_HORENV'	, '' } )
	   			aAdd( aLinha, { 'N73_USRENV'	, '' } )
	   			aAdd( aLinha, { 'N73_PEDREM'	, '' } )		
	   			aAdd( aLinha, { 'N73_DOCREM'	, '' } )
	   			aAdd( aLinha, { 'N73_SERREM'	, '' } )	   			
   			 	aAdd( aItens, aLinha )
   			 	
   			 	N73->(dbSkip())
	   		EndDo 	
		EndIf				//Fim Malas
				
		//**Função grava via validações MVC
		lRetorno := UBAA030MVC( 'N72', 'N73', aCab, aItens, cChave, nIndice, aModelo )
		
		If lRetorno
			aModelo	:= {}
			aItens 	:= {}
			//**Informar o modelo para gravar via validaçoes MVC
			aAdd( aModelo, { 'AGRA630'		, 'Rotina'		} )	
			aAdd( aModelo, { 'MdFieldDXJ'	, 'Model Field'	} )	
			aAdd( aModelo, { 'MdGridDXK'	, 'Model Grid'	} )
					
			//**DXJ - Romaneio de Classificação
			cQueryDXJ += " SELECT DXJ.DXJ_CODIGO, DXJ.DXJ_SAFRA, DXJ.DXJ_CODUNB, N73.N73_CODREM "
			cQueryDXJ +=   " FROM " + RetSqlName('N73')+ " N73 " 			
			cQueryDXJ +=  " INNER JOIN " + RetSqlName('DXJ')+ " DXJ ON DXJ.D_E_L_E_T_ 	= ' ' "
			cQueryDXJ +=                                         " AND DXJ.DXJ_CODIGO	= N73.N73_CODMAL "
			cQueryDXJ +=                                         " AND DXJ.DXJ_SAFRA	= N73.N73_CODSAF "
			cQueryDXJ +=   " WHERE N73.D_E_L_E_T_	= ' ' "
			cQueryDXJ +=     " AND N73.N73_CODREM	= '" + cCodRem 	+ "' " 
			cQueryDXJ +=     " AND N73.N73_CODSAF	= '" + cSafra 	+ "' " 
			cQueryDXJ +=     " AND N73.N73_TIPO		= '" + cTipoRem + "' "
			cQueryDXJ := ChangeQuery( cQueryDXJ )
			If select("cAliasDXJ") <> 0
				cAliasDXJ->( dbCloseArea() )	
			EndIf
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryDXJ),cAliasDXJ,.T.,.T.)
		   	
		   	//**Percorrer Todas as Malas da DXJ
			While .Not. (cAliasDXJ)->(Eof())
				aCab   := {}
		   		aLinha := {}
		   		aAdd( aLinha, { 'DXJ_DATENV', CToD("  /  /    ") } )		
		   		aAdd( aLinha, { 'DXJ_HORENV', '' } )
		   		aAdd( aLinha, { 'DXJ_USRENV', '' } )				
				aAdd( aCab, aLinha )
				
				cChave 	:= cSafra + (cAliasDXJ)->DXJ_CODIGO + cTipoRem
				nIndice	:= 3
				
				dbSelectArea( "DXJ" )
				dbSetOrder( nIndice )
				If DbSeek( xFilial( "DXJ" ) + cChave )
					RecLock("DXJ")
						DXJ->DXJ_DATENV	:= CToD("  /  /    ")
						DXJ->DXJ_HORENV := ''
						DXJ->DXJ_USRENV	:= ''
												
						DXJ->DXJ_DATATU	:= dDatabase
						DXJ->DXJ_HORATU := Time()						
                	MsUnLock()
				EndIf
				(cAliasDXJ)->(dbSkip())
			EndDo
		Else
			lRetorno := .F.
		EndIf
	EndIf

Return(lRetorno)


/** {Protheus.doc} UBAA030MVC
Função grava MVC via modelo de dados

@param:     Nil
@author:    Marcelo Wesan
@since:     16/02/2017
@Uso:       UBAA030REC
*/
Function UBAA030MVC( cMaster, cDetail, aCpoMaster, aCpoDetail, cChave, nIndice, aModelo )
	Local aAreaOri	:= GetArea()
	Local oModel	:= Nil
	Local oAux		:= Nil
	Local oStruct	:= Nil
	Local aAux 		:= {}
	Local nItErro 	:= 0
	Local nI 		:= 0
	Local nJ 		:= 0
	Local nPos 		:= 0
	Local lAux 		:= .T.
	Local lRet 		:= .T.
	
	//*Variaveis para utilização do modelo de dados
	cRotina := aModelo[1][1]	//Nome da Rotina 
	cModelo	:= aModelo[2][1]	//Nome do modelo do field
	cGridMo := aModelo[3][1]	//Nome do modelo do grid
	
	If cRotina == "AGRA630"
		cUserBenf := ''
		//dbSelectArea( cMaster )
		//dbSetOrder( nIndice )
		//If DbSeek( xFilial( cMaster ) + cChave )
		//	cUserBenf := DXJ->DXJ_CODUNB
		//EndIf
	EndIf
	
	oModel := FWLoadModel( cRotina )
	// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
	oModel:SetOperation( 4 )
	// Antes de atribuirmos os valores dos campos temos que ativar o modelo
	//oModel:Activate()
	IF !oModel:Activate() // Verificando se o VldActivate Falhou
		cMsg := oModel:GetErrorMessage()[3] + oModel:GetErrorMessage()[6]
		Help( ,,"AJUDA",,cMsg, 1, 0 ) //"Ajuda"
		Return (.f.)
	EndIF
	
	// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
	oAux := oModel:GetModel( cModelo )   // Modelo da NJJ Cab. Romaneio = NJJUNICO, dos Itens == NJMUnico
	// Obtemos a estrutura de dados do cabeçalho
	oStruct := oAux:GetStruct()
	aAux := oStruct:GetFields()
	If lRet .AND. .NOT. Empty(cMaster)
		dbSelectArea( cMaster )
		dbSetOrder( nIndice )
		If DbSeek( xFilial( cMaster ) + cChave )
		
			For nI := 1 To Len( aCpoMaster )
				// Verifica se os campos passados existem na estrutura do cabeçalho
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoMaster[nI][1] ) } ) ) > 0
					// È feita a atribuição do dado aos campo do Model do cabeçalho
					If !( lAux := oModel:SetValue( cModelo, aCpoMaster[nI][1],aCpoMaster[nI][2] ) )
						// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
						// o método SetValue retorna .F.
						lRet := .F.
						Exit
					EndIf
				EndIf
			Next
		EndIf
	EndIf
	If lRet .AND. .NOT. Empty(cDetail)
		dbSelectArea( cDetail )
		dbSetOrder( nIndice )
		If DbSeek( xFilial( cDetail ) + cChave )			
			// Instanciamos apenas a parte do modelo referente aos dados do item
			oAux := oModel:GetModel( cGridMo )
			// Obtemos a estrutura de dados do item
			oStruct := oAux:GetStruct()
			aAux := oStruct:GetFields()
			nItErro := 0
			For nI := 1 To Len( aCpoDetail )
				// Atribui a linha que quer alterar
				oAux:GoLine( nI )
			If .NOT. aCpoDetail[nI][1][1] = "Recebido" 
				For nJ := 1 To Len( aCpoDetail[nI] )					
					// Verifica se os campos passados existem na estrutura de item
					If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoDetail[nI][nJ][1] ) } ) ) > 0
						If .NOT. ( lAux := oModel:SetValue( cGridMo, aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2] ) )
							// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
							// o método SetValue retorna .F.
							lRet 	:= .F.
							nItErro := nI
							Exit
						EndIf
					EndIf
				Next
			EndIf	
			If !lRet
				Exit
			EndIf
		 Next
	 EndIf
	EndIf
	If lRet
		// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
		// neste momento os dados não são gravados, são somente validados.
		If lRet := oModel:VldData()
			// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
			lRet := oModel:CommitData()
		EndIf
	EndIf
	If !lRet
		// Se os dados não foram validados obtemos a descrição do erro para gerar
		// LOG ou mensagem de aviso
		aErro := oModel:GetErrorMessage()
		AutoGrLog( STR0013 	+ ' [' + AllToChar( aErro[1] ) + ']' )	//"Id do formulário de origem:"
		AutoGrLog( STR0014 	+ ' [' + AllToChar( aErro[2] ) + ']' )	//"Id do campo de origem: "
		AutoGrLog( STR0015 	+ ' [' + AllToChar( aErro[3] ) + ']' )	//"Id do formulário de erro: "
		AutoGrLog( STR0016 	+ ' [' + AllToChar( aErro[4] ) + ']' )	//"Id do campo de erro: "
		AutoGrLog( STR0017	+ ' [' + AllToChar( aErro[5] ) + ']' )	//"Id do erro: "
		AutoGrLog( STR0018	+ ' [' + AllToChar( aErro[6] ) + ']' )	//"Mensagem do erro: "
		AutoGrLog( STR0019	+ ' [' + AllToChar( aErro[7] ) + ']' )	//"Mensagem da solução: "
		AutoGrLog( STR0020	+ ' [' + AllToChar( aErro[8] ) + ']' )  //"Valor atribuído: "
		AutoGrLog( STR0021	+ ' [' + AllToChar( aErro[9] ) + ']' )	//"Valor anterior: "
		If nItErro > 0
			AutoGrLog( STR0022	+ ' [' + AllTrim( AllToChar( nItErro ) ) + ']' )	//"Erro no Item: "
		EndIf
		If !IsBLind()
			MostraErro()
		Endif
	EndIf
	// Desativamos o Model
	oModel:DeActivate()
	RestArea(aAreaOri)
Return lRet


/** {Protheus.doc} UBAF030REC
Função de recebimento de remessa e malas atraves do codigo de barras

@param:     Nil
@author:    Marcelo Wesan
@since:     16/02/2017
@Uso:       UBAA030REC
*/
Function UBAF030REC()
	Local cCodBar := Space(TamSX3("DXJ_CODBAR")[1])
	
	Private dData := dDataBase
    	Private cHora := Time()
    
    //-------------------------------------------------------------------
    // Define a janela do Browse
    //-------------------------------------------------------------------
    DEFINE MSDIALOG oDlg Title STR0023 FROM 0,0 TO 200,420 PIXEL //Gestão de Remessa
    
    oLayer := FWLayer():new()
    oLayer:Init(oDlg,.F.)
    
    oLayer:addLine('LinhaSuperior',100,.F.,)
    oLayer:addColumn('ColSuperior',100,.F.,'LinhaSuperior')
    oLayer:addWindow('ColSuperior','C1_Win01',STR0024 + ''  ,100,.F.,.F.,,'LinhaSuperior',)//Recebimento
    oTopGrid2   := oLayer:getwinpanel('ColSuperior','C1_Win01','LinhaSuperior')
    oFont 		:= TFont():New('Arial',,15,.T.)    
    
    oSay1:= tSay():New(30,10,{||STR0034},oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,120,30)//Cod. Barra
    oSay2:= tSay():New(30,117,{||STR0035},oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,40,30) //Data
    oSay3:= tSay():New(30,162,{||STR0036},oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,40,30) //Hora

    @ 40,10 MSGET cCodBar  SIZE 100,7  PIXEL 
    @ 40,117 MSGET dData  	SIZE 40,7 PIXEL WHEN .F.
    @ 40,162 MSGET cHora  	SIZE 40,7 PIXEL WHEN .F.
   
    oTButtonCancel    := TButton():Create(  oLayer:getColPanel('ColSuperior','LinhaSuperior'),78,105,STR0037  ,{||UBAF030CAC()},40,10,,,,.T.,,,,,,)//Cancelar
    oTButtonComfir    := TButton():Create(  oLayer:getColPanel('ColSuperior','LinhaSuperior'),78,150,STR0038  ,{|| UBAF030OK(cCodBar)},40,10,,,,.T.,,,,,,)//Confirmar
    
    ACTIVATE MSDIALOG oDlg CENTERED
    
Return()

/** {Protheus.doc} UBAF030CAC
Função botão de cancelamento de remessa/mala - tela

@param:     Nil
@author:    Marcelo Wesan
@since:     16/02/2017
@Uso:       UBAF030REC
*/
 Static Function  UBAF030CAC()
    lCancelou := .F.
    oDlg:end()
Return

/** {Protheus.doc} UBAF030OK
Valida o codigo de barras recebido e atualiza as tabelas na N72, N73, DXJ

@param:     Nil
@author:    Marcelo Wesan
@since:     15/02/2017
@Uso:       UBAF030OK
*/
Static Function UBAF030OK(cCodBar)
    Local cHoraAlterado := ''
    Local cData
    Local aConteudo := Separa(cCodBar,"-")
    Local cRem :=""
    Local cStat :=""
    Local cFil   :=""
    Local cSafra :=""
    Local cCodRem:=""
    Local cTipoR :=""
    Local cTipoA :=""
    Local cCodMal:=""
    Local cTipM  :=""
    Local cTipR  :=""

    If Len(aConteudo) = 5 .AND. aConteudo[5] = "ML" 
		cFil      := Alltrim(aConteudo[1]) 
    	cSafra    := PADR(Alltrim(aConteudo[2]),TamSX3('N72_SAFRA')[1],' ')
      	cCodMal   := Alltrim(aConteudo[3])
      	cTipoR    := Alltrim(aConteudo[4])
      	cTipoA    := Alltrim(aConteudo[5])
      
    ElseIf Len(aConteudo) = 4 .AND. aConteudo[4] = "RM"     
      	cFil      := Alltrim(aConteudo[1])  
      	cSafra    := PADR(Alltrim(aConteudo[2]),TamSX3('N72_SAFRA')[1],' ')
      	cCodRem   := Alltrim(aConteudo[3]) 
     	cTipoR    := Alltrim(aConteudo[4])
      	cTipoA    := " "
    Else
      	MsgInfo(STR0025)	//????
      	Return (.F.)
    EndIf
     
    cData 	   		:= dtoc(dData)
    cHoraAlterado 	:= strtran(substring(cHora,1,5),':','')
     
    dbSelectArea("N72")
    dbSetOrder(1)
    If cTipoR == "RM" .AND. cTipoA == " "  .AND. N72->(DbSeek(XFilial("N72") +cSafra+ cCodRem))
    	cStat := N72->N72_STATUS
    	cTipR := N72->N72_TIPO
    	If cTipR = "1"
	      	If cStat = "2" .or. cStat = "4" 
	        	dbSelectArea("N73")
	        	dbSetOrder(1)
	        	If N73->(DbSeek(XFilial("N73") +cSafra+ cCodRem)) 
	        		cTipoRem := N73->N73_TIPO
	        		lRetorno := UBAF030REM(cSafra, cCodRem,cTipoRem )	        	
		        	If lRetorno
		        		AGRGRAVAHIS(,,,,{"N72",xFilial("N72")+cSaFra+cCodRem,"4","RECEBIMENTO REMESSA"}) //
		           		MsgInfo(STR0026)//Remessa recebida com sucesso! 		           		
		        	Else 
		          		Help( ,, STR0039,, STR0027 , 1, 0,)	//"Atenção"#"Não foi possivel receber a Remessa"
		          		Return(.F.)
					EndIf //Fim lRetorno
				EndIf	//Fim N73
			Else
				If cStat = "1"
					Help( ,, STR0039,, STR0028 , 1, 0,)	//"Atenção"#Somente Remessas com status -Enviada- ou -Entregue Parcial- podem ser -Recebidas-.
			    EndIf
			    If cStat = "5"
			      	Help( ,, STR0039,, STR0028 , 1, 0,)	//"Atenção"#Somente Remessas com status -Enviada- ou -Entregue Parcial- podem ser -Recebidas-.
			    EndIf
			    If cStat = "3"
			      	Help( ,, STR0039,, STR0028 , 1, 0,)	//"Atenção"#Somente Remessas com status -Enviada- ou -Entregue Parcial- podem ser -Recebidas-.
			    EndIf
		    EndIf
		 Else
		 	Help( ,, STR0039,, STR0059 , 1, 0,)	//"Atenção"#Só é possivel receber remessas do tipo Visual!
		 EndIf    
	Else
		dbSelectArea("DXJ")
     	dbSetOrder(3)
     	If cTipoA == "ML" .AND. DXJ->(DbSeek(XFilial("DXJ") +cSafra+ cCodMal+ cTipoR))
     	 cTipM := DXJ->DXJ_TIPO
     	  If cTipM = "1"
	      		dbSelectArea("N73")
	      		N73->(DbSetOrder(2))
		      	If N73->(DbSeek(XFilial("N73") + cSafra + cCodMal + cTipoR))
		      		While !N73->(Eof()) .AND. N73->(N73_FILIAL+N73_CODSAF+N73_CODMAL+N73_TIPO) == XFilial("N73")+cSafra+cCodMal+cTipoR
		      					      		
			        	cRem := N73->N73_CODREM
			        	dbSelectArea("N72")
			        	N72->(DbSetOrder(1))
				        If .not. N72->(DbSeek(XFilial("N72") +cSafra+ cRem))     
				        	MsgInfo(STR0025)
				        	EXIT
				        Else
				        	If N72->N72_STATUS == "5" // Cancelado
				        		cStat := N72->N72_STATUS
				        		N73->(DbSkip())
				        		LOOP
				        	Else
				        		cStat := N72->N72_STATUS
				        		EXIT
				        	EndIf				        	
				        EndIf
				        
				        N73->(DbSkip())
				    EndDo
		      	EndIf 
		      	If cStat = "2" .or. cStat = "4"
			    	If Empty(Alltrim(DXJ->DXJ_DATREC)) .AND. Empty(Alltrim(DXJ->DXJ_HORREC)) .AND. Empty(Alltrim(DXJ->DXJ_USRREC)) 
				        //atualiza dxj e N73		       
				        lRetorno := UBAF030MAL(cSafra, cCodMal, cTipoR, cRem)		        
					    If lRetorno
					    	AGRGRAVAHIS(,,,,{"N72",xFilial("N72")+cSaFra+cRem,"4","RECEBIMENTO MALA"}) //
					    	MsgInfo(STR0031)//Mala recebida com sucesso!					    	
					    Else 
					    	Help( ,, STR0039,, STR0032 , 1, 0,)	//"Atenção"#Não foi possivel receber a mala
					        Return(.F.)
					    EndIf
					Else
						Help( ,, STR0039,, STR0033 , 1, 0,)	//"Atenção"#Somente Remessas com status -Enviada- ou -Entregue Parcial- podem ser -Recebidas-.
					EndIf
				Else
					If cStat = "1"
						Help( ,, STR0039,, STR0028 , 1, 0,)	//"Atenção"#Somente Remessas com status -Enviada- ou -Entregue Parcial- podem ser -Recebidas-.
					EndIf
					If cStat = "5"
						Help( ,, STR0039,, STR0028 , 1, 0,)	//"Atenção"#Somente Remessas com status -Enviada- ou -Entregue Parcial- podem ser -Recebidas-.
					EndIf
					If cStat = "3"
						Help( ,, STR0039,, STR0028 , 1, 0,)	//"Atenção"#Somente Remessas com status -Enviada- ou -Entregue Parcial- podem ser -Recebidas-.
					EndIf
				EndIf
		  Else
		     Help( ,, STR0039,, STR0060 , 1, 0,)	//"Atenção"#Só é possivel receber malas  do tipo Visual!
		  EndIf	
		Else
			Help( ,, STR0039,, STR0025 , 1, 0,)//Informe um codigo de barras válido!!			
		EndIf
	EndIf	
Return()


/*{Protheus.doc} UBAF030REM
Atualiza informações de status, data, hora e usuario o qual 
realizou o recebimento de uma remessa

@author 	marcelo.wesan
@since 		17/02/2017
@version 	1.0
@param 		cSafra		, character, Informação da rotina UBAA030	- SAFRA
@param 		cCodRem		, character, Informação da rotina UBAA030	- REMESSA
@param 		cTipoRem	, character, Informação da rotina UBAA030   - Tipo Remessa
@return 	lRetorno	, logico   , Retorno verdadeiro .T. ou falso .F.
*/
Function UBAF030REM(cSafra, cCodRem, cTipoRem)
    Local aCab		:= {}
	Local aItens	:= {}
	Local aLinha	:= {}
	Local aModelo	:= {}
	Local cAliasDXJ	:= GetNextAlias()
	Local cQueryDXJ	:= ""
	Local lRetorno 	:= .T. 
	Local cChave 	:= cSafra + cCodRem
	Local nIndice := 1
		
	//**Informar o modelo para gravar via validaçoes MVC
	aAdd( aModelo, { 'UBAA030'		, 'Rotina'		} )	
	aAdd( aModelo, { 'N72UBAA030'	, 'Model Field'	} )	
	aAdd( aModelo, { 'N73UBAA030'	, 'Model Grid'	} )
		
	//**N73 - Remessa
	DbSelectArea("N73")	//Remessa
	DbSetOrder(1)
	If DbSeek( xFilial("N73") + cSafra + cCodRem )
		aAdd( aCab, { 'N72_STATUS'	, '3' } )		//*2-entregue
		
		DbSelectArea("N72")
		N72->(DbSetOrder(1)) // N72_FILIAL+N72_SAFRA+N72_CODREM			
		If N72->(DbSeek(FWxFilial("N72")+cSafra+cCodRem))
			
			If N72->N72_TIPO == "1" // Visual				
				// Informa a data e hora de ataulização no envio da remessa para análise
				// para excluir a remessa no aplicativo do Beneficiamento 
				aAdd(aCab, {'N72_DATATU', dDatabase})
				aAdd(aCab, {'N72_HORATU', Time()})
			EndIf				
		EndIf
		
	   	While .Not. N73->(Eof()) .AND. N73->N73_CODSAF == cSafra .AND. N73->N73_CODREM == cCodRem
	   		If Empty(N73->N73_DATREC) .AND. Empty(N73->N73_HORREC).AND. Empty(N73->N73_USRREC)
		   		aLinha := {}
	   			
	   			aAdd( aLinha, { 'N73_DATREC'	, dDatabase 				} )		
	   			aAdd( aLinha, { 'N73_HORREC'	, Time() 					} )
	   			aAdd( aLinha, { 'N73_USRREC'	, UsrRetName(RetCodUsr())	} )
   			 	aAdd(aItens, aLinha)
	   		Else
	   		 	aAdd(aItens, {{"Recebido"}})
	   		EndIf
   			 	N73->(dbSkip())
	   		EndDo 	
	EndIf				//Fim Remessas

	//**Função grava via validações MVC
	lRetorno := UBAA030MVC( 'N72', 'N73', aCab, aItens, cChave, nIndice, aModelo)
		
	If lRetorno		//Função grava malas na DXJ
		aModelo	:= {}
		aItens 	:= {}
		
		//**Informar o modelo para gravar via validaçoes MVC
		aAdd( aModelo, { 'AGRA630'		, 'Rotina'		} )	
		aAdd( aModelo, { 'MdFieldDXJ'	, 'Model Field'	} )	
		aAdd( aModelo, { 'MdGridDXK'	, 'Model Grid'	} )
					
		//**DXJ - Romaneio de Classificação
		cQueryDXJ += " SELECT DXJ.DXJ_CODIGO, DXJ.DXJ_SAFRA, DXJ.DXJ_CODUNB, N73.N73_CODREM "
		cQueryDXJ +=   " FROM " + RetSqlName('N73')+ " N73 " 			
		cQueryDXJ +=  " INNER JOIN " + RetSqlName('DXJ')+ " DXJ ON DXJ.D_E_L_E_T_ 	= ' ' "
		cQueryDXJ +=                                         " AND DXJ.DXJ_CODIGO	= N73.N73_CODMAL "
		cQueryDXJ +=                                         " AND DXJ.DXJ_SAFRA	= N73.N73_CODSAF "
		cQueryDXJ +=   " WHERE N73.D_E_L_E_T_	= ' ' "
		cQueryDXJ +=     " AND N73.N73_CODREM	= '" + cCodRem 	+ "' " 
		cQueryDXJ +=     " AND N73.N73_CODSAF	= '" + cSafra 	+ "' " 
		cQueryDXJ +=     " AND N73.N73_TIPO		= '" + cTipoRem + "' "
		cQueryDXJ := ChangeQuery( cQueryDXJ )
		If select("cAliasDXJ") <> 0
			cAliasDXJ->( dbCloseArea() )	
		EndIf
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryDXJ),cAliasDXJ,.T.,.T.)
		   	
		//**Percorrer Todas as Malas da DXJ
		While .Not. (cAliasDXJ)->(Eof())
			aCab   := {}
			aLinha := {}
		  	aAdd( aLinha, { 'DXJ_CODUNB', (cAliasDXJ)->DXJ_CODUNB	} )	
		   	aAdd( aLinha, { 'DXJ_DATREC', dDatabase 				} )		
		   	aAdd( aLinha, { 'DXJ_HORREC', Time() 					} )
		   	aAdd( aLinha, { 'DXJ_USRREC', UsrRetName(RetCodUsr()) 	} )				
			aAdd( aCab, aLinha )
				
			cChave 	:= cSafra + (cAliasDXJ)->DXJ_CODIGO + cTipoRem
			nIndice	:= 3
				
			dbSelectArea( "DXJ" )
			dbSetOrder( nIndice )
			If DbSeek( xFilial( "DXJ" ) + cChave )
				If Empty(DXJ->DXJ_DATREC) .AND. Empty(DXJ->DXJ_HORREC) .AND. Empty(DXJ->DXJ_USRREC)
					RecLock("DXJ")
						DXJ->DXJ_DATREC:= dDatabase
						DXJ->DXJ_HORREC := Time()
						DXJ->DXJ_USRREC	:= UsrRetName(RetCodUsr())
												
						DXJ->DXJ_DATATU	:= dDatabase
						DXJ->DXJ_HORATU := Time()
												
	               	MsUnLock()
	               EndIf
			EndIf
			(cAliasDXJ)->(dbSkip())
		EndDo
	Else
		lRetorno := .F.
	EndIf
Return (lRetorno)	
	
/*{Protheus.doc} UBAF030MAL
Atualiza informações de status, data, hora e usuario o qual 
realizou o recebimento de uma mala

@author 	marcelo.wesa
@since 		20/02/2017
@version 	1.0
@param 		cSafra		, character, Informação da rotina UBAA030	- SAFRA
@param 		cRem		, character, Informação da rotina UBAA030	- REMESSA
@param 		cTipoR	    , character, Informação da rotina UBAA030   - Tipo Remessa
@param 		cCodMal	    , character, Informação da rotina UBAA030   - MALA
@return 	lRetorno	, logico   , Retorno verdadeiro .T. ou falso .F.
*/
Function UBAF030MAL(cSafra, cCodMal, cTipoR,cRem)  
    Local aCab		:= {}
	Local aItens	:= {}
	Local aLinha	:= {}
	Local aModelo	:= {}
	Local cAliasDXJ	:= GetNextAlias()
	Local cQueryDXJ	:= ""
	Local lRetorno 	:= .T. 
	Local cChave 	:= cSafra + cRem
	Local nIndice 	:= 1
	Local nCount	:= 0
		
	//**Informar o modelo para gravar via validaçoes MVC
	aAdd( aModelo, { 'UBAA030'		, 'Rotina'		} )	
	aAdd( aModelo, { 'N72UBAA030'	, 'Model Field'	} )	
	aAdd( aModelo, { 'N73UBAA030'	, 'Model Grid'	} )


	//**N73 - Malas
	DbSelectArea("N73")	//Malas
	DbSetOrder(1)
	If DbSeek( xFilial("N73") + cSafra + cRem  )
	 	While .Not. N73->(Eof()) .AND. N73->N73_CODSAF == cSafra .AND. N73->N73_CODREM == cRem
	   		If Empty(N73->N73_DATREC) .AND. Empty(N73->N73_HORREC).AND. Empty(N73->N73_USRREC)
		   	  	nCount++
		   	  	IF N73->N73_CODMAL == cCodMal
			   		aLinha := {}
			   		aAdd( aLinha, { 'N73_DATREC'	, dDatabase 				} )		
			   		aAdd( aLinha, { 'N73_HORREC'	, Time() 					} )
			   		aAdd( aLinha, { 'N73_USRREC'	, UsrRetName(RetCodUsr())	} )	   			  			
			  		aAdd( aItens, aLinha )
			   	Else
			   		aAdd(aItens, {{"Recebido"}}) 	//
			   	EndIf
			Else   	
			   	aAdd(aItens, {{"Recebido"}})
   			EndIf
   		 	N73->(dbSkip())
	   	EndDo 	
	EndIf				//Fim Malas
				
	If nCount > 1
		aAdd( aCab, { 'N72_STATUS'	, '4' } )		//*4-entregue parcial
	ElseIf nCount == 1
		aAdd( aCab, { 'N72_STATUS'	, '3' } )		//*3-entregue
	EndIf
	
	If nCount > 0 // Se vai alterar o status da remessa para 4 ou 3	
		DbSelectArea("N72")
		N72->(DbSetOrder(1)) // N72_FILIAL+N72_SAFRA+N72_CODREM			
		If N72->(DbSeek(FWxFilial("N72")+cSafra+cRem))		
			If N72->N72_TIPO == "1" // Visual
				// Informa a data e hora de ataulização no envio da remessa para análise
				// para excluir/alterar a remessa no aplicativo do Beneficiamento 
				aAdd(aCab, {'N72_DATATU', dDatabase})
				aAdd(aCab, {'N72_HORATU', Time()})
			EndIf				
		EndIf			
	EndIf
		
 		
	//**Função grava via validações MVC
	lRetorno := UBAA030MVC( 'N72', 'N73', aCab, aItens, cChave, nIndice, aModelo )
	If lRetorno		//Função grava malas na DXJ
		aModelo	:= {}
		aItens 	:= {}
		//**Informar o modelo para gravar via validaçoes MVC
		aAdd( aModelo, { 'AGRA630'		, 'Rotina'		} )	
		aAdd( aModelo, { 'MdFieldDXJ'	, 'Model Field'	} )	
		aAdd( aModelo, { 'MdGridDXK'	, 'Model Grid'	} )
					
		//**DXJ - Romaneio de Classificação
		cQueryDXJ += " SELECT N73.N73_CODREM, DXJ.DXJ_CODIGO, DXJ.DXJ_SAFRA, "
		cQueryDXJ += " DXJ.DXJ_TIPO, DXJ.DXJ_DATREC, DXJ.DXJ_HORREC, DXJ.DXJ_USRREC  "
		cQueryDXJ +=   " FROM " + RetSqlName('DXJ')+ " DXJ " 			
		cQueryDXJ +=  " INNER JOIN " + RetSqlName('N73')+ " N73 ON N73.D_E_L_E_T_ 	= ' ' "
		cQueryDXJ +=                                         " AND N73.N73_CODMAL = DXJ.DXJ_CODIGO "
		cQueryDXJ +=                                         " AND N73.N73_CODSAF = DXJ.DXJ_SAFRA "
		cQueryDXJ +=                                         " AND N73.N73_TIPO	 = DXJ.DXJ_TIPO  "                          
		cQueryDXJ +=   " WHERE DXJ.D_E_L_E_T_	= ' ' "
		cQueryDXJ +=     " AND DXJ.DXJ_SAFRA	= '" + cSafra 	+ "' " 
		cQueryDXJ +=     " AND DXJ.DXJ_CODIGO	= '" + cCodMal 	+ "' " 
		cQueryDXJ +=     " AND DXJ.DXJ_TIPO		= '" + cTipoR + "' "
		cQueryDXJ := ChangeQuery( cQueryDXJ )
		If select("cAliasDXJ") <> 0
			cAliasDXJ->( dbCloseArea() )	
		EndIf
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryDXJ),cAliasDXJ,.T.,.T.)
		   	
		//**Percorrer Todas as Malas da DXJ
		While .Not. (cAliasDXJ)->(Eof())
			aCab   := {}
			aLinha := {}
			//aAdd( aLinha, { 'DXJ_CODUNB', (cAliasDXJ)->DXJ_CODUNB	} )	
		 	aAdd( aLinha, { 'DXJ_DATREC', dDatabase 				} )		
		   	aAdd( aLinha, { 'DXJ_HORREC', Time() 					} )
		   	aAdd( aLinha, { 'DXJ_USRREC', UsrRetName(RetCodUsr()) 	} )				
			aAdd( aCab, aLinha )
				
			cChave 	:= cSafra + (cAliasDXJ)->DXJ_CODIGO + cTipoR
			nIndice	:= 3
				
			dbSelectArea( "DXJ" )
			dbSetOrder( nIndice )
			If DbSeek( xFilial( "DXJ" ) + cChave )
				If Empty(DXJ->DXJ_DATREC) .AND. Empty(DXJ->DXJ_HORREC) .AND. Empty(DXJ->DXJ_USRREC)
					RecLock("DXJ")
						DXJ->DXJ_DATREC:= dDatabase
						DXJ->DXJ_HORREC := Time()
						DXJ->DXJ_USRREC	:= UsrRetName(RetCodUsr())
						
						DXJ->DXJ_DATATU	:= dDatabase
						DXJ->DXJ_HORATU := Time()
												
	               	MsUnLock()
	            EndIf
			EndIf
			(cAliasDXJ)->(dbSkip())
		EndDo
	Else
		lRetorno := .F.
		EndIf
Return (lRetorno)


/*{Protheus.doc} UBAF030CAN
Função de cancelamento da remessa

@author 	ana.olegini
@since 		24/02/2017
@version 	1.0
@param 		cSafra		, character, Informação da rotina UBAA030	- SAFRA
@param 		cCodRem		, character, Informação da rotina UBAA030	- REMESSA
@param 		cTipo		, character, Informação da rotina UBAA030	- TIPO VISUAL/HVI
@param 		cCForCli	, character, Informação da rotina UBAA030	- CLIENTE
@param 		cLForCli	, character, Informação da rotina UBAA030	- LOJA CLIENTE
@param		cStatus		, charecter, Informação da rotina UBAA030	- STATUS DA REMESSA
@return 	lRetorno, Logico, Retorna .T. para verdadeiro ou .F. para falso
*/ 
Function UBAF030CAN(cSafra,cCodRem,cTipo,cCForCli,cLForCli,cStatus)
	Local aDocs   		:= {}
	Local aRegSD2		:= {}
	Local aRegSE1 		:= {}
	Local aRegSE2 		:= {}
	Local aCab			:= {}
	Local aLinha		:= {}
	Local aItens		:= {}	
	Local lRetorno 		:= .T.

	//*Variavel Privada da rotina MATA410 não pode ser modificada
	Private lMsErroAuto := .F.
    Private _cModAtu   	:= cModulo	//*Salvando Modulo Atual
    Private _nModAtu   	:= nModulo  //*Salvando Modulo Atual

	If cStatus $ '3|4|5'
		Help( ,, STR0039,, STR0079 , 1, 0,)	//"Atenção"#"Somente Remessas com status de -Iniciada- ou -Enviadas- podem ser -Canceladas-." 
		Return( .F. )		
	EndIf

	//*"Confirma o cancelamento da NFS?"
	If !IsBLind()
		If !MsgYesNo( STR0071+Alltrim(cCodRem)+STR0072 )	//"Deseja realmente cancelar a Remessa "#"? "
			MsgInfo( STR0006 ) 	//"Operação abortada!"
			Return( .F. )
		EndIf	
	Endif
	
	//**N73 - Malas
	DbSelectArea("N73")	//Malas
	DbSetOrder(1)
	If DbSeek( xFilial("N73") + cSafra + cCodRem  )
		aDocs := {}
	 	While .Not. N73->(Eof()) .AND. N73->N73_CODSAF == cSafra .AND. N73->N73_CODREM == cCodRem 
	 		If .NOT. Empty(N73->N73_DOCREM) .AND. .NOT. Empty(N73->N73_SERREM) .AND. .NOT. Empty(N73->N73_PEDREM)
	 			aAdd( aDocs, { N73->N73_CODMAL, N73->N73_DOCREM, N73->N73_SERREM, N73->N73_PEDREM } )
			EndIf 
			dbSkip()
		EndDo
	EndIf
	
	nModulo := 5
	cModulo := "FAT"
	IF lRetorno .AND. cStatus <> '1' 
		BEGIN TRANSACTION
			If IsBLind() .OR. MsgYesNo( STR0073, STR0057) 	//"Deseja realmente excluir o Documento Fiscal da Remessa?"AJUDA						
				dbSelectArea('SF2')
				dbSetOrder(1)
				If dbSeek(xFilial('SF2')+aDocs[1][2]+aDocs[1][3])
					If !MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2,'MATA460') // Validação na exclusão da Nota Fiscal
						DisarmTransaction()
						Alert( STR0074+Alltrim(aDocs[1][2])+STR0075+Alltrim(aDocs[1][3])+"." )		//#"Não foi possivel excluir o Documento de Saida "" Série: "
						lRetorno := .F.
					Else  
						// Estorna o documento de saída e deixa o pedido de vendas em carteira
						If !IsBLind()
							MsAguarde({||SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,.F.,.F.,.F.,.T.))},STR0008,STR0076) //"Aguarde..."###"Estonarndo o documento de saída..."
						Else
							SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,.F.,.F.,.F.,.T.))
						Endif
						SF2->( MsUnlock() )
						lRetorno := .T.						
					EndIF
				EndIf 
			Else
				lRetorno := .F.
			EndIf
	
		End TRANSACTION	
		
		If lRetorno
			DbSelectArea("SC5")
			DbSetOrder(1)
			If DbSeek(xFilial('SC5')+ aDocs[1][4])
				//*----------- CABEÇALHO PEDIDO DE VENDA	- 	SC5
			    aAdd( aCab, {"C5_NUM"     		, SC5->C5_NUM   	, Nil } )
				aAdd( aCab, {"C5_TIPO"          , SC5->C5_TIPO     	, Nil } )
			    aAdd( aCab, {"C5_CLIENTE"       , SC5->C5_CLIENTE   , Nil } )
			    aAdd( aCab, {"C5_LOJACLI"       , SC5->C5_LOJACLI   , Nil } )
			    aAdd( aCab, {"C5_CLIENT"    	, SC5->C5_CLIENT    , Nil } )
				aAdd( aCab, {"C5_LOJAENT"   	, SC5->C5_LOJAENT   , Nil } )
				aAdd( aCab, {"C5_CONDPAG" 		, SC5->C5_CONDPAG   , Nil } )
				aadd( aCab, {"C5_EMISSAO"		, SC5->C5_EMISSAO	, Nil } )
				aadd( aCab, {"C5_TPFRETE"	 	, SC5->C5_TPFRETE	, Nil } )	                                                                                   
				aAdd( aCab, {"C5_TIPLIB" 		, SC5->C5_TIPLIB	, Nil } )	
				aAdd( aCab, {"C5_LIBEROK"		, SC5->C5_LIBEROK	, Nil } )	
				aAdd( aCab, {"C5_ESPECI1" 		, SC5->C5_ESPECI1	, Nil } )	
				aAdd( aCab, {"C5_ORIGEM"		, SC5->C5_ORIGEM	, Nil } )							
							
				DbSelectArea("SC6")
				DbSetOrder(1)	//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
				If DbSeek(xFilial('SC6')+ aDocs[1][4])
					While .Not. SC6->(Eof()) .AND. xFilial('SC6') == SC5->C5_FILIAL .AND. SC6->C6_NUM == SC5->C5_NUM
						aLinha := {}	                        
						aAdd( aLinha, { "C6_ITEM"       , SC6->C6_ITEM     	, Nil } )
						aAdd( aLinha, { "C6_PRODUTO"    , SC6->C6_PRODUTO   , Nil } )
						aAdd( aLinha, { "C6_UM"			, SC6->C6_UM		, Nil } )     
						aAdd( aLinha, { "C6_TES"        , SC6->C6_TES       , Nil } )
						aAdd( aLinha, { "C6_QTDVEN"     , SC6->C6_QTDVEN    , Nil } )
						aAdd( aLinha, { "C6_QTDLIB"     , SC6->C6_QTDLIB    , Nil } )
						aAdd( aLinha, { "C6_PRCVEN"     , SC6->C6_PRCVEN    , Nil } )
						aAdd( aLinha, { "C6_VALOR"      , SC6->C6_VALOR     , Nil } )
						aAdd( aLinha, { "C6_LOCAL"      , SC6->C6_LOCAL     , Nil } )
						aAdd( aLinha, { "C6_ENTREG"     , SC6->C6_ENTREG    , Nil } )
						aAdd( aItens, aLinha )	 							
						dbSkip()
					EndDo
					MSExecAuto({ | a, b, c | Mata410( a, b, c ) }, aCab, aItens, 5 )
					//*RETORNO DE ERROS DO EXECAUTO
					If lMsErroAuto
						MostraErro()
						RollBackSX8()
						Return(.F.)
					EndIF	//lMsErroAuto
				EndIf	//SC6
			EndIf	//SC5				
		EndIf	//lRetorno
	EndIF
	
	nModulo := _nModAtu
	cModulo := _cModAtu			

	If lRetorno
		If cStatus <> "1"
			DbSelectArea("SF2")
			DbSetOrder(1)
			If Dbseek(xFilial('SF2')+aDocs[1][2]+aDocs[1][3])
				lRetorno := .F.
				Help( ,, STR0039,, STR0077 , 1, 0,)	//"Atenção"//"Não foi possivel cancelar! Documento de Saída não pode ser excluído. Favor gerar devolução."
			Else 
				DbSelectArea("SC5")
				DbSetOrder(1)
				If DbSeek(xFilial('SC5')+ aDocs[1][4])	
					lRetorno := .F.
					Help( ,, STR0039,, STR0078 , 1, 0,) //"Não foi possivel cancelar! Pedido de Venda não pode ser excluído."			
				EndIf 		
			EndIf 
		EndIf
		 
		If lRetorno		
			DbSelectArea("DXJ")
		
			//**N73 - Malas
			DbSelectArea("N73")	//Malas
			N73->(DbSetOrder(1))
			If DbSeek( xFilial("N73") + cSafra + cCodRem  )
				While .Not. N73->(Eof()) .AND. N73->N73_CODSAF == cSafra .AND. N73->N73_CODREM == cCodRem 	   			
		   			If cStatus <> "1"
			   			If RecLock('N73',.f.)	
			  				//*Deve ser atualizado os campos de data de envio caso nao foi recebido 
			   				N73->N73_DATENV	:= CToD("  /  /    ")
			   				N73->N73_HORENV	:= ""
			   				N73->N73_USRENV	:= ""			   				
							N73->N73_DOCREM := "" 
							N73->N73_SERREM := "" 
							//N73->N73_PEDREM := "" 
							N73->(MsUnlock())
														
							DXJ->(DbSetOrder(1)) // DXJ_FILIAL+DXJ_CODIGO+DXJ_TIPO
							If DXJ->(DbSeek(FWxFilial("DXJ")+N73->N73_CODMAL+N73->N73_TIPO))
								If RecLock("DXJ", .F.)
									DXJ->DXJ_DATATU	:= dDatabase
									DXJ->DXJ_HORATU := Time()
									DXJ->(MsUnlock())
								EndIf									
							EndIf
														
							lContinua := .T.
						EndIf
					Else //Deleta
							lContinua := .T.
					EndIf 
		   			N73->(DbSkip())
				EndDo 	
				If lContinua
					DbSelectArea("N72")	//Malas
			   		DbSetOrder(1)	//N73_FILIAL+N73_DOCREM+N73_SERREM+N73_PEDREM  
			   		If DbSeek( xFilial("N72") + cSafra + cCodRem )
						If RecLock('N72',.f.)
							// Caso o tipo de classificação da mala seja Visual e a mesma foi enviada para análise
							If N72->N72_TIPO == "1" .AND. N72->N72_STATUS == "2"
								// Informa a data e hora de ataulização no envio da remessa para análise
								// para excluir a remessa no aplicativo do Beneficiamento								
								N72->N72_DATATU := dDatabase
								N72->N72_HORATU := Time()
							EndIf
						
							//*Atualiza status para Cancelado
				   			N72->N72_STATUS	:= "5"	//Cancelado
				   			N72->(MsUnlock())
						EndIf	//Fim recklock
					EndIf 	//Fim Remessa
				EndIf	//Fim lContinua  
			EndIf	//Fim Malas
		EndIf	//lRetorno
	EndIf 
	
Return(lRetorno)

/*/{Protheus.doc} ValidMrk
Valida a marcação dos dados na markbrowse.
@author carlos.augusto
@since 18/04/2017
/*/
Function UBAF030EST()
	Local aArea     := GetArea()
	Local oDlg	    := Nil
	Local oFwLayer  := Nil
	Local oPnDown   := Nil
	Local oSize     := Nil
	Local lRet      := .T.
	Local oBrwMrk 	:= Nil
	Local aButtons  := {}
	Local aCampos 	:= {'N73_FILIAL', 'N73_CODMAL', 'N73_CODREM', 'N73_CODSAF', 'N73_TIPO', 'N73_QTDCLA', 'N73_DATENV', 'N73_HORENV',;
	 					'N73_USRENV', 'N73_DATREC', 'N73_HORREC', 'N73_USRREC', 'N73_PEDREM', 'N73_DOCREM', 'N73_SERREM'}

	AAdd( aButtons, { "REMOVER",{ || RemoveMala(oBrwMrk)}, STR0087 , STR0088 } ) //#"Remover malas da remessa", "Remover mala" 

	If N72->N72_STATUS = "3" .Or. N72->N72_STATUS = "4" //# 3=Entregue; 4=Entregue Parcial

		oSize := FWDefSize():New(.T.)
		oSize:AddObject( "ALL", 100, 100, .T., .T. )    
		oSize:lLateral	:= .F.  // Calculo vertical	
		oSize:Process() //executa os calculos
	
		oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4],;
		STR0082 , , , , , CLR_BLACK, CLR_WHITE, , , .t. ) 
	
		oFwLayer := FwLayer():New()
		oFwLayer:Init( oDlg, .f., .t. )
	
		oFWLayer:AddLine( 'UP', 10, .F. )
		oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
	
		oFWLayer:AddLine( 'DOWN', 90, .F. )
		oFWLayer:AddCollumn( 'ALL' , 100, .T., 'DOWN' )
		oPnDown := TPanel():New( oSize:GetDimension("ALL","LININI"), oSize:GetDimension("ALL","COLINI"),;
				 ,oDlg, , , , , ,oSize:GetDimension("ALL","COLEND"), oSize:GetDimension("ALL","LINEND")/1.12)
	
		oBrwMrk := FWMarkBrowse():NEW()   // Cria o objeto oMark - MarkBrowse
		oBrwMrk:SetDescription( STR0082 ) // Define o titulo do MarkBrowse
		oBrwMrk:SetAlias("N73") 
		oBrwMrk:SetFieldMark("N73_OK")	// Define o campo utilizado para a marcacao
		oBrwMrk:SetOnlyFields(aCampos)			
		oBrwMrk:SetSemaphore(.F.)	// Define se utiliza marcacao exclusiva
		oBrwMrk:SetValid({|| ValidMrk(oBrwMrk)}) //Valida marcacao
		oBrwMrk:SetFilterDefault("@"+FiltraMark())
		oBrwMrk:SetAllMark( { || .F. } )
		
		oBrwMrk:SetMenuDef("")	// Desabilita a opcao de imprimir	    
		oBrwMrk:Activate(oPnDown)	// Ativa o MarkBrowse
		oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar(oDlg,{|| EstorReceb( oBrwMrk ), oDlg:End(), NIL},{||oDlg:End()},,@aButtons) } )
		
	Else
		Help( , , STR0039, , STR0084, 1, 0 ) // Atenção # "Operação não permitida. O status da remessa é diferente de Entregue e Entregue Parcial."
		lRet := .F.
	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} ValidMrk
Valida a marcação dos dados na markbrowse.
@author carlos.augusto
@since 18/04/2017
/*/
Static Function ValidMrk(oBrwMrk)
	Local aArea		:= GetArea()
	Local lRet      := .T.       
	Local cStatus 	:= ""

	cStatus := Posicione("DXJ",3,xFilial("DXJ")+ N73->N73_CODSAF + N73->N73_CODMAL + N73->N73_TIPO,"DXJ_STATUS") 
	If !Empty(cStatus) .And. (cStatus = "2" .Or. ;
	   cStatus = "3" .Or. cStatus = "5" .Or. cStatus = "6") 
	   lRet := .F.
	EndIf

	If !lRet
		Help('' ,1,"UBAF030CMALA", , STR0083 + AGRRETSX3BOX("DXJ_STATUS", cStatus) + ".",1,0)
		//#.Problema: Operacao nao permitida para malas com status. Solucao: Selecione uma mala classificada 
	EndIf

	If lRet .And. !oBrwMrk:IsMark() //Validar somente antes de marcar
		dbSelectArea('DXJ')
		dbSetOrder(1)
		If dbSeek(FwXFilial('DXJ')+N73->N73_CODMAL + N73->N73_TIPO)
			If Empty(DXJ->DXJ_DATREC) .And. ;
			   Empty(DXJ->DXJ_HORREC) .And. ;
			   Empty(DXJ->DXJ_USRREC) 
				Help( , , STR0039, , STR0089, 1, 0 ) // Atenção # "Já foi realizado o cancelamento de recebimento desta mala."
				lRet := .F.
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} FiltraMark
@author carlos.augusto
@since 18/04/2017
@version undefined
@type function
/*/
Static Function FiltraMark()
	Local cQuery := ""
	
	cQuery := "   D_E_L_E_T_ = ' ' " +;
			  "   AND N73_FILIAL = '" + FwXFilial("N73") + "' " +;
			  "   AND N73_CODSAF = '" + N72->N72_SAFRA + "' " +;
			  "   AND N73_CODREM = '" + N72->N72_CODREM + "' " +;
			  "   AND N73_TIPO   = '" + N72->N72_TIPO + "' "

Return cQuery

/*/{Protheus.doc} EstorReceb
//TODO Descrição auto-gerada.
@author carlos.augusto
@since 20/04/2017
@version undefined
@param oBrwMrk
@type function
/*/
Static Function EstorReceb(oBrwMrk)
	Local nQtdEstorn := 0
	Local nQtdTotal  := 0
	Local aArea 	 := GetArea()
	Local lRet 		 := .T.
	Local oModel
	Local oAuxN73
	Local nLinha  	 := 1
    Local oStruN72 
    Local nQtdNRec	 := 0
    
    Begin Transaction
      
		oModel 	 := FWLoadModel( 'UBAA030' )
		oModel:SetOnDemand( .T. )  
		oModel:SetOperation(4)
	    oStruN72 := oModel:GetModel("N72UBAA030")
	    
		If(oModel:Activate())
	                                                                   
			oAuxN73 := oModel:GetModel( 'N73UBAA030' )
	        
	        DbSelectArea("N73")
			N73->(DbSetOrder(1)) // N73_FILIAL+N73_CODSAF+N73_CODREM+N73_CODMAL
			If N73->(DbSeek(FwXFilial("N73")+oStruN72:GetValue("N72_SAFRA")+oStruN72:GetValue("N72_CODREM")))
				While .Not. N73->(Eof()) .AND. N73->(N73_FILIAL+N73_CODSAF+N73_CODREM) == FwXFilial("N73")+oStruN72:GetValue("N72_SAFRA")+oStruN72:GetValue("N72_CODREM")
					nQtdTotal++
					
					If Empty(N73->N73_DATREC)
						nQtdNRec++		
					EndIf
									
					If oBrwMrk:IsMark()
						nQtdNRec++
						nQtdEstorn++
						oAuxN73:GoLine(nLinha)
						oModel:SetValue( 'N73UBAA030', "N73_USRREC", "")
						oModel:SetValue( 'N73UBAA030', "N73_DATREC", CToD("  /  /    "))
						oModel:SetValue( 'N73UBAA030', "N73_HORREC", "")
						
						ResetMala(.F.)						
					EndIf
					
					N73->(DbSkip())
					nLinha++
				EndDo
			EndIf
		EndIf
	
		If nQtdTotal == nQtdNRec
			If oStruN72:GetValue("N72_TIPO") == "1" // Visual
				oStruN72:SetValue("N72_DATATU", dDatabase)
				oStruN72:SetValue("N72_HORATU", Time())
			EndIf
		
			oStruN72:SetValue("N72_STATUS", "2")
			oStruN72:SetValue("N72_DATENV", CToD("  /  /    "))
			oStruN72:SetValue("N72_HORENV", "")
		ElseIf nQtdEstorn > 0
			If oStruN72:GetValue("N72_TIPO") == "1" // Visual
				oStruN72:SetValue("N72_DATATU", dDatabase)
				oStruN72:SetValue("N72_HORATU", Time())
			EndIf
		
			oStruN72:SetValue("N72_STATUS", "4") //Entregue Parcial						
		EndIf
		If ( lRet := oModel:VldData() )
			lRet := oModel:CommitData()
		EndIf
		
	End Transaction
	
	RestArea(aArea)
	oBrwMrk:Refresh()
	oBrwMrk:GoTop()
Return lRet


/*/{Protheus.doc} ResetMala
//TODO Descrição auto-gerada.
@author carlos.augusto
@since 24/04/2017
@version undefined
@param oBrwMrk
@type function
/*/
Static Function ResetMala(lExclusao)
	Local lRet := .T.
	Local oModelDXJ
    Default lExclusao := .T. //Se é exclusao da mala na remessa
    Private cUserBenf	:= A655GETUNB( )
     
	oModelDXJ := FWLoadModel( 'AGRA630' ) 
	oModelDXJ:SetOnDemand( .T. )  
	oModelDXJ:SetOperation(4)

	dbSelectArea('DXJ')
	dbSetOrder(1)
	If MsSeek(FwXFilial('DXJ')+N73->N73_CODMAL+N73->N73_TIPO) //Filial+Codigo+Tipo (1 = Visual, 2 = HVI)
	
		If(oModelDXJ:Activate())
		
			If lExclusao
				oModelDXJ:SetValue( 'MdFieldDXJ', "DXJ_DATENV", CToD("  /  /    "))
				oModelDXJ:SetValue( 'MdFieldDXJ', "DXJ_HORENV", "")
				oModelDXJ:SetValue( 'MdFieldDXJ', "DXJ_USRENV", "")
			EndIf
			
			oModelDXJ:SetValue( 'MdFieldDXJ', "DXJ_DATREC", CToD("  /  /    "))
			oModelDXJ:SetValue( 'MdFieldDXJ', "DXJ_HORREC", "")
			oModelDXJ:SetValue( 'MdFieldDXJ', "DXJ_USRREC", "")
						
			oModelDXJ:SetValue('MdFieldDXJ', "DXJ_DATATU", dDatabase)
			oModelDXJ:SetValue('MdFieldDXJ', "DXJ_HORATU", Time())			
		
			If ( lRet := oModelDXJ:VldData() )
				lRet := oModelDXJ:CommitData()
			EndIf
			oModelDXJ:DeActivate()
		EndIf
	EndIf



Return lRet


/*/{Protheus.doc} RemoveMala
@author carlos.augusto
@since 20/04/2017
@version undefined
@param oBrwMrk
@type function
/*/
Static Function RemoveMala(oBrwMrk)
	Local aArea := GetArea()
	Local lRet  := .T.
	
	If !AGRIsSelec("N73", oBrwMrk)
		Help(,,STR0039,,STR0085, 1, 0) //"ATENCAO"###"Nenhuma mala selecionada para ser removida da remessa" 
		lRet := .F.
	EndIf
	
	If lRet .And. ApMsgYesNo(STR0086) //#"Deseja remover as malas selecionadas da remessa?"
		//Limpar dados de recebimento da DXJ
		ResetMala(.T.)
		Begin Transaction
			N73->(dbGoTop())
			While .Not. N73->(Eof())
				If oBrwMrk:IsMark()
					If RecLock('N73',.F.)
						dbDelete()
						MsUnlock()
					EndIf
				EndIf
				N73->(dbSkip())
			EndDo
		End Transaction
	EndIf
	
	oBrwMrk:Refresh()
	oBrwMrk:GoTop()
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} UBABLIND
//Chamado via Automação para simular a tela de recebimento
@author felipe.mendes
@since 20/04/2017
@version undefined
@param oBrwMrk
@type function
/*/
Function UBABLIND(cCodBar) 
	Private dData := dDataBase
	Private cHora := Time()

	UBAF030OK(cCodBar)
Return 

