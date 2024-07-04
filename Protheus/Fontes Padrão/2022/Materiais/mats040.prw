#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"

//dummy function
Function MATS040()
Return

/*/{Protheus.doc} Seller

API de integração de Cadastro de Vendedor

@author		Squad Faturamento/SRM
@since		02/08/2018
/*/
WSRESTFUL Seller DESCRIPTION "Cadastro de Vendedor" //"Cadastro de Vendedor"
	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA Code				AS STRING	OPTIONAL
 
    WSMETHOD GET Main ;
    DESCRIPTION "Carrega todos os vendedores" ;
    WSSYNTAX "/api/crm/v2/Seller/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v2/Seller"

    WSMETHOD POST Main ;
    DESCRIPTION "Cadastra um novo Vendedor" ;
    WSSYNTAX "/api/crm/v2/Seller/" ;
    PATH "/api/crm/v2/Seller"	

	WSMETHOD GET Code ;
    DESCRIPTION "Carrega um vendedor específico" ;
    WSSYNTAX "/api/crm/v2/Seller/{Code}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v2/Seller/{Code}"

	WSMETHOD PUT Code ;
    DESCRIPTION "Altera um vendedor específico" ;
    WSSYNTAX "/api/crm/v2/Seller/{Code}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v2/Seller/{Code}"

	WSMETHOD DELETE Code ;
    DESCRIPTION "Deleta um vendedor específico" ;
    WSSYNTAX "/api/crm/v2/Seller/{Code}/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v2/Seller/{Code}"


ENDWSRESTFUL

/*/{Protheus.doc} GET / Seller/Seller
Retorna todos os vendedores

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE Seller
	
    Local cError		:= ""
	Local lRet			:= .T.
	Local oApiManager	:= Nil

	Private cRtGetList  := ""
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("MATS040","2.001") 
	
	lRet    := GetSA3(@oApiManager, Self)

	If lRet
		Self:SetResponse( cRtGetList )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf
	
	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} POST / Seller/Seller
Inclui um novo vendedor

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE Seller	

	Local aFilter       := {}
    Local aJson         := {}
    Local cError		:= ""
	Local cBody 	  	:= Self:GetContent()
	Local lRet			:= .T.
	Local oApiManager	:= FWAPIManager():New("MATS040","2.001")
	Local oJson			:= THashMap():New()

    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"SA3","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

	If lRet 
		lRet := ManutVend(oApiManager, Self:aQueryString, 3, aJson, ,oJson, cBody)		
		If lRet
            aAdd(aFilter, {"SA3", "items",{"A3_FILIAL = '" + SA3->A3_FILIAL + "'"}})
            aAdd(aFilter, {"SA3", "items",{"A3_COD = '" + SA3->A3_COD + "'"}})
	        oApiManager:SetApiFilter(aFilter)
			lRet    := GetSA3(@oApiManager, Self)
        Endif
	Else
		oApiManager:SetJsonError("400","Erro ao Incluir Vendedor!", "Nao foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
	Endif	

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aJson,0)    
    FreeObj( oJson )

Return lRet

/*/{Protheus.doc} GET / Seller/Seller/Code
Retorna um vendedor específico

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
WSMETHOD GET Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE Seller

	Local aFilter			:= {}
	Local cError			:= ""
    Local lRet 				:= .T.
	Local oApiManager		:= FWAPIManager():New("mats040","2.001")
	
	Default Self:Code:= ""

    Self:SetContentType("application/json")    
	
	aAdd(aFilter, {"SA3", "items",{"A3_FILIAL = '" + xFilial("SA3") + "'"}})
	aAdd(aFilter, {"SA3", "items",{"A3_COD = '" + Self:Code + "'"}})
	oApiManager:SetApiFilter(aFilter) 	

	If lRet
		lRet := GetSA3(@oApiManager, Self)
	EndIf

	If lRet		
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	FreeObj(aFilter)

Return lRet

/*/{Protheus.doc} PUT / Seller/Seller
Altera um vendedor especíifco

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
WSMETHOD PUT Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE Seller

	Local aFilter		:= {}
	Local aJson			:= {}
    Local cBody 	   	:= Self:GetContent()
    Local cError		:= ""
    Local lRet			:= .T.
	Local oApiManager 	:= FWAPIManager():New("MATS040","2.001")
	Local oJson			:= THashMap():New()

	Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"SA3","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

	If lRet
		If SA3->(Dbseek(xFilial("SA3") + Self:Code))
			lRet := ManutVend(oApiManager, Self:aQueryString, 4, aJson, Self:Code, oJson, cBody)
			If lRet
				aAdd(aFilter, {"SA3", "items",{"A3_FILIAL = '" + SA3->A3_FILIAL + "'"}})
            	aAdd(aFilter, {"SA3", "items",{"A3_COD = '" + SA3->A3_COD + "'"}})
				oApiManager:SetApiFilter(aFilter)
				lRet := GetSA3(@oApiManager, Self)
			Endif
		Else
			lRet := .F.
            oApiManager:SetJsonError("404","Erro ao Alterar Vendedor!", "Registro nao encontrado",/*cHelpUrl*/,/*aDetails*/)
		Endif
	Else
        lRet := .F.        
        oApiManager:SetJsonError("400","Erro ao Alterar Vendedor!", "Nao foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
	EndIf

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

/*/{Protheus.doc} DELETE / Seller/Seller
Deleta um vendedor

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
WSMETHOD DELETE Code PATHPARAM Code WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE Seller

	Local aJson			:= {}
	Local cResp			:= "Registro Excluido com Sucesso"
    Local cBody			:= Self:GetContent()
	Local cError		:= ""
    Local lRet			:= .T.
    Local oApiManager	:= FWAPIManager():New("MATS040","2.001")
    Local oJsonPositions:= JsonObject():New()
	
    Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"AOF","items", "items"})
	oApiManager:SetApiMap(ApiMap())
	oApiManager:Activate()

	If SA3->(Dbseek(xFilial("SA3") + Self:Code))
		lRet := ManutVend(oApiManager, Self:aQueryString, 5, aJson, Self:Code, , cBody)
	Else
		lRet	:= .F.
		oApiManager:SetJsonError("404","Erro durante a exclusao do vendedor!","Vendedor nao encontrado",/*cHelpUrl*/,/*aDetails*/)
	EndIf
	
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

/*/{Protheus.doc} ManutVend
Função para incluir/alterar/excluir um vendedor

@param	nOpc			, numérico	, Informa se é uma inclusão (3), alteração (4) ou exclusão (5)
@param	oApiManager		, objeto	, Objeto com a classe API Manager
@param	cBody			, caracter	, Json recebido
@param	aQueryString	, array		, Array com os filtros

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
Static Function ManutVend(oApiManager, aQueryString, nOpcx, aJson, cChave, oJson, cBody)

	Local aCab			:= {}
	Local aMsgErro		:= {}		
    Local lRet			:= .T.
	Local nPosVend		:= 0
	Local nX			:= 0
	Local nPosBlq		:= 0
    
	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile	:= .T.

	Default aJson			:= {}
	Default cChave 			:= ""
	Default oJson			:= Nil
	Default cBody			:= ""
	
	DefRelation(@oApiManager)

	If nOpcx != 5

		aJson := oApiManager:ToArray(cBody)

		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aCab)
		EndIf

		If Len(aJson[1][2]) > 0
			For nX := 1 To Len(aJson[1][2][1])
				oApiManager:ToExecAuto(1, aJson[1][2][1][nX][2], aCab)
			Next nX
		EndIf

		nPosVend := (aScan(aCab ,{|x| AllTrim(x[1]) == "A3_COD"}))

		If nOpcx == 3 .And. nPosVend == 0			
			aAdd( aCab, {'A3_COD',MATI40PNum(), Nil})			
		ElseIf nOpcx == 4
			If nPosVend == 0
				aAdd( aCab, {'A3_COD',cChave, Nil})
			Else
				aCab[nPosVend][2] := cChave
			EndIf
		EndIf

		nPosBlq := (aScan(aCab ,{|x| AllTrim(x[1]) == "A3_MSBLQL"}))

		If nPosBlq > 0
			If (VALTYPE(aCab[nPosBlq][2]) == "L")
				If aCab[nPosBlq][2] == .T.
					aCab[nPosBlq][2] := "2"
				ElseIf aCab[nPosBlq][2] == .F.
					aCab[nPosBlq][2] := "1"
				EndIf
			EndIf
		EndIf
	Else
		aAdd(aCab,{"A3_COD" ,cChave     ,Nil})
	Endif
	
	MSExecAuto( { |x, y| MATA040( x, y ) }, aCab, nOpcx )

	If lMsErroAuto
		aMsgErro := GetAutoGRLog()
		cResp	 := ""
		For nX := 1 To Len(aMsgErro)
			cResp += StrTran( StrTran( aMsgErro[nX], "<", "" ), "-", "" ) + (" ") 
		Next nX	
		lRet := .F.
		oApiManager:SetJsonError("400","Erro durante inclusão/alteração do vendedor!.", cResp,/*cHelpUrl*/,/*aDetails*/)
	EndIf

    aSize(aCab,0)
	aSize(aMsgErro,0)

Return lRet

/*/{Protheus.doc} GetSA3
Realiza o Get dos Vendedores

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param Self			, Objeto	, Objeto Restful
@return lRet	    , Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		20/12/2018
@version	12.1.21
/*/

Static Function GetSA3(oApiManager, Self)

	Local aFatherAlias	:= {"SA3", "items"							, "items"                           }
	Local cIndexKey		:= " A3_FILIAL, A3_COD "
    Local lRet          := .T.
	Local oRetJson		:= JsonObject():new()

    If Len(oApiManager:GetApiRelation()) == 0
	    DefRelation(@oApiManager)
    Endif

	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)
	
	If(lRet == .T.)
		// tratativa para a tag "active" receber um booleano em seu retorno. 
		If isInCallStack('GET_MAIN')
			cRtGetList    := oApiManager:GetJsonSerialize()
			cRtGetList    := REPLACE(cRtGetList,'"active":"2"','"active":true')
			cRtGetList    := REPLACE(cRtGetList,'"active":"1"','"active":false')
		Else
			oRetJson:FromJson(oApiManager:ToObjectJson())
			If oRetJson['active'] == "1"
				oRetJson['active'] := .F.
			Else
				oRetJson['active'] := .T.
			EndIf
		EndIf
		oAPIManager:SetJson(.F.,{oRetJson})
	EndIf

Return lRet

/*/{Protheus.doc} GetMain
Realiza o Get da tabela SA3

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informação se existem ou não mais paginas a serem exibidas
@param cIndexKey	, String	, Índice da tabela pai
@return lRet	    , Lógico	, Retorna se conseguiu ou não processar o Get.
@return lRet	, Lógico	, Retorna se conseguiu ou não processar o Get.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
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

	FreeObj( aRelation )
	FreeObj( aChildrenAlias )
	FreeObj( aFatherAlias )

Return lRet

/*/{Protheus.doc} MATI40PNum

Rotina para retornar o Proximo numero para gravação

@return cProxNum	, caracter	, Código do vendedor.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/
Static Function MATI40PNum()

	Local cProxNum := ""

	cProxNum := GETSX8NUM("SA3","A3_COD")
	While .T.
		If SA3->( DbSeek( xFilial("SA3")+cProxNum ) )
			ConfirmSX8()
			cProxNum:=GetSXeNum("SA3","A3_COD")
		Else
			Exit
		Endif
	Enddo

Return(cProxNum)

/*/{Protheus.doc} ApiMap
Estrutura a ser utilizada na classe ServicesApiManager

@return cRet	, caracter	, Mensagem de retorno de sucesso/erro.

@author		Squad Faturamento/CRM
@since		06/08/2018
@version	12.1.20
/*/

Static Function ApiMap()

	Local apiMap		:= {}
	Local aStrSA3Pai    := {}
	Local aStrSA3End    := {}
	Local aStrSA3Cid	:= {}
	Local aStrSA3Est    := {}
	Local aStrSA3Con    := {}	
	Local aStrSA3Com	:= {}
	Local aStructAlias  := {}

	aStrSA3Pai    :=	{"SA3","fields","items","items",;
							{;
								{"companyId"					, "Exp:cEmpAnt"													},;
								{"branchID"						, "Exp:cFilAnt"													},;
								{"CompanyInternalId"			, "Exp:cEmpAnt, Exp:cFilAnt"									},;
								{"code"							, "A3_COD"														},;
								{"internalId"					, "A3_FILIAL, A3_COD"											},;
								{"name"							, "A3_NOME"														},;
								{"shortName"					, "A3_NREDUZ"													},;
								{"personalIdentification"		, "A3_CGC"														},;
								{"sellerPassWord"				, "A3_SENHA"													},;
								{"sellerPhoneDDD"				, "A3_DDDTEL"													},;
								{"sellerPhone"					, "A3_TEL"														},;
								{"sellerEmail"					, "A3_EMAIL"													},;
								{"representativeType"			, ""															},;
								{"active"						, "A3_MSBLQL"												    };
							},;
						}
							
	aStrSA3End    := 	{"SA3","fields","address","address",;
							{;
								{"address"						, "A3_END"	},;
								{"complement"					, ""															},;
								{"number"						, ""															},;
								{"district"						, "A3_BAIRRO"													},;
								{"region"						, ""															},;
								{"zipCode"						, "A3_CEP"  													},;
								{"poBox"						, ""															},;
								{"mainAddress"					, "Exp:.T."														},;
								{"shippingAddress"				, "Exp:.T."														},;
								{"billingAddress"				, "Exp:.T."														};
							},;
						}

	aStrSA3Cid    := 	{"SA3","fields","city","city",;
							{; 
								{"cityId"						, "A3_MUN"														},;
								{"cityInternalId"				, "A3_MUN"														},;
								{"cityDescription"				, ""															};
							},;
						}

	aStrSA3Est    := 	{"SA3","fields","state","state",;
							{;
								{"stateId"						, "A3_EST"														},;
								{"stateInternalId"				, "A3_EST"														},;
								{"stateDescription"				, ""															};
							},;
						}

	aStrSA3Con    := 	{"SA3","fields","country","country",;
							{;
								{"countryId"					, "A3_PAIS"														},;
								{"countryInternalId"			, "A3_PAIS"														},;
								{"countryDescription"			, ""															};
							},;
						}

	aStrSA3Com    := 	{"SA3","fields","InfoCom","InfoCom",;
							{;
								{"customerVendorInternalId"		, "A3_FORNECE"													},;
								{"salesChargeInterface"			, "A3_GERASE2"													},;
								{"indirectSeller"				, "A3_GERASE2"													},;
								{"indirectSellerInternalId"		, ""															};
							},;
						}

	aStructAlias  := {aStrSA3Pai, aStrSA3End, aStrSA3Cid, aStrSA3Est, aStrSA3Con, aStrSA3Com}
	
	apiMap := {"MATS040","items","2.001","MATA040",aStructAlias,"cabeçalho"}

Return apiMap

/*/{Protheus.doc} DefRelation
Realiza o relacionamento da Estrutura

@param      oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@return     Nil         , Nulo
@author		Squad Faturamento/CRM
@since		10/09/2018
@version	12.1.21
/*/

Static Function DefRelation(oApiManager)

    Local aRelation     := {{"A3_FILIAL","A3_FILIAL"},{"A3_COD","A3_COD"}}
    Local aFatherAlias	:= {"SA3", "items"							, "items"                           }
    Local aChiAddres   	:= {"SA3","address"						, "address"                         }
    Local aChiCity   	:= {"SA3","city"							, "city"                            }	
    Local aChiInfoCo	:= {"SA3","InfoCom"						, "InfoCom"  }
	Local aChiCountr   	:= {"SA3","country"						, "country"                         }
    Local aChiState   	:= {"SA3","state"							, "state"                           }	
	Local cIndexKey		:= "A3_FILIAL, A3_COD"

	oApiManager:SetApiRelation(aChiAddres	, aFatherAlias  	, aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiCountr	, aChiAddres	    , aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiState	, aChiAddres	    , aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiCity 	, aChiAddres	    , aRelation, cIndexKey)
	oApiManager:SetApiRelation(aChiInfoCo 	, aFatherAlias	    , aRelation, cIndexKey)
    oApiManager:SetApiMap(ApiMap())

Return Nil
