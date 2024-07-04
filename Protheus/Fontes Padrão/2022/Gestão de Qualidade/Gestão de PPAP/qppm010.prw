#INCLUDE "QPPM010.CH"
#INCLUDE "PROTHEUS.CH"


/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё QPPM010	  Ё Autor Ё Robson Ramiro A. OliveЁ Data Ё 14/03/02 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Gera Revisao         					  				    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё QPPM010()                                                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Void                                                         Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso		 Ё SIGAPPAP				                 					    Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       Ё╠╠
╠╠цддддддддддддддбддддддддбдддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё PROGRAMADOR  Ё DATA   Ё BOPS  Ё MOTIVO DA ALTERACAO                     Ё╠╠
╠╠цддддддддддддддеддддддддедддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Robson RamiroЁ06.09.02Ё xMETA Ё Troca da QA_CVKEY por GetSXENum         Ё╠╠
╠╠юддддддддддддддаддддддддадддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function QPPM010

Local lOk

Local cFuncao	:= "QPPM010"
Local cPergunte	:= ""	//"PPM010"
Local cTitulo	:= OemToAnsi( STR0021 )		//"Geracao de Revisao PPAP"
Local cDescricao:= ""
Local bProcessa	:= {|oSelf| lOk := QPPM010PROC(oSelf) }

Private cRevNew
DbSelectArea("QKM")                            

Do While .T.
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Variaveis utilizadas para parametros							Ё
	//Ё mv_par01				// Peca Origem							Ё
	//Ё mv_par02				// Revisao Origem 						Ё
	//Ё mv_par03				// Alteracao / Geracao         			Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If Pergunte("PPM010",.T.)

		If mv_par03 == 1 .and. QaCheckFK()
			Loop
		Endif

		QK1->(DbSetOrder(1))
		If !(QK1->(DbSeek(xFilial("QK1")+mv_par01+mv_par02)))
			MsgAlert(OemToAnsi(STR0001)) //"Peca e Revisao de Origem Nao Existem"
			Loop
		Else
			If !(QK1->QK1_STATUS $ "1_4")
				MsgAlert(OemToAnsi(STR0023)) //"Nao foi possivel gerar, a peca origem tem que ter Status Aberta ou Rejeitada !"
				Loop
			Endif
		Endif

		QK1->(DbSetOrder(2)) // Pega o Numero para a proxima revisao
		If (QK1->(DbSeek(xFilial("QK1")+mv_par01)))
			cRevNew := StrZero((Val(QK1->QK1_REV)+1),2)
		Endif

		If QK1->(DbSeek(xFilial("QK1")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0002)) //"Peca e Revisao Destino Ja Existem"
			Loop
		EndIf

		QKK->(DbSetOrder(1))
		If QKK->(DbSeek(xFilial("QKK")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0003)) //"Peca e Revisao Destino Ja Existem Nas Operacoes"
			Loop
		EndIf

		QKG->(DbSetOrder(1))
		If QKG->(DbSeek(xFilial("QKG")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0004))  //"Peca e Revisao Destino Ja Existem No Cronograma"
			Loop
		EndIf
			
		QKF->(DbSetOrder(1))
		If QKF->(DbSeek(xFilial("QKF")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0005))  //"Peca e Revisao Destino Ja Existem Na Viabilidade"
			Loop
		EndIf

		QM4->(DbSetOrder(3))
		If QM4->(DbSeek(xFilial("QM4")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0006))  //"Peca e Revisao Destino Ja Existem No RR"
			Loop
		EndIf

		QK9->(DbSetOrder(1))
		If QK9->(DbSeek(xFilial("QK9")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0007))  //"Peca e Revisao Destino Ja Existem Na Capabilidade"
			Loop
		EndIf

		QKB->(DbSetOrder(1))
		If QKB->(DbSeek(xFilial("QKB")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0008))  //"Peca e Revisao Destino Ja Existem No Ensaio Dimensional"
			Loop
		EndIf

		QKD->(DbSetOrder(1))
		If QKD->(DbSeek(xFilial("QKD")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0009))  //"Peca e Revisao Destino Ja Existem No Ensaio Material"
			Loop
		EndIf

		QKC->(DbSetOrder(1))
		If QKC->(DbSeek(xFilial("QKC")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0010))  //"Peca e Revisao Destino Ja Existem No Ensaio Desempenho"
			Loop
		EndIf

		QK3->(DbSetOrder(1))
		If QK3->(DbSeek(xFilial("QK3")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0011))  //"Peca e Revisao Destino Ja Existem Na Aprov. Aparencia"
			Loop
		EndIf

		QKI->(DbSetOrder(1))
		If QKI->(DbSeek(xFilial("QKI")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0012))  //"Peca e Revisao Destino Ja Existem No Certificado de Submissao"
			Loop
		EndIf

		QKL->(DbSetOrder(1))
		If QKL->(DbSeek(xFilial("QKL")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0013))  //"Peca e Revisao Destino Ja Existem No Plano de Controle"
			Loop
		EndIf

		QK5->(DbSetOrder(1))
		If QK5->(DbSeek(xFilial("QK5")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0014))  //"Peca e Revisao Destino Ja Existem No FMEA Projeto"
			Loop
		EndIf

		QK7->(DbSetOrder(1))
		If QK7->(DbSeek(xFilial("QK7")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0015))  //"Peca e Revisao Destino Ja Existem No FMEA Processo"
			Loop
		EndIf

		QKJ->(DbSetOrder(1))
		If QKJ->(DbSeek(xFilial("QKJ")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0016))  //"Peca e Revisao Destino Ja Existem No Sumario e APQP"
			Loop
		EndIf

		QKN->(DbSetOrder(1))
		If QKN->(DbSeek(xFilial("QKN")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0017))  //"Peca e Revisao Destino Ja Existem No Diagrama de Fluxo"
			Loop
		EndIf

		QKH->(DbSetOrder(1))
		If QKH->(DbSeek(xFilial("QKH")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0018))  //"Peca e Revisao Destino Ja Existem Na Aprovacao Interina"
			Loop
		EndIf

		QKQ->(DbSetOrder(1))
		If QKQ->(DbSeek(xFilial("QKQ")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0024)) //"Peca e Revisao Destino Ja Existem no CheckList A1"
			Loop
		Endif

		QKR->(DbSetOrder(1))
		If QKR->(DbSeek(xFilial("QKR")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0025)) //"Peca e Revisao Destino Ja Existem no CheckList A2"
			Loop
		Endif

		QKS->(DbSetOrder(1))
		If QKS->(DbSeek(xFilial("QKS")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0026)) //"Peca e Revisao Destino Ja Existem no CheckList A3"
			Loop
		Endif

		QKT->(DbSetOrder(1))
		If QKT->(DbSeek(xFilial("QKT")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0027)) //"Peca e Revisao Destino Ja Existem no CheckList A4"
			Loop
		Endif

		QKU->(DbSetOrder(1))
		If QKU->(DbSeek(xFilial("QKU")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0028)) //"Peca e Revisao Destino Ja Existem no CheckList A5"
			Loop
		Endif

		QKV->(DbSetOrder(1))
		If QKV->(DbSeek(xFilial("QKV")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0029)) //"Peca e Revisao Destino Ja Existem no CheckList A6"
			Loop
		Endif

		QKW->(DbSetOrder(1))
		If QKW->(DbSeek(xFilial("QKW")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0030)) //"Peca e Revisao Destino Ja Existem no CheckList A7"
			Loop
		Endif

		QKX->(DbSetOrder(1))
		If QKX->(DbSeek(xFilial("QKX")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0031)) //"Peca e Revisao Destino Ja Existem no CheckList A8"
			Loop
		Endif

		QKY->(DbSetOrder(1))
		If QKY->(DbSeek(xFilial("QKY")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0032)) //"Peca e Revisao Destino Ja Existem no CheckList Granel"
			Loop
		Endif

		QL0->(DbSetOrder(1))
		If QL0->(DbSeek(xFilial("QL0")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0033)) //"Peca e Revisao Destino Ja Existem no PSA"
			Loop
		Endif

		QL1->(DbSetOrder(1))
		QL2->(DbSetOrder(1))

		If QL1->(DbSeek(xFilial("QL1")+mv_par01+cRevNew)) .or. QL2->(DbSeek(xFilial("QL2")+mv_par01+cRevNew))
			MsgAlert(OemToAnsi(STR0034)) //"Peca e Revisao Destino Ja Existem no VDA"
			Loop
		Endif
		
		//Sintaxe: tNewProcess():New( <cFunction> , <cTitle> , <bProcess> ,<cDescription> ,[ cPerg ],[ aInfoCustom ], [lPanelAux], [nSizePanelAux], [cDescriAux], [lViewExecute] , [lOneMeter] )
		tNewProcess():New( cFuncao, cTitulo, bProcessa , cDescricao, cPergunte,,,,,, .T. )

		If mv_par03 == 2 .and. lOk  // Altera o Status da revisao anterior no caso de duplicacao
			QK1->(DbSetOrder(1))
			If QK1->(DbSeek(xFilial("QK1")+mv_par01+mv_par02))
				RecLock("QK1",.F.)
				QK1->QK1_STATUS := "3"
				MsUnlock()
			Endif
		Endif
	
	Else
		Exit
	Endif
Enddo

Return Nil

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё QPPM010PROCЁ Autor Ё Robson Ramiro A. OliveЁ Data Ё 14/10/02 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Executa a Geracao da Revisao com Duplicacao  			    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё QPPM010PROC()                                                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Void                                                         Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso		 Ё SIGAPPAP				                 					    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function QPPM010PROC(oSelf)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Variaveis 														  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local bCRepQK1,bCRepQK2,bCRepQKK,bCRepQKO,bCRepQKG,bCRepQKP,bCRepQKF,bCRepQK9,bCRepQKA	// Atribuicao no replace
Local bCRepQKB,bCRepQKD,bCRepQKC,bCRepQK3,bCRepQK4,bCRepQKI,bCRepQKL,bCRepQKM,bCRepQKJ 	
Local bCRepQK5,bCRepQK6,bCRepQK7,bCRepQK8,bCRepQKN,bCRepQKH,bCRepQM4,bCRepQM5
Local bCRepQKQ,bCRepQKR,bCRepQKS,bCRepQKT,bCRepQKU,bCRepQKV,bCRepQKW,bCRepQKX,bCRepQKY
Local bCRepQL0,bCRepQL1,bCRepQL2,bCRepQL3

Local bCConQK1,bCConQK2,bCConQKK,bCConQKO,bCConQKG,bCConQKP,bCConQKF,bCConQK9,bCConQKA 	// Condicao para o replace
Local bCConQKB,bCConQKD,bCConQKC,bCConQK3,bCConQK4,bCConQKI,bCConQKL,bCConQKM,bCConQKJ
Local bCConQK5,bCConQK6,bCConQK7,bCConQK8,bCConQKN,bCConQKH,bCConQM4,bCConQM5
Local bCConQKQ,bCConQKR,bCConQKS,bCConQKT,bCConQKU,bCConQKV,bCConQKW,bCConQKX,bCConQKY
Local bCConQL0,bCConQL1,bCConQL2,bCConQL3

Local aArq				// Array de arquivos para duplicacao
Local aArqRec           // Array com os recnos para alteracao
Local lVolta
Local cEspecie 			// Especie
Local cKeyOri			// Nova Chave
Local cKeyNew			// Nova Chave
Local nCntFor
Local nCont
Local lOk
Local lReturn 	:= .F.
Local cKeyQKQ 	:= ""
Local cKeyQKR 	:= ""
Local cKeyQKS 	:= ""
Local cKeyQKT 	:= ""
Local cKeyQKU 	:= ""
Local cKeyQKV 	:= ""
Local cKeyQKW 	:= ""
Local cKeyQKX 	:= ""
Local nSaveSX8	:= GetSX8Len()
Local nCon

If Empty(Alltrim(MV_PAR06))
	MsgInfo(OemToAnsi(STR0022)+STR0039, OemToAnsi(STR0021)) //"Nao Houve GeraГЦo de RevisЦo !!!"###" Informe a descriГЦo da PeГa."###"GeraГЦo de RevisЦo do PPAP"
	Return Nil
EndIf
		
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa Arrays 											 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aArq	:= {}
aArqRec	:= {}


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKO, Arquivo de Textos						         Ё 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 	
bCRepQKO := { || QKO->QKO_CHAVE := cKeyNew }

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK1, Cadastro de Pecas						         Ё 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQK1 := { ||	QK1->QK1_PECA	:= mv_par01,;
					QK1->QK1_REV	:= cRevNew,;
					QK1->QK1_REVINV	:= Inverte(cRevNew),;
					QK1->QK1_DTREVI	:= dDataBase,;
					QK1->QK1_STATUS	:= "1" }

If MV_PAR07 == 1 .AND. MV_PAR08 == 1 
	bCRepQK1 := { ||	QK1->QK1_PECA	:= mv_par01,;
						QK1->QK1_REV	:= cRevNew,;
						QK1->QK1_REVINV	:= Inverte(cRevNew),;
						QK1->QK1_DTREVI	:= dDataBase,;
						QK1->QK1_STATUS	:= "1",;
						QK1->QK1_DESC   := MV_PAR06,;
						QK1->QK1_PRODUT := MV_PAR09,;
						QK1->QK1_REVI   := MV_PAR10 }

ElseIf MV_PAR07 == 1
	bCRepQK1 := { ||	QK1->QK1_PECA	:= mv_par01,;
				   		QK1->QK1_REV	:= cRevNew,;
				   		QK1->QK1_REVINV	:= Inverte(cRevNew),;
				   		QK1->QK1_DTREVI	:= dDataBase,;
				   		QK1->QK1_STATUS	:= "1" ,;
						QK1->QK1_DESC   := MV_PAR06 }
ElseIf MV_PAR08 == 1
	bCRepQK1 := { ||	QK1->QK1_PECA	:= mv_par03,;
						QK1->QK1_REV 	:= mv_par04,;
						QK1->QK1_REVINV	:= Inverte(mv_par04),;
						QK1->QK1_DTREVI	:= dDataBase,;
						QK1->QK1_STATUS	:= "1",;
						QK1->QK1_PRODUT := MV_PAR09,;
						QK1->QK1_REVI   := MV_PAR10 }
EndIf
														
bCConQK1 := { || ! Eof() .and. xFilial("QK1") == QK1_FILIAL .and.;
											  QK1_PECA == mv_par01 .and.;
											  QK1_REV == mv_par02 }

aAdd( aArq, { "QK1", mv_par01+mv_par02, bCRepQK1, bCConQK1, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK2, Caracteristica das Pecas						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQK2 := { ||	QK2->QK2_PECA	 := mv_par01,;
					QK2->QK2_REV 	 := cRevNew,;
					QK2->QK2_REVINV	 :=	Inverte(cRevNew)}
						
bCConQK2 := { || ! Eof() .and. xFilial("QK2") == QK2_FILIAL .and.;
											  QK2_PECA == mv_par01 .and.;
											  QK2_REV == mv_par02 }

aAdd( aArq, { "QK2", mv_par01+mv_par02, bCRepQK2, bCConQK2, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKK, Operacoes                     					 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKK := { ||	QKK->QKK_PECA	 := mv_par01,;
					QKK->QKK_REV 	 := cRevNew,;
					QKK->QKK_REVINV	 :=	Inverte(cRevNew)}
							
bCConQKK := { || ! Eof() .and. xFilial("QKK") == QKK_FILIAL .and.;
											  QKK_PECA == mv_par01 .and.;
											  QKK_REV == mv_par02 }

aAdd( aArq, { "QKK", mv_par01+mv_par02, bCRepQKK, bCConQKK, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKG, Cabecalho do Cronograma       					 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKG := { ||	QKG->QKG_PECA	 := mv_par01,;
					QKG->QKG_REV 	 := cRevNew,;
					QKG->QKG_REVINV	 :=	Inverte(cRevNew)}
							
bCConQKG := { || ! Eof() .and. xFilial("QKG") == QKG_FILIAL .and.;
											  QKG_PECA == mv_par01 .and.;
											  QKG_REV == mv_par02 }

aAdd( aArq, { "QKG", mv_par01+mv_par02, bCRepQKG, bCConQKG, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKP, Detail do Cronograma       					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKP := { ||	QKP->QKP_PECA	 := mv_par01,;
					QKP->QKP_REV 	 := cRevNew,;
					QKP->QKP_REVINV	 :=	Inverte(cRevNew)}
							
bCConQKP := { || ! Eof() .and. xFilial("QKP") == QKP_FILIAL .and.;
											  QKP_PECA == mv_par01 .and.;
											  QKP_REV == mv_par02 }

aAdd( aArq, { "QKP", mv_par01+mv_par02, bCRepQKP, bCConQKP, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKF, Viabilidade                					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKF := { ||	QKF->QKF_PECA	 := mv_par01,;
					QKF->QKF_REV 	 := cRevNew,;
					QKF->QKF_REVINV	 :=	Inverte(cRevNew)}
							
bCConQKF := { || ! Eof() .and. xFilial("QKF") == QKF_FILIAL .and.;
											  QKF_PECA == mv_par01 .and.;
											  QKF_REV == mv_par02 }

aAdd( aArq, { "QKF", mv_par01+mv_par02, bCRepQKF, bCConQKF, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK9, Cabecalho Capabilidade     					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQK9 := { ||	QK9->QK9_PECA	 := mv_par01,;
					QK9->QK9_REV 	 := cRevNew,;
					QK9->QK9_REVINV	 :=	Inverte(cRevNew)}
							
bCConQK9 := { || ! Eof() .and. xFilial("QK9") == QK9_FILIAL .and.;
											  QK9_PECA == mv_par01 .and.;
											  QK9_REV == mv_par02 }

aAdd( aArq, { "QK9", mv_par01+mv_par02, bCRepQK9, bCConQK9, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKA, Detail da Capabilidade     					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKA := { ||	QKA->QKA_PECA	 := mv_par01,;
					QKA->QKA_REV 	 := cRevNew,;
					QKA->QKA_REVINV	 :=	Inverte(cRevNew)}
							
bCConQKA := { || ! Eof() .and. xFilial("QKA") == QKA_FILIAL .and.;
											  QKA_PECA == mv_par01 .and.;
											  QKA_REV == mv_par02 }

aAdd( aArq, { "QKA", mv_par01+mv_par02, bCRepQKA, bCConQKA, 1 } )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKB, Enasio Dimensional        					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKB := { ||	QKB->QKB_PECA	 := mv_par01,;
					QKB->QKB_REV 	 := cRevNew,;
					QKB->QKB_REVINV	 :=	Inverte(cRevNew),;
					QKB->QKB_ASSFOR	 := " ",;
					QKB->QKB_DTAPR 	 := CTOD(" ")}
							
bCConQKB := { || ! Eof() .and. xFilial("QKB") == QKB_FILIAL .and.;
											  QKB_PECA == mv_par01 .and.;
											  QKB_REV == mv_par02 }

aAdd( aArq, { "QKB", mv_par01+mv_par02, bCRepQKB, bCConQKB, 1 } )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKD, Enasio Material           					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKD := { ||	QKD->QKD_PECA	 := mv_par01,;
					QKD->QKD_REV 	 := cRevNew,;
					QKD->QKD_REVINV	 :=	Inverte(cRevNew),;
					QKD->QKD_ASSFOR	 := " ",;
					QKD->QKD_DTAPR 	 := CTOD(" ")}
							
bCConQKD := { || ! Eof() .and. xFilial("QKD") == QKD_FILIAL .and.;
											  QKD_PECA == mv_par01 .and.;
											  QKD_REV == mv_par02 }

aAdd( aArq, { "QKD", mv_par01+mv_par02, bCRepQKD, bCConQKD, 1 } )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKC, Enasio Desempenho           					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKC := { ||	QKC->QKC_PECA	 := mv_par01,;
					QKC->QKC_REV 	 := cRevNew,;
					QKC->QKC_REVINV	 :=	Inverte(cRevNew),;
					QKC->QKC_ASSFOR	 := " ",;
					QKC->QKC_DTAPR 	 := CTOD(" ")}
							
bCConQKC := { || ! Eof() .and. xFilial("QKC") == QKC_FILIAL .and.;
											  QKC_PECA == mv_par01 .and.;
											  QKC_REV == mv_par02 }

aAdd( aArq, { "QKC", mv_par01+mv_par02, bCRepQKC, bCConQKC, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK3, Cabecalho Aprovacao de Aparencia  			     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQK3 := { ||	QK3->QK3_PECA	 := mv_par01,;
					QK3->QK3_REV 	 := cRevNew,;
					QK3->QK3_REVINV	 :=	Inverte(cRevNew)}
							
bCConQK3 := { || ! Eof() .and. xFilial("QK3") == QK3_FILIAL .and.;
											  QK3_PECA == mv_par01 .and.;
											  QK3_REV == mv_par02 }

aAdd( aArq, { "QK3", mv_par01+mv_par02, bCRepQK3, bCConQK3, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK4, Details Aprovacao de Aparencia  			         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQK4 := { ||	QK4->QK4_PECA	 := mv_par01,;
					QK4->QK4_REV 	 := cRevNew,;
					QK4->QK4_REVINV	 :=	Inverte(cRevNew)}
							
bCConQK4 := { || ! Eof() .and. xFilial("QK4") == QK4_FILIAL .and.;
											  QK4_PECA == mv_par01 .and.;
											  QK4_REV == mv_par02 }

aAdd( aArq, { "QK4", mv_par01+mv_par02, bCRepQK4, bCConQK4, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKI, Certificado de Submissao     			         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKI := { ||	QKI->QKI_PECA	 := mv_par01,;
					QKI->QKI_REV 	 := cRevNew,;
					QKI->QKI_REVINV	 :=	Inverte(cRevNew)}
							
bCConQKI := { || ! Eof() .and. xFilial("QKI") == QKI_FILIAL .and.;
											  QKI_PECA == mv_par01 .and.;
											  QKI_REV == mv_par02 }

aAdd( aArq, { "QKI", mv_par01+mv_par02, bCRepQKI, bCConQKI, 1 } )
 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKL, Cabecalho do Plano de Controle  			         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKL := { ||	QKL->QKL_PECA	 := mv_par01,;
					QKL->QKL_REV 	 := cRevNew,;
					QKL->QKL_REVINV	 :=	Inverte(cRevNew),;
					QKL->QKL_APRFOR	 := "",;
					QKL->QKL_DTAFOR	 := CToD(""),;
					QKL->QKL_TPPRO	 := AllTrim(STR(mv_par05-1))}
							
bCConQKL := { || ! Eof() .and. xFilial("QKI") == QKL_FILIAL .and.;
								QKL_PECA == mv_par01 .and.;
								QKL_REV == mv_par02 .and.;
								QKL_TPPRO == AllTrim(STR(mv_par04-1)) }
								
aAdd( aArq, { "QKL", mv_par01+mv_par02+AllTrim(STR(mv_par04-1)), bCRepQKL, bCConQKL, 1 } )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKM, Details do Plano de Controle  			         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKM := { ||	QKM->QKM_PECA	 := mv_par01,;
					QKM->QKM_REV 	 := cRevNew,;
					QKM->QKM_REVINV	 :=	Inverte(cRevNew),;
					QKM->QKM_TPPRO	 := AllTrim(STR(mv_par05-1))}
					
bCConQKM := { || ! Eof() .and. xFilial("QKM") == QKM_FILIAL .and.;
 							    QKM_PECA == mv_par01 .and.;
								QKM_REV == mv_par02  .and.;
								QKM_TPPRO == AllTrim(STR(mv_par04-1))}                                                 

aAdd( aArq, { "QKM", mv_par01+mv_par02+AllTrim(STR(mv_par04-1)), bCRepQKM, bCConQKM, 3 } )
	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKJ, Sumario e APQP        							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKJ := { ||	QKJ->QKJ_PECA	 := mv_par01,;
					QKJ->QKJ_REV 	 := cRevNew,;
					QKJ->QKJ_REVINV	 :=	Inverte(cRevNew)}
							
bCConQKJ := { || ! Eof() .and. xFilial("QKJ") == QKJ_FILIAL .and.;
											  QKJ_PECA == mv_par01 .and.;
											  QKJ_REV == mv_par02 }

aAdd( aArq, { "QKJ", mv_par01+mv_par02, bCRepQKJ, bCConQKJ, 1 } )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK5, Cabecalho FMEA Projeto							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQK5 := { ||	QK5->QK5_PECA	 := mv_par01,;
					QK5->QK5_REV 	 := cRevNew,;
					QK5->QK5_REVINV	 :=	Inverte(cRevNew),;
					QK5->QK5_APRPOR  := "",;
					QK5->QK5_DATA    := CToD("")}
							
bCConQK5 := { || ! Eof() .and. xFilial("QK5") == QK5_FILIAL .and.;
											  QK5_PECA == mv_par01 .and.;
											  QK5_REV == mv_par02 }

aAdd( aArq, { "QK5", mv_par01+mv_par02, bCRepQK5, bCConQK5, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK6, Details FMEA Projeto							     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQK6 := { ||	QK6->QK6_PECA	 := mv_par01,;
					QK6->QK6_REV 	 := cRevNew,;
					QK6->QK6_REVINV	 :=	Inverte(cRevNew)}
							
bCConQK6 := { || ! Eof() .and. xFilial("QK6") == QK6_FILIAL .and.;
											  QK6_PECA == mv_par01 .and.;
											  QK6_REV == mv_par02 }

aAdd( aArq, { "QK6", mv_par01+mv_par02, bCRepQK6, bCConQK6, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK7, Cabecalho FMEA Processo							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQK7 := { ||	QK7->QK7_PECA	 := mv_par01,;
					QK7->QK7_REV 	 := cRevNew,;
					QK7->QK7_REVINV	 :=	Inverte(cRevNew),;
					QK7->QK7_APRPOR  := "",;
					QK7->QK7_DATA    := CToD("")}
							
bCConQK7 := { || ! Eof() .and. xFilial("QK7") == QK7_FILIAL .and.;
											  QK7_PECA == mv_par01 .and.;
											  QK7_REV == mv_par02 }

aAdd( aArq, { "QK7", mv_par01+mv_par02, bCRepQK7, bCConQK7, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK8, Details FMEA Processo						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQK8 := { ||	QK8->QK8_PECA	 := mv_par01,;
					QK8->QK8_REV 	 := cRevNew,;
					QK8->QK8_REVINV	 :=	Inverte(cRevNew)}
							
bCConQK8 := { || ! Eof() .and. xFilial("QK8") == QK8_FILIAL .and.;
											  QK8_PECA == mv_par01 .and.;
											  QK8_REV == mv_par02 }

aAdd( aArq, { "QK8", mv_par01+mv_par02, bCRepQK8, bCConQK8, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKN, Diagrama de Fluxo    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKN := { ||	QKN->QKN_PECA	 := mv_par01,;
					QKN->QKN_REV 	 := cRevNew,;
					QKN->QKN_REVINV	 :=	Inverte(cRevNew),;
					QKN->QKN_APRPOR	 := " ",;
					QKN->QKN_DTAPR 	 := CTOD(" ")}
					
							
bCConQKN := { || ! Eof() .and. xFilial("QKN") == QKN_FILIAL .and.;
											  QKN_PECA == mv_par01 .and.;
											  QKN_REV == mv_par02 }

aAdd( aArq, { "QKN", mv_par01+mv_par02, bCRepQKN, bCConQKN, 1 } )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QM4, Cabecalho do RR       						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQM4 := { ||	QM4->QM4_PECA1	 := mv_par01,;
					QM4->QM4_REV 	 := cRevNew,;
					QM4->QM4_REVINV	 :=	Inverte(cRevNew)}
							
bCConQM4 := { || ! Eof() .and. xFilial("QM4") == QM4_FILIAL .and.;
											  QM4_PECA1 == mv_par01 .and.;
											  QM4_REV == mv_par02 }

aAdd( aArq, { "QM4", mv_par01+mv_par02, bCRepQM4, bCConQM4, 3 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QM5, Details do RR       						         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQM5 := { ||	QM5->QM5_PECA1	 := mv_par01,;
					QM5->QM5_REV 	 := cRevNew,;
					QM5->QM5_REVINV	 :=	Inverte(cRevNew)}
							
bCConQM5 := { || ! Eof() .and. xFilial("QM5") == QM5_FILIAL .and.;
											  QM5_PECA1 == mv_par01 .and.;
											  QM5_REV == mv_par02 }

aAdd( aArq, { "QM5", mv_par01+mv_par02, bCRepQM5, bCConQM5, 2 } )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKH, Aprovacao Interina    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKH := { ||	QKH->QKH_PECA	 := mv_par01,;
					QKH->QKH_REV 	 := cRevNew,;
					QKH->QKH_REVINV	 :=	Inverte(cRevNew)}
							
bCConQKH := { || ! Eof() .and. xFilial("QKH") == QKH_FILIAL .and.;
											  QKH_PECA == mv_par01 .and.;
											  QKH_REV == mv_par02 }

aAdd( aArq, { "QKH", mv_par01+mv_par02, bCRepQKH, bCConQKH, 1 } )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKQ, Checklist APQP A1    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKQ := { ||	QKQ->QKQ_PECA	:= mv_par01,;
					QKQ->QKQ_REV	:= cRevNew,;
					QKQ->QKQ_REVINV	:= Inverte(cRevNew)}
							
bCConQKQ := { || ! Eof() .and. xFilial("QKQ") == QKQ_FILIAL .and.;
												QKQ_PECA == mv_par01 .and.;
												QKQ_REV == mv_par02 }

aAdd( aArq, { "QKQ", mv_par01+mv_par02, bCRepQKQ, bCConQKQ, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKR, Checklist APQP A2    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKR := { ||	QKR->QKR_PECA	:= mv_par01,;
					QKR->QKR_REV	:= cRevNew,;
					QKR->QKR_REVINV	:= Inverte(cRevNew)}
							
bCConQKR := { || ! Eof() .and. xFilial("QKR") == QKR_FILIAL .and.;
												QKR_PECA == mv_par01 .and.;
												QKR_REV == mv_par02 }

aAdd( aArq, { "QKR", mv_par01+mv_par02, bCRepQKR, bCConQKR, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKS, Checklist APQP A3    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKS := { ||	QKS->QKS_PECA	:= mv_par01,;
					QKS->QKS_REV	:= cRevNew,;
					QKS->QKS_REVINV	:= Inverte(cRevNew)}
							
bCConQKS := { || ! Eof() .and. xFilial("QKS") == QKS_FILIAL .and.;
												QKS_PECA == mv_par01 .and.;
												QKS_REV == mv_par02 }

aAdd( aArq, { "QKS", mv_par01+mv_par02, bCRepQKS, bCConQKS, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKT, Checklist APQP A4    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKT := { ||	QKT->QKT_PECA	:= mv_par01,;
					QKT->QKT_REV	:= cRevNew,;
					QKT->QKT_REVINV	:= Inverte(cRevNew)}
							
bCConQKT := { || ! Eof() .and. xFilial("QKT") == QKT_FILIAL .and.;
												QKT_PECA == mv_par01 .and.;
												QKT_REV == mv_par02 }

aAdd( aArq, { "QKT", mv_par01+mv_par02, bCRepQKT, bCConQKT, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKU, Checklist APQP A5    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKU := { ||	QKU->QKU_PECA	:= mv_par01,;
					QKU->QKU_REV	:= cRevNew,;
					QKU->QKU_REVINV	:= Inverte(cRevNew)}
							
bCConQKU := { || ! Eof() .and. xFilial("QKU") == QKU_FILIAL .and.;
												QKU_PECA == mv_par01 .and.;
												QKU_REV == mv_par02 }

aAdd( aArq, { "QKU", mv_par01+mv_par02, bCRepQKU, bCConQKU, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKV, Checklist APQP A6    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKV := { ||	QKV->QKV_PECA	:= mv_par01,;
					QKV->QKV_REV	:= cRevNew,;
					QKV->QKV_REVINV	:= Inverte(cRevNew)}
							
bCConQKV := { || ! Eof() .and. xFilial("QKV") == QKV_FILIAL .and.;
												QKV_PECA == mv_par01 .and.;
												QKV_REV == mv_par02 }

aAdd( aArq, { "QKV", mv_par01+mv_par02, bCRepQKV, bCConQKV, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKW, Checklist APQP A7    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKW := { ||	QKW->QKW_PECA	:= mv_par01,;
					QKW->QKW_REV	:= cRevNew,;
					QKW->QKW_REVINV	:= Inverte(cRevNew)}
							
bCConQKW := { || ! Eof() .and. xFilial("QKW") == QKW_FILIAL .and.;
												QKW_PECA == mv_par01 .and.;
												QKW_REV == mv_par02 }

aAdd( aArq, { "QKW", mv_par01+mv_par02, bCRepQKW, bCConQKW, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKX, Checklist APQP A8    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKX := { ||	QKX->QKX_PECA	:= mv_par01,;
					QKX->QKX_REV	:= cRevNew,;
					QKX->QKX_REVINV	:= Inverte(cRevNew)}
							
bCConQKX := { || ! Eof() .and. xFilial("QKX") == QKX_FILIAL .and.;
												QKX_PECA == mv_par01 .and.;
												QKX_REV == mv_par02 }

aAdd( aArq, { "QKX", mv_par01+mv_par02, bCRepQKX, bCConQKX, 1 } )


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKY, Checklist APQP A8    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKY := { ||	QKY->QKY_PECA	:= mv_par01,;
					QKY->QKY_REV	:= cRevNew,;
					QKY->QKY_REVINV	:= Inverte(cRevNew)}
							
bCConQKY := { || ! Eof() .and. xFilial("QKY") == QKY_FILIAL .and.;
												QKY_PECA == mv_par01 .and.;
												QKY_REV == mv_par02 }

aAdd( aArq, { "QKY", mv_par01+mv_par02, bCRepQKY, bCConQKY, 1 } )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QL0, PSA                  						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQL0 := { ||	QL0->QL0_PECA	:= mv_par01,;
					QL0->QL0_REV	:= cRevNew,;
					QL0->QL0_REVINV	:= Inverte(cRevNew)}
							
bCConQL0 := { || ! Eof() .and. xFilial("QL0") == QL0_FILIAL .and.;
												QL0_PECA == mv_par01 .and.;
												QL0_REV == mv_par02 }

aAdd( aArq, { "QL0", mv_par01+mv_par02, bCRepQL0, bCConQL0, 1 } )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QL1, VDA Amostras Iniciais   						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQL1 := { ||	QL1->QL1_PECA	:= mv_par01,;
					QL1->QL1_REV	:= cRevNew,;
					QL1->QL1_REVINV	:= Inverte(cRevNew)}
							
bCConQL1 := { || ! Eof() .and. xFilial("QL1") == QL1_FILIAL .and.;
												QL1_PECA == mv_par01 .and.;
												QL1_REV == mv_par02 }

aAdd( aArq, { "QL1", mv_par01+mv_par02, bCRepQL1, bCConQL1, 1 } )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QL2, VDA Folha de Capa       						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQL2 := { ||	QL2->QL2_PECA	:= mv_par01,;
					QL2->QL2_REV	:= cRevNew,;
					QL2->QL2_REVINV	:= Inverte(cRevNew)}
							
bCConQL2 := { || ! Eof() .and. xFilial("QL2") == QL2_FILIAL .and.;
												QL2_PECA == mv_par01 .and.;
												QL2_REV == mv_par02 }

aAdd( aArq, { "QL2", mv_par01+mv_par02, bCRepQL2, bCConQL2, 1 } )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QL3, Detail do VDA Folha de Capa  				     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQL3 := { ||	QL3->QL3_PECA	:= mv_par01,;
					QL3->QL3_REV	:= cRevNew,;
					QL3->QL3_REVINV	:= Inverte(cRevNew)}
							
bCConQL3 := { || ! Eof() .and. xFilial("QL3") == QL3_FILIAL .and.;
												QL3_PECA == mv_par01 .and.;
												QL3_REV == mv_par02 }

aAdd( aArq, { "QL3", mv_par01+mv_par02, bCRepQL3, bCConQL3, 1 } )

//здддддддддддддддддддд©
//Ё Efetiva gravacao   Ё
//юдддддддддддддддддддды

oSelf:SetRegua1(Len(aArq))

Begin Transaction

If mv_par03 == 2  // Duplicacao
		
	For nCntFor := 1 To Len(aArq)
		oSelf:IncRegua1(LTrim(Str(nCntFor)))

		DbselectArea(aArq[nCntFor,1])
		DbSetOrder(aArq[nCntFor,5])
		DbSeek(xFilial()+aArq[nCntFor,2])
	
		Do While Eval(aArq[nCntFor,4])
			lVolta	:= .T.	

			If Alias() == "QKH"
				lVolta := .F.
			Endif
				
			If QA_Dupl(lVolta, aArq[nCntFor,3], aArq[nCntFor,1])

				// QK3
				If Alias() == "QK3" .and. !Empty(QK3->QK3_CHAVE)
					cKeyOri := QK3->QK3_CHAVE
					cKeyNew := GetSXENum("QK3", "QK3_CHAVE",,3)

					While (GetSX8Len() > nSaveSx8)
						ConfirmSX8()
					End

					cEspecie := "QPPA210 "

					bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
										  QKO->QKO_CHAVE == QK3->QK3_CHAVE .and.;
										  QKO->QKO_ESPEC == cEspecie }

					If DuplicQKO(cEspecie, cKeyOri, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
						RecLock("QK3",.F.)
						QK3->QK3_CHAVE := cKeyNew
						MsUnlock()
					Else
						RecLock("QK3",.F.)
						QK3->QK3_CHAVE := " "
						MsUnlock()
					Endif
				Endif

				// QKK
				If Alias() == "QKK" .and. !Empty(QKK->QKK_CHAVE)
					cKeyOri := QKK->QKK_CHAVE
					cKeyNew := GetSXENum("QKK", "QKK_CHAVE",,4)

					While (GetSX8Len() > nSaveSx8)
						ConfirmSX8()
					End
					
					cEspecie := "QPPA020 "

					bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
											  QKO->QKO_CHAVE == QKK->QKK_CHAVE .and.;
											  QKO->QKO_ESPEC == cEspecie }

					If DuplicQKO(cEspecie, cKeyOri, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
						RecLock("QKK",.F.)
						QKK->QKK_CHAVE := cKeyNew
						MsUnlock()
					Else
						RecLock("QKK",.F.)
						QKK->QKK_CHAVE := " "
						MsUnlock()
					Endif
				Endif

				// QKG
				If Alias() == "QKG" .and. !Empty(QKG->QKG_CHAVE)
					cKeyOri := QKG->QKG_CHAVE
					cKeyNew := GetSXENum("QKG", "QKG_CHAVE",,3)

					While (GetSX8Len() > nSaveSx8)
						ConfirmSX8()
					End

					cEspecie := "QPPA110A"

					bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
										  QKO->QKO_CHAVE == QKG->QKG_CHAVE .and.;
										  QKO->QKO_ESPEC == cEspecie }

					If DuplicQKO(cEspecie, cKeyOri, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
						RecLock("QKG",.F.)
						QKG->QKG_CHAVE := cKeyNew
						MsUnlock()
					Else
						RecLock("QKG",.F.)
						QKG->QKG_CHAVE := " "
						MsUnlock()
					Endif
				Endif

				// QKI
				If Alias() == "QKI" .and. !Empty(QKI->QKI_CHAVE)
					cKeyOri := QKI->QKI_CHAVE
					cKeyNew := GetSXENum("QKI", "QKI_CHAVE",,3)

					While (GetSX8Len() > nSaveSx8)
						ConfirmSX8()
					End

					cEspecie := "QPPA220 "

					bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
										  QKO->QKO_CHAVE == QKI->QKI_CHAVE .and.;
										  QKO->QKO_ESPEC == cEspecie }

					If DuplicQKO(cEspecie, cKeyOri, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
						RecLock("QKI",.F.)
						QKI->QKI_CHAVE := cKeyNew
						MsUnlock()
					Else
						RecLock("QKI",.F.)
						QKI->QKI_CHAVE := " "
						MsUnlock()
						If MV_PAR11 == 1 //.and. Posicione("QAA",1,xFilial("QAA")+QKI->QKI_MAT,"QAA_STATUS")=="2"
							DbSetOrder(3)
							if DbSeek(xFilial("QKI") + cKeyOri)
								RecLock("QKI",.F.)
								QKI->QKI_MAT    := " "
								QKI->QKI_NOMAPR := " "
								MsUnlock()
							EndiF
						EndIF
					Endif
				Endif

				// QKP
				If Alias() == "QKP" .and. !Empty(QKP->QKP_CHAVE)
					cKeyOri := QKP->QKP_CHAVE
					cKeyNew := GetSXENum("QKP", "QKP_CHAVE",,5)

					While (GetSX8Len() > nSaveSx8)
						ConfirmSX8()
					End

					cEspecie := "QPPA110 "

					bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
											  QKO->QKO_CHAVE == QKP->QKP_CHAVE .and.;
											  QKO->QKO_ESPEC == cEspecie }

					If DuplicQKO(cEspecie, cKeyOri, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
						RecLock("QKP",.F.)
						QKP->QKP_CHAVE := cKeyNew
						MsUnlock()
					Endif
				Endif

				// QKF
				If Alias() == "QKF" .and. !Empty(QKF->QKF_CHAVE)
					cKeyOri := QKF->QKF_CHAVE
					cKeyNew := GetSXENum("QKF", "QKF_CHAVE",,3)

					While (GetSX8Len() > nSaveSx8)
						ConfirmSX8()
					End

					cEspecie := "QPPA140 "

					bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
											  QKO->QKO_CHAVE == QKF->QKF_CHAVE .and.;
											  QKO->QKO_ESPEC == cEspecie }

					If DuplicQKO(cEspecie, cKeyOri, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
						RecLock("QKF",.F.)
						QKF->QKF_CHAVE := cKeyNew
						MsUnlock()
					Else
						RecLock("QKF",.F.)
						QKF->QKF_CHAVE := " "
						MsUnlock()
					Endif
				Endif

				// QK9
				If Alias() == "QK9" .and. !Empty(QK9->QK9_CHAVE)
					cKeyOri	:= QK9->QK9_CHAVE
					cKeyNew	:= GetSXENum("QK9", "QK9_CHAVE",,3)

					While (GetSX8Len() > nSaveSx8)
						ConfirmSX8()
					End

					cEspecie := "QPPA170 "

					bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
											  QKO->QKO_CHAVE == QK9->QK9_CHAVE .and.;
											  QKO->QKO_ESPEC == cEspecie }

					If DuplicQKO(cEspecie, cKeyOri, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
						RecLock("QK9",.F.)
						QK9->QK9_CHAVE := cKeyNew
						MsUnlock()
					Else
						RecLock("QK9",.F.)
						QK9->QK9_CHAVE := " "
						MsUnlock()
					Endif
				Endif

				// QKB
				If Alias() == "QKB" .and. !Empty(QKB->QKB_CHAVE)
					cKeyOri	:= QKB->QKB_CHAVE
					cKeyNew := GetSXENum("QKB", "QKB_CHAVE",,3)

					While (GetSX8Len() > nSaveSx8)
						ConfirmSX8()
					End

					cEspecie := "QPPA180 "

					bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
											  QKO->QKO_CHAVE == QKB->QKB_CHAVE .and.;
											  QKO->QKO_ESPEC == cEspecie }

					If DuplicQKO(cEspecie, cKeyOri, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
						RecLock("QKB",.F.)
						QKB->QKB_CHAVE := cKeyNew
						MsUnlock()
					Else
						RecLock("QKB",.F.)
						QKB->QKB_CHAVE := " "
						MsUnlock()
					Endif
				Endif

				// QKD
				If Alias() == "QKD" .and. !Empty(QKD->QKD_CHAVE)
					cKeyOri	:= QKD->QKD_CHAVE
					cKeyNew := GetSXENum("QKD", "QKD_CHAVE",,3)

					While (GetSX8Len() > nSaveSx8)
						ConfirmSX8()
					End
	
					cEspecie := "QPPA190 "

					bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
										  QKO->QKO_CHAVE == QKD->QKD_CHAVE .and.;
										  QKO->QKO_ESPEC == cEspecie }

					If DuplicQKO(cEspecie, cKeyOri, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
						RecLock("QKD",.F.)
						QKD->QKD_CHAVE := cKeyNew
						MsUnlock()
					Else
						RecLock("QKD",.F.)
						QKD->QKD_CHAVE := " "
						MsUnlock()
					Endif
				Endif

				// QKC
				If Alias() == "QKC" .and. !Empty(QKC->QKC_CHAVE)
					cKeyOri	:= QKC->QKC_CHAVE
					cKeyNew := GetSXENum("QKC", "QKC_CHAVE",,3)

					While (GetSX8Len() > nSaveSx8)
						ConfirmSX8()
					End

					cEspecie := "QPPA200 "

					bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
											  QKO->QKO_CHAVE == QKC->QKC_CHAVE .and.;
											  QKO->QKO_ESPEC == cEspecie }

					If DuplicQKO(cEspecie, cKeyOri, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
						RecLock("QKC",.F.)
						QKC->QKC_CHAVE := cKeyNew
						MsUnlock()
					Else
						RecLock("QKC",.F.)
						QKC->QKC_CHAVE := " "
						MsUnlock()
					Endif
				Endif

				// QKJ
				If Alias() == "QKJ" .and. !Empty(QKJ->QKJ_CHAVE)
					cKeyOri	:= QKJ->QKJ_CHAVE
					cKeyNew := GetSXENum("QKJ", "QKJ_CHAVE",,3)

					While (GetSX8Len() > nSaveSx8)
						ConfirmSX8()
					End

					cEspecie := "QPPA230 "

					bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
											  QKO->QKO_CHAVE == QKJ->QKJ_CHAVE .and.;
											  QKO->QKO_ESPEC == cEspecie }

					If DuplicQKO(cEspecie, cKeyOri, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
						RecLock("QKJ",.F.)
						QKJ->QKJ_CHAVE := cKeyNew
						MsUnlock()
					Else
						RecLock("QKJ",.F.)
						QKJ->QKJ_CHAVE := " "
						MsUnlock()
					Endif
				Endif

				// QK6 - Processo diferenciado pois existem 8 especies (A...H)
				If Alias() == "QK6" .and. !Empty(QK6->QK6_CHAVE1)
					cKeyOri	:= QK6->QK6_CHAVE1
					cKeyNew := GetSXENum("QK6", "QK6_CHAVE1",,3)

					While (GetSX8Len() > nSaveSx8)
						ConfirmSX8()
					End

					bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
					   						  QKO->QKO_CHAVE == cKeyOri .and.;
											  QKO->QKO_ESPEC == cEspecie }
					lOk := .F.

				For nCont := 1 To 8
					cEspecie := "QPPA120" + Subs("ABCDEFGH",nCont,1)
						If DuplicQKO(cEspecie, cKeyOri, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
        	            	lOk := .T.
						Endif
					Next nCont

					If lOk
						RecLock("QK6",.F.)
						QK6->QK6_CHAVE1 := cKeyNew
						MsUnlock()
					Else
						RecLock("QK6",.F.)
						QK6->QK6_CHAVE1 := " "
						MsUnlock()
					Endif
				Endif

				// QK8 - Processo diferenciado pois existem 8 especies (A...H)
				If Alias() == "QK8" .and. !Empty(QK8->QK8_CHAVE1)
					cKeyOri	:= QK8->QK8_CHAVE1
					cKeyNew := GetSXENum("QK8", "QK8_CHAVE1",,3)

					While (GetSX8Len() > nSaveSx8)
						ConfirmSX8()
					End

					bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
											  QKO->QKO_CHAVE == cKeyOri .and.;
											  QKO->QKO_ESPEC == cEspecie }
					lOk := .F.

				For nCont := 1 To 8
					cEspecie := "QPPA130" + Subs("ABCDEFGH",nCont,1)
						If DuplicQKO(cEspecie, cKeyOri, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
							lOk := .T.
						Endif
	               Next nCont

					If lOk
						RecLock("QK8",.F.)
						QK8->QK8_CHAVE1 := cKeyNew
						MsUnlock()
					Else
						RecLock("QK8",.F.)
						QK8->QK8_CHAVE1 := " "
						MsUnlock()
					Endif
				Endif

				// QKH - Processo diferenciado pois existem 4 especies (A...D)
				If Alias() == "QKH" .and. !Empty(QKH->QKH_CHAV01)
					cKeyOri	:= QKH->QKH_CHAV01
					cKeyNew	:= GetSXENum("QKH", "QKH_CHAV01",,3)

					While (GetSX8Len() > nSaveSx8)
						ConfirmSX8()
					End

					bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
					   						  QKO->QKO_CHAVE == cKeyOri .and.;
											  QKO->QKO_ESPEC == cEspecie }
					lOk := .F.

					For nCont := 1 To 4
						cEspecie := "QPPA240" + Subs("ABCD",nCont,1)
						If DuplicQKO(cEspecie, cKeyOri, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
							lOk := .T.
						Endif
					Next nCont

					If lOk
						RecLock("QKH",.F.)
						QKH->QKH_CHAV01 := cKeyNew
						MsUnlock()
					Else
						RecLock("QKH",.F.)
						QKH->QKH_CHAV01 := " "
						MsUnlock()
					Endif
				Endif

				// QKQ - Processo diferenciado pois existem 8 especies (1...8)
				If Alias() == "QKQ" .and. !Empty(QKQ->QKQ_CHAVE)
					cKeyQKQ := QKQ->QKQ_CHAVE
				Endif

				// QKR - Processo diferenciado pois existem 40 especies (1...40)
				If Alias() == "QKR" .and. !Empty(QKR->QKR_CHAVE)
					cKeyQKR := QKR->QKR_CHAVE
				Endif

				// QKS - Processo diferenciado pois existem 20 especies (1...20)
				If Alias() == "QKS" .and. !Empty(QKS->QKS_CHAVE)
					cKeyQKS := QKS->QKS_CHAVE
				Endif

				// QKT - Processo diferenciado pois existem 53 especies (1...53)
				If Alias() == "QKT" .and. !Empty(QKT->QKT_CHAVE)
					cKeyQKT := QKT->QKT_CHAVE
				Endif

				// QKU - Processo diferenciado pois existem 13 especies (1...13)
				If Alias() == "QKU" .and. !Empty(QKU->QKU_CHAVE)
					cKeyQKU := QKU->QKU_CHAVE
				Endif

				// QKV - Processo diferenciado pois existem 7 especies (1...7)
				If Alias() == "QKV" .and. !Empty(QKV->QKV_CHAVE)
					cKeyQKV := QKV->QKV_CHAVE
				Endif

				// QKW - Processo diferenciado pois existem 13 especies (1...13)
				If Alias() == "QKW" .and. !Empty(QKW->QKW_CHAVE)
					cKeyQKW := QKW->QKW_CHAVE
				Endif

				// QKX - Processo diferenciado pois existem 10 especies (1...10)
				If Alias() == "QKX" .and. !Empty(QKX->QKX_CHAVE)
					cKeyQKX := QKX->QKX_CHAVE
				Endif
				
				DbselectArea(aArq[nCntFor,1])
				DbSkip()
			Else
				Exit
			Endif
		Enddo

	Next nCntFor
	
	If !Empty(cKeyQKQ)
		cKeyNew := GetSXENum("QKQ", "QKQ_CHAVE",,3)

		While (GetSX8Len() > nSaveSx8)
			ConfirmSX8()
		End

		bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
														QKO->QKO_CHAVE == cKeyQKQ .and.;
								  						QKO->QKO_ESPEC == cEspecie }

		bCConQKQ := { || ! Eof() .and. xFilial("QKQ") == QKQ_FILIAL .and.;
												QKQ_PECA == mv_par01 .and.;
												QKQ_REV == cRevNew }


		lOk := .F.

		For nCont := 1 To 8
			cEspecie := "PPA250" + StrZero(nCont,2)
			If DuplicQKO(cEspecie, cKeyQKQ, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
        		lOk := .T.
			Endif
		Next nCont

		DbSelectArea("QKQ")
		DbSetOrder(1)
		DbSeek(xFilial("QKQ") + mv_par01 + cRevNew)
		
		Do While Eval(bCConQKQ)
			If lOk
				RecLock("QKQ",.F.)
				QKQ->QKQ_CHAVE := cKeyNew
				MsUnlock()
			Else
				RecLock("QKQ",.F.)
				QKQ->QKQ_CHAVE := " "
				MsUnlock()
			Endif

			DbSkip()

		Enddo

	Endif

	If !Empty(cKeyQKR)
		cKeyNew := GetSXENum("QKR", "QKR_CHAVE",,3)

		While (GetSX8Len() > nSaveSx8)
			ConfirmSX8()
		End

		bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
														QKO->QKO_CHAVE == cKeyQKR .and.;
								  						QKO->QKO_ESPEC == cEspecie }

		bCConQKR := { || ! Eof() .and. xFilial("QKR") == QKR_FILIAL .and.;
												QKR_PECA == mv_par01 .and.;
												QKR_REV == cRevNew }


		lOk := .F.

		For nCont := 1 To 40
			cEspecie := "PPA260" + StrZero(nCont,2)
			If DuplicQKO(cEspecie, cKeyQKR, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
        		lOk := .T.
			Endif
		Next nCont

		DbSelectArea("QKR")
		DbSetOrder(1)
		DbSeek(xFilial("QKR") + mv_par01 + cRevNew)
		
		Do While Eval(bCConQKR)
			If lOk
				RecLock("QKR",.F.)
				QKR->QKR_CHAVE := cKeyNew
				MsUnlock()
			Else
				RecLock("QKR",.F.)
				QKR->QKR_CHAVE := " "
				MsUnlock()
			Endif

			DbSkip()

		Enddo

	Endif


	If !Empty(cKeyQKS)
		cKeyNew := GetSXENum("QKS", "QKS_CHAVE",,3)

		While (GetSX8Len() > nSaveSx8)
			ConfirmSX8()
		End

		bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
														QKO->QKO_CHAVE == cKeyQKS .and.;
								  						QKO->QKO_ESPEC == cEspecie }

		bCConQKS := { || ! Eof() .and. xFilial("QKS") == QKS_FILIAL .and.;
												QKS_PECA == mv_par01 .and.;
												QKS_REV == cRevNew }


		lOk := .F.

		For nCont := 1 To 20
			cEspecie := "PPA270" + StrZero(nCont,2)
			If DuplicQKO(cEspecie, cKeyQKS, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
        		lOk := .T.
			Endif
		Next nCont

		DbSelectArea("QKS")
		DbSetOrder(1)
		DbSeek(xFilial("QKS") + mv_par01 + cRevNew)
		
		Do While Eval(bCConQKS)
			If lOk
				RecLock("QKS",.F.)
				QKS->QKS_CHAVE := cKeyNew
				MsUnlock()
			Else
				RecLock("QKS",.F.)
				QKS->QKS_CHAVE := " "
				MsUnlock()
			Endif

			DbSkip()

		Enddo

	Endif


	If !Empty(cKeyQKT)
		cKeyNew := GetSXENum("QKT", "QKT_CHAVE",,3)

		While (GetSX8Len() > nSaveSx8)
			ConfirmSX8()
		End

		bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
														QKO->QKO_CHAVE == cKeyQKT .and.;
								  						QKO->QKO_ESPEC == cEspecie }

		bCConQKT := { || ! Eof() .and. xFilial("QKT") == QKT_FILIAL .and.;
												QKT_PECA == mv_par01 .and.;
												QKT_REV == cRevNew }


		lOk := .F.

		For nCont := 1 To 53
			cEspecie := "PPA280" + StrZero(nCont,2)
			If DuplicQKO(cEspecie, cKeyQKT, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
        		lOk := .T.
			Endif
		Next nCont

		DbSelectArea("QKT")
		DbSetOrder(1)
		DbSeek(xFilial("QKT") + mv_par01 + cRevNew)
		
		Do While Eval(bCConQKT)
			If lOk
				RecLock("QKT",.F.)
				QKT->QKT_CHAVE := cKeyNew
				MsUnlock()
			Else
				RecLock("QKT",.F.)
				QKT->QKT_CHAVE := " "
				MsUnlock()
			Endif

			DbSkip()

		Enddo

	Endif


	If !Empty(cKeyQKU)
		cKeyNew := GetSXENum("QKU", "QKU_CHAVE",,3)

		While (GetSX8Len() > nSaveSx8)
			ConfirmSX8()
		End

		bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
														QKO->QKO_CHAVE == cKeyQKU .and.;
								  						QKO->QKO_ESPEC == cEspecie }

		bCConQKU := { || ! Eof() .and. xFilial("QKU") == QKU_FILIAL .and.;
												QKU_PECA == mv_par01 .and.;
												QKU_REV == cRevNew }


		lOk := .F.

		For nCont := 1 To 13
			cEspecie := "PPA290" + StrZero(nCont,2)
			If DuplicQKO(cEspecie, cKeyQKU, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
        		lOk := .T.
			Endif
		Next nCont

		DbSelectArea("QKU")
		DbSetOrder(1)
		DbSeek(xFilial("QKU") + mv_par01 + cRevNew)
		
		Do While Eval(bCConQKU)
			If lOk
				RecLock("QKU",.F.)
				QKU->QKU_CHAVE := cKeyNew
				MsUnlock()
			Else
				RecLock("QKU",.F.)
				QKU->QKU_CHAVE := " "
				MsUnlock()
			Endif

			DbSkip()

		Enddo

	Endif

	If !Empty(cKeyQKV)
		cKeyNew := GetSXENum("QKV", "QKV_CHAVE",,3)

		While (GetSX8Len() > nSaveSx8)
			ConfirmSX8()
		End

		bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
														QKO->QKO_CHAVE == cKeyQKV .and.;
								  						QKO->QKO_ESPEC == cEspecie }

		bCConQKV := { || ! Eof() .and. xFilial("QKV") == QKV_FILIAL .and.;
												QKV_PECA == mv_par01 .and.;
												QKV_REV == cRevNew }


		lOk := .F.

		For nCont := 1 To 7
			cEspecie := "PPA300" + StrZero(nCont,2)
			If DuplicQKO(cEspecie, cKeyQKV, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
        		lOk := .T.
			Endif
		Next nCont

		DbSelectArea("QKV")
		DbSetOrder(1)
		DbSeek(xFilial("QKV") + mv_par01 + cRevNew)
		
		Do While Eval(bCConQKV)
			If lOk
				RecLock("QKV",.F.)
				QKV->QKV_CHAVE := cKeyNew
				MsUnlock()
			Else
				RecLock("QKV",.F.)
				QKV->QKV_CHAVE := " "
				MsUnlock()
			Endif

			DbSkip()

		Enddo

	Endif

	If !Empty(cKeyQKW)
		cKeyNew := GetSXENum("QKW", "QKW_CHAVE",,3)

		While (GetSX8Len() > nSaveSx8)
			ConfirmSX8()
		End

		bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
														QKO->QKO_CHAVE == cKeyQKW .and.;
								  						QKO->QKO_ESPEC == cEspecie }

		bCConQKW := { || ! Eof() .and. xFilial("QKW") == QKW_FILIAL .and.;
												QKW_PECA == mv_par01 .and.;
												QKW_REV == cRevNew }


		lOk := .F.

		For nCont := 1 To 13
			cEspecie := "PPA310" + StrZero(nCont,2)
			If DuplicQKO(cEspecie, cKeyQKW, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
        		lOk := .T.
			Endif
		Next nCont

		DbSelectArea("QKW")
		DbSetOrder(1)
		DbSeek(xFilial("QKW") + mv_par01 + cRevNew)
		
		Do While Eval(bCConQKW)
			If lOk
				RecLock("QKW",.F.)
				QKW->QKW_CHAVE := cKeyNew
				MsUnlock()
			Else
				RecLock("QKW",.F.)
				QKW->QKW_CHAVE := " "
				MsUnlock()
			Endif

			DbSkip()

		Enddo

	Endif

	If !Empty(cKeyQKX)
		cKeyNew := GetSXENum("QKX", "QKX_CHAVE",,3)

		While (GetSX8Len() > nSaveSx8)
			ConfirmSX8()
		End

		bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
														QKO->QKO_CHAVE == cKeyQKX .and.;
								  						QKO->QKO_ESPEC == cEspecie }

		bCConQKX := { || ! Eof() .and. xFilial("QKX") == QKX_FILIAL .and.;
												QKX_PECA == mv_par01 .and.;
												QKX_REV == cRevNew }


		lOk := .F.

		For nCont := 1 To 13
			cEspecie := "PPA320" + StrZero(nCont,2)
			If DuplicQKO(cEspecie, cKeyQKX, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
        		lOk := .T.
			Endif
		Next nCont

		DbSelectArea("QKX")
		DbSetOrder(1)
		DbSeek(xFilial("QKX") + mv_par01 + cRevNew)
		
		Do While Eval(bCConQKX)
			If lOk
				RecLock("QKX",.F.)
				QKX->QKX_CHAVE := cKeyNew
				MsUnlock()
			Else
				RecLock("QKX",.F.)
				QKX->QKX_CHAVE := " "
				MsUnlock()
			Endif

			DbSkip()

		Enddo

	Endif


	
Else  //alteracao

	For nCntFor := 1 To Len(aArq)
		oSelf:IncRegua1(LTrim(Str(nCntFor)))
			
		aArqRec	:= {}

		DbselectArea(aArq[nCntFor,1])
		DbSetOrder(aArq[nCntFor,5])
		DbSeek(xFilial()+aArq[nCntFor,2])
	
		Do While Eval(aArq[nCntFor,4])
			aAdd(aArqRec, Recno())  //alimenta array com os enderecos a serem alterados
			DbSkip()
		Enddo

		If Len(aArqRec) > 0

			For nCon := 1 To Len(aArqRec)
				DbGoTo(aArqRec[nCon])

				If !Empty(aArq[nCntFor,3])
					RecLock(aArq[nCntFor,1],.F.)
					Eval(aArq[nCntFor,3])   // efetua a alteracao via codeblock
					MsUnLock()
					FkCommit()				
				Endif				
			Next nCon

		Endif

	Next nCntFor
Endif

End Transaction

If Len(aArq) > 0
	MsgInfo(OemToAnsi(STR0020), OemToAnsi(STR0021)) //"Revisao Gerada com Sucesso !!!"###"Geracao de Revisao PPAP"
	lReturn := .T.
Else
	MsgInfo(OemToAnsi(STR0022), OemToAnsi(STR0021)) //"Nao Houve Geracao de Revisao !!!"###"Geracao de Revisao PPAP"
	lReturn := .F.
Endif

Return lReturn


/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPPM010Vrev╨Autor  ЁDenis Martins       ╨ Data Ё  01/27/05   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё QPPM010                                                    ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PPM010Vrev() 
Local lRet := .T.           

If !IsDigit(SubStr(mv_par02,1,1)) .or. !IsDigit(SubStr(mv_par02,2,1))
	lRet := .F.
Else
	lRet := ExistCpo("QK1",mv_par01+mv_par02,1)
	If Val(mv_par02) > 99
		MessageDlg(OemToAnsi(STR0035),,1)	//"Maximo numero de revisao da peca. Nao sera possivel a duplicacao!!"
		lRet := .F.
	Endif
Endif

Return lRet           

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o	 Ё A010VPro   Ё Autor Ё Cicero Cruz     	  Ё Data Ё 04/04/06 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Atualiza descricao do Produto de acordo com a opcao escolhidaЁ╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso		 Ё X1_VALID                               						Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function QPM010VDesc()  
Local lRet   := .T.
Local cDes   := MV_PAR06  
        
If (MV_PAR07 == 2)
	QK1->(dbSetOrder(1))
	If QK1->(DbSeek(xFilial("QK1")+MV_PAR01+MV_PAR02))
		cDes := QK1->QK1_DESC
	EndIf
EndIf       

MV_PAR06 := cDes
Return(lRet)

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o	 Ё A010VPro   Ё Autor Ё Cicero Cruz     	  Ё Data Ё 04/04/06 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Atualiza descricao do Produto de acordo com a opcao escolhidaЁ╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso		 Ё X1_VALID                               						Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function QPM010VPR()  
Local lRet   := .T.
Local cDesP   := MV_PAR09
Local cDesR   := MV_PAR10
        
If (MV_PAR08 == 2)
	cDesP := Space(15)
	cDesR := Space(2)
EndIf       

MV_PAR09 := cDesP
MV_PAR10 := cDesR
Return(lRet)
