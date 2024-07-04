#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "LOJI070.CH"

#DEFINE CFORMPAD	"BOL|CC|CD|CH|CO|CR|DC|FI|FID|R$|VA|VP|CI|CQ|FA|RA"     //Formas de Pagamento Padrao

Static cMarca		:= ""
Static cInterId		:= ""                                                   //Codigo externo utilizada no De/Para
Static cIdMsg		:= "PAYMENTMETHOD"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOJI070A

Funcao de integracao com o adapter EAI para recebimento do cadastro de
Forma de Pagamento utilizando o conceito de mensagem unica.

@param		cXml          Variável com conteúdo XML para envio/recebimento.
@param		nTypeTrans    Tipo de transação. (Envio/Recebimento)
@param		cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author		Vendas Cliente      
@version	P12
@since		06/10/2015
@return		lRet - (boolean)  Indica o resultado da execução da função
			cXmlRet - (caracter) Mensagem XML para envio
			Nome do Adapter EAI
@Obs		
/*/
//-------------------------------------------------------------------------------------------------
Function LOJI070A(cXml, nTypeTrans, cTypeMsg)

Local cError		:= ""  //Erros no XML
Local cWarning		:= ""  //Avisos no XML
Local cVersao		:= ""  //Versao da Mensagem
Local cXmlRet		:= ""  //Mensagem de retorno da integracao
Local lRet			:= .T. //Retorno da integracao
Local oXmlLj070 	:= NIL

Default cXml     := ""

If !Empty(cXml)
	oXmlLj070 := xmlParser(cXml, "_", @cError, @cWarning) //Objeto XML
EndIf	 
//Validacoes de erro no XML
If Valtype(oXmlLj070) == "O" .And. Empty(cError) .And. Empty(cWarning)
	//Validacao de versao
	If XmlChildEx(oXmlLj070:_TOTVSMessage:_MessageInformation, "_VERSION") <> Nil .And.; 
		!Empty(oXmlLj070:_TOTVSMessage:_MessageInformation:_version:Text)
		
		cVersao := StrTokArr(oXmlLj070:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
		//Valida se versao implementada
		If cVersao $ "1|2"																													
			v1000(oXmlLj070, cTypeMsg, @lRet, @cXmlRet, nTypeTrans)
		Else
			lRet 	 := .F.
			cXmlRet := STR0001 //#"A versao da mensagem informada nao foi implementada!"	
		EndIf				
	Else
		lRet 	 := .F.
		cXmlRet := STR0002 //#"Versao da mensagem nao informada!"	
	EndIf
Else
	lRet 	 := .F.
	cXmlRet := STR0003 //#"Erro no parser!" 
EndIf

Return {lRet, cXmlRet, cIdMsg}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOJI070

Rotina para processar a mensagem tipo RECEIVE e BUSINESS
Efetua a gravacao da Forma de Pagamento (SX5 - 24)

@param   oXmlLj070	Objeto contendo a mensagem (XML)
@param   cTypeMsg    	Tipo da mensagem 
@param   lRet  		Indica o resultado da execução da função
@param   cXmlRet  		Mensagem Xml para envio
@param   nTypeTrans	Tipo da transação

@author  Vendas Cliente      
@version P12
@since   06/10/2015
@return  Nil

/*/
//-------------------------------------------------------------------------------------------------
Static Function v1000(oXmlLj070, cTypeMsg, lRet, cXmlRet, nTypeTrans)

Local aArea	 	:= GetArea() 			//Armazena areas
Local oXmlContent	:= Nil 				//Objeto Xml com o conteudo da BusinessContent apenas

//Mensagem de Recebimento
If nTypeTrans == TRANS_RECEIVE
	//Mensagem tipo Business
	If cTypeMsg == EAI_MESSAGE_BUSINESS
		lRet := LojI070Rec(oXmlLj070, @cXmlRet)	// Recebi as msgs de forma 
	ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE							
		cXmlRet := "<TAGX>RECEPCAO RESPONSE MESSAGE</TAGX>"																
	ElseIf cTypeMsg == EAI_MESSAGE_WHOIS						 
		cXmlRet := "1.000"
	EndIf	
EndIf	
//Restaura areas
RestArea(aArea)
Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LojI070Rec
@param   oXmlContent	valor recebido na tag internalId
@param   cXMLRet 		Mensagem de retorno para o EAI
@param   cValInt 		Recebe o valor do InternalID do XML
@since   18/01/2017
@return  lRet 			Retorno lógico
/*/
//-------------------------------------------------------------------------------------------------
Static Function LojI070Rec(oXmlLj070,cXmlRet)

Local aAux		:= {}	//Array auxiliar no De-Para
Local cEvent	:= ""	//Armazena o evento
Local lRet		:= .T.
Local lItemAtivo:= .T.	// Verifica se Forma de Pagamento Ativa
Local cValInt	:= ""	// InternalId
 
//Verifica se possui Marca	
If XmlChildEx(oXmlLj070:_TOTVSMessage:_MessageInformation:_Product, "_NAME") <> Nil .And.;
	!Empty(oXmlLj070:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
	cMarca := oXmlLj070:_TotvsMessage:_MessageInformation:_Product:_Name:Text //Armazena marca
Else	
	lRet    := .F.
	cXmlRet := STR0018 //"O campo MARCA é obrigatorio"
EndIf

//Verifica se tem Evento
If XmlChildEx(oXmlLj070:_TOTVSMessage:_BusinessMessage:_BusinessEvent, "_EVENT") <> Nil .And.;         	
	!Empty(oXmlLj070:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text)
	cEvent := Upper(oXmlLj070:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) //Armazena evento
Else
	lRet    := .F.
	cXmlRet := STR0009 //#"O evento e obrigatorio"
EndIf

//Efetua a carga do objeto InternalID	     	
oXmlContent := oXmlLj070:_TOTVSMessage:_BusinessMessage:_BusinessContent
If XmlChildEx(oXmlContent, "_INTERNALID") <> Nil .And. !Empty(oXmlContent:_InternalId:Text) //InternalId da Forma de Pagto			
    cInterId := oXmlContent:_InternalId:Text
Else
    lRet    := .F.
    cXmlRet := I18n(STR0031, {"InternalId"})    //"A TAG #1 é obrigatória"
EndIf

If lRet
	
	//Valida se item esta ativo
	If XmlChildEx(oXmlContent, "_ACTIVE") <> Nil .And. !Empty(oXmlContent:_Active:Text)
		lItemAtivo := AllTrim(Upper(oXmlContent:_Active:Text)) == "TRUE" 
	EndIf

	//Verifica qual o ID da mensagem
	If XmlChildEx(oXmlLj070:_TOTVSMessage:_MessageInformation, "_TRANSACTION") <> Nil .AND.;
	 			!Empty(oXmlLj070:_TOTVSMessage:_MessageInformation:_Transaction:Text)
		cIdMsg := AllTrim(Upper(oXmlLj070:_TOTVSMessage:_MessageInformation:_TRANSACTION:Text))		
	EndIf
	
	//Se nao esta ativo e ainda nao foi integrado primeiro inser para depois deletar
	//pois o protheus não tem o conceito de ativo para pagamentos
	aAux := IntFmPgtInt(cInterId, cMarca ,  /*Versao*/) 
	If !lItemAtivo .And. !(ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1])		
		lRet := LojI070Upd(oXmlContent,@cXMLRet,@cValInt)
	EndIf

	//Se item inativo, evento sera delete
	If !lItemAtivo
		cEvent := "DELETE"
	EndIf
	
	If lRet	
		If cEvent == "UPSERT"
			lRet := LojI070Upd(oXmlContent,@cXMLRet,@cValInt)
		ElseIf cEvent == "DELETE" //Se o evento Delete
			lRet := LojI070Del(oXmlContent,@cXMLRet,@cValInt)
		EndIf
	EndIf
	
	//Valida se continua e pega o retorno
	If lRet
		cXMLRet := LojI070Ret(cValInt)
	EndIf																																				
EndIf

Return(lRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LojI070Upd
Retorno final do XML para a mensagem unica
@param   oXmlContent	valor recebido na tag internalId
@param   cXMLRet 		Mensagem de retorno para o EAI
@param   cValInt 		Recebe o valor do InternalID do XML
@since   18/01/2017
@return  lRet 			Retorno lógico
/*/
//-------------------------------------------------------------------------------------------------
Static Function LojI070Upd(oXmlContent,cXMLRet,cValInt)

Local aAux		    := {}	//Array auxiliar no De-Para
Local lRet		    := .T.
Local cCodigo	    := ""	//Codigo da Forma de Pagamento
Local cDescri	    := "" 	//Descricao da Forma de Pagamento
Local nTamL4Forma	:= 0
Local nTamE1TIPO	:= 0

If cIdMsg == "PAYMENTMETHOD"
    
    //Tratamento utilizando a tabela XXF com um De/Para de codigos
	aAux := IntFmPgtInt(cInterId, cMarca,  /*Versao*/)
	
    //Verifica se o registro foi encontrado
    //Update
	If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
        
        //Codigo da Forma de Pagamento
		cCodigo := PadR(aAux[2][4], TamSx3("X5_CHAVE")[1])
		
        //Validacao para nao permitir alterar o Codigo da Forma de Pagamento ja incluida
		If XmlChildEx(oXmlContent, "_CODE") <> Nil .And. !Empty(oXmlContent:_Code:Text) .And. cCodigo <> Padr(oXmlContent:_Code:Text, TamSx3("X5_CHAVE")[1])
			lRet    := .F.
			cXmlRet := STR0004  //#"O codigo da Forma de Pagamento nao pode ser alterado."
		Else		            			
			//Monta o InternalId de produto que será gravado na table XXF (de/para)
			cValInt := IntFmPgtExt(/*Empresa*/, /*Filial*/, cCodigo, /*Versão*/)[2]			               					               		
		EndIf

    //Insert
	Else
		If XmlChildEx(oXmlContent, "_CODE") <> Nil .And. !Empty(oXmlContent:_Code:Text) 

            //Codigo Forma de Pagamento
			cCodigo := PadR(oXmlContent:_Code:Text, TamSx3("X5_CHAVE")[1])
			
			nTamL4Forma	:= TamSX3('L4_FORMA')[1]
			nTamE1TIPO	:= TamSX3('E1_TIPO')[1]
			
			If Len(AllTrim(cCodigo)) > nTamE1TIPO .OR. Len(AllTrim(cCodigo)) > nTamL4Forma 
				lRet 	:= .F.
				cXmlRet := STR0025 + cCodigo + STR0026 + cValToChar(Len(AllTrim(cCodigo))) + STR0027 +; //"O código da Forma de Pagamento:"###" informado na tag: [CODE], possui "### " caracteres, sendo maior que o tamanho da coluna que irá receber o dado: "
							IIF( Len(AllTrim(cCodigo)) > nTamE1TIPO,"E1_TIPO" + STR0028 + cValToChar(nTamE1TIPO),"L4_FORMA" + STR0028 + cValToChar(nTamE1TIPO))//" tamanho: "	                  							
			Else
				//Monta o InternalId de produto que será gravado na table XXF (de/para)
				cValInt := IntFmPgtExt(/*Empresa*/, /*Filial*/, cCodigo, /*Versão*/)[2]    	                  			                  					
			EndIf
			
		Else			                  		
			lRet    := .F.
			cXmlRet := STR0005  //#"O codigo da Forma de Pagamento é obrigatorio."
		EndIf		                  			                  			                  	
			                  			                  			                  	
	EndIf

	If lRet

        //Descricao Forma Pagto
		If XmlChildEx(oXmlContent, "_DESCRIPTION") <> Nil .And. !Empty(oXmlContent:_Description:Text)
			cDescri := AllTrim(oXmlContent:_Description:Text) 
		Else 
			cDescri := cCodigo  //Se a descricao nao informada, considera o codigo como descricao
		EndIf
		
		//Inclui/Altera Forma de Pagamento somente se nao for padrao		            		
		If !(AllTrim(cCodigo) $ CFORMPAD)		            		

			//Adiciona / Atualiza registro no SX5 - Tabela 24 (FORMAS DE PAGAMENTO) é utilizada pelo Varejo
			FwPutSX5(Nil, "24", cCodigo, cDescri, cDescri, cDescri, Nil)

			//Adiciona / Atualiza registro no SX5 - Tabela 05 (TIPOS DE TÍTULOS) é utilizada pelo Financeiro
			FwPutSX5(Nil, "05", cCodigo, cDescri, cDescri, cDescri, Nil)
		EndIf
        
		//Grava na Tabela XXF (de/para)
		lRet := CFGA070Mnt(cMarca, "SX5", "X5_CHAVE", cInterId, cValInt)
		If !lRet
			cXMLRet := STR0008 //#"Erro na integracao do De-Para de Forma de Pagamento"
		EndIf
	EndIf
Else

	lRet    := .F.
	cXmlRet := STR0019 //" Tag TRANSACTION não é (PAYMENTMETHOD) "
EndIf

Return(lRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LojI070Del
Retorno final do XML para a mensagem unica
@param   oXmlContent	valor recebido na tag internalId
@param   cXMLRet 		Mensagem de retorno para o EAI
@param   cValInt 		recebe o valor do InternalID do XML
@since   18/01/2017
@return  aRet 		Todas os campos das mensagens
/*/
//-------------------------------------------------------------------------------------------------
Static Function LojI070Del(oXmlContent,cXMLRet,cValInt)
Local lRet		:= .T.
Local aAux		:= {}	//Array auxiliar no De-Para
Local cCodigo	:= ""

If cIdMsg == "PAYMENTMETHOD"	
	aAux := IntFmPgtInt(cInterId, cMarca ,  /*Versao*/) 	//Tratamento utilizando a tabela XXF com um De/Para de codigos
	//Se o registro foi encontrado
	If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
		cCodigo := PadR(aAux[2][4], TamSx3("X5_CHAVE")[1]) //Codigo da Forma de Pagamento	            		
		//Monta o InternalId de produto que será gravado na table XXF (de/para)		            			
		cValInt := IntFmPgtExt(/*Empresa*/, /*Filial*/, cCodigo, /*Versão*/)[2]
		//Validacao para exclusao da Forma de Pagamento
		If !Lji70VlExc(cCodigo)
			lRet    := .F.
			cXmlRet := STR0016 + " " +AllTrim(cInterId) + " " + STR0017 //#"Forma de Pagamento" ##"ja foi utilizada em vendas, nao podera ser excluida"
		EndIf
		If lRet
			//Deleta Forma de Pagamento somente se nao for padrao
			If !(AllTrim(cCodigo) $ CFORMPAD)
				//Deleta Forma de Pagamento no SX5
				SX5->( dbSetOrder(1) )  //X5_FILIAL+X5_TABELA+X5_CHAVE
				If SX5->(dbSeek(xFilial("SX5") + "24" + cCodigo))
					SX5->(Reclock("SX5", .F.)) 
					SX5->(dbDelete())
					SX5->(MsUnLock())
				EndIf
			EndIf
			//Exclui na Tabela XXF (de/para)
			lRet := CFGA070Mnt(cMarca, "SX5", "X5_CHAVE", cInterId, cValInt, .T.)
			If !lRet
				cXMLRet := STR0008 //#"Erro na integracao do De-Para de Forma de Pagamento"
			EndIf
		EndIf	
	Else
		lRet 	 := .F.
		cXmlRet := STR0006 + " -> " + AllTrim(cInterId) //#"O registro a ser excluido nao existe na base Protheus"                 
	EndIf
Else
	lRet := .F.
	cXmlRet := STR0019 //" Tag TRANSACTION não é (PAYMENTMETHOD) "
EndIf	
Return(lRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LojI070Ret
Retorno final do XML para a mensagem unica
@param   cValInt	valor recebido na tag internalId
@since   18/01/2017
@return  cXMLRet 	Mensagem retornada para o EAI
/*/
//-------------------------------------------------------------------------------------------------
Static Function LojI070Ret(cValInt)
Local cXMLRet := ""

cXMLRet := "<ListOfInternalId>"
cXMLRet +=    "<InternalId>"
cXMLRet +=       "<Name>PaymentMethodInternalId</Name>"
cXMLRet +=       "<Origin>"+cInterId+ "</Origin>"
cXMLRet +=       "<Destination>"+cValInt+"</Destination>"
cXMLRet +=    "</InternalId>"
cXMLRet += "</ListOfInternalId>" 
Return(cXMLRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntFmPgtInt

Recebe um InternalID e retorna a Forma de Pagamento Protheus

@param   cInternalID	InternalID recebido na mensagem
@param   cRefer    	Produto que enviou a mensagem 
@param   cVersao  		Versão da mensagem única (Default 1.000)

@author  Vendas Cliente      
@version P12
@since   17/12/2015
@return  Array contendo no primeiro parâmetro uma variável logica
		  indicando se o registro foi encontrado no de/para
		  No segundo parâmetro uma variável array com empresa, filial
		  e a Forma de Pagamento.

/*/
//-------------------------------------------------------------------------------------------------
Function IntFmPgtInt(cInternalID, cRefer, cVersao)
   
Local aResult  := {}
Local aTemp    := {}
Local cTemp    := ""
Local cAlias   := "SX5"
Local cField   := "X5_CHAVE"

Default cVersao  := "1.000"

cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)
   
If !Empty(cTemp)
	If cVersao == "1.000"
		aAdd(aResult, .T.)
       aTemp := Separa(cTemp, "|")
       aAdd(aResult, aTemp)	     
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, STR0014 + Chr(10) + STR0015 + "1.000") //#"Versao nao suportada." ##"As versoes suportadas sao:"        
   EndIf
EndIf
  
Return aResult

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntFmPgtExt

Monta o InternalID da Forma de Pagamento de acordo com codigo passado

@param   cEmpresa	Codigo da empresa (Default cEmpAnt)
@param   cFil    	Codigo da Filial (Default xFilial) 
@param   cCodigo    Codigo do Pagamento 
@param   cVersao    Versao da Mensagem

@author  Vendas Cliente      
@version P12
@since   17/12/2015
@return  Array contendo no primeiro parâmetro uma variável logica
		  indicando se o registro foi encontrado
		  No segundo parâmetro uma variável string com o InternalID
		  montado              

/*/
//-------------------------------------------------------------------------------------------------
Function IntFmPgtExt(cEmpresa, cFil, cCodigo, cVersao)
   
Local aResult := {}

Default cEmpresa 	:= cEmpAnt
Default cFil     	:= xFilial("SX5")
Default cCodigo		:= ""
Default cVersao		:= "1.000"

If cVersao == "1.000"
	aAdd(aResult, .T.)
	aAdd(aResult, cEmpresa + "|" + RTrim(cFil) + "|" + "24" + "|" + RTrim(cCodigo))					
Else
	aAdd(aResult, .F.)
	aAdd(aResult, STR0014 + Chr(10) + STR0015 + "1.000") //#"Versao nao suportada." ##"As versoes suportadas sao:" 
EndIf
   
Return aResult

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Lji70VlExc

Verifica se Forma de Pagamento ja foi utilizada em alguma venda.     

@param   cFormaPgt Codigo da Forma de Pagamento       

@author  Vendas Cliente      
@version P12
@since   18/01/2016
@return  Se Forma de Pagamento pode ser excluida, caso ja tenha sido
		  utilizada em alguma venda, a exclusao sera impedida.		  
/*/
//-------------------------------------------------------------------------------------------------
Static Function Lji70VlExc(cFormaPgt)

Local lRet   		:= .T. //Retorno da validacao
Local cWhere 		:= "" //Condicao da query
Local cAliasSL4 	:= GetNextAlias() //Alias temporario

//Condicional para a query		
cWhere := "%"
cWhere += " L4_FILIAL = '" + xFilial("SL4") + "'"
cWhere += " AND L4_FORMA = '" + cFormaPgt + "'"
cWhere += " AND SL4.D_E_L_E_T_ = ''"   		   			
cWhere += "%" 

//Executa a query
BeginSql alias cAliasSL4
	SELECT 
		L4_FILIAL 
	FROM %table:SL4% SL4							
	WHERE %exp:cWhere% 			
EndSql

(cAliasSL4)->(dbGoTop()) //Posiciona no inicio do arquivo temporario

//Se utilizada, Forma de Pagamanto nao pode ser excluida
If (cAliasSL4)->(!EOF())
	lRet := .F.
EndIf

Return lRet