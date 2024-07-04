#INCLUDE "QMTA020.CH"
#Include "PROTHEUS.CH"
#define Confirma 1
#define Redigita 2
#define Abandona 3


/*                                                                          
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QMTA020	  ³ Autor ³ Wanderley Gon‡alves   ³ Data ³ 19/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Duplica Instrumentos 					  					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAQMT				                 						³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QMTA020
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis 														  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local bCRepQM2,bCRepQA2H,bCRepQA2I,bCRepQMG	// Atribuicao no replace
Local bCConQM2,bCConQA2H,bCConQA2I,bCConQMG	// Condicao para o replace
Local aArq				// Array de arquivos para duplicacao
Local lVolta			// 
Local cEspecI, cEspecH // Especie	 
//Local cKeyNewI, cKeyNewH	// Chaves com o novo produto para gravacao
Local cKeyNew
Local nRec
Local nCntFor
Local cMemo
Local cChave := "00"
Local cIndice :=""
Local lCompInst := ExistBlock("CompInst")
Private aRotina:={ {OemToAnsi(STR0003), "AllwaysTrue",0,3}} // "Duplica‡„o de Instrumento"
Private cRev := '' 
Private cTpMov		:= GetMV("MV_QMTPMOV", .F., "1") // 1 = Mov Tipo 1 / 2 = Mov Tipo 2
Private lQMovIns 	:= .F. 
Private lGerou      :=.T.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros							³
//³ mv_par01				// Origem								³
//³ mv_par02				// Revisao Origem 						³
//³ mv_par03				// Destino								³
//³ mv_par04				// Revisao Destino						³
//³ mv_par05				// Duplica Historico do Instrumento		³
//³ mv_par06				// Duplica Inf. Complementares do Instr.³
//³ mv_par07				// Altera Responsavel do Instrumento	³
//³ mv_par08				// Altera Departamento do Instrumento	³
//³ mv_par09				// Altera Localizacao					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cTpMov == "2"
	If ChkFile("QN5")
		lQMovIns := .T.
	Endif
EndIf
Do while .t.
	If Pergunte("QMA020",.T.)
		QM2->( dbSetOrder(1) )
		If QM2->(DbSeek(xFilial('QM2')+mv_par01+Inverte(mv_par02)))   		
			nRec := QM2->(recno())
			If QM2->(DbSeek(xFilial('QM2')+mv_par03+Inverte(mv_par04)))
				Help(" ",1,"A020EXIREV")
				Return(Nil)
			EndIf
			If mv_par01 == mv_par03 .and. !a020GetJu(@cMemo)
				Loop
			EndIf		
			QM2->(DbGoto(nRec))                                      			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava campo QM2_FLAG, utilizado no filtro de movimentacao de instrumentos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par04 <> "00"
			dbSelectArea("QM2")
			If dbSeek(xFilial("QM2")+mv_par03)
					Do While QM2->(!Eof()) .and. QM2->QM2_INSTR == mv_par03
						If QM2->QM2_REVINS <> mv_par04
   							cChave := QM2->QM2_REVINS   
   							Exit
						Endif
						QM2->(dbSkip())
					Enddo					
				Endif
			Endif	                             
			dbSelectArea("QM2")
			dbSetOrder(01)
			If dbSeek(xFilial("QM2")+mv_par03+Inverte(cChave))
				RecLock("QM2",.F.)
				Replace QM2->QM2_FLAG with "2"
				MsUnlock()
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa Array 														  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aArq := {}

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Condicoes para QA2 - Historico										  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria chave   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cKeyNew := QM2->QM2_FILIAL + mv_par03 + mv_par04   //+'HIST'
			cKeyNew := QA_CvKey(cKeyNew,"QM2",6)
			dbSelectArea("QM2")
			dbGoTo(nRec)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Condicoes para QM2														  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			bCrepQM2:= { || QM2->QM2_INSTR	:= mv_par03 ,;
				 QM2->QM2_REVINS  := mv_par04 ,;
				 QM2->QM2_REVINV  := Inverte(QM2->QM2_REVINS),;
				 QM2->QM2_DATREV  := dDataBase,;
				 QM2->QM2_CHAVE   := cKeyNew,; 
				 QM2->QM2_FLAG    := "1"} // Nova chave criada para acesso aos textos

			bCconQM2 := { || ! eof() .and. xFilial('QM2') == QM2_FILIAL .and.;
												  QM2_INSTR == mv_par01 .and.;
												  QM2_REVINS == mv_par02 }
			aadd( aArq, { 'QM2', mv_par01+Inverte(mv_par02), bCRepQM2, bCConQM2, 1 } ) 


			If mv_par05 == 1 //Duplica Historico ?
				cKeyH 	:= QM2->QM2_CHAVE   //QA_CvKey(cKeyH)
				cEspecH := 'QMTA010H'

				bCRepQA2H := { || QA2->QA2_CHAVE   := cKeyNew }
				bCConQA2H := { || ! eof() .and. xFilial('QA2') == QA2_FILIAL .and.;
													  QA2_CHAVE == cKeyh .and.;
													  QA2_ESPEC == cEspecH }

				aadd( aArq, { 'QA2', cEspecH+cKeyH, bCRepQA2H, bCConQA2H, 1 } )
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chave para QA2 - Informa‡äes Complementares 					  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par06 == 1 //Duplica Informacoes Complementares?
				cKeyI 	:= QM2->QM2_CHAVE    //QA_CvKey(cKeyI)
				cEspecI := 'QMTA010I'
				bCRepQA2I := { || QA2->QA2_CHAVE   := cKeyNew }
				bCConQA2I := { || ! eof() .and. xFilial('QA2') == QA2_FILIAL .and.;
													  QA2_CHAVE == cKeyI .and.;
													  QA2_ESPEC == cEspecI }

				aadd( aArq, { 'QA2', cEspecI+cKeyI, bCRepQA2I, bCConQA2I, 1 } )

    		Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Condicoes para QMG														  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			bCrepQMG:= { || QMG->QMG_INSTR	:= mv_par03 ,;
								 QMG->QMG_REVINS	:= mv_par04 } 
			bCconQMG := { || ! eof() .and. xFilial('QMG') == QMG_FILIAL .and.;
												  QMG_INSTR == mv_par01 .and.;
												  QMG_REVINS == mv_par02 }
			aadd( aArq, { 'QMG', mv_par01+mv_par02, bCRepQMG, bCConQMG, 1 } ) 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Condicoes para QMR														  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			bCrepQMR:= { || QMR->QMR_INSTR	:= mv_par03 ,;
								 QMR->QMR_REVINS	:= mv_par04 } 
			bCconQMR := { || ! eof() .and. xFilial('QMR') == QMR_FILIAL .and.;
												  QMR_INSTR == mv_par01 .and.;
												  QMR_REVINS == mv_par02 }
			aadd( aArq, { 'QMR', mv_par01+mv_par02, bCRepQMR, bCConQMR, 1 } ) 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera campos LAUDO, USOINI e VALDAF, para instrumento ori-  ³
			//³ gem <> instrumento destino                                	  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			A020ValIns()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Efetiva gravacao   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Begin Transaction
			for nCntFor := 1 to len(aArq)
				dbSelectarea(aArq[nCntFor,1])
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

			If !Empty(mv_par07)
				dbSelectArea("QM2")
				dbSetOrder(01)
				If dbSeek(xFilial("QM2")+mv_par03+inverte(mv_par04))
					RecLock("QM2",.f.)
					Replace QM2->QM2_RESP with mv_par07   
					Replace QM2->QM2_FILRES with cFilAnt
					MsUnLock()
				Endif	
			Endif
			
			If !Empty(mv_par08)
				dbSelectArea("QM2")
				dbSetOrder(01)
				If dbSeek(xFilial("QM2")+mv_par03+inverte(mv_par04))
					RecLock("QM2",.f.)
					Replace QM2->QM2_DEPTO with mv_par08  
					MsUnLock()			
				Endif	
			Endif

			If !Empty(mv_par09)
				dbSelectArea("QM2")
				dbSetOrder(01)
				If dbSeek(xFilial("QM2")+mv_par03+inverte(mv_par04))
					RecLock("QM2",.f.)
					Replace QM2->QM2_LOCAL with mv_par09  
					MsUnLock()			
				Endif	
			Endif
			A020GvJu(cMemo,cKeyNew)
			
			If lQMovIns
				If Alltrim(Upper(mv_par01)) ==Alltrim(Upper(mv_par03))
					cIndice := CriaTrab(NIL,.F.)
					cChvQET := "QN5->QN5_INSTR+QN5->QN5_REVINS"
					cQuery  := "QN5->QN5_INSTR=='"+mv_par01+"'.And."
					cQuery  += "QN5->QN5_REVINS =='"+mv_par02+"'"
					
					IndRegua("QN5",cIndice,cChvQET,,cQuery,STR0012) // Selecionando Registros. . .
					nIndice := RetIndex("QN5")
					dbSetOrder(nIndice+1)
					If DbSeek(mv_par01+mv_par02)       //mv_par04
						Reclock("QN5",.F.)
						QN5->QN5_REVINS:=mv_par04
						MsUnlock()

						Ferase(cIndice + OrdBagExt())
						cIndice := CriaTrab(NIL,.F.)
						cChvQET := "QN4->QN4_INSTR+QN4->QN4_REVINS"
						cQuery  := "QN4->QN4_INSTR=='"+mv_par01+"'.And."
						cQuery  += "QN4->QN4_REVINS =='"+mv_par02+"'"
						
						IndRegua("QN4",cIndice,cChvQET,,cQuery,STR0012) // Selecionando Registros. . .
						nIndice := RetIndex("QN4")
						dbSetOrder(nIndice+1)
						If DbSeek(mv_par01+mv_par02)
							while QN4->(!EOF()) .and. QN4->QN4_INSTR == MV_PAR01 
							IF QN4->QN4_ULTMOV<>"S"
							    QN4->(DbSkip())
							    Loop
							Else
								Reclock("QN4",.F.)
								QN4->QN4_REVINS:=mv_par04
								MsUnlock()
								QN4->(DbSkip())
							Endif
							Enddo
						Endif
						Ferase(cIndice + OrdBagExt())
					Else
						QMTAtuIDis(mv_par03,mv_par04,QAA->QAA_MAT,QAA->QAA_FILIAL,QAA->QAA_CC,QM2->QM2_TIPO,"I")	
					EndIf

				Else
					dbSelectArea("QAA")
					dbSetOrder(1)
					If QAA->(DbSeek(QM2->QM2_FILRES+QM2->QM2_RESP))
					      dbSelectArea("QM2")
					      dbSetOrder(1) 
					        If QM2->(DbSeek(xFilial("QM2")+mv_par03+Inverte(mv_par04)))
						         QMTAtuIDis(mv_par03,mv_par04,QM2->QM2_RESP,QM2->QM2_FILRES,QAA->QAA_CC,QM2->QM2_TIPO,"I")
					        EndIf
					Endif  
				EndIf
				
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Seta a revisao anterior do instrumento como inativa ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par01 == mv_par03
				QM2->(FKCOMMIT())
				
				QM2->(DbSetOrder(1)) // QM2_FILIAL+QM2_INSTR+QM2_REVINV
				If QM2->(Dbseek(xFilial("QM2")+mv_par01))
		    		QM2->(DbSkip())
					
					Reclock("QM2",.F.)
					QM2->QM2_STATUS = "I"
					QM2->(MsUnlock())
				EndIf
			EndIf
			
			End Transaction			
		EndIf                               

			If lCompInst
  				ExecBlock("CompInst",.F.,.F.,{mv_par03, mv_par04}) // instrumento+rev atual
   		    EndIf

		MsgInfo( OemToAnsi(STR0010)+RTrim(mv_par03)+" / "+OemToAnsi(STR0011)+mv_par04+" - "+OemToAnsi(STR0004), OemToAnsi(STR0005) ) // "Duplica‡„o Conclu¡da!!!" ### "Duplica‡„o de Instrumentos"
	Else
		Exit	
	EndIf  
EndDo

Return(Nil)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A020UpIns  ³ Autor ³ Wanderley Gon‡alves	  ³ Data ³ 29/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se Campo Instrumento nao esta vazio                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X1_VALID do Grupo QMA020 e Ordem 1						    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A020UpIns()

Local lret := .f.
cRev := ""
If naovazio()
	lRet := .t.
	//Busca e sugere a ultima revisao do instrumento origem, pois desta forma considera 
	//o ultimo texto e complemento do instrumento
	dbSelectArea("QM2")
	dbSetOrder(1)
	If dbSeek(xFilial()+mv_par01)
		If mv_par02 <> QM2->QM2_REVINS
		mv_par02 := QM2->QM2_REVINS
		Endif	
	Endif		
EndIf

Return(lRet)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A020ExIns  ³ Autor ³ Wanderley Gon‡alves	  ³ Data ³ 20/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se Instrumento existe para duplicacao			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X1_VALID do Grupo QMA020 e Ordem 2 e Ordem 4 				³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A020ExIns(cPErg)

Local cChave

If cPerg == "O"  // Instrumento Origem
	If mv_par01 == mv_par03
		dbSelectArea("QM2")
		dbSetOrder(1)
		If dbSeek(xFilial()+mv_par01)
			mv_par02 := QM2->QM2_REVINS
		Else
			mv_par02 := "00"
		Endif	
	Endif	
	cChave := mv_par01 + Inverte(mv_par02)
Else
	//Caso o instrumento destino nao exista, sugere revisao 00, caso contrario sugere a ultima
	dbSelectArea("QM2")
	dbSetOrder(1)
	If dbSeek(xFilial()+mv_par03) 
		mv_par04 := Soma1(QM2->QM2_REVINS)
	Else
		mv_par04 := StrZero(Val(mv_par04),2)
	Endif	
	cChave := mv_par03 + Inverte(mv_par04)
EndIf

If naovazio()
	QM2->(DbsetOrder(1))
	If QM2->(DbSeek(xFilial('QM2') + cChave ))
		If cPerg <> "O"
			RecLock("QM2",.F.)
			QM2->QM2_FLAG := "2"
			MsUnlock()	
		EndIf
		Return(.T.)
	Else
		Return .f.	
	EndIf
Else
	Return .f.
Endif


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A020CkIns  ³ Autor ³ Wanderley Gon‡alves	  ³ Data ³ 20/01/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se Instrumento esta cadastrado para sugerir versao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X1_VALID do Grupo QMA020 e Ordem 3			  			    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A020CkIns()
Local nRec := 0

If mv_par01 == mv_par03 
	dbSelectArea("QM2")
	dbSetOrder(1)
	If dbSeek(xFilial()+mv_par01)
		mv_par02 := QM2->QM2_REVINS
	Endif	
Endif
mv_par03 := Upper(mv_par03)
If naovazio()
	nRec := QM2->(recno())
	QM2->(DbsetOrder(1))
	If QM2->(DbSeek(xFilial('QM2') + mv_par03))
		cRev := Soma1(QM2->QM2_REVINS)
		mv_par04 := cRev
	Else
		mv_par04 := StrZero(Val(mv_par04),2)
	EndIf
	QM2->(DbGoTo(nRec))
EndIf
Return(.T.)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A020ValIns ³ Autor ³ Wanderley Gon‡alves	  ³ Data ³ 17/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Limpa campos USOINI, VALDAF e LAUDO se instrumento origem    ³±±
±±³          ³ for diferente do instrumento destino                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA020                    									³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A020ValIns()

If !mv_par01 == mv_par03

	If QM2->(DbSeek(xFilial("QM2")+mv_par03+Inverte(mv_par04)))
		RecLock("QM2",.f.)
		QM2->QM2_USOINI	:= ctod('  /  /  ','DDMMYY')
		QM2->QM2_VALDAF	:= ctod('  /  /  ','DDMMYY')
		QM2->QM2_FLAG 	:= "2"
		MsUnlock()
	EndIf
EndIf

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A010GetJu	³ Autora³ Iuri Seto             ³ Data ³ 09/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pede a Justificativa da nova revisao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A020GetJu(cMemo)
Local oDlgFim
Local oIcon
Local oSay
Local oMemo
Local oBtn1
Local oBtn2

lGrvJu := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³															 ³
//³ Justificativa criacao de uma nova revisao do instrumento ³
//³															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgFim FROM 58,1 TO 290,300 TITLE STR0006 PIXEL OF oMainWnd  //"Justificativa"
@ 003,003 TO 095,147 OF oDlgFim PIXEL
@ 0.7,002 ICON oIcon RESOURCE "CLIPS" OF oDlgFim NOBORDER
@ 011,045 SAY oSay PROMPT STR0007+" "+Capital(mv_par03)+"-"+Capital(mv_par04)+"." SIZE 096,030 OF oDlgFim PIXEL //"Digite abaixo a justificativa para inclusao revisao do instrumento"
@ 035,017 GET oMemo VAR cMemo SIZE 116,50 OF oDlgFim MEMO NO VSCROLL PIXEL
oMemo:bGotFocus := { || oMemo:nPos := 0,oMemo:Refresh()}
	
@ 100, 050 BUTTON oBtn1 PROMPT STR0001 SIZE 44, 11 OF oDlgFim PIXEL ACTION (If(Empty(cMemo),msgstop(STR0008,STR0009),(lGrvJu:=.T.,oDlgFim:End()))) //"Confirma" //"Justificativa não encontrada.","Atenção"
@ 100, 100 BUTTON oBtn2 PROMPT STR0002 SIZE 44, 11 OF oDlgFim PIXEL ACTION (oDlgFim:End()) 	         //"Cancela"
	
ACTIVATE MSDIALOG oDlgFim CENTER 

Return lGrvJu   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A020GvJu  ³ Autora³ Iuri Seto             ³ Data ³ 10/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Justificativa para criacao de uma nova revisao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A010GvJu(ExpC1,ExpC2)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Variável Memo 									  ³±±
±±³			 ³ ExpC2: Variável Chave									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA020													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A020GvJu(cMemo,cChave)
Local cOldAlias	:= Select()
Local cEspec
Local cTexto
Local nDivQM3 := 0
Local nTamQM3 := 1
Local nx	  := 1
Local nSeqQA3 := 0	
If !EMPTY(cMemo)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³														   ³
	//³ Efetua a Gravacao de justificativa de cada linha - QA3 ³
	//³														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QA3")
	dbSetOrder(1)

	cEspec	:= "QMTA010R"
	cTexto	:= cMemo     
	//Deleta os historicos anteriores se houver e regrava os mesmos com as devidas alteracoes... - conceito 8.11	
	If DbSeek(xFilial("QA3")+cEspec+cChave)
		While QA3->(!Eof()) .and. QA3->QA3_FILIAL+QA3->QA3_ESPEC+QA3->QA3_CHAVE == xFilial("QA3")+cEspec+cChave
			RecLock("QA3",.F.)        	
			dbDelete()
			MsUnLock()	
			dbSelectArea("QA3")
			dbSkip()
		Enddo		
	EndIf

	nDivQM3 := Int(Len(cTexto)/TamSX3("QA3_TEXTO")[1])+1

    For nx := 1 to nDivQM3
	    nSeqQA3++
   		If !Empty(SubsTr(cTexto,nTamQM3,TamSX3("QA3_TEXTO")[1]))             
	    	RecLock("QA3",.T.)
			QA3->QA3_FILIAL := xFilial("QA3")
			QA3->QA3_CHAVE  := cChave
			QA3->QA3_ESPEC  := cEspec

			If nx == 1
				QA3->QA3_TEXTO := Substr(cTexto,nTamQM3,TamSX3("QA3_TEXTO")[1])
				nTamQM3 = 0
			Else
				QA3->QA3_TEXTO := Substr(cTexto,nTamQM3+1,TamSX3("QA3_TEXTO")[1])   
			Endif
		
			nTamQM3 := nTamQM3+TamSX3("QA3_TEXTO")[1]
		
			QA3->QA3_SEQ	:= StrZero(nSeqQA3,3)
			QA3->QA3_DATA	:= dDatabase
			QA3->QA3_DATINV := Inverte(QA3->QA3_DATA)
    		MsUnLock()
		Endif
    Next nx
EndIf
dbSelectArea(cOldAlias)

Return
