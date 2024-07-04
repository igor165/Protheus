#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//Dummy function
Function FATS300()

Return

/*/{Protheus.doc} Oportunidade
API de integração de Cadastro de Oportunidades

@author	Squad Faturamento/CRM
@since		08/10/2018
@version	12.1.21
/*/

WSRESTFUL opportunity DESCRIPTION "Cadastro de Oportunidades" 

    WSDATA Fields				AS STRING	OPTIONAL
    WSDATA Order				AS STRING	OPTIONAL
    WSDATA Page				AS INTEGER	OPTIONAL
    WSDATA PageSize			AS INTEGER	OPTIONAL
    WSDATA opportunityCode  AS STRING	OPTIONAL
	
    WSMETHOD GET Main ;
    DESCRIPTION "Retorna todas as Oportunidades" ;
    WSSYNTAX "/api/crm/v1/opportunity/{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/opportunity"

    WSMETHOD POST Main ;
    DESCRIPTION "Cadastra um Oportunidade" ;
    WSSYNTAX "/api/crm/v1/opportunity/{Fields}";
    PATH "/api/crm/v1/opportunity"

    WSMETHOD GET OpportunityCode ;
    DESCRIPTION "Retorna um Oportunidade" ;
    WSSYNTAX "/api/crm/v1/opportunity/{opportunityCode}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/opportunity/{opportunityCode}"

    WSMETHOD PUT OpportunityCode ;
    DESCRIPTION "Altera um Oportunidade específica" ;
    WSSYNTAX "/api/crm/v1/opportunity/{opportunityCode}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/opportunity/{opportunityCode}"

    WSMETHOD DELETE OpportunityCode ;
    DESCRIPTION "Deleta um Oportunidade específico" ;
    WSSYNTAX "/api/crm/v1/opportunity/{opportunityCode}{Order, Page, PageSize, Fields}" ;
    PATH "/api/crm/v1/opportunity/{opportunityCode}"
 
ENDWSRESTFUL

/*/{Protheus.doc} GET / opportunity/opportunity
Retorna todos Oportunidades

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numúrico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		08/10/2018
@version	12.1.21
/*/

WSMETHOD GET Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE opportunity

	Local cError			:= ""
	Local lRet				:= .T.
	Local oApiManager		:= Nil
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("FATS300","1.000")
	
    lRet    := GetAD1(@oApiManager, Self)

	If lRet
		Self:SetResponse( oApiManager:GetJsonSerialize() )
	Else
		cError := oApiManager:GetJsonError()	
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf
	
	oApiManager:Destroy()

Return lRet

/*/{Protheus.doc} POST / opportunity/opportunity
Cadastra um Oportunidade

@param	Fields		, caracter, Campos que serão retornados no GET.
@return lRet		, Lógico, Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		08/10/2018
@version	12.1.21
/*/

WSMETHOD POST Main WSRECEIVE Order, Page, PageSize, Fields WSSERVICE opportunity

	Local aFilter      	:= {}
	Local aJson       	:= {}
	Local cError			:= ""
	Local cBody 	  		:= Self:GetContent()
	Local lRet				:= .T.
	Local oApiManager		:= FWAPIManager():New("FATS300","1.000")
	Local oJson			:= THashMap():New()    
	
    Self:SetContentType("application/json")

   	oApiManager:SetApiAlias({"AD1","items", "items"})
	oApiManager:SetApiMap(ApiMapAD1())
	oApiManager:Activate()

	lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
        lRet := ManutAD1(@oApiManager, Self:aQueryString, 3, aJson,, oJson, cBody)
        If lRet
	       Aadd(aFilter, {"AD1", "items",{"AD1_NROPOR = '" + AD1->AD1_NROPOR + "'"}})
	       oApiManager:SetApiFilter(aFilter)	    
        	lRet    := GetAD1(@oApiManager, Self)
        Endif
    Else        
        oApiManager:SetJsonError("400","Erro ao Incluir Oportunidade!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
    Endif

	If lRet
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError["code"]), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aJson,0)
   	aSize(aFilter,0)
   	FreeObj( oJson )

Return lRet

/*/{Protheus.doc} GET / opportunity/opportunity/{opportunityCode}
Retorna uma Oportunidade específico

@param	Order		, caracter, Ordenação da tabela principal
@param	Page		, numérico, Número da página inicial da consulta
@param	PageSize	, numérico, Número de registro por páginas
@param	Fields		, caracter, Campos que serão retornados no GET.

@return lRet	    , Lógico, Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		08/10/2018
@version	12.1.21
/*/

WSMETHOD GET opportunityCode PATHPARAM opportunityCode WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE opportunity

	Local aFilter			:= {}
	Local cError			:= ""
	Local lRet 			:= .T.
	Local oApiManager		:= Nil
	Local cCode			:= ""
	
    Self:SetContentType("application/json")

	oApiManager := FWAPIManager():New("FATS300","1.000")
	
	cCode := Substr(Self:opportunityCode,TamSX3("AD1_FILIAL")[1]+1,Len(Self:opportunityCode))   
	
	If  Len(cCode) <> TamSX3("AD1_NROPOR")[1]
		lRet := .F.
       oApiManager:SetJsonError("400","Erro na requisição da Oportunidade!", "O código da filial ou da oportunidade não condiz com os registros requisitados",/*cHelpUrl*/,/*aDetails*/)
    EndIf
	
	If lRet
		Aadd(aFilter, {"AD1", "items",{"AD1_NROPOR = '" + cCode + "'"}})
		oApiManager:SetApiFilter(aFilter)    
		lRet := GetAD1(@oApiManager, Self)
	EndIf
	
	If lRet		
		Self:SetResponse( oApiManager:ToObjectJson() )
	Else
		cError := oApiManager:GetJsonError()
		SetRestFault( Val(oApiManager:oJsonError['code']), EncodeUtf8(cError) )
	EndIf

	oApiManager:Destroy()
	aSize(aFilter,0)

Return lRet

/*/{Protheus.doc} PUT / opportunity/{opportunityCode}
Altera um Oportunidade específico

@param	opportunityCode	, caracter, Código do Oportunidade
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		08/10/2018
@version	12.1.21
/*/

WSMETHOD PUT opportunityCode PATHPARAM opportunityCode WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE opportunity

    Local aFilter			:= {}
    Local aJson			:= {}	
    Local cBody 	   		:= Self:GetContent()
    Local cError			:= ""
    Local lRet			:= .T.    
    Local oApiManager 	:= FWAPIManager():New("FATS300","1.000")
    Local oJson			:= THashMap():New()
    Local cCode			:= ""	

    Self:SetContentType("application/json")

    oApiManager:SetApiAlias({"AD1","items", "items"})
    oApiManager:SetApiMap(ApiMapAD1())
    oApiManager:Activate()

    lRet = FWJsonDeserialize(cBody,@oJson)

    If lRet
    	cCode := Substr(Self:opportunityCode,TamSX3("AD1_FILIAL")[1]+1,Len(Self:opportunityCode))   
	
		If  Len(cCode) <> TamSX3("AD1_NROPOR")[1]
			lRet := .F.
	       oApiManager:SetJsonError("400","Erro na requisição da Oportunidade!", "O código da filial ou da oportunidade não condiz com os registros requisitados",/*cHelpUrl*/,/*aDetails*/)
	    EndIf
	    
       If lRet 
	        If AD1->(DbSeek(xFilial("AD1") + cCode))
			    lRet := ManutAD1(oApiManager, Self:aQueryString, 4, aJson, cCode, oJson, cBody)
	            If lRet
		            Aadd(aFilter, {"AD1", "items",{"AD1_NROPOR = '" + AD1->AD1_NROPOR + "'"}})
	                oApiManager:SetApiFilter(aFilter)	    
	                lRet    := GetAD1(@oApiManager, Self)
	            Endif
	        Else
	            lRet := .F.
	            oApiManager:SetJsonError("404","Erro ao alterar o Oportunidade!", "Oportunidade não encontrado.",/*cHelpUrl*/,/*aDetails*/)
	        Endif
       EndIf
    Else
        lRet := .F.        
        oApiManager:SetJsonError("400","Erro ao Alterar Oportunidade!", "Não foi possível tratar o Json recebido.",/*cHelpUrl*/,/*aDetails*/)
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

/*/{Protheus.doc} DELETE / opportunity/{opportunityCode}/
Deleta um Oportunidade específico

@param	opportunityCode	, caracter, Código do Oportunidade
@param	Order				, caracter, Ordenação da tabela principal
@param	Page				, numérico, Numero da página inicial da consulta
@param	PageSize			, numérico, Numero de registro por páginas
@param	Fields				, caracter, Campos que serão retornados no GET.

@return lRet	            , Lógico  , Informa se o processo foi executado com sucesso.

@author	Squad Faturamento/CRM
@since		08/10/2018
@version	12.1.21
/*/

WSMETHOD DELETE opportunityCode PATHPARAM opportunityCode WSRECEIVE Order, Page, PageSize, Fields  WSSERVICE opportunity

    Local aJson			:= {}
    Local cResp			:= "Registro Deletado com Sucesso"
    Local cBody			:= Self:GetContent()
    Local cError			:= ""
    Local lRet			:= .T.
    Local oApiManager 	:= FWAPIManager():New("FATS300","1.000")
    Local oJsonPositions	:= JsonObject():New()
    Local cCode			:= ""
	
    Self:SetContentType("application/json")

	oApiManager:SetApiAlias({"AD1","items", "items"})
	oApiManager:SetApiMap(ApiMapAD1())
	oApiManager:Activate()
	
	cCode := Substr(Self:opportunityCode,TamSX3("AD1_FILIAL")[1]+1,Len(Self:opportunityCode))   
	
	If  Len(cCode) <> TamSX3("AD1_NROPOR")[1]
		lRet := .F.
       oApiManager:SetJsonError("400","Erro na requisição da Oportunidade!", "O código da filial ou da oportunidade não condiz com os registros requisitados",/*cHelpUrl*/,/*aDetails*/)
    EndIf

	If lRet
	    If AD1->(DbSeek(xFilial("AD1") + cCode))
			lRet := ManutAD1(oApiManager, Self:aQueryString, 5, aJson, cCode, , cBody)        
	    Else
	        lRet := .F.
	        oApiManager:SetJsonError("404","Erro ao Excluir o Oportunidade!", "Oportunidade não encontrado.",/*cHelpUrl*/,/*aDetails*/)
	    Endif
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

/*/{Protheus.doc} ManutAD1
Realiza a manutenção (inclusão/alteração/exclusão) do Oportunidade

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param nOpc			, Numérico	, Operação a ser realizada
@param aJson			, Array		, Array tratado de acordo com os dados do json recebido
@param cChave			, Caracter	, Chave com codigo do Oportunidade (AD1_NROPOR)
@param oJson			, Objeto	, Objeto com Json parceado
@param cBody       	, Caracter  , Corpo do Requisicao JSON

@return lRet	    , Lógico	, Retorna se realizou ou não o processo

@author	Squad Faturamento/CRM
@since		08/10/2018
@version	12.1.21
/*/

Static Function ManutAD1(oApiManager, aQueryString, nOpc, aJson, cChave, oJson, cBody)
                
	Local   aCabOportu   := {}
	Local   aContato		:= {}
	Local   aMsgErro     := {}			
	Local   cCodigo      := ""
	Local   cResp	       := ""
	Local   lRet         := .T.
	Local   nPosCod      := 0
	Local   nX           := 0
	Local   nPosTpCP     := 0
	Local   nPosCodCP    := 0
	Local   nPosLojCP    := 0
	Local	 nPosNomCP		:= 0
	Local	 nPosOpor		:= 0
	Local   aTroca       := {}

	Private lMsErroAuto 		:= .F.
	Private lAutoErrNoFile	:= .T.

	Default aJson			:= {}
	Default cChave 		:= ""
	Default oJson			:= Nil
	Default cBody			:= ""

	DefRelation(@oApiManager)

    If !Empty(cChave)
		cCodigo := SubStr(cChave, 1, TamSX3("AD1_NROPOR")[1] )
	EndIf

    If nOpc != 5

		aJson := oApiManager:ToArray(cBody)

		If Len(aJson[1][1]) > 0
			oApiManager:ToExecAuto(1, aJson[1][1][1][2], aCabOportu)
		EndIf
		
        If Len(aJson[1][2]) > 0
			For nX := 1 To Len(aJson[1][2][1])
				oApiManager:ToExecAuto(1, aJson[1][2][1][nX][2], aContato)
			Next
		EndIf
		
        nPosCod	:= (aScan(aCabOportu ,{|x| AllTrim(x[1]) == "AD1_NROPOR"}))

        If nOpc == 4 .And. nPosCod > 0
			aCabOportu[nPosCod][2]  := cCodigo
        Elseif nOpc == 4 .And. nPosCod == 0
            aAdd(aCabOportu,{"AD1_NROPOR" ,cChave     ,Nil})
        Endif
        
        ASort(aCabOportu,,,{ |x,y| x[1] < y[1] })
        
        nPosTpCP := (aScan(aCabOportu ,{|x| AllTrim(x[1]) == "TIPOCLI"}))
        nPosCodCP := (aScan(aCabOportu ,{|x| AllTrim(x[1]) == "CODCP"}))
        nPosLojCP := (aScan(aCabOportu ,{|x| AllTrim(x[1]) == "LOJCP"}))
        nPosNomCP := (aScan(aCabOportu ,{|x| AllTrim(x[1]) == "NOMECP"}))
        If nPosTpCP <> 0 .AND. nPosCodCP <> 0 .AND.  nPosLojCP <> 0

	        If aCabOportu[nPosTpCP][2] == "1"
	        	aCabOportu[nPosCodCP][1] := "AD1_CODCLI"
	        	aCabOportu[nPosLojCP][1] := "AD1_LOJCLI"	        	
	        ElseIf aCabOportu[nPosTpCP][2] == "2"
	      		aCabOportu[nPosCodCP][1] := "AD1_PROSPE"
	        	aCabOportu[nPosLojCP][1] := "AD1_LOJPRO"
	        EndIf

	        If nPosCodCP > nPosLojCP 
	        	aTroca := aCabOportu[nPosCodCP]
	        	aCabOportu[nPosCodCP] := aCabOportu[nPosLojCP]
	        	aCabOportu[nPosLojCP] := aTroca
	        EndIf

	        ADel(aCabOportu,nPosTpCP)

	        If nPosNomCP <> 0
	        	ADel(aCabOportu,nPosNomCP)
	        	ASize(aCabOportu,Len(aCabOportu)-2)
	        Else
	        	ASize(aCabOportu,Len(aCabOportu)-1)
	        EndIf
		Else
			MntCliPro(oJson, @aCabOportu)
        EndIf   

    Else
        aAdd(aCabOportu,{"AD1_NROPOR" ,cChave     ,Nil})
        aAdd(aCabOportu,{"AD1_NROPOR" ,"Exclusao" ,Nil})
    Endif
    
    nPosOpor := (aScan(aCabOportu ,{|x| AllTrim(x[1]) == "AD1_NROPOR"}))
    DbSelectArea("AD1")
    dbSetOrder(1)
    If (nOpc == 4 .OR. nOpc == 5) .AND. DbSeek(cFilial+aCabOportu[nPosOpor][2])
    	If AD1->AD1_STATUS $ "2|9"
    		lRet := .F.
    		oApiManager:SetJsonError("400","Oportunidade Encerrada","Esta oportunidade já foi finalizada e não pode ser alterada/excluida.",/*cHelpUrl*/,/*aDetails*/)
    	EndIf
    EndIf
    	
    If lRet
    	MSExecAuto({|x,y|FATA300(x,y)},nOpc,aCabOportu) 	
	   If lMsErroAuto
	        aMsgErro := GetAutoGRLog()
	        cResp	 := ""
	        For nX := 1 To Len(aMsgErro)
	            cResp += StrTran( StrTran( aMsgErro[nX], "<", "" ), "-", "" ) + (" ")
	        Next nX	
	        lRet := .F.
	        oApiManager:SetJsonError("400","Erro durante Inclusão/Alteração/Exclusão do Oportunidade!.", cResp,/*cHelpUrl*/,/*aDetails*/)
	    EndIf
    EndIf

    aSize(aMsgErro,0)
    aSize(aCabOportu,0)    

Return lRet

/*/{Protheus.doc} GetAD1
Realiza o Get dos Oportunidades

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param Self			, Objeto	, Objeto Restful
@return lRet	   		, Lógico	, Retorna se conseguiu ou não processar o Get.

@author	Squad Faturamento/CRM
@since		08/10/2018
@version	12.1.21
/*/

Static Function GetAD1(oApiManager, Self)

	Local aFatherAlias	:=  {"AD1","items", "items"}
	Local cIndexKey		:=  " AD1_FILIAL, AD1_NROPOR, AD1_REVISA "
   	Local lRet          	:=  .T.

	If Len(oApiManager:GetApiRelation()) == 0
		DefRelation(@oApiManager)
	EndIf
	
	aQuery := MntQueryPri()
	
	oApiManager:setQuery(aQuery[1],aQuery[2],aQuery[3])
	
	aQuery := MntQueryCP()
	
	oApiManager:setQuery(aQuery[1],aQuery[2],aQuery[3])

	lRet := GetMain(@oApiManager, Self:aQueryString, aFatherAlias, , cIndexKey)

Return lRet

/*/{Protheus.doc} DefRelation
Realiza o relacionamento da Estrutura

@param      oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@return     Nil         	, Nulo

@author	Squad Faturamento/CRM
@since		08/10/2018
@version	12.1.21
/*/

Static Function DefRelation(oApiManager)

	Local aRelation    	:=	{{"AD1_FILIAL", "AD1_FILIAL"},{"AD1_NROPOR", "AD1_NROPOR"},{"AD1_REVISA", "AD1_REVISA"}}
	Local aRelatCtt    	:=	{{"U5_CODCONT", "U5_CODCONT"}}
	Local aRelCtxCt    	:=	{{"U5_FILIAL", "U5_FILIAL"},{"U5_CODCONT", "U5_CODCONT"}}
	Local aFatherAlias	:=	{"AD1",	"items",							"items"}
	Local aLstConsum   	:= 	{"AD1",	"ListofConsumer",					"ListofConsumer"}
	Local aLstContat   	:= 	{"SU5",	"ListOfContacts",					"ListOfContacts"}	
	Local aChiCmnInf		:=	{"SU5",	"CommunicationInformation", 	"CommunicationInformation"}
	Local aChiCtcAds   	:= 	{"SU5",	"ContactInformationAddress",	"ContactInformationAddress"}
	Local aChiCity		:=	{"SU5",	"City", 							"City"}
	Local aChiState		:=	{"SU5",	"State",							"StateCtt"}
	Local aChiCountr		:=	{"SU5",	"Country",							"Country"}
	Local cIndexKey		:=	"AD1_FILIAL, AD1_NROPOR, AD1_REVISA"
	Local cIndCtxCt		:=	"U5_FILIAL, U5_CODCONT"

	oApiManager:SetApiRelation(aLstConsum,		aFatherAlias,		aRelation, cIndexKey)
	oApiManager:SetApiRelation(aLstContat,		aFatherAlias,		aRelatCtt, cIndCtxCt)
	oApiManager:SetApiRelation(aChiCmnInf,		aLstContat,		aRelCtxCt, cIndCtxCt)
	oApiManager:SetApiRelation(aChiCtcAds,		aLstContat,		aRelCtxCt, cIndCtxCt)
	oApiManager:SetApiRelation(aChiCity,		aChiCtcAds,		aRelCtxCt, cIndCtxCt)
	oApiManager:SetApiRelation(aChiState,		aChiCtcAds,		aRelCtxCt, cIndCtxCt)
	oApiManager:SetApiRelation(aChiCountr,		aChiCtcAds,		aRelCtxCt, cIndCtxCt)

    oApiManager:SetApiMap(ApiMapAD1())

Return Nil

/*/{Protheus.doc} GetMain
Realiza o Get dos Oportunidades

@param oApiManager	, Objeto	, Objeto ApiManager inicializado no método 
@param aQueryString	, Array		, Array com os filtros a serem utilizados no Get
@param aFatherAlias	, Array		, Dados da tabela pai
@param lHasNext		, Logico	, Informa se informação se existem ou não mais paginas a serem exibidas
@param cIndexKey		, String	, Índice da tabela pai
@return lRet	    	, Lógico	, Retorna se conseguiu ou não processar o Get.

@author	Squad Faturamento/CRM
@since		08/10/2018
@version	12.1.21
/*/

Static Function GetMain(oApiManager, aQueryString, aFatherAlias, lHasNext, cIndexKey)

	Local aRelation 		:= {}
	Local aChildrenAlias	:= {}
	Local lRet 			:= .T.

	Default cIndexKey		:= ""
	Default aQueryString	:={,}
	Default oApiManager	:= Nil
	Default lHasNext		:= .T.

	lRet := ApiMainGet(@oApiManager, aQueryString, aRelation , aChildrenAlias, aFatherAlias, cIndexKey, oApiManager:GetApiAdapter(), oApiManager:GetApiVersion(), lHasNext)

	FreeObj( aRelation )
	FreeObj( aChildrenAlias )
	FreeObj( aFatherAlias )

Return lRet

/*/{Protheus.doc} ApiMapAD1
Estrutura a ser utilizada na classe ServicesApiManager

@return     aApiMap , Array , Array com estrutura 

@author	Squad Faturamento/CRM
@since		08/10/2018
@version	12.1.21
/*/

Static Function ApiMapAD1()

	Local aApiMap			:=	{}
	Local aStruct			:=	{}
	Local aStrAD1			:=	{}
	Local aStrConsum		:=	{}
	Local aStrLstCtt		:=	{}
	Local aStrComInf		:=	{}
	Local aStrCttInf		:=	{}
	Local aStrCity		:=	{}
	Local aStrTState		:=	{}
	Local aStrCountry		:=	{}	

	aStrAD1 :=			{"AD1","field","items","items",;
		{;
			{"BranchId"						,"AD1_FILIAL"												},;
			{"CompanyInternalId"				,""															},;
			{"InternalId"       	    		,"AD1_FILIAL, AD1_NROPOR"								},;
			{"Code"              	       ,"AD1_NROPOR"												},;
			{"Review"							,"AD1_REVISA"												},;
			{"Description"					,"AD1_DESCRI"												},;
			{"Seller"							,"AD1_VEND"												},;
			{"SellerName"						,""															},;
			{"StartDate"						,"AD1_DTINI"												},;
			{"ClosingDate"					,"AD1_DTFIM"												},;
			{"Process"							,"AD1_PROVEN"												},;
			{"Stage"							,"AD1_STAGE"												},;
			{"Notes"							,"AD1_MEMO"												},;
			{"Currency"						,"AD1_MOEDA"												},;
			{"Priority"						,"AD1_PRIOR"												},;
			{"SuccessFactor"					,"AD1_FCS"													},;
			{"FailureFactor"					,"AD1_FCI"													},;
			{"Status"							,"AD1_STATUS"												},;
			{"Ending"							,"AD1_ENCERR"												},;
			{"Reason"							,"AD1_MTVENC"												},;
			{"DateSignature"					,"AD1_DTASSI"												},;
			{"Comments"						,"AD1_OBSPRO"												};
		},;
	}
	
	aStrConsum :=		{"AD1","field","ListofConsumer","ListofConsumer",;
		{;
	       {"ConsumerType"					,"TIPOCLI"													},;
	       {"ConsumerId"						,"CODCP"													},;
	       {"ConsumerUnit"					,"LOJCP"													},;
	       {"ConsumerName"					,"NOMECP"				  									};
       },;
    }

    aStrLstCtt :=		{"SU5","item","ListOfContacts","ListOfContacts",;
		{;
			{"ContactInformationCode"		,"U5_CODCONT"												},;
			{"ContactInformationInternalId"	,"U5_FILIAL, U5_CODCONT"									},;
			{"ContactInformationTitle"		,"U5_CONTAT"												},;
			{"ContactInformationName"		,"U5_CONTAT"												},;
			{"ContactInformationDepartment"	,""															};
		},;
	}	

    aStrComInf :=		{"SU5","field","CommunicationInformation","CommunicationInformation",;
		{;
           {"PhoneNumber"					,"U5_FONE"													},;
           {"PhoneExtension"				,""															},;
           {"FaxNumber"						,"U5_FAX"													},;
           {"FaxNumberExtension"			,""															},;
           {"HomePage"						,"U5_URL"													},;
           {"Email"							,"U5_EMAIL"												};
        },;
	}

    aStrCttInf :=		{"SU5","field","ContactInformationAddress", "ContactInformationAddress",;
        {;
           {"Address"						,"U5_END"													},;
           {"Number"							,""															},;
           {"Complement"						,""															},;
           {"District"						,"U5_BAIRRO"												},;
           {"ZIPCode"						,"U5_CEP"													},;
           {"Region"							,""  														},;								
           {"POBox"							,""															};
        },;
    }

    aStrCity :=		{"SU5","field","City","City",;
		{;
			{"cityCode"						,"" 						       						},;
			{"cityInternalId"					,""		        											},;
			{"cityDescription"				,"U5_MUN"													};
		},;
	}

    aStrTState := 	 {"SU5","field","State","StateCtt",;
        {;
        	{"stateId"							,"U5_EST"													},;
        	{"stateInternalId"				,"U5_EST"													},;
        	{"stateDescription"				,""															};
        },;
    }

    aStrCountry :=	  {"SU5","field","Country","Country",;
        {;
            {"countryCode"					,"U5_PAIS"												    },;
            {"countryInternalId"			,"U5_PAIS"												    },;
            {"countryDescription"			,""														    };
        },;
    }

	aStruct := {aStrAD1,aStrConsum,aStrLstCtt,aStrComInf,aStrCttInf,aStrCity,aStrTState,aStrCountry}

	aApiMap := {"FATS300","items","1.000","FATS300",aStruct, "items"}

Return aApiMap

/*/{Protheus.doc} MntQueryPri
Monta a query principal

@return aQuery	 		, Array 	, Retorna um array de uma dimenssão com trés posições (Query,Order).

@author	Squad Faturamento/CRM
@since		08/10/2018
@version	12.1.21
/*/

Static Function MntQueryPri()

	Local aQuery	:= {}
	Local cQuery	:= ""
	Local cOrder	:= ""
	
	aAdd(aQuery, "items")
	
	cQuery := "SELECT "
	cQuery += "items.AD1_FILIAL, items.AD1_NROPOR, items.AD1_REVISA, items.AD1_DESCRI, items.AD1_VEND, "
	cQuery += "SA3.A3_NOME, "
	cQuery += "items.TIPOCLI, "
	cQuery += "items.CODCP, "
	cQuery += "items.LOJCP, "
	cQuery += "items.NOMECP, "
	cQuery += "items.AD1_DTINI, items.AD1_DTFIM, items.AD1_PROVEN, items.AD1_STAGE, items.AD1_CODMEM, items.AD1_MOEDA, items.AD1_PRIOR, items.AD1_FCS, items.AD1_FCI, "
	cQuery += "items.AD1_STATUS, items.AD1_ENCERR, items.AD1_MTVENC, items.AD1_DTASSI, items.AD1_OBSPRO, "
	cQuery += "ListOfContacts.U5_FILIAL, ListOfContacts.U5_CODCONT, ListOfContacts.U5_CONTAT, "
	cQuery += "CommunicationInformation.U5_FONE, CommunicationInformation.U5_FAX, CommunicationInformation.U5_URL, CommunicationInformation.U5_EMAIL, "
	cQuery += "ContactInformationAddress.U5_END, ContactInformationAddress.U5_BAIRRO, ContactInformationAddress.U5_CEP, "
	cQuery += "City.U5_MUN, "
	cQuery += "StateCtt.U5_EST, "
	cQuery += "Country.U5_PAIS, "
	cQuery += "items.AD1_CODMEM, "
	cQuery += "items.D_E_L_E_T_ "
	cQuery += "FROM (SELECT AD1.AD1_FILIAL, AD1.AD1_NROPOR, AD1.AD1_REVISA, AD1.AD1_DESCRI, AD1.AD1_VEND, AD1.D_E_L_E_T_, "
	cQuery += "(CASE WHEN AD1_LOJCLI <> ''	THEN '1' ELSE '2' END)  TIPOCLI, "
	cQuery += "(CASE WHEN AD1_CODCLI <> ''	THEN AD1_CODCLI ELSE AD1_PROSPE END)  CODCP, "
	cQuery += "(CASE WHEN AD1_LOJCLI <> ''	THEN AD1_LOJCLI ELSE AD1_LOJPRO END)  LOJCP, "
	cQuery += "(CASE WHEN AD1_LOJCLI <> ''	THEN A1_NOME ELSE US_NOME END)  NOMECP, "
	cQuery += "AD1.AD1_DTINI, AD1.AD1_DTFIM, AD1.AD1_PROVEN, AD1.AD1_STAGE, AD1.AD1_CODMEM, AD1.AD1_MOEDA, AD1.AD1_PRIOR, AD1.AD1_FCS, AD1.AD1_FCI, " 
	cQuery += "AD1.AD1_STATUS, AD1.AD1_ENCERR, AD1.AD1_MTVENC, AD1.AD1_DTASSI, AD1.AD1_OBSPRO, "
	cQuery += "AD1_CNTPRO "
	cQuery += "FROM " + RetSqlName("AD1") + " AD1 "
	cQuery += "LEFT JOIN SA1T10 SA1 ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.A1_COD = AD1.AD1_CODCLI AND SA1.D_E_L_E_T_ = '' "
	cQuery += "LEFT JOIN SUST10 SUS ON SUS.US_FILIAL = '"+xFilial("SUS")+"' AND SUS.US_COD = AD1.AD1_PROSPE AND SUS.D_E_L_E_T_ = '') items "
	cQuery += "LEFT JOIN SA3T10 SA3 ON SA3.A3_FILIAL = '"+xFilial("SA3")+"' AND SA3.A3_COD = items.AD1_VEND AND SA3.D_E_L_E_T_ = '' "
	cQuery += "LEFT JOIN SU5T10 ListOfContacts ON ListOfContacts.U5_FILIAL = '"+xFilial("SU5")+"' AND ListOfContacts.U5_CODCONT = items.AD1_CNTPRO AND ListOfContacts.D_E_L_E_T_ = '' "
	cQuery += "LEFT JOIN SU5T10 CommunicationInformation ON CommunicationInformation.U5_FILIAL = '"+xFilial("SU5")+"' AND CommunicationInformation.U5_CODCONT = items.AD1_CNTPRO AND CommunicationInformation.D_E_L_E_T_ = '' "
	cQuery += "LEFT JOIN SU5T10 ContactInformationAddress ON ContactInformationAddress.U5_FILIAL = '"+xFilial("SU5")+"' AND ContactInformationAddress.U5_CODCONT = items.AD1_CNTPRO AND ContactInformationAddress.D_E_L_E_T_ = '' "
	cQuery += "LEFT JOIN SU5T10 City ON City.U5_FILIAL = '"+xFilial("SU5")+"' AND City.U5_CODCONT = items.AD1_CNTPRO AND City.D_E_L_E_T_ = '' "
	cQuery += "LEFT JOIN SU5T10 StateCtt ON StateCtt.U5_FILIAL = '"+xFilial("SU5")+"' AND StateCtt.U5_CODCONT = items.AD1_CNTPRO AND StateCtt.D_E_L_E_T_ = '' "
	cQuery += "LEFT JOIN SU5T10 Country ON Country.U5_FILIAL = '"+xFilial("SU5")+"' AND Country.U5_CODCONT = items.AD1_CNTPRO AND Country.D_E_L_E_T_ = '' "
	
	aAdd(aQuery, cQuery)
	
	cOrder := "items.AD1_FILIAL, items.AD1_NROPOR, items.AD1_REVISA, items.AD1_DESCRI, items.AD1_VEND, "
	cOrder += "SA3.A3_NOME, "
	cOrder += "items.TIPOCLI, "
	cOrder += "items.CODCP, "
	cOrder += "items.LOJCP, "
	cOrder += "items.NOMECP, "
	cOrder += "items.AD1_DTINI, items.AD1_DTFIM, items.AD1_PROVEN, items.AD1_STAGE, items.AD1_CODMEM, items.AD1_MOEDA, items.AD1_PRIOR, items.AD1_FCS, items.AD1_FCI, "
	cOrder += "items.AD1_STATUS, items.AD1_ENCERR, items.AD1_MTVENC, items.AD1_DTASSI, items.AD1_OBSPRO, "
	cOrder += "ListOfContacts.U5_FILIAL, ListOfContacts.U5_CODCONT, ListOfContacts.U5_CONTAT, "
	cOrder += "CommunicationInformation.U5_FONE, CommunicationInformation.U5_FAX, CommunicationInformation.U5_URL, CommunicationInformation.U5_EMAIL, "
	cOrder += "ContactInformationAddress.U5_END, ContactInformationAddress.U5_BAIRRO, ContactInformationAddress.U5_CEP, "
	cOrder += "City.U5_MUN, "
	cOrder += "StateCtt.U5_EST, "
	cOrder += "Country.U5_PAIS, "
	cOrder += "items.AD1_CODMEM, "
	cOrder += "items.D_E_L_E_T_"
	
	aAdd(aQuery, cOrder)

Return aQuery

/*/{Protheus.doc} MntQueryCP
Monta a query de cliente/prospect

@return aQuery	 		, Array 	, Retorna um array de uma dimenssão com trés posições (Query,Order).

@author	Squad Faturamento/CRM
@since		08/10/2018
@version	12.1.21
/*/

Static Function MntQueryCP()

	Local aQuery	:= {}
	Local cQuery	:= ""
	Local cOrder	:= ""

	aAdd(aQuery, "ListofConsumer")
	
	cQuery := "SELECT "
	cQuery += "ListofConsumer.AD1_FILIAL,
	cQuery += "ListofConsumer.AD1_NROPOR,
	cQuery += "ListofConsumer.AD1_REVISA, ListofConsumer.AD1_DESCRI, ListofConsumer.AD1_VEND, "
	cQuery += "(CASE WHEN AD1_LOJCLI <> ''	THEN '1' ELSE '2' END)  TIPOCLI, "
	cQuery += "(CASE WHEN AD1_CODCLI <> ''	THEN AD1_CODCLI ELSE AD1_PROSPE END)  CODCP, "
	cQuery += "(CASE WHEN AD1_LOJCLI <> ''	THEN AD1_LOJCLI ELSE AD1_LOJPRO END)  LOJCP, "
	cQuery += "(CASE WHEN AD1_LOJCLI <> ''	THEN A1_NOME ELSE US_NOME END)  NOMECP "
	cQuery += "FROM " + RetSqlName("AD1") + " ListofConsumer "
	cQuery += "LEFT JOIN SA1T10 SA1 ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.A1_COD = ListofConsumer.AD1_CODCLI AND SA1.D_E_L_E_T_ = '' "
	cQuery += "LEFT JOIN SUST10 SUS ON SUS.US_FILIAL = '"+xFilial("SUS")+"' AND SUS.US_COD = ListofConsumer.AD1_PROSPE AND SUS.D_E_L_E_T_ = '' "
	
	aAdd(aQuery, cQuery)
	
	cOrder := "ListofConsumer.AD1_FILIAL, "
	cOrder += "ListofConsumer.AD1_NROPOR, "
	cOrder += "ListofConsumer.AD1_REVISA, ListofConsumer.AD1_DESCRI, ListofConsumer.AD1_VEND, "
	cOrder += "ListofConsumer.AD1_CODCLI, "
	cOrder += "ListofConsumer.AD1_LOJCLI, "
	cOrder += "ListofConsumer.AD1_PROSPE, "
	cOrder += "ListofConsumer.AD1_LOJPRO, "
	cOrder += "US_NOME, "
	cOrder += "A1_NOME"
	
	aAdd(aQuery, cOrder)

Return aQuery

/*/{Protheus.doc} MntCliPro
Monta a query de cliente/prospect
@param oJson		, Objeto	, Objeto JSON
@param aCliPro		, Array		, Array com os filtros a serem utilizados no Get
@author	Squad Faturamento/CRM
@since		17/12/2018
@version	12.1.21
/*/

Static Function MntCliPro( oJson , aCliPro )

	Local nType	:= 0

	If AttIsMemberOf(oJson, "ListofConsumer")

	Endif

Return Nil