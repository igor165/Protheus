#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "LOJI120O.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} LojI120o() 
Mensagem única de integração do Operador\Caixa com FWEaiObj

@param oEaiObj		- Objeto FWEaiObj recebido via msg unica
@param nTypeTrans 	- Determina se e uma mensagem a ser enviada/recebida (TRANS_SEND ou TRANS_RECEIVE)	
@param cTypeMessage	- Tipo de mensagem (EAI_MESSAGE_WHOIS, EAI_MESSAGE_RESPONSE, EAI_MESSAGE_BUSINESS)

@author  Rafael Tenorio da Costa
@since   05/12/18
/*/
//-------------------------------------------------------------------
Function LojI120o(oEaiObj, nTypeTrans, cTypeMessage)

	Local aRet		:= {}
	Local oCashOper := CashierOperatorAdapter():New(oEaiObj)

	If nTypeTrans == TRANS_RECEIVE

		Do Case

			Case cTypeMessage == EAI_MESSAGE_BUSINESS
				oCashOper:ReceiveBusiness()
				aRet := {oCashOper:GetOk(), oCashOper:GetEaiObjSnd() , oCashOper:GetMsgName()}

			Case cTypeMessage == EAI_MESSAGE_RESPONSE
				oCashOper:ReceiveResponse()
				aRet := {oCashOper:GetOk(), oCashOper:GetEaiObjSnd(), oCashOper:GetMsgName()}			

			Case cTypeMessage == EAI_MESSAGE_WHOIS
				aRet := {oCashOper:GetOk(), oCashOper:GetVersion()	 , oCashOper:GetMsgName()}

		EndCase

	ElseIf nTypeTrans == TRANS_SEND 
		oCashOper:SendBusiness()
		aRet:={oCashOper:GetOk(), oCashOper:GetEaiObjSnd(), oCashOper:GetMsgName()}	

	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe CashierOperatorAdapter
	Classe do adapter de Operadores de Caixa utiliza o FwEaiObj
/*/
//-------------------------------------------------------------------
Class CashierOperatorAdapter

	Data lOk		as Logical
	Data cError 	as Character
	Data cDetail	as Character

	Data nOperation    			as Numeric

	Data cProduct    			as Character
	Data cInternalId 			as Character
	Data cExternalId 			as Character
	Data cCashierCode	 		as Character
	Data cExtCashierCode	 	as Character
	Data cName	 				as Character
	Data cShortName	 			as Character
	Data aWithdrawalLimit		as Array
	Data nDiscountTotalPercent	as Numeric
	Data nDiscountTotalValue	as Numeric
	Data nDiscountItemPercent	as Numeric
	Data nDiscountItemValue		as Numeric
	Data cCardNumber	 		as Character
	Data nCanWithdrawal	 		as Numeric
	Data nCanCancelItem	 		as Numeric
	Data nCanCancelSale	 		as Numeric
	Data nCanEditPayment 		as Numeric
	Data nCanOpenDrawer	 		as Numeric

	Data cOldUser				as Character

	Data oConfigOpe	 as Object

	Data oFieldsHash as Object
	Data oEaiobjSnd  as Object
	Data oEaiobjRec  as Object

	Method New()

	Method ReceiveBusiness()
	Method ReceiveResponse()
	Method SendBusiness()

	Method Include()
	Method Alter()
	Method Delete()
	Method Get()
	Method GetApi()

	Method GetFields()
	Method SetInformation()
	Method ValidInformation()
	Method LoadOperator(nOpcao)
	Method CreateQuery()

	Method SetCashierCode(cOperador)

	Method GetMsgName()
	Method GetOk()
	Method GetError()
	Method GetVersion()
	Method GetEaiObjSnd()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@param oEaiRec - FwObjEai recebido pela mensagem unica

@author Rafael Tenorio da Costa
@since  05/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(oEaiRec) Class CashierOperatorAdapter

	Default oEaiRec := Nil
	
	self:lOk		:= .T.
	self:cError		:= ""
	self:cDetail	:= ""

	self:nOperation				:= MODEL_OPERATION_INSERT
	self:cProduct				:= ""
	self:cInternalId			:= ""
	self:cExternalId			:= ""
	self:cCashierCode			:= ""
	self:cExtCashierCode		:= ""
	self:cName					:= ""
	self:cShortName				:= ""
	self:aWithdrawalLimit		:= {}
	self:nDiscountTotalPercent 	:= 0
	self:nDiscountTotalValue 	:= 0
	self:nDiscountItemPercent 	:= 0
	self:nDiscountItemValue 	:= 0
	self:cCardNumber			:= ""
	self:nCanWithdrawal 		:= 0
	self:nCanCancelItem 		:= 0
	self:nCanCancelSale 		:= 0
	self:nCanEditPayment 		:= 0
	self:nCanOpenDrawer 		:= 0
	self:cOldUser				:= ""

	self:oConfigOpe := JsonObject():New()
	self:oEaiObjSnd := FwEaiObj():New()
	self:oEaiObjRec := oEaiRec

	self:GetFields()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ReceiveBussines
Método que ira fazer a tratativa do processo eai para recebimento 
de mensagem business

@param Vazio

@return nil

@author Rafael Tenorio da Costa
@since 05/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method ReceiveBusiness() Class CashierOperatorAdapter

	//Carrega propriedade com a mensagem recebida
	self:SetInformation()

	//Valida as propriedades carregadas
	self:ValidInformation()

	If self:lOk

		If self:oEaiObjRec:getEvent() == "delete"

			Begin Transaction

				self:Delete()

				If self:lOk

					//Exclusão
					If !CfgA070Mnt(self:cProduct, "SLF", "LF_COD", /*cValExt*/, self:cInternalId, .T., /*nOrdem*/, /*cTable*/, /*cOwnerMsg*/)
						self:lOk 	:= .F.
						self:cError := STR0001	//"Não foi possível atualizar De\Para de Operadores"
					EndIf
				Endif

			End Transaction

		Else

			Begin Transaction

				If self:nOperation == MODEL_OPERATION_INSERT
					self:Include()
				Else
					self:Alter()
				EndIf

				If self:lOk

					//Inclusão
					If self:nOperation == MODEL_OPERATION_INSERT
						If !CfgA070Mnt(self:cProduct, "SLF", "LF_COD", self:cExternalId, self:cInternalId, /*lDelete*/, /*nOrdem*/, /*cTable*/, /*cOwnerMsg*/)
							self:lOk 	:= .F.
							self:cError := STR0001	//"Não foi possível atualizar De\Para de Operadores"
						EndIf
					EndIf

					//Monta retorno
					If self:lOk
						self:oEaiObjSnd:setProp("CashierCode"			, self:cExtCashierCode	)
						self:oEaiObjSnd:setProp("ExternalCode"			, self:cCashierCode		)
						self:oEaiObjSnd:setProp("DestinationInternalId"	, self:cInternalId		)
						self:oEaiObjSnd:setProp("OriginInternalId"		, self:cExternalId		)
					EndIf
				EndIf

			End Transaction

		EndIf

	EndIf

	If !self:lOk
		self:oEaiobjSnd:setProp("Error", self:cError)
		LjGrvLog("LOJI120O", self:cError)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ReceiveResponse
Método que ira fazer a tratativa do processo eai para recebimento 
de mensagem Response

@author  Rafael Tenorio da Costa
@since 	 05/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method ReceiveResponse() Class CashierOperatorAdapter

	Local oMensagens := Nil
	Local cMensagem	 := ""
	Local cErro		 := ""
	Local nCont		 := 0

	self:oEaiobjSnd:Activate()

	If self:oEaiObjRec:getPropValue("ProcessingInformation") == Nil

		self:lOk 	:= .F.
		self:cError := I18n(STR0002, {"ProcessingInformation"})		//"Tag #1 não informada"

	Else

		If Upper( self:oEaiObjRec:getPropValue("ProcessingInformation"):getPropValue("Status") ) == "OK" .And.;
				self:oEaiObjRec:getPropValue("ListOfInternalId") <> Nil
		
			self:cProduct		:= self:oEaiObjRec:getHeaderValue("ProductName")
			self:cExternalId	:= self:oEaiObjRec:getPropValue("ListOfInternalId")[1]:getPropValue("Origin")
			self:cInternalId	:= self:oEaiObjRec:getPropValue("ListOfInternalId")[1]:getPropValue("Destination")
		
			If !Empty(self:cExternalId) .Or. !Empty(self:cInternalId)
				self:lOk 	:= .F.
				self:cError := STR0003	//"Valor Interno ou Externo vazio, não será possível atualizar De\Para de Operadores"
			Else

				//Grava de/para de Operadores
				If !CfgA070Mnt(self:cProduct, "SLF", "LF_COD", self:cExternalId, self:cInternalId)
					self:lOk 	:= .F.
					self:cError := STR0001	//"Não foi possível atualizar De\Para de Operadores"
				EndIf
			EndIf

		Else

			oMensagens := self:oEaiObjRec:getPropValue("ProcessingInformation"):getPropValue("ListOfMessages")

			For nCont:=1 To Len(oMensagens)

				cMensagem := oMensagens[nCont]:getPropValue("Message")

				If cMensagem <> NiL .And. ValType(cMensagem) == "C"
					cErro += cMensagem + CRLF
				EndIf
			Next nCont

			self:lOk 	:= .F.
			self:cError := STR0004 + cErro	//"Erro ao obter resposta: "
		EndIf

	EndIf

	If !self:lOk
		self:oEaiobjSnd:setProp("Error", self:cError)
		LjGrvLog("LOJI120O", self:cError)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SendBusiness
Método que ira fazer a tratativa do processo eai para Envio 
de mensagem Business

@param Vazio

@return nil

@author Rafael Tenorio da Costa
@since 05/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method SendBusiness() Class CashierOperatorAdapter
	self:Get()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Include
Método que ira fazer a inclusão do Operador uma vez que os campos forem
carregados

@author  Rafael Tenorio da Costa
@since   05/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method Include() Class CashierOperatorAdapter

	Local aAux := {}

	self:LoadOperator(1)

	self:oEaiobjSnd:Activate()

	aAux := LjI120Grv(self:oConfigOpe)

	If aAux[1]

		self:lOk 		  := .T.
		self:cError 	  := ""
		self:cCashierCode := aAux[2]
		self:cInternalId  := cEmpAnt + "|" + RTrim( xFilial("SLF") ) + "|" + self:cCashierCode
	Else

		self:lOk 	:= .F.
		self:cError := I18n(STR0005, {STR0006}) + CRLF + aAux[2]		//"Não foi possível efetuar a #1 do Operador"	//"inclusão"
	EndIf

	FwFreeObj(aAux)	

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Método que ira fazer a alteração do Operador uma vez que os campos forem
carregados

@author  Rafael Tenorio da Costa
@since   10/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method Alter() Class CashierOperatorAdapter

	Local aAux 	   := {}
	Local aArea    := GetArea()
	Local aAreaSA6 := SA6->( GetArea() )

	SA6->( DbSetOrder(1) )
	If SA6->( DbSeek(xFilial("SA6") + self:cCashierCode) )
		self:cCashierCode := SA6->A6_COD
		self:cOldUser	  := SA6->A6_NOME
	EndIf

	self:LoadOperator(2)

	self:oEaiobjSnd:Activate()

	Begin Transaction

		aAux := LjI120Grv(self:oConfigOpe)

		If aAux[1]

			self:lOk 		 := .T.
			self:cError 	 := ""
			self:cInternalId := cEmpAnt + "|" + RTrim( xFilial("SLF") ) + "|" + self:cCashierCode
		Else

			self:lOk 	:= .F.
			self:cError := I18n(STR0005, {STR0007}) + CRLF + aAux[2]	//"Não foi possível efetuar a #1 do Operador"		//"alteração"
		EndIf

	End Transaction

	FwFreeObj(aAux)

	RestArea(aAreaSA6)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Delete
Método que ira fazer a deleção da Operador uma vez que os campos forem
carregados

@author  Rafael Tenorio da Costa
@since   05/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method Delete() Class CashierOperatorAdapter

	Local aAux := {}

	If self:lOk

		SA6->( DbSetOrder(1) )
		If SA6->( DbSeek(xFilial("SA6") + self:cCashierCode) )
			self:cCashierCode := SA6->A6_COD
			self:cName		  := SA6->A6_NOME
		EndIf	

		self:LoadOperator(3)

		self:oEaiobjSnd:Activate()

		Begin Transaction

			aAux := LjI120Grv(self:oConfigOpe)

			If aAux[1]

				self:lOk 		 := .T.
				self:cError 	 := ""
				self:cInternalId := cEmpAnt + "|" + RTrim( xFilial("SLF") ) + "|" + self:cCashierCode
			Else

				self:lOk 	:= .F.
				self:cError := I18n(STR0005, {STR0008}) + CRLF + aAux[2]		//"Não foi possível efetuar a #1 do Operador"	//"exclusão"
			EndIf

		End Transaction

	EndIf

	FwFreeObj(aAux)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Get
Método que ira buscar e retornar os operadores\caixa utilizado na mensagem unica.

@author  Rafael Tenorio da Costa
@since   05/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method Get() Class CashierOperatorAdapter

	Local aArea 	:= GetArea()
	Local aAreaSLF 	:= SLF->( GetArea() )
	Local aAreaSA6 	:= SA6->( GetArea() )
	Local cEvent 	:= IIF(!Inclui .And. !Altera, "delete", "upsert")

	self:oEaiobjSnd:Activate()

	self:lOk := .T.
	self:oEaiobjSnd:SetEvent(cEvent)

	self:oEaiobjSnd:setProp("CashierCode"			, AllTrim(SLF->LF_COD) 													)
	self:oEaiobjSnd:setProp("InternalId"			, cEmpAnt + "|" + RTrim ( xFilial("SLF") ) + "|" + AllTrim(SLF->LF_COD)	)
	self:oEaiobjSnd:setProp("DiscountTotalPercent"	, SLF->LF_TOTDESP														)
	self:oEaiobjSnd:setProp("DiscountTotalValue"	, SLF->LF_TOTDESV														)
	self:oEaiobjSnd:setProp("DiscountItemPercent"	, SLF->LF_DESCPER														)
	self:oEaiobjSnd:setProp("DiscountItemValue"		, SLF->LF_DESCVAL														)
	self:oEaiobjSnd:setProp("CardNumber"			, _NoTags( AllTrim( Encript( AllTrim(SLF->LF_NUMCART), 1) ) )			)
	self:oEaiobjSnd:setProp("CanWithdrawal"			, IIF(Substr(SLF->LF_ACESSO,5 ,1) == "S", 1, IIF( Substr(SLF->LF_ACESSO,5 ,1) == "N", 2 , 3 ))	)
	self:oEaiobjSnd:setProp("CanCancelItem"			, IIF(Substr(SLF->LF_ACESSO,7 ,1) == "S", 1, IIF( Substr(SLF->LF_ACESSO,7 ,1) == "N", 2 , 3 ))	)
	self:oEaiobjSnd:setProp("CanCancelSale"			, IIF(Substr(SLF->LF_ACESSO,8 ,1) == "S", 1, IIF( Substr(SLF->LF_ACESSO,8 ,1) == "N", 2 , 3 ))	)
	self:oEaiobjSnd:setProp("CanEditPayment"		, IIF(Substr(SLF->LF_ACESSO,9 ,1) == "S", 1, IIF( Substr(SLF->LF_ACESSO,9 ,1) == "N", 2 , 3 ))	)
	self:oEaiobjSnd:setProp("CanOpenDrawer"			, IIF(Substr(SLF->LF_ACESSO,13,1) == "S", 1, IIF( Substr(SLF->LF_ACESSO,13,1) == "N", 2 , 3 ))	)
	
	SA6->( DbSetOrder(1) )	//A6_FILIAL+A6_COD
	If SA6->( Dbseek(xFilial("SA6") + SLF->LF_COD) )
		self:oEaiobjSnd:setProp("Name"		, AllTrim(SA6->A6_NOME)	  )	
		self:oEaiobjSnd:setProp("ShortName" , AllTrim(SA6->A6_NREDUZ) )
	EndIf

	If FWAliasInDic("MGW")
		MGW->( DbSetOrder(1) )	//MGW_FILIAL+MGW_CAIXA+MGW_FPAGTO 
		If MGW->( DbSeek(xFilial("MGW") + SLF->LF_COD + "R$") )
			self:oEaiobjSnd:setProp("WithdrawalLimit" , MGW->MGW_LIM1)
		EndIf
	EndIf

	RestArea(aAreaSA6)
	RestArea(aAreaSLF)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetApi
Método que ira buscar e retornar os operadores\caixa utilizado para API.

@author  Rafael Tenorio da Costa
@since 	 13/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetApi() Class CashierOperatorAdapter

	Local nCount     	:= 0
	Local cAliasQuery 	:= ""
	Local oPage      	:= Nil
	Local aFields		:= {}
	Local nFields		:= 0
	Local nX			:= 0
	Local aArea 		:= GetArea()
	Local aAreaSLF 		:= SLF->( GetArea() )
	Local aAreaSA6 		:= SA6->( GetArea() )
	Local aAux 			:= {}
	Local cTag	   		:= ""
	Local cExpResult 	:= ""
	Local xResult		:= Nil

	If self:lOk

		self:oEaiobjSnd:Activate()

		//Pega tags que devem retornar
		If !Empty( self:oEaiObjRec:getPathParam("Fields") )
			aFields := self:oEaiObjRec:getPathParam("Fields")
			nFields := Len(aFields)
		EndIf

		//Pepara paginação
		If !Empty( self:oEaiObjRec:GetPage() )
			oPage := FwPageCtrl():New( self:oEaiObjRec:GetPageSize(),self:oEaiObjRec:GetPage() )
		EndIf

		//Busca retorno
		cAliasQuery := self:CreateQuery()
					
		If self:lOk

			While !(cAliasQuery)->( Eof() )

				nCount++

				If !oPage:CanAddLine()
					(cAliasQuery)->( DbSkip() )
					Loop
				EndIf

				//Preenche retorno com tags selecionadas
				If nFields > 0

					For nX:=1 To nFields
						If HmGet(Self:oFieldsHash, aFields[nX], @aAux)
							cTag	   	:= aAux[1][4]
							cExpResult 	:= aAux[1][3]
							xResult		:= (cAliasQuery)->&(cExpResult)
							xResult		:= IIF(ValType(xResult) == "C", RTrim(xResult), xResult)
							self:oEaiobjSnd:setProp(cTag, xResult)
						EndIf
					Next nX
				
				//Preenche retorno com todas as tags
				Else

					If HmList(Self:oFieldsHash, @aAux)
						For nX:=1 To Len(aAux)
							cTag	   	:= aAux[nX][2][1][4]
							cExpResult 	:= aAux[nX][2][1][3]
							xResult		:= (cAliasQuery)->&(cExpResult)
							xResult		:= IIF(ValType(xResult) == "C", RTrim(xResult), xResult)
							self:oEaiobjSnd:setProp(cTag, xResult)
						Next nX
					EndIf
				EndIf

				(cAliasQuery)->( Dbskip() )
			
				If !(cAliasQuery)->( Eof() )
					self:oEaiobjSnd:NextItem()
				EndIf					
			EndDo		
		
			If nCount > ( self:oEaiObjRec:GetPageSize() * self:oEaiObjRec:GetPage() )
				self:oEaiobjSnd:SetHasNext(.T.)
			EndIf
		EndIf

		If Select(cAliasQuery) > 0
			(cAliasQuery)->( DBCloseArea() )
		EndIf	
	EndIf

	RestArea(aAreaSA6)
	RestArea(aAreaSLF)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFields
Método que retorna os campos que serão retornados em um objeto HashMap

@return oFieldsHash - HashMap com os campos

@author  Rafael Tenorio da Costa
@since 	 13/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetFields() Class CashierOperatorAdapter

  	self:oFieldsHash := HmNew()
			   				//Tag					  Campo		  	  Expressão que será executada para gerar o retorno										  Tag que será utilizada para preencher o objeto oEaiObjSnd
	HmAdd(self:oFieldsHash, {"COMPANYID"			, ""			, "cEmpAnt"																				, "CompanyId"			} , 1, 3)
	HmAdd(self:oFieldsHash, {"BRANCHID	"			, "LF_FILIAL"	, "LF_FILIAL"																			, "BranchId"			} , 1, 3)
	HmAdd(self:oFieldsHash, {"CASHIERCODE"			, "LF_COD"		, "LF_COD"																				, "CashierCode"			} , 1, 3)
	HmAdd(self:oFieldsHash, {"INTERNALID"			, ""			, "RTrim(LF_FILIAL) + '|' + AllTrim(LF_COD)"											, "InternalId"			} , 1, 3)	//Para API não é necessario enviar a Empresa
	HmAdd(self:oFieldsHash, {"DISCOUNTTOTALPERCENT"	, "LF_TOTDESP"	, "LF_TOTDESP"																			, "DiscountTotalPercent"} , 1, 3)
	HmAdd(self:oFieldsHash, {"DISCOUNTTOTALVALUE"	, "LF_TOTDESV"	, "LF_TOTDESV"																			, "DiscountTotalValue"	} , 1, 3)
	HmAdd(self:oFieldsHash, {"DISCOUNTITEMPERCENT"	, "LF_DESCPER"	, "LF_DESCPER"																			, "DiscountItemPercent"	} , 1, 3)
	HmAdd(self:oFieldsHash, {"DISCOUNTITEMVALUE"	, "LF_DESCVAL"	, "LF_DESCVAL"																			, "DiscountItemValue"	} , 1, 3)
	HmAdd(self:oFieldsHash, {"CARDNUMBER"			, "LF_NUMCART"	, "_NoTags( AllTrim( Encript( AllTrim(LF_NUMCART), 1) ) )"								, "CardNumber"			} , 1, 3)
	HmAdd(self:oFieldsHash, {"CANWITHDRAWAL"		, "LF_ACESSO"	, "IIF(Substr(LF_ACESSO,5 ,1) == 'S', 1, IIF( Substr(LF_ACESSO,5 ,1) == 'N', 2 , 3 ))"	, "CanWithdrawal"		} , 1, 3)
	HmAdd(self:oFieldsHash, {"CANCANCELITEM"		, "LF_ACESSO"	, "IIF(Substr(LF_ACESSO,7 ,1) == 'S', 1, IIF( Substr(LF_ACESSO,7 ,1) == 'N', 2 , 3 ))"	, "CanCancelItem"		} , 1, 3)
	HmAdd(self:oFieldsHash, {"CANCANCELSALE"		, "LF_ACESSO"	, "IIF(Substr(LF_ACESSO,8 ,1) == 'S', 1, IIF( Substr(LF_ACESSO,8 ,1) == 'N', 2 , 3 ))"	, "CanCancelSale"		} , 1, 3)
	HmAdd(self:oFieldsHash, {"CANEDITPAYMENT"		, "LF_ACESSO"	, "IIF(Substr(LF_ACESSO,9 ,1) == 'S', 1, IIF( Substr(LF_ACESSO,9 ,1) == 'N', 2 , 3 ))"	, "CanEditPayment"		} , 1, 3)
	HmAdd(self:oFieldsHash, {"CANOPENDRAWER"		, "LF_ACESSO"	, "IIF(Substr(LF_ACESSO,13,1) == 'S', 1, IIF( Substr(LF_ACESSO,13,1) == 'N', 2 , 3 ))"	, "CanOpenDrawer"		} , 1, 3)
	HmAdd(self:oFieldsHash, {"NAME"					, "A6_NOME"		, "A6_NOME"																				, "Name"				} , 1, 3)
	HmAdd(self:oFieldsHash, {"SHORTNAME"			, "A6_NREDUZ"	, "A6_NREDUZ"																			, "ShortName"			} , 1, 3)
	HmAdd(self:oFieldsHash, {"WITHDRAWALLIMIT"		, "MGW_LIM1"	, "MGW_LIM1"																			, "WithdrawalLimit"		} , 1, 3)
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetInformation
Metodo que seta as informações do operado\caixa nas propriedades da 
classe, a partir do objeto EAI.

@author Rafael Tenorio da Costa
@since 05/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetInformation() Class CashierOperatorAdapter

	Local nWitdLimit := 0

	//Produto\Marca
	If  !empty(self:oEaiObjRec:getHeaderValue('ProductName'))
		self:cProduct := self:oEaiObjRec:getHeaderValue('ProductName')
	EndIf

	//Codigo do caixa\operador
	If  !empty(self:oEaiObjRec:getPropValue('CashierCode'))
		self:cExtCashierCode := self:oEaiObjRec:getPropValue('CashierCode')
	EndIf

	//InternalId do caixa\operador
	If !empty(self:oEaiObjRec:getPropValue('InternalId'))
		self:cExternalId := self:oEaiObjRec:getPropValue('InternalId')
	EndIf

	//Nome do(a) operador(a) de Caixa
	If !empty(self:oEaiObjRec:getPropValue('Name'))
		self:cName := AllTrim( self:oEaiObjRec:getPropValue('Name') )
	EndIf

	//Nome reduzido do(a) operador(a) de Caixa
	If !empty(self:oEaiObjRec:getPropValue('ShortName'))
		self:cShortName := AllTrim( self:oEaiObjRec:getPropValue('ShortName') )
	EndIf

	//Valor limite para o caixa efetuar sangria
	If !empty(self:oEaiObjRec:getPropValue('WithdrawalLimit'))
		nWitdLimit := LjiOVldTag(self:oEaiObjRec, "WithdrawalLimit", "N")
		self:aWithdrawalLimit := { {"R$", nWitdLimit, nWitdLimit} }
	EndIf

	//Percentual permitido para o operador conceder desconto no total da venda
	If !empty(self:oEaiObjRec:getPropValue('DiscountTotalPercent'))
		self:nDiscountTotalPercent := LjiOVldTag(self:oEaiObjRec, "DiscountTotalPercent", "N")
	EndIf

	//Valor permitido para o operador conceder desconto no total da venda
	If !empty(self:oEaiObjRec:getPropValue('DiscountTotalValue'))
		self:nDiscountTotalValue := LjiOVldTag(self:oEaiObjRec, "DiscountTotalValue", "N")
	EndIf

	//Percentual permitido para o operador conceder desconto no item da venda
	If !empty(self:oEaiObjRec:getPropValue('DiscountItemPercent'))
		self:nDiscountItemPercent := LjiOVldTag(self:oEaiObjRec, "DiscountItemPercent", "N")
	EndIf

	//Valor permitido para o operador conceder desconto no item da venda
	If !empty(self:oEaiObjRec:getPropValue('DiscountItemValue'))
		self:nDiscountItemValue := LjiOVldTag(self:oEaiObjRec, "DiscountItemValue", "N")
	EndIf

	//Numero do cartao do operador, utilizado para acesso do operador
	If !empty(self:oEaiObjRec:getPropValue('CardNumber'))
		self:cCardNumber := AllTrim( self:oEaiObjRec:getPropValue('CardNumber') )
	EndIf

	//Tem permissao para fazer sangria 1-SIM 2-NÃO 3-Solicita Superior
	If !empty(self:oEaiObjRec:getPropValue('CanWithdrawal'))
		self:nCanWithdrawal := LjiOVldTag(self:oEaiObjRec, "CanWithdrawal", "N")
	EndIf

	//Tem permissao para cancelar um item 1-SIM 2-NÃO 3-Solicita Superior
	If !empty(self:oEaiObjRec:getPropValue('CanCancelItem'))
		self:nCanCancelItem := LjiOVldTag(self:oEaiObjRec, "CanCancelItem", "N")
	EndIf

	//Tem permissao para cancelar a venda 1-SIM 2-NÃO 3-Solicita Superior
	If !empty(self:oEaiObjRec:getPropValue('CanCancelSale'))
		self:nCanCancelSale := LjiOVldTag(self:oEaiObjRec, "CanCancelSale", "N")
	EndIf

	//Tem permissao para alterar pagamentos 1-SIM 2-NÃO 3-Solicita Superior
	If !empty(self:oEaiObjRec:getPropValue('CanEditPayment'))
		self:nCanEditPayment := LjiOVldTag(self:oEaiObjRec, "CanEditPayment", "N")
	EndIf

	//Tem permissao para abrir gaveta 1-SIM 2-NÃO 3-Solicita Superior
	If !empty(self:oEaiObjRec:getPropValue('CanOpenDrawer'))
		self:nCanOpenDrawer := LjiOVldTag(self:oEaiObjRec, "CanOpenDrawer", "N")
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidInformation
Valida as propriedades

@author  Rafael Tenorio da Costa
@since   09/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method ValidInformation() Class CashierOperatorAdapter

	Local cOperador := ""
	Local aAux		:= {}

	//Valida Produto\Marca
	If Empty(self:cProduct)
		self:lOk	:= .F.
		self:cError := I18n(STR0002, {"ProductName"})	//"Tag #1 não informada"
	EndIf

	//Valida Operador\Caixa
	SLF->( DbSetOrder(1) )	  //LF_FILIAL + LF_COD
	Do Case

		//Pelo internalId
		Case !Empty(self:cExternalId)
				
			//Tratamento utilizando a tabela XXF com um De/Para de codigos
			aAux := Separa( CFGA070Int(self:cProduct, "SLF", "LF_COD", self:cExternalId), "|")
		
			If Len(aAux) >= 3

				cOperador := PadR( AllTrim(aAux[3]), TamSx3("LF_COD")[1] )

				If SLF->( DbSeek(xFilial("SLF") + cOperador) )
					self:nOperation	  := MODEL_OPERATION_UPDATE
					self:cCashierCode := cOperador
				Else
					self:lOk 	:= .F.
					self:cError	:= I18n(STR0009, {cOperador})	//"Operador\Caixa #1 não integrado no Protheus, verifique a integração de operador"
				EndIf	
			EndIf
		
		//Pelo código do operador
		Case !Empty(self:cExtCashierCode)
		
			cOperador := PadR(self:cExtCashierCode, TamSx3("LF_COD")[1])

			If SLF->( DbSeek(xFilial("SLF") + cOperador) )
				self:nOperation	  := MODEL_OPERATION_UPDATE
				self:cCashierCode := cOperador
			Else
				self:lOk 	:= .F.
				self:cError	:= I18n(STR0009, {cOperador})	//"Operador\Caixa #1 não integrado ao Protheus, verifique a integração de operador"
			EndIf

		OtherWise

			self:lOk	:= .F.
			self:cError := STR0010	//"Código do operador\caixa não foi informado"
	End Case

	//Valida nome do operador
	If Empty(self:cName)
		self:lOk	:= .F.
		self:cError := I18n(STR0002, {"Name"})	//"Tag #1 não informada"
	EndIf

	FwFreeObj(aAux)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadOperator
Carrega o objeto JsonObjet que sera enviado a função de gravação LjI120Grv.

@param nOpcao - Define a operação que esta sendo executada - 1-Inclusao, 2-Alteracao, 3-Exclusao

@author  Rafael Tenorio da Costa
@since   09/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method LoadOperator(nOpcao) Class CashierOperatorAdapter

	self:oConfigOpe["opcao"]	  := nOpcao					//1-Inclusao, 2-Alteracao, 3-Exclusao
	self:oConfigOpe["opername"]	  := self:cName
	self:oConfigOpe["shortname"]  := self:cShortName
	self:oConfigOpe["olduser"]	  := self:cOldUser			//Utilizado apenas na alteração\exclusão para poscionar na SA6 nome do usuário
	self:oConfigOpe["operador"]	  := IIF(At("C", Self:cExtCashierCode) > 0 .and. nOpcao <> 2 , SubStr(Self:cExtCashierCode,2), Self:cExtCashierCode)
	self:oConfigOpe["permsang"]   := self:nCanWithdrawal
	self:oConfigOpe["permcanit"]  := self:nCanCancelItem
	self:oConfigOpe["permcanvd"]  := self:nCanCancelSale
	self:oConfigOpe["permedipay"] := self:nCanEditPayment
	self:oConfigOpe["permgaveta"] := self:nCanOpenDrawer
	self:oConfigOpe["descper"] 	  := self:nDiscountItemPercent
	self:oConfigOpe["descval"] 	  := self:nDiscountItemValue
	self:oConfigOpe["numcartao"]  := self:cCardNumber
	self:oConfigOpe["totperdesc"] := self:nDiscountTotalPercent 
	self:oConfigOpe["totvaldesc"] := self:nDiscountTotalValue
	self:oConfigOpe["sangria"] 	  := self:aWithdrawalLimit

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CreateQuery
Metodo que monta a query para busca de valores nas tabelas necessarias

@return cAliasQuery - Alias temporario com o retorno da query

@author Rafael Tenorio da Costa
@since  05/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method CreateQuery() Class CashierOperatorAdapter

	Local nX 		   	:= 0
	Local cAliasQuery  	:= GetNextAlias()
	Local cWhere       	:= "1=1"
	Local cOrder	   	:= ""
	Local cFields	   	:= ""
	Local aTemp		   	:= {}
	Local oJsonFilter  	:= Nil
	Local cInternalId  	:= ""
	Local cProperty		:= ""
	Local aAux			:= {}
	Local cCmpBanco  	:= ""

	//Carrega Filtro do InternalId
	Do Case
		Case !Empty( Self:oEaiObjRec:getPathParam("InternalId") )
			cInternalId := Self:oEaiObjRec:getPathParam("InternalId")
		Case !Empty( Self:oEaiObjRec:getPropValue("InternalId") )
			cInternalId := Self:oEaiObjRec:getPropValue("InternalId")
		Case !Empty(self:cCashierCode)
			cInternalId := xFilial("SLF") + "|" + self:cCashierCode
	End Case

	If !Empty(cInternalId)

		aParam := Separa(cInternalId, "|")
		
		If !Empty(aParam)
			cWhere += " AND LF_FILIAL = '" + aParam[1] + "'"	
			cWhere += " AND LF_COD = '"    + aParam[2] + "'"
		EndIf
	Else	
		self:oEaiobjSnd:setBatch(1)
	EndIf
	  
	//Carrega Filtros	  
	oJsonFilter := Self:oEaiObjRec:getFilter()
	If oJsonFilter != Nil

		aTemp := oJsonFilter:getProperties()

		For nX := 1 To Len(aTemp)

			aAux	  := {}
			cProperty := AllTrim( Upper(aTemp[nX]) )

			If HmGet(Self:oFieldsHash, cProperty, @aAux) .And. aAux[nX][2] == aAux[nX][3]

				cWhere += " AND "

				If ValType(oJsonFilter[aTemp[nX]]) == "C"
					oJsonFilter[aTemp[nX]] := "'" + oJsonFilter[aTemp[nX]] + "'"
				Else
					oJsonFilter[aTemp[nX]] := Str( oJsonFilter[aTemp[nX]] )
				EndIf

				cWhere += aAux[nX][2] + " = " + oJsonFilter[aTemp[nX]]
			Else
				self:lOk 	:= .F.
				Self:cError += I18n(STR0011, {cProperty, STR0012}) + CRLF	//"A propriedade #1 não é valida para #2"	//"filtro"
			EndIf
		Next nX
	EndIf

	//Seta Ordem
	aTemp  := Self:oEaiObjRec:getOrder()
	cOrder := ""
	For nX := 1 To Len(aTemp)
			
		aAux := {}

		If SubStr(aTemp[nX],1,1) == "-"

			cProperty := AllTrim( Upper( SubStr(aTemp[nX], 2) )	)

			If !Empty(cProperty)

				If HmGet(Self:oFieldsHash, cProperty, @aAux) .And. !Empty(aAux[1][2])
					cOrder += aAux[1][2] + " desc,"
				Else
					self:lOk 	:= .F.
					Self:cError += I18n(STR0011, {cProperty, STR0013}) + CRLF	//"A propriedade #1 não é valida para #2"	//"ordenação"
				EndIf
			EndIf
		Else

			cProperty := AllTrim( Upper( IIF(SubStr(aTemp[nX], 1, 1) == "+", SubStr(aTemp[nX], 2), aTemp[nX]) )	)

			If !Empty(cProperty)

				If HmGet(Self:oFieldsHash, cProperty, @aAux) .And. !Empty(aAux[1][2])
					cOrder += aAux[1][2] + ","
				Else
					self:lOk 	:= .F.
					Self:cError += I18n(STR0011, {cProperty, STR0013}) + CRLF	//"A propriedade #1 não é valida para #2"	//"ordenação"
				EndIf
			EndIf
		EndIf
	Next nX

	If SubStr(cOrder, Len(cOrder)) == ","
		cOrder := SubStr(cOrder, 1, Len(cOrder) - 1)
	ElseIf Empty(cOrder)
		cOrder := "1"
	EndIf

	If self:lOk

		aAux := {}

		If HmList(Self:oFieldsHash, @aAux)

			For nX := 1 to Len(aAux)
				cCmpBanco  := aAux[nX][2][1][2]

				If !Empty(cCmpBanco) .And. !(cCmpBanco $ cFields)
					cFields += cCmpBanco + ","
				EndIf
			Next nX

			If SubStr(cFields, Len(cFields)) == ","
				cFields := SubStr(cFields, 1, Len(cFields) - 1)
			EndIf	
			
			cWhere  := "%" + cWhere  + "%"
			cOrder  := "%" + cOrder  + "%"
			cFields := "%" + cFields + "%"
			BeginSql alias cAliasQuery			
				SELECT %exp:cFields%
				FROM %table:SLF% SLF //%table:SLF% SLF, %table:SA6% SA6, %table:MGW% MGW
					INNER JOIN %table:SA6% SA6
						ON LF_FILIAL = A6_FILIAL AND LF_COD = A6_COD
					LEFT JOIN %table:MGW% MGW
						ON LF_FILIAL = MGW_FILIAL AND LF_COD = MGW_CAIXA
				WHERE %exp:cWhere%
					AND SLF.%notDel%
					AND SA6.%notDel%
					AND MGW.%notDel%
				ORDER BY %exp:cOrder%
			EndSql

			If (cAliasQuery)->( Eof() )
				self:lOk 	 := .F.
				self:cError  := STR0014 + CRLF + STR0016 //"Operador de caixa não localizado" # "Verifique se as tabelas MGW, SA6 e SLF estão com o mesmo nivel de compartilhamento."
				self:cDetail := STR0015 + CRLF + GetLastQuery()[2]	//"Query executada: "
			EndIf

		EndIf
	EndIf

Return cAliasQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} SetCashierCode()
Seta o código do Operador\Caixa para execução via API de alteração o exclusão.

@param	cOperador - Código do Operador\Caixa

@author  Rafael Tenorio da Costa
@since   11/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetCashierCode(cOperador) Class CashierOperatorAdapter
	Default cOperador := ""
	self:cCashierCode := cOperador
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMsgName
Retorna o nome da mensagem.

@return Caracter - O nome da mensagem única

@author  Rafael Tenorio da Costa
@since   05/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetMsgName() Class CashierOperatorAdapter
Return "CASHIEROPERATOR"

//-------------------------------------------------------------------
/*/{Protheus.doc} GetOk
Retorna o resultado da execução dos metodos.

@return Logico - Resultado da execução dos metodos.

@author  Rafael Tenorio da Costa
@since   05/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetOk() Class CashierOperatorAdapter
Return self:lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} GetError
Mensagem caso tenha ocorrido erro

@return Caractere - Descrição do erro

@author  Rafael Tenorio da Costa
@since   11/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetError() Class CashierOperatorAdapter
Return self:cError

//-------------------------------------------------------------------
/*/{Protheus.doc} GetVersion
Metodo que retorna as versões disponiveis

@return Caracter - Versões disponiveis

@author  Rafael Tenorio da Costa
@since   05/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetVersion() Class CashierOperatorAdapter
Return "2.000"

//-------------------------------------------------------------------
/*/{Protheus.doc} GetEaiObjSnd
Metodo que retorna o oEaiObjSnd já carregado.

@return oEaiObjSnd - Retorna o oEaiObjSnd já carregado

@author  Rafael Tenorio da Costa
@since   05/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetEaiObjSnd() Class CashierOperatorAdapter
Return self:oEaiobjSnd
