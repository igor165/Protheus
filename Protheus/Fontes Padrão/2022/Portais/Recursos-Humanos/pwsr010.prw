#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSR010PRW.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PWSR010.prw   ³ Autor ³ Mauricio MR        		  ³ Data ³ 10.07.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de cadastramento do curriculo via Portal Candidato			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.  			            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ FNC  	      	 ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³MauricioMR  |08/09/09|00000021002/2009|Ajuste na manutencao dos campos de usuario³±±
±±³            |        |     			 |de dados pessoais ao acionar o botao adi- ³±±
±±³            |        |     			 |cionar de historico de carreira.          ³±±
±±³Allyson M.  |27/05/10|00000010132/2010|Ajuste p/ gravar descricao do curso infor-³±±
±±³            |        |     			 |mado pelo usuario caso o curso selecionado³±±
±±³            |        |     			 |seja 'Outros'.					        ³±±
±±³Allyson M.  |20/05/11|00000012100/2011|Incluida validacao para retirar os carac- ³±±
±±³            |        |     			 |teres '<' e '>' de todos os campos pois   ³±±
±±³            |        |     			 |sao utilizadas em tags html e funcoes     ³±±
±±³            |        |     			 |javascript e o candidato poderia digitar  ³±±
±±³            |        |     			 |para derrubar o banco ou outro fim.       ³±±
±±³            |        |     			 |Incluida validacao para nao permitir digi-³±±
±±³            |        |     			 |tar mais do que 18224 caracteres.         ³±±
±±³Allyson M.  |20/06/11|00000013746/2011|Adicionado chamada para validar o RFC do  ³±±
±±³            |        |     			 |candidato.     							³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³R.Berti     |14/12/11|TECRDR|No MEX, a mascara numerica e' invertida (999,999.99)³±±
±±³            |        |      |Correcao de erros de exibicao(***,***.**)ou gravacao³±±
±±³            |        |      |incorreta campos(SQG) - Ult.Salario e Pret.Salarial.³±±
±±³Gustavo M.  |28/11/12|TGBPIQ|Ajuste para gravar corretamente a instituicao, caso ³±±
±±³            |        |      |usado a opcao "Outros".								³±±
±±³Luis Artuso |07/01/13|TGJWBH|Ajuste para exibir a descricao correta de:Cursos Re-³±±
±±³            |        |000151|levantes, Idiomas e Certificoes Tecnicas.           ³±±
±±³            |        |  2013|                                                    ³±±
±±³Emerson Camp|03/02/11|  PROJ|Implementacao dos controles de obrigatoriedade dos  ³±±
±±³            |        |297701|campos da SQG                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/



/*************************************************************/
/* Apresenta formulario para inclusao 						 */
/*************************************************************/
Web Function PWSR010A()	//GetCurriculum

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml
	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
	WsChgURL(@oObj,"RHCURRICULUM.APW")

	HttpSession->cCurricCpf 	:= DECODE64(HttpPost->cCurricCpf)
	HttpSession->cCurricPass 	:= DECODE64(HttpPost->cCurricPass)

	If !Empty( HttpSession->cCurricCpf ) //.And. !Empty( HttpSession->cCurricPass ) //Vem do PWSR000
		If oObj:GetCurriculum( "MSALPHA", HttpSession->cCurricCpf, HttpSession->cCurricPass, 1 )

			HttpSession->GetCurriculum 	:= {oObj:oWSGetCurriculumRESULT:oWSCURRIC1}
			HttpSession->GETTABLES 		:= {oObj:oWSGetCurriculumRESULT:oWSCURRIC2}

			If oObj:GetConfigField('SQG')
				/*
					Cada objeto contem 2 caracteres S ou N
					Primeiro caractere se e ou não obrigatorio S ou N
					Segundo caracter se e ou não visual na tela S ou N
				*/
            	HttpSession->oConfig	:= oObj:OWSGETCONFIGFIELDRESULT
            	If oObj:X3Fields('SQG',"QG_ULTSAL")
            		HttpSession->oPicture	:= oObj:oWSX3FIELDSRESULT:cUSERPICTURE
            	EndIf
			EndIf

			If AllTrim(HttpPost->cCurricPass) == "654321"
	           HttpPost->cScript := "<script>alert('STR0001')</script>" //"Troque sua senha de acesso."
    	    EndIf

			cHtml += ExecInPage( "PWSR010" )

		Else
			HttpSession->cCurricCpf := ""
			Return RHALERT( "", STR0002, STR0003, "W_PWSR000.APW" ) //"Portal Candidato"###"CPF ou Senha invalido."

		EndIf
	Else
		Return RHALERT( "", STR0002, STR0004, "W_PWSR000.APW" ) //"Portal Candidato"###"CPF deve ser informado."

	EndIf

WEB EXTENDED END

Return cHtml

/*************************************************************/
/* Apresenta formulario para atualizacao					 */
/*************************************************************/
Web Function PWSR010B()	//GetCurriculum

Local cHtml 		:= ""
Local oObj

WEB EXTENDED INIT cHtml

	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
	WsChgURL(@oObj,"RHCURRICULUM.APW")

	If !Empty(HttpPost->cCurricCpf)
		HttpSession->cCurricCpf 	:= DECODE64(HttpPost->cCurricCpf)
		HttpSession->cCurricPass 	:= DECODE64(HttpPost->cCurricPass)
	EndIf

	If !Empty( HttpSession->cCurricCpf ) //.And. !Empty( HttpSession->cCurricPass ) //Vem do PWSR000
		If oObj:GetCurriculum( "MSALPHA", HttpSession->cCurricCpf, HttpSession->cCurricPass, 2 )

			HttpSession->GetCurriculum 	:= {oObj:oWSGetCurriculumRESULT:oWSCURRIC1}
			HttpSession->GETTABLES 		:= {oObj:oWSGetCurriculumRESULT:oWSCURRIC2}

			If oObj:GetConfigField('SQG')
				/*
					Cada objeto contem 2 caracteres S ou N
					Primeiro caractere se e ou não obrigatorio S ou N
					Segundo caracter se e ou não visual na tela S ou N
				*/
            	HttpSession->oConfig	:= oObj:OWSGETCONFIGFIELDRESULT
            	If oObj:X3Fields('SQG',"QG_ULTSAL")
            		HttpSession->oPicture	:= oObj:oWSX3FIELDSRESULT:cUSERPICTURE
            	EndIf
			EndIf

			If AllTrim(HttpSession->cCurricPass) == "654321"
	           HttpPost->cScript := "<script>alert('STR0001')</script>" //"Troque sua senha de acesso."
    	    EndIf

			cHtml += ExecInPage( "PWSR010" )

		Else
			HttpSession->cCurricCpf := ""
			Return RHALERT( "", STR0002, STR0003, "W_PWSR00D.APW" ) //"Portal Candidato"###"CPF ou Senha invalido."

		EndIf
	Else
		Return RHALERT( " ", STR0002, STR0004, "W_PWSR00D.APW" ) //"Portal Candidato"###"CPF deve ser informado."

	EndIf

WEB EXTENDED END

Return cHtml


//************************************************************/
// Gravacao do Curriculo (Todos os dados) - Grava e Sai
//************************************************************/
Web Function PWSR011()

Local cHtml		:= "W_PWSR010"
Local oObj		:= ""
Local oObjTermo	:= ""
Local nI 		:= 0
Local cIdiom	:= FWRetIdiom()        //Retorna Idioma Atual

WEB EXTENDED INIT cHtml

	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
	WsChgURL(@oObj,"RHCURRICULUM.APW")

	If HttpSession->GetCurriculum != Nil
		Pwsr010Atu( HttpSession->GetCurriculum[1] )
		Pwsr010Char()

		If cPaisLoc == "MEX" .and. !ChkRfc(HttpSession->GetCurriculum[1]:cCPF, HttpSession->GetCurriculum[1]:cFirstName, HttpSession->GetCurriculum[1]:cSecondName, HttpSession->GetCurriculum[1]:cFirstSurname, HttpSession->GetCurriculum[1]:cSecondSurname, HttpSession->GetCurriculum[1]:dDateofBirth, HttpSession->GetCurriculum[1]:cGender, .T.)
			Return RHALERT( "", STR0002, STR0003, "W_PWSR00D.APW" ) //"Portal Candidato"###"CPF ou Senha invalido."
				//Return ExecInPage( "PWSR010" )
		Else
			//PARA GRAVAR DADOS DO USERFIELD
			For nI := 1 to len(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField)
				//SE TIPO FOR DATA, TRANSFORMA
				If HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserType == "D"
				   	HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserTag:= (&( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserName) ))

				ElseIf HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserType == "N"

					If (Upper(GetSrvProfString("PictFormat", "DEFAULT")) == "DEFAULT") .And. cPaisLoc <> "MEX"
						&( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserName) ) := StrTran( &( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserName) ), ".", "" )
						&( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserName) ) := StrTran( &( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserName) ), ",", "." )
					Else
						&( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserName) ) := StrTran( &( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserName) ), ",", "" )
					EndIf

					HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserTag := (&( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserName) ))

				Else
					HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserTag := &( "HttpPost->"+Alltrim(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserName) )
				EndIf
			Next nI

			If oObj:SetCurriculum( "MSALPHA", HttpSession->GetCurriculum[1] )//oObj:oWSCURRIC1 )	//Dados Pessoais
				IF FindClass( "WSTERMOCONSENT" ) .And. cPaisLoc == "BRA"
					oObjTermo := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSTERMOCONSENT"), WSTERMOCONSENT():New())
					WsChgURL( @oObjTermo, "TERMOCONSENT.APW" )
					if oObjTermo:GetCurrentTerm()
						HTTPSESSION->ARQUIVO 	:=  StrTran( oObjTermo:OWSGETCURRENTTERMRESULT:CDIRTERMO, '"', '' ) + oObjTermo:OWSGETCURRENTTERMRESULT:CFILEPATH
						HTTPSESSION->CODTERMO 	:= oObjTermo:OWSGETCURRENTTERMRESULT:CCODE
						HTTPSESSION->PAGINA := 'PWSR010'

						if Empty(HttpSession->GetCurriculum[1]:cCurriculum) .or. HttpSession->GetCurriculum[1]:cCurriculum == NIL
							HTTPSESSION->ROTINA := 3 //inclusao

							oObjTermo:cCPF := HttpSession->GetCurriculum[1]:CCPF

							if oObjTermo:GETCANDIDATE()
								HTTPSESSION->CUSERID 	:= oObjTermo:cGETCANDIDATERESULT
								cHtml := ExecInPage( "TERMOCONSENT" )
							ELSE
								cHtml := W_PWSR019C()
							ENDIF
						else
							HTTPSESSION->ROTINA  := 4 //ATUALIZACAO
							oObjTermo:cORIGIN	 := "1" //portal do candidato
							oObjTermo:cUSERID	 := HttpSession->GetCurriculum[1]:cBranch + HttpSession->GetCurriculum[1]:cCurriculum
							oObjTermo:oWSCURRENTTERM := oObjTermo:OWSGETCURRENTTERMRESULT

							if oObjTermo:GetCurrentAccept() .AND. !oObjTermo:LGETCURRENTACCEPTRESULT
								cHtml += ExecInPage("TERMOCONSENT")
							else
								cHtml := W_PWSR019C(oObjTermo:LGETCURRENTACCEPTRESULT)
							ENDIF
						ENDIF
					ELSE
						cHtml := W_PWSR019C()
					ENDIF
				ELSE
					If cIdiom == 'es'       
						cHtml := "<script>window.location='htmls-rh/PwsrAgradece-esp.htm';</script>"
					ElseIf cIdiom == 'en' 
						cHtml := "<script>window.location='htmls-rh/PwsrAgradece-ing.htm';</script>"
					Else
						cHtml := "<script>window.location='htmls-rh/PwsrAgradece.htm';</script>"
					Endif
				ENDIF
			Else
				Return RHALERT( "", STR0005, STR0006, "W_PWSR010.APW" ) //"Erro"###"Falha na gravação"
			EndIf
		EndIf
	Else
		Return RHALERT( " ", STR0002, STR0010, "W_PWSR00C.APW" ) //"Portal Candidato"###"Sua sessão expirou. Clique em Voltar para ser redirecionado para a página principal."
	EndIf

WEB EXTENDED END
Return cHtml

//************************************************************/
// Gravacao do Curriculo (Todos os dados) - Grava e Continua
//************************************************************/
Web Function PWSR011A()

Local cHtml	:= "W_PWSR010"
Local oObj	:= ""
Local nI 	:= 0

WEB EXTENDED INIT cHtml

	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
	WsChgURL(@oObj,"RHCURRICULUM.APW")

	If HttpSession->GetCurriculum != Nil
		Pwsr010Atu( HttpSession->GetCurriculum[1] )
		Pwsr010Char()

		//PARA GRAVAR DADOS DO USERFIELD
		For nI := 1 to len(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField)
			//SE TIPO FOR DATA, TRANSFORMA
			If HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserType == "D"
			   	HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserTag:= CtoD(&( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserName) ))

			ElseIf HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserType == "N"

				If (Upper(GetSrvProfString("PictFormat", "DEFAULT")) == "DEFAULT") .And. cPaisLoc <> "MEX"
					&( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserName) ) := StrTran( &( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserName) ), ".", "" )
					&( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserName) ) := StrTran( &( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserName) ), ",", "." )
				Else
					&( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserName) ) := StrTran( &( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserName) ), ",", "" )
				EndIf

				HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserTag := (&( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserName) ))
			Else
				HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserTag := &( "HttpPost->"+Alltrim(HttpSession->GetCurriculum[1]:oWsUserFieldS:oWsUserField[nI]:cUserName) )
			EndIf
		Next nI

		If oObj:SetCurriculum( "MSALPHA", HttpSession->GetCurriculum[1] )//oObj:oWSCURRIC1 )	//Dados Pessoais
			Return RHALERT( "", STR0007, STR0008, "W_PWSR010B.APW") //"Curriculo"###"Gravacao realizada com sucesso."
		Else
			Return RHALERT( "", STR0005, STR0006, "W_PWSR010.APW" ) //"Erro"###"Falha na gravação"
		EndIf
	Else
		Return RHALERT( " ", STR0002, STR0010, "W_PWSR00C.APW" ) //"Portal Candidato"###"Sua sessão expirou. Clique em Voltar para ser redirecionado para a página principal."
	EndIf

WEB EXTENDED END

Static Function IncHist()
Local cAux	:= ""
Local cHtml := ""
Local nX	:= 0
Local nI	:= 0
Local nZ	:= 0
Local cTag	:= ""
Local oObj	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("RHCURRICULUM_HISTORY"), RHCURRICULUM_HISTORY():New()) 

	aAdd( HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory, oObj)

	nX := Len( HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory )

	HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[nx]:cCompany  		:= HttpPost->cCompany
	HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[nx]:cFunctionCode		:= HttpPost->cFunctionCode
	HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[nx]:dAdmissionDate 	:= Ctod(HttpPost->dAdmissionDate)
	HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[nx]:dDismissalDate	:= Ctod(HttpPost->dDismissalDate)
	HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[nx]:cActivity			:= HttpPost->cActivity
	HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[nx]:cAreaCode			:= HttpPost->cAreaCode
	HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[nx]:cAreaDescription 	:= HttpPost->cAreaDesc
  	
	//Campos Usuario
	HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[nx]:oWsUserFields := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHCURRICULUM_ARRAYOFUSERFIELD"), RHCURRICULUM_ARRAYOFUSERFIELD():New())
	
	For nI := 1 to len(HttpSession->GetCurriculum[1]:oWsUserFieldHIST:oWsUserField)

		HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[nX]:oWsUserFields:oWsUserField := HttpSession->GetCurriculum[1]:oWsUserFieldHIST:oWsUserField

		If HttpSession->GetCurriculum[1]:oWsUserFieldHIST:oWsUserField[nI]:cUserType == "N"
			If (Upper(GetSrvProfString("PictFormat", "DEFAULT")) == "DEFAULT") .And. cPaisLoc <> "MEX"
				&( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldHIST:oWsUserField[nI]:cUserName) ) := StrTran( &( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldHIST:oWsUserField[nI]:cUserName) ), ".", "" )
				&( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldHIST:oWsUserField[nI]:cUserName) ) := StrTran( &( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldHIST:oWsUserField[nI]:cUserName) ), ",", "." )
			Else
				&( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldHIST:oWsUserField[nI]:cUserName) ) := StrTran( &( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldHIST:oWsUserField[nI]:cUserName) ), ",", "" )
			EndIf
			HttpSession->GetCurriculum[1]:oWsUserFieldHIST:oWsUserField[nI]:cUserTag := (&( "HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldHIST:oWsUserField[nI]:cUserName) ))
			HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[nX]:oWsUserFields:oWsUserField[nI]:cUserTag := &( "HttpPost->"+Alltrim(HttpSession->GetCurriculum[1]:oWsUserFieldHIST:oWsUserField[nI]:cUserName) )
		Else
			cAux := &("HttpPost->cUserTag"+AllTrim(str(nI)))	//cTag
			cAux :=	strtran( cAux, "<", "" )
			cAux :=	strtran( cAux, ">", "" )
			If Len( cAux ) >= 18225
				cAux := SubStr( cAux, 1, 18225 )
			EndIf
			HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[nX]:oWsUserFields:oWsUserField[nI]:cUserTag 		:= cAux
		EndIf
	Next nI

	//Limpar conteudo para nova inclusao
	HttpPost->cCompany 			:= ""
	HttpPost->cFunctionCode 	:= ""
	HttpPost->dAdmissionDate 	:= ""
	HttpPost->dDismissalDate 	:= ""
	HttpPost->cActivity 		:= ""
	HttpPost->cAreaCode 		:= ""
	HttpPost->cAreaDesc 		:= ""
	For nZ := 1 To Len( HttpSession->GetCurriculum[1]:oWsUserFieldHIST:oWsUserField  )
		&("HttpPost->cUserTag"+AllTrim(str(nZ)))	:= 	""
		&("HttpPost->"+Alltrim(HttpSession->GetCurriculum[1]:oWsUserFieldHIST:oWsUserField[nz]:cUserName) ) := ""
	Next nZ

	//Reposiciona o foco no Botao incluir apos clicar
	HttpPost->cScript := "<script>document.forms[0].Incluir_Historico.focus();</script>"

	If ExistBlock("PRS10Hist")
		ExecBlock("PRS10Hist",.F.,.F.,{HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[nX]}) //Rdmake recebe ParamIxb
	EndIf

Return

/*************************************************************/
/* Manutencao de Item de Historico na HttpSession / Oobj     */
/*************************************************************/
Web Function PWSR012()

Local cAux	:= ""
Local cHtml := ""
Local oObj
Local nx	:= 0
Local ny	:= 0
Local nZ	:= 0
Local cTipo	:= HttpPost->cTipo
Local nI	:= Val(HttpPost->nI)
Local cTag	:= ""

WEB EXTENDED INIT cHtml

	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
	WsChgURL(@oObj,"RHCURRICULUM.APW")

	If HttpSession->GetCurriculum != Nil
		If cTipo == "1"	//Inclusao
			IncHist()
		ElseIf cTipo == "2"	//Alteracao

			If Len( HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory ) > 0

				HttpPost->cCompany 			:= HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[ni]:cCompany
				HttpPost->cFunctionCode 	:= HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[ni]:cFunctionCode
				HttpPost->dAdmissionDate 	:= HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[ni]:dAdmissionDate
				HttpPost->dDismissalDate 	:= HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[ni]:dDismissalDate
				HttpPost->cActivity 		:= HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[ni]:cActivity
				HttpPost->cAreaCode 		:= HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[ni]:cAreaCode
				If !Empty(HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[ni]:cAreaDescription)
					HttpPost->cAreaDesc 		:= HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[ni]:cAreaDescription
				Else
					HttpPost->cAreaDesc 		:= ""
				EndIf
				For nx := 1 To Len( HttpSession->GetCurriculum[1]:oWsUserFieldHIST:oWsUserField  )
					&("HttpPost->cUserTag"+AllTrim(str(nX)))	:= 	HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory[ni]:oWsUserFields:oWsUserField[nx]:cUserTag
					&("HttpPost->"+Alltrim(HttpSession->GetCurriculum[1]:oWsUserFieldHIST:oWsUserField[nx]:cUserName) )	:= 	HttpSession->GetCurriculum[1]:oWsUserFieldHIST:oWsUserField[nx]:cUserTag
				Next nx

				aDel( HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory, nI )
				aSize( HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory, len( HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory ) - 1 )

			EndIf

			//Reposiciona o foco no Botao incluir apos clicar
			HttpPost->cScript := "<script>document.forms[0].Incluir_Historico.focus();</script>"

		ElseIf cTipo == "3"	//Exclusao
			If Len( HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory ) > 0
				aDel( HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory, nI )
				aSize( HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory, len( HttpSession->GetCurriculum[1]:OWSLISTOFHISTORY:oWsHistory ) - 1 )
			EndIf

			//Reposiciona o foco no Botao incluir apos clicar
			HttpPost->cScript := "<script>document.forms[0].Incluir_Historico.focus();</script>"

		EndIf

		Return ExecInPage( "PWSR010" )
	Else
		Return RHALERT( " ", STR0002, STR0010, "W_PWSR00C.APW" ) //"Portal Candidato"###"Sua sessão expirou. Clique em Voltar para ser redirecionado para a página principal."
	EndIf

WEB EXTENDED END

Static Function IncCurso()
Local cAux		:= ""
Local cHtml 	:= ""
Local nx		:= 0
Local nY 		:= 0
Local nZ 		:= 0
Local oObj		:= Iif(FindFunction("GetAuthWs"), GetAuthWs("RHCURRICULUM_COURSES"), RHCURRICULUM_COURSES():New())
Local cDescEnt 	:= ""
			
			aAdd( HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses, oObj  )
			
			nx := Len( HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses )

			HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[nx]:dGraduationDate		:= Ctod(HttpPost->dGraduationDate3)
			HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[nx]:cType		 		:= "4"

			HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[nx]:cCourseCode 			:= HttpPost->cCourse3Code
			HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[nx]:cCourseDesc 			:= IIF(Type("HttpPost->lCourse3Other") != "U", HttpPost->cC3Desc, HttpPost->cCourse3Desc)

			HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[nx]:cEntityCode 			:= IIF(Type("HttpPost->lEntity3Other") != "U", "", HttpPost->cEntity3Code)
			HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[nx]:cEntityDesc 			:= HttpPost->cEntity3Desc

			HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[nx]:cEmployCourse		:= ""
			HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[nx]:cEmployDescCourse	:= ""
			HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[nx]:cEmployEntity		:= ""
			HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[nx]:cEmployDescEntity	:= ""

		  	//Campos Usuario
			HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[nx]:oWsUserFields := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHCURRICULUM_ARRAYOFUSERFIELD"), RHCURRICULUM_ARRAYOFUSERFIELD():New())

			For nY := 1 To Len( HttpSession->GetCurriculum[1]:oWsUserFieldCOUR:oWsUserField )
				HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[nX]:oWsUserFields:oWsUserField := HttpSession->GetCurriculum[1]:oWsUserFieldCOUR:oWsUserField
		 		cAux := &("HttpPost->cr"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldCOUR:oWsUserField[nY]:cUserName)+AllTrim(str(nY)))	//cTag
				cAux :=	strtran( cAux, "<", "" )
				cAux :=	strtran( cAux, ">", "" )
				If Len( cAux ) >= 18225
					cAux := SubStr( cAux, 1, 18225 )
				EndIf
				HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[nX]:oWsUserFields:oWsUserField[nY]:cUserTag 		:= cAux
			Next nY

			//Limpar conteudo para nova inclusao
			HttpPost->dGraduationDate3	:= ""
			HttpPost->cCourse3Code	 	:= ""
			HttpPost->cCourse3Desc	 	:= ""
			HttpPost->cC3Desc	   		:= ""
			HttpPost->cEntity3Code	 	:= ""
			HttpPost->cEntity3Desc		:= ""

			For nZ := 1 To Len( HttpSession->GetCurriculum[1]:oWsUserFieldCOUR:oWsUserField  )
				&("HttpPost->cr"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldCOUR:oWsUserField[nZ]:cUserName)+AllTrim(str(nZ)))	:= 	""
			Next nZ


			//Reposiciona o foco no Botao incluir apos clicar
			HttpPost->cScript := "<script>document.forms[0].Incluir_Curso.focus();</script>"

			If ExistBlock("PRS10Cour")
				ExecBlock("PRS10Cour",.F.,.F.,{HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[nX], HttpPost->cCourse3Desc}) //Rdmake recebe ParamIxb
			EndIf

Return
/*************************************************************/
/* Manutencao de Item de Curso na HttpSession / Oobj         */
/* Alterado por: 	Juliana Barros - 05/09/2005				 */
/*************************************************************/
Web Function PWSR013()

Local cAux		:= ""
Local cHtml 	:= ""
Local cTipo		:= HttpPost->cTipo
Local nx		:= 0
Local nY 		:= 0
Local nZ 		:= 0
Local nI		:= Val(HttpPost->nI)
Local oObj		:= ""
Local cDescEnt 	:= ""

WEB EXTENDED INIT cHtml

	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
	WsChgURL(@oObj,"RHCURRICULUM.APW")

	If HttpSession->GetCurriculum != Nil
		If cTipo == "1"	//Inclusao
			IncCurso()
	   	ElseIf cTipo == "2"	//Alteracao

	    	If Len( HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses ) > 0
	            HttpPost->dGraduationDate3	:= Dtoc(HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[ni]:dGraduationDate)

				If Empty(HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[ni]:cCourseDesc)
					HttpPost->cCourse3Code 		:= ""
					HttpPost->cCourse3Desc		:= HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[ni]:cCourseCode
					HttpPost->lCourse3Other		:= .T.
				Else
					HttpPost->cCourse3Code 		:= HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[ni]:cCourseCode
					HttpPost->cCourse3Desc		:= HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[nI]:cCourseDesc
				EndIf

				If Empty(HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[ni]:cEntityCode)
					HttpPost->cEntity3Code		:= ""
					HttpPost->cEntity3Desc		:= HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[ni]:cEntityDesc
					HttpPost->lEntity3Other		:= .T.
				Else
					HttpPost->cEntity3Code		:= HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[ni]:cEntityCode
					HttpPost->cEntity3Desc		:= HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[ni]:cEntityDesc
				EndIf

				For nx := 1 To Len( HttpSession->GetCurriculum[1]:oWsUserFieldCOUR:oWsUserField  )
					&("HttpPost->cr"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldCOUR:oWsUserField[nX]:cUserName)+AllTrim(str(nX)))	:= 	HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses[ni]:oWsUserFields:oWsUserField[nx]:cUserTag
				Next nx

		        aDel( HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses, nI )
		        aSize( HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses, len( HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses ) - 1 )
		    EndIf

	   		//Reposiciona o foco no Botao incluir apos clicar
			HttpPost->cScript := "<script>document.forms[0].Incluir_Curso.focus();</script>"

	    ElseIf cTipo == "3"	//Exclusao
	    	If Len( HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses ) > 0
		        aDel( HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses, nI )
		        aSize( HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses, len( HttpSession->GetCurriculum[1]:oWsListOfCourses:oWsCourses ) - 1 )
		    EndIf

		    //Reposiciona o foco no Botao incluir apos clicar
			HttpPost->cScript := "<script>document.forms[0].Incluir_Curso.focus();</script>"

	    EndIf

		Return ExecInPage( "PWSR010" )
	Else
		Return RHALERT( " ", STR0002, STR0010, "W_PWSR00C.APW" ) //"Portal Candidato"###"Sua sessão expirou. Clique em Voltar para ser redirecionado para a página principal."
	EndIf

WEB EXTENDED END


/*************************************************************/
/* Manutencao de Item de Qualificacao na HttpSession / Oobj  */
/* Alterado por: 	Juliana Barros - 05/09/2005				 */
/*************************************************************/
Web Function PWSR014()

Local cAux	:= ""
Local cHtml := ""
Local cTipo	:= HttpPost->cTipo
Local nx	:= 0
Local nY 	:= 0
Local nZ 	:= 0
Local nI	:= Val(HttpPost->nI)
Local oObj	:= ""

WEB EXTENDED INIT cHtml

	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
	WsChgURL(@oObj,"RHCURRICULUM.APW")

	If HttpSession->GetCurriculum != Nil
		If cTipo == "1"	//Inclusao
			aAdd( HttpSession->GetCurriculum[1]:oWsListOfQualification:oWSQualification, Iif(FindFunction("GetAuthWs"), GetAuthWs("RHCURRICULUM_Qualification"), RHCURRICULUM_Qualification():New()) )
			nx := Len( HttpSession->GetCurriculum[1]:oWsListOfQualification:oWSQualification )

			HttpSession->GetCurriculum[1]:oWsListOfQualification:oWSQualification[nx]:cFactor  := HttpPost->cFactor1
			HttpSession->GetCurriculum[1]:oWsListOfQualification:oWSQualification[nx]:cDegree 	:= HttpPost->cDegree1

		  	//Campos Usuario
			HttpSession->GetCurriculum[1]:oWsListOfQualification:oWSQualification[nx]:oWsUserFields := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHCURRICULUM_ARRAYOFUSERFIELD"), RHCURRICULUM_ARRAYOFUSERFIELD():New())

			For nY := 1 To Len( HttpSession->GetCurriculum[1]:oWsUserFieldCert:oWsUserField )
				HttpSession->GetCurriculum[1]:oWsListOfQualification:oWSQualification[nX]:oWsUserFields:oWsUserField := HttpSession->GetCurriculum[1]:oWsUserFieldCert:oWsUserField
		 		cAux := &("HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldCert:oWsUserField[nY]:cUserName)+AllTrim(str(nY)))	//cTag
				cAux :=	strtran( cAux, "<", "" )
				cAux :=	strtran( cAux, ">", "" )
				If Len( cAux ) >= 18225
					cAux := SubStr( cAux, 1, 18225 )
				EndIf
				HttpSession->GetCurriculum[1]:oWsListOfQualification:oWSQualification[nX]:oWsUserFields:oWsUserField[nY]:cUserTag 		:= cAux
			Next nY

	        //Limpar conteudo para nova inclusao
		  	HttpPost->cFactor1	:= ""
			HttpPost->cDegree1 	:= ""

			For nX := 1 To Len( HttpSession->GetCurriculum[1]:oWsUserFieldCert:oWsUserField  )
				&("HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldCert:oWsUserField[nX]:cUserName)+AllTrim(str(nX)))	:= 	""
			Next nX

			//Reposiciona o foco no Botao incluir apos clicar
			HttpPost->cScript := "<script>document.forms[0].Incluir_Qualification.focus();</script>"

		   	If ExistBlock("PRS10Qual")
				ExecBlock("PRS10Qual",.F.,.F.,{HttpSession->GetCurriculum[1]:oWsListOfQualification:oWSQualification[nX]}) //Rdmake recebe ParamIxb
			EndIf

		ElseIf cTipo == "2"	//Alteracao

	    	If Len( HttpSession->GetCurriculum[1]:oWsListOfQualification:oWSQualification ) > 0

	    		HttpPost->cFactor1 	:=	HttpSession->GetCurriculum[1]:oWsListOfQualification:oWSQualification[ni]:cFactor
			 	HttpPost->cDegree1 	:=	HttpSession->GetCurriculum[1]:oWsListOfQualification:oWSQualification[ni]:cDegree

				For nZ := 1 To Len( HttpSession->GetCurriculum[1]:oWsUserFieldCert:oWsUserField  )
					&("HttpPost->"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldCert:oWsUserField[nZ]:cUserName)+AllTrim(str(nZ)))	:= 	HttpSession->GetCurriculum[1]:oWsListOfQualification:oWSQualification[ni]:oWsUserFields:oWsUserField[nZ]:cUserTag
				Next nZ

		        aDel( HttpSession->GetCurriculum[1]:oWsListOfQualification:oWSQualification, nI )
		        aSize( HttpSession->GetCurriculum[1]:oWsListOfQualification:oWSQualification, len( HttpSession->GetCurriculum[1]:oWsListOfQualification:oWSQualification ) - 1 )
		    EndIf

			//Reposiciona o foco no Botao incluir apos clicar
			HttpPost->cScript := "<script>document.forms[0].Incluir_Qualification.focus();</script>"

	    ElseIf cTipo == "3"	//Exclusao
	    	If Len( HttpSession->GetCurriculum[1]:oWsListOfQualification:oWSQualification ) > 0
		        aDel( HttpSession->GetCurriculum[1]:oWsListOfQualification:oWSQualification, nI )
		        aSize( HttpSession->GetCurriculum[1]:oWsListOfQualification:oWSQualification, len( HttpSession->GetCurriculum[1]:oWsListOfQualification:oWSQualification ) - 1 )
		    EndIf

	   		//Reposiciona o foco no Botao incluir apos clicar
			HttpPost->cScript := "<script>document.forms[0].Incluir_Qualification.focus();</script>"

	    EndIf

		Return ExecInPage( "PWSR010" )
	Else
		Return RHALERT( " ", STR0002, STR0010, "W_PWSR00C.APW" ) //"Portal Candidato"###"Sua sessão expirou. Clique em Voltar para ser redirecionado para a página principal."
	EndIf

WEB EXTENDED END

Static Function IncFormacao()
Local cAux		:= ""
Local cHtml 	:= ""
Local nx		:= 0
Local nY 		:= 0
Local nZ 		:= 0
Local oObj		:= Iif(FindFunction("GetAuthWs"), GetAuthWs("RHCURRICULUM_Graduation"), RHCURRICULUM_Graduation():New())
Local cDescEnt 	:= ""


			aAdd( HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation,oObj  )
			
			nx := Len( HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation )

			HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[nx]:dGraduationDate  	:= Ctod(HttpPost->dGraduationDate1)
			HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[nx]:cType	 			:= "1"

			HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[nx]:cCourseCode 		:= HttpPost->cCourse1Code
			HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[nx]:cCourseDesc 		:= IIF(Type("HttpPost->lCourse1Other") != "U", HttpPost->cC1Desc, HttpPost->cCourse1Desc)

			HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[nx]:cEntityCode 		:= IIF(Type("HttpPost->lEntity1Other") != "U", "", HttpPost->cEntity1Code)
			HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[nx]:cEntityDesc 		:= HttpPost->cEntity1Desc

			HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[nx]:cGrade 			:= HttpPost->cGrade1

			HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[nx]:cEmployCourse		:= ""
			HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[nx]:cEmployDescCourse	:= ""
			HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[nx]:cEmployEntity		:= ""
			HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[nx]:cEmployDescEntity	:= ""

		  	//Campos Usuario
			HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[nx]:oWsUserFields := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHCURRICULUM_ARRAYOFUSERFIELD"), RHCURRICULUM_ARRAYOFUSERFIELD():New())

			For nY := 1 To Len( HttpSession->GetCurriculum[1]:oWsUserFieldGRAD:oWsUserField )
				HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[nX]:oWsUserFields:oWsUserField := HttpSession->GetCurriculum[1]:oWsUserFieldGRAD:oWsUserField
		 		cAux := &("HttpPost->ac" + AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldGRAD:oWsUserField[nY]:cUserName) + AllTrim(STR(nY)))	//cTag
				cAux :=	strtran( cAux, "<", "" )
				cAux :=	strtran( cAux, ">", "" )
				If Len( cAux ) >= 18225
					cAux := SubStr( cAux, 1, 18225 )
				EndIf
				HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[nX]:oWsUserFields:oWsUserField[nY]:cUserTag 		:= cAux
			Next nY

	        //Limpar conteudo para nova inclusao
		  	HttpPost->dGraduationDate1	:= ""
			HttpPost->cGrade1		 	:= ""
			HttpPost->cCourse1Code		:= ""
			HttpPost->cCourse1Desc		:= ""
			HttpPost->cC1Desc	   		:= ""
			HttpPost->cEntity1Code		:= ""
			HttpPost->cEntity1Desc		:= ""

			For nZ := 1 To Len( HttpSession->GetCurriculum[1]:oWsUserFieldGRAD:oWsUserField  )
				&("HttpPost->ac"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldGRAD:oWsUserField[nZ]:cUserName)+AllTrim(str(nZ)))	:= 	""
			Next nZ


			//Reposiciona o foco no Botao incluir apos clicar
			HttpPost->cScript := "<script>document.forms[0].Incluir_Formacao.focus();</script>"

			If ExistBlock("PRS10Grad")
				ExecBlock("PRS10Grad",.F.,.F.,{HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[nX], HttpPost->cCourse1Desc}) //Rdmake recebe ParamIxb
			EndIf

Return

/*************************************************************/
/* Manutencao de Item de Formacao na HttpSession / Oobj      */
/* Alterado por: 	Juliana Barros - 05/09/2005				 */
/*************************************************************/
Web Function PWSR015()

Local cAux		:= ""
Local cHtml 	:= ""
Local cTipo		:= HttpPost->cTipo
Local nx		:= 0
Local nY 		:= 0
Local nZ 		:= 0
Local nI		:= Val(HttpPost->nI)
Local oObj		:= ""
Local cDescEnt 	:= ""

WEB EXTENDED INIT cHtml

	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
	WsChgURL(@oObj,"RHCURRICULUM.APW")

	If HttpSession->GetCurriculum != Nil
		If cTipo == "1"	//Inclusao
			IncFormacao()
		ElseIf cTipo == "2"	//Alteracao

	    	If Len( HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation ) > 0
	   	       	HttpPost->dGraduationDate1 	:= Dtoc(HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[ni]:dGraduationDate)
				HttpPost->cGrade1 			:= HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[ni]:cGrade

				If Empty(HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[ni]:cCourseDesc)
					HttpPost->cCourse1Code 		:= ""
					HttpPost->cCourse1Desc		:= HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[ni]:cCourseCode
					HttpPost->lCourse1Other		:= .T.
				Else
					HttpPost->cCourse1Code 		:= HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[ni]:cCourseCode
					HttpPost->cCourse1Desc		:= HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[nI]:cCourseDesc
				EndIf

				If Empty(HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[ni]:cEntityCode)
					HttpPost->cEntity1Code		:= ""
					HttpPost->cEntity1Desc		:= HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[ni]:cEntityDesc
					HttpPost->lEntity1Other		:= .T.
				Else
					HttpPost->cEntity1Code		:= HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[ni]:cEntityCode
					HttpPost->cEntity1Desc		:= HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[ni]:cEntityDesc
				EndIf

				For nX := 1 To Len( HttpSession->GetCurriculum[1]:oWsUserFieldGRAD:oWsUserField  )
					&("HttpPost->ac"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldGRAD:oWsUserField[nX]:cUserName)+AllTrim(str(nX)))	:= 	HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation[ni]:oWsUserFields:oWsUserField[nx]:cUserTag
				Next nX

		        aDel( HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation, nI )
		        aSize( HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation, len( HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation ) - 1 )
		    EndIf

			//Reposiciona o foco no Botao incluir apos clicar
			HttpPost->cScript := "<script>document.forms[0].Incluir_Formacao.focus();</script>"

	    ElseIf cTipo == "3"	//Exclusao
	    	If Len( HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation ) > 0
		        aDel( HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation, nI )
		        aSize( HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation, len( HttpSession->GetCurriculum[1]:oWsListOfGraduation:oWSGraduation ) - 1 )
		    EndIf

	   		//Reposiciona o foco no Botao incluir apos clicar
			HttpPost->cScript := "<script>document.forms[0].Incluir_Formacao.focus();</script>"

	    EndIf

		Return ExecInPage( "PWSR010" )
	Else
		Return RHALERT( " ", STR0002, STR0010, "W_PWSR00C.APW" ) //"Portal Candidato"###"Sua sessão expirou. Clique em Voltar para ser redirecionado para a página principal."
	EndIf

WEB EXTENDED END

Static Function IncIdioma()
Local cAux		:= ""
Local cHtml 	:= ""
Local nx		:= 0
Local nY 		:= 0
Local nZ 		:= 0
Local oObj		:= Iif(FindFunction("GetAuthWs"), GetAuthWs("RHCURRICULUM_Languages"), RHCURRICULUM_Languages():New())
Local cDescEnt 	:= ""

			aAdd( HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages, oObj )
			
			nx := Len( HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages )

			HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[nx]:dGraduationDate  	:= Ctod(HttpPost->dGraduationDate4)
			HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[nx]:cType	 			:= "3"
			HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[nx]:cGrade	 			:= HttpPost->cGrade4

			HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[nx]:cCourseCode 			:= HttpPost->cCourse4Code
			HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[nx]:cCourseDesc			:= IIF(Type("HttpPost->lCourse4Other") != "U", HttpPost->cC4Desc, HttpPost->cCourse4Desc)

			HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[nx]:cEntityCode			:= IIF(Type("HttpPost->lEntity4Other") != "U", "", HttpPost->cEntity4Code)
			HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[nx]:cEntityDesc			:= HttpPost->cEntity4Desc

			HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[nx]:cEmployCourse		:= ""
			HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[nx]:cEmployDescCourse	:= ""
			HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[nx]:cEmployEntity		:= ""
			HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[nx]:cEmployDescEntity	:= ""

		  	//Campos Usuario
			HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[nx]:oWsUserFields := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHCURRICULUM_ARRAYOFUSERFIELD"), RHCURRICULUM_ARRAYOFUSERFIELD():New())

			For nY := 1 To Len( HttpSession->GetCurriculum[1]:oWsUserFieldLang:oWsUserField )
				HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[nX]:oWsUserFields:oWsUserField := HttpSession->GetCurriculum[1]:oWsUserFieldLang:oWsUserField
		 		cAux := &("HttpPost->id"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldLang:oWsUserField[nY]:cUserName)+AllTrim(str(nY)))	//cTag
				cAux :=	strtran( cAux, "<", "" )
				cAux :=	strtran( cAux, ">", "" )
				If Len( cAux ) >= 18225
					cAux := SubStr( cAux, 1, 18225 )
				EndIf
				HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[nX]:oWsUserFields:oWsUserField[nY]:cUserTag 		:= cAux
			Next nY

	        //Limpar conteudo para nova inclusao
		  	HttpPost->dGraduationDate4	:= ""
	        HttpPost->cGrade4			:= ""
			HttpPost->cCourse4Code		:= ""
			HttpPost->cCourse4Desc		:= ""
			HttpPost->cC4Desc	   		:= ""
			HttpPost->cEntity4Code		:= ""
			HttpPost->cEntity4Desc		:= ""

			For nZ := 1 To Len( HttpSession->GetCurriculum[1]:oWsUserFieldLang:oWsUserField  )
				&("HttpPost->id"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldLang:oWsUserField[nZ]:cUserName)+AllTrim(str(nZ)))	:= 	""
			Next nZ

			//Reposiciona o foco no Botao incluir apos clicar
			HttpPost->cScript := "<script>document.forms[0].Incluir_Idioma.focus();</script>"

			If ExistBlock("PRS10Lang")
				ExecBlock("PRS10Lang",.F.,.F.,{HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[nX], HttpPost->cCourse4Desc}) //Rdmake recebe ParamIxb
			EndIf

Return

/*************************************************************/
/* Manutencao de Item de Idioma na HttpSession / Oobj        */
/* Alterado por: 	Juliana Barros - 05/09/2005				 */
/*************************************************************/
Web Function PWSR016()

Local cAux		:= ""
Local cHtml 	:= ""
Local cTipo		:= HttpPost->cTipo
Local nx		:= 0
Local nY 		:= 0
Local nZ 		:= 0
Local nI		:= Val(HttpPost->nI)
Local oObj		:= ""
Local cDescEnt 	:= ""

WEB EXTENDED INIT cHtml

	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
	WsChgURL(@oObj,"RHCURRICULUM.APW")

	If HttpSession->GetCurriculum != Nil
		If cTipo == "1"	//Inclusao
			IncIdioma()
		ElseIf cTipo == "2"	//Alteracao

			If Len( HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages ) > 0
		        HttpPost->dGraduationDate4 	:= Dtoc(HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[nI]:dGraduationDate)
				HttpPost->cGrade4 			:= HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[nI]:cGrade

				If Empty(HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[ni]:cCourseDesc)
					HttpPost->cCourse4Code 		:= ""
					HttpPost->cCourse4Desc		:= HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[ni]:cCourseCode
					HttpPost->lCourse4Other		:= .T.
				Else
					HttpPost->cCourse4Code 		:= HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[ni]:cCourseCode
					HttpPost->cCourse4Desc		:= HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[nI]:cCourseDesc
				EndIf

				If Empty(HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[ni]:cEntityCode)
					HttpPost->cEntity4Code		:= ""
					HttpPost->cEntity4Desc		:= HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[ni]:cEntityDesc
					HttpPost->lEntity4Other		:= .T.
				Else
					HttpPost->cEntity4Code		:= HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[ni]:cEntityCode
					HttpPost->cEntity4Desc		:= HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[ni]:cEntityDesc
				EndIf

				For nX := 1 To Len( HttpSession->GetCurriculum[1]:oWsUserFieldLang:oWsUserField  )
					&("HttpPost->id"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldLang:oWsUserField[nX]:cUserName)+AllTrim(str(nX)))	:= 	HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages[ni]:oWsUserFields:oWsUserField[nx]:cUserTag
				Next nX

		        aDel( HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages, nI )
		        aSize( HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages, len( HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages ) - 1 )
		    EndIf

			//Reposiciona o foco no Botao incluir apos clicar
			HttpPost->cScript := "<script>document.forms[0].Incluir_Idioma.focus();</script>"

	    ElseIf cTipo == "3"	//Exclusao
	    	If Len( HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages ) > 0
		        aDel( HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages, nI )
		        aSize( HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages, len( HttpSession->GetCurriculum[1]:oWsListOfLanguages:oWSLanguages ) - 1 )
		    EndIf

	   		//Reposiciona o foco no Botao incluir apos clicar
			HttpPost->cScript := "<script>document.forms[0].Incluir_Idioma.focus();</script>"

	    EndIf

		Return ExecInPage( "PWSR010" )
	Else
		Return RHALERT( " ", STR0002, STR0010, "W_PWSR00C.APW" ) //"Portal Candidato"###"Sua sessão expirou. Clique em Voltar para ser redirecionado para a página principal."
	EndIf

WEB EXTENDED END

Static Function IncCert()
Local cAux		:= ""
Local cHtml 	:= ""
Local nx		:= 0
Local nY 		:= 0
Local nZ		:= 0
Local nPos		:= 0
Local oObj		:= Iif(FindFunction("GetAuthWs"), GetAuthWs("RHCURRICULUM_Certification"), RHCURRICULUM_Certification():New())
Local cDescEnt 	:= ""

			aAdd( HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification, oObj)
			
			nx := Len( HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification )

			HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[nx]:dGraduationDate		:= Ctod(HttpPost->dGraduationDate2)
			HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[nx]:cType	 			:= "2"

			HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[nx]:cCourseCode	 		:= HttpPost->cCourse2Code
			HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[nx]:cCourseDesc	 		:= IIF(Type("HttpPost->lCourse2Other") != "U", HttpPost->cC2Desc, HttpPost->cCourse2Desc)

			HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[nx]:cEntityCode			:= IIF(Type("HttpPost->lEntity2Other") != "U", "" , HttpPost->cEntity2Code)
			HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[nx]:cEntityDesc			:= HttpPost->cEntity2Desc

			HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[nx]:cEmployCourse		:= ""
			HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[nx]:cEmployDescCourse	:= ""
			HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[nx]:cEmployEntity		:= ""
			HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[nx]:cEmployDescEntity	:= ""

		  	//Campos Usuario
			HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[nx]:oWsUserFields := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHCURRICULUM_ARRAYOFUSERFIELD"), RHCURRICULUM_ARRAYOFUSERFIELD():New())

			For nY := 1 To Len( HttpSession->GetCurriculum[1]:oWsUserFieldCert:oWsUserField )
				HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[nX]:oWsUserFields:oWsUserField := HttpSession->GetCurriculum[1]:oWsUserFieldCert:oWsUserField
		 		cAux := &("HttpPost->ct"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldCert:oWsUserField[nY]:cUserName)+AllTrim(str(nY)))	//cTag
				cAux :=	strtran( cAux, "<", "" )
				cAux :=	strtran( cAux, ">", "" )
				If Len( cAux ) >= 18225
					cAux := SubStr( cAux, 1, 18225 )
				EndIf
				HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[nX]:oWsUserFields:oWsUserField[nY]:cUserTag 		:= cAux
			Next nY

	        //Limpar conteudo para nova inclusao
		  	HttpPost->dGraduationDate2	:= ""
			HttpPost->cCourse2Code	 	:= ""
			HttpPost->cCourse2Desc	 	:= ""
			HttpPost->cC2Desc	 		:= ""
			HttpPost->cEntity2Code	 	:= ""
			HttpPost->cEntity2Desc	 	:= ""

			For nZ := 1 To Len( HttpSession->GetCurriculum[1]:oWsUserFieldCert:oWsUserField  )
				&("HttpPost->ct"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldCert:oWsUserField[nZ]:cUserName)+AllTrim(str(nZ)))	:= 	""
			Next nZ

			//Reposiciona o foco no Botao incluir apos clicar
			HttpPost->cScript := "<script>document.forms[0].Incluir_Certificacao.focus();</script>"

			If ExistBlock("PRS10Cert")
				ExecBlock("PRS10Cert",.F.,.F.,{HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[nX], HttpPost->cCourse2Desc}) //Rdmake recebe ParamIxb
			EndIf
Return

/*************************************************************/
/* Manutencao de Item de Certificacao na HttpSession / Oobj  */
/* Alterado por: 	Juliana Barros - 05/09/2005				 */
/*************************************************************/
Web Function PWSR017()

Local cAux		:= ""
Local cHtml 	:= ""
Local cTipo		:= HttpPost->cTipo
Local nx		:= 0
Local nY 		:= 0
Local nZ		:= 0
Local nI		:= Val(HttpPost->nI)
Local nPos		:= 0
Local oObj		:= ""
Local cDescEnt 	:= ""

WEB EXTENDED INIT cHtml

	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
	WsChgURL(@oObj,"RHCURRICULUM.APW")

	If HttpSession->GetCurriculum != Nil
		If cTipo == "1"	//Inclusao
			IncCert()

		ElseIf cTipo == "2"	//Alteracao

			If Len( HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification ) > 0
		        HttpPost->dGraduationDate2 	:= Dtoc(HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[ni]:dGraduationDate)

				If Empty(HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[ni]:cCourseDesc)
					HttpPost->cCourse2Code 		:= ""
					HttpPost->cCourse2Desc		:= HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[ni]:cCourseCode
					HttpPost->lCourse2Other		:= .T.
				Else
					HttpPost->cCourse2Code 		:= HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[ni]:cCourseCode
					HttpPost->cCourse2Desc		:= HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[nI]:cCourseDesc
				EndIf

				If Empty(HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[ni]:cEntityCode)
					HttpPost->cEntity2Code		:= ""
					HttpPost->cEntity2Desc		:= HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[ni]:cEntityDesc
					HttpPost->lEntity2Other		:= .T.
				Else
					HttpPost->cEntity2Code		:= HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[ni]:cEntityCode
					HttpPost->cEntity2Desc		:= HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[ni]:cEntityDesc
				EndIf

				For nX := 1 To Len( HttpSession->GetCurriculum[1]:oWsUserFieldCert:oWsUserField  )
					&("HttpPost->ct"+AllTrim(HttpSession->GetCurriculum[1]:oWsUserFieldCert:oWsUserField[nX]:cUserName)+AllTrim(str(nX)))	:= 	HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification[ni]:oWsUserFields:oWsUserField[nx]:cUserTag
				Next nX

		        aDel( HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification, nI )
		        aSize( HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification, len( HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification ) - 1 )
		    EndIf

	 		//Reposiciona o foco no Botao incluir apos clicar
			HttpPost->cScript := "<script>document.forms[0].Incluir_Certificacao.focus();</script>"

	    ElseIf cTipo == "3"	//Exclusao
	    	If Len( HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification ) > 0
		        aDel( HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification, nI )
		        aSize( HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification, len( HttpSession->GetCurriculum[1]:oWsListOfCertification:oWSCertification ) - 1 )
		    EndIf

	   		//Reposiciona o foco no Botao incluir apos clicar
			HttpPost->cScript := "<script>document.forms[0].Incluir_Certificacao.focus();</script>"

	    EndIf

		Return ExecInPage( "PWSR010" )
	Else
		Return RHALERT( " ", STR0002, STR0010, "W_PWSR00C.APW" ) //"Portal Candidato"###"Sua sessão expirou. Clique em Voltar para ser redirecionado para a página principal."
	EndIf

WEB EXTENDED END


/*************************************************************/
/* Atualiza Dados Pessoais da Session com Post 		         */
/*************************************************************/
Static Function Pwsr010Atu( oObj )

Local nx 			:= 0
Local ny 			:= 0
Local aCurricClass 	:= {}

aCurricClass 	:= ClassDataArr(oObj)	//Seta ponteiro do array no objeto

If HttpPost->cIncHist == "1"
	IncHist()
EndIf

If HttpPost->cIncCurso == "1"
	IncCurso()
EndIf

If HttpPost->cIncFormacao == "1"
	IncFormacao()
EndIf

If HttpPost->cIncIdioma == "1"
	IncIdioma()
EndIf

If HttpPost->cIncCert == "1"
	IncCert()
EndIf
For nx := 1 To Len(HttpPost->aPost)
	ny := Ascan(aCurricClass, {|x| x[1] == HttpPost->aPost[nx] })
	If ny > 0

		If Left(HttpPost->aPost[nx],1) == "D"
			aCurricClass[ny][2] := Ctod(&("HttpPost->"+HttpPost->aPost[nx]))
			&("HttpSession->GetCurriculum[1]:"+HttpPost->aPost[nx]) := Ctod(&("HttpPost->"+HttpPost->aPost[nx]))
		ElseIf Left(HttpPost->aPost[nx],1) == "N"

			If (Upper(GetSrvProfString("PictFormat", "DEFAULT")) == "DEFAULT") .And. cPaisLoc <> "MEX"
				&( "HttpPost->" + HttpPost->aPost[nx] ) := StrTran( &( "HttpPost->" + HttpPost->aPost[nx] ), ".", "" )
				&( "HttpPost->" + HttpPost->aPost[nx] ) := StrTran( &( "HttpPost->" + HttpPost->aPost[nx] ), ",", "." )
			Else
				&( "HttpPost->" + HttpPost->aPost[nx] ) := StrTran( &( "HttpPost->" + HttpPost->aPost[nx] ), ",", "" )
			EndIf

			aCurricClass[ny][2] := Val(&("HttpPost->"+HttpPost->aPost[nx])	)
			&("HttpSession->GetCurriculum[1]:"+HttpPost->aPost[nx]) := Val(&("HttpPost->"+HttpPost->aPost[nx]))
		Else
			aCurricClass[ny][2] := &("HttpPost->"+HttpPost->aPost[nx])
			&("HttpSession->GetCurriculum[1]:"+HttpPost->aPost[nx]) := &("HttpPost->"+HttpPost->aPost[nx])
		EndIf

	EndIf
Next nx

//Em virtude do campo da senha ter sido retirado do formulário de curriculum
//e transferido para a opção de alteração de senha no menu, esse campo será atualizado separadamente
HttpSession->GetCurriculum[1]:cPassword := HttpSession->cCurricPass


Return Nil

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³Pwsr010Char³ Autor ³ Leandro Drumond      ³ Data ³ 06/06/16 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Atualiza dados de caracteristicas do candidato.			    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<vide parametros formais>                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<vide parametros formais>                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Generico                                                    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function Pwsr010Char(lPost)
Local nX := 0
Local cResp	:= ""
Local lAtu := .T.
Default lPost := .F.
If HttpSession->GetCurriculum[1]:nNumberChars > 0
	For nX := 1 to Len(HttpSession->GetCurriculum[1]:oWsListofCharacters:oWsCharacters)
		lAtu := .T.
		If lPost
			cResp := &("HttpPost->Char"+AllTrim(Str(nX)))
			If Empty(cResp)
				lAtu := .F.
			EndIf
		EndIf
		If lAtu
			If HttpSession->GetCurriculum[1]:oWsListofCharacters:oWsCharacters[nX]:cType == "3"
				HttpSession->GetCurriculum[1]:oWsListofCharacters:oWsCharacters[nX]:cAnswer := &("HttpPost->Char"+AllTrim(Str(nX)))
			ElseIf HttpSession->GetCurriculum[1]:oWsListofCharacters:oWsCharacters[nX]:cType == "2"
				cResp := &("HttpPost->Char"+AllTrim(Str(nX)))
				If cResp <> Nil
					HttpSession->GetCurriculum[1]:oWsListofCharacters:oWsCharacters[nX]:cChoice := StrTran(&("HttpPost->Char"+AllTrim(Str(nX))),", ","*")
				Else
					HttpSession->GetCurriculum[1]:oWsListofCharacters:oWsCharacters[nX]:cChoice := ""
				EndIf
			Else
				HttpSession->GetCurriculum[1]:oWsListofCharacters:oWsCharacters[nX]:cChoice := &("HttpPost->Char"+AllTrim(Str(nX)))
			EndIf
		EndIf
	Next nX
EndIf

Return Nil

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³RetUserFields³ Autor ³ Mauricio MR	      ³ Data ³ 04/09/09 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Identifica e trata inicializacao dos campos do formulario   ³
³          ³para alimentacao do curriculo.                              ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<vide parametros formais>                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<vide parametros formais>                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Generico                                                    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/

Function RetUserFields(;
						xVar,	; //01 - Campo do formulario
						m		; //02 - Posicao do campo na estrutura do webservice do curriculo
					   )
Local lNil	:= .F.
Local xRet:= ''

If xVar == Nil
    lNil:= .T.
	If HttpPost->GetCurriculum[1]:oWsUserFields:oWsUserField[m]:cUserType == 'D'
       xVar:= Ctod(Space(8))
    ElseIf HttpPost->GetCurriculum[1]:oWsUserFields:oWsUserField[m]:cUserType == 'N'

      	If (Upper(GetSrvProfString("PictFormat", "DEFAULT")) == "DEFAULT") .And. cPaisLoc <> "MEX"
			xVar  := StrTran( HttpPost->GetCurriculum[1]:oWsUserFields:oWsUserField[m]:cUserTag , ".", "" )
			xVar  := StrTran(xVar , ",", "." )
		Else
			xVar  := StrTran( HttpPost->GetCurriculum[1]:oWsUserFields:oWsUserField[m]:cUserTag , ",", "" )
		EndIf

    Else
		xVar:= ''
    Endif
Else
	xVar:= xVar
Endif


If ( Empty(HttpPost->GetCurriculum[1]:oWsUserFields:oWsUserField[m]:cUserTag ) )
	If Empty(xVar)
		xRet:= Alltrim(xVar)
	Else
	    IF HttpPost->GetCurriculum[1]:oWsUserFields:oWsUserField[m]:cUserType == 'D'
		   If( Len(xVar)<8 )
		          	xRet:=xVar
		   Else
		         	xRet:=StoD(xVar)
		   Endif
		ElseIF  HttpPost->GetCurriculum[1]:oWsUserFields:oWsUserField[m]:cUserType == 'N'

	    	If (Upper(GetSrvProfString("PictFormat", "DEFAULT")) == "DEFAULT") .And. cPaisLoc <> "MEX"
				xRet  := StrTran( xVar , ",", "" )
				xRet  := StrTran(xRet , ".", "," )
			Else
				xRet  := StrTran( xVar , ",", "" )
			Endif

			xRet:=AllTrim(xVar)
		Else
			xRet:=AllTrim(xVar)
		Endif
	Endif
Else
    IF HttpPost->GetCurriculum[1]:oWsUserFields:oWsUserField[m]:cUserType == 'D'
	    If( len(HttpPost->GetCurriculum[1]:oWsUserFields:oWsUserField[m]:cUserTag) < 8 )
				xRet:=HttpPost->GetCurriculum[1]:oWsUserFields:oWsUserField[m]:cUserTag
		Else
				IF lNil
					xRet:=Stod(HttpPost->GetCurriculum[1]:oWsUserFields:oWsUserField[m]:cUserTag)
				Else
					xRet:=HttpPost->GetCurriculum[1]:oWsUserFields:oWsUserField[m]:cUserTag
				Endif
        Endif
    ElseIF HttpPost->GetCurriculum[1]:oWsUserFields:oWsUserField[m]:cUserType == 'N'

	    	If (Upper(GetSrvProfString("PictFormat", "DEFAULT")) == "DEFAULT") .And. cPaisLoc <> "MEX"
				xRet  := StrTran( HttpPost->GetCurriculum[1]:oWsUserFields:oWsUserField[m]:cUserTag , ",", "" )
				xRet  := StrTran(xRet , ".", "," )
			Else
				xRet  := StrTran( HttpPost->GetCurriculum[1]:oWsUserFields:oWsUserField[m]:cUserTag , ",", "" )
			EndIf

			xRet:=Val(AllTrim(HttpPost->GetCurriculum[1]:oWsUserFields:oWsUserField[m]:cUserTag))
    Else
       	xRet:=AllTrim(HttpPost->GetCurriculum[1]:oWsUserFields:oWsUserField[m]:cUserTag)
    Endif
Endif
Return xRet

/*/{Protheus.doc} RetUsFldHist
	(long_description)
	@type  Function
	@author Emerson Grassi
	@since 06/01/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function RetUsFldHist(;
						xVar,	; //01 - Campo do formulario
						m		; //02 - Posicao do campo na estrutura do webservice do curriculo
					   )
Local lNil	:= .F.
Local xRet:= ''

If xVar == Nil
    lNil:= .T.
	If HttpPost->GetCurriculum[1]:OWSUSERFIELDHIST:oWsUserField[m]:cUserType == 'D'
       xVar:= Ctod(Space(8))
    ElseIf HttpPost->GetCurriculum[1]:OWSUSERFIELDHIST:oWsUserField[m]:cUserType == 'N'

      	If (Upper(GetSrvProfString("PictFormat", "DEFAULT")) == "DEFAULT") .And. cPaisLoc <> "MEX"
			xVar  := StrTran( HttpPost->GetCurriculum[1]:OWSUSERFIELDHIST:oWsUserField[m]:cUserTag , ".", "" )
			xVar  := StrTran(xVar , ",", "." )
		Else
			xVar  := StrTran( HttpPost->GetCurriculum[1]:OWSUSERFIELDHIST:oWsUserField[m]:cUserTag , ",", "" )
		EndIf

    Else
		xVar:= ''
    Endif
Else
	xVar:= xVar
Endif


If ( Empty(HttpPost->GetCurriculum[1]:OWSUSERFIELDHIST:oWsUserField[m]:cUserTag ) )
	If Empty(xVar)
		xRet:= Alltrim(xVar)
	Else
	    IF HttpPost->GetCurriculum[1]:OWSUSERFIELDHIST:oWsUserField[m]:cUserType == 'D'
		   If( Len(xVar)<8 )
		          	xRet:=xVar
		   Else
		         	xRet:=StoD(xVar)
		   Endif
		ElseIF  HttpPost->GetCurriculum[1]:OWSUSERFIELDHIST:oWsUserField[m]:cUserType == 'N'

	    	If (Upper(GetSrvProfString("PictFormat", "DEFAULT")) == "DEFAULT") .And. cPaisLoc <> "MEX"
				xRet  := StrTran( xVar , ",", "" )
				xRet  := StrTran(xRet , ".", "," )
			Else
				xRet  := StrTran( xVar , ",", "" )
			Endif

			xRet:=AllTrim(xVar)
		Else
			xRet:=AllTrim(xVar)
		Endif
	Endif
Else
    IF HttpPost->GetCurriculum[1]:OWSUSERFIELDHIST:oWsUserField[m]:cUserType == 'D'
	    If( len(HttpPost->GetCurriculum[1]:OWSUSERFIELDHIST:oWsUserField[m]:cUserTag) < 8 )
				xRet:=HttpPost->GetCurriculum[1]:OWSUSERFIELDHIST:oWsUserField[m]:cUserTag
		Else
				IF lNil
					xRet:=Stod(HttpPost->GetCurriculum[1]:OWSUSERFIELDHIST:oWsUserField[m]:cUserTag)
				Else
					xRet:=HttpPost->GetCurriculum[1]:OWSUSERFIELDHIST:oWsUserField[m]:cUserTag
				Endif
        Endif
    ElseIF HttpPost->GetCurriculum[1]:OWSUSERFIELDHIST:oWsUserField[m]:cUserType == 'N'

	    	If (Upper(GetSrvProfString("PictFormat", "DEFAULT")) == "DEFAULT") .And. cPaisLoc <> "MEX"
				xRet  := StrTran( HttpPost->GetCurriculum[1]:OWSUSERFIELDHIST:oWsUserField[m]:cUserTag , ",", "" )
				xRet  := StrTran(xRet , ".", "," )
			Else
				xRet  := StrTran( HttpPost->GetCurriculum[1]:OWSUSERFIELDHIST:oWsUserField[m]:cUserTag , ",", "" )
			EndIf

			xRet:=Val(AllTrim(HttpPost->GetCurriculum[1]:OWSUSERFIELDHIST:oWsUserField[m]:cUserTag))
    Else
       	xRet:=AllTrim(HttpPost->GetCurriculum[1]:OWSUSERFIELDHIST:oWsUserField[m]:cUserTag)
    Endif
Endif
Return xRet


Web Function PWSR018()
Local cHtml 	:= ""
Local nI		:= 1
Local oObj		:= ""

WEB EXTENDED INIT cHtml

	HttpCTType("text/html; charset=ISO-8859-1")

	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
	WsChgURL(@oObj,"RHCURRICULUM.APW")

	If oObj:BrwCity(HttpGet->cChave)
			cHtml += '<td width="400" class="FundoConteudo">'
			cHtml += '	            <span class="TituloMenor">'
			cHtml += '	            	<select name="cCodCityOri" id="cCodCityOri" class="combo"  onBlur="return limparMsg("cCodCityOri", "cCodCityOriAlert")">'
			cHtml += '						<option value=""></option>'
			For nI := 1 To Len(oObj:oWSBRWCITYRESULT:oWSCITY)
				cHtml += "<option value='" + oObj:oWSBRWCITYRESULT:oWSCITY[nI]:cCodCityOri + "'" + IIf(Alltrim(HttpSession->GETCURRICULUM[1]:cCodCityOri) == Alltrim(oObj:oWSBRWCITYRESULT:oWSCITY[nI]:cCodCityOri),'selected',"") + "> "+ AllTrim(oObj:oWSBRWCITYRESULT:oWSCITY[nI]:cCityOri) +"</option>"
			Next nI
			cHtml += '					</select>'
			cHtml += '	            </span>'
			cHtml += '	            <br /><span class="alertas" id="cCodCityOriAlert"></span>'
			cHtml += '	        </td>'

	Else
		cHtml := GetWsCError(3)
	EndIf

WEB EXTENDED END

Return cHtml


//-------------------------------------------------------------------
/*/{Protheus.doc} function PWSR019
Funcao para processar o aceite do termo de consentimento
@author  Gisele Nuncherino
@since   13/03/2020
/*/
//-------------------------------------------------------------------
Web Function PWSR019()
Local cHtml 	:= ""
Local oObjTermo	:= ""

WEB EXTENDED INIT cHtml

	oObjTermo := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSTERMOCONSENT"), WSTERMOCONSENT():New())
	WsChgURL( @oObjTermo, "TERMOCONSENT.APW" )
	oObjTermo:oWSCURRENTTERM := Iif(FindFunction("GetAuthWs"), GetAuthWs("TERMOCONSENT_TCURRENTTERM"), TERMOCONSENT_TCURRENTTERM():New())

	oObjTermo:oWSCURRENTTERM:cCODE	 	 := HTTPSESSION->CODTERMO
	oObjTermo:cORIGIN	 := "1" //portal do candidato
	IF HTTPSESSION->ROTINA == 4
		oObjTermo:cUSERID	 := HttpSession->GetCurriculum[1]:cBranch + HttpSession->GetCurriculum[1]:cCurriculum
	ELSEIF HTTPSESSION->ROTINA == 3
		oObjTermo:cUSERID	 := HTTPSESSION->CUSERID
	ENDIF

	if oObjTermo:PutAceite()
		cHtml := W_PWSR019C()
	else
		Return RHALERT( "", STR0005, STR0038, "W_PWSR010.APW" ) //"Erro"###"Falha na gravação"
	ENDIF

WEB EXTENDED END

Return cHtml


//-------------------------------------------------------------------
/*/{Protheus.doc} function PWSR019A
Funcao para direcionar para a pagina de nao aceite do termo
@author  Gisele Nuncherino
@since   13/03/2020
/*/
//-------------------------------------------------------------------
Web Function PWSR019A()
Local cHtml 	:= ""

WEB EXTENDED INIT cHtml

	cHtml += ExecInPage( "TermoNaoAceite" )

WEB EXTENDED END

Return cHtml


//-------------------------------------------------------------------
/*/{Protheus.doc} function PWSR019B
Funcao para direcionar para a pagina de revogacao do termo
@author  Gisele Nuncherino
@since   16/03/2020
/*/
//-------------------------------------------------------------------
Web Function PWSR019B()
Local cHtml 	:= ""

WEB EXTENDED INIT cHtml

	cHtml += ExecInPage( "Revogacao" )

WEB EXTENDED END

Return cHtml

/*/{Protheus.doc} PWSR019C
	Validar direcionamento para página de agradecimento ou ao bloqueio do candidato menor de 18 anos
	@author	isabel.noguti
	@since	17/03/2020
	@version 1.0
/*/
Web Function PWSR019C(lTermAc)
Local cHtml		:= ""
Local oObjTermo	:= ""
Local cCodRDG	:= ""
Local oMsg		:= ""
Local lMsgPad	:= .T.
Local cIdiom	:= FWRetIdiom()        //Retorna Idioma Atual

DEFAULT lTermAc	:= .F.

WEB EXTENDED INIT cHtml

	oObjTermo := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSTERMOCONSENT"), WSTERMOCONSENT():New())
	WsChgURL( @oObjTermo, "TERMOCONSENT.APW" )

	IF HttpSession->Rotina == 3
		oObjTermo:cUserID	 := HttpSession->cUserID
	Else
		oObjTermo:cUserID	 := HttpSession->GetCurriculum[1]:cBranch + HttpSession->GetCurriculum[1]:cCurriculum
	EndIf

	If HttpSession->Rotina != 2
		HttpSession->cMsgBlq := STR0043	//"Confirmamos o cadastramento de seu currículo!"
	EndIf

	If ( YearSum( HttpSession->GetCurriculum[1]:dDateofBirth, 18) > Date() .And. oObjTermo:GetMinorAccept() .AND. !oObjTermo:OWSGetMinorAcceptRESULT:lACCEPT ) .Or. HttpSession->Rotina == 2
		cCodRDG := oObjTermo:OWSGetMinorAcceptRESULT:cCODRDG
		If !Empty(cCodRDG)
			oMsg	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
			WsChgURL(@oMsg,"RHPERSONALDESENVPLAN.APW")
			If oMsg:GETMESSAGE( "MSALPHA", cCodRDG )
				If !Empty(oMsg:cGETMESSAGERESULT)
					HttpSession->cMsgBlq += "</br></br>" + StrTran( oMsg:cGETMESSAGERESULT, Chr( 10 ), "<br>" )
					lMsgPad := .F.
				EndIf
			EndIf
		EndIf
		If lMsgPad
			HttpSession->cMsgBlq += "</br></br>" + STR0039 + "<B><U>" + STR0040 + "</U></B></br></br>" + STR0041
		EndIf
		cHtml := ExecInPage("TermoMenor")
	Else
		If cPaisLoc == 'BRA' .And. lTermAc .And. HttpSession->Rotina == 4
			cHtml := "<script>window.location='htmls-rh/PwsrAgradeceTermo.htm';</script>"
		Else
			If cIdiom == 'es'       
				cHtml := "<script>window.location='htmls-rh/PwsrAgradece-esp.htm';</script>"				
			ElseIf cIdiom == 'en' 
				cHtml := "<script>window.location='htmls-rh/PwsrAgradece-ing.htm';</script>"				
			Else
				cHtml := "<script>window.location='htmls-rh/PwsrAgradece.htm';</script>"			
			Endif
		EndIf
	EndIf

WEB EXTENDED END

Return cHtml

/*/{Protheus.doc} PWSR019D
	//Bloqueio de inscrição em vaga por falta de consentimento
	@author	isabel.noguti
	@since	27/03/2020
	@version 1.0
/*/
Web Function PWSR019D()

Local cHtml := ""

WEB EXTENDED INIT cHtml

	HttpSession->Rotina := 2 //Visualizar vaga
	HttpSession->cMsgBlq := STR0042	//"Seu currículo se encontra bloqueado para inscrição nas vagas disponíveis."

	If HttpSession->GetCurriculum[1]:cAceite != '2'
		HttpSession->cMsgBlq += "</br></br>" + STR0044 + "<B><U>" + STR0045 + "</U></B>" + STR0046
		//"Acesse a página de atualização de currículo e, se de acordo, aceite o Termo de Consentimento para uso de seus dados cadastrais."
	EndIf

	If HttpSession->GetCurriculum[1]:cAceiteResp == '1'
		cHtml := W_PWSR019C()
	else
		cHtml := ExecInPage("TermoMenor")
	EndIf

WEB EXTENDED END

Return cHtml
