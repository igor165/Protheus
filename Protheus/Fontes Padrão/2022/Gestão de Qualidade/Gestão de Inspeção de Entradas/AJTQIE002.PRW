#INCLUDE "PROTHEUS.CH"
#INCLUDE "AJTQIE002.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AJTQIE002 ³ Autor ³ Sergio Sueo Fuzinaka    ³ Data ³ 04.09.2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Compatibilizacao do conteudo dos campos QEK_DOCENT e QEP_DOCENT,³±±
±±³          ³com o conteudo do campo D1_LOTEFOR.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGAQIE                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AJTQIE002

If (TamSX3("D1_LOTEFOR")[1] > TamSX3("QEK_DOCENT")[1] .Or. TamSX3("D1_LOTEFOR")[1] > TamSX3("QEP_DOCENT")[1])
	MsgStop( OemToAnsi(STR0002)+OemToAnsi(STR0003), Upper(OemToAnsi(STR0001)) )
Else
	If MsgYesNo(OemToAnsi(STR0004),Upper(OemToAnsi(STR0001)))
		Processa({|lEnd| AjtQProc()})
	EndIf
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AjtQProc  ³ Autor ³ Sergio Sueo Fuzinaka    ³ Data ³ 04.09.2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Efetua o processamento dos registros.                           ³±±
±±³          ³                                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjtQProc()

Local lFound := .F.

dbSelectArea("SD1")
dbSetOrder(1)
dbGoTop()
ProcRegua(LastRec())
While !Eof()
	IncProc()
	If !Empty( SD1->D1_LOTEFOR )
		dbSelectArea("QEK")
		dbSetOrder(11)
		If dbSeek(xFilial("QEK")+SD1->(D1_FORNECE+D1_LOJA+D1_DOC+D1_SERIE+D1_ITEM+D1_TIPO))
			While !Eof() .And. QEK->(QEK_FILIAL+QEK_FORNECE+QEK_LOJFOR+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF) == ;
								xFilial("QEK")+SD1->(D1_FORNECE+D1_LOJA+D1_DOC+D1_SERIE+D1_ITEM+D1_TIPO)
				IncProc()
				RecLock("QEK",.F.)
				QEK->QEK_DOCENT := SD1->D1_LOTEFOR
				MsUnLock()
				
				dbSelectArea("QEP")
				dbSetOrder(1)
				lFound := dbSeek(xFilial("QEP")+"1"+QEK->(QEK_FORNECE+QEK_LOJFOR+QEK_PRODUT+DTOS(QEK_DTENTR)+QEK_LOTE))
				If !lFound
					lFound := dbSeek(xFilial("QEP")+"2"+QEK->(QEK_FORNECE+QEK_LOJFOR+QEK_PRODUT+DTOS(QEK_DTENTR)+QEK_LOTE))
				Endif
				If lFound
					While !Eof() .And. QEP->(QEP_FILIAL+QEP_FORNEC+QEP_LOJFOR+QEP_PRODUT+DTOS(QEP_DTENTR)+QEP_LOTE) == ;
										xFilial("QEP")+QEK->(QEK_FORNECE+QEK_LOJFOR+QEK_PRODUT+DTOS(QEK_DTENTR)+QEK_LOTE)
						IncProc()
						RecLock("QEP",.F.)
						QEP->QEP_DOCENT := SD1->D1_LOTEFOR
						MsUnLock()
				
						dbSelectArea("QEP")
						dbSkip()
					Enddo
			    Endif

				dbSelectArea("QEK")
				dbSkip()
			Enddo
		Endif
	Endif
	dbSelectArea("SD1")
	dbSkip()
Enddo

MsgInfo(OemToAnsi(STR0005))		// "Fim de Processamento!"

Return Nil
