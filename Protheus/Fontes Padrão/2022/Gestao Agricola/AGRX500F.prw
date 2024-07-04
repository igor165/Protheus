#INCLUDE 'TOTVS.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGRX500F.CH"

#DEFINE _CRLF CHR(13)+CHR(10)

Static __oOK	   	:= LoadBitmap(GetResources(),'LBOK')
Static __oNo     	:= LoadBitmap(GetResources(),'LBNO')
Static __lMarcAllE	:= .T.
Static __lMarcAllD	:= .T.
Static __lVldAut	:= .F.
Static __lAgra500	:= FwIsInCallStack("AGRA500")
Static __lAgra550	:= FwIsInCallStack("AGRA550") .OR. FwIsInCallStack("AGRA550_01") .OR. FwIsInCallStack("AGRA550_02") .OR. FwIsInCallStack("OGWSPUTATU")
Static __lGfea523	:= FwIsInCallStack('GFEA523') .OR. FWIsInCallStack('AX500PRFUN') //Patios e Portarias
Static __lOga250	:= FwIsInCallStack("OGA250")
Static __lOga251	:= FwIsInCallStack("OGA251")
Static __cAnaCred	:= SuperGetMv('MV_AGRB003', , .F.) // Parametro de utilização de análise de crédito

/*/{Protheus.doc} AGRX550AVF
//Funcao que exibe tela para vincular fardos no Romaneio
@author carlos.augusto/claudineia.reinert
@since 16/03/2018
@version undefined
@type function
/*/
Function AGRX500AVF(par1, par2)
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
	Local oModel			:= FwModelActive()
	Local oMldNJJ 			:= A500MdlNJJ(oModel)
	
	Private _aItsEsqd		:= {}
	Private _aItsDirt		:= {}
	Private _nPesoSel		:= 0
	Private _nQtdeSel		:= 0 //quantidade de fardos
	Private _oBrwEsqd		:= nil
	Private _oBrwDirt		:= nil
	Private _lInstEmb 		:= .F. //Indica que os fardos sao da instrucao de embarque
	Private _cCodRom 	    := par2
	Private _aIEPeso        := {}
	Private _aIEORRF 		:= {}
	
	If .not. AGRTPALGOD(M->NJJ_CODPRO)
		//"Atencao"##"Opção disponível somente para produto algodão."
		Help( ,, STR0021,,STR0063, 1, 0,) 
		Return( .F. )
	EndIf

	_cCodRom	:= oMldNJJ:GetValue("NJJ_CODROM")

	_aIEORRF := AGRX500IERF(_cCodRom, oModel)

	If oModel:GetOperation() = 4   .and. (M->( NJJ_STATUS ) $ "2|3|4") 
		//"Atenção"##"Operação não permitida para Romaneio com status "
		Help( ,, STR0021,, STR0040 + M->( NJJ_STATUS )+" - "+X3CboxDesc( "NJJ_STATUS", M->( NJJ_STATUS ) ), 1, 0,) 
		Return( .F. )
	ElseIf (oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE) 
		If GetRpoRelease() >= "12.1.027"  .and. _aIEORRF[1] == 0 //não tem IE nem regra fiscal vinculado
			Help( ,, STR0021,,STR0064, 1, 0,)  //##"Para vincular fardos é necessário que o romaneio esteja vinculado a uma instrução de embarque na aba 'Integração do Romaneio' ou a uma regra fiscal do contrato na aba 'Comercialização'. "
			Return( .F. )
		ElseiF GetRpoRelease() < "12.1.027" .AND. _aIEORRF[1] != 1 //não tem IE vinculado
			//"Atencao"##"Para vincular fardos é necessário que o romaneio esteja vinculado a uma instrução de embarque. "
			Help( ,, STR0021,,STR0039, 1, 0,) 
			Return( .F. )
		EndIf
	EndIf

	If lRet
	
		__lMarcAllD 		:= .T. //marca tudo painel direito - varivel static
		__lMarcAllE 		:= .T. //marca tudo painel esquerdo - varivel static
	
		AADD(aCombo, STR0001 ) //"Fardo"
		AADD(aCombo, STR0002 ) //"Etiqueta"
		AADD(aCombo, STR0003 ) //"Bloco"
	
		//----- TELA PARA SELECIONAR FARDOS
		//- Coordenadas da area total da Dialog
		oSize:= FWDefSize():New(.T.)
		oSize:AddObject("DLG",100,100,.T.,.T.)
		oSize:SetWindowSize(aCoors)
		oSize:lProp 	:= .T.
		oSize:aMargins := {0,0,0,0}
		oSize:Process()
	
		DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4];
		TITLE STR0004 OF oMainWnd PIXEL //"Vínculo de Fardos no Romaneio"
	
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
	
		oFWLayer:addWindow( "ESQ" , "Wnd1", IIF(_lInstEmb,STR0005 ,STR0006), 90, .F., .T.) //"Fardos da Instrução de Embarque" ou "Fardos Autorizados" 
		oFWLayer:addWindow( "DIR" , "Wnd2", STR0007, 90, .F., .T.) //"Fardos Selecionados para o Romaneio"   
	
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
		TButton():New(0,0,STR0008,oBtBarDir,{|| Pesquisa(cChavDir,Alltrim(cPesqDir),@_oBrwDirt)},Len(STR0007)*4,10,,,,.T.,,) //"Pesquisa"###'Pesquisa'
	
		_oBrwDirt := TCBrowse():New( oSize4:aPosObj[1,1], oSize4:aPosObj[1,2], oSize4:aPosObj[1,3], oSize4:aPosObj[1,4], , , , oPnl4, , , , {|| }, {|| }, , , , , , , .f., , .t., , .f., , , )
		_oBrwDirt:AddColumn( TCColumn():New(""	 , { || IIf( _aItsDirt[_oBrwDirt:nAt,1] == "1", __oOK, __oNo  ) },,,,"CENTER",010,.t.,.t.,,,,.f., ) )
		_oBrwDirt:AddColumn( TCColumn():New(STR0009 , { || _aItsDirt[_oBrwDirt:nAt,2] }									 , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Filial"
		_oBrwDirt:AddColumn( TCColumn():New(STR0013 , { || _aItsDirt[_oBrwDirt:nAt,3] }									 , , , , "LEFT" , 110, .f., .t., , , , .f., ) ) //"Instrucao de Embarque"
		_oBrwDirt:AddColumn( TCColumn():New(STR0010 , { || _aItsDirt[_oBrwDirt:nAt,4] }									 , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Safra"
		_oBrwDirt:AddColumn( TCColumn():New(STR0003 , { || _aItsDirt[_oBrwDirt:nAt,5] }									 , , , , "LEFT" , 025, .f., .t., , , , .f., ) ) //"Bloco"
		_oBrwDirt:AddColumn( TCColumn():New(STR0002 , { || _aItsDirt[_oBrwDirt:nAt,6] }									 , , , , "LEFT" , 060, .f., .t., , , , .f., ) ) //"Etiqueta"
		_oBrwDirt:AddColumn( TCColumn():New(STR0011 , { || _aItsDirt[_oBrwDirt:nAt,7] }									 , , , , "LEFT" , 025, .f., .t., , , , .f., ) ) //"Fardo"
		_oBrwDirt:AddColumn( TCColumn():New(STR0031 , { || Transform( _aItsDirt[_oBrwDirt:nAt,8], "@E 999,999,999.99" ) }, , , , "RIGHT", 050, .f., .t., , , , .f., ) ) //"Peso Bruto"
		_oBrwDirt:AddColumn( TCColumn():New(STR0012 , { || Transform( _aItsDirt[_oBrwDirt:nAt,9], "@E 999.99"  ) }		 , , , , "RIGHT", 035, .f., .t., , , , .f., ) ) //"Peso Liquido"
		_oBrwDirt:AddColumn( TCColumn():New(STR0032 , { || Transform( _aItsDirt[_oBrwDirt:nAt,10],"@E 999,999,999.99" ) }, , , , "RIGHT", 040, .f., .t., , , , .f., ) ) //"Peso Saída"
		_oBrwDirt:AddColumn( TCColumn():New(STR0033 , { || _aItsDirt[_oBrwDirt:nAt,11] }								 , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Serie NF"
		_oBrwDirt:AddColumn( TCColumn():New(STR0034 , { || _aItsDirt[_oBrwDirt:nAt,12] }								 , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Numero NF"
		_oBrwDirt:AddColumn( TCColumn():New(STR0035 , { || Transform( _aItsDirt[_oBrwDirt:nAt,13],"@E 999,999,999.99" ) }, , , , "RIGHT", 050, .f., .t., , , , .f., ) ) //"Peso Chegada"
		_oBrwDirt:AddColumn( TCColumn():New(STR0059 , { || Transform( _aItsDirt[_oBrwDirt:nAt,14],"@E 999,999,999.99" ) }, , , , "RIGHT", 050, .f., .t., , , , .f., ) ) //"Peso Estoque"
		_oBrwDirt:AddColumn( TCColumn():New(STR0014 , { || _aItsDirt[_oBrwDirt:nAt,15] }								 , , , , "LEFT" , 050, .f., .t., , , , .f., ) ) //"Contrato"
		_oBrwDirt:AddColumn( TCColumn():New(STR0015 , { || _aItsDirt[_oBrwDirt:nAt,16] }								 , , , , "LEFT" , 050, .f., .t., , , , .f., ) ) //"Id.Entrega"
		_oBrwDirt:AddColumn( TCColumn():New(STR0016 , { || _aItsDirt[_oBrwDirt:nAt,17] }								 , , , , "LEFT" , 050, .f., .t., , , , .f., ) ) //"Id.Regra"
		
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
		TButton():New(0,0, STR0008 ,oBtBarEsq,{|| Pesquisa(cChavEsq,Alltrim(cPesqEsq),@_oBrwEsqd)},Len(STR0007)*4,10,,,,.T.,,) //"Pesquisa"###'Pesquisa'
	
		_oBrwEsqd := TCBrowse():New( oSize2:aPosObj[1,1], oSize2:aPosObj[1,2], oSize2:aPosObj[1,3], oSize2:aPosObj[1,4], , , , oPnl2, , , , {|| }, {|| }, , , , , , , .f., , .t., , .f., , , )
		_oBrwEsqd:AddColumn( TCColumn():New(""	  ,  { || IIf( _aItsEsqd[_oBrwEsqd:nAt,1] == "1", __oOK, __oNo ) }       , , , , "CENTER", 010,.t.,.t.,,,,.f., ) )
		_oBrwEsqd:AddColumn( TCColumn():New(STR0009 , { || _aItsEsqd[_oBrwEsqd:nAt,2] }									 , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Filial"
		_oBrwEsqd:AddColumn( TCColumn():New(STR0013 , { || _aItsEsqd[_oBrwEsqd:nAt,3] }									 , , , , "LEFT" , 110, .f., .t., , , , .f., ) ) //"Instrucao de Embarque"
		_oBrwEsqd:AddColumn( TCColumn():New(STR0010 , { || _aItsEsqd[_oBrwEsqd:nAt,4] }									 , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Safra"
		_oBrwEsqd:AddColumn( TCColumn():New(STR0003 , { || _aItsEsqd[_oBrwEsqd:nAt,5] }									 , , , , "LEFT" , 025, .f., .t., , , , .f., ) ) //"Bloco"
		_oBrwEsqd:AddColumn( TCColumn():New(STR0002 , { || _aItsEsqd[_oBrwEsqd:nAt,6] }									 , , , , "LEFT" , 060, .f., .t., , , , .f., ) ) //"Etiqueta"
		_oBrwEsqd:AddColumn( TCColumn():New(STR0011 , { || _aItsEsqd[_oBrwEsqd:nAt,7] }									 , , , , "LEFT" , 025, .f., .t., , , , .f., ) ) //"Fardo"
		_oBrwEsqd:AddColumn( TCColumn():New(STR0031 , { || Transform( _aItsEsqd[_oBrwEsqd:nAt,8], "@E 999,999,999.99" ) }, , , , "RIGHT", 050, .f., .t., , , , .f., ) ) //"Peso Bruto"
		_oBrwEsqd:AddColumn( TCColumn():New(STR0012 , { || Transform( _aItsEsqd[_oBrwEsqd:nAt,9], "@E 999.99"  ) }		 , , , , "RIGHT", 035, .f., .t., , , , .f., ) ) //"Peso Liquido"
		_oBrwEsqd:AddColumn( TCColumn():New(STR0032 , { || Transform( _aItsEsqd[_oBrwEsqd:nAt,10],"@E 999,999,999.99" ) }, , , , "RIGHT", 040, .f., .t., , , , .f., ) ) //"Peso Saída"
		_oBrwEsqd:AddColumn( TCColumn():New(STR0033 , { || _aItsEsqd[_oBrwEsqd:nAt,11] }								 , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Serie NF"
		_oBrwEsqd:AddColumn( TCColumn():New(STR0034 , { || _aItsEsqd[_oBrwEsqd:nAt,12] }								 , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Numero NF"
		_oBrwEsqd:AddColumn( TCColumn():New(STR0035 , { || Transform( _aItsEsqd[_oBrwEsqd:nAt,13],"@E 999,999,999.99" ) }, , , , "RIGHT", 050, .f., .t., , , , .f., ) ) //"Peso Chegada"
		_oBrwEsqd:AddColumn( TCColumn():New(STR0059 , { || Transform( _aItsEsqd[_oBrwEsqd:nAt,14],"@E 999,999,999.99" ) }, , , , "RIGHT", 050, .f., .t., , , , .f., ) ) //"Peso Estoque"
		_oBrwEsqd:AddColumn( TCColumn():New(STR0014 , { || _aItsEsqd[_oBrwEsqd:nAt,15] }								 , , , , "LEFT" , 050, .f., .t., , , , .f., ) ) //"Contrato"
		_oBrwEsqd:AddColumn( TCColumn():New(STR0015 , { || _aItsEsqd[_oBrwEsqd:nAt,16] }								 , , , , "LEFT" , 050, .f., .t., , , , .f., ) ) //"Id.Entrega"
		_oBrwEsqd:AddColumn( TCColumn():New(STR0016 , { || _aItsEsqd[_oBrwEsqd:nAt,17] }								 , , , , "LEFT" , 050, .f., .t., , , , .f., ) ) //"Id.Regra"
	
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
		TButton():New( (oSize3:APOSOBJ[1][3]/2)-44, oSize3:APOSOBJ[1][1]+5, ">>" , oPnl3, {|| MovFardos( ">", @_oBrwEsqd, @_oBrwDirt ) }, oSize3:APOSOBJ[1][4]-10, 15, , /**oFont*/, , .t., , STR0017 ) //"Vincular Marcados"
		TButton():New( (oSize3:APOSOBJ[1][3]/2)-28, oSize3:APOSOBJ[1][1]+5, "<<" , oPnl3, {|| MovFardos( "<", @_oBrwEsqd, @_oBrwDirt ) }, oSize3:APOSOBJ[1][4]-10, 15, , /**oFont*/, , .t., , STR0018 ) //"Desvincular Marcados"
	
		_nQtdeSel := Len(_aItsDirt)
	
		//---------------------------------------------------------------------------------------------------
		// Apresenta calculos de peso total dos Fardos selecionados e quantidade de itens do romaneio na tela
		//---------------------------------------------------------------------------------------------------
		oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)-5,oSize3:APOSOBJ[1][1]+5,{|| Transform( STR0019 , "@!" )},oPnl3,,oFont,,; //"Quantidade"
		,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)
		oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)+5,oSize3:APOSOBJ[1][1]+5,{||  Alltrim(Transform( _nQtdeSel, '@E 99999') )},oPnl3,,oFont,,;
		,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)
		oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)+15,oSize3:APOSOBJ[1][1]+5,{|| Transform( STR0020, "@!" )},oPnl3,,oFont,,; //"Peso Total"
		,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)
		oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)+25,oSize3:APOSOBJ[1][1]+5,{||Alltrim(Transform( _nPesoSel, PesqPict('DXL','DXL_PSLIQU')) )},oPnl3,,oFont,,;
		,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)
		
		ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| nOpcA:= 1, ExecGrav(oDlg, @_aItsDirt)},{|| nOpcA:= 2, ExecCancel(oDlg) })
	EndIf
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
	Local oMldN9D 	:= A500MdlN9D(oModel)
	Local oMldN9E 	:= A500MdlN9E(oModel)
	Local oMldNJJ 	:= A500MdlNJJ(oModel)
	Local nX
	Local nPesoLiq
	Local nPesoCheg
	Local nPesoBruto
	Local cCodNF
	Local cSerieNF
	Local lValidItem := __lAgra500 .Or. __lAgra550 .Or. __lGfea523
	Local cTpAgendam := IIF(__lAgra550,'11','07')
	
	//Variavel privada. Resetar valor antes da busca dos fardos para somar corretamente.
	//Representa aquele peso que fica no meio dos grids
	_nPesoSel     := 0
	
	//Esta buscando os fardos que estao no modelo, em backgroud para posteriormente exibir na tela, atraves do array (lado direito)
	For nX := 1 to oMldN9D:Length()
		oMldN9D:GoLine( nX )
		If .Not. oMldN9D:IsDeleted() .And. .Not. Empty(oMldN9D:GetValue( "N9D_CODROM" )) .And. ;
		          IIF(lValidItem,(oMldN9E:GetValue( "N9E_SEQUEN" ) == oMldN9D:GetValue( "N9D_SEQUEN" )),1 == 1) .And. ; //Filtrar item clicado no grid
		          oMldN9D:GetValue( "N9D_TIPMOV" ) == cTpAgendam .AND. oMldN9D:GetValue( "N9D_STATUS" ) $ "1|2" 
			nCont++
	
			nPesoLiq	:= 0
			nPesoBruto  := 0
			nPesoCheg   := 0
			cCodNF      := ""
			cSerieNF    := ""

			DbSelectArea("DXI")
			DXI->(DbSetOrder(1))
			If DXI->(DbSeek(FwXFilial("DXI") + oMldN9D:GetValue( "N9D_SAFRA" ) + oMldN9D:GetValue( "N9D_FARDO" )))
				nPesoLiq	:= DXI->DXI_PSLIQU
				nPesoBruto  := DXI->DXI_PSBRUT   
				nPesoCheg   := DXI->DXI_PESCHE
			EndIf
			
			DbSelectArea("NJM")
			NJM->(DbSetOrder(7))
			//NJM_FILIAL+NJM_CODROM+NJM_CODINE+NJM_CODCTR+NJM_ITEM+NJM_SEQPRI
			If NJM->(DbSeek(FwXFilial("NJM") + oMldNJJ:GetValue( "NJJ_CODROM" ) + oMldN9D:GetValue( "N9D_CODINE" ) +;
			                oMldN9D:GetValue( "N9D_CODCTR" ) + oMldN9D:GetValue( "N9D_ITEETG" ) + oMldN9D:GetValue( "N9D_ITEREF" )))
				cCodNF   := NJM->NJM_DOCNUM
				cSerieNF := NJM->NJM_DOCSER
			EndIf
			
			/* aColsLoad = [1]Marcado, [2]Filial, [3]IE, [4]Safra, [5]Bloco, [6]Etiqueta, [7]Fardo, [8]Peso Bruto, [9]Peso Liquido,
			 			   [10]Peso Saida, [11]Serie Nf, [12]Numero NF, [13]Peso Chegada, [14]Peso Estoque, [15]Contrato,
			 			   [16]Id Entrega, [17]Id Regra */
			aAdd( aColsLoad, { "2", oMldN9D:GetValue( "N9D_FILORG" ), oMldN9D:GetValue( "N9D_CODINE" ), oMldN9D:GetValue( "N9D_SAFRA" ) ,;
			 					    oMldN9D:GetValue( "N9D_BLOCO" ) , oMldN9D:GetValue( "N9D_FARDO" ),  oMldN9D:GetValue( "N9D_CODFAR" ),;
			 					    nPesoBruto                 , nPesoLiq               , oMldN9D:GetValue( "N9D_PESFIM" ),;
			 					    cSerieNF, cCodNF, nPesoCheg,;
			 					    oMldN9D:GetValue( "N9D_PESINI" ), oMldN9D:GetValue( "N9D_CODCTR" ), oMldN9D:GetValue( "N9D_ITEETG" ),;
			 					    oMldN9D:GetValue( "N9D_ITEREF" )})
	
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
	Local oMldN9D 	:= A500MdlN9D(oModel)
	Local nX	
	Local aFardN9D  := {}
	Private _aColsLoad	:= {}
		
	If !oModel:GetOperation() == MODEL_OPERATION_VIEW
		For nX := 1 to oMldN9D:Length()
			oMldN9D:GoLine(nX)
			If .Not. oMldN9D:IsDeleted() .And. .Not. Empty(oMldN9D:GetValue("N9D_SAFRA"))
				aAdd(aFardN9D, {oMldN9D:GetValue("N9D_FILIAL"), oMldN9D:GetValue("N9D_SAFRA"), oMldN9D:GetValue("N9D_FARDO")})
			EndIf
		Next nX
		
		If __lAgra500 .Or. __lAgra550 .Or. __lGfea523
			Processa({||_aColsLoad := LDFardAut(_aColsLoad, aFardN9D)}, STR0041) //"Procurando Fardos Autorizados..."
			Processa({||_aColsLoad := LDFardBlAut(_aColsLoad, aFardN9D)}, STR0042) //"Procurando Fardos dos Blocos Autorizados..."
			If Empty(_aColsLoad) //.And. lModelEpt //Se lModelEpt estiver true e nao retornar nada, o usuario ja pegou todos os autorizados. Por isso nao exibe nada
				Processa({||_aColsLoad := LDFardIE(_aColsLoad, aFardN9D, .T.)}, STR0043) //"Não foram selecionados fardos na Autorização. Procurando Fardos da Instrução de Embarque..."
				Processa({||_aColsLoad := LDFardBlIE(_aColsLoad, aFardN9D, .T.)}, STR0044 ) //"Não foram selecionados fardos de Blocos na Autorização. Procurando fardos de Blocos da Instrução de Embarque..."
				__lVldAut := .F.
			Else
				__lVldAut := .T.
			EndIf
		Else
			Processa({||_aColsLoad := LDFardIE(_aColsLoad, aFardN9D, .F.)}, STR0045) //"Procurando Fardos da Instrução de Embarque..."
			Processa({||_aColsLoad := LDFardBlIE(_aColsLoad, aFardN9D, .F.)}, STR0046) //"Procurando fardos de Blocos da Instrução de Embarque..."	
			If Empty(_aColsLoad) .and. GetRpoRelease() >= "12.1.027" //não encontrou IE, gera pela regra fiscal na NJM
				Processa({||_aColsLoad := LDFardRegFis(_aColsLoad, aFardN9D)}, STR0065) //###Procurando Fardos pela Regra fiscal do contrato..."
				__lVldAut := .F.
			EndIf
		EndIf
		
		If .Not. Empty(_aColsLoad)
			_aColsLoad := ASort( _aColsLoad, , , { | x, y | x[2]+x[3]+x[4]+x[5]+x[6]+x[7] < y[2]+y[3]+y[4]+y[5]+y[6]+y[7]})
		EndIf
	EndIf
	RestArea(aArea)
Return(_aColsLoad)

/*/{Protheus.doc} LDFardAut
//Busca Fardos da Autorizacao de Carregamento
@author carlos.augusto
@since 18/05/2018
@version undefined
@param _aColsLoad, , descricao
@param aFardN9D, array, descricao
@type function
/*/
Static Function LDFardAut(_aColsLoad, aFardN9D)
	Local aArea	    := GetArea()
	Local oModel	:= FwModelActive()
	Local oMldN9E 	:= A500MdlN9E(oModel)
	Local oMldNJJ 	:= A500MdlNJJ(oModel)
	Local cAliasQry := ""
	Local cQry 		:= ""
	Local nCont	    := 0
	Local nX	
	Local lAdiciona := .T.
	
	cAliasQry := GetNextAlias()

	cQry := " SELECT DXI.DXI_FILIAL,DXI.DXI_PSBRUT,DXI.DXI_PSLIQU,DXI.DXI_PESCHE,DXI.DXI_PESSAI,DXI.DXI_PESCER,"
	cQry +=        "N9D.N9D_FILIAL,N9D.N9D_CODINE,N9D.N9D_ITEMAC,N9D.N9D_SAFRA,N9D.N9D_BLOCO,"
    cQry +=        "N9D.N9D_FARDO,N9D.N9D_CODFAR,N9D.N9D_PESFIM,N9D.N9D_FILORG,N9D.N9D_CODCTR,"
    cQry +=        "N9D.N9D_ITEETG,N9D.N9D_ITEREF,N9D.N9D_PESINI,NJM.NJM_DOCSER,NJM.NJM_DOCNUM "
	cQry += 	"FROM " + RetSqlName("N9D") + " N9D "
	
	cQry += 	"LEFT OUTER JOIN "+ RetSqlName("NJM") +" NJM "	
	cQry += 		"ON (NJM.D_E_L_E_T_=' ' "
	cQry += 		"AND NJM.NJM_FILIAL='" + FwXfilial("NJM") + "' "
	cQry += 		"AND NJM.NJM_CODROM='" + oMldNJJ:GetValue( "NJJ_CODROM" ) + "' " //Romaneio
	cQry += 		"AND NJM.NJM_CODINE=N9D.N9D_CODINE "
	cQry += 		"AND NJM.NJM_CODCTR=N9D.N9D_CODCTR "
	cQry += 		"AND NJM.NJM_ITEM=N9D.N9D_ITEETG "
	cQry += 		"AND NJM.NJM_SEQPRI=N9D.N9D_ITEREF) "
	
	cQry += 	"INNER JOIN "+ RetSqlName("DXI") +" DXI "
	cQry += 		"ON (DXI.D_E_L_E_T_ = ' ' "
	cQry += 		"AND DXI_FILIAL=N9D_FILIAL "
	cQry += 		"AND DXI_SAFRA=N9D_SAFRA "
	cQry += 		"AND DXI_ETIQ=N9D_FARDO "  
	cQry += 		"AND DXI_CODINE=N9D_CODINE "
	cQry += 		"AND DXI_STATUS='90') " //instruido
	cQry += 			"WHERE N9D.D_E_L_E_T_ = ' '"
	cQry += 			" AND N9D.N9D_FILIAL='" + FwXfilial("N9D") + "' "
	
	If .Not. __lAgra550//Ainda nao temos safra na tela	
		cQry +=             " AND N9D.N9D_SAFRA='" + oMldNJJ:GetValue( "NJJ_CODSAF" ) + "'" //Safra
	EndIf
	
	cQry +=             " AND N9D.N9D_CODINE='" + oMldN9E:GetValue( "N9E_CODINE" ) + "'" //Instrucao de embarque
	cQry +=             " AND N9D.N9D_ITEETG='" + oMldN9E:GetValue( "N9E_ITEM" ) + "'" //Id Entrega
	cQry +=             " AND N9D.N9D_CODCTR='" + oMldN9E:GetValue( "N9E_CODCTR" ) + "'" //Contrato
	cQry +=             " AND N9D.N9D_ITEREF='" + oMldN9E:GetValue( "N9E_SEQPRI" ) + "'" //Regra
	cQry +=             " AND N9D.N9D_TIPMOV='10' " //Autorizacao de Carregamento
	cQry +=             " AND N9D.N9D_STATUS='2' " //1=Previsto;2=Ativo;3=Inativo
	cQry += "     AND N9D.N9D_FARDO NOT IN "
	cQry += 			"(SELECT N9D2.N9D_FARDO FROM "+ RetSqlName("N9D") +" N9D2"
	cQry += 					" INNER JOIN " + RetSqlName("NJJ") + " NJJ"
	cQry +=		 				" ON (NJJ.D_E_L_E_T_ = ' '"
	cQry += 					" AND NJJ.NJJ_FILIAL='" + FwXfilial("NJJ") + "'"
	cQry += 					" AND N9D2.N9D_FILIAL='" + FwXfilial("N9D") + "'"
	cQry += 					" AND NJJ.NJJ_CODROM = N9D2.N9D_CODROM)"
	cQry += 						" WHERE N9D2.D_E_L_E_T_=' '"
	cQry += 				 			" AND N9D.N9D_SAFRA=N9D2.N9D_SAFRA"
	
	If .Not. __lAgra550//Ainda nao temos safra na tela
		cQry += " AND N9D2.N9D_TIPMOV='07' "
	Else
		cQry += " AND (N9D2.N9D_TIPMOV='07' OR N9D2.N9D_TIPMOV='11')"
	EndIf
	 
	cQry += 						" AND (N9D2.N9D_STATUS='1' OR N9D2.N9D_STATUS='2')"
	If oMldNJJ:GetValue( "NJJ_TIPO" )= '4'
		cQry += 						" AND NJJ.NJJ_TIPO = '4') "
	ElseIf oMldNJJ:GetValue( "NJJ_TIPO" )= '2'
		cQry += 						" AND NJJ.NJJ_TIPO = '2') "
	Else
		cQry += 						")"
	EndIF

	cQry += "ORDER BY N9D.N9D_CODINE,N9D.N9D_BLOCO,N9D.N9D_FARDO"

	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	

	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof()) 
		lAdiciona := .T.
		
		For nX := 1 To len(aFardN9D)
			If aFardN9D[nX][1] == (cAliasQry)->N9D_FILIAL  .And. ;
			   aFardN9D[nX][2] == (cAliasQry)->N9D_SAFRA .And. ;
			   aFardN9D[nX][3] == (cAliasQry)->N9D_FARDO
				lAdiciona := .F.
				exit
			EndIf
		Next nX

		If lAdiciona
			nCont++
				/* aColsLoad = [1]Marcado, [2]Filial, [3]IE, [4]Safra, [5]Bloco, [6]Etiqueta, [7]Fardo, [8]Peso Bruto, [9]Peso Liquido,
				 			   [10]Peso Saida, [11]Serie Nf, [12]Numero NF, [13]Peso Chegada, [14]Peso Estoque, [15]Contrato,
				 			   [16]Id Entrega, [17]Id Regra */
			aAdd( _aColsLoad, { "2",(cAliasQry)->DXI_FILIAL, (cAliasQry)->N9D_CODINE, (cAliasQry)->N9D_SAFRA ,;
			 						(cAliasQry)->N9D_BLOCO , (cAliasQry)->N9D_FARDO , (cAliasQry)->N9D_CODFAR,;
			 						(cAliasQry)->DXI_PSBRUT, (cAliasQry)->DXI_PSLIQU, (cAliasQry)->DXI_PESSAI,;
			 						(cAliasQry)->NJM_DOCSER, (cAliasQry)->NJM_DOCNUM, (cAliasQry)->DXI_PESCHE,;
			 						(cAliasQry)->N9D_PESINI, (cAliasQry)->N9D_CODCTR, (cAliasQry)->N9D_ITEETG,;
			 						(cAliasQry)->N9D_ITEREF  })								
		 EndIf
		(cAliasQry)->(DbSkip())
	End

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return(_aColsLoad)


/*/{Protheus.doc} LDFardBlAut
//Exibe fardos do bloco na Autorizacao de Carregamento
@author carlos.augusto
@since 18/05/2018
@version undefined
@param _aColsLoad, , descricao
@param aFardN9D, array, descricao
@type function
/*/
Static Function LDFardBlAut(_aColsLoad, aFardN9D)
	Local aArea	    := GetArea()
	Local oModel	:= FwModelActive()
	Local oMldN9E 	:= A500MdlN9E(oModel)
	Local oMldNJJ 	:= A500MdlNJJ(oModel)
	Local cAliasQry := ""
	Local cQry 		:= ""
	Local nCont	    := 0
	Local nX	
	Local lAdiciona := .T.
	
	cAliasQry := GetNextAlias()

	cQry := " SELECT DXI.DXI_FILIAL,DXI.DXI_CODIGO,DXI.DXI_BLOCO,DXI.DXI_PSBRUT,DXI.DXI_PSLIQU,"
	cQry +=        "DXI.DXI_SAFRA,DXI.DXI_ETIQ,DXI.DXI_PESSAI,DXI.DXI_PSESTO,DXI.DXI_PESCHE, "
	cQry +=        "DXI.DXI_CODINE,N8O.N8O_CODCTR,N8O.N8O_IDENTR,N8O.N8O_IDREGR,NJM.NJM_DOCSER,NJM.NJM_DOCNUM "
	cQry += 	"FROM " + RetSqlName("DXI") + " DXI "
	cQry += 	"INNER JOIN  " + RetSqlName("DXD") + " DXD  "
	cQry += 		" ON (DXD.D_E_L_E_T_ =' '"
	cQry += 		" AND DXD.DXD_FILIAL='" + FwXfilial("DXD") + "'" 
	cQry += 		" AND DXD.DXD_SAFRA='" + oMldNJJ:GetValue( "NJJ_CODSAF" ) + "'
	cQry += 		" AND DXD.DXD_CODIGO=DXI.DXI_BLOCO) "
	cQry += 	"INNER JOIN " + RetSqlName("N83") + " N83 "
	cQry += 		" ON (N83.D_E_L_E_T_= ' '"
	cQry += 		" AND N83.N83_FILIAL='" + FwXfilial("N83") + "'" 
	cQry += 		" AND N83.N83_SAFRA=DXD.DXD_SAFRA"
	cQry += 		" AND N83.N83_BLOCO=DXD.DXD_CODIGO)"
	cQry += 	"INNER JOIN " + RetSqlName("N8P") + " N8P  "
	cQry += 		" ON (N8P.D_E_L_E_T_=' '"
	cQry += 		" AND N8P.N8P_FILIAL= '" + FwXfilial("N8P") + "'" 
	cQry += 		" AND N8P.N8P_SAFRA=DXD.DXD_SAFRA"
	cQry += 		" AND N8P.N8P_BLOCO=DXD.DXD_CODIGO) "
	
	cQry += 	"LEFT OUTER JOIN "+ RetSqlName("NJM") +" NJM "	
	cQry += 		"ON (NJM.D_E_L_E_T_=' ' "
	cQry += 		"AND NJM.NJM_FILIAL='" + FwXfilial("NJM") + "' " 
	cQry += 		"AND NJM.NJM_CODROM='" + oMldNJJ:GetValue( "NJJ_CODROM" ) + "') " //Romaneio		
	
	cQry += 	"INNER JOIN " + RetSqlName("N8O") + " N8O"
	cQry += 		" ON (N8O.D_E_L_E_T_ = ' '"
	cQry += 		" AND N8O.N8O_FILIAL='" + FwXfilial("N8O") + "'" 
	cQry += 		" AND N8O.N8O_CODAUT='" + oMldN9E:GetValue( "N9E_CODAUT" ) + "'" 
	cQry += 		" AND N8O.N8O_ITEM='" + oMldN9E:GetValue( "N9E_ITEMAC" ) + "')" 
	cQry += 			" WHERE DXI.D_E_L_E_T_=' '"
	cQry += 		      " AND DXI.DXI_FILIAL='" + FwXfilial("DXI") + "'"
	cQry += 			  " AND DXI.DXI_SAFRA=N83.N83_SAFRA"
	cQry += 			  " AND DXI.DXI_BLOCO=N83.N83_BLOCO"
	cQry += 			  " AND DXI.DXI_STATUS IN ('30','70','80') " //70(take-up) e 80(global Futura) , 30 provisorio ate implementar status fardo no take-up
	
	cQry += 			  " AND N8O.N8O_CODINE='" + oMldN9E:GetValue( "N9E_CODINE" ) + "'"
	cQry += 			  " AND N8P.N8P_QTDAUT > 0"
	cQry += 			  " AND DXI.DXI_ETIQ NOT IN "
    cQry += 			  		" (SELECT N9D2.N9D_FARDO "
    cQry += 			  		" FROM " + RetSqlName("N9D") + " N9D2 "
    cQry += 			 		" WHERE N9D2.D_E_L_E_T_= ' '"
    cQry += 			  		" AND N9D2.N9D_FILIAL='" + FwXfilial("N9D") + "'"
    cQry += 			  		" AND DXI.DXI_SAFRA= N9D2.N9D_SAFRA"
    cQry += 			  		" AND N9D2.N9D_TIPMOV= '07'"
    cQry += 			  		" AND N9D2.N9D_STATUS= '1')"
    
    cQry += 			  " AND DXI.DXI_BLOCO NOT IN" 
    cQry += 			  		" (SELECT N9D3.N9D_BLOCO "
    cQry += 			  		" FROM " + RetSqlName("N9D") + " N9D3 "
    cQry += 			  		" WHERE N9D3.D_E_L_E_T_= ' '"
    cQry += 			  		" AND N9D3.N9D_FILIAL = '" + FwXfilial("N9D") + "'"
    cQry += 			  		" AND DXI.DXI_SAFRA=N9D3.N9D_SAFRA"
    cQry += 			  		" AND N9D3.N9D_TIPMOV='10'"
    cQry += 			  		" AND N9D3.N9D_STATUS='2')"

	cQry += "ORDER BY N8O.N8O_CODINE,DXI.DXI_BLOCO,DXI.DXI_ETIQ "

	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	

	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof()) 
		lAdiciona := .T.
		
		For nX := 1 To len(aFardN9D)
			If aFardN9D[nX][1] == (cAliasQry)->DXI_FILIAL .And. ;
			   aFardN9D[nX][2] == (cAliasQry)->DXI_SAFRA .And. ;
			   aFardN9D[nX][3] == (cAliasQry)->DXI_ETIQ
				lAdiciona := .F.
				exit
			EndIf
		Next nX

		If lAdiciona
			nCont++
									
				/* aColsLoad = [1]Marcado, [2]Filial, [3]IE, [4]Safra, [5]Bloco, [6]Etiqueta, [7]Fardo, [8]Peso Bruto, [9]Peso Liquido,
				 			   [10]Peso Saida, [11]Serie Nf, [12]Numero NF, [13]Peso Chegada, [14]Peso Estoque, [15]Contrato,
				 			   [16]Id Entrega, [17]Id Regra */
			aAdd( _aColsLoad, { "2", (cAliasQry)->DXI_FILIAL,(cAliasQry)->DXI_CODINE, (cAliasQry)->DXI_SAFRA ,;
			 						(cAliasQry)->DXI_BLOCO , (cAliasQry)->DXI_ETIQ  , (cAliasQry)->DXI_CODIGO,;
			 						(cAliasQry)->DXI_PSBRUT, (cAliasQry)->DXI_PSLIQU, (cAliasQry)->DXI_PESSAI,;
			 						(cAliasQry)->NJM_DOCSER, (cAliasQry)->NJM_DOCNUM, (cAliasQry)->DXI_PESCHE,;
			 						(cAliasQry)->DXI_PSESTO, (cAliasQry)->N8O_CODCTR, (cAliasQry)->N8O_IDENTR,;
			 						(cAliasQry)->N8O_IDREGR  })								
		 EndIf
		(cAliasQry)->(DbSkip())
	End

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return(_aColsLoad)



/*/{Protheus.doc} LDFardBlIE
//Exibe fardos do bloco na IE
@author carlos.augusto
@since 18/05/2018
@version undefined
@param _aColsLoad, , descricao
@param aFardN9D, array, descricao
@param lAutorizacao, logical, descricao
@type function
/*/
Static Function LDFardBlIE(_aColsLoad, aFardN9D, lAutorizacao)
	Local aArea	    := GetArea()
	Local oModel	:= FwModelActive()
	Local oMldN9E 	:= A500MdlN9E(oModel)
	Local oMldNJJ 	:= A500MdlNJJ(oModel)
	Local cAliasQry := ""
	Local cQry 		:= ""
	Local nCont	    := 0
	Local nX	
	Local aCodines	:= {}
	Local lAdiciona := .T.	
	Local nLinha 	:= 0
	
	If .Not. lAutorizacao
		nLinha := oMldN9E:GetLine()
		For nX := 1 to oMldN9E:Length()
			oMldN9E:GoLine(nX)
			If .Not. oMldN9E:IsDeleted()
				If .Not. Empty(oMldN9E:GetValue("N9E_CODINE"))
					aAdd( aCodines, oMldN9E:GetValue("N9E_CODINE"))
				EndIf
			EndIf
		Next nX
		oMldN9E:GoLine(nLinha)
	EndIf

	cAliasQry := GetNextAlias()
	cQry := " SELECT DXI.DXI_FILIAL,DXI.DXI_CODIGO,DXI.DXI_BLOCO,DXI.DXI_PSBRUT,DXI.DXI_PSLIQU,"
	cQry +=        "DXI.DXI_SAFRA,DXI.DXI_ETIQ,DXI.DXI_PESSAI,DXI.DXI_PSESTO,DXI.DXI_PESCHE,"
	cQry +=        "DXI.DXI_CODINE,N83.N83_CODCTR,N83.N83_ITEM,N83.N83_ITEREF,NJM.NJM_DOCSER,NJM.NJM_DOCNUM "
	cQry += 	"FROM " + RetSqlName("DXI") + " DXI "
	
	cQry += 	" INNER JOIN " + RetSqlName("DXD") + " DXD "
	cQry += 		" ON (DXD.D_E_L_E_T_ = ' '"
	cQry += 	" AND DXD.DXD_FILIAL='" + FwXfilial("DXD") + "'" 
	cQry += 	" AND DXD.DXD_SAFRA=DXI.DXI_SAFRA"
	cQry += 	" AND DXD.DXD_CODIGO=DXI.DXI_BLOCO) "
	
	cQry += 	"INNER JOIN  " + RetSqlName("N83") + " N83 "
	cQry += 		" ON (N83.D_E_L_E_T_=' '"
	cQry += 		" AND N83.N83_FILIAL='" + FwXfilial("N83") + "' " 
	cQry += 		" AND N83.N83_SAFRA=DXD.DXD_SAFRA"
	cQry += 		" AND N83.N83_BLOCO=DXD.DXD_CODIGO"
	cQry += 		" AND N83.N83_FILORG=DXI.DXI_FILIAL)"
	
	cQry += 	" INNER JOIN " + RetSqlName("DXP") + " DXP ON (DXP.D_E_L_E_T_ = '' " 
	cQry += 		" AND DXP_FILIAL='" + FwXfilial("DXP") + "' "
	cQry += 		" AND DXP_CODCTP=N83_CODCTR"
	cQry += 		" AND DXP_ITECAD=N83_ITEM"
	cQry += 		" AND DXP_CODIGO=DXI_CODRES)"
	
	cQry += 	"LEFT OUTER JOIN "+ RetSqlName("NJM") +" NJM "	
	cQry += 		"ON (NJM.D_E_L_E_T_=' ' "
	cQry += 		"AND NJM.NJM_FILIAL='" + FwXfilial("NJM") + "' "
	cQry += 		"AND NJM.NJM_CODROM='" + oMldNJJ:GetValue( "NJJ_CODROM" ) + "') " //Romaneio	
	cQry += 		"AND NJM.NJM_CODCTR=N83.N83_CODCTR AND NJM.NJM_ITEM = N83.N83_ITEM AND NJM.NJM_SEQPRI = N83.N83_ITEREF "	
	
	cQry += 			" WHERE DXI.D_E_L_E_T_ = ' '"
	cQry += 			  " AND DXI.DXI_FILIAL= '" + FwXfilial("DXI") + "'" 
	cQry += 			  " AND DXI.DXI_SAFRA=N83.N83_SAFRA"
	cQry += 			  " AND DXI.DXI_BLOCO=N83.N83_BLOCO"
	cQry += 			  " AND DXI.DXI_STATUS IN ('30','70','80') " //70(take-up) e 80(global Futura) , 30 provisorio ate implementar status fardo no take-up
	
	If lAutorizacao
		cQry += 			  " AND N83.N83_CODINE='" + oMldN9E:GetValue( "N9E_CODINE" ) + "' "	
		cQry += 			  " AND N83.N83_ITEM='" + oMldN9E:GetValue( "N9E_ITEM" ) + "' "
	Else
		For nX := 1 to Len( aCodines )
			If nX == 1
				cQry += " AND("
			Else
				cQry += " OR "
			EndIf
			cQry +=             "N83.N83_CODINE='" + aCodines[nX] + "' " //Instrucao de embarque
			If nX == Len( aCodines )
				cQry += " )"
			EndIf
		Next nX
	EndIf
	cQry += 			  " AND N83.N83_FRDMAR = '2'"
	cQry += 			  " AND DXI.DXI_CODINE = ''"
	cQry += 			  " AND DXI.DXI_ETIQ NOT IN "
    cQry += 					" (SELECT N9D2.N9D_FARDO "
    cQry += 						" FROM " + RetSqlName("N9D") + " N9D2 " 
    cQry += 						" WHERE N9D2.D_E_L_E_T_ = ' '"
    cQry += 						   " AND DXI.DXI_SAFRA=N9D2.N9D_SAFRA"
    cQry += 						   " AND N9D2.N9D_TIPMOV='07'"
    cQry += 						   " AND N9D2.N9D_STATUS='1') "

	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	

	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof()) 
	
		lAdiciona := .T.
		
		For nX := 1 To len(aFardN9D)
			If aFardN9D[nX][1] == (cAliasQry)->DXI_FILIAL .And. ;
			   aFardN9D[nX][2] == (cAliasQry)->DXI_SAFRA .And. ;
			   aFardN9D[nX][3] == (cAliasQry)->DXI_ETIQ
				lAdiciona := .F.
				exit
			EndIf
		Next nX

		If lAdiciona
			nCont++
				/* _aColsLoad = [1]Marcado, [2]Filial, [3]IE, [4]Safra, [5]Bloco, [6]Etiqueta, [7]Fardo, [8]Peso Bruto, [9]Peso Liquido,
				 			   [10]Peso Saida, [11]Serie Nf, [12]Numero NF, [13]Peso Chegada, [14]Peso Estoque, [15]Contrato,
				 			   [16]Id Entrega, [17]Id Regra */
			aAdd( _aColsLoad, { "2", (cAliasQry)->DXI_FILIAL,(cAliasQry)->DXI_CODINE, (cAliasQry)->DXI_SAFRA ,;
			 						(cAliasQry)->DXI_BLOCO , (cAliasQry)->DXI_ETIQ  , (cAliasQry)->DXI_CODIGO,;
			 						(cAliasQry)->DXI_PSBRUT, (cAliasQry)->DXI_PSLIQU, (cAliasQry)->DXI_PESSAI,;
			 						(cAliasQry)->NJM_DOCSER, (cAliasQry)->NJM_DOCNUM, (cAliasQry)->DXI_PESCHE,;
			 						(cAliasQry)->DXI_PSESTO, (cAliasQry)->N83_CODCTR, (cAliasQry)->N83_ITEM,;
			 						(cAliasQry)->N83_ITEREF  })								
		 EndIf
		(cAliasQry)->(DbSkip())
	End

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return(_aColsLoad)

/*/{Protheus.doc} LDFardIE
//Fardos relacionados a IE
@author carlos.augusto
@since 18/05/2018
@version undefined
@param _aColsLoad, , descricao
@param aFardN9D, array, descricao
@param lAutorizacao, logical, descricao
@type function
/*/
Static Function LDFardIE(_aColsLoad, aFardN9D, lAutorizacao)
	Local aArea	    := GetArea()
	Local oModel	:= FwModelActive()
	Local oMldN9E 	:= A500MdlN9E(oModel)
	Local oMldNJJ 	:= A500MdlNJJ(oModel)
	Local cAliasQry := ""
	Local cQry 		:= ""
	Local nCont	    := 0
	Local nX	
	Local lNotIn	:= .F.
	Local aCodines	:= {}
	Local lAdiciona := .T.
	Local nLinha	:= 0
	
	If .Not. lAutorizacao
		nLinha := oMldN9E:GetLine()
		For nX := 1 to oMldN9E:Length()
			oMldN9E:GoLine(nX)
			If .Not. oMldN9E:IsDeleted()
				If .Not. Empty(oMldN9E:GetValue("N9E_CODINE"))
					aAdd( aCodines, oMldN9E:GetValue("N9E_CODINE"))
				EndIf
			EndIf
		Next nX
		oMldN9E:GoLine(nLinha)
	EndIf

	If LEN(aCodines) > 0 .or. (lAutorizacao .and. !Empty(oMldN9E:GetValue("N9E_CODINE")))

		cAliasQry := GetNextAlias()
		lNotIn	:= .F.

		cQry := " SELECT DXI.DXI_FILIAL,DXI.DXI_PSBRUT,DXI.DXI_PSLIQU,DXI.DXI_PESCHE,DXI.DXI_PESSAI,DXI.DXI_PESCER,"
		cQry +=         "N9D.N9D_FILIAL,N9D.N9D_CODINE,N9D.N9D_ITEMAC,N9D.N9D_SAFRA,N9D.N9D_BLOCO,"
		cQry +=         "N9D.N9D_FARDO,N9D.N9D_CODFAR,N9D.N9D_PESFIM,N9D.N9D_FILORG,N9D.N9D_CODCTR,"
		cQry +=         "N9D.N9D_ITEETG,N9D.N9D_ITEREF,N9D.N9D_PESINI,NJM.NJM_DOCSER,NJM.NJM_DOCNUM "
		
		cQry +=	" FROM " + RetSqlName("N9D") + " N9D "
		
		cQry += " LEFT OUTER JOIN "+ RetSqlName("NJM") +" NJM "	
		cQry += 		"ON (NJM.D_E_L_E_T_=' ' "
		cQry += 		"AND NJM.NJM_FILIAL='" + FwXfilial("NJM") + "' "
		cQry += 		"AND NJM.NJM_CODROM='" + oMldNJJ:GetValue( "NJJ_CODROM" ) + "') " //Romaneio		
		cQry += 		"AND NJM.NJM_CODCTR=N9D.N9D_CODCTR AND NJM.NJM_ITEM=N9D.N9D_ITEETG AND NJM.NJM_SEQPRI=N9D.N9D_ITEREF "
		
		cQry += " INNER JOIN "+ RetSqlName("DXI") +" DXI "
		cQry += 		"ON (DXI.D_E_L_E_T_=' ' " 
		cQry += 		"AND DXI_FILIAL=N9D_FILIAL "
		cQry += 		"AND DXI_SAFRA=N9D_SAFRA "
		cQry += 		"AND DXI_ETIQ=N9D_FARDO "  
		cQry += 		"AND DXI_CODINE=N9D_CODINE ) "
		
		cQry += " WHERE N9D.D_E_L_E_T_=' ' "
		cQry += " AND N9D.N9D_FILIAL='" + FwXfilial("N9D") + "' "
		
		If .Not. __lAgra550//Ainda nao temos safra na tela
			cQry += " AND N9D.N9D_SAFRA='" + oMldNJJ:GetValue( "NJJ_CODSAF" ) + "' " //Safra
		EndIf
		
		If lAutorizacao
			cQry += " AND N9D.N9D_CODINE='" + oMldN9E:GetValue( "N9E_CODINE" ) + "' " //Instrucao de Embarque
			cQry += " AND N9D.N9D_ITEETG='" + oMldN9E:GetValue( "N9E_ITEM" ) + "' " //Id Entrega
			cQry += " AND N9D.N9D_CODCTR='" + oMldN9E:GetValue( "N9E_CODCTR" ) + "' " //Contrato
			cQry += " AND N9D.N9D_ITEREF='" + oMldN9E:GetValue( "N9E_SEQPRI" ) + "' " //Regra
		Else
			For nX := 1 to Len( aCodines )
				If nX == 1
					cQry += " AND ("
				Else
					cQry += " OR "
				EndIf
				cQry +=             "N9D.N9D_CODINE='" + aCodines[nX] + "' " //Instrucao de embarque
				If nX == Len( aCodines )
					cQry += " ) "
				EndIf
			Next nX
		EndIf
		cQry += " AND N9D.N9D_TIPMOV='04' " //INSTRUÇÃO DE EMBARQUE
		cQry += " AND N9D.N9D_STATUS='2' " //1=Previsto;2=Ativo;3=Inativo

		//Se ja esta em outro romaneio, nao exibe
		cQry += " AND N9D.N9D_FARDO NOT IN "
		cQry += 		" ( SELECT N9D2.N9D_FARDO FROM "+ RetSqlName("N9D") +" N9D2 "
		cQry += 		" INNER JOIN " + RetSqlName("NJM") + " NJM "
		cQry +=	 			" ON ( NJM.D_E_L_E_T_ = ' '"
		cQry +=				" AND NJM.NJM_FILIAL='" + FwXfilial("NJM") + "' "
		cQry +=				" AND N9D2.N9D_FILIAL='" + FwXfilial("N9D") + "' "
		cQry += 			" AND NJM.NJM_CODROM = N9D2.N9D_CODROM ) "
		cQry +=			" WHERE N9D2.D_E_L_E_T_=' ' "
		cQry +=			" AND N9D2.N9D_SAFRA = N9D.N9D_SAFRA "
		cQry +=			" AND N9D2.N9D_CODROM <> '"+ oMldNJJ:GetValue( "NJJ_CODROM" ) +"' "
		
		If .Not. __lAgra550//Ainda nao temos safra na tela
			cQry +=		" AND N9D2.N9D_TIPMOV='07' "
		Else
			cQry +=		" AND (N9D2.N9D_TIPMOV='07' OR N9D2.N9D_TIPMOV='11') "
		EndIf
		
		cQry += 		" AND (N9D2.N9D_STATUS='1' OR N9D2.N9D_STATUS='2') "
		cQry += 		" AND NJM_SUBTIP NOT IN ('43','49') "
		If oMldNJJ:GetValue( "NJJ_TIPO" ) = '4'
			cQry += 	" AND NJM.NJM_TIPO = '4') "
		ElseIf oMldNJJ:GetValue( "NJJ_TIPO" ) = '2'
			cQry += 	" AND NJM.NJM_TIPO = '2') "
		Else
			cQry += 	" ) "
		EndIF
		
		//Nao posso mostrar os fardos da IE se esta IE teve algum fardo que ja foi autorizado
		cQry += " AND N9D.N9D_CODINE NOT IN "
		cQry += 		" ( SELECT N9D3.N9D_CODINE FROM "+ RetSqlName("N9D") +" N9D3 WHERE "
		cQry += 		" N9D3.N9D_SAFRA=N9D.N9D_SAFRA " //Safra

		If lAutorizacao
			cQry += 	" AND N9D3.N9D_CODINE='" + oMldN9E:GetValue( "N9E_CODINE" ) + "' " //Instrucao de Embarque
			cQry += 	" AND N9D3.N9D_ITEETG='" + oMldN9E:GetValue( "N9E_ITEM" ) + "' " //Id Entrega
			cQry += 	" AND N9D3.N9D_CODCTR='" + oMldN9E:GetValue( "N9E_CODCTR" ) + "' " //Contrato
			cQry += 	" AND N9D3.N9D_ITEREF='" + oMldN9E:GetValue( "N9E_SEQPRI" ) + "' " //Regra
		Else
			For nX := 1 to Len( aCodines )
				If nX == 1
					cQry += " AND("
				Else
					cQry += " OR "
				EndIf
				cQry +=             "N9D3.N9D_CODINE='" + aCodines[nX] + "' " //Instrucao de embarque
				If nX == Len( aCodines )
					cQry += " )"
				EndIf
			Next nX
		EndIf
		cQry += 	" AND N9D3.N9D_TIPMOV='10' " //Instrucao de embarque
		cQry += 	" AND N9D3.N9D_STATUS='2' " //1=Previsto;2=Ativo;3=Inativo
		cQry += 	" AND N9D3.D_E_L_E_T_=' ' ) "

		cQry += " ORDER BY N9D.N9D_CODINE,N9D.N9D_BLOCO,N9D.N9D_FARDO "

		cQry := ChangeQuery( cQry )	
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	

		dbSelectArea(cAliasQry)
		dbGoTop()
		While (cAliasQry)->(!Eof()) 
		
			lAdiciona := .T.
			
			For nX := 1 To len(aFardN9D)
				If aFardN9D[nX][1] == (cAliasQry)->N9D_FILIAL .And. ;
				aFardN9D[nX][2] == (cAliasQry)->N9D_SAFRA .And. ;
				aFardN9D[nX][3] == (cAliasQry)->N9D_FARDO
					lAdiciona := .F.
					exit
				EndIf
			Next nX

			If lAdiciona
				_lInstEmb := .T.
				nCont++
				aAdd( _aColsLoad, { "2",(cAliasQry)->DXI_FILIAL, (cAliasQry)->N9D_CODINE, (cAliasQry)->N9D_SAFRA ,;
										(cAliasQry)->N9D_BLOCO , (cAliasQry)->N9D_FARDO , (cAliasQry)->N9D_CODFAR,;
										(cAliasQry)->DXI_PSBRUT, (cAliasQry)->DXI_PSLIQU, (cAliasQry)->DXI_PESSAI,;
										(cAliasQry)->NJM_DOCSER, (cAliasQry)->NJM_DOCNUM, (cAliasQry)->DXI_PESCHE,;
										(cAliasQry)->DXI_PESCER, (cAliasQry)->N9D_CODCTR, (cAliasQry)->N9D_ITEETG,;
										(cAliasQry)->N9D_ITEREF  })
			EndIf						
									
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	EndIf
	RestArea(aArea)
Return(_aColsLoad)
/*/{Protheus.doc} LDFardRegFis
//Fardos relacionados a IE
@author claudineia.reinert	
@since 01/06/2020
@version undefined
@param _aColsLoad, , descricao
@param aFardN9D, array, descricao
@type function
/*/
Static Function LDFardRegFis(_aColsLoad, aFardN9D)
	Local aArea	    := GetArea()
	Local oModel	:= FwModelActive()
	Local oMldNJM 	:= A500MdlNJM(oModel)
	Local oMldNJJ 	:= A500MdlNJJ(oModel)
	Local cAliasQry := ""
	Local cQry 		:= ""
	Local nCont	    := 0
	Local nX		:= 0	
	Local aCodRegFis	:= {}
	Local lAdiciona := .T.
	Local nLinha	:= 0
	
	nLinha := oMldNJM:GetLine()
	For nX := 1 to oMldNJM:Length()
		oMldNJM:GoLine(nX)
		If .Not. oMldNJM:IsDeleted() 
			If !Empty(oMldNJM:GetValue("NJM_CODCTR")) .AND. !Empty(oMldNJM:GetValue("NJM_ITEM")) .AND. !Empty(oMldNJM:GetValue("NJM_SEQPRI"))
				aAdd( aCodRegFis, {oMldNJM:GetValue("NJM_CODCTR"),oMldNJM:GetValue("NJM_ITEM"),oMldNJM:GetValue("NJM_SEQPRI")})
			EndIf
		EndIf
	Next nX
	oMldNJM:GoLine(nLinha)

	If LEN(aCodRegFis) > 0 
	
		cAliasQry := GetNextAlias()
		
		cQry := " SELECT DISTINCT DXI.DXI_FILIAL,DXI.DXI_PSBRUT,DXI.DXI_PSLIQU,DXI.DXI_PESCHE,DXI.DXI_PESSAI,DXI.DXI_PESCER,"
		cQry +=         "N9D.N9D_FILIAL,N9D.N9D_CODINE,N9D.N9D_ITEMAC,N9D.N9D_SAFRA,N9D.N9D_BLOCO,"
		cQry +=         "N9D.N9D_FARDO,N9D.N9D_CODFAR,N9D.N9D_PESFIM,N9D.N9D_FILORG,N9D.N9D_CODCTR,"
		cQry +=         "N9D.N9D_ITEETG,N9D.N9D_ITEREF,N9D.N9D_PESINI,NJM.NJM_DOCSER,NJM.NJM_DOCNUM "
		cQry += 	"FROM " + RetSqlName("N9D") + " N9D "
		
		cQry += 	"LEFT OUTER JOIN "+ RetSqlName("NJM") +" NJM "	
		cQry += 		"ON (NJM.D_E_L_E_T_=' ' "
		cQry += 		"AND NJM.NJM_FILIAL='" + FwXfilial("NJM") + "' "
		cQry += 		"AND NJM.NJM_CODROM='" + oMldNJJ:GetValue( "NJJ_CODROM" ) + "') " //Romaneio		
		cQry += 		"AND NJM.NJM_CODCTR=N9D.N9D_CODCTR AND NJM.NJM_ITEM=N9D.N9D_ITEETG AND NJM.NJM_SEQPRI=N9D.N9D_ITEREF "
		
		cQry += 	"INNER JOIN "+ RetSqlName("DXI") +" DXI "
		cQry += 		"ON (DXI.D_E_L_E_T_=' ' " 
		cQry += 		"AND DXI_FILIAL=N9D_FILIAL "
		cQry += 		"AND DXI_SAFRA=N9D_SAFRA "
		cQry += 		"AND DXI_ETIQ=N9D_FARDO "  
		cQry += 		"AND DXI_CODINE='' "
		cQry += 		"AND DXI_STATUS in ('70','80') ) "
		
		cQry += 			"WHERE N9D.D_E_L_E_T_=' '"
		cQry += 			" AND N9D.N9D_FILIAL='" + FwXfilial("N9D") + "' "
		
		cQry +=             " AND N9D.N9D_SAFRA='" + oMldNJJ:GetValue( "NJJ_CODSAF" ) + "'" //Safra
		
		For nX := 1 to Len( aCodRegFis )
			If nX == 1
				cQry += " AND (("
			Else
				cQry += " OR ("
			EndIf
			cQry +=             "N9D.N9D_CODCTR='" + aCodRegFis[nX][1] + "' " //CODIGO CONTRATO
			cQry +=             " AND N9D.N9D_ITEETG='" + aCodRegFis[nX][2] + "' " //ITEM DA ENTREGA/CADENCIA
			cQry +=             " AND N9D.N9D_ITEREF='" + aCodRegFis[nX][3] + "' )" //ITEM REGRA FISCAL
			If nX == Len( aCodRegFis )
				cQry += " )"
			EndIf
		Next nX

		cQry += " AND N9D.N9D_TIPMOV='02'" //TAKE-UP
		cQry += " AND N9D.N9D_STATUS='2'" //1=Previsto;2=Ativo;3=Inativo

		//Se ja esta em outro romaneio, nao exibe
		cQry += 	" AND N9D.N9D_FARDO NOT IN "
		cQry += 			"(SELECT N9D2.N9D_FARDO FROM "+ RetSqlName("N9D") +" N9D2"
		cQry += 					" INNER JOIN " + RetSqlName("NJM") + " NJM"
		cQry +=		 				" ON (NJM.D_E_L_E_T_ = ' '"
		cQry += 					" AND NJM.NJM_FILIAL='" + FwXfilial("NJM") + "'"
		cQry += 					" AND NJM.NJM_CODROM = N9D2.N9D_CODROM)"
		cQry += 						" WHERE N9D2.D_E_L_E_T_=' '"
		cQry += 					"     AND N9D2.N9D_FILIAL='" + FwXfilial("N9D") + "'"
		cQry += 				 	"     AND N9D.N9D_SAFRA=N9D2.N9D_SAFRA"
		
		cQry += 					"     AND (N9D2.N9D_TIPMOV='07' OR N9D2.N9D_TIPMOV='11')"
		
		cQry += 					"     AND (N9D2.N9D_STATUS='1' OR N9D2.N9D_STATUS='2')"
		cQry += 					"     AND NJM_SUBTIP NOT IN ('43','49') "
		If oMldNJJ:GetValue( "NJJ_TIPO" )= '4'
			cQry += 				"     AND NJM.NJM_TIPO = '4') "
		ElseIf oMldNJJ:GetValue( "NJJ_TIPO" )= '2'
			cQry += 				"     AND NJM.NJM_TIPO = '2') "
		Else
			cQry += 				")"
		EndIF
		
		cQry += "ORDER BY N9D.N9D_CODINE,N9D.N9D_BLOCO,N9D.N9D_FARDO"

		cQry := ChangeQuery( cQry )	
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	

		dbSelectArea(cAliasQry)
		dbGoTop()
		While (cAliasQry)->(!Eof()) 
		
			lAdiciona := .T.
			
			For nX := 1 To len(aFardN9D)
				If aFardN9D[nX][1] == (cAliasQry)->N9D_FILIAL .And. ;
				aFardN9D[nX][2] == (cAliasQry)->N9D_SAFRA .And. ;
				aFardN9D[nX][3] == (cAliasQry)->N9D_FARDO
					lAdiciona := .F.
					exit
				EndIf
			Next nX

			If lAdiciona
				_lInstEmb := .F.
				nCont++
				aAdd( _aColsLoad, { "2",(cAliasQry)->DXI_FILIAL, (cAliasQry)->N9D_CODINE, (cAliasQry)->N9D_SAFRA ,;
										(cAliasQry)->N9D_BLOCO , (cAliasQry)->N9D_FARDO , (cAliasQry)->N9D_CODFAR,;
										(cAliasQry)->DXI_PSBRUT, (cAliasQry)->DXI_PSLIQU, (cAliasQry)->DXI_PESSAI,;
										(cAliasQry)->NJM_DOCSER, (cAliasQry)->NJM_DOCNUM, (cAliasQry)->DXI_PESCHE,;
										(cAliasQry)->DXI_PESCER, (cAliasQry)->N9D_CODCTR, (cAliasQry)->N9D_ITEETG,;
										(cAliasQry)->N9D_ITEREF  })
			EndIf						
									
			(cAliasQry)->(DbSkip())
		End
		(cAliasQry)->(DbCloseArea())
	EndIf
	RestArea(aArea)
Return(_aColsLoad)


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


/*/{Protheus.doc} MovFardos
//Movimenta fardos
@author carlos.augusto
@since 18/05/2018
@version undefined
@param cSeta, characters, descricao
@param oBrwEsq, object, descricao
@param oBrwDir, object, descricao
@type function
/*/
Static Function MovFardos( cSeta, oBrwEsq, oBrwDir )
	Local oModel   := FwModelActive() 
	Local aItsOrig := {}
	Local aItsDest := {}
	Local nX	   := 0 
	Local lRet	   := .T.
	Local lMarc	   := .F.
	Local cBlcMarc := "" //selecionado fardos("1") ou digitado quantidade("2")
	Local nQtdBlc  := 0
	Local nI       := 0
	Local nY       := 0
	Local lAchou   := .F.
	Local aIEs     := {}
	Local nFrds    := 1
	Local aBlcErr  := {}
	Local cMsg	   := ""
	Local cCodSaf  := ""
	
	If oModel:GetOperation() == MODEL_OPERATION_VIEW
		MsgAlert(STR0060) //O programa está executando em modo de visualização.
		Return .T.
	EndIf

	If _aIEORRF[1] == 1 //tem IE vinculado no romaneio
		aIEs := _aIEORRF[2] 
	EndIf

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	
		_lVincFard  := .T.
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
				lMarc  := .T.
				lAchou := .F.
				aAdd( aItsDest, aItsOrig[ nX ] )
				aItsDest[ Len( aItsDest ), 1 ] := "2"

				//If que valid quantidade autorizada, se algo foi selecionado na autorizacao
				If __lVldAut .And. (__lAgra500 .Or. __lAgra550 .Or. __lGfea523)
					If cSeta == ">" .and. Empty(aItsDest[ Len( aItsDest ), 3 ])

						oModel  := FwModelActive()
						oN9E    := A500MdlN9E(oModel)
						oNJJ    := A500MdlNJJ(oModel)

						cCodSaf := IIF(__lAgra550,SafraN7Q(oN9E:GetValue("N9E_CODINE")),oNJJ:GetValue("NJJ_CODSAF"))

						DbSelectArea("N8P")
						N8P->(DbSetOrder(2))
						If N8P->(DbSeek(FwxFilial("N8P") + oN9E:GetValue("N9E_CODAUT") + oN9E:GetValue("N9E_ITEMAC") + cCodSaf ))
							While N8P->(!EOF()) .AND. FwxFilial("N8P") == N8P->N8P_FILIAL ;
							.AND. oN9E:GetValue("N9E_CODAUT") == N8P->N8P_CODAUT ;
							.AND. oN9E:GetValue("N9E_ITEMAC") == N8P->N8P_ITEMAC ;
							.AND. cCodSaf == N8P->N8P_SAFRA
								If N8P->N8P_QTDAUT > 0

									For nI := 1 To Len(aItsDest)
										If aItsDest[nI][5] == N8P->N8P_BLOCO
											nQtdBlc ++
										EndIf
									Next nI

									If N8P->N8P_QTDAUT >= (nQtdBlc + QtdN9DBlc(oN9E:GetValue("N9E_CODINE"), N8P->N8P_SAFRA, N8P->N8P_BLOCO, N8P->N8P_CODAUT, N8P->N8P_ITEMAC, oNJJ:GetValue("NJJ_CODROM"))) 

										aItsDest[ Len( aItsDest ), 3 ] := oN9E:GetValue("N9E_CODINE")
										nQtdBlc := 0

									EndIf

									nQtdBlc := 0
								EndIf
								N8P->(DbSkip())
							EndDo
						EndIf
						N8P->(DbCloseArea())

					ElseIf cSeta == "<" 
						cBlcMarc := AGRXTVFBIE(aItsDest[ Len( aItsDest ), 3 ], aItsDest[ Len( aItsDest ), 2 ], aItsDest[ Len( aItsDest ), 5 ])
						If cBlcMarc == "2"
							aItsDest[ Len( aItsDest ), 3 ] := Space(TamSX3("N9E_CODINE")[1])
						EndIf
					EndIf

				ElseIf __lOga250 .Or. __lOga251 .Or. __lAgra500 .Or. __lAgra550 .Or. __lGfea523
					If cSeta == ">" .and. Empty(aItsDest[ Len( aItsDest ), 3 ]) .and. LEN(aIEs) > 0

						For nY := 1 To Len( aIEs )
							DbSelectArea("N83")
							DbSetOrder(2) //N83_FILIAL+N83_CODINE+N83_FILORG+N83_BLOCO
							If N83->(DbSeek(FwxFilial("N83") + aIEs[nY] + aItsOrig[ nX,2 ] + aItsOrig[ nX, 5 ] ))
								While N83->(!EOF()) .AND. N83->N83_CODINE == aIEs[nY] .AND. N83->N83_FRDMAR == '2' .AND. aItsOrig[ nX, 5 ] == N83->N83_BLOCO

									For nI := 1 To Len(aItsDest)
										If aItsDest[nI][5] == N83->N83_BLOCO .AND. aItsDest[nI][3] == N83->N83_CODINE
											nQtdBlc ++
										EndIf
									Next nI
									
									If N83->N83_QUANT > (nQtdBlc + QTDFRBLCIE( aIEs[nY] , N83->N83_BLOCO , _cCodRom, N83->N83_SAFRA))  

										aItsDest[ Len( aItsDest ), 3 ] := N83->N83_CODINE
										lAchou  := .T.
										nQtdBlc := 0
										EXIT

									EndIf

									nQtdBlc := 0
									N83->(DbSkip())
								EndDo
							EndIf
							N83->(DbCloseArea())
							If !lAchou
								LOOP
							Else
								EXIT
							EndIf
						Next nY

					ElseIf cSeta == "<" 
						cBlcMarc := AGRXTVFBIE(aItsDest[ Len( aItsDest ), 3 ], aItsDest[ Len( aItsDest ), 2 ], aItsDest[ Len( aItsDest ), 5 ])
						If cBlcMarc == "2"
							aItsDest[ Len( aItsDest ), 3 ] := Space(TamSX3("N83_CODINE")[1])
						EndIf
					EndIf
				EndIf

				If LEN(aIEs) > 0 .AND. Empty( aItsDest[ Len( aItsDest ), 3 ] ) .AND. cSeta == ">"
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

			cMsg += STR0047 + aBlcErr[nI,1] + _CRLF //#Bloco: 
			cMsg += STR0048 + cValToChar( aBlcErr[nI,2] )+ _CRLF + _CRLF //#Qtd Acima:

		Next nI

		If !empty(cMsg)
			MsgAlert(STR0049 + _CRLF + _CRLF + cMsg)  //#"Quantidade de fardos do bloco ultrapassou o limite disponivel: "
			lRet := .F.
		EndIf

		aItsOrig := ASort( aItsOrig, , , { | x, y | x[2]+x[3]+x[4]+x[5]+x[6]+x[7] < y[2]+y[3]+y[4]+y[5]+y[6]+y[7]}) //ordena filial+codine+safra+bloco+etiqueta+codigo
		aItsDest := ASort( aItsDest, , , { | x, y | x[2]+x[3]+x[4]+x[5]+x[6]+x[7] < y[2]+y[3]+y[4]+y[5]+y[6]+y[7]}) //ordena filial+codine+safra+bloco+etiqueta+codigo

		If lRet .and. cSeta == ">"
			lRet := AGR500VALID(aItsDest,aItsOrig,.T.)
		EndIf

		If lRet .And. lMarc
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
			Help( , , STR0021, , STR0022, 1, 0 ) //"Atenção"###"Favor selecionar fardos."
		EndIf

		If !lRet
			Return lRet
		EndIF

	EndIf

	_nQtdeSel := Len(oBrwDir:AARRAY) // Total de itens do romaneio
	_nPesoSel := 0
	For nX := 1 To len(oBrwDir:AARRAY)
		_nPesoSel += oBrwDir:AARRAY[nX, 9] //Peso Liquido Total de fardos selecionados
	Next nX

	ASize( aItsOrig, 0 )
	ASize( aItsDest, 0 )

Return(lRet)

	/*/{Protheus.doc} QTDFRBLCIE()
	Função que retorna a quantidade de fardos do bloco para a Isntrução de embarque vinculado em outros romaneios
	@type  Static Function
	@author claudineia.reinert
	@since 28/02/2018
	@version 1.0
	@param param, param_type, param_desc
	@return nQtd - quantidade de fardos 
	@example
	(examples)
	@see http://tdn.totvs.com/pages/viewpage.action?pageId=338377171
	/*/
Static function QTDFRBLCIE(cIE, cBloco, cCodRom, cSafra)
	Local nQtd := 0
	Local cQry := ""
	Local cAliasQry 	:= GetNextAlias()

	cQry := " SELECT COUNT(N9D_FARDO) AS QTDFRD"
	cQry += " FROM " + RetSQLName("N9D") + " N9D"
	cQry += " WHERE N9D.D_E_L_E_T_ = ' ' "
	cQry += " AND N9D_FILIAL = '" + FwxFilial( 'N9D' ) + "' "
	cQry += " AND N9D_SAFRA = '" + cSafra + "' "
	cQry += " AND N9D_CODINE = '" + cIE + "' "
	cQry += " AND N9D_BLOCO = '" + cBloco + "'  "
	If __lAgra550
		cQry += " AND (N9D_TIPMOV = '07' OR N9D_TIPMOV = '11') "
	Else
		cQry += " AND N9D_TIPMOV = '07' "
	
	EndIf
	cQry += " AND (N9D_STATUS = '1' OR N9D_STATUS = '2')
	cQry += " AND N9D_CODROM <> '" + cCodRom + "'  " //DIFERENTE DO ROMANEIO ATUAL
	cQry := ChangeQuery( cQry ) 
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	If (cAliasQry)->( !Eof() )        
		nQtd := (cAliasQry)->QTDFRD 
	EndIf
	(cAliasQry)->(dbCloseArea())

Return nQtd


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

@author: 	claudineia.reinert
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

	ASORT(oBrowse:AARRAY,,,{|x,y| x[2]+x[4]+x[5]+x[6]+x[7] < y[2]+y[4]+y[5]+y[6]+y[7]})   //ordena filial+codine+safra+bloco+etiqueta+codigo

	If Alltrim(Upper(cChave)) == Upper(STR0001) //fardos 
		for nX := 1 to len(oBrowse:AARRAY) 
			If oBrowse:AARRAY[nX][7] == cPesquisa 
				If nPosAc = 0 
					nPosAc := nX //seta linha para posicionar
				EndIf
				//realiza a marcação do registro
				MarcaPesq( oBrowse, oBrowse:AARRAY, nX)
			EndIf
		Next
	ElseIf Alltrim(Upper(cChave)) == Upper(STR0002) //Etiqueta
		for nX := 1 to len(oBrowse:AARRAY) 
			If oBrowse:AARRAY[nX][6] == cPesquisa 
				If nPosAc = 0 
					nPosAc := nX //seta linha para posicionar
				EndIf
				//realiza a marcação do registro
				MarcaPesq( oBrowse, oBrowse:AARRAY, nX)
			EndIf
		Next
	ElseIf Alltrim(Upper(cChave)) == Upper(STR0003) //bloco
		for nX := 1 to len(oBrowse:AARRAY) 
			If oBrowse:AARRAY[nX][5] == cPesquisa 
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



/*/{Protheus.doc} OGA250QIE()
Função que valida se a instrução de embarque selecionada possui quantidade instruida para a filial do romaneio.
@type  Function
@author rafael.kleestadt
@since 22/02/2018
@version 1.0
@param param, param_type, param_descr
@return lRet, Logical, True or False
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=338377171
/*/
Function AGRX500IE()
	Local lRet    := .F.
	Local oModel  := FwModelActive()
	Local oNJJ	  := A500MdlNJJ(oModel)
	Local oMldN9E := A500MdlN9E(oModel)
	Local aArea   := GetArea()
	Local cCodine := oMldN9E:GetValue( "N9E_CODINE" )
		
	If oNJJ:GetValue("NJJ_TIPO") == "9"
		lRet := .T.
	Else
		DbSelectArea("N7S")
		DbSetOrder(1)
		If N7S->(DbSeek(FwxFilial("N7S") + cCodine))
			While N7S->( !Eof() ) .And. N7S->N7S_CODINE == cCodine	
				If N7S->N7S_QTDVIN > 0 .And. N7S->N7S_FILORG == FwxFilial("NJJ")		
					lRet := .T.
					Exit
				EndIf
				N7S->(DbSkip())
			EndDo
		EndIf
		N7S->(DbCloseArea())
	EndIf
	
	If .Not. lRet
		Help(" ",1,".OGA250000001.")//Problema: "Instrução de Embarque não instruída para este romaneio."
	EndIf
	
	//verifica se o produto do romaneio é o mesmo da IE
	If lRet
		DbSelectArea("N7Q")
		DbSetOrder(1)
		If N7Q->(DbSeek(FwxFilial("N7Q") + cCodine))
			If oNJJ:GetValue("NJJ_CODPRO") != N7Q->N7Q_CODPRO
				If Empty(oNJJ:GetValue("NJJ_CODPRO"))
					Help( ,, STR0021,, STR0023, 1, 0)	//"Ajuda" "Campo Produto não preenchido."
				Else
					Help( ,, STR0021,, STR0050, 1, 0)	//"Ajuda" "Campo Produto não preenchido."
				EndIf
				Return .F.
			EndIf
		EndIf
	EndIf
	
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} AGRX500FVL
//Validacoes no commit do romaneio
@author carlos.augusto
@since 13/04/2018
@version undefined
@type function
/*/
Function AGRX500FVL(oModel)
	Local lRet    := .T.
	Local oMldNJJ 	:= A500MdlNJJ(oModel)
	Local oMldN9E 	:= A500MdlN9E(oModel)
	Local oMldN9D 	:= A500MdlN9D(oModel)	
	Local aArea     := GetArea()
	Local nX		:= 0
	Local nLinha	:= 0
		
	//Valida Produto
	For nX := 1 to oMldN9D:Length()
		oMldN9D:GoLine( nX )
		If (.Not. oMldN9D:IsDeleted() .And. .Not. Empty(oMldN9D:GetValue("N9D_SAFRA"))) ;
		   .And. (oMldNJJ:GetValue("NJJ_CODSAF") != oMldN9D:GetValue("N9D_SAFRA"))
		   //#"Safra inválida para o fardo: " - "Verifique o campo Safra."
			oModel:GetModel():SetErrorMessage( oModel:GetId(), , oModel:GetId(), "", "", STR0024 + oMldN9D:GetValue("N9D_FARDO"), STR0025, "", "")
			lRet := .F.
			exit
		EndIf
	Next nX
	
	//verifica se o produto do romaneio é o mesmo da IE
	If lRet
		DbSelectArea("N7Q")
		N7Q->(DbSetOrder(1))
		nLinha := oMldN9E:GetLine()
		For nX := 1 to oMldN9E:Length()
			oMldN9E:GoLine( nX )
			If .Not. oMldN9E:IsDeleted() .And. .Not. Empty(oMldN9E:GetValue("N9E_CODINE"))
				If N7Q->(MsSeek(FwxFilial("N7Q") + oMldN9E:GetValue("N9E_CODINE")))
					If oMldNJJ:GetValue("NJJ_CODPRO") != N7Q->N7Q_CODPRO
						//#"Produto diferente do informado para o Romaneio na Instrução de Embarque: " - "Verifique o campo Produto."
						oModel:GetModel():SetErrorMessage( oModel:GetId(), , oModel:GetId(), "", "", STR0026 + oMldN9E:GetValue("N9E_CODINE"), STR0027, "", "")
						lRet := .F.
						exit
					EndIf
				EndIf
			EndIf
		Next nX	
		oMldN9E:GoLine(nLinha)
		N7Q->(dbCloseArea())
	EndIf
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} AGRX500FPR
//Função para uso na pre-edição da grid N9E, para uso relacionado aos fardos
//Ao deletar uma linha, desrelacionar os fardos selecionados para o item
@author carlos.augusto
@since 13/04/2018
@version undefined
@param oMldN9E, object, descricao
@param nLine, numeric, descricao
@param cAction, characters, descricao
@param cIDField, characters, descricao
@param xValue, , descricao
@param xCurrentValue, , descricao
@type function
/*/
Function AGRX500FPR(oMldN9E, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local lRet 		:= .T.
	Local oModel	:= FwModelActive()
	Local oMldN9D 	:= A500MdlN9D(oModel)
	Local nX
	Local cAutoriz	:= oMldN9E:GetValue( "N9E_CODAUT" )
	Local cCodine	:= oMldN9E:GetValue( "N9E_CODINE" )
	Local cItemAc	:= oMldN9E:GetValue( "N9E_ITEMAC" )
	Local cSequen   := oMldN9E:GetValue( "N9E_SEQUEN" )
	Local cTipoMer 	:= ""

	If cAction == "DELETE" .And. !Empty(cCodine)
		ApMsgAlert(STR0028) //Ao excluir a linha da Instrução de Embarque, os fardos deste item são automaticamente desrelacionados.
		For nX := 1 to oMldN9D:Length()
			oMldN9D:GoLine(nX)
			If !oMldN9D:IsDeleted() .And. oMldN9D:GetValue( "N9D_CODINE" ) == cCodine .AND. ;
			    !Empty(cAutoriz) .AND. oMldN9D:GetValue( "N9D_CODAUT" ) == cAutoriz .AND. ;
				!Empty(cItemAc) .AND. oMldN9D:GetValue( "N9D_ITEMAC" ) == cItemAc
			    oMldN9D:DeleteLine()
				_lVincFard := .T.
			ElseIf !oMldN9D:IsDeleted() .And. oMldN9D:GetValue( "N9D_CODINE" ) == cCodine .AND. ;
			       oMldN9D:GetValue( "N9D_SEQUEN" ) == cSequen			       
				oMldN9D:DeleteLine()
				_lVincFard := .T.
			EndIf
		Next nX
	ElseIf cAction == "UNDELETE" .And. !Empty(cCodine)
		For nX := 1 to oMldN9E:Length()			
			oMldN9E:GoLine(nX) //percorre N9E para verificar se não foi informado mesma IE em outra linha
			If  nX != nLine .AND. !oMldN9E:IsDeleted()  .AND. oMldN9E:GetValue( "N9E_CODINE" ) == cCodine .AND. ;
			    !Empty(cAutoriz) .AND. oMldN9E:GetValue( "N9E_CODAUT" ) == cAutoriz .AND. ;				
				!Empty(cItemAc) .AND. oMldN9E:GetValue( "N9E_ITEMAC" ) == cItemAc
				lRet := .F.
				Help( ,, STR0021,, STR0029, 1, 0)//"Ajuda" "Operação não permitida. Duplicará registros."
			ElseIf  nX != nLine .And. !oMldN9E:IsDeleted()  .AND. oMldN9E:GetValue( "N9E_ORIGEM" ) == "5" .And. ;
				oMldN9E:GetValue( "N9E_CODINE" ) == cCodine 		
				lRet := .F.
				Help( ,, STR0021,, STR0029, 1, 0)//"Ajuda" "Operação não permitida. Duplicará registros."
			EndIf
		Next nX
		oMldN9E:GoLine( nLine )	//mantem na linha posicionada

		If lRet
			For nX := 1 to oMldN9D:Length()
				oMldN9D:GoLine(nX)
				If oMldN9D:IsDeleted() .AND. oMldN9D:GetValue( "N9D_CODINE" ) == cCodine .AND. ;
					!Empty(cAutoriz) .AND. oMldN9D:GetValue( "N9D_CODAUT" ) == cAutoriz .AND. ;
					!Empty(cItemAc) .AND. oMldN9D:GetValue( "N9D_ITEMAC" ) == cItemAc 
					oMldN9D:UnDeleteLine()
					_lVincFard := .T.
				ElseIf oMldN9D:IsDeleted() .And. oMldN9D:GetValue( "N9D_CODINE" ) == cCodine .AND. ;
				       oMldN9D:GetValue( "N9D_SEQUEN" ) == cSequen
					oMldN9D:UnDeleteLine()
					_lVincFard := .T.
				EndIf
			Next nX
			ApMsgAlert(STR0030) //"Os fardos deste item serão recuperados."
		EndIf
	ElseIf cAction == "SETVALUE"
		IF oMldN9E:IsInserted() .OR. oMldN9E:IsUpdated()
			If Alltrim(cIDField) == "N9E_CODINE" .and. VldVincN9EN9D(oMldN9E,oMldN9D)
				lRet := .F.
				Agrhelp(STR0021,"Há fardos vinculados neste registro.", "Para alterar este campo é necessario desvincular os fardos relacionados a esta instrução de embarque deste registro.")
			ElseIf .NOT. Empty(AllTrim(oMldN9E:GetValue("N9E_CODINE", nLine)))
				cTipoMer := Posicione("N7Q",1,FWxFilial("N7Q")+AllTrim(oMldN9E:GetValue("N9E_CODINE", nLine)),"N7Q_TPMERC")

				If __cAnaCred $ "1|2|3" //Parâmetro de análise de crédito: 1 - Interno, 2 - Externo, 3 - Ambos, 4 - Nenhum
					If __cAnaCred = "3" //Ambos
						_lAltIE := .T.
					ElseIf __cAnaCred = cTipoMer
						_lAltIE := .T.
					EndIf
				Else
					_lAltIE := .F.
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} AGRX500FNJM
//Função para uso na pre-edição da grid NJM, para uso relacionado aos fardos
@author claudineia.reinert
@since 08/07/2020
@version 1.0
@param oMldNJM, object, objeto do modelo da estrutura da NJM
@param nLine, numeric, numero da linha posicionada
@param cAction, characters, ação executado na linha ou campo
@param cIDField, characters, campo da execução da ação(para SETVALUE/CANSETVALUE)
@param xValue, , novo valor para o campo(para SETVALUE/CANSETVALUE)
@param xCurrentValue, , valor atual do campo(para SETVALUE/CANSETVALUE)
@type function
/*/
Function AGRX500FNJM(oMldNJM, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local lRet 		:= .T.
	Local oModel	:= FwModelActive()
	Local oMldN9D 	:= A500MdlN9D(oModel)
	Local nX		:= 0
	Local cCodctr	:= oMldNJM:GetValue( "NJM_CODCTR" )
	Local cItem		:= oMldNJM:GetValue( "NJM_ITEM" )
	Local cSeqPri	:= oMldNJM:GetValue( "NJM_SEQPRI" )
	Local cIteRom	:= oMldNJM:GetValue( "NJM_ITEROM" )
	Local lMsg		:= .F.

	If cAction == "DELETE" .And. !Empty(cCodctr) .And. !Empty(cItem) .And. !Empty(cSeqPri)
		For nX := 1 to oMldN9D:Length()
			oMldN9D:GoLine(nX)
			If .Not. oMldN9D:IsDeleted() .And. oMldN9D:GetValue( "N9D_CODCTR" ) == cCodctr .AND. ;
			       oMldN9D:GetValue( "N9D_ITEETG" ) == cItem .AND. ;
				   oMldN9D:GetValue( "N9D_ITEREF" ) == cSeqPri .AND. ;
				   oMldN9D:GetValue( "N9D_ITEROM" ) == cIteRom 
				   If !lMsg //mostra apenas uma vez
						lMsg := .T.
						ApMsgAlert(STR0066) //##"Ao excluir este item do romaneio, os fardos deste item são automaticamente desvinculados do romaneio."
				   EndIf
				oMldN9D:DeleteLine()
				_lVincFard := .T.
			EndIf
		Next nX
	ElseIf cAction == "UNDELETE" .AND. !Empty(cCodctr) .AND. !Empty(cItem) .AND. !Empty(cSeqPri)
		For nX := 1 to oMldNJM:Length()
			oMldNJM:GoLine(nX)
			If  nX != nLine .AND. !oMldNJM:IsDeleted() .AND. oMldNJM:GetValue( "NJM_CODCTR" ) == cCodctr .AND. ;
				oMldNJM:GetValue( "NJM_ITEM" ) == cItem .AND. ;
				oMldNJM:GetValue( "NJM_SEQPRI" ) == cSeqPri 
				lRet := .F.
				Help( ,, STR0021,, STR0029, 1, 0)//"Ajuda" "Operação não permitida. Duplicará registros."
			EndIf
		Next nX
		oMldNJM:GoLine(nLine) //mantem na linha posicionada

		If lRet
			For nX := 1 to oMldN9D:Length()
				oMldN9D:GoLine(nX)
				If oMldN9D:IsDeleted() .AND. oMldN9D:GetValue( "N9D_CODCTR" ) == cCodctr .AND. ;
			       oMldN9D:GetValue( "N9D_ITEETG" ) == cItem .AND. ;
				   oMldN9D:GetValue( "N9D_ITEREF" ) == cSeqPri .AND. ;
				   oMldN9D:GetValue( "N9D_ITEROM" ) == cIteRom
				   If !lMsg //mostra apenas uma vez
						lMsg := .T.
						ApMsgAlert(STR0030) //"Os fardos deste item foram recuperados."
				   EndIf
					oMldN9D:UnDeleteLine()
					_lVincFard := .T.
				EndIf
			Next nX
		EndIf
	ElseIf cAction == "SETVALUE" .AND. Alltrim(cIDField) $ "NJM_CODCTR|NJM_ITEM|NJM_SEQPRI" .and. VldVincNJMN9D(oMldNJM,oMldN9D)
		Agrhelp(STR0021,STR0067, STR0068) //##Ajuda ##"Há fardos vinculados neste item do romaneio." ##"Para alterar este campo desvincule os fardos deste item do romaneio."
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} VldVincN9EN9D
//Função que valida de há vinculo da N9E posicionada com a N9D
@author claudineia.reinert
@since 10/07/2020
@version 1.0
@param oN9E, object, objeto do modelo da estrutura da N9E
@param oN9D, object, objeto do modelo da estrutura da N9D
@type function
/*/
Static Function VldVincN9EN9D(oN9E,oN9D)
	Local lRet 	:= .F.
	Local nX 	:= 0
		
	For nX := 1 to oN9D:Length() 
		oN9D:GoLine(nX)
		If !oN9D:IsDeleted() .AND. oN9D:GetValue("N9D_SEQUEN") == oN9E:GetValue("N9E_SEQUEN") 	
			lRet := .T. //TEM FARDOS VINCULADOS PARA ESTE REGISTRO N9E
			exit
		EndIf
	Next nX	

Return lRet

/*/{Protheus.doc} VldVincNJMN9D
//Função que valida de há vinculo da NJM posicionada com a N9D
@author claudineia.reinert
@since 10/07/2020
@version 1.0
@param oNJM, object, objeto do modelo da estrutura da NJM
@param oN9D, object, objeto do modelo da estrutura da N9D
@type function
/*/
Static Function VldVincNJMN9D(oNJM,oN9D)
	Local lRet 	:= .F.
	Local nX 	:= 0
		
	For nX := 1 to oN9D:Length() 
		oN9D:GoLine(nX)
		If !oN9D:IsDeleted() .AND. oN9D:GetValue("N9D_ITEROM") == oNJM:GetValue("NJM_ITEROM")
			lRet := .T. //TEM FARDOS VINCULADOS PARA ESTE REGISTRO NJM
			exit
		EndIf
	Next nX	

Return lRet


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
Function AGR500BRMSAI(cCodRom, oModel)

	Local aAreaAtu 		:= GetArea()
	Local aAreaNJJ 		:= NJJ->( GetArea() )
	Local aAreaNJR 		:= NJR->( GetArea() )	
	Local aAreaN7S 		:= N7S->( GetArea() )	
	Local aAreaN9A 		:= N9A->( GetArea() )	
	Local cCampo		:= 'DXI_ROMFLO'	
	Local oNJJ    		:= nil
	Local cCodCtr 		:= ''
	Local cItem   		:= ''
	Local cSeqPri 		:= ''
	Local aIEORRF       := {}
	Local cTipoRom		:= ""

	Default oModel		:= NIL
	
	If oModel != Nil .and. oModel:IsActive()
		oNJJ := A500MdlNJJ(oModel)
	EndIf
	
	If oNJJ != NIL .and. oNJJ:IsActive()
		cTipoRom := oNJJ:GetValue("NJJ_TIPO")
	Else
		cTipoRom := POSICIONE("NJJ",1,FWxFilial("NJJ")+cCodRom,"NJJ_TIPO")
	EndIf

	If cTipoRom == "4" //ROMANEIO DE VENDA

		aIEORRF	 := AGRX500IERF(cCodRom,oModel) 

		If LEN(aIEORRF) > 0 .AND. aIEORRF[1] == 1 //tem IEs na N9E
			DbSelectArea("N7S") //IE x Entrega
			N7S->(DbSetOrder(1))
			If N7S->(DbSeek( xFilial("N7S") + aIEORRF[2][1] )) //posiciona no primeiro registro para pegar contrato 			
				cCodCtr := N7S->N7S_CODCTR
				cItem   := N7S->N7S_ITEM
				cSeqPri := N7S->N7S_SEQPRI
			EndIf

		ElseIf LEN(aIEORRF) > 0 .AND. aIEORRF[1] == 2 //tem regra fiscal na NJM
			cCodCtr := aIEORRF[2][1][1]  //usa a primeira pra pegar o contrato
			cItem   := aIEORRF[2][1][2]
			cSeqPri := aIEORRF[2][1][3]
		EndIf

		DbSelectArea("NJR") //Contratos
		NJR->(DbSetOrder(1))
		If NJR->(DbSeek( xFilial("NJR") + cCodCtr )) .AND. NJR->NJR_CODCTR == cCodCtr .AND. NJR->NJR_TIPO == '2'  //Verifica se o Contrato é do tipo '2' - Venda
			If NJR->NJR_TIPMER == '2' //SE EXPORTAÇÃO
				cCampo := 'DXI_ROMSAI' // "DXI_ROMSAI" - Salvar no campo DXI_ROMSAI 
			ELSE								
				DbSelectArea("N9A") //Contratos
				N9A->(DbSetOrder(1))
				If N9A->(DbSeek( xFilial("N9A") + cCodCtr + cItem + cSeqPri ))
					While N9A->( !Eof() ) .and. N9A->N9A_CODCTR = cCodCtr .AND. N9A->N9A_ITEM == cItem .AND. N9A->N9A_SEQPRI == cSeqPri	
						If (N9A->N9A_OPEFUT == "1" .OR. N9A->N9A_OPETRI == "1") .AND. EMPTY(N9A->N9A_CODROM) //SE VENDA FUTURA OU VENDA ORDEM 
							cCampo := 'DXI_ROMSAI' // "DXI_ROMSAI" - Salvar no campo DXI_ROMSAI 
						ElseIf N9A->N9A_OPEFUT == "2" .AND. N9A->N9A_OPETRI == "2" //SE VENDA SIMPLES 
							cCampo := 'DXI_ROMSAI' // "DXI_ROMSAI" - Salvar no campo DXI_ROMSAI 
						EndIf
						N9A->(DbSkip())
					EndDo		
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea( aAreaNJJ )
	RestArea( aAreaN7S )
	RestArea( aAreaNJR )
	RestArea( aAreaN9A )
	RestArea( aAreaAtu )	

Return cCampo	
	
	/*/{Protheus.doc} AGRX500IERF()
	Função que busca com qual objeto o romaneio esta trabalhando, IE ou Regras Fiscais.
	@type  Static Function
	@author claudineia.reinert
	@since 02/07/2020
	@version 1.0
	@param param, Caracter, Codigo do Romaneio
	@param param, Objeto, Objeto do Modelo ativo
	@return aRet, array, Retorna um array com 2 posições, ver exemplo abaixo
	@example
		aRet default, posição [1] valor numerico 0 representa que não encontrou IE ou regra fiscal vinculado no romaneio e na posição [2] um array vazio.
		aRet = {  0 ,
				  {}
				}
		//aRet com IEs, posição [1] valor numerico 1 representa usa IE e na posição [2] um array com as IEs
		aRet = {  1 ,
			      { {"000000100"} ,
				    {"000000101"}
		          }
				}
		//aRet com Regras fiscais, posição [1] valor numerico 2 representa usa regra fiscal e na posição [2] um array com as regras fiscais
		aRet = {  2 ,
			      { { "000055","001","001" } ,
				    { "000056","001","001" }
		          }
	(examples)
	/*/
Static Function AGRX500IERF(cCodRom,oModel)
	Local aRet := { 0 , {} }
	Local oN9E := NIL
	Local oNJM := NIL
	Local nLinha := 0
	Local nY	:= 0
	Local aAreaAtu 		:= GetArea()
	Local aAreaNJM 		:= NJM->( GetArea() )
	Local aAreaN9E 		:= N9E->( GetArea() )	

	Default oModel := FwModelActive()

	IF oModel != NIL .and. oModel:IsActive()
		oN9E := A500MdlN9E(oModel)
	    oNJM := A500MdlNJM(oModel)
	EndIf

	//OBS: Sempre verifica primeiro N9E pois se tem IE o romaneio será pela IE mesmo que tenha regra fiscal na NJM
	IF oN9E != NIL .and. oN9E:IsActive() 
		If oN9E:Length( .T. ) //se tiver linha ativa na grid
			nLinha	:= oN9E:GetLine()
			FOR nY := 1 TO oN9E:Length() //percorre toda a grid pois pode haver registros deletados
				oN9E:GoLine(nY) //posiciona na linha
				IF !oN9E:IsDeleted() .AND. !Empty(oN9E:GetValue("N9E_CODINE")) //se linha não estiver deletada
					aRet[1] := 1
					AADD( aRet[2] , oN9E:GetValue("N9E_CODINE") )
				ENDIF
			NEXT nY
			oN9E:GoLine(nLinha) //posiciona na linha
		ENDIF
	ELSE
		//modelo não esta ativo, busca na tabela
		DbSelectArea("N9E") //Integrações do Romaneio
		N9E->(DbSetOrder(1))
		IF N9E->(DbSeek( xFilial("N9E") + cCodRom )) 
			WHILE N9E->( !Eof() ) .and. N9E->N9E_CODROM == cCodRom 
				If !Empty(N9E->N9E_CODINE) //verifica se codigo da instrução de embarque esta preenchido
					aRet[1] := 1
					AADD( aRet[2] , N9E->N9E_CODINE )
				ENDIF
			ENDDO
		ENDIF
	ENDIF

	IF aRet[1] = 0 //não encontrou IE no romaneio verifica as regras fiscais
		IF oNJM:IsActive() 
			If oNJM:Length( .T. ) //se tiver linha ativa na grid
				nLinha	:= oNJM:GetLine()
				For nY := 1 To oNJM:Length() //percorre toda a grid pois pode haver registros deletados
					oNJM:GoLine(nY) //posiciona na linha
					If !oNJM:IsDeleted() .AND. !Empty(oNJM:GetValue("NJM_CODCTR")) .AND. !Empty(oNJM:GetValue("NJM_ITEM")) .AND. !Empty(oNJM:GetValue("NJM_SEQPRI")) 
						aRet[1] := 2
						AADD( aRet[2] , {oNJM:GetValue("NJM_CODCTR"), oNJM:GetValue("NJM_ITEM"), oNJM:GetValue("NJM_SEQPRI")} )
					EndIf
				Next nY
				oNJM:GoLine(nLinha) //posiciona na linha
			EndIf
		ELSE
			//modelo não esta ativo, busca na tabela
			DbSelectArea("NJM") //Itens do Romaneio
			NJM->(DbSetOrder(1))
			IF NJM->(DbSeek( xFilial("NJM") + cCodRom )) 
				WHILE NJM->( !Eof() ) .and. NJM->NJM_CODROM == cCodRom //percorre NJM 
					If !Empty(NJM->NJM_CODCTR) .AND. !Empty(NJM->NJM_ITEM) .AND. !Empty(NJM->NJM_SEQPRI)  //verifica se regra fiscal esta preenchida
						aRet[1] := 2
						AADD( aRet[2] , {NJM->NJM_CODCTR,NJM->NJM_ITEM,NJM->NJM_SEQPRI} )
					ENDIF
				ENDDO
			ENDIF
		ENDIF
	ENDIF

	RestArea( aAreaN9E )
	RestArea( aAreaNJM )
	RestArea( aAreaAtu )	
	
Return aRet 
	
/** -------------------------------------------------------------------------------------
{Protheus.doc} AGR500VALID
Valida dados dos fardos

@author tamyris.ganzenmueller
@since 04/12/2017
-------------------------------------------------------------------------------------- **/
Static Function AGR500VALID(aRRRAYDir, aRRRAYEsq, lValCTN)
	Local nX		:= 0
	Local lRet      := .T.
	Local nPos	    := 0
	Local aFardBlc  := {}
	Local fPeso     := 0

	aFardRom := {}
	_aIEPeso := {}

	For nX:= 1 To Len(aRRRAYDir)

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

		//Quando estufagem de CNT valida pelo peso de saída faz. ou peso cheg. porto
		nPeso1 := aRRRAYDir[nX][9] //Peso Líquido
		nPeso2 := aRRRAYDir[nX][8] //Peso Bruto

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

	If (__lOga250 .Or. __lOga251) .and. _aIEORRF[1] == 1 //se romaneio for com IE
		
		lRet := ValQtdFrd(aFardBlc)

		if lRet 
			For nX:=1 To Len(_aIEPeso)
				fPeso := (_aIEPeso[nX][2] )
				lRet := AGRX500VQIE(_aIEPeso[nX][1], fPeso, _cCodRom) 
				If .not. lRet //se passou do peso da IE
					//se tiver mais de uma IE, e primeira ultrapassou o peso da IE retornando falso na função,
					// então sai do for e a segunda IE não é validada, será necessario primeiro corrigir o peso da primeira				
					Exit 
				EndIf
			Next nX
		endIf
	Endif

Return lRet


/*{Protheus.doc} ValQtdFrd
Função destinada a validar o valor da quantidade dos fardos

@return:	Nil
@author: 	claudineia.reinert
@since: 	14/11/2017
@Uso: 		OGA250 - Romaneio
*/
Static Function ValQtdFrd(aFardBlc)
	Local lRet 		:= .T.
	Local cQry 		:= ""
	Local cAliasQry := GetNextAlias()
	Local cMsg		:= "" 
	Local nI        := 0
	Local oModel    := FwModelActive()
	Local cCampoRom := AGR500BRMSAI(_cCodRom,oModel) 
	/************************************************/
	/*Montado a query que irá trazer, Bloco, quantidade limite do bloco e quantidade já alocada em outros romaneiros da IE, cada linha é um bloco*/
	cQry := " SELECT N83_CODINE,N83_BLOCO,SUM(N83_QUANT) AS N83_QUANT,DXI.FRDIE AS FARDS_IE "
	cQry += " FROM " + RetSQLName("N83") + " N83 "
	//cQry +=	" LEFT OUTER JOIN " + RetSQLName("NJJ") + " NJJ ON NJJ.D_E_L_E_T_ <> '*' AND NJJ_FILIAL = N83_FILORG AND NJJ_CODROM <> '" + _cCodRom + "' "
	//cQry +=	" LEFT OUTER JOIN " + RetSQLName("DXI") + " DXI ON DXI.D_E_L_E_T_ <> '*' AND "+cCampoRom+" = NJJ_CODROM AND DXI_FILIAL = N83_FILORG AND DXI_CODINE = N83_CODINE AND DXI_BLOCO = N83_BLOCO"
	cQry +=	" LEFT OUTER JOIN (SELECT DXI_FILIAL,DXI_CODINE,DXI_BLOCO,COUNT(DXI_CODIGO) AS FRDIE "
	cQry +=	" 					FROM " + RetSQLName("DXI") + " WHERE D_E_L_E_T_ = ' ' AND "+cCampoRom+" NOT IN ('" + _cCodRom + "','') "
	
	cQry +=	" 					GROUP BY DXI_FILIAL,DXI_CODINE,DXI_BLOCO ) "
	cQry +=	" 	DXI ON DXI.DXI_FILIAL = N83_FILORG AND DXI.DXI_CODINE = N83_CODINE AND DXI.DXI_BLOCO = N83_BLOCO "    
	cQry += " WHERE N83_FILIAL = '"+FWxFilial("N83")+"' AND N83.D_E_L_E_T_ = ' ' "
	cQry += " AND N83_FILORG = '"+FWxFilial("NJJ")+"' "
	cQry += " AND N83_CODINE in (" + compQry("N83") + ") "
	cQry +=	" GROUP BY N83_CODINE,N83_FILORG,N83_BLOCO,DXI.FRDIE" 

	cQry := ChangeQuery( cQry ) 
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	(cAliasQry)->( dbGoTop() )

	/*Para cada bloco de fardo sendo alocado ao romaneiro*/
	For nI := 1 to Len( aFardBlc ) 

		(cAliasQry)->( dbGoTop() )

		/*Verifica na consulta da soma dos fardos alocados por bloco*/
		While (cAliasQry)->( !Eof() )
			/*Se o bloco atual for igual ao bloco retornado na consulta e a quantidade limite for menor que a soma da quantidade já alocada com a quantidade sendo alocada no romaneiro atual*/
			If aFardBlc[nI][1] == (cAliasQry)->N83_CODINE .AND. aFardBlc[nI][2] == (cAliasQry)->N83_BLOCO .AND. (cAliasQry)->N83_QUANT < (cAliasQry)->FARDS_IE + aFardBlc[nI][3] 

				lRet := .F.
				cMsg += STR0054 + aFardBlc[nI,1] + _CRLF //#IE: 
				cMsg += STR0047 + (cAliasQry)->N83_BLOCO + _CRLF //#Bloco: 
				cMsg += STR0048 + cValToChar( ( (cAliasQry)->FARDS_IE + aFardBlc[nI][3] ) - (cAliasQry)->N83_QUANT ) + _CRLF + _CRLF //#Qtd Acima: 

			EndIf

			(cAliasQry)->( dbSkip() )

		EndDo		
	Next nI

	(cAliasQry)->(dbCloseArea())

	If !empty(cMsg)
		//"Quantidade de fardos do bloco ultrapassou o limite disponivel: "
		MsgAlert(STR0049 + _CRLF + _CRLF + cMsg)   
	EndIf	

Return lRet

	/*/{Protheus.doc} compQry()
	Função que busca as instruções de embarque para complementar a query dos fardos vinculado ou que podem ser vinculados
	@type  Static Function
	@author rafael.kleestadt
	@since 20/02/2018
	@version 1.0
	@param cTab, caractere, tabela que deve ser usada no complemento
	@return cCompl, caractere, caracter contendo o complemento da query
	@example
	(examples)
	@see http://tdn.totvs.com/pages/viewpage.action?pageId=338377171
	/*/
Static Function compQry(cTab)
	Local cCompl := ""
	Local aIEs	 := IIF(_aIEORRF[1] == 1, _aIEORRF[2], {}) //Se tem Ie vinculado no romaneio carrega array de IE
	Local nY 	 := 0

	For nY := 1 To Len(aIEs) 
		If nY = 1
			cCompl := "'" + aIEs[nY] + "'" 
		Else
			cCompl += ",'" + aIEs[nY] + "'" 
		EndIf

	Next nY

	Return cCompl
	
/**-------------------------------------------------------------------------------------
{Protheus.doc} AGRX500VQIE
Validar a qtd remetida da IE (peso liquido 
total dos fardos) com a qtd total liquida da IE mais o percentual permitido.

@author: 	janaina.duarte
@since: 	09/11/2017
@uso: 		OGA250
-------------------------------------------------------------------------------------**/
Function AGRX500VQIE(cCodIE,nQtdIE,cCodRom) //AGRX500VQIE
	Local aAreaAtu	 := GetArea()
	Local aAreaN7Q 	 := N7Q->( GetArea() ) //area N7Q é usada na função que chama esta função, como esta função tambem usa a area N7Q entao precisa ser restaurada ao voltar na função anterior
	Local lRet 		 := .T.
	Local nQtdMaxima := 0 
	Local cMsg 		 := ""
	Local nQtdTotIE  := 0
	Local nVlrPsLq   := 0
	Local cCampoRom  := ''
	Local oModel     := FwModelActive()

	If Empty(cCodRom)
		cCodRom := NJJ->NJJ_CODROM
	EndIf
	cCampoRom := AGR500BRMSAI(cCodRom, oModel) //Verifica se o campo para gravar o Romaneio é DXI_ROMSAI ou DXI_ROMFO

	cAliasQry := GetNextAlias()
	cQry :=    " Select SUM(DXI_PSLIQU) AS PESO "
	cQry +=    " FROM " + RetSQLName("DXI") + " DXI "
	cQry +=    " WHERE DXI.DXI_CODINE = '" + cCodIE + "' "
	cQry +=    "   AND DXI."+cCampoRom+" <> '"  + cCodRom  + "' "
	cQry +=    "   AND DXI."+cCampoRom+" <> ''     
	cQry +=    "   AND DXI.DXI_PESSAI = 0" 
	cQry +=    "   AND DXI.D_E_L_E_T_ = ' ' "
	cQry +=    "   UNION "
	cQry +=    " Select SUM(DXI_PESSAI) AS PESO "
	cQry +=    " FROM " + RetSQLName("DXI") + " DXI "
	cQry +=    " WHERE DXI.DXI_CODINE = '" + cCodIE + "' "
	cQry +=    "   AND DXI."+cCampoRom+" <> '"  + cCodRom  + "' "
	cQry +=    "   AND DXI."+cCampoRom+" <> '' 
	cQry +=    "   AND DXI.DXI_PESSAI > 0 " 
	cQry +=    "   AND DXI.D_E_L_E_T_ = ' ' "

	cQry := ChangeQuery( cQry ) 
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	(cAliasQry)->( dbGoTop() )      

	While (cAliasQry)->( !Eof() )        

		nVlrPsLq += (cAliasQry)->PESO

		(cAliasQry)->(DbSkip())

	EndDo 

	(cAliasQry)->(dbCloseArea())

	//grava a quantidade no campo
	dbSelectArea( "N7Q" ) 
	N7Q->(dbSetOrder(1)) //N7Q_FILIAL+N7Q_CODINE
	If N7Q->(dbSeek( xFilial( "N7Q" ) + cCodIE) )
		nQtdMaxima := (N7Q->N7Q_LIMMAX * ((100 - N7Q->N7Q_PERMAX) / 100)) // Validação Qtd máxima da instrução, se N7Q_LIMMAX for zero então o limite será os fardos vinculados na IE
		nQtdTotIE  :=  nVlrPsLq + nQtdIE

		If nQtdMaxima > 0 .and. nQtdTotIE > nQtdMaxima
			lRet := .F.
			cMsg += STR0052 + cCodIE + _CRLF   //Instrução de Embarque:
			cMsg += STR0056 + _CRLF + _CRLF //Total do Peso Líquido dos fardos vinculados acima do permitido na Instrução de Embarque.
			cMsg += STR0057 + cValToChar(nQtdMaxima) + _CRLF + _CRLF  //"Qtd. Máx. permitida na Instrução de Embarque: "
			cMsg += STR0058 + cValToChar(nQtdTotIE) + _CRLF + _CRLF   //"Qtd. Vinculada:" 
		EndIf

	EndIf

	If !Empty(cMsg) 
		MsgAlert(cMsg)
	endif 	

	RestArea( aAreaAtu )
	RestArea( aAreaN7Q )
Return lRet


/**-------------------------------------------------------------------------------------
{Protheus.doc} AGRXTVFBIE
Retorna se o bloco do fardo foi seleciondo fardos("1") ou digitado quantidade de fardos("2") 

@return:	cMarc - "1"=Fardos Selecionados/marcados; "2"=digitado quantidade de fardos no bloco da IE
@author: 	claudineia.reinert
@since: 	26/12/2017
@Uso: 		OGA250
-------------------------------------------------------------------------------------**/
Function AGRXTVFBIE(pcIE, pcFilori, pcBloco)
	Local cMarc := ""
	Local aAreaAtu 		:= GetArea()
	Local aAreaN83 		:= N83->( GetArea() )

	dbSelectArea("N83")
	N83->(dbSetOrder(2)) //N83_FILIAL+N83_CODINE+N83_FILORG+N83_BLOCO
	If N83->(dbSeek(xFilial("N83") + pcIE + pcFilori + pcBloco)) //posiciona no bloco do fardo
		cMarc := N83->N83_FRDMAR //selecionado fardos("1") ou digitado quantidade("2")
	EndIf 	

	RestArea(aAreaN83)
	RestArea(aAreaAtu)

Return cMarc


/*/{Protheus.doc} QtdN9DBlc
//Quantidade que ja foi utilizada deste bloco
@author carlos.augusto
@since 21/05/2018
@version undefined
@param cCodine, characters, descricao
@param cSafra, characters, descricao
@param cBloco, characters, descricao
@param cCodAut, characters, descricao
@param cItemAc, characters, descricao
@param cCodRom, characters, descricao
@type function
/*/
Static Function QtdN9DBlc(cCodine, cSafra, cBloco, cCodAut, cItemAc, cCodRom)
	Local nQtd 		:= 0
	Local oModel	:= FwModelActive()
	Local oMldN9D 	:= A500MdlN9D(oModel)
	Local nX
	Local cQry := ""
	Local cAliasQry 	:= GetNextAlias()
	
	For nX := 1 to oMldN9D:Length()
		oMldN9D:GoLine(nX)
		If .Not. oMldN9D:IsDeleted() .And. .Not. Empty(oMldN9D:GetValue("N9D_SAFRA")) ;
			.AND. cCodine == oMldN9D:GetValue("N9D_CODINE");
			.AND. cSafra  == oMldN9D:GetValue("N9D_SAFRA");
			.AND. cBloco  == oMldN9D:GetValue("N9D_BLOCO");
			.AND. cCodAut == oMldN9D:GetValue("N9D_CODAUT");
			.AND. cItemAc == oMldN9D:GetValue("N9D_ITEMAC")
			nQtd++
		EndIf
	Next nX

	cQry := " SELECT COUNT(N9D_FARDO) AS QTDFRD"
	cQry += " FROM " + RetSQLName("N9D") + " N9D"
	cQry += " WHERE N9D.D_E_L_E_T_ = ' ' "
	cQry += " AND N9D_FILIAL = '" + FwxFilial( 'N9D' ) + "' "
	cQry += " AND N9D_SAFRA = '" + cSafra + "' "
	cQry += " AND N9D_CODINE = '" + cCodine + "' "
	cQry += " AND N9D_BLOCO = '" + cBloco + "'  "
	
	If __lAgra550
		cQry += " AND (N9D_TIPMOV = '07' OR N9D_TIPMOV = '11')"
	Else
		cQry += " AND N9D_TIPMOV = '07' "
	EndIf
	cQry += " AND N9D_STATUS = '1'
//	cQry += " AND " + cCampoRom + " <> '' " //DEFERENTE DE BRANCO
	cQry += " AND N9D_CODROM <> '" + cCodRom + "'  " //DIFERENTE DO ROMANEIO ATUAL
	cQry := ChangeQuery( cQry ) 
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	If (cAliasQry)->( !Eof() )        
		nQtd += (cAliasQry)->QTDFRD 
	EndIf
	(cAliasQry)->(dbCloseArea())

Return nQtd


/*/{Protheus.doc} AGRN9DCOPY
//Realiza a copia do ultimo registro do fardo
@author carlos.augusto/claudineia.reinert
@since 21/05/2018
@version undefined
@param cSafra, characters, descricao
@param cEtiq, characters, descricao
@type function
/*/
Function AGRN9DCOPY(cSafra, cEtiq)
	Local oModel	:= FwModelActive()
	Local oMldN9D 	:= A500MdlN9D(oModel)
	Local cAliasQry := GetNextAlias()
	Local aStruct	:= {}
	Local nItStr
	Local cQry
	Local dDataCpo
	aStruct := N9D->(dBStruct()) // Obtém a estrutura
	
	cQry := " SELECT N9D.* "
	cQry += "   FROM " + RetSqlName("N9D") + " N9D "
	cQry += "  WHERE N9D.N9D_FILIAL = '"+ FwxFilial("N9D") +"' "   // D MG 01
	cQry += "    AND N9D.N9D_SAFRA  = '"+ cSafra +"' "   // D MG 01 
	cQry += "    AND N9D.N9D_FARDO  = '"+ cEtiq +"' "
	cQry += "    AND N9D.D_E_L_E_T_ = ' ' "
	cQry += "    AND N9D_IDMOV IN (SELECT MAX(N9D2.N9D_IDMOV) "				
	cQry += "	                     FROM " + RetSqlName("N9D") + " N9D2 "
	cQry += "	                    WHERE N9D2.N9D_FILIAL = N9D.N9D_FILIAL "
	cQry += "	                      AND N9D2.N9D_SAFRA  = N9D.N9D_SAFRA "
	cQry += "		                  AND N9D2.N9D_FARDO  = N9D.N9D_FARDO AND N9D2.D_E_L_E_T_ = ' ') "	
	cQry := ChangeQuery(cQry)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.F.,.T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	
	If (cAliasQry)->(!Eof())												
		For nItStr := 1 To Len(aStruct)
			// Apenas insere no array (aDados) os campos que não estão no array
			If AllTrim(aStruct[nItStr][1]) == "N9D_IDMOV"	                    		
				oMldN9D:LoadValue("N9D_IDMOV", Soma1((cAliasQry)->N9D_IDMOV))
			Else
				If .Not. Empty((cAliasQry)->&(AllTrim(aStruct[nItStr][1])))
					If TamSX3(aStruct[nItStr][1])[3] == 'D'
						dDataCpo := STOD((cAliasQry)->&(AllTrim(aStruct[nItStr][1])))
						oMldN9D:LoadValue(aStruct[nItStr][1], dDataCpo)
					Else
						oMldN9D:LoadValue(aStruct[nItStr][1], (cAliasQry)->&(AllTrim(aStruct[nItStr][1])))
					EndIF
				EndIf
			EndIf
			//EndIf
		Next nItStr
	EndIf																	 	
	(cAliasQry)->(DbCloseArea())
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
	Local oMldNJJ 	:= A500MdlNJJ(oModel)
	Local oMldNJM 	:= A500MdlNJM(oModel)
	Local oMldN9E 	:= A500MdlN9E(oModel) //Itens do Romaneio
	Local oMldN9D 	:= A500MdlN9D(oModel) //Fardos do Romaneio
	Local nX		:= 0
	Local nY		:= 0
	Local nZ		:= 0
	Local nMov		:= 0
	Local lDelete	:= .F.	
	Local nEmbalagem 	:= 0
	Local dPesoI 	:= 0
	Local dPesoF 	:= 0
	Local nM		:= 1
	Local cLotFar 	:= ''
	Local nLinha	:= 0
	
	If oModel:GetOperation() == MODEL_OPERATION_VIEW
		oDlg:End()
		Return
	EndIf
	
	//Se a quantidade de fardos vinculados é menor ou igual a quantidade máxima de fardinhos 
	// que podem ser vinculados ao romaneio ou a quantidade informada for zero, efetua a garavaçao. 
	//Senão, não deixa fechar a tela.
	if oMldNJJ:GetValue("NJJ_QTDFAR") = 0 .OR. Len(_aItsDirt) <= oMldNJJ:GetValue("NJJ_QTDFAR")	
		//Esta fazendo um looping nos fardos que ja estao no modelo e nao foram mantidos ao salvar
		//Ou seja, vai deletar do modelo.
		//Tambem sera removido (o fardo) do array para facilitar a adicao de elementos posteriormente
		For nX := 1 to oMldN9D:Length()
			oMldN9D:GoLine( nX )
			If .Not. oMldN9D:IsDeleted() .And. ((Empty(oMldN9D:GetValue("N9D_FARDO")) ;//Se a etiqueta esta vazia, eh a primeira linha do modelo
				 .OR. oMldN9D:GetValue("N9D_SEQUEN") == oMldN9E:GetValue("N9E_SEQUEN")) ;
				 .OR. __lOga250 .OR. __lOga251 ) 
				lDelete := .T.
				For nZ := 1 To Len(_aItsDirt)
					If _aItsDirt[nZ] != Nil
						If oMldN9D:GetValue("N9D_FILIAL") == _aItsDirt[nZ][2] .And.;
						oMldN9D:GetValue("N9D_SAFRA") == _aItsDirt[nZ][4] .And.;
						oMldN9D:GetValue("N9D_BLOCO") == _aItsDirt[nZ][5] .And.;
						oMldN9D:GetValue("N9D_FARDO") == _aItsDirt[nZ][6]
	
							lDelete := .F.
							If oMldN9D:GetValue("N9D_TIPMOV") = '07' .OR. oMldN9D:GetValue("N9D_TIPMOV") = '11'
								ADel( _aItsDirt, nZ )
							EndIf
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
			
				DbSelectArea("DXI")
				DXI->(DbSetOrder(1))
				If DXI->(DbSeek(FwXFilial("DXI") + _aItsDirt[nY][4] + _aItsDirt[nY][6]))
					dPesoI := IIF( DXI->DXI_PSESTO > 0 , DXI->DXI_PSESTO , DXI->DXI_PSLIQU )
					
					//Uusar o peso certificado, ou peso saida ou peso liquido
					IF DXI->DXI_PESCER > 0 
						dPesoF := DXI->DXI_PESCER 
					ElseIf DXI->DXI_PESSAI > 0
						dPesoF := DXI->DXI_PESSAI
					Else   
						dPesoF := DXI->DXI_PSLIQU
					EndIF   
						
				EndIf
			
			
				For nMov := 1 To 2
					
					If .Not. Empty(DXI->DXI_CODINE) .or. _aIEORRF[1] != 1
						nMov := 2 //Nao adiciona tipo '04' na N9D, porque o fardo foi marcado na IE ou não usa IE no romaneio
					EndIf
					oMldN9D:AddLine()
					oMldN9D:GoLine( oMldN9D:Length())
					//Insere o ultimo movimento do fardo na linha da N9D
					AGRN9DCOPY(_aItsDirt[nY][4],  _aItsDirt[nY][6]  )					
					
					oMldN9D:LoadValue("N9D_CODINE", _aItsDirt[nY][3])
					If _aIEORRF[1] == 1 //Usa IE, vincula fardo com N9E
						If __lAgra500 .Or. __lAgra550 .Or. __lGfea523
							oMldN9D:LoadValue("N9D_SEQUEN", oMldN9E:GetValue("N9E_SEQUEN"))
							oMldN9D:LoadValue("N9D_ITEMAC", oMldN9E:GetValue("N9E_ITEMAC"))
							oMldN9D:LoadValue("N9D_CODAUT", oMldN9E:GetValue("N9E_CODAUT"))
						Else
							nLinha := oMldN9E:getLine()
							For nX := 1 to oMldN9E:Length()
								oMldN9E:goLine(nX)
								If oMldN9D:GetValue("N9D_CODINE") == oMldN9E:GetValue("N9E_CODINE") 
									oMldN9D:LoadValue("N9D_SEQUEN", oMldN9E:GetValue("N9E_SEQUEN"))
									oMldN9D:LoadValue("N9D_ITEMAC", oMldN9E:GetValue("N9E_ITEMAC"))
									oMldN9D:LoadValue("N9D_CODAUT", oMldN9E:GetValue("N9E_CODAUT"))
									Exit 
								EndIf
							next nX
							oMldN9E:goLine(nLinha)
						EndIf
					ElseIf _aIEORRF[1] == 2 .and. nMov == 2 //vincula fardo com NJM e movimento 07(romaneio)
						nLinha := oMldNJM:getLine()
						For nX := 1 to oMldNJM:Length()
							oMldNJM:goLine(nX)
							If oMldNJM:GetValue("NJM_CODCTR") == oMldN9D:GetValue("N9D_CODCTR") .AND. ;
							   oMldNJM:GetValue("NJM_ITEM") == oMldN9D:GetValue("N9D_ITEETG") .AND. ;
							   oMldNJM:GetValue("NJM_SEQPRI") == oMldN9D:GetValue("N9D_ITEREF") 
							   //MESMO QUE NJM TENHA 2 LINHAS COM MESMO REGRA FISCAL USA A PRIMEIRA QUE ENCONTRA PARA VINCULAR O FARDO, NO ATUALIZAR SERÁ AJUSTADO SE NECESSARIO
								oMldN9D:LoadValue("N9D_ITEROM", oMldNJM:GetValue("NJM_ITEROM"))
								Exit 
							EndIf
						next nX
						oMldNJM:goLine(nLinha)
					EndIf						
					//----OGA250--------
					oMldN9D:LoadValue("N9D_CODROM", oMldNJJ:GetValue("NJJ_CODROM"))
					oMldN9D:LoadValue("N9D_TIPOPE", POSICIONE("NJM" , 1 , FwxFilial("NJM") + oMldNJJ:GetValue("NJJ_CODROM") , "NJM_SUBTIP" ) )
					//----OGA250--------
					
					oMldN9D:LoadValue("N9D_PESFIM", _aItsDirt[nY][9])
					oMldN9D:LoadValue("N9D_CODCTR", _aItsDirt[nY][15])
					oMldN9D:LoadValue("N9D_ITEETG", _aItsDirt[nY][16])
					oMldN9D:LoadValue("N9D_ITEREF", _aItsDirt[nY][17])
					
					
									
					//Campos complementares
					If nMov == 1
						//cria tipo 04 pois na IE não foi selecionado o fardo mas sim digitado qtd do bloco
						oMldN9D:LoadValue("N9D_TIPMOV", '04')
						oMldN9D:LoadValue("N9D_STATUS", '2')
						oMldN9D:LoadValue("N9D_FILORG", FwXFilial("N7Q"))
					Else
						oMldN9D:LoadValue("N9D_FILORG", FwXFilial("NJJ"))
						If __lAgra550
							oMldN9D:LoadValue("N9D_TIPMOV", '11')
						Else
							oMldN9D:LoadValue("N9D_TIPMOV", '07')
						EndIf
						oMldN9D:LoadValue("N9D_STATUS", '1')
						oMldN9D:LoadValue("N9D_IDMOV", Soma1(oMldN9D:GetValue("N9D_IDMOV")))
						oMldN9D:LoadValue("N9D_LOCAL",  oMldNJJ:GetValue("NJJ_LOCAL"))
						oMldN9D:LoadValue("N9D_ENTLOC", oMldNJJ:GetValue("NJJ_CODENT"))
						oMldN9D:LoadValue("N9D_LOJLOC", oMldNJJ:GetValue("NJJ_LOJENT"))
					EndIf
					
					oMldN9D:SetValue("N9D_DATA", dDatabase)
					
				Next nMov
			EndIf
		Next nY
		
		nEmbalagem := A500FPSEMB(oModel)
		oMldNJJ:SetValue("NJJ_PESEMB", nEmbalagem )
		
		//Caso ja tenha efetuado a pesagem, atualiza o peso liquido
		If oMldNJJ:GetValue("NJJ_PSLIQU") <> 0
			oMldNJJ:LoadValue("NJJ_PSLIQU", oMldNJJ:GetValue("NJJ_PSSUBT") - (oMldNJJ:GetValue("NJJ_PSDESC") + oMldNJJ:GetValue("NJJ_PSEXTR")+ nEmbalagem) )
			oMldNJJ:LoadValue("NJJ_PESO3", oMldNJJ:GetValue("NJJ_PSLIQU") )
		EndIf
		
		If ValType(_aItsDirt) == "A"
			//Atualiza o campo de lote da NJM quando 
			If .Not. Empty(_aItsDirt) .AND. .NOT. Empty(_aItsDirt[1])
				cLotFar := POSICIONE("DXI",1,FwXFilial("DXI") + oMldNJJ:GetValue( "NJJ_CODSAF" ) + _aItsDirt[1][6],"DXI_LOTE")
			EndIf

			nLinha := oMldNJM:getLine()
			For nM := 1 to oMldNJM:Length()
				oMldNJM:goLine(nM)
				oMldNJM:LoadValue("NJM_LOTCTL", cLotFar)
			next nM
			oMldNJM:goLine(nLinha)
		
			If lRet 
				ASize( aColsLoad, 0 )
				oDlg:End()
			EndIf
		EndIF
	else
		//"Número de fardinhos vinculados maior que o informado na tela de romaneio. " //"Qtd. Máxima: "
		MsgAlert( STR0061 + _CRLF + STR0062 + cValToChar(oMldNJJ:GetValue("NJJ_QTDFAR"))) 
	endIf

Return 


/*/{Protheus.doc} AGRX500FAR
//Permite vincular fardos no romaneio pelo registro posicionado
@author carlos.augusto/claudineia.reinert
@since 21/05/2018
@version undefined
@type function
/*/
Function AGRX500FAR()
	Local oModelRom := FwLoadModel("OGA250")
	Local lRet		:= .T.
	
	oModelRom:SetOperation( MODEL_OPERATION_UPDATE )
	
	If .not. oModelRom:Activate() //se não ativar o modelo
		//OGA250 no SetVldActivate valida o status do romaneio não permitindo ativar 
		Help( , , STR0021, , oModelRom:GetErrorMessage()[6] + "-" + oModelRom:GetErrorMessage()[7], 1, 0 )
		Return .F.
	EndIf
	
	AGRX500AVF(NJJ->NJJ_CODCTR, NJJ->NJJ_CODROM)

	lRet := oModelRom:VldData()		

	If .Not. lRet
		Help( , , STR0021, , oModelRom:GetErrorMessage()[6] + "-" + oModelRom:GetErrorMessage()[7], 1, 0 )
	EndIf
	
	If lRet .AND. _lVincFard
		AGRX500FCM(oModelRom)	
	EndIf

	// Se os dados foram validados faz-se a gravação efetiva dos dados (commit)
	If lRet .AND. _lVincFard
		lRet := FWFormCommit(oModelRom)
	EndIf

Return lRet


/*/{Protheus.doc} AGRX500FCM
//Atualizacoes que devem ser realizadas na DXI e NJM
@author carlos.augusto/claudineia.reinert
@since 21/05/2018
@version undefined
@param oModel, object, descricao
@type function
/*/
Function AGRX500FCM(oModel)
	Local lRet := .F.
	Local oMldNJJ 	:= Nil 
	Local oMldN9E 	:= Nil 
	Local oMldN9D 	:=  Nil
	Local nX
	Local cFrdMar
	Local nEmbalagem := 0
	Local cCampoRom 
	Local nQtdAux := 0
	Local nQtdFco := 0
	Local nPerDiv := 0
	Local nDecPeso := SuperGetMV("MV_OGDECPS",,0)
	
	oMldNJJ	:= A500MdlNJJ(oModel) //Romaneio
	oMldN9E	:= A500MdlN9E(oModel) //Itens do Romaneio
	oMldN9D	:= A500MdlN9D(oModel) //Fardos do Romaneio
	oMldNJM	:= A500MdlNJM(oModel) //Comercializacao
	
	dbSelectArea("DXI")
	DXI->(dbSetOrder(1)) //FILIAL+SAFRA+ETIQ	

	cCampoRom := AGR500BRMSAI(oMldNJJ:GetValue("NJJ_CODROM"),oModel)

	For nX := 1 to oMldN9D:Length()
		oMldN9D:GoLine( nX )
		cFrdMar := AGRXTVFBIE(oMldN9D:GetValue("N9D_CODINE"), oMldN9D:GetValue("N9D_FILIAL"), oMldN9D:GetValue("N9D_BLOCO") )
		If DXI->(MsSeek(FwXFilial("DXI") + oMldN9D:GetValue( "N9D_SAFRA" ) + oMldN9D:GetValue( "N9D_FARDO" )))
			If RecLock( "DXI", .F. )
				If .Not. oMldN9D:IsDeleted() .And. oModel:GetOperation() != MODEL_OPERATION_DELETE
					&("DXI->"+cCampoRom+" := '"+oMldNJJ:GetValue("NJJ_CODROM")+"' ")
					If cFrdMar == '2' 
						DXI->DXI_CODINE := oMldN9D:GetValue("N9D_CODINE")
					EndIf
					//incluir(1) status do fardo na DXI(DXI_STATUS)
					AGRXFNSF( 1 , "RomaneioVin") 
	
					nEmbalagem += DXI->DXI_PSTARA
					
				Else
					&("DXI->"+cCampoRom+" := '' ")
					If cFrdMar = '2'
						DXI->DXI_CODINE := ''
					EndIf
					//retorna(2) status do fardo na DXI(DXI_STATUS)
					If oMldN9D:GetValue("N9D_STATUS") $ '1|2' //FARDO PREVISTO|ATIVO
						If AllTrim(DXI->DXI_STATUS) == "80"
							//Ao Excluir romaneio global futura
							AGRXFNSF( 2 , "RomaneioFut") 
						Else
							AGRXFNSF( 2 , "RomaneioVin") 
						EndIf	
					EndIf
				EndIf
	
				DXI->( msUnLock() )
			EndIf
		EndIf
	Next nX


	If oModel:GetOperation() != MODEL_OPERATION_DELETE .And. !__lAgra550
		nLinha := oMldNJM:GoLine()
		For nX := 1 to oMldNJM:Length()
			oMldNJM:GoLine( nX )
			If .Not. oMldNJM:IsDeleted()
				nQtdAux := Round( ( oMldNJJ:GetValue("NJJ_PESO3") * ( oMldNJM:GetValue("NJM_PERDIV") / 100 ) ), nDecPeso )
				nQtdFco += nQtdAux
				nPerDiv += oMldNJM:GetValue("NJM_PERDIV")
				oMldNJM:SetValue("NJM_QTDFCO",nQtdAux)
			EndIf
		Next nX
				
		// Ajusta em caso de diferença de arredondamento
		If oMldNJJ:GetValue("NJJ_PSLIQU") <> nQtdFco 
			oMldNJM:GoLine(1)
			oMldNJM:SetValue("NJM_QTDFCO", oMldNJM:GetValue("NJM_QTDFCO") + oMldNJJ:GetValue("NJJ_PESO3") - nQtdFco)
		EndIf
		oMldNJM:GoLine(nLinha)
		
	EndIf	

Return lRet


/*/{Protheus.doc} PesoEmbal / A500FPESEM 
//Atualiza peso da Embalagem na NJJ

//*Alteração de Static para Function, pois foi necessário utilizar 
//em outra função. 
//*Alteração do nome para A500FPSEMB 

@author carlos.augusto
@since 22/05/2018
@version undefined
@type function
/*/
Function A500FPSEMB(oModel)
	Local nEmbalagem := 0
	Local oMldN9D 	:=  Nil
	Local nX
	
	oMldN9D	:= A500MdlN9D(oModel) //Fardos do Romaneio

	dbSelectArea("DXI")
	DXI->(dbSetOrder(1)) //FILIAL+SAFRA+ETIQ	

	For nX := 1 to oMldN9D:Length()
		oMldN9D:GoLine( nX )
		If oMldN9D:GetValue( "N9D_TIPMOV" ) == '07'
			If DXI->(MsSeek(FwXFilial("DXI") + oMldN9D:GetValue( "N9D_SAFRA" ) + oMldN9D:GetValue( "N9D_FARDO" )))
				If .Not. oMldN9D:IsDeleted() .And. oModel:GetOperation() != MODEL_OPERATION_DELETE
					nEmbalagem += DXI->DXI_PSTARA
				EndIf
			EndIf
		EndIf
	Next nX

Return nEmbalagem


/*/{Protheus.doc} A500MdlNJJ
//Retorna submodelo NJJ
@author carlos.augusto
@since 04/06/2018
@version undefined
@param oModel, object, descricao
@type function
/*/
Function A500MdlNJJ(oModel)
	Local oMldNJJ := Nil 

	Do Case
		Case __lAgra500 .Or. __lGfea523
			oMldNJJ := oModel:GetModel( "AGRA500_NJJ" )
		Case __lAgra550
			oMldNJJ := oModel:GetModel( "AGRA550_NJJ" )
		OtherWise
			oMldNJJ := oModel:GetModel( "NJJUNICO" )
	EndCase

Return oMldNJJ


/*/{Protheus.doc} A500MdlN9E
//Retorna submodelo N9E
@author carlos.augusto
@since 04/06/2018
@version undefined
@param oModel, object, descricao
@type function
/*/
Function A500MdlN9E(oModel)
	Local oMldN9E := Nil 

	Do Case
		Case __lAgra500 .Or. __lGfea523
			oMldN9E := oModel:GetModel( "AGRA500_N9E" )
		Case __lAgra550
			oMldN9E := oModel:GetModel( "AGRA550_N9E" )
		OtherWise
			oMldN9E := oModel:GetModel( "N9EUNICO" )
	EndCase

Return oMldN9E


/*/{Protheus.doc} A500MdlN9D
//Retorna submodelo N9D
@author carlos.augusto
@since 04/06/2018
@version undefined
@param oModel, object, descricao
@type function
/*/
Function A500MdlN9D(oModel)
	Local oMldN9D := Nil 

	Do Case
		Case __lAgra500 .Or. __lGfea523
			oMldN9D := oModel:GetModel( "AGRA500_N9D" )
		Case __lAgra550
			oMldN9D := oModel:GetModel( "AGRA550_N9D" )
		OtherWise
			oMldN9D := oModel:GetModel( "N9DUNICO" )
	EndCase

Return oMldN9D


/*/{Protheus.doc} A500MdlNJM
//Retorna submodelo NJM
@author carlos.augusto
@since 04/06/2018
@version undefined
@param oModel, object, descricao
@type function
/*/
Function A500MdlNJM(oModel)
	Local oMldNJM := Nil 

	Do Case
		Case __lAgra500 .Or. __lGfea523
			oMldNJM := oModel:GetModel( "AGRA500_NJM" )
		Case __lAgra550
			oMldNJM := oModel:GetModel( "AGRA550_NJM" )
		OtherWise
			oMldNJM := oModel:GetModel( "NJMUNICO" )
	EndCase

Return oMldNJM


/*/{Protheus.doc} SafraN7Q
//Retorna a safra da IE
@author carlos.augusto
@since 07/06/2018
@version undefined
@param cCodine, characters, descricao
@type function
/*/
Static Function SafraN7Q(cCodine)
	Local cSafra := ""
	
	DbSelectArea("N7Q")
	DbSetOrder(1)
	If N7Q->(DbSeek(FwxFilial("N7Q") + cCodine))
		cSafra := N7Q->N7Q_CODSAF
	EndIf

Return cSafra
