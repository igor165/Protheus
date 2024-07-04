#include "totvs.ch"
#include "RESTFUL.ch"
#include "OFJDDTF.ch"

#DEFINE lDebug .f.

Function OFJDDTF()
Return

Class OFJDDTF

	Data oSoConfig

	Data cToken
	Data cUser
	Data cPassword
	Data cUserVAI
	Data cPasswdVAI
	Data cDealerAccount

	Data lOkta
	Data lParamCheck

	Data oOkta as OBJECT
	data _OKTA
	data _oOkta

	Data cWSDL
	Data cURLWebService
	Data cNameHeaderToken

	Data lInitProp

	Data oRest as OBJECT
	Data oJsonResult as Object
	Data oOFDTFRequest as Object
	Data _auxProfile

	Method New() CONSTRUCTOR

	Method getDTFList_Service()
	Method getDTFDownload_Service()
	Method getDTFPut_Service()

	Method chekDTFListService()
	Method chekDTFDownloadService()
	Method chekDTFPutService()

	Method setAuthentication()
	Method getError()

EndClass

/*/{Protheus.doc} New
		Construtor Simples

	@type function
	@author Jose Luis
	@since 10/08/2021
/*/
Method New(cMethod) Class OFJDDTF
	Local cHost := ""
	Private oDTFConfig := OFJDDTFConfig():New()
	Default cMethod := ""

	oDTFConfig:GetConfig()
	
	self:cURLWebService := "dbs/dealer/" // testar

	self:oRest := FWRest():New(cHost)
	self:oJsonResult := JsonObject():New()

	self:cNameHeaderToken := "JDK_TOKEN"

	self:lInitProp := .t.
	self:lParamCheck := .f.

	self:_oOkta := OFJDOkta():New()
	if cMethod == 'GET'
		self:_OKTA := self:_oOkta:oConfig:DTFGETAPI()
		if self:_OKTA
			self:_oOkta:SetDTFGETAPI()
			cHost := self:_oOkta:oConfig:getUrlWSDTFGETAPI()
		endif
	ElseIF  cMethod == 'PUT'
		self:_OKTA := self:_oOkta:oConfig:DTFPUTAPI()
		if self:_OKTA
			self:_oOkta:SetDTFPUTAPI()
			cHost := self:_oOkta:oConfig:getUrlWSDTFPUTAPI()
		endif
	Else
		Return .f.
	endif

Return SELF
/*/{Protheus.doc} setAuthentication
	Checa autenticação Okta

	@type function
	@author Jose Luis
	@since 23/09/2021
/*/
Method setAuthentication() class OFJDDTF

	Local cToken := ""
	Local lRetorno := .t.

	if self:_OKTA
		cToken := self:_oOkta:getToken()
		If Empty(cToken)
			lRetorno := .f.
		EndIf
	endif

Return lRetorno

/*/{Protheus.doc} getError
	Lista erros API
	@type function
	@author Jose Luis
	@since 23/09/2021
/*/

Method getError(cCodError,cVerb) class OFJDDTF

	Local cListError := ""
	if cVerb == "GET"

		Do Case
			Case cCodError == "404 DealerSetupNotFound"
				cListError := "Dealer’s Setup does not exist"
			Case cCodError == "404 FileNotFound"
				cListError := "Specified File does not exist."
			Case cCodError == "403 NotReadble"
				cListError := "Unable to read the file."
			Case cCodError == "403 insufficient_scope"
				cListError := "Insufficient scope for this resource"
			Case cCodError == "500 ServiceUnavailable"
				cListError := "Unable to process your request"
			Otherwise
				cListError := "Erro Não catalogado"
		End Case
	Else
		Do Case
			Case cCodError == "400 FileAttachmentMissing"
				cListError := "File Attachment not found"
			Case cCodError == "404 Not Found"
				cListError := "No message available"
			Case cCodError == "404 DealerPathNotFound"
				cListError := "The specified dealer path doesn't exist: [Parent id]"
			Case cCodError == "409 FileAlreadyExists"
				cListError := "The specified file already exists"
			Case cCodError == "403 insufficient_scope"
				cListError := "Insufficient scope for this resource"
			Case cCodError == "500 FileIOException"
				cListError := "The specified file not able to write to the specified resource path"
			Otherwise
				cListError := "Erro Não catalogado"
		End Case

	EndIf
Return cListError

/*/{Protheus.doc} getDTFList_Service
	Get na Lista de arquivos

	@type function
	@author Jose Luis
	@since 23/09/2021
/*/
Method getDTFList_Service(cTipArc,cDirDTF,lO411) Class OFJDDTF

	Local aHeader := {}
	Local cRetFromJson
	Local lRetorno
	Local nPdtf := 1
	Local cAuxResult := ""
	Local cAccessToken := self:_oOkta:getToken()
	Local cDealerAcc := GetMV("MV_MIL0005")
	Local cHost := self:_oOkta:oConfig:getUrlWSDTFGETAPI()
	local oJsonResult := JsonObject():New()
	Local oOFDTFLog

	Default lO411 := .f.

	oOFDTFLog := OFDMSRequest():New()
	oOFDTFLog:SetTypeDTF()
	oOFDTFLog:SetOriginDBS()

	oDTFConfig:GetConfig()


	AADD(aHeader, "Authorization: Bearer " + cAccessToken )
	self:oRest:SetHost(cHost)
	self:oRest:setPath("dbs/dealer/"+cDealerAcc+"/files")
	self:oRest:setPostParams("")

	lRetorno := self:oRest:Get(aHeader)

	If lRetorno
		cAuxResult := self:oRest:GetResult()
		cRetFromJson := self:oJsonResult:FromJson(cAuxResult)
		if empty(cRetFromJson)
			oOFDTFLog:Set("VK5_MESSAG", "04")
			oOFDTFLog:Set("VK5_ORIKEY", FunName())
			oOFDTFLog:Set("VK5_REQHEA", aHeader[1])
			oOFDTFLog:Set("VK5_RESBOD", cAuxResult)
			oOFDTFLog:Set("VK5_RESHEA", cValToChar(self:oRest:GetLastError()))
			oOFDTFLog:Set("VK5_RESCOD", val(SubStr(self:oRest:GetLastError(),1,3) ) )
			oOFDTFLog:Save()
		endif

		If ValType(cRetFromJson) == "U"
			For nPdtf := 1 to len(self:oJsonResult['files'])
				self:_auxProfile :=  Array(len(self:oJsonResult['files']))

				IF lO411 .and. Alltrim(cDirDTF) == Alltrim(oDTFConfig:getNAO_CLASSIFICADOS())
					self:getDTFDownload_Service(self:oJsonResult['files'][nPdtf]['name'],Alltrim(cDirDTF),cAccessToken)
				Endif

				If Alltrim(cTipArc) $ Alltrim(self:oJsonResult['files'][nPdtf]['name'])
					self:getDTFDownload_Service(self:oJsonResult['files'][nPdtf]['name'],Alltrim(cDirDTF),cAccessToken)
				Endif

			Next
		Else
			lRetorno := .f.
		EndIf
	Else
		self:oJsonResult:FromJson(self:oRest:GetResult())

		cLogGRV := STR0001 + cValToChar(self:oRest:GetLastError()) +" "+  cValToChar(self:oJsonResult['error']) +" "+  cValToChar(self:oJsonResult['message']) +" "+;//"Não foi Possivel obter o FileList: "
			self:getError(cValToChar(self:oJsonResult['error']) +" "+  cValToChar(self:oJsonResult['message']),"GET")

		if empty(cRetFromJson)
			oOFDTFLog:Set("VK5_MESSAG", "04")
			oOFDTFLog:Set("VK5_ORIKEY", FunName())
			oOFDTFLog:Set("VK5_REQHEA", aHeader[1])
			oOFDTFLog:Set("VK5_RESBOD", cLogGRV)
			oOFDTFLog:Set("VK5_RESHEA", cValToChar(self:oRest:GetLastError()))
			oOFDTFLog:Set("VK5_RESCOD", val(SubStr(self:oRest:GetLastError(),1,3)))
			oOFDTFLog:Save()
		endif

		lRetorno := .f.

	EndIf

	If Empty(cAccessToken)

		lRetorno := .f.

		oOFDTFLog:Set("VK5_MESSAG", "04")
		oOFDTFLog:Set("VK5_ORIKEY", FunName())
		oOFDTFLog:Set("VK5_RESHEA", Alltrim(STR0002))//"Erro ao obter o Token do Okta."
		oOFDTFLog:Set("VK5_RESBOD", Alltrim(STR0003))//"Não foi possível obter o Token do Okta, verifique as configurações. "
		oOFDTFLog:Set("VK5_RESCOD", 000)
		oOFDTFLog:Save()

	Endif

	aSize(aHeader,0)

Return lRetorno

/*/{Protheus.doc} getDTFDownload_Service
	 Get no aquivo da lista

	@type function
	@author Jose Luis
	@since 23/09/2021
/*/
Method getDTFDownload_Service(aNomArq,cDirDTF,cAccessToken,lDbg) Class OFJDDTF

	Local aHeader := {}
	Local cRetFromJson
	Local lRetorno
	Local cAuxResult := ""
	Local cDealerAcc := GetMV("MV_MIL0005")
	Local nHandle := 00
	Local cHost := self:_oOkta:oConfig:getUrlWSDTFGETAPI()
	Local oOFDTFLog
	Local nTarq
	Local lRet := .f.
	Local cArqDel := ""
	Local cPatch
	Local cPatchTo
	Local lDel
	Default lDbg := .f.

	oOFDTFLog := OFDMSRequest():New()
	oOFDTFLog:SetTypeDTF()
	oOFDTFLog:SetOriginDBS()
	oDTFConfig:GetConfig()

	AADD(aHeader, "Authorization: Bearer " + cAccessToken )
	self:oRest:SetHost(cHost)
	self:oRest:setPath("dbs/dealer/"+cDealerAcc+"/files/"+aNomArq)
	self:oRest:setPostParams("")

	lRetorno := self:oRest:Get(aHeader)

	If lRetorno .or. lDbg
		cAuxResult := self:oRest:GetResult()
		nHandle := FCreate(Alltrim(cDirDTF)+alltrim(cDealerAcc)+"\"+aNomArq,0)
		FWrite(nHandle, cAuxResult)
		FClose(nHandle)

		if Right(aNomArq,4) == ".dtz"// extensão padrão arquivos compactados DTF.
			lRet := GzDecomp(Alltrim(cDirDTF) + alltrim(cDealerAcc)+"\"+ aNomArq,Alltrim(cDirDTF)+alltrim(cDealerAcc)+"\",)
			if lRet
				nTarq := len(aNomArq)-4
				oFile := FwFileReader():New(alltrim(cDirDTF)+alltrim(cDealerAcc)+"\"+Left(aNomArq,nTarq))
				if oFile:Open()
					cAuxResult := oFile:FullRead()
					oFile:Close()
					cArqDel := aNomArq
					aNomArq := Left(aNomArq,nTarq)
					cPatch   := alltrim(cDirDTF)+alltrim(cDealerAcc)+"\"+cArqDel
					cPatchTo := alltrim(cDirDTF)+"salva\"+cArqDel
					lDel := __CopyFile(cPatch, cPatchTo,,,.F.)
					if !IsSrvUnix()
						CHMOD( cPatch , 2,,.f. )
					Endif
					if lDel
						FERASE(cPatch)
					endif
				else
					cAuxResult := STR0009 //"Não foi possível abrir o arquivo."
				endif
			Else
				cAuxResult := STR0010 //"Não foi possível descompactar o arquivo."
			endif
		endif
		if len(cAuxResult) > 10000
			cAuxResult := STR0011 + alltrim(cDirDTF)+alltrim(cDealerAcc)//Tamanho do arquivo impede sua gravação em campo Memo. Arquivo disponivel no Diretorio: 
		Endif
		if empty(cRetFromJson)
			oOFDTFLog:Set("VK5_MESSAG", "05")
			oOFDTFLog:Set("VK5_ORIKEY", FunName())
			oOFDTFLog:Set("VK5_REQHEA", aHeader[1])
			oOFDTFLog:Set("VK5_REQBOD", Alltrim(cDirDTF)+alltrim(cDealerAcc)+"\" + aNomArq)
			oOFDTFLog:Set("VK5_RESBOD", cAuxResult)
			oOFDTFLog:Set("VK5_RESHEA", cValToChar(self:oRest:GetLastError()))
			oOFDTFLog:Set("VK5_RESCOD", val(SubStr(self:oRest:GetLastError(),1,3)))
			oOFDTFLog:Save()
		endif

	Else

		self:oJsonResult:FromJson(self:oRest:GetResult())

		cLogGRV := STR0004 + cValToChar(self:oRest:GetLastError()) +" "+;//"Não foi possivel obter o FileDownload: "
			cValToChar(self:oJsonResult['error']) +" "+ cValToChar(self:oJsonResult['message']) +" "+;
			self:getError(cValToChar(self:oJsonResult['error']) +" "+  cValToChar(self:oJsonResult['message']),"GET")

		if empty(cRetFromJson)
			oOFDTFLog:Set("VK5_MESSAG", "05")
			oOFDTFLog:Set("VK5_ORIKEY", FunName())
			oOFDTFLog:Set("VK5_REQHEA", aHeader[1])
			oOFDTFLog:Set("VK5_REQBOD", Alltrim(cDirDTF)+alltrim(cDealerAcc)+"\" + aNomArq)
			oOFDTFLog:Set("VK5_RESBOD", cLogGRV)
			oOFDTFLog:Set("VK5_RESHEA", Alltrim(cDirDTF)+alltrim(cDealerAcc)+"\" + aNomArq)
			oOFDTFLog:Set("VK5_RESCOD", val(SubStr(self:oRest:GetLastError(),1,3)))
			oOFDTFLog:Save()
		endif

		lRetorno := .f.

	EndIf

	aSize(aHeader,0)

Return lRetorno

/*/{Protheus.doc} getDTFPut_Service
	Put de arquivos

	@type function
	@author Jose Luis
	@since 23/09/2021
/*/
Method getDTFPut_Service(cDirDTF,lDbg) Class OFJDDTF

	Local aHeader := {}
	Local lRetorno := .f.
	Local cPostParms := ""
	Local cAccessToken := self:_oOkta:getToken()
	Local cDealerAcc := GetMV("MV_MIL0005")
	Local cData := ""
	Local cLogGRV := ""
	Local nUp := 1
	Local aNomArq :={}
	Local oOFDTFLog
	Local cHost := self:_oOkta:oConfig:getUrlWSDTFPUTAPI()
	Local cPatch
	Local cPatchTo
	Local lDel
	Default lDbg := .f.

	aNomArq := aNomArq := Directory(LoWer(alltrim(cDirDTF)+alltrim(cDealerAcc))+"\"+"*.*", "S",,.F.)

	For nUp := 1 to len(aNomArq)
		cData := ""
		cPostParms := ""
		oOFDTFLog := OFDMSRequest():New()
		oOFDTFLog:SetTypeDTF()
		oOFDTFLog:SetOriginDBS()
		oFile := FwFileReader():New(alltrim(cDirDTF)+alltrim(cDealerAcc)+"\"+aNomArq[nUp][1])

		If Right(aNomArq[nUp][1],5) ==".temp"
			Loop
		endif

		if oFile:Open()
			cData := oFile:FullRead()
			Aadd(aHeader , "Authorization: Bearer " + cAccessToken )
			Aadd(aHeader , 'Content-Type:  multipart/form-data; boundary=--------------------------699695784725676941504380')
			cPostParms := '----------------------------699695784725676941504380'
			cPostParms += CRLF
			cPostParms += 'Content-Disposition: form-data; name="file"; filename="'+aNomArq[nUp][1]+'"'
			cPostParms += CRLF
			cPostParms += 'Content-Type: application/octet-stream'
			cPostParms += CRLF
			cPostParms += CRLF
			cPostParms += cData
			cPostParms += CRLF
			cPostParms += '----------------------------699695784725676941504380--'
			//
			//		Quando POST, utilizar o esquema abaixo:
			//		Aadd(aHeader , "Authorization: Bearer " + cAccessToken )
			//		Aadd(aHeader , 'Content-Type:  multipart/form-data')
			//
			//		cPostParms += 'Content-Disposition: form-data; name="file"; filename="'+oFile:cfilename+'"'
			//
			self:oRest:SetHost(cHost)
			self:oRest:setPath("dbs/dealer/"+cDealerAcc+"/files")

			lRetorno := self:oRest:Put(aHeader,cPostParms)

			If cValToChar(self:oRest:GetLastError()) == "204 NoContent"
				lRetorno := .t.

				cLogGRV := oFile:cfilename+STR0005 //" transmitido com sucesso: "

				oOFDTFLog:Set("VK5_MESSAG", "06")
				oOFDTFLog:Set("VK5_ORIKEY", FunName())
				oOFDTFLog:Set("VK5_REQHEA", aHeader[1])
				oOFDTFLog:Set("VK5_REQBOD", Alltrim(oFile:cfilename))
				oOFDTFLog:Set("VK5_RESBOD", cLogGRV)
				If Alltrim("DPMEXT") $ cValtochar(Alltrim(aNomArq[nUp][1])) // devido arquivo DPM ser muito grande para gravar em campo Memo
					oOFDTFLog:Set("VK5_RESHEA", Alltrim(STR0006))//"Arquivo DPM"
				ElseIf Len(cData) > 9999
					oOFDTFLog:Set("VK5_RESHEA", Alltrim(STR0011)+alltrim(cDirDTF)+"salva\"+aNomArq[nUp][1])//"Tamanho do arquivo impede sua gravação em campo Memo. Arquivo disponivel no Diretorio: "
				Else
					oOFDTFLog:Set("VK5_RESHEA", Alltrim(cData))
				Endif
				oOFDTFLog:Set("VK5_RESCOD", val(SubStr(self:oRest:GetLastError(),1,3)))
				oOFDTFLog:Save()

			Else

				self:oJsonResult:FromJson(self:oRest:GetResult())

				cLogGRV := oFile:cfilename+STR0007 + cValToChar(self:oRest:GetLastError()) +" "+;
					cValToChar(self:oJsonResult['error']) +" "+  cValToChar(self:oJsonResult['message']) +" "+;
					self:getError(cValToChar(self:oJsonResult['error']) +" "+  cValToChar(self:oJsonResult['message']),"PUT")

				oOFDTFLog:Set("VK5_MESSAG", "06")
				oOFDTFLog:Set("VK5_ORIKEY", FunName())
				oOFDTFLog:Set("VK5_REQHEA", aHeader[1])
				oOFDTFLog:Set("VK5_REQBOD", Alltrim(oFile:cfilename))
				oOFDTFLog:Set("VK5_RESBOD", cLogGRV)
				If Alltrim("DPMEXT") $ cValtochar(Alltrim(aNomArq[nUp][1])) // devido arquivo DPM ser muito grande para gravar em campo Memo
					oOFDTFLog:Set("VK5_RESHEA", Alltrim(STR0006))//"Arquivo DPM"
				ElseIf Len(cData) > 9999
					oOFDTFLog:Set("VK5_RESHEA", Alltrim(STR0011)+alltrim(cDirDTF)+"salva\"+aNomArq[nUp][1])//"Tamanho do arquivo impede sua gravação em campo Memo. Arquivo disponivel no Diretorio: "
				Else
					oOFDTFLog:Set("VK5_RESHEA", Alltrim(cData))
				Endif

				oOFDTFLog:Set("VK5_RESCOD", val(SubStr(self:oRest:GetLastError(),1,3)))
				oOFDTFLog:Save()

			Endif

		Else

			oOFDTFLog:Set("VK5_MESSAG", "06")
			oOFDTFLog:Set("VK5_ORIKEY", FunName())
			oOFDTFLog:Set("VK5_REQHEA", aHeader[1])
			oOFDTFLog:Set("VK5_REQBOD", Alltrim(STR0008))
			oOFDTFLog:Set("VK5_RESBOD", cLogGRV)
			oOFDTFLog:Set("VK5_RESHEA", Alltrim(cData))
			oOFDTFLog:Set("VK5_RESCOD", val(SubStr(self:oRest:GetLastError(),1,3)))
			oOFDTFLog:Save()

		Endif

		oFile:Close()

		if lRetorno .OR. cValToChar(self:oRest:GetLastError()) == "409 Conflict" .or. lDbg
			cPatch   := alltrim(cDirDTF)+alltrim(cDealerAcc)+"\"+aNomArq[nUp][1]
			cPatchTo := alltrim(cDirDTF)+"salva\"+aNomArq[nUp][1]
			lDel := __CopyFile(cPatch, cPatchTo,,,.F.)
			if !IsSrvUnix()
				CHMOD( cPatch , 2,,.f. )
			Endif
			if lDel
				FERASE(cPatch,,.F.)
			endif
		Endif

	Next

	If Empty(cAccessToken)

		oOFDTFLog := OFDMSRequest():New()
		oOFDTFLog:SetTypeDTF()
		oOFDTFLog:SetOriginDBS()

		oOFDTFLog:Set("VK5_MESSAG", "06")
		oOFDTFLog:Set("VK5_ORIKEY", FunName())
		oOFDTFLog:Set("VK5_RESHEA", Alltrim(STR0002))
		oOFDTFLog:Set("VK5_RESBOD", Alltrim(STR0003))
		oOFDTFLog:Set("VK5_RESCOD", 000)
		oOFDTFLog:Save()

	Endif
	aSize(aHeader,0)

Return lRetorno

/*/{Protheus.doc} chekDTFListService
	Checa Funcionamento ListService

	@type function
	@author Jose Luis
	@since 23/09/2021
/*/
Method chekDTFListService() Class OFJDDTF

	Local aHeader := {}
	Local lRetorno
	Local cAccessToken := self:_oOkta:getToken()
	Local cDealerAcc := GetMV("MV_MIL0005")
	Local cHost := self:_oOkta:oConfig:getUrlWSDTFGETAPI()

	AADD(aHeader, "Authorization: Bearer " + cAccessToken )
	self:oRest:SetHost(cHost)
	self:oRest:setPath("dbs/dealer/"+cDealerAcc+"/files")
	self:oRest:setPostParams("")

	lRetorno := self:oRest:Get(aHeader)

	aSize(aHeader,0)

Return lRetorno

/*/{Protheus.doc} chekDTFDownloadService
	Checa Funcionamento DownloadService

	@type function
	@author Jose Luis
	@since 23/09/2021
/*/
Method chekDTFDownloadService() Class OFJDDTF

	Local aHeader := {}
	Local lRetorno
	Local cAccessToken := self:_oOkta:getToken()
	Local cDealerAcc := GetMV("MV_MIL0005")
	Local cHost := self:_oOkta:oConfig:getUrlWSDTFGETAPI()

	AADD(aHeader, "Authorization: Bearer " + cAccessToken )
	self:oRest:SetHost(cHost)
	self:oRest:setPath("dbs/dealer/"+cDealerAcc+"/files/check.txt")
	self:oRest:setPostParams("")

	lRetorno := self:oRest:Get(aHeader)

	if cValToChar(self:oRest:GetLastError()) == "404 NotFound"
		lRetorno := .t.
	Endif

	aSize(aHeader,0)

Return lRetorno

/*/{Protheus.doc} chekDTFPutService
	Checa Funcionamento PutService

	@type function
	@author Jose Luis
	@since 23/09/2021
/*/
Method chekDTFPutService() Class OFJDDTF

	Local aHeader := {}
	Local lRetorno := .f.
	Local cPostParms := ""
	Local cAccessToken := self:_oOkta:getToken()
	Local cDealerAcc := GetMV("MV_MIL0005")

	Local cHost := self:_oOkta:oConfig:getUrlWSDTFPUTAPI()

	Aadd(aHeader , "Authorization: Bearer " + cAccessToken )
	Aadd(aHeader , 'Content-Type:  multipart/form-data; boundary=--------------------------699695784725676941504380')

	cPostParms += '----------------------------699695784725676941504380'
	cPostParms += CRLF
	cPostParms += 'Content-Disposition: form-data; name="file"; filename=""'
	cPostParms += CRLF
	cPostParms += 'Content-Type: application/octet-stream'
	cPostParms += CRLF
	cPostParms += CRLF
	cPostParms += ""
	cPostParms += CRLF
	cPostParms += '----------------------------699695784725676941504380--'

	self:oRest:SetHost(cHost)
	self:oRest:setPath("dbs/dealer/"+cDealerAcc+"/files")

	lRetorno := self:oRest:Put(aHeader,cPostParms)

	If cValToChar(self:oRest:GetLastError()) == "400 BadRequest"
		lRetorno := .t.
	Endif

	aSize(aHeader,0)

Return lRetorno