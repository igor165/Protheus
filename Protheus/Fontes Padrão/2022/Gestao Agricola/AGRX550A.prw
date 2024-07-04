#INCLUDE 'TOTVS.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGRX550.CH"

#DEFINE _CRLF CHR(13)+CHR(10)

Static __oOK	   		:= LoadBitmap(GetResources(),'LBOK')
Static __oNo     		:= LoadBitmap(GetResources(),'LBNO')
Static __lMarcAllE	:= .T.
Static __lMarcAllD	:= .T.
Static __cAnaCred	:= SuperGetMv('MV_AGRB003', , .F.) // Parametro de utilização de análise de crédito


/*/{Protheus.doc} AGRX550AVF
//Funcao que exibe tela para vincular fardos no Pre-Romaneio
@author carlos.augusto
@since 16/03/2018
@version undefined
@type function
/*/
Function AGRX550AVF()

	Local oSize2 	        := FWDefSize():New(.F.)
	Local oSize3 	        := FWDefSize():New(.F.)
	Local oSize4 	        := FWDefSize():New(.F.)
	Local oDlg		        := Nil
	Local oFWLayer	    	:= Nil
	Local oBtBarEsq	    	:= Nil
	Local oBtBarDir	    	:= Nil
	Local aCoors	       	:= FWGetDialogSize( oMainWnd )
	Local aCombo 	       	:= {}
	Local cChavEsq	   		:= Space(10)
	Local cChavDir	   		:= Space(10)
	Local cPesqEsq 	   		:= Space(TamSX3("DXI_ETIQ")[1])
	Local cPesqDir 	   		:= cPesqEsq
	Local nOpcA 	       	:= 0
	Local oModel			:= FwModelActive()
	Local oMldN9E 			:= oModel:GetModel('AGRA550_N9E')
	
	Private _aItsEsqd		:= {}
	Private _aItsDirt		:= {}
	Private _nPesoSel		   	:= 0
	Private _nQtdeSel		   	:= 0 //quantidade de fardos
	Private _oBrwEsqd
	Private _oBrwDirt
	Private _lInstEmb := .F. //Indica que os fardos sao da instrucao de embarque

	__lMarcAllD 		:= .T. //marca tudo painel direito - varivel static
	__lMarcAllE 		:= .T. //marca tudo painel esquerdo - varivel static

	If Empty(oMldN9E:GetValue( "N9E_CODINE" ))
		//A Instrução de Embarque não foi selecionada. Favor selecionar uma Instrução de Embarque em Itens da Autorização de Carregamento.
		Help('' ,1,".AGRX54000001.", , ,1,0)
		Return .F.
	EndIf

	AADD(aCombo, STR0036 ) //"Fardo"
	AADD(aCombo, STR0022 ) //"Etiqueta"
	AADD(aCombo, STR0021 ) //"Bloco"

	//----- TELA PARA SELECIONAR FARDOS
	//- Coordenadas da area total da Dialog
	oSize:= FWDefSize():New(.T.)
	oSize:AddObject("DLG",100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.
	oSize:aMargins := {0,0,0,0}
	oSize:Process()

	DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4];
	TITLE STR0037 OF oMainWnd PIXEL //"Vínculo de Fardos na Autorização de Embarque"

	oPnl1:= tPanel():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],,oDlg,,,,,,oSize:aPosObj[1,4],oSize:aPosObj[1,3])
	//---------------------------
	// Cria instancia do fwlayer
	//---------------------------
	oFWLayer := FWLayer():New()
	oFWLayer:init( oPnl1, .F. )

	oFWLayer:AddCollumn( 'ESQ' , 45, .F.)
	oFWLayer:AddCollumn( 'MEIO', 10, .F.)
	oFWLayer:AddCollumn( 'DIR' , 45, .F.)

	//Carrega os itens na Grid de fardos já vinculados
	_aItsDirt := LoadFarDir()
	_aItsEsqd := LoadFardos()

	oFWLayer:addWindow( "ESQ" , "Wnd1", IIF(_lInstEmb,STR0029 ,STR0030), 90, .F., .T.) //"Fardos da Instrução de Embarque" ou "Fardos Autorizados" 
	oFWLayer:addWindow( "DIR" , "Wnd2", STR0031, 90, .F., .T.) //"Fardos Selecionados para o Pré-Romaneio"   

	oPnl2 := oFWLayer:getWinPanel( "ESQ", "Wnd1")
	oPnl3 := oFWLayer:GetColPanel( 'MEIO')
	oPnl4 := oFWLayer:getWinPanel( "DIR", "Wnd2")

	oSize4:AddObject("PNL4",100,100,.T.,.T.)
	oSize4:SetWindowSize({0,0,oPnl4:NHEIGHT,oPnl4:NWIDTH})
	oSize4:lProp    := .T.
	oSize4:aMargins := {0,0,1,0}
	oSize4:Process()

	//----------------------
	// Cria barra de botoes
	//----------------------
	oBtBarDir := TBar():New( oPnl4,0,0,.T.,,,,.F. )
	@ 0, 0 COMBOBOX cChavDir ITEMS aCombo SIZE 40,07 PIXEL OF oBtBarDir
	@ 0, 0 MSGET cPesqDir SIZE 100,10 PIXEL OF oBtBarDir PICTURE "@x"
	TButton():New(0,0,STR0018,oBtBarDir,{|| Pesquisa(cChavDir,Alltrim(cPesqDir),@_oBrwDirt)},Len(STR0007)*4,10,,,,.T.,,) //"Pesquisa"###'Pesquisa'



	_oBrwDirt := TCBrowse():New( oSize4:aPosObj[1,1], oSize4:aPosObj[1,2], oSize4:aPosObj[1,3], oSize4:aPosObj[1,4], , , , oPnl4, , , , {|| }, {|| }, , , , , , , .f., , .t., , .f., , , )
	_oBrwDirt:AddColumn( TCColumn():New(""	 , { || IIf( _aItsDirt[_oBrwDirt:nAt,1] == "1", __oOK, __oNo  ) },,,,"CENTER",010,.t.,.t.,,,,.f., ) )

	_oBrwDirt:AddColumn( TCColumn():New(STR0019 , { || _aItsDirt[_oBrwDirt:nAt,2] }									, , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Filial"
	_oBrwDirt:AddColumn( TCColumn():New(STR0020 , { || _aItsDirt[_oBrwDirt:nAt,3] }									, , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Safra"
	_oBrwDirt:AddColumn( TCColumn():New(STR0021 , { || _aItsDirt[_oBrwDirt:nAt,4] }									, , , , "LEFT" , 025, .f., .t., , , , .f., ) ) //"Bloco"
	_oBrwDirt:AddColumn( TCColumn():New(STR0022 , { || _aItsDirt[_oBrwDirt:nAt,5] }									, , , , "LEFT" , 060, .f., .t., , , , .f., ) ) //"Etiqueta"
	_oBrwDirt:AddColumn( TCColumn():New(STR0023 , { || _aItsDirt[_oBrwDirt:nAt,6] }									, , , , "LEFT" , 025, .f., .t., , , , .f., ) ) //"Codigo"
	_oBrwDirt:AddColumn( TCColumn():New(STR0024 , { || Transform( _aItsDirt[_oBrwDirt:nAt,7], X3PICTURE("N9D_PESFIM")  ) }	, , , , "RIGHT", 035, .f., .t., , , , .f., ) ) //"Peso Liquido"
	_oBrwDirt:AddColumn( TCColumn():New(STR0025 , { || _aItsDirt[_oBrwDirt:nAt,8] }									, , , , "LEFT" , 110, .f., .t., , , , .f., ) ) //"Instrucao de Embarque"
	_oBrwDirt:AddColumn( TCColumn():New(STR0026 , { || _aItsDirt[_oBrwDirt:nAt,9] }									, , , , "LEFT" , 050, .f., .t., , , , .f., ) ) //"Contrato"
	_oBrwDirt:AddColumn( TCColumn():New(STR0027 , { || _aItsDirt[_oBrwDirt:nAt,10] }								, , , , "LEFT" , 050, .f., .t., , , , .f., ) ) //"Id.Entrega"
	_oBrwDirt:AddColumn( TCColumn():New(STR0028 , { || _aItsDirt[_oBrwDirt:nAt,11] }								, , , , "LEFT" , 050, .f., .t., , , , .f., ) ) //"Id.Regra" 

	_oBrwDirt:SetArray( _aItsDirt )
	_oBrwDirt:bLDblClick 		:= {|| MarcaUm( _oBrwDirt, _aItsDirt, _oBrwDirt:nAt, .F. )}
	_oBrwDirt:bHeaderClick 	:= {|| MarcaTudo( _oBrwDirt, _aItsDirt, _oBrwDirt:nAt, @__lMarcAllD, .F. ) }
	_oBrwDirt:Align := CONTROL_ALIGN_ALLCLIENT
	_oBrwDirt:Refresh(.T.)

	//-----------------------------------
	// Cria Botão marca/desmarca na Grid
	//-----------------------------------
	//--------------------------
	// Dimensionamento da area
	//--------------------------
	oSize2:AddObject("PNL2",100,100,.T.,.T.)
	oSize2:SetWindowSize({0,0,oPnl2:NHEIGHT,oPnl2:NWIDTH})
	oSize2:lProp 	:= .T.
	oSize2:aMargins := {0,0,1,0}
	oSize2:Process()
	//----------------------
	// Cria barra de botoes
	//----------------------
	oBtBarEsq := TBar():New( oPnl2,0,0,.T.,,,,.F. )
	@ 0, 0 COMBOBOX cChavEsq ITEMS aCombo SIZE 40,07 PIXEL OF oBtBarEsq
	@ 0, 0 MSGET cPesqEsq SIZE 100,10 PIXEL OF oBtBarEsq PICTURE "@x"
	TButton():New(0,0, STR0018 ,oBtBarEsq,{|| Pesquisa(cChavEsq,Alltrim(cPesqEsq),@_oBrwEsqd)},Len(STR0007)*4,10,,,,.T.,,) //"Pesquisa"###'Pesquisa'
	

	_oBrwEsqd := TCBrowse():New( oSize2:aPosObj[1,1], oSize2:aPosObj[1,2], oSize2:aPosObj[1,3], oSize2:aPosObj[1,4], , , , oPnl2, , , , {|| }, {|| }, , , , , , , .f., , .t., , .f., , , )
	_oBrwEsqd:AddColumn( TCColumn():New(""	  ,  { || IIf( _aItsEsqd[_oBrwEsqd:nAt,1] == "1", __oOK, __oNo ) }       , , , , "CENTER", 010,.t.,.t.,,,,.f., ) )
	_oBrwEsqd:AddColumn( TCColumn():New(STR0019, { || _aItsEsqd[_oBrwEsqd:nAt,2] }									  , , , , "LEFT"  , 030, .f., .t., , , , .f., ) ) //"Filial"
	_oBrwEsqd:AddColumn( TCColumn():New(STR0020, { || _aItsEsqd[_oBrwEsqd:nAt,3] }									  , , , , "LEFT"  , 030, .f., .t., , , , .f., ) ) //"Safra"
	_oBrwEsqd:AddColumn( TCColumn():New(STR0021, { || _aItsEsqd[_oBrwEsqd:nAt,4] }									  , , , , "LEFT"  , 025, .f., .t., , , , .f., ) ) //"Bloco"
	_oBrwEsqd:AddColumn( TCColumn():New(STR0022, { || _aItsEsqd[_oBrwEsqd:nAt,5] }									  , , , , "LEFT"  , 060, .f., .t., , , , .f., ) ) //"Etiqueta"
	_oBrwEsqd:AddColumn( TCColumn():New(STR0023, { || _aItsEsqd[_oBrwEsqd:nAt,6] }									  , , , , "LEFT"  , 025, .f., .t., , , , .f., ) ) //"Codigo"
	_oBrwEsqd:AddColumn( TCColumn():New(STR0024, { || Transform( _aItsEsqd[_oBrwEsqd:nAt,7],  X3PICTURE("N9D_PESFIM") ) } , , , , "RIGHT" , 035, .f., .t., , , , .f., ) ) //"Peso Liquido"
	_oBrwEsqd:AddColumn( TCColumn():New(STR0025, { || _aItsEsqd[_oBrwEsqd:nAt,8] }									  , , , , "LEFT"  , 110, .f., .t., , , , .f., ) ) //Instrucao de embarque
	_oBrwEsqd:AddColumn( TCColumn():New(STR0026, { || _aItsEsqd[_oBrwEsqd:nAt,9] }								  , , , , "LEFT"  , 050, .f., .t., , , , .f., ) ) //"Contrato"
	_oBrwEsqd:AddColumn( TCColumn():New(STR0027, { || _aItsEsqd[_oBrwEsqd:nAt,10] }							  , , , , "LEFT"  , 050, .f., .t., , , , .f., ) ) //"Id.Entrega"
	_oBrwEsqd:AddColumn( TCColumn():New(STR0028, { || _aItsEsqd[_oBrwEsqd:nAt,11] }							  , , , , "LEFT"  , 050, .f., .t., , , , .f., ) ) //"Id.Regra"
	

	_oBrwEsqd:SetArray( _aItsEsqd )
	_oBrwEsqd:bLDblClick 		:= {|| MarcaUm( _oBrwEsqd, _aItsEsqd, _oBrwEsqd:nAt, .F. )}
	_oBrwEsqd:bHeaderClick 	:= {|| MarcaTudo( _oBrwEsqd, _aItsEsqd, _oBrwEsqd:nAt, @__lMarcAllE, .F. ) }
	_oBrwEsqd:Align := CONTROL_ALIGN_ALLCLIENT
	_oBrwEsqd:Refresh(.T.)

	//-----------------------------------
	// Cria Botão marca/desmarca na Grid
	//-----------------------------------
	//--------------------------
	// Dimensionamento da area
	//--------------------------
	oSize3:AddObject("PNL3",100,100,.T.,.T.)
	oSize3:SetWindowSize({0,0,oPnl3:NHEIGHT,oPnl3:NWIDTH})
	oSize3:lProp 	:= .T.
	oSize3:aMargins := {0,0,0,0}
	oSize3:Process()

	//----------------
	// Define a fonte
	//----------------
	oFont := TFont():New('Arial',,-12,.T.)

	//-----------------------------------------------------------
	// Cria botoes vincular ou desvincular os fardos do romaneio
	//-----------------------------------------------------------
	TButton():New( (oSize3:APOSOBJ[1][3]/2)-44, oSize3:APOSOBJ[1][1]+5, ">>" , oPnl3, {|| MovFardos( ">", @_oBrwEsqd, @_oBrwDirt ) }, oSize3:APOSOBJ[1][4]-10, 15, , /**oFont*/, , .t., , STR0038 ) //"Vincular Marcados"
	TButton():New( (oSize3:APOSOBJ[1][3]/2)-28, oSize3:APOSOBJ[1][1]+5, "<<" , oPnl3, {|| MovFardos( "<", @_oBrwEsqd, @_oBrwDirt ) }, oSize3:APOSOBJ[1][4]-10, 15, , /**oFont*/, , .t., , STR0039 ) //"Desvincular Marcados"

	_nQtdeSel := Len(_aItsDirt)

	//---------------------------------------------------------------------------------------------------
	// Apresenta calculos de peso total dos Fardos selecionados e quantidade de itens do romaneio na tela
	//---------------------------------------------------------------------------------------------------
	oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)-5,oSize3:APOSOBJ[1][1]+5,{|| Transform( STR0032 , "@!" )},oPnl3,,oFont,,; //"Quantidade"
	,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)
	oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)+5,oSize3:APOSOBJ[1][1]+5,{||  Alltrim(Transform( _nQtdeSel, '@E 99999') )},oPnl3,,oFont,,;
	,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)
	oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)+15,oSize3:APOSOBJ[1][1]+5,{|| Transform( STR0033, "@!" )},oPnl3,,oFont,,; //"Peso Total"
	,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)
	oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)+25,oSize3:APOSOBJ[1][1]+5,{||Alltrim(Transform( _nPesoSel, PesqPict('DXL','DXL_PSLIQU')) )},oPnl3,,oFont,,;
	,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)
	
	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| nOpcA:= 1, ExecGrav(oDlg, @_aItsDirt)},{|| nOpcA:= 2, ExecCancel(oDlg) })

Return 


/*/{Protheus.doc} LoadFarDir
//Carrega os fardos ja selecionados para Autorizacao de Carregamento
@author carlos.augusto
@since 23/02/2018
@version undefined
@param oBrw, object, descricao
@type function
/*/
Static Function LoadFarDir(oBrw)
	Local aArea	    := GetArea()
	Local aColsLoad	:= {}
	Local nCont	    := 0	
	Local oModel	:= FwModelActive()
	Local oMldN9D 	:= oModel:GetModel('AGRA550_N9D')
	Local oMldN9E 	:= oModel:GetModel('AGRA550_N9E')
	Local nX
	
	//Variavel privada. Resetar valor antes da busca dos fardos para somar corretamente.
	//Representa aquele peso que fica no meio dos grids
	_nPesoSel     := 0
	
	//Esta buscando os fardos que estao no modelo, em backgroud para posteriormente exibir na tela, atraves do array (lado direito)
	For nX := 1 to oMldN9D:Length()
		oMldN9D:GoLine( nX )
		If .Not. oMldN9D:IsDeleted() .And. .Not. Empty(oMldN9D:GetValue( "N9D_CODROM" )) .And. (oMldN9E:GetValue( "N9E_SEQUEN" ) == oMldN9D:GetValue( "N9D_SEQUEN" ))
			nCont++
			aAdd( aColsLoad, { "2", oMldN9D:GetValue( "N9D_FILORG" ), oMldN9D:GetValue( "N9D_SAFRA" ),;
			 					    oMldN9D:GetValue( "N9D_BLOCO" ),  oMldN9D:GetValue( "N9D_FARDO" ),   oMldN9D:GetValue( "N9D_CODFAR" ),;
			 					    oMldN9D:GetValue( "N9D_PESFIM" ), oMldN9D:GetValue( "N9D_CODINE" ),;
			 					    oMldN9D:GetValue( "N9D_CODCTR" ),  oMldN9D:GetValue( "N9D_ITEETG" ),   oMldN9D:GetValue( "N9D_ITEREF" )})
	
	
			_nPesoSel += oMldN9D:GetValue( "N9D_PESFIM" )
		EndIf
	Next nX

	RestArea(aArea)
Return(aColsLoad)


/*/{Protheus.doc} LoadFardos
//Carrega o grid esquerdo com fardos que podem ser adicionados
@author carlos.augusto
@since 23/02/2018
@version undefined

@type function
/*/
Static Function LoadFardos()
	Local aArea	    := GetArea()
	Local oModel	:= FwModelActive()
	Local oMldN9E 	:= oModel:GetModel('AGRA550_N9E')
	Local oMldN9D 	:= oModel:GetModel('AGRA550_N9D')
	Local aColsLoad	:= {}
	Local cAliasQry := ""
	Local cQry 		:= ""
	Local nCont	    := 0
	Local nX	
	Local lNotIn	:= .F.
	Local lModelEpt	:= .T.
	Local cSafraIE  := ""
	
	cAliasQry := GetNextAlias()
	
	//Obtem safra da IE
	DbSelectArea("N7Q")
	DbSetOrder(1)
	If N7Q->(DbSeek(FwxFilial("N7Q") + oMldN9E:GetValue( "N9E_CODINE" )))
		cSafraIE	:= N7Q->N7Q_CODSAF
	EndIf

	cQry := "SELECT N9D_FILIAL, N9D_CODINE, N9D_ITEMAC, N9D_SAFRA, N9D_BLOCO, N9D_FARDO, N9D_CODFAR, N9D_PESFIM, N9D_FILORG, "
	cQry += " N9D_CODCTR, N9D_ITEETG, N9D_ITEREF, N9D_LOTECT, N9D_NUMLOT "
	cQry += "FROM " + RetSqlName("N9D") + " N9D "
	cQry += "WHERE N9D.D_E_L_E_T_ = ' ' "
	cQry += " AND  N9D_FILIAL = '" + FwXfilial("N9D") + "' "
	
	cQry += " AND N9D.N9D_SAFRA = '" + cSafraIE + "' " //Safra
	
	cQry += " AND N9D_CODINE = '" + oMldN9E:GetValue( "N9E_CODINE" ) + "' " //Instrucao de embarque
	cQry += " AND N9D_ITEETG = '" + oMldN9E:GetValue( "N9E_ITEM" ) + "' " //Id Entrega
	cQry += " AND N9D_CODCTR = '" + oMldN9E:GetValue( "N9E_CODCTR" ) + "' " //Contrato
	cQry += " AND N9D_ITEREF = '" + oMldN9E:GetValue( "N9E_SEQPRI" ) + "' " //Regra
	cQry += " AND N9D_TIPMOV = '10' " //Autorizacao de Carregamento
	cQry += " AND N9D_STATUS = '2' " //1=Previsto;2=Ativo;3=Inativo

	For nX := 1 to oMldN9D:Length()
		oMldN9D:GoLine(nX)
		If .Not. oMldN9D:IsDeleted()
			If lNotIn
				cQry += ","
			Else
				cQry += " AND N9D_FARDO NOT IN("
				lNotIn := .T.
			EndIf
			cQry += "'"+ oMldN9D:GetValue("N9D_FARDO") +"'"
			If .Not. Empty(oMldN9D:GetValue("N9D_FARDO"))
				lModelEpt := .F.
			EndIf
		EndIf
	Next nX
	
	If lNotIn
		cQry += ")"
	EndIf

	cQry += "ORDER BY N9D_FILORG,N9D_ITEMAC,N9D_BLOCO,N9D_CODFAR "

	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	

	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof()) 

		nCont++
		aAdd( aColsLoad, { "2", (cAliasQry)->N9D_FILORG, (cAliasQry)->N9D_SAFRA, (cAliasQry)->N9D_BLOCO, (cAliasQry)->N9D_FARDO, (cAliasQry)->N9D_CODFAR, (cAliasQry)->N9D_PESFIM, ;
								(cAliasQry)->N9D_CODINE, (cAliasQry)->N9D_CODCTR, (cAliasQry)->N9D_ITEETG, (cAliasQry)->N9D_ITEREF, (cAliasQry)->N9D_LOTECT, (cAliasQry)->N9D_NUMLOT  })

		(cAliasQry)->(DbSkip())
	End
	
	
	If Empty(aColsLoad) .And. lModelEpt //Se lModelEpt estiver true e nao retornar nada, o usuario ja pegou todos os autorizados. Por isso nao exibe nada
		(cAliasQry)->(DbCloseArea())
		cAliasQry := GetNextAlias()
		lNotIn	:= .F.
		cQry := "SELECT N9D_FILIAL, N9D_CODINE, N9D_ITEMAC, N9D_SAFRA, N9D_BLOCO, N9D_FARDO, N9D_CODFAR, N9D_PESFIM, N9D_FILORG, "
		cQry += " N9D_CODCTR, N9D_ITEETG, N9D_ITEREF, N9D_LOTECT, N9D_NUMLOT "
		cQry += "FROM " + RetSqlName("N9D") + " N9D "
		cQry += "WHERE N9D.D_E_L_E_T_ = ' ' "
		cQry += " AND  N9D_FILIAL = '" + FwXfilial("N9D") + "' "
		cQry += " AND N9D.N9D_SAFRA = '" + cSafraIE + "' " //Safra
		cQry += " AND N9D_CODINE = '" + oMldN9E:GetValue( "N9E_CODINE" ) + "' " //Instrucao de embarque
		cQry += " AND N9D_ITEETG = '" + oMldN9E:GetValue( "N9E_ITEM" ) + "' " //Id Entrega
		cQry += " AND N9D_CODCTR = '" + oMldN9E:GetValue( "N9E_CODCTR" ) + "' " //Contrato
		cQry += " AND N9D_ITEREF = '" + oMldN9E:GetValue( "N9E_SEQPRI" ) + "' " //Regra
		cQry += " AND N9D_TIPMOV = '04' " //Instrucao de embarque
		cQry += " AND N9D_STATUS = '2' " //1=Previsto;2=Ativo;3=Inativo
	
		For nX := 1 to oMldN9D:Length()
			oMldN9D:GoLine(nX)
			If .Not. oMldN9D:IsDeleted()
				If lNotIn
					cQry += ","
				Else
					cQry += " AND N9D_FARDO NOT IN("
					lNotIn := .T.
				EndIf
				cQry += "'"+ oMldN9D:GetValue("N9D_FARDO") +"'"
			EndIf
		Next nX
		
		If lNotIn
			cQry += ")"
		EndIf

		//Nao posso mostrar os fardos da IE se esta IE teve algum fardo que ja foi autorizado
		cQry += " AND N9D.N9D_CODINE NOT IN "
		cQry += "(SELECT N9D3.N9D_CODINE FROM "+ RetSqlName("N9D") +" N9D3 WHERE "
		cQry += "  N9D3.N9D_SAFRA = N9D.N9D_SAFRA " //Safra
		cQry += " AND N9D3.N9D_CODINE = '" + oMldN9E:GetValue( "N9E_CODINE" ) + "' " //Instrucao de embarque
		cQry += " AND N9D3.N9D_ITEETG = '" + oMldN9E:GetValue( "N9E_ITEM" ) + "' " //Id Entrega
		cQry += " AND N9D3.N9D_CODCTR = '" + oMldN9E:GetValue( "N9E_CODCTR" ) + "' " //Contrato
		cQry += " AND N9D3.N9D_ITEREF = '" + oMldN9E:GetValue( "N9E_SEQPRI" ) + "' " //Regra
		cQry += " AND N9D3.N9D_TIPMOV = '10' " //Instrucao de embarque
		cQry += " AND N9D3.N9D_STATUS = '2' " //1=Previsto;2=Ativo;3=Inativo
		cQry += " AND N9D3.D_E_L_E_T_ = ' ')  "
	
		cQry += "ORDER BY N9D_FILORG,N9D_ITEMAC,N9D_BLOCO,N9D_CODFAR "
	
		cQry := ChangeQuery( cQry )	
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	
	
		dbSelectArea(cAliasQry)
		dbGoTop()
		While (cAliasQry)->(!Eof()) 
			_lInstEmb := .T.
			nCont++
			aAdd( aColsLoad, { "2", (cAliasQry)->N9D_FILORG, (cAliasQry)->N9D_SAFRA, (cAliasQry)->N9D_BLOCO, (cAliasQry)->N9D_FARDO, (cAliasQry)->N9D_CODFAR, (cAliasQry)->N9D_PESFIM, ;
									(cAliasQry)->N9D_CODINE, (cAliasQry)->N9D_CODCTR, (cAliasQry)->N9D_ITEETG, (cAliasQry)->N9D_ITEREF, (cAliasQry)->N9D_LOTECT, (cAliasQry)->N9D_NUMLOT  })
	
			(cAliasQry)->(DbSkip())
		End
	
	EndIf

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return(aColsLoad)


/**-------------------------------------------------------------------------------------
{Protheus.doc} MarcaUm
Marca/Desmarca Posicionado

@author: 	thiago.rover e janaina.duarte
@since: 	09/11/2017
-------------------------------------------------------------------------------------**/
Static Function MarcaUm( oBrwMrk, aItsMrk, nLinMrk, lDir)
	Local lMarca := .T.

	//Marca caso o fardo não tenha sido embarcado
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


/**-------------------------------------------------------------------------------------
{Protheus.doc} MovFardos
Responsavel pela transferencia dos registros entre os browsers

@author: 	thiago.rover e janaina.duarte
@since: 	08/11/2017
-------------------------------------------------------------------------------------**/
Static Function MovFardos( cSeta, oBrwEsq, oBrwDir )
	Local aItsOrig := {}
	Local aItsDest := {}
	Local nX	   := 0 
	Local lMarc	   := .F.

	If INCLUI .Or. ALTERA
		If cSeta == ">"
			aItsOrig 	:= aClone( _aItsEsqd )
			aItsDest 	:= aClone( _aItsDirt )
		EndIf
		If cSeta == "<"
			aItsOrig 	:= aClone( _aItsDirt )
			aItsDest 	:= aClone( _aItsEsqd )
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

		aItsOrig := ASort( aItsOrig, , , { | x, y | x[2]+x[3]+x[4]+x[5]+x[6] < y[2]+y[3]+y[4]+y[5]+y[6]}) //ordena filial+safra+bloco+etiqueta+codigo
		aItsDest := ASort( aItsDest, , , { | x, y | x[2]+x[3]+x[4]+x[5]+x[6] < y[2]+y[3]+y[4]+y[5]+y[6]}) //ordena filial+codine+safra+bloco+etiqueta+codigo

		If lMarc
			If cSeta == ">"
				_aItsEsqd := aClone( aItsOrig )
				_aItsDirt := aClone( aItsDest )
				__lMarcAllE := .T.
			EndIf

			If cSeta == "<"
				_aItsEsqd := aClone( aItsDest )
				_aItsDirt := aClone( aItsOrig )
				__lMarcAllE := .T.
			EndIf

			oBrwEsq:SetArray( _aItsEsqd )
			oBrwDir:SetArray( _aItsDirt )
			oBrwEsq:GoPosition(1) //para posicionar na primeira linha, quando utiliza a pesquisa a posição é alterada e se der refresh e a posição não mais existir gera erro
			oBrwDir:GoPosition(1)
			oBrwEsq:Refresh()
			oBrwDir:Refresh()

		EndIf
		If !lMarc
			Help( , , STR0010, , STR0034, 1, 0 ) //"Atenção"###"Favor selecionar fardos."
		EndIf

	EndIf

	_nQtdeSel := Len(oBrwDir:AARRAY) // Total de itens do romaneio
	_nPesoSel := 0
	For nX := 1 To len(oBrwDir:AARRAY)
		_nPesoSel += oBrwDir:AARRAY[nX, 7] //Peso Liquido Total de fardos selecionados
	Next nX

	ASize( aItsOrig, 0 )
	ASize( aItsDest, 0 )
	
Return .T.


/**-------------------------------------------------------------------------------------
{Protheus.doc} MarcaAll
Marca/Desmarca Todos

@author: 	thiago.rover e janaina.duarte
@since: 	09/11/2017
-------------------------------------------------------------------------------------**/
Static Function MarcaTudo( oBrwMrk, aItsMrk, nLinMrk, lMark, lDir )
	Local nX	:= 0

	Default lMark := .T.

	For nX := 1 to Len( aItsMrk )                 

		If aItsMrk[ nX, 1 ] $ "1|2"
			aItsMrk[ nX, 1 ] := If(lMark, "1", "2")
		EndIf
	Next nX

	oBrwMrk:Refresh()
	lMark := !lMark
Return( )

/**-------------------------------------------------------------------------------------
{Protheus.doc} MarcaPesq
Marca o item da linha conforme passado por parametro nesta função

@author: 	Claudineia H. Reinert
@since: 	05/12/2017
-------------------------------------------------------------------------------------**/
Static Function MarcaPesq( oBrwMrk, aItsMrk, nLinMrk)
	aItsMrk[ nLinMrk, 1 ] := "1"
Return


/** -------------------------------------------------------------------------------------
{Protheus.doc} Pesquisa
Função de pesquisa de registro no Browse

@author thiago.rover e janaina.duarte
@since 11/11/2017
-------------------------------------------------------------------------------------- **/
Static Function Pesquisa(cChave, cPesquisa, oBrowse)
	Local nX 		:= 0
	Local nPosAc	:= 0

	ASORT(oBrowse:AARRAY,,,{|x,y| x[2]+x[3]+x[4]+x[5]+x[6] < y[2]+y[3]+y[4]+y[5]+y[6]})   //ordena filial+codine+safra+bloco+etiqueta+codigo

	If Alltrim(Upper(cChave)) == Upper(STR0036) //fardos 
		for nX := 1 to len(oBrowse:AARRAY) 
			If oBrowse:AARRAY[nX][6] == cPesquisa 
				If nPosAc = 0 
					nPosAc := nX //seta linha para posicionar
				EndIf
				//realiza a marcação do registro
				MarcaPesq( oBrowse, oBrowse:AARRAY, nX)
			EndIf
		Next
	ElseIf Alltrim(Upper(cChave)) == Upper(STR0022) //Etiqueta
		for nX := 1 to len(oBrowse:AARRAY) 
			If oBrowse:AARRAY[nX][5] == cPesquisa 
				If nPosAc = 0 
					nPosAc := nX //seta linha para posicionar
				EndIf
				//realiza a marcação do registro
				MarcaPesq( oBrowse, oBrowse:AARRAY, nX)
			EndIf
		Next
	ElseIf Alltrim(Upper(cChave)) == Upper(STR0021) //bloco
		for nX := 1 to len(oBrowse:AARRAY) 
			If oBrowse:AARRAY[nX][4] == cPesquisa 
				If nPosAc = 0 
					nPosAc := nX //seta linha para posicionar
				EndIf
				//realiza a marcação do registro
				MarcaPesq( oBrowse, oBrowse:AARRAY, nX)
			EndIf
		Next		  
	EndIf

	If nPosAc > 0
		oBrowse:GoPosition(nPosAc)
	EndIf

Return


/*/{Protheus.doc} ExecCancel
//Cancelar - sem efetivação
@author carlos.augusto
@since 23/02/2018
@version undefined
@param oDlg, object, descricao
@param _aItsDirt, , descricao
@type function
/*/
Static function ExecCancel(oDlg)
	oDlg:End()
Return


/*/{Protheus.doc} ExecGrav
//Ao clicar em Salvar, replicar as alteracoes para o modelo N8Q e atualizar quantidade em N8O
@author carlos.augusto
@since 23/02/2018
@version undefined
@param oDlg, object, descricao
@param _aItsDirt, , descricao
@type function
/*/
Static Function ExecGrav(oDlg, _aItsDirt)
	Local aColsLoad	:= {}
	Local lRet		:= .T.
	Local oModel	:= FwModelActive()
	Local oMldNJJ 	:= oModel:GetModel('AGRA550_NJJ') //Pre Romaneio
	Local oMldN9E 	:= oModel:GetModel('AGRA550_N9E') //Itens do Pre-Romaneio
	Local oMldN9D 	:= oModel:GetModel('AGRA550_N9D') //Fardos do Pre-Romaneio
	Local oMldN8Q 	:= oModel:GetModel('AGRA550_N8Q') //Blocos do Pre-Romaneio
	Local nX, nY, nZ
	Local lDelete	
	Local cIDMov	
	
	//Esta fazendo um looping nos fardos que ja estao no modelo e nao foram mantidos ao salvar
	//Ou seja, vai deletar do modelo.
	//Tambem sera removido (o fardo) do array para facilitar a adicao de elementos posteriormente
	For nX := 1 to oMldN9D:Length()
		oMldN9D:GoLine( nX )
		If .Not. oMldN9D:IsDeleted() .And. (Empty(oMldN9D:GetValue("N9D_FARDO")) .Or. ;//Se a etiqueta esta vazia, eh a primeira linha do modelo
			oMldN9D:GetValue("N9D_SEQUEN")== oMldN9E:GetValue("N9E_SEQUEN"))
			lDelete := .T.
			For nZ := 1 To Len(_aItsDirt)
				If _aItsDirt[nZ] != Nil
					If oMldN9D:GetValue("N9D_FILORG") == _aItsDirt[nZ][2] .And.;
					oMldN9D:GetValue("N9D_SAFRA") == _aItsDirt[nZ][3] .And.;
					oMldN9D:GetValue("N9D_BLOCO") == _aItsDirt[nZ][4] .And.;
					oMldN9D:GetValue("N9D_FARDO")  == _aItsDirt[nZ][5]

						lDelete := .F.
						ADel( _aItsDirt, nZ )
						exit
					EndIf
				EndIf
			Next nZ
			If lDelete //Deleta registros removidos
				oMldN9D:DeleteLine()
			EndIf
		EndIf
	Next nX	

	If Empty(_aItsDirt)
		RollBackSx8()
	EndIf
	//Neste array ficaram somente os novos elementos. Adiciono todos. Exceto posicoes eliminadas =D
	For nY := 1 To Len(_aItsDirt)
		If _aItsDirt[nY] != Nil
			oMldN9D:AddLine()
			oMldN9D:GoLine( nY + (nX-1)) //Comeco a contar a partir da ultima linha do modelo, o modelo existe em background
			oMldN9D:LoadValue("N9D_FILORG", _aItsDirt[nY][2])
			oMldN9D:LoadValue("N9D_CODROM", oMldNJJ:GetValue("NJJ_CODROM"))
			oMldN9D:LoadValue("N9D_SEQUEN", oMldN9E:GetValue("N9E_SEQUEN"))
			oMldN9D:LoadValue("N9D_SAFRA",  _aItsDirt[nY][3])
			oMldN9D:LoadValue("N9D_BLOCO",  _aItsDirt[nY][4])
			oMldN9D:LoadValue("N9D_FARDO",  _aItsDirt[nY][5])
			oMldN9D:LoadValue("N9D_CODFAR", _aItsDirt[nY][6])
			oMldN9D:LoadValue("N9D_PESFIM", _aItsDirt[nY][7])
			oMldN9D:LoadValue("N9D_CODINE", _aItsDirt[nY][8])
			oMldN9D:LoadValue("N9D_CODCTR", _aItsDirt[nY][9])
			oMldN9D:LoadValue("N9D_ITEETG", _aItsDirt[nY][10])
			oMldN9D:LoadValue("N9D_ITEREF", _aItsDirt[nY][11])
			
			//Campos complementares
			oMldN9D:LoadValue("N9D_TIPMOV", '11')
			oMldN9D:LoadValue("N9D_DATA", dDatabase)
			oMldN9D:LoadValue("N9D_STATUS", '1')
			
			//Lote
			oMldN9D:LoadValue("N9D_LOTECT", _aItsDirt[nY][12])
			oMldN9D:LoadValue("N9D_NUMLOT", _aItsDirt[nY][13])
			
			//Chave
			cIDMov := AGRX550AID(_aItsDirt[nY][3], _aItsDirt[nY][5])
			oMldN9D:LoadValue("N9D_IDMOV", cIDMov)
			
		EndIf
	Next nY

	oMldN9E:SetValue("N9E_QTDAGD", _nPesoSel + oMldN8Q:GetValue("N8Q_PSLIQU"))

	If lRet 
		ASize( aColsLoad, 0 )
		oDlg:End()
	EndIf

Return 

/*/{Protheus.doc} AGRX550APRE
//Ao deletar uma linha, desrelacionar os fardos selecionados para o item
@author carlos.augusto
@since 16/03/2018
@version undefined
@param oMldN8O, object, descricao
@param nLine, numeric, descricao
@param cAction, characters, descricao
@param cIDField, characters, descricao
@param xValue, , descricao
@param xCurrentValue, , descricao
@type function
/*/
Function AGRX550APRE(oMldN9E, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local lRet 		:= .T.
	Local oModel	:= FwModelActive()
	Local oMldN9D 	:= oModel:GetModel('AGRA550_N9D') //Fardos da Autorizacao
	Local oMldN8Q 	:= oModel:GetModel('AGRA550_N8Q') //Blocos da Autorizacao
	//Local oMldN9E 	:= oModel:GetModel('AGRA550_N9E') //Autorização de Carregamento
	Local cTpMerAt  := ""
	Local nX
	
	If cAction == "DELETE" .And. .Not. Empty(oMldN9E:GetValue("N9E_CODINE"))
		ApMsgAlert(STR0035) //Ao excluir a linha do Pré-Romaneio, os fardos e blocos deste item são automaticamente desrelacionados."
		If lRet
			For nX := 1 to oMldN9D:Length()
				oMldN9D:GoLine(nX)
				If .Not. oMldN9D:IsDeleted() .And. (oMldN9E:GetValue( "N9E_SEQUEN" ) == oMldN9D:GetValue( "N9D_SEQUEN" ))
					oMldN9D:DeleteLine()
				EndIf
			Next nX
			For nX := 1 to oMldN8Q:Length()
				oMldN8Q:GoLine(nX)
				If .Not. oMldN8Q:IsDeleted() .And. (oMldN9E:GetValue( "N9E_SEQUEN" ) == oMldN8Q:GetValue( "N8Q_SEQUEN" ))
					oMldN8Q:DeleteLine()
				EndIf
			Next nX
		EndIf
	ElseIf cAction == "SETVALUE"

		IF oMldN9E:IsInserted() .OR. oMldN9E:IsUpdated()
			cTpMerAt := Posicione("N7Q",1,xFilial("N7Q")+AllTrim(M->N9E_CODINE),"N7Q_TPMERC")
			
			If __cAnaCred $ "1|2|3" //Parâmetro de análise de crédito: 1 - Interno, 2 - Externo, 3 - Ambos, 4 - Nenhum
				If __cAnaCred = "3" //Ambos
					_lAltIE := .T.
				ElseIf __cAnaCred = cTpMerAt
					_lAltIE := .T.
				EndIf
			Else
				_lAltIE := .F.
			EndIf
		EndIf
	EndIf

Return lRet



/*/{Protheus.doc} AGRX550AID
//Verifica o último registro inserido para a filial, safra e etiqueta
@author carlos.augusto
@since 26/03/2018
@version undefined

@type function
/*/
Function AGRX550AID(cSafra, cEtiqueta)
	Local cIdMovFard := ""
	Local cQry		 := ""
	Local cAliasQry  := ""
	
	cAliasQry := GetNextAlias()
	cQry := " SELECT N9D.N9D_IDMOV "
	cQry += "   FROM " + RetSqlName("N9D") + " N9D "
	cQry += "  WHERE N9D.N9D_FILIAL = '"+ FwXfilial("N9D") +"' "
	cQry += "    AND N9D.N9D_SAFRA  = '"+ cSafra +"' " 
	cQry += "    AND N9D.N9D_FARDO  = '"+ cEtiqueta +"' "
	cQry += "    AND D_E_L_E_T_  = ' ' "
	cQry += "    AND N9D_IDMOV IN (SELECT MAX(N9D2.N9D_IDMOV) "
	cQry += "	                     FROM " + RetSqlName("N9D") + " N9D2 "
	cQry += "	                    WHERE N9D2.N9D_FILIAL = N9D.N9D_FILIAL "
	cQry += "	                      AND N9D2.N9D_SAFRA  = N9D.N9D_SAFRA "
	cQry += "		                  AND N9D2.N9D_FARDO  = N9D.N9D_FARDO "
	cQry += "		                  AND D_E_L_E_T_  = ' ') "	
	cQry := ChangeQuery(cQry)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.F.,.T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	
	If (cAliasQry)->(.Not. Eof())
		cIdMovFard := Soma1((cAliasQry)->N9D_IDMOV)
	EndIf
	(cAliasQry)->(DbCloseArea())
				
Return cIdMovFard
