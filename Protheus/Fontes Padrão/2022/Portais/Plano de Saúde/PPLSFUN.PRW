#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

// o ch directory conforme tdn não existe, foi necessário fazer aqui
#DEFINE F_NAME 1
#DEFINE F_SIZE 2
#DEFINE F_DATE 3
#DEFINE F_TIME 4
#DEFINE F_ATT  5

/*/{Protheus.doc} GeraJSPls
Gera os scripts para utilizacao da tela do Portal
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function GeraJSPls( aF3s, aRets, lOnBlur, lNewF3 )
	LOCAL nI 		 := 0
	LOCAL nY 		 := 0
	LOCAL nTam 		 := Len( aF3s )
	LOCAL nTamY 	 := Len( aRets )
	LOCAL cJs 		 := "" + CRLF
	LOCAL cPrecoTemp := ""
	LOCAL xValue	 :=	""
	PRIVATE nJ 		 := 0
	PRIVATE oTempObj := aRets
	DEFAULT lOnBlur := .F.
	DEFAULT lNewF3 := .F.

	cJs += "function envia( x ) {" + CRLF

	For nY := 1 To nTamY

		nJ := nY

		cJs += "if( x == " + AllTrim( Str( nY - 1) ) + " ) {" + CRLF

		For nI := 1 To nTam
			xValue	:=	&( "oTempObj[nJ]:" + aF3s[nI][1] )
			If ValType(xValue) == "N"
				xValue	:=	Str(xValue)
				if !lNewF3
					cJs += "parent.opener.document.forms[0]." + aF3s[nI][2] + ".value = "+xValue+ ";" + CRLF
				else
					cJs += "parent.frames['principal'].document.forms[0]." + aF3s[nI][2] + ".value = "+xValue+ ";" + CRLF
				endif
			Else
				If ValType(xValue) == "D"
					xValue	:=	Dtoc(xValue)
				ElseIf	ValType(xValue) == "L"
					xValue	:=	If(xValue,'.T.','.F.')
				Endif
				if !lNewF3
					cJs += "parent.opener.document.forms[0]." + aF3s[nI][2] + ".value = '"+xValue+ "';" + CRLF
				else
					cJs += "parent.frames['principal'].document.forms[0]." + aF3s[nI][2] + ".value = '"+xValue+ "';" + CRLF
				endif
			Endif
			If nI == nTam
				If lOnBlur
					if !lNewF3
						cJs += "parent.opener.document.forms[0]." + aF3s[1][2] + ".onblur();" + CRLF
					else
						cJs += "parent.frames['principal'].document.forms[0]." + aF3s[1][2] + ".onblur();" + CRLF
					endif
				EndIf
				if !lNewF3
					cJs += "parent.opener.document.forms[0]." + aF3s[1][2] + ".focus();" + CRLF
					cJs += "parent.opener.document.forms[0]." + aF3s[1][2] + ".select();" + CRLF
				else
					cJs += "parent.frames['principal'].document.forms[0]." + aF3s[1][2] + ".focus();" + CRLF
					cJs += "parent.frames['principal'].document.forms[0]." + aF3s[1][2] + ".select();" + CRLF
				endif

				If (aF3s[1][2] == "cCodProSExe" .and. aF3s[2][2] == "cDesProSExe" .and. nTam > 2 .and. (!empty(aF3s[3][2]) .and. aF3s[3][2] == "cTpProc"))
					cJs += "		parent.frames['principal'].document.forms[0].cCodProSExe.onchange();" + CRLF
				EndIf
			EndIf
		Next

		cJs += "}"  + CRLF
	Next

	if !lNewF3
		If	(aF3s[1][2] == "cDente")
			cJs += 'cDente = parent.opener.document.forms[0].cDente.value;' + CRLF
			cJs += 'cCodPad = parent.opener.document.forms[0].cCodPadSE.value;' + CRLF
			cJs += 'cCodPro = parent.opener.document.forms[0].cCodProSE.value;' + CRLF
			cJs += ' Ajax.open("W_PPLRETFAC.APW?cCodDente=" + cDente + "&cCodPad=" + cCodPad + "&cCodPro=" + cCodPro, {callback: VerificaFaceDente, error: ExibeErro});' +  CRLF
		EndIf
	Else
		If	(aF3s[1][2] == "cDente")
			cJs += "cDente = parent.frames['principal'].document.forms[0].cDente.value;" + CRLF
			cJs += "cCodPad = parent.frames['principal'].document.forms[0].cCodPadSE.value;" + CRLF
			cJs += "cCodPro = parent.frames['principal'].document.forms[0].cCodProSE.value;" + CRLF
			cJs += ' Ajax.open("W_PPLRETFAC.APW?cCodDente=" + cDente + "&cCodPad=" + cCodPad + "&cCodPro=" + cCodPro, {callback: VerificaFaceDente, error: ExibeErro});' +  CRLF
		EndIf
	EndIf

	if !lNewF3
		cJs += "parent.window.close();" + CRLF
	else
		cJs += "closeModalBS();" + CRLF

		//Só habilita esse gatilho se o campo hidden for
		if	(aF3s[1][2] == "cProSol" .and. aF3s[2][2] == "cProSolDesc") .or. ;
				(aF3s[1][2] == "cProExe" .and. aF3s[2][2] == "cProExeDesc")
			cJs += "gatilhoHiddenJS('"+aF3s[1][2]+"');" + CRLF
		endif
	endif
	cJs += "}" + CRLF

	If	(aF3s[1][2] == "cDente")
		cJs += "function VerificaFaceDente(v) {" + CRLF
		cJs += "	parent.frames['principal'].document.forms[0].cFlagDente.value = v;" + CRLF
		cJs += "	parent.window.close();" + CRLF
		cJs += "}" + CRLF
	EndIf

	cJs += ""

Return cJs

/*/{Protheus.doc} WCDecode
Trata string acentuada
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function WCDecode(cString)
	cString := StrTran(cString,"á","&aacute;")
	cString := StrTran(cString,"à","&agrave;")
	cString := StrTran(cString,"â","&acirc;")
	cString := StrTran(cString,"ã","&atilde;")
	cString := StrTran(cString,"ä","&auml;")
	cString := StrTran(cString,"Á","&Aacute;")
	cString := StrTran(cString,"À","&Agrave;")
	cString := StrTran(cString,"Ã","&Atilde;")
	cString := StrTran(cString,"Â","&Acirc;")
	cString := StrTran(cString,"Ä","&Auml;")

	cString := StrTran(cString,"é","&eacute;")
	cString := StrTran(cString,"è","&egrave;")
	cString := StrTran(cString,"ê","&ecirc;")
	cString := StrTran(cString,"ë","&euml;")
	cString := StrTran(cString,"É","&Eacute;")
	cString := StrTran(cString,"È","&Egrave;")
	cString := StrTran(cString,"Ê","&Ecirc;")
	cString := StrTran(cString,"Ë","&Euml;")

	cString := StrTran(cString,"í","&iacute;")
	cString := StrTran(cString,"ì","&igrave;")
	cString := StrTran(cString,"ï","&iuml;")
	cString := StrTran(cString,"Í","&Iacute;")
	cString := StrTran(cString,"Ì","&Igrave;")
	cString := StrTran(cString,"Î","&Icirc;")
	cString := StrTran(cString,"Ï","&Iuml;")

	cString := StrTran(cString,"ó","&oacute;")
	cString := StrTran(cString,"ò","&ograve;")
	cString := StrTran(cString,"õ","&otilde;")
	cString := StrTran(cString,"ô","&ocirc;")
	cString := StrTran(cString,"ö","&ouml;")
	cString := StrTran(cString,"Ó","&Oacute;")
	cString := StrTran(cString,"Ò","&Ograve;")
	cString := StrTran(cString,"Õ","&Otilde;")
	cString := StrTran(cString,"Ô","&Ocirc;")
	cString := StrTran(cString,"Ö","&Ouml;")

	cString := StrTran(cString,"ú","&uacute;")
	cString := StrTran(cString,"ù","&ugrave;")
	cString := StrTran(cString,"ü","&uuml;")
	cString := StrTran(cString,"û","&ucirc;")
	cString := StrTran(cString,"Û","&Ucirc;")
	cString := StrTran(cString,"Ú","&Uacute;")
	cString := StrTran(cString,"Ù","&Ugrave;")
	cString := StrTran(cString,"Ü","&Uuml;")

	cString := StrTran(cString,"ç","&ccedil;")
	cString := StrTran(cString,"Ç","&Ccedil;")
	cString := StrTran(cString,"µ","")
	cString := StrTran(cString,"¿","")
	cString := StrTran(cString,"´","'")
	cString := StrTran(cString,"¨","&uml")
	cString := StrTran(cString,"°","&deg")
	cString := StrTran(cString,"º","&deg")

	cString := StrTran(cString,"Chr(166)","")
	cString := StrTran(cString,"Chr(167)","")
	cString := StrTran(cString,"","")
	cString := StrTran(cString,"","")
	cString := StrTran(cString,"","")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fim da funcao														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(cString)

/*/{Protheus.doc} WCGatField
Gatilho de campo estrutura de retorno
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function WCGatField(aMat)
	LOCAL aRet 		:= {}
	LOCAL nI   		:= 0
	LOCAL cCampo 	:= ""
	LOCAL xConteudo := ""
	LOCAL cCpDes    := "B4C_DESPRO,cDesProSSol,cDesProSExe"

	If ValType(aMat) == "A"

		//Se teve algum mensagem de retorno
		AaDd(aRet, aMat[1] + "%" )

		//Retorna o resultado
		For nI:=1 To Len(aMat[2])

			cCampo := AllTrim( aMat[2,nI,1] )

			If ValType(aMat[2,nI,2]) == 'C'
				xConteudo := IIF(cCampo $ cCpDes,AllTrim( StrTran(aMat[2,nI,2],"#"," ") ),AllTrim( aMat[2,nI,2] ))
			ElseIf ValType(aMat[2,nI,2]) == 'N'
				xConteudo := cValToChar(aMat[2,nI,2])
			ElseIf ValType(aMat[2,nI,2]) == 'D'
				xConteudo := DToC(aMat[2,nI,2])
			EndIf

			AaDd(aRet, cCampo + "$" + xConteudo + "|" )
		Next
	EndIf

Return( aRet )

/*/{Protheus.doc} WCHeader
Rotina de recuperacao do header das estruturas
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function WCHeader(aMat)
	LOCAL aArea   := GetArea()
	LOCAL nX      := 0
	LOCAL aHeader := {}
	LOCAL aRetAux := {}
	LOCAL cCampos := ""

	//Monta aherder
	For nX := 1 To Len(aMat)

		//Inicia a estrutura
		AaDd(aHeader,WSClassNew("BrwHeader"))

		//Verifica se e um campo virtual criado na query
		aRetAux := StrToArray(aMat[nX,1],"|")

		//Se foi informado matriz pega direto dela. pois o campo nao existe no dicionario
		If Len(aRetAux)>1

			aMat[nX,1]					:= aRetAux[1]

			aHeader[nX]:HeaderTitle    	:= aRetAux[2]
			aHeader[nX]:HeaderField    	:= aMat[nX,2]

			aHeader[nX]:HeaderPicture  	:= aRetAux[3]
			aHeader[nX]:HeaderSize     	:= Val(aRetAux[4])
			aHeader[nX]:HeaderType     	:= aRetAux[5]
			aHeader[nX]:HeaderDec      	:= 0
		Else
			aHeader[nX]:HeaderTitle    	:= RetTitle(aMat[nX,1])
			aHeader[nX]:HeaderField    	:= aMat[nX,2]
			aHeader[nX]:HeaderPicture  	:= SX3->X3_PICTURE
			aHeader[nX]:HeaderSize     	:= SX3->X3_TAMANHO
			aHeader[nX]:HeaderDec      	:= SX3->X3_DECIMAL
			aHeader[nX]:HeaderType     	:= SX3->X3_TIPO
			aHeader[nX]:HeaderComboBox 	:= X3CBox()
			aHeader[nX]:HeaderOblig    	:= X3Obrigat(SX3->X3_CAMPO)
			aHeader[nX]:HeaderF3       	:= SX3->X3_F3
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Lista de campos reais
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		cCampos	+= aMat[nX,1] + Iif(Len(aMat)==nX,"",",")

	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rest na area															   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea(aArea)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fim da rotina														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return( { aHeader,cCampos } )

/*/{Protheus.doc} WCTextNeg
Retorna texto formatado negado
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function WCTextNeg(cTexto,lEstilo)
	LOCAL cHTML		:= ""
	DEFAULT lEstilo := .T.

	//Retorno com ou sem estilo
	If lEstilo
		cHTML += "&nbsp;&nbsp;&nbsp;&nbsp;<samp class='TextoNegPeq'>" + cTexto + "</samp><br>"
	Else
		cHTML += "&nbsp;&nbsp;&nbsp;&nbsp;" + cTexto + "<br>"
	EndIf

Return cHTML

/*/{Protheus.doc} WCFTxtHtm
Formata arquivo txt para formato htm
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function WCFTxtHtm(cTp)
	LOCAL cHTML := ""

	Do Case
		Case cTp == 'A'
			cHTML += "<html>"
			cHTML += "<head>"
			cHTML += "<style type='text/css'>"
			cHTML += " .relTxt {"
			cHTML += " 		background-color: #FFFFFF;"
			cHTML += "		font-family: 'Courier New', Courier, mono;"
			cHTML += "		font-size: 12px;"
			cHTML += "		color: #000000;"
			cHTML += "		text-decoration: none;"
			cHTML += "		font-style: normal;"
			cHTML += "		font-weight: bold;"
			cHTML += "}"
			cHTML += "</style>"
			cHTML += "</head>"
			cHTML += "<body>"
			cHTML += "<table>"
			cHTML += "<tr>"
			cHTML += "<td nowrap class='relTxt'>"
		Case cTp == 'F'
			cHTML += "</td>"
			cHTML += "</tr>"
			cHTML += "</table>"
			cHTML += "</body>"
			cHTML += "</html>"
	EndCase

Return cHTML

/*/{Protheus.doc} WCFImgHtm
Formata arquivo img para formato htm
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function WCFImgHtm(cFileName,cWidth,cZoom)
	LOCAL cHTML   := ""
	DEFAULT cZoom := 0

	cHTML := "<img width='" + cWidth + "px' style='zoom:" + cZoom + "' src='" + cFileName + "'/>"

Return cHTML

/*/{Protheus.doc} PLRETOECS
Retorna operadora,empresa, contrato, subcontratos ou familia
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function PLRETOECS(aMat,cTp,cChave,cEsp)
	LOCAL aRet 		:= {}
	LOCAL nI		:= 0
	LOCAL nY		:= 0
	LOCAL nX		:= 0
	LOCAL nZ		:= 0
	DEFAULT cChave 	:= ""
	DEFAULT cEsp	:= ""

	//³Verifica se tem registro
	If Len(aMat) > 0

		Do Case
			//³Operadora
			Case cTp == 'O'

				aRet := RETDM(aMat,cChave)

				//³Empresa
			Case cTp == 'E'

				//³Empresas da operadora
				For nI:=1 To Len(aMat)
					aRet := RETDM(aMat[nI]:OWSEMPRESA:OWSSEMPRESA,cChave,aRet)
				Next

				//³Contrato
			Case cTp == 'C'

				//³Empresas da operadora
				For nI:=1 To Len(aMat)

					//³Contratos da Empresa
					For nY:=1 To Len(aMat[nI]:OWSEMPRESA:OWSSEMPRESA)
						aRet := RETDM(aMat[nI]:OWSEMPRESA:OWSSEMPRESA[nY]:OWSCONTRATO:OWSSCONTRATO,cChave,aRet)
					Next

				Next

				//³SubContrato
			Case cTp == 'S'

				//³Empresas da operadora
				For nI:=1 To Len(aMat)

					//³Contratos da Empresa
					For nY:=1 To Len(aMat[nI]:OWSEMPRESA:OWSSEMPRESA)

						//³SubContrato do Contrato
						For nX:=1 To Len(aMat[nI]:OWSEMPRESA:OWSSEMPRESA[nY]:OWSCONTRATO:OWSSCONTRATO)
							aRet := RETDM(aMat[nI]:OWSEMPRESA:OWSSEMPRESA[nY]:OWSCONTRATO:OWSSCONTRATO[nX]:OWSSUBCONTRATO:OWSSSUBCONTRATO,cChave,aRet)
						Next
					Next
				Next

				//³Familia
			Case cTp == 'F'

				//³Empresas da operadora
				For nI:=1 To Len(aMat)

					//³Contratos da Empresa
					For nY:=1 To Len(aMat[nI]:OWSEMPRESA:OWSSEMPRESA)

						//³SubContrato do Contrato
						For nX:=1 To Len(aMat[nI]:OWSEMPRESA:OWSSEMPRESA[nY]:OWSCONTRATO:OWSSCONTRATO)

							//³Familia
							For nZ:=1 To Len(aMat[nI]:OWSEMPRESA:OWSSEMPRESA[nY]:OWSCONTRATO:OWSSCONTRATO[nX]:OWSSUBCONTRATO:OWSSSUBCONTRATO)
								aRet := RETDM(aMat[nI]:OWSEMPRESA:OWSSEMPRESA[nY]:OWSCONTRATO:OWSSCONTRATO[nX]:OWSSUBCONTRATO:OWSSSUBCONTRATO[nZ]:OWSFAMILIA:OWSSFAMILIA,cChave,aRet,cEsp)
							Next
						Next
					Next
				Next

		EndCase

	EndIf

Return(aRet)

/*/{Protheus.doc} RETDM
Retorna informacoes de uma matriz para outra matriz
@author PLSTEAM
@since 10.2007
@version P12
/*/
Static Function RETDM(aMat,cChave,aRet,cEsp)
	LOCAL nI	:= 0
	DEFAULT aRet:= {}

	//Monta matriz de retorno
	For nI := 1 To Len(aMat)

		If ! empty(cEsp)

			If Eval( &('{|| aScan( aRet, { |x| x:' + cEsp + ' == aMat[nI]:'  + cEsp + ' } ) }' ) ) == 0
				AaDd(aRet,aMat[nI])
			EndIf

		ElseIf ! empty(cChave)

			If cChave $ aMat[nI]:cCode

				If aScan( aRet, { |x| x:cCode == aMat[nI]:cCode } ) == 0
					AaDd(aRet,aMat[nI])
				EndIf

			EndIf

		Else

			If aScan( aRet, { |x| x:cCode == aMat[nI]:cCode } ) == 0
				AaDd(aRet,aMat[nI])
			EndIf

		EndIf

	Next

Return aRet

/*/{Protheus.doc} PLGETDADR
Retorna resultado de uma tabela
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function PLGETDADR(cAlias,cCmpRet,nIdx,cChave,cCmpChave,lFil)
	LOCAL aRet 			:= {}
	DEFAULT nIdx		:= 1
	DEFAULT cChave      := ""
	DEFAULT cCmpChave	:= ""
	DEFAULT lFil		:= .F.

	//³Posiciona na SX5
	If lFil .And. !Empty(cChave)

		(cAlias)->( DbGoTop() )
		While !(cAlias)->( Eof() ) .And. cChave == (cAlias)->&(cCmpChave)

			AaDd(aRet,&( "{" + cCmpRet + "}" ) )

			(cAlias)->( DbSkip() )
		EndDo

	ElseIf !Empty(cChave)
		(cAlias)->( DbSetOrder(nIdx) )
		(cAlias)->( MsSeek( xFilial(cAlias) + cChave ) )

		While !(cAlias)->( Eof() ) .And. cChave == (cAlias)->&(cCmpChave)

			AaDd(aRet,&( "{" + cCmpRet + "}" ) )

			(cAlias)->( DbSkip() )
		EndDo
	Else
		(cAlias)->( DbGoTop() )
		While !(cAlias)->( Eof() )

			AaDd(aRet,&( "{" + cCmpRet + "}" ) )

			(cAlias)->( DbSkip() )
		EndDo
	EndIf

Return aRet

/*/{Protheus.doc} getUsrWeb
Retorna o codigo do login do usuario do portal tabela bsw
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function getUsrWeb()
Return Iif( ValType(HttpSession->USR_INFO) != 'U',HttpSession->USR_INFO[1]:OWSUSERLOGPLS:CUSERLOGINCODE,"")

/*/{Protheus.doc} getNameUsr
Retorna o nome do login do usuario do portal tabela bsw
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function getNameUsr()
Return Iif( ValType(HttpSession->USR_INFO) != 'U',HttpSession->USR_INFO[1]:CUSERLOGIN,"")

/*/{Protheus.doc} getTpPortal
Retorna o tipo de portal que esta sendo usado
1 - Prestador, 2 - Empresa e 3 - Familia
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function getTpPortal(nTp)
	LOCAL xRet := NIL

	DEFAULT nTp = 0

	//³Se e para validar o tipo do portal ou retorno o tipo de portal
	If nTp == 0
		xRet := Iif( ValType(HttpSession->USR_INFO) != 'U',HttpSession->USR_INFO[1]:OWSUSERLOGPLS:nTpPortal,0)
	Else
		xRet := Iif( ValType(HttpSession->USR_INFO) != 'U',(nTp == HttpSession->USR_INFO[1]:OWSUSERLOGPLS:nTpPortal),.F.)
	EndIf

Return(xRet)

/*/{Protheus.doc} getWebDir
Retorna o diretorio corrente da web
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function getWebDir(cChave,lServer)
	LOCAL cCaminho 	:= ""
	LOCAL nPos 		:= 0
	LOCAL cCamOri 	:= ""
	LOCAL aArea		:= GetArea()

	DEFAULT cChave	:= ""
	DEFAULT lServer	:= .F.

	//³Se foi inforamdo a chave
	If ! Empty(cChave)

		If lServer
			cCaminho := lower( GetPvProfString( GetEnvServer(), cChave, "ERROR", GetADV97() ) ) + "\"
		Else
			cCaminho := lower( GetPvProfString( GetEnvHost(), cChave, "ERROR", GetADV97() ) ) + "\"
		EndIf
	Else
		cCaminho := lower( GetPvProfString( GetEnvHost(), "PATH", "ERROR", GetADV97() )) + "\"
		cCamOri  := GetPvProfString( GetEnvHost(), "PATH", "ERROR", GetADV97() ) + "\"
		nPos	 := at('web', lower(cCaminho) )

		//³Se achou a posicao da web
		If nPos > 0
			cCaminho := SubStr(cCamOri,nPos-1)
		Else
			cCaminho := PGetWDirPad()
		EndIf
	EndIf

	RestArea( aArea )

Return(PLSMUDSIS(cCaminho))

/*/{Protheus.doc} PGetWDirPad
Retorna o diretorio corrente da web
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function PGetWDirPad()
	Local cParWeb := ""
	Local cDirRet := ""
	LOCAL aArqDir := {}
	LOCAL nI      := 1
	LOCAL lAchou  := .F.

	If !Empty(cParWeb)

		cDirRet := cParWeb

		cCaminho := lower( GetPvProfString( cDirRet, "PATH", "ERROR", GetADV97() )) + "\"
		cCamOri  := GetPvProfString( cDirRet, "PATH", "ERROR", GetADV97() ) + "\"
		nPos	 := at('web', lower(cCaminho) )

		If nPos > 0
			cDirRet := SubStr(cCamOri,nPos-1)
		Else
			cDirRet := "\web\pp\"
		EndIf

	Else

		aArqDir := Directory("\web\*.*", "D")

		While nI <= Len(aArqDir) .AND. !lAchou
			If (aArqDir[nI][F_ATT] == "D") .AND. (File("\web\"+aArqDir[nI][F_NAME]+"\"+getSkinPls()))
				lAchou := .T.
			Else
				nI++
			EndIf
		EndDo

		If lAchou
			cDirRet := lower("\web\"+aArqDir[nI][F_NAME]+"\")
		Else
			cDirRet := "\web\pp\"
		EndIf

	EndIf

Return cDirRet

/*/{Protheus.doc} getWebDir
Retorna o diretorio corrente da web
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function getSkinPls()
Return "imagens-pls"

/*/{Protheus.doc} PLRETCARS
Retira mascara do conteudo
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function PLRETCARS(cConteudo)

	cConteudo := StrTran(cConteudo,'.','')
	cConteudo := StrTran(cConteudo,',','')
	cConteudo := StrTran(cConteudo,'/','')
	cConteudo := StrTran(cConteudo,'\','')
	cConteudo := StrTran(cConteudo,'-','')
	cConteudo := StrTran(cConteudo,'=','')
	cConteudo := StrTran(cConteudo,'`','')
	cConteudo := StrTran(cConteudo,"'",'')
	cConteudo := StrTran(cConteudo,'"','')

Return cConteudo

/*/{Protheus.doc} WCGetPar
Chama WS PLSGETMV.
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function WCGetPar(cPar,cPad)
	local oParam  := WSCFGDICTIONARY():NEW()
	local xResult := nil
	IIf (!Empty(PlsGetAuth()),oParam:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL(@oParam,"CFGDICTIONARY.APW")

	oParam:getParam( "MSALPHA", cPar )

	xResult := iIf( oParam:cGETPARAMRESULT == ".F.", cPad, oParam:cGETPARAMRESULT)

return xResult

/*/{Protheus.doc} getPastPp
Retorna o diretório corrente da web, tanto para o portal
quanto para o remote, a função GetEnvHost() em algumas situaçoes
não funcionou, dessa forma foi necessário criar a rotina e o
parametro MV_SESINI
@author PLSTEAM
@since 10.2007
@version P12
/*/
Function getPastPp(lPortal)
	LOCAL cCaminho 	:= ""
	LOCAL nPos 		:= 0
	LOCAL cCamOri 	:= ""
	LOCAL aArea		:= GetArea()
	LOCAL cSesIni	:= ""
	DEFAULT lPortal	:= .F.

	//Por algum motivo a função GetEnvHost deixa de mostrar o endereço do servidor em determinadas situações, por este
	//motivo, criei o parâmetro MV_SESINI criado no compatibilizador UPDPLSEV onde o usuário digita o endereço
	//do servidor (ex: localhost:8080) dessa forma a rotina noticias no portal sempre vai conseguir acessar os arquivos
	//e criar novos arquivos
	If lPortal
		cSesIni := IIF(!EMPTY(WCGetPar("MV_SESINI","")),WCGetPar("MV_SESINI",""),GetEnvHost())
	Else
		cSesIni := IIF(!EMPTY(GetNewPar("MV_SESINI","")),GetNewPar("MV_SESINI",""),GetEnvHost())
	EndIf

	//³Se foi inforamdo a chave
	cCaminho := lower( GetPvProfString( cSesIni, "PATH", "ERROR", GetADV97() )) + "\"
	cCamOri  := GetPvProfString( cSesIni, "PATH", "ERROR", GetADV97() ) + "\"
	nPos	 := at('web', lower(cCaminho) )

	//³Se achou a posicao da web
	If nPos > 0
		cCaminho := SubStr(cCamOri,nPos-1)
	Else
		cCaminho := "\web\pp\"
	EndIf

	RestArea( aArea )

Return(PLSMUDSIS(cCaminho))

/*/{Protheus.doc} PLLOGMon
retorna log do montior ( ATENCAO NAO DEVE FICAR LIGADO POR MUITO TEMPO )
@type function
@author PLSTEAM
@since 20.03.18
@version 1.0
/*/
function getLOGMon()
	local nI		 := 0
	local nTimeDel	 := 30
	local cThID		 := ''
	local cThReadId	 := ''
	local cLog		 := ''
	local cData 	 := ''
	local cTempo 	 := ''
	local cNInst 	 := ''
	local cNInstSeg  := ''
	local cDuracao	 := ''
	local cMemory	 := ''
	local aList		 := {}
	local cSecao 	 := "TCP"
	local cChave 	 := "Port"
	local cServerIni := ''
	local cPorta	 := ''
	local nPadrao 	 := 0

	if HttpSession->lLogProd

		cServerIni 	:= getAdv97()
		cPorta	 	:= NToC(getPvProfileInt(cSecao, cChave, nPadrao, cServerIni), 10)
		aList 		:= getUserInfoArray()

		if valType(HttpSession->aLog) == 'U' .or. aScan(HttpSession->aLog,{|x| val(subStr(elapTime( x[1], time() ),4,2)) >= nTimeDel }) > 0
			HttpSession->aLog := nil
			HttpSession->aLog := {}
		endIf

		for nI := 1 to len(aList)

			if 'SOAP REQUEST' $ allTrim(aList[nI,11])

				cThID		:= allTrim(cValToChar(aList[nI,3]))
				cThReadId 	:= 'Thread: ' + allTrim(cValToChar(aList[nI,3])) + ';'
				cData 		:= 'Data: ' + allTrim(strTran(cValToChar(aList[nI,7]),chr(10),'') ) + ';'
				cTempo 		:= 'Th Ativa: ' + allTrim(cValToChar(aList[nI,8])) + ';'
				cNInst 		:= 'N. Inst.: ' + allTrim(cValToChar(aList[nI,9])) + ';'
				cNInstSeg 	:= 'Ins. Seg.: ' + allTrim(cValToChar(aList[nI,10])) + ';'
				cLog		:= 'Obs: ' + allTrim( strTran(cValToChar(aList[nI,11]),chr(10),'') ) + ';'
				cDuracao	:= 'T. Proc: ' + strTran(allTrim(substr(aList[nI,11],at('( ', aList[nI,11])+1, 10) ),'.',',')  + ';'
				cMemory		:= 'Memoria: ' + allTrim(cValToChar(aList[nI,12]))

				if aScan(HttpSession->aLog,{|x| (cThID + cLog) $ x[2] }) == 0

					plsLogFil( allTrim(cThReadId + cData + cTempo + cNInst + cNInstSeg + cLog + cDuracao + cMemory), 'portal_' + cPorta + '.csv' )

					aadd(HttpSession->aLog, { time(), cThID + cLog })

				endIf

			endIf

		next

	endIf

return

/*/{Protheus.doc} setLoadPar
carrega parametros do modulo e combo nas SESSIONS
TODO - rever pontos de utilizacao de PRIVATE trocar por variaveis de SESSION.

@type function
@author PLSTEAM
@since 20.03.18
@version 1.0
/*/
function setLoadPar(oParam)
	local oObjLib := nil

	//ExistBlock
	if valType(HttpSession->lPLSCMPFP) == 'U'
		HttpSession->lPLSCMPFP := existBlock('PLSCMPFP')
	endIf

	if valType(HttpSession->lPLSCPGUI) == 'U'
		HttpSession->lPLSCPGUI := existBlock('PLSCPGUI')
	endIf

	if valType(HttpSession->lPLSPROF) == 'U'
		HttpSession->lPLSPROF := existBlock('PLSPROF')
	endIf

	if valType(HttpSession->lPLSCARD) == 'U'
		HttpSession->lPLSCARD := existBlock('PLSCARD')
	endIf

	if valType(HttpSession->lPPLBiomet) == 'U'
		HttpSession->lPPLBiomet := existBlock('PPLBiomet')
	endIf

	if valType(HttpSession->lPLSVLDC) == 'U'
		HttpSession->lPLSVLDC := existBlock('PLSVLDC')
	endIf

	if valType(HttpSession->lPPLREGBTN) == 'U'
		HttpSession->lPPLREGBTN := existBlock('PPLREGBTN')
	endIf

	if valType(HttpSession->lPPLSVPTU) == 'U'
		HttpSession->lPPLSVPTU := existBlock('PPLSVPTU')
	endIf

	if valType(HttpSession->lPPLMFUN1) == 'U'
		HttpSession->lPPLMFUN1 := existBlock('PPLMFUN1')
	endIf

	if valType(HttpSession->lPPLEXIELE) == 'U'
		HttpSession->lPPLEXIELE := existBlock('PPLEXIELE')
	endIf

	if valType(HttpSession->lPPLEXSTAT) == 'U'
		HttpSession->lPPLEXSTAT := existBlock('PPLEXSTAT')
	endIf

	oObjLib := WSPLSXFUN():New()
	IIf (!Empty(PlsGetAuth()),oObjLib:_HEADOUT :=  { PlsGetAuth() },)
	WsChgURL( @oObjLib, "PLSXFUN.APW" )

	oObjLib:cUSERCODE := "MSALPHA"

	//Alimenta parametros
	if oObjLib:getParam()

		httpSession->cLinkProfi := oObjLib:oWSGETPARAMRESULT:cLinkProfi
		httpSession->cLinkProdu := oObjLib:oWSGETPARAMRESULT:cLinkProdu
		httpSession->cLinkPriAc := oObjLib:oWSGETPARAMRESULT:cLinkPriAc
		httpSession->lTimeAte 	:= oObjLib:oWSGETPARAMRESULT:lTimeAte
		httpSession->lLogProd 	:= oObjLib:oWSGETPARAMRESULT:lLogProd
		httpSession->lUnimeds 	:= oObjLib:oWSGETPARAMRESULT:lUnimeds
		httpSession->cSmtpEnv 	:= oObjLib:oWSGETPARAMRESULT:cSmtpEnv
		httpSession->cUsuEmai 	:= oObjLib:oWSGETPARAMRESULT:cUsuEmai
		httpSession->cUsuPass 	:= oObjLib:oWSGETPARAMRESULT:cUsuPass
		httpSession->cAprNImp 	:= oObjLib:oWSGETPARAMRESULT:cAprNImp
		httpSession->cCodCons 	:= oObjLib:oWSGETPARAMRESULT:cCodCons
		httpSession->lDiagno 	:= oObjLib:oWSGETPARAMRESULT:lDiagno
		httpSession->lFiltPRF 	:= oObjLib:oWSGETPARAMRESULT:lFiltPRF
		httpSession->lPreAten 	:= oObjLib:oWSGETPARAMRESULT:lPreAten
		httpSession->cUsuProc 	:= oObjLib:oWSGETPARAMRESULT:cUsuProc
		httpSession->cChaGe 	:= oObjLib:oWSGETPARAMRESULT:cChaGe
		httpSession->lMatrAnt 	:= oObjLib:oWSGETPARAMRESULT:lMatrAnt
		httpSession->cValParam 	:= oObjLib:oWSGETPARAMRESULT:cValParam
		httpSession->cMVQTDIARQ := oObjLib:oWSGETPARAMRESULT:cMVQTDIARQ
		httpSession->MV_LOGSCHE := oObjLib:oWSGETPARAMRESULT:cMVLOGSCHE
		httpSession->lMosGui 	:= oObjLib:oWSGETPARAMRESULT:lMosGui
		httpSession->cCodOff 	:= oObjLib:oWSGETPARAMRESULT:cCodOff
		httpSession->lPOGTISS 	:= oObjLib:oWSGETPARAMRESULT:lPOGTISS
		httpSession->lBaixar 	:= oObjLib:oWSGETPARAMRESULT:cBaixar
		httpSession->lVldOpc 	:= oObjLib:oWSGETPARAMRESULT:lVldOpc

		httpSession->lRecOb 	:= oObjLib:oWSGETPARAMRESULT:cRecOb
		httpSession->lMultComp 	:= oObjLib:oWSGETPARAMRESULT:cMultComp
		httpSession->lTourReemb := oObjLib:oWSGETPARAMRESULT:cTourReemb

		httpSession->cTitPar 	:= oObjLib:oWSGETPARAMRESULT:cTitPar
		httpSession->MV_LRN360 	:= oObjLib:oWSGETPARAMRESULT:cMVLRN360
		httpSession->lPL395WS 	:= oObjLib:oWSGETPARAMRESULT:lPL395WS
		httpSession->cPLSDRDA 	:= oObjLib:oWSGETPARAMRESULT:cPLSDRDA
		HttpSession->cPLCMPFP 	:= oObjLib:oWSGETPARAMRESULT:cPLCMPFP

	endIf

	//operadora
	oObjLib:plsIntPad()

	HttpSession->cIntPad := oObjLib:cPLSINTPADRESULT

	//combos
	HttpSession->lCombo := .t.

	//Alimenta as variaves com o x3-combobox a variavel de HttpSession->cCodCons,HttpSession->cAprNImp esta sendo alimentada na chamada insite.
	if oObjLib:getCombo()

		HttpSession->cCodPad   	:= oObjLib:oWSGETCOMBORESULT:cCodPad
		HttpSession->aTpDoe 	:= oObjLib:oWSGETCOMBORESULT:oWSCBTPDOE:oWSGenericStruct
		HttpSession->aTmpDoe  	:= oObjLib:oWSGETCOMBORESULT:oWSCBTMPDOE:oWSGenericStruct
		HttpSession->aIndAcid	:= oObjLib:oWSGETCOMBORESULT:oWSCBIndAcid:oWSGenericStruct
		HttpSession->aTpCon		:= oObjLib:oWSGETCOMBORESULT:oWSCBTpCon:oWSGenericStruct
		HttpSession->aTpSai 	:= oObjLib:oWSGETCOMBORESULT:oWSCBTpSai:oWSGenericStruct
		HttpSession->aCarSolict	:= oObjLib:oWSGETCOMBORESULT:oWSCBCarSolict:oWSGenericStruct
		HttpSession->aTpAtend	:= oObjLib:oWSGETCOMBORESULT:oWSCBTpAtend:oWSGenericStruct
		HttpSession->aViaAce	:= oObjLib:oWSGETCOMBORESULT:oWSCBViaAce:oWSGenericStruct
		HttpSession->aTecUti	:= oObjLib:oWSGETCOMBORESULT:oWSCBTecUti:oWSGenericStruct
		HttpSession->aGraPart  	:= oObjLib:oWSGETCOMBORESULT:oWSCBGraPart:oWSGenericStruct
		HttpSession->aTpPreAte 	:= oObjLib:oWSGETCOMBORESULT:oWSCbTpPreAte:oWSGenericStruct
		HttpSession->aTpAtOD   	:= oObjLib:oWSGETCOMBORESULT:oWSCbTpAtOD:oWSGenericStruct
		HttpSession->aTpInter	:= oObjLib:oWSGETCOMBORESULT:oWSCbTpInter:oWSGenericStruct
		HttpSession->aRegInter	:= oObjLib:oWSGETCOMBORESULT:oWSCbRegInter:oWSGenericStruct
		HttpSession->aTipGui	:= oObjLib:oWSGETCOMBORESULT:oWSCbTipGui:oWSGenericStruct
		HttpSession->aTipFat	:= oObjLib:oWSGETCOMBORESULT:oWSCbTipFat:oWSGenericStruct

		oObjLib:nTp := 3

		if oObjLib:getCombo()
			HttpSession->aMotCar := oObjLib:oWSGETCOMBORESULT:oWSCbMotCar:oWSGenericStruct
		endIf

	else

		HttpSession->lCombo := .f.

	endIf


return
