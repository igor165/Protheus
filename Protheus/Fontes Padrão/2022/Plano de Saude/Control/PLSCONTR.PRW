#INCLUDE "PLSCONTR.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AP5MAIL.CH"  
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCONTR
Metodos genericos da aplicacao

@author Alexander Santos
@since 16/02/2011
@version P11
/*/

//-------------------------------------------------------------------

CLASS PLSCONTR      

DATA cErro AS STRING

METHOD SetLog()

METHOD New() Constructor
METHOD GetReceitaUsu()
METHOD GetCustoUsu()
METHOD GetVal(aDad,cVariavel,lRetArray) 
METHOD SendEmail(cFrom,cTo,cCC,cBCC,cSubject,cBody)
METHOD ExbMHelp( cMsg, cRotina, lRot )
METHOD RetConCP( cAlias,cCampo )
METHOD Split(cDelimit, cString)
METHOD Destroy()

EndClass     

/*/{Protheus.doc} New
Construtor da Class

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
METHOD New() Class PLSCONTR
Return Self                
//-------------------------------------------------------------------
/*/ { Protheus.doc } SetLog
Seta conteudo LOG

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetLog(nHoraBase,lConsole) Class PLSCONTR
LOCAL lLog 		 := GetNewPar("MV_PLSSLOG","0")=="1"
DEFAULT lConsole := .T.
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� LOG																		
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If lLog      
	cLog := OemToAnsi(STR0001+FunName()+STR0002+AllTrim(PadR(AllTrim(ProcName(1)),12))+STR0003 + AllTrim( Str( Seconds()-nHoraBase,12,3 ) )+STR0004) //"Fonte: ["###"] Funcao: ["###"] Dura豫o: ["###"] segundos"
	If lConsole
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', cLog , 0, 0, {})
	Else	
		PLSLOGFIL(cLog,__PLSFLOGX)
	EndIf	
EndIf	
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Fim do metodo
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return              
//-------------------------------------------------------------------
/*/ { Protheus.doc } GetReceitaUsu
Retorna receita de um usuario 

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetReceitaUsu(cTipo,cCodOpe,cCodEmp,cNumCon,cVerCon,cSubCon,cVerSub,cMatric,cTipReg,cAnoIni,cMesIni,cAnoFin,cMesFin,nTpRec) Class PLSCONTR

LOCAL nValRec := PLSRECCALC(cTipo,cCodOpe,cCodEmp,cNumCon,cVerCon,cSubCon,cVerSub,cMatric,cTipReg,cAnoIni,cMesIni,cAnoFin,cMesFin,nTpRec)[1]
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Fim do metodo
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return(nValRec)
//-------------------------------------------------------------------
/*/ { Protheus.doc } GetCustoUsu
Retorna custo do usuario 

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetCustoUsu(cTipo,cCodOpe,cCodEmp,cNumCon,cVerCon,cSubCon,cVerSub,cMatric,cTipReg,cAnoIni,cMesIni,cAnoFin,cMesFin,lDialogo) Class PLSCONTR

LOCAL nValCus := PLSCUSTMOV(cTipo,cCodOpe,cCodEmp,cNumCon,cVerCon,cSubCon,cVerSub,cMatric,cTipReg,cAnoIni,cMesIni,cAnoFin,cMesFin,.F.)[1]
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Fim do metodo
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return(nValCus)
//-------------------------------------------------------------------
/*/ { Protheus.doc } GetVal
Retorna valor de uma variavel ou matriz

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
METHOD GetVal(aDad,cVariavel,lRetArray) Class PLSCONTR
LOCAL nI	 		:= 0
LOCAL nPos	 		:= 0
LOCAL xRet 			:= Iif(lRetArray,{},NIL)
DEFAULT cVariavel	:= ""
DEFAULT lRetArray 	:= .F.
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Retorna o conteudo da variavel											 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If !lRetArray
	If ( nPos := Ascan(aDad,{|x| x[1] == cVariavel } ) ) == 0
		xRet := aDad[nPos,2]
	EndIf	
Else               
	For nI:= 1 To Len(aDad)
		AaDd(xRet,aDad[nI,2])
	Next 
EndIf	
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Fim da Rotina															 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Return(xRet)
//-------------------------------------------------------------------
/*/ { Protheus.doc } SendEMail
Envia email

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SendEmail(cFrom,cTo,cCC,cBCC,cSubject,cBody) Class PLSCONTR
LOCAL oServer   	:= NIL
LOCAL oMessage  	:= NIL
LOCAL nErr      	:= 0
LOCAL nSMTPPort 	:= GetNewPar("MV_PORSMTP",25)
LOCAL cSMTPAddr 	:= GetNewPar("MV_RELSERV","")
LOCAL cUser     	:= GetNewPar("MV_RELAUSR","")
LOCAL cPass     	:= GetNewPar("MV_RELAPSW","")
LOCAL lAutentica	:= GetNewPar("MV_RELAUTH",.F.)
LOCAL nSMTPTime 	:= GetNewPar("MV_RELTIME",60)
LOCAL lSSL 			:= GetNewPar("MV_RELSSL",.F.)
LOCAL lTLS 			:= GetNewPar("MV_RELTLS",.F.)
DEFAULT cCC 		:= ""
DEFAULT cBCC 		:= ""
DEFAULT cFrom 		:= GetNewPar("MV_RELFROM","")
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿣erifica se e para autenticar e pega so o nome do usuario
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
If lAutentica .And. At("@",cUser)>0
	cUser := Subs(cUser,1,At("@",cUser)-1)
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿚bj de Mail
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oServer := tMailManager():New()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿢sa SSL, TLS ou nenhum na inicializacao
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
If lSSL
	oServer:SetUseSSL(lSSL)
	nErr := oServer:init("",cSMTPAddr,cUser,cPass,,nSMTPPort)
ElseIf lTLS
	oServer:SetUseTLS(lTLS)
	nErr := oServer:init("",cSMTPAddr,cUser,cPass,,nSMTPPort)
Else
	nErr := oServer:init("",cSMTPAddr,cUser,cPass,,nSMTPPort)
Endif

If nErr <> 0
	::cErro := STR0006 + oServer:getErrorString(nErr) //"Falha ao conectar: "
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', 'Iniciando: '+ oServer:getErrorString(nErr) , 0, 0, {})
	
	Return .F.
Endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿏efine o Timeout SMTP
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
If oServer:SetSMTPTimeout(nSMTPTime) != 0

	::cErro := "Falha ao definir timeout"

	Return .F.
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿎onecta ao servidor
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
nErr := oServer:smtpConnect()
If nErr <> 0
	::cErro := STR0006 + oServer:getErrorString(nErr) //"Falha ao conectar: "
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', 'Conectando: '+ oServer:getErrorString(nErr) , 0, 0, {})
	
	oServer:SMTPDisconnect()
	Return .F.
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿝ealiza autenticacao no servidor
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
If lAutentica
	nErr := oServer:smtpAuth(cUser, cPass)
	If nErr <> 0
		::cErro := STR0007 + oServer:getErrorString(nErr) //"Falha ao autenticar: "
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', 'Autenticando: '+ oServer:getErrorString(nErr) , 0, 0, {})
		oServer:SMTPDisconnect()
		Return .F.
	EndIf
EndIf	
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿎ria uma nova mensagem (TMailMessage)
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oMessage := tMailMessage():new()
oMessage:clear()        
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿏ados da mensagem
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oMessage:cFrom	:= cFrom
oMessage:cTo      	:= cTo
oMessage:cCC      	:= cCC
oMessage:cBCC    	:= cBCC
oMessage:cSubject	:= cSubject
oMessage:cBody    := cBody
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿐nvia a mensagem
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
nErr := oMessage:send(oServer)
If nErr <> 0
	::cErro := STR0008 + oServer:getErrorString(nErr) //"Falha ao enviar: "
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', 'Enviando: '+ oServer:getErrorString(nErr) , 0, 0, {})
	
	oServer:SMTPDisconnect()
	Return .F.
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿏isconecta do Servidor
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oServer:smtpDisconnect()

::cErro := "E-mail enviado com sucesso"
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿑im do Metodo
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Return(.T.)
//-------------------------------------------------------------------
/*/ { Protheus.doc } ExbMHelp
Exibe mensagem no formado help

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD ExbMHelp( cMsg, cRotina, lRot , cSoluc) Class PLSCONTR
LOCAL nI		:= 0    
LOCAL lAut		:= .F.
LOCAL cPart1 	:= ""
LOCAL cPart2 	:= ""
LOCAL cPart3 	:= ""
LOCAL cMenAux	:= ""
DEFAULT cSoluc 	:= STR0009 //"Verifique a opera豫o executada"
DEFAULT cMsg 	:= STR0010 //"Erro ..."
DEFAULT cRotina := ProcName(1)  
DEFAULT lRot	:= .F.                                           
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Se a mensagem tiver mais que 40 caracteres
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
If Len(cMsg) > 40
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	//� Separa paravras
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	aRet := ::Split(" ", cMsg)
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	//� Monta string de 40 caracteres
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	
	For nI:= 1 To Len(aRet)
	
		lAut := .F.
		If Len(cMenAux+aRet[nI]) <= 40
		    cMenAux += aRet[nI] + " "
		    lAut := .T.
		EndIf    
	
	    If !lAut
			If Empty(cPart1)
				cPart1 := cMenAux
		 	ElseIf Empty(cPart2)
				cPart2 := cMenAux
		 	ElseIf Empty(cPart3)
				cPart3 := cMenAux
		 	EndIf
		 	cMenAux := aRet[nI] + " "
		EndIf

		If nI >= Len(aRet)
			If Empty(cPart1)
				cPart1 := cMenAux
		 	ElseIf Empty(cPart2)
				cPart2 := cMenAux
		 	ElseIf Empty(cPart3)
				cPart3 := cMenAux
		 	EndIf
		EndIf
	Next    
Else   
	cPart1 := cMsg
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Help generico
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CheckHLP("PEXBMHELP",{cPart1,cPart2,cPart3},{cPart1,cPart2,cPart3},{cPart1,cPart2,cPart3},.T.)
CheckHLP("SEXBMHELP",{cSoluc,Iif(lRot,"Rotina: " + cRotina,"") },{},{},.T.)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Exibe mensagem															 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Help(" ",1,'EXBMHELP')
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Fim da Rotina															 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Return .F.
//-------------------------------------------------------------------
/*/ { Protheus.doc } RetConCP
Retornar o conteudo do campo referente ao alias informado

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD RetConCP( cAlias,cCampo,cTpVld ) Class PLSCONTR
LOCAL xConteudo                
DEFAULT cTpVld := 'C'
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Ajusta nome campo
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
cCampo := StrTran(cCampo,"_","") 
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Retorna o campo referente ao alias
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
If (cAlias)->( FieldPos(cAlias + "_" + cCampo) ) > 0 
	xConteudo := (cAlias)->&(cAlias + "_" + cCampo)
Else            
	If Upper(cTpVld) == 'C'
		xConteudo := ''
	ElseIf Upper(cTpVld) == 'N'
		xConteudo := 0
	ElseIf Upper(cTpVld) == 'D'
		xConteudo := CToD("")
	EndIf
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	//� Conout
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0011+cAlias + "_" + cCampo+STR0012 , 0, 0, {}) //"Verifique o campo ["###"] metodo RetConCP"
EndIf	
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Fim da Rotina															 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Return(xConteudo)
//-------------------------------------------------------------------
/*/ { Protheus.doc } Split
Tranforma uma string em array informando o delimitador

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Split(cDelimit, cString) Class PLSCONTR
LOCAL nPos := 0
LOCAL aRet := {}

cString := AllTrim(cString) + cDelimit

While ( nPos := At( cDelimit, cString ) ) > 0
    AaDd( aRet,AllTrim(StrTran(SubStr( cString, 1, nPos-1 ),"'","") ) )
    cString := SubStr( cString, nPos+1, Len(cString) )
EndDo       
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Fim da Funcao															 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Return(aRet)
//-------------------------------------------------------------------
/*/ { Protheus.doc } Destroy
Libera da memoria o obj (Destroy)

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Destroy() Class PLSCONTR
FreeObj(Self:self)
Return
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽굇
굇쿑uncao    쿛LSCONTR  � Autor � Totvs				    � Data � 30/03/10 낢굇
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙굇
굇쿏escricao � Somente para compilar a class							  낢굇
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
/*/
Function PLSCONTR
Return
