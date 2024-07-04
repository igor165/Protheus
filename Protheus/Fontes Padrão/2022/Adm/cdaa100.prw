#include "Protheus.ch"
#include "cdaa100.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CDAA100  ³ Autor ³ Edson Maricate        ³ Data ³ 29/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Refaz acumulados                                           ³±±
±±³          ³ Este programa refaz o saldo acumulado do adiantamento      ³±±
±±³          ³ no contrato do direito a partir da ultima prestação de     ³±±
±±³          ³ contas do autor.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACDA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CDAA100
Local nOpca	:= 0
Private cCadastro := STR0001 //"Refaz Acumulados do Contrato"


aSays := {}
	
AADD(aSays, STR0002) //"  Este programa ira refazer os valores acumulados dos contratos de"
AADD(aSays, STR0003) //"direitos autorais bem como os seus saldos baseado nos adiantamentos"
AADD(aSays, STR0004) //"efetuados ao autor e no calculo do DA a partir da ultima prestação" 
AADD(aSays, STR0005) //"de contas."

aButtons := {}

AADD(aButtons, { 1,.T.,{|| nOpca:= 1, FechaBatch() }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a tela de processamento.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FormBatch( cCadastro, aSays, aButtons ,,220,428)
	
If (nOpca == 1)
	If MsgYesNo(STR0006) //"Confirma processamento Refaz Acumulados do Contrato ?"
		Processa( {|lEnd| CDA100Proc()} ) 
	EndIf
EndIf

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CDA100Proc³Autor ³ Edson Maricate        ³ Data ³ 29/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Refaz acumulados                                           ³±±
±±³          ³ Este programa refaz o saldo acumulado do adiantamento      ³±±
±±³          ³ no contrato do direito a partir da ultima prestação de     ³±±
±±³          ³ contas do autor.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACDA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CDA100Proc()

ProcRegua( AH1->(RecCount()) )

dbSelectArea("AH1")
dbSeek(xFilial())
While !Eof() .And. AH1->AH1_FILIAL = xFilial("AH1")
	IncProc()
	dbSelectArea("AH4")
	dbSetOrder(3)
	If !Empty(AH1->AH1_DTULTP).And. dbSeek(xFilial("AH4")+AH1->AH1_PRODUT+AH1->AH1_FORNEC+AH1->AH1_LOJAFO+DTOS(AH1->AH1_DTULTP))
		cMdaRoy := AllTrim(Str(AH1->AH1_MOEDRO,2))
		cMdaOri := Iif(AH1->AH1_MOEDA == "1","1",GetMv("MV_MCUSTO"))
		nValAdi := 0
		nQtdAdi	:= 0
		nValAcum:= 0
		nQtdAcum:= 0
		nQtdTot	:= 0
		nTotAdi	:= 0

		dbSelectArea("AH5")
		dbSetOrder(3)
		dbSeek( xFilial() + AH1->AH1_PRODUT+AH1->AH1_FORNEC+AH1->AH1_LOJAFO )
		While AH5->(!Eof()) .And. xFilial() + AH1->AH1_PRODUT+AH1->AH1_FORNEC+AH1->AH1_LOJAFO == ;
			AH5->AH5_FILIAL + AH5->AH5_PRODUT + AH5->AH5_FORNEC + AH5->AH5_LOJAFO 
			If  AH5->AH5_DTPRES == AH1->AH1_DTULTP 
				nQtdAcum += AH5->AH5_QTDACU
				If AH5->AH5_PERCDA == 0.00 .Or. AH1->AH1_MOEDRO == 1
					nValAcum += AH5->AH5_VALORD
				Else
					nValAcum += Round(xMoeda(AH5->AH5_VALORD,Val(cMdaOri),Val(cMdaRoy),AH4->AH4_DTPREST),2)
				Endif
			EndIf
			nQtdTot += AH5->AH5_QTDACU
			dbSelectArea("AH5")
			dbSkip()
		End
		
		nValAcum := Round(nValAcum,2)

		dbSelectArea("AH3")
		dbSetOrder(1)
		dbSeek( xFilial() + AH1->AH1_PRODUT+AH1->AH1_FORNEC+AH1->AH1_LOJAFO )
		While AH3->(!Eof()) .And. xFilial() + AH1->AH1_PRODUT+AH1->AH1_FORNEC+AH1->AH1_LOJAFO == ;
			AH3->AH3_FILIAL + AH3->AH3_PRODUT + AH3->AH3_FORNEC + AH3->AH3_LOJAFO 

			If AH3->AH3_TIPOMO == "1"
				nSalAdi := 0
				nQtdSal	:= 0
				nTotAdi	+= AH3->AH3_VALOR
				If AH3->AH3_TIPOPA <> "1"    // Valor
					nSalAdi := AH3->AH3_VALOR
				ElseIf AH3->AH3_TIPOPA == "1"
					nQtdSal	:= AH3->AH3_EXEMPL
				EndIf

				dbSelectArea("AH5")
				dbSetOrder(3)
				dbSeek( xFilial() + AH3->AH3_PRODUT+AH3->AH3_FORNEC+AH3->AH3_LOJAFO )
				While AH5->(!Eof()) .And. xFilial() + AH3->AH3_PRODUT+AH3->AH3_FORNEC+AH3->AH3_LOJAFO == ;
					AH5->AH5_FILIAL + AH5->AH5_PRODUT + AH5->AH5_FORNEC + AH5->AH5_LOJAFO 
					If  AH5->AH5_DTPRES > AH3->AH3_DATA
						nQtdSal -= AH5->AH5_QTDACU
						If AH5->AH5_PERCDA == 0.00 .Or. AH1->AH1_MOEDRO == 1
							nSalAdi -= AH5->AH5_VALORD
						Else
							nSalAdi -= Round(xMoeda(AH5->AH5_VALORD,Val(cMdaOri),Val(cMdaRoy),AH4->AH4_DTPREST),2)
						Endif
					EndIf
					If nSalAdi <= 0 .And. nQtdSal <= 0 
						Exit
					EndIf
					dbSelectArea("AH5")
					dbSkip()
				End
		
				nValAdi += Max(Round(nSalAdi,2),0)
				nQtdAdi	+= Max(nQtdSal,0)

			EndIf
			dbSelectArea("AH3")
			dbSkip()
		End

//		If nValAcum > 0
//			nSaldo := nValAdi - nValAcum
//		Else
//			nSaldo := nValAdi
//		Endif
		
//		If nQtdAcum > 0
//			nSalQtd := nQtdAdi - nQtdAcum
//		Else
//			nSalQtd := nQtdAdi
//		Endif
		
		RecLock("AH1",.F.)
		Replace AH1_SALDOA With nValAdi
		Replace AH1_SALDQT With nQtdAdi
		Replace AH1_VALADI With nTotAdi
		Replace AH1_QTDEVD With nQtdTot
		MsUnlock()

		dbSelectArea("AH4")
		dbSetOrder(3)
		dbSeek( xFilial() + AH1->AH1_PRODUT+AH1->AH1_FORNEC+AH1->AH1_LOJAFO+DTOS(AH1->AH1_DTULTP) )
		While AH4->(!Eof()) .And. xFilial() + AH1->AH1_PRODUT+AH1->AH1_FORNEC+AH1->AH1_LOJAFO == ;
			AH4->AH4_FILIAL + AH4->AH4_PRODUT + AH4->AH4_FORNEC + AH4->AH4_LOJAFO
			If AH4->AH4_DTPRES > AH1->AH1_DTULTP
				RecLock("AH4",.F.)
				Replace AH4_VALADI With AH1->AH1_SALDOA
				Replace AH4_QTDADI With AH1->AH1_SALDQT
				MsUnlock()
			EndIf
			dbSelectArea("AH4")
			dbSkip()
		End

		
	EndIf
	dbSelectArea("AH1")
	dbSkip()
End



Return 