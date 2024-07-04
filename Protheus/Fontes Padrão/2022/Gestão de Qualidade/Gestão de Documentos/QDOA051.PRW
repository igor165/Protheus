#INCLUDE "QDOA051.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QDOA051  ³ Autor ³ Newton R. Ghiraldelli ³ Data ³ 01/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Criticas do Documento                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico ( Windows )                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Eduardo S.  ³05/04/02³------³ Melhoria e Otimizacao.                   ³±±
±±³Eduardo S.  ³09/04/02³------³ Acerto na Finalizacao da etapa de Digita-³±±
±±³            ³        ³      ³ cao com critica.                         ³±±
±±³Eduardo S.  ³14/05/02³------³ Alterado para permitir a finalizacao so- ³±±
±±³            ³        ³      ³ mente pelos botoes OK e CANCELAR.        ³±±
±±³Eduardo S.  ³24/08/02³059434³ Acerto para destravar o arquivo no final ³±±
±±³            ³        ³      ³ da gravacao.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOA051(cAlias,nOpc)
Local aButCrit   := {}
Local aTxtCri    := Aclone(aTxtResul) //BKP do Textos
Local aUsrBut    := {}
Local aUsrMat    := QA_USUARIO()
Local cMvQDBxAle := GetMv("MV_QDBXALE",.F.,"N")
Local cStatus    := M->QDH_STATUS
Local lElabDigit := .f.
Local lFecha     := .F.
Local lMvQDOJust := GetMV("MV_QDOJUST",.F.,"N") == "S"
Local nC         := 0
Local nCnt       := 0
Local nOrdQd1    := QD1->(IndexOrd())
Local nPosBx     := 0
Local nVolta     := 0
Local oCodDoc	 := Nil
Local oDesTit	 := Nil	
Local oDlg1		 := Nil
Local oGet		 := Nil
Local oRvDoc	 := Nil

Private aCols    := {}
Private aHeader  := {}
Private aLeuCrit := {.F.}
Private cCodDoc  := ""
Private cDesTit  := ""
Private cMatCod  := aUsrMat[3]
Private cMatDep  := aUsrMat[4]
Private cMatFil  := aUsrMat[2]
Private cRvDoc   := ""
Private cTpTXT   := ""

If Empty(M->QDH_DOCTO) .Or. Empty(M->QDH_RV) .Or. M->QDH_STATUS $ "D  ,I  "
	Return .F.
EndIf

If M->QDH_STATUS == "E  "
	cStatus:= "DC "
ElseIf M->QDH_STATUS $ "R  ,A  ,H  ,L  "
	cStatus:= "EC "
EndIf

If M->QDH_STATUS == "EC "
	QD1->(DbSetOrder(2))
	If QD1->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+"D"))
		If cFilMat+cMatCod+cMatDep == QD1->QD1_FILMAT+QD1->QD1_MAT+QD1->QD1_DEPTO
			lElabDigit := .T.
		EndIf
	EndIf
	QD1->(DbSetOrder(nOrdQd1))
EndIf

If QD4->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV))
	While QD4->(!Eof()) .And. QD4->QD4_FILIAL+QD4->QD4_DOCTO+QD4->QD4_RV == M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV
		nCnt++		
		AADD(aLeuCrit,.F.)
		If cMvQdBxAle == "S" .AND. 	M->QDH_STATUS <> "DC " .AND. M->QDH_STATUS <> "EC " .AND. QD4->QD4_PENDEN == "P" .AND.;
		    nOpc <> 2 .AND. QD4->QD4_FILMAT+QD4->QD4_MAT!=cMatFil+cMatCod		    
			Help(" ",1,"QD050ECP",,OEMTOANSI(STR0012)+QD4->QD4_FILMAT+"-"+QD4->QD4_MAT,04,00) // "Existem criticas pendentes para este documento." //"Criada Pelo Usuario "
			nOpc:= 2
		Endif
		QD4->(DbSkip())
	EndDo
Else
	If nOpc == 2 
		MsgAlert(OemToAnsi(STR0002),OemToAnsi(STR0003)) // "N„o existe cr¡ticas cadastradas..." ### "Aten‡„o"
		Return .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor aHeader a ser utilizado na getdados              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader	:=Aclone(aHedDoc[5]) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols               					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols	:=Aclone(aQD4DOC)
IF Empty(aCols[1,1])
	aCols[1,1]:="00000000000000000001"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Erro no Binario de Deletar a primeira linha do aCols³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF aCols[1,Len(aCols[1])]
	aCols[1,Len(aCols[1])]:=.F.
	lErroDel:= .T.
Else
	lErroDel:= .F.	
Endif	

cCodDoc := M->QDH_DOCTO
cRvDoc  := M->QDH_RV
cDesTit := M->QDH_TITULO

DEFINE MSDIALOG oDlg1 TITLE OemToAnsi(STR0001) FROM 000,000 TO 022,080 OF oMainWnd // "Manuten‡„o de Cr¡ticas"

@ 032,005 TO 58,311 OF oDlg1 PIXEL

@ 034,008 SAY OemToAnsi(STR0004)+": " SIZE 030,007 OF oDlg1 PIXEL  // "Documento"
@ 034,040 MSGET oCodDoc VAR cCodDoc SIZE 060,008 OF oDlg1 PIXEL
@ 034,105 MSGET oRvDoc VAR cRvDoc SIZE 012,008 OF oDlg1 PIXEL
oCodDoc:lReadOnly:= .T.
oRvDoc:lReadOnly:= .T.

@ 046,008 SAY OemToAnsi(STR0005)+": " SIZE 030,007 OF oDlg1 PIXEL  // "T¡tulo"
@ 046,040 MSGET oDesTit VAR cDesTit SIZE 240,008 OF oDlg1 PIXEL
oDesTit:lReadOnly:= .T.

If M->QDH_STATUS $ "DC ,EC " .And. nOpc <> 2
	nPosBx:= aScan(aHeader,{|x| Upper(AllTrim(X[2])) == "QD4_DTFIM" })
	If lMvQDOJust
		aButCrit:= {	{"SDUPROP", { || QD051EdTxt(If((nPosBx > 0 .And. !Empty(aCols[n,nPosBx])) .Or. lElabDigit,2,nOpc))},OemToAnsi(STR0006),OemToAnsi(STR0010)},; // "Texto da Cr¡tica" //"Txt Crit"
						{"NOTE", { || If(nPosBx > 0 .And. Empty(aCols[n,nPosBx]),QD051BxCri(oGet,nOpc),"")},OemToAnsi(STR0007),OemToAnsi(STR0011)},; // "Baixa Cr¡tica" //"Baixa Cr"
		                {"RELATORIO", { || If(nPosBx > 0 .And. !Empty(aCols[n,nPosBx]),QD051EdJus(2),MsgAlert(STR0013))},OemToAnsi(STR0014),OemToAnsi(STR0015)}} // "Justificativa disponível somente para críticas já baixadas" ### "Texto da Justificativa" ### "Txt Just"
	Else
		aButCrit:= {	{"SDUPROP", { || QD051EdTxt(If((nPosBx > 0 .And. !Empty(aCols[n,nPosBx])) .Or. lElabDigit,2,nOpc))},OemToAnsi(STR0006),OemToAnsi(STR0010)},; // "Texto da Cr¡tica" //"Txt Crit"
						{"NOTE", { || If(nPosBx > 0 .And. Empty(aCols[n,nPosBx]),QD051BxCri(oGet,nOpc),"")},OemToAnsi(STR0007),OemToAnsi(STR0011)}} // "Baixa Cr¡tica" //"Baixa Cr"
	Endif
Else
	nPosBx:= aScan(aHeader,{|x| Upper(AllTrim(X[2])) == "QD4_DTFIM" })
	If lMvQDOJust
		aButCrit:= {	{"SDUPROP", { || QD051EdTxt(If((nPosBx > 0 .And. !Empty(aCols[n,nPosBx])) .Or. lElabDigit,2,nOpc))},OemToAnsi(STR0006),OemToAnsi(STR0010)} ,; // "Texto da Cr¡tica" //"Txt Crit"
		            	{"RELATORIO", { || If(nPosBx > 0 .And. !Empty(aCols[n,nPosBx]),QD051EdJus(2),MsgAlert(STR0013))},OemToAnsi(STR0014),OemToAnsi(STR0015)}} // "Justificativa disponível somente para críticas já baixadas" ### "Texto da Justificativa" ### "Txt Just"
	Else
		aButCrit:= {	{"SDUPROP", { || QD051EdTxt(If((nPosBx > 0 .And. !Empty(aCols[n,nPosBx])) .Or. lElabDigit,2,nOpc))},OemToAnsi(STR0006),OemToAnsi(STR0010)}} // "Texto da Cr¡tica" //"Txt Crit"
	Endif
EndIf  
If ExistBlock( "QD051BUT" )
	If Valtype( aUsrBut := Execblock( "QD051BUT", .f., .f. ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButCrit, x ) } )
	EndIF
EndIf

If M->QDH_STATUS $ "DC ,D  ,E  ,EC ,A  ,R  ,H  " .And. (nOpc == 3 .Or. nOpc == 4)
	If M->QDH_STATUS <> "DC "
		oGet := MSGetDados():New( 065, 006, 155, 312, 4, "QD051LinOk", "", "+QD4_SEQ" , .t.,,,,If(lElabDigit,Len(aCols),Len(aCols)+1),,,,"QD051Exc")
	Else
		oGet := MSGetDados():New(065,006,155,312,2)	
	EndIf
  	IF lErroDel
		aCols[1,Len(aCols[1])]:=.T.
	Endif	

	ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,;
					{|| If(Obrigatorio(aGets,aTela) .And. QD051LinOk(),(aQD4doc:=aClone(aCols),lFecha:= .T.,oDlg1:End()),.F.)},;
					{|| aTxtResul:=aClone(aTxtCri),oDlg1:End()},,aButCrit) CENTERED VALID lFecha                   										
Else
	oGet := MSGetDados():New(047,005,136,312,2)
  	IF lErroDel
		aCols[1,Len(aCols[1])]:=.T.
	Endif	

	ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,	{|| oDlg1:End()},{|| oDlg1:End()},,aButCrit) CENTERED
EndIf

If Inclui .Or. nOpc == 7
	lIncDepois:= .T.
EndIf

If QD4->(DbSeek(M->QDH_FILIAL + cCodDoc + cRvDoc))
	While !(QD4->(Eof())) .And. QD4->QD4_FILIAL+QD4->QD4_DOCTO+QD4->QD4_RV == M->QDH_FILIAL + cCodDoc + cRvDoc
		nVolta:= Val(Alltrim(QD4->QD4_SEQ))
		QD4->(DbSkip())
	EndDo
EndIf

For nC:= 1 to Len(aQD4doc)
	If Len(aQD4Ini) < Len(aQD4Doc) .And. nC > Len(aQD4Ini)
		aAdd(aQD4Ini,aClone(aQD4Doc[nc]))

		If M->QDH_STATUS $ "E  ,EC "
			aAdd(aQD4Ini[Len(aQD4Ini)],"DC ")
		ElseIf M->QDH_STATUS $ "R  ,A  ,H  "
			aAdd(aQD4Ini[Len(aQD4Ini)],"EC ")
		Else
			aAdd(aQD4Ini[Len(aQD4Ini)],M->QDH_STATUS)
		EndIf

		aAdd(aQD4Ini[Len(aQD4Ini)],cMatFil)
		aAdd(aQD4Ini[Len(aQD4Ini)],cMatCod)

	Endif
Next

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QD051LinOk ³ Autor ³ Newton R. Ghiraldelli³ Data ³ 01/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Critica a linha digitada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD051LinOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA051()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD051LinOk()
Local cEspecie   := Left("CRI"+Space(8),8)
Local laTxt      := VALTYPE(aTxtResul)=="A"
Local lRet		 := .T.
Local nPosCRI	 := aScan(aTxtResul, {|x| x[1] == cEspecie})
Local nPosTxt	 := aScan(aTxtResul, {|x| x[2] == aCols[n][6]})

	If !aCols[ n, Len( aHeader ) + 1 ] .AND. laTxt
		If Empty(aCols[n][6]) .Or. nPosCRI == 0 .Or. nPosTxt == 0 .Or. Empty( Alltrim( aTxtResul[nPosTxt][3][1][2] ) ) 
			Help(" ",1,"QATXTCRIBR")
			lRet :=  .F.
		EndIf 
	EndIf

	If lRet .AND. Len(aLeuCrit) < (Len(Acols))
		AADD(aLeuCrit,.F.)
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD051EdTxt ³ Autor ³ Newton R. Ghiraldelli³ Data ³ 01/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Abra a janela para digitacao do texto da critica           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD051EdTxt( ExpN1 )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA051                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD051EdTxt(nOpc)

Local nPos      := GdFieldPos("QD4_SEQ"  ,aHeader)
Local nPosChave := GdFieldPos("QD4_CHAVE",aHeader)
Local cCabec    := OemtoAnsi(STR0008) // "Cr¡ticas"
Local cTitulo   := OemtoAnsi(STR0008) // "Cr¡ticas"
Local cChave    := ""
Local cCod      := "Doc: " + M->QDH_DOCTO + " Rev: " + M->QDH_RV + " Num: " + aCols[ n, nPos ]
Local cEspecie  := Left( "CRI" + Space( 8 ), 8 )
Local nTamLin   := TamSX3( "QA2_TEXTO" )[1]
Local lEdit     := .f.
Local axTextos  := {}
Local cSvFilAnt	:= cFilAnt

If Empty(M->QDH_DOCTO) .Or. Empty(M->QDH_RV) .Or. aCols[n,Len(aHeader)+1]
	Return .F.
EndIf

If Empty(Acols[n][nPosChave])
	cChave:= QA_CvKey(M->QDH_FILIAL+cCod,"QD4",2)
	Acols[n][nPosChave]:= cChave
Else
	cChave:= Acols[n][nPosChave]
	If Len(aLeuCrit) < (Len(Acols))
		AADD(aLeuCrit,.T.)
	Else
		aLeuCrit[n]:= .T.
	EndIf
EndIf

If (M->QDH_STATUS $ "D  ,E  ,EC ,A  ,R  ,H  " .And. nOpc <> 2)
	lEdit := .T.
EndIf

If QD4->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+Acols[n][nPos]))
	If !QD4->QD4_FILMAT+QD4->QD4_MAT == cMatFil+cMatCod .OR. Alltrim(M->QDH_STATUS) == "EC"
		lEdit := .F.
	Endif
Endif

nLocTxt:=ASCAN(aTxtREsul,{|X| x[1]==cEspecie .AND. X[2]==cChave})

If  FWModeAccess("QA2") == "E" //!Empty(xFilial("QA2"))
	cFilAnt		 := QDH->QDH_FILMAT //Mudo a Variavel publica de Memória como na SuperGetMV
EndIf
	
If nLocTxt==0
	If QA_TEXTO( cChave, cEspecie, nTamlin, cTitulo, cCod, @axtextos, 1, cCabec, lEdit )
		If ! Len(axtextos[1][2]) > 0 .or. axtextos[1][2]== space(Len(axtextos[1][2]))
			Help(" ",1,"QATXTCRIBR")					
			Return(.F.)
		EndIf	
  		AADD(aTxtREsul , {cEspecie,cChave, axtextos} )	   
  	ENDIF
Else  		
	axtextos := aTxtREsul[nLocTxt,3]
	If QA_TEXTO( cChave, cEspecie, nTamlin, cTitulo, cCod, @axtextos, 1, cCabec, lEdit )
		If ! Len(axtextos[1][2]) > 0 .or. axtextos[1][2]== space(Len(axtextos[1][2]))
			Help(" ",1,"QATXTCRIBR")					
			Return(.F.)
		EndIf	
		aTxtREsul[nLocTxt,3]:= axtextos
	Endif	
EndIf

If  FWModeAccess("QA2") == "E" //!Empty(xFilial("QA2"))
	cFilAnt      := cSvFilAnt    //Restauro a Variavel publica de Memória como na SuperGetMV
EndIf
	
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QD051Grav ³ Autor ³ Newton R. Ghiraldelli³ Data ³ 01/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Grava os lancamentos das Criticas por Documento            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD051Grav()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA051()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD051Grav(aColsAux)

Local aUsrMat  	:= QA_USUARIO()
Local cMatFil  	:= aUsrMat[2]
Local cMatCod  	:= aUsrMat[3]
Local cMatDep  	:= aUsrMat[4]
Local nPos1    	:= GdFieldPos("QD4_SEQ"   ,aHedDoc[5])
Local nPos2    	:= GdFieldPos("QD4_PENDEN",aHedDoc[5])
Local nPosChave	:= GdFieldPos("QD4_CHAVE" ,aHedDoc[5])
Local nPosDtIni	:= GdFieldPos("QD4_DTINIC",aHedDoc[5])
Local nPosDtFim	:= GdFieldPos("QD4_DTFIM" ,aHedDoc[5])
Local nCnt		:= 0
Local cStatus	:=""

If SubsTr(M->QDH_STATUS,1,1) == "E"
	cStatus := "DC "
ElseIf M->QDH_STATUS $ "R  /A  /H  "
	cStatus := "EC "
EndIf

For nCnt:= 1 to Len(aColsAux)
	If aColsAux[nCnt][leN(aColsAux[nCnt])] == .F.
		If QD4->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+aColsAux[nCnt][nPos1]))
			If QD4->QD4_PENDEN == "B" .Or. (M->QDH_STATUS == "EC " .And. aColsAux[nCnt][nPos2] == "P")
				Loop
			EndIf
			RecLock("QD4",.F.)
		Else
			RecLock("QD4",.T.)
			QD4->QD4_FILIAL := M->QDH_FILIAL
			QD4->QD4_DOCTO  := M->QDH_DOCTO
			QD4->QD4_RV     := M->QDH_RV
			QD4->QD4_SEQ    := aColsAux[nCnt][nPos1]
			QD4->QD4_TPPEND := cStatus
		EndIf
		QD4->QD4_DTINIC := aColsAux[nCnt][nPosDtIni]
		QD4->QD4_DTFIM  := aColsAux[nCnt][nPosDtFim]
		If aColsAux[nCnt][nPos2] == "P"
			QD4->QD4_PENDEN := aColsAux[nCnt][nPos2]
			If Empty(QD4->QD4_FILMAT)
				QD4->QD4_FILMAT := cMatFil
	   		EndIf
			If Empty(QD4->QD4_MAT)
				QD4->QD4_MAT    := cMatCod
			EndIf
		ElseIf Empty(QD4->QD4_DTBAIX)
			QD4->QD4_DTFIM  := dDataBase
			QD4->QD4_DTBAIX := dDataBase
			QD4->QD4_PENDEN := "B"
			QD4->QD4_HRBAIX := Substr( Time(), 1, 5 )
			QD4->QD4_FMATBX := cMatFil
			QD4->QD4_MATBX  := cMatCod
			QD4->QD4_DEPBX  := cMatDep
		EndIf
		QD4->QD4_CHAVE  := aColsAux[nCnt][nPosChave]
		QD4->(MsUnlock())
		FKCOMMIT()
	Else
		If QD4->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+aColsAux[nCnt][nPos1]))
			RecLock("QD4",.F.)
			QD4->(DbDelete())
			QD4->(MsUnlock())  			
			FKCOMMIT()		
			QD4->(DbSkip())
		EndIf
	EndIf
Next nCnt

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QD051BxCri³ Autor ³ Newton R. Ghiraldelli³ Data ³ 01/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza a baixa das criticas                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD051BxCri( ExpO1,ExpN1 )                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto do get                                      ³±±
±±³          ³ ExpN1 - Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA051()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD051BxCri(oGet,nOpc)

Local nPos1 := Ascan( aHeader, { |X| Upper( Alltrim( X[2] ) ) == "QD4_SEQ" } )
Local nPos2 := Ascan( aHeader, { |X| Upper( Alltrim( X[2] ) ) == "QD4_PENDEN" } )
Local nPos3 := Ascan( aHeader, { |X| Upper( Alltrim( X[2] ) ) == "QD4_DTFIM" } )

If Len(aCols) > Len(aQD4Ini)
	Return .F.
Endif

If M->QDH_STATUS <> aQD4Ini[n,Len(aCols[n])+1]
	Return .F.
EndIf

If Len(aLeuCrit) < (Len(Acols))
	AADD(aLeuCrit,.F.)
EndIf

If aLeuCrit[n]
	If nPos1 > 0 .And. nPos2 > 0
		If aCols[ n,nPos2 ] == "P"
			If MsgYesNo(OemToAnsi(STR0009),OemToAnsi(STR0003))  //"Confirma Baixa da Critica?" ### "Aten‡„o"
				aCols[n,nPos2]:= "B"
				aCols[n,nPos3]:= dDatabase
				oGet:oBrowse:Refresh(.t.)        
				If GetMV("MV_QDOJUST",.F.,"N") == "S"
					QD051EdJus(3)
				Endif
			EndIf
		EndIf
	EndIf
Else
	Help(" ", 1,"QD051LECRI") //Nao e possivel finalizar critica ### Leia a critica antes de finalizar
	Return .F.
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QD051Exc  ³ Autor ³ Eduardo de Souza     ³ Data ³ 13/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exclui critica                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD051Exc( ExpO1, ExpL1, ExpL2, ExpB1 )                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA051()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD051Exc()

Local aUsrMat := QA_USUARIO()
Local nPosPend:= Ascan( aHeader,{ |X| Upper( Alltrim( X[2] ) ) == "QD4_PENDEN" } )
Local nPosSeq := Ascan( aHeader,{ |X| Upper( Alltrim( X[2] ) ) == "QD4_SEQ" } )

If Acols[n,Len(aCols[n])]
	If QD4->(DbSeek(M->QDH_FILIAL+M->QDH_DOCTO+M->QDH_RV+Acols[n][nPosSeq]))
		If !(aUsrMat[3] == QD4->QD4_MAT .And. Acols[n][nPosPend] == "P")
			Acols[n,Len(aCols[n])]:= .F.
			Help(" ", 1, "QD051DELCR")  // "Nao e possivel deletar critica ### verifique se o usuario logado e responsavel pela critica e se esta Pendente.
		EndIf
	EndIf
EndIf

Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD051EdJus ³ Autor ³ Newton R. Ghiraldelli³ Data ³ 13/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Abra a janela para digitacao do texto da Justificativa     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QD051Edjus( ExpN1 )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QDOA051                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD051EdJus(nOpc)

Local nPos      := GdFieldPos("QD4_SEQ"  ,aHeader)
Local nPosChave := GdFieldPos("QD4_CHAVE",aHeader)
Local cCabec    := OemtoAnsi(STR0017) // "Justificativa"
Local cTitulo   := OemtoAnsi(STR0017) // "Justificativa"
Local cChave    := ""
Local cCod      := "Doc: " + M->QDH_DOCTO + " Rev: " + M->QDH_RV + " Num: " + aCols[ n, nPos ]
Local cEspecie  := Left( "JUS" + Space( 8 ), 8 )
Local nTamLin   := TamSX3( "QA2_TEXTO" )[1]
Local lEdit     := .f.
Local axTextos  := {}

If Empty(M->QDH_DOCTO) .Or. Empty(M->QDH_RV) .Or. aCols[n,Len(aHeader)+1]
	Return .F.
EndIf

If Empty(Acols[n][nPosChave])
	cChave:= QA_CvKey(M->QDH_FILIAL+cCod,"QD4",2)
	Acols[n][nPosChave]:= cChave
Else
	cChave:= Acols[n][nPosChave]
EndIf

If nOpc == 3
	lEdit := .T.
EndIf

nLocTxt:=ASCAN(aTxtREsul,{|X| x[1]==cEspecie .AND. X[2]==cChave})
	
IF nLocTxt==0
	While .t.
		If QA_TEXTO( cChave, cEspecie, nTamlin, cTitulo, cCod, @axtextos, 1, cCabec, lEdit )
	  		AADD(aTxtREsul , {cEspecie,cChave, axtextos} )	   
	  		Exit
		Else
			If lEdit
				MsgStop(STR0016)	// "É obrigatório o preenchimento da justificativa"
			Else
				Exit
			Endif
		ENDIF
	Enddo	
Else  		
	axtextos := aTxtREsul[nLocTxt,3]
	While .t.
		If QA_TEXTO( cChave, cEspecie, nTamlin, cTitulo, cCod, @axtextos, 1, cCabec, lEdit )
			aTxtREsul[nLocTxt,3]:= axtextos
			Exit
		Else
			If lEdit
				MsgStop(STR0016)	// "É obrigatório o preenchimento da justificativa"
			Else
				Exit
			Endif
		Endif	
	Enddo
EndIf

Return .T.
