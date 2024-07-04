#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRMXFUN.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "CRMDEF.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWTABLEATTACH.CH"
#INCLUDE "FWCALENDARWIDGET.CH"

Static lFixSXB 		:= .F.
Static lCallGFSXB	:= .F.

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXEnvMail

Funcao generica para envio de e-mail utilizando as configuracoes de E-mail/Proxy
especificados atraves do Configurador.

@sample   CRMXEnvMail(cFrom, cTo, cCc, cBcc, cSubject, cBody, cAlias, cCodEnt, lAuto, cUserAut, cPassAut)

@param	  ExpC1 - Rementente
		  ExpC2 - Destinatario
		  ExpC3 - Copia
		  ExpC4 - Copia Oculta
		  ExpC5 - Assunto
		  ExpC6 - Mensagem / Texto
		  ExpC7 - Alias da Entidade que possuie Anexo
		  ExpC8 - Codigo da entidade(Chave unica de relacionamento na AC9, para buscar o Registro que possue anexo).
		  ExpL9 - Indica se a chamada é automatica, se for não mostra a telas de aviso.
		  ExpC10 - Usuario para Autenticacao SMTP.
		  ExpC11 - Senha para Autentica SMTP.

@return  lRet

@author  Thiago Tavares
@since	  19/05/2013
@version 11.90
/*/
//------------------------------------------------------------------------------
Function CRMXEnvMail(cFrom, cTo, cCc, cBcc, cSubject, cBody, cAlias, cCodEnt, lAuto, cUserAut, cPassAut, aAnexo)

Local aArea       := GetArea()
Local oMailServer := Nil
Local lRetorno    := .F.
Local nSMTPPort   := SuperGetMV("MV_PORSMTP",.F.,25)  				// Porta SMTP.
Local cSMTPAddr   := AllTrim( SuperGetMV("MV_RELSERV",.F.,"") ) 	// Endereco SMTP.
Local cUser       := AllTrim( SuperGetMV("MV_RELACNT",.F.,"") )		// Conta a ser utilizada no envio de E-Mail para os relatorios.
Local cPass       := SuperGetMV("MV_RELPSW" ,.F.,"") 			 	// Senha da Conta de E-Mail para envio de relatorios.
Local lAutentica  := SuperGetMV("MV_RELAUTH",.F.,.F.) 				// Servidor de EMAIL necessita de Autenticacao?
Local nSMTPTime	  := SuperGetMV("MV_RELTIME",.F.,120) 				// Timeout no Envio de EMAIL.
Local lSSL        := SuperGetMV("MV_RELSSL",.F.,.F.)  				// Define se o envio e recebimento de e-mails na rotina SPED utilizara conexao segura (SSL).
Local lTLS        := SuperGetMV("MV_RELTLS",.F.,.F.)  				// Informe se o servidor de SMTP possui conexao do tipo segura ( SSL/TLS ).
Local nError      := 0  									 				// Controle de Erro.
Local nPortAddSrv := 0
Local nX          := 0

Default	aAnexo		:= {}
Default cFrom     	:= AllTrim( SuperGetMV("MV_RELACNT",.F.,"") )		// E-mail utilizado no campo FROM no envio de relatorios por e-mail
Default cTo       	:= ""
Default cCc       	:= ""
Default cBcc      	:= ""
Default cSubject  	:= ""
Default cBody     	:= ""
Default cAlias    	:= ""
Default cCodEnt   	:= ""
Default cUserAut	:= ""  // Usuario para Autenticacao no Servidor de E-mail
Default cPassAut	:= ""  // Senha para autenticacäo no servidor de E-mail

Default lAuto     := .F.

/*
 Se autenticacao estiver ligada priorizar os parametros da função.
 Senao considerar do configurador.
*/
If lAutentica
	If Empty( cUserAut ) .OR. Empty( cPassAut )
		cFrom 	 := AllTrim( SuperGetMV("MV_RELACNT",.F.,"") )
		cUserAut := SuperGetMV("MV_RELAUSR",.F.,"")
		cPassAut := SuperGetMV("MV_RELAPSW",.F.,"")
	EndIf
	cUserAut := AllTrim( cUserAut )
	cUser 	 := cUserAut
	cPass 	 := cPassAut
EndIf

oMailServer := TMailManager():New()

// Usa SSL, TLS ou nenhum na inicializacao
If lSSL
	oMailServer:SetUseSSL(lSSL)
ElseIf lTLS
	oMailServer:SetUseTLS(lTLS)
Endif

// Inicializacao do objeto de Email
If nError == 0
	//Prioriza se a porta está no endereço
	nPortAddSrv := AT(":",cSMTPAddr)

	If nPortAddSrv > 0
		nSMTPPort := Val(Substr(cSMTPAddr, nPortAddSrv + 1,Len(cSMTPAddr)))
		cSMTPAddr := Substr(cSMTPAddr, 0, nPortAddSrv - 1)
	EndIf

	nError := oMailServer:Init("",cSMTPAddr,cUser,cPass,,nSMTPPort)
	If nError <> 0
		Conout(STR0013+ oMailServer:GetErrorString(nError)) // Falha ao conectar:"
	EndIf
Endif

// Define o Timeout SMTP
If ( nError == 0 .And. oMailServer:SetSMTPTimeout(nSMTPTime) <> 0 )
	nError := 1
	Conout(STR0014) // Falha ao definir timeout
EndIf

// Conecta ao servidor
If nError == 0
	nError := oMailServer:SmtpConnect()
	If nError <> 0
		Conout(STR0013 + oMailServer:GetErrorString(nError)) // Falha ao conectar:
		oMailServer:SMTPDisconnect()
	EndIf
EndIf

// Realiza autenticacao no servidor
If nError == 0 .And. lAutentica
	nError	:= oMailServer:SmtpAuth(cUserAut,cPassAut)
	If nError <> 0
		Conout(STR0015+ oMailServer:GetErrorString(nError)) // Falha ao autenticar:
		oMailServer:SMTPDisconnect()
	EndIf
EndIf

If nError == 0

	oMessage := TMailMessage():New()
	oMessage:Clear()

	oMessage:cFrom    := cFrom
	oMessage:cTo      := cTo
	oMessage:cCc      := cCc
	oMessage:cBcc     := cBcc
	oMessage:cSubject := cSubject
	oMessage:cBody    := cBody

	If !Empty(cAlias) .And. !Empty(cCodEnt)  // verificando se existe Anexos, se existir anexar ao email
		BeginSql Alias "TMPALIAS"
			SELECT
			ACB.ACB_OBJETO
			FROM
			%Table:AC9% AC9 INNER JOIN %Table:ACB% ACB ON (ACB.ACB_CODOBJ = AC9_CODOBJ)
			WHERE
			AC9.AC9_FILIAL = %xFilial:AC9%          AND
			AC9.AC9_ENTIDA = %Exp:cAlias%           AND
			AC9.AC9_FILENT = %Exp:xFilial(cAlias)%  AND
			AC9.AC9_CODENT = %Exp:cCodEnt%          AND
			AC9.%NotDel%
		EndSql

		While TMPALIAS->(!Eof())
			oMessage:AttachFile(MsDocPath()+"\"+AllTrim(TMPALIAS->ACB_OBJETO))
			TMPALIAS->(DbSkip())
		EndDo

		For nX := 1 To Len(aAnexo)
			oMessage:AttachFile(aAnexo[nX][1])
			oMessage:AddAttHTag('Content-ID: '+aAnexo[nX][2]) 
		Next nX

		TMPALIAS->(DbCloseArea())
	EndIf

	nError := oMessage:Send( oMailServer )

	If nError <> 0
		If !lAuto
			MsgAlert(STR0002 + oMailServer:GetErrorString(nError),STR0004)//"Falha no envio do Email - "   #Atencao
		Else
			Conout(STR0002 + oMailServer:GetErrorString(nError))
		EndIf
	Else
		lRetorno := .T.
		If !lAuto .And. !IsInCallStack("CRMA180")
			MsgAlert(STR0003,STR0004)//"Email enviado com sucesso."#Atencao
		Else
			Conout(STR0003)
		EndIf
	EndIf

	oMailServer:SmtpDisconnect()

EndIf

RestArea(aArea)

Return(lRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXRetVend

Retorna o codigo do vendedor do usuário logado no CRM.

@sample 	CRMXRetVend()

@param		Nenhum

@Return   	ExpC - Codigo do vendedor

@author		Thiago Tavares
@since		24/03/2014
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMXRetVend(cCodUsr)

Local aArea	 	:= GetArea()
Local aAreaUSR	:= {}
Local cCodVend	:= ""
Local lPosVend	:= .T.
Local __aUserRole := {} 

Default cCodUsr	:= CRMXCodUser()

If SuperGetMv("MV_CRMUAZS",, .F.)
	__aUserRole := CRMXGetRole()
	If ( !Empty( __aUserRole ) .And. __aUserRole[USER_PAPER_CODUSR] == cCodUsr )
		cCodVend := __aUserRole[USER_PAPER_CODVEND]
	EndIf
Else
	aAreaUSR := AO3->(GetArea())
	DbSelectArea("AO3")	// Usuários do CRM
	DbSetOrder(1)      	// AO3_FILIAL + AO3_CODUSR
	
	If ( !Empty(cCodUsr) .AND. (AO3->AO3_CODUSR <> cCodUsr) )
		lPosVend := AO3->(DbSeek(xFilial("AO3")+cCodUsr))
	EndIf
	
	If !Empty(cCodUsr) .AND. lPosVend
		cCodVend := AO3->AO3_VEND
	EndIf
	RestArea(aAreaUSR)
EndIf

RestArea(aArea)

Return(cCodVend)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXIntVend

Inicializa os campos de vendedor para as entidades do CRM.

@sample 	CRMXIntVend()

@param		Nenhum

@Return   	ExpC Código do Vendedor

@author	Anderson Silva
@since		29/10/2013
@version	11.90
/*/
//------------------------------------------------------------------------------
Function CRMXIntVend()

Local aArea		:= GetArea()
Local cCodVend	:= ""

//Retorna o codigo do vendedor logado somente no SIGACRM.
If nModulo == 73
	cCodVend := CRMXRetVend()
EndIf

RestArea(aArea)

Return(cCodVend)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXGetSX2

Obtém o X2_UNICO, X2_DISPLAY, X2_SYSOBJ ou Chave Unica sem Funcao ADVPL.

@sample		CRMXGetSX2( cAliasEnt, lUnqNoFunc )

@param		ExpC1 - Alias atual
			ExpL2 - Monta a chave unica sem funções ADVPL.

@Return		ExpA - Array com X2_UNICO, X2_DISPLAY e X2_SYSOBJ.

@author		Cristiane Nishizaka
@since		07/02/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMXGetSX2(cAliasEnt, lUnqNoFunc)

Local aArea			:= {}
Local aAreaSX2 		:= {}
Local aAreaSX3 		:= {}
Local aCmpDisp		:= {}
Local aCampos		:= {}
Local aRet 			:= {}
Local aSX2Info		:= {}
Local cX3Cmp     	:= "X3_RELACAO"
Local cCpoNoFunc	:= ""
Local cUnqNoFunc	:= ""
Local cDisplay		:= ""
Local cExpress 		:= ""
Local cUnico		:= ""
Local cX2Display	:= ""
Local cSysObj		:= ""
Local nPosFunc		:= 0
Local nX			:= 0
Local lSX2Found		:= .F.

Default lUnqNoFunc	:= .F.

If !Empty( cAliasEnt )

	If	GetRpoRelease() >= "12.1.027"
		If	( lSX2Found := FwSX2Util():SeekX2File(cAliasEnt) )
			aSX2Info	:= FwSX2Util():GetSX2Data(cAliasEnt /*cAlias*/, {"X2_UNICO","X2_DISPLAY","X2_SYSOBJ"} /*aFields*/, /*lQuery*/)
			cUnico		:= AllTrim(aSX2Info[01,02])
			cX2Display	:= AllTrim(aSX2Info[02,02])
			cSysObj		:= AllTrim(aSX2Info[03,02])
		EndIf
	Else
		aArea			:= GetArea()
		aAreaSX2 		:= SX2->(GetArea())
		aAreaSX3 		:= SX3->(GetArea())
		SX2->(DbSetOrder(1))
		If	( lSX2Found := SX2->(DbSeek(cAliasEnt)) )
			cUnico		:= AllTrim(SX2->X2_UNICO)
			cX2Display	:= AllTrim(SX2->X2_DISPLAY)
			cSysObj		:= AllTrim(SX2->X2_SYSOBJ)
		EndIf
	EndIf

	If lSX2Found .AND. ! Empty(cUnico)

		If ! Empty(cX2Display)

			aCmpDisp := StrTokArr(AllTrim(cX2Display),"+")// criando um array com os campos presentes no display

			SX3->(DbSetOrder(2))//X3_CAMPO
			For nX := 1 to Len(aCmpDisp) // Pegando somente campos reais do display para poder macro executar
				If SX3->(DbSeek(aCmpDisp[nX]))

					If SX3->X3_CONTEXT <> "V" //Diferente de campo virtual
						If SX3->X3_TIPO == "D" //  tratando campo do tipo data
							cExpress := "DTOC("+aCmpDisp[nX]+")"
						Else
							cExpress := aCmpDisp[nX]
						EndIf
					Else
						cExpress := StrTran(AllTrim(GetSx3Cache(aCmpDisp[nX],cX3Cmp)),'"',"'",,)
					EndIf

					If Empty(cDisplay) .AND. !Empty(cExpress)//montando a expressão para macro executar
						cDisplay += cExpress
					ElseIf !Empty(cExpress)
						cDisplay += "+' | '+"+ cExpress
					EndIf

				EndIf
			Next nX
		EndIf

		cUnico	:= AllTrim( SubStr( cUnico, At( "+", cUnico ) + 1, Len( cUnico ) ) )
		aRet	:= {cUnico, cDisplay, cSysObj}

		If lUnqNoFunc
			aCampos := StrTokArr(cUnico,"+")
			For nX := 1 To Len(aCampos)
				nPosFunc 	:= At("(",aCampos[nX])
				If nPosFunc == 0
					cUnqNoFunc += ( aCampos[nX] + If(nX <> Len(aCampos), "+", "") )
				Else
					cCpoNoFunc := SubStr(aCampos[nX],nPosFunc+1,(Len(aCampos[nX])-nPosFunc)-1)
					cUnqNoFunc += ( cCpoNoFunc  + If(nX <> Len(aCampos), "+", "") )
				EndIf
			Next nX
			aAdd(aRet,cUnqNoFunc)
		EndIf

	EndIf

EndIf

If	GetRpoRelease() < "12.1.027"
	RestArea(aAreaSX2)
	RestArea(aAreaSX3)
	RestArea(aArea)
	aSize(aAreaSX2,0)
	aSize(aAreaSX3,0)
	aSize(aArea,0)
EndIf
FreeObj(aSX2Info)
Return(aRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXGMnDef

Busca o menudef da rotina da entidade.
Abre o cadastro da entidade em modo de visualização.

@sample		CRMXGMnDef( cEntidade, cUnico )

@param		ExpC1 - Alias Entidade
			ExpC2 - X2_UNICO posicionado

@Return		ExpL - Verdadeiro

@author		Cristiane Nishizaka
@since		07/02/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMXGMnDef(cAlias, cUnico)

Local aArea		:= GetArea()
Local aAreaEnt 	:= ( cAlias )->( GetArea() )
Local lRet		:=	.T.
Local aDadosSX2	:= CRMXGetSX2( cAlias )
Local aRotina	:= {}
Local cFuncVisu	:= ""
Local cX2Obj	:= ""

//Variável criada para possibilitar a chamada da função AXVisual
Private cCadastro	:= STR0011		// "Visualizar"

DbSelectArea( cAlias )
DbSetOrder( 1 )

cX2Obj		:= AllTrim( aDadosSX2[3] )
aRotina 	:= &( "StaticCall( " + cX2Obj + ", MENUDEF )" )
cFuncVisu	:= aRotina[2][2]

If ( cAlias )->( DbSeek( cUnico ) )
	// Se a função estiver em MVC
	If Left( AllTrim( cFuncVisu ), 7 ) == "VIEWDEF"
		FWExecView( STR0011, AllTrim( cFuncVisu ), 1, /*oDlg*/, /*bCloseOnOk*/, /*bOk*/, /*nPercReducao*/ )		// "Visualizar"
	Else
		&( cFuncVisu + "( '" + cAlias + "', " + AllTrim( Str( ( cAlias )->( Recno() ) ) ) + ", 2 )" )
	EndIf
Else
	Help("",1, "HELP", ,STR0012, 1, )//"Problemas para visualizar este registro !"
	lRet := .F.
EndIf

RestArea(aAreaEnt)
RestArea(aArea)

Return(lRet)

//----------------------------------------------------------
/*/{Protheus.doc} CRMXVldEnt()

Rotina para Validar o valor digitado no Campo AOF_ENTIDA

Exemplo :  cAlias = "SA3"
           nRotina = 2

a rotina irá verificar se o alias SA3 está disponivel para a rotina de atividades

@param	   ExpC1 - Alias Entidade
		   ExpN1 - Numero que representa a Rotina que deverá ser verificada a permissão do Alias
		            esse numero deverá ser passado pela variavel DEFINE que está no fonte CRMDEF
		     		#DEFINE RESPECIFICACAO   1
			 		#DEFINE RATIVIDADE        2
			 		#DEFINE RCONEXAO          3
			 		#DEFINE RANOTACOES        4
			 		#DEFINE REMAIL            5
       			    #DEFINE RCEMAIL           6
@return   ExpL - Verdadeiro / Falso

@author   Victor Bitencourt
@since    26/02/2014
@version  12.0
/*/
//----------------------------------------------------------
Function CRMXVldEnt(cAlias, nRotina)

Local lRet		:= .T.
Local aAreaAO2 	:= {}

Default cAlias 	:= ""
Default nRotina	:= 0

If Select("AO2") > 0
	aAreaAO2 := AO2->(GetArea())
Else
	DbSelectArea("AO2")
EndIf

AO2->(DbSetOrder(1))//AO2_FILIAL+AO2_ENTID

If !Empty( cAlias ) .AND.  AO2->( DbSeek( xFilial( "AO2" ) + cAlias ) )
	Do Case
		Case nRotina == RESPECIFICACAO
			If AO2->AO2_ESPEC == "1"
				lRet   := .T.
			Else
				lRet   := .F.
			EndIf
		Case nRotina == RATIVIDADE
			If AO2->AO2_ATIV == "1"
				lRet   := .T.
			Else
				lRet   := .F.
			EndIf
		Case nRotina == RCONEXAO
			If AO2->AO2_CONEX == "1"
				lRet   := .T.
			Else
				lRet   := .F.
			EndIf
		Case nRotina == RANOTACOES
			If AO2->AO2_ANOTAC == "1"
				lRet   := .T.
			Else
				lRet   := .F.
			EndIf
		Case nRotina == REMAIL
			If AO2->AO2_MEMAIL == "1"
				lRet   := .T.
			Else
				lRet   := .F.
			EndIf
		Case nRotina == RCEMAIL
			If AO2->AO2_CEMAIL == "1"
				lRet   := .T.
			Else
				lRet   := .F.
			EndIf
	EndCase
ElseIf Empty( cAlias )
	lRet   := .T.
Else
	lRet   := .F.
EndIf

If !Empty(aAreaAO2)
	RestArea(aAreaAO2)
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMInitFun

Funções a serem executadas na entrada do modulo CRM

@sample 	CRMInitFun()

@param		Nenhum

@return		Nenhum

@author		Victor Bitencourt
@since		23/01/2014
@version	12.0
/*/
//---------------------------------------------------------------------
Function CRMInitFun()
	CRMXCRGAO2()
	CRMLayMile()
	CRMXP360()
	CRMXObserver()
	
	If SuperGetMv("MV_CRMUAZS",, .F.)
		CRMXInitRole()
	EndIf
Return( .T. )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMLayMile

Funções a serem executadas na entrada do modulo CRM

@sample 	CRMLayMile()

@param		Nenhum

@Return		Nenhum

@author		Victor Bitencourt
@since		23/01/2014
@version	12.0
/*/
//---------------------------------------------------------------------
Function CRMLayMile()

	Local lImpLayMl := SuperGetMv("MV_MLLYENT",,.T.)
	Local oFwMile 	:= FwMile():New()  //Não retirar esta variável do fonte.

	//Apaga layout NeoWay descontinuado;
	If !lImpLayMl
		NwLayClear()
	EndIf

	If  lImpLayMl

		If !(TkxExtMile("ACHLAY01"))
			Tk341Mile("ACHLAY01")
		EndIf

		If !(TkxExtMile("SUSLAY01"))
			Tk260Mile("SUSLAY01")
		EndIf

		If !(TkxExtMile("SA1LAY01"))
			Ma030Mile("SA1LAY01")
		EndIf

		If !(TkxExtMile("TK700IMP"))
			Tk700Mile("TK700IMP")
		EndIf

		DbSelectArea("SX6")
		DbSetOrder(1)

		PutMv("MV_MLLYENT",.F.)

	EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXNewOpo

Rotina que inclui uma nova oportuniadde conforme o registro posiciondo

@sample 	CRMXNewOpo()

@param		ExpC1 - Alias Entidade que está chamando
		    ExpC2 - Codigo do registro posicionado
		    ExpC3 - Loja do registro posicionado

@return		Nenhum

@author		Victor Bitencourt
@since		01/05/2014
@version	12.0
/*/
//---------------------------------------------------------------------
Function CRMXNewOpo(cEntidad, cCodEnt, cLojEnt)

Local oModel    := Nil
Local oFWMVCWin := Nil
Local aSize	 	:= FWGetDialogSize( oMainWnd )	// Coordenadas da Dialog Principal.
Local aError	:= {}

Default cEntidad	:= ""
Default cCodEnt		:= ""
Default cLojEnt		:= ""

If MPUserHasAccess("FATA300", 3, /*cUserId*/, .T.)
	oModel := FwLoadModel("FATA300")
	oModel:SetOperation(3)
	oModel:Activate()

	If oModel:IsActive()
		If !Empty(cEntidad) .AND. cEntidad == "SUS"
			oModel:GetModel("AD1MASTER"):SetValue("AD1_PROSPE",cCodEnt)
			oModel:GetModel("AD1MASTER"):SetValue("AD1_LOJPRO",cLojEnt)
		ElseIf !Empty(cEntidad) .AND. cEntidad == "SA1"
			oModel:GetModel("AD1MASTER"):SetValue("AD1_CODCLI",cCodEnt)
			oModel:GetModel("AD1MASTER"):SetValue("AD1_LOJCLI",cLojEnt)
		EndIf

		oView := FWLoadView("FATA300")
		oView:SetModel(oModel)
		oView:SetOperation(3)

		oFWMVCWin := FWMVCWindow():New()
		oFWMVCWin:SetUseControlBar(.T.)

		oFWMVCWin:SetView(oView)
		oFWMVCWin:SetCentered(.T.)
		oFWMVCWin:SetPos(aSize[1],aSize[2])
		oFWMVCWin:SetSize(aSize[3],aSize[4])
		oFWMVCWin:SetTitle(STR0021)//"Incluir"
		oFWMVCWin:oView:BCloseOnOk := {|| .T.  }

		oFWMVCWin:Activate()
	Else
		aError := oModel:GetErrorMessage()
		If !Empty( aError )
			Help("",1,Alltrim(aError[5]),,aError[6],1)
		EndIf
	EndIF
Endif

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXNewApo

Rotina que inclui um novo apontamento conforme o registro posiciondo

@sample 	CRMXNewApo(cEntidad, cCodEnt, cLojEnt)

@param		ExpC1 - Alias Entidade que está chamando
		    ExpC2 - Codigo do registro posicionado
		    ExpC3 - Loja do registro posicionado

@return	Nenhum

@author	Victor Bitencourt
@since		01/05/2014
@version	12.0
/*/
//---------------------------------------------------------------------
Function CRMXNewApo(cEntidad, cCodEnt, cLojEnt)

Local oModel    := Nil
Local oFWMVCWin := Nil
Local aSize	 	:= FWGetDialogSize( oMainWnd )	// Coordenadas da Dialog Principal.
Local aError	:= {}

Default cEntidad	:= ""
Default cCodEnt		:= ""
Default cLojEnt		:= ""

If MPUserHasAccess("FATA310", 3, /*cUserId*/, .T.)
	oModel := FwLoadModel("FATA310")
	oModel:SetOperation(3)
	oModel:Activate()

	If oModel:iSActive()
		If !Empty(cEntidad) .AND. cEntidad == "SUS"
			oModel:GetModel("AD5MASTER"):SetValue("AD5_PROSPE",cCodEnt)
			oModel:GetModel("AD5MASTER"):SetValue("AD5_LOJPRO",cLojEnt)
		ElseIf !Empty(cEntidad) .AND. cEntidad == "SA1"
			oModel:GetModel("AD5MASTER"):SetValue("AD5_CODCLI",cCodEnt)
			oModel:GetModel("AD5MASTER"):SetValue("AD5_LOJA",cLojEnt)
		ElseIf !Empty(cEntidad) .AND. cEntidad == "AD1"
			oModel:GetModel("AD5MASTER"):SetValue("AD5_NROPOR",cCodEnt)
		EndIf


		oView := FWLoadView("FATA310")
		oView:SetModel(oModel)
		oView:SetOperation(3)

		oFWMVCWin := FWMVCWindow():New()
		oFWMVCWin:SetUseControlBar(.T.)

		oFWMVCWin:SetView(oView)
		oFWMVCWin:SetCentered(.T.)
		oFWMVCWin:SetPos(aSize[1],aSize[2])
		oFWMVCWin:SetSize(aSize[3],aSize[4])
		oFWMVCWin:SetTitle(STR0021)//"Incluir"
		oFWMVCWin:oView:BCloseOnOk := {|| .T.  }

			oFWMVCWin:Activate()
	Else
		aError := oModel:GetErrorMessage()
		If !Empty( aError )
			Help("",1,"CRMXNewApo",,aError[6],1)
		EndIf
	EndIf
Endif

Return	Nil

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXVldAli

Função que Valida se o Alias da tabela existe no SX2

@sample	CRMXVldAli(cAlias)

@param		ExpC1 - Alias  da Tabela

@return		ExpL - Indica se foi encontrada ou não a tabela no SX2

@author		Victor Bitencourt
@since		12/09/2014
@version	12.0
/*/
//---------------------------------------------------------------------------------------------------------------
Function CRMXVldAli(cAlias)

Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaSX2 := SX2->(GetArea())

Default cAlias := ""

If !Empty(cAlias)
	DbSelectArea("SX2")
	SX2->(DbSetOrder(1))

	If !SX2->(DbSeek(cAlias))
		Help("",1,"CRMXVLDALI")	// Este alias não existe !
		lRet := .F.
	EndIf
EndIf

RestArea(aAreaSX2)
RestArea(aArea)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMXGeraExcel
Gera uma planilha excel com base nos dados recebidos em arrays ou tabelas.

@param nTipoDados      Tipo dos dados de origem (1=array;2=tabela)
@param aDados           dados de origem (array com arrays ou array com aliases)
@param aFieldsEx        cabecalhos das colunas (array com arrays de estrutura de campos)
@param aSheets          array com os nomes das WorkSheets
@param cNomeArq         Parte inicial do nome do arquivo gerado
@param cDirArq          Diretório da máquina local para geração da planilha

@return lRetorno        Indica se a planilha foi gerada ou nao

@author  Norberto Frassi Jr
@since   06/08/2015
/*/
//-------------------------------------------------------------------
Function CRMXGeraExcel( nTipoDados, aDados, aFieldsEx, aSheets, cNomeArq, cDirArq )

	Local oExcel            := Nil
	Local aRow              := {}
	Local cFile             := ""
	Local nField            := 0
	Local nAlign            := 1
	Local nFormat           := 1
	Local cDirDest          := ""
	Local nWs               := 0
	Local nLinha            := 0
	Local lRetorno          := .T.

	Default nTipoDados      := 1
	Default aDados          := {}
	Default aFieldsEx       := {}
	Default cNomeArq        := FunName()+"_"
	Default aSheets         := {FunDesc()}
	Default cDirArq         := ""

	Do Case
		Case ( Empty( aDados ) .Or. Empty( aFieldsEx ) .Or. Empty( aSheets ) )
			MsgAlert(STR0109)	 //	"Parâmetros inválidos para a geração de planilha."
			lRetorno := .F.
		Case ( Len( aDados ) <> Len( aFieldsEx ) .Or. Len( aDados ) <> Len( aSheets ) )
			MsgAlert(STR0112)	 //	"A quantidade de elementos de dados, cabeçalhos e WorkSheets não é a mesma."
			lRetorno := .F.
		Case !ApOleClient( 'MsExcel' )
			MsgAlert( STR0113 ) //"Não será possível exportar os dados, pois não existe Excel instalado."
			lRetorno := .F.
	EndCase

	If lRetorno

		If ( Empty( cDirArq ) .Or. !File( cDirArq ) )
			cDirDest := GetTempPath(.T.) //	Se Diretório não recebido ou não existir, gera no temporário local do usuário
		Else
			cDirDest := cDirArq	//Diretório recebido
		Endif

		If ( !Empty( cDirArq ) .And. !File( cDirArq ) )
			MsgAlert(STR0110 + cDirArq + STR0111 + cDirDest + ".")		//	"O diretório informado "###" não existe. A planilha será gerada no diretório "
		Endif

		//-------------------------------------------------------------------
		// Define o nome da planilha.
		//-------------------------------------------------------------------
		cFile := AllTrim( cNomeArq ) + DTos( Date() ) + "_" + StrTran( Time(), ":", "" ) + ".xml"

		oExcel := FWMsExcelEx():New()

		//-------------------------------------------------------------------
		// Define o título da planilha e das WorkSheets
		//-------------------------------------------------------------------
		For nWs := 1 to Len( aSheets )

			oExcel:AddworkSheet( aSheets[nWs] )              //  Nome da planilha
			oExcel:AddTable( aSheets[nWs], aSheets[nWs] )     //  Nome da planilha

			//-------------------------------------------------------------------
			// Monta as colunas da planilha.
			//-------------------------------------------------------------------
			For nField := 1 To Len( aFieldsEx[nWs]	)

				If ( aFieldsEx[nWs][nField][2] == "C" )
					nAlign	:= 1
					nFormat	:= 1
				ElseIf( aFieldsEx[nWs][nField][2] == "N" )
					nAlign	:= 3
					nFormat	:= 2
				ElseIf( aFieldsEx[nWs][nField][2] == "D" )
					nAlign	:= 2
					nFormat	:= 4
				Else
					nAlign	:= 1
					nFormat	:= 1
				EndIf

				oExcel:AddColumn( aSheets[nWs], aSheets[nWs], aFieldsEx[nWs][nField][5], nAlign, nFormat, .F.) //   Nome da planilha###Nome da planilha

			Next nField

			If nTipoDados == 1		//	array

				For nLinha := 1 to Len(aDados[nWs])

					//-------------------------------------------------------------------
					// Monta as linhas da planilha.
					//-------------------------------------------------------------------
					aRow := {}
					//-------------------------------------------------------------------
					// Recupera o conteúdo do arquivo temporário.
					//-------------------------------------------------------------------
					For nField := 1 To Len( aFieldsEx[nWs]	)
						aAdd( aRow, ( aDados[nWs][nLinha][nField] ) )
					Next nField

					//-------------------------------------------------------------------
					// Adiciona uma nova linha na planilha.
					//-------------------------------------------------------------------
					oExcel:AddRow( aSheets[nWs], aSheets[nWs], aRow )  //   Nome da planilha###Nome da planilha

				Next nLinha
			Else	//	tabela

				(aDados[nWs])->( DBGoTop() )

				//-------------------------------------------------------------------
				// Monta as linhas da planilha.
				//-------------------------------------------------------------------
				While (aDados[nWs])->( ! Eof() )
					aRow := {}
					//-------------------------------------------------------------------
					// Recupera o conteúdo do arquivo temporário.
					//-------------------------------------------------------------------
					For nField := 1 To Len( aFieldsEx[nWs]	)
						aAdd( aRow, (aDados[nWs])->&( aFieldsEx[nWs][nField][1] ) )
					Next nField

					//-------------------------------------------------------------------
					// Adiciona uma nova linha na planilha.
					//-------------------------------------------------------------------
					oExcel:AddRow( aSheets[nWs], aSheets[nWs], aRow )  //   Nome da planilha###Nome da planilha

					(aDados[nWs])->(DbSkip())
				EndDo
			Endif

		Next nWs

		oExcel:Activate()

		//-------------------------------------------------------------------
		// Gera a planilha no servidor.
		//-------------------------------------------------------------------
		If oExcel:nRows > 0
			oExcel:GetXMLFile( cFile )
			//-------------------------------------------------------------------
			// Copia a planilha para máquina local e executa.
			//-------------------------------------------------------------------
			If ( CpyS2T ( cFile, cDirDest, .T. ) )
				If ( MsgYesNo( STR0114 + cFile + STR0115 + cDirDest + " ? ") ) //"Deseja abrir a planilha "###" gerada no diretório "###cDirArq###" ? "
					ShellExecute( "OPEN", "EXCEL", cDirDest + "\" + cFile, "", SW_SHOWMAXIMIZED )
				EndIf
			EndIf
		EndIf

		//-------------------------------------------------------------------
		// Apaga o arquivo do servidor.
		//-------------------------------------------------------------------
		If ( File( cFile ) )
			FErase( cFile )
		EndIf

		oExcel:DeActivate()

		FreeObj( oExcel )
		oExcel := Nil

	Endif

Return (lRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} DlgMsgCRM
Exibe log de processamento na tela
@param cMsg, caracter: (LOG a ser exibido)
@param cTitle, caracter: Título da tela de LOG de processamento
@param lVScroll, lógico: habilita ou não a barra de scroll vertical
@param lHScroll, lógico: habilita ou não a barra de scroll horizontal
@param lWrdWrap, lógico: habilita a quebra de linha automática ou não, obedecendo ao tamanho da caixa de texto do log
@return lRet, Indica confirmação ou cancelamento
@author     William Pianheri
@since 22/06/2017
@version 1.0
/*/
//------------------------------------------------------------------------------
Function DlgMsgCRM(cMsg,cTitle,lVScroll,lHScroll,lWrdWrap)
Local lRet			:= .F.
Local oFont		:= TFont():New("Courier New",07,15)
Local oMemo		:= Nil
Local oDlgEsc		:= Nil
Default cMsg		:= ""
Default cTitle	:= ""
Default lVScroll	:= .T.
Default lHScroll	:= .F.
Default lWrdWrap	:= .T.
Default lCancel	:= .T.

If !Empty(cMsg)
    Define Dialog oDlgEsc Title AllTrim(cTitle) From 0,0 to 425, 600 Pixel
    @ 000, 000 MsPanel oDlg Of oDlgEsc Size 000,250    // Coordenada para o panel
    oDlg:Align := CONTROL_ALIGN_TOP //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
    @ 005,005 Get oMemo Var cMsg Memo FONT oFont Size 292,186 READONLY Of oDlg Pixel
    oMemo:EnableVScroll(lVScroll)
    oMemo:EnableHScroll(lHScroll)
    oMemo:lWordWrap := lWrdWrap
    oMemo:bRClicked := {|| AllwaysTrue()}
    Define SButton From 196, 270 Type  1 Action (lRet := .T., oDlgEsc:End()) Enable Of oDlg Pixel // OK

    If lCancel
        Define SButton From 196, 240 Type  2 Action (lRet := .F., oDlgEsc:End()) Enable Of oDlg Pixel // Cancelar
    Endif

    Activate Dialog oDlgEsc Centered
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMXPicTel
Função genérica para ajuste da máscara dos campos de Telefone.
@sample	CRMXPicTel(cTipTel)
@param		cTipTel, caracter, Tipo de Telefone (Conforme tipos definidos na tabela AGB)
      		1=U5_FONE
      		2=U5_FCOM1
      		3=U5_FCOM2
      		4=U5_FAX
      		5=U5_CELULAR
@return	cRet
@author	CRM/Faturamento
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Function CRMXPicTel(cTipTel)

Local cRet			:= ""

Default cTipTel	:= '1'

Do Case
	Case cTipTel == '1'
		cRet := GetMaskTel("U5_FONE")
	Case cTipTel == '2'
		cRet := GetMaskTel("U5_FCOM1")
	Case cTipTel == '3'
		cRet := GetMaskTel("U5_FCOM2")
	Case cTipTel == '4'
		cRet := GetMaskTel("U5_FAX")
	Case cTipTel == '5'
		cRet := GetMaskTel("U5_CELULAR")
	Case cTipTel == '6'
		cRet := GetMaskTel("A3_TEL")
EndCase

cRet	:= cRet + "%C"
Return cRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} GetMaskTel
Função genérica avalia a quantidade de caracter do conteudo do campo (cCpo) e
define qual tipo de mascara deve ser aplicada.
@sample	GetMaskTel(cCpo)
@param	cCpo
@return	cRet
@author	CRM/Faturamento
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Static Function GetMaskTel(cCpo)

Local cContent	:= IIF(Type(cCpo) <> "U", &("M->" + (cCpo)),"")
Local cRet			:= AllTrim(SX3->(X3Picture(cCpo)))

IF cRet == Alltrim('@R 999999999999999')
	cRet	:= ''
EndIF

If Empty(cRet)
	cRet	:= "@R 9999-99999"
	If ! Empty(cContent) .AND. Len(Alltrim(cContent)) == 9
		cRet	:= "@R 99999-9999"
	EndIf
EndIf
Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc}CRMXGFSXB
Retorna se o fix do SXB foi carregado.
@sample 	CRMXGFSXB
@param		Nenhum
@Return   	Nenhum
@author	SQUAD FAT / CRM
@since		23/05/2017
@version	12.1.17
/*/
//------------------------------------------------------------------------------
Function CRMXGFSXB()

Local aAreaSXB	:= {}
Local nTamSXB 	:= 0

If !lCallGFSXB
	aAreaSXB := SXB->( GetArea() )
	SXB->( DBSetOrder( 1 ) )
	nTamSXB := Len(SXB->XB_ALIAS)
	If SXB->( DBSeek(PadR("SA1", nTamSXB)+'601  ') .And. (RTrim(SXB->XB_CONTEM) == 'CRMXFilSXB("SA1")') )
		lFixSXB := .F.
	Else
		lFixSXB := .T.
	EndIf
	lCallGFSXB := .T.
	RestArea( aAreaSXB )
EndIf

Return( lFixSXB )

//------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXGetJFields
Retorna uma lista de campos no formato JSON de uma determinada
tabela do SX2 ou de uma tabela temporaria com estrutura de campos.

@param		cAlias	    , caracter	, Alias da tabela
			cLanguage	, caracter	, Linguagem do nome do campo.
			aFields	    , array		, Lista de campos para retornar.
            lContent    , logico    , Traz o conteudo do campo na tag value do registro posicionado.
			lListDetail , logico    , Indica se objeto JSON será utilizado numa lista de um outro objeto.
@return	    cJFiedls 	, caracter  , Lista os campos no formato JSON as Tags {identifier, label, type, value}.

@author 	Squad CRM / FAT
@version	12.1.20 / Superior
@since		31/01/2018
/*/
//-------------------------------------------------------------------------------------------------------------------------
Function CRMXGetJFields(cAlias, cLanguage, aFields, lContent, lListDetail)

    Local aJFields      := {}
    Local aStruct       := {}
    Local jFields       := JsonObject():New()   
    Local jField        := Nil
    Local nI            := 0
    Local lAliasInDic   := .F.
    Local lFields       := .F.
    Local cJFiedls      := ""
    Local cOptions      := ""
	Local xValue

    Default cAlias      := ""
    Default cLanguage   := "pt"
    Default aFields     := {}
    Default lContent    := .F.
    Default lListDetail := .F.

    lFields := !Empty(aFields)

    If !Empty(cAlias)

        lAliasInDic := AliasInDic(cAlias)
        aStruct 	:= (cAlias)->(DBStruct())

        For nI := 1 To Len(aStruct)
            If (lFields .And. aScan(aFields, {|x| AllTrim(Upper(x)) == aStruct[nI][1]}) == 0)
                Loop
            EndIf

            jField := JsonObject():New()

            jField["identifier"] := aStruct[nI][1]
            jField["type"      ] := aStruct[nI][2]

            If lAliasInDic
                jField["label"] := CRMXGetTitle(aStruct[nI][1], cLanguage)
				cOptions 		:= CRMXGetBox(aStruct[nI][1], cLanguage)
				If !Empty(cOptions)
                	jField["options"] := AllTrim(cOptions)
           		EndIf
			EndIf

            If (lContent .And. (cAlias)->(!Eof()))
				xValue := (cAlias)->(FieldGet(FieldPos(aStruct[nI][1])))
				If aStruct[nI][2] = "C" .or. aStruct[nI][2] = "M"
	                jField["value"] := EncodeUTF8(RTrim(xValue))
				Else
	                jField["value"] := xValue
				Endif
            EndIf

            AAdd(aJFields, jField)
        Next nI
    EndIf

    If !lListDetail
	    jFields := JsonObject():New()
        jFields["fields"] := aJFields
        cJFiedls := FwJsonSerialize(jFields)
    Else
        cJFiedls := FwJsonSerialize(aJFields)
        cJFiedls := Substr(cJFiedls,2,Len(cJFiedls)-2)
    EndIf

Return cJFiedls

//------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXGetTitle
Retorna o nome do campo.

@param		cField	    , caracter	, Nome da campo no SX3
			cLanguage	, caracter	, Linguagem do nome do campo.

@return	    cTitle      , caracter  , Título do campo.

@author 	Squad CRM / FAT
@version	12.1.20 / Superior
@since		31/01/2018
/*/
//-------------------------------------------------------------------------------------------------------------------------
Static Function CRMXGetTitle(cField, cLanguage)
    Local cTitle    := ""
    Local cSX3Field := ""

    Default cField      := ""
    Default cLanguage   := "pt"

    cLanguage := Lower( cLanguage )

    Do Case
        Case cLanguage == "en"
            cSX3Field := "X3_TITENG"
        Case cLanguage == "es"
            cSX3Field := "X3_TITSPA"
        Otherwise
            cSX3Field := "X3_TITULO"
    EndCase

    If !Empty( cField )
        cTitle := GetSx3Cache( cField, cSX3Field )
    EndIf

Return EncodeUtf8( AllTrim( cTitle ) )

//------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMXGetBox
Retorna o conteudo do combobox.

@param		cField	    , caracter	, Nome da campo no SX3
			cLanguage	, caracter	, Linguagem do conteúdo do Combobox.

@return	    cOptBox     , caracter  , Conteúdo do Combobox.

@author 	Squad CRM / FAT
@version	12.1.20 / Superior
@since		31/01/2018
/*/
//-------------------------------------------------------------------------------------------------------------------------
Static Function CRMXGetBox(cField, cLanguage)
    Local cOptBox   := ""
    Local cSX3Field := ""

    Default cField      := ""
    Default cLanguage   := "pt"

    cLanguage := Lower( cLanguage )

    Do Case
        Case cLanguage == "en"
            cSX3Field := "X3_CBOXENG"
        Case cLanguage == "es"
            cSX3Field := "X3_CBOXSPA"
        Otherwise
            cSX3Field := "X3_CBOX"
    EndCase

    If !Empty( cField )
        cOptBox := GetSx3Cache( cField, cSX3Field )
    EndIf

Return EncodeUtf8( AllTrim( cOptBox ) )

//----------------------------------------------------------------------------
/*/{Protheus.doc} CRMMText
Prepara texto para Json mobile

@param		cString	    , caracter	, String a ser formatada
			lIsUpper	, Lógico	, Caixa alta.
			lIsTrim     , Lógico    , Retira espaços em branco.
@return	    cString     , caracter  , String formatada.

@author 	Renato da Cunha
@version	12.1.17
@since		27/03/2018
/*/
//----------------------------------------------------------------------------
Function CRMMText(cString, lIsUpper, lIsTrim)
	Default	cString	:= ''
	Default lIsUpper	:= .F.
	Default lIsTrim	:= .F.

	If !Empty(cString)
		cString := StrTran( cString,","," "   )
		cString := StrTran( cString,"."," "   )
		cString := StrTran( cString,'"',''    )
		cString := StrTran( cString,'\','\\'  )
	EndIf

	If lIsUpper
		cString := Upper(cString)
	EndIf

	If lIsTrim
		cString := Alltrim(cString)
	EndIf
Return FwNoAccent(cString)

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMXRtrnPos
Retorna o cargo do usuário com base no parametro MV_CRMESTR - que define se o cargo deverá ser 
buscado na SA3 ou na AO3.



@param cCodUser	, caracter	, codigo do usuario 
@param cSeqPaper	, caracter	, Sequencia + Papel ( Default: Considera o papel do usuario logado.)
 
@return cPosition		, caracter , Retorna o cargo do usuário CRM.

@author  Renato da Cunha 
@version P12
@since   15/04/2016  
/*/
//-------------------------------------------------------------------
Function CRMXRtrnPos ( cCodUser,cSeqPaper )

Local cPosition	:= ""									// Cargo
Local cSeller		:= ""									// Vendedor
Local cTpStruc	:= SuperGetMv("MV_CRMESTR",.F.,"1") //1-AO3 / 2-vendedor 

Local aAreaAZS	:= {}
Local aAreaSA3	:= {}

Local aSeqPaper	:= CRMXGetPaper()

Default cCodUser	:= CRMXCodUser()
Default cSeqPaper	:= Alltrim(aSeqPaper[2]+aSeqPaper[3])

   
If cTpStruc == "1" // Se o cargo é original do Usuário CRM, pega o valor da AO3

	aAreaSA3 := SA3->(GetArea())
	AO3->( DbSetOrder(1) ) //AO3_FILIAL+AO3_CODUSR
	
	If AO3->( MSSeek( xFilial("AO3") + cCodUser ) )	
		cPosition := AO3->AO3_CARGO
	EndIf
	RestArea( aAreaSA3 )

ElseIf cTpStruc == "2" // Se o cargo é original do Vendedor, pega o Vendedor do Papel
	
	aAreaAZS := AZS->(GetArea())
	aAreaSA3 := SA3->(GetArea())
	
	AZS->( DbSetOrder(1) ) //AZS_FILIAL + AZS_CODUSR + AZS_IDESTN
				
	If AZS->( MsSeek(xFilial("AZS") + cCodUser + cSeqPaper ) )
		cSeller := AZS->AZS_VEND
		
		SA3->( DbSetOrder(1) ) //A3_FILIAL+A3_COD
		
		If SA3->( DbSeek(xFilial("SA3")+cSeller) )		
			cPosition	:= SA3->A3_CARGO
		EndIf
	EndIf 
	
	RestArea( aAreaSA3 )
	RestArea( aAreaAZS )

EndIf

Return( cPosition )