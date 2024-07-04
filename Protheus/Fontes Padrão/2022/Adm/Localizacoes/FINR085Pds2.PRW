#include "protheus.ch"
#include "Birtdataset.ch"
#INCLUDE "FINR085P.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FINR085Pds2³ Autor ³ Jonathan Gonzalez     ³ Data ³ 26.05.14   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza la definicion del datase que sera utiliza para        ³±±
±±³          ³ contener los datos obtenidos apartir de los parametros        ³±±
±±³          ³ proporcionados en por el usario.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ (void)                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINR085P                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³      ³                                           ³±±
±±³            ³          ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
dataset F085d2
	title STR0072 //"Orden de Pago - Secundario y Retenciones"
	description STR0073 //"Orden de Pago BIRT - Secundario y Retenciones"
	PERGUNTE "FINR085P"
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Se define las columnas del dataset dsVen.
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
columns
If cPaisLoc == "ARG"
	define column CPORDEN TYPE CHARACTER  SIZE 12 LABEL STR0074 //"C.P. Orden"
else
	define column CPORDEN TYPE CHARACTER  SIZE 6  LABEL STR0074 //"C.P. Orden"
EndIf
	define column CPPROVD TYPE CHARACTER  SIZE 6  LABEL STR0075 //"C.P. Cod. Prov."
	define column TDALOJA LIKE EK_LOJA
	define column PRVLOJA LIKE A2_LOJA
	define column CRTIPNR TYPE CHARACTER  SIZE 80 LABEL STR0076 //"C.P. Tip.Cert/Nro"
	define column CRMONTO TYPE CHARACTER  SIZE 15 LABEL STR0077 //"C.P. Cert Monto"
	define column CRFLAG1 TYPE CHARACTER  SIZE 2  LABEL STR0078 //"C.P. Bandera"
//pagos anticipados
	define column PANUMRO TYPE CHARACTER  SIZE 30 LABEL STR0079 //"P.A. Numero"
	define column PAVALPG TYPE CHARACTER  SIZE 15 LABEL STR0080 //"P.A. Val. Pag."
	define column PAMOEDA TYPE CHARACTER  SIZE 5  LABEL STR0081 //"P.A. Moneda"
	define column PAFLAG1 TYPE CHARACTER  SIZE 2  LABEL STR0082 //"P.A. Bandera"



//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Se define el query, para la obtencion de informacion del dataset
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
define query "SELECT CPORDEN, CPPROVD, CRTIPNR, CRMONTO, CRFLAG1, PANUMRO, PAVALPG, PAMOEDA, "+;
                    "PAFLAG1, TDALOJA, PRVLOJA  "+;
             "FROM   %WTable:1%  "

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Se inicia la rutina de llenado del dataset
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
process dataset
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cWTabAlias
Local cString		:= "SEK"
Local cPerg 	 	:= "FINR085P"
Local cChave		:= ""
Local lAgregSEK	:= .F.
Local cTcMoeda	:= ""
Local nTxMoeda	:= 0
Local cTipoRet	:= ""
Local lCBU			:= .F.
Local lCancelado	:= .F.
Local lRastroCTB	:= AllTrim(ProcName(1)) == "CTBORDPAGO"
Local cFornece , cLoja	, cOrdPago	, dDtBaixa	, nBaixa	 , nTotal	, cTipoOp
Local aPaApl	 , aNFs	, aChqPr	, aChqTer	, aPaGer	 , aRets	,aDesp
Local cQuery	 , aStru	, nLoop	, cFiltro	, cIndice	 , nIndex
Local nBaixaMd1, nTotMd1	, i			, aTasas	, nValorMd1
Local aSX3Box

Private dDateIni	:= self:execParamValue("MV_PAR01")
Private dDateFin	:= self:execParamValue("MV_PAR02")
Private cOrdIni	:= self:execParamValue("MV_PAR03")
Private cOrdFin	:= self:execParamValue("MV_PAR04")
Private cForIni	:= self:execParamValue("MV_PAR05")
Private cForFin	:= self:execParamValue("MV_PAR06")

if ::isPreview()
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preparacao do arquivo de trabalho                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cString)
dbSetOrder(3)

lAgregSEK	:= .T.

If lRastroCTB .And. !Empty(CTL->CTL_KEY)
	dbSetOrder(1)
	dbSeek(CV3->CV3_KEY)
	cChave    := &(CTL->CTL_KEY)
	dDateIni  := CV3->CV3_DTSEQ
	dDateFin  := CV3->CV3_DTSEQ
	cOrdIni   := Substr(cChave,3,TamSX3("EK_ORDPAGO")[1])
	cOrdFin   := Substr(cChave,3,TamSX3("EK_ORDPAGO")[1])
	cForIni   := ""
	cForFin   := "ZZZZZZ"
EndIf

dbSelectArea("SEK")

cString     := getNextAlias()

	aStru := SEK->(dbStruct())

	dbSelectArea("SA2") //Este comando eh necessario. Nao apague!!!!

	cQuery := "SELECT * FROM " + RetSQLname("SEK")
	cQuery += " WHERE D_E_L_E_T_ <> '*'"
	cQuery += " AND EK_FILIAL  = '"  + xFilial("SEK") + "'"
	cQuery += " AND EK_DTDIGIT BETWEEN '" + DTOS(dDateIni) + "' AND '" + DTOS(dDateFin) + "'"
	cQuery += " AND EK_ORDPAGO BETWEEN '" + cOrdIni + "' AND '" + cOrdFin + "'"
	If !lAgregSEK
		cQuery += " AND EK_FORNECE BETWEEN '" + cForIni + "' AND '" + cForFin + "'"
	EndIf
	If !lRastroCTB
	   cQuery += " AND EK_CANCEL <> 'T'"
	EndIf
	cQuery += " ORDER BY EK_FILIAL, EK_ORDPAGO "
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cString, .F., .T.)

	For nLoop := 1 to Len(aStru)
		If aStru[nLoop,2] <> "C"
			TCSetField(cString, aStru[nLoop,1], aStru[nLoop,2],;
			aStru[nLoop,3], aStru[nLoop,4])
		Endif
	Next

	dbSelectArea(cString)

If cPaisLoc == "PTG"
	aSx3Box 	:= RetSx3Box( Posicione("SX3", 2, "EK_TPDESP", "X3CBox()" ),,, 1 )
Endif

dbGotop()

cWTabAlias := ::createWorkTable()
chkFile(cString)

While (cString)->(!Eof())

	dbSelectArea(cString)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento de OP agrupada por Fornecedor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAgregSEK .And. !Empty(EK_FORNEPG)
		If EK_FORNEPG < cForIni .or. EK_FORNEPG > cForFin
			DbSkip()
			Loop
		EndIf
		cFornece	:= EK_FORNEPG
		cLoja		:= EK_LOJAPG
	Else
		cFornece	:= EK_FORNECE
		cLoja		:= EK_LOJA
	EndIf

	cOrdPago	:= EK_ORDPAGO
	dDtBaixa	:= EK_DTDIGIT
	cTipoOp	:= EK_TIPO
	aPaApl		:= {}
	aNFs		:= {}
	aChqPr		:= {}
	aChqTer	:= {}
	aPaGer		:= {}
	aDesp		:= {}
	aRets		:= {}
	nTotal		:= 0.00
	nTotMd1	:= 0.00

    lCancelado  := lRastroCTB .And. EK_CANCEL

    If (cString)->(FieldPos("EK_PGCBU")) > 0
    	lCBU := (cString)->EK_PGCBU
    Endif

    DbSelectArea(cString)

	While !Eof() .and. EK_ORDPAGO == cOrdPago
		If EK_TIPODOC == "TB"
			If EK_TIPO $ MVPAGANT + "/" + MV_CPNEG
				Aadd(aPaApl,{EK_NUM,EK_VALOR,EK_MOEDA,EK_EMISSAO,EK_VLMOED1})
			Else
				nBaixa		:= EK_VALOR
				nTotal		+= nBaixa
				If EK_MOEDA == "1"
					nBaixaMd1 := nBaixa
				Else
					cTcMoeda  := "EK_TXMOE0" + EK_MOEDA
					nTxMoeda  := IIf(FieldPos(cTcMoeda) > 0, &cTcMoeda, 0)
					nBaixaMd1 := Round(xMoeda(nBaixa, Val(EK_MOEDA), 1, dDtBaixa, 5, nTxMoeda), MsDecimais(1))
				Endif
				nTotMd1		+= nBaixaMd1
				cPref:= EK_PREFIXO

				If cPaisLoc=="PER" .And. SEK->(FieldPos("EK_SERORI")>0) .And.  !Empty(EK_SERORI)
			   		cPref:= SerieNfId(cString,2,'EK_SERORI')	// EK_SERORI
				EndIf
				Aadd(aNfs,{cPref,EK_NUM,EK_PARCELA,nBaixa,EK_MOEDA,EK_VENCTO,nBaixaMd1,(cString)->(FieldPos('EK_CANPARC')) > 0 .And.!Empty((cString)->EK_CANPARC)})
			Endif
		ElseIf EK_TIPODOC == "CP"
			Aadd(aChqPr  ,{EK_TIPO,EK_NUM,EK_VALOR,EK_MOEDA,EK_BANCO,EK_AGENCIA,EK_CONTA,EK_VENCTO})
		ElseIf EK_TIPODOC == "CT"
			Aadd(aChqTer ,{EK_NUM,EK_VALOR,EK_MOEDA,EK_BANCO,EK_AGENCIA,EK_CONTA,EK_ENTRCLI,EK_LOJCLI,;
							EK_VLMOED1})
		ElseIf EK_TIPODOC == "PA"
			nBaixa		:= EK_VALOR
			nBaixaMd1	:= IIf(EK_MOEDA=="1",nBaixa,xMoeda(nBaixa,Val(EK_MOEDA),1,dDtBaixa))
			nTotMd1		-= nBaixaMd1
			Aadd(aPaGer  ,{EK_NUM,EK_VALOR,EK_MOEDA})
		ElseIf EK_TIPODOC == "DE"
			If (nPosDesp	:=	Ascan(aSX3BOX,{|x| x[2]== EK_TPDESP})) >0
				Aadd(aDesp   ,{aSX3Box[nPosDesp,3],EK_VALOR,EK_MOEDA})
			Else
				Aadd(aDesp   ,{"Gasto",EK_VALOR,EK_MOEDA})
			Endif
		EndIf
		DbSelectArea(cString)
		DbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acumular retencoes                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc != "CHI"
	   dbSelectArea("SFE")
	   dbSetOrder(2)
	   dbSeek(xFilial("SFE")+cOrdPago)
	   While !Eof() .And. FE_ORDPAGO == cOrdPago
		  If FE_RETENC <> 0
			 nPosRet  := Ascan(aRets,{|X| X[1]+X[3]==FE_NROCERT+FE_TIPO})
			 If nPosRet ==  0
				Aadd(aRets,{FE_NROCERT,FE_RETENC,FE_TIPO})
			 Else
				aRets[nPosRet][2]:=aRets[nPosRet][2]+FE_RETENC
			 EndIf
		  EndIf
		  dbSkip()
	   EndDo
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona fornecedor                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(xFilial("SA2") + cFornece + cLoja )

	//CERTIFICADOS DE RETENCIONES
	If Len(aPaGer) > 0
		If Len(aRets) > 0
			For i:= 1 to Len(aRets)
			    If aRets[i][2] > 0
					If cPaisLoc == "ARG"
						cTipoRet:=IIf(aRets[i][3]=="G",OemToAnsi(STR0032),Iif(aRets[i][3]=="B",OemToAnsi(STR0033),Iif(aRets[i][3]=="S",OemToAnsi(STR0034),OemToAnsi(STR0035)))) //"GANANCIAS" //"ING. BR." //"S.U.S.S." //"I.V.A."
					ElseIf cPaisLoc == "URU"
						cTipoRet:=OemToAnsi(STR0036) //I.R.I.C
					ElseIf cPaisLoc == "ANG"
						cTipoRet:=OemToAnsi(STR0038) //R.I.E
					EndIf
				RecLock(cWTabAlias,.T.)
					(cWTabALias)->CPORDEN := RTRIM(cOrdPago)
					(cWTabAlias)->CPPROVD := RTRIM(SA2->A2_COD)
					(cWTabAlias)->TDALOJA := SEK->EK_LOJA
					(cWTabAlias)->PRVLOJA := SA2->A2_LOJA
					(cWTabAlias)->CRTIPNR := STR0040 +cTipoRet+ "NR " + aRets[i][1] //emitido certificado de //TIPO DE CERTIFICADO Y NUMERO
					(cWTabAlias)->CRMONTO := ALLTRIM(Transform((aRets[i][2] * - 1 ),"99,999,999.99"))//MONTO DEL CERTIFICADO
					(cWTabALias)->CRFLAG1 := "CR"

				(cWTabAlias)->(MsUnLock())
				ENDIF
			Next
		EndIf

		//POR VERBA DE PAGAMENTO ANTECIPADO DE TITULOS
		For i := 1 To Len(aPaGer)
		RecLock(cWTabAlias,.T.)

			(cWTabALias)->CPORDEN := RTRIM(cOrdPago)
			(cWTabAlias)->CPPROVD := RTRIM(SA2->A2_COD)
			(cWTabAlias)->TDALOJA := SEK->EK_LOJA
			(cWTabAlias)->PRVLOJA := SA2->A2_LOJA
			(cWTabAlias)->PANUMRO := RTRIM(aPaGer[i][1]) // NUMERO
			(cWTabAlias)->PAVALPG := ALLTRIM(Transform(aPaGer[i][2],"99,999,999.99")) // VALOR PAGO
			(cWTabAlias)->PAMOEDA := RTRIM(aPaGer[i][3]) // MONEDA
			(cWTabAlias)->PAFLAG1 := "PA"

		(cWTabAlias)->(MsUnLock())
		Next
	EndIf

	dbSelectArea(cString)
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indice ou consulta(Query)                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cString)
dbCloseArea()

MS_FLUSH()

return  .T.