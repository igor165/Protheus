#INCLUDE "Protheus.ch"
#include "AJTQIE001.CH"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AJTQIE001³ Autor ³Cicero Odilio Cruz     ³ Data ³ 19.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Adequa os dados da Tabela QER e QEL a partir da QEK  - este³±±     
±±³          ³ ajuste terá que ser executado sempre que um dos campos (No-³±±
±±³          ³ ta Fiscal - Serie e Item da NFE forem alterados.           ³±±
±±³          ³ BOPS 121421											  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Inspeção de Entrada				                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AJTQIE001

If MsgYesNo(OemToAnsi(STR0001),OemToAnsi(STR0002)) // "Deseja efetuar o ajuste para as tabelas QEL e QER? Esta rotina deve ser utilizada em modo exclusivo ! Faca um backup dos dicionários e da Base de Dados antes da atualização para eventuais falhas de atualização !"###"Atencao" 
		Processa({|lEnd| AJTQProc()})
EndIf

Return Nil

Function AJTQProc
Local lNiser      := 0
Local nOrdQEK     := 0
Local nOrdQEL     := 0
Local nOrdQER     := 0
Local nOrdQEY     := 0
Local nOrdQEZ     := 0
Local nRecnoSM0   := SM0->(RecNo())
Local nBusca	  := 0
Local cSvFilAnt	  := cFilAnt
Local aSM0CodFil  := {}
Local aFilQEK := {}
Local aFilQEL := {}
Local aFilQER := {}
Local aFilQEY := {}
Local aFilQEZ := {}

dbSelectArea("SM0")
dbGoTop()
do While ! Eof()
	If SM0->M0_CODIGO == cEmpAnt
		Aadd(aSM0CodFil, SM0->M0_CODFIL)
	Endif
	dbSkip()
Enddo	
dbGoto(nRecnoSM0)     

aFilQEK := If(! Empty(Alltrim(xFilial("QEK"))), aClone(aSM0CodFil), aClone({xFilial("QEK")}))
aFilQEL := If(! Empty(Alltrim(xFilial("QEL"))), aClone(aSM0CodFil), aClone({xFilial("QEL")}))
aFilQER := If(! Empty(Alltrim(xFilial("QER"))), aClone(aSM0CodFil), aClone({xFilial("QER")}))
aFilQEY := If(! Empty(Alltrim(xFilial("QEY"))), aClone(aSM0CodFil), aClone({xFilial("QEY")}))
aFilQEZ := If(! Empty(Alltrim(xFilial("QEZ"))), aClone(aSM0CodFil), aClone({xFilial("QEZ")}))
	
nOrdQEK := QEK->(IndexOrd())
nOrdQEL := QEL->(IndexOrd())
nOrdQER := QER->(IndexOrd())
nOrdQEY := QEY->(IndexOrd())
nOrdQEZ := QEZ->(IndexOrd())

dbSelectArea("QER") 
DbSetOrder(1) 
lNiser := QER->(FieldPos("QER_NISERI")) > 0

If 	TamSx3("QEK_NTFISC")[1]+TamSx3("QEK_SERINF")[1]+TamSx3("QEK_ITEMNF")[1] > TamSx3("QEL_NISERI")[1] .OR.;
	TamSx3("QEK_NTFISC")[1]+TamSx3("QEK_SERINF")[1]+TamSx3("QEK_ITEMNF")[1] > TamSx3("QER_NISERI")[1] 
	Help(" ",1,"QIENISERI")
	Return Nil
EndIf

If lNiser 

	For nBusca := 1 to Len(aFilQEL)
    
		cFilAnt := aFilQEL[nBusca]
		
		dbSelectArea("QEL")  
	   	ProcRegua(QEL->(LastRec()))
		dbSetorder(1)
		dbGoTop()
		While QEL->(!Eof())
		       
		    dbSelectArea("QEK")
		    dbSetOrder(1)
		    If dbSeek(xFilial("QEK")+QEL->QEL_FORNEC+QEL->QEL_LOJFOR+QEL->QEL_PRODUT)
				While QEK->(!EOF()) .And.;
				      xFilial("QEK")+QEL->QEL_FORNEC+QEL->QEL_LOJFOR+QEL->QEL_PRODUT == QEK->QEK_FILIAL+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT	
				    lAtu := .T.
					If !QEK->QEK_FILIAL==xFilial("QEL") 
						lAtu := .F.				
					EndIf         
					If !QEK->QEK_LOTE==QEL->QEL_LOTE
						lAtu := .F.				
					EndIf
					If !QEK->QEK_DTENTR==QEL->QEL_DTENTR
						lAtu := .F.				
					ElseIf !QEK->QEK_HRENTR==QEL->QEL_HRENLA
						lAtu := .F.
					EndIf
 					If !Empty(AllTrim(QEL->QEL_NISERI)) .AND. QEL->QEL_NISERI == QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
					   lAtu := .F.
					EndIf
					If lAtu
						RecLock("QEL",.F.)
						Replace QEL->QEL_NISERI With QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
						Replace QEL->QEL_TIPONF With QEK->QEK_TIPONF   
						MsUnLock()
					EndIf 
					QEK->(dbSkip())
				EndDo
			EndIf
			IncProc(STR0005) //"Atualizando QEL ..."
			QEL->(dbSkip())
			
		EndDo 
	Next

	For nBusca := 1 to Len(aFilQER)
    
		cFilAnt := aFilQER[nBusca]
		
		dbSelectArea("QER")
		ProcRegua(QER->(LastRec()))
		dbGoTop()
	
		While QER->(!Eof())
			dbSelectArea("QEK")
			dbSetOrder(3)
			If DbSeek(xFilial("QEK")+QER->QER_PRODUT+Inverte(QER->QER_DTENTR)+Inverte(QER->QER_LOTE))
				While QEK->(!Eof()) .AND. QEK->QEK_FILIAL+QEK->QEK_PRODUT+QEK->QEK_ENTINV+QEK->QEK_LOTINV == xFilial("QEK")+QER->QER_PRODUT+Inverte(QER->QER_DTENTR)+Inverte(QER->QER_LOTE) 
				    lAtu := .T.
					If !QEK->QEK_FILIAL==xFilial("QER") 
						lAtu := .F.				
					EndIf    
					If !QEK->QEK_LOTE==QER->QER_LOTE
						lAtu := .F.				
					EndIf
					If !QEK->QEK_DTENTR==QER->QER_DTENTR
						lAtu := .F.				
					EndIf
					If !Empty(AllTrim(QER->QER_NISERI)) .AND. QER->QER_NISERI == QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
					   lAtu := .F.
					EndIf
					If lAtu
						RecLock("QER",.F.)
						Replace QER->QER_NISERI With QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
						Replace QER->QER_TIPONF With QEK->QEK_TIPONF     
						MsUnLock()
					EndIf
					QEK->(dbSkip())
				Enddo
		    EndIf
			IncProc(STR0006)//"Atualizando QER ..." 
			QER->(dbSkip())
		EndDo
	Next           
	
	For nBusca := 1 to Len(aFilQEY)
    
		cFilAnt := aFilQEY[nBusca]
		
		dbSelectArea("QEY")
	   	ProcRegua(QEY->(LastRec()))
		dbSetOrder(1)
		dbGoTop()
	
		While QEY->(!Eof())
			dbSelectArea("QEK")
			dbSetOrder(3)
			If DbSeek(xFilial("QEK")+QEY->QEY_PRODUT+Inverte(QEY->QEY_DTENTR)+Inverte(QEY->QEY_LOTE))
				While QEK->(!Eof()) .AND. QEK->QEK_FILIAL+QEK->QEK_PRODUT+QEK->QEK_ENTINV+QEK->QEK_LOTINV == xFilial("QEK")+QEY->QEY_PRODUT+Inverte(QEY->QEY_DTENTR)+Inverte(QEY->QEY_LOTE) 
				    lAtu := .T.
					If !QEK->QEK_FILIAL==xFilial("QEY") 
						lAtu := .F.				
					EndIf
					If !QEK->QEK_LOTE==QEY->QEY_LOTE
						lAtu := .F.				
					EndIf
					If !QEK->QEK_DTENTR==QEY->QEY_DTENTR
						lAtu := .F.				
					EndIf
					If !Empty(AllTrim(QEY->QEY_ITEMNF)) .AND. QEY->QEY_ITEMNF == QEK->QEK_ITEMNF
					   lAtu := .F.
					EndIf
					If lAtu
						RecLock("QEY",.F.)
						Replace QEY->QEY_NTFISC With QEK->QEK_NTFISC
						Replace QEY->QEY_SERINF With QEK->QEK_SERINF
						Replace QEY->QEY_ITEMNF With QEK->QEK_ITEMNF
						Replace QEY->QEY_TIPONF With QEK->QEK_TIPONF
						MsUnLock()
					EndIf
					QEK->(dbSkip())
				Enddo
		    EndIf
			IncProc(STR0007)//"Atualizando QEY ..."
			QEY->(dbSkip())
		EndDo  
	Next	

	For nBusca := 1 to Len(aFilQEZ)
    
		cFilAnt := aFilQEZ[nBusca]
		
		dbSelectArea("QEZ")
	   	ProcRegua(QEZ->(LastRec()))
		dbSetOrder(1)
		dbGoTop()
	
		While QEZ->(!Eof())
			dbSelectArea("QEK")
			dbSetOrder(3)
			If DbSeek(xFilial("QEK")+QEZ->QEZ_PRODUT+Inverte(QEZ->QEZ_DTENTR)+Inverte(QEZ->QEZ_LOTE))
				While QEK->(!Eof()) .AND. QEK->QEK_FILIAL+QEK->QEK_PRODUT+QEK->QEK_ENTINV+QEK->QEK_LOTINV == xFilial("QEK")+QEZ->QEZ_PRODUT+Inverte(QEZ->QEZ_DTENTR)+Inverte(QEZ->QEZ_LOTE) 
				    lAtu := .T.
					If !QEK->QEK_FILIAL==xFilial("QEZ") 
						lAtu := .F.				
					EndIf
					If !QEK->QEK_LOTE==QEZ->QEZ_LOTE
						lAtu := .F.				
					EndIf
					If !QEK->QEK_DTENTR==QEZ->QEZ_DTENTR
						lAtu := .F.				
					EndIf
					If !Empty(AllTrim(QEZ->QEZ_ITEMNF)) .AND. QEZ->QEZ_ITEMNF == QEK->QEK_ITEMNF
					   lAtu := .F.
					EndIf                           
					If lAtu
						RecLock("QEZ",.F.)
						Replace QEZ->QEZ_NTFISC With QEK->QEK_NTFISC
						Replace QEZ->QEZ_SERINF With QEK->QEK_SERINF
						Replace QEZ->QEZ_ITEMNF With QEK->QEK_ITEMNF
						Replace QEZ->QEZ_TIPONF With QEK->QEK_TIPONF
						MsUnLock()
					EndIf
					QEK->(dbSkip())
				Enddo
		    EndIf
			IncProc(STR0008)//"Atualizando QEZ ..."
			QEZ->(dbSkip())
		EndDo
	Next
	
	dbSelectArea("QEK")
	dbSetOrder(nOrdQEK)

	dbSelectArea("QEL")
	dbSetOrder(nOrdQEL)

	dbSelectArea("QER")
	dbSetOrder(nOrdQER)
	
	dbSelectArea("QEY")
	dbSetOrder(nOrdQEY)           

	dbSelectArea("QEZ")
	dbSetOrder(nOrdQEZ)	

	cFilAnt	  := cSvFilAnt
	MsgAlert(STR0003) // "Atualização Finalizada!"
Else
	MsgAlert(STR0004) // "Ajuste não executado!"
EndIf
	  
Return Nil                  
