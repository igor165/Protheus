#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "AP5MAIL.CH"
/*/
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Funcao    � PPLSW00 � Autor � Alexander Santos	   � Data � 09.06.06 ���
������������������������������������������������������������������������Ĵ��
���Descricao � Web Function Generica									 ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Web Function PPLSW00()

LOCAL  oObj 		:= NIL
LOCAL cHtml := ""
LOCAL cCaminho 	:= getWebDir()+getPrtSkin()
LOCAL aJsPls := directory(cCaminho+"\jspls.js")
LOCAL aJsUser := directory(cCaminho+"\jsuser.js")

WEB EXTENDED INIT cHtml START "InSite"

//�������������������������������������������������������������������������
//� oBJ
//�������������������������������������������������������������������������
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"

HttpSession->cDtJs := "jspls@"+dtos(aJsPls[1][3])+strtran(aJsPls[1][4],":","")+"|jsuser@"+dtos(aJsUser[1][3])+strtran(aJsUser[1][4],":","")

If oObj:ExNotPort()

	HttpSession->lExisTbl := oObj:lExNotPortRESULT
EndIf

cHtml += ExecInPage( "PPLSW00" )

WEB EXTENDED END

Return cHtml
/*/
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Funcao    � PPLSW0A � Autor � Alexander Santos	   � Data � 09.06.06 ���
������������������������������������������������������������������������Ĵ��
���Descricao � Frame Topo												 ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Web Function PPLSW0A()

Local cHtml := ""

WEB EXTENDED INIT cHtml

cHtml += ExecInPage( "PPLSW0A" )

WEB EXTENDED END

Return cHtml
/*/
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Funcao    � PPLSW0B � Autor � Alexander Santos	   � Data � 09.06.06 ���
������������������������������������������������������������������������Ĵ��
���Descricao � Frame Menu												 ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Web Function PPLSW0B()

Local cHtml := ""

WEB EXTENDED INIT cHtml

cHtml += ExecInPage( "PPLSW0B" )

WEB EXTENDED END

Return cHtml
/*/
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Funcao    � PPLSW0C � Autor � Alexander Santos	   � Data � 09.06.06 ���
������������������������������������������������������������������������Ĵ��
���Descricao � Frame Principal											 ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Web Function PPLSW0C()
LOCAL cHtmlBen	:= ""
LOCAL cHtml := ""
LOCAL oObj

WEB EXTENDED INIT cHtml START "InSite"

If HttpSession->MPortal == "000010"  // PORTAL DO BENEFICIARIO/EMPRESA
	cHtmlBen := PLSTPTLBEN()
EndIf


oObj := WSUSERPRESENTATION():New()

IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "USERPRESENTATION.apw" )

If Empty( HttpSession->PPLSW0CINST )
	HttpSession->PPLSW0CINST := { Nil, Nil }
EndIf

If !Empty(cHtmlBen)
	HttpSession->PPLSW0CINST[1] := cHtmlBen
ElseIf oObj:GETPRESENTATION()
	HttpSession->PPLSW0CINST[1] := oObj:cGETPRESENTATIONRESULT
EndIf

If oObj:GETDAILYNEWS()
	HttpSession->PPLSW0CINST[2] := oObj:oWSGETDAILYNEWSRESULT
EndIf

If oObj:GETPHOTO()
	HttpSession->_IMG_INST := oObj:cGETPHOTORESULT
EndIf

cHtml += ExecInPage( "PPLSW0C" )

WEB EXTENDED END

Return cHtml
/*/
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Funcao    � PPLSOUT � Autor � Alexander Santos	   � Data � 09.06.06 ���
������������������������������������������������������������������������Ĵ��
���Descricao � LogOut do Portal											 ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Web Function PPLSOUT()

LOCAL cHtml := ""
LOCAL oObj  := Nil

WEB EXTENDED INIT cHtml

oObj := WSUSERPORTAL():NEW()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgUrl(@oObj,"USERPORTAL.apw")

oObj:PRTLOGOUT( GetUsrCode() )

HttpFreeSession()

cHtml := RedirPage( "W_PWSX010.APW", "top" ) //"<script>top.location='W_PWSX010.APW?cLoginPLS=1';</script>"

WEB EXTENDED END

Return cHtml
/*/
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Funcao    �PLSTPTLBEN� Autor � Rogerio Tabosa	   � Data � 29/01/13 ���
������������������������������������������������������������������������Ĵ��
���Descricao � Retorna parametro de arquivo tela inicial para portal do  ���
��           � beneficiario												 ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Function PLSTPTLBEN()
	Local oObjConfig := Nil
	Local cHtml	:= ""

	oObjConfig := WSCFGDICTIONARY():New()

	IIf (!Empty(PlsGetAuth()),oObjConfig:_HEADOUT :=  { PlsGetAuth() },)
	WsChgUrl(@oObjConfig, "CFGDICTIONARY.apw")

	If oObjConfig:GetParam(GtPtUsrCod()[1], "MV_TPTLBEN")
		cFileBEN := oObjConfig:cGetParamResult
		If File(cFileBEN)
			cHtml := ""
			FT_FUse(cFileBEN)
			FT_FGotop()
			While ( !FT_FEof() )
				cHtml += FT_FREADLN()
				FT_FSkip()
			EndDo
			FT_FUse()
		EndIf
	EndIf

Return(cHtml)
