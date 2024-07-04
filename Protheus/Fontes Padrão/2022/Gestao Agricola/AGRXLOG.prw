#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "AGRXLOG.CH"

#DEFINE CRLF CHR(13)+CHR(10) // FINAL DE LINHA

#DEFINE AGRLOG_DISABLED "1"
#DEFINE AGRLOG_INFO "2"
#DEFINE AGRLOG_DEBUG "3"
#DEFINE AGRLOG_CONSOLE "4"

#DEFINE AGRVP_TELA "1"
#DEFINE AGRVP_ARQUIVO "2"
#DEFINE AGRVP_AMBOS "3"


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRLog
Classe de controle de Log
Generico

@authorTamyris Ganzenmueller
@since 23/08/2018
@version 1.0
/*///------------------------------------------------------------------------------------------------
CLASS AGRLog
	DATA cFilename
	DATA cFullFile
	DATA cTitulo
	DATA cBody
	DATA cLogOption
	DATA lShowConsole

	// Declaração dos Métodos da Classe
	METHOD New(cFilename, cTitulo, cLogOption) CONSTRUCTOR
	METHOD EnableConsole()
	METHOD Add(cTexto, nIdent)
	METHOD AddDebug(cTexto, nIdent)
	METHOD ShowParameters(cPergunte)
	METHOD NewLine(nCont)
	METHOD Save()
	METHOD CheckLimit()
	METHOD EndLog()
	METHOD ChangeFilename(cNewFile)
ENDCLASS


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRLog:New
Constructor do log
Generico

Parâmetros:
	cFilename: Nome do Arquivo (Sem espaço, diretório ou extensão)
	cTitulo  : Título
	cLogOption: Nível de log: 1=Desabilitado, 2=Info, 3=Debug
	           Server para generalizar o controle da geração dentro da classe ao invés do programa chamador

@authorTamyris Ganzenmueller
@since 23/08/2018
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD New(cFilename, cTitulo, cLogOption, lChangeFN, lPrintCab) Class AGRLog
	Default cLogOption := AGRLOG_DISABLED
	Default lChangeFN  := .T.
	Default lPrintCab  := .T.

	Self:cTitulo 	:= cTitulo
	Self:cFilename 	:= cFilename
	Self:cFullFile 	:= cFilename
	Self:cLogOption	:= cLogOption
	Self:cBody		:= ""
	Self:lShowConsole := .F.

	If empty(cLogOption)
		Self:cLogOption := "1"
	Endif 
	
	If Self:cLogOption == AGRLOG_CONSOLE
		conout(Self:cTitulo + " : Início do Log " + Replicate("-", 20))
	EndIf

	If Self:cLogOption $ AGRLOG_INFO + AGRLOG_DEBUG

		If lChangeFN
			Self:ChangeFilename(cFilename)
		EndIf

		If lPrintCab
			Self:cBody := Self:cBody + Replicate("-", 120) + CRLF
			Self:cBody := Self:cBody + "SIGAAGR - " + Self:cTitulo + CRLF
			Self:cBody := Self:cBody + "Data da Geração: " + Dtoc(Date()) + " - " + Time() + CRLF
			Self:cBody := Self:cBody + "Usuário: " + cUserName + CRLF
			Self:cBody := Self:cBody + Replicate("-", 120) + CRLF
			Self:NewLine(2)
		EndIf

	EndIf

Return Self



//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRLog:EnableConsole
Habilita saída via console.log
Generico

@authorTamyris Ganzenmueller
@since 02/01/14
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD EnableConsole() Class AGRLog
	Self:lShowConsole := .T.
Return Nil




//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRLog:EndLog
Constructor do log
Generico

@authorTamyris Ganzenmueller
@since 23/08/2018
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD EndLog() Class AGRLog
	If Self:cLogOption == AGRLOG_DISABLED
		Return
	EndIf

	If Self:cLogOption == AGRLOG_CONSOLE
		conout(Self:cTitulo + " : Fim do processamento " + Replicate("-", 20))
		Return
	EndIf

	Self:NewLine(2)
	Self:cBody := Self:cBody + Replicate("-", 120) + CRLF
	Self:cBody := Self:cBody + "Término da Geração: " + Dtoc(Date()) + " - " + Time() + CRLF
	Self:cBody := Self:cBody + Replicate("-", 120) + CRLF
	Self:Save()
Return Nil




//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRLog:Add
Constructor do log
Generico

@authorTamyris Ganzenmueller
@since 23/08/2018
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD Add(cTexto, nIdent) Class AGRLog
	Default nIdent := 0
	Default cTexto := ""

	If Self:cLogOption == AGRLOG_DISABLED
		Return
	EndIf

	If Self:cLogOption == AGRLOG_CONSOLE .OR. Self:lShowConsole
		conout("[" + PADR(Time(), 8) + "]" + Self:cTitulo + " : " + cTexto)
		
		If Self:cLogOption == AGRLOG_CONSOLE
			Return Nil
		EndIf
	EndIf

	If Empty(cTexto)
		Self:NewLine()
		Return Nil
	EndIf
	
	If Self:cLogOption == AGRLOG_DEBUG
		Self:cBody := Self:cBody + "[" + PADR(Time(), 8) + "]" + Space(2)
	EndIf

	If nIdent > 0
		Self:cBody := Self:cBody + Replicate(" ", nIdent * 2)
	EndIf
	
	Self:CheckLimit()
	
	Self:cBody := Self:cBody + cTexto + CRLF
	
Return Nil


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRLog:AddDebug
Adiciona um texto de log para tipo Debug
Generico

@authorTamyris Ganzenmueller
@since 27/06/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD AddDebug(cTexto, nIdent) Class AGRLog
	Default nIdent := 0
	
	If Self:cLogOption != AGRLOG_DEBUG
		Return
	EndIf
	
	Self:cBody := Self:cBody + "[" + PADR(Time(), 8) + "]" + Space(2) + Replicate(" ", nIdent * 2) + cTexto + CRLF
	
	If Self:lShowConsole
		conout("[" + PADR(Time(), 8) + "] AGRLOG : " + cTexto)
	EndIf

	Self:CheckLimit()
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRLog:ShowParameters
Adiciona os dados dos campos do Pergunte(SX1) no log

@authorTamyris Ganzenmueller
@since 23/08/2018
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD ShowParameters(cPergunte) Class AGRLog
	Local nTextSize := 0
	Local nI	:= 0
	Local nOpc
	Local cValue
	Local aItens := {}
	Local aValue := {}
	Local oFWSX1 := NIL
	Local aPergunte := {}

	Self:Add("Parâmetros ------------------------")
	
	cPergunte := PadR(AllTrim(cPergunte), 10)

	oFWSX1 := FWSX1Util():New()
	oFWSX1:AddGroup(cPergunte)
	oFWSX1:SearchGroup()

	aPergunte := oFWSX1:GetGroup(cPergunte)

	If Len(aPergunte) > 0 .and. aPergunte[1] == cPergunte
		For nI := 1 To Len(aPergunte[2])
		
			If Len(AllTrim(aPergunte[2][nI]:CX1_PERGUNT)) > nTextSize //X1_PERGUNT
				nTextSize := Len(AllTrim(aPergunte[2][nI]:CX1_PERGUNT))
			EndIf

			aADD(aItens, AllTrim(aPergunte[2][nI]:CX1_PERGUNT))
			cValue := &("MV_PAR" + If(nI <= 9, "0", "") + AllTrim(cValToChar(nI)))
			
			If aPergunte[2][nI]:CX1_GSC == "C"
				nOpc := AllTrim(cValToChar(cValue))
				
				If nOpc == "1"
					aADD(aValue, aPergunte[2][nI]:CX1_DEF01)
				ElseIf nOpc == "2"
					aADD(aValue, aPergunte[2][nI]:CX1_DEF02)
				ElseIf nOpc == "3"
					aADD(aValue, aPergunte[2][nI]:CX1_DEF03)
				ElseIf nOpc == "4"
					aADD(aValue, aPergunte[2][nI]:CX1_DEF04)
				ElseIf nOpc == "5"
					aADD(aValue, aPergunte[2][nI]:CX1_DEF05)
				Else
					aADD(aValue, aPergunte[2][nI]:CX1_DEF01)
				EndIf
			Else
				aADD(aValue, AllTrim(cValue))
			EndIf

		Next nI
	EndIf

	For nI := 1 To Len(aItens)
		Self:Add(aItens[nI] + Replicate(".", nTextSize - Len(aItens[nI])) + ": " + aValue[nI])
		// cValue := &("MV_PAR" + If(nI <= 9, "0", "") + AllTrim(cValToChar(nI)))
		// Self:Add(aItens[nI] + Replicate(".", nTextSize - Len(aItens[nI])) + ": " + cValToChar(cValue))
	Next

	Self:NewLine()

Return Nil


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRLog:NewLine
Adiciona uma linha em branco
Generico

@authorTamyris Ganzenmueller
@since 23/08/2018
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD NewLine(nCont) Class AGRLog
	Default nCont := 1

	If Self:cLogOption == AGRLOG_DISABLED
		Return
	EndIf

	If Self:cLogOption == AGRLOG_CONSOLE
		conout(Self:cTitulo)
		Return
	EndIf

	If Self:cLogOption == AGRLOG_DEBUG
		Self:cBody := Self:cBody + Replicate("[" + PADR(Time(), 8) + "]" + CRLF, nCont)
	Else
		Self:cBody := Self:cBody + Replicate(CRLF, nCont)
	EndIf
	

	Self:CheckLimit()
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRLog:CheckLimit
Checa se a string chegou no tamanho limite, salva o log se for necessário
Generico

@authorTamyris Ganzenmueller
@since 23/08/2018
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD CheckLimit()  Class AGRLog
	If Self:cLogOption == AGRLOG_DISABLED
		Return
	EndIf

	// 400 KB
	If Len(Self:cBody) > 409600
		Self:Save()
	EndIf
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRLog:ChangeFilename
Altera o nome do arquivo
Generico

@authorTamyris Ganzenmueller
@since 23/08/2018
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD ChangeFilename(cNewFile)  Class AGRLog
	Local cMV_DRTLOG := GetMv("MV_DRTLOG")
	Local cSep := "/"
	
	Self:cFilename := cNewFile

	If Self:cLogOption != AGRLOG_INFO .AND. Self:cLogOption != AGRLOG_DEBUG
		Return
	EndIf

	If Empty(cMV_DRTLOG)
		Self:cFullFile := Self:cFilename + "_" + AGRNOW() + ".log"
	Else
		// Se for diretório fixo (C:\temp\ por exemplo) e a barra for normal, corrige o separador de diretórios
		If SubStr(cMV_DRTLOG, 3, 1) == "\"
			cSep := "\"
		EndIf
		
		// Se o final de MV_DRTLOG possuir barra, limpa o separador
		If SubStr(cMV_DRTLOG, len(cMV_DRTLOG), 1) == "/" .OR. SubStr(cMV_DRTLOG, len(cMV_DRTLOG), 1) == "\"
			cSep := ""
		EndIf
		
		Self:cFullFile := cMV_DRTLOG + cSep + Self:cFilename + "_" + AGRNOW() + ".log"
	EndIf
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRLog:Save
Salva e limpa a variável do corpo do log
Generico

@authorTamyris Ganzenmueller
@since 23/08/2018
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD Save()  Class AGRLog
	Local nHandle 	:= 0
	Local cLock		:= ""

	If Self:cLogOption != AGRLOG_INFO .AND. Self:cLogOption != AGRLOG_DEBUG
		Return
	EndIf
	
	cLock := "AGRXLOG" + Self:cFullFile
		
	If LockByName(cLock, .F., .F.)

		If !File(Self:cFullFile)  // Arquivo não existe
			// Cria o arquivo de log
			nHandle := FCreate(Self:cFullFile, FC_NORMAL)
			FSeek(nHandle, 0)	// Posiciona no inicio do arquivo de log
		Else	// Arquivo existe
			nHandle := FOpen(Self:cFullFile, FO_READWRITE)
			FSeek(nHandle, 0, FS_END)	// Posiciona no fim do arquivo de log
		EndIf
	
		FWrite(nHandle, Self:cBody, Len(Self:cBody)) // Grava o conteudo da variavel no arquivo de log
	
		FClose(nHandle) // Fecha o arquivo de log
	
		Self:cBody := ""
		
		UnLockByName(cLock, .F., .F.)
		ClearGlbValue('AGRXLOG*', 10)				
	EndIf

Return Nil


/* =============================================================================================================== */


/*/{Protheus.doc} AGRViewProc
Classe para visualizar o resultado do processamento de uma rotina
Generico

@author tamyris.g
@since 03/07/2018
@version 1.0
/*///------------------------------------------------------------------------------------------------
CLASS AGRViewProc
	DATA cBody
	DATA cBodyDetail
	DATA nLinhas
	DATA lEnabledLog
	DATA AGRLog
	DATA cIcon
	DATA lLimite
	DATA lLimiteDetail

	// Declaração dos Métodos da Classe
	METHOD New() CONSTRUCTOR
	METHOD EnableLog(cFileName, cTitulo)
	METHOD Add(cTexto, nIdent)
	METHOD AddDetail(cTexto, nIdent)
	METHOD AddErro(cTexto, nIdent)
	METHOD AddOnlyLog(cTexto, nIdent)
	METHOD Show(cTitulo, cSubTitulo, cTituloDetail, cMsgOnDetail)
	METHOD EmptyMsg()
	METHOD SetWarningIcon()
	METHOD StrContain(cStr,lDetail)
ENDCLASS


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRViewProc:New
Constructor da classe de visualização do processamento
Generico

Parâmetros:
	cFilename: Nome do Arquivo (Sem espaço, diretório ou extensão)
	cTitulo  : Título
	cLogOption: Nível de log: 1=Desabilitado, 2=Info, 3=Debug
	           Server para generalizar o controle da geração dentro da classe ao invés do programa chamador

@author tamyris.g
@since 03/07/2018
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD New() Class AGRViewProc
	Self:cBody 		 := ""
	Self:cBodyDetail := ""
	Self:nLinhas     := 0
	Self:lEnabledLog := .F.
	Self:cIcon		 := "OK"
	Self:lLimite 	 := .F.			// Flag que identifica se atingiu o limite máximo de caracteres, usado para evitar fazer o cálculo de bytes a toda chamado em Add
	Self:lLimiteDetail := .F.		// Flag que identifica se atingiu o limite máximo de caracteres, usado para evitar fazer o cálculo de bytes a toda chamado em AddDetail
Return Self


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRViewProc:Add
Habilita a geração de log automática com o resultado do processamento
Generico

@author tamyris.g
@since 08/12/12
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD EnableLog(cFileName, cTitulo, cLogOption, lChangeFN) Class AGRViewProc
	If Self:lEnabledLog
		Return Nil
	EndIf

	Self:lEnabledLog := .T.
	Self:AGRLog := AGRLog():New(cFileName, STR0001 + " - " + cTitulo, cLogOption, lChangeFN) //"Resultado de processamento

Return Nil


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRViewProc:Add
Adiciona mensagens
Generico

@author tamyris.g
@since 03/07/2018
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD Add(cTexto, nIdent, lAddErro) Class AGRViewProc
	Default nIdent := 0
	Default cTexto := "" 
	Default lAddErro := .F. 
	
	If Self:lLimite
		Return Nil
	EndIf
	
	If Empty(cTexto)
		Self:cBody := Self:cBody + CRLF

		If Self:lEnabledLog
			Self:AGRLog:NewLine()
		EndIf
		Return Nil
	EndIf
	
	// Verifica se a concatenação de cBodyDetail e cTexto, ultrapassa de 0.99 MB (margem de 10 KB)
	// 1 MB = 1048576 bytes
	// 0.99 MB = 1 MB - 10 KB = 1038336 bytes (10.000 caracteres)
	If Len(Self:cBody + cTexto) > 1038336
		Self:cBody := Self:cBody + "..." + CRLF
		Self:lLimite := .T.
		Return Nil
	EndIf	

	If nIdent > 0
		Self:cBody := Self:cBody + Replicate(" ", nIdent * 2)
	EndIf

	Self:cBody := Self:cBody + cTexto + CRLF

	If Self:lEnabledLog
		Self:AGRLog:Add(cTexto, nIdent)
	EndIf
	
	If lAddErro
		Self:AddErro(cTexto)
	EndIf

	Self:nLinhas++
Return Nil


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRViewProc:AddOnlyLog
Adiciona mensagens
Generico

@author tamyris.g
@since 03/07/2018
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD AddOnlyLog(cTexto, nIdent) Class AGRViewProc
	Default nIdent := 0
	Default cTexto := ""

	If Self:lEnabledLog
		Self:AGRLog:Add(cTexto, nIdent)
	EndIf
Return Nil


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRViewProc:Add
Adiciona mensagens de detalhes
Generico

@author tamyris.g
@since 03/07/2018
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD AddDetail(cTexto, nIdent) Class AGRViewProc
	Default nIdent := 0
	Default cTexto := ""
	
	If Self:lLimiteDetail
		Return Nil
	EndIf
	
	// Verifica se a concatenação de cBodyDetail e cTexto, ultrapassa de 0.99 MB (margem de 10 KB)
	// 1 MB = 1048576 bytes
	// 0.99 MB = 1 MB - 10 KB = 1038336 bytes (10.000 caracteres)
	If Len(Self:cBodyDetail + cTexto) > 1038336
		Self:cBodyDetail := Self:cBodyDetail + "..." + CRLF
		Self:lLimiteDetail := .T.
		Return Nil
	EndIf	

	If Empty(cTexto)
		Self:cBodyDetail := Self:cBodyDetail + CRLF
		Return Nil
	EndIf

	If nIdent > 0
		Self:cBodyDetail := Self:cBodyDetail + Replicate(" ", nIdent * 2)
	EndIf

	Self:cBodyDetail := Self:cBodyDetail + cTexto + CRLF
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRViewProc:AddErro
Adiciona mensagens de detalhes
Generico

@author tamyris.g
@since 03/07/2018
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD AddErro(cTexto, nIdent) Class AGRViewProc
	Self:AddDetail(cTexto, nIdent)
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRViewProc:Show
Mostra a tela com o resultado do processamento
Generico

@param cMsgOnDetail Mostra uma mensagem no final do resultado caso exista alguma mensagem de detalhamento/erro

@author tamyris.g
@since 03/07/2018
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD Show(cTitulo, cSubTitulo, cTituloDetail, cMsgOnDetail) Class AGRViewProc
	Default cTitulo    		:= STR0002 //"Resultado"
	Default cSubTitulo 		:= STR0003 //"Resumo"
	Default cTituloDetail 	:= STR0004 //"Erros"
	Default cMsgOnDetail 	:= STR0005 + "'" + cTituloDetail + "'" + STR0006  // "Ocorreram erros durante o processamento. Clique no botão para mais detalhes"

	If !Empty(cMsgOnDetail) .AND. !Empty(Self:cBodyDetail)
		Self:cBody := Self:cBody + CRLF + cMsgOnDetail
	EndIf

	If Self:lEnabledLog
		If !Empty(Self:cBodyDetail)
			Self:AGRLog:Save()
			Self:AGRLog:Add()
			Self:AGRLog:Add(Replicate("-", 120))
			Self:AGRLog:Add(cTituloDetail)
			Self:AGRLog:Add(Replicate("-", 120))
			Self:AGRLog:Add()
			Self:AGRLog:Add(Self:cBodyDetail)
		EndIf

		Self:AGRLog:EndLog()
	EndIf

	DEFINE MSDIALOG oDlg TITLE STR0007 + " - " + cTitulo From 0,0 To 18,70 /* OF oMainWnd */ //"Gestão Agroindústria"
		oPanelSummary := tPanel():Create(oDlg,01,01,,,,,,,0,0)
		oPanelSummary:Align := CONTROL_ALIGN_ALLCLIENT

		@ 4, 020 SAY cSubTitulo + " :" SIZE 130,7 PIXEL OF oPanelSummary

	    oTMultiget1 := TMultiget():New(15,07,{|u|If(Pcount()>0,Self:cBody:=u,Self:cBody)},;
	                           oPanelSummary,266,100,,,,,,.T.,,,,,,.T.)

		oTBitmap 		:= TBitmap():Create(oPanelSummary,01,06,32,32,,If(Empty(Self:cBodyDetail), Self:cIcon, "UPDERROR"),.T., ,,.F.,.F.,,,.F.,,.T.,,.F.)
		oButtonOK   	:= tButton():New(119,7,'OK',oPanelSummary,{|| oDlg:End()},40,12,,,,.T.)

		// Detalhes
		If !Empty(Self:cBodyDetail)
			oButtonDetail	:= tButton():New(119,49, cTituloDetail + ' >>',oPanelSummary,{|| oPanelSummary:Hide(), oPanelDetail:Show()},40,12,,,,.T.)

			oPanelDetail := tPanel():Create(oDlg,01,01,,,,,,,0,0)
			oPanelDetail:Align := CONTROL_ALIGN_ALLCLIENT
			oPanelDetail:Hide()

			@ 4, 020 SAY cTituloDetail + " :" SIZE 130,7 PIXEL OF oPanelDetail

	    	oTMultiDetail := TMultiget():New(15,07,{|u|If(Pcount()>0,Self:cBodyDetail:=u,Self:cBodyDetail)},;
	                           oPanelDetail,266,100,,,,,,.T.,,,,,,.T.)

			oButtonOK   	:= tButton():New(119,7,'OK',oPanelDetail,{|| oDlg:End()},40,12,,,,.T.)
			oButtonSummary	:= tButton():New(119,49,'<< Voltar',oPanelDetail,{|| oPanelDetail:Hide(), oPanelSummary:Show()},40,12,,,,.T.)
			oTBitmap 		:= TBitmap():Create(oPanelDetail,01,06,32,32,,"UPDERROR", .T., ,,.F.,.F.,,,.F.,,.T.,,.F.)

		EndIf

	ACTIVATE MSDIALOG oDlg CENTER
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRViewProc:VerifyMsg
Verifica se a variavel que armazena a mensagem está vazia
Generico

@author tamyris.g
@since 03/07/2018
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD EmptyMsg() Class AGRViewProc

Return Empty(Self:cBody)


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRViewProc:VerifyMsg
Verifica se a mensagem que está sendo incluída já existe em cBody.
Parâmetros:
	cStr: String a ser verificada
	lDetail: Se é mensagem detalhe ou não.
Generico

@author tamyris.g
@since 03/07/2018
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD StrContain(cStr,lDetail) Class AGRViewProc
	Local lRet
	Local cStrBody
	Default lDetail := .T.
	
	If lDetail 
		cStrBody := Self:cBodyDetail
	Else 
		cStrBody := Self:cBody
	EndIf
	
	lRet := cStr $ cStrBody  
	
Return lRet


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRViewProc:SetWarningIcon
Define o ícone padão como Warning
Generico

@author tamyris.g
@since 03/07/2018
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD SetWarningIcon() Class AGRViewProc
	Self:cIcon := "UPDWARNING"
Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} AGRNOW
Retorna uma string contendo a data e hora

@param lShowDate	Mostra data
@param lMs  		Mostra MiliSegundos
@param cSepDtHr	Define o separador entre data e hora. Default '_'
@param cSepHr		Define o separador entre hora, minuto e segundo. Desault '' (para manter legado)
@param cSepMS		Define o separador entre segundo e milissegundo. Default cSepDtHr (para manter legado)
@param lFileFormat 	T: Formato de arquivo: sem pontuação e data reversa. Ex: 20160127_120101. F: Formato de apresentação em tela. Ex: 27/01/2016 - 12:01:01
@author Tamyris Ganzenmueller
@since 31/10/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function AGRNOW(lShowDate, lShowMs, cSepDtHr, cSepHr, cSepMs, lFileFormat)
	Local nHH, nMM , nSS, nMS := Seconds()
	Local cRet := ""
	Default lShowDate	:= .T.
	Default lShowMs	:= .T.
	Default cSepDtHr	:= '_'
	Default cSepHr	:= ''
	Default cSepMs	:= cSepDtHr //compatibilização para manter a função com mesmo funcionamento de antes da inclusão de cSepHr e cSepMs
	Default lFileFormat := .T.
	
	nHH := Int(nMS / 3600)
	nMS -= (nHH * 3600)
	nMM := Int(nMS / 60)
	nMS -= (nMM * 60)
	nSS := Int(nMS)
	nMS := (nMs - nSS) * 1000

	If lFileFormat
		If lShowDate
			cRet := Dtos(Date()) + cSepDtHr
		EndIf
	
		cRet += StrZero(nHH,2) + ;
				cSepHr + ;
				StrZero(nMM,2) + ;
				cSepHr + ;
				StrZero(nSS,2)
			
		If lShowMs
			cRet += cSepMs + StrZero(nMS,3)
		EndIf
					
	Else 
		If lShowDate
			cRet := DtoC(Date()) + cSepDtHr
		EndIf
	
		cRet += StrZero(nHH,2) + ":" +;
				StrZero(nMM,2) + ":" + ;
				StrZero(nSS,2)
				
		If lShowMs
			cRet += ":" + StrZero(nMS,3)
		EndIf
					
	EndIf


Return (cRet)
