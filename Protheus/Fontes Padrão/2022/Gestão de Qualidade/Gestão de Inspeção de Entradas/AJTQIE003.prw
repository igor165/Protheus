#INCLUDE "PROTHEUS.CH"
#INCLUDE "AJTQIE003.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AJTQIE003 ³ Autor ³ Sergio Sueo Fuzinaka    ³ Data ³  14.05.09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Compatibilizacao do conteudo dos campos QEL_NUMSEQ e QER_NUMSEQ,³±±
±±³          ³a partir do conteudo do campo QEK_NUMSEQ.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAQIE                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AJTQIE003

Local lQReinsp	:= QieReinsp()

If lQReinsp
	If MsgYesNo(OemToAnsi(STR0002)+CHR(13)+CHR(13)+OemToAnsi(STR0003),Upper(OemToAnsi(STR0001)))
		Processa({|lEnd| AjtQProc()})
	EndIf
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AjtQProc  ³ Autor ³ Sergio Sueo Fuzinaka    ³ Data ³  14.05.09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Efetua o processamento dos registros.                           ³±±
±±³          ³                                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjtQProc()

Local cAliasQEK	:= "QEK"
Local cSeek		:= ""
#IFNDEF TOP
	Local cFiltro	:= ""
	Local cIndice	:= ""
	Local nIndice	:= 0
#ENDIF

dbSelectArea("QEK")
dbSetOrder(11)

#IFDEF TOP

	cAliasQEK := GetNextAlias()
  
	BeginSql Alias cAliasQEK
	
		Column QEK_DTENTR As Date

		SELECT QEK_FORNEC,QEK_LOJFOR,QEK_PRODUT,QEK_REVI,QEK_DTENTR,QEK_HRENTR,QEK_LOTE,QEK_NTFISC,QEK_SERINF,
				QEK_ITEMNF,QEK_TIPONF,QEK_NUMSEQ

		FROM %table:QEK% QEK

		WHERE QEK.QEK_FILIAL = %xFilial:QEK% AND
		      QEK.QEK_NUMSEQ <> ' ' AND			
		      QEK.%NotDel%

		ORDER BY %Order:QEK,11%  
	
	EndSql

	cQuery := GetLastQuery()[2]

#ELSE

	cIndice := CriaTrab(NIL,.F.)
	cFiltro := "QEK_FILIAL == '"+xFilial("QEK")+"' .AND. !EMPTY(QEK_NUMSEQ)"
	
	IndRegua("QEK",cIndice,QEK->(IndexKey()),,cFiltro)
	nIndice := RetIndex("QEK")
	dbSetIndex(cIndice+OrdBagExt())
	dbSetOrder(nIndice+1)

#ENDIF

dbSelectArea(cAliasQEK)
dbGoTop()
While !Eof()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizando a tabela QEL         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSeek := (cAliasQEK)->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT)
	cSeek += (cAliasQEK)->(QEK_NTFISC+QEK_SERINF+QEK_ITEMNF)	// _NISERI
	cSeek += (cAliasQEK)->(QEK_TIPONF+DTOS(QEK_DTENTR)+QEK_LOTE)
	dbSelectArea("QEL")
	dbSetOrder(3)
	If dbSeek(xFilial("QEL")+cSeek)

		While !Eof() .And. ;
			QEL->(QEL_FILIAL+QEL_FORNEC+QEL_LOJFOR+QEL_PRODUT+QEL_NISERI+QEL_TIPONF+DTOS(QEL_DTENTR)+QEL_LOTE) == 	xFilial("QEL")+cSeek

			If QEL->QEL_DTENTR == (cAliasQEK)->QEK_DTENTR .And. QEL->QEL_HRENLA == (cAliasQEK)->QEK_HRENTR
				RecLock("QEL",.F.)
				QEL->QEL_NUMSEQ := (cAliasQEK)->QEK_NUMSEQ
				MsUnlock()
			Endif

			dbSelectArea("QEL")
			dbSkip()
		Enddo

	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizando a tabela QER         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSeek := (cAliasQEK)->(QEK_PRODUT+QEK_REVI+QEK_FORNEC+QEK_LOJFOR)
	cSeek += (cAliasQEK)->(QEK_NTFISC+QEK_SERINF+QEK_ITEMNF)	// _NISERI
	cSeek += (cAliasQEK)->(QEK_TIPONF+QEK_LOTE)
	dbSelectArea("QER")
	dbSetOrder(5)
	If dbSeek(xFilial("QER")+cSeek)

		While !Eof() .And. ;
			QER->(QER_FILIAL+QER_PRODUT+QER_REVI+QER_FORNEC+QER_LOJFOR+QER_NISERI+QER_TIPONF+QER_LOTE) == xFilial("QER")+cSeek

			If QER->QER_DTENTR == (cAliasQEK)->QEK_DTENTR
				RecLock("QER",.F.)
				QER->QER_NUMSEQ := (cAliasQEK)->QEK_NUMSEQ
				MsUnlock()
			Endif
			
			dbSelectArea("QER")
			dbSkip()
		Enddo

	Endif

	dbSelectArea(cAliasQEK)
	dbSkip()
Enddo

dbSelectArea(cAliasQEK)

#IFDEF TOP
	dbCloseArea()
#ELSE
	RetIndex("QEK")
	dbClearFilter()
	FErase(cIndice+OrdBagExt())
#ENDIF

MsgInfo(OemToAnsi(STR0004))		// "Fim de Processamento!"

Return Nil
