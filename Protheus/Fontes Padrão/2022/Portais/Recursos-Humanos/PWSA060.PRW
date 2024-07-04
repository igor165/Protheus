#INCLUDE "PWSA060.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE CRLF 				Chr( 13 )
#DEFINE CODUSUARIO			"MSALPHA"

/*******************************************************************
* Funcao: PWSA060 -
* Autor:	Juliana Barros Mariano
* Data:		04/05/2005
********************************************************************/
Web Function PWSA060()

Local cHtml		:= ""
Local oParam	:= ""
Local oMsg		:= ""

WEB EXTENDED INIT cHtml START "InSite"

oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
oMsg	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
WsChgURL(@oParam,"CFGDICTIONARY.APW")
WsChgURL(@oMsg,"RHPERSONALDESENVPLAN.APW")

HttpPost->cMsg := STR0001 //"Levantar o capital de conhecimento e experiência do profissional, bem como medir qualificações, domínio técnico-funcional, conhecimentos conceituais e certificações do participante."

//RESGATA PARAMETRO CONTENDO CODIGO DA MENSAGEM
//SE EM QUALQUER SITUACAO MSG NAUM ESTIVER CADASTRADA OU ESTIVER EM BRANCO, VALE MSG DEFAULT
If oParam:GETPARAM( CODUSUARIO, "MV_MSGMC" )
	If !Empty(oParam:cGETPARAMRESULT)
		If oMsg:GETMESSAGE( CODUSUARIO, oParam:cGETPARAMRESULT )
			If !Empty(oMsg:cGETMESSAGERESULT)
				HttpPost->cMsg := StrTran( oMsg:cGETMESSAGERESULT, Chr( 10 ), "<br>" )
			EndIf
		EndIf
	EndIf
EndIf


//PARAMETRO QUE VERIFICA SE APROVACAO DE VERSAO PODE FUNCIONAR OU NAO
//SE RETORNO DO PARAMETRO = 1 NAO EXISTIRAO APROVACOES DE VERSAO
//CASO CONTRARIO, CONTROLE DE VERSAO EXISTIRA NORMALMENTE
If oParam:GETPARAM( CODUSUARIO, "MV_APRVMPC" )
	HttpSession->cAprvMpc := AllTrim(oParam:cGETPARAMRESULT)
Else
	HttpSession->cAprvMpc := ""
EndIf

If oParam:GETPARAM( CODUSUARIO, "MV_APDINCB" )
	HttpSession->cApdIncB := AllTrim(oParam:cGETPARAMRESULT)
Else
	HttpSession->cApdIncB := "1"
EndIf

cHtml += ExecInPage( "PWSA060" )

WEB EXTENDED END

Return cHtml


/*******************************************************************
* Funcao: PWSA061 - Tela de selecao de mapa ou mapa de equipe
* Autor:	Juliana Barros Mariano
* Data:		16/05/2005
********************************************************************/
Web Function PWSA061()

Local cHtml		:= ""

Local oConhec	:= ""

Local aAvaliados := {}


WEB EXTENDED INIT cHtml START "InSite"

oConhec := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHKNOWLEDGE"), WSRHKNOWLEDGE():New())
WsChgURL(@oConhec,"RHKNOWLEDGE.APW")


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VERIFICAR AVALIADO POSSUI MAPA PENDENTE  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HttpPost->aMeuMapa := {}
	If oConhec:GETMYMAP( CODUSUARIO,HttpSession->cParticipantID )
		If !Empty(oConhec:oWSGETMYMAPRESULT:CCODMAP)
			HttpPost->aMeuMapa := {oConhec:oWSGETMYMAPRESULT}
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CONSULTA MAPAS DA EQUIPE (SE EXISTIR)    |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oConhec:BRWEVALUATED( CODUSUARIO, HttpSession->cParticipantID )
		//RETORNO
	    aAvaliados := oConhec:oWSBRWEVALUATEDRESULT:oWSMAPPARTICIPANT
		//ORDENACAO POR NOME
		HttpPost->aEquipe := aSort(aAvaliados,,, { |x, y| UPPER(x:cEvaluatedName) < UPPER(y:cEvaluatedName) })
	EndIf


	cHtml := ExecInPage( "PWSA061" )


WEB EXTENDED END

Return cHtml


/*******************************************************************
* Funcao: PWSA061A - Tela de selecao de avaliador
* Autor:	Juliana Barros Mariano
* Data:		16/05/2005
********************************************************************/
Web Function PWSA061A()
	Local cHtml		:= ""
	Local oPart		:= ""
	Local oConhec	:= ""
	
	
	WEB EXTENDED INIT cHtml START "InSite"
		oConhec := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHKNOWLEDGE"), WSRHKNOWLEDGE():New())
		oPart := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
		oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		
		WsChgURL(@oConhec,"RHKNOWLEDGE.APW")
		WsChgURL(@oPart,"RHPERSONALDESENVPLAN.APW")
		WsChgURL(@oParam,"CFGDICTIONARY.APW")
		
		//RESGATA PARAMETRO CONTENDO CODIGO DA MENSAGEM
		//SE EM QUALQUER SITUACAO MSG NAUM ESTIVER CADASTRADA OU ESTIVER EM BRANCO, VALE MSG DEFAULT
		If oParam:GETPARAM( CODUSUARIO, "MV_MSGMC" )
			If !Empty(oParam:cGETPARAMRESULT)
				If oPart:GETMESSAGE( CODUSUARIO, oParam:cGETPARAMRESULT )
					If !Empty(oPart:cGETMESSAGERESULT)
						HttpPost->cMsg := StrTran( oPart:cGETMESSAGERESULT, Chr( 10 ), "<br>" )
					EndIf
				EndIf
			EndIf
		EndIf
		
		
		//PARAMETRO QUE VERIFICA SE APROVACAO DE VERSAO PODE FUNCIONAR OU NAO
		//SE RETORNO DO PARAMETRO = 1 NAO EXISTIRAO APROVACOES DE VERSAO
		//CASO CONTRARIO, CONTROLE DE VERSAO EXISTIRA NORMALMENTE
		If oParam:GETPARAM( CODUSUARIO, "MV_APRVMPC" )
			HttpSession->cAprvMpc := AllTrim(oParam:cGETPARAMRESULT)
		Else
			HttpSession->cAprvMpc := ""
		EndIf
		
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ VERIFICAR AVALIADO POSSUI AVALIADOR CADASTRADO, CADASTRA  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oConhec:GETMYMAP( CODUSUARIO,HttpSession->cParticipantID )
			If Empty(oConhec:oWSGETMYMAPRESULT:CEVALUATORID) .And. !Empty(oConhec:oWSGETMYMAPRESULT:CCODMAP)
				HttpPost->aMapa := {oConhec:oWSGETMYMAPRESULT}
	
				//CONSULTA TODOS OS PARTICIPANTES PARA ESCOLHA DE AVALIADOR
				//If oPart:SHOWALLPARTICIPANT( CODUSUARIO,HttpSession->cParticipantID )
				//    HttpPost->aAvaliador := oPart:oWSSHOWALLPARTICIPANTRESULT:oWSUSER
					cHtml := ExecInPage( "PWSA061A" )
				//Else
				//	HttpSession->_HTMLERRO := { STR0002, PWSGetWSError(), "W_PWSA060.APW" } //"Erro"
			 	//	cHtml :=  ExecInPage("PWSAMSG")
				//EndIf
			Else
				cHtml := W_PWSA061()
			EndIf
		Else
			cHtml := W_PWSA061()
		EndIf
	WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao:	PWSA061B - Gravacao do avaliador no mapa de conhecimento
* Autor:	Juliana Barros Mariano
* Data:		23/05/2005
********************************************************************/
Web Function PWSA061B()

Local cHtml := ""
Local oConhec := {}

WEB EXTENDED INIT cHtml START "InSite"

oConhec := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHKNOWLEDGE"), WSRHKNOWLEDGE():New())
WsChgURL(@oConhec,"RHKNOWLEDGE.APW")

	//GRAVACAO DO AVALIADOR NA TABELA DE MAPAS
	If oConhec:PUTEVALUATEDMAP( CODUSUARIO, HttpSession->cParticipantId, HttpPost->cCodMapa, HttpPost->cAvaliador )

		cHtml := W_PWSA061()

    Else
    	HttpSession->_HTMLERRO := { STR0002, PWSGetWSError(), "W_PWSA061A.APW" } //"Erro"
		cHtml := ExecInPage("PWSAMSG" )
	EndIf


WEB EXTENDED END

Return cHtml


/*************************************************************/
/* Autor...: Emerson Grassi Rocha     		  Data: 17/01/06 */
/* Objetivo: Pop Up para selecionar o Mentor              	 */
/*************************************************************/
Web Function PWSA061C()
Local cHtml := ""
Local cNome := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHKNOWLEDGE"), WSRHKNOWLEDGE():New())
WsChgURL(@oObj,"RHKNOWLEDGE.APW")

if empty(HttpPost->cNome)
	cNome := ""
else
	cNome := HttpPost->cNome
endif

If oObj:brwMentors( CODUSUARIO, cNome )
	httpPost->aMentores 	:= 	oObj:oWSBRWMENTORSRESULT:OWSMENTORS
	cHtml := H_PWSAMaPop()
Else
	HttpSession->_HTMLERRO := { STR0002, PWSGetWSError(), "W_PWSA060.APW" }
 	Return ExecInPage("PWSAMSG" )
EndIf

WEB EXTENDED END

Return cHtml


/*************************************************************/
/* Autor...: Emerson Grassi Rocha     		  Data: 17/01/06 */
/* Objetivo: Alterar o avaliador     				         */
/*************************************************************/
Web Function PWSA061D()
Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHKNOWLEDGE"), WSRHKNOWLEDGE():New())
WsChgURL(@oObj,"RHKNOWLEDGE.APW")

If oObj:PutMentor( CODUSUARIO, HttpSession->cParticipantId, HttpGet->cMentor, HttpSession->HeaderPart[1]:cCodMap, HttpSession->HeaderPart[1]:cVersion )
	HttpSession->MentorName	:= HttpGet->cNomeMentor
	HttpSession->MentorId	:= HttpGet->cMentor

	HttpGet->cCodMentor := HttpGet->cMentor
	cHtml := "<script>alert('" + STR0009 + "!');</script>" //"Mentor alterado com sucesso"
	cHtml += W_PWSA062()
Else
	HttpSession->_HTMLERRO := { STR0002, PWSGetWSError(), "W_PWSA060.APW" }
	Return ExecInPage("PWSAMSG" )
EndIf

WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao:	PWSA062 - Consulta de Competencias
* Autor:	Juliana Barros Mariano
* Data:		16/05/2005
********************************************************************/
Web Function PWSA062()

Local cHtml := ""
Local oConhec := ""

WEB EXTENDED INIT cHtml START "InSite"

oConhec := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHKNOWLEDGE"), WSRHKNOWLEDGE():New())
WsChgURL(@oConhec,"RHKNOWLEDGE.APW")


	HttpSession->aCompetencia := {}
	HttpSession->aItem := NIL

	HttpPost->lLibAprovacao := .T.
	If Empty(HttpSession->lAltItem)
		HttpSession->lAltItem := .F.
	EndIf


	//tpAvaliador
	//1 - Participante
	//2 - Avaliador
	//3 - Mentor

	//PEGA DADOS DO PARTICIPANTE QUE ESTA ENTRANDO AGORA
	If !Empty(HttpPost->ParticipantID)
		HttpSession->cPartAcesso := {"",""}
		HttpSession->cPartAcesso[1] := HttpPost->ParticipantID
		HttpSession->cPartAcesso[2] := HttpPost->tpAvaliador
	EndIf

	//PEGA DADOS DO PARTICIPANTE LOGADO PARA HEADER DO MAPA - PENDENTE
	If oConhec:GETHEADERPART( CODUSUARIO, HttpSession->cPartAcesso[1], "1" )
	    HttpSession->HeaderPart := {oConhec:oWSGETHEADERPARTRESULT}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ PARA VERIFICAR SE EXISTE ALGUM ITEM ALTERADO  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oConhec:GETCHANGEDITEM( CODUSUARIO, HttpSession->cPartAcesso[1], HttpSession->HeaderPart[1]:CPartEvaluatorID, HttpSession->HeaderPart[1]:CCodMap, HttpSession->HeaderPart[1]:CVersion )
			HttpSession->lAltItem := oConhec:lGETCHANGEDITEMRESULT
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ NAO LIBERA O BOTAO APROVACAO SE NAO TIVER NENHUMA HABIL CADASTRADA  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpPost->lLibAprovacao := .F.
		EndIf


		//LISTA DE COMPETENCIAS
	    If oConhec:BRWCOMPETENCE( CODUSUARIO, HttpSession->HeaderPart[1]:CCodMap, HttpSession->cPartAcesso[1], HttpSession->HeaderPart[1]:CPartEvaluatorID )
	    	HttpSession->aCompetencia := oConhec:oWSBRWCOMPETENCERESULT:oWSCOMPETENCELIST
			cHtml := ExecInPage( "PWSA062" )
	    Else
	    	HttpSession->_HTMLERRO := { STR0002, PWSGetWSError(), "W_PWSA001.APW" } //"Erro"
			cHtml := ExecInPage( "PWSAMSG" )
		EndIf

	Else
		HttpSession->_HTMLERRO := { STR0002, PWSGetWSError(), "W_PWSA061.APW" } //"Erro"
 		cHtml := ExecInPage( "PWSAMSG" )
	EndIf


WEB EXTENDED END

Return cHtml


/*******************************************************************
* Funcao: PWSA061 - Consulta de todos os participantes que estao
*					abaixo do participante logado
* Autor:	Juliana Barros Mariano
* Data:		24/11/2004
********************************************************************/
Web Function PWSA063()

Local cHtml		:= ""
Local cString	:= ""
Local cComent	:= ""
Local aCampos	:= {}
Local oItem		:= {}

WEB EXTENDED INIT cHtml START "InSite"

oItem := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHKNOWLEDGE"), WSRHKNOWLEDGE():New())
WsChgURL(@oItem,"RHKNOWLEDGE.APW")

If Empty(HttpPost->aItem)
	HttpPost->aItem := {}
EndIf


//GRAVA DESCRICAO DA COMPETENCIA NA SESSION PARA MOSTRAR NO TOPO DA PAGINA
If !Empty(HttpPost->cCompDesc)
	HttpSession->cComp := {HttpPost->cCompId,HttpPost->cCompDesc}
EndIf

    If oItem:BRWITEMCOMPETENCE( CODUSUARIO, HttpSession->cComp[1], HttpSession->HeaderPart[1]:CCODMAP, HttpSession->HeaderPart[1]:CPARTID, HttpSession->HeaderPart[1]:CPartEvaluatorID )

		//GRAVA NA SESSION PARA PODER SALVAR AS HABILIDADES DEPOIS
		HttpSession->aMapa := oItem:oWSBRWITEMCOMPETENCERESULT:OWSLISTOFITEM:OWSITEMLIST
		Recursivo( oItem:oWSBRWITEMCOMPETENCERESULT:OWSLISTOFITEM:OWSITEMLIST, @cString, @cComent, @aCampos )

        HttpPost->aItem			:= cString
        HttpPost->cComentario	:= cComent
        HttpPost->aCampos		:= aCampos

		cHtml := ExecInPage( "PWSA063" )
    Else
  	HttpSession->_HTMLERRO := { STR0002, PWSGetWSError(), "W_PWSA001.APW" } //"Erro"
		cHtml := ExecInPage("PWSAMSG" )
	EndIf


WEB EXTENDED END

Return cHtml


/*******************************************************************
* Funcao: Recursivo -
* Autor:	Juliana Barros Mariano
* Data:		10/03/2005
********************************************************************/
Static Function Recursivo( aTree, cHtml, cComentario, aCampos )

Local lRetorno	:= .T.
Local nCont := 0
Local nI := 0
Local nY := 0
Local nJ := 0

Local cDesc		:= ""
Local cCod		:= ""
Local cQuestao	:= ""
Local cParam	:= HttpSession->cApdIncB
Local cStatus	:= ""

Local aHabil	:= {}
Local aStatus 	:= {}

For nI := 1 To Len( aTree )
	cHtml += "<table>" + CRLF
	cHtml += "  <tr>" + CRLF
	cHtml += "    <td class='info-esq'>" + CRLF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PARA VERIFICAR STATUS DAS HABILIDADES DO NIVEL ATUAL  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cStatus	:= ""
	aStatus := {}
	If len(aTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST) > 0 //HABILIDADES
		For nY := 1 to len(aTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST)
			aadd( aStatus, aTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST[nY]:CSKILLSTATUS )
		Next
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ FUNCAO QUE VERIFICA STATUS DAS HABILIDADES  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	StatusRec( aTree[nI]:OWSLISTOFITEM:OWSITEMLIST, 1, @aStatus )
	//VERIFICAR PRIORIDADES DO STATUS
	If ascan( aStatus, "4" ) > 0
		cStatus := "4"
	ElseIf ascan( aStatus, "2" ) > 0
		cStatus := "2"
	ElseIf ascan( aStatus, "3" ) > 0
		cStatus := "3"
	ElseIf ascan( aStatus, "1" ) > 0
		cStatus := "1"
	Endif

	If cStatus == "2" .Or. cStatus == "4"
		cHtml += "		<img src='imagens-rh/tick_amarelo2.gif' border='0'>&nbsp;" + CRLF
	ElseIf cStatus == "3"
		cHtml += "		<img src='imagens-rh/tick_verde.gif' border='0'>&nbsp;" + CRLF
	Else
		cHtml += "		<img src='imagens-rh/tick_branco.gif' border='0'>&nbsp;" + CRLF
	EndIf

	If len(aTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST) > 0 //HABILIDADES
	    cHtml += "	<a class='links' href=javascript:DinMenu(b" + AllTrim(str(val(aTree[nI]:cCompetenceItem))) + ",'img" + AllTrim(str(val(aTree[nI]:cCompetenceItem))) + "',1);><img id='img" + AllTrim(str(val(aTree[nI]:cCompetenceItem))) + "' name='img" + AllTrim(str(val(aTree[nI]:cCompetenceItem))) + "' src='imagens-rh/plus.gif' border='0'></a>" + CRLF
	ElseIf len(aTree[nI]:OWSLISTOFITEM:OWSITEMLIST) > 0 //ITEM DE COMPETENCIA
	    cHtml += "	<a class='links' href=javascript:DinMenu(a" + AllTrim(str(val(aTree[nI]:cCompetenceItem))) + ",'img" + AllTrim(str(val(aTree[nI]:cCompetenceItem))) + "',0);><img id='img" + AllTrim(str(val(aTree[nI]:cCompetenceItem))) + "' name='img" + AllTrim(str(val(aTree[nI]:cCompetenceItem))) + "' src='imagens-rh/plus.gif' border='0'></a>" + CRLF
    Else
    	cHtml += "	<img src='imagens-rh/minus.gif' border='0'>" + CRLF   //mnupage //rule //minus
    EndIf
    cHtml +=       aTree[nI]:cCompetenceItemDesc + CRLF
	cHtml += "</div></td>" + CRLF
	cHtml += "  </tr>" + CRLF
	aHabil := aTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST
	If len(aHabil) > 0
		cHtml += "  <tr>" + CRLF
		cHtml += "    <td>" + CRLF
		cHtml += "    	<table style='display:none' id='b" + AllTrim(str(val(aTree[nI]:cCompetenceItem))) + "'>" + CRLF
		For nY := 1 to len(aHabil)
			cCod := AllTrim(str(val(aTree[nI]:cCompetenceId))) + AllTrim(str(val(aTree[nI]:cCompetenceItem))) + AllTrim(str(val(aHabil[nY]:CSKILLID)))

			cHtml += "		<tr>" + CRLF
			cHtml += "			<td class='info-esq'>" + CRLF
		    cHtml += "				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + CRLF
			If aHabil[nY]:CSKILLSTATUS == "3"
		    	cHtml += "				<img src='imagens-rh/tick_verde.gif' border='0'>"
			ElseIf aHabil[nY]:CSKILLSTATUS == "2" .Or. aHabil[nY]:CSKILLSTATUS == "4"
		    	cHtml += "				<img src='imagens-rh/tick_amarelo2.gif' border='0'>"
			Else
	    		cHtml += "				<img src='imagens-rh/tick_branco.gif' border='0'>"
			EndIf
			cHtml += "				<a class='links' href='javascript:DinMenu2(cMCom" + cCod + ");'>&nbsp;" + AllTrim(aHabil[nY]:CSKILLDESCRIPTION) + "&nbsp;</a></td>" + CRLF
			cHtml += "			<td class='info-esq'>" + CRLF
	    	cHtml += "				<select name='cHab" + cCod + "'  "
	    	If HttpPost->cCompType != "2"
	    		cHtml += "disabled"
	    	ElseIf HttpSession->cParticipantId != HttpSession->cPartAcesso[1] .And. HttpSession->HeaderPart[1]:cAuthor != "2"
	    		cHtml += "disabled"
	    	ElseIf HttpSession->cParticipantId == HttpSession->cPartAcesso[1] .And. HttpSession->HeaderPart[1]:cAuthor == "2"
	    		cHtml += "disabled"
			EndIf
			cHtml += "> " + CRLF
			If Empty(aHabil[nY]:CSKILLLEVELANSWER)
	    	cHtml += "				<option selected>---</option>" + CRLF
			EndIf
			cDesc := ""
			For nJ := 1 to len(aHabil[nY]:OWSLISTOFLEVEL:OWSLEVELLIST)
				cDesc += aHabil[nY]:OWSLISTOFLEVEL:OWSLEVELLIST[nJ]:cLevelId + " - " + AllTrim(aHabil[nY]:OWSLISTOFLEVEL:OWSLEVELLIST[nJ]:cLevelDescription) + chr(13)
				cQuestao := ""
				For nCont := 1 to Len(cParam)
					If Substr(cParam, nCont, 1) == "1"
						cQuestao += AllTrim(aHabil[nY]:OWSLISTOFLEVEL:OWSLEVELLIST[nJ]:cLevelId) + " - "
					ElseIf Substr(cParam, nCont, 1) == "2"
						cQuestao += AllTrim(aHabil[nY]:OWSLISTOFLEVEL:OWSLEVELLIST[nJ]:cLevelDescription) + " - "
					EndIf
				Next nCont
				If !Empty(cQuestao)
					cQuestao := Substr(cQuestao, 1, Len(cQuestao) - 3)
				EndIf
		    	cHtml += "				<option value='" + aHabil[nY]:OWSLISTOFLEVEL:OWSLEVELLIST[nJ]:cLevelId + "' "
				If aHabil[nY]:CSKILLLEVELANSWER == aHabil[nY]:OWSLISTOFLEVEL:OWSLEVELLIST[nJ]:cLevelId
		    		cHtml += "selected"
	    		EndIf
		    	cHtml += ">" + cQuestao + "</option>" + CRLF
			Next
	    	cHtml += "				</select> <img src='imagens-rh/help.png' title='" + cDesc + "' width='18' height='18' border='0'></td>" + CRLF

			cHtml += "			</td>" + CRLF
			cHtml += "  	</tr>" + CRLF



			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ MONTA CAMPO DE COMENTARIOS DO AVALIADO E AVALIADOR  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ADICIONAR NO ARRAY OS NOMES DOS CAMPOS TEXTAREA DE COMENTARIO
			aadd(aCampos, "cMCom" + cCod )

			cComentario += "<div  style='display:none' id='cMCom" + cCod + "'>"
			cComentario += "<table>"
			cComentario += "<tr>"
			cComentario += "<td>"
			cComentario += "<table>"
			cComentario += "<tr>"
			cComentario += "<td colspan='2'>&nbsp;" + STR0004 + " - " + AllTrim(aHabil[nY]:CSKILLDESCRIPTION) 
			cComentario += "</td><!--Comentários Gerais do Avaliado-->"
			cComentario += "</tr>"
			cComentario += "<tr>"
			cComentario += "<td><textarea id='cCAdo" + cCod + "' name='cCAdo" + cCod + "'  cols='98%' rows='4'"
			If HttpSession->cPartAcesso[1] != HttpSession->cParticipantId .Or. HttpSession->HeaderPart[1]:cAuthor == "2" .Or. HttpPost->cCompType != "2"
				cComentario += "readonly"
			EndIf
			cComentario += ">" + aHabil[nY]:CEVALUATEDCOM + "</textarea></td>"
			cComentario += "</tr>"
			cComentario += "</table></td></tr></table>"
			cComentario += "<br>"

		 	If HttpSession->cAprvMpc != "1"
				cComentario += "<table>"
				cComentario += "<tr>"
				cComentario += "<td>"
				cComentario += "<table>"
				cComentario += "<tr>"
				cComentario += "<td colspan='2'>&nbsp;" + STR0005 + " - " + AllTrim(aHabil[nY]:CSKILLDESCRIPTION)
				cComentario += "</td><!--Comentários Gerais do Avaliador-->"
				cComentario += "</tr>"
				cComentario += "<tr>"
				cComentario += "<td><textarea id='cCDor" + cCod + "' name='cCDor" + cCod + "'  cols='98%' rows='4'"
				If HttpSession->cPartAcesso[1] == HttpSession->cParticipantId .Or. HttpSession->HeaderPart[1]:cAuthor != "2" .Or. HttpPost->cCompType != "2"
					cComentario += "readonly"
				EndIf
				cComentario += ">" + aHabil[nY]:CEVALUATORCOM + "</textarea></td>"
				cComentario += "</tr>"
				cComentario += "</table></td></tr></table>"
				cComentario += "<br>"
			EndIf
			cComentario += "</div>"

			//HttpSession->HeaderPart[1]:cAuthor := aHabil[nY]:CSKILLAUTHOR //AVALIADO = 1; AVALIADOR = 2
		Next
		cHtml += "  	</table>" + CRLF
		cHtml += "	  </td>" + CRLF
		cHtml += " 	</tr>" + CRLF




	EndIf
	cHtml += "  <tr>" + CRLF
	cHtml += "    <td>" + CRLF
	cHtml += "    <table style='display:none' id='a" + AllTrim(str(val(aTree[nI]:cCompetenceItem))) + "'><tr><td>" + CRLF

	Recursivo( aTree[nI]:OWSLISTOFITEM:OWSITEMLIST, @cHtml, @cComentario, @aCampos )

	cHtml += "    </td></tr></table>" + CRLF
	cHtml += "    </td>" + CRLF
	cHtml += "  </tr>" + CRLF
	cHtml += "</table>" + CRLF
Next nI

Return lRetorno



/*******************************************************************
* Funcao: StatusRec -
* Autor:	Juliana Barros Mariano
* Data:		14/06/2005
********************************************************************/
Static Function StatusRec( aTree, nLen, aStatus, cAutor )

Local lRetorno := .T.
Local nI := 0
Local nY := 0
Local aHabil := {}

DEFAULT nLen := 1

For nI := nLen To Len( aTree )

	If len(aTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST) > 0 //HABILIDADES
		aHabil := aTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST
		If len(aHabil) > 0
			For nY := 1 to len(aHabil)
				//SE AUTOR FOR AVALIADOR JA NA PRECISA GRAVAR MAIS
				If cAutor != "2"
					cAutor := aHabil[nY]:CSKILLAUTHOR
				EndIf
				aadd( aStatus, aHabil[nY]:CSKILLSTATUS )
/*				If aHabil[nY]:CSKILLSTATUS == "3" //APROVADO
					If cStatus != "2" .And. cStatus != "4"
						cStatus := "3"
					EndIf
				ElseIf aHabil[nY]:CSKILLSTATUS == "2" .Or. aHabil[nY]:CSKILLSTATUS == "4"  //PENDENTE
					cStatus := aHabil[nY]:CSKILLSTATUS
				EndIf*/
			Next
		EndIf
	EndIf
	StatusRec( aTree[nI]:OWSLISTOFITEM:OWSITEMLIST, , @aStatus, @cAutor )

Next nI

Return lRetorno





/*******************************************************************
* Funcao: PWSA064 - Consulta de todos os participantes que estao
*					abaixo do participante logado
* Autor:	Juliana Barros Mariano
* Data:		16/12/2004
********************************************************************/
Web Function PWSA064()


Local cHtml		:= ""
Local oHabil	:= ""

WEB EXTENDED INIT cHtml START "InSite"

oHabil := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHKNOWLEDGE"), WSRHKNOWLEDGE():New())
WsChgURL(@oHabil,"RHKNOWLEDGE.APW")

oHabil:oWSLEVELSKILL:oWSSKILLS := WSCLASSNEW("RHKNOWLEDGE_ARRAYOFSKILLLEVEL")
oHabil:oWSLEVELSKILL:oWSSKILLS:oWSSKILLLEVEL := {}

PWSA064REC(HttpSession->aMapa, @oHabil:oWSLEVELSKILL:oWSSKILLS:oWSSKILLLEVEL)


If oHabil:PUTLEVELSKILL( CODUSUARIO, HttpSession->HeaderPart[1]:CCodMap, HttpSession->cPartAcesso[1] , HttpSession->HeaderPart[1]:CPartEvaluatorID, HttpSession->HeaderPart[1]:cAuthor, oHabil:oWSLEVELSKILL )
	HttpSession->lAltItem := oHabil:lPUTLEVELSKILLRESULT
	cHtml := W_PWSA062()
Else

  	HttpSession->_HTMLERRO := { STR0003, PWSGetWSError(), "W_PWSA063.APW" } //"Mensagem"
	cHtml := ExecInPage("PWSAMSG" )
EndIf

WEB EXTENDED END

Return cHtml


/*******************************************************************
* Funcao: PWSA064REC - Consulta de todos os participantes que estao
*					abaixo do participante logado
* Autor:	Juliana Barros Mariano
* Data:		16/12/2004
********************************************************************/
Static Function PWSA064REC(oTree, oGrava)

Local nI		:= 0
Local nY 		:= 0
Local cHab		:= ""
Local lRetorno	:= .T.
Local oRet		:= {}



For nI := 1 To Len( oTree )
	If len(oTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST) > 0 //HABILIDADES
		For nY := 1 to len(oTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST)

			cHab := &("HttpPost->cHab"+AllTrim(str(val(oTree[nI]:cCompetenceId)))+AllTrim(str(val(oTree[nI]:cCompetenceItem)))+AllTrim(str(val(oTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST[nY]:cSKILLID))))
			If !Empty(cHab) .And. cHab != "---"
				oRet := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHKNOWLEDGE_SKILLLEVEL"), RHKNOWLEDGE_SKILLLEVEL():New())

				//OBRIGATORIO
				oRet:cCOMPETENCEID		:= oTree[nI]:cCompetenceId
				oRet:cCOMPETENCEITEMID	:= oTree[nI]:cCompetenceItem
				oRet:cEVALUATEDID       := HttpSession->HeaderPart[1]:CPARTID
				oRet:cEVALUATORID       := HttpSession->HeaderPart[1]:CPartEvaluatorID
				oRet:cCodMap           := HttpSession->HeaderPart[1]:CCodMap
				oRet:cSKILLID           := oTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST[nY]:cSKILLID

				//NAO OBRIGATORIO
				If HttpSession->cParticipantId == HttpSession->cPartAcesso[1]
					oRet:cMAPACCESS		:= "1"
					oRet:cEVALUATEDCOM	:=  &("HttpPost->cCAdo"+AllTrim(str(val(oTree[nI]:cCompetenceId)))+AllTrim(str(val(oTree[nI]:cCompetenceItem)))+AllTrim(str(val(oTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST[nY]:cSKILLID))))
				Else
					oRet:cMAPACCESS		:= "2"
					oRet:cEVALUATORCOM	:=  &("HttpPost->cCDor"+AllTrim(str(val(oTree[nI]:cCompetenceId)))+AllTrim(str(val(oTree[nI]:cCompetenceItem)))+AllTrim(str(val(oTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST[nY]:cSKILLID))))
				EndIf
				oRet:cITEMVERSION		:=  HttpSession->HeaderPart[1]:CVERSION
				oRet:cLEVELID			:=  oTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST[nY]:cSKILLLEVEL
				oRet:cLEVELITEMID		:=  &("HttpPost->cHab"+AllTrim(str(val(oTree[nI]:cCompetenceId)))+AllTrim(str(val(oTree[nI]:cCompetenceItem)))+AllTrim(str(val(oTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST[nY]:cSKILLID))))


				aAdd( oGrava, oRet )
			EndIf

		Next nY

    EndIf

	PWSA064REC( oTree[nI]:OWSLISTOFITEM:OWSITEMLIST, oGrava )

Next nI


Return lRetorno



/*******************************************************************
* Funcao: PWSA065 - Envia para revisao
* Autor:	Juliana Barros Mariano
* Data:		06/06/2005
********************************************************************/
Web Function PWSA065()

Local cHtml		:= ""
Local cString	:= ""

Local oConhec	:= ""
Local oItem		:= ""

Local nI		:= 0

Local aComp		:= {}

//Local lLibera	:= .T.


WEB EXTENDED INIT cHtml START "InSite"

oConhec := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHKNOWLEDGE"), WSRHKNOWLEDGE():New())
oItem := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHKNOWLEDGE"), WSRHKNOWLEDGE():New())
WsChgURL(@oConhec,"RHKNOWLEDGE.APW")
WsChgURL(@oItem,"RHKNOWLEDGE.APW")


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ANTES DE GRAVAR, VERIFICA SE TODAS AS HABILIDADES FORAM PREENCHIDAS	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If oConhec:BRWCOMPETENCE( CODUSUARIO, HttpSession->HeaderPart[1]:CCODMAP, HttpSession->cPartAcesso[1], HttpSession->HeaderPart[1]:CPartEvaluatorID )
		aComp := oConhec:oWSBRWCOMPETENCERESULT:oWSCOMPETENCELIST
		For nI := 1 to len(aComp)
			If aComp[nI]:cCOMPETENCETYPE == "2"		//DISPONIVEL PARA ATUALIZACAO

			    If oItem:BRWITEMCOMPETENCE( CODUSUARIO, aComp[nI]:cCOMPETENCEID, HttpSession->HeaderPart[1]:CCODMAP, HttpSession->HeaderPart[1]:CPARTID, HttpSession->HeaderPart[1]:CPartEvaluatorID )

					PWSA065REC( oItem:oWSBRWITEMCOMPETENCERESULT:OWSLISTOFITEM:OWSITEMLIST, @cString )


					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ EXISTEM HABILIDADES QUE NAO FORAM PREENCHIDAS	|
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(cString)
//						lLibera	:= .F.
						HttpPost->cScript := "<script>alert('Existem habilidades não preenchidas: \n\n"
						HttpPost->cScript += cString
						HttpPost->cScript += "')</script>"
					EndIf
				EndIf

			EndIf

		Next nI
	EndIf

//	If lLibera == .T.

		If oConhec:SETTOREVISION( CODUSUARIO, HttpSession->HeaderPart[1]:CCODMAP, HttpSession->cPartAcesso[1] , HttpSession->HeaderPart[1]:CPartEvaluatorID, HttpSession->HeaderPart[1]:cAuthor )
			If HttpSession->HeaderPart[1]:cAuthor == "2"
				HttpSession->HeaderPart[1]:cAuthor := "1"
				HttpPost->cScript2 := "<script>alert('" + STR0007 + "');</script>" //Mapa de conhecimento enviado para revisão do avaliado
			Else
				HttpSession->HeaderPart[1]:cAuthor := "2"
				HttpPost->cScript2 := "<script>alert('" + STR0006 + "');</script>" //Mapa de conhecimento enviado para revisão do avaliador
			EndIf
			cHtml := W_PWSA062()
		Else
		  	HttpSession->_HTMLERRO := { STR0003, PWSGetWSError(), "W_PWSA063.APW" } //"Mensagem"
			cHtml := ExecInPage("PWSAMSG" )
		EndIf
/*	Else
		cHtml := W_PWSA062()
	EndIf*/


WEB EXTENDED END

Return cHtml


/*******************************************************************
* Funcao: PWSA065REC -
* Autor:	Juliana Barros Mariano
* Data:		09/06/2005
********************************************************************/
Static Function PWSA065REC(oTree, cString)

Local nI		:= 0
Local nY 		:= 0
Local lRetorno	:= .T.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VERIFICA QUAIS HABILIDADES NAO FORAM PREENCHIDAS	|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( oTree )
	If len(oTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST) > 0 //HABILIDADES
		For nY := 1 to len(oTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST)

			If Empty(oTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST[nY]:cSKILLLEVELANSWER)
				cString += "Competência: " + AllTrim(oTree[nI]:cCOMPETENCEDESC) + " - Item: " + (oTree[nI]:cCOMPETENCEITEMDESC) + " - Habilidade: " + AllTrim(oTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST[nY]:cSKILLDESCRIPTION) + "; \n"
			EndIf

		Next nY

    EndIf

	PWSA065REC( oTree[nI]:OWSLISTOFITEM:OWSITEMLIST, @cString )

Next nI


Return lRetorno



/*******************************************************************
* Funcao: PWSA066 - Envia para revisao do avaliado
* Autor:	Juliana Barros Mariano
* Data:		06/06/2005
********************************************************************/
Web Function PWSA066()

Local cHtml		:= ""
Local oHabil	:= ""

WEB EXTENDED INIT cHtml START "InSite"

oHabil := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHKNOWLEDGE"), WSRHKNOWLEDGE():New())
WsChgURL(@oHabil,"RHKNOWLEDGE.APW")

oHabil:oWSLEVELSKILL:oWSSKILLS := WSCLASSNEW("RHKNOWLEDGE_ARRAYOFSKILLLEVEL")
oHabil:oWSLEVELSKILL:oWSSKILLS:oWSSKILLLEVEL := {}

PWSA066REC(HttpSession->aMapa, @oHabil:oWSLEVELSKILL:oWSSKILLS:oWSSKILLLEVEL)


If oHabil:SETEVALUATORREVISION( CODUSUARIO, oHabil:oWSLEVELSKILL )
	HttpPost->cScript := "<script>alert('" + STR0007 + "');</script>" //Mapa de conhecimento enviado para revisão do avaliado
	cHtml := W_PWSA062()
Else

  	HttpSession->_HTMLERRO := { STR0003, PWSGetWSError(), "W_PWSA063.APW" } //"Mensagem"
	cHtml := ExecInPage("PWSAMSG" )
EndIf


WEB EXTENDED END

Return cHtml

/*******************************************************************
* Funcao: PWSA066REC -
* Autor:	Juliana Barros Mariano
* Data:		06/06/2005
********************************************************************/
Static Function PWSA066REC(oTree, oGrava)

Local nI		:= 0
Local nY 		:= 0
Local cCom		:= ""
Local lRetorno	:= .T.
Local oRet		:= {}



For nI := 1 To Len( oTree )
	If len(oTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST) > 0 //HABILIDADES
		For nY := 1 to len(oTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST)

			cCom := &("HttpPost->cCDor"+AllTrim(str(val(oTree[nI]:cCompetenceId)))+AllTrim(str(val(oTree[nI]:cCompetenceItem)))+AllTrim(str(val(oTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST[nY]:cSKILLID))))
			//If !Empty(cCom)
				oRet := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHKNOWLEDGE_SKILLLEVEL"), RHKNOWLEDGE_SKILLLEVEL():New())

				//OBRIGATORIO
				oRet:cCOMPETENCEID		:= oTree[nI]:cCompetenceId
				oRet:cCOMPETENCEITEMID	:= oTree[nI]:cCompetenceItem
				oRet:cEVALUATEDID       := HttpSession->HeaderPart[1]:CPARTID
				oRet:cEVALUATORID       := HttpSession->HeaderPart[1]:CPartEvaluatorID
				oRet:cCodMap           := HttpSession->HeaderPart[1]:CCodMap
				oRet:cSKILLID           := oTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST[nY]:cSKILLID

				//NAO OBRIGATORIO
				oRet:cMAPACCESS		:= "2" //avaliador
				oRet:cEVALUATORCOM	:=  cCom
				oRet:cITEMVERSION	:=  HttpSession->HeaderPart[1]:CVERSION

				aAdd( oGrava, oRet )
			//EndIf

		Next nY

    EndIf

	PWSA066REC( oTree[nI]:OWSLISTOFITEM:OWSITEMLIST, oGrava )

Next nI


Return lRetorno



/*******************************************************************
* Funcao: PWSA067 - Aprovar mapa
* Autor:	Juliana Barros Mariano
* Data:		07/06/2005
* Alterado:	Juliana Barros - 30/09/2005
********************************************************************/
Web Function PWSA067()

Local cHtml		:= ""
Local cParam	:= ""
Local oHabil	:= ""
Local oParam    := ""

WEB EXTENDED INIT cHtml START "InSite"

oHabil := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHKNOWLEDGE"), WSRHKNOWLEDGE():New())
oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
WsChgURL(@oHabil,"RHKNOWLEDGE.APW")
WsChgURL(@oParam,"CFGDICTIONARY.APW")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PARAMETRO QUE VERIFICA SE E NECESSARIO GRAVAR DADOS DA TABELA RBQ 	 |
//³ RBQ NA TABELA RBI. RETORNO:										     |
//³ 0 = Nao Integra; 1 = Integra valores; 2 = Integra valores e cadastro |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oParam:GETPARAM( CODUSUARIO, "MV_MPC2CSA" )
	cParam := oParam:cGETPARAMRESULT
EndIf


If oHabil:APPROVEMAP( CODUSUARIO, HttpSession->HeaderPart[1]:CCODMAP, HttpSession->cPartAcesso[1] , HttpSession->HeaderPart[1]:CPartEvaluatorID, cParam )
	HttpPost->cScript := "<script>alert('" + STR0008 + "!');</script>" //Mapa aprovado com sucesso
	cHtml := W_PWSA062()
Else
  	HttpSession->_HTMLERRO := { STR0003, PWSGetWSError(), "W_PWSA063.APW" } //"Mensagem"
	cHtml := ExecInPage("PWSAMSG" )
EndIf

WEB EXTENDED END

Return cHtml



/*******************************************************************
* Funcao: PWSA068 -
* Autor:	Juliana Barros Mariano
* Data:		08/06/2005
********************************************************************/
Web Function PWSA068()

Local cHtml	:= ""
Local oHist	:= ""


WEB EXTENDED INIT cHtml START "InSite"

oHist := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHKNOWLEDGE"), WSRHKNOWLEDGE():New())
WsChgURL(@oHist,"RHKNOWLEDGE.APW")

	HttpPost->aMeuMapa	:= {}
	HttpPost->aEquipe	:= {}

	//PEGA DADOS DO PARTICIPANTE LOGADO
	If oHist:GETMAPHISTORY( CODUSUARIO,HttpSession->cParticipantId, "1" )
		HttpPost->aMeuMapa	:= oHist:oWSGETMAPHISTORYRESULT:oWSHISTORYMAP
	EndIf


	//PEGA DADOS DA EQUIPE
	If oHist:GETMAPHISTORY( CODUSUARIO, HttpSession->cParticipantID, "2" )
	    HttpPost->aEquipe := oHist:oWSGETMAPHISTORYRESULT:oWSHISTORYMAP
		HttpPost->aEquipe := aSort(HttpPost->aEquipe,,, { |x, y| UPPER(x:cPARTICIPANTNAME) < UPPER(y:cPARTICIPANTNAME) })  //ORDENACAO
	EndIf

	cHtml := ExecInPage( "PWSA064" )


WEB EXTENDED END

Return cHtml

/*******************************************************************
* Funcao: PWSA068 -
* Autor:	Juliana Barros Mariano
* Data:		08/06/2005
********************************************************************/
Web Function PWSA069()

Local cHtml	:= ""
Local oHist	:= ""


WEB EXTENDED INIT cHtml START "InSite"

oHist := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHKNOWLEDGE"), WSRHKNOWLEDGE():New())
WsChgURL(@oHist,"RHKNOWLEDGE.APW")

//1=NO PRAZO
//2=FINALIZADO
If Empty(HttpPost->cTipo)
	HttpPost->cTipo := "2"
EndIf

	//PEGA DADOS DO PARTICIPANTE QUE ESTA ENTRANDO AGORA
	If !Empty(HttpPost->ParticipantID)
		HttpSession->cPartAcesso := {"","",""}
		HttpSession->cPartAcesso[1] := HttpPost->ParticipantID
		HttpSession->cPartAcesso[2] := HttpPost->tpAvaliador
		HttpSession->cPartAcesso[3] := HttpPost->cTipo
	EndIf

	//PEGA DADOS DO PARTICIPANTE LOGADO PARA HEADER DO MAPA - FINALIZADO
	If oHist:GETHEADERPART( CODUSUARIO, HttpSession->cPartAcesso[1], HttpPost->cTipo, HttpPost->cCodMap )
	    HttpSession->HeaderPart := {oHist:oWSGETHEADERPARTRESULT}
	EndIf


	//SE FOR FINALIZADO VAI DIRETO PARA VISUALIZACAO DA ULTIMA VERSAO
	If HttpPost->cTipo == "2"
		cHtml := W_PWSA069A()
	Else
		cHtml := ExecInPage( "PWSA065" )
	EndIf



WEB EXTENDED END

Return cHtml



/*******************************************************************
* Funcao: PWSA069A - Consulta Historico
* Autor:	Juliana Barros Mariano
* Data:		13/06/2005
********************************************************************/
Web Function PWSA069A()

Local cHtml		:= ""
Local cString	:= ""
Local oHist		:= ""


WEB EXTENDED INIT cHtml START "InSite"

oHist := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHKNOWLEDGE"), WSRHKNOWLEDGE():New())
WsChgURL(@oHist,"RHKNOWLEDGE.APW")


If oHist:BRWHISTORY( CODUSUARIO, HttpSession->HeaderPart[1]:CPARTID, HttpSession->HeaderPart[1]:CPARTEVALUATORID, HttpSession->HeaderPart[1]:CCODMAP, HttpPost->cVersao )

	PWSA069ARec( oHist:oWSBRWHISTORYRESULT:OWSLISTOFITEM:OWSITEMLIST, @cString )

	HttpPost->aItem := cString
EndIf

cHtml := ExecInPage( "PWSA066" )


WEB EXTENDED END

Return cHtml


/*******************************************************************
* Funcao: Recursivo -
* Autor:	Juliana Barros Mariano
* Data:		10/03/2005
********************************************************************/
Static Function PWSA069ARec( aTree, cHtml, cComp )

Local lRetorno	:= .T.
Local lLibera	:= .F.
Local nI := 0
Local nY := 0
Local nJ := 0
Local cDesc := ""
Local cCod	:= ""
Local aHabil := {}

For nI := 1 To Len( aTree )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VERIFICA PRIMEIRO SE EXISTE HABILIDADE NO NIVEL ATUAL	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If len(aTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST) > 0
		lLibera := .T.
	Else
		lLibera := AchaHabilRec( aTree[nI]:OWSLISTOFITEM:OWSITEMLIST, nI, .F. )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SE EXISTIR ALGUMA HABILIDADE PREENCHIDA NO NIVEL ATUAL OU EM ALGUM NIVEL ABAIXO, LIBERA	|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLibera == .T.

		If cComp != aTree[nI]:cCompetenceId
			cComp := aTree[nI]:cCompetenceId
			cHtml += "<h4>" + aTree[nI]:cCompetenceDesc + "</h4>" + CRLF
		EndIf
		cHtml +=      "<table><tr><td colspan='2'><b>"
	    cHtml +=       AllTrim(aTree[nI]:cCompetenceItemDesc) + "</b></td>"+ CRLF
		aHabil := aTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST
		If len(aHabil) > 0
			For nY := 1 to len(aHabil)
				cHtml += "  <tr>" + CRLF
				cHtml += "    	<td></td>" + CRLF
				cCod := AllTrim(str(val(aTree[nI]:cCompetenceId))) + AllTrim(str(val(aTree[nI]:cCompetenceItem))) + AllTrim(str(val(aHabil[nY]:CSKILLID)))

				cHtml += "			<td><label>" + AllTrim(aHabil[nY]:CSKILLDESCRIPTION)  + CRLF
		    	cHtml += "				</label><select name='cHab" + cCod + "' disabled> " + CRLF
				cDesc := ""
				For nJ := 1 to len(aHabil[nY]:OWSLISTOFLEVEL:OWSLEVELLIST)
					cDesc += aHabil[nY]:OWSLISTOFLEVEL:OWSLEVELLIST[nJ]:cLevelId + " - " + AllTrim(aHabil[nY]:OWSLISTOFLEVEL:OWSLEVELLIST[nJ]:cLevelDescription) + chr(13)
			    	cHtml += "				<option value='" + aHabil[nY]:OWSLISTOFLEVEL:OWSLEVELLIST[nJ]:cLevelId + "' "
					If aHabil[nY]:CSKILLLEVELANSWER == aHabil[nY]:OWSLISTOFLEVEL:OWSLEVELLIST[nJ]:cLevelId
			    		cHtml += "selected"
		    		EndIf
			    	cHtml += ">" + aHabil[nY]:OWSLISTOFLEVEL:OWSLEVELLIST[nJ]:cLevelId + "</option>" + CRLF
				Next
		    	cHtml += "				</select><img src='imagens-rh/help.png' title='" + cDesc + "' width='18' height='18' border='0'></td>" + CRLF

				cHtml += "			</td>" + CRLF
				cHtml += "  	</tr>" + CRLF

			Next
			cHtml += "  	</table>" + CRLF
			
		EndIf
		
		PWSA069ARec( aTree[nI]:OWSLISTOFITEM:OWSITEMLIST, @cHtml, @cComp )

	EndIf

Next nI

Return lRetorno


/*******************************************************************
* Funcao: AchaHabilRec -
* Autor:	Juliana Barros Mariano
* Data:		14/06/2005
********************************************************************/
Static Function AchaHabilRec( aTree, nLen, lRetorno )

Local nI := 0

DEFAULT nLen := 1
DEFAULT lRetorno := .F.

For nI := nLen To Len( aTree )

	If len(aTree[nI]:OWSLISTOFSKILLS:OWSSKILLSLIST) > 0 //HABILIDADES
		lRetorno := .T.
	EndIf
	AchaHabilRec( aTree[nI]:OWSLISTOFITEM:OWSITEMLIST, , @lRetorno )

Next nI

Return lRetorno

