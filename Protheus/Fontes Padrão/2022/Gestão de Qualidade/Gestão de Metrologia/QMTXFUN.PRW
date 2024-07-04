#Include "QMTXFUN.CH"
#Include "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Fun‡…o	 ³ QMTXDecim³ Autor ³ Wanderley Goncalves Jr³ Data ³ 17.12.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna numero de casas decimais 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QMTXDecim(ExpN1)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor numerico 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Geral 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMTXDecim(nValor)

Local nDec := 0
Local nPos := 0

nPos := at('.',alltrim(nValor))

If npos # 0
	nDec	:= len(alltrim(nValor)) - nPos
EndIf

Return(nDec)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QMTXFRR	³ Autor ³ Wanderley Goncalves   ³ Data ³ 04.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime corpo da ficha de R&R 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QMTXFRR()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nXPar01 - No.Ensaiadores									  ³±±
±±³			 ³ nXPar02 - No.Ciclos (Medicoes)							  ³±±
±±³			 ³ nXPar03 - No.Pecas										  ³±±
±±³			 ³ cFicha  - Tipo de ficha - I-Individual P-Por Periodo		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMTXFRR(nXPar01,nXPar02,nXPar03,cFicha)

Local nCntFor, nCntFor2,nCntFor3

	For nCntFor := 1 to nXPar01
		If ( li > 53 .and. nCntFor > 1 )
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
			@ li	,000 PSAY Repl("*",132)
			If cFicha == 'I'
				R230Cabec(.f.,nCOL,nCntFor)
			Else
				R240Cabec(.f.,nCOL,nCntFor)
			EndIf
		EndIf
		li+=2
		@ li	,nCOL PSAY repl('=',8*nXPar03+7)
		li++
		@ li	,nCOL PSAY '| ' + alltrim(OemToAnsi(STR0012))+' '+StrZero(nCntFor,2)+':' // 'Ensaiador'
		@ li	,nCOL+8*nXPar03+6 PSAY '|'
		li++
		@ li	,nCOL PSAY repl('-',8*nXPar03+7)
		li++
		@ li	,nCOL PSAY '|' + alltrim(OemToAnsi(STR0013))  // 'Med.'
		@ li	,nCol+6 PSAY '|'
		For nCntFor3 := 1 to nXPar03
			 @ li  ,pcol() PSAY subs(alltrim(OemToAnsi(STR0007)),1,4)+StrZero(nCntFor3,2)+' |' // 'PECA '
		Next
		li++
		@ li	,nCOL PSAY repl('-',8*nXPar03+7)
		For nCntFor2 := 1 to nXPar02
			If li > 53 .and. nCntFor2 < nXPar02
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
				@ li	,000 PSAY Repl("*",132)
				If cFicha == 'I'
					R230Cabec(.t.,nCOL,nCntFor)
				Else
					R240Cabec(.t.,nCOL,nCntFor)
				EndIf
			EndIf
			li++
			@ li	,nCOL PSAY '|  '+StrZero(nCntFor2,2) +' |'
			For nCntFor3 := 1 to nXPar03
				 @ li  ,pcol() PSAY '       |'
			Next
			li++
			@ li	,nCOL PSAY repl('-',8*nXPar03+7)
		 Next
	Next

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QMTXSTAT ³ Autor ³ Wanderley Goncalves   ³ Data ³ 04.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se Status do Instrumento esta ativo 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QMTXSTAT()																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cStat -> Status atual do Instrumento (QM2->QM2_STATUS)	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMTXSTAT(cStat)

LOCAL cRet := .t.
If QMP->(DbSeek(xFilial("QMP")+cStat))
	If QMP->QMP_ATUAL == 'S'  && Sim
		cRet := .t.
	Else
		cRet := .f.
	EndIf
Else
	cRet := .t. // Conforme GQCAL V.3.51 - Se nao achar, considerar como ativo
EndIf

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QmCalib	³ Autor ³ Alessandro B. Freire  ³ Data ³ 01.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o orgao calibrador do instrumento ‚ interno	  ³±±
±±³			 ³ ou externo. 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QmCalib(nTipo, cInterno, cExterno)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTipo 	- 1 - Todos, 2-Externo, 3-Interno				  ³±±
±±³			 ³ cInterno - Orgao calibrador interno 						  ³±±
±±³			 ³ cExterno - Orgao calibrador externo 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ QMTR070													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTR070													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto ³ 14/08/00 ³Consultar instr.+rev. no QMR ao inves do QMK.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QmCalib( nTipo, cInterno, cExterno )

Local cOldAlias	:= Alias()
Local lReturn		:= .F.

// Vai para a escala da revisao do instrumento
dbSelectArea( "QMR" )
dbSetOrder(1)
QMR->(dbSeek(xFilial()+QM2->QM2_INSTR+QM2->QM2_REVINS))
While !Eof() .AND. xFilial()+QM2->QM2_INSTR+QM2->QM2_REVINS == ;
		QMR->QMR_FILIAL+QMR->QMR_INSTR+QMR->QMR_REVINS

	// Vai para a ultima revisao da escala
	dbSelectArea( "QM9" )
	dbSetOrder(1)
	dbSeek( xFilial() + QMR->QMR_ESCALA )

	If QM9->QM9_ORGAFE == "I"
		If nTipo == 2
			lReturn := .F.
		Else
			If ! Empty( cInterno ) .And. ( cInterno != QM9->QM9_LABOR )
				lReturn := .F.
			Else
				lReturn := .T.
				Exit
			EndIf
		EndIf
	ElseIf QM9->QM9_ORGAFE == "E"
		If nTipo == 3
			lReturn := .F.
		Else
			If ! Empty( cExterno ) .And. ( cExterno != QM9->QM9_LABOR )
				lReturn := .F.
			Else
				lReturn := .T.
				Exit
			EndIf
		EndIf
	EndIf
    QMR->(DbSkip())
EndDo

DbSelectArea(cOldAlias)

Return( lReturn )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³AxGatRev	³ Autor ³ Wanderley Gon‡alves   ³ Data ³ 12.03.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho para retornar ultima revisao							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AxGatRev()																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Gatilho do campo QM6_INSTR p/ QM6_REVINS						  ³±±
±±³			 ³ Gatilho do campo QME_INSTR p/ QME_REVINS						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AxGatRev(cInstr)

QM2->(DbSetOrder(1))
If QM2->(DbSeek(xFilial("QM2")+cInstr))            //M->QM6_INSTR))
	 Return(QM2->QM2_REVINS)
Else
	 Return('00')
EndIf

Return "00"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Calibrador³ Autor ³ Alessandro B. Freire  ³ Data ³ 01.07.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o orgao calibrador do instrumento ‚ interno	  ³±±
±±³			 ³ ou externo e se o mesmo est  dentro do range definido.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Calibrador( nTipo, cCalibIni, cCalibFim ) 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTipo 	- 0- Todos, 1-Interno, 2-Externo 				  ³±±
±±³			 ³ cCaliIni - Orgao calibrador inicial interno				  ³±±
±±³			 ³ cCaliFim - Orgao calibrador final interno 				  ³±±
±±³			 ³ cCaleIni - Orgao calibrador inicial externo				  ³±±
±±³			 ³ cCaleFim - Orgao calibrador final externo 				  ³±±
±±³			 ³ cInstrum - Instrumento a ser consultado					  ³±±
±±³			 ³ cRevi 	- Rev. do Instrumento a ser consultado			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ QMTR070													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTR070													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Iuri Seto ³ 14/08/00 ³Consultar instr.+rev. no QMR ao inves do QMK.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Calibrador( nTipo, cCaliIni, cCaliFim, cCaleIni,cCaleFim,cInstrum,cRevi,lRange )

LOCAL cOldAlias	:= Alias()
LOCAL nRecAtu		:= Recno()
LOCAL nOldOrd		:= IndexOrd()
LOCAL lReturn		:= .F.

Default cInstrum	:= ""
Default cRevi		:= ""
Default lRange		:= .F.

If Empty(cInstrum)
	cInstrum := QM2->QM2_INSTR
Endif

If Empty(cRevi)
   cRevi := QM2->QM2_REVINS
Endif
// Vai para a escala da revisao do instrumento
dbSelectArea("QMR")
dbSetOrder(1)
dbGoTop()
dbSeek(xFilial("QMR")+cInstrum+cRevi)
While !Eof() .AND. xFilial("QMR")+cInstrum+cRevi ==;
	QMR->QMR_FILIAL+QMR->QMR_INSTR+QMR->QMR_REVINS

	// Vai para a ultima revisao da escala
	dbSelectArea("QM9")
	dbSetOrder(1)
	dbSeek(xFilial()+QMR->QMR_ESCALA)

	If QM9->QM9_ORGAFE == "I"
		If lRange
			// Orgao calibrador interno
			If nTipo == 1 .or. nTipo == 0 .or. nTipo == 3
				If &cCaliIni
					lReturn := .T.
				Else
					lReturn := .F.
					Exit
				EndIf
			EndIf
		Else
			// Orgao calibrador interno
			If nTipo == 1 .or. nTipo == 0 .or. nTipo == 3
				/*
				If AllTrim(QM9->QM9_DEPTO) < AllTrim(cCaliIni) .or. ;
				   AllTrim(QM9->QM9_DEPTO) > AllTrim(cCaliFim)
					lReturn := .F.
				Else
					lReturn := .T.
					Exit
				EndIf
				*/
				If AllTrim(QM9->QM9_DEPTO) >= AllTrim(cCaliIni) .AND.;
				   AllTrim(QM9->QM9_DEPTO) <= AllTrim(cCaliFim)
					lReturn := .T.
				Else
					lReturn := .F.
					Exit
				EndIf

			EndIf
		EndIf
	ElseIf QM9->QM9_ORGAFE == "E"
		If lRange
			// Orgao calibrador externo
			If nTipo == 2 .or. nTipo == 0
				If &cCaleIni
					lReturn := .T.
				Else
					lReturn := .F.
				EndIf
			Else
				lReturn := .F.
			EndIf
		Else
			// Orgao calibrador externo
			If nTipo == 2 .or. nTipo == 0
				/*If AllTrim(QM9->QM9_LABOR) < AllTrim(cCaleIni) .or. ;
	 			   AllTrim(QM9->QM9_LABOR) > AllTrim(cCaleFim)*/
	 		    If AllTrim(QM9->QM9_LABOR) >= AllTrim(cCaleIni) .AND.;
	 		       AllTrim(QM9->QM9_LABOR) <= AllTrim(cCaleFim)
					lReturn := .T.  //lReturn := .F.
				Else
					lReturn := .F.  //lReturn := .T.
				EndIf
			Else
				lReturn := .F.
			EndIf
		EndIf
	EndIf
	dbSelectArea("QMR")
	dbSkip()
EndDo
dbSelectArea(cOldAlias)
dbSetOrder(nOldOrd)
dbGoTo(nRecAtu)
Return(lReturn)


/*/
antiga VlMov
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³qmtVlMov  ³ Autor ³ Alessandro B. Freire  ³ Data ³ 7/9/1998 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validar movimentacao de instrumentos 						  ³±±
±±³			 ³Se QM1_LOCAL == "S", NAO POSSO ALTERAR NENHUM DOS CAMPOS    ³±±
±±³			 ³DESCRITOS.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³qmtVlMov     												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nenhum 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³x3_when dos campos qm2_local	, qm2_resp e qm2_depto		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function qmtVlMov()

LOCAL cAlias  := Alias()
LOCAL nOrder  := IndexOrd()
LOCAL lReturn := .f.
LOCAL nRecQM1 := QM1->(Recno())


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nas inclusoes nao e necessario validar						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( Inclui ) .or. (M->QM2_STATUS) == "0"	// Status = Malha
	Return(.t.)
EndIf

dbSelectArea("QM1")
dbSetOrder(1)
dbSeek(cFilial + QM2->QM2_TIPO)

Do while ! Eof() .and. QM1->QM1_TIPO == QM2->QM2_TIPO

	If QM1->QM1_FILIAL != cFilial
		Exit
	EndIf

	If ( QM1->QM1_LOCAL == "S" )
		lReturn := .f.
		Exit
	Else
		lReturn := .t.
		Exit
	EndIf

	dbSkip()

EndDo

dbGoto(nRecQM1)
dbSelectArea(cAlias)
dbSetOrder(nOrder)
Return(lReturn)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A140PosCol³ Autor ³ Wanderley Gon‡alves   ³ Data ³ 05.03.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Guarda o posicao dos campos na getdados em variaveis		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ A140PosCol()															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA140																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A140PosCol()

nPosEsc := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM8_ESCALA" })
nPosPad := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM8_PADRAO" })
nPosNom := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM8_ESPEC" })
nPosIni := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM8_VLRINI" })
nPosFim := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM8_VLRFIM" })
nPosAtr := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM8_ATRIB" })
nPosLab := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM8_LABOR" })
nPosNrC := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM8_NRCERT" })
nPosJus := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM8_JUST" })
nPosPS  := ASCAN(aHeader,{|x| alltrim(X[2]) = "QM8_PADSEC" })
nPosIut := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM8_IU" })
nPosNCs := ASCAN(aHeader,{|x| alltrim(x[2]) = "QM8_NCS" })

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QMT_RetNum³ Autor ³ Wanderley Gonçalves   ³ Data ³10/27/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna numero gravado no Celerina antigo com ponto como   ³±±
±±³          ³ separador de decimais com virgula                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Campo a ser convertido                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpC2 = Valor convertido                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT_RetNum(cValor)

Local cNum := cValor

QA_VerNum(@cNum)

Return(cNum)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QMTNum    ³ Autor ³ Wanderley Goncalves Jr³ Data ³ 14.05.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se valor e numerico ou nao, retornando sempre nu- ³±±
±±³          ³ merico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMTNum(xVal)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ nVal -> Valor a ser avaliado                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTR030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMTNum(xVal)

Local nVal

If ValType(xVal) == "N"
	nVal := xVal
Else
	nVal := SuperVal(xVal)
EndIf

Return(nVal)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³RetSem    ³ Autor ³ Wanderley Goncalves   ³ Data ³21/06/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna Numero da Semana no ano									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Expd1 - Data a ser convertida            				        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpC1 - Semana / Ano                                   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³A140GrvAll()                       								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetSem(dData)

Local nRet
Local lMes := .F.
Local dDataFmt := STOD(DTOS(dData))

// Segundo padrão ISO8601:2000 Standard
nRet := INT((dDataFmt-stod(Strzero(Year(dDataFmt-Dow(dDataFmt-1)+4),4)+"0103")+Dow(stod(Strzero(Year(dDataFmt-Dow(dDataFmt-1)+4),4)+"0103"))+5)/7)

If nRet == 53 .or. nRet == 52
	If StrZero(Month(dDataFmt),2)== "01"
		dData1:= Year(dDataFmt)-1
		lMes := .T.
	EndIF
End

cRet := ALLTRIM(STR(Int(nRet)))


Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³AltRevisao³ Autora³ Iuri Seto     	    ³ Data ³ 04/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa generico para alteracao com geracao de revisao.   ³±±
±±³          ³ Baseado na funcao AxAltera().                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpN1 := AltRevisao(ExpC1,ExpN2,ExpN3,ExpA1,ExpA2)		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao devolvida pela funcao 				  	      ³±±
±±³			 ³ ExpC1 = Alias do arquivo							  	      ³±±
±±³			 ³ ExpN2 = Numero do registro 						  	      ³±±
±±³			 ³ ExpN3 = Numero da opcao selecionada 				   		  ³±±
±±³			 ³ ExpA1 = Array contEndo campos a serem mostrados 			  ³±±
±±³			 ³ ExpA2 = Array limitando campos a serem aceitos com Get	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION AltRevisao(cAlias,nReg,nOpc,aAcho,aCpos,nColMens,cMensagem,cTudoOk,cTransact,cCamNRev)
Local bCampo,nOpcA:=0,cCpoFil,nSavReg,oDlg, aPosEnch
Local lX
Local i := 1

cCamNRev := If(cCamNRev == Nil, "", cCamNRev)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VerIfica se esta' alterando um registro da mesma filial               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT cTudoOk := ".t."

DbSelectArea(cAlias)
cCpofil := PrefixoCpo(cAlias)+"_FILIAL"
nSavReg := Recno()

If TYPE(cCpoFil) != "U"
	DbSeek(cFilial)
Else
	DbGoTop()
EndIf
If Eof()
	Help(" ",1,"A000FI")
	Return 3
EndIf
DbGoTo(nSavReg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo						     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTELA[0][0],aGETS[0],aArrayQM2[0][0]

bCampo := {|nCPO| Field(nCPO) }

If !SoftLock(cAlias)
	Return 3
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados 		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FOR i := 1 TO FCount()
	M->&(EVAL(bCampo,i)) := FieldGet(i)
NEXT i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis para campos Memos Virtuais		 				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("aMemos")=="A"
	For i:=1 to Len(aMemos)
		cMemo := aMemos[i][2]
		If ExistIni(cMemo)
			&cMemo := InitPad(GetSx3Cache(cMemo,"X3_RELACAO"))
		Else
			&cMemo := ""
		EndIf
	Next i
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia para processamento dos Gets				   	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// no protheus, a tela da enchoice ocupa toda a altura disponível.
// no advanced, a tela ocupa o espaço disponível na tela padrão (640x480)
DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO TranslateBottom(.F.,28),80 OF oMainWnd

aPosEnch := {,,(oDlg:nClientHeight - 4)/2,}  // ocupa todo o  espaço da janela


nReg :=Iif(nReg==NIL,RecNo(),nReg)
If nColMens != nil
	nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"CRA",oemtoansi(STR0014),aAcho,aPosEnch,aCpos,,nColMens,cMensagem,cTudoOk ) //"Quanto …s altera‡”es?"
Else
	nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"CRA",oemtoansi(STR0014),aAcho,aPosEnch,aCpos,,,,cTudoOk) //"Quanto …s altera‡”es?"
EndIf

nOpca := 3

aArrayQM2 := Aclone(aTela)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| QMARConf(@nOpca,cCamNRev,cTudoOk,oDlg,aArrayQM2) },{|| nOpca := 3,oDlg:End()}) 	// "Esta alteracao criara uma nova revisao. Confirma ?" ## "Confirma Alteracao ?" ## "Atencao"

DbGoTo(nReg)
If nOpcA == 1 .Or. nOpcA == 4
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Flag para Rotina de Movimentacao de Instrumento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cAlias == "QM2"
		RecLock(cAlias,.F.)
		Replace QM2->QM2_FLAG with "2"
		MsUnlock()
	Endif
	Begin Transaction ExtEnded
		If nOpcA == 4
			RecLock(cAlias,.T.)
		Else
			RecLock(cAlias,.F.)
		EndIf
		For i := 1 TO FCount()
			If Alltrim(FieldName(i)) == "QM2_FLAG"
               Replace QM2->QM2_FLAG with "1"
			Elseif Alltrim(FieldName(i)) == "QM9_REVESC"
				Replace QM9->QM9_REVESC with StrZero(Val(cUtRev)+1,2) //Integridade Referencial quando se gera uma revisao
			Elseif Alltrim(FieldName(i)) == "QM3_REVPAD"
				Replace QM3->QM3_REVPAD with StrZero(Val(M->QM3_REVPAD)+1,2)
			Else
				FieldPut(i,M->&(EVAL(bCampo,i)))
			Endif
		Next i
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava os campos Memos Virtuais					  				  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type("aMemos") == "A"
			For i := 1 to Len(aMemos)
				cVar := aMemos[i][2]
				cVar1:= aMemos[i][1]
				MSMM(&cVar1,TamSx3(aMemos[i][2])[1],,&cVar,1,,,cAlias,aMemos[i][1])
			Next i
		EndIf
		If cTransact != Nil
			If !("("$cTransact)
				cTransact+="()"
			EndIf
			lX := &cTransact
		EndIf
	End Transaction ExtEnded
EndIf
If nOpcA == 3
	MsUnLockAll()
EndIf

DbSelectArea(cAlias)
Return nOpcA


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QMTGeraRev³ Autora³ Iuri Seto     	    ³ Data ³ 15/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gerar nova revisao.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QMTGeraRev(ExpC1)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : campos que nao geram revisao						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION QMTGeraRev(cCamNRev)
Local lRet	:= .F.
Local i
Local bCampo

bCampo := {|nCPO| Field(nCPO) }
FOR i := 1 TO FCount()
    If M->&(EVAL(bCampo,i)) <> FieldGet(i) .And. !( EVAL(bCampo,i) $ cCamNRev )
		lRet := .T.
		Exit
	EndIf
NEXT i
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QMTMARConf³ Autora³ Iuri Seto     	    ³ Data ³ 15/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a alteracao esta OK.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QMTMARConf()   											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMARConf(nOpcA,cCamNRev,cTudoOk,oDlg,aArrayQM2)
Local lRet := .F.,lVer := .F.
Local nX := 1

nOpca := If(QMTGeraRev(cCamNRev),4,1)

lRet := Obrigatorio(aGets,aTela)

If lRet
	lRet := Eval({|| &cTudoOk. })
EndIf

If lRet
   If nOpca==4
      lRet := MsgYesNo(Oemtoansi(STR0016),Oemtoansi(STR0015))
   Endif

   If nOpca==1  //Verifica se foi alterado algo no cadastro
      For nX := 1 To Len(aTela)
          If aTela[nX][2] != aArrayQM2[nX][2]
             lVer := .T.
          Endif
      Next nX
      If lVer
         lRet := MsgYesNo(Oemtoansi(STR0017),Oemtoansi(STR0015))
      Else
      	 lRet := .F.
      Endif
   Endif
EndIf

If lRet
	oDlg:End()
Else
	nOpca:=3
EndIF

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³AxGatSeq	³ Autor ³ Denis Martins         ³ Data ³18/06/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho para retornar ultima sequencia					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AxGatSeq()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Gatilho do campo QM6_INSTR p/ QM6_REVINS					  ³±±
±±³			 ³ Gatilho do campo QME_INSTR p/ QME_REVINS					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AxGatSeq(cInstr,cRevIns,dMtData)
Local cSequ := ""
Local aArea := GetArea()
Local lRet	:= .T.
//Garante todos os campos obrigatorios preenchidos
If Empty(cInstr) .or. Empty(cRevIns) .or. Empty(dMtData)
	lRet := .F.
Endif

If lRet
	dbSelectArea("QM6")
	QM6->(DbSetOrder(1))

	If dbSeek(xFilial("QM6")+cInstr+cRevIns+DtoS(dMtData))
		While !QM6->(Eof()) .And. xFilial("QM6")+cInstr+cRevIns+DtoS(dMtData) ==;
			QM6->QM6_FILIAL+QM6->QM6_INSTR+QM6->QM6_REVINS+DTOS(QM6->QM6_DATA)
			cSequ := QM6->QM6_CSEQ
			cSequ := Str(Val(cSequ) + 1)
			If Val(Alltrim(cSequ)) <= 9
				cSequ := "0"+Alltrim(cSequ)
			Endif
			QM6->(dbSkip())
		Enddo
		M->QM6_CSEQ := cSequ
	Else
		M->QM6_CSEQ := "00"
	Endif
	RestArea(aArea)
	Return( M->QM6_CSEQ )
Else
	Return lRet
Endif

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMTXFUN   ºAutor  ³Denis Martins       º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Na entrada do Modulo Metrologia, dispara e-mail alertando   º±±
±±º          ³sobre as pendencias dos instrumentos(validade de afericao). º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA160,QMTA010,QMTA070                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMTLOAD()
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄT¿
//³Tipos de Movimentação:                                                   ³
//³1 = Movimentação Tipo 1 (Movimentação entre Departamentos de uma Filial) ³
//³2 = Movimentação Tipo 2 (Movimentação de Instrumentos Entre Filiais)     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄTÙ
*/
Private cTpMov		:= GetMV("MV_QMTPMOV", .F., "1") // 1 = Mov Tipo 1 / 2 = Mov Tipo 2


//Realiza travamento do usuario...
QA_TRAVUSR()
If cTpMov == "2"
    QMTINVEN()
EndIf
If GetMV("MV_QMETODE",.T.,.T.)  //Envia E-mail das pendencias aos usuarios...
	QmtEMailInst()
	QMT160EMP()
	QMT160DVOL()
	QMT070Email()
	If GetMV("MV_QEEINST",.T.,"2") == "1" //Envia e-mail para responsaveis (instrumento emprestados) e nao devolvidos na data de retorno
		QMT160AVI()
	Endif
Endif

If GetMv("MV_QALOGIX") == "1" //Caso haja integracao com o Logix - verifica se tem inconsistencias nos WebServices
	If GetMV("MV_QMLOGIX",.T.,"1") == "1" //Define se mostra a tela de inconsistencia
		QXMSLOGIX()
	Endif
Endif

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMTrUltQM6ºAutor  ³Denis Martins       º Data ³  01/28/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Traz a ultima calibracao do instrumento+revisao considerandoº±±
±±º          ³o status e flag do instrumento e validade de afericao.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SXB - QXD(Metrologia)                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMTrUltQM6(lSeek,cInstt,cRevo)
Local aArea := GetArea()
Local lRet 	:= .T.
Default lSeek	:= .T.
Default cInstt	:= QM2->QM2_INSTR
Default cRevo	:= QM2->QM2_REVINS

If lSeek
	dbSelectArea("QM2")
	dbSetOrder(1)
	If !dbSeek(xFilial("QM2")+cInstt+Inverte(cRevo))
		Help(" ",1,"A010NAOINS") //Codigo/Revisao do instrumento nao cadastrado
		lRet := .F.
	Endif
Endif
If lRet
	If QM2->QM2_FLAG == "1" .and. QMTXSTAT(QM2->QM2_STATUS) .and. (QM2->QM2_VALDAF >= dDataBase)
		dbSelectArea("QM6")
		dbSetOrder(2)
		If dbSeek(xFilial("QM6")+QM2->QM2_INSTR+QM2->QM2_REVINS)
			lRet := .T.
		Endif
	Endif
Endif
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQMTANEXO  ³ Autor ³ Cicero Odilio Cruz  ³ Data ³ 24/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta Tela com os Anexos da Calibracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQMTANEXO()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FQMTANEXO(nOpct,aColAnx)
Local oDlgDC
Local aButtons	:= {}
Local aAlter  	:= {}
Local lAlter  	:= .F.
Local nOpcao  	:= 0
Local lRet		:= .T.
Local lRoda     := .T.
Local aAreaSX3  := " "
Local lEmpty    := .F.
Local bCondicao := ""

Default nOpct	:= 4

Private oGetDC

// Verifica se o botao GERA ja foi apertado
If !lJaMontTre
	return
EndIf

If empty(M->QM6_INSTR)
	return
EndIf

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Verifica a existencia dos campos principais a serem utiliza- ³
// ³ dos.  														 ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAreaSX3 := SX3->(GetArea())
SX3->(dbSetOrder(2))
lRoda := SX3->(dbSeek("QN7_ANEXO"))
RestArea(aAreaSX3)
If !lRoda
    MsgInfo(STR0018)	//"Tabela QN7 requerida!"
	Return
EndIf

// Garante  dados  principais
dData    := Iif(Empty(dData),M->QM6_DATA,Iif(dData==M->QM6_DATA,dData,M->QM6_DATA))

Private aHeader   := {}
Private aCols     := {}
Private nUsado    := 0
Private cAliasAnex:= "QN7"
Default aColAnx	  := {}

n:= 1
Aadd(aAlter,"QN7_DESCR" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se pode ser Alterado / Deletado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpct == 3 .Or. nOpct == 4
	nOpct := 4
	lAlter:= .T.
EndIf


DEFINE MSDIALOG oDlgDC TITLE OemToAnsi(STR0019) FROM 000,000 TO 315,625 OF oMainWnd PIXEL // "Documento Anexo"

dbSelectArea("QN7")
dbSetOrder(1)
If lGHist
	lEmpty := IIf(dbSeek(xFilial("QN7")+M->QM6_INSTR+M->QM6_REVINS),.F.,.T.)
Else
	lEmpty := IIf(dbSeek(xFilial("QN7")+M->QM6_INSTR+M->QM6_REVINS+DTOS(M->QM6_DATA)+M->QM6_CSEQ),.F.,.T.)
EndIf

IF lGHist
	cSeek  := QN7->QN7_FILIAL+QN7->QN7_INSTR+QN7->QN7_REV
	cWhile := "QN7->QN7_FILIAL+QN7->QN7_INSTR+QN7->QN7_REV"
Else
	cSeek  := QN7->QN7_FILIAL+QN7->QN7_INSTR+QN7->QN7_REV+Dtos(QN7->QN7_DATA)+QN7->QN7_SEQINS
	cWhile := "QN7->QN7_FILIAL+QN7->QN7_INSTR+QN7->QN7_REV+Dtos(QN7->QN7_DATA)+QN7->QN7_SEQINS"
	bCondicao := {|| If( (M->QM6_INSTR == QN7->QN7_INSTR .AND. M->QM6_REVINS == QN7->QN7_REV .AND. M->QM6_CSEQ == QN7->QN7_SEQINS .AND. M->QM6_DATA == QN7->QN7_DATA) , .T. , .F. ) }
EndIf

If !lEmpty .Or. Len(aColAnx) != 0
	FillGetDados(nOpct,cAliasAnex,1,cSeek ,{|| &cWhile},          ,         ,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpct,Alias     ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
Else
	FillGetDados(nOpct,cAliasAnex,1     ,      ,             ,bCondicao ,         ,          ,        ,      ,        , lEmpty,          ,        ,          ,           ,            ,)
  //FillGetDados(nOpct,Alias     ,nOrdem,cSeek  ,bSeekWhile   ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
EndIf

nUsado := Len(aHeader)
If Len(aColAnx) > 0
	aCols := aClone(aColAnx)
	aHeadAnx := aClone(aHeader)
Else
	aColAnx := aClone(aCols)
	aHeadAnx := aClone(aHeader)
EndIf

oGetDC := MSGetDados():New(030,002,155,312  ,nOpct,"QMTALinOk()" ,," ",lAlter,aAlter,,,,,,,If(lAlter,"QMTVdRAnex",),oDlgDC)
oGetDC:oBrowse:Refresh()
oGetDC:Refresh()

aAdd(aButtons,{"SDUPROP", {|| lRet:=QMTVRFAnexo(nOpct) }, OemToAnsi(STR0019),OemToAnsi(STR0020) } )  //"Documento Anexo"###"Doc.Anexo"

ACTIVATE MSDIALOG oDlgDC ON INIT EnchoiceBar(oDlgDC,{|| IF(QMTATudOk(lAlter),(nOpcao:=1,oDlgDC:End()),"") },{|| oDlgDC:End()},,aButtons) CENTERED

IF nOpcao == 1 .And. lRet
   aColAnx:=Aclone(aCols)
Endif

Return(aColAnx)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QMTALinOk  ³ Autor ³ Cicero Odilio Cruz  ³ Data ³ 24/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Consistencia para mudanca/inclusao de linhas              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMTALinOk                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQMT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMTALinOk()
Local lRet    := .T.
Local nPos01  := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QN7_DESCR" })
Local nPos02  := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QN7_ANEXO" })
Local nPosDel := Len(aHeader) + 1

If aCols[n,nUsado+1] == .F.
	If nPos01 <> 0 .Or. nPos02 <> 0
		If Empty(Acols[n,nPos01]) .Or. Empty(Acols[n,nPos02])
			Help(" ",1,"QDOBRIG") // "Existem campos obrigatorios nao preenchidos"
		   	lRet:= .F.
		EndIf
	EndIf
EndIf

If lGHist .And. !aCols[n, nPosDel]
	lRet := .F.
	Help(,,"Help", "MV_QMTGINS", STR0045 ,1, 0,,,,,, {STR0046}) 
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QMTATudOk  ³ Autor ³ Cicero Odilio Cruz  ³ Data ³ 24/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consistencia para mudanca/inclusao de linhas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMTATudOk(lAlter)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQMT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMTATudOk(lAlter)
Local lRet   := .T.
Local nPos01 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QN7_DESCR" })
Local nPos02 := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QN7_ANEXO" })
Local nIc	 := 0

IF lAlter
	For nIc:=1 To Len(aCols)
   		If aCols[nIc,nUsado+1] == .F.
	 		If nPos01 <> 0 .Or. nPos02 <> 0
				If Empty(Acols[n,nPos01]) .Or. Empty(Acols[n,nPos02])
					Help(" ",1,"QDOBRIG") // "Existem campos obrigatorios nao preenchidos"
				   	lRet:= .F.
				EndIf
			EndIf
		EndIf
	Next
Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QMTVRFAnexo³ Autor ³ Cicero Odilio Cruz  ³ Data ³ 24/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclui / Visualiza Documento Anexo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMTVRFAnexo(nOpc)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQMT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMTVRFAnexo(nOpc)
Local nPosSeq  := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QN7_SEQ" })
Local nPos1    := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QN7_ANEXO" })
Local cArqAnexo:= ""
Local cFileTrm := ""
Local lRet     :=.F.

cMtSeq := Iif(Empty(cMtSeq),Iif(Empty(M->QM6_CSEQ),"00",M->QM6_CSEQ),cMtSeq)
//__INSTRUMENTO___ __ SEQ SQ_DATA_
//XXXXXXXXXXXXXXXXPXXP999P99YYMMDD.CEL
//123456789012345678901234567890123456789
cArqAnexo:= AllTrim(cMtInstr) + "P" + cMtRevIns + "P" + SubStr(Acols[n,nPosSeq],1,3)+ "P" + cMtSeq + RIGHT(Dtos(dData),6) + ".cal"
cFileTrm:= aCols[n,nPos1]
lRet:=FQMTDRIVE(nOpc,@cFileTrm,cArqAnexo)

If lRet
	aCols[n,nPos1]:= cFileTrm
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QMTVRFAnexo³ Autor ³ Cicero Odilio Cruz  ³ Data ³ 24/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se Usuario pode alterar / deletar Doctos Anexos   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMTVRFAnexo(nOpc)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQMT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMTVdRAnex()
Local lRet :=.T.
//Valida Anexo
Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FQMTDrive  ³ Autor ³ Aldo Marini Junior   ³ Data ³ 29/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa generico para Selecionar diretorio do Documento   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQMTDrive(nOpc)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Expn1 - Opcao do Cadastro                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQMTDrive(nOpc,cFileTrm,cArqAnexo)

Local cFile		:= ""
Local cFileTmp := ""
Local nTrm     := 0
Local cQPathQMT:= GETMV("MV_QMTPATH",.T.,"\SYSTEM\DOCS\")
Local aQPath   := QDOPATH()

Private cQPathTrm := aQPath[3]

If At("/",cArqAnexo) > 0
	cArqAnexo := StrTran(cArqAnexo,"/","")
EndIf

If !Right( cQPathQMT,1 ) == "\"
	cQPathQMT := cQPathQMT + "\"
Endif
If !Right( cQPathTrm,1 ) == "\"
	cQPathTrm := cQPathTrm + "\"
Endif

IF Empty(cFileTrm)

	If nOpc == 2	// Visualizar - Opcao Cadastro
		MsgAlert(OemToAnsi(STR0021),OemToAnsi(STR0015))	     		//"Nao existe nenhum documento anexo a esta Calibracao" ### "Aten‡ao"
	Else
		cFile := Trim(cGetFile(STR0037+"|*.DOC|"+;		// "Documentos Anexos(*.Doc)"
						   PADR(STR0038,27)+"|*.TXT|"+;    // "Arquivos Texto(*.Txt)"
						   PADR(STR0039,27)+"|*.*|" ,;     // "Todos Arquivos(*.*)"
						   STR0040,0,,.T.,;			// "Selecione Diretorio e Arquivo"
						   49))

		If !Empty(cFile)

         	cQPathQMT 	:= StrTran(cQPathQMT,"SERVIDOR","")
         	cArqAnexo	:= Left(cArqAnexo, Len(cArqAnexo) - 3) + Right(cFile, (LEN(CFILE)-RAt(".",cFile)))		// Uso a extensao selecionada

			If AT(":",cFile) > 0
				__CopyFile(cFile,cQPathTrm + cArqAnexo)
				If !File(cQPathTrm + cArqAnexo)
					Help(" ",1,"QNAOCOP")
					Return
				Endif
  	  		Else
				If !CpyS2T(cFile,cQPathTrm,.T.)
					Help(" ",1,"QNAOCOP")
					Return
				Endif

				cFileTmp := ""
				For nTrm:= Len(cFile) to 1 STEP -1
					If SubStr(cFile,nTrm,1) == "\"
						Exit
					Endif
					cFileTmp := SubStr(cFile,nTrm,1)+cFileTmp
				Next

				__CopyFile(cQPathTrm+cFileTmp,cQPathTrm + cArqAnexo)
				If File(cQPathTrm+cFileTmp)
					FErase(cQPathTrm+cFileTmp)
				Endif
	  		Endif

			cFileTrm := cArqAnexo

			If Len(cFileTrm) > TamSX3('QN7_ANEXO')[1]
				HELP(" ",1,"QMT140TAMDOC")
				Return .F.
			Endif

			If File(cQPathTrm+cFileTrm).And. ;
				MsgYesNo(OemToAnsi(STR0022),OemToAnsi(STR0015))	     	//"Deseja Visualizar o Documento Agora?" ### "Aten‡ao"
				QA_OPENARQ(cQPathTrm+cFileTrm)//Programa para abrir arquivo com qualquer extensao. - QAXFUNA.PRX
			Endif
		Endif
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Visualiza Documento Anexo. 			   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File(cQPathTrm+AllTrim(cFileTrm))
		If !CpyS2T(cQPathQMT+AllTrim(cFileTrm),cQPathTrm,.T.)
			If !File(cQPathTrm+AllTrim(cFileTrm))
				Help(" ",1,"QNAOCOP")
				Return
			Endif
		Endif
	EndIf

	If File(cQPathTrm+cFileTrm)
		QA_OPENARQ(cQPathTrm+cFileTrm)//Programa para abrir arquivo com qualquer extensao. - QAXFUNA.PRX
	Endif
Endif

Return(!Empty(cFileTrm))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QMTGAnexo³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 27/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Anexos                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMTGAnexo(ExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQMT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QMTGAnexo(nOpc)

Local lRecLock:= .F.
Local nCnt    := 0
Local nCpo    := 0
Local nPosDel := Len(aHeader) + 1
Local nPosSeq := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QN7_SEQ"})
Local nPosArq := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QN7_ANEXO"})
Local cFilAnex := ""
Local cCodAnex := ""
Local cRevAnex := ""
Local cSeqAnex := ""
Local cComp := ""
Local cQPathQMT:= GETMV("MV_QMTPATH",.T.,"\SYSTEM\DOCS\")
Local aQPath   := QDOPATH()
Local lRet 		:= .T.

Private cQPathTrm := aQPath[3]

If !Right( cQPathQMT,1 ) == "\"
	cQPathQMT := cQPathQMT + "\"
Endif
If !Right( cQPathTrm,1 ) == "\"
	cQPathTrm := cQPathTrm + "\"
Endif


If nOpc == 3
	lRecLock:= .T.
EndIf

cFilAnex := M->QM6_FILIAL
If Empty (cFilAnex)
   cFilAnex := xFilial(cAliasAnex)
Endif
cCodAnex := M->QM6_INSTR
cRevAnex := M->QM6_REVINS
cSeqAnex := Iif(Empty(M->QM6_CSEQ),"00",M->QM6_CSEQ) // Garanto o preenchimento da Sequencia


Begin Transaction
	DbSelectArea(cAliasAnex)
	DbSetOrder(1)
	For nCnt:= 1 To Len(aCols)
		IF lGHist
			cComp  := cFilAnex+cCodAnex+cRevAnex
		Else
			cComp  := cFilAnex+cCodAnex+cRevAnex+Dtos(dData)+cSeqAnex+SubStr(Acols[nCnt,nPosSeq],1,3)
		EndIf

		If !aCols[nCnt, nPosDel] // Verifica se o item foi deletado
 			If DbSeek(cComp)
				lRecLock := .F.
			Else
				lRecLock := .T.
			Endif

			RecLock(cAliasAnex,lRecLock)

			For nCpo := 1 To Len(aHeader)
				If aHeader[nCpo, 10] <> "V"
					FieldPut(FieldPos(Trim(aHeader[nCpo,2])),aCols[nCnt,nCpo])
				EndIf
			Next nCpo
			If lRecLock
				QN7->QN7_FILIAL := cFilAnex
				QN7->QN7_INSTR  := cCodAnex
				QN7->QN7_REV    := cRevAnex
				QN7->QN7_SEQINS := cSeqAnex
				QN7->QN7_DATA   := dData
				QN7->QN7_SEQ    := aCols[nCnt,nPosSeq]
			EndIf


		    MsUnlock()

			__CopyFile(cQPathTrm+ALLTRIM(aCols[nCnt,nPosArq]), cQPathQMT+ALLTRIM(aCols[nCnt,nPosArq]) )
			If !File(cQPathQMT+ALLTRIM(aCols[nCnt,nPosArq]))
				Help(" ",1,"QNAOCOP")
				DisarmTransaction()
				lRet := .F.
				Break
			Else
				FErase(cQPathTrm+ALLTRIM(aCols[nCnt,nPosArq]))
			Endif
		Else
			If DbSeek(cComp)
				cFileTrm:= Acols[nCnt,nPosSeq]
				If File(cQPathQMT+cFileTrm)
					FErase(cQPathQMT+cFileTrm)
				Endif

				RecLock(cAliasAnex,.F.)
				DbDelete()
				MsUnlock()
			Endif
		Endif
	Next nCnt
End Transaction

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QMTAtuIDis³ Autora³ Renata Cavalcante     ³ Data ³ 11/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza cadastro de Instrumentos Disponiveis para         ³±±
±±³          ³ Movimentação entre departamentos e filais                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QMTAtuIDis(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpC6,ExpC7)	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Instrumento  	 				  	      ³±±
±±³			 ³ ExpC2 = Revisão do Instrumento					  	      ³±±
±±³			 ³ ExpC3 = Codigo do Usuario Responsavel.			  	      ³±±
±±³			 ³ ExpC4 = Filial do Usuario Responsavel			  	      ³±±
±±³			 ³ ExpC5 = Departamento do Usuario Responsavel.		  	      ³±±
±±³			 ³ ExpC6 = Familia                                  	      ³±±
±±³			 ³ ExpC7 = Tipo de ADM da tabela (I/E)                 	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMTAtuIDis(cInst,cRevIns,cResp,cFilRes,cDepRes,cTipo,cTipAdm)

Local aArea := GetArea()

If cTipAdm == "I"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclusao do Instrumento no cadastro de Instrumentos Liberados para uso.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QN5")
	dbSetOrder(1)
	If !dbSeek(xFilial("QN5")+cInst+cRevIns+SM0->M0_CODFIL)
		RecLock("QN5", .T. )
		QN5->QN5_FILIAL  := xFilial("QN5")
		QN5->QN5_INSTR   := cInst
		QN5->QN5_REVINS  := cRevIns
		QN5->QN5_FILINS  := SM0->M0_CODFIL
		QN5->QN5_TIPO    := cTipo
	Else
		RecLock("QN5", .F. )
	EndIf
	QN5->QN5_STATUS := "1"
	MsUnlock()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclusao do Instrumento no cadastro de Movimentacao dos Instrumentos.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QN4")
	dbSetOrder(1)
	If !dbSeek(xFilial("QN4")+cInst+cRevIns+SM0->M0_CODFIL)
		RecLock("QN4", .T. )
		QN4->QN4_FILIAL  := xFilial("QN4")
		QN4->QN4_INSTR   := cInst
		QN4->QN4_REVINS  := cRevIns
		QN4->QN4_TIPO    := cTipo
		QN4->QN4_FILINS  := SM0->M0_CODFIL
	Else
		RecLock("QN4", .F. )
	EndIf

	QN4->QN4_DTASAI := dDataBase
	QN4->QN4_HORSAI	:= Time()
	QN4->QN4_RESSAI	:= cResp
	QN4->QN4_FILRSA := cFilRes
	QN4->QN4_DEPRSA	:= cDepRes
	QN4->QN4_DTAENT	:= dDataBase
	QN4->QN4_HORENT	:= Time()
	QN4->QN4_RESENT	:= cResp
	QN4->QN4_FILREN := cFilRes
	QN4->QN4_DEPREN	:= cDepRes
	QN4->QN4_TPMOV	 := "1"
	QN4->QN4_TPDEV	 := "2"
	QN4->QN4_DTADEV	:= CTOD("  /  /  ")
	QN4->QN4_ULTMOV	:= "S"
	QN4->QN4_SEQUEN := StrZero(1,10)
	MsUnlock()

Else
	dbSelectArea("QN5")
	dbSetOrder(1)
	If dbSeek(xFilial("QN5")+cInst+cRevIns+SM0->M0_CODFIL)
		RecLock("QN5",.F.)
		dbDelete()
		MsUnlock()
	EndIf
EndIF

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ TrataPar ³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 31.05.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Trata parametros do tipo Range salvando o ADVPL do Range   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTR010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TrataPar(cPerg, aParRange, oReport, lQuery)
Local nI := 0
   //Faco backup dos parametros
   For nI := 1 to Len(aParRange)
		&("advMV_"+aParRange[nI]+" := MV_PAR"+aParRange[nI])
   Next

   MakeAdvplExpr(cPerg)

   For nI := 1 to Len(aParRange)
   		uAux     := &("advMV_"+aParRange[nI])
		&("advMV_"+aParRange[nI]+" := MV_PAR"+aParRange[nI])
   		//advMV_01 := MV_PAR01
   		&("MV_PAR"+aParRange[nI]) := uAux
   Next

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Transforma parametros Range em expressao                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If lQuery
	   MakeSqlExpr(oReport:uParam)
   Else
	   MakeAdvplExpr(oReport:uParam) // Para mantermos a compatibilidade com os  parametros
   EndIf