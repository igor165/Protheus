#include "protheus.ch"
#include "Birtdataset.ch"
#include "FINR085P.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FINR085Pds1³ Autor ³ Jonathan Gonzalez     ³ Data ³ 26.05.14   ³±±
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
Dataset F085d1
	title STR0041 //"Orden Pago - DC-GP-CT-CE
	description STR0042 //"Orden de Pago - DC-GP-CT-CE"
	PERGUNTE "FINR085P"
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Se define las columnas del dataset dsVen.
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
columns
//DESCUENTOS
	define column DCDPROV TYPE CHARACTER  SIZE 6   LABEL STR0043 //"D.C Cod. Prov."
	define column TDALOJA LIKE EK_LOJA
	define column PRVLOJA LIKE A2_LOJA
If cPaisLoc == "ARG"
	define column DCORDEN TYPE CHARACTER  SIZE 12  LABEL STR0044 //"D.C Orden Pago"
else
	define column DCORDEN TYPE CHARACTER  SIZE  6  LABEL STR0044 //"D.C Orden Pago"
endif
	define column DCNUMRO TYPE CHARACTER  SIZE 30  LABEL STR0045 //"D.C Numero"
	define column DCVALOR TYPE CHARACTER  SIZE 15  LABEL STR0046 //"D.C Valor"
	define column DCMOEDA TYPE CHARACTER  SIZE 60  LABEL STR0047 //"D.C Moneda"
	define column DCEMISO TYPE CHARACTER  SIZE 60  LABEL STR0048 //"D.C Emision"
	define column DCVALEN TYPE CHARACTER  SIZE 60  LABEL STR0049 //"D.C Valor en"
	define column DCDESMD TYPE CHARACTER  SIZE 20  LABEL STR0050 //"D.C Desc. Mda"
	define column DCFLAG1 TYPE CHARACTER  SIZE 2   LABEL STR0051 //"D.C Bandera"

//Gatos de pago
	define column GPTIPOP TYPE CHARACTER  SIZE 80  LABEL STR0052 //"G.P Tip. Pag"
	define column GPVALOR TYPE CHARACTER  SIZE 15  LABEL STR0053 //"G.P Val. Pag"
	define column GPMOEDA TYPE CHARACTER  SIZE 60  LABEL STR0054 //"G.P Moneda"
	define column GPFLAG1 TYPE CHARACTER  SIZE 2   LABEL STR0055 //"G.P Bandera"

//cheques-transacciones-efectivo
	define column CTNUMRO TYPE CHARACTER  SIZE 25  LABEL STR0056 //"C.T Pre/Numero"
	define column CTVALOR TYPE CHARACTER  SIZE 15  LABEL STR0057 //"C.T valor"
	define column CTMOEDA TYPE CHARACTER  SIZE 5   LABEL STR0058 //"C.T Moneda"
	define column CTBANCO TYPE CHARACTER  SIZE 40  LABEL STR0059 //"C.T Banco"
	define column CTAGENC TYPE CHARACTER  SIZE 15  LABEL STR0060 //"C.T Agencia"
	define column CTCUENT TYPE CHARACTER  SIZE 30  LABEL STR0061 //"C.T Cuenta"
	define column CTVENCT TYPE CHARACTER  SIZE 10  LABEL STR0062 //"C.T Vencito"
	define column CTFLAG1 TYPE CHARACTER  SIZE 2   LABEL STR0063 //"C.T Bandera"

//cheques entregado
	define column CENUMRO TYPE CHARACTER  SIZE 25  LABEL STR0064 //"C.E Numero"
	define column CEVALOR TYPE CHARACTER  SIZE 15  LABEL STR0065 //"C.E valor"
	define column CEMOEDA TYPE CHARACTER  SIZE 5   LABEL STR0066 //"C.E Moneda"
	define column CEBANCO TYPE CHARACTER  SIZE 40  LABEL STR0067 //"C.E Banco"
	define column CEAGENC TYPE CHARACTER  SIZE 15  LABEL STR0068 //"C.E Agencia"
	define column CECUENT TYPE CHARACTER  SIZE 30  LABEL STR0069 //"C.E Cuenta"
	define column CEVENCT TYPE CHARACTER  SIZE 10  LABEL STR0070 //"C.E Vencito"
	define column CEFLAG1 TYPE CHARACTER  SIZE 2   LABEL STR0071 //"C.E Bandera"



//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Se define el query, para la obtencion de informacion del dataset
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
define query "SELECT  DCDPROV, TDALOJA, PRVLOJA, DCORDEN, DCNUMRO, DCVALOR, DCMOEDA, DCEMISO, "+;
                     "DCVALEN, DCDESMD, DCFLAG1, GPTIPOP, GPVALOR, GPMOEDA, GPFLAG1, CTNUMRO, "+;
                     "CTVALOR, CTMOEDA, CTBANCO, CTAGENC, CTCUENT, CTVENCT, CTFLAG1, CENUMRO, "+;
                     "CEVALOR, CEMOEDA, CEBANCO, CEAGENC, CECUENT, CEVENCT, CEFLAG1  " +;
                     "FROM %WTable:1% "

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
	//dbCloseArea()
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

If (cString)->(Eof())

	RecLock(cWTabAlias,.T.)
	MsUnlock( cWTabAlias )

EndIf

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
							EK_VLMOED1,EK_VENCTO})
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

	//DESCONTADOS LOS SIGUIENTES ANTICIPOS/CREDITOS
	If Len(aPaApl) > 0
		//Getmv("MV_MOEDAP1") //DESCRIPCION DE LA MONEDA
		For i := 1 to Len(aPaApl)

		RecLock(cWTabAlias,.T.)

			(cWTabAlias)->DCDPROV := RTRIM(SA2->A2_COD)
			(cWTabAlias)->DCORDEN := RTRIM(cOrdPago)
			(cWTabAlias)->TDALOJA := SEK->EK_LOJA
			(cWTabAlias)->PRVLOJA := SA2->A2_LOJA
			(cWTabAlias)->DCNUMRO := RTRIM(aPaApl[i][1])		       //NUMERO
			(cWTabAlias)->DCVALOR := ALLTRIM(Transform((aPaApl[i][2]* -1),"99,999,999.99")) //VALOR
			(cWTabAlias)->DCMOEDA := RTRIM(aPaApl[i][3])		       //MONEDA
			(cWTabAlias)->DCEMISO := RTRIM(DTOC(aPaApl[i][4]))      //EMISION
			(cWTabAlias)->DCVALEN := ALLTRIM(Transform((aPaApl[i][5]* -1),"99,999,999.99")) //VALOR EN (TIPO DE CAMBIO)
			(cWTabAlias)->DCDESMD := RTRIM(Getmv("MV_MOEDAP1"))
			(cWTabALias)->DCFLAG1 := "DC" //Bandera

			nTotal		-= aPaApl[i][2]
			nTotMd1	-= aPaApl[i][5]

		(cWTabAlias)->(MsUnLock())
		Next
	EndIf

	//GASTOS DE PAGO
	If len(aDesp) > 0
		For i:=1  to LEN(aDesp)
		RecLock(cWTabAlias,.T.)

			(cWTabAlias)->DCDPROV := RTRIM(SA2->A2_COD)
			(cWTabAlias)->DCORDEN := RTRIM(cOrdPago)
			(cWTabAlias)->TDALOJA := SEK->EK_LOJA
			(cWTabAlias)->PRVLOJA := SA2->A2_LOJA
			(cWTabAlias)->GPTIPOP := RTRIM(aDesp[i][1])      //TIPO DE PAGO
			(cWTabAlias)->GPVALOR := ALLTRIM(Transform(aDesp[i][2],"99,999,999.99")) //VALOR PAGADO
			(cWTabAlias)->GPMOEDA := RTRIM(aDesp[i][3])      //MONEDA
			(cWTabAlias)->GPFLAG1 := "GP" //Bandera

		(cWTabAlias)->(MsUnLock())
		Next
	Endif

	//CHEQUES - EFECTIVO - TRANFERENCIAS
	If len(aChqPr) > 0
		For i:=1  to LEN(aChqPr)
		RecLock(cWTabAlias,.T.)

			(cWTabAlias)->DCDPROV := RTRIM(SA2->A2_COD)
			(cWTabAlias)->DCORDEN := RTRIM(cOrdPago)
			(cWTabAlias)->TDALOJA := SEK->EK_LOJA
			(cWTabAlias)->PRVLOJA := SA2->A2_LOJA
			(cWTabAlias)->CTNUMRO := RTRIM(aChqPr[i][1]) +" - "+ RTRIM(aChqPr[i][2]) //PRE/NUMERO char 6
			(cWTabAlias)->CTVALOR := ALLTRIM(Transform(aChqPr[i][3],"99,999,999.99"))//VALOR char 15
			(cWTabAlias)->CTMOEDA := RTRIM(aChqPr[i][4])        //MONEDA char 5
			(cWTabAlias)->CTBANCO := ALLTRIM(POSICIONE("SA6",1,XFILIAL("SA6") + ALLTRIM(aChqPr[i][5]) + ALLTRIM(aChqPr[i][6]) + ALLTRIM(aChqPr[i][7]),"A6_NOME"))//BANCO
			(cWTabAlias)->CTAGENC := RTRIM(aChqPr[i][6])        //AGENCIA char 10
			(cWTabAlias)->CTCUENT := RTRIM(aChqPr[i][7])        //CUENTA char 15
			(cWTabAlias)->CTVENCT := RTRIM(DTOC(aChqPr[i][8]))  //VENCIMIENTO date
			(cWTabAlias)->CTFLAG1 := "CT" //Bandera

		(cWTabAlias)->(MsUnLock())
		Next
	Endif

	//CHEQUES DE TERCEROS ENTREGADOS
	If len(aChqTer) > 0
		For i:=1  to LEN(aChqTer)
		RecLock(cWTabAlias,.T.)

			(cWTabAlias)->DCDPROV := RTRIM(SA2->A2_COD)
			(cWTabAlias)->DCORDEN := RTRIM(cOrdPago)
			(cWTabAlias)->TDALOJA := SEK->EK_LOJA
			(cWTabAlias)->PRVLOJA := SA2->A2_LOJA
			(cWTabAlias)->CENUMRO := RTRIM(aChqTer[i][1])        //PRE/NUMERO
			(cWTabAlias)->CEVALOR := ALLTRIM(Transform(aChqTer[i][2],"99,999,999.99"))//VALOR
			(cWTabAlias)->CEMOEDA := ALLTRIM(STR(aChqTer[i][3])) //MONEDA
			(cWTabAlias)->CEBANCO := POSICIONE("SA6",1,XFILIAL("SA6") + ALLTRIM(aChqTer[i][4]) + ALLTRIM(aChqTer[i][5]) + ALLTRIM(aChqTer[i][6]),"A6_NOME")//BANCO
			(cWTabAlias)->CEAGENC := RTRIM(aChqTer[i][5])        //AGENCIA
			(cWTabAlias)->CECUENT := RTRIM(aChqTer[i][6])        //CUENTA
			(cWTabAlias)->CEVENCT := RTRIM(DTOC(aChqTer[i][6]))  //Vencimiento
			(cTWabAlias)->CEFLAG1 := "CE" //Bandera

		(cWTabAlias)->(MsUnLock())
		Next
	Endif

	dbSelectArea(cString)
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indice ou consulta(Query)                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cString)
dbCloseArea()

MS_FLUSH()

return .T.