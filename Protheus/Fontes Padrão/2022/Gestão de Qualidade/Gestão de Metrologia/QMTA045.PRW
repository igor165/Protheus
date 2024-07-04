#INCLUDE "QMTA045.CH"
#Include "PROTHEUS.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QMTA045	  ³ Autor ³ Wanderley Gon‡alves   ³ Data ³ 07/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Duplica Escalas      					  					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAQMT				                 						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QMTA045
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local bCRepQM9,bCRepQMC,bCRepQMA,bCRepQMH	// Atribuicao no replace
Local bCConQM9,bCConQMC,bCConQMA,bCConQMH	// Condicao para o replace
Local aArq				// Array de arquivos para duplicacao
Local lVolta			// 
Local nRec
Local nCntFor
Private lUpper := .F.
Private aRotina:={ {OemToAnsi(STR0003), "AllwaysTrue",0,3}} // "Duplica‡„o de Escala"
//BOPS JJ - Verificar se existe picture cadastrada no SX3 para surgerir na duplicacao somente letras maiusculas...
If Alltrim(GetSx3Cache("QM9_ESCALA","X3_PICTURE")) == "@!"
	lUpper := .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros						  	³
//³ mv_par01				// Origem								³
//³ mv_par02				// Revisao Origem 						³
//³ mv_par03				// Destino								³
//³ mv_par04				// Revisao Destino						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Do while .t.

	If Pergunte("QMA045",.T.)

		QM9->( dbSetOrder(1) )
		If QM9->(DbSeek(xFilial('QM9')+mv_par01+Inverte(mv_par02)))
			If Alltrim(Upper(mv_par01)) == Alltrim(Upper(mv_par03)) .and. Val(mv_par02) > Val(mv_par04)
				MessageDlg(STR0002,,3) //"Nao e permitido gerar revisao anterior dessa escala"
				Return .F.
			Endif
			nRec := QM9->(recno())
			If QM9->(DbSeek(xFilial('QM9')+mv_par03+Inverte(mv_par04)))
				Help(" ",1,"A045EXIREV") // Esta escala/revisao ja esta cadastrada.
				Return(Nil)
			EndIf
			QM9->(DbGoto(nRec))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa Array 										  	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aArq	  := {}

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Condicoes para QM9											 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			bCrepQM9:= { || QM9->QM9_ESCALA  := mv_par03 ,;
								 QM9->QM9_REVESC	:= mv_par04 ,;
								 QM9->QM9_REVINV  := Inverte(QM9->QM9_REVESC),;
								 QM9->QM9_DATREV  := dDataBase }
			bCconQM9 := { || ! eof() .and. xFilial('QM9') == QM9_FILIAL .and.;
												  QM9_ESCALA == mv_par01 .and.;
												  QM9_REVESC == mv_par02 }
			aadd( aArq, { 'QM9', mv_par01+Inverte(mv_par02), bCRepQM9, bCConQM9, 1 } ) 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Condicoes para QMC											 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			bCrepQMC:= { || QMC->QMC_ESCALA	:= mv_par03 ,;
								 QMC->QMC_REVESC	:= mv_par04 ,;
								 QMC->QMC_REVINV  := Inverte(mv_par04) }

			bCconQMC := { || ! eof() .and. xFilial('QMC') == QMC_FILIAL .and.;
												  QMC_ESCALA == mv_par01 .and.;
												  QMC_REVESC == mv_par02 }
			aadd( aArq, { 'QMC', mv_par01+Inverte(mv_par02), bCRepQMC, bCConQMC, 1 } ) 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Condicoes para QMA											 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			bCrepQMA:= { || QMA->QMA_ESCALA	:= mv_par03 ,;
								 QMA->QMA_REVESC	:= mv_par04 } 
			bCconQMA := { || ! eof() .and. xFilial('QMA') == QMA_FILIAL .and.;
												  QMA_ESCALA == mv_par01 .and.;
												  QMA_REVESC == mv_par02 }
			aadd( aArq, { 'QMA', mv_par01+mv_par02, bCRepQMA, bCConQMA, 1 } ) 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Condicoes para QMH (somente sera duplicado se as escalas fo- ³
			//³ rem diferentes (nao existe revisao para esta amarracao)      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par01 <> mv_par03
				bCrepQMH:= { || QMH->QMH_ESCALA	:= mv_par03 }
				bCconQMH := { || ! eof() .and. xFilial('QMH') == QMH_FILIAL .and.;
													  QMH_ESCALA == mv_par01 }
				aadd( aArq, { 'QMH', mv_par01, bCRepQMH, bCConQMH, 1 } ) 
			EndIf


			for nCntFor := 1 to len(aArq)
				dbselectar(aArq[nCntFor,1])
				dbSetOrder(aArq[nCntFor,5])
				dbseek(xFilial()+aArq[nCntFor,2])
				do while eval(aArq[nCntFor,4])
					lVolta := .t.
					if QA_Dupl(lVolta, aArq[nCntFor,3], aArq[nCntFor,1])
						skip
					else
						exit
					endif
				enddo
			next

		EndIf
		MsgInfo( OemToAnsi(STR0004), OemToAnsi(STR0005) )// "Duplica‡„o Conclu¡da!!!" ### "Duplica‡„o de Escalas"
	Else
		Exit
	EndIf  
EndDo

Return(Nil)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A045UpIns  ³ Autor ³ Wanderley Gon‡alves	  ³ Data ³ 29/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se Campo Escala nao esta vazio                 		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X1_VALID do Grupo QMA045 e Ordem 1							³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A045UpIns()

Local lret := .f.

If naovazio()
	If lUpper 
		mv_par01 := Upper(mv_par01)
	Endif	
	//Sugere ultima revisao da escala origem
	dbSelectArea("QM9")
	dbSetOrder(1)
	If dbSeek(xFilial()+mv_par01)
		mv_par02 := QM9->QM9_REVESC
		lRet := .T.		
	Else
		lRet := .F.
		MSGALERT(OemToAnsi(STR0006))
	Endif	
Else
	lRet := .F.
EndIf

Return(lRet)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A045ExIns  ³ Autor ³ Wanderley Gon‡alves	  ³ Data ³ 20/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se Escala existe para duplicacao				    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X1_VALID do Grupo QMA045 e Ordem 2 e Ordem 4 				³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A045ExIns(cPErg)

Local cChave
If cPerg == "O"  // Instrumento Origem
	If !Isdigit(mv_par02)
		Return(.F.)
	EndIf
	dbSelectArea("QM9") 
	dbSeek(xFilial()+mv_par01)
	mv_par02 := QM9->QM9_REVESC
	cChave := mv_par01 + Inverte(mv_par02)
Else
	If !Isdigit(mv_par04) 
		Return(.F.)
	EndIf
	cChave := mv_par03 + Inverte(mv_par04)
EndIf

If naovazio()
	//Localiza a ultima revisao do instrumento Para
	dbSelectArea("QM9")
	dbSetOrder(1)
	If dbSeek(xFilial()+mv_par03)	
		//Compara com a ultima encontrada..	
		If Val(QM9->QM9_REVESC) > Val(mv_par04)
			Return(.T.)
		Endif
	Endif

	QM9->(DbsetOrder(1))

	If QM9->(DbSeek(xFilial('QM9') + cChave ))
		Return(.T.)
	EndIf

EndIf

Return(.F.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A045CkIns  ³ Autor ³ Wanderley Gon‡alves	  ³ Data ³ 20/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se Instrumento esta cadastrado para sugerir versao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X1_VALID do Grupo QMA045 e Ordem 3						    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A045CkIns()
Local nRec := 0

//BOPS JJ
If lUpper
	mv_par03 := Upper(mv_par03)
Endif	
If naovazio()
	nRec := QM9->(recno())
	QM9->(DbsetOrder(1))
	If QM9->(DbSeek(xFilial('QM9') + mv_par03))
		mv_par04 := StrZero(Val(QM9->QM9_REVESC)+1,2)
	Else
		mv_par04 := "00"		
	EndIf
Else
	Return .f.
EndIf
Return(.T.)
