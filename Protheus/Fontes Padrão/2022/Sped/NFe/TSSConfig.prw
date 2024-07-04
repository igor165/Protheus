#include 'protheus.ch' 
#include 'totvs.ch'
#include 'parmtype.ch'
#include 'TSSConfig.ch'
#include 'FILEIO.CH'
#DEFINE UID	"TSSCONFIG"
#DEFINE LOG_ERROR 	1
#DEFINE LOG_WARNING 2
#DEFINE LOG_INFO 	3
#DEFINE LOG_PRINT	4

static __lToken		:= GetSrvProfString("TOTVSTOKEN","0") == "1"
static __lInfo		:= GetSrvProfString("ERPLOGINFO", "0" ) == "1"
static __lWarning	:= GetSrvProfString("ERPLOGWARNING", "0" ) == "1"
static _lCheckAut
static _lCpoMod
static _cModelo		:= ""

//-------------------------------------------------------------------
/*/{Protheus.doc} getCfgEntidadeHash
Retorna uma chave gerada a partir de dados da entidade.

@param 		cTextoAdicional	- Texto adicional para ser acrescentado no Hash
@return	cHash				- MD5 dos dados da Entidade

@author  Ricardo Pierini
@since   18/03/2018
@version 12

/*/
//-------------------------------------------------------------------
function getHashCfgEntidade(cTextoAdicional)
local cHash := ""
local aTel	:= NfeGetTel(SM0->M0_TEL)

default 	cTextoAdicional	:= ""

lUsaGesEmp	:= iif(findFunction("FWFilialName") .And. findFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)

cHash		:= "TOTVS"
cHash		+= iiF(SM0->M0_TPINSC==2 .Or. empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
cHash		+= iiF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
cHash		+= AllTrim(SM0->M0_INSC)
cHash		+= AllTrim(SM0->M0_INSCM)
cHash		+= AllTrim(SM0->M0_NOMECOM)
cHash		+= iif(lUsaGesEmp,FWFilialName(),Alltrim(SM0->M0_NOME))
cHash		+= AllTrim(FisGetEnd(SM0->M0_ENDENT)[1])
cHash		+= AllTrim(FisGetEnd(SM0->M0_ENDENT)[3])
cHash		+= AllTrim(FisGetEnd(SM0->M0_ENDENT)[4])
cHash		+= AllTrim(SM0->M0_ESTENT)
cHash		+= AllTrim(SM0->M0_CEPENT)
cHash		+= AllTrim(SM0->M0_CODMUN)
cHash		+= "1058"
cHash		+= AllTrim(SM0->M0_BAIRENT)
cHash		+= AllTrim(SM0->M0_CIDENT)
cHash		+= aTel[2]
cHash		+= aTel[3]
cHash		+= FormatTel(SM0->M0_FAX)
cHash		+= UsrRetMail(RetCodUsr())
cHash		+= AllTrim(SM0->M0_NIRE)
cHash		+= Alltrim(SM0->M0_CODIGO) + alltrim(SM0->M0_CODFIL)
cHash		+= cTextoAdicional

cHash := MD5( cHash, 2 )

return cHash

//-------------------------------------------------------------------
/*/{Protheus.doc} getCfgEntidade
Retorno o codigo da Entidade no TSS.

@param cError	- Mensagem de Retorno em caso de falha na requisição

@return	Entidade	-	Codigo da Entidade

@author  Renato Nagib
@since   17/08/2015
@version 12

/*/
//--------------------------------------------------------------------
function getCfgEntidade(cError, cUrl)

	local aArea 		:= {}
	local cIdEnt	 	:= ""
	local lUsaGesEmp	:= .F.
	local lEnvCodEmp	:= .F.
	local oWS			:= nil
	local cHash			:= ""
	local cLastHash		:= ""
	local lRetHash		:= .F.
	local lRetLstHash	:= .F.
	local aTel			:= {}
	local cMsgError		:= ""

	default cError	:= ""
	default cUrl	:= getUrl()

	varSetUID(UID, .T.)

	cHash := getHashCfgEntidade(cUrl)

	if( type( "oSigamatX" ) == "U" )
		lRetHash 		:= varGetXD(UID, cHash, @cIdEnt )
		lRetLstHash	:= varGetXD(UID, "TSSLastHash", @cLastHash)
		if(  !lRetHash .or. cHash <> cLastHash)

			aArea 	:= getArea()
			lEnvCodEmp	:= getNewPar("MV_ENVCDGE",.F.)
			lUsaGesEmp	:= iif(findFunction("FWFilialName") .And. findFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)

			oWS := WsSPedAdm():New()
			aTel := NfeGetTel(SM0->M0_TEL)

			oWS:cUSERTOKEN				:= "TOTVS"
			oWS:oWSEMPRESA:cCNPJ		:= iiF(SM0->M0_TPINSC==2 .Or. empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
			oWS:oWSEMPRESA:cCPF			:= iiF(SM0->M0_TPINSC==1 .or. SM0->M0_TPINSC==3,SM0->M0_CGC,"")
			oWS:oWSEMPRESA:cIE			:= AllTrim(SM0->M0_INSC)
			oWS:oWSEMPRESA:cIM			:= AllTrim(SM0->M0_INSCM)
			oWS:oWSEMPRESA:cNOME		:= AllTrim(SM0->M0_NOMECOM)
			oWS:oWSEMPRESA:cFANTASIA	:= iif(lUsaGesEmp,FWFilialName(),Alltrim(SM0->M0_NOME))
			oWS:oWSEMPRESA:cENDERECO	:= AllTrim(FisGetEnd(SM0->M0_ENDENT)[1])
			oWS:oWSEMPRESA:cNUM			:= AllTrim(FisGetEnd(SM0->M0_ENDENT)[3])
			oWS:oWSEMPRESA:cCOMPL		:= AllTrim(FisGetEnd(SM0->M0_ENDENT)[4])
			oWS:oWSEMPRESA:cUF			:= AllTrim(SM0->M0_ESTENT)
			oWS:oWSEMPRESA:cCEP			:= AllTrim(SM0->M0_CEPENT)
			oWS:oWSEMPRESA:cCOD_MUN		:= AllTrim(SM0->M0_CODMUN)
			oWS:oWSEMPRESA:cCOD_PAIS	:= "1058"
			oWS:oWSEMPRESA:cBAIRRO		:= AllTrim(SM0->M0_BAIRENT)
			oWS:oWSEMPRESA:cMUN			:= AllTrim(SM0->M0_CIDENT)
			oWS:oWSEMPRESA:cCEP_CP		:= nil
			oWS:oWSEMPRESA:cCP			:= nil
			oWS:oWSEMPRESA:cDDD			:= aTel[2]
			oWS:oWSEMPRESA:cFONE		:= aTel[3]
			oWS:oWSEMPRESA:cFAX			:= FormatTel(SM0->M0_FAX)
			oWS:oWSEMPRESA:cEMAIL		:= UsrRetMail(RetCodUsr())
			oWS:oWSEMPRESA:cNIRE		:= AllTrim(SM0->M0_NIRE)
			oWS:oWSEMPRESA:dDTRE		:= SM0->M0_DTRE
			oWS:oWSEMPRESA:cNIT			:= iif(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
			oWS:oWSEMPRESA:cINDSITESP	:= ""
			oWS:oWSEMPRESA:cID_MATRIZ	:= ""

			if(lUsaGesEmp .And. lEnvCodEmp )
				oWS:oWSEMPRESA:CIDEMPRESA:= FwGrpCompany()+FwCodFil()

			endif

			oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
			oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"

			if( oWs:ADMEMPRESAS() )
				cIdEnt  := oWs:cADMEMPRESASRESULT

				varSetXD(UID, cHash, cIdEnt )
				varSetXD(UID, "TSSLastHash", cHash)
			else
				cError := iif( empty(GetWscError(3)), getWscError(1), getWscError(3) )

			endif

			freeObj(oWs)
			oWs := nil

			restArea(aArea)
			aSize(aArea,0)
			aArea := nil

		endif
	else
		/*Customização para Princesa dos Campos NFS-e Curitiba - NÃO DIVULGAR E NÃO UTILIZAR EM OUTRO CLIENTE*/
		if(  !varGetXD(UID, alltrim(oSigamatX:M0_CGC) + alltrim(oSigamatX:M0_INSC) + alltrim(oSigamatX:M0_ESTENT) + alltrim(oSigamatX:M0_CODIGO) + alltrim(oSigamatX:M0_CODFIL) + cUrl, @cIdEnt ) )

			aArea 	:= getArea()
			lEnvCodEmp	:= getNewPar("MV_ENVCDGE",.F.)
			lUsaGesEmp	:= iif(findFunction("FWFilialName") .And. findFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)
			aTel := NfeGetTel(oSigamatX:M0_TEL)

			oWS := WsSPedAdm():New()

			oWS:cUSERTOKEN				:= "TOTVS"
			oWS:oWSEMPRESA:cCNPJ		:= iiF(oSigamatX:M0_TPINSC==2 .Or. empty(oSigamatX:M0_TPINSC),oSigamatX:M0_CGC,"")
			oWS:oWSEMPRESA:cCPF			:= iiF(oSigamatX:M0_TPINSC==3,oSigamatX:M0_CGC,"")
			oWS:oWSEMPRESA:cIE			:= AllTrim(oSigamatX:M0_INSC)
			oWS:oWSEMPRESA:cIM			:= AllTrim(oSigamatX:M0_INSCM)
			oWS:oWSEMPRESA:cNOME		:= AllTrim(oSigamatX:M0_NOMECOM)
			oWS:oWSEMPRESA:cFANTASIA	:= iif(lUsaGesEmp,FWFilialName(),Alltrim(oSigamatX:M0_NOME))
			oWS:oWSEMPRESA:cENDERECO	:= AllTrim(FisGetEnd(oSigamatX:M0_ENDENT)[1])
			oWS:oWSEMPRESA:cNUM			:= AllTrim(FisGetEnd(oSigamatX:M0_ENDENT)[3])
			oWS:oWSEMPRESA:cCOMPL		:= AllTrim(FisGetEnd(oSigamatX:M0_ENDENT)[4])
			oWS:oWSEMPRESA:cUF			:= AllTrim(oSigamatX:M0_ESTENT)
			oWS:oWSEMPRESA:cCEP			:= AllTrim(oSigamatX:M0_CEPENT)
			oWS:oWSEMPRESA:cCOD_MUN		:= AllTrim(oSigamatX:M0_CODMUN)
			oWS:oWSEMPRESA:cCOD_PAIS	:= "1058"
			oWS:oWSEMPRESA:cBAIRRO		:= AllTrim(oSigamatX:M0_BAIRENT)
			oWS:oWSEMPRESA:cMUN			:= AllTrim(oSigamatX:M0_CIDENT)
			oWS:oWSEMPRESA:cCEP_CP		:= nil
			oWS:oWSEMPRESA:cCP			:= nil
			oWS:oWSEMPRESA:cDDD			:= aTel[2]
			oWS:oWSEMPRESA:cFONE		:= aTel[3]
			oWS:oWSEMPRESA:cFAX			:= FormatTel(oSigamatX:M0_FAX)
			oWS:oWSEMPRESA:cEMAIL		:= UsrRetMail(RetCodUsr())
			oWS:oWSEMPRESA:cNIRE		:= AllTrim(oSigamatX:M0_NIRE)
			oWS:oWSEMPRESA:dDTRE		:= oSigamatX:M0_DTRE
			oWS:oWSEMPRESA:cNIT			:= iif(oSigamatX:M0_TPINSC==1,oSigamatX:M0_CGC,"")
			oWS:oWSEMPRESA:cINDSITESP	:= ""
			oWS:oWSEMPRESA:cID_MATRIZ	:= ""

			if(lUsaGesEmp .And. lEnvCodEmp )
				oWS:oWSEMPRESA:CIDEMPRESA:= FwGrpCompany()+FwCodFil()

			endif

			oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
			oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"

			if( oWs:ADMEMPRESAS() )
				cIdEnt  := oWs:cADMEMPRESASRESULT

				varSetXD(UID, alltrim(oSigamatX:M0_CGC) + alltrim(oSigamatX:M0_INSC) + alltrim(oSigamatX:M0_ESTENT) + alltrim(oSigamatX:M0_CODIGO) + alltrim(oSigamatX:M0_CODFIL) + cUrl, cIdEnt )
			else
				cError := iif( empty(GetWscError(3)), getWscError(1), getWscError(3) )

			endif

			freeObj(oWs)
			oWs := nil

			restArea(aArea)
			aSize(aArea,0)
			aArea := nil

		endif
	endIf

	if !empty(cError) .and. (HttpGetStatus(@cMsgError) == 403 .or. HttpGetStatus(@cMsgError) == 401)
		cError := STR0002 + CHR(13) + CHR(10) + CHR(13) + CHR(10) // "Você não tem permissão para acessar esse servidor"
		cError += STR0003 // Verificar as credenciais cadastrada através na rotina 'Conf. Geral TSS' (SPEDCONFTSS).
		SPEDPRTMSG(cMsgError)
	endif

Return cIdEnt

//-------------------------------------------------------------------
/*/{Protheus.doc} getCfgAmbiente
Retorna o Ambiente configurado no TSS.

@param	cError		-	Mensagem de Retorno em caso de falha na requisição
@param	cIdEnt		-	Id da Entidade no TSS
@param	cModelo		-	Modelo do Documento
@param	cAmbiente	-	Ambiente a ser configurado(default=0)

@return	cAmbiente  	-	Ambiente configurado


@author  Renato Nagib
@since   17/08/2015
@version 12

/*/
//-------------------------------------------------------------------
function getCfgAmbiente(cError, cIdEnt, cModelo, cAmbiente)

	local cIdEmp	:= ""
	local cURL		:= ""
	local cValConfig:= ""
	local oWS		:= nil

	default cError		:= ""
	default cIdEnt		:= getCfgEntidade(@cError)
	default cModelo		:= "55"
	default cAmbiente	:= "0"

	cUrl := alltrim( if( FunName() == "LOJA701" .and. !Empty( getNewPar("MV_NFCEURL","")), PadR(GetNewPar("MV_NFCEURL","http://"),250),padR(getNewPar("MV_SPEDURL","http://"),250 )) )

	cIdEmp 		:= "AMBIENTE:" + cIdEnt + cModelo + cUrl

	cValConfig := cAmbiente

	varSetUID(UID, .T.)

	if(  !empty(cIdEnt) .and. ( !varGetXD(UID, cIdEmp, @cAmbiente ) .or. cValConfig <> "0"  ) )

		oWS := WsSpedCfgNFe():New()
		oWS:_URL       	:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWS:cUSERTOKEN 	:= "TOTVS"
		oWS:cID_ENT    	:= cIdEnt
		oWS:nAmbiente  	:= val(cValConfig)
		oWS:cModelo		:= cModelo

		If ( execWSRet( oWS, "CFGAMBIENTE") )

			cAmbiente 	:= oWS:cCfgAmbienteResult

			varSetXD(UID, cIdEmp, cAmbiente)


		Else
			cError 		:= (IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)))

		EndIf

		freeObj(oWS)
		oWS := nil

	endif

return cAmbiente

//-------------------------------------------------------------------
/*/{Protheus.doc} getCfgModalidade
Retorna a Modalidade configurada no TSS.

@param	cIdEnt		-	Id da Entidade no TSS
@param	cModelo		-	Modelo do Documento
@param	cError		-	Mensagem de Retorno em caso de falha na requisição
@param	cModalidade	-	Modalidade  a ser configurada(default=0)

@return	cModalidade	-	Modalidade configurada


@author  Renato Nagib
@since   17/08/2015
@version 12

/*/
//-------------------------------------------------------------------
function getCfgModalidade(cError, cIdEnt, cModelo, cModalidade, lGetTSS)

	local cIdEmp		:= ""
	local cURL			:= ""
	local oWS			:= nil
	local cValConfig	:= ""

	default cError	:= ""
	default cIdEnt	:= getCfgEntidade(@cError)
	default cModelo	:= "55"
	default cModalidade	:= "0"
    default lGetTSS     := .F.

	cUrl := alltrim( if( FunName() == "LOJA701" .and. !Empty( getNewPar("MV_NFCEURL","")), PadR(GetNewPar("MV_NFCEURL","http://"),250),padR(getNewPar("MV_SPEDURL","http://"),250 )) )

	cIdEmp := "MODALIDADE:" + cIdEnt + cModelo + cUrl

	cValConfig := substr(cModalidade,1,1)

	varSetUID(UID, .T.)

	if( !empty(cIdEnt) .and. ( !varGetXD(UID, cIdEmp, @cModalidade) .or. cValConfig >= "0"  .or. lGetTSS) )

		oWS := WsSpedCfgNFe():New()
		oWS:_URL       	:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWS:cUSERTOKEN 	:= "TOTVS"
		oWS:cID_ENT    	:= cIdEnt
		oWS:nModalidade	:= val(cValConfig)
		oWs:cModelo	   	:= cModelo

		lOk 		   	:= execWSRet( oWS, "CFGModalidade" )

		if (lOk)
			cModalidade	:= oWS:cCfgModalidadeResult
			varSetXD(UID, cIdEmp, cModalidade)

		else
			cError := iif( empty(getWscError(3)), getWscError(1), getWscError(3) )

		endIf

		freeObj(oWS)
		oWS := nil

	endif

return cModalidade


//-------------------------------------------------------------------
/*/{Protheus.doc} getVersaoTSS
Retorna a Versao de Release do TSS.

@param cError	- Mensagem de Retorno em caso de falha na requisição

@return	cVersaoTSS	-	Versao do release do TSS


@author  Renato Nagib
@since   17/08/2015
@version 12

/*/
//-------------------------------------------------------------------
function getVersaoTSS(cError, cUrl)

	local cVersaoTSS	:= ""
	local oWS			:= nil

	default cError 	:= ""
	default cUrl	:= getUrl()

	varSetUID(UID, .T.)

	if(  !varGetXD(UID, "VERSAOTSS" + cUrl, @cVersaoTSS) )

		oWS := WsSpedCfgNFe():New()
		oWS:_URL       	:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWS:cUSERTOKEN 	:= "TOTVS"

		lOk 		   	:= execWSRet( oWS, "CFGTSSVersao" )

		if (lOk)
			cVersaoTSS := oWS:cCfgTssVersaoResult
			varSetXD(UID, "VERSAOTSS" + cUrl, cVersaoTSS )


		else
			cError := iif( empty(getWscError(3)), getWscError(1), getWscError(3) )

		endIf

		freeObj(oWS)
		oWS := nil

	endif

return cVersaoTSS

//-------------------------------------------------------------------
/*/{Protheus.doc} getCfgVersao
Retorno a Versao configurada no TSS de acordo com o Modelo.

@param	cError		-	Mensagem de Retorno em caso de falha na requisição
@param	cIdEnt		-	Id da Entidade no TSS
@param	cModelo		-	Modelo do Documento
@param	cVersao	-	Versao a ser configurada(default=0.00)


@return	cVersao	-	Versao configurada


@author  Renato Nagib
@since   17/08/2015
@version 12

/*/
//-------------------------------------------------------------------
function getCfgVersao(cError, cIdEnt, cModelo, cVersao )


	local cIdEmp		:= ""
	local cURL			:= ""
	local cMetodo		:= ""
	local cValConfig	:= ""
	local oWS			:= nil

	default cError	:= ""
	default cIdEnt	:= getCfgEntidade(@cError)
	default cModelo := "55"
	default cVersao	:= "0.00"

	cUrl := alltrim( if( FunName() == "LOJA701" .and. !Empty( getNewPar("MV_NFCEURL","")), PadR(GetNewPar("MV_NFCEURL","http://"),250),padR(getNewPar("MV_SPEDURL","http://"),250 )) )

	cIdEmp := "VERSAO:" + cIdEnt + cModelo + cUrl

	cValConfig := cVersao

	varSetUID(UID, .T.)


	if( !empty(cIdEnt) .and. (!varGetXD(UID, cIdEmp, @cVersao) .or. cValConfig <> "0.00") )


		cMetodo := iif( cModelo $ "57-67", "CFGVersaoCTe", "CFGVersao")

		oWS := WsSpedCfgNFe():New()
		oWS:cUSERTOKEN	:= "TOTVS"
		oWS:cID_ENT		:= cIdEnt
		oWS:cVersao		:= cValConfig
		if cModelo <> "57"
			oWS:cModelo	:= cModelo
		EndIf
		oWS:_URL		:= AllTrim(cURL)+"/SPEDCFGNFe.apw"


		if( execWSRet(oWs, cMetodo) )
			cVersao	:= iif( cMetodo == "CFGVersaoCTe", oWS:cCfgVersaoCTeResult, oWS:cCfgVersaoResult )
			varSetXD(UID, cIdEmp, iif(cValConfig <> "0.00",cValConfig,cVersao))

		else
			cError	:= iif( empty( getWscError(3)), getWscError(1), getWscError(3) )
			cVersao := ""

		endif

		freeObj(oWS)
		oWS := nil

	endif

return cVersao

//-------------------------------------------------------------------
/*/{Protheus.doc} getCfgVerDpec
Retorna a Versao Dpec da Nfe

@param	cError		-	Mensagem de Retorno em caso de falha na requisição
@param	cIdEnt		-	Id da Entidade no TSS
@param	cVersaoDpec	-	Versao Dpec a ser Configurada(default=0.00)

@return	cVersaoDpec	-	Versao Dpec Configurada


@author  Renato Nagib
@since   17/08/2015
@version 12

/*/
//-------------------------------------------------------------------
function getCfgVerDpec(cError, cIdEnt, cVersaoDpec)

	local cIdEmp		:= ""
	local cURL			:= ""
	local cValConfig	:= ""
	local oWS			:= nil

	default cError		:= ""
	default cIdEnt		:= getCfgEntidade(@cError)
	default cVersaoDpec	:= "0.00"

	cUrl := alltrim( if( FunName() == "LOJA701" .and. !Empty( getNewPar("MV_NFCEURL","")), PadR(GetNewPar("MV_NFCEURL","http://"),250),padR(getNewPar("MV_SPEDURL","http://"),250 )) )

	varSetUID(UID, .T.)

	cIdEmp := "CFGVersaoDpec:" + cIdEnt + cUrl

	cValConfig := cVersaoDpec

	if( !empty(cIdEnt) .and. ( !varGetXD(UID, cIdEmp, @cVersaoDpec) .or. cValConfig <> "0.00" ) )

		oWS := WsSpedCfgNFe():New()
		oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWS:cUSERTOKEN := "TOTVS"
		oWS:cID_ENT    := cIdEnt
		oWS:cVersao    := cValConfig

		if( execWSRet(oWs, "CFGVersaoDpec") )

			cVersaoDpec	   := oWS:cCfgVersaoDpecResult

			varSetXD(UID, cIdEmp, cValConfig)

		else
			cError		:= iif( empty( getWscError(3)), getWscError(1), getWscError(3) )
			cVersaoDpec := ""

		endif

		freeObj(oWS)
		oWS := nil

	endif

return cVersaoDpec

//-------------------------------------------------------------------
/*/{Protheus.doc} getCfgEpecCte
Configura o Epec do CTe

@param	cError			-	Mensagem de Retorno em caso de falha na requisição
@param	cIdEnt			-	Id da Entidade no TSS
@param	cVERSAOGERALEPEC-	Versão Geral do Epec
@param	cVERSAOEVENEPEC	-	Versão do Evento Epec
@param	VERSAOGERALCANC	-	Versão geral do Cancelamento
@param	cVERSAOEVENCANC	-	Versão do Evento de cancelamento
@param	cVERSAOGERALCCE	-	Versão geral da Carta de correção
@param	cVERSAOEVENCCE	-	Versão do Evento de carta de orreção
@param	cVERSAOGERALMULT-	Versão geral do Multimodal
@param	cVERSAOEVENMULT	-	Versao do Evento MultiModal
@param	nSEQLOTEEPEC	-	Sequencia do Lote Epec
@param	lCTECANCEVENTO	-	Cancelamento por Evento

@return	aConfig			Configurações
 						aConfig[1]	- Cancelamento por Evento
 						aConfig[2]	- Sequencia do Lote Epec
 						aConfig[3]	- Versão do Evento de cancelamento
 						aConfig[4]	- Versão do Evento de carta de orreção
 						aConfig[5]	- Versão do Evento Epec
 						aConfig[6]	- Versao do Evento MultiModal
 						aConfig[7]	- Versão geral do Cancelamento
 						aConfig[8]	- Versão geral da Carta de correção
 						aConfig[9]	- Versão Geral do Epec
 						aConfig[10]	- Versão geral do Multimodal


@author  Renato Nagib
@since   17/08/2015
@version 12

/*/
//-------------------------------------------------------------------
function getCfgEpecCte(cError, cIdEnt, cVerGerEpec, cVerEvEpec, cVerGerCanc, cVerEVCanc, cVerGerCCE, cVerEVCCE, cVerGerMult, cVerEVMult, nSeqLoteEpec, cHRVeraoCTe, cHRCTe, cVerGerDesac, cVerEVDesac)

	local aConfig		:= array(15)
	local aParam		:= {}
	local cIdEmp		:= ""
	local cURL			:= ""
	local lRet			:= .F.
	local lConfig		:= .F.
	local nX			:= 0
	local oWS			:= nil

	default cError		:= ""
	default cIdEnt		:= getCfgEntidade(@cError)


	default cVerEVCanc	:= "3.00"
	default cVerGerCCE	:= "3.00"
	default cVerEVCCE		:= "3.00"
	default cVerGerDesac	:= "3.00"
	default cVerEVDesac	:= "3.00"
	default cVerGerCanc	:= "3.00"
	default cVerGerEpec	:= "3.00"
	default cVerEvEpec	:= "3.00"

	default cVerGerMult	:= ""
	default cVerEVMult 	:= ""
	default nSeqLoteEpec := 0
	default cHRVeraoCTe	:= "0"
	default cHRCTe		:= "0"

	cUrl := alltrim( if( FunName() == "LOJA701" .and. !Empty( getNewPar("MV_NFCEURL","")), PadR(GetNewPar("MV_NFCEURL","http://"),250),padR(getNewPar("MV_SPEDURL","http://"),250 )) )

	aParam := {	cVERGEREPEC, cVerEvEpec, cVerGerCanc, cVerEVCanc, cVerGerCCE,;
				cVerEVCCE, cVerGerMult, cVerEVMult, nSeqLoteEpec, .T., cHRCTe, cHRVeraoCTe, cVerGerDesac, cVerEVDesac }


	varSetUID(UID, .T.)

	cIdEmp := "CFGEPECCTE:" + cIdEnt + cUrl

	if !Empty(aParam[11])
		if(Valtype(aParam[11]) == "C")
			aParam[11] := Substr((aParam[11]),1,1)
		else
			aParam[11] := Alltrim(Str(aParam[11]))
		endif
	endif
	if( !empty(cIdEnt))

		if(  !varGetAD(UID, cIdEmp, @aConfig) )
			lConfig := .T.
		else
			for nX := 1 to len(aParam)

				if(!empty(aParam[nX]) .And. aParam[nX] <> aConfig[nX])
					lConfig := .T.
					exit
				endif
			next
		endif
	endif

	If Empty(cHRCTe) .And. Len(aConfig) > 0
		cHRCTe := Substr(AllTrim(aConfig[11]),1, 1)
	ElseIf Len(aConfig) = 0
		cHRCTe := "0"
	EndIf

	If Empty(cHRVeraoCTe) .And. Len(aConfig) > 0
		cHRVeraoCTe := Substr(AllTrim(aConfig[12]),1,1)
	ElseIf Len(aConfig) = 0
		cHRVeraoCTe := "0"
	EndIf
	if(lConfig)

		oWS := WsSpedCfgNFe():New()
		oWS:_URL       		 	:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWS:cUSERTOKEN 		 	:= "TOTVS"
		oWS:cID_ENT    		 	:= cIdEnt
		oWS:cVERSAOGERALEPEC		:= cVERGEREPEC
		oWS:cVERSAOEVENEPEC		:= cVerEvEpec
		oWS:cVERSAOGERALCANC		:= cVerGerCanc
		oWS:cVERSAOEVENCANC		:= cVerEVCanc
		oWS:cVERSAOGERALCCE		:= cVerGerCCE
		oWS:cVERSAOEVENCCE		:= cVerEVCCE
		oWS:cVERSAOGERALMULT		:= cVerGerMult
		oWS:cVERSAOEVENMULT		:= cVerEVMult
		oWS:nSEQLOTEEPEC			:= nSeqLoteEpec
		oWS:lCTECANCEVENTO		:= .T.
		oWS:cHORAVERAOCTE			:= Substr(AllTrim(cHRVeraoCTe), 1, 1)
		If Valtype(cHRCTe) == "N"
			cHRCTe := "0"
		EndIf
		oWS:cHORARIOCTE			:= Substr(AllTrim(cHRCTe),1, 1)
		oWS:cVERSAOGERALDESAC	:= cVerGerDesac
		oWS:cVERSAOEVENDESAC 	:= cVerEVDesac

		lRet := execWSRet(oWs, "CFGEpecCte")

		if( lRet )

			aSize(aConfig, 0 )
			aConfig := nil
			aConfig := {}

			aadd(aConfig, oWS:oWSCFGEPECCTERESULT:cVERSAOGERALEPEC	)
			aadd(aConfig, oWS:oWSCFGEPECCTERESULT:cVERSAOEVENEPEC	)
			aadd(aConfig, oWS:oWSCFGEPECCTERESULT:cVERSAOGERALCANC	)
			aadd(aConfig, oWS:oWSCFGEPECCTERESULT:cVERSAOEVENCANC	)
			aadd(aConfig, oWS:oWSCFGEPECCTERESULT:cVERSAOGERALCCE	)
			aadd(aConfig, oWS:oWSCFGEPECCTERESULT:cVERSAOEVENCCE	)
			aadd(aConfig, oWS:oWSCFGEPECCTERESULT:cVERSAOGERALMULT	)
			aadd(aConfig, oWS:oWSCFGEPECCTERESULT:cVERSAOEVENMULT	)
			aadd(aConfig, oWS:oWSCFGEPECCTERESULT:nSEQLOTEEPEC		)
			aadd(aConfig, if( substr(oWS:oWSCFGEPECCTERESULT:cCTECANCEVENTO, 1, 1) == "0", .F., .T.) )
			aadd(aConfig, oWS:oWSCFGEPECCTERESULT:cHORARIOCTE		)
			aadd(aConfig, oWS:oWSCFGEPECCTERESULT:cHORAVERAOCTE		)
			aadd(aConfig, oWS:oWSCFGEPECCTERESULT:cVERSAOGERALDESAC	)
			aadd(aConfig, oWS:oWSCFGEPECCTERESULT:cVERSAOEVENDESAC 	)

			varSetAD(UID, cIdEmp, aConfig)

		else
			cError	:= iif( empty( getWscError(3)), getWscError(1), getWscError(3) )

		endif

		freeObj(oWS)
		oWS := nil

	endif

return aConfig


//-------------------------------------------------------------------
/*/{Protheus.doc} setCfgparamSped
Retorna a Versao Epec do CTe

@param	cIdEnt	-	Id da Entidade no TSS
@param	cError	-	Mensagem de Retorno em caso de falha na requisição

@return	cCFGResult	-	Status da configuracao


@author  Renato Nagib
@since   17/08/2015
@version 12

/*/
//-------------------------------------------------------------------
function setCfgparamSped(cError, cIdEnt, nAMBIENTE,nMODALIDADE, cVERSAONFE,cVERSAONSE,;
							cVERSAODPEC,cVERSAOCTE, cNFEDISTRDANFE,cNFEENVEPEC,cModelo,cAUTODISTR,aAutoDist)

	local aCFGResult	:= {}
	local aParam		:= {}
	local cIdEmp		:= ""
	local cConteudo		:= ""
	local cUSACOLAB		:= Upper(GetNewPar("MV_SPEDCOL","N"))//Usa TC 1.0 S ou N
	local cUSERNEOG 	:= GetNewPar("MV_USERCOL","") //Usuario TC 1.0
	local cPASSWORD 	:= GetNewPar("MV_PASSCOL","") //Senha TC 1.0
	local cCONFALL 		:= GetNewPar("MV_CONFALL","S")//Confirma recebimento de documentos TC 1.0
	local cDOCSCOL		:= GetNewPar("MV_DOCSCOL","")//Configura tipo de documento via TC 1.0
	local nAMBNFECOLAB	:= GetNewPar("MV_AMBICOL",2)//Configura ambiente NFE do documento via TC 1.0
	local nAMBCTECOLAB	:= GetNewPar("MV_AMBCTEC",2)//Configura ambiente CTE do documento via TC 1.0
	local nNUMRETNF		:= GetNewPar("MV_NRETCOL",10)//Configura o tamanho do lote recebimento via TC 1.0
	local lNFECANCEVENTO:= GetNewPar("MV_NFECAEV",.T.)
	Local nAmbCTeC		:= Iif(!Empty(nAMBCTECOLAB),nAMBCTECOLAB,2)
	Local nAmbNFeC		:= Iif(!Empty(nAMBNFECOLAB),nAMBNFECOLAB,2)
	local nX			:= 0
	local nY			:= 0
	local nZ			:= 0
	local oWS			:= nil
	local lConfig		:= .F.

	default cError			:= ""
	default cIdEnt		 	:= getCfgEntidade(@cError)
	default nAMBIENTE		:= val(substr(getCfgAmbiente(@cError, cIdEnt, cModelo,),1,1))
	default nMODALIDADE		:= val(substr(getCfgModalidade(@cError, cIdEnt, cModelo,nMODALIDADE),1,1))
	default cVERSAONFE		:= getCfgVersao(@cError, cIdEnt, "55", "0.00")
	default cVERSAOCTE		:= getCfgVersao(@cError, cIdEnt, "57", "0.00")
	default cVERSAONSE		:= iif (Upper (cUSACOLAB) $ "S" .And. Upper(cDOCSCOL) $ "0|3","1.00","")
	default cVERSAODPEC		:= iif (!Empty (cVERSAODPEC),getCfgVerDpec(@cError, cIdEnt, "0.00"),"1.01")
	default cNFEDISTRDANFE	:= " "
	default cNFEENVEPEC		:= "1"
	default cModelo         := "55"
	default cAUTODISTR      := "1"
	default aAutoDist		:= { {cAUTODISTR, cModelo} }

	aadd(aParam, cUSACOLAB		)
	aadd(aParam, nNUMRETNF		)
	aadd(aParam, nAMBIENTE		)
	aadd(aParam, nMODALIDADE	)
	aadd(aParam, cVERSAONFE		)
	aadd(aParam, cVERSAONSE		)
	aadd(aParam, cVERSAODPEC	)
	aadd(aParam, cVERSAOCTE		)
	aadd(aParam, cUSERNEOG		)
	aadd(aParam, cPASSWORD 		)
	aadd(aParam, cCONFALL 		)
	aadd(aParam, cDOCSCOL		)
	aadd(aParam, nAMBNFECOLAB	)
	aadd(aParam, nAMBCTECOLAB	)
	aadd(aParam, lNFECANCEVENTO	)
	aadd(aParam, cNFEDISTRDANFE	)
	aadd(aParam, cNFEENVEPEC	)
	aadd(aParam, cAUTODISTR	)
	aadd(aParam, aAutoDist )

	cUrl := alltrim( if( FunName() == "LOJA701" .and. !Empty( getNewPar("MV_NFCEURL","")), PadR(GetNewPar("MV_NFCEURL","http://"),250),padR(getNewPar("MV_SPEDURL","http://"),250 )) )

	varSetUID(UID, .T.)

	cIdEmp:= "CFGPARAMSPED:" + cIdEnt + cUrl

	if ( !empty(cIdEnt) )
		if (  !varGetAD(UID, cIdEmp, @aCFGResult) .or. !Valtype(aCFGResult) == "A" .or. len(aCFGResult) <> len(aParam) ) 
			lConfig := .T.
		else
			begin sequence 

			lConfig := .T.

			for nX := 1 to len(aParam)
				if !empty(aParam[nX])
					if !valtype(aParam[nX]) == "A" 
						if aParam[nX] <> aCFGResult[nX]
							break
						endif
					else
						if !len(aParam[nX]) == len(aCFGResult[nX])
							break
						else
							for nY := 1 to len(aParam[nX])
								if !Valtype(aParam[nX][nY]) == "A" .or. !Valtype(aCFGResult[nX][nY]) == "A" .or. len(aParam[nX][nY]) <> len(aCFGResult[nX][nY])
									break
								else
									for nZ := 1 to len( aParam[nX][nY] )
										if (aParam[nX][nY][nZ] <> aCFGResult[nX][nY][nZ])
											break
										endif
									next nZ
								endif
							next nY
						endif
					endif
				endif
			next nX

			// Caso não caia em nenhum BREAK, está tudo ok.
			lConfig := .F.

			end sequence

		endif

	endif

	if (lConfig)

		oWS := WsSpedCfgNFe():New()

		oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWS:cUSERTOKEN := "TOTVS"
		oWS:cID_ENT    := cIdEnt

		oWS:cUSACOLAB  		:= cUSACOLAB
		oWS:nNUMRETNF  		:= nNUMRETNF
		oWS:nAMBIENTE  		:= nAMBIENTE
		oWS:nMODALIDADE		:= nMODALIDADE
		oWS:cVERSAONFE 		:= cVERSAONFE
		oWS:cVERSAONSE 		:= cVERSAONSE
		oWS:cVERSAODPEC		:= cVERSAODPEC
		oWS:cVERSAOCTE		:= cVERSAOCTE
		oWS:cUSERNEOG		:= cUSERNEOG
		oWS:cPASSWORD		:= cPASSWORD
		oWS:cCONFALL   		:= cCONFALL
		if(!empty(cNFEDISTRDANFE))
			oWS:cNFEDISTRDANFE	:= cNFEDISTRDANFE
		endif
		
		if(!empty(cAUTODISTR))
			oWS:cAUTODISTR	:= cAUTODISTR
		endif
		
		If (GetAPOInfo("sped_wsccfgnfe.prw")[4] >= SToD("20210728")) .And. Len(aAutoDist) > 0
			oWS:oWSCFGAUTODIST:oWSPARAMDIST:= SPEDCFGNFE_ARRAYOFCFGAUTO():New()
			For nX := 1 to Len(aAutoDist)
				If !Empty(aAutoDist[nX][1]) .And. !Empty(aAutoDist[nX][2])
					aAdd(oWS:oWSCFGAUTODIST:oWSPARAMDIST:oWSCFGAUTO, SPEDCFGNFE_CFGAUTO():New())
					oWS:oWSCFGAUTODIST:oWSPARAMDIST:oWSCFGAUTO[nX]:cEnable := aAutoDist[nX][1]
					oWS:oWSCFGAUTODIST:oWSPARAMDIST:oWSCFGAUTO[nX]:cModelo := aAutoDist[nX][2]
				EndIf
			Next nX
		EndIf

		if( getVersaoTSS() >= "1.43" )

			if("1" $ Upper(cDOCSCOL) )//1–Emissão de NF-e;
				cConteudo += "1"

			endif

			if( "2" $ Upper(cDOCSCOL) )//2–Emissão de CT-e;
				cConteudo += "2"

			endif

			if( "3" $ Upper(cDOCSCOL) )//3–Emissão de NFS-e;
				cConteudo += "3"

			endif

			if( "5" $ Upper(cDOCSCOL) )//5-Carta de correção;
				cConteudo += "5"
			endif
			if( "6" $ Upper(cDOCSCOL) )//6–MD-e;
				cConteudo += "6"
			endif
			if( "7" $ Upper(cDOCSCOL) )//7–MDF-e;
				cConteudo += "7"
			endif
			if( "4" $ Upper(cDOCSCOL) )//4-Nenhum;
				cConteudo := "4"

			endif

			if("0" $ Upper(cDOCSCOL) )//0–Todos;
				cConteudo := "0"

			endif

			//-- Cancelamento por Evento
			if (getVersaoTSS() >= "2.15" )
				oWS:lNFeCancEvento := GetNewPar("MV_NFECAEV",.T.)

			endif

			oWS:cDOCSCOL	:= cConteudo
			oWS:nAMBNFECOLAB:= IIF(nAmbNFeC >= 1 .And. nAmbNFeC <=2,nAmbNFeC,2)
			oWS:nAMBCTECOLAB:= IIF(nAmbCTeC >= 1 .And. nAmbCTeC <=2,nAmbCTeC,2)

		endif

			oWS:cNFEENVEPEC := "1"


		lRet:= execWSRet(oWs, "CFGPARAMSPED")

		if(lRet)
			aCFGResult := aClone(aParam)

			varSetAD(UID, cIdEmp, aCFGResult)
		else
			cError := iif( empty(GetWscError(3)), getWscError(1), getWscError(3) )
		endif

		freeObj(oWS)
		oWS	:= nil

	endif

return aCFGResult


//-------------------------------------------------------------------
/*/{Protheus.doc} isCFGReady
Verifica se ha certificado configurado

@param	cIdEnt		-	Id da entidade no TSS
@param	cError	-	Mensagem de Retorno em caso de falha na requisição

@return	lRet		-	Status da configuração


@author  Renato Nagib
@since   17/08/2015
@version 12

/*/
//-------------------------------------------------------------------

function isCFGReady(cIdEnt, cError)

	local cIdEmp	:= ""
	local cURL		:= ""
	local cRet		:= ""
	local lRet		:= .F.
	local oWS		:= nil

	default cError := ""
	default cIdEnt := getCfgEntidade(@cError)

	cUrl := alltrim( if( FunName() == "LOJA701" .and. !Empty( getNewPar("MV_NFCEURL","")), PadR(GetNewPar("MV_NFCEURL","http://"),250),padR(getNewPar("MV_SPEDURL","http://"),250 )) )

	varSetUID(UID, .T.)

	cIdEmp := "CFGReady:" + cIdEnt + cUrl

	if (!empty(cIdEnt) .and. !varGetXD(UID, cIdEmp, @cRet) )

		oWS := WsSpedCfgNFe():New()
		oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWs:cUserToken := "TOTVS"
		oWs:cID_ENT    := cIdEnt
		oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"

		if( oWs:CFGReady() )
			lRet := .T.

			varSetXD(UID, cIdEmp, cRet)

		else
			cError := iif(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))

		endif

		freeObj(oWS)
		oWS := nil

	else
		lRet := .T.

	endif

return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} isValidCert
Verifica validade dos certificados da Entidade

@param	cIdEnt		-	Id da entidade no TSS
@param	cError		-	Mensagem de Error em caso de falha na requisição

@return	lRet		-	Status de validade do certificado


@author  Renato Nagib
@since   17/08/2015
@version 12

/*/
//-------------------------------------------------------------------
function isValidCert(cIdEnt, cError, cUrl, cWarning, lHelp)

	local cIdEmp:= ""
	local lRet	:= .T.
	local nX	:= 0
	local oWS	:= nil

	default cError	 := ""
	default cIdEnt	 := getCfgEntidade(@cError)
	default cUrl	 := getUrl()
	default cWarning := ""
	default lHelp	 := .T.

	varSetUID(UID, .T.)

	cIdEmp := "CFGStatusCertificate:" + cIdEnt + cUrl

	if(  !empty(cIdEnt) )

		oWS := WsSpedCfgNFe():New()
		oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWs:cUserToken := "TOTVS"
		oWs:cID_ENT    := cIdEnt
		oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"

		if oWs:CFGStatusCertificate()
			if len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE) > 0

				for nX := 1 To Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE)

					if oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nX]:DVALIDTO-30 <= Date()
						if oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nX]:DVALIDTO < Date()
							lRet := .F.
						else
							cWarning := STR0001+Dtoc(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nX]:DVALIDTO)
							if lHelp
								aviso("SPED",STR0001+Dtoc(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nX]:DVALIDTO),{"Ok"},3) //"O certificado digital irá vencer em: "
							endif
						endif
					endif
				Next nX
			endif
		endif

		freeObj(oWS)
		oWS := nil

	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} isConnTSS
Verifica se esta concetado com o TSS


@param	cError		-	Mensagem de Error em caso de falha na requisição

@return	lRet		-	Status da conexão

@author  Renato Nagib
@since   17/08/2015
@version 12

/*/
//-------------------------------------------------------------------
function isConnTSS(cError, cUrl)

	local aConn	:= { seconds(), date() }
	local lRet := .T.
	local oWS := nil

	default cError := ""
	default cUrl := getUrl()

	varSetUID(UID, .T.)

	if(  !varGetAD(UID, "CFGCONNECT" + cUrl, @aConn) .or. ( seconds() - aConn[1] )  > 10 .or. date() > aConn[2] )

		oWs := WsSpedCfgNFe():New()
		oWs:cUserToken	:= "TOTVS"
		oWS:_URL 		:= AllTrim(cURL)+"/SPEDCFGNFe.apw"

		if( !execWSRet(oWs, "CFGCONNECT") )
			cError := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
			lRet := .F.

		else

			aConn := array(2)
			aConn[1] := seconds()
			aConn[2] := date()

			varSetAD(UID, "CFGCONNECT" + cUrl, aConn)

			aSize(aConn, 0)
			aConn := nil

		endIf

		freeObj(oWS)
		oWS := nil

	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} checkActiveEnt
Verifica se esta concetado com o TSS

@param	cIdEnt		-	Id da entidade no TSS
@param	cError		-	Mensagem de Error em caso de falha na requisição

@return	lRet		-	Status de ativação da Entidade

@author  Renato Nagib
@since   17/08/2015
@version 12

/*/
//-------------------------------------------------------------------
function checkActiveEnt(cIdEnt, cError)

	local cIdEmp	:= ""
	local cURL		:= ""
	local lRet		:= .T.
	local oWS		:= nil

	default cError 		:= ""
	default cIdEnt 		:= getCfgEntidade(@cError)

	cUrl := alltrim( if( FunName() == "LOJA701" .and. !Empty( getNewPar("MV_NFCEURL","")), PadR(GetNewPar("MV_NFCEURL","http://"),250),padR(getNewPar("MV_SPEDURL","http://"),250 )) )

	varSetUID(UID, .T.)

	cIdEmp := "ENTIDADEATIVA:" + cIdEnt + cUrl

	if(  !varGetXD(UID, cIdEmp, @cEntAtiv) .or. cEntAtiv <> allTrim( getNewPar("MV_SPEDENT","S") ) )

		oWS:= WSSPEDADM()		:New()
		oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
		oWS:cUSERTOKEN			:= "TOTVS"
		oWS:cID_ENT				:= cIdEnt
		oWS:nOpc    			:= Iif(allTrim( getNewPar("MV_SPEDENT","S") ) == "N",2,1)

		lRet:= oWs:ENTIDADEATIVA()

		if(lRet)
			cEntAtiv := oWS:cENTIDADEATIVARESULT

			varSetXD(UID, cIdEmp, cEntAtiv)

		else
			cError := iif( empty(GetWscError(3)), getWscError(1), getWscError(3) )
		endif

	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getcfgContigencia
Verifica se esta concetado com o TSS

@param	cError		-	Mensagem de Error em caso de falha na requisição
@param	cIdEnt		-	Id da entidade no TSS
@param 	cModelo		-	Modelo do documento
@param 	cCont		-	Código da contingência a configurar(default=0)


@return	cCont		-	Código da contingência configurada

@author  Renato Nagib
@since   17/08/2015
@version 12

/*/
//-------------------------------------------------------------------
function getcfgContigencia(cError, cIdEnt, cModelo, cCont)

	local cIdEmp	:= ""
	local cValConfig:= ""
	local oWS		:= ""

	default cError	:= ""
	default cIdEnt	:= getCfgEntidade(@cError)
	default cModelo	:= "55"
	default cCont	:= "0"

	cUrl := alltrim( if( FunName() == "LOJA701" .and. !Empty( getNewPar("MV_NFCEURL","")), PadR(GetNewPar("MV_NFCEURL","http://"),250),padR(getNewPar("MV_SPEDURL","http://"),250 )) )

	varSetUID(UID, .T.)

	cIdEmp := "CfgAutoOffLine:" + cIdEnt + cModelo + cUrl

	cValConfig := cCont

	if( (!empty(cIdEnt) .and. (!varGetXD( UID, cIdEmp, @cCont) .or. cValConfig <> "0" ) ) )

		oWs := WsSpedCfgNFe():New()
		oWS:_URL       		:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWS:cUSERTOKEN 		:= "TOTVS"
		oWS:cID_ENT    		:= cIdEnt
		oWS:nContingencia	:= val(cValConfig)

	 	oWS:cModelo			:= cModelo

		if( oWS:CfgAutoOffLine() )
			cCont := oWS:cCfgAutoOffLineResult

			varSetXD( UID, cIdEmp, cCont)
		else
			cError := iif( empty(GetWscError(3)), getWscError(1), getWscError(3) )
		endif

	endif

return cCont

//-------------------------------------------------------------------
/*/{Protheus.doc} getCfgEspera
Verifica o Tempo de Espera

@param	cError		-	Mensagem de Error em caso de falha na requisição
@param	cIdEnt		-	Id da entidade no TSS
@param	nTempo		-	Tempo de espera a Configurar(default=0)

@return	nTempo		-	Tempo de Espera configurado

@author  Renato Nagib
@since   17/08/2015
@version 12

/*/
//-------------------------------------------------------------------
function getCfgEspera(cError, cIdEnt, nTempo)

	local cIdEmp	:= ""
	local nValConfig:= 0
	local oWS		:= ""

	default cError := ""
	default cIdEnt := getCfgEntidade(@cError)
	default nTempo := 0

	cUrl := alltrim( if( FunName() == "LOJA701" .and. !Empty( getNewPar("MV_NFCEURL","")), PadR(GetNewPar("MV_NFCEURL","http://"),250),padR(getNewPar("MV_SPEDURL","http://"),250 )) )

	varSetUID(UID, .T.)

	cIdEmp := "CFGTempoEspera:" + cIdEnt + cUrl

	nValConfig := nTempo

	if(  !empty(cIdEnt) .and. (!varGetXD( UID, cIdEmp, @nTempo) .or. nValConfig <> 0) )

		oWs := WsSpedCfgNFe():New()
		oWS:cUSERTOKEN  := "TOTVS"
		oWS:cID_ENT     := cIdEnt
		oWS:nTempoEspera:=  nValConfig
		oWS:_URL        := AllTrim(cURL)+"/SPEDCFGNFe.apw"

		if( oWS:CFGTempoEspera() )
			nTempo := oWS:nCfgTempoEsperaResult

			varSetXD( UID, cIdEmp, nTempo)

		else
			cError := iif( empty(GetWscError(3)), getWscError(1), getWscError(3) )
		endif

		freeObj(oWS)
		oWS := nil

	endif

return nTempo

//-------------------------------------------------------------------
/*/{Protheus.doc} getCfgCCe
Retorna configuração da CCe

@param	cIdEnt		-	Id da entidade no TSS
@param	cError		-	Mensagem de Error em caso de falha na requisição

@return	lRet		-	Status da conexão

@author  Renato Nagib
@since   17/08/2015
@version 12

/*/
//-------------------------------------------------------------------
function getCfgCCe(cError, cIdEnt, nAmbCCE, cVerCCeLayout, cVerLayCCeEven, cVerCCeEven, cVerCCe, cHRVeraoCCe, cHRCCe, nSeqLoteCCe, ;
					cVerEpp, cVerEppVen ,cVerEppLEve , cVerEppLay,lEpp,nAmbEPP,cCCePdf)


	local aConfig		:= {}
	local cIdEmp		:= ""
	local cURL			:= ""
	local lRet			:= .F.
	local oWS			:= nil

	default cError 			:= ""
	default cIdEnt			:= getCfgEntidade(@cError)
	default nAmbCCE	:= 0
	
	default nAmbEPP	:= 0
	default cVerCCeLayout	:= "1.00"
	default cVerLayCCeEven	:= "1.00"
	default cVerCCeEven		:= "1.00"
	default cVerCCe			:= "1.00"
	default cHRVeraoCCe	:= "2-Nao"
	default cHRCCe		:= "2-Brasilia"
	default nSeqLoteCCe		:= 1
	default cVerEpp			:= "1.00"
	default cVerEppVen		:= "1.00"
	default cVerEppLEve		:= "1.00"
	default cVerEppLay		:= "1.00"
	Default lEpp	:= .F.
	Default cCCePdf			:= "2"

	cUrl := alltrim( if( FunName() == "LOJA701" .and. !Empty( getNewPar("MV_NFCEURL","")), PadR(GetNewPar("MV_NFCEURL","http://"),250),padR(getNewPar("MV_SPEDURL","http://"),250 )) )

	varSetUID(UID, .T.)

	cIdEmp := "CfgCCe:" + cIdEnt + cUrl

	if( !empty(cIdEnt) .and. (!varGetAD(UID, cIdEmp, @aConfig) .or. len(aConfig) < 10 .or. nAmbCCE > 0 .Or. lEpp) )

		oWS := WsSpedCfgNFe():New()
		oWS:_URL       		:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWS:cUSERTOKEN 		:= "TOTVS"
		oWS:cID_ENT    		:= cIdEnt
		oWS:nAMBIENTECCE	:= nAmbCCE
		oWS:cVERCCELAYOUT	:= cVerCCeLayout
		oWS:cVERCCELAYEVEN	:= cVerLayCCeEven
		oWS:cVERCCEEVEN		:= cVerCCeEven
		oWS:cVERCCE			:= cVerCCe
		oWS:cHORAVERAOCCE	:= cHRVeraoCCe
		oWS:cHORARIOCCE		:= cHRCCe
		oWS:nSEQLOTECCE		:= nSeqLoteCCe
		oWS:cCCEPDF			:= cCCePdf

		If lEpp
			oWS:cVEREPP            := cVerEpp
			oWS:cVEREPPEVEN        := cVerEppVen
			oWS:cVEREPPLAYEVEN     := cVerEppLEve
			oWS:cVEREPPLAYOUT      := cVerEppLay
			oWS:nAMBIENTEEPP       := nAmbEPP 
		EndIF


		lRet := execWSRet(oWs, "CfgCCe")

		if( lRet )

			aSize(aConfig, 0)
			aConfig := nil
			aConfig := {}

			aadd(aConfig, oWS:oWsCfgCCeResult:cAmbiente		)
			aadd(aConfig, oWS:oWsCfgCCeResult:cHORARIOCCE	)
			aadd(aConfig, oWS:oWsCfgCCeResult:cHORAVERAOCCE	)
			aadd(aConfig, oWS:oWsCfgCCeResult:nSEQLOTECCE	)
			aadd(aConfig, oWS:oWsCfgCCeResult:cVERCCE		)
			aadd(aConfig, oWS:oWsCfgCCeResult:cVERCCEEVEN	)
			aadd(aConfig, oWS:oWsCfgCCeResult:cVERCCELAYEVEN)
			aadd(aConfig, oWS:oWsCfgCCeResult:cVERCCELAYOUT	)
			aadd(aConfig, oWS:oWsCfgCCeResult:nAMBIENTEEPP	)
			aadd(aConfig, oWS:oWsCfgCCeResult:cCCEPDF		)
			varSetAD(UID, cIdEmp, aConfig)

		else
			cError	:= iif( empty( getWscError(3)), getWscError(1), getWscError(3) )

		endif

		freeObj(oWS)
		oWS := nil

	endif

return aConfig

//-------------------------------------------------------------------
/*/{Protheus.doc} setCfgAmbNFSe
Realiza a configuração dos parametros da NFSe

@param	cIdEnt		-	Id da entidade no TSS
@param	nAmbNFSe	-	Ambiente da NFSe
@param	nModNFSe	-	Mod NFSe
@param	cVersaoNFSe	-	Versao da NFSe
@param	cCodSiafi	-	Codigo Siafi
@param	nCNPJ		-	CNPJ
@param	cUser		-	Codigo do usuario
@param	cPSW		-	Senha do Usuario
@param	cAutorizacao-	Codigo de autorização
@param	cChaveAutent-	Codigo de autenticação
@param	cError		-	Mensagem de Error em caso de falha na requisição

@return	cResult		-	Status da configuração

@author  Renato Nagib
@since   27/08/2015
@version 12

/*/
//-------------------------------------------------------------------
function setCfgAmbNFSe(nAmbNFSe, cModNFSe, cVersaoNFSe, cCodSiafi, nCNPJ, cUser, cPSW, cAutorizacao, cChaveAutent, cError)

	local aConfig	:= {}
	local aParam	:= {}
	local cUserToken:= "TOTVS"
	local cIdEnt	:= ""
	local cCodMun	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
	local cUso		:= "NFSE"
	local cMaxLote	:= GetNewPar("MV_MAXLOTE","1")//Por padrão, o sistema utiliza 1 para MV_MAXLOTE no TSS
	local cEnvSinc	:= GetNewPar("MV_ENVSINC","N")
 	local cURL		:= ""
 	local cResult	:= ""
	local nY		:= 0
	local oWS		:= nil

	default nAmbNFSe		:=  2
	default cModNFSe		:=  "0"
	default cVersaoNFSe		:= "1   "
	default cCodSiafi		:= ""
	default nCNPJ			:= 0
	default cUser			:= ""
	default cPSW			:= ""
	default cAutorizacao	:= ""
	default cChaveAutent	:= ""
	default cError 			:= ""

	cURL = Padr(GetNewPar("MV_SPEDURL","http://localhost:8080"),250)

	varSetUID(UID, .T.)


	cIdEnt := getCfgEntidade(@cError)

	cIdEmp := "CFGambNFSE001" + cIdEnt + cUrl

	aadd(aParam, nAmbNFSe)
	aadd(aParam, cModNFSe)
	aadd(aParam, cVersaoNFSe)
	aadd(aParam, cCodSiafi)
	aadd(aParam, cUso)
	aadd(aParam, cMaxLote)
	aadd(aParam, nCNPJ)
	aadd(aParam, cEnvSinc)
	aadd(aParam, cUSer)
	aadd(aParam, cPSW)
	aadd(aParam, cAutorizacao)
	aadd(aParam, cChaveAutent)


	if( !empty(cIdEnt) .and. (!varGetAD(UID, cIdEmp, @aConfig)  .or. aScan(aParam, {|x| nY++, x <> aConfig[nY]}) > 0 ) )

		cURL := AllTrim(cURL)+"/NFSE001.apw"

		oWS							:= WsNFSE001():New()
		oWS:_URL					:= cURL
		oWS:cUSERTOKEN			:= cUserToken
		oWS:cID_ENT				:= cIdEnt
		oWS:nAmbienteNFSe			:= nAmbNFSe
		oWS:nModNFSE				:= Val(cModNFSE)
		oWS:cVersaoNFSe			:= cVersaoNFSe
		oWS:cCODMUN				:= cCodMun
		oWS:cCodSIAFI				:= cCodSiafi
		oWS:cUso					:= cUSO
		oWS:cMaxLote				:= cMaxLote

		if(getVersaoTSS() > "1.22")
			oWS:nCNPJAut 				:= nCNPJ
		endif

		oWS:cEnvSinc				:= cEnvSinc

		if(getVersaoTSS() >= "2.01")
			oWS:cLogin					:= cUser
			oWS:cPass					:= cPSW
		endif

		if(getVersaoTSS() >= "2.09")
			oWS:cAUTORIZACAO			:= cAutorizacao
		endif

		if(getVersaoTSS() >= "2.19")
			oWS:cChaveAutenticacao	:= cChaveAutent
		endif

		if( execWSRet( oWS ,"CFGambNFSE001" ) )
			cResult := oWS:cCFGAMBNFSE001RESULT
			aSize(aConfig, 0)
			aConfig := nil
			aConfig := {}

			aConfig := aClone(aParam)

			varSetAD(UID, cIdEmp, aConfig)

		else
			cError := iif( empty(GetWscError(3)), getWscError(1), getWscError(3) )
		endif

		freeObj(oWS)
		oWS := nil

	endif

return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} checkCfgNFSe
Verifica configurações da NFSe

@param	cError		-	Mensagem de Error em caso de falha na requisição

@return	lOk		-	Status da configuração

@author  Renato Nagib
@since   27/08/2015
@version 12

/*/
//-------------------------------------------------------------------
function checkCfgNFSe(cError)

	local cIdEnt 	:= ""
	local cConfig	:= ""
	local cURL		:= ""
	local cIdEmp 	:= ""
	local cCodMun	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
	local lOk	:= .T.
	local oWS		:= nil

	default cError:= ""

	cURL = Padr(GetNewPar("MV_SPEDURL","http://localhost:8080"),250)

	cIdEnt := getCfgEntidade(@cError)

	cIdEmp := "CFGREADYX" + cIdEnt + cUrl

	varSetUID(UID, .T.)

	if( !empty(cIdEnt) .and. !varGetXD(UID, cIdEmp, @cConfig) )


		cURL := AllTrim(cURL)+"/NFSE001.apw"

		oWS						:= WsNFSE001():New()
		oWS:_URL				:= cURL
		oWS:cUSERTOKEN			:= "TOTVS"
		oWS:cID_ENT				:= cIdEnt
		oWS:cCODMUN				:= cCodMun

		if( execWSRet( oWS ,"CFGREADYX" ) )

			varSetXD(UID, cIdEmp, cConfig)

		else
			lOk := .F.
			cError := iif( empty(GetWscError(3)), getWscError(1), getWscError(3) )

		endif

		freeObj(oWS)
		oWS := nil

	endif

return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} getMunSiafi
Retorna o codigo Siafi do Municipio

@param	cError		-	Mensagem de Error em caso de falha na requisição

@return	aSiafi		-	Info Siafi
						aSiafi[1] Codigo Siafi
						aSiafi[2] Codigo do Srviço
@author  Renato Nagib
@since   27/08/2015
@version 12

/*/
//-------------------------------------------------------------------
function getInfoSiafi(cError)

	local aSiafi	:= {}
	local cIdEnt 	:= ""
	local cURL		:= ""
	local cIdEmp := ""
	local cCodMun	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
	local lOk	:= .F.
	local oWS		:= nil

	default cError:= ""

	cURL = Padr(GetNewPar("MV_SPEDURL","http://localhost:8080"),250)

	cIdEnt := getCfgEntidade(@cError)

	cIdEmp := "GetMunSiaf" + cIdEnt	+ cUrl

	varSetUID(UID, .T.)

	if( !empty(cIdEnt) .and. !varGetAD(UID, cIdEmp, @aSiafi) )

		cURL := AllTrim(cURL)+"/NFSE001.apw"

		oWS							:= WsNFSE001():New()
		oWS:_URL					:= cURL
		oWS:cUSERTOKEN			:= "TOTVS"
		oWS:cID_ENT				:= cIdEnt
		oWS:cCODMUN				:= cCodMun

		if( execWSRet( oWS ,"GetMunSiaf" ) )

			lOk := .T.

			aSiafi := {oWS:OWSGETMUNSIAFRESULT:CCODSIAF, oWS:OWSGETMUNSIAFRESULT:CCODSERV }

			varSetAD(UID, cIdEmp, aSiafi)

		else
			cError	:= iif( empty( getWscError(3)), getWscError(1), getWscError(3) )

		endif

		freeObj(oWS)
		oWS := nil

	endif

return aSiafi

//-------------------------------------------------------------------
/*/{Protheus.doc} getMunServ
Retorna os codigos dos Municipios de acordo com o modelo

@param	cError		-	Mensagem de Error em caso de falha na requisição

@return	cMunServ	-	Lista dos Municipios

@author  Renato Nagib
@since   27/08/2015
@version 12

/*/
//-------------------------------------------------------------------
function getMunServ(cError, cServico)

	local cURL		:= ""
	local cMunServ	:= ""
	local cIdEmp	:= ""
	local oWS		:= nil

	default cError		:= ""
	default cServico	:= ""

	cURL = Padr(GetNewPar("MV_SPEDURL","http://localhost:8080"),250)

	cIdEmp := "RETMUNSERV" + cIdEnt	+ cServico + cUrl

	varSetUID(UID, .T.)

	if( !empty(cIdEnt) .and. !varGetXD(UID, cIdEmp, @cMunServ) )


		cURL := AllTrim(cURL)+"/NFSE001.apw"

		oWS				:= WsNFSE001():New()
		oWS:_URL		:= cURL
		oWS:cUSERTOKEN	:= "TOTVS"
		oWS:cCSERVICO	:= cServico

		if( execWSRet( oWS ,"RETMUNSERV" ) )

			cMunServ := oWS:cRETMUNSERVRESULT

			varSetXD(UID, cIdEmp, cMunServ)

		else
			cError := iif( empty(GetWscError(3)), getWscError(1), getWscError(3) )
		endif

		freeObj(oWS)
		oWS := nil

	endif

return cMunServ

//-------------------------------------------------------------------
/*/{Protheus.doc} getMunCanc
Retorna os codigos dos Municipios que atendem à serviço de cancelamento

@param	cError		-	Mensagem de Error em caso de falha na requisição

@return	cMunServ	-	Lista dos Municipios

@author  Renato Nagib
@since   27/08/2015
@version 12

/*/
//-------------------------------------------------------------------
function getMunCanc(cError)

	local cURL		:= ""
	local cMunCanc	:= ""
	local cIdEmp	:= ""
	local oWS		:= nil

	default cError:= ""

	cURL = Padr(GetNewPar("MV_SPEDURL","http://localhost:8080"),250)

	cIdEmp := "RETMUNCANC" + cIdEnt	+ cUrl

	varSetUID(UID, .T.)

	if( !empty(cIdEnt) .and. !varGetXD(UID, cIdEmp, @cMunCanc) )

		cURL := AllTrim(cURL)+"/NFSE001.apw"

		oWS				:= WsNFSE001():New()
		oWS:_URL		:= cURL
		oWS:cUSERTOKEN	:= "TOTVS"

		if( execWSRet( oWS ,"RETMUNCANC" ) )

			cMunCanc := oWS:cRETMUNCANCRESULT

			varSetXD(UID, cIdEmp, cMunCanc)

		else
			cError := iif( empty(GetWscError(3)), getWscError(1), getWscError(3) )
		endif

		freeObj(oWS)
		oWS := nil

	endif

return cMunCanc
//-------------------------------------------------------------------
/*/{Protheus.doc} getCfgMdfe
Configura os parâmetros do MDFe

@param	cError				-	Mensagem de Retorno em caso de falha na requisição
@param	cIdEnt				-	Id da Entidade no TSS
@param	nAmbienteMDFE		-	Ambiente de configuração
@param	cVersaoMDFE		-	Versão do MDFe
@param	nModalidadeMDFE	-	Modalidade de envio
@param	cVERMDFELAYOUT	-	Versão do Layout MDFe
@param	cVERMDFELAYEVEN	-	Versão do Evento MDFe
@param	nSEQLOTEMDFE		-	Sequencia do Lote MDFe
@param	cHORAVERAOCCE		-	Define o uso do Horário de verão
@param	cHORARIOCCE		-	Define o Fuso Horário

@return	aConfig			Configurações
 						aConfig[1]		- Cancelamento por Evento
 						aConfig[2]		- Sequencia do Lote Epec
 						aConfig[3]		- Versão do Evento de cancelamento
 						aConfig[4]		- Versão do Evento de carta de orreção
 						aConfig[5]		- Versão do Evento Epec
 						aConfig[6]		- Versao do Evento MultiModal
 						aConfig[7]		- Versão geral do Cancelamento
 						aConfig[8]		- Versão geral da Carta de correção
 						aConfig[9]		- Versão Geral do Epec
 						aConfig[10]	- Versão geral do Multimodal


@author  Cleiton Genuino da Silva
@since   31/01/2017
@version 11

/*/
//-------------------------------------------------------------------
function getCfgMdfe(cError, cIdEnt, nAmbienteMDFE, nModalidadeMDFE, cVERLAYOUT, cVERLAYEVEN, cVersaoMDFE, cHORAVERAOMDFE, cHORARIOMDFE, nSEQLOTEMDFE)

	local aConfig		:= array(10)
	local aParam		:= {}
	local cIdEmp		:= ""
	local cURL			:= ""
	local lRet			:= .F.
	local lConfig		:= .F.
	local nX			:= 0
	local oWS			:= nil

	default cError			:= ""
	default cIdEnt			:= getCfgEntidade(@cError)
	default nAmbienteMDFE	:= 0
	default cVersaoMDFE		:= "0.00"
	default nModalidadeMDFE	:= 0
	default cVERLAYOUT		:= "0.00"
	default cVERLAYEVEN		:= "0.00"
	default nSEQLOTEMDFE		:= 0
	default cHORAVERAOMDFE	:= "0"
	default cHORARIOMDFE 	:= "0"

	cUrl := alltrim( if( FunName() == "LOJA701" .and. !Empty( getNewPar("MV_NFCEURL","")), PadR(GetNewPar("MV_NFCEURL","http://"),250),padR(getNewPar("MV_SPEDURL","http://"),250 )) )

	aParam := { nAmbienteMDFE, nModalidadeMDFE, cVERLAYOUT, cVERLAYEVEN,;
				cVersaoMDFE, cHORAVERAOMDFE, cHORARIOMDFE , nSEQLOTEMDFE }

	varSetUID(UID, .T.)

	cIdEmp := "CFGMDFE:" + cIdEnt + cUrl

	if( !empty(cIdEnt))

		if ( !varGetAD(UID, cIdEmp, @aConfig) )
			lConfig := .T.
		else
			for nX := 1 to len(aParam)

				if(!empty(aParam[nX]) .and. aParam[nX] <> aConfig[nX])
					lConfig := .T.
					exit
				endif

			next
		endif
	endif

	if( !empty(cIdEnt) .and. (!varGetAD(UID, cIdEmp, @aConfig) .Or. lConfig ) )

		oWS := WsSpedCfgNFe():New()
		oWS:_URL       		:= AllTrim(cURL)+"/SPEDCFGNFe.apw"

		oWS:cUSERTOKEN 		:= "TOTVS"
		oWS:cID_ENT    		:= cIdEnt
		oWS:nAmbienteMDFE  	:= iif (ValType(aParam[1]) == "N", aParam[1], Val(Substr(aParam[1],1,1)))
		oWS:cVersaoMDFE		:= aParam[5]
		oWS:nModalidadeMDFE	:= iif (ValType(aParam[2]) == "N", aParam[2], Val(Substr(aParam[2],1,1)))
		oWS:cVERMDFELAYOUT	:= aParam[3]
		oWS:cVERMDFELAYEVEN	:= aParam[4]
		oWS:nSEQLOTEMDFE  	:= aParam[8]
		oWS:cHORAVERAOMDFE	:= iif (ValType(aParam[6]) == "N", Substr(cValtoChar(aParam[6]),1,1),Substr(aParam[6],1,1))
		oWS:cHORARIOMDFE		:= iif (ValType(aParam[7]) == "N", Substr(cValtoChar(aParam[7]),1,1),Substr(aParam[7],1,1))


		lRet := execWSRet(oWs, "CFGMDFE")
		//lRet:= oWS:CFGMDFE()

		if( lRet )

			aSize(aConfig, 0 )
			aConfig := nil
			aConfig := {}

			aadd(aConfig, oWS:OWSCFGMDFERESULT:CAMBIENTEMDFE	)
			aadd(aConfig, oWS:OWSCFGMDFERESULT:CMODALIDADEMDFE)
			aadd(aConfig, oWS:OWSCFGMDFERESULT:CVERMDFELAYOUT)
			aadd(aConfig, oWS:OWSCFGMDFERESULT:CVERMDFELAYEVEN)
			aadd(aConfig, oWS:OWSCFGMDFERESULT:CVERSAOMDFE	)
			aadd(aConfig, oWS:OWSCFGMDFERESULT:CHORAVERAOMDFE)
			aadd(aConfig, oWS:OWSCFGMDFERESULT:CHORARIOMDFE	)
			aadd(aConfig, oWS:OWSCFGMDFERESULT:NSEQLOTEMDFE	)

			varSetAD(UID, cIdEmp, aConfig)

		else
			cError	:= iif( empty( getWscError(3)), getWscError(1), getWscError(3) )

		endif

		freeObj(oWS)
		oWS := nil

	endif

return aConfig

//------------------------------------------------------------------------------
/*/{Protheus.doc} getCfgAutoCont
Retorno a configuração da Contingência Automática do TSS de acordo com o Modelo.

@param	cOpc		-	0-Consulta ou 1-Atualiza
@param	cIdEnt		-	Id da Entidade no TSS
@param	cModelo		-	Modelo do Documento: 55-NF-e
@param	cAtiva		-	0-Desativa ou 1-Ativa
@param	cModalidade	-	5-EPEC

@return	aRet		-	Array

@author  Sergio S. Fuzinaka
@version 12.1.017
@version 12

/*/
//------------------------------------------------------------------------------
function getCfgAutoCont( cOpc, cIdEnt, cModelo, cAtiva, cModalidade, aRetorno, cError )

local oWS			:= nil
local cURL			:= PadR( GetNewPar( "MV_SPEDURL", "http://" ), 250 )
local cMetodo		:= "cfgAutoCont"

local cIdEmp	    := ""
local lRet          := .T.

default cError		:= ""
default cOpc		:= "0"
default cIdEnt		:= getCfgEntidade(@cError)
default cModelo 	:= "55"
default cModalidade	:= ""
default cAtiva		:= ""

cIdEmp 		:= "CFGAUTO:" + cIdEnt + cModelo + cUrl

if !empty(cIdEnt)

	varSetUID(UID, .T.)

	if(  !empty(cIdEnt) .and. !varGetAD(UID, cIdEmp, @aRetorno ) .or. ( (!empty(cAtiva) .and. cAtiva <> aRetorno[1] ) .or. ( !empty(cModalidade) .and. cModalidade <>  aRetorno[2] ) ) )

		oWS:=WsSpedCfgNFe():New()
		oWS:cUSERTOKEN							:= "TOTVS"
		oWS:_URL								:= AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWs:oWscfgAutoCont:cOption				:= cOpc		// 0-Consulta ou 1-Atualiza

		oWs:oWScfgAutoCont:oWsConfig			:= SPEDCFGNFE_CFGDATA():New()
		oWs:oWScfgAutoCont:oWsConfig:cEntity	:= cIdEnt
		oWs:oWScfgAutoCont:oWsConfig:cDocType	:= cModelo
		oWs:oWScfgAutoCont:oWsConfig:cModality	:= cModalidade
		oWs:oWScfgAutoCont:oWsConfig:cActive	:= cAtiva

		If execWSRet(oWs, cMetodo)

	        aRetorno := {oWs:oWScfgAutoContResult:oWsConfig:cActive, oWs:oWScfgAutoContResult:oWsConfig:cModality}
	        varSetAD(UID, cIdEmp, aRetorno)

			if alltrim(cOpc) == "1" .and. alltrim(cAtiva) == "1" .and. !alltrim(oWs:oWScfgAutoContResult:oWsConfig:cModality) == alltrim(cModalidade)
				lRet := .F.
				cError	:= STR0004 + CHR(13) + CHR(10) + STR0005 // "Não foi possível salvar a configuração da contingência automática." # "Verificar a atualização do TSS."
				ConOut( cError )
			endif

		Else

		    lRet := .F.
			cError	:= "ERROR: " + STR0006 + " - Entidade: " + cIdEnt + " - Modelo: " + cModelo + " - " + STR0007 + " - " + IIf( empty( getWscError(3)), getWscError(1), getWscError(3) ) // Contingencia Automatica # falha na execucao do metodo
			ConOut( cError )

		Endif

        freeObj(oWS)
        oWS := nil

	Endif

Else

	cError := "ERROR: " + STR0008 // Contingencia Automatica: Entidade invalida.
	ConOut( cError )

Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getNfseVersao
Aciona o metodo getVersaonfse001 para retornar ao ERP se municipio foi homologado no TSS.

@param cError	- Mensagem de Retorno em caso de falha na requisição

@return	cVersaoTSS	-	Versao do Layout homologado no TSS - retorno "9.99" | Não homologado |


@author  Cleiton Genuino
@since   19/06/2017
@version 12

/*/
//-------------------------------------------------------------------
function getNfseVersao(cError)

	local cURL			:= ""
	local cVerNfseTSS	:= ""
	local oWS			:= nil
	local cIdEnt    	:= getCfgEntidade()

	default cError := ""

	cUrl := alltrim( if( FunName() == "LOJA701" .and. !Empty( getNewPar("MV_NFCEURL","")), PadR(GetNewPar("MV_NFCEURL","http://"),250),padR(getNewPar("MV_SPEDURL","http://"),250 )) )

	cIdEmp := "VERSAONFSE001" + cIdEnt + cUrl

	varSetUID(UID, .T.)

	if( !empty(cIdEnt) .and. !varGetXD(UID, cIdEmp, @cVerNfseTSS) )

		cURL := AllTrim(cURL)+"/NFSE001.apw"

		oWS := WsNFSE001():New()
		oWS:cUSERTOKEN            	:= "TOTVS"
		oWS:cCODMUN               	:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
		oWS:_URL                  	:= AllTrim(cUrl)+"/NFSE001.apw"


		if( execWSRet( oWS ,"VERSAONFSE001" ) )

			lOk := .T.

			cVerNfseTSS := oWS:cVERSAONFSE001RESULT

			varSetXD(UID, cIdEmp, cVerNfseTSS)

		else
			cError	:= iif( empty( getWscError(3)), getWscError(1), getWscError(3) )

		endif

		freeObj(oWS)
		oWS := nil

	endif

return cVerNfseTSS

//-------------------------------------------------------------------
/*/{Protheus.doc} MensPadrao
Adiciona alerta para o usuario de um evento exporadido

@param
@return

@author  Fernando Bastos
@since   08/05/2018
@version 12

/*/
//-------------------------------------------------------------------
function MensPadrao()
/*
local cMensPadrao	:= ""
local cDateIni	:= "01/08/2018" // Data Final da NFE 4.0
local nDias 		:= ""
local cModelo		:= "55"
local cVersao		:= ""
local cError		:=	""

	cVersao := getCfgVersao(@cError,cIdEnt,cModelo,)

	If cVersao == "3.10" .And. empty(cError)
		nDias :=  CTOD(cDateIni) - Date()
		If nDias > 0
			cMensPadrao :='   -   ATENÇÂO: FALTAM '+ cValToChar(nDias) +' DIAS PARA SEFAZ DESATIVAR A VERSÃO 3.10 DA NF-E.'
		Else
			cMensPadrao :='   -   ATENÇÂO: EM 02/08/2018, A SEFAZ DESATIVOU VERSÂO 3.10 da NF-e.'
		End
		cCadastro += cMensPadrao

		notify()
	EndIf

return cCadastro*/
return

//-------------------------------------------------------------------
/*/{Protheus.doc} notify
Notifica o usuario

@param
@return

@author  Fernando Bastos
@since   08/05/2018
@version 12

/*/
//-------------------------------------------------------------------
/*static function notify()

	local lNotify := .T.

	cDate := GetParam()

	lNotify := date() >= ctod(cDate)

	if(lNotify)
		NFeV4Notify()
	endif

return*/

//-------------------------------------------------------------------
/*/{Protheus.doc} NFeV4Notify
Monta a tela de notificacao
@param
@return

@author  Fernando Bastos
@since   08/05/2018
@version 12

/*/
//-------------------------------------------------------------------
/*static function NFeV4Notify()

	local cUrl   :=""
	local oBtn1  := NIL
	local oDLg   := NIL
	local oCombo := NIL
	local cAviso := ""

	cUrl :="http://tdn.totvs.com/display/public/PROT/NFE0125_Novo_Layout_NFE_4.0"
	cAviso := "Em 02/08/2018, a versão 3.10 da NF-e será desativada pela Sefaz."
	oFont := TFont():New('Arial',,15,.T.)

	DEFINE MSDIALOG oDlg TITLE "Quadro de Notificações" From 000,000 to 200, 500 OF oMainWnd PIXEL
	@005,111 SAY "Atenção!"  SIZE 500,050 COLOR CLR_RED FONT oFont PIXEL OF oDlg
	@030,010 SAY cAviso  SIZE 500,050 PIXEL FONT oFont OF oDlg																		//Tirar depois
	//@017,010 SAY cAviso  SIZE 500,050 PIXEL FONT oFont OF oDlg
	//@037,010 SAY "Adiar notificação em:"  SIZE 500,050 FONT oFont PIXEL OF oDlg
	//@047,010 COMBOBOX oCombo VAR cCombo ITEMS {"1-dia","5-dias","7-dias"} SIZE 060,010 OF oDlg PIXEL
	@082,172 BUTTON oBtn1 PROMPT "Informações"	ACTION ( ShellExecute( "Open", cUrl, "", "", 1 ) , .F.) OF oDlg PIXEL SIZE 035,011 //Informações
	//@082,212 BUTTON oBtn1 PROMPT "OK"	ACTION ( setNotify(oCombo, oCombo:nAt), oDlg:End()) OF oDlg PIXEL SIZE 035,011 //"OK"
	@082,212 BUTTON oBtn1 PROMPT "OK"	ACTION ( setNotify(oCombo, 1), oDlg:End()) OF oDlg PIXEL SIZE 035,011 //"OK"     	//Tirar Depois
	ACTIVATE MSDIALOG oDlg	CENTERED

return*/

//-------------------------------------------------------------------
/*/{Protheus.doc} setNotify
Grava um arquivo com a data de notificacao tela

@param
@return

@author  Fernando Bastos
@since   08/05/2018
@version 12

/*/
//-------------------------------------------------------------------
/*static function setNotify(oCombo, nAt)

	local aPerg := {}
	local cBackup := ""
	local __cDate := ""

	//__cDate :=  date() + val(substr(ocombo:aitems[nAt], 1,1))
	__cDate :=  date() + 1 																// Tirar depois
	__cDate := dtoc(__cDate)
	cBackup := MV_PAR01
	MV_PAR01 := __cDate
	aadd(aPerg,{1,"date",__cDate,"",".T.","",".T.",30,.F.})

	ParamSave("notify",aPerg,MV_PAR01)
	MV_PAR01 := cBackup

return*/

//-------------------------------------------------------------------
/*/{Protheus.doc} getParam
le o arquivo com a data do arquivo para notificação

@param
@return

@author  Fernando Bastos
@since   08/05/2018
@version 12

/*/
//-------------------------------------------------------------------
/*static function getParam()
	local aPerg 	:= {}
	local __cDate := ""

	aadd(aPerg,{1,"date","","",".T.","",".T.",30,.F.})

	__cDate := ParamLoad("notify",aPerg,1,space(10))
	if(empty(__cDate))
		__cDate := dtoc(date())
	endif
return __cDate*/

//-----------------------------------------------------------------------
/*/{Protheus.doc} ClearRelt
Limpa arquivos temporarios .rel da pasta MV_RELT

@author Fábio Veiga
@since 23.11.18
@version 12.1.17

@param	Null

/*/
//-----------------------------------------------------------------------
Function ClearRelt(cTipo)
//cTipo = "danfe" ou "damdfe"
Local cPath		:= SuperGetMV('MV_RELT',,"\SPOOL\")
Local aArquivos := {}
Local nX		:= 0
Local cNome		:= ""

aArquivos := Directory(cPath + "*.rel", "D")

For nX := 1 to Len(aArquivos)
	cNome := LOWER(aArquivos[nX,1])
	If AT(cTipo, cNome) > 0
		FERASE(cPath + cNome)
	EndIf
Next nX

Return

//-----------------------------------------------------------------------
/*/ {Protheus.doc}
Dados do Responsável Técnico

@author Valter da Silva
@since 15.01.2019
@version 11.80

@param	Null

/*/
function NfeRespTec(cChave,nModelo) 
	local cxml := ''
	local cCNPJ := '53113791000122'
	local cContato :='Rodrigo de Almeida Sartorio'
	local cEmail := 'resp_tecnico_dfe_protheus@totvs.com.br'
	local cFone := '1128593904'
	local cIdCSRT := ''	
	local cHashCSRT := ''
	local cTagContato := "Contato"
	
	default cChave := ""
	default nModelo := 55	//NF-e
	
	// cIdCSRT := '12'	
	//cHashCSRT := encode64(encode64(sha1(SuperGetMv("MV_TOKENRT",, "123") + cChave, 1 ) ))//aplicado duplo encode64 apenas para passar na validação de schema.sera necessario ajustar rotina na oficialização da valdação
	
	if nModelo == 58 //MDF-e
		cTagContato := "xContato"
	endif
	
	cXml +='<infRespTec>'
	cXml += '<CNPJ>'+cCNPJ+'</CNPJ>'
	cXml += '<'+cTagContato+'>'+cContato+'</'+cTagContato+'>'
	cXml += '<email>'+cEmail+'</email>'
	cXml += '<fone>'+cFone+'</fone>'
	If  !empty(cIdCSRT)
		cXml += '<idCSRT>'+cIdCSRT+'</idCSRT>'
		cXml += '<hashCSRT>'+cHashCSRT+'</hashCSRT>'
	Endif
	cXml +='</infRespTec>'
return cXml

//-----------------------------------------------------------------------
/*/ {Protheus.doc}
Verifica se o documento utilizado deverá levar a tag do responsavel tecnico

@author Bruno Seiji
@since 12.07.2019
@version 12.1.17
@param	cTpDoc	- Tipo de documento para validar se utilizara o a Tag
				  0 - Todos
				  1 - NFe
				  2 - MDFe	

/*/
function getRespTec(cTpDoc)

local xRespTec	:= superGetMV("MV_RESPTEC", ,.T.)
local lRespTec	:= .F.

default cTpDoc	:= "1"

if valType( xRespTec ) == "L"
	lRespTec := xRespTec
elseif valType( xRespTec ) == "C"
	if xRespTec $ "0" .or. xRespTec $ cTpDoc .or. (xRespTec == ".T." .or. xRespTec == "T")
		lRespTec := .T.
	endif
endif

return lRespTec

function accessPD()	
	if(findFunction("FwPDCanUse") .and. FwPDCanUse(.T.))
		if(!versenha(192)) /*.or. !versenha(193)) - Retirada a validação para Dados Sensíveis (DSERTSS1-15852) */ 
			Help(NIL, NIL, "DADO_PROTEGIDO", NIL, STR0009, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0010 + CRLF + ' <a href=" https://tdn.totvs.com/x/9JYIHw">' + STR0011 + '</a>'}) // "Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina." # Saiba mais em: # Lei Geral de Proteção de Dados
			return .F.
		endif
	endif	
return .T.

/*
function logPdAutdit()
	//#LGPD Log Auditoria
	if(FwPDCanUse(.T.))
		FwPDLogUser( procName(), 3)
	endif
	
return*/

//-----------------------------------------------------------------------
/*{Protheus.doc} ObjSelf
Funcao responsavel por receber o objeto, validar se o processo esta
sendo executado pelo SMART ERP ou Legado.

@param		self			Objeto, 
@return		cToken			String, Token retornado WSO2.

@author	Douglas Parreja
@since	17/07/2019
@version 3.0
/*/
//-----------------------------------------------------------------------
function ObjSelf( oSelf )

	local cService		:= ""
	local cVarAmbiente	:= "TSS"
	local aToken		:= {}
	local cError		:= ""
	local cClientID		:= ""
	local cClientSec	:= ""
	local cCertCA		:= ""
	local cCert			:= ""
	local cKey			:= ""
	local cPassCert		:= ""
	local cUrl			:= alltrim(oSelf:_URL)

	if !empty(oSelf:_URL) .and. 'apw' $ lower(oSelf:_URL) .and. rat("/", oSelf:_URL) > 8 // https:// ou http://
		cUrl := substr(oSelf:_URL, 1, rat("/", oSelf:_URL) - 1 )
	endif

	//-------------------------------------------------
	// Verifica se utiliza validacao por Token
	//-------------------------------------------------
	if usaToken()
	
		//-------------------------------------------------
		// Obtem nome do servico a ser executado
		//-------------------------------------------------
		cService := getServSvc( oSelf:_URL )
		
		//-------------------------------------------------
		// Adiciona na URL o endereco da API WSO2
		//-------------------------------------------------
		oSelf:_URL := getUrl() + getWSO2URL(cService)				

		//-------------------------------------------------
		// Adiciona no header o mesmo prefixo das variaveis
		// de ambiente, por exemplo 'TSS'.
		//-------------------------------------------------
		if( empty( oSelf:_HEADOUT) )
			oSelf:_HEADOUT := {}
		endif	
		aadd( oSelf:_HEADOUT, "FwCredential: " + cVarAmbiente )	

	elseif useTSSAuth(oSelf, @cClientID, @cClientSec, @cCertCA, @cCert, @cKey, @cPassCert, cUrl)
		aToken := TSSAuth(@cError, cUrl, cClientID, cClientSec, cCertCA, cCert, cKey, cPassCert)
		if len(aToken) > 1
			aAdd( oSelf:_HEADOUT, "Authorization: " + aToken[1] + " " + aToken[2] )
		else
			SPEDPRTMSG("Nao foi possivel obter o token de autenticacao - " + cError)
		endif
	endif
	
return oSelf

//-----------------------------------------------------------------------
/*{Protheus.doc} getServSvc
Realizar validacao atraves do parametro 3(SoapAction) para que retorne
o nome do servico que esta sendo executado.

@param		cDados			String, Recebe o valor para ser capturado servico.
@return		cToken			string, Token retornado WSO2.

@author	Douglas Parreja
@since	17/07/2019
@version 3.0
/*/
//-----------------------------------------------------------------------
static function getServSvc( cDados )
	
	local nX			:= 0
	local aDados		:= {}	
	local cService		:= ""		
	default cDados		:= ""

	if( !empty(cDados) ) 
		aDados := Strtokarr( cDados, "/" )
		if( len(aDados) > 0 )
			for nX := 1 to len( aDados )
				if( at(".apw", aDados[nX]) > 0 )
					cService 	:= upper(substr(aDados[nX],1,at(".apw",aDados[nX])-1))	
					exit
				endif
				//-------------------------------------------------
				// Penultimo parametro (nome do servico + versao)
				//-------------------------------------------------
				if ( nX == len(aDados) )						
					cService := upper(aDados[len(aDados)-1])
				endif
			next
		endif
	endif

return ( cService )

//-----------------------------------------------------------------------
/*{Protheus.doc} getWSO2Cred
URL do WSO2 que irá fazer o redirect para a URL original do serviço

@param		cService		String, Nome do servico a ser consumido.			
@return		url				String, Retorno com a URL do Direct + servico.							

@author	Douglas Parreja
@since	17/07/2019
@version 3.0
/*/
//-----------------------------------------------------------------------
function getWSO2URL(cService)
	
	local cVar 			:= GETENV("TSS_PROD")
	default cService	:= ""

return StrTran(cVar, "SERVICE", cService)

//-----------------------------------------------------------------------
/*{Protheus.doc} usaToken
Funcao responsavel por retornar se esta utilizando Smart ERP.
Criterio: PTInternal(28) + TOTVSCLOUD=1 [General]

@author	Douglas Parreja
@since	30/07/2019
@version 3.0
/*/
//-----------------------------------------------------------------------
function usaToken()

	local cID		:= "TSSID"
	local cChave	:= "SMART"
	local aRet 		:= {}
	local lUsaToken := .F.
	
	if( VarGetAD(cID, cChave, @aRet) )
		lUsaToken := iif( len(aRet) > 0, aRet[1], lUsaToken )
	else
		if( validVersionBuild() )			
			if( __lToken )				
				lUsaToken := .T.			
			endif					
		endif
		lRet := VarSetUID(cID, .T.)
  
		if(!lRet)
			conout("Erro na criação da sessão: " + cID)
		endif

		lRet := VarSetAD(cID, cChave, {lUsaToken} )    
		if(!lRet)
			conout("Erro na atualização da chave: " + cChave)
		endif		
		
	endif

return ( lUsaToken )

//-----------------------------------------------------------------------
/*{Protheus.doc} getUrl
Funcao responsavel por retornar a url que esta cadastrada nos parametros.

@return		URL			String, retorno da url

@author	Douglas Parreja
@since	31/07/2019
@version 3.0
/*/
//-----------------------------------------------------------------------	
static function getUrl()
return alltrim( if( FunName() == "LOJA701" .and. !Empty( getNewPar("MV_NFCEURL","")), PadR(GetNewPar("MV_NFCEURL","http://"),250),padR(getNewPar("MV_SPEDURL","http://"),250 )) )

//-----------------------------------------------------------------------
/*{Protheus.doc} validVersionBuild
Funcao responsavel por validar a versao do binario, sendo que foi implementado
o PtInternal(28) na versao 17.3.0.11.
Caso a versao do binario for menor, retornara false.

@return		URL			String, retorno da url

@author	Douglas Parreja
@since	12/12/2019
@version 3.0
/*/
//-----------------------------------------------------------------------	
static function validVersionBuild()

	local nX			:= 0
	local lContinua		:= .F.
	local aVersionBuild	:= {}
	Local cSrvVer		:= ""

	If ExistFunc("getSrvVersion") //Devido a desatualização do robo de compilação
		cSrvVer := &("getSrvVersion()")
		aVersionBuild := StrTokArr(cSrvVer, "." )

		if( valtype(aVersionBuild) == "A" )
			if( len(aVersionBuild) > 0 )
				for nX := 1 to len(aVersionBuild)
					if nX == 1
						if( valtype(aVersionBuild[1]) <> "U" )						
							if( val(aVersionBuild[1]) >= 17 )				
								lContinua := .T.
								loop
							else
								lContinua := .F.
								exit
							endif
						else
							lContinua := .F.
							exit						
						endif		
					endif
					if nX == 2 
						if( valtype(aVersionBuild[2]) <> "U" )
							if( (val(aVersionBuild[2]) >= 3 .and. val(aVersionBuild[1]) >= 17) .or. (val(aVersionBuild[1]) > 17) )	
								lContinua := .T.
								loop
							else
								lContinua := .F.
								exit
							endif
						else
							lContinua := .F.
							exit	
						endif					
					endif
					if nX == 3														
						if( valtype(aVersionBuild[3]) <> "U" )							
							if( (val(aVersionBuild[3]) >= 0 .and. val(aVersionBuild[1]) >= 17) .or. (val(aVersionBuild[1]) > 17) )
								lContinua := .T.
								loop
							else
								lContinua := .F.
								exit
							endif
						else
							lContinua := .F.
							exit	
						endif					
					endif
					if nX == 4
						if( valtype(aVersionBuild[4]) <> "U" )
							if( (val(aVersionBuild[4]) >= 11 .and. val(aVersionBuild[1]) >= 17) .or. (val(aVersionBuild[1]) > 17) )
								lContinua := .T.
								loop
							else
								lContinua := .F.
								exit
							endif
						else
							lContinua := .F.
							exit	
						endif					
					endif
				next
			endif
		endif
	EndIf

return ( lContinua ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMvTSS
Retorna os parâmetros da tabela SPED000 referentes a entidade informada.

@param	cError		-	Mensagem de Retorno em caso de falha na requisição
@param	cIdEnt		-	Id da Entidade no TSS
@param	aParam		-	Array com os parâmetros desejados, para obter todos os parâmetros basta passar o array vazio

@return	aMvTss  	-	Array com o nome e conteúdo dos parâmetros solicitados

@author  Caique Lima Fonseca
@since   07/04/2020
@version 1.0

/*/
//-------------------------------------------------------------------
function GetMvTSS(cIdEnt, aParam, cError)

	local cURL		:= ""
	local aMvTSS	:= {}
	local aRetMv 	:= {}
	local oWS		:= nil
	local nY		:= 0
	Local nX		:= 0
	local nLenPar	:= 0

	default cError		:= ""
	default cIdEnt		:= getCfgEntidade( @cError )
	default aParam		:= {}

	nLenPar := len( aParam )
	cUrl := alltrim(padR(getNewPar("MV_SPEDURL","http://"),250 )) 

	//Monto o Objeto para a chamada do método
	oWS := WsSpedCfgNFe():New()
	oWS:_URL       	:= AllTrim( cURL )+"/SPEDCFGNFE.apw"
	oWS:cUSERTOKEN 	:= "TOTVS"
	oWS:OWSENTSGETALLMV:cID    		    := cIdEnt
	oWS:OWSENTSGETALLMV:cSEPARATOR		:= ""
	oWS:OWSENTSGETALLMV:nTYPESEP		:= 3

	//Realizo a chamada do método
	If ( execWSRet( oWS, "GetAllMvTss") )
		If valtype( oWS:OWSGETALLMVTSSRESULT:OWSRETGETALLMV[1]:OWSMVSTRUCT:OWSRETMVGETALLMV ) <> "U"
			aRetMv := aClone( oWS:OWSGETALLMVTSSRESULT:OWSRETGETALLMV[1]:OWSMVSTRUCT:OWSRETMVGETALLMV )
			nLenMv := len( aRetMv )
		Else
			cError := ( IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)) )
		EndIf
	Else
		cError := ( IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)) )
	EndIf
	
	If Empty( aParam ) //Retorna todos os parâmetros
		For nX := 1 to nLenMv
			Aadd( aMvTSS, {aRetMv[nX]:cMVNAME, aRetMv[nX]:cMVVALUE} )
		Next
	Else //Retorna apenas os parâmetros solicitados
		If Len(aRetMv) > 0 
			For nY := 1 to nLenPar 
				For nX := 1 to nLenMv
					If ( aParam[nY] $ aRetMv[nX]:cMVNAME )
						Aadd( aMvTSS, {aRetMv[nX]:cMVNAME, aRetMv[nX]:cMVVALUE} )
					EndIf
				Next
			Next
		EndIF	
	EndIf

	freeObj( oWS )
	oWS := nil

return aMvTSS

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAmbNfse
Retorna o Ambiente da NFSe, configurado no TSS.

@param	cIdEnt		-	Id da Entidade no TSS
@param	lAmbAlt		- 	Indica se o ambiente foi alterado pelo usuário

@return	cAmbiente  	-	Ambiente configurado

@author  Caique Lima Fonseca
@since   15/04/2020
@version 1.0

/*/
//-------------------------------------------------------------------
function GetAmbNfse( cIdEnt, lAmbAlt )

	local cIdEmp	:= ""
	local cURL		:= ""
	local cError	:= ""
	local aParam	:= {"MV_NFSEAMB"}

	default cIdEnt		:= getCfgEntidade( @cError )
	default cAmbiente	:= ""
	default lAmbAlt		:= .F.

	cUrl := alltrim( padR(getNewPar("MV_SPEDURL","http://"),250 )) 
	cIdEmp 		:= "AMBNFSE:" + cIdEnt + cUrl

	varSetUID( UID, .T. )

	//Verifico se a informaão está na variável global, se a lAmbAlt estiver true, demonstra que o ambiente foi alterado.
	If ( !empty( cIdEnt ) .and. ( !varGetXD(UID, cIdEmp, @cAmbiente ))) .or. cAmbiente == "0" .or. Empty( cAmbiente ) .or. lAmbAlt

		//Pego o conteúdo do parâmetro MV_NFSEAMB da atual entidade
		aAmbPar := GetMvTSS( cIdEnt, aParam, cError )
		
		//Se a infromação do parâmetro for retornada com sucesso, atualizo a variável Global
		If Len(aAmbPar) > 0
			If valtype( aAmbPar[1][2] ) <> "U"
				cAmbiente := aAmbPar[1][2]
				If !Empty( cAmbiente )
					varSetXD( UID, cIdEmp, cAmbiente )
					lAmbAlt := .F.
				EndIf
			EndIf
		EndIf
	endif

	//Retorno o ambiente
	If alltrim( cAmbiente ) $ "1|2"
		If alltrim( cAmbiente ) == "1"
			cAmbiente := "1 - " + STR0012 // Produção
		Else
			cAmbiente := "2 - " + STR0013 // Homologação
		EndIf
	Else
		cAmbiente := STR0014 // Não configurado"
	Endif	

return cAmbiente

//-------------------------------------------------------------------
/*/{Protheus.doc} NfeGetTel
Retorna o telefone após a correção do fiscal referente a função FisGetTel
https://jiraproducao.totvs.com.br/browse/DSERFIS1-22424

@since   21/10/2020
@version 1.0
/*/
//-------------------------------------------------------------------
function NfeGetTel(cTelefone)
	local aTel       := {}
	local aRet		 := {}
	local cDDI       := ""
	local cDDD       := ""
	local cTel       := ""

	default cTelefone := SM0->M0_TEL

	aTel := FisGetTel(FormatTel(cTelefone),,,.T.)
	if len(aTel) > 2 
		cDDI := if(valtype(aTel[1]) == "N", Right(alltrim(str(aTel[1])),3) , Right(alltrim(aTel[1]),3))
		cDDD := if(valtype(aTel[2]) == "N", Right(alltrim(str(aTel[2])),3) , Right(alltrim(aTel[2]),3))
		cTel := if(valtype(aTel[3]) == "N", alltrim(str(aTel[3])) , alltrim(aTel[3]))
	endif
	aAdd(aRet, cDDI)
	aAdd(aRet, cDDD)
	aAdd(aRet, cTel)

return aRet

/*/{Protheus.doc} FormatTel
Função para retirada dos caracteres '(', ')'  e '+'

/*/
static function FormatTel(cTel)
	local 	cRet := ""
	default cTel := SM0->M0_TEL
	cRet := strtran(strtran(strtran(cTel, "(", ""), ")", ""), "+", "")
return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SPEDPRTMSG()

Executa um Print padronizado 

@param 	cMensagem    mensagem a ser printada no console  
@param 	nTypeMsg     Tipo do Conout 

@return nil

@author 	Renato Nagib 
@since		28/11/2016
@version	12.1.15

/*/
//-------------------------------------------------------------------
function SPEDPRTMSG(cMensagem, nTypeMsg)

	local cDelConout := replicate("-", 78 )

	default nTypeMsg	:= 1
	
	if(nTypeMsg == LOG_ERROR)
		ConOut(CRLF + cDelConout + CRLF + "[ ERROR: " + UPPER(procName(1)) + "] " + (StrZero(ProcLine(1), 4)) + " [Thread: " + alltrim(str(ThreadId())) + "] " + "[" + dtoc(date()) +" "+ time() + "] " + CRLF + "[" + cMensagem + "] " + CRLF + cDelConout)
	elseif( nTypeMsg == LOG_PRINT)
		ConOut(CRLF + cDelConout + CRLF + "[ LOG: " + UPPER(procName(1)) + "] " + (StrZero(ProcLine(1), 4)) + " [Thread: " + alltrim(str(ThreadId())) + "] " + "[" + dtoc(date()) +" "+ time() + "] "  + CRLF +  "[" + cMensagem + "] " + CRLF + cDelConout)
	elseif(nTypeMsg == LOG_WARNING .and. __lWarning )
		ConOut(CRLF + cDelConout + CRLF + "[ WARNING: " + UPPER(procName(1)) + "] " + (StrZero(ProcLine(1), 4)) + " [Thread: " + alltrim(str(ThreadId())) + "] " + "[" + dtoc(date()) +" "+ time() + "] "  + CRLF +  "[" + cMensagem + "] " + CRLF + cDelConout)
	elseif(nTypeMsg == LOG_INFO .and. __lInfo )
		ConOut(CRLF + cDelConout + CRLF + "[ INFO: " + UPPER(procName(1)) + "] " + (StrZero(ProcLine(1), 4)) + " [Thread: " + alltrim(str(ThreadId())) + "] " + "[" + dtoc(date()) +" "+ time() + "] "  + CRLF +  "[" + cMensagem + "] " + CRLF + cDelConout)
	endif

return

/*/{Protheus.doc} useTSSAuth
Função para retornar se será utilizado autenticação com TSS

/*/
static function useTSSAuth(oSelf, cClientId, cClientSec, cCertCA, cCertPem, cCertKey, cCertPass, cUrl)
	local lUse		 := .F.
	local aAreaFX7	 := {}
	local cArqIni	 := ""
	local cVersao	 := ""
	local nPos		 := 0
	local lSeek		 := .F.
	local cModelo	 := ""
	local cUrlParam	 := ""
	local lMod		 := .F.

	default cClientId	:= ""
	default cClientSec	:= ""
	default cCertCA	 	:= ""
	default cCertPem	:= ""
	default cCertKey	:= ""
	default cCertPass	:= ""
	default cUrl		:= if(select("SX6") > 0, getUrl(), "")

	// Verifica se já existe o token devido ao RH (SIGAGPE) possuir outra rotina de cadastro de credenciais (RH x TAF)
	if( empty( oSelf:_HEADOUT) )
		oSelf:_HEADOUT := {}
	else
		nPos := aScan( oSelf:_HEADOUT, { |X| alltrim(upper(X)) == alltrim(upper("Authorization:"))})
	endif

	if nPos == 0
		if _lCheckAut == nil
			_lCheckAut := select("SX6") > 0 .and. TableInDic("FX7") .and. ChkFile("FX7") .and. ExistFunc("FX7DesKey") .and. !FwIsInCallStack("StaticCall") 
		endif

		if _lCheckAut

			cArqIni := GetAdv97()
			dbSelectArea("FX7")
			if Select("FX7") > 0

				aAreaFX7 := FX7->(getArea())
				lSeek := .F.
				if _lCpoMod == nil
					_lCpoMod := FX7->(ColumnPos("FX7_MODELO")) > 0 .and. val(SuperGetMv("MV_SPDCFGM",.F.,"0",FWCodEmp())) == 1
				endif

				if _lCpoMod .and. !empty(cUrl)
					cModelo := TSSGetAuth()
					if empty(cModelo)
						cUrlParam := alltrim(SuperGetMv("MV_SPEDURL",.F.,"",FWCodEmp()))
						if !empty(cUrlParam) .and. lower(cUrl) == lower(cUrlParam)
							cModelo := "0" // "Documentos eletrônicos"
							// MV_SPEDURL - NFE / NFSE / MDFE / MDE
							// MV_SPEDURL - GFE
							// MV_SPEDURL - TMS
							// MV_SPEDURL - FISA031 (RECOPI)
							// MV_SPEDURL - FISA095 (GNRE)
						else
							cUrlParam := SuperGetMv("MV_TAFSURL",.F.,"",FWCodEmp())
							if !empty(cUrlParam) .and. lower(cUrl) $ lower(cUrlParam)
								cModelo := "1" // "eSocial / Reinf (TAF)"
							else
								cUrlParam := SuperGetMv("MV_GPEMURL",.F.,"",FWCodEmp())
								if !empty(cUrlParam) .and. lower(cUrl) $ lower(cUrlParam)
									cModelo := "2" // "RH"
								else
									cUrlParam := SuperGetMv("MV_NFCEURL",.F.,"",FWCodEmp())
									if !empty(cUrlParam) .and. lower(cUrl) $ lower(cUrlParam)
										cModelo := "3" // "NFCe"
									endif
								endif
							endif
						endif
					endif

					if !empty(cModelo)
						FX7->(dbSetOrder(2)) // FX7_FILIAL + FX7_MODELO
						lSeek := FX7->(dbSeek( PadR(FwCodFil(), len(FX7->FX7_FILIAL)) + PadR(cModelo, len(FX7->FX7_MODELO)) ))
						if !empty(cModelo) .and. !lSeek
							lMod := .F.
							FX7->(dbSeek( PadR(FwCodFil(), len(FX7->FX7_FILIAL)) ))
							// Caso tenha definido um modelo específico, não realizar a busca com modelo em branco (FX7_MODELO)
							while FX7->(!eof()) .and. FX7->FX7_FILIAL == PadR(FwCodFil(), len(FX7->FX7_FILIAL))
								if !empty(FX7->FX7_MODELO)
									lMod := .T.
									exit
								endif
								FX7->(dbSkip())
							end
						endif
						// Caso não encontre com o modelo e não tenha para filial nenhum específico, realizar com o padrão em branco
						if !lSeek .and. !lMod
							lSeek := FX7->(dbSeek( PadR(FwCodFil(), len(FX7->FX7_FILIAL)) + PadR("", len(FX7->FX7_MODELO)) ))
						endif
					else
						FX7->(dbSetOrder(1)) // FX7_FILIAL + FX7_CREDEN
						lSeek := FX7->(dbSeek( PadR(FwCodFil(), len(FX7->FX7_FILIAL)) ))
					endif

				else
					FX7->(dbSetOrder(1)) // FX7_FILIAL + FX7_CREDEN
					lSeek := FX7->(dbSeek( PadR(FwCodFil(), len(FX7->FX7_FILIAL)) ))
				endif

				if lSeek
					lUse := !empty(FX7->FX7_CREDEN) .and. !empty(FX7->FX7_CREKEY)
					cClientId := FX7->FX7_CREDEN
					cClientSec := FX7DesKey(FX7->FX7_CREKEY)
					cCertCA := nil
					cCertPem := GetPvProfString('SSLConfigure','CertificateClient','', cArqIni)
					cCertKey := GetPvProfString('SSLConfigure','KeyClient','', cArqIni)
					cCertPass := GetPvProfString('SSLConfigure','PassPhrase','', cArqIni)
					if lUse
						SPEDPRTMSG("Utilizando credenciais da Filial - '" + PadR(FwCodFil(), len(FX7->FX7_FILIAL)) + "'" + if(_lCpoMod," - Modelo: '" + FX7->FX7_MODELO + "' ","") + " - URL: '" + alltrim(cUrl) + "'.", LOG_INFO)
					endif
				endif
				// Setar em branco, pra caso houver outro consumo que não seja uma busca definida, não ter necessidade de setar em todos os métodos
				TSSSetAuth("")
				restArea(aAreaFX7)
			endif

			if lUse .and. !FwIsInCallStack("getVersaoTSS")
				cVersao := getVersaoTSS(,cUrl)
				cVersao := alltrim(substr( cVersao , 1, (at("|", cVersao)-1)))
				if cVersao <= "12.1.027"
					lUse := .F.
					SPEDPRTMSG("O protheus esta configurado para utilizar token de autenticacao, porem o versao do TSS nao esta compativel. " + cVersao, LOG_INFO)
				endif
			endif

		endif
	endif

return lUse

/*/{Protheus.doc} TSSSetAuth
Função para setar o modelo de documento para buscar as credenciais da autenticação

/*/
function TSSSetAuth(cModelo)
	default cModelo := ""
	_cModelo := alltrim(cModelo)
return 

/*/{Protheus.doc} TSSGetAuth
Função para retornar o modelo de documento para buscar as credenciais da autenticação

/*/
static function TSSGetAuth()
return _cModelo

/*/{Protheus.doc} TSSAuth
Função para retornar o token de autenticação do TSS

/*/
static function TSSAuth(cMsgError, cURL, cClientId, cClientSec, cCA, cCert, cKey, cPassword, cMetodo)
	local cService	 := "TSSAUTHENTICATION"
	local cIdGlobal	 := ""
	local aRet		 := {}
	local aToken	 := {}
	local cToken	 := ""
	local cTokenType := ""
	local cMsg		 := ""
	local cIdEnt	 := ""
	local cHash		 := ""
	local lGlobal	 := .F.

	default cMsgError	:= ""
	default cURL		:= getUrl()
	default cClientId	:= ""
	default cClientSec	:= ""
	default cCA			:= ""
	default cCert		:= ""
	default cKey		:= ""
	default cPassword	:= ""
	default cMetodo		:= ProcName(2)

	varSetUID(UID, .T.)
	cIdGlobal := cService + cURL + cClientId + cClientSec + alltrim(xFilial("FX7"))

	// { 1    , 2            , 3   , 4                , 5             }
	// { TOKEN, REFRESH_TOKEN, DATA, TEMPO DE VALIDADE, TIPO DO TOKEN }
	if !varGetAD(UID, cIdGlobal, @aToken) .or. (valtype(aToken) <> "A" .or. len(aToken) <> 5 .or. date() > aToken[3] .or. ( (aToken[4]) <= seconds() ))

		// caso eu ja tenha o token e tem necessidade de realizar o refresh
		if valtype(aToken) == "A" .and. len(aToken) > 0 
			aToken := getTSSAuth(@cMsgError, cURL, cClientId, cClientSec, aToken[2], cCA, cCert, cKey, cPassword)
			if len(aToken) > 0
				SPEDPRTMSG("Realizado com sucesso a solicitacao de refresh do token", LOG_INFO)
				cMsg := "atualizado"
			endif
		endif

		// caso tenha que gerar um token ou se o refresh ja esteja vencido
		if len(aToken) == 0
			aToken := getTSSAuth(@cMsgError, cURL, cClientId, cClientSec, "", cCA, cCert, cKey, cPassword)
			cMsg := "gerado"
		endif

		if len(aToken) > 0
			SPEDPRTMSG("Token " + cMsg + " com sucesso ao consumir o metodo " + cMetodo + " - " + aToken[1], LOG_INFO)
			varSetAD(UID, cIdGlobal, aToken)
		else
			cIdEnt := ""
			lGlobal := .F.
			if( type( "oSigamatX" ) == "U" )
				cHash := getHashCfgEntidade(cUrl)
				lGlobal := varGetXD(UID, cHash, @cIdEnt )
			else
				cHash := alltrim(oSigamatX:M0_CGC) + alltrim(oSigamatX:M0_INSC) + alltrim(oSigamatX:M0_ESTENT) + alltrim(oSigamatX:M0_CODIGO) + alltrim(oSigamatX:M0_CODFIL) + cUrl
				lGlobal := varGetXD(UID, cHash , @cIdEnt )
			endif
			if lGlobal .and. !empty(cIdEnt)
				VarDelX( UID , cHash)
			endif
		endif

	else
		SPEDPRTMSG("Recuperou da variavel global ao consumir o metodo " + cMetodo + " - " + aToken[1], LOG_INFO)
	endif

	if len(aToken) > 0
		cToken := aToken[1]
		cTokenType := aToken[5]
		aRet := {cTokenType, cToken}
	endif

	aSize(aToken, 0)
	aToken := nil

return aRet

/*/{Protheus.doc} getTSSAuth
Função para consumir o método Token de autenticação do TSS

/*/
static function getTSSAuth(cMsgError, cURL, cClientId, cClientSec, cTokenRef, cCA, cCert, cKey, cPassword)
	local aToken	 := {}
	local lRet		 := .T.
	local oWSdl		 := nil
	local aSimple	 := {}
	local cXmlRet	 := ""
	local nPosType	 := 0
	local nPosEnt	 := 0
	local nPosSec	 := 0
	local cToken	 := ""
	local cTokenType := ""
	local nExpTime	 := 0
	local cErrParse	 := ""
	local cWarParse	 := ""
	local cError	 := ""

	default cMsgError	:= ""
	default cURL		:= getUrl()
	default cClientId	:= ""
	default cClientSec	:= ""
	default cTokenRef	:= ""
	default cCA			:= ""
	default cCert		:= ""
	default cKey		:= ""
	default cPassword	:= ""

	private oXmlToken := nil

	if empty(cClientId)
		cError := STR0015 // "Não foi definido credenciais para geração do Token de autenticação do TSS."
		cMsgError := cError
	else

		oWsdl := TWsdlManager():New()
		oWsdl:nTimeout := 120
		oWsdl:bNoCheckPeerCert := .T.
		if "https://" $ lower(cURL)
			oWsdl:cSSLCACertFile := cCA
			oWsdl:cSSLCertFile := cCert
			oWsdl:cSSLKeyFile := cKey
			oWsdl:cSSLKeyPwd := cPassword
		endif

		//Habilita log em arquivo para os comandos SOAP enviados e recebidos.
		//oWsdl:lVerbose := .T.

		lRet := oWsdl:ParseURL(lower(cURL) + "/TSSAUTHENTICATION.apw?WSDL")
		if !lRet
			cMsgError := oWsdl:cError
			cError := "[PARSEURL] " + oWsdl:cError
		else
			lRet := oWsdl:SetOperation("TOKEN")
			if !lRet
				cMsgError := oWsdl:cError
				cError := "[SETOPERATION] " + oWsdl:cError
			else
				aSimple := oWsdl:SimpleInput()
				nPosType := aScan( aSimple, {|X| alltrim(upper(X[2])) == "GRANT_TYPE"})
				if !empty(cTokenRef)
					oWsdl:SetValue(aSimple[nPosType][1], "refresh_token")
					nPosEnt := aScan( aSimple, {|X| alltrim(upper(X[2])) == "REFRESH_TOKEN"})
					oWsdl:SetValue(aSimple[nPosEnt][1], cTokenRef)
				else
					oWsdl:SetValue(aSimple[nPosType][1], "client_credentials")
					nPosEnt := aScan( aSimple, {|X| alltrim(upper(X[2])) == "CLIENT_ID"})
					nPosSec := aScan( aSimple, {|X| alltrim(upper(X[2])) == "CLIENT_SECRET"})
					oWsdl:SetValue(aSimple[nPosEnt][1], cClientId)
					oWsdl:SetValue(aSimple[nPosSec][1], cClientSec)
				endif

				lRet := oWsdl:SendSoapMsg()
				if !lRet
					cMsgError := oWsdl:cError
					cError := "[SENDSOAPMSG] " + oWsdl:cError
				else
					cXmlRet := oWsdl:GetSoapResponse()
					lRet := !empty(cXmlRet)
					if !lRet
						cMsgError := oWsdl:cError
						cError := "[GETSOAPRESPONSE] " + oWsdl:cError
					else
						cErrParse := ""
						cWarParse := ""
						oXmlToken := XmlParser(cXmlRet, "_", @cErrParse, @cWarParse )
						if empty(cErrParse) .and. empty(cWarParse)
							if type("oXmlToken:_SOAP_ENVELOPE:_SOAP_BODY:_TOKENRESPONSE:_TOKENRESULT:_ACCESS_TOKEN") == "O"
								cToken := oXmlToken:_SOAP_ENVELOPE:_SOAP_BODY:_TOKENRESPONSE:_TOKENRESULT:_ACCESS_TOKEN:Text
							endif
							if type("oXmlToken:_SOAP_ENVELOPE:_SOAP_BODY:_TOKENRESPONSE:_TOKENRESULT:_REFRESH_TOKEN") == "O"
								cTokenRef := oXmlToken:_SOAP_ENVELOPE:_SOAP_BODY:_TOKENRESPONSE:_TOKENRESULT:_REFRESH_TOKEN:Text
							endif
							if type("oXmlToken:_SOAP_ENVELOPE:_SOAP_BODY:_TOKENRESPONSE:_TOKENRESULT:_EXPIRES_IN") == "O"
								nExpTime := Val(oXmlToken:_SOAP_ENVELOPE:_SOAP_BODY:_TOKENRESPONSE:_TOKENRESULT:_EXPIRES_IN:Text)
							endif
							if type("oXmlToken:_SOAP_ENVELOPE:_SOAP_BODY:_TOKENRESPONSE:_TOKENRESULT:_TOKEN_TYPE") == "O"
								cTokenType := oXmlToken:_SOAP_ENVELOPE:_SOAP_BODY:_TOKENRESPONSE:_TOKENRESULT:_TOKEN_TYPE:Text
							endif
							if !empty(cToken)
								aToken := {cToken, cTokenRef, date(), (nExpTime - 5) + seconds(), cTokenType}
							endif
						else
							cError := STR0016 + " Error: " + cErrParse + if(!empty(cWarParse)," - Warning: " + cWarParse, "") // "Falha no parse no retorno
							cMsgError := STR0016 // "Falha no parse no retorno."
						endif
						freeObj(oXmlToken)
						oXmlToken := nil
					endif
				endif
			endif
		endif

		freeObj(oWsdl)
		oWsdl := nil

	endif

	if !lRet
		SPEDPRTMSG("Erro ao consumir o método Token - " + cError)
	endif

	if !empty(cMsgError)
		cMsgError := decodeutf8(cMsgError)
	endif

return aToken

/*/{Protheus.doc} tssHasRdm()
Valida se o Rdmake ou o fonte padrao estão compilados

@param 		cProg, string, Nome da função a ser executada
@return		logico, .T. quando a função esta compilada e liberada para execução
@author 	Felipe Martinez
@since		16/05/2021
@version	12.1.27
/*/
function tssHasRdm(cProg)
return existBlock(cProg) .or. isRdmPad(cProg)

/*/{Protheus.doc} tssExecRdm()
Executa o rdmake padrao ou o fonte padrao

@param 		cProg, string, Nome da função a ser executada
@param	 	lParamIxb, logico, indica se o parametro deve ser passado via PARAMIXB ou passada normal de parametro
			da rotina.
@param		xParam, parametros a serem passados para a função
@return		xRet, retorno da função executada
@author 	Felipe Martinez
@since		16/05/2021
@version	12.1.27
/*/
function tssExecRdm(cProg, lParamIxb, xParam1, xParam2, xParam3, xParam4, xParam5, xParam6, xParam7, xParam8)
local xRet 			:= nil
local lExec			:= .F.
local nI			:= 0
local lUserFunc		:= existBlock(cProg)

Default lParamIxb	:= .T. //se .T. a função irá passar parametros via PARAMIXB (igual ao ExecBlock())

if lParamIxb .and. lUserFunc
	xRet := execBlock(cProg,.F.,.F.,xParam1)
else

	if lUserFunc //Valida se dever ser executado como U_ (legado da chamada do fonte original)
		cProg := "U_"+cProg
		lExec := .T.
	elseIf isRdmPad(cProg) //Valida se a função esta compilada como fonte padrao
		lExec := .T.
	endIf

	//Cria a variavel Private PARAIXB para os RDMAKES PADROES que utilizam essa variavel
	if lExec
		if lParamIxb
			private PARAMIXB := array(len(xParam1))
			for nI := 1 to len(PARAMIXB)
				PARAMIXB[nI] := xParam1[nI]
			next nI
			
			xRet := &cProg.()

		else
			xRet := &cProg.(xParam1, xParam2, xParam3, xParam4, xParam5, xParam6, xParam7, xParam8)
		endIf
	else
		Help(nil,nil,STR0019,nil, STR0017 + cProg  + ".", 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0018})
		//#"Fonte não compilado" ##"Não foi possível executar o Rdmake " ###"Acessar portal do cliente, baixar os fontes correspondetes e compilar em seu ambiente"
	endIf
endIf

return xRet

/*/{Protheus.doc} isRdmPad()
Valida se é a versão 12.1.033 e o fonte padrão esta compilado (apenas a partir da versoa 12.1.033)

@param 		cProg, string, Nome da função a ser executada
@return		logico, .T. se o fonte esta compilado e liberado para execução
@author 	Felipe Martinez
@since		16/05/2021
@version	12.1.27
/*/
function isRdmPad(cProg)
return getRPORelease() >= "12.1.033" .and. existFunc(cProg)

/*/{Protheus.doc} TSSIsReady
	Valida se o TSS está no ar, como também verifica se o certificado está configurado

/*/
function TSSIsReady(cError, cUrl, nTipo, cMsg, lHelp)
	local lRetorno := .F.

	default cError	 := ""
	default cUrl	 := getUrl()
	default nTipo 	 := 1
	default cMsg	 := ""
	default lHelp	 := .T.

	//Verifica se o servidor da Totvs esta no ar
	if(isConnTSS(@cError))
		lRetorno := .T.
	else
		cError := cError + if(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		lRetorno := .F.
	endif

	//Verifica se Há Certificado configurado
	if nTipo <> 1 .And. lRetorno
		if( isCfgReady(, @cError) )
			lRetorno := .T.
		else
			if nTipo == 3
				if !"003" $ cError
					lRetorno := .F.
				endif
			else
				lRetorno := .F.
			endif
		endif
	endif

	//Verifica Validade do Certificado
	if nTipo == 2 .And. lRetorno
		lRetorno := isValidCert(, @cError, cUrl, @cMsg, lHelp)
	endif

return lRetorno

/*/{Protheus.doc} TSSMonEven
	Monitora o evento através do método NFEMONITORLOTEEVENTO

/*/
function TSSMonEven(cError, cUrl, cIdEnt, cChvIni, cChvFim, cTpEvento, cMsg)
    local lOk        := .F.
	local nMon		 := 0
	local aRetorno	 := {}

    private oWS		 := nil
	private aMonitor := {}

	default cError	  := ""
	default cUrl	  := getUrl()
	default cIdEnt    := getCfgEntidade(@cError, cUrl)
	default cChvIni	  := ""
	default cChvFim	  := ""
	default cTpEvento := ""
	default cMsg      := ""

	begin sequence

	if empty(cUrl) .or. empty(cIdEnt) .or. (empty(cChvIni) .and. empty(cChvFim)) .or. empty(cTpEvento)
		break
	endif

	if TSSIsReady(@cError, cUrl, 0, @cMsg, .F.)
		cChvFim := if(!empty(cChvFim),cChvFim,cChvIni)
		oWS := WSNFeSBRA():New()
		oWS:cUSERTOKEN	:= "TOTVS"
		oWS:cID_ENT		:= cIdEnt
		oWS:_URL		:= alltrim(cUrl)+"/NFeSBRA.apw"
		oWS:cEVENTO		:= cTpEvento
		oWS:cCHVINICIAL	:= cChvIni
		oWS:cCHVFINAL	:= cChvFim

		lOk := oWS:NFEMONITORLOTEEVENTO()
		if lOk
			if type("oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento") <> "U"
				aMonitor := if(type("oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento") <> "A", {oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento}, oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento)
				for nMon := 1 to len(aMonitor)
					aAdd( aRetorno, {	aMonitor[nMon]:nStatus,;
										If(aMonitor[nMon]:nProtocolo <> 0, alltrim(str(aMonitor[nMon]:nProtocolo)),""),;
										aMonitor[nMon]:cId_Evento,;
										aMonitor[nMon]:nAmbiente,;
										alltrim(Str(aMonitor[nMon]:nStatus)),;
										aMonitor[nMon]:cMensagem,;
										aMonitor[nMon]:nCSTATEVEN,;
										aMonitor[nMon]:cCMOTEVEN,;
										if(ValAtrib("aMonitor["+Str(nMon)+"]:nStatusCanc") <> "U", alltrim(str(aMonitor[nMon]:nStatusCanc)),""),;
										if(ValAtrib("aMonitor["+Str(nMon)+"]:cMensagemCanc") <> "U", aMonitor[nMon]:cMensagemCanc,"") })
				next
		   else
			   cError := STR0020 // "Retorno inválido"
		   endif
		else
			cError := if(empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		endif
		FwFreeObj(oWS)
		FwFreeObj(aMonitor)
	else
		cError := STR0021 // "Realize a configuração do serviço do TSS."
	endif

	end sequence

return aRetorno

static Function ValAtrib(atributo)
return (type(atributo) )

/*/{Protheus.doc} TSSEnvEven
	Realiza o envio do evento atraves do método REMESSAEVENTO

/*/
function TSSEnvEven(cError, cUrl, cIdEnt, cXmlEvento, cMsg)
    local lOk        := .F.
	local aRetorno	 := {}

	default cError	   := ""
	default cUrl	   := getUrl()
	default cIdEnt     := getCfgEntidade(@cError, cUrl)
	default cXmlEvento := ""
	default cMsg       := ""

    private oWS		 := nil

	begin sequence

	if empty(cUrl) .or. empty(cIdEnt) .or. empty(cXmlEvento)
		break
	endif

	if TSSIsReady(@cError, cUrl, 0, @cMsg, .F.)
		oWs := WSNFeSBRA():New()
		oWS:cUSERTOKEN	:= "TOTVS"
		oWS:cID_ENT		:= cIdEnt
		oWS:_URL		:= alltrim(cUrl)+"/NFeSBRA.apw"
		oWs:cXML_LOTE	:= cXmlEvento

		lOk := oWS:RemessaEvento()
		if lOk
			if type("oWS:oWsRemessaEventoResult:cString") <> "U"
				if type("oWS:oWsRemessaEventoResult:cString") <> "A"
					aRetorno := aClone({oWS:oWsRemessaEventoResult:cString})
				else
					aRetorno := aClone(oWS:oWsRemessaEventoResult:cString)
				endif
			else
				cError := STR0020 // "Retorno inválido"
			endif
		else
			cError := if(empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		endif
		FwFreeObj(oWS)

	else
		cError := if(empty(cError),STR0020,cError) // "Realize a configuração do serviço do TSS."
	endif

	end sequence

return aRetorno

/*/{Protheus.doc} TSSExpEvento
	Realiza a exportação do xml do evento da nfe

/*/
function TSSExpEvento(cError, cUrl, cIdEnt, cTpEvento, cChvIni, cChvFim, cMsg)
    local lOk        := .F.
	local aRetorno	 := {}

	default cError	   := ""
	default cUrl	   := getUrl()
	default cIdEnt     := getCfgEntidade(@cError, cUrl)
	default cTpEvento  := ""
	default cChvIni	   := ""
	default cChvFim	   := ""
	default cMsg       := ""

    private oWS		 := nil

	begin sequence

	if empty(cUrl) .or. empty(cIdEnt) .or. empty(cTpEvento) .or. (empty(cChvIni) .and. empty(cChvFim))
		break
	endif

	if TSSIsReady(@cError, cUrl, 0, @cMsg, .F.)
		cChvFim := if(!empty(cChvFim),cChvFim,cChvIni)
		oWS:= WSNFeSBRA():New()
		oWS:cUSERTOKEN	:= "TOTVS"
		oWS:cID_ENT		:= cIdEnt
		oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
		oWS:cID_EVENTO	:= cTpEvento
		oWS:cChvInicial	:= cChvIni
		oWS:cChvFinal	:= cChvFim
		lOk := oWS:NFEEXPORTAEVENTO()
		if lOk
			if type("oWS:oWSNFEEXPORTAEVENTORESULT:CSTRING") == "A"
				aRetorno := aClone(oWS:oWSNFEEXPORTAEVENTORESULT:CSTRING)
			else
				cError := STR0020 // "Retorno inválido"
			endif
		else
			cError := if(empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		endif
		FwFreeObj(oWS)

	else
		cError := if(empty(cError),STR0020,cError) // "Realize a configuração do serviço do TSS."
	endif

	end sequence

return aRetorno

/*/{Protheus.doc} ConfCert
Função para configurar o certificado digital
@author Valter Silva
@since  25/06/2021
/*/
Function ConfCert(cIdEnt,cUrl,cError,nTipo,cCert,cKey,cPassWord,cSlot,cLabel,cModulo,cIdHex,cCertRes,lPassFormat)

Local oWS
Local lRetorno 			:= .T.

default cIdHex	 		:= ""
default cCertRes 		:= ""
default cError	 		:= ""
default cURL     		:= getUrl()
default cIdEnt   		:= getCfgEntidade(@cError, cURL)
default lPassFormat		:= .F.

If empty(cIdEnt) .or. cIdEnt =='000000' .or. !Empty(cError) 
	If !Empty(cError) 
		cCertRes := cError
	EndIf
	lRetorno := .F.
EndIf

if lRetorno
	
	//tratamento para quando a senha do certificado termina em espaços em branco
	cPassWord := iif(lPassFormat,cPassWord,AllTrim(cPassWord))

	If nTipo <> 3 
		oWs:= WsSpedCfgNFe():New()
		oWs:cUSERTOKEN   := "TOTVS"
		oWs:cID_ENT      := cIdEnt
		oWs:cCertificate := FsLoadTXT(cCert)
		If nTipo == 1
			oWs:cPrivateKey  := FsLoadTXT(cKey)
		EndIf
		oWs:cPASSWORD    := cPassWord
		oWS:_URL         := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		If IIF(nTipo==1,oWs:CfgCertificate(),oWs:CfgCertificatePFX())
		    cCertRes:= IIF(nTipo==1,oWS:cCfgCertificateResult,oWS:cCfgCertificatePFXResult)	
		Else
			lRetorno := .F.
			cCertRes  := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		EndIf
	EndIf
	If  nTipo == 3
		oWs:= WsSpedCfgNFe():New()
		oWs:cUSERTOKEN   := "TOTVS"
		oWs:cID_ENT      := cIdEnt
		oWs:cSlot        := AllTrim(cSlot)
		oWs:cModule      := AllTrim(cModulo)
		oWs:cPASSWORD    := cPassWord
		If !Empty( cIdHex )
			oWs:cIDHEX      := AllTrim(cIdHex)
			oWs:cLabel      := ""
		Else
			oWs:cIDHEX      := ""
			oWs:cLabel       := cLabel

		EndIf
		If nTipo == 1
			oWs:cPrivateKey  := FsLoadTXT(cKey)
		EndIf
		oWs:cPASSWORD    := cPassWord
		oWS:_URL         := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		If oWs:CfgHSM()
			cCertRes  := oWS:cCfgHSMResult
		Else
			lRetorno := .F.
			cCertRes  := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		EndIf
	EndIf
EndIf

Return(lRetorno)

/*/{Protheus.doc} FsLoadTXT
Funcao de leitura de arquivo texto para anexar ao layout.
@author Valter Silva
@since  25/06/2021
/*/
Static Function FsLoadTXT(cFileImp)

Local cTexto		:= ""
local cCopia		:= ""
local cExt			:= ""
Local nHandle		:= 0
Local nTamanho	:= 0

if left(cFileImp, 1) # "\" .And. !IsSrvUnix()
	CpyT2S(cFileImp,"\")
endif

nHandle := FOpen(cFileImp)
nTamanho := Fseek(nHandle,0,FS_END)
FSeek(nHandle,0,FS_SET)
FRead(nHandle,@cTexto,nTamanho)
FClose(nHandle)

SplitPath(cFileImp,/*cDrive*/,/*cPath*/, @cCopia,cExt)
FErase("\"+cCopia+cExt)

Return(cTexto)

/*/{Protheus.doc} SpedValidCert
Função para retonar se certificado foi configurado corretamente.
@author Valter Silva
@since  25/06/2021
/*/
function SpedValidCert(cIdEnt, cUrl, cError)
	local lRet	:= .T.
	local nX
	local oWS	:= nil

	default cError	 := ""
	default cURL     := getUrl()
	default cIdEnt   := getCfgEntidade(@cError, cURL)

	if( !empty(cIdEnt) )
		oWS := WsSpedCfgNFe():New()
		oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWs:cUserToken := "TOTVS"
		oWs:cID_ENT    := cIdEnt
		oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"

		if oWs:CFGStatusCertificate()
			if len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE) > 0

				for nX := 1 To Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE)
					if oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nX]:DVALIDTO < Date()
						lRet := .F.
					endif	
				Next nX
			else
				lRet := .F.
			endif
		endif

		freeObj(oWS)
		oWS := nil

	else
		lRet := .F.
	endif

return lRet
