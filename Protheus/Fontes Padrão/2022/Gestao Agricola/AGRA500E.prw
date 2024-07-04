#include 'protheus.ch'
#include 'parmtype.ch'
#include 'AGRA500E.ch'

#DEFINE _CRLF CHR(13)+CHR(10)

Static __oOK	    := LoadBitmap(GetResources(),'LBOK')
Static __oNo     	:= LoadBitmap(GetResources(),'LBNO')
Static __lMarcAllE	:= .T.
Static __lMarcAllD	:= .T.


/*/{Protheus.doc} AGRA500E
//Rotina responsável pela montagem da tela de vínculo fardão x romaneio
@author brunosilva
@since 16/01/2018
@version undefined
@param cPar01, char, NJJ_CODVAR
@param cPar02, char, NJJ_TALHAO
@param cPar03, char, NJJ_FAZ
@param cPar04, char, NJJ_CODROM
@param cPar05, char, NJJ_CODENT
@param cPar06, char, NJJ_CODSAF
@type function
/*/
Function AGRA500E(cPar01, cPar02, cPar03, cPar04, cPar05, cPar06, cPar07, _aItsEsq)
	Local oSize2 	 	:= FWDefSize():New(.F.)
	Local oSize3 	 	:= FWDefSize():New(.F.)
	Local oSize4 	 	:= FWDefSize():New(.F.)
	Local oDlg		 	:= Nil
	Local oFWLayer	 	:= Nil
	Local oBtBarEsq	 	:= Nil
	Local oBtBarDir	 	:= Nil
	Local aCoors	 	:= FWGetDialogSize( oMainWnd )
	Local cChavEsq	 	:= Space(10)
	Local cChavDir	 	:= Space(10)
	Local nOpcA 	 	:= 0
	Local cPesqEsq 	 	:= Space(TamSX3("DXL_CODIGO")[1])
	Local cPesqDir 	 	:= cPesqEsq
	Local oModel     	:= FWModelActive()
	Local oMldNJM		:= IIF(FwIsInCallStack("AGRA500") .OR. FwIsInCallStack("GFEA523"),oModel:GetModel('AGRA500_NJM'),oModel:GetModel('NJMUNICO'))
	Local nX			:= 0 
	Local lAlgodao		:= .F.
	Local cHelp			:= ""
	
	Private _oBrwEsq
	Private _oBrwDir
	Private _nOp       	:= oModel:getOperation()
	Private _aItsDir   	:= {}
	Private _nPeso     	:= 0
	Private _nPesoEst  	:= 0
	Private _nPesoOrig 	:= 0
		
	Private _cCodVar   	:= IIF(EMPTY(cPar01),' ',cPar01)
	Private _cTalhao   	:= IIF(EMPTY(cPar02),' ',cPar02)
	Private _cFaz      	:= IIF(EMPTY(cPar03),' ',cPar03)
	Private _cCodRom   	:= IIF(EMPTY(cPar04),' ',cPar04)
	Private _cCodEnt   	:= IIF(EMPTY(cPar05),' ',cPar05)
	Private _cCodSaf   	:= IIF(EMPTY(cPar06),' ',cPar06)
	Private _cCodPro   	:= IIF(EMPTY(cPar07),' ',cPar07)
	
	Default _aItsEsq   	:= {}
	
	/*SAFRA, PRODUTO, FAZENDA E ENTIDADE/LOJA SÃO OBRIGATÓRIOS PARA O VINCULO DE FARDÃO*/
	if oModel:getOperation() != 1
		if !(Empty(_cCodPro)) //Se o produto estiver preenchido
			lAlgodao := iif(Posicione("SB5",1,fwxFilial("SB5")+cPar07,"B5_TPCOMMO")== '2',.T.,.F.)
			if !lAlgodao
				Alert(STR0028)//"Não é possível vincular fardões para produtos diferentes de algodão. Caso o produto seja algodão, verifique se o campo Tipo de Commodity no cadastro de complemento do produto, na aba AGRO, está como 2 - Algodão."
				Return .F.
			else
				iif(EMPTY(_cCodSaf),cHelp := " Safra", iif(EMPTY(_cCodEnt),cHelp := " Entidade/Loja", iif(EMPTY(_cFaz),cHelp := " Fazenda",)))
				if !EMPTY(cHelp)
					Alert(STR0032 + cHelp + STR0033) //"Os campos Safra, Produto, Fazenda, Entidade e Loja são obrigatórios para o filtro dos fardões." //" não informado."
					Return .F.
				endIf
			endIf
		else
			Alert(STR0030) //"Produto não informado."
			Return .F.
		endIf
	endIf
	
	//aRet := StrTokArr ( NJJ->NJJ_OBS , ":" )
	//Caso necessite de alguma validação futura envolvendo os campos da observação.
	If _nOp = 4 .AND. (NJJ->NJJ_tipo = 'A' .AND. !(EMPTY(NJJ->NJJ_OBS)))
		If FwIsInCallStack("GFEA523")
			MsgInfo(STR0027)	//"Não é possível manipular os fardões vinculados pois este romaneio foi gerado a partir de outro."
			Return(.F.)
		Else
			Help( ,, STR0017,,STR0027, 1, 0,) //"Atenção" //"Não é possível manipular os fardões vinculados pois este romaneio foi gerado a partir de outro." 
			Return(.F.)
		EndIf
	EndIf

	//--Caso o parametro esteja preenchido com .T. 
	If SuperGetMV("MV_AGRPRFA",.F.,.F.)	
		//--Caso produto possua rastro por lote
		IF Rastro(_cCodPro,"N")
			For nX := 1 to oMldNJM:Length()
				oMldNJM:GoLine(nX)
				If .Not. oMldNJM:IsDeleted()
					If Empty( oMldNJM:GetValue("NJM_LOTCTL") )
						Help(" ",1,".AGRA500E0001.")	//O produto selecionado possui rastro por lote.#Favor informar o campo lote para selecionar os fardões.
						Return(.F.)
						Exit
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf
	
	__lMarcAllD 	   := .T. //marca tudo painel direito - varivel static
	__lMarcAllE 	   := .T. //marca tudo painel esquerdo - varivel static
	
	//----- TELA PARA SELECIONAR FARDOES
	//- Coordenadas da area total da Dialog
	oSize:= FWDefSize():New(.T.)
	oSize:AddObject("DLG",100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.
	oSize:aMargins := {0,0,0,0}
	oSize:Process()

	DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4];
	TITLE STR0001 OF oMainWnd PIXEL //"Vínculo de Fardões por Romaneio"

	oPnl1:= tPanel():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],,oDlg,,,,,,oSize:aPosObj[1,4],oSize:aPosObj[1,3])
	//---------------------------
	// Cria instancia do fwlayer
	//---------------------------
	oFWLayer := FWLayer():New()
	oFWLayer:init( oPnl1, .F. )

	oFWLayer:AddCollumn( 'ESQ' , 45, .F.)
	oFWLayer:AddCollumn( 'MEIO', 10, .F.)
	oFWLayer:AddCollumn( 'DIR' , 45, .F.)

	oFWLayer:addWindow( "ESQ" , "Wnd1", STR0002, 90, .F., .T.) 
	oFWLayer:addWindow( "DIR" , "Wnd2", STR0003, 90, .F., .T.) 
	
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
	@ 0, 0 MSGET cPesqDir SIZE 50,10 PIXEL OF oBtBarDir PICTURE "@x"
	TButton():New(0,0,STR0004,oBtBarDir,{|| Pesquisa(cChavDir,Alltrim(cPesqDir),@_oBrwDir)},Len(STR0004)*4,10,,,,.T.,,) //"Pesquisa"

	//Carrega os itens na Grid de fardos já vinculados
	_aItsDir := LoadFarDir()

	_oBrwDir := TCBrowse():New( oSize4:aPosObj[1,1], oSize4:aPosObj[1,2], oSize4:aPosObj[1,3], oSize4:aPosObj[1,4], , , , oPnl4, , , , {|| }, {|| }, , , , , , , .f., , .t., , .f., , , )
	_oBrwDir:AddColumn( TCColumn():New(""	 , { || IIf( _aItsDir[_oBrwDir:nAt,1] == "1", __oOK, __oNo  ) },,,,"CENTER",010,.t.,.t.,,,,.f., ) )
	//_oBrwDir:AddColumn( TCColumn():New(STR0005 , { || _aItsDir[_oBrwDir:nAt,2] }  , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Filial"
	_oBrwDir:AddColumn( TCColumn():New(STR0006 , { || _aItsDir[_oBrwDir:nAt,3] }  , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Código"
	_oBrwDir:AddColumn( TCColumn():New(STR0007 , { || _aItsDir[_oBrwDir:nAt,4] }  , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Safra"
	_oBrwDir:AddColumn( TCColumn():New(STR0008 , { || _aItsDir[_oBrwDir:nAt,5] }  , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Entidade"
	_oBrwDir:AddColumn( TCColumn():New(STR0009 , { || _aItsDir[_oBrwDir:nAt,6] }  , , , , "LEFT" , 060, .f., .t., , , , .f., ) ) //"Fazenda"
	_oBrwDir:AddColumn( TCColumn():New(STR0010 , { || _aItsDir[_oBrwDir:nAt,7] }  , , , , "LEFT" , 040, .f., .t., , , , .f., ) ) //"Talhão"
	_oBrwDir:AddColumn( TCColumn():New(STR0011 , { || _aItsDir[_oBrwDir:nAt,8] }  , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Produto"
	_oBrwDir:AddColumn( TCColumn():New(STR0012 , { || _aItsDir[_oBrwDir:nAt,9] }  , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Variedade"
	_oBrwDir:AddColumn( TCColumn():New(STR0013 , { || _aItsDir[_oBrwDir:nAt,10] } , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Peso liquido"
	_oBrwDir:AddColumn( TCColumn():New(STR0014 , { || _aItsDir[_oBrwDir:nAt,11] } , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Peso estimado"

	_oBrwDir:SetArray( _aItsDir )
	_oBrwDir:bLDblClick 	:= {|| MarcaUm( _oBrwDir, _aItsDir, _oBrwDir:nAt)}
	_oBrwDir:bHeaderClick 	:= {|| MarcaTudo( _oBrwDir, _aItsDir, _oBrwDir:nAt, @__lMarcAllD, .F. ) }
	_oBrwDir:Align := CONTROL_ALIGN_ALLCLIENT
	_oBrwDir:Refresh(.T.)
	
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
	@ 0, 0 MSGET cPesqEsq SIZE 50,10 PIXEL OF oBtBarEsq PICTURE "@x"
	TButton():New(0,0, STR0004 ,oBtBarEsq,{|| Pesquisa(cChavEsq,Alltrim(cPesqEsq),@_oBrwEsq)},Len(STR0004)*4,10,,,,.T.,,) //"Pesquisa"###'Pesquisa'
	
	//**************************
	//Monta browse da esquerda
	//**************************
	_aItsEsq := LoadFardos()

	_oBrwEsq := TCBrowse():New( oSize4:aPosObj[1,1], oSize4:aPosObj[1,2], oSize4:aPosObj[1,3], oSize4:aPosObj[1,4], , , , oPnl2, , , , {|| }, {|| }, , , , , , , .f., , .t., , .f., , , )
	_oBrwEsq:AddColumn( TCColumn():New(""	 , { || IIf( _aItsEsq[_oBrwEsq:nAt,1] == "1", __oOK, __oNo  ) },,,,"CENTER",010,.t.,.t.,,,,.f., ) )
	//_oBrwEsq:AddColumn( TCColumn():New(STR0005, { || _aItsEsq[_oBrwEsq:nAt,2] }  , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Filial"
	_oBrwEsq:AddColumn( TCColumn():New(STR0006, { || _aItsEsq[_oBrwEsq:nAt,3] }  , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Código"
	_oBrwEsq:AddColumn( TCColumn():New(STR0007, { || _aItsEsq[_oBrwEsq:nAt,4] }	 , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Safra"
	_oBrwEsq:AddColumn( TCColumn():New(STR0008, { || _aItsEsq[_oBrwEsq:nAt,5] }	 , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Entidade"
	_oBrwEsq:AddColumn( TCColumn():New(STR0009, { || _aItsEsq[_oBrwEsq:nAt,6] }	 , , , , "LEFT" , 060, .f., .t., , , , .f., ) ) //"Fazenda"
	_oBrwEsq:AddColumn( TCColumn():New(STR0010, { || _aItsEsq[_oBrwEsq:nAt,7] }	 , , , , "LEFT" , 040, .f., .t., , , , .f., ) ) //"Talhão"
	_oBrwEsq:AddColumn( TCColumn():New(STR0011, { || _aItsEsq[_oBrwEsq:nAt,8] }  , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Produto"
	_oBrwEsq:AddColumn( TCColumn():New(STR0012, { || _aItsEsq[_oBrwEsq:nAt,9] }  , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Variedade"
	_oBrwEsq:AddColumn( TCColumn():New(STR0013, { || _aItsEsq[_oBrwEsq:nAt,10] } , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Peso liquido"
	_oBrwEsq:AddColumn( TCColumn():New(STR0014, { || _aItsEsq[_oBrwEsq:nAt,11] } , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Peso estimado"
	
	_oBrwEsq:SetArray( _aItsEsq )
	_oBrwEsq:bLDblClick 		:= {|| MarcaUm( _oBrwEsq, _aItsEsq, _oBrwEsq:nAt)}
	_oBrwEsq:bHeaderClick 	:= {|| MarcaTudo( _oBrwEsq, _aItsEsq, _oBrwEsq:nAt, @__lMarcAllE, .F. ) }
	_oBrwEsq:Align := CONTROL_ALIGN_ALLCLIENT
	_oBrwEsq:Refresh(.T.)

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
	TButton():New( (oSize3:APOSOBJ[1][3]/2)-44, oSize3:APOSOBJ[1][1]+5, ">>" , oPnl3, {|| MovFardos( ">", @_oBrwEsq, @_oBrwDir, _aItsEsq, oModel:GetOperation() )}, oSize3:APOSOBJ[1][4]-10, 15, , /**oFont*/, , .t., , STR0023 ) //"Vincular Marcados"
	TButton():New( (oSize3:APOSOBJ[1][3]/2)-28, oSize3:APOSOBJ[1][1]+5, "<<" , oPnl3, {|| MovFardos( "<", @_oBrwEsq, @_oBrwDir, _aItsEsq, oModel:GetOperation() )}, oSize3:APOSOBJ[1][4]-10, 15, , /**oFont*/, , .t., , STR0024 ) //"Desvincular Marcados"

	_nQtde := Len(_aItsDir)
	
	//---------------------------------------------------------------------------------------------------
	// Apresenta calculos de peso total dos Fardos selecionados e quantidade de itens do romaneio na tela
	//---------------------------------------------------------------------------------------------------
	oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)-5,oSize3:APOSOBJ[1][1]+5,{|| Transform( STR0015 , "@!" )},oPnl3,,oFont,,; //"Quantidade"
	,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)
	oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)+5,oSize3:APOSOBJ[1][1]+5,{||  Alltrim(Transform( _nQtde, '@E 99999') )},oPnl3,,oFont,,;
	,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)
	oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)+15,oSize3:APOSOBJ[1][1]+5,{|| Transform( STR0016, "@!" )},oPnl3,,oFont,,; //"Peso Liquido"
	,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)
	oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)+25,oSize3:APOSOBJ[1][1]+5,{||Alltrim(Transform( _nPeso, PesqPict('DXL','DXL_PSLIQU')) )},oPnl3,,oFont,,;
	,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)

	oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)+35,oSize3:APOSOBJ[1][1]+5,{|| Transform( STR0031, "@!" )},oPnl3,,oFont,,; //"Peso Estimado"
	,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)
	oSay:= TSay():New((oSize3:APOSOBJ[1][3]/2)+45,oSize3:APOSOBJ[1][1]+5,{||Alltrim(Transform( _nPesoEst, PesqPict('DXL','DXL_PSLIQU')) )},oPnl3,,oFont,,;
	,,.T.,,,oSize3:APOSOBJ[1][4]-10,10)


	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg, {|| nOpcA:= 1, ExecGrv(@_oBrwDir, oDlg)},{|| nOpcA:= 2, ExecCancel(oDlg)})

Return

/*/{Protheus.doc} LoadFarDir
//Rotina que busca no banco os fardões que estão vinculados ao romaneio
@author brunosilva
@since 12/01/2018
@version undefined
@param oBrw, object, descricao
@type function
/*/
Static Function LoadFarDir(oBrw)
	Local aColsLoad := {}
	Local nCont	    := 0
	Local aRet		:= {}
	Local nX
	Local oModel	:= FwModelActive()
	Local oMldDX0   := oModel:GetModel('AGRA500_DX0') //Vinculo FardaoxRomaneio
	Local nPsEst	:= 0
	
	_nPeso := 0
	_nPesoEst := 0
	
	//Esta buscando os fardos que estao no modelo, em backgroud para posteriormente exibir na tela, atraves do array (lado direito)
	For nX := 1 to oMldDX0:Length()
		oMldDX0:GoLine( nX )
		If .Not. oMldDX0:IsDeleted()
			nCont++
			aRet := StrTokArr ( oMldDX0:GetValue( "DX0_CODUNI" ) , "-" )
			If .Not. Empty(oMldDX0:GetValue( "DX0_CODUNI" ))
				nPsEst := Posicione("DXL",2, FwxFilial("DXL") + oMldDX0:GetValue( "DX0_CODUNI" ), "DXL_PSESTI")
			
				aAdd( aColsLoad, { "2", oMldDX0:GetValue( "DX0_FILIAL" ), oMldDX0:GetValue( "DX0_FARDAO" ),;
				aRet[2], aRet[3], PADR(RTRIM(aRet[5]),TamSx3("DX0_FAZ")[1]," "),;
				oMldDX0:GetValue( "DX0_TALHAO" ), oMldDX0:GetValue( "DX0_CODPRO" ),;
				oMldDX0:GetValue( "DX0_CODVAR" ), oMldDX0:GetValue( "DX0_PSLIQU" ), nPsEst,;
				oMldDX0:GetValue( "DX0_CODUNI" ), oMldDX0:GetValue( "DX0_CODUNB" )  })
				_nPeso		+= oMldDX0:GetValue( "DX0_PSLIQU" )
				_nPesoEst	+= nPsEst
			EndIf
		EndIf
	Next nX
Return(aColsLoad)


/*/{Protheus.doc} LoadFardos
//Rotina que busca os fardões que não possuem vínculo com romaneios.
@author brunosilva
@since 12/01/2018
@version undefined

@type function
/*/
Static Function LoadFardos()
	Local aArea	        := GetArea() 
	Local aColsLoad	    := {}
	Local cAliasQry     := ""
	Local cQry 		    := ""
	Local nCont	        := 0  
	Local oModel		:= FwModelActive() 
	Local oMldNJJ 		:= IIF(FwIsInCallStack("AGRA500") .OR. FwIsInCallStack("GFEA523"), oModel:GetModel('AGRA500_NJJ'), oModel:GetModel('NJJUNICO'))
	Local oMldNJM 		:= IIF(FwIsInCallStack("AGRA500") .OR. FwIsInCallStack("GFEA523"), oModel:GetModel('AGRA500_NJM'), oModel:GetModel('NJMUNICO'))
	Local oMldDX0 	   	:= oModel:GetModel('AGRA500_DX0') //Vinculo FardaoxRomaneio
	Local cTipo			:= oMldNJJ:GetValue('NJJ_TIPO')
	Local cLoja			:= oMldNJJ:GetValue('NJJ_LOJENT')
	Local lNotIn	    := .F.
	Local nX
	
	cAliasQry := GetNextAlias()

	cQry := " SELECT DXL_FILIAL, DXL_CODIGO, DXL_SAFRA, DXL_PRDTOR, DXL_FAZ, DXL_TALHAO, DXL_CODPRO, DXL_CODVAR, DXL_PSLIQU, DXL_PSESTI, DXL_CODUNI, DXL_CODUNB "
	cQry += " FROM "+ RetSqlName("DXL") +" DXL "
	cQry += " WHERE DXL_FILIAL = '" + FWxFilial('DXL') + "' "
	cQry += " AND DXL_SAFRA     = '" + _cCodSaf + "' "
	cQry += " AND DXL_CODPRO    = '" + _cCodPro + "' "
	cQry += " AND DXL_PRDTOR    = '" + _cCodEnt + "' "
	cQry += " AND DXL_LJPRO     = '" + cLoja + "' "
	cQry += " AND DXL_FAZ       = '" + _cFaz + "' "
	iF !Empty(oMldNJJ:GetValue('NJJ_TALHAO'))
		cQry += " AND DXL_TALHAO    = '" + _cTalhao + "' "
	EndIF
	If !Empty(oMldNJJ:GetValue('NJJ_CODVAR'))
		cQry += " AND DXL_CODVAR    = '" + _cCodVar + "' "
	EndIf
	cQry += " AND D_E_L_E_T_<> '*' "	
	if cTipo $ '1|3|5|7|9|A'
		cQry += " AND DXL_STATUS  = '1'" //Status = Previsto
	ElseIf cTipo $ '2|4|6|8'
		cQry += " AND DXL_STATUS  = '3'"  //Status = Disponível	
	ElseIf cTipo = 'B'
		cQry += " AND (DXL_STATUS  = '1' OR DXL_STATUS  = '3')"  //Status = Previsto ou Disponível 	
	EndIF
			
	For nX := 1 to oMldDX0:Length()
		oMldDX0:GoLine(nX)
		If .Not. oMldDX0:IsDeleted()
			If lNotIn
				cQry += ","
			Else
				cQry += " AND DXL_CODUNI NOT IN("
				lNotIn := .T.
			EndIf
			cQry += "'"+ oMldDX0:GetValue("DX0_CODUNI") +"'"
		EndIf
	Next nX
	
	If lNotIn
		cQry += ")"
	EndIf
	
	//--Caso o parametro esteja preenchido com .T. 
	If SuperGetMV("MV_AGRPRFA",.F.,.F.) 
		//--Caso produto possua rastro por lote
		IF Rastro(_cCodPro,"N")
			lNotIn := .F.
			//--Percorre  a grid da NJM para verificar todos os lotes informados e trazer na query
			For nX := 1 to oMldNJM:Length()
				oMldNJM:GoLine(nX)
				If .Not. oMldNJM:IsDeleted()
					If lNotIn
						cQry += ","
					Else
						cQry += " AND DXL_LOTCTL IN("
						lNotIn := .T.
					EndIf
					cQry += "'"+ oMldNJM:GetValue("NJM_LOTCTL") +"'"
				EndIf
			Next nX
			
			If lNotIn
				cQry += ")"
			EndIf	
		EndIf 
		//Fim- Rastro
	EndIf
	//--Fim SuperGetMV
	
	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	
	
	//Seleciona a tabela 
	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof()) 
		nCont++
		If EMPTY((cAliasQry)->DXL_CODUNI)
			Help( , ,STR0017, , STR0026, 1, 0 ) //"Atenção"###"Não existe código único nos fardões. Favor verificar na tela de cadastro de fardões."
			aColsLoad := {}
			exit
		EndIf

		aAdd( aColsLoad, { "2", (cAliasQry)->DXL_FILIAL, (cAliasQry)->DXL_CODIGO, (cAliasQry)->DXL_SAFRA, (cAliasQry)->DXL_PRDTOR, ;
		 (cAliasQry)->DXL_FAZ, (cAliasQry)->DXL_TALHAO, (cAliasQry)->DXL_CODPRO, (cAliasQry)->DXL_CODVAR, (cAliasQry)->DXL_PSLIQU, ;
		 (cAliasQry)->DXL_PSESTI, (cAliasQry)->DXL_CODUNI, (cAliasQry)->DXL_CODUNB } )
		
		(cAliasQry)->(DbSkip())
	End
	
	(cAliasQry)->(DbCloseArea())	

	RestArea(aArea)
	
Return(aColsLoad)

/*/{Protheus.doc} MarcaUm
//Responsável por marcar uma linha com o duplo clique.
@author brunosilva
@since 15/01/2018
@version undefined
@param oBrwMrk, object, descricao
@param aItsMrk, array, descricao
@param nLinMrk, numeric, descricao
@param lDir, logical, descricao
@type function
/*/
Static Function MarcaUm( oBrwMrk, aItsMrk, nLinMrk)
	
	If(_nOp != 1)
		DO CASE      
	
			CASE aItsMrk[ nLinMrk, 1 ] = "1" .OR. aItsMrk[ nLinMrk, 1 ] = ""
			aItsMrk[ nLinMrk, 1 ] := "2"
	
			CASE aItsMrk[ nLinMrk, 1 ] == "2"
			aItsMrk[ nLinMrk, 1 ] := "1"
	
		ENDCASE
	
		oBrwMrk:Refresh()
	EndIf
Return


/*/{Protheus.doc} MarcaTudo
//Rotina para marcar/desmarcar todos os itens.
@author brunosilva
@since 15/01/2018
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
	
	If(_nOp != 1)
		For nX := 1 to Len( aItsMrk )                 
	
			If aItsMrk[ nX, 1 ] $ "1|2"
				aItsMrk[ nX, 1 ] := If(lMark, "1", "2")
			EndIf
		Next nX
	
		oBrwMrk:Refresh()
		lMark := !lMark
	EndIf
Return

/*/{Protheus.doc} MovFardos
//Rotina responsável movimentar os fardões.  
@author brunosilva
@since 15/01/2018
@version undefined
@param cSeta, characters, descricao
@param oBrwEsq, object, descricao
@param oBrwDir, object, descricao
@type function
/*/
Static Function MovFardos( cSeta, oBrwEsq, oBrwDir, _aItsEsq, nOperation )
	Local aItsOrig 	:= {}
	Local aItsDest 	:= {}
	Local nX		:= 0 
	Local lRet		:= .T.
	Local lMarc		:= .F.

	//If INCLUI .Or. ALTERA
	If nOperation == 3 .OR. nOperation == 4 
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
		
		aItsOrig := ASort( aItsOrig, , , { | x, y | x[2]+x[3]+x[4]+x[5]+x[6]+x[7] < y[2]+y[3]+y[4]+y[5]+y[6]+y[7]}) 
		aItsDest := ASort( aItsDest, , , { | x, y | x[2]+x[3]+x[4]+x[5]+x[6]+x[7] < y[2]+y[3]+y[4]+y[5]+y[6]+y[7]}) 
		
		If lMarc
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
			oBrwEsq:GoPosition(1) 
			oBrwDir:GoPosition(1)
			oBrwEsq:Refresh()
			oBrwDir:Refresh()
		
		EndIf
		If !lMarc
			Help( , ,STR0017, , STR0019, 1, 0 ) //"Atenção"###"Favor selecionar fardoes."
		EndIf
		
		If !lRet
			Return lRet
		EndIF
	Else
		Help( , , STR0017, , STR0020, 1, 0 )//"Atenção" //"Opção inválida na operação de visualização.             
	EndIf

	_nQtde := Len(oBrwDir:AARRAY) // Total de itens do romaneio
	_nPeso := 0
	_nPesoEst := 0
	For nX := 1 To len(oBrwDir:AARRAY)
		_nPeso += oBrwDir:AARRAY[nX, 10] //Peso Total de fardos selecionados
		_nPesoEst += oBrwDir:AARRAY[nX, 11] //Peso Total de fardos selecionados
	Next nX
Return(lRet)

/*/{Protheus.doc} Pesquisa
//Rotina que efetua a pesquisa por código dos fardos disponíveis
@author brunosilva
@since 15/01/2018
@version undefined
@param cChave, characters, descricao
@param cPesquisa, characters, descricao
@param oBrowse, object, descricao
@type function
/*/
Static Function Pesquisa(cChave, cPesquisa, oBrowse)
	Local nX 	 := 0
	Local nPosAc := 0
	
	for nX := 1 to len(oBrowse:AARRAY) 
		If oBrowse:AARRAY[nX][3] == cPesquisa 
			If nPosAc = 0 
				nPosAc := nX //seta o nº da linha para posicionar
			EndIf
			//realiza a marcação do registro
			if(_nOp != 1)
				oBrowse:AARRAY[ nX, 1 ] := "1"
			EndIf
		EndIf
	Next
	
	//Foca na linha que contém o registro pesquisado
	If nPosAc > 0
		oBrowse:GoPosition(nPosAc)
	EndIf
Return

/*/{Protheus.doc} ExecGrv
//Responsável por armazenar os fardões selecionados dentro da variável _aDXLRom para que seja gravado no momento em que 
// o romaneio todo for salvo com sucesso.
@author brunosilva
@since 16/01/2018
@version undefined
@param oBrowseDir, object, descricao
@type function
/*/
Function ExecGrv(oBrowseDir, oDlg)
	Local oModel  	:= FWModelActive()
	Local oView	  	:= FwViewActive()
	Local lDelete	
	Local oMldNJJ 	:= IIF(FwIsInCallStack("AGRA500") .OR. FwIsInCallStack("GFEA523"),oModel:GetModel('AGRA500_NJJ'),oModel:GetModel('NJJUNICO'))
	Local oMldDX0 	:= oModel:GetModel('AGRA500_DX0') //Vinculo FardaoxRomaneio
	Local nCount	:= 1
	Local nX		:= 0
	Local nY		:= 0
	Local nZ		:= 0
	Local nEmbal	:= 0	
		
	If oModel:GetOperation() != 1	
		If oModel:GetOperation() != 5
			For nY := 1 to oMldDX0:Length()
				oMldDX0:GoLine( nY )
				If !(oMldDX0:IsDeleted()) 
					lDelete := .T.
					For nZ := 1 To Len(_aItsDir)
						If _aItsDir[nZ] != Nil
							If oMldDX0:GetValue("DX0_FARDAO") == _aItsDir[nZ][3]
								lDelete := .F.
								ADel( _aItsDir, nZ )
								exit
							EndIf					
						EndIf
					Next nZ
					If lDelete //Deleta registros removidos
						oMldDX0:DeleteLine()
					EndIf
				EndIf
			Next nY
			
			For nZ := 1 to Len(_aItsDir)
				If _aItsDir[nZ] != Nil
					oMldDX0:AddLine()
					oMldDX0:GoLine( nZ + (nY-1)) //Comeco a contar a partir da ultima linha do modelo, o modelo existe em background
					oMldDX0:LoadValue("DX0_FILIAL", _aItsDir[nZ][2])
					oMldDX0:LoadValue("DX0_FARDAO", _aItsDir[nZ][3])
					oMldDX0:LoadValue("DX0_FAZ"   , _aItsDir[nZ][6])
					oMldDX0:LoadValue("DX0_TALHAO", _aItsDir[nZ][7])
					oMldDX0:LoadValue("DX0_CODPRO", _aItsDir[nZ][8])
					oMldDX0:LoadValue("DX0_CODVAR", _aItsDir[nZ][9])
					oMldDX0:LoadValue("DX0_PSLIQU", _aItsDir[nZ][10])			
					oMldDX0:LoadValue("DX0_CODUNI", _aItsDir[nZ][12])
					oMldDX0:LoadValue("DX0_CODUNB", _aItsDir[nZ][13])
					oMldDX0:LoadValue("DX0_NRROM" , _cCodRom)
					oMldDX0:LoadValue("DX0_ITEM"  , STRZERO(nZ + (nY-1), 3))
					oMldDX0:LoadValue("DX0_TIPROM", oMldNJJ:GetValue("NJJ_TIPO"))
				EndIf
			Next nX 
			
			For nX := 1 To oMldDX0:Length()
				If .Not. oMldDX0:IsDeleted(nX)
					oMldDX0:GoLine(nX)
					oMldDX0:LoadValue("DX0_ITEM", STRZERO(nCount, 3))
					nCount++
					
					//--busca o peso da tara do produto/fardao
					dbSelectArea('DXL')
					dbSetOrder(1)
					If MsSeek( FWxFilial("DXL") + oMldDX0:GetValue("DX0_FARDAO") )
						nEmbal += DXL->DXL_PSTARA
					EndIf										
				EndIf
			Next
			
			//--Atualiza o campo do peso da embalagem no romaneio - refente á soma do peso da tara do produto/fardao
			oMldNJJ:SetValue("NJJ_PESEMB", nEmbal )			
			If oMldNJJ:GetValue("NJJ_PSLIQU") <> 0
				oMldNJJ:SetValue("NJJ_PSLIQU", oMldNJJ:GetValue("NJJ_PSSUBT") - (oMldNJJ:GetValue("NJJ_PSDESC") + oMldNJJ:GetValue("NJJ_PSEXTR")+ nEmbal) )
				oMldNJJ:SetValue("NJJ_PESO3", oMldNJJ:GetValue("NJJ_PSLIQU") )
			EndIf			
			
			oMldNJJ:SetValue("NJJ_DTULAL", DDATABASE )
			oMldNJJ:SetValue("NJJ_HRULAL", SubStr(TIME(), 0, 8) )
			oView:oModel:lModify := .T.
			oView:lModify := .T.
			ASize( _aItsDir, 0 )
			oDlg:End()
		Else
			Help( , , STR0017, , STR0020, 1, 0 ) //"Atenção" //"Opção inválida na operação de visualização."
		EndIf			
	Else
		Help( , , STR0017, , STR0020, 1, 0 ) //"Atenção" //"Opção inválida na operação de visualização."
	EndIf	
Return

/*/{Protheus.doc} ExecCancel
//Responsável por limpar o array dos dardos selecionados e fechar a tela.
@author brunosilva
@since 16/01/2018
@version undefined
@param oDlg, object, descricao
@type function
/*/
Static function ExecCancel(oDlg)
	_aItsEsq := {}
	oDlg:End()
Return

/*/{Protheus.doc} A500EATDX0
// Responsável por atualziar dados da DX0 caso algum dado do romaneio seja alterado,
// No momento, somente o campo de Un. beneficiamento é necessário ser alterado
// Pq no OGA 250 ele não é obrigatório.
@author brunosilva
@since 22/03/2018
@version undefined

@type function
/*/
Function A500EATDX0()
	Local lRet    := .T.
	Local oModel  := FWModelActive()
	Local oMldDX0 := oModel:GetModel('AGRA500_DX0') //Vinculo FardaoxRomaneio
	Local oMldNJJ := IIF(FwIsInCallStack("AGRA500") .OR. FwIsInCallStack("GFEA523"),oModel:GetModel('AGRA500_NJJ'),oModel:GetModel('NJJUNICO'))
	Local cTipRom := oMldNJJ:GetValue("NJJ_TIPO")
	Local nY
	
	If oModel:GetOperation() = 4
		For nY := 1 to oMldDX0:Length()
			oMldDX0:GoLine( nY )
			oMldDX0:LoadValue("DX0_TIPROM", cTipRom)
		Next nY
	EndIf
Return lRet

/*/{Protheus.doc} A500ESTT
//Responsável por atualziar o status do fardão para 'em romaneio de entrada'
@author brunosilva
@since 05/04/2018
@version undefined
@param oMldDX0, object, descricao
@type function
/*/
Function A500ESTT(oMldDX0)
	Local aArea 	:= GetArea()
	Local nY
	Local lRet		:= .T.
	Local nOp		:= oMldDX0:GetOperation()
	Local cNrRom	:= oMldDX0:GetValue('DX0_NRROM')
	Local lRomEnt	:= iif(M->NJJ_TIPO $ '1|3|5|7|9|A',.T.,.F.)
	Local lRomSai	:= iif(M->NJJ_TIPO $ '2|4|6|8|B',.T.,.F.)
	Local cAliasDX0 := ""
	Local cQryDX0	:= ""
	
	if !(FwIsInCallStack('A500ConfRom') .AND. !FwIsInCallStack('OGA250NF')) .And. ;
		(FwIsInCallStack('AGRA500') .OR. FwIsInCallStack('OGA250') .OR. FwIsInCallStack("GFEA523") )
		if (nOp = 4 .AND. (lRomEnt .Or. lRomSai)) .OR. nOp = 5
			//Em caso de alteração, encontro todos os fardões que já contém vínculo com o romaneio selecionado
			// e volto o status deles pra 1 porque ele pode ter retirado fardões do vínculo.
			cAliasDX0 := GetNextAlias()
			
			cQryDX0 := " SELECT DX0_CODUNI FROM "+ RetSqlName("DX0") +" DX0 "
			cQryDX0 += " WHERE DX0_FILIAL = '" + FWxFilial('DX0') + "' "
			cQryDX0 += "   AND DX0_NRROM  = '" + cNrRom + "' "
			cQryDX0 += "   AND D_E_L_E_T_ = ' ' "
			
			cQryDX0 := ChangeQuery(cQryDX0)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryDX0),cAliasDX0, .F., .T.) 
			
			DbselectArea(cAliasDX0)
			(cAliasDX0)->(DbGoTop())
			While (cAliasDX0)->( !Eof() )
				dbSelectArea("DXL")
				dbSetOrder(2)
				If MsSeek(FWxFilial("DXL")+(cAliasDX0)->DX0_CODUNI)
					If RecLock( "DXL", .F. )
						If lRomEnt
							DXL->DXL_STATUS := '1'	//--Status 'previsto'
						ElseIf lRomSai
							DXL->DXL_STATUS := '3'	//--Status 'disponivel'
						EndIf 
					Else
						lRet := .F.
					EndIF				
				Else
					lRet := .F.
				EndIf
				DXL->( msUnLock() )
				(cAliasDX0)->(DbSkip())
			EndDo	
		EndIf
		
		if nOp != 5
			//Independente de ser alteração ou exclusão, 
			// Toda vez que vinculo o fardão a um romaenio altero o status dos fardões para em romaneio.
			dbSelectArea("DXL")
			dbSetOrder(2)
			For nY := 1 to oMldDX0:Length()		
				oMldDX0:GoLine( nY )
				If !(oMldDX0:IsDeleted())
					If MsSeek(FWxFilial("DXL")+oMldDX0:GetValue('DX0_CODUNI'))
						If RecLock( "DXL", .F. )	
							DXL->DXL_STATUS := '2'	//--Status 'em romaneio'
						Else
							lRet := .F.
						EndIF
						DXL->( msUnLock() )
					Else
						lRet := .F.
					EndIf
				EndIf
			Next nY			
			RestArea(aArea)	
		EndIf
	EndIF
Return lRet
