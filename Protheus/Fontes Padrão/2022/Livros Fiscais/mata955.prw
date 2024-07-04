#Include 	"Protheus.Ch"
#Include	"Mata955.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ListInis  ³ Autor ³Gustavo G. Rueda       ³ Data ³05.05.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Help para o inis contidos no diretorio SIGAADV              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL - .T.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC - cFile - Arquivos a serem listados no ScrollBox       ³±±
±±³          ³ExpC - cPar - Parametro a ser atualizado com o nome do ini  ³±±
±±³          ³ selecionado quando OK.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATA955 (cFile, cPar)
	Local	lRet		:=	.T.
	Local	nInd		:=	0
	Local	aListInis	:=	Directory (cFile)
	Local	cNameIni	:=	""
	Local	cLinha		:=	""
	Local	aHelp		:=	{}
	Local	aShowInis	:=	{}
	Local	lMVMTA9551	:=	!GetNewPar ("MV_MTA9551","XXX")=="XXX"
	Local	cMVMTA9551	:=	Iif (lMVMTA9551, SuperGetMv ("MV_MTA9551"), "")
	Local	lMVMTA9552	:=	!GetNewPar ("MV_MTA9552","XXX")=="XXX"
	Local	cMVMTA9552	:=	Iif (lMVMTA9552, SuperGetMv ("MV_MTA9552"), "")
	Local	aMVMTA955	:=	{}
	Local	aAsterist	:=	{}
	Local 	nAux		:=	Iif ("/"$SubStr (cMVMTA9551, 1, 1), 2, 1)
	Local	nCtdChar	:=	0
	Local	aX			:=	{}
	Local	cMvs		:=	""
	Local	cDrive		:=	""
	Local	cDir		:=	""
	Local	cDest		:=	""
	Local	cExt		:=	""
	Local	cLib		:=	""
	Local	nRetType 	:=	GetRemoteType( @cLib )
	Local	lTela		:= .T.
	Local	lSmartERP	:= ("HTML" $ cLib .And. nRetType <> 5)

	If lSmartERP

		cFile := cGetFile( '*.ini|*.ini' , 'Textos (INI)', 1, '\system\', .F., ,.T., .T. )
		
		If !Empty(cFile)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atraves destes parametros he possivel eliminar alguns inis do listbox.     ³
			//³Basta preencher estes parametros com os nomes a serem excluidos do listbox.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cMvs	:=	cMVMTA9551
			If (SubSTr (cMVMTA9552, 1, 1)=="/")
				cMvs	+=	SubSTr (cMVMTA9552, 2)
			ElseIf !(Empty (cMVMTA9552))
				cMvs	+=	cMVMTA9552
			EndIf	

			aMvs := Strtokarr2( cMvs, "/", .T.)

			SplitPath(cFile,@cDrive,@cDir,@cDest,@cExt)

			nPosMvs := aScan(aMvs,{|aX|  Upper(AllTrim(StrTran(aX,"*",""))) $ Upper(cDest) })

			If nPosMvs > 0
				MsgAlert("Arquivo Nâo pode ser utilizado na rotina de instrução normativa")
				lTela := .F.
			Else
				If File (cFile)
					FT_FUse(cFile)
					FT_FGoTop ()
					cLinha := FT_FREADLN()
					//
					aHelp	:=	{}
					//
					If ("?"$SubStr (cLinha, 1, 1))
						Do While "?"$SubStr (cLinha, 1, 1)
							aAdd (aHelp, &(AllTrim (SubStr (cLinha, 2))))
								//
							FT_FSkip ()
							cLinha := FT_FREADLN()
						EndDo
					EndIf
					aAdd (aShowInis, {cDest+cExt, aHelp})
				EndIf

			EndIf	
		Else
			lTela := .F.
		EndIf	
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atraves destes parametros he possivel eliminar alguns inis do listbox.     ³
		//³Basta preencher estes parametros com os nomes a serem excluidos do listbox.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMvs	:=	cMVMTA9551
		If (SubSTr (cMVMTA9552, 1, 1)=="/")
			cMvs	+=	SubSTr (cMVMTA9552, 2)
		ElseIf !(Empty (cMVMTA9552))
			cMvs	+=	cMVMTA9552
		EndIf	
		//
		For nInd := 0 To Len (cMvs)	
			If (nInd<>1 .And. "/"$SubStr (cMvs, nInd, 1))
				If ("*"$SubStr (cMvs, nInd-1, 1))
					aAdd (aAsterist, Upper (SubStr (cMvs, nAux, nCtdChar-1)))
				Else
					aAdd (aMVMTA955, Upper (SubStr (cMvs, nAux, nCtdChar-1)))
				EndIf
				//
				nAux		:=	nInd+1
				nCtdChar	:=	0
			EndIf
			//
			nCtdChar++
		Next (nInd)
		//
		//
		For nInd := 1 To Len (aListInis)		
			cNameIni	:=	AllTrim (aListInis[nInd][1])
			cName		:=	SubStr (cNameIni, 1, At (".", cNameIni)-1)
			//
			If aScan (aMVMTA955, {|aX| SubStr (aX, 1, Len (aX))==cName})==0 .And.;
				aScan (aAsterist, {|aX| SubStr (aX, 1, At ("*", aX)-1)$SubStr (cName, 1, At ("*", aX)-1)})==0
				//
				If File (cNameIni)
					FT_FUse(cNameIni)
					FT_FGoTop ()
					cLinha := FT_FREADLN()
					//
					aHelp	:=	{}
					//
					If ("?"$SubStr (cLinha, 1, 1))
						Do While "?"$SubStr (cLinha, 1, 1)
							aAdd (aHelp, &(AllTrim (SubStr (cLinha, 2))))
							//
							FT_FSkip ()
							cLinha := FT_FREADLN()
						EndDo
					EndIf
					aAdd (aShowInis, {cNameIni, aHelp})
				EndIf
			EndIf
		Next (nInd)
	EndIf
	
	If lTela
		Tela (aShowInis, cPar,cFile )
	
		If !lSmartERP
			If aScan( aShowInis, {|aX| SubStr(aX[1], 1, At(".",aX[1])-1)==Alltrim(&(cPar))} ) ==0
				lRet := .F.
			EndIf
		EndIf
		FT_FUse()
	EndIf

Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Tela      ³ Autor ³Gustavo G. Rueda       ³ Data ³05.05.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Montagem da tela de help.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL - .T.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA - aShowInis - Array contendo os nomes dos ini's e os    ±±
±±³          ³help's para os mesmos.                                      ³±±
±±³          ³ExpC - cPar - Paramentro a ser atualizado com o nome do ini ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tela (aShowInis, cPar,cFile)
	Local 	oDlg
	Local	oFont	:=	TFont():New( "Arial",,15,,.F.)
	Local	oFontB	:=	TFont():New( "Arial",,15,,.T.)
	Local	oGrp1
	Local	oGrp2
	Local	oSroll
	Local	oPainel
	Local	oSay
	Local	oSay2
	Local	oSBtn1
	Local	oList1
	Local	lRet	:=	.T.
	Local 	aArray	:=	{}
	Local	aArray2	:=	{}
	Local 	nLinI 	:=	0
	Local	nInd	:=	0
	Local	aSay	:=	{}
	Local	nLimLinha	:=	100
	Local  nList1 := 1
	Local	cLib		:=	""
	Local	nRetType 	:=	GetRemoteType( @cLib )
	Local	lSmartERP	:= ("HTML" $ cLib .And. nRetType <> 5)
	Local	cButton	:=	"{|| Iif (oList1:nAt==0, oDlg:End (),(FOk (cPar, Iif(lSmartERP,cFile,aArray[oList1:nAt])), oDlg:End ()))}"
	//
   	For nInd := 1 To Len (aShowInis)
		aAdd (aArray, aShowInis[nInd][1])
	Next (nInd)
	
	//
	DEFINE MSDIALOG oDlg FROM  0, 0 TO 492, 610 TITLE OemToAnsi (STR0001) PIXEL
	//
	oSBtn1	:=	TButton ():New (227, 265, STR0006, oDlg, &(cButton), 35, 13,, oFont,.F.,.T.,.F.,,.F.,,,.F.)
	//
	oGrp1				:= 	TGroup ():New(7, 5, 220, 120, STR0002, oDlg,,, .T., .T. )
	oGrp1:oFont			:=	oFont
	oGrp1:bLDblClick 	:=	{|| Iif (oList1:nAt==0, oDLG:End (),(FOk (cPar, Iif(lSmartERP,cFile,aArray[oList1:nAt])), oDLG:End ()))}
	//
	oList1	:=	TListBox ():New (15, 10, {|| Nil}, aArray, 105, 200,, oGrp1,,,,.T.,,,oFont)
	oList1:bChange 			:= {|| AtuDescri (@aShowInis, oList1:nAt, @oScroll, aSay, nLimLinha, oFont, oFontB) }
	oList1:bLDblClick 		:= {|| (FOk (cPar, Iif(lSmartERP,cFile,aArray[oList1:nAt])), oDlg:End ())}
	//
	oGrp2				:= 	TGroup ():New(7, 125, 220, 300, STR0003, oDlg,,, .T., .T. )
	oGrp2:oFont			:=	oFont
	//
	oPainel	:=	TPanel():New (15, 129,, oGrp2,,,,,, 166, 200,.F.,.F.)
	//
	oScroll	:=	TScrollBox ():New (oPainel, 0, 0, 200, 166, .T., .T., .T.)
	//
	nLinI	:=	1
	For nInd := 1 To nLimLinha
		oSay := TSay():New( nLinI, 1, {|| }, oScroll,,oFont, .F., .F., .F., .T.,,,155, 10, .F., .F., .F., .F., .F. )		
		nLinI	+=	10
		//
		aAdd (aSay, oSay)
	Next nInd
	//
	ACTIVATE MSDIALOG oDlg CENTERED
Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FOk       ³ Autor ³Gustavo G. Rueda       ³ Data ³05.05.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de atualizacao do Help                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL - .T.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA - aShowInis-Array contendo as características de todos |±±
±±³          ³ os inis.                                                   ³±±
±±³          ³ExpN - nPos - Posicao do objeto selecionado na ScrollBox    ³±±
±±³          ³ExpO - oScroll - Objeto ScrollBar                           ³±±
±±³          ³ExpA - aSay - Array contendo todos os objetos SAY           ³±±
±±³          ³ExpN - nLimLinha - Limite de Obj SAY definidos pela rotina  ³±±
±±³          ³ExpO - oFont - Fonte padrao da rotina                       ³±±
±±³          ³ExpO - oFontB - Fonte padrao da rotina BOLD                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AtuDescri (aShowInis, nPos, oScroll, aSay, nLimLinha, oFont, oFontB)
	Local	lRet	:=	.T.
	Local	nI		:= 	0 // Contador do for.
	Local	nI2		:=	0
	Local	nInd	:=	1
	Local	nSay	:=	1
	Local	nChar	:=	50	//Caracteres por linha
	//
	LimpaSay (aSay, oFont)
	//
	If Len (aShowInis[nPos][2])>0
		Do While (nInd<=Len (aShowInis[nPos][2])) .And. (nInd<=nLimLinha)
			For nI := 1 To Len (aShowInis[nPos][2][nInd])
				If !Empty (aShowInis[nPos][2][nInd][nI])
					If nI==1 .And. Len(aShowInis[nPos][2][nInd])>1
						aSay[nSay]:oFont	:=	oFontB
				    	aSay[nSay]:nClrText	:=	CLR_BLUE
				 	Else			 	
						aSay[nSay]:oFont	:=	oFont
				    	aSay[nSay]:nClrText	:=	CLR_BLACK
				 	EndIf
				 	//
					aRetSay	:=	RetSay (aShowInis[nPos][2][nInd][nI], nChar)
					For nI2 := 1 To Len (aRetSay)
					    aSay[nSay]:cCaption	:=	aRetSay[nI2]
					    nSay++
					Next nI2
				EndIf
				//
				If nI==2 .And. !Empty(aShowInis[nPos][2][nInd][nI])
					nSay++
				EndIf
		  	Next nI
		    nInd++
		EndDo
	Else
		aSay[1]:oFont  		:=	oFont
	    aSay[1]:nClrText	:=	CLR_BLACK
		aSay[1]:cCaption	:=	STR0005
	EndIf

Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FOk       ³ Autor ³Gustavo G. Rueda       ³ Data ³05.05.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de atualizacao do parametro                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL - .T.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC - cPar - Nome do parametro a ser autalizado com o nome |±±
±±³          ³ do ini selecionado na rotina.                              ³±±
±±³          ³ExpC - cPar - Nome do ini selecionado pela rotina           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FOk (cPar, cNomeIni)
	Local	lRet	:=	.T.
	//
	&(cPar)	:=	SubStr (cNomeIni, 1, At (".", cNomeIni)-1)
	//	
Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³LimpaSay  ³ Autor ³Gustavo G. Rueda       ³ Data ³05.05.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina para limpar todos os objs SAY antes de reutiliza-lo  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL - .T.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA - aSay - Array contendo todos os objs SAY da rotina    |±±
±±³          ³ExpO - oFont - Obj fonte padrao da rotina                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LimpaSay (aSay, oFont)
	Local	lRet	:=	.T.
	Local	nInd	:=	1
	//
	For nInd := 1 To Len (aSay)
		aSay[nInd]:oFont  		:=	oFont
		aSay[nInd]:nClrText		:=	CLR_BLACK
		aSay[nInd]:cCaption		:=	""
	Next nInd
Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetSay    ³ Autor ³Gustavo G. Rueda       ³ Data ³05.05.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o |Retorna em forma de array o texto ja quebrado a ser impresso³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA - aRetSay - Array com as linhas a serem impressas.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC - cLinSay - Linha a ser formatada fonforme a quebra    |±±
±±³          ³ExpN - nChar - Numero de caracteres por linha do array      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetSay (cLinSay, nChar)
	Local	aRetSay		:=	{}
	Local	aRetMont	:=	{}
	Local	nPos		:=	0
	Local	cRetSay		:=	""
	//
	aRetMont	:=	MontSay (cLinSay, nChar, 0)
	cRetSay	:=	aRetMont[1]
	nPos	:=	aRetMont[2]
	aAdd (aRetSay, cRetSay)
	//
	If nPos<>0
		Do while nPos<Len (cLinSay) .And. nPos<>0
			aRetMont	:=	MontSay (cLinSay, nChar, nPos)
			cRetSay	:=	aRetMont[1]
			nPos	:=	aRetMont[2]
			aAdd (aRetSay, cRetSay)		
		EndDo		
	EndIf
Return (aRetSay)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MontSay   ³ Autor ³Gustavo G. Rueda       ³ Data ³05.05.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de atualizacao do parametro                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA - Array com a string a ser impressa e a posicao parada ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC - cLinha - Linha a ser quebrada                        |±±
±±³          ³ExpN - nChar - Numero de caracteres por linha               ³±±
±±³          ³ExpN - nPos - Ultima posicao de quebra                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontSay (cLinha, nChar, nPos)
	Local	cString		:=	""
	Local	nInd		:=	0
	//
	Default	nChar	:=	63
	//
	If (Len (cLinha)>nChar)
		cString	:=	SubStr (cLinha, nPos+1, nChar)
		//
		If Len (cString)>=nChar
			For nInd := Len (cString) To 1 Step -1
				If SubStr (cString, nInd, 1)$" .,-"
					nPos	+=	nInd
					cString	:=	SubStr (cString, 1, nInd-1)
					Exit
				EndIf
			Next nInd
		Else
			nPos		:=	0
		EndIf
	Else
		cString		:=	cLinha
	EndIf
Return ({cString, nPos})