#INCLUDE "APWEBEX.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PPLMFUN.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "TBICONN.CH"

Static cAuthWS := Nil

/*/{Protheus.doc} PPLTPCHM
Chamada do menu consulta ou sadt
@author PLSTEAM
@since 07.03.2007
/*/
Web Function PPLTPCHM()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

// Verificar permissão de acesso do botao internados
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:CcUsr		:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE

HttpSession->cBtIntern := ""

If oObj:VALACEBOT()
	If LEN(oObj:OWSVALACEBOTRESULT:OWSSUSUARIO) > 0
		HttpSession->cBtIntern := oObj:OWSVALACEBOTRESULT:OWSSUSUARIO[1]:CPERMITE
	EndIf
EndIf

//Define o tipo de entrada de dados
If ValType(HttpSession->cTipCar) == 'U'
	If HttpSession->USR_INFO[1]:OWSUSERLOGPLS:cTipCar == '1'
		HttpSession->cTipCar := "1"
	Else
		HttpSession->cTipCar := "0"
	EndIf
EndIf

//Tipo de pre-atendimento se vai pre-atender ou atender (executar)
HttpSession->cTpPreAte := "0"
HttpSession->cBtInterna:= "0"

//Mostra a pagina para entrar com a matricula
cHtml := ExecInPage( "PPLCARTMAT" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLSTIPCAR
Alimenta variavel de sessao
@author PLSTEAM
@since 07.03.2007
/*/
Web Function PPLSTIPCAR()
LOCAL cResult := "true"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//Define o tipo de entrada de dados
HttpSession->cTipCar := HttpGet->cTipCar

WEB EXTENDED END

getLOGMon()

Return cResult

/*/{Protheus.doc} PPLSDADUSR
Carrega dados do usuario e envia para consulta ou sadt
@author PLSTEAM
@since 07.03.2007
/*/
Web Function PPLSDADUSR()
LOCAL nI			:= 0
LOCAL oObj			:= nil
LOCAL nPos			:= 0
LOCAL cResult 		:= ""
LOCAL cSepara1 		:= ""
LOCAL cSepara2 		:= ""
LOCAL cSepara3 		:= ""
LOCAL cNomeCartao 	:= ""
LOCAL cViaCartao 	:= ""
LOCAL cNumCartao 	:= ""
LOCAL cDtValid 		:= ""
LOCAL cLocalCob		:= ""
LOCAL cProduto		:= ""
LOCAL cAbrange		:= ""
LOCAL cNatJuri		:= ""
LOCAL aCartao 		:= {}
LOCAL aMatrCartao 	:= {}
LOCAL cResultInc    := "" //variavel usada para pegar o retorno da inclusão na grid quando o pre atendimento for no atendimento
LOCAL lDigiRetro	:= .T.
LOCAL CDATALIMIT	:= ""
local cCodLdp 		:= ""
LOCAL cHtml 		:= ""
Local nTmpIni 		:= Seconds()
LOCAL cTrilhaCar := ""

WEB EXTENDED INIT cHtml START "InSite"

//Guarda a trilha informada
If At( "_pntItrrog_", HttpGet->TrilhaCard ) > 0
	HttpGet->TrilhaCard := StrTran( HttpGet->TrilhaCard, "_pntItrrog_", "?" )
EndIf

If At( "_pntmod_", HttpGet->TrilhaCard ) > 0
	HttpGet->TrilhaCard := StrTran( HttpGet->TrilhaCard, "_pntmod_", "%" )
EndIf

If At( "_2pnt_", HttpGet->TrilhaCard ) > 0
	HttpGet->TrilhaCard := StrTran( HttpGet->TrilhaCard, "_2pnt_", ":" )
EndIf

If At( "_pntundf_", HttpGet->TrilhaCard ) > 0
	HttpGet->TrilhaCard := StrTran( HttpGet->TrilhaCard, "_pntundf_", "ç" )
EndIf

HttpSession->TrilhaCard := HttpGet->TrilhaCard

cTrilhaCar := HttpGet->TrilhaCard

//Verifica se o usuário possui permissão para digitar guia retroativa no portal
If ValType(HttpGet->lDigiRetro) <> "U" .and. (HttpGet->lDigiRetro == "true")

	//Chamar função para verificar se o usuário tem permissão
	oObj := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLSXFUN.APW" )

	oObj:cUSERCODE			:= "MSALPHA"
	oObj:cRDACode			:= HttpGet->cRda
	oObj:cCodLoc			:= HttpGet->cCodLoc
	oObj:cCUsr			 	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
	oObj:cUserCardNumber 	:= HttpGet->TrilhaCard
	oObj:cDatGuia		    := HttpGet->dDtaAtd
	oObj:cTriCar			:= cTrilhaCar

	//Verificar se existe calendário de pagamento cadastrado para essa RDA e localidade
	If oObj:GETCALEND() .and. !Empty(oObj:cGETCALENDRESULT)

		If oObj:GETDIARETRO() .and. !("false" $ oObj:CGETDIARETRORESULT)
			cDataLimit := oObj:CGETDIARETRORESULT
		Else
			cResult 	:= oObj:CGETDIARETRORESULT
			lDigiRetro 	:= .F.
		EndIf

	Else
		cResult := "false|Não há calendário cadastrado, entre em contato com a operadora."
		lDigiRetro := .F.
	EndIf

	//Como pode ser informado tanto o número da carteirinha
	//quanto o número da matrícula (BA1_MATEMP),
	//verificamos nesse ponto se o número informado é de matrícula (isto é, se for encontrado BA1_MATEMP).
	//Caso positivo, substituimos o número pela carteirinha para validação.
	//Caso negativo, continua com o número informado.
	If lDigiRetro .and. oObj:VLDBA1MATEMP()

		If !Empty(oObj:cVLDBA1MATEMPRESULT)
			HttpGet->TrilhaCard 		:= oObj:cVLDBA1MATEMPRESULT
			HttpSession->TrilhaCard 	:= HttpGet->TrilhaCard
		EndIf

	EndIf

	if oObj:GETDIGP()

		cCodLdp := oObj:cGETDIGPRESULT

		if alltrim(cCodLdp) = ""
			cResult 	:= "false|O parâmetro MV_PLSDIGP não está configurado, entre em contato com a operadora."
			lDigiRetro 	:= .F.
		else
			if alltrim(cCodLdp) = "9999"
				cResult 	:= "false|O parâmetro MV_PLSDIGP está configurado de forma errada (Valor: 9999), entre em contato com a operadora."
				lDigiRetro 	:= .F.
			endif
		endif

	endif

EndIf

If lDigiRetro

	//Guardo a data de atendimento informada na digitação de guias
	HttpSession->dDtaAtend := HttpGet->dDtaAtd

	//Atenção, ajuste realizado pois a matrícula antiga pode ser menor que 16 caracteres
	if !Empty(HttpGet->TrilhaCard) .and. Len(HttpGet->TrilhaCard) < 16
		HttpGet->TrilhaCard := HttpGet->TrilhaCard + Space(16 - Len(HttpGet->TrilhaCard))
	endif


	If Len(HttpGet->TrilhaCard) >= 16 .Or. ! HttpSession->lUnimeds

		// Para ponto de entrada tratamento das trilhas de carcao
		If HttpSession->lPLSCARD

			aMatrCartao := ExecBlock("PLSCARD",.F.,.F.,{HttpGet->TrilhaCard,HttpSession->cTipCar})

			If Len(aMatrCartao) > 0 .And. Empty(aMatrCartao[9])
				cNumCartao 	:= aMatrCartao[1]
				cNomeCartao := aMatrCartao[2]
				cViaCartao 	:= aMatrCartao[3]
				cDtValid 	:= aMatrCartao[4]
				cLocalCob	:= aMatrCartao[5]
				cProduto	:= aMatrCartao[6]
				cAbrange	:= aMatrCartao[7]
				cNatJuri	:= aMatrCartao[8]
				cMsgErro	:= aMatrCartao[9]
			Else

				If Empty(aMatrCartao[9])
					cResult := "false|Passe o cartao novamente"
				Else
					cResult := "false|"+aMatrCartao[9]
				EndIf

			EndIf

		Else

			// Valida trilha
			HttpGet->TrilhaCard := Upper(HttpGet->TrilhaCard)
			nPos := At( ":", HttpGet->TrilhaCard )
			If nPos > 0
				HttpGet->TrilhaCard := Upper(SubStr(HttpGet->TrilhaCard,1,nPos))+'ç'+SubStr( HttpGet->TrilhaCard,(nPos+2),Len(HttpGet->TrilhaCard) )
			EndIf

			// Case

			Do Case
				Case At( "?", HttpGet->TrilhaCard ) > 0
					cSepara1 := "?"
					cSepara2 := "%"
					cSepara3 := ";"
				Case At( ":", HttpGet->TrilhaCard ) > 0
					cSepara1 := ":"
					cSepara2 := "%"
					cSepara3 := "ç"
			EndCase

			// Separa

			If ! Empty( cSepara1 )

				aCartao := Separa( HttpGet->TrilhaCard, cSepara1 )

				If Empty(aCartao) .Or. Len(aCartao) < 2
					cResult := "false|Passe o cartao novamente"
				EndIf

				// Tratamento matriz cartao

				aMatrCartao := Separa( SubStr( aCartao[2], At( cSepara3, aCartao[2] ) + 1 ), "=" )

				If Empty(aMatrCartao) .Or. Len(aMatrCartao) < 3
					cResult := "false|Passe o cartao novamente"
				EndIf

				// Pega os valores

				If Empty(cResult)
					cNumCartao 	:= aMatrCartao[1]
					cViaCartao 	:= SubStr( aMatrCartao[2], 1, 2 )
					cDtValid 	:= SubStr( aMatrCartao[2], 3, 4 )
					cLocalCob	:= SubStr( aMatrCartao[3], 1, 4 )
					cProduto	:= SubStr( aMatrCartao[3], 5, 3 )
					cAbrange	:= SubStr( aMatrCartao[3], 8, 1 )
					cNatJuri	:= SubStr( aMatrCartao[3], 9, 1 )
					cNomeCartao := PLSDECODE(aCartao[1])
					cNomeCartao := StrTran(cNomeCartao,"%","")

				EndIf
			Else
				cNumCartao := HttpGet->TrilhaCard

				// Verifica se existe alfa na scrintg
				If HttpSession->lUnimeds

					For nI:=1 To Len(AllTrim(HttpGet->TrilhaCard))

						lOk := IsAlpha(StrTPLS(SubStr(HttpGet->TrilhaCard,	nI,1)))

						If lOk
							cResult := "false|Conteudo invalido"
						EndIf

					Next

				EndIf

			EndIf

		EndIf

		// se nao tiver critica
		If Empty(cResult)

			// Valida a Data da Validade Carteirinha
			If ! Empty(cDtValid) .And. cDtValid < Substr(StrZero(Year(Date()),4),3,2)+StrZero( Month( Date() ),2)
				cResult := "false|Data de validade do cartão vencida"
			Else

				// obj

				oObj := WSPLSXFUN():New()
				IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
				WsChgURL( @oObj, "PLSXFUN.APW" )

				// Parametros

				oObj:cUSERCODE			:= "MSALPHA"
				oObj:cUSERCARDNUMBER	:= cNumCartao
				oObj:cUSERCARDNAME	    := cNomeCartao
				oObj:cLocalExec			:= "1"
				oObj:cAreaAbr			:= cAbrange
				oObj:cUserCardEdition   := cViaCartao
				oObj:cDatGuia		    := HttpGet->dDtaAtd
				oObj:cTriCar			:= cTrilhaCar
				If ValType(HttpGet->lBloqGui) <> "U"
					oObj:LBLOQGUI		:= iif ("true" $ HttpGet->lBloqGui,.T.,.F.)
				Endif


				// Executa o metodo

				If oObj:USERCARDVALIDATION()

					// Verifica se teve critica

					If Len(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI) == 0

						// Nome do cartao

						If Empty(cNomeCartao)
							cNomeCartao := WTDecode(oObj:oWSUSERCARDVALIDATIONRESULT:cCARDNAME)
						EndIf

						// Validade

						If Empty(cDtValid)
							cDtValid := DToS(oObj:oWSUSERCARDVALIDATIONRESULT:dValCar)
						EndIf

						// Produto

						If Empty(cProduto)
							cProduto := oObj:oWSUSERCARDVALIDATIONRESULT:cPlano
						EndIf

						// Matriz de sessao

						HttpSession->aVldCartao := {	cNomeCartao,;										//01
							oObj:oWSUSERCARDVALIDATIONRESULT:cCardNumber,;		//02
							cViaCartao,;										//03
							cDtValid,;											//04
							cLocalCob,;											//05
							cProduto,;											//06
							cAbrange,;											//07
							cNatJuri,;											//08
							oObj:oWSUSERCARDVALIDATIONRESULT:cNumCarNac,;		//09
							oObj:oWSUSERCARDVALIDATIONRESULT:lInterchange,;		//10
							oObj:oWSUSERCARDVALIDATIONRESULT:cCardNumberOld,;	//11
							oObj:oWSUSERCARDVALIDATIONRESULT:cTelefone,;		//12
							oObj:oWSUSERCARDVALIDATIONRESULT:cNomTit,;			//13
							oObj:oWSUSERCARDVALIDATIONRESULT:cNomEmp,;			//14
							oObj:oWSUSERCARDVALIDATIONRESULT:cVida,;			//15
							oObj:oWSUSERCARDVALIDATIONRESULT:cDig1,;			//16
							oObj:oWSUSERCARDVALIDATIONRESULT:cDig2,;			//17
							oObj:oWSUSERCARDVALIDATIONRESULT:cTpAcom,;			//18
							oObj:oWSUSERCARDVALIDATIONRESULT:cPadCon,;			//19
							oObj:oWSUSERCARDVALIDATIONRESULT:cDesAcom,;			//20
							oObj:oWSUSERCARDVALIDATIONRESULT:cNomSocBn}			//21

						// Carrega para o determinado formulario consulta,sadt etc

						If Valtype(HttpSession->USR_INFO) != "U"
							If HttpSession->USR_INFO[1]:OWSUSERLOGPLS:cBiometria == '1' .And. (!oObj:oWSUSERCARDVALIDATIONRESULT:lInterchange .Or. oObj:oWSUSERCARDVALIDATIONRESULT:lChkBioInter)

								// Form da biometria
								cDigital := oObj:oWSUSERCARDVALIDATIONRESULT:cDig1+oObj:oWSUSERCARDVALIDATIONRESULT:cDig2

								//Ponto de entrada que habilita a biometria via portal.
								If HttpSession->lPPLBiomet

									If ExecBlock('PPLBiomet',.F.,.F.,{cNumCartao})
										cResult := "true|S|" + AllTrim( Iif( Empty( cDigital ),'1','2' ) )+'|'+cDigital+'|'+HttpSession->USR_INFO[1]:OWSUSERLOGPLS:cBiometriaCad+'|'+'Biometria'
									Else
										cResult := "true|N"
									Endif

								Else
									cResult := "true|S|" + AllTrim( Iif( Empty( cDigital ),'1','2' ) )+'|'+cDigital+'|'+HttpSession->USR_INFO[1]:OWSUSERLOGPLS:cBiometriaCad+'|'+'Biometria'
								EndIf

							Else
								cResult := "true|N"
							EndIf

						Else
							cResult := "true|N"
						Endif

					Else


						// valida se permite continuar pre-atendimento mesmo com critica

						If HttpSession->cBtInterna == "1"

							If !oObj:oWSUSERCARDVALIDATIONRESULT:lCritPreAtdm
								cResult := "false|"
							Else

								If Empty(cNomeCartao)
									cNomeCartao := WTDecode(oObj:oWSUSERCARDVALIDATIONRESULT:cCARDNAME)
								EndIf

								// Validade

								If Empty(cDtValid)
									cDtValid := DToS(oObj:oWSUSERCARDVALIDATIONRESULT:dValCar)
								EndIf

								// Produto

								If Empty(cProduto)
									cProduto := oObj:oWSUSERCARDVALIDATIONRESULT:cPlano
								EndIf

								// Matriz de sessao

								HttpSession->aVldCartao := {	cNomeCartao,;										//01
									oObj:oWSUSERCARDVALIDATIONRESULT:cCardNumber,;		//02
									cViaCartao,;										//03
									cDtValid,;											//04
									cLocalCob,;											//05
									cProduto,;											//06
									cAbrange,;											//07
									cNatJuri,;											//08
									oObj:oWSUSERCARDVALIDATIONRESULT:cNumCarNac,;		//09
									oObj:oWSUSERCARDVALIDATIONRESULT:lInterchange,;		//10
									oObj:oWSUSERCARDVALIDATIONRESULT:cCardNumberOld,;	//11
									oObj:oWSUSERCARDVALIDATIONRESULT:cTelefone,;		//12
									oObj:oWSUSERCARDVALIDATIONRESULT:cNomTit,;			//13
									oObj:oWSUSERCARDVALIDATIONRESULT:cNomEmp,;			//14
									oObj:oWSUSERCARDVALIDATIONRESULT:cVida,;			//15
									oObj:oWSUSERCARDVALIDATIONRESULT:cDig1,;			//16
									oObj:oWSUSERCARDVALIDATIONRESULT:cDig2,;			//17
									oObj:oWSUSERCARDVALIDATIONRESULT:cTpAcom,;			//18
									oObj:oWSUSERCARDVALIDATIONRESULT:cPadCon,;			//19
									oObj:oWSUSERCARDVALIDATIONRESULT:cDesAcom,;			//20
									oObj:oWSUSERCARDVALIDATIONRESULT:cNomSocBn}			//21


								cResult := "true|T|"

							EndIf

							For nI := 1 To Len(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI)
								If !Empty(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI[nI]:CDESPRI)

									If !oObj:oWSUSERCARDVALIDATIONRESULT:lCritPreAtdm
										cResult += AllTrim(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI[nI]:CDESPRI)+" - "+AllTrim(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI[nI]:CDESSEQ)+Chr(13)
									Else
										cResult += AllTrim(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI[nI]:CDESPRI)+" - "+AllTrim(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI[nI]:CDESSEQ)+Chr(13) + "|"
									EndIf
								EndIf
							Next
						Else
							cResult := "false|"
							For nI := 1 To Len(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI)
								If !Empty(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI[nI]:CDESPRI)
									cResult += AllTrim(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI[nI]:CDESPRI)+" - "+AllTrim(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI[nI]:CDESSEQ)+AllTrim(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI[nI]:CDESTER)+Chr(13)
								EndIf
							Next
						EndIf
					EndIf
				Else
					cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
				EndIf
			EndIf
		EndIf
	Else
		cResult := "false|Matricula invalida"
	EndIf
EndIf

if "true" $ cResult

	// Para ponto de entrada para validacoes complementares apos as validacoes  padroes
	if HttpSession->lPLSVLDC
		cResult := ExecBlock("PLSVLDC",.F.,.F.,{HttpGet->TrilhaCard,HttpSession->cTipCar,aMatrCartao,cResult})
	endif

	// Verifica se é preatendimento no atendimento
	if ValType(HttpGet->lPreAten) <> "U" .AND. HttpGet->lPreAten == "true"

		//eu atribui os valores direto no HttpGet porque a função que é chamada dentro do W_PPLENVPRT() usa o HttpGet, já que ela era
		//usada dentro da função de pre atendimento antiga
		HttpGet->cMatric 	:= oObj:oWSUSERCARDVALIDATIONRESULT:cCardNumber
		HttpGet->cNomeUsu 	:= alltrim(cNomeCartao)

		if !("true|S" $ cResult) .OR. ("Biometria" $ cResult) //se não precisa validar a biometria eu prossigo  //Identificar o processo de Biometria na tela de Atendimento

			cResult = StrTran(cResult, "Biometria", "")
			cResultInc := W_PPLENVPRT()

			if "false" $ cResultInc
				cResult := cResultInc
			else
				//separador do result deste metodo com o do W_PPLENVPRT
				cResultInc :=  substr(cResultInc, 6, len(alltrim(cResultInc)))
				cResult += "#" + cResultInc
			endif

		endif

	else
		HttpSession->cBtInterna := "0"
	endif

	If ValType(cDataLimit) <> "U" .and. ! Empty(cDataLimit)
		//Adiciona data limite, caso possua
		cResult += "@" + cDataLimit
	EndIf
endif

WEB EXTENDED END

//Mostra o tempo que durou pra confirmar o atendimento
if httpSession->lTimeAte

	oObjPar := WSCFGDICTIONARY():New()
	IIf (!Empty(PlsGetAuth()),oObjPar:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObjPar, "CFGDICTIONARY.APW" )

	oObjPar:cMsgLog  := "1) " + Time()+ "|" + Alltrim(Str(Seconds() - nTmpIni)) + "|" + HttpGet->cRDA
	oObjPar:cFileLog := "PreAtendimento.txt"
	oObjPar:PutPLSLogFil()

endIf

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLENVFOR
 Alimenta Sessions rda e envia pra tela de consulta ou sadt
@author PLSTEAM
@since 07.03.2007
/*/
Web Function PPLENVFOR()
LOCAL cHtml		:= ""
LOCAL cCookie 	:= ""
PRIVATE lPreAten := .t.

WEB EXTENDED INIT cHtml START "InSite"

//Define se vai mostrar o botao voltar na impressao da guia
HttpSession->cBVolt := "0"

cCookie := HttpCookies->SIGAPLS

if ! HttpSession->lCombo
	Return PPLSALERT( "", "Atenção", "", "W_PPLENVFOR.APW" )
endIf

//Verifica se tem RdMake compilado para tratamento no botao confirmar
If  HttpSession->lPPLREGBTN
	HttpSession->ExisRegEsp := '1'
Else
	HttpSession->ExisRegEsp := '0'
EndIf

//Chama formulario de pre-atendimento
cHtml += ExecInPage("PPLMOSPRE")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLENVPRT
Alimenta Sessions rda e envia pra tela de consulta ou sadt
@author PLSTEAM
@since 07.03.2007
/*/
Web Function PPLENVPRT()
LOCAL cHtml	  := ""
LOCAL cCookie := ""
PRIVATE lPreAten := .T.

WEB EXTENDED INIT cHtml START "InSite"

//Define se vai mostrar o botao voltar na impressao da guia
HttpSession->cBVolt := "0"

//Biscoito
cCookie := HttpCookies->SIGAPLS

if !HttpSession->lCombo
	Return PPLSALERT( "", "Atenção", "", "W_PPLENVPRT.APW" )
endIf

//Verifica se tem RdMake compilado para tratamento no botao confirmar
If HttpSession->lPPLREGBTN
	HttpSession->ExisRegEsp := '1'
Else
	HttpSession->ExisRegEsp := '0'
EndIf

WEB EXTENDED END

getLOGMon()

Return W_PPLTRAPRE()

/*/{Protheus.doc} PPLCHABIO
Chama o formulario da biometria
@author PLSTEAM
@since 07.03.2007
/*/
Web Function PPLCHABIO()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//Chama formulario

cHtml += ExecInPage("PPLMOSBIO")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLINCBIO
Chama o formulario da biometria
@author PLSTEAM
@since 07.03.2007
/*/
Web Function PPLINCBIO()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXINC():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXINC.APW" )

// Processa a guia
oObj:cUSERCODE				:= "MSALPHA"					//Usuario
oObj:OWSINCMATBIO:cVida 	:= HttpSession->aVldCartao[15]	//Vida
oObj:OWSINCMATBIO:cAlias	:= 'BTS'						//Alias
oObj:OWSINCMATBIO:cDig		:= HttpGet->cDedo				//Digital (Dedo)
oObj:OWSINCMATBIO:cDig1		:= StrTran( HttpGet->cDig1," ","+" )//String biometrica 1
oObj:OWSINCMATBIO:cDig2		:= StrTran( HttpGet->cDig2," ","+" )//String biometrica 2

// Processa Guia
If oObj:IncBio()
	cResult :=  oObj:CINCBIORESULT
Else
	cResult :=  "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLATEUSU
Carrega dados do usuario solicitacao de atendimento
@author PLSTEAM
@since 07/2016
@version P12
/*/
Web Function PPLATEUSU()
LOCAL nI
LOCAL oObj
LOCAL cResult 		:= ""
LOCAL cMsnBloqInt	:= ""
LOCAL cHtml 		:= ""
LOCAL cTipGui 		:= ""
LOCAL cCodUsr 		:= ""
LOCAL cCodRda 		:= ""
LOCAL cGuiRef 		:= ""
LOCAL cMatric 		:= ""
LOCAL cDatGui 		:= ""

WEB EXTENDED INIT cHtml START "InSite"


// obj

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUSERCODE		 := "MSALPHA"
oObj:cUSERCARDNUMBER := StrTran(StrTran(HttpGet->cMatric,".",""),"-","")
oObj:cUSERCARDNAME	 := HttpGet->cNomeUsu
oObj:cRdaCode	 	 := HttpGet->cRda
oObj:cCodLoc	 	 := HttpGet->cCodLoc
oObj:cTipAtd		 := HttpGet->cTpAte

// Executa o metodo

If oObj:USERCARDVALIDATION()

	// Verifica se teve critica

	If Len(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI) == 0

		// Matriz de sessao

		HttpSession->aVldCartao := {	oObj:oWSUSERCARDVALIDATIONRESULT:cCARDNAME,;				//1
			oObj:oWSUSERCARDVALIDATIONRESULT:cCardNumber,;		   		//2
			AllTrim(Str(oObj:oWSUSERCARDVALIDATIONRESULT:nViaCartao)),;//3
			DToS(oObj:oWSUSERCARDVALIDATIONRESULT:dValCar),;   			//4
			oObj:oWSUSERCARDVALIDATIONRESULT:cLocalCob,;				//5
			oObj:oWSUSERCARDVALIDATIONRESULT:cPlano,;		   			//6
			oObj:oWSUSERCARDVALIDATIONRESULT:cAbrange,;		   			//7
			oObj:oWSUSERCARDVALIDATIONRESULT:cNatJuri,;		   			//8
			oObj:oWSUSERCARDVALIDATIONRESULT:cNumCarNac,;	   			//9
			oObj:oWSUSERCARDVALIDATIONRESULT:lInterchange,;				//10
			oObj:oWSUSERCARDVALIDATIONRESULT:cCardNumberOld,;	   		//11
			oObj:oWSUSERCARDVALIDATIONRESULT:cTelefone,;   				//12
			oObj:oWSUSERCARDVALIDATIONRESULT:cNomTit,;                 	//13
			oObj:oWSUSERCARDVALIDATIONRESULT:cNomEmp,;                 	//14
			oObj:oWSUSERCARDVALIDATIONRESULT:cVida,;					//15
			oObj:oWSUSERCARDVALIDATIONRESULT:cDig1,;					//16
			oObj:oWSUSERCARDVALIDATIONRESULT:cDig2,;					//17
			oObj:oWSUSERCARDVALIDATIONRESULT:cTpAcom,;					//18
			oObj:oWSUSERCARDVALIDATIONRESULT:cPadCon,;					//19
			oObj:oWSUSERCARDVALIDATIONRESULT:cDesAcom,;					//20
			oObj:oWSUSERCARDVALIDATIONRESULT:cNomSocBn}					//21

		// Lista de profissional de saude

		If ValType(oObj:oWSUSERCARDVALIDATIONRESULT:cMsnBloInter) == "C"
			cMsnBloqInt := oObj:oWSUSERCARDVALIDATIONRESULT:cMsnBloInter
		Endif

		HttpSession->cMsnBloInt := cMsnBloqInt

		HttpSession->PROSAUD := {}

		If ! HttpGet->cTpAte $ "1,2,3,4" //Tipo de Guia

			If oObj:ProfSaud()

				HttpSession->PROSAUD := oObj:OWSPROFSAUDRESULT:OWSLISTPROFSAUD:oWSPROFSAUD

				If ValType(oObj:OWSPROFSAUDRESULT:OWSLISTPFSEXE:oWSPROFSAUD) <> "U" .And. Len(oObj:OWSPROFSAUDRESULT:OWSLISTPFSEXE:oWSPROFSAUD) > 0
					HttpSession->PROSAUDEXE := oObj:OWSPROFSAUDRESULT:OWSLISTPFSEXE:oWSPROFSAUD
				EndIF
			Else
				cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
			EndIf
		EndIf

		// Verifica se e fisica ou juridica quando solicitado consulta

		If HttpGet->cTpAte == "1"
			nPosRDA := aScan( HttpSession->RDAVIEW, { |x| x:cCODE == HttpGet->cRda .And. x:cCodLoc == HttpGet->cCodLoc} )
		EndIf

		// Carrega para o determinado formulario consulta,sadt etc

		If Empty(cResult)
			If  !(Empty(cMsnBloqInt)) .and.  (HttpGet->cTpAte == "2" .OR. HttpGet->cTpAte == "4" )
				cResult :=  "true|W_PPLCHAATE.APW" + "|" + HttpSession->cMsnBloInt
			else

				cResult := "true|W_PPLCHAATE.APW|"
			EndIF
		EndIf
	Else
		cResult := "false|"
		For nI := 1 To Len(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI)
			If !Empty(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI[nI]:CDESPRI)
				cResult += AllTrim(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI[nI]:CDESPRI)+" - "+AllTrim(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI[1]:CDESSEQ)+Chr(13)
			EndIf
		Next
	EndIf

	//Gravo os atributos necessarios para o metodo 'isDupGui'
	cTipGui := if(HttpGet->cTpAte == "4","13",HttpGet->cTpAte)
	cCodUsr := oObj:cUserCode
	cCodRda := oObj:cRdaCode
	cGuiRef := ""
	cMatric := HttpGet->cMatric
	cDatGui := DtoS(Date())

	// Parametros para retornar se a guia eh duplicada
	oObj:cUserCode			:= cCodUsr
	oObj:cRdaCode			:= cCodRda
	oObj:cTipGui			:= cTipGui
	oObj:cUserCardNumber	:= cMatric
	oObj:cNumGuiRef			:= cGuiRef
	oObj:cDatGuia		 	:= cDatGui

	// Verifica se a guia pode estar sendo duplicada
	if oObj:isDupGui()
		cResult += "|" + SubStr(oObj:cIsDupGuiRESULT,6)
	endif

Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCHAATE
Chama determinado formulario do atendimento
@author PLSTEAM
@since 07/2016
@version P12
/*/
Web Function PPLCHAATE()
LOCAL cHtml 		:= ""
LOCAL oObj	    	:= nil
LOCAL nPosRda		:= 0
LOCAL cTISSVer		:= ""
LOCAL cRda			:= ""
LOCAL cCodLoc		:= ""
LOCAL aRDA			:= {}
LOCAL nI			:= 0
LOCAL nY			:= 0
LOCAL cResult		:= ""
Local cDigiGui		:= IIF(ValType(HttpGet->cDigiGui  ) == "C", AllTrim(HttpGet->cDigiGui  ) , "")
Local cNumGuiRef	:= IIF(ValType(HttpGet->cNumGuiRef) == "C", AllTrim(HttpGet->cNumGuiRef) , "")
Local cTpGuiRef  	:= IIF(ValType(HttpGet->cTpGuiRef ) == "C", AllTrim(HttpGet->cTpGuiRef ) , "")
Local cRecGuiRef 	:= IIF(ValType(HttpGet->cRecGuiRef) == "C", AllTrim(HttpGet->cRecGuiRef) , "")
Local lAltCpAUT		:= IIF (ValType(HttpGet->cTipAltG) == "C" .and. HttpGet->cTipAltG == "AltCmp", .T., .F.)
Local cRecnoBD5 	:= IIF(ValType(HttpGet->cRecnoBD5) == "C", AllTrim(HttpGet->cRecnoBD5) , "")

WEB EXTENDED INIT cHtml START "InSite"

// Aliemnta variavel de sessao
HttpSession->cTp := HttpGet->cTp

// Recupera a RDA e sua versão TISS
cRda 	:= HttpGet->cRda
cCodLoc := HttpGet->cCodLoc

//para achar a versao da tiss precisa sempre olhar só o codigo da rda, o codloc não precisa mas somente nesse caso
nPosRDA := aScan( HttpSession->RDAVIEW, { |x| x:cCODE == cRda } )
If nPosRDA > 0
	aRDA := ClassDataArr(HttpSession->RDAVIEW[nPosRDA])
Endif

If aScan(aRDA,{|x| AllTrim(x[1]) == "CTISSVER"  }) > 0
	cTISSVer := HttpSession->RDAVIEW[nPosRDA]:cTissVer
EndIf

HttpSession->cTISSVer := cTISSVer

//Obj
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametro
oObj:cUSERCODE	:= "MSALPHA"
oObj:cTipo 		:= HttpSession->cTp

// Alimenta a dados especifico por tipo de guia
If oObj:GetDadG()

	Do Case
		//Internacao
		Case HttpSession->cTp == "3"

			HttpSession->RDASOLT := oObj:oWSGetDadGRESULT:oWSDADRDATP:oWSMSDADRDA

			//ODontologico
		Case HttpSession->cTp == "4"

			HttpSession->cCodPad := oObj:oWSGetDadGRESULT:cCodPad
	EndCase

Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLENVFOR.APW" )
EndIf

// Ponto de Entrada que define os campos obrigatorios a mais na GUia

HttpSession->cObrCpGuia := ""

If HttpSession->lPLSCPGUI
	HttpSession->cObrCpGuia := execBlock('PLSCPGUI',.F.,.F.,{HttpSession->cTp})
EndIf

//Indicacao dos tipos de formularios a terem o botao complemento habilitado no portal 1=Cons 2=SADT 3=GIH e 4=Odonto
if HttpSession->lPLSCMPFP

	if ! empty(HttpSession->cPLCMPFP) .and. HttpSession->cTp $ HttpSession->cPLCMPFP
		HttpSession->cCmpl := HttpSession->cPLCMPFP
	endIf

endIf

//Digitação de Guias
oObj:cDigigui	:= cDigigui
oObj:cRECNOBD5  := cRecnoBD5
oObj:cTipo 		:= iIf( Empty( HttpGet->cTipoOrigem ), "", HttpGet->cTipoOrigem)

If !(EmpTy(oObj:Ctipo)) //Tratamentos específicos da digitação de guias

	oObj:cRdaCode	:= HttpGet->cRda
	oObj:cCodLoc	:= HttpGet->cCodLoc

	If !HttpSession->cTp $ "1,2,3,4,5,11,12,6"

		If oObj:ProfSaud()
			HttpSession->PROSAUD := oObj:oWSPROFSAUDRESULT:OWSLISTPROFSAUD:oWSPROFSAUD
		EndIf

	EndIf

EndIf

if lAltCpAUT

	// Parametros
	oObj:cRdaCode	:= HttpGet->cRda
	oObj:cCodLoc	:= HttpGet->cCodLoc

	// Lista de profissional de saude
	If !HttpSession->cTp $ "1,2,3,4,5,11,12,6"

		If oObj:ProfSaud()
			HttpSession->PROSAUD := oObj:oWSPROFSAUDRESULT:OWSLISTPROFSAUD:oWSPROFSAUD
		EndIf

	endIf

endIf

// CRIAR PAGINA PARA TISS 3.0
If cTissVer >= "3"

	// Parametros
	oObj:oWSGUIATISS:cTipGui	:= strZero(val(HttpSession->cTp),2)
	oObj:oWSGUIATISS:cVerTiss	:= cTISSVer

	// Aqui eu pego o que vem de Session executo aqui pra enviar a informaçao
	// pro WS pois o mesmo nao acessa o conteudo da Session	dificultando o dinamismo

	If oObj:GetCmbFormT()

		// ATRIBUO OS PARAMETROS NOVAMENTE PARA UTILIZAÇÃO DO PROXIMO METODO
		oObj:oWSGUIATISS:cTipGui	:= strZero(val(HttpSession->cTp),2)
		oObj:oWSGUIATISS:cVerTiss	:= cTISSVer
		oObj:oWSGUIATISS:cDadCombo	:= ""

		If Len(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA) > 0

			For nI := 1 To Len(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA)

				cStrCBOX := ""

				// Se for uma Session eu pego CCODE e CNAME e monto o Combo
				If "HTTPSESSION" $ Upper(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX)

					If ValType(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX)) <> 'U'

						For nY := 1 To Len(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX))
							cStrCBOX += Alltrim(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX + "[" + Alltrim(Str(nY)) + "]:cCODE")) + "=" + Alltrim(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX + "[" + Alltrim(Str(nY)) + "]:cNAME")) + ";"
						Next nY

					EndIf

					If nY > 2
						cStrCBOX += ";="
					EndIf

					// Caso contrario eu pego a STRING com mesma estrutura do X3_COBX
				Else
					cStrCBOX := Alltrim(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX)
				EndIf

				If SubStr(cStrCBOX, Len(cStrCBOX),1) == ";"
					cStrCBOX := SubStr(cStrCBOX, 1, Len(cStrCBOX)-1)
				EndIf

				oObj:oWSGUIATISS:cDadCombo	+= Alltrim(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCampoG) + ";" + cStrCBOX + "|"

			Next

		EndIf

	EndIf

	If SubStr(oObj:oWSGUIATISS:cDadCombo, Len(oObj:oWSGUIATISS:cDadCombo),1) == "|"
		oObj:oWSGUIATISS:cDadCombo := SubStr(oObj:oWSGUIATISS:cDadCombo, 1, Len(oObj:oWSGUIATISS:cDadCombo)-1)
	EndIf

	//Alimenta tipo de guia, se é modo de edição com a query string passada por parâmetro e data limite para inclusão da data
	//Se alteração estiver preenchido e digiguia não, garanto que não é da digitação de contas off e sim da autorização
	IF (lAltCpAUT .and. Empty(cDigiGui))
		oObj:cTipo		:= "AltCmp|" + AllTrim(StrTran(StrTran(HttpGet->cNumGOB,".",""),"-","")) + '|' + HttpGet->cTp
	ELSEIF (lAltCpAUT .and. !Empty(cDigiGui))
		oObj:cTipo		:= "AltCmp|" + IIF(Empty(HttpGet->cTipoOrigem),"",HttpGet->cTipoOrigem)
	ELSE
		oObj:cTipo		:= IIF(Empty(HttpGet->cTipoOrigem),"",HttpGet->cTipoOrigem)
	ENDIF

	oObj:ccRecno 		:= IIF(Empty(HttpGet->cNumGuia),"",HttpGet->cNumGuia)
	oObj:cDtLimRetro 	:= IIF(Empty(HttpGet->dDtLimRetro),"",HttpGet->dDtLimRetro)

	// Retorna dados da pagina

	oObj:cMsnBloInter	:= HttpSession->cMsnBloInt
	oObj:cDigigui		:= cDigigui
	oObj:cNumGuiRef 	:= cNumGuiRef
	oObj:cTpGuiRef   	:= cTpGuiRef
	oObj:cRecGuiRef  	:= cRecGuiRef
	oObj:lAltCpAT		:= lAltCpAUT

	//Adiciona data da guia SADT na inclusão de outras despesas
	if (HttpSession->cTp == "12")
		HttpSession->cDatAtd	:= IIF(Empty(HttpGet->cDatAtd),"",HttpGet->cDatAtd)
	endif

	If ValType(HttpSession->aVldCartao) == 'A'
		oObj:lIntercambio := HttpSession->aVldCartao[10]
	Else
		oObj:lIntercambio := .F.
	EndIf

	HttpSession->cDigitacao := cDigigui
	oObj:cRECNOBD5   		:= cRecnoBD5
	oObj:cDtJs 				:= iif(valtype(HttpSession->cDtJs) <> 'U', HttpSession->cDtJs, "")

	If oObj:GetFormTiss()

		cResult :=  oObj:OWSGETFORMTISSRESULT:cPagina

		If ValType(oObj:OWSGETFORMTISSRESULT:cGrids) == "C"
			HttpSession->cGrids := oObj:OWSGETFORMTISSRESULT:cGrids
		EndIf

		If ValType(oObj:OWSGETFORMTISSRESULT:OWSCMPGUIA:oWSSCmpGuia) == "A" /*/:OWSCMPGUIA:OWSSCMPGUIA)*/
			HttpSession->aCmpGuia := aClone(oObj:OWSGETFORMTISSRESULT:OWSCMPGUIA:oWSSCmpGuia)
		EndIf

		//Executa os inicializadores dos campos
		nIni := At("<%=",cResult)

		While  nIni > 0

			nFim 		:= At("%>",cResult)
			cComando 	:= SubStr(cResult,nIni+3,nFim - nIni-3)
			xResult 	:= &(cComando)
			cTipResult 	:= ValType(xResult)

			Do Case
				Case cTipResult == "D"
					xResult := DtoS(xResult)
					xResult := SubStr(xResult,7,2) + "/" + SubStr(xResult,5,2) + "/" + SubStr(xResult,1,4)
				Case cTipResult == "N"
					xResult := Alltrim(Str(xResult))
			EndCase

			cResult := StrTran ( cResult, "<%=" + cComando + "%>", xResult) //, nIni, 1)
			nIni 	:= At("<%=",cResult)

		EndDo

	EndIf

	HttpSession->cPaginaGuia := Substr(cResult,At("|",cResult)+1,Len(cResult)) // Retiro o true| ou o false|

EndIf

// Envia para o determinado formulario
If cTissVer < "3"

	Do Case
		Case HttpSession->cTp == "1" //Consulta
			cHtml := ExecInPage( "PPLSCONS?cRda="+HttpGet->cRda+"&cCodLoc="+HttpGet->cCodLoc )
		Case HttpSession->cTp == "2" //Sadt
			cHtml := ExecInPage( "PPLSSADT?cRda="+HttpGet->cRda+"&cCodLoc="+HttpGet->cCodLoc )
		Case HttpSession->cTp == "3" //Internacao
			cHtml := ExecInPage( "PPLSSOIN?cRda="+HttpGet->cRda+"&cCodLoc="+HttpGet->cCodLoc )
		Case HttpSession->cTp == "4" //ODontologico
			cHtml := ExecInPage( "PPLSGTOP?cRda="+HttpGet->cRda+"&cCodLoc="+HttpGet->cCodLoc )
	EndCase

Else

	oObj:cMsnBloInter	:= HttpSession->cMsnBloInt
	//GUIA ODONTOLOGICA AINDA NAO EH DINAMICA TODAS AS OUTRAS SAO...
	//FOI FEITO DESTA FORMA POIS O LAYOUT DE GUIA DA GUIA ODONTOLOGICA EH O MESMO
	//LAYOUT DA GUIA SADT. NO FUTURO ISSO DEVE SER CORRIGIDO 22/07/2014 - DAHER
	If HttpSession->cTp == "4" //ODontologico

		//Sessions para alimentar os hiddens da guia odontológica.
		HttpSession->dDtLimRetro := HttpGet->dDtLimRetro
		HttpSession->cTipoOrigem := HttpGet->cTipoOrigem

		//Se for alteração, alimenta a session cAltCmpG e o recno.
		if(lAltCpAUT)
			HttpSession->cAltCmpG := oObj:cTipo
			HttpSession->cRecnoBD5 := oObj:cRECNOBD5
		else
			//Limpa sessions de possíveis outros formulários
			HttpSession->cAltCmpG := ""
			HttpSession->cRecnoBD5 := ""
		endif

		if ValType(HttpGet->dDtLimRetro) <> "U"
			cHtml := ExecInPage( "PPLSGTOF?cRda="+HttpGet->cRda+"&cCodLoc="+HttpGet->cCodLoc+"&dDtLimRetro="+HttpGet->dDtLimRetro+"&cTipoOrigem="+HttpGet->cTipoOrigem )
		else
			cHtml := ExecInPage( "PPLSGTOF?cRda="+HttpGet->cRda+"&cCodLoc="+HttpGet->cCodLoc )
		endif

	Else
		cHtml += ExecInPage("PPLSGUIAS")
	Endif

EndIf

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCHAPRE
Mostra pacientes para o atendimento chamada do menu
@author PLSTEAM
@since 07/2016
@version P12
/*/
Web Function PPLCHAPRE()
LOCAL cHtml 	:= ""
LOCAL oObjPar 	:= nil
Private lPreAten := HttpSession->lPreAten

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->cBtIntern := " "

If ValType(lPreAten) == 'U'
	oObjPar :=  WSCFGDICTIONARY():New()
	IIf (!Empty(PlsGetAuth()),oObjPar:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObjPar, "CFGDICTIONARY.APW" )

	oObjPar:cUSERCODE	:= "MSALPHA"
	oObjPar:cMVPARAM	:= "MV_PLPREAT"
	If oObjPar:GETPARAM()
		lPreAten := oObjPar:cGETPARAMRESULT
		If ValType(lPreAten) == 'U'
			lPreAten := .F.
		ElseIf	ValType(lPreAten) == 'C'
			If Type(lPreAten)=="L"
				lPreAten := &(lPreAten)
			EndIf
		EndIf
	EndIf

EndIf

//Pré atendimento dentro do atendimento
if lPreAten

	// Verificar permissão de acesso do botao internados
	oObj := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLSXFUN.APW" )

	oObj:cUserCode	:= "MSALPHA"
	oObj:CcUsr		:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
	HttpSession->cBtIntern := ""

	If oObj:VALACEBOT()
		If LEN(oObj:OWSVALACEBOTRESULT:OWSSUSUARIO) > 0
			HttpSession->cBtIntern := oObj:OWSVALACEBOTRESULT:OWSSUSUARIO[1]:CPERMITE
		EndIf
	EndIf

	//Tipo de pre-atendimento se vai pre-atender ou atender (executar)

	HttpSession->cTpPreAte := "0"
	HttpSession->cBtInterna:= "0"
EndIf

//Define o tipo de entrada de dados

If ValType(HttpSession->cTipCar) == 'U'
	If HttpSession->USR_INFO[1]:OWSUSERLOGPLS:cTipCar == '1'
		HttpSession->cTipCar := "1"
	Else
		HttpSession->cTipCar := "0"
	EndIf
EndIf


// "0" Pre-Atendimento "1" Pacientes "2" Atendimento

HttpSession->cTpPreAte := HttpGet->cP

// "2" Atendimento	carrega combos

If HttpSession->cTpPreAte != '0'
	W_PPLENVFOR()
Else

	// Chama formulario de atendimento

	cHtml += ExecInPage("PPLMOSPRE")
EndIf

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLSCHKCID
Verifica se o cid e valido
@author PLSTEAM
@since 07/2016
@version P12
/*/
Web Function PPLSCHKCID()
LOCAL cResult := ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//Web Service

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros de entrada

oObj:cUserCode	:= "MSALPHA"
oObj:cCid		:= HttpGet->cChkCid

//Executa metodo verificar se o cid e valido

If oObj:ChkCid()
	If ValType(HttpGet->cCampoRef) == "U"  //nas versoes 3.xx.xx esse cara vem preenchido
		cResult := 'true|'+oObj:cCHKCIDRESULT
	Else
		If "false" $ oObj:cCHKCIDRESULT
			cResult := oObj:cCHKCIDRESULT
		Else
			cResult := 'true|'+HttpGet->cCampoRef+"|"+oObj:cCHKCIDRESULT
		EndIf
	Endif
Else
	cResult :=  "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSITEPCT
Procura e inclui dados dos itens do pacote,qtd e codpad
@author PLSTEAM
@since 07/2016
@version P12
/*/
Web Function PPLSITEPCT()
Local cCpaDoc		:= subStr(HttpGet->cCodPct,0,2)
Local cCodPct		:= subStr(HttpGet->cCodPct,3,10)
Local cQtdSSol		:= HttpGet->cQtdSSol
Local cQtdAutSSol	:= HttpGet->qtdAutSSol
Local cStatusAut 	:= HttpGet->cStatusAut
Local cTpAut 		:= HttpGet->cTpAut
Local lRetCab 		:= HttpGet->lRetCab
Local dDtExe		:= HttpGet->dDtExe
Local nRedAcreSExe	:= HttpGet->nRedAcreSExe
Local nI			:= 0
Local cResult 		:= ""
Local aResultado	:= {}
LOCAL cHtml 		:= ""

WEB EXTENDED INIT cHtml START "InSite"

If ValType(HttpGet->lRetCab) = "U"
	lRetCab := .F.
Else
	lRetCab := .T.
EndIf

If ValType(HttpGet->dDtExe) = "U"
	dDtExe := ""
EndIf

If ValType(HttpGet->nRedAcreSExe) = "U"
	nRedAcreSExe := ""
EndIf

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW")

oObj:cUSERCODE 			:= "MSALPHA"
oObj:OWSPRODAD:cCodPad	:= cCpaDoc
oObj:OWSPRODAD:cCodPro	:= cCodPct


If oObj:RetLstPro()
	cResult := oObj:cRETLSTPRORESULT //+ "cQtdSSol;" + cQtdSSol + "~" + "cQtdAutSSol;" + cQtdAutSSol + "~"
EndIf

aResultado := PlSplitAdvpl(cResult, "|")

cResult := "true"

//Adicionando a todos os itens a quantidade autorizada/solicitada do pacote.
For nI := 2 To Len(aResultado)

	If dDtExe = ""
		cResult += "|" + aResultado[nI] + "~cQtdAutSSol;" + cQtdAutSSol + "~" + "cQtdSSol;" + cQtdSSol + "~" + "cStatusAut;" + cStatusAut + "~" + "cTpAut;" + cTpAut + "~cCodPct;" + cCodPct + "~dDtExe;"+dDtExe + "~nRedAcreSExe;" + nRedAcreSExe
	Else
		cResult += "|" + aResultado[nI] + "~cQtdAutSSol;" + cQtdAutSSol + "~" + "cStatusAut;" + cStatusAut + "~" + "cTpAut;" + cTpAut + "~cCodPct;" + cCodPct + "~dDtExe;"+dDtExe + "~nRedAcreSExe;" + nRedAcreSExe
	EndIf

Next

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSCHKPCT
Verifica se o procedimento e pacote
@author PLSTEAM
@since 07/2016
@version P12
/*/
Web Function PPLSCHKPCT()
LOCAL cHtml 	:= ""
local cResult	:= "false|"

WEB EXTENDED INIT cHtml START "InSite"

//Web Service

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Registro no WS
oObj:cUSERCODE 			:= "MSALPHA"
oObj:oWSMatPre:cCodRda	:= HttpGet->cRda										  	//Rda
oObj:oWSMatPre:cMatric	:= HttpGet->cMatric											//Matricula
oObj:oWSMatPre:cNomeUsu	:= HttpGet->cNomeUsu										//Nome do usuario
oObj:oWSMatPre:cCodUsr	:= getUsrWeb()											 	//Codigo de login web Login pls bsw
oObj:oWSMatPre:cMatric	:= HttpGet->cMatric		//Matricula

//Parametros de entrada
oObj:OWSPRODAD:cCodPad	:= SubStr(HttpGet->cCodPadPro,0,2)
oObj:OWSPRODAD:cCodPro	:= SubStr(HttpGet->cCodPadPro,3,8)
oObj:OWSPRODAD:cCodRda	:= SubStr(HttpGet->cCodPadPro,11,6)

if oObj:ChkCodPct()

	cResult := "true|" + oObj:cCHKCODPCTRESULT + "?" + subStr(HttpGet->cCodPadPro,3,8)//+ "?" + cV

else

	cResult := "false|" + strTran(PWSGetWSError( "" ),":","")

endIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSCHKSER
Verifica se o procedimento e valido
@author PLSTEAM
@since 07/2016
@version P12
/*/
Web Function PPLSCHKSER()

LOCAL cTISSVer:= ""
LOCAL cResult := ""
LOCAL aRDA    := {}
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//Web Service

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Registro no WS
oObj:cUserCode			:= "MSALPHA"
oObj:oWSMatPre:cCodRda	:= HttpGet->cRda										  	//Rda
oObj:oWSMatPre:cMatric	:= HttpGet->cMatric											//Matricula
oObj:oWSMatPre:cNomeUsu	:= HttpGet->cNomeUsu										//Nome do usuario
oObj:oWSMatPre:cCodUsr	:= getUsrWeb()											 	//Codigo de login web Login pls bsw

//Parametros de entrada
oObj:OWSPRODAD:cTpServ	:= HttpSession->cTp
oObj:OWSPRODAD:cCodPad	:= Left(HttpGet->cCodPadPro,2)
oObj:OWSPRODAD:cCodPro	:= SubStr(HttpGet->cCodPadPro,3,10)
oObj:OWSPRODAD:cTpProc	:= HttpGet->cTpProc
oObj:OWSPRODAD:cCodRda	:= HttpGet->cRda

nPosRDA := aScan( HttpSession->RDAVIEW, { |x| x:cCODE == HttpGet->cRda } )

If nPosRDA > 0
	aRDA := ClassDataArr(HttpSession->RDAVIEW[nPosRDA])
Endif

If aScan(aRDA,{|x| AllTrim(x[1]) == "CTISSVER"  }) > 0
	cTISSVer := HttpSession->RDAVIEW[nPosRDA]:cTissVer
EndIf

oObj:OWSPRODAD:cTissVer	:= cTISSVer

//Executa metodo verificar se o procedimento e valido

If oObj:ChkCodPro()
	cResult := oObj:cCHKCODPRORESULT
Else
	cResult :=  "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSQTD
Quantidade
@author PLSTEAM
@since 10.2013
@version P12
/*/
Web Function PPLSQTD()
LOCAL cResult := ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


//Web Service

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros de entrada

oObj:cUSERCODE 	:= "MSALPHA"
oObj:OWSPRODAD:cCodPad	:= HttpGet->cCodPad
oObj:OWSPRODAD:cCodPro	:= HttpGet->cCodPro

If ValType(HttpGet->nQtdPro) <> "U"
	oObj:OWSPRODAD:nQtdPro	:= val(HttpGet->nQtdPro)
ElseIf ValType(HttpGet->cQtdPro) <> "U"
	oObj:OWSPRODAD:nQtdPro	:= val(HttpGet->cQtdPro)
Else
	oObj:OWSPRODAD:nQtdPro := 0
EndIf


//Executa metodo verificar se o procedimento e valido

If oObj:ChkQtdPro()
	cResult := oObj:cCHKQTDPRORESULT
Else
	cResult :=  "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPSDETPRO
Retorna informação do prof de saude com base na selecao
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function PPSDETPRO(cProfSau,cTp,cTpProf)
	LOCAL cResult       := ""
	LOCAL nPosPSau 	    := 0
	LOCAL nI			:= 0
	LOCAL oObj			:= NIL
	LOCAL cTpGuia       := iif(valtype(HttpSession->cTp) <> "U", HttpSession->cTp, "")
	DEFAULT	 cTpProf	:= "S" //S - Solicitante | E - Executante

	// Profissional de Saude
	If HttpSession->PROSAUD == NIL
		HttpSession->PROSAUD := {}
	EndIf
	If HttpSession->PROSAUDEXE == NIL
		HttpSession->PROSAUDEXE := {}
	EndIf

	If !(cTp == "W") .And. cTpProf <> "E" .And. aScan( HttpSession->PROSAUD, { |x| x:cCODE == AllTrim(cProfSau) } ) == 0
		oObj := WSPLSXFUN():New()
		IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
		WsChgURL( @oObj, "PLSXFUN.APW" )

		// Parametros
		oObj:cUSERCODE	:= "MSALPHA"
		//oObj:cRdaCode	:= cProfSau
		oObj:cCodLoc	:= HttpGet->cCodLoc
		if(ValType(HttpGet->cRda) <> 'U')
			oObj:cRdaCode		:= HttpGet->cRda
		elseif(ValType(HttpPost->cRda) <> 'U')
			oObj:cRdaCode		:= HttpPost->cRda
		else
			oObj:cRdaCode		:= ""
		endIf
		oObj:cBusca	:= cProfSau //Codigo do profissional a ser gatilhado
		oObj:cTipo		:= "2" //Tipo de busca: 1 - por nome, 2 - por código
		oObj:cTipGui	:= cTpGuia

		// Lista de profissional de saude
		If oObj:ProfSaud()
			HttpSession->PROSAUD := oObj:oWSPROFSAUDRESULT:OWSLISTPROFSAUD:oWSPROFSAUD
		EndIf
	EndIf

	nPosPSau := aScan( IIF(cTpProf == "E",HttpSession->PROSAUDEXE,HttpSession->PROSAUD), { |x| x:cCODE == AllTrim(cProfSau) } )

	If nPosPSau == 0
		//Seleciona o profissional caso exista apenas 1 na session
		If (cTpProf == "E" .and. (ValType(HttpSession->PROSAUDEXE) == "A" .OR. ValType(HttpSession->PROSAUDEXE) == "O") .AND. Len(HttpSession->PROSAUDEXE) == 1 .and. (AllTrim(HttpSession->PROSAUDEXE[1]:cCode) == AllTrim(cProfSau))) .or. ;
				(cTpProf <> "E" .and. (ValType(HttpSession->PROSAUD)    == "A" .OR. ValType(HttpSession->PROSAUD)    == "O") .AND. Len(HttpSession->PROSAUD)    == 1 .and. (AllTrim(HttpSession->PROSAUD[1]:cCode)    == AllTrim(cProfSau)))

			nPosPSau := 1
		else
			//Caso não seja encontrado na session
			//Realizo busca na BB0 para retornar os demais dados do profissional (orgao, nº orgao, uf orgao, etc).
			//Chamada da função que busca o profissional na BB0
			oObj := WSPLSXFUN():New()
			IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
			WsChgURL( @oObj, "PLSXFUN.APW" )

			if(ValType(HttpGet->cRda) <> 'U')
				oObj:cRdaCode		:= HttpGet->cRda
			elseif(ValType(HttpPost->cRda) <> 'U')
				oObj:cRdaCode		:= HttpPost->cRda
			else
				oObj:cRdaCode		:= ""
			endIf

			if(ValType(HttpGet->cCodLoc) <> 'U')
				oObj:cCodLoc		:= HttpGet->cCodLoc
			elseif(ValType(HttpPost->cRda) <> 'U')
				oObj:cCodLoc		:= HttpPost->cCodLoc
			else
				oObj:cCodLoc		:= ""
			endIf

			oObj:cUSERCODE 	:= "MSALPHA"
			oObj:cBusca		:= cProfSau //Codigo do profissional a ser gatilhado
			oObj:cTipo		:= "2" //Tipo de busca: 1 - por nome, 2 - por código
			oObj:cTipGui	:= cTpGuia
			oObj:cTipProf	:= cTpProf

			If oObj:ProfSaud()
				if (cTpProf == "E")
					HttpSession->PROSAUDEXE := oObj:OWSPROFSAUDRESULT:OWSLISTPFSEXE:oWSPROFSAUD
				else
					HttpSession->PROSAUD := oObj:oWSPROFSAUDRESULT:OWSLISTPROFSAUD:oWSPROFSAUD
				endif

				if len(Iif(cTpProf == "E",HttpSession->PROSAUDEXE,HttpSession->PROSAUD)) == 1
					nPosPSau := 1
				endif
			EndIf
		EndIf
	EndIf

	// Carrega dados do profissional
	If nPosPSau > 0
		If cTp == "W"
			cResult :=  "true|"+HttpSession->PROSAUD[nPosPSau]:cCodSig	+"|"+;
				HttpSession->PROSAUD[nPosPSau]:cNumCr	+"|"+;
				HttpSession->PROSAUD[nPosPSau]:cEstado	+"|"+;
				HttpSession->PROSAUD[nPosPSau]:cName + "@" + HttpSession->PROSAUD[nPosPSau]:cCode +"|"+;
				HttpSession->PROSAUD[nPosPSau]:cCpfCnpj	+"|"+;
				HttpSession->PROSAUD[nPosPSau]:cCodOpe

			// Ajusta caracter especial

			cResult := PLSDECODE(cResult)

		ElseIf cTp == "W2"
			cResult := "true|"+ IIF(cTpProf == "E", HttpSession->PROSAUDEXE[nPosPSau]:cCodSig, HttpSession->PROSAUD[nPosPSau]:cCodSig)	 +"|"+;
				IIF(cTpProf == "E", HttpSession->PROSAUDEXE[nPosPSau]:cNumCr, HttpSession->PROSAUD[nPosPSau]:cNumCr)	 +"|"+;
				IIF(cTpProf == "E", HttpSession->PROSAUDEXE[nPosPSau]:cEstado, HttpSession->PROSAUD[nPosPSau]:cEstado)	 +"|"+;
				IIF(cTpProf == "E", HttpSession->PROSAUDEXE[nPosPSau]:cName + "@" + HttpSession->PROSAUDEXE[nPosPSau]:cCode, HttpSession->PROSAUD[nPosPSau]:cName + "@" + HttpSession->PROSAUD[nPosPSau]:cCode) + "|"+;
				IIF(cTpProf == "E", HttpSession->PROSAUDEXE[nPosPSau]:cCpfCnpj, HttpSession->PROSAUD[nPosPSau]:cCpfCnpj) +"|"+;
				IIF(cTpProf == "E", HttpSession->PROSAUDEXE[nPosPSau]:cCodOpe, HttpSession->PROSAUD[nPosPSau]:cCodOpe)

			// Ajusta caracter especial

			If cTpProf == "E"
				If Type("HttpSession->PROSAUDEXE["+alltrim(str(nPosPSau))+"]:oWsEspeci") <> 'U'
					If Len(HttpSession->PROSAUDEXE[nPosPSau]:oWsEspeci:oWsGenericStruct) > 0
						cResult += "|"
						For nI:=1 To Len(HttpSession->PROSAUDEXE[nPosPSau]:oWsEspeci:oWsGenericStruct)
							cResult += HttpSession->PROSAUDEXE[nPosPSau]:oWsEspeci:oWsGenericStruct[nI]:cCode+"#"+alltrim(HttpSession->PROSAUDEXE[nPosPSau]:oWsEspeci:oWsGenericStruct[nI]:cDescription)+"$"
						Next
					Endif
				Endif
			Else
				If Type("HttpSession->PROSAUD["+alltrim(str(nPosPSau))+"]:oWsEspeci") <> 'U'
					If Len(HttpSession->PROSAUD[nPosPSau]:oWsEspeci:oWsGenericStruct) > 0
						cResult += "|"
						For nI:=1 To Len(HttpSession->PROSAUD[nPosPSau]:oWsEspeci:oWsGenericStruct)
							cResult += HttpSession->PROSAUD[nPosPSau]:oWsEspeci:oWsGenericStruct[nI]:cCode+"#"+alltrim(HttpSession->PROSAUD[nPosPSau]:oWsEspeci:oWsGenericStruct[nI]:cDescription)+"$"
						Next
					Endif
				Endif
			Endif
		Else
			cResult	 := {}
			AaDd(cResult,{	HttpSession->PROSAUD[nPosPSau]:cCodSig,;
				HttpSession->PROSAUD[nPosPSau]:cNumCr,;
				HttpSession->PROSAUD[nPosPSau]:cEstado,;
				HttpSession->PROSAUD[nPosPSau]:cName + "@" + HttpSession->PROSAUD[nPosPSau]:cCode,;
				HttpSession->PROSAUD[nPosPSau]:cCpfCnpj,;
				HttpSession->PROSAUD[nPosPSau]:cCodOpe } )
		EndIf
	EndIf

Return cResult

/*/{Protheus.doc} PPSDADPSAU
Retorna informação do prof de saude com base na selecao
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPSDADPSAU()
LOCAL cResult 	:= "true|||||||||||||||||||||||"
LOCAL cRet 	  	:= ""
LOCAL cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

//Pega detalhe do profissional
cRet := PPSDETPRO(HttpGet->cProSaud,"W2")

if HttpSession->lPLSPROF

	aRet := execblock('PLSPROF',.F.,.F.,{HttpGet->cProSaud,HttpGet->cMatric})

	if !aRet[1]
		cRet:="false|"+aRet[2]
	endIf

endIf

if ! empty(cRet)
	cResult := cRet
endIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPCBOSPSAU
Retorna informação do prof de saude com base na selecao
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPCBOSPSAU()
LOCAL cResult:= "true|||||||||||||||||||||||"
LOCAL cRet 	 := ""
LOCAL cHtml	 := ""

WEB EXTENDED INIT cHtml START "InSite"

//Pega detalhe do profissional
if HttpGet->cTpProf != NIL .AND. !Empty(HttpGet->cTpProf)
	cRet := PPSDETPRO(HttpGet->cProSaud,"W2",HttpGet->cTpProf)
else
	cRet := PPSDETPRO(HttpGet->cProSaud,"W")
endif

if HttpSession->lPLSPROF

	aRet := execblock('PLSPROF',.F.,.F.,{HttpGet->cProSaud,HttpGet->cMatric})

	If ! aRet[1]
		cRet := "false|" + aRet[2]
	Endif

endIf

if ! Empty(cRet)
	cResult := cRet
endIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPSDADRSOL
Retorna informação do prof de saude com base na selecao
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPSDADRSOL()
LOCAL nPos	  := 0
LOCAL cResult := "true|"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// Dados da Rda
If ( nPos := aScan( HttpSession->RDASOLT, { |x| AllTrim(x:cNAME) == AllTrim(HttpGet->cNomeSolT) } ) ) > 0

	// Para a resposta
	cResult +=	HttpSession->RDASOLT[nPos]:cCnpfCpf+"|"+;
		HttpSession->RDASOLT[nPos]:cCode+"|"+;
		HttpSession->RDASOLT[nPos]:cCodProf+"|"+;
		HttpSession->RDASOLT[nPos]:cCodOpe+"|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPSVLDESP
Retorna especifica do cliente com base no ponto de entrada
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPSVLDESP()
LOCAL cResult := "true||"
LOCAL aRet	  := ""
LOCAL cHtml := ""
LOCAL aProcs := {}

WEB EXTENDED INIT cHtml START "InSite"


//Pega informacao para tratamento no ponto de entrada

cCodRda := HttpGet->cCodRda
cMatric := HttpGet->cMatric
cCodPad := HttpGet->cCodPad
cCodPro := HttpGet->cCodPro
cProcs	:= HttpGet->cProcs
dDatPro := HttpGet->dDatPro
nVlrPro := HttpGet->nVlrPro


If !Empty(cProcs)
	aProcs := StrTokArr( HttpGet->cProcs, "|" )
EndIf

//Verifica ponto de entrada
If  HttpSession->lPPLREGBTN

	aRet := ExecBlock( "PPLREGBTN",.F.,.F.,{cCodRda,cMatric,cCodPad,cCodPro,dDatPro,aProcs} )

	If Len(aRet) > 0 .and. ! empty(aRet[1])
		cResult := "false|"+AllTrim(aRet[1])+"|"
	EndIf

EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPSDETRDA
Retorna informação da rda com base na selecao do combo
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function PPSDETRDA(cRda,cCodLoc, cTpGuia)
	LOCAL nI
	LOCAL nPosRDA := 0
	LOCAL cResult := "true|NORMAL|||||||||||||||||||||||"
	LOCAL nPosPSau := 1
	LOCAL lFindSol := .F.

	// se nao e necessario o codloc na busca da Rda

	if !empty(cCodLoc)
		nPosRDA := aScan( HttpSession->RDAVIEW, { |x| x:cCODE == cRda .And. x:cCodLoc == cCodLoc} )
	else
		nPosRDA := aScan( HttpSession->RDAVIEW, { |x| x:cCODE == cRda} )
	endIf

	HttpSession->cEndCon :=	""

	// Monta resultado

	If nPosRDA > 0

		// Monta o endereco do contratado

		HttpSession->cEndCon :=	HttpSession->RDAVIEW[nPosRDA]:cTpLograd+HttpSession->RDAVIEW[nPosRDA]:cCep+;
			HttpSession->RDAVIEW[nPosRDA]:cNumero+HttpSession->RDAVIEW[nPosRDA]:cState

		cResult :=  "true|"+HttpSession->RDAVIEW[nPosRDA]:cRegAtend+"|"+;//0
			HttpSession->RDAVIEW[nPosRDA]:cRegAns+"|"+;//1
			HttpSession->RDAVIEW[nPosRDA]:cCnpfCpf+"|"+;//2
			HttpSession->RDAVIEW[nPosRDA]:cName+"|"+;//3
			HttpSession->RDAVIEW[nPosRDA]:cCnes+"|"+;//4
			AllTrim(HttpSession->RDAVIEW[nPosRDA]:cTpLograd)+"|"+;//5
			PadR(HttpSession->RDAVIEW[nPosRDA]:cAddress+' - '+AllTrim(HttpSession->RDAVIEW[nPosRDA]:cNumero)+' - '+HttpSession->RDAVIEW[nPosRDA]:cComplen,60)+"|"+;//6
			HttpSession->RDAVIEW[nPosRDA]:cDistrict+"|"+;//7
			HttpSession->RDAVIEW[nPosRDA]:cState+"|"+;//8
			HttpSession->RDAVIEW[nPosRDA]:cIBGE+"|"+;//9
			HttpSession->RDAVIEW[nPosRDA]:cCep+"|"+;//10
			HttpSession->RDAVIEW[nPosRDA]:cSigCr+"|"+;//11
			HttpSession->RDAVIEW[nPosRDA]:cCodCr+"|"+;//12
			HttpSession->RDAVIEW[nPosRDA]:cEstCr+"|"+;//13
			HttpSession->RDAVIEW[nPosRDA]:cTipPE+"|"+;//14
			HttpSession->RDAVIEW[nPosRDA]:cCodBB0+"|"//15

		// Dados do profissional de saude da rda

		cDadProf := Iif ((cTpGuia $ "6,5") .or. Empty(AllTrim(HttpSession->RDAVIEW[nPosRDA]:cCodBB0)), "", StrTran( PPSDETPRO(HttpSession->RDAVIEW[nPosRDA]:cCodBB0,"W"),"true|",""))
		cResult +=	IiF(Empty(cDadProf),"|||||",cDadProf)+"|"//16-cCodSig, 17-cNumCr, 18-cEstado, 19-cName, 20-cCpfCnpj, 21-cCodOpe

		//Local de atendimento

		cResult +=	HttpSession->RDAVIEW[nPosRDA]:cCodLoc+"|"//22

		//Carater da Solicitacao

		cResult +=	HttpSession->RDAVIEW[nPosRDA]:cCarSol+"|"//23

		if Type("HttpSession->PROSAUD["+alltrim(str(nPosPSau))+"]:oWsEspeci") <> 'U'
			if Len(HttpSession->PROSAUD[nPosPSau]:oWsEspeci:oWsGenericStruct) > 0

				// Se for maior que um coloca o cabecalho
				if Len(HttpSession->PROSAUD[nPosPSau]:oWsEspeci:oWsGenericStruct) > 1
					cResult +=	"~$-- CBOS --"
				endIf

				// Monta as especialidades
				For nI:=1 To Len(HttpSession->PROSAUD[nPosPSau]:oWsEspeci:oWsGenericStruct)
					cResult +=	"~"+HttpSession->PROSAUD[nPosPSau]:oWsEspeci:oWsGenericStruct[nI]:cCode+"$"+;//24
						Alltrim(HttpSession->PROSAUD[nPosPSau]:oWsEspeci:oWsGenericStruct[nI]:cDescription)
				Next
				lFindSol := .T.
			endIf
		endIf

		if !lFindSol

			// Se for maior que um coloca o cabecalho
			If Len(HttpSession->RDAVIEW[nPosRDA]:OWSMESPRDA:OWSESPRDA) > 1
				cResult +=	"~$-- CBOS --"
			EndIf

			// Monta as especialidades
			For nI:=1 To Len(HttpSession->RDAVIEW[nPosRDA]:OWSMESPRDA:OWSESPRDA)
				cResult +=	"~"+HttpSession->RDAVIEW[nPosRDA]:OWSMESPRDA:OWSESPRDA[nI]:cCodEsp+;//24
					HttpSession->RDAVIEW[nPosRDA]:OWSMESPRDA:OWSESPRDA[nI]:cCodCBOS+"$"+;
					AllTrim(HttpSession->RDAVIEW[nPosRDA]:OWSMESPRDA:OWSESPRDA[nI]:cDesCBOS)
			Next
		endIf

		//Versão da TISS utilizada pela RDA

		aRDA := ClassDataArr(HttpSession->RDAVIEW[nPosRDA])
		If aScan(aRDA,{|x| AllTrim(x[1]) == "CTISSVER"  }) > 0
			cResult +=	"|"+HttpSession->RDAVIEW[nPosRDA]:cTissVer+"|"//25
		EndIf
	EndIf




Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLDADRDA
Retorna informação da rda com base na selecao do combo
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLDADRDA()
LOCAL cHtml 	:= ""
local cResult	:= ""
private lProSauLoad := .T.

WEB EXTENDED INIT cHtml START "InSite"

//Informacao da rda

If ValType(HttpGet->cRda) <> 'U' .And. ValType(HttpGet->cCodLoc) <> 'U'

	// Verfica se precisa carregar profissionais
	If ValType(HttpSession->PROSAUD) == 'U' .Or. Len(HttpSession->PROSAUD) == 0

		// obj
		oObj := WSPLSXFUN():New()
		IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
		WsChgURL( @oObj, "PLSXFUN.APW" )

		// Parametros
		oObj:cUSERCODE	:= "MSALPHA"
		oObj:cRdaCode	:= HttpGet->cRda
		oObj:cCodLoc	:= HttpGet->cCodLoc

		// Lista de profissional de saude
		If ! HttpSession->cTp $ "1,2,3,4,11,12,5,6" //Tipo de Guia

			If oObj:ProfSaud()
				HttpSession->PROSAUD := oObj:oWSPROFSAUDRESULT:OWSLISTPROFSAUD:oWSPROFSAUD
			EndIf

		else
			lProSauLoad := .F.
			HttpSession->PROSAUD := {}
		EndIf

	Else

		If HttpSession->cTp $ "1,2,3,4,11,12,5,6"
			lProSauLoad := .F.
		EndIf

	EndIf

	// Dados da Rda
	cResult := PPSDETRDA(HttpGet->cRda, HttpGet->cCodLoc, HttpSession->cTp)
else

	cResult := PPSDETRDA("")

endIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSERGET
Pega o conteudo do campo da matriz
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function PPLSERGET(cVar,aDad)
	LOCAL nPos	:= 0
	LOCAL cVal 	:= ""

	//Pesquisa na matriz e pega o valor
	nPos := aScan(aDad,{|x| allTrim(x[1]) == allTrim(cVar)})

	If nPos > 0

		If allTrim(cVar) == 'cSeq' .And. empty(aDad[nPos,2])
			cVal := '001'
		Else
			cVal := aDad[nPos,2]
		EndIf

	EndIf

Return cVal

/*/{Protheus.doc} getCmpAlt

@author PLSTEAM
@since 10.2007
@version P12
/*/
function getCmpAlt(aCamposAlterados, cTipo,  aCampoCabec, aCampoItem)
	local cEsp := ""
	local nFor
	local cTpCon
	local cTpSai
	local cTpDoe
	local cTmpDoe
	local cTmpDoeC
	local cIndAcid
	local aTabDup := PlsBusTerDup(SuperGetMv("MV_TISSCAB",.F.,"87"))
	local cAtendRN

	for nFor := 1 to len(aCamposAlterados)
		if cTipo == "1"
			Do Case
				Case cCampoTela == 'cAtendRN'
					cAtendRN := HttpPost->cAtendRN
					aadd(aCampoCabec, {"BD5_ATERNA", cAtendRN})
				Case cCampoTela == 'cCbosExe'
					cCbos	 := HttpPost->cCbosExe

					cEsp := SubString(cCbos,1,3)

					aadd(aCampoCabec, {"BD5_CODESP", cEsp})
					aadd(aCampoItem,  {"BD6_CODESP", cEsp})

				Case cCampoTela == 'cTpCon'

					cTpCon := alltrim(PLSVARVINC('52', nil, HttpPost->cTpCon) )

					aadd(aCampoCabec, {"BD5_TIPCON", cTpCon})
					aadd(aCampoItem,  {"BD6_TIPCON", cTpCon})

					// Case cCampoTela == 'cProSol' //Verificar Prestador

				Case cCampoTela == 'cTpSai'

					cTpSai := alltrim(PLSVARVINC('39','BEA', HttpPost->cTpSai))

					aadd(aCampoCabec, {"BD5_TIPSAI", cTpSai})

				Case cCampoTela == 'cTpDoe'

					cTpDoe	 := HttpPost->cTpDoe
					aadd(aCampoCabec, {"BD5_TIPDOE", cTpDoe})

				Case cCampoTela == 'cTmpDoe'

					cTmpDoe	 := HttpPost->cTmpDoe
					aadd(aCampoCabec, {"BD5_TPODOE", cTmpDoe})

				Case cCampoTela == 'cTmpDoeC'

					cTmpDoeC	 := HttpPost->cTmpDoeC
					aadd(aCampoCabec, {"BD5_UTPDOE", cTmpDoeC})


				Case cCampoTela == 'cIndAcid'

					cIndAcid := alltrim(PLSVARVINC('36', nil, HttpPost->cIndAcid))
					aadd(aCampoCabec, {"BD5_INDACI", cIndAcid})


				Case cCampoTela == 'cCodPad' .or. cCampoTela == 'cCodPro'

					cCodPad := AllTrim(PLSVARVINC('87','BR4', HttpPost->cCodPad))

					cCodPro := AllTrim(PLSVARVINC(HttpPost->cCodPad,'BR8',HttpPost->cCodPro ,HttpPost->cCodPad+HttpPost->cCodPro,,aTabDup,@CCODPAD))

					aadd(aCampoItem, {"BD6_CODPAD", cCodPad})
					aadd(aCampoItem, {"BD6_CODPRO", cCodPro})

				Case cCampoTela == 'cVlrPro'

					aadd(aCampoItem, {"BD6_VLRAPR", HttpPost->cVlrPro})

			EndCase

		elseif cTipo == "6"
			Do Case
				Case cCampoTela == 'cAtendRN'
					cAtendRN := HttpPost->cAtendRN
					aadd(aCampoCabec, {"BD5_ATERNA", cAtendRN})


				Case cCampoTela == 'dDataIniFat'
					aadd(aCampoCabec, {"BD5_TPODOE", cTmpDoe})
					ctod(HttpPost->dDataIniFat)		//Inicio Faturamento

				Case cCampoTela == 'dDataFimFat'
					aadd(aCampoCabec, {"BD5_TPODOE", cTmpDoe})
					ctod(HttpPost->dDataFimFat)		//Fim Faturamento
			EndCase

		elseif cTipo == "2"
			Do Case
				Case cCampoTela == 'cAtendRN'
					cAtendRN	 := HttpPost->cAtendRN
					aAdd(aCampoCabec,  {"BD5_ATERNA", cAtendRN})

				Case cCampoTela == 'cProSol'
					cProSol	 := HttpPost->cProSol
					aAdd(aCampoCabec,  {"BD5_CDPFSO", cProSol})
					aAdd(aCampoItem,   {"BD6_CDPFSO", cProSol})

				Case cCampoTela == 'cCodSigSol'
					cCodSigSol := HttpPost->cCodSigSol
					aAdd(aCampoCabec,  {"BD5_SIGLA", cCodSigSol})
					aAdd(aCampoItem,   {"BD6_SIGLA", cCodSigSol})

				Case cCampoTela == 'cNumCrSol'
					cNumCrSol := HttpPost->cNumCrSol
					aAdd(aCampoCabec,  {"BD5_REGSOL", cNumCrSol})
					aAdd(aCampoItem,   {"BD6_REGSOL", cNumCrSol})

				Case cCampoTela == 'cEstSigSol'
					cEstSigSol := HttpPost->cEstSigSol
					aAdd(aCampoCabec,  {"BD5_ESTSOL", cEstSigSol})
					aAdd(aCampoItem,   {"BD6_ESTSOL", cEstSigSol})

				Case cCampoTela == 'cCbosSol'
					cCbosSol := HttpPost->cCbosSol
					aAdd(aCampoCabec,  {"BD5_CODESP", SubString(cCbosSol,1,3)})
					aAdd(aCampoItem,   {"BD6_CODESP", SubString(cCbosSol,1,3)})

				Case cCampoTela == 'cCarSolicit'
					cCarSolicit := HttpPost->cCarSolicit
					aAdd(aCampoCabec,  {"BD5_TIPADM", cCarSolicit})

				Case cCampoTela == 'dDtSolicit'
					dDtSolicit := HttpPost->dDtSolicit
					aAdd(aCampoCabec,  {"BD5_DATSOL", dDtSolicit})

				Case cCampoTela == 'cIndCliSol'
					nTaman	 := (TamSX3("BD5_INDCLI")[1])
					cIndCliSol := HttpPost->cIndCliSol
					aAdd(aCampoCabec,  {"BD5_INDCLI", SubStr(AllTrim(cIndCliSol),1, nTaman) })
					aAdd(aCampoCabec,  {"BD5_INDCL2", IIF (Len(cIndCliSol) > nTaman, SubStr(cIndCliSol,nTaman+1,Len(cIndCliSol) ), "")})

				Case cCampoTela == 'cCnesExe'
					cCnesExe := HttpPost->cCnesExe
					aAdd(aCampoCabec,  {"BD5_CNES", cCnesExe })

				Case cCampoTela == 'cTpAteExe'   //De/Para
					cTpAteExe := alltrim(PLSVARVINC('50', nil, HttpPost->cTpAteExe) )
					aAdd(aCampoCabec,  {"BD5_TIPATE", cTpAteExe})

				Case cCampoTela == 'cIndAcid'   //De/Para
					cIndAcid := alltrim(PLSVARVINC('36', nil, HttpPost->cIndAcid) )
					aAdd(aCampoCabec,  {"BD5_ESTSOL", cIndAcid})

				Case cCampoTela == 'cTpCon'    //De/Para
					cTpCon := alltrim(PLSVARVINC('52', nil, HttpPost->cTpCon) )
					aAdd(aCampoCabec,  {"BD5_TIPCON", cTpCon})
					aAdd(aCampoItem,   {"BD6_ESTSOL", cTpCon})

				Case cCampoTela == 'cTpSai'    //De/Para
					cTpSai := alltrim( PLSVARVINC('39', nil, HttpPost->cTpSai) )
					aAdd(aCampoCabec,  {"BD5_TIPSAI", cTpSai})

				Case cCampoTela == 'cTpDoe'
					cTpDoe := HttpPost->cTpDoe
					aadd(aCampoCabec, {"BD5_TIPDOE", cTpDoe})

				Case cCampoTela == 'cTmpDoe'
					cTmpDoe	 := HttpPost->cTmpDoe
					aadd(aCampoCabec, {"BD5_TPODOE", cTmpDoe})

				Case cCampoTela == 'cTmpDoeC'
					cTmpDoeC	 := HttpPost->cTmpDoeC
					aadd(aCampoCabec, {"BD5_UTPDOE", cTmpDoeC})

				Case cCampoTela == 'cNumInt'
					cNumInt	 := HttpPost->cNumInt
					aadd(aCampoCabec, {"BD5_NRLBOR", cNumInt})
					aadd(aCampoItem,  {"BD6_NRLBOR", cNumInt})
			EndCase

		elseif cTipo == "4" //Odontológico
			Do Case
				Case cCampoTela == 'cAtendRN'
					cAtendRN	 := HttpPost->cProSol
					aAdd(aCampoCabec,  {"BD5_ATERNA", cAtendRN})

				Case cCampoTela == 'cProSol'
					cProSol	 := HttpPost->cProSol
					aAdd(aCampoCabec,  {"BD5_CDPFSO", cProSol})
					aAdd(aCampoItem,   {"BD6_CDPFSO", cProSol})

				Case cCampoTela == 'cCodSigSol'
					cCodSigSol := HttpPost->cCodSigSol
					aAdd(aCampoCabec,  {"BD5_SIGLA", cCodSigSol})
					aAdd(aCampoItem,   {"BD6_SIGLA", cCodSigSol})

				Case cCampoTela == 'cNumCrSol'
					cNumCrSol := HttpPost->cNumCrSol
					aAdd(aCampoCabec,  {"BD5_REGSOL", cNumCrSol})
					aAdd(aCampoItem,   {"BD6_REGSOL", cNumCrSol})

				Case cCampoTela == 'cEstSigSol'
					cEstSigSol := HttpPost->cEstSigSol
					aAdd(aCampoCabec,  {"BD5_ESTSOL", cEstSigSol})
					aAdd(aCampoItem,   {"BD6_ESTSOL", cEstSigSol})

				Case cCampoTela == 'cCbosSol'
					cCbosSol := HttpPost->cCbosSol
					aAdd(aCampoCabec,  {"BD5_CODESP", SubString(cCbosSol,1,3)})
					aAdd(aCampoItem,   {"BD6_CODESP", SubString(cCbosSol,1,3)})

				Case cCampoTela == 'cProExe'
					cProExe	 := HttpPost->cProExe
					aAdd(aCampoCabec,  {"BD5_CDPFRE", cProExe})
					aAdd(aCampoItem,   {"BD6_CDPFRE", cProExe})

				Case cCampoTela == 'cCnpjCpfExe'
					cCnpjCpfExe := HttpPost->cCnpjCpfExe
					aAdd(aCampoCabec,  {"BD5_CPFRDA", cCnpjCpfExe})
					aAdd(aCampoItem,   {"BD6_CPFRDA", cCnpjCpfExe})

				Case cCampoTela == 'cNumCrExe'
					cNumCrExe := HttpPost->cNumCrExe
					aAdd(aCampoCabec,  {"BD5_REGEXE", cNumCrExe})
					aAdd(aCampoItem,   {"BD6_REGEXE", cNumCrExe})

				Case cCampoTela == 'cEstSigExe'
					cEstSigExe := HttpPost->cEstSigSol
					aAdd(aCampoCabec,  {"BD5_ESTEXE", cEstSigExe})
					aAdd(aCampoItem,   {"BD6_ESTEXE", cEstSigExe})

				Case cCampoTela == 'cCbosExe'  //Se tiver executante, grava do Executante
					cCbosExe := HttpPost->cCbosExe
					aAdd(aCampoCabec,  {"BD5_CODESP", SubString(cCbosExe,1,3)})
					aAdd(aCampoItem,   {"BD6_CODESP", SubString(cCbosExe,1,3)})

				Case cCampoTela == 'cTpAto'   //De/Para
					cTpAto := alltrim(PLSVARVINC('51', nil, HttpPost->cTpAto) )
					aAdd(aCampoCabec,  {"BD5_TIPATE", cTpAto})

				Case cCampoTela == 'dDtEmissao'
					dDtEmissao := HttpPost->dDtEmissao
					aAdd(aCampoCabec,  {"BD5_DATPRO", dDtEmissao})

				Case cCampoTela == 'cGuiaPrincipal'
					cGuiaPrincipal	 := HttpPost->cGuiaPrincipal
					aadd(aCampoCabec, {"BD5_NRLBOR", cGuiaPrincipal})
					aadd(aCampoItem,  {"BD6_NRLBOR", cGuiaPrincipal})

				Case cCampoTela == 'cTpFat'   //De/Para
					cTpFat := alltrim(PLSVARVINC('55', nil, HttpPost->cTpFat) )
					aAdd(aCampoCabec,  {"BD5_TIPFAT", cTpFat})

				Case cCampoTela == 'cTpDoe'
					cTpDoe := HttpPost->cTpDoe
					aadd(aCampoCabec, {"BD5_TIPDOE", cTpDoe})

				Case cCampoTela == 'cTmpDoe'
					cTmpDoe	 := HttpPost->cTmpDoe
					aadd(aCampoCabec, {"BD5_TPODOE", cTmpDoe})

				Case cCampoTela == 'cTmpDoeC'
					cTmpDoeC	 := HttpPost->cTmpDoeC
					aadd(aCampoCabec, {"BD5_UTPDOE", cTmpDoeC})
			EndCase

		endif
	next

return

/*/{Protheus.doc} PPLPROCALT
Função Responsável pela processamento da alteração de guias offline.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLPROCALT()
Local aSepara				:= {}
Local cCamposAlterados	:= IIf(Valtype(HttpPost->cLstCmpAlt) == "U", "",  HttpPost->cLstCmpAlt)
Local cItensAlterados  	:= IIf(Valtype(HttpPost->cLstCmpAltServ) == "U", "", HttpPost->cLstCmpAltServ)
Local cTipoConfirm		:= IIF(Valtype(HttpGet->cTipoConfirm)== "U", "", HttpGet->cTipoConfirm)
Local oObj
Local cResult 			:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


//Chamar função para verificar se o usuário tem permissão
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUSERCODE	:= "MSALPHA"
oObj:cCamposAlterados := cCamposAlterados
oObj:cItensAlterados := cItensAlterados
oObj:cTipo 		:= HttpSession->cTp
oObj:cRecnoBD5 	:= AllTrim(HttpGet->cRecno)

oObj:cTipoAut		:= cTipoConfirm
if HttpSession->cTp = "1"
	oObj:cTableCode := HttpPost->cCodPad
else
	oObj:cTableCode := HttpPost->cCodPadSExe
endif

if oObj:GRVALTOFF()
	cResult := oObj:cGRVALTOFFRESULT
	If !Empty(cResult)

		//Verifica se existe críticas para a guia no retorno da gravação, se sim, adiciona na string para o modal.
		IF ('|-|' $ cResult)
			aSepara := SEPARA(cResult, '|-|', .F.)
			cResult := "true|warning|Guia gravada! Número: " + aSepara[1] + "<br>"
			cResult += "Críticas: <br>" + aSepara[2]
		Else
			cResult := "true|success|Guia gravada com sucesso. Número: " + cResult
		EndIf
	else
		cResult := "true|fail|Houve um erro ao editar a guia, contate a operadora."
	endif
endif

WEB EXTENDED END

getLOGMon()

return  PLSDECODE(cResult)

/*/{Protheus.doc} PPLPROCGUI
Processa as Guias
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLPROCGUI()
LOCAL nI,nY		  	:= 0
LOCAL nPos		  	:= 0
LOCAL oObj			:= NIL
LOCAL oObjSex 		:= NIL
LOCAL nIteAut     	:= 0
LOCAL nIteNeg     	:= 0
LOCAL nTmpDoe	  	:= 0
LOCAL nValTot	 	:= 0
LOCAL cResultCab 	:= "true|"
LOCAL cResultItem	:= ""
LOCAL cResultSenPr	:= ""
LOCAL cCodEsp		:= ""
LOCAL cEspSol		:= ""
LOCAL cEspExe		:= ""
LOCAL cNomeSol	  	:= ""
LOCAL cProExe     	:= ""
LOCAL cCodOpeExe  	:= ""
LOCAL cProSol     	:= ""
LOCAL cCodOpeSol  	:= ""
LOCAL cCid		  	:= ""
LOCAL cCid2		  	:= ""
LOCAL cCid3		  	:= ""
LOCAL cCid4		  	:= ""
LOCAL cCid5		  	:= ""
LOCAL cCbos		  	:= ""
LOCAL cTpCon 	  	:= ""
LOCAL cTpSai	  	:= ""
LOCAL cTpAteExe	  	:= ""
LOCAL cTpDoe	  	:= ""
LOCAL cTmpDoeC	  	:= ""
LOCAL cIndAcid	  	:= ""
LOCAL cNomeRda	  	:= ""
LOCAL cCnpjCpfSol 	:= ""
LOCAL cCnesSol    	:= ""
LOCAL cCnesExe    	:= ""
LOCAL cCpfExe	  	:= ""
LOCAL cNumAut	  	:= ""
LOCAL cResult 	  	:= ""
LOCAL cTpAto	  	:= ""
LOCAL cTpFat 	  	:= ""
LOCAL cSequen	  	:= ""
LOCAL cCodTab	  	:= ""
LOCAL cCodPro	  	:= ""
LOCAL cDesPro	  	:= ""
LOCAL cDente	  	:= ""
LOCAL cFace	  	  	:= ""
LOCAL cQtdTot	  	:= ""
LOCAL cSenPro	  	:= ""
LOCAL cCritica	  	:= ""
LOCAL cQtdUs	  	:= ""
LOCAL cData		  	:= ""
LOCAL cSenhaAu	  	:= ""
LOCAL cTpIntern	  	:= ""
LOCAL cRegInter	  	:= ""
LOCAL cOrigem	  	:= "2"
LOCAL cStatus 	  	:= "1"
LOCAL cGrPar      	:= ""
LOCAL cCodSig 	  	:= ""
LOCAL cNumCr	  	:= ""
LOCAL cEstado 	  	:= ""
LOCAL cNomfExe	  	:= ""
LOCAL cSexo       	:= ""
LOCAL cTpAcom	  	:= ""
LOCAL cPadCon	  	:= ""
LOCAL cQtdDSol	  	:= ""
LOCAL cCnpjSolT	  	:= ""
LOCAL cDadInt	  	:= ""
LOCAL cNumPeg	  	:= ""
LOCAL cVia  	  	:= ""
LOCAL cAbrang	  	:= ""
LOCAL cNatur	  	:= ""
LOCAL cDesGRP	  	:= ""
LOCAL lFemini		:= .F.
LOCAL lProGe		:= .F.
LOCAL lExecu		:= .F.
LOCAL lChkReg		:= .T.
LOCAL lInter		:= .F.
LOCAL lEvolu		:= .F.
LOCAL lHonor		:= .F.
LOCAL lResInt		:= .F.
LOCAL lEveNeg       := .F.
LOCAL aMatIte		:= {}
LOCAL aRetProf		:= {}
LOCAL aDadB7B       := {}
LOCAL cJSON
LOCAL cStProc	  	:= ""
LOCAL cTissVer		:= HttpSession->cTISSVer
LOCAL nJ			:= 0
LOCAL aMatGrp		:= {}
LOCAL dPrvInt       := ctod('')
Local cDigigui		:= IIf(Valtype(HttpGet->cTipoOrigem) == "U", "", HttpGet->cTipoOrigem)
Local aAlerta   	:= {}
Local nAl       	:= 0
Local lAlerta   	:= .F.
Local cResAlert 	:= ""
Local cTipoConfirm	:= IIf(Valtype(HttpGet->cTipoConfirm) == "U", "", HttpGet->cTipoConfirm)
LOCAL cProtoc	  	:= ""
LOCAL nC			:= 0
LOCAL nP			:= 0
LOCAL cTokEdi	  	:= ""
LOCAL cImpNoAut	  	:= ""
LOCAL aNoAutTemp  	:= {}
LOCAL cTextoRadio  	:= "false"
LOCAL aSeqProc		:= {}
LOCAL lProcSeq      := .F.
LOCAL cHtml 		:= ""
LOCAL cNumGui		:= ""
Local lTissVt		:= Iif( (!Empty(cTissVer) .and. cTissVer >= "3"), .T., .F.)
local cCarSol		:= ''
local nTmpIni 		:= Seconds()
local cCobEspNw		:= ""
local cRegAtdNw		:= ""
local cSaudOcNw		:= ""

WEB EXTENDED INIT cHtml START "InSite"

if ! empty(cDigigui)
	nIteAut := 1
endif

//Se esse cara ta vazio eu nem preciso rodar os parametros abaixo pq nao vai servir pra nada de acordo com a logica proposta
If empty(HttpSession->cUsuProc)

	//Web Service * retorna sexo
	oObjSex := WSPLSXINC():New()
	IIf (!Empty(PlsGetAuth()),oObjSex:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObjSex, "PLSXINC.APW" )

	oObjSex:cUSERCODE	:= "MSALPHA"	//Usuario

	if HttpPost->cNumecart == NIL
		oObjSex:cMatricula 	:= HttpGet->cNumecart // matricula
		cMatricula 			:= HttpGet->cNumecart
	else
		oObjSex:cMatricula 	:= HttpPost->cNumecart // matricula
		cMatricula 			:= HttpPost->cNumecart
	endif

	If oObjSex:SexoUser()
		cSexo := oObjSex:cSexoUserResult
	EndIf

	lFemini := ( cSexo == "2" )

EndIf

//Sessao para impressao da guia
HttpSession->aResult := {}
HttpSession->lSen 	 := .F.

//PLSXMOV
oObj := WSPLSXMOV():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXMOV.APW" )

//Processa a guia
oObj:cUSERCODE	:= "MSALPHA"				//Usuario
oObj:cRDACODE 	:= HttpPost->cRDA			//Rda
oObj:nAUTTYPE	:= Val(HttpSession->cTp)	//Tipo de guia consulta,sadt,internacao,Odonto

If cDigigui <> ""
	oObj:cDigitacaoGuia	:= HttpGet->cTipoOrigem
EndIf

aIteAux := PPLSALIMA(HttpPost->cMatTabES)
If HttpSession->cTp == '4'
	For nJ := 1 to len(aIteAux)
		nPosStatus := Ascan(aIteAux[nJ],{|x|Upper(x[1]) == "CSTATUS"})
		If nPosStatus > 0 .And. Upper(aIteAux[nJ][nPosStatus][2]) == "N"
			lEveNeg := .T.
			Exit
		EndIf
	Next
ElseIf HttpSession->cTp == '2'
	For nJ := 1 to len(aIteAux)
		nPosStatus := Ascan(aIteAux[nJ],{|x|Upper(x[1]) == "NQTDAUT"})
		If nPosStatus > 0 .And. aIteAux[nJ][nPosStatus][2] == "0"
			lEveNeg := .T.
			Exit
		EndIf
	Next
EndIf

Do Case

	//Consulta
	Case HttpSession->cTp == '1'

		HttpSession->cTpComprov	:= 'Consulta - Execução'
		lChkReg  				:= .T.

		If Type('HttpPost->cCidPri') <> 'U'
			cCid	:= HttpPost->cCidPri
		Endif

		If Type('HttpPost->cCid2') <> 'U'
			cCid2 	:= HttpPost->cCid2
		Endif

		If Type('HttpPost->cCid3') <> 'U'
			cCid3 	:= HttpPost->cCid3
		Endif

		If Type('HttpPost->cCid4') <> 'U'
			cCid4 	:= HttpPost->cCid4
		Endif

		cCid5 	 	:= ""

		If Type('HttpPost->cCbosExe') <> 'U'
			cCbos	 := HttpPost->cCbosExe
		Else
			cCbos	 := HttpPost->cCbos
		Endif

		cEspSol	:= SubString(cCbos,1,3)
		cCodEsp := cEspSol
		cTpCon 	:= HttpPost->cTpCon

		If Type('HttpPost->cProSol') <> 'U'
			cProExe  := HttpPost->cProSol
		ElseIf Type('HttpPost->cNomeExe') <> 'U'
			cProExe  := HttpPost->cNomeExe
		Else
			cProExe  := HttpPost->cProSaud
		Endif

		aRetProf := PPSDETPRO(cProExe,"L")

		If Len(aRetProf) > 0
			cCodOpeExe	:= aRetProf[1,6]
		EndIf

		cNomeRda  := HttpPost->cNomeRdaExe
		cOrigem	  := "1"

		If Type('HttpPost->cTpSai') <> 'U'
			cTpSai	  := HttpPost->cTpSai
		Endif
		If Type('HttpPost->cTpDoe') <> 'U'
			cTpDoe	  := HttpPost->cTpDoe
		Endif

		If Type('HttpPost->cTmpDoe') <> 'U'
			nTmpDoe	  := Val(HttpPost->cTmpDoe)
		Endif

		If Type('HttpPost->cTmpDoeC') <> 'U'
			cTmpDoeC  := HttpPost->cTmpDoeC
		Endif

		cIndAcid	:= HttpPost->cIndAcid
		cCodSig 	:= HttpPost->cCodSigExe
		cNumCr		:= HttpPost->cNumCrExe
		cEstado 	:= HttpPost->cEstSigExe

		If Type('HttpPost->cCnpfCpf') <> 'U'
			cCpfExe 	:= HttpPost->cCnpfCpf
		endif

		If Type('HttpPost->cCnesExe') <> 'U'
			cCnesExe 	:= HttpPost->cCnesExe
		endif

		//Sadt
	Case HttpSession->cTp == '2'

		//Solicitacao
		HttpSession->cTpComprov	:= 'Sadt - Solicitação'

		If ValType(HttpPost->cCbosSol) <> 'U'
			cCbos 	:= HttpPost->cCbosSol
			cEspSol	:= SubString(cCbos,1,3)
			cCodEsp	:= cEspSol
		EndIf

		lChkReg  := .T.

		If ! Empty(cTissVer) .and. cTissVer >= "3"
			cCid := ""
		Else
			cCid := HttpPost->cCid
		EndIf
		cProSol  := HttpPost->cProSol

		if !empty(cProSol)
			aRetProf := PPSDETPRO(cProSol,"L")
		endif

		If Len(aRetProf) > 0
			cNomeSol 	:= aRetProf[1,4]
			cCodOpeSol	:= aRetProf[1,6]
		Else
			cNomeSol := HttpPost->cNomeRdaSol
		EndIf

		cNomeRda  := HttpPost->cNomeRdaSol
		cOrigem	  := "2"
		cTpSai	  := HttpPost->cTpSai
		cTpAteExe := HttpPost->cTpAteExe
		cNumInt   := HttpPost->cNumInt
		cIndAcid  := HttpPost->cIndAcid

		//Executante
		If HttpPost->cNumAut <> "" .Or. (!Empty(HttpPost->cSolExe) .And. !lEveNeg) .Or. !Empty(cDigigui)

			cCarSol 				:= HttpPost->cCarSol	//Carater da solicitacao na execução
			cNumAut					:= AllTrim(StrTran(StrTran(HttpPost->cNumAut,".",""),"-",""))
			HttpSession->cTpComprov	:= 'Sadt - Execução'

			if valType(HttpPost->cCbosExe) == 'C'
				cCbos := HttpPost->cCbosExe
			endIf

			cEspExe	 				:= subStr(cCbos,1,3)
			cProExe  				:= HttpPost->cProExe

			if ! empty(cProExe)
				aRetProf := PPSDETPRO(cProExe,"L")
			endif

			If Len(aRetProf) > 0
				cCodOpeExe	:= aRetProf[1,6]
			EndIf

			cNomeRda  := HttpPost->cNomeRdaExe
			cOrigem   := "1"

			If ! Empty(cTissVer) .AND. cTissVer >= "3"

				cTpCon 	 	:= HttpPost->cTpCon
				cCnesExe   	:= HttpPost->cCnesExe
				cCnpjCpfSol := HttpPost->cCnpjCpfSol//12

				//Implementar Executantes da guia
			Else
				cTpDoe	  := HttpPost->cTpDoe
				nTmpDoe	  := Val(HttpPost->cTmpDoe)
				cTmpDoeC  := HttpPost->cTmpDoeC
			EndIf

			If HttpSession->cChaGe == "2"
				lExecu    := .T.
			Endif

		Else

			If Type('HttpPost->cIndAcid') <> 'U'
				cIndAcid  := HttpPost->cIndAcid
			EndIf

			If HttpSession->cChaGe == "1"
				lExecu    := .T.
			Endif

		EndIf
		//Internacao
	Case HttpSession->cTp == '3'

		//Solicitacao
		HttpSession->cTpComprov	:= 'Internação - Solicitação'

		If Type('HttpPost->cCbosSol') <> 'U'
			cCbos	 	:= HttpPost->cCbosSol //18
		Endif
		cEspSol  	 	:= SubString(cCbos,1,3)
		cCodEsp			:= cEspSol
		lChkReg  		:= .T.
		lInter 			:= .T.

		//Contratado Solicitante
		cCnpjCpfSol := HttpPost->cCnpjCpfSol //12 <-- BE4_RDACON
		cNomeRda   	:= HttpPost->cNomeRdaSol //13 <-- BE4_DRDACO
		cCnesSol   	:= HttpPost->cCnesSol

		//Profissional Solicitante
		cProSol  	:= HttpPost->cProSol //14 <-- BE4_CDPFSO
		aRetProf 	:= PPSDETPRO(cProSol,"L")

		If Len(aRetProf) > 0
			cNomeSol 	:= aRetProf[1,4] // <-- BE4_NOMSOL
			cCodOpeSol	:= aRetProf[1,6] // <-- BE4_REGSOL
		Else
			cNomeSol := HttpPost->cNomeSol
		EndIf

		dPrvInt := ctod(HttpPost->dDSPrAH)

		//Contratado Solicitado (Executante)
		cCnpjSolT := HttpPost->cCnpjSolT //20

		//Solicitacao de internacao
		If HttpPost->cNumAut == ""
			cOrigem	   	:= "2"
			cCid 		:= HttpPost->cCid
			cCid2 		:= HttpPost->cCid2
			cCid3 		:= HttpPost->cCid3
			cCid4 		:= HttpPost->cCid4
			cTpIntern  	:= HttpPost->cTpIntern
			cRegInter  	:= HttpPost->cRegInter
			cQtdDSol	:= HttpPost->cQtdDSol
			cTpDoe	  	:= HttpPost->cTpDoe

			If Empty(cTissVer) .OR. cTissVer < "3"
				nTmpDoe	  	:= Val(HttpPost->cTmpDoe)
			EndIf

			cTmpDoeC  	:= HttpPost->cTmpDoeC
			cIndAcid  	:= HttpPost->cIndAcid
			cTpAcom	   	:= 	Iif(Empty(HttpPost->cTpAcom), HttpSession->aVldCartao[18], HttpPost->cTpAcom)
			cPadCon	   	:= HttpSession->aVldCartao[19]

			if !Empty(HttpPost->cRdaSolT)
				oObj:cRDACODE 	:= HttpPost->cRdaSolT			//Rda
			endIf

		Else

			HttpSession->cTpComprov	:= 'Prorrogação - Execução'

			lEvolu	:= .T.
			cOrigem	:= "1"
			cNumAut	:= AllTrim(StrTran(StrTran(HttpPost->cNumAut,".",""),"-",""))

			//Na execucao da prorrogacao tenho que verificar o Contratato Solicitado
			If !Empty(HttpPost->cRdaSolT)
				HttpPost->cCodLoc 	:= ""
				oObj:cRDACODE 		:= HttpPost->cRdaSolT			//Rda
				cProExe 			:= HttpPost->cProfSolT
				cCodOpeExe  		:= HttpPost->cOpeSolT
			EndIf

		EndIf

		//Odontologico
	Case HttpSession->cTp == '4'

		//Solicitacao
		HttpSession->cTpComprov	:= 'Odontológico - Solicitação'
		cCbos	 				:= HttpPost->cCbosSol
		cEspSol  				:= SubString(cCbos,1,3)
		cCodEsp					:= cEspSol
		lChkReg  				:= .T.
		cCid 					:= ""
		cProSol  				:= HttpPost->cProSol
		aRetProf 				:= PPSDETPRO(cProSol,"L")
		cTpAto 				    := iif( empty(HttpPost->cTpAto), "1", HttpPost->cTpAto ) //Ser não for preenchdio, usado o default "1"
		cTpFat 				    := HttpPost->cTpFat
		cTpAteExe          		 := HttpPost->cTpAto

		If Len(aRetProf) > 0
			cNomeSol 	:= aRetProf[1,4]
			cCodOpeSol	:= aRetProf[1,6]
		Else
			cNomeSol := HttpPost->cNomeSol
		EndIf

		cNomeRda  := HttpPost->cNomeRda
		cOrigem	  := "2"

		//Executante
		If HttpPost->cNumAut <> "" .Or. (!Empty(HttpPost->cProExe) .And. !lEveNeg)
			cNumAut					:= AllTrim(StrTran(StrTran(HttpPost->cNumAut,".",""),"-",""))
			cNumPeg					:= HttpPost->cChvBD6
			HttpSession->cTpComprov	:= 'Odontológico - Execução'
			cCbos	 				:= HttpPost->cCbosExe
			cEspExe   	 			:= SubString(cCbos,1,3)
			cProExe  				:= HttpPost->cProExe
			aRetProf 				:= PPSDETPRO(cProExe,"L")

			If Len(aRetProf) > 0
				cCodOpeExe	:= aRetProf[1,6]
			EndIf

			cNomeRda  := HttpPost->cNomeRda
			cOrigem   := "1"
		EndIf

		//Honorario Individual
	Case HttpSession->cTp $ '6'

		HttpSession->cTpComprov	:= 'Honorário'
		lChkReg 		:= .T.
		lInter 			:= .T.
		lHonor 			:= .T.
		cOrigem			:= "1"

		cNumAut			:= AllTrim(StrTran(StrTran(HttpPost->cGuiaInter,".",""),"-",""))
		cNomeRda		:= HttpPost->cNomeRdaExe

		If lTissVt
			cNomfExe 	:= ""
			cGrPar  	:= ""
		Else
			cNomfExe 	:= HttpPost->cNomExe
			cGrPar  	:= HttpPost->cGrPar
		EndIf

		//Descricao do Grau de participacao
		If (nPos := aScan( HttpSession->aGrPart, { |x| x:cCODE == cGrPar} ) ) > 0
			cDesGRP := HttpSession->aGrPart[nPos]:CDESCRIPTION
		EndIf

		cCodSig 	:= HttpPost->cCodSigExe
		cNumCr		:= HttpPost->cNumCrExe
		cEstado 	:= HttpPost->cEstSigExe
		cCnesExe   	:= HttpPost->cCnesExe
		cNumPeg		:= HttpPost->cChvBD6
		cTpAcom		:= HttpPost->cTpAcom
		nValTot		:= Val(HttpPost->nVlrTotHor)

		cProExe  	:= HttpPost->cNomeRdaExe
		cCpfExe		:= Iif ( lTissVt, HttpPost->cCnpjCpfExe, HttpPost->cCpfExe )
		aRetProf 	:= PPSDETPRO(AllTrim(cProExe),"L")

		If Len(aRetProf) > 0
			cNomfExe 	:= Iif ( lTissVt, aRetProf[1,4], "" )
			cCodOpeExe	:= aRetProf[1,6]
		EndIf

		//Resumo de Internação
	Case HttpSession->cTp == '5'

		//Solicitacao
		HttpSession->cTpComprov	:= 'Resumo de Internação'
		lChkReg 		:= .T.
		lInter 			:= .T.
		cOrigem			:= "1"
		lResInt			:= .T.

		cCid2 		:= HttpPost->cCid2
		cCid3 		:= HttpPost->cCid3
		cCid4 		:= HttpPost->cCid4
		cCid5		:= HttpPost->cCidObt
		cIndAcid  	:= HttpPost->cIndAcid
		cTpIntern 	:= HttpPost->cTpIntern
		cRegInter	:= HttpPost->cRegInter
		cTpFat 		:= HttpPost->cTipFat
		cNumDecVivo	:= HttpPost->cNumDecVivo
		cNumDecObt	:= HttpPost->cNumDecObt
		cIndicRN	:= HttpPost->cIndicRN
		cHorIniFat	:= HttpPost->cHorIniFat
		cHorFimFat	:= HttpPost->cHorFimfat

		cNomeRda  := HttpPost->cNomeRdaSol
		cTpSai	  := HttpPost->cTpSai

		//Executante
		If (nPos := aScan( HttpSession->aGrPart, { |x| x:cCODE == cGrPar} ) ) > 0
			cDesGRP := HttpSession->aGrPart[nPos]:CDESCRIPTION
		EndIf

		cCodSig 	:= HttpPost->cCodSigExe
		cNumCr		:= HttpPost->cNumCrExe
		cEstado 	:= HttpPost->cEstSigExe
		cCnesExe   	:= HttpPost->cCnesExe
		cNumPeg		:= HttpPost->cChvBD6
		cTpAcom		:= HttpPost->cTpAcom
		nValTot		:= Val(HttpPost->nVlrTotHor)

		cProExe  	:= HttpPost->cNomeRdaSol
		cCpfExe		:= Iif ( lTissVt, HttpPost->cCnpjCpfSol, HttpPost->cCpfExe )
		aRetProf 	:= PPSDETPRO(AllTrim(cProExe),"L")

		If Len(aRetProf) > 0
			cNomfExe 	:= Iif ( lTissVt, aRetProf[1,4], "" )
			cCodOpeExe	:= aRetProf[1,6]
		EndIf

		//Prorrogação de Internação
	Case HttpSession->cTp == '11'

		//Solicitacao
		HttpSession->cTpComprov	:= 'Prorrogação - Execução'
		cCbos					:= HttpPost->cCbosSol
		cEspExe					:= SubString(cCbos,1,3)
		cCodEsp					:= cEspExe
		lChkReg  				:= .T.
		lInter 					:= .T.
		cTpAcom	   	:= HttpSession->aVldCartao[18]

		//Contratado Solicitante
		cCnpjCpfSol := HttpPost->cCnpjCpfSol//12
		cNomeRda   	:= HttpPost->cNomeRdaSol//13

		//Profissional Solicitante
		cProSol  	:= HttpPost->cProSol 	//15
		aRetProf 	:= PPSDETPRO(cProSol,"L")

		If Len(aRetProf) > 0
			cNomeSol 	:= aRetProf[1,4]
			cCodOpeSol	:= aRetProf[1,6]
		Else
			cNomeSol := HttpPost->cNomeSol
		EndIf

		cQtdDSol	:= HttpPost->cQtdDSol

		lEvolu	:= .T.
		cOrigem	:= "1"
		cNumAut	:= AllTrim(StrTran(StrTran(HttpPost->cGuiaOpe,".",""),"-","")) //O  NUmAut é o Numero da guia na operaddora

EndCase

// Ponto de Entrada PLB7BGRV é utilizado para coleta de dados dos campos dinâmicos criados nas guias do Portal do Prestador.
// Necessario converter Array para json para que os dados sejam transferido em formato de String.
If ExistBlock("PLB7BGRV")
	aDadB7B  := Execblock("PLB7BGRV",.F.,.F.,{})
	cJSON    := formatJson(aDadB7B)
EndIf

//Campos em comum para SADT e Consulta TISS 4.00
if HttpSession->cTp $ '1/2'
	//campos novos - verificar se vai ser igual para todos
	if type('HttpPost->cCobertEsp') <> 'U'
		cCobEspNw		:= HttpPost->cCobertEsp
	endif
	if type('HttpPost->cRegAtendim') <> 'U'
		cRegAtdNw		:= HttpPost->cRegAtendim
	endif
	if type('HttpPost->cSaudeOcupac') <> 'U'
		cSaudOcNw		:= HttpPost->cSaudeOcupac
	endif
endif

//Usuario
If ValType(HttpSession->aVldCartao) != 'U'
	cVia 	:= HttpSession->aVldCartao[3] 		//Via
	cAbrang := HttpSession->aVldCartao[7] 		//Abrangencia
	cNatur  := HttpSession->aVldCartao[8] 		//Natureza juridica
EndIf

If Type('HttpPost->cProtoc') <> 'U'
	cProtoc	:= HttpPost->cProtoc
Endif

If Type('HttpPost->cTokEdi') <> 'U'
	cTokEdi	:= HttpPost->cTokEdi
Endif

//Restante dos dados da guia
oObj:cLOCALCODE											:= HttpPost->cCodLoc				//LOCAL
oObj:cOrigem 											:= cOrigem							//Se e para solicitar ou executar

oObj:oWSAUTHORIZATION  									:= PLSXMOV_AUTHORIZATIONVIEW():New()
oObj:oWSAUTHORIZATION:oWSAUTHEADER						:= PLSXMOV_AUTHEADERVIEW():New()

aClasse := ClassDataArr(oObj:oWSAUTHORIZATION:oWSAUTHEADER)

If aScan(aClasse,{|x| AllTrim(x[1]) == "CTISSVER"  }) > 0
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cTissVer			:= cTissVer
EndIf

oObj:oWSAUTHORIZATION:oWSAUTHEADER:cReleaseNumber		:= cNumAut			                //Numero da Liberacao
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cGuiPri	 			:= Iif( ValType(HttpPost->cGuiaPrincipal)=='U','',AllTrim(StrTran(StrTran(HttpPost->cGuiaPrincipal,".",""),"-","")) )//Numero da guia principal

if HttpPost->cNumeCart = nil
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cREGISTRATIONNUMBER 	:= Alltrim(HttpGet->cNumeCart) //Matricula -- A MATANT pode ter traços ou pontos e ai não faz o seek
else
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cREGISTRATIONNUMBER 	:= Alltrim(HttpPost->cNumeCart) //Matricula -- A MATANT pode ter traços ou pontos e ai não faz o seek
endif

oObj:oWSAUTHORIZATION:oWSAUTHEADER:dProcedureDate		:=	IIF(!(EmpTy(cDigigui)),; 			//Se for digitação de guias
	IIF(EmpTy(httpSession->dDtaAtend),;//Pode vir nessa session, caso o Post venha vazio..
	IIF(Empty(HttpPost->dDtAtend),; 	//Se vier vazio, não é Consulta
	IIF(EmpTy(HttpPost->dDtExe),;		//Se vier vazio, não é SADT
	IIF(EmpTy(Httpget->dDtExePro),;		//Se vier vazio, não é Internação
	Date(),;								//Se não achou nada, retorna a data atual
	CtoD(Httpget->dDtExePro)),;	//Se for Digitação de guias de Internação, pega esse Get
	CtoD(HttpPost->dDtExe)),;		//Se for Digitação de guias de SADT, pega esse Get
	CtoD(HttpPost->dDtAtend)),;		//Se for Digitação de guias de Consulta, pega esse Get
	CtoD(httpSession->dDtaAtend)),; //Se veio na session, pega o valor da session
	Date())						//Data do procedimento (Se não for digitação de guias, pega a data atual)
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCidPri 			    := cCid					   			//CidPri
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCid2 			    := cCid2		   					//Cid2
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCid3 			    := cCid3		   					//Cid3
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCid4 			    := cCid4		   					//Cid4
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCid5 			    := cCid5				   			//Cid5
oObj:oWSAUTHORIZATION:oWSAUTHEADER:lChkReg 			    := lChkReg				   			//Se vai chegar regras ou nao

oObj:oWSAUTHORIZATION:oWSAUTHEADER:cPROFSOL 			:= cProSol		   					//Codigo do Solicitante
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCODOPESOL			:= cCodOpeSol						//Operadora do Solicitante
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cRDACON 				:= IIF((!empty(cCnpjCpfSol) .and. HttpSession->cTp == "3"), cCnpjCpfSol, "")	//Codigo do Solicitante



oObj:oWSAUTHORIZATION:oWSAUTHEADER:cPROFEXE    			:= cProExe		   					//Codigo do executante
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCODOPEEXE			:= cCodOpeExe                       //Operadora do executante
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cNomfExe				:= cNomfExe                    		//Nome do Executante
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCpfExe				:= cCpfExe                    		//Cpf do Executante
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCnesExe				:= cCnesExe                    		//CNes do Executante

oObj:oWSAUTHORIZATION:oWSAUTHEADER:nValTot				:= nValTot                    		//Valor Total

oObj:oWSAUTHORIZATION:oWSAUTHEADER:cNomeRda				:= cNomeRda                    		//Nome da Rda
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cGrPar				:= cGrPar                      		//Grau de Participacao
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCodSig				:= cCodSig                     		//Sigla
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cNumCr				:= cNumCr                     		//Numero CR
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cEstado				:= cEstado                     		//Estado

oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCARDEDITION 		:= cVia						 		//Via
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCARDENCLOSES		:= cAbrang					 		//Abrangencia
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCARDNATJUST			:= cNatur							//Natureza juridica

oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCARDVALIDDATE		:= HttpPost->cVldCarteira 			//Validade

if HttpPost->cNomeUsu = nil
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCARDNAME		:= HttpGet->cNomeUsu 				//Nome do cartao
else
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCARDNAME		:= HttpPost->cNomeUsu 				//Nome do cartao
endif

oObj:oWSAUTHORIZATION:oWSAUTHEADER:cSpecialityCode	:= cCodEsp								//Especialidade da RDA (BD5_CODESP)
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cEspSol			:= cEspSol								//Especialidade solicitante (BD5_ESPSOL)
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cEspExe			:= cEspExe								//Especialidade executante (BD5_ESPEXE)

If Type('oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW:cCBO') <> 'U'
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCBO			:= SubString(cCbos, 4, len(cCbos))							//CBO
ElseIf HttpSession->cTp == '11'
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCBO			:= cCbos													//CBO
EndIf

//Caso a data de algum procedimento seja menor que a data de atendimento, a data do procedimento será salçva no campo DATPRO.
if (ValType(HttpPost->dDataCorDig) <> 'U' .and. !(empty(HttpPost->dDataCorDig)) )
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:dProcedureDate := iif( (CtoD(HttpPost->dDataCorDig) < oObj:oWSAUTHORIZATION:oWSAUTHEADER:dProcedureDate), CtoD(HttpPost->dDataCorDig), oObj:oWSAUTHORIZATION:oWSAUTHEADER:dProcedureDate)
endif

oObj:oWSAUTHORIZATION:oWSAUTHEADER:cTipCon				:= cTpCon							//Tipo de Consulta
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cTipSai				:= cTpSai							//Tipo de Saida
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cTipAte				:= cTpAteExe			   			//Tipo de Atendimento
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cTipAto				:= cTpAto				   			//Tipo de Atendimento Odontologico
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cTipFat				:= cTpFat				   			//Tipo de Faturamento

oObj:oWSAUTHORIZATION:oWSAUTHEADER:cTpIntern			:= cTpIntern   						//Tipo de Internacao
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cRegInter			:= cRegInter   						//Regime da internacao
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cTpAcom			    := cTpAcom   						//Tipo de Acomodacao
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cPadCon			    := cPadCon   						//Padrao de Conforto
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cQtdDSol			    := cQtdDSol 						//Quantidade de Diaria Solicitada
oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDatPre              := dPrvInt                          //Data prevista de internação

oObj:oWSAUTHORIZATION:oWSAUTHEADER:cTipDoe				:= cTpDoe   						//Tipo de Doenca
oObj:oWSAUTHORIZATION:oWSAUTHEADER:nTmpDoe				:= nTmpDoe				   			//Tempo da Doenca
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cUndDoe				:= cTmpDoeC			   				//Unidade da Doenca
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cIndAcid				:= cIndAcid							//Indicacao de Acidente
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCnpjSolT			:= cCnpjSolT						//CGC da Rda Solicitada

oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDatSol				:= Iif(ValType(HttpPost->dDtSolicit) <> "U",ctod(HttpPost->dDtSolicit),ctod(''))		//Data da solicitacao

if empTy(cCarSol)
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCarSol				:= HttpPost->cCarSolicit			//Carater da solicitacao
else
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCarSol			:= cCarSol
endif

oObj:oWSAUTHORIZATION:oWSAUTHEADER:cIndCli				:= HttpPost->cIndCliSol				//Indicacao clinica
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cFormNumber			:= HttpPost->cFormNumber			//Numero Impresso
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cObs					:= iif(HttpSession->cTp != "11", HttpPost->cObs, HttpPost->cObsJustifica)	//Observacao
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cEndCon				:= HttpSession->cEndCon				//Endereco Contratado

oObj:oWSAUTHORIZATION:oWSAUTHEADER:lInter				:= lInter							//Internacao
oObj:oWSAUTHORIZATION:oWSAUTHEADER:lEvolu				:= lEvolu							//Prorrogacao
oObj:oWSAUTHORIZATION:oWSAUTHEADER:lHonor				:= lHonor			   				//Honorario
oObj:oWSAUTHORIZATION:oWSAUTHEADER:lResInt				:= lResInt							//Resumo de internacao
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cNumPeg				:= cNumPeg							//Numero da Guia Chave no BD6
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cProtoc				:= cProtoc							//Numero do Protocolo de Atendimento
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cGuiPre	 			:= HttpPost->cNumPre				//Numero Guia Prestador via Guia de Consulta do Portal

oObj:oWSAUTHORIZATION:oWSAUTHEADER:cTipoConfirm			:= cTipoConfirm						//string que indica a confirmação ou não da finalização da guia

oObj:oWSAUTHORIZATION:oWSAUTHEADER:cAdadB7B             := cJSON                            //Retorno do Ponto de Entrada PLB7BGRV.
If Type('HttpPost->cTokEdi') <> 'U'
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cTokEdi			:= cTokEdi							//Token PTU Online
EndIf

If ValType(HttpPost->dDtRlz) <> "U"

	If !Empty(HttpPost->dDtRlz)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz := ctod(HttpPost->dDtRlz)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz := ctod('')
	Endif

EndIf

If ValType(HttpPost->dDtRlz2) <> "U"

	If !Empty(HttpPost->dDtRlz2)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz2 := ctod(HttpPost->dDtRlz2)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz2 := ctod('')
	Endif

EndIf

If ValType(HttpPost->dDtRlz3) <> "U"

	If !Empty(HttpPost->dDtRlz3)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz3 := ctod(HttpPost->dDtRlz3)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz3 := ctod('')
	Endif

EndIf

If ValType(HttpPost->dDtRlz3) <> "U"

	If !Empty(HttpPost->dDtRlz3)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz3 := ctod(HttpPost->dDtRlz3)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz3 := ctod('')
	Endif

EndIf

If ValType(HttpPost->dDtRlz4) <> "U"
	If !Empty(HttpPost->dDtRlz4)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz4 := ctod(HttpPost->dDtRlz4)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz4 := ctod('')
	Endif
EndIf

If ValType(HttpPost->dDtRlz5) <> "U"
	If !Empty(HttpPost->dDtRlz5)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz5 := ctod(HttpPost->dDtRlz5)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz5 := ctod('')
	Endif
EndIf

If ValType(HttpPost->dDtRlz6) <> "U"
	If !Empty(HttpPost->dDtRlz6)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz6 := ctod(HttpPost->dDtRlz6)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz6 := ctod('')
	Endif
EndIf

If ValType(HttpPost->dDtRlz7) <> "U"
	If !Empty(HttpPost->dDtRlz7)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz7 := ctod(HttpPost->dDtRlz7)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz7 := ctod('')
	Endif
EndIf

If ValType(HttpPost->dDtRlz8) <> "U"
	If !Empty(HttpPost->dDtRlz8)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz8 := ctod(HttpPost->dDtRlz8)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz8 := ctod('')
	Endif
EndIf

If ValType(HttpPost->dDtRlz9) <> "U"
	If !Empty(HttpPost->dDtRlz9)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz9 := ctod(HttpPost->dDtRlz9)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz9 := ctod('')
	Endif
EndIf

If ValType(HttpPost->dDtRlz1) <> "U"
	If !Empty(HttpPost->dDtRlz1)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz1	:= ctod(HttpPost->dDtRlz1)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz1 	:= ctod('')
	Endif
EndIf

If Empty(oObj:oWSAUTHORIZATION:oWSAUTHEADER:cGuiPri) .And. HttpSession->cTp == "2"
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cGuiPri	 			:= Iif( ValType(HttpPost->cNumInt)=='U','',AllTrim(StrTran(StrTran(HttpPost->cNumInt,".",""),"-","")) )//Numero da guia principal
EndIf
If ValType(HttpPost->cAtendRN) <> "U"
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cAtenRN				:= HttpPost->cAtendRN		//Atendimento a RN
Else
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cAtenRN				:= HttpPost->cAtendRNHidden 	//Atendimento a RN (execução SADT)
EndIf

If Type('HttpPost->cAtenRN') <> "U"

	If HttpSession->cTp == "3"
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:cAtenRN			:= IIF(HttpPost->cAtenRN == "2","0","1")			//Atendimento a RN
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:cAtenRN			:= HttpPost->cAtenRN			//Atendimento a RN
	EndIf

EndIf

If Type('HttpPost->cOpme') <> "U" .and. aScan(aClasse,{|x| AllTrim(x[1]) == "CPRVOPM"  }) > 0
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cPrvOpm := HttpPost->cOpme
EndIf

If Type('HttpPost->cQuimio') <> "U" .and. aScan(aClasse,{|x| AllTrim(x[1]) == "CPRVQUI"  }) > 0
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cPrvQui := HttpPost->cQuimio
EndIf

If ValType(HttpPost->dDataIniFat) <> "U"
	If !Empty(HttpPost->dDataIniFat)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dIniFat := ctod(HttpPost->dDataIniFat)		//Inicio Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dIniFat := ctod('')
	EndIf
Else
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:dIniFat := ctod('')
EndIf

If ValType(HttpPost->dDataFimFat) <> "U"
	If !Empty(HttpPost->dDataFimFat)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dFimFat := ctod(HttpPost->dDataFimFat)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dFimFat := ctod('')
	Endif
Else
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:dFimFat := ctod('')
EndIf

//Guia de Honorário
If ValType(HttpPost->dDadaFimFat) <> "U"

	If !Empty(HttpPost->dDadaFimFat)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dFimFat := ctod(HttpPost->dDadaFimFat)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dFimFat := ctod('')
	Endif
Else
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:dFimFat := ctod('')
EndIf

If ValType(HttpPost->cObs) <> "U"
	If !Empty(HttpPost->cObs)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:cObs := Alltrim(HttpPost->cObs)		// Observação da Guia
	Endif
EndIf

//Dados da Guia de Resumo de Internação
if HttpSession->cTp == '5'
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cNumDecVivo := cNumDecVivo
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cNumDecObt := cNumDecObt
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cIndicRN := cIndicRN
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cHorIniFat := cHorIniFat
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cHorFimFat := cHorFimFat
endif

//Guia de Consulta e SADT TISS 4.00
if HttpSession->cTp $ '1/2'
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCobEspNwS := cCobEspNw
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cRegAtdNwS := cRegAtdNw
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cSaudOcNwS := cSaudOcNw
endif

//Monta matriz de participações
If !Empty(HttpPost->cMatTabExe)
	aMatGrp := PPLSALIMA(HttpPost->cMatTabExe)
EndIf

//Monta matriz de itens
If HttpSession->cTp == '1'

	If !Empty(cTissVer) .AND. cTissVer >= "3" //na versao 3 tem valor apresentado na guia de consulta
		AaDd( aMatIte,{ {'cSeq',''},{'cCodPad',HttpPost->cCodPad},{'cCodPro',HttpPost->cCodPro},{'nQtdSol','1'},{'nQtdAut','1'},{'nVlrApr',HttpPost->cVlrPro},{'cDente',''},{'cFace',''},{'cStProc',''} } )
	Else
		AaDd( aMatIte,{ {'cSeq',''},{'cCodPad',HttpPost->cCodPad},{'cCodPro',HttpPost->cCodPro},{'nQtdSol','1'},{'nQtdAut','1'},{'nVlrApr','0'},{'cDente',''},{'cFace',''},{'cStProc',''} } )
	Endif

Else

	aMatIte := PPLSALIMA(HttpPost->cMatTabES)

	If HttpPost->cSeqProc != NIL
		aSeqProc := PPLSALIMA(HttpPost->cSeqProc + "||")
	EndIf

EndIf

If HttpSession->lPPLSVPTU

	lRet := ExecBlock("PPLSVPTU",.F.,.F.,{cMatricula,cNumAut})

	If !lRet
		Return(.F.)
	Endif

EndIf

//Alimenta a strutura ws com todos os itens do formulario genericamente
oObj:oWSAUTHORIZATION:oWSAUTITEM := PLSXMOV_ARRAYOFAUTITEMVIEW():New()

For nI := 1 To Len(aMatIte)

	AaDd( oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW, PLSXMOV_AUTITEMVIEW():New() )

	//No caso de uma execução a partir de uma liberação deve ser passado o sequencial correto
	//do procedimento para controlar o saldo da liberação.
	If !EMPTY(aSeqProc)

		If LEN(aSeqProc[1]) >= nI

			If VALTYPE(aSeqProc[1][nI]) == "A"
				oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cSEQUENCE 			:= AllTrim(aSeqProc[1][nI][2])  //Sequencia
				lProcSeq := .T.
			EndIf

		EndIf

	EndIf

	//Se o procedimento não é derivado de uma liberação, o sistema usa o sequencial do array de itens.
	If !lProcSeq
		oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cSEQUENCE 			:= StrZero( Val( AllTrim( PPLSERGET('cSeq',aMatIte[nI]) ) ), 3 )  //Sequencia
	Else
		lProcSeq := .F.
	EndIf

	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cCODPAD 			:= AllTrim( PPLSERGET('cCodPad',aMatIte[nI]) )						//Tabela
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cPROCEDURECODE 		:= AllTrim( PPLSERGET('cCodPro',aMatIte[nI]) )						//Servico

	If !EMPTY(PPLSERGET('dDtExePro',aMatIte[nI]))
		oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:dDatPro := CTOD(PPLSERGET('dDtExePro',aMatIte[nI]))
	elseIf !EMPTY(PPLSERGET('dDtExe',aMatIte[nI])) .AND. !(EmpTy(cDigigui)) // guia odonto - digitação offline
		oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:dDatPro := CTOD(PPLSERGET('dDtExe',aMatIte[nI]))
	elseIf !(Empty(httpSession->dDtaAtend)) //Guia de consulta - Digitação OffLine
		oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:dDatPro := CTOD( httpSession->dDtaAtend )
	EndIf

	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:nPROCEDUREQUANTITY	:= Val( PPLSERGET('nQtdSol',aMatIte[nI]) )							//Qtd Solicitada
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:nQtdAut  			:= Val( PPLSERGET('nQtdAut',aMatIte[nI]) ) 						//Qtd Autorizada

	//Alterado o tratamento, agora retira toda a máscara e divide o valor por 100, garantindo o resultado correto
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:nVlrApr  			:= Val( StrTran(StrTran(PPLSERGET('nVlrApr',aMatIte[nI]),',',''),'.','') )/100			//Valor Apresentado
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cResAut  			:= AllTrim( PPLSERGET('cResAut',aMatIte[nI]) )						//Respon. pela Autorizacao
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cIndCliEvo  		:= AllTrim( PPLSERGET('cIndCliEvo',aMatIte[nI]) )					//Indicacao Clinica
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cDente  			:= AllTrim( PPLSERGET('cDente',aMatIte[nI]) )						//Dente
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cFace  			    := AllTrim( PPLSERGET('cFace',aMatIte[nI]) )						//Face
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cHorIni			    := AllTrim( StrTran(PPLSERGET('cHorIni',aMatIte[nI]),':','') )		//Hora Inicio
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cHorFim			    := AllTrim( StrTran(PPLSERGET('cHorFim',aMatIte[nI]),':','') )		//Hora Fim
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cViaAc			    := AllTrim( StrTran(PPLSERGET('cViaAc',aMatIte[nI]),':','') )		//Via
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cTecUt			    := AllTrim( StrTran(PPLSERGET('cTecUt',aMatIte[nI]),':','') )		//Tec

	if HttpSession->cTp == '5' .or. HttpSession->cTp == '6'
		oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:nRedAcre		:= Val(PPLSERGET('nRedAcre',aMatIte[nI]) )						//RedAcre
	else
		oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:nRedAcre		:= Val( StrTran(strtran(PPLSERGET('nRedAcre',aMatIte[nI]),',',''),'.','') )/100	//RedAcre
	endif

	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cDiagPro :=  PPLSERGET('cDiagPro',aMatIte[nI] ) 						//cDiagPro

	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cStProc := AllTrim( PPLSERGET('cStatus',aMatIte[nI]) )						//Status do Procedimento

	//Alimenta a strutura ws com todos os itens do formulario genericamente
	aClasse := ClassDataArr(oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI])

	If aScan(aClasse,{|x| AllTrim(x[1]) == "OWSGRPPAREXE"  }) > 0

		oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:oWSGRPPAREXE := PLSXMOV_ARRAYOFGRPPAREXE():New()
		nCmp := 0

		For nJ := 1 To Len(aMatGrp)

			If val(AllTrim( PPLSERGET('cSeqPro'	,aMatGrp[nJ]))) == Val( AllTrim( PPLSERGET('cSeq',aMatIte[nI])))
				nCmp++
				AaDd( oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:oWSGRPPAREXE:oWSGRPPAREXE, PLSXMOV_GRPPAREXE():New() ) //cNumCrExe;cEstSigExe;

				oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:oWSGRPPAREXE:oWSGRPPAREXE[nCmp]:cSeqPro 	:= AllTrim( PPLSERGET('cSeqPro'	,aMatGrp[nJ]) )			//Sequencia
				oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:oWSGRPPAREXE:oWSGRPPAREXE[nCmp]:cGrPar 	:= AllTrim( PPLSERGET('cGrPar'	,aMatGrp[nJ]) )			//Grau Participação
				oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:oWSGRPPAREXE:oWSGRPPAREXE[nCmp]:cCpfExe 	:= AllTrim( PPLSERGET('cCpfExe'	,aMatGrp[nJ]) )			//CPF Executante
				oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:oWSGRPPAREXE:oWSGRPPAREXE[nCmp]:cProFExe 	:= AllTrim( PPLSERGET('cProExe'	,aMatGrp[nJ]) )			//Prof Executante
				oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:oWSGRPPAREXE:oWSGRPPAREXE[nCmp]:cCodSig	:= AllTrim( PPLSERGET(IIF(HttpSession->cTp $ '5,6','cCodSigExe','cCodSig')	,aMatGrp[nJ]) )			//Sigla;cCodSigExe
				oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:oWSGRPPAREXE:oWSGRPPAREXE[nCmp]:cNumCr  	:= AllTrim( PPLSERGET(IIF(HttpSession->cTp $ '5,6','cNumCrExe','cNumCr')	,aMatGrp[nJ]) ) 			//Num Cr;cNumCrExe
				oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:oWSGRPPAREXE:oWSGRPPAREXE[nCmp]:cEstado  	:= AllTrim( PPLSERGET(IIF(HttpSession->cTp $ '5,6','cEstSigExe','cEstado')	,aMatGrp[nJ]) )			//Estado;cEstSigExe

				If aScan(  aMatGrp[nJ]  ,{|x| AllTrim(x[1]) == "cCbos"  }) > 0
					cEspExe := AllTrim( PPLSERGET('cCbos'	,aMatGrp[nJ]) )
					oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:oWSGRPPAREXE:oWSGRPPAREXE[nCmp]:cEspExe  	:= IIF (HttpSession->cTp == '2', cEspExe, "")
					oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:oWSGRPPAREXE:oWSGRPPAREXE[nCmp]:cCbos  	:= IIF (HttpSession->cTp == '2', "", cEspExe)
				Else
					oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:oWSGRPPAREXE:oWSGRPPAREXE[nCmp]:cCbos  	:= AllTrim( PPLSERGET('cCbosExe'	,aMatGrp[nJ]) )			//Especialidade
				EndIf

				aRetProf := PPSDETPRO(AllTrim( PPLSERGET('cProExeDesc'	,aMatGrp[nJ]) ),"L")

				If Len(aRetProf) > 0
					oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:oWSGRPPAREXE:oWSGRPPAREXE[nCmp]:cNomProf 	:= AllTrim( aRetProf[1,4] )			//Nome Prof.
				EndIf

			EndIf

		Next
	EndIf

	If Type('oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW['+alltrim(str(nI))+']:cCodNeg') <> 'U'
		oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cCodNeg			:= AllTrim( PPLSERGET('cCodNeg',aMatIte[nI]) )						//Status do Procedimento
	Endif

	If Type('oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW['+alltrim(str(nI))+']:cStProc') <> 'U'
		oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cStProc			:= AllTrim( PPLSERGET('cStatus',aMatIte[nI]) )						//Status do Procedimento
	Endif

Next

//Processa Guia
If oObj:PUTAUTHORIZATION()

	//Somente na internacao
	If HttpSession->cTp == '3'

		cDadInt :=	Iif(Empty(cNumAut),'I','P')+"*"+;
			oObj:oWSPUTAUTHORIZATIONRESULT:cMSGCLIENT+"*"+;
			dToc(oObj:oWSPUTAUTHORIZATIONRESULT:dDPrAH)+"*"+;
			oObj:oWSPUTAUTHORIZATIONRESULT:cQTDDAUT+"*"+;
			Iif(Empty(HttpPost->cTpAcom), HttpSession->aVldCartao[18], HttpPost->cTpAcom)+"*"

		//Dados da Rda
		If ! Empty(HttpPost->cNomeSolT)

			If ( nPos := aScan( HttpSession->RDASOLT, { |x| AllTrim(x:cNAME) == AllTrim(HttpPost->cNomeSolT) } ) ) > 0

				//Para a resposta
				cDadInt +=	HttpSession->RDASOLT[nPos]:cCnpfCpf	+"*"+;
					HttpSession->RDASOLT[nPos]:cName+"*"+;
					HttpSession->RDASOLT[nPos]:cCnes+"*"+;
					HttpSession->aVldCartao[20]+"*"

			EndIf

		Else

			//Para a resposta
			If ( nPos := aScan( HttpSession->RDASOLT, { |x| AllTrim(x:cNAME) == AllTrim(HttpPost->cNomeSolT) } ) ) > 0

				//Para a resposta
				cDadInt +=	cCnpjCpfSol+"*"+;
					cNomeRda+"*"+;
					HttpSession->RDASOLT[nPos]:cCnes+"*"+;
					HttpSession->aVldCartao[20]+"*"
			Else

				cDadInt +=	cCnpjCpfSol+"*"+;
					cNomeRda+"*"+;
					''+"*"+;
					HttpSession->aVldCartao[20]+"*"

			EndIf

		EndIf

	EndIf

	//Rda,Nome rda,Nome produto,Servico formatado,Numero da autorizacao,Senha e total
	cResultCab +=	oObj:oWSPUTAUTHORIZATIONRESULT:cNUMBER			+"|"+;	//0
		oObj:oWSPUTAUTHORIZATIONRESULT:cPASSWORD		+"|"+;	//1
		DToC( Date() )									+"|"+;	//2
		DToC(oObj:oWSPUTAUTHORIZATIONRESULT:dDtValSen)	+"|"+;  //3
		cDadInt+"||||||"						        		//4

	cNumGui := oObj:oWSPUTAUTHORIZATIONRESULT:cNUMBER

	//Procedimentos autorizados
	cResultA := ""
	cResultN := ""

	For nI := 1 To Len(oObj:oWSPUTAUTHORIZATIONRESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW)

		nIteAut 	:= 1
		cSequen		:= oObj:oWSPUTAUTHORIZATIONRESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cSequence
		cCodTab		:= oObj:oWSPUTAUTHORIZATIONRESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cTableCode
		cCodPro		:= oObj:oWSPUTAUTHORIZATIONRESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cProcedureCode
		cDesPro		:= StrTran(PadR(oObj:oWSPUTAUTHORIZATIONRESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cDescription,55)," ","&nbsp;")
		cDente    	:= AllTrim(oObj:oWSPUTAUTHORIZATIONRESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cDente)
		cDente    	:= Iif(HttpSession->cTp=="4" , Iif( Empty(cDente),"&nbsp;&nbsp;&nbsp;&nbsp;",cDente ),"" )
		cFace     	:= AllTrim(oObj:oWSPUTAUTHORIZATIONRESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cFace)
		cFace     	:= Iif(HttpSession->cTp=="4" , Iif( Empty(cFace),"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",cFace ),"" )
		cQtdTot		:= StrZero(oObj:oWSPUTAUTHORIZATIONRESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:nQtdTotal,4)

		cQtdUs      := AllTrim(Str(oObj:oWSPUTAUTHORIZATIONRESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:nTotalUS))
		cData       := DtoC(Date())
		cSenhaAu    := oObj:oWSPUTAUTHORIZATIONRESULT:cPASSWORD

		cSenPro		:= oObj:oWSPUTAUTHORIZATIONRESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cSenha

		If (cCodTab+cCodPro) $ HttpSession->cUsuProc
			lProGe :=.T.
		Endif

		//Monta Linha para retorno  em tela
		cResultA += cSequen+"&nbsp;"+cCodTab+"-"+cCodPro+" - "+cDesPro+" - "+cQtdTot+"<br>";

		//Guia de Prorrogacao Senhas dos procedimentos
		If !Empty(cSenPro)
			cResultSenPr += cSenPro+"@"
		EndIf

		For nAl:= 1 To Len(oObj:oWSPUTAUTHORIZATIONRESULT:oWSALERTA:oWSAUTERRORVIEW)

			If oObj:oWSPUTAUTHORIZATIONRESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cSequence == oObj:oWSPUTAUTHORIZATIONRESULT:oWSALERTA:oWSAUTERRORVIEW[nAl]:cSequence .OR.;
					oObj:oWSPUTAUTHORIZATIONRESULT:oWSALERTA:oWSAUTERRORVIEW[nAl]:cSequence == "Alerta"

				cCritica := WCTextNeg( oObj:oWSPUTAUTHORIZATIONRESULT:oWSALERTA:oWSAUTERRORVIEW[nAl]:cCode+" - "+oObj:oWSPUTAUTHORIZATIONRESULT:oWSALERTA:oWSAUTERRORVIEW[nAl]:cDescription )

				//Monta Linha para retorno em tela
				cResAlert +=	cCritica

				AaDd(aAlerta,cCritica )

				lAlerta := .T.
			EndIf
		Next

		AaDd( HttpSession->aResult,{cSequen,cCodTab,cCodPro,cDesPro,cDente,cFace,cQtdTot,{},cQtdUs,cData,cSenhaAu,cSenPro,cDesGRP,cStProc,aAlerta} )

		//Verifica se tem algum procedimento com senha
		If !Empty(cSenPro)
			HttpSession->lSen := .T.
		EndIf

	Next
	//Procedimentos nao autorizados Obs (Nao precisa do if pq e a ultima implementacao)
	For nI:=1 To Len(oObj:oWSPUTAUTHORIZATIONRESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW)-1//10

		nIteNeg   	:= 1
		aCritica 	:= {}
		cSequen		:= oObj:oWSPUTAUTHORIZATIONRESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cSequence
		cCodTab		:= oObj:oWSPUTAUTHORIZATIONRESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cTableCode
		cCodPro		:= oObj:oWSPUTAUTHORIZATIONRESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cProcedureCode
		cDesPro		:= StrTran(oObj:oWSPUTAUTHORIZATIONRESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cDescription," ","&nbsp;")
		cDente    	:= AllTrim(oObj:oWSPUTAUTHORIZATIONRESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cDente)
		cDente    	:= Iif(HttpSession->cTp=="4" , Iif( Empty(cDente),"&nbsp;&nbsp;&nbsp;&nbsp;",cDente ),"" )
		cFace     	:= AllTrim(oObj:oWSPUTAUTHORIZATIONRESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cFace)
		cFace     	:= Iif(HttpSession->cTp=="4" , Iif( Empty(cFace),"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",cFace ),"" )
		cQtdTot		:= StrZero(oObj:oWSPUTAUTHORIZATIONRESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:nQtdTotal,4)
		cQtdUs      := alltrim(Str(oObj:oWSPUTAUTHORIZATIONRESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:nTotalUS))
		cData       := dtoc(date())
		cSenhaAu    := oObj:oWSPUTAUTHORIZATIONRESULT:cPASSWORD

		//Monta Linha para retorno de em tela
		cResultN += cSequen+"&nbsp;"+cCodTab+"-"+cCodPro+" - "+cDesPro+" - "+cQtdTot+"<br>";

		//Procedimentos criticados
		For nY:= 1 To Len(oObj:oWSPUTAUTHORIZATIONRESULT:oWSERROR:oWSAUTERRORVIEW)

			If oObj:oWSPUTAUTHORIZATIONRESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cSequence == oObj:oWSPUTAUTHORIZATIONRESULT:oWSERROR:oWSAUTERRORVIEW[nY]:cSequence

				cCritica := WCTextNeg( oObj:oWSPUTAUTHORIZATIONRESULT:oWSERROR:oWSAUTERRORVIEW[nY]:cCode+" - "+oObj:oWSPUTAUTHORIZATIONRESULT:oWSERROR:oWSAUTERRORVIEW[nY]:cDescription)

				//Monta Linha para retorno em tela
				cResultN +=	cCritica

				//Monta matriz para impressao de guia
				AaDd(aCritica,cCritica )

			EndIf

		Next

		//Monta matriz para impressao de guia
		AaDd( HttpSession->aResult,{cSequen,cCodTab,cCodPro,cDesPro,cDente,cFace,cQtdTot,aCritica,cQtdUs,cData,cSenhaAu,"",cDesGRP,cStProc} )
	Next

	//Monta variaveis de sessao para impressao
	If Len(oObj:oWSPUTAUTHORIZATIONRESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW) > 0

		cImpNoAut := oObj:oWSPUTAUTHORIZATIONRESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[Len(oObj:oWSPUTAUTHORIZATIONRESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW)]:cImpProc

		If cImpNoAut == "0"

			For nC := Len(HttpSession->aResult) To 1 step -1
				If Len(HttpSession->aResult[nC][8]) > 0
					ADEL(HttpSession->aResult,nC)
				EndIf
			Next

			aNoAutTemp := AClone(HttpSession->aResult)
			HttpSession->aResult := {}

			For nP := 1 To Len(aNoAutTemp)
				If aNoAutTemp[nP] != NIL
					AaDd(HttpSession->aResult, aNoAutTemp[nP])
				EndIF
			Next

		EndIF

	EndIF

	HttpSession->cNumeAut	:= Iif(lEvolu,cNumAut,oObj:oWSPUTAUTHORIZATIONRESULT:cNUMBER)
	HttpSession->cSenha		:= Iif(lEvolu,"",oObj:oWSPUTAUTHORIZATIONRESULT:cPASSWORD)
	HttpSession->cCid  		:= cCid

	if HttpPost->cNumeCart = nil
		HttpSession->cNome		:= HttpGet->cNumeCart+" - "+HttpGet->cNomeUsu
	else
		HttpSession->cNome		:= HttpPost->cNumeCart+" - "+HttpPost->cNomeUsu
	endif

	//atenção a alteracao anterior estava causando erro no momento de confirmar uma guia de consulta
	//voltei para o changeset que de-fato corrigiu este problema (285345)
	HttpSession->cNomeSol   := Iif(!Empty(cProSol) .And. !Empty(cNomeSol),cProSol+" - "+cNomeSol,Iif(Empty(HttpPost->cProSol), "", HttpPost->cProSol)+" - "+ Iif(Empty(HttpPost->cNomeSol), "", HttpPost->cNomeSol))//SOL. NAO ENCONTRADO (guia de consulta nao tem solicitante)

	HttpSession->cNomeRda	:= HttpPost->cRda+" - "+cNomeRda
	HttpSession->cIndCli	:= HttpPost->cIndCliSol
	HttpSession->cFormNumber:= HttpPost->cFormNumber

	cStatus := Iif( nIteAut == 1 .and. nIteNeg == 0, "1", Iif( nIteAut == 0 .and. nIteNeg == 1,"3","2") )

	If oObj:oWSPUTAUTHORIZATIONRESULT:lAto .And. cStatus $ "1,2"
		cStatus := "5"
	EndIf

	if cStatus == '1'
		HttpSession->cTitulo := 'Autorizada'
	elseIf cStatus == '2'
		HttpSession->cTitulo := 'Autorizada Parcialmente'
	elseIf cStatus == '3'
		HttpSession->cTitulo := 'Nao Autorizada'
	elseIf cStatus == '4'
		HttpSession->cTitulo := 'Aguardando finalizacao do atendimento'
	elseIf cStatus == '5'
		HttpSession->cTitulo := 'Aguardando Liq. Titulo a Pagar'
	elseIf cStatus == '6'
		HttpSession->cTitulo := 'Em analise pela auditoria'
	endIf

	If oObj:oWSPUTAUTHORIZATIONRESULT:lProcRadio <> Nil .AND. oObj:oWSPUTAUTHORIZATIONRESULT:lProcRadio
		cTextoRadio := "true"
	EndIf

	if ! empty(cDigigui)
		HttpSession->cTitulo := "Guia gravada com sucesso."
	endif

	If nIteAut == 1 .and. nIteNeg == 0

		cResultA := ""

		If lAlerta
			cResultItem := cResultA + cResultN + cResAlert
		Else
			cResultItem := cResultA
		EndIf

	EndIf

	If nIteNeg == 1	.and. nIteAut == 1

		If lAlerta
			cResultItem	:= cResultA+cResultN + cResAlert
		Else
			cResultItem	:= cResultA+cResultN
		EndIf
	EndIf

	If nIteAut == 0 .and. nIteNeg == 1
		cResultItem	:= cResultN
	EndIf

	// RETIRADO O RETORNO DO VALOR DE COPARTICIPAÇÃO DAQUI QUE GRAVA EM UMA SESSION QUE NÃO É UTILIZADA NESSE MOMENTO
	// ESTAVA ONERANDO DESNECESSARIAMENTE A APLICAÇÃO

	//Para digitação de guias off-line o tratamento das críticas e alertas é diferenciado.
	IF ! empty(cDigigui)

		//Incluimos o tratamento de alertas da consulta na digitação off-line nesse trecho pois a digitação off-line não alimenta o array de procedimentos autorizados
		IF HttpSession->cTp == '1' .and. ! Empty(oObj:oWSPUTAUTHORIZATIONRESULT:oWSALERTA:oWSAUTERRORVIEW)

			//Tratamento exclusivo para alertas da guia de consulta
			cCritica := "Foram encontrados alertas no processo: <br>"

			For nAl:= 1 To Len(oObj:oWSPUTAUTHORIZATIONRESULT:oWSALERTA:oWSAUTERRORVIEW)
				cCritica += WCTextNeg( oObj:oWSPUTAUTHORIZATIONRESULT:oWSALERTA:oWSAUTERRORVIEW[nAl]:cCode + " - " +;
					oObj:oWSPUTAUTHORIZATIONRESULT:oWSALERTA:oWSAUTERRORVIEW[nAl]:cDescription + "<br>" )
			Next

			cResultItem := cCritica
			HttpSession->cTitulo := "Guia Gravada - Contêm Alertas."

			lAlerta := .T.

		ELSEIF !Empty(oObj:oWSPUTAUTHORIZATIONRESULT:oWSERROR:oWSAUTERRORVIEW)

			cCritica := "Foram encontradas críticas no processo: <br>"

			For nY:= 1 To Len(oObj:oWSPUTAUTHORIZATIONRESULT:oWSERROR:oWSAUTERRORVIEW)
				cCritica += WCTextNeg( "Procedimento: "+ oObj:oWSPUTAUTHORIZATIONRESULT:oWSERROR:oWSAUTERRORVIEW[nY]:cSequence + ' - '+;
					oObj:oWSPUTAUTHORIZATIONRESULT:oWSERROR:oWSAUTERRORVIEW[nY]:cCode+" - "+oObj:oWSPUTAUTHORIZATIONRESULT:oWSERROR:oWSAUTERRORVIEW[nY]:cDescription + "<br>" )
			Next

			cResultItem := cCritica
			HttpSession->cTitulo := "Guia Gravada - Contêm Críticas."

		ENDIF

	ENDIF

	If oObj:oWSPUTAUTHORIZATIONRESULT:lAudi <> Nil .AND. oObj:oWSPUTAUTHORIZATIONRESULT:lAudi
		cResult := cResultCab + cResultItem + "|" + "Em Análise" + "|"
	ElseIf !empty(cDigigui) .And. oObj:oWSPUTAUTHORIZATIONRESULT:lMudFasOff <> Nil .And. !oObj:oWSPUTAUTHORIZATIONRESULT:lMudFasOff
		cResult := cResultCab + "<br> A guia está sendo processada e em breve poderá consultar no Portal o status da Guia." + cResultItem + "|" + "Atenção! Processo em Andamento" + "|"
	Else
		cResult := cResultCab + cResultItem + "|" + HttpSession->cTitulo + "|"
	EndIf

	If lExecu .And. lFemini .And. lProge
		cResult += "SIM"
	Else
		cResult += "NAO"
	Endif

	cResult += "|" + cResultSenPr + "|" + cTextoRadio + "|"

	If lAlerta
		cResult += "true|"
	Else
		cResult += "false|"
	EndIf

Else
	cResult := "false|" + StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

//Mostra o tempo que durou pra confirmar o atendimento
if httpSession->lTimeAte

	oObjPar := WSCFGDICTIONARY():New()
	IIf (!Empty(PlsGetAuth()),oObjPar:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObjPar, "CFGDICTIONARY.APW" )

	oObjPar:cMsgLog  := Time()+ "|" + Alltrim(Str(Seconds() - nTmpIni)) + "|" + HttpPost->cRDA + "-" + cNomeRda + "|" + HttpSession->cTp  + "|" + IIf(!Empty(HttpPost->cNumAut),"Exec","Solic")  + "| Itens: " + Alltrim(StrZero(Len(aMatIte),3))  + "|" +  cNumGui + "|" + cDigigui
	oObjPar:cFileLog := "ConfirmaAtendimento.txt"
	oObjPar:PutPLSLogFil()

endIf

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLFINCUS
Abre o formulario de inclusao de usuario de intercambio
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLFINCUS()

LOCAL cHtml	:= ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml := ExecInPage( "PPLSINCUSU" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLINCUSU
Executa a inclusao de usuario de intercambio
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLINCUSU()
LOCAL nI
LOCAL oObj
LOCAL cResult := "true|||"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


//Web Service

oObj := WSPLSXINC():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXINC.APW" )

//Alimenta parametros

oObj:cUserCode				:= "MSALPHA"
oObj:OWSINCMAT:cMatricula	:= HttpPost->cMatric
oObj:OWSINCMAT:cNome		:= HttpPost->cNome
oObj:OWSINCMAT:cSexo		:= HttpPost->cSexo
oObj:OWSINCMAT:dDatNas		:= CtoD(HttpPost->cDatNas)

//Inclusao

If oObj:INCUSUARIO()
	If !Empty(oObj:oWSINCUSUARIORESULT:cMatricula)
		cResult := "true|"+oObj:oWSINCUSUARIORESULT:cMatricula+"|"
	Else
		cResult := "false|"
		For nI:=1 To Len(oObj:oWSINCUSUARIORESULT:oWSSMATCRI:oWSGenericStruct)
			cResult += 	oObj:oWSINCUSUARIORESULT:oWSSMATCRI:oWSGenericStruct[nI]:cCode+" - "+;//0
				oObj:oWSINCUSUARIORESULT:oWSSMATCRI:oWSGenericStruct[nI]:cDescription+Chr(13)+Chr(10)//1
		Next
	EndIf
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLFINCPR
Abre o formulario de inclusao de profissional de saude
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLFINCPR()
LOCAL cHtml	:= ""

//Inicio Extended

WEB EXTENDED INIT cHtml START "InSite"

//Direciona para pagina

HttpPost->cRda    := HttpGet->cRda
HttpPost->cCodLoc := HttpGet->cCodLoc
If Type('HttpGet->cTp') <> 'U'
	HttpPost->cTp     := HttpGet->cTp
Else
	HttpPost->cTp     := '1'//tipo execucao, so mostra as especialidades da RDA
Endif
cHtml := ExecInPage( "PPLSINCPRO" )


WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLLISTPCT
Abre o formulário para listagem de pacotes.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLLISTPCT()
LOCAL cHtml	:= ""

//Inicio Extended

WEB EXTENDED INIT cHtml START "InSite"

//Direciona para pagina

HttpPost->cRda    := HttpGet->cRda
HttpPost->cCodLoc := HttpGet->cCodLoc
If Type('HttpGet->cTp') <> 'U'
	HttpPost->cTp     := HttpGet->cTp
Else
	HttpPost->cTp     := '1'//tipo execucao, so mostra as especialidades da RDA
Endif
cHtml := ExecInPage( "PPLSINCPRO" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLPROCPRO
Executa a inclusao de profissional de saude	.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLPROCPRO()
LOCAL oObj
LOCAL cResult := ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


//Web Service

oObj := WSPLSXINC():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXINC.APW" )

//Alimenta parametros

oObj:cUserCode					:= "MSALPHA"
oObj:OWSINCMATPROF:cNome		:= UPPER(HttpPost->cNome)
oObj:OWSINCMATPROF:cCodSig		:= UPPER(HttpPost->cCodSig)
oObj:OWSINCMATPROF:cNumCr		:= UPPER(HttpPost->cNumCr)
oObj:OWSINCMATPROF:cEstado		:= UPPER(HttpPost->cEstado)
oObj:OWSINCMATPROF:cCGC  		:= HttpPost->cCGC
oObj:OWSINCMATPROF:cVinc  		:= HttpPost->cVinc
oObj:OWSINCMATPROF:cRda  		:= HttpPost->cRda
oObj:OWSINCMATPROF:cCodLoc  	:= HttpPost->cCodLoc
oObj:OWSINCMATPROF:cCodEsp  	:= HttpPost->cCodEsp

//Executa o metodo de inclusao	incluir RDA

If oObj:INCPRSAUDE()
	cResult := oObj:cINCPRSAUDERESULT
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLIMPGUIA
Chama formulario de impressao (comprovante)
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLIMPGUIA()
LOCAL cHtml	  := ""
LOCAL cArqAph := ""

WEB EXTENDED INIT cHtml START "InSite"

If HttpSession->lPPLMFUN1

	cRet  := Execblock("PPLMFUN1",.F.,.F.,{})

	cHtml := ExecInPage( cRet )

Else

	cArqAph := PPSAphGuia(HttpSession->cTp)
	cHtml 	:= ExecInPage(cArqAph)

Endif

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLRETOCHA
Retorna para a pagina de digitacao da carteirinha
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLRETOCHA()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml := ExecInPage( "PPLCARTMAT" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLSMONCON
Monta matriz de todos os conselho bah
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSMONCON()
LOCAL nI
LOCAL oObj
LOCAL cResult  	:= "true|"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSMCTMD():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSMCTMD.APW" )

// Parametro

oObj:cUSERCODE := "MSALPHA"

// Executa metodo para pegar os conselhos

If oObj:getSigCon()
	For nI:=1 To Len(oObj:oWSGETSIGCONRESULT:oWSGenericStruct)
		cResult +=	oObj:oWSGETSIGCONRESULT:oWSGenericStruct[nI]:cCode+"$"+;
			oObj:oWSGETSIGCONRESULT:oWSGenericStruct[nI]:cDescription+"|"
	Next
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLTRTIND

@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLTRTIND()
LOCAL cResult 	:= "true|"
LOCAL aMat 	  	:= {}
LOCAL oObj	  	:= Nil
LOCAL cString 	:= HttpGet->cString
LOCAL nI		:= 0
LOCAL cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

If ! Empty(cString)

	While ( nPos := At( "|", cString ) ) > 0
		AaDd( aMat,SubStr( cString, 1, nPos-1 ) )
		cString := SubStr( cString, nPos+1, Len(cString) )
	EndDo

EndIf

If Len(aMat) > 0

	oObj := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLSXFUN.APW" )

	oObj:cUSERCODE := "MSALPHA"

	//Monta Matriz de itens ja executados
	oObj:oWSSAUTPROC:oWSAUTITEM := PLSXFUN_ARRAYOFAUTITEMVIEW():New()

	For nI := 1 To Len(aMat)

		If ! empty(aMat[nI])

			//Monta dados dos itens
			aMatIte := PPLSALIMA(aMat[nI]+'||')

			//Alimenta a estrutura para envio dos procedimentos ja executados
			AaDd( oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW, PLSXFUN_AUTITEMVIEW():New() )

			//Quantidade de itens
			nQtd := Len( oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW )

			//Atribui dados ao obj
			oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cCODPAD 				:= AllTrim( PPLSERGET('cCodPad',aMatIte[1]) )
			oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cPROCEDURECODE 		:= AllTrim( PPLSERGET('cCodPro',aMatIte[1]) )

		Endif

	Next

	If oObj:PPINDCLIN()

		If oObj:oWSPPINDCLINRESULT:OWSSTRATIND[1]:LOBRIGAT .AND. Empty(HttpGet->cIndCli)

			cResult := "false|Indicacao Clinica deve ser informada para pelo menos um dos procedimentos informados."

			return PLSDECODE(cResult)

		Endif

	Endif

	oObj:oWSSAUTPROC:oWSAUTITEM := nil

Endif

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSINCITE

@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSINCITE()

LOCAL aMat 	  	:= {}
LOCAL cString 	:= HttpGet->cString


WEB EXTENDED INIT cHtml START "InSite"


//Pega o conteudo
If !Empty(cString)
	While ( nPos := At( "|", cString ) ) > 0
		AaDd( aMat,SubStr( cString, 1, nPos-1 ) )
		cString := SubStr( cString, nPos+1, Len(cString) )
	EndDo
EndIf

WEB EXTENDED END

getLOGMon()

return

/*/{Protheus.doc} PPLSAUTITE
Valida e inclui dados do procedimento,qtd e codpad
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSAUTITE()
LOCAL nI	  	:= 0
LOCAL nQtd		:= 0
LOCAL nPos	  	:= 0
LOCAL nPosRDA   := 0
LOCAL lPror		:= .F.
LOCAL cResult 	:= "true|"
LOCAL aMat 	  	:= {}
LOCAL oObj	  	:= Nil
LOCAL cString 	:= HttpGet->cString
LOCAL cHtml		:= ""
Local nTmpIni 	:= Seconds()

WEB EXTENDED INIT cHtml START "InSite"

//Pega o conteudo
If ! Empty(cString)
	While ( nPos := At( "|", cString ) ) > 0
		AaDd( aMat,SubStr( cString, 1, nPos-1 ) )
		cString := SubStr( cString, nPos+1, Len(cString) )
	EndDo
EndIf

//Verifica se foi enviado algum registro para tratamento
If Len(aMat) >= 2

	//Registro no WS
	oObj := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLSXFUN.APW" )
	oObj:cUSERCODE := "MSALPHA"

	If Type("HttpGet->cCodPro") <> "U"	.and. Type("HttpGet->cIndCli") <> "U" .and. Type("HttpGet->cCodPad") <> "U"

		oObj:oWSSAUTPROC:oWSAUTITEM := PLSXFUN_ARRAYOFAUTITEMVIEW():New()
		AaDd( oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW, PLSXFUN_AUTITEMVIEW():New() )
		oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[1]:cCODPAD 				:= AllTrim( HttpGet->cCodPad )
		oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[1]:cPROCEDURECODE 		:= AllTrim( HttpGet->cCodPro )

		If oObj:PPINDCLIN()

			If oObj:oWSPPINDCLINRESULT:OWSSTRATIND[1]:LOBRIGAT .AND. Empty(HttpGet->cIndCli)
				cResult := "false|Indicacao Clinica deve ser informada para este procedimento."
				return PLSDECODE(cResult)
			Endif

		Endif

		oObj:oWSSAUTPROC:oWSAUTITEM := nil
	Endif

	oObj:ccRecno := iIf(ValType(Httpget->cRecnoBD5) == "C", Httpget->cRecnoBD5, "")
	oObj:cDigiGui:= IIF(ValType(HttpSession->cDigitacao) == "C", HttpSession->cDigitacao, "")

	//Monta Matriz de itens ja executados

	If Len(aMat) > 3

		oObj:oWSSAUTPROC:oWSAUTITEM := PLSXFUN_ARRAYOFAUTITEMVIEW():New()

		For nI := 3 To Len(aMat)

			If ! Empty(aMat[nI])

				//Monta dados dos itens

				aMatIte := PPLSALIMA(aMat[nI]+'||')

				//Alimenta a estrutura para envio dos procedimentos ja executados

				AaDd( oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW, PLSXFUN_AUTITEMVIEW():New() )

				//Quantidade de itens

				nQtd := Len( oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW )

				//Atribui dados ao obj

				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cCODPAD 				:= AllTrim( PPLSERGET('cCodPad',aMatIte[1]) )
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cPROCEDURECODE 		:= AllTrim( PPLSERGET('cCodPro',aMatIte[1]) )
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:nPROCEDUREQUANTITY		:= Val( PPLSERGET('nQtdSol',aMatIte[1]) )
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cHORINI				:= HttpGet->cHrSolicit
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cDENTE					:= AllTrim( PPLSERGET('cDente',aMatIte[1]) )
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cFACE					:= AllTrim( PPLSERGET('cFace',aMatIte[1]) )
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cSEQUENCE				:= aMat[1]


				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:nVlrApr  				:= Val( StrTran(strtran(PPLSERGET('nVlrApr',aMatIte[1]),',',''),'.','') )/100
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cResAut				:= AllTrim( PPLSERGET('cResAut',aMatIte[1]) )
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cIndCliEvo 			:= AllTrim( PPLSERGET('cIndCliEvo',aMatIte[1]) )
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cHorIni 				:= AllTrim( StrTran(PPLSERGET('cHorIni',aMatIte[1]),':','') )
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cHorFim 				:= AllTrim( StrTran(PPLSERGET('cHorFim',aMatIte[1]),':','') )
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cViaAc 				:= AllTrim( PPLSERGET('cViaAc',aMatIte[1]) )
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cTecUt 				:= AllTrim( strtran(PPLSERGET('cTecUt',aMatIte[1]), ',', '' ) )
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:nRedAcre 				:= Val( PPLSERGET('nRedAcre',aMatIte[1] ) )
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cDiagPro 				:= PPLSERGET('cDiagPro',aMatIte[1])

			EndIf

		Next

	EndIf

	// Na solicitacao da prorrogacao tenho que verificar o Contratato Solicitado

	If HttpSession->cTp == '3'
		lPror := (HttpGet->cChkPro == '1')
	EndIf

	// Rda

	If valType(HttpSession->RDAVIEW) == 'A' .and. ! lPror
		nPosRDA := aScan( HttpSession->RDAVIEW, { |x| x:cCODE == HttpGet->cRda .And. x:cCodLoc == HttpGet->cCodLoc} )
	EndIf

	// Verifica RDA

	If nPosRDA > 0 .or. lPror

		//Parametros de envio
		if HttpSession->cTp == '5'

			oObj:oWSSAUTPROC:cCarSol 	:=  HttpGet->cCarSolicit
			oObj:oWSSAUTPROC:cCnes 		:=	HttpGet->cCnes
			oObj:oWSSAUTPROC:cCid2 		:=	HttpGet->cCid2
			oObj:oWSSAUTPROC:cCid3 		:=	HttpGet->cCid3
			oObj:oWSSAUTPROC:cCid4 		:=	HttpGet->cCid4
			oObj:oWSSAUTPROC:cCid5 		:=	HttpGet->cCidObt
			oObj:oWSSAUTPROC:cTipSai 	:=	HttpGet->cTpSai
			oObj:oWSSAUTPROC:cTipFat 	:=	HttpGet->cTipFaT
			oObj:oWSSAUTPROC:cIndAci 	:=	HttpGet->cIndAcid
			oObj:oWSSAUTPROC:cTipInt 	:=	HttpGet->cTpIntern
			oObj:oWSSAUTPROC:cNumSol 	:=	HttpGet->cNumInt
			oObj:oWSSAUTPROC:cNumGuiTrc :=	HttpGet->cNumGuiTrc

			oObj:oWSSAUTPROC:cDtIniF 	:=  HttpGet->dDataIniFat
			oObj:oWSSAUTPROC:cHrIniF 	:=	HttpGet->cHorIniFat
			oObj:oWSSAUTPROC:cDtFimF 	:=	HttpGet->dDataFimFat
			oObj:oWSSAUTPROC:cHrFimF	:=	HttpGet->cHorFimFat

			oObj:oWSSAUTPROC:cCodOpe	:=	HttpGet->cCodOpe
			oObj:oWSSAUTPROC:cCodLdp	:=	HttpGet->cCodLdp
			oObj:oWSSAUTPROC:cCodPeg	:=	HttpGet->cCodPeg
			oObj:oWSSAUTPROC:cNumero	:=	HttpGet->cNumero
			oObj:oWSSAUTPROC:cSeqMov    :=  HttpGet->cSequen
			oObj:oWSSAUTPROC:cRegAte	:=  HttpGet->cRegInter
			oObj:oWSSAUTPROC:cOperacao	:=  HttpGet->cOperacao
			oObj:oWSSAUTPROC:cObserv	:=  HttpGet->cObserv
			oObj:oWSSAUTPROC:cListProc 	:=	HttpGet->cListProc
		endif

		If (HttpSession->cTp == '2' .Or. HttpSession->cTp == '3')
			oObj:oWSSAUTPROC:cCarSol 	:=  HttpGet->cCarSolicit
		endIf

		oObj:oWSSAUTPROC:cRegInter 	:= Iif(ValType(HttpGet->cRegInt) <> 'U',HttpGet->cRegInt,"")
		oObj:oWSSAUTPROC:cRda		:= HttpGet->cRDA
		oObj:oWSSAUTPROC:cCodLoc	:= HttpGet->cCodLoc
		oObj:oWSSAUTPROC:cOpeRda 	:= Iif(!lPror,HttpSession->RDAVIEW[nPosRDA]:cCodOpe,HttpGet->cOpeSolT )
		oObj:oWSSAUTPROC:cTipPre 	:= Iif(!lPror,HttpSession->RDAVIEW[nPosRDA]:cTipPE,"")

		if HttpSession->cTp <> '5'
			oObj:oWSSAUTPROC:cRegAte := Iif(!lPror,HttpSession->RDAVIEW[nPosRDA]:cRegAtend,"")
		endif

		oObj:oWSSAUTPROC:cMatric 	:= HttpSession->aVldCartao[2]
		oObj:oWSSAUTPROC:cCdpfSo 	:= HttpGet->cProSol
		oObj:oWSSAUTPROC:cCodExe 	:= Iif(ValType(HttpGet->cProExe) <> 'U',HttpGet->cProExe,"")
		oObj:oWSSAUTPROC:cTipGui 	:= HttpSession->cTp
		oObj:oWSSAUTPROC:cPadInt 	:= Iif(ValType(HttpGet->cTpAcom) <> 'U',HttpGet->cTpAcom,"") //HttpSession->aVldCartao[18]
		oObj:oWSSAUTPROC:cPadCon 	:= Iif(ValType(HttpGet->cPadCon) <> 'U',HttpGet->cPadCon,"") //HttpSession->aVldCartao[19]
		oObj:oWSSAUTPROC:cAreaAbr	:= HttpSession->aVldCartao[7]
		oObj:oWSSAUTPROC:dDatPro 	:= IIF(EmpTy(httpSession->dDtaAtend),;//Pode vir nessa session, caso o Post venha vazio..
			IIF(Empty(HttpPost->dDtAtend),; 	//Se vier vazio, não é Consulta
			IIF(EmpTy(HttpPost->dDtExe),;		//Se vier vazio, não é SADT
			IIF(EmpTy(Httpget->dDtExePro),;		//Se vier vazio, não é Internação
			Date(),;								//Se não achou nada, retorna a data atual
			CtoD(HttpGet->dDtExePro)),;	//Se for Digitação de guias de Internação, pega esse Get
			CtoD(HttpPost->dDtExe)),;		//Se for Digitação de guias de SADT, pega esse Get
			CtoD(HttpPost->dDtAtend)),;		//Se for Digitação de guias de Consulta, pega esse Get
			CtoD(httpSession->dDtaAtend)) //Se veio na session, pega o valor da session
		//Data do procedimento
		//fiz isso porque na digitação offline, como preenchia o datpro do procedimento com a data do atendimento, tava permitindo o usuário colocar uma data
		//anterior a data da solicitação... tem que validar sempre com a data do procedimento na guia.
		//POSTERIORMENTE será necessário colocar para as novas guias tbm HONORARIO e RESUMO de internação e ver qual o nome do campo de data que vai utilizar...
		//Por enquanto temos apenas a SADT
		If valtype(HttpGet->dDtExePro) == 'C' .and. valType(HttpSession->cDigitacao) == "C" .and. Capital(HttpSession->cDigitacao) == "Digitacao" .AND. HttpSession->cTp == '2'
			oObj:oWSSAUTPROC:dDatPro := cToD(HttpGet->dDtExePro)
		endIf

		If ValType(HttpGet->cHrSolicit) <> 'U'
			oObj:oWSSAUTPROC:cHorPro 	:= HttpGet->cHrSolicit
		Else
			oObj:oWSSAUTPROC:cHorPro 	:= strtran(Substr(Time(),1,5),':','')
		Endif
		oObj:oWSSAUTPROC:cSequen 	:= aMat[1]
		oObj:oWSSAUTPROC:cMatRet 	:= aMat[2] + "~"
		oObj:oWSSAUTPROC:cCodPad 	:= Alltrim(HttpGet->cCodPad)
		oObj:oWSSAUTPROC:cCodPro 	:= HttpGet->cCodPro
		oObj:oWSSAUTPROC:nQtdPro 	:= IIf(ValType(HttpGet->nQtdSol) <> 'U',Val(HttpGet->nQtdSol), 1)  //Proteção para evita problemas na cemig
		oObj:oWSSAUTPROC:cCid	 	:= HttpGet->cCid
		oObj:oWSSAUTPROC:cAteRN 	:= HttpGet->cAteRN
		oObj:oWSSAUTPROC:cGrpInt 	:= ""
		oObj:oWSSAUTPROC:cDente  	:= HttpGet->cDente
		oObj:oWSSAUTPROC:cFace  	:= HttpGet->cFace
		oObj:oWSSAUTPROC:cChavLib	:= Iif( HttpSession->cTp != '3' ,allTrim(strTran(strTran(httpGet->cNumAut,".",""),"-","")),"")

		If ValType(HttpSession->cDigitacao) == "C" .and. Capital(HttpSession->cDigitacao) == "Digitacao" //Na digitação offLine é sempre Execução
			oObj:oWSSAUTPROC:cTipoProc	:= "E"
		else
			oObj:oWSSAUTPROC:cTipoProc	:= Iif( HttpSession->cTp != '3', Iif( Empty(HttpGet->cNumAut),'S','E'),'S')
		EndIf

		oObj:oWSSAUTPROC:cCbos		:= Left(HttpGet->cCbos,3)
		oObj:oWSSAUTPROC:cEndCon	:= HttpSession->cEndCon
		oObj:oWSSAUTPROC:cChvBD6	:= HttpGet->cChvBD6
		oObj:oWSSAUTPROC:cValorApr	:= iif(HttpSession->cTp == '4', HttpGet->nVlrApr, HttpGet->cVlrUniSExe) // StrTran(strtran( iif(HttpSession->cTp == '4', HttpGet->nVlrApr, HttpGet->cVlrUniSExe) ,',',''),'.','')

		oObj:oWSSAUTPROC:cHorIni 	:= Iif(HttpGet->cHorIni <> NIL, HttpGet->cHorIni, "")
		oObj:oWSSAUTPROC:cHorFim 	:= Iif(HttpGet->cHorFim <> NIL, HttpGet->cHorFim, "")
		oObj:oWSSAUTPROC:cViaAc 	:= Iif(HttpGet->cViaAc <> NIL, HttpGet->cViaAc, "")

		if HttpGet->cTecUt <> nil .and. allTrim(HttpGet->cTecUt) <> ""
			oObj:oWSSAUTPROC:cTecUt := strTran(HttpGet->cTecUt, ",", "")
		else
			oObj:oWSSAUTPROC:cTecUt := ""
		endif

		if HttpGet->nRedAcre <> nil .and. allTrim(HttpGet->nRedAcre) <> ""
			oObj:oWSSAUTPROC:nRedAcre 	:= val(HttpGet->nRedAcre)
		else
			oObj:oWSSAUTPROC:nRedAcre 	:= 1
		endif

		If HttpSession->cTp == "11"
			oObj:oWSSAUTPROC:cNumSol :=	HttpGet->cGuiaOpe
		EndIF

		If valtype(HttpGet->cListProc) == 'C' .And. !Empty(HttpGet->cListProc)
			oObj:oWSSAUTPROC:cListProc :=	HttpGet->cListProc
		EndIF

		//Executa o metodo pega o retorno
		If oObj:AutProc()

			//Se foi autorizado ou negado

			If oObj:oWSAUTPROCRESULT:lPROAUT
				cResult += "1|"
			Else
				cResult += "Critica(s)|"
			EndIf

			//Matriz que retorna os resultados formatados campo a campo do formulario

			cResult += oObj:oWSAUTPROCRESULT:cMatRetRes+"|"

			//Monta a string de retorno

			cResult += oObj:oWSAUTPROCRESULT:cAUTORI+"|"+;
				oObj:oWSAUTPROCRESULT:cCHAVE+"|"+;
				oObj:oWSAUTPROCRESULT:cNIVEL+"|"

			//Monta as criticas

			For nI:=1 To Len(oObj:oWSAUTPROCRESULT:oWSMATCRI:oWSGenericStruct)
				cResult += 	oObj:oWSAUTPROCRESULT:oWSMATCRI:oWSGenericStruct[nI]:cCode+" - "+;//0
					oObj:oWSAUTPROCRESULT:oWSMATCRI:oWSGenericStruct[nI]:cDescription//1
			Next
			cResult += "|"

			If ValType(oObj:oWSAUTPROCRESULT:cLembrete) <> 'U'
				cResult += oObj:oWSAUTPROCRESULT:cLembrete+"|"
			EndIf

			For nI:=1 To Len(oObj:oWSAUTPROCRESULT:oWSALERTA:oWSGenericStruct)
				cResult += 	oObj:oWSAUTPROCRESULT:oWSALERTA:oWSGenericStruct[nI]:cCode+" - "+;//0
					oObj:oWSAUTPROCRESULT:oWSALERTA:oWSGenericStruct[nI]:cDescription//1
			Next

			If Len(oObj:oWSAUTPROCRESULT:oWSALERTA:oWSGenericStruct) > 0

				If !oObj:oWSAUTPROCRESULT:lPROAUT
					cResult += "| e Alerta(s)|"
				Else
					cResult += "|Alerta(s)|"
				EndIf
			EndIf

			If ValType(oObj:oWSAUTPROCRESULT:cTpProc) == "C" .and. oObj:oWSAUTPROCRESULT:cTpProc <> ""

				If ValType(oObj:oWSAUTPROCRESULT:cLembrete) = 'U'
					cResult += "|"
				endif

				If Len(oObj:oWSAUTPROCRESULT:oWSALERTA:oWSGenericStruct) <= 0
					cResult += "|"
				endif

				cResult += "|" + oObj:oWSAUTPROCRESULT:cTpProc + "|"
			endif

			if HttpSession->cTp = '5' .and. HttpGet->cOperacao  = "I"
				cResult += "|" + oObj:oWSAUTPROCRESULT:cNumGui + "|"
			endif

		Else
			cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
		EndIf
	Else
		cResult := "false|RDA invalida"
	EndIf
Else
	cResult := "false|Nenhum registro para tratamento"
EndIf

WEB EXTENDED END

//Mostra o tempo que durou pra confirmar o atendimento
if httpSession->lTimeAte

	oObjPar := WSCFGDICTIONARY():New()
	IIf (!Empty(PlsGetAuth()),oObjPar:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObjPar, "CFGDICTIONARY.APW" )

	oObjPar:cMsgLog  := Time()+ "|" + Alltrim(Str(Seconds() - nTmpIni)) + "|" + HttpGet->cRDA + "|" + HttpGet->cCodPro + "|" + HttpSession->cTp
	oObjPar:cFileLog := "IncluiDespesa.txt"
	oObjPar:PutPLSLogFil()

endIf

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSHORPAR
Inclui itens para processamento do honorario
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSHORPAR()
LOCAL cResult := "true|"
LOCAL oObj	  := Nil
LOCAL cHtml := ""
local nJ
local aMatGrp := {}
local nOpc
local nRecno
local cTable

WEB EXTENDED INIT cHtml START "InSite"


//Obj WebService

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros

oObj:cUSERCODE 				:= "MSALPHA"
oObj:oWSSAUTPROC:cRda		:= HttpGet->cRda
oObj:oWSSAUTPROC:cNomRda	:= HttpGet->cNomeRdaExe
oObj:oWSSAUTPROC:cChavLib	:= AllTrim( StrTran(StrTran(HttpGet->cGuiaInter,".",""),"-","") )
oObj:oWSSAUTPROC:cChvBD6	:= HttpGet->cChvBD6
oObj:oWSSAUTPROC:cGrPar		:= HttpGet->cGrPar
oObj:oWSSAUTPROC:cSeqMov 	:= HttpGet->cSeqMov
oObj:oWSSAUTPROC:cCodPad 	:= HttpGet->cCodPad
oObj:oWSSAUTPROC:cCodPro 	:= HttpGet->cCodPro
oObj:oWSSAUTPROC:nQtdPro 	:= Val(HttpGet->nQtdSol)
oObj:oWSSAUTPROC:cNomExe  	:= HttpGet->cNomExe
oObj:oWSSAUTPROC:cCodSig 	:= HttpGet->cCodSigExe
oObj:oWSSAUTPROC:cNumCr	 	:= HttpGet->cNumCrExe
oObj:oWSSAUTPROC:cEstado   	:= HttpGet->cEstSigExe
oObj:oWSSAUTPROC:dDatPro   	:= IIF(EmpTy(httpSession->dDtaAtend),;//Pode vir nessa session, caso o Post venha vazio..
	IIF(Empty(HttpPost->dDtAtend),; 	//Se vier vazio, não é Consulta
	IIF(EmpTy(HttpPost->dDtExe),;		//Se vier vazio, não é SADT
	IIF(EmpTy(Httpget->dDtExePro),;		//Se vier vazio, não é Internação
	Date(),;								//Se não achou nada, retorna a data atual
	CtoD(HttpGet->dDtExePro)),;	//Se for Digitação de guias de Internação, pega esse Get
	CtoD(HttpPost->dDtExe)),;		//Se for Digitação de guias de SADT, pega esse Get
	CtoD(HttpPost->dDtAtend)),;		//Se for Digitação de guias de Consulta, pega esse Get
	CtoD(httpSession->dDtaAtend)) //Se veio na session, pega o valor da session

nOpc    :=  HttpGet->nOpc
nRecno	:=  HttpGet->nRecno
cTable	:=  HttpGet->cTable

If aScan(  ClassDataArr(oObj:oWSSAUTPROC)   ,{|x| AllTrim(x[1]) == "CTISSVER"  }) > 0

	//Recupera a versão da TISS
	oObj:oWSSAUTPROC:cTissVer := HttpGet->cTissVer

EndIf


// Monta matriz de participações

If !Empty(HttpGet->cMatTabExe)
	aMatGrp := PPLSALIMA(HttpGet->cMatTabExe, .T.)
EndIf

//oObj:oWSSAUTPROC:oWSGRPPAREXE := PLSXFUN_ARRAYOFGRPPAREXE():New()

oObj:oWSSAUTPROC:cGrpParExe = ""

For nJ := 1 To Len(aMatGrp)
	oObj:oWSSAUTPROC:cGrpParExe += AllTrim( PPLSERGET('cGrPar'	,aMatGrp[nJ]) )  + ";"
next


//Executa o metodo pega o retorno

If oObj:VldHoPar()

	If oObj:oWSVLDHOPARRESULT:lPROAUT
		cResult += "S|" + nOpc + "|" + nRecno + "|" + cTable + "|"
	else
		cResult += "N|" + PLSDECODE(oObj:oWSVLDHOPARRESULT:cMatRetRes)
	endif

endif

WEB EXTENDED END

getLOGMon()

return cResult

/*/{Protheus.doc} PPLSHORITE
Inclui itens para processamento do honorario
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSHORITE()
LOCAL nI	  := 0
LOCAL nPosBD6 := 0
LOCAL cResult := "true|"
LOCAL oObj	  := Nil
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

//Obj WebService

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros
oObj:cUSERCODE 				:= "MSALPHA"
oObj:oWSSAUTPROC:cRda		:= HttpGet->cRda
oObj:oWSSAUTPROC:cNomRda	:= HttpGet->cNomeRdaExe
oObj:oWSSAUTPROC:cChavLib	:= AllTrim( StrTran(StrTran(HttpGet->cGuiaInter,".",""),"-","") )
oObj:oWSSAUTPROC:cChvBD6	:= HttpGet->cChvBD6
oObj:oWSSAUTPROC:cGrPar		:= HttpGet->cGrPar
oObj:oWSSAUTPROC:cSeqMov 	:= HttpGet->cSeqMov
oObj:oWSSAUTPROC:cCodPad 	:= HttpGet->cCodPad
oObj:oWSSAUTPROC:cCodPro 	:= HttpGet->cCodPro
oObj:oWSSAUTPROC:nQtdPro 	:= Val(HttpGet->nQtdSol)
oObj:oWSSAUTPROC:cNomExe  	:= HttpGet->cNomExe
oObj:oWSSAUTPROC:cCodSig 	:= HttpGet->cCodSigExe
oObj:oWSSAUTPROC:cNumCr	 	:= HttpGet->cNumCrExe
oObj:oWSSAUTPROC:cEstado   	:= HttpGet->cEstSigExe
oObj:oWSSAUTPROC:cNumAuxi  	:= iif(valType(HttpGet->cNumMaxAux) <> 'U', HttpGet->cNumMaxAux, '0')
oObj:oWSSAUTPROC:dDatPro   	:= IIF(EmpTy(httpSession->dDtaAtend),;//Pode vir nessa session, caso o Post venha vazio..
	IIF(Empty(HttpPost->dDtAtend),; 	//Se vier vazio, não é Consulta
	IIF(EmpTy(HttpPost->dDtExe),;		//Se vier vazio, não é SADT
	IIF(EmpTy(Httpget->dDtExePro),;		//Se vier vazio, não é Internação
	Date(),;								//Se não achou nada, retorna a data atual
	CtoD(HttpGet->dDtExePro)),;	//Se for Digitação de guias de Internação, pega esse Get
	CtoD(HttpPost->dDtExe)),;		//Se for Digitação de guias de SADT, pega esse Get
	CtoD(HttpPost->dDtAtend)),;		//Se for Digitação de guias de Consulta, pega esse Get
	CtoD(httpSession->dDtaAtend)) //Se veio na session, pega o valor da session


If aScan(  ClassDataArr(oObj:oWSSAUTPROC)   ,{|x| AllTrim(x[1]) == "CTISSVER"  }) > 0

	//Recupera a versão da TISS
	oObj:oWSSAUTPROC:cTissVer := HttpGet->cTissVer

EndIf

If ValType(HttpSession->aMatBD6) <> 'U'

	//Para garantir se incluiu e excluiu do browse

	nPosBD6 := aScan( HttpSession->aMatBD6, { |x| !empty(x:cSeqInf) .and.  allTrim(x:cCodPad) == allTrim(HttpGet->cCodPad) .and. allTrim(x:cCodPro) == allTrim(HttpGet->cCodPro)} )
	if nPosBD6>0
		HttpSession->aMatBD6[nPosBD6]:cSeqInf := ""
	endIf

	oObj:oWSSAUTPROC:oWSMATBD6  		 	:= PLSXFUN_ARRAYOFSMATBD6():New()
	oObj:oWSSAUTPROC:oWSMATBD6:oWSSMATBD6	:= HttpSession->aMatBD6
EndIf

//Executa o metodo pega o retorno

If oObj:VldHoIn()

	//Se foi autorizado ou negado

	If oObj:oWSVLDHOINRESULT:lPROAUT
		cResult += "1|"
		If oObj:oWSVLDHOINRESULT:nPosBD6>0
			HttpSession->aMatBD6[oObj:oWSVLDHOINRESULT:nPosBD6]:cSeqInf := oObj:oWSVLDHOINRESULT:cSeqInf
		EndIf
	Else
		cResult += "0|"
	EndIf

	//Monta as criticas

	For nI:=1 To Len(oObj:oWSVLDHOINRESULT:oWSMATCRI:oWSGenericStruct)
		cResult += 	oObj:oWSVLDHOINRESULT:oWSMATCRI:oWSGenericStruct[nI]:cCode+" - "+;//0
			oObj:oWSVLDHOINRESULT:oWSMATCRI:oWSGenericStruct[nI]:cDescription//1
	Next
	cResult += "|"
	If(valType(HttpGet->cSeqPro))<>'U'
		cResult += HttpGet->cSeqPro + "|"
	Else
		cResult += "|"
	EndIf

	If(valType(HttpGet->nOpc))<>'U'
		cResult += HttpGet->nOpc + "|"
	Else
		cResult += "|"
	EndIf

	If(valType(HttpGet->nRecno))<>'U'
		cResult += HttpGet->nRecno + "|"
	Else
		cResult += "|"
	EndIf

Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSALIMA
Alimenta matriz de itens
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function PPLSALIMA(cString, lExec)
	local nPos		:= 0
	local nPosAux	:= 0
	local nPosAux2	:= 0
	local cCmpOri	:= ''
	local cCmpGer	:= ''
	local cCmpC		:= ''
	local cCmpV		:= ''
	LOCAL aMatRet	:= {}

	//Monta campos da matriz
	If ! Empty(cString)

		//Linhas
		While ( nPos := At( "|", cString ) ) > 0

			cCmpOri := SubStr( cString, 1, nPos-1 )
			cString := SubStr( cString, nPos+1, Len(cString) )

			//Colunas
			If ( ! Empty(cString) .or. lExec) .and. ! Empty(cCmpOri)

				cMatDin := "{|| AaDd(aMatRet,{"
				While ( nPosAux := At( "$", cCmpOri  ) ) > 0

					If nPosAux > 0

						cCmpGer := SubStr( cCmpOri, 1, nPosAux-1 )
						nPosAux2 := At( "@", cCmpGer  )
						cCmpOri := SubStr( cCmpOri, nPosAux+1, Len(cCmpOri) )

						//Campo e valor
						cCmpC := SubStr( cCmpGer, 1, nPosAux2-1 )
						cCmpV := AllTrim(SubStr( cCmpGer, nPosAux2+1, Len(cCmpGer) ))

						//Inclui na matriz
						cMatDin +="{'"+cCmpC+"','"+cCmpV+ "'}" + Iif( !Empty(cCmpOri),",","}) }")

					EndIf

				EndDo

				//Inclui na matriz de retrono
				Eval(&cMatDin)

			EndIf

		EndDo

	EndIf

Return aMatRet

/*/{Protheus.doc} PPLSCHALIB
Procura a liberacao e mostra os dados
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSCHALIB()
LOCAL nI      	:= 0
LOCAL oObj	  	:= NIL
LOCAL lExibe  	:= .F.
LOCAL cResult 	:= "true|"
LOCAL cOpme   	:= ""
LOCAL cQuimio	:= ""
LOCAL cValGDExe	:= ""
LOCAL cHtml := ""
LOCAL cSetDtInt := ""
LOCAL cCriticas := ""
Local cValPr		:= "0"

WEB EXTENDED INIT cHtml START "InSite"


//Web Service

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros de entrada

oObj:cUserCode 		 := "MSALPHA"
oObj:cNumAut   		 := AllTrim(StrTran(StrTran(HttpGet->cNumeAut,".",""),"-",""))

//A solicitacao deve informar o tipo.

If ValType(HttpSession->aVldCartao) != 'U'
	oObj:cUserCardNumber := HttpSession->aVldCartao[2]
EndIf
oObj:cPacotes := HttpGet->cPacote
oObj:cTipo		:= HttpGet->cTp
//oObj:cRDACode	:= HttpGet->cRda
oObj:cCodLoc	:= HttpGet->cCodLoc
oObj:cTipoAut	:= IiF( ValType(HttpGet->cTpAut) != 'U',HttpGet->cTpAut,"L")

cSetDtInt := Iif(!Empty(HttpGet->SetDtInt),HttpGet->SetDtInt,"0")

oObj:cSetDtInt	:= cSetDtInt

cValPr				:= iif( ValType(HttpGet->cVPerDig) != 'U', HttpGet->cVPerDig, "0")

if cSetDtInt = "1"
	oObj:cRDACode	:= StrTran(PLA09ASES(),"|M",",")
else
	oObj:cRDACode	:= HttpGet->cRda
endif

oObj:cAltera	:= Iif(!Empty(HttpGet->cAltGuia),HttpGet->cAltGuia,"")
oObj:cCRecno	   := Iif(!Empty(HttpGet->cRecno),HttpGet->cRecno,"0")
if !empty(HttpGet->cCodLoc)
	nPosRDA := aScan( HttpSession->RDAVIEW, { |x| x:cCODE == HttpGet->cRda .And. x:cCodLoc == HttpGet->cCodLoc} )
else
	nPosRDA := aScan( HttpSession->RDAVIEW, { |x| x:cCODE == HttpGet->cRda} )
endIf
if nPosRDA > 0 .AND. ValType(HttpSession->RDAVIEW[nPosRDA]:OWSMESPRDA:OWSESPRDA) == "A"
	If Len(HttpSession->RDAVIEW[nPosRDA]:OWSMESPRDA:OWSESPRDA) > 0
		oObj:cCodEsp := HttpSession->RDAVIEW[nPosRDA]:OWSMESPRDA:OWSESPRDA[1]:cCodEsp
	EndIf
endif

if ValType(HttpGet->cTipoOrigem) != 'U' .and. !empty(HttpGet->cTipoOrigem)

	oObj:cDigiGui := HttpGet->cTipoOrigem
	oObj:cTipGui := HttpGet->cTipoGuia
	oObj:cDatGuia := HttpSession->dDtaAtend

endIf

//Caso coloque o número da Liberação, para validar a data com base na data de atendimento, e não na data atual
if cValPr == "1"
	oObj:ccOpcao  := "1"
	oObj:cDatGuia := HttpSession->dDtaAtend
Endif


//Executa metodo para retorno da liberacao

If oObj:RetAutLib()

	aClasse := ClassDataArr(oObj:OWSRetAutLibRESULT:OWSSCABGUI)

	If aScan(aClasse,{|x| AllTrim(x[1]) == "CPRVOPM"  }) > 0
		cOpme   := oObj:OWSRetAutLibRESULT:OWSSCABGUI:cPrvOpm
	EndIf

	If aScan(aClasse,{|x| AllTrim(x[1]) == "CPRVQUI"  }) > 0
		cQuimio := oObj:OWSRetAutLibRESULT:OWSSCABGUI:cPrvQui
	EndIf


	//Cabecalho

	cResult +=	"cRegAns!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cRegAns+"|"+;				//0
		"cNomeRdaSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomeRda+"|"+; 		//1
		"cCnpjCpfSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cCnpjCpfSol+"|"+;		//2
		"cCnesSol!"+iif(HttpGet->cTp = "06", HttpSession->RDAVIEW[nPosRDA]:OWSMESPRDA:OWSESPRDA[1]:cCnes, oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cCnesSol)+"|"+;      		//3
		"dDtAut!"+DToC(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:dDtAut)+"|"+;        //4
		"cSenha!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cSenha+"|"+;           	//5
		"dDtValid!"+DToC(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:dDtValid)+"|"+;    //6
		"dDtSolicit!"+DToC(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:dDtSolicit)+"|"+;//7
		"cHrSolicit!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cHrSolicit+"|"+;   	//8
		"cCarSolicit!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cCarSolicit+"|"+; 	//9
		"cCid!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cCid+"|"+;               	//10
		"cProSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cProSol+"|"+;         	//11
		"cOpeSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cOpeSol+"|"+;         	//12
		"cNomeSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomeSol+"|"+;       	//13
		"cCodSigSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cCodSigSol+"|"+;   	//14
		"cNumCrSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNumCrSol+"|"+;     	//15
		"cEstSigSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cEstSigSol+"|"+;   	//16
		"cObs!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cObs+"|"+;         			//17
		"cIndCliSol!"+ WTDecode(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cIndCli) +"|"+;         //18
		"cChvBD6!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cChvBD6+"|"+;				//19
		"cCbosSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cCbosSol+'$'+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDescCbosSol+"|"+; //20
		"cTpAto!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cTipAto+"|"+; //21
		"cTpIntern!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cTpIntern+"|"+; //22
		"cRegInter!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cRegInter+"|"+; //23
		"cQtdDSol!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cQtdDSol+"|"+; //24
		"cTpDoe!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cTipDoe+"|"+; //25
		"cTmpDoe!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cTmpDoe+"|"+; //26
		"cTmpDoeC!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cUndDoe+"|"+; //27
		"cIndAcid!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cIndAcid+"|"+; //28
		"cCid2!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cCid2+"|"+; //29
		"cCid3!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cCid3+"|"+; //30
		"cCid4!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cCid4+"|"+; //31
		"dDPrAH!"+DToC(oObj:OWSRetAutLibRESULT:OWSSCABGUI:dDPrAH)+"|"+; //32
		"cQtdDAut!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cQtdDAut+"|"+; //33
		"cQtdDAutPro!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cQtdDAut+"|"+; //34
		"cTpAcom!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cTpAcom+"|"+; //35
		"cCnpjCpfAut!"+Iif(Empty(oObj:OWSRetAutLibRESULT:OWSSCABGUI:cCnpjSolT),oObj:OWSRetAutLibRESULT:OWSSCABGUI:cCnpjCpfSol,oObj:OWSRetAutLibRESULT:OWSSCABGUI:cCnpjSolT)+"|"+; //36
		"cNomeRdaAut!"+Iif(Empty(oObj:OWSRetAutLibRESULT:OWSSCABGUI:cCnpjSolT),oObj:OWSRetAutLibRESULT:OWSSCABGUI:cNomeRda,oObj:OWSRetAutLibRESULT:OWSSCABGUI:cNomeSolT)+"|"+; //37
		"cCnesAut!"+Iif(Empty(oObj:OWSRetAutLibRESULT:OWSSCABGUI:cCnpjSolT),oObj:OWSRetAutLibRESULT:OWSSCABGUI:cCnesSol,oObj:OWSRetAutLibRESULT:OWSSCABGUI:cCnesSolT)+"|"+; //38
		"cCnpjSolT!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cCnpjSolT+"|"+; //39
		"cNomeSolT!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cNomeSolT+"|"+; //40
		"cTpAcomPro!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cTpAcom+"|"+; //41
		"cDesAcomPro!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cDesAcom+"|"+; //42
		"cRdaSolT!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cRdaSolT+"|"+; //43
		"cProfSolT!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cProfSolT+"|"+; //44
		"cOpeSolT!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cOpeSolT+"|"+; //45
		"dDatInt!"+DToC(oObj:OWSRetAutLibRESULT:OWSSCABGUI:dDatInt)+"|"+; //46
		"cHorInt!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cHrAut+"|"+; //47
		"dDatAlt!"+DToC(oObj:OWSRetAutLibRESULT:OWSSCABGUI:dDatAlt)+"|"+; //48
		"cHorAlt!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cHorAlt+"|"+; //49
		"cCancel!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cCancel+"|"+;//50
		"cStatus!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cDesSTAut+"|"+;//51
		"cNumeCart!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cMatric+"|"+;//52
		"cNomeUsu!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cNomeUsr+"|"+;//53
		"cFindEvo!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cFindEvo+"|"+;//54
		"dDtEmissao!"+DToC(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:dDtAut)+"|"+;//55
		"cPlano!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cNomPla+"|"+;//56
		"cVldCarteira!"+DToC(oObj:OWSRetAutLibRESULT:OWSSCABGUI:dDtVldCar)+"|"+;//57
		"cCarSaud!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cCarSaud+"|"+;//58
		"cGrPar!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cGrPar+"|"+;//59
		"cGraPartExe!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cGrPar+"|"+;//59
		"cTpFat!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cTipFat+"|"+; //60
		"cQtdDPro!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cQtdDPro+"|"+; //61
		"cAtendRN!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cAteRN+"|"+; //62
		"cAtenRN!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cAteRN+"|"+; //63
		"cOpme!"+cOpme+"|"+; //64
		"cQuimio!"+cQuimio+"|"+; //65
		"dDtRlz!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz,"")+"|"+; //66
		"dDtRlz2!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz2),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz2,"")+"|"+; //67
		"dDtRlz3!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz3),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz3,"")+"|"+; //68
		"dDtRlz4!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz4),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz4,"")+"|"+; //69
		"dDtRlz5!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz5),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz5,"")+"|"+; //70
		"dDtRlz6!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz6),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz6,"")+"|"+; //71
		"dDtRlz7!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz7),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz7,"")+"|"+; //72
		"dDtRlz8!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz8),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz8,"")+"|"+; //73
		"dDtRlz9!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz9),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz9,"")+"|"+; //74
		"dDtRlz1!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz1),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDtRlz1,"")+"|"+; //75
		"cTpAteExe!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cTipAte),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cTipAte,"")+"|"+; // 76
		"cIndAcid!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cIndAci),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cIndAci,"")+"|"+; // 77
		"cTpSai!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cTipSai),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cTipSai,"")+"|"+; // 78
		"cTipCon!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cTipCon),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cTipCon,"")+"|"+; // 79
		"cTpCon!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cTipCon),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cTipCon,"")+"|"+; //80
		"cCodSigExe!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cTipCon),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cCCPECO,"")+"|"+; //81
		"cNumCrExe!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cTipCon),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cRGEXCO,"")+"|"+; //82
		"cEstSigExe!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cTipCon),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cEXECCO,"")+"|"+; //83
		"cCbosExe!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cTipCon),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cCEPCCO,"")+"|"+; //84
		"cProSol!" + IIF(HttpGet->cTp == '01' .AND. (oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cProSol == ""), oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cPREXCC,"" )+"|"+; //85
		"cFormNumber!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNumImp+"|"+; //86
		"cGralau!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cGralau+"|"+; //87
		"cProSolDesc!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomeSol+"|"+; //88
		"cProtoc!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cProtoc+"|" //89

	if ValType(oObj:OWSRetAutLibRESULT:OWSSCABGUI:cCobEspW) == "C"
		cResult += "cCobertEsp!" + oObj:OWSRetAutLibRESULT:OWSSCABGUI:cCobEspW+"|" //112
	endif

	if ValType(oObj:OWSRetAutLibRESULT:OWSSCABGUI:cTipAut) == "C"
		cResult += "cTipAlt!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cTipAut+"|" //96
	EndIf

	if ValType(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNumAux) == "C"
		cResult += "cNumMaxAux!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNumAux+"|"
	endif

	If ValType(oObj:OWSRetAutLibRESULT:OWSSCABGUI:cGuiaOpe) == "C"
		cResult += "cGuiaOpe!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cGuiaOpe+"|" //110
	EndIf

	If ValType(oObj:OWSRetAutLibRESULT:OWSSCABGUI:cGuiaPri) == "C"
		cResult += "cNumInt!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cGuiaPri+"|" //111
	EndIf
	cResult += "<" //Fim

	//Número de auxiliares
	HttpSession->cNumAux := oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNumAux


	// Matriz de itens
	For nI := 1 To Len(oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI)

		If oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cExibe == "1"

			lExibe := .T.

			aClasse := ClassDataArr(oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI])

			cDiagno := ''

			if aScan(aClasse,{|x| AllTrim(x[1]) == "CDIAGNO"  }) > 0
				cDiagno := oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cDiagno
			endIf

			cResult +=	"cTpServ!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cTpServ+"@"+; //0
				"cExibe!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cExibe+"@"+;  //1
				"cCodPad!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cCodPad+"@"+; //2
				"cCodPro!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cCodPro+"@"+; //3
				"cDesPro!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cDesPro+"@"+; //4
				"nQtdSol!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cQtdSol+"@"+; //5
				"nQtdAut!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cQtdAut+"@"+; //6
				"cFabric!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cFabric+"@"+; //7
				"nVlrApr!"+AllTrim( TransForm( oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nVlrApr,"@U 999,999,999.99" ) )+"@"+;//8
				"cDente!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cDente+"@"+;//9
				"cFace!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cFace+"@"+;//10
				"nQtdUs!"+AllTrim( TransForm( oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nQtdUs,"@U 999,999,999.99" ) )+"@"+;//11
				"nVlrCon!"+AllTrim( TransForm( oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nVlrCon,"@U 999,999,999.99" ) )+"@"+;//12
				"nVlrTpf!"+AllTrim( TransForm( oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nVlrTpf,"@U 999,999,999.99" ) )+"@"+;//13
				"cStatus!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cAutori+"@"+;//14
				"cSeqMov!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cSequencia+"@"+;//15
				'dDtExePro!'+DToC(oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:dDtExe)+"@"+;//16
				'cSenhaPro!'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cSenha+"@"+;//17
				'cResAutPro!'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cResAut+"@"+;//18
				'cHorIni!'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cHorIni+"@"+;//19
				'cHorFim!'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cHorFim+"@"+;//20
				'cViaAc!'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cViaAc+"@"+;//21
				'cTecUt!'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cTecUt+"@"+;//22
				'nRedAcre!'+AllTrim( TransForm( oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nRedAcre,"@U 999.99" ) )+"@"+;//23
				'nVlrTAp!'+AllTrim( TransForm( oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nVlrTAp,"@U 999,999,999.99" ) )+"@"+;
				'cDiagPro!'+cDiagno+"@"+;//24
				'cVlrPro!'+AllTrim( TransForm( oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nVlrApr,"@U 999,999,999.99" ) )+"@"+;//para guia de consulta
				'dDtAtend!'+DToC(oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:dDtExe)+"@"+;//16
				'lPacote!'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cPacote+"@"+;
				'cTpProc!'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cTpProc+"~"//25

			// Esse item ira montar o grid na session, foi necessario pois na chamada da liberação pela sesssion esta vazia ele perdia os procedimentos
			cValGDExe :="cTpServ$"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cTpServ+";"+; //0
				"cExibe$"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cExibe+";"+;  //1
				"cCodPadSExe$"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cCodPad+";"+; //2 ***
				"cCodProSExe$"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cCodPro+";"+; //3 ***
				"cDesProSExe$"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cDesPro+";"+; //4 ***
				"cQtdSExe$"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cQtdAut+";"+; //6 ***
				"cFabric$"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cFabric+";"+; //7
				"nVlrUniSExe$"+AllTrim( TransForm( oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nVlrApr,"@U 999,999,999.99" ) )+";"+;//8 ***
				"cDente$"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cDente+";"+;//9
				"cFace$"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cFace+";"+;//10
				"nQtdUs$"+AllTrim( TransForm( oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nQtdUs,"@U 999,999,999.99" ) )+";"+;//11
				"nVlrCon$"+AllTrim( TransForm( oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nVlrCon,"@U 999,999,999.99" ) )+";"+;//12
				"nVlrTotSExe$"+AllTrim( TransForm( oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nVlrTpf,"@U 999,999,999.99" ) )+";"+;//13 ***
				"cStatus$"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cAutori+";"+;//14
				"cSeqMov$"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cSequencia+";"+;//15
				'dDtExe$'+DToC(oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:dDtExe)+";"+;//16 ***
				'cSenhaPro$'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cSenha+";"+;//17
				'cResAutPro$'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cResAut+";"+;//18
				'cHorIniSExe$'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cHorIni+";"+;//19 ***
				'cHorFimSExe$'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cHorFim+";"+;//20 ***
				'cViaSExe$'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cViaAc+";"+;//21 ***
				'cTecSExe$'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cTecUt+";"+;//22 ***
				'nRedAcreSExe$'+AllTrim( TransForm( oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nRedAcre,"@U 999.99" ) )+";"+;//23
				'nVlrTAp$'+AllTrim( TransForm( oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nVlrTAp,"@U 999,999,999.99" ) )+";"+;
				'cDiagPro$'+cDiagno+";"+;//24
				'cTpProc$'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cTpProc+";"//25


		EndIf
		If !Empty(cValGDExe)
			PTrGdLib(cValGDExe,"TabExeSer")
		EndIf
	Next

	// Matriz de criticas
	if( Len(oObj:OWSRETAUTLIBRESULT:OWSSCriGui:oWsAutErrorView) > 0)
		For nI:=1 To Len(oObj:OWSRETAUTLIBRESULT:OWSSCriGui:oWsAutErrorView)
			if !("&nbsp;" $ oObj:OWSRETAUTLIBRESULT:OWSSCriGui:oWsAutErrorView[nI]:cCode)
				cCriticas += oObj:OWSRETAUTLIBRESULT:OWSSCriGui:oWsAutErrorView[nI]:cCode + " - "
				cCriticas += oObj:OWSRETAUTLIBRESULT:OWSSCriGui:oWsAutErrorView[nI]:cDescription + ";"
			endIf
		Next
		cCriticas := LEFT(cCriticas, (len(cCriticas)-1))
	endIf

	//Gravo os atributos necessarios para o metodo 'isDupGui'
	cTipGui := oObj:cTipo
	cCodUsr := oObj:cUserCode
	cCodRda := oObj:cRdaCode
	cGuiRef := oObj:cNumAut
	cMatric := oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cMatric
	cDatGui := DtoS(Date())


	//Honorario Individual

	If HttpSession->cTp == '5'
		oObj:cNumPeg :=  oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cChvBD6
		If oObj:GetBD6()
			HttpSession->aMatBD6 := oObj:oWSGETBD6RESULT:OWSSMATBD6
		EndIf
	EndIf

	// Parametros para retornar se a guia eh duplicada
	oObj:cUserCode			:= cCodUsr
	oObj:cRdaCode			:= cCodRda
	oObj:cTipGui			:= cTipGui
	oObj:cUserCardNumber	:= cMatric
	oObj:cNumGuiRef			:= cGuiRef
	oObj:cDatGuia		 	:= cDatGui

	// Verifica se a guia pode estar sendo duplicada
	cResult += "<" //coloquei aqui pra garantir no js que essa posição vai ser sempre do isdupgui
	if oObj:isDupGui()
		cResult += SubStr(oObj:cIsDupGuiRESULT,6)
	endif

	cResult += "<" + cCriticas //criticas


	// Se nao tem procedimento

	If !lExibe
		cResult := "false|Nenhum procedimento autorizado para o executante!"
	EndIf
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSALERT
Procura a liberacao e mostra os dados
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function PPLSALERT( cMsgInternal, cTopo, cMsg, cPagVolta )
	LOCAL cHtml 	:= ""
	LOCAL cMsgError := PWSGetWSError( cMsgInternal )

	cMsgError := SubStr(cMsgError,At(":",cMsgError)+1,Len(cMsgError))

	WEB EXTENDED INIT cHtml START "InSite"

	HttpSession->_HTMLERRO := { NIL, NIL, NIL }

	If Empty( cMsg )
		If !Empty( cMsgError )
			cMsg := cMsgError
		Endif
	Endif

	//Variavel  para exibir

	HttpSession->_HTMLERRO[1] := cTopo
	HttpSession->_HTMLERRO[2] := cMsg
	HttpSession->_HTMLERRO[3] := cPagVolta

	//Envia para o determinado formulario

	cHtml += ExecInPage( "PPLSMSG" )

	WEB EXTENDED END

	getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLSREIPAR
Rotina chama formulario de parametros reimpressao da guia
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSREIPAR()
LOCAL cHtml	:= ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PPLSPAREIM" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLSREIMGU
Rotina para reimpressao da guia
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSREIMGU()
LOCAL oObj		:= nil
LOCAL cHtml 	:= ""
local lPostRda	:= valType(HttpPost->cRda) <> 'U'

WEB EXTENDED INIT cHtml START "InSite"

//Obj
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametro

oObj:cUSERCODE 	:= "MSALPHA"

//Conforme informações, a tratativa de retirada do "ponto" e do "traço" foi devido a uma tratativa antiga,
//porém conforme as novas telas do portal , exemplo a nova tela de atendimento, esta funcionalidade de retirar
//o "ponto" e "traço" foi descontinuado. Por isso retiramos também da reimpressão, conforme abaixo
oObj:cUserCardNumber:= HttpPost->cMatricula
oObj:cRDACode		:= iIf(lPostRda, SubStr( HttpPost->cRda,1,At('|',HttpPost->cRda)-1 ), "")
oObj:cCodLoc		:= iIf(lPostRda, SubStr( HttpPost->cRda,At('|',HttpPost->cRda)+1 ), "")

If ! empty(HttpPost->cDtAut)
	oObj:dDtAut := cToD(HttpPost->cDtAut)
Else
	oObj:dDtAut := cToD("")
EndIf


//Chama metodo para traser todas as guias do usuario na data e prestador

If oObj:RetAut()
	HttpSession->aMatGuia := { oObj:OWSRETAUTRESULT:OWSSMATAUT }
Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLSREIPAR.APW" )
EndIf

//Envia para o formulario
cHtml += ExecInPage( "PPLSREIMGU" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLSMATREI
Alimenta a matriz para reimpressao da guia
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSMATREI()
LOCAL oObj,oObjX  := NIL
LOCAL nI,nY       := 0
LOCAL nPos		  := 0
LOCAL cHtml   	  := ""
LOCAL cSequen	  := ""
LOCAL cCodTab	  := ""
LOCAL cCodPro	  := ""
LOCAL cDesPro	  := ""
LOCAL cDente	  := ""
LOCAL cFace	  	  := ""
LOCAL cQtdTot	  := ""
LOCAL cCritica	  := ""
LOCAL cQtdUs      := ""
LOCAL cData       := ""
LOCAL cSenhaAu    := ""
LOCAL cSenPro	  := ""
LOCAL cDesGRP	  := ""
LOCAL aCBox		  := {}
Local cArqAph 	  := ""
Local lProrrog  	  := (HttpGet->lProrrog <> Nil .and. HttpGet->lProrrog == '.T.')

WEB EXTENDED INIT cHtml START "InSite"


//Sessao para impressao da guia

HttpSession->aResult := {}
HttpSession->lSen 	 := .F.

//Web Service

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros de entrada

oObj:cUserCode		 := "MSALPHA"
oObj:cUserCardNumber := ""
oObj:cNumAut         := AllTrim(StrTran(StrTran(HttpGet->cNumGuia,".",""),"-",""))
oObj:cTipoAut        := "A"
oObj:cCampos         := "BEA_STATUS"
oObj:cTipo		     := HttpGet->cTp
oObj:cReimpressao    := "1"
HttpSession->cTp 	 := HttpGet->cTp

//Monta o box de um determinado campo

If oObj:GetBox()
	aCBox := oObj:OWSGETBOXRESULT:OWSGENERICSTRUCT
EndIf

//Executa metodo para retorno das guia

If oObj:RetAutLib()

	//Alimenta variaveis

	cStatusGuia 			:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cSTAut
	HttpSession->cNumeAut	:= HttpGet->cNumGuia
	HttpSession->cSenha		:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cSenha
	HttpSession->cCid  		:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cCid
	HttpSession->DtPro 		:= DToC(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:dDtAut)
	HttpSession->HrPro		:= Transform( oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cHrAut, "@R 99:99" )
	HttpSession->cNome		:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cMatric + " - " + oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomeUsr
	HttpSession->cNomeSol	:= Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cProSol),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cProSol+" - "+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomeSol,"")
	HttpSession->cNomeRda	:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cRda + " - " + oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomeRda
	HttpSession->cIndCli	:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cIndCli
	If Type('oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cFormNumber') <> 'U'
		HttpSession->cFormNumber:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cFormNumber
	Else
		HttpSession->cFormNumber:= ''
	Endif
	cData       			:= DtoC(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:dDtAut)
	cSenhaAu    			:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cSenha
	cGrPar					:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cGrPar

	// Se ainda nao existir crio

	If ValType(HttpSession->aGrPart) == 'U'

		//Web Service

		oObjX := WSPLSXFUN():New()
		IIf (!Empty(PlsGetAuth()),oObjX:_HEADOUT :=  { PlsGetAuth() },)
		WsChgURL( @oObjX, "PLSXFUN.APW" )

		// Propriedade

		oObjX:cUserCode	:= "MSALPHA"
		oObjX:cTipo 	:= HttpGet->cTp

		// Executando Metodo

		If oObjX:GetDadG()
			HttpSession->aGrPart := oObjX:oWSGetDadGRESULT:oWSCbGraPar:oWSGenericStruct
		EndIf
	EndIf

	// Descricao do Grau de participacao

	If (nPos := aScan( HttpSession->aGrPart, { |x| x:cCODE == cGrPar} ) ) > 0
		cDesGRP := HttpSession->aGrPart[nPos]:CDESCRIPTION
	EndIf

	//Tipo de Guia

	Do Case

		// Consulta

		Case HttpSession->cTp == '1'
			HttpSession->cTpComprov	:= 'Consulta - Execução'

			// Sadt

		Case HttpSession->cTp == '2'
			HttpSession->cTpComprov	:= 'Sadt - Solicitação'
			If oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cOrigem == '1'
				HttpSession->cTpComprov	:= 'Sadt - Execução'
			EndIf

			// Internacao

		Case HttpSession->cTp == '3'
			HttpSession->cTpComprov	:= 'Inter./Prorrog. - Solic./Exec.'

			// Odontologico

		Case HttpSession->cTp == '4'
			HttpSession->cTpComprov	:= 'Odontológico - Solicitação'
			If oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cOrigem == '1'
				HttpSession->cTpComprov	:= 'Odontológico - Execução'
			EndIf

			// Honorario Individual

		Case HttpSession->cTp == '5'
			HttpSession->cTpComprov	:= 'Honorário Individual'
	EndCase

	//Itens e criticas

	For nI := 1 To Len( oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI )
		If HttpGet->lProrrog <> Nil .and. !lProrrog .and. !Empty(oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cSenha)
			Loop
		EndIf

		aCritica 	:= {}
		cSequen		:= oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cSequencia
		cCodTab		:= oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cCodPad
		cCodPro		:= AllTrim( oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cCodPro )
		cDesPro		:= StrTran(PadR(oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cDesPro,55)," ","&nbsp;")
		cDente    	:= AllTrim(oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cDente)
		cDente    	:= Iif(HttpSession->cTp=="4" , Iif( Empty(cDente),"&nbsp;&nbsp;&nbsp;&nbsp;",SubStr(cDente,1,At('-',cDente)-1) ),"" )
		cFace     	:= AllTrim(oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cFace)
		cFace     	:= Iif(HttpSession->cTp=="4" , Iif( Empty(cFace),"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",SubStr(cFace,1,At('-',cFace)-1) ),"" )

		If oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cOrigem == '2'  //solicitação
			cQtdTot		:= StrZero(Val(oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cQtdSol),4)
		Else
			cQtdTot		:= StrZero(Val(oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cQtdAut),4)
		Endif

		cQtdUs      := AllTrim( Str(oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nQtdUs) )
		cSenPro		:= oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cSenha

		//Criticas

		For nY:=1 To Len(oObj:OWSRETAUTLIBRESULT:OWSSCRIGUI:oWSAUTERRORVIEW)
			If oObj:OWSRETAUTLIBRESULT:OWSSCRIGUI:oWSAUTERRORVIEW[nY]:cSequence == oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cSequencia
				cCritica := "&nbsp;&nbsp;&nbsp;&nbsp;<samp class='TextoNegPeq'>"+oObj:OWSRETAUTLIBRESULT:OWSSCRIGUI:oWSAUTERRORVIEW[nY]:cCode+" - "+;
					oObj:OWSRETAUTLIBRESULT:OWSSCRIGUI:oWSAUTERRORVIEW[nY]:cDescription+"</samp><br>"

				// Monta matriz para impressao de guia

				AaDd(aCritica,cCritica )
			EndIf
		Next

		// Monta matriz para impressao de guia

		AaDd( HttpSession->aResult,{cSequen,cCodTab,cCodPro,cDesPro,cDente,cFace,cQtdTot,aCritica,cQtdUs,cData,cSenhaAu,cSenPro,cDesGRP} )

		// Verifica se tem algum procedimento com senha

		If !Empty(cSenPro)
			HttpSession->lSen := .T.
		EndIf
	Next

	//Continua alimentando variaves para impressao

	If oObj:GetBox()
		HttpSession->cTitulo := aCBox[Ascan( aCBox, {|x| x:cCODE == cStatusGuia} )]:CDESCRIPTION
	EndIf

	//Formulario de impressao de guia

	HttpSession->cBVolt := "1"

	//Retorna o valor da co-participacao

	If !Empty(HttpSession->cNumeAut)  .And. HttpSession->cTp <> '5'
		oObj:CNUMAUT := AllTrim(StrTran(StrTran(HttpSession->cNumeAut,".",""),"-",""))
		If oObj:GetVlrCo() .AND. oObj:OWSGETVLRCORESULT:NVLRPF > 0
			HttpSession->aVlrPF := {}
			AaDd(HttpSession->aVlrPF,oObj:OWSGETVLRCORESULT:CGUIACO)//1
			AaDd(HttpSession->aVlrPF,oObj:OWSGETVLRCORESULT:NVLRPF)//2
			AaDd(HttpSession->aVlrPF,oObj:OWSGETVLRCORESULT:NVLRBPF)//3
			AaDd(HttpSession->aVlrPF,oObj:OWSGETVLRCORESULT:NPERCPF)//4
			AaDd(HttpSession->aVlrPF,oObj:OWSGETVLRCORESULT:NVLRTPF)//5
			AaDd(HttpSession->aVlrPF,oObj:OWSGETVLRCORESULT:NVLRTAD)//6
			AaDd(HttpSession->aVlrPF,oObj:OWSGETVLRCORESULT:CEXIBECO)//7
			AaDd(HttpSession->aVlrPF,oObj:OWSGETVLRCORESULT:CEXIBEBA)//8
			AaDd(HttpSession->aVlrPF,oObj:OWSGETVLRCORESULT:CPAGRDA)//9

			//Mensagens

			AaDd(HttpSession->aVlrPF,oObj:OWSGETVLRCORESULT:CMSG001)//10
			AaDd(HttpSession->aVlrPF,oObj:OWSGETVLRCORESULT:CMSG002)//11
			AaDd(HttpSession->aVlrPF,oObj:OWSGETVLRCORESULT:CMSG003)//12
			AaDd(HttpSession->aVlrPF,oObj:OWSGETVLRCORESULT:CMSG004)//13
			AaDd(HttpSession->aVlrPF,oObj:OWSGETVLRCORESULT:CMSG005)//14
			AaDd(HttpSession->aVlrPF,oObj:OWSGETVLRCORESULT:CMSG006)//15
			AaDd(HttpSession->aVlrPF,oObj:OWSGETVLRCORESULT:CMSG007)//16
			AaDd(HttpSession->aVlrPF,oObj:OWSGETVLRCORESULT:CMSG008)//17
			AaDd(HttpSession->aVlrPF,oObj:OWSGETVLRCORESULT:CMSG009)//18
			AaDd(HttpSession->aVlrPF,oObj:OWSGETVLRCORESULT:CMSG010)//19
		EndIf
	EndIf

	If HttpSession->lPPLMFUN1

		cRet  := Execblock("PPLMFUN1",.F.,.F.,{})
		cHtml := ExecInPage( cRet )
	Else

		cArqAph := PPSAphGuia(HttpSession->cTp)
		cHtml := ExecInPage(cArqAph)

	Endif

Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLSREIPAR.APW" )
EndIf

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLSCHAAL
Rotina chama form de alteracao de senha
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSCHAAL()
LOCAL cHtml	:= ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PPLALTSEN" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLSCHEPAS
Altera a senha do usuario
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSCHEPAS()
LOCAL oObj
LOCAL cResult := "true|"
LOCAL lRet	  := .T.
Local nX      := 0
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


//obj

oObj := WSUSERPORTAL():NEW()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgUrl(@oObj,"USERPORTAL.apw")

oObj:cUSERCODE := "MSALPHA"

//Verifica se a senha confere

If !(AllTrim( GetUsrSenha() ) == HttpGet->Field_SENHA)
	Return cResult := PLSDECODE("false|Senha não confere")
Endif


//Verifica se a nova senha Tem tamanho 8

If LEN(AllTrim(HttpGet->Field_NEWSEN)) < 8
	lRet := .F.
Endif
If lRet
	// Verifica se existe pelo menos 1 digito
	lRet:= .F.
	FOR nX := 1 TO Len(Alltrim(HttpGet->Field_NEWSEN))
		IF ISDIGIT((SUBSTR(Alltrim(HttpGet->Field_NEWSEN),nX,1))) .Or.;
				!LETTERORNUM(SUBSTR(Alltrim(HttpGet->Field_NEWSEN),nX,1))
			lRet := .T.
			Exit
		ENDIF
	NEXT nX
Endif
If !lRet
	Return cResult := PLSDECODE("false|Por segurança a senha deve ter 8 caracteres, sendo pelo menos 1 caractere não-alfabético (numérico ou caractere especial)")
Endif


//Metodo

If oObj:PRTPSWUSER( getUsrWeb() , AllTrim(GetUsrSenha()), HttpGet->Field_NEWSEN, HttpSession->cTipoPortal)
	If !SetUsrSenha( HttpGet->Field_NEWSEN )
		HttpFreeSession()
	Endif

	//Faz a validacao da senha e criptografa, faz a gravacao do campo data.
	//Alterado por Ronaldo Dantas

	HttpGet->Field_NEWSEN := PLSCRIDEC(1,Alltrim(HttpGet->Field_NEWSEN))

	cResult := "true|Senha alterada com sucesso"
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
Endif

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSCHAHIS
Rotina chama form de Historico de utilizacao
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSCHAHIS()

LOCAL cHtml	:= ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PPLHISUTI" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLSPROHIS
Rotina processar e chama form de Historico de utilizacao
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSPROHIS()
LOCAL oObj
LOCAL cResult := ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


//Web Service

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros de entrada

oObj:cUSERCODE				:= "MSALPHA"
oObj:oWSMViewPar:cCodLog	:= HttpPost->Field_CODUSU
oObj:oWSMViewPar:cDateDe   	:= HttpPost->Field_DTDE
oObj:oWSMViewPar:cDateAte  	:= HttpPost->Field_DTATE
oObj:oWSMViewPar:cHorDe    	:= HttpPost->Field_HRDE
oObj:oWSMViewPar:cHorAte   	:= HttpPost->Field_HRATE

//Executa metodo para retorno das guia

If oObj:GetHistLogin()
	HttpSession->aMatHisUti := { oObj:OWSGETHISTLOGINRESULT:OWSSVIEWHISTLOG }
	cResult := "true|"
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSCHFORH
Abre o formulario com resultado da utilizacao do usuario
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSCHFORH()

LOCAL cHtml	:= ""

//Inicio Extended

WEB EXTENDED INIT cHtml START "InSite"

//Direciona para pagina

cHtml := ExecInPage( "PPLMOSHIUT" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLS673PA
Rotina chama formulario de parametros extrato rda
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLS673PA()
LOCAL cHtml	:= ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PPLROTDESC" )

WEB EXTENDED END

Return cHtml

/*/{Protheus.doc} PPLEXE673
Executa o relatorio 673 extrato da rda
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLEXE673()
LOCAL oObj
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


//Cria variavel de sessao

If ValType(HttpPost->cRda) <> 'U'
	HttpSession->cRDARel := SubStr( HttpPost->cRda,1,At('|',HttpPost->cRda)-1 )
	HttpSession->cCodLoc := SubStr( HttpPost->cRda,At('|',HttpPost->cRda)+1 )
	HttpSession->cAnoRel := HttpPost->cAno
	HttpSession->cMesRel := HttpPost->cMes
EndIf


//Web Service

oObj := WSPLSRELT():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSRELT.APW" )

//Obj

oObj:cUSERCODE 			:= "MSALPHA"
oObj:oWSINPAR:cRDA 		:= HttpSession->cRdaRel
oObj:oWSINPAR:cCodLoc   := HttpSession->cCodLoc
oObj:oWSINPAR:cAno		:= HttpSession->cAnoRel
oObj:oWSINPAR:cMes 		:= HttpSession->cMesRel

//Executa metodo

If oObj:REL673S()
	FT_FUse( oObj:cREL673SRESULT )
	FT_FGotop()

	// Todas as linhas

	HttpSession->aMatRel := {}
	While ( !FT_FEof() )
		cRelato := FT_FREADLN()
		If At("RPC",cRelato) == 0
			AaDd( HttpSession->aMatRel, StrTran(cRelato ," ","&nbsp;") + CRLF  )
		EndIf
		FT_FSkip()
	EndDo

	// Fecha o arquivo

	FT_FUse()
Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLS673PA.APW" )
EndIf

//Define rotina

HttpSession->cRotRel := "W_PPLEXE673.APW"

//Chama o formulario

cHtml += ExecInPage( "PPLMOSREL" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLS754PA
 Extrato de Utilizacoes
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLS754PA()
LOCAL cHtml	:= ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PPLROTDESC" )

WEB EXTENDED END

Return cHtml

/*/{Protheus.doc} PPLEXE754
Executa o relatorio 754 Extrato de Utilizacao
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLEXE754()
LOCAL oObj	:= nil
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


//Cria variavel de sessao

If ValType(HttpPost->cRda) <> 'U'
	HttpSession->cRDARel	:= SubStr( HttpPost->cRda,1,At('|',HttpPost->cRda)-1 )
	HttpSession->cCodLoc   	:= SubStr( HttpPost->cRda,At('|',HttpPost->cRda)+1 )
	HttpSession->cDtDe		:= HttpPost->cDtDe
	HttpSession->cDtAte  	:= HttpPost->cDtAte
	HttpSession->cGuia   	:= HttpPost->cGuia
	HttpSession->cTipo   	:= HttpPost->cTipo
EndIf


//Web Service

oObj := WSPLSRELT():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSRELT.APW" )

//Obj

oObj:cUSERCODE 			:= "MSALPHA"
oObj:oWSINPAR:cRDA		:= HttpSession->cRDARel
oObj:oWSINPAR:cCodLoc   := HttpSession->cCodLoc
oObj:oWSINPAR:dDtDe		:= CToD(HttpSession->cDtDe)
oObj:oWSINPAR:dDtAte	:= CToD(HttpSession->cDtAte)
oObj:oWSINPAR:cGuia 	:= HttpSession->cGuia
oObj:oWSINPAR:cTipo 	:= HttpSession->cTipo

//Executa metodo

If oObj:REL754S()
	FT_FUse( oObj:cREL754SRESULT )
	FT_FGotop()

	// Todas as linhas

	HttpSession->aMatRel := {}
	While ( !FT_FEof() )
		cRelato := FT_FREADLN()
		If At("RPC",cRelato) == 0
			AaDd( HttpSession->aMatRel, StrTran(cRelato ," ","&nbsp;") + CRLF  )
		EndIf
		FT_FSkip()
	EndDo

	// Fecha o arquivo

	FT_FUse()
Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLS754PA.APW" )
EndIf

//Define rotina

HttpSession->cRotRel := "W_PPLEXE754.APW"

//Chama o formulario

cHtml += ExecInPage( "PPLMOSREL" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLS018PA
Rotina chama formulario de parametros Demostrativo de Pagamen
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLS018PA()
LOCAL cHtml	:= ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PPLROTDESC" )

WEB EXTENDED END

Return cHtml

/*/{Protheus.doc} PPLEXE018
Executa o relatorio Demos Pag, Demos Odon e Extrato Pag
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLEXE018()
LOCAL oObj
LOCAL cRelato	:= ""
LOCAL cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"


//Cria variavel de sessao

If ValType(HttpPost->cRda) <> 'U'
	HttpSession->cRDARel  := SubStr( HttpPost->cRda,1,At('|',HttpPost->cRda)-1 )
	HttpSession->cCodLRel := SubStr( HttpPost->cRda,At('|',HttpPost->cRda)+1 )
	HttpSession->cAnoRel  := HttpPost->cAno
	HttpSession->cMesRel  := HttpPost->cMes
EndIf

//Web Service

oObj := WSPLSRELT():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSRELT.APW" )

//Obj

oObj:cUSERCODE 			:= "MSALPHA"
oObj:oWSINPAR:cRDA 		:= HttpSession->cRDARel
oObj:oWSINPAR:cCodLoc	:= HttpSession->cCodLRel
oObj:oWSINPAR:cAno		:= HttpSession->cAnoRel
oObj:oWSINPAR:cMes 		:= HttpSession->cMesRel
oObj:oWSINPAR:cTp 		:= HttpSession->cTpRel

//Executa metodo

If oObj:REL018S()
	FT_FUse( oObj:cREL018SRESULT )
	FT_FGotop()

	// Todas as linhas

	HttpSession->aMatRel := {}
	While ( !FT_FEof() )
		cRelato := StrTran(FT_FREADLN(),'' ,'')
		If At("RPC",cRelato) == 0
			AaDd( HttpSession->aMatRel, StrTran(cRelato ," ","&nbsp;") + CRLF  )
		EndIf
		FT_FSkip()
	EndDo

	// Fecha o arquivo

	FT_FUse()
Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLS018PA.APW" )
EndIf

//Define rotina

HttpSession->cRotRel := "W_PPLEXE018.APW"

//Chama o formulario

cHtml += ExecInPage( "PPLMOSREL" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLSSELO
Ajuda para como logar no portal
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSSELO()
LOCAL cHtml  := ""
PRIVATE cMsg := ""

WEB EXTENDED INIT cHtml

cMsg := "Para utilização do Portal PLS basta informar os login e senha.<br><br>"
cMsg += "Após informar os dados necessários basta clicar no botão 'Acessar o Portal'</b>"
cMsg += "<br><br>"
cMsg += "Caso tenha alguma duvida sobre os dados de login e senha<br>"
cMsg += "utilize a funcionalidade 'Esqueceu sua Senha?'<br><br>"
cMsg += "<br><br>"

cHtml += ExecInPage("PPLSSENHA")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLSHELP
Ajuda para campo
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSHELP()
LOCAL cHtml  := ""
PRIVATE cMsg := ""

WEB EXTENDED INIT cHtml

cMsg := 'Para fazer uma busca, basta digital o conteúdo que desejar.' + "<br>"
cMsg += "   <br><br>"
cMsg += 'A tecla "Delete" limpa o conteúdo da busca por completo, ' + "<br>"
cMsg += 'retornando a posição inicial.' + "</b>"
cMsg += "   <br><br>"
cMsg += 'A tecla "Backspace" limpa o conteúdo da busca ' + "<br>"
cMsg += 'ate retornar a posição inicial.' + "<br>"
cMsg += "   <br><br>"

cHtml += ExecInPage("PPLSSENHA")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLSHEL1
Ajuda para campo
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSHEL1()
LOCAL cHtml  := ""
PRIVATE cMsg := ""

WEB EXTENDED INIT cHtml

cMsg := 'Informe neste campo o número da guia de honorário individual' + "<br>"
cMsg += " <br><br>"
cMsg += 'Este campo deve ser informando quando for necessário' + "<br>"
cMsg += 'consultar uma guia de honorário individual já digitada.' + "</b>"
cMsg += "   <br><br>"
cMsg += 'O número da guia de Solicitação/Senha deve ser informado' + "<br>"
cMsg += 'no campo 3-Nº Guia de Solicitação/Senha.' + "<br>"
cMsg += "   <br><br>"

cHtml += ExecInPage("PPLSSENHA")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLSHEL2
Ajuda para campo
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSHEL2()
LOCAL cHtml  := ""
PRIVATE cMsg := ""

WEB EXTENDED INIT cHtml

cMsg := 'Informe neste campo o número da guia de solictação de ' + "<br>"
cMsg += "internação que originou o honorario individual que <br>"
cMsg += 'esta sendo digitado' + "<br>"

cHtml += ExecInPage("PPLSSENHA")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLESQSENH
Esqueceu a Senha	chamada para o informar o e-mail
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLESQSENH()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml

cHtml += ExecInPage("PPLESQSENH")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLSEVSEN
Validacao de dados e envia por e-mail
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSEVSEN()
LOCAL oEmail	:= nil
LOCAL oObj		:= nil
LOCAL lRet  	:= .t.
LOCAL cResult 	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
WsChgURL( @oObj, "CFGDICTIONARY.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametro															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE	:= "MSALPHA"
oObj:cMVPARAM	:= "MV_RELSERV"
If oObj:GETPARAM()
	cSmtpEnv := oObj:cGETPARAMRESULT
	If Empty(cSmtpEnv)
		lRet	:= .F.
		cResult := "false|Parametro MV_RELSERV sem conteudo"
	EndIf
EndIf

oObj:cMVPARAM	:= "MV_RELACNT"
If oObj:GETPARAM()
	cUsuEmai := oObj:cGETPARAMRESULT
	If Empty(cUsuEmai)
		lRet 	:= .F.
		cResult := "false|Parametro MV_RELACNT sem conteudo"
	EndIf
EndIf

oObj:cMVPARAM	:= "MV_RELPSW"
If oObj:GETPARAM()
	cUsuPass := oObj:cGETPARAMRESULT
	If Empty(cUsuPass)
		lRet 	:= .F.
		cResult := "false|Parametro MV_RELPSW sem conteudo"
	EndIf
EndIf

//Se pode continuar

If lRet

	//Obj

	oEmail := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oEmail:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL(@oEmail,"PLSXFUN.APW")

	//Parametro

	oEmail:cUSERCODE  := "MSALPHA"
	oEmail:cUserEmail := HttpPost->cEmail
	oEmail:cSmtpEnv	  := cSmtpEnv
	oEmail:cUsuEmai	  := cUsuEmai
	oEmail:cUsuPass	  := cUsuPass

	//Metodo

	If oEmail:GetEmail()
		cResult := "true|"+oEmail:cGETEMAILRESULT
	Else
		cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
	EndIf
EndIf


//Fim da funcao

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGUIMED
Mostra formulario do guia medico
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGUIMED()
LOCAL cHtml := ""
local nX	:= 0

WEB EXTENDED INIT cHtml

if valType(HttpSession->aEspecialidade) == 'U'

	oObj := WSPLSMCTMD():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLSMCTMD.APW" )

	oObj:cUSERCODE 	:= "MSALPHA"
	oObj:cFunName	:= 'PLPEECB'
	oObj:nTp		:= 1

	if oObj:getParGM()
		HttpSession->aEspecialidade := oObj:oWSGETPARGMRESULT:OWSGENERICSTRUCT
	else
		HttpSession->aEspecialidade := {}
	endIf

endIf

If(valType(HttpSession->aProdutos) == 'A')
	HttpSession->aProdutos := {}
EndIF

if valType(HttpSession->aProdutos) == 'U' .Or. Empty(HttpSession->aProdutos)

	oObjxFun := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oObjxFun:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObjxFun, "PLSXFUN.APW" )

	oObjxFun:cUSERCODE := "MSALPHA"

	if oObjxFun:getProdutos()

		HttpSession->aProdutos := {}

		for nX := 1 to len(oObjxFun:oWSGETPRODUTOSRESULT:oWSPRODUTOSLIST)
			aAdd( HttpSession->aProdutos, WsClassNew( "ProdutosGM" ) )
			HttpSession->aProdutos[nX]:cCODE			:= allTrim(oObjxFun:oWSGETPRODUTOSRESULT:oWSPRODUTOSLIST[nX]:cCodigo)
			HttpSession->aProdutos[nX]:cDESCRIPTION		:= allTrim(oObjxFun:oWSGETPRODUTOSRESULT:oWSPRODUTOSLIST[nX]:cNome)
		next

	else
		HttpSession->aProdutos := {}
	endIf

endIf

cHtml += ExecInPage("PPLGUIMED")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCGUIMED
Chama form do guia medico
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCGUIMED()
LOCAL oObj		:= NIL
LOCAL cResult 	:= "true|"
LOCAL nI		:= 0
LOCAL aRet		:= {}
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml


// oBJ

oObj := WSPLSMCTMD():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSMCTMD.APW" )

// Parametros

oObj:cUSERCODE	:= "MSALPHA"
oObj:cFunName   := "PLPEECB"
oObj:nTp		:= Val(HttpGet->nTp)
oObj:cCodEsp	:= HttpGet->cCodEsp
oObj:cCodEst	:= HttpGet->cCodEst
oObj:cCodMun	:= HttpGet->cCodMun

// Retorna dados

If oObj:getParGM()
	aRet := oObj:oWSGETPARGMRESULT:OWSGENERICSTRUCT
EndIf

// Monta retono

If Len(aRet) > 0

	//Monta retorno para o combo

	For nI:=1 To Len(aRet)
		cResult += aRet[nI]:cCode + "$" + aRet[nI]:cDescription + "|"
	Next
	cResult := Left(cResult,Len(cResult)-1)
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLMOSMAP
Mostra mapa
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLMOSMAP()
LOCAL cHtml := ""

// Chamada do formulario

WEB EXTENDED INIT cHtml

cHtml += ExecInPage("PPLMOSMAP")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLTRAPRE
Tratamento do pre-atendimento inclusao/alteracao e exclusao
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLTRAPRE()
LOCAL nI		:= 0
LOCAL nPosRDA  := 0
LOCAL cResult  := "true|"
LOCAL cHtml := ""
Local nTmpIni 	:= Seconds()

WEB EXTENDED INIT cHtml START "InSite"

if HttpSession->lMatrAnt .and. valtype(HttpSession->aVldCartao) == "A" .and. ! empty(HttpSession->aVldCartao[11]) .and.;
		HttpGet->cTpAca <> "E" .And. valType(HttpSession->aVldCartao[11]) == 'C' .and. ! empty(HttpGet->cMatric)

	HttpGet->cMatric := allTrim(HttpSession->aVldCartao[11])

endIf

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Registro no WS
oObj:cUSERCODE 			:= "MSALPHA"
oObj:oWSMatPre:cCodRda	:= HttpGet->cRDA										  	//Rda
oObj:oWSMatPre:cTpAca	:= HttpGet->cTpAca									 		//Tipo de acao Inclui,altera ou excluir
oObj:oWSMatPre:cMatric	:= HttpGet->cMatric											//Matricula
oObj:oWSMatPre:cNomeUsu	:= alltrim(HttpGet->cNomeUsu)										//Nome do usuario
oObj:oWSMatPre:cCodUsr	:= getUsrWeb()											 	//Codigo de login web Login pls bsw
oObj:oWSMatPre:cCodLoc	:= HttpGet->cCodLoc   										//LOCAL de atendimento
oObj:oWSMatPre:cTrilha	:= HttpSession->TrilhaCard
If (ValType(HttpGet->cOrdResult) <> "U")
	If (HttpGet->cOrdResult = "")
		oObj:oWSMatPre:cOrdResult	:= "1"
	Else
		oObj:oWSMatPre:cOrdResult	:= HttpGet->cOrdResult
	EndIf
Else
	oObj:oWSMatPre:cOrdResult	:= "1"
EndIf
If ValType(HttpGet->cRDAOld) <> "U" .AND. ValType(HttpGet->cCodLocOld) <> "U" //Valores anteriores à alteração
	oObj:oWSMatPre:cCodRdaOld := HttpGet->cRDAOld
	oObj:oWSMatPre:cCodLocOld := HttpGet->cCodLocOld
Else
	oObj:oWSMatPre:cCodRdaOld := ""
	oObj:oWSMatPre:cCodLocOld := ""
EndIf

// Verificacao

If !Empty(HttpGet->cRDA)

	// Rda

	nPosRDA := aScan( HttpSession->RDAVIEW, { |x| alltrim(x:cCODE) == alltrim(HttpGet->cRda) .And. alltrim(x:cCodLoc) == alltrim(HttpGet->cCodLoc)} )

	// Parametros

	If nPosRDA == 0
		nPosRDA := 1
	Endif

	oObj:oWSMatPre:cOpeRda	:= HttpSession->RDAVIEW[nPosRDA]:cCodOpe			//Operadora da rda
	oObj:oWSMatPre:cNomRda	:= HttpSession->RDAVIEW[nPosRDA]:cName	   			//Nome rda
EndIf

// Metodo
If oObj:PreAte()

	HttpSession->aMatPreAte := { oObj:oWSPREATERESULT:oWSSRETMATPRE }

	// Monta a string de resposta

	If ValType(HttpSession->aVldCartao) == 'A'
		cResult += Iif(Empty(HttpSession->aVldCartao[11]),Transform(HttpSession->aVldCartao[2],'@R !!!!.!!!!.!!!!!!.!!-!'),Iif( Len(HttpSession->aVldCartao[11])>16,Transform(HttpSession->aVldCartao[11],'@R !!!!.!!!!.!!!!!!.!!-!'),Transform(HttpSession->aVldCartao[11],'@R !!!!.!!!!.!!!!!!.!!-!') ) )+"@"+HttpSession->aVldCartao[1]+"~"
	Else
		cResult += "@~"
	EndIf

	For nI := 1 To Len(HttpSession->aMatPreAte[1])

		cResult += 	HttpSession->aMatPreAte[1,nI]:cMsg+"$"+;
			Iif( Len(HttpSession->aMatPreAte[1,nI]:cMatric)>16,Transform( HttpSession->aMatPreAte[1,nI]:cMatric, "@R !!!!.!!!!.!!!!!!.!!-!" ),Transform( HttpSession->aMatPreAte[1,nI]:cMatric, "@R !!!!.!!!!.!!!!!!.!!-!" ) )+"$"+;
			AllTrim(HttpSession->aMatPreAte[1,nI]:cNomeUsu)+"$"+;
			HttpSession->aMatPreAte[1,nI]:cRda+"$"+;
			AllTrim(HttpSession->aMatPreAte[1,nI]:cNomeRda)+"$"+;
			HttpSession->aMatPreAte[1,nI]:cCodLoc+"$"+;
			DtoC(HttpSession->aMatPreAte[1,nI]:dDatChe)+"$"+;
			Transform( HttpSession->aMatPreAte[1,nI]:cHorChe, "@R 99:99" )+"|"
	Next

Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

//Mostra o tempo que durou pra confirmar o atendimento
if httpSession->lTimeAte

	oObjPar := WSCFGDICTIONARY():New()
	IIf (!Empty(PlsGetAuth()),oObjPar:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObjPar, "CFGDICTIONARY.APW" )

	oObjPar:cMsgLog  := "2) " + Time()+ "|" + Alltrim(Str(Seconds() - nTmpIni)) + "|" + HttpGet->cRDA
	oObjPar:cFileLog := "PreAtendimento.txt"
	oObjPar:PutPLSLogFil()

endIf

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSETLL
Grava latitudo e longitude
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSETLL()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= "true|"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSMCTMD():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSMCTMD.APW" )

// Parametros

oObj:cUSERCODE	:= "MSALPHA"
oObj:cRecno		:= HttpGet->cRecno
oObj:cLatLon	:= HttpGet->cLatLon

// Retorna dados

oObj:setLatLon()

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGETELL
Retorna o endereco fisico, latitude longitude e endereco show
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGETELL()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml


// oBJ

oObj := WSPLSMCTMD():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSMCTMD.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cRecno		:= HttpGet->cRecno

// Retorna dados

If oObj:getEndLL()
	cResult := oObj:cGETENDLLRESULT
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCHACOM
Chama form para mostrar a composicao de Solicitacao
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCHACOM()
LOCAL cHtml := ""
LOCAL oObj  := NIL

WEB EXTENDED INIT cHtml START "InSite"


//Web Service

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros

oObj:cUSERCODE	:= "MSALPHA"
oObj:cCampos 	:= "BEA_TIPO"
oObj:cShowAnexo	:= "1"

//Monta o box de um determinado campo

If ValType(HttpSession->aTpAut) == 'U'
	If oObj:GetBox()
		HttpSession->aTpAut := oObj:OWSGETBOXRESULT:OWSGENERICSTRUCT
	EndIf
EndIf

cHtml += ExecInPage("PPLMOSSOL")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCHAELE
Chama form para mostrar a solicitacao de elegibilidade
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCHAELE()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

// Ponto de entrada para controle da exibicao das colunas da elegibilidade
HttpSession->aMatEleg := {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.F.}

if HttpSession->lPPLEXIELE
	HttpSession->aMatEleg := ExecBlock("PPLEXIELE",.F.,.F.)
endIf

cHtml += ExecInPage("PPLMOSELE")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCHADTIN
Chama form para informar data de internacao
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCHADTIN()

LOCAL cHtml := ""
LOCAL oObj  := NIL
Local cRetorno := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUSERCODE		:= "MSALPHA"
oObj:cChave 		:= "39"

// Alimenta a dados especifico por tipo de guia

oObj:RetBTQChv()

cRetorno := oObj:cRETBTQCHVRESULT

HttpSession->aMotivoAlta := StrTokArr(cRetorno, "#")//oObj:cRETBTQCHVRESULT//"teste"//cRetorno//StrTokArr(cRetorno, "$")

cHtml += ExecInPage("PPLDATINT")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCHAHOIN
Chama form para honorario
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCHAHOIN()
LOCAL cHtml := ""
LOCAL oObj  := NIL
LOCAL cTISSVer	:= ""

LOCAL cResult  	:= ""
LOCAL cStrCBOX	:= ""
LOCAL nI,nY, nPos

WEB EXTENDED INIT cHtml START "InSite"

//Obj

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametro
HttpSession->cTp	:= '6'
HttpSession->cBVolt := "1"

oObj:cUSERCODE		:= "MSALPHA"
oObj:cTipo 			:= HttpSession->cTp

// Alimenta a dados especifico por tipo de guia
If oObj:GetDadG()
	HttpSession->aGrPart := oObj:oWSGetDadGRESULT:oWSCbGraPar:oWSGenericStruct
Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLCHAHOIN.APW" )
EndIf

// Alimenta as variaves com o x3-combobox
If !HttpSession->lCombo
	Return PPLSALERT( "", "Atenção", "", "W_PPLCHAHOIN.APW" )
endIf

// Passa a primeira rda do usuario logado
HttpSession->cRdaRel := ""
HttpSession->cCodLoc := ""

If Len(HttpSession->RDAVIEW) >= 1

	HttpSession->cRdaRel := HttpSession->RDAVIEW[1]:cCODE
	HttpSession->cCodLoc := HttpSession->RDAVIEW[1]:cCodLoc

	//Recupera a versão da TISS da RDA
	aRDA := ClassDataArr(HttpSession->RDAVIEW[1])
	If aScan(aRDA,{|x| AllTrim(x[1]) == "CTISSVER"  }) > 0
		cTISSVer := HttpSession->RDAVIEW[1]:cTissVer
	EndIf
	HttpSession->cTISSVer := cTISSVer

EndIf


// CRIAR PAGINA PARA TISS 3.0

If cTissVer >= "3"


	// oBJ

	oObj := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLSXFUN.APW" )


	// Parametros

	oObj:cUserCode	:= "MSALPHA"
	oObj:oWSGUIATISS:cTipGui		:= "06" // Guia de Honorarios
	oObj:oWSGUIATISS:cVerTiss	:= cTISSVer

	// Aqui eu pego o que vem de Session executo aqui pra enviar a informaçao
	// pro WS pois o mesmo nao acessa o conteudo da Session	dificultando o dinamismo

	If oObj:GetCmbFormT()
		// ATRIBUO OS PARAMETROS NOVAMENTE PARA UTILIZAÇÃO DO PROXIMO METODO
		oObj:cUserCode	:= "MSALPHA"
		oObj:oWSGUIATISS:cTipGui		:= "06"
		oObj:oWSGUIATISS:cVerTiss	:= cTISSVer
		//oObj:oWSGUIATISS:OWSCMBGUIA	:= {}
		oObj:oWSGUIATISS:cDadCombo	:= ""
		If Len(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA) > 0 //oObj:OWSGETCMBFORMTRESULT:oWSRETCMBSGUIA
			For nI:=1 To Len(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA)
				cStrCBOX := ""
				If "HTTPSESSION" $ Upper(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX)	 // Se for uma Session eu pego CCODE e CNAME e monto o Combo
					If ValType(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX)) <> 'U'
						For nY := 1 To Len(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX))
							cStrCBOX += Alltrim(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX + "[" + Alltrim(Str(nY)) + "]:cCODE")) + "=" + Alltrim(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX + "[" + Alltrim(Str(nY)) + "]:cNAME")) + ";"
						Next nY
					EndIf
					If nY > 2
						cStrCBOX += ";="//cStrCBOX += ";=-- Selecione um item --"
					EndIf
				Else // Caso contrario eu pego a STRING com mesma estrutura do X3_COBX
					cStrCBOX := Alltrim(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX)
				EndIf
				If SubStr(cStrCBOX, Len(cStrCBOX),1) == ";"
					cStrCBOX := SubStr(cStrCBOX, 1, Len(cStrCBOX)-1)
				EndIf
				oObj:oWSGUIATISS:cDadCombo	+= Alltrim(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCampoG) + ";" + cStrCBOX + "|"
				//WSDATA RetCmbsGuia	AS Array Of SRetCmbsGuia OPTIONAL
			Next
		EndIf
	EndIf
	If SubStr(oObj:oWSGUIATISS:cDadCombo, Len(oObj:oWSGUIATISS:cDadCombo),1) == "|"
		oObj:oWSGUIATISS:cDadCombo := SubStr(oObj:oWSGUIATISS:cDadCombo, 1, Len(oObj:oWSGUIATISS:cDadCombo)-1)
	EndIf
	//Alimenta tipo de guia com a query string passada por parâmetro
	oObj:cTipo 		:= IIF(Empty(HttpGet->cTipoOrigem),"",HttpGet->cTipoOrigem)
	oObj:ccRecno 		:= IIF(Empty(HttpGet->cNumGuia),"",HttpGet->cNumGuia)
	oObj:cDtLimRetro	:= IIF(Empty(HttpGet->dDtLimRetro),"",HttpGet->dDtLimRetro)

	HttpSession->cDigitacao := ""


	// Retorna dados da pagina

	oObj:cDtJs := iif(valtype(HttpSession->cDtJs) <> 'U', HttpSession->cDtJs, "")
	If oObj:GetFormTiss()
		cResult :=  oObj:OWSGETFORMTISSRESULT:cPagina

		If ValType(oObj:OWSGETFORMTISSRESULT:cGrids) == "C"
			HttpSession->cGrids := oObj:OWSGETFORMTISSRESULT:cGrids
		EndIf

		If ValType(oObj:OWSGETFORMTISSRESULT:OWSCMPGUIA:oWSSCmpGuia) == "A" /*/:OWSCMPGUIA:OWSSCMPGUIA)*/
			HttpSession->aCmpGuia := aClone(oObj:OWSGETFORMTISSRESULT:OWSCMPGUIA:oWSSCmpGuia)
		EndIf

		//Executa os inicializadores dos campos
		nIni := At("<%=",cResult)
		While  nIni > 0
			nFim := At("%>",cResult)
			cComando := SubStr(cResult,nIni+3,nFim - nIni-3)
			xResult := &(cComando)

			cTipResult := ValType(xResult)
			Do Case
				Case cTipResult == "D"
					xResult := DtoS(xResult)
					xResult := SubStr(xResult,7,2) + "/" + SubStr(xResult,5,2) + "/" + SubStr(xResult,1,4)
				Case cTipResult == "N"
					xResult := Alltrim(Str(xResult))
			EndCase

			cResult := StrTran ( cResult, "<%=" + cComando + "%>", xResult)
			nIni := At("<%=",cResult)
		EndDo

	EndIf

	HttpSession->cPaginaGuia := Substr(cResult,At("|",cResult)+1,Len(cResult)) // Retiro o true| ou o false|


	// FIM CRIAR PAGINA PARA TISS 3.0

EndIf

If cTissVer >= "3"
	cHtml += ExecInPage("PPLSGUIAS")
	//cHtml += ExecInPage("PPLSHOIN")
	//cHtml += ExecInPage("PPLSHOIF")
Else
	cHtml += ExecInPage("PPLSHOIN")
EndIf

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLEXEALT
Informa a data de alta do paciente
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLEXEALT()
LOCAL cResult	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


//Obj

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Registro no WS

oObj:cUSERCODE 	:= "MSALPHA"
oObj:cNumAut	:= AllTrim( StrTran(StrTran(HttpGet->cNumGui,".",""),"-","") )
oObj:dDatAlt	:= CToD(HttpGet->dDatAlt)
oObj:cHorAlt	:= StrTran(HttpGet->cHorAlt,":","")
oObj:cMotAlt	:= alltrim(HttpGet->cMotAlt)

// Metodo

If oObj:ExeDHAlt()
	cResult := oObj:cExeDHAltRESULT
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return cResult

/*/{Protheus.doc} PPLEXEINT
Informa a data de internacao do paciente
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLEXEINT()
LOCAL cResult	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


//Obj

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Registro no WS

oObj:cUSERCODE 	:= "MSALPHA"
oObj:cNumAut	:= AllTrim( StrTran(StrTran(HttpGet->cNumGui,".",""),"-","") )
oObj:dDatInt	:= CToD(HttpGet->dDatInt)
oObj:cHorInt	:= StrTran(HttpGet->cHorInt,":","")

// Metodo

If oObj:ExeDHInt()
	cResult := oObj:cExeDHIntRESULT
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return cResult

/*/{Protheus.doc} PPLSTAGUI
Mostra dados da Guia
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSTAGUI()
LOCAL nI,nY      := 0
LOCAL aMatComGui := {}
LOCAL cCritica	 := ""
LOCAL lbCancel	 := "true"
LOCAL cResult  	 := "true|"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


//Obj

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Registro no WS

oObj:cUSERCODE 	:= "MSALPHA"
oObj:cNumAut	:= AllTrim( StrTran(StrTran(HttpGet->cNumGui,".",""),"-","") )
oObj:cTipoAut	:= HttpGet->cTipoAut

// Metodo

If oObj:StatusGuia()

	// Retorno

	aMatComGui := oObj:OWSSTATUSGUIARESULT:OWSSMATCOMPGUI

	// Matriz de Retorno

	For nI:=1 To Len(aMatComGui)

		// Nome do usuario e Data da Solicitacao

		If nI == 1

			If aScan( HttpSession->RDAVIEW, { |x| x:cCODE == aMatComGui[1]:CRDACODE} ) == 0 .and. !(HttpGet->cTipoAut $ '7,8,9')
				lbCancel := 'false'
			EndIf

			cResult += aMatComGui[1]:cNomeUsu+"@"+;
				aMatComGui[1]:cDtGui+"@"+;
				aMatComGui[1]:cStaGui+"@"+;
				aMatComGui[1]:cCancel+"@"+;
				aMatComGui[1]:cOnLine+"@"+lbCancel+"~"
		EndIf

		// Itens

		cResult += 	aMatComGui[nI]:cCodTab+"$"+; //Tabela
			aMatComGui[nI]:cCodPro+"$"+; //Procedimento
			aMatComGui[nI]:cDesPro+"$"+; //Nome do Procedimento
			aMatComGui[nI]:cQtdSol+"$"+; //Qtd Solcitacao
			aMatComGui[nI]:cQtdRea+"$"+; //Qtd Realizada
			aMatComGui[nI]:cQtdSal+"$"+; //Qtd Saldo
			aMatComGui[nI]:cStaAud+"$"+; //Status Auditoria
			aMatComGui[nI]:cStaPro+"^"	  //Status Procedimento

		// Criticas

		cCritica := ""
		For nY:=1 To Len(aMatComGui[nI]:OWSMATCRI:OWSGENERICSTRUCT)
			cCritica +=	"*        " + aMatComGui[nI]:OWSMATCRI:OWSGENERICSTRUCT[nY]:cCODE+" - "+AllTrim(aMatComGui[nI]:OWSMATCRI:OWSGENERICSTRUCT[nY]:cDescription)
		Next
		cResult += Iif( Empty(cCritica),'*',cCritica) + "|"
	Next

Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCANGUI
Cancela Guia
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCANGUI()
LOCAL cResult	:= ""
LOCAL lDigiOff	:= .F.
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


//Obj

lDigiOff := IIF(Valtype(HttpGet->cDigiGuia) <> "U" .AND. HttpGet->cDigiGuia == "1" , lDigiOff := .T., lDigiOff := .F.) //Verifico se é da Digitação Off-Line

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Registro no WS

oObj:cUSERCODE  := "MSALPHA"
oObj:cNumAut	:= AllTrim( StrTran(StrTran(HttpGet->cNumGui,".",""),"-","") ) //Se Digitação Off-Line, passo o RECNO da BD5.
oObj:cMotivo	:= IIF (!lDigiOff, AllTrim( HttpGet->cMotivo ), "RECOFF") //Será utilizado como comparador na hora da pesqusia do alias para deletar
oObj:cTipo		:= IIF (!lDigiOff, iif(Valtype(HttpGet->cTipo) <> "U", HttpGet->cTipo, "0") , HttpGet->cTipo)

// Metodo

If oObj:CancelaGuia()
	cResult := oObj:cCANCELAGUIARESULT
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLPROELE
Mostra dados Elegibilidade do Beneficiario
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLPROELE()
LOCAL nI	  	:= 0
LOCAL cResult 	:= "true|"
LOCAL cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

//Obj
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

HttpSession->aResult := {}
oObj:cUSERCODE 		 := "MSALPHA"
oObj:cUserCardNumber := AllTrim(HttpGet->cMatric) //AllTrim( StrTran(StrTran(HttpGet->cMatric,".",""),"-","") )

// Metodo
If oObj:Elegibilidade()

	cResult += 	AllTrim(oObj:OWSELEGIBILIDADERESULT:CCARDNAME)+"|"+;
		AllTrim(oObj:OWSELEGIBILIDADERESULT:CNOMTIT)+"|"+;
		AllTrim(oObj:OWSELEGIBILIDADERESULT:CNOMEMP)+"|"+;
		AllTrim(oObj:OWSELEGIBILIDADERESULT:CCARDNUMBEROLD)+"|"+;
		Iif(oObj:OWSELEGIBILIDADERESULT:LINTERCHANGE == .T.,"SIM","NÃO")+"|"+;
		oObj:OWSELEGIBILIDADERESULT:COPEORI+"|"+;
		AllTrim(oObj:OWSELEGIBILIDADERESULT:CPLANO)+"|"+;
		DToC(oObj:OWSELEGIBILIDADERESULT:DVALCAR)+"|"+;
		oObj:OWSELEGIBILIDADERESULT:CNUMCARNAC+"|"+;
		AllTrim( Str(oObj:OWSELEGIBILIDADERESULT:NVIACARTAO) )+"|"+;
		oObj:OWSELEGIBILIDADERESULT:CABRANGE+"|"+;
		Substr(Dtos(oObj:OWSELEGIBILIDADERESULT:DDATBLO),7,2)+"/"+;
		Substr(Dtos(oObj:OWSELEGIBILIDADERESULT:DDATBLO),5,2)+"/"+;
		Substr(Dtos(oObj:OWSELEGIBILIDADERESULT:DDATBLO),1,4)+"|"+;
		oObj:OWSELEGIBILIDADERESULT:CSTATUSEL+"|"+;
		oObj:OWSELEGIBILIDADERESULT:CCODNEG+"|"+;
		oObj:OWSELEGIBILIDADERESULT:CDESNEG+"|"+;
		oObj:OWSELEGIBILIDADERESULT:COPEANS+"|$"

	// Criticas
	For nI := 1 To Len(oObj:OWSELEGIBILIDADERESULT:OWSUSERCRITICA:OWSUSERCARDCRI)
		If !Empty(oObj:OWSELEGIBILIDADERESULT:OWSUSERCRITICA:OWSUSERCARDCRI[nI]:CDESPRI)
			cResult += AllTrim(oObj:OWSELEGIBILIDADERESULT:OWSUSERCRITICA:OWSUSERCARDCRI[nI]:CDESPRI)+" - "+AllTrim(oObj:OWSELEGIBILIDADERESULT:OWSUSERCRITICA:OWSUSERCARDCRI[nI]:CDESSEQ)+chr(10)+chr(13)
		EndIf
	Next
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLTROMAT
 Procura matricula antiga caso seja usuario de intercambio
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function PPLTROMAT(cMatric)
	Local cMatAnt := cMatric // para fazer o seek com o matant, pois pode ter traços e pontos

	cMatric := AllTrim(StrTran(StrTran(cMatric,".",""),"-",""))

	BA1->( DbSetOrder(2) ) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
	If !BA1->( MsSeek( xFilial("BA1")+cMatric ) )

		BA1->( DbSetOrder(5) ) //BA1_FILIAL + BA1_MATANT + BA1_TIPANT
		If BA1->( MsSeek( xFilial("BA1")+cMatAnt ) )
			cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
		ElseIf BA1->( MsSeek( xFilial("BA1")+Right(cMatric,16) ) )
			cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
		Else
			cMatric := ""
		EndIf

	EndIf

Return cMatric

/*/{Protheus.doc} PLSDECODE
Codifica caracteres especiais acentuacao
@type function
@author PLSTEAM
@since 20.03.18
@version 1.0
/*/
Function PLSDECODE(cString)
Return( WCDecode(cString) )



/*/{Protheus.doc} PPLCHADOW
Chama form para download
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCHADOW()
LOCAL cHtml    	:= ""
LOCAL cCaminho 	:= getWebDir()

WEB EXTENDED INIT cHtml START "InSite"

If !Empty(cCaminho)
	cCaminho := cCaminho + getPrtSkin() + "\biometria\"
EndIf

HttpSession->Driver   := File(cCaminho+"Instalacao_Driver.Rar")
HttpSession->Register := File(cCaminho+"RegistrarDll.exe")

cHtml += ExecInPage("PPLDOWDRV")

WEB EXTENDED END

Return cHtml

/*/{Protheus.doc} PPLCHAMANU
Chamada do menu Manuais
@author PLSTEAM
@since 10.2007
@version P12
/*/
WEB FUNCTION PPLCHAMANU()
LOCAL cHtml  	:= ""
LOCAL cDir	 	:= getWebDir()
LOCAL aFiles	:= {}

WEB EXTENDED INIT cHtml START "InSite"

If !Empty(cDir)

	cDir := cDir + getPrtSkin() + "\manuaistiss\"

	//Le diretorio para mostrar os arquivos disponiveis

	aFiles := DIRECTORY(cDir+"*.*")

	If Len(aFiles) > 0
		HttpPost->aFiles := aClone(aFiles)
		HttpPost->cDir := cDir
	Else
		Return PPLSALERT( "", "Atenção", "Nenhum arquivo encontrado dentro do Diretorio ManuaisTISS", "" )
	EndIf

Else
	Return PPLSALERT( "", "Atenção", "Nao foi possivel encontrar o Diretorio de ManuaisTISS", "" )
EndIf

cHtml += ExecInPage("PPLSMANUAL")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCHADUVI
Chamada do menu Duvidas/Esclarecimentos
@author PLSTEAM
@since 10.2007
@version P12
/*/
WEB FUNCTION PPLCHADUVI()
LOCAL cHtml  	:= ""
LOCAL oObjLib 	:= nil

WEB EXTENDED INIT cHtml START "InSite"

oObjLib := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObjLib:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObjLib, "PLSXFUN.APW" )

//Busca contatos na tabela BIM
If oObjLib:getContato("MSALPHA",HttpSession->cIntPad)

	HttpPost->oContatos := oObjLib:oWSGETCONTATORESULT:oWSCONTATOSTISS

	cHtml += ExecInPage("PPLSDUVIDA")

Else
	Return PPLSALERT( "", "Atenção", "Nao Existe nenhum Contato TISS cadastrado", "" )
EndIf

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCHAORIE
Chamada do menu Orientacoes TISS
@author PLSTEAM
@since 10.2007
@version P12
/*/
WEB FUNCTION PPLCHAORIE()
LOCAL cHtml	:= ""
LOCAL cArq 	:= getWebDir()

WEB EXTENDED INIT cHtml START "InSite"

If !Empty(cArq)

	cArq := cArq + getPrtSkin() + "\orientacoestiss.html"

	If !File(cArq)
		Return PPLSALERT( "", "Atenção", "Nao foi encontrado o arquivo orientacoestiss", "" )
	Endif

Else
	Return PPLSALERT( "", "Atenção", "Nao foi encontrado o diretorio imagens-pls", "" )
EndIf

cHtml += ExecInPage("PPLSORIENT")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCHPROD
Chamada do menu Produtos
@author PLSTEAM
@since 10.2007
@version P12
/*/
WEB FUNCTION PPLCHPROD()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml //Aqui não tem o insite porque a utilização não precisa de login


//WS

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros

oObj:cUSERCODE	:= "MSALPHA"

If oObj:getProdutos()
	HttpSession->aProdutos := oObj:oWSGETPRODUTOSRESULT:oWSPRODUTOSLIST
EndIf

cHtml += ExecInPage("PPLSPRODUT")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCHAEXML
Chamada do menu Envio XML
@author PLSTEAM
@since 10.2007
@version P12
/*/
WEB FUNCTION PPLCHAEXML()
LOCAL cHtml  	:= ""
LOCAL oObjLib	:= Nil

WEB EXTENDED INIT cHtml START "InSite"

oObjLib := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObjLib:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObjLib, "PLSXFUN.APW" )

//Busca Links na tabela B0F
If oObjLib:GetLinks("MSALPHA",HttpSession->cIntPad,"2")

	HttpPost->oLinks := oObjLib:oWSGETLINKSRESULT:oWSLINKSLIST

	cHtml += ExecInPage("PPLSENVXML")

Else
	Return PPLSALERT( "", "Atenção", "Nenhum Link encontrado para Download/Upload", "" )
EndIf

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCHAWBSE
Chamada do menu Webservice
@author PLSTEAM
@since 10.2007
@version P12
/*/
WEB FUNCTION PPLCHAWBSE()
LOCAL cHtml  	:= ""
LOCAL oObjLib	:= Nil

WEB EXTENDED INIT cHtml START "InSite"

//Alimenta a intpad
oObjLib := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObjLib:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObjLib, "PLSXFUN.APW" )

//Busca Links na tabela B0F
If oObjLib:getLinks("MSALPHA",HttpSession->cIntPad,"1")

	HttpPost->oLinks := oObjLib:oWSGETLINKSRESULT:oWSLINKSLIST

	cHtml += ExecInPage("PPLSWEBSER")

Else
	Return PPLSALERT( "", "Atenção", "Nenhuma WebService encontrada", "" )
EndIf

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLSMONESP
Monta matriz de todos os conselho bah
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSMONESP()
LOCAL nI
LOCAL oObj
LOCAL cResult  	:= "true|"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSMCTMD():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSMCTMD.APW" )

// Parametro

oObj:cUSERCODE 			:= "MSALPHA"
oObj:OWSESPEC:cRda  	:= HttpGet->cRda
oObj:OWSESPEC:cCodLoc  	:= HttpGet->cCodLoc
oObj:OWSESPEC:cTp  		:= HttpGet->cTp

// Executa metodo para pegar os conselhos

If oObj:getSigEsp()
	For nI:=1 To Len(oObj:oWSGETSIGESPRESULT:oWSGenericStruct)
		cResult +=	oObj:oWSGETSIGESPRESULT:oWSGenericStruct[nI]:cCode+"$"+;
			oObj:oWSGETSIGESPRESULT:oWSGenericStruct[nI]:cDescription+"|"
	Next
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCHAIMP
Chamada do processamento de arquivo xml
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCHAIMP()
LOCAL cHtml 	:= ""
LOCAL nI    	:= 0
LOCAL oObjLib 	:= NIL
LOCAL nLen		:= IIf(Valtype(HttpSession->RDAVIEW) == "A", Len(HttpSession->RDAVIEW), 0 )

PRIVATE cInterPag := ""
PRIVATE cValParam := HttpSession->cValParam

WEB EXTENDED INIT cHtml START "InSite"

If cValParam == "2"
	HttpSession->DatServXML := FWTimeStamp(3)

	//Alimenta a intpad
	oObjLib := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oObjLib:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObjLib, "PLSXFUN.APW" )

	oObjLib:cUSERCODE := "MSALPHA"
	oObjLib:cRDACode  := ""

	//RDA(s)
	if nLen > 0
		for nI := 1 to nLen
			oObjLib:cRDACode	+= HttpSession->RDAVIEW[nI]:cCode + "|"
		next nI

		if right(oObjLib:cRDACode, 1) == "|" //tiro o ; final
			oObjLib:cRDACode := left(oObjLib:cRDACode, (len(oObjLib:cRDACode)-1))
		endif
	else
		Return PPLSALERT( "", "Atenção", "", "W_PPLCHAIMP.APW" )
	endif

	//Busca Calendario de Pagamento

	If oObjLib:getCalend()
		cInterPag := oObjLib:cGETCALENDRESULT
	Else
		Return PPLSALERT( "", "Atenção", "", "W_PPLCHAIMP.APW" )
	EndIf
EndIf

cHtml += ExecInPage("PPLCHAIMP")


WEB EXTENDED END

getLOGMon()

Return cHtml


/*/{Protheus.doc} PPLCHAMNC
Estatistica de parto

@author  PLS TEAM
@version P11
@since   15.10.15
/*/
Web Function PPLCHAMNC()
LOCAL cHtml := ""

//Exibe pagina

WEB EXTENDED INIT cHtml START "InSite"

//Chama o formulario

cHtml += ExecInPage("PPLCHAMNC")

WEB EXTENDED END

getLOGMon()



Return cHtml

/*/{Protheus.doc} PPLRELMOV
PPLRELMOV
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLRELMOV()
LOCAL cHtml := ""
PRIVATE cMVQTDIARQ	:= HttpSession->cMVQTDIARQ

//Exibe pagina
WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLRELMOV")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLMOSIMP
Mostra lista de arquivos XML	para importacao
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLMOSIMP()
LOCAL cHtml := "true|"
LOCAL oObj 	:= NIL

WEB EXTENDED INIT cHtml START "InSite"

// Verifica se a variavel ja esta definida

If type('HttpSession->RDAVIEW') == 'U' .and. type('HttpSession->USR_INFO') <> 'U'
	HttpSession->RDAVIEW := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFRDA:OWSRDAVIEW //Prestador

Endif
If ValType(HttpGet->cPagina) != 'U'
	HttpSession->nPagUp := Val(HttpGet->cPagina)
Else
	HttpSession->nPagUp  := 1
EndIf

//Obj

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode		:= "MSALPHA"
oObj:nPaginaIni 	:= HttpSession->nPagUp
oObj:nRegPagina 	:= 5000
oObj:cRDACode 		:= HttpGet->cRda

//Exibe lista de arquivos
HttpSession->aFileList 	:= {}
HttpSession->nTPagUp 	:= 1

If oObj:getFList()
	HttpSession->aFileList := oObj:oWSGetFListRESULT:oWSARQUIVOSLIST
	HttpSession->nTPagUp   := HttpSession->aFileList[1]:nQtdPag
EndIf

//Exibe pagina

If ValType(HttpSession->cRetChImp) == 'U' // foi necessário guardar o resultado porque a pagina faz duas requisições seguidas perdendo o valor do metodo
	cHtml := "true| |"
Else
	cHtml := "true|" + HttpSession->cRetChImp + "|"
EndIf

HttpSetPart(.F.)

cHtml += ExecInPage("PPLMOSIMP")

HttpSetPart(.T.)

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cHtml)

/*/{Protheus.doc} PPLPROARQ
Processa arquivo (importacao xml)
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLPROARQ()
LOCAL cResult := "true|"
LOCAL cDirArq := ""
LOCAL lProc	  := .F.
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


//Obj

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Obj

If Val(HttpGet->cLinArray) > 0 .And. Len(HttpSession->aFileList) > 0 .And. Len(HttpSession->aFileList) >= Val(HttpGet->cLinArray)
	cDirArq := HttpSession->aFileList[Val(HttpGet->cLinArray)]:cArquivoIN
	lProc   := HttpSession->aFileList[Val(HttpGet->cLinArray)]:cStatus == '0'
EndIf

// Registro no WS

oObj:cUserCode 		:= "MSALPHA"
oObj:cUserPlsName 	:= getNameUsr()
oObj:cDirArqIn 		:= cDirArq
oObj:cRDACode 		:= Httpget->cRda

// Metodo

If lProc
	If oObj:ProcUpXml()
		cResult := oObj:CPROCUPXMLRESULT
	Else
		cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
	EndIf
Else
	cResult := "false|Este arquivo já foi processado"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLIAARQ
Inclui ou altera arquivo XML
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLIAARQ()
LOCAL cResult := ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//Obj

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

If ValType(HttpPost->cRda) == 'U'
	HttpPost->cRda := ""
EndIf

// Registro no WS

oObj:cUserCode 		:= "MSALPHA"
oObj:cUserPlsName 	:= getNameUsr()
oObj:cDirArqIn 		:= strtran(HttpPost->cDirArq,'/\','\')
oObj:cRDACode 		:= substr(HttpPost->cRda,1,6)

// Metodo

If oObj:IncXmlUp()
	cResult := oObj:cINCXMLUPRESULT
Else
	cResult := StrTran(PWSGetWSError( "" ),":","")
EndIf
HttpSession->cRetChImp := cResult

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLATUPRO
Retorna informação do prof com base na pesquisaL
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLATUPRO()
LOCAL cResult 	:=  "true|"
LOCAL nI		:= 0
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// obj

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUSERCODE	:= "MSALPHA"
oObj:cRdaCode	:= HttpGet->cRda
oObj:cCodLoc	:= HttpGet->cCodLoc
oObj:cBusca		:= HttpGet->cBusca

// Lista de profissional de saude

If oObj:ProfSaud()
	HttpSession->PROSAUD := oObj:oWSPROFSAUDRESULT:OWSLISTPROFSAUD:oWSPROFSAUD
EndIf

//Monta retorno para o combo

For nI:=1 To Len(HttpSession->PROSAUD)
	cResult += HttpSession->PROSAUD[nI]:cCODE + "%" + AllTrim(HttpSession->PROSAUD[nI]:cNAME) + "|"
Next

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSMONSOL
Monta box de Solicitantes
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSMONALL()
LOCAL nI		:= 0
LOCAL cResult  	:= "true|"
LOCAL oObj		:= NIL
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUSERCODE:= "MSALPHA"
oObj:cBusca  := HttpGet->cBusca

// Lista de profissional de saude

HttpSession->PROSAUD := {}
If oObj:ProfSAll()
	HttpSession->PROSAUD := oObj:oWSPROFSALLRESULT:OWSLISTPROFSAUD:oWSPROFSAUD

	For nI:=1 To Len(HttpSession->PROSAUD)
		cResult +=	HttpSession->PROSAUD[nI]:cCode+"$"+;
			HttpSession->PROSAUD[nI]:cName+"|"
	Next
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSMONSOL
Monta box de Solicitantes
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSMONSOL()
LOCAL nI		:= 0
LOCAL cResult  	:= "true|"
LOCAL oObj		:= NIL
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUSERCODE:= "MSALPHA"
oObj:cRdaCode := HttpGet->cRda
oObj:cCodLoc  := HttpGet->cCodLoc

// Lista de profissional de saude

HttpSession->PROSAUD := {}
If oObj:ProfSaud()
	HttpSession->PROSAUD := oObj:oWSPROFSAUDRESULT:OWSLISTPROFSAUD:oWSPROFSAUD

	cResult +=	"''"+"$"+"-- Selecione um Solicitante --"+"|"

	For nI:=1 To Len(HttpSession->PROSAUD)
		cResult +=	HttpSession->PROSAUD[nI]:cCode+"$"+;
			HttpSession->PROSAUD[nI]:cName+"|"
	Next
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCHACPR
Chama o formulario de perda e roubo
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCHACPR()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//Chama formulario
cHtml += ExecInPage("PPLCHACPR")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCHABOL
Chama o formulario de boleto
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCHABOL()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// Contratos

If ValType(HttpSession->aContrato) == 'U'
	HttpSession->aContrato := PLRETOECS(HttpSession->OPEVIEW,'C')
EndIf


//Chama formulario

cHtml += ExecInPage("PPLCHABOL")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCHAMIR
Chama o formulario de IR
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCHAMIR()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//Chama formulario

cHtml += ExecInPage("PPLCHAMIR")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCHASIN
Chama o formulario de Sinistralidade
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCHASIN()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//Chama formulario

cHtml += ExecInPage("PPLCHASIN")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCHAUTL
Chama o formulario de extrato de utilizacao
@author PLSTEAM
@since 10.2007
@version P12
/*/
web function PPLCHAUTL()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//Chama formulario

cHtml += ExecInPage("PPLCHAUTL")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCHDPM
Chama o formulario demonstrativo de pagamento medico
@author PLSTEAM
@since 10.2007
@version P12
/*/
web function PPLCHDPM()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLROTDESC")

WEB EXTENDED END

return cHtml

/*/{Protheus.doc} PPLCHEPM
Chama o formulario extrato de pagamento medico
@author PLSTEAM
@since 10.2007
@version P12
/*/
web function PPLCHEPM()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLROTDESC")

WEB EXTENDED END

return cHtml

/*/{Protheus.doc} PPLCHDAC
Chama o formulario demonstrativo de analise conta medica
@author PLSTEAM
@since 10.2007
@version P12
/*/
web function PPLCHDAC()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLROTDESC")

WEB EXTENDED END

return cHtml

/*/{Protheus.doc} PPLCHDPO
PPLCHDPO
@author PLSTEAM
@since 10.2007
@version P12
/*/
web function PPLCHDPO()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLROTDESC")

WEB EXTENDED END

return cHtml

/*/{Protheus.doc} PPLCHADPM
Inclusão de webfunction PPLCHADPM para avisar que a rotina foi descontinuada.
@author PLSTEAM
@since 10.2007
@version P12
/*/
web function PPLCHADPM()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLROTDESC")

WEB EXTENDED END

return cHtml

/*/{Protheus.doc} PPLCHADAC
Inclusão de webfunction PPLCHADAC para avisar que a rotina foi descontinuada.
@author PLSTEAM
@since 10.2007
@version P12
/*/
web function PPLCHADAC()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLROTDESC")

WEB EXTENDED END

return cHtml

/*/{Protheus.doc} PPLCHAPTC
Chama o formulario de geracao de protocolo
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCHAPTC()
local cHtml 		:= ""
local nI			:= 0
local oObjLib 		:= NIL
local nLen			:= IIf(Valtype(HttpSession->RDAVIEW) == "A", Len(HttpSession->RDAVIEW), 0 )
private cValParam 	:= HttpSession->cValParam

WEB EXTENDED INIT cHtml START "InSite"

//Parametro

oObjLib := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObjLib:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObjLib, "PLSXFUN.APW" )

oObjLib:cUSERCODE := "MSALPHA"
oObjLib:cRDACode  := ""


// RDA(s)
if nLen > 0

	for nI := 1 to nLen
		oObjLib:cRDACode	+= HttpSession->RDAVIEW[nI]:cCode + "|"
	next nI

	if right(oObjLib:cRDACode, 1) == "|" //tiro o ; final
		oObjLib:cRDACode := left(oObjLib:cRDACode, (len(oObjLib:cRDACode)-1))
	endIf

else
	Return PPLSALERT( "", "Atenção", "", "W_PPLCHAIMP.APW" )
endif

//Busca Calendario de Pagamento
If oObjLib:getCalend()
	cInterPag := oObjLib:cGETCALENDRESULT
Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLCHAIMP.APW" )
EndIf

if ! HttpSession->lCombo
	return PPLSALERT( "", "Atenção", "", "W_PPLCHAPTC.APW" )
endIf

cHtml += ExecInPage("PPLCHAPTC")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLRELGEN
Relatorios
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLRELGEN()
LOCAL oObj	:= NIL
LOCAL cHtml := ""

//Web Function

WEB EXTENDED INIT cHtml START "InSite"

//WS

oObj := WSPLSRELT():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSRELT.APW" )

//Parametros

oObj:cUserCode 	:= "MSALPHA"
oObj:cFunName  	:= HttpGet->cFunName
oObj:oWSINPAR:cTpPortS	:= alltrim(Str(getTpPortal()))

//Parametros conforme rotina

Do Case

	//Boleto

	Case HttpGet->cFunName == 'PPRELBOL'
		oObj:oWSINPAR:nRecno := Val( StrTran( strTran(HttpGet->cRecno, ".", ""), ",", ""))
		oObj:oWSINPAR:cAlias := 'SE1'

		//Extrato de utilizacao

	Case HttpGet->cFunName == 'PPRELULT'
		oObj:oWSINPAR:cMatric	:= HttpGet->Field_MATUSU
		oObj:oWSINPAR:dDtDe		:= CToD(HttpGet->Field_DTDE)
		oObj:oWSINPAR:dDtAte	:= CToD(HttpGet->Field_DTATE)
		//Carteirinha beneficiario
	Case HttpGet->cFunName == 'PPLSRECB'
		oObj:oWSINPAR:cMatric := HttpGet->Field_MATUSU

		//Demonstrativo de I.R

	Case HttpGet->cFunName == 'PPRELIR'
		oObj:oWSINPAR:cMatric	:= HttpGet->Field_MATUSU
		oObj:oWSINPAR:cCodEmp	:= HttpGet->Field_CODEMP
		oObj:oWSINPAR:cAno		:= HttpGet->Field_ANO

		//Sinistralidade

	Case HttpGet->cFunName == 'PPRELSIN'
		oObj:oWSINPAR:cMatric	:= HttpGet->Field_MATUSU
		oObj:oWSINPAR:cAno		:= HttpGet->Field_ANO
		oObj:oWSINPAR:cMes		:= HttpGet->Field_MES

		//Movimentacao

	Case HttpGet->cFunName == 'PPRELBEN'
		oObj:oWSINPAR:cNumCon	:= HttpGet->Field_NUMCON
		oObj:oWSINPAR:cSubCon	:= HttpGet->Field_SUBCON
		oObj:oWSINPAR:dDtDe		:= CToD(HttpGet->Field_DTDE)
		oObj:oWSINPAR:dDtAte	:= CToD(HttpGet->Field_DTATE)
		oObj:oWSINPAR:cSituac	:= HttpGet->Field_SITCAD
		oObj:oWSINPAR:cTipo		:= HttpGet->Field_TIPO

		//XML

	Case HttpGet->cFunName == 'PPRELXML'
		oObj:oWSINPAR:cXmlFile	:= HttpGet->Field_FName

		//Guia SADT PDF

	Case HttpGet->cFunName == 'PPRELST'
		oObj:oWSINPAR:cNumAut   := HttpGet->Field_NUMAUT
		oObj:oWSINPAR:cProrrog  := HttpGet->lProrrog
		oObj:oWSINPAR:cTp	 	:= HttpGet->cTp

		If !httpSession->lPOGTISS 	// Verifica se imprime Guia Tiss padrão ANS.
	   		If HttpGet->cReimpr == "1"
				W_PPLSMATREI() 	// Imprime Guia Antiga
			Else
		   		W_PPLIMPGUIA()
       		EndIf
			Return cHtml
		EndIf

		//Guia Recurso de GLOSA PDF

	Case HttpGet->cFunName == 'PPRELRG'
		oObj:oWSINPAR:nRecno := val(HttpGet->cRecno)

		// Relatorio de Solicitacao de Cancelamento de Planos

	Case HttpGet->cFunName == 'PP99BSOL'
		oObj:oWSINPAR:nRecno := val(HttpGet->cRecno)

		// Relatorio de Confirmacao de Cancelamento de Plano

	Case HttpGet->cFunName == 'PP99BCON'
		oObj:oWSINPAR:nRecno := val(HttpGet->cRecno)

	Case HttpGet->cFunName == 'PPRELUPD'
		oObj:oWSINPAR:cRda := HttpGet->Field_RDA

		//PEG - protoolo eletronico de guias

	Case HttpGet->cFunName == 'PPRELPEG'
		oObj:oWSINPAR:cXmlFile	:= HttpGet->Field_FName
		oObj:oWSINPAR:nRecno	:= If(ValType(HttpGet->cRecno)=="C",Val( StrTran( StrTran(HttpGet->cRecno, ",", ""), ".", "")),nil)
	Case HttpGet->cFunName == 'PPRELPROT'
		oObj:oWSINPAR:cProtocolo	:= HttpGet->cProtocolo
		oObj:oWSINPAR:nRecno	:= If(ValType(HttpGet->cRecno)=="C",Val( StrTran( StrTran(HttpGet->cRecno, ",", ""), ".", "")),nil)
	Case HttpGet->cFunName == 'PLSRCRIT'
		oObj:oWSINPAR:cSequen	:= HttpGet->Field_SEQUEN

	Case HttpGet->cFunName == 'PPLEXE754'
		oObj:oWSINPAR:cTipo	 := HttpGet->Field_CTIPO
		oObj:oWSINPAR:ddtAte := cTod(HttpGet->Field_DTATE)
		oObj:oWSINPAR:ddtDe	 := cTod(HttpGet->Field_DTDE)
		oObj:oWSINPAR:cRda	 := HttpGet->Field_CODRDA
		oObj:oWSINPAR:cGuia	 := HttpGet->Field_CGUIA
		oObj:oWSINPAR:cTp	 := HttpGet->Field_CLIBERA

		//Demonstrativo de pagamento medico

	Case HttpGet->cFunName == 'PPRELDPM' .or. HttpGet->cFunName == 'PPRELDAC' .or. HttpGet->cFunName == 'PPRELDPO'.or. HttpGet->cFunName == 'PPRELEPM'
		oObj:oWSINPAR:cRda	:= HttpGet->Field_CODRDA
		oObj:oWSINPAR:cAno	:= HttpGet->Field_ANO
		oObj:oWSINPAR:cMes	:= HttpGet->Field_MES
	Case HttpGet->cFunName == 'PPRELDOC'
		oObj:oWSINPAR:nRecno	:= Val(HttpGet->cRecno)
		oObj:oWSINPAR:cAlias := 'B2H'
	Case HttpGet->cFunName == 'PLSQUIT'
		oObj:oWSINPAR:cTipo 		:= "1"
		oObj:oWSINPAR:cCodEmp	:= Right(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:CCODE, 4)
		oObj:oWSINPAR:cNumCon	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:CNUMCON
		oObj:oWSINPAR:cSubCon	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:CSUBCON
		oObj:oWSINPAR:cMatric	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CFAMILIA
		oObj:oWSINPAR:cAno		:= IIF( ValType(HttpGet->Field_Data) == "C", HttpGet->Field_Data, "")
	Case HttpGet->cFunName == 'PLSIMPBEN'
		oObj:oWSINPAR:nRecno	:= Val(HttpGet->cRecno)
		oObj:oWSINPAR:cAlias := 'BBA'
	case HttpGet->cFunName == 'PPRELRCT'
		oObj:oWSINPAR:cProtocolo := HttpGet->cProtocolo
		//Estatistica de Partos
	Case HttpGet->cFunName == 'PPLSREPA'
		oObj:oWSINPAR:cOperac	:= HttpGet->Field_CODOPE
		oObj:oWSINPAR:cRdaHos	:= HttpGet->Field_RDAHOS
		oObj:oWSINPAR:cRdaMed	:= HttpGet->Field_RDAMED

		//Reembolso Analítico

	Case HttpGet->cFunName == 'PPRELRBANL'
		oObj:oWSINPAR:cMatric	:= HttpGet->Field_MATUSU
		oObj:oWSINPAR:dDtDe		:= CToD(HttpGet->Field_DTDE)
		oObj:oWSINPAR:dDtAte	:= CToD(HttpGet->Field_DTATE)
		oObj:oWSINPAR:dDtDeO	:= CToD(HttpGet->Field_DTDEP)
		oObj:oWSINPAR:dDtAteO	:= CToD(HttpGet->Field_DTATEP)
		oObj:oWSINPAR:cChaveGen	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CCODE

		//Extrato de Reajuste

	Case HttpGet->cFunName == 'R510WEB'
		oObj:oWSINPAR:cMatric	:= HttpGet->Field_MATUSU
		oObj:oWSINPAR:dDtDe		:= cToD('01/01/' + HttpGet->Field_ANO)
		oObj:oWSINPAR:dDtAte	:= cToD('31/12/' + HttpGet->Field_ANO)

		//Extrato de utilização Beneficiário - Co-participação

	Case HttpGet->cFunName == 'PPRELEXTUTI'
		oObj:oWSINPAR:cMatric	:= HttpGet->Field_MATUSU
		oObj:oWSINPAR:cMes		:= HttpGet->Field_DTDESCI //irá receber mes e ano inicial desconto
		oObj:oWSINPAR:cAno		:= HttpGet->Field_DTDESCF  // irá receber mes e ano final desconto
		oObj:oWSINPAR:dDtDe		:= CToD(HttpGet->Field_DTDEP)
		oObj:oWSINPAR:dDtAte	:= CToD(HttpGet->Field_DTATEP)
		oObj:oWSINPAR:cChaveGen	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CCODE

		//Extrato Financeiro

	Case HttpGet->cFunName == 'PPREEFINA' //19-01
		oObj:oWSINPAR:dDtDe		:= CTOD("01/"+HttpGet->cDatIni)
		oObj:oWSINPAR:dDtAte	:= CTOD("01/"+HttpGet->cDatFin)
		oObj:oWSINPAR:cMatric 	:= IF(!EMPTY(HttpGet->cMatric), HttpGet->cMatric, HttpGet->cMatTitular)
		oObj:oWSINPAR:cTipo   	:= HttpGet->cTipoDesp
		oObj:oWSINPAR:cTp   	:= HttpGet->cTipoProd


		//Impressão de guias TISS em branco
	Case HttpGet->cFunName == 'PPRELGUI'
		oObj:oWSINPAR:cTipo := HttpGet->cTipGui
		oObj:oWSINPAR:nRecno	 := VAL(HttpGet->cQtdGui)

EndCase

//Executa metodo

HttpSession->cFileName := ""

If oObj:getRelGEN() //Nessa chamada o array ja esta vazio
	HttpSession->cFileName := oObj:cGETRELGENRESULT
EndIf

//Exibe boleto

cHtml += ExecInPage("PPLRELGEN")

//Log BSW para LGPD
if ValType(httpGet->cRotinLGPD) <> "U"
	oObj:cUserCode	 := "MSALPHA"
	oObj:cUserLGPD   := HttpSession->USR_INFO[1]:cUserLogin
	oObj:cRotinLGPD  := httpGet->cRotinLGPD
	oObj:LogLGPD()
endIf

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLGETCID
 Retorna Cidades do Estado
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGETCID()
LOCAL cResult 	:= "true|"
LOCAL nI		:= 0
LOCAL aRet		:= {}
LOCAL cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametro
oObj:cUserCode 	:= "MSALPHA"
oObj:nTp		:= 4
oObj:cAlias		:= "BID"
oObj:cRetorno	:= "BID->BID_CODMUN,BID->BID_DESCRI"
oObj:nIdx		:= 3 //BID_FILIAL + BID_EST + BID_DESCRI
oObj:cChave		:= HttpGet->Field_ESTADO
oObj:cCmdChave	:= "BID_EST"

// Alimenta as variaves com o x3-combobox
if oObj:getCombo()

	aRet := oObj:oWSGETCOMBORESULT:oWSCbGeneric:oWSGenericStruct

	// Monta combo
	if len(aRet) > 0

		//Monta retorno para o combo

		For nI := 1 to Len(aRet)
			cResult += aRet[nI]:cCode + "$" + aRet[nI]:cDescription + "|"
		next

		cResult := Left(cResult,Len(cResult)-1)

	endIf

endIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGETSUB
Retorna subcontratos de um contrato
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGETSUB()
LOCAL cResult 	:= "true|"
LOCAL nI		:= 0
LOCAL aRet		:= {}
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

// Lista Cidade
aRet := PLRETOECS(HttpSession->OPEVIEW,'S',HttpGet->Field_NUMCON)

If Len(aRet) > 0

	//Retorna a operadora
	cResult += HttpSession->cIntPad + "%"

	//Monta retorno para o combo

	For nI:=1 To Len(aRet)
		cResult += aRet[nI]:cCode + "$" + If(Empty(aRet[nI]:cNomSub),aRet[nI]:cDescription,aRet[nI]:cNomSub) + "|"
	Next

	cResult := Left(cResult,Len(cResult)-1)

EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGATCMP
Gatilho de campos
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGATCMP()
LOCAL cResult 	:= "true|"
LOCAL oObj		:= NIL
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml  //Aqui não tem o insite pq é utilizada no layout generico onde não tem login


//Obj

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametro

oObj:cUserCode		:= "MSALPHA"
oObj:cUserPlsCode	:= getUsrWeb()
oObj:nTpPor			:= getTpPortal()
oObj:cFunName		:= HttpGet->cFunName
oObj:cChave			:= HttpGet->cChave
oObj:cVldGen		:= HttpGet->cVldGen
oObj:nTp			:= Val(HttpGet->nTpRet)

If valtype(HttpSession->cTp) <> "U"
	oObj:cTipGui := STRZERO(val(HttpSession->cTp),2)
Else
	oObj:cTipGui := "01"
Endif

//Executa metodo para montar Header
If oObj:getGAT()
	cResult := 'true|' + oObj:cGETGATRESULT
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLPROBEN
Post do formulario para gravacao
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLPROBEN()
LOCAL cResult 	:= "true|"
LOCAL oObj		:= NIL
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


//Obj

oObj := WSPLSXINC():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXINC.APW" )

//parametros

oObj:cUserCode	:= "MSALPHA"

//Monta envio de fields

WCArrPost(@oObj:oWSINCBENEFIC:oWSDADBENEFIC)

//Executa metodo para montar Header

If oObj:setBenefic()
	cResult := "true|" + oObj:cSETBENEFICRESULT
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSETCAR
Set solicitacao de carteirinha
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSETCAR()
LOCAL cResult 	:= "true|"
LOCAL oObj		:= NIL
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//Obj

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametro

oObj:cUSERCODE 	:= "MSALPHA"
oObj:cMatUsu	:= HttpGet->Field_MATUSU
oObj:cMotCar	:= HttpGet->Field_MOTCAR

//Executa metodo para montar Header

If oObj:setSolCar()
	cResult := "true|" + oObj:cSETSOLCARRESULT
EndIf

//Log BSW para LGPD
if ValType(httpGet->cRotinLGPD) <> "U"
	oObj:cUserCode	 := "MSALPHA"
	oObj:cUserLGPD   := HttpSession->USR_INFO[1]:cUserLogin
	oObj:cRotinLGPD  := httpGet->cRotinLGPD
	oObj:LogLGPD()
endIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGETDGRI
Retorna dados para o browse gridData
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGETDGRI()
LOCAL cResult  	:= "true|"
LOCAL cRdas		:= ""
LOCAL oObj		:= NIL

LOCAL nI		:= 0
LOCAL nLen		:= IIf(Valtype(HttpSession->RDAVIEW) == "A", Len(HttpSession->RDAVIEW), 0 ) //Tratamento para a existencia das RDAs (a função eh chamada antes do login para consulta rede credenciada)
LOCAL cHtml 	:= ""

WEB EXTENDED INIT cHtml

// Metodo e propriedades

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//HttpSession->RDAVIEW
For nI := 1 to nLen
	If ! Empty(cRdas)
		cRdas += ","
	EndIf
	cRdas += "'" + HttpSession->RDAVIEW[nI]:cCodOpe + HttpSession->RDAVIEW[nI]:cCode +"'"
Next nI
//Tratamento para a existencia das RDAs (a função eh chamada antes do login para consulta rede credenciada)
If nLen > 0
	httpGet->cWhere += "|"+"Field_RDA=" + cRdas
EndIf

oObj:cUserCode	:= "MSALPHA"
oObj:cFunName	:= httpGet->cFunName
oObj:cWhere 	:= httpGet->cWhere
oObj:cBuscaTReg	:= httpGet->cBuscaTReg
oObj:cPesquisa	:= iIf(valType(httpGet->cPesquisa)=='U',"",httpGet->cPesquisa)
oObj:cSemaforo	:= iIf(valType(httpGet->cSemaforo)=='U',"",httpGet->cSemaforo)
oObj:nPaginaIni	:= val(httpGet->nPagina)

If ! Empty(httpGet->cRecnoAtu)

	cRecnoChaPtc := httpGet->cRecnoAtu

	If cRecnoChaPtc <> "undefined" .AND. cRecnoChaPtc > '0'
		HttpSession->RECNOCHAPTC := cRecnoChaPtc
	ElseIf cRecnoChaPtc <> "undefined" .AND. cRecnoChaPtc == '0'
		oObj:cWhere := +"Field_RECNO=" + HttpSession->RECNOCHAPTC
	EndIf
EndIf

// Lista de faturas

If oObj:getDadGrid()
	cResult +=	oObj:cGETDADGRIDRESULT
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

//Log BSW para LGPD
if ValType(httpGet->cRotinLGPD) <> "U"
	oObj:cUserCode	 := "MSALPHA"
	oObj:cUserLGPD   := HttpSession->USR_INFO[1]:cUserLogin
	oObj:cRotinLGPD  := httpGet->cRotinLGPD
	oObj:LogLGPD()
endIf

WEB EXTENDED END

getLOGMon()

return PLSDECODE(cResult)

/*/{Protheus.doc} PPSAphGuia
que altera a funcao que monta a ExecPage na funcao
PPLSMATREI - Impressao da Guia de Atendimento.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function PPSAphGuia(cTipoGuia)
	LOCAL cPageExec := "PPLIMPGUIA"
	LOCAL cHtml := ""

	WEB EXTENDED INIT cHtml START "InSite"


	//Tipo de Guia

	Do Case
   
   		// Verifica se irá imprimir guia Tiss padrão ANS									
   
		Case !httpSession->lPOGTISS // Não imprime Guia Tiss padrão ANS.
			cPageExec := "PPLIMPGUIA"
		
		// Consulta

		Case cTipoGuia == '1'
			cPageExec := "PPLSCONS" // "PPLGUICON" // 'Consulta - Execução'

			// Sadt

		Case cTipoGuia == '2'
			cPageExec := "PPLSSADT" // "PPLGUISADT" // 'Sadt'

			// Internacao

		Case cTipoGuia == '3'
			cPageExec := "PPLSSOIN" // "PPLGUIINTE" // 'Inter./Prorrog. - Solic./Exec.'

			// Odontologico

		Case cTipoGuia == '4'
			cPageExec := "PPLSGTOP" //"PPLGUIODON" // Odontológico

			// Honorario Individual

		Case	cTipoGuia == '5'
			cPageExec := "PPLSHOIN"

	EndCase

	WEB EXTENDED END

	getLOGMon()

Return(cPageExec)

/*/{Protheus.doc} PPLPROARQ
Processa arquivo (importacao xml)o.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLEXCARQ()
LOCAL cResult := "true|"
LOCAL cDirArq := ""
LOCAL lProc	  := .F.
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//Obj

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Obj

If Val(HttpGet->cLinArray) > 0 .And. Len(HttpSession->aFileList) > 0 .And. Len(HttpSession->aFileList) >= Val(HttpGet->cLinArray)
	cDirArq := HttpSession->aFileList[Val(HttpGet->cLinArray)]:cArquivoIN
	lProc   := (HttpSession->aFileList[Val(HttpGet->cLinArray)]:cStatus $ '2')
EndIf

// Registro no WS

oObj:cUserCode 		:= "MSALPHA"
oObj:cUserPlsName 	:= getNameUsr()
oObj:cDirArqIn 		:= cDirArq
oObj:cRDACode 		:= Httpget->cRda

// Metodo

If lProc
	If oObj:ProcDeXml()
		cResult := oObj:CPROCDEXMLRESULT
	Else
		cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
	EndIf
Else
	cResult := "false|Somente arquivos no Status <strong>Não Acatado</strong> podem ser excluídos."
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLVALPEG
Valida Guias antes da PEG
@author PLSTEAM
@since 10.2007
@version P12
/*/
web function PPLVALPEG()
LOCAL cResult  	:= ""
LOCAL oObj		:= nil

//D - Digitação Offline   P - Protocolo
Local cTipo		:= IIf(Valtype(HttpGet->cTipo) == "U", "D", HttpGet->cTipo)
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

// Metodo e propriedades

oObj := WSPLSXFUN():new()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//parametros

oObj:cUserCode				:= "MSALPHA"

oObj:cChave		:= httpGet->cInfPegGui
oObj:cTipo 		:= cTipo
oObj:cTipGui	:= httpGet->cTipGuia

if oObj:verDtGuia()
	cResult :=	oObj:cVERDTGUIARESULT
else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
endIf

WEB EXTENDED END

getLOGMon()

return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSETPEG
Gera peg de guias
@author PLSTEAM
@since 10.2007
@version P12
/*/
web function PPLSETPEG()
LOCAL cResult  	:= ""
LOCAL oObj		:= nil
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// Guarda na sessao caso sai da pagina

httpSession->cInProcRda := httpGet->cInProcRda

oObj := WSPLSXFUN():new()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//parametros

oObj:cUserCode				:= "MSALPHA"
oObj:oWSMatPeg:cWhere		:= httpGet->cWhere
oObj:oWSMatPeg:cColsCk		:= httpGet->cColCK
oObj:oWSMatPeg:cColsUnCk	:= httpGet->cColUnCK
oObj:oWSMatPeg:cSemaforo	:= httpGet->cSemaforo
oObj:oWSMatPeg:lGerPeg		:= iIf(httpGet->lGerPeg=="true",.t.,.f.)
oObj:oWSMatPeg:lMosGui		:= httpSession->lMosGui
oObj:oWSMatPeg:cfunName		:= IIF(Empty(httpGet->DigMan), "", httpGet->DigMan)  //Informar se é da digitação off-line de guias
oObj:oWSMatPeg:lgrvVlrApr	:= IIF(Empty(httpGet->lVlrApr), .F., iif( httpGet->lVlrApr == "true", .T., .F.))  //Informar se é da digitação off-line de guias
oObj:oWSMatPeg:cTipoGuia		:= IIF( Empty(httpGet->cTipoGuia), "",httpGet->cTipoGuia )  //Se é Resumo de Internação


// tranferencia de guias para peg definitivo

if oObj:setTFGuia()
	cResult :=	oObj:cSETTFGUIARESULT
else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
endIf

WEB EXTENDED END

getLOGMon()

return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCHKIPR
Verifica se esta em processado
@author PLSTEAM
@since 10.2007
@version P12
/*/
web function PPLCHKIPR()
LOCAL cResult  	:= ""
LOCAL oObj		:= nil
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

// Metodo e propriedades

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode			 	:= "MSALPHA"
oObj:oWSMatPeg:cSemaforo	:= httpGet->cSemaforo
oObj:oWSMatPeg:cFunJs	 	:= httpGet->cFunJs

// tranferencia de guias para peg definitivo

if oObj:getInProces()
	cResult :=	oObj:cGETINPROCESRESULT
else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
endIf

WEB EXTENDED END

getLOGMon()

return PLSDECODE(cResult)

/*/{Protheus.doc} PPOSICIONE
 Verifica se esta em processado
@author PLSTEAM
@since 10.2007
@version P12
/*/
web function PPOSICIONE()
LOCAL cResult := "false|"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

// Metodo e propriedades

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode		:= "MSALPHA"
oObj:nIdx			:= VAL(HttpGet->Field_INDICE)
oObj:cCmdChave	 	:= HttpGet->Field_CAMPO
oObj:cChave	 		:= HttpGet->Field_CODRDA
oObj:cAlias	 		:= HttpGet->Field_ALIAS


// tranferencia de guias para peg definitivo

if oObj:posicione()
	cResult :=	oObj:cPOSICIONERESULT
else
	cResult :=	"false|"+StrTran(PWSGetWSError( "" ),":","")
endif

WEB EXTENDED END

getLOGMon()

return PLSDECODE(cResult)

/*/{Protheus.doc} PPLIPREE
Imprime relatorio e manda por email
@author PLSTEAM
@since 10.2007
@version P12
/*/
web function PPLIPREE

LOCAL cResult := "false|"
Local cGlosa  := 'N'
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// Metodo e propriedades

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

if ValType(HttpGet->cGlosa) <> 'U'
	cGlosa  :=  HttpGet->cGlosa
endif

oObj:cUserCode		:= "MSALPHA"
oObj:cChave			:= HttpGet->Field_CODRDA + "|" + HttpGet->Field_EMAIL + "|" + HttpGet->cRecno + "|" + HttpGet->cTipoRel + "|" + cGlosa + "|"
oObj:cFunName	 	:= HttpGet->cFunRel


// tranferencia de guias para peg definitivo

if oObj:ppImpRel()
	cResult :=	oObj:cPPIMPRELRESULT
else
	cResult :=	"false|"+StrTran(PWSGetWSError( "" ),":","")
endif

WEB EXTENDED END

getLOGMon()

return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGUIPR
Chamada da pagina de escolha de Guia ou Protocolo (recurso Glosa)
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLRECGLO()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml  START "InSite"

cHtml := ExecInPage( "PPLRECGLO" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLADRECG
Chamada da pagina para adicionar Recurso de Glosa
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLADRECG()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"


//Tipo de pre-atendimento se vai pre-atender ou atender (executar)

HttpSession->cObsRecG := ""

//Mostra a pagina para entrar com o protocolo/Guia

cHtml := ExecInPage( "PPLADDRECG" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLVIRECG
Chamada da pagina para visualizar Recurso de Glosa
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLVIRECG()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"


//Mostra a pagina para entrar com o protocolo/Guia

cHtml := ExecInPage( "PPLVISRECG" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLGETRECG
Retorna os dados da guia glosada
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGETRECG()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

// oBJ

oObj := WSPLRECGLO():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLRECGLO.APW" )


// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cRecno		:= HttpGet->cRecno
oObj:cVisDad		:= HttpGet->cTipRet

// Retorna dados

If oObj:GetDadGuiGlo()
	cResult := oObj:cGetDadGuiGloRESULT
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)


/*/{Protheus.doc} PPLDOCRECG
Grava o anexo do Recurso de Glosa
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLDOCRECG()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

// oBJ

oObj := WSPLRECGLO():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLRECGLO.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cRecnoB4D	:= HttpGet->cRecno
oObj:cArq1			:= HttpGet->cUpld1

// Retorna dados

If oObj:PutRecGloDoc()
	cResult += oObj:cPutRecGloDocRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)


/*/{Protheus.doc} PPLDETRECG
Retorna os dados do recurso de glosa
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLDETSRECG()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLRECGLO():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLRECGLO.APW" )


// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cRecnoBVO	:= Alltrim(Str(HttpGet->cRecno))


// Retorna dados

If oObj:GetRecGloEvents()
	cResult += oObj:cGetRecGloEventsRESULT

EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)


/*/{Protheus.doc} PPLTMPPCT

@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLTMPPCT()

local cPacote
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cPacote := HttpGet->cPacote

HttpSession->cPacote := cPacote

WEB EXTENDED END

getLOGMon()

return PLSDECODE("true")

/*/{Protheus.doc} PPLTMPPCT
Função responsável por popular a lista de pacotes na liberação
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSERPC()
Local nPosRDA	:= 0
local nI		:= 0
local nP		:= 0
LOCAL cHtml   	:= ""
Local cMatric	:= ""
Local cNumAut	:= ""
Local cTipo		:= ""
Local cRDACode	:= ""
Local cCodLoc	:= ""
Local cTipoAut	:= ""
Local cCodEsp	:= ""
Local cAltCmp	:= ""
local cPacote 	:= "false|Erro ao buscar dados da liberação."
LOCAL oObj 		:= NIL
local aServ 	:= {}

WEB EXTENDED INIT cHtml START "InSite"

// oBJ
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

cMatric 	:= HttpSession->aVldCartao[2]
cNumAut 	:= AllTrim(StrTran(StrTran(HttpGet->cNumeAut,".",""),"-",""))
cTipo   	:= HttpGet->cTp
cRDACode 	:= HttpGet->cRda
cCodLoc 	:= HttpGet->cCodLoc
cTipoAut	:= IiF( ValType(HttpGet->cTpAut) != 'U',HttpGet->cTpAut,"L")
cAltCmp		:= HttpGet->cAltGuia

if ! empty(cCodLoc)
	nPosRDA := aScan( HttpSession->RDAVIEW, { |x| x:cCODE == HttpGet->cRda .And. x:cCodLoc == cCodLoc} )
else
	nPosRDA := aScan( HttpSession->RDAVIEW, { |x| x:cCODE == HttpGet->cRda} )
endIf

if nPosRDA > 0 .and. ValType(HttpSession->RDAVIEW[nPosRDA]:OWSMESPRDA:OWSESPRDA) == "A"

	If Len(HttpSession->RDAVIEW[nPosRDA]:OWSMESPRDA:OWSESPRDA) > 0
		cCodEsp := HttpSession->RDAVIEW[nPosRDA]:OWSMESPRDA:OWSESPRDA[1]:cCodEsp
	EndIf

endif

oObj:cUSERCODE		 := cMatric
oObj:cUSERCARDNUMBER := cMatric
oObj:cNUMAUT		 :=	cNumAut
oObj:cTIPOAUT		 := cTipoAut
oObj:cRDACODE		 := cRDACode
oObj:cCODLOC		 := cCodLoc
oObj:cTIPO			 := cTipo
oObj:cCODESP		 := cCodEsp
oObj:cSETDTINT 		 := ""
oObj:cAltera		 := cAltCmp

aadd(aServ, {"Código", "Descrição", "Pacote"})

If oObj:RetSerPct()

	if Len(oObj:oWSRETSERPCTRESULT:OWSMITEGUI) <> 0

		cPacote := "true|cabecalho@"

		For nI := 1 To Len(oObj:oWSRETSERPCTRESULT:OWSMITEGUI)

			For nP := 1 to len(oObj:oWSRETSERPCTRESULT:OWSMITEGUI[nI]:OWSSPCTITEGUI:OWSMPCTITEGUI)

				cPacote += oObj:oWSRETSERPCTRESULT:OWSMITEGUI[nI]:cCodPro + "|" + oObj:oWSRETSERPCTRESULT:OWSMITEGUI[nI]:cDesPro + "|" + oObj:oWSRETSERPCTRESULT:OWSMITEGUI[nI]:OWSSPCTITEGUI:OWSMPCTITEGUI[nP]:cCodPro + "|" + oObj:oWSRETSERPCTRESULT:OWSMITEGUI[nI]:OWSSPCTITEGUI:OWSMPCTITEGUI[nP]:cDesPro

				if nP <> len(oObj:oWSRETSERPCTRESULT:OWSMITEGUI[nI]:OWSSPCTITEGUI:OWSMPCTITEGUI)
					cPacote += "~"
				endif

			next

			if nI <> Len(oObj:oWSRETSERPCTRESULT:OWSMITEGUI)
				cPacote += "@"
			endif

		next
	else
		cPacote := "true|"
	endif

EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cPacote)

/*/{Protheus.doc} PPLVIRECG
Chamada da pagina para visualizar Recurso de Glosa
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLDETRECG()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml := ExecInPage( "PPLDETRECG" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCMPFP
Botao de complemento nos formularios do portal
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSCMPFP()
Local cResult := ""
Local oObj    := Nil
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSCMPFP():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSCMPFP.APW" )

oObj:cUserCode := "MSALPHA"
oObj:cFunName  := HttpGet->cFunName
oObj:cRda	   := HttpGet->cRda
oObj:cCodLoc   := HttpGet->cCodLoc
oObj:cTp	   := HttpGet->cTp
oObj:cNumAut   := StrTran(HttpGet->cNumAut,".","")

If oObj:PPLSCMPFP()
	cResult := oObj:CPPLSCMPFPRESULT
Else
	cResult :=  "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSHON
Rotina para buscar o honorario individual
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSHON()
LOCAL nI      	:= 0
LOCAL oObj	  	:= NIL
LOCAL lExibe  	:= .F.
LOCAL cResult 	:= "true|"
LOCAL nA		:= 0
LOCAL cSelected	:= ""
LOCAL cRetDadUsr:= ""
LOCAL cHtml 	:= ""
LOCAL cCodUsr	:= ""
LOCAL cCodRda	:= ""
LOCAL cTipGui	:= ""
LOCAL cMatric	:= ""
LOCAL cGuiRef	:= ""
LOCAL cDatGui	:= ""

WEB EXTENDED INIT cHtml START "InSite"


//Web Service

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros de entrada

oObj:cUserCode 		 := "MSALPHA"
oObj:cNumAut   		 := AllTrim(StrTran(StrTran(HttpGet->cNumeAut,".",""),"-",""))

//A solicitacao deve informar o tipo.

If ValType(HttpSession->aVldCartao) != 'U'
	oObj:cUserCardNumber := HttpSession->aVldCartao[2]
EndIf

oObj:cTipo 		 := HttpGet->cTp

if HttpGet->cTp = '11'
	oObj:cRDACode	 := StrTran(PLA09ASES(),"|M",",")//HttpGet->cRda Localiza todas as RDAS que estão no login
else
	oObj:cRDACode	 := HttpGet->cRda
endif

oObj:cCodLoc	 := HttpGet->cCodLoc
oObj:cTipoAut	 := IiF( ValType(HttpGet->cTpAut) != 'U',HttpGet->cTpAut,"L")


//Executa metodo para retorno da liberacao

If oObj:RetAutLib()

	HttpGet->cRda		:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cRda
	HttpGet->cCodLoc	:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cCodLoc
	If ValType(HttpSession->cTp) == 'U'
		HttpSession->cTp := HttpGet->cTp
	EndIf

	W_PPLDADRDA()

	For nA := 1 To Len(HttpSession->PROSAUD)
		if nA = 1
			cResult += "cComboSol!"
		endif

		if alltrim(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cProSol) = alltrim(HttpSession->PROSAUD[nA]:cCode)
			cSelected = "T"
		else
			cSelected = "F"
		endif

		cResult += HttpSession->PROSAUD[nA]:cCode + "$"+ HttpSession->PROSAUD[nA]:cName + "$" + cSelected + ";"
	next

	if Len(HttpSession->PROSAUD) > 0
		cResult += "|"
	endif


	//Cabecalho

	cResult +=	"cRda!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cRda+"|"+;				//0
		"cRegAns!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cRegAns+"|"+;				//1
		"cNomeRdaSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomeRda+"|"+; 		//2
		"cCnpjCpfSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cCnpjCpfSol+"|"+;		//3
		"cCnesSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cCnesSol+"|"+;      		//4
		"cNomeSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomeSol+"|"+;       	//5
		"cProExe!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cProExe+"|"+;       	//6
		"cCodSigExe!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cCodSigExe+"|"+;       	//7
		"cNumCrExe!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNumCrExe+"|"+;       	//8
		"cEstSigExe!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cEstSigExe+"|"+;       	//9
		"cMatric!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cMatric+"|"+;   	//10
		"cNomeUsr!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomeUsr+"|"+;     	//11
		"cTpAcom!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cTpAcom+"|"+;   	//12
		"cNomeSolT!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomeSolT+"|"+;         			//13
		"cCnesSolT!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cCnesSolT+"|"+;         //14
		"cNomPla!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomPla+"|"+;				//15
		"cDtVldCar!"+DToC(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:dDtVldCar)+"|"+; //16
		"cCarSaud!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cCarSaud+"|"+; //17
		"cGrPar!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cGrPar+"|"+;  //18
		"cGraPartExe!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cGrPar+"|"+;  //18
		"cDtEmiss!"+DToC(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:dDtSolicit)+"|"+; //19
		"cSenha!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cSenha+"|"+; //20
		"cFormNumber!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNumImp+"|"+;//62
		"cObs!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cObs+"|"+;//38
		"cAtendRN!"+ Iif(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cAteRN == '1', '1', '0')+"|"+;
		"cCarSolicit!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cCarSolicit+"|"+; 	//9
		"cTpIntern!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cTpIntern+"|"+; //22
		"cRegInter!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cRegInter+"|"+; //23
		"cIndAcid!"+Iif(!Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cIndAcid),oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cIndAcid,"")+"|"+; // 77
		"cCbosSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cCbosSol+'$'+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cDescCbosSol+"|"+; //20
		"cProSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cProSol+"|"+;         	//11
		"cProSolDesc!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomeSol+"|"+;
		"cNomeSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomeSol+"|"+;       	//13
		"dDataIniFat!"+DToC(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:dIniFat)+"|"+;
		"dDataFimFat!"+DToC(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:dFimFat)+"|"+;
		"dDataFimFat!"+DToC(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:dFimFat)+"|"+;
		"cNomeUsu!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomeUsr+"|"+;
		"cNumeCart!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cMatric+"|"+;
		"cCodSigSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cCodSigSol+"|"+;
		"cCid!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cCid+"|"+;               	//10
		"cCid2!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cCid2+"|"+; //29
		"cCid3!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cCid3+"|"+; //30
		"cCid4!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cCid4+"|"+; //31
		"cNumCrSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNumCrSol+"|"+;
		"dDtAut!"+dtoc(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:dDtAut)+"|"+; 		//1
		"dDtValid!"+DToC(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:dDtValid)+"|"+;    //6
		"cEstSigSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cEstSigSol+"|"+;
		iif(HttpGet->cTp != '11', "cCodLoc!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cCodLoc+"|", "" )+;
		"cObs!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cObs+"|"+;         			//17
		"cPadCon!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cPadCon+"|"+;
		"cQtdDSol!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cQtdDSol+"|"+;
		"cNumMaxAux!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNumAux+"|"

	cResult += iif (ValType(oObj:OWSRetAutLibRESULT:OWSSCABGUI:cNomSocBn) == "C", ;
		"cNomeSocial!" + oObj:OWSRetAutLibRESULT:OWSSCABGUI:cNomSocBn + "|", "") + "<"

	//Alimenta Sessions de impressão
	HttpSession->cNumeAut	:= AllTrim(StrTran(StrTran(HttpGet->cNumeAut,".",""),"-",""))
	HttpSession->cSenha		:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cSenha
	HttpSession->cCid  		:= ""
	HttpSession->cNome		:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cMatric+" - "+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomeUsr
	HttpSession->cNomeSol  	:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomeSolT
	HttpSession->cNomeRda	:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cRda + " - " + oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomeRda
	HttpSession->cIndCli		:= ""
	HttpSession->cFormNumber	:= ""
	HttpSession->aResult 	:= {}

	//Número de auxiliares
	HttpSession->cNumAux		:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNumAux

	For nI:=1 To Len(oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI) 		//63
		If oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cExibe == "1"
			lExibe := .T.
			cResult +=	"cTpServ!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cTpServ+"@"+; //0
				"cExibe!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cExibe+"@"+;  //1
				"cCodPad!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cCodPad+"@"+; //2
				"cCodPro!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cCodPro+"@"+; //3
				"cDesPro!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cDesPro+"@"+; //4
				"nQtdSol!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cQtdSol+"@"+; //5
				"nQtdAut!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cQtdAut+"@"+; //6
				"cFabric!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cFabric+"@"+; //7
				"nVlrApr!"+AllTrim( TransForm( oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nVlrApr,"@U 999,999,999.99" ) )+"@"+;//8
				"cDente!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cDente+"@"+;//9
				"cFace!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cFace+"@"+;//10
				"nQtdUs!"+AllTrim( TransForm( oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nQtdUs,"@U 999,999,999.99" ) )+"@"+;//11
				"nVlrCon!"+AllTrim( TransForm( oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nVlrCon,"@U 999,999,999.99" ) )+"@"+;//12
				"nVlrTpf!"+AllTrim( TransForm( oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nVlrTpf,"@U 999,999,999.99" ) )+"@"+;//13
				"cStatus!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cAutori+"@"+;//14
				"cSeqMov!"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cSequencia+"@"+;//15
				'dDtExePro!'+DToC(oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:dDtExe)+"@"+;//16
				'cSenhaPro!'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cSenha+"@"+;//17
				'cResAutPro!'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cResAut+"@"+;//18
				'cHorIni!'+AllTrim( TransForm( oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cHorIni,"@R !!:!!" ) )+"@"+;//19
				'cHorFim!'+AllTrim( TransForm( oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cHorFim,"@R !!:!!" ) )+"@"+;//20
				'cViaAc!'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cViaAc+"@"+;//21
				'cTecUt!'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cTecUt+"@"+;//22
				'nRedAcre!'+AllTrim( TransForm( oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nRedAcre,"@U 999.99" ) )+"@"+;//23
				'nVlrTAp!'+AllTrim( TransForm( oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nVlrTAp,"@U 999,999,999.99" ) )+"~"//24
		EndIf


		// Monta matriz para impressao de guia

		AaDd( HttpSession->aResult,{oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cSequencia,;
			oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cCodPad,;
			oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cCodPro,;
			oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cDesPro,;
			oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cDente,;
			oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cFace,;
			oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cQtdAut,;
			{},;
			AllTrim( TransForm( oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:nQtdUs,"@U 999,999,999.99" ) ),;
			DToC(oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:dDtExe),;
			"",;
			oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cSenha,;
			"",;
			oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cAutori} )

	Next

	If HttpSession->cTissVer >=  "3"
		//EXECUTANTES
		cResult += "<"
		For nI:=1 To Len(oObj:OWSRETAUTLIBRESULT:OWSSEXEGUI:OWSMEXEGUI) 		//63
			cResult += "nSeqRef!"+oObj:OWSRETAUTLIBRESULT:OWSSEXEGUI:OWSMEXEGUI[nI]:cSequen+"@"+; //0
				"cGrPar!"+oObj:OWSRETAUTLIBRESULT:OWSSEXEGUI:OWSMEXEGUI[nI]:cGrPar+"@"+;  //1
				"cGraPartExe!"+oObj:OWSRETAUTLIBRESULT:OWSSEXEGUI:OWSMEXEGUI[nI]:cGrPar+"@"+;  //1
				"cCpfExe!"+oObj:OWSRETAUTLIBRESULT:OWSSEXEGUI:OWSMEXEGUI[nI]:cCpfExe+"@"+; //2
				"cNomExe!"+oObj:OWSRETAUTLIBRESULT:OWSSEXEGUI:OWSMEXEGUI[nI]:cNomExe+"@"+; //3
				"cCodSigExe!"+oObj:OWSRETAUTLIBRESULT:OWSSEXEGUI:OWSMEXEGUI[nI]:cConReg+"@"+; //4
				"cNumCrExe!"+oObj:OWSRETAUTLIBRESULT:OWSSEXEGUI:OWSMEXEGUI[nI]:cNumCr+"@"+; //5
				"cEstSigExe!"+oObj:OWSRETAUTLIBRESULT:OWSSEXEGUI:OWSMEXEGUI[nI]:cUfCr+"@"+; //6
				"cCbosExe!"+oObj:OWSRETAUTLIBRESULT:OWSSEXEGUI:OWSMEXEGUI[nI]:cCbo+"@"+"~"//7
		Next
	EndIf

	//Gravo os atributos necessarios para o metodo 'isDupGui'
	cTipGui := HttpGet->cTp
	cCodUsr := oObj:cUserCode
	cCodRda := oObj:cRdaCode
	cGuiRef := HttpSession->cNumeAut
	cMatric := oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cMatric
	cDatGui := DtoS(Date())


	//Honorario Individual

	If HttpSession->cTp == '5'
		oObj:cNumPeg :=  oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cChvBD6
		If oObj:GetBD6()
			HttpSession->aMatBD6 := oObj:oWSGETBD6RESULT:OWSSMATBD6
		EndIf
	EndIf

	//Para guia de prorrogaçã (tipo 11), é necessáio validar a matricula do usurio e gravar as sessions de matricula
	If HttpSession->cTp == '11'
		//Atribui valor da carteirinha na variavel para busca dos dados do usuario
		HttpGet->TrilhaCard := oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cMatric
		HttpGet->cRda 		:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cRda
		HttpGet->cCodLoc 	:= "001"


		cRetDadUsr := W_PPLSDADUSR()

		//Se houver algum problema na validacao do usuario, atribui o retorno para a funcaoo exibir alerta na tela e nao prosseguir com o processamento.
		if "false" $ cRetDadUsr
			cResult := cRetDadUsr
		endif
	EndIf

	// Parametros para retornar se a guia eh duplicada
	oObj:cUserCode			:= cCodUsr
	oObj:cRdaCode			:= cCodRda
	oObj:cTipGui			:= cTipGui
	oObj:cUserCardNumber	:= cMatric
	oObj:cNumGuiRef			:= cGuiRef
	oObj:cDatGuia		 	:= cDatGui

	if HttpSession->cTp == '5' //Se for resumo de internação, joga resumo de internação
		oObj:cTipGui := HttpSession->cTp
	endif

	// Verifica se a guia pode estar sendo duplicada
	if oObj:isDupGui()
		cResult += "<" + SubStr(oObj:cIsDupGuiRESULT,6)
	endif


	// Se nao tem procedimento

	If !lExibe .and. HttpSession->cTp != '11'
		cResult := "false|Nenhum procedimento autorizado para o executante!"
	EndIf
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGUIPR
Chamada da pagina de escolha de Guia ou Protocolo (recurso Glosa)
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLDOCG()
Local cHtml	:= ""

WEB EXTENDED INIT cHtml START "InSite"

//Mostra a pagina para entrar com o protocolo/Guia

HttpSession->cResDoc := ""
If ValType(HttpGet->cChvPes) == 'U'
	HttpGet->cChvPes := "||" // manda vazio a primeira vez
EndIf
cHtml := ExecInPage( "PPLDOCGUIA" )

WEB EXTENDED END

getLOGMon()



Return cHtml

/*/{Protheus.doc} PPLDOCGUI
Chamada da pagina para adicionar Recurso de Glosa
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLDOCGUI()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"


//Tipo de pre-atendimento se vai pre-atender ou atender (executar)

HttpSession->cObsRecG := ""

//Mostra a pagina para entrar com o protocolo/Guia

cHtml := ExecInPage( "PPLADDOCG" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLGETDOCG
Retorna os dados da guia glosada
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGETDOCG()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLRECGLO():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLRECGLO.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cRecno		:= HttpGet->cRecno

// Retorna dados

If oObj:GetDadEveGui()
	cResult := oObj:cGetDadEveGuiRESULT
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGRVDOCG
Grava documento
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGRVDOCG()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLRECGLO():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLRECGLO.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cRecno		:= HttpGet->cRecno
oObj:cArq1		 	:= HttpPost->cDirArq
oObj:cArq2		 	:= HttpPost->cDir2Arq
oObj:cCodRda	 	:= HttpSession->RDAVIEW[1]:CCODE

HttpSession->cResDoc := "Vazio"

// Retorna dados

If oObj:PutDocGuiEvents()
	cResult += oObj:cPutDocGuiEventsRESULT
	HttpSession->cResDoc := cResult
Else
	HttpSession->cResDoc := ""
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} WTDecode
Grava documento
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function WTDecode(cString, lNoAcento, lEspace)
	local cEspVz		:= ""
	default lNoAcento 	:= .t.
	default	lEspace		:= .f.
	cEspVz := iif(lEspace, " ", cEspVz)

	//ATENCAO ESTA FUNCAO TEM A FUNCIONALIDADE DE RETIRAR OS CARACTERES ESPECIAIS
	// DE UMA DETERMINADA STRING.
	if lNoAcento
		cString := StrTran(cString,"á","a");cString := StrTran(cString,"à","a");cString := StrTran(cString,"â","a");cString := StrTran(cString,"ã","a")
		cString := StrTran(cString,"ä","a");cString := StrTran(cString,"Á","A");cString := StrTran(cString,"À","A");cString := StrTran(cString,"Ã","A")
		cString := StrTran(cString,"Â","A");cString := StrTran(cString,"Ä","A");cString := StrTran(cString,"é","e");cString := StrTran(cString,"è","e")
		cString := StrTran(cString,"ê","e");cString := StrTran(cString,"ë","e");cString := StrTran(cString,"É","E");cString := StrTran(cString,"È","E")
		cString := StrTran(cString,"Ê","E");cString := StrTran(cString,"Ë","E");cString := StrTran(cString,"í","i");cString := StrTran(cString,"ì","i")
		cString := StrTran(cString,"ï","i");cString := StrTran(cString,"Í","I");cString := StrTran(cString,"Ì","I");cString := StrTran(cString,"Î","I")
		cString := StrTran(cString,"Ï","I");cString := StrTran(cString,"ó","o");cString := StrTran(cString,"ò","o");cString := StrTran(cString,"õ","o")
		cString := StrTran(cString,"ô","o");cString := StrTran(cString,"ö","o");cString := StrTran(cString,"Ó","O");cString := StrTran(cString,"Ò","O")
		cString := StrTran(cString,"Õ","O");cString := StrTran(cString,"Ô","O");cString := StrTran(cString,"Ö","O");cString := StrTran(cString,"ú","u")
		cString := StrTran(cString,"ù","u");cString := StrTran(cString,"ü","u");cString := StrTran(cString,"û","u");cString := StrTran(cString,"Û","U")
		cString := StrTran(cString,"Ú","U");cString := StrTran(cString,"Ù","U");cString := StrTran(cString,"Ü","U");cString := StrTran(cString,"ç","c")
		cString := StrTran(cString,"Ç","C")
	endif
	cString := StrTran(cString,"µ", cEspVz); cString := StrTran(cString,"¿", cEspVz); cString := StrTran(cString,"´", cEspVz); cString := StrTran(cString,"º", cEspVz)
	cString := StrTran(cString,"%", cEspVz); cString := StrTran(cString,"@", cEspVz); cString := StrTran(cString,"#", cEspVz); cString := StrTran(cString,"$", cEspVz)
	cString := StrTran(cString,"&", cEspVz); cString := StrTran(cString,"=", cEspVz); cString := StrTran(cString,"™", cEspVz)
	cString := StrTran(cString,"`", cEspVz); cString := StrTran(cString,"~", cEspVz); cString := StrTran(cString,"?", cEspVz); cString := StrTran(cString,"/", cEspVz)
	cString := StrTran(cString,"\", cEspVz); cString := StrTran(cString,"þ", cEspVz); cString := StrTran(cString,"Þ", cEspVz); cString := StrTran(cString,"¾", cEspVz)
	cString := StrTran(cString,"{", cEspVz); cString := StrTran(cString,"|", cEspVz); cString := StrTran(cString,"}", cEspVz); cString := StrTran(cString,"¡", cEspVz)
	cString := StrTran(cString,"¢", cEspVz); cString := StrTran(cString,"£", cEspVz); cString := StrTran(cString,"¤", cEspVz); cString := StrTran(cString,"¥", cEspVz)
	cString := StrTran(cString,"¦", cEspVz); cString := StrTran(cString,"¨", cEspVz); cString := StrTran(cString,"©", cEspVz); cString := StrTran(cString,"ª", cEspVz)
	cString := StrTran(cString,"«", cEspVz); cString := StrTran(cString,"¬", cEspVz); cString := StrTran(cString,"­",  cEspVz); cString := StrTran(cString,"®", cEspVz)
	cString := StrTran(cString,"¯", cEspVz); cString := StrTran(cString,"°", cEspVz); cString := StrTran(cString,"±", cEspVz); cString := StrTran(cString,"²", cEspVz)
	cString := StrTran(cString,"³", cEspVz); cString := StrTran(cString,"´", cEspVz); cString := StrTran(cString,"µ", cEspVz); cString := StrTran(cString,"¶", cEspVz)
	cString := StrTran(cString,"·", cEspVz); cString := StrTran(cString,"¸", cEspVz); cString := StrTran(cString,"¹", cEspVz); cString := StrTran(cString,"º", cEspVz)
	cString := StrTran(cString,"»", cEspVz); cString := StrTran(cString,"¼", cEspVz); cString := StrTran(cString,"½", cEspVz); cString := StrTran(cString,"¾", cEspVz)
	cString := StrTran(cString,"¿", cEspVz); cString := StrTran(cString,"×", cEspVz); cString := StrTran(cString,"Ø", cEspVz); cString := StrTran(cString,"ß", cEspVz)
	cString := StrTran(cString,"æ", cEspVz); cString := StrTran(cString,"÷", cEspVz); cString := StrTran(cString,"ø", cEspVz); cString := StrTran(cString,"<", cEspVz)
	cString := StrTran(cString,"þ", cEspVz); cString := StrTran(cString,"œ", cEspVz); cString := StrTran(cString,"”", cEspVz); cString := StrTran(cString,"°", cEspVz)
	cString := StrTran(cString,"•", cEspVz); cString := StrTran(cString,"!", cEspVz); cString := StrTran(cString,"¨", cEspVz); cString := StrTran(cString,"-", cEspVz)
	//os caracteres abaixo não são convertidos pelo FwNoAccent
	cString := StrTran(cString,"ž","z"); cString := StrTran(cString,"ƒ","f"); cString := StrTran(cString,"Ÿ","Y")
	cString := StrTran(cString,"Š","S"); cString := StrTran(cString,"š","s"); cString := StrTran(cString,"Ž","Z")
	cString := StrTran(cString,"ý","y"); cString := StrTran(cString,"Ÿ","Y"); cString := StrTran(cString,"ÿ","y")

	cString := StrTran(cString,"", cEspVz); cString := StrTran(cString,"", cEspVz)
	cString := StrTran(cString,"Chr(167)", cEspVz); cString := StrTran(cString,"Chr(166)", cEspVz)

Return(cString)

/*/{Protheus.doc} PPLPRTCAR
Exibe procedimentos e suas carencias no portal
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLPRTCAR()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= "true|"
LOCAL nResult	:= 0
LOCAL nI		:= 0
local xHeader   := ""
Local xCols     := ""
LOCAL cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

// oBJ
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros
oObj:cUserCode	:= "MSALPHA"

// Retorna dados
If oObj:ExCarPortal()

	nResult := Len(oObj:OWSEXCARPORTALRESULT:OWSSCARPOR)

	// Cabecalho
	xHeader += "[{name:'Codigo'},"
	xHeader += "{name:'Descrição'},"
	xHeader += "{name:'Carência Proc.'}]"

	xCols := "["
	For nI := 1 to nResult

		xCols += "{"
		xCols +=  "0:{field:'CodPro', value:'" + oObj:OWSEXCARPORTALRESULT:OWSSCARPOR[nI]:cCodPro +   "'},"
		xCols +=  "1:{field:'DescPro',value:'" + SubStr(oObj:OWSEXCARPORTALRESULT:OWSSCARPOR[nI]:cDescPro,1,80) +"'},"
		xCols +=  "2:{field:'REC', value:'0#"  + oObj:OWSEXCARPORTALRESULT:OWSSCARPOR[nI]:cRec + "'}"  +Iif( nResult != nI ,"},","}]" )
	Next nI

	cResult += xHeader + "|" + xCols +"|"
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCARPOR

@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCARPOR()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

//Mostra a pagina de procedimentos


cHtml += ExecInPage( "PPLEXCARPORT" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCARENC
Retorna as carencias do beneficiario para o portal
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCARENC()
LOCAL cResult  	:= "true|"
LOCAL cMatric := HttpGet->cMatric
LOCAL cRecno  := HttpGet->cRecno
LOCAL nResult
LOCAL nI
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:CcMatrc	:= cMatric
oObj:CcRecno	:= cRecno

If oObj:CarenBnf()

	nResult := Len(oObj:OWSCARENBNFRESULT:OWSSRETCAREN)


	// Cabecalho

	xCols := "["
	For nI := 1 to nResult

		xCols += "{"
		xCols +=  "0:{field:'cInfo', value:'" + oObj:OWSCARENBNFRESULT:OWSSRETCAREN[nI]:CcInfo +   "'},"
		xCols +=  "1:{field:'cMsg',value:'" + SubStr(oObj:OWSCARENBNFRESULT:OWSSRETCAREN[nI]:CcMsg,1,80) +"'}" + Iif( nResult != nI ,"},","}]" )

	Next nI

	cResult += xCols + "|"
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGRPFAM
etorna os dados do grupo familiar
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGRPFAM()
LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

If HttpSession->MPortal == "000010"

	oObj:cUserCode	:= "MSALPHA"
	oObj:cCUSRLOGIN	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE

EndIf

// Retorna dados

If oObj:DadGrpFam()

	nResult := Len(oObj:OWSDadGrpFamRESULT:OWSSDADGRP)

	xCols := "["
	For nI := 1 to nResult

		xCols += "{"
		xCols +=  "0:{field:'cMatric', value:'" + oObj:OWSDadGrpFamRESULT:OWSSDADGRP[nI]:cMatricl +   "'},"
		xCols +=  "1:{field:'cNomBnf',value:'" +  SubStr(oObj:OWSDadGrpFamRESULT:OWSSDADGRP[nI]:cNomeBnf,1,50) +"'}" + Iif( nResult != nI ,"},","}]" )
	Next

	cResult += xCols +"|"

Else
	cResult := "false|Não foram encontrados Beneficiários."
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLNOTIC
Retorna os dados da noticia no portal
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLNOTIC()
LOCAL  oObj 		:= NIL
LOCAL  cResult  	:= "true|"
LOCAL  nQtdPrtd	:= 0
LOCAL  nI			:= 0
LOCAL  cCodPrt		:= ""
LOCAL  cRe       := ""
LOCAL  nQtdEspec	:= 0
LOCAL  nQtdNot		:= 0
LOCAL cHtml := ""
STATIC lVerTds		:= .F.

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros



// Chamada da rotina pelo portal do prestador

If HttpSession->MPortal == "000008"

	nQtdPrtd := Len(HttpSession->RDAVIEW)

	For nI := 1 To nQtdPrtd

		if nI <nQtdPrtd
			cCodPrt+= HttpSession->RDAVIEW[nI]:CCODE+ ","
		Else
			cCodPrt+= HttpSession->RDAVIEW[nI]:CCODE
		EndIf
	Next

	oObj:cUserCode	:= "MSALPHA"
	oObj:CcCodRDA		:= cCodPrt

	If EMPTY(HttpGet->cOpcao)
		oObj:CcOpcao := "1"
		oObj:CcCodEsp := HttpGet->cCdEspec
	Else
		oObj:CcOpcao  := HttpGet->cOpcao
		oObj:CcCodNotic := HttpGet->cCdNot
	EndIf


	// Chamada da rotina pelo portal do beneficiario

ElseIf HttpSession->MPortal == "000010"

	oObj:cUserCode	:= "MSALPHA"

	If EMPTY(HttpGet->cOpcao)
		oObj:CcOpcao := "1"
		oObj:CcUserCod := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
	Else
		oObj:CcOpcao    := HttpGet->cOpcao
		oObj:CcCodNotic := HttpGet->cCdNot
	EndIf
EndIf


// Retorna dados para a pagina


If oObj:RetNot()


	// Retorna os títulos das notícias

	If oObj:CcOpcao == "1"

		nQtdEspec := LEN(oObj:OWSRETNOTRESULT:OWSSNOTICIA)

		For nI := 1 To nQtdEspec

			cRe += "<li class='newsItem'><a class='newsLink' href='W_PPLNOTIC.APW?cOpcao=2&cCdNot=" + oObj:OWSRETNOTRESULT:OWSSNOTICIA[nI]:CCCODNOT + "' target='principal' "
			cRe += "title='Título da notícia disponível'>" + oObj:OWSRETNOTRESULT:OWSSNOTICIA[nI]:CTITULONOT
			cRe += "</a></li>"

			If !lVerTds .AND. nI == 10

				cRe += "<li class='newsItem'><a href='#' onclick='carregaNoticia()' title='Visualizar todas as notícias disponíveis' class='newsLink'>"
				cRe += "<i>Todas as notícias</i><a/></li>"
				lVerTds := .T.

				EXIT
			EndIf
		Next

		If lVerTds .AND. nI > 10

			cRe += "<li class='newsItem'><a href='#' onclick='carregaNoticia()' title='Visualizar somente as últimas notícias' class='newsLink'>"
			cRe += "<i>Visualizar somente as últimas dez notícias</i><a/></li>"
			lVerTds := .F.
		EndIf

		If nQtdEspec == 0
			cRe += "<li class='newsItem'><a href='#' class='newsLink' style='text-align:start;'><i>Não existem notícias disponíveis no momento.<i></a></li>"
		EndIf

		cResult += cRe


		// Retorna o conteúdo da notícia

	ElseIf oObj:CcOpcao == "2"

		nQtdNot := LEN(oObj:OWSRETNOTRESULT:OWSSNOTICIA)

		cRe := "<html>"
		cRe +=   	"<head>"

		cRe += "<title>Untitled Document</title>"
		cRe += "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
		cRe += "<meta http-equiv='X-UA-Compatible' content='IE=Edge' >"
		cRe += "<meta name='viewport' content='width=device-width, initial-scale=1' >"
		cRe += "<meta name='description' content='' >"
		cRe += "<meta name='author' content='' >"
		cRe += "<link href='" + GetPrtSkin() +"/estilo.css' rel='stylesheet' type='text/css'>"
		cRe += "<script type='text/javascript' src='pplanguage.js'></script>"
		cRe += "<script type='text/javascript' src='criaobj.js'></script>"
		cRe += "<script type='text/javascript' src='" + GetPrtSkin() +"/jspls.js'></script>"
		cRe += "<link href='" + GetPrtSkin() +"/componentes/bootstrap/dist/css/bootstrap.css' rel='stylesheet'>"
		cRe += "<link href='" + GetPrtSkin() +"/componentes/metisMenu/css/metisMenu.css' rel='stylesheet'>"
		cRe += "<link href='" + GetPrtSkin() +"/componentes/datatables-plugins/css/dataTables.bootstrap.css' rel='stylesheet'>"
		cRe += "<link href='" + GetPrtSkin() +"/componentes/datatables-responsive/css/dataTables.responsive.css' rel='stylesheet'>"
		cRe += "<link href='" + GetPrtSkin() +"/componentes/layout-responsivo/css/layout-responsivo.css' rel='stylesheet'>"
		cRe += "<link href='" + GetPrtSkin() +"/componentes/font-awesome/css/font-awesome.css' rel='stylesheet' type='text/css'>"
		cRe +=   	"</head>"

		cRe += "<body>"

		cRe += "<div id='ModalPage'>"
		cRe += "<div class='ModalBackground'></div>"
		cRe += "<div id='ModalContainer' class='ModalContainer'></div>"
		cRe += "</div>"

		For nI := 1 To nQtdNot
			cRe += "<div class='col-lg-12'>"
			cRe += "<h3>" + CAPITAL(oObj:OWSRETNOTRESULT:OWSSNOTICIA[nI]:CTITULONOT) + "</h3>"
			cRe += "</div>"


			cRe += "<div id='newContainer'>"
			cRe += oObj:OWSRETNOTRESULT:OWSSNOTICIA[nI]:CTEXTONOT

			If !EMPTY(oObj:OWSRETNOTRESULT:OWSSNOTICIA[nI]:OWSARQNOT:OWSSARQNOT)
				cRe += "<br><p style='font-size:14px;'>Anexo referente a notícia disponível para download: "
				cRe += 		"<a href='W_PPLCHANOT.APW?cCodNot="+ oObj:OWSRETNOTRESULT:OWSSNOTICIA[nI]:CCCODNOT +"' title='Baixar anexos disponíveis referente a notícia.'>"
				cRe += "<i>Clique aqui</i><a/></p>"
			EndIf
			cRe += "</div>"
		Next
		CrE += "</body>
		cRe += "</html>"

		cResult :=  cRe

	EndIf
Else
	cResult := "false|Não foi possível carregar a notícia"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLNOT

@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLNOT()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PPLEXNOT.APW?cCdEspec="+HttpGet->cCdEspec )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCHANOT
Chamada do menu de arquivo de noticias do portal
@author PLSTEAM
@since 10.2007
@version P12
/*/
WEB FUNCTION PPLCHANOT()
LOCAL cHtml  	:= ""
LOCAL cDir	 	:= getPastPp(.T.)
LOCAL aFiles	:= {}

WEB EXTENDED INIT cHtml START "InSite"

If !Empty(cDir)

	cDir := cDir + getPrtSkin() + "\arquivonoticia\"+ HttpGet->cCodNot + "\"

	//Le diretorio para mostrar os arquivos disponiveis

	aFiles := DIRECTORY(cDir+"*.*")

	If Len(aFiles) > 0
		HttpPost->aFiles := aClone(aFiles)
		HttpPost->cDir := HttpGet->cCodNot
	Else
		Return PPLSALERT( "", "Atenção", "Nenhum arquivo encontrado para esta notícia.", "" )
	EndIf
Else
	Return PPLSALERT( "", "Atenção", "Nao foi possível localizar os arquivos desta notícia.", "" )
EndIf

cHtml += ExecInPage("PPLSNOTICIA.APH")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLVIRECG
Chamada da pagina para retornar um valor da TISS
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLRETVLRTISS()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )


// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:oWSTERMOTISS:cCodAlias	:= HttpGet->cAlias
oObj:oWSTERMOTISS:cVlrProt	:= HttpGet->cVlrProt
oObj:oWSTERMOTISS:cCampo		:= HttpGet->cCampo
oObj:oWSTERMOTISS:cVerTiss	:= HttpSession->cTISSVer


// Retorna dados

If oObj:GetVlrTiss()
	cResult += oObj:cGETVLRTISSRESULT

EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLVIRECG
Chamada para montar guia de acordo com a TISS
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLFORMTISS()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cStrCBOX	:= ""
LOCAL cTISSVer	:= ""
LOCAL nI,nY, nPos
Local cAnexCli	:= IIF( ValType(Httpget->cAnexCli) == "U", "", Httpget->cAnexCli )
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

// oBJ
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros
oObj:cUserCode	:= "MSALPHA"
oObj:oWSGUIATISS:cTipGui		:= HttpGet->cTipGui

//Recupera a versão da TISS da RDA
aRDA := ClassDataArr(HttpSession->RDAVIEW[1])
If aScan(aRDA,{|x| AllTrim(x[1]) == "CTISSVER"  }) > 0
	cTISSVer := HttpSession->RDAVIEW[1]:cTissVer
EndIf
If cTISSVer >= '3'
	oObj:oWSGUIATISS:cVerTiss := cTISSVer
Else
	cTISSVer :=  HttpGet->cVerTiss
	oObj:oWSGUIATISS:cVerTiss := cTISSVer
Endif

// Aqui eu pego o que vem de Session executo aqui pra enviar a informaçao
// pro WS pois o mesmo nao acessa o conteudo da Session	dificultando o dinamismo

If oObj:GetCmbFormT()
	// ATRIBUO OS PARAMETROS NOVAMENTE PARA UTILIZAÇÃO DO PROXIMO METODO
	oObj:cUserCode	:= "MSALPHA"
	oObj:oWSGUIATISS:cTipGui		:= HttpGet->cTipGui
	oObj:oWSGUIATISS:cVerTiss	:= cTISSVer
	//oObj:oWSGUIATISS:OWSCMBGUIA	:= {}
	oObj:oWSGUIATISS:cDadCombo	:= ""
	If Len(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA) > 0 //oObj:OWSGETCMBFORMTRESULT:oWSRETCMBSGUIA
		For nI:=1 To Len(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA)
			cStrCBOX := ""
			If "HTTPSESSION" $ Upper(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX)	 // Se for uma Session eu pego CCODE e CNAME e monto o Combo
				If ValType(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX)) <> 'U'
					For nY := 1 To Len(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX))
						cStrCBOX += Alltrim(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX + "[" + Alltrim(Str(nY)) + "]:cCODE")) + "=" + Alltrim(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX + "[" + Alltrim(Str(nY)) + "]:cNAME")) + ";"
					Next nY

					If nY > 2
						cStrCBOX += ";="//cStrCBOX += ";=-- Selecione um item --"
					EndIf
				EndIf
			Else // Caso contrario eu pego a STRING com mesma estrutura do X3_COBX
				cStrCBOX := Alltrim(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX)
			EndIf
			If SubStr(cStrCBOX, Len(cStrCBOX),1) == ";"
				cStrCBOX := SubStr(cStrCBOX, 1, Len(cStrCBOX)-1)
			EndIf
			oObj:oWSGUIATISS:cDadCombo	+= Alltrim(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCampoG) + ";" + cStrCBOX + "|"
			//WSDATA RetCmbsGuia	AS Array Of SRetCmbsGuia OPTIONAL
		Next
	EndIf
EndIf
If SubStr(oObj:oWSGUIATISS:cDadCombo, Len(oObj:oWSGUIATISS:cDadCombo),1) == "|"
	oObj:oWSGUIATISS:cDadCombo := SubStr(oObj:oWSGUIATISS:cDadCombo, 1, Len(oObj:oWSGUIATISS:cDadCombo)-1)
EndIf

// Retorna dados

oObj:cDtJs := iif(valtype(HttpSession->cDtJs) <> 'U', HttpSession->cDtJs, "")
If oObj:GetFormTiss()
	cResult :=  oObj:OWSGETFORMTISSRESULT:cPagina

	If ValType(oObj:OWSGETFORMTISSRESULT:cGrids) == "C"
		HttpSession->cGrids := oObj:OWSGETFORMTISSRESULT:cGrids
	EndIf

	If ValType(oObj:OWSGETFORMTISSRESULT:OWSCMPGUIA:oWSSCmpGuia) == "A" /*/:OWSCMPGUIA:OWSSCMPGUIA)*/
		HttpSession->aCmpGuia := aClone(oObj:OWSGETFORMTISSRESULT:OWSCMPGUIA:oWSSCmpGuia)
	EndIf

	//Executa os inicializadores dos campos
	nIni := At("<%=",cResult)
	While  nIni > 0
		nFim := At("%>",cResult)
		cComando := SubStr(cResult,nIni+3,nFim - nIni-3)
		xResult := &(cComando)

		cTipResult := ValType(xResult)
		Do Case
			Case cTipResult == "D"
				xResult := DtoS(xResult)
				xResult := SubStr(xResult,7,2) + "/" + SubStr(xResult,5,2) + "/" + SubStr(xResult,1,4)
			Case cTipResult == "N"
				xResult := Alltrim(Str(xResult))
		EndCase

		cResult := StrTran ( cResult, "<%=" + cComando + "%>", xResult)
		nIni := At("<%=",cResult)
	EndDo
EndIf

IF cAnexCli <> "" //Guias de anexos são carregadas com window.location, precisamos tirar o "true|" antes de mandar pra página
	cResult := SubStr(cResult, At("|", cResult) + 1)
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} EXCLRESU
Chamada da Rotina de Exclusao de Itens do Resumo.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function EXCLRESU(aCols, cParPosExcl)

	LOCAL oObj 		:= NIL
	LOCAL cHtml := ""

	WEB EXTENDED INIT cHtml START "InSite"


	oObj := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLSXFUN.APW" )

	oObj:cUserCode	:= "MSALPHA"

	oObj:cChave	:= cParPosExcl

	oObj:ExclResu()

	WEB EXTENDED END

	getLOGMon()

return

/*/{Protheus.doc} EXCLRECT
Chamada da Rotina de Exclusao de Itens da Receitas.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function EXCLRECT(aCols, cParPosExcl)

	LOCAL oObj 		:= NIL
	LOCAL cHtml := ""

	WEB EXTENDED INIT cHtml START "InSite"


	oObj := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLSXFUN.APW" )

	oObj:cUserCode	:= "MSALPHA"

	oObj:cProtoc	:= cParPosExcl
	oObj:cMedicamento	:= aCols[1]
	oObj:ExclRect()

	WEB EXTENDED END

	getLOGMon()

return

/*/{Protheus.doc} PPLGETGRID
Responsável pela manipulação dos grids das Guias no Portal
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGETGRID()
LOCAL nI			:= 0
LOCAL nJ			:= 0
LOCAL nL			:= 0
LOCAL nLen			:= 0
LOCAL nLenVal		:= 0
LOCAL nPos			:= 0
LOCAL nPosVal		:= 0
LOCAL nOpc 			:= 0
LOCAL nPosCols		:= 0
LOCAL nRecno		:= 0
LOCAL nLenCols		:= 0
LOCAL nQtdReg		:= 1
LOCAL nQtdPag 		:= 1
LOCAL nRegPagina 	:= 1

LOCAL cResult  		:= ""
LOCAL cGrid			:= ""
LOCAL xHeader 		:= "[{}]"
LOCAL xCols			:= ""

LOCAL cPesquisa		:= ""
LOCAL cMsg			:= ""

LOCAL aValores		:= {}
LOCAL aHeader		:= {}
LOCAL aCols			:= {}
LOCAL aLinha		:= {}

//Variaveis de tratamento do relacionamento que preenche a combo genericamente
LOCAL aRelac 		:= {}
LOCAL cCpoRelac		:= ""
LOCAL cVlrRelac		:= ""

LOCAL cLinhas		:= ""
LOCAL lAtuVisibl	:= ""
LOCAL lDelVisibl	:= ""
LOCAL nNumAux		:= -1
LOCAL lFromGrid   	:= "false"
LOCAL cFunPosExcl 	:= ""
local cParPosExcl 	:= ""
local cSeqDelExec	:= "000"
LOCAL cHtml 		:= ""

WEB EXTENDED INIT cHtml //Aqui não tem o insite pq é utilizada no layout generico onde não tem login


// HttpSession->aCmpGuia -> Guarda todos os campos/grids da Guia
// HttpSession->aCmpGuia[nPos] -> Trata-se da referência a um campo ou grid
//
// HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING -> aHeader do Grid
// HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING -> aCols do Grid
//
// xCols e xHeader são as strings que o JSPLS usará para montar o grid
// aCols e aHeader são os arrays que serão utilizados para manipular os campos
//por esta função

If '*@*' $ HttpGet->cValores
	HttpGet->cValores := strTran(HttpGet->cValores, '*@*', '§') //para tratar campos do tipo email que contém @
EndIf

aValores := Separa ( HttpGet->cValores, "@" , .F.)

//Recupera dados da página

cGrid 	:= HttpGet->cGrid
nRecno 	:= IIF(HttpGet->nRecno == "", "0", HttpGet->nRecno)
nRecno 	:= IIF(Valtype("nRecno") <> "C", "", nRecno)
nOpc 	:= Val(HttpGet->nOpc)
lBotao 	:= HttpGet->lBotao
cSt 	:= HttpGet->cSt
cValores:= HttpGet->cValores

If ValType(HttpGet->cFunPosExcl) <> "U"
	cFunPosExcl := HttpGet->cFunPosExcl
Else
	cFunPosExcl := ""
EndIf

If ValType(HttpGet->cParPosExcl) <> "U"
	cParPosExcl := HttpGet->cParPosExcl
Else
	cParPosExcl := ""
EndIf

If ValType(HttpGet->lBtnAtuVisible) <> "U"
	lAtuVisibl := HttpGet->lBtnAtuVisible
Else
	lAtuVisibl := "true"
EndIf

If ValType(HttpGet->lBtnDelVisible) <> "U"
	lDelVisibl := HttpGet->lBtnDelVisible
Else
	lDelVisibl := "true"
EndIf

If ValType(HttpGet->lPacote) <> "U"
	lPacote := HttpGet->lPacote
Else
	lPacote := "false"
EndIf

If ValType(HttpGet->lFromGrid) <> "U"
	lFromGrid := HttpGet->lFromGrid
Else
	lFromGrid := "false"
EndIf

If ValType(HttpGet->cRelac) <> "U" .AND. !Empty(HttpGet->cRelac)
	aRelac 		:= StrToArray(HttpGet->cRelac, "~")
	cCpoRelac	:= aRelac[2]
	cVlrRelac	:= ""
	aRelac 		:= StrToArray(aRelac[3], "|")
Else
	if lDelVisibl <> "false"
		lDelVisibl := "true"
	EndIf
EndIf


If ValType(HttpGet->cSeqDelExec) <> "U"
	cSeqDelExec := HttpGet->cSeqDelExec
Else
	cSeqDelExec := "000"
EndIf


//Encontra o objeto no array de campos
nPos := aScan( HttpSession->aCmpGuia, { |x| x:cNome == cGrid} )

//Monta o aCols e aHeader

If nPos > 0

	aHeader	:= HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING
	aCols	:= HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING

	//Verifica se o aCols e aHeader estão vazios

	If ValType(aHeader) <> 'A'
		aHeader := {}
		HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING := {}
	EndIf

	If ValType(aCols) <> 'A'
		aCols := {}
		HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING := {}
	EndIf


	//Adiciona no aCols ou Posiciona na linha da alteração
	If nOpc == 3

		aAdd(aCols,{})
		aAdd(aHeader,{})
		nPosCols := Len(aCols)

	ElseIf nOpc == 4 .or. nOpc == 5

		nPosCols := Val(nRecno)

	ElseIf nOpc == 6
		xCols 	:= ""
		xHeader := "[{}]"
		nQtdReg := 0
		aCols 	:= {}
		aHeader := {}
	EndIf

	If nPosCols > 0

		If nOpc == 5

			//Exclui registro
			If Len(aCols) > 0

				if cFunPosExcl <> ""
					&cFunPosExcl.(aCols[nPosCols], cParPosExcl) //Chama função após a exclusão da gride.
				endif

				if len(aCols) >= nPosCols

					aDel(aCols,nPosCols)
					aSize(aCols,len(aCols)-1)

					aDel(aHeader,nPosCols)
					aSize(aHeader,len(aHeader)-1)

				endIf

			EndIf

		Else

			//Inicia o xHeader e o xCols

			xHeader := "["

			If 	Empty(HttpSession->aCmpGuia[nPos]:CXCOLS)
				xCols := "["
			Else
				xCols := HttpSession->aCmpGuia[nPos]:CXCOLS
				xCols := Left(xCols,Len(xCols)-1) + ","
			EndIf

			//Monta xHeader e xCols
			nLen 	:= len(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID)
			nLenVal := len(aValores)

			For nI := 1 to nLenVal

				If "§" $ aValores[nI]
					aValores[nI] := strTran(aValores[nI], '§', '@')
				EndIf

				aLinha 	:= Separa(aValores[nI],";",.F.)
				nNumAux := -1

				If Len(aCols) < nPosCols+nI-1
					aAdd(aCols,{})
					aAdd(aHeader,{})
				EndIf

				For nJ := 1 to nLen

					If nJ == 1

						//Adiciona os botões da linha e coloca o Recno

						If (lAtuVisibl == "true") .or. (lDelVisibl == "true")
							xCols += "{"
						endIf

						If (lAtuVisibl == "true")

							If nI == 1
								xHeader += "{name:'Alterar'},"
							endIf

							nNumAux++
							xCols += cValToChar(nNumAux) + ":{field:'RECNO', value:'0#" + AllTrim(Str(nPosCols+nI-1)) + "," + cGrid + ".id,4'},"

						endIf

						If (lDelVisibl == "true")

							If nI == 1
								xHeader += "{name:'Excluir'},"
							endIf

							nNumAux++

							if cFunPosExcl <> ""
								xCols += cValToChar(nNumAux) + ":{field:'RECNO', value:'1#" + allTrim( str( nPosCols + nI - 1 ) ) + "," + cGrid + ".id,5,true," + '""' + " ," + '""' + " ,cCampoDefault," + lAtuVisibl + "," + lDelVisibl + "," + lFromGrid + ", cFunPosExcl, cParPosExcl'}," //Botão Excluir
							else
								xCols += cValToChar(nNumAux) + ":{field:'RECNO', value:'1#" + allTrim( str( nPosCols + nI - 1 ) ) + "," + cGrid + ".id,5,true," + '""' + " ," + '""' + " ,cCampoDefault," + lAtuVisibl + "," + lDelVisibl + "," + lFromGrid + "'}," //Botão Excluir
							endIf

						endIf

					endIf

					cCampo  := alltrim(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID[nJ]:CNOME)
					cTitulo := alltrim(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID[nJ]:CDESCRI)

					// Verifica se o campo já tem algum valor

					nPosVal := aScan(aLinha , { |x| cCampo $ x } )

					If cCampo == "cProExe" .and. nPosVal > 0

						If Separa(aLinha[nPosVal],"$",.T.)[1] == "cProExeDesc"
							nPosVal := 9
						Endif

					EndIF

					If nPosVal > 0
						cValor	:= Separa(aLinha[nPosVal],"$",.T.)[2]
					Else
						cValor 	:= ""
					EndIf

					// Cabecalho
					If nI == 1 .and. cTitulo <> 'CMPSEQ' // Validação para remover do cabeçalho pois estava desposicionando os itens da grid.
						xHeader += "{name:'" + cTitulo + "'}" + Iif( nLen != nJ ,",","]" )
					EndIf

					If nOpc == 3  // Inclui registro

						aAdd(aCols[nPosCols+nI-1],cValor)
						aAdd(aHeader[nPosCols+nI-1],cCampo)

						nNumAux++

						If (lAtuVisibl == "false") .AND. (lDelVisibl == "false")
							xCols += "{"
						EndIf
						xCols += cValToChar(nNumAux) + ":{field:'"+cCampo+"', value:'" + /*cBtnPos +*/ cValor + "'} "

						If nLen != nJ
							xCols += ","
						Else
							xCols += "}"
							If nI != nLenVal
								xCols += ","
							Else
								xCols += "]"
							EndIf
						EndIf

					ElseIf nOpc == 4//Altera Registro

						aCols[nPosCols][nJ] := cValor

					EndIf

				Next nJ

				If nLen > 0

					If nOpc == 3
						aAdd(aCols[nPosCols+nI-1],cSt)
						aAdd(aHeader[nPosCols+nI-1],"Marca")
					ElseIf nOpc == 4
						aCols[nPosCols][len(aCols[nPosCols])] := cSt
					EndIf

				EndIf

			Next nI

		EndIf

	EndIf

	//Se for alteração, reconstroi o xCols

	If nOpc == 4 .or. nOpc == 5

		nLenCols := Len(aCols)

		If nLenCols > 0

			xCols := "[{

			For nI := 1 to nLenCols

				nNumAux = -1

				If (lAtuVisibl == "true")
					nNumAux++
					xCols += cValToChar(nNumAux) + ":{field:'RECNO', value:'0#" + AllTrim(Str(nI)) + "," + cGrid + ".id,2'}," //Botão Alterar
				EndIf

				If (lDelVisibl == "true")
					nNumAux++
					xCols += cValToChar(nNumAux) + ":{field:'RECNO', value:'1#" + AllTrim(Str(nI)) + "," + cGrid + ".id,5,true," + '""' + " ," + '""' + " ,cCampoDefault," + lAtuVisibl + "," + lDelVisibl + "," + lFromGrid + "'}," //Botão Excluir
				EndIf

				nLenHeader := len(aHeader[nI])-1

				for nJ := 1 to nLenHeader

					if nJ > len(aCols[nI])
						exit
					endIf

					nNumAux++

					xCols += cValToChar(nNumAux) + ":{field:'" + aHeader[nI][nJ]+ "', value:'" + aCols[nI][nJ] + "'} " + Iif( nLenHeader != nJ ,",","}" )

				Next nJ

				xCols += Iif( nLenCols != nI ,",{","]" )

			Next nI

			nQtdReg		:= 1
			nQtdPag 	:= 1
			nRegPagina 	:= 1

		Else
			xCols 	:= ""
			xHeader := "[{}]"
			nQtdReg	:= 0
		EndIf

	EndIf

	//Indica que a linha deve ser marcada
	nLenCols := len(aCols)
	nLen 	 := len(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID)

	For nI := 1 to nLenCols

		If aCols[nI][nLen+1] <> "1"
			cLinhas += AllTrim(str(nI))+"&"
		EndIf

	Next nI

	//Adiciona o xHeader e xCols ao array da session
	//Verifica se não houve problemas na montagem e caso haja, fecha o xHeader
	If RAT(xHeader,",") == 0
		xHeader := Left(xHeader,Len(xHeader)-1)+"]"
	EndIf

	HttpSession->aCmpGuia[nPos]:CXHEADER 			:= xHeader
	HttpSession->aCmpGuia[nPos]:CXCOLS   			:= xCols
	HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING 	:= aClone(aHeader)
	HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING 	:= aClone(aCols)

	If ! Empty(cCpoRelac)

		cVlrRelac := "["

		For nI := 1 To Len(aCols)

			For nL := 1 To Len(aRelac)

				nPosVal := aScan(aHeader[1] , { |x| aRelac[nL] == x } )

				If nPosVal <> 0
					cVlrRelac += IIf(nL == 1, "[", "")
					cVlrRelac += IIf(nL <> Len(aRelac), "'" + aCols[nI,nPosVal] + "'" + "," ,"'" + aCols[nI,nPosVal] + "'" + "]")
				EndIf

			Next nL

			If nI <> Len(aCols)
				cVlrRelac += ","
			EndIf

		Next nI

		cVlrRelac += "]"

	EndIf

	cResult := 	 "true|" +;
		cValToChar(nI-1) + "|" + ;
		cValToChar(nQtdPag) + "|" + ;
		cValToChar(nRegPagina) + "|" + ;
		xHeader + "|" +	;
		xCols + "|" + ;
		cMsg + "|" + ;
		"true"/* iIf(lContinua,'true','false')*/ + "|" + ;
		"1"/*cValToChar(nPaginaAtu)*/ + "|" + ;
		cPesquisa + "|" + ;
		"true"/* iIf(lCSemafo,'true','false') */ + "|" + ;
		cGrid + "|" + ;
		AllTrim(Str(nOpc)) + "|" +;
		"" + "|" +;
		lBotao + "|" +;
		cSt + "|" +;
		cLinhas + "|"+;
		lAtuVisibl + "|"+;
		lDelVisibl + "|"+;
		lPacote    + "|"+;
		cCpoRelac + "|"+;
		cVlrRelac + "|"+;
		cSeqDelExec + "|"
Else
	cResult := "false|Não foi encontrado o grid especificado!"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)


/*/{Protheus.doc} PPLGETCMP
Retorna os campos do grid
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGETCMP()
LOCAL nI			:= 0
LOCAL nLen			:= 0
LOCAL nPos			:= 0
LOCAL cResult  		:= ""
LOCAL cGrid			:= ""
LOCAL nOpc			:= ""
LOCAL cRecno		:= ""
LOCAL lAtuVisibl	:= ""
LOCAL lDelVisibl	:= ""
LOCAL lFromGrid   	:= ""
local cFunPosExcl   := ""
local cParPosExcl	:= ""
local cSeqDelExec	:= "000"
LOCAL cHtml 		:= ""

WEB EXTENDED INIT cHtml START "InSite"

//Recupera nome do grid
cGrid 			:= HttpGet->cGrid
nOpc 			:= HttpGet->nOpc
cRecno 			:= HttpGet->nRecno
lBotao 			:= HttpGet->lBotao
cSt				:= HttpGet->cSt // 1-Normal; 0-Marca a linha
cValores 		:= HttpGet->cValores
cCampoDefault 	:= HttpGet->cCampoDefault

If ValType(HttpGet->cFunPosExcl) <> "U"
	cFunPosExcl := HttpGet->cFunPosExcl
Else
	cFunPosExcl := ""
EndIf

If ValType(HttpGet->cParPosExcl) <> "U"
	cParPosExcl := HttpGet->cParPosExcl
Else
	cParPosExcl := ""
EndIf

If ValType(HttpGet->lBtnAtuVisible) <> "U"
	lAtuVisibl := HttpGet->lBtnAtuVisible
Else
	lAtuVisibl := "true"
EndIf

If ValType(HttpGet->lBtnDelVisible) <> "U"
	lDelVisibl := HttpGet->lBtnDelVisible
Else
	lDelVisibl := "true"
EndIf

If ValType(HttpGet->lPacote) <> "U"
	lPacote := HttpGet->lPacote
Else
	lPacote := "false"
EndIf

If ValType(HttpGet->lFromGrid) <> "U"
	lFromGrid := HttpGet->lFromGrid
Else
	lFromGrid := "false"
EndIf

If ValType(HttpGet->cSeqDelExec) <> "U"
	cSeqDelExec := HttpGet->cSeqDelExec
EndIf

If cRecno == 'undefined'
	cRecno := '0'
EndIf

If lBotao == 'undefined'
	lBotao := 'true'
EndIf

If cSt == 'undefined'
	cSt := '1'
EndIf

If lAtuVisibl == 'undefined'
	lAtuVisibl := 'true'
EndIf

If lDelVisibl == 'undefined'
	lDelVisibl := 'true'
EndIf

//Encontra o objeto no array de campos
nPos := aScan( HttpSession->aCmpGuia, { |x| x:cNome == cGrid} )

//Monta o aCols e aHeader
If nPos > 0

	cResult := "true|" +	 cGrid + "|" + nOpc + "|["
	nLen 	:= len(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID)

	// Verifica se foi informado funcao de tratamento na linha
	For nI := 1 to nLen

		if valType(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID[nI]:cNome) <> 'U'

			cResult += alltrim(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID[nI]:cNome) + Iif( nLen != nI , ",", "]|" )

		endIf

	Next nI

	cResult += + cRecno + "|" + lBotao + "|" + cSt + "|"  + cValores + "|" + cCampoDefault + "|" + lAtuVisibl + "|" + lDelVisibl + "|" + lPacote + "|" + lFromGrid + "|" + cFunPosExcl + "|"  + cParPosExcl + "|" + cSeqDelExec + "|"
Else
	cResult := "false|Não foi encontrado o grid especificado!"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLVISGRID
Retorna as colunas e valores da linha do Grid
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLVISGRID()

LOCAL nI		:= 0
LOCAL nPos		:= 0
LOCAL nOpc 		:= 0
LOCAL nRecno	:= 0
LOCAL nLenCols	:= 0

LOCAL cResult  	:= ""
LOCAL cGrid		:= ""
LOCAL xCols		:= "[]"

LOCAL aHeader	:= {}
LOCAL aCols		:= {}

LOCAL cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

//Recupera dados da página
cGrid 	:= HttpGet->cGrid
nRecno 	:= Val(HttpGet->nRecno)
nOpc 	:= Val(HttpGet->nOpc)

//Encontra o objeto no array de campos
nPos := aScan( HttpSession->aCmpGuia, { |x| x:cNome == cGrid} )

//Monta o aCols e aHeader
If nPos > 0

	aHeader	:= HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING
	aCols	:= HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING

	//Verifica se o aCols e aHeader estão vazios
	If ValType(aHeader) <> 'A'
		aHeader := {}
	EndIf

	If ValType(aCols) <> 'A'
		aCols := {}
	EndIf

	//Recupera os valores e monta o xCols

	xCols 	 := "["
	nLenCols := len(aCols[nRecno])

	If nLenCols = 0
		xCols := ""
	EndIf

	For nI := 1 to nLenCols
		cValor := aCols[nRecno][nI]
		cCampo := aHeader[nRecno][nI]
		xCols += "{field:'"+cCampo+"', value:'" + cValor + "'} " + Iif( nLenCols != nI ,",","]" )
	Next nI

	cResult := "true|" + xCols + "|" +;
		Alltrim(Str(nRecno)) + "|" +;
		cGrid + "_RECNO" + "|" +;
		"bSave" + cGrid + "|"

EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSETACMP
Responsável pela manipulação dos grids das Guias no Portal
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSETACMP()
LOCAL cResult  	:= ""


LOCAL xCols		:= Separa ( HttpGet->cCols, "@" , .F.)

LOCAL aHeaderTmp	:=  {}
LOCAL aHeader	:=  {}
LOCAL aCols		:= {}
LOCAL aLinhaMarc	:= Separa ( HttpGet->aLinhas, "," , .F.) //Indica as linhas marcadas no grid
LOCAL aLinha		:= {}

LOCAL cGrid 		:= HttpGet->cGrid
LOCAL nPos			:= 0
LOCAL nI			:= 0
LOCAL nLinhas		:= 0
Local nCont			:= 0

LOCAL cSeqRefAtu := iif(type("HttpGet->cSeqRefAtu") <> "U" .and. !empty(HttpGet->cSeqRefAtu), HttpGet->cSeqRefAtu, "")
LOcal aAuxSeqRef := {}

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

For nCont := 1 To Len(aLinhaMarc)
	If ValType(aLinhaMarc[nCont]) <> "N"
		aLinhaMarc[nCont] := Val(aLinhaMarc[nCont])
	EndIf
Next nCont


//Encontra o objeto no array de campos

nPos := aScan( HttpSession->aCmpGuia, { |x| x:cNome == cGrid} )


//Monta o aCols e aHeader

//coloquei esse len do separa pois nos casos que a guia nao tem itens ainda dava error log,
//outras despesas por exemplo, pode não ter itens gravados
If nPos > 0 .and. len(Separa( HttpGet->cHeader, "@" , .F.)) > 0
	//Adiciona coluna que indica se a linha deve ser pintada
	aAdd(aHeaderTmp,Separa (Separa ( HttpGet->cHeader, "@" , .F.)[1],"|",.F.))
	aAdd(aHeaderTmp[len(aHeaderTmp)],"Marca")

	//Reconstruo o aCols que foi passado pela página
	nLinhas := len(xCols)
	For nI := 1 to nLinhas
		aLinha := Separa(xCols[nI],"|",.T.)
		//Verifica se a linha está marcada no grid
		If aScan( aLinhaMarc, { |x| x == nI} ) > 0
			aAdd(aLinha, "0" ) //Marcada
		Else
			aAdd(aLinha, "1" ) //Não marcada
		EndIf
		aAdd(aHeader,aHeaderTmp[1])
		aAdd(aCols,aLinha)
	Next nI

	HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING := aClone(aHeader)
	HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING := aClone(aCols)

	if(!empty(cSeqRefAtu))
		cSeqRefAtu := Separa(cSeqRefAtu, "!")

		for nI := 1 to len(cSeqRefAtu)

			aAuxSeqRef := Separa(cSeqRefAtu[nI], "$")
			HttpSession->aCmpGuia[nPos]:cXCols := StrTran( HttpSession->aCmpGuia[nPos]:cXCols, "field:'nSeqRef', value:'" + aAuxSeqRef[1] + "'", "field:'nSeqRef', value:'" + aAuxSeqRef[2] + "'")

		next nI

	endIf

	cResult := "true|"
Else
	cResult := "false|Não foi encontrado o grid especificado!"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLPROSAUD
Retorna as colunas e valores da linha do Grid
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLPROSAUD()

LOCAL nI			:= 0
LOCAL cResult  	:= ""
LOCAL cProSaud	:= ""
LOCAL oProSaud	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


//Recupera dados da página

cCombo := HttpGet->cCombo


// obj

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )


// Parametros

oObj:cUSERCODE	:= "MSALPHA"
oObj:cRdaCode	:= HttpGet->cRda
oObj:cCodLoc	:= HttpGet->cCodLoc

//Lista de profissional de saude
//Alterar posteriormente na reformulação da guia Odonto para o novo padrão.
If !HttpSession->cTp $ "1,2,3,4,5,11,12,6" .and. HttpSession->cTissVer < "3" .and. oObj:ProfSaud()
	oProSaud := oObj:oWSPROFSAUDRESULT:OWSLISTPROFSAUD:oWSPROFSAUD

	For nI := 1 To Len( oProSaud )
		cProSaud += oProSaud[nI]:cCODE + ";" + oProSaud[nI]:cNAME + "~"
	Next nI
EndIf

cResult := "true|" + cCombo + "|" + cProSaud + "|"

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCHAANOP
Retorna as colunas e valores da linha do Grid
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLANOPM
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->cTp := '09'

cHtml := ExecInPage( "PPLSSANO" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCHAANRA
Retorna as colunas e valores da linha do Grid
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLANRAD
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->cTp 	 := '08'
HttpSession->cNumAut := iIf(HttpGet->cNumAut == Nil,"",HttpGet->cNumAut)

cHtml := ExecInPage( "PPLSSANR" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLANQUI
Retorna as colunas e valores da linha do Grid d
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLANQUI
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->cTp := '07'

cHtml := ExecInPage( "PPLSSANQ" )

WEB EXTENDED END

getLOGMon()

Return cHtml


/*/{Protheus.doc} PPLSANX
Procura a liberacao e mostra os dados
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSANX()
local oObj	  	:= NIL
local cResult 	:= "true|"
local cHtml 	:= ""
local cTipGui 	:= ""
local cCodUsr 	:= ""
local cCodRda 	:= ""
local cGuiRef 	:= ""
local cMatric 	:= ""
local cDatGui 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

//Web Service
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros de entrada

oObj:cUserCode 		 := "MSALPHA"
oObj:cNumAut   		 := AllTrim(StrTran(StrTran(HttpGet->cNumeAut,".",""),"-",""))
oObj:cTipo			 := HttpGet->cTp

//Resgatar a lista de RDA's e passar para o RetAutLib separadas por vírgula.

oObj:cRDACode := StrTran(PLA09ASES(),"|M",",")


//Executa metodo para retorno da liberacao

If oObj:RetAutLib()

	//Cabecalho
	cResult +=	"B4A_REGANS!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cRegAns+"|"+;		    //0
		"B4A_DATPRO!"+dtoc(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:dDtAut)+"|"+; 		//1
		"B4A_NOMUSR!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomeUsr+"|"+;		        //2
		"B4A_USUARI!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cMatric+"|"+;      		//3
		"B4A_PESO!"+ AllTrim(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cPeso) +"|"+;       //4
		"B4A_ALTURA!"+ AllTrim(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cAltura) +"|"+;   //5
		"B4A_IDADE!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cIdade+"|"+;                //6
		"B4A_SEXO!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cSexo+"|"+;                  //7
		"cFormNumber!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNumImp+"|"             	//8

	//Carrega numero do protocolo RN 395 da guia principal
	cResult += iif( !empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cProtoc) , "B4A_PROATE!" + oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cProtoc + "|", "")	//9
	cResult += iif( !empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomSocBn), "B4A_NOMSOC!" + oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomSocBn + "|", "")	//10
	cResult += "<"

	//Gravo os atributos necessarios para o metodo 'isDupGui'
	cTipGui := oObj:cTipo
	cCodUsr := oObj:cUserCode
	cCodRda := oObj:cRdaCode
	cGuiRef := oObj:cNumAut
	cMatric := oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cMatric
	cDatGui := DtoS(Date())

	// Parametros para retornar se a guia eh duplicada
	oObj:cUserCode			:= cCodUsr
	oObj:cRdaCode			:= cCodRda
	oObj:cTipGui			:= cTipGui
	oObj:cUserCardNumber	:= cMatric
	oObj:cNumGuiRef			:= cGuiRef
	oObj:cDatGuia		 	:= cDatGui

	// Verifica se a guia pode estar sendo duplicada
	if oObj:isDupGui()
		cResult += "<" + SubStr(oObj:cIsDupGuiRESULT,6)
	endif

Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSCBTQ
Procura a liberacao e mostra os dados
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSCBTQ
LOCAL oObj	  	:= NIL
LOCAL cResult 	:= "true|"
LOCAL cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros de entrada
oObj:cUserCode 		 := "MSALPHA"
oObj:cChave   		 := HttpGet->cChkCpo
oObj:ccOpcao		 := HttpGet->cTab
oObj:ccCheckDePara	 := HttpGet->cCheckDePara

if ! oObj:VldBTQChv()
	cResult := "false|" + StrTran(PWSGetWSError( "" ),":","")
else
	cResult := "true|" + HttpGet->cCampoRef + "|" + oObj:OWSVldBTQChvRESULT:OWSSCABGUI:COBS
endIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSAUTANE
Procura a liberacao e mostra os dados
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSAUTANE()
LOCAL nI	  	:= 0
LOCAL nQtd		:= 0
LOCAL nPos	  	:= 0
LOCAL cResult 	:= "true|"
LOCAL aMat 	  	:= {}
LOCAL oObj	  	:= Nil
LOCAL cString 	:= HttpGet->cString
LOCAL cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"


//Pega o conteudo

If !Empty(cString)
	While ( nPos := At( "|", cString ) ) > 0
		AaDd( aMat,SubStr( cString, 1, nPos-1 ) )
		cString := SubStr( cString, nPos+1, Len(cString) )
	EndDo
EndIf

// Verifica se foi enviado algum registro para tratamento

If Len(aMat) >= 2

	// Registro no WS

	oObj := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLSXFUN.APW" )
	oObj:cUSERCODE := "MSALPHA"

	//Monta Matriz de itens ja executados

	If Len(aMat) > 3

		oObj:oWSSAUTPROC:oWSAUTITEM := PLSXFUN_ARRAYOFAUTITEMVIEW():New()

		For nI:=3 To Len(aMat)
			If !Empty(aMat[nI])

				//Monta dados dos itens

				aMatIte := PPLSALIMA(aMat[nI]+'||')

				//Alimenta a estrutura para envio dos procedimentos ja executados

				AaDd( oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW, PLSXFUN_AUTITEMVIEW():New() )

				//Quantidade de itens

				nQtd := Len( oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW )

				//Atribui dados ao obj

				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cCODPAD 				:= AllTrim( PPLSERGET('B4C_CODPAD',aMatIte[1]) )
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cPROCEDURECODE 		:= AllTrim( PPLSERGET('B4C_CODPRO',aMatIte[1]) )
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:nPROCEDUREQUANTITY		:= Val( PPLSERGET('B4C_QTDPRO',aMatIte[1]) )
				oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cSEQUENCE				:= aMat[1]
			EndIf
		Next
	EndIf

	// Parametros de envio

	oObj:oWSSAUTPROC:cMatric 	:= HttpGet->cMatric
	oObj:oWSSAUTPROC:cTipGui 	:= HttpSession->cTp
	oObj:oWSSAUTPROC:dDatPro 	:= Date()
	oObj:oWSSAUTPROC:cSequen 	:= aMat[1]
	oObj:oWSSAUTPROC:cMatRet 	:= aMat[2]+"~"
	oObj:oWSSAUTPROC:cCid	 	:= HttpGet->cCid
	oObj:oWSSAUTPROC:cCodPad 	:= HttpGet->cCodPad
	oObj:oWSSAUTPROC:cCodPro 	:= HttpGet->cCodPro
	oObj:oWSSAUTPROC:cGuiRef    := HttpGet->cGuiRef


	If ("," $ HttpGet->nQtdSol)
		nQtd := SEPARA(HttpGet->nQtdSol,",")[2]
		oObj:oWSSAUTPROC:nQtdPro 	:= Val(nQtd)
	Else
		oObj:oWSSAUTPROC:nQtdPro 	:= Val(HttpGet->nQtdSol)
	EndIf

	//Executa o metodo pega o retorno

	If oObj:AutAnexo()

		//Se foi autorizado ou negado

		If oObj:oWSAutAnexoRESULT:lPROAUT
			cResult += "1|"
		Else
			cResult += "Critica(s)|"
		EndIf

		//Matriz que retorna os resultados formatados campo a campo do formulario

		cResult += oObj:oWSAutAnexoRESULT:cMatRetRes+"|"

		//Monta a string de retorno

		cResult += oObj:oWSAutAnexoRESULT:cAUTORI+"|"+;
			oObj:oWSAutAnexoRESULT:cCHAVE+"|"+;
			oObj:oWSAutAnexoRESULT:cNIVEL+"|"

		//Monta as criticas

		For nI:=1 To Len(oObj:oWSAutAnexoRESULT:oWSMATCRI:oWSGenericStruct)
			cResult += 	oObj:oWSAutAnexoRESULT:oWSMATCRI:oWSGenericStruct[nI]:cCode+" - "+;//0
				oObj:oWSAutAnexoRESULT:oWSMATCRI:oWSGenericStruct[nI]:cDescription//1
		Next
	Else
		cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
	EndIf
Else
	cResult := "false|Nenhum registro para tratamento"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLPRANEXO
Processa as Guias
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLPRANEXO()
LOCAL nI,nY		  := 0
LOCAL oObj,oObjAux,oObjSex := NIL
LOCAL nIteAut     := 0
LOCAL nIteNeg     := 0
LOCAL cResultCab  := "true|"
LOCAL cResultItem := ""
LOCAL cResultSenPr:= ""
LOCAL cNumAut	  := ""
LOCAL cResult 	  := ""
LOCAL cSequen	  := ""
LOCAL cCodTab	  := ""
LOCAL cCodPro	  := ""
LOCAL cDesPro	  := ""
LOCAL cDente	  := ""
LOCAL cFace	  	  := ""
LOCAL cQtdTot	  := ""
LOCAL cSenPro	  := ""
LOCAL cCritica	  := ""
LOCAL cQtdUs	  := ""
LOCAL cData		  := ""
LOCAL cSenhaAu	  := ""
LOCAL cOrigem	  := "2"
LOCAL cStatus 	  := "1"
LOCAL cDadInt	  := ""
LOCAL cDesGRP	  := ""
LOCAL lFemini	  := .F.
LOCAL lProGe	  := .F.
LOCAL lExecu	  := .F.
LOCAL lEvolu	  := .F.
LOCAL aMatIte	  := {}
LOCAL cStProc	  := ""
LOCAL cTissVer	  := iIf( valtype(HttpSession->RDAVIEW) == 'A' .and. len(HttpSession->RDAVIEW) > 0, HttpSession->RDAVIEW[1]:cTissVer,'3.03.00')
Local lTemProc 	  := cTissVer < '3.03.00' .or. HttpSession->cTp != "08" //radioterapia não tem mais procedimentos a partir da tiss 3.03.00
LOCAL cHtml 	  := ""
LOCAL cStatGui    := ""

WEB EXTENDED INIT cHtml START "InSite"


//Sessao para impressao da guia

HttpSession->aResult := {}
HttpSession->lSen 	 := .F.

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros de entrada
oObj:cUserCode		 := "MSALPHA"
oObj:cUserCardNumber := ""
oObj:cNumAut         := ""
oObj:cTipoAut        := "A"
oObj:cCampos         := "B4A_STATUS"
oObj:cTipo		     := HttpSession->cTp

//Monta o box de um determinado campo

If oObj:GetBox()
	aCBox := oObj:OWSGETBOXRESULT:OWSGENERICSTRUCT
EndIf


// PLSXMOV

oObj := WSPLSXMOV():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXMOV.APW" )

// Processa a guia
oObj:cUSERCODE	:= "MSALPHA"				//Usuario
oObj:nAUTTYPE	:= val(HttpSession->cTp)			//Tipo de guia consulta,sadt,internacao,Odonto

// Restante dos dados da guia

oObj:cOrigem 								:= cOrigem							//Se e para solicitar ou executar

oObj:oWSAUTHORIZATION  						:= PLSXMOV_AUTHORIZATIONVIEW():New()
oObj:oWSAUTHORIZATION:oWSAUTHEADER			:= PLSXMOV_AUTHEADERVIEW():New()

oObj:oWSAUTHORIZATION:oWSAUTHEADER:cRegAns	:= HttpPost->B4A_REGANS
oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDatDia	:= If(HttpPost->B4A_DATDIA <> nil,ctod(HttpPost->B4A_DATDIA),ctod(''))
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cDiaImg	:= HttpPost->B4A_DIAIMG
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cEstadi	:= HttpPost->B4A_ESTADI
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cEcog	:= HttpPost->B4A_ECOG
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cFinAtd	:= HttpPost->B4A_FINALI
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cDiaGch	:= HttpPost->B4A_DIAGCH
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cGuiRef	:= AllTrim(StrTran(StrTran(HttpPost->B4A_GUIREF,".",""),"-",""))//Matricula
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cInfRel	:= HttpPost->B4A_INFREL
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCirurg	:= HttpPost->B4A_CIRURG
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cQuimio	:= HttpPost->B4A_QUIMIO
oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDatCir	:= If(HttpPost->B4A_DATCIR <> nil,ctod(HttpPost->B4A_DATCIR),ctod(''))
oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDatIrr	:= If(HttpPost->B4A_DATIRR <> nil,ctod(HttpPost->B4A_DATIRR),ctod(''))
oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDatqui	:= If(HttpPost->B4A_DATQUI <> nil,ctod(HttpPost->B4A_DATQUI),ctod(''))
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cNomfSol	:= HttpPost->B4A_NOMSOL
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cEmafSol	:= HttpPost->B4A_EMASOL
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cTelfSol	:= HttpPost->B4A_TELSOL
oObj:oWSAUTHORIZATION:oWSAUTHEADER:nNroCam	:= If(HttpPost->B4A_NROCAM <> nil,val(StrTran(HttpPost->B4A_NROCAM,",",".")),0)
oObj:oWSAUTHORIZATION:oWSAUTHEADER:nDosDia	:= If(HttpPost->B4A_DOSDIA <> nil,val(StrTran(HttpPost->B4A_DOSDIA,",",".")),0)
oObj:oWSAUTHORIZATION:oWSAUTHEADER:nDosTot	:= If(HttpPost->B4A_DOSTOT <> nil,val(StrTran(HttpPost->B4A_DOSTOT,",",".")),0)
oObj:oWSAUTHORIZATION:oWSAUTHEADER:nNroDia	:= If(HttpPost->B4A_NRODIA <> nil,val(StrTran(HttpPost->B4A_NRODIA,",",".")),0)
oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDatPre	:= If(HttpPost->B4A_DATPRE <> nil,ctod(HttpPost->B4A_DATPRE),ctod(''))
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cPlater	:= HttpPost->B4A_PLATER
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cTipQui	:= HttpPost->B4A_TIPQUI
oObj:oWSAUTHORIZATION:oWSAUTHEADER:nSupCor	:= If(HttpPost->B4A_SUPCOR <> nil,val(StrTran(HttpPost->B4A_SUPCOR,",",".")),0)
oObj:oWSAUTHORIZATION:oWSAUTHEADER:nAltura	:= If(HttpPost->B4A_ALTURA <> nil,val(StrTran(HttpPost->B4A_ALTURA,",",".")),0)
oObj:oWSAUTHORIZATION:oWSAUTHEADER:nPeso	:= If(HttpPost->B4A_PESO <> nil,val(StrTran(HttpPost->B4A_PESO,",",".")),0)
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCidPri 	:= HttpPost->B4A_CIDPRI
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCid2 	:= HttpPost->B4A_CIDSEC
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCid3 	:= HttpPost->B4A_CIDTER
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCid4 	:= HttpPost->B4A_CIDQUA
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cEspMat	:= HttpPost->B4A_ESPMAT
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cObserv	:= HttpPost->B4A_OBSERV
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cJustTe	:= HttpPost->B4A_JUSTTE
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cAreaIr	:= HttpPost->B4A_AREA
oObj:oWSAUTHORIZATION:oWSAUTHEADER:nNroCic	:= If(HttpPost->B4A_NROCIC <> nil,val(StrTran(HttpPost->B4A_NROCIC,",",".")),0)
oObj:oWSAUTHORIZATION:oWSAUTHEADER:nCicAtu	:= If(HttpPost->B4A_CICATU <> nil,val(StrTran(HttpPost->B4A_CICATU,",",".")),0)
oObj:oWSAUTHORIZATION:oWSAUTHEADER:nIntCic	:= If(HttpPost->B4A_INTCIC <> nil,val(StrTran(HttpPost->B4A_INTCIC,",",".")),0)
oObj:oWSAUTHORIZATION:oWSAUTHEADER:nIdade	:= If(HttpPost->B4A_IDADE <> nil,val(StrTran(HttpPost->B4A_IDADE,",",".")),0)
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cSexo	:= HttpPost->B4A_SEXO

oObj:oWSAUTHORIZATION:oWSAUTHEADER:cTumor	:= HttpPost->B4A_TUMOR
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cNodulo	:= HttpPost->B4A_NODULO
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cMetast	:= HttpPost->B4A_METAST
oObj:oWSAUTHORIZATION:oWSAUTHEADER:nDCicAtu	:= If(HttpPost->B4A_DCICAT <> nil,val(StrTran(HttpPost->B4A_DCICAT,",",".")),0)

oObj:oWSAUTHORIZATION:oWSAUTHEADER:lChkReg 				:= .T.				   				//Se vai chegar regras ou nao
oObj:oWSAUTHORIZATION:oWSAUTHEADER:dProcedureDate		:= Date()							//Data do procedimento
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cRegistrationNumber 	:= AllTrim(HttpPost->B4A_USUARI) //Matricula -- A MATANT pode ter traços ou pontos e ai não faz o seek


aMatIte := PPLSALIMA(HttpPost->cMatTabES)


//Alimenta a strutura ws com todos os itens do formulario genericamente

oObj:oWSAUTHORIZATION:oWSAUTITEM := PLSXMOV_ARRAYOFAUTITEMVIEW():New()

For nI:=1 To Len(aMatIte)

	AaDd( oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW, PLSXMOV_AUTITEMVIEW():New() )

	//Adiciona na strutura ws

	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cSEQUENCE 			:= StrZero( Val( AllTrim( PPLSERGET('cSeq',aMatIte[nI]) ) ), 3 )  //Sequencia
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cCODPAD 			:= AllTrim( PPLSERGET('cCodPad',aMatIte[nI]) )					  //Tabela
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cPROCEDURECODE 		:= AllTrim( PPLSERGET('cCodPro',aMatIte[nI]) )					  //Servico
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:nPROCEDUREQUANTITY	:= Val( PPLSERGET('nQtdSol',aMatIte[nI]) )						  //Qtd Solicitada
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:nQtdAut  			:= Val( PPLSERGET('nQtdAut',aMatIte[nI]) ) 						  //Qtd Autorizada
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:dDatPro				:= ctod( PPLSERGET('dDatPro',aMatIte[nI]) )
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cViaAdm				:= AllTrim( PPLSERGET('cViaAdm',aMatIte[nI]) )
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:nFreque				:= val(AllTrim( PPLSERGET('cFreque',aMatIte[nI]) ))
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cRegAnv				:= AllTrim( PPLSERGET('cRegAnv',aMatIte[nI]) )
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cRefMat				:= AllTrim( PPLSERGET('cRefMaf',aMatIte[nI]) )
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cAutFun				:= AllTrim( PPLSERGET('cAutFun',aMatIte[nI]) )
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:nVlrUnt				:= val( StrTran( StrTran(PPLSERGET('nVlrUnt',aMatIte[nI]), ".", ""), ",","") ) /100
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:nVlrTot				:= val( StrTran( StrTran(PPLSERGET('nVlrUna',aMatIte[nI]), ".", ""), ",","") ) /100
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cOpcao				:= AllTrim( PPLSERGET('cOpcao',aMatIte[nI]) )
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cViaAc				:= AllTrim( PPLSERGET('cViaAc',aMatIte[nI]) )
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cUniMedC			:= AllTrim( PPLSERGET('cUniMed',aMatIte[nI]) )

	If Type('oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW['+alltrim(str(nI))+']:cCodNeg') <> 'U'
		oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cCodNeg			:= AllTrim( PPLSERGET('cCodNeg',aMatIte[nI]) )						//Status do Procedimento
	Endif

	If Type('oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW['+alltrim(str(nI))+']:cStProc') <> 'U'
		oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cStProc			:= AllTrim( PPLSERGET('cStatus',aMatIte[nI]) )						//Status do Procedimento
	Endif

Next

// Processa Guia
If oObj:GravaAnexo()

	// Somente na internacao


	// Rda,Nome rda,Nome produto,Servico formatado,Numero da autorizacao,Senha e total

	cResultCab +=	oObj:oWSGRAVAANEXORESULT:cNUMBER			+"|"+;	//0
		oObj:oWSGRAVAANEXORESULT:cPASSWORD		+"|"+;	//1
		DToC( Date() )									+"|"+;	//2
		DToC(oObj:oWSGRAVAANEXORESULT:dDtValSen)	+"|"+;  //3
		cDadInt+"||||||"						        //4

	// Procedimentos autorizados

	cResultA := ""
	cResultN := ""
	cStatGui := oObj:oWSGRAVAANEXORESULT:cStatAut
	If lTemProc

		For nI:=1 To Len(oObj:oWSGRAVAANEXORESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW)
			nIteAut := 1
			cSequen		:= oObj:oWSGRAVAANEXORESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cSequence
			cCodTab		:= oObj:oWSGRAVAANEXORESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cTableCode
			cCodPro		:= oObj:oWSGRAVAANEXORESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cProcedureCode
			cDesPro		:= StrTran(PadR(oObj:oWSGRAVAANEXORESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cDescription,55)," ","&nbsp;")
			cDente    	:= AllTrim(oObj:oWSGRAVAANEXORESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cDente)
			cDente    	:= Iif(HttpSession->cTp=="4" , Iif( Empty(cDente),"&nbsp;&nbsp;&nbsp;&nbsp;",cDente ),"" )
			cFace     	:= AllTrim(oObj:oWSGRAVAANEXORESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cFace)
			cFace     	:= Iif(HttpSession->cTp=="4" , Iif( Empty(cFace),"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",cFace ),"" )
			cQtdTot		:= StrZero(oObj:oWSGRAVAANEXORESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:nQtdTotal,4)

			cQtdUs      := AllTrim(Str(oObj:oWSGRAVAANEXORESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:nTotalUS))
			cData       := DtoC(Date())
			cSenhaAu    := oObj:oWSGRAVAANEXORESULT:cPASSWORD

			cSenPro		:= oObj:oWSGRAVAANEXORESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cSenha

			If (cCodTab+cCodPro) $ HttpSession->cUsuProc
				lProGe :=.T.
			Endif

			// Monta Linha para retorno  em tela

			cResultA += cSequen+"&nbsp;"+cCodTab+"-"+cCodPro+" - "+cDesPro+" - "+cQtdTot+"<br>";

			// Guia de Prorrogacao Senhas dos procedimentos

			If !Empty(cSenPro)
				cResultSenPr += cSenPro+"@"
			EndIf

			// Monta matriz para impressao de guia

			AaDd( HttpSession->aResult,{cSequen,cCodTab,cCodPro,cDesPro,cDente,cFace,cQtdTot,{},cQtdUs,cData,cSenhaAu,cSenPro,cDesGRP,cStProc} )

			// Verifica se tem algum procedimento com senha

			If !Empty(cSenPro)
				HttpSession->lSen := .T.
			EndIf
		Next

		// Procedimentos nao autorizados Obs (Nao precisa do if pq e a ultima implementacao)

		For nI:=1 To Len(oObj:oWSGRAVAANEXORESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW)//10
			nIteNeg   	:= 1
			aCritica 	:= {}
			cSequen		:= oObj:oWSGRAVAANEXORESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cSequence
			cCodTab		:= oObj:oWSGRAVAANEXORESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cTableCode
			cCodPro		:= oObj:oWSGRAVAANEXORESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cProcedureCode
			cDesPro		:= StrTran(PadR(oObj:oWSGRAVAANEXORESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cDescription,55)," ","&nbsp;")
			cDente    	:= AllTrim(oObj:oWSGRAVAANEXORESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cDente)
			cDente    	:= Iif(HttpSession->cTp=="4" , Iif( Empty(cDente),"&nbsp;&nbsp;&nbsp;&nbsp;",cDente ),"" )
			cFace     	:= AllTrim(oObj:oWSGRAVAANEXORESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cFace)
			cFace     	:= Iif(HttpSession->cTp=="4" , Iif( Empty(cFace),"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",cFace ),"" )
			cQtdTot		:= StrZero(oObj:oWSGRAVAANEXORESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:nQtdTotal,4)
			cQtdUs      := alltrim(Str(oObj:oWSGRAVAANEXORESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:nTotalUS))
			cData       := dtoc(date())
			cSenhaAu    := oObj:oWSGRAVAANEXORESULT:cPASSWORD

			// Monta Linha para retorno de em tela

			cResultN += cSequen+"&nbsp;"+cCodTab+"-"+cCodPro+" - "+cDesPro+" - "+cQtdTot+"<br>";

			// Procedimentos criticados

			For nY:= 1 To Len(oObj:oWSGRAVAANEXORESULT:oWSERROR:oWSAUTERRORVIEW)
				If oObj:oWSGRAVAANEXORESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cSequence == oObj:oWSGRAVAANEXORESULT:oWSERROR:oWSAUTERRORVIEW[nY]:cSequence

					cCritica := WCTextNeg( oObj:oWSGRAVAANEXORESULT:oWSERROR:oWSAUTERRORVIEW[nY]:cCode+" - "+oObj:oWSGRAVAANEXORESULT:oWSERROR:oWSAUTERRORVIEW[nY]:cDescription )

					// Monta Linha para retorno em tela

					cResultN +=	cCritica

					// Monta matriz para impressao de guia

					AaDd(aCritica,cCritica )
				EndIf
			Next

			// Monta matriz para impressao de guia

			AaDd( HttpSession->aResult,{cSequen,cCodTab,cCodPro,cDesPro,cDente,cFace,cQtdTot,aCritica,cQtdUs,cData,cSenhaAu,"",cDesGRP,cStProc} )
		Next
	Else
		If cStatGui $ "1,2" .Or. empty(cStatGui)
			If cStatGui == "1"
				nIteAut := 1
				nIteNeg := 0
				aCritica := {}
			else
				nIteAut := 1
				nIteNeg := 1
				aCritica := {}
			endIf
		else
			nIteAut := 0
			nIteNeg := 1
			aCritica := {}
		EndIf

	EndIf

	// Monta variaveis de sessao para impressao

	HttpSession->cNumeAut	:= Iif(lEvolu,cNumAut,oObj:oWSGRAVAANEXORESULT:cNUMBER)
	HttpSession->cSenha		:= Iif(lEvolu,"",oObj:oWSGRAVAANEXORESULT:cPASSWORD)
	HttpSession->cFormNumber:= HttpPost->cFormNumber

	cStatus := Iif( nIteAut == 1 .And. nIteNeg == 0,"1",Iif( nIteAut == 0 .And. nIteNeg == 1,"3","2") )

	If nIteAut == 0 .AND. nIteNeg == 0 //Guia de Radioterapia pode não ter itens, daí atualiza aqui.. talvez isso tenha que ser revisto no futuro
		cStatus := "1"
	endIf

	If oObj:oWSGRAVAANEXORESULT:lAto .And. cStatus $ "1,2"
		cStatus := "5"
	EndIf



	HttpSession->cTitulo := AllTrim(aCBox[Ascan( aCBox, {|x| x:cCODE == cStatus} )]:CDESCRIPTION)

	If nIteAut==1 .and. nIteNeg==0
		cResultA	:= ""
		cResultItem := cResultA
	EndIf

	If nIteNeg==1	.and. nIteAut==1
		cResultItem	:= cResultA+cResultN
	EndIf

	If nIteAut==0 .and. nIteNeg==1
		cResultItem	:= cResultN
	EndIf

	If oObj:oWSGRAVAANEXORESULT:lAudi <> Nil .AND. oObj:oWSGRAVAANEXORESULT:lAudi
		cResult := cResultCab + cResultItem + "|" + "Em Análise" + "|"
	Else
		cResult := cResultCab + cResultItem + "|" + HttpSession->cTitulo + "|"
	EndIf

	If lExecu .And. lFemini .And. lProge
		cResult += "SIM"
	Else
		cResult += "NAO"
	Endif

	cResult += "|" + cResultSenPr + "|"

Else
	cResult := "false|" + StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLRESDOCG
retorna valor da session
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLRESDOCG()
Return PLSDECODE("true|" + HttpSession->cResDoc)

/*/{Protheus.doc} PPLINTERBE

@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLINTERBE()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

//Mostra a pagina de procedimentos


cHtml += ExecInPage( "PPLINTERABER" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLMATRIC
Retorna a matricula do beneficiario internado
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLMATRIC()
LOCAL cResult  	:= "true|"
LOCAL cRecno  := HttpGet->cRecno
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->cBtInterna := "1"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:CcRecno	:= cRecno

If HttpSession->cTipCar $ HttpSession->cBtIntern .OR. HttpSession->cBtIntern $ "2"

	If oObj:Matric()
		cResult += oObj:OWSMatricRESULT:OWSSMatric[1]:CMATRIC
	Else
		cResult := "false|"
	EndIf
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLRETINTR
Utilizado para controlar utilizacao do botao interna
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLRETINTR()

LOCAL cResult := "true|"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->cBtInterna := "0"

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLB4DRGLO
Retorna informação o Recurso de Glosa para popular a guia
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLB4DRGLO()
Local cResult := ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


//Informacao do Recurso

If ValType(HttpGet->cRecnoB4D) <> 'U'

	// obj

	oObj := WSPLRECGLO():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLRECGLO.APW" )

	// Parametros

	oObj:cUSERCODE	:= "MSALPHA"
	oObj:cRecno	:= HttpGet->cRecnoB4D
	oObj:cVisDad	:= IIF(HttpGet->cOpc == "V","1","0") // se for somente visualizacao ou nao

	// Dados do Recurso

	If oObj:GetRecGloB4D()
		cResult += "true|" + oObj:cGetRecGloB4DRESULT
	else
		cResult += "false"
	EndIf
Else
	cResult := "false"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLPROCRGL
Processa a Guia de Recurso de Glosa
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLPROCRGL()

LOCAL cResult := ""
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"


// obj

oObj := WSPLRECGLO():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLRECGLO.APW" )

// Parametros

oObj:cUSERCODE	:= "MSALPHA"
oObj:cRecno	:= HttpPost->cRecnoB4D
oObj:cTipoGlosa	:= HttpPost->cTpRecGlo
oObj:cJustif	:= HttpPost->cMatJustif


// Dados do Recurso

If oObj:ProcJustfRecGlo()
	cResult += oObj:cProcJustfRecGloRESULT
else
	cResult += "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCHARECG
Chama determinado forumulario do atendimento
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCHARECG()
LOCAL cHtml 	:= ""
LOCAL oObj	    := nil
LOCAL nPosRda	:= 0
LOCAL cTISSVer	:= "3.01.00"
LOCAL cRda		:= ""
LOCAL aRDA		:= {}
LOCAL nI		:= 0
LOCAL nY		:= 0
LOCAL cResult	:= ""

WEB EXTENDED INIT cHtml START "InSite"

// Aliemnta variavel de sessao

HttpSession->cTp := "10"

// Recupera a RDA e sua versão TISS

cRda := HttpGet->cRda

nPosRDA := aScan( HttpSession->RDAVIEW, { |x| x:cCODE == cRda } )
If nPosRDA > 0
	aRDA := ClassDataArr(HttpSession->RDAVIEW[nPosRDA])
	If aScan(aRDA,{|x| AllTrim(x[1]) == "CTISSVER"  }) > 0
		cTISSVer := HttpSession->RDAVIEW[nPosRDA]:cTissVer
	EndIf
Else
	cTISSVer := HttpSession->RDAVIEW[1]:cTissVer
EndIf
HttpSession->cTISSVer := cTISSVer


// CRIAR PAGINA PARA TISS 3.0

If cTissVer >= "3"


	// oBJ

	oObj := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLSXFUN.APW" )


	// Parametros

	oObj:cUserCode	:= "MSALPHA"
	oObj:oWSGUIATISS:cTipGui		:= "10" // Guia de Recurso de Glosa
	oObj:oWSGUIATISS:cVerTiss	:= cTISSVer


	// Aqui eu pego o que vem de Session executo aqui pra enviar a informaçao
	// pro WS pois o mesmo nao acessa o conteudo da Session	dificultando o dinamismo

	If oObj:GetCmbFormT()
		// ATRIBUO OS PARAMETROS NOVAMENTE PARA UTILIZAÇÃO DO PROXIMO METODO
		oObj:cUserCode	:= "MSALPHA"
		oObj:oWSGUIATISS:cTipGui		:= STRZERO(val(HttpSession->cTp),2)
		oObj:oWSGUIATISS:cVerTiss	:= cTISSVer
		//oObj:oWSGUIATISS:OWSCMBGUIA	:= {}
		oObj:oWSGUIATISS:cDadCombo	:= ""
		If Len(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA) > 0 //oObj:OWSGETCMBFORMTRESULT:oWSRETCMBSGUIA
			For nI:=1 To Len(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA)
				cStrCBOX := ""
				If "HTTPSESSION" $ Upper(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX)	 // Se for uma Session eu pego CCODE e CNAME e monto o Combo
					If ValType(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX)) <> 'U'
						For nY := 1 To Len(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX))
							cStrCBOX += Alltrim(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX + "[" + Alltrim(Str(nY)) + "]:cCODE")) + "=" + Alltrim(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX + "[" + Alltrim(Str(nY)) + "]:cNAME")) + ";"
						Next nY
					EndIf
					If nY > 2
						cStrCBOX += ";="//cStrCBOX += ";=-- Selecione um item --"
					EndIf
				Else // Caso contrario eu pego a STRING com mesma estrutura do X3_COBX
					cStrCBOX := Alltrim(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX)
				EndIf
				If SubStr(cStrCBOX, Len(cStrCBOX),1) == ";"
					cStrCBOX := SubStr(cStrCBOX, 1, Len(cStrCBOX)-1)
				EndIf
				oObj:oWSGUIATISS:cDadCombo	+= Alltrim(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCampoG) + ";" + cStrCBOX + "|"
				//WSDATA RetCmbsGuia	AS Array Of SRetCmbsGuia OPTIONAL
			Next
		EndIf
	EndIf
	If SubStr(oObj:oWSGUIATISS:cDadCombo, Len(oObj:oWSGUIATISS:cDadCombo),1) == "|"
		oObj:oWSGUIATISS:cDadCombo := SubStr(oObj:oWSGUIATISS:cDadCombo, 1, Len(oObj:oWSGUIATISS:cDadCombo)-1)
	EndIf

	oObj:cMsnBloInter	:= HttpSession->cMsnBloInt


	// Retorna dados da pagina

	oObj:cDtJs := iif(valtype(HttpSession->cDtJs) <> 'U', HttpSession->cDtJs, "")
	If oObj:GetFormTiss()
		cResult :=  oObj:OWSGETFORMTISSRESULT:cPagina
		If ValType(oObj:OWSGETFORMTISSRESULT:cGrids) == "C"
			HttpSession->cGrids := oObj:OWSGETFORMTISSRESULT:cGrids
		EndIf

		If ValType(oObj:OWSGETFORMTISSRESULT:OWSCMPGUIA:oWSSCmpGuia) == "A" /*/:OWSCMPGUIA:OWSSCMPGUIA)*/
			HttpSession->aCmpGuia := aClone(oObj:OWSGETFORMTISSRESULT:OWSCMPGUIA:oWSSCmpGuia)
		EndIf

		//Executa os inicializadores dos campos
		nIni := At("<%=",cResult)
		While  nIni > 0
			nFim := At("%>",cResult)
			cComando := SubStr(cResult,nIni+3,nFim - nIni-3)
			xResult := &(cComando)

			cTipResult := ValType(xResult)
			Do Case
				Case cTipResult == "D"
					xResult := DtoS(xResult)
					xResult := SubStr(xResult,7,2) + "/" + SubStr(xResult,5,2) + "/" + SubStr(xResult,1,4)
				Case cTipResult == "N"
					xResult := Alltrim(Str(xResult))
			EndCase

			cResult := StrTran ( cResult, "<%=" + cComando + "%>", xResult) //, nIni, 1)
			nIni := At("<%=",cResult)
		EndDo

	EndIf

	HttpSession->cPaginaGuia := Substr(cResult,At("|",cResult)+1,Len(cResult)) // Retiro o true| ou o false|

	cHtml += ExecInPage("PPLSGUIAS")
EndIf

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLRGVLD
Valida inclusao de  Recurso de Glosa
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLRGVLD()
Local cResult := ""
Local cRda		:= ""
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"


// obj

oObj := WSPLRECGLO():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLRECGLO.APW" )

// Parametros

oObj:cUSERCODE	:= "MSALPHA"
oObj:cRecno	:= HttpGet->cRecnoB4D
cRda			:= HttpGet->cRda

// Dados do Recurso

If oObj:VldRecGlo()
	cResult += oObj:cVldRecGloRESULT
else
	cResult += "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLRGDEL
Cancela um recurso de Glosa
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLRGDEL()
Local cResult := ""
Local cRda		:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLRECGLO():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLRECGLO.APW" )

// Parametros

oObj:cUSERCODE	:= "MSALPHA"
oObj:cRecno	:= HttpGet->cRecno

// Dados do Recurso

If oObj:ExcRecGlo()
	cResult += oObj:cExcRecGloRESULT
else
	cResult += "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLTIPDOC
Retorna os tipos de documentos do reembolso no portal do beneficiario
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLTIPDOC()
LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

//If HttpSession->MPortal == "000010"

oObj:cUserCode	:= "MSALPHA"
//oObj:cCUSRLOGIN	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE

//EndIf

// Retorna dados

If oObj:DadTipDoc()

	nResult := Len(oObj:OWSDadTipDocRESULT:OWSSDadTip)

	xCols := "["
	For nI := 1 to nResult

		xCols += "{"
		xCols +=  "0:{field:'cCod', value:'" + oObj:OWSDadTipDocRESULT:OWSSDadTip[nI]:cCod +   "'},"
		xCols +=  "1:{field:'cDescri',value:'" +  SubStr(oObj:OWSDadTipDocRESULT:OWSSDadTip[nI]:cDescri,1,25) + "'},"
		xCols +=  "2:{field:'cImgHelp',value:'" + oObj:OWSDadTipDocRESULT:OWSSDadTip[nI]:cImgHelp + "'},"
		xCols +=  "3:{field:'cObriga',value:'" + oObj:OWSDadTipDocRESULT:OWSSDadTip[nI]:cObriga + "'}"
		xCols +=  IIF( nResult != nI ,"},","}]" )
	Next

	If nResult == 0
		xCols += "{"
		xCols +=  "0:{field:'cCod', value:'01'},"
		xCols +=  "1:{field:'cDescri',value:'Nota Fiscal'},"
		xCols +=  "2:{field:'cImgHelp',value:''},"
		xCols +=  "3:{field:'cObriga',value:'1'}}]"
	EndIf

	cResult += xCols +"|"

Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PRDAREF
Retorna a RDA nao referenciada BK6 ao digitar o CPF/CNPJ
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PRDAREF()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""
Local cMatric	:= ""
WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cCpfCnpj		:= HttpGet->cProSaud
oObj:cMatric		:= SubStr(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CBENEFI,1,14)


// Retorna dados

If oObj:RDARef()
	cResult += oObj:cRDARefRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGETCMP
Retorna os campos do grid
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGCMP()
LOCAL oObj 		:= NIL

LOCAL nI			:= 0
LOCAL nLen			:= 0
LOCAL nPos			:= 0

LOCAL cResult  	:= ""
LOCAL cGrid		:= ""
LOCAL nOpc			:= ""
LOCAL cRecno		:= ""
LOCAL aObjSess	:= {} // Variaveis para criação de Grid generica
LOCAL aMntSess	:= {} 	// Variaveis para criação de Grid generica
LOCAL aCpoAtu		:= {} 	// Variaveis para criação de Grid generica
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


//Recupera nome do grid

cGrid := HttpGet->cGrid
nOpc := HttpGet->nOpc
cRecno := HttpGet->nRecno
lBotao := HttpGet->lBotao
cSt		:= HttpGet->cSt // 1-Normal; 0-Marca a linha
cValores := HttpGet->cValores
cCampoDefault := HttpGet->cCampoDefault
cMontaSess := HttpGet->cMontaSess
cLarBrw 	:= HttpGet->cLarBrw
cAltBrw 	:= HttpGet->cAltBrw
cUpdReg	:= HttpGet->cUpdReg
cNoLpCamp	:= IIf(Empty(HttpGet->cNoLimpa), "", HttpGet->cNoLimpa)

If cRecno='undefined'
	cRecno := '0'
EndIf

If lBotao='undefined'
	lBotao := 'true'
EndIf

If cSt='undefined'
	cSt := '1'
EndIf

If cMontaSess='undefined'
	cMontaSess := ''
Else
	aMntSess := StrToArray(cMontaSess, "|")
EndIf

If cLarBrw='undefined'
	cLarBrw := '630'
EndIf

If cAltBrw='undefined'
	cAltBrw := '300'
EndIf

If cUpdReg='undefined'
	cUpdReg := '1'
EndIf

If cNoLpCamp='undefined'
	cNoLpCamp := ''
EndIf

// Para montagem do Grid especificado direto da pagina sem ir no WS
If !Empty(cMontaSess) .AND. ValType(HttpSession->aCmpGuia) == 'U'	//.AND. nPos := aScan( HttpSession->aCmpGuia, { |x| x:cNome == cGrid} )

	oObj := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLSXFUN.APW" )
	oObj:cUSERCODE := "MSALPHA"

	AaDd( aObjSess, PLSXFUN_ARRAYOFSCMPGUIA():New() ) //aObjSess := PLSXFUN_ARRAYOFSCMPGUIA():New()

	nPos := Len(aObjSess)
	AaDd( aObjSess[nPos]:OWSSCMPGUIA, PLSXFUN_SCMPGUIA():New() )

	aObjSess[nPos]:OWSSCMPGUIA[1]:cTipo := 'G'
	aObjSess[nPos]:OWSSCMPGUIA[1]:cNome := cGrid
	aObjSess[nPos]:OWSSCMPGUIA[1]:cDescri := ""
	aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid := PLSXFUN_ARRAYOFSCMPGRID():NEW()

	aObjSess[nPos]:OWSSCMPGUIA[1]:oWsaCols := PLSXFUN_ARRAYOFSTRING():NEW()
	aObjSess[nPos]:OWSSCMPGUIA[1]:oWsaHeader := PLSXFUN_ARRAYOFSTRING():NEW()

	aObjSess[nPos]:OWSSCMPGUIA[1]:oWsaCols := PLSXFUN_ARRAYOFSTRING():NEW()
	aObjSess[nPos]:OWSSCMPGUIA[1]:oWsaHeader := PLSXFUN_ARRAYOFSTRING():NEW()

	//AaDd( aObjSess[nPos]:OWSSCMPGUIA[1]:oWsaCols , PLSXFUN_ARRAYOFSTRING():NEW())
	//AaDd( aObjSess[nPos]:OWSSCMPGUIA[1]:oWsaHeader , PLSXFUN_ARRAYOFSTRING():NEW())
	aObjSess[nPos]:OWSSCMPGUIA[1]:cxCols := ""
	aObjSess[nPos]:OWSSCMPGUIA[1]:cxHeader := ""

	For nI := 1 To Len(aMntSess)
		aCpoAtu := StrToArray(aMntSess[nI],";") // FIELD_CAMPO (na pagina) | Descricao Coluna | Tipo

		//Adiciona os campos da Grid


		AaDd( aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:OWSSCmpGrid, PLSXFUN_SCMPGRID():NEW() )
		aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[nI]:cTipo := IIf(Len(aCpoAtu) >= 3,aCpoAtu[3],"C")
		aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[nI]:cNome := aCpoAtu[1]
		aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[nI]:cDescri := aCpoAtu[2]
	Next nI
	HttpSession->aCmpGuia := aClone(aObjSess[nPos]:OWSSCMPGUIA)
EndIf


//Encontra o objeto no array de campos

nPos := aScan( HttpSession->aCmpGuia, { |x| x:cNome == cGrid} )


//Monta o aCols e aHeader

If nPos > 0

	cResult := "true|" +	 cGrid + "|" + nOpc + "|["
	nLen := len(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID)

	For nI := 1 to nLen

		// Verifica se foi informado funcao de tratamento na linha

		cResult += "'" + alltrim(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID[nI]:CNOME) + "'" + Iif( nLen != nI ,",","]|" )
	Next nI
	cResult += + cRecno + "|" + lBotao + "|" + cSt + "|"  + cValores + "|" + cCampoDefault + "|" + cLarBrw + "|" + cAltBrw + "|" + cUpdReg + "|" + cNoLpCamp + "|"
Else
	cResult := "false|Não foi encontrado o grid especificado!"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGETGRID
Responsável pela manipulação dos grids das Guias no Portal
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGGRID()
LOCAL oObj 		:= NIL

LOCAL nI			:= 0
LOCAL nJ			:= 0
LOCAL nLen			:= 0
LOCAL nLenVal		:= 0
LOCAL nPos			:= 0
LOCAL nOpc 		:= 0
LOCAL nPosCols	:= 0
LOCAL nRecno		:= 0
LOCAL nLenCols	:= 0
LOCAL nQtdReg		:= 1
LOCAL nQtdPag 	:= 1
LOCAL nRegPagina 	:= 1

LOCAL cResult  	:= ""
LOCAL cGrid		:= ""
LOCAL xHeader 	:= "[{}]"
LOCAL xCols		:= ""

//Variaveis a utilizar posteriormente
LOCAL cPesquisa	:= ""
LOCAL cMsg			:= ""

LOCAL aCampos		:= Separa ( HttpGet->cCmp, "," , .T.)
LOCAL aValores	:= Separa ( HttpGet->cValores, "@" , .F.)
LOCAL aHeader		:= {}
LOCAL aCols		:= {}
LOCAL aLinha		:= {}

LOCAL cLinhas		:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// HttpSession->aCmpGuia -> Guarda todos os campos/grids da Guia
// HttpSession->aCmpGuia[nPos] -> Trata-se da referência a um campo ou grid
//
// HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING -> aHeader do Grid
// HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING -> aCols do Grid
//
// xCols e xHeader são as strings que o JSPLS usará para montar o grid
// aCols e aHeader são os arrays que serão utilizados para manipular os campos
//por esta função



//Recupera dados da página

cGrid := HttpGet->cGrid
nRecno := HttpGet->nRecno
nOpc := Val(HttpGet->nOpc)
lBotao := HttpGet->lBotao
cSt := HttpGet->cSt
cValores	:= HttpGet->cValores
cUpdReg 	:= HttpGet->cUpdReg

If HttpSession->cLarGrd == NIL
	HttpSession->cLarGrd := HttpGet->cLarBrw
Endif

If HttpSession->cAltGrd == NIL
	HttpSession->cAltGrd := HttpGet->cAltBrw
Endif


//Encontra o objeto no array de campos

nPos := aScan( HttpSession->aCmpGuia, { |x| x:cNome == cGrid} )


//Monta o aCols e aHeader

If nPos > 0

	aHeader	:= HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING
	aCols		:= HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING


	//Verifica se o aCols e aHeader estão vazios

	If ValType(aHeader) <> 'A'
		aHeader := {}
		HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING := {}
	EndIf
	If ValType(aCols) <> 'A'
		aCols := {}
		HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING := {}
	EndIf


	//Adiciona no aCols ou Posiciona na linha da alteração

	If nOpc == 3

		aAdd(aCols,{})
		aAdd(aHeader,{})
		nPosCols := Len(aCols)

	ElseIf nOpc == 4 .OR. nOpc == 5
		nPosCols := Val(nRecno)

	ElseIf nOpc == 6
		xCols := ""
		xHeader := "[{}]"
		nQtdReg := 0
		aCols := {}
		aHeader := {}
	EndIf

	If nPosCols > 0

		If nOpc == 5

			//Exclui registro

			If Len(aCols) > 0
				aDel(aCols,nPosCols)
				aSize(aCols,Len(aCols)-1)
				aDel(aHeader,nPosCols)
				aSize(aHeader,Len(aHeader)-1)
			EndIf

		Else

			//Inicia o xHeader e o xCols

			xHeader := "["

			If 	Empty(HttpSession->aCmpGuia[nPos]:CXCOLS)
				xCols := "[{"
			Else
				xCols := HttpSession->aCmpGuia[nPos]:CXCOLS
				xCols := Left(xCols,Len(xCols)-1) + ",{"
			EndIf


			//Adiciona os botões da linha e coloca o Recno

			If cUpdReg == "0"
				xHeader += "{name:'Excluir'},"
				xCols += "0:{field:'RECNO', value:'0#" + AllTrim(Str(nPosCols)) + "," + cGrid + ".id,5,undefined,undefined,undefined,undefined,undefined,undefined, undefined, (0).toString()'},"

			Else
				xHeader += "{name:'Alterar'},"
				xCols += "0:{field:'RECNO', value:'0#" + AllTrim(Str(nPosCols)) + "," + cGrid + ".id,4'},"
				xHeader += "{name:'Excluir'},"
				xCols += "1:{field:'RECNO', value:'1#" + AllTrim(Str(nPosCols)) + "," + cGrid + ".id,5'},"
			EndIf


			//Monta xHeader e xCols

			nLen := len(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID)
			nLenVal := len(aValores)
			For nI := 1 to nLenVal
				aLinha := Separa(aValores[nI],",",.F.)
				For nJ := 1 to nLen

					cCampo  := alltrim(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID[nJ]:CNOME)
					cTitulo := alltrim(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID[nJ]:CDESCRI)


					// Verifica se o campo já tem algum valor

					nPosVal := aScan(aLinha , { |x| cCampo $ x } )
					If nPosVal > 0
						cValor	 := Separa(aLinha[nPosVal],"$",.T.)[2]
					Else
						cValor := ""
					EndIf


					// Cabecalho

					xHeader += "{name:'" + cTitulo + "'}" + Iif( nLen != nJ ,",","]" )

					If nOpc == 3  // Inclui registro

						aAdd(aCols[nPosCols],cValor)
						aAdd(aHeader[nPosCols],cCampo)
						If cUpdReg == "0"
							xCols += cValToChar((nJ)) + ":{field:'"+cCampo+"', value:'" + /*cBtnPos +*/ cValor + "'} " + Iif( nLen != nJ ,",","}]" )
						Else
							xCols += cValToChar((nJ+1)) + ":{field:'"+cCampo+"', value:'" + /*cBtnPos +*/ cValor + "'} " + Iif( nLen != nJ ,",","}]" )
						EndIf

					ElseIf nOpc == 4//Altera Registro

						aCols[nPosCols][nJ] := cValor

					EndIf
				Next nJ
				If nLen > 0 .AND. nOpc == 3
					aAdd(aCols[nPosCols],cSt)
					aAdd(aHeader[nPosCols],"Marca")
				EndIf
			Next nI
		EndIf
	EndIf


	//Se for alteração, reconstroi o xCols

	If nOpc == 4 .OR. nOpc == 5

		xHeader := "[{name:'Excluir'},"


		//Monta xHeader e xCols

		nLen := len(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID)
		nLenVal := len(aValores)
		For nI := 1 to nLenVal
			For nJ := 1 to nLen

				cTitulo := alltrim(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID[nJ]:CDESCRI)


				// Cabecalho

				xHeader += "{name:'" + cTitulo + "'}" + Iif( nLen != nJ ,",","]" )

			Next nJ
		Next nI

		nLenCols := Len(aCols)
		If nLenCols > 0
			xCols := "[{
			For nI := 1 to nLenCols

				If cUpdReg == "0"
					xCols += "0:{field:'RECNO', value:'0#" + AllTrim(Str(nI)) + "," + cGrid + ".id,5,undefined,undefined,undefined,undefined,undefined,undefined, undefined, (0).toString()'}," //Botão Excluir
				Else
					xCols += "0:{field:'RECNO', value:'0#" + AllTrim(Str(nI)) + "," + cGrid + ".id,2'}," //Botão Alterar
					xCols += "1:{field:'RECNO', value:'1#" + AllTrim(Str(nI)) + "," + cGrid + ".id,5'}," //Botão Excluir
				EndIf
				nLenHeader := Len(aHeader[nI])-1
				For nJ := 1 to nLenHeader
					xCols += cValToChar((nJ+1)) + ":{field:'"+ aHeader[nI][nJ]+ "', value:'" + aCols[nI][nJ] + "'} " + Iif( nLenHeader != nJ ,",","}" )
				Next nJ
				xCols += Iif( nLenCols != nI ,",{","]" )

			Next nI
			nQtdReg		:= 1
			nQtdPag 		:= 1
			nRegPagina 	:= 1
		Else
			xCols := ""
			xHeader := "[{}]"
			nQtdReg		:= 0
		EndIf

	EndIf
	//Indica que a linha deve ser marcada
	nLenCols := len(aCols)
	nLen := len(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID)
	For nI := 1 to nLenCols
		If aCols[nI][nLen+1] <> "1"
			cLinhas += AllTrim(str(nI))+"&"
		EndIf
	Next nI


	//Adiciona o xHeader e xCols ao array da session

	HttpSession->aCmpGuia[nPos]:CXHEADER := xHeader
	HttpSession->aCmpGuia[nPos]:CXCOLS   := xCols
	HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING := aClone(aHeader)
	HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING := aClone(aCols)


	cResult := "true|" +;
		cValToChar(nI-1) + "|" + ;
		cValToChar(nQtdPag) + "|" + ;
		cValToChar(nRegPagina) + "|" + ;
		xHeader + "|" +	;
		xCols + "|" + ;
		cMsg + "|" + ;
		"true"/* iIf(lContinua,'true','false')*/ + "|" + ;
		"1"/*cValToChar(nPaginaAtu)*/ + "|" + ;
		cPesquisa + "|" + ;
		"true"/* iIf(lCSemafo,'true','false') */ + "|" + ;
		cGrid + "|" + ;
		AllTrim(Str(nOpc)) + "|" +;
		HttpGet->cCmp + "|" +;
		lBotao + "|" +;
		cSt + "|" +;
		cLinhas + "|" +;
		HttpSession->cLarGrd + "|" +;
		HttpSession->cAltGrd + "|" +;
		cUpdReg + "|"
Else
	cResult := "false|Não foi encontrado o grid especificado!"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)


/*/{Protheus.doc} PLPUTREEMB
Istancia o webservice para gravacao da solicitacao de reemb
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PLPUTREEMB()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL nI			:= 0
LOCAL nSumTot		:= 0
LOCAL Arda			:= {}
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= HttpGet->cCODUSU
oObj:cCpfCnpj		:= HttpGet->cCODRDA
oObj:cMatUsu		:= HttpGet->cBENEF
oObj:dDatDoc		:= CTOD(HttpGet->cDTDOC)
oObj:cNomRdaNRef	:= HttpGet->cNOMRDA
oObj:cTelefone	:= StrTran(StrTran(HttpGet->cTELEFONE,"(",""),")","")

If !EMPTY(httpget->ccodrda)
	Arda := separa(HttpGet->cCODRDA)
EndIf

oObj:OWSITENSREEMB:OWSLISTDESP := PLSXFUN_ARRAYOFSITENSREEMB():New()

For nI := 1 To Len(HttpSession->aCmpGuia[1]:OWSACOLS:cString)
	AaDd( oObj:OWSITENSREEMB:OWSLISTDESP:oWSSITENSREEMB, PLSXFUN_SITENSREEMB():New() )
	nQtd := Len( oObj:OWSITENSREEMB:OWSLISTDESP:oWSSITENSREEMB )
	oObj:OWSITENSREEMB:OWSLISTDESP:oWSSITENSREEMB[nQtd]:cCODPRO 	:= HttpSession->aCmpGuia[1]:OWSACOLS:cString[nI,7]
	oObj:OWSITENSREEMB:OWSLISTDESP:oWSSITENSREEMB[nQtd]:cCODRDA 	:= Arda[nI]
	oObj:OWSITENSREEMB:OWSLISTDESP:oWSSITENSREEMB[nQtd]:cEnviaRec 	:= ""
	oObj:OWSITENSREEMB:OWSLISTDESP:oWSSITENSREEMB[nQtd]:cIsMedic 	:= IIf(HttpSession->aCmpGuia[1]:OWSACOLS:cString[nI,3] == "S", "1","0")
	oObj:OWSITENSREEMB:OWSLISTDESP:oWSSITENSREEMB[nQtd]:cTipDoc    := HttpSession->aCmpGuia[1]:OWSACOLS:cString[nI,4]
	oObj:OWSITENSREEMB:OWSLISTDESP:oWSSITENSREEMB[nQtd]:cNroDoc 	:= HttpSession->aCmpGuia[1]:OWSACOLS:cString[nI,5]
	oObj:OWSITENSREEMB:OWSLISTDESP:oWSSITENSREEMB[nQtd]:cUsoC 		:= HttpSession->aCmpGuia[1]:OWSACOLS:cString[nI,3]
	oObj:OWSITENSREEMB:OWSLISTDESP:oWSSITENSREEMB[nQtd]:cVlrPro		:= HttpSession->aCmpGuia[1]:OWSACOLS:cString[nI,2]
	oObj:OWSITENSREEMB:OWSLISTDESP:oWSSITENSREEMB[nQtd]:cQTDPRO 	:= HttpSession->aCmpGuia[1]:OWSACOLS:cString[nI,8]
	oObj:OWSITENSREEMB:OWSLISTDESP:oWSSITENSREEMB[nQtd]:dDatDoc		:= CTOD(HttpSession->aCmpGuia[1]:OWSACOLS:cString[nI,9])
	oObj:OWSITENSREEMB:OWSLISTDESP:oWSSITENSREEMB[nQtd]:cEstd		:= HttpSession->aCmpGuia[1]:OWSACOLS:cString[nI,10]
	oObj:OWSITENSREEMB:OWSLISTDESP:oWSSITENSREEMB[nQtd]:cCodMun		:= HttpSession->aCmpGuia[1]:OWSACOLS:cString[nI,11]
	oObj:OWSITENSREEMB:OWSLISTDESP:oWSSITENSREEMB[nQtd]:cSeqRec		:= HttpSession->aCmpGuia[1]:OWSACOLS:cString[nI,12]
	oObj:OWSITENSREEMB:OWSLISTDESP:oWSSITENSREEMB[nQtd]:cNomRDA		:= HttpSession->aCmpGuia[1]:OWSACOLS:cString[nI,6]

	nSumTot += Val(HttpSession->aCmpGuia[1]:OWSACOLS:cString[nI,2] ) * Val(HttpSession->aCmpGuia[1]:OWSACOLS:cString[nI,8]) //Quantidade vezes valor
Next nI

oObj:cVlrApr		:= Alltrim(Str(nSumTot))


//Atribui dados ao obj



// Retorna dados

If oObj:PutReembBen()
	cResult += oObj:cPutReembBenRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCONREE
Chamada da Rotina de Reembolso Portal beneficiario
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCONREE()
LOCAL cHtml	  := ""

PRIVATE lMultComp	:= HttpSession->lMultComp
PRIVATE lBaixar		:= HttpSession->lBaixar
PRIVATE cCodSol 	:= iif(valtype(HttpGet->cCodSol) <> "U", 	HttpGet->cCodSol, "")
PRIVATE cRDA 		:= iif(valtype(HttpGet->cRdaNoRef) <> "U", 	HttpGet->cRdaNoRef, "")
PRIVATE cNomePres 	:= iif(valtype(HttpGet->cNomePres) <> "U", 	HttpGet->cNomePres, "")
PRIVATE cTipDoc 	:= iif(valtype(HttpGet->cTipDoc) <> "U", 	HttpGet->cTipDoc, "")
PRIVATE cNumDoc 	:= iif(valtype(HttpGet->cNumDoc) <> "U", 	HttpGet->cNumDoc, "")
PRIVATE cDatDoc 	:= iif(valtype(HttpGet->cDatDoc) <> "U", 	HttpGet->cDatDoc, "")
PRIVATE cRecno 		:= iif(valtype(HttpGet->cRecno) <> "U", 	HttpGet->cRecno, "")

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLCONREE")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLGDGRID
Retorna dados para o browse gridData
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGDGRID()
LOCAL cResult  	:= "true|"
LOCAL cRdas		:= ""
LOCAL cUsuarios	:= ""
LOCAL oObj		:= NIL
local lUSR_INFO	:= type('HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA') == "U"
LOCAL nI		:= 0
LOCAL nLen		:= IIf(Valtype(HttpSession->RDAVIEW) == "A", Len(HttpSession->RDAVIEW), 0 ) //Tratamento para a existencia das RDAs (a função eh chamada antes do login para consulta rede credenciada)
LOCAL cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

// Metodo e propriedades
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//HttpSession->RDAVIEW
For nI := 1 to nLen

	If ! Empty(cRdas)
		cRdas += ","
	EndIf

	cRdas += "'" + HttpSession->RDAVIEW[nI]:cCodOpe + HttpSession->RDAVIEW[nI]:cCode +"'"

Next nI

//Tratamento para a existencia das RDAs (a função eh chamada antes do login para consulta rede credenciada)
If nLen > 0
	httpGet->cWhere += "|"+"Field_RDA=" + cRdas
EndIf

If ! lUSR_INFO .and. len(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA) > 0 //Essa verificação foi inserida, para casos em que o usuário logado ainda não é beneficiário

	// Beneficiario Logado (Portal do beneficiario) --> Pega o principal pois tem apenas um login
	If ValType(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA) == "A"

		If ValType(httpGet->cUsuari) <> 'U'

			httpGet->cWhere += "|"+"Field_USUARI=" + httpGet->cUsuari

		Else
			For nI := 1 to Len(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA)

				If ! Empty(cUsuarios)
					cUsuarios += ","
				EndIf

				cUsuarios += "'" + HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[nI]:cCode +"'"

			Next nI

			httpGet->cWhere += "|"+"Field_USUARI=" + cUsuarios
		EndIf

	EndIf

EndIf

oObj:cUserCode		:= "MSALPHA"
oObj:cFunName		:= httpGet->cFunName
oObj:cWhere 		:= httpGet->cWhere
oObj:cBuscaTReg		:= httpGet->cBuscaTReg
oObj:cPesquisa		:= iIf(valType(httpGet->cPesquisa)=='U',"",httpGet->cPesquisa)
oObj:cSemaforo		:= iIf(valType(httpGet->cSemaforo)=='U',"",httpGet->cSemaforo)
oObj:nPaginaIni		:= val(httpGet->nPagina)
oObj:cCamposCustom 	:= iIf(valType(httpGet->cCampoCustom)=='U',"",httpGet->cCampoCustom)

// Lista de faturas
If oObj:getDadGrid()
	cResult +=	oObj:cGETDADGRIDRESULT
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

//Log BSW para LGPD
if ValType(httpGet->cRotinLGPD) <> "U"
	oObj:cUserCode	 := "MSALPHA"
	oObj:cUserLGPD   := HttpSession->USR_INFO[1]:cUserLogin
	oObj:cRotinLGPD  := httpGet->cRotinLGPD
	oObj:LogLGPD()
endIf

WEB EXTENDED END

getLOGMon()

return PLSDECODE(cResult)

/*/{Protheus.doc} PPLOBSPRT
Retorna a observação do protocolo selecionado
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLOBSPRT()
LOCAL cResult  	:= "true|"
LOCAL cRecno  := HttpGet->cRecno
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )


// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:CcRecno	:= cRecno
oObj:cTipo :=  iif(ValType(HttpGet->cTipo) <> "U", HttpGet->cTipo, "")

If oObj:OBSPROTOC()

	xCols := oOBJ:OWSOBSPROTOCRESULT:OWSSRETOBSPROT[1]:CcMsg

	cResult += xCols + "|"
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLMSGEXC
Retorna o motivo da exclusão do item no protocolo
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLMSGEXC()
LOCAL cResult  	:= "true|"
LOCAL cRecno  := HttpGet->cRecno
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

// oBJ
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros
oObj:cUserCode	:= "MSALPHA"
oObj:CcRecno	:= cRecno

If oObj:ExcItmReemb()

	xCols :=  oObj:OWSEXCITMREEMBRESULT:OWSSRETITEEX[1]:CcMsg
	cResult += xCols + "|"
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLEXCREE
Exclui um item ou um reembolso
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLEXCREE()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cChave		:= iif(valtype(httpget->cChave) <> "U", httpget->cChave, "")
LOCAL cRecno		:= iif(valtype(httpget->cRecno) <> "U", httpget->cRecno, "")
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )


// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:ccRecno		:= cRecno
oObj:cAlias		:= HttpGet->cAlias
oObj:cChave		:= cChave


// Retorna dados

If oObj:ReembDelPI()
	cResult := oObj:cReembDelPIRESULT
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLRMBREC
Chamada da Rotina de Reembolso Portal beneficiario
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLRMBREC()
LOCAL cHtml 	:= ""
LOCAL cResult	:= ""


//Exibe pagina

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLRMBREC")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLATUBOW
 Atualiza BOW
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLATUBOW()
LOCAL cResult  	:= "true|"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )


// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:CUsrCod	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE

If !oObj:AtuBow()
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGETEST
Retorna os estados brasileiros no portal
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGETEST()
LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cTipo			:= HttpGet->cTipo

// Retorna dados

If oObj:DADRETEST() .OR. oObj:DADRETSIGLACR()

	If oObj:DADRETEST()
		nResult := Len(oObj:OWSDADRETESTRESULT:OWSSDADEST)

		xCols := "["
		For nI := 1 to nResult

			xCols += "{"
			xCols +=  "1:{field:'cDescri',value:'" +  SubStr(oObj:OWSDADRETESTRESULT:OWSSDADEST[nI]:CDESCRI,1,15) +"'}" + Iif( nResult != nI ,"},","}]" )
		Next

		cResult += xCols +"|"
	EndIF

	If oObj:DADRETSIGLACR()

		nResult := Len(oObj:OWSDADRETSIGLACRRESULT:OWSSDADSIGLACR)

		xCols := "["
		For nI := 1 to nResult

			xCols += "{"
			xCols +=  "1:{field:'cDescri',value:'" +  SubStr(oObj:OWSDADRETSIGLACRRESULT:OWSSDADSIGLACR[nI]:CDESCRI,1,15) +"'}" + Iif( nResult != nI ,"},","}]" )
		Next

		cResult += xCols +"|"
	EndIF

Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLRETGEN
Retorna os dados de uma tabela qualquer passada por param
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLRETGEN()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )


// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cCRecno		:= HttpGet->cRecno
oObj:cAlias		:= HttpGet->cAlias
oObj:cCampos		:= HttpGet->cCampos


// Retorna dados

If oObj:GetDadGen()
	cResult := oObj:cGetDadGenRESULT
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLEXPSEN
Verifica se exibe mensagem de Expirar Senha
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLEXPSEN()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

// oBJ
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros
oObj:cUserCode	:= "MSALPHA"
oObj:cPLSCodUsr	:= getUsrWeb()

// Retorna dados
if oObj:SenhaExp()
	cResult := oObj:cSenhaExpRESULT
endIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLDESPRO
Retorna a descrição do procedimento a partir do codigo
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLDESPRO()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )


// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cCodPro		:= HttpGet->cCodPro
oObj:cClasse		:= HttpGet->cClasse


// Retorna dados

If oObj:DesProc()
	cResult += oObj:cDesProcRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PTrGdLib
Trata a session de valores do grid ao chamar uma liberação
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function PTrGdLib(cValores,cGrid,nOpc,lAtuVisibl,lDelVisibl)
	LOCAL nI			:= 0
	LOCAL nJ			:= 0
	LOCAL nLen			:= 0
	LOCAL nLenVal		:= 0
	LOCAL nPos			:= 0
	LOCAL nPosCols		:= 0
	LOCAL nRecno		:= 0
	LOCAL nLenCols		:= 0
	LOCAL nQtdReg		:= 1
	LOCAL nQtdPag 		:= 1
	LOCAL nRegPagina 	:= 1

	LOCAL xHeader 	:= "[{}]"
	LOCAL xCols		:= ""

	//LOCAL aCampos		:= Separa ( HttpGet->cCmp, "," , .T.)
	LOCAL aValores	:= Separa ( cValores, "@" , .F.)
	LOCAL aHeader		:= {}
	LOCAL aCols		:= {}
	LOCAL aLinha		:= {}

	LOCAL cLinhas		:= ""
	LOCAL nNumAux		:= -1
	LOCAL cSt := "1"
	Default  lAtuVisibl	:= .T.
	Default  lDelVisibl	:= .T.
	Default  nOpc			:= 3
	Default cGrid		:= ""

	If ValType(HttpSession->aCmpGuia) == "U"
		Return()
	EndIf


	//Encontra o objeto no array de campos

	nPos := aScan( HttpSession->aCmpGuia, { |x| x:cNome == cGrid} )


	//Monta o aCols e aHeader

	If nPos > 0

		aHeader	:= HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING
		aCols	:= HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING


		//Verifica se o aCols e aHeader estão vazios

		If ValType(aHeader) <> 'A'
			aHeader := {}
			HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING := {}
		EndIf
		If ValType(aCols) <> 'A'
			aCols := {}
			HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING := {}
		EndIf


		//Adiciona no aCols ou Posiciona na linha da alteração

		If nOpc == 3

			aAdd(aCols,{})
			aAdd(aHeader,{})
			nPosCols := Len(aCols)

		ElseIf nOpc == 4 .OR. nOpc == 5
			nPosCols := Iif(ValType(nRecno) == "N", nRecno, Val(nRecno) )

		ElseIf nOpc == 6
			xCols := ""
			xHeader := "[{}]"
			nQtdReg := 0
			aCols := {}
			aHeader := {}
		EndIf

		If nPosCols > 0

			If nOpc == 5

				//Exclui registro

				If Len(aCols) > 0
					aDel(aCols,nPosCols)
					aSize(aCols,Len(aCols)-1)
					aDel(aHeader,nPosCols)
					aSize(aHeader,Len(aHeader)-1)
				EndIf

			Else

				//Inicia o xHeader e o xCols

				xHeader := "["

				If 	Empty(HttpSession->aCmpGuia[nPos]:CXCOLS)
					xCols := "["
				Else
					xCols := HttpSession->aCmpGuia[nPos]:CXCOLS
					xCols := Left(xCols,Len(xCols)-1) + ","
				EndIf


				//Monta xHeader e xCols

				nLen := len(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID)
				nLenVal := len(aValores)
				For nI := 1 to nLenVal
					aLinha := Separa(aValores[nI],";",.F.)
					nNumAux := -1
					If Len(aCols) < nPosCols+nI-1
						aAdd(aCols,{})
						aAdd(aHeader,{})
					EndIf
					For nJ := 1 to nLen

						If nJ == 1

							//Adiciona os botões da linha e coloca o Recno

							If (lAtuVisibl == .T.) .OR. (lDelVisibl == .T.)
								xCols += "{"
							EndIf
							If (lAtuVisibl == .T.)
								If nI == 1
									xHeader += "{name:'Alterar'},"
								EndIf
								nNumAux++
								//xCols += "{"
								xCols += cValToChar(nNumAux) + ":{field:'RECNO', value:'0#" + AllTrim(Str(nPosCols+nI-1)) + "," + cGrid + ".id,4'},"
							EndIf
							If (lDelVisibl == .T.)
								If nI == 1
									xHeader += "{name:'Excluir'},"
								EndIf
								nNumAux++
								//xCols += "{"
								xCols += cValToChar(nNumAux) + ":{field:'RECNO', value:'1#" + AllTrim(Str(nPosCols+nI-1)) + "," + cGrid + ".id,5,true," + '""' + " ," + '""' + " ,cCampoDefault'}," //Botão Excluir
							EndIf
						EndIf

						cCampo  := alltrim(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID[nJ]:CNOME)
						cTitulo := alltrim(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID[nJ]:CDESCRI)


						// Verifica se o campo já tem algum valor

						nPosVal := aScan(aLinha , { |x| cCampo $ x } )

						If nPosVal > 0

							If cCampo == "cProExe" .And. Separa(aLinha[nPosVal],"!",.T.)[1] == "cProExe"
								cValor	 := Separa(aLinha[nPosVal],"!",.T.)[2]
							Else
								cValor	 := Separa(aLinha[nPosVal],"$",.T.)[2]
							EndIf

						Else
							cValor := ""
						EndIf


						// Cabecalho

						If nI == 1
							xHeader += "{name:'" + cTitulo + "'}" + Iif( nLen != nJ ,",","]" )
						EndIf

						If nOpc == 3  // Inclui registro

							aAdd(aCols[nPosCols+nI-1],cValor)
							aAdd(aHeader[nPosCols+nI-1],cCampo)
							nNumAux++
							xCols += cValToChar(nNumAux) + ":{field:'"+cCampo+"', value:'" + /*cBtnPos +*/ cValor + "'} "

							If nLen != nJ
								xCols += ","
							Else
								xCols += "}"
								If nI != nLenVal
									xCols += ","
								Else
									xCols += "]"
								EndIf
							EndIf
						ElseIf nOpc == 4//Altera Registro

							aCols[nPosCols][nJ] := cValor

						EndIf
					Next nJ
					If nLen > 0
						If nOpc == 3
							aAdd(aCols[nPosCols+nI-1],cSt)
							aAdd(aHeader[nPosCols+nI-1],"Marca")
						ElseIf nOpc == 4
							aCols[nPosCols][len(aCols[nPosCols])] := cSt
						EndIf
					EndIf
				Next nI
			EndIf
		EndIf


		//Se for alteração, reconstroi o xCols

		If nOpc == 4 .OR. nOpc == 5
			nLenCols := Len(aCols)
			If nLenCols > 0
				xCols := "[{
				For nI := 1 to nLenCols
					nNumAux = -1
					If (lAtuVisibl == .T.)
						nNumAux++
						xCols += cValToChar(nNumAux) + ":{field:'RECNO', value:'0#" + AllTrim(Str(nI)) + "," + cGrid + ".id,2'}," //Botão Alterar
					EndIf
					If (lDelVisibl == .T.)
						nNumAux++
						xCols += cValToChar(nNumAux) + ":{field:'RECNO', value:'1#" + AllTrim(Str(nI)) + "," + cGrid + ".id,5,true," + '""' + " ," + '""' + " ,cCampoDefault'}," //Botão Excluir
					EndIf
					nLenHeader := Len(aHeader[nI])-1	//,true,cCampo.value,"",cCampoDefault.replace(/\|/g,",")
					For nJ := 1 to nLenHeader
						nNumAux++
						xCols += cValToChar(nNumAux) + ":{field:'"+ aHeader[nI][nJ]+ "', value:'" + aCols[nI][nJ] + "'} " + Iif( nLenHeader != nJ ,",","}" )
					Next nJ
					xCols += Iif( nLenCols != nI ,",{","]" )

				Next nI
				nQtdReg		:= 1
				nQtdPag 		:= 1
				nRegPagina 	:= 1
			Else
				xCols := ""
				xHeader := "[{}]"
				nQtdReg		:= 0
				//nQtdPag 	:= 0
				//nRegPagina 	:= 0
			EndIf

		EndIf
		//Indica que a linha deve ser marcada
		nLenCols := len(aCols)
		nLen := len(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID)
		For nI := 1 to nLenCols
			If aCols[nI][nLen+1] <> "1"
				cLinhas += AllTrim(str(nI))+"&"
			EndIf
		Next nI


		//Adiciona o xHeader e xCols ao array da session

		HttpSession->aCmpGuia[nPos]:CXHEADER := xHeader
		HttpSession->aCmpGuia[nPos]:CXCOLS   := xCols
		HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING := aClone(aHeader)
		HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING := aClone(aCols)
	EndIf

Return

/*/{Protheus.doc} PVldNGui
Verifica se a guia principal digitada existe
@Project
@version	P12
/*/
Web Function PVldNGui()
Local cResult := ""
Local oObj    := Nil
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUSERCODE 	:= "MSALPHA"
oObj:cTipGui	:= HttpGet->TipGui
oObj:cBenef	:= HttpGet->cNumCart
oObj:cNumAut   := StrTran(StrTran(HttpGet->NumAut,".",""),"-","")

If oObj:VLNUMGUI()
	cResult := oObj:CVLNUMGUIRESULT
Else
	cResult :=  "false|Erro na tentativa de localizar a guia!"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLDOC
Consulta o(s) contrato(s) e/ou aditivo(s)
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLDOC()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//Chama formulario

cHtml += ExecInPage("PPLDOC")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLDELAT
Exclui o atalho da barra de atalhos do portal
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLDELAT()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL nI := 1
LOCAL nTamI
LOCAL aAtalho     := {}
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

aAtalho := HttpSession->ATAVIEW
nTamI := Len(aAtalho)
lAchou := .F.

//oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cCodMenu		:= HttpGet->cCodMnu
oObj:cUsrCod		:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE

//Retorna dados

If oObj:DelAtalho()
	cResult := oObj:cDelAtalhoRESULT
EndIf

If  "true" $ cResult
	While nI <= nTamI .and. !lAchou
		If(aAtalho[nI][1] == HttpGet->cCodMnu)
			ADEL(HttpSession->ATAVIEW , nI)
			nTamI--
			ASIZE(HttpSession->ATAVIEW, nTamI)
			lAchou := .T.
		EndIf
		nI++
	EndDo

	aAtalho = HttpSession->ATAVIEW
	For nI := 1 To Len(aAtalho)
		cResult += "@" + aAtalho[nI][1] + "|" +  aAtalho[nI][2] + "|" + aAtalho[nI][3] + "|" + aAtalho[nI][4] + "|" + aAtalho[nI][5] + "|"
	Next nI
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGETIMG
Diretório de imagens do servidor
@author PLSTEAM
@since 10.2007
@version P12
/*/
WEB FUNCTION PPLGETIMG(cCodMnu)
LOCAL cResult  := "true|"
LOCAL cDir	 	:= getWebDir()
LOCAL aFiles	:= {}
LOCAL nI := 0
LOCAL nTpPor	:= 0
LOCAL cMenu := HttpGet->cCodMnu
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

nTpPor	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:nTpPortal

If !Empty(cDir)
	//verificar tipo de portal do usuario logado
	If nTpPor == 1
		cDir := cDir + getPrtSkin() + "\atalhos_portal\prestador\"
	Else
		cDir := cDir + getPrtSkin() + "\atalhos_portal\empbenef\"
	EndIf

	//Le diretorio para mostrar os arquivos disponiveis
	aFiles := DIRECTORY(cDir+"*.png")

	If Len(aFiles) <= 0
		cResult  :=  "true|Nofile"+cMenu
	Else
		cResult += cMenu + "|" + Alltrim(STR(nTpPor)) + "|"
	EndIf

Else
	cResult  := "true|Nodirectory"
EndIf

For nI := 1 To Len(aFiles)
	cResult += aFiles[nI][1] + "|"
Next nI

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLADDAT
Adiciona o atalho da barra de atalhos do portal
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLADDAT()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL aString
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//oBJ
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros
oObj:cUserCode	:= "MSALPHA"
oObj:cCodMenu		:= HttpGet->cCodMnu
oObj:cUsrCod		:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
oObj:cCamImg      := HttpGet->cCamImg
oObj:nCodPor      := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:nTpPortal

//Retorna dados
If oObj:AddAtalho()
	cResult := oObj:cADDATALHORESULT
EndIf

aString := strtokarr (cResult, "|")
ADEL(aString, 1)
ASIZE(aString, 5)

If  "true" $ cResult
	AADD(HttpSession->ATAVIEW, { AllTrim(aString[1]), AllTrim(aString[2]), AllTrim(aString[3]), AllTrim(aString[4]), AllTrim(aString[5]) })
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCADGEN
Pagina de cadastro de paginas genericas
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCADGEN()
LOCAL cHtml 	:= ""
LOCAL oObj	    := nil
LOCAL nI		:= 0
LOCAL nY		:= 0
LOCAL nJ 		:= 0
LOCAL cResult	:= ""
LOCAL cDataAux	:= ""
LOCAL cLayout	:= ""
LOCAL cRecno  	:= ""
LOCAL xCols   	:= ""
LOCAL xHeader 	:= ""
LOCAL cChave 	:= Alltrim(HttpGet->cChave)

WEB EXTENDED INIT cHtml START "InSite" /*IIF(cChave == "PLSCREDPF" .OR. cChave == "PLSCREDPJ", "","InSite")*/

if ( cChave == "PLSCREDPF" .or. cChave == "PLSCREDPJ" )
	cHtml += ExecInPage("PPLROTDESC")
else

	HttpSession->xDataAux := IIF( ValType( HttpGet->cDataAux ) == "C", HttpGet->cDataAux, "")

	//Obj
	oObj := WSPLCADWEB():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLCADWEB.APW" )

	// Parametro
	If ValType(HttpGet->cChave) <> "U"  //nas versoes 3.xx.xx esse cara vem preenchido
		cLayout := Alltrim(HttpGet->cChave)
	EndIf

	If ValType(HttpGet->cRecno) <> "U"  //nas versoes 3.xx.xx esse cara vem preenchido
		cRecno := Alltrim(HttpGet->cRecno)
	EndIf

	If ValType( HttpGet->cDataAux ) == "C"
		cDataAux := AllTrim(HttpGet->cDataAux)
	EndIf

	If ValType( HttpGet->cTipMan ) == "C" .And. cLayout == "PPLALTSOL" .And. HttpGet->cTipMan == "2"
		cLayout := "PPLALTB7L"
	EndIf

	oObj:cUSERCODE	:= "MSALPHA"
	oObj:oWSDataForm:cChaveLay	:= cLayout // Unidade de medida
	oObj:oWSDataForm:cRecnoReg 	:= cRecno
	oObj:oWSDataForm:cDataAux 	:= cDataAux
	If oObj:GetCmbForm()
		// ATRIBUO OS PARAMETROS NOVAMENTE PARA UTILIZAÇÃO DO PROXIMO METODO
		oObj:cUserCode	:= "MSALPHA"
		oObj:oWSDataForm:cChaveLay	:= cLayout // Unidade de medida
		oObj:oWSDataForm:cDadCombo	:= ""
		oObj:oWSDataForm:cRecnoReg 	:= cRecno
		oObj:oWSDataForm:cDataAux 	:= cDataAux
		If Len(oObj:OWSGETCMBFORMRESULT:OWSRETCMBS:OWSSRETCMBS) > 0 //oObj:OWSGETCMBFORMTRESULT:oWSRETCMBSGUIA
			For nI:=1 To Len(oObj:OWSGETCMBFORMRESULT:OWSRETCMBS:OWSSRETCMBS)
				cStrCBOX := ""
				If "HTTPSESSION" $ Upper(oObj:OWSGETCMBFORMRESULT:OWSRETCMBS:OWSSRETCMBS[nI]:cCBOX)	 // Se for uma Session eu pego CCODE e CNAME e monto o Combo
					If ValType(&(oObj:OWSGETCMBFORMRESULT:OWSRETCMBS:OWSSRETCMBS[nI]:cCBOX)) <> 'U'
						For nY := 1 To Len(&(oObj:OWSGETCMBFORMRESULT:OWSRETCMBS:OWSSRETCMBS[nI]:cCBOX))
							cStrCBOX += Alltrim(&(oObj:OWSGETCMBFORMRESULT:OWSRETCMBS:OWSSRETCMBS[nI]:cCBOX + "[" + Alltrim(Str(nY)) + "]:cCODE")) + "=" +;
								Alltrim(&(oObj:OWSGETCMBFORMRESULT:OWSRETCMBS:OWSSRETCMBS[nI]:cCBOX + "[" + Alltrim(Str(nY)) + "]:cNAME")) + ";"
						Next nY
					EndIf
					If nY > 2
						cStrCBOX += ";="//cStrCBOX += ";=-- Selecione um item --"
					EndIf
				Else // Caso contrario eu pego a STRING com mesma estrutura do X3_COBX
					cStrCBOX := Alltrim(oObj:OWSGETCMBFORMRESULT:OWSRETCMBS:OWSSRETCMBS[nI]:cCBOX)
				EndIf
				If SubStr(cStrCBOX, Len(cStrCBOX),1) == ";"
					cStrCBOX := SubStr(cStrCBOX, 1, Len(cStrCBOX)-1)
				EndIf
				oObj:oWSDataForm:cDadCombo	+= Alltrim(oObj:OWSGETCMBFORMRESULT:OWSRETCMBS:OWSSRETCMBS[nI]:cCampoG) + ";" + cStrCBOX + "|"
				//WSDATA RetCmbsGuia	AS Array Of SRetCmbsGuia OPTIONAL
			Next
		EndIf

		If SubStr(oObj:oWSDataForm:cDadCombo, Len(oObj:oWSDataForm:cDadCombo),1) == "|"
			oObj:oWSDataForm:cDadCombo := SubStr(oObj:oWSDataForm:cDadCombo, 1, Len(oObj:oWSDataForm:cDadCombo)-1)
		EndIf

		// Retorna dados da pagina
		oObj:oWSDataForm:cTpPortWS	:= iif( valtype(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:nTpPortal) == "U", "3", cvaltochar(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:nTpPortal) )
		If oObj:GetForm()
			cResult :=  oObj:OWSGETFORMRESULT:cPagina
			If ValType(oObj:OWSGETFORMRESULT:cGrids) == "C"
				HttpSession->cGrids := oObj:OWSGETFORMRESULT:cGrids
			EndIf


			If ValType(oObj:OWSGETFORMRESULT:OWSCMPS:oWSSCmps) == "A" /*/:OWSCMPGUIA:OWSSCMPGUIA)*/
				HttpSession->aCmpGuia := aClone(oObj:OWSGETFORMRESULT:OWSCMPS:oWSSCmps)
			EndIf

			If ValType(oObj:OWSGETFORMRESULT:OWSCONTGRID:OWSAGRIDS) == "A" .AND. len(oObj:OWSGETFORMRESULT:OWSCONTGRID:OWSAGRIDS) > 0

				For nI := 1 to Len(oObj:OWSGETFORMRESULT:OWSCONTGRID:OWSAGRIDS)
					cGrid := oObj:OWSGETFORMRESULT:OWSCONTGRID:OWSAGRIDS[nI]:cGrid
					xCols := oObj:OWSGETFORMRESULT:OWSCONTGRID:OWSAGRIDS[nI]:cXCols
					xHeader := oObj:OWSGETFORMRESULT:OWSCONTGRID:OWSAGRIDS[nI]:cXHeader

					nPos := aScan( HttpSession->aCmpGuia, { |x| x:cNome == cGrid} )

					If nPos > 0

						aHeader	:= HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING
						aCols		:= HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING

						HttpSession->aCmpGuia[nPos]:CXCOLS := xCols
						HttpSession->aCmpGuia[nPos]:CXHEADER := xHeader


						//Verifica se o aCols e aHeader estão vazios

						If ValType(aHeader) <> 'A'
							aHeader := {}
							HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING := {}
						EndIf
						If ValType(aCols) <> 'A'
							aCols := {}
							HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING := {}
						EndIf

						For nJ := 1 to Len(oObj:OWSGETFORMRESULT:OWSCONTGRID:OWSAGRIDS[nI]:OWSAHEADER:OWSSSTRGRID)
							aAdd(HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING, oObj:OWSGETFORMRESULT:OWSCONTGRID:OWSAGRIDS[nI]:OWSAHEADER:OWSSSTRGRID[nJ]:OWSVALORES:CSTRING)
							aAdd(HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING, oObj:OWSGETFORMRESULT:OWSCONTGRID:OWSAGRIDS[nI]:OWSACOLS:OWSSSTRGRID[nJ]:OWSVALORES:CSTRING)
						Next nJ

					EndIf

				Next nI
			EndIf

			//Executa os inicializadores dos campos
			nIni := At("<%=",cResult)
			While  nIni > 0
				nFim := At("%>",cResult)
				cComando := SubStr(cResult,nIni+3,nFim - nIni-3)
				xResult := &(cComando)

				cTipResult := ValType(xResult)
				Do Case
					Case cTipResult == "D"
						xResult := DtoS(xResult)
						xResult := SubStr(xResult,7,2) + "/" + SubStr(xResult,5,2) + "/" + SubStr(xResult,1,4)
					Case cTipResult == "N"
						xResult := Alltrim(Str(xResult))
				EndCase

				cResult := StrTran ( cResult, "<%=" + cComando + "%>", xResult) //, nIni, 1)
				nIni := At("<%=",cResult)
			EndDo

		EndIf

		HttpSession->cPaginaForm := Substr(cResult,At("|",cResult)+1,Len(cResult)) // Retiro o true| ou o false|
	EndIf

	//Log BSW para LGPD
	if ValType(httpGet->cRotinLGPD) <> "U"
		oObj:cUserCode	 := "MSALPHA"
		oObj:cUserLGPD   := HttpSession->USR_INFO[1]:cUserLogin
		oObj:cRotinLGPD  := httpGet->cRotinLGPD
		oObj:LogLGPD()
	endIf

	cHtml += ExecInPage("PPLCADGEN")

endif

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCONPRO
Consulta o(s) protocolos de indicações de profissionais
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCONPRO()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//Chama formulario

cHtml += ExecInPage("PPLCONPRO")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLSolCon
Chamada da Página de Solicitação de alteração contratual
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSolCon()

LOCAL cHtml := ""

local cCodRda	:= httpget->cRDACod

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->CodRDAsolCon := StrZero(Val(cCodRda), 6)

//Chama formulario

cHtml += ExecInPage("PPLSOLCONTR")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLGRVGEN
Verifica se exibe mensagem de Expirar Senha
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGRVGEN()
LOCAL oObj 			:= NIL
LOCAL cResult  		:= ""
LOCAL aAux			:= {}
LOCAL aAux2			:= {}
LOCAL aHeader		:= {}
LOCAL aCols			:= {}
LOCAL nI			:= 0
LOCAL nL			:= 0
LOCAL nR			:= 0
LOCAL cAliAtu		:= ""
LOCAL aDadGri		:= {}
LOCAL cHtml 		:= ""
WEB EXTENDED INIT cHtml START "InSite"

// oBJ
oObj := WSPLCADWEB():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLCADWEB.APW" )

// Parametros
oObj:cUserCode	:= "MSALPHA"
oObj:oWSDataInput:cChaveLay	:= HttpPost->cChvLay
oObj:oWSDataInput:cRecnus	:= HttpPost->cRecnus
oObj:oWSDataInput:cRecnoReg	:= HttpPost->cRecnoReg
oObj:oWSDataInput:cUserLogin:= IIF(Valtype(HttpSession->USR_INFO) == "U", "" , HttpSession->USR_INFO[1]:CUSERLOGIN)
oObj:cDataAux					:= IIF(ValType(HttpSession->xDataAux) == "C", HttpSession->xDataAux, "")

//Adicionando Session do Tipo do Portal e Matricula.
IF !(Valtype(HttpSession->USR_INFO) == "U")
	oObj:oWSDataInput:cTpPortal := IIF(Valtype(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:nTpPortal) == "U", "" , str(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:nTpPortal))

	if alltrim(str(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:nTpPortal)) <> "2" .AND. Len(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA) > 0
		if HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1] <> nil .and. HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1] <> nil .and. ;
				HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1] <> nil .and. HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1] <> nil .and. ;
				HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1] <> nil .and. HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CCODE <> nil

			oObj:oWSDataInput:cMatric := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CCODE
		endif
	endif
EndIf

oObj:oWSDataInput:oWSDados := PLCADWEB_ARRAYOFSCmpVlr():New()
//oObj:oWSAUTHORIZATION:oWSAUTITEM := PLSXMOV_ARRAYOFAUTITEMVIEW():New()

// Cabeçalho
If !Empty(HttpPost->cCampos)
	aAux := StrToArray(Alltrim(HttpPost->cCampos) , "|")
	For nI := 1 To Len(aAux)
		If ";" $ aAux[nI]
			cAliAtu := StrToArray(aAux[nI] , ";")[1]
			aAux[nI] := StrToArray(aAux[nI] , ";")[2]
		EndIf
		AaDd( oObj:oWSDataInput:oWSDados:oWSSCmpVlr, PLCADWEB_SCMPVLR():New() )
		oObj:oWSDataInput:oWSDados:oWSSCmpVlr[nI]:cTipo := ""
		oObj:oWSDataInput:oWSDados:oWSSCmpVlr[nI]:cCampo := aAux[nI]
		//o sinal + é interpretado como espaço em HTML, sendo necessário o ajuste abaixo, no campo e-mail
		If (aAux[nI] == 'cBA1_CPFUSR') 
			oObj:oWSDataInput:oWSDados:oWSSCmpVlr[nI]:cValor := replace(replace(AllTrim(HttpPost->cBA1_CPFUSR), "-", ""), ".", "")
		elseIf (aAux[nI] == 'cBA1_CEPUSR') 
			oObj:oWSDataInput:oWSDados:oWSSCmpVlr[nI]:cValor := replace(AllTrim(HttpPost->cBA1_CEPUSR), "-", "")
		elseIf (aAux[nI] == 'cBA1_TELEFO') 
			oObj:oWSDataInput:oWSDados:oWSSCmpVlr[nI]:cValor := replace(AllTrim(HttpPost->cBA1_TELEFO), "-", "") 
		else 
			oObj:oWSDataInput:oWSDados:oWSSCmpVlr[nI]:cValor := &("HttpPost->" + aAux[nI]) // macro do campo que veio do post
		endIf
		oObj:oWSDataInput:oWSDados:oWSSCmpVlr[nI]:cTabela := cAliAtu
		oObj:oWSDataInput:oWSDados:oWSSCmpVlr[nI]:cSeqGrid := "" // no cabeçalho eu nao preciso da sequencia
	Next nI
EndIf
// Grids
If !Empty(HttpPost->cGrids)
	aAux := StrToArray(Alltrim(HttpPost->cGrids) , "@") // Aqui eu separo cada Grid contido na pagina
	For nI := 1 To Len(aAux)
		aAux2 := StrToArray(Alltrim(aAux[nI]) , "~") // Separo dados do Grid
		AADD(aDadGri, {aAux2[1], aAux2[2], aAux2[3]}) // Nome do Grid, Tabela, Campos
	Next nI

	For nL := 1 To Len(aDadGri)
		nPos := aScan( HttpSession->aCmpGuia, { |x| x:cNome == aDadGri[nL,1]} )
		aAux := StrToArray (StrToArray(aAux2[3] , "|")[1],",") // Pego os campos do Grid
		aHeader	:= HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING
		aCols		:= HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING
		For nI := 1 To Len(aCols)
			For nR := 1 To Len(aHeader[1]) - 1 // Tiro o campo "marca" do Header
				AaDd( oObj:oWSDataInput:oWSDados:oWSSCmpVlr, PLCADWEB_SCMPVLR():New() )
				nPosAtu := Len(oObj:oWSDataInput:oWSDados:oWSSCmpVlr)
				oObj:oWSDataInput:oWSDados:oWSSCmpVlr[nPosAtu]:cTipo := ""
				oObj:oWSDataInput:oWSDados:oWSSCmpVlr[nPosAtu]:cCampo := aHeader[1,nR]
				oObj:oWSDataInput:oWSDados:oWSSCmpVlr[nPosAtu]:cValor := aCols[nI,nR]
				oObj:oWSDataInput:oWSDados:oWSSCmpVlr[nPosAtu]:cTabela := aDadGri[nL,2]
				oObj:oWSDataInput:oWSDados:oWSSCmpVlr[nPosAtu]:cSeqGrid := Alltrim(Str(nI))
			Next nR
		Next nI
	Next nL
EndIf

If oObj:GrvForm()
	cResult := oObj:cGrvFormRESULT
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLVIEWRDA
Verifica se RDA possui mais de uma RDA.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLVIEWRDA()

LOCAL cHtml := ""
LOCAL cResult := "true|"
LOCAL nI := 0

WEB EXTENDED INIT cHtml START "InSite"


//Chama formulario

If ValType(HttpSession->RDAVIEW) <> "U"
	If len(HttpSession->RDAVIEW) > 1
		cHtml += 	"<label>RDA</label>"
		cHtml += 	"<select id='cRdaRec' name='cRdaRecno' class='form-control TextoInputOB ComboSelectOB'>"
		cHtml += 		"<option value='SELECTED'>-- Selecione uma RDA --</option>"

		//Preciso pegar o tipo de pessoa (fisica ou juridica) para redirecionar para o layout certo
		For nI:=1 To Len( HttpSession->RDAVIEW )

			//Nao inclui registro duplicado

			if at("> "+ allTrim(HttpSession->RDAVIEW[nI]:cNAME) + " <" ,cHTML) == 0
				cHtml += "<option value='" + alltrim(str(HttpSession->RDAVIEW[nI]:nRdaRecno) + HttpSession->RDAVIEW[nI]:cTipPE) + "'> " + AllTrim(HttpSession->RDAVIEW[nI]:cNAME) + " </option>"
			endIf
		Next nI

		cHtml += 	"</select>"

		cResult += "Selecione uma RDA|" + cHtml + "|" + "@Confirmar~ loadAltCadRda();@Cancelar~$('#closeModal').click();"
	Else
		cResult := "true|REDIRECIONAR|" + STR(HttpSession->RDAVIEW[1]:nRdaRecno) + "|" + Upper(AllTrim(HttpSession->RDAVIEW[1]:cTipPE))
	Endif
Else
	cResult := "false|Erro ao processar RDA's"
Endif

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PLENVADT
Consulta o(s) contrato(s) e/ou aditivo(s)
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PLENVADT()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->RetSeqACad := HttpGet->cCodSeq
HttpSession->RetMotACad := HttpGet->cMotivos
HttpSession->RetRDAACad := HttpGet->cCodRDA
HttpSession->RetcTipo   := HttpGet->cTipo

HttpSession->RecnoManBen := IIf(HttpGet->cRecno == NIL, "", HttpGet->cRecno)

cHtml += ExecInPage("PPLADT")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLGRTEST
Upload de arquivo através da Grid
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGRTEST()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
Local cRecno		:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode		:= "MSALPHA"
oObj:cCRecno		:= cRecno
oObj:cCArquivo		:= HttpGet->cDirArq
oObj:cCCodRda	 	:= Httpget->cCodRDA
oObj:cChave			:= HttpGet->cCodSeq
oObj:cAlias			:= iif(!empty(HttpGet->cAlitab),HttpGet->cAlitab,"BBA")
oObj:cIndice		:= "1"
oObj:lLIncRap		:= .T.

HttpSession->cUpload := "Vazio"

// Retorna dados

If oObj:UplConhec()
	cResult += oObj:cUplConhecRESULT

	HttpSession->cUpload := cResult
Else

	HttpSession->cUpload := ""
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCONADT

@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCONADT()

LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
Local cRecno		:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cCCodRda	 	:= HttpGet->cCodRDA
oObj:cChave		:= HttpGet->cCodSeq

HttpSession->cResDoc := "Vazio"

// Retorna dados

If oObj:ConSolAdt()
	cResult += oObj:cConSolAdtRESULT

Else

	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSTBEN
Atualizar status da solicitação para em análise.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSTBEN()

LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

// oBJ
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
//oObj:cCCodRda	 	:= HttpGet->cCodRDA
oObj:cChave		:= HttpGet->cCodSeq
oObj:cModo      := "1"
HttpSession->cResDoc := "Vazio"

// Retorna dados

If oObj:AltStBen()
	cResult += oObj:cAltStBenRESULT

Else

	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLRESUPL
Retorna o valor de resposta da Session
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLRESUPL()

Local cTeste := ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

If Valtype(HttpSession->cUpload) == "C"
	cTeste := HttpSession->cUpload
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE("true|" + cTeste)

/*/{Protheus.doc} PPLGRVADT
Alimentar Browse com os documentos vinculados à solicitação
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGRVADT()

LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cObserv	:= IIf(Valtype(HttpGet->cObserv) == "U", "", HttpGet->cObserv)
oObj:cCodSol	:= IIF(Valtype(HttpGet->cCodSol) == "U", "", HttpGet->cCodSol)
oObj:cCCodRda	:= IIf(ValType(httpGet->cCodRDA) == "U", "", HttpGet->cCodRDA)

HttpSession->cResDoc := "Vazio"

// Retorna dados

If oObj:GrvSolAdt()
	cResult += oObj:cGrvSolAdtRESULT
	HttpSession->cResDoc := cResult
Else
	HttpSession->cResDoc := ""
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCONSCON
Consulta o(s) contrato(s) e/ou aditivo(s)
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCONSCON()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//Chama formulario

cHtml += ExecInPage("PPLROTDESC")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLRMBCAL
Chamada da Rotina de Calendário de reembolso) no Portal beneficiario
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCALREE()
LOCAL cHtml 	:= ""
LOCAL cResult	:= ""


//Exibe pagina

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLCALREE")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLRECEI
Rastrear receita
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLRECEI()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

//Mostra a pagina de procedimentos

cHtml += ExecInPage( "PPLRASTRE?cCodRec=" + HttpGet->cCodRec + "&cCodMed="+HttpGet->cCodMed )

WEB EXTENDED END

getLOGMon()

Return cHtml


/*/{Protheus.doc} PPLPEPREST
Chamada da pagina de listagem dos prestadores por plano
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLPEPREST()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros

oObj:cUSERCODE	:= "MSALPHA"

If oObj:getProdutos()
	HttpSession->aProdutos := oObj:oWSGETPRODUTOSRESULT:oWSPRODUTOSLIST
EndIf

//Mostra a pagina para entrar com o protocolo/Guia

cHtml := ExecInPage( "PPLPEPREST" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCBCDRDA
Abre combo para selecionar RDA ao acessar a rotina
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCBCDRDA()

LOCAL cHtml := ""
LOCAL cResult := "true|"
LOCAL nI := 0

WEB EXTENDED INIT cHtml START "InSite"


//Chama formulario

If ValType(HttpSession->RDAVIEW) <> "U"
	If len(HttpSession->RDAVIEW) > 1
		cHtml += 	"<label>RDA</label>"
		cHtml += 	"<select id='cRDACod' name='cCoidigoRDA' class='form-control TextoInputOB ComboSelectOB'>"
		cHtml += 		"<option value='SELECTED'>-- Selecione uma RDA --</option>"

		For nI:=1 To Len( HttpSession->RDAVIEW )

			//Nao inclui registro duplicado

			if at("> "+ allTrim(HttpSession->RDAVIEW[nI]:cNAME) + " <" ,cHTML) == 0
				cHtml += "<option value='" + HttpSession->RDAVIEW[nI]:CCODE + "'> " + AllTrim(HttpSession->RDAVIEW[nI]:cNAME) + " </option>"
			endIf
		Next nI

		cHtml += 	"</select>"

		cResult += "Selecione uma RDA|" + cHtml + "|" + "@Confirmar~ loadSolConRda();@Cancelar~$('#closeModal').click();"
	Else
		cResult := "true|REDIRECIONAR|" + HttpSession->RDAVIEW[1]:CCODE
	Endif
Else
	cResult := "false|Erro ao processar RDA's"
Endif

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGETSIGLACR
Retorna as siglas C.R. do profissional
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGETSIGLACR()
LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cTipo			:= HttpGet->cTipo

// Retorna dados

If oObj:DADRETSIGLACR()

	nResult := Len(oObj:OWSDADRETSIGLACRRESULT:OWSSDADSIGLACR)

	xCols := "["
	For nI := 1 to nResult

		xCols += "{"
		xCols +=  "1:{field:'cDescri',value:'" +  SubStr(oObj:OWSDADRETSIGLACRRESULT:OWSSDADSIGLACR[nI]:CDESCRI,1,15) +"'}" + Iif( nResult != nI ,"},","}]" )
	Next

	cResult += xCols +"|"
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCORPOCLI
Corpo Clinico da RDA selecionada
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCORPOCLI ()
LOCAL cHtml := ""
PRIVATE aDocs := {}
PRIVATE lPrestTiss := .T.

WEB EXTENDED INIT cHtml START "InSite"

//Carregar documentos cadastrados para o corpo clínico

oObj := WSPLSXFUN():New()

IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUSERCODE	:= "MSALPHA"

If oObj:GetDocCorpoCli()
	aDocs := oObj:OWSGETDOCCORPOCLIRESULT:OWSSDOCS
EndIf

cHtml += ExecInPage("PPLCORPOCLI")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLDEPREST
Chamada para retornar os detalhes do prestadot
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLDEPREST()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros

oObj:cUSERCODE	:= "MSALPHA"
oObj:cRecnoBB8	:= HttpGet->cRecnoBB8

If oObj:GetPrestBB8()
	cHtml := "true|"
	HttpSession->cArrPrest := oObj:cGetPrestBB8RESULT
EndIf

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCAUTZ
Abre pág. de consulta de status de autorização (beneficiário)
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCAUTZ()
LOCAL cHtml	:= ""
LOCAL oObj  := NIL
Local nI		:= 0

WEB EXTENDED INIT cHtml START "InSite"

//Web Service
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros
oObj:cUSERCODE	:= "MSALPHA"
oObj:cCampos 	:= "BEA_TIPO"
oObj:cShowAnexo	:= "1"

//Monta o box de um determinado campo

If ValType(HttpSession->aTpGuia) == 'U'

	If oObj:GetBox()
		HttpSession->aTpGuia := oObj:OWSGETBOXRESULT:OWSGENERICSTRUCT
	EndIf

EndIf

cHtml += ExecInPage( "PPLCSAUT" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLDETPRES
Chamada da pagina para visualizar o detalhe do prestador
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLDETPRES()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

//Mostra o detalhamento do prestador

cHtml := ExecInPage( "PPLDETPRES" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLSACR
Web Function da pagina PPLSACR.aph
@Project	TTQLAU
@author	Lucas de Azevedo Nonato
@since		29/10/2015
@version	P12
@Return	L
/*/
Web Function PPLSACR()
Local cHtml   	:= ""
Local oObj		:= nil

WEB EXTENDED INIT cHtml START "InSite"

If ! Empty(HttpPost->cCodRda)

	oObj := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLSXFUN.APW" )

	oObj:cUSERCODE	:= "MSALPHA"
	oObj:cCODRDAACR := HttpPost->cCodRda

	If oObj:ACREDITACOES()
		HttpSession->Acreditacoes := aClone(oObj:OWSACREDITACOESRESULT:OWSSACREDIT)
	EndIf

EndIf

cHtml := ExecInPage("PPLSACR")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLGRANXB
Upload de arquivo através da Grid
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGRANXB()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
Local cNomArq		:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cCArquivo	:= HttpGet->cDirArq
oObj:cChave		:= Substr(Httpget->cChavP, 1, Len(Httpget->cChavP)-3)
oObj:cAlias		:= Right(Httpget->cChavP,3)
oObj:llIncRap		:= .T.

HttpSession->cUpload := "Vazio"

// Retorna dados

If oObj:UplConhec()
	cResult += oObj:cUplConhecRESULT

	HttpSession->cUpload := cResult
Else

	HttpSession->cUpload := ""
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)


/*/{Protheus.doc} PPLSGRVITE
Montar HTML para resposta da Iteraçãod
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSGRVITE()
local cResult := "true|"
local cChave 		:= IIF(!EMPTY(HttpSession->cChave),HttpSession->cChave,HttpGet->cChave)
local cChaveInt 	:= IIF(!EMPTY(HttpSession->cChaveInt),HttpSession->cChaveInt, HttpGet->cChaveInt)
local cResposta	:= StrTran(HttpGet->cResposta, "[ENTERz]", chr(10))

//variavel que identifica se ainda há interações pendentes para alterar o status da guia
//quando não houver mais nenhuma interação pendente (lPendente false) podemos alterar o status da guia
local lPendente	:= valtype(HttpGet->lPendente) <> "U" .and. HttpGet->lPendente == "true"
local cPublico	:= iif(valtype(HttpGet->cPubl) <> "U",  HttpGet->cPubl, "")
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


//Web Service

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cChave	  := cChave
oObj:cChaveInt  := cChaveInt
oObj:cResposta  := plsBNumStr(cResposta, 16, 2)
oObj:lPendente  := lPendente
oObj:cPublico   := cPublico

If ! oObj:GrvIntera()
	cResult :=  "false|"+StrTran(PWSGetWSError( "" ),":","")
Else
	cResult += oObj:cGrvInteraRESULT
EndIf

WEB EXTENDED END

getLOGMon()

return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGETENDER
Retorna as siglas C.R. do profissiona
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGETENDER()
LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cCCodRDA	:= HttpGet->cCodRDA
If ValType(HttpGet->cCodLoc)<>"U"
	oObj:cCCodLoc	:= HttpGet->cCodLoc
EndIf

// Retorna dados

If oObj:DADRETENDER()

	nResult := Len(oObj:oWSDADRETENDERRESULT:oWSSDADENDER)

	xCols := "["
	For nI := 1 to nResult

		xCols += "{"
		xCols +=  "1:{field:'cDescri',value:'" +  SubStr(oObj:oWSDADRETENDERRESULT:oWSSDADENDER[nI]:CCODLOC,1,50) + '$' + SubStr(oObj:oWSDADRETENDERRESULT:oWSSDADENDER[nI]:CDESCRI,1,50) +"'}" + Iif( nResult != nI ,"},","}]" )
	Next

	cResult += xCols +"|"
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLESPEC

@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLESPEC()
LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cCCodRDA		:= HttpGet->cCodRDA
oObj:cCodLoc		:= HttpGet->cCodLoc

// Retorna dados

If oObj:DADRETESPEC()

	nResult := Len(oObj:oWSDADRETESPECRESULT:oWSSDADESPEC)

	xCols := "["
	For nI := 1 to nResult

		xCols += "{"
		xCols +=  "1:{field:'cDescri',value:'" +  SubStr(oObj:oWSDADRETESPECRESULT:oWSSDADESPEC[nI]:CCODESP,1,50) + "$" + SubStr(oObj:oWSDADRETESPECRESULT:oWSSDADESPEC[nI]:CDESCRI,1,50) +"'}" + Iif( nResult != nI ,"},","}]" )
	Next

	cResult += xCols +"|"
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSMNTITE
Montar HTML para exibição das Iterações
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSMNTITE()

LOCAL cHtml := ""
local cResult := "true|"
local nI
local cChave
local cResposta
Local cVerifica
Local cObsvacao
Local cTipoGuia

WEB EXTENDED INIT cHtml START "InSite"


//Web Service

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//cVerifica := HttpGet->cVerif

// Registro no WS


oObj:cUSERCODE 			:= "MSALPHA"


//Parametros de entrada

If (HttpGet->cAlias == "BKU")
	oObj:oWSITEDAD:cALIMOV		:= HttpGet->cAlias
	oObj:oWSITEDAD:cANOAUT 		:= SubStr(HttpGet->cNumAut,1,4) //cAnoAut
	oObj:oWSITEDAD:cMESAUT		:= SubStr(HttpGet->cNumAut,5,2) //cMesAut
	oObj:oWSITEDAD:cNUMAUT		:= SubStr(HttpGet->cNumAut,7,8) //cNumAut
Else
	oObj:oWSITEDAD:cALIMOV		:= HttpGet->cAlias
	oObj:oWSITEDAD:cANOAUT 		:= HttpGet->cAnoAut
	oObj:oWSITEDAD:cCODOPE 		:= HttpGet->cCodOpe
	oObj:oWSITEDAD:cMESAUT		:= HttpGet->cMesAut
	oObj:oWSITEDAD:cNUMAUT		:= HttpGet->cNumAut
	oObj:oWSITEDAD:cSEQPROC		:= HttpGet->cSeqProc

EndIf


If HttpSession->MPortal == "000010"

	oObj:oWSITEDAD:cTPPUBLICO := "B"

ElseIf HttpSession->MPortal == "000008"

	oObj:oWSITEDAD:cTPPUBLICO := "P"

EndIf

if oObj:GetInteracao()

	cHTML += "<table id='tabIteracao' class='table table-striped table-bordered table-hover dt-responsive' cellspacing='0' cellpadding='0' style='width: 100%;'>"
	cHTML += "		<thead class='cabacalho'>"
	cHTML += "		<tr>"
	cHTML += "			<th><font size='3' >Visualizar</font></th>"
	cHTML += "			<th><font size='2' >Setor</font></th>"
	cHTML += "			<th><font size='2' >Data Interação</font></th>"
	cHTML += "			<th><font size='2' >Mot. Padrão</font></th>"
	If HttpSession->MPortal == "000008"
		cHTML += "			<th><font size='2' >Aguardando Resposta</font></th>"
	Endif
	If!(HttpGet->cAlias == "BKU")
		cHTML += "			<th><font size='2' >Aguardando Anexo</font></th>"
	EndIf
	cHTML += "		</tr>"
	cHTML += "		</thead>"
	cHTML += "		<tbody class='conteudo'>"    //para cada registro

	for nI := 1 to len (oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO)

		// IF (cVerifica == "S")
		//    Return cResult := .T.
		// ENDIF
		if oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:lRESPRE
			cResposta := 'S'
		else
			cResposta := 'N'
		endif

		cObsvacao := EncodeUTF8(oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cOBSERVACAO)
		cObsvacao := DecodeUTF8(cObsvacao)

		cChave := '"'
		cChave += "CarregaVisInt('"
		If !(HttpGet->cAlias == "BKU")
			cChave += HttpGet->cCodOpe + HttpGet->cAnoAut + HttpGet->cMesAut + HttpGet->cNumAut + "','" + HttpGet->cSeqProc + "','" + oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cSEQINT + "','"  + DTOC(oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:dDTITERACAO)+"','"+ oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cDESMOP+"','"+ EncodeUTF8(oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cOBSERVACAO) + "','" + cResposta + "','" + oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cALIASPAI + "','" + oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cRESPPREST + "','" + ALLTRIM(STR(getTpPortal()))
		Else
			cChave += HttpGet->cNumAut + "','" + "" + "','" + oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cSEQINT + "','"  + DTOC(oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:dDTITERACAO)+"','"+ oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cDESMOP+"','"+ cObsvacao + "','" + cResposta + "','" + oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cALIASPAI + "','" + oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cRESPPREST + "','" + ALLTRIM(STR(getTpPortal()))
		EndIf
		cChave += "')"
		cChave += '"'


		if oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cALIASPAI = 'BEA'
			cTipoGuia := '1'
		else
			if oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cALIASPAI = 'BE4'
				cTipoGuia := '2'
			else
				cTipoGuia := '3'
			endif
		endif

		If !(HttpGet->cAlias == "BKU")
			HttpSession->cChave    := HttpGet->cCodOpe + HttpGet->cAnoAut + HttpGet->cMesAut + HttpGet->cNumAut
			HttpSession->cChaveInt := HttpSession->cChave + HttpGet->cSeqProc + oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cSEQINT
		Else
			cChave += HttpGet->cNumAut
		EndIf

		cHTML += "<tr id='Linha" + alltrim(str(nI)) + "' bgcolor='#FFFFFF'>"
		cHTML += "		<td>"
		cHTML += "			<center><img id='btn" + alltrim(str(nI - 1)) +  "' class='colBtn' src='imagens-pls/refresh.gif' alt='Alterar' onclick=" + cChave + /*+ "closeModalBS();" + + "CarregaVisInt('" + cChave +"' )*/"></center>"

		cHTML += "		</td>"
		cHTML += "		<td><font size='2' >" + oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cSETOR + "</font></td>"
		cHTML += "		<td><font size='2' >" + DTOC(oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:dDTITERACAO) + "</font></td>"
		cHTML += "		<td><font size='2' >" + oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cDESMOP + "</font></td>"

		If HttpSession->MPortal == "000008"
			If oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:lRESPRE .AND. EMPTY(oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cRespPrest) .AND. ;
					oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cTipDirec != "A"

				cHTML += "		<td><font size='2' >Sim</font></td>"
			Else
				cHTML += "		<td><font size='2' >Não</font></td>"
			EndIf
		EndIf

		If!(HttpGet->cAlias == "BKU")
			If !oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:lANEXADO .AND. !oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:lRESPRE .AND. ;
					oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cTipDirec != "A"

				cHTML += "		<td><font size='2' >Sim</font></td>"
			Else
				cHTML += "		<td><font size='2' >Não</font></td>"
			EndIf
		endif

		cHTML += "	</tr>"
	Next nI

	cHTML += "		</tbody>"
	cHTML += "	</table>"

	cResult += "Histórico de Interações|" +cHTML+ "|" + "@Fechar~ closeModalBS();"
else
	cResult :=  "false|"+StrTran(PWSGetWSError( "" ),":","")
endif

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGETMUN
Retorna a cidade conforme o estado selecionado.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGETMUN()
LOCAL cResult  	:= "true|"
LOCAL xCols  := ""
LOCAL nI
local cCampoCID
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml //Aqui não tem o insite pq é utilizada no layout generico onde não tem login


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cCodEst	:= HttpGet->cCod
cCampoCID		:= HttpGet->cCampoCID

// Retorna dados

If oObj:DADRETCID()

	nResult := Len(oObj:oWSDADRETCIDRESULT:OWSSDADCODMUN)
	If nResult > 0

		For nI := 1 to nResult

			xCols +=  SubStr(AllTrim(oObj:oWSDADRETCIDRESULT:OWSSDADCODMUN[nI]:CCODCID),1,50) + '$' + SubStr(AllTrim(oObj:oWSDADRETCIDRESULT:OWSSDADCODMUN[nI]:CDESCRI),1,50) + Iif( nResult != nI ,"~","" )

		Next

		cResult += xCols +"|" + cCampoCID +"|"

		//cCampoCID += xCols +"|"

	Else
		cResult += "ZERO|SEM REGISTROS PARA ESSA UF"
	EndIf

Else
	cResult := "false|Não permitida a utilização do método webService"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGETCEN
Retorna o endereço conforme o CEP selecionado.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGETCEN()

LOCAL cResult  	:= ""
local cCampoEndereco
local cCampoBairro
local cCampoCodMunicipio
local cCampoMunicipio
local cCampoEstado
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml //Aqui não tem o insite pq é utilizada no layout generico onde não tem login


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )


// Parametros

oObj:cUserCode     := "MSALPHA"
oObj:cCep          := HttpGet->cCep
cCampoEndereco     := HttpGet->cCampoEndereco
cCampoBairro       := HttpGet->cCampoBairro
cCampoCodMunicipio := HttpGet->cCampoCodMunicipio
cCampoEstado       := HttpGet->cCampoEstado


// Retorna dados

If oObj:DADRETCEN()
	if oObj:cDADRETCENRESULT <> ""
		cResult += oObj:cDADRETCENRESULT + "~" + cCampoEndereco + "|" + cCampoBairro + "|" + cCampoCodMunicipio + "|" + cCampoEstado
	endif
Else
	cResult := ""
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGETDBN
Retorna os dados do beneficiário atras do CPF.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGETDBN()

LOCAL cResult  	:= ""
local cCampoCpf
local cCmpNome
local cCmpDtNasc
local cCmpRg
local cCmpOrigem
local cCmpCRNA
local cCmpNomePai
local cCmpNomeMae
local cCmpEmail
local cCmpCep
local cCmpComplemento
local cCmpNumero
local cCmpDDD
local cCmpTelefone
local cCmpSexo
local cCmpEstEmi
local cCmpUniv
local cCmpEstCiv
local cCmpInval
local cEstado
local cCampMuni
local cCmpEnder
local cCmpBai
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )


// Parametros

oObj:cUserCode  := "MSALPHA"
oObj:cCpfCnpj   := HttpGet->cCpf
cCmpNome        := HttpGet->cCmpNome
cCmpDtNasc      := HttpGet->cCmpDtNasc
cCmpRg          := HttpGet->cCmpRg
cCmpOrigem      := HttpGet->cCmpOrigem
cCmpCRNA        := HttpGet->cCmpCRNA
cCmpNomeMae     := HttpGet->cCmpNomeMae
cCmpNomePai     := HttpGet->cCmpNomePai
cCmpEmail       := HttpGet->cCmpEmail
cCmpCep         := HttpGet->cCmpCep
cCmpComplemento := HttpGet->cCmpComplemento
cCmpNumero      := HttpGet->cCmpNumero
cCmpDDD         := HttpGet->cCmpDDD
cCmpTelefone    := HttpGet->cCmpTelefone
cCmpSexo        := HttpGet->cCmpSexo
cCmpEstEmi      := HttpGet->cCmpEstEmi
cCmpUniv        := HttpGet->cCmpUniv
cCmpEstCiv      := HttpGet->cCmpEstCiv
cCmpInval       := HttpGet->cCmpInval
cEstado         := HttpGet->cEstado
cCampMuni       := HttpGet->cCampMuni
cCmpEnder       := HttpGet->cCmpEnder
cCmpBai         := HttpGet->cCmpBai


// Retorna dados

If oObj:DADRETBEN()
	if oObj:cDADRETBENRESULT <> ""
		cResult += oObj:cDADRETBENRESULT + "~" + cCmpNome + "|" + cCmpDtNasc + "|" + cCmpRg + "|" + cCmpOrigem + "|" + cCmpCRNA  + "|" + cCmpNomePai + "|" + cCmpNomeMae + "|" + cCmpEmail + "|" + cCmpCep + "|" + cCmpComplemento+ "|" +  cCmpNumero + "|" + cCmpDDD + "|" + cCmpTelefone + "|" + cCmpSexo + "|" +  cCmpEstEmi  + "|" + cCmpUniv + "|" + cCmpEstCiv + "|" + cCmpInval + "|" + cEstado + "|" + cCampMuni + "|" + cCmpEnder + "|" + cCmpBai
	endif
Else
	cResult := ""
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLVERBEN
Recebe o Login e verifica se é benef, ou ja solicitou.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLVERBEN()
LOCAL cResult  	:= ""
local cCpf := ""
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	     := "MSALPHA"

if Alltrim(Str(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:nTpPortal)) = "2"
	cCpf := Alltrim(HttpSession->CCPF)
else
	cCpf := Alltrim(HttpSession->USR_INFO[1]:CUSERLOGIN)
endif

oObj:cUsrLoginCode	 := cCpf


// Retorna dados


if len(Alltrim(cCpf)) = 11

	If oObj:VERBENPRI()
		if oObj:cVERBENPRIRESULT = "S"
			cResult := "true|true|" + cCpf//Alltrim(HttpSession->USR_INFO[1]:CUSERLOGIN)
		else
			cResult := "true|false"
		endif
	Else
		cResult := "true|false"
	EndIf
else
	cResult := "true|false"
endif

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPDELPROF
Exclui o corpo clinico.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPDELPROF()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )


// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cCRecno		:= HttpGet->cRecno
oObj:cAlias		:= "BC1"


// Retorna dados

If oObj:DelCorpoClinico()
	cResult := oObj:cDELCORPOCLINICORESULT
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGRVLOG

@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGRVLOG()

LOCAL cResult  	:= "true|"
Local cLogin 		:= IIf(ValType(HttpSession->USR_INFO[1]:CUSERLOGIN) == "C", HttpSession->USR_INFO[1]:CUSERLOGIN, "")
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cDadLog 		:= HttpGet->aDados
oObj:cCUSRLOGIN 	:= cLogin

If oObj:GRAVALOG()
	cResult += oObj:cGRAVALOGRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCBLOAD
Retorna os estados brasileiros no portal
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCBLOAD()
LOCAL cResult  	:= "true|"
LOCAL xCols		:= ""
LOCAL nI
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

// oBJ
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros
oObj:cUserCode	:= "MSALPHA"
oObj:cTipo			:= HttpGet->cTipo

// Retorna dados

If oObj:DADLOAD()

	nResult := Len(oObj:OWSDADLOADRESULT:OWSSDADLOAD)

	xCols += "["
	For nI := 1 to nResult

		If Empty(oObj:OWSDADLOADRESULT:OWSSDADLOAD[nI]:CDESCRIB)
			xCols += "{"
			xCols +=  "1:{field:'cDescri',value:'" +  SubStr(oObj:OWSDADLOADRESULT:OWSSDADLOAD[nI]:CDESCRIA,1,15) +"'}" + Iif( nResult != nI ,"},","}]" )
		else
			xCols += "{"
			xCols +=  "1:{field:'cDescri',value:'" +  SubStr(oObj:OWSDADLOADRESULT:OWSSDADLOAD[nI]:CDESCRIB,1,15) +"'}" + Iif( nResult != nI ,"},","}]" )
		EndIF
	Next

	cResult += xCols +"|"

Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PLSMAPCAPT
Inicia a tela de consulta de visitas aos prestadores
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PLSMAPCAPT()
LOCAL cHtml := ""
Local nI
Local nResult
Local xCols := ""
Private aResult := {}

WEB EXTENDED INIT cHtml START "InSite"


//Obj

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametro

oObj:cUSERCODE 	:= "MSALPHA"
oObj:cTipo			:= "UF"


// ComboBox da Rotina

If oObj:DADLOAD()
	nResult := Len(oObj:OWSDADLOADRESULT:OWSSDADLOAD)

	For nI := 1 to nResult
		aadd(aResult,AllTrim(oObj:OWSDADLOADRESULT:OWSSDADLOAD[nI]:CDESCRIA)+"="+AllTrim(oObj:OWSDADLOADRESULT:OWSSDADLOAD[nI]:CDESCRIA))
	Next
EndIF


//Chama formulario

cHtml += ExecInPage("PPLMAPCAPT")

WEB EXTENDED END

getLOGMon()

Return cHtml


/*/{Protheus.doc} PPLProced
Solicitação de procedimentos da RDA
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLPROCED()
LOCAL cHtml 		:= ""
LOCAL nPos			:= 1
LOCAL nI			:= 1
LOCAL aObjSess	:= {} // Variaveis para criação de Grid generica
LOCAL aMntSess	:= {} 	// Variaveis para criação de Grid generica


WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLROTDESC")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLSOLOP
Rotina para chamar a tela de solicitação de opcionais.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSOLOP()
LOCAL cHtml   := ""
LOCAL nPos			:= 1
LOCAL nI			:= 1
LOCAL aObjSess	:= {} // Variaveis para criação de Grid generica
LOCAL aMntSess	:= {} 	// Variaveis para criação de Grid generica
Private cClass := Iif(ValType(HttpGet->cClass) <> "U",HttpGet->cClass,"")
WEB EXTENDED INIT cHtml START "InSite"

aAdd( aObjSess, PLSXFUN_ARRAYOFSCMPGUIA():New() )

nPos := Len(aObjSess)

aAdd( aObjSess[nPos]:OWSSCMPGUIA, PLSXFUN_SCMPGUIA():New() )

aObjSess[nPos]:OWSSCMPGUIA[1]:cTipo := 'G'
aObjSess[nPos]:OWSSCMPGUIA[1]:cNome := "BrwGrid"
aObjSess[nPos]:OWSSCMPGUIA[1]:cDescri := ""
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid := PLSXFUN_ARRAYOFSCMPGRID():NEW()

aObjSess[nPos]:OWSSCMPGUIA[1]:oWsaCols := PLSXFUN_ARRAYOFSTRING():NEW()
aObjSess[nPos]:OWSSCMPGUIA[1]:oWsaHeader := PLSXFUN_ARRAYOFSTRING():NEW()

aObjSess[nPos]:OWSSCMPGUIA[1]:oWsaCols := PLSXFUN_ARRAYOFSTRING():NEW()
aObjSess[nPos]:OWSSCMPGUIA[1]:oWsaHeader := PLSXFUN_ARRAYOFSTRING():NEW()

aObjSess[nPos]:OWSSCMPGUIA[1]:cxCols := ""
aObjSess[nPos]:OWSSCMPGUIA[1]:cxHeader := ""

for nI := 1 to 7
	aadd( aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:OWSSCmpGrid, PLSXFUN_SCMPGRID():NEW() )
next

aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[1]:cTipo := "C"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[1]:cNome := "Field_BenefsMat"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[1]:cDescri := "Matrícula"

aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[2]:cTipo := "C"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[2]:cNome := "Field_BenefsNom"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[2]:cDescri := "Nome"

aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[3]:cTipo := "C"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[3]:cNome := "Field_CodOpc"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[3]:cDescri := "Código"

aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[4]:cTipo := "C"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[4]:cNome := "Field_VerOpc"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[4]:cDescri := "Versão"

aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[5]:cTipo := "C"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[5]:cNome := "Field_descriOpc"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[5]:cDescri := "Opcional"

aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[6]:cTipo := "D"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[6]:cNome := "Field_DTAD"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[6]:cDescri := "Data Adesão"

aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[7]:cTipo := "D"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[7]:cNome := "Field_DTLIM"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[7]:cDescri := "Data Limite"

HttpSession->aCmpGuia := aClone(aObjSess[nPos]:OWSSCMPGUIA)

cHtml := ExecInPage( "PPLSOLOP" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCARBEN
Rotina para carregar os beneficiários vinculados a familia ou a empresa..
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCARBEN()

LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cCUSRLOGIN	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
oObj:nTpPor		:= getTpPortal()

//matricula do beneficiario selecionado para filtrar o multiselect
oObj:cMatUsu	:= IIF(valtype(httpGet->cMatric) != "U", httpGet->cMatric, "")

// Retorna dados
If oObj:DadFrmEmp()

	nResult := Len(oObj:OWSDadFrmEmpRESULT:OWSSDADGRP)

	xCols := "["
	For nI := 1 to nResult

		xCols += "{"
		xCols +=  "0:{field:'cMatric', value:'" + oObj:OWSDadFrmEmpRESULT:OWSSDADGRP[nI]:cMatricl +   "'},"
		xCols +=  "1:{field:'cNomBnf',value:'" +  SubStr(oObj:OWSDadFrmEmpRESULT:OWSSDADGRP[nI]:cNomeBnf,1,20) +"'}" + Iif( nResult != nI ,"},","}]" )
	Next

	cResult += xCols +"|"

Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGRVOP
Rotina para chamar a tela de solicitação de opcionais.a..
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGRVOP()
Local oObj
Local oObjItens		:= {}
Local cResult		:= "true|"
Local nCont			:= 1
Local nTpPortal		:= 0
Local aResult      := {}
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"


//Web Service

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )


//Alimenta parametros

oObj:cUserCode	:= "MSALPHA"
oObj:oWSDADOSOPC:oWSDADOSBENOPC := PLSXFUN_ARRAYOFSITENSOPC():New()


//Inclusao

oObj:cCUSRLOGIN	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
oObj:nCodPor	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:nTpPortal
aCols			:= HttpSession->aCmpGuia[1]:OWSACOLS:CSTRING
oObj:cClasse 	:= HttpGet->cClass

For nCont := 1 To Len(aCols)

	aAdd( oObj:oWSDADOSOPC:oWSDADOSBENOPC:oWSSITENSOPC, PLSXFUN_SITENSOPC():New() )
	nQtd := Len( oObj:oWSDADOSOPC:oWSDADOSBENOPC:oWSSITENSOPC )

	oObj:oWSDADOSOPC:oWSDADOSBENOPC:oWSSITENSOPC[nQtd]:cCodBen	:= aCols[nCont,1]
	oObj:oWSDADOSOPC:oWSDADOSBENOPC:oWSSITENSOPC[nQtd]:cCodOpc	:= aCols[nCont,3]
	oObj:oWSDADOSOPC:oWSDADOSBENOPC:oWSSITENSOPC[nQtd]:dDatade	:= CtoD(aCols[nCont,6])
	oObj:oWSDADOSOPC:oWSDADOSBENOPC:oWSSITENSOPC[nQtd]:dDatLim	:= CtoD(aCols[nCont,7])
	oObj:oWSDADOSOPC:oWSDADOSBENOPC:oWSSITENSOPC[nQtd]:cVerOpc	:= aCols[nCont,4]

Next

If oObj:INCBENOPC()
	cResult += oObj:cINCBENOPCRESULT
	aResult := 	Separa(cResult, "|")
	cUrl := Iif(len(aResult) > 4 .and. !Empty(aResult[5]), aResult[5], "")

	If(!Empty(cUrl))
		HttpSession->cUrlForm := cUrl
	Else
		HttpSession->cUrlForm := ""
	EndIf
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

//Log BSW para LGPD
if ValType(httpGet->cRotinLGPD) <> "U"
	oObj:cUserCode	 := "MSALPHA"
	oObj:cUserLGPD   := HttpSession->USR_INFO[1]:cUserLogin
	oObj:cRotinLGPD  := httpGet->cRotinLGPD
	oObj:LogLGPD()
endIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLVLOPC
Rotina para validar a inclusão dos beneficiários e opcionais Rotina para validar a inclusão dos beneficiários e opcionais
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLVLOPC()
LOCAL cResult  	:= "true|"
LOCAL cRec 		:= ""
LOCAL cVldEspe 	:= ""
LOCAL cOpcTit 	:= ""
LOCAL aDados 	:= {}
LOCAL oObj 		:= NIL
LOCAL oObjPar 	:= NIL
LOCAL nPos 		:= 0
LOCAL nLen 		:= 0
LOCAL nPosMat 	:= 0
LOCAL nPosCodOpc:= 0
LOCAL nPosVerOpc:= 0
local nI 		:= 1
LOCAL cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

if httpSession->lVldOpc

	//pego os itens que já estão na solicitação
	nPos := aScan( HttpSession->aCmpGuia, { |x| x:cNome == "BrwGrid"} )

	if nPos > 0

		nLen 		:= len(HttpSession->aCmpGuia[nPos]:oWSACOLS:CSTRING)
		nPosMat    	:= aScan( HttpSession->aCmpGuia[nPos]:oWSCMPGRID:oWSSCMPGRID, { |x| x:cNome == "Field_BenefsMat"} )
		nPosCodOpc 	:= aScan( HttpSession->aCmpGuia[nPos]:oWSCMPGRID:oWSSCMPGRID, { |x| x:cNome == "Field_CodOpc"} )
		nPosVerOpc 	:= aScan( HttpSession->aCmpGuia[nPos]:oWSCMPGRID:oWSSCMPGRID, { |x| x:cNome == "Field_VerOpc"} )

		if nPosMat > 0 .and. nPosCodOpc > 0 .and. nPosVerOpc > 0 .and. nLen > 0

			oObj:cARROPC := ""

			For nI := 1 to nLen
				oObj:cARROPC += HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING[nI][nPosMat] + "$"
				oObj:cARROPC += HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING[nI][nPosCodOpc] + "$"
				oObj:cARROPC += HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING[nI][nPosVerOpc]
				oObj:cARROPC += iif(nI >= (nLen-1),"", "|")
			Next nI

		endIf

	endif
endIf

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cValores	:= HttpGet->cValores

// Retorna dados

if oObj:VldBenOpc()

	aDados	:= Separa(oObj:cVLDBENOPCRESULT, "|", .F.)

	HttpGet->cValores := iif(aDados[1]=="0", "", aDados[1])

	cRec 	:= iif(aDados[2]=="0","", aDados[2])
	cVldEspe:= iif(aDados[3]=="0","", aDados[3])
	cOpcTit := iif(aDados[4]=="0","", aDados[4])

	if HttpGet->cValores != ""
		cResult := W_PPLGETGRID()
	endif

	cResult += ">>"+cRec+">>"+cVldEspe+">>"+cOpcTit
else
	cResult :=  "false|"+StrTran(PWSGetWSError( "" ),":","")
endIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCONSOP
 Chamada da pagina de consulta de solicitações de opcionais
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCONSOP()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

// Chamada do .APH

cHtml := ExecInPage( "PPLCONSOP" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PLIMPOPC
Chamada da pagina com o protocolo do opcional
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PLSIMPOPC()
LOCAL cHtml   := ""
LOCAL oObj := NIL
Private oDadSolOpc := NIL //private para poder usar no aph

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:ccRecno		:= HttpGet->cRecno

// Retorna dados

if oObj:GetSolOpc()

	oDadSolOpc := oObj:oWSGETSOLOPCRESULT

endif

cHtml := ExecInPage( "PLSIMPOPC" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCHECKPR
Verificação da solicitação de alteração de procedimento
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCHECKPR()

LOCAL cResult  := "true|"
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cDadLog 		:= httpGet->cDadLog

If oObj:CHECKPROCEDIMENTO()
	cResult := oObj:CCHECKPROCEDIMENTORESULT
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGRVPROC
Gravação de procedimento na tabela de análise de log
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGRVPROC()

LOCAL cResult  	:= ""
Local cLogin 		:= IIf(ValType(HttpSession->USR_INFO[1]:CUSERLOGIN) == "C", HttpSession->USR_INFO[1]:CUSERLOGIN, "")
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cDadLog 		:= HttpGet->aDados
oObj:cCUSRLOGIN 	:= cLogin

If oObj:GRAVAPROCEDIMENTO()
	cResult += oObj:CGRAVAPROCEDIMENTORESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLPRMACE
Rotina para verificar se é primeiro acesso, caso seja, o sistema irá obrigar que seja alterada a senha.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLPRMACE()

local cResult := "true|"
local cUsuarioLogado
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

cUsuarioLogado := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE


//Web Service

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUsrLoginCode := cUsuarioLogado

If oObj:VERACESSO()
	cResult += oObj:cVERACESSORESULT
else
	cResult :=  "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

return PLSDECODE(cResult)

/*/{Protheus.doc} PPLUPLOPC
Chama APH da rotina de upload Genérica
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLUPLOPC()
LOCAL cHtml := ""
Local cModo := IIF(ValType(HttpGet->cModo) == "U", "1", HttpGet->cModo)

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLUPLOPC")

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cHtml)

/*/{Protheus.doc} ALTBBA

@author PLSTEAM
@since 10.2007
@version P12
/*/
Function ALTBBA(cRecnoBBA, cVar)
	LOCAL oObj 		:= NIL
	LOCAL cHtml := " "

	WEB EXTENDED INIT cHtml START "InSite"

	oObj := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLSXFUN.APW" )

	oObj:cUserCode	:= "MSALPHA"
	oObj:cChave		:= cRecnoBBA
	oObj:cModo      := "2"
	oObj:AltStBen()

	WEB EXTENDED END

	getLOGMon()

return

/*/{Protheus.doc} PPLENVUPG
Upload de arquivo
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLENVUPG()
local oObj 		:= NIL
local cResult  	:= ''
local cRetorno  := ''
local cExecPos	:= ''
local aFunPos	:= {}
local cFunction	:= ''
local cPar		:= ''
local cHtml 	:= ''
local cGvrPro   := HttpGet->cGvrProtoc

WEB EXTENDED INIT cHtml START "InSite"

If ! Empty(HttpSession->cExecPos )
	cExecPos 	:= HttpSession->cExecPos
	aFunPos  	:= SEPARA(cExecPos, "|")
	cFunction	:= aFunPos[1]
	cPar     	:= aFunPos[2]
EndIf

// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cCRecno	:= iIf( valType(HttpGet->cRecno)  == "C", HttpGet->cRecno, "")
oObj:cCArquivo	:= iIf( valType(HttpGet->cDirArq) == "C", HttpGet->cDirArq, "")
oObj:cChave		:= iIf( valType(Httpget->cChave)  == "C", Httpget->cChave, "")
oObj:cAlias		:= iIf( valType(HttpGet->cAlitab) == "C", HttpGet->cAlitab, "")
oObj:cIndice	:= iIf( valType(HttpGet->cNumInd) == "C", HttpGet->cNumInd, "")


if ValType(HttpGet->cNoArqComp) <>  'U' .and. !empty(HttpGet->cNoArqComp)
	oObj:cNoArqComp := RC4Crypt(HttpGet->cNoArqComp, '123456789')
endif

HttpSession->cUpload := "Vazio"
HttpSession->nAnexos := "Gravou"
if cExecPos <> ""
	&cFunction.(cPar, "") //Chama função após a exclusão da gride.
endif

//Retorna dados
If oObj:UplConhec()
	cResult 			 := oObj:cUplConhecRESULT
	HttpSession->cUpload := cResult
Else
	HttpSession->cUpload := ""
	cResult 			 := "false|"
EndIf


//Protocolo das guia de upload
if !empty(cGvrPro)

	oObj:cMonSol         := HttpGet->cMonSol
	oObj:cNumCrm         := HttpGet->cNrCrm
	oObj:cSgCrm          := HttpGet->cSgCrm
	oObj:cTpEst          := HttpGet->cTpEst
	oObj:cProtocUpl      := HttpGet->cChave
	oObj:cBenef          := HttpGet->cBenef
	oObj:cMatric         := HttpGet->cMatric

	if oObj:GrvUplGui()
		cRetorno := oObj:cGRVUPLGUIRESULT
	EndIf

	If cRetorno != "true|S"
		cResult := "false|"
	endIf

endIf

//Log BSW para LGPD
if ValType(httpGet->cRotinLGPD) <> "U"
	oObj:cUserCode	 := "MSALPHA"
	oObj:cUserLGPD   := HttpSession->USR_INFO[1]:cUserLogin
	oObj:cRotinLGPD  := httpGet->cRotinLGPD
	oObj:LogLGPD()
endIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLUPGEN
Chama APH da rotina de upload Genérica
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLUPGEN()
LOCAL cHtml := ""
Local cModo := IIF(ValType(HttpGet->cModo) == "U", "1", HttpGet->cModo)
Local cExecPos := IIF(ValType(HttpGet->cExecPos) == "", "", HttpGet->cExecPos)

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->cModoUpl := cModo
HttpSession->cExecPos := cExecPos

HttpSetPart(.F.)

//Se cModo == 1, a chamada é para a página separada
//Se cModo <> 1, a chamada é para a página dentro de outra página
if (cModo == "1")
	cHtml += ExecInPage("PPLUPGEN")
else
	cHtml += "true|" + ExecInPage("PPLUPGEN")
EndIf

HttpSetPart(.T.)

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cHtml)

/*/{Protheus.doc} PPLCONOPC
Gravação Opcionais após Upload
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCONOPC()

LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
Local cRecno		:= ""
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cChave		:= HttpGet->cCodSeq

HttpSession->cResDoc := "Vazio"

// Retorna dados

If oObj:GrvSolOpc()
	cResult += oObj:cGrvSolOpcRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSTAOPC
Altera o status da solicitação de opcional após anexar docs
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLSTAOPC()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
Local cRecno		:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:ccRecno		:= HttpGet->cRecno

// Retorna dados

If oObj:AltSolOpc()
	cResult := oObj:cAltSolOpcRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLUNUPL
Exclusão de arquivos do banco de conhecimento
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLUNUPL()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cCRecno		:= HttpGet->cRecno


// Retorna dados

If oObj:UnUplConhec()
	cResult += oObj:cUnUplConhecRESULT

Else

	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCPARQ
Chamada da função que retorna o caminho de download arquivos
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCPARQ()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cCRecno		:= STRTRAN(HttpGet->cRecno, ".","")


// Retorna dados

If oObj:CpyArqConhe()
	cResult += oObj:cCpyArqConheRESULT

Else

	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLREEMB
 Chamada da pagina de solicitação de reembolso
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLREEMB()

LOCAL cHtml 	:= ""
LOCAL cResult	:= ""
LOCAL aRegras	:= {}
LOCAL nTpPor  := getTpPortal()
LOCAL oObj		:= nil
LOCAL oObjPar	:= nil
LOCAL oObjSolic	:= nil

PRIVATE lRecOb  	:= HttpSession->lRecOb
PRIVATE lMultComp	:= HttpSession->lMultComp
PRIVATE lTourReemb 	:= HttpSession->lTourReemb

PRIVATE lSolRee		:= "false"
PRIVATE aDadosSoli 	:= {}
PRIVATE nX 			:= 1
PRIVATE cCodSol 	:= iif(valtype(HttpGet->cCodSol) <> "U", HttpGet->cCodSol, "")
PRIVATE cMsgs 		:= ""


//Web Service


WEB EXTENDED INIT cHtml START "InSite"

HttpSession->ClasseProc := {}
if (nTpPor <> 2)
	oObj := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLSXFUN.APW" )


	//Parametros de entrada

	oObj:cUserCode  := "MSALPHA"
	oObj:ccUsrLogin := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
	oObj:cMatUsu    := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CCODE

	If oObj:VerPermRee()

		lSolRee := oObj:cVERPERMREERESULT

		if (lSolRee == "true")

			//Exibe pagina
			If Empty(HttpSession->ClasseProc)
				If oObj:RetClassProc()
					HttpSession->ClasseProc	:=   oObj:OWSRETCLASSPROCRESULT:OWSSCLASSEPROC
				EndIf
			EndIf

			If oObj:ReembChkRegr()
				cResult := oObj:cREEMBCHKREGRRESULT
				aRegras := StrToArray(cResult , "|")
			EndIf


			//Chama o formulario

			If Len(aRegras) > 0
				HttpSession->cDtLimit := SubStr(aRegras[1],4,2) + "/" + SubStr(aRegras[1],1,2) + "/" + SubStr(aRegras[1],7,4)
			EndIf

			//Verifica se origem é tela de consulta
			If HttpGet->cOrigem == "consulta" .and. !Empty(HttpGet->cRecnoProt)

				//Chamada de webservice para obter os dados do recno correspondente e alimentar a private aDadosSoli
				oObjSolic 	:= NIL
				oObjSolic	:= WSPLSXFUN():new()
				IIf (!Empty(PlsGetAuth()),oObjSolic:_HEADOUT :=  { PlsGetAuth() },)
				WsChgURL( @oObjSolic, "PLSXFUN.APW" )
				oObjSolic:cUserCode	:= "MSALPHA"
				oObjSolic:cCRecno		:= HttpGet->cRecnoProt

				//Invoca método para alimentar a private aDadosSoli
				if (oObjSolic:EditSolic())
					aadd(aDadosSoli, .T.)
					aadd(aDadosSoli, oObjSolic:oWSEDITSOLICRESULT)
				endif
			ElseIf HttpGet->cOrigem == "consulta" .and. !Empty(HttpGet->cChaveB1N)

				oObjSolic 	:= NIL
				oObjSolic	:= WSPLSXFUN():new()
				IIf (!Empty(PlsGetAuth()),oObjSolic:_HEADOUT :=  { PlsGetAuth() },)
				WsChgURL( @oObjSolic, "PLSXFUN.APW" )
				oObjSolic:cUserCode	:= "MSALPHA"
				oObjSolic:cChave		:= HttpGet->cChaveB1N
				oObjSolic:cCRecno		:= ""

				//Invoca método para alimentar a private aDadosSoli
				if (oObjSolic:EditSolic())
					aadd(aDadosSoli, .T.)
					aadd(aDadosSoli, oObjSolic:oWSEDITSOLICRESULT)
				endif
			EndIf

			//Retorna o texto que será exibido no li e concordo
			If oObj:GetLieCon()
				HttpSession->cLieCon := oObj:OWSGETLIECONRESULT:CCLIECON
			EndIf

			if( empty(HttpGet->cOrigem) .and. empty(HttpGet->lNewComp) ) //quando é edição não preciso exibir o tour de novo e nem quando o usuario clica em novo comprovante

				oObjSolic 	:= NIL
				oObjSolic	:= WSPLSXFUN():new()
				IIf (!Empty(PlsGetAuth()),oObjSolic:_HEADOUT :=  { PlsGetAuth() },)
				WsChgURL( @oObjSolic, "PLSXFUN.APW" )

				oObjSolic:cUserCode	:= "MSALPHA"
				oObjSolic:nTPPOR 	:= getTpPortal()
				oObjSolic:cROTINA 	:= "PPLREEMB"
				oObjSolic:cIDIOMA 	:= "POR"

				if oObjSolic:GetMsgPortal()
					cMsgs := oObjSolic:cGETMSGPORTALRESULT
				EndIf

			endIf

		EndIf

	EndIf

endif

If (lSolRee == "false" .AND. HttpSession->cLieCon == NIL)
	HttpSession->cLieCon := ""
EndIf

cHtml += ExecInPage("PPLREEMB")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCARREC
Rotina para carregar as receitas aprovadas vinculadas a matricula do beneficiario.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCARREC()

LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
//matricula do beneficiario selecionado para filtrar o multiselect
oObj:cMatUsu		:= httpGet->cMatric
oObj:dDtDoc		:= CTOD(httpGet->cDatDoc)

// Retorna dados

If oObj:GetUsrRec()

	nResult := Len(oObj:OWSGetUsrRecRESULT:OWSSDadRecUsr)

	xCols := "["
	For nI := 1 to nResult

		xCols += "{"
		xCols +=  "0:{field:'cCodRec', value:'" + oObj:OWSGetUsrRecRESULT:OWSSDadRecUsr[nI]:cCodRec + "'},"
		xCols +=  "1:{field:'cDesRec', value:'" + oObj:OWSGetUsrRecRESULT:OWSSDadRecUsr[nI]:cNomRec + "'},"
		xCols +=  "2:{field:'cCodMed', value:'" + oObj:OWSGetUsrRecRESULT:OWSSDadRecUsr[nI]:cCodMed + "'},"
		xCols +=  "3:{field:'cNomMed', value:'" + oObj:OWSGetUsrRecRESULT:OWSSDadRecUsr[nI]:cNomMed + "'},"
		xCols +=  "4:{field:'nQtdAut', value:'" + alltrim(str(oObj:OWSGetUsrRecRESULT:OWSSDadRecUsr[nI]:nQtdAut)) + "'},"
		xCols +=  "5:{field:'nQtdExe', value:'" + alltrim(str(oObj:OWSGetUsrRecRESULT:OWSSDadRecUsr[nI]:nQtdExe)) + "'} " + Iif( nResult != nI ,"},","}]" )

	Next

	If nResult <= 0
		xCols += "]"
	EndIF

	cResult += xCols

Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCOPRM
Retorna dados do procedimento.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCOPRM()
LOCAL nI      	:= 0
LOCAL oOb2	  	:= NIL
LOCAL lExibe  	:= .F.
LOCAL cResult 	:= "true|"
LOCAL cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

//Web Service

oOb2 := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oOb2:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oOb2, "PLSXFUN.APW" )

//Parametros de entrada

oOb2:cUserCode 		:= "MSALPHA"
oOb2:cCCodTb   		:= HttpGET->cCodTb
oOb2:cCCodPro		:= HttpGet->cCodPro
oOb2:cCCodRDA		:= left(HttpGet->cCodRDA,6)
oOb2:cCCodLoc		:= HttpGet->cCodLoc
oOb2:cCCodEsp		:= HttpGet->cCodEsp
oOb2:cFlgVRDA		:= "SIM"

//TODO 25/04/2018 - necessario incluir a matricula do usuario no formulario de elegibilidade e tabela de valores
oOb2:cMatric		:= ''

if oOb2:GetVlrPro()
	cResult +=	oOb2:cGetVlrProRESULT
else
	cResult := "false|" + StrTran(PWSGetWSError( "" ),":","")
endIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLITREEMB
Grava o item do reembolso enquanto o beneficiarios está fazendo a solicitação
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLITREEMB()
LOCAL oObj		:= NIL
LOCAL cResult  	:= "true|"
Local aArrFami 	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA
Local nPos     	:= 0
LOCAL cHtml   	:= ""
LOCAL dFontxFun :=  GetAPOInfo("WSPLSXFUN.PRX")[4]
LOCAL dDatCliet :=  GetAPOInfo("WSCLIENT_WSPLSXFUN.PRX")[4]

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros
oObj:cUserCode	:= "MSALPHA"
oObj:cCodSol	:= httpGet->cCodSol
oObj:ccRecno    := httpGet->cRecno

//Busca titular ou responsável financeiro
nPos := aScan(aArrFami , { |x| x:cTipUsu == HttpSession->cTitPar} )

if nPos == 0
	nPos := aScan(aArrFami , { |x| x:cResFam == "1"} )
endif

if nPos > 0

	oObj:cMatUsu := aArrFami[nPos]:cBenefi

	oObj:lCabAlt	:= ValType(HttpGet->lCabAlt) <> "U" .and. HttpGet->lCabAlt == "true" //verifica se alterou o cabeçalho do reembolso
	oObj:cRecDivs	:= iif(ValType(HttpGet->cRecDivs) <> "U" .and. !empty(HttpGet->cRecDivs), HttpGet->cRecDivs, "0") //esse recnodivs vem quando é multicomprovante e eu só posso alterar as B1N do comprovante e não da solicitação interi

	//Condição para garantir a existencia da propriedade e que o client está atualizado
	If dFontxFun >= CTOD("01/11/2017") .AND. dDatCliet >= CTOD("01/11/2017")
		oObj:cOriReemb	:= "01" //Portal do Beneficiario
	endIf

	oObj:oWSITEMREEMB := PLSXFUN_SITENSREEMB():New()

	oObj:oWSITEMREEMB:cCodPad := HttpGet->Field_CODPAD
	oObj:oWSITEMREEMB:cCodPro := HttpGet->Field_CODPROC

	if valType(HttpGet->Field_VALOR) == 'C'
		oObj:oWSITEMREEMB:cVlrPro := strTran(strTran(HttpGet->Field_VALOR, ",", ""),".","")
	else
		oObj:oWSITEMREEMB:cVlrPro := '0'
	endIf

	oObj:oWSITEMREEMB:cUsoC   		:= iif(HttpGet->Field_USOCONST == "1", "1", "0")
	oObj:oWSITEMREEMB:cQtdPro 		:= HttpGet->Field_QTD
	oObj:oWSITEMREEMB:cMatric 		:= HttpGet->Field_MATRIC
	oObj:oWSITEMREEMB:cCodRec 		:= HttpGet->Field_CODREC
	oObj:oWSITEMREEMB:cCodMed 		:= HttpGet->Field_CODMED
	oObj:oWSITEMREEMB:cSeqMed 		:= HttpGet->Field_SEQMED
	oObj:oWSITEMREEMB:cTipDoc 		:= HttpGet->Field_TIPDOC
	oObj:oWSITEMREEMB:cCPFCNPJ		:= HttpGet->Field_CPFCNPJ
	oObj:oWSITEMREEMB:cNomRDA 		:= HttpGet->Field_NOMEPRE
	oObj:oWSITEMREEMB:cNroDoc 		:= HttpGet->Field_NUMDOC
	oObj:oWSITEMREEMB:dDatDoc 		:= CtoD(HttpGet->Field_DTEMIS)
	oObj:oWSITEMREEMB:cTipSer 		:= HttpGet->Field_TIPSER

	oObj:oWSITEMREEMB:cCidade 		:= HttpGet->cCidade
	oObj:oWSITEMREEMB:cUF     		:= alltrim(HttpGet->cUf)
	oObj:oWSITEMREEMB:cDatComprov	:= HttpGet->Field_DTEXEC

	// Retorna dados
	if oObj:GrvItReemb()

		cResult += oObj:cGRVITREEMBRESULT

	else

		cResult := "false|" + StrTran(PWSGetWSError( "" ),":","")

	endIf

else
	cResult := "false|Família não possui titular ou responsável financeiro. Entre em contato com a operadora."
endIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLExDsp
Exclusão da despesa
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLExDsp()

Local oObj	:= NIL
Local cResult	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj	:= WSPLSXFUN():new()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cCRecno		:= HttpGet->cRecno

If oObj:DelDesp()
	cResult += oObj:cDELDESPRESULT

else
	cResult := "false|"

EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCHTAB
Abre página de consulta de tabelas solicitadas
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCHTAB()
LOCAL cHtml	:= ""

WEB EXTENDED INIT cHtml START "InSite"

//Chama o formulario

cHtml += ExecInPage( "PPLROTDESC" )

WEB EXTENDED END

Return cHtml

/*/{Protheus.doc} PPLTBKHF
Retorna dados do procedimento
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLTBKHF()
LOCAL oObj	  		:= NIL
LOCAL cResult 	:= "true|"
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"


//Web Service

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros de entrada

oObj:cUserCode 		:= "MSALPHA"
oObj:ccCodTb   		:= HttpGET->cCodTb
oObj:ccCodRDA			:= HttpGet->cCodRDA
oObj:ccCodLoc			:= HttpGet->cCodLoc
oObj:ccCodEsp			:= HttpGet->cCodEsp
oObj:cUsuEmai			:= HttpGet->cEmail
oObj:cPLSCodUsr		:= HttpGet->cCodUs
oObj:cTipo				:= HttpGet->cForRel

If oObj:PlsTWPGQ()
	cResult := 'true|'+oObj:cPlsTWPGQRESULT
Else

	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
ENDIF

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLReemCon
Confirmação Solicitação
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLReemCon()
Local oObj 		:= NIL
Local oObjPar 	:= NIL
Local cResult	:= ""
Local aArrFami 	:= {}
Local nPos     	:= 0
LOCAL cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

if valType(HttpSession->USR_INFO) == 'A' .and. len(HttpSession->USR_INFO) > 0
	aArrFami := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA
endIf

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"

if empty(httpGet->cCodSol)

	cResult := "false|Ocorreu um erro na conexão, por favor tente novamente."

elseIf len(aArrFami) > 0

	oObj:cCodSol := httpGet->cCodSol

	//Busca titular ou responsável financeiro
	nPos := aScan(aArrFami , { |x| x:cTipUsu == httpSession->cTitPar} )

	if nPos == 0
		nPos := aScan(aArrFami , { |x| x:cResFam == "1"} )
	endif

	if nPos >= 1

		oObj:cMatUsu    	:= aArrFami[nPos]:cBenefi
		oObj:cCPFCNPJ       := HttpGet->cCpfCnpj
		oObj:cNomRdaNRef    := HttpGet->cNomePres
		oObj:cCUsrLogin 	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
		oObj:cTipo          := HttpGet->cTipDoc
		oObj:cNumDoc        := HttpGet->cNumDoc
		oObj:cDocEmi        := HttpGet->cDatDoc
		oObj:cAltera        := HttpGet->lAltera
		oObj:cDocObrig    	:= HttpGet->lDocObrig
		oObj:lCabAlt        := ValType(HttpGet->lCabAlt) <> "U" .and. HttpGet->lCabAlt == "true"
		oObj:cRecDivs       := iif(ValType(HttpGet->cRecDivs) <> "U", HttpGet->cRecDivs, "0")

		oObj:cAtuB1N   		:= iif(ValType(HttpGet->lAtuB1N) <> "U", HttpGet->lAtuB1N, "S")
		oObj:cTipoVld       := iif(ValType(HttpGet->lMulti) <> "U" .and. HttpGet->lMulti == "true", "1", "0")

		if oObj:GrvFimReemb()
			cResult := oObj:cGRVFIMREEMBRESULT
		else
			cResult := "false|"
		endIf

	else
		cResult := "false|Família não possui titular ou responsável financeiro. Entre em contato com a operadora."
	endIf
else
	cResult := "false|Ocorreu um erro na conexão, por favor tente novamente."
endIf

//Log BSW para LGPD
if ValType(httpGet->cRotinLGPD) <> "U"
	oObj:cUserCode	 := "MSALPHA"
	oObj:cUserLGPD   := HttpSession->USR_INFO[1]:cUserLogin
	oObj:cRotinLGPD  := httpGet->cRotinLGPD
	oObj:LogLGPD()
endIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLISMBJE
Verifica na BJE se o serviço está definido como medicamento
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLISMBJE()

Local oObj	:= NIL
Local cRet	:= ""
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj	:= WSPLSXFUN():new()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cTipSer		:= Httpget->cTipSer

If oObj:IsMedBJE()
	cRet := "true|" + oObj:cISMEDBJERESULT
else
	cRet := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cRet)

/*/{Protheus.doc} PPLVRSOL
Retorna dados do procedimento.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLVRSOY()
LOCAL oObj	  		:= NIL
LOCAL cResult 	:= ""
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"


//Web Service

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros de entrada

oObj:cUserCode 		:= "MSALPHA"
oObj:ccCodRDA			:= HttpGet->cCodRDA
oObj:cPLSCodUsr		:= HttpGet->cCodUs

If oObj:PLSRELYB()
	cResult := 'true|'+oObj:cPLSRELYBRESULT
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
ENDIF

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLEDITPRO
Verifica status do protocolo selecionado e, caso permitido,
abre a tela de solicitação com os dados preenchidos.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLEDITPRO()

LOCAL cHtml := ""
Local oObj 	:= NIL
Local cResult	:= ""

WEB EXTENDED INIT cHtml START "InSite"

oObj	:= WSPLSXFUN():new()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cCRecno		:= HttpGet->cRecno

HttpSession->_SOLICITACAO := { .F., NIL, NIL }

If oObj:VldPrtReem()
	//Armazena em session os valores para mostrar no cabeçalho.
	HttpSession->_SOLICITACAO[1] := .T.
	HttpSession->_SOLICITACAO[2] := oObj:OWSVLDPRTREEMRESULT
else
	cResult := "false|O status atual da solicitação não permite o uso desta funcionalidade."
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLDWLDY
Procurar pastas com arquivos de downloads,
@author PLSTEAM
@since 10.2007
@version P12
/*/
WEB FUNCTION PPLDWLDY()
Local aArqDw	:= {}
Local cPastAq 	:= ""
Local cNomArq 	:= ""
Local cResult	:= httpSession->cPLSDRDA
Local nPos		:= 0
LOCAL oObj	  	:= NIL
LOCAL cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

cNom := HttpGet->cNomArq

//Le diretorio para mostrar os arquivos disponiveis
If ! empty(cNom)
	cNom 	:= Alltrim(cNom)
	cResult := Substr(cResult, 0, Len(cResult)-1)
	nPos    := RAT("\", cResult)
	cResult := Substr(cResult, nPos, Len(cResult))
	cResult := cResult + "\" + cNom
	cResult := Strtran(cResult, "\", "/")
	cResult := "true|"+cResult
else
	cResult := "false| nenhum arquivo encontrado"
endIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGETPRO
Retorna a o prestador a partir do CRM e Estado
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGETPRO()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cCrm		:= HttpGet->cCrm
oObj:cEstado	:= HttpGet->cEstado
oObj:cCodSig	:= HttpGet->cConselho


// Retorna dados

If oObj:RDAPro()
	cResult := oObj:cRDAProRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLPROREC
Chamada da Rotina de Receitas Portal beneficiario.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLPROREC()
LOCAL cHtml 	:= ""
local nI
LOCAL aObjSess	:= {} // Variaveis para criação de Grid generica


//Exibe pagina
WEB EXTENDED INIT cHtml START "InSite"

aAdd( aObjSess, PLSXFUN_ARRAYOFSCMPGUIA():New() )

nPos := Len(aObjSess)

aAdd( aObjSess[nPos]:OWSSCMPGUIA, PLSXFUN_SCMPGUIA():New() )

aObjSess[nPos]:OWSSCMPGUIA[1]:cTipo := 'G'
aObjSess[nPos]:OWSSCMPGUIA[1]:cNome := "BrwGridProc"
aObjSess[nPos]:OWSSCMPGUIA[1]:cDescri := ""
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid := PLSXFUN_ARRAYOFSCMPGRID():NEW()

aObjSess[nPos]:OWSSCMPGUIA[1]:oWsaCols := PLSXFUN_ARRAYOFSTRING():NEW()
aObjSess[nPos]:OWSSCMPGUIA[1]:oWsaHeader := PLSXFUN_ARRAYOFSTRING():NEW()

aObjSess[nPos]:OWSSCMPGUIA[1]:oWsaCols := PLSXFUN_ARRAYOFSTRING():NEW()
aObjSess[nPos]:OWSSCMPGUIA[1]:oWsaHeader := PLSXFUN_ARRAYOFSTRING():NEW()

aObjSess[nPos]:OWSSCMPGUIA[1]:cxCols := ""
aObjSess[nPos]:OWSSCMPGUIA[1]:cxHeader := ""

for nI := 1 to 2
	aadd( aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:OWSSCmpGrid, PLSXFUN_SCMPGRID():NEW() )
next

aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[1]:cTipo := "C"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[1]:cNome := "Field_CODMED"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[1]:cDescri := "Cód. Medicamento"

aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[2]:cTipo := "C"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[2]:cNome := "Field_DESPRO"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[2]:cDescri := "Desc. Medicamento"

/*aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[3]:cTipo := "C"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[3]:cNome := "Field_F3ESPECIALIDADE"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[3]:cDescri := "Especialidade"

aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[4]:cTipo := "C"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[4]:cNome := "Field_F3TABELA"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[4]:cDescri := "Tabela"

aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[5]:cTipo := "C"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[5]:cNome := "Field_F3PROCEDIMENTO"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[5]:cDescri := "Procedimento"

aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[6]:cTipo := "RADIO"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[6]:cNome := "Field_RADIOACAO"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[6]:cDescri := "Atender"*/

HttpSession->aCmpGuia := aClone(aObjSess[nPos]:OWSSCMPGUIA)

cHtml += ExecInPage("PPLPROREC")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLGRVREC
Gravação do Cabeçalho/Item da receita B7D e B4F
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGRVREC()

LOCAL cResult := "true|"
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	  := "MSALPHA"
oObj:cProtoc 	  := HttpGet->cProtoc
oObj:cBenef 	  := HttpGet->cBenef
oObj:cCrm 		  := HttpGet->cCrm
oObj:cEstado 	  := HttpGet->cUf
oObj:cMedico	  := HttpGet->cMedico
oObj:cDtReceita	  := HttpGet->cDtReceita
oObj:cMedicamento := HttpGet->cCodMed
oObj:cCodSig       := HttpGet->cConselho

If oObj:GrvRec()
	cResult += oObj:CGRVRECRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLALTREC
Alteração Status  B7D.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLALTREC()

LOCAL cResult := "true|"
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	  := "MSALPHA"
oObj:cProtoc 	  := HttpGet->cProtoc
oObj:cBenef 	  := HttpGet->cBenef

If oObj:AltRect()
	cResult += oObj:CALTRECTRESULT
Else
	cResult := "false|"
EndIf

//Log BSW para LGPD
if ValType(httpGet->cRotinLGPD) <> "U"
	oObj:cUserCode	 := "MSALPHA"
	oObj:cUserLGPD   := HttpSession->USR_INFO[1]:cUserLogin
	oObj:cRotinLGPD  := httpGet->cRotinLGPD
	oObj:LogLGPD()
endIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCARBA1
 Rotina para carregar os beneficiários com acesso ao reemblso
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLCARBA1()

LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode		:= "MSALPHA"
oObj:cCUSRLOGIN		:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
oObj:nTpPor			:= getTpPortal()

//matricula do beneficiario selecionado para filtrar o multiselect
oObj:cMatUsu		:= IIF(valtype(httpGet->cMatric) != "U", httpGet->cMatric, "")
oObj:cPermT 		:= "1"  //Para identificar o reembolso|
oObj:cDtRecibo      	:= HttpGet->DtRecibo

// Retorna dados
If oObj:DadFrmEmp()

	nResult := Len(oObj:OWSDadFrmEmpRESULT:OWSSDADGRP)

	xCols := "["
	For nI := 1 to nResult

		xCols += "{"
		xCols +=  "0:{field:'cMatric', value:'" + oObj:OWSDadFrmEmpRESULT:OWSSDADGRP[nI]:cMatricl +   "'},"
		xCols +=  "1:{field:'cNomBnf',value:'" +  SubStr(oObj:OWSDadFrmEmpRESULT:OWSSDADGRP[nI]:cNomeBnf,1,50) +"'}" + Iif( nResult != nI ,"},","}]" )
	Next

	cResult += xCols +"|"

Else
	cResult := "false|Não há beneficiarios aptos a solicitar reembolso para a data informada do documento."
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLVERPRO
Verifica se já não possue algum protocolo em aberto
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLVERPRO()

LOCAL cResult := "true|"
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode := "MSALPHA"
oObj:cCpfCnpj 	   := HttpSession->cCpf

If oObj:VerPro()
	cResult += oObj:CVERPRORESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLMSGPOR
 Retorna mensagens do portal
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLMSGPOR()
LOCAL oObj := NIL
LOCAL cMsgs 		:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//Obj
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametro
oObj:cUSERCODE	:= "MSALPHA"
oObj:nTPPOR 	:= getTpPortal()
oObj:cROTINA 	:= IIF(valType(HttpGet->cRotina) <> "U",HttpGet->cRotina , "") //"PPLMOSPRE"
oObj:cCODMSG 	:= IIF(valType(HttpGet->cCodMsg) <> "U",HttpGet->cCodMsg , "")//HttpGet->cCodMsg
oObj:cIDIOMA 	:= IIF(valType(HttpGet->cIdioma) <> "U",HttpGet->cIdioma , "")//HttpGet->cIdioma //"POR"

if oObj:GetMsgPortal()
	cMsgs := oObj:cGETMSGPORTALRESULT
endif

WEB EXTENDED END

getLOGMon()

Return cMsgs

/*/{Protheus.doc} PPLDIGGUIP
Retorna guias de acordo com o critério selecionado.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLDIGGUIP()
LOCAL cHtml		:= ""
LOCAL cTpDIGR 	:= ""
LOCAL cResult	:= ""
LOCAL nLenCombo := 1
LOCAL oObjPar 	:= NIL
LOCAL oObjLib	:= NIL
Local oObjCbx	:= Nil
LOCAL nLen		:= IIf(Valtype(HttpSession->RDAVIEW) == "A", Len(HttpSession->RDAVIEW), 0 )
Local nI		:= 0

PRIVATE lPrestTiss 	:= .T.
PRIVATE cDataLimit 	:= ""
PRIVATE cInterPag	:= ""
PRIVATE cValParam 	:= HttpSession->cValParam

WEB EXTENDED INIT cHtml START "InSite"

oObjLib := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObjLib:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObjLib, "PLSXFUN.APW" )

oObjLib:cUSERCODE := "MSALPHA"
oObjLib:cRDACode  := ""

//RDA(s)
if nLen > 0
	for nI := 1 to nLen
		oObjLib:cRDACode	+= HttpSession->RDAVIEW[nI]:cCode + "|"
	next nI

	if right(oObjLib:cRDACode, 1) == "|" //tiro o ; final
		oObjLib:cRDACode := left(oObjLib:cRDACode, (len(oObjLib:cRDACode)-1))
	endif
else
	Return PPLSALERT( "", "Atenção", "", "W_PPLCHAIMP.APW" )
endif

//Busca Calendario de Pagamento
If oObjLib:getCalend()
	cInterPag := oObjLib:cGETCALENDRESULT
Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLCHAIMP.APW" )
EndIf

cHtml += ExecInPage( "PPLDIGGUIAS" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLBKGUI
Retorna fase das guias selecionadas para voltar para digitação
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLBKGUI()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""

LOCAL nI
LOCAL nTamI
LOCAL aString
LOCAL nCount := 0
LOCAL nTamY
LOCAL nY := 0
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXMOV():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXMOV.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cNumAut		:= HttpGet->cRecnoGuias
oObj:nAutType		:= Val(HttpGet->cTipoGuias)

If oObj:BackDigitacaoGuia()
	cResult := oObj:cBACKDIGITACAOGUIARESULT
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLTIPGUI
Retorna os tipos de guia para impressão em branco beneficiario
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLTIPGUI()
LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )


// Parametros

oObj:cUserCode	:= "MSALPHA"

//EndIf

// Retorna dados

If oObj:DadTipGui()

	nResult := Len(oObj:OWSDadTipGuiRESULT:OWSSTipGui)

	xCols := "["
	For nI := 1 to nResult

		xCols += "{"
		xCols +=  "0:{field:'cCod', value:'" + oObj:OWSDadTipGuiRESULT:OWSSTipGui[nI]:cCod +   "'},"
		xCols +=  "1:{field:'cDescri',value:'" +  SubStr(oObj:OWSDadTipGuiRESULT:OWSSTipGui[nI]:cDescri,1,25) +"'}" + Iif( nResult != nI ,"},","}]" )
	Next

	cResult += xCols +"|"
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCRRBAN - Relatório de Reembolso Analítico
@author	Renan Martins
@since		11/2015
@version	P12
@Obs
/*/
Web Function PPLCRRBAN()
Local cHtml   	:= ""
Private cTipo	:= "R"
//cTipo, para identificar se é tela de opções de reembolso ou utilização

WEB EXTENDED INIT cHtml START "InSite"

cHtml := ExecInPage("PPLCHRRAN")

WEB EXTENDED END

getLOGMon()

Return cHtml


/*/{Protheus.doc} PPLCRREUTX - Relatório de Extrato de Utilização
@author	Renan Martins.
@since		12/2015
@version	P12
@Obs 	.
/*/
Web Function PPLCRREUTX()
Local cHtml   	:= ""
Private cTipo	:= "E"
//cTipo, para identificar se é tela de opções de reembolso ou utilização

WEB EXTENDED INIT cHtml START "InSite"

cHtml := ExecInPage("PPLCHRRAN")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLCHAMCB
Carteirinha do beneficiario

@author  PLS TEAM
@version P11
@since   15.10.15
/*/
web function PPLCHAMCB()
LOCAL cHtml := ""

//Exibe pagina
WEB EXTENDED INIT cHtml START "InSite"

//Chama o formulario
cHtml += ExecInPage("PPLCHAMCB")

WEB EXTENDED END

getLOGMon()

return cHtml


/*/{Protheus.doc} 	PPLREAJ
Function da pagina PPLREAJ.aph
@author	Lucas de Azevedo Nonato
@since		23/12/2015
@version	P12
/*/
Web Function PPLREAJ()
Local cHtml   	:= ""

WEB EXTENDED INIT cHtml START "InSite"

//verificando o tipo de portal 2= Empresa, 3=Beneficiario
If HTTPSESSION->USR_INFO[1]:OWSUSERLOGPLS:NTPPORTAL == 2

	If HTTPSESSION->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:CSUBCON <> nil
		HttpSession->cMatric := HTTPSESSION->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:CCODE
	EndIf

Else

	If HTTPSESSION->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CFAMILIA <> nil
		HttpSession->cMatric := HTTPSESSION->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CFAMILIA
	EndIf

EndIf

cHtml := ExecInPage("PPLREAJ")

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} 	PPLGETFREL
Web Function da listagem de arquivos nos relatorios de pagamento PPLRELMOV

@author	Rogério Tabosa
@since		01/2016
@version	P11
/*/
Web Function PPLGETFREL()
LOCAL cResult  := ""
LOCAL cRdas	:= ""
LOCAL oObj		:= NIL
LOCAL nI		:= 0
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"


// Metodo e propriedades

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cRDACode	:= httpGet->cRdaCode


// Lista de arquivos

If oObj:getArqRel()
	cResult +=	oObj:cGETARQRELRESULT
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

getLOGMon()

return PLSDECODE(cResult)


/*/{Protheus.doc} 	PPLBLORE
Web Function da verificação de bloqueio do usuário para fazer o reembolso.
@author	Lucas Nonato
@since		03/2016
@version	P12
/*/
Web Function PPLBLORE()
LOCAL oObj		:= nil
LOCAL cResult  	:= "true|"
LOCAL cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode				:= "MSALPHA"
oObj:cDocObrig    			:= HttpGet->lDocObrig
oObj:oWSITEMREEMB 			:= PLSXFUN_SITENSREEMB():New()

oObj:oWSITEMREEMB:cCodPad 	:= HttpGet->Field_CODPAD
oObj:oWSITEMREEMB:cCodPro 	:= HttpGet->Field_CODPROC

If valType(HttpGet->Field_VALOR) == "C"
	oObj:oWSITEMREEMB:cVlrPro := StrTran(strTran(HttpGet->Field_VALOR, ",", ""),".","")
else
	oObj:oWSITEMREEMB:cVlrPro := '0'
Endif

oObj:oWSITEMREEMB:cUsoC   		:= iif(HttpGet->Field_USOCONST == "1", "1", "0")
oObj:oWSITEMREEMB:cQtdPro 		:= HttpGet->Field_QTD
oObj:oWSITEMREEMB:cMatric 		:= HttpGet->Field_MATRIC
oObj:oWSITEMREEMB:cCodRec 		:= HttpGet->Field_CODREC
oObj:oWSITEMREEMB:cCodMed 		:= HttpGet->Field_CODMED
oObj:oWSITEMREEMB:cSeqMed 		:= HttpGet->Field_SEQMED
oObj:oWSITEMREEMB:cTipDoc 		:= HttpGet->Field_TIPDOC
oObj:oWSITEMREEMB:cCPFCNPJ		:= HttpGet->Field_CPFCNPJ
oObj:oWSITEMREEMB:cNomRDA 		:= HttpGet->Field_NOMEPRE
oObj:oWSITEMREEMB:cNroDoc 		:= HttpGet->Field_NUMDOC
oObj:oWSITEMREEMB:dDatDoc 		:= CtoD(HttpGet->Field_DTEMIS)
oObj:oWSITEMREEMB:cTipSer 		:= HttpGet->Field_TIPSER

// Retorna dados
If oObj:BloqReem()

	cResult += oObj:cBLOQREEMRESULT

Else
	cResult := "false|" + AllTrim(StrTran(PWSGetWSError( "" ),":",""))
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLGUIBCO
Chamada da Rotina de impressão de guias TISS em branco
@author PLSTEAM
@since 10.2007
@version P12
/*/
Web Function PPLGUIBCO()
LOCAL cHtml 	:= ""
LOCAL cResult	:= ""


//Exibe pagina

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLGUIBCO")

WEB EXTENDED END

getLOGMon()

Return cHtml


/*/{Protheus.doc} PPLRDEB
Chamada da tela para geração do relatório de quitação de débitos no Portal
@author Oscar Zanin
@since 27/04/2016
@version P12
/*/
Web Function PPLRDEB()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLRDEB")

WEB EXTENDED END

getLOGMon()

Return cHtml


/*/{Protheus.doc} PPLTBLVALOR
Chamada da tela de verificação de elegibilidade de procedimentos e solicitação de tabela

@author Renan Martins
@since 29/04/2016
@version P12
/*/
Web Function PPLTBLVALOR()
LOCAL cHtml	:= ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PPLROTDESC" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLMEMORET
Retorna o conteudo memo de um campo pelo recno
@author PLSTEAM
@since 05/05/16
/*/
Web Function PPLMEMORET()
LOCAL cResult  	:= "true|"
LOCAL cRecno  := HttpGet->cRecno
LOCAL cAlias  := HttpGet->cAlias
LOCAL cCampo  := HttpGet->cCampo
LOCAL nResult
LOCAL nI
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )


// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:CcRecno	:= cRecno
oObj:cAlias	:= cAlias
oObj:CCampos	:= cCampo

If oObj:RETMEMOGEN()

	xCols := oOBJ:OWSRETMEMOGENRESULT:OWSSRETOBSPROT[1]:CcMsg

	cResult += xCols + "|"
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)


/*/{Protheus.doc} PPLFLAINT
Altera a flag da interação no anexo

@author Karine Riquena Limp
@since 20/07/2016
@version P12
/*/
Web Function PPLFLAINT()
local cResult 	:= "true|"
local oObj 		:= WSPLSXFUN():New()
local lPendente	:= valtype(HttpGet->lPendente) <> "U" .and. HttpGet->lPendente == "true"
LOCAL cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros
oObj:cUserCode	:= "MSALPHA"
oObj:cChave		:= HttpGet->cChave
oObj:cAlias		:= HttpGet->cAlias
oObj:lPendente   	:= lPendente
oObj:cSequen		:= HttpGet->cSequen

If oObj:AltFlaInt()

	cResult := oOBJ:cAltFlaIntResult

Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)


/*/{Protheus.doc} PPLGRCAAUT
Gravar apenas os campos após autorização

@author Renan Martins
@since 09/06/2016
@version P12
/*/
Web Function PPLGRCAAUT()
LOCAL cVar 		:= HttpGet->cElmts
Local cVarIts 	:= HttpGet->cElmtsIts
LOCAL cResult 	:= 'true|'
LOCAL cHtml := ""
LOCAL nI		:= 0

WEB EXTENDED INIT cHtml START "InSite"

//OBJETO WEBSERVICE
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros
oObj:cChave		:= cVar
oObj:cCmdChave	:= cVarIts

If oObj:ATGUIAAAUT()

	cResult:= oOBJ:cATGUIAAAUTRESULT

Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)




/*/{Protheus.doc} PPLRETCRMF
Retorna Críticas da BDX no Digitação Off-Line

@author Renan Martins
@since 07/2016
@version P12
/*/
Web Function PPLRETCRMF()
LOCAL cResult  	:= "true|"
LOCAL cChave  := HttpGet->cChave
LOCAL nI
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"


// oBJ

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )


// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cChave  	:= cChave

If oObj:RETCRIMF()

	cResult += oOBJ:cRETCRIMFRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)


/*/{Protheus.doc} PPLVLBLBen

@author Oscar Zanin
@since 07/2016
@version P12
/*/
Web Function PPLVLBLBen()
Local cResult := "true|"
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode := "MSALPHA"
oObj:cBenef    := IIF( ValType(Httpget->cBenef) == "U" , "", Httpget->cBenef )
oObj:cDATASTRING	 := IIF( ValType(HttpGet->cDatPro) == "U", "", HttpGet->cDatPro )

If oObj:VBlqBen()
	cResult += oOBJ:cVBLQBENRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)



/*/{Protheus.doc} PPLPRORINT
Chama tela de prorrogação de internação

@author  Rodrigo Morgon
@version P12
@since   04.07.16
/*/
Web Function PPLPRORINT()
LOCAL cHtml := ""
Local cTISSVer := ""
local aRDA := {}

WEB EXTENDED INIT cHtml START "InSite"

If Len(HttpSession->RDAVIEW) >= 1
	HttpSession->cRdaRel := HttpSession->RDAVIEW[1]:cCODE
	HttpSession->cCodLoc := HttpSession->RDAVIEW[1]:cCodLoc

	//Recupera a versão da TISS da RDA
	aRDA := ClassDataArr(HttpSession->RDAVIEW[1])
	If aScan(aRDA,{|x| AllTrim(x[1]) == "CTISSVER"  }) > 0
		cTISSVer := HttpSession->RDAVIEW[1]:cTissVer
	EndIf
	HttpSession->cTISSVer := cTISSVer
	HttpSession->cTp		 := "11"

EndIf

//Chama o formulario
cHtml += ExecInPage("PPLPRORINT")

WEB EXTENDED END

getLOGMon()

Return cHtml


/*/{Protheus.doc} PPLGETPATD
Function para pegar o número do protocolo de atendimento
@author	Lucas Nonato
@since		08/08/2016
@version	P11
/*/
Web Function PPLGETPATD()
Local cHtml		:= ""
Local oObj		:= nil

WEB EXTENDED INIT cHtml START "InSite"

If !(HttpGet->lAnexos == 'true') .And. ValType(HttpSession->aVldCartao) == 'A' .And. HttpSession->aVldCartao[10]
	cResult := "false|Para usuários de intercambio é necessário a digitação do protocolo"

Else
	oObj := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLSXFUN.APW" )

	oObj:cUserCode	:= "MSALPHA"

	If oObj:getNumProtoc()
		cHtml += "true|"+oObj:cGETNUMPROTOCRESULT + "|" + HttpGet->bID + "|" + HttpGet->cID
	Else
		cHtml := "false|"+StrTran(PWSGetWSError( "" ),":","")
	EndIf

	//Log BSW para LGPD
	if ValType(httpGet->cRotinLGPD) <> "U"
		oObj:cUserCode	 := "MSALPHA"
		oObj:cUserLGPD   := HttpSession->USR_INFO[1]:cUserLogin
		oObj:cRotinLGPD  := httpGet->cRotinLGPD
		oObj:LogLGPD()
	endIf

EndIf

WEB EXTENDED END

getLOGMon()

return PLSDECODE(cHtml)


/*/{Protheus.doc} PPLVLDPROT
Web Function para validação do protocolo de atendimento

@author	Lucas Nonato
@since		09/08/2016
@version	P11
/*/
Web Function PPLVLDPROT()
Local cResult	:= ""
Local cHtml	:= ""
Local oObj		:= nil

WEB EXTENDED INIT cHtml START "InSite"
cNumProto := HttpGet->cProtoc
If ValType(HttpSession->aVldCartao) == 'A'
	cMatric := HttpSession->aVldCartao[2]
Else
	cMatric := HttpGet->cMatric

EndIF

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cNumProtoc	:= cNumProto
oObj:cMatUsu	:= cMatric

If oObj:VldNumProtoc()
	If !Empty(oObj:cVLDNUMPROTOCRESULT)
		cResult +=	"false|Erro na validação do Protocolo" + Chr(13) + oObj:cVLDNUMPROTOCRESULT
	Else
		cResult +=	"true"
	EndIf
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)


/*/{Protheus.doc} PPLINTPROTOC
Web Function que chama a tela de integração do protocolo

@author	Lucas Nonato
@since		08/08/2016
@version	P11
/*/
Web Function PPLINTPROTOC()
Local cHtml			:= ""


WEB EXTENDED INIT cHtml START "InSite"
HttpSession->cMatInterc := HttpGet->cMatric
cHtml := ExecInPage( "PPLSPROTOC" )

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cHtml)


/*/{Protheus.doc} PPL773WEBRN
Web Function para pegar o número do protocolo da Unimed Origem

@author	 Lucas Nonato
@since	 08/08/2016
@version P11
/*/
Web Function PPL773WEBRN()
Local cHtml		:= ""
Local oObj		:= nil
Local cIsAnexo	:= "|false"
WEB EXTENDED INIT cHtml START "InSite"
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )
oObj:cUserCode	:= "MSALPHA"
oObj:cDDD 		:= HttpGet->cDDD
oObj:cTelefone 	:= HttpGet->cTel
oObj:cSentimento:= HttpGet->cSent
oObj:cProtAnt 	:= HttpGet->cProtAnt
oObj:cTxtLivre 	:= HttpGet->cTxtLivre

If ValType(HttpSession->aVldCartao) == "A" .And. Empty(HttpSession->cMatInterc)
	oObj:cMatric 	:= HttpSession->aVldCartao[2]
Else
	oObj:cMatric 	:= HttpSession->cMatInterc
	cIsAnexo	:= "|true"
EndIf

If oObj:Protocolo()
	cHtml := oObj:cPROTOCOLORESULT + cIsAnexo
EndIF

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cHtml)


/*/{Protheus.doc} PPLVERINT
Web Function para verificar se a integração está ativada.

@author	Lucas Nonato
@since		08/08/2016
@version	P11
/*/
Web Function PPLVERINT()
Local cHtml	:= ""

WEB EXTENDED INIT cHtml START "InSite"

If httpSession->lPL395WS
	cHtml := "true|" + Iif(ValType(HttpGet->cMatric) == "C", HttpGet->cMatric, "")
Else
	cHtml := "false|Para usuários de intercambio é necessário a digitação do protocolo"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cHtml)


/*/{Protheus.doc} PPLdtFut

@author Oscar Zanin
@since 07/2016
@version P12
/*/
Web Function PPLdtFut()
Local cResult := "true|"
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode := "MSALPHA"
oObj:cDATASTRING	 := IIF( ValType(HttpGet->cDatPro) == "U", "", HttpGet->cDatPro )
oObj:cBenef    := IIF( ValType(HttpSession->TrilhaCard) == "U" , "", HttpSession->TrilhaCard )

If oObj:VBlqBen()
	cResult += oOBJ:cVBLQBENRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)


/*/{Protheus.doc} PPLUPDB1N

@author Karine Riquena Limp
@since 28/09/2016
@version P12
@description Atualiza todas os itens da B1N quando altera o cabeçalho
               no reembolso
/*/
Web Function PPLUPDB1N()
Local cResult := "true|"
local oObj := WSPLSXFUN():New()
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode := "MSALPHA"
oObj:cCodSol		:= HttpGet->cCodSol
oObj:cCPFCNPJ		:= HttpGet->cCpfCnpj
oObj:cNomRdaNRef	:= HttpGet->cNomRda
oObj:cTipo			:= HttpGet->cTipDoc
oObj:cNumDoc		:= HttpGet->cNroDoc
oObj:cDocEmi		:= HttpGet->cDatDoc

If oObj:UpdB1N()
	cResult += oOBJ:cUpdB1NRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)


/*/{Protheus.doc} PPLBENINT
Web Function para verificar se a integração está ativada.

@author	Lucas Nonato
@since		08/08/2016
@version	P11
/*/
Web Function PPLBENINT()

Local cHtml	:= ""
Local cNumCart:= HttpGet->cNumCart

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )
oObj:cUSERCODE 	:= "MSALPHA"
oObj:cUserCardNumber := cNumCart

If oObj:RetItercamb()
	cHtml := oObj:cRetItercambRESULT
Else
	cHtml := ""
EndIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cHtml)


/*/{Protheus.doc} PPLDADPES
Web Function da pagina PPLSDADPES.aph

@Project
@author	Lucas Nonato
@since		29/10/2015
@version	P12

/*/
Web Function PPLDADPES()
local cHtml   	:= ""
local oObjLGPD	:= nil

WEB EXTENDED INIT cHtml START "InSite"	 // Garante que existe uma sessão válida.

//gravar log do LGPD *****
oObjLGPD := WSPLSXFUN():New()
iif (!Empty(PlsGetAuth()), oObjLGPD:_HEADOUT := { PlsGetAuth() },)
WsChgURL( @oObjLGPD, "PLSXFUN.APW" )
oObjLGPD:cUserCode	 := "MSALPHA"
oObjLGPD:cUserLGPD   := HttpSession->USR_INFO[1]:cUserLogin
oObjLGPD:cRotinLGPD  := 'PPLDADPES'
oObjLGPD:LogLGPD()
//**********

HttpSession->aDados := {}

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj,"PLSXFUN.APW" )
oObj:cUSERCODE 	:= "MSALPHA"
oObj:cMatric 	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CBENEFI
oObj:RetDadBen()

aadd( HttpSession->aDados,{	OOBJ:oWSRETDADBENRESULT:CCNOMEUSUARI,;
	OOBJ:OWSRETDADBENRESULT:CCMATRICULA,;
	OOBJ:OWSRETDADBENRESULT:CDDTNACTO,;
	OOBJ:OWSRETDADBENRESULT:CCCNESUSU,;
	OOBJ:OWSRETDADBENRESULT:CCSUSEP,;
	OOBJ:OWSRETDADBENRESULT:CCSEGASSPL,;
	OOBJ:OWSRETDADBENRESULT:CCNUMREGOPE,;
	OOBJ:OWSRETDADBENRESULT:CCCONTATOOPE,;
	OOBJ:OWSRETDADBENRESULT:CCCONTATOANS,;
	OOBJ:OWSRETDADBENRESULT:CDCPT,;
	OOBJ:OWSRETDADBENRESULT:CCTPACOMODA,;
	OOBJ:OWSRETDADBENRESULT:CCCONTRATACA,;
	OOBJ:OWSRETDADBENRESULT:CCABRANG,;
	OOBJ:oWSRETDADBENRESULT:CCNOMPRO,;
	OOBJ:OWSRETDADBENRESULT:CCNFANTAZOPE,;
	OOBJ:OWSRETDADBENRESULT:CCNFAADMBENE,;
	OOBJ:OWSRETDADBENRESULT:CCRZSOCIAL,;
	OOBJ:OWSRETDADBENRESULT:CDDTVIGPL,;
	OOBJ:OWSRETDADBENRESULT:CCNUMCON,;
	OOBJ:OWSRETDADBENRESULT:CDDATCON,;
	OOBJ:OWSRETDADBENRESULT:CDDTMAXCON,;
	OOBJ:OWSRETDADBENRESULT:CCINFOPLAN,;
	OOBJ:OWSRETDADBENRESULT:CCINFORMACOE,;
	OOBJ:OWSRETDADBENRESULT:CCCARENCAMB,;
	OOBJ:OWSRETDADBENRESULT:CCCARENCHOS,;
	OOBJ:OWSRETDADBENRESULT:CCCARENCPAT,;
	OOBJ:OWSRETDADBENRESULT:CCCARENCODO} )

cHtml := ExecInPage("PPLDADPES")

WEB EXTENDED END

getLOGMon()

return cHtml



/*/{Protheus.doc} PPLEXFINA
Chamada do relatório de extrato financeiro

@Project
@author	Thiago Guilherme
@since		30.11.2015
@version	P12

/*/
Web Function PPLEXFINA()
LOCAL cHtml 	:= ""
LOCAL cResult	:= ""


//Exibe pagina

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLEXFIN")

WEB EXTENDED END

getLOGMon()

Return cHtml


/*/{Protheus.doc} PPLGETLAN
Retorna os tipos de lançamentos

@Project
@author	Totvs
@since		18.06.2009
@version	P12

/*/
WEB FUNCTION PPLGETLAN()

LOCAL cResult := "true|"
LOCAL nI	  := NIL
LOCAL nResult := NIL
LOCAL xCols	  := NIL

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUSERCODE	:= "MSALPHA"

If oObj:getLancam()

	nResult := Len(oObj:OWSGETLANCAMRESULT:OWSSTipGui)

	xCols := iif(nResult > 0, "[", "[]")
	For nI := 1 to nResult

		xCols += "{"
		xCols +=  "0:{field:'cCod', value:'" + oObj:OWSGETLANCAMRESULT:OWSSTipGui[nI]:cCod +   "'},"
		xCols +=  "1:{field:'cDescri',value:'" +  SubStr(oObj:OWSGETLANCAMRESULT:OWSSTipGui[nI]:cDescri,1,25) +"'}" + Iif( nResult != nI ,"},","}]" )
	Next

	cResult += xCols +"|"
Else
	cResult := "false|"
EndIf

Return PLSDECODE(cResult)


/*/{Protheus.doc} PPLPROD
Retorna os Produtos

@Project
@author	Totvs
@since		18.06.2009
@version	P12

/*/
WEB FUNCTION PPLPROD()

LOCAL cResult := "true|"
LOCAL nI	  := NIL
LOCAL nResult := NIL
LOCAL xCols	  := NIL

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUSERCODE	:= "MSALPHA"

If oObj:getProdutos()

	nResult := Len(oObj:oWSGETPRODUTOSRESULT:oWSPRODUTOSLIST)

	xCols := "["
	For nI := 1 to nResult

		xCols += "{"
		xCols +=  "0:{field:'cCod', value:'" + oObj:oWSGETPRODUTOSRESULT:oWSPRODUTOSLIST[nI]:CCODIGO +   "'},"
		xCols +=  "1:{field:'cDescri',value:'" +  oObj:oWSGETPRODUTOSRESULT:oWSPRODUTOSLIST[nI]:CNOME +"'}" + Iif( nResult != nI ,"},","}]" )
	Next

	cResult += xCols +"|"
Else
	cResult := "false|"
EndIf

Return PLSDECODE(cResult)




/*/{Protheus.doc} PPLVlItRe
Valida itens negados para reembolso

@author Francisco Edcarlo
@since 03/2017
@version P12
/*/
Web Function PPLVlItRe()

Local oObj 	:= NIL
Local cResult	:= ""

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros

oObj:cUserCode	:= "MSALPHA"
oObj:cCodSol	:= httpGet->cCodSol


If oObj:VldItReemb()
	cResult := oObj:cVldItReembRESULT
else
	cResult := "false|"
EndIf

//Log BSW para LGPD
if ValType(httpGet->cRotinLGPD) <> "U"
	oObj:cUserCode	 := "MSALPHA"
	oObj:cUserLGPD   := HttpSession->USR_INFO[1]:cUserLogin
	oObj:cRotinLGPD  := httpGet->cRotinLGPD
	oObj:LogLGPD()
endIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)


/*/{Protheus.doc} PPLHABBOT
Web Function para anexos medicamento uso constante.

@author	Lucas Nonato
@since		08/08/2016
@version	P11
/*/
Web Function PPLHABBOT()

Local cHtml	:= ""
Local cRecno:= HttpGet->cRecno
Local cChave:= HttpGet->cChave


oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )
oObj:cUSERCODE 	:= "MSALPHA"

oObj:ccRecno := Alltrim(cRecno)
oObj:cChave := Alltrim(cChave)

If oObj:HabBotao()
	cHtml := oObj:cHabBotaoresult
Else
	cHtml := "true|"
EndIf

Return PLSDECODE(cHtml)


/*/{Protheus.doc} PPLCANPLA
Web Function para carregar pagina de cancelamento de planos

@author	Lucas Nonato
@since		08/08/2016
@version	P11
/*/
Web Function PPLCANPLA()
LOCAL cHtml := ""


//Chama formulario
WEB EXTENDED INIT cHtml

If ValType(HttpSession->aFamBloq) <> "A"
	HttpSession->aFamBloq := {}
EndIf

//Ws
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros
oObj:cUserCode	:= "MSALPHA"
oObj:cCUSRLOGIN	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE

If oObj:getFamBloq()
	HttpSession->aFamBloq := oObj:oWSGETFAMBLOQRESULT:oWSFAMBLOQLIST
EndIf

cHtml += ExecInPage("PPLCANPLA")

WEB EXTENDED END

getLOGMon()

Return cHtml


/*/{Protheus.doc} PPLCONFPLA
Web Function para confirmacao do cancelamento de planos

@author	Lucas Nonato
@since		08/08/2016
@version	P11
/*/
Web Function PPLCONFPLA()
Local cHtml := "false|"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros
oObj:cUserCode	:= "MSALPHA"
oObj:cCUSRLOGIN	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
oObj:ccRecno    := HttpGet->cRecSelec

If oObj:procSolicBloq()
	cHtml := oObj:cPROCSOLICBLOQRESULT
EndIf

//Log BSW para LGPD
if ValType(httpGet->cRotinLGPD) <> "U"
	oObj:cUserCode	 := "MSALPHA"
	oObj:cUserLGPD   := HttpSession->USR_INFO[1]:cUserLogin
	oObj:cRotinLGPD  := httpGet->cRotinLGPD
	oObj:LogLGPD()
endIf

Return PLSDECODE(cHtml)



/*/{Protheus.doc} PPLRELCPL
Web Function para exibicao de relatorios da RN 412

@author	Renan Sakai
@since		08/08/2016
@version	P11
/*/
Web Function PPLRELCPL()
LOCAL cHtml := ""

//Ws
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

If ValType(HttpSession->aSolCanPla) <> "A"
	HttpSession->aSolCanPla := {}
EndIf

//Parametros
oObj:cUserCode	:= "MSALPHA"
oObj:cCUSRLOGIN	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
oObj:ccRecno    := "0"

If oObj:getSolCanPla()
	HttpSession->aSolCanPla := oObj:oWSGETSOLCANPLARESULT:oWSSOLICCANPLALIST
EndIf

//Chama formulario
WEB EXTENDED INIT cHtml

cHtml += ExecInPage("PPLRELCPL")

WEB EXTENDED END

getLOGMon()

Return cHtml


/*/{Protheus.doc} PPLINFCPL
Web Function para exibicao de busca de informacoes de uma solicitacao de cancelamento de
plano - RN 412

@author	Renan Sakai
@since		08/08/2016
@version	P11
/*/
Web Function PPLINFCPL()
Local cHtml := "true|"

//Ws
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros
oObj:cUserCode	:= "MSALPHA"
oObj:cCUSRLOGIN	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
oObj:ccRecno    := HttpGet->cRecno

If oObj:getSolCanPla()
	HttpSession->aSolCanPla := oObj:oWSGETSOLCANPLARESULT:oWSSOLICCANPLALIST
EndIf

Return cHtml


/*/{Protheus.doc} PPLINFCPL
Chama pagina com informacoes de uma solicitacao de cancelamento de plano

@author	Renan Sakai
@since		08/08/2016
@version	P11
/*/
Web Function PPLCPLPOP()
Local cHtml := ""

//Chama formulario
WEB EXTENDED INIT cHtml

cHtml += ExecInPage("PPLCPLPOP")

WEB EXTENDED END

getLOGMon()

Return cHtml


/*/{Protheus.doc} PPLCRTXT
Críticas do XML da submissão via Portal em base 64

@author	Renan Martins
@since		06/2017
@version	P11
/*/
Web Function PPLCRTXT()

Local cResult	:= ""
Local chtml 	:= ""

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )
oObj:cUSERCODE 	:= "MSALPHA"

//Alimenta os atributos do objeto com os respectivos valores
oObj:cBusca	:= HttpGet->Field_SEQUEN

if oObj:RetCriTXT()
	cResult := oObj:cRETCRITXTRESULT
endif

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLDUPGUI
Verifica se a guia que esta sendo digitada pode estar em duplicidade
@author victor.silva
@since 20/06/2017
/*/
Web Function PPLDUPGUI()
local aData	 	:= {}
local cAno		:= ""
local cMes		:= ""
local cDia		:= ""
local cHtml		:= ""
local cResult	:= "true|N|--"

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros
oObj:cUserCode			:= "MSALPHA"
oObj:cRdaCode			:= HttpGet->cRda
oObj:cTipGui			:= HttpGet->cTpGui
oObj:cNumGuiRef			:= HttpGet->cNumGui
oObj:cUserCardNumber	:= HttpGet->cMatric

// Trata a data para o formato 'AAAAMMDD'
aData 			:= StrTokArr(AllTrim(HttpGet->cDate),"-")
cAno			:= StrZero(Val(aData[1]),4)
cMes			:= StrZero(Val(aData[2]),2)
cDia			:= StrZero(Val(aData[3]),2)
oObj:cDatGuia	:= cAno + cMes + cDia

if oObj:isDupGui()
	cResult := oObj:cIsDupGuiRESULT
endif

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)


/*/{Protheus.doc} PPLVerSInt
Verifica a Solicitação de Internação para a Guia de Resumo.

@author  Roberto Arruda
@version P12
@since   08.03.16
/*/
Web Function PPLVerSInt()
Local cHtml 	:= ""
Local cTISSVer 	:= ""
Local cResult 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

//Web Service
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros de entrada
oObj:cUserCode 		:= "MSALPHA"
oObj:cNumGuiRef  	:= HttpGET->cCodGuia
oObj:cDatGuia		:= HttpGET->dDtaAtd
oObj:cRDACode		:= HttpGET->cRda

If oObj:VerGuiInt()
	cResult :=	oObj:cVerGuiIntRESULT
Else
	cResult := "false| ERRO"
ENDIF

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)


/*/{Protheus.doc} PLSRETCODP
Retorna codigo do profissional de saude

@author		totvs team
@since		29/06/2017
@version	P11
/*/
function PLSRETCODP( cCnpjCpfSol,cProSol )
	local cRet := ''

	oObj := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLSXFUN.APW" )

	oObj:cUSERCODE 	:= "MSALPHA"
	oObj:cCpfCnpj	:= cCnpjCpfSol
	oObj:cCodProf	:= cProSol

	if( oObj:RetProSau())
		cRet := oObj:cRETPROSAURESULT
	endIf

Return cRet

/*/{Protheus.doc} PPLCRPROT
Protocolo

@author	André Dini
@since		07/2017
@version	P11
/*/
Web Function PPLCRPROT()
Local cResult	:= ""
Local chtml 	:= ""

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )
oObj:cUSERCODE 	:= "MSALPHA"

//Alimenta os atributos do objeto com os respectivos valores
oObj:cBusca	:= HttpGet->cRecno
oObj:cTipBusca  := HttpGet->cTipRel

if oObj:RetCriPROT()
	cResult := oObj:cRETCRIPROTRESULT
endif

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLSREDIR
Alteração cadastral

@author	André Dini
@since		10/2017
@version	P12.1.17
/*/
Web Function PPLSREDIR()
Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml := ExecInPage("PPLSREDIR")

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cHtml)

/*/{Protheus.doc} PPLRETFAC
Retorna as faces que estão atreladas com o dente.
@author andre.dini
@since 15/05/2017
/*/
Web Function PPLRETFAC()
Local cResult	:= ""
Local cCodDente	:= HttpGet->cCodDente
Local cCodPad	:= HttpGet->cCodPad
Local cCodPro	:= HttpGet->cCodPro

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )
oObj:cUSERCODE 	:= "MSALPHA"

//Alimenta os atributos do objeto com os respectivos valores
oObj:cCodDente	:= cCodDente
oObj:cCodPad	:= cCodPad
oObj:cCodPro	:= cCodPro

if oObj:RetVldDent()
	cResult := oObj:cRetVldDentRESULT
endif

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLCBOXGEN
Retorna valores para combo box generico.
@author francisco.edcarlo
@since 15/05/2017

@param cAliAux   - Alias que será utilizado para uma consulta secundária
@param cIndicAux - Indice da tabela secundária que será utilizada
@param cChaveAux - grupo de campos da tabela principal que será utilizada para
				   posicionamento da tabela secundária
@param cCampoAux - Campo da tabela secundária que retornará o valor correspondente

@obs Para os parâmetros acima poderá ser usado como exemplo a codificação da função Loadproduto
	 que foi criada no JSPLS
/*/
Web Function PPLCBOXGEN()
Local cResult	 := ""
Local cAlias	 := HttpGet->cAlias
Local cDados	 := HttpGet->cDados
Local cWhere	 := HttpGet->cWhere
Local cAliAux    := Iif(!Empty(HttpGet->cAliAux),HttpGet->cAliAux,"")
Local cIndiceAux := Iif(!Empty(HttpGet->cIndiceAux),HttpGet->cIndiceAux,"")
Local cChaveAux	 := Iif(!Empty(HttpGet->cChaveAux),HttpGet->cChaveAux,"")
Local cCampoAux	 := Iif(!Empty(HttpGet->cCampoAux),HttpGet->cCampoAux,"")
Local cCodLogin  := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
Local cTpPortal  := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:NTPPORTAL //1=Prestador;2=Empresa;3=Beneficiario
Local cContPrt   := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:CCODE
Local cMatricPrt := ""
Local lPesFis	 := .F.
Local aCodPlan	 := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA
Local cCodPlan   := Iif(Len(aCodPlan) > 0,HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CCODPLA,"")
Local cDesPlan   := Iif(Len(aCodPlan) > 0,HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CDESPLA,"")

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )
oObj:cUSERCODE 	:= "MSALPHA"

//Alimenta os atributos do objeto com os respectivos valores
oObj:cAlias		:= cAlias
oObj:cDados		:= cDados
oObj:cWhere		:= cWhere
oObj:cAliAux	:= cAliAux
oObj:cIndiceAux	:= cIndiceAux
oObj:cChaveAux	:= cChaveAux
oObj:cCampoAux	:= cCampoAux
oObj:cCodLogin	:= cCodLogin
oObj:cTpPortal	:= cValTochar(cTpPortal)
oObj:cContPrt    := cContPrt
If cTpPortal == 3
	oObj:cMatricPrt := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CBENEFI
Else
	oObj:cMatricPrt := ""
EndIF

If Empty(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:CNUMCON);
		.And. Empty(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:CVERCON);
		.And. Empty(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:CSUBCON)

	lPesFis := .T.
EndIf

If !lPesFis

	if oObj:getCboxGen()
		cResult := oObj:cgetCboxGenRESULT
	endif
Else
	cResult := "true|PFBLOQ;"+Alltrim(cCodPlan)+";"+Alltrim(cDesPlan)
EndIf
Return PLSDECODE(cResult)


/*/{Protheus.doc} PPLVLDDEFA
Verifica se o dente/face informado existem
@author Renan Sakai
@since 20/07/2018
/*/
Web Function PPLVLDDEFA()
Local cResult	:= ""
Local cTipo     := HttpGet->cTipo
Local cCodPad	:= HttpGet->cCodPad
Local cCodPro	:= HttpGet->cCodPro
Local cCodDente	:= HttpGet->cCodDente
Local cCodFace := HttpGet->cCodFace

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )
oObj:cUSERCODE 	:= "MSALPHA"

//Alimenta os atributos do objeto com os respectivos valores
oObj:cCodPad	:= cCodPad
oObj:cCodPro	:= cCodPro
oObj:cCodDente	:= cCodDente
oObj:cCodFace   := cCodFace

if cTipo == "D"
	if oObj:VldDente()
		cResult := oObj:cVldDenteRESULT
	endif
elseIf cTipo == "F"
	if oObj:VldFace()
		cResult := oObj:cVldFaceRESULT
	endif
endIf

Return PLSDECODE(cResult)



/*/{Protheus.doc} PPLRADIO
Verifica se existe guia de radioterapia
@author
@since 25/09/2018
/*/
Web Function PPLRADIO()

Local cResult	:= ""
Local cNumAut     := HttpGet->cNumAut

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )
oObj:cUSERCODE 	:= "MSALPHA"

//Alimenta os atributos do objeto com os respectivos valores
oObj:cNumAut	:= cNumAut

if oObj:getRadio()
	cResult := oObj:cgetRadioRESULT
endif

Return PLSDECODE(cResult)


/*/{Protheus.doc} PPLCAREBEN
Chama a pagina de consulta de classes de carencia no Portal
@author Roberto Barbosa
@since 09/10/2018
@version P12
/*/
Web Function PPLCAREBEN()
LOCAL cHtml := ""

//Chama formulario
WEB EXTENDED INIT cHtml

If ValType(HttpSession->aFamBloq) <> "A"
	HttpSession->aFamBloq := {}
EndIf

//Ws
oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros
oObj:cUserCode	:= "MSALPHA"
oObj:cCUSRLOGIN	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE

If oObj:getFamBloq()
	HttpSession->aFamBloq := oObj:oWSGETFAMBLOQRESULT:oWSFAMBLOQLIST
EndIf

cHtml += ExecInPage( "PPLCAREBEN" )

WEB EXTENDED END

getLOGMon()

Return cHtml

/*/{Protheus.doc} PPLRETCAR
Retorna as classes de carencias do beneficiario para o portal
@author Roberto Barbosa
@since 09/10/2018
@version P12
/*/
Web Function PPLRETCAR(cRec)

LOCAL cRet := "true|"
LOCAL aResult := {}

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

If ValType(HttpSession->aCarenBenefi) <> "A"
	HttpSession->aCarenBenefi := {}
EndIf

//Parametros
oObj:cUserCode	:= "MSALPHA"
oObj:cCUSRLOGIN	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
oObj:ccRecno    := HttpGet->cRecno

If oObj:CarenBenefi()
	HttpSession->aCarenBenefi := oObj:oWSCARENBENEFIRESULT:oWSCARENBENLIST
EndIf

//retonar false para exibir mensagem que não possui informação
If EMPTY(HttpSession->aCarenBenefi)
	cRet += "false"
EndIf
Return cRet

/*/{Protheus.doc} PPLCARBPOP
Chama pagina com informacoes das classes de carencia do beneficiario
@author	Roberto Barbosa
@since		09/10/2018
@version	P12
/*/
Web Function PPLCARBPOP()
Local cHtml := ""

//Chama formulario
WEB EXTENDED INIT cHtml

cHtml += ExecInPage("PPLCARBPOP")

WEB EXTENDED END

getLOGMon()

Return cHtml




/*/{Protheus.doc} PPLUPLOADG
Upload de Guias
@author PLSTEAM
@since 21/11/2018
@version P12
/*/
Web Function PPLUPLOADG()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


cHtml += ExecInPage( "PPLUPLOADG" )

WEB EXTENDED END

getLOGMon()

Return cHtml




/*/{Protheus.doc} PPLPROTPAG
Consulta solicitação de protocolo
@author PLSTEAM
@since 21/11/2018
@version P12
/*/
Web Function PPLPROTPAG()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


cHtml += ExecInPage( "PPLPROTPAG" )

WEB EXTENDED END

getLOGMon()

Return cHtml




/*/{Protheus.doc} PPLCBKU
Consulta Profissional solicitante ou executante.
@author PLSTE
@since 04/12/2018
@version P12
/*/
Web Function PPLCBKU()

Local oObj 		:= NIL
Local cResult	:= ""
Local cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"

if empty(httpGet->cCodSol)

	oObj:cCUsrLogin 	 := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
	oObj:cNumCrm         := HttpGet->cNrCrm
	oObj:cSgCrm          := HttpGet->cSgCrm
	oObj:cMonSol         := HttpGet->cMonSol
	oObj:cCodEst         := HttpGet->cEstado

	if oObj:ConsSolProf()
		cResult := oObj:cCONSSOLPROFRESULT
	else
		cResult := "false|"
	endIf

else
	cResult := "false|Ocorreu um erro na conexão, por favor tente novamente."
endIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)




/*/{Protheus.doc} PPLSRELHG
Carrega pagina dos Relatórios Resumo Internação
@author PLS
@since 21/01/2019
@version P12
/*/
Web Function PPLSRELHG()
Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml := ExecInPage("PPLSRELHG")

WEB EXTENDED END
getLOGMon()
Return cHtml


/*/{Protheus.doc} PPLRELZ
Gerar demonstrativos
@author PLSTE
@since 14/02/2019
@version P12
/*/
Web Function PPLRELZ()

Local oObj 		:= NIL
Local cResult	:= ""
Local cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"

oObj:ccCodRDA := HttpGet->cCodRDA
oObj:cTipo := HttpGet->ctipRel
oObj:cTipBusca := HttpGet->ctipRef
oObj:cBusca := HttpGet->cRef
oObj:cProtocolo := HttpGet->cProtocolo

if oObj:relTissOn()
	cResult := oObj:crelTissOnRESULT
else
	cResult := "false|"
endIf

WEB EXTENDED END

Return PLSDECODE(cResult)



/*/{Protheus.doc} PPlSRELGOD
Carrega pagina dos Relatórios Outras Despesas
@author PLS
@since 21/01/2019
@version P12
/*/
Web Function PPlSRELGOD()
Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml := ExecInPage("PPlSRELGOD")

WEB EXTENDED END
getLOGMon()
Return cHtml



/*/{Protheus.doc} PPLCPFB2N
Verifica se existe o cpf na base de analise
@author PLSTEAM
@since 04.2019
@version P12
/*/
Web Function PPLCPFB2N()

LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

// Parametros
oObj:cUserCode	:= "MSALPHA"
oObj:cNumCpf	:= httpget->cNumCpf
oObj:cProtoc	:= httpget->cProtoc

// Retorna dados
If oObj:VldCpfB2n()
	cResult := oObj:CVldCpfB2nRESULT
else
	cResult := "false|Erro ao validar CPF duplicado na mesma solicitação"
endIf

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)


/*/{Protheus.doc} PPLCHEPEG
Verifica a situação do PEG
@author PLSTEAM
@since 05.2019
@version P12
/*/
Web Function PPLCHEPEG()
local oObj 	  := NIL
local cReturn := ""
local cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLRECGLO():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLRECGLO.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cCodRDA 	:= HttpGet->cCodRDA
oObj:cCodPeg    := HttpGet->cCodPeg

if oObj:CheckPeg()
	cReturn := oObj:cCheckPegRESULT
else
	cReturn := oObj:cCheckPegRESULT
endif

WEB EXTENDED END

return PLSDECODE(cReturn)

/*/{Protheus.doc} PPLINCREC
Inclui novo recurso
@author PLSTEAM
@since 05.2019
@version P12
/*/
Web Function PPLINCREC()
local oObj 	  := NIL
local cReturn := ""
local cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLRECGLO():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLRECGLO.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cCodRDA 	:= HttpGet->cCodRDA
oObj:cCodPeg    := HttpGet->cCodPeg
oObj:cGuiaNum 	:= HttpGet->cGuiaNum
oObj:cJustif 	:= HttpGet->cJustif
oObj:cOperador	:= HttpGet->cOperador
oObj:cItens		:= HttpGet->cItens

if oObj:IncluiRec()
	cReturn := oObj:cIncluiRecRESULT
else
	cReturn := oObj:cIncluiRecRESULT
endif

WEB EXTENDED END

return PLSDECODE(cReturn)

/*/{Protheus.doc} PPLCHEPEG
Verifica a situação do PEG
@author PLSTEAM
@since 05.2019
@version P12
/*/
Web Function PPLCHEGUI()
local oObj 	  := NIL
local cReturn := ""
local cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLRECGLO():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLRECGLO.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cCodPeg    := HttpGet->cCodPeg
oObj:cGuiaNum 	:= HttpGet->cGuiaNum

if oObj:CheckGui()
	cReturn := oObj:cCheckGuiRESULT
else
	cReturn := oObj:cCheckGuiRESULT
endif

WEB EXTENDED END

return PLSDECODE(cReturn)


/*/{Protheus.doc} PLisCriRG
Retorna justificativa da Operadora no Recursod e Glosa
@since 07/2016
@version P12
/*/
Web Function PLisCriRG()
LOCAL cResult  	:= "true|"
LOCAL cChave  	:= HttpGet->cChave
local cAlias  	:= HttpGet->cAlias
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLRECGLO():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLRECGLO.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cChave  	:= cChave
oObj:cAlias  	:= cAlias

If oObj:WLisCriRG()
	cResult += oObJ:cWLisCriRGRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)




/*/{Protheus.doc} PLisCriRG
Converte um array em formate de json
@since 06/2019
@version P12
/*/
Function formatJson(_aArray)

	Local cJSON := ""
	LOCAL aCab          := {}
	LOCAL aLin          := {}
	LOCAL cConteudo
	LOCAL cTable        := "DINAM_B7B"
	Local nI            := 0
	Local nX            := 0

	Default _aArray := {}

	// Converte para json
	if (len(_aArray) > 0)
		For nI := 1 to len(_aArray)
			If ValType(_aArray[nI,2]) == 'C'
				aAdd(aCab, _aArray[nI,1])
				aAdd(aLin, _aArray[nI,2])

			ElseIf ValType(_aArray[nI,2]) == 'D'
				aAdd(aCab, _aArray[nI,1])
				aAdd(aLin, dtoc(_aArray[nI,2]))

			ElseIf ValType(_aArray[nI,2]) == 'N'

				aAdd(aCab, _aArray[nI,1])
				aAdd(aLin, str(_aArray[nI,2],12,2))

			ElseIf ValType(_aArray[nI,2]) == 'L'

				aAdd(aCab, _aArray[nI,1])
				aAdd(aLin, iif(_aArray[nI,2],'T','F'))
			EndIf
		Next
		//gerar o JSON.
		cJSON := '{"'+cTable+'": ['

		For nX:= 1 to Len( aCab )
			cJSON += '{'
			If ValType(aLin[nX]) = "C"
				cConteudo := '"'+aLin[nX] +'" '
			ElseIf ValType(aLin[nX]) = "N"
				cConteudo := ALLTRIM(STR(aLin[nX]))
			ElseIf ValType(aLin[nI][nX]) = "D"
				cConteudo := '"'+DTOC(aLin[nX])+'"'
			ElseIf ValType(aLin[nX]) = "L"
				cConteudo := IF(aLin[nX], '"T"' , '"F"')
			Else
				cConteudo := '"'+aLin[nX]+'"'
			EndIf

			cJSON += '"'+aCab[nX]+'":' + cConteudo
			cJSON += '}'
			IF nX < LEN(aCab)
				cJSON += ','
			ENDIF
		Next
		cJSON += ']}'
	EndIf

Return cJSON

/*/{Protheus.doc} PPLGETOBS
carrega observação de peg glosada integralmente
@since 10/2019
@version P12
/*/
web function PPLGETOBS()
local cResult  	:= "true|"
local cProt  	:= HttpGet->cProt
local cHtml 	:= ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cProtoc  	:= cProt

If oObj:getObs()
	cResult += oObJ:cGetObsRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/{Protheus.doc} PPLUSRCON
Verifica se o usuário está bloqueado.
@author Victor Alves dos Santos
@since 06.2020
@version P12
/*/
Web Function PPLUSRCON()

LOCAL cResult := "true|"
LOCAL cHtml := ""
Local cFamilia := HTTPSESSION->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CFAMILIA

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	  := "MSALPHA"
oObj:cBenef 	  := HttpGet->cBenef

If SubStr(cFamilia, 1, 14) != SubStr(HttpGet->cBenef, 1, 14)
	cResult := "false|Matrícula não pertence a familia"
else
	If oObj:USRRECBLQ()
		cResult += oObj:cUSRRECBLQRESULT
	Else
		cResult := "false|"
	EndIf
Endif

WEB EXTENDED END

getLOGMon()

Return PLSDECODE(cResult)

//-------------------------------------------------------------------
/*/{Protheus.doc} function PlsGetAuth(cService)
Rotina para instanciar e autenticar os webservices
@author  Gisele Nuncherino
@since   25/09/2020
/*/
//-------------------------------------------------------------------
Function PlsGetAuth()

	Local aIniSessions := GetIniSessions(GetADV97())
	Local nTag 	:= 0
	Local aEnv	:= {}
	Local cPesqWeb := ""
	Local cJobs	:= ""
	Local cHeader	:= ""

	If Type("cAuthWS") == "U"
		If Type("cModulo") == "U"
			For nTag:=1 To Len(aIniSessions)
				cJobs := GetPvProfString( aIniSessions[nTag] , "ONCONNECT", "", GetADV97() )
				If cJobs == '__WSCONNECT'
					cPesqWeb:= GetPvProfString( aIniSessions[nTag] , "PREPAREIN", "", GetADV97() )
					If !empty(cPesqWeb)
						Exit
					EndIf
				EndIf
			Next

			If !empty(cPesqWeb)
				aEnv := StrTokArr( cPesqWeb , "," )
				If len(aEnv) >= 2
					cEmpresa := alltrim(aEnv[1])
					cUnidade  := alltrim(aEnv[2])
					If !Empty(cEmpresa) .And. !Empty(cUnidade)
						RpcSetType(3)
						RpcSetEnv( cEmpresa, cUnidade)

						cAuthWS := SuperGetMV("MV_AUTHWS",.F.,"")

						RESET ENVIRONMENT
					EndIf
				EndIf
			EndIf
		Else
			cAuthWS := SuperGetMV("MV_AUTHWS",.F.,"")
		EndIf
	EndIf
	If !Empty(cAuthWS)
		cHeader := "Authorization: BASIC "+ ENCODE64(rc4crypt( cAuthWS ,"AuthWS#ReceiptID", .F.,.T.))
	EndIf
Return cHeader


/*/{Protheus.doc} PPLALTSOL
Consulta de solicitações de Beneficiários
@author Rafael Soares da Silva
@since 08/04/2021
@version P12
/*/
Web Function PPLALTSO()
LOCAL cHtml 	:= ""
LOCAL oObj	    := nil
LOCAL cResult := "true|"
LOCAL cDataAux	:= ""
LOCAL cLayout	:= ""
LOCAL cRecno  := ""
LOCAL cChave := Alltrim(HttpGet->cChave)

// WEB EXTENDED INIT cHtml START "InSite"

if ( cChave == "PLSCREDPF" .or. cChave == "PLSCREDPJ" )
	cHtml += ExecInPage("PPLROTDESC")
else
	HttpSession->xDataAux := IIF( ValType( HttpGet->cDataAux ) == "C", HttpGet->cDataAux, "")

	//Obj
	oObj := WSPLCADWEB():New()
	IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObj, "PLCADWEB.APW" )

	// Parametro
	If ValType(HttpGet->cChave) <> "U"  //nas versoes 3.xx.xx esse cara vem preenchido
		cLayout := Alltrim(HttpGet->cChave)
	EndIf

	If ValType(HttpGet->cRecno) <> "U"  //nas versoes 3.xx.xx esse cara vem preenchido
		cRecno := Alltrim(HttpGet->cRecno)
	EndIf

	If ValType( HttpGet->cDataAux ) == "C"
		cDataAux := AllTrim(HttpGet->cDataAux)
	EndIf

	oObj:cUSERCODE	:= "MSALPHA"
	oObj:oWSDataForm:cChaveLay	:= cLayout // Unidade de medida
	oObj:oWSDataForm:cRecnoReg 	:= cRecno
	oObj:oWSDataForm:cDataAux 	:= cDataAux

	If !oObj:VerifyStatus()
		cResult := "Status inválido para edição do Beneficiário. Só podem ser editados com os Status 'Pendente de Documentação' ou 'Em análise' e quando a operação for de 'Inclusão' ou 'Alteração'!"
	EndIf

EndIf


Return PLSDECODE(cResult)
