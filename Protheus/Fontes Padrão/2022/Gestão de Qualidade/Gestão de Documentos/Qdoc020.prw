#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "QDOC020.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QDOC020    ³ Autor ³ Eduardo de Souza           ³ Data ³ 04/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Historico de Documentos                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QDOC020()                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ SIGAQDO - Controle de Documentos                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Observacoes ³                                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³   Data   ³ BOPS ³ Programador ³                 Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 15/01/02 ³012645³ Eduardo S.  ³ Acerto no posicionamento qdo for Topconnect     ³±±
±±³ 04/02/02 ³ ---- ³ Eduardo S.  ³ Incluido Mensagem sobre o processamento.        ³±±
±±³ 26/08/02 ³ ---- ³ Eduardo S.  ³ Incluido o botao Legenda.                       ³±±
±±³ 17/02/02 ³ ---- ³ Eduardo S.  ³ Acerto para prever qualquer tipo de pendencia.  ³±±
±±³ 03/12/02 ³ ---- ³ Eduardo S.  ³ Alterado para listar os textos (QA2) apartir da ³±±
±±³          ³      ³             ³ funcao QA_RecTxt().                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOC020()

Local oDlg
Local oScrollBox
Local oBtn1
Local oBtn2
Local oDeDocto
Local oAteDocto
Local oCombOrig
Local oCombRv
Local oDeTpDoc
Local oAteTpDoc
Local oDeAssunt
Local oAteAssunt
Local oTitulo
Local oCombStat

Local lGeraTree := .f.
Local aCombOrig := {OemToAnsi(STR0076),OemToAnsi(STR0004),OemToAnsi(STR0003)} // "Ambas" ### "Interno" ### "Externo"
Local aCombRv   := {OemToAnsi(STR0070),OemToAnsi(STR0069)} // "Todas" ### "Ultima"
Local aCombStat := {OemToAnsi(STR0076),; // "Ambas"
							OemToAnsi(STR0024),; // "Vigente"
							OemToAnsi(STR0027),; // "Em Elaboracao"
							OemToAnsi(STR0025),; // "Obsoleto"
							OemToAnsi(STR0026)}  // "Cancelado"

Private cDeDocto  := Space(16)
Private cAteDocto := Replicate("z",16)  // incializa parametro
Private cCombRv   := OemToAnsi(STR0070) // "Todas"
Private cCombOrig := OemToAnsi(STR0076) // "Ambas"
Private cDeTpDoc  := Space(6)
Private cAteTpDoc := Replicate("z",6)   // incializa parametro
Private cDeAssunt := Space(6)
Private cAteAssunt:= Replicate("z",6)   // incializa parametro
Private cTitulo   := Space(100)
Private cCombStat := OemToAnsi(STR0076) // "Ambas"
Private cTpOrigem := ""
Private nCombStat := 0
Private nCombRv   := 0

DEFINE MSDIALOG oDlg FROM 000,000 TO 243,485 PIXEL TITLE OemToAnsi(STR0001) // "Historico de Documentos"
oScrollBox := TScrollBox():new(oDlg,007,007,095,230,.T.,.T.,.T.)

@ 007,003 SAY OemToAnsi(STR0065) SIZE 045,010 OF oScrollBox PIXEL // "De Documento ?"
@ 005,065 MSGET oDeDocto VAR cDeDocto F3 "QDH" SIZE 080,005 OF oScrollBox PIXEL

@ 022,003 SAY OemToAnsi(STR0066) SIZE 045,010 OF oScrollBox PIXEL // "Ate Documento?"
@ 020,065 MSGET oAteDocto VAR cAteDocto F3 "QDH" SIZE 080,005 OF oScrollBox PIXEL

@ 037,003 SAY OemToAnsi(STR0068) SIZE 045,010 OF oScrollBox PIXEL // "Revisao      ?"
@ 035,065 COMBOBOX oCombRv VAR cCombRv ITEMS aCombRv SIZE 040,010 PIXEL OF oScrollBox;
				ON CHANGE (nCombRv:= oCombRv:nAt)

@ 052,003 SAY OemToAnsi(STR0067) SIZE 045,010 OF oScrollBox PIXEL // "Origem Docto ?"
@ 050,065 COMBOBOX oCombOrig VAR cCombOrig ITEMS aCombOrig SIZE 040,010 PIXEL OF oScrollBox;
				ON CHANGE If(oCombOrig:nAt<>1,If(oCombOrig:nAt==2,cTpOrigem:= "I",cTpOrigem:= "E"),)

@ 067,003 SAY OemToAnsi(STR0071) SIZE 045,010 OF oScrollBox PIXEL // "De Tipo Docto ?"
@ 065,065 MSGET oDeTpDoc VAR cDeTpDoc F3 "QD2" SIZE 040,005 OF oScrollBox PIXEL

@ 082,003 SAY OemToAnsi(STR0072) SIZE 045,010 OF oScrollBox PIXEL // "Ate Tipo Docto?"
@ 080,065 MSGET oAteTpDoc VAR cAteTpDoc F3 "QD2" SIZE 040,005 OF oScrollBox PIXEL

@ 097,003 SAY OemToAnsi(STR0073) SIZE 045,010 OF oScrollBox PIXEL // "De Assunto?"
@ 095,065 MSGET oDeAssunt VAR cDeAssunt F3 "QD3" SIZE 040,005 OF oScrollBox PIXEL

@ 112,003 SAY OemToAnsi(STR0074) SIZE 045,010 OF oScrollBox PIXEL // "Ate Assunto?"
@ 110,065 MSGET oAteAssunt VAR cAteAssunt F3 "QD3" SIZE 040,005 OF oScrollBox PIXEL

@ 127,003 SAY OemToAnsi(STR0075) SIZE 045,010 OF oScrollBox PIXEL // "Titulo ?"
@ 125,065 MSGET oTitulo VAR cTitulo SIZE 100,005 OF oScrollBox PIXEL

@ 142,003 SAY OemToAnsi(STR0077) SIZE 045,010 OF oScrollBox PIXEL // "Status?"
@ 140,065 COMBOBOX oCombStat VAR cCombStat ITEMS aCombStat SIZE 050,010 PIXEL OF oScrollBox;
				ON CHANGE (nCombStat:= oCombStat:nAt)

DEFINE SBUTTON oBtn1 FROM 105, 175 TYPE 1 ENABLE OF oDlg;
		ACTION (lGeraTree:=.t.,oDlg:End())
 
DEFINE SBUTTON oBtn2 FROM 105, 205 TYPE 2 ENABLE OF oDlg;
       ACTION  oDlg:End()      

ACTIVATE MSDIALOG oDlg CENTERED

If lGeraTree
	If MsgYesNo(OemToAnsi(STR0086),OemToAnsi(STR0085)) //"Este processo pode levar alguns minutos tem certeza que deseja continuar" ### "Aten‡ao"
   	Processa( {||QDC020Proc() }, OemToAnsi(STR0061), OemToAnsi(STR0060) )
	EndIf
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QDC020Proc ³ Autor ³ Eduardo de Souza           ³ Data ³ 04/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Historico de Documentos                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QDC020Proc()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ SIGAQDO - Controle de Documentos                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDC020Proc()
Local oDlg
Local oTree
Local cBitMap01:= ""
Local cBitMap02:= ""
Local cStatDoc := ""
Local cOldAut  := ""
Local cOldTpPen:= ""
Local cOldDepto:= ""
Local cTpRcbt  := ""
Local cOriRef  := ""
Local cRvObrig := ""
Local	cStatCri := ""
Local nOrdQD1  := QD1->(IndexOrd())
Local nOrdQDG  := QDG->(IndexOrd())
Local cAliasQDH:= ""
Local cDocto   := ""
Local cRv      := ""
Local cChave   := ""
Local cTop	   := ""
Local nReg	   := 0
Local cTexto   := ""
Local nTexto   := 0
Local nCnt     := 0
Local nTamLin  := TamSx3("QA2_TEXTO")[1]
Local cDescPast := ""
Local lPrimeira := .F.
Local lItem := .F.
Local aMsSize	:= MsAdvSize()
Local aObjects  := {{ 100, 100, .T., .T., .T. }}
Local aInfo		:= { aMsSize[ 1 ], aMsSize[ 2 ], aMsSize[ 3 ], aMsSize[ 4 ], 4, 4 } 
Local aPosObj	:= MsObjSize( aInfo, aObjects, .T. , .T. )

Private Inclui:= .f.

// Variaveis utilizadas na pesqusa de texto
Private nSeqTree  := 0
Private cChaveTree:= Space(100)
Private cChaveSeq := "0000"
Private lEditPTree:= .T.

cTop := "S"
	
DbSelectArea("QD1")
DbSetOrder(2)
DbSelectArea("QDG")
DbSetOrder(3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtra Parametros            					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QDC020filt()
cAliasQDH:= Alias()

While !Eof()
	nReg++
	DbSkip()
Enddo

ProcRegua(nReg)

DEFINE MSDIALOG oDlg  TITLE OemToAnsi(STR0001) FROM aMsSize[7],000 TO aMsSize[6],aMsSize[5] OF oMainWnd Pixel // "Historico de Documentos"
oTree := DbTree():New(15, 3, 197, 315, oDlg,,,.T.)
oTree:lShowHint := .F.		// Desabilita o Hint
oTree:Align := CONTROL_ALIGN_ALLCLIENT

DbSelectArea(cAliasQDH)
If cAliasQDH == "QDH"
	DbSeek(xFilial("QDH"))
Else
	DbGotop()
EndIf

While !Eof()
	IncProc()
	cDocto   := QDH_DOCTO
	cRv		:= QDH_RV
	cChave   := QDH_CHAVE
	If cTop == "S"
		dDtVig := STOD(QDH_DTVIG)
		dDtLim := STOD(QDH_DTLIM)
		dDtImpl:= STOD(QDH_DTIMPL)
	Else
		dDtVig := QDH_DTVIG
		dDtLim := QDH_DTLIM
		dDtImpl:= QDH_DTIMPL
	EndIf
	cOldAut  := ""
	cOldTpPen:= ""
	cOldDepto:= ""

    If !Empty(cTitulo) .and. At(Upper(Alltrim(cTitulo)),Upper(QDH_TITULO)) == 0    //Somente filtra se for informado.
		DbSkip()
		Loop
    EndIf
	
	If QDH_OBSOL  == "N" .And. QDH_STATUS == "L  " .And. QDH_CANCEL <> "S"
		cBitMap01 := "FOLDER10" // Verde Fechado
		cBitMap02 := "FOLDER11" // Verde Aberto
		cStatDoc:= "("+OemToAnsi(STR0024)+")" // "Vigente"
	ElseIf QDH_OBSOL  == "N" .And. QDH_STATUS <> "L  " .And. QDH_CANCEL <> "S"
		cBitMap01 := "FOLDER5" // Amarelo Fechado
		cBitMap02 := "FOLDER6" // Amarelo Aberto
		cStatDoc:= "("+OemToAnsi(STR0027)+")" // "Em Elaboracao"
	ElseIf QDH_CANCEL == "S"
		cBitMap01 := "FOLDER14" // Cinza Fechado
		cBitMap02 := "FOLDER15" // Cinza Aberto
		cStatDoc:= "("+OemToAnsi(STR0026)+")" // "Cancelado"
	ElseIf QDH_OBSOL  == "S" .And. QDH_CANCEL <> "S"
		cBitMap01 := "FOLDER7" // Vermelho Fechado
		cBitMap02 := "FOLDER8" // Vermelho Aberto
		cStatDoc:= "("+OemToAnsi(STR0025)+")" // "Obsoleto"
	EndIf

	If QDH_DTOIE == "E"
		cOrigem:= OemToAnsi(STR0003) // "Externo"
	Else
		cOrigem:= OemToAnsi(STR0004) // "Interno"	
	EndIf
	
	DBADDTREE oTree PROMPT PADR((AllTrim(QDH_DOCTO)+" - "+QDH_RV+" - "+Alltrim(QDH_TITULO)),100) RESOURCE cBitMap01,cBitMap02 CARGO StrZero(nSeqTree++,4)

		DBADDITEM oTree PROMPT OemToAnsi(STR0007)+" "+Alltrim(QA_NSIT(QDH_STATUS))+" "+cStatDoc+" - "+OemToAnsi(STR0002)+" "+cOrigem RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Status:" ### "Origem: "
		DBADDITEM oTree PROMPT OemToAnsi(STR0005)+" "+QDXFNANTPD(QDH_CODTP) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Tipo de Documento"
		DBADDITEM oTree PROMPT OemToAnsi(STR0006)+" "+QDXFNANASS(QDH_CODASS)RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Assunto:"
		DBADDITEM oTree PROMPT OemToAnsi(STR0008)+" "+QA_NDEPT(QDH_DEPTOD,.t.,QDH_FILDEP)RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Depto Distribuidor:"
		DBADDITEM oTree PROMPT OemToAnsi(STR0009)+" "+DTOC(dDtVig)+" - "+OemToAnsi(STR0010)+" "+DTOC(dDtLim)+" - "+OemToAnsi(STR0011)+" "+DTOC(dDtImpl)RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Data de Vigencia:" ### "Data Limite:" ### "Data Implantacao"
		
		If QA2->(DbSeek(xFilial("QA2")+"OBJ     "+cChave))
			cTexto:= QA_RecTxt(cChave,"OBJ     ")

			nTexto:= MlCount(cTexto,nTamLin)

			DBADDTREE oTree PROMPT OemToAnsi(STR0015) RESOURCE "OBJETIVO" CARGO StrZero(nSeqTree++,4) // "Objetivo"

			For nCnt:= 1 To nTexto
				DBADDITEM oTree PROMPT Padr(MemoLine(cTexto,nTamLin,nCnt),nTamLin) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Departamento:"			
			Next nCnt		

			DBENDTREE oTree		                                                      
	   EndIf
	      
		If QA2->(DbSeek(xFilial("QA2")+"SUM     "+cChave))
			cTexto:= QA_RecTxt(cChave,"SUM     ")

			nTexto:= MlCount(cTexto,nTamLin)

			DBADDTREE oTree PROMPT OemToAnsi(STR0018) RESOURCE "SUMARIO" CARGO StrZero(nSeqTree++,4) // "Sumario"

			For nCnt:= 1 To nTexto
				DBADDITEM oTree PROMPT Padr(MemoLine(cTexto,nTamLin,nCnt),nTamLin) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Departamento:"
			Next nCnt		

			DBENDTREE oTree		
		EndIf
	
		If QA2->(DbSeek(xFilial("QA2")+"REV     "+cChave))
			cTexto:= QA_RecTxt(cChave,"REV     ")

			nTexto:= MlCount(cTexto,nTamLin)

			DBADDTREE oTree PROMPT OemToAnsi(STR0021) RESOURCE "NOTE" CARGO StrZero(nSeqTree++,4) // "Motivo da Revisao"

			For nCnt:= 1 To nTexto
				DBADDITEM oTree PROMPT Padr(MemoLine(cTexto,nTamLin,nCnt),nTamLin) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Departamento:"
			Next nCnt
			DBENDTREE oTree		
	   EndIf
		
		If QD0->(DbSeek(xFilial("QD0")+cDocto+cRv))
			DBADDTREE oTree PROMPT PADR(OemToAnsi(STR0016),100) RESOURCE "RESPONSA" CARGO StrZero(nSeqTree++,4) // "Responsaveis"
			While QD0->(!Eof()) .And. xFilial("QD0")+cDocto+cRv == QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV
					If QD0->QD0_FLAG <> "I"
						cSit:= OemToAnsi(STR0082)
					Else
						cSit:= OemToAnsi(STR0083)
					EndIf	
					If cOldAut <> QD0->QD0_AUT			
						If Alltrim(QD0->QD0_AUT) == "E"
							DBADDTREE oTree PROMPT OemToAnsi(STR0028) RESOURCE "BMPUSER" CARGO StrZero(nSeqTree++,4) // "Elaboradores"
							cOldAut:= "E"
						ElseIf Alltrim(QD0->QD0_AUT) == "R"
							DBADDTREE oTree PROMPT OemToAnsi(STR0031) RESOURCE "BMPUSER" CARGO StrZero(nSeqTree++,4) // "Revisores"
							cOldAut:= "R"
						ElseIf Alltrim(QD0->QD0_AUT) == "A"
							DBADDTREE oTree PROMPT OemToAnsi(STR0032) RESOURCE "BMPUSER" CARGO StrZero(nSeqTree++,4) // "Aprovadores"
							cOldAut:= "A"
						ElseIf Alltrim(QD0->QD0_AUT) == "H"
							DBADDTREE oTree PROMPT OemToAnsi(STR0033) RESOURCE "BMPUSER" CARGO StrZero(nSeqTree++,4) // "Homologadores"
							cOldAut:= "H"
						EndIf
						DBADDITEM oTree PROMPT OemToAnsi(STR0029)+" "+QD0->QD0_ORDEM+" - "+Alltrim(QA_NUSR(QD0->QD0_FILMAT,QD0->QD0_MAT))+" - "+OemToAnsi(STR0034)+" "+Alltrim(QA_NDEPT(QD0->QD0_DEPTO,.T.,QD0->QD0_FILMAT)+" - "+OemToAnsi(STR0084)+" "+cSit) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Ordem:" ### "Depto:"				   
				   Else
						DBADDITEM oTree PROMPT OemToAnsi(STR0029)+" "+QD0->QD0_ORDEM+" - "+Alltrim(QA_NUSR(QD0->QD0_FILMAT,QD0->QD0_MAT))+" - "+OemToAnsi(STR0034)+" "+Alltrim(QA_NDEPT(QD0->QD0_DEPTO,.T.,QD0->QD0_FILMAT)+" - "+OemToAnsi(STR0084)+" "+cSit) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Ordem:" ### "Depto:"
	              EndIf
				   QD0->(DbSkip())
					If cOldAut <> QD0->QD0_AUT .Or. QD0->(Eof()) .Or. ;
						xFilial("QD0")+cDocto+cRv <> QD0->QD0_FILIAL+QD0->QD0_DOCTO+QD0->QD0_RV
						DBENDTREE oTree
					EndIf
				EndDo
			DBENDTREE oTree
		EndIf
			
		If QDG->(DbSeek(xFilial("QDG")+cDocto+cRv))
            lPrimeira := .F.
			lItem := .F.
			While QDG->(!Eof()) .And. xFilial("QDG")+cDocto+cRv == QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV
				If QDG->QDG_TPRCBT == "4" .Or. QDG->QDG_RECEB == "N"
					QDG->(DbSkip())
					If lPrimeira .and. !lItem
						If cOldDepto <> QDG->QDG_DEPTO .Or. QDG->(Eof()) .Or. ;
							xFilial("QDG")+cDocto+cRv <> QDG->QDG_FILIAL+QDG->QDG_DOCTO+QDG->QDG_RV
							DBENDTREE oTree
							lItem := .F.
						EndIf
					Endif
					Loop
				Endif
				If !lPrimeira
					DBADDTREE oTree PROMPT OemToAnsi(STR0017) RESOURCE "DESTINOS" CARGO StrZero(nSeqTree++,4) // "Destinatarios"
					lPrimeira := .T.
    			Endif

				If QDG->QDG_SIT <> "I"
					cSit:= OemToAnsi(STR0082)
				Else
					cSit:= OemToAnsi(STR0083)
				EndIf	

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Tipo de Recebimento - 1 Copias Eletronicas / 2 - Copias em Papel / 3 - Ambas³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If QDG->QDG_TPRCBT == "1"
					cTpRcbt:= OemToAnsi(STR0037)
				ElseIf QDG->QDG_TPRCBT == "2"
					cTpRcbt:= OemToAnsi(STR0038)
				ElseIf QDG->QDG_TPRCBT == "3"
					cTpRcbt:= OemToAnsi(STR0039)
				EndIf
						
				If cOldDepto <> QDG->QDG_DEPTO
					If !lItem
						lItem := .T.      
					Else
						DBENDTREE oTree	
					EndIF
					DBADDTREE oTree PROMPT PADR(Alltrim(QDG->QDG_DEPTO)+" - "+QA_NDEPT(QDG->QDG_DEPTO,.T.,QDG->QDG_FILMAT),100) RESOURCE "GROUP" CARGO StrZero(nSeqTree++,4)
					DBADDITEM oTree PROMPT OemToAnsi(STR0020)+" "+Alltrim(QA_NUSR(QDG->QDG_FILMAT,QDG->QDG_MAT))+" - "+cTpRcbt+" - "+OemToAnsi(STR0035)+" "+Alltrim(STR(QDG->QDG_NCOP)+" - "+OemToAnsi(STR0084)+" "+cSit) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Usuario:"
					If QDG->QDG_TIPO == "P"
						cDescPast := ""
						If QDC->(DbSeek(xFilial("QDC")+QDG->QDG_CODMAN))
							cDescPast:= QDC->QDC_DESC
						EndIf
						DBADDITEM oTree PROMPT OemToAnsi(STR0036)+" "+QDG->QDG_CODMAN+" - "+cDescPast RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Pasta:"
					EndIf
					cOldDepto:= QDG->QDG_DEPTO
	            Else
					DBADDITEM oTree PROMPT OemToAnsi(STR0020)+" "+Alltrim(QA_NUSR(QDG->QDG_FILMAT,QDG->QDG_MAT))+" - "+cTpRcbt+" - "+OemToAnsi(STR0035)+" "+Alltrim(STR(QDG->QDG_NCOP)+" - "+OemToAnsi(STR0084)+" "+cSit) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Usuario:"
					If QDG->QDG_TIPO == "P"
						cDescPast := ""
						If QDC->(DbSeek(xFilial("QDC")+QDG->QDG_CODMAN))
							cDescPast:= QDC->QDC_DESC
						EndIf
						DBADDITEM oTree PROMPT OemToAnsi(STR0036)+" "+QDG->QDG_CODMAN+" - "+cDescPast RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Pasta:"
					EndIf	            
	            EndIf
				QDG->(DbSkip())
			EndDo
			If lPrimeira
				If !lItem
					DBENDTREE oTree 
				Else                
					DBENDTREE oTree 
					DBENDTREE oTree 
				Endif
			Endif
	   	EndIf		
			                                    
		If QD1->(DbSeek(xFilial("QD1")+cDocto+cRv))
			DBADDTREE oTree PROMPT OemToAnsi(STR0049) RESOURCE "PEDIDO" CARGO StrZero(nSeqTree++,4) // "Baixa"
			While QD1->(!Eof()) .And. xFilial("QD1")+cDocto+cRv == QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV
				If QD1->QD1_SIT <> "I"
					cSit:= OemToAnsi(STR0082)//"Ativo"
				Else
					cSit:= OemToAnsi(STR0083)//"Inativo"
				EndIf	
				If QD1->QD1_LEUDOC == "S"
					cLeuDoc:= OemtoAnsi(STR0041) // "Sim"
				Else
					cLeuDoc:= OemtoAnsi(STR0042) // "Nao"
				EndIf
               		If QD1->QD1_PENDEN == "P"
					cPendBx:= OemtoAnsi(STR0044)//"Pendente"
				Else
					cPendBx:= OemtoAnsi(STR0045)//"Baixada"
				EndIf               
				
				If cOldTpPen <> QD1->QD1_TPPEND
			
					If Alltrim(QD1->QD1_TPPEND) == "A"
						DBADDTREE oTree PROMPT OemToAnsi(STR0056) RESOURCE "BMPUSER" CARGO StrZero(nSeqTree++,4) // "Aprovacao"
					ElseIf Alltrim(QD1->QD1_TPPEND) == "D"
						DBADDTREE oTree PROMPT OemToAnsi(STR0050) RESOURCE "BMPUSER" CARGO StrZero(nSeqTree++,4) // "Digitacao"
					ElseIf Alltrim(QD1->QD1_TPPEND) == "E"
						DBADDTREE oTree PROMPT OemToAnsi(STR0053) RESOURCE "BMPUSER" CARGO StrZero(nSeqTree++,4) // "Elaboracao"
					ElseIf Alltrim(QD1->QD1_TPPEND) == "EC"
						DBADDTREE oTree PROMPT OemToAnsi(STR0054) RESOURCE "BMPUSER" CARGO StrZero(nSeqTree++,4) // "Elaboracao c/Critica"
					ElseIf Alltrim(QD1->QD1_TPPEND) == "H"    
						DBADDTREE oTree PROMPT OemToAnsi(STR0057) RESOURCE "BMPUSER" CARGO StrZero(nSeqTree++,4) // "Homologacao"	
					ElseIf Alltrim(QD1->QD1_TPPEND) == "I"
						DBADDTREE oTree PROMPT OemToAnsi(STR0058) RESOURCE "BMPUSER" CARGO StrZero(nSeqTree++,4) // "Distribuicao"
					ElseIf Alltrim(QD1->QD1_TPPEND) == "L"
						DBADDTREE oTree PROMPT OemToAnsi(STR0051) RESOURCE "BMPUSER" CARGO StrZero(nSeqTree++,4) // "Leitura"
					ElseIf Alltrim(QD1->QD1_TPPEND) == "R"
						DBADDTREE oTree PROMPT OemToAnsi(STR0055) RESOURCE "BMPUSER" CARGO StrZero(nSeqTree++,4) // "Revisao"
					EndIf
				
					cOldTpPen:= QD1->QD1_TPPEND

					If QD1->QD1_PENDEN == "P"
						DBADDITEM oTree PROMPT PADR(Alltrim(QA_NUSR(QD1->QD1_FILMAT,QD1->QD1_MAT))+" - "+OemToAnsi(STR0034)+" "+Alltrim(QA_NDEPT(QD1->QD1_DEPTO,.T.,QD1->QD1_FILMAT))+" - "+OemToAnsi(STR0007)+" "+cPendBx+" - "+OemToAnsi(STR0084)+" "+cSit,100) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Status"
					Else
						DBADDTREE oTree PROMPT PADR(Alltrim(QA_NUSR(QD1->QD1_FILMAT,QD1->QD1_MAT))+" - "+OemToAnsi(STR0034)+" "+Alltrim(QA_NDEPT(QD1->QD1_DEPTO,.T.,QD1->QD1_FILMAT))+" - "+OemToAnsi(STR0007)+" "+cPendBx+" - "+OemToAnsi(STR0084)+" "+cSit,100) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Status"
						If QD1->QD1_FILMAT+QD1->QD1_MAT <> QD1->QD1_FMATBX+QD1->QD1_MATBX
							DBADDITEM oTree PROMPT OemToAnsi(STR0062)+" "+Alltrim(QA_NUSR(QD1->QD1_FMATBX,QD1->QD1_MATBX))+" - "+Alltrim(QA_NDEPT(QD1->QD1_DEPBX,.T.,QD1->QD1_FMATBX)+" - "+OemToAnsi(STR0084)+" "+cSit) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Baixado Por:" ### "Depto"
						EndIf
						DBADDITEM oTree PROMPT OemToAnsi(STR0046)+" "+DTOC(QD1->QD1_DTBAIX)+" "+Alltrim(QD1->QD1_HRBAIX)+" - "+OemToAnsi(STR0059)+" "+cLeuDoc  RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Leu Docto" ### "Dt Baixa"
						DBENDTREE oTree
					EndIf
			   	Else
					If QD1->QD1_PENDEN == "P"
						DBADDITEM oTree PROMPT PADR(Alltrim(QA_NUSR(QD1->QD1_FILMAT,QD1->QD1_MAT))+" - "+OemToAnsi(STR0034)+" "+Alltrim(QA_NDEPT(QD1->QD1_DEPTO,.T.,QD1->QD1_FILMAT))+" - "+OemToAnsi(STR0007)+" "+cPendBx+" - "+OemToAnsi(STR0084)+" "+cSit,100) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Status"
					Else
						DBADDTREE oTree PROMPT PADR(Alltrim(QA_NUSR(QD1->QD1_FILMAT,QD1->QD1_MAT))+" - "+OemToAnsi(STR0034)+" "+Alltrim(QA_NDEPT(QD1->QD1_DEPTO,.T.,QD1->QD1_FILMAT))+" - "+OemToAnsi(STR0007)+" "+cPendBx+" - "+OemToAnsi(STR0084)+" "+cSit,100) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Status"
							If QD1->QD1_FILMAT+QD1->QD1_MAT <> QD1->QD1_FMATBX+QD1->QD1_MATBX
								DBADDITEM oTree PROMPT OemToAnsi(STR0062)+" "+Alltrim(QA_NUSR(QD1->QD1_FMATBX,QD1->QD1_MATBX))+" - "+Alltrim(QA_NDEPT(QD1->QD1_DEPBX,.T.,QD1->QD1_FMATBX)+" - "+OemToAnsi(STR0084)+" "+cSit) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Baixado Por:" ### "Depto"
							EndIf
							DBADDITEM oTree PROMPT OemToAnsi(STR0046)+" "+DTOC(QD1->QD1_DTBAIX)+" "+Alltrim(QD1->QD1_HRBAIX)+" - "+OemToAnsi(STR0059)+" "+cLeuDoc RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Leu Docto" ### "Dt Baixa"
						DBENDTREE oTree
					EndIf
               	EndIf
			   	QD1->(DbSkip())
				If cOldTpPen <> QD1->QD1_TPPEND .Or. QD1->(Eof()) .Or. ;
					xFilial("QD1")+cDocto+cRv <> QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV
					DBENDTREE oTree
				EndIf
			EndDo
			DBENDTREE oTree
		EndIf
		
		If QDB->(DbSeek(xFilial("QDB")+cDocto+cRv))
			DBADDTREE oTree PROMPT OemToAnsi(STR0019) RESOURCE "S4WB014B" CARGO StrZero(nSeqTree++,4) // "Referencias"
			While QDB->(!Eof()) .And. xFilial("QDB")+cDocto+cRv == QDB->QDB_FILIAL+QDB->QDB_DOCTO+QDB->QDB_RV
				If QDB->QDB_ORIGEM == "I"
	               	cOriRef:= OemToAnsi(STR0004) // "Interno"
				Else
    	           	cOriRef:= OemToAnsi(STR0003) // "Externo"
				EndIf
				If QDB->QDB_REVIS == "S"
        	       	cRvObrig:= OemToAnsi(STR0041) // "Sim"
				Else
	               	cRvObrig:= OemToAnsi(STR0042) // "Nao"
				EndIf								
				DBADDITEM oTree PROMPT Alltrim(QDB->QDB_DESC)+" - "+OemToAnsi(STR0002)+" "+cOriRef+" - "+OemToAnsi(STR0040)+" "+cRvObrig RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Origem:" ### "Rv Obrigatorio"
		      	QDB->(DbSkip())
			EndDo
			DBENDTREE oTree
      EndIf
      		
		If QD4->(DbSeek(xFilial("QD4")+cDocto+cRv))
			DBADDTREE oTree PROMPT OemToAnsi(STR0022) RESOURCE "CRITICA" CARGO StrZero(nSeqTree++,4) // "Criticas"
			While QD4->(!Eof()) .And. xFilial("QD4")+cDocto+cRv == QD4->QD4_FILIAL+QD4->QD4_DOCTO+QD4->QD4_RV
               	If QD4->QD4_PENDEN == "P"
					cStatCri:= OemToAnsi(STR0044) // "Pendente"
				Else
					cStatCri:= OemToAnsi(STR0045) // "Baixado"
				EndIf
				DBADDTREE oTree PROMPT OemToAnsi(STR0048)+" "+Alltrim(QA_NSIT(QD4->QD4_TPPEND))+" - "+OemToAnsi(STR0047)+" "+Alltrim(QD4->QD4_SEQ) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Tipo Pendencia" ### "Sequencia:"
				DBADDITEM oTree PROMPT OemToAnsi(STR0043)+" "+DTOC(QD4->QD4_DTINIC)+" - "+OemToAnsi(STR0030)+" "+Alltrim(QA_NUSR(QD4->QD4_FILMAT,QD4->QD4_MAT))+" - "+OemToAnsi(STR0007)+" "+cStatCri RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Num Seq" ### "Dt Inicial:" ### "Responsavel" ### "Status"
				If QD4->QD4_PENDEN == "B"
					DBADDITEM oTree PROMPT OemToAnsi(STR0046)+" "+DTOC(QD4->QD4_DTBAIX)+" "+ Alltrim(QD4->QD4_HRBAIX)+" - "+Alltrim(QA_NUSR(QD4->QD4_FMATBX,QD4->QD4_MATBX))+" - "+OemToAnsi(STR0034)+" "+Alltrim(QA_NDEPT(QD4->QD4_DEPBX,.T.,QD4->QD4_FMATBX)) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4) // "Dt Baixa:" ### "Depto:"
				EndIf

				If QA2->(DbSeek(xFilial("QA2")+"CRI     "+QD4->QD4_CHAVE))

					cTexto:= QA_RecTxt(QD4->QD4_CHAVE,"CRI     ")
				
					nTexto:= MlCount(cTexto,nTamLin)
				
					DBADDTREE oTree PROMPT OemToAnsi(STR0063) RESOURCE "RELATORIO" CARGO StrZero(nSeqTree++,4) // "Texto da Critica"
				
					For nCnt:= 1 To nTexto
						DBADDITEM oTree PROMPT Padr(MemoLine(cTexto,nTamLin,nCnt),nTamLin) RESOURCE "FOLDER9" CARGO StrZero(nSeqTree++,4)
					Next nCnt		
		
					DBENDTREE oTree			                                                      
				EndIf											
				DBENDTREE oTree					
				QD4->(DbSkip())
			EndDo	
			DBENDTREE oTree
		EndIf
	DBENDTREE oTree
	DbSelectArea(cAliasQDH)
	DbSkip()
EndDo

aButtons := { 	{"S4WB013N", {|| QDC020Leg() },OemToAnsi(STR0087)},; //"Legenda"
				{"PESQUISA", {|| QDC020Pesq(@oTree,nBtn:=1) }, OemToAnsi(STR0078),OemtoAnsi(STR0092) } ,; //"Pesquisa Texto" //"Pesquisa"
			 	{"BMPVISUAL" , {|| QDC020Pesq(@oTree,nBtn:=2) }, OemToAnsi(STR0081),OemtoAnsi(STR0093) }  } //"Proxima Pesquisa" //"Prox.Pesq"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{ ||oDlg:End() },{ ||oDlg:End() },,aButtons) CENTERED

DbSelectArea("QD1")
DbSetOrder(nOrdQD1)
DbSelectArea("QDG")
DbSetOrder(nOrdQDG)

If cAliasQDH == "QDH_TRB"
	(cAliasQDH)->(dbCloseArea())
EndIf

Return Nil
                  
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡ao      ³ QDC020filt ³ Autor ³ Eduardo de Souza           ³ Data ³ 11/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡ao   ³ Filtra Documentos                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe     ³ QDC020filt()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso         ³ QDOC020.PRW                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QDC020filt()

Local cQuery := ""

cQuery := "SELECT QDH_FILIAL,QDH_DOCTO,QDH_RV,QDH_CHAVE,QDH_TITULO,QDH_OBSOL,QDH_STATUS,"
cQuery += "QDH_CANCEL,QDH_DTOIE,QDH_CODTP,QDH_CODASS,QDH_DEPTOD,QDH_DTVIG,QDH_DTLIM,QDH_DTIMPL,QDH_FILDEP"
cQuery += " FROM " + RetSqlName("QDH") + " QDH WHERE"
cQuery += " QDH_FILIAL = '"+ xFilial("QDH")+"'"
cQuery += " AND QDH.QDH_DOCTO >= '"+cDeDocto +"' AND QDH.QDH_DOCTO <= '"+cAteDocto +"'"
cQuery += " AND QDH.QDH_CODTP >= '"+cDeTpDoc +"' AND QDH.QDH_CODTP <= '"+cAteTpDoc +"'"
cQuery += " AND QDH.QDH_CODASS >= '"+cDeAssunt+"' AND QDH.QDH_CODASS <= '"+cAteAssunt+"'"
If nCombRv == 2 // Ultima Revisao
	cQuery += " AND QDH.QDH_OBSOL <> 'S' AND QDH.QDH_CANCEL <> 'S'"
EndIf
If !Empty(cTpOrigem)
	cQuery += " AND QDH.QDH_DTOIE = '"+cTpOrigem+"'"
EndIf
If nCombStat <> 1 // Ambas
	If nCombStat == 2 // Vigente
		cQuery += " AND QDH.QDH_OBSOL = 'N' AND QDH.QDH_STATUS = 'L  ' AND QDH.QDH_CANCEL <> 'S'"
	ElseIf nCombStat == 3 // Em Elaboracao
		cQuery += " AND QDH.QDH_OBSOL = 'N' AND QDH.QDH_STATUS <> 'L  ' AND QDH.QDH_CANCEL <> 'S'"
	ElseIf nCombStat == 4 // Obsoleto
		cQuery += " AND QDH.QDH_OBSOL = 'S' AND QDH.QDH_CANCEL <> 'S'"
	ElseIf nCombStat == 5 // Cancelado
		cQuery += " AND QDH.QDH_CANCEL = 'S'"
	EndIf
EndIf
cQuery += " AND D_E_L_E_T_ <> '*'"
cQuery += " ORDER BY " + SqlOrder(QDH->(IndexKey()))
		
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QDH_TRB', .F., .T.)
DbSelectArea("QDH_TRB")

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDC020Pesq  ³ Autor ³ Eduardo de Souza              ³ Data ³ 15/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pesquisa Texto                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDC020Pesq(oTree)                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1-Objeto do Tree                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOC020.PRW                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDC020Pesq(oTree,nBtn)
Local nOpcao := 0
Local oDlgPesq
Local oBtn1
Local oBtn2
Local lAchou := .F.

If nBtn == 1 // "Pesquisa Texto"
	lEditPTree := .T.		
Else         // "Proxima Pesquisa"
	lEditPTree := .F.
EndIf

If lEditPTree
	DEFINE MSDIALOG oDlgPesq FROM 0,0 TO 080,634 PIXEL TITLE OemToAnsi(STR0078)	// "Pesquisa Texto"

    cChaveTree := Padr(cChaveTree,100)
	@ 010,05 MSGET cChaveTree SIZE 310,08 OF oDlgPesq PIXEL

	DEFINE SBUTTON oBtn1 FROM 25,005 TYPE 1 PIXEL ENABLE OF oDlgPesq ACTION ( nOpcao:=1,oDlgPesq:End() )
	DEFINE SBUTTON oBtn2 FROM 25,035 TYPE 2 PIXEL ENABLE OF oDlgPesq ACTION ( nOpcao:=2,oDlgPesq:End() )

	ACTIVATE MSDIALOG oDlgPesq CENTERED
Endif

If (nOpcao == 1 .Or. nOpcao == 0) .And. !Empty(AllTrim(cChaveTree))
	cChaveTree := UPPER(AllTrim(cChaveTree))
	dbSelectArea(oTree:cArqTree)
	dbGoTop()	
	While !Eof()
		If cChaveTree $ UPPER(T_PROMPT)
			If (nOpcao == 0 .And. T_CARGO > cChaveSeq) .Or. nOpcao == 1
				oTree:TreeSeek(T_CARGO)
				oTree:Refresh()
				// Colocado duas vezes para posicionar na linha onde esta o texto
				// porque se buscar uma vez posiciona no Item pai.                
				oTree:TreeSeek(T_CARGO)
				oTree:Refresh()
				cChaveSeq := T_CARGO
				lAchou := .T.
				lEditPTree := .F.
				Exit
			Endif
		Endif
		dbSkip()
	Enddo
	If !lAchou
		If cChaveSeq <> "0000"
			lEditPTree := .T.
		Endif
		MsgAlert(OemToAnsi(STR0079+" '"+cChaveTree+"' "+STR0080))	// "Texto" ### "nao encontrado"
	Else
		lEditPTree := .F.
	Endif
Endif

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QDC020Leg  ³ Autor ³Eduardo de Souza              ³ Data ³ 26/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Cria uma janela contendo a legenda da mBrowse                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QDC020Leg( )              											³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOC020                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDC020Leg()

Local aLegenda := {}

Aadd( aLegenda, {'DISABLE'   , OemtoAnsi(STR0090)} ) // "Documento Obsoleto"
Aadd( aLegenda, {'ENABLE'    , OemtoAnsi(STR0089)} ) // "Documento Normal/Em Leitura"
Aadd( aLegenda, {'BR_AMARELO', OemtoAnsi(STR0088)} ) // "Documento em fase de Elaboracao"
Aadd( aLegenda, {'BR_PRETO'  , OemtoAnsi(STR0091)} ) // "Documento cancelado"

BrwLegenda(OemToAnsi(STR0001),OemtoAnsi(STR0087),aLegenda) // "Historico de Documentos" ### "Legenda"

Return .T.
