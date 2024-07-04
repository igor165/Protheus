#INCLUDE "QPPM020.CH"
#INCLUDE "PROTHEUS.CH"


/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё QPPM020	  Ё Autor Ё Robson Ramiro A. OliveЁ Data Ё 02/10/01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Duplica PPAP         					  				    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё QPPM020()                                                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Void                                                         Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso		 Ё SIGAPPAP				                 					    Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       Ё╠╠
╠╠цддддддддддддддбддддддддбдддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё PROGRAMADOR  Ё DATA   Ё BOPS  Ё MOTIVO DA ALTERACAO                     Ё╠╠
╠╠цддддддддддддддеддддддддедддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Robson RamiroЁ18.02.02Ё VersaoЁ Retirada a Funcao AjustaSX1 para 7.10   Ё╠╠
╠╠Ё Robson RamiroЁ13.03.02Ё VersaoЁ Inclusao do alias QKH-Aprovacao InterinaЁ╠╠
╠╠Ё Robson RamiroЁ06.09.02Ё xMETA Ё Troca da QA_CVKEY por GetSXENum         Ё╠╠
╠╠юддддддддддддддаддддддддадддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function QPPM020

Local cFuncao	:= "QPPM020"
Local cPergunte	:= ""	//"PPM020"
Local cTitulo	:= OemToAnsi( STR0021 )		//"Duplicacao do PPAP"
Local cDescricao:= ""
Local bProcessa	:= {|oSelf| QPPM020PROC(oSelf) }

DbSelectArea("QKM")                            

Do While .T.
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Variaveis utilizadas para parametros							Ё
	//Ё mv_par01				// Peca Origem							Ё
	//Ё mv_par02				// Revisao Origem 						Ё
	//Ё mv_par03				// Peca Destino							Ё
	//Ё mv_par04				// Revisao Destino						Ё
	//Ё mv_par05  				// Todo PPAP Sim/Nao   					Ё
	//Ё mv_par06  				// Peca Sim/Nao       					Ё
	//Ё mv_par07  				// Operacoes Sim/Nao       				Ё
	//Ё mv_par08  				// Cronograma Sim/Nao 					Ё
	//Ё mv_par09  				// Viabilidade Sim/Nao 					Ё
	//Ё mv_par10  				// Estudo de RR Sim/Nao     			Ё
	//Ё mv_par11  				// Capabilidade Sim/Nao					Ё
	//Ё mv_par12  				// Ensaio Dimensional Sim/Nao   		Ё
	//Ё mv_par13  				// Ensaio Material Sim/Nao              Ё
	//Ё mv_par14  				// Ensaio Desempenho Sim/Nao            Ё
	//Ё mv_par15  				// Aprovac. Aparencia                 	Ё
	//Ё mv_par16  				// Certif. Submissao                 	Ё
	//Ё mv_par17  				// Plano de Controle                 	Ё
	//Ё mv_par18  				// FMEA Projeto                 		Ё
	//Ё mv_par19  				// FMEA Processo                 		Ё
	//Ё mv_par20  				// Sumario e APQP                 		Ё
	//Ё mv_par21  				// Diagrama de Fluxo                 	Ё
	//Ё mv_par22  				// Aprovacao Interina-GM                Ё
	//Ё mv_par23  				// Checklist APQP A1 A8                 Ё
	//Ё mv_par24  				// Checklist Granel                     Ё
	//Ё mv_par25  				// PSA                                  Ё
	//Ё mv_par26  				// VDA                                  Ё
	//Ё mv_par27  				// Fase de ProduГЦo                     Ё
	//Ё mv_par28  				// DescriГЦo da PeГa                    Ё
	//Ё mv_par29  				// Origem DescriГЦo                     Ё
	//Ё mv_par30  				// Altera Codigo Produto                Ё
	//Ё mv_par31  				// Codigo Produto                       Ё
	//Ё mv_par32  				// RevisЦo                              Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If Pergunte("PPM020",.T.)

    	If Empty(mv_par03) .or. Empty(mv_par04)
    		Alert(OemToAnsi(STR0032)) //"Preencha Peca e Revisao destino !"
    		Loop
    	Endif
	
		QK1->(DbSetOrder(1))
		If !(QK1->(DbSeek(xFilial("QK1")+mv_par01+mv_par02)))
			MsgAlert(OemToAnsi(STR0001)) //"Peca e Revisao de Origem Nao Existem"
			Loop
		EndIf

		If mv_par01 == mv_par03
			Alert(OemToAnsi(STR0033)) //"Nao e permitido gerar revisao atraves da rotina de duplicacao "
			Loop
		Endif
		// Mudanca no conceito
		If QK1->(DbSeek(xFilial("QK1")+mv_par03+mv_par04))
			MsgAlert(OemToAnsi(STR0002)) //"Peca e Revisao Destino Ja Existem"
			Loop
		Endif
		
		If mv_par05 == 1 .or. mv_par07 == 1 .or. mv_par17 == 1 ;	// Mudanca no conceito devido a Integridade Referencial
			.or. mv_par19 == 1 .or. mv_par21 == 1 					// Todo PPAP, Operacoes, Plano de Controle, FMEA Processo, Fluxograma
			
			QKK->(DbSetOrder(1))
			If QKK->(DbSeek(xFilial("QKK")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0003)) //"Peca e Revisao Destino Ja Existem Nas Operacoes"
				Loop
			EndIf
		Endif

		If mv_par08 == 1 .or. mv_par05 == 1 // Cronograma
			QKG->(DbSetOrder(1))
			If QKG->(DbSeek(xFilial("QKG")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0004)) //"Peca e Revisao Destino Ja Existem No Cronograma"
				Loop
			EndIf
		Endif
			
		If mv_par09 == 1 .or. mv_par05 == 1 // Viabilidade
			QKF->(DbSetOrder(1))
			If QKF->(DbSeek(xFilial("QKF")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0005)) //"Peca e Revisao Destino Ja Existem Na Viabilidade"
				Loop
			EndIf
		Endif

		If mv_par10 == 1 .or. mv_par05 == 1 // Estudo de RR
			QM4->(DbSetOrder(3))
			If QM4->(DbSeek(xFilial("QM4")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0006)) //"Peca e Revisao Destino Ja Existem No RR"
				Loop
			EndIf
		Endif

		If mv_par11 == 1 .or. mv_par05 == 1 // Capabilidade
			QK9->(DbSetOrder(1))
			If QK9->(DbSeek(xFilial("QK9")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0007)) //"Peca e Revisao Destino Ja Existem Na Capabilidade"
				Loop
			EndIf
		Endif

		If mv_par12 == 1 .or. mv_par05 == 1 // Dimensional
			QKB->(DbSetOrder(1))
			If QKB->(DbSeek(xFilial("QKB")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0008)) //"Peca e Revisao Destino Ja Existem No Ensaio Dimensional"
				Loop
			EndIf
		Endif

		If mv_par13 == 1 .or. mv_par05 == 1 // Material
			QKD->(DbSetOrder(1))
			If QKD->(DbSeek(xFilial("QKD")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0009)) //"Peca e Revisao Destino Ja Existem No Ensaio Material"
				Loop
			EndIf
		Endif

		If mv_par14 == 1 .or. mv_par05 == 1 // Desempenho
			QKC->(DbSetOrder(1))
			If QKC->(DbSeek(xFilial("QKC")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0010)) //"Peca e Revisao Destino Ja Existem No Ensaio Desempenho"
				Loop
			EndIf
		Endif

		If mv_par15 == 1 .or. mv_par05 == 1 // Aprov. Aparencia
			QK3->(DbSetOrder(1))
			If QK3->(DbSeek(xFilial("QK3")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0011)) //"Peca e Revisao Destino Ja Existem Na Aprov. Aparencia"
				Loop
			EndIf
		Endif

		If mv_par16 == 1 .or. mv_par05 == 1 // Certificado de Submissao
			QKI->(DbSetOrder(1))
			If QKI->(DbSeek(xFilial("QKI")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0012)) //"Peca e Revisao Destino Ja Existem No Certificado de Submissao"
				Loop
			EndIf
		Endif

		If mv_par17 == 1 .or. mv_par05 == 1 // Plano de Controle
			QKL->(DbSetOrder(1))
			If QKL->(DbSeek(xFilial("QKL")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0013)) //"Peca e Revisao Destino Ja Existem No Plano de Controle"
				Loop
			EndIf
		Endif

		If mv_par18 == 1 .or. mv_par05 == 1 // FMEA Projeto
			QK5->(DbSetOrder(1))
			If QK5->(DbSeek(xFilial("QK5")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0014)) //"Peca e Revisao Destino Ja Existem No FMEA Projeto"
				Loop
			EndIf
		Endif

		If mv_par19 == 1 .or. mv_par05 == 1 // FMEA Processo
			QK7->(DbSetOrder(1))
			If QK7->(DbSeek(xFilial("QK7")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0015)) //"Peca e Revisao Destino Ja Existem No FMEA Processo"
				Loop
			EndIf
		Endif

		If mv_par20 == 1 .or. mv_par05 == 1 // Sumario e APQP
			QKJ->(DbSetOrder(1))
			If QKJ->(DbSeek(xFilial("QKJ")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0016)) //"Peca e Revisao Destino Ja Existem No Sumario e APQP"
				Loop
			EndIf
		Endif

		If mv_par21 == 1 .or. mv_par05 == 1 // Diagrama de Fluxo
			QKN->(DbSetOrder(1))
			If QKN->(DbSeek(xFilial("QKN")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0017)) //"Peca e Revisao Destino Ja Existem No Diagrama de Fluxo"
				Loop
			EndIf
		Endif

		If mv_par22 == 1 .or. mv_par05 == 1 // Aprovacao Interina
			QKH->(DbSetOrder(1))
			If QKH->(DbSeek(xFilial("QKH")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0018)) //"Peca e Revisao Destino Ja Existem Na Aprovacao Interina"
				Loop
			EndIf
		Endif

		If mv_par23 == 1 .or. mv_par05 == 1 // Checklist APQP A1 A8
			QKQ->(DbSetOrder(1))
			If QKQ->(DbSeek(xFilial("QKQ")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0023)) //"Peca e Revisao Destino Ja Existem no CheckList A1"
				Loop
			Endif

			QKR->(DbSetOrder(1))
			If QKR->(DbSeek(xFilial("QKR")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0024)) //"Peca e Revisao Destino Ja Existem no CheckList A2"
				Loop
			Endif

			QKS->(DbSetOrder(1))
			If QKS->(DbSeek(xFilial("QKS")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0025)) //"Peca e Revisao Destino Ja Existem no CheckList A3"
				Loop
			Endif

			QKT->(DbSetOrder(1))
			If QKT->(DbSeek(xFilial("QKT")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0026)) //"Peca e Revisao Destino Ja Existem no CheckList A4"
				Loop
			Endif

			QKU->(DbSetOrder(1))
			If QKU->(DbSeek(xFilial("QKU")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0027)) //"Peca e Revisao Destino Ja Existem no CheckList A5"
				Loop
			Endif

			QKV->(DbSetOrder(1))
			If QKV->(DbSeek(xFilial("QKV")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0028)) //"Peca e Revisao Destino Ja Existem no CheckList A6"
				Loop
			Endif

			QKW->(DbSetOrder(1))
			If QKW->(DbSeek(xFilial("QKW")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0029)) //"Peca e Revisao Destino Ja Existem no CheckList A7"
				Loop
			Endif

			QKX->(DbSetOrder(1))
			If QKX->(DbSeek(xFilial("QKX")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0030)) //"Peca e Revisao Destino Ja Existem no CheckList A8"
				Loop
			Endif
		Endif

		If mv_par24 == 1 .or. mv_par05 == 1 // Checklist Granel
			QKY->(DbSetOrder(1))
			If QKY->(DbSeek(xFilial("QKY")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0031)) //"Peca e Revisao Destino Ja Existem no CheckList Granel"
				Loop
			Endif
		Endif
		
		If mv_par25 == 1 .or. mv_par05 == 1 // PSA
			QL0->(DbSetOrder(1))
			If QL0->(DbSeek(xFilial("QL0")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0034)) //"Peca e Revisao Destino Ja Existem no PSA"
				Loop
			Endif
		Endif

		If mv_par26 == 1 .or. mv_par05 == 1 // VDA
			QL1->(DbSetOrder(1))
			QL2->(DbSetOrder(1))

			If QL1->(DbSeek(xFilial("QL1")+mv_par03+mv_par04)) .or. QL2->(DbSeek(xFilial("QL2")+mv_par03+mv_par04))
				MsgAlert(OemToAnsi(STR0035)) //"Peca e Revisao Destino Ja Existem no VDA"
				Loop
			Endif
		Endif
		
		//Sintaxe: tNewProcess():New( <cFunction> , <cTitle> , <bProcess> ,<cDescription> ,[ cPerg ],[ aInfoCustom ], [lPanelAux], [nSizePanelAux], [cDescriAux], [lViewExecute] , [lOneMeter] )
		tNewProcess():New( cFuncao, cTitulo, bProcessa , cDescricao, cPergunte,,,,,, .T. )
		
	Else
		Exit
	Endif
Enddo

Return Nil

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё QPPM020PROCЁ Autor Ё Robson Ramiro A. OliveЁ Data Ё 03/10/01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Executa a Duplicacao    					  				    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё QPPM020PROC()                                                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Void                                                         Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso		 Ё SIGAPPAP				                 					    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function QPPM020PROC(oSelf)

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
Local lVolta
Local cEspecie 			// Especie
Local cKeyOri			// Nova Chave
Local cKeyNew			// Nova Chave
Local nCntFor
Local nCont
Local lOk
Local cKeyQKQ 	:= ""
Local cKeyQKR 	:= ""
Local cKeyQKS 	:= ""
Local cKeyQKT 	:= ""
Local cKeyQKU 	:= ""
Local cKeyQKV 	:= ""
Local cKeyQKW 	:= ""
Local cKeyQKX 	:= ""
Local cKeyQKH 	:= ""
Local nSaveSX8	:= GetSX8Len()

If Empty(Alltrim(MV_PAR28))
	MsgInfo(OemToAnsi(STR0022)+STR0037, OemToAnsi(STR0021)) //"Nao Houve Duplicacao !!!"###" Informe a descriГЦo da PeГa."###"Duplicacao do PPAP"
	Return Nil
EndIf
		
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa Array 											 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aArq := {}


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKO, Arquivo de Textos						         Ё 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 	
bCRepQKO := { || QKO->QKO_CHAVE := cKeyNew }

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK1, Cadastro de Pecas						         Ё 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQK1 := { ||	QK1->QK1_PECA	:= mv_par03,;
					QK1->QK1_REV 	:= mv_par04,;
					QK1->QK1_REVINV	:= Inverte(mv_par04),;
					QK1->QK1_DTREVI	:= dDataBase,;
					QK1->QK1_STATUS	:= "1" }

If MV_PAR29 == 1 .AND. MV_PAR30 == 1 
	bCRepQK1 := { ||	QK1->QK1_PECA	:= mv_par03,;
						QK1->QK1_REV 	:= mv_par04,;
						QK1->QK1_REVINV	:= Inverte(mv_par04),;
						QK1->QK1_DTREVI	:= dDataBase,;
						QK1->QK1_STATUS	:= "1",;
						QK1->QK1_DESC   := MV_PAR28,;
						QK1->QK1_PRODUT := MV_PAR31,;
						QK1->QK1_REVI   := MV_PAR32 }

ElseIf MV_PAR29 == 1
	bCRepQK1 := { ||	QK1->QK1_PECA	:= mv_par03,;
						QK1->QK1_REV 	:= mv_par04,;
						QK1->QK1_REVINV	:= Inverte(mv_par04),;
						QK1->QK1_DTREVI	:= dDataBase,;
						QK1->QK1_STATUS	:= "1",;
						QK1->QK1_DESC   := MV_PAR28 }
ElseIf MV_PAR30 == 1
	bCRepQK1 := { ||	QK1->QK1_PECA	:= mv_par03,;
						QK1->QK1_REV 	:= mv_par04,;
						QK1->QK1_REVINV	:= Inverte(mv_par04),;
						QK1->QK1_DTREVI	:= dDataBase,;
						QK1->QK1_STATUS	:= "1",;
						QK1->QK1_PRODUT := MV_PAR31,;
						QK1->QK1_REVI   := MV_PAR32 }
EndIf
														
bCConQK1 := { || ! Eof() .and. xFilial("QK1") == QK1_FILIAL .and.;
											  QK1_PECA == mv_par01 .and.;
											  QK1_REV == mv_par02 }

// Mudanca no conceito, independente dos parametros o cadastro de peca devera ser duplicado tambem.
aAdd( aArq, { "QK1", mv_par01+mv_par02, bCRepQK1, bCConQK1, 1 } )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK2, Caracteristica das Pecas						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQK2 := { ||	QK2->QK2_PECA	 := mv_par03,;
					QK2->QK2_REV 	 := mv_par04,;
					QK2->QK2_REVINV	 :=	Inverte(mv_par04)}
						
bCConQK2 := { || ! Eof() .and. xFilial("QK2") == QK2_FILIAL .and.;
											  QK2_PECA == mv_par01 .and.;
											  QK2_REV == mv_par02 }

// Mudanca no conceito, independente dos parametros o cadastro de peca devera ser duplicado tambem.
aAdd( aArq, { "QK2", mv_par01+mv_par02, bCRepQK2, bCConQK2, 1 } )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKK, Operacoes                     					 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKK := { ||	QKK->QKK_PECA	 := mv_par03,;
					QKK->QKK_REV 	 := mv_par04,;
					QKK->QKK_REVINV	 :=	Inverte(mv_par04)}
							
bCConQKK := { || ! Eof() .and. xFilial("QKK") == QKK_FILIAL .and.;
											  QKK_PECA == mv_par01 .and.;
											  QKK_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par07 == 1 .or. mv_par17 == 1 ;	// Mudanca no conceito devido a Integridade Referencial
	.or. mv_par19 == 1 .or. mv_par21 == 1 					// Todo PPAP, Operacoes, Plano de Controle, FMEA Processo, Fluxograma
	aAdd( aArq, { "QKK", mv_par01+mv_par02, bCRepQKK, bCConQKK, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKG, Cabecalho do Cronograma       					 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKG := { ||	QKG->QKG_PECA	 := mv_par03,;
					QKG->QKG_REV 	 := mv_par04,;
					QKG->QKG_REVINV	 :=	Inverte(mv_par04)}
							
bCConQKG := { || ! Eof() .and. xFilial("QKG") == QKG_FILIAL .and.;
											  QKG_PECA == mv_par01 .and.;
											  QKG_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par08 == 1 // Todo PPAP ou Cronograma
	aAdd( aArq, { "QKG", mv_par01+mv_par02, bCRepQKG, bCConQKG, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKP, Detail do Cronograma       					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKP := { ||	QKP->QKP_PECA	 := mv_par03,;
					QKP->QKP_REV 	 := mv_par04,;
					QKP->QKP_REVINV	 :=	Inverte(mv_par04)}
							
bCConQKP := { || ! Eof() .and. xFilial("QKP") == QKP_FILIAL .and.;
											  QKP_PECA == mv_par01 .and.;
											  QKP_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par08 == 1 // Todo PPAP ou Cronograma
	aAdd( aArq, { "QKP", mv_par01+mv_par02, bCRepQKP, bCConQKP, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKF, Viabilidade                					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKF := { ||	QKF->QKF_PECA	 := mv_par03,;
					QKF->QKF_REV 	 := mv_par04,;
					QKF->QKF_REVINV	 :=	Inverte(mv_par04)}
							
bCConQKF := { || ! Eof() .and. xFilial("QKF") == QKF_FILIAL .and.;
											  QKF_PECA == mv_par01 .and.;
											  QKF_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par09 == 1 // Todo PPAP ou Viabilidade
	aAdd( aArq, { "QKF", mv_par01+mv_par02, bCRepQKF, bCConQKF, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK9, Cabecalho Capabilidade     					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQK9 := { ||	QK9->QK9_PECA	 := mv_par03,;
					QK9->QK9_REV 	 := mv_par04,;
					QK9->QK9_REVINV	 :=	Inverte(mv_par04)}
							
bCConQK9 := { || ! Eof() .and. xFilial("QK9") == QK9_FILIAL .and.;
											  QK9_PECA == mv_par01 .and.;
											  QK9_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par11 == 1 // Todo PPAP ou Capabilidade
	aAdd( aArq, { "QK9", mv_par01+mv_par02, bCRepQK9, bCConQK9, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKA, Detail da Capabilidade     					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKA := { ||	QKA->QKA_PECA	 := mv_par03,;
					QKA->QKA_REV 	 := mv_par04,;
					QKA->QKA_REVINV	 :=	Inverte(mv_par04)}
							
bCConQKA := { || ! Eof() .and. xFilial("QKA") == QKA_FILIAL .and.;
											  QKA_PECA == mv_par01 .and.;
											  QKA_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par11 == 1 // Todo PPAP ou Capabilidade
	aAdd( aArq, { "QKA", mv_par01+mv_par02, bCRepQKA, bCConQKA, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKB, Enasio Dimensional        					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKB := { ||	QKB->QKB_PECA	 := mv_par03,;
					QKB->QKB_REV 	 := mv_par04,;
					QKB->QKB_REVINV	 :=	Inverte(mv_par04)}
							
bCConQKB := { || ! Eof() .and. xFilial("QKB") == QKB_FILIAL .and.;
											  QKB_PECA == mv_par01 .and.;
											  QKB_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par12 == 1 // Todo PPAP ou Dimensional
	aAdd( aArq, { "QKB", mv_par01+mv_par02, bCRepQKB, bCConQKB, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKD, Enasio Material           					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKD := { ||	QKD->QKD_PECA	 := mv_par03,;
					QKD->QKD_REV 	 := mv_par04,;
					QKD->QKD_REVINV	 :=	Inverte(mv_par04)}
							
bCConQKD := { || ! Eof() .and. xFilial("QKD") == QKD_FILIAL .and.;
											  QKD_PECA == mv_par01 .and.;
											  QKD_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par13 == 1 // Todo PPAP ou Material
	aAdd( aArq, { "QKD", mv_par01+mv_par02, bCRepQKD, bCConQKD, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKC, Enasio Desempenho           					     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKC := { ||	QKC->QKC_PECA	 := mv_par03,;
					QKC->QKC_REV 	 := mv_par04,;
					QKC->QKC_REVINV	 :=	Inverte(mv_par04)}
							
bCConQKC := { || ! Eof() .and. xFilial("QKC") == QKC_FILIAL .and.;
											  QKC_PECA == mv_par01 .and.;
											  QKC_REV == mv_par02 }
If mv_par05 == 1 .or. mv_par14 == 1 // Todo PPAP ou Desempenho
	aAdd( aArq, { "QKC", mv_par01+mv_par02, bCRepQKC, bCConQKC, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK3, Cabecalho Aprovacao de Aparencia  			     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQK3 := { ||	QK3->QK3_PECA	 := mv_par03,;
					QK3->QK3_REV 	 := mv_par04,;
					QK3->QK3_REVINV	 :=	Inverte(mv_par04)}
							
bCConQK3 := { || ! Eof() .and. xFilial("QK3") == QK3_FILIAL .and.;
											  QK3_PECA == mv_par01 .and.;
											  QK3_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par15 == 1 // Todo PPAP ou Aprov. Aparencia
	aAdd( aArq, { "QK3", mv_par01+mv_par02, bCRepQK3, bCConQK3, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK4, Details Aprovacao de Aparencia  			         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQK4 := { ||	QK4->QK4_PECA	 := mv_par03,;
					QK4->QK4_REV 	 := mv_par04,;
					QK4->QK4_REVINV	 :=	Inverte(mv_par04)}
							
bCConQK4 := { || ! Eof() .and. xFilial("QK4") == QK4_FILIAL .and.;
											  QK4_PECA == mv_par01 .and.;
											  QK4_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par15 == 1 // Todo PPAP ou Aprov. Aparencia
	aAdd( aArq, { "QK4", mv_par01+mv_par02, bCRepQK4, bCConQK4, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKI, Certificado de Submissao     			         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKI := { ||	QKI->QKI_PECA	 := mv_par03,;
					QKI->QKI_REV 	 := mv_par04,;
					QKI->QKI_REVINV	 :=	Inverte(mv_par04)}
							
bCConQKI := { || ! Eof() .and. xFilial("QKI") == QKI_FILIAL .and.;
											  QKI_PECA == mv_par01 .and.;
											  QKI_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par16 == 1 // Todo PPAP ou Certificado
	aAdd( aArq, { "QKI", mv_par01+mv_par02, bCRepQKI, bCConQKI, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKL, Cabecalho do Plano de Controle  			         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKL := { ||	QKL->QKL_PECA	 := mv_par03,;
					QKL->QKL_REV 	 := mv_par04,;
					QKL->QKL_REVINV	 :=	Inverte(mv_par04),;
					QKL->QKL_TPPRO	 := AllTrim(STR(mv_par27-1))}
							
bCConQKL := { || ! Eof() .and. xFilial("QKI") == QKL_FILIAL .and.;
											  QKL_PECA == mv_par01 .and.;
											  QKL_REV == mv_par02 .and.;
								QKL_TPPRO == AllTrim(STR(mv_par27-1)) }

If mv_par05 == 1 .or. mv_par17 == 1 // Todo PPAP ou Plano de Controle
	aAdd( aArq, { "QKL", mv_par01+mv_par02+AllTrim(STR(mv_par27-1)), bCRepQKL, bCConQKL, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKM, Details do Plano de Controle  			         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKM := { ||	QKM->QKM_PECA	 := mv_par03,;
					QKM->QKM_REV 	 := mv_par04,;
					QKM->QKM_REVINV	 :=	Inverte(mv_par04),;
					QKM->QKM_TPPRO	 := AllTrim(STR(mv_par27-1))}
							
bCConQKM := { || ! Eof() .and. xFilial("QKI") == QKM_FILIAL .and.;
								QKM_PECA == mv_par01 .and.;
								QKM_REV == mv_par02  .and.;
								QKM_TPPRO == AllTrim(STR(mv_par27-1))}

If mv_par05 == 1 .or. mv_par17 == 1 // Todo PPAP ou Plano de Controle
	aAdd( aArq, { "QKM", mv_par01+mv_par02+AllTrim(STR(mv_par27-1)), bCRepQKM, bCConQKM, 3 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKJ, Sumario e APQP        							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKJ := { ||	QKJ->QKJ_PECA	 := mv_par03,;
					QKJ->QKJ_REV 	 := mv_par04,;
					QKJ->QKJ_REVINV	 :=	Inverte(mv_par04)}
							
bCConQKJ := { || ! Eof() .and. xFilial("QKJ") == QKJ_FILIAL .and.;
											  QKJ_PECA == mv_par01 .and.;
											  QKJ_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par20 == 1 // Todo PPAP ou Sumario e APQP
	aAdd( aArq, { "QKJ", mv_par01+mv_par02, bCRepQKJ, bCConQKJ, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK5, Cabecalho FMEA Projeto							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQK5 := { ||	QK5->QK5_PECA	 := mv_par03,;
					QK5->QK5_REV 	 := mv_par04,;
					QK5->QK5_REVINV	 :=	Inverte(mv_par04),;
					QK5->QK5_APRPOR  := "",;
					QK5->QK5_DATA    := CtoD("  /  /    ","DD/MM/YYYY")}
							
bCConQK5 := { || ! Eof() .and. xFilial("QK5") == QK5_FILIAL .and.;
											  QK5_PECA == mv_par01 .and.;
											  QK5_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par18 == 1 // Todo PPAP ou FMEA Projeto
	aAdd( aArq, { "QK5", mv_par01+mv_par02, bCRepQK5, bCConQK5, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK6, Details FMEA Projeto							     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQK6 := { ||	QK6->QK6_PECA	 := mv_par03,;
					QK6->QK6_REV 	 := mv_par04,;
					QK6->QK6_REVINV	 :=	Inverte(mv_par04)}
							
bCConQK6 := { || ! Eof() .and. xFilial("QK6") == QK6_FILIAL .and.;
											  QK6_PECA == mv_par01 .and.;
											  QK6_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par18 == 1 // Todo PPAP ou FMEA Projeto
	aAdd( aArq, { "QK6", mv_par01+mv_par02, bCRepQK6, bCConQK6, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK7, Cabecalho FMEA Processo							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQK7 := { ||	QK7->QK7_PECA	 := mv_par03,;
					QK7->QK7_REV 	 := mv_par04,;
					QK7->QK7_REVINV	 :=	Inverte(mv_par04),;
					QK7->QK7_APRPOR  := "",;
					QK7->QK7_DATA    := CtoD("  /  /    ","DD/MM/YYYY")}
							
bCConQK7 := { || !Eof() .and. xFilial("QK7") == QK7_FILIAL .and.;
											  QK7_PECA == mv_par01 .and.;
											  QK7_REV == mv_par02}

If mv_par05 == 1 .or. mv_par19 == 1 // Todo PPAP ou FMEA Processo
	aAdd( aArq, { "QK7", mv_par01+mv_par02, bCRepQK7, bCConQK7, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QK8, Details FMEA Processo						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQK8 := { ||	QK8->QK8_PECA	 := mv_par03,;
					QK8->QK8_REV 	 := mv_par04,;
					QK8->QK8_REVINV	 :=	Inverte(mv_par04)}
							
bCConQK8 := { || ! Eof() .and. xFilial("QK8") == QK8_FILIAL .and.;
											  QK8_PECA == mv_par01 .and.;
											  QK8_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par19 == 1 // Todo PPAP ou FMEA Processo
	aAdd( aArq, { "QK8", mv_par01+mv_par02, bCRepQK8, bCConQK8, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKN, Diagrama de Fluxo    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKN := { ||	QKN->QKN_PECA	 := mv_par03,;
					QKN->QKN_REV 	 := mv_par04,;
					QKN->QKN_REVINV	 :=	Inverte(mv_par04)}
							
bCConQKN := { || ! Eof() .and. xFilial("QKN") == QKN_FILIAL .and.;
											  QKN_PECA == mv_par01 .and.;
											  QKN_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par21 == 1 // Todo PPAP ou Diagrama de Fluxo
	aAdd( aArq, { "QKN", mv_par01+mv_par02, bCRepQKN, bCConQKN, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QM4, Cabecalho do RR       						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQM4 := { ||	QM4->QM4_PECA1	 := mv_par03,;
					QM4->QM4_REV 	 := mv_par04,;
					QM4->QM4_REVINV	 :=	Inverte(mv_par04)}
							
bCConQM4 := { || ! Eof() .and. xFilial("QM4") == QM4_FILIAL .and.;
											  QM4_PECA1 == mv_par01 .and.;
											  QM4_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par10 == 1 // Todo PPAP ou RR
	aAdd( aArq, { "QM4", mv_par01+mv_par02, bCRepQM4, bCConQM4, 3 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QM5, Details do RR       						         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQM5 := { ||	QM5->QM5_PECA1	 := mv_par03,;
					QM5->QM5_REV 	 := mv_par04,;
					QM5->QM5_REVINV	 :=	Inverte(mv_par04)}
							
bCConQM5 := { || ! Eof() .and. xFilial("QM5") == QM5_FILIAL .and.;
											  QM5_PECA1 == mv_par01 .and.;
											  QM5_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par10 == 1 // Todo PPAP ou RR
	aAdd( aArq, { "QM5", mv_par01+mv_par02, bCRepQM5, bCConQM5, 2 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKH, Aprovacao Interina    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKH := { ||	QKH->QKH_PECA	 := mv_par03,;
					QKH->QKH_REV 	 := mv_par04,;
					QKH->QKH_REVINV	 :=	Inverte(mv_par04)}
							
bCConQKH := { || ! Eof() .and. xFilial("QKH") == QKH_FILIAL .and.;
											  QKH_PECA == mv_par01 .and.;
											  QKH_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par22 == 1 // Todo PPAP ou Aprov. Interina
	aAdd( aArq, { "QKH", mv_par01+mv_par02, bCRepQKH, bCConQKH, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKQ, Checklist APQP A1    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKQ := { ||	QKQ->QKQ_PECA	:= mv_par03,;
					QKQ->QKQ_REV	:= mv_par04,;
					QKQ->QKQ_REVINV	:= Inverte(mv_par04)}
							
bCConQKQ := { || ! Eof() .and. xFilial("QKQ") == QKQ_FILIAL .and.;
												QKQ_PECA == mv_par01 .and.;
												QKQ_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par23 == 1 // Todo PPAP ou Checklist APQP
	aAdd( aArq, { "QKQ", mv_par01+mv_par02, bCRepQKQ, bCConQKQ, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKR, Checklist APQP A2    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKR := { ||	QKR->QKR_PECA	:= mv_par03,;
					QKR->QKR_REV	:= mv_par04,;
					QKR->QKR_REVINV	:= Inverte(mv_par04)}
							
bCConQKR := { || ! Eof() .and. xFilial("QKR") == QKR_FILIAL .and.;
												QKR_PECA == mv_par01 .and.;
												QKR_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par23 == 1 // Todo PPAP ou Checklist APQP
	aAdd( aArq, { "QKR", mv_par01+mv_par02, bCRepQKR, bCConQKR, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKS, Checklist APQP A3    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKS := { ||	QKS->QKS_PECA	:= mv_par03,;
					QKS->QKS_REV	:= mv_par04,;
					QKS->QKS_REVINV	:= Inverte(mv_par04)}
							
bCConQKS := { || ! Eof() .and. xFilial("QKS") == QKS_FILIAL .and.;
												QKS_PECA == mv_par01 .and.;
												QKS_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par23 == 1 // Todo PPAP ou Checklist APQP
	aAdd( aArq, { "QKS", mv_par01+mv_par02, bCRepQKS, bCConQKS, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKT, Checklist APQP A4    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKT := { ||	QKT->QKT_PECA	:= mv_par03,;
					QKT->QKT_REV	:= mv_par04,;
					QKT->QKT_REVINV	:= Inverte(mv_par04)}
							
bCConQKT := { || ! Eof() .and. xFilial("QKT") == QKT_FILIAL .and.;
												QKT_PECA == mv_par01 .and.;
												QKT_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par23 == 1 // Todo PPAP ou Checklist APQP
	aAdd( aArq, { "QKT", mv_par01+mv_par02, bCRepQKT, bCConQKT, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKU, Checklist APQP A5    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKU := { ||	QKU->QKU_PECA	:= mv_par03,;
					QKU->QKU_REV	:= mv_par04,;
					QKU->QKU_REVINV	:= Inverte(mv_par04)}
							
bCConQKU := { || ! Eof() .and. xFilial("QKU") == QKU_FILIAL .and.;
												QKU_PECA == mv_par01 .and.;
												QKU_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par23 == 1 // Todo PPAP ou Checklist APQP
	aAdd( aArq, { "QKU", mv_par01+mv_par02, bCRepQKU, bCConQKU, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKV, Checklist APQP A6    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKV := { ||	QKV->QKV_PECA	:= mv_par03,;
					QKV->QKV_REV	:= mv_par04,;
					QKV->QKV_REVINV	:= Inverte(mv_par04)}
							
bCConQKV := { || ! Eof() .and. xFilial("QKV") == QKV_FILIAL .and.;
												QKV_PECA == mv_par01 .and.;
												QKV_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par23 == 1 // Todo PPAP ou Checklist APQP
	aAdd( aArq, { "QKV", mv_par01+mv_par02, bCRepQKV, bCConQKV, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKW, Checklist APQP A7    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKW := { ||	QKW->QKW_PECA	:= mv_par03,;
					QKW->QKW_REV	:= mv_par04,;
					QKW->QKW_REVINV	:= Inverte(mv_par04)}
							
bCConQKW := { || ! Eof() .and. xFilial("QKW") == QKW_FILIAL .and.;
												QKW_PECA == mv_par01 .and.;
												QKW_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par23 == 1 // Todo PPAP ou Checklist APQP
	aAdd( aArq, { "QKW", mv_par01+mv_par02, bCRepQKW, bCConQKW, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKX, Checklist APQP A8    						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKX := { ||	QKX->QKX_PECA	:= mv_par03,;
					QKX->QKX_REV	:= mv_par04,;
					QKX->QKX_REVINV	:= Inverte(mv_par04)}
							
bCConQKX := { || ! Eof() .and. xFilial("QKX") == QKX_FILIAL .and.;
												QKX_PECA == mv_par01 .and.;
												QKX_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par23 == 1 // Todo PPAP ou Checklist APQP
	aAdd( aArq, { "QKX", mv_par01+mv_par02, bCRepQKX, bCConQKX, 1 } )
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QKY, Checklist Granel     						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQKY := { ||	QKY->QKY_PECA	:= mv_par03,;
					QKY->QKY_REV	:= mv_par04,;
					QKY->QKY_REVINV	:= Inverte(mv_par04)}
							
bCConQKY := { || ! Eof() .and. xFilial("QKY") == QKY_FILIAL .and.;
												QKY_PECA == mv_par01 .and.;
												QKY_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par24 == 1 // Todo PPAP ou Checklist Granel
	aAdd( aArq, { "QKY", mv_par01+mv_par02, bCRepQKY, bCConQKY, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QL0, PSA                  						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQL0 := { ||	QL0->QL0_PECA	:= mv_par03,;
					QL0->QL0_REV	:= mv_par04,;
					QL0->QL0_REVINV	:= Inverte(mv_par04)}
							
bCConQL0 := { || ! Eof() .and. xFilial("QL0") == QL0_FILIAL .and.;
												QL0_PECA == mv_par01 .and.;
												QL0_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par25 == 1 // Todo PPAP ou PSA
	aAdd( aArq, { "QL0", mv_par01+mv_par02, bCRepQL0, bCConQL0, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QL1, VDA Amostras Iniciais   						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQL1 := { ||	QL1->QL1_PECA	:= mv_par03,;
					QL1->QL1_REV	:= mv_par04,;
					QL1->QL1_REVINV	:= Inverte(mv_par04)}
							
bCConQL1 := { || ! Eof() .and. xFilial("QL1") == QL1_FILIAL .and.;
												QL1_PECA == mv_par01 .and.;
												QL1_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par26 == 1 // Todo PPAP ou VDA
	aAdd( aArq, { "QL1", mv_par01+mv_par02, bCRepQL1, bCConQL1, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QL2, VDA Folha de Capa       						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQL2 := { ||	QL2->QL2_PECA	:= mv_par03,;
					QL2->QL2_REV	:= mv_par04,;
					QL2->QL2_REVINV	:= Inverte(mv_par04)}
							
bCConQL2 := { || ! Eof() .and. xFilial("QL2") == QL2_FILIAL .and.;
												QL2_PECA == mv_par01 .and.;
												QL2_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par26 == 1 // Todo PPAP ou VDA
	aAdd( aArq, { "QL2", mv_par01+mv_par02, bCRepQL2, bCConQL2, 1 } )
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alias QL3, Detail do VDA Folha de Capa  				     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
bCRepQL3 := { ||	QL3->QL3_PECA	:= mv_par03,;
					QL3->QL3_REV	:= mv_par04,;
					QL3->QL3_REVINV	:= Inverte(mv_par04)}
							
bCConQL3 := { || ! Eof() .and. xFilial("QL3") == QL3_FILIAL .and.;
												QL3_PECA == mv_par01 .and.;
												QL3_REV == mv_par02 }

If mv_par05 == 1 .or. mv_par26 == 1 // Todo PPAP ou VDA
	aAdd( aArq, { "QL3", mv_par01+mv_par02, bCRepQL3, bCConQL3, 1 } )
Endif


//здддддддддддддддддддд©
//Ё Efetiva gravacao   Ё
//юдддддддддддддддддддды

Begin Transaction

oSelf:SetRegua1(Len(aArq))
		
For nCntFor := 1 To Len(aArq)

	oSelf:IncRegua1(LTrim(Str(nCntFor)))

	DbselectArea(aArq[nCntFor,1])
	DbSetOrder(aArq[nCntFor,5])
	DbSeek(xFilial()+aArq[nCntFor,2])
	
	Do While Eval(aArq[nCntFor,4])
		lVolta	:= .T.
				
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
				cKeyOri	:= QKK->QKK_CHAVE
				cKeyNew	:= GetSXENum("QKK", "QKK_CHAVE",,4)

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
				Endif
			Endif

			// QKP
			If Alias() == "QKP" .and. !Empty(QKP->QKP_CHAVE)
				cKeyOri	:= QKP->QKP_CHAVE
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
				cKeyOri	:= QKF->QKF_CHAVE
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

			// QK8 - Processo diferenciado pois existem 11 especies (A...K)
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

				For nCont := 1 To 11
					cEspecie := "QPPA130" + Subs("ABCDEFGHIJK",nCont,1)
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
				cKeyQKH := QKH->QKH_CHAV01
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

If !Empty(cKeyQKH)
	cKeyNew	:= GetSXENum("QKH", "QKH_CHAV01",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

	bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
	   						  QKO->QKO_CHAVE == cKeyQKH .and.;
							  QKO->QKO_ESPEC == cEspecie }
	lOk := .F.

	For nCont := 1 To 4
		cEspecie := "QPPA240" + Subs("ABCD",nCont,1)
		If DuplicQKO(cEspecie, cKeyQKH, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
			lOk := .T.
		Endif
	Next nCont

	DbSelectArea("QKH")
	DbSetOrder(1)
	If DbSeek(xFilial("QKH") + mv_par03 + mv_par04)
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
Endif


If !Empty(cKeyQKQ)
	cKeyNew := GetSXENum("QKQ", "QKQ_CHAVE",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

	bCConQKO := { || !Eof() .and. xFilial("QKO") == QKO->QKO_FILIAL .and.;
													QKO->QKO_CHAVE == cKeyQKQ .and.;
							  						QKO->QKO_ESPEC == cEspecie }

	bCConQKQ := { || ! Eof() .and. xFilial("QKQ") == QKQ_FILIAL .and.;
											QKQ_PECA == mv_par03 .and.;
											QKQ_REV == mv_par04 }


	lOk := .F.

	For nCont := 1 To 8
		cEspecie := "PPA250" + StrZero(nCont,2)
		If DuplicQKO(cEspecie, cKeyQKQ, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
       		lOk := .T.
		Endif
	Next nCont

	DbSelectArea("QKQ")
	DbSetOrder(1)
	DbSeek(xFilial("QKQ") + mv_par03 + mv_par04)
		
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
											QKR_PECA == mv_par03 .and.;
											QKR_REV == mv_par04 }


	lOk := .F.

	For nCont := 1 To 40
		cEspecie := "PPA260" + StrZero(nCont,2)
		If DuplicQKO(cEspecie, cKeyQKR, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
       		lOk := .T.
		Endif
	Next nCont

	DbSelectArea("QKR")
	DbSetOrder(1)
	DbSeek(xFilial("QKR") + mv_par03 + mv_par04)
		
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
											QKS_PECA == mv_par03 .and.;
											QKS_REV == mv_par04 }


	lOk := .F.

	For nCont := 1 To 20
		cEspecie := "PPA270" + StrZero(nCont,2)
		If DuplicQKO(cEspecie, cKeyQKS, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
       		lOk := .T.
		Endif
	Next nCont

	DbSelectArea("QKS")
	DbSetOrder(1)
	DbSeek(xFilial("QKS") + mv_par03 + mv_par04)
		
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
											QKT_PECA == mv_par03 .and.;
											QKT_REV == mv_par04 }


	lOk := .F.

	For nCont := 1 To 53
		cEspecie := "PPA280" + StrZero(nCont,2)
		If DuplicQKO(cEspecie, cKeyQKT, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
       		lOk := .T.
		Endif
	Next nCont

	DbSelectArea("QKT")
	DbSetOrder(1)
	DbSeek(xFilial("QKT") + mv_par03 + mv_par04)
		
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
											QKU_PECA == mv_par03 .and.;
											QKU_REV == mv_par04 }


	lOk := .F.

	For nCont := 1 To 13
		cEspecie := "PPA290" + StrZero(nCont,2)
		If DuplicQKO(cEspecie, cKeyQKU, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
       		lOk := .T.
		Endif
	Next nCont

	DbSelectArea("QKU")
	DbSetOrder(1)
	DbSeek(xFilial("QKU") + mv_par03 + mv_par04)
		
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
											QKV_PECA == mv_par03 .and.;
											QKV_REV == mv_par04 }


	lOk := .F.

	For nCont := 1 To 7
		cEspecie := "PPA300" + StrZero(nCont,2)
		If DuplicQKO(cEspecie, cKeyQKV, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
       		lOk := .T.
		Endif
	Next nCont

	DbSelectArea("QKV")
	DbSetOrder(1)
	DbSeek(xFilial("QKV") + mv_par03 + mv_par04)
		
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
											QKW_PECA == mv_par03 .and.;
											QKW_REV == mv_par04 }


	lOk := .F.

	For nCont := 1 To 13
		cEspecie := "PPA310" + StrZero(nCont,2)
		If DuplicQKO(cEspecie, cKeyQKW, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
       		lOk := .T.
		Endif
	Next nCont

	DbSelectArea("QKW")
	DbSetOrder(1)
	DbSeek(xFilial("QKW") + mv_par03 + mv_par04)
		
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
											QKX_PECA == mv_par03 .and.;
											QKX_REV == mv_par04 }


	lOk := .F.

	For nCont := 1 To 13
		cEspecie := "PPA320" + StrZero(nCont,2)
		If DuplicQKO(cEspecie, cKeyQKX, cKeyNew, bCCOnQKO, bCRepQKO) // Funcao para Duplicacao dos Textos
       		lOk := .T.
		Endif
	Next nCont

	DbSelectArea("QKX")
	DbSetOrder(1)
	DbSeek(xFilial("QKX") + mv_par03 + mv_par04)
		
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


End Transaction

If Len(aArq) > 0
	MsgInfo(OemToAnsi(STR0020), OemToAnsi(STR0021)) //"Duplicacao Concluida!!!"###"Duplicacao do PPAP"
Else
	MsgInfo(OemToAnsi(STR0022), OemToAnsi(STR0021)) //"Nao Houve Duplicacao !!!"###"Duplicacao do PPAP"
Endif

Return Nil

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё DuplicQKO  Ё Autor Ё Robson Ramiro A. OliveЁ Data Ё 03/10/01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Duplica os Textos dos Alias                  			    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё DuplicQKO(cEspecie, cKeyOri,cKeyNew, bCCOnQKO, bCRepQKO)     Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ cEspecie	= Especie para busca                                Ё╠╠
╠╠Ё          Ё cKeyOri 	= Chave de Origem                                   Ё╠╠
╠╠Ё          Ё cKeyNew 	= Nova chave                                        Ё╠╠
╠╠Ё          Ё bCCOnQKO	= Block com as condicoes para While					Ё╠╠
╠╠Ё          Ё bCRepQKO = Block com os Campos especificos para Replace      Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso		 Ё SIGAPPAP				                 					    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function DuplicQKO(cEspecie, cKeyOri, cKeyNew, bCCOnQKO, bCRepQKO)

Local lVolta 	:= .T.
Local lReturn 	:= .F.

DbSelectArea("QKO")
DbSetOrder(1)

If DbSeek(xFilial()+cEspecie+cKeyOri)
	lReturn := .T.
	Do While Eval(bCConQKO)
		lVolta := .T.
		If QA_Dupl(lVolta, bCRepQKO, "QKO")
			DbSkip()
		Else
			Exit
		Endif
	Enddo
Endif

Return lReturn

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPPM020Vrev╨Autor  ЁDenis Martins       ╨ Data Ё  01/27/05   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁValidacao da revisao da peca/ppap para considerar somente   ╨╠╠
╠╠╨          Ёdigitos.                                                    ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё QPPM020                                                    ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PPM020Vrev()
Local lRet := .T.
If !IsDigit(SubStr(mv_par04,1,1)) .or. !IsDigit(SubStr(mv_par04,2,1))
	lRet := .F.
Else
	If Val(mv_par04) > 99
		MessageDlg(OemToAnsi(STR0036),,1)	 //"Maximo numero de revisao de PPAP. Nao sera possivel a revisao do PPAP!!"
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
Function QPM020VDesc()  
Local lRet   := .T.
Local cDes   := MV_PAR28
        
If (MV_PAR29 == 2)
	QK1->(dbSetOrder(1))
	If QK1->(DbSeek(xFilial("QK1")+MV_PAR01+MV_PAR02))
		cDes := QK1->QK1_DESC
	EndIf
EndIf       

MV_PAR28 := cDes
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
Function QPM020VPR()  
Local lRet   := .T.
Local cDesP   := MV_PAR31
Local cDesR   := MV_PAR32
        
If (MV_PAR30 == 2)
	cDesP := Space(15)
	cDesR := Space(2)
EndIf       

MV_PAR31 := cDesP
MV_PAR32 := cDesR
Return(lRet)