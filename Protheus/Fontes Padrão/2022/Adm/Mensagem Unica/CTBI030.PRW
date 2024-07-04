#INCLUDE "Protheus.ch"
#INCLUDE "FwAdapterEAI.ch"
#INCLUDE "FwMvcDef.ch"
#INCLUDE "CTBI030.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBI030
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de centro de custos utilizando o conceito de mensagem unica.

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   cTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMsg      Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Leandro Luiz da Cruz
@version P11
@since   13/07/2012
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execuÁ„o da funÁ„o
         aRet[2] - (caracter) Mensagem Xml para envio

@obs     Caso a vers„o da mensagem utilizada (XX4_SNDVER) seja 1.000 ser· chamada a
         funÁ„o v1000 caso seja 2.000 ser· chamada a funÁ„o v2000.
/*/
//------------------------------------------------------------------------------------
Function CTBI030(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

   Local cError   := ""
   Local cWarning := ""	
   Local aRet     := {}
   Local cXMLRet  := ""
   Local lRet     := .T.
   Local cVersao  := ""


   //Valida vers„o de envio e/ou recebimento
   cVersao := StrTokArr(cVersion, ".")[1]
	   
   Private oXml    := Nil

   //Mensagem de Entrada
   If cTypeTrans == TRANS_RECEIVE
      If cTypeMsg == EAI_MESSAGE_BUSINESS .Or. cTypeMsg == EAI_MESSAGE_RESPONSE
         oXml := xmlParser(cXml, "_", @cError, @cWarning)

         If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
            // Vers„o da mensagem
            If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXml:_TOTVSMessage:_MessageInformation:_version:Text)
               cVersao := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
            Else
               lRet    := .F.
               cXmlRet := STR0002 // "Vers„o da mensagem n„o informada!"
               Return {lRet, cXmlRet}
            EndIf
         Else
            lRet    := .F.
            cXmlRet := STR0003 // "Erro no parser!"
            Return {lRet, cXmlRet}
         EndIf
         If cVersao == "1"
            aRet := v1000(cXml, cTypeTrans, cTypeMsg)
         ElseIf cVersao == "2"
            aRet := v2000(cXml, cTypeTrans, cTypeMsg, oXml)
         Else
            lRet    := .F.
            cXmlRet := STR0001 // "A vers„o da mensagem informada n„o foi implementada!"
            Return {lRet, cXmlRet}
         EndIf
      ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
         aRet := v2000(cXml, cTypeTrans, cTypeMsg, oXml)
      Endif
   ElseIf cTypeTrans == TRANS_SEND
   		If Empty(cVersao)
           lRet    := .F.
           cXmlRet := STR0020 //"Vers„o n„o informada no cadastro do adapter."
           Return {lRet, cXmlRet}
        EndIf
        If cVersao == "1"
            aRet := v1000(cXml, cTypeTrans, cTypeMsg)
         ElseIf cVersao == "2"
            aRet := v2000(cXml, cTypeTrans, cTypeMsg, oXml)
         Else
            lRet    := .F.
            cXmlRet := STR0001 // "A vers„o da mensagem informada n„o foi implementada!"
            Return {lRet, cXmlRet}
         EndIf
         Else
         	ConOut(STR0022) //"A lib da framework Protheus est· desatualizada!"
         	aRet := v1000(cXml, cTypeTrans, cTypeMsg) //Se o campo vers„o n„o existir chamar a vers„o 1
   EndIf
   
   		lRet    := aRet[1]
   		cXMLRet := aRet[2]
   
Return {lRet, cXmlRet}


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ CTBI030 ≥ Autor ≥ Wilson P. de Godoi    ≥ Data ≥ 28/02/12  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ M.U Castramento de Centro de Custo                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ CTBI030()                                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ Nenhum                                                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ Nenhum                                                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±≥         ATUALIZACOES SOFRIDAS DESDE A CONSTRUÄAO INICIAL.             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function v1000( cXml, nType, cTypeMsg )

Local lRet := .T.
Local cXmlRet := ""
Local cEvent := 'upsert'
Local cErroXml := ""
Local cWarnXml := ""
Local oXmlBusMsg := nil
Local aCTTproc := {}
Local aSave := GetArea()
Local aValInt:={}
Local nOpcExec := 0
Local cMarca:= ''
Local cAlias:= 'CTT'
Local cField:= 'CTT_CUSTO'
Local cValInt:= ''
Local cValExt:= ''
Local aSaveCTT
Private oXmlI030 := Nil

dbSelectArea( 'CTT' )
aSaveCTT := CTT->( GetArea() )
CTT->( dbSetOrder(1))

Do Case
    // verificaÁ„o do tipo de transaÁ„o recebimento ou envio
    // trata o envio
    Case ( nType == TRANS_SEND )
        //  Tratar o envio inserindo as informaÁıes
		 cValInt := IntCusExt(, CTT->CTT_FILIAL, CTT->CTT_CUSTO, '1.000')[2]

        If ( !INCLUI .AND. !ALTERA )
            cEvent := 'delete'
            If FindFunction('CFGA070Mnt')
                If !Empty(cValInt)
                    //Exclui quando vem de outro ERP
                    CFGA070Mnt(, cAlias, cField,, cValInt, .T. )  // Deleta o XXF
                Endif
            Endif
        EndIf

        M->CTT_CUSTO    := CTT->CTT_CUSTO
        M->CTT_BLOQ     := CTT->CTT_BLOQ
        M->CTT_CLASSE   := CTT->CTT_CLASSE
        M->CTT_DESC01   := CTT->CTT_DESC01
        M->CTT_RES      := CTT->CTT_RES

        cXMLRet := '<BusinessEvent>'
        cXMLRet +=     '<Entity>COSTCENTER</Entity>'
        cXMLRet +=     '<Event>' + cEvent + '</Event>'  //vari·vel upsert para atualizaÁ„o ou deleÁ„o
        cXMLRet +=      '<Identification>'
        cXMLRet +=         '<key name="InternalId">' + cValInt + '</key>'
        cXMLRet +=     '</Identification>'
        cXMLRet += '</BusinessEvent>'
        cXMLRet += '<BusinessContent>'
        cXMLRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
        cXMLRet +=    '<Code>' + _NoTags(RTrim(M->CTT_CUSTO)) + '</Code>'
        If M->CTT_BLOQ == '2'
            cXMLRet +=    '<RegisterSituation>Active</RegisterSituation>'
        Else
            cXMLRet +=    '<RegisterSituation>Inactive</RegisterSituation>'
        Endif
        cXMLRet +=    '<Name>' + _NoTags(RTrim(M->CTT_DESC01)) + '</Name>'
        cXMLRet +=    '<AnalyticalOrSynthetic>' + _NoTags(RTrim(M->CTT_CLASSE)) + '</AnalyticalOrSynthetic>'
        cXMLRet +=    '<Class>' + _NoTags(RTrim(M->CTT_CLASSE)) + '</Class>'
        // 2 = Analitica  Obrigado ter CTT_RES
        // 1 = Sintetica  Obrigado N„o ter CTT_RES
        cXMLRet +=    '<ShortCode>' + _NoTags(RTrim(M->CTT_RES)) + '</ShortCode>'
        cXMLRet += '</BusinessContent>'
        // verificaÁ„o do tipo de transaÁ„o recebimento ou envio
        // trata o recebimento
    Case ( nType == TRANS_RECEIVE )

        Do Case
            Case ( cTypeMsg == EAI_MESSAGE_WHOIS )
                cXmlRet := '1.000|2.000'
            Case ( cTypeMsg == EAI_MESSAGE_RESPONSE )
                //-- Quando Recebemos de Fora ent„o fazemos a Gravacao do De/Para Codigo Interno X Codigo Externo
                If FindFunction('CFGA070Mnt')
                    oXmli030 := XmlParser(cXml, "_", @cErroXML, @cWarnXML)

                    If oXmli030 <> Nil .And. Empty(cErroXML) .And. Empty(cWarnXML)

                        If Type("oXmli030:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U"
                            cMarca :=  oXmlI030:_TotvsMessage:_MessageInformation:_Product:_Name:Text
                        EndIf
                        If Type("oXmli030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_OriginInternalID:Text") <> "U"
                            cValInt := oXmlI030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_OriginInternalID:Text
                        EndIf
                        If Type("oXmlI030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_DestinationInternalID:Text") <> "U"
                            cValExt := oXmlI030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_DestinationInternalID:Text
                        EndIf

                        If !Empty(cValExt) .And. !Empty(cValInt)
                            //Inclui ou Altera a DevoluÁ„o do Envio para Outro ERP
                            CFGA070Mnt( cMarca, cAlias, cField, cValExt, cValInt )
                        Endif
                     EndIf
                EndIf

            Case ( cTypeMsg == EAI_MESSAGE_BUSINESS )
                oXmlI030 := XmlParser(cXml, "_", @cErroXml, @cWarnXml)

                If oXmlI030 <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)

                    If ( XmlChildEx( oXmlI030:_TOTVSMessage, '_BUSINESSMESSAGE' ) <> nil )
                        oXmlBusMsg := oXmlI030:_TOTVSMessage:_BusinessMessage

                        // Recebe Nome do Produto (ex: RM ou PROTHEUS) e guarda na variavel cMarca
                        If Type("oXmli030:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U"
                            cMarca :=  oXmLi030:_TotvsMessage:_MessageInformation:_Product:_Name:Text
                        EndIf
                        // Recebe o codigo da Conta no Cadastro externo e guarda na variavel cValExt
                        If Type("oXmli030:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_key:Text") <> "U"
                            cValExt := oXmli030:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_key:Text
                        EndIf
                        aValInt:=IntCusInt(cValExt, cMarca, '1.000')
                        If Upper(oXmli030:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
                                If aValInt[1]
                                	CTT->(dbSeek(aValInt[2][1]+aValInt[2][2]))
                                	nOpcExec:= 4
                                Else
                                	nOpcExec:=3
                                Endif
                        ElseIF aValInt[1]
                           	nOpcExec:= 5
                       Else
                          lRet := .F.
                   		 cXmlRet:='<Message type="ERROR" code="c2">'+STR0010+'</Message>'//centro de custo nao informado
                       Endif
						If lRet
	                        aCTTproc := UPSERTCTT( oXmlBusMsg, nOpcExec, cMarca, cAlias, cField, cValExt, aValInt )
	                        lRet    := aCTTproc[1]
	                        cXmlRet := aCTTproc[2]
	               		 Endif
                    EndIf
                Else
                    lRet := .F.
                    cXmlRet:='<Message type="ERROR" code="c2">'+STR0003+'</Message>'//erro no parser
                EndIf
        EndCase
EndCase
RestArea(aSaveCTT)
RestArea( aSave )
cXmlRet:=EncodeUTF8(cXmlRet)
Return { lRet, cXmlRet }

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥UPSERTCTT ∫Autor  ≥Microsiga           ∫ Data ≥  21/12/2011 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Insere os dados na tabela CTT nos casos de inserÁ„o e       ∫±±
±±∫          ≥alteraÁ„o dos dados constantes no XML.                      ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function UPSERTCTT ( oObjXml1, nOpcExec, cMarca, cAlias, cField, cValExt, aValInt )
Local aErrorlog:= {}
Local nCount:= 0
Local lRet := .T.
Local aCab := {}
Local cValInt:=''
Local cXmlRet := ""
Local cCusto:=''
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
Private lAutoErrNoFile := .T.
Private oObjXml:=oObjXml1
  BEGIN TRANSACTION

    If Type("oObjXml:_BusinessContent:_Code:Text") <> "U"
        If nOpcExec <> 3
           	If aValInt[1]
           		cCusto:=aValint[2][2]
           	Endif
            Aadd( aCab, { "CTT_CUSTO",cCusto, Nil })
        Else
            cCusto:= SubStr(oObjXml:_BusinessContent:_Code:Text,1,TamSX3("CTT_CUSTO")[1])

            //Retira os eventuais pontos do codigo, preservando a mascara do Protheus
           	cCusto := PADR(Replace(cCusto,".",""),TamSX3("CTT_CUSTO")[1])

            While .T.
                If CTT->(DbSeek(xFilial("CTT")+cCusto))
                    cCusto:=GetSXeNum("CTT","CTT_CUSTO")
                    ConfirmSX8()
                Else
                    Exit
                Endif
            Enddo
            Aadd( aCab, { "CTT_CUSTO",cCusto, Nil })
        Endif
    Endif
    If Type("oObjXml:_BusinessContent:_RegisterSituation:Text") <> "U"
        If oObjXml:_BusinessContent:_RegisterSituation:Text == 'Active'
            Aadd( aCab, { "CTT_BLOQ", '2', Nil })
        Else
            Aadd( aCab, { "CTT_BLOQ", '1', Nil })
        Endif
    Endif
    If Type("oObjXml:_BusinessContent:_Name:Text") <> "U"
        Aadd( aCab, { "CTT_DESC01", oObjXml:_BusinessContent:_Name:Text, Nil })
    Endif

    // OBSREVA«√O: Se a Classe For 2 È obrigatÛrio ter ShortCode se For 1 È ObrigatÛrio ser Branco
    If Type("oObjXml:_BusinessContent:_AnalyticalOrSynthetic:Text") <> "U"
        Aadd( aCab, { "CTT_CLASSE", oObjXml:_BusinessContent:_AnalyticalOrSynthetic:Text, Nil })
    Endif
    If Type("oObjXml:_BusinessContent:_ShortCode:Text") <> "U"
        Aadd( aCab, { "CTT_RES", oObjXml:_BusinessContent:_ShortCode:Text, Nil })
    Endif

    MSExecAuto({|x,y| CTBA030(x,y)},aCab,nOpcExec)

    If lMsErroAuto
        cLogErro:=""
        aErroAuto := GetAutoGRLog()
        For nCount := 1 To Len(aErroAuto)
            cLogErro += '<Message type="ERROR" code="c2">'+StrTran(StrTran(StrTran(aErroAuto[nCount],"<"," "),"-"," "),"/"," ")+" "+'</Message>'
        Next nCount
        // Monta XML de Erro de execuÁ„o da rotina automatica.
        lRet:=.F.
        cXmlRet:=cLogErro
    Else
        // Monta xml RETORNO DO DE/PARA
        If nOpcExec # 5
            If FindFunction('CFGA070Mnt')
					If nOpcexec==3
						cValInt:=IntCusExt(, , cCusto, '1.000')[2]
					Else
						cValInt:=aValInt[3]
					Endif

					CFGA070Mnt( cMarca, cAlias, cField, cValExt, cValInt ) //Grava na Tabela XXF
					lRet:= .T.
					cXMLRet += "<DestinationInternalID>"+ cValInt +"</DestinationInternalID>"  //-- Valor recebido na tag "BusinessMessage:BusinessContent:Code"
					cXMLRet += "<OriginInternalID>"     + cValExt +"</OriginInternalID>"       //-- Valor gerado
            Endif
        ElseIf nOpcExec == 5
                lRet:= .T.
                If FindFunction('CFGA070Mnt')
                	cValInt:=aValInt[3]
                	//Exclui quando vem de outro ERP
                     CFGA070Mnt(, cAlias, cField,, cValInt, .T. )  // Deleta o XXF
                Endif
        EndIf
    EndIf
  END TRANSACTION
Return { lRet, cXmlRet }

//-------------------------------------------------------------------
/*/{Protheus.doc} v2000
Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de centro de custos utilizando o conceito de mensagem unica.

@param   cXML          Variavel com conteudo xml para envio/recebimento.
@param   cTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMsg      Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Leandro Luiz da Cruz
@version P11
@since   13/07/2012
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execuÁ„o da funÁ„o
         aRet[2] - (caracter) Mensagem Xml para envio
/*/
//------------------------------------------------------------------------------------
Static Function v2000(cXml, cTypeTrans, cTypeMsg, oXml)
   Local lRet               := .T.
   Local cXmlRet            := ""
   Local cValInt            := ""
   Local cValExt            := ""
   Local cProduct           := ""
   Local cAlias             := "CTT"
   Local cField             := "CTT_CUSTO"
   Local nOpcx              := 0
   Local cEvent             := "upsert"
   Local nCount             := 0
   Local aCentroCusto       := {}
   Local aErroAuto          := {}
   Local cCode              := ""
   Local oXmlRet            := Nil
   Local cError             := ""
   Local cWarning           := ""
   Local xAux 				:= Nil
   Local cXMLOri				:= ""

	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private oXml030        := oXml

   If cTypeTrans == TRANS_RECEIVE
      If cTypeMsg == EAI_MESSAGE_BUSINESS
         // Verifica se a marca foi informada
         If Type("oXml030:_TotvsMessage:_MessageInformation:_Product:_Name:Text") != "U" .And. ;
         	 !Empty(oXml030:_TotvsMessage:_MessageInformation:_Product:_Name:Text)

            cProduct :=  oXml030:_TotvsMessage:_MessageInformation:_Product:_Name:Text
         Else
            lRet    := .F.
            cXmlRet := STR0007 // "O produto È obrigatÛrio!"
            Return {lRet, cXmlRet}
         EndIf

         // Verifica se o InternalId foi informado
         If Type("oXml030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. ;
         	 !Empty(oXml030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)

            cValExt := oXml030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
         Else
            lRet    := .F.
            cXmlRet := STR0008 // "O InternalId È obrigatÛrio!"
            Return {lRet, cXmlRet}
         EndIf

         // Verifica se o cÛdigo do centro de custo foi informado
         If Type("oXml030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text") != "U" .And. ;
         	 !Empty(oXml030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text)

            cCode := oXml030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text

         Else
            lRet    := .F.
            cXmlRet := STR0009 // "O cÛdigo È obrigatÛrio!"
            Return {lRet, cXmlRet}
         EndIf

         dbSelectArea(cAlias)
         CTT->(dbSetOrder(1)) // CTT_FILIAL + CTT_CUSTO

         // ObtÈm o valor interno da tabela XXF (de/para)
         xAux := IntCusInt( cValExt, cProduct, "2.000")

		If xAux[1]
			cValInt := xAux[2, 2] + xAux[2, 3]
		EndIf

         // Se o evento È upsert
         If Upper(oXml030:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"

            // Se o registro existe
            If !Empty(cValInt) .And. CTT->( DbSeek( cValInt ) )
               nOpcx := 4 // Update
               cCode := CTT->CTT_CUSTO
               aAdd(aCentroCusto, {"CTT_CUSTO", cCode, Nil}) // CÛdigo do centro de custo
            Else

               nOpcx := 3 // Insert
               cValInt := cEmpAnt + xFilial(cAlias) + cCode
            	 aAdd(aCentroCusto, {"CTT_CUSTO", PADR( cCode, TamSX3("CTT_CUSTO")[1] ), Nil}) // CÛdigo do centro de custo
            EndIf


         // Se o evento È delete
         ElseIf Upper(oXml030:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
            // Se o registro existe
            If !Empty(cValInt) .And. CTT->( DbSeek( cValInt ) )
               nOpcx := 5 // Delete
               aAdd(aCentroCusto, {"CTT_CUSTO", CTT->CTT_CUSTO, Nil}) // CÛdigo do centro de custo
            Else
               lRet := .F.
               cXmlRet := STR0010 + " -> " + cValExt // "O centro de custo n„o foi encontrado!"
               Return {lRet, cXmlRet}
            EndIf
         Else
            lRet    := .F.
            cXmlRet := STR0011 // "O evento informado È inv·lido!"
            Return {lRet, cXmlRet}
         EndIf

         // Se n„o for exclus„o
         If nOpcx != 5
            If Type("oXml030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterSituation:Text") != "U" .And. ;
            	 !Empty(oXml030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterSituation:Text)
               aAdd(aCentroCusto, {"CTT_BLOQ" ,  IIf(Upper(oXml030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterSituation:Text) == "ACTIVE", "2", "1"), Nil}) //
            Else
               lRet := .F.
               cXmlRet := STR0012 // "A situaÁ„o do centro de custo È obrigatÛria!"
               Return {lRet, cXmlRet}
            EndIf

            // Verifica se a nomenclatura do centro de custo foi informada
            If Type("oXml030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text") != "U" .And. ;
            	 !Empty(oXml030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text)
               aAdd(aCentroCusto, {"CTT_DESC01", oXml030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text, Nil}) // Nome do centro de custo
            Else
               lRet    := .F.
               cXmlRet := STR0013 // "O nome È obrigatÛrio!"
               Return {lRet, cXmlRet}
            EndIf

            // Verifica se a classe do centro de custo foi informada
            If Type("oXml030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Class:Text") != "U" .And. ;
            	 !Empty(oXml030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Class:Text)

               aAdd(aCentroCusto, {"CTT_CLASSE", oXml030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Class:Text, Nil}) // Classe do centro de custo - AnalÌtico/SintÈtico
            Else
               aAdd(aCentroCusto, {"CTT_CLASSE", "2", Nil}) // Classe do centro de custo - AnalÌtico/SintÈtico
            Endif

            aAdd(aCentroCusto, {"CTT_RES", PADR( oXml030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShortCode:Text, TamSX3("CTT_RES")[1] ), Nil} )

            // Verifica se o centro de custo superior foi informado
            If Type("oXml030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TopCode:Text") != "U"
               aAdd(aCentroCusto, {"CTT_CCSUP", oXml030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_TopCode:Text, Nil}) // Centro de custo superior.
            Endif
         EndIf

         // Executa comando para insert, update ou delete conforme evento
         MSExecAuto( {|x, y| CTBA030(x, y) }, aCentroCusto, nOpcx )

         // Se houve erros no processamento do MSExecAuto
         If lMsErroAuto

            lRet := .F.

			// | Workaround | ObtÈm o array com os erros que foram gerados durante a execuÁ„o da rotina MSExecAuto
			aErroAuto := GetAutoGRLog()

            For nCount := 1 To Len(aErroAuto)
               cXMLRet += StrTran( StrTran( StrTran( StrTran( StrTran( aErroAuto[nCount], CHR(10), "" ), CHR(13), "" ), "<", "" ), "/", "" ), ">", "" ) + "|"
            Next nCount
         Else

         	cValInt := IntCusExt( , CTT->CTT_FILIAL, RTrim(CTT->CTT_CUSTO), "2.000" )[2]

            If nOpcx != 5 // Se o evento È diferente de delete
               // Grava o registro na tabela XXF (de/para)
               CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt )

	            // Monta o XML de retorno
	            cXMLRet := "<ListOfInternalId>"
	            cXMLRet +=     "<InternalId>"
	            cXMLRet +=         "<Name>CostCenter</Name>"
	            cXMLRet +=         "<Origin>" + cValExt + "</Origin>" // Valor recebido na tag
	            cXMLRet +=         "<Destination>" + cValInt + "</Destination>" // Valor XXF gerado
	            cXMLRet +=     "</InternalId>"
	            cXMLRet += "</ListOfInternalId>"

            Else
               // Exclui o registro na tabela XXF (de/para)
               CFGA070Mnt(, cAlias, cField,, cValInt, .T.)
            EndIf

         EndIf
      ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE

         // Se n„o houve erros na resposta
         If Upper(oXml030:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
            // Verifica se a marca foi informada
            If Type("oXml030:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. ;
            	 !Empty(oXml030:_TOTVSMessage:_MessageInformation:_Product:_name:Text)

               cProduct := oXml030:_TOTVSMessage:_MessageInformation:_Product:_name:Text
            Else
               lRet    := .F.
               cXmlRet := STR0014 + "|" // "Erro no retorno. O Product È obrigatÛrio!"
               Return {Ret, cXmlRet}
            EndIf

            // Se n„o for array e existir, transforma a estrutura em array
            cEvent := Type("oXml030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId")
            If cEvent <> "U" .And. cEvent <> "A"
               // Transforma em array
               XmlNode2Arr(oXml030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId, "_InternalId")

	            // Verifica se o cÛdigo interno foi informado
	            If Type("oXml030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text") != "U" .And. ;
	            	 !Empty(oXml030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text)

	               cValInt := oXml030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Origin:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0015 // "Erro no retorno. O OriginalInternalId È obrigatÛrio!"
	               Return {lRet, cXmlRet}
	            EndIf

	            // Verifica se o cÛdigo externo foi informado
	            If Type("oXml030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text") != "U" .And. ;
	            	 !Empty(oXml030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text)

	               cValExt := oXml030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId[1]:_Destination:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0016 // "Erro no retorno. O DestinationInternalId È obrigatÛrio"
	               Return {lRet, cXmlRet}
	            EndIf

				//ObtÈm a mensagem original enviada
				If Type("oXml030:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") != "U" .And. !Empty(oXml030:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
					cXMLOri := oXml030:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
				EndIf

				//Faz o parse do XML em um objeto
				oXml030Ori := XmlParser(cXMLOri, "_", @cError, @cWarning)

				//Se n„o houve erros no parse
				If oXml030Ori != Nil .And. Empty(cError) .And. Empty(cWarning)
					If !Empty( cProduct ) .And. !Empty( cValInt ) .And. !Empty( cValExt )
						If Upper(oXml030Ori:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
							CFGA070Mnt( cProduct, cAlias, cField, cValExt, cValInt, .F.,1)
						ElseIf Upper(oXml030Ori:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
							CFGA070Mnt( cProduct, cAlias, cField, cValExt, cValInt, .T.,1)
						EndIf
					Endif
				EndIf
			EndIf
         Else
            // Se n„o for array
            If Type("oXml030:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
               // Transforma em array
               XmlNode2Arr(oXml030:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
            EndIf

            // Percorre o array para obter os erros gerados
            For nCount := 1 To Len(oXml030:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
               cError := oXml030:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + "|"
            Next nCount

            lRet    := .F.
            cXmlRet := cError
         EndIf

      ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
         cXMLRet := "1.000|2.000|2.001|2.002"
      EndIf

   ElseIf cTypeTrans == TRANS_SEND

      cValInt := IntCusExt( , CTT->CTT_FILIAL, _NoTags( RTrim( CTT->CTT_CUSTO ) ), "2.000" )[2]

      If !Inclui .And. !Altera
         cEvent  := 'delete'

         CFGA070MNT( , "CTT", "CTT_CUSTO", , cValInt, .T. )
      EndIf

      cXMLRet := '<BusinessEvent>'
      cXMLRet +=    '<Entity>' + 'COSTCENTER' + '</Entity>'
      cXMLRet +=    '<Event>' + cEvent + '</Event>' //vari·vel upsert para atualizaÁ„o ou deleÁ„o
      cXMLRet +=    '<Identification>'
      cXMLRet +=       '<key name="InternalId">' + cValInt + '</key>'
      cXMLRet +=    '</Identification>'
      cXMLRet += '</BusinessEvent>'
      cXMLRet += '<BusinessContent>'
      cXMLRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
      cXMLRet +=    '<BranchId>' + cFilAnt + '</BranchId>'
      cXMLRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
      cXMLRet +=    '<Code>' + _NoTags( AllTrim( CTT->CTT_CUSTO ) ) + '</Code>'
      cXMLRet +=    '<InternalId>' + cValInt + '</InternalId>'
      cXMLRet +=    '<RegisterSituation>' + If(CTT->CTT_BLOQ == '2', 'Active', 'Inactive') + '</RegisterSituation>'
      cXMLRet +=    '<Name>' + _NoTags( AllTrim( CTT->CTT_DESC01 ) ) + '</Name>'
      cXMLRet +=    '<ShortCode>' + _NoTags( AllTrim( CTT->CTT_RES ) ) + '</ShortCode>'
      cXMLRet +=    '<Class>' + AllTrim(CTT->CTT_CLASSE) + '</Class>'
      cXMLRet +=    '<TopCode>'   + _NoTags( AllTrim( CTT->CTT_CCSUP ) ) + '</TopCode>'
      cXMLRet += '</BusinessContent>'
   EndIf

Return {lRet, cXmlRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} IntCusExt
Monta o InternalID do Centro de Custo de acordo com o cÛdigo passado
no par‚metro.

@param   cEmpresa   CÛdigo da empresa (Default cEmpAnt)
@param   cFil       CÛdigo da Filial (Default cFilAnt)
@param   cCCusto    CÛdigo do Centro de Custo
@param   cVersao    Vers„o da mensagem ˙nica (Default 2.000)

@author
@version P11
@since   30/01/2013
@return  aResult Array contendo no primeiro par‚metro uma vari·vel
         lÛgica indicando se o registro foi encontrado.
         No segundo par‚metro uma vari·vel string com o InternalID
         montado.

@sample  IntCusExt(, , '40') ir· retornar {.T., '01|01|40'}
/*/
//-------------------------------------------------------------------
Function IntCusExt(cEmpresa, cFil, cCCusto, cVersao)
   Local aResult    := {}
   Default cEmpresa := cEmpAnt
   Default cFil     := xFilial('CTT')
   Default cVersao  := '2.000'

   If cVersao == '1.000'
      aAdd(aResult, .T.)
      aAdd(aResult, PadR(cFil, TamSX3('CTT_FILIAL')[1]) + PadR(cCCusto, TamSX3('CTT_CUSTO')[1]))
   ElseIf cVersao == '2.000'
      aAdd(aResult, .T.)
      aAdd(aResult, cEmpresa + '|' + PadR(cFil, TamSX3('CTT_FILIAL')[1]) + '|' + AllTrim(cCCusto))
   Else
      aAdd(aResult, .F.)
      aAdd(aResult, STR0025 + Chr(10) + STR0026) //"Vers„o da mensagem Centro de Custo n„o suportada." + "As versıes suportadas s„o: 1.000|2.000"
   EndIf
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntCusInt
Recebe um InternalID e retorna o cÛdigo do Centro de Custo.

@param   cInternalID InternalID recebido na mensagem.
@param   cRefer      Produto que enviou a mensagem
@param   cVersao     Vers„o da mensagem ˙nica (Default 2.000)

@author  Leandro Luiz da Cruz
@version P11
@since   05/02/2013
@return  aResult Array contendo no primeiro par‚metro uma vari·vel
         lÛgica indicando se o registro foi encontrado no de/para.
         No segundo par‚metro uma vari·vel array com a empresa,
         filial e o cÛdigo do centro de custo.

@sample  IntLocInt('01|01|40', 'RM') ir· retornar {.T., {'01', '01', '40       '}}
//adicionada para o retorno da versao 1.000 o internalid
//Vesao 1.000 retornar· {.T., {xFilial,Centro de Custo},InternalId}
/*/
//-------------------------------------------------------------------
Function IntCusInt(cInternalID, cRefer, cVersao)
   Local   aResult  := {}
   Local   aTemp    := {}
   Local   cTemp    := ''
   Local   cAlias   := 'CTT'
   Local   cField   := 'CTT_CUSTO'
   Default cVersao  := '2.000'

   cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)

   If Empty(cTemp)
      aAdd(aResult, .F.)
      aAdd(aResult, STR0023 + AllTrim(cInternalID) + STR0024) //"Centro de Custo " + " n„o encontrado no de/para!"
   Else
      If cVersao == '1.000'
         aAdd(aResult, .T.)
         aAdd(aTemp, SubStr(cTemp, 1, Len(cFilAnt)))
         aAdd(aTemp, SubStr(cTemp, Len(cFilAnt)+1, TamSX3('CTT_CUSTO')[1]))
         aAdd(aResult, aTemp)
         aAdd(aResult,cTemp)
      ElseIf cVersao == '2.000'
         aAdd(aResult, .T.)

         aTemp := Separa( cTemp, "|", .T. )
         aAdd(aResult, aTemp)
      Else
         aAdd(aResult, .F.)
         aAdd(aResult, STR0025 + Chr(10) + STR0026) //"Vers„o da mensagem Centro de Custo n„o suportada." + "As versıes suportadas s„o: 1.000|2.000"
      EndIf
   EndIf
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataResp
	Trata a resposta da aplicaÁ„o destino para gravaÁ„o do De/Para

@since 26/06/2013
@version P11
@params 	lProcOk 	Status do processamento (referÍncia)
@params 	cMsgRet 	Mensagem de retorno do processamento (referÍncia)
@params 	cXml    	Mensagem da response para tratamento

/*/
//-------------------------------------------------------------------
Static Function TrataResp( lProcOk, cMsgRet, cXml )

Local oObjXml 	:= Nil
Local cXmlErro 	:= ""
Local cXmlWarn 	:= ""
Local nZ 		:= 0
Local cMarca 	:= ""

oObjXml := XmlParser( cXml, "_", @cXmlErro, @cXmlWarn )

If oObjXml <> Nil .And. Empty( cXmlErro ) .And. Empty( cXmlWarn )

	cMarca := oObjXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text

	If XmlChildEx( oObjXml:_TotvsMessage:_ResponseMessage:_ProcessingInformation, "_STATUS" ) <> Nil .And. ;
		Upper( oObjXml:_TotvsMessage:_ResponseMessage:_ProcessingInformation:_Status:Text ) == "OK"

		oObjXml := XmlChildEx( oObjXml:_TotvsMessage:_ResponseMessage:_ReturnContent, "_LISTOFINTERNALID" )

		If oObjXml <> Nil

			If XmlChildEx( oObjXml, "_INTERNALID" ) <> Nil

				If Valtype( oObjXml:_InternalId ) <> "A"
					XmlNode2Arr( oObjXml:_InternalId, "_InternalId" )
				EndIf

				For nZ := 1 To Len( oObjXml:_InternalId )

					If XmlChildEx( oObjXml:_InternalId[nZ], "_NAME" ) <> Nil .And. ;
						Upper( oObjXml:_InternalId[nZ]:_Name:Text ) == "COSTCENTER" .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_ORIGIN" ) <> Nil .And. ;
						XmlChildEx( oObjXml:_InternalId[nZ], "_DESTINATION" ) <> Nil

						CFGA070Mnt( cMarca, 'CTT', 'CTT_CUSTO', ;
							oObjXml:_InternalId[nZ]:_Destination:Text, ;
							oObjXml:_InternalId[nZ]:_Origin:Text )

						Exit
					EndIf
				Next nZ

			Else

				lProcOk := .F.
				cMsgRet := STR0028 // "N„o conte˙do de retorno para cadastro de de-para"

			EndIf

		Else

			lProcOk := .F.
			cMsgRet := STR0029 // "N„o È possÌvel gravar de-para por causa de erro na leitura do retorno"

		EndIf

	Else

		lProcOk 	:= .F.
		cMsgRet 	:= STR0030 + "|"  // "Erro no processamento pela outra aplicaÁ„o"

		If XmlChildEx( oObjXml:_TotvsMessage:_ResponseMessage:_ProcessingInformation, "_LISTOFMESSAGES" ) <> Nil
			oObjXml := oObjXml:_TotvsMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages

			If XmlChildEx( oObjXml, "_MESSAGE" ) <> Nil

				If Valtype( oObjXml:_Message ) <> "A"
					XmlNode2Arr( oObjXml:_Message, "_Message" )
				EndIf

				For nZ := 1 To Len( oObjXml:_Message )

					cMsgRet += Alltrim( oObjXml:_Message[nZ]:Text ) + "|"

				Next nZ
			Else

				lProcOk := .F.
				cMsgRet := STR0031 // "Erro no processamento, mas sem detalhes do erro pela outra aplicaÁ„o"

			EndIf

		EndIf

	EndIf

Else
	lProcOk 	:= .F.
	cMsgRet 	:= STR0032 + "|" + cXmlErro + "|" + cXmlWarn // "Falha na leitura da resposta, de-para n„o ser· gravado"
EndIf

oObjXml := Nil
DelClassIntF()

Return
