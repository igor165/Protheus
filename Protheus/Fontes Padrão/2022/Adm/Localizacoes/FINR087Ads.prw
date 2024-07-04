#include "protheus.ch"
#include "Birtdataset.ch"
#include "finr087a.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FINR087Ads³ Autor ³Jesus Peñaloza         ³ Data ³ 29/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Data set de Facturas de Recibos de cobro en formato birt   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
dataset F087ds
	title STR0005 //"Facturas - Recibos de Cobro"
	description STR0005 //"Facturas - Recibos de Cobro"
	PERGUNTE "FINR087A"
columns
	define column RECIB like EL_RECIBO
	define column SERIE like EL_SERIE
	define column FECHA type character size 10     label STR0006 //"Fecha"
	define column NOMBR type character size 100    label STR0007 //"Nombre"
	define column DIREC type character size 100    label STR0033 //"Direccion"
	define column CIUDA type character size 100    label STR0008 //"Ciudad"
	define column PAIS  type character size 100    label STR0009 //"Pais"
	define column FACTU type character size 30     label STR0010 //"Factura"
	define column FECVE type character size 10     label STR0011 //"Fecha Ven"
	define column IMPOR type character size 20     label STR0012 //"Importe"
	define column IMPFA type character size 20     label STR0013 //"Importe Facturas"
	If cPaisLoc == 'ARG'
		define column REVIS type character size 20  label STR0014 //"Revision"
	EndIf
	define column IMAGE type character size 20   label "Imagen"


If cPaisLoc == 'ARG'
	define query "SELECT RECIB, SERIE, FECHA, NOMBR, DIREC, CIUDA, PAIS, FACTU, FECVE, IMPOR, IMPFA, REVIS, IMAGE FROM %WTable:1% "
Else
	define query "SELECT RECIB, SERIE, FECHA, NOMBR, DIREC, CIUDA, PAIS, FACTU, FECVE, IMPOR, IMPFA, IMAGE FROM %WTable:1% "
EndIf

process dataset

	Local cWTabAlias
	Local cnt       := 0
	Local lRet      := .F.
	Local cReci     := ''
	Local cRecf     := ''
	Local cSerie	  := ''
	Local cRevi     := ''
	Local cRevf     := ''

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
	endif


	cWTabAlias := ::createWorkTable()
	chkFile("SEL")
	Processa({|_lEnd| lRet := CreaRepo(cWTabAlias,cReci,cRecf,cSerie,cRevi,cRevf)}, ::title())

	if !lRet
		MsgInfo(STR0004) //"No existen recibos dentro de los rangos seleccionados"
	else
		MsgInfo("Impresion Terminada")
	endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  CreaRepo ³Autor ³ Jesus Peñaloza        ³ Data ³29/05/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Crea el Reporte de Recibos de Cobro                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CreaRepo(cExp1, cExp2, cExp3, cExp4, cExp5, cExp6)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ cExp1.- Nombre de tabla temporal que guardara las remisiones±±
±±³Parametros³ cExp2.- Numero de recibo de cobro inicial                  ³±±
±±³          ³ cExp3.- Numero de recibo de cobro final                    ³±±
±±³          ³ cExp4.- Numero de Serie                                    ³±±
±±³          ³ cExp5.- Numero de Revision inicial (solo Argentina)        ³±±
±±³          ³ cExp6.- Numero de Revision final (solo Argentina)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR472                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CreaRepo(cWTabAlias, cReci, cRecf, cSerie, cRevi, cRevf)

	Local cSerief  := ''
	Local cFecha   := ''
	Local cNombre  := ''
	Local cDirecc  := ''
	Local cCiudad  := ''
	Local cPais    := ''
	Local cRecibo  := ''
	Local cFactBan := ''
	Local cFactNum := ''
	Local cFactImp := ''
	Local cRevision:= ''
	Local nTotalf  := 0
	Local nTotalfa := 0
	Local cQuery   := ''
	Local cTempF   := CriaTrab(Nil, .F.)
	Local nCount   := 0
	Local lVersao  := .F.
	Local cnt      := 0
	Local lRet     := .F.

	cQuery := "SELECT EL_RECIBO, EL_EMISSAO, EL_SERIE,EL_PREFIXO, EL_NUMERO, EL_DTVCTO, EL_VLMOED1, "
	cQuery += "EL_CLIORIG, EL_LOJORIG, A1_PAIS, EL_TIPODOC, "
	If cPaisLoc != 'ARG'
		cQuery += "A1_NR_END, A1_NROINT, "
	Else
		dbSelectArea("SEL")
		If SEL->(FieldPos("EL_VERSAO")) > 0
			lVersao := .T.
			cQuery += "EL_VERSAO, "
		EndIf
	EndIf
	cQuery += "A1_NOME, A1_END, A1_BAIRRO, A1_EST, A1_MUN, A1_CEP "
	cQuery += "FROM "+RetSqlName("SEL")+" SEL, "+RetSqlName("SA1")+" SA1 "
	cQuery += "WHERE EL_CLIORIG = A1_COD AND EL_LOJORIG = A1_LOJA "
	cQuery += "AND EL_FILIAL = '"+xFilial("SEL")+"' "
	cQuery += "AND A1_FILIAL = '"+xFilial("SA1")+"' "
	cQuery += "AND EL_RECIBO BETWEEN '"+cReci+"' AND '"+cRecf+"' AND EL_SERIE = '"+cSerie+"' "
	If lVersao
		cQuery += "AND EL_VERSAO BETWEEN '"+cRevi+"' AND '"+cRevf+"' "
	EndIf
	//cQuery += "AND EL_TIPODOC = 'TB' "
	cQuery += "AND SEL.D_E_L_E_T_ = '' "
	cQuery += "AND SA1.D_E_L_E_T_ = '' "
	cQuery += "ORDER BY EL_RECIBO, EL_NUMERO "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempF,.T.,.T.)
	TCSetField(cTempF, "EL_EMISSAO", "D")
	TCSetField(cTempF, "EL_DTVCTO", "D")

	count to nCount

	(cTempF)->(dbGoTop())
	ProcRegua(nCount)

	While (!(cTempF)->(EOF()))
		cRecibo  := (cTempF)->EL_RECIBO
		cSerief  := (cTempF)->EL_SERIE
		cFecha   := ''
		cNombre  := ''
		cDirecc  := ''
		cCiudad  := ''
		cPais    := ''
		cFactBan := ''
		cFactNum := ''
		cFactImp := ''
		nTotalf  := 0
		nTotalfa := 0
		cRevision := ''

		if (cTempF)->EL_TIPODOC <> "TB"
			(cTempF)->(dbSkip())
		endif

		While ((cTempF)->EL_RECIBO == cRecibo .and. !(cTempF)->(EOF()) .and. (cTempF)->EL_TIPODOC == "TB")
			Incproc()
			cnt++
			cFecha := DTOC((cTempF)->EL_EMISSAO)
			cNombre:= (cTempF)->A1_NOME
			If cPaisLoc == 'ARG'
				cDirecc:= Alltrim((cTempF)->A1_END)+", "+Alltrim((cTempF)->A1_BAIRRO)
			Else
				cDirecc:= Alltrim((cTempF)->A1_END)+", "+Alltrim((cTempF)->A1_NR_END)+", "+Alltrim((cTempF)->A1_NROINT)+ ", "+Alltrim((cTempF)->A1_BAIRRO)
			EndIf
			cCiudad:= Alltrim(POSICIONE("SX5",1,XFILIAL("SX5")+"12"+(cTempF)->A1_EST,"X5_DESCSPA"))+", "+Alltrim((cTempF)->A1_MUN)
			cPais  := Alltrim(POSICIONE("SYA",1,xFilial("SYA")+(cTempF)->A1_PAIS,"YA_DESCR"))+", C.P. "+alltrim((cTempF)->A1_CEP)
			cFactBan := Alltrim((cTempF)->EL_PREFIXO)+"/"+Alltrim((cTempF)->EL_NUMERO)
			cFactNum := DTOC((cTempF)->EL_DTVCTO)
			nTotalf  := (cTempF)->EL_VLMOED1
			nTotalfa += nTotalf
			cFactImp := Alltrim(Transform(nTotalf, "@E 999,999,999.99"))
			If lVersao
				cRevision := (cTempF)->EL_VERSAO
			EndIf
			RecLock(cWTabAlias, .T.)
			(cWTabAlias)->RECIB := cRecibo
			(cWTabAlias)->SERIE := cSerief
			(cWTabAlias)->FECHA := cFecha
			(cWTabAlias)->NOMBR := cNombre
			(cWTabAlias)->DIREC := cDirecc
			(cWTabAlias)->CIUDA := cCiudad
			(cWTabAlias)->PAIS  := cPais
			(cWTabAlias)->FACTU := cFactBan
			(cWTabAlias)->FECVE := cFactNum
			(cWTabAlias)->IMPOR := cFactImp
			(cWTabAlias)->IMPFA := Transform(nTotalfa, "@E 999,999,999.99")
			(cWTabAlias)->IMAGE := "lgrl"+cEmpAnt+".bmp"
			If lVersao
				(cWTabAlias)->REVIS := cRevision
			EndIf
			(cWTabAlias)->(MsUnlock())
			(cTempF)->(dbSkip())
		EndDo
	EndDo
	(cTempF)->(dbCloseArea())
	lRet := cnt > 0
Return lRet