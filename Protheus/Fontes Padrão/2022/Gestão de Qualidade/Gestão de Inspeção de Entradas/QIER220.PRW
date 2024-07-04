#Include "QIER220.CH"
#Include "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIER220  ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³22/02/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao das Fichas dos Produtos que foram importados     ³±±
±±³          ³ corretamente e que estao marcados para inspecao.           ³±±
±±³          ³ Imprime tambem as etiquetas de rastreabilidade e de laudo. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ QIER220()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Chamado a partir do QIEA180.PRW                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Vera        ³19/04/99³------³ Inclusao da Loja do Fornecedor           ³±±
±±³Vera        ³24/09/99³------³ Opcao de impr. tambem as etiquetas rastr.³±±
±±³            ³        ³      ³ e de laudo se vier pelo menu Prod-Import.³±±
±±³Paulo Emidio³18/05/00³------³Retirada da Funcao de ajuste do SX1       ³±±
±±³Marcelo     ³13/07/00³      ³ Inclusao da pergunta Imprime Entrada em  ³±±
±±³            ³        ³      ³ Skip-Lote (S/N).                         ³±±
±±³Paulo Emidio³29/09/00³----- ³ Alteracao na exibicao dos caracteres inva³±±
±±³            ³        ³      ³ lidos.                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIER220(cProg,aGravDad)
// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Par„metros para a fun‡„o SetPrint () ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL wnrel     := "QIER220"
LOCAL cString   := "QEK"
LOCAL cDesc1    := OemToAnsi(STR0001)	//"Neste relatorio ser„o relacionados os ensaios a serem realizados em ca-"
LOCAL cDesc2    := OemToAnsi(STR0002)	//"da laboratorio, para a validacao da Entrada."
LOCAL cDesc3    := ""
Local lEsc	    := .F.
Local lImpFic   := .F.
Local lEtiqRast	:= .F.
Local lEtiqLaudo:= .F.

Private lreport
// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Par„metros para a fun‡„o Cabec()  ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cTitulo   :=	GetMv("MV_QEFICHP")+ STR0003	// - USO
PRIVATE cRelatorio:=	"QIER220"
PRIVATE cTamanho  := "G"
PRIVATE nPagina   := 1
Private LI        := 80

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vari veis utilizadas pela fun‡„o SetDefault () ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private	aReturn  := {STR0004, 1,STR0005,  1, 2, 1, "",1 }  //"Zebrado"###"Administracao"
Private	nLastKey := 0  
Private cPerg    := "QER220"
Private	cMV_PAR01 
Private	cMV_PAR02 
Private	cMV_PAR03 
Private	cMV_PAR04 
Private	cMV_PAR05 
Private	cMV_PAR06 
Private lExistBol := IIf(ExistBlock("QIER200R"),.T.,.F.)
Private lExistRas := IIf(ExistBlock("QIER240R"),.T.,.F.)
Private lExistLau := IIf(ExistBlock("QIER270R"),.T.,.F.)
Private cCabec1   := ""
Private cCabec2   := ""

If AllTrim(FunName()) == "QIER220" 

	If !Pergunte(cPerg,.T.)
  		lEsc := .T.
  	EndIf

  	cMV_PAR01 := mv_par01
  	cMV_PAR02 := mv_par02
  	cMV_PAR03 := mv_par03
  	cMV_PAR04 := mv_par04
  	cMV_PAR05 := mv_par05
  	cMV_PAR06 := mv_par06
Else

	cPerg := "QIE200"
	Pergunte(cPerg,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existem Entradas corretas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QEP")
	dbSetOrder(1)
	If !(dbSeek(xFilial("QEP")+"1"))
		lESC := .T.
	EndIf

  	cMV_PAR01 := mv_par01
  	cMV_PAR02 := mv_par02
  	cMV_PAR03 := mv_par03
  	cMV_PAR04 := mv_par04
  	cMV_PAR05 := mv_par05
  	cMV_PAR06 := mv_par06
  	
	If AllTrim(FunName())=="QIEA183"
	  	cPerg := ''
	EndIf  	

EndIf
	
If !lESC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Os valores de mv_par04 e mv_par05 sao  ³
	//³ perdidos depois de passar no execblock ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lImpFic		:= IF(cmv_par01 == 1,.T.,.F.)
	lEtiqRast   := IF(cmv_par02 == 1,.T.,.F.)
	lEtiqLaudo  := IF(cmv_par03 == 1,.T.,.F.)
	
	If lImpFic .Or. lEtiqRast .Or. lEtiqLaudo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia controle para a funcao SETPRINT                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If !lExistBol 
			wnrel := SetPrint(cString,wnrel,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",,cTamanho) 
		Endif			
		
		If nLastKey == 27
			Set Filter To
			Return
		Endif
		
	    If !lExistBol 
			SetDefault(aReturn,cString)
		Endif	
		
		If nLastKey == 27
			Set Filter To
			Return
		Endif
			
		RptStatus({|lEnd| A220Imp(@lEnd,wnRel,cString,lEsc,;
						lImpFic,lEtiqRast,lEtiqLaudo,aGravDad)},cTitulo)
	EndIf					
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A220Imp  ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³23/02/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a impr. ficha p/ entr. marcadas p/ inspecao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ A220Imp(lEnd,wnRel,cString)                       		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd     -  A‡Æo do CodeBlock                              ³±±
±±³          ³ wnRel    -  T¡tulo do relat¢rio                            ³±±
±±³          ³ cString  -  Mensagem                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A220Imp(lEnd,wnRel,cString,lEsc,lImpFic,lEtiqRast,lEtiqLaudo,aGravDad)
Local aVetQEK	:= {}
Local cChvQEK	:= ""
Local lImpres	:= .F.
Local nConta	:= 0
Local nCont		:= 0
Local nTipo 	:= 0
Local lFirst	:= .T.
Local cChvQEK1	:= ""
Local lQIER200R := ExistBlock("QIER200R")
Local lQER200RE := ExistBlock("QER200RE")

If !lEsc

	Li    := 80
	m_Pag := 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime as Fichas dos Produtos para as Entradas corretas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QEP")
	dbSetOrder(1)
	If dbSeek(xFilial("QEP")+"1")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao da Ficha do Produto - Uso, Etiquetas de Rastrea- ³
		//³ bilidade e de Laudo, independente de inspecionar ou certi- ³
		//³ ficar a Entrada.                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If LI > 58 .And. lImpFic .And. (!lQER200RE .AND. !lQIER200R)
			Cabec(cTitulo,cCabec1,cCabec2,wnrel,cTamanho,nTipo,,.F.)
		EndIf	
		
		While !Eof() .And. QEP_FILIAL == xFilial("QEP") .And. QEP_CODTAB == "1" 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a Entrada nao foi excluida  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If QEP->QEP_EXCLUI == "S"
				dbSkip()
				Loop
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se foi chamada pelo menu de Relatorios, verifica se já foi   ³
			//³ impressa, se a opcao for a 2 - somente as nao impressas.     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cMV_PAR06 == 2 //1=Todas 2=Atual
				If AllTrim(FunName()) == "QIER220"	.or. AllTrim(FunName()) == "QIEA183"
					If QEP->QEP_IMPFIC == "S"
						dbSkip()
						Loop
					EndIf
				EndIf
			EndIf         
			
			QEK->(dbSetOrder(14))
			cChvQEK := xFilial("QEK")+QEP->QEP_FORNEC+QEP->QEP_LOJFOR+;
					QEP->QEP_PRODUT+QEP->QEP_NTFISC+QEP->QEP_SERINF+DtoS(QEP->QEP_DTENTR)+QEP->QEP_LOTE

			
			// Localiza a Entrada
			If QEK->(dbSeek(cChvQEK))
			
				While !QEK->(Eof())
						IF Alltrim(QEK->QEK_ITEMNF+QEK->QEK_TIPONF) == Alltrim(QEP->QEP_ITEMNF+QEP->QEP_TIPONF) 		            
			    			If cMV_PAR06 == 2 //1=Todas 2=Atual
								If AllTrim(FunName()) == "QIEA200" 
									If QEP->QEP_INSPOB == "P" 
										QEP->(dbSkip())
										Loop
									EndIf
								EndIf
							EndIf	
																
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Imprime Ficha do Produto - Uso ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lImpFic  // Imprime o Relat¢rio
								If lQIER200R
									If lFirst 
										lFirst := .F.
										SetaPilha()	// precisa porque chama lprint mais de 1 vez
										cChvQEK1 := xFilial("QEK")+QEP->QEP_FORNEC+QEP->QEP_LOJFOR+QEP->QEP_PRODUT+QEP->QEP_NTFISC+QEP->QEP_SERINF+QEP->QEP_ITEMNF+QEP->QEP_TIPONF+DTOS(QEP->QEP_DTENTR)+QEP->QEP_LOTE								 
										ExecBlock("QIER200R",.f.,.f.,{"QIER220",aGravDad,{cChvQEK1}})
										SetaPilha()
									Endif
									If aGravDad <> NIL .and. !Alltrim(FunName()) $ "QIER220.QIEA200"
										nConta := Len(aGravDad)
									Endif	
									
								Else								
									lImpres := .T.
									SetWFirstPage(.F.)
									QIER200("QIER220",lImpres,@nConta,aGravDad,@lReport)
								EndIf
							Else
								If aGravDad <> NIL .and. !Alltrim(FunName()) $ "QIER220.QIEA200"
									nConta := Len(aGravDad)						
								Endif	
							EndIf
							Exit
						Endif
						QEK->(dbSetOrder(14))
						QEK->(dbSkip())
   					Enddo  
			
			EndIf		
		
			dbSelectArea("QEP")
			dbSkip()
		EndDo
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime as Etiquetas para as Entradas corretas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QEP")
	dbSetOrder(1)
	If dbSeek(xFilial("QEP")+"1")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao da Ficha do Produto - Uso, Etiquetas de Rastrea- ³
		//³ bilidade e de Laudo, independente de inspecionar ou certi- ³
		//³ ficar a Entrada.                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !Eof() .And. QEP_FILIAL == xFilial("QEP") .And. QEP_CODTAB == "1" 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a Entrada nao foi excluida  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If QEP->QEP_EXCLUI == "S"
				dbSkip()
				Loop
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se foi chamada pelo menu de Relatorios, verifica se já foi   ³
			//³ impressa, se a opcao for a 2 - somente as nao impressas.     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   		If cMV_PAR06 == 2 //1=Todas 2=Atual
				If AllTrim(FunName()) == "QIER220" .or. AllTrim(FunName()) == "QIEA183"
					If QEP->QEP_IMPFIC == "S"
						dbSkip()
						Loop
					EndIf
				EndIf
			EndIf			

			QEK->(dbSetOrder(14))
			cChvQEK := xFilial("QEK")+QEP->QEP_FORNEC+QEP->QEP_LOJFOR+;
					QEP->QEP_PRODUT+QEP->QEP_NTFISC+QEP->QEP_SERINF+DtoS(QEP->QEP_DTENTR)+QEP->QEP_LOTE

			If QEK->(dbSeek(cChvQEK))
				If Alltrim(FunName()) $ "QIER220.QIEA200"	 
					// Guarda o registro da entrega
					Aadd(aVetQEK,cChvQEK)
				Else  
					If nCont < nConta .and. lImpFic
						Aadd(aVetQEK,cChvQEK)					
		        	    nCont++
					Endif             
					If !lImpFic
					    If aGravDad <> NIL
						    aVetQEK := aClone(aGravDad)
						Endif    
					Endif
				Endif	
			EndIf		
			dbSelectArea("QEP")
			dbSkip()
		EndDo
		
		If Len(aVetQEK) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime Etiqueta de Rastreabilidade ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lEtiqRast   // Imprime a Etiqueta de Rastreabilidade
				If ExistBlock("QIER240R")
					SetaPilha()
					Execblock("QIER240R",.f.,.f.,{"QIER220",cMv_par04,cMv_par05,aVetQEK,aGravDad,lImpFic})
					SetaPilha()
				Else
					QIER240("QIER220",cMv_par04,cMv_par05,aVetQEK,aGravDad,lImpFic)
				Endif
			Endif
		Endif		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Etiqueta de Laudo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEtiqLaudo
			If cmv_par03 == 1
				If ExistBlock("QIER270R")
					SetaPilha()
					ExecBlock("QIER270R",.F.,.F.,{"QIER220",cMv_par04,cMv_par05,aVetQEK,aGravDad,lImpFic,lEtiqRast})
					SetaPilha()
				Else       
					QIER270("QIER220",cMv_par04,cMv_par05,aVetQEK,lImpFic,lEtiqRast)
				EndIf
			Endif
		EndIf
	EndIf
EndIf

Return
