#INCLUDE "PWSTMS10.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/*                      
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���WebFunction  �PWSTMS1X  �Autor  �Gustavo Almeida  � Data �  29/12/10   ���
�������������������������������������������������������������������������͹��
���Desc.        � WebRotina com layout da p�ginas de configura��o do      ���
���             � Portal TMS.                                             ���
�������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                      ���
�������������������������������������������������������������������������ͼ��
���WEBFUNC.     � DESCRI��O                                               ��� 
�����������������������������������������������������������������������������
���PWSTMS10     � FRAME com TOPO(TMS11), MENU(TMS12) e P�g. Inicial(TMS13)���
���PWSTMS11     � CFG e Redirec. para p�gina de topo.                     ���
���PWSTMS12     � CFG e Redirec. para p�gina de menu.                     ���
���PWSTMS13     � CFG e Redirec. para p�gina principal.                   ���
���PWSTMS14     � P�g. de Configura��o de Regi�o de Origem (1o Login).    ���
���PWSTMS15     � Cadastro de novo usu�rio para portal.                   ���
���PWSTMS16     � FRAME(F3) com ListBrowser(TMS1A) e Busca(TMS1B).        ���
���PWSTMS17     � Cadastro de Regi�o de Origem do usu�rio.                ���
���PWSTMS18     � P�g. de Cadastro de novo usu�rio/Altera��o de dados.    ���
���PWSTMS19     � P�g. de Aviso/Erros.                                    ���
���PWSTMS1A     � CFG e Redirec. para p�gina de ListBrowser (F3).         ���
���PWSTMS1B     � CFG e Redirec. para p�gina de Busca (F3).               ���
���PWSTMS1C     � P�g. de Inclus�o/Altera��o de Seq. Endere�os do usu�rio.��� 
���PWSTMS1D     � P�g. de Altera��o de Senha.                             ���
���PWSTMS1E     � Valida��o de Altera��o de Senha.                        ���
���PWSTMS1F     � P�g. de Reenvio de Senha.                               ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���WebFunction  �PWSTMS11  �Autor  �Gustavo Almeida  � Data �  29/12/10   ���
�������������������������������������������������������������������������͹��
���Desc.        � WebRotina com layout da p�gina de topo do Portal TMS.   ���
���             �                                                         ���
�������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Web Function PWSTMS11()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSTMS11" )

WEB EXTENDED END

Return cHtml

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���WebFunction  �PWSTMS12  �Autor  �Gustavo Almeida  � Data �  29/12/10   ���
�������������������������������������������������������������������������͹��
���Desc.        � WebRotina com layout da p�gina de menu do Portal TMS.   ���
���             �                                                         ���
�������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Web Function PWSTMS12()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSTMS12" )

WEB EXTENDED END

Return cHtml

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���WebFunction  �PWSTMS13  �Autor  �Gustavo Almeida  � Data �  29/12/10   ���
�������������������������������������������������������������������������͹��
���Desc.        � WebRotina com layout da p�gina principal do Portal TMS. ���
���             �                                                         ���
�������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Web Function PWSTMS13()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSUSERPRESENTATION():New()
WsChgURL( @oObj, "USERPRESENTATION.apw" )

If Empty( HttpSession->PWSTMS13INFO )
	HttpSession->PWSTMS13INFO := { Nil, Nil }
EndIf

If ExistBlock('PEGETPRES')
	HttpSession->PWSTMS13INFO[1] := execBlock('PEGETPRES', .f., .f., {1, GetUsrCode()})
ElseIf oObj:GETPRESENTATION()
	HttpSession->PWSTMS13INFO[1] := oObj:cGETPRESENTATIONRESULT
EndIf

If oObj:GETDAILYNEWS()
	HttpSession->PWSTMS13INFO[2] := oObj:oWSGETDAILYNEWSRESULT
EndIf

If oObj:GETPHOTO()
	HttpSession->_IMG_INST := oObj:cGETPHOTORESULT
EndIf

cHtml += ExecInPage( "PWSTMS13" )

WEB EXTENDED END

Return cHtml  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���WebFunction  �PWSTMS14  �Autor  �Gustavo Almeida  � Data �  05/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.        � WebRotina com layout de configura��o de regi�o do novo  ���
���             � usu�rio do Portal - TMS.                                ���
�������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Web Function PWSTMS14()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml := ExecInPage( "PWSTMS14" )

WEB EXTENDED END

Return cHtml

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���WebFunction  �PWSTMS15   �Autor  �Gustavo Almeida  � Data �  10/01/11  ���
�������������������������������������������������������������������������͹��
���Desc.        � WebRotina para inclus�o de usu�rio no TMS.              ���
���             �                                                         ���
�������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Web Function PWSTMS15()

Local cHtml     := ""
Local oObj, oUserData

If HttpGet->x == "4"

	//-- Session com { T�tulo do erro/informa��o,Descri��o do erro/informa��o, T�tulo do cabe�alho}
	HttpSession->PWSTMS19INFO:= {Nil, Nil, Nil, Nil}
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	oObj := WSTMSCFGUSER():NEW()
	WsChgUrl(@oObj,"TMSCFGUSER.APW")

	HttpSession->PWSTMS19INFO[1] := STR0001 //"Altera��o de Dados Cadastrais"
	oUserData := TMSCFGUSER_USERSTR():New()
	
	//-- Dados Alterados
	oUserData:cUserLogin     := HttpSession->UserLogin
	oUserData:cUserPsw       := HttpSession->UserPsw
	oUserData:cUserMail      := HttpSession->UserMail
	oUserData:cUserCGC       := HttpSession->UserCGC
	oUserData:cUserDDD       := HttpSession->UserDDD
	oUserData:cUserTel       := HttpSession->UserTel
	oUserData:cUserName      := HttpPost->UserName
	oUserData:cUserTradeName := HttpPost->UserTradeName
	oUserData:cUserAdress    := HttpPost->UserAdress
	oUserData:cUserCity      := HttpPost->UserCity
	oUserData:cUserState     := HttpPost->UserState
	oUserData:cUserDistrict  := HttpPost->UserDistrict
	oUserData:cUserZip       := HttpPost->UserZip
	oUserData:cUserAreaCode  := HttpPost->UserAreaCode
	
	//-- Envio dos dados para Altera��o
	If oObj:PUTCHGUSER(oUserData,GetUsrCode()) 
	                       
		HttpSession->PWSTMS19INFO[2] := oObj:cPUTCHGUSERRESULT
		HttpSession->PWSTMS19INFO[3] := STR0002 //"Altera��o"
		If  "sucesso" $ HttpSession->PWSTMS19INFO[2]
			HttpSession->PWSTMS19INFO[4] := ""
		Else 
			HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		EndIf
		cHtml := ExecInPage( "PWSTMS19" ) 
		
	Else
		HttpSession->PWSTMS19INFO[2] := STR0006+GetWSCError() //"Erro de Execu��o : "
		HttpSession->PWSTMS19INFO[3] := STR0007 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		cHtml := ExecInPage( "PWSTMS19" )
		
	Endif
   
	WEB EXTENDED END

Else 

	//-- Session com { T�tulo do erro/informa��o,Descri��o do erro/informa��o, T�tulo do cabe�alho}
	HttpSession->PWSTMS19INFO:= {Nil, Nil, Nil, Nil}
	
	WEB EXTENDED INIT cHtml
	
	oObj := WSTMSCFGUSER():NEW()
	WsChgUrl(@oObj,"TMSCFGUSER.APW")
	
	HttpSession->PWSTMS19INFO[1] := STR0008 //"Solicita��o de Acesso"
	oUserData := TMSCFGUSER_USERSTR():New()
	
	//-- Dados Novos
	oUserData:cUserLogin     := HttpPost->UserLogin
	oUserData:cUserPsw       := HttpPost->UserPsw
	oUserData:cUserMail      := HttpPost->UserMail
	oUserData:cUserCGC       := HttpPost->UserCGC
	oUserData:cUserDDD       := HttpPost->UserDDD
	oUserData:cUserTel       := HttpPost->UserTel
	oUserData:cUserName      := HttpPost->UserName
	oUserData:cUserTradeName := HttpPost->UserTradeName
	oUserData:cUserAdress    := HttpPost->UserAdress
	oUserData:cUserCity      := HttpPost->UserCity
	oUserData:cUserState     := HttpPost->UserState
	oUserData:cUserDistrict  := HttpPost->UserDistrict
	oUserData:cUserZip       := HttpPost->UserZip
	
	//-- Guarda dados em caso de erro
	HttpSession->UserLogin     := HttpPost->UserLogin
	HttpSession->UserDDD       := HttpPost->UserDDD
	HttpSession->UserTel       := HttpPost->UserTel
	HttpSession->UserName      := HttpPost->UserName
	HttpSession->UserTradeName := HttpPost->UserTradeName
	HttpSession->UserAdress    := HttpPost->UserAdress	                       
	HttpSession->UserCity      := HttpPost->UserCity
	HttpSession->UserState     := HttpPost->UserState
	HttpSession->UserDistrict  := HttpPost->UserDistrict
	HttpSession->UserZip       := HttpPost->UserZip	                       
	HttpSession->UserCGC       := HttpPost->UserCGC
	HttpSession->UserMail      := HttpPost->UserMail
		
	//-- Envio dos dados para inclus�o
	If oObj:PUTNEWUSER(oUserData) 
	                       
		HttpSession->PWSTMS19INFO[2] := oObj:cPUTNEWUSERRESULT
		HttpSession->PWSTMS19INFO[3] := STR0009 //"Inclus�o"
		If "sucesso" $ HttpSession->PWSTMS19INFO[2]
			HttpSession->PWSTMS19INFO[4] := STR0004 //"fechar"
		Else 
			HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		EndIf
		cHtml := ExecInPage( "PWSTMS19" ) 
		
	Else
		HttpSession->PWSTMS19INFO[2] := STR0006+GetWSCError() //"Erro de Execu��o : "
		HttpSession->PWSTMS19INFO[3] := STR0007 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		cHtml := ExecInPage( "PWSTMS19" )
		
	Endif

	WEB EXTENDED END

EndIf

Return cHtml

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���WebFunction  �PWSTMS16  �Autor  �Gustavo Almeida  � Data �  19/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.        � WebRotina de F3 para o Portal TMS                       ���
���             �                                                         ���
�������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Web Function PWSTMS16()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSTMS16" )

WEB EXTENDED END

Return cHtml

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���WebFunction  �PWSTMS17  �Autor  �Gustavo Almeida  � Data �  26/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.        � WebRotina para inclus�o de Regi�o de Origem.            ���
���             �                                                         ���
�������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Web Function PWSTMS17()

Local cHtml     := ""
Local oObj 

//-- Session com { T�tulo do erro/informa��o,Descri��o do erro/informa��o, T�tulo do cabe�alho}
HttpSession->PWSTMS19INFO:= {Nil, Nil, Nil, Nil} 

HttpSession->PWSTMS19INFO[1]:= STR0010 //"Regi�o de Origem"

WEB EXTENDED INIT cHtml START "InSite"

//-- Configura��o de Regi�o de Origem
If !Empty(HttpGet->cRegOri)           

	oObj := WSTMSCFGUSER():NEW()
	WsChgUrl(@oObj,"TMSCFGUSER.APW")
	
	//-- Envio dos dados para inclus�o
	If oObj:PUTAREAREQUESTOR(HttpGet->cRegOri,GetUsrCode()) 
		cHtml += ExecInPage( "PWSTMS10" )
	Else
		HttpSession->PWSTMS19INFO[3]:= STR0007 //"Erro"
		HttpSession->PWSTMS19INFO[2]:= STR0006+GetWSCError() //"Erro de Execu��o : "
		HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		cHtml += ExecInPage( "PWSTMS19" )
	Endif
	
EndIf

WEB EXTENDED END

Return cHtml 
       
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���WebFunction  �PWSTMS18  �Autor  �Gustavo Almeida  � Data �  05/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.        � WebRotina com layout de cadastro de usu�rio no portal.  ���
���             �                                                         ���
�������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Web Function PWSTMS18()

Local cHtml := ""

If HttpGet->x = "4"
	//-- Dados j� informados

	WEB EXTENDED INIT cHtml START "InSite"
	
	oObj := WSTMSCFGUSER():NEW()
	WsChgUrl(@oObj,"TMSCFGUSER.APW")
	
	HttpSession->PWSTMS19INFO:= {Nil, Nil, Nil, Nil}

	If oObj:GETCHGUSER(GetUsrCode())
		HttpSession->UserLogin     := oObj:oWSGETCHGUSERRESULT:cUserLogin
		HttpSession->UserDDD       := oObj:oWSGETCHGUSERRESULT:cUserDDD	                       
		HttpSession->UserPsw       := oObj:oWSGETCHGUSERRESULT:cUserPsw
		HttpSession->UserTel       := oObj:oWSGETCHGUSERRESULT:cUserTel
		HttpSession->UserName      := oObj:oWSGETCHGUSERRESULT:cUserName
		HttpSession->UserTradeName := oObj:oWSGETCHGUSERRESULT:cUserTradeName
		HttpSession->UserAdress    := oObj:oWSGETCHGUSERRESULT:cUserAdress	                       
		HttpSession->UserCity      := oObj:oWSGETCHGUSERRESULT:cUserCity
		HttpSession->UserState     := oObj:oWSGETCHGUSERRESULT:cUserState
		HttpSession->UserDistrict  := oObj:oWSGETCHGUSERRESULT:cUserDistrict
		HttpSession->UserZip       := oObj:oWSGETCHGUSERRESULT:cUserZip	                       
		HttpSession->UserCGC       := oObj:oWSGETCHGUSERRESULT:cUserCGC
		HttpSession->UserMail      := oObj:oWSGETCHGUSERRESULT:cUserMail
		HttpSession->UserAreaCode  := oObj:oWSGETCHGUSERRESULT:cUserAreaCode
	Else		
		HttpSession->PWSTMS19INFO[2] := STR0006+GetWSCError() //"Erro de Execu��o : "
		HttpSession->PWSTMS19INFO[3] := STR0007 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		cHtml := ExecInPage( "PWSTMS19" )
	Endif
	
	cHtml += ExecInPage( "PWSTMS18?x=4" )
	
	WEB EXTENDED END
	
Else

	WEB EXTENDED INIT cHtml
	
	oObj := WSTMSCFGUSER():NEW()
	WsChgUrl(@oObj,"TMSCFGUSER.APW")
	
	HttpSession->PWSTMS19INFO:= {Nil, Nil, Nil, Nil}

	cHtml += ExecInPage( "PWSTMS18" )
	
	WEB EXTENDED END
	
EndIf	

Return cHtml

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���WebFunction  �PWSTMS1A  �Autor  �Gustavo Almeida  � Data �  16/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.        � WebRotina com layout da p�gina de Browser para F3(TMS16)���
���             �                                                         ���
�������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Web Function PWSTMS1A()

Local cHtml  := ""
Local oObj   := {}
Local nI     := 0
Local nX     := 0    
Local nPagina:= 1  
Local cTypDLC:= ""


oObj := WSTMSCFGUSER():NEW()
WsChgUrl(@oObj,"TMSCFGUSER.APW")

HttpSession->APWSTMS1AHEADER := {} 
HttpSession->APWSTMS1AITENS  := {} 

WEB EXTENDED INIT cHtml START "InSite"

//-- Header
If oObj:GETHEADER(HttpGet->cF3)
	For nI:=1 to Len(oObj:oWSGETHEADERRESULT:oWSBRWHEADER)
		aAdd( HttpSession->APWSTMS1AHEADER, oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:CHEADERTITLE )
	Next
Endif 


If HttpGet->cF3 = "DUY" //-- Regi�o de Origem       
	
	//-- Listagem
	If oObj:GETBROWSERDUY()
		For nX:=1 to Len(oObj:oWSGETBROWSERDUYRESULT:oWSDUY)
		
			//-- Pagina��o
			If nX%6 == 0
				nPagina++	
			EndIf
			
			//-- Busca
			 If !Empty(HttpGet->cBusca)
			 	If HttpGet->cTipo == "1" //-- por descri��o
			 		If (AllTrim(Upper(HttpGet->cBusca))) $ (AllTrim(Upper(oObj:oWSGETBROWSERDUYRESULT:oWSDUY[nX]:cDUYDESCRIPTION)))
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDUYRESULT:oWSDUY[nX]:cDUYAREAGROUP,;
			 	      								  	          oObj:oWSGETBROWSERDUYRESULT:oWSDUY[nX]:cDUYDESCRIPTION,;
			 											             oObj:oWSGETBROWSERDUYRESULT:oWSDUY[nX]:cDUYSTATE,.T.,nPagina})
				      HttpGet->cPagina:= Str(nPagina)
				   Else 
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDUYRESULT:oWSDUY[nX]:cDUYAREAGROUP,;
			 	      								  	          oObj:oWSGETBROWSERDUYRESULT:oWSDUY[nX]:cDUYDESCRIPTION,;
			 											             oObj:oWSGETBROWSERDUYRESULT:oWSDUY[nX]:cDUYSTATE,.F.,nPagina})
				   EndIf
				ElseIf HttpGet->cTipo == "2" //-- por estado
					If (AllTrim(Upper(HttpGet->cBusca))) $ (AllTrim(Upper(oObj:oWSGETBROWSERDUYRESULT:oWSDUY[nX]:cDUYSTATE)))
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDUYRESULT:oWSDUY[nX]:cDUYAREAGROUP,;
			 	      								  	          oObj:oWSGETBROWSERDUYRESULT:oWSDUY[nX]:cDUYDESCRIPTION,;
			 											             oObj:oWSGETBROWSERDUYRESULT:oWSDUY[nX]:cDUYSTATE,.T.,nPagina})
				      HttpGet->cPagina:= Str(nPagina)
				   Else 
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDUYRESULT:oWSDUY[nX]:cDUYAREAGROUP,;
			 	      								  	          oObj:oWSGETBROWSERDUYRESULT:oWSDUY[nX]:cDUYDESCRIPTION,;
			 											             oObj:oWSGETBROWSERDUYRESULT:oWSDUY[nX]:cDUYSTATE,.F.,nPagina})
				   EndIf
			 	EndIf
			 Else
			    aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDUYRESULT:oWSDUY[nX]:cDUYAREAGROUP,;
			 	      								  	     oObj:oWSGETBROWSERDUYRESULT:oWSDUY[nX]:cDUYDESCRIPTION,;
			 											        oObj:oWSGETBROWSERDUYRESULT:oWSDUY[nX]:cDUYSTATE,.F.,nPagina})
			 EndIf
		
		Next nX
	Endif       
 
ElseIf HttpGet->cF3 = "DLA" //-- Sequencia de Endere�os         
	
	//-- Listagem
	If oObj:GETBROWSERDLA(GetUsrCode())
		For nX:=1 to Len(oObj:oWSGETBROWSERDLARESULT:oWSDLA) 
		
			//-- Pagina��o
			If nX%6 == 0
				nPagina++	
			EndIf   
			
			//-- Busca
			If !Empty(HttpGet->cBusca)
				If HttpGet->cTipo == "1" //-- por endere�o
			 		If (AllTrim(Upper(HttpGet->cBusca))) $ (AllTrim(Upper(oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESS)))
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESSSEQ,;
			 															 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESS,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLADISTRICT,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLACITY,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLASTATE,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAZIP,.T.,nPagina})
				      HttpGet->cPagina:= Str(nPagina)
				   Else 
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESSSEQ,;
			 															 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESS,;
			 											    		    oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLADISTRICT,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLACITY,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLASTATE,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAZIP,.F.,nPagina})
				   EndIf
				ElseIf HttpGet->cTipo == "2" //-- por bairro
					If (AllTrim(Upper(HttpGet->cBusca))) $ (AllTrim(Upper(oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLADISTRICT)))
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESSSEQ,;
			 															 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESS,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLADISTRICT,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLACITY,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLASTATE,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAZIP,.T.,nPagina})
				      HttpGet->cPagina:= Str(nPagina)
				   Else 
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESSSEQ,;
			 															 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESS,;
			 											    		    oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLADISTRICT,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLACITY,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLASTATE,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAZIP,.F.,nPagina})
				   EndIf
				ElseIf HttpGet->cTipo == "3" //-- por municipio
					If (AllTrim(Upper(HttpGet->cBusca))) $ (AllTrim(Upper(oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLACITY)))
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESSSEQ,;
			 															 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESS,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLADISTRICT,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLACITY,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLASTATE,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAZIP,.T.,nPagina})
				      HttpGet->cPagina:= Str(nPagina)
				   Else 
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESSSEQ,;
			 															 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESS,;
			 											    		    oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLADISTRICT,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLACITY,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLASTATE,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAZIP,.F.,nPagina})
				   EndIf 
				ElseIf HttpGet->cTipo == "4" //-- por estado
					If (AllTrim(Upper(HttpGet->cBusca))) $ (AllTrim(Upper(oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLASTATE)))
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESSSEQ,;
			 															 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESS,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLADISTRICT,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLACITY,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLASTATE,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAZIP,.T.,nPagina})
				      HttpGet->cPagina:= Str(nPagina)
				   Else 
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESSSEQ,;
			 															 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESS,;
			 											    		    oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLADISTRICT,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLACITY,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLASTATE,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAZIP,.F.,nPagina})
				   EndIf 
				ElseIf HttpGet->cTipo == "5" //-- por cep
					If (AllTrim(Upper(HttpGet->cBusca))) $ (AllTrim(Upper(oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAZIP)))
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESSSEQ,;
			 															 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESS,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLADISTRICT,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLACITY,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLASTATE,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAZIP,.T.,nPagina})
				      HttpGet->cPagina:= Str(nPagina)
				   Else 
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESSSEQ,;
			 															 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESS,;
			 											    		    oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLADISTRICT,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLACITY,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLASTATE,;
			 											    			 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAZIP,.F.,nPagina})
				   EndIf 
				EndIf   
			Else
				aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESSSEQ,;
			 											  	 	 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAADRESS,;
			 											    	 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLADISTRICT,;
			 											    	 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLACITY,;
			 											    	 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLASTATE,;
			 											    	 oObj:oWSGETBROWSERDLARESULT:oWSDLA[nX]:cDLAZIP,.F.,nPagina})
			EndIf

		Next
	EndIf 
	
ElseIf HttpGet->cF3 = "DLC" //-- Tipo de Transporte

	//-- Listagem
	If HttpGet->cCamp = "SERTMSA"
		cTypDLC := "SERTMS"
	Else
	   cTypDLC := ""
	EndIf 
   If oObj:GETBROWSERDLC(cTypDLC)
    		For nX:=1 to Len(oObj:oWSGETBROWSERDLCRESULT:oWSBROWSERGENERIC)
		
			 //-- Pagina��o
			 If nX%6 == 0
			 	nPagina++	
			 EndIf
			 
		  	 //-- Busca
			 If !Empty(HttpGet->cBusca)
			 	If HttpGet->cTipo == "1" //-- por c�digo
			 		If (AllTrim(HttpGet->cBusca)) $ (AllTrim(oObj:oWSGETBROWSERDLCRESULT:oWSBROWSERGENERIC[nX]:cBGCODE))
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDLCRESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
				         									       oObj:oWSGETBROWSERDLCRESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.T.,nPagina})
				      HttpGet->cPagina:= Str(nPagina)
				   Else 
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDLCRESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
				         									       oObj:oWSGETBROWSERDLCRESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.F.,nPagina})
				   EndIf
				ElseIf HttpGet->cTipo == "2" //-- por descri��o
					If (AllTrim(Upper(HttpGet->cBusca))) $ (AllTrim(Upper(oObj:oWSGETBROWSERDLCRESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION)))
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDLCRESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
				         									       oObj:oWSGETBROWSERDLCRESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.T.,nPagina})
				      HttpGet->cPagina:= Str(nPagina)
				   Else 
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDLCRESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
				         									       oObj:oWSGETBROWSERDLCRESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.F.,nPagina})
				   EndIf
			 	EndIf
			 Else
			    aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDLCRESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
				      									     oObj:oWSGETBROWSERDLCRESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.F.,nPagina})
			 EndIf
	   Next nX  
   EndIf
     
ElseIf HttpGet->cF3 = "MG" //-- Embalagem
	
	//-- Listagem
  	If oObj:GETBROWSERMG()
		
		For nX:=1 to Len(oObj:oWSGETBROWSERMGRESULT:oWSBROWSERGENERIC)
		
			 //-- Pagina��o
			 If nX%6 == 0
			 	nPagina++	
			 EndIf
			 
		  	 //-- Busca
			 If !Empty(HttpGet->cBusca)
			 	If HttpGet->cTipo == "1" //-- por c�digo
			 		If (AllTrim(Upper(HttpGet->cBusca))) $ (AllTrim(Upper(oObj:oWSGETBROWSERMGRESULT:oWSBROWSERGENERIC[nX]:cBGCODE)))
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERMGRESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
				         									       oObj:oWSGETBROWSERMGRESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.T.,nPagina})
				      HttpGet->cPagina:= Str(nPagina)
				   Else 
					   aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERMGRESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
					         									    oObj:oWSGETBROWSERMGRESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.F.,nPagina})
				   EndIf
				ElseIf HttpGet->cTipo == "2" //-- por descri��o
					If (AllTrim(Upper(HttpGet->cBusca))) $ (AllTrim(Upper(oObj:oWSGETBROWSERMGRESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION)))
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERMGRESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
				         									       oObj:oWSGETBROWSERMGRESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.T.,nPagina})
				      HttpGet->cPagina:= Str(nPagina)
				   Else 
					   aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERMGRESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
					         									    oObj:oWSGETBROWSERMGRESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.F.,nPagina})
				   EndIf
			 	EndIf
			 Else
					aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERMGRESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
					         									 oObj:oWSGETBROWSERMGRESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.F.,nPagina})
			 EndIf
	   Next nX
	Endif       
ElseIf HttpGet->cF3 = "SB1" //-- Produtos
	
	//-- Listagem
  	If oObj:GETBROWSERSB1()
		
		For nX:=1 to Len(oObj:oWSGETBROWSERSB1RESULT:oWSBROWSERGENERIC)
		
			 //-- Pagina��o
			 If nX%6 == 0
			 	nPagina++	
			 EndIf
			 
		  	 //-- Busca
			 If !Empty(HttpGet->cBusca)
			 	If HttpGet->cTipo == "1" //-- por c�digo
			 		If (AllTrim(HttpGet->cBusca)) $ (AllTrim(oObj:oWSGETBROWSERSB1RESULT:oWSBROWSERGENERIC[nX]:cBGCODE))
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERSB1RESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
				         									       oObj:oWSGETBROWSERSB1RESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.T.,nPagina})
				      HttpGet->cPagina:= Str(nPagina)
				   Else 
					   aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERSB1RESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
					         									    oObj:oWSGETBROWSERSB1RESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.F.,nPagina})
				   EndIf
				ElseIf HttpGet->cTipo == "2" //-- por descri��o
					If (AllTrim(Upper(HttpGet->cBusca))) $ (AllTrim(Upper(oObj:oWSGETBROWSERSB1RESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION)))
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERSB1RESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
				         									       oObj:oWSGETBROWSERSB1RESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.T.,nPagina})
				      HttpGet->cPagina:= Str(nPagina)
				   Else 
					   aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERSB1RESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
					         									    oObj:oWSGETBROWSERSB1RESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.F.,nPagina})
				   EndIf
			 	EndIf
			 Else
					aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERSB1RESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
					         									 oObj:oWSGETBROWSERSB1RESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.F.,nPagina})
			 EndIf
	   Next nX
	Endif 
EndIf 
	
cHtml += ExecInPage( "PWSTMS1A" ) 

WEB EXTENDED END	

Return cHtml

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���WebFunction  �PWSTMS1B  �Autor  �Gustavo Almeida  � Data �  16/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.        � WebRotina com layout da p�gina de Busca para F3(TMS16). ���
���             �                                                         ���
�������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Web Function PWSTMS1B()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSTMS1B" )

WEB EXTENDED END

Return cHtml 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���WebFunction  �PWSTMS1C  �Autor  �Gustavo Almeida  � Data �  23/02/11   ���
�������������������������������������������������������������������������͹��
���Desc.        � WebRotina com layout da p�gina de Inclus�o de Endere�os.���
���             �                                                         ���
�������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Web Function PWSTMS1C()

Local cHtml   := ""
Local nI      :=0

oObj := WSTMSCFGUSER():NEW()
WsChgUrl(@oObj,"TMSCFGUSER.APW")

WEB EXTENDED INIT cHtml START "InSite" 

//-- Foco na p�gina
If !Empty(HttpPost->cCAMPFOCO)
	HttpSession->CPWSTMS1CFOCO:= HttpPost->cCAMPFOCO
Else
	HttpSession->CPWSTMS1CFOCO:= "CDRDESA"
EndIf	

If HttpGet->cAct == 'INC' 
	
	HttpSession->APWSTMS1CINFOANT:= {}
	
	If Empty(HttpSession->APWSTMS1CHEADER)  
		HttpSession->APWSTMS1CHEADER := {}
		
		If oObj:GETHEADER("SEQEND")
			For nI:=1 to Len(oObj:oWSGETHEADERRESULT:oWSBRWHEADER)
				aAdd( HttpSession->APWSTMS1CHEADER,{oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERTITLE,;
															   oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERFIELD,;
														 	   oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERTYPE,;
																oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:nHEADERSIZE,;
																oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:nHEADERDEC,;
																oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:lHEADEROBLIG,;
																oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERPICTURE,;
																oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERCOMBOBOX,;
																oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERF3})
			Next nI		
		EndIf 
		 
	EndIf
  
	//-- Proxima sequencia de endere�o
	oObj:GETTRGINFO("SEQENDNEW",GetUsrCode())
	HttpSession->CPWSTMS1CSEQEND:= oObj:oWSGETTRGINFORESULT:cTRGVALUE01
	
	cHtml += ExecInPage( "PWSTMS1C?cAct=INC" )
	
ElseIf HttpGet->cAct == "ALT" 

	If Empty(HttpSession->APWSTMS1CHEADER)  
		HttpSession->APWSTMS1CHEADER := {}
		
		If oObj:GETHEADER("SEQEND")
			For nI:=1 to Len(oObj:oWSGETHEADERRESULT:oWSBRWHEADER)
				aAdd( HttpSession->APWSTMS1CHEADER,{oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERTITLE,;
															   oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERFIELD,;
														 	   oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERTYPE,;
																oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:nHEADERSIZE,;
																oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:nHEADERDEC,;
																oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:lHEADEROBLIG,;
																oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERPICTURE,;
																oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERCOMBOBOX,;
																oObj:oWSGETHEADERRESULT:oWSBRWHEADER[nI]:cHEADERF3})
			Next nI		
		EndIf 
		 
	EndIf 
	
	HttpSession->APWSTMS1CINFOANT:= {}
	HttpSession->CPWSTMS1CSEQEND := HttpGet->nSeq
	
	//-- Valores
	If oObj:GETADRESSSEQ(GetUsrCode(),HttpGet->nSeq)
		aAdd(HttpSession->APWSTMS1CINFOANT,{oObj:oWSGETADRESSSEQRESULT:cDLAAREACODE ,"CDRDESA"})
		aAdd(HttpSession->APWSTMS1CINFOANT,{oObj:oWSGETADRESSSEQRESULT:cDLAADRESS   ,"DULENDA"})
		aAdd(HttpSession->APWSTMS1CINFOANT,{oObj:oWSGETADRESSSEQRESULT:cDLADISTRICT ,"BAIRROA"})
		aAdd(HttpSession->APWSTMS1CINFOANT,{oObj:oWSGETADRESSSEQRESULT:cDLAZIP      ,"CEPA"})		
		aAdd(HttpSession->APWSTMS1CINFOANT,{oObj:oWSGETADRESSSEQRESULT:cDLACITY     ,"MUNV"})
		aAdd(HttpSession->APWSTMS1CINFOANT,{oObj:oWSGETADRESSSEQRESULT:cDLACITY     ,"MUNVPRE"})
		aAdd(HttpSession->APWSTMS1CINFOANT,{oObj:oWSGETADRESSSEQRESULT:cDLASTATE    ,"ESTV"})
		aAdd(HttpSession->APWSTMS1CINFOANT,{oObj:oWSGETADRESSSEQRESULT:cDLASTATE    ,"ESTVPRE"})
	EndIf 
	
	cHtml += ExecInPage( "PWSTMS1C?cAct=ALT" )
	
ElseIf HttpPost->cAct == "INC" .And. Empty(HttpPost->cGATILHOCAMP) //-- Incluir

	HttpSession->PWSTMS19INFO:= {Nil, Nil, Nil, Nil}
	
	HttpSession->PWSTMS19INFO[1]:= STR0011 //"Inclus�o de Seq. de Endere�o"
	
	HttpSession->OPWSTMS1CINFO:= TMSCFGUSER_DLA():New()
	  
	//Valores para Inclus�o
	HttpSession->OPWSTMS1CINFO:CDLAAREACODE  := HttpPost->CDRDESA
	HttpSession->OPWSTMS1CINFO:CDLAADRESSSEQ := HttpPost->SEQEND
	HttpSession->OPWSTMS1CINFO:CDLAADRESS    := HttpPost->DULENDA
	HttpSession->OPWSTMS1CINFO:CDLADISTRICT  := HttpPost->BAIRROA
	HttpSession->OPWSTMS1CINFO:CDLACITY      := HttpPost->MUNVPRE
	HttpSession->OPWSTMS1CINFO:CDLASTATE     := HttpPost->ESTVPRE
	HttpSession->OPWSTMS1CINFO:CDLAZIP       := HttpPost->CEPA
			
	If oObj:PUTADRESSSEQ(GetUsrCode(),HttpSession->OPWSTMS1CINFO)
		HttpSession->PWSTMS19INFO[2] := "<center>"+STR0012+"</center>"  //"Inclus�o efetuada com sucesso!"
		HttpSession->PWSTMS19INFO[4] := STR0004 //"fechar"
		cHtml += ExecInPage( "PWSTMS19" )
	Else
		HttpSession->PWSTMS19INFO[2] := STR0006+GetWSCError() //"Erro de Execu��o : "
		HttpSession->PWSTMS19INFO[3] := STR0007 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		cHtml += ExecInPage( "PWSTMS19" )
	EndIf

ElseIf HttpPost->cAct == "ALT" .And. Empty(HttpPost->cGATILHOCAMP)//-- Alterar
	
	HttpSession->PWSTMS19INFO:= {Nil, Nil, Nil, Nil}
	
	HttpSession->PWSTMS19INFO[1]:= STR0013 //"Altera��o de Seq. de Endere�o"
	
	HttpSession->OPWSTMS1CINFO:= TMSCFGUSER_DLA():New()
	  
	//Valores para Altera��o
	HttpSession->OPWSTMS1CINFO:CDLAAREACODE  := HttpPost->CDRDESA
	HttpSession->OPWSTMS1CINFO:CDLAADRESSSEQ := HttpSession->CPWSTMS1CSEQEND
	HttpSession->OPWSTMS1CINFO:CDLAADRESS    := HttpPost->DULENDA
	HttpSession->OPWSTMS1CINFO:CDLADISTRICT  := HttpPost->BAIRROA
	HttpSession->OPWSTMS1CINFO:CDLACITY      := HttpPost->MUNVPRE
	HttpSession->OPWSTMS1CINFO:CDLASTATE     := HttpPost->ESTVPRE
	HttpSession->OPWSTMS1CINFO:CDLAZIP       := HttpPost->CEPA
	
	If oObj:CHGADRESSSEQ(GetUsrCode(),HttpSession->OPWSTMS1CINFO,HttpSession->OPWSTMS1CINFO:CDLAADRESSSEQ)
	
		HttpSession->PWSTMS19INFO[2] := "<center>"+STR0014+"</center>" //"Altera��o efetuada com sucesso!"
		HttpSession->PWSTMS19INFO[4] := STR0004 //"fechar"
		cHtml += ExecInPage( "PWSTMS19" )
	Else
		HttpSession->PWSTMS19INFO[2] := STR0006+GetWSCError() //"Erro de Execu��o : "
		HttpSession->PWSTMS19INFO[3] := STR0007 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		cHtml += ExecInPage( "PWSTMS19" )
	EndIf

Else

	If !Empty(HttpPost->cGATILHOCAMP)
	
		HttpSession->APWSTMS1CINFOANT:= {}
		HttpSession->CPWSTMS1CACT    := HttpPost->cAct
		
		aAdd(HttpSession->APWSTMS1CINFOANT,{HttpPost->CDRDESA  ,"CDRDESA"  })
	  	aAdd(HttpSession->APWSTMS1CINFOANT,{HttpPost->DULENDA  ,"DULENDA"  })
	  	aAdd(HttpSession->APWSTMS1CINFOANT,{HttpPost->BAIRROA  ,"BAIRROA"  })
	  	aAdd(HttpSession->APWSTMS1CINFOANT,{HttpPost->CEPA     ,"CEPA"     })
	  	 
		//-- Municipio de Regi�o de Origem e Estado
		oObj:GETTRGINFO("CDRDES",HttpPost->CDRDESA)
		aAdd(HttpSession->APWSTMS1CINFOANT,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"MUNV"})
		aAdd(HttpSession->APWSTMS1CINFOANT,{oObj:oWSGETTRGINFORESULT:cTRGVALUE01,"MUNVPRE"})
		aAdd(HttpSession->APWSTMS1CINFOANT,{oObj:oWSGETTRGINFORESULT:cTRGVALUE02,"ESTV"})
		aAdd(HttpSession->APWSTMS1CINFOANT,{oObj:oWSGETTRGINFORESULT:cTRGVALUE02,"ESTVPRE"})
	
	EndIf	
	
	cHtml += ExecInPage( "PWSTMS1C" )
		
EndIf

WEB EXTENDED END

Return cHtml 

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSTMS1D   �Autor  �Gustavo Almeida      � Data �  17/03/11  ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������͹��
���Desc.        � WebRotina com layout da p�gina de altera��o de senha.    ���
���             �                                                          ���
��������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                       ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSTMS1D()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSTMS1D" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSTMS1E   �Autor  �Gustavo Almeida      � Data �  17/03/11  ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������͹��
���Desc.        � WebRotina com a altera��o de senha.                      ���
���             �                                                          ���
��������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                       ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSTMS1E()

Local cHtml := ""

HttpSession->PWSTMS19INFO:= {Nil, Nil, Nil, Nil}
HttpSession->PWSTMS19INFO[1] := STR0015 //"Altera��o de Senha"

WEB EXTENDED INIT cHtml START "InSite"

	oObj := WSUSERPORTAL():NEW()
	
	WsChgUrl(@oObj,"USERPORTAL.apw")
	
	If AllTrim( GetUsrSenha() ) != HttpPost->UserPsw
	
		HttpSession->PWSTMS19INFO[2] := STR0016 //"Senha atual digitada n�o confere!"
		HttpSession->PWSTMS19INFO[3] := STR0007 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		cHtml += ExecInPage( "PWSTMS19" )
		
	ElseIf oObj:PRTPSWUSER( GetUsrCode(), AllTrim(GetUsrSenha()), HttpPost->UserNewPsw )
	
		If !SetUsrSenha( HttpPost->UserNewPsw )
			HttpFreeSession()
		Endif
		
		HttpSession->PWSTMS19INFO[2] := STR0017 //"Nova senha cadastrada com sucesso"
		HttpSession->PWSTMS19INFO[3] := STR0015 //"Altera��o de Senha"
		HttpSession->PWSTMS19INFO[4] := ""
		cHtml += ExecInPage( "PWSTMS19" )
		
	Else
 		HttpSession->PWSTMS19INFO[2] := STR0018+GetWSCError() //"Altera��o n�o efetuada "
		HttpSession->PWSTMS19INFO[3] := STR0007 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		cHtml += ExecInPage( "PWSTMS19" )

	Endif
	
WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSTMS1F   �Autor  �Gustavo Almeida      � Data �  17/03/11  ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������͹��
���Desc.        � WebRotina com layout da p�gina de reenvio de senha.      ���
���             �                                                          ���
��������������������������������������������������������������������������͹��
���Uso          � Portal TMS - Gest�o de Transportes                       ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSTMS1F()

Local cHtml := ""

HttpSession->PWSTMS19INFO:= {Nil, Nil, Nil, Nil}
HttpSession->PWSTMS19INFO[1] := STR0021 //"Reenvio de Senha"

If HttpGet->cAct <> "ENV"

	WEB EXTENDED INIT cHtml
	
	cHtml += ExecInPage( "PWSTMS1F" )
	
	WEB EXTENDED END

Else

	oObj := WSTMSCFGUSER():NEW()
	WsChgUrl(@oObj,"TMSCFGUSER.APW")
   
	WEB EXTENDED INIT cHtml

	If oObj:GETPWDUSER( HttpPost->UserLogin )
		If "informado" $ oObj:cGETPWDUSERRESULT  //-- Login n�o existe em base
			HttpSession->PWSTMS19INFO[2] := STR0022 //"Login n�o cadastrado."
			HttpSession->PWSTMS19INFO[3] := STR0021 //"Reenvio de Senha"
			HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
			cHtml += ExecInPage( "PWSTMS19" )
		Else
			HttpSession->PWSTMS19INFO[2] := oObj:cGETPWDUSERRESULT
			HttpSession->PWSTMS19INFO[3] := STR0021 //"Reenvio de Senha"
			HttpSession->PWSTMS19INFO[4] := STR0004 //"fechar"
			cHtml += ExecInPage( "PWSTMS19" )
      EndIf
   Else
   	HttpSession->PWSTMS19INFO[2] := GetWSCError()
		HttpSession->PWSTMS19INFO[3] := STR0007 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		cHtml += ExecInPage( "PWSTMS19" )
	EndIf  
	
	WEB EXTENDED END

EndIf

Return cHtml