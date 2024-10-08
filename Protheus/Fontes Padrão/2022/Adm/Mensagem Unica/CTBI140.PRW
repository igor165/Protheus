#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "CTBI140.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBI140
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de moedas utilizando o conceito de mensagem unica.

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Leandro Luiz da Cruz
@version P11
@since   10/07/2012
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execu��o da fun��o
         aRet[2] - (caracter) Mensagem Xml para envio

@obs     Caso a vers�o da mensagem utilizada seja 1.000 ser� chamada a
         fun��o v1000 caso seja 2.000 ser� chamada a fun��o v2000.
/*/
//------------------------------------------------------------------------------------
Function CTBI140(cXml, nTypeTrans, cTypeMessage, cVersion)
   Local cError   := ""
   Local cWarning := ""
   Local cVersao  := ""
   Local lRet     := .T.
   Local cXmlRet  := ""
   Local aRet     := {}

   Private oXML   := Nil
   
   cVersao := StrTokArr(cVersion, ".")[1]

   If nTypeTrans == TRANS_RECEIVE
      If cTypeMessage == EAI_MESSAGE_BUSINESS
         oXml := xmlParser(cXml, "_", @cError, @cWarning)

         If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
            If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXml:_TOTVSMessage:_MessageInformation:_version:Text)
               cVersao := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
            Else
               lRet := .F.
               cXmlRet := STR0015 // "Vers�o da mensagem n�o informada!"
               Return {lRet, cXmlRet}
            EndIf
         Else
            lRet := .F.
            cXmlRet := STR0002 // "Erro no parser!"
            Return {lRet, cXMLRet}
         EndIf

         If cVersao == "1"
            aRet := v1000(cXml, nTypeTrans, cTypeMessage)
         ElseIf cVersao == "2"
            aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXml)
         Else
            lRet := .F.
            cXmlRet := STR0001 // "A vers�o da mensagem informada n�o foi implementada!"
            Return  {lRet, cXmlRet}
         EndIf
      ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
         oXml := xmlParser(cXml, "_", @cError, @cWarning)

         If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
            If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXml:_TOTVSMessage:_MessageInformation:_version:Text)
               cVersao := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
            EndIf
         Else
            lRet := .F.
            cXmlRet := STR0004 // "Erro no parser do response!"
            Return {lRet, cXMLRet}
         EndIf

         If cVersao == "1"
            aRet := v1000(cXml, nTypeTrans, cTypeMessage)
         ElseIf cVersao == "2"
            aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXml)
         Else
            lRet    := .F.
            cXmlRet := STR0003 // "A vers�o da mensagem informada n�o foi implementada!"
            Return {lRet, cXmlRet}
         EndIf
      ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
         aRet := v2000(cXML, nTypeTrans, cTypeMessage, oXML)
      EndIf
   ElseIf nTypeTrans == TRANS_SEND
    If Empty(cVersao)
       lRet := .F.
       cXmlRet := STR0016 // "Vers�o n�o informada no cadastro do adapter."
       Return {lRet, cXmlRet}
    EndIf

     If cVersao == "1"
        aRet := v1000(cXml, nTypeTrans, cTypeMessage)
     ElseIf cVersao == "2"
        aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXml)
     Else
        lRet := .F.
        cXmlRet := STR0018 // "A vers�o da mensagem informada n�o foi implementada!"
        Return {lRet, cXmlRet}
     EndIf
  
   EndIf

   lRet := aRet[1]
   cXmlRet := aRet[2]
Return {lRet, cXMLRet}

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �IntegDef  �Autor  � Marcelo C. Coutinho  � Data �  16/12/11   ���
���������������������������������������������������������������������������͹��
���Descricao � Mensagem �nica    										    ���
���������������������������������������������������������������������������͹��
���Uso       � Mensagem �nica                                            	���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function v1000( cXML, nTypeTrans, cTypeMessage )

Local lRet     	:= .T.
Local cXMLRet  	:= ""
Local cError	:= ""
Local cWarning 	:= ""
Local aCab			:= {}
Local nOpcx			:= 0
Local nCount		:= 0
Local cLogErro 	:= ""
Local aErroAuto	:= {}
Local cEvent      := "upsert"
Local cMarca:= ''
Local cAlias:= 'CTO'
Local cField:= 'CTO_MOEDA'
Local aValInt:={}
Local cValInt:= ''
Local nOpcExec:=3
Local cValExt:= ''  
Local oXmlBusMsg := Nil
Local aArea:=GetArea()
Local aAreaCTO:={}
Local cMoeda :=''
Local lMktPlace 	:= SuperGetMv("MV_MKPLACE",.F.,.F.)

Private oXmlCTBA140   
Private nCountA010	  := 0
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.
dbSelectArea( 'CTO' )
aAreaCTO:=CTO->(GetArea())
CTO->( dbSetOrder(1))  
Do Case
Case nTypeTrans == TRANS_RECEIVE  
	 
	Do  Case
		Case cTypeMessage == EAI_MESSAGE_BUSINESS
			oXmlCTBA140 := XmlParser(cXml, "_", @cError, @cWarning)
		
			If oXmlCTBA140 <> Nil .And. Empty(cError) .And. Empty(cWarning)
			
				If ( XmlChildEx( oXmlCTBA140:_TOTVSMessage, '_BUSINESSMESSAGE' ) <> nil )
					oXmlBusMsg := oXmlCTBA140:_TOTVSMessage:_BusinessMessage
       				
					// Recebe Nome do Produto (ex: RM ou PROTHEUS) e guarda na variavel cMarca
					If Type("oXmlCTBA140:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U" 					
						cMarca :=  oXmlCTBA140:_TotvsMessage:_MessageInformation:_Product:_Name:Text
					EndIf      
					// Recebe o codigo da Moeda no Cadastro externo e guarda na variavel cValExt
				   	If Type("oXmlCTBA140:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_key:Text") <> "U"	
				   	    cValExt := oXmlCTBA140:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_key:Text
				   	EndIf
		   	
					//----------------------------------------------------------------------------------------
					//-- procura a Marca,Alias,Codigo na Tabela XXF de De/Para para ver se Existe o C�digo
					//----------------------------------------------------------------------------------------
	   			    //Apens verifica se existe o Registro no XXF para saber se � Inclus�o, Altera��o ou Exclus�o	
		   			aValInt:=C40GetInt(cValExt, cMarca)
		   			If aValInt[1]
		   				cValInt := aValInt[3]//CFGA070INT( cMarca,  cAlias , cField, cValExt )  
		   			Endif
			   					   		
			   		If Upper(oXmlCTBA140:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"                                                             
						If !Empty( cValInt )
							If CTO->(dbSeek(aValint[2][2]+aValint[2][3]))
								nOpcExec:= 4
							Endif
						Else
							nOpcExec:=3
						Endif
			  		Else
		  				nOpcExec:= 5  // se o valint for vazio, o execauto pega o erro.
			   		Endif  
				Else
					lRet := .F.
					cXmlRet := STR0024 //'Arquivo Inv�lido'
				EndIf
 				Aadd( aCab, { "CTO_FILIAL", xFilial("CTO"), Nil })
				If !Empty(cValInt)
					cMoeda:=aValint[2][3]
			   ElseIf Type("oXmlCTBA140:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text") <> "U"
			   		cMoeda:=Padr(oXmlCTBA140:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text,TAMSX3('CTO_MOEDA')[1])
			   		If CTO->(DbSeek(xFilial('CTO')+cMoeda))
			   			cMoeda:=CriaVar("CTO_MOEDA")
			   		Endif
			   Else
			   		cMoeda:=CriaVar("CTO_MOEDA")
			   Endif
				Aadd( aCab, { "CTO_MOEDA",cMoeda, Nil })
				If Type("oXmlCTBA140:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text") <> "U"
					Aadd( aCab, { "CTO_DESC", oXmlCTBA140:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text, Nil })
			    Endif              
				If Type("oXmlCTBA140:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Symbol:Text") <> "U"
					Aadd( aCab, { "CTO_SIMB", oXmlCTBA140:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Symbol:Text, Nil })
			    Endif  

				MSExecAuto({|x,y| CTBA140(x,y)},aCab,nOpcExec)
                                        	
				If lMsErroAuto
					cLogErro:=""
					aErroAuto := GetAutoGRLog()
					For nCount := 1 To Len(aErroAuto)
						cLogErro += '<Message type="ERROR" code="c2">'+StrTran(StrTran(StrTran(aErroAuto[nCount],"<"," "),"-"," "),"/"," ")+" "+'</Message>'
						
					Next nCount
					// Monta XML de Erro de execu��o da rotina automatica.
					lRet:=.F.                          
					cXmlRet:=cLogErro  
				Else
					// Monta xml RETORNO DO DE/PARA
					If nOpcExec # 5
						  
						cValInt:= C40MontInt(,cMoeda)//(CTO->CTO_FILIAL)+(CTO->CTO_MOEDA)
					    //Inclui ou Altera quando vem de Outro ERP e devolve para o ERP
						If CFGA070Mnt( cMarca, cAlias, cField, cValExt, cValInt )					 //Grava na Tabela XXF
							cXMLRet := "<DestinationInternalID>"+ cValInt +"</DestinationInternalID>"  
							cXMLRet += "<OriginInternalID>"     + cValExt +"</OriginInternalID>"      
						Endif
					
					ElseIf nOpcExec == 5
						lRet:= .T.
						  
					   //Exclui quando vem de outro ERP
						CFGA070Mnt(, cAlias, cField,, cValInt, .T. )  // Deleta o XXF
					EndIf
				Endif
			Else
				lRet := .F.
				cXMLRet := STR0025 //"Falha ao manipular o XML"
			EndIf

	    Case cTypeMessage == EAI_MESSAGE_RESPONSE
 				//-- Quando Recebemos de Fora ent�o fazemos a Gravacao do De/Para Codigo Interno X Codigo Externo  	
				oXmlCTBA140 := XmlParser(cXml, "_", @cError, @cWarning) 
			
				If oXmlCTBA140 <> Nil .And. Empty(cError) .And. Empty(cWarning)
					If Type("oXmlCTBA140:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U" 					
						cMarca :=  oXmlCTBA140:_TotvsMessage:_MessageInformation:_Product:_Name:Text
					EndIf      
				   	If Type("oXmlCTBA140:_TOTVSMessage:_ResponseMessage:_ReturnContent:_OriginInternalID:Text") <> "U"	
				   		cValInt := oXmlCTBA140:_TOTVSMessage:_ResponseMessage:_ReturnContent:_OriginInternalID:Text
				   	EndIf
				   	If Type("oXmlCTBA140:_TOTVSMessage:_ResponseMessage:_ReturnContent:_DestinationInternalID:Text") <> "U"	
				   	    cValExt := oXmlCTBA140:_TOTVSMessage:_ResponseMessage:_ReturnContent:_DestinationInternalID:Text
				   	EndIf 
				   	
					If !Empty(cValExt) .And. !Empty(cValInt)
					    //Inclui ou Altera a Devolu��o do Envio para Outro ERP
					    If !CFGA070Mnt( cMarca, cAlias, cField, cValExt, cValInt )
							lRet    := .F. 
						Else
							lRet    := .T. 
						Endif
					Else
						lRet    := .F. 
					Endif
			   EndIf	
		Case cTypeMessage == EAI_MESSAGE_WHOIS
			cXMLRet := "1.000|2.000|2.001"
	EndCase
		
Case nTypeTrans == TRANS_SEND
	cValInt :=C40MontInt(,CTO->CTO_MOEDA )// xfilial('CTO')+CTO->CTO_MOEDA  
	If !Inclui .And. !Altera
		cEvent := 'delete'
		
		If !Empty(cValInt) 
		   	//Exclui quando vem de outro ERP
	   		CFGA070Mnt(, cAlias, cField,, cValInt, .T. )  // Deleta o XXF
	    Endif			  	
	EndIf

   	M->CTO_MOEDA  := CTO->CTO_MOEDA
   	M->CTO_DESC   := CTO->CTO_DESC
   	M->CTO_SIMB   := CTO->CTO_SIMB 

	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>Currency</Entity>'
	cXMLRet +=     '<Event>' + cEvent + '</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="Code">' + RTrim(M->CTO_MOEDA) + '</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'
	cXMLRet += '<BusinessContent>'
   		
	If lMktPlace
		cXmlRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
   		cXmlRet +=    '<BranchId>' + RTrim(cFilAnt) + '</BranchId>'
		cXmlRet +=    '<CompanyInternalID>' + cEmpAnt + '|' + RTrim(cFilAnt) + '</CompanyInternalID>'
		cXMLRet +=    '<InternalId>' + cEmpAnt + "|" + RTrim(xFilial("CTO")) + "|"+ RTrim(M->CTO_MOEDA) + '</InternalId>'
	Endif
	
	cXMLRet +=	  	'<Code>' + RTrim(M->CTO_MOEDA) + '</Code>'
	cXMLRet +=    '<Description>' + RTrim(M->CTO_DESC) + '</Description>'
	cXMLRet +=    '<Symbol>' + RTrim(M->CTO_SIMB) + '</Symbol>'
	
	If lMktPlace
		cXmlRet +=    '<DecimalPlaces>' + RTrim(cValToChar(CTO->CTO_DECIM)) + '</DecimalPlaces>'
	Endif
	
	cXMLRet += '</BusinessContent>'

EndCase

RestArea(aAReaCTO)
RestArea(aARea)
Return { lRet, cXMLRet }

//-------------------------------------------------------------------
/*{Protheus.doc} C40MontInt
Recebe um registro no Protheus e gera o InternalId deste registro

@param		cFil		Filial do Registro
@Param		cCod	Codigo da moeda


@author  Jandir Deodato
@version P11.8
@since   30/04/13
@return  cRetorno - Retorna o InternalId do registro

@sample  exemplo de retorno - {'Empresa'|'xFilial'|'codigo'}}
								//		01		02				03				
*/			
//-------------------------------------------------------------------
Function C40MontInt(cFil,cCod)
Local cRetCode := ''

Default cFil := xFilial('CTO')

cFil := xFilial('CTO',cFil)

cRetCode := cEmpAnt + '|' + RTrim(cFil) + '|' + Padr(cCod,TamSX3('CTO_MOEDA')[1])

Return cRetCode

//-------------------------------------------------------------------
/*{Protheus.doc} C40GetInt
Recebe um codigo, busca seu internalId e faz a quebra da chave

@param   cCode		 InternalID recebido na mensagem.
@param   cMarca      Produto que enviou a mensagem


@author  Jandir Deodato
@version P11.8
@since   30/04/13
@return  aRetorno Array contendo os campos da chave primaria do titulo a receber,a sequencia da baixa  e o seu internalid.

@sample  exemplo de retorno - {.T., {'Empresa', 'xFilial', 'Codigo' },InternalId}
*/										//   01          02         03         
//-------------------------------------------------------------------

Function C40GetInt(cCode, cMarca)

Local cValInt:=''
Local aRetorno:={}
Local aAux:={}

cValInt:= CFGA070Int(cMarca, 'CTO', 'CTO_MOEDA', cCode)
If !Empty(cValInt)
	aadd(aRetorno,.T.)
	aAux:={cEmpAnt,SubStr(cValInt,1,len(cFilAnt)),SubStr(cValInt,len(cFilant)+1,TamSX3('CTO_MOEDA')[1])}
	aadd(aRetorno,aAux)
	aadd(aRetorno,cValInt)
Else
	aadd(aRetorno,.F.)
Endif

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} v2000

Funcao de integracao com o adapter EAI para envio e recebimento do  cadastro de
Moedas Cont�beis (CTO) utilizando o conceito de mensagem unica.

@param   cXml          Variavel com conteudo xml para envio/recebimento.
@param   nTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Leandro Luiz da Cruz
@version P11
@since   10/07/2012
@return  aRet    - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execu��o da fun��o
         aRet[2] - (caracter) Mensagem Xml para envio

@obs     O m�todo ir� retornar um objeto do tipo TOTVSBusinessEvent caso
         o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
         TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
         O tipo da classe pode ser definido com a fun��o EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------
Function v2000(cXml, nTypeTrans, cTypeMessage, oXml)
   Local cFilBck          := cFilAnt
   Local cAdapter         := "CTBI140"
   Local cXMLRet          := ""
   Local cError           := ""
   Local cWarning         := ""
   Local cLogErro         := ""
   Local cCode            := ""
   Local cProduct         := ""
   Local cValInt          := ""
   Local cValExt          := ""
   Local lRet             := .T.
   Local nOpcx            := 0
   Local nCount           := 0
   Local aMoeda           := {}
   Local aErroAuto        := {}
   Local aAux             := {}
   Local cAlias           := "CTO"
   Local cField           := "CTO_MOEDA"
   Local cEvent           := "upsert"
   Local cVersao          := RTrim(PmsMsgUVer('CURRENCY', 'CTBA140')) //Vers�o da mensagem

   Private lMsErroAuto    := .F.
   Private lAutoErrNoFile := .T.
   Private lMsHelpAuto    := .T.

   AdpLogEAI(1, cAdapter, nTypeTrans, cTypeMessage, cXML)

   If nTypeTrans == TRANS_RECEIVE
      If cTypeMessage == EAI_MESSAGE_BUSINESS
         // Verifica se a marca foi informada
         If Type("oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
            cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
         Else
            lRet    := .F.
            cXmlRet := STR0005 // "A Marca � obrigat�ria!"
            AdpLogEAI(5, cAdapter, cXMLRet, lRet)
            Return {Ret, cXMLRet}
         EndIf
         
         // Verifica se a filial atual � a mesma filial de inclus�o do cadastro
         aAux := IntChcEmp(oXML, cAlias, cProduct)
         If !aAux[1]
           lRet := aAux[1]
           cXmlRet := aAux[2]
           AdpLogEAI(5, "CTBI140", cXMLRet, lRet)
           Return {lRet, cXmlRet}
         EndIf
         
         // Verifica se o InternalId foi informado
         If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
            cValExt := Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
         Else
            lRet    := .F.
            cXmlRet := STR0006 // "O InternalId � obrigat�rio!"
            AdpLogEAI(5, cAdapter, cXMLRet, lRet)
            Return {lRet, cXMLRet}
         EndIf

         // Obt�m o valor interno na tabela XXF (de/para)
         aAux := IntMoeInt(cValExt, cProduct, cVersao)

         // Verifica se o evento � Upsert
         If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
            // Verifica se � Update ou Insert
            If aAux[1]
               nOpcx := 4 // Update
               cCode := aAux[2][3]
            Else
               nOpcx   := 3 // Insert
               cCode   := geraCod()
            Endif
         ElseIf Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
            // Verifica se o registro a ser exclu�do existe na base Protheus
            If aAux[1]
               nOpcx := 5 // Delete
               cCode := aAux[2][3]
            Else
               lRet    := .F.
               cXmlRet := STR0007 // "O registro informado n�o existe na base Protheus"
               AdpLogEAI(5, cAdapter, cXMLRet, lRet)
               Return {lRet, cXMLRet}
            EndIf
         Else
            lRet    := .F.
            cXmlRet := STR0008 // "O evento informado � inv�lido!"
            AdpLogEAI(5, cAdapter, cXMLRet, lRet)
            Return {lRet, cXMLRet}
         Endif

         cValInt := IntMoeExt(, , cCode, cVersao)[2]

         // Armazena a Filial no Array
         aAdd(aMoeda, {"CTO_FILIAL", xFilial(cAlias), Nil})

         // Armazena o C�digo da Moeda no Array
         aAdd(aMoeda, {"CTO_MOEDA", PadR(cCode, TamSX3("CTO_MOEDA")[1]), Nil})

         If nOpcx == 5 // Delete - devera posicionar no registro
          	CTO->(dbSetOrder(1))
          	CTO->(dbSeek(xFilial(cAlias)+PadR(cCode, TamSX3("CTO_MOEDA")[1])))
         EndIf

         // Se o evento � diferente de DELETE
         If nOpcx != 5
            // Verifica se a descri��o da moeda foi informada
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text)
               aAdd(aMoeda, {"CTO_DESC", oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Description:Text, Nil})
            EndIf

            // Verifica se o S�mbolo da moeda foi informado
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Symbol:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Symbol:Text)
               aAdd(aMoeda, {"CTO_SIMB", oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Symbol:Text, Nil})
            EndIf

            // Verifica se a quantidade de casas decimais foi informada
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DecimalPlaces:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DecimalPlaces:Text)
               aAdd(aMoeda, {"CTO_DECIM", Val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_DecimalPlaces:Text), Nil})
            EndIf
         EndIf
         
        AdpLogEAI(4, nOpcx)
        AdpLogEAI(3, "aMoeda: ", aMoeda)
        AdpLogEAI(3, "cValInt: ", cValInt)
        AdpLogEAI(3, "cValExt: ", cValExt)

         // Executa Rotina Autom�tica conforme evento
         MSExecAuto({|x, y| CTBA140(x, y)}, aMoeda, nOpcx)

         // Se a Rotina Autom�tica retornou erro
         If lMsErroAuto
            // Obt�m o log de erros
            aErroAuto := GetAutoGRLog()

            // Percorre o array obtendo os erros
            cXMLRet := '<![CDATA['
            For nCount := 1 to Len(aErroAuto)
               cXmlRet += aErroAuto[nCount] + CRLF
            Next nCount
            cXMLRet += ']]>'

            lRet := .F.
         Else
            // Se o evento � diferente de Delete
            If nOpcx != 5
               // Insere na tabela XXF (de/para)
               CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F.)
               
				// Monta o XML de retorno
	            cXMLRet := "<ListOfInternalId>"
	            cXmlRet +=     "<InternalId>"
	            cXmlRet +=         "<Name>CurrencyInternalId</Name>"
	            cXmlRet +=         "<Origin>" + AdpEscapeChar(cValExt) + "</Origin>"
	            cXmlRet +=         "<Destination>" + cValInt + "</Destination>"
	            cXmlRet +=     "</InternalId>"
	            cXmlRet += "</ListOfInternalId>"
               
            Else
               // Exclui na tabela XXF (de/para)
               CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T.)
            EndIf


         EndIf

         // Retorna o Alias original
         cFilAnt := cFilBck
      ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
         // Se n�o ouve erros na resposta
         If Upper(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
           // Verifica se a marca foi informada
            If Type("oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
               cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
            Else
               lRet    := .F.
               cXmlRet := STR0009 // "Erro no retorno. O Product � obrigat�rio!"
               AdpLogEAI(5, cAdapter, cXMLRet, lRet)
               Return  {Ret, cXMLRet}
            EndIf
				
			if Upper(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_Event:Text) == "UPSERT"
				   // Verifica se o c�digo interno foi informado
	            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text)
	               cValInt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0010 // "Erro no retorno. O OriginalInternalId � obrigat�rio!"
	               AdpLogEAI(5, cAdapter, cXMLRet, lRet)
	               Return  {lRet, cXMLRet}
	            EndIf
	
	            // Verifica se o c�digo externo foi informado
	            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text)
	               cValExt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0011 // "Erro no retorno. O DestinationInternalId � obrigat�rio"
	               AdpLogEAI(5, cAdapter, cXMLRet, lRet)
	               Return {lRet, cXMLRet}
	            EndIf
	
	            // Obt�m a mensagem original enviada
	            If Type("oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
	               cXml := oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0012 // "Conte�do do MessageContent vazio!"
	               AdpLogEAI(5, cAdapter, cXMLRet, lRet)
	               Return  {lRet, cXmlRet}
	            EndIf
	            
	           AdpLogEAI(3, "cValInt: ", cValInt)
	           AdpLogEAI(3, "cValExt: ", cValExt)
	
	            // Faz o parse do XML em um objeto
	            oXml := XmlParser(cXml, "_", @cError, @cWarning)
	
	            // Se n�o houve erros no parse
	            If oXml <> Nil .And. Empty(cError) .And. Empty(cWarning)
                  If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
	                  // Insere / Atualiza o registro na tabela XXF (de/para)
	                  CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F.)
	               ElseIf Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
	                  // Exclui o registro na tabela XXF (de/para)
	                  CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T.)
	               Else
	                  lRet := .F.
	                  cXmlRet := STR0013 // "Evento do retorno inv�lido!"
	                  AdpLogEAI(5, cAdapter, cXMLRet, lRet)
	                  Return {lRet, cXMLRet}
	               EndIf
	            Else
	               lRet    := .F.
	               cXmlRet := STR0014 // "Erro no parser do retorno!"
	               AdpLogEAI(5, cAdapter, cXMLRet, lRet)
	               Return {lRet, cXMLRet}
	            EndIf
			EndIF
         Else
            // Se n�o for array
            If Type("oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
               // Transforma em array
               XmlNode2Arr(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
            EndIf

            // Percorre o array para obter os erros gerados
            For nCount := 1 To Len(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
               cError := oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + CRLF
            Next nCount

            lRet    := .F.
            cXmlRet := cError
         EndIf
      ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
         cXMLRet := "1.000|2.000|2.001"
      EndIf
   ElseIf nTypeTrans == TRANS_SEND
      If Inclui
         AdpLogEAI(4, 3)
      ElseIf Altera
         AdpLogEAI(4, 4)
      Else
         AdpLogEAI(4, 5)
         cEvent := "delete"
      EndIf
      
	  aValInt :=IntMoeExt(cEmpAnt, CTO->CTO_FILIAL, CTO->CTO_MOEDA, cVersao)
	  
	  If aValint[1]
	  	cValInt := aValint[2]
	  EndIf
	
	  If cEvent = "delete"
	  	If !empty(cValInt)
			CFGA070Mnt(, cAlias, cField,, cValInt, .T.) // excluindo da XXF
		EndIf
	  EndIf

      cXmlRet := '<BusinessEvent>'
      cXmlRet +=    '<Entity>' + 'Currency' + '</Entity>'
      cXmlRet +=    '<Event>' + cEvent + '</Event>'
      cXmlRet +=    '<Identification>'
      cXmlRet +=       '<key name="InternalId">' + cValInt + '</key>'
      cXmlRet +=    '</Identification>'
      cXmlRet += '</BusinessEvent>'
      cXmlRet += '<BusinessContent>'
      If cVersao != "2.000"
         cXmlRet += '<CompanyId>' + cEmpAnt + '</CompanyId>'
         cXmlRet += '<BranchId>' + cFilAnt + '</BranchId>'
         cXmlRet += '<CompanyInternalID>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalID>'
      EndIf
      cXmlRet +=    '<Code>' + RTrim(CTO->CTO_MOEDA) + '</Code>'
      cXmlRet +=    '<InternalId>' + cValInt + '</InternalId>'
      cXmlRet +=    '<Description>' + RTrim(CTO->CTO_DESC) + '</Description>'
      cXmlRet +=    '<Symbol>' + AdpEscapeChar(RTrim(CTO->CTO_SIMB)) + '</Symbol>'
      If cVersao != "2.000"
         cXmlRet += '<DecimalPlaces>' + RTrim(cValToChar(CTO->CTO_DECIM)) + '</DecimalPlaces>'
      EndIf
      cXmlRet += '</BusinessContent>'
   EndIf

   AdpLogEAI(5, cAdapter, cXMLRet, lRet)
Return {lRet, cXMLRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} geraCod
Monta incremento para o campo CTO_MOEDA reaproveitando c�digos de
registros exclu�dos.

@param   cAlias Alias da tabela

@author  Leandro Luiz da Cruz
@version P11
@since   10/07/2012
@return  nCod Variavel com o valor gerado
/*/
//-------------------------------------------------------------------
Static Function geraCod()
   Local nCod := 1
   Local lOk  := .T.

   DbSelectArea("CTO")
   CTO->(DbSetOrder(1))
   CTO->(DbGoTop())

   While lOk
      If CTO->(dbSeek(xFilial("CTO") + PadL(cValToChar(nCod), TamSX3("CTO_MOEDA")[1], "0")))
         nCod++
      Else
         lOk := .F.
      EndIf
   End
Return PadL(cValToChar(nCod), TamSX3("CTO_MOEDA")[1], "0")

//-------------------------------------------------------------------
/*/{Protheus.doc} AdpEscapeChar()
Fun��o para substituir os caracteres ASCII 34, 38, 39, 60 e 62 para
serem enviados no xml.

@param   cText Texto a ser formatado.
@param   lHTML Formatar em HTML. Opcional, Defaul .F.

@author  Mateus Gustavo de freitas e Silva
@version P11
@since   13/01/2013
@return  cEscaped Valor formatado.

@Obs     Alterar para a fun��o FwXMLType quando a mesma for corrigida
         pela framework.
/*/
//-------------------------------------------------------------------
Static Function AdpEscapeChar(cText, lHTML)
   Local cEscaped := ""
   Local nI       := 0

   Default lHTML  := .F.

   For nI := 1 To Len (cText)
      Do Case
         Case Asc(SubStr(cText, nI, 1)) == 34
            If lHTML
               cEscaped += '&quot;'
            Else
               cEscaped += '&#34;'
            EndIf
         Case Asc(SubStr(cText, nI, 1)) == 38
            If lHTML
               cEscaped += '&amp;'
            Else
               cEscaped += '&#38;'
            EndIf
         Case Asc(SubStr(cText, nI, 1)) == 39
            cEscaped += '&#39;'
         Case Asc(SubStr(cText, nI, 1)) == 60
            If lHTML
               cEscaped += '&lt;'
            Else
               cEscaped += '&#60;'
            EndIf
         Case Asc(SubStr(cText, nI, 1)) == 62
            If lHTML
               cEscaped += '&gt;'
            Else
               cEscaped += '&#62;'
            EndIf
         Case ASc(SubStr(cText, nI, 1)) == 156
            If lHTML
               cEscaped += '&pound;'
            Else
               cEscaped += '&#163;'
            EndIf
         Case ASc(SubStr(cText, nI, 1)) == 238
            If lHTML
               cEscaped += '&euro;'
            Else
               cEscaped += '&#8364;'
            EndIf
         Otherwise
            cEscaped += SubStr(cText, nI, 1)
      EndCase
   Next nI
Return cEscaped

//-------------------------------------------------------------------
/*/{Protheus.doc} IntMoeExt
Monta o InternalID da Moeda de acordo com o c�digo passado
no par�metro.

@param   cEmpresa   C�digo da empresa (Default cEmpAnt)
@param   cFil       C�digo da Filial (Default cFilAnt)
@param   cMoeda     C�digo da Moeda
@param   cVersao    Vers�o da mensagem �nica (Default 2.000)

@author  Leandro Luiz da Cruz
@version P11
@since   05/02/2013
@return  aResult Array contendo no primeiro par�metro uma vari�vel
         l�gica indicando se o registro foi encontrado.
         No segundo par�metro uma vari�vel string com o InternalID
         montado.

@sample  IntMoeExt(, , '01') ir� retornar {.T., '01|01|01'}
/*/
//-------------------------------------------------------------------
Function IntMoeExt(cEmpresa, cFil, cMoeda, cVersao)
   Local aResult    := {}
   Default cEmpresa := cEmpAnt
   Default cFil     := xFilial('CTO') // Cadastro compartilhado
   Default cVersao  := '2.000'

   If cVersao == '1.000'
      aAdd(aResult, .T.)
      aAdd(aResult, PadR(cFil, TamSX3('CTO_FILIAL')[1]) + PadR(cMoeda, TamSX3('CTO_MOEDA')[1]))
   ElseIf cVersao = '2.000' .Or. cVersao == '2.001'
      aAdd(aResult, .T.)
      aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cMoeda))
   Else
      aAdd(aResult, .F.)
      aAdd(aResult, STR0019 + Chr(10) + STR0023 + " 1.000, 2.000 e 2.001.") // "Vers�o da moeda n�o suportada." "As vers�es suportadas s�o:"
   EndIf
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntMoeInt
Recebe um InternalID e retorna o c�digo da Moeda.

@param   cInternalID InternalID recebido na mensagem.
@param   cRefer      Produto que enviou a mensagem
@param   cVersao     Vers�o da mensagem �nica (Default 2.000)

@author  Leandro Luiz da Cruz
@version P11
@since   05/02/2013
@return  aResult Array contendo no primeiro par�metro uma vari�vel
         l�gica indicando se o registro foi encontrado no de/para.
         No segundo par�metro uma vari�vel array com a empresa,
         filial e o c�digo da moeda.

@sample  IntMoeInt('01|01|01') ir� retornar
{.T., {'01', '01', '01'}}
/*/
//-------------------------------------------------------------------
Function IntMoeInt(cInternalID, cRefer, cVersao)
   Local   aResult  := {}
   Local   aTemp    := {}
   Local   cTemp    := ''
   Local   cAlias   := 'CTO'
   Local   cField   := 'CTO_MOEDA'
   Default cVersao  := '2.000'

   cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)

   If Empty(cTemp)
      aAdd(aResult, .F.)
      aAdd(aResult, STR0020 + " -> Moeda: " + cInternalID) // "Registro n�o encontrado no de/para!"
      
   Else
      If cVersao == '1.000'
         aAdd(aResult, .T.)
         aAdd(aTemp, SubStr(cTemp, 1, TamSX3('CTO_FILIAL')[1]))
         aAdd(aTemp, SubStr(cTemp, TamSX3('CTO_FILIAL')[1] + 1, TamSX3('CTO_MOEDA')[1]))
         aAdd(aResult, aTemp)
         aAdd(aResult, cTemp )

      ElseIf cVersao == '2.000' .Or. cVersao == '2.001'
         aAdd(aResult, .T.)
         aTemp := Separa(cTemp, '|')
         aAdd(aResult, aTemp)
         aAdd(aResult, cTemp )
         
      Else
         aAdd(aResult, .F.)
         aAdd(aResult, STR0019 + Chr(10) + STR0023 + " 1.000, 2.000 e 2.001.") // "Vers�o da moeda n�o suportada." "As vers�es suportadas s�o:"
         
      EndIf
   EndIf

Return aResult
