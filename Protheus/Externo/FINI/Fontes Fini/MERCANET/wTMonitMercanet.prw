#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include 'rwmake.ch' 

/*
|==============================================================================|
|                           S A N C H E Z   C A N O                            |
|==============================================================================|
| Programa  | WTMONITMERCANET |Autor  Cristian Müller      |Data 03/04/2016    |
|-----------+------------------------------------------------------------------|
|           |                                                                  |
|           |                                                                  |
| Descrição | Rotina para monitoramento da Integracao de Pedidos vindos        |
|           | do Mercanet.                                                     |
|           |                                                                  |
|           |                                                                  |
|           |                                                                  |
|           |                                                                  |
|-----------+------------------------------------------------------------------|
|    Uso    |   Protheus      | Móduto | Faturamento      | Chamado |          |
|------------------------------------------------------------------------------|
|>>>>>>>>>>>>>>>>>>>>>>>>>> Histórico de Alterações <<<<<<<<<<<<<<<<<<<<<<<<<<<|
|------------------------------------------------------------------------------|
|   Data    |               Alteração               |    Autor     |  Chamado  |
|-----------+---------------------------------------+--------------+-----------|
|==============================================================================|
*/

User Function MonitMerca()

	Private oFont20b 	:= tFont():New("Arial",nil,-20,,.t.,nil,nil,nil,nil,.F.,.F.)
	Private oFont16b 	:= tFont():New("Arial",nil,-16,,.t.,nil,nil,nil,nil,.F.,.F.)
	Private oFont14b	:= tFont():New("Arial",nil,-14,,.t.,nil,nil,nil,nil,.F.,.F.)
	Private oFont20 	:= tFont():New("Arial",nil,-20,,.t.,nil,nil,nil,nil,.F.,.F.)
	Private oFont12		:= tFont():New("Arial",nil,-12,,.f.,nil,nil,nil,nil,.F.,.F.)
	Private oFont10		:= tFont():New("Arial",nil,-12,,.f.,nil,nil,nil,nil,.F.,.F.)
	Private oFont10b	:= tFont():New("Arial",nil,-12,,.t.,nil,nil,nil,nil,.F.,.F.)
	Private oFont07		:= tFont():New("Arial",nil,-07,,.f.,nil,nil,nil,nil,.F.,.F.)
	Private oFont08		:= tFont():New("Arial",nil,-08,,.f.,nil,nil,nil,nil,.F.,.F.)
	Private oFont09		:= tFont():New("Arial",nil,-09,,.f.,nil,nil,nil,nil,.F.,.F.)
	Private aStruTMP	:= {}
	Private cQuery		:= ""
	Private oMenuUF 	:= NIL
	Private cEmail      := U_GETZPA("EMAIL_ERRO_MERCANET","ZZ")        // E-mail para envio de avisos aos responsáveis

	//Variaveis do dialogo
	Private oDlg1		:= NIL
	Private oBrw1		:= 0
	Private nOpc 	  	:= 0                  //GD_INSERT+GD_DELETE+GD_UPDATE
	Private cLinhaOk	:= 'AllwaysTrue()'
	Private cTudoOk		:= 'AllwaysTrue()'
	Private cIniCpos	:= ''				  //Campos com incremento automatico
	Private aAlter    	:= {}				  //Vetor com os campos que poderão ser alterados.
	Private nFreeze		:= 0
	Private nMax		:= 999999999	      //Numero maximos de registros a serem exibidos
	Private cFieldOk	:= 'AllwaysTrue()'    //Validacao de campo
	Private cSuperDel	:= ''				  //Super Del
	Private cDelOk		:= 'AllwaysTrue()'	  //Validacao da Exclusão da Linha
	Private aHeader		:= {}
	Private aCols		:= {}
	Private lAsc        := .F.                // Ordem ascendente
	Private cSemaforo   := U_GETZPA("SEMAFORO_MERCANET","ZZ")
	Private cDtHr       := U_GETZPA("STATUS_MERCANET",cFilAnt)  // Data / hora 
	Private cFiltro     := "T" 
	Private cPerg       := "MercPe1" 
	Private cTGet1      := dtoc(dDataBase) + " - " + substr(time(),1,5) + " hs."

	criaSX1(cPerg)       

	if !LoadAcols(cFiltro)
		msgBox("Sem dados a apresentar")  
		return
	endif 

	BuildHeader()
	BScreen()

Return




Static Function LoadAcols(_par01)

	Local aTmp    := {}
	Local cFiltro := _par01 
	Local i 		:= 0
	Local ik 		:= 0

	// --------------------------------------------------------
	// Monta a query de seleção de dados, a ordem colocada aqui, 
	// será a mesma da tela de exibição
	// --------------------------------------------------------
	cQuery:= " SELECT TOP 500 CASE WHEN ZC5_STATUS = '   ' THEN 'BR_VERDE' "
	cQuery+= "      WHEN ZC5_STATUS = 'PRO' THEN 'BR_VERMELHO' "
	cQuery+= "      WHEN ZC5_STATUS = 'ERR' AND ZC5_ESTOK = 'S' THEN 'BR_CANCEL'  "
	cQuery+= "      WHEN ZC5_STATUS = 'ERR' AND ZC5_ESTOK = 'N' THEN 'BR_PRETO'  "
	cQuery+= "      WHEN ZC5_STATUS = 'INI' THEN 'BR_AMARELO' "
	cQuery+= " END MARK , "

	cQuery+= " CASE WHEN ZC5_STATUS = '   ' THEN 'Aguardando' "
	cQuery+= "      WHEN ZC5_STATUS = 'PRO' THEN 'Integrado'  "
	cQuery+= "      WHEN ZC5_STATUS = 'ERR' AND ZC5_ESTOK = 'S' THEN 'Erro Integração'  "
	cQuery+= "      WHEN ZC5_STATUS = 'ERR' AND ZC5_ESTOK = 'N' THEN 'Erro Estoque'   "
	cQuery+= "      WHEN ZC5_STATUS = 'INI' THEN 'Processando' "
	cQuery+= " END DESMARK , "

	cQuery+= " ZC5_FILA AS _SEQ,ZC5_FILIAL,ZC5_PEDMER,ZC5_TIPVEN,ZC5_NUM,ZC5_FILA,ZC5_DTINC,ZC5_HRINC,ZC5_DTINI,ZC5_HRINI,"
	cQuery+= " ZC5_DTFIM,ZC5_HRFIM,ZC5_CLIENT,A1_NOME,ZC5_VTOT,ZC5_ESTOK,ZC5_ELIRES,ZC5_PEDPAI,ZC5_PROCRT "
	cQuery+= " FROM " + retSqlName("ZC5") + " ZC5 "
	cQuery+= " LEFT JOIN " + retSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_= '' AND SA1.A1_COD = ZC5.ZC5_CLIENT "
	cQuery+= " WHERE ZC5.D_E_L_E_T_ = '' "

	do case 
		case cFiltro == "A" 
		cQuery += " AND ZC5_STATUS = '   ' "  
		case cFiltro == "I" 
		cQuery += " AND ZC5_STATUS = 'PRO' "  
		case cFiltro == "E" 
		cQuery += " AND ZC5_STATUS = 'ERR' AND ZC5_ESTOK = 'S' " 
		case cFiltro == "X" 
		cQuery += " AND ZC5_STATUS = 'ERR' AND ZC5_ESTOK = 'N' " 
	endcase

	if !empty(MV_PAR01)
		cQuery += " AND ZC5_DTINC >= '" + dtos(MV_PAR01) + "' "  
	endif 

	//cQuery+= " ORDER BY ZC5_FILIAL,ZC5_FILA DESC "+CRLF
	cQuery+= " ORDER BY ZC5_FILA DESC "+CRLF

	MEMOWRITE("MONITMERC.TXT",cQuery)

	IF SELECT("TMP")>0
		TMP->(DbCloseArea())
	EndIF

	TCQUERY cQuery NEW ALIAS "TMP"
	DbSelectArea("TMP")
	DbGotop()

	aCols		:= {}
	aStruTMP	:= TMP->(DbStruct())

	// -----------------------------------------------------
	// Ajuste do tamanho dos campos com base no tamanho real
	// -----------------------------------------------------
	For i:=1 to Len(aStruTMP)
		If aStruTMP[i][2]=="N"
			aStruTMP[i][3]:= 10
			aStruTMP[i][4]:= 2
		ElseIf aStruTMP[i][1] $ "ZC5_DTINC,ZC5_DTINI,ZC5_DTFIM"
			aStruTMP[i][3]:= 10
			aStruTMP[i][4]:= 0
		Else
			aStruTMP[i][3]:= Len(&("TMP->"+aStruTMP[i][1]))
		EndIF
	Next

	//------------------------------------
	// Trata se não houver dados na query
	//------------------------------------
	If Eof()
		return(.F.) 
	EndIf

	// ---------------------------------------------
	// -- Faz a montagem do aCols
	// ---------------------------------------------
	_nSeq:=0
	While !Eof()
		aTmp:={}
		For ik:= 1 to Len(aStruTMP)
			If aStruTMP[ik][1]=="ZC5_FILIAL"
				AADD(aTmp,ZC5_FILIAL)
			ElseIf aStruTMP[ik][1]=="_SEQ"
				AADD(aTmp,strZero(_nseq,10,0))
			ElseIf aStruTMP[ik][1] $ "ZC5_DTINC,ZC5_DTINI,ZC5_DTFIM"
				AADD(aTmp,STOD(&("TMP->"+aStruTMP[ik][1])))
			Else
				AADD(aTmp,&("TMP->"+aStruTMP[ik][1]))
			EndIf

		Next
		_nSeq++
		AADD(aTmp,.F.)	    //ADD o flag de fim de grid
		AADD(aCols,aTmp)	//Add do Acols
		DbSkip()
	End
	TMP->(DbCloseArea())

Return(.T.)



//==============================================
// 
//  Monta o Header
//
//==============================================
Static Function BuildHeader()

	AADD(aHeader,{""                , "US_MARK"		 , "@BMP"               , 01 , 00 , ".T." , , "L" ,, })
	AADD(aHeader,{"Status"          , "DESMARK"		 , ""                   , 15 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Seq"      		, "_SEQ"         , "@!"                 , 10 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Filial"   		, "ZC5_FILIAL"	 , "@!"                 , 02 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Ped.Mercanet"    , "ZC5_PEDMER"   , ""                   , 20 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Tipo"            , "ZC5_TIPVEN"   , ""                   , 01 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Ped.Protheus"    , "ZC5_NUM"      , ""                   , 06 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Nro.Fila"        , "ZC5_FILA"     , ""                   , 10 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Dt.Chegada"      , "ZC5_DTINC"    , ""                   , 08 , 00 , ".T." , , "D" ,, })
	AADD(aHeader,{"Hr.Chegada"      , "ZC5_HRINC"    , ""                   , 10 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Dt.Ini.Proc"     , "ZC5_DTINI"    , ""                   , 08 , 00 , ".T." , , "D" ,, })
	AADD(aHeader,{"Hr.Ini.Proc"     , "ZC5_HRINI"    , ""                   , 10 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Dt.Fim.Proc"     , "ZC5_DTFIM"    , ""                   , 08 , 00 , ".T." , , "D" ,, })
	AADD(aHeader,{"Hr.Fim.Proc"     , "ZC5_HRFIM"    , ""                   , 10 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Cod.Cliente"     , "ZC5_CLIENT"   , ""                   , 06 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Razão Social"    , "A1_NOME"      , ""                   , 35 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Valor Total R$"  , "ZC5_VTOT"     , "@E 9,999,999.99"    , 10 , 02 , ".T." , , "N" ,, })
	AADD(aHeader,{"Estoque OK?"     , "ZC5_ESTOK"    , ""                   , 01 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Eliminou Residuo", "ZC5_ELIRES"   , ""                   , 01 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Nro.Pedido Pai  ", "ZC5_PEDPAI"   , ""                   , 01 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Proc.Retorno Mecanet"    , "ZC5_PROCRT"      , ""                   , 01 , 00 , ".T." , , "C" ,, })

Return



//===========================================================
// 
//  Monta a interface padrão com o usuário
// 
//===========================================================
Static Function BScreen()

	//Local aAdvSize		 := {}
	//Local aInfoAdvSize	 := {}
	//Local aObjSize		 := {}
	//Local aObjCoords	 := {}
	//Local aButtons   	 := {}

	//------------------------------------------------
	// Monta as Dimensoes dos Objetos
	//------------------------------------------------
	aSizeAut := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 315,  50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo   := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	oDlg1            := MSDialog():New(0,0,800, 1000,"Monitor de Integração -> Pedidos MERCANET x PROTHEUS",,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,.T.)
	oDlg1:lMaximized := .T. //Maximizar a Janela		
	oDlg1:lCentered  := .T.

	//----------------------------------------------------------
	//Executa o renew a cada X minutos conforme parametro
	//----------------------------------------------------------
	nSegundos    := ( mv_par02 * 6000 )  
	otimer		 :=TTimer():New(nSegundos,{|| oTimer:DeActivate(),Renew(cFiltro),oTimer:Activate() },oDlg1)
	oTimer:Activate()

	//---------------------------------------------------------------------------------------------------------------
	// Grupo para ligar ou desligar a integração entre Protheus x Mercanet
	//---------------------------------------------------------------------------------------------------------------
	oGrp1      := TGroup():New( 002,004,050,100," Integração Mercanet x Protheus ",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oBtnOn     := TButton():New( 015,10 , "ON"  , oGrp1 , {|| semaforo("ON") },055,013,,,,.T.,,"",,,,.F. )
	oBtnOff    := TButton():New( 030,10 , "OFF" , oGrp1 , {|| semaforo("OFF") },055,013,,,,.T.,,"",,,,.F. )
	oGrp2      := TGroup():New( 013,074,045,090,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oTBitOn    := TBitmap():New(15, 76, 40, 80, NIL, "VERDE.PNG"    , .T., oGrp2,{||Alert("Integração está ativada.")}    , NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
	oTBitOff   := TBitmap():New(30, 76, 40, 80, NIL, "VERMELHO.PNG" , .T., oGrp2,{||Alert("Integração está desativada.")} , NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)

	//--------------------------------------------------------------------
	// Avalia status do semaforo para atualizar na tela 
	//--------------------------------------------------------------------
	avalSemaforo(cSemaforo)

	//--------------------------------------------------------------------
	// Botoes de refresh , visualização de pedidos / erros  
	//--------------------------------------------------------------------
	oGrp2      := TGroup():New(  005,110,050,245,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oBtnVerMerc:= TButton():New( 010,118 , "Ver Dados Mercanet"   , oGrp2 , {|| vePedMerc(oBrw1:aCols[oBrw1:nAt][gdFieldPos("ZC5_PEDMER")]) },055,018,,,,.T.,,"",,,,.F. )
	oBtnVerPed := TButton():New( 010,180 , "Ver Pedido Protheus"  , oGrp2 , {|| vePedProt(oBrw1:aCols[oBrw1:nAt][gdFieldPos("ZC5_NUM")]) },055,018,,,,.T.,,"",,,,.F. )
	oBtnVerErro:= TButton():New( 030,118 , "Ver Erro ExecAuto"    , oGrp2 , {|| veErroExec(oBrw1:aCols[oBrw1:nAt][gdFieldPos("ZC5_NUM")]) },055,018,,,,.T.,,"",,,,.F. )
	oBtnSair   := TButton():New( 030,180 , "Sair"                 , oGrp2 , {|| oDlg1:end() },055,018,,,,.T.,,"",,,,.F. )

	//------------------------------------- SAYs --------------------------------------------
	oGrp3        := TGroup():New(  005,250,050,400,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay1        := TSay():New( 007,252,{|| SM0->M0_NOMECOM }       , oGrp3,,oFont16b,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,244,012)
	oSay2        := TSay():New( 021,252,{|| "Última atualização: "} , oGrp3,,oFont10,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,244,012)
	oTGet1       := TGet():New( 20,310 ,{||cTGet1},oDlg1,065,010,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTGet1,,,, )
	oTGet1:disable()
	
	oBtnRenew    := TButton():New( 034,252 , "Atualizar"            , oGrp3 , {|| renew(cFiltro) },055,013,,,,.T.,,"",,,,.F. )
	oBtnParam    := TButton():New( 034,320 , "Parâmetros"           , oGrp3 , {|| pergunte(cPerg,.T.),oTimer:nInterval:= (mv_par02*6000),renew(cFiltro) },055,013,,,,.T.,,"",,,,.F. )

	//------------------- Botoes de Filtros por Status ----------------------------------------------------------------
	oGrp4        := TGroup():New(  002,405,050,540," Filtrar Status ",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oBtnF1       := TButton():New( 010,415 , "Aguardando"          , oGrp4 , {|| renew("A") },055,010,,,,.T.,,"",,,,.F. )
	oBtnF2       := TButton():New( 023,415 , "Integrado"           , oGrp4 , {|| renew("I") },055,010,,,,.T.,,"",,,,.F. )
	oBtnF4       := TButton():New( 010,480 , "Erro Estoque"        , oGrp4 , {|| renew("X") },055,010,,,,.T.,,"",,,,.F. )
	oBtnF3       := TButton():New( 023,480 , "Erro Integração"     , oGrp4 , {|| renew("E") },055,010,,,,.T.,,"",,,,.F. )
	oBtnF5       := TButton():New( 036,415 , "Limpar Filtros"      , oGrp4 , {|| renew("T") },120,010,,,,.T.,,"",,,,.F. )

	//------------------- Monitoramento -------------------------------------------------------------------
	oGrp5        := TGroup():New(  002,545,050,647," Monitoramento",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oBtnF6       := TButton():New( 014,550 , "Dt/Hr última execução JOB"      , oGrp5 , {|| ultProc() },80,010,,,,.T.,,"",,,,.F. )
	oBtnF7       := TButton():New( 032,550 , "Qtde. a processar por JOB"      , oGrp5 , {|| qtdProc()  },80,010,,,,.T.,,"",,,,.F. )
    
	//----------------------------------------------------BROWSE------------------------------------------
	oBrw1 := MsNewGetDados():New(aPosObj[2,1]-070, aPosObj[2,2] , aPosObj[2,3] , aPosObj[2,4] ,nOpc,cLinhaOk,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDlg1,aHeader,aCols)

	//---------------------------------------------------------
	// Metodo para Ordenar Coluna quando Clicada
	//---------------------------------------------------------
	oBrw1:oBROWSE:bHEADERCLICK := { |oBRW,nCOL,ADIM|oBrw1:oBROWSE:nCOLPOS := nCOL,FORDENA(nCOL),GETCELLRECT(oBRW,@ADIM)}

	//---------------------------------------------------------
	// Duplo click na coluna do getdados - Ordena 
	//---------------------------------------------------------
	oBrw1:oBrowse:bLDblClick	:= {|| DbClick(oBrw1)}

	oBrw1:oBrowse:SetFocus()

	//Ativa o dialogo
	oDlg1:Activate(,,,.T.)

Return





//================================================================
//
//
// Funcao para ordernar a coluna clicada pelo usuario
//
//
//================================================================
Static Function fORDENA(nCOL)

	if  lAsc
		aSORT(oBrw1:aCOLS,,,{|X,Y|(X[nCOL] < Y[nCOL])})
		lAsc := .F.
	else
		aSORT(oBrw1:aCOLS,,,{|X,Y|(X[nCOL] > Y[nCOL])})
		lAsc := .T.
	endif

	oBrw1:oBROWSE:REFRESH()

Return



//=========================================================================
//
// Funcao duplo clique na linha = Abre pedido ou erro execauto
// 
//=========================================================================
Static Function dbClick(oObj)

	Local   cNumPed :=  oObj:aCols[oBrw1:nAt][gdFieldPos("ZC5_NUM")]
	Local   cEstOk  :=  oObj:aCols[oBrw1:nAt][gdFieldPos("ZC5_ESTOK")]
	Local   cNumMerc:=  oObj:aCols[oBrw1:nAt][gdFieldPos("ZC5_PEDMER")]

	//---------------------------------------------------
	// Se gerou pedido, permite a visualização 
	//--------------------------------------------------
	if !empty(cNumPed)
		vePedProt(cNumPed)
		return
	elseif empty(cNumPed) .and. cEstOk == "S"
		veErroExec()
	elseif empty(cNumPed) .and. cEstOk == "N"
		vePedMerc(cNumMerc)
	endif

Return


//=================================================================================
// 
// Funcao para retornar conteudo de erro do execauto - Campo Memo 
//
//================================================================================= 
Static Function MEMOtxt(_cFila)

	Local _cSQL
	Local _resultado := ""

	_cSQL := "SELECT ISNULL( CONVERT( VARCHAR(4096), CONVERT(VARBINARY(4096), ZC5_ERRO )),'') AS MEMO FROM "+retSqlName("ZC5")+ " WHERE ZC5_FILA = '"+_cFila+"' AND D_E_L_E_T_ = '' "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cSQL),"ZTRD",.T.,.T.)
	dbSelectArea("ZTRD")
	ZTRD->(dbGoTop())
	WHILE !ZTRD->(EOF())
		_resultado := ZTRD->MEMO
		ZTRD->(DBSKIP())
	ENDDO
	ZTRD->(dbCloseArea())
return _resultado



//=================================================================================
// 
// Funcao para avaliar status do semaforo e atualizar informações em tela
//
//================================================================================= 
Static Function avalSemaforo(cSemaforo)

	if cSemaforo=="ON"
		oBtnOn:lActive    := .F.
		oBtnOff:lActive   := .T.
		oTBitOn:lVisible  := .T.
		oTBitOff:lVisible := .F.
	else
		oBtnOn:lActive:=.T.
		oBtnOff:lActive:=.F.
		oTBitOn:lVisible  := .F.
		oTBitOff:lVisible := .T.
	endif

Return


//=================================================================================
// 
// Funcao para ativar ou desativar integracao dos pedidos Mercanet x Protheus 
//
//================================================================================= 
Static Function semaforo(_par01)

	Local cTitulo := ""
	Local cTexto  := ""
	Local cAnexos := ""

	cSemaforo := _par01

	U_PUTZPA("SEMAFORO_MERCANET","ZZ",cSemaforo)

	avalSemaforo(cSemaforo)

	Renew(cFiltro)

	//---------------------------------------------------------------
	// Envia e-mail notificando ativacao/desativacao da integracao 
	//---------------------------------------------------------------
	cTxtAtv := iif(cSemaforo="ON","ATIVADA","DESATIVADA")
	cTitulo := "Integração Pedidos -> Mercanet -> " + cTxtAtv
	cTexto  := cTitulo+"<BR><BR>"+"Usuário Responsável: " + cUserName +"<BR><BR>Data: "+dtoc(date())+"<BR><BR>Hora: "+time()
	MsAguarde ( { || U_SUBEML(cEmail,cTitulo,cTexto,cAnexos) } , iif(cSemaforo=="ON","Ativando ","Desativando ")+"integração...")

Return


//=================================================================================
// 
// Funcao de refresh da tela  
//
//================================================================================= 
Static Function Renew(cFiltro)

	//Recarrega/Atualiza o Array Acols
	LoadAcols(cFiltro)
	//Atualiza Data e Hora da obteção dos dados	
	cTGet1 := dtoc(dDataBase) + " - " + substr(time(),1,5) + " hs." 
	oBrw1:SetArray(aCols,.t.)
	oBrw1:Refresh()
	oBrw1:oBrowse:SetFocus()
	oDlg1:Refresh()

Return


//=========================================================================
// 
// Visualiza pedido de vendas gerado no protheus 
//
//=========================================================================
Static Function vePedProt(cNumPed)

	Local   cFilPed :=  oBrw1:aCols[oBrw1:nAt][gdFieldPos("ZC5_FILIAL")]
	Private aRotina :=  menuDef()


	SC5->(dbSetOrder(1))
	IF SC5->(dbSeek(cFilPed + cNumPed))
		MVP01BKP := MV_PAR01
		MVP02BKP := MV_PAR02 
		MsAguarde ( { || A410Visual("SC5",SC5->(RECNO()),1) } , "Abrindo pedido de vendas...")
		MV_PAR01 := MVP01BKP 
		MV_PAR02 := MVP02BKP  
		return
	endif

	oBrw1:oBrowse:SetFocus()

Return


//=========================================================================
// 
// Visualiza erro ExecAuto  
//
//=========================================================================
Static Function veErroExec(cNumPed)

	Local cResult   := ""
	Local cFila     := oBrw1:aCols[oBrw1:nAt][gdFieldPos("ZC5_FILA")]


	//-------------------------------------------------------
	// Se gerou erro no execAuto , exibe o conteudo do erro 
	//-------------------------------------------------------
	cResult := MEMOtxt(cFila)
	AVISO("Erro no MsExecAuto",cResult,{"OK"},3)
	oBrw1:oBrowse:SetFocus()

Return


//==========================================================================
//
// Funcao para visualizar os dados originais vindos do MERCANET 
//
//==========================================================================  
Static Function vePedMerc(_pedMer)

	Local _ni
	Local nX
	Local cNumPedMer := _pedMer

	//--------------------------------
	// Backup aCols rotina principal 
	//--------------------------------
	aColsBkp := aClone(aCols)
	aHeadBkp := aClone(aHeader)

	aRotina := menuDef()

	//+--------------------------------------------------------------+
	//| Opcoes de acesso para a Modelo 3                             |
	//+--------------------------------------------------------------+
	nOpcE:=2
	nOpcG:=2

	DbSelectArea("ZC5")
	DbSetOrder(2)
	DbSeek(xFilial("ZC5")+cnumPedMer)

	//+--------------------------------------------------------------+
	//| Cria variaveis M->????? da Enchoice                          |
	//+--------------------------------------------------------------+
	//RegToMemory("ZC5",(cOpcao=="INCLUIR"))
	RegToMemory("ZC5",.F.)
	RegToMemory("ZC6",.F.)

	//+--------------------------------------------------------------+
	//| Cria aHeader e aCols da GetDados                             |
	//+--------------------------------------------------------------+
	nUsado:=0
	/*dbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("ZC6")
	aHeader:={}
	While !Eof().And.(x3_arquivo=="ZC6")
		If X3USO(x3_usado).And.cNivel>=x3_nivel
			nUsado:=nUsado+1
			Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,"AllwaysTrue()",;
			x3_usado, x3_tipo, x3_arquivo, x3_context } )
		Endif
		dbSkip()
	End*/

	aFields := ZC6->(dbStruct())
	aHeader:={}

	For nX := 1 To Len(aFields)
		If X3USO(GetSx3Cache(aFields[nX, 1], "X3_USADO")).And.cNivel>=GetSx3Cache(aFields[nX, 1], "X3_NIVEL")
			nUsado:=nUsado+1
			Aadd(aHeader,{ ;
				TRIM(GetSx3Cache(aFields[nX, 1], "X3_TITULO")),;
				GetSx3Cache(aFields[nX, 1], "X3_CAMPO"),;
				GetSx3Cache(aFields[nX, 1], "X3_PICTURE"),;
				GetSx3Cache(aFields[nX, 1], "X3_TAMANHO"),;
				GetSx3Cache(aFields[nX, 1], "X3_DECIMAL"),;
				"AllwaysTrue()",;
				GetSx3Cache(aFields[nX, 1], "X3_USADO"),; 
				GetSx3Cache(aFields[nX, 1], "X3_TIPO"),;
				GetSx3Cache(aFields[nX, 1], "X3_ARQUIVO"),; 
				GetSx3Cache(aFields[nX, 1], "X3_CONTEXT");
			} )
		Endif
	Next

	aCols:={}
	dbSelectArea("ZC6")
	dbSetOrder(1)
	dbSeek(XFILIAL("ZC6")+cNumPedMer)
	While !eof().and. ZC6->ZC6_PEDMER == cNumPedMer .and. ZC6->ZC6_FILIAL == XFILIAL("ZC6")
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			//aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
			if aHeader[_ni,10] <> "V"
				aCols[len(aCols),_ni] := Fieldget(Fieldpos(aHeader[_ni,2]))
			else
				aCols[len(aCols),_ni] := Criavar(aHeader[_ni,2],.T.)
			endif
		Next
		aCols[Len(aCols),nUsado+1]:=.F.
		dbSkip()
	End

	If Len(aCols)>0
		//+--------------------------------------------------------------+	
		//| Executa a Modelo 3                                           |	
		//+--------------------------------------------------------------+	
		cTitulo:="Dados do Pedido vindo do Mercanet"
		cAliasEnchoice := "ZC5"
		cAliasGetD     := "ZC6"
		cLinOk         := "AllwaysTrue()"
		cTudOk         := "AllwaysTrue()"
		cFieldOk       := "AllwaysTrue()"
		_lRet:=Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,.T.,9999)
		//+--------------------------------------------------------------+	
		//| Executar processamento                                       |	
		//+--------------------------------------------------------------+	
		If _lRet
			//Aviso("Modelo3()","Confirmada operacao!",{"Ok"})
		Endif
	Endif

	///--------------------------------
	// Restore aCols rotina principal 
	//--------------------------------
	aCols   := aClone(aColsBkp)
	aHeader := aClone(aHeadBkp)
	oBrw1:oBrowse:SetFocus()

Return 	



//==========================================================================
//
// Funcao para alterar a quantiade de pedidos a serem processados 
// na rotina wtImpMercanet - altera o SELECT TOP xx  
//
//==========================================================================  
Static Function qtdProc()

	Local MVP01BKP  := MV_PAR01
	Local aPerg	    := {}
	Local aPergRt	:= {}
	Local zzMERCPED := Getmv("ZZ_MERCPED")
	Local cPerg	    := "zzMERCPED" 
	Local aButtons  := {}

	//+------------------------------------------+
	//|Abre Perguntas na Tela                    |
	//+------------------------------------------+
	AADD(aPerg,{1,"Qtde.Pedidos por JOB ",zzMERCPED,"@E 9999","","",".T.",50,.T.})
	lRet:=PARAMBOX(aPerg,cPerg,@aPergRt,,aButtons,.t.,,,,cPerg,.t.,.t.)
	If lRet
		PUTMV("ZZ_MERCPED",aPergRt[1])
	endif 
	MV_PAR01 := MVP01BKP 

Return 


//==========================================================================
//
// Funcao para exibir data e hora da última execução do JOB  
//
//==========================================================================  
Static Function ultProc()

	Local cRet01   := U_GETZPA("STATUS_MERCANET",cEmpAnt)
	Local cTxtOcor1 := "Data / Hora do último processamento: " + substring(cRet01,9,2)+"/"+substring(cRet01,6,2)+"/"+substring(cRet01,1,4)+"  -  "+substring(cRet01,12,8)

	AVISO("Appserver_Jobs_Mercanet",cTxtOcor1,{"OK"},3)

Return 



/*****************************************
**FUNCAO PARA CRIAR A PERGUNTA
******************************************/

Static Function CriaSX1(cPerg)

	/*
	Private bValid	:=Nil
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil

	PutSx1(cPerg,'01','Data chegada a partir de','','','mv_ch1','D',8,0,1,'G',bValid,"",cSXG,cPyme,'MV_PAR01',,,,,,,)
	PutSx1(cPerg,'02','Tempo Refresh (Minutos)','','','mv_ch2','N',3,0,1,'G',bValid,"",cSXG,cPyme,'MV_PAR02',,,,,,,)
	*/
	pergunte(cPerg,.F.)

RETURN


