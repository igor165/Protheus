#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"            
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PMSWFI040.CH"
#DEFINE _EOL chr(13) + chr(10)

/* --------------------------------------------------------------------------------------
WStruct		stChaveSE1
Autor		Reynaldo Tetsu Miyashita
Data		05/04/2010
Descricao	Chave Primaria da tabela SE1 (Contas a Receber)
-------------------------------------------------------------------------------------- */
WSStruct stChaveSE1

	WSData cE1_FILIAL	as String
	WSData cE1_PREFIXO	as String
	WSData cE1_NUM		as String
	WSData cE1_PARCELA	as String
	WSData cE1_TIPO		as String
	WSData cE1_CLIENTE	as String
	WSData cE1_LOJA		as String
	WSData cE1_EMPRESA	as String

EndWSStruct

/* --------------------------------------------------------------------------------------
WStruct		stCabSE1
Autor		Edvin Markstein Zimmermann
Data		27/03/2010
Descricao	Cabecalho da tabela SE1 (Contas a Receber)
-------------------------------------------------------------------------------------- */
WSStruct stCabSE1

	WSData cE1_FILIAL	as String
	WSData cE1_PREFIXO	as String 
	WSData cE1_NUM		as String 
	WSData cE1_PARCELA	as String 
	WSData cE1_TIPO		as String
	WSData cE1_NATUREZ	as String 
	WSData cE1_CLIENTE	as String
	WSData cE1_LOJA		as String
	WSData cE1_EMISSAO	as String
	WSData cE1_VENCTO	as String
	WSData nE1_VALOR	as Float
	WSData cE1_PORTADO  as String
	WSData cE1_AGEDEP   as String
	WSData cE1_CONTA    as String
	WSData cAFT_PROJETO	As String
	WSData cAFT_TAREFA	As String
	WSData cE1_EMPRESA	As String

EndWSStruct

/* --------------------------------------------------------------------------------------
WStruct		stSE1Del
Autor		Edvin Markstein Zimmermann
Data		27/03/2010
Descricao	Indice para utilizar exclusao
-------------------------------------------------------------------------------------- */
WSStruct stSE1Del

	WSData cE1_FILIAL	as String
	WSData cE1_PREFIXO	as String
	WSData cE1_NUM		as String
	WSData cE1_PARCELA	as String
	WSData cE1_TIPO		as String
	WSData cE1_CLIENTE	as String
	WSData cE1_LOJA		as String
	WSData cE1_EMPRESA	As String

EndWSStruct


/* --------------------------------------------------------------------------------------
WStruct		stContasAPagar
Autor		Edvin Markstein Zimmermann
Data		27/03/2010
Descricao	Cadastro de Contas a Receber
-------------------------------------------------------------------------------------- */
WSStruct stContasAReceber
                             
	WSData sCab			as stCabSE1

EndWSStruct

/* --------------------------------------------------------------------------------------
WebService	WSFINA040
Autor		Edvin Markstein Zimmermann
Data		27/03/2010
Descricao	Web Service FINA040 - Contas a Receber
-------------------------------------------------------------------------------------- */
WSService WSFINA040 Description STR0001//"FINA040 - Contas a Receber integrado do TOTVS Obras e Projetos" 
    
    //Declara็ใo de variaveis
	WSData sContasAReceber	as stContasAReceber
	WSData cId				as String
	WSData cRet				as String
	WSData sRet				as stChaveSE1
	WSData sSE1Exclui		as stSE1Del

	//Declaracaoo de metodos
	WSMethod Inclui			description STR0002//"Inclui uma conta a Receber" 
	WSMethod Exclui			description STR0003//"Exclui uma conta a Receber" 

ENDWSSERVICE

/*--------------------------------------------------------------------------------------
WSMethod	Inclui
Autor		Edvin Markstein Zimmermann
Data		27/03/2010
Descricao	Inclui uma conta a Receber
Retorno		.t.
--------------------------------------------------------------------------------------*/
WSMethod Inclui WSReceive sContasAReceber WSSEND sRet WSSERVICE WSFINA040

	Local aCabec		:= {}
	Local oCabe			:= nil
	Local aErro			:= {}
	Local nZ				:= 0
	Local cErro			:= ""
	Local cFFILIAL		:= ""
	Local cPREFIXO		:= ""
	Local cNUM			:= ""
	Local cPARCELA		:= ""
	Local cTIPO			:= ""
	Local cCLIENTE		:= ""
	Local cLOJA			:= ""
	Local cNATUREZ		:= ""
	Local aBcoDefault   := {}
	Local lAutoNumTit   := .F.
    Local aItPrjTmp 	:= {}
    Local aItPrj		:= {}
	Local lRet		    :=.T.
	// Controle de Filial PROTHEUS - 13/05/2010 - Multi Filiais
	// Controle de Filial PROTHEUS - 23/11/2010 - cEmpOOO/cFilOOO - Multi Empresas/Filiais
	Local aArea			:= {}
	Local cFilOOO		:= ""
	Local cEmpOOO		:= ""
	Local lEMPFil		:= .F.
	Local nFim          := 0
    Local cVolta        := ""
    Local nColigada     := 0
    Local lTOpxTin      :=.F.
	PRIVATE lMsErroAuto := .F.  

	//UTILIZANDO VARIมVEL PARA MELHOR VISUALIZAวรO DO CำDIGO
	oCabe	:= ::sContasAReceber:sCab

	// **********************
	// *********@@@**********
	// ********@@@@**********
	// *******@**@@**********
	// **********@@**********
	// **********@@**********
	// **********@@**********
	// **********************
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPosicionamento da Empresa/Filial                          ณ
	//ณ                                                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

    If Empty(oCabe:cE1_EMPRESA) .or. Empty(oCabe:cE1_FILIAL)   
		// "Titulo contas a receber nao incluso." "Codigo da Empresa/Filial nao informado (vazio)."
		SetSoapFault( "WSFINA040", STR0004+ STR0005)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
		return .F.
	Endif    

	cFilOOO :=(oCabe:cE1_FILIAL) 
	cEmpOOO :=(oCabe:cE1_EMPRESA)

	lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)

    If !lEMPFil
		SetSoapFault( "WSFINA040",STR0004+ STR0006)//"Titulo contas a receber nao incluso." "Codigo da Empresa/Filial inexistente ou nใo autorizada."                                                                                                                                                                                                                                                                                                                                  
		return .F.
    Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTratamento de variavel apos ter definido o ambiente       ณ
	//ณ                                                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aArea		:= GetArea()
    nColigada:=GetNewPar('MV_RMCOLIG',0)
	lTopxTin:=Iif(FindFunction('intTopTin'),IntTopTin(nColigada),.F.)
	// **********************
	// *******@@@@@**********
	// ******@@**@@@*********
	// **********@@**********
	// *********@@@**********
	// ********@@@***********
	// *******@@@@@@*********
	// **********************

	cFFILIAL	:= xFilial("SE1") 
	cPREFIXO	:= padR(oCabe:cE1_PREFIXO	,TamSX3("E1_PREFIXO")[1])
	cNUM		:= padR(oCabe:cE1_NUM		,TamSX3("E1_NUM")[1])
	cPARCELA	:= padR(oCabe:cE1_PARCELA	,TamSX3("E1_PARCELA")[1])
	cTIPO		:= padR(oCabe:cE1_TIPO		,TamSX3("E1_TIPO")[1])
	If lTopxTin // indica que o cliente usa integra็ใo do Tin e TOP ao mesmo tempo
		cCliente:=IsTopxTin("SA1",(oCabe:cE1_CLIENTE))
		cLOJA:=SubStr(cCliente,TamSX3("E1_CLIENTE")[1]+1,TamSX3("E1_LOJA")[1])
		cCLIENTE:=SubStr(cCliente,1,TamSX3("E1_CLIENTE")[1])
	Else
		cCLIENTE	:= padR(oCabe:cE1_CLIENTE	,TamSX3("E1_CLIENTE")[1])
		cLOJA		:= padR(oCabe:cE1_LOJA		,TamSX3("E1_LOJA")[1])
	Endif
	cNATUREZ	:= padR(oCabe:cE1_NATUREZ	,TamSX3("E1_NATUREZ")[1])

    //
    // se nใo informou o prefixo , utiliza do parametro
    //

	If Empty(cPREFIXO)
		cPREFIXO := SuperGetMv("MV_SLMPRER" ,.F. ,"")
		If Empty(cPREFIXO)
			SetSoapFault("WSFINA040",STR0007)//"Prefixo do titulo a receber em branco, verifique o parametro MV_SLMPRER ou o valor informado."
			return .F.
		endIf		
    EndIf
 
    //
    // se nใo informou o numero, deve gerar um sequencial baseado no prefixo+cliente+loja
    //
    If Empty(cNUM)
		cNUM := GetNumSE1(cPrefixo ,cCliente ,cLoja, cPARCELA ,cTIPO)
		lAutoNumTit := .T.
	EndIf
		
    //
    // se nใo informou o prefixo , utiliza do parametro
    //
	If Empty(cNATUREZ)
		cNATUREZ := SuperGetMv("MV_SLMNATR" ,.F. ,"")
		If Empty(cNATUREZ)
			SetSoapFault("WSFINA040",STR0008)//"Natureza do titulo a receber em branco, verifique o parametro MV_SLMNATR ou o valor informado."
			return .F.
		EndIf		
     Else
     	If lTopxTin // indica que o cliente usa integra็ใo do Tin e TOP ao mesmo tempo
			cNATUREZ:=IsTopxTin("SED",oCabe:cE1_NATUREZ)
			cNATUREZ:=SubStr(cNATUREZ,TAMSX3("ED_FILIAL")[1]+1,TAMSX3("ED_CODIGO"))
		Endif
     EndIf

	//Verificando se ja existe uma inclusao com esta chave
	dbSelectArea("SE1")
	SE1->(dbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
    If SE1->(DbSeek( cFFILIAL + cCLIENTE + cLOJA + cPREFIXO + cNUM + cPARCELA + cTIPO ))
		SetSoapFault("WSFINA040",STR0009)//"Nao e possivel duplicar registro."
		return .F.
	EndIf		
	     
	//Verificando se ja existe o cliente no Protheus   
	dbSelectArea("SA1")
	dbSetOrder(1)
	If !DbSeek(xFilial("SA1")+cCLIENTE + cLOJA)
      conOut(xFilial("SA1")+cCLIENTE + cLOJA )
		SetSoapFault("WSFINA040",STR0010)//"Cliente ou Loja Inexistente."
		return .F.
	endIf	 
	
	//Verificando se o Tipo existe no SX5
	If !Empty(cTipo)
		dbSelectArea( "SX5" )                              
		SX5->( MsSeek(cFilial+"05") )
		While SX5->X5_FILIAL+SX5->X5_TABELA == cFilial+"05"
			If SX5->X5_CHAVE = cTIPO
				cVolta := Left( X5Descri(),20 )
		 		Exit
			EndIf
			SX5->(dbSkip())
		End 
		If Empty(cVolta)
	      conOut("WSFINA040" + ALLTRIM(cTipo) + STR0011 )//"Tipo do Titulo Inexistente!!!"
			SetSoapFault("WSFINA040",+ ALLTRIM(cTipo) +STR0011 ) //"Tipo do Titulo Inexistente!!!"
			return .F.
		Endif
	Else      
      conOut("WSFINA040" + ALLTRIM(cTipo) + STR0012 )//"Tipo do Titulo nใo informado!!!"
		SetSoapFault("WSFINA040",+ ALLTRIM(cTipo) +STR0012 )//"Tipo do Titulo nใo informado!!!"
		return .F.
   Endif 
	 lRet:= Pms040Loc(cTipo)
	 If lRet
	   
		//CRIANDO CABECALHO
		AADD(aCabec,{"E1_FILIAL"	, cFFILIAL				, Nil})
		AADD(aCabec,{"E1_PREFIXO"	, cPrefixo				, Nil})
		AADD(aCabec,{"E1_NUM"		, cNUM					, Nil})
		AADD(aCabec,{"E1_PARCELA"	, cPARCELA				, Nil})
		AADD(aCabec,{"E1_TIPO"		, cTIPO					, Nil})
		AADD(aCabec,{"E1_NATUREZ"	, cNATUREZ				, Nil})
		AADD(aCabec,{"E1_CLIENTE"	, cCLIENTE				, Nil})
		AADD(aCabec,{"E1_LOJA"		, cLOJA					, Nil})
		AADD(aCabec,{"E1_EMISSAO"	, CtoD(oCabe:cE1_EMISSAO), Nil})
		AADD(aCabec,{"E1_VENCTO"	, CtoD(oCabe:cE1_VENCTO), Nil})
		AADD(aCabec,{"E1_VENCREA"	, Datavalida( CtoD(oCabe:cE1_VENCTO)), Nil})
		AADD(aCabec,{"E1_VALOR"		, oCabe:nE1_VALOR		, Nil})
		AADD(aCabec,{"E1_VLCRUZ"	, oCabe:nE1_VALOR		, Nil})
		AADD(aCabec,{"E1_PROJPMS"   , "1"					, Nil})
		AADD(aCabec,{"E1_MOEDA"		, 1						, Nil})
		AADD(aCabec,{"E1_ORIGEM"   , "WSFINA04",				Nil})	
	
		If !Empty(oCabe:cAFT_PROJETO)        
		   cTarefa := IIF(Empty(oCabe:cAFT_TAREFA ),oCabe:cAFT_PROJETO,oCabe:cAFT_TAREFA) 
			aItPrjTmp := {}
			aadd( aItPrjTmp ,{"AFT_PROJET" 		, oCabe:cAFT_PROJETO		, Nil })
			aadd( aItPrjTmp ,{"AFT_EDT" 		   , Space(TamSX3("AFT_EDT")[1])		, Nil })
			aadd( aItPrjTmp ,{"AFT_REVISA" 		, StrZero(1,TamSX3("AFT_REVISA")[1]), Nil })
			aadd( aItPrjTmp ,{"AFT_TAREFA" 		, cTarefa            		, Nil })
			aadd( aItPrjTmp ,{"AFT_PREFIX" 		, cPREFIXO				 	, Nil })
			aadd( aItPrjTmp ,{"AFT_NUM" 	    	, cNUM					 	, Nil })
			aadd( aItPrjTmp ,{"AFT_PARCEL" 		, cPARCELA				 	, Nil })
			aadd( aItPrjTmp ,{"AFT_TIPO" 	    	, cTIPO					 	, Nil })
			aadd( aItPrjTmp ,{"AFT_CLIENT" 		, cCLIENTE				 	, Nil })
			aadd( aItPrjTmp ,{"AFT_LOJA" 	   	, cLOJA					 	, Nil })
			aadd( aItPrjTmp ,{"AFT_VALOR1" 		, oCabe:nE1_VALOR		 	, Nil })		
			aadd( aItPrjTmp ,{"AFT_DATA" 	   	, CtoD(oCabe:cE1_EMISSAO)	, Nil })	
			aadd( aItPrjTmp ,{"AFT_VENREA" 		, CtoD(oCabe:cE1_VENCTO)	, Nil })		
			aAdd(aItPrj ,aClone(aItPrjTmp))      
		EndIf
		
		//Verificando se informou data de Emissใo
		if Empty(CtoD(oCabe:cE1_EMISSAO))
	      conOut(STR0013)//"WSFINA040 - Data de Emissใo nใo informada."
			SetSoapFault(STR0013)//"WSFINA040 - Data de Emissใo nใo informada."
			return .F.
		endIf          
		
		//Verificando se informou vencto Real
		if Empty(CtoD(oCabe:cE1_VENCTO))
	      conOut(STR0014)//"WSFINA040 - Data de Vencimento Real nใo informada."
			SetSoapFault(STR0014)
			return .F.
		endIf
		
		//Verificando se informou vencto Real menor que Data de Emissใo
		if CtoD(oCabe:cE1_VENCTO) < CtoD(oCabe:cE1_EMISSAO)
	      conOut(STR0015)//"WSFINA040 - Data de Vencimento Real Menor que Data de Emissใo."
			SetSoapFault(STR0015)
			return .F.
		endIf
	           
		//Verificando se informou Valor do titulo
		if Empty(oCabe:nE1_VALOR)
	      conOut("WSFINA040, " + STR0016)//" - Valor nใo informado."
			SetSoapFault("WSFINA040, "+STR0016)
			return .F.
		endIf
		
		If cTIPO $ MVRECANT
	    	//
	    	// carrega o banco/agencia/conta padrใo do parametro MV_CXFIN
	    	//
			aBcoDefault := xCxFina()
		
			If Empty(oCabe:cE1_PORTADO)
				oCabe:cE1_PORTADO := aBcoDefault[1]
				oCabe:cE1_AGEDEP  := aBcoDefault[2]
				oCabe:cE1_CONTA   := aBcoDefault[3]
			EndIf
	
			AADD(aCabec,{"CBCOAUTO"	, oCabe:cE1_PORTADO	, Nil})
			AADD(aCabec,{"CAGEAUTO"	, oCabe:cE1_AGEDEP	, Nil})
			AADD(aCabec,{"CCTAAUTO"	, oCabe:cE1_CONTA	, Nil})
	
		EndIf
	
		// ponto de entrada inserido para controlar dados especificos do cliente
		If ExistBlock("PWSFI040")
			aRetPe := ExecBlock("PWSFI040",.F.,.F.,{aCabec,aItPrj})
			If ValType(aRetPe) == "A" .And. Len(aRetPe) == 2 .And.;
			 	ValType(aRetPe[1]) == "A" .And. ValType(aRetPe[2]) == "A"
				aCabec := aClone(aRetPe[1])
				aItPrj := aClone(aRetPe[2])
			EndIf
		EndIf
		
		ConOUT(STR0017 +"(" + TIME() + ")")//EXECUTANDO FUNCAO DE GRAVACAO AUTOMATICA FINA040...
	
		lMsErroAuto := .F.
		
	  	MsExecAuto({|x,y| FINA040(x,y) },aCabec,3)
	  	
		If lAutoNumTit
			FreeUsedCode(.T.)
		EndIf
	
		//VERIFICANDO SE HOUVE ERRO AO FECHAR O PEDIDO
		If lMsErroAuto
	
			conOut(STR0018)//" *** ATENCAO *** "
			conOut(STR0019 + DtoC(Date()) + " - " + time())//"     ERRO AO EFETUAR SOLICITACAO - DATA: "
			conOut(STR0020)//"++++++++++ SOLICITACAO DO ERRO ++++++++++"
			conOut(MemoRead(NomeAutoLog()))
	
			//LISTANDO DETALHES DO ERRO
	 		aErro := GetAutoGRLog()
			For nZ := 1 To Len(aErro)
				cErro += aErro[nZ] + Chr(13)+Chr(10)
			Next nZ
			conOut(cErro)
			conOut("---------------------------------------")
	
			//LISTANDO DETALHES DO WS
			cErro:= STR0025 + ", "   
			nFim:=10
			For nZ := 2 TO nFim
			   If ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) <> ""
	  				cErro+= ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) + " "
	  			Else            
	  				nZ:=10
				Endif
			Next nZ		
			SetSoapFault("WSFINA040",STR0025 + CRLF + MemoRead(NomeAutoLog()))
			return .F.
		Else
			conOut("FINA040"+STR0021+  "(" + TIME() + ")")//EXECUTADO!
		EndIf
	
		::sRet:cE1_FILIAL		:= cFFILIAL
		::sRet:cE1_PREFIXO	:= cPREFIXO
		::sRet:cE1_NUM			:= cNUM
		::sRet:cE1_PARCELA	:= cPARCELA
		::sRet:cE1_TIPO		:= cTIPO
		::sRet:cE1_CLIENTE	:= cCLIENTE
		::sRet:cE1_LOJA		:= cLOJA
		::sRet:cE1_EMPRESA	:= cEmpOOO
	
		pmsWsCR("3" ,aItPrj )
		conOut(STR0022)//"FINALIZANDO..."
	Endif
RestArea(aArea)		
Return lRet

/*--------------------------------------------------------------------------------------
WSMethod	Exclui
Autor		Edvin Markstein Zimmermann
Data		20/03/2010
Descricao	Exclui um pedido de venda
Retorno		.t.
--------------------------------------------------------------------------------------*/
WSMethod Exclui WSReceive sSE1Exclui WSSEND cRet WSSERVICE WSFINA040

	Local aCabec		:= {}
	Local aItPrjTmp		:= {}
	Local aItPrj		:= {}
	Local nZ			:= 0
	Local cFFILIAL		:= ""
	Local cPREFIXO		:= ""
	Local cNUM			:= ""
	Local cPARCELA		:= ""
	Local cTIPO			:= ""
	Local cCLIENTE		:= ""
	Local cLOJA			:= ""
	Local cErro			:= ""
	Local lRet			:=.T.
	// Controle de Filial PROTHEUS - 13/05/2010 - Multi Filiais
	// Controle de Filial PROTHEUS - 23/11/2010 - cEmpOOO/cFilOOO - Multi Empresas/Filiais
	Local aArea			:= {}
	Local cEmpOOO		:= ""
	Local cFilOOO		:= ""
	Local lEMPFil		:= .F.
	Local nFim        := 0
    Local nColigada:=0
    Local lTOpxTin:=.F.
	PRIVATE lMsErroAuto := .F.  

	// **********************
	// *********@@@**********
	// ********@@@@**********
	// *******@**@@**********
	// **********@@**********
	// **********@@**********
	// **********@@**********
	// **********************
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPosicionamento da Empresa/Filial                          ณ
	//ณ                                                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

    If Empty(::sSE1Exclui:cE1_EMPRESA) .Or. Empty(::sSE1Exclui:cE1_FILIAL)
		SetSoapFault( "WSFINA040",STR0023 + STR0005)//"Titulo contas a receber nao excluido.Codigo da Empresa/Filial nao informado (vazio)."     
		return .F.
	Endif    

	cFilOOO := ::sSE1Exclui:cE1_FILIAL
	cEmpOOO := ::sSE1Exclui:cE1_EMPRESA

	lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)

    If !lEMPFil
		SetSoapFault( "WSFINA040",STR0023 + STR0006)//Titulo contas a receber nao excluido."Codigo da Empresa/Filial inexistente ou nใo autorizada" 
		return .F.
    Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTratamento de variavel apos ter definido o ambiente       ณ
	//ณ                                                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aArea	:= GetArea()
    nColigada:=GetNewPar('MV_RMCOLIG',0)
	lTopxTin:=Iif(FindFunction('intTopTin'),intTopTin(nColigada),.F.)
	// **********************
	// *******@@@@@**********
	// ******@@**@@@*********
	// **********@@**********
	// *********@@@**********
	// ********@@@***********
	// *******@@@@@@*********
	// **********************

	cFFILIAL	:= xFilial("SE1") // padR(::sSE1Exclui:cE1_FILIAL,TamSX3("E1_FILIAL")[1])
	cPREFIXO	:= padR(::sSE1Exclui:cE1_PREFIXO,TamSX3("E1_PREFIXO")[1])
	cNUM		:= padR(::sSE1Exclui:cE1_NUM,TamSX3("E1_NUM")[1])
	cPARCELA	:= padR(::sSE1Exclui:cE1_PARCELA,TamSX3("E1_PARCELA")[1])
	cTIPO		:= padR(::sSE1Exclui:cE1_TIPO,TamSX3("E1_TIPO")[1])
	If lTopxTin // indica que o cliente usa integra็ใo do Tin e TOP ao mesmo tempo
		cCLIENTE:=IsTopxTin("SA1",(::sSE1Exclui:cE1_CLIENTE))
		cLOJA:=SubStr(cCliente,TamSX3("E1_CLIENTE")[1]+1,TamSX3("E1_LOJA")[1])
		cCLIENTE:=SubStr(cCliente,1,TamSX3("E1_CLIENTE")[1])
	Else
		cCLIENTE	:= padR(::sSE1Exclui:cE1_CLIENTE,TamSX3("E1_CLIENTE")[1])
		cLOJA		:= padR(::sSE1Exclui:cE1_LOJA,TamSX3("E1_LOJA")[1])
	Endif

	dbSelectArea("SE1")
	SE1->(dbSetOrder(2))//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
    If !SE1->(DbSeek( cFFILIAL + cCLIENTE + cLOJA + cPREFIXO + cNUM + cPARCELA + cTIPO ))
		SetSoapFault("WSFINA040",STR0024)//"Titulo contas a receber nao encontrado."
		return .F.
	endIf		
	lRet:=PMS040Loc(cTipo)
	If lRet
	
		//CRIANDO CABECALHO
		AADD(aCabec,{"E1_FILIAL"	, 	cFFILIAL	, Nil})
		AADD(aCabec,{"E1_PREFIXO"	,	cPREFIXO	, Nil})
		AADD(aCabec,{"E1_NUM"		,	cNUM		, Nil})
		AADD(aCabec,{"E1_PARCELA"	, 	cPARCELA	, Nil})
		AADD(aCabec,{"E1_TIPO"		,	cTIPO		, Nil})
		AADD(aCabec,{"E1_CLIENTE"	,	cCLIENTE	, Nil})
		AADD(aCabec,{"E1_LOJA"		,	cLOJA		, Nil})
	    
	           
		aItPrjTmp := {}
		aadd( aItPrjTmp ,{"AFT_PREFIX" 		, cPREFIXO				 	, Nil } )
		aadd( aItPrjTmp ,{"AFT_NUM" 		, cNUM					 	, Nil } )
		aadd( aItPrjTmp ,{"AFT_PARCEL" 		, cPARCELA				 	, Nil } )
		aadd( aItPrjTmp ,{"AFT_TIPO" 		, cTIPO					 	, Nil } )
		aadd( aItPrjTmp ,{"AFT_CLIENT" 		, cCLIENTE				 	, Nil } )
		aadd( aItPrjTmp ,{"AFT_LOJA" 		, cLOJA					 	, Nil } )
		
		aAdd(aItPrj ,aClone(aItPrjTmp))
	
		//EXECUTANDO FUNCAO DE GRAVACAO AUTOMATICA
		CONOUT(STR0017+"(" + TIME() + ")")//"EXECUTANDO FUNCAO DE GRAVACAO AUTOMATICA FINA040... "
	
		lMsErroAuto := .F.
		
		MsExecAuto({|x,y| FINA040(x,y) },aCabec,5)
	
		//VERIFICANDO SE HOUVE ERRO AO FECHAR O PEDIDO
		If lMsErroAuto
	
			conOut(STR0018)//" *** ATENCAO *** "
			conOut(STR0019 + DtoC(Date()) + " - " + time())//"     ERRO AO EFETUAR SOLICITACAO - DATA: "
			conOut(STR0020)//"++++++++++ SOLICITACAO DO ERRO ++++++++++"
			conOut(MemoRead(NomeAutoLog()))
			
			//LISTANDO DETALHES DO ERRO
			aErro := GetAutoGRLog()
			For nZ := 1 To Len(aErro)
				cErro += aErro[nZ] + Chr(13)+Chr(10)
			Next nZ
			conOut(cErro)
			conOut("---------------------------------------")
	
			//LISTANDO DETALHES DO WS
			cErro:= STR0025 + ", "//VERIFIQUE!       
			nFim:=10
			For nZ := 2 TO nFim
			   If ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) <> ""
	  				cErro+= ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) + " "
	  			Else            
	  				nZ:=10
				Endif
			Next nZ		
			SetSoapFault("WSFINA040",STR0025 + CRLF +MemoRead(NomeAutoLog()) )		
			return .F.
		Else
			conOut("FINA040"+" " +STR0021+"(" + TIME() + ")")//EXECUTADO
		EndIf
	
		// Exclui a associacao com o projeto
		pmsWsCR("5" ,aItPrj )
	
		::cRet := STR0026//"Titulo a receber excluido com sucesso."
Endif
RestArea(aArea)		

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetNumSE1 บAutor  ณMicrosiga           บ Data ณ  07/22/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o proximo numero do titulo                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetNumSE1(cPrefixo ,cCliente ,cLoja,cPARCELA ,cTIPO)

Local cNumero := ""
Local cMay := ""
Local cRetorno  := ""
Local cQuery    := ""
Local cAliasSE1 := ""


#IFDEF TOP
	cAliasSE1 := "AliasSE1"
	cQuery    := "SELECT MAX(E1_NUM) AS NUMERO "
	cQuery    += "FROM "+RetSqlName("SE1")+" "
	cQuery    += "WHERE E1_FILIAL ='"+xFilial("SE1")+"' AND "
	cQuery    += "E1_PREFIXO ='"+cPrefixo+"' AND "
	cQuery    += "E1_PARCELA ='"+cPARCELA+"' AND "
	cQuery    += "E1_TIPO ='"+cTIPO+"' AND "
	cQuery    += "E1_CLIENTE ='"+cCliente+"' AND "
	cQuery    += "E1_LOJA ='"+cLoja+"' AND "
	cQuery    += "D_E_L_E_T_=' ' "
	cQuery    := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1,.T.,.T.)
	If (cAliasSE1)->(!Eof())
		cNumero := IIF(Empty((cAliasSE1)->NUMERO) ,STRZERO(1 ,Len(SE1->E1_NUM)) ,Soma1((cAliasSE1)->NUMERO))
	EndIf	 
	
	If Empty(cNumero)
		cNumero := STRZERO(1 ,Len(SE1->E1_NUM))
	EndIf
	(cAliasSE1)->(dbCloseArea())

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValida se o titulo nใo estแ sendo usado em outro processoณ
	//ณe nใo tem no SE5                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	SE5->(dbSetOrder(7))
	dbSelectArea("SE1")
	cMay := "SE1"+xFilial("SE1")+cNumero+cCliente+cLoja
	While .T. 
		If MayIUseCode(cMay)  .And. !SE5->(dbSeek( xFilial("SE5") + cPrefixo + cNumero + cParcela + cTipo ) )
			Exit
		EndIf 
		cNumero := Soma1(cNumero)
		cMay := "SE1"+xFilial("SE1")+cNumero+cCliente+cLoja
	EndDo
#ENDIF
cRetorno := cNumero

Return(cRetorno)

User Function NOTHING2; Return  // "dummy" function - Internal Use



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMSSM0Emp บAutor  ณMicrosiga           บ Data ณ  18/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPosiciona a empresa e filial                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMSSM0Env(cEEmp,cFFil)
Local lEMPfil	:= .F.

Default cEEmp	:= ''
Default cFFil:=''

If Empty(cEEmp) .Or. Empty(cFFil) 
	conOut(STR0005 ,cEEmp ,cFFil)//'Empresa/Filial nao informado (vazio)'
Else
	lEmpFil:=PmsW40Fil (cEEmp, cFFil)
Endif
Return lEMPfil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMS040Loc บAutor  ณJandir Deodato      บ Data ณ  31/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se ้ localizado a integra็ใo                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PMS040Loc(cTipo)
Local lREt:=.T.
If (cTipo $ MVRECANT .And. cPaisLoc <> "BRA")//para localizacoes so e permitido a geracao de Pas no Protheus
   		 SetSoapFault("WSFINA040",STR0027+" "+ alltrim(cTipo)+" " + STR0028 )//"Para localiza็๕es s๓ ้ permitido a manipula็ao de " "no Protheus."
   		lRet:=.F.
Endif
Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} PmsW40Fil(cEEmp, cFFil)
Fun็ใo para realizar a troca de ambiente nos webservices da integra็ใo  Protheus X TOP - Fase1

@param   cEEmp          C๓digo da empresa/grupo de empresas
@param   cFFil   		C๓digo da filial

@author  Jandir Deodato
@version P11
@since   19/04/2013
@return  lRet  		Indica se conseguiu ou nใo abrir o ambiente informado.

//-------------------------------------------------------------------
*/

Function PmsW40Fil (cEEmp, cFFil)
Local lRet:=.F.

If Type ('cEmpAnt') # 'U' .and. Type ('cFilAnt') #'U'
	If cEmpAnt==Padr(AllTrim(CEEmp),len(cEmpAnt)) .and. cFilAnt==Padr(AllTrim(cFFil),Len(cFilAnt))//esta logado na filial certa
		lRet:=.T.
	Endif
Endif
If !lRet
	RpcClearEnv()
	RpcSetType(3)
	lRet :=	 RpcSetEnv( cEEmp, cFFil )
Endif
If !lRet//for็ando para verificar se o tamanho das variแveis estแ correta. Agora o SM0 estแ aberto
	cEEmp:=Padr(AllTrim(CEEmp),len(SM0->M0_CODIGO))
	cFFil:=Padr(AllTrim(cFFil),Len(cFilAnt))
	RpcClearEnv()
	RpcSetType(3)
	lRet:=RpcSetEnv( cEEmp, cFFil )
Endif
If lRet	
	lRet:=EmprOk(cEEmp+cFFil)//verificando se a empresa/filial estแ autorizada.
Endif 	
Return lRet



