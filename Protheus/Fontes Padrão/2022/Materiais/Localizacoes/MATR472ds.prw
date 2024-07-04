#include "protheus.ch"
#include "Birtdataset.ch"
#include "matr472.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR472ds³ Autor ³Jesus Peñaloza         ³ Data ³ 08/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Data set de Remision de venta en formato birt              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³09/09/15³TTH559³Se complementa el informe con la impresion³±±
±±³            ³        ³      ³de los valores de gastos, fletes, seguro y³±±
±±³            ³        ³      ³descuentos de los remitos de entrada o de ³±±
±±³            ³        ³      ³salida.                                   ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
dataset M472ds
	title STR0006 //"Remisiones de Venta"
	description STR0006 //"Remisiones de Venta"
	PERGUNTE "MATR472"

columns
	define column ESPEC  like F2_ESPECIE
	define column SERIE  like F2_SERIE
	define column DOCUM  like F2_DOC
	define column CLIEN  like F2_CLIENTE
	define column PESO   like D2_PESO
	define column RFC    like A1_CGC
	define column CANTI  like D2_QUANT
	define column UMEDI  like D2_UM
	define column DESCR  like B1_DESC
	define column NOME   like A1_NOME
	define column LOTE   like D2_NUMLOTE
	define column SUBL   like D2_LOTECTL
	define column FECHA  type character size 10  label STR0007 //"Fecha Emision"
	define column VALOR  type character size 20  label STR0008 //"Valor Bruto"
	define column VALET  type character size 100 label STR0009 //"Importe letra"
	define column TRANSP type character size 100 label STR0010 //"Transportadora"
	define column DIREC  type character size 150 label STR0011 //"Direccion"
	define column ESTAD  type character size 100 label STR0012 //"NombreEstado"
	define column PAIS   type character size 100 label STR0013 //"Descripcion"
	define column PRECV  type character size 20  label STR0014 //"Valor Unit."
	define column TOTAL  type character size 20  label STR0015 //"Valor Total"
	define column FECVA  type character size 10  label STR0016 //"Fecha Validez"
	define column IMAGE  type character size 20  label STR0023 //Imagen
	define column GASTO  type character size 20  label STR0024 //"Valor Gatos"
	define column FLETE  type character size 20  label STR0025 //"Valor Flete"
	define column SEGUR  type character size 20  label STR0026 //"Valor Seguro"
	define column DESCT  type character size 20  label STR0027 //"Valor Descuento"
	define column MERCA  type character size 20  label STR0028 //"Valor Mercaderia"

define query "SELECT ESPEC, SERIE, DOCUM, CLIEN, FECHA, VALOR, VALET, "+;
             "TRANSP, NOME, DIREC, ESTAD, IMAGE, GASTO, FLETE, SEGUR, "+;
             "DESCT , PAIS, RFC  , CANTI, UMEDI, DESCR, PRECV, TOTAL, "+;
             "LOTE  , SUBL, FECVA, PESO , MERCA  "+;
             "FROM %WTable:1% "

process dataset

	Local cWTabAlias
	Local cRemisi := self:execParamValue("MV_PAR01")
	Local cRemisf := self:execParamValue("MV_PAR02")
	Local cSerie  := self:execParamValue("MV_PAR03")
	Local cTipo   := self:execParamValue("MV_PAR04")
	Local lRet    := .F.

	Private cQuery := ''

	If cTipo == "1"
		cTipo := "RCN"
	Else
		cTipo := "RFN"
	EndIf
	if ::isPreview()

	endif

	cWTabAlias := ::createWorkTable()
	chkFile("SF2")

	Processa({|_lEnd| lRet := CreaRepo(cWTabAlias,cRemisi,cRemisf,cSerie,cTipo)}, ::title())

	if !lRet
		MsgInfo(STR0005) //"No existen remisiones dentro de los rangos seleccionados"
	ELSE
		MsgInfo (STR0022) //"Impresion Terminada"
	endif

return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  CreaRepo ³Autor ³ Jesus Peñaloza        ³ Data ³08/05/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Crea el Reporte de Remisiones de Venta                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CreaRepo(cExp1, cExp2, cExp3, cExp4, cExp5)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ cExp1.- Nombre de tabla temporal que guardara las remisiones±±
±±³Parametros³ cExp2.- Numero de remision inicial                         ³±±
±±³          ³ cExp3.- Numero de remision final                           ³±±
±±³          ³ cExp4.- Numero de Serie                                    ³±±
±±³          ³ cExp5.- Tipo de Operacion                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR472                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CreaRepo(cWTabAlias, cRemisi, cRemisf, cSerie, cTipo)
	Local cnt := 0
	Local nPes := 0
	Local cDoc := ''
	Local lRet := .F.
	Local cTempF := CriaTrab(nil, .f.)
	Local nCount := 0

	If cTipo == "RCN" // remisiones de entrada SF1 y SD1
		cQuery := "SELECT F1_ESPECIE, F1_SERIE, F1_DOC, F1_FORNECE, F1_EMISSAO, F1_VALBRUT, F1_VALMERC, "
		cQuery += "F1_TRANSP, F1_DESPESA, F1_FRETE, F1_DESCONT, F1_SEGURO, D1_DESC, "
		cQuery += "D1_QUANT, D1_UM, D1_VUNIT, D1_TOTAL, D1_NUMLOTE, D1_LOTECTL, D1_DTVALID, D1_PESO, "
	Else
		cQuery := "SELECT F2_ESPECIE, F2_SERIE, F2_DOC, F2_CLIENTE, F2_EMISSAO, F2_VALBRUT, F2_VALMERC, "
		cQuery += "F2_TRANSP, F2_DESPESA, F2_FRETE, F2_DESCONT, F2_SEGURO, D2_DESC, D2_DESCON, "
		cQuery += "D2_QUANT, D2_UM, D2_PRCVEN, D2_TOTAL, D2_NUMLOTE, D2_LOTECTL, D2_DTVALID, D2_PESO, "
	Endif
	cQuery += "A1_NOME, A1_END, A1_BAIRRO, A1_EST, A1_MUN, A1_PAIS, A1_CEP, A1_CGC, B1_DESC "
	If cPaisLoc == 'MEX'
		cQuery += ", A1_NR_END, A1_NROINT "
	EndIf
	if cTipo == "RCN"
		cQuery += "FROM "+RetSqlName("SF1")+" SF1, "+RetSqlName("SA1")+" SA1, "+RetSqlName("SD1")+" SD1, "+RetSqlName("SB1")+" SB1 "
	else
		cQuery += "FROM "+RetSqlName("SF2")+" SF2, "+RetSqlName("SA1")+" SA1, "+RetSqlName("SD2")+" SD2, "+RetSqlName("SB1")+" SB1 "
	endif
	if cTipo == "RCN"
		cQuery += "WHERE  F1_DOC BETWEEN '"+cRemisi+"' AND '"+cRemisf+"' AND F1_SERIE = '"+cSerie+"' AND F1_ESPECIE = '"+cTipo+"' "
		cQuery += "AND F1_FORNECE = A1_COD AND F1_LOJA = A1_LOJA AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND A1_COD = D1_FORNECE "
		cQuery += "AND A1_LOJA = D1_LOJA AND D1_COD = B1_COD "
		cQuery += "AND F1_FILIAL = '"+xFilial("SF1")+"' AND D1_FILIAL = '"+xFilial("SD1")+"' "
	else
		cQuery += "WHERE  F2_DOC BETWEEN '"+cRemisi+"' AND '"+cRemisf+"' AND F2_SERIE = '"+cSerie+"' AND F2_ESPECIE = '"+cTipo+"' "
		cQuery += "AND F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND A1_COD = D2_CLIENTE "
		cQuery += "AND A1_LOJA = D2_LOJA AND D2_COD = B1_COD "
		cQuery += "AND F2_FILIAL = '"+xFilial("SF2")+"' AND D2_FILIAL = '"+xFilial("SD2")+"' "
	endif
	cQuery += "AND A1_FILIAL = '"+xFilial("SA1")+"' AND B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery += "AND SA1.D_E_L_E_T_ = '' AND SB1.D_E_L_E_T_ = '' "
	if cTipo == "RCN"
		cQuery += "AND SF1.D_E_L_E_T_ = '' AND SD1.D_E_L_E_T_ = '' "
		cQuery += "ORDER BY  F1_DOC"
	else
		cQuery += "AND SF2.D_E_L_E_T_ = '' AND SD2.D_E_L_E_T_ = '' "
		cQuery += "ORDER BY  F2_DOC "
	endif

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempF,.T.,.T.)

	count to nCount

	(cTempF)->(dbGoTop())
	ProcRegua(nCount)

	While (!(cTempF)->(EOF()))
		cnt++
		if cTipo == "RCN"
			cDoc := (cTempF)->F1_DOC
		else
			cDoc := (cTempF)->F2_DOC
		endif
		nPes := 0

		While (!(cTempF)->(EOF())) .and. if(cTipo == "RCN",cDoc == (cTempF)->F1_DOC,cDoc == (cTempF)->F2_DOC)
			Incproc()
			RecLock(cWTabAlias, .T.)

			if cTipo == "RCN"
				(cWTabAlias)->ESPEC := (cTempF)->F1_ESPECIE
				(cWTabAlias)->SERIE := (cTempF)->F1_SERIE
				(cWTabAlias)->DOCUM := (cTempF)->F1_DOC
				(cWTabAlias)->CLIEN := (cTempF)->F1_FORNECE
				(cWTabAlias)->FECHA := substr((cTempF)->F1_EMISSAO,7)+"/"+substr((cTempF)->F1_EMISSAO,5,2)+"/"+substr((cTempF)->F1_EMISSAO,1,4)
				(cWTabAlias)->VALOR := Alltrim(Transform((cTempF)->F1_VALBRUT, "@E 999,999,999.99"))
				(cWTabAlias)->VALET := extenso((cTempF)->F1_VALBRUT)
				(cWTabAlias)->TRANSP := POSICIONE("SA4",1,xFilial("SA4")+(cTempF)->F1_TRANSP,"A4_NOME")
				(cWTabAlias)->CANTI := (cTempF)->D1_QUANT
				(cWTabAlias)->UMEDI := (cTempF)->D1_UM
				(cWTabAlias)->PRECV := Alltrim(Transform((cTempF)->D1_VUNIT, "@E 999,999,999.99"))
				(cWTabAlias)->TOTAL := Alltrim(Transform((cTempF)->D1_TOTAL, "@E 999,999,999.99"))
				(cWTabAlias)->GASTO := Alltrim(Transform((cTempF)->F1_DESPESA, "@E 999,999,999.99"))
				(cWTabAlias)->FLETE := Alltrim(Transform((cTempF)->F1_FRETE, "@E 999,999,999.99"))
				(cWTabAlias)->SEGUR := Alltrim(Transform((cTempF)->F1_SEGURO, "@E 999,999,999.99"))
				(cWTabAlias)->DESCT := Alltrim(Transform((cTempF)->F1_DESCONT, "@E 999,999,999.99"))
				(cWTabAlias)->MERCA := Alltrim(Transform((cTempF)->F1_VALMERC, "@E 999,999,999.99"))
				(cWTabAlias)->LOTE  := (cTempF)->D1_NUMLOTE
				(cWTabAlias)->SUBL  := (cTempF)->D1_LOTECTL
				If Len(Alltrim((cTempF)->D1_DTVALID)) > 0
					(cWTabAlias)->FECVA := substr((cTempF)->D1_DTVALID,7)+"/"+substr((cTempF)->D1_DTVALID,5,2)+"/"+substr((cTempF)->D1_DTVALID,1,4)
				EndIf
				nPes += (cTempF)->D1_PESO
			else
				(cWTabAlias)->ESPEC := (cTempF)->F2_ESPECIE
				(cWTabAlias)->SERIE := (cTempF)->F2_SERIE
				(cWTabAlias)->DOCUM := (cTempF)->F2_DOC
				(cWTabAlias)->CLIEN := (cTempF)->F2_CLIENTE
				(cWTabAlias)->FECHA := substr((cTempF)->F2_EMISSAO,7)+"/"+substr((cTempF)->F2_EMISSAO,5,2)+"/"+substr((cTempF)->F2_EMISSAO,1,4)
				(cWTabAlias)->VALOR := Alltrim(Transform((cTempF)->F2_VALBRUT, "@E 999,999,999.99"))
				(cWTabAlias)->VALET := extenso((cTempF)->F2_VALBRUT)
				(cWTabAlias)->TRANSP := POSICIONE("SA4",1,xFilial("SA4")+(cTempF)->F2_TRANSP,"A4_NOME")
				(cWTabAlias)->CANTI := (cTempF)->D2_QUANT
				(cWTabAlias)->UMEDI := (cTempF)->D2_UM
				(cWTabAlias)->PRECV := Alltrim(Transform( ( (cTempF)->D2_PRCVEN + ( (cTempF)->D2_DESCON / (cTempF)->D2_QUANT) ), "@E 999,999,999.99" ) )
				(cWTabAlias)->TOTAL := Alltrim(Transform( ( (cTempF)->D2_TOTAL  + (cTempF)->D2_DESCON ) , "@E 999,999,999.99" ) )
				(cWTabAlias)->GASTO := Alltrim(Transform((cTempF)->F2_DESPESA, "@E 999,999,999.99"))
				(cWTabAlias)->FLETE := Alltrim(Transform((cTempF)->F2_FRETE, "@E 999,999,999.99"))
				(cWTabAlias)->SEGUR := Alltrim(Transform((cTempF)->F2_SEGURO, "@E 999,999,999.99"))
				(cWTabAlias)->DESCT := Alltrim(Transform((cTempF)->F2_DESCONT, "@E 999,999,999.99"))
				(cWTabAlias)->MERCA := Alltrim(Transform((cTempF)->F2_VALMERC + (cTempF)->F2_DESCONT, "@E 999,999,999.99"))
				(cWTabAlias)->LOTE  := (cTempF)->D2_NUMLOTE
				(cWTabAlias)->SUBL  := (cTempF)->D2_LOTECTL
				If Len(Alltrim((cTempF)->D2_DTVALID)) > 0
					(cWTabAlias)->FECVA := substr((cTempF)->D2_DTVALID,7)+"/"+substr((cTempF)->D2_DTVALID,5,2)+"/"+substr((cTempF)->D2_DTVALID,1,4)
				EndIf
				nPes += (cTempF)->D2_PESO
			endif
			if cPaisLoc == 'MEX'
				(cWTabAlias)->DIREC := Alltrim((cTempF)->A1_END)+" Num "+ Alltrim((cTempF)->A1_NR_END)+", " +Alltrim((cTempF)->A1_NROINT)+", "+ Alltrim((cTempF)->A1_BAIRRO)
			else
				(cWTabAlias)->DIREC := ALLTRIM((cTempF)->A1_END)+", "+ Alltrim((cTempF)->A1_BAIRRO)
			endif
			(cWTabAlias)->NOME  := alltrim((cTempF)->A1_NOME)
			(cWTabAlias)->ESTAD := AllTrim(POSICIONE("SX5",1,XFILIAL("SX5")+"12"+(cTempF)->A1_EST,"X5_DESCSPA"))
			(cWTabAlias)->PAIS  := Alltrim(POSICIONE("SYA",1,xFilial("SYA")+(cTempF)->A1_PAIS,"YA_DESCR"))+", "+ alltrim((cTempF)->A1_CEP)
			(cWTabAlias)->RFC   := alltrim((cTempF)->A1_CGC)
			(cWTabAlias)->DESCR := (cTempF)->B1_DESC
			(cWTabAlias)->PESO := nPes
			(cWTabAlias)->IMAGE := "lgrl"+cEmpAnt+".bmp"

			(cWTabAlias)->(MsUnlock())
			(cTempF)->(dbSkip())
		EndDo
	EndDo
	(cTempF)->(dbCloseArea())
	lRet := cnt > 0
Return lRet