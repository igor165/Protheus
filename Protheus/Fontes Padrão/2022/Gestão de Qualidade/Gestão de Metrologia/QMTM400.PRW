#INCLUDE "PROTHEUS.CH"
#INCLUDE "QMTM400.CH"


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QMTM400	³ Autor ³ Wanderley Goncalves   ³ Data ³ 23.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de Recalculo de Incerteza  				          ³±±
±±³          ³ (sempre sobre a ultima revisao)   				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void QMTM400						                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso	     ³ SIGAQMT							                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³	MOTIVO DA ALTERACAO		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Antonio      ³14/05/99³------³  Testa a tecla ESC e a opcao de        ³±±
±±³				 ³		  ³		 ³	 CANCELAR na Pergunte()     	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Antonio      ³19/07/99³22057 ³ Parametro de, ate para Status          ³±± 
±±³ Denis Martins³29/11/00³Melhor³ Correcao de gravacao campos QM7_ADEQ,  ³±± 
±±³              ³        ³      ³ QM7_EXAT,QM7_ ACEIT.Correcao de grava- ³±±
±±³              ³        ³      ³ cao do Arq. Temporario.                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QMTM400(cAlias,nReg,nOpcx)

Local aTMPStru := {}
Local nCntFor
Local nLastKey := 0
Local oTmpTable := NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Privates para efetuar os calculos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private Inclui		:= .F.
Private Altera		:= .T.
Private cMtInstr	:= ''
Private cMtRevIns := ''
Private dMtData
Private cMtResp	:= ''
Private cMtTotHr	:= ''
Private cMtRepRepr := ''
Private cPerg := "QMM400"
Private lEnd := .F.

Private nPosEsc	:= 01
Private nPosPad	:= 02
Private nPosEsp	:= 03
Private nPosMed	:= 04
Private nPosObs	:= 05
Private nPosSec	:= 06
Private nPosIns	:= 07
Private nPosNco	:= 08
Private nPosITB	:= 09
Private nPosCar	:= 10
Private nPosExt	:= 11
Private nPosGer	:= 12
Private nPosTp5	:= 13
Private aMedicoes := {}
Private dProxAfer
Private aResult := {}
Private  cSeql			:= "00"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa as Variaveis da Enchoice							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QM6")
M->QM6_INSTR := QM6->QM6_INSTR
M->QM6_REVINS := QM6->QM6_REVINS
M->QM6_DATA  := QM6->QM6_DATA
M->QM6_REPEPR := QM6->QM6_REPEPR
M->QM6_CSEQ	  := QM6->QM6_CSEQ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros									  ³
//³ mv_par01				// Instrumento Inicial							  ³
//³ mv_par02				// Instrumento Final 							  ³
//³ mv_par03				// Periodo Inicial								  ³
//³ mv_par04				// Periodo Final								  ³
//³ mv_par05				// Departamento Inicial 						  ³
//³ mv_par06				// Departamento Final							  ³
//³ mv_par07				// Orgao Calibrador Todos/Interno/Externo		  ³
//³ mv_par08				// Org.Calib.Intr.Inicial  					  	  ³
//³ mv_par09				// Org.Calib.Intr.Final    					      ³
//³ mv_par10				// Org.Calib.Extr.Inicial  					      ³
//³ mv_par11				// Org.Calib.Extr.Final    					      ³
//³ mv_par12				// Familia Inicial                          	  ³
//³ mv_par13				// Familia Final 								  ³
//³ mv_par14				// Fabricante Inicial							  ³
//³ mv_par15				// Fabricante Final								  ³
//³ mv_par16				// Status de  			                          ³
//³ mv_par17             	// Status ate                               	  ³
//³ mv_par18				// Usu rio Inicial 								  ³
//³ mv_par19				// Usu rio Final 								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Pergunte(cPerg,.T.)
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arq. Temporario para guardar recalculos de incerteza  				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aTMPstru,{ "TMP_FILIAL", "C", TamSX3("QM7_FILIAL")[1 ],0})
aadd(aTMPstru,{ "TMP_INSTR" , "C", TamSX3("QM7_INSTR")[1]  ,0})
aadd(aTMPstru,{ "TMP_REVINS", "C", TamSX3("QM7_REVINS")[1] ,0})
aadd(aTMPstru,{ "TMP_DATA"  , "D", TamSX3("QM7_DATA")[1]   ,0})
aadd(aTMPstru,{ "TMP_ESCALA", "C", TamSX3("QM7_ESCALA")[1] ,0})
aadd(aTMPstru,{ "TMP_REVESC", "C", TamSX3("QM7_REVESC")[1] ,0})
aadd(aTMPstru,{ "TMP_PONTO" , "C", TamSX3("QM7_PONTO")[1]  ,0})
aadd(aTMPstru,{ "TMP_REVPAD", "C", TamSX3("QM7_REVPAD")[1] ,0})
aadd(aTMPstru,{ "TMP_EXAT"  , "C", TamSX3("QM7_EXAT")[1]   ,0})
aadd(aTMPstru,{ "TMP_ADEQ"  , "C", TamSX3("QM7_ADEQ")[1]   ,0})
aadd(aTMPstru,{ "TMP_ACEIT" , "C", TamSX3("QM7_ACEIT")[1]  ,0})
aadd(aTMPstru,{ "TMP_INCERT", "C", TamSX3("QM7_INCERT")[1] ,0})
aadd(aTMPstru,{ "TMP_ERSIST", "C", TamSX3("QM7_ERSIST")[1] ,0})
aadd(aTMPstru,{ "TMP_RESULT", "C", TamSX3("QM7_RESULT")[1] ,0})
aadd(aTMPstru,{ "TMP_CSEQ"  , "C", TamSX3("QM7_CSEQ")[1] ,0})

oTmpTable := FWTemporaryTable():New( "TMP" )
oTmpTable:SetFields( aTMPstru )
oTmpTable:AddIndex("indice1", {"TMP_INSTR","TMP_REVINS","TMP_DATA"} )
oTmpTable:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se apertou o botao cancela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nLastKey == 27
	Return
EndIf

dbSelectArea( "QM6" )
dbSetOrder(1)
dbSeek( xFilial() + mv_par01 )

While !Eof()
	
	If QM6->QM6_FILIAL != xfilial()
		Exit
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o c¢digo do instrumento.                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( QM6->QM6_INSTR > mv_par02 )
		Exit
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se n„o est  entre os periodos informados, n„o imprime.          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( QM6->QM6_DATA < mv_par03 .or. QM6->QM6_DATA > mv_par04 )
		dbSkip()
		Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura o instrumento relacionado com o cabe‡alho               ³
	//³ e posiciona os arquivos relacionados.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "QM2" )
	dbSetOrder(1)
	dbSeek( xFilial() + QM6->QM6_INSTR + Inverte(QM6->QM6_REVINS) )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura o DEPARTAMENTO no QAD.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "QAD" )
	dbSetOrder(1)
	dbSeek( xFilial() + QM2->QM2_DEPTO )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura o RESPONSAVEL NO SRA.                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QAA")
	dbSetOrder(1)
	dbSeek( cFilAnt + QM2->QM2_RESP )
	
	dbSelectArea( "QM6" )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se n„o est  entre os departamentos informados, n„o imprime.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( QM2->QM2_DEPTO < mv_par05 .or. QM2->QM2_DEPTO > mv_par06 )
		dbSkip()
		Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico O.C. interno e externo                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par07 == 1
		If ! Calibrador(0,mv_par08,mv_par09,mv_par10,mv_par11)
			dbSkip()
			Loop
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico O.C. interno                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par07 == 2
		If ! Calibrador(1,mv_par08,mv_par09)
			dbSkip()
			Loop
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico O.C. externo                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par07 == 3
		If ! Calibrador(2,,,mv_par10,mv_par11)
			dbSkip()
			Loop
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se n„o ‚ a familia selecionada n„o Imprime.                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( QM2->QM2_TIPO < mv_par12 .or. QM2->QM2_TIPO > mv_par13 )
		dbSkip()
		Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ N„o ‚ o fabricante selecionado.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( QM2->QM2_FABR < mv_par14 .or. QM2->QM2_FABR > mv_par15 )
		dbSkip()
		Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o status.         												  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QM2->QM2_STATUS < mv_par16 .Or. QM2->QM2_STATUS > mv_par17
		dbSkip()
		Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ N„o ‚ o usu rio selecionado.                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( QM2->QM2_RESP < mv_par18 .or. QM2->QM2_RESP > mv_par19 )
		dbSkip()
		Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega aMedicoes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMtInstr	:= QM6->QM6_INSTR
	cMtRevIns   := QM6->QM6_REVINS
	dMtData	    := QM6->QM6_DATA
	cMtResp	    := QM6->QM6_RESP
	cMtTotHr	:= QM6->QM6_TOTHOR
	cMtRepRepr  := QM6->QM6_REPEPR
    cSeql		:= QM6->QM6_CSEQ
 
	a140CarMed()
	
	For nCntFor := 1 to len(aMedicoes)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula valores na GETDADOS ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aResult, a140Calc(nCntFor,.f.))
		dbSelectArea("QM7")
		If QM7->(DbSeek(xFilial("QM7")+cMtInstr+cMtRevIns+;
  			DtoS(dMtData)+cSeql+aMedicoes[nCntFor,nPosEsc]+aMedicoes[nCntFor,nPosGer,1,11]+;
  			aMedicoes[nCntFor,nPosPad]+aMedicoes[nCntFor,nPosGer,1,12]))		

			RecLock("QM7",.f.)
			
			If aMedicoes[nCntFor,nPosGer,1,6] == '1' // Incerteza c/ Confirmacao Metrologica
				Replace QM7_EXAT  with If(aResult[1,1,7],"A","R") // Exatidao
				Replace QM7_ACEIT with If(aResult[1,1,8],"A","R") // Aceitabilidade
				Replace QM7_ADEQ  with If(aResult[1,1,9],"A","R") // Adequacao
			EndIf
			
			If !empty(aResult)
				If ValType(aResult[1,1,5]) == "C"
					aResult[1,1,5] := SuperVal(aResult[1,1,5])
				Endif
				Replace QM7_INCERT with Padl(Ltrim(Str(aResult[1,1,5])),10) // Incerteza
				If ValType(aResult[1,1,2]) == "C"
					aResult[1,1,2] := SuperVal(aResult[1,1,2])
				Endif
				Replace QM7_ERSIST with Padl(Ltrim(Str(aResult[1,1,2])),10) // Desvio Medio (Maior Erro Sistematico)
			EndIf
			
			Replace QM7_RESULT with aResult[1,1,10] // Status Final
			MsUnlock()
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava registro de alteracao de calculo de incerteza			  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		RecLock("TMP",.T.)
		
		Replace TMP_FILIAL  with xFilial()
  		Replace TMP_INSTR   with cMtInstr
  		Replace TMP_REVINS  with cMtRevIns
  		Replace TMP_DATA    with dMtData 
		Replace TMP_ESCALA  with aMedicoes[nCntFor,nPosEsc]
		Replace TMP_REVESC  with aMedicoes[nCntFor,nPosGer,1,11]
		Replace TMP_PONTO   with aMedicoes[nCntFor,nPosPad]
		Replace TMP_REVPAD  with aMedicoes[nCntFor,nPosGer,1,12]
		Replace TMP_EXAT    with If(aResult[1,1,7],"A","R")
       	Replace TMP_ADEQ    with If(aResult[1,1,8],"A","R")
       	Replace TMP_ACEIT   with If(aResult[1,1,9],"A","R")
		If Valtype(aResult[1,1,5]) = "N"
			Replace TMP_INCERT  with Padl(Ltrim(Str(aResult[1,1,5])),10)
		Else
			Replace TMP_INCERT  with Padl(Ltrim(aResult[1,1,5]),10)
		EndIf
		If Valtype(aResult[1,1,2]) = "N"
			Replace TMP_ERSIST  with Padl(Ltrim(Str(aResult[1,1,2])),10)
		Else
			Replace TMP_ERSIST  with Padl(Ltrim(aResult[1,1,2]),10)
		EndIf
		Replace TMP_RESULT  with aResult[1,1,10]
		Replace TMP_CSEQ	with cSeql
		
		MsUnLock()
		
	Next nCntFor
	
	DbSelectArea("QM6")
	DbSkip()
	
EndDo

If TMP->(Eof()) .and. TMP->(Bof())
	Help( " ", 1, "M400NEM" ) // NÆo foi efetuado nenhum recalculo
Else
	MessageDlg(OemToAnsi(STR0002),,2) //"Rec lculo encerrado com sucesso"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desmonta arquivos temporarios										  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ( Select("TMP") != 0 )
	oTmpTable:Delete()
EndIf

Return(Nil)
