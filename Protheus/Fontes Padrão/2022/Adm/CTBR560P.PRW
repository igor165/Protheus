#Include "CTBR560P.CH"
#Include "PROTHEUS.CH"

#DEFINE CXAINI 1
#DEFINE CXAFIM 2

//--------------------------------------------------------------------------------------------------
//Criar no CTB.PRW a criacao da consulta padrao (SXB) chamada SX5SL
//--------------------------------------------------------------------------------------------------
//SX5SL - 1 - 01 - RE - SELECAO SALDOS CTB - SELECAO SALDOS CTB - SELECAO SALDOS CTB - SX5
//SX5SL - 2 - 01 - 01 -                    -                    -                    - CTR560SX5(1)
//SX5SL - 5 - 01 -    -                    -                    -                    - cRetSX5SL
//--------------------------------------------------------------------------------------------------

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ Ctbr560	³ Autor ³ Felipe Aurelio de Melo ³ Data ³ 25.09.08 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ DEMONSTRACAO DO FLUXO DE CAIXA                              ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum                                                      ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ Nenhum                                                      ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbR560P()

Local lRet        	:= .T.
Local nHandle		:= 0

Private cRetSX5SL := ""
Private cPerg     := "CTR560P"
Private NomeProg  := "CTBR560P"
Private wnRel     := "CTBR560P"
Private dFinal    := StoD("")
Private dFinalA   := StoD("")
Private aSetOfBook:= {}
Private aCtbMoeda := {}
Private aSelFil		:= {}
Private cTitulo   := STR0001 //"DEMONSTRACAO DO FLUXO DE CAIXA"

// verifica existencia da consulta padrao SX5SL
If SXB->(!DbSeek("SX5SL"))
	Help(" ",1,"HELP","",STR0002,3,1)
	lRet := .F.
EndIf

//chama a tela de perguntas
If lRet .And. !Pergunte(cPerg,.T.)
	lRet := .F.
Else
	aSetOfBook:= CTBSetOf(mv_par02)
	aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
EndIf

// Faz a validacao das filiais
If lRet .And. mv_par23 == 1 .And. Len( aSelFil ) <= 0 
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		lRet := .F.
	EndIf 
EndIf 

//faz a validacao do livro
If lRet .And. !VdSetOfBook(mv_par02,.T.)
	lRet := .F.
EndIf

If lRet .And. Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
	lRet := .F.
Endif

If lRet .And. MV_PAR10 == 1 .And. (nHandle:= FOpen( mv_par11,3)) < 0
	MsgAlert(STR0022) //"O arquivo da Nota Explicativa (.TRM) não pode estar como somente leitura."
	lRet := .F.
ElseIf lRet
	FClose(nHandle)
EndIf

//Se passou pelas perguntas e validacoes chama funcao de impressao do relatorio
If lRet
	CTR560R3P()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CTR560R3P ³ Autor³ Felipe Aurelio de Melo³ Data ³ 25.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ DEMONSTRACAO DO FLUXO DE CAIXA - R4                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CTR560R3P                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CTR560R3P()

Local lMovPeriodo := mv_par13 == 1
local aArea       := GetArea()
Local cDesc       := ""
Private m_pag     := mv_par07 // numeração da pagina

cDesc += OemToAnsi( STR0003 )  			//"Este programa irá imprimir a Demonstração do fluxo de caixa, "
cDesc += OemToAnsi( STR0004 )			//"de acordo com os parâmetros informados pelo usuário."
cTitulo := If(!Empty(aSetOfBook[10]),aSetOfBook[10],cTitulo)                        //"Titulo definido SetOfBook"

If (mv_par22 == 1)
	cTitulo := CTBNomeVis( aSetOfBook[5] )
EndIf

If mv_par09 == 1
	// SE DEVE CONSIDERAR TODO O CALENDARIO
	CTG->(DbSeek(xFilial("CTG")+mv_par01))
	dbSelectArea("CTG")
	dbSetOrder(1)
	MsSeek(xFilial("CTG")+mv_par01,.T.)
	
	If Empty(mv_par08)
		While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
			dFinal	:= CTG->CTG_DTFIM
			CTG->(DbSkip())
		EndDo
	Else
		dFinal	:= mv_par08
	EndIf
	dFinalA   	:= Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 1, 4))
	mv_par01    := dFinal
Else
	// SE DEVE CONSIDERAR O PERIODO CONTABIL
	If Empty(mv_par08)
		MsgInfo( STR0005, STR0006 )//"É necessário informar a data de referência !"#"Parametro Considera igual a Periodo."
		Return .F.
	Endif
	dFinal := mv_par08
	
	CTG->(dbSetOrder(1))
	CTG->(DbSeek(xFilial("CTG")+mv_par01))
	While CTG->CTG_FILIAL == xFilial("CTG") .And. CTG->CTG_CALEND == mv_par01
		If dFinal >= CTG->CTG_DTINI .and. dFinal <= CTG->CTG_DTFIM
			dFinalA		:= CTG->CTG_DTINI-1							
			Exit
		Endif
		CTG->(DbSkip())
	EndDo
	
	If Empty(dFinalA)
		MsgInfo( STR0007, STR0008 )//"Data fora do calendário !"#"Data de referência."
		Return .F.
	Endif
EndIf

If lMovPeriodo
	dPeriodo0 := CtoD("01/01/"+Alltrim(Str(Year(dFinalA))))
EndIf

MsgRun(	STR0009,"",{|| CursorWait(), Ctr500Cfg(@cTitulo, "Ctr560DtP", STR0001, .F.) ,CursorArrow()}) //"Gerando relatorio, aguarde..."##"DEMONSTRACAO DO FLUXO DE CAIXA"

//Limpa os arquivos temporários 
CTBGerClean()

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    Ctr560DtP ³ Autor ³ Felipe Aurelio de Melo³ Data ³ 25.09.08 ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Detalhe do Relatorio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctr560DtP(ExpO1,ExpN1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpN1 = Contador de paginas                                ³±±
±±³          ³ ParC1 = Titulo do relatorio                                ³±±
±±³          ³ ParC2 = Titulo da caixa do processo                        ³±±
±±³          ³ ParL1 = Indica se imprime em Paisagem (.T.) ou Retrato .F. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctr560DtP(oPrint,i,cTitulo,cProcesso,lLandScape)
Private lComNivel   := .T.

#DEFINE N_CONTA 	 1
#DEFINE N_DESCCTA	 2
#DEFINE N_COLUNA	 3
#DEFINE N_IDENTIFI	 4
#DEFINE N_TIPOCONTA	 5
#DEFINE N_SUPERIOR	 6
#DEFINE N_TOTVIS	 7
#DEFINE N_NORMAL	 8
#DEFINE N_MOVPERANT	 9
#DEFINE N_MOVIMENTO	 10
#DEFINE N_NIVEL		 11


If mv_par13 == 1
	ImpPeriod(oPrint,i,cTitulo,cProcesso,lLandScape)		
Else
	ImpSaldo(oPrint,i,cTitulo,cProcesso,lLandScape)		
EndIf	

Return
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} ImpPeriod

@author TOTVS
@since 21/07/2020
@version 12.1.31
@return 
/*/
//---------------------------------------------------------------------------------------
Static Function ImpPeriod(oPrint,i,cTitulo,cProcesso,lLandScape)
Local cArqTmp
Local nTraco      	:= 0
Local nColuna     	:= 0
Local cCodVis     	:= Posicione("CTN",1, xFilial("CTN")+MV_PAR02,"CTN_PLAGER")
Local cDescCont   	:= ""
Local nBegin		:= 0
Local nLinha		:= 0
Local nPosCol		:= 0
Local lFirstPage	:= .T.
Local lin 			:= 3001
Local nTamLin		:= 2349
Local lMovPeriodo 	:= mv_par13 == 1
Local cTpValor		:= GetMV("MV_TPVALOR")
Local cDescMoeda  	:= AllTrim(aCtbMoeda[3])
Local lImpTrmAux	:= Iif(mv_par10 == 1,.T.,.F.)
Local nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)
Local cMoedaDesc  	:= IIf( Empty(mv_par14),mv_par03,mv_par14)
Local cPicture 		:= IIf(!Empty(aSetOfBook[4]) .And. Len(Trans(0, aSetOfBook[4])) > 17,"",aSetOfBook[4])
Local aPosCol		:= IIf(MV_PAR06 == 1,{ 1120, 1500, 1900 },{ 1500, 1900 })
Local lVlrZerado  	:= IIf(mv_par12==1,.T.,.F.)
Local cSaldos     	:= fTrataSlds()
Local nSaldoAnt		:= 0
Local nSaldoAtu		:= 0
Local nSaldoVar		:= 0
Local nI			:= 0
Local nX			:= 0
Local cFiliais		:= ""
Local cSelFil		:= ""
Local aTotais		:= {0,0,0}
Local aImpArray		:= {}
Local aSubTot       := {0,0,0}
Local cDesSubTot	:= ""
Local dDtAntLP      := StoD("")

//Limitado a exibição do titulo em 85 caracteres para que não estoure na exibição das filiais
If Len(aSelFil) > 0            
	For nX := 1 to Len(aSelFil)
		cFiliais += aSelFil[nX] + ","
	Next nX
	
	cFiliais := Left(cFiliais,Len(cFiliais)-1)
	
	//Não exibe as filiais caso nao haja espaco suficiente.
	If Len(cTitulo + STR0019 + cFiliais) <= 85
		cTitulo += STR0019 + cFiliais
	EndIf	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to 2
	
	If nI == 1 
		If mv_par09==1 
			dDataIni := MonthSub(dFinalA,12)+1
		Else
			dDataIni := FirstDate(dFinalA)
		EndIf
		dDataFim := dFinalA
	Else
		dDataIni := dFinalA+1
		dDataFim := dFinal	
	EndIf

	If mv_par04 == 1
		dDtAntLP := StoD(cValToChar(Year(dDataFim))+MesDia(mv_par05))
	EndIf

	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTGerPlan(	/*01*/oMeter,;
								/*02*/oText,;
								/*03*/oDlg,;
								/*04*/@lEnd,;
								/*05*/@cArqTmp,;
								/*06*/dDataIni,;
								/*07*/dDataFim,;
								/*08*/"",;
								/*09*/"",;
								/*10*/"",;
								/*11*/Repl("Z", TamSx3("CT1_CONTA")[1]),;
								/*12*/"",;
								/*13*/Repl("Z", TamSx3("CTT_CUSTO")[1]),;
								/*14*/"",;
								/*15*/Repl("Z", TamSx3("CTD_ITEM")[1]),;
								/*16*/"",;
								/*17*/Repl("Z", TamSx3("CTH_CLVL")[1]),;
								/*18*/mv_par03,;
								/*19*/cSaldos,;
								/*20*/aSetOfBook,;
								/*21*/,;
								/*22*/"",;
								/*23*/Repl("Z", 20),;
								/*24*/,;
								/*25*/,;
								/*26*/,;
								/*27*/,;
								/*28*/,;
								/*29*/mv_par04=1,;
								/*30*/dDtAntLP,;
								/*31*/,;
								/*32*/lVlrZerado,;
								/*33*/,;
								/*34*/,;
								/*35*/,;
								/*36*/,;
								/*37*/,;
								/*38*/,;
								/*39*/,;
								/*40*/,;
								/*41*/,;
								/*42*/,;
								/*43*/,;
								/*44*/,;
								/*45*/,;
								/*46*/,;
								/*47*/,;
								/*48*/,;
								/*49*/,;
								/*50*/,;
								/*51*/,;
								/*52*/,;
								/*53*/,;
								/*54*/,;
								/*55*/,;
								/*56*/,;
								/*57*/cMoedaDesc,;
								/*58*/lMovPeriodo,;
								/*59*/aSelFil,;
								/*60*/,;
								/*61*/.T.,;
								/*62*/mv_par15=1);
				},STR0010,cProcesso) //"Criando Arquivo Temporario..."

	dbSelectArea( "cArqTmp" )
	dbGoTop()
	
	While cArqTmp->(!Eof())

		If cArqTmp->VISENT == "2"
			cArqTmp->( DbSkip() )
			Loop
		EndIf

		If nI == 1
			nSaldoAnt := cArqTmp->MOVIMENTO
			nSaldo    := 0			
		Else
			nSaldoAnt := 0
			nSaldo    := cArqTmp->MOVIMENTO			
		EndIf

		If (nPos := aScan(aImpArray,{|x| x[1] == cArqTmp->CONTA })) > 0
			aImpArray[nPos,N_MOVPERANT] += nSaldoAnt
			aImpArray[nPos,N_MOVIMENTO] += nSaldo
		Else
			AAdd(aImpArray,{cArqTmp->CONTA,;	//01
							cArqTmp->DESCCTA,;	//02
							cArqTmp->COLUNA,;	//03
							cArqTmp->IDENTIFI,;	//04
							cArqTmp->TIPOCONTA,;//05
							cArqTmp->SUPERIOR,;	//06
							cArqTmp->TOTVIS,;	//07
							cArqTmp->NORMAL,;	//08
							nSaldoAnt,;			//09
							nSaldo,;				//10
							cArqTmp->NIVEL})	//11
		EndIf
		cArqTmp->(dbSkip())
	EndDo
	cArqTmp->(dbCloseArea())
Next nI

For nI := 1 to Len(aImpArray)

	If lin > 3000
		If !lFirstPage
			oPrint:Line( ntraco,150,ntraco,nTamLin )//Horizontal
		EndIf
		i++
		oPrint:EndPage()//Finaliza a pagina
		
		CtbCbcDem(oPrint,cTitulo,lLandScape,aSelFil)//Funcao que monta o cabecalho padrao

		lin := 270
		If MV_PAR18 == 2
			Ctr560Ind( oPrint, @lin, nTamLin )
		EndIf

		Ctr560Esp(oPrint,cDescMoeda,aPosCol,nTamLin, lin)
		lin += 50
		lFirstPage := .F.
	EndIf


	If AllTrim(aImpArray[nI,N_CONTA]) == "-"
		// Linha horizontal
		oPrint:Line(lin,150,lin,nTamLin)
	Else

		If Empty(aImpArray[nI,N_SUPERIOR]) .And. !Empty(cDesSubTot)			
			oPrint:Line( lin,150,lin+57,150)
			oPrint:Say(lin+15,nColuna,MemoLine(cDesSubTot,74,1), If(aSubTot[N_IDENTIFI] $ "3469", oCouNew08N, oFont08))
			For nPosCol := 1 To Len(aPosCol)
				oPrint:Line(lin,aPosCol[nPosCol],lin+50,aPosCol[nPosCol])					
				If nPosCol == 1
					nSubTot := aSubTot[N_MOVIMENTO]
				ElseIf nPosCol == 2
					nSubTot := aSubTot[N_MOVPERANT]
				ElseIf nPosCol == 3
					nSubTot := aSubTot[N_MOVIMENTO]-aSubTot[N_MOVPERANT]
				EndIf
				
				ValorCTB(nSubTot,lin+15,aPosCol[nPosCol],IIf(cTpValor $ "D",20,23),nDecimais,.T.,cPicture,aSubTot[N_NORMAL],aSubTot[N_CONTA],.T.,oPrint,cTpValor,IIf(aSubTot[N_IDENTIFI] $ "4","1",aSubTot[N_IDENTIFI]))								
			Next aPosCol
			oPrint:Line(lin,nTamLin,lin+57,nTamLin)
			lin += 57			
		EndIf
		
		//Linha vertical
		If !Empty(aImpArray[nI,N_SUPERIOR])			
			oPrint:Line( lin,150,lin+50,150)
		EndIf

		//Negrito caso Sub-Total/Total/Separador (caso tenha descricao) e Igual (Totalizador)
		nColuna := 180+(15*aImpArray[nI,N_COLUNA] )
		cDescCont := Posicione("CTS",2,xFilial("CTS")+cCodVis+aImpArray[nI,N_CONTA],"CTS_DETHCG")
		cDescCont := AllTrim(aImpArray[nI,N_DESCCTA])+Rtrim(cDescCont)
		cDescCont := Space(aImpArray[nI,N_NIVEL]) + cDescCont
		nLinha:= MLCount(cDescCont,74)

		If Empty(aImpArray[nI,N_SUPERIOR])
			If AllTrim(aImpArray[nI,N_CONTA]) == "1"
				cDesSubTot := STR0023 //"FLUXO DE CAIXA LÍQUIDO DAS OPERAÇÕES"
			ElseIf AllTrim(aImpArray[nI,N_CONTA]) == "2"
				cDesSubTot := STR0024 //"FLUXO DE CAIXA LÍQUIDO DAS ATIVIDADES DE INVESTIMENTO"
			ElseIf AllTrim(aImpArray[nI,N_CONTA]) == "3"
				cDesSubTot := STR0025 //"FLUXO DE CAIXA LÍQUIDO DAS ATIVIDADES DE FINANCIAMENTO"
			EndIf
			aSubTot := aClone(aImpArray[nI])
			oPrint:Line(lin,150,lin,nTamLin)
		EndIf

		oPrint:Say(lin+15,nColuna,MemoLine(cDescCont,74,1), If(aImpArray[nI,N_IDENTIFI] $ "3469" .Or. Empty(aImpArray[nI,N_SUPERIOR]), oCouNew08N, oFont08))

		For nPosCol := 1 To Len(aPosCol)
			If !Empty(aImpArray[nI,N_SUPERIOR])	
				oPrint:Line(lin,aPosCol[nPosCol],lin+50,aPosCol[nPosCol])	// Separador vertical
			EndIf
			Do Case
				Case nPosCol = 1
					nSaldo := aImpArray[nI,N_MOVIMENTO]
				
					If aImpArray[nI,N_TIPOCONTA] == "1" .AND. Empty( aImpArray[nI,N_SUPERIOR] ) .AND. aImpArray[nI,N_TOTVIS] == "1"
						nSaldoAtu += nSaldo
					EndIf					
				Case nPosCol = 2
					nSaldo := aImpArray[nI,N_MOVPERANT]

					If aImpArray[nI,N_TIPOCONTA] == "1" .AND. Empty( aImpArray[nI,N_SUPERIOR] ) .AND. aImpArray[nI,N_TOTVIS] == "1"
						nSaldoAnt += nSaldo
					EndIf
				Case nPosCol = 3
					nSaldo := aImpArray[nI,N_MOVIMENTO]-aImpArray[nI,N_MOVPERANT]
					
					If aImpArray[nI,N_TIPOCONTA] == "1" .AND. Empty( aImpArray[nI,N_SUPERIOR] ) .AND. aImpArray[nI,N_TOTVIS] == "1"
						nSaldoVar += nSaldo
					EndIf
			EndCase			

			If aImpArray[nI,N_IDENTIFI] < "5"  
				If Empty(aImpArray[nI,N_SUPERIOR])			
					aSubTot[nPosCol] := nSaldo
				Else
					ValorCTB(nSaldo,lin+15,aPosCol[nPosCol],IIf(cTpValor $ "D",20,23),nDecimais,.T.,cPicture,aImpArray[nI,N_NORMAL],aImpArray[nI,N_CONTA],.T.,oPrint,cTpValor,IIf(aImpArray[nI,N_IDENTIFI] $ "4","1",aImpArray[nI,N_IDENTIFI]))				
				EndIf
			EndIf

			//Incrementa Totalizador
			If aImpArray[nI,N_TIPOCONTA] == "2"				
				aTotais[nPosCol] += nSaldo				
			EndIf
		Next

		//Separador vertical
		If !Empty(aImpArray[nI,N_SUPERIOR])	
			oPrint:Line(lin,nTamLin,lin+50,nTamLin)
		EndIf
		
		//Impressão da continuacao da descricao caso exista
		For nBegin := 2 To nLinha
			lin +=47
			oPrint:Line( lin,150,lin+50,150)	// Separador vertical
			oPrint:Say(lin+15,nColuna,MemoLine(cDescCont,74,nBegin), If(aImpArray[nI,N_IDENTIFI] $ "3469", oCouNew08N, oFont08))
			For nPosCol := 1 To Len(aPosCol)
				oPrint:Line(lin,aPosCol[nPosCol],lin+50,aPosCol[nPosCol])	// Separador vertical
			Next nPosCol
			oPrint:Line(lin,nTamLin,lin+50,nTamLin) ////Separador vertical
		Next nBegin
		
		lin +=47

		If Empty(aImpArray[nI,N_SUPERIOR])
			oPrint:Line(lin,150,lin,nTamLin)
		EndIf
	Endif
	
	nTraco := lin + 1
Next nI

oPrint:Line( lin,150,lin+50,150)
oPrint:Say(lin+15,nColuna,MemoLine(cDesSubTot,74,1), If(aSubTot[N_IDENTIFI] $ "3469", oCouNew08N, oFont08))
For nPosCol := 1 To Len(aPosCol)
	oPrint:Line(lin,aPosCol[nPosCol],lin+50,aPosCol[nPosCol])	
	If nPosCol == 1
		nSubTot := aSubTot[N_MOVIMENTO]
	ElseIf nPosCol == 2
		nSubTot := aSubTot[N_MOVPERANT]
	ElseIf nPosCol == 3
		nSubTot := aSubTot[N_MOVIMENTO]-aSubTot[N_MOVPERANT]
	EndIf
	
	ValorCTB(nSubTot,lin+15,aPosCol[nPosCol],IIf(cTpValor $ "D",20,23),nDecimais,.T.,cPicture,aSubTot[N_NORMAL],aSubTot[N_CONTA],.T.,oPrint,cTpValor,IIf(aSubTot[N_IDENTIFI] $ "4","1",aSubTot[N_IDENTIFI]))					
Next aPosCol
oPrint:Line(lin,nTamLin,lin+50,nTamLin)

lin +=47
//Linha horizontal
oPrint:Line(lin,150,lin,nTamLin)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³preenche o saldo dos exercicios na caixa de atividades³
//³operacionais usado com o metodo indireto              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR18 == 2
	If MV_PAR19 == 2
		nSaldoAtu := MV_PAR20
		nSaldoAnt := MV_PAR21
		nSaldoVar := nSaldoAtu - nSaldoAnt
	EndIf

	If MV_PAR06 == 1
		ValorCTB(nSaldoAnt, 379,  770,IIf(cTpValor $ "D",20,IIF(cTpValor $ "P", 23, 21)),nDecimais,.T.,cPicture,,,.T.,oPrint,cTpValor,"1")
		ValorCTB(nSaldoAtu, 379, 1350,IIf(cTpValor $ "D",20,IIF(cTpValor $ "P", 23, 21)),nDecimais,.T.,cPicture,,,.T.,oPrint,cTpValor,"1")
		ValorCTB(nSaldoVar, 379, 1918,IIf(cTpValor $ "D",22,23),nDecimais,.T.,cPicture,,,.T.,oPrint,cTpValor,"1")
	Else
		ValorCTB(nSaldoAnt, 379, 1350,IIf(cTpValor $ "D",20,IIF(cTpValor $ "P", 23, 21)),nDecimais,.T.,cPicture,,,.T.,oPrint,cTpValor,"1")
		ValorCTB(nSaldoAtu, 379, 1918,IIf(cTpValor $ "D",20,IIF(cTpValor $ "P", 23, 21)),nDecimais,.T.,cPicture,,,.T.,oPrint,cTpValor,"1")
	EndIf
EndIf

lin += 20 

//Totalizador Fluxo de Caixa  
If lin > 3000
	If !lFirstPage
		oPrint:Line( ntraco,150,ntraco,nTamLin ) //horizontal
	EndIf
	i++
	oPrint:EndPage() 	 							//Finaliza a pagina
	CtbCbcDem(oPrint,cTitulo,lLandScape)			//Funcao que monta o cabecalho padrao
	Ctr560Esp(oPrint, cDescMoeda,aPosCol,nTamLin,lin)
	lin := 304
	lFirstPage := .F.
EndIf

//Inicializa Totalizador Caixa Inicial periodo anterior
cSelFil := IIf(!Empty(cFiliais),cFiliais,cFilAnt)

ImpQuadTot(oPrint,@lin,nTamLin,nColuna,aPosCol,aTotais,cMoedaDesc,cSaldos,cSelFil,cTpValor,nDecimais,cPicture)

lin += 10             

If lImpTrmAux
	If lin > 3000
		If !lFirstPage
			oPrint:Line( ntraco,150,ntraco,nTamLin )   	// horizontal
		EndIf
		i++
		oPrint:EndPage() 	 								// Finaliza a pagina
		CtbCbcDem(oPrint,cTitulo,lLandScape)					// Funcao que monta o cabecalho padrao
		Ctr560Esp(oPrint, cDescMoeda,aPosCol,nTamLin,lin)
		lin := 304
		lFirstPage := .F.
	Endif

	cArqTRM 	   := mv_par11
	aVariaveis  := {}

	// Buscando os parâmetros do relatorio (a partir do SX1) para serem impressaos do Termo (arquivos *.TRM)
	SX1->(DbSeek(cPerg+"01"))
	While AllTrim(SX1->X1_GRUPO) == cPerg
		AADD(aVariaveis,{AllTrim(Upper(SX1->X1_VAR01)),&(SX1->X1_VAR01)})
		SX1->(DbSkip())
	End

	If !File(cArqTRM)
		aSavSet:=__SetSets()
		cArqTRM := CFGX024( cArqTRM, STR0011 ) // "Responsáveis..."
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqTRM#NIL
		ImpTerm(cArqTRM,aVariaveis,"",.T.,{oPrint,oFont08,Lin})
	Endif
Endif
 
If Select( "cArqTmp" ) == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	

Return 
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} ImpSaldo

@author TOTVS
@since 21/07/2020
@version 12.1.31
@return 
/*/
//---------------------------------------------------------------------------------------
Static Function ImpSaldo(oPrint,i,cTitulo,cProcesso,lLandScape)
Local cArqTmp
Local nTraco      	:= 0
Local nColuna     	:= 0
Local cCodVis     	:= Posicione("CTN",1, xFilial("CTN")+MV_PAR02,"CTN_PLAGER")
Local cDescCont   	:= ""
Local nBegin		:= 0
Local nLinha		:= 0
Local nPosCol		:= 0
Local lFirstPage	:= .T.
Local lin 			:= 3001
Local nTamLin		:= 2349
Local lMovPeriodo 	:= mv_par13 == 1
Local cTpValor		:= GetMV("MV_TPVALOR")
Local cDescMoeda  	:= AllTrim(aCtbMoeda[3])
Local lImpTrmAux	:= Iif(mv_par10 == 1,.T.,.F.)
Local nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)
Local cMoedaDesc  	:= IIf( Empty(mv_par14),mv_par03,mv_par14)
Local cPicture 		:= IIf(!Empty(aSetOfBook[4]) .And. Len(Trans(0, aSetOfBook[4])) > 17,"",aSetOfBook[4])
Local aPosCol		:= IIf(MV_PAR06 == 1,{ 1120, 1500, 1900 },{ 1500, 1900 })
Local lVlrZerado  	:= IIf(mv_par12==1,.T.,.F.)
Local cSaldos     	:= fTrataSlds()
Local nSaldoAnt		:= 0
Local nSaldoAtu		:= 0
Local nSaldoVar		:= 0
Local nX			:= 0
Local cFiliais		:= ""
Local cSelFil		:= ""
Local aTotais		:= {0,0,0}
Local cDesSubTot	:= ""
Local aSubTot		:= {0,0,0}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(	/*01*/oMeter,;
							/*02*/oText,;
							/*03*/oDlg,;
							/*04*/@lEnd,;
							/*05*/@cArqTmp,;
							/*06*/dFinalA+1,;
							/*07*/dFinal,;
							/*08*/"",;
							/*09*/"",;
							/*10*/"",;
							/*11*/Repl("Z", TamSx3("CT1_CONTA")[1]),;
							/*12*/"",;
							/*13*/Repl("Z", TamSx3("CTT_CUSTO")[1]),;
							/*14*/"",;
							/*15*/Repl("Z", TamSx3("CTD_ITEM")[1]),;
							/*16*/"",;
							/*17*/Repl("Z", TamSx3("CTH_CLVL")[1]),;
							/*18*/mv_par03,;
							/*19*/cSaldos,;
							/*20*/aSetOfBook,;
							/*21*/,;
							/*22*/"",;
							/*23*/Repl("Z", 20),;
							/*24*/,;
							/*25*/,;
							/*26*/,;
							/*27*/,;
							/*28*/,;
							/*29*/mv_par04=1,;
							/*30*/mv_par05,;
							/*31*/,;
							/*32*/lVlrZerado,;
							/*33*/,;
							/*34*/,;
							/*35*/,;
							/*36*/,;
							/*37*/,;
							/*38*/,;
							/*39*/,;
							/*40*/,;
							/*41*/,;
							/*42*/,;
							/*43*/,;
							/*44*/,;
							/*45*/,;
							/*46*/,;
							/*47*/,;
							/*48*/,;
							/*49*/,;
							/*50*/,;
							/*51*/,;
							/*52*/,;
							/*53*/,;
							/*54*/,;
							/*55*/,;
							/*56*/,;
							/*57*/cMoedaDesc,;
							/*58*/lMovPeriodo,;
							/*59*/aSelFil,;
							/*60*/,;
							/*61*/.T.,;
							/*62*/mv_par15=1);
			},STR0010,cProcesso) //"Criando Arquivo Temporario..."

dbSelectArea( "cArqTmp" )
dbGoTop()


//Limitado a exibição do titulo em 85 caracteres para que não estoure na exibição das filiais
If Len(aSelFil) > 0            
	For nX := 1 to Len(aSelFil)
		cFiliais += aSelFil[nX] + ","


	Next nX
	
	cFiliais := Left(cFiliais,Len(cFiliais)-1)
	
	//Não exibe as filiais caso nao haja espaco suficiente.
	If Len(cTitulo + STR0019 + cFiliais) <= 85
		cTitulo += STR0019 + cFiliais
	EndIf	
EndIf
	
While cArqTmp->(!Eof())
	If lin > 3000
		If !lFirstPage
			oPrint:Line( ntraco,150,ntraco,nTamLin )//Horizontal
		EndIf
		i++
		oPrint:EndPage()//Finaliza a pagina
		
		CtbCbcDem(oPrint,cTitulo,lLandScape,aSelFil)//Funcao que monta o cabecalho padrao

		lin := 270
		If MV_PAR18 == 2
			Ctr560Ind( oPrint, @lin, nTamLin )
		EndIf

		Ctr560Esp(oPrint,cDescMoeda,aPosCol,nTamLin, lin)
		lin += 50
		lFirstPage := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³indica se a entidade gerencial sera impressa/visualizada em ³
	//³um relatorio ou consulta apos o processamento da visao      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cArqTmp->VISENT == "2"
		cArqTmp->( DbSkip() )
		Loop
	EndIf
	
	If AllTrim(cArqTmp->DESCCTA ) == "-"
		// Linha horizontal
		oPrint:Line(lin,150,lin,nTamLin)
	Else

		If Empty(cArqTmp->SUPERIOR) .And. !Empty(cDesSubTot)			
			oPrint:Line( lin,150,lin+57,150)
			oPrint:Say(lin+15,nColuna,MemoLine(cDesSubTot,74,1), If(aSubTot[N_IDENTIFI] $ "3469", oCouNew08N, oFont08))
			For nPosCol := 1 To Len(aPosCol)
				oPrint:Line(lin,aPosCol[nPosCol],lin+50,aPosCol[nPosCol])					
				If nPosCol == 1
					nSubTot := aSubTot[N_MOVIMENTO]
				ElseIf nPosCol == 2
					nSubTot := aSubTot[N_MOVPERANT]
				ElseIf nPosCol == 3
					nSubTot := aSubTot[N_MOVIMENTO]-aSubTot[N_MOVPERANT]
				EndIf
				
				ValorCTB(nSubTot,lin+15,aPosCol[nPosCol],IIf(cTpValor $ "D",20,23),nDecimais,.T.,cPicture,aSubTot[N_NORMAL],aSubTot[N_CONTA],.T.,oPrint,cTpValor,IIf(aSubTot[N_IDENTIFI] $ "4","1",aSubTot[N_IDENTIFI]))								
			Next aPosCol
			oPrint:Line(lin,nTamLin,lin+57,nTamLin)
			lin += 57			
		EndIf

		//Linha vertical
		If !Empty(cArqTmp->SUPERIOR) 
			oPrint:Line( lin,150,lin+50,150)
		EndIf
		
		//Negrito caso Sub-Total/Total/Separador (caso tenha descricao) e Igual (Totalizador)
		nColuna := 180+(15*cArqTmp->COLUNA )
		cDescCont := Posicione("CTS",2,xFilial("CTS")+cCodVis+cArqTmp->CONTA,"CTS_DETHCG")
		cDescCont := AllTrim(cArqTmp->DESCCTA)+Rtrim(cDescCont)
		cDescCont := Space(cArqTmp->NIVEL) + cDescCont
		nLinha:= MLCount(cDescCont,74)

		If Empty(cArqTmp->SUPERIOR)
			oPrint:Line(lin,150,lin,nTamLin)										

			If AllTrim(cArqTmp->CONTA) == "1"
				cDesSubTot := STR0023 //"FLUXO DE CAIXA LÍQUIDO DAS OPERAÇÕES"
			ElseIf AllTrim(cArqTmp->CONTA) == "2"
				cDesSubTot := STR0024 //"FLUXO DE CAIXA LÍQUIDO DAS ATIVIDADES DE INVESTIMENTO"
			ElseIf AllTrim(cArqTmp->CONTA) == "3"
				cDesSubTot := STR0025 //"FLUXO DE CAIXA LÍQUIDO DAS ATIVIDADES DE FINANCIAMENTO"
			EndIf

			aSubTot := {    cArqTmp->CONTA,;	//01
							cArqTmp->DESCCTA,;	//02
							cArqTmp->COLUNA,;	//03
							cArqTmp->IDENTIFI,;	//04
							cArqTmp->TIPOCONTA,;//05
							cArqTmp->SUPERIOR,;	//06
							cArqTmp->TOTVIS,;	//07
							cArqTmp->NORMAL,;	//08
							cArqTmp->SALDOANT,; //09
							cArqTmp->SALDOATU,;	//10
							cArqTmp->NIVEL }	//11			
		EndIf

		oPrint:Say(lin+15,nColuna,MemoLine(cDescCont,74,1), If(cArqTmp->IDENTIFI $ "3469" .Or. Empty(cArqTmp->SUPERIOR), oCouNew08N, oFont08))
		//oPrint:Say(lin+15,nColuna,cArqTmp->(DESCCTA), If(cArqTmp->(IDENTIFI) $ "3469", oCouNew08N, oFont08))

		For nPosCol := 1 To Len(aPosCol)
			If !Empty(cArqTmp->SUPERIOR) 
				oPrint:Line(lin,aPosCol[nPosCol],lin+50,aPosCol[nPosCol])	// Separador vertical
			EndIf
			Do Case
				Case nPosCol = 1
					nSaldo		:= cArqTmp->SALDOATU
					
					If cArqTmp->TIPOCONTA == "1" .AND. Empty( cArqTmp->SUPERIOR ) .AND. cArqTmp->TOTVIS == "1"
						nSaldoAtu 	+= nSaldo
					EndIf					
				Case nPosCol = 2					
					nSaldo		:= cArqTmp->SALDOANT
					
					If cArqTmp->TIPOCONTA == "1" .AND. Empty( cArqTmp->SUPERIOR ) .AND. cArqTmp->TOTVIS == "1"
						nSaldoAnt 	+= nSaldo
					EndIf
				Case nPosCol = 3
					nSaldo		:= GetVarEnt(cArqTmp->CONTA,cCodVis,cArqTmp->ORDEM)//cArqTmp->(SALDOATU-SALDOANT)
					
					If cArqTmp->TIPOCONTA == "1" .AND. Empty( cArqTmp->SUPERIOR ) .AND. cArqTmp->TOTVIS == "1"
						nSaldoVar 	+= nSaldo
					EndIf
			EndCase			

	   		If cArqTmp->IDENTIFI < "5" .And. !Empty(cArqTmp->SUPERIOR)
				ValorCTB(nSaldo,lin+15,aPosCol[nPosCol],IIf(cTpValor $ "D",20,23),nDecimais,.T.,cPicture,cArqTmp->NORMAL,cArqTmp->CONTA,.T.,oPrint,cTpValor,IIf(cArqTmp->IDENTIFI $ "4","1",cArqTmp->IDENTIFI))
			EndIf

			//Incrementa Totalizador
			If cArqTmp->TIPOCONTA == "2"				
				aTotais[nPosCol] += nSaldo				
			EndIf
		Next

		//Separador vertical
		If !Empty(cArqTmp->SUPERIOR) 
			oPrint:Line(lin,nTamLin,lin+50,nTamLin)
		EndIf
		
		//Impressão da continuacao da descricao caso exista
		For nBegin := 2 To nLinha
			lin +=47			
			oPrint:Line( lin,150,lin+50,150)	// Separador vertical
			
			oPrint:Say(lin+15,nColuna,MemoLine(cDescCont,74,nBegin), If(cArqTmp->IDENTIFI $ "3469", oCouNew08N, oFont08))
			For nPosCol := 1 To Len(aPosCol)
				oPrint:Line(lin,aPosCol[nPosCol],lin+50,aPosCol[nPosCol])	// Separador vertical
			Next nPosCol
			oPrint:Line(lin,nTamLin,lin+50,nTamLin) ////Separador vertical
		Next nBegin
		
		lin +=47
		
		If Empty(cArqTmp->SUPERIOR)
			oPrint:Line(lin,150,lin,nTamLin)
		EndIf
	Endif

	nTraco := lin + 1
	cArqTmp->(DbSkip())
EndDo

oPrint:Line( lin,150,lin+57,150)
oPrint:Say(lin+15,nColuna,MemoLine(cDesSubTot,74,1), If(aSubTot[N_IDENTIFI] $ "3469", oCouNew08N, oFont08))
For nPosCol := 1 To Len(aPosCol)
	oPrint:Line(lin,aPosCol[nPosCol],lin+50,aPosCol[nPosCol])					
	If nPosCol == 1
		nSubTot := aSubTot[N_MOVIMENTO]
	ElseIf nPosCol == 2
		nSubTot := aSubTot[N_MOVPERANT]
	ElseIf nPosCol == 3
		nSubTot := aSubTot[N_MOVIMENTO]-aSubTot[N_MOVPERANT]
	EndIf
	
	ValorCTB(nSubTot,lin+15,aPosCol[nPosCol],IIf(cTpValor $ "D",20,23),nDecimais,.T.,cPicture,aSubTot[N_NORMAL],aSubTot[N_CONTA],.T.,oPrint,cTpValor,IIf(aSubTot[N_IDENTIFI] $ "4","1",aSubTot[N_IDENTIFI]))								
Next aPosCol
oPrint:Line(lin,nTamLin,lin+57,nTamLin)
lin += 57			


//Linha horizontal
oPrint:Line(lin,150,lin,nTamLin)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³preenche o saldo dos exercicios na caixa de atividades³
//³operacionais usado com o metodo indireto              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR18 == 2
	If MV_PAR19 == 2
		nSaldoAtu := MV_PAR20
		nSaldoAnt := MV_PAR21
		nSaldoVar := nSaldoAtu - nSaldoAnt
	EndIf

	If MV_PAR06 == 1
		ValorCTB(nSaldoAnt, 379,  770,IIf(cTpValor $ "D",20,IIF(cTpValor $ "P", 23, 21)),nDecimais,.T.,cPicture,,,.T.,oPrint,cTpValor,"1")
		ValorCTB(nSaldoAtu, 379, 1350,IIf(cTpValor $ "D",20,IIF(cTpValor $ "P", 23, 21)),nDecimais,.T.,cPicture,,,.T.,oPrint,cTpValor,"1")
		ValorCTB(nSaldoVar, 379, 1918,IIf(cTpValor $ "D",22,23),nDecimais,.T.,cPicture,,,.T.,oPrint,cTpValor,"1")
	Else
		ValorCTB(nSaldoAnt, 379, 1350,IIf(cTpValor $ "D",20,IIF(cTpValor $ "P", 23, 21)),nDecimais,.T.,cPicture,,,.T.,oPrint,cTpValor,"1")
		ValorCTB(nSaldoAtu, 379, 1918,IIf(cTpValor $ "D",20,IIF(cTpValor $ "P", 23, 21)),nDecimais,.T.,cPicture,,,.T.,oPrint,cTpValor,"1")
	EndIf
EndIf

lin += 20 

//Totalizador Fluxo de Caixa  
If lin > 3000
	If !lFirstPage
		oPrint:Line( ntraco,150,ntraco,nTamLin ) //horizontal
	EndIf
	i++
	oPrint:EndPage() 	 							//Finaliza a pagina
	CtbCbcDem(oPrint,cTitulo,lLandScape)			//Funcao que monta o cabecalho padrao
	Ctr560Esp(oPrint, cDescMoeda,aPosCol,nTamLin,lin)
	lin := 304
	lFirstPage := .F.
EndIf

//Inicializa Totalizador Caixa Inicial periodo anterior
cSelFil := IIf(!Empty(cFiliais),cFiliais,cFilAnt)

ImpQuadTot(oPrint,@lin,nTamLin,nColuna,aPosCol,aTotais,cMoedaDesc,cSaldos,cSelFil,cTpValor,nDecimais,cPicture)

lin += 10             

If lImpTrmAux
	If lin > 3000
		If !lFirstPage
			oPrint:Line( ntraco,150,ntraco,nTamLin )   	// horizontal
		EndIf
		i++
		oPrint:EndPage() 	 								// Finaliza a pagina
		CtbCbcDem(oPrint,cTitulo,lLandScape)					// Funcao que monta o cabecalho padrao
		Ctr560Esp(oPrint, cDescMoeda,aPosCol,nTamLin,lin)
		lin := 304
		lFirstPage := .F.
	Endif

	cArqTRM 	   := mv_par11
	aVariaveis  := {}

	// Buscando os parâmetros do relatorio (a partir do SX1) para serem impressaos do Termo (arquivos *.TRM)
	SX1->(DbSeek(cPerg+"01"))
	While AllTrim(SX1->X1_GRUPO) == cPerg
		AADD(aVariaveis,{AllTrim(Upper(SX1->X1_VAR01)),&(SX1->X1_VAR01)})
		SX1->(DbSkip())
	End

	If !File(cArqTRM)
		aSavSet:=__SetSets()
		cArqTRM := CFGX024( cArqTRM, STR0011 ) // "Responsáveis..."
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqTRM#NIL
		ImpTerm(cArqTRM,aVariaveis,"",.T.,{oPrint,oFont08,Lin})
	Endif
Endif

DbSelectArea( "cArqTmp" )
Set Filter To
dbCloseArea()
 
If Select( "cArqTmp" ) == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ fTrataSlds³ Autor³ Felipe Aurelio de Melo³ Data ³ 14.10.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tratamento do retorno do parametro                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CTBR560R4                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fTrataSlds()

Local cRet := ""

If MV_PAR15 = 1
	cRet := MV_PAR16
Else
	cRet := MV_PAR17
EndIf

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Ctr560Ind ³ Autor³ Totvs                 ³ Data ³ 11/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ apresenta o quadro de atividades operacionais quando usar  ³±±
±±³          ³ metodo indireto.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CTBR560R4                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctr560Ind( oPrint, lin, nTamLin )
	Local aPosInd	:= IIf( MV_PAR06 == 1, { 625, 1190, 1730 }, { 1190, 1730 } )
	Local nCol		:= 0

	// Cabecalho
	oPrint:Line(lin,150,lin,nTamLin)
	oPrint:Line(lin,150,lin+50,150)

	If MV_PAR06 == 1
		oPrint:Say(lin+15,  860, STR0014, 	oCouNew08N )
		oPrint:Say(lin+15, 1440, STR0015, 	oCouNew08N )
		oPrint:Say(lin+15, 2005, STR0016,	oCouNew08N )
	Else
		oPrint:Say(lin+15, 1410, STR0014, 	oCouNew08N )
		oPrint:Say(lin+15, 2025, STR0015, 	oCouNew08N )
	EndIf

	// Separador vertical
	For nCol := 1 To Len( aPosInd )
		oPrint:Line( lin, aPosInd[nCol], lin+50, aPosInd[nCol] )
	Next

	oPrint:Line( lin, nTamLin, lin+50, nTamLin )
	lin += 47
	

// ORIZIO criar arquivo .CH com os textos usados no relatorio

	// Linha 1
	oPrint:Line(lin,150,lin,nTamLin)
	oPrint:Line(lin,150,lin+50,150)
	oPrint:Say(lin+15,  180, STR0017, oCouNew08N )

	// Separador vertical
	For nCol := 1 To Len( aPosInd )
		oPrint:Line( lin, aPosInd[nCol], lin+50, aPosInd[nCol] )
	Next

	oPrint:Line(lin,nTamLin,lin+50,nTamLin)
	lin += 47

	// Linha 2
	oPrint:Line(lin,150,lin,nTamLin)
	oPrint:Line(lin,150,lin+50,150)
	oPrint:Say(lin+15,  180, STR0018, oCouNew08N )
                                 
	// Separador vertical
	For nCol := 1 To Len( aPosInd )
		oPrint:Line( lin, aPosInd[nCol], lin+50, aPosInd[nCol] )
	Next

	oPrint:Line(lin,nTamLin,lin+50,nTamLin)
	lin += 47

	oPrint:Line(lin,150,lin,nTamLin)
	lin += 20

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CtbCxaIni
Realiza busca dos saldos iniciais para a conta Inicial de Caixa Periodo
Anterior - Conta sintetica fixa 111

@author Totvs
   
@version P12
@since   15/06/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function CtbCxaIni(cContaCxa,dFinal,cMoedaDesc,cSaldos,cSelFil)

Local cQuery 	 := ""
Local cAliasQry  := GetNextAlias()
Local nSaldoIni  := 0

cSelFil := StrTran(cSelFil, ",", ";")

//Busca contas filho
cQuery 	:= " SELECT CT1_CONTA "
cQuery 	+= " 	FROM " + RetSqlName("CT1") 
cQuery 	+= " 	WHERE CT1_FILIAL = '" + XFilial("CT1") + "'"
cQuery 	+= " 	AND SUBSTRING(CT1_CTASUP,1,3) = '" + cContaCxa + "'"
cQuery 	+= " 	AND CT1_CLASSE = '2'"
cQuery 	+= " 	AND D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.F.)

//Incrementa saldo inicial
While (cAliasQry)->(!EOF())
	nSaldoIni += SaldoConta((cAliasQry)->CT1_CONTA,dFinal,cMoedaDesc,cSaldos,,,,cSelFil) 
	(cAliasQry)->(dbSkip())		
EndDo

(cAliasQry)->(dbCloseArea())

Return Abs(nSaldoIni)

//-------------------------------------------------------------------
/*{Protheus.doc} ImpQuadTot
Faz a impressão do quadro totalizador

@author Totvs
   
@version P12
@since   21/12/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function ImpQuadTot(oPrint,lin,nTamLin,nColuna,aPosCol,aTotais,cMoedaDesc,cSaldos,cSelFil,cTpValor,nDecimais,cPicture)
Local nVlCxaAnt := 0
Local nVlCxaAtu := 0
Local nTotAnt   := 0
Local nTotAtu   := 0
Local cContaCxa	:= "111"
Local nX		:= 0
Local nPosCol 	:= 0 
Local dDatRef	:= 0

For nX := 1 to 2
	If nX == 1 
		If mv_par09==1 
			dDatRef := MonthSub(dFinalA,12)
		Else
			dDatRef := FirstDate(dFinalA)
		EndIf
		nVlCxaAnt := CtbCxaIni(cContaCxa,dDatRef,cMoedaDesc,cSaldos,cSelFil)
	Else
		dDatRef := dFinalA+1		
		nVlCxaAtu := CtbCxaIni(cContaCxa,dDatRef,cMoedaDesc,cSaldos,cSelFil)
	EndIf
Next nI

oPrint:Line(lin,150,lin,nTamLin)

For nX := 1 To 3 // 3 linhas
	oPrint:Line( lin,150,lin+50,150) //Separador vertical

	For nPosCol := 1 To Len(aPosCol)
		oPrint:Line(lin,aPosCol[nPosCol],lin+50,aPosCol[nPosCol]) //Separador vertical
		
		If nX == 1
			oPrint:Say(lin+15, nColuna, STR0019, oCouNew08N) //"GERACAO LIQUIDA DE CAIXA E EQUIVALENTE DE CAIXA"
			If nPosCol == 1
				nTotAtu := Abs(aTotais[nPosCol])			
				ValorCTB(nTotAtu,lin+15,aPosCol[nPosCol],IIf(cTpValor $ "D", 20, 23), nDecimais,.T.,cPicture,,, .T., oPrint,,,,.F.)			
			ElseIf nPosCol == 2
				nTotAnt := Abs(aTotais[nPosCol])			
				ValorCTB(nTotAnt,lin+15,aPosCol[nPosCol],IIf(cTpValor $ "D", 20, 23), nDecimais,.T.,cPicture,,, .T., oPrint,,,,.F.)			
			Else
				ValorCTB(Abs(aTotais[nPosCol]),lin+15,aPosCol[nPosCol],IIf(cTpValor $ "D", 20, 23), nDecimais,.T.,cPicture,,, .T., oPrint,,,,.F.)			
			EndIf
		ElseIf nX == 2
			oPrint:Say(lin+15, nColuna, STR0020, oFont08) //"CAIXA E EQUIVALENTE DE CAIXA INICIAL"
			
			If nPosCol == 1						
				ValorCTB(nVlCxaAtu,lin+15,aPosCol[nPosCol],IIf(cTpValor $ "D", 20, 23), nDecimais,.T.,cPicture,,, .T., oPrint,,,,.F.)
			ElseIf nPosCol == 2
				ValorCTB(nVlCxaAnt,lin+15,aPosCol[nPosCol],IIf(cTpValor $ "D", 20, 23), nDecimais,.T.,cPicture,,, .T., oPrint,,,,.F.)
			Else
				ValorCTB(nVlCxaAtu-nVlCxaAnt,lin+15,aPosCol[nPosCol],IIf(cTpValor $ "D", 20, 23), nDecimais,.T.,cPicture,,, .T., oPrint,,,,.F.)
			EndIf					
		Else
			oPrint:Say(lin+15, nColuna, STR0021, oFont08) //"CAIXA E EQUIVALENTE DE CAIXA FINAL"
			
			If nPosCol == 1	
				ValorCTB(nVlCxaAtu+nTotAtu,lin+15,aPosCol[nPosCol],IIf(cTpValor $ "D", 20, 23), nDecimais,.T.,cPicture,,, .T., oPrint,,,,.F.)
			ElseIf nPosCol == 2
				ValorCTB(nVlCxaAnt+nTotAnt,lin+15,aPosCol[nPosCol],IIf(cTpValor $ "D", 20, 23), nDecimais,.T.,cPicture,,, .T., oPrint,,,,.F.)
			Else
				ValorCTB((nVlCxaAtu+nTotAtu)-(nVlCxaAnt+nTotAnt),lin+15,aPosCol[nPosCol],IIf(cTpValor $ "D", 20, 23), nDecimais,.T.,cPicture,,, .T., oPrint,,,,.F.)
			EndIf
		EndIf
	Next nPosCol

	oPrint:Line(lin,nTamLin,lin+50,nTamLin) //Separador vertical
	lin += 47
Next nI

oPrint:Line(lin,150,lin,nTamLin)

Return 
