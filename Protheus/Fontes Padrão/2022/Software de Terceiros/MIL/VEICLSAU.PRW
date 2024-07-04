////////////////
// Versao 006 //
////////////////

#include "protheus.ch"
#include "VEIXFUNB.CH"

Function VEICLSAU()
Return()

/*/{Protheus.doc} DMS_Util

	Classe com metodos gerais de ajuda, para trabalhar com strings, numeros, datas, etc

	@author Vinicius Gati
	@since 06/03/2015
/*/
Class DMS_Util
	Method New() CONSTRUCTOR
	Method GetX3Header()
	Method GerExcel()
	Method GerHtmlTable()
	Method UltimoDia()
	Method Hora2Centes()
	Method Centes2Min()
	Method Centes2Hora()
	Method Min2Hora()
	Method Hora2Min()
	Method SomaHora()
	Method isHour()
	Method RemoveMeses()
	Method AddMeses()
	Method HorToStr()
	Method NomeMes()
	Method ElapTimeFull()
	Method Milisegundos()
	Method ParamFileOpen()
	Method ParamFileSave()
EndClass

/*/{Protheus.doc} New

	@author Vinicius Gati
	@since  06/03/2015
/*/
Method New() Class DMS_Util
Return Self


/*/{Protheus.doc} GerExcel

	@description Gera um arquivo html compatível com excel
	@author Vinicius Gati
	@since  29/06/2016
/*/
Method GerExcel(cfilename, aHeader, aDados) class DMS_Util
	local nidx := 1
	Local nidx2 := 1
	Local oFileStream   := Nil
	Local cPulaLinha := chr(13) + chr(10)
	If FILE(cfilename)
		oFileStream := FOPEN( cfilename, 1 ) // 1 = write FO_WRITE
	Else
		oFileStream := FCREATE( cfilename )
	EndIf
	// 0 FS_SET Ajusta a partir do inicio do arquivo. (Default)
	// 1 FS_RELATIVE Ajuste relativo a posição atual do arquivo.
	// 2 FS_END Ajuste a partir do final do arquivo.
	nFinalPos := FSEEK(oFileStream,0,2)
	FSEEK(oFileStream, nFinalPos)

	FWRITE(oFileStream, " <!DOCTYPE html> " + cPulaLinha)
	FWRITE(oFileStream, " <html> " + cPulaLinha)
	FWRITE(oFileStream, " <head> " + cPulaLinha)
	FWRITE(oFileStream, "   <title></title> " + cPulaLinha)
	FWRITE(oFileStream, " </head> " + cPulaLinha)
	FWRITE(oFileStream, " <body> " + cPulaLinha)
	FWRITE(oFileStream, "    <table>" + cPulaLinha)
	FWRITE(oFileStream, "      <tr>" + cPulaLinha)

	for nidx := 1 to LEN(aHeader)
		FWRITE(oFileStream, "      <td>" + cPulaLinha)
		FWRITE(oFileStream,  aHeader[nidx]  + cPulaLinha)
		FWRITE(oFileStream, "      </td>" + cPulaLinha)
	next
	FWRITE(oFileStream, "      </tr>" + cPulaLinha)

	for nidx := 1 to LEN(aDados)
		aReg := aDados[nidx]
		FWRITE(oFileStream, "  <tr>" + cPulaLinha)
		for nIdx2 := 1 to LEN(aReg)
			FWRITE(oFileStream, "    <td>" + aReg[nIdx2] + "</td>" + cPulaLinha)
		next
		FWRITE(oFileStream, "  </tr>" + cPulaLinha)
	next

	FWRITE(oFileStream, "    </table>" + cPulaLinha)
	FWRITE(oFileStream, " </body> " + cPulaLinha)
	FWRITE(oFileStream, " </html> " + cPulaLinha)
	FCLOSE(oFileStream)
Return .T.

/*/{Protheus.doc} GerHtmlTable

	@description Gera código html para ser usado onde necessário, no caso em emails
	@author Vinicius Gati
	@since  26/03/2017
/*/
Method GerHtmlTable(aDados, lGerCab) class DMS_Util
	Local cHtml := ""
	Local nIdx  := 1
	Local nIdx2 := 1
	Default lGerCab := .T.

	if lGerCab
		cHtml += "    <table>"
	end
	cHtml += "      <tr>"

	for nIdx := 1 to LEN(aDados)
		aReg := aDados[nIdx]
		cHtml += "  <tr>"
		for nIdx2 := 1 to LEN(aReg)
			cHtml += "    <td>"
			if nIdx == 1 // cabecalho
				cHtml += "<b>"
			end
			cHtml += aReg[nIdx2]
			if nIdx == 1
				cHtml += "</b>"
			end
			cHtml += "</td>"
		next
		cHtml += "  </tr>"
	next

	if lGerCab
		cHtml += "    </table>"
	end
Return cHtml

/*/{Protheus.doc} UltimoDia

	@description pega ultimo dia de um ano mes passado
	@author Vinicius Gati
	@since  06/07/2015
/*/
Method UltimoDia(nAno, nMes) class DMS_Util
	Local nDia     := 31
	Local dDtUlDia := STOD( STRZERO(nAno, 4) + STRZERO(nMes, 2) + STRZERO(nDia, 2) )

	Do While EMPTY(dDtUlDia)
		nDia --
		dDtUlDia := STOD( STRZERO(nAno, 4) + STRZERO(nMes, 2) + STRZERO(nDia, 2) )
	End Do
Return dDtUlDia

Method Hora2Centes(nTempo) class DMS_Util
If nTempo == 0
	Return 0
EndIf
Return (Int(nTempo/100) * 100 + Int( MOD(nTempo,100) / 60 * 100 ))

Method Centes2Min(nTempo) class DMS_Util
If nTempo == 0
	Return 0
EndIf
Return (Int(nTempo/100) * 60 + Int( MOD(nTempo,100) / 100 * 60 ))

/*/{Protheus.doc} Centes2Hora

	@description Converte Hora Centesimal em Hora Sexagesimal
		Ex: 15h30 nTempo = 1550
	@author Alecsandre Ferreira
	@since  03/01/2022
/*/
Method Centes2Hora(nTempo) class DMS_Util
If nTempo == 0
	Return 0
EndIf
Return ((Int(nTempo / 100) * 100) + (Int(Mod(nTempo, 100)) / 100) * 60)

Method Min2Hora(nTempo) class DMS_Util
If nTempo == 0
	Return 0
EndIf
//Return (Int(nTempo/60) * 100 + Int( MOD(nTempo,60) * 60 ))
Return Min2Hrs(nTempo)

Method Hora2Min(nTempo) class DMS_Util
If nTempo == 0
	Return 0
EndIf
Return Hrs2Min(nTempo)

Method SomaHora(nTempo,nTempoSoma) class DMS_Util
Return self:Min2Hora( self:Hora2Min(nTempo) + self:Hora2Min(nTempoSoma) )

Method isHour(nTime) class DMS_Util
	if nTime < 0
		return .f.
	endif
	if nTime >= 2400
		return .f.
	endif
	if Val(right(str(nTime,4),2)) >= 60
		return .f.
	endif
Return .t.


/*/{Protheus.doc} RemoveMeses

	@description Remove N meses de uma data X

	@param nRemover, remover de 1 a 12 meses de uma data, não remove mais de 12 se precisar disso chame 2 vezes
	@author Vinicius Gati
	@since  06/07/2015
/*/
Method RemoveMeses(dData, nRemover) class DMS_Util
	Local nAno       := YEAR(dData)
	Local nMes       := MONTH(dData)
	Local nDia       := DAY(dData)

	Default nRemover := 1

	If nMes > nRemover
		nMes := nMes - nRemover
	Else
		nMes  := (nMes - nRemover) + 12
		nAno  := nAno - 1
	EndIf

	If nDia > 28
		If nMes == 2
			nDia := DAY(::UltimoDia(nAno, nMes))
		EndIf
	EndIf
	if EMPTY( STOD( STRZERO(nAno, 4) + STRZERO(nMes, 2) + STRZERO(nDia, 2) ) )
		return ::UltimoDia(nAno, nMes)
	EndIf
Return STOD( STRZERO(nAno, 4) + STRZERO(nMes, 2) + STRZERO(nDia, 2) )


/*/{Protheus.doc} AddMeses

	@description Adiciona N meses em uma data X

	@param nAdicionar, adiciona de 1 a 12 meses de uma data, não adicionar mais de 12 se precisar disso chame 2 vezes
	@author Vinicius Gati
	@since  21/07/2015
/*/
Method AddMeses(dData, nAdicionar) class DMS_Util
	Local nAno       := YEAR(dData)
	Local nMes       := MONTH(dData)
	Local nDia       := DAY(dData)

	Default nAdicionar := 1

	nQtdAnos := INT((nMes+nAdicionar)/12) // basicamente pego o total e divido por 12 que são os anos que devo subtrair
	if (nMes + nAdicionar) <= 12
		nMes := nMes+nAdicionar
	Else
		nMes := (nMes+nAdicionar)-(nQtdAnos*12) // somo tudo e tiro 12 pra cada ano ultrapassado
		nAno += nQtdAnos
	EndiF

	If nDia > 28
		If nMes == 2
			nDia := DAY(::UltimoDia(nAno, nMes))
		EndIf
	EndIf
	if EMPTY( STOD( STRZERO(nAno, 4) + STRZERO(nMes, 2) + STRZERO(nDia, 2) ) )
		return ::UltimoDia(nAno, nMes)
	EndIf
Return STOD( STRZERO(nAno, 4) + STRZERO(nMes, 2) + STRZERO(nDia, 2) )

/*/{Protheus.doc} HorToStr

	@description Formata uma hora para exibição ao usuário

	@param nHora, hora numerica ou string 1 = 00:01 , 100 = 01:00, 2359 = 23:59
	@author Vinicius Gati
	@since  21/07/2015
/*/
Method HorToStr(nHora) class DMS_Util
	If Empty(nHora)
		return ""
	Endif
	if VALTYPE(nHora) == "C"
		nHora := VAL(nHora)
	EndIf
	cHora := STRZERO(nHora, 4)
Return LEFT(cHora, 2) + ":" + RIGHT(cHora, 2)

/*/{Protheus.doc} NomeMes
Retorna o nome do mes

@author Rubens
@since 09/06/2016
@version undefined
@param nMes, numeric, Mes no formato numerico
@type function
/*/
Method NomeMes(nMes) class DMS_Util
Do Case
	Case nMes == 1  ; Return "Jan"
	Case nMes == 2  ; Return "Fev"
	Case nMes == 3  ; Return "Mar"
	Case nMes == 4  ; Return "Abr"
	Case nMes == 5  ; Return "Mai"
	Case nMes == 6  ; Return "Jun"
	Case nMes == 7  ; Return "Jul"
	Case nMes == 8  ; Return "Ago"
	Case nMes == 9  ; Return "Set"
	Case nMes == 10 ; Return "Out"
	Case nMes == 11 ; Return "Nov"
	Case nMes == 12 ; Return "Dez"
EndCase
Return ""

/*/{Protheus.doc} ElapTimeFull
Metodo para retornar a diferenca entre hora inicial e final em segundos

@author rubens.takahashi
@since 14/10/2019
@version 1.0
@return nRetorno, Diferenca entre hora inicial e final em segundos + milisegundos
@param cIniTimeFull, characters, Hora Inicial no formato "99:99:99.999"
@param cFimTimeFull, characters, Hora Final no formato "99:99:99.999"
@type function
/*/
Method ElapTimeFull(cIniTimeFull, cFimTimeFull) class DMS_Util

	Local nIniTime
	Local nFimTime

	If empty(cIniTimeFull) .or. empty(cFimTimeFull)
		return 0
	endif

	cIniTimeFull := StrTran(cIniTimeFull, ":", "")
	nIniTime := Val(Left(cIniTimeFull,2)) * 3600 +;
		Val(SubStr(cIniTimeFull,3,2)) * 60 +;
		Val(SubStr(cIniTimeFull,5,2)) +;
		Val(Right(cIniTimeFull,3)) / 1000

	cFimTimeFull := StrTran(cFimTimeFull, ":", "")
	nFimTime := Val(Left(cFimTimeFull,2)) * 3600 +;
		Val(SubStr(cFimTimeFull,3,2)) * 60 +;
		Val(SubStr(cFimTimeFull,5,2)) +;
		Val(Right(cFimTimeFull,3)) / 1000

Return (nFimTime - nIniTime)


/*/{Protheus.doc} Milisegundos
Retorna milisegundos
@author Rubens
@since 09/06/2016
@version 1.0

@type function
/*/
Method Milisegundos() class DMS_Util
	Local nMiliSegundo := Seconds()
Return ( ( nMiliSegundo - Int(nMilisegundo) ) * 1000 )

/*/{Protheus.doc} GetX3Header
	@author Vinicius Gati
	@since 11/04/2017
	@version 1.0
	@description Retorna um variavel no formato aHeader para ser usada em newgetdados

	@param cTabela, tabela no sx3
	@param aCampos, campos que estarão no browse, caso passe um * todos os campos serão adicionados
	@param aRemCampos, campos que não devem entrar no aheader
/*/
Method GetX3Header(cTabela, aCampos, aRemCampos) class DMS_Util
	Local aHeader    := {}
	Local oArrHlp    := DMS_ArrayHelper():New()
	Local cCampos    := oArrHlp:Join(aCampos, '#') // VS3_CODIGO#VS3_CODITE#VS3_GRUPO
	Local cRemCampos := oArrHlp:Join(aRemCampos, "#")
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cTabela)
	aHeader := {}
	While !Eof().And.(x3_arquivo == cTabela)
		if ! x3_campo $ cRemCampos
			if SX3->X3_BROWSE == "S" .or. ( cCampos == "*" .OR. x3_campo $ cCampos )
				Aadd(aHeader, { TRIM(X3Titulo()) , x3_campo, x3_picture, x3_tamanho, ;
					x3_decimal, x3_valid, x3_usado, x3_tipo, x3_arquivo, x3_context, ;
					x3_relacao, x3_reserv } )
			end
		end
		dbSkip()
	EndDo
Return aHeader

/*/{Protheus.doc} ParamFileOpen
	Pega arquivo de dados com determinado nome e retorna seus dados como DMS_DataContainer

	@author Vinicius Gati
	@since 30/06/2017
	@param cFileName, String, nome do arquivo
/*/
Method ParamFileOpen(cFileName) Class DMS_Util
	local oFileData   := DMS_DataContainer():New()
	local cJson       := {}
	local oJson

	nHandle := FOPEN( cFileName, 1 ) // 1 = write FO_WRITE

	if nHandle >= 0
		cJson := FReadStr( nHandle, 1000000 ) // 1 megabyte maximo poxa tá bom né?
		fclose(nHandle)
		oJson := DMS_JsonParse():New(cJson)
		oFileData := oJson:ParseToObj()
	end
Return oFileData

/*/{Protheus.doc} ParamFileSave
	Salva no arquivo com nome enviado por parametro os dados passados pelo parametro oFileData

	@author Vinicius Gati
	@since 30/06/2017
	@param cFileName, String, nome do arquivo
	@param oFileData, DMS_DataContainer, dados que serão salvos no arquivo como json
/*/
Method ParamFileSave(cFileName, oFileData) Class DMS_Util
	local oJsonHelper := DMS_Json():New()
	local cJson       := oJsonHelper:toJson(oFileData)

	If FILE(cFileName)
		if FRenameEx(cFileName , cFileName + "_BAK") != 0
			conout(str(ferror()))
		endif
	EndIf
	If FILE(cFileName)
		FErase(cFileName)
	endif

	nHandle := FCREATE( cFileName )

	if nHandle >= 0
		fwrite(nHandle, EncodeUtf8(NoAcento(cJson)))
		FClose(nHandle)
		return .T.
	else
		conout(str(ferror()))
	end
Return .F.
