#INCLUDE "LOJI704.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"

CLASS ItemReserveAdapter

	DATA lApi               as LOGICAL
	DATA lOk		        as LOGICAL		
	DATA cMsgName           as CHARACTER
	DATA cCode              as CHARACTER
	DATA cError             as CHARACTER	
	DATA oModel		        as OBJECT
	DATA oReserve           as OBJECT	
	DATA oFieldsJson        as OBJECT
	DATA oFieldsItemsJson   as OBJECT
	DATA oEaiobjSnd         as OBJECT
	DATA oEaiobjRec         as OBJECT
	DATA aParam             as ARRAY
	DATA oFields            as array
	
	METHOD NEW()	

	METHOD IncludeReserve()
	METHOD DeleteReserve()
	METHOD GetItemReserve()
    METHOD UpdateReserve()
    
	METHOD GetFieldsNames()
	METHOD GetItemsNames()
	METHOD CreateQuery()
	METHOD GetVersion()	
EndClass

Method NEW() CLASS ItemReserveAdapter
	
	Self:lApi	          := .F.
	Self:lOk	          := .F.		
	Self:cError           := ''  
	Self:cMsgName         := 'ITEMRESERVE'	
	self:oFieldsJson      := self:GetFieldsNames()
	self:oFieldsItemsJson := self:GetItemsNames()
	self:oFields          := Nil
	self:oEaiobjSnd       := FWEAIObj():NEW()
	self:oEaiObjRec       := Nil

return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetItemReserve
Método que ira buscar e retornar as Reservas de acordo com os parametros informados na url da api, ou
buscará todas.
obs.: retornará as reservas do grupo de empresa que estiver cadastrado no appserver.ini

@param Nil

@return Um ou várias reservas no formato json

@author Ricardo Melo Sousa
@since 05/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetItemReserve() CLASS ItemReserveAdapter
Local lNext     	as LOGICAL
Local nCount     	as NUMERIC
Local cError       	as CHARACTER
Local cAliasRes 	as CHARACTER
Local aArea      	as ARRAY
Local aAreaSC0   	as ARRAY
Local oPage      	as OBJECT
local cItem         as CHARACTER
local nK            as NUMERIC
Local oItem         := Nil	
Local lRel          as LOGICAL
Local nPos          as NUMERIC
local aFields       as ARRAY
local aFieldsItems  as ARRAY

private cFields	:= ""

Default lRel := .F.

aParam   := Nil
aAreaSC0 := SC0 ->(getArea())
aArea    := getArea()
nCount   := 0
cError   := ''

if Self:lApi	
	if !empty(Self:oEaiObjRec:GetPage())
		oPage:=FwPageCtrl():New(Self:oEaiObjRec:GetPageSize(),Self:oEaiObjRec:GetPage())
	EndIf
	
	If !empty(Self:oEaiObjRec:getPathParam('Internal_ID'))
	    cInternalId := Self:oEaiObjRec:getPathParam('Internal_ID')	
	    aParam := Separa(cInternalId, "|")		  
	ElseIf !empty(Self:oEaiObjRec:getPropValue('InternalId'))
		cInternalId := Self:oEaiObjRec:getPropValue('InternalId')
		aParam := Separa(cInternalId, "|")			 		
	EndIf	
		
	cAliasRes := 'SC0'
	
	Self:oEaiobjSnd:Activate()		
	lNext := .T.
	If !empty(aParam)
		cAliasRes := Self:CreateQuery(aParam)
	Else
		cAliasRes := Self:CreateQuery(aParam)
		Self:oEaiobjSnd:setBatch(1)
	EndIf
				
	if Self:lOk		
		aFields := Self:oFieldsJson:getProperties()
		aFieldsItems := Self:oFieldsItemsJson:getProperties()	
	
		While !(cAliasRes)->(EOF())
			nCount++
			nK := 1
			if !oPage:CanAddLine()
				(cAliasRes)->(dbskip())
				loop
			endif 
			cItem :=  AllTrim((cAliasRes)->C0_FILIAL) + AllTrim((cAliasRes)->C0_DOCRES)
			For nPos:= 1 to Len(aFields)
				If !Empty(Self:oFields) .AND. Upper(aFields[nPos]) $ Upper(Self:oFields)
					Self:oEaiobjSnd:setProp(aFields[nPos],AllTrim((cAliasRes)->&(Self:oFieldsJson[aFields[nPos]])))
				ElseIf Empty(Self:oFields)
				    Self:oEaiobjSnd:setProp("CompanyId", cEmpAnt)
					Self:oEaiobjSnd:setProp(aFields[nPos],AllTrim((cAliasRes)->&(Self:oFieldsJson[aFields[nPos]])))
				EndIf
			Next
			IF !empty((cAliasRes)->C0_FILIAL) .AND. !empty((cAliasRes)->C0_DOCRES)
				Self:oEaiobjSnd:setProp("InternalId", AllTrim((cAliasRes)->C0_FILIAL) + "|"+ AllTrim((cAliasRes)->C0_DOCRES))
			ENDIF						
			while cItem == AllTrim((cAliasRes)->C0_FILIAL) + AllTrim((cAliasRes)->C0_DOCRES)
			  oItem :=	Self:oEaiobjSnd:SetProp("ReserveItemType",{})
				For nPos:= 1 to Len(aFieldsItems)
					If !Empty(Self:oFields) .AND. Upper(aFieldsItems[nPos]) $ Upper(Self:oFields)
						if VALTYPE((cAliasRes)->&(Self:oFieldsItemsJson[aFieldsItems[nPos]])) == "N"
							oItem[nK]:setProp(aFieldsItems[nPos],(cAliasRes)->&(Self:oFieldsItemsJson[aFieldsItems[nPos]]))
					    else
					    	oItem[nK]:setProp(aFieldsItems[nPos],AllTrim((cAliasRes)->&(Self:oFieldsItemsJson[aFieldsItems[nPos]])))
					    endif
					ElseIf Empty(Self:oFields)
						if VALTYPE((cAliasRes)->&(Self:oFieldsItemsJson[aFieldsItems[nPos]])) == "N"
							oItem[nK]:setProp(aFieldsItems[nPos],(cAliasRes)->&(Self:oFieldsItemsJson[aFieldsItems[nPos]]))
					    else
					    	oItem[nK]:setProp(aFieldsItems[nPos],AllTrim((cAliasRes)->&(Self:oFieldsItemsJson[aFieldsItems[nPos]])))
					    endif
						 //oItem[nK]:setProp(aFieldsItems[nPos],AllTrim((cAliasRes)->&(Self:oFieldsItemsJson[aFieldsItems[nPos]])))
					EndIf
				Next				
				(cAliasRes)->(dbskip())
				 nK++
			EndDo

            	if lNext
            		cItem := ''
            		Self:oEaiobjSnd:nextItem()
        		Else
        			exit
    			EndIf					
		EndDo 		
	
		if nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
			Self:oEaiobjSnd:setHasNext(.T.)
		EndIf
				
		(cAliasRes)->(DBCloseArea())
	Endif	
EndIf

If 	nCount == 0
	Self:lOk    := .F.	
	Self:cError := "Reserva não encontrada."
	Self:cCode  := "404"
EndIf

RestArea(aArea)
RestArea(aAreaSC0)

return lRel

//-------------------------------------------------------------------
/*/{Protheus.doc} IncludeReserve
Método que ira fazer a inclusão de uma Reserva
@param Vazio
@return lRet se a inclusão foi realizada com sucesso
@author Ricardo Melo Sousa 
@since 05/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method IncludeReserve() CLASS ItemReserveAdapter

    Local lRet as LOGICAL
    Local aRet := {.T., ""}

    if !Empty(Self:oEaiObjRec:getPropValue('InternalId'))
        oReserve:GetItemReserve()
        If !oReserve:lOk
            Self:oEaiobjSnd:Activate()
            lApi := .T.
            aRet := v1000(Self:oEaiObjRec, TRANS_RECEIVE, EAI_MESSAGE_BUSINESS, .T.)
            IF ! aRet[1]	    		
                oReserve:cError := aRet[2]:cError
                oReserve:lOk    := .F.
            else
                oReserve:lOk := .T.
                lRet := .T.	
            Endif     
        else
            oReserve:cError := 'Já existe uma reserva com o código ' + Self:oEaiObjRec:getPropValue("InternalId") + ' no Protheus'
            oReserve:lOk    := .F.
        endif
    else
        oReserve:cError := "Preencha o valor da tag InternalId"
        oReserve:lOk    := .F.	
        Self:cCode      := "400"
    endif          

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdateReserve
Método que ira fazer a inclusão de uma Reserva

@param Vazio

@return lRet se a inclusão foi realizada com sucesso e 

@author Ricardo Melo Sousa 
@since 05/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method UpdateReserve() CLASS ItemReserveAdapter

    Local lRet as LOGICAL
    Local aRet := {.T., ""}

    if ! Empty(Self:oEaiObjRec:getPathParam('Internal_ID'))
        
        oReserve:GetItemReserve()
        If  oReserve:lOk
            Self:oEaiobjSnd:Activate()
            lApi	:= .T.
            aRet := v1000(Self:oEaiObjRec,TRANS_RECEIVE,EAI_MESSAGE_BUSINESS, .T.)  
            IF ! aRet[1]	    		
                oReserve:cError :=  aRet[2]:cError
                oReserve:lOk := .F.
            else
                oReserve:lOk := .T.	
            Endif     
        else
            oReserve:cError :=  'Não existe uma reserva com o código ' + Self:oEaiObjRec:getPathParam('Internal_ID') + ' no Protheus'
            oReserve:lOk := .F.
            Self:cCode := "400"
        endif
    else
        oReserve:cError :=  "Preencha o valor da tag InternalId"
        Self:cCode := "400"
        oReserve:lOk := .F.
    endif
          
return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DeleteReserve
Método que ira fazer a inclusão de uma Reserva

@param Vazio

@return lRet se a inclusão foi realizada com sucesso

@author Ricardo Melo Sousa 
@since 05/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method DeleteReserve() CLASS ItemReserveAdapter

    Local lRet as LOGICAL
    Local aRet := {.T., ""} 
    
    if ! Empty(Self:oEaiObjRec:getPathParam('Internal_ID'))
        Self:oEaiobjSnd:Activate()
        oReserve:GetItemReserve()
        If  oReserve:lOk
            self:oModel := oReserve:oEaiobjSnd
            lApi	:= .T.
            aRet := v1000(self:oModel, TRANS_RECEIVE, EAI_MESSAGE_BUSINESS, .T.)  
            IF ! aRet[1]	    		
                oReserve:cError :=  aRet[2]:cError
                oReserve:lOk := .F.
            else
                oReserve:lOk := .T.	
            Endif     
        else
            oReserve:cError :=  'Não existe uma reserva com o código ' + Self:oEaiObjRec:getPathParam('Internal_ID') + ' no Protheus'
            oReserve:lOk := .F.
            Self:cCode := "400"
        endif
    else
        oReserve:cError :=  "Preencha o valor da tag InternalId"
        Self:cCode := "400"
        oReserve:lOk := .F.
    endif

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CreateQuery
Metodo que monta a query para busca de valores na tabela SC0

@param Vazio

@return Vazio

@author Ricardo Melo Sousa
@since 05/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method CreateQuery(aParam) CLASS ItemReserveAdapter

    Local lRet 		   as LOGICAL
    Local nX 		   as NUMERIC
    Local cWhere       as CHARACTER
    Local cOrder	   as CHARACTER
    Local aTemp		   as ARRAY
    Local aTempItems   as ARRAY
    Local oJsonFilter  as OBJECT
    Local cParam       as CHARACTER

    cFields := ""
	lRet := .T.
	cAliasRes := "ItemReserveTmp"
	cWhere := "1=1"
	cParam := ''
	
	oJsonFilter  := Self:oEaiObjRec:getFilter()	
	If !empty(aParam)		 
		cWhere += " AND C0_FILIAL= '" + aParam[1] + "' "	
		cWhere += " AND C0_DOCRES=" + aParam[2]
	EndIf
	  
	if oJsonFilter != Nil
		aTemp := oJsonFilter:getProperties()
		for nX := 1 to len(aTemp)
			if !Empty(Self:oFieldsJson[aTemp[nX]]) .OR. !Empty(Self:oFieldsItemsJson[aTemp[nX]])
				cWhere += ' AND '
				if ValType(oJsonFilter[aTemp[nX]]) != "C"
					oJsonFilter[aTemp[nX]] := str(oJsonFilter[aTemp[nX]])
				EndIf
				if valtype(oJsonFilter[aTemp[nX]]) == "C"
					if !Empty(Self:oFieldsJson[aTemp[nX]])
						cWhere += Self:oFieldsJson[aTemp[nX]] + '=' + "'" + oJsonFilter[aTemp[nX]] + "'"
				    else
				    	cWhere += Self:oFieldsItemsJson[aTemp[nX]] + '=' + "'" + oJsonFilter[aTemp[nX]] + "'"
				    endif
				else
					if !empty(Self:oFieldsJson[aTemp[nX]])
						cWhere += Self:oFieldsJson[aTemp[nX]] + '=' + val(oJsonFilter[aTemp[nX]])
					else
						cWhere += Self:oFieldsItemsJson[aTemp[nX]] + '=' + val(oJsonFilter[aTemp[nX]])
					endif
				endif
			Else
				Self:cError += 'A propriedade ' + aTemp[nX] + ' não é valida para filtro' + CRLF
				lRet := .F.
			EndIf
		next nX
	Endif

	aTemp := Self:oEaiObjRec:getOrder()
	cOrder := ''
	for nX := 1 to len(aTemp)
		if nX != 1
			cOrder += ','
		Endif

		if substr(aTemp[nX],1,1) == '-'
			if !empty(Self:oFieldsJson[upper(substr(aTemp[nX],2))])
				cOrder += Self:oFieldsJson[upper(substr(aTemp[nX],2))] + ' desc'
			ElseIf	!empty(Self:oFieldsItemsJson[upper(substr(aTemp[nX],2))])
				cOrder += Self:oFieldsItemsJson[upper(substr(aTemp[nX],2))] + ' desc'
			Else
				Self:cError += 'A propriedade ' + aTemp[nX] + ' não é valida para Ordenação' + CRLF
				lRet := .F.
			EndIf
		Else
			if !Empty(Self:oFieldsJson[upper(aTemp[nX])])
				cOrder += Self:oFieldsJson[upper(aTemp[nX])]
			ElseIf	!empty(Self:oFieldsItemsJson[upper(substr(aTemp[nX],2))])
				cOrder += Self:oFieldsItemsJson[upper(aTemp[nX])]
			Else
				Self:cError += 'A propriedade ' + aTemp[nX] + ' não é valida para Ordenação' + CRLF
				lRet := .F.
			EndIf
		EndIf
	next nX

	IF Empty(cOrder)
		cOrder := '1'
	EndIf

	if lRet
		Self:lOk := .T.		
		cFields := '1'
		
			aTemp := Self:oFieldsJson:getProperties()
			for nX := 1 to len(aTemp)
				cFields += ','
				cFields += Self:oFieldsJson[aTemp[nX]]
			next nX		
			aTempItems := Self:oFieldsItemsJson:getProperties()
			for nX := 1 to len(aTempItems)
				cFields += ','
				cFields += Self:oFieldsItemsJson[aTempItems[nX]]
			next nX
		
		cWhere  := '%'+cWhere+'%'
		cOrder  := '%'+cOrder+'%'
		cFields := '%'+cFields+'%'		
		BeginSql alias cAliasRes			
			SELECT %exp:cFields%
			FROM
				%table:SC0%
			WHERE %exp:cWhere%		
			AND D_E_L_E_T_ =' '	
			ORDER BY %exp:cOrder%
		EndSql
	EndIf

Return cAliasRes

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFieldsNames
Método que retorna a estrutura do cabeçalho da reserva em objeto json

@param Vazio

@return objeto json

@author Ricardo Melo Sousa
@since 05/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetFieldsNames() CLASS ItemReserveAdapter
    
    Local oFieldsJson as OBJECT

	oFieldsJson := &('JsonObject():New()')
	
	oFieldsJson['BranchId'] 		  	:= 'C0_FILIAL'	
	oFieldsJson['ReserveNumber'] 		:= 'C0_NUM'
	oFieldsJson['ReserveType']			:= 'C0_TIPO'
	oFieldsJson['DocumentReserve']  	:= 'C0_DOCRES'
	oFieldsJson['Requester'] 			:= 'C0_SOLICIT'
	oFieldsJson['RequestBranch']     	:= 'C0_FILRES'	

return oFieldsJson

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFieldsNames
Método que retorna os itens da reserva em objeto json

@param Vazio

@return objeto json

@author Ricardo Melo Sousa
@since 05/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetItemsNames() CLASS ItemReserveAdapter
    
    Local oFieldsItemsJson as OBJECT

	oFieldsItemsJson := &('JsonObject():New()')	

	oFieldsItemsJson['ItemCode'] 			:= 'C0_PRODUTO'
	oFieldsItemsJson['WarehouseCode']		:= 'C0_LOCAL'
	oFieldsItemsJson['Quantity'] 			:= 'C0_QTDORIG'
	oFieldsItemsJson['ReserveExpiration']   := 'C0_VALIDA'
	oFieldsItemsJson['IssueDateReserve']	:= 'C0_EMISSAO'
	oFieldsItemsJson['LotNumber'] 			:= 'C0_LOTECTL'
	oFieldsItemsJson['SubLotNumber']		:= 'C0_NUMLOTE'
	oFieldsItemsJson['SeriesItem'] 			:= 'C0_NUMSERI'
	oFieldsItemsJson['AddressingItem']		:= 'C0_LOCALIZ'
	oFieldsItemsJson['NoteReserveItem'] 	:= 'C0_OBS'
	oFieldsItemsJson['ReserveBranch'] 		:= 'C0_FILIAL'   

return oFieldsItemsJson

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJI704O
Funcao de integracao com o adapter EAI para recebimento e
envio de informações de Reserva de Protdutos (ItemReserve)
utilizando o conceito de mensagem unica com Objeto EAI. 
@type function
@param Caracter, cMsgRet, Variavel com conteudo xml para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)
@param Caracter, lApi, controle de API

@author rafael.pessoa
@version P12
@since 19/09/2018
@return Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
		aRet[1] - (boolean) Indica o resultado da execução da função
		aRet[2] - (caracter) Mensagem Xml para envio
/*/
//-------------------------------------------------------------------
Function LOJI704O( oEAIObEt, nTypeTrans, cTypeMessage, lApi)
	
    Local lRet 		:= .T.				//Indica o resultado da execução da função
	Local cRet		:= ''				//Xml que será enviado pela função
	Local aRet		:= {.T.,""} 		//Array de retorno da execucao da versao
   
	Default oEAIObEt	 	:= Nil    
	Default nTypeTrans		:= 3
	Default cTypeMessage	:= ""
	Default lApi := .F.
	
	LjGrvLog("LOJI704O","ID_INICIO - InternalId: " + IIF(oEAIObEt:getPropValue("InternalId") != Nil,oEAIObEt:getPropValue("InternalId"),""))
	LjGrvLog("LOJI704O","Objeto oEAIObEt",oEAIObEt)
    
	If ( nTypeTrans == TRANS_RECEIVE )

		If ( cTypeMessage == EAI_MESSAGE_BUSINESS ) .Or. ( cTypeMessage == EAI_MESSAGE_RESPONSE )

			If !Empty(oEAIObEt:getHeaderValue("Version"))

				cVersao := StrTokArr(oEAIObEt:getHeaderValue("Version"), ".")[1]
				  
				If cVersao == "1"
					LjGrvLog("LOJI704O","Antes de entrar na funcao v1000 - InternalId: " + IIF(oEAIObEt:getPropValue("InternalId") != Nil,oEAIObEt:getPropValue("InternalId"),""))
					aRet := v1000(oEAIObEt, nTypeTrans, cTypeMessage, lApi )
					LjGrvLog("LOJI704O","Depois de sair da funcao v1000 - InternalId: " + IIF(oEAIObEt:getPropValue("InternalId") != Nil,oEAIObEt:getPropValue("InternalId"),""))
				Else
					lRet    := .F.					
					cRet := STR0003 //#"A versao da mensagem informada nao foi implementada!"
					aRet := { lRet , cRet }
				EndIf
			Else
				lRet := .F.
				cRet := STR0002 //#"Versao da mensagem nao informada!"
				aRet := { lRet , cRet }
			EndIf			
	 
		ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )		
			cRet := "1.000|1.001|1.002"
			aRet := { lRet , cRet }
			return {aRet[1], aRet[2],"ITEMRESERVE","JSON"}
		EndIf								
                                    	
	ElseIf ( nTypeTrans == TRANS_SEND )

		cVersao := StrTokArr(RTrim(PmsMsgUVer('ITEMRESERVE','LOJA704')), ".")[1]

		//Faz chamada da versão especifica   
		If cVersao == "1"
			aRet := v1000(oEAIObEt, nTypeTrans, cTypeMessage, lApi)
		Else
			cRet := STR0003 //#"A versao da mensagem informada nao foi implementada!"
			aRet := { lRet , cRet }
		EndIf
	EndIf

	LjGrvLog("LOJI704O","ID_FIM - InternalId: " + IIF(oEAIObEt:getPropValue("InternalId") != Nil,oEAIObEt:getPropValue("InternalId"),""))
	
Return {aRet[1], aRet[2],"ITEMRESERVE"}

//-------------------------------------------------------------------
/*/{Protheus.doc} v1000
 Funcao de integracao com o adapter EAI para recebimento e envio de informações de Reserva de Produtos(SC0)
utilizando o conceito de mensagem unica. para Versão 1.000
@type function
@param Caracter, cMsgRet, Variavel com conteudo xml para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)

@author rafael.pessoa
@version P12
@since 19/09/2018
@return Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
		aRet[1] - (boolean) Indica o resultado da execução da função
		aRet[2] - (caracter) Mensagem Xml para envio
/*/
//-------------------------------------------------------------------
Static Function v1000( oEAIObEt, nTypeTrans, cTypeMessage, lApi )

	Local dReserve      := CTOD("  /  /  ")
	Local dReservevld   := CTOD("  /  /  ")
	Local cMsgRet		:= ""
	Local cEvent		:= ""
	Local cMarca		:= ""
	Local cRequester    := ""
	Local cFilResp		:= ""
	Local cInternalId	:= ""
	Local cProd			:= ""
	Local cLocal 		:= ""
	Local cLote			:= ""
	Local cSubLote		:= ""
	Local cSerie		:= ""
	Local cLocaliz		:= ""
	Local cObs			:= ""
	Local cFilRes		:= ""
	Local aFilRes		:= {}
    Local cFilResOld    := ""
	Local cResult		:= ""
	Local cCompany		:= ""
	Local aCab			:= {}
	Local aItens		:= {}
	Local aItem			:= {}
	Local aItFil 		:= {}                       //Array com os Itens que serão processados pelo ExecAuto.
	Local aResult 		:= {}
	Local aProd			:= {}
	Local nCount		:= 0
	Local nSC0Qtd		:= 0
	Local lRet			:= .T.
	Local ofwEAIObj     := FWEAIobj():NEW()	        //Objeto EAI
	Local aEAIEmpFil    := {}
	Local oItReserv		:= Nil
	Local nTamCodLoc	:= TamSX3("NNR_CODIGO")[1]
	Local cDestination  := ""
	Local aProdRet		:= {}                       //Array retono dos itens da reserva
	Local cJson 		:= ""
    Local cOrigem       := ""                       //Origem da Reserva

	Local lLjI704O1		:= ExistBlock("LJI704O1") //Verifica se existe o PE LJI704O1 que faz a manipulação no objeto de produtos

	Private nOpcx		:= 1                        //1=Inclusão - 2=Alteração - 3=Exclusão
	Private lMsErroAuto := .F.
	Private aSaveSC0	:= SC0->(GetArea())
	Private aSave		:= GetArea()
	Private cTipo		:= ""
	Private cDocRes		:= ""
	
	Default oEAIObEt	 := Nil 
	Default nTypeTrans 	 := 0 
	Default cTypeMessage := "" 
	Default lApi := .F.
	
	If nTypeTrans == TRANS_RECEIVE .And. ValType( oEAIObEt ) == 'O' 
	
		If cTypeMessage == EAI_MESSAGE_BUSINESS

			If lRet .And. !lApi
				   
				If oEAIObEt:getHeaderValue("ProductName") != Nil
					cMarca := oEAIObEt:getHeaderValue("ProductName")

                    If oEAIObEt:getPropValue("Event") != Nil
                        cEvent := AllTrim( Upper( oEAIObEt:getPropValue("Event") ) )
                    EndIf
				Else
					lRet    := .F.
					cMsgRet += Chr(10) + STR0010//"Marca nao integrada ao Protheus, verificar a marca da integracao"
				EndIf
			Endif
			 
			If ( oEAIObEt:getPropValue("InternalId") ) != Nil 
				cInternalId := ( oEAIObEt:getPropValue("InternalId") )
			EndIf
			
			If ( oEAIObEt:getPropValue("CompanyId") )  != Nil 
				cCompany := ( oEAIObEt:getPropValue("CompanyId") )
			EndIf
				
			SC0->( dbSetOrder( 1 ) )
			
			LjGrvLog("LOJI704O","MONTAGEM CABEÇALHO")
			
			IF lRet		
			
				If oEAIObEt:getPropValue("ReserveType") != Nil

					cTipo := PADR( oEAIObEt:getPropValue("ReserveType"), TamSX3("C0_TIPO")[1])
					
					If cTipo $ ("VD|CL|PD|LB|NF|LJ")
						Aadd( aCab, { "C0_TIPO",   cTipo,  Nil })
					Else
						lRet    := .F.
						cMsgRet += Chr(10) +  STR0012//"Tipo de Reserva não esta na Lista das Possíveis: VD-Vendedor| CL-Cliente| PD-Pedido| LB-Liberação |NF-Nota Fiscal| LJ-Loja"
					Endif
				Else
					lRet    := .F.
					cMsgRet += Chr(10) +  STR0011//"Tipo de Reserva não informado."				
				EndIf
			Endif
			
			If lRet
				If oEAIObEt:getPropValue("DocumentReserve") != Nil				
					If Len(oEAIObEt:getPropValue("DocumentReserve")) > TamSX3("C0_DOCRES")[1]
						lRet    := .F.
						cMsgRet += Chr(10) + STR0039 //"A informação contida na TAG DocumentReserve esta maior que o tamanho do campo C0_DOCRES da tabela SC0."
					ElseIf Empty(oEAIObEt:getPropValue("DocumentReserve"))
						lRet    := .F.
						cMsgRet += Chr(10) + STR0040 //"A informação da TAG DocumentReserve esta vazia, essa informação é necessaria para a geração da reserva."					
					Else
						cDocRes := PADR( oEAIObEt:getPropValue("DocumentReserve"), TamSX3("C0_DOCRES")[1])
						Aadd( aCab, { "C0_DOCRES", cDocRes , Nil })
					EndIf
				Else
					lRet    := .F.
					cMsgRet += Chr(10) +  STR0013//"Documento responsável pela reserva não informado."
				EndIf
			Endif
			
			If lRet
				If oEAIObEt:getPropValue("Requester") != Nil	
					cRequester := Padr( oEAIObEt:getPropValue("Requester") ,TamSx3("C0_SOLICIT")[1])
					Aadd( aCab, { "C0_SOLICIT", cRequester , Nil })
				Else
					lRet    := .F.
					cMsgRet += Chr(10) +  STR0014//"Nome do Solicitante da Reserva não informado."
				EndIf
			Endif
			
			If lRet
				If oEAIObEt:getPropValue("RequestBranch") != Nil
					If !lApi			
						aEAIEmpFil := FWEAIEMPFIL( cCompany, oEAIObEt:getPropValue("RequestBranch") , cMarca )					
						If Len(aEAIEmpFil) >= 2
							cFilResp:= aEAIEmpFil[2] 
						EndIf
					Else
						cFilResp := oEAIObEt:getPropValue("RequestBranch")		
					EndIf
					
					If !Empty(cFilResp) 
						Aadd( aCab, { "C0_FILRES", cFilResp , Nil })
					Else
						lRet    := .F.
						cMsgRet += Chr(10) +  STR0015 //"Filial Responsavel pela Reserva não existe no De/Para - Protheus."
					Endif
				Else
					lRet    := .F.
					cMsgRet += Chr(10) +  STR0015//"Filial responsável pela Reserva não informada."					
				EndIf
			Endif

            //Origem da Reserva
			If lRet .And. oEAIObEt:getPropValue("ReserveSource") <> Nil
            
                cOrigem := AllTrim( oEAIObEt:getPropValue("ReserveSource") )

                Do Case
                    Case !Empty(cOrigem) .And. SC0->( ColumnPos("C0_ORIGEM") ) == 0
                    	lRet    := .F.
						cMsgRet := I18n(STR0041, {"Tag ReserveSource", "C0_ORIGEM"} )           //"#1 enviada, porém não existe o campo #2 na base de dados, verifique!"

                    Case Len(cOrigem) > TamSx3("C0_ORIGEM")[1]
                    	lRet    := .F.
						cMsgRet := I18n(STR0042, {"tag ReserveSource", cOrigem, "C0_ORIGEM"} )  //"Conteúdo da #1 (#2) maior que o permitido pelo campo #3, verifique!"

                    OTherWise
					    Aadd(aCab, {"C0_ORIGEM", cOrigem, Nil})
                End Case
			Endif

			If lRet

				If lApi

					Do Case
                        //Inclusão
                        Case AllTrim(Upper(oEAIObEt:getRestMethod())) == "POST"
                            nOpcx   := 1

                        //Alteração
                        Case AllTrim(Upper(oEAIObEt:getRestMethod())) == "PUT"	
                            nOpcx   := 2

                        //Exclusão
                        Case AllTrim(Upper(oEAIObEt:getRestMethod())) == "DELETE"	
                            nOpcx   := 3

                        OTherWise
                            lRet    := .F.
                            cMsgRet += Chr(10) +  STR0023   //#"Evento Informado incorreto, apenas as Opções de POST, DELETE e PUT estão disponíveis."
					End Case

			    ElseIf !Empty(cEvent)

                    cResult := CFGA070Int(cMarca, "SC0", "C0_DOCRES", cInternalId)

                    LjGrvLog(cResult, "ItemReserve - De\Para e Evento", cEvent)
                
                    If cEvent == "DELETE"

                        If Empty(cResult)
                            lRet    := .F.
                            cMsgRet += Chr(10) +  STR0021 //#"Evento incorreto, para exclusao é necessário informar o ID de uma reserva já processada pelo Protheus."
                        Else
                            nOpcx   := 3
                            aResult := Separa(cResult, "|")													
                            If !ValType(aResult) == "A" .And. Len(aResult) > 0
                                lRet    := .F.
                                cMsgRet += Chr(10) +  STR0022 //#"ID da Reservão não localizado na tabela De/Para"
                            Endif
                        Endif

                    Elseif cEvent == "UPSERT"

                        aResult := Separa(cResult, "|")

                        //Update
                        If ValType(aResult) == "A" .And. Len(aResult) > 0 
                            nOpcx := 2
                        
                        //Inclusão
                        Else	
                            nOpcx := 1
                        Endif
                    Else

                        lRet    := .F.
                        cMsgRet += Chr(10) +  STR0023 //#"Evento Informado incorreto, apenas as Opções de Upsert ou Delete estão disponíveis."
                    EndIf

                    LjGrvLog(cResult, "ItemReserve - Operação a ser executada", nOpcx)
				Else

					lRet    := .F.
					cMsgRet += Chr(10) +  STR0024 //#"Evento nao informado!"
				EndIf
			EndIf

			//----------
			//Itens	
            //----------
			If lRet		
				If oEAIObEt:getPropValue("ReserveItemType") != Nil	
					If lApi 
							oItReserv := oEAIObEt:getPropValue("ReserveItemType")
					ElseIf  oEAIObEt:getPropValue("ReserveItemType"):getPropValue("Item") <> NIL 
							oItReserv := oEAIObEt:getPropValue("ReserveItemType"):getPropValue("Item")
					EndIf
		
					//Ponto de entrada para manipular os itens
					If lLjI704O1
						LjGrvLog("LOJI704O","Antes de executar o PE LJI704O1",oItReserv)
						oItReserv := ExecBlock( "LJI704O1", .F., .F., {oItReserv} )
						LjGrvLog("LOJI704O","Depois que executou o PE LJI704O1",oItReserv)
						If ValType(oItReserv) <> "A"
							lRet 	:= .F.
							cMsgRet := STR0043 //"Erro no retorno do ponto de entrada LJI704O1, o retorno não foi do tipo array."
                            LjGrvLog("LOJI704O", cMsgRet)
						EndIf
					EndIf

					If ValType(oItReserv) <> "A" .Or. Len(oItReserv) < 1
						lRet    := .F.
						cMsgRet += Chr(10) +  STR0016//"Não foram informados Itens para Reserva."
					Endif			
					
					If lRet
						For nCount:= 1 To Len(oItReserv)
						
							LjGrvLog("LOJI704O","MONTAGEM ITENS","")
							
							If oItReserv[nCount]:getPropValue("ItemInternalId") != Nil							
		                      If !lApi		
		                      	   aProd := IntProInt(oItReserv[nCount]:getPropValue("ItemInternalId"), cMarca)
		                      		If Len(aProd) > 0 .And. aProd[1]
		                      			If Len(aProd[2]) > 1
		                      				cProd := Padr(aProd[2][3], TamSx3("C0_PRODUTO")[1])
		                      			Else
		                      				lRet    := .F.	                      				
										Endif  	
                                    Else
                                        lRet     := .F.                                         
									EndIf

                                    If !lRet
                                        cMsgRet += Chr(10) +  STR0025 + Alltrim(oItReserv[nCount]:getPropValue("ItemInternalId")) +STR0026+; //"Produto: " " não configurado"
										           STR0027 //"corretamento no cadastro De / Para. - XXF_INTVAL - Empresa | Filial | Codigo produto"
                                    EndIf
							  Else
							  		cProd := Padr(oItReserv[nCount]:getPropValue("ItemCode"), TamSx3("C0_PRODUTO")[1])
							  Endif	
							  
							ElseIf oItReserv[nCount]:getPropValue("ItemCode") != Nil  
								cProd := Padr(oItReserv[nCount]:getPropValue("ItemCode"), TamSx3("C0_PRODUTO")[1])
								DbSelectArea("SB1")
								SB1->(dBSetOrder(1))
								If !SB1->(dBSeek(XfILIAL("SB1")+cProd))
									cProd := ""
								Endif							
							EndIf
							
							If lRet .And. !Empty(cProd)
								Aadd(aItem, {"C0_PRODUTO", cProd, Nil }) 
							Else
								lRet    := .F.
								cMsgRet += Chr(10) +  STR0017//"O produto não informado, ou código não foi integrado."
								Exit
							Endif
							
							If lRet					
								If oItReserv[nCount]:getPropValue("WarehouseInternalId") != Nil 

									cResult := CFGA070Int(cMarca, "NNR", "NNR_CODIGO", oItReserv[nCount]:getPropValue("WarehouseInternalId"))

									LjGrvLog("LOJI704O", "Retorno da função CFGA070Int (DE/PARA) NNR_CODIGO", cResult)
									aResult := Separa(cResult, "|")													
									If ValType(aResult) == "A" .And. Len(aResult) > 2 
										cLocal := PadR(aResult[3], nTamCodLoc )
										LjGrvLog("LOJI704O", "Local de estoque encontrado: " + cLocal)
									Endif

								ElseIf oItReserv[nCount]:getPropValue("WarehouseCode") != Nil 
									cLocal := Padr(oItReserv[nCount]:getPropValue("WarehouseCode") , nTamCodLoc )
								EndIf

								If !Empty(cLocal)   
									Aadd(aItem, {"C0_LOCAL", cLocal, Nil } )
								Else
								
									//Verifica o Armazem Padrão do Produto, levando em consideração
									//a configuração do Indicador de Produtos (SBZ) - parametro MV_ARQPROD.
									cLocal	:=	RetFldProd(SB1->B1_COD,"B1_LOCPAD")
													
									Aadd(aItem, {"C0_LOCAL", AllTrim(cLocal), Nil } )
								Endif

							Endif
							
							If lRet
								If oItReserv[nCount]:getPropValue("Quantity") != Nil  

									If ValType(oItReserv[nCount]:getPropValue("Quantity")) == "N" //.OR. ValType(oItReserv[nCount]:getPropValue("Quantity")) == "C" //"N"
										nSC0Qtd := oItReserv[nCount]:getPropValue("Quantity") 
									Else										    
										lRet    := .F.
 										cMsgRet += Chr(10) +  STR0035 + "| Tag: Quantity | Tipo: Numerico " //"O conteúdo informado para tag está incorreto. " 
										Exit
									EndIf	
									
									If nSC0Qtd > 0 
										Aadd(aItem, {"C0_QUANT", nSC0Qtd   ,  Nil })
									Else
										lRet    := .F.
										cMsgRet += Chr(10) +  STR0019//"Quantidade informada para Reserva precisa ser maior que Zero."
										Exit
									Endif
								Else
									lRet    := .F.
									cMsgRet += Chr(10) +  STR0020//"A TAG Quantity não foi informada e ela é obrigatória.
									Exit
								EndIf
								
                                If NNR->(DbSeek(xFilial("NNR")+cLocal))//Verifica se existe Armazem na NNR antes de criar Saldo na B2
	                                //Verifica se Existe Saldo Inicial do Produto, caso não tenha insere saldo zerado
	                                DbSelectArea("SB2")
	                                SB2->(DbSetOrder(1))
	                                If !(SB2->(DbSeek(xFilial("SB2")+cProd+cLocal)))                                    
	                                    CriaSB2(cProd, cLocal)                                  
	                                Endif	
	                            Else
	                            	lRet    := .F.
									cMsgRet += Chr(10) + STR0037    //" O conteúdo da TAG WarehouseCode inválido, informar codigo de Armazém (WarehouseCode) válido no Protheus Tabela NNR " 
									Exit
	                            EndIf    	

							Endif
							
							If oItReserv[nCount]:getPropValue("ReserveExpiration") != Nil 
								If !lApi
                                    dReservevld := CTOD(SubStr(oItReserv[nCount]:getPropValue("ReserveExpiration"), 9, 2 ) + '/'+;
                                                        SubStr(oItReserv[nCount]:getPropValue("ReserveExpiration"), 6, 2 ) + '/'+;
                                                        SubStr(oItReserv[nCount]:getPropValue("ReserveExpiration"), 1, 4 ) )
                                Else
                                    dReservevld := StoD(oItReserv[nCount]:getPropValue("ReserveExpiration"))
                                EndIf
							Else	
								dReservevld := dDataBase
							EndIf
							
							Aadd(aItem, {"C0_VALIDA", dReservevld   ,  Nil })
							
							If oItReserv[nCount]:getPropValue("IssueDateReserve") != Nil 
								If !lApi
                                    dReserve := CTOD(SubStr(oItReserv[nCount]:getPropValue("IssueDateReserve"), 9, 2 ) + '/'+;
                                                    SubStr(oItReserv[nCount]:getPropValue("IssueDateReserve"), 6, 2 ) + '/'+;
                                                    SubStr(oItReserv[nCount]:getPropValue("IssueDateReserve"), 1, 4 ) )
                                Else     
                                    dReserve := StoD(oItReserv[nCount]:getPropValue("ReserveExpiration"))
                                EndIf
							Else
								dReserve := dDataBase
							EndIf
							
							Aadd(aItem, {"C0_EMISSAO", dReserve   ,  Nil })
							
							If oItReserv[nCount]:getPropValue("LotNumber") != Nil 
								cLote := Padr(oItReserv[nCount]:getPropValue("LotNumber"),TamSx3("C0_LOTECTL")[1])
							Else
								cLote := ""
							EndIf
							
							Aadd(aItem, {"C0_LOTECTL", cLote   ,  Nil })
		
							If oItReserv[nCount]:getPropValue("SubLotNumber") != Nil 
								cSubLote := Padr(oItReserv[nCount]:getPropValue("SubLotNumber"),TamSx3("C0_NUMLOTE")[1])
							Else
								cSubLote := ""
							EndIf
							
							Aadd(aItem, {"C0_NUMLOTE", cSubLote   ,  Nil })
							
							If oItReserv[nCount]:getPropValue("SeriesItem") != Nil 
								cSerie := Padr(oItReserv[nCount]:getPropValue("SeriesItem"),TamSx3("C0_NUMSERI")[1])
							EndIf
							
							Aadd(aItem, {"C0_NUMSERI", cSerie   ,  Nil })
							
							If oItReserv[nCount]:getPropValue("AddressingItem") != Nil 
								cLocaliz := Padr(oItReserv[nCount]:getPropValue("AddressingItem"),TamSx3("C0_LOCALIZ")[1])
							Else
								cLocaliz := ""
							EndIf
							
							Aadd(aItem, {"C0_LOCALIZ", cLocaliz   ,  Nil })
							
							If oItReserv[nCount]:getPropValue("NoteReserveItem") != Nil 
								cObs := Padr(oItReserv[nCount]:getPropValue("NoteReserveItem"),TamSx3("C0_OBS")[1])
							Else
								cObs := ""
							EndIf
		
							Aadd(aItem, {"C0_OBS", cObs   ,  Nil })
							
							If oItReserv[nCount]:getPropValue("ReserveBranch") != Nil 							   														  
								if !lApi
							    
							   		aFilRes:= FWEAIEMPFIL( cCompany, oItReserv[nCount]:getPropValue("ReserveBranch"), cMarca )
							   		If Len(aFilRes) > 1 .AND. !Empty(aFilRes[2])
							   			cFilRes := aFilRes[2]
							   			Aadd( aItem, { "C0_FILIAL", cFilRes , Nil })
									
						   			Else
						   				lRet    := .F.
						   				cMsgRet += Chr(10) +  STR0032 //"Filial onde será Reservado o Produto não existe no De/Para - Protheus."
					   				Endif
				   				else
				   					cFilRes := cFilAnt				   					
				   					Aadd( aItem, { "C0_FILIAL", oItReserv[nCount]:getPropValue("ReserveBranch") , Nil })				   					
								endif
							Else
									lRet    := .F.
									cMsgRet += Chr(10) +  STR0033 //"A TAG ReserveBranch não foi informada e ela é obrigatória."
							EndIf

                            //A reserva deve ser feita por filial
							If !Empty(cFilResOld) .And. cFilRes <> cFilResOld
                                lRet    := .F.
                                cMsgRet += Chr(10) +  STR0038   //"Não é permitido efetuar reserva para filiais diferentes."                                
                            EndIf

                            //Carrega Itens
							Aadd(aItens, aClone(aItem) )
							
						    cFilResOld  := cFilRes
							aItem 		:= {}
							cProd		:= ""
							cLocal 		:= ""
							dReserve    := CTOD("  /  /  ")
							dReservevld := CTOD("  /  /  ")
							cLote		:= ""
							cSubLote	:= ""
							cSerie		:= ""
							cLocaliz	:= ""
							cObs		:= ""
							cFilRes		:= ""
							aFilRes     := {}
						Next nCount
					Endif
				Endif
				
			Endif
			
			If lRet

                //Carrega os itens que serão processados
                Aadd(aItFil, {cFilResOld, aItens})

                //Chama rotina para manipular reserva
				lRet := EAI704RES(aCab, aItFil, aResult, @cMsgRet, cInternalId, cDocRes, cMarca, @cDestination, @aProdRet, lApi)
			EndIf
			
		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
			lRet    := .F.
            cMsgRet += Chr(10) +  "EAI_MESSAGE_RESPONSE - NAO IMPLEMENTADO"

		EndIf

	ElseIf nTypeTrans == TRANS_SEND
		lRet    := .F.
		cMsgRet += Chr(10) +  "TRANS_SEND - NAO IMPLEMENTADO"

	EndIf

	ofwEAIObj:Activate()
	
	If lRet

		ofwEAIObj:setProp("ReturnContent")
		ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId',,.T.)
		ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:setProp("Name","ITEMRESERVE")
		ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:setProp("Origin",      	cInternalId)
		ofwEAIObj:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:setProp("Destination",  cDestination)

	Else
			
		ofwEAIObj:setProp("ProcessingInformation")
		ofwEAIObj:getPropValue("ProcessingInformation"):setProp("Status", "ERROR")	
		
        If Len(aProdRet) > 0
		    cJson := Loji704VRet( aProdRet )
        EndIf    

		If lApi
            cMsgRet:= FwCutOff(cMsgRet, .T.)
            ofwEAIObj:setError( cMsgRet, "001", cJson , "")
        
        Else

            If !Empty(cJson)

                cMsgRet := AllTrim( IIF( Empty(cMsgRet), STR0036, cMsgRet) )    //"Saldo do Produto é menor que a quantidade Solicitada."
                ofwEAIObj:setError( cMsgRet, "001", cJson , "")
            Else
                ofwEAIObj:setProp("ReturnContent")
                ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cMsgRet)    
            EndIf
        EndIF
				
	EndIf

    Asize(aFilRes   , 0)
    Asize(aCab      , 0)
    Asize(aItens    , 0)
    Asize(aItem     , 0)
    Asize(aItFil    , 0)
    Asize(aResult   , 0)
    Asize(aProd     , 0)
    Asize(aEAIEmpFil, 0)
    Asize(aProdRet  , 0)
	
	RestArea(aSaveSC0)
	RestArea(aSave)

Return {lRet, ofwEAIObj ,"ITEMRESERVE"}

//-------------------------------------------------------------------
/*/{Protheus.doc} Loji704VRet
 Funcao para validar o retorna dos itens e devolver um json formatado para enviar no response
@type function
@param Caracter, aProdRet, Variavel com produtos a validar

@author rafael.pessoa
@version P12
@since 22/11/2018
@return Caracter, Retorna um Json com produtos validados ex: lista de produtos sem estoque

/*/
//-------------------------------------------------------------------
Static Function Loji704VRet( aProdRet )

Local cJson 	:= ""
Local nX 		:= 0
Local oObjJson  := Nil

Default aProdRet := {}

If Len(aProdRet) > 0 
    oObjJson  := JsonObject():New()

    For nX := 1 To Len(aProdRet)

        If nX == 1
            oObjJson["Item"] := {}
        EndIf	

        Aadd(oObjJson["Item"], JsonObject():New() )
        oObjJson["Item"][nX]["ItemCode"] 			 := aProdRet[nX][1]
        oObjJson["Item"][nX]["AvailableStockAmount"] := aProdRet[nX][2]

        //Informações de rastro
        If Len(aProdRet[nX]) >= 6
            oObjJson["Item"][nX]["LotNumber"] 			:= aProdRet[nX][3]
            oObjJson["Item"][nX]["SubLotNumber"]		:= aProdRet[nX][4]
            oObjJson["Item"][nX]["AddressingItem"]		:= aProdRet[nX][5]
            oObjJson["Item"][nX]["SeriesItem"] 			:= aProdRet[nX][6]
        EndIf
        
    Next nX

    cJson := FWJsonSerialize(oObjJson)
    FreeObj(oObjJson)
EndIf

Return cJson
