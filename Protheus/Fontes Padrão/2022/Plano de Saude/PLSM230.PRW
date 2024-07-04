
#include "PLSMGER.CH"

STATIC cPerg := "PLS230"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSM230 ³ Autor ³ Tulio Cesar          ³ Data ³ 28.08.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analisa titulos gerados de CO/FM possiveis inconsistencias ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSM230
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aSays     := {}
LOCAL aButtons  := {}
LOCAL cCadastro := "Analise de Faturas de CO/VD"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta texto para janela de processamento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aSays,"Analise de Faturas de CO/VD")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botoes para janela de processamento                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|| MsAguarde({|| PLSM230Pro()}, "", "Processando...", .T.),FechaBatch() }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe janela de processamento                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FormBatch( cCadastro, aSays, aButtons,, 160 )

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSM230PRO³ Autor ³ Tulio Cesar         ³ Data ³ 28.08.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analisa titulos gerados de CO/FM possiveis inconsistencias ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSM230PRO()
LOCAL nTotal    := 0
LOCAL nBDH      := 0
LOCAL aCriticas := {}
LOCAL cNameBDH  := RetSQLName("BDH")
LOCAL cNameBD6  := RetSQLName("BD6")
LOCAL cTituloDe
LOCAL cTituloAte
LOCAL cKeyTit	:= ''
LOCAL bCpoBDH	:= {|| 	BDH->(FieldPos("BDH_VLRCP3")) > 0 .and. BDH->(FieldPos("BDH_VLRCP4")) > 0 .and.;
						BDH->(FieldPos("BDH_VLRCP5")) > 0 .and. BDH->(FieldPos("BDH_VLRCP6")) > 0 .and.;
						BDH->(FieldPos("BDH_VLRCP7")) > 0 .and. BDH->(FieldPos("BDH_VLRCP8")) > 0 .and.;
						BDH->(FieldPos("BDH_VLRCP9")) > 0 .and. BDH->(FieldPos("BDH_VLRCPA")) > 0 .and.;
						BDH->(FieldPos("BDH_VLRCPB")) > 0 .and. BDH->(FieldPos("BDH_VLRCPC")) > 0 }

LOCAL lCpoBDH := Eval(bCpoBDH)

Pergunte(cPerg,.F. )
cTituloDe  := mv_par01
cTituloAte := mv_par02

cSQL := "SELECT "
cSQL += "R_E_C_N_O_ AS REG "
cSQL += " FROM "+cNameBDH+ " BDH "
cSQL += " WHERE "
cSQL += "BDH_FILIAL = '"+xFilial("BDH")+"' AND "
cSQL += "BDH_PREFIX+BDH_NUMTIT+BDH_PARCEL+BDH_TIPTIT >= '"+cTituloDe+"' AND BDH_PREFIX+BDH_NUMTIT+BDH_PARCEL+BDH_TIPTIT <= '"+cTituloAte+"' AND "
cSQL += "BDH.D_E_L_E_T_ = '' "

PLSQuery(cSQL,"Trb")

While ! Trb->(Eof())
	
	BDH->(DbGoTo(Trb->REG))
	
	cKeyTit := BDH->(BDH_PREFIX+BDH_NUMTIT+BDH_PARCEL+BDH_NUMTIT)
	If ! Empty(cKeyTit)
		MsProcTXT("Analisando Fatura "+cKeyTit+" ...")
	Else
		MsProcTXT("Analisando Consolidacao usuario "+BDH->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG)+" ...")
	Endif
	ProcessMessage()
	
	If lCpoBDH	
		nBDH := BDH->(	BDH_VLRCOP+BDH_VALOR+BDH_VLRTAX+BDH_VALCPF+BDH_VALCOF+BDH_VALTCF+BDH_VLRCP2+BDH_VLRCP3+;
						BDH_VLRCP4+BDH_VLRCP5+BDH_VLRCP6+BDH_VLRCP7+BDH_VLRCP8+BDH_VLRCP9+BDH_VLRCPA+BDH_VLRCPB+;
						BDH_VLRCPC+BDH_VALOR1+BDH_VALOR2+BDH_VALOR3+BDH_VALOR4+BDH_VALOR5+BDH_VALOR6+BDH_VALOR7+;
						BDH_VALOR8+BDH_VALOR9)
	Else
		nBDH := BDH->(	BDH_VLRCOP+BDH_VLRCP2+BDH_VALOR+BDH_VLRTAX+BDH_VALCPF+BDH_VALCOF+BDH_VALTCF)
						
	Endif		
	
	cSQL := "SELECT BD6_VLRTPF AS VALOR FROM "+cNameBD6+" WHERE "
	cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
	cSQL += "BD6_OPEUSR = '"+BDH->BDH_CODINT+"' AND "
	cSQL += "BD6_CODEMP = '"+BDH->BDH_CODEMP+"' AND "
	cSQL += "BD6_MATRIC = '"+BDH->BDH_MATRIC+"' AND "
	cSQL += "BD6_TIPREG = '"+BDH->BDH_TIPREG+"' AND "
	cSQL += "BD6_ANOPAG = '"+BDH->BDH_ANOFT+"' AND "
	cSQL += "BD6_MESPAG = '"+BDH->BDH_MESFT+"' AND "
	cSQL += "BD6_SEQPF  = '"+BDH->BDH_SEQPF+"' AND "
	cSQL += "( BD6_FASE = '3' OR BD6_FASE = '4' ) AND BD6_SITUAC = '1' AND BD6_BLOCPA <> '1' AND "
	cSQL += "D_E_L_E_T_ = ' '"
	
	PLSquery(cSQL,"Trb2")
	
	nTotal := 0
	While ! Trb2->(Eof())
		nTotal += VALOR
		Trb2->(DbSkip())
	Enddo
	Trb2->(DbCloseArea())
	
	If abs((nTotal-nBDH)) > 0.05
		
		cSQL := "SELECT R_E_C_N_O_ AS REG, "+cNameBD6+".* FROM "+cNameBD6+" WHERE "
		cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
		cSQL += "BD6_OPEUSR = '"+BDH->BDH_CODINT+"' AND "
		cSQL += "BD6_CODEMP = '"+BDH->BDH_CODEMP+"' AND "
		cSQL += "BD6_MATRIC = '"+BDH->BDH_MATRIC+"' AND "
		cSQL += "BD6_TIPREG = '"+BDH->BDH_TIPREG+"' AND "
		cSQL += "BD6_ANOPAG = '"+BDH->BDH_ANOFT+"' AND "
		cSQL += "BD6_MESPAG = '"+BDH->BDH_MESFT+"' AND "
		cSQL += "BD6_SEQPF  = '"+BDH->BDH_SEQPF+"' AND "
		cSQL += "( BD6_FASE = '3' OR BD6_FASE = '4' ) AND BD6_SITUAC = '1' AND BD6_BLOCPA <> '1' AND "
		cSQL += "D_E_L_E_T_ = ' '"
		
		PLSquery(cSQL,"Trb2")
		
		cMatric := Trb2->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG)
		
		If lCpoBDH
			nTotBDH := BDH->(BDH_VLRCOP+BDH_VALOR+BDH_VLRTAX+BDH_VALCPF+BDH_VALCOF+BDH_VALTCF+BDH_VLRCP2+;
					BDH_VLRCP3+BDH_VLRCP4+BDH_VLRCP5+BDH_VLRCP6+BDH_VLRCP7+BDH_VLRCP8+BDH_VLRCP9+;
					BDH_VLRCPA+BDH_VLRCPB+BDH_VLRCPC+BDH_VALOR1+BDH_VALOR2+BDH_VALOR3+BDH_VALOR4+;
					BDH_VALOR5+BDH_VALOR6+BDH_VALOR7+BDH_VALOR8+BDH_VALOR9)
		Else
			nTotBDH := BDH->(	BDH_VLRCOP+BDH_VLRCP2+BDH_VALOR+BDH_VLRTAX+BDH_VALCPF+BDH_VALCOF+BDH_VALTCF)
		
		Endif	
		
		While ! Trb2->(Eof())
			
			nTotBD6 := 0
			While Trb2->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG) == cMatric
				
				BD5->(DbSetOrder(1))
				BD5->(MsSeek(xFilial("BD5")+Trb2->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))
				
				nTotBD6 += Trb2->BD6_VLRTPF
				aadd(aCriticas,{Trb2->(BD6_CODLDP+"-"+BD6_CODPEG+"-"+BD6_NUMERO+"-"+BD6_SEQUEN),;
					Trb2->BD6_VLRTPF,;
					Trb2->BD6_VLRBPF,;
					Trb2->BD6_VLRTAD,;
					Trb2->BD6_SITUAC,;
					Trb2->BD6_FASE,;
					Trb2->BD6_BLOCPA,;
					Trb2->BD6_VLRTPF-Trb2->(BD6_VLRBPF+BD6_VLRTAD),;
					Trb2->BD6_SEQPF,;
					Trb2->(BD6_ANOPAG+"-"+BD6_MESPAG),;
					BDH->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG),;
					BDH->(BDH_ANOFT+"-"+BDH_MESFT),;
					BDH->BDH_SEQPF,;
					BDH->(Recno()),;
					cKeyTit,;
					BDH->BDH_NUMFAT,;
					0,;
					0,;
					0,;
					BD5->(Found()),;
					Trb2->REG,;
					BDH->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG)})
					
					Trb2->(DbSkip())
				
				If cMatric <> Trb2->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG)
					aCriticas[Len(aCriticas),17] := nTotBD6
					aCriticas[Len(aCriticas),18] := nTotBDH
					aCriticas[Len(aCriticas),19] := nTotBD6-nTotBDH
				Endif
			Enddo
		Enddo
		Trb2->(DbCloseArea())
		
	Endif
	
	Trb->(DbSkip())
Enddo

Trb->(DbCloseArea())

If Len(aCriticas) > 0
   PLSCRIGEN(aCriticas,{ {"Evento","@C",100} , {"VLRTPF","@E 999,999.99",040 } , {"VLRBPF","@E 999,999.99",040 }, {"VLRTAD","@E 999,999.99",040 } , {"SITUAC","@!",040 }, {"FASE","@!",040 }, {"BLOPAG","@!",040 } , {"DIF BD6","@E 999,999.999",040 } ,{"SEQPF","@!",040 }, {"ANO/MES PF","@!",040 },{"MATRIC BDH","@!",100 },{"ANO/MES BDH","@!",100 } ,{"SEQPF BDH","@!",100 },{"Recno BDH","99999999",100 },{"Numero SE1 BDH","@!",100 },{"Numero Fat BDH","@!",100 },{"BD6 Tot","@E 999,999.99",040 },{"BDH TOT","@E 999,999.99",040 },{"DIF","@E 999,999.99",040 } ,{"Found","@!",040 }, {"Recno BD6","9999999",040 },{"Usuario","@!",080 }},"Resumo")
Else
   MsgStop("Analise concluida. Nao foram encontradas inconsistencias.")
Endif

Return