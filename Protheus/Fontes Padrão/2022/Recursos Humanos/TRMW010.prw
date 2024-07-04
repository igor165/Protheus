#include 'protheus.ch'
//#include 'parmtype.ch'
#INCLUDE 'TRMW010.ch'


/*/{Protheus.doc} TRMW010
WorkFlow de vencimento de cursos
@author Cícero Alves	
@since 21/10/2015
@version P12.1.8
@See Documentação sobre schedule: 
http://tdn.totvs.com.br/display/framework/Schedule+Protheus
/*/
Function TRMW010()

	Local cWFAlias := GetNextAlias()
	Local cDataAte := "%RA4_VALIDA <= " + "'" + DtoS(dDataBase + Val(SuperGetMV("MV_DIASVEN",,"30"))) + "'%" 
	Local cCargo   := OemToAnsi( STR0002 ) //Cargo
	Local cFuncao  := OemToAnsi( STR0003 ) //Função
	Local aJoins   := {}
	Local cTitulo  := OemToAnsi( STR0001 ) // Workflow de Vencimento de Cursos 
	Local cHtml    := ""
	Local cAuxNome := ""
	Local aDados   := {}
	Local _aArea   := {}
	Local aDeptos  := {}
	Local aDestinos:= {}
	Local aAlldes  := {}
	Local _cFil    := ""
	Local nI	   := 0
	Local nJ	   := 0
	Local nK	   := 0
	Local nDiasVenc:= 0
	Local cStatus  := ""
	Local cDestino := ""
	
	//Parametro usados para envio dos e-mails
	Local lMailAuth   := SuperGetMV("MV_RHAUTEN",,.F.) 			// Define se o servidor de e-mail requer autenticação.
	Local cEmailDe	  := Upper(Alltrim(GetMv("MV_EMAILDE"))) 	// E-mail default
	Local cMailServer := SuperGetMV("MV_RHSERV",,"") 			// Servidor para envio dos E-mails
	Local cMailConta  := SuperGetMV("MV_RHCONTA",,"") 			// Conta para envio dos E-mails
	Local cMailSenha  := SuperGetMV("MV_RHSENHA",,"") 			// Senha para envio 
	Local lUseSSL	  := SuperGetMV("MV_RELSSL" ,,.F.) 			// Define se será utilizada conexão segura (SSL).
	Local lUseTLS	  := SuperGetMV("MV_RELTLS" ,,.F.) 			// Define se o servidor tem conexão do tipo SSL / TLS.
	Local cQtdNiv 	  := GetMv("MV_QTDENIV") 					// Nivel maximo da hierarquia 
	Local nDias		  := Val(SuperGetMv("MV_DIASNIV"))			// Numero de dias para subir a hierarquia	
	Local nDiasNiv	  := Val(GetMv("MV_DIASNIV")) 				// Número de dias antes do vencimento do curso que o E-mail é enviado
	Local cVision	  := SuperGetMv("MV_APDVIS") 				// visão utilizada
	Local cTypeOrg	  := SuperGetMV("MV_ORGCFG",,"0") 			// Configuração do modo de uso do SIGAORG.
	Local nRecno      := 0
	
	_aArea   := GetArea()
	_cFil    := FWCodFil()
	
	If cTypeOrg == "0"
		aDeptos := fEstrutDepto( _cFil )
	EndIf
	
	If Empty( cEmailDe )
		AutoGrLog( OemToAnsi( STR0017 ) )
	EndIf 
	
	aAdd(aJoins,'%'+ FWJoinFilial('CTT', 'SRA') +'%') //1
	aAdd(aJoins,'%'+ FWJoinFilial('RA4', 'SRA') +'%') //2
	aAdd(aJoins,'%'+ FWJoinFilial('RA1', 'RA4') +'%') //3
	aAdd(aJoins,'%'+ FWJoinFilial('RA2', 'RA4') +'%') //4
	aAdd(aJoins,'%'+ FWJoinFilial('RA3', 'RA2') +'%') //5
	aAdd(aJoins,'%'+ FWJoinFilial('RA5', 'SRA') +'%') //6
	aAdd(aJoins,'%'+ FWJoinFilial('RAL', 'SRA') +'%') //7
	
	aAdd(aJoins,'%'+ FWJoinFilial('SQ3', 'SRA') +'%') //8
	aAdd(aJoins,'%'+ FWJoinFilial('SRJ', 'SRA') +'%') //9	
	
	BeginSql alias cWFAlias	
		
		Column RA4_VALIDA As Date
				
		SELECT RA_FILIAL, RA_CC, CTT_DESC01, RA_DEPTO, RA_MAT, RA_NOME, RA4_CURSO, RA1_DESC, RA2_DATAIN, RA2_DATAFI, RA3_RESERV, %exp:cCargo% as ORIGEM, RA1_CJETAP, 
		MAX(RA4_VALIDA) AS RA4_VALIDA			 		
		FROM %table:SRA% SRA
		LEFT  JOIN %table:CTT% CTT ON (%exp:aJoins[1]% AND CTT_CUSTO = RA_CC     AND CTT.%notDel%)			
		INNER JOIN %table:RA4% RA4 ON (%exp:aJoins[2]% AND RA4_MAT 	 = RA_MAT    AND RA4.RA4_VALIDA != '' AND RA4.%notDel% )
		INNER JOIN %table:RA1% RA1 ON (%exp:aJoins[3]% AND RA1_CURSO = RA4_CURSO AND RA1.%notDel%)		
		LEFT  JOIN %table:RA2% RA2 ON (%exp:aJoins[4]% AND RA2_CURSO = RA4_CURSO AND RA2.%notDel% AND RA2_REALIZ IN('','N') AND RA2_DATAIN >= %exp: DToS(dDataBase)%)			
		LEFT  JOIN %table:RA3% RA3 ON (%exp:aJoins[5]% AND RA3_MAT   = RA_MAT AND RA3_CURSO = RA4_CURSO AND RA3.%notDel%
		AND RA3_CALEND = RA2_CALEND AND RA3_TURMA = RA2_TURMA AND RA3_CURSO = RA2_CURSO)					
		INNER JOIN %table:RA5% RA5 ON (%exp:aJoins[6]% AND RA5_CARGO = RA_CARGO  AND RA5_CURSO = RA4_CURSO AND RA5.%notDel%)			
		INNER JOIN %table:SQ3% SQ3 ON (%exp:aJoins[8]% AND Q3_CARGO  = RA_CARGO  AND SQ3.%notDel%)
		
		WHERE SRA.%notDel%  
		AND (RA_SITFOLH IN(' ','A','F','T')) AND %exp:cDataAte%
		 
		GROUP BY RA_FILIAL, RA_CC, CTT_DESC01, RA_MAT, RA_NOME, RA_DEPTO, RA4_CURSO, RA1_DESC, RA2_DATAIN, RA2_DATAFI, RA3_RESERV, RA1_CJETAP
		
		UNION
		
		SELECT RA_FILIAL, RA_CC, CTT_DESC01, RA_DEPTO, RA_MAT, RA_NOME, RA4_CURSO, RA1_DESC, RA2_DATAIN, RA2_DATAFI, RA3_RESERV, %exp:cFuncao% as ORIGEM, RA1_CJETAP, 
		MAX(RA4_VALIDA) AS RA4_VALIDA			 		
		FROM %table:SRA% SRA
		LEFT  JOIN %table:CTT% CTT ON (%exp:aJoins[1]% AND CTT_CUSTO = RA_CC  AND CTT.%notDel%)			
		INNER JOIN %table:RA4% RA4 ON (%exp:aJoins[2]% AND RA4_MAT   = RA_MAT AND RA4.RA4_VALIDA != '' AND RA4.%notDel%)
		INNER JOIN %table:RA1% RA1 ON (%exp:aJoins[3]% AND RA1_CURSO = RA4_CURSO  AND RA1.%notDel%)
		LEFT  JOIN %table:RA2% RA2 ON (%exp:aJoins[4]% AND RA2_CURSO = RA4_CURSO  AND RA2.%notDel% AND RA2_REALIZ IN('','N') AND RA2_DATAIN >= %exp: DToS(dDataBase)%)			
		LEFT  JOIN %table:RA3% RA3 ON (%exp:aJoins[5]% AND RA3_MAT   = RA_MAT AND RA3_CURSO = RA4_CURSO AND RA3.%notDel%
		AND RA3_CALEND = RA2_CALEND AND RA3_TURMA = RA2_TURMA AND RA3_CURSO = RA2_CURSO)	
					
		INNER JOIN %table:RAL% RAL ON (%exp:aJoins[7]% AND RAL_FUNCAO = RA_CODFUNC AND RAL_CURSO = RA4_CURSO AND RAL.%notDel%)		
		INNER JOIN %table:SRJ% SRJ ON (%exp:aJoins[9]% AND RJ_FUNCAO  = RA_CODFUNC AND SRJ.%notDel%)
		
		WHERE SRA.%notDel%
		AND (RA_SITFOLH IN(' ','A','F','T')) 
		AND %exp:cDataAte%
				
		GROUP BY RA_FILIAL, RA_CC, CTT_DESC01, RA_MAT, RA_NOME, RA_DEPTO, RA4_CURSO, RA1_DESC, RA2_DATAIN, RA2_DATAFI, RA3_RESERV, RA1_CJETAP
		
		ORDER BY RA_FILIAL, RA4_CURSO, RA4_VALIDA
	EndSql
	
	(cWFAlias)->(dbGoTop())
	
	While( ! (cWFAlias)->( EOF() ) )
		nRecno := 0
		aDestinos 	:= {}
		cStatus 	:= ""
		nDiasVenc 	:= Val(dToS((cWFAlias)->RA4_VALIDA)) - Val(dToS(dDataBase))
		
		If Empty(cQtdNiv) .OR. cQtdNiv == "0"
			aAdd( aDestinos, cEmailDe )
		Else
			
			For nI := 1 To Val(cQtdNiv)
				If nI == 1
					aSuperior := fBuscaSuperior((cWFAlias)->RA_FILIAL, (cWFAlias)->RA_MAT, (cWFAlias)->RA_DEPTO, aDeptos, cTypeOrg, cVision)
				ElseIf nDiasVenc <= 0 .OR. nDiasVenc <= (nDiasNiv - nDias)
					nDiasNiv  := (nDiasNiv - nDias)
					aSuperior := fBuscaSuperior(SRA->RA_FILIAL, SRA->RA_MAT, SRA->RA_DEPTO, aDeptos, cTypeOrg, cVision)
				EndIf
				If Len(aSuperior) > 0 .AND. aSuperior[1][4] != 99
				
					If ! Empty(Posicione("SRA",1,aSuperior[1][1]+aSuperior[1][2],"RA_EMAIL"))
						
						If aScan(aDestinos, {|x| x[1] == AllTrim(SRA->RA_EMAIL)} ) == 0
							aAdd( aDestinos, {AllTrim(SRA->RA_EMAIL), AllTrim(SRA->RA_NOME)})
						EndIf
					Else
						If aScan(aDestinos, {|x| x[1] == cEmailDe} ) == 0
							aAdd( aDestinos, {cEmailDe, "" })
						EndIf
					EndIf
				
				Else
					If aScan(aDestinos, {|x| x[1] == cEmailDe} ) == 0
						aAdd( aDestinos, {cEmailDe, "" })
					EndIf
					cAuxNome := ""
				EndIf
				
			Next
			
		EndIf
		
		If (cWFAlias)->RA3_RESERV == "R"
			cStatus := OemToAnsi( STR0004 ) // Reservado
		ElseIf (cWFAlias)->RA3_RESERV == "S"
			cStatus := OemToAnsi( STR0005 )  // Solicitado
		ElseIf (cWFAlias)->RA3_RESERV == "L"		
			cStatus := OemToAnsi( STR0006 ) // Lista de espera
		Else
			cStatus := OemToAnsi( STR0007 ) // não matriculado
		EndIf
		
		aSort( aDestinos, , , {|x, y| x < y } )
		
		For nI := 1 To Len(aDestinos)
		 	If aScan(aAlldes, {|x| x[1] == aDestinos[nI][1]} ) == 0
		 		aAdd(aAlldes, {aDestinos[nI][1], aDestinos[nI][2]})
			EndIf
		Next
		
	aAdd( aDados, { cAuxNome, aDestinos, (cWFAlias)->RA_NOME, (cWFAlias)->RA4_CURSO+" - "+(cWFAlias)->RA1_DESC, Dtoc((cWFAlias)->RA4_VALIDA), (cWFAlias)->ORIGEM, cStatus } )
	
	//checklist reciclagem
	If !Empty((cWFAlias)->RA1_CJETAP)
		nRecno := GetChkList((cWFAlias)->RA_FILIAL,(cWFAlias)->RA_MAT,(cWFAlias)->RA1_CJETAP,"1",(cWFAlias)->RA4_CURSO )
		If nRecno > 0
			UpdEtapa(nRecno,,.T.)
		EndIf
	EndIf
	
	(cWFAlias)->(dbSkip())
	
	EndDo
	
	(cWFAlias)->(dbCloseArea())
	
	aSort( aDados, , , {|x, y| x[2][1][1] + x[4] < y[2][1][1] + y[4] } )
	
	cDestino := ""
	
	cDataAte := dDataBase + Val(SuperGetMV("MV_DIASVEN",,"30")) 
	
	For nI := 1 To Len(aAlldes)
		
		cHtml := "<html>"
		cHtml += "	<p></p>"
		cHtml += OemToAnsi( STR0014 ) + aAlldes[nI][2] + "," // Prezado(a) 
		cHtml += "	<br/>"
		cHtml += "	<p></p>"
		cHtml += OemToAnsi( STR0008 ) + dTOc(cDataAte)
		cHtml += "	<p></p>"
		cHtml += "	<br/>"
		cHtml += "	<table border= '1' >"
		cHtml += "		<tr>"
		cHtml += "			<td><b>" + OemToAnsi( STR0009 ) + "</b></td>" //	Nome 
		cHtml += "			<td><b>" + OemToAnsi( STR0010 ) + "</b></td>" //	Curso	
		cHtml += "			<td><b>" + OemToAnsi( STR0011 ) + "</b></td>" //	Vencimento em: 
		cHtml += "			<td><b>" + OemToAnsi( STR0012 ) + "</b></td>" //	Necessidade
		cHtml += "			<td><b>" + OemToAnsi( STR0013 ) + "</b></td>" //	Status
		cHtml += "		</tr>"
		
		For nJ := 1 To Len(aDados)
			nK := aScan(aDados[nJ][2], {|x| x[1] == aAlldes[nI][1]} )
			If nK > 0
				cHtml += "<tr><td>" + aDados[nJ][3] + "</td><td>" + aDados[nJ][4] + "</td><td>" + aDados[nJ][5] + "</td><td>" + aDados[nJ][6] + "</td><td>" + aDados[nJ][7] + "</td></tr>"
			Else 
				Loop
			EndIf
		Next 
		cHtml += "	</table>"
		cHtml += "	<p></p>"
		cHtml += "	<br/>"
		cHtml += "</html>"
		If ! RHSendMail(cTitulo,cHtml,aAlldes[nI][1], lMailAuth, cMailServer, cMailConta, cMailSenha, lUseSSL, lUseTLS)
			AutoGrLog( OemToAnsi( STR0016 ) )
		EndIf
	Next
	
	RestArea(_aArea)
Return



/*/{Protheus.doc} RHSendMail
Função para envio de E-mail
@author Cícero Alves
@since 22/10/2015
@version P12
@Param cSubject, Caractere, Assunto do E-mail.
@Param cMensagem, Caractere, Mensagem a ser enviada.
@Param cEMail, Caractere, E-mail de destino. 
@Param lMailAuth, Lógico, Determina se o servidor de e-mail requer autenticação.
@Param cMailServer, Caractere, Servidor de e-mail para envio de mensagens. 
@Param cMailConta, caractere, Conta de e-mail para envio de mensagens.
@Param cMailSenha, caractere, Senha de e-mail para envio de mensagens. 
@Param lUseSSL, Lógico, Define se o envio e recebimento de e-mails utilizará conexão segura (SSL).
@Param lUseTLS, Lógico, Informe se o servidor de SMTP possui conexão do tipo segura ( SSL/TLS ).   
@example
RHSendMail("Teste Envio E-Mail","Estamos testando o envio de E-mails com a função SendMail","email@totvs.com.br", .F., "smtp.microsiga.com.br", "email@totvs.com.br", "senha", .F., .F.)
@See Documentação sobre o TMailManager: http://tdn.totvs.com/x/moJXBQ
/*/
Function RHSendMail(cSubject,cMensagem,cEMail, lMailAuth, cMailServer, cMailConta, cMailSenha, lUseSSL, lUseTLS)

Local lEnvioOK 		:= .F.	// Variavel que verifica se foi conectado OK
Local oMail			:= NIL
Local nErro			:= 0
Local cMsgErro		:= ""
Local cUsuario		:= ""
Local oMessage		:= NIL
Local nPort			:= 0
Local nAt			:= 0
Local cServer		:= ""

Default cMailSenha  := ""
Default cMailConta  := ""
Default cMailServer := ""
Default lMailAuth   := .F.
Default lUseSSL   	:= .F.
Default lUseTLS 	:= .F.

cUsuario			:= SubStr(cMailConta,1,At("@",cMailConta)-1)


If (!Empty(cMailServer)) .AND. (!Empty(cMailConta)) .AND. (!Empty(cMailSenha))
	
	oMail	:= TMailManager():New()
	oMail:SetUseSSL(lUseSSL)
	oMail:SetUseTLS(lUseTLS)
	nAt	:=  At(':' , cMailServer)
	
	// Para autenticacao, a porta deve ser enviada como parametro[nSmtpPort] na chamada do método oMail:Init().
	If ( nAt > 0 )
		cServer		:= SubStr(cMailServer , 1 , (nAt - 1) )
		nPort		:= Val(AllTrim(SubStr(cMailServer , (nAt + 1) , Len(cMailServer) )) )
	Else
		cServer		:= cMailServer
	EndIf
	
	oMail:Init("", cServer, cMailConta, cMailSenha , 0 , nPort)	
	//Init( < cMailServer >, < cSmtpServer >, < cAccount >, < cPassword >, [ nMailPort ], [ nSmtpPort ] )
	
	nErro := oMail:SMTPConnect()
		
	If ( nErro == 0 )

		If lMailAuth

			// try with account and pass
			nErro := oMail:SMTPAuth(cMailConta, cMailSenha)
			If nErro != 0
				// try with user and pass
				nErro := oMail:SMTPAuth(cUsuario, cMailSenha)
				If nErro != 0
					AutoGrLog( OemToAnsi( STR0018 ) + CHR(13) + oMail:GetErrorString(nErro)) // Falha na conexão com servidor de e-mail:  	
					Return Nil
				EndIf
			EndIf
		Endif
		
		oMessage := TMailMessage():New()
		
		//Limpa o objeto
		oMessage:Clear()
		
		//Popula com os dados de envio
		oMessage:cFrom 		:= cMailConta
		oMessage:cTo 		:= cEmail
		oMessage:cCc 		:= ""
		oMessage:cBcc 		:= ""
		oMessage:cSubject 	:= cSubject
		oMessage:cBody 		:= cMensagem
		
		//Envia o e-mail
		nErro := oMessage:Send( oMail )
		
		If !(nErro == 0)
			cMsgErro := oMail:GetErrorString(nErro)
			AutoGrLog( OemToAnsi( STR0016 ) + CHR(13) + cMsgErro ) // Falha no envio do e-mail:
		Else
			lEnvioOk	:= .T.
		EndIf

		//Desconecta do servidor
		oMail:SmtpDisconnect()
		
	Else
		cMsgErro := oMail:GetErrorString(nErro)
		AutoGrLog(OemToAnsi( STR0018 ) + CHR(13) + cMsgErro) // Falha na conexão com servidor de e-mail:  	
	EndIf
	
Else

	If ( Empty(cMailServer) )
		AutoGrLog( OemToAnsi( STR0019 ) ) // Servidor de SMTP nao foi configurado: 
	EndIf

	If ( Empty(cMailConta) )
		AutoGrLog(OemToAnsi( STR0020 )) // Conta para envio de E-Mails não foi configurada
	EndIf
	
	If Empty(cMailSenha)
		AutoGrLog( OemToAnsi( STR0021 )) // A senha do E-mail  utilizado para o envio das mensagens não foi informada.
	EndIf
	
EndIf

Return( lEnvioOK )



/*/{Protheus.doc} Scheddef
Funcao static para carregar ambiente do schedule
@since 23/10/2015
@version P12
@See Documentação sobre schedule: 
http://tdn.totvs.com.br/display/framework/Schedule+Protheus
/*/			
Static Function Scheddef()
Local aOrd		:= {}
Local aParam	:= {}

aParam := {"P",;
			"PARAMDEF",;
			"",;
			aOrd, "" ;			
}	
Return aParam

