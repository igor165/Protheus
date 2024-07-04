#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FILEIO.CH"

//dummy function
Function CRMS120()

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} documents
API de integração de Cadastro de Documentos

@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSRESTFUL documents DESCRIPTION "Cadastro de Banco de Conhecimento"

	WSDATA Fields			AS STRING	OPTIONAL
    WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA Code 	        AS STRING	OPTIONAL

	WSMETHOD GET Main ;
    DESCRIPTION "Retorma uma lista com todos os Documentos" ;
    WSSYNTAX "/api/crm/v1/documents/{Order,Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/documents"

	WSMETHOD POST Main ;
    DESCRIPTION "Inclui um Documento" ;
    WSSYNTAX "/api/crm/v1/documents/{Order,Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/documents/"

	WSMETHOD GET Code ;
    DESCRIPTION "Retorna um Documento especificado" ;
    WSSYNTAX "/api/crm/v1/documents/{Code}{Order,Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/documents/{Code}"

	WSMETHOD PUT Code ;
    DESCRIPTION "Altera um documento especificado" ;
    WSSYNTAX "/api/crm/v1/documents/{Code}{Order,Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/documents/{Code}"

	WSMETHOD DELETE Code ;
    DESCRIPTION "Exclui um Documento especificado" ;
    WSSYNTAX "/api/crm/v1/documents/{Code}{Order,Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/documents/{Code}"

ENDWSRESTFUL

//--------------------------------------------------------------------
/*/{Protheus.doc} GET /documents/crm/documents
Lista todos os documentos

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.20
/*/
//--------------------------------------------------------------------
WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE documents

	Local cError			:= ""
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")
	oApiManager := FWAPIManager():New("CRMS120","1.000")

	lRet 	:= GetAC9(@oApiManager, Self)

	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf
	
	oApiManager:Destroy()

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} POST /documents/crm/documents/{Code}
Inclui um Documento

@param	Fields	, caracter, Campos que serão retornados no GET.
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE documents

	Local aFilter       := {}
    Local aJson         := {}
    Local cError		:= ""
	Local cBody 	  	:= Self:GetContent()
	Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("CRMS120","1.000")
	Local oJson			:= THashMap():New()
	
    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"AC9","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
        lRet := ManutDoc(oApiManager, Self:aQueryString, 3, aJson,, oJson, cBody)
        If lRet
			Aadd(aFilter, {"AC9", "items",{"AC9_FILIAL = '" + AC9->AC9_FILIAL + "'"}})
			Aadd(aFilter, {"AC9", "items",{"AC9_CODOBJ = '" + AC9->AC9_CODOBJ + "'"}})
			Aadd(aFilter, {"AC9", "items",{"AC9_ENTIDA = '" + AC9->AC9_ENTIDA + "'"}})
			Aadd(aFilter, {"AC9", "items",{"AC9_FILENT = '" + AC9->AC9_FILENT + "'"}})
			Aadd(aFilter, {"AC9", "items",{"AC9_CODENT = '" + AC9->AC9_CODENT + "'"}})

	        oApiManager:SetApiFilter(aFilter)            
			lRet    := GetMain(oApiManager, Self:aQueryString)						
        Endif
    Else
        oApiManager:SetJsonError("400","Erro ao Incluir Documento!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
    Endif

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aJson,0)
    aSize(aFilter,0)
    FreeObj( oJson )

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} GET /documents/crm/documents/{Code}
Lista um Documento específico

@param	Code		, caracter, Código do Documento
@param	Fields		, caracter, Campos que serão retornados na requisição.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD GET Code PATHPARAM Code WSRECEIVE Fields WSSERVICE documents

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= Nil
	
	Self:SetContentType("application/json")
	oApiManager := FWAPIManager():New("CRMS120","1.000")
	oApiManager:SetApiMap(ApiMap(.T.))

	AC9->(DbSetOrder(1))
	If AC9->(DbSeek( Self:Code ))

		Aadd(aFilter, {"AC9", "items",{"AC9_FILIAL = '" + AC9->AC9_FILIAL + "'"}})
		Aadd(aFilter, {"AC9", "items",{"AC9_CODOBJ = '" + AC9->AC9_CODOBJ + "'"}})
		Aadd(aFilter, {"AC9", "items",{"AC9_ENTIDA = '" + AC9->AC9_ENTIDA + "'"}})
		Aadd(aFilter, {"AC9", "items",{"AC9_FILENT = '" + AC9->AC9_FILENT + "'"}})
		Aadd(aFilter, {"AC9", "items",{"AC9_CODENT = '" + AC9->AC9_CODENT + "'"}})

		oApiManager:SetApiFilter(aFilter)
		
		lRet := GetAC9(@oApiManager, Self, .T.)
	Else
        lRet := .F.
        oApiManager:SetJsonError("404","Erro ao Listar o Documento!", "Documento não encontrado.",/*cHelpUrl*/,/*aDetails*/)
	Endif

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aFilter,0)

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} PUT /documents/crm/documents/{Code}
Altera um Documento específico

@param	Code		        , caracter, Código do Documento
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD PUT Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE documents

	Local aFilter		:= {}
	Local aJson			:= {}	
    Local cBody 	   	:= Self:GetContent()
    Local cError		:= ""
    Local lRet			:= .T.    
	Local oApiManager 	:= FWAPIManager():New("CRMS120","1.000")
	Local oJson			:= THashMap():New()	

	Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"AC9","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
		AC9->(DbSetOrder(1))
        If AC9->(DbSeek( Self:Code ))
		    lRet := ManutDoc(oApiManager, Self:aQueryString, 4, aJson, Self:Code, oJson, cBody)
            If lRet
				Aadd(aFilter, {"AC9", "items",{"AC9_FILIAL = '" + AC9->AC9_FILIAL + "'"}})
				Aadd(aFilter, {"AC9", "items",{"AC9_CODOBJ = '" + AC9->AC9_CODOBJ + "'"}})
				Aadd(aFilter, {"AC9", "items",{"AC9_ENTIDA = '" + AC9->AC9_ENTIDA + "'"}})
				Aadd(aFilter, {"AC9", "items",{"AC9_FILENT = '" + AC9->AC9_FILENT + "'"}})
				Aadd(aFilter, {"AC9", "items",{"AC9_CODENT = '" + AC9->AC9_CODENT + "'"}})

                oApiManager:SetApiFilter(aFilter)
				lRet    := GetMain(oApiManager, Self:aQueryString)
            Endif
        Else
            lRet := .F.
            oApiManager:SetJsonError("404","Erro ao alterar o Documento!", "Documento não encontrado.",/*cHelpUrl*/,/*aDetails*/)
        Endif
    Else
        lRet := .F.        
        oApiManager:SetJsonError("400","Erro ao Alterar Documento!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
    Endif

    If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

    oApiManager:Destroy()
	aSize( aFilter, 0)
	aSize( aJson, 0)
    FreeObj( oJson )

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} DELETE /documents/crm/documents/{Code}
Deleta um Contato específico

@param	Code		        , caracter, Código do Documento
@param	Fields				, caracter, Campos que serão retornados na requisição.
@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		11/09/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
WSMETHOD DELETE Code PATHPARAM Code WSRECEIVE Fields WSSERVICE documents

	Local aJson			:= {}
	Local cResp			:= "Registro Deletado com Sucesso"
    Local cBody			:= Self:GetContent()
	Local cError		:= ""
    Local lRet			:= .T.
    Local oApiManager	:= FWAPIManager():New("CRMS120","1.000")
    Local oJsonPositions:= JsonObject():New()
	
    Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"AC9","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	AC9->(DbSetOrder(1))
    If AC9->(DbSeek( Self:Code ))
		lRet := ManutDoc(oApiManager, Self:aQueryString, 5, aJson, Self:Code, , cBody)        
    Else
        lRet := .F.
        oApiManager:SetJsonError("404","Erro ao Excluir o Documento!", "Documento não encontrado.",/*cHelpUrl*/,/*aDetails*/)
    Endif

    If lRet
		oJsonPositions['response'] := cResp
		cResp := EncodeUtf8(FwJsonSerialize( oJsonPositions, .T. ))
		Self:SetResponse( cResp )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

    oApiManager:Destroy()
	aSize(aJson,0)
    FreeObj( oJsonPositions )

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} ManutDoc
Realiza a manutenção (inclusão/alteração/exclusão) do Documetno

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpcx		, Numérico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com codigo do apontamento
@param oJson		, Objeto	, Objeto com Json parceado
@param cBody        , Caracter  , Corpo do Requisicao JSON

@return lRet	    , Lógico	, Retorna se realizou ou não o processo

@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function ManutDoc(oApiManager, aQueryString, nOpcx, aJson, cChave, oJson, cBody)

	Local cResp		:= "Não foi possivel realizar Inclusão/Alteração/Exclusão do Documento"
	Local cCodObj	:= ""
	Local lRet		:= .T.
	Local nSaveSX8	:= 0

	Default aJson			:= {}
	Default cChave 			:= ""
	Default oJson			:= Nil
	Default cBody			:= ""
	
	Begin Transaction

		If nOpcx == 3 .or. Empty(cChave)
			nSaveSX8	:= GetSX8Len()
			cCodObj 	:= GetSXENum("ACB", "ACB_CODOBJ")
		Else
			If Len(cChave) > FWSizeFilial()+1
				cCodObj		:= Substr(cChave,FWSizeFilial()+1)
			Else
				lRet := .F.
			Endif
		Endif

		If lRet .And. nOpcx <> 5

			If AttIsMemberOf(oJson, "ListOfKnowledge") .And. Valtype(oJson:ListOfKnowledge) == "A"
				If AttIsMemberOf(oJson:ListOfKnowledge[1], "EncodeDocument")
					If Empty(oJson:ListOfKnowledge[1]:EncodeDocument)
						lRet := .F.
					Endif
				Else 
					lRet := .F.
				Endif
			Else 
				lRet := .F.
			Endif

			If lRet
				lRet := ManutAC9(nOpcx , oJson, cCodObj)
				If lRet 
					lRet := ManutACB(nOpcx , oJson, cCodObj, @cResp)
					If lRet
						lRet := ManutACC(nOpcx , oJson, cCodObj)
					Else 
						DisarmTransaction()     				
					Endif
				Else
					DisarmTransaction()     			
				Endif
			Else 
				cResp	:= "Documento em base64 não encontrado no corpo da requisição..."
			Endif
		Elseif lRet .and. nOpcx == 5
			lRet := ManutACC(nOpcx , oJson, cCodObj)
			If lRet 
				lRet := ManutACB(nOpcx , oJson, cCodObj)
				If lRet
					lRet := ManutAC9(nOpcx , oJson, cCodObj)
				Else
					DisarmTransaction() 
				Endif
			Else 
				DisarmTransaction() 
			Endif			
		Endif

		While ( GetSx8Len() > nSaveSX8 ) 
			ConfirmSX8()
		EndDo

	End Transaction
	
	If !lRet
		oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão do Documento.",cResp, /*cHelpUrl*/,/*aDetails*/)
	Else 
		DefRelation(@oApiManager)
	Endif
	
Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} ManutAC9
Realiza a manutenção (inclusão/alteração/exclusão) do documento

@param cCodObj		, Caractere	, Codigo do Objeto
@param nOpcx		, Numérico	, Operação a ser realizada
@param oJson		, Objeto	, Objeto com Json parceado
@return lRet	    , Lógico	, Retorna se realizou ou não o processo

@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function ManutAC9(nOpcx , oJson, cCodObj)

	Local lRet 		:= .F.
	Local cEntity	:= ""

	If nOpcx == 3
		Reclock("AC9",.T.)
		AC9->AC9_FILIAL := xFilial("AC9")
		AC9->AC9_CODOBJ	:= cCodObj
		lRet := .T.
	Elseif nOpcx == 4 .Or. nOpcx == 5
		Reclock("AC9",.F.)
		lRet := .T.
	Endif

	If nOpcx == 3 .Or. nOpcx == 4

		If AttIsMemberOf(oJson, "Entity") .And. !Empty(oJson:Entity)
			cEntity := oJson:Entity
			If FWAliasInDic(cEntity)
				AC9->AC9_ENTIDA := cEntity
				AC9->AC9_FILENT	:= xFilial(cEntity)
				lRet := .T.
			Else
				lRet := .F.
			Endif
		Else
			lRet := .F.
		Endif

		If AttIsMemberOf(oJson, "EntityCode") .And. !Empty(oJson:EntityCode) .And. !Empty(cEntity)
			If ExistCpo(cEntity, oJson:EntityCode, 1 )
				AC9->AC9_CODENT	:= oJson:EntityCode
				lRet := .T.
			Else
				lRet := .F.
			Endif
		Else
			lRet := .F.
		Endif
	
	Elseif nOpcx == 5
		AC9->(DbDelete())
	Endif

	AC9->(MsUnlock())

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} ManutACB
Realiza a manutenção (inclusão/alteração/exclusão) do documento

@param cCodObj		, Caractere	, Codigo do Objeto
@param nOpcx		, Numérico	, Operação a ser realizada
@param oJson		, Objeto	, Objeto com Json parceado
@return lRet	    , Lógico	, Retorna se realizou ou não o processo

@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function ManutACB(nOpcx , oJson , cCodObj , cResp)

	Local cObject	:= ""
	Local lRet 		:= .T.
	Local nI		:= 0

	DbSelectArea("ACB")
	ACB->(DbSetOrder(1))

	If nOpcx <> 5 .And. AttIsMemberOf(oJson, "ListOfKnowledge") .And. Valtype(oJson:ListOfKnowledge) == "A"
		For nI := 1 To Len(oJson:ListOfKnowledge)
			If ACB->(DbSeek(xFilial("ACB") + cCodObj))
				Reclock("ACB",.F.)
			Else
				Reclock("ACB",.T.)
			Endif

			If AttIsMemberOf(oJson:ListOfKnowledge[nI], "FileName") .And. !Empty(oJson:ListOfKnowledge[nI]:FileName)
				ACB->ACB_FILIAL := xFilial("ACB")
				ACB->ACB_CODOBJ	:= cCodObj
				ACB->ACB_OBJETO	:= oJson:ListOfKnowledge[nI]:FileName
				cObject 		:= oJson:ListOfKnowledge[nI]:FileName

				If AttIsMemberOf(oJson:ListOfKnowledge[nI], "EncodeDocument") .And. !Empty(oJson:ListOfKnowledge[nI]:EncodeDocument)
					GravaArq(oJson:ListOfKnowledge[nI]:EncodeDocument, cObject, @cResp)
				Else 
					cResp	:= "Documento em base64 não encontrado no corpo da requisição..."
					lRet 	:= .F.
				Endif
			Endif

			If AttIsMemberOf(oJson:ListOfKnowledge[nI], "FileDescription") .And. !Empty(oJson:ListOfKnowledge[nI]:FileDescription)
				ACB->ACB_DESCRI	:= oJson:ListOfKnowledge[nI]:FileDescription
			Elseif nOpcx == 3
				ACB->ACB_DESCRI	:= cObject
			Endif

			ACB->(MsUnlock())
		Next nI
	Elseif nOpcx == 5
		If ACB->(DbSeek(xFilial("ACB") + cCodObj ))
			While ACB->(!Eof()) .And. ACB->ACB_CODOBJ == cCodObj
				Reclock("ACB",.F.)
				ACB->(DbDelete())
				ACB->(MsUnlock())
				ACB->(DbSkip())
			Enddo
		Endif			
	Endif

	ACB->(DbCloseArea())

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} ManutACC
Realiza a manutenção (inclusão/alteração/exclusão) do documento

@param cCodObj		, Caractere	, Codigo do Objeto
@param nOpcx		, Numérico	, Operação a ser realizada
@param oJson		, Objeto	, Objeto com Json parceado
@return lRet	    , Lógico	, Retorna se realizou ou não o processo

@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function ManutACC(nOpcx, oJson, cCodObj)

	Local lRet := .T.
	Local nI	:= 0

	DbSelectArea("ACC")
	ACC->(DbSetOrder(1))
	If nOpcx == 3
		If AttIsMemberOf(oJson, "ListOfKeyWords") .And. Valtype(oJson:ListOfKeyWords) == "A"
			For nI := 1 To Len(oJson:ListOfKeyWords)
				If AttIsMemberOf(oJson:ListOfKeyWords[nI], "FileSearch") .And. !Empty(oJson:ListOfKeyWords[nI]:FileSearch)
					Reclock("ACC",.T.)
					ACC->ACC_FILIAL := xFilial("ACC")
					ACC->ACC_CODOBJ	:= cCodObj
					ACC->ACC_KEYWRD	:= oJson:ListOfKeyWords[nI]:FileSearch				
					ACC->(MsUnlock())
				Endif
			Next nI
		Endif
	Elseif nOpcx == 5
		If ACC->(DbSeek(xFilial("ACC") + cCodObj ))
			While ACC->(!Eof()) .And. ACC->ACC_CODOBJ == cCodObj
				Reclock("ACC",.F.)
				ACC->(DbDelete())
				ACC->(MsUnlock())
				ACC->(DbSkip())
			Enddo
		Endif
	Endif

	ACC->(DbCloseArea())

Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} GetAC9
Realiza o Get dos Documentos
@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param Self			, Objeto	, Objeto Restful
@return lRet	    , Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function GetAC9(oApiManager, Self , lFile)

	Local aFatherAlias	:=  {"AC9", "items"             , "items"           } 
	Local cIndexKey		:=  "AD6_FILIAL, AD6_VEND, AD6_DATA, AD6_SEQUEN, AD6_ITEM"
    Local lRet          :=  .T.

	Default lFile := .F.

	DefRelation(@oApiManager, lFile)
	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} GetMain
Realiza o Get dos Documentos

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informação se existem ou não mais paginas a serem exibidas
@param cIndexKey	, String	, Índice da tabela pai
@return lRet	    , Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function GetMain(oApiManager, aQueryString, aFatherAlias, lHasNext, cIndexKey)

	Local aRelation 		:= {}
	Local aChildrenAlias	:= {}
	Local lRet 				:= .T.

	Private cSize			:= "0 KB"

	Default cIndexKey		:= ""
	Default aQueryString	:={,}
	Default oApiManager		:= Nil
	Default lHasNext		:= .T.

	lRet := ApiMainGet(@oApiManager, aQueryString, aRelation , aChildrenAlias, aFatherAlias, cIndexKey, oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} DefRelation
Realiza o relacionamento da Estrutura

@param      oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@return     Nil         , Nulo
@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function DefRelation(oApiManager , lFile)

    Local aChldACB  	:= 	{"ACB", "ListOfKnowledge"      		, "ListOfKnowledge"  	}
	Local aChldACC  	:= 	{"ACC", "ListOfKeyWords"      		, "ListOfKeyWords"  	}
    Local aFatherAC9	:=	{"AC9", "items"                     , "items"           		}
    Local aRelatACB     :=  {{"AC9_FILIAL", "ACB_FILIAL"},{"AC9_CODOBJ", "ACB_CODOBJ"}}	
    Local aRelatACC     :=  {{"AC9_FILIAL", "ACC_FILIAL"},{"AC9_CODOBJ", "ACC_CODOBJ"}}
	Local cIndexACB		:=  "ACB_FILIAL, ACB_CODOBJ"
	Local cIndexACC		:=  "ACC_FILIAL, ACC_CODOBJ"

	Default lFile := .F.

	oApiManager:SetApiRelation(aChldACB	, aFatherAC9  , aRelatACB, cIndexACB)
	oApiManager:SetApiRelation(aChldACC	, aFatherAC9  , aRelatACC, cIndexACC)
    oApiManager:SetApiMap(ApiMap(lFile))

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} ApiMap
Estrutura a ser utilizada na classe ServicesApiManager

@return     aApiMap , Array , Array com estrutura 

@author		Squad Faturamento/CRM
@since		25/10/2018
@version	12.1.21
/*/
//--------------------------------------------------------------------
Static Function ApiMap(lFile)

	Local aApiMap	:= {}
	Local aStrAC9	:= {}
	Local aStrACB	:= {}
	Local aStrACC	:= {}
	Local aStrTmp	:= {}	
	Local aStruct 	:= {}

	Default lFile	:= .F.

	aStrAC9 := {"AC9","Field","items","items",;
					{;
						{"CompanyId"								, "Exp:cEmpAnt"									},;
						{"BranchID"									, "AC9_FILIAL"									},;
						{"CompanyInternalId"						, "Exp:cEmpAnt, AC9_FILIAL, AC9_CODOBJ, AC9_ENTIDA, AC9_FILENT, AC9_CODENT"},;
						{"InternalId"								, "AC9_FILIAL, AC9_CODOBJ"						},;
						{"Code"		                            	, "AC9_CODOBJ"									},;
						{"Entity"			                    	, "AC9_ENTIDA"									},;
						{"BranchEntity"		                        , "AC9_FILENT"									},;
						{"EntityCode"	                            , "AC9_CODENT"									};
					};
				}

	aAdd(aStrTmp,{"FileName"		,"ACB_OBJETO"		})
	aAdd(aStrTmp,{"FileDescription"	,"ACB_DESCRI"		})
	aAdd(aStrTmp,{"FileSizeBytes"	,"Exp:CRMS120T(ACB->ACB_OBJETO)"	})

	If lFile
		aAdd(aStrTmp,{"EncodeDocument","Exp:CRMS120E(ACB->ACB_OBJETO)"})
	Endif

	aStrACB := { "ACB", "Item", "ListOfKnowledge", "ListOfKnowledge",aStrTmp}

	aStrACC := { "ACC", "Item", "ListOfKeyWords", "ListOfKeyWords",;
					{;
						{"FileSearch"								, "ACC_KEYWRD"									};
					};
				}

	aStruct := {aStrAC9,aStrACB,aStrACC}

	aApiMap := {"CRMS120","items","1.000","CRMA120",aStruct,"items"}

Return aApiMap

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMS120E()
Formata um valor em bytes em um texto para ser exibida amigavelmente.
  
@param	cObject	, caractere, Objeto (ACB->ACB_OBJETO)
@return cRet	, caractere, Texto amigável

@author	 Squad CRM/Faturamento
@since	 25/10/2018
@version 12.1.21 
/*/
//--------------------------------------------------------------------
Function CRMS120E(cObject)

	Local cContent		:= ""
	Local cDirDocs		:= ""
	Local cRet			:= ""
	Local nBytesRead 	:= 0
	Local nHandle	 	:= 0
	Local nSize		 	:= Val(CRMS120T( cObject , @cDirDocs))

	nHandle		:= FOpen(cDirDocs + "\" + cObject )
	nSize		:= FSeek(nHandle,0,2)

	FSeek(nHandle,0)

	While nSize > 0
		nBytesRead 	:= min(1024,nSize) 
		cContent 	:= Space(nBytesRead)
		FRead(nHandle,	@cContent, nBytesRead) 
		cRet 		+= cContent
		nSize 		:= nSize - nBytesRead
	Enddo

	cRet	:= Encode64(cRet)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMS120T()
Formata um valor em bytes em um texto para ser exibida amigavelmente.
  
@param	cObject	, caractere, Objeto (ACB->ACB_OBJETO)
@return cRet	, caractere, Texto amigável

@author	 Squad CRM/Faturamento
@since	 25/10/2018
@version 12.1.21 
/*/
//--------------------------------------------------------------------
Function CRMS120T( cObject , cDirDocs)

	Local aDir		:= {}	
	Local cRet 		:= "0 KB"

	Default cDirDocs	:= ""

	If MsMultDir()
		cDirDocs := MsRetPath( cObject ) 
	Else
		cDirDocs := MsDocPath()
	Endif

	aDir := Directory(  cDirDocs + "\" + cObject  )

	If !Empty( aDir )		
		Do Case
			Case aDir[1,2] < 1024			
				cRet := Transform( aDir[1,2] / 1024,"9999.9999") + " KB"
			Case aDir[1,2] >= 1024 .And. aDir[1,2] < 1024*1024
				cRet := Transform( aDir[1,2] / 1024, "9999.99") + " KB"
			Case aDir[1,2] >= 1024*1024 .And. aDir[1,2] < 1024*1024*1024
				cRet := Transform( aDir[1,2] /(1024*1024),"9999.99") + " MB"			
			Case aDir[1,2] >= 1024*1024*1024 .And. aDir[1,2] < 1024*1024*1024*1024
				cRet := Transform( aDir[1,2] / (1024*1024*1024), "9999.99") + " GB"
		EndCase
	EndIf

	aSize(aDir,0)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaArq()
Formata um valor em bytes em um texto para ser exibida amigavelmente.
  
@param	cObject	, caractere, Objeto (ACB->ACB_OBJETO)
@return cRet	, caractere, Texto amigável

@author	 Squad CRM/Faturamento
@since	 25/10/2018
@version 12.1.21 
/*/
//--------------------------------------------------------------------
Static Function GravaArq(cArquivo, cObject, cResp)

	Local cDirDocs	:= ""
	Local nHandle	:= 0

	If MsMultDir()
		cDirDocs := MsRetPath( cObject )
	Else
		cDirDocs := MsDocPath()
	Endif

	nHandle := FCreate(cDirDocs + "\" + cObject , 0)
	
	If nHandle > 0
		FWrite(nHandle, Decode64(cArquivo))
		FClose(nHandle)
	Else 
		cResp	:= "Não foi possivel incluir o arquivo"
	Endif

Return Nil