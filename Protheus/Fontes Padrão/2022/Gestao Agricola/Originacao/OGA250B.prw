#include 'protheus.ch'
#include 'parmtype.ch'
#include 'OGA250B.ch'

#DEFINE _CRLF CHR(13)+CHR(10)

Static __oOK	   		:= LoadBitmap(GetResources(),'LBOK')
Static __oNo     		:= LoadBitmap(GetResources(),'LBNO')
Static __lMarcAllE	:= .T.
Static __lMarcAllD	:= .T.
Static __lTelaAtv		:= .F. //se a tela de estufagem esta aberta

/** {Protheus.doc} OGA250B
Função para permitir, no caso do algodão, vincular os fardos no container

@author: 	thiago.rover e janaina.duarte
@since: 	08/11/2017
*/

Function OGA250B(par1, par2, par3, par4)
	Local oModel            := Nil
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
	Local lRet		       	:= .T.
	Local nOpcA 	       	:= 0
	Local oStru

	Private _aItsEsq		:= {}
	Private _aItsDir		:= {}
	Private _nPeso		   	:= 0
	Private _nPesoOrig   	:= 0
	Private _nQtde		   	:= 0 //quantidade de fardos
	Private _oBrwEsq
	Private _oBrwDir
	Private _aIEPeso         := {}
	Private _lValor          := par1 //fora da tela = .T., dentro da tela = .F.
	Private _cCodIE

	__lMarcAllD 		:= .T. //marca tudo painel direito - varivel static
	__lMarcAllE 		:= .T. //marca tudo painel esquerdo - varivel static

	Private _cContainer
	Private _cStatus

	If !IsInCallStack("OGA730")
		Return .f.
	EndIf

	If _lValor //FORA DA TELA
		aFardRom	:= {} //VARIAVEL DECLARADA NO OGA730
		_cCodIE 	:= N91->N91_CODINE
		_cContainer := N91->N91_CONTNR
		_cStatus 	:= N91->N91_STATUS
		oModel		:=  FWLoadModel("OGA730")
	Else
		oModel		:=  FwModelActive()
		oStru 		:= oModel:GetModel("N91UNICO")
		_cCodIE 	:= oStru:GetValue("N91_CODINE")
		_cContainer := oStru:GetValue("N91_CONTNR")
		_cStatus 	:= oStru:GetValue("N91_STATUS")
	EndIf

	If ( _lValor .and. !( _cStatus $ "1|2")) .or. (oModel:GetOperation() = 4  .and. !(_cStatus $ "1|2"))
		AgrHelp(STR0019,STR0028,STR0047)        //"Atenção!" #"Status do container não permite Estufagem." #"Somente containers com status '1-Disponível' e '2-Em estufagem' podem ser estufados."        
		Return .F.
	EndIf

	If !( _lValor) .And. Empty(oStru:GetValue("N91_CONTNR"))
		AgrHelp(STR0019,STR0048,STR0029)        //"Atenção!" #"Campo Container não foi preeenchido." #"Para iniciar a estufagem é necessário preencher o campo container"
		Return .F.
	EndIf

	If lRet
		__lTelaAtv := .T.

		AADD(aCombo, STR0002 ) //"Fardo"
		AADD(aCombo, STR0003 ) //"Etiqueta"
		AADD(aCombo, STR0004 ) //"Bloco"
		AADD(aCombo, STR0037 ) //"Num NF"

		//----- TELA PARA SELECIONAR FARDOS
		//- Coordenadas da area total da Dialog
		oSize:= FWDefSize():New(.T.)
		oSize:AddObject("DLG",100,100,.T.,.T.)
		oSize:SetWindowSize(aCoors)
		oSize:lProp 	:= .T.
		oSize:aMargins := {0,0,0,0}
		oSize:Process()

		DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4];
			TITLE  STR0046 OF oMainWnd PIXEL //"Vínculo de Fardos"

		oPnl1:= tPanel():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],,oDlg,,,,,,oSize:aPosObj[1,4],oSize:aPosObj[1,3])
		//---------------------------
		// Cria instancia do fwlayer
		//---------------------------
		oFWLayer := FWLayer():New()
		oFWLayer:init( oPnl1, .F. )

		oFWLayer:AddCollumn( 'ESQ' , 45, .F.)
		oFWLayer:AddCollumn( 'MEIO', 10, .F.)
		oFWLayer:AddCollumn( 'DIR' , 45, .F.)

		oFWLayer:addWindow( "ESQ" , "Wnd1", STR0007 , 90, .F., .T.) //"Fardos da Instrução de Embarque"
		oFWLayer:addWindow( "DIR" , "Wnd2", STR0008 , 90, .F., .T.) //"Fardos Selecionados "


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
		TButton():New(0,0,STR0009,oBtBarDir,{|| Pesquisa(cChavDir,Alltrim(cPesqDir),@_oBrwDir)},Len(STR0009)*4,10,,,,.T.,,) //"Pesquisa"###'Pesquisa'

		//Carrega os itens na Grid de fardos já vinculados
		_aItsDir := OG250BFRDDIR()

		_oBrwDir := TCBrowse():New( oSize4:aPosObj[1,1], oSize4:aPosObj[1,2], oSize4:aPosObj[1,3], oSize4:aPosObj[1,4], , , , oPnl4, , , , {|| }, {|| }, , , , , , , .f., , .t., , .f., , , )
		_oBrwDir:AddColumn( TCColumn():New(""	 , { || IIf( _aItsDir[_oBrwDir:nAt,1] == "1", __oOK, __oNo  ) },,,,"CENTER",010,.t.,.t.,,,,.f., ) )

		_oBrwDir:AddColumn( TCColumn():New(STR0010 , { || _aItsDir[_oBrwDir:nAt,2] }									, , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Filial"
		_oBrwDir:AddColumn( TCColumn():New(STR0005 , { || _aItsDir[_oBrwDir:nAt,3] }									, , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"IE"
		_oBrwDir:AddColumn( TCColumn():New(STR0011 , { || _aItsDir[_oBrwDir:nAt,4] }									, , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Safra"
		_oBrwDir:AddColumn( TCColumn():New(STR0004 , { || _aItsDir[_oBrwDir:nAt,5] }									, , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Bloco"
		_oBrwDir:AddColumn( TCColumn():New(STR0003 , { || _aItsDir[_oBrwDir:nAt,6] }									, , , , "LEFT" , 060, .f., .t., , , , .f., ) ) //"Etiqueta"
		_oBrwDir:AddColumn( TCColumn():New(STR0002 , { || _aItsDir[_oBrwDir:nAt,7] }									, , , , "LEFT" , 040, .f., .t., , , , .f., ) ) //"Codigo"
		_oBrwDir:AddColumn( TCColumn():New(STR0013 , { || Transform( _aItsDir[_oBrwDir:nAt,8], "@E 999,999,999.99" ) }	, , , , "RIGHT", 050, .f., .t., , , , .f., ) ) //"Peso Bruto"
		_oBrwDir:AddColumn( TCColumn():New(STR0014 , { || Transform( _aItsDir[_oBrwDir:nAt,9], "@E 999,999,999.99" ) }	, , , , "RIGHT", 050, .f., .t., , , , .f., ) ) //"Peso Liquido"
		_oBrwDir:AddColumn( TCColumn():New(STR0043 , { || Transform( _aItsDir[_oBrwDir:nAt,10],"@E 999,999,999.99" ) }  , , , , "RIGHT", 040, .f., .t., , , , .f., ) ) //"Peso Saída"
		_oBrwDir:AddColumn( TCColumn():New(STR0036 , { || _aItsDir[_oBrwDir:nAt,11] }									, , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Serie NF"
		_oBrwDir:AddColumn( TCColumn():New(STR0037 , { || _aItsDir[_oBrwDir:nAt,12] }									, , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Numero NF"
		_oBrwDir:AddColumn( TCColumn():New(STR0042 , { || Transform( _aItsDir[_oBrwDir:nAt,13],"@E 999,999,999.99" ) }  , , , , "RIGHT", 050, .f., .t., , , , .f., ) ) //"Peso Chegada"
		_oBrwDir:AddColumn( TCColumn():New(STR0044 , { || Transform( _aItsDir[_oBrwDir:nAt,14],"@E 999,999,999.99" ) }  , , , , "RIGHT", 050, .f., .t., , , , .f., ) ) //"Peso Certificado"

		_oBrwDir:SetArray( _aItsDir )
		_oBrwDir:bLDblClick 		:= {|| MarcaUm( _oBrwDir, _aItsDir, _oBrwDir:nAt, .F. )}
		_oBrwDir:bHeaderClick 	:= {|| MarcaTudo( _oBrwDir, _aItsDir, _oBrwDir:nAt, @__lMarcAllD, .F. ) }
		_oBrwDir:Align := CONTROL_ALIGN_ALLCLIENT
		_oBrwDir:Refresh(.T.)

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
		TButton():New(0,0, STR0009 ,oBtBarEsq,{|| Pesquisa(cChavEsq,Alltrim(cPesqEsq),@_oBrwEsq)},Len(STR0009)*4,10,,,,.T.,,) //"Pesquisa"###'Pesquisa'

		_aItsEsq := OG250BFRDESQ()

		_oBrwEsq := TCBrowse():New( oSize2:aPosObj[1,1], oSize2:aPosObj[1,2], oSize2:aPosObj[1,3], oSize2:aPosObj[1,4], , , , oPnl2, , , , {|| }, {|| }, , , , , , , .f., , .t., , .f., , , )
		_oBrwEsq:AddColumn( TCColumn():New(""	  , { || IIf( _aItsEsq[_oBrwEsq:nAt,1] == "1", __oOK, __oNo ) }         , , , , "CENTER", 010,.t.,.t.,,,,.f., ) )
		_oBrwEsq:AddColumn( TCColumn():New(STR0010 , { || _aItsEsq[_oBrwEsq:nAt,2] }									, , , , "LEFT"  , 030, .f., .t., , , , .f., ) ) //"Filial"
		_oBrwEsq:AddColumn( TCColumn():New(STR0005 , { || _aItsEsq[_oBrwEsq:nAt,3] }									, , , , "LEFT"  , 030, .f., .t., , , , .f., ) ) //"IE"
		_oBrwEsq:AddColumn( TCColumn():New(STR0011 , { || _aItsEsq[_oBrwEsq:nAt,4] }									, , , , "LEFT"  , 030, .f., .t., , , , .f., ) ) //"Safra"
		_oBrwEsq:AddColumn( TCColumn():New(STR0004 , { || _aItsEsq[_oBrwEsq:nAt,5] }									, , , , "LEFT"  , 030, .f., .t., , , , .f., ) ) //"Bloco"
		_oBrwEsq:AddColumn( TCColumn():New(STR0003 , { || _aItsEsq[_oBrwEsq:nAt,6] }								, , , , "LEFT"  , 060, .f., .t., , , , .f., ) ) //"Etiqueta"
		_oBrwEsq:AddColumn( TCColumn():New(STR0002 , { || _aItsEsq[_oBrwEsq:nAt,7] }									, , , , "LEFT"  , 040, .f., .t., , , , .f., ) ) //"Codigo"
		_oBrwEsq:AddColumn( TCColumn():New(STR0013 , { || Transform( _aItsEsq[_oBrwEsq:nAt,8], "@E 999,999,999.99" ) }	, , , , "RIGHT" , 050, .f., .t., , , , .f., ) ) //"Peso Bruto"
		_oBrwEsq:AddColumn( TCColumn():New(STR0014 , { || Transform( _aItsEsq[_oBrwEsq:nAt,9], "@E 999,999,999.99" ) }	, , , , "RIGHT" , 050, .f., .t., , , , .f., ) ) //"Peso Liquido"
		_oBrwEsq:AddColumn( TCColumn():New(STR0043 , { || Transform( _aItsEsq[_oBrwEsq:nAt,10],"@E 999,999,999.99" ) }  , , , , "RIGHT" , 040, .f., .t., , , , .f., ) ) //"Peso Saída"
		_oBrwEsq:AddColumn( TCColumn():New(STR0036 , { || _aItsEsq[_oBrwEsq:nAt,11] }									, , , , "LEFT"  , 030, .f., .t., , , , .f., ) ) //"Serie NF"
		_oBrwEsq:AddColumn( TCColumn():New(STR0037 , { || _aItsEsq[_oBrwEsq:nAt,12] }									, , , , "LEFT"  , 030, .f., .t., , , , .f., ) ) //"Numero NF"
		_oBrwEsq:AddColumn( TCColumn():New(STR0042 , { || Transform( _aItsEsq[_oBrwEsq:nAt,13],"@E 999,999,999.99" ) }  , , , , "RIGHT" , 050, .f., .t., , , , .f., ) ) //"Peso Chegada"
		_oBrwEsq:AddColumn( TCColumn():New(STR0044 , { || Transform( _aItsEsq[_oBrwEsq:nAt,14],"@E 999,999,999.99" ) }  , , , , "RIGHT" , 050, .f., .t., , , , .f., ) ) //"Peso Certificado"

		_oBrwEsq:SetArray( _aItsEsq )
		_oBrwEsq:bLDblClick 		:= {|| MarcaUm( _oBrwEsq, _aItsEsq, _oBrwEsq:nAt, .F. )}
		_oBrwEsq:bHeaderClick 	:= {|| MarcaTudo( _oBrwEsq, _aItsEsq, _oBrwEsq:nAt, @__lMarcAllE, .F. ) }
		_oBrwEsq:Align := CONTROL_ALIGN_ALLCLIENT
		_oBrwEsq:Refresh(.T.)

		//Caso um fardo seja adicionado na tela principal e a funcao Incluir Fardos seja acionada novamente.
		//Estes fardos que já foram adicionados aparecerao ao lado direito novamente
		UpdFardos(@_oBrwEsq, @_oBrwDir)

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
		TButton():New( (oSize3:APOSOBJ[1][3]/2)-44, oSize3:APOSOBJ[1][1]+5, ">>" , oPnl3, {|| MovFardos( ">", @_oBrwEsq, @_oBrwDir ) }, oSize3:APOSOBJ[1][4]-10, 15, , /**oFont*/, , .t., , STR0015 ) //"Vincular Marcados"
		TButton():New( (oSize3:APOSOBJ[1][3]/2)-28, oSize3:APOSOBJ[1][1]+5, "<<" , oPnl3, {|| MovFardos( "<", @_oBrwEsq, @_oBrwDir ) }, oSize3:APOSOBJ[1][4]-10, 15, , /**oFont*/, , .t., , STR0016 ) //"Desvincular Marcados"

		_nQtde := Len(_aItsDir)

		//---------------------------------------------------------------------------------------------------
		// Apresenta calculos de peso total dos Fardos selecionados e quantidade de itens do romaneio na tela
		//---------------------------------------------------------------------------------------------------
		oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)-5,oSize3:APOSOBJ[1][1]+5,{|| Transform( STR0017 , "@!" )},oPnl3,,oFont,,; //"Quantidade"
		,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)
		oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)+5,oSize3:APOSOBJ[1][1]+5,{||  Alltrim(Transform( _nQtde, '@E 99999') )},oPnl3,,oFont,,;
			,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)
		oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)+15,oSize3:APOSOBJ[1][1]+5,{|| Transform( STR0018, "@!" )},oPnl3,,oFont,,; //"Peso Total"
		,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)
		oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)+25,oSize3:APOSOBJ[1][1]+5,{||Alltrim(Transform( _nPeso, PesqPict('DXL','DXL_PSLIQU')) )},oPnl3,,oFont,,;
			,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)

		ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| nOpcA:= 1, ExecGrav(oDlg, @_oBrwDir, @_oBrwEsq)},{|| nOpcA:= 2, ExecCancel(oDlg) })

	EndIf
	__lTelaAtv := .F.
Return

/*{Protheus.doc} OG250BFRDDIR
Função destinada para buscar no banco os fardos que estão vinculados ao Romaneio ou container(OGA730) posicionado da tela

@author thiago.rover e janaina.duarte
@since 09/11/2017
*/
Function OG250BFRDDIR()
	Local aArea	    := GetArea()
	Local aColsLoad	:= {}
	Local cAliasQry := ""
	Local cQry 		:= ""
	Local nCont	    := 0

	cAliasQry := GetNextAlias()

	cQry := " SELECT DXI_FILIAL, "
	cQry += "DXI_CODINE, "
	cQry += "DXI_SAFRA, "
	cQry += "DXI_BLOCO, "
	cQry += "DXI_ETIQ, "
	cQry += "DXI_CODIGO, "
	cQry += "DXI_PSBRUT, "
	cQry += "DXI_PSLIQU, "
	cQry += "NJM_DOCSER, "
	cQry += "NJM_DOCNUM, "
	cQry += "DXI_PESCHE, "
	cQry += "DXI_PESSAI, "
	cQry += "DXI_PESCER "
	cQry += "FROM "+ RetSqlName("DXI") +" DXI "
	cQry += " INNER JOIN "+ RetSqlName("N9D") +" N9D ON N9D.D_E_L_E_T_ = '' "
	cQry += "     AND N9D_FARDO = DXI_ETIQ AND N9D_FILIAL = DXI_FILIAL "
	cQry += "     AND N9D_TIPMOV='07' AND N9D_STATUS='2' "
	cQry += " INNER JOIN "+ RetSqlName("NJJ") +" NJJ ON NJJ.D_E_L_E_T_ = '' "
	cQry += "     AND NJJ_FILIAL = DXI_FILIAL AND NJJ_CODROM = DXI_ROMFLO AND NJJ_STATUS='3' "
	cQry += "     AND NJJ_TIPO = '2' " //TIPO REMESSA
	cQry += " INNER JOIN "+ RetSqlName("NJM") +" NJM ON NJM.D_E_L_E_T_ = '' "
	cQry += "     AND NJM_FILIAL = NJJ_FILIAL AND NJM_CODROM=NJJ_CODROM AND NJM_ITEROM = N9D_ITEROM "
	cQry += "     AND NJM_CODCTR = N9D_CODCTR AND NJM_ITEM = N9D_ITEETG "
	cQry += "     AND NJM_SEQPRI = N9D_ITEREF "
	cQry += " WHERE DXI.D_E_L_E_T_ = '' "
	cQry += " AND DXI_CODINE = '"+ _cCodIE + "' "
	cQry += " AND DXI_ROMFLO <> '' "
	cQry += " AND DXI_CONTNR = '"+ _cContainer + "' "
	cQry += " AND DXI_CONTNR <> ''"
	cQry += " ORDER BY  DXI_FILIAL,DXI_CODINE,DXI_BLOCO,DXI_CODIGO "

	cQry := ChangeQuery( cQry )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	//Variavel privada. Resetar valor antes da busca dos fardos para somar corretamente.
	_nPeso     := 0
	_nPesoOrig := 0

	//Seleciona a tabela
	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof())

		nCont++
		aAdd( aColsLoad, { "2", (cAliasQry)->DXI_FILIAL, (cAliasQry)->DXI_CODINE, (cAliasQry)->DXI_SAFRA, (cAliasQry)->DXI_BLOCO, (cAliasQry)->DXI_ETIQ, (cAliasQry)->DXI_CODIGO, (cAliasQry)->DXI_PSBRUT, ;
			(cAliasQry)->DXI_PSLIQU, (cAliasQry)->DXI_PESSAI, (cAliasQry)->NJM_DOCSER, (cAliasQry)->NJM_DOCNUM, (cAliasQry)->DXI_PESCHE,(cAliasQry)->DXI_PESCER })

		//Se Peso Chegada for maior que o Peso de Saída usa o Peso de Chegada, se não, usa o Peso de Saída.
		_nPeso += Iif((cAliasQry)->DXI_PESCHE > (cAliasQry)->DXI_PESSAI, (cAliasQry)->DXI_PESCHE, (cAliasQry)->DXI_PESSAI)

		_nPesoOrig += (cAliasQry)->DXI_PSLIQU
		(cAliasQry)->(DbSkip())
	End

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return(aColsLoad)


/*{Protheus.doc} OG250BFRDESQ
Função destinada para buscar no banco os fardos que estão vinculados a instrução de embarque, sem vinculo ao Romaneio ou conatiner(OGA730) posicionado da tela

@author thiago.rover e janaina.duarte
@since 09/11/2017
*/

Function OG250BFRDESQ()
	Local aArea	    := GetArea()
	Local aColsLoad	:= {}
	Local cAliasQry := ""
	Local cQry 		:= ""
	Local nCont	    := 0

	cAliasQry := GetNextAlias()

	If Select(cAliasQry) > 0
		(cAliasQry)->( dbCloseArea() )
	EndIf

	cQry := " SELECT DXI_FILIAL, "
	cQry += "DXI_CODINE, "
	cQry += "DXI_SAFRA, "
	cQry += "DXI_BLOCO, "
	cQry += "DXI_ETIQ, "
	cQry += "DXI_CODIGO, "
	cQry += "DXI_PSBRUT, "
	cQry += "DXI_PSLIQU, "
	cQry += "NJM_DOCSER, "
	cQry += "NJM_DOCNUM, "
	cQry += "DXI_PESCHE, "
	cQry += "DXI_PESSAI, "
	cQry += "DXI_PESCER "
	cQry += "FROM "+ RetSqlName("DXI") +" DXI "
	cQry += " INNER JOIN "+ RetSqlName("N9D") +" N9D ON N9D.D_E_L_E_T_ = '' "
	cQry += "     AND N9D_FARDO = DXI_ETIQ AND N9D_FILIAL = DXI_FILIAL "
	cQry += "     AND N9D_TIPMOV='07' AND N9D_STATUS='2'"
	cQry += " INNER JOIN "+ RetSqlName("NJJ") +" NJJ ON NJJ.D_E_L_E_T_ = '' "
	cQry += "     AND NJJ_FILIAL = DXI_FILIAL AND NJJ_CODROM = DXI_ROMFLO AND NJJ_STATUS='3' "
	cQry += "     AND NJJ_TIPO = '2' " //TIPO REMESSA
	cQry += " INNER JOIN "+ RetSqlName("NJM") +" NJM ON NJM.D_E_L_E_T_ = '' "
	cQry += "     AND NJM_FILIAL = NJJ_FILIAL AND NJM_CODROM = NJJ_CODROM AND NJM_ITEROM = N9D_ITEROM "
	cQry += "     AND NJM_CODCTR = N9D_CODCTR AND NJM_ITEM = N9D_ITEETG AND NJM_SEQPRI = N9D_ITEREF "
	cQry += " WHERE DXI.D_E_L_E_T_ = '' "
	cQry += " AND DXI_CODINE = '"+ _cCodIE + "' "
	cQry += " AND DXI_ROMFLO <> '' "
	cQry += " AND DXI_CONTNR = '' "
	cQry += " ORDER BY DXI_FILIAL,DXI_CODINE,DXI_BLOCO,DXI_CODIGO "

	cQry := ChangeQuery( cQry )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	//Seleciona a tabela
	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof())

		nCont++

		aAdd( aColsLoad, { "2", (cAliasQry)->DXI_FILIAL, (cAliasQry)->DXI_CODINE, (cAliasQry)->DXI_SAFRA, (cAliasQry)->DXI_BLOCO, (cAliasQry)->DXI_ETIQ, (cAliasQry)->DXI_CODIGO, (cAliasQry)->DXI_PSBRUT, ;
			(cAliasQry)->DXI_PSLIQU, (cAliasQry)->DXI_PESSAI, (cAliasQry)->NJM_DOCSER, (cAliasQry)->NJM_DOCNUM, (cAliasQry)->DXI_PESCHE, (cAliasQry)->DXI_PESCER } )

		(cAliasQry)->(DbSkip())
	EndDo

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
	Local lRet	   := .T.
	Local lMarc	   := .F.
	Local nI       := 0
	Local lAchou   := .F.
	Local nFrds    := 1
	Local aBlcErr  := {}
	Local cMsg	   := ""

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
				lMarc  := .T.
				lAchou := .F.
				aAdd( aItsDest, aItsOrig[ nX ] )
				aItsDest[ Len( aItsDest ), 1 ] := "2"

				If Empty( aItsDest[ Len( aItsDest ), 3 ] ) .AND. cSeta == ">"
					nPosErr := aScan( aBlcErr, { | x | AllTrim( x[ 1 ]) = aItsDest[ Len( aItsDest ), 5 ] } )
					If nPosErr == 0
						aAdd( aBlcErr, { aItsDest[ Len( aItsDest ), 5 ], nFrds})
					Else
						aBlcErr[nPosErr, 2] += 1
					EndIf

					aDel( aItsDest, Len( aItsDest ) )
					aSize( aItsDest, Len( aItsDest )-1 )

				Else

					aDel( aItsOrig, nX )
					aSize( aItsOrig, Len( aItsOrig )-1 )
					nX--

				EndIf

			EndIf

		Next nX

		/*Para cada bloco de fardo que teve seu limite ultrapassado*/
		For nI := 1 to Len( aBlcErr )

			cMsg += STR0039 + aBlcErr[nI,1] + _CRLF //#Bloco: 
			cMsg += STR0040 + cValToChar( aBlcErr[nI,2] )+ _CRLF + _CRLF //#Qtd Acima:

		Next nI

		If !empty(cMsg)
			AgrHelp(STR0019, STR0022 + _CRLF + _CRLF + cMsg, STR0049) //#Atenção ##"Quantidade de fardos do bloco ultrapassou o limite disponivel: " #"Ajuste a quantidade de fardos na instrução de embarque ou no container."            
			lRet := .F.
		EndIf

		aItsOrig := ASort( aItsOrig, , , { | x, y | x[2]+x[3]+x[4]+x[5]+x[6]+x[7] < y[2]+y[3]+y[4]+y[5]+y[6]+y[7]}) //ordena filial+codine+safra+bloco+etiqueta+codigo
		aItsDest := ASort( aItsDest, , , { | x, y | x[2]+x[3]+x[4]+x[5]+x[6]+x[7] < y[2]+y[3]+y[4]+y[5]+y[6]+y[7]}) //ordena filial+codine+safra+bloco+etiqueta+codigo

		If lRet .and. cSeta == ">"
			lRet := OGA250BVALID(aItsDest,aItsOrig,.T.)
		EndIf

		If lRet .And. lMarc
			If cSeta == ">"
				_aItsEsq := aClone( aItsOrig )
				_aItsDir := aClone( aItsDest )
				__lMarcAllE := .T.
			EndIf

			If cSeta == "<"
				_aItsEsq := aClone( aItsDest )
				_aItsDir := aClone( aItsOrig )
				__lMarcAllE := .T.
			EndIf

			oBrwEsq:SetArray( _aItsEsq )
			oBrwDir:SetArray( _aItsDir )
			oBrwEsq:GoPosition(1) //para posicionar na primeira linha, quando utiliza a pesquisa a posição é alterada e se der refresh e a posição não mais existir gera erro
			oBrwDir:GoPosition(1)
			oBrwEsq:Refresh()
			oBrwDir:Refresh()

		EndIf
		If !lMarc
			AgrHelp(STR0019,STR0050,STR0051) //#Atenção #"Não foram marcados fardos na tela." #"Necessário marcar os fardos."            
		EndIf

		If !lRet
			Return lRet
		EndIF

	EndIf

	_nQtde := Len(oBrwDir:AARRAY) // Total de itens do romaneio
	_nPeso := 0
	For nX := 1 To len(oBrwDir:AARRAY)
		//Se Peso Chegada for maior que o Peso de Saída usa o Peso de Chegada, se não usa o Peso de Saída.
		_nPeso += Iif(oBrwDir:AARRAY[nX, 10] > oBrwDir:AARRAY[nX, 13], oBrwDir:AARRAY[nX, 10], oBrwDir:AARRAY[nX, 13])
	Next

Return(lRet)


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

	ASORT(oBrowse:AARRAY,,,{|x,y| x[2]+x[3]+x[4]+x[5]+x[6]+x[7] < y[2]+y[3]+y[4]+y[5]+y[6]+y[7]})   //ordena filial+codine+safra+bloco+etiqueta+codigo

	If Alltrim(Upper(cChave)) == Upper(STR0002) //fardos
		for nX := 1 to len(oBrowse:AARRAY)
			If oBrowse:AARRAY[nX][7] == cPesquisa
				If nPosAc = 0
					nPosAc := nX //seta linha para posicionar
				EndIf
				//realiza a marcação do registro
				MarcaPesq( oBrowse, oBrowse:AARRAY, nX)
			EndIf
		Next
	ElseIf Alltrim(Upper(cChave)) == Upper(STR0003) //Etiqueta
		for nX := 1 to len(oBrowse:AARRAY)
			If oBrowse:AARRAY[nX][6] == cPesquisa
				If nPosAc = 0
					nPosAc := nX //seta linha para posicionar
				EndIf
				//realiza a marcação do registro
				MarcaPesq( oBrowse, oBrowse:AARRAY, nX)
			EndIf
		Next
	ElseIf Alltrim(Upper(cChave)) == Upper(STR0004) //bloco
		for nX := 1 to len(oBrowse:AARRAY)
			If oBrowse:AARRAY[nX][5] == cPesquisa
				If nPosAc = 0
					nPosAc := nX //seta linha para posicionar
				EndIf
				//realiza a marcação do registro
				MarcaPesq( oBrowse, oBrowse:AARRAY, nX)
			EndIf
		Next
	ElseIf Alltrim(Upper(cChave)) == Upper(STR0037) //numero nota fiscal romaneio
		ASORT(oBrowse:AARRAY,,,{|x,y| x[2]+x[12] < y[2]+y[12]})   //ordena filial+NF
		for nX := 1 to len(oBrowse:AARRAY)
			If oBrowse:AARRAY[nX][12] == cPesquisa
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


/** -------------------------------------------------------------------------------------
{Protheus.doc} OGA730BGRV
Validação da confirmação dos dados da janela

@author thiago.rover e janaina.duarte
@since 11/11/2017
-------------------------------------------------------------------------------------- **/
Function OGA730BGRV(lCond)

	Local aArea	      := GetArea()
	Local nI	      := 0	
	Local lRet		  := .T.
	Local nSqtdRen    := 0 
	Local nSqtdRec    := 0
	Local oModel      := FwModelActive()
	Local oN91        := IIF(lCond , nil ,oModel:GetModel("N91UNICO"))

	_cContainer := IIF(lCond , N91->N91_CONTNR ,oN91:GetValue("N91_CONTNR"))
	_cCodIE := IIF(lCond , N91->N91_CODINE ,oN91:GetValue("N91_CODINE"))

	dbSelectArea("DXI")
	DXI->(dbSetOrder(7)) //FILIAL+SAFRA+CODIGO	
	For nI := 1 To Len(aFardRom)

		If DXI->(dbSeek(aFardRom[nI][2] + aFardRom[nI][4] + aFardRom[nI][7]))
			
			MovFardosN9D(.F.,"05")
			
			If RecLock( "DXI", .F. )
	
				if aFardRom[nI][12] = 'I'
					DXI->DXI_CONTNR := _cContainer
	
					nSqtdRen += DXI->DXI_PESSAI
					nSqtdRec += DXI->DXI_PESCHE
					
					MovFardosN9D(.T.,"05")
					
				else
					DXI->DXI_CONTNR := ''
					
				EndIf
	
				DXI->( msUnLock() )
			EndIf
		EndIf
	
	Next nI

	AtDadosCnt(lCond)

	//Se a IE já estiver com status FATURADA, ao mexer na estufagem física, voltar o status
	//da IE para Parcial	
	dbSelectArea( "N7Q" ) 
	N7Q->(dbSetorder(1))
	If N7Q->(dbSeek(xFilial( "N7Q" ) + _cCodIE ))
		If Alltrim(N7Q->N7Q_STAFAT) == '3'
			RecLock("N7Q",.F.)
			N7Q->N7Q_STAFAT :=  '2'  //Parcial
			N7Q->(MsUnLock())
		EndIf
	EndIf
	
	OG250EAQIE("05", xFilial( "N7Q" ), _cCodIE)

	aFardRom := {}
	_aIEPeso  := {}

	RestArea(aArea)
Return lRet

/**-------------------------------------------------------------------------------------
{Protheus.doc} UpdFardos
Reexibe no Grid direito/Esquerdo os fardos adicionados sem confirmação

@author: 	thiago.rover e janaina.duarte
@since: 	09/11/2017
-------------------------------------------------------------------------------------**/
Static Function UpdFardos(oBrwEsq, oBrwDir)
	Local nI, nX
	Local aItsEsq := oBrwEsq:AARRAY
	Local lSelec  := .F.

	For nI := 1 To Len(aFardRom)
		If !Empty(aFardRom[nI][7])
			For nX := 1 To Len(aItsEsq)
				If aFardRom[nI][12] = "I" .And. aFardRom[nI][7] = aItsEsq[nX][7]
					aItsEsq[nX][1] := "1"
					lSelec := .T.
				Endif
			Next nX
		Endif
	Next nI

	If lSelec
		MovFardos( ">", @oBrwEsq, @oBrwDir )
	EndIf
Return 



/**-------------------------------------------------------------------------------------
{Protheus.doc} ExecGrav
Recebe o Dialog, Browse e Modelo para ser enviado para o método de gravação.
Realiza a gravação antes de fechar o dialog, pois o mesmo anula variaveis.

@author: 	thiago.rover e janaina.duarte
@since: 	08/11/2017
-------------------------------------------------------------------------------------**/
Static Function ExecGrav(oDlg, oBrwDir, oBrwEsq)
	Local lRet := .T.

	If INCLUI .Or. ALTERA
		Begin Transaction
			oProcess := MsNewProcess():New( { | lEnd | lRet := OGA250AGRAVA(@oBrwDir,@oBrwEsq)}, STR0012, STR0021, .F. ) //"Aguarde"###"Atualizando tabela de dados dos itens do romaneio"
			oProcess:Activate()
			If !lRet
				DisarmTransaction()
			EndIf

		End Transaction
	EndIf

	If lRet //se true/bverdadeiro fecha tela
		oDlg:End()
	EndIf

Return 

/**-------------------------------------------------------------------------------------
{Protheus.doc} ExecCancel
Recebe o Dialog.
Realiza a cancelamento da tela.

@author: 	claudineia.reinert
@since: 	15/12/2017
-------------------------------------------------------------------------------------**/
Static function ExecCancel(oDlg)

	aFardRom:={} //limpa variavel 
	oDlg:End()

Return

/** -------------------------------------------------------------------------------------
{Protheus.doc} OGA250AGRAVA
Atualiza os dados dos itens do Romaneio

@author thiago.rover e janaina.duarte
@since 09/11/2017
-------------------------------------------------------------------------------------- **/
Static Function OGA250AGRAVA(oBrowseDir, oBrowseEsq)

	lRet := OGA250BVALID(oBrowseDir:AARRAY,oBrowseEsq:AARRAY,.F.)

	//
	//Chama a função para setar os atributos
	If _lValor == .T. .AND. lRet == .T.
		OGA730BGRV(.T.)
	ElseIf _lValor == .F. .AND. lRet == .T.
		AtDadosCnt(_lValor) //atualiza dados do container
	ElseIf lRet == .F.
		aFardRom := {}
		_aIEPeso  := {}
	EndIf

Return lRet

/** -------------------------------------------------------------------------------------
{Protheus.doc} OGA250BVALID
Valida dados dos fardos

@author tamyris.ganzenmueller
@since 04/12/2017
-------------------------------------------------------------------------------------- **/
Static Function OGA250BVALID(aRRRAYDir, aRRRAYEsq, lValCTN)
	Local nX		:= 0
	Local lRet      := .T.
	Local nPos	    := 0
	Local aFardBlc  := {}
	Local cParLot	:= ""
	Local cFilCnt	:= N91->N91_FILORG

	aFardRom := {}
	_aIEPeso := {}

	For nX:= 1 To Len(aRRRAYDir)

		// Não permitir vincular fardos de filiais diferentes no container caso N7Q_PARLOT seja igual a NÂO("2")
		If Empty(cParLot)
				cParLot	:= POSICIONE("N7Q",1,xFilial("N7Q")+aRRRAYDir[nX][3],"N7Q_PARLOT")
		EndIf
		If cParLot == "2"
			If !EMPTY(cFilCnt) .AND. cFilCnt <> aRRRAYDir[nX][2]
					AgrHelp(STR0019, STR0045 + cFilCnt, STR0052+ cFilCnt) //#Atenção #"Não foi possivel vincular este fardo. O Container esta reservado para estufagem da filial " #"Vincule somente fardos da filial "                    
					Return .F.
			ElseIf (nX > 1 .AND.  aRRRAYDir[nX][2] <> aRRRAYDir[(nX-1)][2])
					HELP(" ",1,"OGA730PARLOT") //PROBLEMA:não é possivel vincular fardos de filiais diferentes quando a IE do container possui PartLot igual a Não##SOLUÇÂO: Vincule fardos de uma unica filial
					Return .F.
			EndIf
		EndIf
		//*******  FIM - Não permitir vincular fardos de filiais diferentes no container caso N7Q_PARLOT seja igual a NÂO("2")

		aAdd(aFardRom,{,; 
						aRRRAYDir[nX][2],; //Filial
						aRRRAYDir[nX][3],; //IE
						aRRRAYDir[nX][4],; //Safra
						aRRRAYDir[nX][5],; //Bloco
						aRRRAYDir[nX][6],; //Etiqueta
						aRRRAYDir[nX][7],; //Fardo
						aRRRAYDir[nX][8],; //Peso Bruto
						aRRRAYDir[nX][9],; //Peso Líquido
						aRRRAYDir[nX][10],;//Peso Saída
						aRRRAYDir[nX][13],;//Peso Chegada
						'I'})

		nPos := aScan( aFardBlc, { | x | AllTrim( x[ 1 ])+AllTrim( x[ 2 ] ) = AllTrim( aRRRAYDir[nX][3] ) + AllTrim( aRRRAYDir[nX][5] ) } )
		If nPos = 0
			aAdd(aFardBlc,{;
			aRRRAYDir[nX][3],; //IE
			aRRRAYDir[nX][5],; //Bloco
			1; //qtd fardos romaneio para o bloco e IE
			})
		Else
			aFardBlc[nPos][3] += 1
		EndIF

		//*******  INICIO - Cria array com as IE´s e total do peso
		//armazena um array contendo as instruções de embarque e peso
		nPos := aScan( _aIEPeso, { | x | AllTrim( x[ 1 ]) = AllTrim(aRRRAYDir[nX][3]) } )

		nPeso1 := aRRRAYDir[nX][10] //Peso Saída
		//Se Peso Chegada for maior que o Peso de Saída usa o Peso de Chegada, se não, usa o Peso de Saída.
		nPeso2 := Iif(aRRRAYDir[nX][13] > aRRRAYDir[nX][10], aRRRAYDir[nX][13], aRRRAYDir[nX][10])
		
		If nPos = 0
			aAdd(_aIEPeso,{aRRRAYDir[nX][3],nPeso1,nPeso2})
		Else
			_aIEPeso[nPos][2] += nPeso1
			_aIEPeso[nPos][3] += nPeso2 
		EndIF
		//*******  FIM - Cria array com as IE´s e total do peso

	Next nX

	For nX:= 1 To Len(aRRRAYEsq)

		aAdd(aFardRom,{,; 
		aRRRAYEsq[nX][2],; //Filial
		aRRRAYEsq[nX][3],; //IE
		aRRRAYEsq[nX][4],; //Safra
		aRRRAYEsq[nX][5],; //Bloco
		aRRRAYEsq[nX][6],; //Etiqueta
		aRRRAYEsq[nX][7],; //Fardo
		aRRRAYEsq[nX][8],; //Peso Bruto
		aRRRAYEsq[nX][9],;//Peso Líquido
		aRRRAYEsq[nX][10],;//Peso Saída
		aRRRAYEsq[nX][13],;//Peso Chegada
		'E'})//Peso Líquido

	Next nX

	If lRet .And. lValCTN //Validação para o container
		For nX:=1 To Len(_aIEPeso)
			lRet := ValPesCTN(_aIEPeso[nX][1],_aIEPeso[nX][2],_aIEPeso[nX][3])
		Next nX
	EndIF

Return lRet

/** {Protheus.doc} OG250BRPFA
Realiza o rateio do peso dos fardinhos de algodão

@return:	Nil
@author: 	Claudineia Heerdt Reinert
@since: 	16/11/2017
@Uso: 		OGA250 - Romaneio
*/
Function OG250BRPFA(cCodRom, nOpcCampo )
	//funcão executada quando atualiza o romaneio
	//Realiza o rateio do peso liquido do romaneio para os fardinhos
	Local aRateio		:= {} //array com os dados do rateio
	Local cQuery 		:= ""
	Local cAliasQry		:= GetNextAlias()
	Local nPsLiqRom		:= NJJ->NJJ_PESO3 //peso liquido do romaneio = peso bruto dos fardinhos
	Local nI			:= 0
	Local nTaraFrd		:= 0 //tara do fardinho
	Local nPsFrdRat		:= 0 //peso do fardinho rateado
	Local nPercFrd		:= 0 //percentual do fardinho
	Local nPsTotRat		:= 0 //peso bruto total do rateio dos fardinho
	Local nPsTotFrd		:= 0 //peso bruto total dos fardinhos
	Local lRet			:= .T.
	Local nPsAntAtu		:= 0 //peso rateio do fardo antes de atualizar campo
	Local cCampoRom     := AGR500BRMSAI(cCodRom) //OGA250BRMSAI(cCodRom) //Verifica se o campo para gravar o Romaneio é DXI_ROMSAI ou DXI_ROMFO

	//query para buscar os fardinhos do romaneio
	cQuery :=  " SELECT * "
	cQuery +=  " FROM "+ RetSqlName("DXI") + " DXI"
	cQuery +=  " WHERE DXI.DXI_FILIAL = '" + xFilial( 'DXI' ) + "'"
	cQuery +=  " AND DXI."+cCampoRom+"   = '" + cCodRom + "' "
	cQuery +=  " AND DXI.D_E_L_E_T_ = '' "
	cQuery +=  " ORDER BY DXI.DXI_CODIGO "
	cQuery := ChangeQuery(cQuery)
	If Select(cAliasQry) <> 0
		(cAliasQry)->(dbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	While (cAliasQry)->(!Eof())

		nTaraFrd := (cAliasQry)->DXI_PSBRUT - (cAliasQry)->DXI_PSLIQU //tara do fardinho
		nPsTotFrd += (cAliasQry)->DXI_PSLIQU //peso liquido dos fardinhos no beneficiamento

		Aadd( aRateio, { ;
			(cAliasQry)->DXI_CODINE,;
			(cAliasQry)->DXI_FILIAL,;
			(cAliasQry)->DXI_BLOCO ,;
			(cAliasQry)->DXI_SAFRA ,;
			(cAliasQry)->DXI_CODIGO,;
			(cAliasQry)->DXI_PSBRUT,;
			(cAliasQry)->DXI_PSLIQU,;
			nTaraFrd,;
			0,; //peso rateio
		(cAliasQry)->DXI_ETIQ })

		(cAliasQry)->( dbSkip() )

	EndDo
	(cAliasQry)->(dbCloseArea())

	For nI := 1 to Len( aRateio )
		nPercFrd  := (aRateio[nI][7] / nPsTotFrd)*100 //percentual do fardinho em relação ao peso bruto dos fardinhos do romaneio no beneficiamento
		nPsFrdRat := round(nPsLiqRom * (nPercFrd/100) , 2) //Peso bruto de rateio do fardinho
		nPsTotRat += nPsFrdRat
		aRateio[nI][9] := nPsFrdRat //armazena no aRateio o novo peso liquido de rateio do fardinho
		If nI = Len( aRateio ) .and. nPsLiqRom <> nPsTotRat
			aRateio[nI][9] += round((nPsLiqRom - nPsTotRat),2) //o ultimo fardinho recebe a diferença de peso que pode ser maior ou menor devido as casas decimais
		EndIf

		dbSelectArea( "DXI" )
		DXI->(dbSetOrder(7)) //FILIAL+SAFRA+CODIGO
		If DXI->(dbSeek( aRateio[nI][2] + aRateio[nI][4] + aRateio[nI][5]) )
			If RecLock( "DXI", .F. )
				If nOpcCampo = 1 // Rateio romaneio de saida

					DXI->DXI_PESSAI  := round(aRateio[nI][9],2)

				ElseIf nOpcCampo = 2 // Rateio romaneio de chegada no destino

					nPsAntAtu := DXI->( DXI_PESCHE ) //armazena valor do campo antes de atualizar
					DXI->( DXI_PESCHE ) := round(aRateio[nI][9],2)
					//O peso de chegada pode ser alterado varias vezes,
					// então para atualizar a quantidade de chegada na IE é necessario atualizar a diferença do valor rateado anteriormente com o valor atual
					aRateio[nI][9] := aRateio[nI][9] - nPsAntAtu

				EndIf
				DXI->( msUnLock() )
			EndIf
		EndIf

	Next nI

	lRet := AtuQtdIE(aRateio,nOpcCampo,.T.,cCodRom)

Return lRet

/** {Protheus.doc} AtuQtdIE
Atualiza campos de Quantidade na IE conforme parametros recebido nesta função

@param: aRateio - array com os fardinhos
@param: nOpcCampo - valor numerico com a opção do campo a ser atualizado, sendo 1=N7Q_QTDREM,2=N7Q_QTDCHE
@param: lSomar - valor logico, sendo .T. para somar ou .F. para subtrair a quantidade do campo
@return:	.T. - valor logico
@author: 	Claudineia Heerdt Reinert
@since: 	16/11/2017
@Uso: 		OGA250 - Romaneio
*/
Static Function AtuQtdIE(aRateio,nOpcCampo, lSomar, cCodRom)

	Local nI := 0
	Local aQtdIE		:= {} //Quantidade por IE
	Local nPos := 0
	Local lRet := .T.
	Local cSubTipo := ""

	Default lSomar := .T.

	//Valida SubTipo Romaneio
	If !Empty(cCodRom) .And. NJM->NJM_CODROM <> cCodRom
		dbSelectArea( "NJM" )
		NJM->(dbSetOrder(1))
		NJM->(dbSeek( xFilial( "NJM" ) + cCodRom) )
	EndIf
	cSubTipo := NJM->NJM_SUBTIP

	//le os fardinhos gerando a quantidade por IE de cada fardos
	For nI := 1 to Len( aRateio )

		nPos := aScan( aQtdIE, { | x | AllTrim( x[ 1 ]) = AllTrim( aRateio[nI][1] ) } )
		If nPos = 0
			aAdd(aQtdIE,{	;
				aRateio[nI][1],; //IE
			aRateio[nI][9],; //PESO RATEIO FARDO
			1 })
		Else
			aQtdIE[nPos][2] += aRateio[nI][9] //PESO RATEIO FARDO
			aQtdIE[nPos][3] += 1 //QTD FARDOS
		EndIF
	Next nI

	//grava a quantidade no campo
	dbSelectArea( "N7Q" )
	N7Q->(dbSetOrder(1)) //N7Q_FILIAL+N7Q_CODINE
	For nI := 1 to Len( aQtdIE )
		If N7Q->(dbSeek( xFilial( "N7Q" ) + aQtdIE[nI][1]) )
			If RecLock( "N7Q", .F. )
				If nOpcCampo = 1 .AND. lSomar // Rateio romaneio de saida
					If !AGRX500VQIE(aQtdIE[nI][1], aQtdIE[nI][2], cCodRom)
						lRet := .F.
						N7Q->( msUnLock() )
						Exit
					EndIf
				ElseIf nOpcCampo = 2 // Rateio romaneio de chegada
					N7Q->( N7Q_QTDREC ) := N7Q->( N7Q_QTDREC ) + aQtdIE[nI][2]
				EndIf
				N7Q->( msUnLock() )
			EndIf
		EndIf
	Next nI

Return lRet

/**-------------------------------------------------------------------------------------
{Protheus.doc} ValPesCTN(aIePeso)
Validar peso dos fardos x Peso Maximo do Container mais o percentual permitido  
@author: 	tamyris.ganzenmueller
@since: 	29/11/2017
-------------------------------------------------------------------------------------**/
Function ValPesCTN(cCodIE,nQtdIELiq,nQtdIEBru)
	Local lRet 			:= .T.
	Local cMsg 			:= ""
	Local nPesTotCtn   	:= 0
	Local nPesCtnMax 	:= 0

	//grava a quantidade no campo
	dbSelectArea( "N7Q" ) 
	N7Q->(dbSetOrder(1)) //N7Q_FILIAL+N7Q_CODINE
	If N7Q->(dbSeek( xFilial( "N7Q" ) + cCodIE) )
		nPesCtnMax := (N7Q->N7Q_PSCNTR * ((100 - N7Q->N7Q_PERMAX) / 100)) // Validação Qtd máxima da instrução

		//Quando estufagem de CNT utiliza o maior peso entre a soma dos pesos de saída faz. ou peso cheg. porto
		//A varivel nQtdIEBru recebe o maior peso da função OGA250BVALID()
		nPesTotCtn := nQtdIEBru

		If nPesTotCtn > nPesCtnMax .And. N7Q->N7Q_PSCNTR > 0 //Somente valida se for informado peso máximo para o CNT.
			cMsg += STR0026 + cCodIE + _CRLF//Instrução de Embarque:			
            cMsg += STR0027 + _CRLF + _CRLF //"O total do peso vinculado está acima do peso máximo do container informado na instrução de embarque. "			
			cMsg += STR0053 + cValToChar( ABS(nPesCtnMax - nPesTotCtn) ) + _CRLF + _CRLF //"Quantidade acima: "
		EndIf
	EndIf

	If !Empty(cMsg)
		AgrHelp(STR0019, cMsg, STR0054) //#Atenção //"Ajuste o peso vinculado no container ou ajuste o peso na instrução de embarque."
        MsgAlert(cMsg)
	endif

Return lRet

/*{Protheus.doc} AtDadosCnt
Função auxiliar criada para separar as validações e gravações do Romaneio da tela de Container

@author Claudineia Heerdt Reinert
@since 05/12/2017
@version undefined
@param lCond, logical, descricao
@type function
*/
Static Function AtDadosCnt(lCond)
	Local oModel 		:= FwModelActive()
	Local oN91 			:= nil
	Local nQtdLiqRem 	:= 0
	Local nQtdBrtRem 	:= 0
	Local nQtdLiqRec 	:= 0
	Local nQtdBrtRec 	:= 0
	Local nTaraFrd 		:= 0
	Local nI			:= 0
	Local nStatus       := '1'

	//Lê os fardos
	dbSelectArea("DXI")
	DXI->(dbSetOrder(7)) //FILIAL+SAFRA+CODIGO
	For nI := 1 To Len(aFardRom)

		If DXI->(dbSeek(aFardRom[nI][2] + aFardRom[nI][4] + aFardRom[nI][7])) 	//posiciona no registro
			If aFardRom[nI][12] = 'I' //se fardo para gravar
				nTaraFrd := DXI->DXI_PSBRUT - DXI->DXI_PSLIQU //tara do fardo
				nQtdLiqRem += DXI->DXI_PESSAI //peso liquido de saida/remetido
				nQtdBrtRem += DXI->DXI_PESSAI + nTaraFrd  //peso bruto de saida/remetido
				nQtdLiqRec += DXI->DXI_PESCHE //peso liquido de chegada/recebido
				nQtdBrtRec += DXI->DXI_PESCHE + nTaraFrd  //peso bruto de chegada/recebido
			EndIf
		EndIf
	Next nI

	If lCond
		If !Empty(_nQtde)
			If N91->N91_STUFIN == '1'
				nStatus := '3'
			Else
				nStatus := '2'
			EndIf
		Else
			nStatus := '1'
		EndIf

		dbSelectArea("N91")
		N91->(dbSetOrder(1)) //FILIAL+CODINE+CONTAINER
		N91->(dbSeek( xFilial( "N91" ) + _cCodIE + _cContainer) )
		If RecLock( "N91", .F. )
			N91_QTDFRD := _nQtde //qtd de fardos
			N91_QTDREM := nQtdLiqRem
			N91_BRTREM := nQtdBrtRem
			N91_QTDREC := nQtdLiqRec
			N91_BRTREC := nQtdBrtRec
			N91_STATUS := nStatus

			If N91_STATUS == '1'
				N91_STUFIN := '2'
			EndIf

			N91->( msUnLock() )
		EndIf

	ElseIf !lCond .and. (oModel:GetOperation() = 4 .or. oModel:GetOperation() = 3 ) .and. __lTelaAtv  //se for pelo formulario do container em modo de alteração/inclusao e com a tela de estufagem aberta

		oN91 := oModel:GetModel("N91UNICO")
		oN91:SetValue("N91_QTDFRD", _nQtde) //qtd de fardos
		oN91:SetValue("N91_QTDREM", nQtdLiqRem)
		oN91:SetValue("N91_BRTREM", nQtdBrtRem)
		oN91:SetValue("N91_QTDREC", nQtdLiqRec)
		oN91:SetValue("N91_BRTREC", nQtdBrtRec)

		If oN91:GetValue("N91_STATUS") == '1' .AND. !Empty(_nQtde)
			oN91:SetValue("N91_STATUS", '2')
		ElseIf Empty(_nQtde)
			oN91:SetValue("N91_STUFIN", '2')
			oN91:SetValue("N91_STATUS", '1')
		EndIf

	EndIf
Return

/*{Protheus.doc} 
Função para definir em qual campo na DXI será salvo o codigo do romaneio
@sample   	OGA250ROMSAI()
@param		cCodRom - Codigo Romaneio
@param		lValor  - Por Fora
@return   	"DXI_ROMSAI" - Salvar no campo DXI_ROMSAI ; "DXI_ROMFLO" - Salvar no campo DXI_ROMFLO
@author   	felipe.mendes
@since    	09/01/2018
@version  	P12
*/
Function OGA250BRMSAI(cCodRom)

	Local aAreaAtu 		:= GetArea()
	Local aAreaNJJ 		:= NJJ->( GetArea() )
	Local aAreaNJR 		:= NJR->( GetArea() )
	Local aAreaN9E 		:= N9E->( GetArea() )
	Local aAreaN7S 		:= N7S->( GetArea() )
	Local cCampo		:= 'DXI_ROMFLO'
	Local nY            := 0

	If Type( '_lValor') == "U" //Se não existe a variavel
		_lValor := .T. //fora da tela
	EndIF

	If _lValor //fora da tela de cadastro do romaneio
		//Busca Romaneio informado
		DbSelectArea("NJJ") //Romaneio
		NJJ->(DbSetOrder(1))
		IF NJJ->(DbSeek( xFilial("NJJ") + cCodRom ))   .AND. NJJ->NJJ_TIPO == '4' // Verifica se o Romaneio é do tipo '4' - venda
			DbSelectArea("N9E") //IE x agendamento
			N9E->(DbSetOrder(1))
			If N9E->(DbSeek( xFilial("N9E") + NJJ->NJJ_CODROM ))
				While N9E->( !Eof() ) .and. N9E->N9E_CODROM == NJJ->NJJ_CODROM //percorre N9E
					If !Empty(N9E->N9E_CODINE) //verifica se codigo da instrução de embarque esta preenchido
						DbSelectArea("N7S") //IE x Entrega
						N7S->(DbSetOrder(1))
						If N7S->(DbSeek( xFilial("N7S") + N9E->N9E_CODINE )) //posiciona no primeiro registro para pegar contrato
							DbSelectArea("NJR") //Contratos
							NJR->(DbSetOrder(1))
							If NJR->(DbSeek( xFilial("NJR") + N7S->N7S_CODCTR )) .AND. NJR->NJR_TIPO == '2'  //Verifica se o Contrato é do tipo '2' - Venda
								If NJR->NJR_TIPMER == '2' //SE EXPORTAÇÃO
									cCampo := 'DXI_ROMSAI' // "DXI_ROMSAI" - Salvar no campo DXI_ROMSAI
									Exit //sai do while N9E pois só precisa de uma IE para pegar um contrato e definir qual campo
								ELSE
									DbSelectArea("N9A") //Contratos
									N9A->(DbSetOrder(1))
									If N9A->(DbSeek( xFilial("N9A") + N7S->N7S_CODCTR + N7S->N7S_ITEM + N7S->N7S_SEQPRI ))
										While N9A->( !Eof() ) .and. N9A->N9A_CODCTR = N7S->N7S_CODCTR .AND. N9A->N9A_ITEM = N7S->N7S_ITEM .AND. N9A->N9A_SEQPRI = N7S->N7S_SEQPRI
											//SE N7S da IE não for global futura e nem venda ordem
											If (N9A->N9A_OPEFUT = '1' .OR. N9A->N9A_OPETRI = '1') .AND. EMPTY(N9A->N9A_CODROM) //SE VENDA FUTURA OU VENDA ORDEM
												cCampo := 'DXI_ROMSAI' // "DXI_ROMSAI" - Salvar no campo DXI_ROMSAI
											elseIf N9A->N9A_OPEFUT = '2' .AND. N9A->N9A_OPETRI = '2' //SE VENDA SIMPLES
												cCampo := 'DXI_ROMSAI' // "DXI_ROMSAI" - Salvar no campo DXI_ROMSAI
											EndIf
											N9A->(DbSkip())
										EndDo
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					N9E->(DbSkip())
				EndDo
			EndIf
		EndIf
	Else //dentro da tela de cadastro do romaneio
		oModel  := FwModelActive()
		oN9E    := oModel:GetModel( "N9EUNICO" )
		oNJJ    := oModel:GetModel( "NJJUNICO" )

		If oNJJ:GetValue("NJJ_TIPO") = '4'

			If oN9E:Length( .T. ) //se tiver linha ativa na grid
				For nY := 1 To oN9E:Length() //percorre toda a grid pois pode haver registros deletados
					oN9E:GoLine(nY) //posiciona na linha
					If !oN9E:IsDeleted() .AND. !Empty(oN9E:GetValue("N9E_CODINE")) //se linha não estiver deletada

						DbSelectArea("N7S") //IE x Entrega
						N7S->(DbSetOrder(1))
						If N7S->(DbSeek( xFilial("N7S") + oN9E:GetValue("N9E_CODINE") )) //posiciona no primeiro registro para pegar contrato
							DbSelectArea("NJR") //Contratos
							NJR->(DbSetOrder(1))
							If NJR->(DbSeek( xFilial("NJR") + N7S->N7S_CODCTR )) .AND. NJR->NJR_TIPO == '2'  //Verifica se o Contrato é do tipo '2' - Venda
								If NJR->NJR_TIPMER == '2' //SE EXPORTAÇÃO
									cCampo := 'DXI_ROMSAI' // "DXI_ROMSAI" - Salvar no campo DXI_ROMSAI
									Exit //sai do while N9E pois só precisa de uma IE para pegar um contrato e definir qual campo
								ELSE
									DbSelectArea("N9A") //Contratos
									N9A->(DbSetOrder(1))
									If N9A->(DbSeek( xFilial("N9A") + N7S->N7S_CODCTR + N7S->N7S_ITEM + N7S->N7S_SEQPRI ))
										While N9A->( !Eof() ) .and. N9A->N9A_CODCTR = N7S->N7S_CODCTR .AND. N9A->N9A_ITEM = N7S->N7S_ITEM .AND. N9A->N9A_SEQPRI = N7S->N7S_SEQPRI
											//SE N7S da IE não for global futura e nem venda ordem
											If (N9A->N9A_OPEFUT = '1' .OR. N9A->N9A_OPETRI = '1') .AND. EMPTY(N9A->N9A_CODROM) //SE VENDA FUTURA OU VENDA ORDEM
												cCampo := 'DXI_ROMSAI' // "DXI_ROMSAI" - Salvar no campo DXI_ROMSAI
											elseIf N9A->N9A_OPEFUT = '2' .AND. N9A->N9A_OPETRI = '2' //SE VENDA SIMPLES
												cCampo := 'DXI_ROMSAI' // "DXI_ROMSAI" - Salvar no campo DXI_ROMSAI
											EndIf
											N9A->(DbSkip())
										EndDo
									EndIf
								EndIf
							EndIf
						EndIf

					EndIf
				Next nY
				oN9E:GoLine(1) //posiciona na linha
			EndIf
		EndIf
	EndIf

	RestArea( aAreaNJR )
	RestArea( aAreaN7S )
	RestArea( aAreaN9E )
	RestArea( aAreaNJJ )
	RestArea( aAreaAtu )

Return cCampo	//"DXI_ROMFLO" - Salvar no campo DXI_ROMFLO

/** {Protheus.doc} MovFardosN9D
Função para criar a movimentação quando criar romaneios 

@return:	Nil
@author: 	felipe.mendes
@since: 	08/03/2018
*/
Static Function MovFardosN9D(lIncOrUpd,cOp)
	Local aRet
	Local dPesoF := 0
	Local dPesoI := 0

	If lIncOrUpd //Se inclusão

		//Usar o peso certificado, ou peso saida ou peso liquido
		IF DXI->DXI_PESCER > 0
			dPesoF := DXI->DXI_PESCER
		ElseIf DXI->DXI_PESSAI > 0
			dPesoF := DXI->DXI_PESSAI
		Else
			dPesoF := DXI->DXI_PSLIQU
		EndIF

		dPesoI := IIF( DXI->DXI_PSESTO > 0 , DXI->DXI_PSESTO , DXI->DXI_PSLIQU )

		DbSelectArea("N7Q")
		N7Q->(DbSetOrder(1))
		If N7Q->(DbSeek(xFilial("N7Q") + DXI->DXI_CODINE)) //Filial+Instrução Embarque
			cLocal    := N7Q->N7Q_LOCAL
			cEntidade := N7Q->N7Q_ENTENT
			cLoja     := N7Q->N7Q_LOJENT
		endIf

		cRegFis   := Posicione( "N9D", 2, DXI->DXI_FILIAL+FWxFilial("N91")+DXI->DXI_SAFRA+DXI->DXI_ETIQ+"02"+"2", "N9D_ITEREF" )

		//Array para gerar movimento do fardo N9D
		aFardos:= 	{{  {"N9D_FARDO"	,DXI->DXI_ETIQ                      },; //Etiqueta do Fardo
		{"N9D_TIPMOV"	,"05"					            },; // 05-Certificação de Peso
		{"N9D_PESINI"	,dPesoI         		            },; //Peso Ini
		{"N9D_PESFIM"	,dPesoF   		                    },; //Peso Fim
		{"N9D_PESDIF"	,dPesoF - dPesoI                 	},; //Diferença de Peso
		{"N9D_LOCAL"	,cLocal            					},; //Local
		{"N9D_ENTLOC"	,cEntidade							},; //Entidade
		{"N9D_LOJLOC"	,cLoja           					},; //Loja
		{"N9D_DATA"	    ,dDatabase 							},; //Data
		{"N9D_STATUS"	,"2"                 				},; //Status
		{"N9D_CODROM"	,DXI->DXI_ROMFLO   					},; //Romaneio
		{"N9D_CODINE"   ,DXI->DXI_CODINE       		    	},; //Instrução de Embarque
		{"N9D_ITEREF"	,cRegFis	 	        			},; //Regra Fiscal
		{"N9D_FILIAL"	,DXI->DXI_FILIAL	    			},; //Filial DO FARDO
		{"N9D_FILORG"	,FWxFilial("N91")					},; //Filial de origem do movimento do fardo
		{"N9D_SAFRA"	,DXI->DXI_SAFRA  					},; //Safra
		{"N9D_CONTNR"	,_cContainer 				        },; //Container
		{"N9D_CODFAR"	,DXI->DXI_CODIGO        			},; //Fardo
		{"N9D_BLOCO"	,DXI->DXI_BLOCO           			},; //Bloco
		{"N9D_TIPOPE"	,"1"								}}} //1-Estufagem Física

		//incluir(1) status do fardo na DXI(DXI_STATUS)
		AGRXFNSF( 1 , "EstufagIni" ) //Aguardando estufagem, esta dentro do container

		aRet := AGRMOVFARD(aFardos, 1)

	Else //Se exclusão
		DbSelectArea("N9D")
		N9D->(DbSetOrder(5))
		If N9D->(DbSeek(DXI->DXI_FILIAL+DXI->DXI_SAFRA+DXI->DXI_ETIQ+cOp+'2'))
			If !N9D->(Eof()) .AND. Reclock("N9D",.F.)

				N9D->(DbDelete())
				N9D->(MsUnlock())

				//retorna(2) status do fardo na DXI(DXI_STATUS)
				AGRXFNSF( 2 , "EstufagIni" ) //Aguardando estufagem
			EndIf
		EndIf
	EndIf
Return .T.
