#INCLUDE "EDCSA150.ch"
#INCLUDE "AVERAGE.CH"

#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#xTranslate :COURIER_10         => \[1\]
#xTranslate :COURIER_10_NEGRITO => \[2\]
#xTranslate :COURIER_12_NEGRITO => \[3\]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ EDCSA150 ³ Autor ³ Thomaz               ³ Data ³ 29.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Relatorio de Saldo de Ato Concessorio                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observação³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*----------------------*
Function EDCSA150()
*----------------------*
Local cAlias   := "ED0", nOpca := 1
Local bOk:={||(nOpca:=1, oDlg:End())}
Local bCancel:={||(nOpca:=0,oDlg:End())}
LOCAL nOrdSX3 := SX3->(indexOrd())

Private cFilSb1 := xFilial("SB1"), lPrint, lItensED8, lItens_E, lItens_W8, lItens_W5, lItensED9
Private cFilSB1Aux:=cFilSB1, cAliasSB1:="SB1" //Para utilizar produtos de outra Empresa/Filial
Private cAto    := Space(AVSX3("ED0_AC",3)), cItem:= Space(AVSX3("ED2_ITEM",3))
Private cFilSYT:=xFilial("SYT"), cFilSA2:=xFilial("SA2")
Private cTit    := STR0022 //"Relatorio de Saldo de Ato Concessorio"
Private cTipo   := "1-Analitico"
Private cModo   := "3 - Imp./Exp."
Private nSaldo  := 1 //"1-Encerrado" //AJP 17/04/2006
Private cPicCgc := "@R 99.999.999/9999-99"
Private lRet, oData, oData1, aObj:= {1,2,3}
Private dDtIni := cTod(""), dDtFim := cTod("")
Private cNomWork, cTipoAc
Private lTipoItem := ED7->( FieldPos("ED7_TPITEM") ) > 0  .And.  ED7->( FieldPos("ED7_PD") ) > 0
Private lAlt := .F.
SX3->(dbSetOrder(2)) //X3_CAMPO
//AJP 25/06/2007
Private lMultiFil  := VerSenha(115)  ;
                      .And.  Posicione("SX2",1,"ED1","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"ED2","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"EDD","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"EE9","X2_MODO") == "E" ;
                      .And.  Posicione("SX2",1,"SW8","X2_MODO") == "E" ;
                      .And.  SX3->(DbSeek("ED1_FILORI"));
                      .And.  SX3->(DbSeek("ED2_FILORI"));
                      .And.  SX3->(DbSeek("EDD_FILIMP"));
                      .And.  SX3->(DbSeek("EDD_FILEXP"))

// --- ACSJ - 19/11/2004 --------
SX3->(DBSetOrder(2))
Private lW5QtAc2 := SX3->(DBSeek("W5_QT_AC2"))
Private lW8QtAc2 := SX3->(DBSeek("W8_QT_AC2"))
SX3->(DBSetOrder(nOrdSX3))

SX6->(DBSETORDER(1))
lIntEDC := SX6->(DBSEEK(xFilial()+"MV_EIC_EDC"))

If (.not. lW5QtAc2  .or. .not. lW8QtAc2 ) .and. lIntEDC
   MsgInfo( STR0098 + Chr(13) +;
            STR0099 )
   Return .t.
Endif

//AJP 25/06/2007
Private aFil := IIF(lMultiFil,AvgSelectFil(.F.,,"ED0"),{xFilial("ED0")})
//**

// ------------------------- ACSJ

If Select("SB1EXP") = 0
   lAbriuExp := AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"")),cFilSB1,"SB1EXP") // Abre arq. produtos de outra Empresa/Filial de acordo com os parametros.
Else
   lAbriuExp := .T.
Endif

If lAbriuExp
   cAliasSB1  := "SB1EXP"
   cFilSB1Aux := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))
   If(Empty(Alltrim(cFilSB1Aux)),cFilSB1Aux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
Endif

//ASK 13/02/07 10:14 - Incluso no AtuSx do P9R1
//SA150ACERTADICIO()
While .T.

   cModo   := "3 - Imp./Exp."

   dbselectarea("ED4") // AAF 25/05/04 - Necessario haver um alias aberto antes da chamada ao pergunte.
   If !Pergunte("EDCSA1",.T.)
      Return .F.
   EndIf

   cAto   := mv_par01
   cItem  := mv_par02
   cTipo  := mv_par03
   cModo  := mv_par04
   dDtIni := mv_par05
   dDtFim := mv_par06
   nSaldo := mv_par07

   If nOpca == 1
      If Str(cTipo, 1) $ "1/2"
	     Processa({|| If (SA150VALID("DATAS"), SA150IMP(), )})
	  Endif
   ElseIf nOpca == 0
      Exit
   EndIf

EndDo

dbSelectArea(cAlias)

Return

*-----------------------------*
STATIC FUNCTION SA150IMP()
*-----------------------------*
Local cDesc1         := STR0029 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0030 //"de Saldo do Ato Concessorio."
Local cDesc3         := ""
Local cPict          := ""
Local imprime        := .T.
Private titulo       := STR0031 //"Relatorio de Saldo do Ato Concessorio"
Private nLin         := 80
Private Cabec1       := ""
Private Cabec2       := ""
Private cString      := "ED0"
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := STR0001 //"EDCSA150"
Private nTipo        := 18
Private aReturn      := { STR0002, 1, STR0003, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "EDCSA150" // Coloque aqui o nome do arquivo usado para impressao em disco
PRIVATE nPagina      := 0
Private TituloRel, lImprime:= .F.

wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

nTipo := If(aReturn[4]==1,15,18)

CRIAWORKDBF()

RptStatus({|lEnd| lImprime:= Imprime(wnRel,cString)})
If(lImprime, EDCSAGERADBF(), )

WORK->(E_EraseArq(cNomWork))

Return

*--------------------------------------*
STATIC FUNCTION Imprime(wnrel,cString)
*--------------------------------------*
Local cFilED0 := xFilial("ED0"), cFilED3 := xFilial("ED3"), cFilED4 := xFilial("ED4")
Local cFilSW5 := xFilial("SW5"), cFilSW8 := xFilial("SW8"), cFilEE9 := xFilial("EE9")
Local cFilSWP := xFilial("SWP"), cFilSA5 := xFilial("SA5"), cFilEEC := xFilial("EEC")
Local cFilSW6 := xFilial("SW6"), cFilSW7 := xFilial("SW7"), cFilSW9 := xFilial("SW9")
Local cPictEmb:= AVSX3("ED4_VALEMB",6), cPictNcm:= AVSX3("ED4_NCM",6)
Local cPictSeq:= AVSX3("ED4_SEQSIS",6), cPictQ_Ncm:= AVSX3("ED4_QTDNCM",6)
Local cPictQtd:= AVSX3("ED4_QTD",6), cPictQ_Li:= AVSX3("ED4_QT_LI",6)
Local cPictS_Nli:= AVSX3("ED4_SNCMLI",6), cPictVl_Li:= AVSX3("ED4_VL_LI",6)
Local cPictQt_Di:= AVSX3("ED4_QT_DI",6), cPictQ_Ndi:= AVSX3("ED4_SNCMDI",6)
Local cPictVl_Di:= AVSX3("ED4_VL_DI",6), cPictReg:= AVSX3("WP_REGIST",6)
Local cPictPgi:= AVSX3("W5_PGI_NUM",6), cPictS_Li:= AVSX3("W5_SEQ_LI",6)
Local cPictVen:= AVSX3("WP_VENCTO",6), cPictVl_Ac:= AVSX3("W5_VL_AC",6)
Local cPictCod:= AVSX3("W5_COD_I",6), cPictHawb:= AVSX3("W8_HAWB",6)
Local cPictQt_Ac := AVSX3("W5_QT_AC",6)
Local cPictDi:= AVSX3("W6_DI_NUM",6), cPictDtReg:= AVSX3("W6_DTREG_D",6)
Local cPictW8_P:= AVSX3("W8_PGI_NUM",6), cPictW8_Vl :=AVSX3("W8_VL_AC",6)
Local cPictInv:= AVSX3("W8_INVOICE",6)
Local cPictEd3_N:= AVSX3("ED3_NCM",6), cPictSeq_S:= AVSX3("ED3_SEQSIS",6)
Local cPictQtde:= AVSX3("ED3_QTD",6), cPictQt_Nc:= AVSX3("ED3_QTDNCM",6)
Local cPictValE:= AVSX3("ED3_VAL_EM",6), cPictVl_Se:= AVSX3("ED3_VAL_SE",6)
Local cPictSal:= AVSX3("ED3_SALDO",6), cPictSal_N:= AVSX3("ED3_SALNCM",6)
Local cPictSalCo:= AVSX3("ED3_SAL_CO",6), cPictSalSe:= AVSX3("ED3_SAL_SE",6)
Local cPictP_Em:= AVSX3("EEC_PREEMB",6), cPictRe:= AVSX3("EE9_RE",6)
Local cPictDtRe:= AVSX3("EE9_DTRE",6), cPictVlAto:= AVSX3("EE9_VL_AC",6)
Local  cPictCod_I:= AVSX3("EE9_COD_I",6)
Local cPictDtEm:= AVSX3("ED9_DTEMB",6)
Local cPictDtQtED9:= AVSX3("ED9_QTD",6), cPictVl_F:= AVSX3("ED9_VL_FOB",6)
Local cPictTx_M:= AVSX3("ED9_TX_MOE",6), cPictVl_M:= AVSX3("ED9_VALMOE",6)
Local cPictSerie:= AVSX3("ED8_SERIE",6), cPictNF:= AVSX3("ED8_NF",6)
Local nFilInd :=0
Local cPictImp:= AVSX3("YT_COD_IMP",6), cPictMOE:= AVSX3("ED9_MOEDA",6)
Local cPictExp:= AVSX3("A2_COD",6)
Local cFilED9 := xFilial("ED9")
// ACSJ - 01/12/2004 - Variaveis não Usadas.
//LOCAL cPictLoja:= AVSX3("ED9_LOJA",6), cPictQEm:= AVSX3("EE9_SLDINI",6), cPictW5_Q := AVSX3("W5_QTDE",6)
//LOCAL cPictW8_Q:=AVSX3("W8_QTDE",6), nCalcQtd := 0,nCalVal  := 0
Local lReturn
Local i := 1 // GFP - 21/12/2012
Private aValores := {}, lAltValores := .F.  // GFP - 21/12/2012

//AAF 17/02/06 - Verifica o parametro para declaracao das variaveis
//NOPADO POR AOM - 04/11/10 - If EasyGParam("MV_EDCDIE",,.F.)
   cPictAd:= AVSX3("ED8_ADICAO",6)
   cPictLi:= AVSX3("ED8_LI_NUM",6)
   cPictDtLi:= AVSX3("ED8_DTLI",6)
   cPictPeso:= AVSX3("ED8_PESO",6)
   cPictQtED8:= AVSX3("ED8_QTD",6)
   cPictUm:= AVSX3("ED8_UM",6)
   cPictVlF:= AVSX3("ED8_VALEMB",6)
   cPictTxM:= AVSX3("ED8_TX_MOE",6)
   cPictVlM:= AVSX3("ED8_VALORI",6)
   cFilED8 := xFilial("ED8")
//EndIf

Private cCobCamb, cAtoEd3, cAtoEd4
Private nLin := 99, cMensagem, cObserva

ED0->(dbSetOrder(2))

If !Empty(cAto) .AND. ED0->ED0_AC # cAto
   ED0->(DBSEEK(cFilED0+cAto))
ElseIf Empty(cAto)
   ED0->(DBSEEK(cFilED0, .T.))
EndIf

ED3->(dbSetOrder(2))
ED4->(dbSetOrder(2))
SYT->(dbSetOrder(1))
SA2->(dbSetOrder(1))

DO While !(ED0->(EOF())) .And. ED0->ED0_FILIAL == cFilED0

    If !Empty(cAto) .AND. ED0->ED0_AC # cAto
       Exit
    EndIf

    //If Empty(ED0->ED0_AC) .OR. !Empty(ED0->ED0_DT_ENC) AJP 17/04/2006
    If Empty(ED0->ED0_AC)
	   ED0->(DBSKIP())
	   LOOP
    EndIf
    // AJP 17/04/2006
    If nSaldo == 1 .AND. Empty(ED0->ED0_DT_ENC)  // Encerrado
	   ED0->(DBSKIP())
	   LOOP
    EndIf

    If nSaldo == 2 .AND. !Empty(ED0->ED0_DT_ENC)  // Em Aberto
	   ED0->(DBSKIP())
	   LOOP
    EndIf

	cModal := ED0->ED0_MODAL

	If Str(cModo,1) $ "1/3"

	    ED4->(DbSeek(cFilED4+ED0->ED0_AC))

		cAtoEd4 := ED4->ED4_AC
		Do While (!ED4->(Eof())) .And. ED4->ED4_FILIAL == cFilED4 .And. ED0->ED0_AC == ED4->ED4_AC

			If !Empty(cItem) .And. cItem <> ED4->ED4_ITEM
			   ED4->(dbSkip())
			   Loop
			Endif

			If !Empty(dDtIni)
				If !Empty(ED4->ED4_DT_VAL)
					If ED4->ED4_DT_VAL < dDtIni
						ED4->(DbSkip())
						Loop
					Endif
				Endif
			Endif

			If !Empty(dDtFim)
				If !Empty(ED4->ED4_DT_VAL)
					If ED4->ED4_DT_VAL > dDtFim
						ED4->(DbSkip())
						Loop
					Endif
				Endif
			Endif

			SysRefresh()
			If nLin >= 55
			   SA150CAB("I")
			EndIf

			nLin := nLin + 1
			// - BHF - Caracter = 30
			If Len(Alltrim(ED4->ED4_ITEM)) > 15 .And. Len(Alltrim(ED4->ED4_ITEM)) <= 30
			   @ nLin,001 PSAY If(Empty(ED4->ED4_ITEM), STR0004+Alltrim(ED4->ED4_UMITEM),Alltrim(ED4->ED4_ITEM)+"/"+Alltrim(ED4->ED4_UMITEM)) //"Generico/"
			   nLin := nLin + 1
			Else
			   @ nLin,001 PSAY If(Empty(ED4->ED4_ITEM), STR0004+Alltrim(ED4->ED4_UMITEM),Alltrim(ED4->ED4_ITEM)+"/"+Alltrim(ED4->ED4_UMITEM)) //"Generico/"
			EndIf

			@ nLin,021 PSAY If(cModal == "1", (Transf(ED4->ED4_NCM ,cPictNcm)+"/"+If(Empty(ED4->ED4_ITEM) .Or. Alltrim(ED4->ED4_NCM) == "99999999", Alltrim(ED4->ED4_UMITEM), Alltrim(ED4->ED4_UMNCM))), Transf(ED4->ED4_NCM ,cPictNcm))
			@ nLin,If(cModal == "1", 041, 035) PSAY Transf(ED4->ED4_SEQSIS ,cPictSeq)
			If cModal == "2"
			   @ nLin,043 PSAY Alltrim(ED4->ED4_UMNCM)
			Endif
			@ nLin,If(cModal == "1", 050, 051) PSAY Transf(ED4->ED4_QTDCAL,cPictQtd)//AAF 23/05/05 - Alterada a quantidade pela quantidade calculada.  //If(ED4->ED4_QTD < 0, Transf(0,cPictQtd),
			@ nLin,If(cModal == "1", 068, 069) PSAY Transf(ED4->ED4_QTDNCM * ED4->ED4_QTDCAL / ED4->ED4_QTD,cPictQ_Ncm) //AAF 10/06/05 - Quantidade calculada na NCM. //If(ED4->ED4_QTDNCM < 0 , Transf(0,cPictQ_Ncm),
			@ nLin,If(cModal == "1", 086, 087) PSAY Transf(ED4->ED4_VALCAL, cPictEmb)
			@ nLin,If(cModal == "1", 104, 105) PSAY Transf(ED4->ED4_QT_LI , cPictQ_Li) //If(ED4->ED4_QT_LI < 0 , Transf(0,cPictQ_Li),
		   	@ nLin,If(cModal == "1", 122, 123) PSAY Transf(ED4->ED4_SNCMLI, cPictS_Nli) //If(ED4->ED4_SNCMLI < 0 , Transf(0,cPictS_Nli),
			@ nLin,If(cModal == "1", 139, 140) PSAY Transf(ED4->ED4_VL_LI , cPictVl_Li)
			@ nLin,If(cModal == "1", 158, 159) PSAY Transf(ED4->ED4_QT_DI , cPictQt_Di) //If(ED4->ED4_QT_DI < 0 , Transf(0,cPictQt_Di),
			@ nLin,If(cModal == "1", 176, 177) PSAY Transf(ED4->ED4_SNCMDI, cPictQ_Ndi) //If(ED4->ED4_SNCMDI < 0 , Transf(0,cPictQ_Ndi),
			@ nLin,If(cModal == "1", 193, 194) PSAY Transf(ED4->ED4_VL_DI , cPictVl_Di)
			If ED4->ED4_CAMB == "1"
			   @ nLin,If(cModal == "1", 214, 215) PSAY STR0032 //"Sim"
			Else
			   @ nLin,If(cModal == "1", 214, 215) PSAY STR0033 //"Nao"
			Endif

			lReturn:= .T.

			If Str(cTipo,1) == "1"

				SWP->(dbSetOrder(1))
				SW5->(dbSetOrder(9))
				SA5->(dbSetOrder(3))
				SB1->(dbSetOrder(1))

                // AJP 25/06/2007 -> Tratamento MultiFilial
                For nFilInd :=1 to Len(aFil)
                   If lMultiFil
                      cFilSW5 := aFil[nFilInd]
                      cFilSW6 := aFil[nFilInd]
                      cFilSW7 := aFil[nFilInd]
                      cFilSW8 := aFil[nFilInd]
                      cFilSW9 := aFil[nFilInd]
                      cFilSWP := aFil[nFilInd]
                   EndIf
				   SW5->(DbSeek(cFilSW5+ED4->ED4_AC))
   				   lPrint    := .T.
				   lItens_W5 := .F.

				   DO While !(SW5->(Eof())) .And. SW5->W5_FILIAL == cFilSW5 .And. ED4->ED4_AC == SW5->W5_AC

                    /*If !Empty(cItem) .And. (cItem <> SW5->W5_COD_I .and. BuscaItemGen(SW5->W5_COD_I) <> cItem)
                         SW5->(dbSkip())
                         Loop
                    Endif*/

					  If ED4->ED4_SEQSIS <> SW5->W5_SEQSIS .OR. SW5->W5_SEQ # 0
					     SW5->(DBSKIP())
					     LOOP
					  Endif

					  If lPrint
				         nLin := nLin + 2
				      Endif

					SWP->(DbSeek(cFilSWP+SW5->W5_PGI_NUM))
					  SA5->(DbSeek(cFilSA5+SW5->W5_COD_I))
					  SB1->(DbSeek(cFilSB1+SW5->W5_COD_I))

					  SysRefresh()
					  If nLin >= 55 .or. lPrint = .T.
				         If (!lMultiFil,SA150LI_DI("LI"),SA150LIDIMULT("LI")) //AJP 27/06/2007
					     lPrint := .F.
					  EndIf

   	        	      nLin := nLin + 1
   	        	      //AJP 26/06/2007 MultiFiliais
   	        	      If lMultiFil
   	        	         @nLin,010 PSAY Left(cFilSW5+"-"+AvgFilName({cFilSW5})[1],10)
   	        	      EndIf
                      @ nLin,021 PSAY Transf(SWP->WP_REGIST, cPictReg)
                      @ nLin,037 PSAY Transf(SW5->W5_PGI_NUM, cPictPgi)
                      @ nLin,054 PSAY Transf(SW5->W5_SEQ_LI, cPictS_Li)
				      @ nLin,063 PSAY Transf(SWP->WP_VENCTO, cPictVen)
                      @ nLin,078 PSAY Transf(SW5->W5_VL_AC, cPictVl_Ac)
                      @ nLin,098 PSAY Transf(SW5->W5_QT_AC, cPictQT_AC)
                      @ nLin,117 PSAY Transf(SW5->W5_QT_AC2, cPictQT_AC)
                      /*cItem := If(Alltrim(ED4->ED4_NCM) == "99999999", BuscaItemGen(SW5->W5_COD_I), SW5->W5_COD_I)
                      @ nLin,117 PSAY Transf(If(SA5->A5_UNID = ED4->ED4_UMNCM, SW5->W5_QT_AC, AVTransUnid(SA5->A5_UNID,ED4->ED4_UMNCM,cItem,SW5->W5_QT_AC)), cPictW8_Q)*/
                      If ED4->ED4_CAMB == "1"
				         @ nLin,143 PSAY STR0032 //"Sim"
                      Else
				         @ nLin,143 PSAY STR0033 //"Nao"
                      Endif

                      If Alltrim(ED4->ED4_NCM) == "99999999"  .And. Empty(ED4->ED4_ITEM)
                         @ nLin,155 PSAY Transf(SW5->W5_COD_I, cPictCod)
                         @ nLin,172 PSAY SB1->B1_DESC
                         @ nLin,206 PSAY Transf(SWP->WP_NCM, cPictNcm)

                      ElseIf Alltrim(ED4->ED4_NCM) <> "99999999"  .And. Empty(ED4->ED4_ITEM)
                         @ nLin,155 PSAY Transf(SW5->W5_COD_I,  cPictCod)
                         @ nLin,172 PSAY SB1->B1_DESC

                      ElseIf Alltrim(ED4->ED4_NCM) == "99999999" .And. !Empty(ED4->ED4_ITEM)
                         @ nLin,155 PSAY Transf(SWP->WP_NCM, cPictNcm)
                      Endif

                      If ED4->ED4_ITEM <> SW5->W5_COD_I
                         @ nLin,153 PSAY SW5->W5_COD_I
                      EndIf

					  lItens_W5 := .T.

					  EDCSAGRVDBF("SW5")

					  SW5->(DBSKIP())
				  ENDDO

				  SW6->(DBSETORDER(1))
                  SW7->(DBSETORDER(1))
                  SW9->(DBSETORDER(3))
                  SA5->(DBSETORDER(3))
                  SB1->(DBSETORDER(1))
                  SW8->(DBSETORDER(5))

				  SW8->(DbSeek(cFilSW8+ED4->ED4_AC))
                  lPrint := .T.
                  lItens_W8 := .F.

                  Do While SW8->(!EOF()) .And. SW8->W8_FILIAL == cFilSW8 .And. SW8->W8_AC == ED4->ED4_AC

                   /*If !Empty(cItem) .And. (cItem <> SW8->W8_COD_I .and. BuscaItemGen(SW8->W8_COD_I) <> cItem)
                        SW8->(dbSkip())
                        Loop
                    Endif*/

 				     If ED4->ED4_SEQSIS <> SW8->W8_SEQSIS
				        SW8->(DBSKIP())
                        LOOP
                     Endif

                     SW6->(DbSeek(cFilSW6+SW8->W8_HAWB))
                     SW7->(DbSeek(cFilSW7+SW8->W8_HAWB))
                     SW9->(DbSeek(cFilSW9+SW8->W8_HAWB))
                     SA5->(DbSeek(cFilSA5+SW8->W8_COD_I))
                     SB1->(DbSeek(cFilSB1+SW8->W8_COD_I))

				     Do Case
				        Case Empty(SW6->W6_DI_NUM) .And. !Empty(SW6->W6_DTRECDO)
                           cMensagem := STR0034 + dtoc(SW6->W6_DTRECDO) //"Ag. Registro da D.I / Rec. de Doctos em "
                        Case Empty(SW6->W6_DI_NUM) .And. !Empty(SW6->W6_CHEG)
                           cMensagem := STR0035 + dtoc(SW6->W6_CHEG)    //"Ag. Registro da D.I / Atracado em "
                        Case Empty(SW6->W6_DI_NUM) .And. !Empty(SW6->W6_DT_EMB)
				           cMensagem := STR0036 + dtoc(SW6->W6_DT_EMB)  //"Ag. Registro da D.I / Embarcado em "
				        Case Empty(SW6->W6_DI_NUM) .And. Empty(SW6->W6_DT_EMB)
                           cMensagem := STR0058
                     EndCase

                     If lPrint
				         nLin := nLin + 2
				     Endif

        		     SysRefresh()
				     If nLin >= 55 .or. lPrint = .T.
                        //SA150LI_DI("DI")
     			        If (!lMultiFil,SA150LI_DI("DI"),SA150LIDIMULT("DI")) //AJP 27/06/2007
				   	    lPrint := .F.
                     EndIf

                     nLin := nLin + 1
             	     If lMultiFil
   	        	         @nLin,010 PSAY Left(cFilSW8+"-"+AvgFilName({cFilSW8})[1],10)
   	        	     EndIf

                     @ nLin,021 PSAY Transf(SW8->W8_HAWB, cPictHawb)
                     @ nLin,039 PSAY Transf(SW6->W6_DI_NUM, cPictDi)
                     @ nLin,053 PSAY Transf(SW6->W6_DTREG_D, cPictDtReg)
                     @ nLin,064 PSAY Transf(SW8->W8_PGI_NUM, cPictW8_P)
                     @ nLin,072 PSAY Transf(SW8->W8_VL_AC, cPictW8_Vl)
                     If Alltrim(ED4->ED4_NCM) <> "99999999"
                        //@ nLin,099 PSAY Transf(If(SA5->A5_UNID = ED4->ED4_UMITEM, SW8->W8_QTDE, AVTransUnid(SA5->A5_UNID,ED4->ED4_UMITEM,SW8->W8_COD_I,SW8->W8_QTDE)), cPictW8_Q)
                        //@ nLin,115 PSAY Transf(If(SA5->A5_UNID = ED4->ED4_UMNCM, SW8->W8_QTDE, AVTransUnid(SA5->A5_UNID,ED4->ED4_UMNCM,SW8->W8_COD_I,SW8->W8_QTDE)), cPictW8_Q)
                        @ nLin,090 PSAY Transf(SW8->W8_QT_AC, cPictQT_AC)//cPictW8_Q)
                        @ nLin,108 PSAY Transf(SW8->W8_QT_AC2, cPictQT_AC)//cPictW8_Q)
                        If ED4->ED4_CAMB == "1"
     	                   @ nLin,131 PSAY STR0032 //"Sim"
                        Else
                           @ nLin,131 PSAY STR0033 //"Nao"
                        Endif
          		        @ nLin,136 PSAY  Transf(SW8->W8_INVOICE, cPictInv)
				        @ nLin,154 PSAY  AllTrim(cMensagem)
				        If ED4->ED4_ITEM <> SW8->W8_COD_I
                           @ nLin,202 PSAY SW8->W8_COD_I
                        EndIf
                     Else
                        If ED4->ED4_CAMB == "1"
				           @ nLin,95 PSAY STR0032 //"Sim"
                        Else
                           @ nLin,95 PSAY STR0033 //"Nao"
                        Endif
                        @ nLin,110 PSAY  Transf(SW8->W8_INVOICE, cPictInv)
                        @ nLin,126 PSAY  cMensagem
                     Endif

                     @ nLin,210 PSAY "Import."

                     lItens_W8 := .T.

                     EDCSAGRVDBF("SW8")

                     cMensagem := " "
                     SW8->(DBSKIP())
           		  Enddo

                  //IF NOPADO POR AOM - 04/11/10 - EasyGParam("MV_EDCDIE",,.F.) //Alcir Alves - define se virá dados das DI´s externas
                     ED8->(DBSETORDER(3))
                     ED8->(DbSeek(cFilED8+ED4->ED4_AC+ED4->ED4_SEQSIS))

                     lPrint    := .T.
                     lItensED8 := .F.

                     SYT->(dbSetOrder(3))
		             Do While ED8->(!EOF()) .And. ED8->ED8_FILIAL == cFilED8 .And. ED8->ED8_AC == ED4->ED4_AC ;
		                .And. Alltrim(ED8->ED8_SEQSIS) == Alltrim(ED4->ED4_SEQSIS)

		                SYT->(dbSeek(cFilSYT+ED8->ED8_CNPJIM))

                        If lPrint
			               nLin := nLin + 2
			            Endif

                        SysRefresh()
                        If nLin >= 55 .Or. lPrint = .T.
			               //SA150LI_DI("IN/SOL/I")
			               If (lMultiFil,SA150LIDIMULT("IN/SOL/I"),SA150LI_DI("IN/SOL/I")) //AJP 27/06/2007
			               lPrint := .F.
                        EndIf

                        IF(EasyEntryPoint("EDCSA150"),Execblock("EDCSA150",.F.,.F.,"ALTERA_VALORES"),)  //GFP - 21/12/2012

                        nLin := nLin + 1
                        // GFP - 21/12/2012 - Caso entre no ponto de entrada acima, o sistema considera os valores colocados pelo usuario.
                        @ nLin,010 PSAY Transf( If(lAltValores, If(!Empty(aValores[i][1]), aValores[i][1], ED8->ED8_DI_NUM) , ED8->ED8_DI_NUM ) , cPictDi)
                        @ nLin,026 PSAY Transf( If(lAltValores, If(!Empty(aValores[i][2]), aValores[i][2], ED8->ED8_ADICAO ), ED8->ED8_ADICAO ) , cPictAd)
                        @ nLin,035 PSAY Transf( If(lAltValores, If(!Empty(aValores[i][3]), aValores[i][3], ED8->ED8_DTREG ) , ED8->ED8_DTREG )  , cPictDtReg)
                        @ nLin,047 PSAY Transf( If(lAltValores, If(!Empty(aValores[i][4]), aValores[i][4], ED8->ED8_LI_NUM ), ED8->ED8_LI_NUM ) , cPictLi)
                        @ nLin,060 PSAY Transf( If(lAltValores, If(!Empty(aValores[i][5]), aValores[i][5], ED8->ED8_DTLI )  , ED8->ED8_DTLI )   , cPictDtLi)
                        @ nLin,073 PSAY Transf( If(lAltValores, If(!Empty(aValores[i][6]), aValores[i][6], ED8->ED8_PESO )  , ED8->ED8_PESO )   , cPictPeso)
                        @ nLin,093 PSAY Transf( If(lAltValores, If(!Empty(aValores[i][7]), aValores[i][7], ED8->ED8_QTD )   , ED8->ED8_QTD )    , cPictQtED8)
                        @ nLin,112 PSAY Transf( If(lAltValores, If(!Empty(aValores[i][8]), aValores[i][8], ED8->ED8_UM )    , ED8->ED8_UM )     , cPictUm)
                        @ nLin,119 PSAY Transf( If(lAltValores, If(!Empty(aValores[i][9]), aValores[i][9], ED8->ED8_VALEMB ), ED8->ED8_VALEMB ) , cPictVlF)
                        @ nLin,142 PSAY Transf( If(lAltValores, If(!Empty(aValores[i][10]), aValores[i][10],ED8->ED8_TX_MOE ), ED8->ED8_TX_MOE ), cPictTxM)
                        @ nLin,158 PSAY Transf( If(lAltValores, If(!Empty(aValores[i][11]), aValores[i][11],ED8->ED8_VALORI ), ED8->ED8_VALORI ), cPictVlM)
                        @ nLin,179 PSAY Transf( If(lAltValores, If(!Empty(aValores[i][12]), aValores[i][12],ED8->ED8_NF )    , ED8->ED8_NF )    , cPictNF)
                        @ nLin,187 PSAY Transf( If(lAltValores, If(!Empty(aValores[i][13]), aValores[i][13],ED8->ED8_SERIE ) , ED8->ED8_SERIE ) , cPictSerie)
                        @ nLin,193 PSAY Transf(SYT->YT_COD_IMP, cPictImp)
                        @ nLin,198 PSAY Left(SYT->YT_NOME, 20)
                        @ nLin,220 PSAY IIF(EMPTY(ED8->ED8_DT_INT),"Manuten.","Integra.")
                        lItensED8 := .T.
		                i++
		                ED8->(DBSKIP())
		             EndDo
		          //ENDIF
		          SYT->(dbSetOrder(1))
               Next
            EndIF

            //AOM - 04/11/10 - Inserindo os Saldos das Ocorrências
            If ChkFile("EDH")
               EDH->(DbSetOrder(2))
               EDH->(xFilial("EDH") + AvKey(ED4->ED4_AC,"EDH_AC") + AvKey(ED4->ED4_SEQSIS,"EDH_SEQSIS"))

               lPrint := .T.

               Do While EDH->(!EOF()) .And. EDH->EDH_FILIAL == xFilial("EDH") .And. EDH->EDH_AC == ED4->ED4_AC ;
		                .And. Alltrim(EDH->EDH_SEQSIS) == Alltrim(ED4->ED4_SEQSIS)

                     If lPrint
				         nLin := nLin + 2
				     Endif

        		     SysRefresh()
				     If nLin >= 55 .or. lPrint = .T.
                        SA150EDH()
				   	    lPrint := .F.
                     EndIf

                     nLin := nLin + 1
                     If EDH->EDH_TPOCOR == "1"             //Tipo Ocorrencia
                        @ nLin,023 PSAY "1-Devolução"
                     ElseIf EDH->EDH_TPOCOR == "2"
                        @ nLin,023 PSAY "2-Destruição"
                     ElseIf EDH->EDH_TPOCOR == "3"
                        @ nLin,023 PSAY "3-Sinistro"
                     ElseIf EDH->EDH_TPOCOR == "4"
                        @ nLin,023 PSAY "4-Nacionalização"
                     EndIf

                     @ nLin,043 PSAY Transf(EDH->EDH_DTOCOR, AVSX3("EDH_DTOCOR",6)) //Data Ocorrencia
                     @ nLin,058 PSAY EDH->EDH_CODOCO                                //Codigo da Ocorrencia
                     @ nLin,063 PSAY Transf(EDH->EDH_QTDNCM, AVSX3("EDH_QTDNCM",6)) //Qntde NCM
                     @ nLin,080 PSAY Transf(EDH->EDH_QTDEST, AVSX3("EDH_QTDEST",6)) //Qntde de estoque do Item
                     @ nLin,100 PSAY Transf(EDH->EDH_VALDOL, AVSX3("EDH_VALDOL",6)) //Valor da Ocorrencia em US$
                     @ nLin,125 PSAY Transf(EDH->EDH_HAWB  , AVSX3("EDH_HAWB"  ,6)) //Processo
                     @ nLin,141 PSAY Transf(EDH->EDH_INVOIC, AVSX3("EDH_INVOIC",6)) //Invoice
                     @ nLin,154 PSAY Transf(EDH->EDH_DI_NUM, cPictDi)               //Nr DI
                     @ nLin,170 PSAY Transf(EDH->EDH_DT_DI , AVSX3("EDH_DT_DI" ,6)) //Dt DI
                     @ nLin,188 PSAY Transf(EDH->EDH_PGI_NU, AVSX3("EDH_PGI_NU",6)) //Nr PLI
                     @ nLin,205 PSAY Transf(EDH->EDH_LI    , AVSX3("EDH_LI"    ,6)) //LI
               EDH->(DBSKIP())
               EndDo
            EndIf


            If(!lItens_W5 .And. !lItens_W8, EDCSAGRVDBF("ED4"), )


		    ED4->(DBSKIP())

            If cAtoEd4 <> ED4->ED4_AC
               nLin    := 999
               cAtoEd4 := ED4->ED4_AC
            Endif

		    If Str(cTipo,1) == "1" .And. (lItens_W5 = .T. .OR. lItens_W8 = .T. .Or. lItensED8)
               nLin := nLin+2
            Endif
		Enddo
	    nLin := nLin+2
	Endif

	nLin := 99

    If Str(cModo,1) $ "2/3" .And. cModal == "1" //Se for Suspensão

	    ED3->(DbSeek(cFilED3+ED0->ED0_AC))
	    nLin     := nLin + 2

		cAtoEd3 := ED3->ED3_AC
		Do While !(ED3->(Eof())) .And. ED3->ED3_FILIAL == cFilED3 .And. ED0->ED0_AC == ED3->ED3_AC

		   If !Empty(cItem) .And. cItem <> ED3->ED3_PROD
		      ED3->(dbSkip())
		      Loop
		   Endif

		   If ! Empty(dDtIni)
		      If !Empty(ED3->ED3_DT_VAL)
			     If ED3->ED3_DT_VAL < dDtIni
				    ED3->(DbSkip())
					Loop
				 Endif
			  Endif
		   Endif

           If ! Empty(dDtFim)
		      If !Empty(ED3->ED3_DT_VAL)
                 If ED3->ED3_DT_VAL > dDtFim
                    ED3->(DbSkip())
                    Loop
                 Endif
              Endif
           Endif

           SysRefresh()
           If nLin >= 55
              SA150CAB("E")
           EndIf

           nLin := nLin + 1
           // BHF - 30/01/09 - 30 Caracteres
           If Len(ALLTRIM(ED3->ED3_PROD)) > 15 .And. Len(ALLTRIM(ED3->ED3_PROD)) <= 30
              @ nLin,001 PSAY If(Empty(ED3->ED3_PROD),STR0004+Alltrim(ED3->ED3_UMPROD), Alltrim(ED3->ED3_PROD)+"/"+Alltrim(ED3->ED3_UMPROD)) //"Generico/"
		      nLin := nLin + 1
  	 	   Else
  	 	      @ nLin,001 PSAY If(Empty(ED3->ED3_PROD),STR0004+Alltrim(ED3->ED3_UMPROD), Alltrim(ED3->ED3_PROD)+"/"+Alltrim(ED3->ED3_UMPROD)) //"Generico/"
		   EndIf
		   @ nLin,021 PSAY Transf(ED3->ED3_NCM, cPictEd3_N)+"/"+If(Empty(ED3->ED3_PROD) .Or. Alltrim(ED3->ED3_NCM) == "99999999", Alltrim(ED3->ED3_UMPROD), Alltrim(ED3->ED3_UMNCM))
           @ nLin,040 PSAY Transf(ED3->ED3_SEQSIS, cPictSeq_S)
		   @ nLin,050 PSAY Transf(ED3->ED3_QTD   , cPictQtde)
		   @ nLin,068 PSAY Transf(ED3->ED3_QTDNCM, cPictQt_Nc)
		   @ nLin,086 PSAY Transf(ED3->ED3_VAL_EM, cPictValE)
		   @ nLin,104 PSAY Transf(ED3->ED3_VAL_SE, cPictVl_Se)
		   @ nLin,122 PSAY Transf(ED3->ED3_SALDO , cPictSal)
		   @ nLin,140 PSAY Transf(ED3->ED3_SALNCM, cPictSal_N)
		   @ nLin,157 PSAY Transf(ED3->ED3_SAL_CO, cPictSalCo)
		   @ nLin,175 PSAY Transf(ED3->ED3_SAL_SE, cPictSalSe)

           lReturn:= .T.

           If Str(cTipo,1) == "1"

       	      For nFilInd :=1 to Len(aFil)

          	     If lMultiFil
          	        cFilEE7 := aFil[nFilInd]
          	        cFilEE8 := aFil[nFilInd]
          	        cFilEE9 := aFil[nFilInd]
          	        cFilEEC := aFil[nFilInd]
          	     EndIf

          	     EE9->(dbSetOrder(10))
       		     EEC->(dbSetOrder(1))
		         EE9->(DbSeek(cFilEE9+ED3->ED3_AC))
        	     lPrint   := .T.
                 lItens_E := .F.


                 Do While EE9->(!EOF()) .And. EE9->EE9_FILIAL == cFilEE9 .And. Alltrim(EE9->EE9_ATOCON) == Alltrim(ED3->ED3_AC)
                    lAlt := .F.

                    If !Empty(cItem) .And. cItem <> EE9->EE9_COD_I
                       EE9->(dbSkip())
                       Loop
                    Endif

                    //TRP-14/11- Verifica se o produto é um alternativo
 	   		        If ED3->ED3_PROD <> EE9->EE9_COD_I .and. lTipoItem
 			           lAlt:=.T.
 			        Endif

 			        If ED3->ED3_SEQSIS <> EE9->EE9_SEQED3
			 	       EE9->(DBSKIP())
                       LOOP
                    Endif

                    (cAliasSB1)->(DbSeek(cFilSB1Aux+EE9->EE9_COD_I))
                    EEC->(DbSeek(cFilEEC+EE9->EE9_PREEMB))

                    If EEC->EEC_STATUS == "*"
                       EE9->(DBSKIP())
                       LOOP
                    Endif

 				    Do Case
 				       Case Empty(EE9->EE9_RE) .And. !Empty(EEC->EEC_DTENDC)
				          cObserva := STR0037 + dtoc(EEC->EEC_DTENDC) //"Ag. Reg. da R.E. / Data de Envio dos Doctos em "
 				       Case Empty(EE9->EE9_RE) .And. !Empty(EEC->EEC_DTINSP)
				          cObserva := STR0038 + dtoc(EEC->EEC_DTINSP) //"Ag. Reg. da R.E. / Data da Inspecao em "
                       Case Empty(EE9->EE9_RE) .And. !Empty(EEC->EEC_DTPALE)
 				          cObserva := STR0039 + dtoc(EEC->EEC_DTPALE) //"Ag. Reg. da R.E. / Data da Paletizacao em "
                       Case Empty(EE9->EE9_RE) .And. !Empty(EEC->EEC_DTSLIN)
 				          cObserva := STR0040 + dtoc(EEC->EEC_DTSLIN) //"Ag. Reg. da R.E. / Data da Sol. de Inspecao em "
                       Case Empty(EE9->EE9_RE) .And. !Empty(EEC->EEC_DTSLPL)
 				          cObserva := STR0041 + dtoc(EEC->EEC_DTSLPL) //"Ag. Reg. da R.E. / Data da Sol. da Palet. em "
                       Case Empty(EE9->EE9_RE) .And. !Empty(EEC->EEC_DTCONH)
 				          cObserva := STR0042 + dtoc(EEC->EEC_DTCONH) //"Ag. Registro da R.E. / Data do Conhecimento em "
                    EndCase

                    If lPrint
				        nLin := nLin + 2
				    Endif

                    SysRefresh()
				    If nLin >= 55  .or. lPrint = .T.
				       //SA150LI_DI("RE")
				       If(lMultiFil,SA150LIDIMULT("RE"),SA150LI_DI("RE")) //AJP 27/06/2007
				       lPrint := .F.
				    EndIf

				    nLin := nLin + 1
             	    If lMultiFil
   	        	        @nLin,010 PSAY Left(cFilEE9+"-"+AvgFilName({cFilEE9})[1],10)
   	        	    EndIf
                    @ nLin,021 PSAY Transf(EEC->EEC_PREEMB, cPictP_Em)
				    @ nLin,044 PSAY Transf(EE9->EE9_RE, cPictRe)
				    @ nLin,061 PSAY Transf(EE9->EE9_DTRE, cPictDtRe)

				    If EE9->(FieldPos("EE9_VLSCOB")) > 0
   				       If EEC->EEC_COBCAM == "1"
                          @ nLin,072 PSAY Transf(EE9->EE9_VL_AC, cPictVlAto)
                          @ nLin,090 PSAY Transf(EE9->EE9_VLSCOB, cPictVlAto)
                       Else
                          @ nLin,072 PSAY Transf(0, cPictVlAto)
                          @ nLin,090 PSAY Transf(EE9->EE9_VL_AC+EE9->EE9_VLSCOB, cPictVlAto)
                       EndIf
                    Else
   				       If EEC->EEC_COBCAM == "1"
                          @ nLin,072 PSAY Transf(EE9->EE9_VL_AC, cPictVlAto)
                          @ nLin,090 PSAY Transf(0, cPictVlAto)
                       Else
                          @ nLin,072 PSAY Transf(0, cPictVlAto)
                          @ nLin,090 PSAY Transf(EE9->EE9_VL_AC, cPictVlAto)
                       EndIf
				    EndIf

				    //AAF 29/09/05 - Conversão utilizando a U.M. do Ato Concessório.
				    //@ nLin,091 PSAY Transf(If(EE9->EE9_UNIDAD = ED3->ED3_UMPROD, EE9->EE9_SLDINI, AVTransUnid(EE9->EE9_UNIDAD,ED3->ED3_UMPROD,EE9->EE9_COD_I,EE9->EE9_SLDINI)), cPictSal)
				    @ nLin,109 PSAY Transf(EE9->EE9_QT_AC, cPictSal)
				    //@ nLin,109 PSAY Transf(If(EE9->EE9_UNIDAD = ED3->ED3_UMNCM, EE9->EE9_SLDINI, AVTransUnid(EE9->EE9_UNIDAD,ED3->ED3_UMNCM,EE9->EE9_COD_I,EE9->EE9_SLDINI)), cPictSal)
				    @ nLin,127 PSAY Transf(If(ED3->ED3_UMPROD = ED3->ED3_UMNCM, EE9->EE9_QT_AC, AVTransUnid(ED3->ED3_UMPROD,ED3->ED3_UMNCM,EE9->EE9_COD_I,EE9->EE9_QT_AC)), cPictSal)

				 	/*
    			    If EEC->EEC_COBCAM == "1"
  				       @ nLin,128 PSAY STR0032 //"Sim"
        		    Else
                       @ nLin,128 PSAY STR0033 //"Nao"
                    EndIf
                    */

                    If Empty(ED3->ED3_PROD)
                       @ nLin,144 PSAY Transf(EE9->EE9_COD_I, cPictCod_I)
                       @ nLin,163 PSAY AllTrim(cObserva)
   				       If lAlt
				          @ nLin,163+60 PSAY  EE9->EE9_COD_I
                       Endif
                    Else
				       @ nLin,144 PSAY AllTrim(cObserva)
                       If lAlt
				          @ nLin,144+60 PSAY  EE9->EE9_COD_I
				       Endif
				    Endif

                    IF(EasyEntryPoint("EDCSA150"),Execblock("EDCSA150",.F.,.F.,"INCLUIR_CAMPOS_EE9"),)    // GFP - 01/03/2013

				    EDCSAGRVDBF("EE9")

				    lItens_E := .T.
				    cObserva := " "

				    EE9->(DBSKIP())
                 ENDDO

                 ED9->(DBSETORDER(3))
                 ED9->(DbSeek(cFilED9+ED3->ED3_AC+ED3->ED3_SEQSIS))

                 lPrint    := .T.
                 lItensED9 := .F.

                 SA2->(dbSetOrder(3))
		      Do While ED9->(!EOF()) .And. ED9->ED9_FILIAL == cFilED9 .And. ED9->ED9_AC == ED3->ED3_AC

		            SA2->(dbSeek(cFilSA2+ED9->ED9_EXPORT))

                 If ED9->ED9_SEQSIS <> ED3->ED3_SEQSIS   //TRP - 27/06/11 - Os dois campos devem ser caracter.
                    ED9->(dbSkip())
                    LOOP
                 EndIf

                    If lPrint
			           nLin := nLin + 2
			        Endif

                    SysRefresh()
                    If nLin >= 55 .Or. lPrint = .T.
			           //SA150LI_DI("IN/SOL/E")
			           If (lMultiFil,SA150LIDIMULT("IN/SOL/E"),SA150LI_DI("IN/SOL/E")) //AJP 27/06/2007
			           lPrint := .F.
                    EndIf

                    nLin := nLin + 1
                    @ nLin,012 PSAY Transf(ED9->ED9_RE, cPictRe)
                    @ nLin,028 PSAY Transf(ED9->ED9_DTRE, cPictDtRe)
                    @ nLin,040 PSAY Transf(ED9->ED9_DTEMB, cPictDtEm)
                    @ nLin,053 PSAY Transf(ED9->ED9_PESO, cPictPeso)
                    @ nLin,073 PSAY Transf(ED9->ED9_QTD, cPictDtQtED9)
                    @ nLin,093 PSAY Transf(ED9->ED9_UM, cPictUm)
                    @ nLin,099 PSAY Transf(ED9->ED9_VL_FOB, cPictVl_F)
                    @ nLin,120 PSAY Transf(ED9->ED9_TX_MOE, cPictTx_M)
                    @ nLin,140 PSAY Transf(ED9->ED9_VALMOE, cPictVl_M)
                    @ nLin,161 PSAY Transf(ED9->ED9_MOEDA, cPictMOE)
                    @ nLin,167 PSAY Transf(ED9->ED9_NF, cPictNF)
                    @ nLin,177 PSAY Transf(ED9->ED9_SERIE, cPictSerie)
                    @ nLin,183 PSAY Transf(SA2->A2_COD, cPictExp)
                    @ nLin,192 PSAY Left(SA2->A2_NOME, 30)

                    lItensED9 := .T.
		            ED9->(DBSKIP())
		         EndDo
		         SA2->(dbSetOrder(1))
              Next
           EndIF
		   If(!lItens_E, EDCSAGRVDBF("ED3"), )

		   ED3->(DBSKIP())

		   If cAtoEd3 <> ED3->ED3_AC
              nLin    := 999
              cAtoEd3 := ED3->ED3_AC
           Endif

		   If Str(cTipo,1) == "1" .And. (lItens_E = .T. .Or. lItensED9 = .T.)
              nLin := nLin+2
           Endif

		Enddo
	Endif
    ED0->(DBSKIP())
Enddo

nLin++
@nLin,001 PSAY " "

If lReturn
   If aReturn[5] = 1
      Set Printer To
	  Commit
	  Ourspool(wnrel)
   EndIf
Else
   Help(" ",1,"AVG0005190") //MsgInfo(STR0019) //"Nao Ha Dados para Impressao !!!"
   lReturn:= .F.
Endif

MS_FLUSH()

dDtIni := cTod("")
dDtFim := cTod("")
cAto   := Space(AVSX3("ED0_AC",3))
cTipo  := ""
cModo  := ""

ED0->(dbSetOrder(1))
SW6->(DBSETORDER(1))
SW7->(DBSETORDER(1))
SW9->(DBSETORDER(1))
SA5->(DBSETORDER(1))
SB1->(DBSETORDER(1))
SW8->(DBSETORDER(1))
SWP->(dbSetOrder(1))
SW5->(dbSetOrder(1))
EE9->(DBSETORDER(1))
EEC->(DBSETORDER(1))

Return lReturn

*---------------------------------*
STATIC FUNCTION SA150CAB(cModulo)
*---------------------------------*
Local cFilSYT := xFilial("SYT")
Local cPictAC := ""

TituloRel := Titulo + If(Str(cTipo,1) == "1", STR0043, STR0044 ) //" (Analitico)"###" (Sintetico)"

SYT->(DBSETORDER(1))

// Buscar Dados do Importador
SYT->(DbSeek(cFilSYT+ED0->ED0_IMPORT))

Do Case
   Case ED0->ED0_TIPOAC == "01"
      cTipoAc := STR0074       //"Comum                           "
   Case ED0->ED0_TIPOAC == "02"
      cTipoAc := STR0075       //"Intermediário                   "
   Case ED0->ED0_TIPOAC == "03"
      cTipoAc := STR0076       //"Solidário                       "
   Case ED0->ED0_TIPOAC == "04"
      cTipoAc := STR0077       //"Embarcação                      "
   Case ED0->ED0_TIPOAC == "05"
      cTipoAc := STR0078       //"Fornecimento no Mercado Interno "
   Case ED0->ED0_TIPOAC == "06"
      cTipoAc := STR0079       //"Genérico                        "
   Case ED0->ED0_TIPOAC == "08"
      cTipoAc := STR0080       //"Genérico/Embarcação             "
   OtherWise
      cTipoAc := STR0081       //"Genérico/Fornec. Mercado Interno"
EndCase

If cModal == "2"
   cPictAC := "@R 9999-99/999999-9"
Else
   cPictAC := AVSX3("ED0_AC",6)
Endif

nLin := 08

If cModulo  == "I"
	Cabec1 := STR0045+If(!Empty(cAto),Transf(cAto,cPictAC), Transf(ED4->ED4_AC, cPictAC))+Space(10)+"Pedido..:"+ED0->ED0_PD+Space(2)+"Modalidade: "+If(cModal == "1", "Suspensão","Isenção  ")+Space(4)+STR0046+Transf(SYT->YT_CGC,cPicCgc)+If(cModal == "2", Space(44), Space(47))+STR0047+Left(SYT->YT_NOME, 33) //" Ato Concessorio...: "###"C.N.P.J..: "###"Importador......: "
	nLIN:= nLIN + 1
	Cabec2 := STR0048+dtoc(dDtIni)+" a "+dtoc(dDtFim)+Space(05)+STR0082+cTipoAc+Space(16)+STR0049+space(16)+STR0050 +If(!Empty(ED4->ED4_DT_VAL), Str((ED4->ED4_DT_VAL - dDataBase),5),"00")+Space(07)+STR0051+dtoc(ED4->ED4_DT_VAL) //" Periodo...........:"###"Tipo A.C "###"Importacao "###"Dias Restantes..:"###"Dt. Validade: "
                                                                                                       //NCF - 20/09/2011 - diminuido o espaço entre strings para não truncar no fim do relatorio
ElseIf cModulo == "E"
	Cabec1 := STR0045+If(!Empty(cAto),Transf(cAto,cPictAC), Transf(ED3->ED3_AC, cPictAC))+Space(10)+"Pedido..:"+ED0->ED0_PD+Space(2)+"Modalidade: "+If(cModal == "1", "Suspensão","Isenção  ")+Space(4)+STR0046+Transf(SYT->YT_CGC,cPicCgc)+If(cModal == "2", Space(44), Space(47))+STR0047+Left(SYT->YT_NOME, 33) //" Ato Concessorio...: "###"C.N.P.J..: "###"Importador......: "
	nLIN:= nLIN + 1
	Cabec2 := STR0048+dToc(dDtIni)+" a "+dtoc(dDtFim)+Space(05)+STR0082+cTipoAc+Space(16)+STR0052+Space(16)+STR0050 +If(!Empty(ED3->ED3_DT_VAL), Str((ED3->ED3_DT_VAL - dDataBase),5),"00")+Space(07)+STR0051+dtoc(ED3->ED3_DT_VAL) //" Periodo...........:"###"Tipo A.C "###"Exportacao "###"Dias Restantes..:"###"Dt. Validade: "

Endif

Cabec(TituloRel,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

If cModulo  == "I"
	@ nLin,00 Psay If(cModal == "1", STR0055, STR0083) // "                                                                     Autorizado                                            Saldo LI                                              Saldo DI " ### "                                                                      Autorizado                                            Saldo LI                                              Saldo DI "
	nLin := nLin +1
	@ nLin,00 Psay If(cModal == "1", STR0056, STR0084) // "                                                  ----------------------------------------------------- ----------------------------------------------------- -----------------------------------------------------" ### "                                                   ----------------------------------------------------- ----------------------------------------------------- ------------------------------------------------------"
	nLin := nLin +1
	@ nLin,00 Psay If(cModal == "1", STR0005, STR0085) // "     Item                NCM        Seq. Siscomex     Qtde Item         Qtde NCM          Valor US$         Qtde Item         Qtde NCM          Valor US$         Qtde Item         Qtde NCM          Valor US$     C/ Cob." ### "     Item               NCM     Seq.Sis. UM Compra     Qtde Item         Qtde Compra       Valor US$         Qtde Item         Qtde Compra        Valor US$        Qtde Item         Qtde Compra       Valor US$     C/ Cob."
	nLin := nLin +1
	@ nLin,00 Psay If(cModal == "1", STR0006, STR0086) // " =================== ============== ============= ================= ================= ================= ================= ================= ================= ================= ================= ================= =======" ### " =================== ========== ======== ========= ================= ================= ================= ================= ================= ================= ================= ================= ================= ======="
ElseIf cModulo  == "E"
	@ nLin,00 Psay STR0057 //"                                                                                      Autorizado                                                       Saldo"
	nLin := nLin +1
	@ nLin,00 Psay STR0007 //"                                                  ----------------------------------------------------------------------- -----------------------------------------------------------------------"
	nLin := nLin +1
	@ nLin,00 Psay STR0008 //"     Produto             NCM        Seq. Siscomex    Qtde Prod.        Qtde NCM         Valor com Cob.    Valor sem Cob.     Qtde Prod.        Qtde NCM       Vl. com Cob. US$  Vl. sem Cob. US$"
	nLin := nLin +1
	@ nLin,00 Psay STR0009 //" =================== ============== ============= ================= ================= ================= ================= ================= ================= ================= ================="
Endif

RETURN .T.

*------------------------------------------*
STATIC FUNCTION SA150LI_DI(cForma)
*------------------------------------------*

If nLIn >= 55
   Cabec(TituloRel,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   nLin := 09
Endif

If cForma  == "LI" .And. Empty(ED4->ED4_ITEM) .And. Alltrim(ED4->ED4_NCM) == "99999999"
   //                                  1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1
   //                        0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
   @ nLin,00 Psay If(cModal == "1", STR0010, STR0087) //"                       Nro PLI/Reg       P.L.I.    Seq. L.I.    Data Vencto       Valor US$         Qtde UM Item       Qtde UM NCM        Com Cobertura         Item                 Descricao                     NCM"
   nLin := nLin +1
   @ nLin,00 Psay STR0092 // "                     ============== ============== ========= ================= =================  =================  ================     =============    ================ ================================= ============"
ElseIf cForma  == "LI"  .And. Empty(ED4->ED4_ITEM) .And. Alltrim(ED4->ED4_NCM) <> "99999999"
   @ nLin,00 Psay If(cModal == "1", STR0012, STR0088) //"                       Nro PLI/Reg       P.L.I.    Seq. L.I.    Data Vencto       Valor US$         Qtde UM Item       Qtde UM NCM        Com Cobertura         Item                 Descricao"
   nLin := nLin +1
   @ nLin,00 Psay STR0093 // "                     ============== ============== ========= ================= =================  =================  ================     =============    ================ ================================"
ElseIf cForma  == "LI"  .And. !Empty(ED4->ED4_ITEM) .And. Alltrim(ED4->ED4_NCM) == "99999999"
   @ nLin,00 Psay If(cModal == "1", STR0059, STR0089) //"                       Nro PLI/Reg       P.L.I.    Seq. L.I.    Data Vencto       Valor US$         Qtde UM Item       Qtde UM NCM        Com Cobertura         NCM"
   nLin := nLin +1
   @ nLin,00 Psay STR0094 // "                     ============== ============== ========= ================= =================  =================  ================     =============    ============"
ElseIf cForma  == "LI"
   @ nLin,00 Psay If(cModal == "1", STR0061, STR0090) //"                       Nro PLI/Reg       P.L.I.    Seq. L.I.    Data Vencto       Valor US$         Qtde UM Item       Qtde UM NCM        Com Cobertura  Item Alternativo"
   nLin := nLin +1
   @ nLin,00 Psay STR0095 // "                     ============== ============== ========= ================= =================  =================  ================     =============  ================"
Endif

If cForma  == "DI"  .And. Alltrim(ED4->ED4_NCM) <> "99999999"
   @ nLin,00 Psay If(cModal == "1", STR0014, STR0091) //"                           Processo           D.I.      Dt Reg. D.I.    P.L.I         Valor US$      Qtde UM Item    Qtde UM NCM   Com Cobertura    Invoice                          Observacao Item Alternativo"
   nLin := nLin +1
   @ nLin,00 Psay STR0015 //"                     =================== ============== ============ ============ ================ =============== =============== ============= ================ ================================================= ================"
ElseIf cForma  == "DI"  .And. Alltrim(ED4->ED4_NCM) == "99999999"
   @ nLin,00 Psay STR0016 //"                           Processo           D.I.      Dt Reg. D.I.    P.L.I         Valor US$    Com Cobertura     Invoice                        Observacao"
   nLin := nLin +1
   @ nLin,00 Psay STR0017 //"                     =================== ============== ============ ============ ================ ============= ================ ================================================="
Endif

If cForma  == "RE" .And.  Empty(ED3->ED3_PROD)
   @ nLin,00 Psay STR0018 //"                            Embarque             R.E.       Dt Registro     Valor US$      Valor S/ Cob. US$  Qtde UM Item       Qtde UM NCM       Produto                            Observacao"
   nLin := nLin +1
   @ nLin,00 Psay STR0019 //"                     ====================== =============== ============ ================= ================= ================= ================= ================ =========================================================="
ElseIf cForma  == "RE" .And. ! Empty(ED3->ED3_PROD)
   @ nLin,00 Psay STR0020 //"                            Embarque             R.E.       Dt Registro     Valor US$      Valor S/ Cob. US$  Qtde UM Item       Qtde UM NCM                         Observacao"
   nLin := nLin +1
   @ nLin,00 Psay STR0021 //"                     ====================== =============== ============ ================= ================= ================= ================= ======================================================"
Endif

If cForma  == "IN/SOL/I" //Intermediário - Solidário da Imp.
   //NOPADO POR AOM - 04/11/10 - IF EasyGParam("MV_EDCDIE",,.F.) //Alcir Alves - define se virá dados das DI´s externas
   If ED0->ED0_TIPOAC == "02" .Or. ED0->ED0_TIPOAC == "03"
      @ nLin,00 Psay STR0068+STR0065+STR0072 //"  -----------------------------------------------------------------------------------" "Comprovação" "----------------------------------------------------------------------------------------------------"
      nLin := nLin +1
   Endif
   @ nLin,00 Psay STR0063 //"            Nro D.I.     Adição   Dt Registro   Nro L.I.     Dt L.I.       Peso               Qtde UM NCM      U.M.      Valor FOB           Taxa Moe             Valor Moe        N.F.   Série Imp.    Nome Importador      Origem  "
   nLin := nLin +1
   @ nLin,00 Psay STR0064 //"         ============== ======== ============ ============ ========== =================== ==================== ==== ==================== =================== ==================== ======= ===== ==== ====================== =========== "
   //endif
Endif

If cForma  == "IN/SOL/E" //Intermediário - Solidário da Exp.
   If ED0->ED0_TIPOAC == "02" .Or. ED0->ED0_TIPOAC == "03"
      @ nLin,00 Psay STR0071+STR0065+STR0073 //"            ------------------------------------------------------------------------" " ---------------------------------------------------------------------------------------------------------------------"
      nLin := nLin +1
   Endif
   @ nLin,00 Psay STR0069 //"               Nro R.E.     Dt R.E.   Dt Embarque        Peso             Qtde UM NCM       U.M.       Valor FOB           Taxa Moe            Valor Moe       Moeda    N.F    Série  Export.          Nome Exportador "
   nLin := nLin +1
   @ nLin,00 Psay STR0070 //"            ============== ========== ============ =================== ==================== ==== ==================== =================== ==================== ====== ======== ====== =======  =============================="
Endif

Return .T.

*------------------------------------------*
STATIC FUNCTION SA150LIDIMULT(cForma)
*------------------------------------------*

If nLIn >= 55
   Cabec(TituloRel,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   nLin := 09
Endif

If cForma  == "LI" .And. Empty(ED4->ED4_ITEM) .And. Alltrim(ED4->ED4_NCM) == "99999999"
   //                                  1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1
   //                        0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
   @ nLin,00 Psay If(cModal == "1", STR0100, STR0110) //"                       Nro PLI/Reg       P.L.I.    Seq. L.I.    Data Vencto       Valor US$         Qtde UM Item       Qtde UM NCM        Com Cobertura         Item                 Descricao                     NCM"
   nLin := nLin +1
   @ nLin,00 Psay STR0115 // "                     ============== ============== ========= ================= =================  =================  ================     =============    ================ ================================= ============"
ElseIf cForma  == "LI"  .And. Empty(ED4->ED4_ITEM) .And. Alltrim(ED4->ED4_NCM) <> "99999999"
   @ nLin,00 Psay If(cModal == "1", STR0101, STR0111) //"                       Nro PLI/Reg       P.L.I.    Seq. L.I.    Data Vencto       Valor US$         Qtde UM Item       Qtde UM NCM        Com Cobertura         Item                 Descricao"
   nLin := nLin +1
   @ nLin,00 Psay STR0116 // "                     ============== ============== ========= ================= =================  =================  ================     =============    ================ ================================"
ElseIf cForma  == "LI"  .And. !Empty(ED4->ED4_ITEM) .And. Alltrim(ED4->ED4_NCM) == "99999999"
   @ nLin,00 Psay If(cModal == "1", STR0059, STR0112) //"                       Nro PLI/Reg       P.L.I.    Seq. L.I.    Data Vencto       Valor US$         Qtde UM Item       Qtde UM NCM        Com Cobertura         NCM"
   nLin := nLin +1
   @ nLin,00 Psay STR0117 // "                     ============== ============== ========= ================= =================  =================  ================     =============    ============"
ElseIf cForma  == "LI"
   @ nLin,00 Psay If(cModal == "1", STR0061, STR0113) //"                       Nro PLI/Reg       P.L.I.    Seq. L.I.    Data Vencto       Valor US$         Qtde UM Item       Qtde UM NCM        Com Cobertura  Item Alternativo"
   nLin := nLin +1
   @ nLin,00 Psay STR0118 // "                     ============== ============== ========= ================= =================  =================  ================     =============  ================"
Endif

If cForma  == "DI"  .And. Alltrim(ED4->ED4_NCM) <> "99999999"
   @ nLin,00 Psay If(cModal == "1", STR0102, STR0114) //"                           Processo           D.I.      Dt Reg. D.I.    P.L.I         Valor US$      Qtde UM Item    Qtde UM NCM   Com Cobertura    Invoice                          Observacao Item Alternativo"
   nLin := nLin +1
   @ nLin,00 Psay STR0103 //"                     =================== ============== ============ ============ ================ =============== =============== ============= ================ ================================================= ================"
ElseIf cForma  == "DI"  .And. Alltrim(ED4->ED4_NCM) == "99999999"
   @ nLin,00 Psay STR0104 //"                           Processo           D.I.      Dt Reg. D.I.    P.L.I         Valor US$    Com Cobertura     Invoice                        Observacao"
   nLin := nLin +1
   @ nLin,00 Psay STR0105 //"                     =================== ============== ============ ============ ================ ============= ================ ================================================="
Endif

If cForma  == "RE" .And.  Empty(ED3->ED3_PROD)
   @ nLin,00 Psay STR0106 //"                            Embarque             R.E.       Dt Registro     Valor US$        Qtde UM Item       Qtde UM NCM    C/ Cob.     Produto                            Observacao"
   nLin := nLin +1
   @ nLin,00 Psay STR0107 //"                     ====================== =============== ============ ================= ================= ================= ======== ================ =========================================================="
ElseIf cForma  == "RE" .And. ! Empty(ED3->ED3_PROD)
   @ nLin,00 Psay STR0108 //"                            Embarque             R.E.       Dt Registro     Valor US$        Qtde UM Item       Qtde UM NCM    C/ Cob.                       Observacao"
   nLin := nLin +1
   @ nLin,00 Psay STR0109 //"                     ====================== =============== ============ ================= ================= ================= ======== ======================================================"
Endif

If cForma  == "IN/SOL/I" //Intermediário - Solidário da Imp.
   //NOPADO POR AOM - 04/11/10 - IF EasyGParam("MV_EDCDIE",,.F.) //Alcir Alves - define se virá dados das DI´s externas
   If ED0->ED0_TIPOAC == "02" .Or. ED0->ED0_TIPOAC == "03"
      @ nLin,00 Psay STR0068+STR0065+STR0072 //"  -----------------------------------------------------------------------------------" "Comprovação" "----------------------------------------------------------------------------------------------------"
      nLin := nLin +1
   Endif
   @ nLin,00 Psay STR0063 //"            Nro D.I.     Adição   Dt Registro   Nro L.I.     Dt L.I.       Peso               Qtde UM NCM      U.M.      Valor FOB           Taxa Moe             Valor Moe        N.F.   Série Imp.    Nome Importador      Origem  "
   nLin := nLin +1
   @ nLin,00 Psay STR0064 //"         ============== ======== ============ ============ ========== =================== ==================== ==== ==================== =================== ==================== ======= ===== ==== ====================== =========== "
   //endif
Endif

If cForma  == "IN/SOL/E" //Intermediário - Solidário da Exp.
   If ED0->ED0_TIPOAC == "02" .Or. ED0->ED0_TIPOAC == "03"
      @ nLin,00 Psay STR0071+STR0065+STR0073 //"            ------------------------------------------------------------------------" " ---------------------------------------------------------------------------------------------------------------------"
      nLin := nLin +1
   Endif
   @ nLin,00 Psay STR0069 //"               Nro R.E.     Dt R.E.   Dt Embarque        Peso             Qtde UM NCM       U.M.       Valor FOB           Taxa Moe            Valor Moe       Moeda    N.F    Série  Export.          Nome Exportador "
   nLin := nLin +1
   @ nLin,00 Psay STR0070 //"            ============== ========== ============ =================== ==================== ==== ==================== =================== ==================== ====== ======== ====== =======  =============================="
Endif

Return .T.
*--------------------------*
Function SA150VALID(cParam)
*--------------------------*
Local lRet:= .T.

If cParam = "ATO"
   IF !EMPTY(mv_par01)
      If(!ExistCpo("ED0",mv_par01,2), lRet:= .F., )
   Endif
ElseIf cParam = "DATAS"
   If !Empty(dDtFim) .And. !Empty(dDtIni)
      If dDtFim < dDtIni
         Help(" ",1,"AVG0005207") //Msginfo(STR0053, STR0054) //"A data final deve ser maior que a data inicial"###"Mensagem"
         lRet:= .F.
      Endif
   Endif
ElseIf cParam == "ITEM"

   If Type("cAliasSB1") == "U"
      cAliasSB1:= "SB1"
   EndIf
   If Type("cFilSB1Aux") == "U"
      cFilSB1Aux:= SB1->(xFilial("SB1"))
   EndIf

   IF !EMPTY(mv_par02).and. !(cAliasSB1)->(DbSeek(cFilSB1Aux+mv_par02))
      If !ExistCpo('SB1',mv_par02)
         lRet:=.F.
      EndIf
   EndIf
Endif

Return lRet


*-----------------------------*
Static Function CRIAWORKDBF()
*-----------------------------*
Private aWork:={;
               {"WKAC"     ,"C",AVSX3("ED0_AC",3),AVSX3("ED0_AC",4)},;
               {"WKPD"     ,"C",AVSX3("ED0_PD",3),AVSX3("ED0_PD",4)},;
               {"WKMODAL"  ,"C",9  ,0},;
               {"WKCNPJ"   ,"C",AVSX3("ED0_CNPJ",3),AVSX3("ED0_CNPJ",4)},;
               {"WKIMPOR"  ,"C",33 ,0},;
               {"WKTIPO"   ,"C",32 ,0},;
               {"WKDIAS"   ,"N",6  ,0},;
               {"WKDTVAL"  ,"D",AVSX3("ED4_DT_VAL",3),AVSX3("ED4_DT_VAL",4)},;
               {"WKITEM"   ,"C",AVSX3("ED4_ITEM",3)+AVSX3("ED4_UM",3)+1,0},;
               {"WKNCM"    ,"C",AVSX3("ED4_NCM",3)+AVSX3("ED4_UM",3)+1,0},;
               {"WKSEQ"    ,"C",AVSX3("ED4_SEQSIS",3),AVSX3("ED4_SEQSIS",4)},;
               {"WKUMCOM"  ,"C",AVSX3("ED4_UMNCM",3),AVSX3("ED4_UMNCM",4)},;
               {"WKQT_IAU" ,"N",AVSX3("ED4_QTD",3),AVSX3("ED4_QTD",4)},;
               {"WKQT_CAU" ,"N",AVSX3("ED4_QTDNCM",3),AVSX3("ED4_QTDNCM",4)},;
               {"WKVLAUT"  ,"N",AVSX3("ED4_VALCAL",3),AVSX3("ED4_VALCAL",4)},;
               {"WKQT_ILI" ,"N",AVSX3("ED4_QT_LI",3),AVSX3("ED4_QT_LI",4)},;
               {"WKQT_CLI" ,"N",AVSX3("ED4_SNCMLI",3),AVSX3("ED4_SNCMLI",4)},;
               {"WKVLLI"   ,"N",AVSX3("ED4_VL_LI",3),AVSX3("ED4_VL_LI",4)},;
               {"WKQT_IDI" ,"N",AVSX3("ED4_QT_DI",3),AVSX3("ED4_QT_DI",4)},;
               {"WKQT_CDI" ,"N",AVSX3("ED4_SNCMDI",3),AVSX3("ED4_SNCMDI",4)},;
               {"WKVLDI"   ,"N",AVSX3("ED4_VL_DI",3),AVSX3("ED4_VL_DI",4)},;
               {"WKCOBIT"  ,"C",3,0},;
               {"WKREGIST" ,"C",AVSX3("WP_REGIST",3),AVSX3("WP_REGIST",4)},;
               {"WKPGI"    ,"C",AVSX3("W5_PGI_NUM",3),AVSX3("W5_PGI_NUM",4)},;
               {"WKSEQLI"  ,"C",AVSX3("W5_SEQ_LI",3),AVSX3("W5_SEQ_LI",4)},;
               {"WKVENCTO" ,"D",AVSX3("WP_VENCTO",3),AVSX3("WP_VENCTO",4)},;
               {"WKVL_AC"  ,"N",AVSX3("W5_VL_AC",3),AVSX3("W5_VL_AC",4)},;
               {"WKQT_AC"  ,"N",AVSX3("W5_QT_AC",3),AVSX3("W5_QT_AC",4)},;
               {"WKQTACCO" ,"N",AVSX3("W5_QT_AC",3),AVSX3("W5_QT_AC",4)},;
               {"WKCOBPLI" ,"C",3,0},;
               {"WKCODI"   ,"C",AVSX3("B1_COD",3),AVSX3("B1_COD",4)},;
               {"WKDESC"   ,"C",AVSX3("B1_DESC",3),AVSX3("B1_DESC",4)},;
               {"WKNCMPLI" ,"C",AVSX3("WP_NCM",3),AVSX3("WP_NCM",4)},;
               {"WKHAWB"   ,"C",AVSX3("W8_HAWB",3),AVSX3("W8_HAWB",4)},;
               {"WKNRODI"  ,"C",AVSX3("W6_DI_NUM",3),AVSX3("W6_DI_NUM",4)},;
               {"WKDTDI"   ,"D",AVSX3("W6_DTREG_D",3),AVSX3("W6_DTREG_D",4)},;
               {"WKPGINUM" ,"C",AVSX3("W8_PGI_NUM",3),AVSX3("W8_PGI_NUM",4)},;
               {"WKVLPROC" ,"N",AVSX3("W8_VL_AC",3),AVSX3("W8_VL_AC",4)},;
               {"WKQTPROC" ,"N",AVSX3("W8_QT_AC",3),AVSX3("W8_QT_AC",4)},;
               {"WKQTPROC2","N",AVSX3("W8_QT_AC2",3),AVSX3("W8_QT_AC2",4)},;
               {"WKCOBPRO" ,"C",3,0},;
               {"WKINVOIC" ,"C",AVSX3("W8_INVOICE",3),AVSX3("W8_INVOICE",4)},;
               {"WKPREEMB" ,"C",AVSX3("EEC_PREEMB",3),AVSX3("EEC_PREEMB",4)},;
               {"WKRE"     ,"C",AVSX3("EE9_RE",3),AVSX3("EE9_RE",4)},;
               {"WKDTRE"   ,"D",8,0},;
               {"WKMENSA"  ,"C",100,0},;
               {"WKIM_EXP" ,"C",1,0}}

cNomWork:=E_CriaTrab(,aWork,"Work")

If !USED()
   Help(" ",1,"E_NAOHAREA")
   Return .F.
Endif

IndRegua("Work",cNomWork+TEOrdBagExt(),"WKAC")

Return .T.

*-----------------------------------*
Static Function EDCSAGRVDBF(cAlias)
*-----------------------------------*

Work->(dbAppend())

If cAlias $ "ED4/SW5/SW8"
   Work->WKAC    :=ED4->ED4_AC
   Work->WKPD    :=ED4->ED4_PD
   Work->WKMODAL :=If(cModal == "1", "Suspensão","Isenção")
   Work->WKDIAS  :=If(!Empty(ED4->ED4_DT_VAL), (ED4->ED4_DT_VAL - dDataBase),)
   Work->WKDTVAL :=ED4->ED4_DT_VAL
   Work->WKITEM  :=If(Empty(ED4->ED4_ITEM), STR0004+Alltrim(ED4->ED4_UMITEM),Alltrim(ED4->ED4_ITEM)+"/"+Alltrim(ED4->ED4_UMITEM))
   Work->WKNCM   :=If(cModal == "1", ED4->ED4_NCM+"/"+If(Empty(ED4->ED4_ITEM) .Or. Alltrim(ED4->ED4_NCM) == "99999999", Alltrim(ED4->ED4_UMITEM), Alltrim(ED4->ED4_UMNCM)), ED4->ED4_NCM)
   Work->WKSEQ   :=ED4->ED4_SEQSIS
   Work->WKUMCOM :=If(cModal=="2", ED4->ED4_UMNCM, )
   Work->WKQT_IAU:=ED4->ED4_QTDCAL
   Work->WKQT_CAU:=ED4->ED4_QTDNCM * ED4->ED4_QTDCAL / ED4->ED4_QTD //AAF 10/06/05 - Quantidade calculada na NCM.
   Work->WKVLAUT :=ED4->ED4_VALCAL
   Work->WKQT_ILI:=ED4->ED4_QT_LI
   Work->WKQT_CLI:=ED4->ED4_SNCMLI
   Work->WKVLLI  :=ED4->ED4_VL_LI
   Work->WKQT_IDI:=ED4->ED4_QT_DI
   Work->WKQT_CDI:=ED4->ED4_SNCMDI
   Work->WKVLDI  :=ED4->ED4_VL_DI
   Work->WKCOBIT :=If(ED4->ED4_CAMB == "1",STR0032, STR0033)  //Sim###"Nao"
   Work->WKIM_EXP:="I"
Endif

If cAlias $ "ED3/EE9"
   Work->WKAC    :=ED3->ED3_AC
   Work->WKPD    :=ED3->ED3_PD
   Work->WKMODAL :="Suspensão"
   Work->WKDIAS  :=If(!Empty(ED3->ED3_DT_VAL), (ED3->ED3_DT_VAL - dDataBase),)
   Work->WKDTVAL :=ED3->ED3_DT_VAL
   Work->WKITEM  :=If(Empty(ED3->ED3_PROD), STR0004+Alltrim(ED3->ED3_UMPROD),Alltrim(ED3->ED3_PROD)+"/"+Alltrim(ED3->ED3_UMPROD))
   Work->WKNCM   :=ED3->ED3_NCM+"/"+If(Empty(ED3->ED3_PROD) .Or. Alltrim(ED3->ED3_NCM) == "99999999", Alltrim(ED3->ED3_UMPROD), Alltrim(ED3->ED3_UMNCM))
   Work->WKSEQ   :=ED3->ED3_SEQSIS
   Work->WKQT_IAU:=ED3->ED3_QTD
   Work->WKQT_CAU:=ED3->ED3_QTDNCM

   Work->WKVLAUT :=ED3->ED3_VAL_EM
   Work->WKQT_ILI:=ED3->ED3_SALDO
   Work->WKQT_CLI:=ED3->ED3_SALNCM
   Work->WKVLLI  :=ED3->ED3_VAL_SE
   Work->WKQT_IDI:=ED3->ED3_SAL_CO
   Work->WKQT_CDI:=ED3->ED3_SAL_SE
   Work->WKIM_EXP:="E"
Endif

Work->WKCNPJ  :=SYT->YT_CGC
Work->WKIMPOR :=Left(SYT->YT_NOME, 33)
Work->WKTIPO  :=cTipoAc

If cAlias == "SW5"
   Work->WKREGIST:=SWP->WP_REGIST
   Work->WKPGI   :=SW5->W5_PGI_NUM
   Work->WKSEQLI :=SW5->W5_SEQ_LI
   Work->WKVENCTO:=SWP->WP_VENCTO
   Work->WKVL_AC :=SW5->W5_VL_AC
   Work->WKQT_AC :=SW5->W5_QT_AC
   Work->WKQTACCO:=SW5->W5_QT_AC2
   Work->WKCOBPLI:=If(ED4->ED4_CAMB == "1",STR0032, STR0033)  //Sim###"Nao"
   If Alltrim(ED4->ED4_NCM) == "99999999"  .And. Empty(ED4->ED4_ITEM)
      Work->WKCODI  :=SW5->W5_COD_I
      Work->WKDESC  :=SB1->B1_DESC
      Work->WKNCMPLI:=SWP->WP_NCM
   ElseIf Alltrim(ED4->ED4_NCM) <> "99999999"  .And. Empty(ED4->ED4_ITEM)
      Work->WKCODI  :=SW5->W5_COD_I
      Work->WKDESC  :=SB1->B1_DESC
   ElseIf Alltrim(ED4->ED4_NCM) == "99999999" .And. !Empty(ED4->ED4_ITEM)
      Work->WKNCMPLI:=SWP->WP_NCM
   Endif
   Work->WKIM_EXP:="I"
ElseIf cAlias == "SW8"
   Work->WKHAWB  :=SW8->W8_HAWB
   Work->WKNRODI :=SW6->W6_DI_NUM
   Work->WKDTDI  :=SW6->W6_DTREG_D
   Work->WKPGINUM:=SW8->W8_PGI_NUM
   Work->WKVLPROC:=SW8->W8_VL_AC
   If Alltrim(ED4->ED4_NCM) <> "99999999"
      Work->WKQTPROC :=SW8->W8_QT_AC
      Work->WKQTPROC2:=SW8->W8_QT_AC2
      Work->WKCOBPRO :=If(ED4->ED4_CAMB == "1",STR0032, STR0033)  //Sim###"Nao"
      Work->WKINVOIC :=SW8->W8_INVOICE
      Work->WKMENSA  :=cMensagem
   Else
      Work->WKCOBPRO:=If(ED4->ED4_CAMB == "1",STR0032, STR0033)  //Sim###"Nao"
      Work->WKINVOIC:=SW8->W8_INVOICE
      Work->WKMENSA :=cMensagem
   Endif
   Work->WKIM_EXP:="I"
ElseIf cAlias == "EE9"
   Work->WKPREEMB :=EEC->EEC_PREEMB
   Work->WKRE     :=EE9->EE9_RE
   Work->WKDTRE   :=EE9->EE9_DTRE
   Work->WKVL_AC  :=EE9->EE9_VL_AC
   Work->WKQT_AC :=If(EE9->EE9_UNIDAD = ED3->ED3_UMPROD, EE9->EE9_SLDINI, AVTransUnid(EE9->EE9_UNIDAD,ED3->ED3_UMPROD,EE9->EE9_COD_I,EE9->EE9_SLDINI))
   Work->WKQTACCO:=If(EE9->EE9_UNIDAD = ED3->ED3_UMNCM, EE9->EE9_SLDINI, AVTransUnid(EE9->EE9_UNIDAD,ED3->ED3_UMNCM,EE9->EE9_COD_I,EE9->EE9_SLDINI))
   Work->WKCOBPLI:=If(EEC->EEC_COBCAM == "1",STR0032, STR0033)  //Sim###"Nao"
   If Empty(ED3->ED3_PROD)
      Work->WKCOBPRO :=EE9->EE9_COD_I
      Work->WKMENSA  :=cObserva
   Else
      Work->WKMENSA  :=cObserva
   Endif
   Work->WKIM_EXP:="E"
EndIf

Return .T.

*------------------------------*
Static Function EDCSAGERADBF()
*------------------------------*
Local oDlg, nOp:=0, oCbx, lRet:= .T.
Private cGera:=Space(1), aGera:={"1 - Sim","2 - Não"}

DEFINE MSDIALOG oDlg TITLE STR0096; //"Geração de Arquivo DBF/TXT"
       FROM 12,05 To 20,45 OF GetwndDefault()

   @01,04 SAY STR0097 of oDlg //"Gera Arquivo"
   cGera := "1"
   @01,09 ComboBox oCbx Var cGera Items aGera Valid (!Empty(cGera)) SIZE 52,08 of oDlg

   DEFINE SBUTTON FROM 40,45 TYPE 13 ACTION (nOp:=1,oDlg:End()) ENABLE OF oDlg //Salvar Arq.
   DEFINE SBUTTON FROM 40,80 TYPE 2 ACTION (nOp:=0,oDlg:End()) ENABLE OF oDlg  //Cancelar

ACTIVATE MSDIALOG oDlg CENTERED

If nOp = 1 .And. Left(cGera,1)=="1"
   TR350ARQUIVO("Work")
Else
   lRet:= .F.
EndIf

Return lRet


*-------------------------*
STATIC FUNCTION SA150EDH()
*-------------------------*

If nLIn >= 55
   Cabec(TituloRel,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   nLin := 09
Endif

If cModal == "1"
   @ nLin,00 Psay STR0119//  "                         Tp Ocorre.       Dt. Ocorre.   Cod. Ocorre.    Qtd. NCM        Qtd. Item       Vl. Ocorre. US$      Processo        Invoice         Nr. DI         Dt. DI         Nr. PLI            Nr. LI         "
   nLin := nLin +1
   @ nLin,00 Psay STR0120//  "                     ================== =============== ============ ================= =============== ================= ================= =============== ============ =============== =============== ====================="
EndIf

Return .T.
