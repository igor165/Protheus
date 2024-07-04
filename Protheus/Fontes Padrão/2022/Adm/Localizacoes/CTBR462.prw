#INCLUDE "CTBR462.ch"
#Include "PROTHEUS.Ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBR462  ³ Autor ³Roberto Rogério Mezzalira ³ Data ³ 24.12.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 1- "PROVEEDORES (CUENTA 42)"                                  ³±±
±±³          ³ 2- "CUENTAS POR PAGAR DIVERSAS (CUENTA 46)"                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBR462(nOpca)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Generico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpca 4- Demonstrativo - Contas de Proveedores (CUENTA 42)    ³±±
±±³          ³ nOpca 5- Demonstrativo - Contas diversas por pagar (CUENTA 46) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctbr462(nOpca,cCta)
Local CREPORT	:= ""
Local CTITULO	:= ""
Local CDESC		:= ""
Local cPerg		:= "CTR461"
Local cPicture	:= ""
Local aCtbMoeda	:= {}
Local lRet		:= .T.

Private aSelFil		:= {}
Private oReport
Private cConta1		:= ""
Private cConta2		:= ""
Private aFieldSM0	:= {"M0_CGC"}
Private aDatosEmp	:= IIf (cVersao <> "11" ,FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, aFieldSM0),"")
Private cRUC		:= Trim(IIf (cVersao <> "11" ,aDatosEmp[1][2],SM0->M0_CGC))

If Empty(cCta)
	MsgAlert(STR0020, STR0001)	// "Acceso indebido."##"Libro de inventario y balances"
	Return .F.
EndIf

cConta1 := cCta
cConta2 := cConta1 + "zzz"

If CT1->(DbSeek(xFilial("CT1") + cConta1))
	CTITULO := STR0001 //"Libro de inventario y balances"
	CDESC := STR0002 + " " + cConta1 + " " + Lower(Alltrim(CT1->CT1_DESC01)) //"Detalles del saldo de la cuenta"
	CREPORT := STR0001 //"Libro de inventario y balances"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variables utilizadas en los parametros                       ³
//³ mv_par01  	      	   Fecha Inicial                         ³
//³ mv_par02               Fecha Final                           ³
//³ mv_par03               Moenda?                               ³
//³ mv_par04               Selecciona Filial?					 ³
//³ mv_par05               Generar archivo? 					 ³
//³ mv_par06               Directorio?							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !Pergunte( cPerg , .T. )
	lRet := .F.
EndIf

IF lRet
 	aCtbMoeda	:= CtbMoeda(mv_par03)
 	If Empty(aCtbMoeda[1])
 		Help(" ",1,"NOMOEDA")
 		lRet := .F.
 	EndIf
Endif

If lRet .And. mv_par04 == 1 .And. Len( aSelFil ) <= 0 //SELECIONA FILIALES
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		lRet := .F.
	EndIf
Else
	aSelFil := {cFilAnt}
EndIf

If !lRet
	Set Filter To
	Return
EndIf

cPicture := Ctb461Pic(aCtbMoeda[5])
aRelatorio := {{.06,.38,.21,.22,.21,.19,.19},{},{},{},{}}	//tamanho das celulas,detalhe,total,cabec1,cabec2

/* Linha de detalhe */
Aadd(aRelatorio[2],Nil)
Aadd(aRelatorio[2],{"CODIGO",,"LEFT",,"14"})
Aadd(aRelatorio[2],{"DENOM",,"LEFT",,"14"})
Aadd(aRelatorio[2],{"ENTID",,"CENTER",,"14"})
Aadd(aRelatorio[2],{"CONTA",,"LEFT",,"14"})
Aadd(aRelatorio[2],{"MOEDA",,"CENTER",,"14"})
Aadd(aRelatorio[2],{"DEBITO",cPicture,"CENTER",,"134"})
Aadd(aRelatorio[2],{"CREDITO",cPicture,"CENTER",,"34"})
/* Linha de total */
Aadd(aRelatorio[3],Nil)
Aadd(aRelatorio[3],{"TOTFIL1",,"CENTER",,""})
Aadd(aRelatorio[3],{"TOTFIL2",,"CENTER",,""})
Aadd(aRelatorio[3],{"TOTFIL3",,"CENTER",,""})
Aadd(aRelatorio[3],{"TOTFIL4",,"RIGHT",{|| ""},""})
Aadd(aRelatorio[3],{"TOTFIL5",,"CENTER",{|| STR0003},""}) //"Totales"
Aadd(aRelatorio[3],{"TOTDB",cPicture,"CENTER",,"134"})
Aadd(aRelatorio[3],{"TOTCR",cPicture,"CENTER",,"34"})
/* Linha de cabecalho 1 */
Aadd(aRelatorio[4],Nil)
Aadd(aRelatorio[4],{"CABFIL1",,"CENTER",,"124"})
Aadd(aRelatorio[4],{"CABFIL2","","CENTER",{|| STR0004},"24"}) //"Cuenta"
Aadd(aRelatorio[4],{"CABFIL3",,"CENTER",,"124"})
Aadd(aRelatorio[4],{"CABCTA",,"LEFT",{|| STR0005},"24"}) //"Referencia"
Aadd(aRelatorio[4],{"CABFIL4",,"CENTER",,"24"})
Aadd(aRelatorio[4],{"CABVLR1",,"RIGHT",{|| STR0006},"124"}) //"Saldo"
Aadd(aRelatorio[4],{"CABVLR2",,"LEFT",,"234"})
/* Cabecalho 2 */
Aadd(aRelatorio[5],Nil)
Aadd(aRelatorio[5],{"CABTIPO",,"CENTER",{|| STR0007},"14"}) //"Código"
Aadd(aRelatorio[5],{"CABNUM",,"CENTER",{|| STR0008},"14"}) //"Denominación"
Aadd(aRelatorio[5],{"CABNOM",,"CENTER",{|| STR0009},"14"}) //"Entidad"
Aadd(aRelatorio[5],{"CABDOC",,"CENTER",{|| STR0004 },"14"})	//"Cuenta"
Aadd(aRelatorio[5],{"CABDAT",,"CENTER",{|| STR0010},"14"}) //"Moneda"
Aadd(aRelatorio[5],{"CABVAL1",,"CENTER",{|| STR0011},"134"}) //"Deudor"
Aadd(aRelatorio[5],{"CABVAL2",,"CENTER",{|| STR0012},"34"}) //"Acreedor"

oReport := CTB461Def(CREPORT,CTITULO,cPerg,CDESC)
oReport:SetAction({|oReport| ReportPrint(oReport)})

IF Valtype( oReport ) == 'O'
	If !Empty( oReport:uParam )
		Pergunte( oReport:uParam, .F. )
	EndIf
	oReport:PrintDialog()
Endif

oReport := Nil

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³ Roberto Rogério Mezzalira ³ Data ³ 30/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime o relatorio definido pelo usuario de acordo com as       ³±±
±±³          ³secoes/celulas criadas na funcao ReportDef definida acima.       ³±±
±±³          ³Nesta funcao deve ser criada a query das secoes se SQL ou        ³±±
±±³          ³definido o relacionamento e filtros das tabelas em CodeBase.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportPrint(oReport)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³EXPO1: Objeto do relatório                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport)
Local oSection1		:= oReport:Section(1)
Local nPos			:= 0
Local nToDiaD		:= 0
Local nToMesC		:= 0
Local nToMesD		:= 0
Local nK			:= 0
Local nSaldoDb		:= 0
Local nSaldoCr		:= 0
Local cFilOld		:= cFilAnt
Local aArea			:= GetArea()
Local aAreaSA6		:= SA6->(GetArea())
Local aAreaSM0		:= SM0->(GetArea())
Local aCtas10		:= {}
Local titulo		:= ""

SA6->(DbSetOrder(3))
CTB461Dim(oReport)

For nK := 1 to Len(aSelFil)
	cFilAnt := aSelFil[nK]
	SM0->(DbSeek(cEmpAnt+cFilAnt))
	nToDiaD		:= 0
	nToMesC		:= 0
	nToMesD		:= 0

	If CT1->(DbSeek(xFilial("CT1") + cConta1))
		titulo := STR0002 + " " + cConta1 + " " + Lower(Alltrim(CT1->CT1_DESC01)) // Detalles del Saldo de la Cuenta
	Endif

	oReport:SetCustomText( {|| CTB461CabL(oReport,titulo,MV_PAR01,MV_PAR02,(MV_PAR04 == 1))} )
	cAliasqry := GetNextAlias()

	IF Select( cAliasqry ) > 0
		dbSelectArea( cAliasqry )
		dbCloseArea()
	EndIf

	BeginSql alias cAliasqry
			SELECT CT2_MOEDLC,CT2_DEBITO,CT2_CREDIT,CT2_VALOR,CT2_EC05DB,CT2_EC05CR
			FROM %table:CT2% CT2
			WHERE CT2.%notDel% AND
			CT2_FILIAL = (%exp:XFILIAL('CT2')%) AND
			CT2_TPSALD = '1' AND
			CT2_MOEDLC = (%exp:MV_PAR03%) AND
			(substring(CT2_DEBITO,1,2) = '10' OR substring(CT2_CREDIT,1,2) = '10') AND
			CT2_DATA BETWEEN (%exp:MV_PAR01%) AND (%exp:MV_PAR02%)
   	EndSql

	DBGOTOP()
	DBSelectArea(cAliasqry)
	oREPORT:SETMETER(RECCOUNT())
	aCtas10  := {}

	DO WHILE (cAliasqry)->(!Eof())

		IF oREPORT:CANCEL()
			EXIT
			aCtas10 := {}
		ENDIF

		If Substr((cAliasqry)->CT2_DEBITO,1,2) == '10'
			nPos := Ascan(aCtas10,{|cta| cta[1] == (cAliasqry)->CT2_DEBITO .And. cta[2] == (cAliasqry)->CT2_EC05DB})
			If nPos == 0
				Aadd(aCtas10,{(cAliasqry)->CT2_DEBITO,(cAliasqry)->CT2_EC05DB,(cAliasqry)->CT2_EC05CR,0,0,"","","",""})
				nPos := Len(aCtas10)
				CT1->(DbSeek(xFilial("CT1") + (cAliasqry)->CT2_DEBITO))
				aCtas10[nPos,7] := Lower(Alltrim(CT1->CT1_DESC01))
				If !Empty((cAliasqry)->CT2_EC05DB)
					SA6->(DbSeek(xFilial("SA6")))
					ACHOU:= .F.
					While SA6->(!Eof()) .And. !ACHOU
						If (xfilial("SA6")+(cAliasqry)->CT2_EC05DB) == (SA6->A6_FILIAL)+(SA6->A6_EC05DB)
							aCtas10[nPos,6] := If(SA6->A6_MOEDA > 0,StrZero(SA6->A6_MOEDA,2),"01")
							aCtas10[nPos,8] := SA6->A6_CLASENT
							aCtas10[nPos,9] := SA6->A6_NUMCON
							ACHOU := .T.
						EndIf
						SA6->(DBSKIP())
	                EndDo
				Endif
			Endif
			aCtas10[nPos,4] += (cAliasqry)->CT2_VALOR
		Endif

		If Substr((cAliasqry)->CT2_CREDIT,1,2) == '10'
			nPos := Ascan(aCtas10,{|cta| cta[1] == (cAliasqry)->CT2_CREDIT .And. cta[3] == (cAliasqry)->CT2_EC05CR})
			If nPos == 0
				Aadd(aCtas10,{(cAliasqry)->CT2_CREDIT,(cAliasqry)->CT2_EC05DB,(cAliasqry)->CT2_EC05CR,0,0,"","","",""})
				nPos := Len(aCtas10)
				CT1->(DbSeek(xFilial("CT1") + (cAliasqry)->CT2_CREDIT))
				aCtas10[nPos,7] := Lower(Alltrim(CT1->CT1_DESC01))
				If !Empty((cAliasqry)->CT2_EC05CR)
					SA6->(DbSeek(xFilial("SA6")))
					ACHOU:= .F.
					While SA6->(!Eof()) .And. !ACHOU
						If (xfilial("SA6")+(cAliasqry)->CT2_EC05CR) == (SA6->A6_FILIAL)+(SA6->A6_EC05CR)
							aCtas10[nPos,6] := If(SA6->A6_MOEDA > 0,StrZero(SA6->A6_MOEDA,2),"01")
							aCtas10[nPos,8] := SA6->A6_CLASENT
							aCtas10[nPos,9] := SA6->A6_NUMCON
							ACHOU := .T.
						EndIf
						SA6->(DBSKIP())
	                EndDo
				Endif
			Endif
			aCtas10[nPos,5] += (cAliasqry)->CT2_VALOR
		Endif

		DBSELECTAREA(cAliasqry)
		DBSKIP()
		oREPORT:INCMETER()

	ENDDO

	oREPORT:SETMETER(Len(aCtas10))
	nSaldoDb := 0
	nSaldoCr := 0
	nPos := 0

	DO WHILE nPos < Len(aCtas10)

		nPos++
		IF oREPORT:CANCEL()
			EXIT
		ENDIF

		oSECTION1:INIT()
		oSection1:Cell("CODIGO"  ):SetBlock( { || aCtas10[nPos,1]} )
		oSection1:Cell("DENOM"   ):SetBlock( { || aCtas10[nPos,7]} )
		oSection1:Cell("ENTID"   ):SetBlock( { || aCtas10[nPos,8]} )
		oSection1:Cell("CONTA"   ):SetBlock( { || aCtas10[nPos,9]} )
		oSection1:Cell("MOEDA"   ):SetBlock( { || aCtas10[nPos,6]} )
		oSection1:Cell("DEBITO"  ):SetBlock( { || aCtas10[nPos,4]} )
		oSection1:Cell("CREDITO" ):SetBlock( { || aCtas10[nPos,5]} )
		oSECTION1:PRINTLINE()

		nSaldoDb += aCtas10[nPos,4]
		nSaldoCr += aCtas10[nPos,5]

		oREPORT:INCMETER()

	ENDDO

	CTB461Tot({{"TOTDB",nSaldoDb},{"TOTCR",nSaldoCr}})
	oReport:EndPage()
	oReport:SetPageNumber(1)

Next nK

If MV_PAR05 == 2
	Processa({|| GerArq(AllTrim(MV_PAR06),aCtas10)},,STR0017) // Archivo generado con éxito
EndIf

cFilAnt := cFilOld
RestArea(aAreaSM0)
RestArea(aAreaSA6)
RestArea(aArea)
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ GerArq   ³ Autor ³                     ³ Data ³ 03.05.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ 3.2 LIBRO DE INVENTARIOS Y BALANCES       .                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cDir - Diretorio de criacao do arquivo.                    ³±±
±±³            ³ cArq - Nome do arquivo com extensao do arquivo.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Peru                  - Arquivo Magnetico           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GerArq(cDir,aCtas10)

Local nHdl    := 0
Local cLin    := ""
Local cSep    := "|"
Local nCont   := 0
Local cArq    := ""
Local nPos    := 0
Local cMoneda := ""
Local nMes	  :=  Month (MV_PAR02)
Local nSaldo  := 0

FOR nCont:=LEN(ALLTRIM(cDir)) TO 1 STEP -1
	IF SUBSTR(cDir,nCont,1)=='\'
		cDir:=Substr(cDir,1,nCont)
		EXIT
	ENDIF
NEXT

cArq += "LE"                                  // Fijo  'LE'
cArq +=  cRUC        					      // Ruc
cArq +=  DTOS(MV_PAR02)       				  // Fecha
cArq += "030200"                              // Fijo '030200' CONTA10
//Código de Oportunidad
If nMes == 12
	cArq += "01"
ElseIf nMes == 1
	cArq += "02"
ElseIf nMes == 6
	cArq += "04"
Else
	cArq += "07"
EndIf
cArq += "1"
cArq += "1"
cArq += "1"
cArq += "1"
cArq += ".TXT" // Extensión

nHdl := fCreate(cDir+cArq)

If nHdl <= 0

	ApMsgStop(STR0018)//Ocurrió un error al generar el archivo Txt.

Else

	DO WHILE nPos < Len(aCtas10)
		nPos++
		cLin := ""

		//01 - Periodo
		cLin += SubStr(DTOS(mv_par02),1,8)
		cLin += cSep

		//02 - Código de la cuenta contable desagregado en subcuentas al nivel máximo de dígitos utilizado, según la estructura 5.3
		cLin += AllTrim(aCtas10[nPos,1])
		cLin += cSep

		//03 - Código de la Entidad financiera a la que corresponde la cuenta TABLA 3
		If Empty(AllTrim(aCtas10[nPos,8]))
			cLin += "99"
		Else
			cLin += AllTrim(aCtas10[nPos,8])
		EndIf
		cLin += cSep

		//04 - Número de la cuenta de la Entidad Financiera
		If Empty(AllTrim(aCtas10[nPos,8]))
			cLin += "-"
		Else
			cLin += AllTrim(aCtas10[nPos,9])
		EndIf
		cLin += cSep

		//05 - Tipo de moneda correspondiente a la cuenta  - TABLA 4 SUNAT
	    If cMoneda ==""
		    SYF->(DbSetOrder(1))
		    If SYF->(Dbseek(xFilial("SYF")+(GetMV("MV_SIMB"+AllTrim(STR(VAL(CT2->CT2_MOEDLC))))))) .And. !Empty(AllTrim(SYF->YF_ISO))
		    	cMoneda := AllTrim(SYF->YF_ISO)
		    	cLin += cMoneda
			EndIf
		Else
			cLin += cMoneda
		EndIf
		cLin += cSep

		//06 - Saldo deudor de la cuenta
		nSaldo := Val(STR(aCtas10[nPos,4])) - Val(STR(aCtas10[nPos,5]))
		If nSaldo >= 0
			cLin +=	AllTrim(StrTran(Transform(nSaldo,"@E 999999999.99"),",","."))
		Else
			cLin += "0.00"
		EndIf
		cLin += cSep

		//07 - Saldo acreedor de la cuenta
		If nSaldo < 0
			cLin += AllTrim(StrTran(Transform(ABS(nSaldo),"@E 999999999.99"),",","."))
		Else
			cLin += "0.00"
		EndIf
		cLin += cSep

		//08 - Indica el estado de la operación
		cLin += "1"
		cLin += cSep

		cLin += chr(13)+chr(10)
		fWrite(nHdl,cLin)
	EndDo

	fClose(nHdl)
	MsgAlert(STR0017,"") // Archivo generado con éxito

EndIf

Return Nil
