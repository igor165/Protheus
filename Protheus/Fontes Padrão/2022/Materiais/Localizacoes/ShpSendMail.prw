#Include "Protheus.ch"
#Include "topconn.ch"
#INCLUDE "SHOPIFY.CH"
#INCLUDE "ShopifyExt.ch"

#define SMTP_DEFAULT_PORT		25
#define SMTP_TLS_PORT			587
#define SMTP_SSL_PORT			465
#define STMP_TIMEOUT			60

#Define HTML_ASCII				1
#Define HTML_ENTIDADE			2

#define ATTACHED_FILES_FOLDER	'\attached_files'

Static aHTML := {;
	{"Á",'&Aacute;'},;
	{"á",'&aacute;'},;
	{"Â",'&Acirc;'},;
	{"â",'&acirc;'},;
	{"À",'&Agrave;'},;
	{"à",'&agrave;'},;
	{"Ã",'&Atilde;'},;
	{"ã",'&atilde;'},;
	{"Ä",'&Auml;'},;
	{"ä",'&auml;'},;
	{"ï",'&iuml;'},;
	{"É",'&Eacute;'},;
	{"é",'&eacute;'},;
	{"Ê",'&Ecirc;'},;
	{"ê",'&ecirc;'},;
	{"È",'&Egrave;'},;
	{"è",'&egrave;'},;
	{"Ë",'&Euml;'},;
	{"ë",'&euml;'},;
	{"õ",'&otilde;'},;
	{"Í",'&Iacute;'},;
	{"í",'&iacute;'},;
	{"Î",'&Icirc;'},;
	{"î",'&icirc;'},;
	{"Ì",'&Igrave;'},;
	{"ì",'&igrave;'},;
	{"Ï",'&Iuml;'},;
	{"Ù",'&Ugrave;'},;
	{"ù",'&ugrave;'},;
	{"Ó",'&Oacute;'},;
	{"ó",'&oacute;'},;
	{"Ô",'&Ocirc;'},;
	{"ô",'&ocirc;'},;
	{"Ç",'&Ccedil;'},;
	{"Ò",'&Ograve;'},;
	{"ç",'&ccedil;'},;
	{"ò",'&ograve;'},;
	{"Ñ",'&Ntilde;'},;
	{"ñ",'&ntilde;'},;
	{"Õ",'&Otilde;'},;
	{"Ý",'&Yacute;'},;
	{"Ö",'&Ouml;'},;
	{"ý",'&yacute;'},;
	{"ö",'&ouml;'},;
	{"Ú",'&Uacute;'},;
	{"ú",'&uacute;'},;
	{"Û",'&Ucirc;'},;
	{"û",'&ucirc;'},;
	{"Ü",'&Uuml;'},;
	{"&",'&amp;'}}

//--------------------------------------------------------------------
/*/{Protheus.doc} ShpSendMail
Classe de envio e recebimento de e-mail

@author Renan Guedes Alexandre
@since 28/09/2018
@version 1
/*/
//--------------------------------------------------------------------
class ShpSendMail
	data error as string

	method new() constructor
	method send(cAccount, cTo, cCc, cBcc, cSubject, cBody, aAttach)
endclass


method new() class ShpSendMail
	::error := ''
return self


method send(cAccount, cTo, cCc, cBcc, cSubject, cBody, aAttach, lJob, cFrom) class ShpSendMail
	local aArea 		:= getArea()
	local cQuery 		:= ""
	local cAliasWF		:= ''
	local nSMTPSSL		:= 0
	local nAttach 		:= 0
	local xRet 		:= nil
	local oMail 		:= nil
	local oMessage		:= nil
	local cDrive 		:= ''
	local cDiretorio 	:= ''
	local cNome 		:= ''
	local cExtensao 	:= ''
	local lRet 		:= .F.
	local lTMailMng 	:= findFunction( 'findclass' ) .and. findclass( 'TMailMng' )		//função disponível em build superior a 7.00.131227A
	local cUser 		:= ''
	local cFile 		:= ''

	default cAccount 	:=  ShpGetPar("CONTAEMAIL","SHOPIFY",STR0091) //"Email account using on Shopify
	default cTo 		:= ''
	default cCc 		:= ''
	default cBcc 		:= ''
	default cSubject 	:= ''
	default cBody 		:= ''
	default cFrom		:= ''
	default aAttach 	:= {}
	default lJob		:= .F.

	BEGIN SEQUENCE

		if empty(cAccount)
			::error := STR0132 //'The account was not defined'
			BREAK
		endif

		if empty(cTo)
			::error := STR0133//'The recipient of the e-mail was not defined'
			BREAK
		endif

		if empty(cSubject)
			::error := STR0134//'The subject of the e-mail was not defined'
			BREAK
		endif

		if empty(cBody)
			::error := STR0135//'The body of the e-mail was not defined'
			BREAK
		endif

		//busca os dados da conta de e-mail na tabela de contas de workflow
		cQuery := "SELECT WF7.WF7_REMETE,"
		cQuery += "       WF7.WF7_ENDERE,"
		cQuery += "       WF7.WF7_TEMPO,"
		cQuery += "       WF7.WF7_SMTPSR,"
		cQuery += "       WF7.WF7_SMTPPR,"
		cQuery += "       WF7.WF7_SMTPSE,"
		cQuery += "       WF7.WF7_AUTUSU,"
		cQuery += "       WF7.WF7_AUTSEN"
		cQuery += "       ,WF7.WF7_CONTA" //ALTERADO BRUNO - 20181114
		cQuery += "  FROM " + retSqlName('WF7') + " WF7"
		cQuery += " WHERE WF7.D_E_L_E_T_ = ' '"
		cQuery += "   AND WF7.WF7_FILIAL = '" + xFilial("WF7") + "'"
		cQuery += "   AND WF7.WF7_PASTA = '" + upper(PADR(cAccount, tamSX3('WF7_PASTA')[1])) + "'"
		cQuery += "   AND WF7.WF7_ATIVO = 'T'"

		cQuery := ChangeQuery(cQuery)

		tcQuery cQuery new alias (cAliasWF := getNextAlias())

		//define os dados da conta de e-mail
		if (cAliasWF)->(eof())
			::error := STR0136 + cAccount + STR0137 // "The account [" // "] was not found"
			BREAK
		else
			//verifica qual protocolo e versão deve ser utilziado
			do case
			case upper(alltrim((cAliasWF)->WF7_SMTPSE)) == 'TLS'
				nSMTPSSL := 6
			case upper(alltrim((cAliasWF)->WF7_SMTPSE)) == 'SSL'
				nSMTPSSL := 3
			endcase

			cUser := if(!empty(alltrim((cAliasWF)->WF7_AUTUSU)), alltrim((cAliasWF)->WF7_AUTUSU), alltrim((cAliasWF)->WF7_ENDERE))

			//instancia a classe de conexão com o servidor de e-mail
			if lTMailMng
				oMail := TMailMng():New(1,, nSMTPSSL)
				oMail:lSMTPRetrySSL := .T.
				oMail:cSMTPAddr := alltrim((cAliasWF)->WF7_SMTPSR)
				oMail:cUser := cUser
				oMail:cPass := alltrim((cAliasWF)->WF7_AUTSEN)
				//oMail:lAuthLogin := !empty(alltrim((cAliasWF)->WF7_AUTUSU)) .and. !empty(alltrim((cAliasWF)->WF7_AUTSEN))
				oMail:nSMTPPort := (cAliasWF)->WF7_SMTPPR
				
				oMail:nSMTPTimeout := (cAliasWF)->WF7_TEMPO
				xRet := oMail:SMTPConnect()
				if empty(xRet)
					xRet := oMail:SMTPAuth( oMail:cUser, oMail:cPass )
				endif

				if !empty(xRet)
					::error := oMail:GetErrorString( xRet )
					BREAK
				endif
			else
				oMail := TMailManager():New()
				//ALTERADO 20181120 - BRUNO 
				//coloquei o IF abaixo, porque no campo cAliasWF)->WF7_SMTPSE conseguimos colocar
				//ou TLS ou SSL, e nao os dois, e para o gmail, precisamos das duas validacoes. 
				if allTrim((cAliasWF)->WF7_SMTPSR) == 'smtp.gmail.com'
					oMail:SetUseTLS(.T.)
					oMail:SetUseSSL(.T.)
				else
					oMail:SetUseTLS(upper(alltrim((cAliasWF)->WF7_SMTPSE)) == 'TLS')
					oMail:SetUseSSL(upper(alltrim((cAliasWF)->WF7_SMTPSE)) == 'SSL')
				endIf
				oMail:init('', alltrim((cAliasWF)->WF7_SMTPSR), cUser, alltrim((cAliasWF)->WF7_AUTSEN),, (cAliasWF)->WF7_SMTPPR)
				
				xRet := oMail:SetSMTPTimeout((cAliasWF)->WF7_TEMPO)
				if !empty(xRet)
					::error := oMail:GetErrorString( xRet )
					BREAK
				endif
				
				xRet := oMail:SmtpConnect()
				if !empty(xRet)
					::error := oMail:GetErrorString( xRet )
					BREAK
				endif

				if !empty(alltrim((cAliasWF)->WF7_AUTUSU)) .and. !empty(alltrim((cAliasWF)->WF7_AUTSEN))
					xRet := oMail:SmtpAuth( alltrim((cAliasWF)->WF7_AUTUSU), alltrim((cAliasWF)->WF7_AUTSEN) )
					if !empty(xRet)
						::error := oMail:GetErrorString( xRet )
						BREAK
					endif
				endif
			endif
		endif
		
		//se nao tiver destinatário, pegamos o destinatário da WF7.
		if empty(allTrim(cFrom))
			cFrom := alltrim((cAliasWF)->WF7_CONTA)
		endIf
		
		//instancia a classe de mensagem de e-mail
		oMessage := TMailMessage():New()
		oMessage:cTo := cTo
		oMessage:cFrom := cFrom
		if !empty(cCc)
			oMessage:cCc := cCc
		endif
		if !empty(cBcc)
			oMessage:cBcc := cBcc
		endif
		oMessage:cDate := dtoc(date())
		oMessage:cSubject := cSubject
		oMessage:cBody := ASCToHTML(cBody)
		//oMessage:cBody := cBody



		if len(aAttach) > 0
			if attachFolder()
				for nAttach := 1 to len(aAttach)
					cFile := aAttach[nAttach]
					
					if file(cFile)
						SplitPath(cFile, @cDrive, @cDiretorio, @cNome, @cExtensao)
						cNome += cExtensao

						if !empty(cDrive)
							if !cpyT2S(cFile, ATTACHED_FILES_FOLDER, .T., .F.)
								::error += STR0138 + cFile + STR0139 + CRLF + FError() + CRLF //'It was not possible to copy the file ['//'] to the server'
								BREAK
							endif

							cFile := ATTACHED_FILES_FOLDER + '\' + cNome
						endif
						
						xRet := oMessage:AttachFile(cFile)
						If xRet >= 0
							oMessage:AddAtthTag('Content-Disposition: attachment; filename="' + cNome + '"')
						else
							::error += STR0140 + aAttach[nAttach] + CRLF //'It was not possible to attach the file: '
							BREAK
						endif
					else
						::error += STR0141 + cFile + STR0137 // 'The file [' // '] was not found'
						BREAK
					endif
				next nAttach
			else
				::error += STR0142//'It was not possible to copy the attached file(s) to the server'
				BREAK
			endif
		endif

		if lTMailMng
			if !(oMail:lSMTPConnected)
				::error += STR0143//'The connection to the SMTP server has broken'
				BREAK
			endif
		endif

		//envia o e-mail
		if lTMailMng
			xRet := oMessage:Send2(oMail)
		else
			xRet := oMessage:Send(oMail)
		endif
		if !empty(xRet)
			::error := oMail:GetErrorString( xRet )
			BREAK
		endif

		xRet := oMail:SMTPDisconnect()

		lRet := .T.

	END SEQUENCE

	//fecha a tabela temporária, caso tenha sido usada
	if !empty(cAliasWF)
		if select(cAliasWF) > 0
			(cAliasWF)->(dbCloseArea())
		endif
	endif
	
	if(!empty(allTrim(::error)))
		conout("BLCOM002 - " + STR0144 + allTrim(::error)) //Error to send mail - "
	endIf

	
	restArea(aArea)

return lRet


static function ASCToHTML(cString)
	Local nHTML := 0

	Default cString := ""
	
	BEGIN SEQUENCE
	
		If ValType(cString) != "C"
			BREAK
		EndIf
		
		For nHTML := 1 To Len(aHTML)
			cString := StrTran(cString, aHTML[nHTML, HTML_ASCII], aHTML[nHTML, HTML_ENTIDADE])
		Next nHTML

	END SEQUENCE

Return cString


static function attachFolder()
	local lRet := .F.

	BEGIN SEQUENCE

		if !existDir(ATTACHED_FILES_FOLDER)
			if !makeDir(ATTACHED_FILES_FOLDER)
				BREAK
			endif
		endif

		lRet := .T.

	END SEQUENCE

return lRet
