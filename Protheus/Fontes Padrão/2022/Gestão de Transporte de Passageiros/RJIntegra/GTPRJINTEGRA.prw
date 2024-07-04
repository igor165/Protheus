#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "GTPRJINTEGRA.CH"

Static cSXBRet  := ""

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GtpRjIntegra

Classe para parametrizar a integração com os serviços disponibilizados pela RJ Consultores  

@type 		Class
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Class GtpRjIntegra from FWRest

// propriedades
Data oJson		   As Object
Data oXmlConf	   As Object
Data oGTPLog       As Object
Data oHashMap	   As Array
Data aHeader       As Array
Data aParam        As Array
Data aResult       As Array
Data aFldDePara	   As Array
Data aFldXXF       As Array
Data cIdServico    As Character
Data cHost         As Character
Data cPath         As Character
Data cUrl          As Character
Data cUser         As Character
Data cPswd         As Character
Data cParam        As Character
Data cJsonResult   As Character
Data cXmlConf      As Character
Data cMainList	   As Character
Data nLenMainItens As Numeric
Data lActive	   As Logical

// método
Method New(cHost, cPath, aHeader, aParam) CONSTRUCTOR
Method Destroy()
Method LoadFldDePara(nModulo)
Method SetPath(cPath)
Method SetaHeader(aHeader)
Method SetcHeader(cHeader)
Method SetParam(cParam, cConteudo)
Method SetServico(cIdServico, lGrid, nModulo)
Method SetXmlConf()
Method SetValue(oModel, cCampo, uValue, lOverWrite)
Method SetConnection()
Method Get()
Method GetResult()
Method GetUrl()
Method GetaHeader()
Method GetaParam()
Method GetcParam()
Method GetEmpRJ(cEmpresa, cFilPro)
Method GetFieldDePara() 
Method GetFldXXF()
Method GetLenItens()
Method GetJsonValue(nLine, cTagName, cTipo, cListPath)
Method GetAuthorization()
Method Activate()

EndClass

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New

Função new/construtora da classe GtpRjIntegra   

@type 		Method
@sample 	obj:New(cPath)
@param 	 	cPath, character - caminho para o serviço que será consumido
@return		Object - objeto da classe GtpRjIntegra
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method New(cPath, cIdServico) Class GtpRjIntegra

Default cPath      := ""
Default cIdServico := ""

cPath := TrataPath(cPath)

_Super:New('')

Self:oXmlConf	:= tXMLManager():New()
Self:cHost       := ""	
Self:cParam      := ""
Self:cPath       := ""
Self:cIdServico	 := cIdServico
Self:cUrl        := Self:cHost + Self:cPath
Self:aHeader     := {}
Self:aParam	     := {}
Self:cJsonResult := ""
Self:aResult     := {}
Self:oJson		 := tJsonParser():New()
Self:cUser       := ""
Self:cPswd       := ""
Self:oGTPLog     := GTPLog():New(/*cTitulo*/,.T./*lSalva*/,!IsBlind()/*lShow*/,/*cPath*/,/*cArquivo*/)
Self:nTimeOut    := GtpGetRules('INTTIMEOUT', .F., , "120")

Self:SetPath(cPath)

Self:SetConnection()

Self:SetcHeader("Content-Type: application/json; charset=UTF-8")
Self:SetcHeader("Accept: application/json")
Self:SetcHeader("User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")
Self:SetcHeader(Self:GetAuthorization())
	
Self:aFldDePara	:= {}
Self:aFldXXF    := {}

If !Empty(Self:cIdServico)
	Self:SetXmlConf(GetXmlStruct(Self:cIdServico))
	Self:oXmlConf:Parse(Self:cXmlConf)
	Self:LoadFldDePara()
EndIf

Return Self

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Destroy

Função destroy/destrutora da classe GtpRjIntegra   

@type 		Method
@sample 	obj:Destroy(cPath)
@param 	 	
@return		
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method Destroy() Class GtpRjIntegra

GTPDestroy(Self:oJson)
GTPDestroy(Self:oXmlConf)
GTPDestroy(Self)

Return Nil

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadFldDePara

Função que lê o XML de configuração do serviço e monta o ARRAY de DE/PARA   

@type 		Method
@sample 	obj:LoadFldDePara()
@param 	 	
@return		
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method LoadFldDePara(nModulo) Class GtpRjIntegra

Local cTagFields   := "/RJIntegra/" + Self:cIdServico + "/ListOfFields"
Local cListOfFld   := "" 
Local cTagName	   := ""
Local cCampo	   := ""
Local cTipo		   := ""
Local nFields	   := 0
Local nXXFList     := 0 
Local n1		   := 0
Local n2           := 0
Local nTam		   := 0
Local nDec		   := 0
Local lOnlyInsert  := .F.
Local lOverWrite   := .T.
Local aFldSeek     := {}

Local cXXF_Alias   := ""
Local cXXF_Field   := ""
Local cXXF_Collumn := ""
Local cXXF_Indice  := ""

Default nModulo	   := 88

aSize(Self:aFldDePara, 0)
aSize(Self:aFldXXF, 0)

Self:cMainList := AllTrim(Self:oXmlConf:XPathGetAtt("/RJIntegra/" + Self:cIdServico, "tagMainList"))

If (nFields	:= Self:oXmlConf:xPathChildCount(cTagFields)) > 0
	For n1 := 1 To nFields
		cListOfFld := cTagFields + "/Field[" + cValToChar(n1) + "]"
		cTagName    := AllTrim(Self:oXmlConf:XPathGetNodeValue(cListOfFld + "/tagName") )
		cCampo	    := AllTrim(Self:oXmlConf:XPathGetNodeValue(cListOfFld + "/fieldProtheus") )
		cTipo	    := GetSx3Cache(cCampo, "X3_TIPO")
		nTam	    := GetSx3Cache(cCampo, "X3_TAMANHO")
		nDec	    := GetSx3Cache(cCampo, "X3_DECIMAL")
		lOnlyInsert := AllTrim(Self:oXmlConf:XPathGetNodeValue(cListOfFld + "/onlyInsert")) == "True"
		lOverWrite  := AllTrim(Self:oXmlConf:XPathGetNodeValue(cListOfFld + "/overwrite")) == "True"
		
		If AllTrim(GetSx3Cache(cCampo, "X3_CAMPO")) == cCampo .And. X3Uso(GetSx3Cache(cCampo, "X3_USADO"), nModulo)
			aAdd(Self:aFldDePara, {cTagName, cCampo, cTipo, nTam, nDec, lOnlyInsert, lOverWrite})
				
			If Self:oXmlConf:XPathHasNode(cListOfFld + '/DeParaXXF')
				cXXF_Alias   := AllTrim(Self:oXmlConf:XPathGetNodeValue(cListOfFld + "/DeParaXXF/Alias"))
				cXXF_Field   := AllTrim(Self:oXmlConf:XPathGetNodeValue(cListOfFld + "/DeParaXXF/XXF_Field"))
				cXXF_Collumn := AllTrim(Self:oXmlConf:XPathGetNodeValue(cListOfFld + "/DeParaXXF/ColumnNumber"))
				cXXF_Indice  := AllTrim(Self:oXmlConf:XPathGetNodeValue(cListOfFld + "/DeParaXXF/IndiceOrder"))
				
				aSize(aFldSeek, 0)
				If (nXXFList :=  Self:oXmlConf:xPathChildCount(cListOfFld + '/DeParaXXF/ListOfSeekField')) > 0
					For n2 := 1 To nXXFList
						aAdd(aFldSeek, Self:oXmlConf:XPathGetNodeValue(cListOfFld + '/DeParaXXF/ListOfSeekField/SeekField[' + cValToChar(n2) + ']'))
					Next n2
				EndIf
				aAdd(Self:aFldXXF, {cCampo, cXXF_Alias, cXXF_Field, Val(cXXF_Collumn), Val(cXXF_Indice), aClone(aFldSeek)})
			EndIf
		EndIf
	Next n1
EndIf 

GTPDestroy(aFldSeek)

Return Nil

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetPath

Função que determina o caminho do serviço REST a ser consumido 

@type 		Method
@sample 	obj:SetPath(cPath)
@param 	 	cPath, character - caminho (URI) do serviço 
@return		 
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method SetPath(cPath) Class GtpRjIntegra
		
Default cPath	:= ""
	
If Right(cPath, 1) == '/'
	cPath := SubStr(cPath,1,Len(cPath)-1)
EndIf
	
If Left(cPath, 1) <> '/'
	cPath := '/' + cPath
EndIf
		
Self:cPath := cPath
Self:cUrl  := Self:cHost + Self:cPath + Self:cParam 
	
_Super:SetPath(cPath)

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetaHeader

Função que determina as definições da estrutura HEAD 

@type 		Method
@sample 	obj:SetaHeader(aHeader)
@param 	 	aHeader, array - lista de definições da estrutura HEAD 
@return		
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method SetaHeader(aHeader) Class GtpRjIntegra
	Self:aHeader := aClone(aHeader)
Return Nil

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetcHeader

Função que determina uma definição da estrutura HEAD 

@type 		Method
@sample 	obj:SetcHeader(aHeader)
@param 	 	cHeader, character - definição da estrutura HEAD 
@return		
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method SetcHeader(cHeader) Class GtpRjIntegra
	aAdd(Self:aHeader, cHeader)
Return Nil

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetParam

Função que determina os QueryParams necessários ao consumo de um serviço REST  

@type 		Method
@sample 	obj:SetParam(cParam, cConteudo)
@param 	 	cParam, character - nome do parâmetro que será passado na URL ao consumir o serviço 
			cConteudo, character - conteúdo do parâmetro que será utilizado com filtro 
@return		
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method SetParam(cParam, cConteudo) Class GtpRjIntegra

Local cParamAux   := ""

Default cParam	  := ""
Default cConteudo := ""
	
If !Empty(cParam) .And. !Empty(cConteudo)
	cParamAux := cParam + "=" + cConteudo
ElseIf !Empty(cParam) .And. Empty(cConteudo)
	cParamAux := cParam 
EndIf

If !Empty(cParamAux)
	aAdd(Self:aParam, {cParam, cConteudo})
		
	If Empty(Self:cParam)
		Self:cParam := cParamAux
	Else
		Self:cParam += "&" + cParamAux
	EndIf
		
	Self:cUrl := Self:cHost + Self:cPath +If(!Empty(Self:cParam),'?'+ Self:cParam ,'') 
EndIf

Return Nil

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetServico

Função que determina o serviço que será consumido pela classe   

@type 		Method
@sample 	obj:SetServico(cIdServico)
@param 	 	cIdServico, character - identificação do serviço que será consumido
			lGrid, logical - informa se é um submodelo (.T.) ou não (.F.)
			nModulo - Informa o modulo (opcional)
@return		
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method SetServico(cIdServico, lGrid, nModulo, cXmlAut) Class GtpRjIntegra

Default cIdServico := ""
Default lGrid      := .F.
Default nModulo	   := 88
Default cXmlAut    := ""
	
Self:cIdServico	:= cIdServico
	
If !lGrid .And. !Empty(Self:cIdServico)
	Self:SetXmlConf(GetXmlStruct(Self:cIdServico))
EndIf

If !Empty(Self:cIdServico)
	If EMPTY(cXmlAut)
		Self:oXmlConf:Parse(Self:cXmlConf)
	Else
		Self:oXmlConf:Parse(cXmlAut)
	EndIf
	Self:LoadFldDePara(nModulo)
EndIf
	
Return Nil

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetXmlConf

Função que guarda o XML de configuração do serviço que está sendo consumido 

@type 		Method
@sample 	obj:SetXmlConf(cXml)
@param 	 	cXml, character - lista de definições da estrutura HEAD 
@return		
@author 	thiago.tavares
@since 		07/05/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method SetXmlConf(cXml) Class GtpRjIntegra
	Self:cXmlConf := cXml
Return Nil

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetValue

Função que grava os valores consumidos nos respectivos campos do modelo   

@type 		Method
@sample 	obj:SetValue(oModel, cCampo, uValue, lOverWrite)
@param 	 	oModel, objeto - modelo de dados
			cCampo, character - campo que irá receber o valor 
			uValue, undefined - valor a ser gravado (seu tipo será igual ao do campo)
			lOverWrite, logical - determina se o valor deve ser sobreposto caso o campo já esteja preenchido
@return		
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method SetValue(oModel, cCampo, uValue) Class GtpRjIntegra
Return oModel:SetValue(cCampo, uValue)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetConnection

@author flavio.martins
@since 23/07/2019
@version 1.0
@type method
/*/
//------------------------------------------------------------------------------------------
Method SetConnection() Class GtpRjIntegra
Local oXml	:= tXMLManager():New()

oXml:Parse(GetXmlStruct('Conf'))

Self:cHost := AllTrim(oXml:XPathGetNodeValue("/Connection/host"))
Self:cUser := AllTrim(oXml:XPathGetNodeValue("/Connection/userauth"))
Self:cPswd := AllTrim(oXml:XPathGetNodeValue("/Connection/pswdauth"))

If Right(Self:cHost, 1) == '/'
	Self:cHost := SubString(Self:cHost, 1, Len(Self:cHost) - 1)
EndIf

GtpDestroy(oXml)

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Get

Função que executa o verbo GET de um serviço REST

@type 		Method
@sample 	obj:Get()
@param 	 	
@return		Logical - irá retornar sucesso (.T.) ou falha (.F.)
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method Get(cResultAuto) Class GtpRjIntegra

Local lRet	   := .T.//_Super:Get(Self:aHeader, Self:cParam)
Local nLenRes  := 0
Local nLenPars := 0

Default cResultAuto := ""

If Self:Activate(cResultAuto)
	If _Super:Get(Self:aHeader, Self:cParam) .OR. !(EMPTY(cResultAuto))
		
		Self:GetResult(cResultAuto)
		
		nLenRes := Len(Self:cJsonResult)
		
		If (lRet := Self:oJson:Json_Hash(Self:cJsonResult, nLenRes, Self:aResult, @nLenPars, @Self:oHashMap))
			If nLenRes > nLenPars
				lRet := .F.
				Self:oGTPLog:SetText(STR0001)	// "Falha ao realizar o parse do Json"	
			Else
				IF (Self:nLenMainItens := Len(Self:aResult[1][2][1][2]) - 1) < 0
					Self:oGTPLog:SetText(STR0002)	// "Nenhum registro encontrado."
				EndIf
			EndIf
		Endif
	Else
		Self:oGTPLog:SetText(Self:GetLastError())
		lRet := .F.
	Endif
Else
	lRet := .F.
Endif

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetResult

Função que retorna o último conteúdo valido retornado pela uma chamada ao verbo GET ou POST

@type 		Method
@sample 	obj:GetResult()
@param 	 	 
@return		Array - lista com as informações do serviço consumido 
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method GetResult(cResultAuto) Class GtpRjIntegra
	If EMPTY(cResultAuto)
		Self:cJsonResult := _Super:GetResult()
	Else
		Self:cJsonResult := cResultAuto
	EndIf
Return Self:cJsonResult 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetUrl

Função que retorna a URL do serviço que está sendo consumido  

@type 		Method
@sample 	obj:GetUrl()
@param 	 	 
@return		Character - caminho (URI) do serviço 
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method GetUrl() Class GtpRjIntegra
Return Self:cUrl

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetaHeader

Função que retorna uma lista de definições da estrutura HEAD 

@type 		Method
@sample 	obj:GetaHeader(aHeader)
@param 	 	 
@return		Array - lista de definições da estrutura HEAD
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method GetaHeader() Class GtpRjIntegra
Return Self:aHeader

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetaParam

Função que retorna os parâmetros necessários ao consumo de um serviço REST  

@type 		Method
@sample 	GetaParam()
@param 	 	 
@return		Array - lista de parâmetros
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method GetaParam() Class GtpRjIntegra
Return Self:aParam

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetcParam

Função que retorna um parâmetro utilizado para consumo do serviço  

@type 		Method
@sample 	GetcParam()
@param 	 	
@return		Character - string com o valor do parâmetro
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method GetcParam() Class GtpRjIntegra
Return Self:cParam

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetEmpRJ

Função que retorna a respectiva empresa após DE/PARA  

@type 		Method
@sample 	GetEmpRJ(cEmpresa, cFilPro)
@param		cEmpresa, character - código da empresa informado pela RJ 	 	
			cFilPro, character - código filial do Protheus
			cRetorno, character - determina a informação que será retornada
				'1' - recupera código Totalbus
				'2' - recupera código Protheus
@return		Character - código da empresa no Protheus
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method GetEmpRJ(cEmpresa, cFilpro, cCompa, cBranch, cRetorno, lExternal) Class GtpRjIntegra
Local aRetEmp	  := {}    
Local cRetEmp	  := ""
Local cReferencia := Padr('TOTALBUS', 15)

Default cEmpresa  := cEmpAnt
Default cFilpro   := cFilAnt
Default cCompa    := ""
Default cBranch   := ""
Default cRetorno  := "1" 
Default lExternal := .F.

cEmpresa := Padr(cEmpresa, 2)
cFilpro  := Padr(cFilpro, 12)

aRetEmp := FwEaiEmpFil(cCompa,cBranch,cReferencia, lExternal)

If Len(aRetEmp) > 0
    cRetEmp := aRetEmp[Val(cRetorno)]
Endif
Return cRetEmp

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetFieldDePara

Função que retorna a lista DE/PARA necessária ao consumo de um serviço REST  

@type 		Method
@sample 	obj:GetFieldDePara()
@param 	 	 
@return		Array - lista com o DE/PARA
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method GetFieldDePara() Class GtpRjIntegra
Return Self:aFldDePara

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetFieldDePara

Função que retorna a lista DE/PARA da tabela XXF necessária ao consumo de um serviço REST  

@type 		Method
@sample 	obj:GetFldXXF()
@param 	 	 
@return		Array - lista com o DE/PARA do XXF
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method GetFldXXF() Class GtpRjIntegra
Return Self:aFldXXF

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetLenItens

Função que retorna a quantidade de registros recebidos e que serão processados  

@type 		Method
@sample 	obj:GetLenItens()
@param 	 	 
@return		Integer - quantidade de registros recebidos
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method GetLenItens() Class GtpRjIntegra
Return Self:nLenMainItens

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetJsonValue

Função que retorna o valor de uma tag JSon  

@type 		Method
@sample 	obj:GetJsonValue()
@param 	 	nLine, integer - identificador do registro que está sendo recuperado do JSon
			cTagName, character - identificação da Tag JSon que terá o valor recuperado 
			cTipo, character - tipo do campo Protheus 
			cListPath, character - caminho para leitura do valor através do objeto HashMap
@return		uValue - valor 
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Method GetJsonValue(nLine, cTagName, cTipo, cListPath, lPrencCamp) Class GtpRjIntegra

Local cCaminho := ""
Local cPicture := ""
Local uValue   := Nil
Local nPosFld  := aScan(Self:aFldDePara, {|x| AllTrim(x[1]) == cTagName})

Default nLine		:= 0
Default cListPath 	:= ""
Default lPrencCamp	:= .T.

If !Empty(cListPath)
	cCaminho := cListPath
Else
	cCaminho := Self:cMainList
EndIf

If !HMGet(Self:oHashMap, cCaminho + '[' + cValToChar(nLine) + '].' + cTagName, uValue)
	Self:oGTPLog:SetText(I18n(STR0003, {cTagName}))		// "Variavel do campo #1 não encotrada na lista do resultado."
EndIf

uValue := GTPCastType(uValue, cTipo)
If lPrencCamp .AND. nPosFld > 0
	cPicture := X3Picture(Self:aFldDePara[nPosFld][2])
EndIf

If lPrencCamp .AND. nPosFld > 0 .AND. Self:aFldDePara[nPosFld][3] == "C" .AND. (Len(uValue) > Len(cPicture) .AND. Len(uValue) > Self:aFldDePara[nPosFld][4])
	uValue := SubStr(uValue, 1, Self:aFldDePara[nPosFld][4])
EndIf

Return uValue

/*/{Protheus.doc} Activate
//TODO Descrição auto-gerada.
@author flavio.martins
@since 23/07/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Method Activate(cResultAuto) Class GtpRjIntegra
Local lRet	:= .T.

Default cResultAuto := ""

If Empty(Self:cHost)
	Self:oGTPLog:SetText(STR0004) // "Host não informado, verifique o arquivo de configuração.")
	lRet := .F.
Endif

If Empty(Self:cUser)
	Self:oGTPLog:SetText(STR0005) // "Usuário de autenticação não informado, verifique o arquivo de configuração.")
	lRet := .F.
Endif

If Empty(Self:cPswd)
	Self:oGTPLog:SetText(STR0006) // "Senha de autenticação não informada, verifique o arquivo de configuração.")
	lRet := .F.
Endif

If Empty(Self:cPath)
	Self:oGTPLog:SetText(STR0007) // "Caminho para os Xml's de configuração não encontrado, verifique o parâmetro XMLCONFRJ.")
	lRet := .F.
Endif

If !EMPTY(cResultAuto)
	lRet := .T.
EndIf	

Self:lActive := lRet 

Return lRet


/*/{Protheus.doc} GetAuthorization
Metodo que retorna informação de acesso para serviços que exigem autenticação
@author flavio.martins
@since 23/07/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Method GetAuthorization() Class GtpRjIntegra 
Return "Authorization: Basic " + Encode64(Self:cUser + ":" + Self:cPswd)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetXmlStruct

Função que retorna o XML de configuração     

@type 		Function
@sample 	GetXmlStruct()
@param 	 	
@return		Character - XML de configuração 
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GetXmlStruct(cIdServico)

Local cParm		:= GTPGetRules('PARCONFRJ', .F., Nil, "StartPath")
Local cPath		:= GTPGetRules('XMLCONFRJ', .F., Nil, "rjintegra\conf")
Local cArq		:= cIdServico + '.xml'
Local cArqConf	:= GetSrvProfString(cParm, '') + TrataPath(cPath, .F.) + cArq
Local cXml		:= ""
Local nHandle 	:= 0
Local nLength 	:= 0

If File(cArqConf)
	nHandle := FOpen(cArqConf, FO_READ)
	nLength := FSeek(nHandle, 0, 2)    
	FSeek(nHandle, 0)
	FRead(nHandle, @cXml, nLength)
	FClose(nHandle)
EndIf

Return cXml

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TrataPath

Função que trata a URL do serviço a ser consumido 

@type 		Function
@sample 	TrataPath(cPath, lPre, lPos)
@param 	 	cPath, character - caminho a ser tratado
			lPre, logical    - determina se o início do caminho deve ser tratado (.T.) ou não (.F.) 
			lPre, logical    - determina se o final do caminho deve ser tratado (.T.) ou não (.F.) 
@return		Character - caminho tratado 
@author 	jacomo.fernandes
@since 		26/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function TrataPath(cPath, lPre, lPos)

Default cPath := ""
Default lPre  := .T.
Default lPos  := .T.

If lPre .And. Left(cPath, 1) <> '/'
	cPath := '/' + cPath
EndIf

If lPos .And. Right(cPath, 1) <> '/'
	cPath += '/'
EndIf

Return cPath


//------------------------------------------------------------------------------
/* /{Protheus.doc} GtpXBRjEmp

@type Function
@author 
@since 05/08/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GtpGetRjEmp()
Local lRet      := .F.
Local aRetorno  := {}
Local cQuery    := ""          
Local oLookUp   := Nil

cQuery := " select DISTINCT XXD_COMPA from XXD WHERE D_E_L_E_T_ ='' "

oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), {"XXD_COMPA"})
                                                        
oLookUp:AddIndice("Emp TotalBus"		, "XXD_COMPA")

If oLookUp:Execute()
	lRet       := .T.
	aRetorno   := oLookUp:GetReturn()
	cSXBRet := aRetorno[1]
EndIf   

FreeObj(oLookUp)

GTPDestroy(aRetorno)

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} GtpXBRjEmp

@type Function
@author 
@since 05/08/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GtpRetRjEmp()
Local cRet  := cSXBRet
Return cRet



//------------------------------------------------------------------------------
/* /{Protheus.doc} GtpGetXXF

@type Function
@author 
@since 05/08/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GtpGetXXF()
Local lRet      := .F.
Local aRetorno  := {}
Local cQuery    := ""          
Local oLookUp   := Nil

cQuery := " SELECT XXF.XXF_EXTVAL, GI6.GI6_CODIGO, GI6.GI6_DESCRI "
cQuery += " FROM "+RetSqlName('GI6')+" GI6 "
cQuery += " 	INNER JOIN XXF ON "
cQuery += " 		XXF_ALIAS = 'GI6' "
cQuery += " 		AND XXF_INTVAL =  '"+cEmpAnt+"|'||RtRIM(GI6_FILIAL)||'|'||RTRIM(GI6.GI6_CODIGO) || REPLICATE(' ',DATALENGTH(XXF_INTVAL) - LEN(XXF_INTVAL)) "
cQuery += " 		AND XXF.D_E_L_E_T_ = REPLICATE(' ',DATALENGTH(XXF.D_E_L_E_T_))  "
cQuery += " WHERE "
cQuery += " 	GI6_FILIAL = '"+xFilial('GI6')+"' "
cQuery += " 	AND GI6.D_E_L_E_T_ = REPLICATE(' ',DATALENGTH(GI6.D_E_L_E_T_))  "
cQuery += " ORDER BY REPLICATE(' ', DATALENGTH(XXF_INTVAL) - LEN(XXF_EXTVAL)) || RTRIM(LTRIM(XXF_EXTVAL)) , GI6.GI6_CODIGO "

cQuery := ChangeQuery(cQuery)

oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), {"XXF_EXTVAL"})
                                                        
oLookUp:AddIndice("Agência TotalBus"		, "XXF_EXTVAL")
oLookUp:AddIndice("Agência Protheus"		, "GI6_CODIGO")
oLookUp:AddIndice("Nome Agência"			, "GI6_DESCRI")

If oLookUp:Execute()
	lRet       := .T.
	aRetorno   := oLookUp:GetReturn()
	cSXBRet := aRetorno[1]
EndIf   

GTPDestroy(aRetorno)

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} GtpRetXXF

@type Function
@author 
@since 05/08/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GtpRetXXF()
Local cRet  := cSXBRet
Return cRet
