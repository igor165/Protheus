#INCLUDE "CDAA030.ch"
#INCLUDE "Protheus.CH"

Static lFWCodFil := FindFunction("FWCodFil")
/*эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё CDAA030  Ё Autor Ё Cristiano G. Cunha    Ё Data Ё 04/07/02 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Programa de Calculo de Direito Autoral - Royalty           Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё SIGACDA - Controle de Direitos Autorais                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function CDAA030

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Variaveis                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

Local nOpca := 0
Local cCadastro := STR0001 //"Calculo do D.A."
Local oDlg

PRIVATE aInconsist := {}
PRIVATE lLicitaca  := .F.
Private nQtdAcum1 := 0

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Salva a Interface                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SaveInter()

If AMIIn(45)

	nOpca := 2           
	Pergunte("CDA030",.F.)
	DEFINE MSDIALOG oDlg FROM 130,111 TO 350,600 TITLE cCadastro PIXEL

		@ 10 ,4   TO 73 ,239 LABEL '' OF oDlg PIXEL
		@ 23,15 SAY "  "+STR0014+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0015+DTOC(GetMV("MV_CDAFECH")) SIZE 210,80 OF oDlg PIXEL  //"Este programa tem como objetivo calcular os valores a serem pagos aos proprietarios de direito de acordo com os as regras estabelecidas no contrato do direito autoral. " // "Data do ultimo fechamento :"

		DEFINE SBUTTON FROM 92 ,136 TYPE 5 ACTION Pergunte("CDA030",.T.) ENABLE OF oDlg
		DEFINE SBUTTON FROM 92 ,174 TYPE 1 ACTION (nOpca := 1,IF(CD030Ok(),oDlg:End(),nOpca:=0)) ENABLE OF oDlg
		DEFINE SBUTTON FROM 92 ,204 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpcA == 1
		#IFNDEF TOP
			Processa({|lEnd| CD030Processa()},STR0001,STR0005,.T.) //"Calculo do Direito Autoral"###"Calculando o direito autoral..."
		#ELSE
			Processa({|lEnd| CD030ProcTOP()},STR0001,STR0005,.T.) //"Calculo do Direito Autoral"###"Calculando o direito autoral..."
		#ENDIF
	Endif

	If Len(aInconsist) > 0
		If ExistBlock("CDAR070")
			ExecBlock("CDAR070",.F.,.F. )
		Endif
	EndIF
EndIf	

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Restaura a Interface                                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
RestInter()

Return (.T.)

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддбдддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    ЁCD030ProcessaЁAutorЁ Cristiano G. Cunha   Ё Data Ё 05/07/02 Ё╠╠
╠╠цддддддддддедддддддддддддадддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Processamento - Calculo do Direito Autoral (Royalty)       Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё CDAA030                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function CD030Processa()
Local aArea     := GetArea()
Local dPerIni 
Local dPerFim
//Local cPrdMaster:= ""
Local cForneced := ""
Local cProduto  := ""
//Local nQtdAcSB1 := 0
Local nSldAdian := 0
Local nAreaAHA  := 0
Local nElemen   := 0
Local nI        := 0
Local lFirst    := .T.
Local lRet      := .T.
Local aPrdMaster:= {}
Local i         := 0
Local cFilIni 		:= Iif(Empty(MV_PAR02),cFilAnt,MV_PAR02)
Local cFilFin 		:= Iif(Empty(MV_PAR03),cFilAnt,MV_PAR03) 
Local cFilOri		:= IIf( lFWCodFil , FWGETCODFILIAL, SM0->M0_CODFIL )
Local aSM0			:= AdmAbreSM0()
Local nContFil		:= 0  
    
Private lCalcAH7:= .T.
Private aInd    := {}  // array com nomes dos indices temporarios
Private aQtdeAH7:= {}
Private cPrdMaster:=""
Private nQtdAcSB1 := 0

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Periodo de processamento, do dia 01 do mes e ano informados  Ё
//Ё ate o ultimo dia do mes.                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dPerIni := CTOD("01/"+StrZero(Month(mv_par01),2)+"/"+Str(Year(mv_par01)))
dPerFim := LastDay(dPerini)

If dPerFim <= GetMv("MV_CDAFECH")
	Help(" ",1,"CD030DtInv")
	Return (.F.)
Endif

lRet := .T.
If (ExistBlock("CDA030A"))
	lRet := ExecBlock("CDA030A",.F.,.F.)
	If !lRet                                                                                                                                    
	
		Return lRet
	Endif
EndIf                       

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle por filial.                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nContFil := 1 to Len(aSM0)
	If aSM0[nContFil][SM0_CODFIL] < cFilIni .Or. aSM0[nContFil][SM0_CODFIL] > cFilFin .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt  
		Loop
	EndIf
	 
	cFilAnt := aSM0[nContFil][SM0_CODFIL]	

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Gera indices temporarios do SD1, SD2 e SD3.                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	CD030GerIn(dPerIni,dPerFim)
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Apaga os registros de apuracao do periodo.                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If (ExistBlock("CDAA104"))
		ExecBlock("CDAA104",.F.,.F., {dPerIni, dPerFim})
	Else
		CD030DelDA(dPerIni,dPerFim)
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicializa a regua de processamento.                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	ProcRegua(AH1->(RecCount()))
	
	lFirst := .T.
	
	dbSelectArea("AH4")
	dbSetOrder(1)     // AH4_FILIAL+AH4_PRODUT+AH4_FORNEC+AH4_LOJAFO+DTOS(AH4_DATCAL)+AH4_LICITA
	
	dbSelectArea("AH5")
	dbSetOrder(1)     // AH5_FILIAL+AH5_PRODUT+AH5_FORNEC+AH5_LOJAFO+DTOS(AH5_DATCAL)+Str(AH5_FXFINA,9)+Str(AH5_PRECOU,14,3)
	
	dbSelectArea("AH6")
	dbSetOrder(1)     // AH6_FILIAL+AH6_PRODUT+AH6_FORNEC+AH6_LOJAFO
	
	dbSelectArea("AH1")
	dbSeek(xFilial())
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Calculo do direito autoral (royalty).                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	While AH1->(!Eof()) .And. xFilial("AH1")==AH1->AH1_FILIAL
	
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Calcula um produto (livro) por vez.                          Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cProduto   := AH1->AH1_PRODUT
		aPrdMaster := {}
		lCalcAH7   := .F.
		lLicitaca  := .F.
		While AH1->(!Eof()) .And. xFilial("AH1")+cProduto == ;
									AH1->AH1_FILIAL+AH1->AH1_PRODUT
			
			If lFirst
				IncProc(STR0006) //"Calculando direito autoral ..."
				lFirst := .F.
			Else
				IncProc()
			Endif
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se gera prestacao de contas ou nao.                 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			SA2->( dbSetOrder(1) )
			SA2->(dbSeek(xFilial("SA2")+AH1->AH1_FORNEC+AH1->AH1_LOJAFO))
			If SA2->A2_PAGAMEN == "1"   // nao recebe pagamento, somente o relatorio.
				dbSelectArea("AH1")
				dbSkip()
				Loop
			Endif
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Pesquisa e acumula qtde. do livro, produto master.           Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cPrdMaster := AH1->AH1_MASTER
			AH8->(dbSetOrder(1))
			AH8->(dbSeek(xFilial("AH8")+cPrdMaster))
			
			cForneced := AH1->AH1_FORNEC + AH1->AH1_LOJAFO
			While AH1->(!Eof()) .And. xFilial("AH1")+cProduto+cForneced == ;
				AH1->AH1_FILIAL+AH1->AH1_PRODUT+AH1->AH1_FORNEC+AH1->AH1_LOJAFO
	
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifica se o periodo esta dentro do mes de calculo.         Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If AH1->AH1_INICVI > dPerFim .Or. (AH1->AH1_DATAFI < dPerFim .And. !Empty(AH1->AH1_DATAFI))
					dbSelectArea("AH1")
					dbSkip()
					Loop
				Endif
	
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Calcula o adiantamento inicial da amarracao.           Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nSldAdian := AH1->AH1_SALDOA + AH1->AH1_SALDQT
	
				dbSelectArea("AHF")
				dbSeek(xFilial("AHF")+cForneced)
				If !Eof()
					nSldAdian := AHF->AHF_SALDOA + AHF->AHF_SALDQT
				Endif
	
				dbSelectArea("AH1")
				If nSldAdian > 0
					CD030Adian(cProduto,cForneced)
				Endif
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifica a data da proxima prestacao de contas.         Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				dbSelectArea("AH6")
				dbSetOrder(1)
				If !CdSeekAH6(xFilial("AH6")+cProduto+cForneced)
					RecLock("AH6",.T.)
					AH6->AH6_FILIAL := xFilial("AH6")
					AH6->AH6_PRODUT := cProduto
					AH6->AH6_FORNEC := AH1->AH1_FORNEC
					AH6->AH6_LOJAFO := AH1->AH1_LOJAFO
					AH6->AH6_DTPRXD := CD030DtPrx(CTOD(SPACE(08)),cProduto,cForneced)
					If (AH6->(FieldPos("AH6_CODANT")) > 0)
						AH6->AH6_CODANT := AH1->AH1_CODANT
					EndIf
					MsUnLock()
				Endif
	
				dbSelectArea("AH8")
				dbSetOrder(1)
				dbSeek(xFilial("AH8") + cPrdMaster )
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Calcula o direito autoral e retorno da qtde do produto.Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nQtdAcSB1 := 0
				nQtdAcSB1 := CD030CalDA(cProduto,cForneced,dPerIni,dPerFim)
				lCalcAH7  := .T.
	
	 			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Pesquisa no array o produto master diferente do produto.     Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If cProduto != cPrdMaster
					nElement := aScan(aPrdMaster,{|x| x == cPrdMaster})
					If nElement == 0
						Aadd(aPrdMaster,cPrdMaster)
					Endif
				Endif
				
				dbSelectArea("AH1")
				dbSkip()
			End
			dbSelectArea("AH1")
		End
	
	/*	dbSelectArea("AH8")
		dbSetOrder(1)
		If dbSeek(xFilial("AH8")+cPrdMaster)
			RecLock("AH8",.F.)
			AH8_QTDACU += nQtdAcSB1
			MsUnLock()
		EndIf*/
		
		If Len(aPrdMaster) >= 1
			For i := 1 To Len(aPrdMaster)
				dbSelectArea("AH8")
				dbSetOrder(1)
				If dbSeek(xFilial("AH8")+aPrdMaster[i])
					RecLock("AH8",.F.)
					AH8_QTDACU += nQtdAcSB1
					MsUnLock()
				EndIf
			Next
		Endif
	
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava dados no AH7 - qtdes acumuladas no mes.          Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lCalcAH7
			CD030GrAH7(dPerIni,dPerFim,cProduto)
		Endif
	End
	
	dbSelectArea("AH4")
	dbSetOrder(1)
	dbSelectArea("AH5")
	dbSetOrder(1)
	
	dbSelectArea("SD1")
	RetIndex("SD1")
	DbClearFilter()
	
	dbSelectArea("SD2")
	RetIndex("SD2")
	DbClearFilter()
	
	dbSelectArea("SD3")
	RetIndex("SD3")
	DbClearFilter()

	If Len(aInd) > 0
		For nI := 1 To Len(aInd)
			If File(aInd[nI]+OrdBagExt())
				FErase(aInd[nI]+OrdBagExt())
			Endif
		Next
	Endif
	
Next nContFil

RestArea( aArea )

//здддддддддддддддддддддддддддддддддддддддддд©
//ЁVolta a empresa anteriormente selecionada.Ё
//юдддддддддддддддддддддддддддддддддддддддддды
cFilAnt := cFilOri
Return


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠Ё Fun┤┘o   Ё CD030Ok  Ё Autor Ё Cristiano G. Cunha    Ё Data Ё 05/07/02 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠Ё Descri┤┘oЁ Mensagem de OK antes de executar o processamento           Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё CDAA030                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function CD030Ok()
Return (MsgYesNo(STR0007,STR0008)) //"Confirma calculo do Dir.Autoral ?"###"Aten┤└o"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠Ё Fun┤┘o   Ё CD030Mes Ё Autor Ё Cristiano G. Cunha    Ё Data Ё 05/07/02 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠Ё Descri┤┘oЁ Funcao que verifica a validade do mes.                     Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё CDAA030                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function CD030Mes()

Local nMes := &(ReadVar())
Local lRet := .T.

If nMes < 0 .Or. nMes > 12
	Help(" ",1,"CD030MesIn")
	lRet := .F.
Endif

Return lRet


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠Ё Fun┤┘o   ЁCD030DelDAЁ Autor Ё Cristiano G. Cunha    Ё Data Ё 05/07/02 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠Ё Descri┤┘oЁ Funcao que apaga os direitos autorais do periodo.          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё CD030DelDA(ExpD1,ExpD2)                                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpD1 - Data Inicial do periodo                            Ё╠╠
╠╠Ё          Ё ExpD2 - Data Final do periodo                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё CDAA030                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function CD030DelDA(dPerIni,dPerFim)
Local aArea     := GetArea()
Local nRegistro := 0
Local lFirst    := .T.

If (ExistBlock("DIRA010"))
   nRegistro := ExecBlock("DIRA010",.F.,.F.)
Endif
If nRegistro == 0
	nRegistro := (AH4->(RecCount())+AH5->(RecCount())+AH1->(RecCount())+AH7->(RecCount())+1)
Endif
ProcRegua(nRegistro)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Apaga todos os registros do periodo (AH4 - cabecalho da apuracao do DA)  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
IncProc(STR0009) //"Deletando registros do periodo ..."
dbSelectArea("AH4")
dbSetOrder(2)      // AH4_FILIAL + DTOS(AH4_DATCAL)
dbSeek(xFilial("AH4")+DTOS(dPerIni),.T.)

While AH4->(!Eof()) .And. xFilial("AH4") == AH4->AH4_FILIAL

	IncProc()
	If AH4->AH4_DATCAL >= dPerIni
		RecLock("AH4",.F.,.T.)
		dbDelete()
	EndIf

	dbSelectArea("AH4")
	dbSkip()
End
 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Apaga todos os registros do periodo (AH5 - itens da apuracao do DA)      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("AH5")
dbSetOrder(2)      // AH5_FILIAL + DTOS(AH5_DATCAL)
dbSeek(xFilial("AH5")+DTOS(dPerIni),.T.)
While AH5->(!Eof()) .And. xFilial("AH5") == AH5->AH5_FILIAL

	IncProc()
	If AH5->AH5_DATCAL >= dPerIni
		RecLock("AH5",.F.,.T.)
		dbDelete()
		MsUnlock()
	Endif
	dbSelectArea("AH5")
	dbSkip()
End

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Apaga todos os registros do periodo (AH7 - qtdes acumuladas por mes)     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("AH7")
dbSetOrder(2)      // AH7_FILIAL + DTOS(AH7_DATCAL) + AH7_PRODUT + AH7_FORNEC + AH7_LOJAFO
dbSeek(xFilial("AH7")+DTOS(dPerIni),.T.)
While AH7->(!Eof()) .And. xFilial("AH7") == AH7->AH7_FILIAL 

	IncProc()

	If AH7->AH7_DATCAL >= dPerIni
		RecLock("AH7",.F.,.T.)
		dbDelete()
	Endif
	dbSelectArea("AH7")
	dbSkip()
End

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava a quantidade do inicio do mes no campo quantidade acumulada.       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ProcRegua(AH8->(RecCount()))
dbSelectArea("AH8")
dbSeek(xFilial())
lFirst   := .T.
While AH8->(!Eof()) .And. xFilial("AH8")==AH8->AH8_FILIAL

	If lFirst
		IncProc(STR0010) //"Retornando quantidades do periodo ..."
		lFirst := .F.
	Else
		IncProc()
	Endif

	RecLock("AH8",.F.)
	AH8->AH8_QTDACU := AH8->AH8_QTDINI
	MsUnLock()

	dbSelectArea("AH8")
	dbSkip()
End

RestArea(aArea)
Return (.T.)


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    ЁCD030DtPrxЁ Autor Ё Cristiano G. Cunha    Ё Data Ё 05/07/02 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Funcao que calcula a proxima data da prestacao de contas.  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё ExpD1 := CD030DtPrx(ExpD2,ExpC1,ExpC2)                     Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpD1 - Data da proxima prestacao de contas (royalty)      Ё╠╠
╠╠Ё          Ё ExpD2 - Data da prestacao de contas anterior (royalty)     Ё╠╠
╠╠Ё          Ё ExpC1 - Codigo do produto                                  Ё╠╠
╠╠Ё          Ё ExpC2 - Codigo + Loja do Fornecedor                        Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё CDAA030                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function CD030DtPrx(dUltPrest,cProduto,cForneced)
Local aArea    := GetArea()
Local aAreaAH1 := AH1->(GetArea())
Local nMesPrest:= 0
Local nMesProxi:= 0
Local nAnoProxi:= 0
Local cDataAuxi:= "" 
Local dDataProxi
Local dDataFinal

dbSelectArea("AH1")
dbSetOrder(1)
dbSeek(xFilial("AH1")+cProduto+cForneced)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Usa a data da ultima prestacao de contas ou a data de incio da vigencia. Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(dUltPrest)
	If !Empty(AH1->AH1_DTULTP)
		dUltPrest := AH1->AH1_DTULTP
	Else
		dUltPrest := AH1->AH1_INICVI
		If Empty(AH1->AH1_INICVI) .or. Month(AH1->AH1_INICVI) < Month(dDataBase)
			dUltPrest := dDataBase
		Endif
		cDataAuxi := Dtoc(dUltPrest)
		nMesPrest := Month(dUltPrest) - 1
		If nMesPrest <= 0
			cDataAuxi := Substr(cDataAuxi,1,2) + "/12/" + Substr(StrZero(Year(dUltPrest)-1,4),3,2)
			dUltPrest := CTOD(cDataAuxi)
		Else
			cDataAuxi := Substr(cDataAuxi,1,3) + StrZero(nMesPrest,2) + "/" + Substr(StrZero(Year(dUltPrest),4),3,2)
			dUltPrest := CTOD(cDataAuxi)
		Endif
	Endif
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Soma a periodicidade (meses) na ultima prestacao de contas.              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nMesPrest := Val(AH1->AH1_PERIOD)
nMesProxi := Month(dUltPrest) + nMesPrest
nAnoProxi := Year(dUltPrest)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se o mes calculado for > que 12, atualiza o mes e ano.                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nMesProxi > 12
	nMesProxi -= 12
	nAnoProxi++
Endif
dDataProxi := CTOD("01/" + StrZero(nMesProxi,2) + "/" + ;
              Substr(StrZero(nAnoProxi,4),3,2))
dDataFinal := LastDay(dDataProxi)

RestArea(aAreaAH1)
RestArea(aArea)

Return dDataFinal


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    ЁCD030AdianЁ Autor Ё Cristiano G. Cunha    Ё Data Ё 05/07/02 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Funcao que calcula o adiantamento em valor.                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё CD030Adian(ExpC1,ExpC2)                                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpC1 - Codigo do Produto                                  Ё╠╠
╠╠Ё          Ё ExpC2 - Codigo + Loja do Fornecedor                        Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё CDAA030                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function CD030Adian(cProduto,cForneced)
Local aArea     := GetArea()
Local aAreaAH1  := AH1->(GetArea())
Local aTam      := {}
Local nSaldQtd  := 0
Local nSaldAdi  := 0
Local cCodAnt   := ""
Local cLojaFor  := ""
Local dPrxPrest
Local dDatCalc

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica a data da proxima prestacao de contas.         Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("AH6")
dbSetOrder(1)
If !CdSeekAH6(xFilial("AH6")+cProduto+cForneced)
	RecLock("AH6",.T.)
	AH6->AH6_FILIAL := xFilial("AH6")
	AH6->AH6_PRODUT := cProduto
	AH6->AH6_FORNEC := Left(cForneced,6)
	AH6->AH6_LOJAFO := Right(cForneced,2)
	AH6->AH6_DTPRXD := CD030DtPrx(CTOD(""),cProduto,cForneced)

	If (AH6->(FieldPos("AH6_CODANT")) > 0)
		aAreaAH1:= AH1->(GetArea())
		
		dbSelectArea("AH1")
		dbSetOrder(1)
		If dbSeek(xFilial("AH1")+cProduto+cForneced)
			cCodAnt := AH1->AH1_CODANT
		EndIf
		
		RestArea(aAreaAH1)

		dbSelectArea("AH6")
		AH6->AH6_CODANT := cCodAnt
	EndIf
	MsUnLock()
Endif

dPrxPrest := AH6->AH6_DTPRXD     // Proxima prestacao do direito autoral
dDatCalc  := LastDay(CTOD("01/"+StrZero(Month(mv_par01),2)+"/"+Str(Year(mv_par01))))

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se possui adiantamento no arq. AHF             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFornece := AH1->AH1_FORNEC
cLojaFor := AH1->AH1_LOJAFO
nSaldQtd := AH1->AH1_SALDQT
nSaldAdi := AH1->AH1_SALDOA

dbSelectArea("AHF")
dbSetOrder(1)
If dbSeek(xFilial("AHF")+cForneced)
	cFornece := AHF->AHF_FORNEC
	cLojaFor := AHF->AHF_LOJAFO
	nSaldQtd := AHF->AHF_SALDQT
	nSaldAdi := AHF->AHF_SALDOA
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava movimentos de royalty.                            Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("AH4")
dbSetOrder(1)
If !dbSeek(xFilial("AH4")+cProduto+cForneced+DTOS(dDatCalc))
	RecLock("AH4",.T.)
	AH4->AH4_FILIAL := xFilial("AH4")
	AH4->AH4_PRODUT := cProduto
	AH4->AH4_FORNEC := cFornece
	AH4->AH4_LOJAFO := cLojaFor
	AH4->AH4_DATCAL := dDatCalc
	AH4->AH4_DTULTI := AH1->AH1_DTULTP
	
	If (AH4->(FieldPos("AH4_CODANT")) > 0)
		aAreaAH1:= AH1->(GetArea())
		
		dbSelectArea("AH1")
		dbSetOrder(1)
		If dbSeek(xFilial("AH1")+cProduto+cFornece+cLojaFor)
			cCodAnt := AH1->AH1_CODANT
		EndIf
		
		RestArea(aAreaAH1)
		dbSelectArea("AH4")
		AH4->AH4_CODANT := cCodAnt
	EndIf
Else
	RecLock("AH4",.F.)
Endif
AH4->AH4_DTPRES := AH6->AH6_DTPRXD
If nSaldQtd > 0
	AH4->AH4_QTDADI := nSaldQtd
Else
	AH4->AH4_VALADI := nSaldAdi
Endif
MsUnLock()

aTam      := TamSX3("AH5_PRECOU")
cPrecoVen := Str(0,aTam[1],aTam[2])
dbSelectArea("AH5")  
dbSetOrder(1)
If !dbSeek(xFilial("AH5")+cProduto+cForneced+DTOS(dDatCalc)+Str(AH2->AH2_FXFINA,9)+cPrecoVen)
	RecLock("AH5",.T.)
	AH5->AH5_FILIAL := xFilial("AH5")
	AH5->AH5_PRODUT := cProduto
	AH5->AH5_FORNEC := cFornece
	AH5->AH5_LOJAFO := cLojaFor
	AH5->AH5_DATCAL := dDatCalc

	If (AH5->(FieldPos("AH5_CODANT")) > 0)
		aAreaAH1:= AH1->(GetArea())
		
		dbSelectArea("AH1")
		If dbSeek(xFilial("AH1")+cProduto+cFornece+cLojaFor)
			cCodAnt := AH1->AH1_CODANT
		EndIf
		
		RestArea(aAreaAH1)
		dbSelectArea("AH5")
		AH5->AH5_CODANT := cCodAnt
	EndIf
Else
	RecLock("AH5",.F.)
Endif
AH5->AH5_DTPRES := AH6->AH6_DTPRXD
MsUnLock()

RestArea(aArea)
Return (.T.)


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    ЁCD030ArrayЁ Autor Ё Cristiano G. Cunha    Ё Data Ё 05/07/02 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Gera array com regras da amarracao (AH2)                   Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё ExpA1 := CD030Array(ExpC1)                                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpA1 - Array com as regras                                Ё╠╠
╠╠Ё          Ё ExpC1 - Codigo do Produto                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё CDAA030                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function CD030Array(cChave)
Local aRegraAH2 := {}
Local aTam		:= {}
Local aTamFx    := {}

If (ExistBlock("DIRA020"))
   aRegraAH2 := ExecBlock("DIRA020",.F.,.F.,aRegraAH2)
Endif

dbSelectArea("AH2")
dbSetOrder(1)
dbSeek(xFilial("AH2")+cChave)

While AH2->(!Eof()) .And.  xFilial("AH2")+cChave == AH2->AH2_FILIAL+AH2->AH2_PRODUT+ ;
							AH2->AH2_FORNEC+AH2->AH2_LOJAFO

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Array com as regras do AH2                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Aadd( aRegraAH2,{AH2->AH2_FXINIC,AH2->AH2_FXFINA,AH2->AH2_DESCMI,;
	                   AH2->AH2_PERCRE,AH2->AH2_VALREG,AH2->AH2_PRBRUT,;
    	               AH2->AH2_DESCCO,AH2->AH2_ICMS,AH2->AH2_IPI,;
	                   AH2->AH2_COFINS, AH2->AH2_OUTROS})
	dbSkip()
End

aTamFx := TamSX3("AH2_FXINIC")
aTam   := TamSX3("D2_DESC")
aSort(aRegraAH2,,,{|x,y| Strzero(x[3]*-1,aTam[1],aTam[2]) + StrZero(x[1],aTamFx[1],aTamFx[2]) < Strzero(y[3]*-1,aTam[1],aTam[2]) + StrZero(y[1],aTamFx[1],aTamFx[2])})

Return aRegraAH2


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠Ё Fun┤┘o   ЁCD030GerInЁ Autor Ё Cristiano G. Cunha    Ё Data Ё 05/07/02 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠Ё Descri┤┘oЁ Funcao que gera os indices temporarios de SD1, SD2 e SD3.  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё CD030GerIn(ExpD1,ExpD2)                                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpD1 - Data inicial do periodo                            Ё╠╠
╠╠Ё          Ё ExpD2 - Data final do periodo                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё CDAA030                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function CD030GerIn(dPerIni,dPerFim)
Local cIndex   := ""
Local cKey     := ""
Local cCondicao:= ""
Local nIndex   := 0
Local aChave   := {}

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Gera indice temporario do SD2.                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cIndex := CriaTrab(Nil,.F.)

AADD(aInd,cIndex)
dbSelectArea("SD2")

If (ExistBlock("DIRA030"))
	aChave    := ExecBlock("DIRA030",.F.,.F.,{dPerIni,dPerFim})
	cKey      := aChave[1]
	cCondicao := aChave[2]
Endif
If Len(aChave)==0
	cKey      := "D2_FILIAL+D2_COD+DTOS(D2_EMISSAO)"
	cCondicao := 'D2_FILIAL == SD2->(xFILIAL()) .AND. DTOS(D2_EMISSAO) >= "' + DTOS(dPerIni) + '" .And. DTOS(D2_EMISSAO) <= "' + DTOS(dPerFim) + '" .And. D2_TIPO # "D" '
Endif

IndRegua("SD2",cIndex,cKey,,cCondicao,STR0011) //"Selec. Registros (SD2) ..."
nIndex := RetIndex("SD2")
dbSelectArea("SD2")
#IFNDEF TOP
	dbSetIndex(cIndex+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)
dbGoTop()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Gera indice temporario do SD1.                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cIndex := CriaTrab(Nil,.F.)

AADD(aInd,cIndex)
dbSelectArea("SD1")

aChave:={}
If (ExistBlock("DIRA040"))
	aChave    := ExecBlock("DIRA040",.F.,.F.,{dPerIni,dPerFim})
	cKey      := aChave[1]
	cCondicao := aChave[2]
Endif
If Len(aChave) == 0
	cKey      := "D1_FILIAL+D1_COD+DTOS(D1_DTDIGIT)"
	cCondicao := 'D1_FILIAL == SD1->(xFILIAL()) .AND. DTOS(D1_DTDIGIT) >= "' + DTOS(dPerIni) + '" .And. DTOS(D1_DTDIGIT) <= "' + DTOS(dPerFim) + '" .And. D1_TIPO $ "BD"'
	cCondicao += ' .And. D1_TES <> "' + Space(TamSX3("D1_TES")[1]) + '"'
Endif

IndRegua("SD1",cIndex,cKey,,cCondicao,STR0012) //"Selecionando Registros..."
nIndex := RetIndex("SD1")
dbSelectArea("SD1")
#IFNDEF TOP
	dbSetIndex(cIndex+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)
dbGoTop()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Gera indice temporario do SD3.                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cIndex := CriaTrab(Nil,.F.)

AADD(aInd,cIndex)
dbSelectArea("SD3")

aChave := {}
If (ExistBlock("DIRA050"))
	aChave    := ExecBlock("DIRA050",.F.,.F.,{dPerIni,dPerFim})
	cKey      := aChave[1]
	cCondicao := aChave[2]
Endif
If Len(aChave)==0
	cKey      := "D3_FILIAL+D3_COD+DTOS(D3_EMISSAO)"
	cCondicao := 'D3_FILIAL == SD3->(xFILIAL()) .AND. DTOS(D3_EMISSAO) >= "' + DTOS(dPerIni) + '" .And. DTOS(D3_EMISSAO) <= "' + DTOS(dPerFim) + '"'
Endif

IndRegua("SD3",cIndex,cKey,,cCondicao,STR0013) //"Selec. Registros (SD3) ..."
nIndex := RetIndex("SD3")
dbSelectArea("SD3")
#IFNDEF TOP
	dbSetIndex(cIndex+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)
dbGoTop()

Return (.T.)


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    ЁCD030CalDAЁ Autor Ё Cristiano G. Cunha    Ё Data Ё 05/07/02 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Calcula o direito autoral em moeda Corrente ou Forte.      Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё CD030Calc(ExpC1,ExpC2,ExpD1,ExpD2)                         Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpC1 - Codigo do Produto                                  Ё╠╠
╠╠Ё          Ё ExpC2 - Codigo e Loja do Fornecedor                        Ё╠╠
╠╠Ё          Ё ExpD1 - Data de inicio do periodo                          Ё╠╠
╠╠Ё          Ё ExpD2 - Data de final do periodo                           Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё CDAA030                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function CD030CalDA(cProduto,cForneced,dPerIni,dPerFim)
Local aAreaAH1  := AH1->(GetArea())

Local nSaldoIni := 0
Local nSaldoFim := 0
Local aCondicao := {}
Local aRetSaldo := {}
Local aSaldo    := {}
Local cSeek     := ""
Local cCondicao := ""
Local cCpoTipo  := ""
Local lDira060  := ExistBlock("DIRA060")
Local lDira070  := ExistBlock("DIRA070")
Local lDira080  := ExistBlock("DIRA080")
Local dDataAux

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Codigos de origem de movimento:                              Ё
//Ё 01 - Venda                                                   Ё
//Ё 02 - Devolucao                                               Ё
//Ё 03 - Transferencia                                           Ё
//Ё 04 - Promocao                                                Ё
//Ё 05 - Consignacao                                             Ё
//Ё 06 - Perdas                                                  Ё
//Ё 07 - Producao                                                Ё
//Ё 08 - Acertos                                                 Ё
//Ё 09 - Venda de Consignacao                                    Ё
//Ё 10 - Retorno de Consignacao                                  Ё
//Ё 11 - Devolucao de Venda de Consignacao                       Ё
//Ё 12 - Licitacao                                               Ё
//Ё 13 - Dev. de Venda de Consignacao - com Estoque              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lCalcAH7
	aQtdeAH7 := Array(16)
	Afill(aQtdeAH7,0,1,16)
Endif

SF4->(dbSetOrder(1))
SF4->(dbSeek(xFilial("SF4") + SD2->D2_TES))
cCpoTipo := Iif(Empty(SF4->F4_TIPOPER),"SD2->D2_TES","SF4->F4_TIPOPER")

nQtdAcum1 := AH8->AH8_QTDACU

dDataAux := dPerIni
While dDataAux <= dPerFim
	dbSelectArea("SD2")
	
	aCondicao := {}
	cSeek     := ""
	cCondicao := ""
	If lDira060
		aCondicao := ExecBlock("DIRA060",.F.,.F.,cProduto)
		cSeek     := aCondicao[1]
		cCondicao := aCondicao[2]
	Endif
	If Len(aCondicao) == 0
		cSeek:= SD2->(xFILIAL())+cProduto+DTOS(dDataAux)
		cCondicao := "SD2->D2_FILIAL+SD2->D2_COD+DTOS(SD2->D2_EMISSAO) == "+ "'" + SD2->(xFILIAL())+cProduto+DTOS(dDataAux) + "'"
	Endif                                     

	dbSeek(cSeek)
	While SD2->(!Eof()) .and. &cCondicao
		CD030Calc2(cProduto,cForneced,dPerFim,"SD2")
		dbSelectArea("SD2")
		dbSkip()
	End

	aCondicao := {}
	cSeek     := ""
	cCondicao := ""
	dbSelectArea("SD1")
	
	If lDira070
		aCondicao := ExecBlock( "DIRA070",.F.,.F.,cProduto)
		cSeek     := aCondicao[1]
		cCondicao := aCondicao[2]
	Endif
	If Len(aCondicao) == 0
		cSeek:= SD1->(xFILIAL())+cProduto+DTOS(dDataAux)
		cCondicao := "SD1->D1_FILIAL+SD1->D1_COD+DTOS(SD1->D1_DTDIGIT) == "+ "'" + SD1->(xFILIAL())+cProduto+DTOS(dDataAux) + "'"
	Endif
	
	dbSeek(cSeek)
	While SD1->(!Eof()) .and. &cCondicao
		CD030Calc2(cProduto,cForneced,dPerFim,"SD1")
		dbSelectArea("SD1")
		dbSkip()
	End

	aCondicao := {}
	cSeek     := ""
	cCondicao := ""
	dbSelectArea("SD3")
	
	If lDira080
		aCondicao := ExecBlock( "DIRA080", .F., .F. ,cProduto)
		cSeek     := aCondicao[1]
		cCondicao := aCondicao[2]
	Endif
	If Len(aCondicao) == 0
		cSeek:= SD3->(xFILIAL())+cProduto+DTOS(dDataAux)
		cCondicao := "SD3->D3_FILIAL+SD3->D3_COD+DTOS(SD3->D3_EMISSAO) == "+ "'" + SD3->(xFILIAL())+cProduto+DTOS(dDataAux) + "'"
	Endif
	
	dbSeek(cSeek)
	While SD3->(!Eof()) .and. &cCondicao
		CD030Calc2(cProduto,cForneced,dPerFim,"SD3")
		dbSelectArea("SD3")
		dbSkip()
	End

	dDataAux++
End

If ExistBlock("DIRA090")
	aRetSaldo := ExecBlock("DIRA090",.F.,.F.,{cProduto,dPerIni,dPerFim})
	nSaldoIni := aRetSaldo[1]
	nSaldoFim := aRetSaldo[2]
Endif
If Len(aRetSaldo) == 0
	dbSelectArea("SB2")
	dbSeek(xFilial("SB2")+ cProduto)
	While SB2->(!Eof()) .And. xFilial("SB2")+cProduto == SB2->B2_FILIAL+SB2->B2_COD
		aSaldo    := CalcEst(SB2->B2_COD,SB2->B2_Local,dPerIni)
		nSaldoIni += aSaldo[1]
		aSaldo    := CalcEst(SB2->B2_COD,SB2->B2_Local,dPerFim+1)
		nSaldoFim += aSaldo[1]
		dbSkip()
	End
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se a grava AH4 zerado ou nao.                  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nSaldoIni != 0 .Or. nSaldoFim != 0
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica a data da proxima prestacao de contas.         Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("AH6")
	dbSetOrder(1)
	If !CdSeekAH6(xFilial("AH6")+cProduto+cForneced)
		RecLock("AH6",.T.)
		AH6->AH6_FILIAL := xFilial("AH6")
		AH6->AH6_PRODUT := cProduto
		AH6->AH6_FORNEC := AH2->AH2_FORNEC
		AH6->AH6_LOJAFO := AH2->AH2_LOJAFO
		AH6->AH6_DTPRXD := CD030DtPrx(CTOD(""),cProduto,cForneced)

		If (AH6->(FieldPos("AH6_CODANT")) > 0)
			aAreaAH1:= AH1->(GetArea())

			dbSelectArea("AH1")
			dbSetOrder(1)
			If dbSeek(xFilial("AH1")+cProduto+AH2->AH2_FORNEC+AH2->AH2_LOJAFO)
				cCodAnt := AH1->AH1_CODANT
			EndIf

			RestArea(aAreaAH1)
			dbSelectArea("AH6")
			AH6->AH6_CODANT := cCodAnt
		EndIf
		MsUnLock()
	Endif
	dPrxPrest := AH6->AH6_DTPRXD     // Proxima prestacao do direito autoral
	dDatCalc  := LastDay(CTOD("01/"+StrZero(Month(mv_par01),2)+"/"+Str(Year(mv_par01))))

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava movimentos de royalty.                            Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("AH4")
	dbSetOrder(1)
	If !dbSeek(xFilial("AH4")+cProduto+cForneced+DTOS(dDatCalc))
		RecLock("AH4",.T.)
		AH4->AH4_FILIAL := xFilial("AH4")
		AH4->AH4_PRODUT := cProduto
		AH4->AH4_FORNEC := AH1->AH1_FORNEC
		AH4->AH4_LOJAFO := AH1->AH1_LOJAFO
		AH4->AH4_DATCAL := dDatCalc
		AH4->AH4_DTPRES := AH6->AH6_DTPRXD
		AH4->AH4_DTULTI := AH1->AH1_DTULTP

		If (AH4->(FieldPos("AH4_CODANT")) > 0)
			AH4->AH4_CODANT := AH1->AH1_CODANT
		EndIf
		MsUnLock()
	Endif
EndIf

Return (nQtdAcum1 - AH8->AH8_QTDACU)


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    ЁCD030Calc2Ё Autor Ё Cristiano G. Cunha    Ё Data Ё 05/07/02 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Calcula o direito autoral em moeda Corrente ou Forte.      Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё CD030Calc2(ExpC1,ExpC2,ExpD1,ExpD2)                        Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpC1 - codigo do produto                                  Ё╠╠
╠╠Ё          Ё ExpC2 - codigo e loja do fornecedor                        Ё╠╠
╠╠Ё          Ё ExpD1 - data de inicio do periodo                          Ё╠╠
╠╠Ё          Ё ExpD2 - data de final do periodo                           Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё CDAA030                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function CD030Calc2(cProduto,cForneced,dPerFim,cAlias)
Local lSeguinte 	:= .F.
Local lAchouFxa 	:= .F.
Local lAppend   	:= .F.
//Local nQtdAcum1 := 0
Local nQtdAcum2 	:= 0
Local nQtdVenda 	:= 0
Local nQtdVend2 	:= 0
Local nPrecoUn  	:= 0
Local nElemen   	:= 0
Local nDirAutor 	:= 0
Local nQtdAuxil 	:= 0
Local i				:= 0
Local nI			:= 0
Local nAreaAH9		:= 0
Local nMoedaFor 	:= Val(GetMv("MV_MCUSTO"))
Local aRegraAH2 	:= {}
Local aAreaAH2  	:= {}
Local aAreaSD2  	:= {}
Local aCalMov   	:= {}
Local cPrecoUn  	:= ""
Local dPrxPrest
Local cCpoTipo 		:= ""
Local lMV_CDAPRCP	:= SuperGetMV( "MV_CDAPRCP", .F., .F. )
Local lD1UnDA		:= SD1->( FieldPos( "D1_PRUNDA" ) ) > 0 .AND. lMV_CDAPRCP
Local lD2UnDA		:= SD2->( FieldPos( "D2_PRUNDA" ) ) > 0 .AND. lMV_CDAPRCP
Local lCda030VDA    := ExistBlock("Cda030VDA")

SF4->(dbSetOrder(1))
SF4->( dbSeek( xFilial("SF4") + Iif(cAlias=="SD2",SD2->D2_TES,SD1->D1_TES)) )

cCpoTipo := Iif(Empty(SF4->F4_TIPOPER),"SD2->D2_TES","SF4->F4_TIPOPER")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Codigos de origem de movimento:                              Ё
//Ё 01 - Venda                                                   Ё
//Ё 02 - Devolucao                                               Ё
//Ё 03 - Transferencia                                           Ё
//Ё 04 - Promocao                                                Ё
//Ё 05 - Consignacao                                             Ё
//Ё 06 - Perdas                                                  Ё
//Ё 07 - Producao                                                Ё
//Ё 08 - Acertos                                                 Ё
//Ё 09 - Venda de Consignacao                                    Ё
//Ё 10 - Retorno de Consignacao                                  Ё
//Ё 11 - Devolucao de Venda de Consignacao                       Ё
//Ё 12 - Licitacao                                               Ё
//Ё 13 - Dev. de Venda de Consignacao - com Estoque              Ё
//Ё 14 - Bonificacao                                             Ё
//Ё 15 - Venda Autor                                             Ё
//Ё 16 - Doacao                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

lSeguinte := .F.
lLicitaca := .F.
If !lCalcAH7
	If cAlias == "SD1"
		If ExistBlock("DIRA100")
			aCalMov   := ExecBlock("DIRA100",.F.,.F.,{lSeguinte,aQtdeAH7})
			If Len(aCalMov) # 0
				lSeguinte := aCalMov[1]
				aQtdeAH7  := aCalMov[2]
			EndIf
		Endif

		If (Len(aCalMov) == 0)
			If !Empty(SF4->F4_TIPOPER)
				If SF4->F4_TIPOPER $ GetMv("MV_CDAACER",,"")
					aQtdeAH7[8] += SD1->D1_QUANT
					lSeguinte := .T.
				ElseIf SF4->F4_TIPOPER $ GetMv("MV_CDACONS",,"")  // Consignacao
					aQtdeAH7[10] -= SD1->D1_QUANT
					lSeguinte := .T.
				ElseIf SF4->F4_TIPOPER $ GetMv("MV_CDADVCO",,"")  // Devolucao de Venda de Consignacao
					aQtdeAH7[11] += SD1->D1_QUANT
					lSeguinte := .T.
				Else
					aQtdeAH7[2] += SD1->D1_QUANT    // Devolucao de Venda
				Endif
			ElseIf SD1->D1_TES $ GetMv("MV_CDAACER",,"")
				aQtdeAH7[8] += SD1->D1_QUANT
				lSeguinte := .T.
			ElseIf SD1->D1_TES $ GetMv("MV_CDACONS",,"")  // Consignacao
				aQtdeAH7[10] -= SD1->D1_QUANT
				lSeguinte := .T.
			ElseIf SD1->D1_TES $ GetMv("MV_CDADVCO",,"")  // Devolucao de Venda de Consignacao
				aQtdeAH7[11] += SD1->D1_QUANT
				lSeguinte := .T.
			Else
				aQtdeAH7[2] += SD1->D1_QUANT
			Endif
			nAreaAH9 := SELECT("AH9")
			If nAreaAH9 > 0
				lLicitaca := .F.
				dbSelectArea("AH9")
				dbSetOrder(2)   // AH9_FILIAL + DTOS(AH9_DTINIC)
				dbSeek(xFilial("AH9")+DTOS(SD1->D1_DTDIGIT),.T.)
				While AH9->(!Eof()) .And. xFilial("AH9") == AH9->AH9_FILIAL .And. ;
						SD1->D1_DTDIGIT >= 	AH9->AH9_DTINIC .And. ;
						SD1->D1_DTDIGIT <= AH9->AH9_DTFIM
					If SD1->D1_TES $ AH9->AH9_TESLIC
						lLicitaca := .T.
						Exit
					Endif
					dbSelectArea("AH9")
					dbSkip()
				End
	        EndIf
		Endif
	ElseIf cAlias == "SD2"
		If ExistBlock("CDAA101")
			aCalMov   := ExecBlock("CDAA101",.F.,.F.,{lSeguinte,aQtdeAH7})
			If Len(aCalMov) # 0
				lSeguinte := aCalMov[1]
				aQtdeAH7  := aCalMov[2]
			EndIf
		Endif
		
		If (Len(aCalMov) == 0)
		nAreaAH9 := SELECT("AH9")
		If nAreaAH9 > 0
			lLicitaca := .F.
			dbSelectArea("AH9")
			dbSetOrder(2)   // AH9_FILIAL + DTOS(AH9_DTINIC)
			dbSeek(xFilial("AH9")+DTOS(SD2->D2_EMISSAO),.T.)
			While AH9->(!Eof()) .And. xFilial("AH9") == AH9->AH9_FILIAL .And. ;
					SD2->D2_EMISSAO >= 	AH9->AH9_DTINIC .And. ;
					SD2->D2_EMISSAO <= AH9->AH9_DTFIM
				If SD2->D2_TES $ AH9->AH9_TESLIC
					lLicitaca := .T.
					Exit
				Endif
				dbSelectArea("AH9")
				dbSkip()
			End
			If lLicitaca
				aQtdeAH7[12] += SD2->D2_QUANT     // Licitacao

				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifica a data da proxima prestacao de contas.         Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				dbSelectArea("AH6")
				dbSetOrder(1)
				If !CdSeekAH6(xFilial("AH6")+cProduto+cForneced+AH9->AH9_CODLIC)
					RecLock("AH6",.T.)
					AH6->AH6_FILIAL := xFilial("AH6")
					AH6->AH6_PRODUT := cProduto
					AH6->AH6_FORNEC := AH1->AH1_FORNEC
					AH6->AH6_LOJAFO := AH1->AH1_LOJAFO
					AH6->AH6_DTPRXD := CD030DtPrx(CTOD(""),cProduto,cForneced)
					AH6->AH6_LICITA := AH9->AH9_CODLIC

					If (AH6->(FieldPos("AH6_CODANT")) > 0)
						AH6->AH6_CODANT := AH1->AH1_CODANT
					EndIf
					MsUnLock()
				Endif
				
			Endif
		Endif
		If !lLicitaca
			If &cCpoTipo $ GetMv("MV_CDAPROM",,"")      // Promocao
				If SF4->F4_ESTOQUE != "N"      // Somente produtos que atualizam o Estoque
					aQtdeAH7[4] += SD2->D2_QUANT
				EndIf
				lSeguinte := .T.
			ElseIf &cCpoTipo $ GetMv("MV_CDACONS",,"")  // Consignacao
				aQtdeAH7[5] += SD2->D2_QUANT
				lSeguinte := .T.
			ElseIf &cCpoTipo $ GetMv("MV_CDAVEAU",,"")  // Venda Autor
				aQtdeAH7[15] += SD2->D2_QUANT
				lSeguinte := .T.
			ElseIf SD2->D2_TES $ GetMv("MV_CDADOA",,"")  // Doacao
				aQtdeAH7[16] += SD2->D2_QUANT
				lSeguinte := .T.
			ElseIf SD2->D2_TES $ GetMv("MV_CDABONI",,"")  // Bonificacao 
				aQtdeAH7[14] += SD2->D2_QUANT
				If GetMv("MV_CDACBON",,"N") == "N" // Indica se gera DA para Bonificacoes
					lSeguinte := .T.
				EndIf
			ElseIf &cCpoTipo $ GetMv("MV_CDAACER",,"")  // Acertos
				If SF4->F4_ESTOQUE != "N"      // Somente produtos que atualizam o Estoque
					aQtdeAH7[8] -= SD2->D2_QUANT
				EndIf
				lSeguinte := .T.
			Else                                    // Venda
				If !Empty(SF4->F4_TIPOPER)
					If &cCpoTipo $ GetMv("MV_CDAVEND",,"")
						aQtdeAH7[1] += SD2->D2_QUANT
					ElseIf &cCpoTipo $ GetMv("MV_CDAVCON",,"")
						aQtdeAH7[9] += SD2->D2_QUANT
					Else
						lSeguinte :=.T.
					Endif
				Else
					If SF4->F4_ESTOQUE != "N"      // somente produtos que atualizam o estoque
						aQtdeAH7[1] += SD2->D2_QUANT
					EndIF
				Endif
			Endif
		Endif
	  EndIf
	ElseIf cAlias == "SD3"
		If ExistBlock("CDAA102")
			aCalMov   := ExecBlock("CDAA102",.F.,.F.,{lSeguinte,aQtdeAH7})
			If Len(aCalMov) # 0
				lSeguinte := aCalMov[1]
				aQtdeAH7  := aCalMov[2]
			EndIf
		Endif
		
		If (Len(aCalMov) == 0)
		If SD3->D3_DOC == "INVENT"               // Acertos de Inventario
			aQtdeAH7[8] += Iif(Substr(SD3->D3_CF,1,2)=="RE",SD3->D3_QUANT * -1,SD3->D3_QUANT)
		ElseIf SD3->D3_CF == "PR0"               // Producao
			aQtdeAH7[7] += Iif(Substr(SD3->D3_CHAVE,1,1)=="R",SD3->D3_QUANT,SD3->D3_QUANT*-1)
		ElseIf SD3->D3_CF == "RE0" .And. Empty(SD3->D3_OP)  // Perdas
			aQtdeAH7[6] += Iif(Substr(SD3->D3_CF,1,2)=="DE",SD3->D3_QUANT * -1,SD3->D3_QUANT)
		ElseIf Substr(SD3->D3_CF,3,1) == "4"     // Transferencia
			aQtdeAH7[3] += Iif(Substr(SD3->D3_CF,1,2)=="RE",SD3->D3_QUANT * -1,SD3->D3_QUANT)
		ElseIf SD3->D3_CF == "ER0" .Or. SD3->D3_CF == "RE0"
			aQtdeAH7[8] -= SD3->D3_QUANT
		ElseIf Substr(SD3->D3_CF,2,2) == "E6"
			aQtdeAH7[8] += Iif(Substr(SD3->D3_CF,1,2)=="RE",SD3->D3_QUANT * -1,SD3->D3_QUANT)
		Else
			If ExistBlock("DIRA110")
				aQtdeAH7[8] += ExecBlock("DIRA110",.F.,.F.)
			Endif
		Endif
		lSeguinte:=.T.
		nPreco := SD3->D3_CUSTO1 / IIf(SD3->D3_QUANT == 0,1,SD3->D3_QUANT)
	  EndIf
	EndIf
Else
	If cAlias == "SD1"
		If ExistBlock("DIRA120")
			lSeguinte := ExecBlock("DIRA120",.F.,.F.)
		Else
			If !Empty(SF4->F4_TIPOPER)

				// Nao calcula movimento para acertos, consignacao e devolucao de
				// venda de consignacao
				If SF4->F4_TIPOPER $ GetMv("MV_CDAACER",,"") .Or. ;
					SF4->F4_TIPOPER $ GetMv("MV_CDACONS",,"") .Or. ;
					SF4->F4_TIPOPER $ GetMv("MV_CDADVCO",,"")
					lSeguinte := .T.
				Endif
			ElseIf SD1->D1_TES $ GetMv("MV_CDAACER",,"")
				lSeguinte := .T.
			ElseIf SD1->D1_TES $ GetMv("MV_CDACONS",,"")  // Consignacao
				lSeguinte := .T.
			Endif
		Endif
	ElseIf cAlias == "SD2"
		If ExistBlock("CDAA103")
			lSeguinte := ExecBlock("CDAA103",.F.,.F.)
		Else
			If &cCpoTipo $ GetMv("MV_CDAPROM",,"")		// Promocao
				lSeguinte := .T.
			ElseIf &cCpoTipo $ GetMv("MV_CDACONS",,"")	// Consignacao
				lSeguinte := .T.
			ElseIf &cCpoTipo $ GetMv("MV_CDAVEAU",,"")	// Venda Autor
				lSeguinte := .T.
			ElseIf SD2->D2_TES $ GetMv("MV_CDADOA",,"")	// Doacao
				lSeguinte := .T.
			ElseIf &cCpoTipo $ GetMv("MV_CDAACER",,"")	// Acertos
				lSeguinte := .T.
			ElseIf SD2->D2_TES $ GetMv("MV_CDABONI",,"") // Bonificacao
				If GetMv("MV_CDACBON",,"N") == "N" // Indica se gera DA para Bonificacoes
					lSeguinte := .T.
				EndIf
			Else									// Venda
				If !Empty(SF4->F4_TIPOPER)
					If !(&cCpoTipo $ GetMv("MV_CDAVEND",,"")) .And. ;
						!(&cCpoTipo $ GetMv("MV_CDAVCON",,"")) .And. ;
						!(&cCpoTipo $ GetMv("MV_CDAPROM",,""))
						
						lSeguinte := .T.
					Endif
				Endif
			Endif
		EndIf
	ElseIf cAlias == "SD3"
		lSeguinte := .T.
	Endif
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Nao calcula D.A. para Movimentos de Transferencia (03), Promocao (04) Ё
//Ё Consignacao (05), Perdas (06), Producao (07) e Acertos (08).          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lSeguinte
	Return (.F.)
Endif

nQtdAcum2 := nQtdAcum1 + Iif(cAlias=="SD2",SD2->D2_QUANT,SD1->D1_QUANT*-1)
nQtdVenda := Iif(cAlias=="SD2",SD2->D2_QUANT,SD1->D1_QUANT*-1)
lAchouFxa := .F.
                     
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Gera array de regras AH2.                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aRegraAH2 := CD030Array(cProduto+cForneced)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pesquisa qual regra aplicar.                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("AH2")
dbSetOrder(1)
dbSeek(xFilial("AH2")+cProduto+cForneced)

While nQtdVenda != 0
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё lAchouFxa - Verifica se achou alguma faixa que atenda a    Ё
	//Ё             qtde. caso contrario sai do while.             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	lAchouFxa := .F.

	For i := 1 To Len(aRegraAH2)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se a quantidade acumulada esta dentro da faixa.   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

		nQtdAux := nQtdAcum1 + Iif(nQtdVenda > 0,1,0)
		If nQtdAcum1+1 >= aRegraAH2[i][1] .And. nQtdAux <= aRegraAH2[i][2] ;
			.And. aRegraAH2[i][3] <= Iif(cAlias=="SD2",SD2->D2_DESC,SD1->D1_DESC)
			lAchouFxa := .T.
			nI := i
			Exit
		Else

/*/
//    Caso queira fazer em uma unica ocorrencia do produto, habilite este bloco
//    de codigo.
//            If ( nPos := Ascan( aInconsist, { |x| x[ 1 ] == cForneced .and. x[ 2 ] == cProduto } ) ) > 0
//                aInconsist[ nPos, 3 ] += nQtdVenda
//            Else
//                AAdd( aInconsist, { cForneced, cProduto, nQtdVenda } )
//            EndIf
//            AAdd( aInconsist, { cForneced, cProduto, nQtdVenda } )
/*/

		Endif
	Next

	If !lAchouFxa
		nElemen := aScan(aInconsist,{|x| x[1] == cForneced .And. x[2] == cProduto })
		If nElemen == 0
			AAdd(aInconsist,{cForneced,cProduto,nQtdVenda})
		Else
			aInconsist[nElemen][3] += nQtdVenda
		Endif
		Exit
	Endif
	i := nI

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Calcula o preco unitario com base nas regras da faixa.     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If (ExistBlock("CDAA105"))
		nPrecoUn := ExecBlock("CDAA105",.F.,.F.,{cAlias,aRegraAH2})
	Else
		If cAlias == "SD2"
			If aRegraAH2[i][6] == "1"    // preco de capa ou liquido
				nPrecoUn:=Iif( lD2UnDA, SD2->D2_PRUNDA, SD2->D2_PRUNIT )
			Else
				nPrecoUn := SD2->D2_PRCVEN
			Endif
		Else
			If aRegraAH2[i][6] == "1"   // Preco de Capa
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Procura o preco de tabela (capa) no arq. SD2.              Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				aAreaSD2:= SD2->(GetArea())
				dbSelectArea("SD2")
				dbSetOrder(3)  // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD
				If dbSeek(xFilial("SD2")+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD )
					nPrecoUn:=Iif( lD2UnDA, SD2->D2_PRUNDA, SD2->D2_PRUNIT )
				Else
					nPrecoUn:=Iif( lD1UnDA, SD1->D1_PRUNDA, SD1->D1_VUNIT )
				Endif

				If (ExistBlock("CDAPRDEV"))
					nPrecoUn := ExecBlock("CDAPRDEV",.F.,.F.)
				Endif

				RestArea(aAreaSD2)

				dbSelectArea("SD1")
			Else
				nPrecoUn := SD1->D1_VUNIT - Round(SD1->D1_VALDESC / SD1->D1_QUANT,2)            // preco liquido
			Endif
    EndIf
	EndIf

	If cAlias == "SD2"
		nPrecoUn -= Iif(aRegraAH2[i][7]  == "1",Round((nPrecoUn*SD2->D2_DESC)/100,3),0)        // diminui valor de desconto
		nPrecoUn -= Iif(aRegraAH2[i][8]  == "1",Round((SD2->D2_VALICM/SD2->D2_QUANT),3),0)     // diminui valor de ICM
		nPrecoUn -= Iif(aRegraAH2[i][9]  == "1",Round((SD2->D2_VALIPI/SD2->D2_QUANT),3),0)     // diminui valor de IPI
		nPrecoUn -= Iif(aRegraAH2[i][10] == "1",Round((nPrecoUn*GetMV("MV_COFINS1"))/100,3),0)  // diminui valor de PIS/COFINS
		nPrecoUn -= Iif(aRegraAH2[i][11] !=  0 ,Round((nPrecoUn*aRegraAH2[i][11])/100,3),0)    // diminui valor de outro desconto
	Else
		nPrecoUn -= Iif(aRegraAH2[i][7]  == "1",Round((nPrecoUn*SD1->D1_DESC)/100,3),0)        // diminui valor de desconto
		nPrecoUn -= Iif(aRegraAH2[i][8]  == "1",Round((SD1->D1_VALICM/SD1->D1_QUANT),3),0)     // diminui valor de ICM
		nPrecoUn -= Iif(aRegraAH2[i][9]  == "1",Round((SD1->D1_VALIPI/SD1->D1_QUANT),3),0)     // diminui valor de IPI
		nPrecoUn -= Iif(aRegraAH2[i][10] == "1",Round((nPrecoUn*GetMV("MV_COFINS1"))/100,3),0)  // diminui valor de PIS/COFINS
		nPrecoUn -= Iif(aRegraAH2[i][11] !=  0 ,Round((nPrecoUn*aRegraAH2[i][11])/100,3),0)    // diminui valor de outro desconto
	Endif
	If AH1->AH1_MOEDA == "2"    // Moeda Forte
		If ExistBlock("DIRA130")
			nPrecoUn := ExecBlock("DIRA130",.F.,.F.,{nPrecoUn,nMoedaFor})
		Else
			nPrecoUn  := xMoeda(nPrecoUn,1,nMoedaFor,Iif(cAlias == "SD2",SD2->D2_EMISSAO,SD1->D1_EMISSAO))
		Endif
	Endif
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se a qtde. de venda esta tudo em 1 faixa ou mais. Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nQtdAcum2 <= aRegraAH2[i][2] .And. (nQtdAcum1 > aRegraAH2[i][1] .Or. ;
		nQtdVenda > 0)
		nQtdVend2 := nQtdVenda
	Else
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Qtde de venda em mais de uma faixa, o restante passa para  Ё
		//Ё a proxima faixa.                                           Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nQtdVenda > 0
			nQtdVend2 := ((aRegraAH2[i][2] - aRegraAH2[i][1] + 1) - (nQtdAcum1 - aRegraAH2[i][1] + 1))
		Else
			nQtdVend2 := aRegraAH2[i][1] - nQtdAcum1 - 1
			If nQtdVend2 == 0
				nQtdVend2 := nQtdVenda
			Endif
		Endif
	Endif
	nQtdVenda -= nQtdVend2

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Calcula o valor do direito autoral (royalty).           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nDirAutor := 0
	If aRegraAH2[i][4] != 0
		nDirAutor := Round(nQtdVend2 * nPrecoUn * aRegraAH2[i][4] / 100,3)
	ElseIf aRegraAH2[i][5] != 0 
		If lCda030VDA
			nDirAutor := ExecBlock("Cda030VDA", .f., .f., {nQtdVend2, nPrecoUn, aRegraAH2[i][5]})
		Else
			nDirAutor := aRegraAH2[i][5]
		EndIf
	Endif

	If lLicitaca
		nDirAutor := Round(nQtdVend2 * nPrecoUn * AH9->AH9_PERCEN/100,3)
		aRegraAH2[i][4] := AH9->AH9_PERCEN
	Endif
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica a data da proxima prestacao de contas.         Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("AH6")
	dbSetOrder(1)
	If !CdSeekAH6(xFilial("AH6")+cProduto+cForneced)
		RecLock("AH6",.T.)
		AH6->AH6_FILIAL := xFilial("AH6")
		AH6->AH6_PRODUT := cProduto
		AH6->AH6_FORNEC := AH1->AH1_FORNEC
		AH6->AH6_LOJAFO := AH1->AH1_LOJAFO
		AH6->AH6_DTPRXD := CD030DtPrx(CTOD(""),cProduto,cForneced)

		If (AH6->(FieldPos("AH6_CODANT")) > 0)
			AH6->AH6_CODANT := AH1->AH1_CODANT
		EndIf
		MsUnLock()
	Endif
	dPrxPrest := AH6->AH6_DTPRXD     // Proxima prestacao do direito autoral
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava movimentos de royalty.                            Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("AH4")
	dbSetOrder(1)
	If !lLicitaca
		dbSeek(xFilial("AH4")+cProduto+cForneced+DTOS(dPerFim)+Space(Len(AH4->AH4_LICITA)))
	Else
		dbSeek(xFilial("AH4")+cProduto+cForneced+DTOS(dPerFim)+AH9->AH9_CODLIC)
	Endif
	If Eof() .Or. xFilial("AH4")+cProduto+cForneced != ;
		AH4->AH4_FILIAL+AH4->AH4_PRODUT+AH4->AH4_FORNEC+AH4->AH4_LOJAFO .Or. ;
		AH4->AH4_DATCAL != dPerFim

		If AH9->AH9_CODLIC != AH4->AH4_LICITA .Or. Eof()
			RecLock("AH4",.T.)
			AH4->AH4_FILIAL := xFilial("AH4")
			AH4->AH4_PRODUT := cProduto
			AH4->AH4_FORNEC := AH1->AH1_FORNEC
			AH4->AH4_LOJAFO := AH1->AH1_LOJAFO
			AH4->AH4_DATCAL := dPerFim
			AH4->AH4_DTULTI := AH1->AH1_DTULTP

			If lLicitaca
				AH4->AH4_LICITA := AH9->AH9_CODLIC
			Endif
	
			If (AH4->(FieldPos("AH4_CODANT")) > 0)
				AH4->AH4_CODANT := AH1->AH1_CODANT
			EndIf
		Else
			RecLock("AH4",.F.)
		Endif
	Else
		RecLock("AH4",.F.)
	Endif
	AH4->AH4_QTDACU += nQtdVend2
	AH4->AH4_VALACU += (nQtdVend2 * nPrecoUn)
	AH4->AH4_VALORD += nDirAutor
	AH4->AH4_DTPRES := Iif(!lLicitaca,dPrxPrest,LastDay(AH9->AH9_DTFIM))
	AH4->AH4_VALADI := AH1->AH1_SALDOA
	MsUnLock()
	
	cPrecoUn := Str(nPrecoUn,14,3)
	lAppend  := .F.
	dbSelectArea("AH5")
	If !lLicitaca
		dbSeek(xFilial("AH5")+cProduto+cForneced+DTOS(dPerFim)+Str(aRegraAH2[i][2],9)+cPrecoUn)
	Else
		dbSetOrder(4)   // AH5_FILIAL+AH5_PRODUT+AH5_FORNEC+AH5_LOJAFO+AH5_LICITA+DTOS(AH5_DATCAL)+Str(AH5_FXFINA,9)
		dbSeek(xFilial("AH5")+cProduto+cForneced+AH9->AH9_CODLIC+DTOS(dPerFim)+Str(aRegraAH2[i][2],9))
	Endif
	If AH5->(Eof())
		lAppend := .T.
	Else
		While xFilial("AH5")+cProduto+cForneced+DTOS(dPerFim)+Str(aRegraAH2[i][2],9)+;
				cPrecoUn == AH5->AH5_FILIAL+AH5->AH5_PRODUT+AH5->AH5_FORNEC+;
				AH5->AH5_LOJAFO+DTOS(AH5->AH5_DATCAL)+Str(AH5->AH5_FXFINA,9)+;
				Str(AH5->AH5_PRECOU,14,3) .And. cAlias == "SD1"
			If AH5->AH5_QTDACU < 0
				lAppend := .F.
				Exit
			Endif
			lAppend := .T.
			dbSkip()
		End
		While xFilial("AH5")+cProduto+cForneced+DTOS(dPerFim)+Str(aRegraAH2[i][2],9)+;
				cPrecoUn == AH5->AH5_FILIAL+AH5->AH5_PRODUT+AH5->AH5_FORNEC+;
				AH5->AH5_LOJAFO+DTOS(AH5->AH5_DATCAL)+Str(AH5->AH5_FXFINA,9)+;
				Str(AH5->AH5_PRECOU,14,3) .And. cAlias == "SD2"
			If AH5->AH5_QTDACU > 0
				lAppend := .F.
				Exit
			Endif
			lAppend := .T.
			dbSkip()
		End
	Endif
	If lAppend
		RecLock("AH5",.T.)
		AH5->AH5_FILIAL := xFilial("AH5")
		AH5->AH5_PRODUT := cProduto
		AH5->AH5_FORNEC := AH1->AH1_FORNEC
		AH5->AH5_LOJAFO := AH1->AH1_LOJAFO
   		AH5->AH5_FXFINA := aRegraAH2[i][2]
		AH5->AH5_PRECOU := nPrecoUn
		AH5->AH5_DATCAL := dPerFim
		If lLicitaca
			AH5->AH5_LICITA := AH9->AH9_CODLIC
		Endif

		If (AH5->(FieldPos("AH5_CODANT")) > 0)
			AH5->AH5_CODANT := AH1->AH1_CODANT
		EndIf
	Else
		RecLock("AH5",.F.)
	Endif
	
	AH5->AH5_QTDACU += nQtdVend2
	AH5->AH5_BASEDA += (nQtdVend2 * nPrecoUn)
	AH5->AH5_VALORD += nDirAutor
	AH5->AH5_PERCDA := aRegraAH2[i][4]
	AH5->AH5_DTPRES := Iif(!lLicitaca,dPrxPrest,LastDay(AH9->AH9_DTFIM))
	MsUnLock()

	nQtdAcum1 += nQtdVend2
	
	If ExistBlock("DIRA140")
		ExecBlock("DIRA140",.F.,.F.,{nDirAutor,cAlias})
	Endif
End

If !lAchouFxa
	nQtdAcum1 := nQtdAcum2
Endif

Return (.T.)


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    ЁCD030GrAH7Ё Autor Ё Cristiano G. Cunha    Ё Data Ё 05/07/02 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Grava dados no arquivo AH7.                                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё CD030GrAH7(ExpD1,ExpD2)                                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpD1 - Data inicial do periodo a ser calculado            Ё╠╠
╠╠Ё          Ё ExpD2 - Data final do periodo a ser calculado              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё CDAA030                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function CD030GrAH7(dPerIni,dPerFim,cProduto)
Local nSaldoIni := 0
Local nSaldoFim := 0
Local nDiferenc := 0
Local aRetSaldo := {}
Local aSaldo
Local aAreaAH1  := {}

If ExistBlock("DIRA090")
	aRetSaldo := ExecBlock("DIRA090",.F.,.F.,{cProduto,dPerIni,dPerFim})
	nSaldoIni := aRetSaldo[1]
	nSaldoFim := aRetSaldo[2]
Else
	dbSelectArea("SB2")
	dbSetOrder(1)
	dbSeek(xFilial("SB2")+cProduto)
	While SB2->(!Eof()) .And. xFilial("SB2")+cProduto == SB2->B2_FILIAL+SB2->B2_COD
		aSaldo    := CalcEst(SB2->B2_COD,SB2->B2_Local,dPerIni)
		nSaldoIni += aSaldo[1]
		aSaldo    := CalcEst(SB2->B2_COD,SB2->B2_Local,dPerFim+1)
		nSaldoFim += aSaldo[1]
		dbSkip()
	End
Endif

dbSelectArea("AH7")
dbSetOrder(1)    // AH7_FILIAL + AH7_PRODUT + DTOS(AH7_DATCAL)
If !dbSeek(xFilial("AH7")+AH1->AH1_PRODUT+DTOS(dPerFim))
	RecLock("AH7",.T.)
	AH7->AH7_FILIAL := xFilial("AH7")
	AH7->AH7_PRODUT := cProduto
	AH7->AH7_DATCAL := dPerFim

	If (AH7->(FieldPos("AH7_CODANT")) > 0)
		aAreaAH1:= AH1->(GetArea())

		dbSelectArea("AH1")
		dbSetOrder(1)
		If dbSeek(xFilial("AH1")+cProduto)
			cCodAnt := AH1->AH1_CODANT
		EndIf
		
		RestArea(aAreaAH1)

		dbSelectArea("AH7")
		AH7->AH7_CODANT := cCodAnt
	EndIf
Else
	RecLock("AH7",.F.)
Endif

AH7->AH7_VENDAS += aQtdeAH7[1]    // Venda
AH7->AH7_DEVOLU += aQtdeAH7[2]    // Devolucao
AH7->AH7_TRANSF += aQtdeAH7[3]    // Transferencia
AH7->AH7_PROMOC += aQtdeAH7[4]    // Promocao
AH7->AH7_CONSIG += aQtdeAH7[5]    // Consignacao
AH7->AH7_PERDAS += aQtdeAH7[6]    // Perdas
AH7->AH7_PRODUC += aQtdeAH7[7]    // Producao
AH7->AH7_ACERTO += aQtdeAH7[8]    // Acertos
AH7->AH7_VDACON += aQtdeAH7[9]    // Venda de Consignacao
AH7->AH7_DEVCON += aQtdeAH7[10]   // Devolucao de consignacao
AH7->AH7_DVVDCO += aQtdeAH7[11]+aQtdeAH7[13]   // Devolucao de venda de consignacao
If AH7->(FieldPos("AH7_BONIFI")) > 0
	AH7->AH7_BONIFI += aQtdeAH7[14]    // Bonificacao
EndIf
If AH7->(FieldPos("AH7_VENDAU")) > 0
	AH7->AH7_VENDAU += aQtdeAH7[15]    // Venda Autor
EndIf
If AH7->(FieldPos("AH7_DOACAO")) > 0
	AH7->AH7_DOACAO += aQtdeAH7[16]    // Doacao
EndIf
AH7->AH7_SALDIN := nSaldoIni
AH7->AH7_SALDFI := nSaldoFim
If lLicitaca
	AH7->AH7_LICITA += aQtdeAH7[12]  // Licitacao
Endif
MsUnLock()

nDiferenc := nSaldoIni - nSaldoFim - AH7->AH7_VENDAS + AH7->AH7_DEVOLU
nDiferenc := nDiferenc + AH7->AH7_TRANSF - AH7->AH7_PROMOC - AH7->AH7_PERDAS
nDiferenc := nDiferenc + AH7->AH7_PRODUC + AH7->AH7_ACERTO - AH7->AH7_CONSIG
nDiferenc := nDiferenc + AH7->AH7_DEVCON + Iif(AH7->(FieldPos("AH7_BONIFI"))>0,AH7->AH7_BONIFI,0) +Iif(AH7->(FieldPos("AH7_VENDAU"))>0,AH7->AH7_VENDAU,0) 

If nDiferenc != 0
	If ExistBlock("DIRA150")
		aInconsist := ExecBlock("DIRA150",.F.,.F.,{aInconsist,nDiferenc,cProduto,aQtdeAH7[13]})
	EndIf
Endif

Return (.T.)

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    ЁCD030ProcTopЁ Autor Ё Cristiano G. Cunha  Ё Data Ё 05/07/02 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Processamento - Calculo do Direito Autoral (Royalty) - TOP Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё CDAA030                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function CD030ProcTOP()
Local dPerIni 
Local dPerFim
Local dData
Local aArea      := GetArea()
Local cQuery     := ""
Local cPrdMaster := ""
Local cForneced  := ""
Local cProduto   := ""
Local cOrdem     := ""
//Local nQtdAcSB1  := 0
Local nSldAdian  := 0
Local nAreaAHA   := 0
Local nElemen    := 0
Local nI		 := 0
Local nSaldoIni  := 0
Local nSaldoFim  := 0
Local lFirst     := .T.
Local lRet       := .T.
Local lProdFirst := .F.
Local aPrdMaster := {}
Local aProdForne := {}
Local aRetSaldo  := {}
Local aProdPesq := {}
Local cFilIni 		:= Iif(Empty(MV_PAR02),cFilAnt,MV_PAR02)
Local cFilFin 		:= Iif(Empty(MV_PAR03),cFilAnt,MV_PAR03) 
Local cFilOri		:= IIf( lFWCodFil , FWGETCODFILIAL, SM0->M0_CODFIL )
Local aSM0			:= AdmAbreSM0()
Local nContFil		:= 0     
Private aInd     := {}  // array com nomes dos indices temporarios
Private aQtdeAH7 := Array(16)
Private lCalcAH7 := .T.
Private nQtdAcSB1  := 0  

AFILL( aQtdeAH7,0,1,16 )

lLicitaca := .F.

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Periodo de processamento, do dia 01 do mes e ano informados  Ё
//Ё ate o ultimo dia do mes.                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dPerIni := CTOD("01/"+StrZero(Month(mv_par01),2)+"/"+Str(Year(mv_par01)))
dPerFim := LastDay(dPerini)

If dPerFim <= GetMv("MV_CDAFECH")
	Help(" ",1,"CD030DtInv")
	Return (.F.)
Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ponto de entrada que verifica se deve ou processar o calculo.Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lRet := .T.
If (ExistBlock("CDA030A"))
	lRet := ExecBlock("CDA030A",.F.,.F.)
	If !lRet
		Return lRet
	Endif
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle por filial.                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nContFil := 1 to Len(aSM0)
	If aSM0[nContFil][SM0_CODFIL] < cFilIni .Or. aSM0[nContFil][SM0_CODFIL] > cFilFin .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt  
		Loop
	EndIf
	 
	cFilAnt := aSM0[nContFil][SM0_CODFIL]				
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Apaga os registros de apuracao do periodo.                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If (ExistBlock("CDAA104"))
		ExecBlock("CDAA104",.F.,.F., {dPerIni, dPerFim})
	Else
		CD030DelDA(dPerIni,dPerFim)
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Cria um SELECT para agilizar o calculo em TOP.               Ё
	//Ё O SELECT ┌ criado no SD2, SD1 e SD3 e o calculo ┌ feito com  Ё
	//Ё base nesse SELECT, para depois ir para o arquivo de Amarra-  Ё
	//Ё cao Livro x Autor.                                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cQuery:=""
	
	If Empty(cQuery)
		cQuery := "Select SD2.D2_FILIAL FILIAL, SD2.D2_COD     PRODUTO, "
		cQuery +=         "SD2.D2_EMISSAO DATAEMI, "
		cQuery +=         "'1 SD2'        ORDEM, "
		cQuery +=         "' '            EMISSAO, "
		cQuery +=         "SD2.D2_QUANT   QUANT, "
		cQuery +=         "SD2.D2_TES     TES, "
		cQuery +=         "SD2.D2_PRUNIT  PRUNIT, "
		cQuery +=         "SD2.D2_PRCVEN  PRCVEN, "
		cQuery +=         "SD2.D2_DESC    DESCO, "
		cQuery +=         "SD2.D2_DESCON  VALDESC, "
		cQuery +=         "SD2.D2_VALICM  VALICM, "
		cQuery +=         "SD2.D2_VALIPI  VALIPI, "
		cQuery +=         "SD2.D2_CF      CF, "
		cQuery +=         "SD2.D2_DOC     DOC, "
		cQuery +=         "SD2.D2_SERIE   SERIE, "
		cQuery +=         "SD2.D2_ITEM	  ITEM, "
		cQuery +=         "' '			  NFORI, "
		cQuery +=         "' ' 			  SERIORI, "
		cQuery +=         "' ' 			  ITEMORI, "
		cQuery +=         "SD2.D2_CLIENTE CLIENTE, "
		cQuery +=         "SD2.D2_LOJA    LOJA, "
		cQuery +=         "' '   		  OP, "
		cQuery +=         "' '            CHAVE "
		cQuery += "From " + RetSQLName("SD2") + " SD2 "
		cQuery += "Where   SD2.D2_FILIAL='"+xFILIAL("SD2")+"' AND SD2.D2_EMISSAO BETWEEN '"+ Dtos(dPerIni) + "'"
		cQuery += "  And '" + Dtos(dPerFim) + "'"
		cQuery += "  And SD2.D2_TIPO <> 'D'"
		cQuery += "  And SD2.D2_COD IN (SELECT AH1_PRODUT FROM " + RetSQLName("AH1")+") "
		cQuery += "  And SD2.D_E_L_E_T_ <> '*' "
		cQuery += " Union All "
		
		cQuery += "Select  SD1.D1_FILIAL FILIAL,SD1.D1_COD     PRODUTO, "
		cQuery +=         "SD1.D1_DTDIGIT DATAEMI, "
		cQuery +=         "'2 SD1'        ORDEM, "
		cQuery +=         "SD1.D1_EMISSAO EMISSAO, "
		cQuery +=         "SD1.D1_QUANT   QUANT, "
		cQuery +=         "SD1.D1_TES     TES, "
		cQuery +=         "SD1.D1_VUNIT   PRUNIT, "
		cQuery +=         "SD1.D1_VUNIT   PRCVEN, "
		cQuery +=         "SD1.D1_DESC    DESCO, "
		cQuery +=         "SD1.D1_VALDESC VALDESC, "
		cQuery +=         "SD1.D1_VALICM  VALICM, "
		cQuery +=         "SD1.D1_VALIPI  VALIPI, "
		cQuery +=         "SD1.D1_CF      CF, "
		cQuery +=         "SD1.D1_DOC     DOC, "
		cQuery +=         "SD1.D1_SERIE   SERIE, "
		cQuery +=         "SD1.D1_ITEM	  ITEM, "
		cQuery +=         "SD1.D1_NFORI   NFORI, "
		cQuery +=         "SD1.D1_SERIORI SERIORI, "
		cQuery +=         "SD1.D1_ITEMORI ITEMORI, "
		cQuery +=         "SD1.D1_FORNECE CLIENTE, "
		cQuery +=         "SD1.D1_LOJA    LOJA, "
		cQuery +=         "' '			  OP, "
		cQuery +=         "' '            CHAVE "
		cQuery += "From " + RetSQLName("SD1") + " SD1 "
		cQuery += "Where   SD1.D1_FILIAL='" +xFILIAL("SD1")+ "' AND SD1.D1_DTDIGIT BETWEEN '" + Dtos(dPerIni) + "'"
		cQuery += "  And   '" + Dtos(dPerFim) + "'"
		cQuery += "  And (SD1.D1_TIPO = 'B' OR SD1.D1_TIPO = 'D')"
		cQuery += "  And SD1.D1_COD IN (SELECT AH1_PRODUT FROM " + RetSQLName("AH1")+") "
		cQuery += "  And SD1.D1_TES <> ''"
		cQuery += "  And SD1.D_E_L_E_T_ <> '*' "
		cQuery += " Union All "
		
		cQuery += "Select  SD3.D3_FILIAL,SD3.D3_COD     PRODUTO, "
		cQuery +=         "SD3.D3_EMISSAO DATAEMI, "
		cQuery +=         "'3 SD3'        ORDEM, "
		cQuery +=         "' '            EMISSAO, "
		cQuery +=         "SD3.D3_QUANT   QUANT, "
		cQuery +=         "' '            TES, "
		cQuery +=         "SD3.D3_CUSTO1  PRUNIT, "
		cQuery +=         "0              PRCVEN, "
		cQuery +=         "0              DESCO, "
		cQuery +=         "0              VALDESC, "
		cQuery +=         "0              VALICM, "
		cQuery +=         "0              VALIPI, "
		cQuery +=         "SD3.D3_CF      CF, "
		cQuery +=         "SD3.D3_DOC     DOC, "
		cQuery +=         "' '	 		  SERIE, "
		cQuery +=         "' '			  ITEM, "
		cQuery +=         "' '			  NFORI, "
		cQuery +=         "' ' 			  SERIORI, "
		cQuery +=         "' ' 			  ITEMORI, "
		cQuery +=         "' '			  CLIENTE, "
		cQuery +=         "' '			  LOJA, "
		cQuery +=         "SD3.D3_OP      OP, "
		cQuery +=         "SD3.D3_CHAVE   CHAVE "
		cQuery += "From " + RetSQLName("SD3") + " SD3 "
		cQuery += "Where SD3.D3_FILIAL='" +xFILIAL("SD3")+ "' AND SD3.D3_EMISSAO BETWEEN '" + Dtos(dPerIni) + "'"
		cQuery += "  And '" + Dtos(dPerFim) + "'"
		cQuery += "  And SD3.D3_COD IN (SELECT AH1_PRODUT FROM " + RetSQLName("AH1")+") "
		cQuery += "  And SD3.D_E_L_E_T_ <> '*' "
		cQuery += "Order By ORDEM"
	Endif
	
	If (ExistBlock("DIRA160"))
	  	cQuery := ExecBlock("DIRA160",.F.,.F.,{dPerIni,dPerFim,cQuery})
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T.,"TOPCONN",TCGENQRY(,,cQuery),"TRB",.F.,.T.)
	dbSelectArea("TRB")
	dbGoTop()
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicializa a regua de processamento.                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	ProcRegua(TRB->(RecCount()))
	
	lFirst := .T.
	
	dbSelectArea("AH4")
	dbSetOrder(1)     // AH4_FILIAL+AH4_PRODUT+AH4_FORNEC+AH4_LOJAFO+DTOS(AH4_DATCAL)+AH4_LICITA
	
	dbSelectArea("AH5")
	dbSetOrder(1)     // AH5_FILIAL+AH5_PRODUT+AH5_FORNEC+AH5_LOJAFO+DTOS(AH5_DATCAL)+Str(AH5_FXFINA,9)+Str(AH5_PRECOU,14,3)
	
	dbSelectArea("AH6")
	dbSetOrder(1)     // AH6_FILIAL+AH6_PRODUT+AH6_FORNEC+AH6_LOJAFO
	
	dbSelectArea("AH1")
	dbSetOrder(1)     // AH1_FILIAL+AH1_PRODUT+AH1_FORNEC+AH1_LOJAFO
	
	dbSelectArea("TRB")
	
	nQtdAcSB1 := 0
	lCalcAH7  := .T.
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Calculo do direito autoral (royalty).                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	While TRB->(!Eof())
	
		dbSelectArea("TRB")
		cProduto := TRB->PRODUTO
		aProdForne := {}
		
		While !Eof() .And. cProduto == TRB->PRODUTO
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Calcula por data dentro do mes.                              Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			dData := TRB->DATAEMI
			While !Eof() .And. dData == TRB->DATAEMI .And. cProduto == TRB->PRODUTO
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Calcula na seguinte ordem SD2, SD1 e SD3.                    Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				cOrdem := TRB->ORDEM
				While !Eof() .And. cOrdem == TRB->ORDEM .And. dData == TRB->DATAEMI .And. ;
									cProduto == TRB->PRODUTO
					If lFirst
						IncProc(STR0006) //"Calculando Direito Autoral ..."
						lFirst := .F.
					Else
						IncProc()
					EndIf
					
					dbSelectArea("AH1")
					dbSetOrder(1)
					dbSeek(xFilial("AH1")+ cProduto)
					lCalcAH7   := .F.
					lProdFirst := .T.
					While !Eof() .And. xFilial("AH1")+cProduto == AH1->AH1_FILIAL+AH1->AH1_PRODUT
						cForneced  := AH1->AH1_FORNEC + AH1->AH1_LOJAFO
						cPrdMaster := AH1->AH1_MASTER
	
						AH8->(dbSetOrder(1))
						AH8->(dbSeek(xFilial("AH8")+cPrdMaster))
	
						While !Eof() .And. xFilial("AH1")+cProduto == AH1->AH1_FILIAL+AH1->AH1_PRODUT .And.;
											cForneced == AH1->AH1_FORNEC + AH1->AH1_LOJAFO
	
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Verifica se gera prestacao de contas ou nao.                 Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							SA2->(dbSetOrder(1))
							SA2->(dbSeek(xFilial("SA2")+AH1->AH1_FORNEC+AH1->AH1_LOJAFO))
							If SA2->A2_PAGAMEN == "1"   // Nao recebe pagamento, somente o relatorio.
								dbSelectArea("AH1")
								dbSkip()
								Loop
							EndIf
						
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Verifica se o periodo esta dentro do mes de calculo.         Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							If AH1->AH1_INICVI > dPerFim .Or. (dPerFim > AH1->AH1_DATAFI ;
								.And. !Empty(AH1->AH1_DATAFI))
								dbSelectArea("AH1")
								dbSkip()
								Loop
							EndIf
	
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Calcula o adiantamento inicial da amarracao.           Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							If aScan(aProdForne,cProduto+cForneced ) == 0
								nSldAdian := AH1->AH1_SALDOA + AH1->AH1_SALDQT
								dbSelectArea("AHF")
								If dbSeek(xFilial("AHF")+cForneced)
									nSldAdian := AHF->AHF_SALDOA + AHF->AHF_SALDQT
								EndIf
	
								dbSelectArea("AH1")
								If nSldAdian > 0
									CD030Adian(cProduto,cForneced)
								EndIf
								Aadd(aProdForne,cProduto+cForneced)
							EndIf
							
							//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Verifica a data da proxima prestacao de contas.         Ё
							//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							dbSelectArea("AH6")
							dbSetOrder(1)
							If !CdSeekAH6(xFilial("AH6")+cProduto+cForneced)
								RecLock("AH6",.T.)
								AH6->AH6_FILIAL := xFilial("AH6")
								AH6->AH6_PRODUT := cProduto
								AH6->AH6_FORNEC := AH1->AH1_FORNEC
								AH6->AH6_LOJAFO := AH1->AH1_LOJAFO
								AH6->AH6_DTPRXD := CD030DtPrx(CTOD(""),cProduto,cForneced)
	
								If (AH6->(FieldPos("AH6_CODANT")) > 0)
									AH6->AH6_CODANT := AH1->AH1_CODANT
								EndIf
								MsUnLock()
							EndIf
	
							dbSelectArea("AH8")
							dbSetOrder(1)
							dbSeek(xFilial("AH8") + cPrdMaster)
							
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Calcula o direito autoral e retorno da qtde do produto.Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							nQtdAcSB1 := 0
							nQtdAcSB1 := CD030CalTOP(cProduto,cForneced,dPerIni,dPerFim)
							lCalcAH7  := .T.
	 
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Pesquisa no array o produto master diferente do produto.     Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							If cProduto != cPrdMaster
								nElement := aScan(aPrdMaster,{|x| x == cPrdMaster})
								If nElement == 0
									aAdd(aPrdMaster,cPrdMaster)
								EndIf
							EndIf
							dbSelectArea("AH8")
							dbSetOrder(1)
							If dbSeek(xFilial("AH8")+cPrdMaster) .And. lProdFirst
								RecLock("AH8",.F.)
								Ah8->AH8_QTDACU += nQtdAcSB1
								MsUnLock()
							EndIf
							dbSelectArea("AH1")
							dbSkip()
						End
						lProdFirst := .F.					
					End
					aAdd(aProdPesq, TRB->PRODUTO)
					dbSelectArea("TRB")
					dbSkip()
				End
			End
		End
			
		nSaldoIni := 0
		nSaldoFim := 0             
		If (ExistBlock("DIRA090"))
			aRetSaldo := ExecBlock("DIRA090",.F.,.F.,{cProduto,dPerIni,dPerFim})
			nSaldoIni := aRetSaldo[1]
			nSaldoFim := aRetSaldo[2]
		Endif
		If Len(aRetSaldo) == 0
		 	nSaldoIni := 0
			nSaldoFim := 0
			dbSelectArea("SB2")
			dbSetOrder(1)
			dbSeek(xFilial("SB2")+cProduto)
			While SB2->(!Eof()) .And. xFilial("SB2")+cProduto == SB2->B2_FILIAL + SB2->B2_COD
				aSaldo    := CalcEst(SB2->B2_COD,SB2->B2_Local,dPerIni)
				nSaldoIni += aSaldo[1]
				aSaldo    := CalcEst(SB2->B2_COD,SB2->B2_Local,dPerFim)
				nSaldoFim += aSaldo[1]
				dbSkip()
			End
		Endif		
	
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava dados no AH7 - qtdes acumuladas no mes.          Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lCalcAH7
			CD030GrAH7(dPerIni,dPerFim,cProduto)
			aQtdeAH7 := Array(16)
			AFILL(aQtdeAH7,0,1,16)
		EndIf
	End
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verificar o arquivo AH1 e AH6. Mesmo que nao haja      Ё
	//Ё movimento e necessario criar o AH6.                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("AH1")
	dbSeek(xFilial())
	While AH1->(!Eof()) .And. xFilial("AH1")==AH1->AH1_FILIAL
		If aScan(aProdPesq, { |x| x== AH1->AH1_PRODUTO}) == 0
			nSaldoIni := 0
			nSaldoFim := 0             
			If (ExistBlock("DIRA090"))
				aRetSaldo := ExecBlock("DIRA090",.F.,.F.,{AH1->AH1_PRODUTO,dPerIni,dPerFim})
				nSaldoIni := aRetSaldo[1]
				nSaldoFim := aRetSaldo[2]
			Endif
			
			If Len(aRetSaldo) == 0
			 	nSaldoIni := 0
				nSaldoFim := 0
				dbSelectArea("SB2")
				dbSetOrder(1)
				dbSeek(xFilial("SB2")+AH1->AH1_PRODUTO)
				While SB2->(!Eof()) .And. xFilial("SB2")+AH1->AH1_PRODUTO == SB2->B2_FILIAL + SB2->B2_COD
					aSaldo    := CalcEst(SB2->B2_COD,SB2->B2_Local,dPerIni)
					nSaldoIni += aSaldo[1]
					aSaldo    := CalcEst(SB2->B2_COD,SB2->B2_Local,dPerFim)
					nSaldoFim += aSaldo[1]
					dbSkip()
				End
			EndIf
				
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava dados no AH7 - qtdes acumuladas no mes.          Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		
			aQtdeAH7 := Array(16)
			aFill(aQtdeAH7,0,1,16)
			CD030GrAH7(dPerIni,dPerFim,AH1->AH1_PRODUTO)
		EndIf
	
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Calcula um produto (livro) por vez.                          Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cProduto  := AH1->AH1_PRODUT
		cForneced := AH1->AH1_FORNEC + AH1->AH1_LOJAFO
	
		SA2->(dbSetOrder(1))
		SA2->(dbSeek(xFilial("SA2")+AH1->AH1_FORNEC+AH1->AH1_LOJAFO))
		If SA2->A2_PAGAMEN == "1"   // nao recebe pagamento, somente o relatorio.
			dbSelectArea("AH1")
			dbSkip()
			Loop
		Endif
			
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se o periodo esta dentro do mes de calculo.         Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If AH1->AH1_INICVI > dPerFim .Or. (dPerFim > AH1->AH1_DATAFI ;
			.And. !Empty(AH1->AH1_DATAFI))
			dbSelectArea("AH1")
			dbSkip()
			Loop
		Endif
	
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica a data da proxima prestacao de contas.         Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		dbSelectArea("AH6")
		dbSetOrder(1)
		If !CdSeekAH6(xFilial("AH6")+cProduto+cForneced)
			RecLock("AH6",.T.)
			AH6->AH6_FILIAL := xFilial("AH6")
			AH6->AH6_PRODUT := cProduto
			AH6->AH6_FORNEC := AH1->AH1_FORNEC
			AH6->AH6_LOJAFO := AH1->AH1_LOJAFO
			AH6->AH6_DTPRXD := CD030DtPrx(CTOD(""),cProduto,cForneced)
			If (AH6->(FieldPos("AH6_CODANT")) > 0)
				AH6->AH6_CODANT := AH1->AH1_CODANT
			EndIf
			MsUnLock()
		EndIf
	    dbSelectArea("AH1")
	    dbSkip()
	End
	
	dbSelectArea("AH4")
	dbSetOrder(1)
	
	dbSelectArea("AH5")
	dbSetOrder(1)
	
	dbSelectArea("SD1")
	RetIndex("SD1")
	DbClearFilter()
	
	dbSelectArea("SD2")
	RetIndex("SD2")
	DbClearFilter()
	
	dbSelectArea("SD3")
	RetIndex("SD3")
	DbClearFilter()
	If Len(aInd) > 0
		For nI := 1 To Len(aInd)
			If File(aInd[nI]+OrdBagExt())
				FErase(aInd[nI]+OrdBagExt())
			Endif
		Next
	Endif
	
	dbSelectArea("TRB") 
	
	dbCloseArea()
	
Next nContFil

RestArea(aArea)  

//здддддддддддддддддддддддддддддддддддддддддд©
//ЁVolta a empresa anteriormente selecionada.Ё
//юдддддддддддддддддддддддддддддддддддддддддды
cFilAnt := cFilOri

Return


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    ЁCD030CalTopЁ Autor Ё Cristiano G. Cunha   Ё Data Ё 05/07/02 Ё╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Calcula o direito autoral em moeda Corrente ou Forte (TOP) Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё CD030CalTOP(ExpC1,ExpC2,ExpD1,ExpD2)                       Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ ExpC1 - Codigo do Produto                                  Ё╠╠
╠╠Ё          Ё ExpC2 - Codigo e Loja do Fornecedor                        Ё╠╠
╠╠Ё          Ё ExpD1 - Data inicial do periodo                            Ё╠╠
╠╠Ё          Ё ExpD2 - Data final do periodo                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё CDAA030                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function CD030CalTOP(cProduto,cForneced,dPerIni,dPerFim)
Local dDataCal
Local dPrxPrest
Local nPrecoUn 		:= 0
Local lSeguinte		:= .F.
Local lAppend  		:= .F.
Local nQtdAuxil		:= 0
//Local nQtdAcum1:= 0
Local nQtdAcum2		:= 0
Local nQtdVenda		:= 0
Local nQtdVend2		:= 0
Local nDirAutor		:= 0
Local nElemen  		:= 0
Local nI       		:= 0
Local i        		:= 0
Local lAchouFxa		:= .F. 
Local nMoedaFor		:= Val(GetMv("MV_MCUSTO"))
Local aAreaAH2 		:= {}
Local aRegraAH2		:= {}
Local aAreaSD2 		:= {}
Local aCalMov  		:= {}
Local cCpoTipo 		:= ""
Local cAlias   		:= ""
Local cPrecoUn 		:= ""
Local lMV_CDAPRCP	:= SuperGetMV( "MV_CDAPRCP", .F., .F. )
Local lD1UnDA		:= SD1->( FieldPos( "D1_PRUNDA" ) ) > 0 .AND. lMV_CDAPRCP
Local lD2UnDA		:= SD2->( FieldPos( "D2_PRUNDA" ) ) > 0 .AND. lMV_CDAPRCP  
Local nValBruto   := 0 //Valor bruto para calculo do PIS/COFINS na geracao do Royalty (DA)
Local lCda030VDA  := ExistBlock("Cda030VDA")

//Private nQtdAcum1 := 0
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Codigos de origem de movimento:                              Ё
//Ё 01 - Venda                                                   Ё
//Ё 02 - Devolucao                                               Ё
//Ё 03 - Transferencia                                           Ё
//Ё 04 - Promocao                                                Ё
//Ё 05 - Consignacao                                             Ё
//Ё 06 - Perdas                                                  Ё
//Ё 07 - Producao                                                Ё
//Ё 08 - Acertos                                                 Ё
//Ё 09 - Venda de Consignacao                                    Ё
//Ё 10 - Retorno de Consignacao                                  Ё
//Ё 11 - Devolucao de Venda de Consignacao                       Ё
//Ё 12 - Licitacao                                               Ё
//Ё 13 - Dev. de Venda de Consignacao - com Estoque              Ё
//Ё 14 - Bonificacao                                             Ё
//Ё 15 - Venda Autor                                             Ё
//Ё 16 - Doacao                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

nQtdAcum1 := AH8->AH8_QTDACU

SF4->(dbSetOrder(1))
SF4->( dbSeek( xFilial("SF4") + TRB->TES ) )
cCpoTipo := IIf(Empty(SF4->F4_TIPOPER),"TRB->TES","SF4->F4_TIPOPER")

cAlias := Substr(TRB->ORDEM,3,3)
lSeguinte := .F.
lLicitaca := .F.
If !lCalcAH7
	If cAlias == "SD1"
		If (ExistBlock("DIRA100"))
        	 aCalMov   := ExecBlock("DIRA100",.F.,.F.,{lSeguinte,aQtdeAH7})
			If Len(aCalMov) # 0
	         lSeguinte := aCalMov[1]
	         aQtdeAH7  := aCalMov[2]
			EndIf
		Endif
      	If Len(aCalMov) == 0
			If !Empty(SF4->F4_TIPOPER)
				If SF4->F4_TIPOPER $ GetMv("MV_CDAACER",,"")
					aQtdeAH7[8]  += TRB->QUANT
					lSeguinte    := .T.
				ElseIf SF4->F4_TIPOPER $ GetMv("MV_CDACONS",,"")  // Consignacao
					aQtdeAH7[10] -= TRB->QUANT
					lSeguinte    := .T.
				ElseIf SF4->F4_TIPOPER $ GetMv("MV_CDADVCO",,"")  // Devolucao de Venda de Consignacao
					aQtdeAH7[11] += TRB->QUANT
					lSeguinte    := .T.
				Else
					aQtdeAH7[2] += TRB->QUANT    // Devolucao de Venda
				EndIf
			ElseIf TRB->TES $ GetMv("MV_CDAACER",,"")
				aQtdeAH7[8]  += TRB->QUANT
				lSeguinte    := .T.
			ElseIf TRB->TES $ GetMv("MV_CDACONS",,"")  // Consignacao
				aQtdeAH7[10] -= TRB->QUANT
				lSeguinte    := .T.
			ElseIf TRB->TES $ GetMv("MV_CDADVCO",,"")  // Devolucao de Venda de Consignacao
				aQtdeAH7[11] += TRB->QUANT
				lSeguinte    := .T.
			Else
				If SF4->F4_ESTOQUE != 'N'
					aQtdeAH7[2] += TRB->QUANT
				Endif	
			EndIf
			dbSelectArea("AH9")
			dbSetOrder(2)   // AH9_FILIAL + DTOS(AH9_DTINIC)
			dbSeek(xFilial("AH9")+TRB->DATAEMI,.T.)
			While !Eof() .And. xFilial("AH9") == AH9->AH9_FILIAL .And.;
								TRB->DATAEMI <= DTOS(AH9->AH9_DTFIM) .And.;
								TRB->DATAEMI >= DTOS(AH9->AH9_DTINIC)
				If TRB->TES $ AH9->AH9_TESLIC
					lLicitaca := .T.
					Exit
				EndIf
				dbSelectArea("AH9")
				dbSkip()
			End
		Endif
	ElseIf cAlias == "SD2"
		If (ExistBlock("CDAA101"))
			aCalMov   := ExecBlock("CDAA101",.F.,.F.,{lSeguinte,aQtdeAH7})
			If Len(aCalMov) # 0
				lSeguinte := aCalMov[1]
				aQtdeAH7  := aCalMov[2]
			EndIf
		EndIf
		If Len(aCalMov) == 0
			dbSelectArea("AH9")
			dbSetOrder(2)   // AH9_FILIAL + DTOS(AH9_DTINIC)
			dbSeek(xFilial("AH9")+TRB->DATAEMI,.T.)
			While !Eof() .And. xFilial("AH9") == AH9->AH9_FILIAL .And.;
								TRB->DATAEMI <= DTOS(AH9->AH9_DTFIM) .And.;
								TRB->DATAEMI >= DTOS(AH9->AH9_DTINIC)
				If TRB->TES $ AH9->AH9_TESLIC
					lLicitaca := .T.
					Exit
				EndIf
				dbSelectArea("AH9")
				dbSkip()
			End
			If lLicitaca
				aQtdeAH7[12] += TRB->QUANT     // Licitacao
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifica a data da proxima prestacao de contas.         Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				dbSelectArea("AH6")
				dbSetOrder(1)
				If !CdSeekAH6(xFilial("AH6")+cProduto+cForneced+AH9->AH9_CODLIC)
					RecLock("AH6",.T.)
					AH6->AH6_FILIAL := xFilial("AH6")
					AH6->AH6_PRODUT := cProduto
					AH6->AH6_FORNEC := AH1->AH1_FORNEC
					AH6->AH6_LOJAFO := AH1->AH1_LOJAFO
					AH6->AH6_DTPRXD := CD030DtPrx(CTOD(""),cProduto,cForneced)
					AH6->AH6_LICITA := AH9->AH9_CODLIC
	
					If (AH6->(FieldPos("AH6_CODANT")) > 0)
						AH6->AH6_CODANT := AH1->AH1_CODANT
					EndIf
					MsUnLock()
				EndIf
			EndIf                         
			
			If !lLicitaca
				If &cCpoTipo $ GetMv("MV_CDAPROM",,"")      // Promocao
					If SF4->F4_ESTOQUE != 'N'
						aQtdeAH7[4] += TRB->QUANT
					Endif	
					lSeguinte := .T.
				ElseIf &cCpoTipo $ GetMv("MV_CDACONS",,"")	// Consignacao
					aQtdeAH7[5] += TRB->QUANT
					lSeguinte := .T.
				ElseIf &cCpoTipo $ GetMv("MV_CDAVEAU",,"")	// Venda Autor
					aQtdeAH7[15] += TRB->QUANT
					lSeguinte := .T.				
				ElseIf TRB->TES $ GetMv("MV_CDADOA",,"")	// Doacao
					aQtdeAH7[16] += TRB->QUANT
					lSeguinte := .T.
				ElseIf TRB->TES $ GetMv("MV_CDABONI",,"")	// Bonificacao
					aQtdeAH7[14] += TRB->QUANT
					If GetMv("MV_CDACBON",,"N") == "N" // Indica se gera DA para Bonificacoes
						lSeguinte := .T.
					EndIf
				ElseIf &cCpoTipo $ GetMv("MV_CDAACER",,"")	// Acertos
					If SF4->F4_ESTOQUE != "N"
						aQtdeAH7[8] -= TRB->QUANT
					Endif	
					lSeguinte := .T.
				Else                                    // Venda
					If !Empty(SF4->F4_TIPOPER)
						If &cCpoTipo $ GetMv("MV_CDAVEND",,"")
							aQtdeAH7[1] += TRB->QUANT
						ElseIf &cCpoTipo $ GetMv("MV_CDAVCON",,"")
							aQtdeAH7[9] += TRB->QUANT
						Else
							lSeguinte :=.T.
						EndIf
					Else
						If SF4->F4_ESTOQUE != "N"
							aQtdeAH7[1] += TRB->QUANT
						Endif
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf cAlias == "SD3"
		If (ExistBlock("CDAA102"))
			aCalMov   := ExecBlock("CDAA102",.F.,.F.,{lSeguinte,aQtdeAH7})
			If Len(aCalMov) # 0
				lSeguinte := aCalMov[1]
				aQtdeAH7  := aCalMov[2]
			EndIf
		EndIf
		If Len(aCalMov) == 0
			If TRB->DOC == "INVENT"               // Acertos de Inventario
				aQtdeAH7[8] += Iif(Substr(TRB->CF,1,2) == "RE",TRB->QUANT * -1,TRB->QUANT)
			ElseIf Alltrim(TRB->CF) == "PR0"               // Producao
				aQtdeAH7[7] += Iif(Substr(TRB->CHAVE,1,1) == "R",TRB->QUANT,TRB->QUANT*-1)
			ElseIf Alltrim(TRB->CF) == "RE0" .And. Empty(TRB->OP)  // Perdas
				aQtdeAH7[6] += Iif(Substr(TRB->CF,1,2) == "DE",TRB->QUANT * -1,TRB->QUANT)
			ElseIf Substr(TRB->CF,3,1) == "4"     // Transferencia
				aQtdeAH7[3] += Iif(Substr(TRB->CF,1,2) == "RE",TRB->QUANT * -1,TRB->QUANT)
			ElseIf Alltrim(TRB->CF) == "ER0" .Or. Alltrim(TRB->CF) == "RE0"
				aQtdeAH7[8] -= TRB->QUANT
			ElseIf Substr(TRB->CF,2,2) == "E6"
				aQtdeAH7[8] += Iif(Substr(TRB->CF,1,2)=="RE",TRB->QUANT * -1,TRB->QUANT)
			Else
	         	If (ExistBlock("DIRA110"))
		            aQtdeAH7[8] += ExecBlock("DIRA110",.F.,.F.)
	    	    Endif     			
			EndIf
			lSeguinte := .T.
			nPreco := TRB->PRUNIT / IIf(TRB->QUANT == 0,1,TRB->QUANT)
		EndIf
	EndIf
Else
	If cAlias == "SD1" 
      	If (ExistBlock("DIRA120"))
        	lSeguinte := ExecBlock("DIRA120",.F.,.F.)
      	Else	
			If !Empty(SF4->F4_TIPOPER)
				// Nao calcula movimento para acertos, consignacao e devolucao de
				// venda de consignacao
				If SF4->F4_TIPOPER $ GetMv("MV_CDAACER",,"") .Or. ;
					SF4->F4_TIPOPER $ GetMv("MV_CDACONS",,"") .Or. ;
					SF4->F4_TIPOPER $ GetMv("MV_CDADVCO",,"")
					lSeguinte := .T.
				EndIf
			ElseIf TRB->TES $ GetMv("MV_CDAACER",,"")
				lSeguinte := .T.
			ElseIf TRB->TES $ GetMv("MV_CDACONS",,"")  // Consignacao
				lSeguinte := .T.
			EndIf
		Endif	
	ElseIf cAlias == "SD2"
		If (ExistBlock("CDAA103"))
			lSeguinte := ExecBlock("CDAA103",.F.,.F.)
		Else
			If &cCpoTipo $ GetMv("MV_CDAPROM",,"")		// Promocao
				lSeguinte := .T.
			ElseIf &cCpoTipo $ GetMv("MV_CDACONS",,"")	// Consignacao
				lSeguinte := .T.
			ElseIf &cCpoTipo $ GetMv("MV_CDAVEAU",,"")	// Venda Autor
				lSeguinte := .T.
			ElseIf TRB->TES $ GetMv("MV_CDADOA",,"")	// Doacao
				lSeguinte := .T.
			ElseIf &cCpoTipo $ GetMv("MV_CDAACER",,"")  // Acertos
				lSeguinte := .T.
			ElseIf TRB->TES $ GetMv("MV_CDABONI",,"") // Bonificacao
				If GetMv("MV_CDACBON",,"N") == "N" // Indica se gera DA para Bonificacoes
					lSeguinte := .T.
				EndIf
			Else									// Venda
				If !Empty(SF4->F4_TIPOPER)
					If !(&cCpoTipo $ GetMv("MV_CDAVEND",,"")) .And. ;
						!(&cCpoTipo $ GetMv("MV_CDAVCON",,"")).And. ;
						!(&cCpoTipo $ GetMv("MV_CDAPROM",,""))
						lSeguinte := .T.
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf cAlias == "SD3"
		lSeguinte := .T.
	EndIf
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Nao calcula D.A. para movimentos de transferencia (03), pro- Ё
//Ё mocao (04), consignacao (05), perdas (06), producao (07) e   Ё
//Ё acertos (08).                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lSeguinte
	Return 0
Endif

nQtdAcum2 := nQtdAcum1 + Iif(cAlias=="SD2",TRB->QUANT,TRB->QUANT*-1)
nQtdVenda := Iif(cAlias == "SD2",TRB->QUANT,TRB->QUANT*-1)
lAchouFxa := .F.

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Gera array de regras AH2.                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aRegraAH2 := CD030Array(cProduto+cForneced)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pesquisa qual regra aplicar.                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aAreaAH2:= AH2->(GetArea())
dbSelectArea("AH2")
dbSetOrder(1)
dbSeek(xFilial("AH2")+cProduto+cForneced)

While nQtdVenda != 0
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё lAchouFxa - verifica se achou alguma faixa que atenda a    Ё
	//Ё             qtde. caso contrario sai do while.             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	lAchouFxa := .F.
	
	For i := 1 To Len(aRegraAH2)

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se a quantidade acumulada esta dentro da faixa.   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nQtdAux := nQtdAcum1 + Iif(nQtdVenda > 0,1,0)
		If nQtdAcum1+1 >= aRegraAH2[i][1] .And. nQtdAux <= aRegraAH2[i][2] ;
			.And. aRegraAH2[i][3] <= TRB->DESCO
			lAchouFxa := .T.
			nI        := i
			Exit
		Endif
	Next

	If !lAchouFxa
		nElemen := aScan(aInconsist,{|x| x[1] == cForneced .And. x[2] == cProduto})
		If nElemen == 0
			aAdd(aInconsist,{cForneced,cProduto,nQtdVenda})
		Else
			aInconsist[nElemen][3] += nQtdVenda
		Endif
		Exit
	Endif
	i := nI

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Calcula o preco unitario com base nas regras da faixa.     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If (ExistBlock("CDAA105"))
		nPrecoUn := ExecBlock("CDAA105",.F.,.F.,{cAlias,aRegraAH2})		
	Else
		If cAlias == "SD2"
			dbSelectArea("SD2")		
			dbSetOrder(3)
			If dbSeek( xFilial("SD2") + TRB->DOC + TRB->SERIE + TRB->CLIENTE + TRB->LOJA + TRB->PRODUTO + TRB->ITEM)
				If aRegraAH2[i][06] == "1"    // preco de capa ou liquido
					nPrecoUn:=Iif( lD2UnDA, SD2->D2_PRUNDA, TRB->PRUNIT )
				Else
					nPrecoUn := TRB->PRCVEN
				Endif
			Else
				nPrecoUn := TRB->PRCVEN
			EndIf
		Else
			dbSelectArea("SD1")
			dbSetOrder(1)
			If dbSeek(xFilial("SD1") + TRB->DOC + TRB->SERIE + TRB->CLIENTE + TRB->LOJA + TRB->PRODUTO + TRB->ITEM)
				If aRegraAH2[i][6] == "1"     // Preco de Capa
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Procura o preco de tabela (capa) no arq. SD2.              Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					aAreaSD2:= SD2->(GetArea())
					dbSelectArea("SD2")
					dbSetOrder(3)  // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD
					If dbSeek(xFilial("SD2") + TRB->NFORI + TRB->SERIORI + TRB->CLIENTE + TRB->LOJA + TRB->PRODUTO + TRB->ITEMORI)
						nPrecoUn:=IIf( lD2UnDA, SD2->D2_PRUNDA, TRB->PRUNIT )
					Else
						nPrecoUn:=IIf( lD1UnDA, SD1->D1_PRUNDA, TRB->PRUNIT )
					EndIf
					
					RestArea(aAreaSD2)
					dbSelectArea("SD1")
				Else
					nPrecoUn := TRB->PRCVEN           // Preco Liquido
				EndIf
			EndIf
	
			If nPrecoUn == 0
				nPrecoUn := TRB->PRCVEN
			EndIf
		
			If (ExistBlock("CDAPRDEV"))
				nPrecoUn := ExecBlock("CDAPRDEV",.F.,.F.)
			EndIf
		EndIf
	EndIf
   
	nValBruto := 0

	If cAlias == "SD2"
		nPrecoUn -= Iif(aRegraAH2[i][7]  == "1",Round((nPrecoUn*TRB->DESCO)/100,3),0)    // diminui valor de desconto
		nValBruto := nPrecoUn
		nPrecoUn -= Iif(aRegraAH2[i][8]  == "1",Round((TRB->VALICM/TRB->QUANT),3),0)     // diminui valor de ICM
		nPrecoUn -= Iif(aRegraAH2[i][9]  == "1",Round((TRB->VALIPI/TRB->QUANT),3),0)     // diminui valor de IPI
		nPrecoUn -= Iif(aRegraAH2[i][10] == "1",Round((nValBruto*GetMV("MV_COFINS1"))/100,3),0)  // diminui valor de PIS/COFINS
		nPrecoUn -= Iif(aRegraAH2[i][11] !=  0 ,Round((nPrecoUn*aRegraAH2[i][11])/100,3),0)    // diminui valor de outro desconto
	Else
		If aRegraAH2[i][7] == "1" .Or. aRegraAH2[i][6] == "2"
			nPrecoUn -= Round((nPrecoUn*TRB->DESCO)/100,3)   // diminui valor de desconto
		EndIf
		nValBruto := nPrecoUn
		nPrecoUn -= Iif(aRegraAH2[i][8]  == "1",Round((TRB->VALICM/TRB->QUANT),3),0)     // diminui valor de ICM
		nPrecoUn -= Iif(aRegraAH2[i][9]  == "1",Round((TRB->VALIPI/TRB->QUANT),3),0)     // diminui valor de IPI
		nPrecoUn -= Iif(aRegraAH2[i][10] == "1",Round((nValBruto*GetMV("MV_COFINS1"))/100,3),0)  // diminui valor de PIS/COFINS
		nPrecoUn -= Iif(aRegraAH2[i][11] !=  0 ,Round((nPrecoUn*aRegraAH2[i][11])/100,3),0)    // diminui valor de outro desconto
	EndIf
	If AH1->AH1_MOEDA == "2"    // Moeda Forte
      	If (ExistBlock("DIRA130"))
         	nPrecoUn := ExecBlock("DIRA130",.F.,.F.,{nPrecoUn,nMoedaFor})
      	Else
            dDataCalc := Iif(cAlias <> "SD1",TRB->DATAEMI,TRB->EMISSAO)
            dDataCalc := CTOD(Subst(dDataCalc,7,2)+"/"+Subst(dDataCal,5,2)+"/"+Subst(dDataCal,1,4))

            nPrecoUn  := xMoeda(nPrecoUn,1,nMoedaFor,dDataCal)
		Endif 	
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se a qtde. de venda esta tudo em 1 faixa ou mais. Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nQtdAcum2 <= aRegraAH2[i][2] .And. (nQtdAcum1 > aRegraAH2[i][1] .Or. ;
		nQtdVenda > 0)
		
		nQtdVend2 := nQtdVenda
	Else
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Qtde de venda em mais de uma faixa, o restante passa para  Ё
		//Ё a proxima faixa.                                           Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nQtdVenda > 0
			nQtdVend2 := ((aRegraAH2[i][2] - aRegraAH2[i][1] + 1) - (nQtdAcum1 - aRegraAH2[i][1] + 1))
		Else
			nQtdVend2 := aRegraAH2[i][1] - nQtdAcum1 - 1
			If nQtdVend2 == 0
				nQtdVend2 := nQtdVenda
			EndIf
		EndIf
	EndIf
	nQtdVenda -= nQtdVend2

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Calcula o valor do direito autoral (royalty).           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nDirAutor := 0
	If aRegraAH2[i][4] != 0
		nDirAutor := Round(nQtdVend2 * nPrecoUn * aRegraAH2[i][4] / 100,3)
	ElseIf aRegraAH2[i][5] != 0
		//nDirAutor := nQtdVend2 * aRegraAH2[i][5]
  		If lCda030VDA
			nDirAutor := ExecBlock("Cda030VDA", .f., .f., {nQtdVend2, nPrecoUn, aRegraAH2[i][5]})
		Else
			nDirAutor := aRegraAH2[i][5]
		EndIf
	EndIf

	If lLicitaca
		nDirAutor := Round(nQtdVend2 * nPrecoUn * AH9->AH9_PERCEN/100,3)
		aRegraAH2[i][4] := AH9->AH9_PERCEN
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica a data da proxima prestacao de contas.         Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("AH6")
	dbSetOrder(1)
	If !CdSeekAH6( xFilial("AH6")+cProduto+cForneced)
		RecLock("AH6",.T.)
		AH6->AH6_FILIAL := xFilial("AH6")
		AH6->AH6_PRODUT := cProduto
		AH6->AH6_FORNEC := AH1->AH1_FORNEC
		AH6->AH6_LOJAFO := AH1->AH1_LOJAFO
		AH6->AH6_DTPRXD := CD030DtPrx(CTOD(""),cProduto,cForneced)

		If (AH6->(FieldPos("AH6_CODANT")) > 0)
			AH6->AH6_CODANT := AH1->AH1_CODANT
		EndIf
		MsUnLock()
	EndIf
	dPrxPrest := AH6->AH6_DTPRXD     // Proxima prestacao do direito autoral
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava movimentos de royalty.                            Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("AH4")
	dbSetOrder(1)
	If !lLicitaca
		dbSeek(xFilial("AH4")+cProduto+cForneced+DTOS(dPerFim)+Space(Len(AH4->AH4_LICITA)))
	Else
		dbSeek(xFilial("AH4")+cProduto+cForneced+DTOS(dPerFim)+AH9->AH9_CODLIC)
	EndIf
	If Eof() .Or. xFilial("AH4")+cProduto+cForneced != ;
		AH4->AH4_FILIAL+AH4->AH4_PRODUT+AH4->AH4_FORNEC+AH4->AH4_LOJAFO .Or. ;
		AH4->AH4_DATCAL != dPerFim

		If AH9->AH9_CODLIC != AH4->AH4_LICITA .Or. Eof()
			RecLock("AH4",.T.)
			Replace AH4_FILIAL With xFilial("AH4") , AH4_PRODUT With cProduto
			Replace AH4_FORNEC With AH1->AH1_FORNEC, AH4_LOJAFO With AH1->AH1_LOJAFO
			Replace AH4_DATCAL With dPerFim
			Replace	AH4_DTULTI With AH1->AH1_DTULTP			
			If lLicitaca
				Replace AH4_LICITA With AH9->AH9_CODLIC
			EndIf

			If (AH4->(FieldPos("AH4_CODANT")) > 0)
				AH4->AH4_CODANT := AH1->AH1_CODANT
			EndIf
		Else
			RecLock("AH4",.F.)
		EndIf
	Else
		RecLock("AH4",.F.)
	EndIf

	AH4->AH4_QTDACU += nQtdVend2
	AH4->AH4_VALACU += (nQtdVend2 * nPrecoUn)
	AH4->AH4_VALORD += nDirAutor
	AH4->AH4_DTPRES := Iif(!lLicitaca,dPrxPrest,LastDay(AH9->AH9_DTFIM))
	AH4->AH4_VALADI := AH1->AH1_SALDOA
	
	If Empty(AH1->AH1_DTULTP)
		AH4->AH4_DTULTI := AH1->AH1_INICVI
	Else
		AH4->AH4_DTULTI := AH1->AH1_DTULTP
	Endif
	
	MsUnLock()
	cPrecoUn := Str(nPrecoUn,14,3)
	lAppend := .F.
	dbSelectArea("AH5")
	If !lLicitaca
		dbSetOrder(1)
		dbSeek(xFilial("AH5")+cProduto+cForneced+DTOS(dPerFim)+Str(aRegraAH2[i][2],9)+cPrecoUn)
	Else
		dbSetOrder(4)
		dbSeek(xFilial("AH5")+cProduto+cForneced+AH9->AH9_CODLIC+DTOS(dPerFim)+Str(aRegraAH2[i][2],9))
	EndIf
	If AH5->(Eof())
		lAppend := .T.
	Else
		While xFilial("AH5")+cProduto+cForneced+DTOS(dPerFim)+Str(aRegraAH2[i][2],9)+;
				cPrecoUn == AH5->AH5_FILIAL+AH5->AH5_PRODUT+AH5->AH5_FORNEC+;
				AH5->AH5_LOJAFO+DTOS(AH5->AH5_DATCAL)+Str(AH5->AH5_FXFINA,9)+;
				Str(AH5->AH5_PRECOU,14,3) .And. cAlias == "SD1"
			If AH5->AH5_QTDACU < 0
				lAppend := .F.
				Exit
			EndIf
			lAppend := .T.
			dbSkip()
		End
		While xFilial("AH5")+cProduto+cForneced+DTOS(dPerFim)+Str(aRegraAH2[i][2],9)+;
				cPrecoUn == AH5->AH5_FILIAL+AH5->AH5_PRODUT+AH5->AH5_FORNEC+;
				AH5->AH5_LOJAFO+DTOS(AH5->AH5_DATCAL)+Str(AH5->AH5_FXFINA,9)+;
				Str(AH5->AH5_PRECOU,14,3) .And. cAlias == "SD2"
			If AH5->AH5_QTDACU > 0
				lAppend := .F.
				Exit
			EndIf
			lAppend := .T.
			dbSkip()
		End
	EndIf
	If lAppend
		RecLock("AH5",.T.)
		AH5->AH5_FILIAL := xFilial("AH5")
		AH5->AH5_PRODUT := cProduto
		AH5->AH5_FORNEC := AH1->AH1_FORNEC
		AH5->AH5_LOJAFO := AH1->AH1_LOJAFO
  		AH5->AH5_FXFINA := aRegraAH2[i][2]
		AH5->AH5_PRECOU := nPrecoUn
		AH5->AH5_DATCAL := dPerFim
		If lLicitaca
			AH5->AH5_LICITA := AH9->AH9_CODLIC
		Endif

		If (AH5->(FieldPos("AH5_CODANT")) > 0)
			AH5->AH5_CODANT := AH1->AH1_CODANT
		EndIf
	Else
		RecLock("AH5",.F.)
	EndIf
	
	AH5->AH5_QTDACU += nQtdVend2
	AH5->AH5_BASEDA += (nQtdVend2*nPrecoUn)
	AH5->AH5_VALORD += nDirAutor
	AH5->AH5_PERCDA := aRegraAH2[i][4]
	AH5->AH5_DTPRES := Iif(!lLicitaca,dPrxPrest,LastDay(AH9->AH9_DTFIM))
	MsUnLock()

	nQtdAcum1 += nQtdVend2
	
   	If (ExistBlock("DIRA140"))
    	ExecBlock("DIRA140",.F.,.F.,{nDirAutor,cALias})
   	Endif 	
End

If !lAchouFxa
	nQtdAcum1 := nQtdAcum2
Endif

Return (nQtdAcum1 - AH8->AH8_QTDACU)

Function CdSeekAH6(cChave)
Local lRet := .F.

// ATENCAO ! CRIAR INDICE NA VERSAO 8.11 F3
dbSelectArea("AH6")
dbSetOrder(1)
dbSeek(cChave)
While !Eof() .And. xFilial("AH6")==AH6->AH6_FILIAL .And. Alltrim(cChave) == Alltrim(AH6->AH6_FILIAL + AH6->AH6_PRODUT + AH6->AH6_FORNEC + AH6->AH6_LOJAFO + AH6->AH6_LICITA)
	If Empty(AH6->AH6_DTPRES)
		lRet := .T.
		Exit
	EndIf
	dbSKip()
End
Return lRet

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    ЁAdmAbreSM0Ё Autor Ё Orizio                Ё Data Ё 22/01/10 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁRetorna um array com as informacoes das filias das empresas Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Generico                                                   Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function AdmAbreSM0()
Local aArea			:= SM0->( GetArea() )
Local aAux			:= {}
Local aRetSM0		:= {}
Local lFWLoadSM0	:= FindFunction( "FWLoadSM0" )
Local lFWCodFilSM0 	:= FindFunction( "FWCodFil" )

If lFWLoadSM0
	aRetSM0	:= FWLoadSM0()
Else
	DbSelectArea( "SM0" )
	SM0->( DbGoTop() )
	While SM0->( !Eof() )
		aAux := { 	SM0->M0_CODIGO,;
					IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
					"",;
					"",;
					"",;
					SM0->M0_NOME,;
					SM0->M0_FILIAL }

		aAdd( aRetSM0, aClone( aAux ) )
		SM0->( DbSkip() )
	End
EndIf

RestArea( aArea )
Return aRetSM0   
