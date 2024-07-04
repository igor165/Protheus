#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"            
#include "tbiconn.ch"
#include "topconn.ch"
#include "pmswfi050.ch"
#DEFINE _EOL chr(13) + chr(10)

/* --------------------------------------------------------------------------------------
WStruct		stChaveSE2
Autor		Reynaldo Tetsu Miyashita
Data		05/04/2010
Descricao	Chave Primaria da tabela SE2 (Contas a Pagar)
-------------------------------------------------------------------------------------- */
WSStruct stChaveSE2

	WSData cE2_FILIAL	as String
	WSData cE2_PREFIXO	as String
	WSData cE2_NUM		as String
	WSData cE2_PARCELA	as String
	WSData cE2_TIPO		as String
	WSData cE2_FORNECE	as String
	WSData cE2_LOJA		as String
	WSData cE2_EMPRESA	as String

EndWSStruct

/* --------------------------------------------------------------------------------------
WStruct		stCabSE2
Autor		Edvin Markstein Zimmermann
Data		27/03/2010
Descricao	Cabecalho da tabela SE2 (Contas a Pagar)
-------------------------------------------------------------------------------------- */
WSStruct stCabSE2

	WSData cE2_FILIAL	as String
	WSData cE2_PREFIXO	as String
	WSData cE2_NUM		as String
	WSData cE2_PARCELA	as String
	WSData cE2_TIPO		as String
	WSData cE2_FORNECE	as String
	WSData cE2_LOJA		as String
	WSData cE2_NATUREZ	as String
	WSData cE2_EMISSAO	as String
	WSData cE2_VENCTO	as String
	WSData cAFR_PROJETO	As String
	WSData cAFR_TAREFA	As String
	WSData nE2_VALOR	as Float
	WSData cE2_EMPRESA	As String
	WSData cE2_CCD as String OPTIONAL

EndWSStruct

/* --------------------------------------------------------------------------------------
WStruct		stSE2Del
Autor		Edvin Markstein Zimmermann
Data		27/03/2010
Descricao	Indice para utilizar exclusao
-------------------------------------------------------------------------------------- */
WSStruct stSE2Del

	WSData cE2_FILIAL	as String
	WSData cE2_PREFIXO	as String
	WSData cE2_NUM		as String
	WSData cE2_PARCELA	as String
	WSData cE2_TIPO		as String
	WSData cE2_FORNECE	as String
	WSData cE2_LOJA		as String
	WSData cE2_EMPRESA	as String

EndWSStruct


/* --------------------------------------------------------------------------------------
WStruct		stContasAPagar
Autor		Edvin Markstein Zimmermann
Data		27/03/2010
Descricao	Cadastro de Contas a Pagar
-------------------------------------------------------------------------------------- */
WSStruct stContasAPagar
                             
	WSData sCab			as stCabSE2

EndWSStruct

/* --------------------------------------------------------------------------------------
WebService	WSFINA050
Autor		Edvin Markstein Zimmermann
Data		27/03/2010
Descricao	Web Service FINA050 - Contas a Pagar
-------------------------------------------------------------------------------------- */
WSService WSFINA050 Description STR0001//"FINA050 - Contas a Pagar integrado do TOTVS Obras e Projetos"
    
    //Declaração de variaveis
	WSData sContasAPagar	as stContasAPagar
	WSData cId				as String
	WSData sRet				as stChaveSE2 
	WSData cRet				as String
	WSData sSE2Exclui		as stSE2Del

	//Declaracaoo de metodos
	WSMethod Inclui			description STR0002//"Inclui uma conta a pagar" 
	WSMethod Exclui			description STR0003//"Exclui uma conta a pagar" 

ENDWSSERVICE

/*--------------------------------------------------------------------------------------
WSMethod	Inclui
Autor		Edvin Markstein Zimmermann
Data		27/03/2010
Descricao	Inclui uma conta a pagar
Retorno		.t.
--------------------------------------------------------------------------------------*/
WSMethod Inclui WSReceive sContasAPagar WSSEND sRet WSSERVICE WSFINA050

	Local aCabec		:= {}
	Local lAuto			:= nil
	Local oCabe			:= nil
	Local aErro			:= {}
	Local nZ			:= 0
	Local cErro			:= ""
	Local cFFILIAL		:= ""
	Local cPREFIXO		:= ""
	Local cNUM			:= ""
	Local cPARCELA		:= ""
	Local cTIPO			:= ""
	Local cFORNECE		:= ""
	Local cLOJA			:= ""
	Local cNATUREZ      := ""
	Local cCTCUSTDT := ""
	Local lAutoNumTit   := .F.
    Local aItPrjTmp 	:= {}
    Local aItPrj		:= {}
	Local aBcoDefault   := {}
   Local lRet :=.T.
	// Controle de Filial PROTHEUS - 13/05/2010 - Multi Filiais
	// Controle de Filial PROTHEUS - 23/11/2010 - cEmpOOO/cFilOOO - Multi Empresas/Filiais
	Local aArea			:= {}
	Local cFilOOO		:= ""
	Local cEmpOOO		:= ""
	Local lEMPFil		:= .F.
	Local nFim			:= 0
	Local nColigada:=0
    Local lTOpxTin:=.F.
	PRIVATE lMsErroAuto := .F.  

	//UTILIZANDO VARIÁVEL PARA MELHOR VISUALIZAÇÃO DO CÓDIGO
	oCabe	:= ::sContasAPagar:sCab

	// **********************
	// *********@@@**********
	// ********@@@@**********
	// *******@**@@**********
	// **********@@**********
	// **********@@**********
	// **********@@**********
	// **********************
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicionamento da Empresa/Filial                          ³
	//³                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    If Empty(oCabe:cE2_EMPRESA) .or. Empty(oCabe:cE2_FILIAL)
		SetSoapFault( "WSFINA050",STR0004 + " " + STR0005)//"Titulo contas a pagar nao incluso.""Codigo da Empresa/Filial nao informado (vazio)."
		return .F.
	Endif    

	If Type("cFilAnt") =="U" //retirou o preparein do ini
		If FindFunction("PmsW40Fil")
			cFilOOO := (oCabe:cE2_FILIAL) 
			cEmpOOO :=	(oCabe:cE2_EMPRESA) 
			lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
		Else //está sem o preparein, e nao vai conseguir setar a filial.
			SetSoapFault( "WSFINA050",STR0030)//Não foi possível completar esta ação. É necessária uma atualização dos WebServices de integração TOP x Protheus. Entre com contato com o Suporte Totvs."
			return .F.
		Endif
	Else
		cFilOOO := Padr(Alltrim(oCabe:cE2_FILIAL) ,Len(cFilAnt) )
		cEmpOOO := Padr(Alltrim(oCabe:cE2_EMPRESA),Len(cEmpAnt) )
		lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
	Endif
    If !lEMPFil
		SetSoapFault( "WSFINA050",STR0004 + " "  + STR0006 )//"Titulo contas a pagar nao incluso. Codigo da Empresa/Filial inexistente ou não autorizada"
		return .F.
    Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento de variavel apos ter definido o ambiente       ³
	//³                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArea		:= GetArea()
	nColigada:=GetNewPar('MV_RMCOLIG',0)
	lTopxTin:=Iif(FindFunction('IntTopTin'),IntTopTin(nColigada),.F.)
	// **********************
	// *******@@@@@**********
	// ******@@**@@@*********
	// **********@@**********
	// *********@@@**********
	// ********@@@***********
	// *******@@@@@@*********
	// **********************

	cFFILIAL	:= xFilial("SE2") 
	cPREFIXO	:= padR(oCabe:cE2_PREFIXO,TamSX3("E2_PREFIXO")[1])
	cNUM		:= padR(oCabe:cE2_NUM,TamSX3("E2_NUM")[1])
	cPARCELA	:= padR(oCabe:cE2_PARCELA,TamSX3("E2_PARCELA")[1])
	cTIPO		:= padR(oCabe:cE2_TIPO,TamSX3("E2_TIPO")[1])
	If lTopxTin // indica que o cliente usa integração do Tin e TOP ao mesmo tempo
		cFORNECE:=IsTopxTin("SA2",(oCabe:cE2_FORNECE))
		cLOJA:=SubStr(cFORNECE,TamSX3("E2_FORNECE")[1]+1,TamSX3("E2_LOJA")[1])
		cFORNECE:=SubStr(cFORNECE,1,TamSX3("E2_FORNECE")[1])
		cCTCUSTDT:=IsTopxTin("CTT",(oCabe:cE2_CCD))
		cCTCUSTDT:=SubStr(cCTCUSTDT,TAMSX3('CTT_FILIAL')[1]+1,TAMSX3("CTT_CUSTO")[1])	
	Else
		cFORNECE	:= padR(oCabe:cE2_FORNECE,TamSX3("E2_FORNECE")[1])
		cLOJA		:= padR(oCabe:cE2_LOJA,TamSX3("E2_LOJA")[1])
		cCTCUSTDT := padR(oCabe:cE2_CCD,TamSX3("E2_CCD")[1])
	Endif
	cNATUREZ	:= padR(oCabe:cE2_NATUREZ,TamSX3("E2_NATUREZ")[1])

    //
    // se não informou o prefixo , utiliza do parametro
    //
	If Empty(cPREFIXO)
		cPREFIXO := SuperGetMv("MV_SLMPREP" ,.F. ,"")
		If Empty(cPREFIXO)
			SetSoapFault("WSFINA050",STR0007)//"Prefixo do titulo a pagar em branco, verifique o parametro MV_SLMPREP ou o valor informado."
			return .F.
		EndIf		
    EndIf

	
    //
    // se nao informou o numero, deve gerar um sequencial baseado no prefixo+fornece+loja
    //
    If Empty(cNUM)
		cNUM := GetNumSE2(cPrefixo ,cFornece ,cLoja)
		lAutoNumTit   := .T.
	EndIf
                           
    //
    // se não informou o prefixo , utiliza do parametro
    //
	If Empty(cNATUREZ)
		cNATUREZ := SuperGetMv("MV_SLMNATP" ,.F. ,"")
		If Empty(cNATUREZ)
			SetSoapFault("WSFINA050",STR0008)//"Natureza do titulo a pagar em branco, verifique o parametro MV_SLMNATP ou o valor informado."
			return .F.
		EndIf		
     Else
     	If lTopxTin // indica que o cliente usa integração do Tin e TOP ao mesmo tempo
			cNATUREZ:=IsTopxTin("SED",oCabe:cE2_NATUREZ)
			cNATUREZ:=SubStr(cNATUREZ,TAMSX3("ED_FILIAL")[1]+1,TAMSX3("ED_CODIGO"))
		Endif
     EndIf
    
	//Verificando se ja existe uma inclusao com esta chave
	dbSelectArea("SE2")
	SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
    If SE2->(DbSeek( cFFILIAL + cPREFIXO + cNUM + cPARCELA + cTIPO + cFORNECE + cLOJA ))
		SetSoapFault("WSFINA050",STR0009)//"Nao e possivel duplicar registro."
		return .F.
	endIf		

	//Verificando se ja existe o fornecedor no Protheus   
	dbSelectArea("SA2")
	dbSetOrder(1)
	If !DbSeek(xFilial("SA2")+cFORNECE + cLOJA )
       conOut(xFilial("SA2")+cFORNECE + cLOJA )
		SetSoapFault("WSFINA050",STR0010)//"Fornecedor ou Loja Inexistente."
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
	      conOut("WSFINA050" +" " + ALLTRIM(cTipo)+ " " + STR0011 )//"Tipo do Titulo Inexistente!!!"
			SetSoapFault("WSFINA050",+ ALLTRIM(cTipo)+ " " + STR0011)//"Tipo do Titulo Inexistente!!!" 
			return .F.
		Endif
	Else      
      conOut("WSFINA050" + ALLTRIM(cTipo) + STR0012 )//"-Tipo do Titulo não informado!!!"
		SetSoapFault("WSFINA050",+ ALLTRIM(cTipo) + STR0012)//"-Tipo do Titulo não informado!!!"
		return .F.
   Endif
   
   /* Trecho comentado até que a parte RM Solum da implementação esteja pronta para a correta integração
   @autor luis.gustavo@totvs.com.br
   @since 10/07/2012
   // Verificando se o centro de custo de debito foi informado no cabecalho e esta cadastrado
   // no Protheus        
   if(empty(cCTCUSTDT))
		conOut("WSFINA050 - Centro de Custo de Débito não informado!!!" )
		SetSoapFault("WSFINA050", + "Centro de Custo de Débito não informado!!!")
		return .F.
	ElseIf (!CTB105CC(cCTCUSTDT,))
		conOut("WSFINA050" + " - Centro de Custo de Débito " + alltrim(cCTCUSTDT) + " Inexistente!!!" )
		SetSoapFault("WSFINA050",+ " Centro de Custo de Débito " + alltrim(cCTCUSTDT) + " Inexistente!!!")
		return .F.
	EndIf
	*/
lRet:=Pms050Loc(cTipo)
If lRet
		//CRIANDO CABECALHO
		AADD(aCabec,{"E2_FILIAL"	, cFFILIAL,					Nil})
		AADD(aCabec,{"E2_PREFIXO"	, cPREFIXO,					Nil})
		AADD(aCabec,{"E2_NUM"		, cNUM,						Nil})
		AADD(aCabec,{"E2_PARCELA"	, cPARCELA,					Nil})
		AADD(aCabec,{"E2_TIPO"		, cTIPO,					Nil})
		AADD(aCabec,{"E2_FORNECE"	, cFORNECE,					Nil})
		AADD(aCabec,{"E2_LOJA"		, cLOJA,					Nil})
		AADD(aCabec,{"E2_CCD"		, cCTCUSTDT,				 Nil})
		AADD(aCabec,{"E2_NATUREZ"	, cNATUREZ,					Nil})
		AADD(aCabec,{"E2_EMISSAO"	, CtoD(oCabe:cE2_EMISSAO),	Nil})
		AADD(aCabec,{"E2_VENCTO"	, CtoD(oCabe:cE2_VENCTO),	Nil})
		AADD(aCabec,{"E2_VENCREA"	, Datavalida( CtoD(oCabe:cE2_VENCTO) ),	Nil})
		AADD(aCabec,{"E2_VALOR"		, oCabe:nE2_VALOR,			Nil})
		AADD(aCabec,{"E2_VLCRUZ"	, oCabe:nE2_VALOR,			Nil})
		AADD(aCabec,{"E2_PROJPMS"   ,"1",						Nil})  
		AADD(aCabec,{"E2_ORIGEM"   , "WSFINA05",				Nil})  
	    
		If !Empty(oCabe:cAFR_PROJETO)
			aItPrjTmp := {}
			cTarefa := IIF(Empty(oCabe:cAFR_TAREFA ),oCabe:cAFR_PROJETO,oCabe:cAFR_TAREFA) 
			
			aadd( aItPrjTmp ,{"AFR_PROJET" 		, oCabe:cAFR_PROJETO		, Nil } )
			aadd( aItPrjTmp ,{"AFR_REVISA" 		, StrZero(1,TamSX3("AFR_REVISA")[1]) , Nil } )
			aadd( aItPrjTmp ,{"AFR_TAREFA" 		, cTarefa       		 	, Nil } )
			aadd( aItPrjTmp ,{"AFR_TIPOD" 		, "0004"				 	, Nil } )
			aadd( aItPrjTmp ,{"AFR_PREFIX" 		, cPREFIXO				 	, Nil } )
			aadd( aItPrjTmp ,{"AFR_NUM" 		, cNUM					 	, Nil } )
			aadd( aItPrjTmp ,{"AFR_PARCEL" 		, cPARCELA				 	, Nil } )
			aadd( aItPrjTmp ,{"AFR_TIPO" 		, cTIPO					 	, Nil } )
			aadd( aItPrjTmp ,{"AFR_FORNEC" 		, cFORNECE				 	, Nil } )
			aadd( aItPrjTmp ,{"AFR_LOJA" 		, cLOJA					 	, Nil } )
			aadd( aItPrjTmp ,{"AFR_VALOR1" 		, oCabe:nE2_VALOR		 	, Nil } )		
			aadd( aItPrjTmp ,{"AFR_DATA" 		, CtoD(oCabe:cE2_EMISSAO) 	, Nil } )	
			aadd( aItPrjTmp ,{"AFR_VENREA" 		, CtoD(oCabe:cE2_VENCTO) 	, Nil } )	
			aAdd(aItPrj ,aClone(aItPrjTmp))
		EndIf
	
		//Verificando se informou data de Emissão
		if Empty(CtoD(oCabe:cE2_EMISSAO))
	      conOut("WSFINA050" + " " + STR0013)//"Data de Emissão não informada."
			SetSoapFault("WSFINA050",STR0013)//"Data de Emissão não informada."
			return .F.
		endIf          
	
		//Verificando se informou vencto Real
		if Empty(CtoD(oCabe:cE2_VENCTO))
	      conOut("WSFINA050" + " " + STR0014)//"Data de Vencimento Real não informada."
			SetSoapFault("WSFINA050",STR0014)//"Data de Vencimento Real não informada."
			return .F.
		endIf
		
		//Verificando se informou vencto Real menor que Data de Emissão
		if CtoD(oCabe:cE2_VENCTO) < CtoD(oCabe:cE2_EMISSAO)
	      conOut("WSFINA050" + " " + STR0015)//"Data de Vencimento Real Menor que Data de Emissão."
			SetSoapFault("WSFINA050",STR0015)
			return .F.
		endIf
	
		//Verificando se informou Valor do titulo
		if Empty(oCabe:nE2_VALOR)
	      conOut("WSFINA050" + " " + STR0016 )//Valor não informado."
			SetSoapFault("WSFINA050",STR0016)
			return .F.
		endIf
	
		If cTIPO $ MVPAGANT
	    	//
	    	// carrega o banco/agencia/conta padrão do parametro MV_CXFIN
	    	//
			aBcoDefault := xCxFina()
	
			AADD(aCabec,{"AUTBANCO"	,aBcoDefault[1]	,Nil})
			AADD(aCabec,{"AUTAGENCIA"	,aBcoDefault[2]	,Nil})
			AADD(aCabec,{"AUTCONTA"	,aBcoDefault[3]	,Nil})
	
		EndIf
		
		// ponto de entrada inserido para controlar dados especificos do cliente
		If ExistBlock("PWSFI050")
			aRetPe := ExecBlock("PWSFI050",.F.,.F.,{aCabec,aItPrj})
			If ValType(aRetPe) == "A" .And. Len(aRetPe) == 2 .And.;
			 	ValType(aRetPe[1]) == "A" .And. ValType(aRetPe[2]) == "A"
				aCabec := aClone(aRetPe[1])
				aItPrj := aClone(aRetPe[2])
			EndIf
		EndIf
		
		conOut(STR0017 + "(" + TIME() + ")")//"EXECUTANDO FUNCAO DE GRAVACAO AUTOMATICA FINA050...
		
		lMsErroAuto := .F.
		MsExecAuto({|x,y| FINA050(x,,y) },aCabec,3)
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
			cErro:= STR0021 //"Verifique !, "       
			nFim:=10
			For nZ := 2 TO nFim
			   If ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) <> ""
	  				cErro+= ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) + " "
	  			Else            
	  				nZ:=10
				Endif
			Next nZ		
			SetSoapFault("WSFINA050",STR0021 + CRLF + MemoRead(NomeAutoLog()))
			return .F.
		Else
			conOut("FINA050" + " " + STR0022 + " " +  "(" + TIME() + ")")//" EXECUTADO!"
		EndIf
	
		::sRet:cE2_FILIAL	:= cFFILIAL
		::sRet:cE2_PREFIXO	:= cPREFIXO
		::sRet:cE2_NUM		:= cNUM
		::sRet:cE2_PARCELA	:= cPARCELA
		::sRet:cE2_TIPO		:= cTIPO
		::sRet:cE2_FORNECE	:= cFORNECE
		::sRet:cE2_LOJA		:= cLOJA
		::sRet:cE2_EMPRESA	:= cEmpOOO
	

	pmsWsCP("3" ,aItPrj )
	
	conOut(STR0023)//"FINALIZANDO..."
Endif
RestArea(aArea)		

Return lRet

/*--------------------------------------------------------------------------------------
WSMethod	Exclui
Autor		Edvin Markstein Zimmermann
Data		20/03/2010
Descricao	Exclui um Titulo a Pagar
Retorno		.t.
--------------------------------------------------------------------------------------*/
WSMethod Exclui WSReceive sSE2Exclui WSSEND cRet WSSERVICE WSFINA050

	Local aCabec		:= {}
    Local aItPrjTmp 	:= {}
    Local aItPrj		:= {}
	Local nZ			:= 0
	Local cErro			:= ""
	Local cFFILIAL		:= ""
	Local cPREFIXO		:= ""
	Local cNUM			:= ""
	Local cPARCELA		:= ""
	Local cTIPO			:= ""
	Local cFORNECE		:= ""
	Local cLOJA			:= ""
	Local lREt			:=.T.
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
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicionamento da Empresa/Filial                          ³
	//³                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    If Empty(::sSE2Exclui:cE2_EMPRESA) .Or. Empty(::sSE2Exclui:cE2_FILIAL)
		SetSoapFault( "WSFINA050", STR0024 + STR0005)//Titulo contas a pagar nao excluido.Codigo da Empresa/Filial nao informado (vazio).
		return .F.
	Endif    

	If Type("cFilAnt") =="U" //retirou o preparein do ini
		If FindFunction("PmsW40Fil")
			cFilOOO := (::sSE2Exclui:cE2_FILIAL) 
			cEmpOOO :=	(::sSE2Exclui:cE2_EMPRESA) 
			lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
		Else //está sem o preparein, e nao vai conseguir setar a filial.
			SetSoapFault( "WSFINA050",STR0030)//Não foi possível completar esta ação. É necessária uma atualização dos WebServices de integração TOP x Protheus. Entre com contato com o Suporte Totvs."
			return .F.
		Endif
	Else
		cFilOOO := Padr( Alltrim(::sSE2Exclui:cE2_FILIAL)  ,Len(cFilAnt) )
		cEmpOOO := Padr( Alltrim(::sSE2Exclui:cE2_EMPRESA) ,Len(cEmpAnt) )
	
		lEMPFil :=PMSSM0Env(cEmpOOO,cFilOOO)
	Endif

    If !lEMPFil
		SetSoapFault( "WSFINA050",STR0024+ STR0006 )//Titulo contas a pagar nao excluido.Codigo da Empresa/Filial inexistente ou nao autorizada
		return .F.
    Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento de variavel apos ter definido o ambiente       ³
	//³                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArea	:= GetArea()
	nColigada:=GetNewPar('MV_RMCOLIG',0)
	lTopxTin:=Iif(FindFunction('IntTopTin'),IntTopTin(nColigada),.F.)
	// **********************
	// *******@@@@@**********
	// ******@@**@@@*********
	// **********@@**********
	// *********@@@**********
	// ********@@@***********
	// *******@@@@@@*********
	// **********************

	cFFILIAL	:= xFilial( "SE2") // padR(::sSE2Exclui:cE2_FILIAL		,TamSX3("E2_FILIAL")[1])
	cPREFIXO	:= padR(::sSE2Exclui:cE2_PREFIXO	,TamSX3("E2_PREFIXO")[1])
	cNUM		:= padR(::sSE2Exclui:cE2_NUM		,TamSX3("E2_NUM")[1])
	cPARCELA	:= padR(::sSE2Exclui:cE2_PARCELA	,TamSX3("E2_PARCELA")[1])
	cTIPO		:= padR(::sSE2Exclui:cE2_TIPO		,TamSX3("E2_TIPO")[1])
	If lTopxTin // indica que o cliente usa integração do Tin e TOP ao mesmo tempo
		cFORNECE:=IsTopxTin("SA2",(::sSE2Exclui:cE2_FORNECE))
		cLOJA:=SubStr(cFORNECE,TamSX3("E2_FORNECE")[1]+1,TamSX3("E2_LOJA")[1])
		cFORNECE:=SubStr(cFORNECE,1,TamSX3("E2_FORNECE")[1])
	Else
		cFORNECE	:= padR(::sSE2Exclui:cE2_FORNECE	,TamSX3("E2_FORNECE")[1])
		cLOJA		:= padR(::sSE2Exclui:cE2_LOJA		,TamSX3("E2_LOJA")[1])
	Endif
    dbSelectArea("SE2")
	dbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
    If !DbSeek( cFFILIAL + cPREFIXO + cNUM + cPARCELA + cTIPO + cFORNECE + cLOJA )
		SetSoapFault("WSFINA050",STR0025)//"Título de Contas a Pagar não encontrado."
		return .F.
	endIf	
lREt:=Pms050Loc(cTipo)
If lRet
		//CRIANDO CABECALHO
		AADD(aCabec,{"E2_FILIAL"	, 	cFFILIAL	, Nil})
		AADD(aCabec,{"E2_PREFIXO"	,	cPREFIXO	, Nil})
		AADD(aCabec,{"E2_NUM"		,	cNUM		, Nil})
		AADD(aCabec,{"E2_PARCELA"	, 	cPARCELA	, Nil})
		AADD(aCabec,{"E2_TIPO"		,	cTIPO		, Nil})
		AADD(aCabec,{"E2_FORNECE"	,	cFORNECE	, Nil})
		AADD(aCabec,{"E2_LOJA"		,	cLOJA		, Nil})
	                 
		aItPrjTmp := {}
		aadd( aItPrjTmp ,{"AFR_PREFIX" 		, cPREFIXO				 	, Nil } )
		aadd( aItPrjTmp ,{"AFR_NUM" 		, cNUM					 	, Nil } )
		aadd( aItPrjTmp ,{"AFR_PARCEL" 		, cPARCELA				 	, Nil } )
		aadd( aItPrjTmp ,{"AFR_TIPO" 		, cTIPO					 	, Nil } )
		aadd( aItPrjTmp ,{"AFR_FORNEC" 		, cFORNECE				 	, Nil } )
		aadd( aItPrjTmp ,{"AFR_LOJA" 		, cLOJA					 	, Nil } )
		
		aAdd(aItPrj ,aClone(aItPrjTmp))
	
		conOut(STR0026 + "(" + TIME() + ")")//"EXECUTANDO FUNCAO DE EXCLUSAO AUTOMATICA FINA050...
	
		lMsErroAuto := .F.
		MsExecAuto({|x,y| FINA050(x,,y) },aCabec,5)
	
		//VERIFICANDO SE HOUVE ERRO AO FECHAR O PEDIDO
		If lMsErroAuto
	
			conOut(STR0018)//" *** ATENCAO *** "
			conOut( STR0019 + DtoC(Date()) + " - " + time())//"     ERRO AO EFETUAR SOLICITACAO - DATA: "
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
			cErro:= STR0021 //"Verifique !, "       
			nFim:=10
			For nZ := 2 TO nFim
			   If ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) <> ""
	  				cErro+= ALLTRIM(MemoLine(MemoRead(NomeAutoLog()),,nZ)) + " "
	  			Else            
	  				nZ:=10
				Endif
			Next nZ
			SetSoapFault("WSFINA050",STR0021 + CRLF + MemoRead(NomeAutoLog()) )
			return .F.
		Else
			conOut("FINA050" + " " + STR0022 + "(" + TIME() + ")")//" EXECUTADO!"
		EndIf
	
		// Exclui a associacao com o projeto
		pmsWsCP("5" ,aItPrj )
		
			::cRet := STR0027 //"Titulo a pagar excluido com sucesso."
		  	conOut("FINA050" + " " +  STR0027 + "(" + TIME() + ")")//"Titulo a pagar excluido com sucesso."
		
Endif	
RestArea(aArea)		

Return lRet



Static Function GetNumSE2(cPrefixo ,cFornece ,cLoja)

Local cNumero := ""
Local cMay := ""
Local cRetorno  := ""
Local cQuery    := ""
Local cAliasSE2 := "" 
 
#IFDEF TOP
	cAliasSE2 := "AliasSE2"
	cQuery    := "SELECT MAX(E2_NUM) AS NUMERO "
	cQuery    += "FROM "+RetSqlName("SE2")+" "
	cQuery    += "WHERE E2_FILIAL ='"+xFilial("SE2")+"' AND "
	cQuery    += "E2_PREFIXO ='"+cPrefixo+"' AND "
	cQuery    += "E2_FORNECE ='"+cFornece+"' AND "
	cQuery    += "E2_LOJA ='"+cLoja      +"' AND "
	cQuery    += "D_E_L_E_T_=' ' "
	cQuery    := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2,.T.,.T.)
        
	If (cAliasSE2)->(!Eof())
		cNumero := IIF(Empty((cAliasSE2)->NUMERO) ,STRZERO(1 ,Len(SE2->E2_NUM)) ,Soma1((cAliasSE2)->NUMERO))
	EndIf
	
	If Empty(cNumero)
		cNumero := STRZERO(1 ,Len(SE2->E2_NUM))
	EndIf
	
	(cAliasSE2)->(dbCloseArea())
	dbSelectArea("SE2")
	
	cMay := "SE2"+xFilial("SE2")+cNumero+cFornece+cLoja
	While !MayIUseCode(cMay)
		cNumero := Soma1(cNumero)
		cMay := "SE2"+xFilial("SE2")+cNumero+cFornece+cLoja
	EndDo
#ENDIF
cRetorno := cNumero                                         


Return(cRetorno)

User Function NOTHING3a; Return  // "dummy" function - Internal Use


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pms050Loc ºAutor  ³Jandir Deodato      º Data ³  30/0812    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Nas localizações nao sera permitido realizar alteracoes     º±±
±±º          ³nos pagamentos antecipados no TOP                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PMS050Loc(cTipo)

Local lREt:=.T.
If (cTipo $ MVPAGANT .And. cPaisLoc <> "BRA")//para localizacoes so e permitido a geracao de Pas no Protheus
	 SetSoapFault("WSFINA050",STR0028+" "+ alltrim(cTipo)+" " + STR0029)//"Para localizações só é permitido a manipulação de"  "no Protheus." 
	 lRet:=.F.
Endif

Return lRet