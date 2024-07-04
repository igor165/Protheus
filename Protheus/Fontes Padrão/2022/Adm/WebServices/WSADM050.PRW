#INCLUDE "WSADM050.ch"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³WSADM050  ³ Autor ³Bruno Sobieski         ³ Data ³11.02.2004  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Web Service das funcionalidades do Financeiro para os portais³±±
±±³          ³ de Fornecedor e Cliente de Localizacoes                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Financeiro/Portais                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao do Web Service de Controle do Usuario                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSSERVICE Receipts                 DESCRIPTION STR0001 //"Serviço de consulta aos recibos de clientes ( <b>Restrição de cliente</b> )"
   WSDATA UserCode                 As String
   WSDATA CustomerID               As String
   WSDATA ReceiptNumber            As String
   WSDATA ReceiptSeries            As String
   WSDATA DateFrom                 As Date
   WSDATA DateTo                   As Date
   WSDATA ListOfReceipts           As Array Of RCOrPOResume 
   WSDATA Receipt                  As ReceiptOrPO
   WSDATA Header                   As Array Of BrwHeader
   WSDATA HeaderType               As String
	WSDATA Currency                 As FLOAT OPTIONAL

   WSMETHOD GetHeader    DESCRIPTION STR0002 //"Método que descreve as estruturas de retorno do Serviço"
   WSMETHOD GetReceipt   DESCRIPTION STR0003 //"Método de consulta aos Recibos"
   WSMETHOD BrwReceipts  DESCRIPTION STR0004 //"Método de listagem dos Recibos"
ENDWSSERVICE

WSSERVICE PaymentOrders            DESCRIPTION STR0001 //"Serviço de consulta aos recibos de clientes ( <b>Restrição de cliente</b> )"
   WSDATA UserCode                 As String
   WSDATA SupplierID               As String
   WSDATA OrderNumber              As String OPTIONAL
   WSDATA DateFrom                 As Date OPTIONAL
   WSDATA DateTo                   As Date OPTIONAL
   WSDATA ListOfOrders             As Array Of ReceiptOrPO OPTIONAL
   WSDATA PaymentOrder             As ReceiptOrPO OPTIONAL
   WSDATA QueryAddWhere            As String OPTIONAL
   WSDATA Header                   As Array Of BrwHeader
   WSDATA HeaderType               As String

   WSMETHOD GetHeader    DESCRIPTION STR0002 //"Método que descreve as estruturas de retorno do Serviço"
//   WSMETHOD GetOrders    DESCRIPTION "Método de consulta as Ordens de pagamentos"
//   WSMETHOD BrwOrders    DESCRIPTION "Método de listagem das Ordens de pagamentos"
ENDWSSERVICE


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetHeader ³Autor  ³ Bruno Sobieski        ³ Data ³11.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Método de recuperacao do header de recibos                   ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Nome da Estrutura                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o Método foi avaliado com sucesso          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este Método devolve o header de uma estrutura                ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WSMETHOD GetHeader WSRECEIVE HeaderType WSSEND Header WSSERVICE Receipts

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do Header da estrutura Bill                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

::Header := FinHeader(::HeaderType)

Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetHeader ³Autor  ³ Bruno Sobieski        ³ Data ³11.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Método de recuperacao do header de OPs                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Nome da Estrutura                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o Método foi avaliado com sucesso          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este Método devolve o header de uma estrutura                ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WSMETHOD GetHeader WSRECEIVE HeaderType WSSEND Header WSSERVICE PaymentOrders

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do Header da estrutura Bill                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

::Header := FinHeader(::HeaderType)

Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetReceipt³Autor  ³ Eduardo Riera         ³ Data ³04.12.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Método de recuperacao dos dados de um recibo de um cliente   ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do usuario                                     ³±±
±±³          ³ExpC2: Numero de recibo                                      ³±±
±±³          ³ExpC3: Serie do recibo                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o Método foi avaliado com sucesso          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este Método recupera os dados de um recibo de um cliente     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WSMETHOD GetReceipt WSRECEIVE UserCode,CustomerID,ReceiptNumber,ReceiptSeries WSSEND Receipt WSSERVICE Receipts

Local aArea     	:= GetArea()
Local lRetorno  	:= .F.
Local cRecibo   := Self:ReceiptNumber
Local cSerie    := Self:ReceiptSeries

If PrtChkUser(Self:UserCode,"RECEIPTS","GETRECEIPT","SA1",Self:CustomerID)

	lRetorno := .T.

	dbSelectArea("SEL")
	dbSetOrder(8)
	If MsSeek(xFilial("SEL")+cSerie+cRecibo)
		GetReceipt(@Self:Receipt,"SEL")
	Else
		lRetorno := .F.
		SetSoapFault("GETRECEIPT",STR0005) //"Recibo não achado"
	EndIf
Else
	lRetorno := .F.
EndIf
RestArea(aArea)
Return(lRetorno)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³BrwReceipts³Autor ³ Eduardo Riera         ³ Data ³04.12.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Método de recuperacao dos dados dos recibos de um cliente    ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do usuario                                     ³±±
±±³          ³ExpC2: Codigo de cliente+loja                                ³±±
±±³          ³ExpD3: Data de emissao de                                    ³±±
±±³          ³ExpD4: Data de emissao ate                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o Método foi avaliado com sucesso          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este Método recupera os dados dos recibos de um cliente      ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WSMETHOD BrwReceipts WSRECEIVE UserCode,CustomerID,DateFrom,DateTo,Currency WSSEND ListOfReceipts WSSERVICE Receipts

Local aArea     	:= GetArea()
Local lRetorno  	:= .F.
Local cCliente		:= SubStr(Self:CustomerID,1,Len(SA1->A1_COD))
Local cLoja     	:= SubStr(Self:CustomerID,Len(SA1->A1_COD)+1)
Local nY
Local nX
Local lQuery		:=	.F.
Local cAliasSEL	:=	"SEL"                                                 

DEFAULT Self:Currency	:=	1

If PrtChkUser(Self:UserCode,"RECEIPTS","BRWRECEIPTS","SA1",Self:CustomerID)

	lRetorno := .T.
	If !Empty(cCliente) .And. !Empty(cLoja)
	
		lRetorno := .T.

		dbSelectArea("SEL")
		dbSetOrder(3)
		#IFDEF TOP
			lQuery    := .T.
			aStruSEL  := SEL->(dbStruct())
			cAliasSEL := "FINGETREC"
			
			cQuery := "SELECT * "
			cQuery += "FROM "+RetSqlName("SEL")+" SEL "
			cQuery += "WHERE "
			cQuery += "SEL.EL_FILIAL = '"+xFilial("SEL")+"' AND "
			cQuery += "SEL.EL_CLIENTE='"+cCliente+"' AND "
			cQuery += "SEL.EL_LOJA='"+cLoja+"' AND "
			cQuery += "SEL.EL_DTDIGIT BETWEEN '"+Dtos(Self:DateFrom)+"' AND '"+Dtos(Self:DateTo)+"' AND "
			cQuery += "SEL.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY "+SqlOrder(SEL->(IndexKey()))
			
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSEL)
			
			For nX := 1 To Len(aStruSEL)
				If aStruSEL[nX][2]<>"C" .And. FieldPos(aStruSEL[nX][1])<>0
					TcSetField(cAliasSEL,aStruSEL[nX][1],aStruSEL[nX][2],aStruSEL[nX][3],aStruSEL[nX][4])
			    EndIf
			Next nX
		#ELSE
			MsSeek(xFilial("SEL")+Self:CustomerID+Dtos(Self:DateFrom),.T.)
		#ENDIF
		
		While !Eof() .And. xFilial("SEL") == (cAliasSEL)->EL_FILIAL .And.;
			cCliente == (cAliasSEL)->EL_CLIORIG .And.;
			cLoja == (cAliasSEL)->EL_LOJORIG .And. 	Self:DateTo >= (cAliasSEL)->EL_DTDIGIT
			Aadd(Self:ListOfReceipts,WSClassNew("RCOrPOResume"))
			nY	:=	Len(Self:ListOfReceipts)
			GetReceipt(@Self:ListOfReceipts[nY],cAliasSEL,.T.,Self:Currency)

			dbSelectArea(cAliasSEL)
			dbSkip()
		EndDo
		If lQuery
			dbSelectArea(cAliasSEL)
			dbCloseArea()
			dbSelectArea("SEL")
		EndIf
	Else
		lRetorno := .F.
		SetSoapFault("BRWRECEIPTS",STR0006) //"Cliente invalido"
	EndIf
Else
	lRetorno := .F.
EndIf
RestArea(aArea)
Return(lRetorno)















/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetReceipt³Autor  ³ Bruno Sobieski        ³ Data ³11.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Montagem da estrutura de recibos                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto da estrutura de recibos                        ³±±
±±³          ³ExpC2: Alias do SEL                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o Método foi avaliado com sucesso          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta funcao atualiza a estrutura RECEIPT com os dados do     ³±±
±±³          ³recibo                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GetReceipt(oObjeto,cAliasSEL,lResumo,nMoeda)
Local cSerie := (cAliasSEL)->EL_SERIE 
Local cRecibo:= (cAliasSEL)->EL_RECIBO

DEFAULT lResumo	:=	.F.
DEFAULT nMoeda 	:=	1  

oObjeto:ReceiptOrPO  	:= cRecibo
oObjeto:ReceiptSeries  	:= cSerie
oObjeto:IssueDate      	:= (cAliasSEL)->EL_DTDIGIT
oObjeto:ProvisoryReceipt:= (cAliasSEL)->EL_RECPROV

If lResumo
	oObjeto:CompBills   	:=	0
	oObjeto:PaidBills  	:=	0
	oObjeto:Docs       	:=	0
	oObjeto:CreditBills 	:=	0
	oObjeto:Taxes       	:=	0
Endif

While !Eof() .And. cSerie == (cAliasSEL)->EL_SERIE .And. cRecibo == (cAliasSEL)->EL_RECIBO
   Do Case
		Case Alltrim((cAliasSEL)->EL_TIPODOC) == "TB" 
			If lResumo     
				If Alltrim((cAliasSEL)->EL_TIPO) $ MV_CRNEG+"/"+MVRECANT
					oObjeto:CompBills   	+=	GetValRec(nMoeda,cAliasSEL)
				Else
					oObjeto:PaidBills   	+=	GetValRec(nMoeda,cAliasSEL)
				Endif
			Else
				aadd(oObjeto:PaidBills,WSClassNew("PaidBillView"))
				nY	:= Len(oObjeto:PaidBills)
				SE5->(DbSetOrder(7))
			   SE5->(DbSeek(xFilial("SE5")+(cAliasSEL)->EL_PREFIXO+(cAliasSEL)->EL_NUMERO+(cAliasSEL)->EL_PARCELA+(cAliasSEL)->EL_TIPO+(cAliasSEL)->EL_CLIORIG+(cAliasSEL)->EL_LOJORIG))
				While xFilial("SE5") == SE5->E5_FILIAL .And. (cAliasSEL)->EL_PREFIXO == SE5->E5_PREFIXO .And.;
					(cAliasSEL)->EL_NUMERO == SE5->E5_NUMERO .And. (cAliasSEL)->EL_PARCELA == SE5->E5_PARCELA .And.;
					(cAliasSEL)->EL_TIPO == SE5->E5_TIPO .And. SE5->E5_CLIFOR == (cAliasSEL)->EL_CLIENTE .And.;
					(cAliasSEL)->EL_LOJA == SE5->E5_LOJA .And.	!SE5->(Eof())
					IF SE5->E5_TIPODOC == "BA" .And. SE5->E5_SERREC ==(cAliasSEL)->EL_SERIE .And.	(cAliasSEL)->EL_RECIBO == SE5->E5_ORDREC 
						GetCPPaidBill(@oObjeto:PaidBills[nY],"SE5")
						Exit
					Endif
					SE5->(DbSkip())
				Enddo	
			Endif
		Case Alltrim((cAliasSEL)->EL_TIPODOC) == "RS"
			If lResumo     
				oObjeto:Taxes       	+=	GetValRec(nMoeda,cAliasSEL)
  			Else
				Aadd(oObjeto:Taxes,WSClassNew("TaxesView"))		
				nY	:=	Len(oObjeto:Taxes)
				oObjeto:Taxes[nY]:TaxCode  	:=	"Ret. SUSS"
				oObjeto:Taxes[nY]:TaxBase   	:=	0
				oObjeto:Taxes[nY]:TaxRate 		:=	0
				oObjeto:Taxes[nY]:TaxAmount	:=	(cAliasSEL)->EL_VALOR
			Endif
		Case Alltrim((cAliasSEL)->EL_TIPODOC) == "RI"
			If lResumo     
				oObjeto:Taxes       	+=	GetValRec(nMoeda,cAliasSEL)
  			Else
				Aadd(oObjeto:Taxes,WSClassNew("TaxesView"))		
				nY	:=	Len(oObjeto:Taxes)
				oObjeto:Taxes[nY]:TaxCode  	:=	"Ret. IVA "
				oObjeto:Taxes[nY]:TaxBase   	:=	0
				oObjeto:Taxes[nY]:TaxRate 		:=	0
				oObjeto:Taxes[nY]:TaxAmount	:=	(cAliasSEL)->EL_VALOR
			Endif
		Case Alltrim((cAliasSEL)->EL_TIPODOC) == "RB"
			If lResumo     
				oObjeto:Taxes       	+=	GetValRec(nMoeda,cAliasSEL)
  			Else
				Aadd(oObjeto:Taxes,WSClassNew("TaxesView"))		
				nY	:=	Len(oObjeto:Taxes)
				oObjeto:Taxes[nY]:TaxCode  	:=	"Ret. IIBB"
				oObjeto:Taxes[nY]:TaxBase   	:=	0
				oObjeto:Taxes[nY]:TaxRate 		:=	0
				oObjeto:Taxes[nY]:TaxAmount	:=	(cAliasSEL)->EL_VALOR
			Endif
		Case Alltrim((cAliasSEL)->EL_TIPODOC) == "RG"
			If lResumo     
				oObjeto:Taxes       	+=	GetValRec(nMoeda,cAliasSEL)
  			Else
				Aadd(oObjeto:Taxes,WSClassNew("TaxesView"))		
				nY	:=	Len(oObjeto:Taxes)
				oObjeto:Taxes[nY]:TaxCode  	:=	STR0007 //"Ganancias"
				oObjeto:Taxes[nY]:TaxBase   	:=	0
				oObjeto:Taxes[nY]:TaxRate 		:=	0
				oObjeto:Taxes[nY]:TaxAmount	:=	(cAliasSEL)->EL_VALOR
			Endif
		Case Alltrim((cAliasSEL)->EL_TIPODOC) == "RA"
			If lResumo     
				oObjeto:CreditBills 	+=	GetValRec(nMoeda,cAliasSEL)
  			Else
				Aadd(oObjeto:CreditBills,WSClassNew("BillView"))
				nY	:=	Len(oObjeto:CreditBills)
				SE1->(DbSetOrder(2))
				SE1->(DbSeek(xFilial('SE1')+(cAliasSEL)->EL_CLIORIG+(cAliasSEL)->EL_LOJORIG+(cAliasSEL)->EL_PREFIXO+(cAliasSEL)->EL_NUMERO+(cAliasSEL)->EL_PARCELA+(cAliasSEL)->EL_TIPO))
	   		GetCRBill(@oObjeto:CreditBills[nY],'SE1',.F.)
			Endif
		OtherWise
			If lResumo     
				oObjeto:Docs 	+=	GetValRec(nMoeda,cAliasSEL)
  			Else
				Aadd(oObjeto:Docs,WSClassNew("BillView"))
				nY	:=	Len(oObjeto:Docs)
				SE1->(DbSetOrder(2))
				SE1->(DbSeek(xFilial('SE1')+(cAliasSEL)->EL_CLIORIG+(cAliasSEL)->EL_LOJORIG+(cAliasSEL)->EL_PREFIXO+(cAliasSEL)->EL_NUMERO+(cAliasSEL)->EL_PARCELA+(cAliasSEL)->EL_TIPO))
	   		GetCRBill(@oObjeto:Docs[nY],'SE1',.F.)
			Endif
	EndCase
	(cAliasSEL)->(DbSkip())
Enddo

Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetValRec ³Autor  ³ Bruno Sobieski        ³ Data ³12.02.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Retorna o valor da linha do recibo na moeda escolhida        ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Moeda escolhida                                       ³±±
±±³          ³ExpC2: Alias do SEL                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1: Valor da linha na moeda escolhida                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GetValRec(nMoeda,cAliasSEL) 
Local nValor	:=	0
If nMoeda==1
	nValor	+=	(cAliasSEL)->EL_VLMOED1
ElseIf nMoeda == Val((cAliasSEL)->EL_MOEDA)
	nValor	+=	(cAliasSEL)->EL_VALOR
Else
	cCpoTxMoeda	:=	"EL_TXMOE"+StrZero(nMoeda,2)
	If SEL->(FieldPos(cCpoTxMoeda)) > 0
		nValor   +=	xMoeda((cAliasSEL)->EL_VLMOED1,nMoeda,(cAliasSEL)->EL_DTDIGIT,,,&(cAliasSEL+"->"+cCpoTxMoeda))
	Else
		nValor	+=	xMoeda((cAliasSEL)->EL_VLMOED1,nMoeda,(cAliasSEL)->EL_DTDIGIT)
	Endif
Endif

Return nValor

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³BrwBill   ³Autor  ³ Eduardo Riera         ³ Data ³21.03.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Método de recuperacao dos titulos financeiros do Fornecedor  ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do usuario                                     ³±±
±±³          ³ExpC2: Customer ID                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o Método foi avaliado com sucesso          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este Método recupera os titulos financeiro em aberto de um   ³±±
±±³          ³Fornecedor                                                   ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
WSMETHOD BrwBill WSRECEIVE UserCode,SupplierID,QueryAddWhere,IndexKey WSSEND ListOfBill WSSERVICE FinanceSupplierBill

Local aArea     := GetArea()
Local lRetorno  := .F.
Local lQuery    := .F.
Local nY        := 0
Local cAliasSE2 := "SE2"
Local cFornece  := SubStr(::SupplierID,1,Len(SA2->A2_COD))
Local cLoja     := SubStr(::SupplierID,Len(SA2->A2_COD)+1)
#IFDEF TOP
Local aStruSE2  := {}
Local cQuery    := ""
Local nX        := 0
#ENDIF

DEFAULT ::IndexKey := SE2->(IndexKey())

If PrtChkUser(::UserCode,"FINANCESUPPLIERBILL","BRWBILL","SA2",::SupplierID)

	If !Empty(cFornece) .And. !Empty(cLoja)
	
		lRetorno := .T.

		dbSelectArea("SE2")
		dbSetOrder(6)
		#IFDEF TOP
			lQuery    := .T.
			aStruSE2  := SE2->(dbStruct())
			cAliasSE2 := "FINGETBILL"
			
			cQuery := "SELECT E2_FILIAL,E2_FORNECE,E2_LOJA,E2_SALDO,E2_TIPO,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_VALOR,"
			cQuery += "E2_NATUREZ,E2_EMISSAO,E2_VENCTO,E2_VENCREA,E2_MOEDA,E2_PORTADO,E2_HIST,E2_PORCJUR,E2_DTVARIA,"
			cQuery += "E2_VALJUR,E2_VALOR "
			cQuery += GetUserField("SE2")
			cQuery += "FROM "+RetSqlName("SE2")+" SE2 "
			cQuery += "WHERE "
			cQuery += "SE2.E2_FILIAL = '"+xFilial("SE2")+"' AND "
			cQuery += "SE2.E2_FORNECE='"+cFornece+"' AND "
			cQuery += "SE2.E2_LOJA='"+cLoja+"' AND "
			cQuery += "SE2.E2_SALDO > 0 AND "
			cQuery += "SE2.E2_TIPO NOT IN "+FormatIn(MV_CPNEG+"/"+MVPAGANT+"/"+MVABATIM,"/")+" AND "
			cQuery += "SE2.D_E_L_E_T_=' ' "
			cQuery := WsQueryAdd(cQuery,::QueryAddWhere)
			cQuery += "ORDER BY "+WsSqlOrder(::IndexKey)
			
			cQuery := ChangeQuery(cQuery)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2)
			
			For nX := 1 To Len(aStruSE2)
				If aStruSE2[nX][2]<>"C" .And. FieldPos(aStruSE2[nX][1])<>0
					TcSetField(cAliasSE2,aStruSE2[nX][1],aStruSE2[nX][2],aStruSE2[nX][3],aStruSE2[nX][4])
			    EndIf
			Next nX
		#ELSE
			MsSeek(xFilial("SE2")+::SupplierID)
		#ENDIF
		
		While !Eof() .And. xFilial("SE2") == (cAliasSE2)->E2_FILIAL .And.;
			cFornece == (cAliasSE2)->E2_FORNECE .And.;
			cLoja == (cAliasSE2)->E2_LOJA		
			If (cAliasSE2)->E2_SALDO > 0 .And. !(cAliasSE2)->E2_TIPO$MVABATIM .And. !(cAliasSE2)->E2_TIPO$MV_CPNEG+"/"+MVPAGANT
				aadd(::ListOfBill,WSClassNew("BillView"))
				nY++
				GetCPBill(@::ListOfBill[nY],cAliasSE2,.T.)
			EndIf		
			dbSelectArea(cAliasSE2)
			dbSkip()
		EndDo
		If lQuery
			dbSelectArea(cAliasSE2)
			dbCloseArea()
			dbSelectArea("SE2")
		EndIf
	Else
		lRetorno := .F.
		SetSoapFault("BRWBILL","Fornecedor invalido")
	EndIf
Else
	lRetorno := .F.
EndIf
RestArea(aArea)
Return(lRetorno)
*/
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetDebitNo³Autor  ³ Eduardo Riera         ³ Data ³15.05.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Método de recuperacao das notas de credito de um Fornecedor  ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do usuario                                     ³±±
±±³          ³ExpC2: Customer ID                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o Método foi avaliado com sucesso          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este Método recupera as notas de credito de um Fornecedor    ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
WSMETHOD BrwDebitNote WSRECEIVE UserCode,SupplierID,QueryAddWhere,IndexKey WSSEND ListOfBill WSSERVICE FinanceSupplierBill

Local aArea     := GetArea()

Local lRetorno  := .F.
Local lQuery    := .F.
Local nY        := 0
Local cAliasSE2 := "SE2"
Local cFornece  := SubStr(::SupplierID,1,Len(SA2->A2_COD))
Local cLoja     := SubStr(::SupplierID,Len(SA2->A2_COD)+1)
#IFDEF TOP
Local aStruSE2  := {}
Local cQuery    := ""
Local nX        := 0
#ENDIF

DEFAULT ::IndexKey := SE2->(IndexKey())

If PrtChkUser(::UserCode,"FINANCESUPPLIERBILL","BRWDEBITNOTE","SA2",::SupplierID)

	If !Empty(cFornece) .And. !Empty(cLoja)
	
		lRetorno := .T.

		dbSelectArea("SE2")
		dbSetOrder(6)
		#IFDEF TOP
			lQuery    := .T.
			aStruSE2  := SE2->(dbStruct())
			cAliasSE2 := "FINGETBILL"
			
			cQuery := "SELECT E2_FILIAL,E2_FORNECE,E2_LOJA,E2_SALDO,E2_TIPO,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_VALOR,"
			cQuery += "E2_NATUREZ,E2_EMISSAO,E2_VENCTO,E2_VENCREA,E2_MOEDA,E2_PORTADO,E2_HIST,E2_PORCJUR,E2_DTVARIA,"
			cQuery += "E2_VALJUR,E2_VALOR "
			cQuery += GetUserField("SE2")
			cQuery += "FROM "+RetSqlName("SE2")+" SE2 "
			cQuery += "WHERE "
			cQuery += "SE2.E2_FILIAL = '"+xFilial("SE2")+"' AND "
			cQuery += "SE2.E2_FORNECE='"+cFornece+"' AND "
			cQuery += "SE2.E2_LOJA='"+cLoja+"' AND "
			cQuery += "SE2.E2_SALDO > 0 AND "
			cQuery += "SE2.E2_TIPO IN "+FormatIn(MV_CPNEG+"/"+MVPAGANT,"/")+" AND "
			cQuery += "SE2.D_E_L_E_T_=' ' "
			cQuery := WsQueryAdd(cQuery,::QueryAddWhere)
			cQuery += "ORDER BY "+WsSqlOrder(::IndexKey)
			
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2)
			
			For nX := 1 To Len(aStruSE2)
				If aStruSE2[nX][2]<>"C".And. FieldPos(aStruSE2[nX][1])<>0
					TcSetField(cAliasSE2,aStruSE2[nX][1],aStruSE2[nX][2],aStruSE2[nX][3],aStruSE2[nX][4])
			    EndIf
			Next nX
		#ELSE
			MsSeek(xFilial("SE2")+::SupplierID)
		#ENDIF
		
		While !Eof() .And. xFilial("SE2") == (cAliasSE2)->E2_FILIAL .And.;
			cFornece == (cAliasSE2)->E2_FORNECE .And.;
			cLoja == (cAliasSE2)->E2_LOJA		
			If (cAliasSE2)->E2_SALDO > 0 .And. (cAliasSE2)->E2_TIPO$MV_CPNEG
				aadd(::ListOfBILL,WSClassNew("BillView"))
				nY++
				GetCPBill(@::ListOfBill[nY],cAliasSE2,.T.)
			EndIf
			dbSelectArea(cAliasSE2)
			dbSkip()
		EndDo
		If lQuery
			dbSelectArea(cAliasSE2)
			dbCloseArea()
			dbSelectArea("SE2")
		EndIf
	Else
		lRetorno := .F.
		SetSoapFault("BRWDEBITNOTE","Fornecedor invalido")
	EndIf
EndIf
RestArea(aArea)
Return(lRetorno)
*/

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³BrwPaidBil³Autor  ³ Eduardo Riera         ³ Data ³21.03.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Método de recuperacao dos titulos financeiros do Fornecedor  ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do usuario                                     ³±±
±±³          ³ExpC2: Customer ID                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o Método foi avaliado com sucesso          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este Método recupera uma colecao de titulos pagos jutamente  ³±±
±±³          ³com seus respectivos pagamentos                              ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
WSMETHOD BrwPaidBill WSRECEIVE UserCode,SupplierID,DateFrom,DateTo,QueryAddWhere,IndexKey WSSEND ListOfBill WSSERVICE FinanceSupplierBill

Local aArea     := GetArea()
Local aChave    := {}
Local lRetorno  := .F.
Local lQuery    := .F.
Local lSkip     := .F.
Local nX        := 0
Local nY        := 0
Local cAliasSE2 := "SE2"
Local cAliasSE5 := "SE5"
Local cFornece  := SubStr(::SupplierID,1,Len(SA2->A2_COD))
Local cLoja     := SubStr(::SupplierID,Len(SA2->A2_COD)+1)
Local dDataIni  := ::DateFrom
Local dDataFim  := ::DateTo  
#IFDEF TOP
Local aStruSE2  := {}
Local aStruSE5  := {}
Local cQuery    := ""
#ENDIF

DEFAULT ::IndexKey := SE2->(IndexKey())
dDataIni := IIF(Empty(dDataIni),Ctod("01/01/1980"),dDataIni)
dDataFim := IIF(Empty(dDataFim),dDataBase,dDataFim)

If PrtChkUser(::UserCode,"FINANCESUPPLIERBILL","BRWPAIDBILL","SA2",::SupplierID)

	If !Empty(cFornece) .And. !Empty(cLoja)
	
		lRetorno := .T.
		
		dbSelectArea("SE2")
		dbSetOrder(6)
		#IFDEF TOP
			lQuery    := .T.
			aStruSE2  := SE2->(dbStruct())
			aStruSE5  := SE5->(dbStruct())
			
			cAliasSE2 := "FINGETBILL"
			cAliasSE5 := "FINGETBILL"			
			
			cQuery := "SELECT E2_FILIAL,E2_FORNECE,E2_LOJA,E2_SALDO,E2_TIPO,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_VALOR,"
			cQuery += "E2_NATUREZ,E2_EMISSAO,E2_VENCTO,E2_VENCREA,E2_MOEDA,E2_PORTADO,E2_HIST,E2_PORCJUR,E2_DTVARIA,"
			cQuery += "E2_VALJUR,E2_VALOR,"
			cQuery += "E5_FILIAL,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_TIPO,E5_CLIFOR,E5_LOJA,E5_TIPODOC,E5_DATA,"
			cQuery += "E5_SITUACA,E5_RECPAG,E5_MOTBX,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_DATA,E5_DTDISPO,E5_VALOR,"
			cQuery += "E5_HISTOR,E5_ORDREC,E5_SERREC"			
			cQuery += GetUserField("SE2")
			cQuery += GetUserField("SE5")			
			cQuery += "FROM "+RetSqlName("SE2")+" SE2,"
			cQuery += RetSqlName("SE5")+" SE5 "
			cQuery += "WHERE "
			cQuery += "SE2.E2_FILIAL = '"+xFilial("SE2")+"' AND "
			cQuery += "SE2.E2_FORNECE='"+cFornece+"' AND "
			cQuery += "SE2.E2_LOJA='"+cLoja+"' AND "
			cQuery += "SE2.E2_TIPO NOT IN "+FormatIn(MV_CPNEG+"/"+MVPAGANT+"/"+MVABATIM,"/")+" AND "
			cQuery += "SE2.E2_SALDO <> E2_VALOR AND "
			cQuery += "SE2.D_E_L_E_T_=' ' AND "
			cQuery += "SE5.E5_FILIAL='"+xFilial("SE5")+"' AND "
			cQuery += "SE5.E5_NATUREZ=SE2.E2_NATUREZ AND "
			cQuery += "SE5.E5_PREFIXO=SE2.E2_PREFIXO AND "
			cQuery += "SE5.E5_NUMERO=SE2.E2_NUM AND "
			cQuery += "SE5.E5_PARCELA=SE2.E2_PARCELA AND "
			cQuery += "SE5.E5_TIPO=SE2.E2_TIPO AND "
			cQuery += "SE5.E5_CLIFOR=SE2.E2_FORNECE AND "
			cQuery += "SE5.E5_LOJA=SE2.E2_LOJA AND "
			cQuery += "SE5.E5_RECPAG='P' AND "
			cQuery += "SE5.E5_DATA>='"+Dtos(dDataIni)+"' AND "
			cQuery += "SE5.E5_DATA<='"+Dtos(dDataFim )+"' AND "
			cQuery += "SE5.E5_SITUACA<>'C' AND "
			cQuery += "SE5.D_E_L_E_T_=' ' AND NOT EXISTS ("
 			cQuery += "SELECT A.E5_NUMERO "
			cQuery += "FROM "+RetSqlName("SE5")+" A "
			cQuery += "WHERE A.E5_FILIAL='"+xFilial("SE5")+"' AND "
			cQuery += "A.E5_NATUREZ=SE5.E5_NATUREZ AND "
			cQuery += "A.E5_PREFIXO=SE5.E5_PREFIXO AND "
			cQuery += "A.E5_NUMERO=SE5.E5_NUMERO AND "
			cQuery += "A.E5_PARCELA=SE5.E5_PARCELA AND "
			cQuery += "A.E5_TIPO=SE5.E5_TIPO AND "
			cQuery += "A.E5_CLIFOR=SE5.E5_CLIFOR AND "
			cQuery += "A.E5_LOJA=SE5.E5_LOJA AND "
			cQuery += "A.E5_SEQ=SE5.E5_SEQ AND "
			cQuery += "A.E5_TIPODOC='ES' AND "
			cQuery += "A.E5_RECPAG<>'P' AND "
			cQuery += "A.D_E_L_E_T_ = ' ') "
			cQuery := WsQueryAdd(cQuery,::QueryAddWhere)
			cQuery += "ORDER BY "+WsSqlOrder(::IndexKey)
			
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2)
			
			For nX := 1 To Len(aStruSE2)
				If aStruSE2[nX][2]<>"C" .And. FieldPos(aStruSE2[nX][1])<>0
					TcSetField(cAliasSE2,aStruSE2[nX][1],aStruSE2[nX][2],aStruSE2[nX][3],aStruSE2[nX][4])
			    EndIf
			Next nX
			For nX := 1 To Len(aStruSE5)
				If aStruSE5[nX][2]<>"C" .And. FieldPos(aStruSE5[nX][1])<>0
					TcSetField(cAliasSE5,aStruSE5[nX][1],aStruSE5[nX][2],aStruSE5[nX][3],aStruSE5[nX][4])
			    EndIf
			Next nX			
		#ELSE
			MsSeek(xFilial("SE2")+::SupplierID)
		#ENDIF
		
		While !Eof() .And. xFilial("SE2") == (cAliasSE2)->E2_FILIAL .And.;
			cFornece == (cAliasSE2)->E2_FORNECE .And.;
			cLoja == (cAliasSE2)->E2_LOJA		
			If (cAliasSE2)->E2_SALDO < (cAliasSE2)->E2_VALOR .And. !(cAliasSE2)->E2_TIPO $ MVABATIM
			
				If !lQuery
					dbSelectArea("SE5")
					dbSetOrder(7)
					MsSeek(xFilial("SE5")+(cAliasSE2)->E2_PREFIXO+(cAliasSE2)->E2_NUM+(cAliasSE2)->E2_PARCELA+(cAliasSE2)->E2_TIPO+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA)
				EndIf

				nX    := 0
				lSkip := .F.
				aChave := {	(cAliasSE2)->E2_PREFIXO ,;
					(cAliasSE2)->E2_NUM ,;
					(cAliasSE2)->E2_PARCELA ,;
					(cAliasSE2)->E2_TIPO ,;
					(cAliasSE2)->E2_FORNECE,;
					(cAliasSE2)->E2_LOJA}

				
				While !Eof() .And. xFilial("SE5") == (cAliasSE5)->E5_FILIAL .And.;
					aChave[1] == (cAliasSE5)->E5_PREFIXO .And.;
					aChave[2] == (cAliasSE5)->E5_NUMERO .And.;
					aChave[3] == (cAliasSE5)->E5_PARCELA .And.;
					aChave[4] == (cAliasSE5)->E5_TIPO .And.;
					aChave[5] == (cAliasSE5)->E5_CLIFOR .And.;
					aChave[6] == (cAliasSE5)->E5_LOJA
					
					If (cAliasSE5)->E5_TIPODOC $ "VL#BA#V2#CP#LJ#DC#D2#MT#M2#JR#J2#CM#C2#CX" .And.;
						(cAliasSE5)->E5_DATA >= dDataIni .And. (cAliasSE5)->E5_DATA <= dDataFim .And.;
						(cAliasSE5)->E5_SITUACA <> "C" .And.;
						(cAliasSE5)->E5_RECPAG == "P" .And.;
						IIf(lQuery,.T.,!TemBxCanc())
						nX++					
						If nX == 1
							aadd(::ListOfBill,WSClassNew("BillView"))
							nY++
							GetCPBill(@::ListOfBill[nY],cAliasSE2,.T.)
						EndIf
					EndIf
					dbSelectArea(cAliasSE5)
					dbSkip()
					lSkip := .T.
				EndDo
			EndIf
			If !lQuery .Or. !lSkip
				dbSelectArea(cAliasSE2)
				dbSkip()
			EndIf
		EndDo
		If lQuery
			dbSelectArea(cAliasSE2)
			dbCloseArea()
			dbSelectArea("SE2")
		EndIf
	Else
		lRetorno := .F.
		SetSoapFault("BRWPAIDBILL","Fornecedor invalido")
	EndIf
Else
	lRetorno := .F.
EndIf
RestArea(aArea)
Return(lRetorno)
*/

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetPaidBil³Autor  ³ Eduardo Riera         ³ Data ³04.12.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Método de recuperacao dos dados de um titulo pago do fornece-³±±
±±³          ³dor                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do usuario                                     ³±±
±±³          ³ExpC2: Codigo do fornecedor                                  ³±±
±±³          ³ExpC3: Prefixo                                               ³±±
±±³          ³ExpC4: Numero                                                ³±±
±±³          ³ExpC3: Parcela                                               ³±±
±±³          ³ExpC4: Tipo                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o Método foi avaliado com sucesso          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Este Método recupera os dados de um titulo pago juntamente   ³±±
±±³          ³com seus respectivos pagamentos.                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
WSMETHOD GetPaidBill WSRECEIVE UserCode,SupplierID,Prefix,BillNumber,Installment,BillType WSSEND PaidBill WSSERVICE FinanceSupplierBill

Local aArea     := GetArea()
Local lRetorno  := .F.
Local lQuery    := .F.
Local nX        := 0
Local cAliasSE5 := "SE5"
Local cFornece  := SubStr(::SupplierID,1,Len(SA2->A2_COD))
Local cLoja     := SubStr(::SupplierID,Len(SA2->A2_COD)+1)
#IFDEF TOP
Local aStruSE5  := {}
Local cQuery    := ""
#ENDIF

If PrtChkUser(::UserCode,"FINANCESUPPLIERBILL","GETPAIDBILL","SA2",::SupplierID)

	If !Empty(cFornece) .And. !Empty(cLoja)
	
		dbSelectArea("SE2")
		dbSetOrder(1)
		If MsSeek(xFilial("SE2")+::Prefix+::BillNumber+::Installment+::BillType+::SupllierId)
	
			lRetorno := .T.
			dbSelectArea("SE5")
			dbSetOrder(7)			
			#IFDEF TOP
				lQuery    := .T.
				aStruSE5  := SE5->(dbStruct())
				
				cAliasSE5 := "FINGETBILL"			
				
				cQuery := "SELECT E5_FILIAL,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_TIPO,E5_CLIFOR,E5_LOJA,E5_TIPODOC,E5_DATA,"
				cQuery += "E5_SITUACA,E5_RECPAG,E5_MOTBX,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_DATA,E5_DTDISPO,E5_VALOR,"
				cQuery += "E5_HISTOR,E5_ORDREC,E5_SERREC"			
				cQuery += GetUserField("SE5")			
				cQuery += "FROM "+RetSqlName("SE5")+" SE5 "
				cQuery += "WHERE "
				cQuery += "SE5.E5_FILIAL='"+xFilial("SE5")+"' AND "
				cQuery += "SE5.E5_NATUREZ='"+SE2->E2_NATUREZ+"' AND "
				cQuery += "SE5.E5_PREFIXO='"+SE2->E2_PREFIXO+"' AND "
				cQuery += "SE5.E5_NUMERO='"+SE2->E2_NUM+"' AND "
				cQuery += "SE5.E5_PARCELA='"+SE2->E2_PARCELA+"' AND "
				cQuery += "SE5.E5_TIPO='"+SE2->E2_TIPO+"' AND "
				cQuery += "SE5.E5_CLIFOR='"+SE2->E2_FORNECE+"' AND "
				cQuery += "SE5.E5_LOJA='"+SE2->E2_LOJA+"' AND "
				cQuery += "SE5.E5_RECPAG='P' AND "
				cQuery += "SE5.E5_DATA>='"+Dtos(dDataIni)+"' AND "
				cQuery += "SE5.E5_DATA<='"+Dtos(dDataFim )+"' AND "
				cQuery += "SE5.E5_SITUACA<>'C' AND "
				cQuery += "SE5.D_E_L_E_T_=' ' AND NOT EXISTS ("
	 			cQuery += "SELECT A.E5_NUMERO "
				cQuery += "FROM "+RetSqlName("SE5")+" A "
				cQuery += "WHERE A.E5_FILIAL='"+xFilial("SE5")+"' AND "
				cQuery += "A.E5_NATUREZ=SE5.E5_NATUREZ AND "
				cQuery += "A.E5_PREFIXO=SE5.E5_PREFIXO AND "
				cQuery += "A.E5_NUMERO=SE5.E5_NUMERO AND "
				cQuery += "A.E5_PARCELA=SE5.E5_PARCELA AND "
				cQuery += "A.E5_TIPO=SE5.E5_TIPO AND "
				cQuery += "A.E5_CLIFOR=SE5.E5_CLIFOR AND "
				cQuery += "A.E5_LOJA=SE5.E5_LOJA AND "
				cQuery += "A.E5_SEQ=SE5.E5_SEQ AND "
				cQuery += "A.E5_TIPODOC='ES' AND "
				cQuery += "A.E5_RECPAG<>'P' AND "
				cQuery += "A.D_E_L_E_T_ = ' ') "
				cQuery := WsQueryAdd(cQuery,::QueryAddWhere)
				cQuery += "ORDER BY "+WsSqlOrder(SE5->(IndexKey()))
				
				cQuery := ChangeQuery(cQuery)
	
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE5)
				
				For nX := 1 To Len(aStruSE5)
					If aStruSE5[nX][2]<>"C" .And. FieldPos(aStruSE5[nX][1])<>0
						TcSetField(cAliasSE5,aStruSE5[nX][1],aStruSE5[nX][2],aStruSE5[nX][3],aStruSE5[nX][4])
				    EndIf
				Next nX			
			#ELSE		
				MsSeek(xFilial("SE5")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA)
			#ENDIF
	
			nX    := 0
			
			While !Eof() .And. xFilial("SE5") == (cAliasSE5)->E5_FILIAL .And.;
				SE2->E2_PREFIXO == (cAliasSE5)->E5_PREFIXO .And.;
				SE2->E2_NUM == (cAliasSE5)->E5_NUMERO .And.;
				SE2->E2_PARCELA == (cAliasSE5)->E5_PARCELA .And.;
				SE2->E2_TIPO == (cAliasSE5)->E5_TIPO .And.;
				SE2->E2_FORNECE == (cAliasSE5)->E5_CLIFOR .And.;
				SE2->E2_LOJA == (cAliasSE5)->E5_LOJA
					
				If (cAliasSE5)->E5_TIPODOC $ "VL#BA#V2#CP#LJ#DC#D2#MT#M2#JR#J2#CM#C2#CX" .And.;
					(cAliasSE5)->E5_DATA >= dDataIni .And. (cAliasSE5)->E5_DATA <= dDataFim .And.;
					(cAliasSE5)->E5_SITUACA <> "C" .And.;
					(cAliasSE5)->E5_RECPAG == "P" .And.;
					IIf(lQuery,.T.,!TemBxCanc())
					nX++					
					If nX == 1
						::PaidBill:Bill := WSClassNew("BillView")
						::PaidBill:Payment := {}
						GetCPBill(@::PaidBill:Bill,"SE2")
					EndIf
					aadd(::PaidBill:PayMent,WSClassNew("PaidBillView"))
					GetCPPaidBill(@::PaidBill:PayMent[nX],cAliasSE5)
				EndIf
				dbSelectArea(cAliasSE5)
				dbSkip()
			EndDo
			If lQuery
				dbSelectArea(cAliasSE5)
				dbCloseArea()
				dbSelectArea("SE5")
			EndIf
		Else
			lRetorno := .F.
			SetSoapFault("GETPAIDBILL","Titulo nao encontrado")
		EndIf
	Else
		lRetorno := .F.
		SetSoapFault("GETPAIDBILL","Fornecedor invalido")
	EndIf
Else
	lRetorno := .F.
EndIf
RestArea(aArea)
Return(lRetorno)
*/
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetCPBill ³Autor  ³ Eduardo Riera         ³ Data ³04.12.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Montagem da estrutura de titulos financeiros                 ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto da estrutura de titulos                        ³±±
±±³          ³ExpC2: Alias do SE2                                          ³±±
±±³          ³ExpL3: Indica se a otimizacao deve ser utilizada             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o Método foi avaliado com sucesso          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta funcao atualiza a estrutura Bill com os dados do titulo ³±±
±±³          ³financeiro                                                   ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Function GetCPBill(oObjeto,cAliasSE2,lFast)

Local aValores := {}

DEFAULT lFast := .F.
aValores := FaVlAtuCP(cAliasSE2,dDataBase,"NOR",lFast)
If lFast
	aValores[11] := Nil
	aValores[12] := Nil
EndIf
oObjeto:Prefix                := (cAliasSE2)->E2_PREFIXO
oObjeto:BillNumber            := (cAliasSE2)->E2_NUM
oObjeto:Installment           := (cAliasSE2)->E2_PARCELA	
oObjeto:BillType              := (cAliasSE2)->E2_TIPO
oObjeto:ClassCode             := (cAliasSE2)->E2_NATUREZ
oObjeto:IssueDate             := (cAliasSE2)->E2_EMISSAO
oObjeto:OriginalDueDate       := (cAliasSE2)->E2_VENCTO
oObjeto:RealDueDate           := (cAliasSE2)->E2_VENCREA
oObjeto:Currency              := (cAliasSE2)->E2_MOEDA
oObjeto:CurrencySimbol        := SuperGetMV("MV_SIMB"+AllTrim(Str((cAliasSE2)->E2_MOEDA,2)))
oObjeto:OriginalValue         := aValores[1]
oObjeto:OriginalCurrencyValue := xMoeda(aValores[01],(cAliasSE2)->E2_MOEDA,1)
oObjeto:DeductionsValue       := aValores[02]
oObjeto:IncreaseValue         := aValores[05]
oObjeto:DecreaseValue         := aValores[04]
oObjeto:BalanceValue          := aValores[11]
oObjeto:BalanceCurrencyValue  := aValores[12]
oObjeto:Bank                  := (cAliasSE2)->E2_PORTADO
oObjeto:History               := (cAliasSE2)->E2_HIST
oObjeto:DelayInDays           := IIf((cAliasSE2)->E2_VENCREA>dDatabase,dDataBase-(cAliasSE2)->E2_VENCTO,0)
oObjeto:DaylyInterestRate     := (cAliasSE2)->E2_PORCJUR
oObjeto:DaylyInterestValue    := (cAliasSE2)->E2_VALJUR
UserFields("SE2",@oObjeto:UserFields,cAliasSE2)
Return(.T.)
  */
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetCPPaid ³Autor  ³ Eduardo Riera         ³ Data ³04.12.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Montagem da estrutura de pagamentos dos titulos financeiros  ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto da estrutura de titulos                        ³±±
±±³          ³ExpC2: Alias do SE5                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica que o Método foi avaliado com sucesso          ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta funcao atualiza a estrutura Bill com os dados do titulo ³±±
±±³          ³financeiro                                                   ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CRM/Materiais/Portais                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Function GetCPPaidBill(oObjeto,cAliasSE5)

oObjeto:ReasonOfWriteOff    := (cAliasSE5)->E5_MOTBX
oObjeto:Bank                := (cAliasSE5)->E5_BANCO
oObjeto:BankBranch          := (cAliasSE5)->E5_AGENCIA
oObjeto:BankAccount         := (cAliasSE5)->E5_CONTA
oObjeto:PaidDate            := (cAliasSE5)->E5_DATA
oObjeto:CreditDate          := (cAliasSE5)->E5_DTDISPO
oObjeto:Currency            := 1
oObjeto:CurrencySimbol      := SuperGetMv("MV_SIMB1")
oObjeto:ValuePaid           := (cAliasSE5)->E5_VALOR
oObjeto:CurrencyValuePaid   := (cAliasSE5)->E5_VALOR
oObjeto:History             := (cAliasSE5)->E5_HISTOR
oObjeto:ReceiptOrPaymentOrder := (cAliasSE5)->E5_ORDREC
oObjeto:SerialReceipt       := (cAliasSE5)->E5_SERREC
If (cAliasSE5)->E5_TIPODOC $ "VL#BA#V2#CP#LJ"
	oObjeto:WriteOffType        :=  "1"
	oObjeto:TypeDescription  :=  "Principal"
EndIf
If ( (cAliasSE5)->E5_TIPODOC$"DC#D2" )
	oObjeto:WriteOffType        :=  "2"
	oObjeto:TypeDescription  :=  "Desconto"
Endif
If (cAliasSE5)->E5_TIPODOC$"MT#M2"
	oObjeto:WriteOffType        :=  "3"
	oObjeto:TypeDescription  :=  "Multa"
EndIf
If (cAliasSE5)->E5_TIPODOC$"JR#J2"
	oObjeto:WriteOffType        :=  "4"
	oObjeto:TypeDescription  :=  "Juros"
EndIf
If (cAliasSE5)->E5_TIPODOC$"CM#C2#CX"
	oObjeto:WriteOffType        :=  "5"
	oObjeto:TypeDescription  :=  "Correcao Monetaria"
EndIf
UserFields("SE5",@oObjeto:UserFields,cAliasSE5)
Return(.T.)
*/
