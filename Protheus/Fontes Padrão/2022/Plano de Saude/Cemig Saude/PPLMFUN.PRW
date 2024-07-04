#INCLUDE "APWEBEX.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PPLMFUN.CH"
#INCLUDE "PLSMGER.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLTPCHM 	  ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ Ä´±±
±±³Descri‡„o ³ Chamada do menu consulta ou sadt								³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLTPCHM()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Operadora padrao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
wcGetIntPad()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Verificar permissão de acesso do botao internados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:CcUsr	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
HttpSession->cBtIntern := ""

If oObj:VALACEBOT()
	If LEN(oObj:OWSVALACEBOTRESULT:OWSSUSUARIO) > 0
		HttpSession->cBtIntern := oObj:OWSVALACEBOTRESULT:OWSSUSUARIO[1]:CPERMITE
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Define o tipo de entrada de dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If ValType(HttpSession->cTipCar) == 'U'
	If HttpSession->USR_INFO[1]:OWSUSERLOGPLS:cTipCar == '1'
		HttpSession->cTipCar := "1"
	Else
		HttpSession->cTipCar := "0"
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tipo de pre-atendimento se vai pre-atender ou atender (executar)		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->cTpPreAte := "0"
HttpSession->cBtInterna:= "0"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mostra a pagina para entrar com a matricula							   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml := ExecInPage( "PPLCARTMAT" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLSTIPCAR  ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alimenta variavel de sessao									 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSTIPCAR()
LOCAL cResult := "true"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define o tipo de entrada de dados									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->cTipCar := HttpGet->cTipCar

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cResult
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLSDADUSR  ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega dados do usuario e envia para consulta ou sadt		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSDADUSR()
LOCAL nI
LOCAL oObj
LOCAL oObjPar
LOCAL nPos
LOCAL lUnimeds
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
LOCAL lPreAten      := .F.
LOCAL cResultInc    := "" //variavel usada para pegar o retorno da inclusão na grid quando o pre atendimento for no atendimento
LOCAL lDigiRetro	:= .T.
LOCAL CDATALIMIT	:= ""
local cCodLdp := ""
LOCAL cHtml := ""
Local lTimeAte	:= .F.
Local nTmpIni := Seconds()

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o parametro													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjPar := WSCFGDICTIONARY():New()
WsChgURL( @oObjPar, "CFGDICTIONARY.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro no WS														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjPar:cUSERCODE	:= "MSALPHA"
oObjPar:cMVPARAM	:= "MV_PLSUNI"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pegar a codigo de consulta definido no parametro 					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObjPar:GETPARAM()
	lUnimeds := IiF( AllTrim(oObjPar:cGETPARAMRESULT)=="1",.T.,.F.)
EndIf

oObjPar:cMVPARAM	:= "MV_PTIMATE" 
If oObjPar:GETPARAM()
	lTimeAte := oObjPar:cGETPARAMRESULT
	If ValType(lTimeAte) == 'U'
		lTimeAte := .F.
	ElseIf	ValType(lTimeAte) == 'C'
		If Type(lTimeAte)=="L"
			lTimeAte := &(lTimeAte)
		EndIf
	EndIf
EndIf
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


//Verifica se o usuário possui permissão para digitar guia retroativa no portal
If ValType(HttpGet->lDigiRetro) <> "U" .and. (HttpGet->lDigiRetro == "true")
	//Chamar função para verificar se o usuário tem permissão
	oObj := WSPLSXFUN():New()
	WsChgURL( @oObj, "PLSXFUN.APW" )
	oObj:cUSERCODE	:= "MSALPHA"
	oObj:cRDACode		:= HttpGet->cRda
	oObj:cCodLoc		:= HttpGet->cCodLoc
	oObj:cCUsr			 := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
	oObj:cUserCardNumber := HttpGet->TrilhaCard
	oObj:cDatGuia		    := HttpGet->dDtaAtd

	//Verificar se existe calendário de pagamento cadastrado para essa RDA e localidade
	If oObj:GETCALEND() .and. !Empty(oObj:cGETCALENDRESULT)
		If oObj:GETDIARETRO() .and. !("false" $ oObj:CGETDIARETRORESULT)
			cDataLimit := oObj:CGETDIARETRORESULT
		Else
			//cResult := "false|Sem permissão para digitar guia para esse prestador."
			cResult := oObj:CGETDIARETRORESULT
			lDigiRetro := .F.
		EndIf
	Else
		cResult := "false|Não há calendário cadastrado, entre em contato com a operadora."
		lDigiRetro := .F.
	EndIf

	/* 	Como pode ser informado tanto o número da carteirinha
	*	quanto o número da matrícula (BA1_MATEMP),
	* 	verificamos nesse ponto se o número informado é de matrícula (isto é, se for encontrado BA1_MATEMP).
	*	Caso positivo, substituimos o número pela carteirinha para validação.
	*	Caso negativo, continua com o número informado.
	*/
	If lDigiRetro .and. oObj:VLDBA1MATEMP()
		If !Empty(oObj:cVLDBA1MATEMPRESULT)
			HttpGet->TrilhaCard 		:= oObj:cVLDBA1MATEMPRESULT
			HttpSession->TrilhaCard 	:= HttpGet->TrilhaCard
		EndIf
	EndIf

	if oObj:GETDIGP()
		cCodLdp := oObj:cGETDIGPRESULT

		if alltrim(cCodLdp) = ""
			cResult := "false|O parâmetro MV_PLSDIGP não está configurado, entre em contato com a operadora."
			lDigiRetro := .F.
		else
			if alltrim(cCodLdp) = "9999"
				cResult := "false|O parâmetro MV_PLSDIGP está configurado de forma errada (Valor: 9999), entre em contato com a operadora."
				lDigiRetro := .F.
			endif
		endif
	endif


EndIf

If lDigiRetro
	//Guardo a data de atendimento informada na digitação de guias
	HttpSession->dDtaAtend := HttpGet->dDtaAtd
	If Len(HttpGet->TrilhaCard) >= 16 .Or. !lUnimeds
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Para ponto de entrada tratamento das trilhas de carcao					 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("PLSCARD")
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
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida trilha																³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpGet->TrilhaCard := Upper(HttpGet->TrilhaCard)
			nPos := At( ":", HttpGet->TrilhaCard )
			If nPos > 0
			   HttpGet->TrilhaCard := Upper(SubStr(HttpGet->TrilhaCard,1,nPos))+'ç'+SubStr( HttpGet->TrilhaCard,(nPos+2),Len(HttpGet->TrilhaCard) )
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Case																		³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Separa																		³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty( cSepara1 )
				aCartao := Separa( HttpGet->TrilhaCard, cSepara1 )
				If Empty(aCartao) .Or. Len(aCartao) < 2
				   cResult := "false|Passe o cartao novamente"
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Tratamento matriz cartao													³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aMatrCartao := Separa( SubStr( aCartao[2], At( cSepara3, aCartao[2] ) + 1 ), "=" )
				If Empty(aMatrCartao) .Or. Len(aMatrCartao) < 3
				   cResult := "false|Passe o cartao novamente"
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pega os valores															    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existe alfa na scrintg											³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lUnimeds
					For nI:=1 To Len(AllTrim(HttpGet->TrilhaCard))
				      	lOk := IsAlpha(SubStr(HttpGet->TrilhaCard,	nI,1))
				      	If lOk
						   cResult := "false|Conteudo invalido"
					    EndIf
					Next
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ se nao tiver critica														³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cResult)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida a Data da Validade Carteirinha										³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cDtValid) .And. cDtValid < Substr(StrZero(Year(Date()),4),3,2)+StrZero( Month( Date() ),2)
				cResult := "false|Data de validade do cartão vencida"
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ obj																			³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oObj := WSPLSXFUN():New()
				WsChgURL( @oObj, "PLSXFUN.APW" )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Parametros																    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oObj:cUSERCODE			:= "MSALPHA"
				oObj:cUSERCARDNUMBER	:= cNumCartao
				oObj:cUSERCARDNAME	    := cNomeCartao
				oObj:cLocalExec			:= "1"
				oObj:cAreaAbr			:= cAbrange
				oObj:cUserCardEdition   := cViaCartao
				oObj:cDatGuia		    := HttpGet->dDtaAtd
				If ValType(HttpGet->lBloqGui) <> "U"
					oObj:LBLOQGUI		:= iif ("true" $ HttpGet->lBloqGui,.T.,.F.)
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Executa o metodo															³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If oObj:USERCARDVALIDATION()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se teve critica													³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Len(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI) == 0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Nome do cartao																³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					    If Empty(cNomeCartao)
						    cNomeCartao := WTDecode(oObj:oWSUSERCARDVALIDATIONRESULT:cCARDNAME)
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Validade																	³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					    If Empty(cDtValid)
						    cDtValid := DToS(oObj:oWSUSERCARDVALIDATIONRESULT:dValCar)
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Produto																		³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Empty(cProduto)
						    cProduto := oObj:oWSUSERCARDVALIDATIONRESULT:cPlano
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Matriz de sessao															³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
														oObj:oWSUSERCARDVALIDATIONRESULT:cDesAcom}			//20
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Carrega para o determinado formulario consulta,sadt etc						³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Valtype(HttpSession->USR_INFO) != "U"
							If HttpSession->USR_INFO[1]:OWSUSERLOGPLS:cBiometria == '1' .And. (!oObj:oWSUSERCARDVALIDATIONRESULT:lInterchange .Or. oObj:oWSUSERCARDVALIDATIONRESULT:lChkBioInter)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Form da biometria													   ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								cDigital := oObj:oWSUSERCARDVALIDATIONRESULT:cDig1+oObj:oWSUSERCARDVALIDATIONRESULT:cDig2

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Ponto de entrada que habilita a biometria via portal.³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

								If ExistBlock("PPLBiomet")
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

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ valida se permite continuar pre-atendimento mesmo com critica	 			   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If HttpSession->cBtInterna == "1"

							If !oObj:oWSUSERCARDVALIDATIONRESULT:lCritPreAtdm
								cResult := "false|"
							Else

								 If Empty(cNomeCartao)
								    cNomeCartao := WTDecode(oObj:oWSUSERCARDVALIDATIONRESULT:cCARDNAME)
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Validade																	³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							    If Empty(cDtValid)
								    cDtValid := DToS(oObj:oWSUSERCARDVALIDATIONRESULT:dValCar)
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Produto																		³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If Empty(cProduto)
								    cProduto := oObj:oWSUSERCARDVALIDATIONRESULT:cPlano
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Matriz de sessao															³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
														oObj:oWSUSERCARDVALIDATIONRESULT:cDesAcom}			//20


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

									cResult += AllTrim(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI[nI]:CDESPRI)+" - "+AllTrim(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI[nI]:CDESSEQ)+Chr(13)
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
	if ExistBlock("PLSVLDC")//³ Para ponto de entrada para validacoes complementares apos as validacoes  padroes³
		cResult := ExecBlock("PLSVLDC",.F.,.F.,{HttpGet->TrilhaCard,HttpSession->cTipCar,aMatrCartao,cResult})
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se é preatendimento no atendimento													³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if ValType(HttpGet->lPreAten) <> "U" .AND. HttpGet->lPreAten == "true"
		//eu atribui os valores direto no HttpGet porque a função que é chamada dentro do W_PPLENVPRT() usa o HttpGet, já que ela era
		//usada dentro da função de pre atendimento antiga
		HttpGet->cMatric := oObj:oWSUSERCARDVALIDATIONRESULT:cCardNumber
		HttpGet->cNomeUsu := alltrim(cNomeCartao)

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
	If ValType(cDataLimit) <> "U" .and. !Empty(cDataLimit)
		//Adiciona data limite, caso possua
		cResult += "@" + cDataLimit
	EndIf
endif

WEB EXTENDED END

//Mostra o tempo que durou pra confirmar o atendimento
If lTimeAte
    oObjPar:cMsgLog  := "1) " + Time()+ "|" + Alltrim(Str(Seconds() - nTmpIni)) + "|" + HttpGet->cRDA
    oObjPar:cFileLog := "PreAtendimento.txt"
    oObjPar:PutPLSLogFil()
EndIf

Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLENVFOR  ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alimenta Sessions rda e envia pra tela de consulta ou sadt	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLENVFOR()
LOCAL oObj
LOCAL cCodConsulta 	:= ""
LOCAL cHtml 		:= ""
LOCAL cCookie 		:= ""
LOCAL cAprNumImp	:= "0" // Não Apresenta o campo Número Impresso no Portal
PRIVATE lPreAten := .T.

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define se vai mostrar o botao voltar na impressao da guia			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->cBVolt := "0"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Biscoito																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCookie := HttpCookies->SIGAPLS
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSCFGDICTIONARY():New()
WsChgURL( @oObj, "CFGDICTIONARY.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro no WS														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE	:= "MSALPHA"
oObj:cMVPARAM	:= "MV_PLSCDCO"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pegar a codigo de consulta definido no parametro 					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:GETPARAM()
	cCodConsulta := oObj:cGETPARAMRESULT
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro que indica se apresenta o campo de Numero Impresso no Portal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cMVPARAM	:= "MV_PLSNIMP"

If oObj:GETPARAM()
	cAprNumImp := oObj:cGETPARAMRESULT
	If ValType(cAprNumImp) == 'L'
		cAprNumImp := IIF(cAprNumImp,"1","0")
   ElseIf ValType(cAprNumImp) == 'C'
   	cAprNumImp := IIF(cAprNumImp==".T.","1","0")
   EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Verifica se esta ligado para exibir todos os profissionais
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cMVPARAM	:= "MV_PLSPRFS" // .T. filtra - .F.  lista todos

If oObj:GETPARAM()
	HttpSession->lFiltPRF := oObj:cGETPARAMRESULT
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE := "MSALPHA"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta as variaves com o x3-combobox								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if oObj:getCombo()
	HttpSession->cCodPad   	:= oObj:oWSGETCOMBORESULT:cCodPad
	HttpSession->cCodCons  	:= SubStr(cCodConsulta,3,16)
	HttpSession->aTpDoe 	:= oObj:oWSGETCOMBORESULT:oWSCBTPDOE:oWSGenericStruct
	HttpSession->aTmpDoe  	:= oObj:oWSGETCOMBORESULT:oWSCBTMPDOE:oWSGenericStruct
	HttpSession->aIndAcid	:= oObj:oWSGETCOMBORESULT:oWSCBIndAcid:oWSGenericStruct
	HttpSession->aTpCon		:= oObj:oWSGETCOMBORESULT:oWSCBTpCon:oWSGenericStruct
	HttpSession->aTpSai 	:= oObj:oWSGETCOMBORESULT:oWSCBTpSai:oWSGenericStruct
	HttpSession->aCarSolict	:= oObj:oWSGETCOMBORESULT:oWSCBCarSolict:oWSGenericStruct
	HttpSession->aTpAtend	:= oObj:oWSGETCOMBORESULT:oWSCBTpAtend:oWSGenericStruct
	HttpSession->aViaAce	:= oObj:oWSGETCOMBORESULT:oWSCBViaAce:oWSGenericStruct
	HttpSession->aTecUti	:= oObj:oWSGETCOMBORESULT:oWSCBTecUti:oWSGenericStruct
	HttpSession->aGraPart  	:= oObj:oWSGETCOMBORESULT:oWSCBGraPart:oWSGenericStruct
	HttpSession->aTpPreAte 	:= oObj:oWSGETCOMBORESULT:oWSCbTpPreAte:oWSGenericStruct
	HttpSession->aTpAtOD   	:= oObj:oWSGETCOMBORESULT:oWSCbTpAtOD:oWSGenericStruct
	HttpSession->aTpInter	:= oObj:oWSGETCOMBORESULT:oWSCbTpInter:oWSGenericStruct
	HttpSession->aRegInter	:= oObj:oWSGETCOMBORESULT:oWSCbRegInter:oWSGenericStruct
	HttpSession->aTipGui	:= oObj:oWSGETCOMBORESULT:oWSCbTipGui:oWSGenericStruct
	HttpSession->cAprNImp   := cAprNumImp
	HttpSession->aTipFat	:= oObj:oWSGETCOMBORESULT:oWSCbTipFat:oWSGenericStruct
else
	Return PPLSALERT( "", "Atenção", "", "W_PPLENVFOR.APW" )
endIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se tem RdMake compilado para tratamento no botao confirmar	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ExistBlock("PPLREGBTN")
	HttpSession->ExisRegEsp := '1'
Else
	HttpSession->ExisRegEsp := '0'
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama formulario de pre-atendimento									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml += ExecInPage("PPLMOSPRE")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLENVPRT ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alimenta Sessions rda e envia pra tela de consulta ou sadt	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLENVPRT()
LOCAL oObj
LOCAL cCodConsulta 	:= ""
LOCAL cHtml 		:= ""
LOCAL cCookie 		:= ""
LOCAL cAprNumImp	:= "0" // Não Apresenta o campo Número Impresso no Portal
PRIVATE lPreAten := .T.

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define se vai mostrar o botao voltar na impressao da guia			   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->cBVolt := "0"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Biscoito																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCookie := HttpCookies->SIGAPLS
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSCFGDICTIONARY():New()
WsChgURL( @oObj, "CFGDICTIONARY.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro no WS														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE	:= "MSALPHA"
oObj:cMVPARAM	:= "MV_PLSCDCO"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pegar a codigo de consulta definido no parametro 					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:GETPARAM()
	cCodConsulta := oObj:cGETPARAMRESULT
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro que indica se apresenta o campo de Numero Impresso no Portal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cMVPARAM	:= "MV_PLSNIMP"

If oObj:GETPARAM()
	cAprNumImp := oObj:cGETPARAMRESULT
	If ValType(cAprNumImp) == 'L'
		cAprNumImp := IIF(cAprNumImp,"1","0")
   ElseIf ValType(cAprNumImp) == 'C'
   	cAprNumImp := IIF(cAprNumImp==".T.","1","0")
   EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Verifica se esta ligado para exibir todos os profissionais
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cMVPARAM	:= "MV_PLSPRFS" // .T. filtra - .F.  lista todos

If oObj:GETPARAM()
	HttpSession->lFiltPRF := oObj:cGETPARAMRESULT
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE := "MSALPHA"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta as variaves com o x3-combobox								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if oObj:getCombo()
	HttpSession->cCodPad   	:= oObj:oWSGETCOMBORESULT:cCodPad
	HttpSession->cCodCons  	:= SubStr(cCodConsulta,3,16)
	HttpSession->aTpDoe 	:= oObj:oWSGETCOMBORESULT:oWSCBTPDOE:oWSGenericStruct
	HttpSession->aTmpDoe  	:= oObj:oWSGETCOMBORESULT:oWSCBTMPDOE:oWSGenericStruct
	HttpSession->aIndAcid	:= oObj:oWSGETCOMBORESULT:oWSCBIndAcid:oWSGenericStruct
	HttpSession->aTpCon		:= oObj:oWSGETCOMBORESULT:oWSCBTpCon:oWSGenericStruct
	HttpSession->aTpSai 	:= oObj:oWSGETCOMBORESULT:oWSCBTpSai:oWSGenericStruct
	HttpSession->aCarSolict	:= oObj:oWSGETCOMBORESULT:oWSCBCarSolict:oWSGenericStruct
	HttpSession->aTpAtend	:= oObj:oWSGETCOMBORESULT:oWSCBTpAtend:oWSGenericStruct
	HttpSession->aViaAce	:= oObj:oWSGETCOMBORESULT:oWSCBViaAce:oWSGenericStruct
	HttpSession->aTecUti	:= oObj:oWSGETCOMBORESULT:oWSCBTecUti:oWSGenericStruct
	HttpSession->aGraPart  	:= oObj:oWSGETCOMBORESULT:oWSCBGraPart:oWSGenericStruct
	HttpSession->aTpPreAte 	:= oObj:oWSGETCOMBORESULT:oWSCbTpPreAte:oWSGenericStruct
	HttpSession->aTpAtOD   	:= oObj:oWSGETCOMBORESULT:oWSCbTpAtOD:oWSGenericStruct
	HttpSession->aTpInter	:= oObj:oWSGETCOMBORESULT:oWSCbTpInter:oWSGenericStruct
	HttpSession->aRegInter	:= oObj:oWSGETCOMBORESULT:oWSCbRegInter:oWSGenericStruct
	HttpSession->aTipGui	:= oObj:oWSGETCOMBORESULT:oWSCbTipGui:oWSGenericStruct
	HttpSession->cAprNImp   := cAprNumImp
	HttpSession->aTipFat	:= oObj:oWSGETCOMBORESULT:oWSCbTipFat:oWSGenericStruct
else
	Return PPLSALERT( "", "Atenção", "", "W_PPLENVPRT.APW" )
endIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se tem RdMake compilado para tratamento no botao confirmar	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ExistBlock("PPLREGBTN")
	HttpSession->ExisRegEsp := '1'
Else
	HttpSession->ExisRegEsp := '0'
EndIf

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return W_PPLTRAPRE()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCHABIO  ³ Autor ³ Alexander Santos     ³ Data ³ 20.01.2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama o formulario da biometria								 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCHABIO()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLMOSBIO")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLINCBIO  ³ Autor ³ Alexander Santos     ³ Data ³ 20.01.2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama o formulario da biometria								 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLINCBIO()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXINC():New()
WsChgURL( @oObj, "PLSXINC.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa a guia																	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE				:= "MSALPHA"					//Usuario
oObj:OWSINCMATBIO:cVida 	:= HttpSession->aVldCartao[15]	//Vida
oObj:OWSINCMATBIO:cAlias	:= 'BTS'						//Alias
oObj:OWSINCMATBIO:cDig		:= HttpGet->cDedo				//Digital (Dedo)
oObj:OWSINCMATBIO:cDig1		:= StrTran( HttpGet->cDig1," ","+" )//String biometrica 1
oObj:OWSINCMATBIO:cDig2		:= StrTran( HttpGet->cDig2," ","+" )//String biometrica 2
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa Guia																	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:IncBio()
	cResult :=  oObj:CINCBIORESULT
Else
	cResult :=  "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina																	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLATEUSU    ³ Autor ³ Alexander Santos	   ³ Data ³ 02.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega dados do usuario solicitacao de atendimento			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ obj																			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros																    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE		 := "MSALPHA"
oObj:cUSERCARDNUMBER := StrTran(StrTran(HttpGet->cMatric,".",""),"-","")
oObj:cUSERCARDNAME	 := HttpGet->cNomeUsu
oObj:cRdaCode	 	 := HttpGet->cRda
oObj:cCodLoc	 	 := HttpGet->cCodLoc
oObj:cTipAtd		 := HttpGet->cTpAte
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa o metodo															³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:USERCARDVALIDATION()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se teve critica													³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(oObj:OWSUSERCARDVALIDATIONRESULT:OWSUSERCRITICA:OWSUSERCARDCRI) == 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Matriz de sessao															³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
										oObj:oWSUSERCARDVALIDATIONRESULT:cDesAcom}					//20
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Lista de profissional de saude										   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se e fisica ou juridica quando solicitado consulta			   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If HttpGet->cTpAte == "1"
			nPosRDA := aScan( HttpSession->RDAVIEW, { |x| x:cCODE == HttpGet->cRda .And. x:cCodLoc == HttpGet->cCodLoc} )
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega para o determinado formulario consulta,sadt etc						³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	cTipGui := if(HttpGet->cTpAte == "4","2",HttpGet->cTpAte)
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina																³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLCHAATE    ³ Autor ³ Alexander Santos	   ³ Data ³ 02.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chama determinado formulario do atendimento					 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCHAATE()
LOCAL cHtml 	:= ""
LOCAL oObj	    := nil
LOCAL oObjRG    := nil
LOCAL nPosRda	:= 0
LOCAL cTISSVer	:= ""
LOCAL cRda		:= ""
LOCAL cCodLoc	:= ""
LOCAL aRDA		:= {}
LOCAL nI		:= 0
LOCAL nY		:= 0
LOCAL cResult	:= ""
LOCAL lDiagno	:= ""
Local cDigiGui	:= IIF(ValType(HttpGet->cDigiGui  ) == "C", AllTrim(HttpGet->cDigiGui  ) , "")
Local cNumGuiRef	:= IIF(ValType(HttpGet->cNumGuiRef) == "C", AllTrim(HttpGet->cNumGuiRef) , "")
Local cTpGuiRef  	:= IIF(ValType(HttpGet->cTpGuiRef ) == "C", AllTrim(HttpGet->cTpGuiRef ) , "")
Local cRecGuiRef 	:= IIF(ValType(HttpGet->cRecGuiRef) == "C", AllTrim(HttpGet->cRecGuiRef) , "")
Local cCodConsulta	:= ""
Local oObjx		:= Nil
LOCAL cTipoG	:= ""
Local lAltCpAUT	:= IIF (ValType(HttpGet->cTipAltG) == "C" .AND. HttpGet->cTipAltG == "AltCmp", .T., .F.)
Local cRecnoBD5 := IIF(ValType(HttpGet->cRecnoBD5) == "C", AllTrim(HttpGet->cRecnoBD5) , "")
LOCAL cTipoAlt := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aliemnta variavel de sessao											   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->cTp := HttpGet->cTp
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a RDA e sua versão TISS						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cRda := HttpGet->cRda
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE	:= "MSALPHA"
oObj:cTipo 		:= HttpSession->cTp
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta a dados especifico por tipo de guia						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:GetDadG()
	Do Case
		Case HttpSession->cTp == "3" //Internacao
			HttpSession->RDASOLT 	:= oObj:oWSGetDadGRESULT:oWSDADRDATP:oWSMSDADRDA
		Case HttpSession->cTp == "4" //ODontologico
			HttpSession->cCodPad 	:= oObj:oWSGetDadGRESULT:cCodPad
    EndCase
Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLENVFOR.APW" )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada que define os campos obrigatorios a mais na GUia 	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->cObrCpGuia := ""
If ExistBlock('PLSCPGUI')
  	HttpSession->cObrCpGuia := ExecBlock('PLSCPGUI',.F.,.F.,{HttpSession->cTp})
EndIf

//Indicacao dos tipos de formularios a terem o botao complemento habilitado no portal 1=Cons 2=SADT 3=GIH e 4=Odonto
If oObj:PLSGETMV("MV_PLCMPFP","") .And. ExistBlock("PLSCMPFP")
	If !Empty(oObj:cPLSGETMVRESULT) .And. HttpSession->cTp $ oObj:cPLSGETMVRESULT
		HttpSession->cCmpl := oObj:cPLSGETMVRESULT
	EndIf
EndIf

//Digitação de Guias
oObj:cDigigui		:= cDigigui
oObj:cRECNOBD5   := cRecnoBD5
oObj:cTipo 	:= IIF(Empty(HttpGet->cTipoOrigem),"",HttpGet->cTipoOrigem)
If !(EmpTy(oObj:Ctipo)) //Tratamentos específicos da digitação de guias

	If Separa(oObj:cTipo,"|")[1] == "consulta"
		oObjx := WSCFGDICTIONARY():New()
		WsChgURL( @oObjx, "CFGDICTIONARY.APW" )

		oObjx:cUSERCODE	:= "MSALPHA"
		oObjx:cMVPARAM	:= "MV_PLSCDCO"

		If oObjx:GETPARAM()
			cCodConsulta := oObjx:cGETPARAMRESULT //Inicia a session que inicializa o códgo da consulta.
		EndIf

		HttpSession->cCodCons  	:= SubStr(cCodConsulta,3,16)
	EndIf

	oObjx := WSPLSXFUN():New()
	WsChgURL( @oObjx, "PLSXFUN.APW" )
	oObjx:cUSERCODE:= "MSALPHA"

	oObj:cRdaCode	:= HttpGet->cRda
	oObj:cCodLoc	:= HttpGet->cCodLoc
	If !HttpSession->cTp $ "1,2,3,4,5,11,12,6"
		If oObj:ProfSaud()
			HttpSession->PROSAUD := oObj:oWSPROFSAUDRESULT:OWSLISTPROFSAUD:oWSPROFSAUD
		EndIf
	EndIf

EndIf

	IF lAltCpAUT
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ obj																			³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObj := WSPLSXFUN():New()
		WsChgURL( @oObj, "PLSXFUN.APW" )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Parametros																    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObj:cUSERCODE	:= "MSALPHA"
		oObj:cRdaCode	:= HttpGet->cRda
		oObj:cCodLoc	:= HttpGet->cCodLoc
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Lista de profissional de saude										   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !HttpSession->cTp $ "1,2,3,4,5,11,12,6"
			If oObj:ProfSaud()
				HttpSession->PROSAUD := oObj:oWSPROFSAUDRESULT:OWSLISTPROFSAUD:oWSPROFSAUD
			EndIf
		ENDIF
	ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CRIAR PAGINA PARA TISS 3.0													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTissVer >= "3"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ oBJ
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oObj := WSPLSXFUN():New()
	WsChgURL( @oObj, "PLSXFUN.APW" )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Parametros
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oObj:cUserCode	:= "MSALPHA"
	oObj:oWSGUIATISS:cTipGui		:= STRZERO(val(HttpSession->cTp),2)
	oObj:oWSGUIATISS:cVerTiss	:= cTISSVer
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Aqui eu pego o que vem de Session executo aqui pra enviar a informaçao
	// pro WS pois o mesmo nao acessa o conteudo da Session	dificultando o dinamismo
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If oObj:GetCmbFormT()
		// ATRIBUO OS PARAMETROS NOVAMENTE PARA UTILIZAÇÃO DO PROXIMO METODO
		oObj:cUserCode	:= "MSALPHA"
		oObj:oWSGUIATISS:cTipGui	:= STRZERO(val(HttpSession->cTp),2)
		oObj:oWSGUIATISS:cVerTiss	:= cTISSVer
		oObj:oWSGUIATISS:cDadCombo	:= ""
		
		If Len(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA) > 0
		
			For nI := 1 To Len(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA)
		
				cStrCBOX := ""
				If "HTTPSESSION" $ Upper(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX)	 // Se for uma Session eu pego CCODE e CNAME e monto o Combo
					If ValType(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX)) <> 'U'
						For nY := 1 To Len(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX))
							cStrCBOX += Alltrim(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX + "[" + Alltrim(Str(nY)) + "]:cCODE")) + "=" + Alltrim(&(oObj:OWSGETCMBFORMTRESULT:OWSRETCMBSGUIA:OWSSRETCMBSGUIA[nI]:cCBOX + "[" + Alltrim(Str(nY)) + "]:cNAME")) + ";"
						Next nY
					EndIf
					If nY > 2
						cStrCBOX += ";="
					EndIf
				Else // Caso contrario eu pego a STRING com mesma estrutura do X3_COBX
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
	IF (lAltCpAUT .AND. Empty(cDigiGui))  //Se alteração estiver preenchido e digiguia não, garanto que não é da digitação de contas off e sim da autorização
			oObj:cTipo		:= "AltCmp|" + AllTrim(StrTran(StrTran(HttpGet->cNumGOB,".",""),"-","")) + '|' + HttpGet->cTp
	ELSEIF (lAltCpAUT .AND. !Empty(cDigiGui))
		oObj:cTipo		:= "AltCmp|" + IIF(Empty(HttpGet->cTipoOrigem),"",HttpGet->cTipoOrigem)
	ELSE
		oObj:cTipo		:= IIF(Empty(HttpGet->cTipoOrigem),"",HttpGet->cTipoOrigem)
	ENDIF
	oObj:ccRecno 		:= IIF(Empty(HttpGet->cNumGuia),"",HttpGet->cNumGuia)
	oObj:cDtLimRetro 	:= IIF(Empty(HttpGet->dDtLimRetro),"",HttpGet->dDtLimRetro)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Retorna dados da pagina
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oObj:cMsnBloInter	:= HttpSession->cMsnBloInt
	oObj:cDigigui		:= cDigigui
	oObj:cNumGuiRef 	:= cNumGuiRef
	oObj:cTpGuiRef   	:= cTpGuiRef
	oObj:cRecGuiRef  	:= cRecGuiRef
	oObj:lAltCpAT		:= lAltCpAUT //r77
	
	//Adiciona data da guia SADT na inclusão de outras despesas
	if (HttpSession->cTp == "12")
		HttpSession->cDatAtd	:= IIF(Empty(HttpGet->cDatAtd),"",HttpGet->cDatAtd)	
	endif
	
	If ValType(HttpSession->aVldCartao) == 'A'
		oObj:lIntercambio		:= HttpSession->aVldCartao[10]
	Else
		oObj:lIntercambio		:= .F.
	EndIf
	HttpSession->cDigitacao := cDigigui
	oObj:cRECNOBD5   := cRecnoBD5
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ FIM CRIAR PAGINA PARA TISS 3.0													   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para o determinado formulario									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTissVer < "3"
	Do Case
		Case HttpSession->cTp == "1" //Consulta
			cHtml := ExecInPage( "PPLSCONS?cRda="+HttpGet->cRda+"&cCodLoc="+HttpGet->cCodLoc )
		Case HttpSession->cTp == "2" //Sadt
			cHtml := ExecInPage( "PPLSSADT?cRda="+HttpGet->cRda+"&cCodLoc="+HttpGet->cCodLoc )
		Case HttpSession->cTp == "3" //Internacao
			//recupera valor do parâmetro
			oObjPar := WSCFGDICTIONARY():New()
			WsChgURL( @oObjPar, "CFGDICTIONARY.APW" )

			oObjPar:cUSERCODE	:= "MSALPHA"
			oObjPar:cMVPARAM	:= "MV_PLSDGN"
			If oObjPar:GETPARAM()
				lDiagno := oObjPar:cGETPARAMRESULT
				If ValType(lDiagno) == 'U'
					lDiagno := .F.
				ElseIf	ValType(lDiagno) == 'C'
					If Type(lDiagno)=="L"
						lDiagno := &(lDiagno)
					EndIf
				EndIf
			EndIf

			HttpSession->lDiagno	:= lDiagno//SuperGetMv( "MV_PLSDGN", .F.,.F.)
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

Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLCHAPRE    ³ Autor ³ Alexander Santos	   ³ Data ³ 09.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra pacientes para o atendimento chamada do menu			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCHAPRE()
LOCAL cHtml := ""
LOCAL oObjPar := nil
Private lPreAten := .F.

WEB EXTENDED INIT cHtml START "InSite"

 HttpSession->cBtIntern := " "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Recupera parametro para verificar se o Pré atendimento está habilitado dentro do atendimento
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObjPar := WSCFGDICTIONARY():New()
WsChgURL( @oObjPar, "CFGDICTIONARY.APW" )

oObjPar:cUSERCODE	:= "MSALPHA"
oObjPar:cMVPARAM	:= "MV_PLPREATE"
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Pré atendimento dentro do atendimento
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If lPreAten
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Operadora padrao
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	wcGetIntPad()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Verificar permissão de acesso do botao internados
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oObj := WSPLSXFUN():New()
	WsChgURL( @oObj, "PLSXFUN.APW" )

	oObj:cUserCode	:= "MSALPHA"
	oObj:CcUsr	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
	HttpSession->cBtIntern := ""

	If oObj:VALACEBOT()
		If LEN(oObj:OWSVALACEBOTRESULT:OWSSUSUARIO) > 0
			HttpSession->cBtIntern := oObj:OWSVALACEBOTRESULT:OWSSUSUARIO[1]:CPERMITE
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Define o tipo de entrada de dados
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If ValType(HttpSession->cTipCar) == 'U'
		If HttpSession->USR_INFO[1]:OWSUSERLOGPLS:cTipCar == '1'
			HttpSession->cTipCar := "1"
		Else
			HttpSession->cTipCar := "0"
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tipo de pre-atendimento se vai pre-atender ou atender (executar)		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HttpSession->cTpPreAte := "0"
	HttpSession->cBtInterna:= "0"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ "0" Pre-Atendimento "1" Pacientes "2" Atendimento						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->cTpPreAte := HttpGet->cP
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ "2" Atendimento	carrega combos											  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If HttpSession->cTpPreAte != '0'
	W_PPLENVFOR()
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama formulario de atendimento											  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cHtml += ExecInPage("PPLMOSPRE")
EndIf

WEB EXTENDED END

Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSCHKCID ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o cid e valido									 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSCHKCID()
LOCAL cResult := ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUserCode	:= "MSALPHA"
oObj:cCid		:= HttpGet->cChkCid
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa metodo verificar se o cid e valido							   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:ChkCid()
	If ValType(HttpGet->cCampoRef) == "U"  //nas versoes 3.xx.xx esse cara vem preenchido
		cResult := 'true|'+oObj:cCHKCIDRESULT
	Else
		cResult := 'true|'+HttpGet->cCampoRef+"|"+oObj:cCHKCIDRESULT
	Endif
Else
	cResult :=  "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSITEPCT ³ Autor ³ Roberto Vanderlei    ³ Data ³ 10.04.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´ ±±
±±³Descri‡„o ³ Procura e inclui dados dos itens do pacote,qtd e codpad		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSITEPCT()
Local cCodPct	:= SubStr(HttpGet->cCodPct,3,10)
Local cQtdSSol	:= HttpGet->cQtdSSol
Local cQtdAutSSol	:= HttpGet->qtdAutSSol
Local cStatusAut 	:= HttpGet->cStatusAut
Local cTpAut 		:= HttpGet->cTpAut
Local aMatPct 		:= HttpGet->aMatPct
Local lRetCab 		:= HttpGet->lRetCab
Local dDtExe		:= HttpGet->dDtExe
Local nRedAcreSExe	:= HttpGet->nRedAcreSExe
Local cCodRda		:= HttpGet->cCodRda
Local nI
Local cResult 	:= ""
Local nLen
Local nPos
Local aResultado
LOCAL cHtml := ""

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
WsChgURL( @oObj, "PLSXFUN.APW")
oObj:cUSERCODE := "MSALPHA"
oObj:OWSPRODAD:cCodPro	:= cCodPct

If oObj:RetLstPro()
	cResult := oObj:cRETLSTPRORESULT //+ "cQtdSSol;" + cQtdSSol + "~" + "cQtdAutSSol;" + cQtdAutSSol + "~"
EndIf

aResultado := PlSplitAdvpl(cResult, "|")

cResult := "true"

/*Adicionando a todos os itens a quantidade autorizada/solicitada do pacote.*/
For nI:=2 To Len(aResultado)
	If dDtExe = ""
		cResult += "|" + aResultado[nI] + "~cQtdAutSSol;" + cQtdAutSSol + "~" + "cQtdSSol;" + cQtdSSol + "~" + "cStatusAut;" + cStatusAut + "~" + "cTpAut;" + cTpAut + "~cCodPct;" + cCodPct + "~dDtExe;"+dDtExe + "~nRedAcreSExe;" + nRedAcreSExe
	Else
		cResult += "|" + aResultado[nI] + "~cQtdAutSSol;" + cQtdAutSSol + "~" + "cStatusAut;" + cStatusAut + "~" + "cTpAut;" + cTpAut + "~cCodPct;" + cCodPct + "~dDtExe;"+dDtExe + "~nRedAcreSExe;" + nRedAcreSExe
	EndIf

Next

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSCHKPCT ³ Autor ³ Roberto Vanderlei    ³ Data ³ 09.04.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o procedimento e pacote  								³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSCHKPCT()
Local lPLSEXPC
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro no WS														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE 			:= "MSALPHA"
oObj:oWSMatPre:cCodRda	:= HttpGet->cRda										  	//Rda
oObj:oWSMatPre:cMatric	:= HttpGet->cMatric											//Matricula
oObj:oWSMatPre:cNomeUsu	:= HttpGet->cNomeUsu										//Nome do usuario
oObj:oWSMatPre:cCodUsr	:= getUsrWeb()											 	//Codigo de login web Login pls bsw
oObj:oWSMatPre:cMatric	:= HttpGet->cMatric		//Matricula

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUserCode			:= "MSALPHA"
oObj:OWSPRODAD:cCodPro	:= SubStr(HttpGet->cCodPadPro,3,8)
oObj:OWSPRODAD:cCodRda	:= SubStr(HttpGet->cCodPadPro,11,6)

/*Roberto Vanderlei de Arruda*/
if oObj:ChkCodPct()

	cResult := "true|"+oObj:cCHKCODPCTRESULT+"?" + SubStr(HttpGet->cCodPadPro,3,8)//+ "?" + cV

else
	cResult :=  "false|"+StrTran(PWSGetWSError( "" ),":","")
endif

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSCHKSER ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o procedimento e valido							 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSCHKSER()

LOCAL cTISSVer:= ""
LOCAL cResult := ""
LOCAL aRDA    := {}
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro no WS														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE 			:= "MSALPHA"
oObj:oWSMatPre:cCodRda	:= HttpGet->cRda										  	//Rda

oObj:oWSMatPre:cMatric	:= HttpGet->cMatric											//Matricula
oObj:oWSMatPre:cNomeUsu	:= HttpGet->cNomeUsu										//Nome do usuario
oObj:oWSMatPre:cCodUsr	:= getUsrWeb()											 	//Codigo de login web Login pls bsw

oObj:oWSMatPre:cMatric	:= HttpGet->cMatric		//Matricula

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUserCode			:= "MSALPHA"
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Executa metodo verificar se o procedimento e valido
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:ChkCodPro()
	cResult := oObj:cCHKCODPRORESULT
Else
	cResult :=  "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSQTD	  ³ Autor ³ Totvs    			 ³ Data ³ 217.10.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Quantidade															 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSQTD()
LOCAL cResult := ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Executa metodo verificar se o procedimento e valido
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:ChkQtdPro()
	cResult := oObj:cCHKQTDPRORESULT
Else
 	cResult :=  "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPSDETPRO  ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna informação do prof de saude com base na selecao		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PPSDETPRO(cProfSau,cTp,cTpProf)
LOCAL cResult       := ""
LOCAL nPosPSau 	    := 0
LOCAL nI			:= 0
LOCAL aRet			:= {}
LOCAL oObj			:= NIL
LOCAL cTpGuia       := iif(valtype(HttpSession->cTp) <> "U", HttpSession->cTp, "")
LOCAL dDatFxFun     :=  GetAPOInfo("WSPLSXFUN.PRX")[4] 
LOCAL dDtCliet      :=  GetAPOInfo("WSCLIENT_WSPLSXFUN.PRX")[4] 
DEFAULT	 cTpProf	:= "S" //S - Solicitante | E - Executante

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Profissional de Saude												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If HttpSession->PROSAUD == NIL
	HttpSession->PROSAUD := {}
EndIf
If HttpSession->PROSAUDEXE == NIL
	HttpSession->PROSAUDEXE := {}
EndIf

If !(cTp == "W") .And. cTpProf <> "E" .And. aScan( HttpSession->PROSAUD, { |x| x:cCODE == AllTrim(cProfSau) } ) == 0 
    oObj := WSPLSXFUN():New()
	WsChgURL( @oObj, "PLSXFUN.APW" )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros																    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObj:cUSERCODE	:= "MSALPHA"
	oObj:cRdaCode	:= cProfSau
	oObj:cCodLoc	:= HttpGet->cCodLoc
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lista de profissional de saude										   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega dados do profissional										   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPosPSau > 0
	If cTp == "W"
		cResult :=  "true|"+HttpSession->PROSAUD[nPosPSau]:cCodSig	+"|"+;
							HttpSession->PROSAUD[nPosPSau]:cNumCr	+"|"+;
							HttpSession->PROSAUD[nPosPSau]:cEstado	+"|"+;
							HttpSession->PROSAUD[nPosPSau]:cName + "@" + HttpSession->PROSAUD[nPosPSau]:cCode +"|"+;
							HttpSession->PROSAUD[nPosPSau]:cCpfCnpj	+"|"+;
							HttpSession->PROSAUD[nPosPSau]:cCodOpe
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ajusta caracter especial											   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cResult := PLSDECODE(cResult)

	ElseIf cTp == "W2"
		cResult := "true|"+ IIF(cTpProf == "E", HttpSession->PROSAUDEXE[nPosPSau]:cCodSig, HttpSession->PROSAUD[nPosPSau]:cCodSig)	 +"|"+;
							IIF(cTpProf == "E", HttpSession->PROSAUDEXE[nPosPSau]:cNumCr, HttpSession->PROSAUD[nPosPSau]:cNumCr)	 +"|"+;
							IIF(cTpProf == "E", HttpSession->PROSAUDEXE[nPosPSau]:cEstado, HttpSession->PROSAUD[nPosPSau]:cEstado)	 +"|"+;
							IIF(cTpProf == "E", HttpSession->PROSAUDEXE[nPosPSau]:cName + "@" + HttpSession->PROSAUDEXE[nPosPSau]:cCode, HttpSession->PROSAUD[nPosPSau]:cName + "@" + HttpSession->PROSAUD[nPosPSau]:cCode) + "|"+;
							IIF(cTpProf == "E", HttpSession->PROSAUDEXE[nPosPSau]:cCpfCnpj, HttpSession->PROSAUD[nPosPSau]:cCpfCnpj) +"|"+;
							IIF(cTpProf == "E", HttpSession->PROSAUDEXE[nPosPSau]:cCodOpe, HttpSession->PROSAUD[nPosPSau]:cCodOpe)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ajusta caracter especial											   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cResult
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPSDADPSAU ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna informação do prof de saude com base na selecao		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPSDADPSAU()
LOCAL cResult := "true|||||||||||||||||||||||"
LOCAL cRet 	  := ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega detalhe do profissional										   	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cRet := PPSDETPRO(HttpGet->cProSaud,"W2")
If ExistBlock('PLSPROF')
	aRet :=Execblock('PLSPROF',.F.,.F.,{HttpGet->cProSaud,HttpGet->cMatric})
   If !aRet[1]
  		cRet:="false|"+aRet[2]
   Endif
Endif
If !Empty(cRet)
	cResult := cRet
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPSDADPSAU ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna informação do prof de saude com base na selecao		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPCBOSPSAU()
LOCAL cResult := "true|||||||||||||||||||||||"
LOCAL cRet 	  := ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega detalhe do profissional										   	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if HttpGet->cTpProf != NIL .AND. !Empty(HttpGet->cTpProf)
    cRet := PPSDETPRO(HttpGet->cProSaud,"W2",HttpGet->cTpProf)
else
    cRet := PPSDETPRO(HttpGet->cProSaud,"W")
endif

If ExistBlock('PLSPROF')
	aRet :=Execblock('PLSPROF',.F.,.F.,{HttpGet->cProSaud,HttpGet->cMatric})
   If !aRet[1]
  		cRet:="false|"+aRet[2]
   Endif
Endif
If !Empty(cRet)
	cResult := cRet
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPSDADRSOL ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna informação do prof de saude com base na selecao		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPSDADRSOL()
LOCAL nPos	  := 0
LOCAL cResult := "true|"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados da Rda																	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nPos := aScan( HttpSession->RDASOLT, { |x| AllTrim(x:cNAME) == AllTrim(HttpGet->cNomeSolT) } ) ) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Para a resposta																	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cResult +=	HttpSession->RDASOLT[nPos]:cCnpfCpf+"|"+;
				HttpSession->RDASOLT[nPos]:cCode+"|"+;
				HttpSession->RDASOLT[nPos]:cCodProf+"|"+;
				HttpSession->RDASOLT[nPos]:cCodOpe+"|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPSVLDESP  ³ Autor ³ Alexander Santos     ³ Data ³ 06.08.2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna especifica do cliente com base no ponto de entrada	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPSVLDESP()
LOCAL cResult := "true||"
LOCAL aRet	  := ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega informacao para tratamento no ponto de entrada					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCodRda := HttpGet->cCodRda
cMatric := HttpGet->cMatric
cCodPad := HttpGet->cCodPad
cCodPro := HttpGet->cCodPro
dDatPro := HttpGet->dDatPro
nVlrPro := HttpGet->nVlrPro
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica ponto de entrada											   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  ExistBlock("PPLREGBTN")
	aRet := ExecBlock( "PPLREGBTN",.F.,.F.,{cCodRda,cMatric,cCodPad,cCodPro,dDatPro} )
	If Len(aRet)>0 .And. !Empty(aRet[1])
		cResult := "false|"+AllTrim(aRet[1])+"|"
	EndIf
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPSDETRDA  ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna informação da rda com base na selecao do combo 		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PPSDETRDA(cRda,cCodLoc, cTpGuia)
LOCAL nI
LOCAL nPosRDA := 0
LOCAL cResult := "true|NORMAL|||||||||||||||||||||||"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ se nao e necessario o codloc na busca da Rda
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if !empty(cCodLoc)
nPosRDA := aScan( HttpSession->RDAVIEW, { |x| x:cCODE == cRda .And. x:cCodLoc == cCodLoc} )
else
	nPosRDA := aScan( HttpSession->RDAVIEW, { |x| x:cCODE == cRda} )
endIf

HttpSession->cEndCon :=	""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta resultado														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPosRDA > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o endereco do contratado										   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Dados do profissional de saude da rda								   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cDadProf := Iif ((cTpGuia $ "6,5") .or. Empty(AllTrim(HttpSession->RDAVIEW[nPosRDA]:cCodBB0)), "", StrTran( PPSDETPRO(HttpSession->RDAVIEW[nPosRDA]:cCodBB0,"W"),"true|",""))
						cResult +=	IiF(Empty(cDadProf),"|||||",cDadProf)+"|"//16-cCodSig, 17-cNumCr, 18-cEstado, 19-cName, 20-cCpfCnpj, 21-cCodOpe
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Local de atendimento													   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cResult +=	HttpSession->RDAVIEW[nPosRDA]:cCodLoc+"|"//22
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Carater da Solicitacao												   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cResult +=	HttpSession->RDAVIEW[nPosRDA]:cCarSol+"|"//23
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Se for maior que um coloca o cabecalho								   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Len(HttpSession->RDAVIEW[nPosRDA]:OWSMESPRDA:OWSESPRDA) > 1
							cResult +=	"~$-- CBOS --"
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Monta as especialidades												   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nI:=1 To Len(HttpSession->RDAVIEW[nPosRDA]:OWSMESPRDA:OWSESPRDA)
						     cResult +=	"~"+HttpSession->RDAVIEW[nPosRDA]:OWSMESPRDA:OWSESPRDA[nI]:cCodEsp+;//24
									    	HttpSession->RDAVIEW[nPosRDA]:OWSMESPRDA:OWSESPRDA[nI]:cCodCBOS+"$"+;
											AllTrim(HttpSession->RDAVIEW[nPosRDA]:OWSMESPRDA:OWSESPRDA[nI]:cDesCBOS)
						Next
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Versão da TISS utilizada pela RDA                                       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aRDA := ClassDataArr(HttpSession->RDAVIEW[nPosRDA])
						If aScan(aRDA,{|x| AllTrim(x[1]) == "CTISSVER"  }) > 0
							cResult +=	"|"+HttpSession->RDAVIEW[nPosRDA]:cTissVer+"|"//25
						EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLDADRDA  ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna informação da rda com base na selecao do combo 		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLDADRDA()
LOCAL cHtml := ""
Private lProSauLoad := .T.

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacao da rda													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(HttpGet->cRda) <> 'U' .And. ValType(HttpGet->cCodLoc) <> 'U'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verfica se precisa carregar profissionais									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(HttpSession->PROSAUD) == 'U' .Or. Len(HttpSession->PROSAUD) == 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ obj																			³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObj := WSPLSXFUN():New()
		WsChgURL( @oObj, "PLSXFUN.APW" )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Parametros																    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObj:cUSERCODE	:= "MSALPHA"
		oObj:cRdaCode	:= HttpGet->cRda
		oObj:cCodLoc	:= HttpGet->cCodLoc
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Lista de profissional de saude										   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !HttpSession->cTp $ "1,2,3,4,11,12,5,6" //Tipo de Guia 
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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dados da Rda														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cResult := PPSDETRDA(HttpGet->cRda, HttpGet->cCodLoc, HttpSession->cTp)
Else
	cResult := PPSDETRDA("")
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSERGET  ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pega o conteudo do campo da matriz							 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PPLSERGET(cVar,aDad)
LOCAL nPos
LOCAL cVal := ""
LOCAL 	cHtml := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pesquisa na matriz e pega o valor									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPos := aScan(aDad,{|x|AllTrim(x[1])==AllTrim(cVar)})
If nPos > 0
	If AllTrim(cVar) == 'cSeq' .And. Empty(aDad[nPos,2])
		cVal := '001'
	Else
		cVal := aDad[nPos,2]
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cVal

function getCmpAlt(aCamposAlterados, cTipo,  aCampoCabec, aCampoItem)

local aRet := {}
local cEsp := ""
local nFor
local cTpCon
local cTpSai
local cTpDoe
local cTmpDoe
local cTmpDoeC
local cIndAcid
local aTabDup := PlsBusTerDup(SuperGetMv("MV_TISSCAB",.F.,"87"))
local objGuia
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

/*
	Função Responsável pela processamento da alteração de guias offline.
*/

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

return  PLSDECODE(cResult)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLPROCGUI ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa as Guias											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLPROCGUI()
LOCAL nI,nY		  := 0
LOCAL nPos		  := 0
LOCAL oObj			:= NIL
LOCAL oObjAux		:= NIL
LOCAL oObjSex 		:= NIL
LOCAL nIteAut     := 0
LOCAL nIteNeg     := 0
LOCAL nTmpDoe	  := 0
LOCAL nValTot	  := 0
LOCAL cResultCab  := "true|"
LOCAL cResultItem := ""
LOCAL cResultSenPr:= ""
LOCAL cCodEsp		:= ""
LOCAL cEspSol		:= ""
LOCAL cEspExe		:= ""
LOCAL cNomeSol	  := ""
LOCAL cProExe     := ""
LOCAL cCodOpeExe  := ""
LOCAL cProSol     := ""
LOCAL cCodOpeSol  := ""
LOCAL cCid		  := ""
LOCAL cCid2		  := ""
LOCAL cCid3		  := ""
LOCAL cCid4		  := ""
LOCAL cCid5		  := ""
LOCAL cCbos		  := ""
LOCAL cTpCon 	  := ""
LOCAL cTpSai	  := ""
LOCAL cTpAteExe	  := ""
LOCAL cTpDoe	  := ""
LOCAL cTmpDoeC	  := ""
LOCAL cIndAcid	  := ""
LOCAL cNomeRda	  := ""
LOCAL cCnpjCpfSol := ""
LOCAL cCnesSol    := ""
LOCAL cCnesExe    := ""
LOCAL cCpfExe	  := ""
LOCAL cNumAut	  := ""
LOCAL cResult 	  := ""
LOCAL cTpAto	  := ""
LOCAL cTpFat 	  := ""
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
LOCAL cTpIntern	  := ""
LOCAL cRegInter	  := ""
LOCAL cOrigem	  := "2"
LOCAL cStatus 	  := "1"
LOCAL cGrPar      := ""
LOCAL cCodSig 	  := ""
LOCAL cNumCr	  := ""
LOCAL cEstado 	  := ""
LOCAL cNomfExe	  := ""
LOCAL cUsuProc    := ""
LOCAL cSexo       := ""
LOCAL cTpAcom	  := ""
LOCAL cPadCon	  := ""
LOCAL cQtdDSol	  := ""
LOCAL cCnpjSolT	  := ""
LOCAL cDadInt	  := ""
LOCAL cResAut	  := ""
LOCAL cIndCliEvo  := ""
LOCAL cNumPeg	  := ""
LOCAL cVia  	  := ""
LOCAL cAbrang	  := ""
LOCAL cNatur	  := ""
LOCAL cDesGRP	  := ""
LOCAL lFemini		:= .F.
LOCAL lProGe		:= .F.
LOCAL lExecu		:= .F.
LOCAL lChkReg		:= .T.
LOCAL lInter		:= .F.
LOCAL lEvolu		:= .F.
LOCAL lHonor		:= .F.
LOCAL lResInt		:= .F.
LOCAL aMatIte		:= {}
LOCAL aRetProf		:= {}
LOCAL cStProc	  	:= ""
LOCAL cAtendRN		:= ""
LOCAL cTissVer		:= HttpSession->cTISSVer
LOCAL nJ			:= 0
LOCAL aMatGrp		:= {}
LOCAL dPrvInt       := ctod('')
Local cDigigui	:= IIf(Valtype(HttpGet->cTipoOrigem) == "U", "", HttpGet->cTipoOrigem)
Local aAlerta   := {}
Local nAl       := 0
Local lAlerta   := .F.
Local cResAlert := ""
Local cTipoConfirm	:= IIf(Valtype(HttpGet->cTipoConfirm) == "U", "", HttpGet->cTipoConfirm)
LOCAL cProtoc	  	:= ""
LOCAL nC			:= 0
LOCAL nP			:= 0
LOCAL cTokEdi	  	:= ""
LOCAL cImpNoAut	  	:= ""
LOCAL aNoAutTemp  	:= {}
LOCAL cTextoRadio  := "false"
LOCAL aSeqProc		:= {} 
LOCAL lProcSeq      := .F. 
LOCAL cHtml := ""
LOCAL nTmpIni		:= 0
LOCAL cNumGui		:= ""
LOCAL lTimeAte		:= .f.
Local lTissVt		:= Iif( (!Empty(cTissVer) .and. cTissVer >= "3"), .T., .F.)
Local cCarSol  		:= ""

nTmpIni := Seconds()

WEB EXTENDED INIT cHtml START "InSite"

if !empty(cDigigui)
	nIteAut := 1
endif

	oObjPar := WSCFGDICTIONARY():New()
	WsChgURL( @oObjPar, "CFGDICTIONARY.APW" )

	oObjPar:cUSERCODE	:= "MSALPHA"
	oObjPar:cMVPARAM	:= "MV_PTIMATE" //Informa se é gestante na solicitação (1) ou na execução (2)

	If oObjPar:GETPARAM()

		lTimeAte := oObjPar:cGETPARAMRESULT

		If ValType(lTimeAte) == 'U'
			lTimeAte := .F.
		ElseIf	ValType(lTimeAte) == 'C'
			If Type(lTimeAte)=="L"
				lTimeAte := &(lTimeAte)
			EndIf
		EndIf

	EndIf

	oObjPar:cMVPARAM	:= "MV_PLPROGE"
	If oObjPar:GETPARAM()
		cUsuProc := oObjPar:cGETPARAMRESULT
		If Type(cUsuProc) == 'L'
			cUsuProc := ""
		EndIf
	EndIf

	If Empty(cUsuProc) //Se esse cara ta vazio eu nem preciso rodar os parametros abaixo pq nao vai servir pra nada de acordo com a logica proposta
	
	oObjPar:cMVPARAM	:= "MV_PLCHAGE" //Informa se é gestante na solicitação (1) ou na execução (2)
	If oObjPar:GETPARAM()
		cChaGe := oObjPar:cGETPARAMRESULT
		If Type(cUsuProc) == 'L'
			cChaGe := ""
		EndIf
	EndIf
		
	//Web Service * retorna sexo											   
	oObjSex := WSPLSXINC():New()
	WsChgURL( @oObjSex, "PLSXINC.APW" )

	oObjSex:cUSERCODE	:= "MSALPHA"	//Usuario

	if HttpPost->cNumecart = NIL
	    oObjSex:cMatricula 	:= HttpGet->cNumecart // matricula
		    cMatricula := HttpGet->cNumecart
	else
	oObjSex:cMatricula 	:= HttpPost->cNumecart // matricula
			cMatricula := HttpPost->cNumecart
	endif

	If oObjSex:SexoUser()
		cSexo := oObjSex:cSexoUserResult
	EndIf

	lFemini:= (cSexo=="2")
	EndIf

//Sessao para impressao da guia										   
HttpSession->aResult := {}
HttpSession->lSen 	 := .F.

//PLSXMOV																	 		  
oObj := WSPLSXMOV():New()
WsChgURL( @oObj, "PLSXMOV.APW" )

//Processa a guia																	  
oObj:cUSERCODE	:= "MSALPHA"				//Usuario
oObj:cRDACODE 	:= HttpPost->cRDA			//Rda
oObj:nAUTTYPE	:= Val(HttpSession->cTp)	//Tipo de guia consulta,sadt,internacao,Odonto

If cDigigui <> ""
	oObj:cDigitacaoGuia	:= HttpGet->cTipoOrigem
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
		cCodEsp 	:= cEspSol
		cTpCon 	 := HttpPost->cTpCon
		
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

		cIndAcid:= HttpPost->cIndAcid
		cCodSig 		:= HttpPost->cCodSigExe
		cNumCr			:= HttpPost->cNumCrExe
		cEstado 		:= HttpPost->cEstSigExe

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
			cCbos := HttpPost->cCbosSol
			cEspSol	:= SubString(cCbos,1,3)
    	   	cCodEsp	:= cEspSol
    	EndIf

		lChkReg  				:= .T.
		
		If ! Empty(cTissVer) .and. cTissVer >= "3"
	    	cCid 					:= ""
	    Else
	    	cCid 					:= HttpPost->cCid
	    EndIf
        cProSol  				:= HttpPost->cProSol
                
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
        If HttpPost->cNumAut <> "" .Or. !Empty(HttpPost->cSolExe) .Or. !Empty(cDigigui)
		
			cCarSol 				:= HttpPost->cCarSol	//Carater da solicitacao na execução			
			cNumAut					:= AllTrim(StrTran(StrTran(HttpPost->cNumAut,".",""),"-",""))
			HttpSession->cTpComprov	:= 'Sadt - Execução'
			cCbos	 				:= HttpPost->cCbosExe
	        cEspExe	 			:= SubString(cCbos,1,3)
	        cProExe  				:= HttpPost->cProExe
	        
	        if !empty(cProExe)
	           aRetProf := PPSDETPRO(cProExe,"L")
	        endif
	        
	        If Len(aRetProf) > 0
				cCodOpeExe	:= aRetProf[1,6]
			EndIf
			
			cNomeRda  := HttpPost->cNomeRdaExe
	        cOrigem   := "1"

			If !Empty(cTissVer) .AND. cTissVer >= "3"
				
				cTpCon 	 	:= HttpPost->cTpCon
				cCnesExe   		:= HttpPost->cCnesExe
				cCnpjCpfSol := HttpPost->cCnpjCpfSol//12
				
				//Implementar Executantes da guia
			Else
				cTpDoe	  := HttpPost->cTpDoe
				nTmpDoe	  := Val(HttpPost->cTmpDoe)
				cTmpDoeC  := HttpPost->cTmpDoeC
			EndIf

			If cChaGe == "2"
				lExecu    := .T.
			Endif
			
	    Else
		    
		    If Type('HttpPost->cIndAcid') <> 'U' 
		    	cIndAcid  := HttpPost->cIndAcid
		    EndIf 
		    
		    If cChaGe == "1"
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
		cEspSol  	 			:= SubString(cCbos,1,3)
       cCodEsp					:= cEspSol
		lChkReg  				:= .T.
   		lInter 					:= .T.

		//Contratado Solicitante
		cCnpjCpfSol 	:= HttpPost->cCnpjCpfSol //12 <-- BE4_RDACON
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
			cTpAcom	   	:= HttpSession->aVldCartao[18]
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
		cTpAto 					:= HttpPost->cTpAto
		cTpFat 					:= HttpPost->cTpFat
		
        If Len(aRetProf) > 0
			cNomeSol 	:= aRetProf[1,4]
			cCodOpeSol	:= aRetProf[1,6]
		Else
			cNomeSol := HttpPost->cNomeSol
		EndIf
		
		cNomeRda  := HttpPost->cNomeRda
        cOrigem	  := "2"
		
		//Executante
        If HttpPost->cNumAut <> "" .Or. !Empty(HttpPost->cProExe)
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
    		cNomfExe 		:= ""
			cGrPar  		:= ""
		Else
			cNomfExe 		:= HttpPost->cNomExe
			cGrPar  		:= HttpPost->cGrPar
		EndIf
		
		//Descricao do Grau de participacao
		If (nPos := aScan( HttpSession->aGrPart, { |x| x:cCODE == cGrPar} ) ) > 0
			cDesGRP := HttpSession->aGrPart[nPos]:CDESCRIPTION
		EndIf

		cCodSig 		:= HttpPost->cCodSigExe
		cNumCr			:= HttpPost->cNumCrExe
		cEstado 		:= HttpPost->cEstSigExe
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
		lChkReg 			:= .T.
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
		cTpFat 	:= HttpPost->cTipFat
		cNumDecVivo	:= HttpPost->cNumDecVivo
		cNumDecObt		:= HttpPost->cNumDecObt
		cIndicRN		:= HttpPost->cIndicRN
		cHorIniFat		:= HttpPost->cHorIniFat
		cHorFimFat		:= HttpPost->cHorFimfat
		
		cNomeRda  := HttpPost->cNomeRdaSol
		cTpSai	  := HttpPost->cTpSai
		
		//Executante
		If (nPos := aScan( HttpSession->aGrPart, { |x| x:cCODE == cGrPar} ) ) > 0
			cDesGRP := HttpSession->aGrPart[nPos]:CDESCRIPTION
		EndIf

		cCodSig 		:= HttpPost->cCodSigExe
		cNumCr			:= HttpPost->cNumCrExe
		cEstado 		:= HttpPost->cEstSigExe
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
		cEspExe				:= SubString(cCbos,1,3)
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
oObj:cOrigem 												:= cOrigem							//Se e para solicitar ou executar

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
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cRDACON 			:= IIF((!empty(cCnpjCpfSol) .and. HttpSession->cTp == "3"), cCnpjCpfSol, "")	//Codigo do Solicitante



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
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCARDNAME			:= HttpGet->cNomeUsu 				//Nome do cartao
else
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCARDNAME			:= HttpPost->cNomeUsu 				//Nome do cartao
endif

oObj:oWSAUTHORIZATION:oWSAUTHEADER:cSpecialityCode	:= cCodEsp								//Especialidade da RDA (BD5_CODESP)
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cEspSol			:= cEspSol								//Especialidade solicitante (BD5_ESPSOL)
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cEspExe			:= cEspExe								//Especialidade executante (BD5_ESPEXE)

If Type('oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW:cCBO') <> 'U'
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCBO					:= SubString(cCbos, 4, len(cCbos))							//CBO

ElseIf HttpSession->cTp == '11'  
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCBO					:= cCbos													//CBO   
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
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cCarSol			:=cCarSol
endif 

oObj:oWSAUTHORIZATION:oWSAUTHEADER:cIndCli				:= HttpPost->cIndCliSol				//Indicacao clinica
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cFormNumber			:= HttpPost->cFormNumber			//Numero Impresso
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cObs					:= HttpPost->cObs					//Observacao
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cEndCon				:= HttpSession->cEndCon				//Endereco Contratado

oObj:oWSAUTHORIZATION:oWSAUTHEADER:lInter				:= lInter							//Internacao
oObj:oWSAUTHORIZATION:oWSAUTHEADER:lEvolu				:= lEvolu							//Prorrogacao
oObj:oWSAUTHORIZATION:oWSAUTHEADER:lHonor				:= lHonor			   				//Honorario
oObj:oWSAUTHORIZATION:oWSAUTHEADER:lResInt				:= lResInt							//Resumo de internacao
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cNumPeg				:= cNumPeg							//Numero da Guia Chave no BD6
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cProtoc				:= cProtoc							//Numero do Protocolo de Atendimento
oObj:oWSAUTHORIZATION:oWSAUTHEADER:cGuiPre	 			:= HttpPost->cNumPre				//Numero Guia Prestador via Guia de Consulta do Portal

oObj:oWSAUTHORIZATION:oWSAUTHEADER:cTipoConfirm			:= cTipoConfirm						//string que indica a confirmação ou não da finalização da guia

If Type('HttpPost->cTokEdi') <> 'U' 
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cTokEdi				:= cTokEdi							//Token PTU Online
EndIf 

If ValType(HttpPost->dDtRlz) <> "U"
	
	If !Empty(HttpPost->dDtRlz)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz				:= ctod(HttpPost->dDtRlz)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz := ctod('')
	Endif
	
EndIf

If ValType(HttpPost->dDtRlz2) <> "U"
	
	If !Empty(HttpPost->dDtRlz2)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz2				:= ctod(HttpPost->dDtRlz2)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz2 := ctod('')
	Endif
	
EndIf

If ValType(HttpPost->dDtRlz3) <> "U"
	
	If !Empty(HttpPost->dDtRlz3)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz3				:= ctod(HttpPost->dDtRlz3)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz3 := ctod('')
	Endif
	
EndIf

If ValType(HttpPost->dDtRlz3) <> "U"
	
	If !Empty(HttpPost->dDtRlz3)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz3				:= ctod(HttpPost->dDtRlz3)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz3 := ctod('')
	Endif
	
EndIf

If ValType(HttpPost->dDtRlz4) <> "U"
	If !Empty(HttpPost->dDtRlz4)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz4				:= ctod(HttpPost->dDtRlz4)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz4 := ctod('')
	Endif
EndIf

If ValType(HttpPost->dDtRlz5) <> "U"
	If !Empty(HttpPost->dDtRlz5)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz5				:= ctod(HttpPost->dDtRlz5)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz5 := ctod('')
	Endif
EndIf

If ValType(HttpPost->dDtRlz6) <> "U"
	If !Empty(HttpPost->dDtRlz6)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz6				:= ctod(HttpPost->dDtRlz6)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz6 := ctod('')
	Endif
EndIf

If ValType(HttpPost->dDtRlz7) <> "U"
	If !Empty(HttpPost->dDtRlz7)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz7				:= ctod(HttpPost->dDtRlz7)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz7 := ctod('')
	Endif
EndIf

If ValType(HttpPost->dDtRlz8) <> "U"
	If !Empty(HttpPost->dDtRlz8)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz8				:= ctod(HttpPost->dDtRlz8)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz8 := ctod('')
	Endif
EndIf

If ValType(HttpPost->dDtRlz9) <> "U"
	If !Empty(HttpPost->dDtRlz9)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz9				:= ctod(HttpPost->dDtRlz9)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz9 := ctod('')
	Endif
EndIf

If ValType(HttpPost->dDtRlz1) <> "U"
	If !Empty(HttpPost->dDtRlz1)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz1				:= ctod(HttpPost->dDtRlz1)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dDtRlz1 := ctod('')
	Endif
EndIf


If Empty(oObj:oWSAUTHORIZATION:oWSAUTHEADER:cGuiPri) .And. HttpSession->cTp == "2"
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cGuiPri	 			:= Iif( ValType(HttpPost->cNumInt)=='U','',AllTrim(StrTran(StrTran(HttpPost->cNumInt,".",""),"-","")) )//Numero da guia principal
EndIf
If ValType(HttpPost->cAtendRN) <> "U"
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cAtenRN				:= HttpPost->cAtendRN		//Atendimento a RN
EndIf

If Type('HttpPost->cAtenRN') <> "U"
	
	If HttpSession->cTp == "3"
	
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:cAtenRN				:= IIF(HttpPost->cAtenRN == "2","0","1")			//Atendimento a RN
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:cAtenRN				:= HttpPost->cAtenRN			//Atendimento a RN
	EndIf
	
EndIf

If aScan(aClasse,{|x| AllTrim(x[1]) == "CPRVOPM"  }) > 0  .and.  Type('HttpPost->cOpme') <> "U"
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cPrvOpm			:= HttpPost->cOpme
EndIf

If aScan(aClasse,{|x| AllTrim(x[1]) == "CPRVQUI"  }) > 0 .and.  Type('HttpPost->cQuimio') <> "U"
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:cPrvQui			:= HttpPost->cQuimio
EndIf

If ValType(HttpPost->dDataIniFat) <> "U"
	If !Empty(HttpPost->dDataIniFat)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dIniFat				:= ctod(HttpPost->dDataIniFat)		//Inicio Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dIniFat := ctod('')
	EndIf
Else
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:dIniFat := ctod('')
EndIf

If ValType(HttpPost->dDataFimFat) <> "U"
	If !Empty(HttpPost->dDataFimFat)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dFimFat				:= ctod(HttpPost->dDataFimFat)		//Fim Faturamento
	Else
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dFimFat := ctod('')
	Endif
Else
	oObj:oWSAUTHORIZATION:oWSAUTHEADER:dFimFat := ctod('')
EndIf

//Guia de Honorário
If ValType(HttpPost->dDadaFimFat) <> "U"
	If !Empty(HttpPost->dDadaFimFat)
		oObj:oWSAUTHORIZATION:oWSAUTHEADER:dFimFat				:= ctod(HttpPost->dDadaFimFat)		//Fim Faturamento
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


	If ExistBlock("PPLSVPTU")
		lRet := ExecBlock("PPLSVPTU",.F.,.F.,{cMatricula,cNumAut})
		If !lRet
			Return(.F.)
		Endif
	EndIf

//Alimenta a strutura ws com todos os itens do formulario genericamente   
oObj:oWSAUTHORIZATION:oWSAUTITEM := PLSXMOV_ARRAYOFAUTITEMVIEW():New()

For nI:=1 To Len(aMatIte)

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
	elseIf !(Empty(httpSession->dDtaAtend)) //Guia de consulta - Digitação OffLine
		oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:dDatPro := CTOD( httpSession->dDtaAtend )
	EndIf

	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:nPROCEDUREQUANTITY	:= Val( PPLSERGET('nQtdSol',aMatIte[nI]) )							//Qtd Solicitada
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:nQtdAut  			:= Val( PPLSERGET('nQtdAut',aMatIte[nI]) ) 						//Qtd Autorizada
	
	//Alterado o tratamento, agora retira toda a máscara e divide o valor por 100, garantindo o resultado correto
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:nVlrApr  			:= Val( StrTran(strtran(PPLSERGET('nVlrApr',aMatIte[nI]),',',''),'.','') )/100			//Valor Apresentado
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cResAut  			:= AllTrim( PPLSERGET('cResAut',aMatIte[nI]) )						//Respon. pela Autorizacao
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cIndCliEvo  		:= AllTrim( PPLSERGET('cIndCliEvo',aMatIte[nI]) )					//Indicacao Clinica
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cDente  			:= AllTrim( PPLSERGET('cDente',aMatIte[nI]) )						//Dente
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cFace  			    := AllTrim( PPLSERGET('cFace',aMatIte[nI]) )						//Face
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cHorIni			    := AllTrim( StrTran(PPLSERGET('cHorIni',aMatIte[nI]),':','') )		//Hora Inicio
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cHorFim			    := AllTrim( StrTran(PPLSERGET('cHorFim',aMatIte[nI]),':','') )		//Hora Fim
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cViaAc			    := AllTrim( StrTran(PPLSERGET('cViaAc',aMatIte[nI]),':','') )		//Via
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cTecUt			    := AllTrim( StrTran(PPLSERGET('cTecUt',aMatIte[nI]),':','') )		//Tec
	
	if HttpSession->cTp == '5' .or. HttpSession->cTp == '6' 
		oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:nRedAcre		    := Val(PPLSERGET('nRedAcre',aMatIte[nI]) )						//RedAcre
	else
		oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:nRedAcre		    := Val( StrTran(strtran(PPLSERGET('nRedAcre',aMatIte[nI]),',',''),'.','') )/100	//RedAcre
	endif
	
	oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cDiagPro		    :=  PPLSERGET('cDiagPro',aMatIte[nI] ) 						//cDiagPro

		oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:cStProc			:= AllTrim( PPLSERGET('cStatus',aMatIte[nI]) )						//Status do Procedimento

	//Alimenta a strutura ws com todos os itens do formulario genericamente   
	aClasse := ClassDataArr(oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI])
	
	If aScan(aClasse,{|x| AllTrim(x[1]) == "OWSGRPPAREXE"  }) > 0
		oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW[nI]:oWSGRPPAREXE := PLSXMOV_ARRAYOFGRPPAREXE():New()
		nCmp := 0
		
		For nJ:=1 To Len(aMatGrp)

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
				
				aRetProf 		:= PPSDETPRO(AllTrim( PPLSERGET('cProExeDesc'	,aMatGrp[nJ]) ),"L")
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
  					HttpSession->aVldCartao[18]+"*"

		//Dados da Rda																	  
		If !Empty(HttpPost->cNomeSolT)
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
			  		cDadInt+"||||||"						        //4
	cNumGui := oObj:oWSPUTAUTHORIZATIONRESULT:cNUMBER		  	

	//Procedimentos autorizados														  
    cResultA := ""
    cResultN := ""
	
    For nI:=1 To Len(oObj:oWSPUTAUTHORIZATIONRESULT:oWSAUTHORIZED:oWSAUTHORIZEDVIEW)
    	
	    nIteAut := 1
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

		If (cCodTab+cCodPro) $ cUsuProc
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
	//Procedimentos nao autorizados Obs (Nao precisa do if pq e a ultima implementacao) ³
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
			
			For nC := Len(HttpSession->aResult) To 1  step -1 
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

	cStatus := Iif( nIteAut==1 .and. nIteNeg==0,"1",Iif( nIteAut==0 .and. nIteNeg==1,"3","2") )

    If oObj:oWSPUTAUTHORIZATIONRESULT:lAto .And. cStatus $ "1,2"
	    cStatus := "5"
	EndIf
	//TODO rever a chamado da funcao RetSx3Box
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
	
	if !empty(cDigigui)
		HttpSession->cTitulo := "Guia gravada com sucesso."
	endif

	If nIteAut==1 .and. nIteNeg==0
		
		cResultA	:= ""

		If lAlerta

			cResultItem := cResultA + cResultN + cResAlert
		Else
			cResultItem := cResultA
		EndIf
	EndIf

	If nIteNeg==1	.and. nIteAut==1

		If lAlerta
		cResultItem	:= cResultA+cResultN + cResAlert
		Else
			cResultItem	:= cResultA+cResultN
		EndIf
	EndIf

	If nIteAut==0 .and. nIteNeg==1
		cResultItem	:= cResultN
	EndIf
	
	// RETIRADO O RETORNO DO VALOR DE COPARTICIPAÇÃO DAQUI QUE GRAVA EM UMA SESSION QUE NÃO É UTILIZADA NESSE MOMENTO
	// ESTAVA ONERANDO DESNECESSARIAMENTE A APLICAÇÃO
	
	//Para digitação de guias off-line o tratamento das críticas e alertas é diferenciado.
	IF !empty(cDigigui)
		
		//Incluimos o tratamento de alertas da consulta na digitação off-line nesse trecho pois a digitação off-line não alimenta o array de procedimentos autorizados
		IF HttpSession->cTp == '1' .and. !Empty(oObj:oWSPUTAUTHORIZATIONRESULT:oWSALERTA:oWSAUTERRORVIEW)
		
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
If lTimeAte
    oObjPar:cMsgLog  := Time()+ "|" + Alltrim(Str(Seconds() - nTmpIni)) + "|" + HttpPost->cRDA + "-" + cNomeRda + "|" + HttpSession->cTp  + "|" + IIf(!Empty(HttpPost->cNumAut),"Exec","Solic")  + "| Itens: " + Alltrim(StrZero(Len(aMatIte),3))  + "|" +  cNumGui + "|" + cDigigui 
    oObjPar:cFileLog := "ConfirmaAtendimento.txt"
    oObjPar:PutPLSLogFil()
EndIf

Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLFINCUS   ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Abre o formulario de inclusao de usuario de intercambio		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLFINCUS()

LOCAL cHtml	:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio Extended														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Direciona para pagina												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml := ExecInPage( "PPLSINCUSU" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim Extended														   	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLINCUSU   ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa a inclusao de usuario de intercambio				 	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLINCUSU()
LOCAL nI
LOCAL oObj
LOCAL cResult := "true|||"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXINC():New()
WsChgURL( @oObj, "PLSXINC.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimenta parametros													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUserCode				:= "MSALPHA"
oObj:OWSINCMAT:cMatricula	:= HttpPost->cMatric
oObj:OWSINCMAT:cNome		:= HttpPost->cNome
oObj:OWSINCMAT:cSexo		:= HttpPost->cSexo
oObj:OWSINCMAT:dDatNas		:= CtoD(HttpPost->cDatNas)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inclusao																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLFINCPR   ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Abre o formulario de inclusao de profissional de saude		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLFINCPR()
LOCAL cHtml	:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio Extended														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Direciona para pagina												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpPost->cRda    := HttpGet->cRda
HttpPost->cCodLoc := HttpGet->cCodLoc
If Type('HttpGet->cTp') <> 'U'
	HttpPost->cTp     := HttpGet->cTp
Else
	HttpPost->cTp     := '1'//tipo execucao, so mostra as especialidades da RDA
Endif
cHtml := ExecInPage( "PPLSINCPRO" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim Extended														   	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLLISTPCT   ³ Autor ³ Roberto Vanderlei   ³ Data ³ 22.04.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Abre o formulário para listagem de pacotes.	 				 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLLISTPCT()
LOCAL cHtml	:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio Extended														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Direciona para pagina												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpPost->cRda    := HttpGet->cRda
HttpPost->cCodLoc := HttpGet->cCodLoc
If Type('HttpGet->cTp') <> 'U'
	HttpPost->cTp     := HttpGet->cTp
Else
	HttpPost->cTp     := '1'//tipo execucao, so mostra as especialidades da RDA
Endif
cHtml := ExecInPage( "PPLSINCPRO" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim Extended														   	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLPROCPRO  ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa a inclusao de profissional de saude					 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLPROCPRO()
LOCAL oObj
LOCAL cResult := ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXINC():New()
WsChgURL( @oObj, "PLSXINC.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimenta parametros													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Executa o metodo de inclusao	incluir RDA
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:INCPRSAUDE()
	cResult := oObj:cINCPRSAUDERESULT
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLIMPGUIA  ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama formulario de impressao (comprovante)					 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLIMPGUIA()
LOCAL cHtml	  := ""
LOCAL cArqAph := ""

WEB EXTENDED INIT cHtml START "InSite"

If ExistBlock("PPLMFUN1")
	cRet  := Execblock("PPLMFUN1",.F.,.F.,{})
	cHtml := ExecInPage( cRet )
Else

	cArqAph := PPSAphGuia(HttpSession->cTp)
	cHtml 	:= ExecInPage(cArqAph)

Endif

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLRETOCHA  ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna para a pagina de digitacao da carteirinha			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLRETOCHA()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

	cHtml := ExecInPage( "PPLCARTMAT" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSMONCON ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta matriz de todos os conselho bah						 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSMONCON()
LOCAL nI
LOCAL oObj
LOCAL cResult  	:= "true|"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ oBJ																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSMCTMD():New()
WsChgURL( @oObj, "PLSMCTMD.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE := "MSALPHA"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa metodo para pegar os conselhos								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:getSigCon()
	For nI:=1 To Len(oObj:oWSGETSIGCONRESULT:oWSGenericStruct)
		cResult +=	oObj:oWSGETSIGCONRESULT:oWSGenericStruct[nI]:cCode+"$"+;
					oObj:oWSGETSIGCONRESULT:oWSGenericStruct[nI]:cDescription+"|"
	Next
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLTRTIND ³ Autor ³ Daher			     ³ Data ³ 17.12.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ 																 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Web Function PPLTRTIND()

LOCAL cResult 	:= "true|"
LOCAL aMat 	  	:= {}
LOCAL oObj	  	:= Nil
LOCAL cString 	:= HttpGet->cString
LOCAL nI		:= 0
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

If !Empty(cString)
	While ( nPos := At( "|", cString ) ) > 0
	    AaDd( aMat,SubStr( cString, 1, nPos-1 ) )
	    cString := SubStr( cString, nPos+1, Len(cString) )
	EndDo
EndIf

If Len(aMat) > 0
	oObj := WSPLSXFUN():New()
	WsChgURL( @oObj, "PLSXFUN.APW" )
	oObj:cUSERCODE := "MSALPHA"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta Matriz de itens ja executados									   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		oObj:oWSSAUTPROC:oWSAUTITEM := PLSXFUN_ARRAYOFAUTITEMVIEW():New()

	    For nI:=1 To Len(aMat)
	        If !Empty(aMat[nI])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta dados dos itens												   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aMatIte := PPLSALIMA(aMat[nI]+'||')
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Alimenta a estrutura para envio dos procedimentos ja executados		   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AaDd( oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW, PLSXFUN_AUTITEMVIEW():New() )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quantidade de itens													   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nQtd := Len( oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atribui dados ao obj													   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

Return PLSDECODE(cResult)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³ PPLSINCITE ³ Autor ³ Totvs     ³ Data ³ 	         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSINCITE()

LOCAL aMat 	  	:= {}
LOCAL cString 	:= HttpGet->cString


WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega o conteudo														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cString)
	While ( nPos := At( "|", cString ) ) > 0
	    AaDd( aMat,SubStr( cString, 1, nPos-1 ) )
	    cString := SubStr( cString, nPos+1, Len(cString) )
	EndDo
EndIf



WEB EXTENDED END

return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSAUTITE ³ Autor ³ Alexander Santos     ³ Data ³ 28.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida e inclui dados do procedimento,qtd e codpad			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
LOCAL lTimeAte	:= .F.
Local nTmpIni 	:= Seconds()

WEB EXTENDED INIT cHtml START "InSite"

//Pega o conteudo														   
If ! Empty(cString)
	While ( nPos := At( "|", cString ) ) > 0
	    AaDd( aMat,SubStr( cString, 1, nPos-1 ) )
	    cString := SubStr( cString, nPos+1, Len(cString) )
	EndDo
EndIf

oObjPar := WSCFGDICTIONARY():New()
WsChgURL( @oObjPar, "CFGDICTIONARY.APW" )

oObjPar:cUSERCODE	:= "MSALPHA"
oObjPar:cMVPARAM	:= "MV_PTIMATE" 
If oObjPar:GETPARAM()
	lTimeAte := oObjPar:cGETPARAMRESULT
	If ValType(lTimeAte) == 'U'
		lTimeAte := .F.
	ElseIf	ValType(lTimeAte) == 'C'
		If Type(lTimeAte)=="L"
			lTimeAte := &(lTimeAte)
		EndIf
	EndIf
EndIf


//Verifica se foi enviado algum registro para tratamento				   
If Len(aMat) >= 2

	//Registro no WS														   
	oObj := WSPLSXFUN():New()
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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta Matriz de itens ja executados									   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aMat) > 3

		oObj:oWSSAUTPROC:oWSAUTITEM := PLSXFUN_ARRAYOFAUTITEMVIEW():New()

	    For nI := 3 To Len(aMat)
	        If ! Empty(aMat[nI])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta dados dos itens												   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aMatIte := PPLSALIMA(aMat[nI]+'||')
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Alimenta a estrutura para envio dos procedimentos ja executados		   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AaDd( oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW, PLSXFUN_AUTITEMVIEW():New() )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quantidade de itens													   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nQtd := Len( oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atribui dados ao obj													   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    //³ Na solicitacao da prorrogacao tenho que verificar o Contratato Solicitado
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    If HttpSession->cTp == '3'
		lPror := (HttpGet->cChkPro == '1')
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Rda																	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If valType(HttpSession->RDAVIEW) == 'A' .and. ! lPror
		nPosRDA := aScan( HttpSession->RDAVIEW, { |x| x:cCODE == HttpGet->cRda .And. x:cCodLoc == HttpGet->cCodLoc} )
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica RDA														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
		endif		

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
		If ValType(HttpSession->cDigitacao) == "C" .AND. Capital(HttpSession->cDigitacao) == "Digitacao" .AND. HttpSession->cTp == '2'
			oObj:oWSSAUTPROC:dDatPro 	:= CtoD(HttpGet->dDtExePro)
		EndIf
		
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
		
		If ValType(HttpSession->cDigitacao) == "C" .AND. Capital(HttpSession->cDigitacao) == "Digitacao" //Na digitação offLine é sempre Execução
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
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa o metodo pega o retorno										   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oObj:AutProc()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se foi autorizado ou negado											   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    If oObj:oWSAUTPROCRESULT:lPROAUT
			   cResult += "1|"
			Else
			   cResult += "Critica(s)|"
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Matriz que retorna os resultados formatados campo a campo do formulario		 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cResult += oObj:oWSAUTPROCRESULT:cMatRetRes+"|"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta a string de retorno											   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cResult += oObj:oWSAUTPROCRESULT:cAUTORI+"|"+;
					   oObj:oWSAUTPROCRESULT:cCHAVE+"|"+;
					   oObj:oWSAUTPROCRESULT:cNIVEL+"|"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta as criticas													   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
			
		//Retirado o tratamento do campo Indc. Cli, já é realizado em outro ponto e não existe mais na Struct
		// correspondente no WSPLSXFUN

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
If lTimeAte
    oObjPar:cMsgLog  := Time()+ "|" + Alltrim(Str(Seconds() - nTmpIni)) + "|" + HttpGet->cRDA + "|" + HttpGet->cCodPro + "|" + HttpSession->cTp
    oObjPar:cFileLog := "IncluiDespesa.txt"
    oObjPar:PutPLSLogFil()
EndIf

Return PLSDECODE(cResult)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSHORPAR ³ Autor ³ Roberto Arruda     ³ Data ³ 11.03.2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclui itens para processamento do honorario					 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSHORPAR()
LOCAL nI	  := 0
LOCAL nPosBD6 := 0
LOCAL cResult := "true|"
LOCAL oObj	  := Nil
LOCAL cHtml := ""
local nJ
local aMatGrp := {}
local nOpc
local nRecno
local cTable

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj WebService														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta matriz de participações													 		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(HttpGet->cMatTabExe)
    aMatGrp := PPLSALIMA(HttpGet->cMatTabExe, .T.)
EndIf

//oObj:oWSSAUTPROC:oWSGRPPAREXE := PLSXFUN_ARRAYOFGRPPAREXE():New()

oObj:oWSSAUTPROC:cGrpParExe = ""

For nJ:=1 To Len(aMatGrp)

	//AaDd( oObj:oWSSAUTPROC:oWSGRPPAREXE:oWSGRPPAREXE, PLSXFUN_GRPPAR():New() ) //cNumCrExe;cEstSigExe;
	//oObj:oWSSAUTPROC:oWSGRPPAREXE:oWSGRPPAREXE[nJ]:cGrPar 	:= AllTrim( PPLSERGET('cGrPar'	,aMatGrp[nJ]) )			//Grau Participação
	
	oObj:oWSSAUTPROC:cGrpParExe += AllTrim( PPLSERGET('cGrPar'	,aMatGrp[nJ]) )  + ";"
next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa o metodo pega o retorno										   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:VldHoPar() 
	If oObj:oWSVLDHOPARRESULT:lPROAUT
		cResult += "S|" + nOpc + "|" + nRecno + "|" + cTable + "|" 
	else
		cResult += "N|" + PLSDECODE(oObj:oWSVLDHOPARRESULT:cMatRetRes)
	endif
endif

WEB EXTENDED END


return cResult


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSHORITE ³ Autor ³ Alexander Santos     ³ Data ³ 11.03.2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclui itens para processamento do honorario					 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSHORITE()
LOCAL nI	  := 0
LOCAL nPosBD6 := 0
LOCAL cResult := "true|"
LOCAL oObj	  := Nil
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj WebService														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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


If aScan(  ClassDataArr(oObj:oWSSAUTPROC)   ,{|x| AllTrim(x[1]) == "CTISSVER"  }) > 0

	//Recupera a versão da TISS
	oObj:oWSSAUTPROC:cTissVer := HttpGet->cTissVer

EndIf

If ValType(HttpSession->aMatBD6) <> 'U'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Para garantir se incluiu e excluiu do browse
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	nPosBD6 := aScan( HttpSession->aMatBD6, { |x| !empty(x:cSeqInf) .and.  allTrim(x:cCodPad) == allTrim(HttpGet->cCodPad) .and. allTrim(x:cCodPro) == allTrim(HttpGet->cCodPro)} )
	if nPosBD6>0
		HttpSession->aMatBD6[nPosBD6]:cSeqInf := ""
	endIf

	oObj:oWSSAUTPROC:oWSMATBD6  		 	:= PLSXFUN_ARRAYOFSMATBD6():New()
	oObj:oWSSAUTPROC:oWSMATBD6:oWSSMATBD6	:= HttpSession->aMatBD6
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa o metodo pega o retorno										   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:VldHoIn()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se foi autorizado ou negado											  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If oObj:oWSVLDHOINRESULT:lPROAUT
	   	cResult += "1|"
	   	If oObj:oWSVLDHOINRESULT:nPosBD6>0
		   HttpSession->aMatBD6[oObj:oWSVLDHOINRESULT:nPosBD6]:cSeqInf := oObj:oWSVLDHOINRESULT:cSeqInf
	 	EndIf
	Else
	   	cResult += "0|"
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta as criticas													   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSALIMA  ³ Autor ³ Alexander Santos     ³ Data ³ 28.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alimenta matriz de itens										 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PPLSALIMA(cString, lExec)
LOCAL nPos,nPosAux,nPosAux2
LOCAL cCmpOri,cCmpGer,cCmpC,cCmpV
LOCAL aMatRet   := {}
LOCAL cHtml := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta campos da matriz												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cString)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Linhas																   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While ( nPos := At( "|", cString ) ) > 0

        cCmpOri := SubStr( cString, 1, nPos-1 )
   	    cString := SubStr( cString, nPos+1, Len(cString) )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Colunas																   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (!Empty(cString) .or. lExec) .And. !Empty(cCmpOri)

		    cMatDin := "{|| AaDd(aMatRet,{"
			While ( nPosAux := At( "$", cCmpOri  ) ) > 0

		        If nPosAux > 0
				    cCmpGer := SubStr( cCmpOri, 1, nPosAux-1 )
			        nPosAux2 := At( "@", cCmpGer  )
			   	    cCmpOri := SubStr( cCmpOri, nPosAux+1, Len(cCmpOri) )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Campo e valor														   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			        cCmpC := SubStr( cCmpGer, 1, nPosAux2-1 )
			        cCmpV := AllTrim(SubStr( cCmpGer, nPosAux2+1, Len(cCmpGer) ))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Inclui na matriz														   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		           cMatDin +="{'"+cCmpC+"','"+cCmpV+ "'}" + Iif( !Empty(cCmpOri),",","}) }")
			    EndIf
		   	EndDo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inclui na matriz de retrono											   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		   	Eval(&cMatDin)
		EndIf
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return aMatRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSCHALIB ³ Autor ³ Alexander Santos     ³ Data ³ 28.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Procura a liberacao e mostra os dados						 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUserCode 		 := "MSALPHA"
oObj:cNumAut   		 := AllTrim(StrTran(StrTran(HttpGet->cNumeAut,".",""),"-",""))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³A solicitacao deve informar o tipo.									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
if (cValPr == "1")
	oObj:ccOpcao := "1"
	oObj:cDatGuia := HttpSession->dDtaAtend
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa metodo para retorno da liberacao								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:RetAutLib()

		aClasse := ClassDataArr(oObj:OWSRetAutLibRESULT:OWSSCABGUI)
		If aScan(aClasse,{|x| AllTrim(x[1]) == "CPRVOPM"  }) > 0
	    	cOpme   := oObj:OWSRetAutLibRESULT:OWSSCABGUI:cPrvOpm
	  	EndIf

		If aScan(aClasse,{|x| AllTrim(x[1]) == "CPRVQUI"  }) > 0
	    	cQuimio := oObj:OWSRetAutLibRESULT:OWSSCABGUI:cPrvQui
	  	EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cabecalho															   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

					if ValType(oObj:OWSRetAutLibRESULT:OWSSCABGUI:cTipAut) == "C"
						cResult += "cTipAlt!"+oObj:OWSRetAutLibRESULT:OWSSCABGUI:cTipAut+"|" //96
					EndIf

					if ValType(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNumAux) == "C"
						cResult += "cNumMaxAux!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNumAux+"|"
					endif
					
					cResult += "<" //Fim

		//Número de auxiliares
		HttpSession->cNumAux		:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNumAux

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Matriz de itens														   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI:=1 To Len(oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI)
		    If oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cExibe == "1"
		        lExibe := .T.
	            aClasse := ClassDataArr(oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI])
				  iF aScan(aClasse,{|x| AllTrim(x[1]) == "CDIAGNO"  }) > 0
	            	cDiagno := oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cDiagno
	            Else
	            	cDiagno := ''
	            EndIf

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
							'lPacote!' + oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cPacote +"@"+;
							'cTpProc!'+oObj:OWSRetAutLibRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cTpProc+"~"//25

				  // Esse item ira montar o grid na session, foi necessario pois na chamada da liberação pela sesssion esta vazia ele perdia os procedimentos
	            cValGDExe :=	"cTpServ$"+oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cTpServ+";"+; //0
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
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Honorario Individual													   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao tem procedimento												   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lExibe
			cResult := "false|Nenhum procedimento autorizado para o executante!"
		EndIf
Else
		cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSALERT  ³ Autor ³ Alexander Santos     ³ Data ³ 28.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Procura a liberacao e mostra os dados						 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variavel  para exibir												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->_HTMLERRO[1] := cTopo
HttpSession->_HTMLERRO[2] := cMsg
HttpSession->_HTMLERRO[3] := cPagVolta
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia para o determinado formulario									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml += ExecInPage( "PPLSMSG" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSREIPAR ³ Autor ³ Alexander Santos     ³ Data ³ 28.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina chama formulario de parametros reimpressao da guia	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSREIPAR()
LOCAL cHtml	:= ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama o formulario													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml += ExecInPage( "PPLSPAREIM" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSREIMGU ³ Autor ³ Alexander Santos     ³ Data ³ 28.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para reimpressao da guia								 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSREIMGU()
LOCAL oObj
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametro															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE 		:= "MSALPHA"

//oObj:cUserCardNumber:= AllTrim(StrTran(StrTran(HttpPost->cMatricula,".",""),"-",""))
//Conforme informações, a tratativa de retirada do "ponto" e do "traço" foi devido a uma tratativa antiga,
//porém conforme as novas telas do portal , exemplo a nova tela de atendimento, esta funcionalidade de retirar
//o "ponto" e "traço" foi descontinuado. Por isso retiramos também da reimpressão, conforme abaixo
oObj:cUserCardNumber:= HttpPost->cMatricula
oObj:cRDACode		:= SubStr( HttpPost->cRda,1,At('|',HttpPost->cRda)-1 )
oObj:cCodLoc		:= SubStr( HttpPost->cRda,At('|',HttpPost->cRda)+1 )

If !EMPTY(HttpPost->cDtAut) 
	oObj:dDtAut	    := CtoD(HttpPost->cDtAut)
Else
	oObj:dDtAut 	:= CTOD("")
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama metodo para traser todas as guias do usuario na data e prestador  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:RetAut()
	HttpSession->aMatGuia := { oObj:OWSRETAUTRESULT:OWSSMATAUT }
Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLSREIPAR.APW" )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia para o formulario												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml += ExecInPage( "PPLSREIMGU" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSMATREI ³ Autor ³ Alexander Santos     ³ Data ³ 28.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alimenta a matriz para reimpressao da guia					 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sessao para impressao da guia										   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->aResult := {}
HttpSession->lSen 	 := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUserCode		 := "MSALPHA"
oObj:cUserCardNumber := ""
oObj:cNumAut         := AllTrim(StrTran(StrTran(HttpGet->cNumGuia,".",""),"-",""))
oObj:cTipoAut        := "A"
oObj:cCampos         := "BEA_STATUS"
oObj:cTipo		     := HttpGet->cTp
HttpSession->cTp 	 := HttpGet->cTp
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o box de um determinado campo									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:GetBox()
	aCBox := oObj:OWSGETBOXRESULT:OWSGENERICSTRUCT
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa metodo para retorno das guia									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:RetAutLib()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Alimenta variaveis													   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se ainda nao existir crio														  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(HttpSession->aGrPart) == 'U'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Web Service															   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObjX := WSPLSXFUN():New()
		WsChgURL( @oObjX, "PLSXFUN.APW" )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Propriedade
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oObjX:cUserCode	:= "MSALPHA"
		oObjX:cTipo 	:= HttpGet->cTp
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executando Metodo																  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oObjX:GetDadG()
			HttpSession->aGrPart := oObjX:oWSGetDadGRESULT:oWSCbGraPar:oWSGenericStruct
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Descricao do Grau de participacao												  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nPos := aScan( HttpSession->aGrPart, { |x| x:cCODE == cGrPar} ) ) > 0
		cDesGRP := HttpSession->aGrPart[nPos]:CDESCRIPTION
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tipo de Guia															   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Consulta																			 ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   Case HttpSession->cTp == '1'
			HttpSession->cTpComprov	:= 'Consulta - Execução'
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Sadt																				 ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   Case HttpSession->cTp == '2'
			HttpSession->cTpComprov	:= 'Sadt - Solicitação'
	        If oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cOrigem == '1'
				HttpSession->cTpComprov	:= 'Sadt - Execução'
		    EndIf
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Internacao 																		 ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   Case HttpSession->cTp == '3'
			HttpSession->cTpComprov	:= 'Inter./Prorrog. - Solic./Exec.'
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Odontologico																		 ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   Case HttpSession->cTp == '4'
			HttpSession->cTpComprov	:= 'Odontológico - Solicitação'
	        If oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cOrigem == '1'
				HttpSession->cTpComprov	:= 'Odontológico - Execução'
		    EndIf
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Honorario Individual																 ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   Case HttpSession->cTp == '5'
			HttpSession->cTpComprov	:= 'Honorário Individual'
	EndCase
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Itens e criticas														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criticas																   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nY:=1 To Len(oObj:OWSRETAUTLIBRESULT:OWSSCRIGUI:oWSAUTERRORVIEW)
			If oObj:OWSRETAUTLIBRESULT:OWSSCRIGUI:oWSAUTERRORVIEW[nY]:cSequence == oObj:OWSRETAUTLIBRESULT:OWSSITEGUI:OWSMITEGUI[nI]:cSequencia
	            cCritica := "&nbsp;&nbsp;&nbsp;&nbsp;<samp class='TextoNegPeq'>"+oObj:OWSRETAUTLIBRESULT:OWSSCRIGUI:oWSAUTERRORVIEW[nY]:cCode+" - "+;
						  											  			 	 oObj:OWSRETAUTLIBRESULT:OWSSCRIGUI:oWSAUTERRORVIEW[nY]:cDescription+"</samp><br>"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta matriz para impressao de guia									  			  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    			AaDd(aCritica,cCritica )
			EndIf
		Next
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta matriz para impressao de guia									  			  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        AaDd( HttpSession->aResult,{cSequen,cCodTab,cCodPro,cDesPro,cDente,cFace,cQtdTot,aCritica,cQtdUs,cData,cSenhaAu,cSenPro,cDesGRP} )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se tem algum procedimento com senha									  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If !Empty(cSenPro)
			HttpSession->lSen := .T.
        EndIf
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Continua alimentando variaves para impressao							   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oObj:GetBox()
		HttpSession->cTitulo := aCBox[Ascan( aCBox, {|x| x:cCODE == cStatusGuia} )]:CDESCRIPTION
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Formulario de impressao de guia										   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HttpSession->cBVolt := "1"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna o valor da co-participacao									   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Mensagens															   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

	If ExistBlock("PPLMFUN1")
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSCHAAL  ³ Autor ³ Alexander Santos     ³ Data ³ 28.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina chama form de alteracao de senha						 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSCHAAL()
LOCAL cHtml	:= ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama o formulario													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml += ExecInPage( "PPLALTSEN" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSCHEPAS ³ Autor ³ Alexander Santos     ³ Data ³ 28.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera a senha do usuario									 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSCHEPAS()
LOCAL oObj
LOCAL cResult := "true|"
LOCAL lRet	  := .T.
Local nX      := 0
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSUSERPORTAL():NEW()
WsChgUrl(@oObj,"USERPORTAL.apw")

oObj:cUSERCODE := "MSALPHA"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a senha confere											   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(AllTrim( GetUsrSenha() ) == HttpGet->Field_SENHA)
  Return cResult := PLSDECODE("false|Senha não confere")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a nova senha Tem tamanho 8										   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Metodo																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:PRTPSWUSER( getUsrWeb() , AllTrim(GetUsrSenha()), HttpGet->Field_NEWSEN, HttpSession->cTipoPortal)
	If !SetUsrSenha( HttpGet->Field_NEWSEN )
		HttpFreeSession()
	Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz a validacao da senha e criptografa, faz a gravacao do campo data.   ³
//³Alterado por Ronaldo Dantas                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HttpGet->Field_NEWSEN := PLSCRIDEC(1,Alltrim(HttpGet->Field_NEWSEN))

	cResult := "true|Senha alterada com sucesso"
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
Endif

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSCHAHIS  ³ Autor ³ Alexander Santos     ³ Data ³ 28.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina chama form de Historico de utilizacao					 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSCHAHIS()

LOCAL cHtml	:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio Extended														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Direciona para pagina												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml += ExecInPage( "PPLHISUTI" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSPROHISU ³ Autor ³ Alexander Santos     ³ Data ³ 28.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina processar e chama form de Historico de utilizacao		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSPROHIS()
LOCAL oObj
LOCAL cResult := ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE				:= "MSALPHA"
oObj:oWSMViewPar:cCodLog	:= HttpPost->Field_CODUSU
oObj:oWSMViewPar:cDateDe   	:= HttpPost->Field_DTDE
oObj:oWSMViewPar:cDateAte  	:= HttpPost->Field_DTATE
oObj:oWSMViewPar:cHorDe    	:= HttpPost->Field_HRDE
oObj:oWSMViewPar:cHorAte   	:= HttpPost->Field_HRATE
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa metodo para retorno das guia									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:GetHistLogin()
   HttpSession->aMatHisUti := { oObj:OWSGETHISTLOGINRESULT:OWSSVIEWHISTLOG }
   cResult := "true|"
Else
   cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSCHFORHU  ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Abre o formulario com resultado da utilizacao do usuario		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSCHFORH()

LOCAL cHtml	:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio Extended														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Direciona para pagina												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml := ExecInPage( "PPLMOSHIUT" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim Extended														   	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLS673PA  ³ Autor ³ Alexander Santos     ³ Data ³ 28.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina chama formulario de parametros extrato rda			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLS673PA()
LOCAL cHtml	:= ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama o formulario													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml += ExecInPage( "PPLPAR673" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLEXE673   ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa o relatorio 673 extrato da rda						 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLEXE673()
LOCAL oObj
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria variavel de sessao												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(HttpPost->cRda) <> 'U'
	HttpSession->cRDARel := SubStr( HttpPost->cRda,1,At('|',HttpPost->cRda)-1 )
	HttpSession->cCodLoc := SubStr( HttpPost->cRda,At('|',HttpPost->cRda)+1 )
	HttpSession->cAnoRel := HttpPost->cAno
	HttpSession->cMesRel := HttpPost->cMes
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSRELT():New()
WsChgURL( @oObj, "PLSRELT.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE 			:= "MSALPHA"
oObj:oWSINPAR:cRDA 		:= HttpSession->cRdaRel
oObj:oWSINPAR:cCodLoc   := HttpSession->cCodLoc
oObj:oWSINPAR:cAno		:= HttpSession->cAnoRel
oObj:oWSINPAR:cMes 		:= HttpSession->cMesRel
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa metodo														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:REL673S()
	FT_FUse( oObj:cREL673SRESULT )
	FT_FGotop()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Todas as linhas														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HttpSession->aMatRel := {}
	While ( !FT_FEof() )
	    cRelato := FT_FREADLN()
	    If At("RPC",cRelato) == 0
			AaDd( HttpSession->aMatRel, StrTran(cRelato ," ","&nbsp;") + CRLF  )
		EndIf
		FT_FSkip()
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha o arquivo														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FT_FUse()
Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLS673PA.APW" )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->cRotRel := "W_PPLEXE673.APW"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama o formulario													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml += ExecInPage( "PPLMOSREL" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLS754PA  ³ Autor ³ Alexander Santos     ³ Data ³ 28.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Extrato de Utilizacoes										 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLS754PA()
LOCAL cHtml	:= ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama o formulario													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml += ExecInPage( "PPLPAR754" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLEXE754   ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa o relatorio 754 Extrato de Utilizacao				 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLEXE754()
LOCAL oObj	:= nil
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria variavel de sessao												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(HttpPost->cRda) <> 'U'
	HttpSession->cRDARel	:= SubStr( HttpPost->cRda,1,At('|',HttpPost->cRda)-1 )
	HttpSession->cCodLoc   	:= SubStr( HttpPost->cRda,At('|',HttpPost->cRda)+1 )
	HttpSession->cDtDe		:= HttpPost->cDtDe
	HttpSession->cDtAte  	:= HttpPost->cDtAte
	HttpSession->cGuia   	:= HttpPost->cGuia
	HttpSession->cTipo   	:= HttpPost->cTipo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSRELT():New()
WsChgURL( @oObj, "PLSRELT.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE 			:= "MSALPHA"
oObj:oWSINPAR:cRDA		:= HttpSession->cRDARel
oObj:oWSINPAR:cCodLoc   := HttpSession->cCodLoc
oObj:oWSINPAR:dDtDe		:= CToD(HttpSession->cDtDe)
oObj:oWSINPAR:dDtAte	:= CToD(HttpSession->cDtAte)
oObj:oWSINPAR:cGuia 	:= HttpSession->cGuia
oObj:oWSINPAR:cTipo 	:= HttpSession->cTipo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa metodo														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:REL754S()
	FT_FUse( oObj:cREL754SRESULT )
	FT_FGotop()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Todas as linhas														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HttpSession->aMatRel := {}
	While ( !FT_FEof() )
	    cRelato := FT_FREADLN()
	    If At("RPC",cRelato) == 0
			AaDd( HttpSession->aMatRel, StrTran(cRelato ," ","&nbsp;") + CRLF  )
		EndIf
		FT_FSkip()
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha o arquivo														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FT_FUse()
Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLS754PA.APW" )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->cRotRel := "W_PPLEXE754.APW"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama o formulario													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml += ExecInPage( "PPLMOSREL" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLS018PA  ³ Autor ³ Alexander Santos     ³ Data ³ 28.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina chama formulario de parametros Demostrativo de Pagamen ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLS018PA()
LOCAL cHtml	:= ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama o formulario													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(HttpGet->cR) != 'U'
	HttpSession->cTpRel := HttpGet->cR
EndIf
cHtml += ExecInPage( "PPLPAR018" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLEXE018   ³ Autor ³ Alexander Santos     ³ Data ³ 07.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa o relatorio Demos Pag, Demos Odon e Extrato Pag		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLEXE018()
LOCAL oObj
LOCAL cRelato	:= ""
LOCAL cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria variavel de sessao												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(HttpPost->cRda) <> 'U'
	HttpSession->cRDARel  := SubStr( HttpPost->cRda,1,At('|',HttpPost->cRda)-1 )
	HttpSession->cCodLRel := SubStr( HttpPost->cRda,At('|',HttpPost->cRda)+1 )
	HttpSession->cAnoRel  := HttpPost->cAno
	HttpSession->cMesRel  := HttpPost->cMes
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSRELT():New()
WsChgURL( @oObj, "PLSRELT.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE 			:= "MSALPHA"
oObj:oWSINPAR:cRDA 		:= HttpSession->cRDARel
oObj:oWSINPAR:cCodLoc	:= HttpSession->cCodLRel
oObj:oWSINPAR:cAno		:= HttpSession->cAnoRel
oObj:oWSINPAR:cMes 		:= HttpSession->cMesRel
oObj:oWSINPAR:cTp 		:= HttpSession->cTpRel
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa metodo														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:REL018S()
	FT_FUse( oObj:cREL018SRESULT )
	FT_FGotop()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Todas as linhas														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HttpSession->aMatRel := {}
	While ( !FT_FEof() )
	    cRelato := StrTran(FT_FREADLN(),'' ,'')
	    If At("RPC",cRelato) == 0
			AaDd( HttpSession->aMatRel, StrTran(cRelato ," ","&nbsp;") + CRLF  )
		EndIf
		FT_FSkip()
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha o arquivo														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FT_FUse()
Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLS018PA.APW" )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->cRotRel := "W_PPLEXE018.APW"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama o formulario													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml += ExecInPage( "PPLMOSREL" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLSSELO ³ Autor ³ Alexander Santos	   ³ Data ³ 09.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ajuda para como logar no portal							 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLSSELO ³ Autor ³ Alexander Santos	   ³ Data ³ 11.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ajuda para campo											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLSHEL1 ³ Autor ³ Daher				   ³ Data ³ 11.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ajuda para campo											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLSHEL2 ³ Autor ³ Daher				   ³ Data ³ 11.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ajuda para campo											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLESQSENH   ³ Autor ³ Alexander Santos	   ³ Data ³ 09.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Esqueceu a Senha	chamada para o informar o e-mail			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLESQSENH()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml

cHtml += ExecInPage("PPLESQSENH")

WEB EXTENDED END

Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLSEVSEN      ³ Autor ³ Alexander Santos	     ³ Data ³ 09.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao de dados e envia por e-mail						   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSEVSEN()
LOCAL oEmail
LOCAL oObj
LOCAL cSmtpEnv
LOCAL cUsuEmai
LOCAL cUsuPass
LOCAL lRet  	:= .T.
LOCAL cResult 	:= ""
LOCAL cHtml := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSCFGDICTIONARY():New()
WsChgURL( @oObj, "CFGDICTIONARY.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametro															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE	:= "MSALPHA"
oObj:cMVPARAM	:= "MV_RELSERV"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Metodo																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:GETPARAM()
	cSmtpEnv := oObj:cGETPARAMRESULT
	If Type(cSmtpEnv) == 'L'
		lRet 	:= .F.
		cResult := "false|Parametro MV_RELSERV não encontrado"
	Else
		If Empty(cSmtpEnv)
			lRet	:= .F.
			cResult := "false|Parametro MV_RELSERV sem conteudo"
		EndIf
	EndIf
Else
	lRet 	:= .F.
	cResult := "false|Parametro MV_RELSERV não encontrado"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega a conta do usuario para fazer o envio							   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	oObj:cMVPARAM	:= "MV_RELACNT"
	If oObj:GETPARAM()
		cUsuEmai := oObj:cGETPARAMRESULT
		If Type(cUsuEmai) == 'L'
		    lRet 	:= .F.
			cResult := "false|Parametro MV_RELACNT não encontrado"
	    Else
	   		If Empty(cUsuEmai)
				lRet 	:= .F.
				cResult := "false|Parametro MV_RELACNT sem conteudo"
			EndIf
		EndIf
	Else
		lRet 	:= .F.
		cResult := "false|Parametro MV_RELACNT não encontrado"
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega a senha do usuario para fazer o envio							   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	oObj:cMVPARAM	:= "MV_RELPSW"
	If oObj:GETPARAM()
		cUsuPass := oObj:cGETPARAMRESULT
		If Type(cUsuEmai) = 'L'
			lRet 	:= .F.
			cResult := "false|Parametro MV_RELPSW não encontrado"
	    Else
			If Empty(cUsuPass)
				lRet 	:= .F.
				cResult := "false|Parametro MV_RELPSW sem conteudo"
			EndIf
	    EndIf
	Else
		lRet 	:= .F.
		cResult := "false|Parametro MV_RELPSW não encontrado"
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se pode continuar													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obj																	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oEmail := WSPLSXFUN():New()
	WsChgURL(@oEmail,"PLSXFUN.APW")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametro															   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oEmail:cUSERCODE  := "MSALPHA"
	oEmail:cUserEmail := HttpPost->cEmail
	oEmail:cSmtpEnv	  := cSmtpEnv
	oEmail:cUsuEmai	  := cUsuEmai
	oEmail:cUsuPass	  := cUsuPass
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Metodo																   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oEmail:GetEmail()
	   cResult := "true|"+oEmail:cGETEMAILRESULT
	Else
	   cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da funcao														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLGUIMED    ³ Autor ³ Alexander Santos	   ³ Data ³ 09.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra formulario do guia medico								 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGUIMED()
LOCAL cHtml := ""
LOCAL nX	:= 1
LOCAL oObjxFun

WEB EXTENDED INIT cHtml 

oObj := WSPLSMCTMD():New()
WsChgURL( @oObj, "PLSMCTMD.APW" )

oObjxFun := WSPLSXFUN():New()
WsChgURL( @oObjxFun, "PLSXFUN.APW" )

oObj:cUSERCODE 	:= "MSALPHA"
oObj:cFunName	:= 'PLPEECB'
oObj:nTp		:= 1


If ValType(HttpSession->aEspecialidade) == 'U' 
	If oObj:getParGM()
		HttpSession->aEspecialidade := oObj:oWSGETPARGMRESULT:OWSGENERICSTRUCT
	Else
		HttpSession->aEspecialidade := {}
	EndIf
EndIf

if ValType(HttpSession->aProdutos) == 'U'
	oObjxFun:cUSERCODE	:= "MSALPHA"
	if oObjxFun:getProdutos()
		HttpSession->aProdutos := {}		
		for nX := 1 to len(oObjxFun:oWSGETPRODUTOSRESULT:oWSPRODUTOSLIST)
			aAdd( HttpSession->aProdutos, WsClassNew( "ProdutosGM" ) )  
			HttpSession->aProdutos[nX]:cCODE			:= AllTrim(oObjxFun:oWSGETPRODUTOSRESULT:oWSPRODUTOSLIST[nX]:cCodigo)
			HttpSession->aProdutos[nX]:cDESCRIPTION		:= AllTrim(oObjxFun:oWSGETPRODUTOSRESULT:oWSPRODUTOSLIST[nX]:cNome)
		next
	else
		HttpSession->aProdutos := {}
	endif
endif

cHtml += ExecInPage("PPLGUIMED")

WEB EXTENDED END

Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLCGUIMED     ³ Autor ³ Alexander Santos	     ³ Data ³ 09.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chama form do guia medico									   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCGUIMED()
LOCAL oObj		:= NIL
LOCAL cResult 	:= "true|"
LOCAL nI		:= 0
LOCAL aRet		:= {}
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ oBJ																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSMCTMD():New()
WsChgURL( @oObj, "PLSMCTMD.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE	:= "MSALPHA"
oObj:cFunName   := "PLPEECB"
oObj:nTp		:= Val(HttpGet->nTp)
oObj:cCodEsp	:= HttpGet->cCodEsp
oObj:cCodEst	:= HttpGet->cCodEst
oObj:cCodMun	:= HttpGet->cCodMun
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:getParGM()
	aRet := oObj:oWSGETPARGMRESULT:OWSGENERICSTRUCT
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Monta retono
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If Len(aRet) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Monta retorno para o combo
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	For nI:=1 To Len(aRet)
		cResult += aRet[nI]:cCode + "$" + aRet[nI]:cDescription + "|"
	Next
	cResult := Left(cResult,Len(cResult)-1)
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLMOSMAP    ³ Autor ³ Alexander Santos	   ³ Data ³ 09.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra mapa													 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLMOSMAP()
LOCAL cHtml := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Chamada do formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
WEB EXTENDED INIT cHtml

cHtml += ExecInPage("PPLMOSMAP")

WEB EXTENDED END

Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLTRAPRE    ³ Autor ³ Alexander Santos	   ³ Data ³ 02.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tratamento do pre-atendimento inclusao/alteracao e exclusao	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLTRAPRE()
LOCAL nI
LOCAL nPosRDA  := 0
LOCAL cResult  := "true|"
LOCAL cHtml := ""
Local lTimeAte	:= .F.
Local nTmpIni := Seconds()
Local lMatrAnt:= .T.

WEB EXTENDED INIT cHtml START "InSite"

oObjPar := WSCFGDICTIONARY():New()
WsChgURL( @oObjPar, "CFGDICTIONARY.APW" )

oObjPar:cUSERCODE	:= "MSALPHA"
oObjPar:cMVPARAM	:= "MV_PTIMATE" //Informa se é gestante na solicitação (1) ou na execução (2)
If oObjPar:GETPARAM()
	lTimeAte := oObjPar:cGETPARAMRESULT
	If ValType(lTimeAte) == 'U'
		lTimeAte := .F.
	ElseIf	ValType(lTimeAte) == 'C'
		If Type(lTimeAte)=="L"
			lTimeAte := &(lTimeAte)
		EndIf
	EndIf
EndIf

oObjPar:cUSERCODE	:= "MSALPHA"
oObjPar:cMVPARAM	:= "MV_PLMATAP" //Exibe a matricula antiga
If oObjPar:GETPARAM()
 
	lMatrAnt := oObjPar:cGETPARAMRESULT == "1"
	
	If lMatrAnt .And. Valtype(HttpSession->aVldCartao) == "A" .and. !Empty(HttpSession->aVldCartao[11]) ;
	.And. HttpGet->cTpAca <> "E" .And. ValType(HttpSession->aVldCartao[11]) == 'C' .AND. !Empty(HttpGet->cMatric)  
		HttpGet->cMatric:= AllTrim(HttpSession->aVldCartao[11])
	EndIf
EndIf

//Obj																	   ³
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//Registro no WS														   ³
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificacao															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(HttpGet->cRDA)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Rda																	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPosRDA := aScan( HttpSession->RDAVIEW, { |x| alltrim(x:cCODE) == alltrim(HttpGet->cRda) .And. alltrim(x:cCodLoc) == alltrim(HttpGet->cCodLoc)} )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros															   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPosRDA == 0
		nPosRDA := 1
	Endif

	oObj:oWSMatPre:cOpeRda	:= HttpSession->RDAVIEW[nPosRDA]:cCodOpe			//Operadora da rda
	oObj:oWSMatPre:cNomRda	:= HttpSession->RDAVIEW[nPosRDA]:cName	   			//Nome rda
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Metodo																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:PreAte()
	HttpSession->aMatPreAte := { oObj:oWSPREATERESULT:oWSSRETMATPRE }
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a string de resposta											   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(HttpSession->aVldCartao) == 'A'
		cResult += Iif(Empty(HttpSession->aVldCartao[11]),Transform(HttpSession->aVldCartao[2],'@R 9999.9999.999999.99-9'),Iif( Len(HttpSession->aVldCartao[11])>16,Transform(HttpSession->aVldCartao[11],'@R 9999.9999.999999.99-9'),Transform(HttpSession->aVldCartao[11],'@R 999.9999.999999.99-9') ) )+"@"+HttpSession->aVldCartao[1]+"~"
	Else
		cResult += "@~"
	EndIf
	For nI:=1 To Len(HttpSession->aMatPreAte[1])
	    cResult += 	HttpSession->aMatPreAte[1,nI]:cMsg+"$"+;
	    			Iif( Len(HttpSession->aMatPreAte[1,nI]:cMatric)>16,Transform( HttpSession->aMatPreAte[1,nI]:cMatric, "@R 9999.9999.999999.99-9" ),Transform( HttpSession->aMatPreAte[1,nI]:cMatric, "@R !999.9999.999999.99-9" ) )+"$"+;
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
If lTimeAte
    oObjPar:cMsgLog  := "2) " + Time()+ "|" + Alltrim(Str(Seconds() - nTmpIni)) + "|" + HttpGet->cRDA
    oObjPar:cFileLog := "PreAtendimento.txt"
    oObjPar:PutPLSLogFil()
EndIf

Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLSETLL     ³ Autor ³ Alexander Santos	   ³ Data ³ 29.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava latitudo e longitude									 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSETLL()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= "true|"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSMCTMD():New()
WsChgURL( @oObj, "PLSMCTMD.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUSERCODE	:= "MSALPHA"
oObj:cRecno		:= HttpGet->cRecno
oObj:cLatLon	:= HttpGet->cLatLon
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:setLatLon()

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLGETELL    ³ Autor ³ Alexander Santos	   ³ Data ³ 29.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o endereco fisico, latitude longitude e endereco show ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGETELL()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSMCTMD():New()
WsChgURL( @oObj, "PLSMCTMD.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cRecno		:= HttpGet->cRecno
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:getEndLL()
	cResult := oObj:cGETENDLLRESULT
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLCHACOM    ³ Autor ³ Alexander Santos	   ³ Data ³ 29.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chama form para mostrar a composicao de Solicitacao			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCHACOM()
LOCAL cHtml := ""
LOCAL oObj  := NIL

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE	:= "MSALPHA"
oObj:cCampos 	:= "BEA_TIPO"
oObj:cShowAnexo	:= "1"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o box de um determinado campo									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(HttpSession->aTpAut) == 'U'
	If oObj:GetBox()
		HttpSession->aTpAut := oObj:OWSGETBOXRESULT:OWSGENERICSTRUCT
	EndIf
EndIf

cHtml += ExecInPage("PPLMOSSOL")

WEB EXTENDED END

Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLCHAELE    ³ Autor ³ Alexander Santos	   ³ Data ³ 29.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chama form para mostrar a solicitacao de elegibilidade		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCHAELE()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para controle da exibicao das colunas da elegibilidade	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->aMatEleg := {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.F.}
If ExistBlock("PPLEXIELE")
	HttpSession->aMatEleg := ExecBlock("PPLEXIELE",.F.,.F.)
EndIf

cHtml += ExecInPage("PPLMOSELE")

WEB EXTENDED END

Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLCHADTIN   ³ Autor ³ Alexander Santos	   ³ Data ³ 06.03.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chama form para informar data de internacao					 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCHADTIN()

LOCAL cHtml := ""
LOCAL oObj  := NIL
Local cRetorno := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUSERCODE		:= "MSALPHA"
oObj:cChave 		:= "39"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta a dados especifico por tipo de guia						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:RetBTQChv()

cRetorno := oObj:cRETBTQCHVRESULT

HttpSession->aMotivoAlta := StrTokArr(cRetorno, "#")//oObj:cRETBTQCHVRESULT//"teste"//cRetorno//StrTokArr(cRetorno, "$")

cHtml += ExecInPage("PPLDATINT")

WEB EXTENDED END

Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLCHAHOIN   ³ Autor ³ Alexander Santos	   ³ Data ³ 06.03.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chama form para honorario									 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCHAHOIN()
LOCAL cHtml := ""
LOCAL oObj  := NIL
LOCAL cTISSVer	:= ""

LOCAL cResult  	:= ""
LOCAL aCmbWS		:= {}
LOCAL aCmbX		:= {}
LOCAL aCmbAux		:= {}
LOCAL cStrCBOX	:= ""
LOCAL nI,nY, nPos

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->cTp	:= '6'
HttpSession->cBVolt := "1"

oObj:cUSERCODE		:= "MSALPHA"
oObj:cTipo 			:= HttpSession->cTp
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta a dados especifico por tipo de guia						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:GetDadG()
	HttpSession->aGrPart := oObj:oWSGetDadGRESULT:oWSCbGraPar:oWSGenericStruct
Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLCHAHOIN.APW" )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta as variaves com o x3-combobox								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:getCombo()
	HttpSession->cCodPad    := oObj:oWSGETCOMBORESULT:cCodPad
	HttpSession->aViaAce	:= oObj:oWSGETCOMBORESULT:oWSCBViaAce:oWSGenericStruct
	HttpSession->aTecUti	:= oObj:oWSGETCOMBORESULT:oWSCBTecUti:oWSGenericStruct
Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLCHAHOIN.APW" )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Passa a primeira rda do usuario logado								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CRIAR PAGINA PARA TISS 3.0													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTissVer >= "3"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ oBJ
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oObj := WSPLSXFUN():New()
	WsChgURL( @oObj, "PLSXFUN.APW" )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Parametros
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oObj:cUserCode	:= "MSALPHA"
	oObj:oWSGUIATISS:cTipGui		:= "06" // Guia de Honorarios
	oObj:oWSGUIATISS:cVerTiss	:= cTISSVer
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Aqui eu pego o que vem de Session executo aqui pra enviar a informaçao
	// pro WS pois o mesmo nao acessa o conteudo da Session	dificultando o dinamismo
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Retorna dados da pagina
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ FIM CRIAR PAGINA PARA TISS 3.0													   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndIf

If cTissVer >= "3"
	cHtml += ExecInPage("PPLSGUIAS")
	//cHtml += ExecInPage("PPLSHOIN")
	//cHtml += ExecInPage("PPLSHOIF")
Else
	cHtml += ExecInPage("PPLSHOIN")
EndIf

WEB EXTENDED END

Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLEXEALT    ³ Autor ³ Roberto Vanderlei	   ³ Data ³ 06.03.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Informa a data de alta do paciente						     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLEXEALT()
LOCAL cResult	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro no WS														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE 	:= "MSALPHA"
oObj:cNumAut	:= AllTrim( StrTran(StrTran(HttpGet->cNumGui,".",""),"-","") )
oObj:dDatAlt	:= CToD(HttpGet->dDatAlt)
oObj:cHorAlt	:= StrTran(HttpGet->cHorAlt,":","")
oObj:cMotAlt	:= alltrim(HttpGet->cMotAlt)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Metodo																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:ExeDHAlt()
	cResult := oObj:cExeDHAltRESULT
Else
    cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cResult
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLEXEINT    ³ Autor ³ Alexander Santos	   ³ Data ³ 06.03.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Informa a data de internacao do paciente						 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLEXEINT()
LOCAL cResult	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro no WS														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE 	:= "MSALPHA"
oObj:cNumAut	:= AllTrim( StrTran(StrTran(HttpGet->cNumGui,".",""),"-","") )
oObj:dDatInt	:= CToD(HttpGet->dDatInt)
oObj:cHorInt	:= StrTran(HttpGet->cHorInt,":","")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Metodo																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:ExeDHInt()
	cResult := oObj:cExeDHIntRESULT
Else
    cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cResult
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLSTAGUI    ³ Autor ³ Alexander Santos	   ³ Data ³ 02.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra dados da Guia										     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSTAGUI()
LOCAL nI,nY      := 0
LOCAL aMatComGui := {}
LOCAL cCritica	 := ""
LOCAL lbCancel	 := "true"
LOCAL cResult  	 := "true|"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro no WS														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE 	:= "MSALPHA"
oObj:cNumAut	:= AllTrim( StrTran(StrTran(HttpGet->cNumGui,".",""),"-","") )
oObj:cTipoAut	:= HttpGet->cTipoAut
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Metodo																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:StatusGuia()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorno																   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aMatComGui := oObj:OWSSTATUSGUIARESULT:OWSSMATCOMPGUI
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Matriz de Retorno													   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI:=1 To Len(aMatComGui)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nome do usuario e Data da Solicitacao								   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Itens																   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    cResult += 	aMatComGui[nI]:cCodTab+"$"+; //Tabela
		   			aMatComGui[nI]:cCodPro+"$"+; //Procedimento
		   			aMatComGui[nI]:cDesPro+"$"+; //Nome do Procedimento
		   			aMatComGui[nI]:cQtdSol+"$"+; //Qtd Solcitacao
		   			aMatComGui[nI]:cQtdRea+"$"+; //Qtd Realizada
		   			aMatComGui[nI]:cQtdSal+"$"+; //Qtd Saldo
		   			aMatComGui[nI]:cStaAud+"$"+; //Status Auditoria
		   			aMatComGui[nI]:cStaPro+"^"	  //Status Procedimento
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Criticas															   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLCANGUI    ³ Autor ³ Alexander Santos	   ³ Data ³ 02.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cancela Guia													 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCANGUI()
LOCAL cResult	:= ""
LOCAL lDigiOff	:= .F.
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lDigiOff := IIF(Valtype(HttpGet->cDigiGuia) <> "U" .AND. HttpGet->cDigiGuia == "1" , lDigiOff := .T., lDigiOff := .F.) //Verifico se é da Digitação Off-Line

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro no WS														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE  := "MSALPHA"
oObj:cNumAut	:= AllTrim( StrTran(StrTran(HttpGet->cNumGui,".",""),"-","") ) //Se Digitação Off-Line, passo o RECNO da BD5.
oObj:cMotivo	:= IIF (!lDigiOff, AllTrim( HttpGet->cMotivo ), "RECOFF") //Será utilizado como comparador na hora da pesqusia do alias para deletar
oObj:cTipo		:= IIF (!lDigiOff, "", HttpGet->cTipo)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Metodo																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:CancelaGuia()
	cResult := oObj:cCANCELAGUIARESULT
Else
    cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLPROELE    ³ Autor ³ Alexander Santos	   ³ Data ³ 02.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra dados Elegibilidade do Beneficiario					 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLPROELE()
LOCAL nI	  := 0
LOCAL cResult := "true|"
LOCAL lPPLEXIS :=ExistBlock("PPLEXSTAT")
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro no WS									  					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->aResult := {}
oObj:cUSERCODE 		 := "MSALPHA"
oObj:cUserCardNumber := AllTrim(HttpGet->cMatric) //AllTrim( StrTran(StrTran(HttpGet->cMatric,".",""),"-","") )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Metodo																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
				Substr(Dtos(oObj:OWSELEGIBILIDADERESULT:DDATBLO),1,4)
				If lPPLEXIS
					cResult += +"|"+(oObj:OWSELEGIBILIDADERESULT:CSTATUSEL)+"|$"
				Else
					cResult += +"|$"
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Criticas															   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nI := 1 To Len(oObj:OWSELEGIBILIDADERESULT:OWSUSERCRITICA:OWSUSERCARDCRI)
				    If !Empty(oObj:OWSELEGIBILIDADERESULT:OWSUSERCRITICA:OWSUSERCARDCRI[nI]:CDESPRI)
						cResult += AllTrim(oObj:OWSELEGIBILIDADERESULT:OWSUSERCRITICA:OWSUSERCARDCRI[nI]:CDESPRI)+" - "+AllTrim(oObj:OWSELEGIBILIDADERESULT:OWSUSERCRITICA:OWSUSERCARDCRI[nI]:CDESSEQ)+chr(10)+chr(13)
					EndIf
				Next
Else
    cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina									 					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ PPLTROMAT³ Autor ³ Alexander Santos	     ³ Data ³ 2.05.07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Procura matricula antiga caso seja usuario de intercambio  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PPLTROMAT(cMatric)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se e usuario de intercambio									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cMatAnt := cMatric // para fazer o seek com o matant, pois pode ter traços e pontos
cMatric := AllTrim(StrTran(StrTran(cMatric,".",""),"-",""))
BA1->( DbSetOrder(2) ) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
If !BA1->( MsSeek( xFilial("BA1")+cMatric ) )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procura matricula antiga												   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BA1->( DbSetOrder(5) ) //BA1_FILIAL + BA1_MATANT + BA1_TIPANT
	If BA1->( MsSeek( xFilial("BA1")+cMatAnt ) )
   	   cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
   	ElseIf BA1->( MsSeek( xFilial("BA1")+Right(cMatric,16) ) )
   	   cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
   	Else
   	   cMatric := ""
    EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³fim da funcao														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cMatric
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³PLSDECODE ³ Autor ³ Alexander Santos	     ³ Data ³ 05.06.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Codifica caracteres especiais acentuacao				   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSDECODE(cString)
Return( WCDecode(cString) )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLCHADOW    ³ Autor ³ Alexander Santos	   ³ Data ³ 05.03.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chama form para download										 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLCHAMANU  ³ Autor ³ Flavio S. Correa     ³ Data ³ 17.06.2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do menu Manuais										 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WEB FUNCTION PPLCHAMANU()
LOCAL cHtml  	:= ""
LOCAL cDir	 	:= getWebDir()
LOCAL aFiles	:= {}

WEB EXTENDED INIT cHtml START "InSite"

If !Empty(cDir)

	cDir := cDir + getPrtSkin() + "\manuaistiss\"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Le diretorio para mostrar os arquivos disponiveis
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLCHADUVI  ³ Autor ³ Flavio S. Correa     ³ Data ³ 16.06.2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do menu Duvidas/Esclarecimentos						 ³±±
±±³----------³---------------------------------------------------------------³±±
±±³Alteracao ³ Luciano Aparecido  | restruturado para o padrao				 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WEB FUNCTION PPLCHADUVI()
LOCAL cHtml  	:= ""
LOCAL oObjLib 	:= Nil
LOCAL cIntPad   := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimenta a intpad													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjLib := WSPLSXFUN():New()
WsChgURL( @oObjLib, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa o metodo												  	       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjLib :PlsIntPad()
cIntPad := oObjLib:cPLSINTPADRESULT
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca contatos na tabela BIM
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObjLib:getContato("MSALPHA",cIntPad)

	HttpPost->oContatos := oObjLib:oWSGETCONTATORESULT:oWSCONTATOSTISS

	cHtml += ExecInPage("PPLSDUVIDA")

Else
	Return PPLSALERT( "", "Atenção", "Nao Existe nenhum Contato TISS cadastrado", "" )
EndIf

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLCHAORIE  ³ Autor ³ Flavio S. Correa     ³ Data ³ 17.06.2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do menu Orientacoes TISS								 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLCHAPROD  ³ Autor ³ Totvs			     ³ Data ³ 18.06.2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do menu Produtos										 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WEB FUNCTION PPLCHPROD()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³WS
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUSERCODE	:= "MSALPHA"

If oObj:getProdutos()
	HttpSession->aProdutos := oObj:oWSGETPRODUTOSRESULT:oWSPRODUTOSLIST
EndIf

	cHtml += ExecInPage("PPLSPRODUT")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLCHAEXML  ³ Autor ³ Flavio S. Correa     ³ Data ³ 22.06.2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do menu Envio XML									 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WEB FUNCTION PPLCHAEXML()
LOCAL cHtml  	:= ""
LOCAL oObjLib	:= Nil

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimenta a intpad													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjLib := WSPLSXFUN():New()
WsChgURL( @oObjLib, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa o metodo												  	       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjLib :PlsIntPad()
HttpSession->cIntPad := oObjLib:cPLSINTPADRESULT
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca Links na tabela B0F											   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObjLib:GetLinks("MSALPHA",HttpSession->cIntPad,"2")

	HttpPost->oLinks := oObjLib:oWSGETLINKSRESULT:oWSLINKSLIST

	cHtml += ExecInPage("PPLSENVXML")

Else
	Return PPLSALERT( "", "Atenção", "Nenhum Link encontrado para Download/Upload", "" )
EndIf

WEB EXTENDED END

Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLCHAWBSE  ³ Autor ³ Flavio S. Correa     ³ Data ³ 22.06.2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do menu Webservice									 ³±±
±±³----------³---------------------------------------------------------------³±±
±±³Alteracao ³ Luciano Aparecido  | restruturado para o padrao				 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WEB FUNCTION PPLCHAWBSE()
LOCAL cHtml  	:= ""
LOCAL oObjLib	:= Nil

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimenta a intpad													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjLib := WSPLSXFUN():New()
WsChgURL( @oObjLib, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa o metodo												  	       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjLib :PlsIntPad()
HttpSession->cIntPad := oObjLib:cPLSINTPADRESULT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca Links na tabela B0F
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObjLib:getLinks("MSALPHA",HttpSession->cIntPad,"1")

	HttpPost->oLinks := oObjLib:oWSGETLINKSRESULT:oWSLINKSLIST

	cHtml += ExecInPage("PPLSWEBSER")

Else
	Return PPLSALERT( "", "Atenção", "Nenhuma WebService encontrada", "" )
EndIf

WEB EXTENDED END

Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSMONESP ³ Autor ³ Patricia Duca Aguiar   Data ³ 13.11.2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta matriz de todos os conselho bah						 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSMONESP()
LOCAL nI
LOCAL oObj
LOCAL cResult  	:= "true|"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ oBJ																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSMCTMD():New()
WsChgURL( @oObj, "PLSMCTMD.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE 			:= "MSALPHA"
oObj:OWSESPEC:cRda  	:= HttpGet->cRda
oObj:OWSESPEC:cCodLoc  	:= HttpGet->cCodLoc
oObj:OWSESPEC:cTp  		:= HttpGet->cTp
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa metodo para pegar os conselhos								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:getSigEsp()
	For nI:=1 To Len(oObj:oWSGETSIGESPRESULT:oWSGenericStruct)
		cResult +=	oObj:oWSGETSIGESPRESULT:oWSGenericStruct[nI]:cCode+"$"+;
					oObj:oWSGETSIGESPRESULT:oWSGenericStruct[nI]:cDescription+"|"
	Next
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLCHAIMP   ³ Autor ³ Totvs                ³ Data ³ 20.02.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do processamento de arquivo xml						 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCHAIMP()
LOCAL cHtml := ""
LOCAL nI    := 0
LOCAL oObj 	:= NIL
LOCAL oObjLib := NIL
LOCAL nLen		:= IIf(Valtype(HttpSession->RDAVIEW) == "A", Len(HttpSession->RDAVIEW), 0 )
PRIVATE cInterPag := ""
PRIVATE cValParam := "1"

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o parametro													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSCFGDICTIONARY():New()
WsChgURL( @oObj, "CFGDICTIONARY.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro no WS														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE	:= "MSALPHA"
oObj:cMVPARAM	:= "MV_PLCALPG"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pegar a codigo de consulta definido no parametro 					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:GETPARAM()
	cValParam := IiF( Empty(oObj:cGETPARAMRESULT),"1",alltrim(oObj:cGETPARAMRESULT))
Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLCHAIMP.APW" )
EndIf

If cValParam == "2"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Alimenta a intpad
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObjLib := WSPLSXFUN():New()
	WsChgURL( @oObjLib, "PLSXFUN.APW" )
	oObjLib:cUSERCODE	:= "MSALPHA"
	oObjLib:cRDACode := ""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ RDA(s)														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   	//³Busca Calendario de Pagamento
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oObjLib:getCalend()
		cInterPag := oObjLib:cGETCALENDRESULT
	Else
		Return PPLSALERT( "", "Atenção", "", "W_PPLCHAIMP.APW" )
	EndIf
EndIf

cHtml += ExecInPage("PPLCHAIMP")


WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

//-------------------------------------------------------------------
/*/{Protheus.doc} PPLCHAMNC
Estatistica de parto

@author  PLS TEAM
@version P11
@since   15.10.15
/*/
//-------------------------------------------------------------------
Web Function PPLCHAMNC()
LOCAL cHtml := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe pagina															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama o formulario													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml += ExecInPage("PPLCHAMNC")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLRELMOV   ³ Autor ³ Totvs                ³ Data ³ 20.02.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do processamento de arquivo xml						 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLRELMOV()
LOCAL cHtml 		:= ""
PRIVATE cMVQTDIARQ	:= "0"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe pagina															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WEB EXTENDED INIT cHtml START "InSite"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o parametro que indica se os arquivos ficarão disponiveis para download e quantos dias  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSCFGDICTIONARY():New()
WsChgURL( @oObj, "CFGDICTIONARY.APW" )

oObj:cUSERCODE	:= "MSALPHA"
oObj:cMVPARAM	:= "MV_QTDIARQ"

If oObj:GETPARAM()
	cMVQTDIARQ := Iif(oObj:cGETPARAMRESULT == '.F.','0',oObj:cGETPARAMRESULT)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama o formulario													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml += ExecInPage("PPLRELMOV")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLMOSIMP   ³ Autor ³ Totvs                ³ Data ³ 20.02.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra lista de arquivos XML	para importacao					 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLMOSIMP()
LOCAL cHtml := "true|"
LOCAL oObj 	:= NIL

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a variavel ja esta definida								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If type('HttpSession->RDAVIEW') == 'U' .and. type('HttpSession->USR_INFO') <> 'U'
	HttpSession->RDAVIEW := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFRDA:OWSRDAVIEW //Prestador

Endif
If ValType(HttpGet->cPagina) != 'U'
	HttpSession->nPagUp := Val(HttpGet->cPagina)
Else
	HttpSession->nPagUp  := 1
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o parametro													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSCFGDICTIONARY():New()
WsChgURL( @oObj, "CFGDICTIONARY.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro no WS														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE	:= "MSALPHA"
oObj:cMVPARAM	:= "MV_LOGSCHE"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pegar a codigo de consulta definido no parametro 					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:GETPARAM()
	HttpSession->MV_LOGSCHE := Iif(oObj:cGETPARAMRESULT == '.F.','1',oObj:cGETPARAMRESULT)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa o metodo												  	       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:PlsIntPad()
HttpSession->cIntPad := oObj:cPLSINTPADRESULT
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quantidade de registros por pagina									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUserCode		:= "MSALPHA"
oObj:nPaginaIni 	:= HttpSession->nPagUp
oObj:nRegPagina 	:= 10
oObj:cRDACode 		:= HttpGet->cRda
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe lista de arquivos 												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->aFileList 	:= {}
HttpSession->nTPagUp 	:= 1

If oObj:getFList()
	HttpSession->aFileList := oObj:oWSGetFListRESULT:oWSARQUIVOSLIST
	HttpSession->nTPagUp   := HttpSession->aFileList[1]:nQtdPag
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe pagina															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(HttpSession->cRetChImp) == 'U' // foi necessário guardar o resultado porque a pagina faz duas requisições seguidas perdendo o valor do metodo
	cHtml := "true| |"
Else
	cHtml := "true|" + HttpSession->cRetChImp + "|"
EndIf

HttpSetPart(.F.)

cHtml += ExecInPage("PPLMOSIMP")

HttpSetPart(.T.)

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cHtml)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLPROARQ    ³ Autor ³ Totvs				   ³ Data ³ 20.02.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa arquivo (importacao xml)							 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLPROARQ()
LOCAL cResult := "true|"
LOCAL cDirArq := ""
LOCAL lProc	  := .F.
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Val(HttpGet->cLinArray) > 0 .And. Len(HttpSession->aFileList) > 0 .And. Len(HttpSession->aFileList) >= Val(HttpGet->cLinArray)
	cDirArq := HttpSession->aFileList[Val(HttpGet->cLinArray)]:cArquivoIN
	lProc   := HttpSession->aFileList[Val(HttpGet->cLinArray)]:cStatus == '0'
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro no WS									  					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUserCode 		:= "MSALPHA"
oObj:cUserPlsName 	:= getNameUsr()
oObj:cDirArqIn 		:= cDirArq
oObj:cRDACode 		:= Httpget->cRda
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Metodo																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina									 					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLIAARQ     ³ Autor ³ Totvs				   ³ Data ³ 20.02.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inclui ou altera arquivo XML									 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLIAARQ()
LOCAL cResult := ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

If ValType(HttpPost->cRda) == 'U'
	HttpPost->cRda := ""
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro no WS									  					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUserCode 		:= "MSALPHA"
oObj:cUserPlsName 	:= getNameUsr()
oObj:cDirArqIn 		:= strtran(HttpPost->cDirArq,'/\','\')
oObj:cRDACode 		:= substr(HttpPost->cRda,1,6)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Metodo																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:IncXmlUp()
	cResult := oObj:cINCXMLUPRESULT
Else
	cResult := StrTran(PWSGetWSError( "" ),":","")
EndIf
HttpSession->cRetChImp := cResult

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina									 					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLATUPRO  ³ Autor ³ Alexander Santos     ³ Data ³ 11.01.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna informação do prof com base na pesquisa				 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLATUPRO()
LOCAL cResult 	:=  "true|"
LOCAL nI		:= 0
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ obj
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUSERCODE	:= "MSALPHA"
oObj:cRdaCode	:= HttpGet->cRda
oObj:cCodLoc	:= HttpGet->cCodLoc
oObj:cBusca		:= HttpGet->cBusca
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Lista de profissional de saude
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:ProfSaud()
	HttpSession->PROSAUD := oObj:oWSPROFSAUDRESULT:OWSLISTPROFSAUD:oWSPROFSAUD
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Monta retorno para o combo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
For nI:=1 To Len(HttpSession->PROSAUD)
	cResult += HttpSession->PROSAUD[nI]:cCODE + "%" + AllTrim(HttpSession->PROSAUD[nI]:cNAME) + "|"
Next

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSMONSOL ³ Autor ³ Totvs 				 | Data ³ 24.01.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta box de Solicitantes									 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSMONALL()
LOCAL nI		:= 0
LOCAL cResult  	:= "true|"
LOCAL oObj		:= NIL
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUSERCODE:= "MSALPHA"
oObj:cBusca  := HttpGet->cBusca
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lista de profissional de saude										   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSMONSOL ³ Autor ³ Totvs 				 | Data ³ 24.01.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta box de Solicitantes									 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSMONSOL()
LOCAL nI		:= 0
LOCAL cResult  	:= "true|"
LOCAL oObj		:= NIL
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUSERCODE:= "MSALPHA"
oObj:cRdaCode := HttpGet->cRda
oObj:cCodLoc  := HttpGet->cCodLoc
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lista de profissional de saude										   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCHACPR  ³ Autor ³ Alexander Santos     ³ Data ³ 26.01.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama o formulario de perda e roubo							 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCHACPR()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Obj
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametro
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUSERCODE 	:= "MSALPHA"
oObj:nTp		:= 3
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ ComboBox da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If ValType(HttpSession->aMotCar) == 'U'
	If oObj:getCombo()
		HttpSession->aMotCar := oObj:oWSGETCOMBORESULT:oWSCbMotCar:oWSGenericStruct
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLCHACPR")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCHABOL  ³ Autor ³ Alexander Santos     ³ Data ³ 26.01.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama o formulario de boleto									 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCHABOL()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Contratos
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If ValType(HttpSession->aContrato) == 'U'
	HttpSession->aContrato := PLRETOECS(HttpSession->OPEVIEW,'C')
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLCHABOL")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCHAMIR  ³ Autor ³ Alexander Santos     ³ Data ³ 26.01.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama o formulario de IR										 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCHAMIR()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLCHAMIR")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCHASIN  ³ Autor ³ Alexander Santos     ³ Data ³ 26.01.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama o formulario de Sinistralidade							 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCHASIN()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLCHASIN")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCHAUTL  ³ Autor ³ Alexander Santos     ³ Data ³ 26.01.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama o formulario de extrato de utilizacao					 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
web function PPLCHAUTL()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLCHAUTL")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCHDPM   ³ Autor ³ Totvs                ³ Data ³ 15.01.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama o formulario demonstrativo de pagamento medico			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
web function PPLCHDPM()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLCHDPM")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCHEPM   ³ Autor ³ Totvs                ³ Data ³ 15.01.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama o formulario extrato de pagamento medico    			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
web function PPLCHEPM()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLCHEPM")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCHDAC   ³ Autor ³ Totvs                ³ Data ³ 15.01.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama o formulario demonstrativo de analise conta medica		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
web function PPLCHDAC()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLCHDAC")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCHDPO	  ³ Autor ³ Totvs                ³ Data ³ 15.01.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama o formulario demonstrativo de pagamento odontologico	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
web function PPLCHDPO()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLCHDPO")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCHAPTC  ³ Autor ³ Alexander Santos     ³ Data ³ 26.12.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama o formulario de geracao de protocolo					 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCHAPTC()
LOCAL cHtml := ""
local nI
LOCAL oObjPar 	:= NIL
LOCAL oObjLib := NIL
LOCAL nLen		:= IIf(Valtype(HttpSession->RDAVIEW) == "A", Len(HttpSession->RDAVIEW), 0 )

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Parametro
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if valType(HttpSession->lMosGui) == 'U'

	httpSession->lMosGui := .t.

	oObj := WSCFGDICTIONARY():new()
	wsChgURL( @oObj, "CFGDICTIONARY.APW" )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ parametro para verificar se exibe as guias ou nao
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oObj:cUSERCODE:= "MSALPHA"
	oObj:cMVPARAM := "MV_PLSEGU"
	if oObj:GETPARAM()
		httpSession->lMosGui := iIf( allTrim(oObj:cGETPARAMRESULT)=="1",.t.,.f. )
	endIf
endIf

//Pego local de Digitação off-line
oObj := WSCFGDICTIONARY():new()
wsChgURL( @oObj, "CFGDICTIONARY.APW" ) 
oObj:cUSERCODE:= "MSALPHA"
oObj:cMVPARAM	:= "MV_PLSDIGP"
If oObj:GETPARAM()
	httpSession->cCodOff := oObj:cGETPARAMRESULT
ENDIF

oObjPar := WSCFGDICTIONARY():New()
WsChgURL( @oObjPar, "CFGDICTIONARY.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro no WS														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjPar:cUSERCODE	:= "MSALPHA"
oObjPar:cMVPARAM	:= "MV_PLCALPG"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pegar a codigo de consulta definido no parametro 					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObjPar:GETPARAM()
	cValParam := IiF( Empty(oObjPar:cGETPARAMRESULT),"1",alltrim(oObjPar:cGETPARAMRESULT))
Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLDIGGUIP.APW" )
EndIf

oObjLib := WSPLSXFUN():New()
WsChgURL( @oObjLib, "PLSXFUN.APW" )
oObjLib:cUSERCODE	:= "MSALPHA"
oObjLib:cRDACode := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ RDA(s)														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca Calendario de Pagamento
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObjLib:getCalend()
	cInterPag := oObjLib:cGETCALENDRESULT
Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLCHAIMP.APW" )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Obj
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametro
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUSERCODE 	:= "MSALPHA"
oObj:nTp		:= 1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ ComboBox da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if oObj:getCombo()
	httpSession->aTipGui := oObj:oWSGETCOMBORESULT:oWSCbTipGui:oWSGenericStruct
else
	return PPLSALERT( "", "Atenção", "", "W_PPLCHAPTC.APW" )
endIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLCHAPTC")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PPLRELGEN ºAutor  ³Totvs				  º Data ³  16.03.2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorios 											   	   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PPLRELGEN()
LOCAL oObj	:= NIL
LOCAL cHtml := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Web Function
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³WS
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSRELT():New()
WsChgURL( @oObj, "PLSRELT.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode 	:= "MSALPHA"
oObj:cFunName  	:= HttpGet->cFunName
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Parametros conforme rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Boleto
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Case HttpGet->cFunName == 'PPRELBOL'
		oObj:oWSINPAR:nRecno := Val( StrTran( strTran(HttpGet->cRecno, ".", ""), ",", ""))
		oObj:oWSINPAR:cAlias := 'SE1'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Extrato de utilizacao
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Case HttpGet->cFunName == 'PPRELULT'
		oObj:oWSINPAR:cMatric	:= HttpGet->Field_MATUSU
		oObj:oWSINPAR:dDtDe		:= CToD(HttpGet->Field_DTDE)
		oObj:oWSINPAR:dDtAte	:= CToD(HttpGet->Field_DTATE)
	//Carteirinha beneficiario
	Case HttpGet->cFunName == 'PPLSRECB'
		oObj:oWSINPAR:cMatric := HttpGet->Field_MATUSU
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Demonstrativo de I.R
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Case HttpGet->cFunName == 'PPRELIR'
		oObj:oWSINPAR:cMatric	:= HttpGet->Field_MATUSU
		oObj:oWSINPAR:cCodEmp	:= HttpGet->Field_CODEMP
		oObj:oWSINPAR:cAno		:= HttpGet->Field_ANO
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Sinistralidade
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Case HttpGet->cFunName == 'PPRELSIN'
		oObj:oWSINPAR:cMatric	:= HttpGet->Field_MATUSU
		oObj:oWSINPAR:cAno		:= HttpGet->Field_ANO
		oObj:oWSINPAR:cMes		:= HttpGet->Field_MES
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Movimentacao
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Case HttpGet->cFunName == 'PPRELBEN'
		oObj:oWSINPAR:cNumCon	:= HttpGet->Field_NUMCON
		oObj:oWSINPAR:cSubCon	:= HttpGet->Field_SUBCON
		oObj:oWSINPAR:dDtDe		:= CToD(HttpGet->Field_DTDE)
		oObj:oWSINPAR:dDtAte	:= CToD(HttpGet->Field_DTATE)
		oObj:oWSINPAR:cSituac	:= HttpGet->Field_SITCAD
		oObj:oWSINPAR:cTipo		:= HttpGet->Field_TIPO
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³XML
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Case HttpGet->cFunName == 'PPRELXML'
		oObj:oWSINPAR:cXmlFile	:= HttpGet->Field_FName
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Guia SADT PDF
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Case HttpGet->cFunName == 'PPRELST'
		oObj:oWSINPAR:cNumAut := HttpGet->Field_NUMAUT
		oObj:oWSINPAR:cProrrog := HttpGet->lProrrog

		If !PPLVGUTIS() 	// Verifica se imprime Guia Tiss padrão ANS.
	   		If HttpGet->cReimpr == "1"
				W_PPLSMATREI() 	// Imprime Guia Antiga
			Else
		   		W_PPLIMPGUIA()
       		EndIf
			Return cHtml
		EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Guia Recurso de GLOSA PDF
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Case HttpGet->cFunName == 'PPRELRG'
		oObj:oWSINPAR:nRecno := val(HttpGet->cRecno)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Relatorio de Solicitacao de Cancelamento de Planos
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Case HttpGet->cFunName == 'PP99BSOL'	
		oObj:oWSINPAR:nRecno := val(HttpGet->cRecno)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Relatorio de Confirmacao de Cancelamento de Plano
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Case HttpGet->cFunName == 'PP99BCON'	
		oObj:oWSINPAR:nRecno := val(HttpGet->cRecno)
		
	Case HttpGet->cFunName == 'PPRELUPD'
		oObj:oWSINPAR:cRda := HttpGet->Field_RDA
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³PEG - protoolo eletronico de guias
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Demonstrativo de pagamento medico
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Reembolso Analítico
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Case HttpGet->cFunName == 'PPRELRBANL'
		oObj:oWSINPAR:cMatric	:= HttpGet->Field_MATUSU
		oObj:oWSINPAR:dDtDe		:= CToD(HttpGet->Field_DTDE)
		oObj:oWSINPAR:dDtAte	:= CToD(HttpGet->Field_DTATE)
		oObj:oWSINPAR:dDtDeO	:= CToD(HttpGet->Field_DTDEP)
		oObj:oWSINPAR:dDtAteO	:= CToD(HttpGet->Field_DTATEP)
		oObj:oWSINPAR:cChaveGen	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CCODE
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Extrato de Reajuste
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Case HttpGet->cFunName == 'R510WEB'
		oObj:oWSINPAR:cMatric	:= HttpGet->Field_MATUSU
		oObj:oWSINPAR:dDtDe		:= cToD('01/01/' + HttpGet->Field_ANO)
		oObj:oWSINPAR:dDtAte	:= cToD('31/12/' + HttpGet->Field_ANO)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Extrato de utilização Beneficiário - Co-participação
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	Case HttpGet->cFunName == 'PPRELEXTUTI'
		oObj:oWSINPAR:cMatric	:= HttpGet->Field_MATUSU
		oObj:oWSINPAR:cMes		:= HttpGet->Field_DTDESCI //irá receber mes e ano inicial desconto
		oObj:oWSINPAR:cAno		:= HttpGet->Field_DTDESCF  // irá receber mes e ano final desconto
		oObj:oWSINPAR:dDtDe		:= CToD(HttpGet->Field_DTDEP)
		oObj:oWSINPAR:dDtAte	:= CToD(HttpGet->Field_DTATEP)
		oObj:oWSINPAR:cChaveGen	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CCODE
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Extrato Financeiro
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Executa metodo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
HttpSession->cFileName := ""

If oObj:getRelGEN() //Nessa chamada o array ja esta vazio
	HttpSession->cFileName := oObj:cGETRELGENRESULT
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Exibe boleto
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLRELGEN")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLGETCID  ³ Autor ³ Totvs				 ³ Data ³ 11.01.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna Cidades do Estado									 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGETCID()
LOCAL cResult 	:= "true|"
LOCAL nI		:= 0
LOCAL aRet		:= {}
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Obj
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametro
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode 	:= "MSALPHA"
oObj:nTp		:= 4
oObj:cAlias		:= "BID"
oObj:cRetorno	:= "BID->BID_CODMUN,BID->BID_DESCRI"
oObj:nIdx		:= 3 //BID_FILIAL + BID_EST + BID_DESCRI
oObj:cChave		:= HttpGet->Field_ESTADO
oObj:cCmdChave	:= "BID_EST"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Alimenta as variaves com o x3-combobox
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:getCombo()

	aRet := oObj:oWSGETCOMBORESULT:oWSCbGeneric:oWSGenericStruct
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Monta combo
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If Len(aRet) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Monta retorno para o combo
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		For nI:=1 To Len(aRet)
			cResult += aRet[nI]:cCode + "$" + aRet[nI]:cDescription + "|"
		Next
		cResult := Left(cResult,Len(cResult)-1)
	EndIf
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLGETSUB  ³ Autor ³ Totvs				 ³ Data ³ 11.01.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna subcontratos de um contrato							 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGETSUB()
LOCAL cResult 	:= "true|"
LOCAL nI		:= 0
LOCAL aRet		:= {}
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Lista Cidade
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
aRet := PLRETOECS(HttpSession->OPEVIEW,'S',HttpGet->Field_NUMCON)

If Len(aRet) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Retorna a operadora
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cResult += WCGetIntPad() + "%"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Monta retorno para o combo
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	For nI:=1 To Len(aRet)
		cResult += aRet[nI]:cCode + "$" + If(Empty(aRet[nI]:cNomSub),aRet[nI]:cDescription,aRet[nI]:cNomSub) + "|"
	Next
	cResult := Left(cResult,Len(cResult)-1)
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLGATCMP  ³ Autor ³ Totvs				 ³ Data ³ 11.01.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gatilho de campos											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGATCMP()
LOCAL cResult 	:= "true|"
LOCAL oObj		:= NIL
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml  //Aqui não tem o insite pq é utilizada no layout generico onde não tem login

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Obj
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametro
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Executa metodo para montar Header
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:getGAT()
	cResult := 'true|' + oObj:cGETGATRESULT
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLPROBEN  ³ Autor ³ Totvs				 ³ Data ³ 11.01.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Post do formulario para gravacao								 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLPROBEN()
LOCAL cResult 	:= "true|"
LOCAL oObj		:= NIL
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Obj
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXINC():New()
WsChgURL( @oObj, "PLSXINC.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Monta envio de fields
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
WCArrPost(@oObj:oWSINCBENEFIC:oWSDADBENEFIC)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Executa metodo para montar Header
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:setBenefic()
	cResult := "true|" + oObj:cSETBENEFICRESULT
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSETCAR  ³ Autor ³ Totvs				 ³ Data ³ 11.01.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Set solicitacao de carteirinha								 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSETCAR()
LOCAL cResult 	:= "true|"
LOCAL oObj		:= NIL
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Obj
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametro
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUSERCODE 	:= "MSALPHA"
oObj:cMatUsu	:= HttpGet->Field_MATUSU
oObj:cMotCar	:= HttpGet->Field_MOTCAR
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Executa metodo para montar Header
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:setSolCar()
	cResult := "true|" + oObj:cSETSOLCARRESULT
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLGETDGRI ³ Autor ³ Totvs 				 | Data ³ 24.01.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna dados para o browse gridData							 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGETDGRI()
LOCAL cResult  	:= "true|"
LOCAL cRdas		:= ""
LOCAL oObj		:= NIL

LOCAL nI		:= 0
LOCAL nLen		:= IIf(Valtype(HttpSession->RDAVIEW) == "A", Len(HttpSession->RDAVIEW), 0 ) //Tratamento para a existencia das RDAs (a função eh chamada antes do login para consulta rede credenciada)
LOCAL cHtml 	:= ""

// Remoção do InSite pois o guia medico não esta conectado
WEB EXTENDED INIT cHtml 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Metodo e propriedades
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Lista de faturas
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:getDadGrid()
	cResult +=	oObj:cGETDADGRIDRESULT
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return PLSDECODE(cResult)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PPSAphGuiaºAutor  ³ Paulo Sampaio      º Data ³ 18/06/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ P.E. que altera a funcao que monta a ExecPage na funcao    º±±
±±º          ³PPLSMATREI - Impressao da Guia de Atendimento.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ S-Case Tecnologia.                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PPSAphGuia(cTipoGuia)
LOCAL cPageExec := "PPLIMPGUIA"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Tipo de Guia
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Do Case
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica se irá imprimir guia Tiss padrão ANS									 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   Case !PPLVGUTIS() // Não imprime Guia Tiss padrão ANS.
		cPageExec := "PPLIMPGUIA"
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Consulta																			 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   Case cTipoGuia == '1'
		cPageExec := "PPLSCONS" // "PPLGUICON" // 'Consulta - Execução'
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   //³ Sadt
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   Case cTipoGuia == '2'
		cPageExec := "PPLSSADT" // "PPLGUISADT" // 'Sadt'
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   //³ Internacao
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   Case cTipoGuia == '3'
		cPageExec := "PPLSSOIN" // "PPLGUIINTE" // 'Inter./Prorrog. - Solic./Exec.'
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   //³ Odontologico
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   Case cTipoGuia == '4'
		cPageExec := "PPLSGTOP" //"PPLGUIODON" // Odontológico
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   //³ Honorario Individual
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   Case	cTipoGuia == '5'
		cPageExec := "PPLSHOIN"

EndCase

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return(cPageExec)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLPROARQ    ³ Autor ³ Totvs				   ³ Data ³ 20.02.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa arquivo (importacao xml)							 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLEXCARQ()
LOCAL cResult := "true|"
LOCAL cDirArq := ""
LOCAL lProc	  := .F.
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Val(HttpGet->cLinArray) > 0 .And. Len(HttpSession->aFileList) > 0 .And. Len(HttpSession->aFileList) >= Val(HttpGet->cLinArray)
	cDirArq := HttpSession->aFileList[Val(HttpGet->cLinArray)]:cArquivoIN
	lProc   := (HttpSession->aFileList[Val(HttpGet->cLinArray)]:cStatus $ '2')
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro no WS									  					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUserCode 		:= "MSALPHA"
oObj:cUserPlsName 	:= getNameUsr()
oObj:cDirArqIn 		:= cDirArq
oObj:cRDACode 		:= Httpget->cRda
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Metodo																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lProc
	If oObj:ProcDeXml()
		cResult := oObj:CPROCDEXMLRESULT
	Else
	    cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
	EndIf
Else
	cResult := "false|Somente podem ser excluidos arquivos nao acatados."
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina									 					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLVALPEG  ³ Autor ³ Totvs 				 | Data ³ 24.01.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida Guias antes da PEG		 			        		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
web function PPLVALPEG()
LOCAL cResult  	:= ""
LOCAL oObj		:= nil
//D - Digitação Offline   P - Protocolo
Local cTipo		:= IIf(Valtype(HttpGet->cTipo) == "U", "D", HttpGet->cTipo)
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Metodo e propriedades
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():new()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSETPEG  ³ Autor ³ Totvs 				 | Data ³ 24.01.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera peg de guias		 									 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
web function PPLSETPEG()
LOCAL cResult  	:= ""
LOCAL oObj		:= nil
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Guarda na sessao caso sai da pagina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
httpSession->cInProcRda := httpGet->cInProcRda
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Metodo e propriedades
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if valType(HttpSession->lMosGui) == 'U'

	httpSession->lMosGui := .t.

	oObj := WSCFGDICTIONARY():new()
	wsChgURL( @oObj, "CFGDICTIONARY.APW" )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ parametro para verificar se exibe as guias ou nao
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oObj:cUSERCODE:= "MSALPHA"
	oObj:cMVPARAM := "MV_PLSEGU"
	if oObj:GETPARAM()
		httpSession->lMosGui := iIf( allTrim(oObj:cGETPARAMRESULT)=="1",.t.,.f. )
	endIf
endIf
oObj := WSPLSXFUN():new()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ tranferencia de guias para peg definitivo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if oObj:setTFGuia()
	cResult :=	oObj:cSETTFGUIARESULT
else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
endIf

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCHKIPR  ³ Autor ³ Totvs 				 | Data ³ 24.01.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se esta em processado							 	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
web function PPLCHKIPR()
LOCAL cResult  	:= ""
LOCAL oObj		:= nil
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Metodo e propriedades
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode			 	:= "MSALPHA"
oObj:oWSMatPeg:cSemaforo	:= httpGet->cSemaforo
oObj:oWSMatPeg:cFunJs	 	:= httpGet->cFunJs
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ tranferencia de guias para peg definitivo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if oObj:getInProces()
	cResult :=	oObj:cGETINPROCESRESULT
else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
endIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCHKIPR  ³ Autor ³ Totvs 				 | Data ³ 24.01.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se esta em processado							 	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
web function PPOSICIONE()
LOCAL cResult := "false|"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Metodo e propriedades
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode		:= "MSALPHA"
oObj:nIdx			:= VAL(HttpGet->Field_INDICE)
oObj:cCmdChave	 	:= HttpGet->Field_CAMPO
oObj:cChave	 		:= HttpGet->Field_CODRDA
oObj:cAlias	 		:= HttpGet->Field_ALIAS

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ tranferencia de guias para peg definitivo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if oObj:posicione()
	cResult :=	oObj:cPOSICIONERESULT
else
	cResult :=	"false|"+StrTran(PWSGetWSError( "" ),":","")
endif

WEB EXTENDED END

return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCHKIPR  ³ Autor ³ Totvs 				 | Data ³ 24.01.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime relatorio e manda por email						 	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
web function PPLIPREE

LOCAL cResult := "false|"
Local cGlosa  := 'N'
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Metodo e propriedades
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

if ValType(HttpGet->cGlosa) <> 'U'
	cGlosa  :=  HttpGet->cGlosa
endif

oObj:cUserCode		:= "MSALPHA"
oObj:cChave			:= HttpGet->Field_CODRDA + "|" + HttpGet->Field_EMAIL + "|" + HttpGet->cRecno + "|" + HttpGet->cTipoRel + "|" + cGlosa + "|"
oObj:cFunName	 	:= HttpGet->cFunRel

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ tranferencia de guias para peg definitivo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if oObj:ppImpRel()
	cResult :=	oObj:cPPIMPRELRESULT
else
	cResult :=	"false|"+StrTran(PWSGetWSError( "" ),":","")
endif

WEB EXTENDED END

return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ PPLVGUTIS³ Autor ³ TOTVS			     ³ Data ³ 01.02.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Verifica se irá imprimir guia Tiss padrão ANS			   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PPLVGUTIS()

LOCAL lRet := .F.
LOCAL oObjPar
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o parametro													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjPar := WSCFGDICTIONARY():New()
WsChgURL( @oObjPar, "CFGDICTIONARY.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro no WS														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjPar:cUSERCODE	:= "MSALPHA"
oObjPar:cMVPARAM	:= "MV_POGTISS"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pegar a codigo de consulta definido no parametro 					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObjPar:GETPARAM()
	lRet := Iif(oObjPar:cGETPARAMRESULT == '.T.',.T.,.F.)
EndIf

If ValType(lRet) <> 'L'
	lRet := .F.
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³fim da funcao														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return (lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLGUIPR 	  ³ Autor ³ Rogerio Tabosa       ³ Data ³ 07.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da pagina de escolha de Guia ou Protocolo (recurso Glosa)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLRECGLO()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml  START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mostra a pagina para entrar com o protocolo/Guia						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml := ExecInPage( "PPLRECGLO" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLADRECG 	  ³ Autor ³ Rogerio Tabosa       ³ Data ³ 18.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da pagina para adicionar Recurso de Glosa               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLADRECG()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tipo de pre-atendimento se vai pre-atender ou atender (executar)		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->cObsRecG := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mostra a pagina para entrar com o protocolo/Guia						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml := ExecInPage( "PPLADDRECG" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLVIRECG 	  ³ Autor ³ Rogerio Tabosa       ³ Data ³ 18.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da pagina para visualizar Recurso de Glosa               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLVIRECG()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mostra a pagina para entrar com o protocolo/Guia						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml := ExecInPage( "PPLVISRECG" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLGETRECG    ³ Autor ³ Rogerio Tabosa	      ³ Data ³ 18/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os dados da guia glosada                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGETRECG()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLRECGLO():New()
WsChgURL( @oObj, "PLRECGLO.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cRecno		:= HttpGet->cRecno
oObj:cVisDad		:= HttpGet->cTipRet
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:GetDadGuiGlo()
	cResult := oObj:cGetDadGuiGloRESULT
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLDOCRECG    ³ Autor ³ Rogerio Tabosa	      ³ Data ³ 18/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava o anexo do Recurso de Glosa                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLDOCRECG()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLRECGLO():New()
WsChgURL( @oObj, "PLRECGLO.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cRecnoB4D	:= HttpGet->cRecno
oObj:cArq1			:= HttpGet->cUpld1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:PutRecGloDoc()
	cResult += oObj:cPutRecGloDocRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLDETRECG    ³ Autor ³ Rogerio Tabosa	      ³ Data ³ 18/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os dados do recurso de glosa                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLDETSRECG()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLRECGLO():New()
WsChgURL( @oObj, "PLRECGLO.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cRecnoBVO	:= Alltrim(Str(HttpGet->cRecno))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:GetRecGloEvents()
	cResult += oObj:cGetRecGloEventsRESULT

EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)


Web Function PPLTMPPCT()

local cPacote
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cPacote := HttpGet->cPacote

HttpSession->cPacote := cPacote

WEB EXTENDED END


return PLSDECODE("true")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLSERPC 	  ³ Autor ³ Roberto       ³ Data ³ 21.05.2015 		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Função responsável por popular a lista de pacotes na liberação ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSERPC()

LOCAL cHtml   := ""
LOCAL aRetorno := {}
Local cMatric
Local cNumAut
Local cTipo
Local cRDACode
Local cCodLoc
Local cTipoAut
Local nPosRDA
Local cCodEsp
Local cAltCmp	:= ""
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
local aServ := {}
local cPacote := "false|Erro ao buscar dados da liberação."
local nI
local nP

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

cMatric := HttpSession->aVldCartao[2]


cNumAut := AllTrim(StrTran(StrTran(HttpGet->cNumeAut,".",""),"-",""))

cTipo   := HttpGet->cTp

cRDACode := HttpGet->cRda

cCodLoc := HttpGet->cCodLoc

cTipoAut	:= IiF( ValType(HttpGet->cTpAut) != 'U',HttpGet->cTpAut,"L")

cAltCmp	:= HttpGet->cAltGuia

if !empty(cCodLoc)
	nPosRDA := aScan( HttpSession->RDAVIEW, { |x| x:cCODE == HttpGet->cRda .And. x:cCodLoc == cCodLoc} )
else
	nPosRDA := aScan( HttpSession->RDAVIEW, { |x| x:cCODE == HttpGet->cRda} )
endIf

if nPosRDA > 0 .AND. ValType(HttpSession->RDAVIEW[nPosRDA]:OWSMESPRDA:OWSESPRDA) == "A"
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

		For nI:=1 To Len(oObj:oWSRETSERPCTRESULT:OWSMITEGUI)

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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cPacote)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLVIRECG 	  ³ Autor ³ Rogerio Tabosa       ³ Data ³ 18.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da pagina para visualizar Recurso de Glosa               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLDETRECG()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mostra a pagina para entrar com o protocolo/Guia						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml := ExecInPage( "PPLDETRECG" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCMPFP   ³ Autor ³ TOTVS S/A            ³ Data ³ 15/08/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Botao de complemento nos formularios do portal                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSCMPFP()
Local cResult := ""
Local oObj    := Nil
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSCMPFP():New()
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

Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLSHON	  ³ Autor ³ Daher	       ³ Data ³ 12.09.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para buscar o honorario individual	               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUserCode 		 := "MSALPHA"
oObj:cNumAut   		 := AllTrim(StrTran(StrTran(HttpGet->cNumeAut,".",""),"-",""))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³A solicitacao deve informar o tipo.									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa metodo para retorno da liberacao								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cabecalho															   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
					"cNumMaxAux!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNumAux+"|<"

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

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta matriz para impressao de guia									  			  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Honorario Individual													   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If HttpSession->cTp == '5'
			oObj:cNumPeg :=  oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cChvBD6
			If oObj:GetBD6()
				HttpSession->aMatBD6 := oObj:oWSGETBD6RESULT:OWSSMATBD6
			EndIf
		EndIf

		//Para guia de prorrogaçã (tipo 11), é necessáio validar a matricula do usurio e gravar as sessions de matricula
		If HttpSession->cTp == '11'
			//Atribui valor da carteirinha na variavel para busca dos dados do usuario
			HttpGet->TrilhaCard 	:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cMatric
			HttpGet->cRda 		:= oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cRda
			HttpGet->cCodLoc 		:= "001"


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

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao tem procedimento												   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lExibe .and. HttpSession->cTp != '11'
			cResult := "false|Nenhum procedimento autorizado para o executante!"
		EndIf
Else
		cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLGUIPR 	  ³ Autor ³ Rogerio Tabosa       ³ Data ³ 07.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chamada da pagina de escolha de Guia ou Protocolo (recurso Glosa)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLDOCG()
Local cHtml	:= ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mostra a pagina para entrar com o protocolo/Guia						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->cResDoc := ""
If ValType(HttpGet->cChvPes) == 'U'
	HttpGet->cChvPes := "||" // manda vazio a primeira vez
EndIf
cHtml := ExecInPage( "PPLDOCGUIA" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLADRECG 	  ³ Autor ³ Rogerio Tabosa       ³ Data ³ 18.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da pagina para adicionar Recurso de Glosa               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLDOCGUI()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tipo de pre-atendimento se vai pre-atender ou atender (executar)		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->cObsRecG := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mostra a pagina para entrar com o protocolo/Guia						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml := ExecInPage( "PPLADDOCG" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLGETRECG    ³ Autor ³ Rogerio Tabosa	      ³ Data ³ 18/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os dados da guia glosada                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGETDOCG()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLRECGLO():New()
WsChgURL( @oObj, "PLRECGLO.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cRecno		:= HttpGet->cRecno
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:GetDadEveGui()
	cResult := oObj:cGetDadEveGuiRESULT
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLGRVDOCG    ³ Autor ³ Rogerio Tabosa	      ³ Data ³ 18/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava documento					                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGRVDOCG()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLRECGLO():New()
WsChgURL( @oObj, "PLRECGLO.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cRecno		:= HttpGet->cRecno
oObj:cArq1		 	:= HttpPost->cDirArq
oObj:cArq2		 	:= HttpPost->cDir2Arq
oObj:cCodRda	 	:= HttpSession->RDAVIEW[1]:CCODE

HttpSession->cResDoc := "Vazio"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:PutDocGuiEvents()
	cResult += oObj:cPutDocGuiEventsRESULT
	HttpSession->cResDoc := cResult
Else
	HttpSession->cResDoc := ""
	cResult := "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³WTDecode    ³ Autor ³ Daher		 	      ³ Data ³ 18/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava documento					                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function WTDecode(cString)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ATENCAO ESTA FUNCAO TEM A FUNCIONALIDADE DE RETIRAR OS CARACTERES ESPECIAIS
// DE UMA DETERMINADA STRING.
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
cString := StrTran(cString,"Ç","C");cString := StrTran(cString,"µ","" );cString := StrTran(cString,"¿","" );cString := StrTran(cString,"´","")
cString := StrTran(cString,"%","" );cString := StrTran(cString,"@","" );cString := StrTran(cString,"#","" );cString := StrTran(cString,"$","")
cString := StrTran(cString,"&","" );cString := StrTran(cString,"*","" );cString := StrTran(cString,"-","" );cString := StrTran(cString,"=","")
cString := StrTran(cString,"`","" );cString := StrTran(cString,"~","" );cString := StrTran(cString,"?","" );cString := StrTran(cString,"/","")
cString := StrTran(cString,"\","" );cString := StrTran(cString,"þ","" );cString := StrTran(cString,"Þ","" );cString := StrTran(cString,"¾","")
cString := StrTran(cString,"{","" );cString := StrTran(cString,"|","" );cString := StrTran(cString,"}","" );cString := StrTran(cString,"¡","")
cString := StrTran(cString,"¢","" );cString := StrTran(cString,"£","" );cString := StrTran(cString,"¤","" );cString := StrTran(cString,"¥","")
cString := StrTran(cString,"¦","" );cString := StrTran(cString,"¨","" );cString := StrTran(cString,"©","" );cString := StrTran(cString,"ª","")
cString := StrTran(cString,"«","" );cString := StrTran(cString,"¬","" );cString := StrTran(cString,"­","" );cString := StrTran(cString,"®","")
cString := StrTran(cString,"¯","" );cString := StrTran(cString,"°","" );cString := StrTran(cString,"±","" );cString := StrTran(cString,"²","")
cString := StrTran(cString,"³","" );cString := StrTran(cString,"´","" );cString := StrTran(cString,"µ","" );cString := StrTran(cString,"¶","")
cString := StrTran(cString,"·","" );cString := StrTran(cString,"¸","" );cString := StrTran(cString,"¹","" );cString := StrTran(cString,"º","")
cString := StrTran(cString,"»","" );cString := StrTran(cString,"¼","" );cString := StrTran(cString,"½","" );cString := StrTran(cString,"¾","")
cString := StrTran(cString,"¿","" );cString := StrTran(cString,"×","" );cString := StrTran(cString,"Ø","" );cString := StrTran(cString,"ß","")
cString := StrTran(cString,"æ","" );cString := StrTran(cString,"ç","c");cString := StrTran(cString,"÷","" );cString := StrTran(cString,"ø","")
cString := StrTran(cString,"ý","y");cString := StrTran(cString,"þ","");cString := StrTran(cString,"ÿ","y" );cString := StrTran(cString,"œ","")
cString := StrTran(cString,"Š","S");cString := StrTran(cString,"š","s");cString := StrTran(cString,"Ÿ","Y");cString := StrTran(cString,"Ž","Z")
cString := StrTran(cString,"ž","z");cString := StrTran(cString,"ƒ","f");cString := StrTran(cString,"!","" );cString := StrTran(cString,"Chr(166)","")
cString := StrTran(cString,"¨","" );cString := StrTran(cString,"°","" );cString := StrTran(cString,"º","" );cString := StrTran(cString,"","")
cString := StrTran(cString,"","" );cString := StrTran(cString,"<","" );cString := StrTran(cString,"Chr(167)","") 
		     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da funcao														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(cString)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLPRTCAR    ³ Autor ³ Thiago Guilherme	      ³ Data ³ 03/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibe procedimentos e suas carencias no portal                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLPRTCAR()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= "true|"
LOCAL nResult		:= 0
LOCAL nI			:= 0
local xHeader    := ""
Local xCols      := ""
LOCAL cGrid	   := "89"
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:ExCarPortal()

	nResult := Len(oObj:OWSEXCARPORTALRESULT:OWSSCARPOR)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Cabecalho
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLCARPOR    ³ Autor ³ Thiago Guilherme	      ³ Data ³ 03/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 									                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCARPOR()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mostra a pagina de procedimentos				 						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cHtml += ExecInPage( "PPLEXCARPORT" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLCARENC    ³ Autor ³ Thiago Guilherme	      ³ Data ³ 13/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna as carencias do beneficiario para o portal            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCARENC()
LOCAL cResult  	:= "true|"
LOCAL cMatric := HttpGet->cMatric
LOCAL cRecno  := HttpGet->cRecno
LOCAL nResult
LOCAL nI
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:CcMatrc	:= cMatric
oObj:CcRecno	:= cRecno

If oObj:CarenBnf()

	nResult := Len(oObj:OWSCARENBNFRESULT:OWSSRETCAREN)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Cabecalho
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLGRPFAM    ³ Autor ³ Thiago Guilherme	    ³ Data ³ 09/01/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os dados do grupo familiar                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Web Function PPLGRPFAM()
LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If HttpSession->MPortal == "000010"

oObj:cUserCode	:= "MSALPHA"
oObj:cCUSRLOGIN	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE

EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:DadGrpFam()

	nResult := Len(oObj:OWSDadGrpFamRESULT:OWSSDADGRP)

	xCols := "["
	For nI := 1 to nResult

		xCols += "{"
		xCols +=  "0:{field:'cMatric', value:'" + oObj:OWSDadGrpFamRESULT:OWSSDADGRP[nI]:cMatricl +   "'},"
		xCols +=  "1:{field:'cNomBnf',value:'" +  SubStr(oObj:OWSDadGrpFamRESULT:OWSSDADGRP[nI]:cNomeBnf,1,20) +"'}" + Iif( nResult != nI ,"},","}]" )
	Next

	cResult += xCols +"|"

Else
	cResult := "false|"
EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLNOTIC    ³ Autor ³ Thiago Guilherme	      ³ Data ³ 03/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os dados da noticia no portal			                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
LOCAL 	cHtml := ""
STATIC lVerTds		:= .F.

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Chamada da rotina pelo portal do prestador
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Chamada da rotina pelo portal do beneficiario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados para a pagina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

If oObj:RetNot()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Retorna os títulos das notícias
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Retorna o conteúdo da notícia
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLNOT    ³ Autor ³ Thiago Guilherme	      ³ Data ³ 03/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 									                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLNOT()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mostra a pagina de procedimentos				 						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cHtml += ExecInPage( "PPLEXNOT.APW?cCdEspec="+HttpGet->cCdEspec )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLCHANOT  ³ Autor ³ Thiago Guilherme	      ³ Data ³ 03/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do menu de arquivo de noticias do portal   			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WEB FUNCTION PPLCHANOT()
LOCAL cHtml  	:= ""
LOCAL cDir	 	:= getPastPp(.T.)
LOCAL aFiles	:= {}

WEB EXTENDED INIT cHtml START "InSite"

If !Empty(cDir)

	cDir := cDir + getPrtSkin() + "\arquivonoticia\"+ HttpGet->cCodNot + "\"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Le diretorio para mostrar os arquivos disponiveis
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina			   													     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLVIRECG 	  ³ Autor ³ Rogerio Tabosa       ³ Data ³ 18.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da pagina para retornar um valor da TISS              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLRETVLRTISS()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:oWSTERMOTISS:cCodAlias	:= HttpGet->cAlias
oObj:oWSTERMOTISS:cVlrProt	:= HttpGet->cVlrProt
oObj:oWSTERMOTISS:cCampo		:= HttpGet->cCampo
oObj:oWSTERMOTISS:cVerTiss	:= HttpSession->cTISSVer

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:GetVlrTiss()
	cResult += oObj:cGETVLRTISSRESULT

EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLVIRECG 	  ³ Autor ³ Everton M. Fernandes ³ Data ³ 18.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada para montar guia de acordo com a TISS                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLFORMTISS()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL aCmbWS		:= {}
LOCAL aCmbX		:= {}
LOCAL aCmbAux		:= {}
LOCAL cStrCBOX	:= ""
LOCAL cTISSVer	:= ""
LOCAL nI,nY, nPos
Local cAnexCli	:= IIF( ValType(Httpget->cAnexCli) == "U", "", Httpget->cAnexCli )
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Aqui eu pego o que vem de Session executo aqui pra enviar a informaçao
// pro WS pois o mesmo nao acessa o conteudo da Session	dificultando o dinamismo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³EXCLRESU   ³ Autor ³ Roberto Vanderlei    ³ Data ³ 22.03.2017  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da Rotina de Exclusao de Itens do Resumo.			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function  EXCLRESU(aCols, cParPosExcl)

LOCAL oObj 		:= NIL
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"

oObj:cChave	:= cParPosExcl

oObj:ExclResu()

WEB EXTENDED END

return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³EXCLRECT   ³ Autor ³ Roberto Vanderlei    ³ Data ³ 27.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da Rotina de Exclusao de Itens da Receitas.			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function  EXCLRECT(aCols, cParPosExcl)

LOCAL oObj 		:= NIL
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"

oObj:cProtoc	:= cParPosExcl
oObj:cMedicamento	:= aCols[1]
oObj:ExclRect()

WEB EXTENDED END

return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLGETGRID  ³ Autor ³ Rogerio Tabosa       ³ Data ³ 18.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Responsável pela manipulação dos grids das Guias no Portal     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGETGRID()
LOCAL oObj 		:= NIL

LOCAL nI			:= 0
LOCAL nJ			:= 0
LOCAL nL			:= 0
LOCAL nLen			:= 0
LOCAL nLenVal		:= 0
LOCAL nPos			:= 0
LOCAL nPosVal		:= 0
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

//LOCAL aCampos		:= Separa ( HttpGet->cCmp, "," , .T.)
LOCAL aValores	:= {}
LOCAL aHeader		:= {}
LOCAL aCols		:= {}
LOCAL aLinha		:= {}

//Variaveis de tratamento do relacionamento que preenche a combo genericamente
LOCAL aRelac 		:= {}
LOCAL cCpoRelac	:= 	""
LOCAL cVlrRelac	:= ""

LOCAL cLinhas		:= ""
LOCAL lAtuVisibl	:= ""
LOCAL lDelVisibl	:= ""
LOCAL nNumAux		:= -1
LOCAL lFromGrid   := "false"
LOCAL cFunPosExcl 	:= ""
local cParPosExcl 	:= ""
local cSeqDelExec	:= "000"

LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml //Aqui não tem o insite pq é utilizada no layout generico onde não tem login

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// HttpSession->aCmpGuia -> Guarda todos os campos/grids da Guia
// HttpSession->aCmpGuia[nPos] -> Trata-se da referência a um campo ou grid
//
// HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING -> aHeader do Grid
// HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING -> aCols do Grid
//
// xCols e xHeader são as strings que o JSPLS usará para montar o grid
// aCols e aHeader são os arrays que serão utilizados para manipular os campos
//por esta função
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If '*@*' $ HttpGet->cValores
	HttpGet->cValores := strTran(HttpGet->cValores, '*@*', '§') //para tratar campos do tipo email que contém @
EndIf

aValores	:= Separa ( HttpGet->cValores, "@" , .F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Recupera dados da página
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cGrid := HttpGet->cGrid
nRecno := IIF(HttpGet->nRecno == "", "0", HttpGet->nRecno)
nRecno := IIF(Valtype("nRecno") <> "C", "", nRecno)
nOpc := Val(HttpGet->nOpc)
lBotao := HttpGet->lBotao
cSt := HttpGet->cSt
cValores	:= HttpGet->cValores

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
	aRelac := StrToArray(HttpGet->cRelac, "~")
	cCpoRelac	:= 	aRelac[2]
	cVlrRelac	:= ""
	aRelac := StrToArray(aRelac[3], "|")
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Encontra o objeto no array de campos
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
nPos := aScan( HttpSession->aCmpGuia, { |x| x:cNome == cGrid} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Monta o aCols e aHeader
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nPos > 0

	aHeader	:= HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING
	aCols		:= HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//Verifica se o aCols e aHeader estão vazios
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If ValType(aHeader) <> 'A'
		aHeader := {}
		HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING := {}
	EndIf
	If ValType(aCols) <> 'A'
		aCols := {}
		HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING := {}
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//Adiciona no aCols ou Posiciona na linha da alteração
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//Exclui registro
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			If Len(aCols) > 0

				if cFunPosExcl <> ""
					&cFunPosExcl.(aCols[nPosCols], cParPosExcl) //Chama função após a exclusão da gride.
				endif

				aDel(aCols,nPosCols)
				aSize(aCols,Len(aCols)-1)
				aDel(aHeader,nPosCols)
				aSize(aHeader,Len(aHeader)-1)
			EndIf

		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//Inicia o xHeader e o xCols
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			xHeader := "["

			If 	Empty(HttpSession->aCmpGuia[nPos]:CXCOLS)
				xCols := "["
			Else
				xCols := HttpSession->aCmpGuia[nPos]:CXCOLS
				xCols := Left(xCols,Len(xCols)-1) + ","
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//Monta xHeader e xCols
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			nLen := len(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID)
			nLenVal := len(aValores)
			For nI := 1 to nLenVal
				If "§" $ aValores[nI]
							aValores[nI] := strTran(aValores[nI], '§', '@')
				EndIf
				aLinha := Separa(aValores[nI],";",.F.)
				nNumAux := -1
				If Len(aCols) < nPosCols+nI-1
					aAdd(aCols,{})
					aAdd(aHeader,{})
				EndIf
				For nJ := 1 to nLen

					If nJ == 1
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						//Adiciona os botões da linha e coloca o Recno
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						If (lAtuVisibl == "true") .OR. (lDelVisibl == "true")
							xCols += "{"
						EndIf
						If (lAtuVisibl == "true")
							If nI == 1
								xHeader += "{name:'Alterar'},"
							EndIf
							nNumAux++
							//xCols += "{"
							xCols += cValToChar(nNumAux) + ":{field:'RECNO', value:'0#" + AllTrim(Str(nPosCols+nI-1)) + "," + cGrid + ".id,4'},"
						EndIf
						If (lDelVisibl == "true")
							If nI == 1
								xHeader += "{name:'Excluir'},"
							EndIf
							nNumAux++

							if cFunPosExcl <> ""
								xCols += cValToChar(nNumAux) + ":{field:'RECNO', value:'1#" + AllTrim(Str(nPosCols+nI-1)) + "," + cGrid + ".id,5,true," + '""' + " ," + '""' + " ,cCampoDefault," + lAtuVisibl + "," + lDelVisibl + "," + lFromGrid + ", cFunPosExcl, cParPosExcl'}," //Botão Excluir
							else
								xCols += cValToChar(nNumAux) + ":{field:'RECNO', value:'1#" + AllTrim(Str(nPosCols+nI-1)) + "," + cGrid + ".id,5,true," + '""' + " ," + '""' + " ,cCampoDefault," + lAtuVisibl + "," + lDelVisibl + "," + lFromGrid + "'}," //Botão Excluir
							endif

						EndIf
					EndIf

					cCampo  := alltrim(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID[nJ]:CNOME)
					cTitulo := alltrim(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID[nJ]:CDESCRI)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³ Verifica se o campo já tem algum valor
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					nPosVal := aScan(aLinha , { |x| cCampo $ x } )
					If cCampo == "cProExe" .AND. nPosVal > 0
						If Separa(aLinha[nPosVal],"$",.T.)[1] == "cProExeDesc"
							nPosVal := 9	
						Endif
					EndIF
					If nPosVal > 0
						cValor	 := Separa(aLinha[nPosVal],"$",.T.)[2]
					Else
						cValor := ""
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³ Cabecalho
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					If nI == 1 .AND. cTitulo <> 'CMPSEQ' // Validação para remover do cabeçalho pois estava desposicionando os itens da grid.
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

	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//Se for alteração, reconstroi o xCols
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If nOpc == 4 .OR. nOpc == 5
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

	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//Adiciona o xHeader e xCols ao array da session
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	//Verifica se não houve problemas na montagem e caso haja, fecha o xHeader
	If RAT(xHeader,",") == 0
		xHeader := Left(xHeader,Len(xHeader)-1)+"]"
	EndIf

	HttpSession->aCmpGuia[nPos]:CXHEADER := xHeader
	HttpSession->aCmpGuia[nPos]:CXCOLS   := xCols
	HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING := aClone(aHeader)
	HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING := aClone(aCols)
	If !Empty(cCpoRelac)
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

	//Calcula a qtd de páginas
	/*nQtdReg	:= nI-1

    	if nRegPagina==0
    		nRegPagina := 1
    	endIf

		nRest	:= mod(nQtdReg, nRegPagina)

		If nRest > 0
			nQtdPag	:= Int(nQtdReg / nRegPagina)+1
		Else
			nQtdPag := Int(nQtdReg / nRegPagina)
		EndIf

		If 	nQtdPag == 0
			nQtdPag := 1
		EndIf*/


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

/*HttpGet->cCmp*/
Return PLSDECODE(cResult)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLGETCMP   ³ Autor ³ Rogerio Tabosa       ³ Data ³ 18.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna os campos do grid                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGETCMP()
LOCAL oObj 		:= NIL

LOCAL nI			:= 0
LOCAL nLen			:= 0
LOCAL nPos			:= 0

LOCAL cResult  	:= ""
LOCAL cGrid		:= ""
LOCAL nOpc			:= ""
LOCAL cRecno		:= ""
LOCAL lAtuVisibl	:= ""
LOCAL lDelVisibl	:= ""
LOCAL lFromGrid   := ""
local cFunPosExcl   := ""
local cParPosExcl	:= ""
local cSeqDelExec	:= "000"

LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Recupera nome do grid
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cGrid := HttpGet->cGrid
nOpc := HttpGet->nOpc
cRecno := HttpGet->nRecno
lBotao := HttpGet->lBotao
cSt		:= HttpGet->cSt // 1-Normal; 0-Marca a linha
cValores := HttpGet->cValores
cCampoDefault := HttpGet->cCampoDefault

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

If cRecno='undefined'
	cRecno := '0'
EndIf

If lBotao='undefined'
	lBotao := 'true'
EndIf

If cSt='undefined'
	cSt := '1'
EndIf

If lAtuVisibl='undefined'
	lAtuVisibl := 'true'
EndIf

If lDelVisibl='undefined'
	lDelVisibl := 'true'
EndIf
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Encontra o objeto no array de campos
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
nPos := aScan( HttpSession->aCmpGuia, { |x| x:cNome == cGrid} )

//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Monta o aCols e aHeader
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nPos > 0

	cResult := "true|" +	 cGrid + "|" + nOpc + "|["
	nLen := len(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID)

	For nI := 1 to nLen
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Verifica se foi informado funcao de tratamento na linha
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		cResult += alltrim(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID[nI]:CNOME) + Iif( nLen != nI ,",","]|" )
	Next nI

	cResult += + cRecno + "|" + lBotao + "|" + cSt + "|"  + cValores + "|" + cCampoDefault + "|" + lAtuVisibl + "|" + lDelVisibl + "|" + lPacote + "|" + lFromGrid + "|" + cFunPosExcl + "|"  + cParPosExcl + "|" + cSeqDelExec + "|"
Else
	cResult := "false|Não foi encontrado o grid especificado!"
EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLVISGRID  ³ Autor ³ Rogerio Tabosa       ³ Data ³ 18.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna as colunas e valores da linha do Grid                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLVISGRID()

LOCAL oObj 		:= NIL

LOCAL nI			:= 0
LOCAL nJ			:= 0
LOCAL nLen			:= 0
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
LOCAL xCols		:= "[]"

LOCAL aHeader		:= {}
LOCAL aCols		:= {}

LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Recupera dados da página
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cGrid := HttpGet->cGrid
nRecno := Val(HttpGet->nRecno)
nOpc := Val(HttpGet->nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Encontra o objeto no array de campos
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
nPos := aScan( HttpSession->aCmpGuia, { |x| x:cNome == cGrid} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Monta o aCols e aHeader
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nPos > 0
 
	aHeader	:= HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING
	aCols		:= HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//Verifica se o aCols e aHeader estão vazios
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If ValType(aHeader) <> 'A'
		aHeader := {}
	EndIf
	If ValType(aCols) <> 'A'
		aCols := {}
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//Recupera os valores e monta o xCols
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	xCols := "["
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

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLSETACMP  ³ Autor ³ Rogerio Tabosa       ³ Data ³ 18.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Responsável pela manipulação dos grids das Guias no Portal     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
LOCAL nPosNomExe	:= 0
LOCAL nI			:= 0
LOCAL nLinhas		:= 0
Local nCont			:= 0

LOCAL cSeqRefAtu := iif(type("HttpGet->cSeqRefAtu") <> "U" .and. !empty(HttpGet->cSeqRefAtu), HttpGet->cSeqRefAtu, "")
LOcal aAuxSeqRef := {}

LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

For nCont := 1 To Len(aLinhaMarc)
	If ValType(aLinhaMarc[nCont]) <> "N"
		aLinhaMarc[nCont] := Val(aLinhaMarc[nCont])	
	EndIf
Next nCont

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Encontra o objeto no array de campos
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
nPos := aScan( HttpSession->aCmpGuia, { |x| x:cNome == cGrid} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Monta o aCols e aHeader
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLPROSAUD  ³ Autor ³ Rogerio Tabosa       ³ Data ³ 18.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna as colunas e valores da linha do Grid                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLPROSAUD()

LOCAL nI			:= 0
LOCAL cResult  	:= ""
LOCAL cProSaud	:= ""
LOCAL oProSaud	:= ""
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Recupera dados da página
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cCombo := HttpGet->cCombo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ obj																			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros																    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  PPLCHAANOP  ³ Autor ³ Rogerio Tabosa       ³ Data ³ 18.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna as colunas e valores da linha do Grid                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Web Function PPLANOPM
LOCAL cHtml 	:= ""
LOCAL oObj	    := nil
LOCAL oObjRG    := nil
LOCAL nPosRda	:= 0
LOCAL cTISSVer	:= ""
LOCAL cRda		:= ""
LOCAL cCodLoc	:= ""
LOCAL aRDA		:= {}


WEB EXTENDED INIT cHtml START "InSite"
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE := "MSALPHA"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta as variaves com o x3-combobox								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if oObj:getCombo()
	HttpSession->cCodPad   	:= oObj:oWSGETCOMBORESULT:cCodPad
Endif

HttpSession->cTp := '09'
cHtml := ExecInPage( "PPLSSANO" )
WEB EXTENDED END

Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  PPLCHAANRA  ³ Autor ³ Rogerio Tabosa       ³ Data ³ 18.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna as colunas e valores da linha do Grid                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Web Function PPLANRAD
LOCAL cHtml 	:= ""
LOCAL oObj	    := nil
LOCAL oObjRG    := nil
LOCAL nPosRda	:= 0
LOCAL cTISSVer	:= ""
LOCAL cRda		:= ""
LOCAL cCodLoc	:= ""
LOCAL aRDA		:= {}

WEB EXTENDED INIT cHtml START "InSite"
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE := "MSALPHA"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta as variaves com o x3-combobox								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if oObj:getCombo()
	HttpSession->cCodPad   	:= oObj:oWSGETCOMBORESULT:cCodPad
Endif
HttpSession->cTp := '08'
HttpSession->cNumAut := If (HttpGet->cNumAut == Nil,"",HttpGet->cNumAut)

cHtml := ExecInPage( "PPLSSANR" )
WEB EXTENDED END

Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLANQUI  ³ Autor ³ Rogerio Tabosa       ³ Data ³ 18.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna as colunas e valores da linha do Grid                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Web Function PPLANQUI
LOCAL cHtml 	:= ""
LOCAL oObj	    := nil
LOCAL oObjRG    := nil
LOCAL nPosRda	:= 0
LOCAL cTISSVer	:= ""
LOCAL cRda		:= ""
LOCAL cCodLoc	:= ""
LOCAL aRDA		:= {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE := "MSALPHA"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta as variaves com o x3-combobox								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if oObj:getCombo()
	HttpSession->cCodPad   	:= oObj:oWSGETCOMBORESULT:cCodPad
Endif
HttpSession->cTp := '07'

cHtml := ExecInPage( "PPLSSANQ" )

WEB EXTENDED END

Return cHtml


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSANX ³ Autor ³ Daher				     ³ Data ³ 28.03.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Procura a liberacao e mostra os dados						 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSANX()
local nI      	:= 0
local oObj	  	:= NIL
local lExibe  	:= .F.
local cResult 	:= "true|"
local cHtml 	:= ""
local cTipGui 	:= ""
local cCodUsr 	:= ""
local cCodRda 	:= ""
local cGuiRef 	:= ""
local cMatric 	:= ""
local cDatGui 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUserCode 		 := "MSALPHA"
oObj:cNumAut   		 := AllTrim(StrTran(StrTran(HttpGet->cNumeAut,".",""),"-",""))
oObj:cTipo			 := HttpGet->cTp

//Resgatar a lista de RDA's e passar para o RetAutLib separadas por vírgula.

oObj:cRDACode := StrTran(PLA09ASES(),"|M",",") 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa metodo para retorno da liberacao								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:RetAutLib()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cabecalho															   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cProtoc)//Carrega numero do protocolo RN 395 da guia principal
	   		cResult +=	"B4A_REGANS!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cRegAns+"|"+;		    //0
					"B4A_DATPRO!"+dtoc(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:dDtAut)+"|"+; 		//1
					"B4A_NOMUSR!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomeUsr+"|"+;		        //2
					"B4A_USUARI!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cMatric+"|"+;      		//3
					"B4A_PESO!"+ AllTrim(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cPeso) +"|"+;       //4
					"B4A_ALTURA!"+ AllTrim(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cAltura) +"|"+;   //5
					"B4A_IDADE!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cIdade+"|"+;                //6
					"B4A_SEXO!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cSexo+"|"+;                  //7
					"cFormNumber!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNumImp+"|"+;             //8 
					"B4A_PROATE!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cProtoc+"|<"               //9
		Else
			cResult +=	"B4A_REGANS!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cRegAns+"|"+;			//0
					"B4A_DATPRO!"+dtoc(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:dDtAut)+"|"+; 		//1
					"B4A_NOMUSR!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNomeUsr+"|"+;		        //2
					"B4A_USUARI!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cMatric+"|"+;      		//3
					"B4A_PESO!"+ AllTrim(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cPeso) +"|"+;       //4
					"B4A_ALTURA!"+ AllTrim(oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cAltura) +"|"+;   //5
					"B4A_IDADE!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cIdade+"|"+;                //6
					"B4A_SEXO!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cSexo+"|"+;                  //7
					"cFormNumber!"+oObj:OWSRETAUTLIBRESULT:OWSSCABGUI:cNumImp+"|<"              //8 
		EndIf

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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSCBTQ ³ Autor ³ Daher				     ³ Data ³ 28.03.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Procura a liberacao e mostra os dados						 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSCBTQ

LOCAL nI      	:= 0
LOCAL oObj	  	:= NIL
LOCAL lExibe  	:= .F.
LOCAL cResult 	:= "true|"
LOCAL cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUserCode 		 := "MSALPHA"
oObj:cChave   		 := HttpGet->cChkCpo
oObj:ccOpcao		 := HttpGet->cTab
oObj:ccCheckDePara	 := HttpGet->cCheckDePara
If !oObj:VldBTQChv()
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
Else
	cResult := "true|"+HttpGet->cCampoRef+"|"+oObj:OWSVldBTQChvRESULT:OWSSCABGUI:COBS
Endif

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSAUTANE ³ Autor ³ Daher				 ³ Data ³ 28.03.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Procura a liberacao e mostra os dados						 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSAUTANE()
LOCAL nI	  	:= 0
LOCAL nQtd		:= 0
LOCAL nPos	  	:= 0
LOCAL nPosRDA   := 0
LOCAL lPror		:= .F.
LOCAL cResult 	:= "true|"
LOCAL aMat 	  	:= {}
LOCAL oObj	  	:= Nil
LOCAL cString 	:= HttpGet->cString
LOCAL 	cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega o conteudo														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cString)
	While ( nPos := At( "|", cString ) ) > 0
	    AaDd( aMat,SubStr( cString, 1, nPos-1 ) )
	    cString := SubStr( cString, nPos+1, Len(cString) )
	EndDo
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi enviado algum registro para tratamento				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aMat) >= 2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro no WS														   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObj := WSPLSXFUN():New()
		WsChgURL( @oObj, "PLSXFUN.APW" )
		oObj:cUSERCODE := "MSALPHA"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta Matriz de itens ja executados									   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aMat) > 3

			oObj:oWSSAUTPROC:oWSAUTITEM := PLSXFUN_ARRAYOFAUTITEMVIEW():New()

		    For nI:=3 To Len(aMat)
		        If !Empty(aMat[nI])
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Monta dados dos itens												   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aMatIte := PPLSALIMA(aMat[nI]+'||')
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Alimenta a estrutura para envio dos procedimentos ja executados		   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					AaDd( oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW, PLSXFUN_AUTITEMVIEW():New() )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Quantidade de itens													   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nQtd := Len( oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atribui dados ao obj													   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cCODPAD 				:= AllTrim( PPLSERGET('B4C_CODPAD',aMatIte[1]) )
					oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cPROCEDURECODE 		:= AllTrim( PPLSERGET('B4C_CODPRO',aMatIte[1]) )
					oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:nPROCEDUREQUANTITY		:= Val( PPLSERGET('B4C_QTDPRO',aMatIte[1]) )
					oObj:oWSSAUTPROC:oWSAUTITEM:oWSAUTITEMVIEW[nQtd]:cSEQUENCE				:= aMat[1]
				EndIf
			Next
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Parametros de envio													   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObj:oWSSAUTPROC:cMatric 	:= HttpGet->cMatric
		oObj:oWSSAUTPROC:cTipGui 	:= HttpSession->cTp
		oObj:oWSSAUTPROC:dDatPro 	:= Date()
		oObj:oWSSAUTPROC:cSequen 	:= aMat[1]
		oObj:oWSSAUTPROC:cMatRet 	:= aMat[2]+"~"
		oObj:oWSSAUTPROC:cCid	 	:= HttpGet->cCid
		oObj:oWSSAUTPROC:cCodPad 	:= HttpGet->cCodPad
		oObj:oWSSAUTPROC:cCodPro 	:= HttpGet->cCodPro
		If ("," $ HttpGet->nQtdSol)
			nQtd := SEPARA(HttpGet->nQtdSol,",")[2]
			oObj:oWSSAUTPROC:nQtdPro 	:= Val(nQtd)
		Else
			oObj:oWSSAUTPROC:nQtdPro 	:= Val(HttpGet->nQtdSol)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa o metodo pega o retorno										   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oObj:AutAnexo()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se foi autorizado ou negado											   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    If oObj:oWSAutAnexoRESULT:lPROAUT
			   cResult += "1|"
			Else
			   cResult += "Critica(s)|"
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Matriz que retorna os resultados formatados campo a campo do formulario		 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cResult += oObj:oWSAutAnexoRESULT:cMatRetRes+"|"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta a string de retorno											   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cResult += oObj:oWSAutAnexoRESULT:cAUTORI+"|"+;
					   oObj:oWSAutAnexoRESULT:cCHAVE+"|"+;
					   oObj:oWSAutAnexoRESULT:cNIVEL+"|"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta as criticas													   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLPRANEXO ³ Autor ³ Daher			     ³ Data ³ 07.03.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa as Guias											 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLPRANEXO()
LOCAL nI,nY		  := 0
LOCAL nPos		  := 0
LOCAL oObj,oObjAux,oObjSex := NIL
LOCAL nIteAut     := 0
LOCAL nIteNeg     := 0
LOCAL nTmpDoe	  := 0
LOCAL nValTot	  := 0
LOCAL cResultCab  := "true|"
LOCAL cResultItem := ""
LOCAL cResultSenPr:= ""
LOCAL cEsp     	  := ""
LOCAL cNomeSol	  := ""
LOCAL cProExe     := ""
LOCAL cCodOpeExe  := ""
LOCAL cProSol     := ""
LOCAL cCodOpeSol  := ""
LOCAL cCid		  := ""
LOCAL cCid2		  := ""
LOCAL cCid3		  := ""
LOCAL cCid4		  := ""
LOCAL cCid5		  := ""
LOCAL cCbos		  := ""
LOCAL cTpCon 	  := ""
LOCAL cTpSai	  := ""
LOCAL cTpAteExe	  := ""
LOCAL cTpDoe	  := ""
LOCAL cTmpDoeC	  := ""
LOCAL cIndAcid	  := ""
LOCAL cNomeRda	  := ""
LOCAL cCnpjCpfSol := ""
LOCAL cCnesSol    := ""
LOCAL cCnesExe    := ""
LOCAL cCpfExe	  := ""
LOCAL cNumAut	  := ""
LOCAL cResult 	  := ""
LOCAL cTpAto	  := ""
LOCAL cTpFat 	  := ""
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
LOCAL cTpIntern	  := ""
LOCAL cRegInter	  := ""
LOCAL cOrigem	  := "2"
LOCAL cStatus 	  := "1"
LOCAL cGrPar      := ""
LOCAL cCodSig 	  := ""
LOCAL cNumCr	  := ""
LOCAL cEstado 	  := ""
LOCAL cNomfExe	  := ""
LOCAL cUsuProc    := ""
LOCAL cSexo       := ""
LOCAL cTpAcom	  := ""
LOCAL cPadCon	  := ""
LOCAL cQtdDSol	  := ""
LOCAL cCnpjSolT	  := ""
LOCAL cDadInt	  := ""
LOCAL cResAut	  := ""
LOCAL cIndCliEvo  := ""
LOCAL cNumPeg	  := ""
LOCAL cVia  	  := ""
LOCAL cAbrang	  := ""
LOCAL cNatur	  := ""
LOCAL cDesGRP	  := ""
LOCAL lFemini		:= .F.
LOCAL lProGe		:= .F.
LOCAL lExecu		:= .F.
LOCAL lChkReg		:= .T.
LOCAL lInter		:= .F.
LOCAL lEvolu		:= .F.
LOCAL lHonor		:= .F.
LOCAL lResInt		:= .F.
LOCAL aMatIte		:= {}
LOCAL aRetProf		:= {}
LOCAL cStProc	  	:= ""
LOCAL cAtendRN		:= ""
LOCAL cTissVer	:= HttpSession->RDAVIEW[1]:cTissVer
LOCAL nJ			:= 0
LOCAL aMatGrp		:= {}
Local lTemProc := cTissVer < '3.03.00' .OR. HttpSession->cTp != "08" //radioterapia não tem mais procedimentos a partir da tiss 3.03.00
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sessao para impressao da guia										   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->aResult := {}
HttpSession->lSen 	 := .F.

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUserCode		 := "MSALPHA"
oObj:cUserCardNumber := ""
oObj:cNumAut         := ""
oObj:cTipoAut        := "A"
oObj:cCampos         := "B4A_STATUS"
oObj:cTipo		     := HttpSession->cTp
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o box de um determinado campo									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:GetBox()
	aCBox := oObj:OWSGETBOXRESULT:OWSGENERICSTRUCT
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PLSXMOV																	 		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXMOV():New()
WsChgURL( @oObj, "PLSXMOV.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa a guia																	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE	:= "MSALPHA"				//Usuario
oObj:nAUTTYPE	:= val(HttpSession->cTp)			//Tipo de guia consulta,sadt,internacao,Odonto
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restante dos dados da guia														  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimenta a strutura ws com todos os itens do formulario genericamente   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:oWSAUTHORIZATION:oWSAUTITEM := PLSXMOV_ARRAYOFAUTITEMVIEW():New()

For nI:=1 To Len(aMatIte)

	AaDd( oObj:oWSAUTHORIZATION:oWSAUTITEM:oWSAUTITEMVIEW, PLSXMOV_AUTITEMVIEW():New() )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona na strutura ws												   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa Guia																	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:GravaAnexo()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somente na internacao															  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Rda,Nome rda,Nome produto,Servico formatado,Numero da autorizacao,Senha e total	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cResultCab +=	oObj:oWSGRAVAANEXORESULT:cNUMBER			+"|"+;	//0
			  		oObj:oWSGRAVAANEXORESULT:cPASSWORD		+"|"+;	//1
			  		DToC( Date() )									+"|"+;	//2
			  		DToC(oObj:oWSGRAVAANEXORESULT:dDtValSen)	+"|"+;  //3
			  		cDadInt+"||||||"						        //4
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procedimentos autorizados														  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    cResultA := ""
    cResultN := ""
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

		If (cCodTab+cCodPro) $ cUsuProc
			lProGe :=.T.
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Linha para retorno  em tela												  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cResultA += cSequen+"&nbsp;"+cCodTab+"-"+cCodPro+" - "+cDesPro+" - "+cQtdTot+"<br>";
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Guia de Prorrogacao Senhas dos procedimentos									  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cSenPro)
			cResultSenPr += cSenPro+"@"
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta matriz para impressao de guia									  			  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        AaDd( HttpSession->aResult,{cSequen,cCodTab,cCodPro,cDesPro,cDente,cFace,cQtdTot,{},cQtdUs,cData,cSenhaAu,cSenPro,cDesGRP,cStProc} )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se tem algum procedimento com senha									  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If !Empty(cSenPro)
			HttpSession->lSen := .T.
        EndIf
    Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procedimentos nao autorizados Obs (Nao precisa do if pq e a ultima implementacao) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Linha para retorno de em tela												  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cResultN += cSequen+"&nbsp;"+cCodTab+"-"+cCodPro+" - "+cDesPro+" - "+cQtdTot+"<br>";
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procedimentos criticados														  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    For nY:= 1 To Len(oObj:oWSGRAVAANEXORESULT:oWSERROR:oWSAUTERRORVIEW)
	        If oObj:oWSGRAVAANEXORESULT:oWSNOTAUTHORIZED:oWSAUTHORIZEDVIEW[nI]:cSequence == oObj:oWSGRAVAANEXORESULT:oWSERROR:oWSAUTERRORVIEW[nY]:cSequence

	            cCritica := WCTextNeg( oObj:oWSGRAVAANEXORESULT:oWSERROR:oWSAUTERRORVIEW[nY]:cCode+" - "+oObj:oWSGRAVAANEXORESULT:oWSERROR:oWSAUTERRORVIEW[nY]:cDescription )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta Linha para retorno em tela												  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cResultN +=	cCritica
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta matriz para impressao de guia									  			  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    			AaDd(aCritica,cCritica )
			EndIf
	    Next
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta matriz para impressao de guia									  			  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        AaDd( HttpSession->aResult,{cSequen,cCodTab,cCodPro,cDesPro,cDente,cFace,cQtdTot,aCritica,cQtdUs,cData,cSenhaAu,"",cDesGRP,cStProc} )
    Next
	Else
		nIteAut := 1
		nIteNeg := 0
		aCritica := {}
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta variaveis de sessao para impressao										  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina																	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna o valor de resposta da Session																	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Web Function PPLRESDOCG()
Return PLSDECODE("true|" + HttpSession->cResDoc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLINTERBE    ³ Autor ³ Thiago Guilherme	   ³ Data ³ 13/03/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 									                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLINTERBE()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mostra a pagina de procedimentos				 						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cHtml += ExecInPage( "PPLINTERABER" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLMATRIC    ³ Autor ³ Thiago Guilherme	   ³ Data ³ 13/03/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a matricula do beneficiario internado                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLMATRIC()
LOCAL cResult  	:= "true|"
LOCAL cRecno  := HttpGet->cRecno
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->cBtInterna := "1"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLRETINTR    ³ Autor ³ Thiago Guilherme	   ³ Data ³ 26/03/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Utilizado para controlar utilizacao do botao interna          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLRETINTR()

LOCAL cResult := "true|"
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->cBtInterna := "0"

WEB EXTENDED END

Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLB4DRGLO ³ Autor ³ Bruno Iserhardts     ³ Data ³ 14.05.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna informação o Recurso de Glosa para popular a guia     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLB4DRGLO()
Local cResult := ""
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacao do Recurso                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(HttpGet->cRecnoB4D) <> 'U'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ obj                                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObj := WSPLRECGLO():New()
	WsChgURL( @oObj, "PLRECGLO.APW" )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros																          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObj:cUSERCODE	:= "MSALPHA"
	oObj:cRecno	:= HttpGet->cRecnoB4D
	oObj:cVisDad	:= IIF(HttpGet->cOpc == "V","1","0") // se for somente visualizacao ou nao
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dados do Recurso                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oObj:GetRecGloB4D()
		cResult += "true|" + oObj:cGetRecGloB4DRESULT
	else
		cResult += "false"
	EndIf
Else
	cResult := "false"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLPROCRGL ³ Autor ³ Bruno Iserhardt      ³ Data ³ 20.05.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa a Guia de Recurso de Glosa								³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLPROCRGL()

LOCAL cResult := ""
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ obj                                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLRECGLO():New()
WsChgURL( @oObj, "PLRECGLO.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros																          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE	:= "MSALPHA"
oObj:cRecno	:= HttpPost->cRecnoB4D
oObj:cTipoGlosa	:= HttpPost->cTpRecGlo
oObj:cJustif	:= HttpPost->cMatJustif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados do Recurso                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:ProcJustfRecGlo()
	cResult += oObj:cProcJustfRecGloRESULT
else
	cResult += "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina																	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ	ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLCHARECG    ³ Autor ³Rogerio Tabosa	   ³ Data ³ 02.05.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chama determinado forumulario do atendimento					 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCHARECG()
LOCAL cHtml 	:= ""
LOCAL oObj	    := nil
LOCAL oObjRG    := nil
LOCAL nPosRda	:= 0
LOCAL cTISSVer	:= "3.01.00"
LOCAL cRda		:= ""
LOCAL cCodLoc	:= ""
LOCAL aRDA		:= {}
LOCAL nI		:= 0
LOCAL nY		:= 0
LOCAL cResult	:= ""
LOCAL lDiagno	:= ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aliemnta variavel de sessao											   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->cTp := "10"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a RDA e sua versão TISS						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CRIAR PAGINA PARA TISS 3.0													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTissVer >= "3"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ oBJ
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oObj := WSPLSXFUN():New()
	WsChgURL( @oObj, "PLSXFUN.APW" )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Parametros
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oObj:cUserCode	:= "MSALPHA"
	oObj:oWSGUIATISS:cTipGui		:= "10" // Guia de Recurso de Glosa
	oObj:oWSGUIATISS:cVerTiss	:= cTISSVer

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Aqui eu pego o que vem de Session executo aqui pra enviar a informaçao
	// pro WS pois o mesmo nao acessa o conteudo da Session	dificultando o dinamismo
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Retorna dados da pagina
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

Return cHtml


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLRGVLD ³ Autor ³ Rogerio Tabosa      ³ Data ³ 20.05.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida inclusao de  Recurso de Glosa								³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLRGVLD()
Local cResult := ""
Local cRda		:= ""
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ obj                                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLRECGLO():New()
WsChgURL( @oObj, "PLRECGLO.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros																          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE	:= "MSALPHA"
oObj:cRecno	:= HttpGet->cRecnoB4D
cRda			:= HttpGet->cRda
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados do Recurso                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:VldRecGlo()
	cResult += oObj:cVldRecGloRESULT
else
	cResult += "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina																	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLRGDEL ³ Autor ³ Rogerio Tabosa      ³ Data ³ 20.05.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cancela um recurso de Glosa	  								³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLRGDEL()
Local cResult := ""
Local cRda		:= ""
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ obj                                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLRECGLO():New()
WsChgURL( @oObj, "PLRECGLO.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros																          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE	:= "MSALPHA"
oObj:cRecno	:= HttpGet->cRecno
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados do Recurso                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:ExcRecGlo()
	cResult += oObj:cExcRecGloRESULT
else
	cResult += "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina																	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLTIPDOC    ³ Autor ³ Thiago Guilherme	    ³ Data ³ 09/01/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os tipos de documentos do reembolso no portal do
	beneficiario³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Web Function PPLTIPDOC()
LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//If HttpSession->MPortal == "000010"

oObj:cUserCode	:= "MSALPHA"
//oObj:cCUSRLOGIN	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE

//EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PRDAREF  ³ Autor ³ Tabosa               ³ Data ³ 20.01.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a RDA nao referenciada BK6 ao digitar o CPF/CNPJ   	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Web Function PRDAREF()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL 	cHtml := ""
Local cMatric	:= ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cCpfCnpj		:= HttpGet->cProSaud
oObj:cMatric		:= SubStr(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CBENEFI,1,14)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:RDARef()
	cResult += oObj:cRDARefRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLGETCMP   ³ Autor ³ Thiago Ribas       ³ Data ³ 18.03.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna os campos do grid                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Recupera nome do grid
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//Adiciona os campos da Grid
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		AaDd( aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:OWSSCmpGrid, PLSXFUN_SCMPGRID():NEW() )
		aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[nI]:cTipo := IIf(Len(aCpoAtu) >= 3,aCpoAtu[3],"C")
		aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[nI]:cNome := aCpoAtu[1]
		aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[nI]:cDescri := aCpoAtu[2]
	Next nI
	HttpSession->aCmpGuia := aClone(aObjSess[nPos]:OWSSCMPGUIA)
EndIf

//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Encontra o objeto no array de campos
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
nPos := aScan( HttpSession->aCmpGuia, { |x| x:cNome == cGrid} )

//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Monta o aCols e aHeader
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nPos > 0

	cResult := "true|" +	 cGrid + "|" + nOpc + "|["
	nLen := len(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID)

	For nI := 1 to nLen
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Verifica se foi informado funcao de tratamento na linha
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		cResult += "'" + alltrim(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID[nI]:CNOME) + "'" + Iif( nLen != nI ,",","]|" )
	Next nI
	cResult += + cRecno + "|" + lBotao + "|" + cSt + "|"  + cValores + "|" + cCampoDefault + "|" + cLarBrw + "|" + cAltBrw + "|" + cUpdReg + "|" + cNoLpCamp + "|"
Else
	cResult := "false|Não foi encontrado o grid especificado!"
EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLGETGRID  ³ Autor ³ Rogerio Tabosa       ³ Data ³ 18.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Responsável pela manipulação dos grids das Guias no Portal     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
// HttpSession->aCmpGuia -> Guarda todos os campos/grids da Guia
// HttpSession->aCmpGuia[nPos] -> Trata-se da referência a um campo ou grid
//
// HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING -> aHeader do Grid
// HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING -> aCols do Grid
//
// xCols e xHeader são as strings que o JSPLS usará para montar o grid
// aCols e aHeader são os arrays que serão utilizados para manipular os campos
//por esta função
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Recupera dados da página
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Encontra o objeto no array de campos
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
nPos := aScan( HttpSession->aCmpGuia, { |x| x:cNome == cGrid} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Monta o aCols e aHeader
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nPos > 0

	aHeader	:= HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING
	aCols		:= HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//Verifica se o aCols e aHeader estão vazios
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If ValType(aHeader) <> 'A'
		aHeader := {}
		HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING := {}
	EndIf
	If ValType(aCols) <> 'A'
		aCols := {}
		HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING := {}
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//Adiciona no aCols ou Posiciona na linha da alteração
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//Exclui registro
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			If Len(aCols) > 0
				aDel(aCols,nPosCols)
				aSize(aCols,Len(aCols)-1)
				aDel(aHeader,nPosCols)
				aSize(aHeader,Len(aHeader)-1)
			EndIf

		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//Inicia o xHeader e o xCols
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			xHeader := "["

			If 	Empty(HttpSession->aCmpGuia[nPos]:CXCOLS)
				xCols := "[{"
			Else
				xCols := HttpSession->aCmpGuia[nPos]:CXCOLS
				xCols := Left(xCols,Len(xCols)-1) + ",{"
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//Adiciona os botões da linha e coloca o Recno
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			If cUpdReg == "0"
				xHeader += "{name:'Excluir'},"
				xCols += "0:{field:'RECNO', value:'0#" + AllTrim(Str(nPosCols)) + "," + cGrid + ".id,5,undefined,undefined,undefined,undefined,undefined,undefined, undefined, (0).toString()'},"

			Else
				xHeader += "{name:'Alterar'},"
				xCols += "0:{field:'RECNO', value:'0#" + AllTrim(Str(nPosCols)) + "," + cGrid + ".id,4'},"
				xHeader += "{name:'Excluir'},"
				xCols += "1:{field:'RECNO', value:'1#" + AllTrim(Str(nPosCols)) + "," + cGrid + ".id,5'},"
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//Monta xHeader e xCols
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			nLen := len(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID)
			nLenVal := len(aValores)
			For nI := 1 to nLenVal
				aLinha := Separa(aValores[nI],",",.F.)
				For nJ := 1 to nLen

					cCampo  := alltrim(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID[nJ]:CNOME)
					cTitulo := alltrim(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID[nJ]:CDESCRI)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³ Verifica se o campo já tem algum valor
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					nPosVal := aScan(aLinha , { |x| cCampo $ x } )
					If nPosVal > 0
						cValor	 := Separa(aLinha[nPosVal],"$",.T.)[2]
					Else
						cValor := ""
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³ Cabecalho
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//Se for alteração, reconstroi o xCols
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If nOpc == 4 .OR. nOpc == 5

		xHeader := "[{name:'Excluir'},"

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//Monta xHeader e xCols
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			nLen := len(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID)
			nLenVal := len(aValores)
			For nI := 1 to nLenVal
				For nJ := 1 to nLen

					cTitulo := alltrim(HttpSession->aCmpGuia[nPos]:OWSCMPGRID:OWSSCMPGRID[nJ]:CDESCRI)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³ Cabecalho
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//Adiciona o xHeader e xCols ao array da session
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLPUTREEMB  ³ Autor ³ Tabosa               ³ Data ³ 20.01.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Istancia o webservice para gravacao da solicitacao de reemb    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Web Function PLPUTREEMB()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL nI			:= 0
LOCAL nSumTot		:= 0
LOCAL Arda			:= {}
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atribui dados ao obj													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:PutReembBen()
	cResult += oObj:cPutReembBenRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLCONREE   ³ Autor ³ Tabosa               ³ Data ³ 20.01.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da Rotina de Reembolso Portal beneficiario			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCONREE()
LOCAL cHtml 	:= ""
LOCAL cResult	:= ""
LOCAL oObjPar := nil

PRIVATE lMultComp	:= "false"
PRIVATE lBaixar	:= "0"
PRIVATE cCodSol := iif(valtype(HttpGet->cCodSol) <> "U", HttpGet->cCodSol, "")

PRIVATE cRDA := iif(valtype(HttpGet->cRdaNoRef) <> "U", HttpGet->cRdaNoRef, "") 
PRIVATE cNomePres := iif(valtype(HttpGet->cNomePres) <> "U", HttpGet->cNomePres, "")
PRIVATE cTipDoc := iif(valtype(HttpGet->cTipDoc) <> "U", HttpGet->cTipDoc, "")
PRIVATE cNumDoc := iif(valtype(HttpGet->cNumDoc) <> "U", HttpGet->cNumDoc, "")
PRIVATE cDatDoc := iif(valtype(HttpGet->cDatDoc) <> "U", HttpGet->cDatDoc, "")
PRIVATE cRecno := iif(valtype(HttpGet->cRecno) <> "U", HttpGet->cRecno, "")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe pagina															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WEB EXTENDED INIT cHtml START "InSite"

	oObjPar := WSCFGDICTIONARY():New()
	WsChgURL( @oObjPar, "CFGDICTIONARY.APW" )
					
	oObjPar:cUSERCODE	:= "MSALPHA"
	oObjPar:cMVPARAM	:= "MV_PLREEMC"
	
	If oObjPar:GETPARAM()
		lMultComp := oObjPar:cGETPARAMRESULT
		If ValType(lMultComp) == 'U'
			lMultComp := "false"
		ElseIf	ValType(lMultComp) == 'C'
			If Type(lMultComp)=="L"
				If &(lMultComp)
					lMultComp := "true"
				Else
					lMultComp := "false"
				EndIf
			EndIf
		EndIf
	EndIf
	
	oObjPar:cMVPARAM	:= "MV_PLPDWN"
	If oObjPar:GETPARAM()
		lBaixar := oObjPar:cGETPARAMRESULT
		If ValType(lBaixar) == 'U'
			lBaixar := "0"
		ElseIf	ValType(lBaixar) == 'C'
			If Type(lBaixar)=="L"
				If &(lBaixar)
					lBaixar := "1"
				Else
					lBaixar := "0"
				EndIf
			EndIf
		EndIf
	EndIf

cHtml += ExecInPage("PPLCONREE")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLGDGRID³ Autor ³ Totvs 				 | Data ³ 24.01.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna dados para o browse gridData							 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGDGRID()
LOCAL cResult  	:= "true|"
LOCAL cRdas		:= ""
LOCAL cUsuarios	:= ""
LOCAL oObj			:= NIL

LOCAL nI		:= 0
LOCAL nLen		:= IIf(Valtype(HttpSession->RDAVIEW) == "A", Len(HttpSession->RDAVIEW), 0 ) //Tratamento para a existencia das RDAs (a função eh chamada antes do login para consulta rede credenciada)
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Metodo e propriedades
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//HttpSession->RDAVIEW
For nI := 1 to nLen
	If !Empty(cRdas)
		cRdas += ","
	EndIf
	cRdas += "'" + HttpSession->RDAVIEW[nI]:cCodOpe + HttpSession->RDAVIEW[nI]:cCode +"'"
Next nI
//Tratamento para a existencia das RDAs (a função eh chamada antes do login para consulta rede credenciada)
If nLen > 0
	httpGet->cWhere += "|"+"Field_RDA=" + cRdas
EndIf
If Len(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA) > 0 //Essa verificação foi inserida, para casos em que o usuário logado ainda não é beneficiário
	// Beneficiario Logado (Portal do beneficiario) --> Pega o principal pois tem apenas um login
	If ValType(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA) == "A"
		If ValType(httpGet->cUsuari) <> 'U'
			httpGet->cWhere += "|"+"Field_USUARI=" + httpGet->cUsuari

		Else
			For nI := 1 to Len(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA)
				If !Empty(cUsuarios)
					cUsuarios += ","
				EndIf
				cUsuarios += "'" + HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[nI]:cCode +"'"
			Next nI
			httpGet->cWhere += "|"+"Field_USUARI=" + cUsuarios
		EndIf
	EndIf
EndIf
oObj:cUserCode	:= "MSALPHA"
oObj:cFunName	:= httpGet->cFunName
If Type('HTTPSESSION->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:CCODE') == "U"
	oObj:cWhere 	:= httpGet->cWhere
else
	oObj:cWhere	:= httpGet->cWhere// + HTTPSESSION->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:CCODE
EndIf
oObj:cBuscaTReg	:= httpGet->cBuscaTReg
oObj:cPesquisa	:= iIf(valType(httpGet->cPesquisa)=='U',"",httpGet->cPesquisa)
oObj:cSemaforo	:= iIf(valType(httpGet->cSemaforo)=='U',"",httpGet->cSemaforo)
oObj:nPaginaIni	:= val(httpGet->nPagina)
oObj:cCamposCustom := iIf(valType(httpGet->cCampoCustom)=='U',"",httpGet->cCampoCustom)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Lista de faturas
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:getDadGrid()
	cResult +=	oObj:cGETDADGRIDRESULT
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLOBSPRT    ³ Autor ³ Thiago Guilherme	   ³ Data ³ 13/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a observação do protocolo selecionado             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLOBSPRT()
LOCAL cResult  	:= "true|"
LOCAL cRecno  := HttpGet->cRecno
LOCAL nResult
LOCAL nI
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLMSGEXC    ³ Autor ³ Thiago Guilherme	   ³ Data ³ 13/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o motivo da exclusão do item no protocolo             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLMSGEXC()
LOCAL cResult  	:= "true|"
LOCAL cRecno  := HttpGet->cRecno
LOCAL nResult
LOCAL nI
LOCAL cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:CcRecno	:= cRecno

If oObj:ExcItmReemb()

	xCols :=  oObj:OWSEXCITMREEMBRESULT:OWSSRETITEEX[1]:CcMsg
	cResult += xCols + "|"
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLEXCREE    ³ Autor ³ Rogerio Tabosa	      ³ Data ³ 18/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclui um item ou um reembolso 								     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLEXCREE()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL cChave		:= iif(valtype(httpget->cChave) <> "U", httpget->cChave, "")
LOCAL cRecno		:= iif(valtype(httpget->cRecno) <> "U", httpget->cRecno, "")
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:ccRecno		:= cRecno
oObj:cAlias		:= HttpGet->cAlias
oObj:cChave		:= cChave

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:ReembDelPI()
	cResult := oObj:cReembDelPIRESULT
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLRMBREC   ³ Autor ³ Tabosa               ³ Data ³ 20.01.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da Rotina de Reembolso Portal beneficiario			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLRMBREC()
LOCAL cHtml 	:= ""
LOCAL cResult	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe pagina															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLRMBREC")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PPLATUBOW  ºAutor  ³Totvs               º Data ³  20/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza BOW						   		    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PPLATUBOW()
LOCAL cResult  	:= "true|"
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:CUsrCod	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE

If !oObj:AtuBow()
	cResult := "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLGETEST    ³ Autor ³ Thiago Guilherme	    ³ Data ³ 09/01/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os estados brasileiros no portal

±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGETEST()
LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cTipo			:= HttpGet->cTipo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLRETGEN    ³ Autor ³ Rogerio Tabosa	      ³ Data ³ 18/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os dados de uma tabela qualquer passada por param     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLRETGEN()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cCRecno		:= HttpGet->cRecno
oObj:cAlias		:= HttpGet->cAlias
oObj:cCampos		:= HttpGet->cCampos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:GetDadGen()
	cResult := oObj:cGetDadGenRESULT
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLEXPSEN   ³ Autor ³ Totvs                ³ Data ³ 20.05.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se exibe mensagem de Expirar Senha				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLEXPSEN()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cPLSCodUsr	:= getUsrWeb()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:SenhaExp()
	cResult := oObj:cSenhaExpRESULT
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLDESPRO  ³ Autor ³ Thiago               ³ Data ³ 20.01.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a descrição do procedimento a partir do codigo   	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Web Function PPLDESPRO()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cCodPro		:= HttpGet->cCodPro
oObj:cClasse		:= HttpGet->cClasse

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:DesProc()
	cResult += oObj:cDesProcRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PTrGdLib    ³ Autor ³ Rogerio Tabosa	      ³ Data ³ 18/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Trata a session de valores do grid ao chamar uma liberação    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

LOCAL cResult  	:= ""
LOCAL xHeader 	:= "[{}]"
LOCAL xCols		:= ""

//Variaveis a utilizar posteriormente
LOCAL cPesquisa	:= ""
LOCAL cMsg			:= ""

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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Encontra o objeto no array de campos
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
nPos := aScan( HttpSession->aCmpGuia, { |x| x:cNome == cGrid} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//Monta o aCols e aHeader
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nPos > 0

	aHeader	:= HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING
	aCols	:= HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//Verifica se o aCols e aHeader estão vazios
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If ValType(aHeader) <> 'A'
		aHeader := {}
		HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING := {}
	EndIf
	If ValType(aCols) <> 'A'
		aCols := {}
		HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING := {}
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//Adiciona no aCols ou Posiciona na linha da alteração
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//Exclui registro
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			If Len(aCols) > 0
				aDel(aCols,nPosCols)
				aSize(aCols,Len(aCols)-1)
				aDel(aHeader,nPosCols)
				aSize(aHeader,Len(aHeader)-1)
			EndIf

		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//Inicia o xHeader e o xCols
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			xHeader := "["

			If 	Empty(HttpSession->aCmpGuia[nPos]:CXCOLS)
				xCols := "["
			Else
				xCols := HttpSession->aCmpGuia[nPos]:CXCOLS
				xCols := Left(xCols,Len(xCols)-1) + ","
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//Monta xHeader e xCols
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						//Adiciona os botões da linha e coloca o Recno
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³ Verifica se o campo já tem algum valor
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³ Cabecalho
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//Se for alteração, reconstroi o xCols
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//Adiciona o xHeader e xCols ao array da session
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	HttpSession->aCmpGuia[nPos]:CXHEADER := xHeader
	HttpSession->aCmpGuia[nPos]:CXCOLS   := xCols
	HttpSession->aCmpGuia[nPos]:OWSAHEADER:CSTRING := aClone(aHeader)
	HttpSession->aCmpGuia[nPos]:OWSACOLS:CSTRING := aClone(aCols)
EndIf

Return

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PVldNGui
Verifica se a guia principal digitada existe

@Project
@version	P12

/*/
//---------------------------------------------------------------------------------------
Web Function PVldNGui()
Local cResult := ""
Local oObj    := Nil
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUSERCODE 	:= "MSALPHA"
oObj:cTipGui	:= HttpGet->TipGui
oObj:cNumAut   := StrTran(StrTran(HttpGet->NumAut,".",""),"-","")

If oObj:VLNUMGUI()
	cResult := oObj:CVLNUMGUIRESULT
Else
	cResult :=  "false|Erro na tentativa de localizar a guia!"
EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLDOC ³ Autor ³ TOTVS              ³ Data ³ 13/05/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta o(s) contrato(s) e/ou aditivo(s)    		    		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLDOC()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLDOC")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLDELAT    ?Autor ?Karine Riquena	      ?Data ?27/11/14 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ?Exclui o atalho da barra de atalhos do portal                 ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLDELAT()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL nI := 1
LOCAL nTamI
LOCAL aAtalho     := {}
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

aAtalho := HttpSession->ATAVIEW
nTamI := Len(aAtalho)
lAchou := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
oObj:cUserCode	:= "MSALPHA"
oObj:cCodMenu		:= HttpGet->cCodMnu
oObj:cUsrCod		:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLGETIMG  ?Autor ?Karine Riquena        ?Data ?02.12.2014 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ?Diretório de imagens do servidor 								    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WEB FUNCTION PPLGETIMG(cCodMnu)
LOCAL cResult  := "true|"
LOCAL cDir	 	:= getWebDir()
LOCAL aFiles	:= {}
LOCAL nI := 0
LOCAL nTpPor	:= 0
LOCAL cMenu := HttpGet->cCodMnu
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

nTpPor	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:nTpPortal

If !Empty(cDir)
    //verificar tipo de portal do usuario logado
    If nTpPor == 1
		cDir := cDir + getPrtSkin() + "\atalhos_portal\prestador\"
	Else
	    cDir := cDir + getPrtSkin() + "\atalhos_portal\empbenef\"
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Le diretorio para mostrar os arquivos disponiveis
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Fim da rotina														   ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLADDAT    ?Autor ?Karine Riquena	      ?Data ?27/11/14 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ?Adiciona o atalho da barra de atalhos do portal                 ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLADDAT()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL nI
LOCAL nTamI
LOCAL aString
LOCAL nCount := 0
LOCAL nNewTamI
LOCAL nTamY
LOCAL nY := 0
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
oObj:cUserCode	:= "MSALPHA"
oObj:cCodMenu		:= HttpGet->cCodMnu
oObj:cUsrCod		:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
oObj:cCamImg      := HttpGet->cCamImg
oObj:nCodPor      := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:nTpPortal
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//?Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLCADGEN    ³ Autor ³ Rogerio Tabosa	   ³ Data ³ 02.02.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pagina de cadastro de paginas genericas						   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCADGEN()
LOCAL cHtml 	:= ""
LOCAL oObj	    := nil
LOCAL oObjRG    := nil
LOCAL nI		:= 0
LOCAL nY		:= 0
LOCAL nJ 		:= 0
LOCAL cResult	:= ""
LOCAL cLayout	:= ""
LOCAL cRecno  := ""
LOCAL xCols   := ""
LOCAL xHeader := ""
LOCAL cChave := Alltrim(HttpGet->cChave)

WEB EXTENDED INIT cHtml START IIF(cChave == "PLSCREDPF" .OR. cChave == "PLSCREDPJ", "","InSite")

HttpSession->xDataAux := IIF( ValType( HttpGet->cDataAux ) == "C", HttpGet->cDataAux, "")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLCADWEB():New()
WsChgURL( @oObj, "PLCADWEB.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ValType(HttpGet->cChave) <> "U"  //nas versoes 3.xx.xx esse cara vem preenchido
	cLayout := Alltrim(HttpGet->cChave)
EndIf

If ValType(HttpGet->cRecno) <> "U"  //nas versoes 3.xx.xx esse cara vem preenchido
	cRecno := Alltrim(HttpGet->cRecno)
EndIf

oObj:cUSERCODE	:= "MSALPHA"
oObj:oWSDataForm:cChaveLay	:= cLayout // Unidade de medida
oObj:oWSDataForm:cRecnoReg := cRecno

If oObj:GetCmbForm()
	// ATRIBUO OS PARAMETROS NOVAMENTE PARA UTILIZAÇÃO DO PROXIMO METODO
	oObj:cUserCode	:= "MSALPHA"
	oObj:oWSDataForm:cChaveLay	:= cLayout // Unidade de medida
	oObj:oWSDataForm:cDadCombo	:= ""
	oObj:oWSDataForm:cRecnoReg := cRecno
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
 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Retorna dados da pagina
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//Verifica se o aCols e aHeader estão vazios
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

cHtml += ExecInPage("PPLCADGEN")

WEB EXTENDED END

Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCONPRO ³ Autor ³ TOTVS                 ³ Data ³ 27/05/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta o(s) protocolos de indicações de profissionais  	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCONPRO()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLCONPRO")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLSolCon 	  ³ Autor ³ Oscar Zanin     ³ Data ³ 30.06.2015	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ Ä´±±
±±³Descri‡„o ³ Chamada da Página de Solicitação de alteração contratual		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSolCon()

LOCAL cHtml := ""

local cCodRda	:= httpget->cRDACod

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->CodRDAsolCon := StrZero(Val(cCodRda), 6)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLSOLCONTR")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLGRVGEN   ³ Autor ³ Totvs                ³ Data ³ 20.03.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se exibe mensagem de Expirar Senha				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGRVGEN()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL aAux			:= {}
LOCAL aAux2		:= {}
LOCAL aGrids		:= {}
LOCAL aHeader		:= {}
LOCAL aCols		:= {}
LOCAL nI			:= 0
LOCAL nL			:= 0
LOCAL nR			:= 0
LOCAL cAliAtu		:= ""
LOCAL aDadGri		:= {}
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLCADWEB():New()
WsChgURL( @oObj, "PLCADWEB.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
		oObj:oWSDataInput:oWSDados:oWSSCmpVlr[nI]:cValor := &("HttpPost->" + aAux[nI]) // macro do campo que veio do post
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

HttpSession->xDataAux := ""

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLVIEWRDA ³ Autor ³ Karine Riquena Limp  ³ Data ³ 23/06/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se RDA possui mais de uma RDA.   		    		    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLVIEWRDA()

LOCAL cHtml := ""
LOCAL cResult := "true|"
LOCAL nI := 0

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If ValType(HttpSession->RDAVIEW) <> "U"
	If len(HttpSession->RDAVIEW) > 1
		cHtml += 	"<label>RDA</label>"
		cHtml += 	"<select id='cRdaRec' name='cRdaRecno' class='form-control TextoInputOB ComboSelectOB'>"
		cHtml += 		"<option value='SELECTED'>-- Selecione uma RDA --</option>"

						//Preciso pegar o tipo de pessoa (fisica ou juridica) para redirecionar para o layout certo
						For nI:=1 To Len( HttpSession->RDAVIEW )
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
							//³Nao inclui registro duplicado
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLENVADT	 ³ Autor ³ TOTVS      	        ³ Data ³ 13/05/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta o(s) contrato(s) e/ou aditivo(s)    		    		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PLENVADT()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->RetSeqACad := HttpGet->cCodSeq
HttpSession->RetMotACad := HttpGet->cMotivos
HttpSession->RetRDAACad := HttpGet->cCodRDA
HttpSession->RetcTipo   := HttpGet->cTipo

HttpSession->RecnoManBen := IIf(HttpGet->cRecno == NIL, "", HttpGet->cRecno)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLADT")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLGRTEST 	  ³ Autor ³ Oscar Zanin     ³ Data ³ 30.06.2015	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ Ä´±±
±±³Descri‡„o ³ Upload de arquivo através da Grid									 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGRTEST()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
Local cRecno		:= ""
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cCRecno		:= cRecno
oObj:cCArquivo	:= HttpGet->cDirArq
oObj:cCCodRda	 	:= Httpget->cCodRDA
oObj:cChave		:= HttpGet->cCodSeq
oObj:cAlias		:= "B98"
oObj:cIndice		:= "1"
oObj:lLIncRap	:= .T.

HttpSession->cUpload := "Vazio"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:UplConhec()
	cResult += oObj:cUplConhecRESULT
	
	HttpSession->cUpload := cResult
Else
	
	HttpSession->cUpload := ""
	cResult := "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

//----
Web Function PPLCONADT()

LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
Local cRecno		:= ""
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cCCodRda	 	:= HttpGet->cCodRDA
oObj:cChave		:= HttpGet->cCodSeq

HttpSession->cResDoc := "Vazio"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:ConSolAdt()
	cResult += oObj:cConSolAdtRESULT
	
Else
	
	cResult := "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLSTBEN 	  ³ Autor ³ Roberto Vanderlei  ³ Data ³ 08.12.2015	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ Ä´±±
±±³Descri‡„o ³ Atualizar status da solicitação para em análise.	 			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSTBEN()

LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
Local cRecno	:= ""
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
//oObj:cCCodRda	 	:= HttpGet->cCodRDA
oObj:cChave		:= HttpGet->cCodSeq
oObj:cModo      := "1"
HttpSession->cResDoc := "Vazio"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:AltStBen()
	cResult += oObj:cAltStBenRESULT
	
Else
	
	cResult := "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLRESUPL 	  ³ Autor ³ Oscar Zanin     ³ Data ³ 30.06.2015	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ Ä´±±
±±³Descri‡„o ³ Retorna o valor de resposta da Session							³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLRESUPL()

Local cTeste := ""
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

If Valtype(HttpSession->cUpload) == "C"
	cTeste := HttpSession->cUpload
EndIf

WEB EXTENDED END

Return PLSDECODE("true|" + cTeste)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLGRVADT 	  ³ Autor ³ Oscar Zanin     ³ Data ³ 30.06.2015	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ Ä´±±
±±³Descri‡„o ³ Alimentar Browse com os documentos vinculados à solicitação	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGRVADT()

LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
Local cRecno		:= ""
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cObserv		:= IIf(Valtype(HttpGet->cObserv) == "U", "", HttpGet->cObserv)
oObj:cCodSol		:= IIF(Valtype(HttpGet->cCodSol) == "U", "", HttpGet->cCodSol)
oObj:cCCodRda	 	:= IIf(ValType(httpGet->cCodRDA) == "U", "", HttpGet->cCodRDA)

HttpSession->cResDoc := "Vazio"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:GrvSolAdt()
	cResult += oObj:cGrvSolAdtRESULT
	HttpSession->cResDoc := cResult
Else
	HttpSession->cResDoc := ""
	cResult := "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCONSCON ³ Autor ³ TOTVS              ³ Data ³ 13/05/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta o(s) contrato(s) e/ou aditivo(s)    		    		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCONSCON()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLCONSCON")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLRMBCAL   ³ Autor ³ Thiago Ribas         ³ Data ³ 08.06.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da Rotina de Calendário de reembolso
			   no Portal beneficiario			 							 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCALREE()
LOCAL cHtml 	:= ""
LOCAL cResult	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe pagina															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLCALREE")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLRECEI    ³ Autor ³ Thiago Guilherme	   ³ Data ³ 13/03/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rastrear receita				                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLRECEI()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mostra a pagina de procedimentos				 						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml += ExecInPage( "PPLRASTRE?codRec=" + HttpGet->codRec )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLPEPREST  ³ Autor ³Everton M Fernandes   ³ Data ³ 15.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da pagina de listagem dos prestadores por plano       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLPEPREST()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUSERCODE	:= "MSALPHA"

If oObj:getProdutos()
	HttpSession->aProdutos := oObj:oWSGETPRODUTOSRESULT:oWSPRODUTOSLIST
EndIf

//Mostra a pagina para entrar com o protocolo/Guia

cHtml := ExecInPage( "PPLPEPREST" )

WEB EXTENDED END

//Fim da rotina
Return cHtml


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLCBCDRDA 	  ³ Autor ³ Oscar Zanin     ³ Data ³ 30.06.2015	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ Ä´±±
±±³Descri‡„o ³ Abre combo para selecionar RDA ao acessar a rotina				³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCBCDRDA()

LOCAL cHtml := ""
LOCAL cResult := "true|"
LOCAL nI := 0

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If ValType(HttpSession->RDAVIEW) <> "U"
	If len(HttpSession->RDAVIEW) > 1
		cHtml += 	"<label>RDA</label>"
		cHtml += 	"<select id='cRDACod' name='cCoidigoRDA' class='form-control TextoInputOB ComboSelectOB'>"
		cHtml += 		"<option value='SELECTED'>-- Selecione uma RDA --</option>"

						For nI:=1 To Len( HttpSession->RDAVIEW )
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
							//³Nao inclui registro duplicado
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLGETSIGLACR    ³ Autor ³ Totvs       	    ³ Data ³ 17/07/15³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna as siglas C.R. do profissional
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGETSIGLACR()
LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cTipo			:= HttpGet->cTipo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

Return PLSDECODE(cResult)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCorpoClinico ³ Autor ³ TOTVS           ³ Data ³ 14/07/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Corpo Clinico da RDA selecionada        )    		    		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCORPOCLI ()
LOCAL cHtml := ""
PRIVATE aDocs := {}
PRIVATE lPrestTiss := .T.

WEB EXTENDED INIT cHtml START "InSite"

//Carregar documentos cadastrados para o corpo clínico

oObj := WSPLSXFUN():New()

WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUSERCODE	:= "MSALPHA"

If oObj:GetDocCorpoCli()
	aDocs := oObj:OWSGETDOCCORPOCLIRESULT:OWSSDOCS
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLCORPOCLI")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLDEPREST 	  ³ Autor ³ Rogerio Tabosa       ³ Data ³ 07.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada para retornar os detalhes do prestadot                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLDEPREST()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUSERCODE	:= "MSALPHA"
oObj:cRecnoBB8	:= HttpGet->cRecnoBB8

If oObj:GetPrestBB8()
	cHtml := "true|"
	HttpSession->cArrPrest := oObj:cGetPrestBB8RESULT
EndIf

WEB EXTENDED END

//Fim da rotina
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCAUTZ  ³ Autor ³ Renan Martins        ³ Data ³ 04.03.2015  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Abre pág. de consulta de status de autorização (beneficiário) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCAUTZ()
LOCAL cHtml	:= ""
LOCAL oObj  := NIL
Local nI		:= 0

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE	:= "MSALPHA"
oObj:cCampos 	:= "BEA_TIPO"
oObj:cShowAnexo	:= "1"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o box de um determinado campo									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(HttpSession->aTpGuia) == 'U'
	If oObj:GetBox()
		HttpSession->aTpGuia := oObj:OWSGETBOXRESULT:OWSGENERICSTRUCT
	EndIf
EndIf

cHtml += ExecInPage( "PPLCSAUT" )

WEB EXTENDED END

Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLDETPRES     ³ Autor ³Everton M Fernandes³ Data ³ 15.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da pagina para visualizar o detalhe do prestador      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLDETPRES()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mostra o detalhamento do prestador                					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml := ExecInPage( "PPLDETPRES" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPLSACR
Web Function da pagina PPLSACR.aph

@Project	TTQLAU
@author	Lucas de Azevedo Nonato
@since		29/10/2015
@version	P12
@Return	L
/*/
//---------------------------------------------------------------------------------------
Web Function PPLSACR()
Local cHtml   	:= ""
Local oWs

WEB EXTENDED INIT cHtml START "InSite"

If !Empty(HttpPost->cCodRda)
	oWs := WSPLSXFUN():New()
	oWs:cUSERCODE	:= "MSALPHA"
	oWs:cCODRDAACR 	:= HttpPost->cCodRda

	If oWs:ACREDITACOES()
		HttpSession->Acreditacoes := aClone(oWs:OWSACREDITACOESRESULT:OWSSACREDIT)
	EndIf
EndIf
	
cHtml := ExecInPage("PPLSACR")

WEB EXTENDED END
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLGRANXB 	  ³ Autor ³ Renan ALmeida     ³ Data ³ 30.06.2015    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ Ä´±±
±±³Descri‡„o ³ Upload de arquivo através da Grid									 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGRANXB()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
Local cNomArq		:= ""
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cCArquivo	:= HttpGet->cDirArq
oObj:cChave		:= Substr(Httpget->cChavP, 1, Len(Httpget->cChavP)-3)
oObj:cAlias		:= Right(Httpget->cChavP,3)
oObj:llIncRap		:= .T.

HttpSession->cUpload := "Vazio"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:UplConhec()
	cResult += oObj:cUplConhecRESULT
	
	HttpSession->cUpload := cResult
Else
	
	HttpSession->cUpload := ""
	cResult := "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSGRVITE ³ Autor ³ Roberto Vanderlei    ³ Data ³ 09.04.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Montar HTML para resposta da Iteração  							³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSGRVITE()
//1
local cResult := "true|"
local cChave 		:= IIF(!EMPTY(HttpSession->cChave),HttpSession->cChave,HttpGet->cChave)
local cChaveInt 	:= IIF(!EMPTY(HttpSession->cChaveInt),HttpSession->cChaveInt, HttpGet->cChaveInt)
local cResposta	:= StrTran(HttpGet->cResposta, "[ENTERz]", chr(10))
//variavel que identifica se ainda há interações pendentes para alterar o status da guia
//quando não houver mais nenhuma interação pendente (lPendente false) podemos alterar o status da guia
local lPendente	:= valtype(HttpGet->lPendente) <> "U" .and. HttpGet->lPendente == "true"
local cPublico	:= iif(valtype(HttpGet->cPubl) <> "U",  HttpGet->cPubl, "")
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
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

return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLGETENDER    ³ Autor ³ Totvs       	    ³ Data ³ 17/07/15³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna as siglas C.R. do profissional
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGETENDER()
LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cCCodRDA			:= HttpGet->cCodRDA
If ValType(HttpGet->cCodLoc)<>"U"
	oObj:cCCodLoc			:= HttpGet->cCodLoc
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

Return PLSDECODE(cResult)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLESPEC    ³ Autor ³ Rodrigo Morgon     	    ³ Data ³ 26/08/15³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLESPEC()
LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cCCodRDA		:= HttpGet->cCodRDA
oObj:cCodLoc		:= HttpGet->cCodLoc
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

Return PLSDECODE(cResult)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSMNTITE ³ Autor ³ Roberto Vanderlei    ³ Data ³ 09.04.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Montar HTML para exibição das Iterações  						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSMNTITE()

LOCAL cHtml := ""
local cResult := "true|"
local nI
local cChave
local cResposta
Local cVerifica
Local cTipoGuia

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//cVerifica := HttpGet->cVerif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro no WS														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oObj:cUSERCODE 			:= "MSALPHA"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oObj:oWSITEDAD:cALIMOV		:= HttpGet->cAlias
oObj:oWSITEDAD:cANOAUT 		:= HttpGet->cAnoAut
oObj:oWSITEDAD:cCODOPE 		:= HttpGet->cCodOpe
oObj:oWSITEDAD:cMESAUT		:= HttpGet->cMesAut
oObj:oWSITEDAD:cNUMAUT		:= HttpGet->cNumAut
oObj:oWSITEDAD:cSEQPROC		:= HttpGet->cSeqProc

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
	cHTML += "			<th><font size='2' >Aguardando Anexo</font></th>" 
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

		cChave := '"'
		cChave += "CarregaVisInt('"
		cChave += HttpGet->cCodOpe + HttpGet->cAnoAut + HttpGet->cMesAut + HttpGet->cNumAut + "','" + HttpGet->cSeqProc + "','" + oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cSEQINT + "','"  + DTOC(oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:dDTITERACAO)+"','"+ oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cDESMOP+"','"+ EncodeUTF8(oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cOBSERVACAO) + "','" + cResposta + "','" + oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cALIASPAI + "','" + oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cRESPPREST + "','" + ALLTRIM(STR(getTpPortal()))
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
		
		HttpSession->cChave    := HttpGet->cCodOpe + HttpGet->cAnoAut + HttpGet->cMesAut + HttpGet->cNumAut
		HttpSession->cChaveInt := HttpSession->cChave + HttpGet->cSeqProc + oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cSEQINT

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
		
		If !oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:lANEXADO .AND. !oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:lRESPRE .AND. ; 
		  oObj:oWSGETINTERACAORESULT:oWSSVIEWINTERACAO[nI]:cTipDirec != "A" 
		  
			cHTML += "		<td><font size='2' >Sim</font></td>"
		Else
			cHTML += "		<td><font size='2' >Não</font></td>"
		EndIf 
		
		cHTML += "	</tr>"
	Next nI

	cHTML += "		</tbody>"
	cHTML += "	</table>"

	cResult += "Histórico de Interações|" +cHTML+ "|" + "@Fechar~ closeModalBS();"
else
	cResult :=  "false|"+StrTran(PWSGetWSError( "" ),":","")
endif

WEB EXTENDED END

Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLGETMUN    ³ Autor ³ Fábio S. dos Santos   ³ Data ³22/07/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a cidade conforme o estado selecionado.               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGETMUN()
LOCAL cResult  	:= "true|"
LOCAL xCols  := ""
LOCAL nI
local cCampoCID
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml //Aqui não tem o insite pq é utilizada no layout generico onde não tem login

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cCodEst	:= HttpGet->cCod
cCampoCID		:= HttpGet->cCampoCID
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLGETCEN    ³ Autor ³ Roberto Vanderlei   ³   Data ³16/11/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o endereço conforme o CEP selecionado.                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGETCEN()

LOCAL cResult  	:= ""
local cCampoEndereco
local cCampoBairro
local cCampoCodMunicipio
local cCampoMunicipio
local cCampoEstado
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml //Aqui não tem o insite pq é utilizada no layout generico onde não tem login

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode     := "MSALPHA"
oObj:cCep          := HttpGet->cCep
cCampoEndereco     := HttpGet->cCampoEndereco
cCampoBairro       := HttpGet->cCampoBairro
cCampoCodMunicipio := HttpGet->cCampoCodMunicipio
cCampoEstado       := HttpGet->cCampoEstado

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:DADRETCEN()
	if oObj:cDADRETCENRESULT <> ""
		cResult += oObj:cDADRETCENRESULT + "~" + cCampoEndereco + "|" + cCampoBairro + "|" + cCampoCodMunicipio + "|" + cCampoEstado
	endif
Else
	cResult := ""
EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLGETDBN    ³ Autor ³ Roberto Vanderlei   ³   Data ³17/11/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os dados do beneficiário atras do CPF.                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:DADRETBEN()
	if oObj:cDADRETBENRESULT <> ""
		cResult += oObj:cDADRETBENRESULT + "~" + cCmpNome + "|" + cCmpDtNasc + "|" + cCmpRg + "|" + cCmpOrigem + "|" + cCmpCRNA  + "|" + cCmpNomePai + "|" + cCmpNomeMae + "|" + cCmpEmail + "|" + cCmpCep + "|" + cCmpComplemento+ "|" +  cCmpNumero + "|" + cCmpDDD + "|" + cCmpTelefone + "|" + cCmpSexo + "|" +  cCmpEstEmi  + "|" + cCmpUniv + "|" + cCmpEstCiv + "|" + cCmpInval + "|" + cEstado + "|" + cCampMuni + "|" + cCmpEnder + "|" + cCmpBai
	endif
Else
	cResult := ""
EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLVERBEN    ³ Autor ³ Roberto Vanderlei   ³   Data ³16/11/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Recebe o Login e verifica se é benef, ou ja solicitou.        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLVERBEN()
LOCAL cResult  	:= ""
local cCpf := ""
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	     := "MSALPHA"

if Alltrim(Str(HttpSession->USR_INFO[1]:OWSUSERLOGPLS:nTpPortal)) = "2"
   cCpf := Alltrim(HttpSession->CCPF)
else
   cCpf := Alltrim(HttpSession->USR_INFO[1]:CUSERLOGIN)
endif

oObj:cUsrLoginCode	 := cCpf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

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

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPDELPROF    ³ Autor ³ Totvs         	    ³ Data ³ 17/07/15³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclui o corpo clinico
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPDELPROF()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cCRecno		:= HttpGet->cRecno
oObj:cAlias		:= "BC1"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:DelCorpoClinico()
	cResult := oObj:cDELCORPOCLINICORESULT
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)


//--------
//--------
//--------------------------------------------
Web Function PPLGRVLOG()

LOCAL cResult  	:= "true|"
Local cLogin 		:= IIf(ValType(HttpSession->USR_INFO[1]:CUSERLOGIN) == "C", HttpSession->USR_INFO[1]:CUSERLOGIN, "")
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
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

Return PLSDECODE(cResult)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLCBLOAD    ³ Autor ³ Thiago Guilherme	    ³ Data ³ 09/01/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os estados brasileiros no portal

±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCBLOAD()
LOCAL cResult  	:= "true|"
LOCAL xCols		:= ""
LOCAL nI
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cTipo			:= HttpGet->cTipo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSMAPCAPT  ³ Autor ³ Rodrigo Morgon     ³ Data ³ 28.07.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicia a tela de consulta de visitas aos prestadores          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PLSMAPCAPT()
LOCAL cHtml := ""
Local nI
Local nResult
Local xCols := ""
Private aResult := {}

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Obj
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametro
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUSERCODE 	:= "MSALPHA"
oObj:cTipo			:= "UF"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ ComboBox da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:DADLOAD()
	nResult := Len(oObj:OWSDADLOADRESULT:OWSSDADLOAD)

	For nI := 1 to nResult
		aadd(aResult,AllTrim(oObj:OWSDADLOADRESULT:OWSSDADLOAD[nI]:CDESCRIA)+"="+AllTrim(oObj:OWSDADLOADRESULT:OWSSDADLOAD[nI]:CDESCRIA))
	Next
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLMAPCAPT")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLProced       ³ Autor ³ Rodrigo Morgon  ³ Data ³ 13/08/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Solicitação de procedimentos da RDA          		    		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLPROCED ()
LOCAL cHtml 		:= ""
LOCAL nPos			:= 1
LOCAL nI			:= 1
LOCAL aObjSess	:= {} // Variaveis para criação de Grid generica
LOCAL aMntSess	:= {} 	// Variaveis para criação de Grid generica

PRIVATE lPrestTiss := .T.

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

for nI := 1 to 6
	aadd( aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:OWSSCmpGrid, PLSXFUN_SCMPGRID():NEW() )
next

aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[1]:cTipo := "C"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[1]:cNome := "Field_CODRDAFP"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[1]:cDescri := "RDA"

aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[2]:cTipo := "C"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[2]:cNome := "Field_F3ENDERECO"
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[2]:cDescri := "Local"

aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[3]:cTipo := "C"
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
aObjSess[nPos]:OWSSCMPGUIA[1]:oWSCmpGrid:oWSSCmpGrid[6]:cDescri := "Atender"

HttpSession->aCmpGuia := aClone(aObjSess[nPos]:OWSSCMPGUIA)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Chama formulario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHtml += ExecInPage("PPLPROCED")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLSOLOP   ³ Autor ³ Fábio S. dos Santos  ³ Data ³ 08/09/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para chamar a tela de solicitação de opcionais.        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da página .APH	                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml := ExecInPage( "PPLSOLOP" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCARBEN  ³ Autor ³ Karine Riquena Limp  ³ Data ³ 11/09/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para carregar os beneficiários vinculados a familia    ³±±
±±³          ³ ou a empresa.                                              	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCARBEN()

LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cCUSRLOGIN	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
oObj:nTpPor		:= getTpPortal()
//matricula do beneficiario selecionado para filtrar o multiselect
oObj:cMatUsu		:= IIF(valtype(httpGet->cMatric) != "U", httpGet->cMatric, "")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLGRVOP ³ Autor ³ Fábio S. dos Santos  ³ Data ³ 08/09/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para chamar a tela de solicitação de opcionais.        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGRVOP()
Local oObj
Local oObjItens		:= {}
Local cResult		:= "true|"
Local nCont			:= 1
Local nTpPortal		:= 0
Local aResult      := {}
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimenta parametros													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUserCode	:= "MSALPHA"
oObj:oWSDADOSOPC:oWSDADOSBENOPC := PLSXFUN_ARRAYOFSITENSOPC():New()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inclusao																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLVLOPC   ³ Autor ³ Karine Riquena Limp  ³ Data ³ 21/09/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para validar a inclusão dos beneficiários e opcionais  ³±±
±±³          ³ na solicitação de opcionais.    									³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLVLOPC()
LOCAL cResult  	:= "true|"
LOCAL cRec := ""
LOCAL cVldEspe := ""
LOCAL cOpcTit := ""
LOCAL aDados := {}
LOCAL oObj := NIL
LOCAL oObjPar := NIL
LOCAL nPos := 0
LOCAL nPosIte := 0
LOCAL nLen := 0
LOCAL nPosMat := 0
LOCAL nPosCodOpc := 0
LOCAL nPosVerOpc := 0
LOCAL aOpc := {}
LOCAL oOpc := nil
local nI := 1
LOCAL aDadosOpc
local oOpc
LOCAL lVldOpc := .F.
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObjPar := WSCFGDICTIONARY():New()
WsChgURL( @oObjPar, "CFGDICTIONARY.APW" )
oObjPar:cUSERCODE	:= "MSALPHA"
oObjPar:cMVPARAM	:= "MV_PVLOPCT"
If oObjPar:GETPARAM()
	lVldOpc := oObjPar:cGETPARAMRESULT
	If ValType(lVldOpc) == 'U'
		lVldOpc := .F.
	ElseIf	ValType(lVldOpc) == 'C'
		If Type(lVldOpc)=="L"
			lVldOpc := &(lVldOpc)
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

if lVldOpc
	//pego os itens que já estão na solicitação
	nPos := aScan( HttpSession->aCmpGuia, { |x| x:cNome == "BrwGrid"} )
	if(nPos > 0)
		nLen := len(HttpSession->aCmpGuia[nPos]:oWSACOLS:CSTRING)
		nPosMat    := aScan( HttpSession->aCmpGuia[nPos]:oWSCMPGRID:oWSSCMPGRID, { |x| x:cNome == "Field_BenefsMat"} )
		nPosCodOpc := aScan( HttpSession->aCmpGuia[nPos]:oWSCMPGRID:oWSSCMPGRID, { |x| x:cNome == "Field_CodOpc"} )
		nPosVerOpc := aScan( HttpSession->aCmpGuia[nPos]:oWSCMPGRID:oWSSCMPGRID, { |x| x:cNome == "Field_VerOpc"} )

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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cValores		:= HttpGet->cValores
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if oObj:VldBenOpc()

	aDados := Separa(oObj:cVLDBENOPCRESULT, "|", .F.)

	HttpGet->cValores := iif(aDados[1]=="0", "", aDados[1])
	cRec := iif(aDados[2]=="0","", aDados[2])
	cVldEspe := iif(aDados[3]=="0","", aDados[3])
	cOpcTit := iif(aDados[4]=="0","", aDados[4])

	if(HttpGet->cValores != "")
		cResult := W_PPLGETGRID()
	endif

	cResult += ">>"+cRec+">>"+cVldEspe+">>"+cOpcTit
else
	cResult :=  "false|"+StrTran(PWSGetWSError( "" ),":","")
endIf

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLCONSOP   ³ Autor ³ Karine Riquena Limp  ³ Data ³ 22.09.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da pagina de consulta de solicitações de opcionais    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCONSOP()
LOCAL cHtml   := ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada do .APH												     		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml := ExecInPage( "PPLCONSOP" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLIMPOPC    ³ Autor ³ Karine Riquena Limp  ³ Data ³ 24.09.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da pagina com o protocolo do opcional                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PLSIMPOPC()
LOCAL cHtml   := ""
LOCAL oObj := NIL
Private oDadSolOpc := NIL //private para poder usar no aph

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:ccRecno		:= HttpGet->cRecno
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if oObj:GetSolOpc()

	oDadSolOpc := oObj:oWSGETSOLOPCRESULT

endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mostra a pagina para entrar com o protocolo/Guia						   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml := ExecInPage( "PLSIMPOPC" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCHECKPR       ³ Autor ³ Rodrigo Morgon  ³ Data ³ 17/08/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verificação da solicitação de alteração de procedimento  		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCHECKPR()

LOCAL cResult  := "true|"
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cDadLog 		:= httpGet->cDadLog

If oObj:CHECKPROCEDIMENTO()
	cResult := oObj:CCHECKPROCEDIMENTORESULT
EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLGRVPROC      ³ Autor ³ Rodrigo Morgon  ³ Data ³ 21/08/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravação de procedimento na tabela de análise de log	  		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGRVPROC()

LOCAL cResult  	:= ""
Local cLogin 		:= IIf(ValType(HttpSession->USR_INFO[1]:CUSERLOGIN) == "C", HttpSession->USR_INFO[1]:CUSERLOGIN, "")
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
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

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLPRMACE ³ Autor ³ Roberto Vanderlei     ³ Data ³ 14/08/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para verificar se é primeiro acesso, caso seja, o      ³±±
±±³          ³ sistema irá obrigar que seja alterada a senha. 					³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLPRMACE()

local cResult := "true|"
local cUsuarioLogado
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

cUsuarioLogado := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUsrLoginCode	  := cUsuarioLogado


If oObj:VERACESSO()
	cResult += oObj:cVERACESSORESULT
else
	cResult :=  "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLUPLOPC			³ Autor ³ TOTVS      	 ³ Data ³ 08/09/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama APH da rotina de upload Genérica	    		    		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLUPLOPC()
LOCAL cHtml := ""
Local cModo := IIF(ValType(HttpGet->cModo) == "U", "1", HttpGet->cModo)

WEB EXTENDED INIT cHtml START "InSite"

	cHtml += ExecInPage("PPLUPLOPC")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cHtml)

Function ALTBBA(cRecnoBBA, cVar)
LOCAL oObj 		:= NIL

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cChave		:= cRecnoBBA
oObj:cModo      := "2"
oObj:AltStBen()

WEB EXTENDED END

return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLENVUPG 	  ³ Autor ³ Oscar Zanin     ³ Data ³ 08.09.2015	 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Upload de arquivo									 				³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLENVUPG()
local oObj 		:= NIL
local cResult  	:= ''
local cExecPos	:= ''
local aFunPos	:= {}
local cFunction	:= ''
local cPar		:= ''
local cHtml 	:= ''

WEB EXTENDED INIT cHtml START "InSite"

If ! Empty(HttpSession->cExecPos )
	cExecPos 	:= HttpSession->cExecPos
	aFunPos  	:= SEPARA(cExecPos, "|")
	cFunction	:= aFunPos[1]
	cPar     	:= aFunPos[2]
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

WEB EXTENDED END 

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLUPGEN			³ Autor ³ TOTVS      	 ³ Data ³ 08/09/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama APH da rotina de upload Genérica	    		    		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cHtml)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCONOPC			³ Autor ³ TOTVS      	 ³ Data ³ 08/09/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravação Opcionais após Upload				    		    		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCONOPC()

LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
Local cRecno		:= ""
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cChave		:= HttpGet->cCodSeq

HttpSession->cResDoc := "Vazio"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:GrvSolOpc()
	cResult += oObj:cGrvSolOpcRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLSTAOPC   ³ Autor ³ Karine R. Limp       ³ Data ³ 28/09/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera o status da solicitação de opcional após anexar docs  	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLSTAOPC()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
Local cRecno		:= ""
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:ccRecno		:= HttpGet->cRecno
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:AltSolOpc()
	cResult := oObj:cAltSolOpcRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLUNUPL 	  ³ Autor ³ Oscar Zanin     ³ Data ³ 05.10.2015	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ Ä´±±
±±³Descri‡„o ³ Exclusão de arquivos do banco de conhecimento        		    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLUNUPL()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cCRecno		:= HttpGet->cRecno

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:UnUplConhec()
	cResult += oObj:cUnUplConhecRESULT
	
Else
	
	cResult := "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLCPARQ 	  ³ Autor ³ Francisco     ³ Data ³ 06.01.2017	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ Ä´±±
±±³Descri‡„o ³ Chamada da função que retorna o caminho de download arquivos  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCPARQ()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cCRecno		:= STRTRAN(HttpGet->cRecno, ".","")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:CpyArqConhe()
	cResult += oObj:cCpyArqConheRESULT
	
Else
	
	cResult := "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLREEMB   ³ Autor ³ Karine Limp          ³ Data ³ 05.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da pagina de solicitação de reembolso                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLREEMB()

LOCAL cHtml 	:= ""
LOCAL cResult	:= ""
LOCAL aRegras	:= {}
LOCAL nTpPor  := getTpPortal()
LOCAL oObj
LOCAL oObjPar
LOCAL oObjSolic

PRIVATE lRecOb  := "false"
PRIVATE lMultComp	:= "false"
PRIVATE lSolRee	:= "false"
PRIVATE lTourReemb := "true"
PRIVATE aDadosSoli 	:= {}
PRIVATE nX := 1
PRIVATE cCodSol := iif(valtype(HttpGet->cCodSol) <> "U", HttpGet->cCodSol, "")
PRIVATE cMsgs := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->ClasseProc := {}
if (nTpPor <> 2)
	oObj := WSPLSXFUN():New()
	WsChgURL( @oObj, "PLSXFUN.APW" )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros de entrada												   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObj:cUserCode  := "MSALPHA"
	oObj:ccUsrLogin := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
	oObj:cMatUsu    := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CCODE

	If oObj:VerPermRee()
		lSolRee := oObj:cVERPERMREERESULT
		if (lSolRee == "true")
			oObjPar := WSCFGDICTIONARY():New()
			WsChgURL( @oObjPar, "CFGDICTIONARY.APW" )
			
			//Parametro MV_PLRECOB
			oObjPar:cUSERCODE	:= "MSALPHA"
			oObjPar:cMVPARAM	:= "MV_PLRECOB"
			If oObjPar:GETPARAM()
				lRecOb := oObjPar:cGETPARAMRESULT
				If ValType(lRecOb) == 'U'
					lRecOb := "false"
				ElseIf	ValType(lRecOb) == 'C'
					If Type(lRecOb)=="L"
						If &(lRecOb)
							lRecOb := "true"
						Else
							lRecOb := "false"
						EndIf
					EndIf
				EndIf
			EndIf

			//Parametro MV_PLREEMC
			oObjPar:cUSERCODE	:= "MSALPHA"
			oObjPar:cMVPARAM	:= "MV_PLREEMC"
			If oObjPar:GETPARAM()
				lMultComp := oObjPar:cGETPARAMRESULT
				If ValType(lMultComp) == 'U'
					lMultComp := "false"
				ElseIf	ValType(lMultComp) == 'C'
					If Type(lMultComp)=="L"
						If &(lMultComp)
							lMultComp := "true"
						Else
							lMultComp := "false"
						EndIf
					EndIf
				EndIf
			EndIf
			
			//Parametro MV_PLTOURE
			oObjPar:cUSERCODE	:= "MSALPHA"
			oObjPar:cMVPARAM	:= "MV_PLTOURE"
			If oObjPar:GETPARAM()
				lTourReemb := oObjPar:cGETPARAMRESULT
				If ValType(lTourReemb) == 'U'
					lTourReemb := "true"
				ElseIf	ValType(lTourReemb) == 'C'
					If Type(lTourReemb)=="L"
						If &(lTourReemb)
							lTourReemb := "true"
						Else
							lTourReemb := "false"
						EndIf
					EndIf
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Exibe pagina															   		  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(HttpSession->ClasseProc)	//	ValType(HttpSession->ClasseProc) == 'U'
				If oObj:RetClassProc()
					HttpSession->ClasseProc	:=   oObj:OWSRETCLASSPROCRESULT:OWSSCLASSEPROC
				EndIf
			EndIf
			
			If oObj:ReembChkRegr()
				cResult := oObj:cREEMBCHKREGRRESULT
				aRegras := StrToArray(cResult , "|")
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Chama o formulario													   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aRegras) > 0
				HttpSession->cDtLimit := SubStr(aRegras[1],4,2) + "/" + SubStr(aRegras[1],1,2) + "/" + SubStr(aRegras[1],7,4)
			EndIf

     	//Verifica se origem é tela de consulta
			If HttpGet->cOrigem == "consulta" .and. !Empty(HttpGet->cRecnoProt)

    		//Chamada de webservice para obter os dados do recno correspondente e alimentar a private aDadosSoli
				oObjSolic 	:= NIL
				oObjSolic	:= WSPLSXFUN():new()
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
				WsChgURL( @oObjSolic, "PLSXFUN.APW" )
				oObjSolic:cUserCode	:= "MSALPHA"
				oObjSolic:nTPPOR := getTpPortal()
				oObjSolic:cROTINA := "PPLREEMB"
				oObjSolic:cIDIOMA := "POR"
	
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCARREC  ³ Autor ³ Karine Riquena Limp  ³ Data ³ 13/10/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para carregar as receitas aprovadas vinculadas a       ³±±
±±³          ³ matricula do beneficiario.                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCARREC()

LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
//matricula do beneficiario selecionado para filtrar o multiselect
oObj:cMatUsu		:= httpGet->cMatric
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCOPRM  ³ Autor ³ Renan Martins        ³ Data ³ 06.01.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna dados do procedimento.								       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCOPRM()
LOCAL nI      	:= 0
LOCAL oOb2	  		:= NIL
LOCAL lExibe  	:= .F.
LOCAL cResult 	:= "true|"
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oOb2 := WSPLSXFUN():New()
WsChgURL( @oOb2, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oOb2:cUserCode 		:= "MSALPHA"
oOb2:ccCodTb   		:= HttpGET->cCodTb
oOb2:ccCodPro			:= HttpGet->cCodPro
oOb2:ccCodRDA			:= HttpGet->cCodRDA
oOb2:ccCodLoc			:= HttpGet->cCodLoc
oOb2:ccCodEsp			:= HttpGet->cCodEsp
oOb2:cFlgVRDA			:= "SIM"

If oOb2:GetVlrPro()
	cResult +=	oOb2:cGetVlrProRESULT
Else
	cResult := "false| ERRO"
ENDIF

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLITREEMB ³ Autor ³ Karine Riquena Limp  ³ Data ³ 14/10/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava o item do reembolso enquanto o beneficiarios            ³±±
±±³          ³ está fazendo a solicitação                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLITREEMB()
LOCAL oObj		:= NIL
LOCAL oObjPar 	:= NIL
LOCAL cResult  	:= "true|"
Local aArrFami 	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA
Local nPos     	:= 0
Local cTitPar	:= "T"
LOCAL 	cHtml   := ""
LOCAL dFontxFun :=  GetAPOInfo("WSPLSXFUN.PRX")[4] 
LOCAL dDatCliet :=  GetAPOInfo("WSCLIENT_WSPLSXFUN.PRX")[4] 

WEB EXTENDED INIT cHtml START "InSite"


//Pego código do titular parametrizado
oObjPar := WSCFGDICTIONARY():new()
wsChgURL( @oObjPar, "CFGDICTIONARY.APW" ) 
oObjPar:cUSERCODE	:= "MSALPHA"
oObjPar:cMVPARAM	:= "MV_PLCDTIT"
If oObjPar:GETPARAM()
	cTitPar := oObjPar:cGETPARAMRESULT
EndIf 

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cCodSol		:= httpGet->cCodSol
oObj:ccRecno      := httpGet->cRecno

//Busca titular ou responsável financeiro
nPos := aScan(aArrFami , { |x| x:cTipUsu == cTitPar} )

if nPos == 0
	nPos := aScan(aArrFami , { |x| x:cResFam == "1"} )
endif

if (nPos == 0)
	cResult := "false|Família não possui titular ou responsável financeiro. Entre em contato com a operadora."
	return PLSDECODE(cResult)
else
	oObj:cMatUsu	:= aArrFami[nPos]:cBenefi
endif

oObj:lCabAlt		:= ValType(HttpGet->lCabAlt) <> "U" .and. HttpGet->lCabAlt == "true" //verifica se alterou o cabeçalho do reembolso
oObj:cRecDivs		:= iif(ValType(HttpGet->cRecDivs) <> "U" .and. !empty(HttpGet->cRecDivs), HttpGet->cRecDivs, "0") //esse recnodivs vem quando é multicomprovante e eu só posso alterar as B1N do comprovante e não da solicitação interi

//Condição para garantir a existencia da propriedade e que o client está atualizado
If dFontxFun >= CTOD("01/11/2017") .AND. dDatCliet >= CTOD("01/11/2017") 
	oObj:cOriReemb		:= "01" //Portal do Beneficiario 
EndIf 
	
	oObj:oWSITEMREEMB := PLSXFUN_SITENSREEMB():New()

	oObj:oWSITEMREEMB:cCodPad := HttpGet->Field_CODPAD
	oObj:oWSITEMREEMB:cCodPro := HttpGet->Field_CODPROC
	oObj:oWSITEMREEMB:cVlrPro := StrTran(strTran(HttpGet->Field_VALOR, ",", ""),".","")
	oObj:oWSITEMREEMB:cUsoC   := iif(HttpGet->Field_USOCONST == "1", "1", "0")
	oObj:oWSITEMREEMB:cQtdPro := HttpGet->Field_QTD
	oObj:oWSITEMREEMB:cMatric := HttpGet->Field_MATRIC
	oObj:oWSITEMREEMB:cCodRec := HttpGet->Field_CODREC
	oObj:oWSITEMREEMB:cCodMed := HttpGet->Field_CODMED
	oObj:oWSITEMREEMB:cSeqMed := HttpGet->Field_SEQMED
	oObj:oWSITEMREEMB:cTipDoc := HttpGet->Field_TIPDOC
	oObj:oWSITEMREEMB:cCPFCNPJ := HttpGet->Field_CPFCNPJ
	oObj:oWSITEMREEMB:cNomRDA := HttpGet->Field_NOMEPRE
	oObj:oWSITEMREEMB:cNroDoc := HttpGet->Field_NUMDOC
	oObj:oWSITEMREEMB:dDatDoc := CtoD(HttpGet->Field_DTEMIS)
	oObj:oWSITEMREEMB:cTipSer := HttpGet->Field_TIPSER
	
	oObj:oWSITEMREEMB:cCidade := HttpGet->cCidade
	oObj:oWSITEMREEMB:cUF     := alltrim(HttpGet->cUf)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:GrvItReemb()

	cResult += oObj:cGRVITREEMBRESULT

Else
	cResult := "false|" + StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLExDsp ³ Autor ³ Oscar Zanin  ³ Data ³ 20/10/2015 			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclusão da despesa            									³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLExDsp()

Local oObj	:= NIL
Local cResult	:= ""
LOCAL 	cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj	:= WSPLSXFUN():new()
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cCRecno		:= HttpGet->cRecno

If oObj:DelDesp()
	cResult += oObj:cDELDESPRESULT

else
	cResult := "false|"

EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCHTAB  ³ Autor ³ Renan Martins        ³ Data ³ 12.01.2014  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Abre página de consulta de tabelas solicitadas      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCHTAB()
LOCAL cHtml	:= ""

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama o formulario													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml += ExecInPage( "PPLTBLVL" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLTBKHF  ³ Autor ³ Renan Martins        ³ Data ³ 06.01.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna dados do procedimento.								       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLTBKHF()
LOCAL oObj	  		:= NIL
LOCAL cResult 	:= "true|"
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLReemCon ³ Autor ³ Oscar Zanin  ³ Data ³ 20/10/2015 			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Confirmação Solicitação          									³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLReemCon()

Local oObj 	:= NIL
Local oObjPar := NIL
Local cResult	:= ""
Local aArrFami := {}
Local nPos     	:= 0
Local cTitPar	:= "T"
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

aArrFami := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA

//Pego código do titular parametrizado
oObjPar := WSCFGDICTIONARY():new()
wsChgURL( @oObjPar, "CFGDICTIONARY.APW" ) 
oObjPar:cUSERCODE	:= "MSALPHA"
oObjPar:cMVPARAM	:= "MV_PLCDTIT"

If oObjPar:GETPARAM()
	cTitPar := oObjPar:cGETPARAMRESULT
EndIf 

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"

if empty(httpGet->cCodSol)

    cResult := "false|Ocorreu um erro na conexão, por favor tente novamente."
    
else

    oObj:cCodSol := httpGet->cCodSol
    
    //Busca titular ou responsável financeiro
    nPos := aScan(aArrFami , { |x| x:cTipUsu == cTitPar} )
    
    if nPos == 0
        nPos := aScan(aArrFami , { |x| x:cResFam == "1"} )
    endif
    
    if (nPos == 0)
        cResult := "false|Família não possui titular ou responsável financeiro. Entre em contato com a operadora."
        return PLSDECODE(cResult)
    else
        oObj:cMatUsu    := aArrFami[nPos]:cBenefi
    endif
    
    oObj:cCPFCNPJ       := HttpGet->cCpfCnpj
    oObj:cNomRdaNRef    := HttpGet->cNomePres
    oObj:cCUsrLogin := HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
    oObj:cTipo          := HttpGet->cTipDoc
    oObj:cNumDoc        := HttpGet->cNumDoc
    oObj:cDocEmi        := HttpGet->cDatDoc
    oObj:cAltera        := HttpGet->lAltera
    oObj:cDocObrig    := HttpGet->lDocObrig
    oObj:lCabAlt        := ValType(HttpGet->lCabAlt) <> "U" .and. HttpGet->lCabAlt == "true"
    oObj:cRecDivs       := iif(ValType(HttpGet->cRecDivs) <> "U", HttpGet->cRecDivs, "0")
    
    oObj:cAtuB1N   := iif(ValType(HttpGet->lAtuB1N) <> "U", HttpGet->lAtuB1N, "S") 
    oObj:cTipoVld       := IIF (ValType(HttpGet->lMulti) <> "U" .And. HttpGet->lMulti == "true", "1", "0")
    
    If oObj:GrvFimReemb()
        cResult := oObj:cGRVFIMREEMBRESULT
    else
        cResult := "false|"
    EndIf
endif

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLISMBJE ³ Autor ³ Oscar Zanin  ³ Data ³ 20/10/2015 			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica na BJE se o serviço está definido como medicamento	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLISMBJE()

Local oObj	:= NIL
Local cRet	:= ""
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj	:= WSPLSXFUN():new()
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cTipSer		:= Httpget->cTipSer

If oObj:IsMedBJE()
	cRet := "true|" + oObj:cISMEDBJERESULT
else
	cRet := "false|"
EndIf

WEB EXTENDED END

Return PLSDECODE(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLVRSOL  ³ Autor ³ Renan Martins        ³ Data ³ 06.01.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna dados do procedimento.								       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLVRSOY()
LOCAL oObj	  		:= NIL
LOCAL cResult 	:= ""
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUserCode 		:= "MSALPHA"
oObj:ccCodRDA			:= HttpGet->cCodRDA
oObj:cPLSCodUsr		:= HttpGet->cCodUs

If oObj:PLSRELYB()
   cResult := 'true|'+oObj:cPLSRELYBRESULT
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
ENDIF

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLEDITPRO ³ Autor ³ Rodrigo Morgon       ³ Data ³ 20/10/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica status do protocolo selecionado e, caso permitido,   ³±±
±±³          ³ abre a tela de solicitação com os dados preenchidos.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLEDITPRO()

LOCAL cHtml := ""
Local oObj 	:= NIL
Local cResult	:= ""

WEB EXTENDED INIT cHtml START "InSite"

oObj	:= WSPLSXFUN():new()
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

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLDWLDY  ³ Autor ³ Renan Martins     ³ Data ³ 20.01.2015      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Procurar pastas com arquivos de downloads         				³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
WEB FUNCTION PPLDWLDY()
Local aArqDw	:= {}
Local cPastAq := ""
Local cNomArq := ""
Local cResult
Local nPos		:= 0
LOCAL oObj	  		:= NIL
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUserCode 		:= "MSALPHA"
If oObj:PLSGETMV("MV_PLSDRDA","")
   cResult := oObj:cPLSGETMVRESULT
Else
	cResult := StrTran(PWSGetWSError( "" ),":","")
ENDIF

cNom := HttpGet->cNomArq
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Le diretorio para mostrar os arquivos disponiveis
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !(Empty(cNom))
cNom := Alltrim(cNom)
cResult := Substr(cResult, 0, Len(cResult)-1)
nPos    := RAT("\", cResult)
cResult := Substr(cResult, nPos, Len(cResult))
cResult := cResult + "\" + cNom
cResult := Strtran(cResult, "\", "/")
cResult := "true|"+cResult
	Else
		cResult := "false| nenhum arquivo encontrado"
	EndIf
	
WEB EXTENDED END
	
Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLGETPRO  ³ Autor ³ Roberto Vanderlei     ³ Data ³ 13.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a o prestador a partir do CRM e Estado    	 		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Web Function PPLGETPRO()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cCrm		:= HttpGet->cCrm
oObj:cEstado	:= HttpGet->cEstado
oObj:cCodSig	:= HttpGet->cConselho 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:RDAPro()
	cResult := oObj:cRDAProRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLPROREC   ³ Autor ³ Roberto Vanderlei    ³ Data ³ 27.10.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da Rotina de Receitas Portal beneficiario.			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLPROREC()
LOCAL cHtml 	:= ""
LOCAL cResult	:= ""
local nI
LOCAL aObjSess	:= {} // Variaveis para criação de Grid generica
LOCAL aMntSess	:= {} 	// Variaveis para criação de Grid generica


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe pagina															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLGRVREC   ³ Autor ³     Roberto Vanderlei Data ³ 27/10/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
D±±³Descri‡„o ³ Gravação do Cabeçalho/Item da receita B7D e B4F				 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGRVREC()

LOCAL cResult := "true|"
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
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

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLALTREC   ³ Autor ³     Roberto Vanderlei Data ³ 28/10/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
D±±³Descri‡„o ³ Alteração Status  B7D.			 							 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLALTREC()

LOCAL cResult := "true|"
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	  := "MSALPHA"
oObj:cProtoc 	  := HttpGet->cProtoc
oObj:cBenef 	  := HttpGet->cBenef

If oObj:AltRect()
	cResult += oObj:CALTRECTRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLCARBA1 ³ Autor ³ Renan MArtins              Data ³ 11/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para carregar os beneficiários com acesso ao reemblso  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLCARBA1()

LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode		:= "MSALPHA"
oObj:cCUSRLOGIN		:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
oObj:nTpPor			:= getTpPortal()
//matricula do beneficiario selecionado para filtrar o multiselect
oObj:cMatUsu		:= IIF(valtype(httpGet->cMatric) != "U", httpGet->cMatric, "")
oObj:cPermT 		:= "1"  //Para identificar o reembolso|
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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
	cResult := "false|"
EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLVERPRO   ³ Autor ³     Roberto Vanderlei Data ³ 28/10/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
D±±³Descri‡„o ³  Verifica se já não possue algum protocolo em aberto. 		  ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLVERPRO()

LOCAL cResult := "true|"
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode := "MSALPHA"
oObj:cCpfCnpj 	   := HttpSession->cCpf

If oObj:VerPro()
	cResult += oObj:CVERPRORESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLMSGPOR  ³ Autor ³ TOTVS     ³            Data ³ 19.11.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna mensagens do portal                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLMSGPOR()
LOCAL oObj := NIL
LOCAL cMsgs 		:= ""
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obj																	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE := "MSALPHA"
oObj:nTPPOR := getTpPortal()
oObj:cROTINA := IIF(valType(HttpGet->cRotina) <> "U",HttpGet->cRotina , "") //"PPLMOSPRE"
oObj:cCODMSG := IIF(valType(HttpGet->cCodMsg) <> "U",HttpGet->cCodMsg , "")//HttpGet->cCodMsg
oObj:cIDIOMA := IIF(valType(HttpGet->cIdioma) <> "U",HttpGet->cIdioma , "")//HttpGet->cIdioma //"POR"

if oObj:GetMsgPortal()
	cMsgs := oObj:cGETMSGPORTALRESULT
endif

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cMsgs

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLDIGGUIP  ³ Autor ³ Rodrigo Morgon        ³ Data ³ 11/2015  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna guias de acordo com o critério selecionado.           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLDIGGUIP()
LOCAL cHtml		:= ""
LOCAL cTpDIGR 	:= ""
LOCAL cResult		:= ""
LOCAL nLenCombo 	:= 1
Local cCodOff		:= ""

LOCAL oObjPar 	:= NIL
LOCAL oObjLib := NIL
Local oObjCbx		:= Nil
LOCAL nLen		:= IIf(Valtype(HttpSession->RDAVIEW) == "A", Len(HttpSession->RDAVIEW), 0 )
Local nI

PRIVATE lPrestTiss := .T.
PRIVATE cDataLimit := ""


PRIVATE cInterPag := ""
PRIVATE cValParam := "1"

WEB EXTENDED INIT cHtml START "InSite"

//Pego local de Digitação off-line
oObj := WSCFGDICTIONARY():new()
wsChgURL( @oObj, "CFGDICTIONARY.APW" ) 
oObj:cUSERCODE:= "MSALPHA"
oObj:cMVPARAM	:= "MV_PLSDIGP"
If oObj:GETPARAM()
	httpSession->cCodOff := oObj:cGETPARAMRESULT
EndIf 


//ATENÇÃO: Foi criado um parâmetro temporário para exibir ou não a opção de Guia de GRI e GH na digitação Off-line, enquanto não ocorre a homologação oficial.Não retirar este ponto!
oObjCbx := WSCFGDICTIONARY():New()
WsChgURL( @oObjCbx, "CFGDICTIONARY.APW" )
oObjCbx:cUSERCODE	:= "MSALPHA"
oObjCbx:cMVPARAM	:= "MV_POPTCBX"
If oObjCbx:GETPARAM()
	httpSession->cPLSPOPTCBX := Iif( Empty(oObjCbx:cGETPARAMRESULT) .or. oObjCbx:cGETPARAMRESULT == ".F.", 'false', lower(oObjCbx:cGETPARAMRESULT))
else
	httpSession->cPLSPOPTCBX := 'true'
EndIf

//Verifico se o usuário tem acesso a incluir guias no portal, definida na tabela BSO, de usuários de portal

oObjPar := WSCFGDICTIONARY():New()
WsChgURL( @oObjPar, "CFGDICTIONARY.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro no WS														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjPar:cUSERCODE	:= "MSALPHA"
oObjPar:cMVPARAM	:= "MV_PLCALPG"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pegar a codigo de consulta definido no parametro 					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObjPar:GETPARAM()
	cValParam := IiF( Empty(oObjPar:cGETPARAMRESULT),"1",alltrim(oObjPar:cGETPARAMRESULT))
Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLDIGGUIP.APW" )
EndIf

oObjLib := WSPLSXFUN():New()
WsChgURL( @oObjLib, "PLSXFUN.APW" )
oObjLib:cUSERCODE	:= "MSALPHA"
oObjLib:cRDACode := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ RDA(s)														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca Calendario de Pagamento
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObjLib:getCalend()
	cInterPag := oObjLib:cGETCALENDRESULT
Else
	Return PPLSALERT( "", "Atenção", "", "W_PPLCHAIMP.APW" )
EndIf


oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada												   			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUserCode 	:= "MSALPHA"
oObj:nTp			:= 1

//Alimenta session tipo guia
httpSession->aTipGui := {}

if oObj:getCombo()
	httpSession->aTipGui := oObj:oWSGETCOMBORESULT:oWSCbTpPreAte:oWSGenericStruct
EndIf

cHtml += ExecInPage( "PPLDIGGUIAS" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PPLBKGUI  ³ Autor ³ Rodrigo Morgon          ³ Data ³ 11/2015    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna fase das guias selecionadas para voltar para digitação  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLBKGUI()
LOCAL oObj 		:= NIL
LOCAL cResult  	:= ""

LOCAL nI
LOCAL nTamI
LOCAL aString
LOCAL nCount := 0
LOCAL nNewTamI
LOCAL nTamY
LOCAL nY := 0
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXMOV():New()
WsChgURL( @oObj, "PLSXMOV.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cNumAut		:= HttpGet->cRecnoGuias
oObj:nAutType		:= Val(HttpGet->cTipoGuias)

If oObj:BackDigitacaoGuia()
	cResult := oObj:cBACKDIGITACAOGUIARESULT
EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLTIPGUI    ³ Autor ³ Thiago Guilherme	    ³ Data ³ 09/01/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os tipos de guia para impressão em branco.
	beneficiario³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Web Function PPLTIPGUI() //02-12
LOCAL cResult  	:= "true|"
LOCAL xCols
LOCAL nI
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"

//EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

Return PLSDECODE(cResult)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPLCRRBAN - Relatório de Reembolso Analítico
@author	Renan Martins
@since		11/2015
@version	P12
@Obs
//---------------------------------------------------------------------------------------/*/
Web Function PPLCRRBAN()
Local cHtml   	:= ""
Private cTipo	:= "R"
//cTipo, para identificar se é tela de opções de reembolso ou utilização

WEB EXTENDED INIT cHtml START "InSite"

	cHtml := ExecInPage("PPLCHRRAN.APH")
	
WEB EXTENDED END

Return cHtml

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPLCRREUTX - Relatório de Extrato de Utilização
@author	Renan Martins.
@since		12/2015
@version	P12
@Obs 	.
//---------------------------------------------------------------------------------------/*/
Web Function PPLCRREUTX()
Local cHtml   	:= ""
Private cTipo	:= "E"
//cTipo, para identificar se é tela de opções de reembolso ou utilização

WEB EXTENDED INIT cHtml START "InSite"

	cHtml := ExecInPage("PPLCHRRAN.APH")
	
WEB EXTENDED END

Return cHtml
//-------------------------------------------------------------------
/*/{Protheus.doc} PPLCHAMCB
Carteirinha do beneficiario

@author  PLS TEAM
@version P11
@since   15.10.15
/*/
//-------------------------------------------------------------------
web function PPLCHAMCB()
LOCAL cHtml := ""

//Exibe pagina
WEB EXTENDED INIT cHtml START "InSite"

//Pega o parametro
oObj := WSCFGDICTIONARY():New()
WsChgURL( @oObj, "CFGDICTIONARY.APW" )

//Registro no WS
oObj:cUSERCODE	:= "MSALPHA"
oObj:cMVPARAM	:= "MV_LRN360"

//Pegar a codigo de consulta definido no parametro
If oObj:GETPARAM()
	HttpSession->MV_LRN360 := oObj:cGETPARAMRESULT
EndIf

//Chama o formulario
cHtml += ExecInPage("PPLCHAMCB")

WEB EXTENDED END

return cHtml

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} 	PPLREAJ
Web Function da pagina PPLREAJ.aph

@author	Lucas de Azevedo Nonato
@since		23/12/2015
@version	P12
/*/
//---------------------------------------------------------------------------------------
Web Function PPLREAJ()
Local cHtml   	:= ""

WEB EXTENDED INIT cHtml START "InSite"

	If HTTPSESSION->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CFAMILIA <> nil
		HttpSession->cMatric := HTTPSESSION->USR_INFO[1]:OWSUSERLOGPLS:OWSLISTOFOPE:OWSSOPERADORA[1]:OWSEMPRESA:OWSSEMPRESA[1]:OWSCONTRATO:OWSSCONTRATO[1]:OWSSUBCONTRATO:OWSSSUBCONTRATO[1]:OWSFAMILIA:OWSSFAMILIA[1]:CFAMILIA
	EndIf

	cHtml := ExecInPage("PPLREAJ")

WEB EXTENDED END

Return cHtml
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} 	PPLGETFREL
Web Function da listagem de arquivos nos relatorios de pagamento PPLRELMOV

@author	Rogério Tabosa
@since		01/2016
@version	P11
/*/
//---------------------------------------------------------------------------------------
Web Function PPLGETFREL()
LOCAL cResult  := ""
LOCAL cRdas	:= ""
LOCAL oObj		:= NIL
LOCAL nI		:= 0
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Metodo e propriedades
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

oObj:cUserCode	:= "MSALPHA"
oObj:cRDACode	:= httpGet->cRdaCode

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Lista de arquivos
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:getArqRel()
	cResult +=	oObj:cGETARQRELRESULT
Else
	cResult := "false|"+StrTran(PWSGetWSError( "" ),":","")
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return PLSDECODE(cResult)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} 	PPLBLORE
Web Function da verificação de bloqueio do usuário para fazer o reembolso.

@author	Lucas Nonato
@since		03/2016
@version	P12
/*/
//---------------------------------------------------------------------------------------

Web Function PPLBLORE()
LOCAL oObj
LOCAL cResult  	:= "true|"
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros.
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cDocObrig    := HttpGet->lDocObrig
	oObj:oWSITEMREEMB := PLSXFUN_SITENSREEMB():New()

	oObj:oWSITEMREEMB:cCodPad := HttpGet->Field_CODPAD
	oObj:oWSITEMREEMB:cCodPro := HttpGet->Field_CODPROC
	If ValType(HttpGet->Field_VALOR) <> "U"
	oObj:oWSITEMREEMB:cVlrPro := StrTran(strTran(HttpGet->Field_VALOR, ",", ""),".","")
	Endif

	oObj:oWSITEMREEMB:cUsoC   := iif(HttpGet->Field_USOCONST == "1", "1", "0")
	oObj:oWSITEMREEMB:cQtdPro := HttpGet->Field_QTD
	oObj:oWSITEMREEMB:cMatric := HttpGet->Field_MATRIC
	oObj:oWSITEMREEMB:cCodRec := HttpGet->Field_CODREC
	oObj:oWSITEMREEMB:cCodMed := HttpGet->Field_CODMED
	oObj:oWSITEMREEMB:cSeqMed := HttpGet->Field_SEQMED
	oObj:oWSITEMREEMB:cTipDoc := HttpGet->Field_TIPDOC
	oObj:oWSITEMREEMB:cCPFCNPJ := HttpGet->Field_CPFCNPJ
	oObj:oWSITEMREEMB:cNomRDA := HttpGet->Field_NOMEPRE
	oObj:oWSITEMREEMB:cNroDoc := HttpGet->Field_NUMDOC
	oObj:oWSITEMREEMB:dDatDoc := CtoD(HttpGet->Field_DTEMIS)
	oObj:oWSITEMREEMB:cTipSer := HttpGet->Field_TIPSER

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Retorna dados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If oObj:BloqReem()

	cResult += oObj:cBLOQREEMRESULT

Else
	cResult := "false|" + AllTrim(StrTran(PWSGetWSError( "" ),":",""))
EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PPLGUIBCO   ³ Autor ³ Thiago Guilherme     ³ Data ³ 30.11.2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada da Rotina de impressão de guias TISS em branco		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLGUIBCO()
LOCAL cHtml 	:= ""
LOCAL cResult	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe pagina															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLGUIBCO")

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

//-------------------------------------------------------------------
/*/{Protheus.doc} PPLRDEB
Chamada da tela para geração do relatório de quitação de débitos no Portal
@author Oscar Zanin
@since 27/04/2016
@version P12
/*/
//-------------------------------------------------------------------
Web Function PPLRDEB()

LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLRDEB")

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------
/*/{Protheus.doc} PPLTBLVALOR
Chamada da tela de verificação de elegibilidade de procedimentos e solicitação de tabela

@author Renan Martins
@since 29/04/2016
@version P12
/*/
//-------------------------------------------------------------------
Web Function PPLTBLVALOR()
LOCAL cHtml	:= ""
PRIVATE lPrestTiss := .T.

WEB EXTENDED INIT cHtml START "InSite"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama o formulario													   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHtml += ExecInPage( "PPLTBLVALOR" )

WEB EXTENDED END
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return cHtml

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPLMEMORET   ³ Autor ³ Karine Riquena Limp   ³ Data ³ 05/05/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o conteudo memo de um campo pelo recno                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PPLMEMORET()
LOCAL cResult  	:= "true|"
LOCAL cRecno  := HttpGet->cRecno
LOCAL cAlias  := HttpGet->cAlias
LOCAL cCampo  := HttpGet->cCampo
LOCAL nResult
LOCAL nI
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

//-------------------------------------------------------------------
/*/{Protheus.doc} PPLFLAINT
Altera a flag da interação no anexo

@author Karine Riquena Limp
@since 20/07/2016
@version P12
/*/
//-------------------------------------------------------------------
Web Function PPLFLAINT()
local cResult := "true|"
local oObj := WSPLSXFUN():New()
local lPendente	:= valtype(HttpGet->lPendente) <> "U" .and. HttpGet->lPendente == "true"
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

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

Return PLSDECODE(cResult)

//-------------------------------------------------------------------
/*/{Protheus.doc} PPLGRCAAUT
Gravar apenas os campos após autorização

@author Renan Martins
@since 09/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Web Function PPLGRCAAUT()
	LOCAL cVar 		:= HttpGet->cElmts
	Local cVarIts 	:= HttpGet->cElmtsIts
	LOCAL cResult 	:= 'true|'
	LOCAL 	cHtml := ""
	LOCAL nI		:= 0
	
WEB EXTENDED INIT cHtml START "InSite"

	//OBJETO WEBSERVICE
	oObj := WSPLSXFUN():New()
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

Return PLSDECODE(cResult)



//-------------------------------------------------------------------
/*/{Protheus.doc} PPLRETCRMF
Retorna Críticas da BDX no Digitação Off-Line

@author Renan Martins
@since 07/2016
@version P12
/*/
//-------------------------------------------------------------------
Web Function PPLRETCRMF()
LOCAL cResult  	:= "true|"
LOCAL cChave  := HttpGet->cChave
LOCAL nI
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ oBJ
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cChave  	:= cChave

If oObj:RETCRIMF()

	cResult += oOBJ:cRETCRIMFRESULT
Else
	cResult := "false|"
EndIf

WEB EXTENDED END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return PLSDECODE(cResult)

//-------------------------------------------------------------------
/*/{Protheus.doc} PPLVLBLBen

@author Oscar Zanin
@since 07/2016
@version P12
/*/
//-------------------------------------------------------------------
Web Function PPLVLBLBen()
Local cResult := "true|"
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
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

Return PLSDECODE(cResult)


//-------------------------------------------------------------------
/*/{Protheus.doc} PPLPRORINT
Chama tela de prorrogação de internação

@author  Rodrigo Morgon
@version P12
@since   04.07.16
/*/
//-------------------------------------------------------------------
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

Return cHtml

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPLGETPATD
Web Function para pegar o número do protocolo de atendimento

@author	Lucas Nonato
@since		08/08/2016
@version	P11
/*/
//---------------------------------------------------------------------------------------
Web Function PPLGETPATD()
Local cHtml		:= ""
Local oObj		:= nil

WEB EXTENDED INIT cHtml START "InSite"

If !(HttpGet->lAnexos == 'true') .And. ValType(HttpSession->aVldCartao) == 'A' .And. HttpSession->aVldCartao[10]
	cResult := "false|Para usuários de intercambio é necessário a digitação do protocolo"

Else
	oObj := WSPLSXFUN():New()
	WsChgURL( @oObj, "PLSXFUN.APW" )

	oObj:cUserCode	:= "MSALPHA"

	If oObj:getNumProtoc()
		cHtml +=	"true|"+oObj:cGETNUMPROTOCRESULT + "|" + HttpGet->bID + "|" + HttpGet->cID
	Else
		cHtml := "false|"+StrTran(PWSGetWSError( "" ),":","")
	EndIf

EndIf

WEB EXTENDED END

return PLSDECODE(cHtml)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPLVLDPROT
Web Function para validação do protocolo de atendimento

@author	Lucas Nonato
@since		09/08/2016
@version	P11
/*/
//---------------------------------------------------------------------------------------
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

Return PLSDECODE(cResult)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPLINTPROTOC
Web Function que chama a tela de integração do protocolo

@author	Lucas Nonato
@since		08/08/2016
@version	P11
/*/
//---------------------------------------------------------------------------------------
Web Function PPLINTPROTOC()
Local cHtml			:= ""


WEB EXTENDED INIT cHtml START "InSite"	
	HttpSession->cMatInterc := HttpGet->cMatric
	cHtml := ExecInPage( "PPLSPROTOC" )

WEB EXTENDED END	

Return PLSDECODE(cHtml)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPL773WEBRN
Web Function para pegar o número do protocolo da Unimed Origem

@author	 Lucas Nonato
@since	 08/08/2016
@version P11
/*/
//---------------------------------------------------------------------------------------
Web Function PPL773WEBRN()
Local cHtml		:= ""
Local oObj		:= nil	
Local cIsAnexo	:= "|false"
WEB EXTENDED INIT cHtml START "InSite"
	oObj := WSPLSXFUN():New()
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

Return PLSDECODE(cHtml)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPLVERINT
Web Function para verificar se a integração está ativada.

@author	Lucas Nonato
@since		08/08/2016
@version	P11
/*/
//---------------------------------------------------------------------------------------
Web Function PPLVERINT()
Local cHtml			:= ""
Local lPL395WS 	:= .F.

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSCFGDICTIONARY():New()
WsChgURL( @oObj, "CFGDICTIONARY.APW" )

oObj:cUSERCODE	:= "MSALPHA"
oObj:cMVPARAM	:= "MV_PL395WS"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pegar a codigo de consulta definido no parametro 					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oObj:GETPARAM()
	lPL395WS := IiF( AllTrim(oObj:cGETPARAMRESULT)=="1",.T.,.F.)
EndIf
If	lPL395WS
	cHtml := "true|" + Iif(ValType(HttpGet->cMatric) == "C", HttpGet->cMatric, "")	
Else
	cHtml := "false|Para usuários de intercambio é necessário a digitação do protocolo"
EndIf

WEB EXTENDED END

Return PLSDECODE(cHtml)

//-------------------------------------------------------------------
/*/{Protheus.doc} PPLdtFut

@author Oscar Zanin
@since 07/2016
@version P12
/*/
//-------------------------------------------------------------------
Web Function PPLdtFut()
Local cResult := "true|"
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
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

Return PLSDECODE(cResult)

//-------------------------------------------------------------------
/*/{Protheus.doc} PPLUPDB1N

@author Karine Riquena Limp
@since 28/09/2016
@version P12
@description Atualiza todas os itens da B1N quando altera o cabeçalho 
               no reembolso
/*/
//-------------------------------------------------------------------
Web Function PPLUPDB1N()
Local cResult := "true|"
local oObj := WSPLSXFUN():New()
LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

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

Return PLSDECODE(cResult)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPLBENINT
Web Function para verificar se a integração está ativada.

@author	Lucas Nonato
@since		08/08/2016
@version	P11 
/*/
//---------------------------------------------------------------------------------------

Web Function PPLBENINT()

Local cHtml	:= ""
Local cNumCart:= HttpGet->cNumCart

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
oObj:cUSERCODE 	:= "MSALPHA"
oObj:cUserCardNumber := cNumCart

If oObj:RetItercamb()
	cHtml := oObj:cRetItercambRESULT
Else
	cHtml := ""
EndIf

WEB EXTENDED END

Return PLSDECODE(cHtml)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPLDADPES
Web Function da pagina PPLSDADPES.aph

@Project	
@author	Lucas Nonato
@since		29/10/2015
@version	P12

/*/
//---------------------------------------------------------------------------------------
Web Function PPLDADPES()
	local cHtml   	:= ""
	local cCodUsr	:= ""
	local oWs

	WEB EXTENDED INIT cHtml START "InSite"	 // Garante que existe uma sessão válida.
	
	HttpSession->aDados := {}
	
	oObj := WSPLSXFUN():New()
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
return cHtml


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPLEXFINA
Chamada do relatório de extrato financeiro

@Project	
@author	Thiago Guilherme
@since		30.11.2015
@version	P12

/*/
//---------------------------------------------------------------------------------------
Web Function PPLEXFINA()
LOCAL cHtml 	:= ""
LOCAL cResult	:= ""


//Exibe pagina	

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage("PPLEXFIN")

WEB EXTENDED END

//Fim da rotina

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



//-------------------------------------------------------------------
/*/{Protheus.doc} PPLVlItRe
Valida itens negados para reembolso

@author Francisco Edcarlo
@since 03/2017
@version P12
/*/
//-------------------------------------------------------------------
Web Function PPLVlItRe()

Local oObj 	:= NIL
Local cResult	:= ""

LOCAL 	cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"


oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Parametros
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj:cUserCode	:= "MSALPHA"
oObj:cCodSol		:= httpGet->cCodSol


If oObj:VldItReemb()
	cResult := oObj:cVldItReembRESULT
else
	cResult := "false|"
EndIf

WEB EXTENDED END

Return PLSDECODE(cResult)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPLHABBOT
Web Function para anexos medicamento uso constante.

@author	Lucas Nonato
@since		08/08/2016
@version	P11 
/*/
//---------------------------------------------------------------------------------------

Web Function PPLHABBOT()

Local cHtml	:= ""
Local cRecno:= HttpGet->cRecno
Local cChave:= HttpGet->cChave


	oObj := WSPLSXFUN():New()
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

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPLCANPLA
Web Function para carregar pagina de cancelamento de planos

@author	Lucas Nonato
@since		08/08/2016
@version	P11 
/*/
//---------------------------------------------------------------------------------------
Web Function PPLCANPLA()
LOCAL cHtml := ""


//Chama formulario
WEB EXTENDED INIT cHtml

If ValType(HttpSession->aFamBloq) <> "A"
	HttpSession->aFamBloq := {}
EndIf

//Ws
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros
oObj:cUserCode	:= "MSALPHA"
oObj:cCUSRLOGIN	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE

If oObj:getFamBloq()
	HttpSession->aFamBloq := oObj:oWSGETFAMBLOQRESULT:oWSFAMBLOQLIST
EndIf

cHtml += ExecInPage("PPLCANPLA")

WEB EXTENDED END

Return cHtml    


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPLCONFPLA
Web Function para confirmacao do cancelamento de planos

@author	Lucas Nonato
@since		08/08/2016
@version	P11 
/*/
//---------------------------------------------------------------------------------------
Web Function PPLCONFPLA()
Local cHtml := "false|" 

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros
oObj:cUserCode	:= "MSALPHA"
oObj:cCUSRLOGIN	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
oObj:ccRecno    := HttpGet->cRecSelec

If oObj:procSolicBloq() 
	cHtml := oObj:cPROCSOLICBLOQRESULT
EndIf

Return PLSDECODE(cHtml)   


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPLRELCPL
Web Function para exibicao de relatorios da RN 412

@author	Renan Sakai
@since		08/08/2016
@version	P11 
/*/
//---------------------------------------------------------------------------------------
Web Function PPLRELCPL()
LOCAL cHtml := ""

//Ws
oObj := WSPLSXFUN():New()
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

Return cHtml         

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPLINFCPL
Web Function para exibicao de busca de informacoes de uma solicitacao de cancelamento de 
plano - RN 412

@author	Renan Sakai
@since		08/08/2016
@version	P11 
/*/
//---------------------------------------------------------------------------------------
Web Function PPLINFCPL()
Local cHtml := "true|" 

//Ws
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )

//Parametros
oObj:cUserCode	:= "MSALPHA"
oObj:cCUSRLOGIN	:= HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE
oObj:ccRecno    := HttpGet->cRecno

If oObj:getSolCanPla()
	HttpSession->aSolCanPla := oObj:oWSGETSOLCANPLARESULT:oWSSOLICCANPLALIST
EndIf

Return cHtml    


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPLINFCPL
Chama pagina com informacoes de uma solicitacao de cancelamento de plano

@author	Renan Sakai
@since		08/08/2016
@version	P11 
/*/
//---------------------------------------------------------------------------------------
Web Function PPLCPLPOP()
Local cHtml := ""

//Chama formulario
WEB EXTENDED INIT cHtml

	cHtml += ExecInPage("PPLCPLPOP")

WEB EXTENDED END

Return cHtml 

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPLCRTXT
Críticas do XML da submissão via Portal em base 64

@author	Renan Martins
@since		06/2017
@version	P11 
/*/
//---------------------------------------------------------------------------------------
Web Function PPLCRTXT()

Local cResult	:= ""
Local chtml := ""

oObj := WSPLSXFUN():New()
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Rotina														   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return PLSDECODE(cResult)

//-------------------------------------------------------------------
/*/{Protheus.doc} PPLVerSInt
Verifica a Solicitação de Internação para a Guia de Resumo.

@author  Roberto Arruda
@version P12
@since   08.03.16
/*/
//-------------------------------------------------------------------
Web Function PPLVerSInt()
Local cHtml := ""
Local cTISSVer := ""
Local cResult := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Web Service															   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros de entrada												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUserCode 		:= "MSALPHA"
oObj:cNumGuiRef  	:= HttpGET->cCodGuia
oObj:cDatGuia		:= HttpGET->dDtaAtd		
oObj:cRDACode			:= HttpGET->cRda		

If oObj:VerGuiInt()
	cResult :=	oObj:cVerGuiIntRESULT
Else
	cResult := "false| ERRO"
ENDIF

WEB EXTENDED END

Return PLSDECODE(cResult)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSRETCODP
Retorna codigo do profissional de saude

@author		totvs team
@since		29/06/2017
@version	P11 
/*/
//---------------------------------------------------------------------------------------
function PLSRETCODP( cCnpjCpfSol,cProSol )
	local cRet
	
	oObj := WSPLSXFUN():New()
	WsChgURL( @oObj, "PLSXFUN.APW" )
	oObj:cUSERCODE 	:= "MSALPHA"
	oObj:cCpfCnpj	:= cCnpjCpfSol
	oObj:cCodProf	:= cProSol
	
	if( oObj:RetProSau())
		cRet := oObj:cRETPROSAURESULT
	endIf 
Return cRet

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPLCRPROT
Protocolo

@author	André Dini
@since		07/2017
@version	P11 
/*/
//---------------------------------------------------------------------------------------
Web Function PPLCRPROT()

Local cResult	:= ""
Local chtml := ""

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
oObj:cUSERCODE 	:= "MSALPHA"

//Alimenta os atributos do objeto com os respectivos valores
oObj:cBusca	:= HttpGet->cRecno
oObj:cTipBusca  := HttpGet->cTipRel

if oObj:RetCriPROT()
	cResult := oObj:cRETCRIPROTRESULT
endif

Return PLSDECODE(cResult)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PPLSREDIR
Alteração cadastral

@author	André Dini
@since		10/2017
@version	P12.1.17
/*/
//---------------------------------------------------------------------------------------
Web Function PPLSREDIR()
Local cHtml   	:= ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml := ExecInPage("PPLSREDIR")

WEB EXTENDED END
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
/*/
Web Function PPLCBOXGEN()
Local cResult	:= ""
Local cAlias	:= HttpGet->cAlias
Local cDados	:= HttpGet->cDados
Local cWhere	:= HttpGet->cWhere

oObj := WSPLSXFUN():New()
WsChgURL( @oObj, "PLSXFUN.APW" )
oObj:cUSERCODE 	:= "MSALPHA"

//Alimenta os atributos do objeto com os respectivos valores
oObj:cAlias	:= cAlias
oObj:cDados	:= cDados
oObj:cWhere	:= cWhere

if oObj:getCboxGen()
	cResult := oObj:cgetCboxGenRESULT
endif

Return PLSDECODE(cResult)

