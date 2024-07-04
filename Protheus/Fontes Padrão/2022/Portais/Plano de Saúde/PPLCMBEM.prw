#INCLUDE "APWEBEX.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �PLSABPRAC   � Autor � F�bio S. dos Santos  � Data � 26/10/2015 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada da pagina de Primeiro Acesso.					     ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Web Function PLSABPRAC()
Local cHtml   := ""
PRIVATE cMsgs	   := ""

WEB EXTENDED INIT cHtml //START "InSite"

//������������������������������������������������������������������������Ŀ
//�Obj																	   �
//��������������������������������������������������������������������������
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )
//������������������������������������������������������������������������Ŀ
//� Parametro															   �
//��������������������������������������������������������������������������
oObj:cUSERCODE	:= "MSALPHA"
oObj:nTPPOR		:= getTpPortal()
oObj:cROTINA	:= "PLSABPRAC"
oObj:cCODMSG	:= ""
oObj:cIDIOMA	:= "POR"

If oObj:GetMsgPortal()
	cMsgs := oObj:cGETMSGPORTALRESULT
EndIf

//������������������������������������������������������������������������Ŀ
//� Chamada do .APH		                                                   �
//��������������������������������������������������������������������������

cHtml += ExecInPage("PPLPRIACP") //PPLPRIACP

WEB EXTENDED END
//������������������������������������������������������������������������Ŀ
//� Fim da rotina			                                               �
//��������������������������������������������������������������������������
Return PLSDECODE(cHtml)

/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  � PLSPESQPA  � Autor � F�bio S. dos Santos  � Data � 27/10/2015 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina para validar o cpf no primeiro acesso.				 ���
���          � 								                                 ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Web Function PLSPESQPA()
Local cResult	:= "true|"
Local oObj		:= NIL
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml //START "InSite"
//������������������������������������������������������������������������Ŀ
//� oBJ																	   �
//��������������������������������������������������������������������������
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )
//������������������������������������������������������������������������Ŀ
//� Parametros															   �
//��������������������������������������������������������������������������
oObj:cUserCode	:= "MSALPHA"
oObj:cCpfCnpj	:= HttpGet->cCpf
//������������������������������������������������������������������������Ŀ
//� Retorna dados														   �
//��������������������������������������������������������������������������
If oObj:PLSPSQVIDA()
	cResult += oObj:CPLSPSQVIDARESULT
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  � PPLSOLMBEN � Autor � F�bio S. dos Santos  � Data � 30/10/2015 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina para chamar a tela de solicita��o de Benefici�rios.    ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Web Function PPLSOLMBEN()
Local cHtml 	:= ""
Local oObj
Private cCodMat	:= ""

WEB EXTENDED INIT cHtml START "InSite"

//recupera valor do par�metro
oObj := WSCFGDICTIONARY():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "CFGDICTIONARY.APW" )
oObj:cUSERCODE	:= "MSALPHA"
oObj:cMVPARAM	:= "MV_EXCBEN"

If oObj:GETPARAM()
	HttpSession->lExclui	:= oObj:cGETPARAMRESULT
EndIf

If HTTPSESSION->USR_INFO[1]:OWSUSERLOGPLS:NTPPORTAL == 3
	If Len(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA) > 0
		cCodMat := HTTPSESSION->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CFAMILIA
	Else
		cCodMat := ""
	EndIf
EndIf

cHtml += ExecInPage("PPLSOLMBEN")

WEB EXTENDED END
//������������������������������������������������������������������������Ŀ
//� Fim da Rotina														   �
//��������������������������������������������������������������������������
Return PLSDECODE(cHtml)

/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �PPLCONBEN   � Autor � F�bio S. dos Santos  � Data � 23/11/2015 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada da pagina de consulta de solicita��es de benefici�rios���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Web Function PPLCONBEN()
Local cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"
//�����������������������������������������Ŀ
//� Chamada do .APH						    �
//�������������������������������������������
cHtml := ExecInPage( "PPLCONBEN" )

WEB EXTENDED END
//�����������������������������������������Ŀ
//� Fim da rotina					        �
//�������������������������������������������
Return cHtml


//-------------------------------------------------------------------
/*/{Protheus.doc} PLBMTBLOQ
Fun��o para buscar os motivos de bloqueio e alimentar o combo de motivos
de bloqueio
@author Oscar Zanin
@since 04/12/2015
@version P12
/*/
//-------------------------------------------------------------------
Web Function PLBMTBLOQ()
LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
Local oObj
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"

If oObj:DADRETBLOQ()

	nResult := Len(oObj:oWSDADRETBLOQRESULT:oWSSDADBLOQ)
	if nResult > 0
		xCols := "["

		For nI := 1 to nResult
			xCols += "{"
			xCols +=  "1:{field:'cDescri',value:'" +  SubStr(oObj:oWSDADRETBLOQRESULT:oWSSDADBLOQ[nI]:CCODBLO,1,50) + '$' + SubStr(oObj:oWSDADRETBLOQRESULT:oWSSDADBLOQ[nI]:CDESCRI,1,50) +"'}" + Iif( nResult != nI ,"},","}]" )
		Next

		cResult += xCols + "|"
	endif
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLBLIDOC
Fun��o para buscar os documentos vinculados ao motivo de exclus�o selecionado
@author Oscar Zanin
@since 07/12/2015
@version P12
/*/
//-------------------------------------------------------------------
Web Function PLBLIDOC()
Local cResult	:= "true|"
Local oObj		:= NIL
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():new()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WschgUrl( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cCodMot	:= HttpGet->cCodMot

If oObj:RETDOC()
	cResult += oObj:cRETDOCRESULT
else
	cResult := "false|"
EndIF

WEB EXTENDED END

Return cResult


//-------------------------------------------------------------------
/*/{Protheus.doc} PLEXCBEN1
Fun��o para realizar a pr�0grava��o da exclus�o
@author Oscar Zanin
@since 07/12/2015
@version P12
/*/
//-------------------------------------------------------------------
web Function PLEXCBEN1()

Local cResult := "true|"
Local oObj		:= NIL
Local cCodMat	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():new()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgUrl( @oObj, "PLSXFUN.APW" )

If Len(HTTPSESSION->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA) > 0//Len(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA) > 0
	cCodMat := HTTPSESSION->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CFAMILIA
	cVerPla := HTTPSESSION->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CVERPLA
	cCodPla := HTTPSESSION->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CCODPLA
Else
	cCodMat := HTTPSESSION->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
	cVerPla := ""
	cCodPla := ""
EndIf

oObj:cUserCode	:= "MSALPHA"
oObj:cCRecno		:= HttpGet->cRecno
oObj:nTp			:= HTTPSESSION->USR_INFO[1]:OWSUSERLOGPLS:NTPPORTAL
oObj:cUsrCod		:= cCodMat
oObj:cCodMot		:= HttpGet->cCodMot
oObj:cVsPlan		:= cVerPla
oObj:cCdPlan		:= cCodPla

If oObj:PREEXCBEN()
	cResult += oObj:cPREEXCBENRESULT
else
	cResult := "false|"
EndIf

WEB EXTENDED END

return PLSDECODE(cResult)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLEXC2BEN
Fun��o para fazer a p�s grava��o da exclus�o
@author Oscar Zanin
@since 07/12/2015
@version P12
/*/
//-------------------------------------------------------------------
web Function PLEXC2BEN()

Local cResult := "true|"
Local oObj		:= NIL
Local cCodMat	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():new()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgUrl( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cCRecno		:= HttpGet->cRecno
oObj:nTp			:= HTTPSESSION->USR_INFO[1]:OWSUSERLOGPLS:NTPPORTAL
oObj:cCodMot		:= HttpGet->cCodMot
oObj:dDtExclu		:= cTod(HttpGet->dDtExclu)

If oObj:POSEXCBEN()
	cResult += oObj:cPOSEXCBENRESULT
else
	cResult := "false|"
EndIf

WEB EXTENDED END

return PLSDECODE(cResult)


//-------------------------------------------------------------------
/*/{Protheus.doc} PPLRETCBNF
Retorna Cr�ticas da BEG/BEL para o protal do benefici�rio

@author Renan Martins
@since 07/2016
@version P12
/*/
//-------------------------------------------------------------------
Web Function PPLRETCBNF()
LOCAL cResult  	:= "true|"
LOCAL cChave  := HttpGet->cChave
LOCAL nI
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//�������������������������������������������������������������������������
//� oBJ
//�������������������������������������������������������������������������
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//�������������������������������������������������������������������������
//� Parametros
//�������������������������������������������������������������������������
oObj:cUserCode	:= "MSALPHA"
oObj:cChave  	:= cChave

If oObj:RETCRIAUT()

	cResult += oOBJ:cRETCRIAUTRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

//�������������������������������������������������������������������������
//� Fim da rotina
//�������������������������������������������������������������������������
Return PLSDECODE(cResult)

/*/{Protheus.doc} PLVALNOME
Valida o nome do benefici�rio e nome da m�e na inclus�o de benefici�rios no portal do benefici�rio
@author	Thiago Ribas
/*/
Web Function PLVALNOME()

LOCAL cRet := "true|"
LOCAL aResult := {}

oObj := WSPLCADWEB():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLCADWEB.APW" )

//Parametros
oObj:cUserCode	:= "MSALPHA"
oObj:cNome      := httpGet->cNome
oObj:cMsgCrit   := httpGet->cMsgCrit

If oObj:ValNomeBe()
	cRet += oObj:cValNomeBeRESULT
EndIf

Return PLSDECODE(cRet)

/*/{Protheus.doc} PPLVALTIT
Verifica se o c�digo de titular configurado no sistema � o mesmo do benefici�rio selecionado
na inclus�o de benefici�rios no portal
/*/
Web Function PPLVALTIT()

Local oObj
Local cResult := ""

oObj := WSPLCADWEB():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLCADWEB.APW" )

oObj:cUSERCODE	:= "MSALPHA"
oObj:cGrauPa    := httpGet->cGrauPa

If oObj:ValCodTit()
	cResult := oObj:CVALCODTITRESULT + "|" + oObj:cGrauPa
Else
	cResult := "false|Erro na execu��o do WS PPLVALTIT"
EndIf

Return cResult

//----------------------------------------------------------------------------
/*/{Protheus.doc} GetVldFam
Verifica se a familia esta bloqueada.

@author Cesar Almeida
@since 05/07/2022
@version Protheus 12
/*/
//----------------------------------------------------------------------------
Web Function PPLVLDFAM()

Local oObj
Local cResult := ""

oObj := WSPLCADWEB():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLCADWEB.APW" )

oObj:cUSERCODE	:= "MSALPHA"
oObj:cDataAux := httpGet->cMatTit

If oObj:GetVldFam()
	cResult := oObj:CGETVLDFAMRESULT
EndIf

Return cResult

