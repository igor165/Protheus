#include "protheus.ch"
#include "Birtdataset.ch"
#include "finr087a.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FINR087AIds³ Autor ³Jesus Peñaloza         ³ Data ³ 30/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Data set de Importes de Recibos de cobro en formato birt     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³        ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³BOPS  ³ Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
dataset F087Ids
	title STR0025 //"Importe - Recibos de Cobro"
	description STR0025 //"Importe - Recibos de Cobro"
	PERGUNTE "FINR087A"
columns
	define column RECIB like EL_RECIBO
	define column SERIE like EL_SERIE
	define column FECHA type character size 10   label STR0006 //"Fecha"
	define column IMPLE type character size 100  label STR0021 //"Importe Letra"
	define column EFECT type character size 1    label STR0022 //"Efectivo"
	define column CHEQU type character size 1    label STR0023 //"Cheque"
	define column DEPOS type character size 1    label STR0024 //"Deposito"
	If cPaisLoc == 'ARG'
		define column REVIS type character size 20  label STR0014 //"Revision"
	EndIf

If cPaisLoc == 'ARG'
	define query "SELECT RECIB, FECHA, SERIE, IMPLE, EFECT, CHEQU, DEPOS, REVIS FROM %WTable:1% "
Else
	define query "SELECT RECIB, FECHA, SERIE, IMPLE, EFECT, CHEQU, DEPOS FROM %WTable:1% "
EndIf

process dataset

	Local cWTabAlias
	Local cnt      := 0
	Local lVersao  := .F.
	Local cFecha   := ''
	Local cReci    := ''
	Local cRecf    := ''
	Local cSerie	 := ''
	Local cSerief  := ''
	Local cRecibo  := ''
	Local nTotalf  := 0
	Local nTotalfa := 0
	Local cQuery   := ''
	Local cTempF   := CriaTrab(Nil, .F.)
	Local cRetorno := ''
	Local cCheque  := ''
	Local cEfecti  := ''
	Local cTransf  := ''
	Local cRevision:= ''

	If ::isPreview()
	Endif

	IF cPaisLoc == 'MEX'
		cReci  := self:execParamValue("MV_PAR01")
		cRecf  := self:execParamValue("MV_PAR02")
		cSerie := self:execParamValue("MV_PAR03")
	else
		cReci  := self:execParamValue("MV_PAR01")
		cRecf  := self:execParamValue("MV_PAR02")
		cRevi  := self:execParamValue("MV_PAR03")
		cRevf  := self:execParamValue("MV_PAR04")
		cSerie := self:execParamValue("MV_PAR05")

		dbSelectArea("SEL")
		If SEL->(FieldPos("EL_VERSAO")) > 0
			lVersao := .T.
		EndIf
	EndIf

	cQuery := "SELECT EL_RECIBO, EL_EMISSAO, EL_SERIE, EL_VALOR, EL_TIPODOC, "
	If cPaisLoc == 'ARG' .and. lVersao
		cQuery += "EL_VERSAO, "
	EndIf
	cQuery += "EL_CLIORIG, EL_LOJORIG "
	cQuery += "FROM "+RetSqlName("SEL")+" SEL, "+RetSqlName("SA1")+" SA1 "
	cQuery += "WHERE EL_CLIORIG = A1_COD AND EL_LOJORIG = A1_LOJA "
	cQuery += "AND EL_FILIAL = '"+xFilial("SEL")+"' "
	cQuery += "AND A1_FILIAL = '"+xFilial("SA1")+"' "
	cQuery += "AND EL_RECIBO BETWEEN '"+cReci+"' AND '"+cRecf+"' AND EL_SERIE = '"+cSerie+"' "
	If lVersao
		cQuery += "AND EL_VERSAO BETWEEN '"+cRevi+"' AND '"+cRevf+"' "
	EndIf
	cQuery += "AND EL_TIPODOC NOT IN('TB', 'RA', 'RS', 'RI', 'RB', 'RG') "
	cQuery += "AND SEL.D_E_L_E_T_ = '' "
	cQuery += "AND SA1.D_E_L_E_T_ = '' "
	cQuery += "ORDER BY EL_RECIBO, EL_NUMERO "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempF,.T.,.T.)
	TCSetField(cTempF, "EL_EMISSAO", "D")
	TCSetField(cTempF, "EL_DTVCTO", "D")

   cWTabAlias := ::createWorkTable()
   chkFile(cTempF)
	(cTempF)->(dbGoTop())

	While (!(cTempF)->(EOF()))
		cRecibo  := (cTempF)->EL_RECIBO
		cSerief  := (cTempF)->EL_SERIE
		nTotalf  := 0
		nTotalfa := 0
		cRetorno := ''
		cFecha   := ''
		cCheque  := ''
		cEfecti  := ''
		cTransf  := ''
		cRevision:= ''
		While ((cTempF)->EL_RECIBO == cRecibo .and. !(cTempF)->(EOF()))
			cnt++
			cFecha := DTOC((cTempF)->EL_EMISSAO)
			If Substr((cTempF)->EL_TIPODOC,1,2) == "CH"
				cRetorno:="Cheque"
			ElseIf Substr((cTempF)->EL_TIPODOC,1,2) == "EF"
				cRetorno:="Efectivo"
			Elseif Substr((cTempF)->EL_TIPODOC,1,2) == "TF"
				cRetorno:="Deposito"
			Elseif Substr((cTempF)->EL_TIPODOC,1,2) == "LT"
				cRetorno:="Letra"
			Elseif Substr((cTempF)->EL_TIPODOC,1,2) == "TJ"
				cRetorno:="Credito"
			Endif
			If lVersao
				cRevision := (cTempF)->EL_VERSAO
			EndIf
			nTotalf  := (cTempF)->EL_VALOR
			nTotalfa += nTotalf
			RecLock(cWTabAlias, .T.)
			(cWTabAlias)->RECIB := cRecibo
			(cWTabAlias)->SERIE := cSerief
			(cWTabAlias)->IMPLE := Extenso(nTotalfa)
			If cRetorno == "Cheque"
				cCheque  := 'X'
			ElseIf cRetorno == "Efectivo"
				cEfecti  := 'X'
			ElseIf cRetorno == "Deposito"
				cTransf  := 'X'
			EndIf
			(cWTabAlias)->EFECT := cEfecti
			(cWTabAlias)->CHEQU := cCheque
			(cWTabAlias)->DEPOS := cTransf
			(cWTabAlias)->FECHA := cFecha
			If lVersao
				(cWTabAlias)->REVIS := cRevision
			EndIf
			(cWTabAlias)->(MsUnlock())
			(cTempF)->(dbSkip())
		EndDo
	EndDo
	(cTempF)->(dbCloseArea())

Return .T.
