#include "protheus.ch"
#include "Birtdataset.ch"
#INCLUDE "FINR085P.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FINR085ds ³ Autor ³ Jonathan Gonzalez     ³ Data ³ 26.05.14   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza la definicion del datase que sera utiliza para       ³±±
±±³          ³ contener los datos obtenidos apartir de los parametros       ³±±
±±³          ³ proporcionados en por el usario.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ (void)                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINR085P                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³      ³                                          ³±±
±±³            ³          ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Dataset F085ds
	title STR0002 //Orden de Pago
	description STR0003 //Orden de Pago BIRT - Principal y Retenciones
	PERGUNTE "FINR085P"
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Se define las columnas del dataset dsVen.
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

columns
If cPaisLoc == "ARG"
	define column OPORDEN TYPE CHARACTER  SIZE 12 LABEL STR0004
else
	define column OPORDEN TYPE CHARACTER  SIZE 6  LABEL STR0004
EndIf
	define column OPPROVD TYPE CHARACTER  SIZE 6  LABEL STR0005
	define column TDALOJA LIKE EK_LOJA
	define column PRVLOJA LIKE A2_LOJA
	define column OPEMISO TYPE CHARACTER  SIZE 10 LABEL STR0006
	define column OPNUMRO TYPE CHARACTER  SIZE 30 LABEL STR0007
	define column OPVALOR TYPE CHARACTER  SIZE 15 LABEL STR0008
	define column OPPAGO  TYPE CHARACTER  SIZE 15 LABEL STR0009
	define column OPMOEDA TYPE CHARACTER  SIZE 5  LABEL STR0010
	define column OPVENCT TYPE CHARACTER  SIZE 10 LABEL STR0011
	define column OPVALEN TYPE CHARACTER  SIZE 15 LABEL STR0012
	define column OPDESMD TYPE CHARACTER  SIZE 10 LABEL STR0013
	define column OPFLAG1 TYPE CHARACTER  SIZE 2  LABEL STR0014
	define column NOMEEMP TYPE CHARACTER  SIZE 60 LABEL STR0015
	define column DIRCEMP TYPE CHARACTER  SIZE 60 LABEL STR0016
	define column CECPEMP TYPE CHARACTER  SIZE 60 LABEL STR0017
	define column NOMECLI TYPE CHARACTER  SIZE 60 LABEL STR0018
	define column DIRCCLI TYPE CHARACTER  SIZE 60 LABEL STR0019
	define column CIUESTD TYPE CHARACTER  SIZE 60 LABEL STR0020
	define column CECPCLI TYPE CHARACTER  SIZE 60 LABEL STR0021
//DATASET DOS
	define column RTTPNUM TYPE CHARACTER  SIZE 80 LABEL STR0022
	define column RTMONTO TYPE CHARACTER  SIZE 15 LABEL STR0023
	define column RTFLAG2 TYPE CHARACTER  SIZE 2  LABEL STR0024
	define column IMAGE   TYPE CHARACTER  SIZE 20 LABEL "Imagen"

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Se define el query, para la obtencion de informacion del dataset
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
define query "SELECT OPORDEN, OPPROVD, TDALOJA, PRVLOJA, OPEMISO, OPNUMRO, OPVALOR, OPPAGO , "+;
                    "OPMOEDA, OPVENCT, OPVALEN, OPDESMD, OPFLAG1, NOMEEMP, DIRCEMP, CECPEMP, "+;
                    "NOMECLI, DIRCCLI, CIUESTD, CECPCLI, RTTPNUM, RTMONTO, RTFLAG2, IMAGE  "+;
             "FROM   %WTable:1%  "

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Se inicia la rutina de llenado del dataset
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
process dataset

Local cWTabAlias
Local lRet 	 	:= .F.

Private dDateIni	:= self:execParamValue("MV_PAR01")
Private dDateFin	:= self:execParamValue("MV_PAR02")
Private cOrdIni	:= self:execParamValue("MV_PAR03")
Private cOrdFin	:= self:execParamValue("MV_PAR04")
Private cForIni	:= self:execParamValue("MV_PAR05")
Private cForFin	:= self:execParamValue("MV_PAR06")

If cPaisLoc == "ARG" .AND. (GetNewPar("MV_CERTRET","N") == "S")
	Private nReImpr	:= self:execParamValue("MV_PAR07")
Endif

if ::isPreview()
endif

cWTabAlias := ::createWorkTable()
chkFile("SEK")

Processa({|_lEnd| lRet := PrintRpt(cWTabAlias)}, ::title())

if !lRet
	MsgInfo(STR0029)
else
	MsgInfo(STR0001)
endif

return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PrintRpt       ³ Autor ³ Jonathan Gonzalez     ³ Data ³ 26.05.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rutina para el llenado del dataset que contendra los datos que   ³±±
±±³          ³se mostran el reporte.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FINR085ds                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function PrintRpt(cWTabAlias)

Local cnt		 	:= 0
Local lRet 	 	:= .F.
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

Private nReImprimir := 0

If cPaisLoc == "ARG" .AND. (GetNewPar("MV_CERTRET","N") == "S")
	nReImprimir := nReimpr
Endif

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
	cQuery += " AND EK_DTDIGIT BETWEEN '" + DTOS( dDateIni ) + "' AND '" + DTOS( dDateFin ) + "'"
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

count to nCount

(cString)->(dbGotop())

ProcRegua(nCount)

While (cString)->(!Eof())
cnt++

Incproc()

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
				Aadd(aNfs,{cPref,EK_NUM,EK_PARCELA,nBaixa,EK_MOEDA,EK_VENCTO,nBaixaMd1,(cString)->(FieldPos('EK_CANPARC')) > 0 .And.!Empty((cString)->EK_CANPARC),EK_VALORIG,EK_EMISSAO})
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

	If nTotal > 0

		For i := 1 to Len(aNfs)
		RecLock(cWTabAlias,.T.)

			(cWTabAlias)->IMAGE	 := "lgrl"+cEmpAnt+".bmp"
			(cWTabAlias)->OPORDEN := RTRIM(cOrdPago)
			(cWTabAlias)->OPPROVD := RTRIM(SA2->A2_COD)
			(cWTabAlias)->TDALOJA := SEK->EK_LOJA
			(cWTabAlias)->PRVLOJA := SA2->A2_LOJA
			(cWTabAlias)->NOMEEMP := RTRIM(SM0->M0_NOME)
			(cWTabAlias)->DIRCEMP := RTRIM(SM0->M0_ENDCOB) +", "+ RTRIM(SM0->M0_BAIRCOB)
			(cWTabAlias)->CECPEMP := RTRIM(SM0->M0_CIDCOB) +", "+ RTRIM(SM0->M0_ESTCOB) +", "+ RTRIM(SM0->M0_CEPCOB)
			(cWTabAlias)->NOMECLI := RTRIM(SA2->A2_NOME)

			if cPaisLoc == "ARG"
				(cWTabAlias)->DIRCCLI := RTRIM(SA2->A2_END) +", "+ RTRIM(SA2->A2_NR_END) +", "+ RTRIM(SA2->A2_BAIRRO)
			else
				(cWTabAlias)->DIRCCLI := RTRIM(SA2->A2_END) +", "+ RTRIM(SA2->A2_NR_END) +", "+ RTRIM(SA2->A2_NROINT) +", "+ RTRIM(SA2->A2_BAIRRO)
			endif

			(cWTabAlias)->CIUESTD := RTRIM(POSICIONE("SX5",1,XFILIAL("SX5")+"12"+SA2->A2_EST,"X5_DESCSPA")) +", "+ RTRIM(SA2->A2_MUN)
			(cWTabAlias)->CECPCLI := RTRIM(POSICIONE("SYA",1,XFILIAL("SYA")+SA2->A2_PAIS,"YA_DESCR")) +", "+ RTRIM(SA2->A2_CEP)
			(cWTabAlias)->OPNUMRO := RTRIM(aNfs[i][1]) +" "+ RTRIM(aNfs[i][2])  // SER/NUMERO
			(cWTabAlias)->OPVALOR := ALLTRIM(Transform(aNfs[i][4],"99,999,999.99")) // VALOR -- picture
			(cWTabAlias)->OPMOEDA := RTRIM(aNfs[i][5] )      // MDA
			(cWTabAlias)->OPVENCT := RTRIM(DTOC(aNfs[i][6])) // VENCTO
			(cWTabAlias)->OPVALEN := ALLTRIM(Transform(aNfs[i][7],"99,999,999.99")) // VALOR EN -- picture
			(cWTabAlias)->OPPAGO  := ALLTRIM(Transform(aNfs[i][9],"99,999,999.99")) //VALOR ORIG. -picture
			(cWTabAlias)->OPDESMD := RTRIM(RTRIM(Getmv("MV_MOEDAP1")))
			(cWTabAlias)->OPFLAG1 := "OP"
			(cWTabAlias)->OPEMISO := RTRIM(DTOC(aNfs[i][10]))

		(cWTabAlias)->(MsUnLock())

		Next

		//RETENCIONES
		If Len(aRets) > 0
			For i:= 1 to Len(aRets)
			   If aRets[i][2] < 0 .Or. aRets[i][2] > 0

					If cPaisLoc == "ARG"
						cTipoRet:=IIf(aRets[i][3]=="G",OemToAnsi(STR0032),Iif(aRets[i][3]=="B",OemToAnsi(STR0033),Iif(aRets[i][3]=="S",OemToAnsi(STR0034),OemToAnsi(STR0035)))) //GANACIAS //ING. BR. //S.U.S.S. //I.V.A
					ElseIf cPaisLoc$"URU|BOL"
						cTipoRet:=OemToAnsi(STR0036) //I.R.I.C
					ElseIf cPaisLoc == "PTG"
						cTipoRet:=Iif(aRets[i][3]=="R",OemToAnsi(STR0037),OemToAnsi(STR0035)) //I.R.C //I.V.A
					ElseIf cPaisLoc == "ANG"
						cTipoRet:=OemToAnsi(STR0038) //R.I.E
					ElseIf cPaisLoc == "PER"
						If aRets[i][3] == "I"
							cTipoRet := OemToAnsi(STR0039) //I.G.V
						EndIf
					EndIf

					RecLock(cWTabAlias,.T.)

						(cWTabAlias)->OPPROVD := RTRIM(SA2->A2_COD)
						(cWTabAlias)->OPORDEN := RTRIM(cOrdPago)
						(cWTabAlias)->TDALOJA := SEK->EK_LOJA
						(cWTabAlias)->PRVLOJA := SA2->A2_LOJA
						(cWTabAlias)->RTTPNUM := STR0040 + cTipoRet + OemToAnsi(' NR ')+ RTRIM(aRets[i][1]) //EMITIDO CERTIFICADO DE RETENCION DE  //TIPO DE CERTIFICADO Y NUMERO
						(cWTabAlias)->RTMONTO := ALLTRIM(Transform((aRets[i][2] *  - 1 ),"999,999,999.99")) //MONTO DEL CERTIFICADO -- picture
						(cWTabALias)->RTFLAG2 := "RT"
					(cWTabAlias)->(MsUnLock())
				EndIf
			Next
		EndIf

	EndIf

	If cPaisLoc == "ARG" .AND. nReImprimir == 1
		ImpCertificado(cOrdPago, cTipoOp)
	EndIf

	dbSelectArea(cString)
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indice ou consulta(Query)                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cString)
dbCloseArea()

MS_FLUSH()

lRet := cnt > 0

return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpCertificado ³ Autor ³ Jonathan Gonzalez     ³ Data ³ 26.05.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rutina para la impresion de Certificados de retenciones          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PrintRpt  (ARG)                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpCertificado(cOrdPago, cTipoOp)
	Local aArea		:= GetArea()
	Local aAreaSFE	:= SFE->( GetArea() )
	Local aCert		:= {}
	Local lCertGn		:= ExistBlock("CERTGAN")
	Local lCertIb		:= ExistBlock("CERTIB")
	Local lCertIvSus	:= ExistBlock("CERTIVSUS")
	Local lCertCpr	:= ExistBlock("CERTCPR")
	Local i 			:= 0

	DbSelectArea("SFE")
	DbSetOrder(RETORDEM("SFE","FE_FILIAL+FE_ORDPAGO+FE_TIPO"))

	if SFE->(DbSeek(xFilial("SFE")+cOrdPago))
		while !SFE->(EOF()) .AND. xFilial("SFE") == SFE->FE_FILIAL .AND. SFE->FE_ORDPAGO == cOrdPago
			If !(Alltrim(SFE->FE_ORDPAGO) == "NORET")
				aadd(aCert,{SFE->FE_NROCERT,;	// [1]	Numero Certificado
							SFE->FE_TIPO,;		// [2]	Tipo
							"",;
							SFE->FE_CODASS})
			endif
			SFE->(dbSkip())
		Enddo

		for i := 1 To LEN(aCert)
			If aCert[i][2] $ "G" .And. lCertGn
				U_CERTGAN(aCert[i],aCert[i][4])
			ElseIf aCert[i][2] $ "I|S" .And. lCertIvSus
				U_CERTIVSUS(aCert[i],aCert[i][4],.F.)
			ElseIf aCert[i][2] $ "B" .And. lCertIb
				U_CERTIB(aCert[i],aCert[i][4],.F.)
			ElseIf aCert[i][2] $ "CPR" .And. lCertCpr
				U_CERTCPR(aCert[i],aCert[i][4],.F.)
			EndIf
		Next
	Endif

	SFE->(RestArea( aAreaSFE ))
	RestArea( aArea )

Return