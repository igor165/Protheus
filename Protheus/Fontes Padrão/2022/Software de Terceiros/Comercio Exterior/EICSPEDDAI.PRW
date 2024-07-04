#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "EICSPEDDAI.ch"

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : EICSPEDDAI()
Parametros : Nenhum
Retorno    : lOk
Objetivos  : Chamada principal para configuração do certificado digital
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/  
Function EICSPEDDAI()
Local oWizard
Local oCombo 
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cCert     := Space(250)
Local cKey      := Space(250)
Local cModulo   := Space(250)
Local cPassWord := Space(24)
Local cCombo    := ""
Local cSlot     := Space(4)
Local cLabel    := Space(250)
Local cIdHex	:= Space(250)
Local aTexto    := {}
Local lUsaIdHex := GetNewPar("MV_A3IDHEX",.F.) 
Local lOk := .F.
Private cVersaoTSS	:= ""

oWS := WsSpedCfgNFe():New()
oWS:cUSERTOKEN := "TOTVS"
oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
If oWs:CFGCONNECT()
   oWS:cID_ENT    := AllTrim(GetIdEnt())
   lOk := oWs:CfgTSSVersao()
   If lOk               
      cVersaoTSS:=oWs:cCfgTSSVersaoResult
   EndIf
EndIf

lOk := .F.

If PswAdmin(,,RetCodUsr()) == 0

    //Montagem da Interface
	aAdd(aTexto,{})
	aTexto[1] := STR0001 + CRLF //"Esta rotina tem como objetivo ajuda-lo na configuração da integração com o Protheus com o serviço Totvs Services SPED. "
	aTexto[1] += STR0002 // "O primeiro passo é configurar a conexão do Protheus com o serviço."
	
	DEFINE WIZARD oWizard ;
		HEADER STR0003 ; // "Assistente de configuração da Declaração Amazonense de Importação" 
		HEADER STR0004 ; // "Atenção"
		MESSAGE STR0005 ; // "Siga atentamente os passos para a configuração da Declaração Amazonense de Importação."
		TEXT aTexto[1] ;
		NEXT {|| .T.} ;
		FINISH {||.T.}
	
	CREATE PANEL oWizard  ;
		HEADER STR0003 ; // "Assistente de configuração da Declaração Amazonense de Importação" 
		MESSAGE ""	;
		BACK {|| .F.} ;
		NEXT {|| IsReady(cURL,3,.T.)} ;
		PANEL
		
	@ 010,010 SAY STR0006 SIZE 270,010 PIXEL OF oWizard:oMPanel[2] // "Informe a URL do servidor Totvs Services" 
	@ 025,010 GET cURL SIZE 270,010 PIXEL OF oWizard:oMPanel[2]

	CREATE PANEL oWizard  ;
		HEADER STR0003 ; // "Assistente de configuração da Declaração Amazonense de Importação" 
		MESSAGE ""	;
		BACK {|| .T.} ;
		NEXT {|| IsCDReady(@oCombo:nAt,@cCert,@cKey,@cPassWord,@cSlot,@cLabel,@cModulo)} ;
		PANEL

	@ 005,010 SAY STR0007 SIZE 270,010 PIXEL OF oWizard:oMPanel[3] // "Informe o tipo de certificado digital"
	@ 005,105 COMBOBOX oCombo VAR cCombo ITEMS {"Formato Apache(.pem)","Formato PFX(.pfx ou .p12)","HSM"} SIZE 120,010 OF oWizard:oMPanel[3] PIXEL //######
	@ 020,010 SAY STR0008 SIZE 270,010 PIXEL OF oWizard:oMPanel[3] // "Informe o nome do arquivo do certificado digital" 
	@ 030,010 GET cCert SIZE 240,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt <> 3
	TButton():New( 030,250,"Drive:",oWizard:oMPanel[3],{||cCert := cGetFile(IIF(oCombo:nAt == 1,"Arquivos .PEM |*.PEM", "Arquivos(.PFX)|*.PFX|Arquivos(.P12)|*.P12"),STR0009,0,"",.T.,GETF_LOCALHARD),.T.},29,12,,oWizard:oMPanel[3]:oFont,,.T.,.F.,,.T., ,, .F.) // "Selecione o certificado"
	@ 050,010 SAY STR0010 SIZE 270,010 PIXEL OF oWizard:oMPanel[3] // "Informe o nome do arquivo da private key"
	@ 060,010 GET cKey SIZE 240,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt == 1
	TButton():New( 060,250,"Drive:",oWizard:oMPanel[3],{||cKey := cGetFile("Arquivos .PEM |*.PEM",STR0009,0,"",.T.,GETF_LOCALHARD),.T.},29,12,,oWizard:oMPanel[3]:oFont,,.T.,.F.,,.T., ,, .F.) // "Selecione o certificado"
	@ 080,010 SAY STR0011 SIZE 100,010 PIXEL OF oWizard:oMPanel[3] // "Slot do certificado digital"
	@ 080,100 GET cSlot SIZE 060,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt == 3 PICTURE "9999"
	@ 095,010 SAY STR0012 SIZE 100,010 PIXEL OF oWizard:oMPanel[3] // "Label do certificado digital" 
	@ 095,100 GET cLabel SIZE 060,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt == 3
	@ 110,010 SAY STR0013 SIZE 270,010 PIXEL OF oWizard:oMPanel[3] // "Informe senha do arquivo digital" 
	@ 110,110 GET cPassWord SIZE 060,010 PIXEL OF oWizard:oMPanel[3] PASSWORD
	@ 125,010 SAY STR0014 SIZE 270,010 PIXEL OF oWizard:oMPanel[3] // "Informe o nome do arquivo do modulo HSM" 
	@ 125,120 GET cModulo SIZE 100,010 PIXEL OF oWizard:oMPanel[3] WHEN oCombo:nAt == 3
	
	CREATE PANEL oWizard  ;
		HEADER STR0003 ; // "Assistente de configuração da Declaração Amazonense de Importação" 
		MESSAGE "";
		BACK {|| oWizard:SetPanel(2),.T.} ;
		FINISH {|| lOk := .T.} ;
		PANEL
	
	aadd(aTexto,{})
	aTexto[2] := STR0015 // "Você concluiu com sucesso a configuração da integração do Protheus para o Totvs Services."
	@ 010,010 GET aTexto[2] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[4]
	
	ACTIVATE WIZARD oWizard CENTERED
Else
	Help( "", 1, "SEMPERM" )
EndIf

Return lOk

Function EICIsReady(cURL,nTipo,lHelp)
Return IsReady(cURL,nTipo,lHelp)

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : IsReady()
Parametros : cURL  - Endereço URL TSS
             nTipo - Tipo de validacao
             lHelp - Flag para apresentação de Help
Retorno    : lRetorno
Objetivos  : Validar a conexão com o TSS, se ja esta configurado o certificado digital e a validade.
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/  
Static Function IsReady(cURL,nTipo,lHelp)
Local nX       := 0
Local cHelp    := ""
Local oWS
Local lRetorno := .F.
DEFAULT nTipo := 1
DEFAULT lHelp := .F.

If !Empty(cURL)
   PutMV("MV_SPEDURL",cURL)
EndIf

//EasyGParam() //Limpa o cache de parametros - nao retirar //LRS - 11/07/2018 - Utilizado anteriormente o SUPERGETMV

DEFAULT cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)

oWs := WsSpedCfgNFe():New()
oWs:cUserToken := "TOTVS"
oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"

If oWs:CFGCONNECT()
   lRetorno := .T.
Else
   If lHelp
      Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
   EndIf
   lRetorno := .F.
EndIf

If nTipo <> 1 .And. lRetorno
   oWs:cUserToken := "TOTVS"
   oWs:cID_ENT    := GetIdEnt()
   oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"		
   If oWs:CFGReady()
      lRetorno := .T.
   Else
      If nTipo == 3
         cHelp := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
         If lHelp .And. !"003" $ cHelp
            Aviso("SPED",cHelp,{"Ok"},3)
            lRetorno := .F.
         EndIf		
      Else
         lRetorno := .F.
      EndIf
   EndIf
EndIf

If nTipo == 2 .And. lRetorno
   oWs:cUserToken := "TOTVS"
   oWs:cID_ENT    := GetIdEnt()
   oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"		
   If oWs:CFGStatusCertificate()
      If Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE) > 0
         For nX := 1 To Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE)
            If oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nx]:DVALIDTO-30 <= Date()
               Aviso("SPED",STR0016+Dtoc(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nX]:DVALIDTO),{"Ok"},3) // "O certificado digital irá vencer em: "
            EndIf
         Next nX		
      EndIf
   EndIf
EndIf

Return lRetorno

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : IsCDReady()
Parametros : nTipo     - Tipo de certificado digital
             cCert     - Nome do arquivo juntamente com o caminho onde esta o mesmo
             cKey      - Private key do certificado digital
             cPassWord - Senha do certificado digital
             cSlot     - Slot
             cLabel    - Label
             cModulo   - Modulo
             cIdHex    - Id do certificado digital Hex
Retorno    : lRetorno
Objetivos  : Configurar o certificado digital
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/  
Static Function IsCDReady(nTipo,cCert,cKey,cPassWord,cSlot,cLabel,cModulo,cIdHex)
Local oWS
Local cIdEnt   := ""
Local lRetorno := .T.
Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)

Default cIdHex := ""

If ((!Empty(cCert) .And. !Empty(cKey) .And. !Empty(cPassWord) .And. nTipo == 1) .Or.;
	(!Empty(cSlot) .And. !Empty(cLabel) .And. !Empty(cPassword) .And. nTipo == 3) .Or.;
	(!Empty(cSlot) .And. !Empty(cIdHex) .And. !Empty(cPassword) .And. nTipo == 3) .Or.;
 	(!Empty(cCert) .And. !Empty(cPassWord) .And. nTipo == 2)) .Or. !IsReady(,2)
   
   cIdEnt := AllTrim(GetIdEnt())
   
   If nTipo <> 3 .And. !File(cCert)
      Aviso("SPED",STR0017,{"Ok"},3) // "Arquivo não encontrado."
      lRetorno := .F.
   EndIf
   
   If nTipo == 1 .And. !File(cKey) .And. lRetorno
      Aviso("SPED",STR0017,{"Ok"},3) // "Arquivo não encontrado."
      lRetorno := .F.
   EndIf
   
   If !Empty(cIdEnt) .And. lRetorno .And. nTipo <> 3
      oWs:= WsSpedCfgNFe():New()
      oWs:cUSERTOKEN   := "TOTVS"
      oWs:cID_ENT      := cIdEnt
      oWs:cCertificate := FsLoadTXT(cCert)

      If nTipo == 1
         oWs:cPrivateKey  := FsLoadTXT(cKey)
      EndIf
   
      oWs:cPASSWORD    := AllTrim(cPassWord)
      oWS:_URL         := AllTrim(cURL)+"/SPEDCFGNFe.apw"
      
      If IIF(nTipo==1,oWs:CfgCertificate(),oWs:CfgCertificatePFX())
         Aviso("SPED",IIF(nTipo==1,oWS:cCfgCertificateResult,oWS:cCfgCertificatePFXResult),{"Ok"},3)
      Else
         lRetorno := .F.
         Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
      EndIf	
   EndIf
   
   If !Empty(cIdEnt) .And. lRetorno .And. nTipo == 3
      oWs:= WsSpedCfgNFe():New()
      oWs:cUSERTOKEN   := "TOTVS"
      oWs:cID_ENT      := cIdEnt
      oWs:cSlot        := cSlot
      oWs:cModule      := AllTrim(cModulo)
      oWs:cPASSWORD    := AllTrim(cPassWord)
      
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
      
      oWs:cPASSWORD    := AllTrim(cPassWord)
      oWS:_URL         := AllTrim(cURL)+"/SPEDCFGNFe.apw"
      If oWs:CfgHSM()
         Aviso("SPED",oWS:cCfgHSMResult,{"Ok"},3)
      Else
         lRetorno := .F.
         Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
      EndIf	

   EndIf

EndIf

Return lRetorno

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : GetIdEnt()
Parametros : Nenhum
Retorno    : cIdEnt
Objetivos  : Retornar o Id da entidade
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/  
Static Function GetIdEnt()
Local aArea  := GetArea()
Local cIdEnt := ""
Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs

   //Obtem o codigo da entidade
   oWS := WsSPEDAdm():New()
   oWS:cUSERTOKEN := "TOTVS"
   oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
   oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
   oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
   oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM		
   oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
   oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
   oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
   oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
   oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
   oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
   oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
   oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
   oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
   oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
   oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
   oWS:oWSEMPRESA:cCEP_CP     := Nil
   oWS:oWSEMPRESA:cCP         := Nil
   oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
   oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
   oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
   oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
   oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
   oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
   oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
   oWS:oWSEMPRESA:cINDSITESP  := ""
   oWS:oWSEMPRESA:cID_MATRIZ  := ""
   oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
   oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"

   If oWs:ADMEMPRESAS()
      cIdEnt  := oWs:cADMEMPRESASRESULT
   Else
      Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
   EndIf

   RestArea(aArea)

Return cIdEnt

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : FsLoadTXT()
Parametros : cFileImp - Arquivo do certificado digital
Retorno    : cTexto
Objetivos  : Ler e retornar o arquivo do certificado digital
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/  
Static Function FsLoadTXT(cFileImp)

Local cTexto     := ""
Local cNewFile   := ""
Local cExt       := "" 
Local cStartPath := GetSrvProfString("StartPath","")
Local nHandle    := 0
Local nTamanho   := 0
   
   cStartPath := StrTran(cStartPath,"/","\")
   cStartPath +=If(Right(cStartPath,1)=="\","","\")

   CpyT2S(cFileImp,cStartPath)
   SplitPath(cFileImp,/*cDrive*/,/*cPath*/, @cNewFile,cExt)
   cNewFile := cNewFile+cExt

   nHandle := FOpen(cNewFile)
   nTamanho := Fseek(nHandle,0,FS_END)
   FSeek(nHandle,0,FS_SET)
   FRead(nHandle,@cTexto,nTamanho)
   FClose(nHandle)
   FErase(cNewFile)

Return cTexto

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : AssinatDigital()
Parametros : cUserToken - TOTVS
             cXml       - XML (String)
             nTpDoc     - 1 - Declaracao Amazonense de Importacao / 2 - Matriz de Tributaçao
             cVersao    - Versao do arquivo XML
Retorno    : cXmlAssinado
Objetivos  : Retornar o arquivo do XML assinado
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/  
Function AssinatDigital(cUserToken,cXml,nTpDoc,cVersao)
Local cXmlAssinado := ""
Local cIdEnt := GetIdEnt()
Local oWSDIESERVICE := WSDIESERVICE():New()
Local cTexto := ""

Begin Sequence

   If Empty(cIdEnt)
      Break
   EndIf

   oWSDIESERVICE:DIeCfgVersao(cUserToken,cIdEnt,cVersao,nTpDoc) 
   oWSDIESERVICE:DIeAssinatura(cUserToken,cIdEnt,cXml,nTpDoc) 
   If ValType(oWSDIESERVICE:OWSDIEASSINATURARESULT) == "O" .And. ValType(oWSDIESERVICE:OWSDIEASSINATURARESULT:CXMLSIG) == "C" .And. ;
      !Empty(oWSDIESERVICE:OWSDIEASSINATURARESULT:CXMLSIG)
      cXmlAssinado := oWSDIESERVICE:OWSDIEASSINATURARESULT:CXMLSIG
   ElseIf ValType(oWSDIESERVICE:OWSDIEASSINATURARESULT) == "O" .And. ValType(oWSDIESERVICE:OWSDIEASSINATURARESULT:CMSGVLDSCHEMA) == "C" .And. ;
      !Empty(oWSDIESERVICE:OWSDIEASSINATURARESULT:CMSGVLDSCHEMA)
      cTexto := STR0018 + CHR(10) + CHR(13) // "O arquivo não pode ser gerado devido a seguinte validação do XML."
      cTexto += STR0019 + CHR(10) + CHR(13) + CHR(10) + CHR(13) // "Conforme apresentado pelo Totvs Service Sped: "
      cTexto += oWSDIESERVICE:OWSDIEASSINATURARESULT:CMSGVLDSCHEMA
      EecView(cTexto,STR0004) // "Atenção"
      cXmlAssinado := ""
   Else
      EecView(STR0020,STR0004) // "O Totvs Service Sped não está configurado corretamente.","Atenção"
   EndIf

End Sequence

Return cXmlAssinado

/*-----------------------------------------------------------------------------------------------------------------------
Funcao     : DAIXsdVersao()
Parametros : cUserToken - TOTVS
             nTpDoc     - 1 - Declaracao Amazonense de Importacao / 2 - Matriz de Tributaçao
             cVersao    - Versao do arquivo XML
Retorno    : cVersaoTSS
Objetivos  : Validar a versao do arquivo xml
Autor      : Bruno Akyo Kubagawa
-------------------------------------------------------------------------------------------------------------------------*/ 
Function DAIXsdVersao(cUserToken,cVersao,nTpDoc)
Local cVersaoTSS := ""    
Local cWSError := ""
Local cSoapFCode := ""
Local cIdEnt := GetIdEnt()
Local oWSDIESERVICE := WSDIESERVICE():New()

//nTpDoc
//1 - Documento de importação eletrônico
//2 - Matriz de tributação do importador

Begin Sequence

   oWSDIESERVICE:DIeCfgVersao(cUserToken,cIdEnt,cVersao,nTpDoc) 
   If Empty(cWSError := GetWSCError()) .And. Valtype(oWSDIESERVICE:OWSDIECFGVERSAORESULT) == "O" .And. Valtype(oWSDIESERVICE:OWSDIECFGVERSAORESULT:cVerConfig) == "C"
      cVersaoTSS := oWSDIESERVICE:OWSDIECFGVERSAORESULT:cVerConfig
   Else
      cSoapFCode  := GetWSCError(2)
      If !Empty(cSoapFCode) 
         MsgStop(GetWSCError(3),cSoapFCode)
      Else
         MsgStop(cWSError,'Atenção')
      Endif
   EndIf

End Sequence

Return cVersaoTSS