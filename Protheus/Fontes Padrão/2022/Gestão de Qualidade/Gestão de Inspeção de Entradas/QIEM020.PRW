#INCLUDE "QIEM020.CH"
#INCLUDE "PROTHEUS.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QIEM020	³ Autor ³ Vera Lucia S.Simoes   ³ Data ³ 28/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa Atualizacao de Situacao e Skip-Lote 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Paulo Emidio³04/05/01³META  ³Alterado programa para que os indices se- ³±±
±±³			   ³	    ³ 	   ³pela rotina padrao do sistema.			  ³±±
±±³Paulo Emidio³15/05/01³003568³Alterado programa para que nao seja reali-³±±
±±³			   ³	    ³ 	   ³zada a media dos ultimos 12 meses no IQFA,³±±
±±³			   ³	    ³ 	   ³pois o mesmo se mantem atualizado no mes  ³±±
±±³			   ³	    ³ 	   ³selecionado.							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIEM020()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis 										     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lCont     := .F.
Local oDlg 
Local oGet_1
Local oGet_2
Local cTit      := OemToAnsi(STR0001) //"Atualiza‡„o Situacao e Skip-Lote"
Local lQiem021  := ExistBlock("QIEM021") 

Private cIE020Mes := StrZero(Month(MsDate()),2)
Private cIE020Ano := Str(Year(MsDate()),4)

DEFINE MSDIALOG oDlg TITLE cTit FROM 150,3 TO 300,400 OF oMainWnd PIXEL

@ 035, 003 Say TitSX3("QEV_ANO")[1] SIZE 35,7 OF oDlg PIXEL   
@ 050, 003 Say TitSX3("QEV_MES")[1] SIZE 25,7 OF oDlg PIXEL   

@ 034, 040 MSGET oGet_1 VAR cIE020Ano PICTURE PesqPict("QEV","QEV_ANO") F3 "QEV" ;
	Valid ExistCpo("QEV",cIE020Ano,1)  SIZE 32,10 OF oDlg PIXEL
	
@ 049,40 MSGET oGet_2 VAR cIE020Mes PICTURE PesqPict("QEV","QEV_MES") ;
	Valid Val(cIE020Mes) > 0 .And. Val(cIE020Mes) < 13 .And.;
		Eval({|| cIE020Mes:=StrZero(Val(cIE020Mes),2),oGet_2:Refresh(),.T. }) .And.;
		ExistCpo("QEV",cIE020Ano+cIE020Mes,1) SIZE 32,10 OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lCont := .T.,oDlg:End()},{|| lCont:=.f.,oDlg:End()})

If lCont

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Atualizacao Automatica Situacao e Skip-Lote via RDMAKE 	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  lQiem021

		Begin Transaction
			ProcQDO({|| ExecBlock("QIEM021",.F.,.F.)},,,.T.,)
		End Transaction

	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa a Atualizacao Automatica Situacao e Skip-Lote via padrao 	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Processa({||Qiem021Atu(cIE020Mes,cIE020Ano)})	

	EndIf           
	
EndIf                               

Return(NIL)    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QIEM021ATU³ Autor ³Paulo Emidio de Barros ³Data  ³03/05/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualizacao Automatica Situacao e Skip-Lote para os        ³±±
±±³          ³ Produtos/Fornecedores marcados para atualizacao ("S")      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEM020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Qiem021Atu(cIE020Mes,cIE020Ano)	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as variaveis utilizadas na Rotina								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lAtual   := .F.
Local nNotaMin
Local nI
Local cMvAssIQS 
Local nMvIQSQua 
Local mMvIQSAss 
Local cMvUtSk25 
Local lVerIQSQua 
Local cMvSklIQS 
Local aQEX 
Local aTamSkl
Local lAtualiza 
Local nIQS
Local cFor	 
Local cProd	 
Local lAtuSit 
Local nIndice 
Local cSitu := ' '   // inicializar para não dar error.log quando não existir cadastro de classes situação.
Local cCateg
Local cSituAnt
Local cSkipAnt
Local cSkip	 
Local cUnidAnt 
Local cEspec	
Local cCodAnt	
Local lAtuSkip
Local nMedia 
Local nNota 
Local nPos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva as areas correntes				 								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSaveSA5 := SA5->(GetArea())
Local aSaveQEF := QEF->(GetArea())
Local aSaveQEG := QEG->(GetArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe o Indice Qualidade gerado para este mes/ano          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QEV")
dbSetOrder(1)
If !dbSeek(xFilial("QEV")+cIE020Ano+cIE020Mes)
	Help(" ",1,"QE_NAOINQU")	// Indice de Qualidade nao foi gerado para este mes ano
	Return(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Tabela de Criterios do Skip-Lote est  cadastrada          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QEX")
dbSetOrder(1)
If !dbSeek(xFilial("QEX"))
	Help(" ",1,"M020CSLVAZ")	// Favor cadastrar os Criterios do Skip-Lote
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a nota minima do Skip-Lote 										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nNotaMin := QEX_VLSUP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Situacao pode ser Assegurado sem IQS									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMvAssIQS := GetMv("MV_QASSIQS")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ IQS minimo para Situacao Qualificado									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nMvIQSQua := GetMv("MV_QIQSQUA")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ IQS minimo para Situacao Assegurado										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mMvIQSAss := GetMv("MV_QIQSASS")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define se sera utilizado o Skip-Lote de 25% 							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMvUtSk25 := GetMv("MV_QUTSK25")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o IQS qualificado se existir a categoria igual a 3				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lVerIQSQua := .F.

dbSelectArea("QEG")
dbSetOrder(1)
dbSeek(xFilial("QEG"))
While QEG_FILIAL == xFilial("QEG") .And. !Eof()
	If QEG_CATEG == "3"
		lVerIQSQua := .T.
		Exit
	EndIf
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Skip-Lote vinculado ao IQS												³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMvSklIQS := GetMv("MV_QSKLIQS")

If cMvSklIQS == "S"

	// Guarda o arquivo em vetor para simular o dbskip(-1)
	aQEX := {}
	dbselectArea("QEX")
	dbSetOrder(1)
	dbSeek(xFilial("QEX"))
	While QEX_FILIAL == xFilial("QEX") .And. !Eof()
		Aadd(aQEX, QEX_VLSUP)
		dbSkip()
	EndDo
EndIf

dbSelectArea("SA5")
dbSetOrder(2)

// Define o tamanho do campo Skip-Lote
aTamSkl := TamSX3("A5_SKPLOT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona os Indices gerados no mes/ano determinado                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QEV")
dbSetOrder(1)
dbSeek(xFilial("QEV")+cIE020Ano+cIE020Mes)

//Inicia a regua de processamento                   
ProcRegua(LastRec())

While !Eof() .And. (QEV_FILIAL+QEV_ANO+QEV_MES) ==;
	xFilial("QEV")+cIE020Ano+cIE020Mes  

	IncProc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Fornecedor/Produto est  marcado para atualizacao 			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lAtualiza := .F.
	
	dbSelectArea("SA5")
	dbSetOrder(2)
	If dbSeek(xFilial("SA5")+QEV->QEV_PRODUT+QEV->QEV_FORNEC)
		While !Eof() .And. (A5_FILIAL+A5_PRODUTO+A5_FORNECE) ==;
			(xFilial("SA5")+QEV->QEV_PRODUT+QEV->QEV_FORNEC) 
			If A5_ATUAL == "S" 
				lAtualiza := .T.
				Exit
			EndIf
			dbSkip()
		EndDo		
	EndIf  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o numero de entradas necessarios para alterar a situação do Fornecedor	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAtualiza          		
		If SA5->A5_DIASSIT > QEV->QEV_LOTENT
			lAtualiza := .F.
		EndIf
	EndIf	

	If !lAtualiza
		dbSelectArea("QEV")
		dbSkip()
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obtem a nota de IQS do Fornecedor										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA2")
	dbSetOrder(1)
	If dbSeek(xFilial("SA2")+QEV->QEV_FORNEC)
		If A2_FATAVA == 0 .And. Empty(A2_DTAVA)
			nIQS := 999.99
		Else
			nIQS := A2_FATAVA
		EndIf
	Else
		dbSelectArea("QEV")
		dbSkip()
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Guarda registro que est  posicionado no QEV								³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QEV")
	cFor	:= QEV_FORNEC
	cProd	:= QEV_PRODUT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define a atualizacao automatica da Situacao								³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lAtuSit := .f.
	nIndice := QEV_IQFA	// Atualizacao pelo IQF Acumulado

	If nIndice <> 999.99
		// Identifica a Classe da Situacao
		dbSelectArea("QEG")
		dbSetOrder(2)
		dbSeek(xFilial("QEG")+Str(nIndice,6,2), .T.)
		If !Eof() .And. QEG_FILIAL == xFilial("QEG")
			lAtuSit := .t.
		EndIf
		
	EndIf

	If lAtuSit
		cSitu  := QEG_SITU
		cCateg := QEG_CATEG

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for assegurado (Categoria 1-> Skip-Lote Total), verifica o IQS		³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QEG_CATEG == "1" 
			If cMvAssIQS == "N" .And. nIQS <> 999.99 .And. nIQS < mMvIQSAss 
				// Muda Situacao p/ Qualificado (Categ. 2-> Skip-Lote 25%)
				dbSetOrder(1)
				dbSeek(xFilial("QEG"))
				While QEG_FILIAL == xFilial("QEG") .And. !Eof()
					If QEG_CATEG == "2"
						cSitu  := QEG_SITU
						cCateg := QEG_CATEG
						Exit
					EndIf
					dbSkip()
				EndDo
			EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se Sit. for Asseg. ou Qualif. (Categoria  2 -> Skip-Lote Total ou 25%)  ³
		//³ Verifica se o IQS ‚ >= a Nota minima p/ Qualificado  					³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf QEG_CATEG $ "2"	// Skip-Lote Total ou 25%  ( Asseg. ou Qualif. )
			If lVerIQSQua .And. nIQS <> 999.99 .And. nIQS < nMvIQSQua
				// Muda Situacao p/ Pre-Qualificado (Categ. 3-> Sem Skip-Lote)
				dbSetOrder(1)
				dbSeek(xFilial("QEG"))
				While QEG_FILIAL == xFilial("QEG") .And. !Eof()
					If QEG_CATEG == "3"
						cSitu  := QEG_SITU
						cCateg := QEG_CATEG
						Exit
					EndIf
					dbSkip()
				EndDo
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza Situacao para todas as lojas do Fornecedor						³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA5")
		dbSetOrder(2)
		SA5->(dbSeek(xFilial("SA5")+QEV->QEV_PRODUT+QEV->QEV_FORNEC))
		While !Eof() .And. (A5_FILIAL+A5_PRODUTO+A5_FORNECE) ==;
			(xFilial("SA5")+QEV->QEV_PRODUT+QEV->QEV_FORNEC)

			If A5_ATUAL == "S"
				If cSitu <> A5_SITU

					lAtuSkip = Qiem020SL(A5_FORNECE, A5_LOJA, A5_PRODUTO)				
					
					// Guarda a Situacao e Skip-Lote anteriores
					cSituAnt := A5_SITU
					cSkipAnt := A5_SKPLOT
					cSkip	 := A5_SKPLOT

					// Guarda a Unidade do Skip-Lote anterior
					dbSelectArea("QEF")
					dbSetOrder(1)
					dbSeek(xFilial("QEF")+cSkipAnt)
					cUnidAnt := QEF_UNSKLT
                    
					lContSA5 := .F.
					
					dbSelectArea("SA5")  
					
					lContSA5 := If(A5_TIPATU $ "0/2 ",.T.,.F.)     

					If lContSA5
						RecLock("SA5",.F.)
						lAtual       := .T.
						SA5->A5_SITU := cSitu
						MsUnLock()

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Gera historico da Situacao												³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cEspec	:= "MATA060T"
						cCodAnt	:= cSituAnt
						
						Qiem021His(cEspec,cCodAnt)
				
                    EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza o Skip-Lote de acordo com a Situacao							³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					// Se a nova categoria nao tem skip-lote associado
					If cCateg $ "3.4" .or. !lAtuSkip // Sem Skip-Lote e Nao Recebe
						cSkip := Space(aTamSkl[1])
					EndIf

					// Se a categoria ‚ skip-lote 25%, verifica o skip-lote:               
					If cMvUtSk25 == "S"
						If cCateg == "2" .And. (cUnidAnt == "D" .Or.;
							(cUnidAnt == "E" .And. QEF->QEF_QTDE > 4))
								
							// Assume o Skip-Lote "Controla 1 a cada 4 Entradas"
							dbSelectArea("QEF")
							dbSetOrder(2)
							For nI := 4 to 1 Step-1
								If dbSeek(xFilial("QEF")+"E"+Str(nI,4))
									cSkip := QEF->QEF_SKPLOT
									Exit
								EndIf
							Next nI
								
						EndIf              
							
					Else        
						
						If cCateg == "2" .And. (cUnidAnt == "D" .Or. cUnidAnt == "E")
								
							// Assume o Skip-Lote 
							dbSelectArea("QEF")
							dbSetOrder(2)
							If dbSeek(xFilial("QEF")+"E"+Str(QEF->QEF_QTDE,4),.T.)
								cSkip := QEF->QEF_SKPLOT
							EndIf
						EndIf              
							
					EndIf

					lContSA5 := .F.

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se houve alteracao, grava o novo skip-lote								³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				

					lContSA5 := If(SA5->A5_TIPATU $ "0/1 ",.T.,.F.)     
					If lContSA5
						If cSkip <> cSkipAnt 
							RecLock("SA5", .F.)
							SA5->A5_SKPLOT	:= cSkip
							MsUnLock()

							// Gera historico do Skip-Lote
							cEspec	:= "MATA060L"
							cCodAnt	:= cSkipAnt  
							Qiem021His(cEspec,cCodAnt)							
						EndIf                
					EndIf
				EndIf
				
			EndIf	
			dbSelectArea("SA5")
			dbSkip()
			
		EndDo
		
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizacao Automatica do Skip-Lote  									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QEV")
	
	// Flag que controla se atualiza o Skip-Lote
	lAtuSkip := .F.
                            
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizacao pelo QIF Acumulado											³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nMedia := QEV_IQFA	
	If QEV_IQFA <> 999.99

		dbSelectArea("QEX")
		
		// Verifica se o Skip-Lote est  vinculado ao IQS
		If cMvSklIQS == "S"
		
			// Calcula nova media com o IQS
			nNota := Iif(nIQS<>999.99,(nMedia+nIQS)/2, nMedia)

			// Verifica em que faixa do Criterio Skip-Lote se encontra
			dbSeek(xFilial("QEX")+Str(nNota,6,2), .T.)
			If !Eof() .And. QEX_FILIAL == xFilial("QEX")
				lAtuSkip := .T.
			EndIf

			If nIQS == 999.99
			
				// Sem IQS, utiliza 2 faixas anteriores
				nPos := Ascan(aQEX,QEX_VLSUP)
				nPos := If(nPos>2,nPos-2,1)

				// Posiciona no arquivo a faixa correspondente
				dbSeek(xFilial("QEX")+Str(aQEX[nPos],6,2))

			ElseIf nIQS < nNotaMin
			
				// Posiciona na 1a. faixa
				dbSeek(xFilial("QEX"))
			
			EndIf
			
		Else

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica em que faixa do Criterio Skip-Lote se encontra					³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSeek(xFilial("QEX")+Str(nMedia,6,2), .T.)
			If !Eof() .And. QEX_FILIAL == xFilial("QEX")
				lAtuSkip := .T.
			EndIf
			
		EndIf

		If lAtuSkip

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza Skip-Lote para todas as lojas do Fornecedor						³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SA5")  
			dbSetOrder(2)			
			SA5->(dbSeek(xFilial("SA5")+QEV->QEV_PRODUT+QEV->QEV_FORNEC))
			While !Eof() .And. (A5_FILIAL+A5_PRODUTO+A5_FORNECE) ==;
				(xFilial("SA5")+QEV->QEV_PRODUT+QEV->QEV_FORNEC)

				cSkip := QEX->QEX_SKPLOT

				// Grava novo Skip-Lote para todas as lojas do fornecedor
				If A5_ATUAL == "S"

					lAtuSkip = Qiem020SL(A5_FORNECE, A5_LOJA, A5_PRODUTO)

					// Identifica a Classe da Situacao do Prod/Fornec/Loja
					dbSelectArea("QEG")
					dbSetOrder(1)
					dbSeek(xFilial("QEG")+cSitu)

					If QEG_CATEG $ "3.4" .Or. !lAtuSkip		// Sem Skip-Lote e Nao Recebe
						cSkip := Space(aTamSkl[1])

					ElseIf QEG_CATEG == "2"	// Skip-Lote 25%
					
						// Verifica a Unidade do novo Skip-Lote
						dbSelectArea("QEF")
						dbSetOrder(1)
						dbSeek(xFilial("QEF")+cSkip)

						// Se nao for Controla 1/Doc. Entrada, passa p/ 1/4
						If cMvUtSk25 == "S"
							If (QEF_UNSKLT == "D" .Or. (QEF_UNSKLT == "E" .And. QEF_QTDE > 4))
							
								// Assume o Skip-Lote "Controla 1 a cada 4 Entradas"
								dbSetOrder(2)
								For nI := 4 to 1 Step-1
									If dbSeek(xFilial("QEF")+"E"+Str(nI,4))
										cSkip := QEF_SKPLOT
										Exit
									EndIf
								Next nI

							EndIf
						Else 
							cSkip := QEF_SKPLOT
						EndIf	
					EndIf
					
					lContSA5 := .F.
					
					dbSelectArea("SA5")
					
					lContSA5 := If(A5_TIPATU $ "0/1 ",.T.,.F.)     
					
					If lContSA5
						If cSkip <> A5_SKPLOT 
					
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Atualiza o Skip-Lote 													³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cSkipAnt := A5_SKPLOT

							RecLock("SA5", .F.)
							SA5->A5_SKPLOT	:= cSkip
							MsUnLock()           
						
							lAtual := .T.

							// Gera historico do Skip-Lote
							cEspec	:=      "MATA060L"
							cCodAnt	:= cSkipAnt
						
							Qiem021His(cEspec,cCodAnt)

						EndIf
					EndIf
				EndIf
				dbSelectArea("SA5")
				dbSkip()

			EndDo
		EndIf
	EndIf

	dbSelectArea("QEV")
	dbSkip()                        
	
EndDo

If lAtual
	MsgInfo(OemToAnsi(STR0005),OemToAnsi(STR0006)) //"Atualizacao realizada com sucesso"###"Atencao"

Else
	MsgInfo(OemToAnsi(STR0007),OemToAnsi(STR0008)) //"Atualizacao nao foi necessaria"###"Atencao"

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ restaura as areas correntes				 								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aSaveSA5)
RestArea(aSaveQEF)
RestArea(aSaveQEG)

Return(NIL)                                                              


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QIEM021HIS³ Autor ³Paulo Emidio de Barros ³Data  ³03/05/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Historico                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEM020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Qiem021His(cEspec,cCodAnt)
Local cChvHis
Local nSaveSX8 := GetSX8Len()
Local lAtu 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta chave para o Historico											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("QA3")
QA3->(DbSetOrder(1))
If cEspec == "MATA060T"
	 lAtu := IIF(cCodAnt <> SA5->A5_SITU, .t., .f. )
	
	 If Empty(SA5->A5_CHAVE)
    	cChvHis := GetSxeNum("SA5","A5_CHAVE",,6)
    	
    	While ( GetSX8Len() > nSaveSx8 )
			ConfirmSX8()
		EndDo
		
		RecLock("SA5",.F.)
          SA5->A5_CHAVE := cChvHis
        MsUnLock()
    EndIf
   	
    If QA3->(dbSeek(xFilial("SA5")+"MATA060T"+SA5->A5_CHAVE))
		cChvHis := SA5->A5_CHAVE
		lAtu    := .F.
	Else 
		DbSelectArea("SA5")
		SA5->(DbSetOrder(1))
		If DbSeek(xFilial("SA5")+SA5->A5_FORNECE+SA5->A5_LOJA+SA5->A5_PRODUTO)		
			cChvHis := SA5->A5_CHAVE
		Endif
	Endif
Else
	lAtu := IIF(cCodAnt <> SA5->A5_SKPLOT, .t., .f. )
	
	If Empty(SA5->A5_CHAVE)
		cChvHis := GetSxeNum("SA5","A5_CHAVE",,6)
	EndIF
	
	While ( GetSX8Len() > nSaveSx8 )
		ConfirmSX8()
	EndDo
	
	RecLock("SA5",.F.)
      SA5->A5_CHAVE := cChvHis
    MsUnLock()
EndIf 

If lAtu .And. !QA3->(dbSeek(xFilial("QA3")+cEspec+SA5->A5_CHAVE))
	RecLock("QA3",.T.)	
		QA3->QA3_FILIAL := xFilial("QA3")
		QA3->QA3_ESPEC  := cEspec
		QA3->QA3_CHAVE  := SA5->A5_CHAVE
		QA3->QA3_DATINV := Inverte(dDataBase)
Else	
	RecLock("QA3",.F.)	
EndIf

	QA3->QA3_TEXTO  := OemToAnsi(STR0009) //"Atualizado automaticamente pelo sistema."
	QA3->QA3_DATA   := dDataBase
	QA3->QA3_ANT    := cCodAnt
MsUnLock()

Return(NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} Qiem020SL()
Retornar se deve realizar a atualização do skip lote com base mo
parâmetro MV_QSKLENT
@author Roberto Reffo
@since 21/03/2019
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Static Function Qiem020SL(cFornec, cLoja, cProdut)
	local nSklEnt  := GetMv("MV_QSKLENT")	// "No. Entradas iniciais p/ aplicacao skip-lote"
	local iContEnt := 0	
	local lRet     := .F.

    QEK->(dbSetOrder(2)) 
    QEK->(dbSeek(xFilial("QEK") + cFornec + cLoja + cProdut))
    While QEK->(!Eof() .and. (QEK->QEK_FORNEC == cFornec .and. ;
	                      QEK->QEK_LOJFOR == cLoja   .and. ;
                              QEK->QEK_PRODUT == cProdut ))	
	    iContEnt++
		if iContEnt >= nSklEnt 
		    lRet := .T.
			Exit
		EndIf
		QEK->(dbSkip())	
    EndDo
	
Return lRet
