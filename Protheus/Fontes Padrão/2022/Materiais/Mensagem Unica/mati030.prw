#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "MATI030.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MATI030
Funcao de integracao com o adapter EAI para recebimento do cadastro de
Cliente (SA1) utilizando o conceito de mensagem unica.

@param   cXml				Vari·vel com conte˙do XML para envio/recebimento.
@param   nTypeTrans		Tipo de transaÁ„o. (Envio/Recebimento)
@param   cTypeMessage		Tipo de mensagem. (Business Type, WhoIs, etc)
@param   cVersion			Vers„o da Mensagem ⁄nica TOTVS
@param   cTransaction		Informa qual o nome da mensagem iniciada no adapter. Ex. "CUSTOMERVENDOR". Esta informaÁ„o È importante quando temos a mesma rotina cadastrada para mais de uma mensagem.

@author  Leandro Luiz da Cruz
@version P11
@since   29/11/2012 - 15:32
@return  lRet - (boolean)  Indica o resultado da execuÁ„o da funÁ„o
         cXmlRet - (caracter) Mensagem XML para envio
/*/
//-------------------------------------------------------------------------------------------------
Function MATI030(cXML, nTypeTrans, cTypeMessage, cVersion, cTransaction)
Local cError   		:= ""
Local cWarning 		:= ""
Local cVersao  		:= ""
Local lRet     		:= .T.
Local cXmlRet  		:= ""
Local aRet     		:= {}
Local cBuild   		:= ""
Local cRotina  		:= IIF(MA030IsMVC(),"CRMA980","MATA030")
Local cMessageName	:= "CUSTOMERVENDOR"

Private oXml    		:= Nil

//Mensagem de Entrada
If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS .Or. cTypeMessage == EAI_MESSAGE_RESPONSE
		oXml := xmlParser(cXml, "_", @cError, @cWarning)

		If oXml != Nil .And. Empty(cError) .And. Empty(cWarning)
			// Vers„o da mensagem
			If Type("oXml:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .Or. !Empty(oXml:_TOTVSMessage:_MessageInformation:_version:Text)
				cVersao := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
				cBuild := StrTokArr(oXml:_TOTVSMessage:_MessageInformation:_version:Text, ".")[2]
			Else
				lRet    := .F.
				cXmlRet := STR0005 // "Vers„o da mensagem n„o informada!"
				Return {lRet, cXmlRet}
			EndIf
		Else
			lRet    := .F.
			cXmlRet := STR0006 // "Erro no parser!"
			Return {lRet, cXmlRet}
		EndIf

		If cVersao == "1"
			aRet := v1000(cXml, nTypeTrans, cTypeMessage)
		ElseIf cVersao == "2"
			aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXml, cVersao + cBuild)
		Else
			lRet    := .F.
			cXmlRet := STR0004 // "A vers„o da mensagem informada n„o foi implementada!"
			Return {lRet, cXmlRet}
		EndIf
	ElseIf cTypeMessage == EAI_MESSAGE_WHOIS
		aRet := v2000(cXml, nTypeTrans, cTypeMessage, oXml)
	Endif
ElseIf nTypeTrans == TRANS_SEND
	If XX4->(ColumnPos("XX4_SNDVER")) > 0
		If ! Empty(cVersion)
			cVersao	:= StrTokArr(cVersion, ".")[1]
			If cVersao == "1"
				aRet		:= v1000(cXml, nTypeTrans, cTypeMessage)
			ElseIf cVersao == "2"
				aRet		:= v2000(cXml, nTypeTrans, cTypeMessage, oXml)
			Else
				lRet		:= .F.
				cXmlRet	:= STR0004 // "A vers„o da mensagem informada n„o foi implementada!"
				Return {lRet, cXmlRet}
			EndIf
		Else
			lRet		:= .F.
			cXmlRet	:= STR0027 //"Vers„o n„o informada no cadastro do adapter."
			Return {lRet, cXmlRet}
		EndIf
	Else
		ConOut(STR0029) //"A lib da framework Protheus est· desatualizada!"
		aRet	:= v1000(cXml, nTypeTrans, cTypeMessage) //Se o campo vers„o n„o existir chamar a vers„o 1
	EndIf
EndIf

lRet    := aRet[1]
cXMLRet := aRet[2]
Return( {lRet, cXmlRet, cMessageName} )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ v1000    ∫Autor  ≥ Marcelo C. Coutinho  ∫ Data ≥  28/10/11   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Desc.    ≥ Funcao de integracao com o adapter EAI para recebimento e    ∫±±
±±∫          ≥ envio de informaÁıes do cadastro de clientes        (SA1)    ∫±±
±±∫          ≥ utilizando o conceito de mensagem unica.                     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Param.   ≥ cXML - Variavel com conteudo xml para envio/recebimento.     ∫±±
±±∫          ≥ nTypeTrans - Tipo de transacao. (Envio/Recebimento)          ∫±±
±±∫          ≥ cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc) ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Retorno  ≥ aRet - Array contendo o resultado da execucao e a mensagem   ∫±±
±±∫          ≥        Xml de retorno.                                       ∫±±
±±∫          ≥ aRet[1] - (boolean) Indica o resultado da execuÁ„o da funÁ„o ∫±±
±±∫          ≥ aRet[2] - (caracter) Mensagem Xml para envio                 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Uso      ≥ v1000                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function v1000( cXML, nTypeTrans, cTypeMessage )

Local aArea         := GetArea()
Local lRet          := .T.
Local lExclui       := .T.
Local aCab          := {}
Local aErroAuto     := {}
Local aRet          := {}
Local nCount        := 0
Local nX            := 0
Local nOpcx         := 0
Local nTamCpo       := 0
Local dRegData      := ""
Local cDatAtu       := ""
Local cXMLRet       := ""
Local cError        := ""
Local cWarning      := ""
Local cLogErro      := ""
Local cEvent        := "upsert"
Local cValGovern    := ""
Local cCodCli       := ""
Local cCNPJCPF      := ""
Local cRegData      := ""
Local cCodEst       := ""
Local cCodMun       := ""
Local cCodEstE      := Space(2) //-- Codigo estado de entrega
Local cCodMunE      := ""       //-- Codigo municipio de entrega
Local cLojCli       := ""
//Variaveis utilizada no De/Para de Codigo Interno X Codigo Externo
Local cMarca        := "" //Armazena a Marca (LOGIX,PROTHEUS,RM...) que enviou o XML
Local cValExt       := "" //Codigo externo utilizada no De/Para de codigos - Tabela XXF
Local cValInt       := "" //Codigo interno utilizado no De/Para de codigos - Tabela XXF
Local cAlias        := "SA1"        //Alias usado como referÍncia no De/Para
Local cCampo        := "A1_COD" //Campo usado como referÍncia no De/Para
Local cType         := ""
Local cStringTemp   := ""
Local aRetPe        := {}
Local cPais         := ""
Local cCodPais      := ""
Local cEst          := ""
Local cEndereco     := ""
Local cTel			:= ""
Local lEAICodUnq    := Iif(FindFunction("TMSCODUNQ"),TMSCODUNQ(),.F.)      //Codigo Unico
Local cOwnerMsg	  	:= "CUSTOMERVENDOR"
Local cCodIniPad    := ""
Local cRotina  		:= IIF(MA030IsMVC(),"CRMA980","MATA030")
Local oModel 		:= Nil
Local cEndEnt			:= ""
Local cRegionExtId  := ''
Local cRegionCode   := ''
Local cRegion       := ''
Local cSegExtId     := ''
Local cSegCode      := ''
Local cSeg          := ''
Local cFreightType  := ''
Local cCarrExtId    := ''
Local cCarrCode     := ''
Local cCarrier      := ''

Private oXmlM030            := Nil
Private nCountM030      := 0
Private lMsErroAuto     := .F.
Private lAutoErrNoFile  := .T.

//Trata o recebimento de mensagens
If ( nTypeTrans == TRANS_RECEIVE )

    //Trata o recebimento de dados (BusinessContent)
    If ( cTypeMessage == EAI_MESSAGE_BUSINESS )

        oXmlM030 := XmlParser( cXml, "_", @cError, @cWarning )

        //Verifica se houve erro na criacao do objeto XML
        If ( oXmlM030 <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) )

            If ( AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text ) ) == "CUSTOMER".Or.;
                 AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text ) ) == "BOTH" ) 

                    If ( AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text ) ) == "BOTH")

                        cType := AllTrim( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text )
                        cXml  := StrTran( cXml, "<Type>" + cType + "</Type>", "<Type>VENDOR</Type>" )
                        aAdd( aRet , FWIntegDef( "MATA020", cTypeMessage, nTypeTrans, cXml ) )
                        If !Empty(aRet)
                            lRet    := aRet[1][1]
                            cXmlRet += aRet[1][2]
                        EndIf
                    EndIf

                    If ( Type( "oXmlM030:_TotvsMessage:_MessageInformation:_Product:_Name:Text" ) <> "U" )
                        cMarca := oXmlM030:_TotvsMessage:_MessageInformation:_Product:_Name:Text
                    EndIf
                    If Type("oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key:Text") <> "U"
                        cValExt:=oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_Key:Text
                    ElseIf ( Type("oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text") <> "U" )
                        cValExt := oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text
                    EndIf

                    //--------------------------------------------------------------------------------------
                    //-- Tratamento utilizando a tabela XXF com um De/Para de codigos
                    //--------------------------------------------------------------------------------------

                    cValInt := CFGA070INT( cMarca , cAlias , cCampo, cValExt )

                    If Empty(cValInt)
                    		If ( Upper(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT" )
	                			nOpcx := 3
	                		ElseIf ( Upper(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE" )
	                			lExclui := .F.
	                		Endif
                    Else
                    		
                    		If ( Upper(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT" )
                    			nOpcx := 4
                    		ElseIf ( Upper(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE" )
                    			nOpcx := 5
                    		Endif
                    Endif

                    If nOpcx == 3 
                        nTamCpo := TamSX3('A1_COD')[1] + TamSX3('A1_LOJA')[1]
                        cValInt  := Padr(cValExt,nTamCpo)
                        cCodIniPad := Posicione('SX3',2,Padr('A1_COD' ,10),'X3_RELACAO')
                        If Empty(cCodIniPad) .Or. "A030INICPD" $ Upper(cCodIniPad) 
                            cCodCli := Substr( cValInt, 1, TamSX3('A1_COD')[1] )
                            aAdd( aCab, { "A1_COD" , cCodCli , Nil } )
                        EndIf

                        If Empty(Posicione('SX3',2,Padr('A1_LOJA',10),'X3_RELACAO'))
                            cLojCli := Substr( cValInt, TamSX3('A1_COD')[1] + 1, TamSX3('A1_LOJA')[1] )
                            aAdd( aCab, { "A1_LOJA", cLojCli, Nil } )
                        EndIf
                    Else
                        cCodCli := Substr( cValInt, 1, TamSX3('A1_COD')[1] )
                        cLojCli := Substr( cValInt, TamSX3('A1_COD')[1] + 1, TamSX3('A1_LOJA')[1] )
                        
                        aAdd( aCab, { "A1_COD" , cCodCli , Nil } )
                        aAdd( aCab, { "A1_LOJA", cLojCli, Nil } )
                    EndIf

                    If ( nOpcx <> 5 )

                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text" ) <> "U" )
                            aAdd( aCab, { "A1_NOME", UPPER(AllTrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text)), Nil } )
                        EndIf

                        If ( Type("oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShortName:Text") <> "U" )
                            aAdd( aCab, { "A1_NREDUZ", UPPER(AllTrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShortName:Text)), Nil } )
                        EndIf

                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EntityType:Text" ) <> "U" )
                            If ( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EntityType:Text ) == 'PERSON' )
                                aAdd( aCab, { "A1_PESSOA", 'F', Nil } )
                                aAdd( aCab, { "A1_TIPO"  , 'F', Nil } )
                            ElseIf ( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EntityType:Text ) == 'COMPANY' )
                                aAdd( aCab, { "A1_PESSOA", 'J', Nil } )
                                aAdd( aCab, { "A1_TIPO"  , 'R', Nil } )
                            EndIf
                        EndIf

                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Address:Text" ) <> "U" )
                           If !Empty(AllTrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Address:Text))
									   cEndereco := AllTrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Address:Text)
									
								   	If Type("oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Number:Text") <> "U"
									   	If !Empty(AllTrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Number:Text))
										   	cEndereco += ", " + AllTrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Number:Text)
                                 Endif
                              Endif
                              
                              cEndereco := AllTrim(Upper(cEndereco))
                           
                              Aadd( aCab, { "A1_END",cEndereco, Nil })
                           Endif
                        EndIf

                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Complement:Text" ) <> "U" )
                            aAdd( aCab, { "A1_COMPLEM", UPPER(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Complement:Text), Nil } )
                        EndIf

                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_District:Text") <> "U" )
                            aAdd( aCab, { "A1_BAIRRO", Upper(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_District:Text), Nil } )
                        EndIf
                        
                        //| Implementado em 05/06/2017 para atender integraÁ„o deste cadastro sendo que o Datasul È o Transmissor, 
                        //| Considerar o cÛdigo de PaÌs do cadastro 
                        If Type("oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Country:_Code:Text") != "U" .And. !Empty(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Country:_Code:Text)
                             cCodPais := PadR(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Country:_Code:Text, TamSx3("YA_CODGI")[1])
                             SYA->(DbSetOrder(1))
                             If !SYA->(MsSeek(xFilial("SYA") + cCodPais))
                                 cCodPais := Space(TamSx3("YA_CODGI")[1])
                             EndIf

                        EndIf
                        If Type("oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Country:_Description:Text") != "U" .And. !Empty(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Country:_Description:Text)
								
							      cPais := AllTrim(Upper(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Country:_Description:Text))
								
                            //Tratativa para considerar o nome do pais "BRAZIL"
                           If cPaisLoc == "BRA"
                              If cPais == "BRAZIL" 
                                 cPais := "BRASIL"
                              EndIf
                           EndIf
                            
								//| Se nao foi informado o codigo do pais busca pela descricao
                           If Empty(cCodPais)
                               cCodPais := Posicione("SYA",2,xFilial("SYA") + PadR(cPais,TamSx3("YA_DESCR")[1]),"YA_CODGI")
                           EndIf
                            
                           If !Empty(cCodPais)
                                If cCodPais <> A2030PALOC("SA1",1)
                                    cEst := "EX"
                                Endif
                                
                                Aadd( aCab, { "A1_PAIS",cCodPais, Nil })
                           Else
                                If cPais <> A2030PALOC("SA1",2)
                                    cEst := "EX"
                                Endif
                           Endif
                            
                           SYA->(DbSetOrder(1))
                        Endif

                        If Type("oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_State:_Code:Text") <> "U" .And. !Empty(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_State:_Code:Text)
                            If Empty(cEst)
                                cEst := AllTrim(Upper(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_State:_Code:Text))
                            Endif
                            
		      					Aadd( aCab, { "A1_EST", cEst, Nil })
				      		EndIf

                        If cEst <> "EX" .And. Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_City:_Code:Text") <> "U"

                            cCodMun := oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_City:_Code:Text

                            If ( Len(cCodMun) == 7 )
                                cCodMun := SubStr( cCodMun, 3, 5 )
                            EndIf

                            aAdd( aCab, { "A1_COD_MUN", cCodMun, Nil } )

                        EndIf

                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_City:_Description:Text") <> "U" )
                            aAdd( aCab, { "A1_MUN", oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_City:_Description:Text, Nil } )
                        EndIf
                        
                        //Verifica se existe o cÛdigo do RegionInternalId, chave extrangeria para cÛdigo de regi„o
                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Region:_RegionInternalId:Text") <> "U" )
                           cRegionExtId := Alltrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Region:_RegionInternalId:Text)
                        EndIf
                        //Verifica se existe o cÛdigo do RegionCode, chave local do Protheus para Regi„o, exemplo: 006-Regi„o Norte
                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Region:_RegionCode:Text") <> "U" )
                           cRegionCode := Alltrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Region:_RegionCode:Text)
                        EndIf						
                        
                        cRegion := Mati30Regi(cRegionExtId, cRegionCode, cMarca)
                        If !Empty(cRegion)
                           aAdd(aCab, { "A1_REGIAO", cRegion, Nil} )
                        Endif


                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_ZIPCode:Text") <> "U" )
                        	cStringTemp:=RemCharEsp(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_ZIPCode:Text, Nil)
								   aAdd(aCab, {"A1_CEP",cStringTemp , Nil})
                        EndIf


                        //Segment Node - Dados de segmento do cliente
                        If Type("oXmlM030:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_Segment:_InternalId") <> "U"
                            If ( ValType( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId) <> "A" )
                                XmlNode2Arr(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId, "_InternalId")
                            EndIf
                            
                            For nX := 1 To Len( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId )
                                 cSegExtId := RemCharEsp(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:TEXT)
                                 If Type("oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[" + cValtoChar(nX) + "]:_CodeERP:Text") != "U"
                                   cSegCode := RemCharEsp(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:_CodeERP:TEXT)
                                 Endif
                                 cSeg      := Mati30Seg(cSegExtId, cSegCode, cMarca) // FunÁ„o retorna o cÛdigo do segmento no Protheus, SX5, tabela T3.
									      If Empty(cSeg)
										      Loop
									      Endif

                                If Type("oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[" + cValtoChar(nX) + "]:_Name:Text") != "U"
                                    If     ( AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:_Name:TEXT ) ) == 'SEGMENT1' )
                                        Aadd( aCab, { "A1_SATIV1", cSeg, Nil })
                                    ElseIf ( AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:_Name:TEXT ) ) == 'SEGMENT2' )
                                        Aadd( aCab, { "A1_SATIV2", cSeg, Nil })
                                    ElseIf ( AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:_Name:TEXT ) ) == 'SEGMENT3' )
                                        Aadd( aCab, { "A1_SATIV3", cSeg, Nil })
                                    ElseIf ( AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:_Name:TEXT ) ) == 'SEGMENT4' )
                                        Aadd( aCab, { "A1_SATIV4", cSeg, Nil })
                                    ElseIf ( AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:_Name:TEXT ) ) == 'SEGMENT5' )
                                        Aadd( aCab, { "A1_SATIV5", cSeg, Nil })
                                    ElseIf ( AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:_Name:TEXT ) ) == 'SEGMENT6' )
                                        Aadd( aCab, { "A1_SATIV6", cSeg, Nil })    
                                    ElseIf ( AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:_Name:TEXT ) ) == 'SEGMENT7' )
                                        Aadd( aCab, { "A1_SATIV7", cSeg, Nil })    
                                    ElseIf ( AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:_Name:TEXT ) ) == 'SEGMENT8' )
                                        Aadd( aCab, { "A1_SATIV8", cSeg, Nil })    
                                    EndIf 
                                EndIf
                        	Next nX
                        EndIf
                        //Codigo do tipo de frete: C=CIF;F=FOB;T=Por conta terceiros;R=Por conta remetente;D=Por conta destinat·rio;S=Sem frete
                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:_Code:Text" ) <> "U" )
                            cFreightType := AllTrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:_Code:Text)
                           If cFreightType $ 'CFTRDS' // C=CIF;F=FOB;T=Por conta terceiros;R=Por conta remetente;D=Por conta destinat·rio;S=Sem frete
                              aAdd( aCab, { "A1_TPFRET", cFreightType, Nil } )
                           Endif
                        EndIf
                        //Transportadora
                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Carrier:_InternalId:Text" ) <> "U" )
                           cCarrExtId := AllTrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Carrier:_InternalId:Text)
                        EndIf
                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Carrier:_CodeERP:Text" ) <> "U" )
                           cCarrCode := AllTrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Carrier:_CodeERP:Text)
                        EndIf
                          
                        cCarrier := Mati30Car(cCarrExtId, cCarrCode, cMarca)
                        If !Empty(cCarrier) 
                           aAdd(aCab, {"A1_TRANSP", cCarrier, Nil})
                        Endif	
                        // Vencimento do Limite de Credito
                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CreditInformation:_MaturityCreditLimit:Text" ) <> "U" )
                           cDatVenLim := AllTrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CreditInformation:_MaturityCreditLimit:Text)
                           If !Empty(cDatVenLim)
                              aAdd(aCab, {"A1_VENCLC", cTod(SubStr(cDatVenLim, 9, 2) + "/" + SubStr(cDatVenLim, 6, 2 ) + "/" + SubStr(cDatVenLim, 1, 4 )), Nil})
                           Endif   
                        EndIf

                        //GovernmentalInformation Node - Dados de documentos do cliente
                        If Type("oXmlM030:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_GOVERNMENTALINFORMATION:_ID") <> "U"
                            If ( ValType( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_ID) <> "A" )
                                XmlNode2Arr(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_ID, "_ID")
                            EndIf
                            
                            For nX := 1 To Len( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_ID )

	                            cValGovern := RemCharEsp(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_ID[nX]:TEXT)
                                If Type("oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_Id[" + cValtoChar(nX) + "]:_Name:Text") != "U"
                                    If ( AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_ID[nX]:_Name:TEXT ) ) == 'INSCRICAO ESTADUAL' )
                                        Aadd( aCab, { "A1_INSCR",  cValGovern, Nil })
                                    ElseIf ( AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_ID[nX]:_Name:TEXT ) ) == 'INSCRICAO MUNICIPAL' )
                                        Aadd( aCab, { "A1_INSCRM", cValGovern, Nil })
                                    ElseIf ( AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_ID[nX]:_Name:TEXT ) ) $ 'CPF/CNPJ' )
                                        Aadd( aCab, { "A1_CGC",    cValGovern, Nil })
                                    ElseIf ( AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_ID[nX]:_Name:TEXT ) ) == 'SUFRAMA' )
                                        Aadd( aCab, { "A1_SUFRAMA",    cValGovern, Nil })
                                    ElseIf ( AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_ID[nX]:_Name:TEXT ) ) == 'RG' )
                                        Aadd( aCab, { "A1_PFISICA", PadR(cValGovern,TamSx3("A1_PFISICA")[1]), Nil })
                                        Aadd( aCab, { "A1_RG",      PadR(cValGovern,TamSx3("A1_RG")[1])     , Nil })
                                    ElseIf ( AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_ID[nX]:_Name:TEXT ) ) == 'INSCRICAO RURAL' )
                                        Aadd( aCab, { "A1_INSCRUR",  cValGovern, Nil })    
                                    EndIf 
                                EndIf
                        	Next nX
                        EndIf

                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_POBox:Text" ) <> "U" )
                            aAdd( aCab, { "A1_CXPOSTA", oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_POBox:Text, Nil } )
                        EndIf

                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_Email:Text" ) <> "U" )
                            aAdd( aCab, { "A1_EMAIL", oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_Email:Text, Nil } )
                        EndIf

                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_PhoneNumber:Text" ) <> "U" )
								cStringTemp:= RemCharEsp(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_PhoneNumber:Text)

								aTelefone := RemDddTel(cStringTemp)
								aAdd(aCab, {"A1_TEL",aTelefone[1], Nil})

								If !Empty(aTelefone[2])
									If Len(AllTrim(aTelefone[2])) == 2
										aTelefone[2] := "0" + aTelefone[2]
									Endif
									aAdd(aCab, {"A1_DDD",aTelefone[2], Nil})
								Elseif ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_DiallingCode:Text" ) <> "U" )
								 	cStringTemp:= RemCharEsp(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_DiallingCode:Text)
								 		aTelefone[2] := "0" + allTrim(cStringTemp)
								 		aAdd(aCab, {"A1_DDD",aTelefone[2], Nil})
								EndIf

								If !Empty(aTelefone[3])
									aAdd(aCab, {"A1_DDI",aTelefone[3], Nil})
								ElseIF ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_InternationalDiallingCode:Text" ) <> "U" )
								 	cStringTemp:= RemCharEsp(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_InternationalDiallingCode:Text)
								 		aTelefone[3] := allTrim(cStringTemp)
								 		aAdd(aCab, {"A1_DDI",aTelefone[3], Nil})
								EndIf 
                        EndIf

                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_FaxNumber:Text" ) <> "U" )
								cStringTemp:= RemCharEsp(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_FaxNumber:Text)
								aTelefone := RemDddTel(cStringTemp)
								Aadd( aCab, { "A1_FAX",aTelefone[1],   Nil })
                        EndIf

                        //-- EndereÁo de cobranÁa
                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_Address:Text" ) <> "U" )
                            aAdd( aCab, { "A1_ENDCOB", AllTrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_Address:Text), Nil } )
                        EndIf


                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_HomePage:Text" ) <> "U" )
                            aAdd( aCab, { "A1_HPAGE", oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_HomePage:Text, Nil } )
                        EndIf

                        //-- EndereÁo de entrega
                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_Address:Text" ) <> "U" )
                            
                            cEndEnt :=  AllTrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_Address:Text)
                            
                            
                            If Type("oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_Number:Text") <> "U"
									If !Empty(AllTrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_Number:Text))
										cEndEnt += ", " + AllTrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_Number:Text)
									Endif
								Endif
									
								cEndEnt := AllTrim(Upper(cEndEnt))
							
								If Type("oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_Complement:Text") <> "U"
									If !Empty(AllTrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_Complement:Text))
										cEndEnt += ", " + AllTrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_Complement:Text)
									Endif
								Endif
								
								cEndEnt := AllTrim(Upper(cEndEnt))
								
								Aadd( aCab, { "A1_ENDENT",cEndEnt, Nil })

                        EndIf
							
					
                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfContacts:_Contact:_Name:Text") <> "U" )
                            aAdd( aCab, { "A1_CONTATO", oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfContacts:_Contact:_Name:Text, Nil } )
                        EndIf

                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterSituation:Text" ) <> "U" )
                            If ( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterSituation:Text ) == 'ACTIVE' )
                                aAdd( aCab, { "A1_MSBLQL", '2', Nil } )
                            Else
                                aAdd( aCab, { "A1_MSBLQL", '1', Nil } )
                            EndIf
                        Else
                            aAdd( aCab, { "A1_MSBLQL", '1', Nil } )
                        EndIf

                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text" ) <> "U" )
                            cRegData := oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text
                            dRegData := CTOD( cRegData )
                            aAdd( aCab, { "A1_DTNASC", dRegData , Nil } )
                        EndIf

                        //-- InformaÁıes de cobranÁa
                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_District:Text" ) <> "U" )
                            aAdd( aCab, {"A1_BAIRROC", AllTrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_District:Text),Nil } )
                        EndIf
                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_ZIPCode:Text" ) <> "U" )
                            aAdd( aCab, {"A1_CEPC",   oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_ZIPCode:Text,           Nil } )
                        EndIf
                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation::_Address_City:_Description:Text" ) <> "U" )
                            aAdd( aCab, {"A1_MUNC",   AllTrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_City:_Description:Text), Nil } )
                        EndIf
                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_State:_Code:Text" ) <> "U" )
                            aAdd( aCab, {"A1_ESTC",   oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_State:_Code:Text,       Nil } )
                        EndIf

                        //-- InformaÁıes de entrega
                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_ZIPCode:Text" ) <> "U" )
                            aAdd( aCab, { "A1_CEPE", oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_ZIPCode:Text, Nil } )
                        EndIf
                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_District:Text" ) <> "U" )
                            aAdd( aCab, { "A1_BAIRROE", oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_District:Text, Nil } )
                        EndIf

                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_State:_Code:Text" ) <> "U" )
                            aAdd( aCab, { "A1_ESTE", oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_State:_Code:Text, Nil } )
                        EndIf
	                   	If cPaisLoc $ "ANG|BRA|EQU|HAI|PTG"     
	                    		If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_City:_Code:Text" ) <> "U" )
	                            cCodMunE := oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_City:_Code:Text
	
                          		If ( Len(cCodMunE) == 7 )
	                                cCodMunE := SubStr( cCodMunE, 3, 5 )
	                           	EndIf
	                           	aAdd( aCab, { "A1_CODMUNE", cCodMunE , Nil } )
								EndIf
							EndIf
                        If ( Type( "oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_City:_Description:Text" ) <> "U" )
                            aAdd( aCab, { "A1_MUNE", AllTrim(oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_City:_Description:Text), Nil } )
                        EndIf

                    EndIf
                    
                    // ponto de entrada inserido para controlar dados especificos do cliente
						If ExistBlock("MT030EAI")
							aRetPe := ExecBlock("MT030EAI",.F.,.F.,{aCab,nOpcx})
							If ValType(aRetPe) == "A" .And. ValType(aRetPe[1]) == "A"
								aCab 	:= aClone(aRetPe)
							EndIf
						EndIf
						
						//Ordena Array conforme dicionario de dados
						aCab := FWVetByDic(aCab /*aVetor*/, "SA1" /*cTable*/, .F./*lItens*/, /*nCpoPos*/)
						
						If nOpcx <> 5
							nPos1 := aScan(aCab,{|x| AllTrim(x[1]) = "A1_COD"})
							nPos2 := aScan(aCab,{|x| AllTrim(x[1]) = "A1_LOJA"})
							
							If nPos1 > 0 .And. nPos2 > 0
								SA1->(DbSetOrder(1))
								If SA1->(DbSeek(xFilial("SA1") + PadR(aCab[nPos1,2],TamSx3("A1_COD")[1]) + PadR(aCab[nPos2,2],TamSx3("A1_LOJA")[1])))
									nOpcx := 4
								Else
									nOpcx := 3
								Endif
							Endif
						Endif

                    BEGIN TRANSACTION

                        If ( nOpcx == 5 ) .And. ( !lExclui )
                            lMsErroAuto := .F.
                        Else
                            If ( nOpcx == 5 )
                                cValInt := cCodCli + cLojCli
                                CFGA070Mnt(,cAlias,cCampo,,cValInt,.T.,,,cOwnerMsg)
                            EndIf
                            If MA030IsMVC()
                            	SetFunName('CRMA980')
                           		MSExecAuto( { |x, y| CRMA980( x, y ) }, aCab, nOpcx )
                            Else
                            	SetFunName('MATA030')
                           		MSExecAuto( { |x, y| MATA030( x, y ) }, aCab, nOpcx )
                           	EndIf
                        EndIf

                        //Tratamento em caso de erro na ExecAuto
                        If ( lMsErroAuto )
                            aErroAuto := GetAutoGRLog()

                            For nCount := 1 To Len(aErroAuto)
                                cLogErro += _NoTags(aErroAuto[nCount])
                            Next nCount

                            //-- Monta XML de Erro de execuÁ„o da rotina automatica.
                            lRet := .F.
                            cXMLRet := cLogErro

                            //-- Desfaz a transacao
                            DisarmTransaction()
                        Else
                        		
                        	cValInt := SA1->( A1_COD + A1_LOJA )
                            
                            If ( nOpcx <> 5 ) .And. ( !Empty(cValExt) ) .And. ( !Empty(cValInt) )

                                If CFGA070Mnt( cMarca, cAlias, cCampo, cValExt, cValInt,,,,cOwnerMsg)
                                    
                                    //-- Se integraÁ„o com cÛdigo unico estiver habilitada, devolve o cÛdigo ˙nico, porÈm na XXF deve ser gravado sempre CÛdigo+Loja
                                    If lEAICodUnq
		                        		cValInt := SA1->( A1_COD )
		                        	Else	
		                        		cValInt := SA1->( A1_COD + A1_LOJA )
		                            EndIf
                                    // Monta xml com status do processamento da rotina automatica OK.
                                    cXMLRet += "<CustomerVendorCode>" + cValExt + "</CustomerVendorCode>"  //Valor recebido na tag "BusinessMessage:BusinessContent:Code"
                                    cXMLRet += "<ExternalCode>" + cValInt + "</ExternalCode>"               //Valor gerado
                                    cXMLRet += "<DestinationInternalId>"+ cValInt +"</DestinationInternalId>"
                                    cXMLRet += "<OriginInternalId>"+       cValExt      +"</OriginInternalId>"
                                EndIf
                            EndIf
                        EndIf

                    END TRANSACTION
            ElseIf ( AllTrim( Upper( oXmlM030:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text ) ) == "VENDOR" )
                aAdd ( aRet , FWIntegDef( "MATA020", cTypeMessage, nTypeTrans, cXml ) )
                If ( !Empty(aRet) )
                    lRet        := aRet[1][1]
                    cXmlRet += aRet[1][2]
                EndIf
            EndIf

        Else
            //Tratamento em caso de falha ao gerar o objeto XML
            lRet        := .F.
            cXMLRet := STR0003 + cWarning//"Falha ao manipular o XML. "
        EndIf

    //Tratamento de respostas
    ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )

       //Gravacao do De/Para Codigo Interno X Codigo Externo
       If ( FindFunction( "CFGA070Mnt" ) )

            oXmlM030 := XmlParser( cXml, "_", @cError, @cWarning )

            If ( oXmlM030 <> Nil ) .And. ( Empty(cError) ) .And. ( Empty(cWarning) )
                If ( Type( "oXmlM030:_TotvsMessage:_MessageInformation:_Product:_Name:Text" ) <> "U" )
                    cMarca := oXmlM030:_TotvsMessage:_MessageInformation:_Product:_Name:Text
                EndIf
                
                If ( Type("oXmlM030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_OriginInternalId:Text") <> "U" )
                	cValInt:= oXmlM030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_OriginInternalId:Text
                ElseIf ( Type( "oXmlM030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_CustomerVendorCode:Text" ) <> "U" )
                	cValInt := oXmlM030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_CustomerVendorCode:Text
                EndIf	
                
                If Type("oXmlM030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_DestinationInternalId:Text") <> "U"
                	cValExt := oXmlM030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_DestinationInternalId:Text
	            ElseIf ( Type("oXmlM030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ExternalCode:Text") <> "U" )
	               cValExt := oXmlM030:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ExternalCode:Text
	            EndIf
	            
	            If !Empty(cValExt) .And. !Empty(cValInt)
	                
	                /*----------------------------------------------------------------------------------------------------------------------------------------------------------
	                //-- Se a mensagem CustomerReserveID estiver habilitada campo Loja n„o È trafegado nas mensagens, por esse motivo encontra-se a loja de acordo com o cÛdigo ˙nico das marcas
	                //--------------------------------------------------------------------------------------------------------------------------------------------------------*/
	                If lEAICodUnq
	                	SA1->(dbSetOrder(1))
	                	If SA1->(MsSeek(xFilial("SA1") + RTrim(cValInt)))	                		
	                		cValInt		:= SA1->( A1_COD + A1_LOJA )	                			                		
	                	EndIF
	                EndIf
	                
	                If CFGA070Mnt( cMarca, cAlias, cCampo, cValExt, cValInt,,,,cOwnerMsg)
	                    lRet := .T.
	                EndIf
	            Else
	                lRet := .F.
	            EndIf
	            
            EndIf
        Else
            ConOut(STR0001) //Atualize EAI
        EndIf

    //Tratamento de solicitacao de versao
    ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )
        cXMLRet := '1.000'
    EndIf

//Tratamento de envio de mensagens
ElseIf ( nTypeTrans == TRANS_SEND )
	
	If cRotina == "MATA030"
	    If ( !Inclui ) .And. ( !Altera )
	        cEvent := 'delete'
	    EndIf
	Else
		oModel := FwModelActive()
		If oModel:GetOperation() == MODEL_OPERATION_DELETE
			 cEvent := 'delete'
		EndIf
	EndIf

   cDatAtu := Transform(dToS(dDataBase),"@R 9999-99-99")

   //-- Retorna o codigo do estado a partir da sigla
   cCodEst := Tms120CdUf(SA1->A1_EST,'1')

   //-- Codigo do estado de entrega
   If !Empty(SA1->A1_ESTE)
       cCodEstE:= Tms120CdUf(SA1->A1_ESTE,'1')
   EndIf

   //-- Codigo do municipio enviado de acordo com tabela IBGE (cod. estado + cod. municipio )
   If !Empty(SA1->A1_COD_MUN)
    cCodMun := Alltrim(cCodEst) + AllTrim(SA1->A1_COD_MUN)
   Else
    cCodMun := cCodEst + AllTrim(SA1->A1_COD_MUN)
   Endif

   //-- Codigo do municipio de entrega
   If cPaisLoc $ "ANG|BRA|EQU|HAI|PTG" .And. !Empty(SA1->A1_CODMUNE)
    If !Empty(cCodEstE)
            cCodMunE := Alltrim(cCodEstE)  + AllTrim(SA1->A1_CODMUNE)
        Else
            cCodMunE := cCodEstE + AllTrim(SA1->A1_CODMUNE)
        EndIf
   Endif

    cXMLRet := '<BusinessEvent>'
    cXMLRet +=     '<Entity>CustomerVendor</Entity>'
    cXMLRet +=     '<Event>' + cEvent + '</Event>'
    cXMLRet +=     '<Identification>'
    cXMLRet +=         '<key name="Code">' + IIf(!lEAICodUnq,SA1->A1_COD + SA1->A1_LOJA,SA1->A1_COD) + '</key>'
    cXMLRet +=     '</Identification>'
    cXMLRet += '</BusinessEvent>'

    cXMLRet += '<BusinessContent>'
    cXMLRet +=  '<CompanyId>' + cEmpAnt + '</CompanyId>'
    cXMLRet +=  '<Code>' +  IIf(!lEAICodUnq,SA1->A1_COD + SA1->A1_LOJA,SA1->A1_COD) + '</Code>'
    cXMLRet +=  '<Name>' + _NoTags(RTrim(SA1->A1_NOME)) + '</Name>'
    cXMLRet +=  '<ShortName>' + _NoTags(RTrim(SA1->A1_NREDUZ)) + '</ShortName>'
    cXMLRet +=  '<Type>' + 'CUSTOMER' + '</Type>'

    If SA1->A1_PESSOA == 'F' //-- Pessoa fisica ou juridica
        cXMLRet     += '<EntityType>' + 'PERSON' + '</EntityType>'
        cCNPJCPF    := 'CPF'
    Else
        cXMLRet     += '<EntityType>' + 'COMPANY' + '</EntityType>'
        cCNPJCPF    := 'CNPJ'
    EndIf

    If ( !Empty(SA1->A1_DTNASC) )
        cXMLRet += '<RegisterDate>' + AllTrim(Transform(DtoS(SA1->A1_DTNASC),"@R 9999-99-99"))  + '</RegisterDate>'
    EndIf

    If ( SA1->A1_MSBLQL == '1' )
        cXMLRet += '<RegisterSituation>' + "INACTIVE" + '</RegisterSituation>'
    Else
        cXMLRet += '<RegisterSituation>' + "ACTIVE" + '</RegisterSituation>'
    EndIf

    cXMLRet += '<GovernmentalInformation>'
    cXMLRet +=  '    <Id scope="State" name="INSCRICAO ESTADUAL" issueOn="' + cDatAtu + '" expiresOn="">' + RTrim(SA1->A1_INSCR) + '</Id>'
    cXMLRet +=      '<Id scope="Municipal" name="INSCRICAO MUNICIPAL" issueOn="' + cDatAtu + '" expiresOn="">' + RTrim(SA1->A1_INSCRM) + '</Id>'
    cXMLRet +=      '<Id scope="Federal" name="SUFRAMA" issueOn="' + cDatAtu + '" expiresOn="">' + RTrim(SA1->A1_SUFRAMA) + '</Id>'
    cXMLRet +=      '<Id scope="Federal" name="' + cCNPJCPF + '" issueOn="' + cDatAtu + '" expiresOn="">' + RTrim(SA1->A1_CGC) + '</Id>'
    cXMLRet +=  '    <Id scope="State" name="INSCRICAO RURAL" issueOn="' + cDatAtu + '" expiresOn="">' + RTrim(SA1->A1_INSCRUR) + '</Id>'
    If !Empty(SA1->A1_PFISICA) .And. (SA1->A1_PESSOA == "F" .OR. SA1->A1_EST == "EX")
       cXMLRet +=      '<Id scope="Federal" name="RG" issueOn="' + cDatAtu + '" expiresOn="">' + RTrim(SA1->A1_PFISICA) + '</Id>'
    EndIf
    cXMLRet += '</GovernmentalInformation>'
	
   If !Empty(SA1->A1_SATIV1) .Or. !Empty(SA1->A1_SATIV2) .Or. !Empty(SA1->A1_SATIV3) .Or. !Empty(SA1->A1_SATIV4);
		 .Or. !Empty(SA1->A1_SATIV5) .Or. !Empty(SA1->A1_SATIV6) .Or. !Empty(SA1->A1_SATIV7) .Or. !Empty(SA1->A1_SATIV8)
      cXMLRet += '<Segment>'
      cXMLRet +=      Iif(!Empty(SA1->A1_SATIV1),'<InternalId Name="Segment1" CodeErp="' + RTrim(SA1->A1_SATIV1) + '" Description="' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV1, "X5DESCRI()" )) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + Rtrim(SA1->A1_SATIV1)   + '</InternalId>', "")
      cXMLRet +=      Iif(!Empty(SA1->A1_SATIV2),'<InternalId Name="Segment2" CodeErp="' + RTrim(SA1->A1_SATIV2) + '" Description="' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV2, "X5DESCRI()" )) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + Rtrim(SA1->A1_SATIV2)   + '</InternalId>', "")
      cXMLRet +=      Iif(!Empty(SA1->A1_SATIV3),'<InternalId Name="Segment3" CodeErp="' + RTrim(SA1->A1_SATIV3) + '" Description="' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV3, "X5DESCRI()" )) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + Rtrim(SA1->A1_SATIV3)   + '</InternalId>', "")
      cXMLRet +=      Iif(!Empty(SA1->A1_SATIV4),'<InternalId Name="Segment4" CodeErp="' + RTrim(SA1->A1_SATIV4) + '" Description="' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV4, "X5DESCRI()" )) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + Rtrim(SA1->A1_SATIV4)   + '</InternalId>', "")
      cXMLRet +=      Iif(!Empty(SA1->A1_SATIV5),'<InternalId Name="Segment5" CodeErp="' + RTrim(SA1->A1_SATIV5) + '" Description="' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV5, "X5DESCRI()" )) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + Rtrim(SA1->A1_SATIV5)   + '</InternalId>', "")
      cXMLRet +=      Iif(!Empty(SA1->A1_SATIV6),'<InternalId Name="Segment6" CodeErp="' + RTrim(SA1->A1_SATIV6) + '" Description="' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV6, "X5DESCRI()" )) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + Rtrim(SA1->A1_SATIV6)   + '</InternalId>', "")
      cXMLRet +=      Iif(!Empty(SA1->A1_SATIV7),'<InternalId Name="Segment7" CodeErp="' + RTrim(SA1->A1_SATIV7) + '" Description="' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV7, "X5DESCRI()" )) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + Rtrim(SA1->A1_SATIV7)   + '</InternalId>', "")
      cXMLRet +=      Iif(!Empty(SA1->A1_SATIV8),'<InternalId Name="Segment8" CodeErp="' + RTrim(SA1->A1_SATIV8) + '" Description="' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV8, "X5DESCRI()" )) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + Rtrim(SA1->A1_SATIV8)   + '</InternalId>', "")
      cXMLRet += '</Segment>'
   Endif
	//Enviando o Tipo de Frete.
	If !Empty(SA1->A1_TPFRET) // C=CIF;F=FOB;T=Por conta terceiros;R=Por conta remetente;D=Por conta destinat·rio;S=Sem frete                                    
		Do Case
			Case SA1->A1_TPFRET == 'C' 
				cFreightDesc := "CIF"
			Case SA1->A1_TPFRET == 'F' 
				cFreightDesc := "FOB"
			Case SA1->A1_TPFRET == 'T' 
				cFreightDesc := "Por conta terceiros"
			Case SA1->A1_TPFRET == 'R' 
				cFreightDesc := "Por conta remetente"
			Case SA1->A1_TPFRET == 'D' 
				cFreightDesc := "Por conta destinat·rio"
			Case SA1->A1_TPFRET == 'S' 
				cFreightDesc := "Sem frete"
			Otherwise
				cFreightDesc := "" 
		Endcase	
      cXMLRet += '<FreightType>'
      cXMLRet +=     '<Code>' + SA1->A1_TPFRET + '</Code>'
      cXMLRet +=     '<Description>' + cFreightDesc + '</Description>'
      cXMLRet += '</FreightType>' 
	Endif	
   //Transportadora
   If !Empty(SA1->A1_TRANSP) 
      cXMLRet += '<Carrier>'
      cXMLRet +=     '<CodeERP>'     + RTrim(SA1->A1_TRANSP)                                                             + '</CodeERP>'
      cXMLRet +=     '<InternalId>'  + cEmpAnt + "|" + Alltrim(xFilial("SA4")) + "|" + RTRIM(SA1->A1_TRANSP)    + '</InternalId>'
      cXMLRet +=     '<Description>' + Rtrim(Posicione("SA4",1, xFilial("SA4") + SA1->A1_TRANSP, "X5DESCRI()" ))  + '</Description>'
      cXMLRet += '</Carrier>' 
   Endif	

    cXMLRet += '<Address>'
    cXMLRet +=     '<Address>' + _NoTags(trataEnd(SA1->A1_END, "L")) + '</Address>'
    cXMLRet +=     '<Number>' + trataEnd(SA1->A1_END, "N") + '</Number>'
    cXMLRet +=     '<Complement>' + Iif(Empty(SA1->A1_COMPLEM),_NoTags(trataEnd(SA1->A1_END,"C")),_NoTags(AllTrim(SA1->A1_COMPLEM))) + '</Complement>'
    cXMLRet +=     '<City>'
    cXMLRet +=          '<Code>' + cCodMun + '</Code>'
    cXMLRet +=      		'<Description>' + _NoTags(AllTrim(SA1->A1_MUN)) + '</Description>'
    cXMLRet +=      '</City>'
    cXMLRet +=     '<District>' + _NoTags(AllTrim(SA1->A1_BAIRRO)) + '</District>'
    cXMLRet +=     '<State>'
    cXMLRet +=          '<Code>' + AllTrim(SA1->A1_EST) + '</Code>'
    cXMLRet +=          '<Description>' + _NoTags(AllTrim(Posicione("SX5",1, xFilial("SX5") + "12" + SA1->A1_EST, "X5DESCRI()" ))) + '</Description>'
    cXMLRet +=     '</State>'
    If !Empty(SA1->A1_PAIS)
        cXMLRet += '<Country>'
        cXMLRet +=      '<Code>'               + SA1->A1_PAIS + '</Code>'
        //cXMLRet +=      '<CountryInternalId>'  + SA1->A1_PAIS + '</CountryInternalId>'
        cXMLRet +=      '<Description>' + Rtrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR")) + '</Description>' 
        cXMLRet += '</Country>'
    EndIf
    If !Empty(SA1->A1_REGIAO)
        cXMLRet += '<Region>'
        cXMLRet +=      '<RegionCode>'        + Rtrim(SA1->A1_REGIAO)                                                            + '</RegionCode>'
        cXMLRet +=      '<RegionInternalId>'  + cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + Rtrim(SA1->A1_REGIAO)            + '</RegionInternalId>'
        cXMLRet +=      '<RegionDescription>' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "A2" + SA1->A1_REGIAO, "X5DESCRI()" )) + '</RegionDescription>' 
        cXMLRet += '</Region>'
    EndIf

    cXMLRet +=     '<ZIPCode>' + AllTrim(SA1->A1_CEP)  + '</ZIPCode>'
    cXMLRet +=      '<POBox>' + RTrim(SA1->A1_CXPOSTA) + '</POBox>'
    cXMLRet += '</Address>'

    //-- Tratamento EndereÁo de entrega
    cXMLRet += '<ShippingAddress>'
    cXMLRet +=     '<Address>' + RTrim(_NoTags(trataEnd(SA1->A1_ENDENT,"L"))) + '</Address>'
    cXMLRet +=     '<Number>' + RTrim(trataEnd(SA1->A1_ENDENT,"N")) + '</Number>'
    cXMLRet +=     '<Complement>' + _NoTags(RTrim(trataEnd(SA1->A1_ENDENT,"C"))) + '</Complement>'
    cXMLRet +=     '<City>'
    cXMLRet +=            '<Code>'        + cCodMunE                       + '</Code>'
    cXMLRet +=            '<Description>' + _NoTags(AllTrim(SA1->A1_MUNE)) + '</Description>'
    cXMLRet +=     '</City>'
    cXMLRet +=     '<District>' + AllTrim(SA1->A1_BAIRROE) + '</District>'
    cXMLRet +=     '<State>'
    cXMLRet +=          '<Code>' + AllTrim(SA1->A1_ESTE) + '</Code>'
    
    If !Empty(AllTrim(SA1->A1_ESTE))
    	cXMLRet +=          '<Description>' + _NoTags(AllTrim(Posicione("SX5",1, xFilial("SX5") + "12" + SA1->A1_ESTE, "X5DESCRI()" ))) + '</Description>'
    Else
    	cXMLRet +=          '<Description/>'
    Endif
    
    cXMLRet +=      '</State>'
    cXMLRet +=     '<ZIPCode>' + AllTrim(SA1->A1_CEPE) + '</ZIPCode>'
    cXMLRet += '</ShippingAddress>'
    
    If !Empty(SA1->A1_DDI)
		cTel := AllTrim(SA1->A1_DDI)
	Endif
	
	If !Empty(SA1->A1_DDD)
		If !Empty(cTel)
			cTel += AllTrim(SA1->A1_DDD)
		Else
			cTel := AllTrim(SA1->A1_DDD)
		Endif
	Endif
	
	If !Empty(cTel)
		cTel += AllTrim(SA1->A1_TEL)
	Else
		cTel := AllTrim(SA1->A1_TEL)
	Endif
	
    cXMLRet += '<ListOfCommunicationInformation>'
    cXMLRet +=  '<CommunicationInformation>'
    cXMLRet +=          '<PhoneNumber>' +  RTrim(cTel) + '</PhoneNumber>'
    cXMLRet +=          '<FaxNumber>' +  AllTrim(SA1->A1_FAX) + '</FaxNumber>'
    cXMLRet +=          '<HomePage>' + _NoTags(RTrim(SA1->A1_HPAGE)) + '</HomePage>'
    cXMLRet +=          '<Email>' + _NoTags(RTrim(SA1->A1_EMAIL)) + '</Email>'
    cXMLRet +=  '</CommunicationInformation>'
    cXMLRet += '</ListOfCommunicationInformation>'

    cXMLRet += '<ListOfContacts>'
    cXMLRet +=  '<Contact>'
    cXMLRet +=          '<Name>' + _NoTags(RTrim(SA1->A1_CONTATO)) + '</Name>'
    cXMLRet +=  '</Contact>'
    cXMLRet += '</ListOfContacts>'

    //-- EndereÁo de cobranÁa
    cXMLRet += '<BillingInformation>'
    cXMLRet +=  '<Address>'
    cXMLRet +=      '<Address>' + RTrim(_NoTags(trataEnd(SA1->A1_ENDCOB,"L"))) + '</Address>'
    cXMLRet +=      '<Number>' + RTrim(trataEnd(SA1->A1_ENDCOB,"N")) + '</Number>'
    cXMLRet +=      '<Complement>' + RTrim(_NoTags(trataEnd(SA1->A1_ENDCOB,"C"))) + '</Complement>'
    cXMLRet +=       '<City>'
    cXMLRet +=          '<Description>' + _NoTags(AllTrim(SA1->A1_MUNC)) + '</Description>'
    cXMLRet +=      '</City>'
    cXMLRet +=      '<District>'+ _NoTags(AllTrim(SA1->A1_BAIRROC))+ '</District>'
    cXMLRet +=      '<State>'
    cXMLRet +=          '<Code>' + AllTrim(SA1->A1_ESTC) + '</Code>'
    
    If !Empty(AllTrim(SA1->A1_ESTC))
    	cXMLRet +=          '<Description>' + _NoTags(AllTrim(Posicione("SX5",1, xFilial("SX5") + "12" + SA1->A1_ESTC, "X5DESCRI()" ))) + '</Description>'
    Else
    	cXMLRet +=          '<Description/>'
    Endif
    
    cXMLRet +=      '</State>'
    cXMLRet +=     '<ZIPCode>' + AllTrim(SA1->A1_CEPC) + '</ZIPCode>'
    cXMLRet +=  '</Address>'
    cXMLRet += '</BillingInformation>'

    cXMLRet +=  '<VendorInformation>'
    cXMLRet +=      '<VendorType>'
    cXMLRet +=          '<Code>' + SA1->A1_VEND + '</Code>'
    cXMLRet +=      '</VendorType>'
    cXMLRet +=  '</VendorInformation>'

    cXMLRet +=  '<CreditInformation>'
    cXMLRet +=      '<CreditLimit>' + cValToChar(SA1->A1_LC) + '</CreditLimit>'
    cXMLRet +=      '<BalanceOfCredit>' + cValToChar(SA1->A1_SALPED) + '</BalanceOfCredit>'
    cXMLRet +=      '<MaturityCreditLimit>' + Transform(DtoS(SA1->A1_VENCLC),'@R 9999-99-99') + '</MaturityCreditLimit>'
    cXMLRet +=  '</CreditInformation>'

    cXMLRet +=  '<PaymentConditionCode>' + SA1->A1_CONDPAG + '</PaymentConditionCode>'
    cXMLRet +=  '<PriceListHeaderItemCode>' + SA1->A1_TABELA + '</PriceListHeaderItemCode>'

    cXMLRet += '</BusinessContent>'

EndIf

RestArea(aArea)
Return { lRet, cXMLRet }

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} v2000

Funcao de integracao com o adapter EAI para recebimento do cadastro de
Cliente (SA1) utilizando o conceito de mensagem unica.

@param   cXml          Vari·vel com conte˙do XML para envio/recebimento.
@param   nTypeTrans    Tipo de transaÁ„o. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Leandro Luiz da Cruz
@version P11
@since   29/11/2012 - 15:32
@return  lRet - (boolean)  Indica o resultado da execuÁ„o da funÁ„o
         cXmlRet - (caracter) Mensagem XML para envio
/*/
//-------------------------------------------------------------------------------------------------
Static Function v2000(cXML, nTypeTrans, cTypeMessage, oXml, cVersao)
   Local nCount         := 0
   Local nX             := 0
   Local cValGov        := 0
   Local nAux           := 0
   Local cError         := ""
   Local cWarning       := ""
   Local cMarca         := ""
   Local cValInt        := ""
   Local cValExt        := ""
   Local cAlias         := "SA1"
   Local cField         := "A1_COD"
   Local cXmlRet        := ""
   Local cType          := ""
   Local cCode          := ""
   Local cStore         := ""
   Local lRet           := .T.
   Local cLograd        := ""
   Local cNumero        := ""
   Local cCodEst        := ""
   Local cCodEstE       := ""
   Local cCodMun        := ""
   Local cCodMunE       := ""
   Local cPais  	:= ""
   Local cCodPais       := ""
   Local cEst   	:= ""
   Local cEndereco      := ""
   Local cTel           := ""
   Local aRet           := {}
   Local aCliente       := {}
   Local aAux           := {}
   Local lV2005         := .F.
   Local lHotel        	:= SuperGetMV( "MV_INTHTL", , .F. )
   Local lIniPadCod     := .F.
   Local cTipoCli	:= ""
   Local aAreaCCH	:= {}
   Local cIniCli	:= ""
   Local cIniLoj	:= ""
   Local cRotina  	:= IIF(MA030IsMVC(),"CRMA980","MATA030")	
   Local cEvent       	:= "upsert"
   Local oModel 	:= Nil 
   Local cOwnerMsg	:= "CUSTOMERVENDOR"
   Local cEndEnt	:= ""
   Local cCompEndEnt	:= ""
   Local cPaisCode      := ''	
   Local lGetXnum       := .F.
   Local aAuxVInt       := {}
   Local nTamA1_DDD     := 0
   Local cRegionExtId   := ''
   Local cRegionCode    := ''
   Local cRegion        := ''
   Local cSegExtId      := ''
   Local cSegCode       := ''
   Local cSeg           := ''
   Local cFreightType   := ''
   Local cCarrExtId     := ''
   Local cCarrCode      := ''
   Local cCarrier       := ''
   Local cTaxpayer      := ''
   Local cVendExtId    := ''
	Local cVendCode     := ''
   Local cAddXml        := ''
   Local lNewLjCli 	:= .F.
   Local aRetCli   	:= {}
   Local cFilSA1        := FWxFilial( 'SA1' )
   Local lIntVetex	:= IIf( FindFunction( 'I030IsInteg' ), I030IsInteg(), .F. )
   Local bRotAut        := { || IIf( MA030IsMVC() , MSExecAuto({|x, y| CRMA980(x, y)}, aCliente, nOpcx), MSExecAuto({|x, y| MATA030(x, y)}, aCliente, nOpcx) ) }

   Private lMsErroAuto    := .F.
   Private lAutoErrNoFile := .T.
   Private lMsHelpAuto    := .T.
	
	If ! Empty( cVersao ) 
   		lV2005 := Iif( Val(cVersao) >= 2005, .T., .F. )
	Endif

   If nTypeTrans == TRANS_RECEIVE
      If cTypeMessage == EAI_MESSAGE_BUSINESS
         If AllTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text)) == "CUSTOMER" .OR. AllTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text)) == "1" .OR.;
            AllTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text)) == "BOTH" .OR. AllTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text)) == "3"
            If AllTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text)) == "BOTH" .OR. AllTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text)) == "3"
               cType := AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text)

               cXML  := StrTran(cXML, "<Type>" + cType + "</Type>", "<Type>VENDOR</Type>")

               aAdd(aRet, FWIntegDef("MATA020", cTypeMessage, nTypeTrans, cXML))

               If !Empty(aRet)
               	If ValType(aRet[1]) == "A" //Ajustado, se nao havia adapter de Fornecedor, causava Error_Log
	                  lRet := aRet[1][1]
	                  cXmlRet := aRet[1][2]
	                  Return {lRet, cXmlRet}
	            	EndIf
               EndIf
            EndIf

            // ObtÈm a marca
            If Type("oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text") != "U" .And. !Empty(oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
               cMarca :=  oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
            Else
               lRet := .F.
               cXmlRet := STR0010 // "Product È obrigatÛrio!"
               Return {lRet, cXmlRet}
            EndIf

            // Verifica se a filial atual È a mesma filial de inclus„o do cadastro
            If FindFunction("IntChcEmp")
               aAux := IntChcEmp(oXML, cAlias, cMarca)
               If !aAux[1]
                  lRet := aAux[1]
                  cXmlRet := aAux[2]
                  Return {lRet, cXmlRet}
               EndIf
            EndIf

            // ObtÈm o Valor externo
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
               cValExt := (oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text)
            Else
               lRet := .F.
               cXmlRet := STR0011 // "InternalId È obrigatÛrio!"
               Return {lRet, cXmlRet}
            EndIf

            //ObtÈm o code
			If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text)
				cCode := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Code:Text
			Else
               //Se for integraÁ„o com hotelaria, ir· gerar um cÛdigo sequencial ou considerar o inicializador padr„o do campo cÛdigo
				If !lHotel  .And. !lIntVetex
					lRet := .F.
					cXmlRet := STR0012 // "Code È obrigatÛrio!"
					Return {lRet, cXmlRet}
				Endif
			EndIf
            //ObtÈm a loja
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_StoreId:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_StoreId:Text)
               cStore := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_StoreId:Text
            EndIf

            //ObtÈm o valor interno
            aAux := IntCliInt(cValExt, cMarca)

            //Verifica se o cliente existe na Base, pois em casos onde um registro
            //È excluÌdo apÛs a integraÁ„o o sistema n„o consegue importar novamente.
            dbSelectArea("SA1")
            SA1->(dbSetOrder(1))

            // Se o evento È Upsert
            If Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
               // Se o registro existe
               If aAux[1]
                  If SA1->(MSSeek(cFilSA1+PADR(AAUX[2][3],LEN(SA1->A1_COD))+ PADR(AAUX[2][4],LEN(SA1->A1_LOJA))))
                     If !( lIntVetex )
                        nOpcx := 4
                     Else
                        //Verifica se os Enderecos Informados, Via Integracao, J· Est„o Cadastrados na Base
                        aRetCli   := I030SrcCli( oXML, SA1->A1_COD, SA1->A1_LOJA, 'XML' )
                        lNewLjCli := aRetCli[3]
                        cCode 	  := IIf( Empty( aRetCli[ 1 ] ), AAUX[2][3], aRetCli[ 1 ] )
                        cStore	  := IIf( Empty( aRetCli[ 2 ] ), AAUX[2][4], aRetCli[ 2 ] )

                        cValInt   := IntCliExt(, , cCode, cStore )[2]
                        nOpcx 	  := IIf( lNewLjCli, 3, 4 )
                        aAux	  := {}
                     EndIf
                  Else
                     nOpcx := 3 // Incluir
                  EndIf
               Else
                     nOpcx := 3 // Incluir
               EndIf

            // Se o evento È Delete
            ElseIf Upper(oXml:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
               // Se o registro existe
               If aAux[1]
                  If ( !lIntVetex )
                     nOpcx := 5 // Delete
                  Else
                     If SA1->( MSSeek(cFilSA1+PADR(AAUX[2][3],LEN(SA1->A1_COD))+ PADR(AAUX[2][4],LEN(SA1->A1_LOJA))))
                        nOpcx 	:= 5
                        //Verifica se os Enderecos Informados, Via Integracao, J· Est„o Cadastrados na Base
                        aRetCli := I030SrcCli( oXML, SA1->A1_COD, SA1->A1_LOJA, 'XML' )
                        
                        cCode 	:= IIf( Empty( aRetCli[ 1 ] ), AAUX[2][3], aRetCli[ 1 ] )
                        cStore	:= IIf( Empty( aRetCli[ 2 ] ), AAUX[2][4], aRetCli[ 2 ] )
                        cValInt := IntCliExt(, , cCode, cStore )[2]
                        aAux	:= {}

                     EndIf
                  EndIf
               Else
                  lRet := .F.
                  cXmlRet := STR0013 + " -> " + cValExt // "O registro a ser excluÌdo n„o existe na base Protheus!"
                  Return {lRet, cXmlRet}
               EndIf
            Else
               lRet := .F.
               cXmlRet := STR0014 // "O evento informado È inv·lido!"
               Return {lRet, cXmlRet}
            EndIf

			// Se È Insert
			If nOpcx == 3
				If Alltrim(cMarca)=="HIS"
					dbSelectArea("SA1")
					dbSetOrder(1)
					If dbSeek(cFilSA1+PadR(cCode, TamSX3("A1_COD")[1])+PadR(cStore, TamSX3("A1_LOJA")[1]))
					   nOpcx := 4
					   aAdd(aCliente, {"A1_COD",  cCode, Nil})  // CÛdigo
					   aAdd(aCliente, {"A1_LOJA", cStore, Nil}) // Loja
					Else
					   cIniCli := Posicione('SX3', 2, Padr('A1_COD', 10), 'X3_RELACAO')
					   cIniLoj := Posicione('SX3', 2, Padr('A1_LOJA', 10), 'X3_RELACAO')
				   		
				   		// Se n„o h· inicializador padr„o ou se A030INICPD esta contido, pois
				   		// este inicializador padr„o È utilizado apenas pela RM					   
					   If Empty(cIniCli) .Or. "A030INICPD" $ cIniCli
						   aAdd(aCliente, {"A1_COD",  cCode, Nil})  // CÛdigo
					   EndIf
					   
					   If Empty(cIniLoj)
					   	  aAdd(aCliente, {"A1_LOJA", cStore, Nil}) // Loja
					   EndIf		   
					EndIf
				Else
				 	// Se n„o h· inicializador padr„o
               cFormula := GetSx3Cache("A1_COD", "X3_RELACAO")
					lIniPadCod := !Empty(cFormula) .And. !( "A030INICPD" $ cFormula )
					
					If !lIniPadCod 
				 		//Se for integraÁ„o com hotelaria, gera um cÛdigo sequencial (pode ser alterada a lÛgica atravÈs de incializador padr„o)
						If lHotel
							cCode := I30ProxNum()
						Else
                     cCode := MATI030Num(cCode,@lGetXnum)  
                  EndIf

                  aAdd(aCliente, {"A1_COD",  cCode, Nil})  // CÛdigo
					EndIf
               
					If Empty(GetSx3Cache("A1_LOJA", "X3_RELACAO"))
				 		//Se for integraÁ„o com hotelaria, fixa a loja como "00" (pode ser alterada a lÛgica atravÈs de incializador padr„o) 
						If lHotel .Or. Empty(cStore)
							cStore := PadL(cStore,GetSx3Cache("A1_LOJA","X3_TAMANHO"),"0")
						Endif

						aAdd(aCliente, {"A1_LOJA", cStore, Nil}) // Loja
					EndIf
				EndIf
			Else
            If !( lIntVetex )
               cValInt := IntCliExt(, , aAux[2][3], aAux[2][4] )[2]
               aAdd(aCliente, {"A1_COD" , PadR(aAux[2][3], TamSX3("A1_COD")[1]) , Nil}) // CÛdigo
               aAdd(aCliente, {"A1_LOJA", PadR(aAux[2][4], TamSX3("A1_LOJA")[1]), Nil}) // Loja
            Else
               aAdd(aCliente, {"A1_COD" , PadR(cCode , TamSX3("A1_COD")[1]) , Nil}) // CÛdigo
               aAdd(aCliente, {"A1_LOJA", PadR(cStore, TamSX3("A1_LOJA")[1]), Nil}) // Loja						
            EndIf
			EndIf

            If nOpcx #5
               // ObtÈm o Nome ou Raz„o Social
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text)
                     aAdd(aCliente, {"A1_NOME", UPPER(AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text)), Nil})
               Else
                  lRet := .F.
                  cXmlRet := STR0015 // "O nome È obrigatÛrio!"
                  Return {lRet, cXmlRet}
               EndIf

               // ObtÈm o Nome de Fantasia
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShortName:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShortName:Text)
                  aAdd(aCliente, {"A1_NREDUZ", UPPER(AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShortName:Text)), Nil})
               Else
                  lRet := .F.
                  cXmlRet := STR0016 // "O nome reduzido È obrigatÛrio!"
                  Return {lRet, cXmlRet}
               EndIf

               // ObtÈm Pessoa/Tipo
               If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EntityType:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EntityType:Text)
                  If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EntityType:Text) == "PERSON" .OR. Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EntityType:Text) == "1" 
                     aAdd(aCliente, {"A1_PESSOA", "F", Nil}) // Pessoa FÌsica
                   
                  ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EntityType:Text) == "COMPANY" .OR. Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EntityType:Text) == "2"  
                     aAdd(aCliente, {"A1_PESSOA", "J", Nil}) // Pessoa JurÌdica
                  EndIf
                  
                  If cPaisLoc <> 'BRA'
                    aAdd(aCliente, {"A1_TIPO", "1", Nil})
                  Else
                    If !lV2005
                        aAdd(aCliente, {"A1_TIPO",   "F", Nil}) // Consumidor Final
                    EndIf
                  EndIf
               Else
                  lRet := .F.
                  cXmlRet := STR0017 // "O tipo do cliente È obrigatÛrio"
                  Return {lRet, cXmlRet}
               EndIf

				//Se for a vers„o 2.005 ou maior da mensagem, pega o tipo de cliente (Cons. Final, Revendedor, ExportaÁ„o, etc)
				If lV2005 .And. cPaisLoc == 'BRA'
					If Type( "oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_StrategicCustomerType:Text") != "U" .AND. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_StrategicCustomerType:Text )						
						cTipoCli := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_StrategicCustomerType:Text
						
						//Trata o tipo de cliente considerando o formato esperado no Protheus para gravaÁ„o desse dado
						If cTipoCli == "1"
							cTipoCli := "F"
						Elseif cTipoCli == "2"
							cTipoCli := "L" 
						Elseif cTipoCli == "3"
							cTipoCli := "R"
						Elseif cTipoCli == "4"
							cTipoCli := "S"
						Elseif cTipoCli == "5"
							cTipoCli := "X"
						Endif
						
						aAdd( aCliente, {"A1_TIPO", cTipoCli, Nil} )
					Else
						aAdd( aCliente, {"A1_TIPO", "F", Nil} ) //Consumidor Final
					Endif
				Endif

				//======================================================================================================
				// ENDERE«O DO CLIENTE
				//======================================================================================================
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address") != "U" .AND. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address)

					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Address:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Address:Text)
						// ObtÈm o N˙mero do EndereÁo do Cliente
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Number:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Number:Text)
							aAdd(aCliente, {"A1_END", UPPER(AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Address:Text)) + ", " + UPPER(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Number:Text), Nil})
						Else
							aAdd(aCliente, {"A1_END", UPPER(AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Address:Text)), Nil})
						EndIf
					Else
						lRet := .F.
						cXmlRet := STR0018 // "O EndereÁo È obrigatÛrio"
						Return {lRet, cXmlRet}
					EndIf

               		// ObtÈm o Complemento do EndereÁo
               		If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Complement:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Complement:Text)
               			aAdd(aCliente, {"A1_COMPLEM", UPPER(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Complement:Text), Nil})
               		EndIf

               		// ObtÈm o Bairro do Cliente
               		If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_District:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_District:Text)
               			aAdd(aCliente, {"A1_BAIRRO", UPPER(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_District:Text), Nil})
               		EndIf

               		// ObtÈm a descriÁ„o do MunicÌpio do Cliente
               		If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_City:_CityDescription:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_City:_CityDescription:Text)
               			aAdd(aCliente, {"A1_MUN", UPPER(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_City:_CityDescription:Text), Nil})
               		Else
               			lRet := .F.
               			cXmlRet := STR0020 // "A descriÁ„o do municÌpio È obrigatÛria"
               			Return {lRet, cXmlRet}
               		EndIf

               		// ObtÈm o Cod EndereÁamento Postal
               		If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_ZIPCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_ZIPCode:Text)
               			aAdd(aCliente, {"A1_CEP", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_ZIPCode:Text, Nil})
               		EndIf

               		//ObtÈm o cÛdigo de Pais do Cliente, no padr„o BACEN, atravÈs da descriÁ„o recebida (Exemplo: Brasil = 01058)
               		If cPaisLoc == 'BRA' .Or. cPaisLoc == 'ARG'//Paises que utilizam a tabela CCH
               			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Country:_CountryDescription:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Country:_CountryDescription:Text)
               				cPais := AllTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Country:_CountryDescription:Text))
               				//Tratativa para considerar o nome do pais "BRAZIL"
               				If cPaisLoc == "BRA"
               					If cPais == "BRAZIL" 
               						cPais := "BRASIL"
               					EndIf
               				EndIf

               				aAreaCCH := CCH->( GetArea() )
               				cCodPais := PadR( Posicione( "CCH", 2, FWxFilial("CCH") + PadR( cPais, GetSx3Cache("CCH_PAIS","X3_TAMANHO") ), "CCH_CODIGO" ), GetSx3Cache("A1_CODPAIS","X3_TAMANHO") )
					
               				CCH->( RestArea( aAreaCCH ) )
               				If ! Empty( cCodPais )
               					aAdd( aCliente, { "A1_CODPAIS", cCodPais, Nil } )
               				EndIf
               			EndIf
               		EndIf
               
               		//ObtÈm o Pais do Cliente pelo cÛdigo (padr„o SISCOMEX)
               		If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Country:_CountryCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Country:_CountryCode:Text)
               			cPaisCode := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Country:_CountryCode:Text
               			cPaisCode := PadR( cPaisCode, GetSX3Cache("A1_PAIS","X3_TAMANHO") ) 
               		EndIf
               
               		//Busca o paÌs por cÛdigo ou descriÁ„o
               		cPaisCode := MATI30Pais(cPaisCode, cPais, cMarca)
               
               		If !Empty(cPaisCode)
               			aAdd(aCliente, {"A1_PAIS", cPaisCode, Nil})
               			If cPaisCode <> A2030PALOC("SA1",1)
               				cEst := "EX"
               			Endif
               		Else
               			If !Empty(cPais) .And. cPais <> A2030PALOC("SA1",2)
               				cEst := "EX"
               			Endif   
               		EndIf

               		// ObtÈm a Sigla da FederaÁ„o
               		If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_State:_StateCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_State:_StateCode:Text)
               			If Empty(cEst)
               				cEst := AllTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_State:_StateCode:Text))
               			Endif
               			aAdd(aCliente, {"A1_EST", cEst, Nil})
               		Else
               			lRet := .F.
               			cXmlRet := STR0019 // "O estado È obrigatÛrio"
               			Return {lRet, cXmlRet}
               		EndIf

               		// ObtÈm o CÛdigo do MunicÌpio
               		If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_City:_CityCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_City:_CityCode:Text)
               			aAdd(aCliente, {"A1_COD_MUN", Right(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_City:_CityCode:Text, 5), Nil})
               		EndIf

                     //Verifica se existe o cÛdigo do RegionInternalId, chave extrangeria para cÛdigo de regi„o
                     If ( Type( "oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Region:_RegionInternalId:Text") <> "U" )
                        cRegionExtId := Alltrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Region:_RegionInternalId:Text)
                     EndIf
                     //Verifica se existe o cÛdigo do RegionCode, chave local do Protheus para Regi„o, exemplo: 006-Regi„o Norte
                     If ( Type( "oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Region:_RegionCode:Text") <> "U" )
                        cRegionCode := Alltrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Region:_RegionCode:Text)
                     EndIf						
                       
                     cRegion := Mati30Regi(cRegionExtId, cRegionCode, cMarca)
                     If !Empty(cRegion)
                        aAdd(aCliente, { "A1_REGIAO", cRegion, Nil} )
                     Endif
            EndIf

            //Segment Node - Dados de segmento do cliente
            If Type("oXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT:_Segment:_InternalId") <> "U"
               If ( ValType( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId) <> "A" )
                  XmlNode2Arr(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId, "_InternalId")
               EndIf

               nAux	:= Len( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId )             
               For nX := 1 To nAux
                  cSegExtId := RemCharEsp(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:TEXT)
                  If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[" + cValtoChar(nX) + "]:_CodeERP:Text") != "U"
                     cSegCode := RemCharEsp(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:_CodeERP:TEXT)
                  Endif
                  cSeg      := Mati30Seg(cSegExtId, cSegCode, cMarca) // FunÁ„o retorna o cÛdigo do segmento no Protheus, SX5, tabela T3.
					   If Empty(cSeg)
						   Loop
						Endif

                  If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[" + cValtoChar(nX) + "]:_Name:Text") != "U"
                     If     ( AllTrim( Upper( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:_Name:TEXT ) ) == 'SEGMENT1' )
                        Aadd( aCliente, { "A1_SATIV1", cSeg, Nil })
                     ElseIf ( AllTrim( Upper( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:_Name:TEXT ) ) == 'SEGMENT2' )
                        Aadd( aCliente, { "A1_SATIV2", cSeg, Nil })
                     ElseIf ( AllTrim( Upper( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:_Name:TEXT ) ) == 'SEGMENT3' )
                        Aadd( aCliente, { "A1_SATIV3", cSeg, Nil })
                     ElseIf ( AllTrim( Upper( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:_Name:TEXT ) ) == 'SEGMENT4' )
                        Aadd( aCliente, { "A1_SATIV4", cSeg, Nil })
                     ElseIf ( AllTrim( Upper( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:_Name:TEXT ) ) == 'SEGMENT5' )
                        Aadd( aCliente, { "A1_SATIV5", cSeg, Nil })
                     ElseIf ( AllTrim( Upper( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:_Name:TEXT ) ) == 'SEGMENT6' )
                        Aadd( aCliente, { "A1_SATIV6", cSeg, Nil })    
                     ElseIf ( AllTrim( Upper( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:_Name:TEXT ) ) == 'SEGMENT7' )
                        Aadd( aCliente, { "A1_SATIV7", cSeg, Nil })    
                     ElseIf ( AllTrim( Upper( oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Segment:_InternalId[nX]:_Name:TEXT ) ) == 'SEGMENT8' )
                        Aadd( aCliente, { "A1_SATIV8", cSeg, Nil })    
                     EndIf 
                  EndIf
              	Next nX
            EndIf
            
            //Codigo do tipo de frete: C=CIF;F=FOB;T=Por conta terceiros;R=Por conta remetente;D=Por conta destinat·rio;S=Sem frete
            If ( Type( "oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:_Code:Text" ) <> "U" )
               cFreightType := AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_FreightType:_Code:Text)
               If cFreightType $ 'CFTRDS' // C=CIF;F=FOB;T=Por conta terceiros;R=Por conta remetente;D=Por conta destinat·rio;S=Sem frete
                  aAdd( aCliente, { "A1_TPFRET", cFreightType, Nil } )
               Endif
            EndIf
            //Transportadora
            If ( Type( "oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Carrier:_InternalId:Text" ) <> "U" )
               cCarrExtId := AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Carrier:_InternalId:Text)
            EndIf
            If ( Type( "oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Carrier:_CodeERP:Text" ) <> "U" )
               cCarrCode := AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Carrier:_CodeERP:Text)
            EndIf
                          
            cCarrier := Mati30Car(cCarrExtId, cCarrCode, cMarca)
            If !Empty(cCarrier) 
               aAdd(aCliente, {"A1_TRANSP", cCarrier, Nil})
            Endif	
            
            // Vencimento do Limite de Credito
            If ( Type( "oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CreditInformation:_MaturityCreditLimit:Text" ) <> "U" )
               cDatVenLim := AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_CreditInformation:_MaturityCreditLimit:Text)
               If !Empty(cDatVenLim)
                  aAdd(aCliente, {"A1_VENCLC", cTod(SubStr(cDatVenLim, 9, 2) + "/" + SubStr(cDatVenLim, 6, 2 ) + "/" + SubStr(cDatVenLim, 1, 4 )), Nil})
               Endif   
            EndIf
            // Informa se o clinete È contribuinte do icms, sendo 1=Sim;2=N„o
            If ( Type( "oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Taxpayer:Text" ) <> "U" )
               cTaxpayer := AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Taxpayer:Text)
               If cTaxpayer $ ('1/2')
					  	 aAdd(aCliente, {"A1_CONTRIB", cTaxpayer, Nil})
					Endif  
            EndIf
            
            If  ( Type( "oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_VendorInformation:_VendorType:_VendorInformationInternalID:Text" ) <> "U" )
               cVendExtId := Alltrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_VendorInformation:_VendorType:_VendorInformationInternalID:Text)
            Endif
            If !Empty(cVendExtId)
					cVendCode := Int030Vend(cVendExtId,cMarca)
				ElseIf ( Type( "oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_VendorInformation:_VendorType:_Code:Text" ) <> "U" )
               cVendCode  := Alltrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_VendorInformation:_VendorType:_Code:Text)
            Endif

            If !Empty(cVendCode)
					SA3->(dbSetOrder(1))
					If SA3->(dbSeek(xFilial("SA3") + cVendCode))
						aAdd(aCliente, {"A1_VEND", cVendCode, Nil})
					Endif
				Endif
				//======================================================================================================
				// DOCUMENTA«’ES DO CLIENTE
				//======================================================================================================
				// ObtÈm InscriÁ„o Estadual/InscriÁ„o Municipal/CNPJ/CPF do Cliente
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_Id") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_Id)
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_Id") != "A"
						XmlNode2Arr(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_Id, "_Id")
					EndIf

					nAux	:= Len(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_Id)
					For nX := 1 To nAux
						cValGov := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_Id[nX]:Text
						If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_Id["+cValtoChar(nX)+"]:_Name:Text") != "U"
							If RTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_Id[nX]:_Name:Text)) == "INSCRICAO ESTADUAL"
								aAdd(aCliente, {"A1_INSCR", cValGov, Nil})
							ElseIf RTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_Id[nX]:_Name:Text)) == "INSCRICAO MUNICIPAL"
								aAdd(aCliente, {"A1_INSCRM", cValGov, Nil})
							ElseIf RTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_Id[nX]:_Name:Text)) $ "CPF/CNPJ"
								aAdd(aCliente, {"A1_CGC", cValGov, Nil})
							ElseIf RTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_Id[nX]:_Name:Text)) == "SUFRAMA"
								aAdd(aCliente, {"A1_SUFRAMA", cValGov, Nil})
							ElseIf RTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_Id[nX]:_Name:Text)) == "PASSAPORTE" .AND. cPaisLoc == "BRA"
								aAdd(aCliente, {"A1_PFISICA", cValGov, Nil})
							ElseIf RTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_Id[nX]:_Name:Text)) == "RG" .AND. cPaisLoc == "BRA"
								aAdd(aCliente, {"A1_PFISICA", cValGov, Nil})
								aAdd(aCliente, {"A1_RG", cValGov, Nil})
							ElseIf RTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_GovernmentalInformation:_Id[nX]:_Name:Text)) == "INSCRICAO RURAL"
								aAdd(aCliente, {"A1_INSCRUR", cValGov, Nil})

							EndIf
						EndIf
					Next nX
				EndIf

				//======================================================================================================
				// INFORMA«’ES DE CONTATO COM O CLIENTE
				//======================================================================================================
				// ObtÈm a Caixa Postal
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_POBox:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_POBox:Text)
					aAdd(aCliente, {"A1_CXPOSTA", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_POBox:Text, Nil})
				EndIf

				// ObtÈm o E-Mail
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_Email:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_Email:Text)
					aAdd(aCliente, {"A1_EMAIL", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_Email:Text, Nil})
				EndIf

				// ObtÈm o N˙mero do Telefone
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_PhoneNumber:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_PhoneNumber:Text)
					cStringTemp:= RemCharEsp(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_PhoneNumber:Text)

					aTelefone := RemDddTel(cStringTemp)
					aAdd(aCliente, {"A1_TEL",aTelefone[1], Nil})

					If !Empty(aTelefone[2])
						If Len(AllTrim(aTelefone[2])) == 2
							aTelefone[2] := "0" + aTelefone[2]
						Endif
						aAdd(aCliente, {"A1_DDD",aTelefone[2], Nil})
					Elseif ( Type( "oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_DiallingCode:Text" ) <> "U" )
					 	nTamA1_DDD := TamSX3("A1_DDD")[1]
					 	cStringTemp:= AllTrim(RemCharEsp(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_DiallingCode:Text))
						aTelefone[2] := PadL(cStringTemp, nTamA1_DDD, "0")
						aAdd(aCliente, {"A1_DDD",aTelefone[2], Nil})
					EndIf

					If !Empty(aTelefone[3])
						aAdd(aCliente, {"A1_DDI",aTelefone[3], Nil})
					ElseIF ( Type( "oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_InternationalDiallingCode:Text" ) <> "U" )
						cStringTemp:= RemCharEsp(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_InternationalDiallingCode:Text)
						aTelefone[3] := allTrim(cStringTemp)
						aAdd(aCliente, {"A1_DDI",aTelefone[3], Nil})
					EndIf
				EndIf

				// ObtÈm o N˙mero do Fax do Cliente
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_FaxNumber:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_FaxNumber:Text)
					cStringTemp:= RemCharEsp(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_FaxNumber:Text)
					aTelefone := RemDddTel(cStringTemp)
					
					Aadd( aCliente, { "A1_FAX",aTelefone[1],   Nil })
				EndIf

				// ObtÈm a Home-Page
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_HomePage:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_HomePage:Text)
					aAdd(aCliente, {"A1_HPAGE", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfCommunicationInformation:_CommunicationInformation:_HomePage:Text, Nil}) // Home-Page
				EndIf

				// ObtÈm o Contato na Empresa
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfContacts:_Contact:_ContactInformationName:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfContacts:_Contact:_ContactInformationName:Text)
					aAdd(aCliente, {"A1_CONTATO", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfContacts:_Contact:_ContactInformationName:Text, Nil})
				EndIf

				//======================================================================================================
				// ENDERE«O DE COBRAN«A DO CLIENTE
				//======================================================================================================
				// ObtÈm o End. de Cobr. do Cliente
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_Address:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_Address:Text)
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_Number:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_Number:Text)
						aAdd(aCliente, {"A1_ENDCOB", AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_Address:Text) + ", " + oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_Number:Text, Nil})
					Else
						aAdd(aCliente, {"A1_ENDCOB", AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_Address:Text), Nil})
					EndIf
				EndIf

				// ObtÈm o Bairro de CobranÁa
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_District:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_District:Text)
					aAdd(aCliente, {"A1_BAIRROC", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_District:Text, Nil})
				EndIf

				// ObtÈm o Cep de CobranÁa
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_ZIPCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_ZIPCode:Text)
					aAdd(aCliente, {"A1_CEPC", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_ZIPCode:Text, Nil})
				EndIf

				// ObtÈm o MunicÌpio de CobranÁa
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_City:_CityDescription:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_City:_CityDescription:Text)   
					aAdd(aCliente, {"A1_MUNC", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_City:_CityDescription:Text, Nil})
				EndIf

				// ObtÈm a Uf de CobranÁa
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_State:_StateCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_State:_StateCode:Text)
					aAdd(aCliente, {"A1_ESTC", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_BillingInformation:_Address:_State:_StateCode:Text, Nil})
				EndIf

				//======================================================================================================
				// ENDERE«O DE ENTREGA DO CLIENTE
				//======================================================================================================
				// ObtÈm o End. de Entr. do Cliente
				If ( Type( "oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_Address:Text" ) <> "U" )

               cEndEnt :=  AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_Address:Text)
               If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_Number:Text") <> "U"
						If !Empty(AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_Number:Text))
							cEndEnt += ", " + AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_Number:Text)
						Endif
					Endif
					cEndEnt := AllTrim(Upper(cEndEnt))
					
					Aadd( aCliente, { "A1_ENDENT",cEndEnt, Nil })
				
					If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_Complement:Text") <> "U"
						If !Empty(AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_Complement:Text))
							cCompEndEnt := AllTrim(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_Complement:Text)
						Endif
					Endif
					cCompEndEnt := AllTrim(Upper(cCompEndEnt))
					
					Aadd( aCliente, { "A1_COMPENT",cCompEndEnt, Nil })
				EndIf

            // ObtÈm o Cep de Entrega
            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_ZIPCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_ZIPCode:Text)
               aAdd(aCliente, {"A1_CEPE", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_ZIPCode:Text, Nil})
            EndIf

            // ObtÈm o Bairro de Entrega
            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_District:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_District:Text)
               aAdd(aCliente, {"A1_BAIRROE", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_District:Text, Nil})
            EndIf

            // ObtÈm o Estado de Entrega
            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_State:_StateCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_State:_StateCode:Text)
               aAdd(aCliente, {"A1_ESTE", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_State:_StateCode:Text, Nil})
            EndIf

            // ObtÈm o MunicÌpio da Entrega
            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_City:_CityCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_City:_CityCode:Text)
               cMunEnt := Right(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_City:_CityCode:Text, 5)
               aAdd(aCliente, {"A1_CODMUNE", cMunEnt, Nil } )
            EndIf

            // ObtÈm a descriÁ„o do MunicÌpio de Entrega
            If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_City:_CityDescription:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_City:_CityDescription:Text)
               aAdd(aCliente, {"A1_MUNE", oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ShippingAddress:_City:_CityDescription:Text, Nil})
            EndIf

				//======================================================================================================
				// OUTRAS INFORMA«’ES DO CLIENTE
				//======================================================================================================
				// ObtÈm Bloqueia o Cliente?
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterSituation:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterSituation:Text)
					If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterSituation:Text) == 'ACTIVE'
						aAdd(aCliente, {"A1_MSBLQL", "2", Nil})
					Else
						aAdd(aCliente, {"A1_MSBLQL", "1", Nil})
					EndIf
				Else
					If !lHotel //Case seja integraÁ„o com hotelaria, e essa tag esteja vazia, n„o muda o status para bloqueado
						aAdd(aCliente, {"A1_MSBLQL", "1", Nil})
					Endif
				EndIf

				// ObtÈm a Data de Nasc. ou Abertura
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text)
					aAdd(aCliente, {"A1_DTNASC", CTOD(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_RegisterDate:Text), Nil})
                EndIf

                // Grava o campo "A1_ORIGEM" somente se for integracao com HIS
                If Alltrim(cMarca)=="HIS"
                	aAdd( aCliente, { "A1_ORIGEM", "S1", Nil } )
                EndIf
            EndIf

            //Ponto de entrada para incluir campos no array aCliente
            If ExistBlock("MTI030NOM")
               aRetPe := ExecBlock("MTI030NOM",.F.,.F.,{aCliente,oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Name:Text})
               If ValType(aRetPe) == "A" .And. Len(aRetPe) >0
                  If ValType(aRetPe) == "A"
                     aCliente := aClone(aRetPe)
                  EndIf
               EndIf
            EndIf
				
            //Ordena Array conforme dicionario de dados
            aCliente := FWVetByDic(aCliente /*aVetor*/, "SA1" /*cTable*/, .F./*lItens*/, /*nCpoPos*/)

            // Executa Rotina Autom·tica conforme evento
            Eval( bRotAut )

            // Se a Rotina Autom·tica retornou erro
            If lMsErroAuto
               // ObtÈm o log de erros
               aErroAuto := GetAutoGRLog()

               // Varre o array obtendo os erros e quebrando a linha
               cXmlRet := "<![CDATA["
               nAux	:= Len(aErroAuto)
               For nCount := 1 to nAux
                  cXmlRet += aErroAuto[nCount] + CRLF
               Next nCount
               cXmlRet += "]]>"

               lRet := .F.
               //Cancela a utilizaÁ„o do cÛdigo sequencial
               If (lHotel .Or. lGetXnum ) .And. !lIniPadCod
               		RollBackSX8()
               Endif               
            Else
               // CRUD do XXF (de/para)
               If nOpcx == 3 // Insert
                  cValInt := IntCliExt(, , SA1->A1_COD, SA1->A1_LOJA)[2]
                  CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F.,,,cOwnerMsg)
                  
                  //Confirma a utilizaÁ„o do cÛdigo sequencial
                  If (lHotel .Or. lGetXnum ).AND. ! lIniPadCod
                  	ConfirmSX8()
				      Endif
               ElseIf nOpcx = 4 // Update
                     // se for integracao com o HIS e n„o houver internalId, 
                     // ent„o o His esta sincronizando o cliente dele com a do Protheus.
                     // necessitando a geracao do internalId
                     If Alltrim(cMarca)=="HIS" .AND. Empty(cValInt) 
                        cValInt := IntCliExt(, , SA1->A1_COD, SA1->A1_LOJA)[2]
                     EndIf
                     CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F.,,,cOwnerMsg) 
               Else  // Delete
                  CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .T.,,,cOwnerMsg) 
               EndIf
               
               lRet := .T.
               // Monta o XML de Retorno
               cXmlRet := "<ListOfInternalId>"
               cXmlRet +=    "<InternalId>"
               cXmlRet +=       "<Name>CustomerVendor</Name>"
               cXmlRet +=       "<Origin>" + cValExt + "</Origin>"
               cXmlRet +=       "<Destination>" + cValInt + "</Destination>"
               cXmlRet +=    "</InternalId>"
               cXmlRet += "</ListOfInternalId>"
            EndIf

         ElseIf AllTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text)) == "VENDOR" .OR. AllTrim(Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Type:Text)) == "2" 
            aRet := FWIntegDef("MATA030", cTypeMessage, nTypeTrans, cXml)

            If ValType(aRet) == "A"
	            If !Empty(aRet)
	               lRet := aRet[1]
	               cXmlRet := aRet[2]
	            EndIf
	         Endif
         EndIf
      ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
         // Se n„o houve erros na resposta
         If Upper(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK"
            // Verifica se a marca foi informada
            If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text)
               cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
            Else
               lRet    := .F.
               cXmlRet := STR0021 // "Erro no retorno. O Product È obrigatÛrio!"
               Return {lRet, cXmlRet}
            EndIf

            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId") <> "U"
	            // Verifica se o cÛdigo interno foi informado
	            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text)
	               cValInt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0022 // "Erro no retorno. O OriginalInternalId È obrigatÛrio!"
	               Return {lRet, cXmlRet}
	            EndIf
	
	            // Verifica se o cÛdigo externo foi informado
	            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text)
	               cValExt := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0023 // "Erro no retorno. O DestinationInternalId È obrigatÛrio"
	               Return {lRet, cXmlRet}
	            EndIf
	
	            // ObtÈm a mensagem original enviada
	            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") != "U" .And. !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text)
	               cXML := oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
	            Else
	               lRet    := .F.
	               cXmlRet := STR0024 // "Conte˙do do MessageContent vazio!"
	               Return {lRet, cXmlRet}
	            EndIf
	
	            // Faz o parse do XML em um objeto
	            oXML := XmlParser(cXML, "_", @cError, @cWarning)

                //Valida valor interno para saber se trata de um fornecedor ou cliente.
                aAuxVInt := Separa(cValInt,"|")
                If Len(aAuxVInt) == 5
                    If AllTrim(Upper(aAuxVInt[5])) == "F"
                        cAlias := "SA2"
                        cField := "A2_COD"  
                    Endif
                Endif
	
	            // Se n„o houve erros no parse
	            If oXML != Nil .And. Empty(cError) .And. Empty(cWarning)
	               If Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
	                  // Insere / Atualiza o registro na tabela XXF (de/para)
	                  CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .F.,,,cOwnerMsg) 
	               ElseIf Upper(oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "DELETE"
	                  // Exclui o registro na tabela XXF (de/para)
	                  CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, .T.,,,cOwnerMsg) 
	               Else
	                  lRet := .F.
	                  cXmlRet := STR0025 // "Evento do retorno inv·lido!"
	               EndIf
	            Else
	               lRet := .F.
	               cXmlRet := STR0026 // "Erro no parser do retorno!"
	               Return {lRet, cXmlRet}
	            EndIf
	         Endif
         Else
            // Se n„o for array
            If Type("oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message") != "A"
               // Transforma em array
               XmlNode2Arr(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
            EndIf

            // Percorre o array para obter os erros gerados
            nAux	:= Len(oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
            For nCount := 1 To nAux
               cError := oXML:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + CRLF
            Next nCount

            lRet := .F.
            cXmlRet := cError
         EndIf
      ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
         cXmlRet := "1.000|2.000|2.001|2.002|2.003|2.004|2.005"
      EndIf
   ElseIf(nTypeTrans == TRANS_SEND)
   
   	  If cRotina == "MATA030"
   	  	  If(!Inclui .And. !Altera)
	         cEvent := "delete"
	      EndIf
	  Else
	  	  oModel := FwModelActive()
		  If oModel:GetOperation() == MODEL_OPERATION_DELETE
		     cEvent := 'delete'
		  EndIf
	  EndIf
      
      If cEvent == "delete"
      	 CFGA070Mnt(,"SA1","A1_COD",,IntCliExt(, , SA1->A1_COD, SA1->A1_LOJA)[2],.T.,,,cOwnerMsg) 
      EndIf
     
      // Trata endereÁo separando Logradouro e N˙mero
      cLograd := trataEnd(SA1->A1_END, "L")
      cNumero := trataEnd(SA1->A1_END, "N")

      // Retorna o codigo do estado a partir da sigla
      cCodEst  := Tms120CdUf(SA1->A1_EST, '1')

      // Codigo do estado de entrega
      cCodEstE:= Tms120CdUf(SA1->A1_ESTE, '1')

      // Envio do codigo de acordo com padrao IBGE (cod. estado + cod. municipio)
      If(!Empty(SA1->A1_COD_MUN))
         cCodMun := Rtrim(cCodEst) + Rtrim(SA1->A1_COD_MUN)
      Endif

      // Codigo do municipio de entrega
      If cPaisLoc $ "ANG|BRA|EQU|HAI|PTG" .And. !Empty(SA1->A1_CODMUNE)
         cCodMunE := Rtrim(cCodEstE)  + Rtrim(SA1->A1_CODMUNE)
      EndIf

      cXMLRet := '<BusinessEvent>'
      cXMLRet +=     '<Entity>CustomerVendor</Entity>'
      cXMLRet +=     '<Event>' + cEvent + '</Event>'
      cXMLRet +=     '<Identification>'
      cXMLRet +=         '<key name="InternalId">' + IntCliExt(, , SA1->A1_COD, SA1->A1_LOJA)[2] + '</key>'
      cXMLRet +=     '</Identification>'
      cXMLRet += '</BusinessEvent>'

      cXMLRet += '<BusinessContent>'
      cXMLRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
      cXMLRet +=    '<BranchId>' + cFilAnt + '</BranchId>'
      cXMLRet +=    '<BranchInternalId>' + cEmpAnt + '|' + cFilAnt + '</BranchInternalId>'
      cXMLRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
      cXMLRet +=    '<Code>' + Rtrim(SA1->A1_COD) + '</Code>'
      cXMLRet +=    '<StoreId>' + Rtrim(SA1->A1_LOJA) + '</StoreId>'
      cXMLRet +=    '<InternalId>' + IntCliExt(, , SA1->A1_COD, SA1->A1_LOJA)[2] + '</InternalId>'
      cXMLRet +=    '<ShortName>' + _NoTags(Rtrim(SA1->A1_NREDUZ)) + '</ShortName>'
      cXMLRet +=    '<Name>' + _NoTags(Rtrim(SA1->A1_NOME)) + '</Name>'
      cXMLRet +=    '<Type>' + 'Customer' + '</Type>'

      If SA1->A1_PESSOA == 'F'
         cXMLRet += '<EntityType>' + 'Person' + '</EntityType>'
         cCNPJCPF := 'CPF'
      Else
         cXMLRet += '<EntityType>' + 'Company' + '</EntityType>'
         cCNPJCPF := 'CNPJ'
      EndIf

      If (!Empty(SA1->A1_DTNASC))
         cXMLRet += '<RegisterDate>' + SubStr(DToC(SA1->A1_DTNASC), 7, 4) + '-' + SubStr(DToC(SA1->A1_DTNASC), 4, 2) + '-' + SubStr(DToC(SA1->A1_DTNASC), 1, 2) + '</RegisterDate>'
      EndIf

      If SA1->A1_MSBLQL == '1'
         cXMLRet += '<RegisterSituation>' + "Inactive" + '</RegisterSituation>'
      Else
         cXMLRet += '<RegisterSituation>' + "Active" + '</RegisterSituation>'
      EndIf

      If !Empty(SA1->A1_INSCR) .Or. !Empty(SA1->A1_INSCRM) .Or. !Empty(SA1->A1_CGC) .Or. !Empty(SA1->A1_SUFRAMA) .or. !Empty(SA1->A1_INSCRUR)
         cXMLRet +=    '<GovernmentalInformation>'
         cXMLRet +=       IIf(!Empty(SA1->A1_INSCR), '<Id name="INSCRICAO ESTADUAL" scope="State">' + Rtrim(SA1->A1_INSCR) + '</Id>', '')
         cXMLRet +=       IIf(!Empty(SA1->A1_INSCRM), '<Id name="INSCRICAO MUNICIPAL" scope="Municipal">' + Rtrim(SA1->A1_INSCRM) + '</Id>', '')
         cXMLRet +=       IIf(!Empty(SA1->A1_CGC), '<Id name="' + cCNPJCPF + '" scope="Federal">' + Rtrim(SA1->A1_CGC) + '</Id>', '')
         cXMLRet +=       IIf(!Empty(SA1->A1_SUFRAMA), '<Id name="SUFRAMA" scope="Federal">' + Rtrim(SA1->A1_SUFRAMA) + '</Id>', '')
         cXMLRet +=       IIf(!Empty(SA1->A1_INSCRUR), '<Id name="INSCRICAO RURAL" scope="State">' + Rtrim(SA1->A1_INSCRUR) + '</Id>', '')
         cXMLRet +=    '</GovernmentalInformation>'
      EndIf

      If !Empty(SA1->A1_SATIV1) .Or. !Empty(SA1->A1_SATIV2) .Or. !Empty(SA1->A1_SATIV3) .Or. !Empty(SA1->A1_SATIV4);
		   .Or. !Empty(SA1->A1_SATIV5) .Or. !Empty(SA1->A1_SATIV6) .Or. !Empty(SA1->A1_SATIV7) .Or. !Empty(SA1->A1_SATIV8)
         cXMLRet += '<Segment>'
         cXMLRet +=      Iif(!Empty(SA1->A1_SATIV1),'<InternalId Name="Segment1" CodeErp="' + RTrim(SA1->A1_SATIV1) + '" Description="' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV1, "X5DESCRI()" )) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + Rtrim(SA1->A1_SATIV1)   + '</InternalId>', "")
         cXMLRet +=      Iif(!Empty(SA1->A1_SATIV2),'<InternalId Name="Segment2" CodeErp="' + RTrim(SA1->A1_SATIV2) + '" Description="' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV2, "X5DESCRI()" )) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + Rtrim(SA1->A1_SATIV2)   + '</InternalId>', "")
         cXMLRet +=      Iif(!Empty(SA1->A1_SATIV3),'<InternalId Name="Segment3" CodeErp="' + RTrim(SA1->A1_SATIV3) + '" Description="' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV3, "X5DESCRI()" )) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + Rtrim(SA1->A1_SATIV3)   + '</InternalId>', "")
         cXMLRet +=      Iif(!Empty(SA1->A1_SATIV4),'<InternalId Name="Segment4" CodeErp="' + RTrim(SA1->A1_SATIV4) + '" Description="' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV4, "X5DESCRI()" )) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + Rtrim(SA1->A1_SATIV4)   + '</InternalId>', "")
         cXMLRet +=      Iif(!Empty(SA1->A1_SATIV5),'<InternalId Name="Segment5" CodeErp="' + RTrim(SA1->A1_SATIV5) + '" Description="' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV5, "X5DESCRI()" )) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + Rtrim(SA1->A1_SATIV5)   + '</InternalId>', "")
         cXMLRet +=      Iif(!Empty(SA1->A1_SATIV6),'<InternalId Name="Segment6" CodeErp="' + RTrim(SA1->A1_SATIV6) + '" Description="' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV6, "X5DESCRI()" )) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + Rtrim(SA1->A1_SATIV6)   + '</InternalId>', "")
         cXMLRet +=      Iif(!Empty(SA1->A1_SATIV7),'<InternalId Name="Segment7" CodeErp="' + RTrim(SA1->A1_SATIV7) + '" Description="' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV7, "X5DESCRI()" )) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + Rtrim(SA1->A1_SATIV7)   + '</InternalId>', "")
         cXMLRet +=      Iif(!Empty(SA1->A1_SATIV8),'<InternalId Name="Segment8" CodeErp="' + RTrim(SA1->A1_SATIV8) + '" Description="' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV8, "X5DESCRI()" )) + '">' + cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + Rtrim(SA1->A1_SATIV8)   + '</InternalId>', "")
         cXMLRet += '</Segment>'
      Endif

      //Enviando o Tipo de Frete.
      If !Empty(SA1->A1_TPFRET) // C=CIF;F=FOB;T=Por conta terceiros;R=Por conta remetente;D=Por conta destinat·rio;S=Sem frete                                    
         Do Case
            Case SA1->A1_TPFRET == 'C' 
               cFreightDesc := "CIF"
            Case SA1->A1_TPFRET == 'F' 
               cFreightDesc := "FOB"
            Case SA1->A1_TPFRET == 'T' 
               cFreightDesc := "Por conta terceiros"
            Case SA1->A1_TPFRET == 'R' 
               cFreightDesc := "Por conta remetente"
            Case SA1->A1_TPFRET == 'D' 
               cFreightDesc := "Por conta destinat·rio"
            Case SA1->A1_TPFRET == 'S' 
               cFreightDesc := "Sem frete"
            Otherwise
               cFreightDesc := "" 
         Endcase	
         cXMLRet += '<FreightType>'
         cXMLRet +=     '<Code>'        + SA1->A1_TPFRET + '</Code>'
         cXMLRet +=     '<Description>' + cFreightDesc   + '</Description>'
         cXMLRet += '</FreightType>' 
      Endif	
      //Transportadora
      If !Empty(SA1->A1_TRANSP) 
         cXMLRet += '<Carrier>'
         cXMLRet +=     '<CodeERP>'     + RTrim(SA1->A1_TRANSP)                                                             + '</CodeERP>'
         cXMLRet +=     '<InternalId>'  + cEmpAnt + "|" + Alltrim(xFilial("SA4")) + "|" + RTRIM(SA1->A1_TRANSP)    + '</InternalId>'
         cXMLRet +=     '<Description>' + Rtrim(Posicione("SA4",1, xFilial("SA4") + SA1->A1_TRANSP, "A4_NOME" ))  + '</Description>'
         cXMLRet += '</Carrier>' 
      Endif	
      cXMLRet +=    '<Address>'
      cXMLRet +=       '<Address>' + Rtrim(cLograd) + '</Address>'
      cXMLRet +=       '<Number>' + Rtrim(cNumero) + '</Number>'
      cXMLRet +=       '<Complement>' + Iif(Empty(SA1->A1_COMPLEM),_NoTags(trataEnd(SA1->A1_END,"C")),_NoTags(Rtrim(SA1->A1_COMPLEM))) + '</Complement>'
      If !Empty(cCodMun) .Or. !Empty(SA1->A1_MUN)
         cXMLRet +=    '<City>'
         If !Empty(cCodMun)
            cXMLRet +=    '<CityCode>' + cCodMun + '</CityCode>'
            cXMLRet +=    '<CityInternalId>' + cCodMun + '</CityInternalId>'
         Else
            cXMLRet +=    '<CityCode/>'
            cXMLRet +=    '<CityInternalId/>'
         EndIf
         cXMLRet +=       '<CityDescription>' + Rtrim(SA1->A1_MUN) + '</CityDescription>'
         cXMLRet +=    '</City>'
      EndIf
      cXMLRet +=       '<District>' + Rtrim(SA1->A1_BAIRRO) + '</District>'
      If !Empty(SA1->A1_EST)
         cXMLRet +=    '<State>'
         cXMLRet +=       '<StateCode>' + SA1->A1_EST + '</StateCode>'
         cXMLRet +=       '<StateInternalId>' + SA1->A1_EST + '</StateInternalId>'
         cXMLRet +=       '<StateDescription>' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "12" + SA1->A1_EST, "X5DESCRI()" )) + '</StateDescription>'
         cXMLRet +=    '</State>'
      EndIf
      If !Empty(SA1->A1_PAIS)
         cXMLRet +=    '<Country>'
         cXMLRet +=       '<Code>' + SA1->A1_PAIS + '</Code>'
         cXMLRet +=       '<CountryInternalId>' + SA1->A1_PAIS + '</CountryInternalId>'
         cXMLRet +=       '<Description>' + Rtrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR")) + '</Description>' 
         cXMLRet +=    '</Country>'
      EndIf
      If !Empty(SA1->A1_REGIAO)
        cXMLRet += '<Region>'
        cXMLRet +=      '<RegionCode>'        + Rtrim(SA1->A1_REGIAO)                                                            + '</RegionCode>'
        cXMLRet +=      '<RegionInternalId>'  + cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + Rtrim(SA1->A1_REGIAO)            + '</RegionInternalId>'
        cXMLRet +=      '<RegionDescription>' + Rtrim(Posicione("SX5",1, xFilial("SX5") + "A2" + SA1->A1_REGIAO, "X5DESCRI()" )) + '</RegionDescription>' 
        cXMLRet += '</Region>'
      EndIf

      cXMLRet +=       '<ZIPCode>' + Rtrim(SA1->A1_CEP) + '</ZIPCode>'
      cXMLRet +=       '<POBox>' + Rtrim(SA1->A1_CXPOSTA) + '</POBox>'
      cXMLRet +=    '</Address>'

      // EndereÁo de entrega
      If !Empty(SA1->A1_ENDENT) .Or. !Empty(SA1->A1_MUNE) .Or. !Empty(SA1->A1_BAIRROE) .Or. !Empty(SA1->A1_ESTE) .Or. !Empty(SA1->A1_CEPE)
         cXMLRet += '<ShippingAddress>'
         cXMLRet +=    '<Address>' + _NoTags(trataEnd(SA1->A1_ENDENT,"L")) + '</Address>'
         cXMLRet +=    '<Number>' + trataEnd(SA1->A1_ENDENT,"N") + '</Number>'
         cXMLRet +=    '<Complement>' + Iif(Empty(SA1->A1_COMPENT),_NoTags(trataEnd(SA1->A1_ENDENT,"C")),_NoTags(Rtrim(SA1->A1_COMPENT))) + '</Complement>'
         If !Empty(cCodMunE) .And. !Empty(SA1->A1_MUNE)
            cXMLRet += '<City>'
            cXMLRet +=    IIF(Empty(cCodMunE), '<CityCode/>', '<CityCode>' + cCodMunE + '</CityCode>')
            cXMLRet +=    '<CityDescription>' + Rtrim(SA1->A1_MUNE) + '</CityDescription>'
            cXMLRet += '</City>'
         EndIf
         cXMLRet +=       '<District>' + Rtrim(SA1->A1_BAIRROE) + '</District>'
         If !Empty(SA1->A1_ESTE)
            cXMLRet += '<State>'
            cXMLRet +=    '<StateCode>' + Rtrim(SA1->A1_ESTE) + '</StateCode>'
            cXMLRet += '</State>'
         EndIf
         cXMLRet +=    '<ZIPCode>' + Rtrim(SA1->A1_CEPE) + '</ZIPCode>'
         cXMLRet += '</ShippingAddress>'
      EndIf

      // Formas de contato
      If !Empty(SA1->A1_TEL) .Or. !Empty(SA1->A1_FAX) .Or. !Empty(SA1->A1_HPAGE) .Or. !Empty(SA1->A1_EMAIL)
      	  	If !Empty(SA1->A1_DDI)
				cTel := AllTrim(SA1->A1_DDI)
			Endif
		
			If !Empty(SA1->A1_DDD)
				If !Empty(cTel)
					cTel += AllTrim(SA1->A1_DDD)
				Else
					cTel := AllTrim(SA1->A1_DDD)
				Endif
			Endif
		
			If !Empty(cTel)
				cTel += AllTrim(SA1->A1_TEL)
			Else
				cTel := AllTrim(SA1->A1_TEL)
			Endif
         cXMLRet += '<ListOfCommunicationInformation>'
         cXMLRet +=    '<CommunicationInformation>'
         cXMLRet +=       '<PhoneNumber>' + cTel + '</PhoneNumber>'
         cXMLRet +=       '<FaxNumber>' +  Rtrim(SA1->A1_FAX) + '</FaxNumber>'
         cXMLRet +=       '<HomePage>' + _NoTags(Rtrim(SA1->A1_HPAGE)) + '</HomePage>'
         cXMLRet +=       '<Email>' + _NoTags(Rtrim(SA1->A1_EMAIL)) + '</Email>'
         cXMLRet +=    '</CommunicationInformation>'
         cXMLRet += '</ListOfCommunicationInformation>'
      EndIf

      // Contato
      If !Empty(SA1->A1_CONTATO)
         cXMLRet += '<ListOfContacts>'
         cXMLRet +=    '<Contact>'
         cXMLRet +=       '<ContactInformationName>' + _NoTags(Rtrim(SA1->A1_CONTATO)) + '</ContactInformationName>'
         cXMLRet +=    '</Contact>'
         cXMLRet += '</ListOfContacts>'
      EndIf

      // EndereÁo de cobranÁa
      If !Empty(SA1->A1_ENDCOB) .Or. !Empty(SA1->A1_MUNC) .Or. !Empty(SA1->A1_BAIRROC) .Or. !Empty(SA1->A1_ESTC) .Or. !Empty(SA1->A1_CEPC)
         cXMLRet += '<BillingInformation>'
         cXMLRet +=    '<Address>'
         cXMLRet +=    	'<Address>' + _NoTags(trataEnd(SA1->A1_ENDCOB,"L")) + '</Address>'
         cXMLRet +=    	'<Number>' + trataEnd(SA1->A1_ENDCOB,"N") + '</Number>'
         cXMLRet +=    	'<Complement>' + _NoTags(trataEnd(SA1->A1_ENDCOB,"C")) + '</Complement>'
         If !Empty(SA1->A1_MUNC)
            cXMLRet +=    '<City>'
            cXMLRet +=       '<CityDescription>' + _NoTags(Rtrim(SA1->A1_MUNC)) + '</CityDescription>'
            cXMLRet +=    '</City>'
         EndIf
         cXMLRet +=       '<District>'+ _NoTags(Rtrim(SA1->A1_BAIRROC))+ '</District>'
         If !Empty(SA1->A1_ESTC)
           cXMLRet +=     '<State>'
           cXMLRet +=        '<StateCode>' + SA1->A1_ESTC + '</StateCode>'
           cXMLRet +=     '</State>'
         EndIf
         cXMLRet +=       '<ZIPCode>' + Rtrim(SA1->A1_CEPC) + '</ZIPCode>'
         cXMLRet +=    '</Address>'
         cXMLRet += '</BillingInformation>'
      EndIf

      // Vendedor
      If !Empty(SA1->A1_VEND)
         cXMLRet += '<VendorInformation>'
         cXMLRet +=    '<VendorType>'
         cXMLRet +=       '<Code>' + SA1->A1_VEND + '</Code>'
         cXMLRet +=    '</VendorType>'
         cXMLRet += '</VendorInformation>'
      EndIf

      // Limite de CrÈdito
      If !Empty(SA1->A1_LC) .or. !Empty(SA1->A1_VENCLC)
         cXMLRet += '<CreditInformation>'
         cXMLRet +=    '<CreditLimit>' + cValToChar(SA1->A1_LC) + '</CreditLimit>'
         cXMLRet +=    '<MaturityCreditLimit>' + Transform(DtoS(SA1->A1_VENCLC),'@R 9999-99-99') + '</MaturityCreditLimit>'
         cXMLRet += '</CreditInformation>'
      EndIf
		
      IF !Empty(SA1->A1_CONTRIB)
         cXMLRet += '<Taxpayer>' + SA1->A1_CONTRIB + '</Taxpayer>'
		Endif

      If ExistBlock("MT030jix")
			cAddXml := ExecBlock("MT030jix",.F.,.F.,{cEvent,oModel})
			If ValType(cAddXml) == "C" .And. !( Empty( cAddXml ) )
				cXMLRet += cAddXml
			EndIf
		EndIf

      cXMLRet += '</BusinessContent>'
   EndIf

Return {lRet, cXmlRet}

// --------------------------------------------------------------------------------------
/*/{Protheus.doc} trataEnd
Trata o endereÁo separando logradouro de n˙mero

@param   cEndereco EndereÁo completo com logradouro e n˙mero
@param   cTipo Tipo que se deseja obter do endereÁo L=Logradouro ou N=N˙mero

@author  Leandro Luiz da Cruz
@version P11
@since   13/09/2012
@return  cResult Variavel com o valor obtido
/*/
// --------------------------------------------------------------------------------------

Function trataEnd(cEnd, cTipo)
    Local cResult		:= ""
    Local aEnd		:= {}
    
    If(At(",", cEnd) != 0)
    	aEnd := Separa(cEnd,",")
    	If Len(aEnd) == 2
    		If Upper(cTipo) == "L"
    			cResult := AllTrim(aEnd[1])
    		Elseif Upper(cTipo) == "N"
    			cResult := AllTrim(aEnd[2])
    		Endif
    	Elseif	Len(aEnd) > 2
    		If Upper(cTipo) == "L"
    			cResult := AllTrim(aEnd[1])
    		Elseif Upper(cTipo) == "N"
    			cResult := AllTrim(aEnd[2])
    		Elseif Upper(cTipo) == "C"
    			cResult := AllTrim(aEnd[3])
    		Endif
    	Endif
    Else
    	If(Upper(cTipo) == "L")
          cResult := cEnd
       EndIf
    Endif
Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntCliExt
Monta o InternalID do Cliente de acordo com o cÛdigo passado
no par‚metro.

@param   cEmpresa   CÛdigo da empresa (Default cEmpAnt)
@param   cFil       CÛdigo da Filial (Default cFilAnt)
@param   cCliente   CÛdigo do Cliente
@param   cLoja      CÛdigo da Loja do Cliente
@param   cVersao    Vers„o da mensagem ˙nica (Default 2.000)

@author  Leandro Luiz da Cruz
@version P11
@since   08/02/2013
@return  aResult Array contendo no primeiro par‚metro uma vari·vel
         lÛgica indicando se o registro foi encontrado.
         No segundo par‚metro uma vari·vel string com o InternalID
         montado.

@sample  IntCliExt(, , '00001', '01') ir· retornar {.T., '01|01|00001|01|C'}
/*/
//-------------------------------------------------------------------
Function IntCliExt(cEmpresa, cFil, cCliente, cLoja, cVersao)
   Local   aResult  := {}
   Default cEmpresa := cEmpAnt
   Default cFil     := xFilial('SA1')
   Default cVersao  := '2.000'

   // alterado por Frank Fuga em 25/08/2022
   If empty(cVersao)
      cVersao  := '2.000'
   EndIF
   If cVersao == '1.000'
      aAdd(aResult, .T.)
      aAdd(aResult, PadR(cCliente, TamSX3('A1_COD')[1]) + PadR(cLoja, TamSX3('A1_LOJA')[1]))
   ElseIf cVersao == '2.000' .Or.  cVersao == '2.001' .Or. cVersao == '2.002' .Or. cVersao == '2.003' .Or. cVersao == '2.004' .Or. cVersao == '2.005'
      aAdd(aResult, .T.)
      aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cCliente) + '|' + RTrim(cLoja) + '|C')
   Else
      aAdd(aResult, .F.)
      aAdd(aResult, STR0030 + Chr(10) + STR0034 + "1.000, 2.000, 2.001, 2.002, 2.003, 2.004, 2.005") //"Vers„o n„o suportada.", "As versıes suportadas s„o: "
   EndIf
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntCliInt
Recebe um InternalID e retorna o cÛdigo do Cliente.

@param   cInternalID InternalID recebido na mensagem.
@param   cRefer      Produto que enviou a mensagem
@param   cVersao     Vers„o da mensagem ˙nica (Default 2.000)

@author  Leandro Luiz da Cruz
@version P11
@since   08/02/2013
@return  aResult Array contendo no primeiro par‚metro uma vari·vel
         lÛgica indicando se o registro foi encontrado no de/para.
         No segundo par‚metro uma vari·vel array com a empresa,
         filial, o cÛdigo do cliente e a loja do cliente.

@sample  IntLocInt('01|01|00001|01') ir· retornar
{.T., {'01', '01', '00001', '01', 'C'}}
/*/
//-------------------------------------------------------------------
Function IntCliInt(cInternalID, cRefer, cVersao)
   Local   aResult  := {}
   Local   aTemp    := {}
   Local   cTemp    := ''
   Local   cAlias   := 'SA1'
   Local   cField   := 'A1_COD'
   Default cVersao  := '2.000'

   If empty(cVersao)
      cVersao  := '2.000'
   EndIF

   cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)

   If Empty(cTemp)
      aAdd(aResult, .F.)
      aAdd(aResult, STR0031 + AllTrim(cInternalID) + STR0032) //"Cliente " " n„o encontrado no de/para!"
   Else
      If cVersao == '1.000'
         aAdd(aResult, .T.)
         aAdd(aTemp, SubStr(cTemp, 1, TamSX3('A1_COD')[1]))
         aAdd(aTemp, SubStr(cTemp, 1 + TamSX3('A1_COD')[1], TamSX3('A1_LOJA')[1]))
         aAdd(aResult, aTemp)
      ElseIf cVersao == '2.000' .Or.  cVersao == '2.001' .Or. cVersao == '2.002' .Or. cVersao == '2.003' .Or. cVersao == '2.004' .Or. cVersao == '2.005'
         aAdd(aResult, .T.)
         aTemp := Separa(cTemp, '|')
         aAdd(aResult, aTemp)
      Else
         aAdd(aResult, .F.)
         aAdd(aResult, STR0030 + Chr(10) + STR0034 + "1.000, 2.000, 2.001, 2.002, 2.003, 2.004, 2.005") //"Vers„o n„o suportada.", "As versıes suportadas s„o: "
      EndIf
   EndIf
Return aResult

/*/{Protheus.doc} X3Ordem
Busca a ordem do campo no dicionario de dados
@param   cCampo        Campo a ser verificado
@author  Rodrigo Machado Pontes
@version P11
@since   05/10/2015
@return  nOrdem - Ordem do campo no dicionario de dados     
/*/

Function X3Ordem(cCampo)

Local aArea	:= GetArea()
Local nOrdem	:= 0

DbSelectArea("SX3")
SX3->(DbSetOrder(2))
If SX3->(DbSeek(cCampo))
	nOrdem := SX3->X3_ORDEM
Endif

RestArea(aArea)

Return nOrdem

/*/{Protheus.doc} A2030PAIS()
Array com codigo dos pais utilizados na TOTVS

@author  Rodrigo Machado Pontes
@version P11
@since   14/10/2015
@return  aArray - Array retornado conforme dicionario  de dados
/*/

Function A2030PAIS(cAliasPais)

Local aArea			:= GetArea()
Local cCdPais		:= ""
Local cFilSYA		:= xFilial("SYA")
Local cCpo			:= IIf(cAliasPais=="SA1","A1_PAIS","A2_PAIS")
Local nTmYADESCR	:= GetSX3Cache("YA_DESCR", "X3_TAMANHO")
Local nTmPAIS		:= GetSX3Cache(cCpo,       "X3_TAMANHO")
Local nI			:= 0
Local aRet			:= {{"BRASIL"					,"BRA","0"},;
          			    {"ANGOLA"					,"ANG","0"},;
          			    {"ARGENTINA"				,"ARG","0"},;
          			    {"BOLIVIA"					,"BOL","0"},;
          			    {"CHILE"					,"CHI","0"},;
          			    {"COLOMBIA"				    ,"COL","0"},;
          			    {"COSTA RICA"				,"COS","0"},;
          			    {"REPUBLICA DOMINICANA"	    ,"DOM","0"},;
          			    {"EQUADOR"					,"EQU","0"},;
          			    {"ESTADOS UNIDOS"			,"EUA","0"},;
          			    {"MEXICO"					,"MEX","0"},;
          			    {"PARAGUAI"				    ,"PAR","0"},;
          			    {"PERU"					    ,"PER","0"},;
          			    {"PORTUGAL"				    ,"PTG","0"},;
          			    {"URUGUAI"					,"URU","0"},;
          			    {"VENEZUELA"				,"VEN","0"}}
Local nTam			:= Len(aRet)

For nI := 1 To nTam
	cCdPais	:= PadR(Posicione("SYA", 2, cFilSYA + PadR(aRet[nI,1], nTmYADESCR), "YA_CODGI"), nTmPAIS)
	If !Empty(cCdPais)
		aRet[nI,3] := cCdPais
	Endif
Next nI

RestArea(aArea)
Return aRet

/*/{Protheus.doc} A2030PALOC()
Busca o codigo do pais atraves do cPaisLoc
@author  Rodrigo Machado Pontes
@version P11
@since   14/10/2015
@return  cCdPaisLoc - codigo do pais atraves do cPaisLoc
/*/

Function A2030PALOC(cAliasPais,nOpc)

Local aPais			:= A2030Pais(cAliasPais)
Local nPos			:= aScan(aPais,{|x| AllTrim(x[2]) == AllTrim(Upper(cPaisLoc))})
Local nInd			:= If(nOpc == 1, 3, If(nOpc == 2, 1, 0))	// nOpc == 1 --> Busca o Codigo do Pais ## nOpc == 2 --> Busca o Nome do Pais
Local cCdPaisLoc	:= ""

If nPos > 0 .AND. nInd > 0
	cCdPaisLoc := aPais[nPos,nInd]
Endif
Return cCdPaisLoc

//-------------------------------------------------------------------
/*/{Protheus.doc} MATI30Pais
Tradutor de cÛdigo de paÌs, para casos onde o cÛdigo enviado seja diferente
dos encontrados na SYA

@param   cPaisCode      ,String, CÛdigo do paÌs enviado ao adapter
@param   cPais          ,String, Nome do paÌs enviado ao adaoter
@param   cMarca         ,String, Marca do Adapter para pesquisa no De/Para
@retur   cRet           ,String, CÛdigo do PaÌs na tabela SYA
@author  Squad CRM/Faturamento
@version P12
@since   11/05/2018
@sample  MATI30Pais('001', 'BRASIL') => '105'
/*/
//-------------------------------------------------------------------
Static Function MATI30Pais(cPaisCode, cPais, cMarca)

Local aAreaSYA    := {}
Local cFilSYA     := ''
Local cRet        := ''
Local lHasCode    := !Empty(cPaisCode)
Local lHasDesc    := !Empty(cPais)

Default cPaisCode := ''
Default cPais     := ''

If lHasCode
	cRet := CFGA070Int(cMarca, 'SYA', 'YA_CODGI', cPaisCode)
EndIf

If !Empty(cRet)
	cRet := Alltrim(cRet)
Else
	aAreaSYA := SYA->(GetArea())
	cFilSYA := xFilial("SYA")

	If lHasCode
		cRet := AllTrim(Posicione("SYA",1,cFilSYA+cPaisCode,"YA_CODGI"))
	EndIf

	If Empty(cRet) .And. lHasDesc
		cRet := AllTrim(Posicione("SYA",2,cFilSYA+ Padr(cPais, GetSX3Cache("YA_DESCR","X3_TAMANHO")),"YA_CODGI"))
	EndIf
	RestArea(aAreaSYA)
	Asize(aAreaSYA,0)
EndIf
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Mati30Regi
Recebe um InternalID e CodigoRegiao interno do Protheus "006-Norte" e retorna o cÛdigo da Region v·lido.

@param   cInternalID recebido na mensagem, externalId.
@param   cRegionCode Codigo da Regiao interno Protheus
@param   cMarca      Produto que enviou a mensagem


@author  TOTVS
@version P12
@since   03/12/2020
@return  cRet com o cÛdigo valido no Protheus.

@sample  Mati30Regi('89014c65-9dc2-4074-8003-db3242fc3227', 'T3||006', 'MASTERCRM') ir· retornar
006
/*/
//-------------------------------------------------------------------
Static Function Mati30Regi(cValExtID, cRegionCode, cMarca)

   Local   cRet        := ''
	Local aAreaSX5      := SX5->(GetArea())
	Local cTemp         := ''
	Local aTemp         := {}

	Default cValExtID	:= ''
	Default cRegionCode	:= ''
	Default cMarca      := ''

	//CÛdigo interno do Prohteus para Regi„o, se for enviado no Json, apenas validamos se o cÛdigo existe na SX5
	If !Empty(cRegionCode)
		If at('|', cRegionCode) > 0
			aTemp := Separa(cRegionCode, '|')
			If Len(aTemp) >= 3
				cRegionCode := Left(aTemp[3] + Space(Len(SA1->A1_REGIAO)), Len(SA1->A1_REGIAO) )
			Endif
		Else
			cRegionCode := Left(cRegionCode + Space(3), Len(SA1->A1_REGIAO))
		Endif
		SX5->(dbSetOrder(1))
		If SX5->(dbSeek(xFilial("SX5") + 'A2' + cRegionCode ))
			SX5->( RestArea( aAreaSX5 ) )
			Return cRegionCode
		Endif
	EndIf

	//CÛdigo externo para busca, se n„o enviado o cÛdigo interno do Protheus ou enviado codigo errado, verificamos pelo cValExtID na tabela XXF.
	cTemp := CFGA070Int(cMarca, 'SX5', 'X5_CHAVE', cValExtID)
	
  	If !Empty( cTemp ) 
	  	If at('|', cTemp) > 0
			aTemp := Separa(cTemp, '|')
			If Len(aTemp) >= 3
				cTemp := Left(aTemp[3] + Space(3), Len(SA1->A1_REGIAO))
			Endif
		Else
			cTemp := Left(cTemp + Space(3), Len(SA1->A1_REGIAO))
		Endif	
		SX5->(dbSetOrder(1))
		If SX5->(dbSeek(xFilial("SX5") + 'A2' + cTemp ))
			cRet := cTemp
		Endif
	Endif

	SX5->( RestArea( aAreaSX5 ) )
Return cRet

/*/{Protheus.doc} Mati30Seg
Recebe um InternalID e CodigoSegmento interno do Protheus "000001-Industria Quimica/Resinas/Tintas/Sinteticos" e retorna o cÛdigo do segmento valido.

@param   cInternalID recebido na mensagem, externalId.
@param   cSegCode    Codigo do segmento interno Protheus
@param   cMarca      Produto que enviou a mensagem

@author  TOTVS
@version P12
@since   03/12/2020
@return  cRet com o cÛdigo valido no Protheus.

@sample  Mati30Seg('89014c65-9dc2-4074-8003-db3242fc3227', 'T3||000001', 'MASTERCRM') ir· retornar
000001
/*/
//-------------------------------------------------------------------
Static Function Mati30Seg(cValExtID, cSegCode, cMarca)

   	Local   cRet        := ''
	Local aAreaSX5      := SX5->(GetArea())
	Local cTemp         := ''
	Local aTemp         := {}
	Local nLenA1SAT     := Len(SA1->A1_SATIV1)

	Default cValExtID	:= ''
	Default cSegCode	:= ''
	Default cMarca      := ''
	
	//CÛdigo interno do Prohteus para Regi„o, se for enviado no Json, apenas validamos se o cÛdigo existe na SX5
	If !Empty(cSegCode)
		If at('|', cSegCode) > 0
			aTemp := Separa(cSegCode, '|')
			If Len(aTemp) >= 3
				cSegCode := Left(aTemp[3] + Space(nLenA1SAT), nLenA1SAT )
			Endif
		Else
			cSegCode := Left(cSegCode + Space(nLenA1SAT), nLenA1SAT )
		Endif
		SX5->(dbSetOrder(1))
		If SX5->(dbSeek(xFilial("SX5") + 'T3' + cSegCode ))
			SX5->( RestArea( aAreaSX5 ) )
			Return cSegCode
		Endif
	EndIf

	//CÛdigo externo para busca, se n„o enviado o cÛdigo interno do Protheus ou enviado codigo errado, verificamos pelo cValExtID na tabela XXF.
	cTemp := CFGA070Int(cMarca, 'SX5', 'X5_CHAVE', cValExtID)
	
  	If !Empty( cTemp ) 
	  	If at('|', cTemp) > 0
			aTemp := Separa(cTemp, '|')
			If Len(aTemp) >= 3
				cTemp := Left(aTemp[3] + Space(nLenA1SAT), nLenA1SAT )
			Endif
		Else
			cTemp := Left(cTemp + Space(nLenA1SAT), nLenA1SAT)
		Endif	
		SX5->(dbSetOrder(1))
		If SX5->(dbSeek(xFilial("SX5") + 'T3' + cTemp ))
			cRet := cTemp
		Endif
	Endif

	SX5->( RestArea( aAreaSX5 ) )
Return cRet
/*/{Protheus.doc} Mati30Car
Recebe um InternalID e Codigo Tranpsortadora retorna o cÛdigo da tranportadora valido.

@param   cInternalID recebido na mensagem, externalId.
@param   cCarrCode    Codigo do segmento interno Protheus
@param   cMarca      Produto que enviou a mensagem

@author  TOTVS
@version P12
@since   03/12/2020
@return  cRet com o cÛdigo valido no Protheus.

@sample  Mati30Car('89014c65-9dc2-4074-8003-db3242fc3227', 'T3||000001', 'MASTERCRM') ir· retornar
000001
/*/
//-------------------------------------------------------------------
Static Function Mati30Car(cValExtID, cCarrCode, cMarca)

   	Local   cRet        := ''
	Local aAreaSA4      := SA4->(GetArea())
	Local cTemp         := ''
	Local aTemp         := {}
	Local nLenA1SAT     := Len(SA1->A1_TRANSP)

	Default cValExtID	:= ''
	Default cCarrCode	:= ''
	Default cMarca      := ''

	//CÛdigo interno do Prohteus para Transportadora, se for enviado no Json, validamos se o cÛdigo existe na SA4
	If !Empty(cCarrCode)
		If at('|', cCarrCode) > 0
			aTemp := Separa(cCarrCode, '|')
			If Len(aTemp) >= 3
				cCarrCode := Left(aTemp[3] + Space(nLenA1SAT), nLenA1SAT )
			Endif
		Else
			cCarrCode := Left(cCarrCode + Space(nLenA1SAT), nLenA1SAT )
		Endif
		SA4->(dbSetOrder(1))
		If SA4->(dbSeek(xFilial("SA4") + cCarrCode ))
			SA4->( RestArea( aAreaSA4 ) )
			Return cCarrCode
		Endif
	EndIf

	//CÛdigo externo para busca, se n„o enviado o cÛdigo interno do Protheus ou enviado codigo errado, verificamos pelo cValExtID na tabela XXF.
	cTemp := CFGA070Int(cMarca, 'SA4', 'A4_COD', cValExtID)
	
  	If !Empty( cTemp ) 
	  	If at('|', cTemp) > 0
			aTemp := Separa(cTemp, '|')
			If Len(aTemp) >= 3
				cTemp := Left(aTemp[3] + Space(nLenA1SAT), nLenA1SAT )
			Endif
		Else
			cTemp := Left(cTemp + Space(nLenA1SAT), nLenA1SAT)
		Endif	
		SA4->(dbSetOrder(1))
		If SA4->(dbSeek(xFilial("SA4") + cTemp ))
			cRet := cTemp
		Endif
  Endif

	SA4->( RestArea( aAreaSA4 ) )
Return cRet

