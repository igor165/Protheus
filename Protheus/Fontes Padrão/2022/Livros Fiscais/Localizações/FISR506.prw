#Include "PROTHEUS.Ch"
#Include "FISR506.ch"

/*/{Protheus.doc} FISR506
	Genera archivo de texto para Resolución DDI-000396 Artículo 1°
	Información de ingresos obtenidos por actividades excluidas o no sujetas y otros
	ingresos no gravados, deducciones o exenciones de los contribuyentes de ICA en Bogotá
	@type    Function
	@author  ARodriguez
	@since   25/04/2022
	@version 1.0
	@param 	 ninguno
	@return  Nil
/*/
Function FISR506()
Local oMeter
Local oText
Local oDlg
Local lEnd			:= .F.
Local cArqRef		:= GetNextAlias()
Local dDataIni		:= CtoD("")
Local dDataFim		:= CtoD("")
Local cPlanoRef		:= ""
Local cVersao		:= ""
Local cMoeda		:= "01"
Local cTpSald		:= "1"
Local lImpAntLP		:= .F.
Local dDataLP		:= CtoD("")
Local nDivide		:= 1
Local lVlrZerado	:= .F.
Local aSelFil		:= {}
Local nAnio			:= 0
Local nMonto		:= 0
Local cDir			:= ""

Private lAutomato	:= IsBlind()
Private _oFISR506

If Pergunte( "FISR506" , .T. )

	dDataIni	:= MV_PAR01
	dDataFim	:= MV_PAR02
	nAnio		:= MV_PAR03
	cPlanoRef	:= MV_PAR04
	cVersao		:= MV_PAR05
	nMonto		:= MV_PAR06
	cDir		:= MV_PAR07

	If Empty(cPlanoRef) .Or. Empty(cVersao)
		If !lAutomato
			MsgAlert(STR0002)	//"Plan Referencial y/o Versión no definidos."
		EndIf
		Return
	EndIf

	DbSelectArea("CVN")
	DbSetOrder(4) 	//CVN_FILIAL+CVN_CODPLA+CVN_VERSAO+CVN_CTAREF
	If !DbSeek(xFilial("CVN")+cPlanoRef+cVersao)
		If !lAutomato
			MsgAlert(STR0003)	//"Plan Referencial y Versión no registrados en el catálogo Plan de Cuentas Referencial."
		EndIf
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Arquivo Temporario para Impressao			  		     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lAutomato
		MsgMeter({| oMeter, oText, oDlg, lEnd | ;
			CtSalPlanRef(oMeter, oText, oDlg, @lEnd, @cArqRef, dDataIni, dDataFim, cPlanoRef, cVersao,;
			cMoeda, cTpSald, lImpAntLP, dDataLP, nDivide, lVlrZerado, aSelfil)},;
			OemToAnsi(OemToAnsi(STR0004)),;  	//"Creando archivo temporal..."
			OemToAnsi(STR0001))  				//"Ingresos por actividades e ingresos exentos de ICA"
	Else
		CtSalPlanRef(oMeter, oText, oDlg, @lEnd, @cArqRef, dDataIni, dDataFim, cPlanoRef, cVersao,;
			cMoeda, cTpSald, lImpAntLP, dDataLP, nDivide, lVlrZerado, aSelfil)
	EndIf

	nCount := (cArqRef)->(RecCount())

	If nCount > 0

		If !lAutomato
			MsgMeter({| oMeter, oText, oDlg, lEnd | GrabaTxt(oMeter, oText, oDlg, @lEnd, cDir, cArqRef, nAnio, nMonto)},;
				OemToAnsi(OemToAnsi(STR0005)),;  	//"Grabando archivo magnético ..."
				OemToAnsi(STR0001))  				//"Ingresos por actividades e ingresos exentos de ICA"
		Else
			GrabaTxt(oMeter, oText, oDlg, @lEnd, cDir, cArqRef, nAnio, nMonto)
		EndIf

	EndIf

	(cArqRef)->(dbCloseArea())

	If _oFISR506 <> Nil
		_oFISR506:Delete()
		_oFISR506 := Nil
	EndIf
 EndIf

Return

/*/{Protheus.doc} CtSalPlanRef
	Genera archivo de trabajo con saldos de plan de cuentas referencial
	Función similar a CTBR049->CtSalPlanRef()
	@type    Static Function
	@author  ARodriguez
	@since   25/04/2022
	@version 1.0
	@param   oMeter, object, barra de status
	@param   oText, object, barra de status
	@param   oDlg, object, barra de status
	@param   lEnd, logical, control de cancelación del proceso
	@param   cArqTrab, character, archivo temporal a generar
	@param   dDataIni, data, fecha inicial
	@param   dDataFim, data, fecha final
	@param   cPlanRef, character, plan referencial
	@param   cVersao, character, versión
	@param   cMoeda, character, moneda
	@param   cTpSald, character, tipo de saldo
	@param   lImpAntLP, logical, considera pérdidas/ganancias
	@param   dDataLP, data, fecha pérdidas/ganancias
	@param   nDivide, numeric, factor para informar valores
	@param   lVlrZerado, logical, valores en cero? (cuentas sínteticas)
	@param   aSelfil, array, sucursales
	@return  Nil
/*/
Static Function CtSalPlanRef(oMeter, oText, oDlg, lEnd, cArqTrab, dDataIni, dDataFim, cPlanRef, cVersao, cMoeda, cTpSald, lImpAntLP, dDataLP, nDivide, lVlrZerado, aSelfil)
Local cQuery 		:= ""
Local cAliasCVD		:= ""
Local aCampos		:= {}
Local aTamConta		:= TAMSX3("CT1_CONTA")
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local nTamCta 		:= Len(CriaVar("CT1->CT1_DESC"+cMoeda))
Local aTamClasse	:= TAMSX3("CVD_CLASSE")
Local aTamCtaSup	:= TAMSX3("CVD_CTASUP")
Local aCtbMoeda 	:= CTbMoeda(cMoeda)
Local nDecimais 	:= aCtbMoeda[5]
Local aSaldoAnt		:= {}
Local aSaldoAtu		:= {}
Local lObj			:= (oMeter <> Nil .And. !IsBlind())
Local nMeter		:= 0

Default cArqTrab	:= "cArqRef"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ(¿
//³Monta a estrutura do arquivo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ(Ù
aAdd(aCampos, { "CONTA"		, "C", aTamConta[1]	, 0 })
aAdd(aCampos, { "DESCCTA"	, "C", nTamCta		, 0 })
aAdd(aCampos, { "SALDOANT"	, "N", aTamVal[1]+2	, nDecimais })
aAdd(aCampos, { "SALDODEB"	, "N", aTamVal[1]+2	, nDecimais })
aAdd(aCampos, { "SALDOCRD"	, "N", aTamVal[1]+2	, nDecimais })
aAdd(aCampos, { "SALDOATU"	, "N", aTamVal[1]+1	, nDecimais })
aAdd(aCampos, { "MOVIMENTO"	, "N", aTamVal[1]+1	, nDecimais })
aAdd(aCampos, { "CLASSE"	, "C", aTamClasse[1]	, 0 })
aAdd(aCampos, { "SUPERIOR"	, "C", aTamCtaSup[1]	, 0 })
cChave := "CONTA"

_oFISR506 := FWTemporaryTable():New( cArqTrab )
_oFISR506:SetFields(aCampos)
_oFISR506:AddIndex("1", {cChave})

//------------------
//Criação da tabela temporaria
//------------------
_oFISR506:Create()

dbSelectArea(cArqTrab)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona o arquivo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasCVD := GetNextAlias()
cQuery	+= " SELECT "
cQuery	+= " 	CVD_CONTA, "
cQuery	+= " 	CVD_ENTREF, "
cQuery	+= " 	CVD_CODPLA, "
cQuery	+= " 	CVD_CTAREF, "
cQuery	+= " 	CVD_CUSTO, "
cQuery	+= " 	CVD_CLASSE,	"
cQuery	+= " 	CVD_CTASUP  "
cQuery	+= " FROM  "
cQuery	+= RetSQLTab("CVD")
cQuery	+= " WHERE  "
cQuery	+= " 	CVD_CODPLA = '"+cPlanRef+"' AND "
cQuery	+= " 	CVD_VERSAO = '"+cVersao+"' AND "
cQuery	+= "    CVD_CTAREF <> '' AND "
cQuery	+= RetSQLCond("CVD")
cQuery	+= "ORDER BY CVD_CODPLA,CVD_CTAREF, CVD_CTASUP "
cQuery	:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCVD,.T.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa o saldo das contas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cAliasCVD)->(!Eof())
	If lObj
		oMeter:SetTotal((cAliasCVD)->(RecCount()))
		oMeter:Set(0)
	EndIf

	(cAliasCVD)->(dbGotop())

	While  (cAliasCVD)->(!Eof())
		If lObj
			nMeter++
			oMeter:Set(nMeter)
		EndIf

		lCusto := !Empty((cAliasCVD)->CVD_CUSTO )

		If lCusto
			aSaldoAnt	:= SaldoCT3Fil((cAliasCVD)->CVD_CONTA,(cAliasCVD)->CVD_CUSTO,dDataIni,cMoeda,cTpSald,'CTBXFUN',lImpAntLP,dDataLP,aSelFil)
			aSaldoAtu	:= SaldoCT3Fil((cAliasCVD)->CVD_CONTA,(cAliasCVD)->CVD_CUSTO,dDataFim,cMoeda,cTpSald,'CTBXFUN',lImpAntLP,dDataLP,aSelFil)
		Else
			aSaldoAnt	:= SaldoCT7Fil((cAliasCVD)->CVD_CONTA,dDataIni,cMoeda,cTpSald,'CTBXFUN',lImpAntLP,dDataLP,aSelFil)
			aSaldoAtu	:= SaldoCT7Fil((cAliasCVD)->CVD_CONTA,dDataFim,cMoeda,cTpSald,'CTBXFUN',lImpAntLP,dDataLP,aSelFil)
		EndIf

		nSaldoAntD	:= aSaldoAnt[7]
		nSaldoAntC	:= aSaldoAnt[8]
		nSldAnt		:= nSaldoAntC - nSaldoAntD
		nSaldoAtuD	:= aSaldoAtu[4]
		nSaldoAtuC	:= aSaldoAtu[5]
		nSldAtu		:= nSaldoAtuC - nSaldoAtuD
		nSaldoDeb	:= nSaldoAtuD - nSaldoAntD
		nSaldoCrd	:= nSaldoAtuC - nSaldoAntC

		// En caso de que se requiera presentar valores en 1000's u otro factor
		// ==> Consultar función CTBR049->CtSalPlanRef()

		If lVlrZerado .Or. (  aSaldoAnt[6] <> 0 .Or. aSaldoAtu[1] <> 0 )
			If (cArqTrab)->(MsSeek( (cAliasCVD)->CVD_CTAREF ) )
				RecLock(cArqTrab,.F.)
				(cArqTrab)->SALDOANT 	+= aSaldoAnt[6]							// Saldo anterior
				(cArqTrab)->SALDOATU 	+= aSaldoAtu[1]	   						// Saldo Atual
				(cArqTrab)->SALDODEB	+= nSaldoDeb								// Saldo Debito
				(cArqTrab)->SALDOCRD	+= nSaldoCrd								// Saldo Credito
				(cArqTrab)->MOVIMENTO	:= (cArqTrab)->(SALDOCRD-SALDODEB)			// Movimento
				(cArqTrab)->(MsUnlock())
			Else
				RecLock(cArqTrab,.T.)
				(cArqTrab)->CONTA		:= (cAliasCVD)->CVD_CTAREF
				(cArqTrab)->DESCCTA		:= GetAdvFval("CVN","CVN_DSCCTA",xFilial("CVN") + (cAliasCVD)->(CVD_CODPLA + CVD_CTAREF),2 )
				(cArqTrab)->SALDOANT 	:= aSaldoAnt[6]			   				// Saldo anterior
				(cArqTrab)->SALDOATU 	:= aSaldoAtu[1]	   		   				// Saldo Atual
				(cArqTrab)->SALDODEB	:= nSaldoDeb			   					// Saldo Debito
				(cArqTrab)->SALDOCRD	:= nSaldoCrd			   					// Saldo Credito
				(cArqTrab)->MOVIMENTO	:= (cArqTrab)->(SALDOCRD-SALDODEB)			// Movimento
				(cArqTrab)->CLASSE		:= (cAliasCVD)->CVD_CLASSE
				(cArqTrab)->SUPERIOR	:= (cAliasCVD)->CVD_CTASUP
				(cArqTrab)->(MsUnlock())
			EndIf
		EndIf
		(cAliasCVD)->(dbSkip())
	EndDo

EndIf

// En caso de requerir la funcionalidad descrita abajo
// ==> Consultar función CTBR049->CtSalPlanRef()
//-----------------------------------------
// Atualiza o saldo das Contas Sintéticas
// Somente serão impresso o saldo das contas
//   sinteticas, caso o parametros Imprime
//   Contas Zeradas esteja igual a SIM.
// Isso porque as contas sinteticas nao
//   possuem valores;
//-----------------------------------------

(cAliasCVD)->(dbCloseArea())
dbSelectArea("CVD")

Return

/*/{Protheus.doc} GrabaTxt
	Generación del archivo de texto
	@type    Static Function
	@author  ARodriguez
	@since   25/04/2022
	@version 1.0
	@param   oMeter, object, barra de status
	@param   oText, object, barra de status
	@param   oDlg, object, barra de status
	@param   lEnd, logical, control de cancelación del proceso
	@param   cDir, character, directorio
	@param   cArqTmp, character, archivo temporal
	@param   nAnio, numeric, año que presenta
	@param   nMonto, numeric, informar valores mayores a este valor
	@return  Nil
/*/
Static Function GrabaTxt(oMeter, oText, oDlg, lEnd, cDir, cArqTmp, nAnio, nMonto)
Local nHdl		:= 0
Local cArq		:= ""
Local cLin		:= ""
Local cSep		:= ";"
Local lObj		:= (oMeter <> Nil .And. !IsBlind())
Local nMeter	:= 0

If lObj
	oMeter:SetTotal((cArqTmp)->(RecCount()))
	oMeter:Set(0)
EndIf

(cArqTmp)->(dbGotop())

cDir := Substr(cDir,1,rat("\",cDir))	// limpia si hay algun nombre de archivo en la ruta

cArq := "DDI-000396_ART1"				// Fijo
cArq += "_" + AllTrim(SM0->M0_CGC)		// NIT
cArq += "_" + StrZero(nAnio,4)			// Año
cArq += ".csv"							// Extensión

nHdl := fCreate(cDir+cArq)

If nHdl <= 0
	ApMsgStop(STR0006)// "Ocurrió un error al crear el archivo csv."

Else
	Do While (cArqTmp)->(!Eof())
		If lObj
			nMeter++
			oMeter:Set(nMeter)
		EndIf

		If (cArqTmp)->SALDOATU > nMonto
			cLin := ""

			//01 - Año
			cLin += StrZero(nAnio,4)
			cLin += cSep

			//02 - Concepto
			cLin += Alltrim((cArqTmp)->CONTA)
			cLin += cSep

			//03 - Valor
			cLin += Alltrim(Str(Abs(Round((cArqTmp)->SALDOATU,0))))
			cLin += CRLF

			fWrite(nHdl,cLin)
		EndIf

		(cArqTmp)->(dbSkip())
	EndDo

	fClose(nHdl)

	If !lAutomato
		MsgAlert(Strtran(STR0007,"%TXT%",cArq))// "Archivo %TXT% generado con éxito."
	EndIf
EndIf

Return Nil
