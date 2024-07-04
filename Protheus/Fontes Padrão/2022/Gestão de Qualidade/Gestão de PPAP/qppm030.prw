#INCLUDE "QPPM030.CH"
#INCLUDE "PROTHEUS.CH"

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё QPPM030	  Ё Autor Ё Robson Ramiro A. OliveЁ Data Ё 04/07/03 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Exclui Todo PPAP         					  				Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё QPPM030()                                                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Void                                                         Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso		 Ё SIGAPPAP				                 					    Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       Ё╠╠
╠╠цддддддддддддддбддддддддбдддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё PROGRAMADOR  Ё DATA   Ё BOPS  Ё MOTIVO DA ALTERACAO                     Ё╠╠
╠╠цддддддддддддддеддддддддедддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддддаддддддддадддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function QPPM030

Local cFuncao	:= "QPPM030"
Local cPergunte	:= ""	//"PPM030"
Local cTitulo	:= OemToAnsi( STR0008 )		//"Exclusao do PPAP"
Local cDescricao:= ""
Local bProcessa	:= {|oSelf| QPPM030PROC(oSelf) }

Private cPRODUT	:= ""
Private cREVI	:= ""

Do While .T.

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Variaveis utilizadas para parametros							Ё
	//Ё mv_par01				// Peca        	   						Ё
	//Ё mv_par02				// Revisao         						Ё
	//Ё mv_par03  				// Todo PPAP Sim/Nao   					Ё
	//Ё mv_par04  				// Peca Sim/Nao       					Ё
	//Ё mv_par05  				// Operacoes Sim/Nao       				Ё
	//Ё mv_par06  				// Cronograma Sim/Nao 					Ё
	//Ё mv_par07  				// Viabilidade Sim/Nao 					Ё
	//Ё mv_par08  				// Estudo de RR Sim/Nao     			Ё
	//Ё mv_par09  				// Capabilidade Sim/Nao					Ё
	//Ё mv_par10  				// Ensaio Dimensional Sim/Nao   		Ё
	//Ё mv_par11  				// Ensaio Material Sim/Nao              Ё
	//Ё mv_par12  				// Ensaio Desempenho Sim/Nao            Ё
	//Ё mv_par13  				// Aprovac. Aparencia                 	Ё
	//Ё mv_par14  				// Certif. Submissao                 	Ё
	//Ё mv_par15  				// Plano de Controle                 	Ё
	//Ё mv_par16  				// FMEA Projeto                 		Ё
	//Ё mv_par17  				// FMEA Processo                 		Ё
	//Ё mv_par18  				// Sumario e APQP                 		Ё
	//Ё mv_par19  				// Diagrama de Fluxo                 	Ё
	//Ё mv_par20  				// Aprovacao Interina-GM                Ё
	//Ё mv_par21  				// Checklist APQP A1 A8                 Ё
	//Ё mv_par22  				// Checklist Granel                     Ё
	//Ё mv_par23  				// PSA                                  Ё
	//Ё mv_par24  				// VDA                                  Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	If Pergunte("PPM030",.T.)

		QK1->(DbSetOrder(1))
		If !(QK1->(DbSeek(xFilial("QK1")+mv_par01+mv_par02)))
			MsgAlert(OemToAnsi(STR0001)) //"Peca e Revisao Nao Existem"
			Loop
		Endif

		cPRODUT	:= QK1->QK1_PRODUT
		cREVI	:= QK1->QK1_REVI

		If mv_par04 == 1 .and. mv_par03 == 2
			If MsgYesNo(OemToAnsi(STR0002)) //"Optando pela exclusao da Peca todo PPAP sera excluido, confirma ?"
				mv_par03 := 1
			Else
				Loop
			Endif
		Endif

		If mv_par05 == 1 .and. mv_par03 == 2
			If !MsgYesNo(OemToAnsi(STR0003)) //"Se as Operacoes forem excluidas, sua dependencias tambem serao, confirma ?"
				Loop
			Endif
		Endif
			
		If MsgYesNo(OemToAnsi(STR0004)) //"Essa rotina excluira todos os processos selecionados, confirma ?"
			//Sintaxe: tNewProcess():New( <cFunction> , <cTitle> , <bProcess> ,<cDescription> ,[ cPerg ],[ aInfoCustom ], [lPanelAux], [nSizePanelAux], [cDescriAux], [lViewExecute] , [lOneMeter] )
			tNewProcess():New( cFuncao, cTitulo, bProcessa , cDescricao, cPergunte,,,,,, .T. )
		Else
			Exit
		Endif
	
	Else
		Exit
	Endif
Enddo

Return Nil

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё QPPM030PROCЁ Autor Ё Robson Ramiro A. OliveЁ Data Ё 03/10/01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Executa a Exclusao      					  				    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё QPPM030PROC()                                                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Void                                                         Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso		 Ё SIGAPPAP				                 					    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function QPPM030PROC(oSelf)

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Variaveis 														  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local bCConQK1,bCConQK2,bCConQKK,bCConQKG,bCConQKP,bCConQKF,bCConQK9,bCConQKA 	// Condicao para exclusao
Local bCConQKB,bCConQKD,bCConQKC,bCConQK3,bCConQK4,bCConQKI,bCConQKL,bCConQKM,bCConQKJ 	
Local bCConQK5,bCConQK6,bCConQK7,bCConQK8,bCConQKN,bCConQKH,bCConQM4,bCConQM5
Local bCConQKQ,bCConQKR,bCConQKS,bCConQKT,bCConQKU,bCConQKV,bCConQKW,bCConQKX,bCConQKY
Local bCConQL0,bCConQL1,bCConQL2,bCConQL3,bCConQL4

Local aArq				// Array de arquivos para exclusao
Local cEspecie 			// Especie
Local nCntFor
Local nCont
Local cKeyQKQ := ""
Local cKeyQKR := ""
Local cKeyQKS := ""
Local cKeyQKT := ""
Local cKeyQKU := ""
Local cKeyQKV := ""
Local cKeyQKW := ""
Local cKeyQKX := ""
Local cTemp
		
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa Array 											 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aArq := {}


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inclusao dos Alias a serem excluidos, na ordem Filho -> Pai	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKP, Detail do Cronograma       					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды							
bCConQKP := { || ! Eof() .and. xFilial("QKP") == QKP_FILIAL .and.;
											  QKP_PECA == mv_par01 .and.;
											  QKP_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par06 == 1 // Todo PPAP ou Cronograma
	aAdd( aArq, { "QKP", mv_par01+mv_par02, bCConQKP, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKG, Cabecalho do Cronograma       					 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды							
bCConQKG := { || ! Eof() .and. xFilial("QKG") == QKG_FILIAL .and.;
											  QKG_PECA == mv_par01 .and.;
											  QKG_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par06 == 1 // Todo PPAP ou Cronograma
	aAdd( aArq, { "QKG", mv_par01+mv_par02, bCConQKG, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKF, Viabilidade                					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды							
bCConQKF := { || ! Eof() .and. xFilial("QKF") == QKF_FILIAL .and.;
											  QKF_PECA == mv_par01 .and.;
											  QKF_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par07 == 1 // Todo PPAP ou Viabilidade
	aAdd( aArq, { "QKF", mv_par01+mv_par02, bCConQKF, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QM5, Details do RR       						         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды							
bCConQM5 := { || ! Eof() .and. xFilial("QM5") == QM5_FILIAL .and.;
											  QM5_PECA1 == mv_par01 .and.;
											  QM5_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par08 == 1 // Todo PPAP ou RR
	aAdd( aArq, { "QM5", mv_par01+mv_par02, bCConQM5, 2 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QM4, Cabecalho do RR       						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды							
bCConQM4 := { || ! Eof() .and. xFilial("QM4") == QM4_FILIAL .and.;
											  QM4_PECA1 == mv_par01 .and.;
											  QM4_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par08 == 1 // Todo PPAP ou RR
	aAdd( aArq, { "QM4", mv_par01+mv_par02, bCConQM4, 3 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKA, Detail da Capabilidade     					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды							
bCConQKA := { || ! Eof() .and. xFilial("QKA") == QKA_FILIAL .and.;
											  QKA_PECA == mv_par01 .and.;
											  QKA_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par09 == 1 // Todo PPAP ou Capabilidade
	aAdd( aArq, { "QKA", mv_par01+mv_par02, bCConQKA, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK9, Cabecalho Capabilidade     					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQK9 := { || ! Eof() .and. xFilial("QK9") == QK9_FILIAL .and.;
											  QK9_PECA == mv_par01 .and.;
											  QK9_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par09 == 1 // Todo PPAP ou Capabilidade
	aAdd( aArq, { "QK9", mv_par01+mv_par02, bCConQK9, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKB, Enasio Dimensional        					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQKB := { || ! Eof() .and. xFilial("QKB") == QKB_FILIAL .and.;
											  QKB_PECA == mv_par01 .and.;
											  QKB_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par10 == 1 // Todo PPAP ou Dimensional
	aAdd( aArq, { "QKB", mv_par01+mv_par02, bCConQKB, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKD, Enasio Material           					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды							
bCConQKD := { || ! Eof() .and. xFilial("QKD") == QKD_FILIAL .and.;
											  QKD_PECA == mv_par01 .and.;
											  QKD_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par11 == 1 // Todo PPAP ou Material
	aAdd( aArq, { "QKD", mv_par01+mv_par02, bCConQKD, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKC, Enasio Desempenho           					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQKC := { || ! Eof() .and. xFilial("QKC") == QKC_FILIAL .and.;
											  QKC_PECA == mv_par01 .and.;
											  QKC_REV == mv_par02 }
If mv_par03 == 1 .or. mv_par12 == 1 // Todo PPAP ou Desempenho
	aAdd( aArq, { "QKC", mv_par01+mv_par02, bCConQKC, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK4, Details Aprovacao de Aparencia  			         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQK4 := { || ! Eof() .and. xFilial("QK4") == QK4_FILIAL .and.;
											  QK4_PECA == mv_par01 .and.;
											  QK4_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par13 == 1 // Todo PPAP ou Aprov. Aparencia
	aAdd( aArq, { "QK4", mv_par01+mv_par02, bCConQK4, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK3, Cabecalho Aprovacao de Aparencia  			     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды							
bCConQK3 := { || ! Eof() .and. xFilial("QK3") == QK3_FILIAL .and.;
											  QK3_PECA == mv_par01 .and.;
											  QK3_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par13 == 1 // Todo PPAP ou Aprov. Aparencia
	aAdd( aArq, { "QK3", mv_par01+mv_par02, bCConQK3, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKI, Certificado de Submissao     			         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQKI := { || ! Eof() .and. xFilial("QKI") == QKI_FILIAL .and.;
											  QKI_PECA == mv_par01 .and.;
											  QKI_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par14 == 1 // Todo PPAP ou Certificado
	aAdd( aArq, { "QKI", mv_par01+mv_par02, bCConQKI, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKM, Details do Plano de Controle  			         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQKM := { || ! Eof() .and. xFilial("QKI") == QKM_FILIAL .and.;
											  QKM_PECA == mv_par01 .and.;
											  QKM_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par15 == 1 .or. mv_par05 == 1  // Todo PPAP ou Plano de Controle
	aAdd( aArq, { "QKM", mv_par01+mv_par02, bCConQKM, 1 } )
Endif
 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKL, Cabecalho do Plano de Controle  			         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQKL := { || ! Eof() .and. xFilial("QKI") == QKL_FILIAL .and.;
											  QKL_PECA == mv_par01 .and.;
											  QKL_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par15 == 1 .or. mv_par05 == 1	// Todo PPAP ou Plano de Controle
	aAdd( aArq, { "QKL", mv_par01+mv_par02, bCConQKL, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK6, Details FMEA Projeto							     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды							
bCConQK6 := { || ! Eof() .and. xFilial("QK6") == QK6_FILIAL .and.;
											  QK6_PECA == mv_par01 .and.;
											  QK6_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par16 == 1 // Todo PPAP ou FMEA Projeto
	aAdd( aArq, { "QK6", mv_par01+mv_par02, bCConQK6, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK5, Cabecalho FMEA Projeto							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды							
bCConQK5 := { || ! Eof() .and. xFilial("QK5") == QK5_FILIAL .and.;
											  QK5_PECA == mv_par01 .and.;
											  QK5_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par16 == 1 // Todo PPAP ou FMEA Projeto
	aAdd( aArq, { "QK5", mv_par01+mv_par02, bCConQK5, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK8, Details FMEA Processo						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды							
bCConQK8 := { || ! Eof() .and. xFilial("QK8") == QK8_FILIAL .and.;
											  QK8_PECA == mv_par01 .and.;
											  QK8_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par17 == 1 .or. mv_par05 == 1 	// Todo PPAP ou FMEA Processo
	aAdd( aArq, { "QK8", mv_par01+mv_par02, bCConQK8, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK7, Cabecalho FMEA Processo							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQK7 := { || ! Eof() .and. xFilial("QK7") == QK7_FILIAL .and.;
											  QK7_PECA == mv_par01 .and.;
											  QK7_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par17 == 1 .or. mv_par05 == 1 	// Todo PPAP ou FMEA Processo
	aAdd( aArq, { "QK7", mv_par01+mv_par02, bCConQK7, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKJ, Sumario e APQP        							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды							
bCConQKJ := { || ! Eof() .and. xFilial("QKJ") == QKJ_FILIAL .and.;
											  QKJ_PECA == mv_par01 .and.;
											  QKJ_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par18 == 1 // Todo PPAP ou Sumario e APQP
	aAdd( aArq, { "QKJ", mv_par01+mv_par02, bCConQKJ, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKN, Diagrama de Fluxo    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды							
bCConQKN := { || ! Eof() .and. xFilial("QKN") == QKN_FILIAL .and.;
											  QKN_PECA == mv_par01 .and.;
											  QKN_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par19 == 1 .or. mv_par05 == 1	// Todo PPAP ou Diagrama de Fluxo
	aAdd( aArq, { "QKN", mv_par01+mv_par02, bCConQKN, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKH, Aprovacao Interina    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQKH := { || ! Eof() .and. xFilial("QKH") == QKH_FILIAL .and.;
											  QKH_PECA == mv_par01 .and.;
											  QKH_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par20 == 1 // Todo PPAP ou Aprov. Interina
	aAdd( aArq, { "QKH", mv_par01+mv_par02, bCConQKH, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKQ, Checklist APQP A1    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQKQ := { || ! Eof() .and. xFilial("QKQ") == QKQ_FILIAL .and.;
												QKQ_PECA == mv_par01 .and.;
												QKQ_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par21 == 1 // Todo PPAP ou Checklist APQP
	aAdd( aArq, { "QKQ", mv_par01+mv_par02, bCConQKQ, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKR, Checklist APQP A2    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQKR := { || ! Eof() .and. xFilial("QKR") == QKR_FILIAL .and.;
												QKR_PECA == mv_par01 .and.;
												QKR_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par21 == 1 // Todo PPAP ou Checklist APQP
	aAdd( aArq, { "QKR", mv_par01+mv_par02, bCConQKR, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKS, Checklist APQP A3    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды							
bCConQKS := { || ! Eof() .and. xFilial("QKS") == QKS_FILIAL .and.;
												QKS_PECA == mv_par01 .and.;
												QKS_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par21 == 1 // Todo PPAP ou Checklist APQP
	aAdd( aArq, { "QKS", mv_par01+mv_par02, bCConQKS, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKT, Checklist APQP A4    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQKT := { || ! Eof() .and. xFilial("QKT") == QKT_FILIAL .and.;
												QKT_PECA == mv_par01 .and.;
												QKT_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par21 == 1 // Todo PPAP ou Checklist APQP
	aAdd( aArq, { "QKT", mv_par01+mv_par02, bCConQKT, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKU, Checklist APQP A5    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQKU := { || ! Eof() .and. xFilial("QKU") == QKU_FILIAL .and.;
												QKU_PECA == mv_par01 .and.;
												QKU_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par21 == 1 // Todo PPAP ou Checklist APQP
	aAdd( aArq, { "QKU", mv_par01+mv_par02, bCConQKU, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKV, Checklist APQP A6    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQKV := { || ! Eof() .and. xFilial("QKV") == QKV_FILIAL .and.;
												QKV_PECA == mv_par01 .and.;
												QKV_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par21 == 1 // Todo PPAP ou Checklist APQP
	aAdd( aArq, { "QKV", mv_par01+mv_par02, bCConQKV, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKW, Checklist APQP A7    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQKW := { || ! Eof() .and. xFilial("QKW") == QKW_FILIAL .and.;
												QKW_PECA == mv_par01 .and.;
												QKW_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par21 == 1 // Todo PPAP ou Checklist APQP
	aAdd( aArq, { "QKW", mv_par01+mv_par02, bCConQKW, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKX, Checklist APQP A8    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды							
bCConQKX := { || ! Eof() .and. xFilial("QKX") == QKX_FILIAL .and.;
												QKX_PECA == mv_par01 .and.;
												QKX_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par21 == 1 // Todo PPAP ou Checklist APQP
	aAdd( aArq, { "QKX", mv_par01+mv_par02, bCConQKX, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKY, Checklist Granel     						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQKY := { || ! Eof() .and. xFilial("QKY") == QKY_FILIAL .and.;
												QKY_PECA == mv_par01 .and.;
												QKY_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par22 == 1 // Todo PPAP ou Checklist Granel
	aAdd( aArq, { "QKY", mv_par01+mv_par02, bCConQKY, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QL0, PSA                  						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды							
bCConQL0 := { || ! Eof() .and. xFilial("QL0") == QL0_FILIAL .and.;
												QL0_PECA == mv_par01 .and.;
												QL0_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par23 == 1 // Todo PPAP ou PSA
	aAdd( aArq, { "QL0", mv_par01+mv_par02, bCConQL0, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QL1, VDA Amostras Iniciais   						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQL1 := { || ! Eof() .and. xFilial("QL1") == QL1_FILIAL .and.;
												QL1_PECA == mv_par01 .and.;
												QL1_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par24 == 1 // Todo PPAP ou VDA
	aAdd( aArq, { "QL1", mv_par01+mv_par02, bCConQL1, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QL3, Detail do VDA Folha de Capa  				     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQL3 := { || ! Eof() .and. xFilial("QL3") == QL3_FILIAL .and.;
												QL3_PECA == mv_par01 .and.;
												QL3_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par24 == 1 // Todo PPAP ou VDA
	aAdd( aArq, { "QL3", mv_par01+mv_par02, bCConQL3, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QL2, VDA Folha de Capa       						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды							
bCConQL2 := { || ! Eof() .and. xFilial("QL2") == QL2_FILIAL .and.;
												QL2_PECA == mv_par01 .and.;
												QL2_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par24 == 1 // Todo PPAP ou VDA
	aAdd( aArq, { "QL2", mv_par01+mv_par02, bCConQL2, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QL4, Peca X Produto							         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQL4 := { || ! Eof() .and. xFilial("QL4") == QL4_FILIAL .and.;
												QL4_PECA == mv_par01 .and.;
												QL4_REV == mv_par02 .and.;
												QL4_PRODUT == cPRODUT .and.;
												QL4_REVI == cREVI }

If !Empty(cPRODUT) .and. (mv_par03 == 1 .or. mv_par04 == 1) // Todo PPAP ou Peca
	aAdd( aArq, { "QL4", mv_par01+mv_par02+cPRODUT+cREVI, bCConQL4, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKK, Operacoes                     					 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды							
bCConQKK := { || ! Eof() .and. xFilial("QKK") == QKK_FILIAL .and.;
											  QKK_PECA == mv_par01 .and.;
											  QKK_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par05 == 1		// Todo PPAP ou Operacoes
	aAdd( aArq, { "QKK", mv_par01+mv_par02, bCConQKK, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK2, Caracteristica das Pecas						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды						
bCConQK2 := { || ! Eof() .and. xFilial("QK2") == QK2_FILIAL .and.;
											  QK2_PECA == mv_par01 .and.;
											  QK2_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par04 == 1 // Todo PPAP ou Peca
	aAdd( aArq, { "QK2", mv_par01+mv_par02, bCConQK2, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK1, Cadastro de Pecas						         Ё 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCConQK1 := { || ! Eof() .and. xFilial("QK1") == QK1_FILIAL .and.;
											  QK1_PECA == mv_par01 .and.;
											  QK1_REV == mv_par02 }

If mv_par03 == 1 .or. mv_par04 == 1 // Todo PPAP ou Peca
	aAdd( aArq, { "QK1", mv_par01+mv_par02, bCConQK1, 1 } )
Endif

//здддддддддддддддддддд©
//Ё Efetiva Exclusao   Ё
//юдддддддддддддддддддды

If Len(aArq) <= 3
	cTemp := ""
	For nCntFor := 1 To Len(aArq)
		cTemp := cTemp + aArq[nCntFor,1]
	Next nCntFor
	If "QKK"$cTemp .or. "QK2QK1"$cTemp
		Alert(STR0005) //"Nao e permitdo excluir somente os cadastos principais !"
		Return Nil
	Endif
Endif
		
oSelf:SetRegua1(Len(aArq))

Begin Transaction
		
For nCntFor := 1 To Len(aArq)
	oSelf:IncRegua1(LTrim(Str(nCntFor)))

	DbselectArea(aArq[nCntFor,1])
	DbSetOrder(aArq[nCntFor,4])
	DbSeek(xFilial()+aArq[nCntFor,2])
	
	Do While Eval(aArq[nCntFor,3])

		// QK3
		If Alias() == "QK3" .and. !Empty(QK3->QK3_CHAVE)
			cEspecie := "QPPA210 "
			QO_DelTxt(QK3->QK3_CHAVE,cEspecie)
		Endif

		// QKK
		If Alias() == "QKK" .and. !Empty(QKK->QKK_CHAVE)			
			cEspecie := "QPPA020 "
			QO_DelTxt(QKK->QKK_CHAVE,cEspecie)
		Endif
			
		// QKG
		If Alias() == "QKG" .and. !Empty(QKG->QKG_CHAVE)
			cEspecie := "QPPA110A"
			QO_DelTxt(QKG->QKG_CHAVE,cEspecie)
		Endif
		
		// QKI
		If Alias() == "QKI" .and. !Empty(QKI->QKI_CHAVE)
			cEspecie := "QPPA220 "
			QO_DelTxt(QKI->QKI_CHAVE,cEspecie)
		Endif

		// QKP
		If Alias() == "QKP" .and. !Empty(QKP->QKP_CHAVE)
			cEspecie := "QPPA110 "
			QO_DelTxt(QKP->QKP_CHAVE,cEspecie)
		Endif
		
		// QKF
		If Alias() == "QKF" .and. !Empty(QKF->QKF_CHAVE)
			cEspecie := "QPPA140 "
			QO_DelTxt(QKF->QKF_CHAVE,cEspecie)
		Endif

		// QK9
		If Alias() == "QK9" .and. !Empty(QK9->QK9_CHAVE)
			cEspecie := "QPPA170 "
			QO_DelTxt(QK9->QK9_CHAVE,cEspecie)
		Endif
		
		// QKB
		If Alias() == "QKB" .and. !Empty(QKB->QKB_CHAVE)
			cEspecie := "QPPA180 "
			QO_DelTxt(QKB->QKB_CHAVE,cEspecie)
		Endif

		// QKD
		If Alias() == "QKD" .and. !Empty(QKD->QKD_CHAVE)
			cEspecie := "QPPA190 "
			QO_DelTxt(QKD->QKD_CHAVE,cEspecie)
		Endif
		
		// QKC
		If Alias() == "QKC" .and. !Empty(QKC->QKC_CHAVE)
			cEspecie := "QPPA200 "
			QO_DelTxt(QKC->QKC_CHAVE,cEspecie)
		Endif

		// QKJ
		If Alias() == "QKJ" .and. !Empty(QKJ->QKJ_CHAVE)
			cEspecie := "QPPA230 "
			QO_DelTxt(QKJ->QKJ_CHAVE,cEspecie)
		Endif
		
		// QK6 - Processo diferenciado pois existem 8 especies (A...H)
		If Alias() == "QK6" .and. !Empty(QK6->QK6_CHAVE1)
			For nCont := 1 To 8
				cEspecie := "QPPA120" + Subs("ABCDEFGH",nCont,1)
				QO_DelTxt(QK6->QK6_CHAVE1,cEspecie)
			Next nCont
		Endif

		// QK8 - Processo diferenciado pois existem 8 especies (A...H)
		If Alias() == "QK8" .and. !Empty(QK8->QK8_CHAVE1)
			For nCont := 1 To 8
				cEspecie := "QPPA130" + Subs("ABCDEFGH",nCont,1)
				QO_DelTxt(QK8->QK8_CHAVE1,cEspecie)
			Next nCont
		Endif
		
		// QKH - Processo diferenciado pois existem 4 especies (A...D)
		If Alias() == "QKH" .and. !Empty(QKH->QKH_CHAV01)
			For nCont := 1 To 4
				cEspecie := "QPPA240" + Subs("ABCD",nCont,1)
				QO_DelTxt(QKH->QKH_CHAV01,cEspecie)
			Next nCont
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
		
		RecLock(aArq[nCntFor,1],.F.)
		DbDelete()
		MsUnlock()

		DbSkip()
		
	Enddo
Next nCntFor

If !Empty(cKeyQKQ)
	For nCont := 1 To 8
		cEspecie := "PPA250" + StrZero(nCont,2)
		QO_DelTxt(cKeyQKQ,cEspecie)
	Next nCont
Endif

If !Empty(cKeyQKR)
	For nCont := 1 To 40
		cEspecie := "PPA260" + StrZero(nCont,2)
		QO_DelTxt(cKeyQKR,cEspecie)
	Next nCont
Endif

If !Empty(cKeyQKS)
	For nCont := 1 To 20
		cEspecie := "PPA270" + StrZero(nCont,2)
		QO_DelTxt(cKeyQKS,cEspecie)
	Next nCont
Endif

If !Empty(cKeyQKT)
	For nCont := 1 To 53
		cEspecie := "PPA280" + StrZero(nCont,2)
		QO_DelTxt(cKeyQKT,cEspecie)
	Next nCont
Endif

If !Empty(cKeyQKU)
	For nCont := 1 To 13
		cEspecie := "PPA290" + StrZero(nCont,2)
		QO_DelTxt(cKeyQKU,cEspecie)
	Next nCont
Endif

If !Empty(cKeyQKV)
	For nCont := 1 To 7
		cEspecie := "PPA300" + StrZero(nCont,2)
		QO_DelTxt(cKeyQKV,cEspecie)
	Next nCont
Endif

If !Empty(cKeyQKW)
	For nCont := 1 To 13
		cEspecie := "PPA310" + StrZero(nCont,2)
		QO_DelTxt(cKeyQKW,cEspecie)
	Next nCont
Endif

If !Empty(cKeyQKX)
	For nCont := 1 To 13
		cEspecie := "PPA320" + StrZero(nCont,2)
		QO_DelTxt(cKeyQKX,cEspecie)
	Next nCont
Endif

End Transaction

If Len(aArq) > 0
	MsgInfo(OemToAnsi(STR0007), OemToAnsi(STR0008)) //"Exclusao Concluida !!!"###"Exclusao do PPAP"
Else
	MsgInfo(OemToAnsi(STR0009), OemToAnsi(STR0008)) //"Nao Houve Exclusao !!!"###"Exclusao do PPAP"
Endif

Return Nil