#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "LOJI057A.CH"

Static cMarca		:= ""
Static cInterId		:= ""	//Codigo externo utilizada no De/Para
Static cIdMsg		:= "CASHIERCONFERENCE" //ID da rotina
Static aSang		:= {}
//--------------------------------------------------------
/*/{Protheus.doc} LOJI057A
Funcao de integracao com o adapter EAI para recebimento Conferência de Caixa
 utilizando o conceito de mensagem unica. 
@type       function
@param		cXml          Variável com conteúdo XML para envio/recebimento.
@param		nTypeTrans    Tipo de transação. (Envio/Recebimento)
@param		cTypeMsg	  Tipo de mensagem. (Business Type, WhoIs, etc)
@param		cVersion      Versão
@author  	rafael.pessoa
@since   	13/10/2017
@version 	P12
@return		lRet - (boolean)  Indica o resultado da execução da função
			cXmlRet - (caracter) Mensagem XML para envio
			Nome do Adapter EAI
/*/
//--------------------------------------------------------
Function LOJI057A(cXml, nTypeTrans, cTypeMsg, cVersion)

Local cError	:= ""  //Erros no XML
Local cWarning	:= ""  //Avisos no XML
Local cVersao	:= ""  //Versao da Mensagem
Local cXmlRet	:= ""  //Mensagem de retorno da integracao
Local lRet		:= .T. //Retorno da integracao
Local oXmlMsg 	:= Nil //Objeto para parser do xml da msg

Default cXml     		:= ""
Default nTypeTrans     	:= 0
Default cTypeMsg   		:= ""
Default cVersion     	:= ""

If cTypeMsg == EAI_MESSAGE_WHOIS
	cXMLRet := '2.000'
Else

	If !Empty(cXml)
		oXmlMsg := xmlParser(cXml, "_", @cError, @cWarning) //Objeto XML
	EndIf	 
	
	//Validacoes de erro no XML
	If Valtype(oXmlMsg) == "O" .And. Empty(cError) .And. Empty(cWarning)
		//Validacao de versao
		If XmlChildEx(oXmlMsg:_TOTVSMessage:_MessageInformation, "_VERSION") <> Nil .And.; 
			          !Empty(oXmlMsg:_TOTVSMessage:_MessageInformation:_version:Text )
			
			cVersao := Separa(oXmlMsg:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
			
			//Valida se versao implementada
			If cVersao $ "2"																													
				v2000(  oXmlMsg		, cTypeMsg, @lRet, @cXmlRet, ;
						nTypeTrans	)
			Else
				lRet 	 := .F.
				cXmlRet := STR0001 //#"A versao da mensagem informada não foi implementada!"	
			EndIf	
						
		Else
			lRet 	 := .F.
			cXmlRet := STR0002 //#"Versao da mensagem não informada!"	
		EndIf
	Else
		lRet 	 := .F.
		cXmlRet := STR0003 //#"Erro no parser!" 
	EndIf

EndIf	

Return {lRet, cXmlRet, cIdMsg}


//--------------------------------------------------------
/*/{Protheus.doc} v2000
Rotina para processar a mensagem tipo RECEIVE e BUSINESS
Efetua a gravacao da Conferência de caixa
@type       function
@param   	oXmlMsg		Objeto contendo a mensagem (XML)
@param   	cTypeMsg    Tipo da mensagem 
@param   	lRet  		Indica o resultado da execução da função
@param   	cXmlRet  	Mensagem Xml para envio
@param   	nTypeTrans	Tipo da transação
@author  	rafael.pessoa
@since   	13/10/2017
@version 	P12
@return		Nil
/*/
//--------------------------------------------------------
Static Function v2000(	oXmlMsg		, cTypeMsg, lRet, cXmlRet, ;
						nTypeTrans	)

Local aArea	 			:= GetArea() 			//Armazena areas
Local oXmlContent		:= Nil 					//Objeto Xml com o conteudo da BusinessContent apenas

Default oXmlMsg     	:= Nil
Default cTypeMsg     	:= ""
Default lRet    		:= .F.
Default cXmlRet     	:= ""
Default nTypeTrans     	:= 0

If nTypeTrans == TRANS_RECEIVE
	If cTypeMsg == EAI_MESSAGE_BUSINESS
		lRet := LojI057Rec(oXmlMsg, @cXmlRet)
	ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE							
		cXmlRet := "<TAGX>RECEPCAO RESPONSE MESSAGE</TAGX>"																
	ElseIf cTypeMsg == EAI_MESSAGE_WHOIS						 
		cXmlRet := "2.000"
	EndIf	
EndIf	

RestArea(aArea)

Return Nil


//--------------------------------------------------------
/*/{Protheus.doc} LojI057Rec
Rotina para Efetuar a gravacao da Conferência de caixa
@type       function
@param   	oXmlMsg		Objeto contendo a mensagem (XML)
@param   	cXmlRet  	Mensagem Xml para envio
@author  	rafael.pessoa
@since   	13/10/2017
@version 	P12
@return		lRet 			Retorno lógico
/*/
//--------------------------------------------------------
Static Function LojI057Rec( oXmlMsg , cXmlRet )

Local cEvent		:= ""	// Armazena o evento
Local lRet			:= .T.  // Retorno
Local cValInt		:= ""	// InternalId

Default oXmlMsg     := Nil
Default cXmlRet     := ""

If XmlChildEx(oXmlMsg:_TOTVSMessage:_MessageInformation:_Product, "_NAME") <> Nil .And.; //Verifica se possui Marca	
	!Empty(oXmlMsg:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
	cMarca := oXmlMsg:_TotvsMessage:_MessageInformation:_Product:_Name:Text //Armazena marca
Else	
	lRet    := .F.
	cXmlRet := STR0004 //"O campo MARCA é obrigatorio"
EndIf	

If XmlChildEx(oXmlMsg:_TOTVSMessage:_BusinessMessage:_BusinessEvent, "_EVENT") <> Nil .And.; //Verifica se tem Evento         	
	!Empty(oXmlMsg:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
	cEvent := Upper(oXmlMsg:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) //Armazena evento
	lRet		:= .T.
Else
	lRet    := .F.
	cXmlRet := STR0005 //#"O evento é obrigatorio"
EndIf

If lRet
	     	
	oXmlContent := oXmlMsg:_TOTVSMessage:_BusinessMessage:_BusinessContent //Efetua a carga do objeto InternalID
	If XmlChildEx(oXmlContent, "_INTERNALID") <> Nil .And. !Empty(oXmlContent:_InternalId:Text) 	
		cInterId := oXmlContent:_InternalId:Text
	Else
		lRet    := .F.
		cXmlRet := STR0028 //#"O código do InternalId é obrigatório!"    	
	EndIf
	
	//Verifica qual o ID da mensagem
	If lRet
		If XmlChildEx(	oXmlMsg:_TOTVSMessage:_MessageInformation, "_TRANSACTION") <> Nil .AND.;
		 				!Empty(oXmlMsg:_TOTVSMessage:_MessageInformation:_Transaction:Text)
			cIdMsg := AllTrim(Upper(oXmlMsg:_TOTVSMessage:_MessageInformation:_TRANSACTION:Text))
		Else
			lRet    := .F.
			cXmlRet := STR0029 //#"O TRANSACTION é obrigatório!"    
		EndIf
	EndIf
	
	//Se o evento Upsert
	If lRet	
		If cEvent == "UPSERT"
			lRet := LojI057Upd(oXmlContent,@cXMLRet,@cValInt)
		ElseIf cEvent == "DELETE" //Se o evento Delete
			lRet := LojI057Del(oXmlContent,@cXMLRet,@cValInt)
		EndIf
	EndIf	
	
	//Valida se continua e pega o retorno
	If lRet
		cXMLRet := LojI057Ret(cValInt)
	EndIf																																				
EndIf

Return lRet


//--------------------------------------------------------
/*/{Protheus.doc} LojI057Upd
Retorno final do XML para a mensagem unica
@type       function
@param   	oXmlContent		Objeto contendo a mensagem (XML)
@param   	cXmlRet  		Mensagem Xml para retorno
@param   	cValInt  		Integração retorno de/para
@author  	rafael.pessoa
@since   	13/10/2017
@version 	P12
@return		lRet 			Retorno lógico
/*/
//--------------------------------------------------------
Static Function LojI057Upd(oXmlContent,cXMLRet,cValInt)

Local lRet			:= .T.
Local aAux			:= {}	//Array auxiliar no De-Para
Local aFechCx		:= {}	//Retorno da integração
Local aPays  		:= {}	//Array de pagamentos

Default oXmlContent    	:= Nil
Default cXMLRet     	:= ""
Default cValInt     	:= ""

aAux := IntConfInt(cInterId,  cMarca, /*Versao*/, @cValInt) 	//Tratamento utilizando a tabela XXF com um De/Para de codigos

If aAux[1] //fechamento ja existe?
	//Nao realiza Alteracao pois o fechamento nao pode ser alterado
	LjGrvLog("LOJI057", "Fechamento de caixa já foi recebido. Retorna OK.")	
Else	
	//Extrai todos os campos do XML
	aAux := LojI057Adm(oXmlContent,@cXMLRet,aPays )
	If !Empty(cXMLRet)
		lRet := .F. // Problemas de validacao
	Else
		aFechCx	:= LojI057Atu(aAux, 0 ,aPays)	// Inclui ou altera o registro na tabela
		lRet	:= aFechCx[1]
		cXMLRet := aFechCx[2]
		cValInt := IntConfExt(	/*Empresa*/				, /*Filial*/		, /*SLW->LW_PDV*/aAux[2][2]	, /*SLW->LW_OPERADO*/aAux[3][2] ,;
								/*SLW->LW_DTABERT*/DTOS(aAux[4][2])	, /*SLW->LW_ESTACAO*/aAux[1][2]	, /*SLW->LW_NUMMOV*/aAux[8][2], /*Versão*/	)[2]
	
		If lRet
			//Grava na Tabela XXF (de/para)
			lRet := CFGA070Mnt(cMarca, "SLW", "LW_DTABERT", cInterId, cValInt)
			If !lRet
				cXMLRet := STR0005 //"Erro na integração"
			EndIf
		EndIf
		
	EndIf
	
EndIf	

Return lRet


//--------------------------------------------------------
/*/{Protheus.doc} LojI057Del
Retorno final do XML para a mensagem unica
@type       function
@param   	oXmlContent		Objeto contendo a mensagem (XML)
@param   	cXmlRet  		Mensagem Xml para retorno
@param   	cValInt  		Integração retorno de/para
@author  	rafael.pessoa
@since   	13/10/2017
@version 	P12
@return		lRet 			Retorno lógico
/*/
//--------------------------------------------------------
Static Function LojI057Del(oXmlContent,cXMLRet,cValInt)

Local lRet			:= .T.
Local aAux			:= {}	//Array auxiliar no De-Para
Local aFechCx		:= {}	//Retorno da integração
Local aPays    		:= {}	//Array de Taxas

Default oXmlContent    	:= Nil
Default cXMLRet     	:= ""
Default cValInt     	:= ""
	
aAux := IntConfInt(cInterId,  cMarca, /*Versao*/) 	//Tratamento utilizando a tabela XXF com um De/Para de codigos

// Extrai todos os campos do XML
aAux := LojI057Adm(oXmlContent,@cXMLRet,aPays)
If Empty(aAux[1][2])
	lRet := .F. // Problemas de validacao
Else
	aFechCx	:= LojI057Atu(aAux, 5,aPays)	// Exclui o registro na tabela
	lRet	:= aFechCx[1]
	cXMLRet := aFechCx[2]
	
	CONOUT("SLW->RECNO "+STRZERO(SLW->(RECNO()),4))
	
	cValInt := IntConfExt(	/*Empresa*/				, /*Filial*/		, SLW->LW_PDV	, SLW->LW_OPERADO ,;
							DTOS(SLW->LW_DTABERT)	, SLW->LW_ESTACAO	, SLW->LW_NUMMOV, /*Versão*/	)[2]

	If lRet
		//Grava na Tabela XXF (de/para)
		lRet := CFGA070Mnt(cMarca, "SLW", "LW_DTABERT", cInterId, cValInt)
		If !lRet
			cXMLRet := STR0005 //"Erro na integração"
		EndIf
	EndIf
EndIf

Return lRet


//--------------------------------------------------------
/*/{Protheus.doc} LojI057Ret
Retorno final do XML para a mensagem unica
@type       function
@param   	cValInt  		Integração retorno de/para
@author  	rafael.pessoa
@since   	13/10/2017
@version 	P12
@return		cXmlRet  		Mensagem final Xml para retorno
/*/
//--------------------------------------------------------
Static Function LojI057Ret(cValInt)

Local cXMLRet := ""

Default cValInt  := ""

cXMLRet := "<ListOfInternalId>"
cXMLRet +=    "<InternalId>"
cXMLRet +=       "<Name>CashierConferenceInternalId</Name>"
cXMLRet +=       "<Origin>"+cInterId+ "</Origin>"
cXMLRet +=       "<Destination>"+cValInt+"</Destination>"
cXMLRet +=    "</InternalId>"
cXMLRet += "</ListOfInternalId>" 

Return cXMLRet


//--------------------------------------------------------
/*/{Protheus.doc} IntConfInt
Recebe um InternalID e retorna a Conferência de Caixa Protheus
@type       function
@param   	cInternalID		InternalID recebido na mensagem
@param   	cRefer    		Produto que enviou a mensagem 
@param   	cVersao  		Versão da mensagem única (Default 2.000)
@param   	cValInt  		InternalId
@author  	rafael.pessoa
@since   	13/10/2017
@version 	P12
@return  	Array contendo no primeiro parâmetro uma variável logica
		  	indicando se o registro foi encontrado no de/para
		 	No segundo parâmetro uma variável array com empresa, filial
		  	e a Adm. Financeira.
/*/
//--------------------------------------------------------
Function IntConfInt(cInternalID, cRefer, cVersao, cValInt)
   
Local aResult  := {}
Local aTemp    := {}
Local cTemp    := ""
Local cAlias   := "SLW"
Local cField   := "LW_DTABERT"

Default cInternalID  	:= ""
Default cRefer  		:= ""
Default cVersao  		:= "2.000"
Default cValInt  		:= ""

cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)
   
If Empty(cTemp)
	aAdd(aResult, .F.)
	aAdd(aResult, STR0008 + " " + AllTrim(cInternalID) + " " + STR0009) //"Conferência de Caixa "  "não encontrada no de/para!"
Else
	If cVersao == "2.000"
		aAdd(aResult, .T.)
       aTemp := Separa(cTemp, "|")
       aAdd(aResult, aTemp)	  
       cValInt := AllTrim(cTemp)
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, STR0009 + Chr(10) + STR0010 + "2.000") //#"Versão não suportada." ##"As versoes suportadas sao:"        
   EndIf
EndIf
  
Return aResult


//--------------------------------------------------------
/*/{Protheus.doc} IntConfExt
Monta o InternalID da Conferência de Caixa de acordo com codigo passado
@type       function
@param   	cEmpresa	Codigo da empresa (Default cEmpAnt)
@param   	cFil    	Codigo da Filial (Default xFilial) 
@param   	cPDV  	    Codigo PDV
@param   	cOperado  	Codigo do caixa
@param   	cDtAbert  	Data Abertura
@param   	cEstacao  	Codigo da estacao
@param   	cNummov  	Numero do movimento do caixa
@param   	cVersao  	Versao da Mensagem
@author  	rafael.pessoa
@since   	13/10/2017
@version 	P12
@return  	Array contendo no primeiro parâmetro uma variável logica
		  	indicando se o registro foi encontrado
		  	No segundo parâmetro uma variável string com o InternalID montado
/*/
//--------------------------------------------------------
Function IntConfExt(cEmpresa, cFil		, cPDV		, cOperado,;
					cDtAbert, cEstacao	, cNummov	, cVersao)

Local aResult := {}

Default cEmpresa 	:= cEmpAnt
Default cFil     	:= xFilial("SLW")
Default cPDV		:= ""
Default cOperado	:= ""
Default cDtAbert	:= ""
Default cEstacao	:= ""
Default cNummov		:= ""
Default cVersao		:= "2.000"

If cVersao == "2.000"
	aAdd(aResult, .T.)
	aAdd(aResult, cEmpresa + "|" + RTrim(cFil) + "|"  + RTrim(cPDV) + "|"  + RTrim(cOperado) + "|"  + RTrim(cDtAbert) + "|"  + RTrim(cEstacao) + "|"  + RTrim(cNummov) )
Else
	aAdd(aResult, .F.)
	aAdd(aResult, STR0009 + Chr(10) + STR0010 + "2.000") //#"Versão não suportada." ##"As versões suportadas são:" 
EndIf
   
Return aResult


//--------------------------------------------------------
/*/{Protheus.doc} LojI057Adm
Retorna os campos do XML da AdmFinanceira
@type       function
@param   	oXmlContent	Objeto contendo a mensagem (XML)
@param   	cXMLRet    	Xml de retorno
@param   	aPays  		Array pagamentos
@param   	cVersao  	Versao da Mensagem
@author  	rafael.pessoa
@since   	13/10/2017
@version 	P12
@return  	aFechCx 		Todas os campos das mensagens
/*/
//--------------------------------------------------------
Static Function LojI057Adm(oXmlContent,cXMLRet , aPays)

Local aFechCx	 	:= {}
Local nI   			:= 0
Local lRet	 		:= .T.
Local aAux 			:= {} 
Local cOperador 	:= ""
Local cPagamento 	:= ""
Local aPagamento 	:= {}
Local aCaixa		:= {}
Local cEstacao   	:= ""
Local aEstacao		:= {}
Local nTamFormPg	:= TamSx3("LT_FORMPG")[1]
Local nTamAdmFin	:= TamSx3("LT_ADMIFIN")[1]

Default oXmlContent	:= Nil
Default cXMLRet		:= ""
Default aPays		:= {}

Aadd(aFechCx,{"LW_ESTACAO"		,Space( TamSX3("LW_ESTACAO")[1] )	, NIl})//01
Aadd(aFechCx,{"LW_PDV"			,Space( TamSX3("LW_PDV")[1] )		, NIl})//02
Aadd(aFechCx,{"LW_OPERADO"		,Space( TamSX3("LW_OPERADO")[1] )	, NIl})//03
Aadd(aFechCx,{"LW_DTABERT"		,dDataBase	, NIl})//04
Aadd(aFechCx,{"LW_HRABERT"		,""			, NIl})//05
Aadd(aFechCx,{"LW_DTFECHA"		,dDataBase	, NIl})//06
Aadd(aFechCx,{"LW_HRFECHA"		,""			, NIl})//07
Aadd(aFechCx,{"LW_NUMMOV"		,Space( TamSX3("LW_NUMMOV")[1] )	, NIl})//08
Aadd(aFechCx,{"LW_NUMINI"		,StrZero(1,TamSX3("LW_NUMINI")[1]), NIl})//09
Aadd(aFechCx,{"LW_NUMFIM"		,StrZero(1,TamSX3("LW_NUMFIM")[1]), NIl})//10
Aadd(aFechCx,{"LW_SERIE"		,""			, NIl})//11
Aadd(aFechCx,{"LW_TIPFECH"		,"2"		, NIl})//12
Aadd(aFechCx,{"LW_CONFERE"		,"2"		, NIl})//13
Aadd(aFechCx,{"LW_ORIGEM"		,"LOJ"		, NIl})//14

aSang := {}

If XmlChildEx(oXmlContent, "_STATIONSALEPOINTINTERNALID") <> Nil .And. !Empty(oXmlContent:_STATIONSALEPOINTINTERNALID:Text) 
	
	cEstacao := AllTrim(oXmlContent:_STATIONSALEPOINTINTERNALID:Text)
		
	//Tratamento utilizando a tabela XXF com um De/Para de codigos
	aEstacao := Separa(CFGA070Int(cMarca, "SLG", "LG_CODIGO", cEstacao),"|")

	If Len(aEstacao) >= 3
		cEstacao := AllTrim(aEstacao[3])
		DbSelectArea("SLG")
		SLG->(dbSetOrder(1))		
		If SLG->(dbSeek(xFilial("SLG") + cEstacao))
			aFechCx[1][2] := PADR(cEstacao,TamSx3("LW_ESTACAO")[1]) 
		Else
			lRet 	 	:= .F.
			cXmlRet		:= STR0011 + " " + cEstacao + " " + STR0012 + " " + STR0013 //#"Estação:" ##"nao integrado ao Protheus, verificar integracao de operador " verificar se o operador esta cadastrado na filial destino correta."
		EndIf
	Else
		lRet 	 := .F.
		cXmlRet  := STR0011 + " " + cEstacao + STR0014 + CFGA070Int(cMarca, "SLG", "LG_CODIGO", cEstacao) + ". " + STR0013  //#"Estação:" ##"nao encontrado no De/Para " " verificar se o operador esta cadastrado na filial destino correta."
	EndIf
	
ElseIf XmlChildEx(oXmlContent, "_STATIONCODE") <> Nil .And. !Empty(oXmlContent:_STATIONCODE:Text) 
	aFechCx[1][2] := PADR(AllTrim(oXmlContent:_STATIONCODE:Text),TamSx3("LW_ESTACAO")[1]) 
Else	
	lRet	 := .F.
	cXmlRet := STR0015 //"Estação não informada"
EndIf

If lRet //Busca informações da estacao
	DbSelectArea("SLG")
	DbSetOrder(1) //LG_FILIAL+LG_CODIGO
	If DbSeek( xFilial("SLG") + aFechCx[1][2]  )
		aFechCx[11][2]	:= SLG->LG_SERIE
		aFechCx[2][2]   := SLG->LG_PDV
		
		If Empty(SLG->LG_PDV)//Valida PDV
			lRet	 := .F.
			cXmlRet  := STR0037 + xFilial("SLG") + " | " + STR0011 + aFechCx[1][2] //"O numero do PDV(LG_PDV) não foi encontrado na estação informada. Filial: " ### "Estação"
		EndIf
		
	Else
		lRet	 := .F.
		cXmlRet  := STR0038 + xFilial("SLG") + " | " + STR0011 + aFechCx[1][2] //"Estação informada não foi encontrada. Filial : " ### "Estação"
	EndIf

EndIf


If XmlChildEx(oXmlContent, "_CASHIERCODEINTERNALID") <> Nil .And. !Empty(oXmlContent:_CASHIERCODEINTERNALID:Text) 
	cOperador := AllTrim(oXmlContent:_CASHIERCODEINTERNALID:Text)
		
	//Tratamento utilizando a tabela XXF com um De/Para de codigos
	aCaixa := Separa(CFGA070Int(cMarca, "SLF", "LF_COD", cOperador),"|")

	If Len(aCaixa) >= 3
		cOperador := AllTrim(aCaixa[3])
		DbSelectArea("SLF")
		SLF->(dbSetOrder(1))		
		If SLF->(dbSeek(xFilial("SLF") + cOperador))
			aFechCx[3][2] := PADR(cOperador,TamSx3("LW_OPERADO")[1]) 
		Else
			lRet 	 := .F.
			cXmlRet := STR0016 + " " + cOperador + " " + STR0012 + " " + STR0013 //#""Operador/Caixa:" ##"nao integrado ao Protheus, verificar integracao de operador " verificar se o operador esta cadastrado na filial destino correta."
		EndIf
	Else
		lRet 	 := .F.
		cXmlRet := STR0016 + " " + cOperador + STR0014 + CFGA070Int(cMarca, "SLF", "LF_COD", cOperador) + ". " + STR0013  //#"Operador/Caixa:" ##"nao encontrado no De/Para " " verificar se o operador esta cadastrado na filial destino correta."
	EndIf
		
ElseIf XmlChildEx(oXmlContent, "_CASHIERCODE") <> Nil .And. !Empty(oXmlContent:_CASHIERCODE:Text) 
	aFechCx[3][2] := PADR(AllTrim(oXmlContent:_CASHIERCODE:Text),TamSx3("LW_OPERADO")[1]) 
Else	
	lRet	 := .F.
	cXmlRet := STR0017 //"Codigo do caixa não informado"
EndIf

If XmlChildEx(oXmlContent, "_OPENDATETIME") <> Nil .And. !Empty(oXmlContent:_OPENDATETIME:Text) 
	//Data
	aFechCx[4][2] := Ctod( SubStr( oXmlContent:_OPENDATETIME:Text, 9, 2 ) + '/' + ;
				        SubStr( oXmlContent:_OPENDATETIME:Text, 6, 2 ) + '/' + ;
				        SubStr( oXmlContent:_OPENDATETIME:Text, 1, 4 ) ) 

	//Hora
	aFechCx[5][2] := SubStr( oXmlContent:_OPENDATETIME:Text, 12, 2 ) + ':' + ;
				  SubStr( oXmlContent:_OPENDATETIME:Text, 15, 2 )  				        
Else	
	lRet	 := .F.
	cXmlRet := STR0018 //"Data e hora de abertura não informado"
EndIf

If XmlChildEx(oXmlContent, "_CLOSEDATETIME") <> Nil .And. !Empty(oXmlContent:_CLOSEDATETIME:Text) 
	//Data
	aFechCx[6][2] := Ctod( SubStr( oXmlContent:_CLOSEDATETIME:Text, 9, 2 ) + '/' + ;
			        	SubStr( oXmlContent:_CLOSEDATETIME:Text, 6, 2 ) + '/' + ;
			        	SubStr( oXmlContent:_CLOSEDATETIME:Text, 1, 4 ) ) 
	//Hora
	aFechCx[7][2] := SubStr( oXmlContent:_CLOSEDATETIME:Text, 12, 2 ) + ':' + ;
				  SubStr( oXmlContent:_CLOSEDATETIME:Text, 15, 2 ) 	
Else	
	lRet	 := .F.
	cXmlRet := STR0019 //"Data e hora de fechamento não informado"
EndIf

If XmlChildEx(oXmlContent, "_MOVEMENTNUMBER") <> Nil .And. !Empty(oXmlContent:_MOVEMENTNUMBER:Text) 
	aFechCx[8][2] := PADR(AllTrim(oXmlContent:_MOVEMENTNUMBER:Text),TamSx3("LW_NUMMOV")[1])
Else	
	lRet	 := .F.
	cXmlRet := STR0020 //"Numero da movimentação não informado"
EndIf

If XmlChildEx(oXmlContent, "_SALESTARTNUMBER") <> Nil .And. !Empty(oXmlContent:_SALESTARTNUMBER:Text) 
	aFechCx[9][2] := AllTrim(oXmlContent:_SALESTARTNUMBER:Text)
EndIf

If XmlChildEx(oXmlContent, "_SALEENDNUMBER") <> Nil .And. !Empty(oXmlContent:_SALEENDNUMBER:Text) 
	aFechCx[10][2] := AllTrim(oXmlContent:_SALEENDNUMBER:Text)
EndIf

//Preenchimento da lista de pagamentos
If XmlChildEx(oXmlContent, "_LISTOFPAYMENTS") <> Nil .And. XmlChildEx(oXmlContent:_LISTOFPAYMENTS, "_PAYMENT") <> Nil

	//Monta Array com pagamentos	            					
	If ValType(oXmlContent:_LISTOFPAYMENTS:_PAYMENT) <> "A"
		XmlNode2Arr(oXmlContent:_LISTOFPAYMENTS:_PAYMENT, "_PAYMENT")
	EndIf

	If  Len(oXmlContent:_LISTOFPAYMENTS:_PAYMENT) > 0 
		For nI:=1 To Len(oXmlContent:_LISTOFPAYMENTS:_PAYMENT)
			
			If XmlChildEx(OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI], "_PAYMENTMETHODCODEINTERNALID") <> Nil .And. OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI]:_PAYMENTMETHODCODEINTERNALID <> Nil .And. ;
				!Empty(AllTrim(OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI]:_PAYMENTMETHODCODEINTERNALID:TEXT))
				
				aPagamento := Separa(CFGA070Int(cMarca, "SX5", "X5_CHAVE", OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI]:_PAYMENTMETHODCODEINTERNALID:TEXT),"|")
				
				If Len(aPagamento) >= 4
				
					cPagamento := xFilial("SX5") + "24" + AllTrim(aPagamento[4])
				
					dbSelectArea("SX5")
					SX5->(dbSetOrder(1))
					SX5->(dbSeek(cPagamento))
					
					If SX5->(Found()) .And. !Empty(AllTrim(SX5->X5_DESCRI))
						cPagamento := PADR(AllTrim(SX5->X5_CHAVE) ,nTamFormPg )
						Aadd(aAux,{"LT_FORMPG"	, 	cPagamento	, Nil } )
					Else
						lRet	 := .F.
						cXmlRet := OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI]:_PAYMENTMETHODCODE:TEXT + " - " + STR0030 //"Forma de pagamento nao integrado ao Protheus, verificar integracao 'forma de pagamento'"
					Endif
					
				Else
					lRet	 := .F.
					cXmlRet := OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI]:_PAYMENTMETHODCODE:TEXT + " - " + STR0030 //"Forma de pagamento nao integrado ao Protheus, verificar integracao 'forma de pagamento'"
				EndIf
				
		
			ElseIf XmlChildEx(OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI], "_PAYMENTMETHODCODE") <> Nil .And. OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI]:_PAYMENTMETHODCODE <> Nil .And. ;
				!Empty(AllTrim(OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI]:_PAYMENTMETHODCODE:TEXT))			
				
				cPagamento := AllTrim(OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI]:_PAYMENTMETHODCODE:TEXT)

				aPagamento := Separa(CFGA070Int(cMarca, "SX5", "X5_CHAVE", cPagamento ),"|")

				If Len(aPagamento) >= 4
					cPagamento := xFilial("SX5") + "24" + AllTrim(aPagamento[4])
				Else
					cPagamento := xFilial("SX5") + "24" + cPagamento
				EndIf

				dbSelectArea("SX5")
				SX5->(dbSetOrder(1))
				SX5->(dbSeek(cPagamento))

				If SX5->(Found()) .And. !Empty(AllTrim(SX5->X5_DESCRI))
					cPagamento := PADR(AllTrim(SX5->X5_CHAVE) ,nTamFormPg )
					Aadd(aAux,{"LT_FORMPG"	, cPagamento	, Nil } )
				Else
					lRet	 := .F.
					cXmlRet := OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI]:_PAYMENTMETHODCODE:TEXT + " - "+ STR0030 //"Forma de pagamento nao integrado ao Protheus, verificar integracao 'forma de pagamento'"
				Endif
				
			Else
				lRet	 := .F.
				cXmlRet := STR0021 //"Forma de pagamento não informada"
			EndIf
			
			If XmlChildEx(OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI], "_CONFERENCEVALUE") <> Nil .And. OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI]:_CONFERENCEVALUE <> Nil .And. ;
				!Empty(AllTrim(OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI]:_CONFERENCEVALUE:TEXT))			
				Aadd(aAux,{"LT_VLRDIG"	, Val(OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI]:_CONFERENCEVALUE:TEXT)			, Nil } )
			Else
				lRet	 := .F.
				cXmlRet := STR0022 //"Valor digitado não informado"
			EndIf
			
			If XmlChildEx(OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI], "_COUNTEDVALUE") <> Nil .And. OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI]:_COUNTEDVALUE <> Nil .And. ;
				!Empty(AllTrim(OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI]:_COUNTEDVALUE:TEXT))	
				Aadd(aAux,{"LT_VLRAPU"	, Val(OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI]:_COUNTEDVALUE:TEXT)				, Nil } )
			Else
				lRet	 := .F.
				cXmlRet := STR0023 //"Valor apurado não informado"
			EndIf

			Aadd(aAux,{"LT_ADMIFIN"	, SPACE(nTamAdmFin)			, Nil } )	//Campo obrigatorio pois faz parte do indice 1						
			Aadd(aAux,{"LT_OPERADO"	, aFechCx[3][2]				, Nil } )
			Aadd(aAux,{"LT_DTMOV"	, aFechCx[4][2]				, Nil } )
			Aadd(aAux,{"LT_DTFECHA"	, aFechCx[6][2]				, Nil } )
			Aadd(aAux,{"LT_NUMMOV"	, aFechCx[8][2]				, Nil } )
			Aadd(aAux,{"LT_ESTACAO"	, aFechCx[1][2]				, Nil } )
			Aadd(aAux,{"LT_PDV"		, aFechCx[2][2]				, Nil } )
			Aadd(aAux,{"LT_AGENCIA"	, "."						, Nil } )
			Aadd(aAux,{"LT_CONFERE"	, "1"						, Nil } )
			Aadd(aAux,{"LT_MOEDA"	, 1 						, Nil } )
			
			If lRet 
				If XmlChildEx(OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI], "_WITHDRAWALVALUE") <> Nil .And. OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI]:_WITHDRAWALVALUE <> Nil .And. ;
					!Empty(AllTrim(OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI]:_WITHDRAWALVALUE:TEXT))	
					Aadd(aAux,{"LT_SANPAR"	, Val(OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI]:_WITHDRAWALVALUE:TEXT)				, Nil } )
					Aadd(aSang,{ cPagamento , Val(OXMLCONTENT:_LISTOFPAYMENTS:_PAYMENT[nI]:_WITHDRAWALVALUE:TEXT) })//salva dados para realizar sangria automatica
				EndIf
	
				If  Ascan(aPays, { |x| AllTrim(x[1][2]) == AllTrim(AllTrim(aAux[1][2])) }) > 0 
					lRet	 := .F.
					cXmlRet := STR0031 + cPagamento + STR0032 + AllTrim(STR(nI)) //"Lista de pagamentos com formas duplicadas. Favor verificar a Lista de pagamentos. Forma: " ### "Item: " 
				Else			
					Aadd(aPays, Aclone(aAux)  )
				EndIf
			
			EndIf
						
			aAux := {}
		Next nI
	Else
		lRet	 := .F.
		cXmlRet := STR0027 //"Lista de pagamentos não informada."
	EndIf
Else
	lRet	 := .F.
	cXmlRet := STR0027 //"Lista de pagamentos não informada."
EndIf 


Return aFechCx


//--------------------------------------------------------
/*/{Protheus.doc} LojI057Atu
Inclui/Altera ou exclui o registro da Conferência de Caixa.
@type       function
@param   	aFechCx		Array campos do fechamento de caixa
@param   	nOpcAuto   	Opção 0=Verifica | 3=Incluir | 4=Alterar	| 5=Excluir
@param   	aPays  		Array pagamentos
@param   	cVersao  	Versao da Mensagem
@author  	rafael.pessoa
@since   	13/10/2017
@version 	P12
@return     Aret[1] - Operação realizada com sucesso
			Aret[2] - Mensagem de erro

/*/
//--------------------------------------------------------
Static Function LojI057Atu(aFechCx,nOpcAuto,aPays)

Local lRet		:= .F.
Local cErro		:= ""
Local aAutoCab	:= {}

Default aFechCx    	:= {}	//Array de campos do fechamento de caixa
Default nOpcAuto	:= 0	//Se for zero é será inclusao ou alteração
Default aPays    	:= {}	//Array de Taxas

Private lMsErroAuto := .F.	//Necessário para verificar possivel erro no ExecAuto

/* Possiveis valres de nOpcAuto:
	0 - Verificar se é inclusão ou alteração.
	3 - Incluir
	4 - Alterar
	5 - Excluir 
*/
//Verificar se é inclusao ou alteração
If nOpcAuto == 0  
	nOpcAuto := 3
	DbSelectArea("SLW")
	DbSetOrder(1) //LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_NUMMOV
	If SLW->(MsSeek( xFilial( "SLW" ) + aFechCx[2][2]+aFechCx[3][2]+DTOS(aFechCx[4][2])+aFechCx[8][2] ))
		Lj057DelPays(aFechCx)
	EndIf 
EndIf


aAutoCab 	:= aClone(aFechCx)
aAutoItens	:= aClone(aPays)


Begin Transaction

	MsExecAuto({|a,b,c| LojA057A(a,b,c)},aAutoCab,aAutoItens,nOpcAuto)

	lRet := !lMsErroAuto

	If lMsErroAuto
		cErro := AllTrim(_NoTags(MostraErro()))
		LjGrvLog("LOJI057", STR0024 + "SLW|SLT")//"Ocorreu erro na transação de gravação "
		LjGrvLog("LOJI057", STR0025 + Iif(!Empty(cErro), cErro, STR0026 ) )// "Erro:" "Não identificado."
		Conout( cErro )
		DisarmTransaction()
	Else				
		//Realiza sangria de caixa  automatica na integração
		If Len(aSang) > 0
			lRet 	:= Lj057Sang(aFechCx, @cErro)
			If !lRet
				LjGrvLog("LOJI057", cErro )
				Conout( cErro )
				DisarmTransaction()
			EndIf
		EndIf
		
	EndIf

End Transaction
	
Return {lRet, cErro}


//--------------------------------------------------------
/*/{Protheus.doc} Lj057DelPays
Deleta Pagamentos antes da atualização
@type       function
@param   	aFechCx		Array campos do fechamento de caixa
@author  	rafael.pessoa
@since   	13/10/2017
@version 	P12
@return  	Nil
/*/
//--------------------------------------------------------
Static Function Lj057DelPays(aFechCx)

Default aFechCx    	:= {}	//Array de campos do fechamento de caixa

If Len(aFechCx) > 0

	DbSelectArea("SLW")
	DbSetOrder(1) //LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_NUMMOV
	If SLW->(MsSeek( xFilial( "SLW" ) + aFechCx[2][2]+aFechCx[3][2]+DTOS(aFechCx[4][2])+aFechCx[8][2] ))
		While SLW->(!EOF()) .And. SLW->LW_FILIAL+SLW->LW_PDV+SLW->LW_OPERADO+DTOS(SLW->LW_DTABERT)+SLW->LW_NUMMOV == ;
			xFilial( "SLW" ) + aFechCx[2][2]+aFechCx[3][2]+DTOS(aFechCx[4][2])+aFechCx[8][2]
			RecLock("SLW",.F.)
			SLW->(DbDelete())
			SLW->(MsUnlock())
			SLW->(dbSkip())
		EndDo
	EndIf

	DbSelectArea("SLT")
	DbSetOrder(5)//LT_FILIAL+DTOS(LT_DTFECHA)+LT_NUMMOV+LT_OPERADO+LT_ESTACAO+LT_PDV 
	If SLT->(MsSeek( xFilial( "SLT" ) + DTOS(aFechCx[6][2])+aFechCx[8][2]+aFechCx[3][2]+aFechCx[1][2]+aFechCx[2][2] ))
		While SLT->(!EOF()) .And. SLT->LT_FILIAL+DTOS(SLT->LT_DTFECHA)+SLT->LT_NUMMOV+SLT->LT_OPERADO+SLT->LT_ESTACAO+SLT->LT_PDV == ;
			xFilial( "SLT" ) + DTOS(aFechCx[6][2])+aFechCx[8][2]+aFechCx[3][2]+aFechCx[1][2]+aFechCx[2][2]
			RecLock("SLT",.F.)
			SLT->(DbDelete())
			SLT->(MsUnlock())
			SLT->(dbSkip())
		EndDo
	EndIf
EndIf

Return Nil


//--------------------------------------------------------
/*/{Protheus.doc} Lj057Sang
Realiza sangria de caixa 
@type       function
@param   	aFechCx		Array campos do fechamento de caixa
@param   	cErro		Controle de erro
@author  	rafael.pessoa
@since   	17/05/2018
@version 	P12
@return  	lRet se retornou corretamente
/*/
//--------------------------------------------------------
Static Function Lj057Sang(aFechCx, cErro)

Local lRet 			:= .T.
Local cCodDestin 	:= Substr(AllTrim(GetMv("MV_CXLOJA")),1,3)	// Variável utilizada na gravação das Sangrias
Local nX			:= 0 //Contador
Local nDinheiro		:= 0 //Valor da sangria em Dinheiro
Local nCheques		:= 0 //Valor da sangria em Cheque
Local nCartao		:= 0 //Valor da sangria em Credito
Local nVlrDebi		:= 0 //Valor da sangria em Debito
Local nFinanc		:= 0 //Valor da sangria em Financiado
Local nConveni		:= 0 //Valor da sangria em Convenio
Local nVales		:= 0 //Valor da sangria em Vales
Local nOutros		:= 0 //Valor da sangria em outros
Local aSimbs		:= {}//Simbolos usado para localizacao


Private nMoedaCorr	:= 1 //Privete Usada na gravacao da sangria   	

Default aFechCx    	:= {}	//Array de campos do fechamento de caixa
Default cErro    	:= ""	//Controle de erro

If Len(aSang) > 0

	For nX := 1 To Len(aSang)
		
		If Upper(AllTrim(aSang[nX][1])) == "R$"
			nDinheiro := aSang[nX][2]
		EndIf
	
	Next nX
	
	// Valida se o Caixa destino existe no SA6
	DbSelectArea("SA6")
	DbSetOrder(1) //A6_FILIAL+A6_COD
	If !Empty(cCodDestin) .And. SA6->(dbSeek(xFilial("SA6")+cCodDestin))	.And. nDinheiro > 0

		lRet := Frt050SE5(  1				,aFechCx[3][2] 	,cCodDestin 	,nDinheiro		, ;
                   			nCheques		,nCartao		,nVlrDebi		,nFinanc		, ;
                  			nConveni		,nVales			,nOutros		,aSimbs 		, ;
                   			.F.				,.T.      )
        If !lRet
        	cErro := STR0033 + AllTrim(aFechCx[3][2])  + STR0034 + cCodDestin //"Não foi possível realizar a sangria do Caixa: " ### " para o Caixa: "	
        EndIf           								
	Else
		lRet := .F. 
		cErro := STR0035 //"Não foi possível realizar a sangria do Caixa. O caixa destino não foi definido ou não foi encontrado."
		cErro += STR0036 // "Verifique se o caixa destino esta correto no parametro MV_CXLOJA ."     					
	EndIf					

	aSang := {}
		
EndIf		

Return lRet
