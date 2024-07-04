#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "CTBI020.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³INTEGDEF  ºAutor  ³Wilson.Godoi        º Data ³ 23/01/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³ M.U Cadastramento de Conta Contabil 			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBI020()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³Função para a interação com EAI                             º±±
±±º          ³envio e recebimento                                         º±±
±±º          ³Cod.Conta       ( CT1_CONTA)                                º±±
±±º          ³Descr.Moeda     ( CT1_DESC01)                               º±±
±±º          ³Classe da Conta ( CT1_CLASSE)                               º±±
±±º          ³Cond.Normal     ( CT1_NORMAL)                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBI020(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

Local aSave 		:= GetArea()
Local aSaveCT1		:= {}
Local aCT1proc 		:= {}
Local aValInt		:= {}
Local cXmlRet 		:= ''
Local cEvent 		:= 'upsert'
Local cErroXml 		:= ""
Local cWarnXml 		:= ""
Local nOpcExec
Local cMarca		:= ''
Local cAlias		:= 'CT1'
Local cField		:= 'CT1_CONTA'
Local cValInt		:= ''
Local cValIntAux	:= ''
Local cValExt		:= ''
Local cInternalID	:= ''
Local lRet 			:= .T.
Local oXmliAux		:= Nil
Local cEntGer				:= SuperGetMV("MV_CTBCGER",.F.,"")
Local cCpoPermite	:= ""
Local cCpoObrigat := ""
Local cPlano := ""
Local cTipoPer := ""
Local nCount := 0
Local lAcetEnt := .T. //Aceita Entidade ?
Local lObriEnt := .T. //Entidade Obrigatória ?
Private oXmli020 	:= Nil
Private oXmlBusMsg	:=Nil

dbSelectArea("CT0")
CT0->(dbSetOrder(1)) //CT0_FILIAL+CT0_ID
If !Empty(cEntGer)
	If !CT0->(dbSeek(xFilial("CT0") + cEntGer))
		lRet    := .F.
		cXmlRet := STR0003 // "A entidade selecionada no parametro MV_CTBCGER não está cadastrada, verificar cadastro de entidades adicionais"
		Return {lRet, cXmlRet}
	Else
		cPlano := cEntGer
		cCpoPermite := "CT1_ACET"+ AllTrim(cEntGer)
		cCpoObrigat := "CT1_"+ AllTrim(cEntGer)+"OBRG"
	EndIf
EndIf

aSaveCT1:=CT1->(GetArea())

Do Case
	Case ( cTypeTrans == TRANS_SEND )
		oMdlCT1 := FwModelActive()
		If !(oMdlCT1 == Nil)
			If oMdlCT1:GetOperation() == MODEL_OPERATION_DELETE
				cEvent := 'delete'
				cValInt := cEmpAnt + "|" + CT1->CT1_FILIAL + "|" + CT1->CT1_CONTA
				If !Empty(cValInt)
					//Exclui quando vem de outro ERP
					CFGA070Mnt(, cAlias, cField,, cValInt, .T. )  // Deleta o XXF
				EndIf
			EndIf
		EndIf

		//Entidades Adicionais
		If !Empty(cPlano)
			//Verifica se os campos existem
			lAcetEnt := CT1->(FieldPos(cCpoPermite)) > 0
			lObriEnt := CT1->(FieldPos(cCpoObrigat)) > 0
		EndIf

		cInternalID := cEmpAnt + "|" + xFilial("CT1") + "|" + AllTrim(CT1->CT1_CONTA)

		cXMLRet := '<BusinessEvent>'
		cXMLRet +=     '<Entity>ACCOUNTANTACCOUNT</Entity>'
		cXMLRet +=     '<Event>' + cEvent + '</Event>'	//variável upsert para atualização ou deleção
		cXMLRet +=		'<Identification>'
		cXMLRet +=         '<key name="InternalId">' + cInternalID + '</key>'
		cXMLRet +=     '</Identification>'
		cXMLRet += '</BusinessEvent>'
		cXMLRet += '<BusinessContent>'
		cXMLRet +=	  '<CompanyId>' + AllTrim( cEmpAnt ) + '</CompanyId>'
		cXMLRet +=	  '<BranchId>' + AllTrim( cFilAnt ) + '</BranchId>'
		cXMLRet +=	  '<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
		cXMLRet +=	  '<Code>'	+ _NoTags( AllTrim( CT1->CT1_CONTA ) ) + '</Code>'
		cXMLRet +=	  '<InternalId>' + _NoTags( AllTrim( cInternalID ) ) + '</InternalId>'
		cXMLRet +=	  '<ShortCode>' + _NoTags( AllTrim( CT1->CT1_RES ) ) + '</ShortCode>'
		cXMLRet +=    '<Description>' + _NoTags( AllTrim( CT1->CT1_DESC01 ) ) + '</Description>'
		cXMLRet +=    '<PostingNature>'	+ AllTrim( CT1->CT1_NORMAL ) + '</PostingNature>'
		cXMLRet +=    '<AnalyticalOrSynthetic>' + AllTrim( CT1->CT1_CLASSE ) + '</AnalyticalOrSynthetic>'
		If CT1->CT1_BLOQ == '2'
			cXMLRet +=    '<ActiveOrInactive>1</ActiveOrInactive>'
		Else
			cXMLRet +=    '<ActiveOrInactive>2</ActiveOrInactive>'
		Endif

		If !Empty(cPlano) .AND. (lAcetEnt .AND. lObriEnt)
			cTipoPer := ""
			If CT1->(&cCpoPermite) == "1" .And. CT1->(&cCpoObrigat) == "1" // Obrigatorio
				cTipoPer := "3"
			ElseIf CT1->(&cCpoPermite) == "1" .And. CT1->(&cCpoObrigat) == "2" // Permite
				cTipoPer := "2"
			ElseIf CT1->(&cCpoPermite) == "2" //Nao Permite
				cTipoPer := "1"
			EndIf

			If !Empty(cTipoPer)
				cXMLRet +=    '<ManagerialAccountingEntityPolicy>' + cTipoPer + '</ManagerialAccountingEntityPolicy>'
			EndIf
		EndIf

		cXMLRet +=	  '<TopCode>' + _NoTags( AllTrim( CT1->CT1_CTASUP ) ) + '</TopCode>'
		cXMLRet += '</BusinessContent>'

	// verificação do tipo de transação recebimento ou envio
	// trata o recebimento

	Case ( cTypeTrans == TRANS_RECEIVE )
		Do Case
			//EAI_MESSAGE_WHOIS == retorno da versão do XML para o solicitante
	   		Case ( cTypeMsg == EAI_MESSAGE_WHOIS )
				cXmlRet := '1.000|2.000|2.001'

			//EAI_MESSAGE_RESPONSE == resposta de uma BUSINESS_MESSAGE
   			Case ( cTypeMsg == EAI_MESSAGE_RESPONSE )
				//-- Quando Recebemos de Fora então fazemos a Gravacao do De/Para Codigo Interno X Codigo Externo
				oXmli020 := XmlParser(cXml, "_", @cErroXML, @cWarnXML)

				If oXmli020 <> Nil .And. Empty(cErroXML) .And. Empty(cWarnXML)

					If Type("oXmli020:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U"
						cMarca :=  oXmlI020:_TotvsMessage:_MessageInformation:_Product:_Name:Text
					EndIf

					If Type( "oXmli020:_TOTVSMessage:_ResponseMessage:_ReturnContent" ) <> "U"
						oXmliAux := oXmli020:_TOTVSMessage:_ResponseMessage:_ReturnContent

						If XmlChildEx( oXmliAux, '_LISTOFINTERNALID' ) <> Nil .And. XmlChildEx( oXmliAux:_ListOfInternalId, '_INTERNALID' ) <> Nil
	                     //tratamento para quando utiliza internalID - Versao 2.0
							cValInt := oXmliAux:_ListOfInternalId:_InternalId:_Origin:Text
							cValExt := oXmliAux:_ListOfInternalId:_InternalId:_Destination:Text
						Else
							If Type("oXmli020:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalID:_InternalIdText") <> "U"
						   		cValInt := oXmlI020:_TOTVSMessage:_ResponseMessage:_ReturnContent:_OriginInternalID:Text
						   	EndIf
						   	If Type("oXmli020:_TOTVSMessage:_ResponseMessage:_ReturnContent:_OriginInternalID:Text") <> "U"
						   		cValInt := oXmlI020:_TOTVSMessage:_ResponseMessage:_ReturnContent:_OriginInternalID:Text
						   	EndIf
						   	If Type("oXmlI020:_TOTVSMessage:_ResponseMessage:_ReturnContent:_DestinationInternalID:Text") <> "U"
						   	    cValExt := oXmlI020:_TOTVSMessage:_ResponseMessage:_ReturnContent:_DestinationInternalID:Text
						   	EndIf
						EndIf
					Else
						If Upper(oXmli020:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "ERROR"
							//Se não for array
							If ValType(oXmli020:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message) != "A"
								//Transforma em array
								XmlNode2Arr(oXmli020:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
							EndIf
							cErroXml := ""
							//Percorre o array para obter os erros gerados
							For nCount := 1 To Len(oXmli020:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
								cErroXml += oXmli020:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + Chr(10)
							Next nCount

							lRet := .F.
							cXmlRet := cErroXml
						EndIf
					Endif

					If !Empty(cValExt) .And. !Empty(cValInt)
					    //Inclui ou Altera a Devolução do Envio para Outro ERP
					    If !CFGA070Mnt( cMarca, cAlias, cField, cValExt, cValInt )
							lRet    := .F.
						Else
							lRet    := .T.
						Endif
					Else
						lRet    := .F.
					EndIf
				EndIf

			Case ( cTypeMsg == EAI_MESSAGE_BUSINESS )
				oXmli020 := XmlParser(cXml, "_", @cErroXml, @cWarnXml)

				If oXmli020 <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
					If ( XmlChildEx( oXmli020:_TOTVSMessage, '_BUSINESSMESSAGE' ) <> nil )
						oXmlBusMsg := oXmli020:_TOTVSMessage:_BusinessMessage

						// Recebe Nome do Produto (ex: RM ou PROTHEUS) e guarda na variavel cMarca
						If Type("oXmli020:_TotvsMessage:_MessageInformation:_Product:_Name:Text") <> "U"
							cMarca :=  oXmLi020:_TotvsMessage:_MessageInformation:_Product:_Name:Text
						EndIf
						// Recebe o codigo da Conta no Cadastro externo e guarda na variavel cValExt
						If Type("oXmli020:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text") <> "U"
							cValExt := oXmli020:_TOTVSMessage:_BusinessMessage:_BusinessContent:_InternalId:Text
						EndIf
					   	If Empty(cValExt) .and. Type("oXmli020:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_key:Text") <> "U"
					   	    cValExt := oXmli020:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Identification:_key:Text
					   	EndIf

						If Empty(cValExt)
							lRet := .F.
							cXmlRet := STR0004 //"tag InternalId n?o enviada na integraç?o, essa informaç?o é obrigatória"
						Else
							//----------------------------------------------------------------------------------------
							//-- procura a Marca,Alias,Codigo na Tabela XXF de De/Para para ver se Existe o Código
							//----------------------------------------------------------------------------------------
							//Apens verifica se existe o Registro no XXF para saber se é Inclusão, Alteração ou Exclusão
							cValInt := CFGA070INT( cMarca,  cAlias , cField, cValExt )
							If Empty(cValInt) .and. "|" $ cValExt
								cValInt := fGetValInt(cMarca,cAlias,cField,cValExt) //Se nao encontrou valor interno e utiliza pipe, faz a busca sem os pipes para manter compatibilidade
							EndIf

							//Retira PIPES utilizados na InternalID
							If !Empty(cValInt) .and. "|" $ cValInt
								aValInt := Separa(cValInt,"|")
							EndIf

							If Len(aValInt) > 2
								cValIntAux := aValInt[2]+aValInt[3]
							Else
								cValIntAux := cValInt
							EndIf

							If Upper(oXmli020:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
								If !Empty( cValIntAux )
									CT1->(dbSetOrder(1))
									CT1->(dbSeek(cValIntAux, .F.))
									nOpcExec:= 4
								Else
									nOpcExec:= 3
								EndIf
							Else
								If !Empty( cValIntAux )
									CT1->(dbSetOrder(1))
									CT1->(dbSeek(cValIntAux))
									//Exclui quando vem de outro ERP
									CFGA070Mnt(, cAlias, cField,, cValInt, .T. )  // Deleta o XXF
								EndIf
								nOpcExec:= 5
							EndIf

							aCT1proc := UPSERTCT1( nOpcExec, cMarca, cAlias, cField, cValExt,cValInt,cValIntAux )
							lRet    := aCT1proc[1]
							cXmlRet := aCT1proc[2]
						EndIf
					EndIf
				Else
					lRet := .F.
					cXmlRet := '<Message type="ERROR" code="c2">' + STR0002 +  '</Message>' //Erro no XML Recebido
				EndIf
		EndCase
EndCase

RestArea( aSaveCT1 )
RestArea( aSave )

Return { lRet, cXmlRet,"ACCOUNTANTACCOUNT" }

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UPSERTCT1 ºAutor  ³Microsiga           º Data ³  21/12/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Insere os dados na tabela CT1 nos casos de inserção e       º±±
±±º          ³alteração dos dados constantes no XML.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function UPSERTCT1 (  nOpcExec, cMarca, cAlias, cField, cValExt,cValInt,cValIntAux )
Local nCount	:= 0
Local lRet 		:= .T.
Local aCab 		:= {}
Local cXmlRet	:= ' '
Local aArea		:= GetArea()
Local cConta	:= ' '
Local nTamRes  	:= GetSx3Cache( "CT1_RES", "X3_TAMANHO" )
Local cEntGer				:= SuperGetMV("MV_CTBCGER",.F.,"")
Local cCpoPermite	:= ""
Local cCpoObrigat := ""
Local cPlano := ""
Local cTipoPer := ""

Private lMsErroAuto 	:= .F.
Private lMsHelpAuto 	:= .T.
Private lAutoErrNoFile 	:= .T.
Private aRotina			:= FWLoadMenuDef("CTBA020")

dbSelectArea("CT0")
CT0->(dbSetOrder(1)) //CT0_FILIAL+CT0_ID
If !Empty(cEntGer)
	If !CT0->(dbSeek(xFilial("CT0") + cEntGer))
		lRet    := .F.
		cXmlRet := STR0003 // "A entidade selecionada no parametro MV_CTBCGER não está cadastrada, verificar cadastro de entidades adicionais"
		Return {lRet, cXmlRet}
	Else
		cPlano := cEntGer
		cCpoPermite := "CT1_ACET"+ AllTrim(cEntGer)
		cCpoObrigat := "CT1_"+ AllTrim(cEntGer)+"OBRG"
	EndIf
EndIf

If nOpcExec == 3
	If Type("oXmlBusMsg:_BusinessContent:_Code:Text") <> "U"
		cConta := oXmlBusMsg:_BusinessContent:_Code:Text
		cConta := SubStr(LimpText(cConta),1,TamSX3("CT1_CONTA")[1]) //Retira mascara
		CT1->(dbSetOrder(1))
		While .T.
			If CT1->(DbSeek(xFilial("CT1")+cConta))
				cConta:=GetSXENum("CT1","CT1_CONTA")
			Else
				Exit
			EndIf
		EndDo
	EndIf
Else
	cConta:=SubStr(cValIntAux,TamSX3("CT1_FILIAL")[1]+1,TamSX3("CT1_CONTA")[1])
EndIf

aAdd( aCab, { "CT1_CONTA", cConta, Nil })

If Type("oXmlBusMsg:_BusinessContent:_Description:Text") <> "U"
	aAdd( aCab, { "CT1_DESC01", oXmlBusMsg:_BusinessContent:_Description:Text, Nil })
EndIf
If Type("oXmlBusMsg:_BusinessContent:_AnalyticalOrSynthetic:Text") <> "U"
	aAdd( aCab, { "CT1_CLASSE", oXmlBusMsg:_BusinessContent:_AnalyticalOrSynthetic:Text, Nil })
EndIf
If Type("oXmlBusMsg:_BusinessContent:_PostingNature:Text") <> "U"
	aAdd( aCab, { "CT1_NORMAL", oXmlBusMsg:_BusinessContent:_PostingNature:Text, Nil })
EndIf
If Type("oXmlBusMsg:_BusinessContent:_ShortCode:Text") <> "U"
	aAdd( aCab, { "CT1_RES", PADR(oXmlBusMsg:_BusinessContent:_ShortCode:Text,nTamRes), Nil })
EndIf
If Type("oXmlBusMsg:_BusinessContent:_TopCode:Text") <> "U"
	aAdd( aCab, { "CT1_CTASUP", oXmlBusMsg:_BusinessContent:_TopCode:Text , Nil })
EndIf

If Type("oXmlBusMsg:_BusinessContent:_ActiveOrInactive:Text") <> "U"
	If oXmlBusMsg:_BusinessContent:_ActiveOrInactive:Text=="1"
		aAdd( aCab, { "CT1_BLOQ","2", Nil })
	ElseIf oXmlBusMsg:_BusinessContent:_ActiveOrInactive:Text=="2"
		aAdd( aCab, { "CT1_BLOQ","1", Nil })
	EndIf
EndIf

If !Empty(cPlano)
	If Type("oXmlBusMsg:_BusinessContent:_ManagerialAccountingEntityPolicy:Text") <> "U"
		cTipoPer := oXmlBusMsg:_BusinessContent:_ManagerialAccountingEntityPolicy:Text
		If cTipoPer == "2" // Permite
			aAdd( aCab, { cCpoPermite,"1", Nil })
			aAdd( aCab, { cCpoObrigat,"2", Nil })
		ElseIf cTipoPer == "1" // Não Permite
			aAdd( aCab, { cCpoPermite,"2", Nil })
			aAdd( aCab, { cCpoObrigat,"2", Nil })
		ElseIf cTipoPer == "3" // Obrigatorio
			aAdd( aCab, { cCpoPermite,"1", Nil })
			aAdd( aCab, { cCpoObrigat,"1", Nil })
		EndIf
	EndIf
EndIf

FWMVCRotAuto(FWLoadModel('CTBA020'), 'CT1', nOpcExec, { {'CT1MASTER',aCab} }, , .T.)

If lMsErroAuto
	cLogErro:=""
	aErroAuto := GetAutoGRLog()
	For nCount := 1 To Len(aErroAuto)
		cLogErro += '<Message type="ERROR" code="c2">'+StrTran(StrTran(StrTran(aErroAuto[nCount],"<"," "),"-"," "),"/"," ")+" "+'</Message>'
	Next nCount
	// Monta XML de Erro de execução da rotina automatica.
	lRet:=.F.
	cXmlRet:=cLogErro
Else
	// Monta xml RETORNO DO DE/PARA
	If nOpcExec # 5
		cValInt:= cEmpAnt + "|" + CT1->CT1_FILIAL + "|" + AllTrim(CT1->CT1_CONTA)
	    //Inclui ou Altera quando vem de Outro ERP e devolve para o ERP
		CFGA070Mnt( cMarca, cAlias, cField, cValExt, cValInt ) //Grava na Tabela XXF
		lRet:= .T.

		cXmlRet := "<ListOfInternalId>"
		cXmlRet += "	<InternalId>"
		cXmlRet += "		<Name>AccountantAccountInternalId</Name>"
		cXMLRet += "		<Origin>" + cValExt  + "</Origin>"  					//-- Valor gerado
		cXMLRet += "		<Destination>" + cValInt + "</Destination>"       	//-- Valor recebido
		cXmlRet += "	</InternalId>"
		cXmlRet += "</ListOfInternalId>"
	EndIf
EndIf

RestArea(aArea)
cXmlRet:=FWNoAccent(cXmlRet)
cXmlRet:=EncodeUTF8(cXmlRet)

Return { lRet, cXmlRet }

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LimpText  ³ Autor ³Leandro Drumond        ³ Data ³ 05/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retira caracteres estranhos de um palavra.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³LimpText()											      ³±±
±±³Parametros³ExpC1 - Texto para limpeza.							      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LimpText(cTexto)
Local cTmpCar	:= ""
Local cCarac	:= "-.;/\*,:$%&"
Local nItem		:= 1

For nItem := 1 to Len(cCarac)
	cTmpCar	:= Substr(cCarac,nItem,1)
	cTexto	:= StrTran(cTexto,cTmpCar)
Next nItem

Return cTexto

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fGetValInt³ Autor ³Leandro Drumond        ³ Data ³ 25/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca valor interno sem PIPES.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fGetValInt()											      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGetValInt(cMarca,cAlias,cField,cValExt)
Local cValInt := ""
Local aValExt := Separa(cValExt,"|")
Local cExtAux := aValExt[2] + aValExt[3] //Filial + codigo

cValInt := CFGA070INT( cMarca,  cAlias , cField, cExtAux )

If !Empty(cValInt)
	CFGA070Mnt(, cAlias, cField,, cValInt, .T. )  // Deleta o XXF
	CT1->(dbSetOrder(1))
	If CT1->(dbSeek(cValInt))
		cValInt:= cEmpAnt + "|" + CT1->CT1_FILIAL + "|" + AllTrim(CT1->CT1_CONTA)
		CFGA070Mnt( cMarca, cAlias, cField, cValExt, cValInt ) //Inclui novo DE-PARA com o codigo correto (com PIPE)
	Else
		cValInt := ""
	EndIf
EndIf

Return cValInt
