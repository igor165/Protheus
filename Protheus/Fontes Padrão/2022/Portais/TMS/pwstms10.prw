#INCLUDE "PWSTMS10.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/*                      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS1X  ºAutor  ³Gustavo Almeida  º Data ³  29/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina com layout da páginas de configuração do      º±±
±±º             ³ Portal TMS.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºWEBFUNC.     ³ DESCRIÇÃO                                               º±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºPWSTMS10     ³ FRAME com TOPO(TMS11), MENU(TMS12) e Pág. Inicial(TMS13)º±±
±±ºPWSTMS11     ³ CFG e Redirec. para página de topo.                     º±±
±±ºPWSTMS12     ³ CFG e Redirec. para página de menu.                     º±±
±±ºPWSTMS13     ³ CFG e Redirec. para página principal.                   º±±
±±ºPWSTMS14     ³ Pág. de Configuração de Região de Origem (1o Login).    º±±
±±ºPWSTMS15     ³ Cadastro de novo usuário para portal.                   º±±
±±ºPWSTMS16     ³ FRAME(F3) com ListBrowser(TMS1A) e Busca(TMS1B).        º±±
±±ºPWSTMS17     ³ Cadastro de Região de Origem do usuário.                º±±
±±ºPWSTMS18     ³ Pág. de Cadastro de novo usuário/Alteração de dados.    º±±
±±ºPWSTMS19     ³ Pág. de Aviso/Erros.                                    º±±
±±ºPWSTMS1A     ³ CFG e Redirec. para página de ListBrowser (F3).         º±±
±±ºPWSTMS1B     ³ CFG e Redirec. para página de Busca (F3).               º±±
±±ºPWSTMS1C     ³ Pág. de Inclusão/Alteração de Seq. Endereços do usuário.º±± 
±±ºPWSTMS1D     ³ Pág. de Alteração de Senha.                             º±±
±±ºPWSTMS1E     ³ Validação de Alteração de Senha.                        º±±
±±ºPWSTMS1F     ³ Pág. de Reenvio de Senha.                               º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS11  ºAutor  ³Gustavo Almeida  º Data ³  29/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina com layout da página de topo do Portal TMS.   º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSTMS11()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSTMS11" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS12  ºAutor  ³Gustavo Almeida  º Data ³  29/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina com layout da página de menu do Portal TMS.   º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSTMS12()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSTMS12" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS13  ºAutor  ³Gustavo Almeida  º Data ³  29/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina com layout da página principal do Portal TMS. º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS14  ºAutor  ³Gustavo Almeida  º Data ³  05/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina com layout de configuração de região do novo  º±±
±±º             ³ usuário do Portal - TMS.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Web Function PWSTMS14()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml := ExecInPage( "PWSTMS14" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS15   ºAutor  ³Gustavo Almeida  º Data ³  10/01/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina para inclusão de usuário no TMS.              º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSTMS15()

Local cHtml     := ""
Local oObj, oUserData

If HttpGet->x == "4"

	//-- Session com { Título do erro/informação,Descrição do erro/informação, Título do cabeçalho}
	HttpSession->PWSTMS19INFO:= {Nil, Nil, Nil, Nil}
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	oObj := WSTMSCFGUSER():NEW()
	WsChgUrl(@oObj,"TMSCFGUSER.APW")

	HttpSession->PWSTMS19INFO[1] := STR0001 //"Alteração de Dados Cadastrais"
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
	
	//-- Envio dos dados para Alteração
	If oObj:PUTCHGUSER(oUserData,GetUsrCode()) 
	                       
		HttpSession->PWSTMS19INFO[2] := oObj:cPUTCHGUSERRESULT
		HttpSession->PWSTMS19INFO[3] := STR0002 //"Alteração"
		If  "sucesso" $ HttpSession->PWSTMS19INFO[2]
			HttpSession->PWSTMS19INFO[4] := ""
		Else 
			HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		EndIf
		cHtml := ExecInPage( "PWSTMS19" ) 
		
	Else
		HttpSession->PWSTMS19INFO[2] := STR0006+GetWSCError() //"Erro de Execução : "
		HttpSession->PWSTMS19INFO[3] := STR0007 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		cHtml := ExecInPage( "PWSTMS19" )
		
	Endif
   
	WEB EXTENDED END

Else 

	//-- Session com { Título do erro/informação,Descrição do erro/informação, Título do cabeçalho}
	HttpSession->PWSTMS19INFO:= {Nil, Nil, Nil, Nil}
	
	WEB EXTENDED INIT cHtml
	
	oObj := WSTMSCFGUSER():NEW()
	WsChgUrl(@oObj,"TMSCFGUSER.APW")
	
	HttpSession->PWSTMS19INFO[1] := STR0008 //"Solicitação de Acesso"
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
		
	//-- Envio dos dados para inclusão
	If oObj:PUTNEWUSER(oUserData) 
	                       
		HttpSession->PWSTMS19INFO[2] := oObj:cPUTNEWUSERRESULT
		HttpSession->PWSTMS19INFO[3] := STR0009 //"Inclusão"
		If "sucesso" $ HttpSession->PWSTMS19INFO[2]
			HttpSession->PWSTMS19INFO[4] := STR0004 //"fechar"
		Else 
			HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		EndIf
		cHtml := ExecInPage( "PWSTMS19" ) 
		
	Else
		HttpSession->PWSTMS19INFO[2] := STR0006+GetWSCError() //"Erro de Execução : "
		HttpSession->PWSTMS19INFO[3] := STR0007 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		cHtml := ExecInPage( "PWSTMS19" )
		
	Endif

	WEB EXTENDED END

EndIf

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS16  ºAutor  ³Gustavo Almeida  º Data ³  19/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina de F3 para o Portal TMS                       º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Web Function PWSTMS16()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSTMS16" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS17  ºAutor  ³Gustavo Almeida  º Data ³  26/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina para inclusão de Região de Origem.            º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSTMS17()

Local cHtml     := ""
Local oObj 

//-- Session com { Título do erro/informação,Descrição do erro/informação, Título do cabeçalho}
HttpSession->PWSTMS19INFO:= {Nil, Nil, Nil, Nil} 

HttpSession->PWSTMS19INFO[1]:= STR0010 //"Região de Origem"

WEB EXTENDED INIT cHtml START "InSite"

//-- Configuração de Região de Origem
If !Empty(HttpGet->cRegOri)           

	oObj := WSTMSCFGUSER():NEW()
	WsChgUrl(@oObj,"TMSCFGUSER.APW")
	
	//-- Envio dos dados para inclusão
	If oObj:PUTAREAREQUESTOR(HttpGet->cRegOri,GetUsrCode()) 
		cHtml += ExecInPage( "PWSTMS10" )
	Else
		HttpSession->PWSTMS19INFO[3]:= STR0007 //"Erro"
		HttpSession->PWSTMS19INFO[2]:= STR0006+GetWSCError() //"Erro de Execução : "
		HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		cHtml += ExecInPage( "PWSTMS19" )
	Endif
	
EndIf

WEB EXTENDED END

Return cHtml 
       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS18  ºAutor  ³Gustavo Almeida  º Data ³  05/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina com layout de cadastro de usuário no portal.  º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Web Function PWSTMS18()

Local cHtml := ""

If HttpGet->x = "4"
	//-- Dados já informados

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
		HttpSession->PWSTMS19INFO[2] := STR0006+GetWSCError() //"Erro de Execução : "
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS1A  ºAutor  ³Gustavo Almeida  º Data ³  16/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina com layout da página de Browser para F3(TMS16)º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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


If HttpGet->cF3 = "DUY" //-- Região de Origem       
	
	//-- Listagem
	If oObj:GETBROWSERDUY()
		For nX:=1 to Len(oObj:oWSGETBROWSERDUYRESULT:oWSDUY)
		
			//-- Paginação
			If nX%6 == 0
				nPagina++	
			EndIf
			
			//-- Busca
			 If !Empty(HttpGet->cBusca)
			 	If HttpGet->cTipo == "1" //-- por descrição
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
 
ElseIf HttpGet->cF3 = "DLA" //-- Sequencia de Endereços         
	
	//-- Listagem
	If oObj:GETBROWSERDLA(GetUsrCode())
		For nX:=1 to Len(oObj:oWSGETBROWSERDLARESULT:oWSDLA) 
		
			//-- Paginação
			If nX%6 == 0
				nPagina++	
			EndIf   
			
			//-- Busca
			If !Empty(HttpGet->cBusca)
				If HttpGet->cTipo == "1" //-- por endereço
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
		
			 //-- Paginação
			 If nX%6 == 0
			 	nPagina++	
			 EndIf
			 
		  	 //-- Busca
			 If !Empty(HttpGet->cBusca)
			 	If HttpGet->cTipo == "1" //-- por código
			 		If (AllTrim(HttpGet->cBusca)) $ (AllTrim(oObj:oWSGETBROWSERDLCRESULT:oWSBROWSERGENERIC[nX]:cBGCODE))
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDLCRESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
				         									       oObj:oWSGETBROWSERDLCRESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.T.,nPagina})
				      HttpGet->cPagina:= Str(nPagina)
				   Else 
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERDLCRESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
				         									       oObj:oWSGETBROWSERDLCRESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.F.,nPagina})
				   EndIf
				ElseIf HttpGet->cTipo == "2" //-- por descrição
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
		
			 //-- Paginação
			 If nX%6 == 0
			 	nPagina++	
			 EndIf
			 
		  	 //-- Busca
			 If !Empty(HttpGet->cBusca)
			 	If HttpGet->cTipo == "1" //-- por código
			 		If (AllTrim(Upper(HttpGet->cBusca))) $ (AllTrim(Upper(oObj:oWSGETBROWSERMGRESULT:oWSBROWSERGENERIC[nX]:cBGCODE)))
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERMGRESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
				         									       oObj:oWSGETBROWSERMGRESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.T.,nPagina})
				      HttpGet->cPagina:= Str(nPagina)
				   Else 
					   aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERMGRESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
					         									    oObj:oWSGETBROWSERMGRESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.F.,nPagina})
				   EndIf
				ElseIf HttpGet->cTipo == "2" //-- por descrição
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
		
			 //-- Paginação
			 If nX%6 == 0
			 	nPagina++	
			 EndIf
			 
		  	 //-- Busca
			 If !Empty(HttpGet->cBusca)
			 	If HttpGet->cTipo == "1" //-- por código
			 		If (AllTrim(HttpGet->cBusca)) $ (AllTrim(oObj:oWSGETBROWSERSB1RESULT:oWSBROWSERGENERIC[nX]:cBGCODE))
				 		aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERSB1RESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
				         									       oObj:oWSGETBROWSERSB1RESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.T.,nPagina})
				      HttpGet->cPagina:= Str(nPagina)
				   Else 
					   aAdd( HttpSession->APWSTMS1AITENS, { oObj:oWSGETBROWSERSB1RESULT:oWSBROWSERGENERIC[nX]:cBGCODE,;
					         									    oObj:oWSGETBROWSERSB1RESULT:oWSBROWSERGENERIC[nX]:cBGDESCRIPTION,.F.,nPagina})
				   EndIf
				ElseIf HttpGet->cTipo == "2" //-- por descrição
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS1B  ºAutor  ³Gustavo Almeida  º Data ³  16/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina com layout da página de Busca para F3(TMS16). º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSTMS1B()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSTMS1B" )

WEB EXTENDED END

Return cHtml 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebFunction  ³PWSTMS1C  ºAutor  ³Gustavo Almeida  º Data ³  23/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina com layout da página de Inclusão de Endereços.º±±
±±º             ³                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSTMS1C()

Local cHtml   := ""
Local nI      :=0

oObj := WSTMSCFGUSER():NEW()
WsChgUrl(@oObj,"TMSCFGUSER.APW")

WEB EXTENDED INIT cHtml START "InSite" 

//-- Foco na página
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
  
	//-- Proxima sequencia de endereço
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
	
	HttpSession->PWSTMS19INFO[1]:= STR0011 //"Inclusão de Seq. de Endereço"
	
	HttpSession->OPWSTMS1CINFO:= TMSCFGUSER_DLA():New()
	  
	//Valores para Inclusão
	HttpSession->OPWSTMS1CINFO:CDLAAREACODE  := HttpPost->CDRDESA
	HttpSession->OPWSTMS1CINFO:CDLAADRESSSEQ := HttpPost->SEQEND
	HttpSession->OPWSTMS1CINFO:CDLAADRESS    := HttpPost->DULENDA
	HttpSession->OPWSTMS1CINFO:CDLADISTRICT  := HttpPost->BAIRROA
	HttpSession->OPWSTMS1CINFO:CDLACITY      := HttpPost->MUNVPRE
	HttpSession->OPWSTMS1CINFO:CDLASTATE     := HttpPost->ESTVPRE
	HttpSession->OPWSTMS1CINFO:CDLAZIP       := HttpPost->CEPA
			
	If oObj:PUTADRESSSEQ(GetUsrCode(),HttpSession->OPWSTMS1CINFO)
		HttpSession->PWSTMS19INFO[2] := "<center>"+STR0012+"</center>"  //"Inclusão efetuada com sucesso!"
		HttpSession->PWSTMS19INFO[4] := STR0004 //"fechar"
		cHtml += ExecInPage( "PWSTMS19" )
	Else
		HttpSession->PWSTMS19INFO[2] := STR0006+GetWSCError() //"Erro de Execução : "
		HttpSession->PWSTMS19INFO[3] := STR0007 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		cHtml += ExecInPage( "PWSTMS19" )
	EndIf

ElseIf HttpPost->cAct == "ALT" .And. Empty(HttpPost->cGATILHOCAMP)//-- Alterar
	
	HttpSession->PWSTMS19INFO:= {Nil, Nil, Nil, Nil}
	
	HttpSession->PWSTMS19INFO[1]:= STR0013 //"Alteração de Seq. de Endereço"
	
	HttpSession->OPWSTMS1CINFO:= TMSCFGUSER_DLA():New()
	  
	//Valores para Alteração
	HttpSession->OPWSTMS1CINFO:CDLAAREACODE  := HttpPost->CDRDESA
	HttpSession->OPWSTMS1CINFO:CDLAADRESSSEQ := HttpSession->CPWSTMS1CSEQEND
	HttpSession->OPWSTMS1CINFO:CDLAADRESS    := HttpPost->DULENDA
	HttpSession->OPWSTMS1CINFO:CDLADISTRICT  := HttpPost->BAIRROA
	HttpSession->OPWSTMS1CINFO:CDLACITY      := HttpPost->MUNVPRE
	HttpSession->OPWSTMS1CINFO:CDLASTATE     := HttpPost->ESTVPRE
	HttpSession->OPWSTMS1CINFO:CDLAZIP       := HttpPost->CEPA
	
	If oObj:CHGADRESSSEQ(GetUsrCode(),HttpSession->OPWSTMS1CINFO,HttpSession->OPWSTMS1CINFO:CDLAADRESSSEQ)
	
		HttpSession->PWSTMS19INFO[2] := "<center>"+STR0014+"</center>" //"Alteração efetuada com sucesso!"
		HttpSession->PWSTMS19INFO[4] := STR0004 //"fechar"
		cHtml += ExecInPage( "PWSTMS19" )
	Else
		HttpSession->PWSTMS19INFO[2] := STR0006+GetWSCError() //"Erro de Execução : "
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
	  	 
		//-- Municipio de Região de Origem e Estado
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSTMS1D   ºAutor  ³Gustavo Almeida      º Data ³  17/03/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina com layout da página de alteração de senha.    º±±
±±º             ³                                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSTMS1D()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSTMS1D" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSTMS1E   ºAutor  ³Gustavo Almeida      º Data ³  17/03/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina com a alteração de senha.                      º±±
±±º             ³                                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSTMS1E()

Local cHtml := ""

HttpSession->PWSTMS19INFO:= {Nil, Nil, Nil, Nil}
HttpSession->PWSTMS19INFO[1] := STR0015 //"Alteração de Senha"

WEB EXTENDED INIT cHtml START "InSite"

	oObj := WSUSERPORTAL():NEW()
	
	WsChgUrl(@oObj,"USERPORTAL.apw")
	
	If AllTrim( GetUsrSenha() ) != HttpPost->UserPsw
	
		HttpSession->PWSTMS19INFO[2] := STR0016 //"Senha atual digitada não confere!"
		HttpSession->PWSTMS19INFO[3] := STR0007 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		cHtml += ExecInPage( "PWSTMS19" )
		
	ElseIf oObj:PRTPSWUSER( GetUsrCode(), AllTrim(GetUsrSenha()), HttpPost->UserNewPsw )
	
		If !SetUsrSenha( HttpPost->UserNewPsw )
			HttpFreeSession()
		Endif
		
		HttpSession->PWSTMS19INFO[2] := STR0017 //"Nova senha cadastrada com sucesso"
		HttpSession->PWSTMS19INFO[3] := STR0015 //"Alteração de Senha"
		HttpSession->PWSTMS19INFO[4] := ""
		cHtml += ExecInPage( "PWSTMS19" )
		
	Else
 		HttpSession->PWSTMS19INFO[2] := STR0018+GetWSCError() //"Alteração não efetuada "
		HttpSession->PWSTMS19INFO[3] := STR0007 //"Erro"
		HttpSession->PWSTMS19INFO[4] := STR0005 //"voltar"
		cHtml += ExecInPage( "PWSTMS19" )

	Endif
	
WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSTMS1F   ºAutor  ³Gustavo Almeida      º Data ³  17/03/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.        ³ WebRotina com layout da página de reenvio de senha.      º±±
±±º             ³                                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Portal TMS - Gestão de Transportes                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
		If "informado" $ oObj:cGETPWDUSERRESULT  //-- Login não existe em base
			HttpSession->PWSTMS19INFO[2] := STR0022 //"Login não cadastrado."
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