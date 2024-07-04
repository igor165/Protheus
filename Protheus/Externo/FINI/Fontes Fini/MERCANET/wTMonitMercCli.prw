#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include 'rwmake.ch'

/*
|==============================================================================|
|                           S A N C H E Z   C A N O                            |
|==============================================================================|
| Programa  | WTMONITMERCCLI  |Autor  Cristian Müller      |Data 03/04/2016    |
|-----------+------------------------------------------------------------------|
|           |                                                                  |
|           |                                                                  |
| Descrição | Rotina para monitoramento da Integracao de Clientes vindos       |
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



User Function MonitCli()

	Private oFont20b 	:= tFont():New("Arial",nil,-20,,.t.,nil,nil,nil,nil,.F.,.F.)
	Private oFont18b 	:= tFont():New("Arial",nil,-18,,.t.,nil,nil,nil,nil,.F.,.F.)
	Private oFont14b	:= tFont():New("Arial",nil,-14,,.t.,nil,nil,nil,nil,.F.,.F.)
	Private oFont20 	:= tFont():New("Arial",nil,-20,,.t.,nil,nil,nil,nil,.F.,.F.)
	Private oFont12		:= tFont():New("Arial",nil,-12,,.f.,nil,nil,nil,nil,.F.,.F.)
	Private oFont10		:= tFont():New("Arial",nil,-12,,.f.,nil,nil,nil,nil,.F.,.F.)
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
	Private cSemaforo   := U_GETZPA("SEMAFORO_MERCACLIENT","ZZ")
	
	LoadAcols()
	
	if !LoadAcols()
	    msgBox("Sem dados a apresentar")  
	    return
	endif 
	
	BuildHeader()
	
	BScreen()
	
Return



	
Static Function LoadAcols()

	Local aTmp:={}

	// --------------------------------------------------------
	// Monta a query de seleção de dados, a ordem colocada aqui, 
	// será a mesma da tela de exibição
	// --------------------------------------------------------
	cQuery:= " SELECT CASE WHEN Z1A_STATUS = '   ' THEN 'BR_VERDE' "
	cQuery+= "             WHEN Z1A_STATUS = 'PRO' THEN 'BR_VERMELHO' "
	cQuery+= "             WHEN Z1A_STATUS = 'ERR' THEN 'BR_CANCEL'  "
	cQuery+= "             WHEN Z1A_STATUS = 'INI' THEN 'BR_AMARELO' "
	cQuery+= " END MARK , "
	
	cQuery+= " CASE WHEN Z1A_STATUS = '   ' THEN 'Aguardando' "
	cQuery+= "      WHEN Z1A_STATUS = 'PRO' THEN 'Finalizado' "
	cQuery+= "      WHEN Z1A_STATUS = 'ERR' THEN 'Erro'  "
	cQuery+= "      WHEN Z1A_STATUS = 'INI' THEN 'Processando' "
	cQuery+= " END DESMARK , "
	
	
	cQuery+= " Z1A_FILA AS _SEQ,Z1A_FILIAL,Z1A_CODMER,Z1A_COD,A1_MSBLQL,Z1A_FILA,Z1A_DTINC,Z1A_HRINC,Z1A_DTINI,Z1A_HRINI,"
	cQuery+= " Z1A_DTFIM,Z1A_HRFIM,Z1A_NOME,Z1A_MUN,Z1A_EST,Z1A_CGC,Z1A_VEND,A3_NOME,Z1A_PROCRT "
	cQuery+= " FROM " + retSqlName("Z1A") + " Z1A "
	cQuery+= " LEFT JOIN " + retSqlName("SA3") + " SA3 ON SA3.D_E_L_E_T_= '' AND Z1A.Z1A_VEND = SA3.A3_COD "
	cQuery+= " LEFT JOIN " + retSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_= '' AND Z1A.Z1A_COD  = SA1.A1_COD "
	cQuery+= " WHERE Z1A.D_E_L_E_T_ = '' "
	cQuery+= " ORDER BY Z1A_FILIAL,Z1A_FILA DESC "+CRLF

	MEMOWRITE("MONITMERCLIE.TXT",cQuery)

	IF SELECT("TMP2")>0
		TMP2->(DbCloseArea())
	EndIF

	TCQUERY cQuery NEW ALIAS "TMP2"
	DbSelectArea("TMP2")
	DbGotop()

	aCols		:= {}
	aStruTMP	:= TMP2->(DbStruct())

	// -----------------------------------------------------
	// Ajuste do tamanho dos campos com base no tamanho real
	// -----------------------------------------------------
	For i:=1 to Len(aStruTMP)
		If aStruTMP[i][2]=="N"
			aStruTMP[i][3]:= 10
			aStruTMP[i][4]:= 2
		ElseIf aStruTMP[i][1] $ "Z1A_DTINC,Z1A_DTINI,Z1A_DTFIM"
			aStruTMP[i][3]:= 10
			aStruTMP[i][4]:= 0
		Else
			aStruTMP[i][3]:= Len(&("TMP2->"+aStruTMP[i][1]))
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
			If aStruTMP[ik][1]=="Z1A_FILIAL"
				AADD(aTmp,Z1A_FILIAL)
			ElseIf aStruTMP[ik][1]=="_SEQ"
				AADD(aTmp,strZero(_nseq,10,0))
			ElseIf aStruTMP[ik][1] $ "Z1A_DTINC,Z1A_DTINI,Z1A_DTFIM"
				AADD(aTmp,STOD(&("TMP2->"+aStruTMP[ik][1])))
			Else
				AADD(aTmp,&("TMP2->"+aStruTMP[ik][1]))
			EndIf
	
		Next
		_nSeq++
		AADD(aTmp,.F.)	    //ADD o flag de fim de grid
		AADD(aCols,aTmp)	//Add do Acols
		DbSkip()
	End
	TMP2->(DbCloseArea())

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
	AADD(aHeader,{"Filial"   		, "Z1A_FILIAL"	 , "@!"                 , 02 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Cod.Mercanet"    , "Z1A_CODMER"   , ""                   , 20 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Cod.Protheus"    , "Z1A_COD"      , ""                   , 06 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Bloqueado"       , "A1_MSBLQL"    , ""                   , 03 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Nro.Fila"        , "Z1A_FILA"     , ""                   , 10 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Dt.Chegada"      , "Z1A_DTINC"    , ""                   , 08 , 00 , ".T." , , "D" ,, })
	AADD(aHeader,{"Hr.Chegada"      , "Z1A_HRINC"    , ""                   , 10 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Dt.Ini.Proc"     , "Z1A_DTINI"    , ""                   , 08 , 00 , ".T." , , "D" ,, })
	AADD(aHeader,{"Hr.Ini.Proc"     , "Z1A_HRINI"    , ""                   , 10 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Dt.Fim.Proc"     , "Z1A_DTFIM"    , ""                   , 08 , 00 , ".T." , , "D" ,, })
	AADD(aHeader,{"Hr.Fim.Proc"     , "Z1A_HRFIM"    , ""                   , 10 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Razão Social"    , "Z1A_NOME"     , ""                   , 35 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Município"       , "Z1A_MUN"      , ""                   , 30 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"UF"              , "Z1A_EST"      , ""                   , 02 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"CNPJ"            , "Z1A_CGC"      , ""                   , 15 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Cod.Vend."       , "Z1A_VEND"     , ""                   , 06 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Vendedor"        , "A3_NOME"      , ""                   , 35 , 00 , ".T." , , "C" ,, })
	AADD(aHeader,{"Proc.Retorno Mecanet"    , "Z1A_PROCRT"      , ""                   , 01 , 00 , ".T." , , "C" ,, })

Return



//===========================================================
// 
//  Monta a interface padrão com o usuário
// 
//===========================================================
Static Function BScreen()

	Local aAdvSize		 := {}
	Local aInfoAdvSize	 := {}
	Local aObjSize		 := {}
	Local aObjCoords	 := {}
	Local aButtons   	 := {}

	//------------------------------------------------
	// Monta as Dimensoes dos Objetos
	//------------------------------------------------
	aSizeAut := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 315,  50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo   := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	

	oDlg1  := MSDialog():New( aSizeAut[7],00, aSizeAut[6],aSizeAut[5],"Monitor de Integração -> Clientes MERCANET x PROTHEUS",,,.F.,,,,,,.T.,,,.T. )

	//---------------------------------------------------------------------------------------------------------------
	// Grupo para ligar ou desligar a integração entre Protheus x Mercanet
	//---------------------------------------------------------------------------------------------------------------
	oGrp1      := TGroup():New( 004,004,050,100," Integração Mercanet x Protheus ",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
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
    // Botoes de refresh , visualização de Cliente            
    //--------------------------------------------------------------------
	oGrp2      := TGroup():New(  005,110,050,245,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oBtnVerMerc:= TButton():New( 010,118 , "Ver Dados Mercanet"   , oGrp2 , {|| veCliMerc(oBrw1:aCols[oBrw1:nAt][gdFieldPos("Z1A_CODMER")]) },055,013,,,,.T.,,"",,,,.F. )
	oBtnVerPed := TButton():New( 010,180 , "Ver Dados Protheus"   , oGrp2 , {|| veCliProt(oBrw1:aCols[oBrw1:nAt][gdFieldPos("Z1A_COD")]) },055,013,,,,.T.,,"",,,,.F. )
	oBtnSair   := TButton():New( 030,180 , "Sair"                 , oGrp2 , {|| oDlg1:end() },055,013,,,,.T.,,"",,,,.F. )

	//------------------------------------- SAYs --------------------------------------------
	oGrp3      := TGroup():New(  005,250,050,400,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	cDateTime    := dtoc(dDataBase) + " - " + substr(time(),1,5) + " hs."
	oSay1        := TSay():New( 007,252,{|| "Integração Clientes Mercanet" } , oGrp3,,oFont18b,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,244,012)
	oSay2        := TSay():New( 018,252,{|| "Última atualização: "} , oGrp3,,oFont10,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,244,012)
	oSay3        := TSay():New( 026,252,{|| cDateTime }             , oGrp3,,oFont10,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,244,012)
	oBtnRenew    := TButton():New( 034,252 , "Atualizar"            , oGrp3 , {|| renew() },055,013,,,,.T.,,"",,,,.F. )
	oBtnParam    := TButton():New( 034,320 , "Parâmetros"           , oGrp3 , {|| renew() },055,013,,,,.T.,,"",,,,.F. )


	//------------------------------------- SAYs --------------------------------------------
	oGrp4      := TGroup():New(  005,405,050,650,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )

	//----------------------------------------------------BROWSE------------------------------------------
	oBrw1 := MsNewGetDados():New(aPosObj[2,1]-40, aPosObj[2,2] , aPosObj[2,3] , aPosObj[2,4] ,nOpc,cLinhaOk,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDlg1,aHeader,aCols)
	
	//---------------------------------------------------------
	// Metodo para Ordenar Coluna quando Clicada
	//---------------------------------------------------------
	oBrw1:oBROWSE:bHEADERCLICK := { |oBRW,nCOL,ADIM|oBrw1:oBROWSE:nCOLPOS := nCOL,FORDENA(nCOL),GETCELLRECT(oBRW,@ADIM)}
	
	//---------------------------------------------------------
	// Duplo click na coluna do getdados - Ordena 
	//---------------------------------------------------------
	oBrw1:oBrowse:bLDblClick	:= {|| DbClick(oBrw1)}


	//Executa o renew a cada 2 MINUTOS
	otimer		 :=TTimer():New(12000,{|| oTimer:DeActivate(),Renew(),oTimer:Activate() },oDlg1)
	oTimer:Activate()
	
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
// Funcao duplo clique na linha = Abre cadastro 
// 
//=========================================================================
Static Function dbClick(oObj)

	Local   cCliProt:=  oObj:aCols[oBrw1:nAt][gdFieldPos("Z1A_COD")]
	Local   cCliMerc:=  oObj:aCols[oBrw1:nAt][gdFieldPos("Z1A_CODMER")]

	//---------------------------------------------------
	// Se gerou cadastro, permite a visualização 
	//--------------------------------------------------
	if !empty(cCliProt)
		veCliProt(cCliProt)
	else
		veCliMerc(cCliMerc)
	endif
    
Return


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
// Funcao para ativar ou desativar integracao dos Clientes Mercanet x Protheus 
//
//================================================================================= 
Static Function semaforo(_par01)

	Local cTitulo := ""
	Local cTexto  := ""
	Local cAnexos := ""

	cSemaforo := _par01

	U_PUTZPA("SEMAFORO_MERCACLIENT","ZZ",cSemaforo)

	avalSemaforo(cSemaforo)
	
	Renew()
	
	//---------------------------------------------------------------
	// Envia e-mail notificando ativacao/desativacao da integracao 
	//---------------------------------------------------------------
	cTxtAtv := iif(cSemaforo="ON","ATIVADA","DESATIVADA")
	cTitulo := "Integração Clientes -> Mercanet -> " + cTxtAtv
	cTexto  := cTitulo+"<BR><BR>"+"Usuário Responsável: " + cUserName +"<BR><BR>Data: "+dtoc(date())+"<BR><BR>Hora: "+time()
	MsAguarde ( { || U_SUBEML(cEmail,cTitulo,cTexto,cAnexos) } , iif(cSemaforo=="ON","Ativando ","Desativando ")+"integração...")

Return


//=================================================================================
// 
// Funcao de refresh da tela  
//
//================================================================================= 
Static Function Renew()

	//Recarrega/Atualiza o Array Acols
	LoadAcols()
	
	//Atualiza Data e Hora da obteção dos dados	
	cDateTime    := dtoc(dDataBase) + " - " + substr(time(),1,5) + " hs."
	oSay3:SetText(cDateTime)
	oSay3:CtrlRefresh()
				
	//Define o acols da grid		
	oBrw1:SetArray(aCols,.t.)
	oBrw1:Refresh()
	oBrw1:oBrowse:SetFocus()
		
Return


//=========================================================================
// 
// Visualiza cliente gerado no protheus 
//
//=========================================================================
Static Function veCliProt(cNumCli)

	Private aRotina :=  menuDef()
	Private cCadastro := "Cadastro de clientes"

	SA1->(dbSetOrder(1))
	IF SA1->(dbSeek(xFilial("SA1") + cNumCli))
		nRcno := SA1->(Recno())
		MsAguarde ( { || A030Visual("SA1",nRcno,2) } , "Abrindo cadastro do cliente...")
		return
	endif

	oBrw1:oBrowse:SetFocus()
	
Return



//==========================================================================
//
// Funcao para visualizar os dados originais vindos do MERCANET 
//
//==========================================================================  
Static Function veCliMerc(_cliMer)

   Private aRotina :=  menuDef()
   Private cCadastro := "Cadastro de clientes" 

   dbSelectArea("Z1A") 
   dbSetOrder(2) 
   dbSeek(xFilial("Z1A"+_cliMer))
   
   AXVISUAL("Z1A",Z1A->(RECNO()),4)
   oBrw1:oBrowse:SetFocus()
	
Return