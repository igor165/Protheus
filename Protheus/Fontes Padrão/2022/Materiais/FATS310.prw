#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

//dummy function
Function FATS310()

Return

/*/{Protheus.doc} annotation
API de integração de Cadastro de Apontamentos

@author		Squad Faturamento/CRM
@since		03/10/2018
@version	12.1.21
/*/

WSRESTFUL annotation DESCRIPTION "Cadastro de Contatos" 

	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA Code			    AS STRING	OPTIONAL
	
    WSMETHOD GET Main ;
    DESCRIPTION "Retorna todos Apontamentos" ;
    WSSYNTAX "/api/crm/v1/annotation/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/annotation"

    WSMETHOD POST Main ;
    DESCRIPTION "Inclui um Apontamento" ;
    WSSYNTAX "/api/crm/v1/annotation/{Fields}";
    PATH "/api/crm/v1/annotation"

    WSMETHOD GET Code ;
    DESCRIPTION "Retorna um Apontamento especifico" ;
    WSSYNTAX "/api/crm/v1/annotation/{Code}{Fields}" ;
    PATH "/api/crm/v1/annotation/{Code}"

    WSMETHOD PUT Code ;
    DESCRIPTION "Altera um Apontamento específico" ;
    WSSYNTAX "/api/crm/v1/annotation/{Code}{Fields}" ;
    PATH "/api/crm/v1/annotation/{Code}"

    WSMETHOD DELETE Code ;
    DESCRIPTION "Deleta um Apontamento específico" ;
    WSSYNTAX "/api/crm/v1/annotation/{Code}{Fields}" ;
    PATH "/api/crm/v1/annotation/{Code}"

ENDWSRESTFUL

/*/{Protheus.doc} GET /annotation/crm/annotation
Retorna lista com todos Apontamentos

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numúrico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados na requisição.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		03/10/2018
@version	12.1.21
/*/

WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE annotation

    Local cError			:= ""
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("FATS310","1.000")

    lRet    := GetAD5(@oApiManager, Self)

	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf
	
	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} POST /annotation/crm/annotation
Inclui um Apontamento

@param	Fields	, caracter, Campos que serão retornados no GET.
@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		08/10/2018
@version	12.1.21
/*/

WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE annotation

	Local aFilter       := {}
    Local aJson         := {}
    Local cError		:= ""
	Local cBody 	  	:= Self:GetContent()
	Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("FATS310","1.000")
	Local oJson			:= THashMap():New()
	
    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"AD5","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
        lRet := ManutAD5(oApiManager, Self:aQueryString, 3, aJson,, oJson, cBody)
        If lRet
			Aadd(aFilter, {"AD5", "items",{"AD5_FILIAL = '" + AD5->AD5_FILIAL + "'"}})
			Aadd(aFilter, {"AD5", "items",{"AD5_VEND = '" + AD5->AD5_VEND + "'"}})
			Aadd(aFilter, {"AD5", "items",{"AD5_DATA = '" + DtoS(AD5->AD5_DATA) + "'"}})
			Aadd(aFilter, {"AD5", "items",{"AD5_SEQUEN = '" + AD5->AD5_SEQUEN + "'"}})

	        oApiManager:SetApiFilter(aFilter)            
			lRet    := GetMain(oApiManager, Self:aQueryString)						
        Endif
    Else
        oApiManager:SetJsonError("400","Erro ao Incluir Apontamento!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
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

/*/{Protheus.doc} GET /annotation/crm/annotation/{AnnotationId}
Lista um Apontamento específico

@param	Code		, caracter, Código do Apontamento
@param	Fields		, caracter, Campos que serão retornados na requisição.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		08/10/2018
@version	12.1.21
/*/

WSMETHOD GET Code PATHPARAM Code WSRECEIVE Fields WSSERVICE annotation

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= Nil
	
	Self:SetContentType("application/json")
	oApiManager := FWAPIManager():New("FATS310","1.000")

	AD5->(DbSetOrder(1))
	If AD5->(DbSeek( Self:Code ))

		Aadd(aFilter, {"AD5", "items",{"AD5_FILIAL = '" + AD5->AD5_FILIAL + "'"}})
		Aadd(aFilter, {"AD5", "items",{"AD5_VEND = '" + AD5->AD5_VEND + "'"}})
		Aadd(aFilter, {"AD5", "items",{"AD5_DATA = '" + DtoS(AD5->AD5_DATA) + "'"}})
		Aadd(aFilter, {"AD5", "items",{"AD5_SEQUEN = '" + AD5->AD5_SEQUEN + "'"}})

		oApiManager:SetApiFilter(aFilter)
		lRet := GetAD5(@oApiManager, Self)
	Else
        lRet := .F.
        oApiManager:SetJsonError("404","Erro ao Listar o Apontamento!", "Apontamento não encontrado.",/*cHelpUrl*/,/*aDetails*/)
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


/*/{Protheus.doc} PUT /annotation/crm/annotation/{AnnotationId}
Altera um Apontamento específico

@param	AnnotationId        , caracter, Código do Apontamento
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		15/10/2018
@version	12.1.21
/*/

WSMETHOD PUT Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE annotation

	Local aFilter		:= {}
	Local aJson			:= {}	
    Local cBody 	   	:= Self:GetContent()
    Local cError		:= ""
    Local lRet			:= .T.    
	Local oApiManager 	:= FWAPIManager():New("FATS310","1.000")
	Local oJson			:= THashMap():New()	

	Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"AD5","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
		AD5->(DbSetOrder(1))
        If AD5->(DbSeek( Self:Code ))
		    lRet := ManutAD5(oApiManager, Self:aQueryString, 4, aJson, Self:Code, oJson, cBody)
            If lRet
	            Aadd(aFilter, {"AD5", "items",{"AD5_FILIAL = '" + AD5->AD5_FILIAL + "'"}})
				Aadd(aFilter, {"AD5", "items",{"AD5_VEND = '" + AD5->AD5_VEND + "'"}})
				Aadd(aFilter, {"AD5", "items",{"AD5_DATA = '" + DtoS(AD5->AD5_DATA) + "'"}})
				Aadd(aFilter, {"AD5", "items",{"AD5_SEQUEN = '" + AD5->AD5_SEQUEN + "'"}})

                oApiManager:SetApiFilter(aFilter)                
				lRet    := GetMain(oApiManager, Self:aQueryString)
            Endif
        Else
            lRet := .F.
            oApiManager:SetJsonError("404","Erro ao alterar o Apontamento!", "Apontamento não encontrado.",/*cHelpUrl*/,/*aDetails*/)
        Endif
    Else
        lRet := .F.        
        oApiManager:SetJsonError("400","Erro ao Alterar Apontamento!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
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

/*/{Protheus.doc} DELETE /annotation/crm/annotation/{AnnotationId}
Deleta um Contato específico

@param	Code		        , caracter, Código do Apontamento
@param	Fields				, caracter, Campos que serão retornados na requisição.
@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		11/09/2018
@version	12.1.21
/*/

WSMETHOD DELETE Code PATHPARAM Code WSRECEIVE Fields WSSERVICE annotation

	Local aJson			:= {}
	Local cResp			:= "Registro Deletado com Sucesso"
    Local cBody			:= Self:GetContent()
	Local cError		:= ""
    Local lRet			:= .T.
    Local oApiManager	:= FWAPIManager():New("FATS310","1.000")
    Local oJsonPositions:= JsonObject():New()
	
    Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"AD5","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	AD5->(DbSetOrder(1))
    If AD5->(DbSeek( Self:Code ))
		lRet := ManutAD5(oApiManager, Self:aQueryString, 5, aJson, Self:Code, , cBody)        
    Else
        lRet := .F.
        oApiManager:SetJsonError("404","Erro ao Excluir o Apontamento!", "Apontamento não encontrado.",/*cHelpUrl*/,/*aDetails*/)
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


/*/{Protheus.doc} GetAD5
Realiza o Get dos Apontamentos

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param Self			, Objeto	, Objeto Restful
@return lRet	    , Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		03/10/2018
@version	12.1.21
/*/

Static Function GetAD5(oApiManager, Self)

	Local aFatherAlias	:=  {"AD5", "items"             , "items"           } 
	Local cIndexKey		:=  "AD6_FILIAL, AD6_VEND, AD6_DATA, AD6_SEQUEN, AD6_ITEM"
    Local lRet          :=  .T.

	DefRelation(@oApiManager)

	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)

Return lRet

/*/{Protheus.doc} DefRelation
Realiza o relacionamento da Estrutura

@param      oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@return     Nil         , Nulo
@author		Squad Faturamento/CRM
@since		03/10/2018
@version	12.1.21
/*/

Static Function DefRelation(oApiManager)

    Local aChildren  	:= 	{"AD6", "ListOfAnnotationCost"      , "ListOfAnnotationCost"  	}
    Local aFatherAD5	:=	{"AD5", "items"                     , "items"           		}        
    Local aRelation     :=  {}
	Local cIndexKey		:=  "AD6_FILIAL, AD6_VEND, AD6_DATA, AD6_SEQUEN, AD6_ITEM"

    aAdd(aRelation,{"AD5_FILIAL","AD6_FILIAL"   })
    aAdd(aRelation,{"AD5_VEND"  ,"AD6_VEND"     })
    aAdd(aRelation,{"AD5_DATA"  ,"AD6_DATA"     })
    aAdd(aRelation,{"AD5_SEQUEN","AD6_SEQUEN"   })

	oApiManager:SetApiRelation(aChildren	, aFatherAD5  	, aRelation, cIndexKey)

    oApiManager:SetApiMap(ApiMap())

Return Nil

/*/{Protheus.doc} GetMain
Realiza o Get dos Apontamentos

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informação se existem ou não mais paginas a serem exibidas
@param cIndexKey	, String	, Índice da tabela pai
@return lRet	    , Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		03/10/2018
@version	12.1.21
/*/

Static Function GetMain(oApiManager, aQueryString, aFatherAlias, lHasNext, cIndexKey)

	Local aRelation 		:= {}
	Local aChildrenAlias	:= {}
	Local lRet 				:= .T.

	Default cIndexKey		:= ""
	Default aQueryString	:={,}
	Default oApiManager		:= Nil
	Default lHasNext		:= .T.

	lRet := ApiMainGet(@oApiManager, aQueryString, aRelation , aChildrenAlias, aFatherAlias, cIndexKey, oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)

Return lRet

/*/{Protheus.doc} ManutAD5
Realiza a manutenção (inclusão/alteração/exclusão) dO Apontamento

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson		, Array		, Array tratado de acordo com os dados do json recebido
@param cChave		, Caracter	, Chave com codigo do apontamento
@param oJson		, Objeto	, Objeto com Json parceado
@param cBody        , Caracter  , Corpo do Requisicao JSON

@return lRet	    , Lógico	, Retorna se realizou ou não o processo

@author		Squad Faturamento/CRM
@since		08/10/2018
@version	12.1.21
/*/

Static Function ManutAD5(oApiManager, aQueryString, nOpcx, aJson, cChave, oJson, cBody)

	Local aCabec	:= {}
	Local aItens	:= {}
	Local aFronze	:= {"AD5_VEND","AD5_DATA","AD5_SEQUEN"}
	Local aModif	:= {}
	Local aMsgErro	:= {}
	Local aAuxFld	:= {}
	Local aAuxGd	:= {}  
    Local cResp		:= ""
    Local lRet		:= .T.
    Local nX		:= 0	
	Local nY		:= 0
	Local oModel  	:= FWLoadModel("FATA310")
	Local oModelFld	:= oModel:GetModel("AD5MASTER")
	Local oModelGd	:= oModel:GetModel("AD6DETAIL")

	Default aJson			:= {}
	Default cChave 			:= ""
	Default oJson			:= Nil
	Default cBody			:= ""

	DefRelation(@oApiManager)

    If nOpcx <> MODEL_OPERATION_DELETE

		aJson := oApiManager:ToArray(cBody)

		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aCabec)
		EndIf

        If Len(aJson[1][2]) > 0
			For nX := 1 To Len(aJson[1][2])
				oApiManager:ToExecAuto(2, aJson[1][2][nX][1][2], aItens)
			Next
		EndIf

		OrdExec(aCabec)

		If nOpcx == MODEL_OPERATION_INSERT
			oModel:SetOperation(MODEL_OPERATION_INSERT)
		Elseif nOpcx == MODEL_OPERATION_UPDATE
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
		Endif
	Else
		oModel:SetOperation(MODEL_OPERATION_DELETE)
    Endif

	If oModel:Activate()
		If oModel:nOperation <> MODEL_OPERATION_DELETE
			aAuxFld := oModelFld:GetStruct():GetFields()
			aAuxGd	:= oModelGd:GetStruct():GetFields()

			For nY := 1 To Len (aCabec)
				If aScan(aAuxFld, {|x| AllTrim(x[3]) == AllTrim(aCabec[nY][1])}) > 0
					If aScan(aFronze, aCabec[nY,1]) == 0 .or. oModel:nOperation != MODEL_OPERATION_UPDATE
						If !oModelFld:SetValue(aCabec[nY,1], aCabec[nY,2]) 
							lRet := .F.
							cResp := "Não foi possível atribuir o valor " + AllToChar(aCabec[nY,2]) + " ao campo " + aCabec[nY,1] + "."
							Exit
						EndIf
					Endif
				Endif
			Next nY

			If lRet
				For nX := 1 To Len(aItens)

					If nX > 1 .And. oModel:nOperation == MODEL_OPERATION_INSERT
						oModelGd:AddLine()
					Elseif oModel:nOperation == MODEL_OPERATION_UPDATE
						nPosItem := aScan(aItens[nX], {|x| AllTrim(x[1]) == "AD6_ITEM"})
						If !oModelGd:SeekLine({{"AD6_ITEM",aItens[nX,nPosItem,2]}})
							If nX > 1
								oModelGd:AddLine()
							Endif
						Endif
					Endif
					For nY := 1 To Len(aItens[nX])
						If aScan(aAuxGd, {|x| AllTrim(x[3]) == AllTrim(aItens[nX,nY,1])}) > 0
							If !oModelGd:SetValue(aItens[nX,nY,1], aItens[nX,nY,2])
								lRet := .F.
								cResp := "Não foi possível atribuir o valor " + AllToChar(aItens[nX,nY,2]) + " ao campo " + aItens[nX,nY,1] + "."
								Exit
							EndIf
						Endif
					Next nY

					If lRet
						If oModelGd:IsModified()
							If !oModelGd:VldLineData(.F.)
								lRet := .F.
								aMsgErro	:= oModel:GetErrorMessage()				
								cResp := "Mensagem do erro: " 			+ StrTran( StrTran( AllToChar(aMsgErro[6]), "<", "" ), "-", "" ) + (" ")
								cResp += "Mensagem da solução: " 		+ StrTran( StrTran( AllToChar(aMsgErro[7]), "<", "" ), "-", "" ) + (" ")
								cResp += "Valor atribuído: " 			+ StrTran( StrTran( AllToChar(aMsgErro[8]), "<", "" ), "-", "" ) + (" ")
								cResp += "Valor anterior: " 			+ StrTran( StrTran( AllToChar(aMsgErro[9]), "<", "" ), "-", "" ) + (" ")
								cResp += "Id do formulário de origem: " + StrTran( StrTran( AllToChar(aMsgErro[1]), "<", "" ), "-", "" ) + (" ")
								cResp += "Id do campo de origem: " 		+ StrTran( StrTran( AllToChar(aMsgErro[2]), "<", "" ), "-", "" ) + (" ")
								cResp += "Id do formulário de erro: " 	+ StrTran( StrTran( AllToChar(aMsgErro[3]), "<", "" ), "-", "" ) + (" ")
								cResp += "Id do campo de erro: " 		+ StrTran( StrTran( AllToChar(aMsgErro[4]), "<", "" ), "-", "" ) + (" ")
								cResp += "Id do erro: " 				+ StrTran( StrTran( AllToChar(aMsgErro[5]), "<", "" ), "-", "" ) + (" ")
								Exit
							Elseif !oModelGd:IsInserted(oModelGd:GetLine()) .And. oModel:nOperation == MODEL_OPERATION_UPDATE
								oModelGd:SetLineModify(oModelGd:GetLine())
							Endif
						Elseif !oModelGd:IsInserted(oModelGd:GetLine()) .And. oModel:nOperation == MODEL_OPERATION_UPDATE
							oModelGd:SetLineModify(oModelGd:GetLine())
						Endif
					Else
						Exit
					Endif
				
				Next nX

			Endif

			If oModel:nOperation == MODEL_OPERATION_UPDATE .AND. lRet
				aModif := oModelGd:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)
				If Len(aModif) > 0
					For nY := 1 To oModelGd:Length()
						If !aScan(aModif, {|x| x == nY})
							oModelGd:GoLine(nY)
							oModelGd:DeleteLine()
						Endif
					Next nY
				Elseif Len(aItens) == 0
					oModelGd:DelAllLine()
				Endif
			Endif
		Endif

		If lRet
			If oModel:VldData()
				oModel:CommitData()				
			Else
				lRet:= .F.
				aMsgErro	:= oModel:GetErrorMessage()				
				cResp := "Mensagem do erro: " 			+ StrTran( StrTran( AllToChar(aMsgErro[6]), "<", "" ), "-", "" ) + (" ")
				cResp += "Mensagem da solução: " 		+ StrTran( StrTran( AllToChar(aMsgErro[7]), "<", "" ), "-", "" ) + (" ")
				cResp += "Valor atribuído: " 			+ StrTran( StrTran( AllToChar(aMsgErro[8]), "<", "" ), "-", "" ) + (" ")
				cResp += "Valor anterior: " 			+ StrTran( StrTran( AllToChar(aMsgErro[9]), "<", "" ), "-", "" ) + (" ")
				cResp += "Id do formulário de origem: " + StrTran( StrTran( AllToChar(aMsgErro[1]), "<", "" ), "-", "" ) + (" ")
				cResp += "Id do campo de origem: " 		+ StrTran( StrTran( AllToChar(aMsgErro[2]), "<", "" ), "-", "" ) + (" ")
				cResp += "Id do formulário de erro: " 	+ StrTran( StrTran( AllToChar(aMsgErro[3]), "<", "" ), "-", "" ) + (" ")
				cResp += "Id do campo de erro: " 		+ StrTran( StrTran( AllToChar(aMsgErro[4]), "<", "" ), "-", "" ) + (" ")
				cResp += "Id do erro: " 				+ StrTran( StrTran( AllToChar(aMsgErro[5]), "<", "" ), "-", "" ) + (" ")
			EndIf
		Endif
	Endif
    
    If !lRet
        oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão do Apontamento!.", cResp,/*cHelpUrl*/,/*aDetails*/)
    EndIf

	aSize(aModif,0)
	aSize(aAuxFld,0)
	aSize(aFronze,0)
	aSize(aAuxGd,0)
	aSize(aCabec,0)
    aSize(aItens,0)	
	aSize(aMsgErro,0)
	FreeObj(oModel)
	FreeObj(oModelFld)
	FreeObj(oModelGd)

Return lRet

/*/{Protheus.doc} OrdExec
Move posição do campo Numero de oportunidade.
@param aCabec	, Array	, Array de Campos que seram utilizados no ExecAuto


@author		Squad Faturamento/CRM
@since		03/10/2018
@version	12.1.21

/*/

Static Function OrdExec(aCabec)

	Local aTemp	:= {}
	Local nI	:= Len(aCabec) - 1
	Local nY	:= aScan(aCabec,{|x|x[1]=="AD5_NROPOR"})

	If nI > 0 .And. nY > 0
		aTemp := aCabec[nY]
		aDel(aCabec,nY)
		aSize(aCabec,nI)
		aAdd(aCabec,aTemp)
	Endif

Return Nil

/*/{Protheus.doc} ApiMap
Estrutura a ser utilizada na classe ServicesApiManager

@return     aApiMap , Array , Array com estrutura 

@author		Squad Faturamento/CRM
@since		03/10/2018
@version	12.1.21
/*/

Static Function ApiMap()

    Local aApiMap   := {}
    Local aStrAD5   := {}
    Local aStrAD6   := {}
    Local aStruct   := {}

    aStrAD5 := {"AD5","field","items","items",;
		{;
			{"CompanyId"		    , "Exp:cEmpAnt" 							                    },;
			{"BranchId"			    , "Exp:cFilAnt"								                    },;
            {"CompanyInternalId"	, "Exp:cEmpAnt, Exp:cFilAnt, AD5_VEND, AD5_DATA, AD5_SEQUEN"    },;
            {"InternalId"			, "Exp:cFilAnt, AD5_VEND, AD5_DATA, AD5_SEQUEN"                 },;
            {"SellerId"			    , "AD5_VEND"										            },;
            {"RegisterDate"			, "AD5_DATA"										            },;
            {"Sequence"			    , "AD5_SEQUEN"										            },;
            {"CustomerId"			, "AD5_CODCLI"										            },;
			{"CustomerUnit"			, "AD5_LOJA"										            },;
            {"EventId"			    , "AD5_EVENTO"										            },;
            {"OpportunityID"		, "AD5_NROPOR"										            },;
            {"ProspectId"			, "AD5_PROSPE"										            },;
            {"ProspectUnit"			, "AD5_LOJPRO"										            };
		},;
	}

    aStrAD6 := {"AD6","Item","ListOfAnnotationCost","ListOfAnnotationCost",;
		{;
            {"InternalId"			, "Exp:cFilAnt, AD6_VEND, AD6_DATA, AD6_SEQUEN, AD6_ITEM"       },;
			{"ItemSequence"			, "AD6_ITEM"										            },;
			{"ProductId"			, "AD6_CODPRO"										            },;
			{"Quantity"			    , "AD6_QUANT"										            },;
			{"UnitValue"			, "AD6_VLUNIT"										            },;
			{"TotalValue"			, "AD6_TOTAL"										            };
		},;
	}

	aStruct := {aStrAD5,aStrAD6}
	aApiMap := {"FATS310","items","1.000","FATS310", aStruct, "items"}

Return aApiMap