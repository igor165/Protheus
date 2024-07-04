#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH" 
#INCLUDE "MATI632.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MATI632

Funcao de integracao com o adapter EAI para recebimento do cadastro de Roteiros
de operações (SG2) utilizando o conceito de mensagem unica.

@param   cXml        Variável com conteúdo XML para envio/recebimento.
@param   nTypeTrans   Tipo de transação. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Lucas Konrad França
@version P118
@since   12/04/2016
@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio

@obs    O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
        o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
        TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
        O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------------------------------------
Function MATI632(cXml, nTypeTrans, cTypeMessage) 
   Local lRet        := .T.
   Local cXmlRet     := ""
   Local aRet        := {}
   
   Private lIntegPPI := .F.
   Private oXml      := Nil

   //Verifica se está sendo executado para realizar a integração com o PPI.
   //Se a variável lRunPPI estiver definida, e for .T., assume que é para o PPI.
   //Variável é criada no fonte mata632.prw, na função mata200PPI().
   If Type("lRunPPI") == "L" .And. lRunPPI
      lIntegPPI := .T.
   EndIf

   //Mensagem de Entrada
   If nTypeTrans == TRANS_RECEIVE
      /*
         Mensagem desenvolvida para integração com o PCFactory, não possui recebimento.
      */
	ElseIf nTypeTrans == TRANS_SEND
		If lIntegPPI
			aRet := v1000(cXml, nTypeTrans, cTypeMessage, oXml)
			lRet    := aRet[1]
			cXMLRet := aRet[2]
		EndIf
	EndIf

Return {lRet, cXmlRet}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} v1000

Funcao de integracao com o adapter EAI para envio do cadastro de Roteiros
de operações (SG2) utilizando o conceito de mensagem unica.

@param   cXml        Variável com conteúdo XML para envio/recebimento.
@param   nTypeTrans   Tipo de transação. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Lucas Konrad França
@version P118
@since   12/04/2016
@return  aRet  - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio

@obs    O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
       o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
       TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
       O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------------------------------------
Static Function v1000(cXml, nTypeTrans, cTypeMessage, oXml)
	Local lRet       := .T.
	Local lLog       := .T. //FindFunction("AdpLogEAI")
	Local cXMLRet    := ""
	Local cEvent     := ""
	Local cEntity    := "ItemScript"
	Local cProduto   := ""
	Local cRoteiro   := ""
	Local aAreaAnt   := GetArea()
	Local aAreaSG2   := SG2->(GetArea())
	Local aAreaSB1   := SB1->(GetArea())
	Local lDtVld     := Iif(SG2->(FieldPos("G2_DTINI")) > 0, .T., .F.)
	Local cAddXml    := ""
	
	Local lUnitTime  := ExistBlock("MTI632UTTP")
	Local lAddTags   := ExistBlock("PCPADDTAGS")
	Local cUnitTime  := "1"
	Local aParam     := {}
   
	If !lIntegPPI
		//IIf(lLog, AdpLogEAI(1, "MATI632", nTypeTrans, cTypeMessage, cXML), ConOut(STR0004)) //"Atualize o UPDINT01.prw para utilizar o log"
		If lLog
          AdpLogEAI(1, "MATI632", nTypeTrans, cTypeMessage, cXML)
       EndIf
	EndIf

	If nTypeTrans == TRANS_RECEIVE
		/*
			Mensagem desenvolvida para integração com o PCFactory, e nao possui recebimento.
		*/
	ElseIf nTypeTrans == TRANS_SEND
		// Verifica se é uma exclusão
		If !Inclui .And. !Altera
			cEvent := 'delete'
		Else
			cEvent := 'upsert'
		EndIf

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+SG2->G2_PRODUTO))
		
		cProduto := SG2->G2_PRODUTO
		cRoteiro := SG2->G2_CODIGO
		
		// Monta XML de envio de mensagem unica
		cXMLRet := '<BusinessEvent>'
		cXMLRet +=    '<Entity>' + cEntity + '</Entity>'
		cXMLRet +=    '<Event>' + cEvent + '</Event>'
		cXMLRet +=    '<Identification>'
		cXMLRet +=       '<key name="InternalID">' + IntRotExt(/*Empresa*/, /*Filial*/, SG2->G2_PRODUTO, SG2->G2_CODIGO, /*Versão*/)[2] + '</key>'
		cXMLRet +=    '</Identification>'
		cXMLRet += '</BusinessEvent>'
		cXMLRet += '<BusinessContent>'
		cXMLRet +=    '<ItemCode>'+AllTrim(SG2->G2_PRODUTO)+'</ItemCode>'
		cXMLRet +=    '<ItemInternalId>'+cEmpAnt+'|'+cFilAnt+'|'+AllTrim(SG2->G2_PRODUTO)+'</ItemInternalId>'
		cXMLRet +=    '<ItemDescription>'+_NoTags(AllTrim(SB1->B1_DESC))+'</ItemDescription>'
		cXMLRet +=    '<ScriptCode>'+AllTrim(SG2->G2_CODIGO)+'</ScriptCode>'
		cXMLRet +=    '<ScriptDescription />'
		cXMLRet +=    '<ScriptAlternative />'
		If cEvent == 'delete'
			cXMLRet += '<ListOfActivity />'
		Else
			cXMLRet += '<ListOfActivity>'
			
			//Posiciona no primeiro registro do produto/roteiro
			SG2->(dbSetOrder(1))
			SG2->(dbSeek(xFilial("SG2")+cProduto+cRoteiro))
			While SG2->(!Eof()) .And. SG2->(G2_FILIAL+G2_PRODUTO+G2_CODIGO) == xFilial("SG2")+cProduto+cRoteiro
				If ! PCPFiltPPI("SG2", AllTrim(cRoteiro)+"+"+AllTrim(cProduto), "SG2")
					SG2->(dbSkip())
					Loop 
				EndIf
				
				cXMLRet += '<Activity>'
				cXMLRet +=    '<ActivityInternalID>'+cValToChar(SG2->(Recno()))+'</ActivityInternalID>'
				cXMLRet +=    '<ActivityCode>'+AllTrim(SG2->G2_OPERAC)+'</ActivityCode>'
				cXMLRet +=    '<ActivityDescription>'+_NoTags(AllTrim(SG2->G2_DESCRI))+'</ActivityDescription>'
				cXMLRet +=    '<MachineCode>'+AllTrim(SG2->G2_RECURSO)+'</MachineCode>'
				cXMLRet +=    '<ToolCode>'+AllTrim(SG2->G2_FERRAM)+'</ToolCode>'
				cXMLRet +=    '<ActivityType>1</ActivityType>'
				cXMLRet +=    '<InitialDate>'+Iif(lDtVld, getDate(SG2->G2_DTINI) ,"")+'</InitialDate>'
				cXMLRet +=    '<FinalDate>'+Iif(lDtVld, getDate(SG2->G2_DTFIM) ,"")+'</FinalDate>'
				cXMLRet +=    '<PercentageScrapValue />'
				cXMLRet +=    '<PercentageValue />'
				cXMLRet +=    '<WorkCenterCode>'+AllTrim(SG2->G2_CTRAB)+'</WorkCenterCode>'
				cXMLRet +=    '<WorkCenterInternalId>'+cEmpAnt+'|'+cFilAnt+'|'+AllTrim(SG2->G2_CTRAB)+'</WorkCenterInternalId>'
				cXMLRet +=    '<WorkCenterDescription>'+_NoTags(AllTrim(Posicione("SHB",1,xFilial("SHB")+SG2->G2_CTRAB,"HB_NOME")))+'</WorkCenterDescription>'
				cXMLRet +=    '<UnitItemNumber>'+cValToChar(SG2->G2_LOTEPAD)+'</UnitItemNumber>'
				cXMLRet +=    '<TimeResource>0</TimeResource>'
				cXMLRet +=    '<TimeMachine>'+cValToChar(SG2->G2_TEMPAD)+'</TimeMachine>'
				cXMLRet +=    '<TimeSetup>'+cValToChar(SG2->G2_SETUP)+'</TimeSetup>'
				If lUnitTime
					aParam := {}
					aAdd(aParam,SG2->G2_OPERAC)
					aAdd(aParam,SG2->G2_RECURSO)
					aAdd(aParam,SG2->G2_CTRAB)
					cUnitTime := ExecBlock('MTI632UTTP',.F.,.F.,aParam)
					If ValType(cUnitTime) != "C"
						cUnitTime := "1"
					EndIf
					cXMLRet += '<UnitTimeType>'+cUnitTime+'</UnitTimeType>'
				Else
					cXMLRet += '<UnitTimeType>1</UnitTimeType>'
				EndIf
				cXMLRet +=    '<ResourceQuantity />'
				cXMLRet +=    '<UnitActivityCode />'
				cXMLRet +=    '<ActivityItemValue />'
				cXMLRet +=    '<ScriptAlternative>'+SG2->G2_ROTALT+'</ScriptAlternative>'
				If lIntegPPI .And. lAddTags
         			cAddXml := ExecBlock("PCPADDTAGS",.F.,.F.,{cEntity,cEvent,"SG2->"})
         			If ValType(cAddXml) == "C"
            			cXMLRet += cAddXml
         			EndIf
      			EndIf
				cXMLRet += '</Activity>'
				SG2->(dbSkip())
			End
			cXMLRet += '</ListOfActivity>'
		EndIf
		
		cXMLRet +=    '<ListOfPertOrders />'
		cXmlRet += '</BusinessContent>'

		If lIntegPPI
			completXml(@cXMLRet)
		EndIf
	EndIf

	If !lIntegPPI
		//IIf(lLog, AdpLogEAI(5, "MATI632", cXMLRet, lRet), ConOut(STR0004)) //"Atualize o UPDINT01.prw para utilizar o log"
		If lLog
          AdpLogEAI(5, "MATI632", cXMLRet, lRet)
       EndIf		
	EndIf
	SG2->(RestArea(aAreaSG2))
	SB1->(RestArea(aAreaSB1))
	RestArea(aAreaAnt)
Return {lRet, cXmlRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} IntRotExt
Monta o InternalID do roteiro de operações de acordo com o código passado
no parâmetro.

@param   cEmpresa   Código da empresa (Default cEmpAnt)
@param   cFil       Código da Filial (Default cFilAnt)
@param   cProduto   Código do Produto
@param   cRoteiro   Código do Roteiro
@param   cVersao    Versão da mensagem única (Default 1.000)

@author  Lucas Konrad França
@version P118
@since   12/04/2016
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado.
         No segundo parâmetro uma variável string com o InternalID
         montado.

@sample  IntRotExt(,,'PRODUTO','01') irá retornar {.T.,'99|01|01|PRODUTO'}
/*/
//-------------------------------------------------------------------
Function IntRotExt(cEmpresa, cFil, cProduto, cRoteiro, cVersao)
   Local aResult    := {}
   Default cEmpresa := cEmpAnt
   Default cFil     := xFilial('SG1')
   Default cVersao  := '1.000'

   If cVersao == '1.000'
      aAdd(aResult, .T.)
      aAdd(aResult, cEmpresa + '|' + RTrim(cFil) +'|' + AllTrim(cRoteiro) + '|' + AllTrim(cProduto))
   Else
      aAdd(aResult, .F.)
      aAdd(aResult, STR0005 + Chr(10) + STR0006) // "Versão do recurso não suportada." "As versões suportadas são: 1.000"
   EndIf   
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} completXml()
Adiciona o cabeçalho da mensagem quando utilizado integração com o PPI.

@param   cXML  - XML gerado pelo adapter. Parâmetro recebido por referência.

@author  Lucas Konrad França
@version P12
@since   13/08/2015
@return  Nil
/*/
//-------------------------------------------------------------------
Static Function completXml(cXML)
   Local cCabec     := ""
   Local cCloseTags := ""
   Local cGenerated := ""

   cGenerated := SubStr(DTOS(Date()), 1, 4) + '-' + SubStr(DTOS(Date()), 5, 2) + '-' + SubStr(DTOS(Date()), 7, 2) + 'T' + Time()

   cCabec := '<?xml version="1.0" encoding="UTF-8" ?>'
   cCabec += '<TOTVSMessage xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="xmlschema/general/events/ItemScript_1_000.xsd">'
   cCabec +=     '<MessageInformation version="1.001">'
   cCabec +=         '<UUID>1</UUID>'
   cCabec +=         '<Type>BusinessMessage</Type>'
   cCabec +=         '<Transaction>ItemScript</Transaction>'
   cCabec +=         '<StandardVersion>1.0</StandardVersion>'
   cCabec +=         '<SourceApplication>SIGAPCP</SourceApplication>'
   cCabec +=         '<CompanyId>'+cEmpAnt+'</CompanyId>'
   cCabec +=         '<BranchId>'+cFilAnt+'</BranchId>'
   cCabec +=         '<UserId>'+__cUserId+'</UserId>'
   cCabec +=         '<Product name="'+FunName()+'" version="'+GetRPORelease()+'"/>'
   cCabec +=         '<GeneratedOn>' + cGenerated +'</GeneratedOn>'
   cCabec +=         '<ContextName>PROTHEUS</ContextName>'
   cCabec +=         '<DeliveryType>Sync</DeliveryType>'
   cCabec +=     '</MessageInformation>'
   cCabec +=     '<BusinessMessage>'

   cCloseTags := '</BusinessMessage>'
   cCloseTags += '</TOTVSMessage>'
   
   cXML := cCabec + cXML + cCloseTags

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} getDate()
Formata uma data para o padrão enviado por XML (YYYY-MM-DD)

@param   dDate  - Data que será transformada para String

@author  Lucas Konrad França
@version P12
@since   04/04/2016
@return  cDate
/*/
//-------------------------------------------------------------------
Static Function getDate(dDate)
   Local cDate     := ""

   If !Empty(dDate)
      cDate := DtoS(dDate)
      cDate := SubStr(cDate, 1, 4) + '-' + SubStr(cDate, 5, 2) + '-' + SubStr(cDate, 7, 2)
   EndIf
Return cDate