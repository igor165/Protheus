#Include "ctbr570.ch"
#Include "protheus.ch"

//--------------------------------------------------------------------------------------------------
//Criar no CTB.PRW a criacao da consulta padrao (SXB) chamada SX5SL
//--------------------------------------------------------------------------------------------------
//SX5SL - 1 - 01 - RE - SELECAO SALDOS CTB - SELECAO SALDOS CTB - SELECAO SALDOS CTB - SX5
//SX5SL - 2 - 01 - 01 -                    -                    -                    - CTR560SX5(1)
//SX5SL - 5 - 01 -    -                    -                    -                    - cRetSX5SL
//--------------------------------------------------------------------------------------------------

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ�
���Fun��o	 � Ctbr570	� Autor � Felipe Aurelio de Melo � Data � 25.09.08 ��
��������������������������������������������������������������������������Ĵ�
���Descri��o � DEMONSTRACAO DO VALOR ADICIONADO                            ��
��������������������������������������������������������������������������Ĵ�
���Retorno	 � Nenhum                                                      ��
��������������������������������������������������������������������������Ĵ�
���Parametros� Nenhum                                                      ��
���������������������������������������������������������������������������ٱ
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CtbR570()

Local lRet        := .T.
Private cRetSX5SL := ""
Private cPerg     := "CTR570"
Private NomeProg  := "CTBR570"
Private wnRel     := "CTBR570"
Private dFinal    := StoD("")
Private dFinalA   := StoD("")
Private aSetOfBook:= {}
Private aCtbMoeda := {} 
Private aSelFil	:= {}
Private cTitulo   := STR0001 //"DEMONSTRACAO DO VALOR ADICIONADO"


//chama a tela de perguntas
If lRet .And. !Pergunte(cPerg,.T.)
	lRet := .F.
Else
	aSetOfBook:= CTBSetOf(mv_par02)
	aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
EndIf

//faz a validacao do livro
If lRet .And. !VdSetOfBook(mv_par02,.T.)
	lRet := .F.
EndIf

// Faz a validacao das filiais
If lRet .And. mv_par22 == 1 .And. Len( aSelFil ) <= 0 
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		lRet := .F.
	EndIf 
EndIf 

// verifica existencia da consulta padrao SX5SL
If SXB->(!DbSeek("SX5SL"))
	Help(" ",1,"HELP","",STR0002,3,1)
	lRet := .F.
EndIf

If lRet .And. Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
	lRet := .F.
Endif

//Se passou pelas perguntas e validacoes chama funcao de impressao do relatorio
If lRet
	CTBR570R3()
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR570R3 � Autor� Felipe Aurelio de Melo� Data � 25.09.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � DEMONSTRACAO DO VALOR ADICIONADO - R3                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR570R3                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function CTBR570R3()

Local cDescMoeda  := AllTrim(aCtbMoeda[3])
Local lMovPeriodo := mv_par06 == 1
local aArea       := GetArea()
Local cDesc       := ""
Private m_pag     := mv_par07 // numera��o da pagina

cDesc += OemToAnsi( STR0003 )  			//"Este programa ir� imprimir a Demonstra��o do fluxo de caixa, "
cDesc += OemToAnsi( STR0004 )           //"de acordo com os par�metros informados pelo usu�rio."
cTitulo := If(!Empty(aSetOfBook[10]),aSetOfBook[10],cTitulo)                        //"Titulo definido SetOfBook"

If (mv_par21 == 1)
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
		MsgInfo( STR0005, STR0006 )//"� necess�rio informar a data de refer�ncia !"#"Parametro Considera igual a Periodo."
		Return .F.
	Endif
	dFinal := mv_par08
	
	CTG->(dbSetOrder(1))
	CTG->(DbSeek(xFilial("CTG")+mv_par01))
	While CTG->CTG_FILIAL == xFilial("CTG") .And. CTG->CTG_CALEND == mv_par01
		If dFinal >= CTG->CTG_DTINI .and. dFinal <= CTG->CTG_DTFIM
			dFinalA		:= CTG->CTG_DTINI
			If lMovPeriodo
				dFinalA		:= dFinalA - 1
			EndIf
			Exit
		Endif
		CTG->(DbSkip())
	EndDo
	
	If Empty(dFinalA)
		MsgInfo( STR0007, STR0008 )//"Data fora do calend�rio !"#"Data de refer�ncia."
		Return .F.
	Endif
EndIf

MsgRun(	STR0009,"",{|| CursorWait(), Ctr500Cfg(@cTitulo, "Ctr570Det", STR0001, .F.) ,CursorArrow()}) //"Gerando relatorio, aguarde..."##"DEMONSTRACAO DO VALOR ADICONADO"

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Ctr570Det � Autor � Felipe Aurelio de Melo� Data � 25.09.08 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Detalhe do Relatorio                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ctr570Det(ExpO1,ExpN1)                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          � ExpN1 = Contador de paginas                                ���
���          � ParC1 = Titulo do relatorio                                ���
���          � ParC2 = Titulo da caixa do processo                        ���
���          � ParL1 = Indica se imprime em Paisagem (.T.) ou Retrato .F. ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctr570Det(oPrint,i,cTitulo,cProcesso,lLandScape)

Local cArqTmp
Local nTraco      := 0
Local nColuna		:= 0
Local cCodVis     := Posicione("CTN",1, xFilial("CTN")+MV_PAR02,"CTN_PLAGER")
Local cDescCont   := ""
Local nBegin		:= 0
Local nLinha		:= 0
Local nPosCol		:= 0
Local lFirstPage	:= .T.
Local lin 			:= 3001
Local nTamLin		:= 2349
Local lMovPeriodo := mv_par06 == 1
Local cTpValor		:= GetMV("MV_TPVALOR")
Local cDescMoeda  := AllTrim(aCtbMoeda[3])
Local lImpTrmAux	:= Iif(mv_par10 == 1,.T.,.F.)
Local nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)
Local cMoedaDesc  := IIf( Empty(mv_par13),mv_par03,mv_par13)
Local cPicture 	:= IIf(!Empty(aSetOfBook[4]) .And. Len(Trans(0, aSetOfBook[4])) > 17,"",aSetOfBook[4])
Local aPosCol		:= { 1740, 2045 }
Local lVlrZerado  := IIf(mv_par12==1,.T.,.F.)
Local cSaldos     := fTrataSlds()
Local nSalVlAdic	:= 0										// Saldo do valor adicionado
Local cCtaSup		:= ""
Local nX					:= 0
Local cFiliais			:= ""
Local lCharSinal	:= .F.

//�������������������������������������������������������Ŀ
//�Verifica se deve imprimir as colunas com os percentuais�
//���������������������������������������������������������
If MV_PAR17 == 1
	aPosCol		:= { 1040, 1390, 1740, 2045 }
EndIf

//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao                      �
//����������������������������������������������������������������
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
							/*62*/mv_par14=1);
			},STR0010,cProcesso) //"Criando Arquivo Temporario..."

dbSelectArea("cArqTmp")
dbGoTop()

//Limitado a exibi��o do titulo em 85 caracteres para que n�o estoure na exibi��o das filiais
If Len(aSelFil) > 0            
	For nX := 1 to Len(aSelFil)
		If Len(cTitulo + STR0013 + cFiliais) <= 85
			cFiliais += aSelFil[nX] + ","	
		endIf
	Next nX
	cFiliais := Left(cFiliais,Len(cFiliais)-1)
	cTitulo += STR0013 + cFiliais	+ "..."
EndIf

While cArqTmp->(!Eof())
	If lin > 3000
		If !lFirstPage
			oPrint:Line( ntraco,150,ntraco,nTamLin )//Horizontal
		EndIf
		i++
		oPrint:EndPage()//Finaliza a pagina
		CtbCbcDem(oPrint,cTitulo,lLandScape)//Funcao que monta o cabecalho padrao
		Ctr570Esp(oPrint,cDescMoeda,aPosCol,nTamLin)
		lin := 304
		lFirstPage := .F.
	EndIf

	//������������������������������������������������������������Ŀ
	//�indica se a entidade gerencial sera impressa/visualizada em �
	//�um relatorio ou consulta apos o processamento da visao      �
	//��������������������������������������������������������������
	If cArqTmp->VISENT == "2"
		cArqTmp->( DbSkip() )
		Loop
	EndIf
	
	If AllTrim(cArqTmp->DESCCTA) == "-"
		// Linha horizontal
		oPrint:Line(lin,150,lin,nTamLin)
	Else
		//Linha vertical
		oPrint:Line( lin,150,lin+50,150)
		
		//Negrito caso Sub-Total/Total/Separador (caso tenha descricao) e Igual (Totalizador)
		nColuna := 180+(15*cArqTmp->COLUNA)
		cDescCont := Posicione("CTS",2,xFilial("CTS")+cCodVis+cArqTmp->(CONTA),"CTS_DETHCG")
		cDescCont := AllTrim(cArqTmp->DESCCTA)+Rtrim(cDescCont)
		nLinha:= MLCount(cDescCont,74)

		oPrint:Say(lin+15,nColuna,MemoLine(cDescCont,74,1), If(cArqTmp->IDENTIFI $ "3469", oCouNew08N, oFont08))
		//oPrint:Say(lin+15,nColuna,cArqTmp->DESCCTA, If(cArqTmp->IDENTIFI $ "3469", oCouNew08N, oFont08))

		For nPosCol := 1 To Len(aPosCol)
			oPrint:Line(lin,aPosCol[nPosCol],lin+50,aPosCol[nPosCol])	 
			
			If MV_PAR17 == 1
				Do Case
					Case nPosCol = 1
						nSaldo := IIF(mv_par06 == 1, cArqTmp->SALDOATU - cArqTmp->SALDOANT, cArqTmp->SALDOATU )
	
					Case nPosCol = 2 // percentual
						nSaldo :=  IIF(mv_par06 == 1, cArqTmp->SALDOATU - cArqTmp->SALDOANT, cArqTmp->SALDOATU ) * 100 / nSalVlAdic
	
					Case nPosCol = 3
						nSaldo := cArqTmp->SALDOANT
	
					Case nPosCol = 4 // percentual
						nSaldo :=  cArqTmp->SALDOANT * 100 / nSalVlAdic
				EndCase

				If ( nPosCol == 1 .OR. nPosCol == 3 ) .AND. cArqTmp->CONTA == MV_PAR18 .AND. nSalVlAdic == 0
					nSalVlAdic 	:= nSaldo
					cCtaSup		:= cArqTmp->CONTA
				EndIf

				If ( nPosCol == 2 .OR. nPosCol == 4 ) 
					//�������������������������������������������������������Ŀ
					//�TITULO:                                                �
					//�indica que todas as entidades com ordem de impressao   �
					//�superior a entidade especificada no parametro estao    �
					//�contidas no segmento "Distribuicao do valor adicionado"�
					//�                                                       �
					//�TOTAL:                                                 �
					//�indica que todas as entidades que tem como     		  �
					//�superior a entidade especificada no parametro estao    �
					//�contidas no segmento "Distribuicao do valor adicionado"�
					//���������������������������������������������������������
					If MV_PAR20 == 1						// Titulo
						If cArqTmp->CONTA < MV_PAR19
							nSaldo := 0
						EndIf
					ElseIf MV_PAR20 == 2					// Total
						If cCtaSup <> MV_PAR18
							nSaldo := 0
						EndIf
					EndIf

					// Imprime o percentual
					ValorCTB(nSaldo,lin+15,aPosCol[nPosCol],15,nDecimais,.F.,cPicture,cArqTmp->NORMAL,cArqTmp->CONTA,.T.,oPrint,cTpValor,IIf(cArqTmp->IDENTIFI $ "4","1",cArqTmp->IDENTIFI),,,,lCharSinal)
				Else
		    		If cArqTmp->IDENTIFI < "5"
						ValorCTB(nSaldo,lin+15,aPosCol[nPosCol],15,nDecimais,.T.,cPicture,cArqTmp->NORMAL,cArqTmp->CONTA,.T.,oPrint,cTpValor,IIf(cArqTmp->IDENTIFI $ "4","1",cArqTmp->IDENTIFI),,,,lCharSinal)
					EndIf
				EndIf
			Else
				Do Case
					Case nPosCol = 1
						nSaldo := IIF(mv_par06 == 1, cArqTmp->SALDOATU - cArqTmp->SALDOANT, cArqTmp->SALDOATU )
					Case nPosCol = 2
						nSaldo := cArqTmp->SALDOANT
				EndCase

	    		If cArqTmp->IDENTIFI < "5"
					ValorCTB(nSaldo,lin+15,aPosCol[nPosCol],15,nDecimais,.T.,cPicture,cArqTmp->NORMAL,cArqTmp->CONTA,.T.,oPrint,cTpValor,IIf(cArqTmp->IDENTIFI $ "4","1",cArqTmp->IDENTIFI),,,,lCharSinal)
				EndIf
			EndIf
		Next
		
		//Separador vertical
		oPrint:Line(lin,nTamLin,lin+50,nTamLin)
		
		//Impress�o da continuacao da descricao caso exista
		For nBegin := 2 To nLinha
			lin +=47
			oPrint:Line( lin,150,lin+50,150)	 
			oPrint:Say(lin+15,nColuna,MemoLine(cDescCont,74,nBegin), If(cArqTmp->IDENTIFI $ "3469", oCouNew08N, oFont08))
			For nPosCol := 1 To Len(aPosCol)
				oPrint:Line(lin,aPosCol[nPosCol],lin+50,aPosCol[nPosCol])	 
			Next nPosCol
			oPrint:Line(lin,nTamLin,lin+50,nTamLin) ////Separador vertical
		Next nBegin
		
		lin +=47
	Endif
	
	nTraco := lin + 1
	cArqTmp->(DbSkip())
EndDo
//Linha horizontal
oPrint:Line(lin,150,lin,nTamLin)

//������������������������������Ŀ
//�apresenta a linha totalizadora�
//��������������������������������
If MV_PAR17 == 1 .AND. MV_PAR20 == 1
	oPrint:Line( lin,150,lin+50,150)	 
	oPrint:Say( lin+15, nColuna, STR0012, oCouNew08N )
	For nPosCol := 1 To Len(aPosCol)
		oPrint:Line(lin,aPosCol[nPosCol],lin+50,aPosCol[nPosCol])	 
	Next nPosCol
	oPrint:Line(lin,nTamLin,lin+50,nTamLin) ////Separador vertical

	lin += 48

	//Linha horizontal
	oPrint:Line(lin,150,lin,nTamLin)
EndIf

lin += 10             

If lImpTrmAux
	If lin > 3000
		If !lFirstPage
			oPrint:Line( ntraco,150,ntraco,nTamLin )   	// horizontal
		EndIf
		i++
		oPrint:EndPage() 	 								// Finaliza a pagina
		CtbCbcDem(oPrint,cTitulo,lLandScape)					// Funcao que monta o cabecalho padrao
		Ctr570Esp(oPrint, cDescMoeda,aPosCol,nTamLin)
		lin := 304
		lFirstPage := .F.
	Endif

	cArqTRM 	   := mv_par11
	aVariaveis  := {}

	// Buscando os par�metros do relatorio (a partir do SX1) para serem impressaos do Termo (arquivos *.TRM)
	SX1->(DbSeek(cPerg+"01"))
	While AllTrim(SX1->X1_GRUPO) == cPerg
		AADD(aVariaveis,{AllTrim(Upper(SX1->X1_VAR01)),&(SX1->X1_VAR01)})
		SX1->(DbSkip())
	End

	If !File(cArqTRM)
		aSavSet:=__SetSets()
		cArqTRM := CFGX024(cArqTRM,STR0011) // "Respons�veis..."
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqTRM#NIL
		ImpTerm(cArqTRM,aVariaveis,"",.T.,{oPrint,oFont08,Lin})
	Endif
Endif

DbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
 
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �CTR570ESP � Autor �Felipe Aurelio de Melo � Data � 25.09.08 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Cabecalho Especifico do relatorio CTBR041.                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �CTR570ESP(ParO1,ParC1)                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
���          � ExpC1 = Descricao da moeda sendo impressa                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTR570Esp(oPrint,cDescMoeda,aPosCol,nTamLin)

Local nPosCol

// Linha vertical
oPrint:Line(250,150,300,150)

//Primeira coluna
oPrint:Say(260,195,"(Em " + cDescMoeda + ")",oArial10)

For nPosCol := 1 To Len(aPosCol)
	If MV_PAR17 == 1
		Do Case
			//Segunda coluna
			Case nPosCol = 1
				oPrint:Say(260,aPosCol[nPosCol] ,Padl(DtoC(dFinal),23),oArial10)
	
			//Terceira coluna (%)
			Case nPosCol = 2
				oPrint:Say(260,aPosCol[nPosCol] ,Padl("%",25),oArial10)
	
			//Quarta coluna
			Case nPosCol = 3
				oPrint:Say(260,aPosCol[nPosCol] ,Padl(DtoC(dFinalA),23),oArial10)
	
			//Quinta coluna (%)
			Case nPosCol = 4
				oPrint:Say(260,aPosCol[nPosCol] ,Padl("%",25),oArial10)
		EndCase
	Else
		Do Case
			Case nPosCol = 1
				oPrint:Say(260,aPosCol[nPosCol] ,Padl(DtoC(dFinal),23),oArial10)
			Case nPosCol = 2
				oPrint:Say(260,aPosCol[nPosCol] ,Padl(DtoC(dFinalA),23),oArial10)
		EndCase
	EndIf
Next

// Linha vertical
oPrint:Line(250,nTamLin,300,nTamLin)

// Linha horizontal
oPrint:Line(300,150,300,nTamLin)

Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � fTrataSlds� Autor� Felipe Aurelio de Melo� Data � 14.10.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tratamento do retorno do parametro                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR560R4                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function fTrataSlds()

Local cRet := ""

If MV_PAR14 = 1
	cRet := MV_PAR15
Else
	cRet := MV_PAR16
EndIf

Return(cRet)
