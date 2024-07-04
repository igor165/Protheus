#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FINI087.CH"

#DEFINE nTamRot 50
#DEFINE nTamMod 50

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FINI087  �Autor �Luis E. Enriquez Mata � Data � 20/02/2018  ���
�������������������������������������������������������������������������͹��
���Descri��o � M.U Baja de Cuentas por Cobrar.   	                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FINI087()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Baja de Cuentas por Cobrar (M.U) envio y recibimiento.      ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������Ĵ��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.           ���
�������������������������������������������������������������������������Ĵ��
���Programador   � Data   � BOPS/FNC  �        Motivo da Alteracao        ���
�������������������������������������������������������������������������Ĵ��
��� Marco Augusto�21/06/19�DMINA-6871 �Se modifica la consulta a la tabla ���
���              �        �           �XX4, por las funciones FwXX4Seek y ���
���              �        �           �FwXX4Version (MEX).                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FINI087(cXml, nType, cTypeMsg)
	Local lRet			:= .T.
	Local cXmlRet		:= ''
	Local cErroXml		:= ""
	Local cWarnXml		:= ""
	Local cIntId		:= ''
	Local aArea			:= GetArea()
	Local aAreaSE5		:= {}
	Local aAreaSE1		:= {}
	Local aRet			:= {}
	Local cRequest		:= ""
	Local cSequencia	:= " "
	Local cMUCliVers	:= '1.000' //Indica la versi�n de mensaje de cliente/proveedor
	Local nValJuros		:= 0
	Local nVlrRec := "0"
	Local cSeq	  := ""
	Local aBco    := {}

	Private oXml 			:= Nil

	lRet := .T. 

	dbSelectArea("SE5")
	aAreaSE5:= SE5->(GetArea())

	dbSelectArea("SE1")
	aAreaSE1:= SE1->(GetArea())

	Do Case
		Case ( nType == TRANS_SEND )
			If lRet
				If !ALTERA
					If Type("cIntegSeq") <> "U"
						cSequencia := cIntegSeq
					Endif
	
					cIntId := F87MontInt(,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,cSequencia)
	
					cRequest := "ReversalOfAccountReceivableDocumentDischarge"
	
					cXMLRet +='<BusinessRequest>'
					cXMLRet +=	'<Operation>'+cRequest+'</Operation>'
					cXMLRet +='</BusinessRequest>'
					cXMLRet +='<BusinessContent>'
					cXMLRet +=		'<CompanyId>'  	 	+ cEmpAnt + '</CompanyId>'
					cXMLRet +=		'<BranchId>' 		+ cFilAnt + '</BranchId>'
					cXMLRet +=		'<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'				
					cXMLRet +=      '<InternalId>' + cIntId + '</InternalId>'
					cXMLRet +=		'<CancelDate>' 	+ Transform(dToS(dDataBase),"@R 9999-99-99") + '</CancelDate>'   	// Data de Cancelamento da Baixa
					cXMLRet +='</BusinessContent>'
	
					CFGA070Mnt( , 'SE1','E1_BAIXA', , cIntId,.T. ) 
				Else
	
					cSeq := SE5->E5_SEQ
	
					SE5->( dbsetorder(7) )
					SE5->( DbSeek( xFilial("SE5")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA+cSeq ) )
	
					cRequest := "AccountReceivableDocumentDischarge"
	
					cXMLRet +='<BusinessRequest>'
					cXMLRet +=	'<Operation>' + cRequest + '</Operation>'
					cXMLRet +='</BusinessRequest>'
					cXMLRet +='<BusinessContent>'
					cXMLRet +=		'<CompanyId>'  	 	+ cEmpAnt + '</CompanyId>'
					cXMLRet +=		'<BranchId>' 		+ cFilAnt + '</BranchId>'
					cXMLRet +=		'<CompanyInternalId>'+ cEmpAnt + '|' + cFilAnt + '</CompanyInternalId>'
					cXMLRet +=      '<InternalId>' + F87MontInt(,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,SE5->E5_SEQ) + '</InternalId>'
					cXMLRet +=		'<AccountReceivableDocumentInternalId>' + F55MontInt(,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,,,'SE1') + '</AccountReceivableDocumentInternalId>'
					cXMLRet +=		'<PaymentDate>' 	+ Transform(dToS(SE5->E5_DATA),"@R 9999-99-99") + '</PaymentDate>'      // Data em que o Cliente Efetuou o Pagamento do T�tulo
					cXMLRet +=		'<CreditDate>' 		+ Transform(dToS(SE5->E5_DTDISPO),"@R 9999-99-99") + '</CreditDate>'    // Data em que o Valor foi Cr�dito na Conta da Empresa
					cXMLRet +=		'<EntryDate>' 	  	+ Transform(dToS(SE5->E5_DTDIGIT),"@R 9999-99-99") + '</EntryDate>'		// Data de Lan�amento da Baixa no Sistema
					nVlrRec := SE5->E5_VALOR				
					cXMLRet +=		'<PaymentValue>'	+ CValToChar(nVlrRec) + '</PaymentValue>'	  						//Valor do Pagamento
					cXMLRet +=		'<OtherValues>'
	
					If SE5->E5_VLJUROS > 0 .And. SE5->E5_VLACRES > 0
						nValJuros := SE5->E5_VLJUROS - SE5->E5_VLACRES
					Else
						nValJuros := SE5->E5_VLJUROS
					EndIf					 
	
					If SE5->E5_VLDESCO > 0 .And. SE5->E5_VLDESCO > SE1->E1_VLBOLSA
						nDesconto := SE5->E5_VLDESCO - SE1->E1_VLBOLSA
					Else
						nDesconto := SE5->E5_VLDESCO
					EndIf
	
					If SE5->E5_VLDECRE > 0
						nDesconto -= SE5->E5_VLDECRE 
					EndIf
	
					cXMLRet +=			'<DiscountValue>'	+ CValToChar(nDesconto) + '</DiscountValue>'			//Valor de Desconto Concedido
					cXMLRet +=			'<InterestValue>'	+ CValToChar(nValJuros) + '</InterestValue>'		//Valor de Juros Pagos
					cXMLRet +=			'<AbatementValue>'	+ CValToChar(SE5->E5_VLDECRE) + '</AbatementValue>'	//Valor de Abatimento
					cXMLRet +=			'<ExpensesValue>'	+ CValToChar(SE5->E5_VLACRES) + '</ExpensesValue>'	//Valor de Despesas Financeiras
					cXMLRet +=			'<NotaryCostsValue>'+ '</NotaryCostsValue>'								//N�o temos - Valor de Despesas de Cart�rio
					cXMLRet +=			'<FineValue>'	  	+ CValToChar(SE5->E5_VLMULTA) + '</FineValue>'		//Valor da Multa Paga
					cXMLRet +=		'</OtherValues>'				
	
					cXMLRet += 		'<CurrencyInternalId>' + C40MontInt(,Iif((SE1->E1_MOEDA<10),STrZero(SE1->E1_MOEDA,TAMSx3("CTO_MOEDA")[1],0),cValtoChar(SE1->E1_MOEDA))) + '</CurrencyInternalId>'
					cXMLRet += 	 	'<CurrencyRate>' + cValToChar(SE1->E1_TXMOEDA) + '</CurrencyRate>'
	
					cMuCliVers := AllTrim(MsgUVer('CUSTOMERVENDOR','MATA030'))
	
					If cMuCliVers == '1.000'
						cXMLRet +=	'<CustomerInternalId>' + SE1->E1_CLIENTE + SE1->E1_LOJA + '</CustomerInternalId>'           
					ElseIF cMuCliVers == '2.000'
						cXMLRet +=	'<CustomerInternalId>' + IntCliExt(, , SE1->E1_CLIENTE, SE1->E1_LOJA, cMuCliVers)[2] + '</CustomerInternalId>'
					Endif
	
					cXMLRet +=		'<StoreId>'	   		+ SE5->E5_HISTOR + '</StoreId>'
					cXMLRet +=		'<PaymentMethod>'	+ RetMotBx( 2, SE5->E5_MOTBX ) + '</PaymentMethod>'						//Forma de Baixa
					cXMLRet +=		'<PaymentMeans>'	+ '</PaymentMeans>'														//N�o Temos   Meio de Pagamento (Dinheiro, Cheque, Cart�o...)
					
					aBco := fObtBanco(SE5->E5_SERREC,SE5->E5_ORDREC)
	
					If Len(aBco) > 0 //Banco-Agencia-Cuenta 
						cXMLRet +=	'<HolderCode>' + M70MontInt(,aBco[1][1],aBco[1][2],aBco[1][3]) + '</HolderCode>'	//Portador da Baixa
					Endif
	
					cXMLRet +=		'<FinancialInternalId>' 	+ F10MontInt(,SE1->E1_NATUREZ) + '</FinancialInternalId>'		//deve ser mandado como o de/para
					cXMLRet +=		'<HistoryText>'		+ SE5->E5_HISTOR + '</HistoryText>'
					cXMLRet +=	'<DischargeSequence>'	+ SE5->E5_SEQ + '</DischargeSequence>'									//Sequ�ncia da Baixa. Utilizado para estornar a baixa
					cXMLRet +=	'</BusinessContent>'
				EndIf
			Else
				Help(,,"FI070DEPEND",,cXmlRet,1,0)
				If InTransact()
					DisarmTransaction()
				EndIf
			EndIf
		Case ( nType == TRANS_RECEIVE )
			Do Case
				Case (cTypeMsg == EAI_MESSAGE_WHOIS )
					cXmlRet := '2.000|2.001|2.002'				
				Case (cTypeMsg == EAI_MESSAGE_RESPONSE )
					If lRet
						oXml := XmlParser(cXml, "_", @cErroXml, @cWarnXml)
		
						If Type("oXml:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION:_STATUS:TEXT") <> "U" .AND. Alltrim(oXml:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION:_STATUS:TEXT) == "ERROR"
							lRet 	:= .F.
							cXmlRet	:= oXml:_TOTVSMESSAGE:_RESPONSEMESSAGE:_PROCESSINGINFORMATION:_LISTOFMESSAGES:_MESSAGE:TEXT
						ElseIf oXml <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
							Fi087Respo(@oXml)
							oXml := nil
							DelClassIntF()
						Else
							lRet := .F.
							cXmlRet := STR0001 //'Error en el XML recebido.'
						EndIf
					Endif
				Case ( cTypeMsg == EAI_MESSAGE_BUSINESS )
					If lRet
						oXml := XmlParser(cXml, "_", @cErroXml, @cWarnXml)
						If oXml <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml)
							aRet := Fi087Rece(@oXml)
							lRet := aRet[1]
							cXmlRet := aRet[2]
							DellArray(@aRet)
							oXml := Nil
							DelClassIntF()
						Else
							lRet := .F.
							cXmlRet := STR0001 //'Error en el XML recebido.'
						EndIf
					EndIf
			EndCase
	EndCase

	RestArea(aAreaSE1)
	DellArray(@aAreaSE1)

	RestArea(aAreaSE5)
	DellArray(@aAreaSE5)

	RestArea( aArea )
	DellArray(@aArea)
Return { lRet, cXmlRet }

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � Fi087Rece  � Autor � Luis Enriquez         � Data � 20.02.18 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Procesamiento de la recepci�n de baja a recibir - M.U.       ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fi087Rece(oXml)                                              ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oXml .- Objeto XML recibo mediante M.U.                      ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRet	- Indica si el proceso fue exitoso .T. = SI .F. = NO.   ���
���          � cXmlRet	- Mensaje Xml generado en el procesamiento.         ��� 
���������������������������������������������������������������������������Ĵ��
��� Uso      � FINI087                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
/*/
Function Fi087Rece(oXml)
	Local lRet			:= .T.
	Local cXmlRet		:= ''
	Local cExternalId	:= ''
	Local cTitInter		:= ''
	Local cMarca		:= ''
	Local cRequest		:= ''
	Local cPrefix		:= ''
	Local cNum			:= ''
	Local cParcel		:= ''
	Local cTipo			:= ''
	Local aArea			:= GetArea()
	Local aTitulo		:= {}		
	Local aInterBx		:= {}
	Local aRet			:= {}
	Local nOpc			:= 0

	If XmlChildEx(oXml:_TotvsMessage:_BusinessMessage,'_BUSINESSREQUEST') <> nil .And. XmlChildEx(oXml:_TotvsMessage:_BusinessMessage:_BusinessRequest,'_OPERATION') <> NIL
		cRequest := oXml:_TotvsMessage:_BusinessMessage:_BusinessRequest:_Operation:Text
	Endif

	If Upper(Alltrim(cRequest)) == 'ACCOUNTRECEIVABLEDOCUMENTDISCHARGE'
		nOpc := 3
	ElseIf Upper(Alltrim(cRequest)) == 'REVERSALOFACCOUNTRECEIVABLEDOCUMENTDISCHARGE'
		nOpc := 5
	Else
		lRet := .F.
		cXmlRet += STR0002 + " " //'El contenido de la etiqueta Request es inv�lido o no se envio.'
	Endif

	If XmlChildEx(oXml:_TotvsMessage:_MessageInformation,'_PRODUCT') <> nil .And. XmlChildEx(oXml:_TotvsMessage:_MessageInformation:_Product,'_NAME') <> NIL
		cMarca := oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
	Else
		lRet := .F.
		cXmlRet += STR0003 + " " //'No se encontro la etiqueta que identifica la marca integrada.' 
	Endif

	If(oXml := XmlChildEx(oXml:_TOTVSMessage:_BusinessMessage,'_BUSINESSCONTENT')) == Nil//a partir deste ponto, utilizo somente informa��es da business
		lRet := .F.
		cXmlRet += STR0004 //'La etiqueta BusinessContent no se encontro en el mensaje.'	
	Endif

	If 	lRet
		cExternalId := Fi087Parse(@oXml,"_InternalId")

		If !Empty (cExternalId)
			aInterBx := F87GetInt(cExternalId, cMarca)

			If (nOpc == 3 .And. !aInterBx[1]) //se inclus�o, nao deve achar correspondente. Se estorno, obrigat�rio ter 
				cTitInter := Fi087Parse(@oXml,'_AccountReceivableDocumentInternalId')

				aTitulo := IntTRcInt(cTitInter,cMarca) //Resgatando os dados do t�tulo pelo InternalId

				If aTitulo[1]
					cPrefix := PadR(aTitulo[2][3],TamSX3("E1_PREFIXO")[1])
					cNum := PadR(aTitulo[2][4],TamSX3("E1_NUM")[1])
					cParcel := PadR(aTitulo[2][5],TamSX3("E1_PARCELA")[1])
					cTipo := PadR(aTitulo[2][6],TamSX3("E1_TIPO")[1])
				Else
					lRet := .F.
					cXmlRet := STR0005 //'No se encontro el titulo para baja.'
				Endif

				DellArray(@aTitulo)			
			ElseIf (nOpc == 5 .And. aInterBx[1])
				cPrefix := PadR(aInterBx[2][3],TamSX3("E1_PREFIXO")[1])
				cNum := PadR(aInterBx[2][4],TamSX3("E1_NUM")[1])
				cParcel := PadR(aInterBx[2][5],TamSX3("E1_PARCELA")[1])
				cTipo := PadR(aInterBx[2][6],TamSX3("E1_TIPO")[1])
			Else 
				lRet := .F.

				If nOpc == 3
					cXmlRet := STR0006 //'Ya existe movimiento de baja con este InternalId.'
					cXmlRet += " " + STR0007 //'En caso de que desee modificar esta baja, es necesario realizar la reversion de la baja y dar baja el titulo nuevamente.'
				Else
					cXmlRet := STR0008 //'No se encontro la baja para realizar la reversion.'
				Endif				
			EndIf
			If lRet
				aRet := Fi087Baixa(@oXml,nOpc,cMarca,cPrefix,cNum,cParcel,cTipo,iif(aInterBx[1],aInterBx[2][9],'');
				,cExternalId,iif(aInterBx[1],aInterBx[3],'')) //prefixo, num, parcela, tipo

				lRet := aRet[1]
				cXmlRet := aRet[2]

				DellArray(@aRet)
			Endif

			DellArray(@aInterBx)
		Else
			lRet := .F.
			cXmlRet := STR0009 //'La etiqueta InternalId no se encontro en el mensaje.'	
		Endif
	Endif		

	RestArea(aARea)
	DellArray(@aArea)
Return {lRet,cXmlRet}

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � Fi087Baixa � Autor � Luis Enriquez         � Data � 20.02.18 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Procesamiento de baja a cobrar - M.U.                        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fi087Baixa(oXml,nOpc,cMarca,cPrefix,cNum,cParcel,cTipo,cSeq, ���
���          � cExternalId,cInternalId)                                     ���   
���������������������������������������������������������������������������Ĵ��
���Parametros� oXml .- Objeto XML recibo mediante M.U.                      ���
���          � nOpc .- Opci�n de baja: 3=Baja 5=Anulaci�n de la baja.       ���
���          � cMarca .- Marca integrada.                                   ���
���          � cPrefix .- Prefijo del titulo.                               ���
���          � cNum .- N�mero de folio del titulo.                          ���
���          � cParcel .- Cuota del titulo.                                 ���
���          � cTipo .- Tipo de titulo.                                     ���
���          � cSeq .- Secuencia de baja.                                   ���
���          � cExternalId .- C�digo externo recibido.                      ���
���          � cInternalId .- C�digo interno.                               ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � lRet	- Indica si el proceso fue exitoso .T. = SI .F. = NO.   ���
���          � cXmlRet	- Mensaje Xml generado en el procesamiento.         ��� 
���������������������������������������������������������������������������Ĵ��
��� Uso      � FINI087 (Fi087Rece)                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
/*/
Function Fi087Baixa(oXml,nOpc,cMarca,cPrefix,cNum,cParcel,cTipo,cSeq,cExternalId,cInternalId)
	Local aArea			:= GetArea()
	Local aAreaSE1		:= {}
	Local aCab			:= {}
	Local aBanco		:= {}	
	Local aBaixa		:= {}
	Local aErroAuto		:= {}
	Local lRet			:= .T.
	Local cXmlRet		:= ''
	Local cCliente		:= ''
	Local cLoja			:= ''
	Local cMotBaixa		:= ''
	Local cBanco		:= ''
	Local cAgencia		:= ''
	Local cNumConta		:= ''
	Local cHist			:= ''
	Local cLogErro		:= ''
	Local cAlias		:= "SE1"
	Local cCampo		:= "E1_BAIXA"
	Local nBaixa		:= 1
	Local nX			:= 0
	Local nJuros		:= 0
	Local nDespesas		:= 0
	Local nMulta		:= 0
	Local nDesconto		:= 0
	Local nAbat			:= 0
	Local nTaxa			:= 0
	Local nOpBaixa		:= 1
	Local dDtBaixa		:= CtoD("//")
	Local dDtEntrada	:= CtoD("//")
	Local aCurrency		:= {}

	Private lMsErroAuto		:= .F.
	Private lMsHelpAuto		:= .T.
	Private lAutoErrNoFile	:= .T.
	Private cIntegSeq		:= '' //Variabla dentro de FINA087A. Necesaria para garantizar la correcta secuencia de baja.

	DbSelectArea('SE1')
	aAreaSE1 := SE1->(GetArea())
	SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA

	AADD(aCab,{"E1_PREFIXO",cPrefix,NIL})
	AADD(aCab,{"E1_NUM",cNum,NIL})
	AADD(aCab,{"E1_PARCELA",cParcel,NIL})
	AADD(aCab,{"E1_TIPO",cTipo,NIL})

	IF SE1->(dbSeek(xFilial('SE1') + cPrefix + cNum + cParcel + cTipo))
		cCliente := SE1->E1_CLIENTE
		cLoja := SE1->E1_LOJA

		AADD(aCab,{"E1_CLIENTE",cCliente,NIL})
		AADD(aCab,{"E1_LOJA",cLoja,NIL})

		If nOpc == 3 //inclus�o da baixa
			dDtBaixa := StoD(StrTran(Fi087Parse(@oXml,'_PaymentDate'),"-"))

			If !Empty(dDtBaixa)
				AADD(aCab,{"AUTDTBAIXA",dDtBaixa,NIL}) // Data de Lan�amento da Baixa no Sistema (AUTDTBAIXA)
			Endif

			dDtEntrada := StoD(StrTran(Fi087Parse(@oXml,'_CreditDate'),"-"))

			If !Empty(dDtEntrada)
				AADD(aCab,{"AUTDTCREDITO",dDtEntrada,NIL}) // Data em que o Valor foi Cr�dito na Conta da Empresa
			Endif

			AADD(aCab,{"AUTVALREC",Val(Fi087Parse(@oXml,'_PaymentValue')),NIL}) // Valor do Pagamento (AUTVALREC)

			nTaxa := Val(Fi087Parse(@oXml,'_CurrencyRate'))

			If nTaxa > 0
				AADD(aCab,{"AUTTXMOEDA",nTaxa,NIL})
			Else
				aCurrency := IntMoeInt(Fi087Parse(@oXml,'_CurrencyInternalId'),cMarca)
				If aCurrency[1]
					nTaxa := RecMoeda(dDtBaixa,Val(aCurrency[2][3]))
					If nTaxa > 0
						AADD(aCab,{"AUTTXMOEDA",nTaxa,NIL})
					EndIf
				EndIf		
			EndIf

			cMotBaixa := Fi087Parse(@oXml,"_PaymentMethod")
			cMotBaixa := RetMotBx(1,cMotBaixa)	

			If !Empty(cMotBaixa)	
				AADD(aCab,{"AUTMOTBX",cMotBaixa,NIL}) //M�todo de Pago
			Endif

			//Datos del Banco
			cBanco := Fi087Parse(@oXml,"_HolderCode")

			If !Empty (cBanco)
				aBanco := M70GetInt(cBanco,cMarca)
				If aBanco[1]
					AADD(aCab,{"AUTBANCO",aBanco[2][3],NIL}) //Portador
					AADD(aCab,{"AUTAGENCIA",aBanco[2][4],NIL}) //Portador
					AADD(aCab,{"AUTCONTA",aBanco[2][5],NIL}) //Portador
				Else
					cXmlRet := STR0010 //'No se encontro el banco de la baja.'
					lRet := .F.
				Endif
				DellArray(@aBanco)
			Endif

			If lRet
				cHist := Fi087Parse(@oXml,"_HistoryText")

				If !Empty(cHist)
					AADD(aCab,{"AUTHIST",cHist,NIL})
				EndIf

				//Otros Valores
				If(oXml := XmlChildEx(oXml,'_OTHERVALUES')) <> NIL
					nJuros := Val(Fi087Parse(@oXml,'_InterestValue'))
					If nJuros > 0
						AADD(aCab,{"AUTJUROS",nJuros,NIL}) 	//Valor de Juros Pagos (AUTJUROS)
					EndIf
					nDesconto := Val(Fi087Parse(@oXml,'_DiscountValue'))
					If nDesconto > 0
						AADD(aCab,{"AUTDESCONT",nDesconto,NIL}) 	//Valor de Desconto Concedido (AUTDESCONT)
					EndIf
					nAbat := Val(Fi087Parse(@oXml,'_AbatementValue'))
					If nAbat > 0
						AADD(aCab,{"AUTDECRESC",nAbat,NIL}) //Valor de Abatimento (AUTDECRESC)
					EndIf
					nDespesa := Val(Fi087Parse(@oXml,'_ExpensesValue'))
					If nDespesa > 0
						AADD(aCab,{"AUTACRESC",nDespesa,NIL})  //Valor de Despesas Financeiras
					EndIf
					nMulta := Val(Fi087Parse(@oXml,'_FineValue'))
					If nMulta > 0 
						AADD(aCab,{"AUTMULTA",nMulta,NIL})      //Valor da Multa Paga  (AUTMULTA)
					EndIf
				EndIf
			EndIf
		EndIf

		If lRet
			BEGIN TRANSACTION

				MSExecAuto({|x,y,z,a| Fina087a(x,y,z,a)},aCab,nOpc)

				If lMsErroAuto
					aErroAuto := GetAutoGRLog()
					For nX := 1 To Len(aErroAuto)
						cLogErro += StrTran(StrTran(StrTran(aErroAuto[nX],"<"," "),"-"," "),"/"," ")+" "
					Next nX
					// Monta XML de Erro de execu��o da rotina automatica.
					lRet := .F.
					cXMLRet := cLogErro
					DellArray(@aErroauto)
				Else
					If nOpc == 3 // inclus�o da baixa
						If Empty(cIntegSeq) .And. Empty(SE5->E5_SEQ) // n�o carregou a variavel e o campo E5_SEQ, efetuo o rollback
							DisarmTransaction()
							lRet := .F.
							cXmlRet := STR0012 //'Para utilizar correctamente esta funcionalidad, es necesario actualizar la rutina Cobros Diversos (FINA087A)'
						Else
							If Empty(cIntegSeq)
								cIntegSeq := SE5->E5_SEQ
							EndIf
							cInternalId := F87MontInt(,cPrefix,cNum,cParcel,cTipo,cCliente,cLoja,cIntegSeq)
							CFGA070Mnt( cMarca, cAlias,cCampo, cExternalId, cInternalId ) 
							cXmlRet := '<OriginInternalID>'+cExternalId+'</OriginInternalID>'
							cXmlRet += ' <DestinationInternalID>'+cInternalId+'</DestinationInternalID>'
						Endif
					Else//estorno da baixa
						CFGA070Mnt( , cAlias,cCampo, , cInternalId,.T. ) //excluindo o de-para
						cXmlRet := '<OriginInternalID>'+cExternalId+'</OriginInternalID>'
						cXmlRet += ' <DestinationInternalID>'+cInternalId+'</DestinationInternalID>'
					Endif
				Endif

			END TRANSACTION
		Endif

	Else
		lRet := .F.
		cXmlRet := STR0005 //'No se encontro el titulo para baja.'
	Endif

	RestArea(aAReaSE1)
	DellArray(@aAReaSE1)

	RestArea(aARea)
	DellArray(@aArea)

	DellArray(@aCab)
Return{lRet,cXmlRet}

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � DellArray  � Autor � Luis Enriquez         � Data � 20.02.18 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Libera la memoria de arrays.                                 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � DellArray(aArray)                                            ���
���������������������������������������������������������������������������Ĵ��
���Parametros� aArray .- Array que ser� destrido.                           ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � FINI087                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
/*/
Static function DellArray(aArray)
	If Valtype(aArray) == 'A'
		aSize(aArray,0)
		aArray := Nil
	Else
		aArray := Nil
	EndIf
Return

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � Fi087Parse  � Autor � Luis Enriquez        � Data � 20.02.18 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica si existe nodo en xml.                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fi087Parse(oXml,cXml)                                        ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oXml .- Objeto XML recibo mediante M.U.                      ���
���          � cXml .- String a ser buscado en XML.                         ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � FINI087                                                      ���
����������������������������������������������������������������������������ٱ�
���Retorno   � cRet	- Contenido del nodo encontrado.                        ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������
/*/
Static Function Fi087Parse(oXml,cXml)
	Local cRet		:= ''
	Local oXmlAux	:= nil
	
	oXmlAux := XmlChildEx( oXml, Upper(cXml) )
	
	If oXmlAux != nil
		cRet := oXmlAux:Text
		oXmlAux := nil
	EndIf
Return cRet

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MsgUVer    � Autor � Luis Enriquez         � Data � 20.02.18 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica la versi�n de M.U. regustrada en adapter EAI.       ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � MsgUVer(cMensagem,cRotina)                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cMensagem .- Nombre de M.U. a ser buscado.                   ���
���          � cRotina .- Rutina que posee IntegDef de M.U.                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � FINI087                                                      ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � cVersion	- Versi�n de M.U. registrado en configurador.       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
/*/
Function MsgUVer(cMensagem, cRotina)
	Local aArea		:= GetArea()
	Local cVersion	:= '1.000'
	
	cRotina := Padr(cRotina, nTamRot)
	
	IF FwXX4Seek(Padr(cRotina, nTamRot) + Padr(cMensagem, nTamMod))
		cVersion := FwXX4Version(cMensagem)
	Endif
	
	RestArea(aArea)
	DellArray(@aArea)
	
Return cVersion

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � RetMotBx     � Autor � Luis Enriquez       � Data � 20.02.18 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Recupera el motivo de baja a partir de c�digos de M.U.       ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � RetMotBx(nTipo,cCod)                                         ���
���������������������������������������������������������������������������Ĵ��
���Parametros� nTipo .- Identificaci�n de columna de retorno.               ���
���          � 1=C�d. Num�ricos (XML) 2=C�d. Alfa (Protheus)                ���
���          � cCod .- C�digo de la enumeraci�n de XML.                     ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � FINI087                                                      ���
����������������������������������������������������������������������������ٱ�
���Retorno   � cMotBxa	- Motivo de baja.                                   ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������
/*/
Static Function RetMotBx( nTipo, cCod )
	//relacionamento entre motivos de baixa e codigos a serem trafegados
	Local aEnumBxas 	:= { { '001', 'AD' } ,{ '002', 'AB' } ,{ '003', 'DV' } ,{ '004', 'NC' },;
						   { 	'005', 'NP' } ,{ '006', 'BX' } ,{ '007', 'NOR' },{ '008', 'DAC' },;
						   { 	'009', 'DEB' },{ '010', 'VEN' },{ '011', 'LIQ' },{ '012', 'FAT' },;
						   { 	'013', 'CRD' },{ '014', 'CEC' } , {'015','BOL'}} 
	Local nValIdent 	:= 0
	Local cMotBxa   	:= ' '
	
	Default nTipo 	:= 1
	
	nValIdent := aScan( aEnumBxas, { |x| x[nTipo]==Alltrim(Upper(cCod)) } )
		
	cMotBxa := If( nValIdent > 0, Padr(aEnumBxas[nValIdent][ Iif(nTipo==1,2,1)],TamSX3('E5_MOTBX')[1]), Space(TamSX3('E5_MOTBX')[1] ) )
	
	DellArray(@aEnumBxas)
Return cMotBxa

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � F87MontInt   � Autor � Luis Enriquez       � Data � 20.02.18 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Recibe un registro en Protheus y genere el InternalId.       ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � F87MontInt(cFil,cPrefix,cNum,cParcel,cTipo,cCliente,         ���
���          � cLoja,cSequencia)                                            ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cFil .- Filial del registro.                                 ���
���          � cPrefix .- Prefijo del titulo.                               ���
���          � cNum .- N�mero de folio del titulo.                          ���
���          � cParcel .- Cuota del titulo.                                 ���
���          � cTipo .- Tipo de titulo.                                     ���
���          � cCliente .- Cliente del titulo             .                 ���
���          � cLoja .- Tienda del titulo.                                  ���
���          � cSequencia .- Secuencia de baja del titulo.                  ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � FINI087                                                      ���
����������������������������������������������������������������������������ٱ�
���Retorno   � cRetCode	- InternalId del registro.                          ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������
/*/
Function F87MontInt(cFil,cPrefix,cNum,cParcel,cTipo,cCliente,cLoja,cSequencia)
	Local cRetCode := ''

	Default cFil := xFilial('SE1')

	cFil := xFilial("SE1",cFil)

	cRetCode := cEmpAnt + '|' + rTrim(cFil) + '|' + Trim(cPrefix) + '|' + rTrim(cNum) + '|' + RTrim(cParcel) + '|' +;
			    RTrim(cTipo) + '|' + RTrim(cCliente) + '|' + RTrim(cLoja) + '|' + rTrim(cSequencia)
Return cRetCode

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � F87GetInt    � Autor � Luis Enriquez       � Data � 20.02.18 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Recibe un c�digo, y busca su InternalId.                     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Function F87GetInt(cCode,cMarca)                             ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cCode .- InternalId recibido en el mensaje.                  ���
���          � cMarca .- Producto que envi� el mensaje.                     ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � FINI087                                                      ���
����������������������������������������������������������������������������ٱ�
���Retorno   � aRetorno	- Array que contiene los campos de la clave primaria���
���Retorno   � del t�tulo a recibir, secuencia de baja y su InternalId.     ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������
/*/
Function F87GetInt(cCode,cMarca)
	//a fun��o j� esta implementada para a ocasiao de implementar a recep��o da baixa.
	Local cValInt	:= ''
	Local aRetorno	:= {}
	Local aAux		:= {}
	Local nX		:= 0
	Local aCampos	:= {cEmpAnt,'E1_FILIAL','E1_PREFIXO','E1_NUM','E1_PARCELA','E1_TIPO','E1_CLIENTE','E1_LOJA','E5_SEQ'}
	
	cValInt := CFGA070Int(cMarca, 'SE1', 'E1_BAIXA', cCode)
	
	If !Empty(cValInt)
	
		aadd(aRetorno,.T.)
	
		aAux:=Separa(cValInt,'|')
	
		aadd(aRetorno,aClone(aAux))
		aadd(aRetorno,cValInt)
	
		aRetorno[2][1]:=Padr(aRetorno[2][1],Len(cEmpAnt))
	
		For nx:=2 to len (aRetorno[2]) //corrigindo  o tamanho dos campos
			aRetorno[2][nX]:=Padr(aRetorno[2][nX],TamSX3(aCampos[nx])[1])
		Next nx
	Else
		aadd(aRetorno,.F.)
	EndIf
	
	DellArray(@aAux)
Return aRetorno

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � Fi087Respo   � Autor � Luis Enriquez       � Data � 20.02.18 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Procesa la respues de mensaje �nico.                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fi087Respo(oXml)                                             ���
���������������������������������������������������������������������������Ĵ��
���Parametros� oXml .- Objeto XML recibo mediante M.U.                      ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � FINI087                                                      ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������
/*/
Function Fi087Respo(oXml)
	Local cMarca	:= ''
	Local cValInt	:= ''
	Local cValExt	:= ''
	Local lEstorno	:= .F.
	Local lRet		:= .T.
	Local nCount	:= 0
	Local cXmlRet	:= ''
	
	If XmlChildEx(oXml:_TotvsMessage:_MessageInformation,'_TRANSACTION') != NIL
		If Alltrim(Upper(oXml:_TotvsMessage:_MessageInformation:_Transaction:Text)) == 'REVERSALOFACCOUNTRECEIVABLEDOCUMENTDISCHARGE'
			lEstorno := .T.
		Endif
	Endif
	
	If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status,'TEXT') != Nil
		If AllTrim(Upper(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text)) == "ERROR" //Retorno da mensagem com erro
			If ValType(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message) != "A"
				// Transforma em array
				XmlNode2Arr(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message, "_Message")
			EndIf		
			
			For nCount := 1 To Len(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message)
				cXmlRet += oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message[nCount]:Text + Chr(10)
			Next nCount
			
			lRet := .F.
		EndIf
	EndIf
	
	If !lEstorno .And. lRet//no estorno, j� excluiu a rela��o de de-para
		If XmlChildEx(oXml:_TotvsMessage:_MessageInformation:_Product,'_NAME') != nil 					
			cMarca := oXml:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		EndIf
	   	
	   	If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent,'_ORIGININTERNALID') != NIL
	   		cValInt := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_OriginInternalID:Text
	   	EndIf
	   	
	   	If XmlChildEx(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent,'_DESTINATIONINTERNALID') != nil
	   	   cValExt := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_DestinationInternalID:Text
	   	EndIf 
		
		If !Empty(cValExt) .And. !Empty(cValInt)
		   CFGA070Mnt( cMarca, "SE1", "E1_BAIXA", cValExt, cValInt )
	 	Endif
	EndIf
Return

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �  fObtBanco   � Autor � Luis Enriquez       � Data � 16.05.18 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Obtiene Banco-Agencia-Cuenta de recibo de cobro.             ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � fObtBanco(cSerie,cRecibo)                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cSerie .- Serie del recibo de cobro.                         ���
���          � cRecibo .- Folio del recibo de cobro.                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � FINI087                                                      ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������
/*/
Static Function fObtBanco(cSerie,cRecibo)
	Local cQry      := ""
	Local cTmpTabla := "TMPBCO"
	Local aBanco    := {}
	
	If Select(cTmpTabla) > 0
		(cTmpTabla)->(DbClosearea())
	EndIf 	
	
	cQry := "SELECT E5_FILIAL, E5_BANCO, E5_AGENCIA, E5_CONTA "
	cQry += "FROM " + RetSQLName("SE5") + " "
	cQry += "WHERE (E5_ORDREC = '" + cRecibo + "') "
	cQry += "AND (E5_SERREC = '" + cSerie + "') "
	cQry += "AND (E5_FILIAL = '" + xFilial("SE5") + "') " 
	cQry += "AND (E5_TIPO IN ('TF','EFE','CH')) "
	cQry += "AND(D_E_L_E_T_ = '') "
	
	cQry := ChangeQuery( cQry )
			
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cTmpTabla,.T.,.T.)  
	
	dbSelectArea(cTmpTabla)
	dbGoTop()
	
	While (!(cTmpTabla)->(EOF()))
		If !Empty((cTmpTabla)->E5_BANCO) .And. !Empty((cTmpTabla)->E5_AGENCIA) .And. !Empty((cTmpTabla)->E5_CONTA)
			aAdd(aBanco,{(cTmpTabla)->E5_BANCO,(cTmpTabla)->E5_AGENCIA,(cTmpTabla)->E5_CONTA})
		EndIf
		(cTmpTabla)->(dbSkip())
	EndDo		
Return aBanco