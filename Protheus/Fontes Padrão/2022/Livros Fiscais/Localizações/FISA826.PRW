#include 'fisa826.ch'
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "fwlibversion.ch"

#DEFINE _SEPARADOR 		CHR(09)
#DEFINE	_CUIT	   		1
#DEFINE _ACTECONO	    3
#DEFINE _BUFFER 16384
Static lCGC := .F.

Function FISA826()

	Local cCombo	:= ""
	Local aCombo	:= {}
	Local oDlg		:= Nil
	Local oFld		:= Nil

	Private cMes	:= StrZero(Month(dDataBase),2)
	Private cMesIni	:= StrZero(Month(dDataBase),2)
	Private cAnoIni	:= StrZero(Year(dDataBase),4)
	Private cMesFin	:= StrZero(Month(dDataBase),2)
	Private cAnoFin	:= StrZero(Year(dDataBase),4)
	Private lRet	:= .F.
	Private lPer	:= .T.

	aAdd( aCombo, STR0002 ) //"1- Fornecedor"
	aAdd( aCombo, STR0003 ) //"2- Cliente"
	aAdd( aCombo, STR0004 ) //"3- Ambos  "

	DEFINE MSDIALOG oDlg TITLE STR0005 FROM 0,0 TO 250,450 OF oDlg PIXEL

	@ 006,006 TO 040,170 LABEL STR0006 OF oDlg PIXEL //"Info. Preliminar"

	@ 011,010 SAY STR0007 SIZE 065,008 PIXEL OF oFld //"Arquivo :"
	@ 020,010 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 65,8 PIXEL OF oFld ON CHANGE ValidChk(cCombo)

//+----------------------
//| Campos Check-Up
//+----------------------

	@ 10,115 SAY STR0008 SIZE 065,008 PIXEL OF oFld //"Imposto: "

	@ 020,115 CHECKBOX oChk1 VAR lPer PROMPT STR0009 SIZE 40,8 PIXEL OF oFld ON CHANGE ValidChk(cCombo)  //"Percepcao"
	@ 030,115 CHECKBOX oChk2 VAR lRet PROMPT STR0010 SIZE 40,8 PIXEL OF oFld ON CHANGE ValidChk(cCombo) //"Retencao"


	@ 041,006 FOLDER oFld OF oDlg PROMPT STR0011 PIXEL SIZE 165,075 //"&Importação de Arquivo TXT"

//+----------------
//| Campos Folder 2
//+----------------
	@ 005,005 SAY STR0012 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta opcao tem como objetivo atualizar o cadstro    "
	@ 015,005 SAY STR0013 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Fornecedor / Cliente  x Imposto segundo arquivo TXT  "
	@ 025,005 SAY STR0014 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"disponibilizado pelo governo                         "

	@ 037,005 SAY STR0015  SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Informe o periodo:"
	@ 037,055 MSGET cMesIni PICTURE "@E 99" VALID !Empty(cMes) SIZE  015,008 PIXEL OF oFld:aDialogs[1]
	@ 037,070 SAY "/" SIZE  150, 8 PIXEL OF oFld:aDialogs[1]
	@ 037,075 MSGET cAnoIni PICTURE "@E 9999" VALID !Empty(cMes) SIZE 020,008 PIXEL OF oFld:aDialogs[1]

//+-------------------
//| Boton de MSDialog
//+-------------------
	@ 055,178 BUTTON STR0016 SIZE 036,016 PIXEL ACTION ImpArq(aCombo,cCombo) //"&Importar"
	@ 075,178 BUTTON STR0018 SIZE 036,016 PIXEL ACTION oDlg:End() //"&Sair"

	ACTIVATE MSDIALOG oDlg CENTER

Return Nil

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ ValidChk ³ Autor ³ Paulo Augusto       ³ Data ³ 30.03.2011 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Programa que impede o uso do check de retencao para        ³±±
	±±³          ³ clientes.                                                  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ cPar01 - Variavel com o valor escolhido no combo.          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ lRet - .T. se validado ou .F. se incorreto                 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Fiscal - Buenos Aires Argentina/Misiones                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function ValidChk(cCombo)
	Local lAux := .T.
	If lRet == .T. .and. Subs(cCombo,1,1) $ "2|3"    // Cliente nao tem retenção!
		lRet :=.F.
		lAux := .F.
	EndIf
	If  lRet == .T. .and. lPer == .T. .and. (Subs(cCombo,1,1) $ "1" )
		lRet :=.F.
		lPer :=.F.
		lAux := .F.
	EndIf

	oChk1:Refresh()
	oChk2:Refresh()

Return lAux

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ ImpArq   ³ Autor ³ Hirae               ³ Data ³ 15.04.2019 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Inicializa a importacao do arquivo.                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ aPar01 - Variavel com as opcoes do combo cliente/fornec.   ³±±
	±±³          ³ cPar01 - Variavel com a opcao escolhida do combo.          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ Nulo                                                       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Fiscal - Buenos Aires Argentina                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpArq(aCombo,cCombo)

	Local   nPos     := 0
	Private cFile    := ""
	Private dDataIni := ""
	Private dDataFim := ""
	Private lFor     := .F.
	Private lCli     := .F.
	Private lImp     := .F.

	nPos := aScan(aCombo,{|x| AllTrim(x) == AllTrim(cCombo)})
	If nPos == 1 // Fornecedor
		lFor := .T.
	ElseIf nPos == 2 // Cliente
		lCli := .T.
	ElseIf nPos == 3 // Ambos
		lFor := .T.
		lCli := .T.
	EndIf

	cFile := FGetFile()
	If Empty(cFile)
		MsgStop(STR0031) //"Seleccione un archivo e intente nuevamente."
		Return Nil
	EndIf

	If !File(cFile)
		MsgStop(STR0031) //"Seleccione un archivo e intente nuevamente."
		Return Nil
	EndIf
	If VldArch()
		MsAguarde({|| Import(cFile)} ,STR0019,STR0020 ,.T.) //"Lendo Arquivo, Aguarde..."###"Atualizacao de aliquotas"
	EndIf

	If (lImp )
		MsgAlert(STR0025,"") //"Arquivo importado!"
	EndIf
Return Nil

Static Function VldArch()

	Local cErro		:= STR0029
	Local cSolucao 	:= STR0031
	Local cTitulo	:= STR0001

	FT_FUSE(cFile)
	If !(_SEPARADOR $ (FT_FREADLN()))
		xMagHelpFis(cTitulo,cErro,cSolucao)
		Return Nil
	EndIf
	dDataIni := CTOD("01/"+cMesIni+"/"+cAnoIni)
	dDataFim := LastDay(dDataIni)
	FT_FUSE()

Return .T.
/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ FGetFile ³ Autor ³ Ivan Haponczuk      ³ Data ³ 09.06.2011 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Tela de seleção do arquivo txt a ser importado.            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ cRet - Diretori e arquivo selecionado.                     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGetFile()

	Local cRet := Space(50)

	oDlg01 := MSDialog():New(000,000,100,500,STR0027,,,,,,,,,.T.)//"Selecionar arquivo"

	oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,,,,,,,.T.,,,,,,,,,,"cRet")
	oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDir(oGet01)},oDlg01,STR0027,,.T.)//"Selecionar arquivo"

	oBtn02 := SButton():New(035,185,1,{|| oDlg01:End() }         ,oDlg01,.T.,,)
	oBtn03 := SButton():New(035,215,2,{|| cRet:="",oDlg01:End() },oDlg01,.T.,,)

	oDlg01:Activate(,,,.T.,,,)

Return cRet

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao    ³ FGetDir  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 09.06.2011 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Tela para procurar e selecionar o arquivo nos diretorios   ³±±
	±±³          ³ locais/servidor/unidades mapeadas.                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ oPar1 - Objeto TGet que ira receber o local e o arquivo    ³±±
	±±³          ³         selecionado.                                       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³ Nulo                                                       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ Fiscal - Buenos Aires Argentina - MSSQL                    ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGetDir(oTGet)

	Local cDir := ""
	cDir := cGetFile(,STR0027,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar arquivo"
	If !Empty(cDir)
		oTGet:cText := cDir
		oTGet:Refresh()
	Endif
	oTGet:SetFocus()

Return Nil

Static Function Import(cFile)

	Local lReturn   	:= .T.

	Private cTipo 		:= ""
	Private lFecMen     := .F.
	Private lExtVige    := .F.
	Private lGenera     := .F.
	Private cTable  	:= ""
	Private cAliasPdr := "PADRSC"

	Processa({|| lReturn := GeraTemp(cFile)})// cualquier base de datos

	If !lReturn
		Return Nil
	EndIf

Return Nil

Static Function ProvCal(lPadron,aTipo)
	Local lSfh	:= .F.
	If lFor .and. (lRet .or. lPer)
		If lPer
			cSA2->(dbGoTop())
			If lCGC
				Do While cSA2->(!EOF())
					dbSelectArea("SFH")
					SFH->(dbSetOrder(1))
					SFH->(dbGoTop())

					cChave := xFilial("SFH")+cSA2->A2_COD+cSA2->A2_LOJA+"IBI"+"SA"
					If SFH->(MsSeek(cChave))
						nRecFim := MayorFech(cSA2->A2_COD,cSA2->A2_LOJA,"IBI",.F.)
						SFH->(DbGoTo(nRecFim))
						If nRecfim >0
							lSfh := .T.
							If lSfh
								If dDataIni <= SFH->FH_FIMVIGE
									lFecMen  := .T.
								ElseIf ((dDataIni == (SFH->FH_FIMVIGE + 1)) .AND. (SFH->FH_TIPO == aTipo[1]) .AND. (SFH->FH_PERCENT == aTipo[2]))
									lExtVige := .T.
								Else
									lGenera  := .T.
								EndIf
							EndIf
						EndIf
					EndIf
					If lSfh
						If !lFecMen
							If lExtVige
								RecLock("SFH", .F.)
								SFH->FH_FIMVIGE := dDataFim
								SFH->(MsUnlock())
							ElseIf lGenera
								ActSFH(SFH->FH_AGENTE,SFH->FH_FORNECE,aTipo[1],cSA2->A2_LOJA,SFH->FH_PERCIBI,SFH->FH_APERIB,SFH->FH_ZONFIS,SFH->FH_IMPOSTO,SFH->FH_ALIQ,dDataIni,dDataFim,aTipo[2],"A2",cSA2->A2_NOME)
							EndIf
						EndIf
					EndIf
					lFecMen     := .F.
					lExtVige    := .F.
					lGenera     := .F.
					lSfh 		:= .F.
					cSA2->(dbSkip())
				EndDo
			Else // no padron
				Do While cSA2->(!EOF())
					dbSelectArea("SFH")
					SFH->(dbSetOrder(1))
					SFH->(dbGoTop())
					lSfh := .F.
					cChave := xFilial("SFH")+cSA2->A2_COD+cSA2->A2_LOJA+"IBI"+"SA"
					If SFH->(MsSeek(cChave))
						nRecFim := MayorFech(cSA2->A2_COD,cSA2->A2_LOJA,"IBI",.F.)
						SFH->(DbGoTo(nRecFim))
						If nRecfim >0
							lSfh:= .T.
							If lSfh
								If dDataIni <= SFH->FH_FIMVIGE
									lFecMen  := .T.
								ElseIf (dDataIni > SFH->FH_FIMVIGE) .And. (SFH->FH_INIVIGE<>dDataIni)
									lGenera := .T.
								EndIf
							EndIf
						EndIf
					EndIf
					If lSfh
						If !lFecMen
							If lGenera
								ActSFH(SFH->FH_AGENTE,SFH->FH_FORNECE,SFH->FH_TIPO,SFH->FH_LOJA,SFH->FH_PERCIBI,SFH->FH_APERIB,SFH->FH_ZONFIS,SFH->FH_IMPOSTO,SFH->FH_ALIQ,dDataIni,CTOD("//"),0,"A2",cSA2->A2_NOME)
							EndIf
						EndIf
					EndIf
					lFecMen     := .F.
					lExtVige    := .F.
					lGenera     := .F.
					lSfh 		:= .F.
					cSA2->(dbSkip())
				EndDo
			EndIf // fin cuit empresa
		EndIf// fin per prove

		If lRet
			If lPadron
				dbSelectArea("SFH")
				SFH->(dbSetOrder(1))
				SFH->(dbGoTop())

				cChave := xFilial("SFH")+cSA2->A2_COD+cSA2->A2_LOJA+"IBR"+"SA"
				If SFH->(MsSeek(cChave))
					nRecFim := MayorFech(cSA2->A2_COD,cSA2->A2_LOJA,"IBR",.F.)
					If nRecFim >0
						lSfh := .T.
						SFH->(DbGoTo(nRecFim))
						If lSfh
							If dDataIni <= SFH->FH_FIMVIGE
								lFecMen  := .T.
							ElseIf (dDataIni == (SFH->FH_FIMVIGE + 1)) .AND. (SFH->FH_TIPO == aTipo[1]) .AND. (SFH->FH_PERCENT == aTipo[2])
								lExtVige := .T.
							Else
								lGenera  := .T.
							EndIf
						Else
							lGenera := .T.
						EndIf
					EndIf
				EndIf// fin sfh busq

				If lSfh
					If !lFecMen
						If lExtVige
							RecLock("SFH", .F.)
							SFH->FH_FIMVIGE := dDataFim
							SFH->(MsUnlock())
						ElseIf lGenera
							ActSFH(SFH->FH_AGENTE,SFH->FH_FORNECE,aTipo[1],SFH->FH_LOJA,SFH->FH_PERCIBI,SFH->FH_APERIB,SFH->FH_ZONFIS,SFH->FH_IMPOSTO,SFH->FH_ALIQ,dDataIni,dDataFim,aTipo[2],"A2",cSA2->A2_NOME)
						EndIf
					EndIf
				Else // no SFH
					ActSFH("N",cSA2->A2_COD,"I",cSA2->A2_LOJA,"N","N","SA","IBR",0,dDataIni,dDataFim,aTipo[2],"A2",cSA2->A2_NOME)
				EndIf
				SFH->(dbCloseArea())

			Else//  no padron
				dbSelectArea("SFH")
				SFH->(dbSetOrder(1))
				SFH->(dbGoTop())

				cChave := xFilial("SFH")+cSA2->A2_COD+cSA2->A2_LOJA+"IBR"+"SA"
				If SFH->(MsSeek(cChave))
					nRecFim := MayorFech(cSA2->A2_COD,cSA2->A2_LOJA,"IBR",.F.)
					If nRecFim >0
						lSfh := .T.
						SFH->(DbGoTo(nRecFim))
						If lSfh
							If dDataIni <= SFH->FH_FIMVIGE
								lFecMen  := .T.
							ElseIf (dDataIni > SFH->FH_FIMVIGE ) .And. (SFH->FH_INIVIGE<>dDataIni)
								lGenera := .T.
							EndIf
						EndIf
					EndIf
				EndIf
				If lSfh
					If !lFecMen
						If lGenera
							ActSFH(SFH->FH_AGENTE,SFH->FH_FORNECE,SFH->FH_TIPO,SFH->FH_LOJA,SFH->FH_PERCIBI,SFH->FH_APERIB,SFH->FH_ZONFIS,SFH->FH_IMPOSTO,SFH->FH_ALIQ,dDataIni,CTOD("//"),0,"A2",cSA2->A2_NOME)
						EndIf
					EndIf
				EndIf
			EndIf// fin padron
		EndIf// fin ret prove

		lFecMen     := .F.
		lExtVige    := .F.
		lGenera     := .F.
		lSfh 		:= .F.
		lImp := .T.
	EndIf // fin prove

Return Nil

Static Function CliPer(lPadron,aTipo)
	Local lSfh := .F.
	If lCli .and. lPer

		If lPadron
			dbSelectArea("SFH")
			SFH->(dbSetOrder(3))
			SFH->(dbGoTop())

			cChave := xFilial("SFH")+cSA1->A1_COD+cSA1->A1_LOJA+"IBI"+"SA"
			If SFH->(MsSeek(cChave))
				nRecFim :=  MayorFech(cSA1->A1_COD,cSA1->A1_LOJA,"IBI",.T.)
				If nRecFim >0
					lSfh := .T.
					SFH->(DbGoTo(nRecFim))
					If dDataIni <= SFH->FH_FIMVIGE
						lFecMen  := .T.
					ElseIf ((dDataIni == (SFH->FH_FIMVIGE + 1)) .AND. (SFH->FH_TIPO == aTipo[1] .AND. SFH->FH_PERCENT=aTipo[2] ))
						lExtVige := .T.
					Else
						lGenera  := .T.
					EndIf
				EndIf
			EndIf
			If lSfh
				If !lFecMen
					If lExtVige
						RecLock("SFH", .F.)
						SFH->FH_FIMVIGE := dDataFim
						SFH->(MsUnlock())
					ElseIf lGenera
						ActSFH(SFH->FH_AGENTE,SFH->FH_CLIENTE,aTipo[1],cSA1->A1_LOJA,SFH->FH_PERCIBI,SFH->FH_APERIB,SFH->FH_ZONFIS,SFH->FH_IMPOSTO,SFH->FH_ALIQ,dDataIni,dDataFim,aTipo[2],"A1",cSA1->A1_NOME)
					EndIf
				EndIf
			Else// no esta en SFH
				ActSFH("N",cSA1->A1_COD,aTipo[1],cSA1->A1_LOJA,"S","S","SA","IBI",0,dDataIni,dDataFim,aTipo[2],"A1",cSA1->A1_NOME)
			EndIf
			SFH->(dbCloseArea())
		Else //no Padron
			dbSelectArea("SFH")
			SFH->(dbSetOrder(3))
			SFH->(dbGoTop())

			cChave := xFilial("SFH")+cSA1->A1_COD+cSA1->A1_LOJA+"IBI"+"SA"
			If SFH->(MsSeek(cChave))
				nRecFim := MayorFech(cSA1->A1_COD,cSA1->A1_LOJA,"IBI",.T.)
				If nRecFim >0
					lSfh := .T.
					SFH->(DbGoTo(nRecFim))
					If dDataIni <= SFH->FH_FIMVIGE
						lFecMen  := .T.
					ElseIf (dDataIni > SFH->FH_FIMVIGE ).And. (SFH->FH_INIVIGE<>dDataIni)
						lExtVige := .T.
					EndIf
				EndIf
			EndIf

			If lSfh
				If !lFecMen
					If lExtVige
						ActSFH(SFH->FH_AGENTE,SFH->FH_CLIENTE,SFH->FH_TIPO,cSA1->A1_LOJA,SFH->FH_PERCIBI,SFH->FH_APERIB,SFH->FH_ZONFIS,SFH->FH_IMPOSTO,SFH->FH_ALIQ,dDataIni,CTOD("//"),0,"A1",cSA1->A1_NOME)
					EndIf
				EndIf
			EndIf
		EndIf // fin Padron

		lFecMen     := .F.
		lExtVige    := .F.
		lGenera     := .F.
		lImp := .T.
	EndIf // fin cli & per


Return Nil

Static Function ActSFH(cAgente,cCOD,cTipo,cLoja,cPercIBI,cAPERIB,cZonaFis,cImpost,nAliq,dDataIni,dDataFim,nPercent,cTable,cNome)
	Default cLoja	:= ""
	Private lLojaSFH:= .T.
	Private lCodSFH := .T.
	Private cPrefixo := "->"+cTable+"_"
	cTable :="S"+cTable

	If Empty(cLoja)
		lLojaSFH := .F.
	EndIf
	If Empty(cCOD)
		lCodSFH := .F.
	EndIf

	If RecLock("SFH", .T.)
		SFH->FH_FILIAL	:=  xFilial("SFH")
		SFH->FH_AGENTE	:= cAgente
		SFH->FH_ZONFIS	:= cZonaFis
		If cTable == "SA2"
			SFH->FH_FORNECE := IIf(lCodSFH, cCOD , &(cTable+cPrefixo+"COD"))
		Else
			SFH->FH_CLIENTE	:= IIf(lCodSFH, cCOD , &(cTable+cPrefixo+"COD"))
		EndIf
		SFH->FH_LOJA	:= IIf(lLojaSFH, cLoja, &(cTable+cPrefixo+"LOJA"))
		SFH->FH_NOME	:= cNome
		SFH->FH_IMPOSTO	:= cImpost
		SFH->FH_PERCIBI	:= cPercIBI
		SFH->FH_ISENTO	:= "N"
		SFH->FH_APERIB	:= cAPERIB
		SFH->FH_ALIQ	:= nAliq
		SFH->FH_PERCENT	:= nPercent
		SFH->FH_TIPO    := cTipo
		SFH->FH_INIVIGE := dDataIni
		SFH->FH_FIMVIGE := dDataFim
		SFH->(MsUnlock())
	EndIf

Return Nil

Static Function Tipo(cTipo)
	Local aAux :={}
	Local cPercen :=""
	cTipo := AllTrim(cTipo)
	If	cTipo $ "JU|EX"
		cTipo	:= "I"
	ElseIf	cTipo == "CM"
		cTipo	:= "V"
	Else
		cTipo	:= "N"
	EndIf
	aadd(aAux,cTipo)
	aadd(aAux,iif(cPercen=="EX",100,0))
Return aAux

Static Function MayorFech(cCod,cLoja,cImpuesto,lTabla)

	Private dFecAnt := ""
	Private nAux :=0
	Private cTabla :=""
	Private nAuxIni :=0

	Iif(lTabla,cTabla:="FH_CLIENTE",cTabla:="FH_FORNECE")
	cQuery	:= ""
	cQuery := "SELECT  FH_FIMVIGE AS FECHA,R_E_C_N_O_ AS NUM,FH_INIVIGE AS INI"
	cQuery += " FROM " + RetSqlName("SFH")
	cQuery += " WHERE FH_FILIAL = '" + xFilial("SFH") + "'"
	cQuery += " AND "+cTabla+" = '"+cCod+"'"
	cQuery += " AND FH_LOJA ='"+cLoja+"'"
	cQuery += " AND FH_IMPOSTO ='"+cImpuesto+"'"
	cQuery += " AND FH_ZONFIS ='SA'"
	cQuery += " AND D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), "cTMayor", .T., .T.)

	cTMayor->(dbGoTop())
	Do While cTMayor->(!EOF())
		If cTMayor->FECHA > dFecAnt
			nAux := cTMayor->NUM
			dFecAnt := cTMayor->FECHA
		EndIf

		If(DTOS(dDataIni) == cTMayor->INI)
			nAuxIni :=cTMayor->NUM
		EndIf
		cTMayor->(dbSkip())
	EndDo
	If(nAuxIni<>0)
		nAux :=nAuxIni
	EndIf
	cTMayor->(dbCloseArea())
Return nAux

Static Function GeraTemp(cFile)
	Local cArqProc   := cFile	// Arquivo a ser importado selecionado na tela de Wizard
	Local cErro	     := ""		// Texto de mensagem de erro ocorrido na validacao do arquivo a ser importado
	Local cSolucao   := ""		// Texto de solucao proposta em relacao a algum erro ocorrido na validacao do arquivo a ser importado
	Local lArqValido := .T.		// Determina se o arquivo XLS esta ok para importacao
	Local cTitulo	 := STR0001  //"Problemas en la importación del archivo"
	Local cQuery	:= ""
	Local cCGCEmp	:= AllTrim(SM0->M0_CGC)
	Local nRegs			:= 0
	Local nTotal		:= 0
	Local lReturn    := .T.
	Local nLineasA1  :=0
	Local nLineasA2  :=0

	If lCli .and. lPer
		cQuery	:= ""
		cQuery := "SELECT A1_COD, A1_LOJA, A1_CGC, A1_NOME"
		cQuery += " FROM " + RetSqlName("SA1")
		cQuery += " WHERE A1_FILIAL = '" + xFilial("SA1") + "'"
		cQuery += " AND A1_CGC <> ''"
		cQuery += " AND D_E_L_E_T_ <> '*'"
		cQuery += " ORDER BY A1_CGC ASC"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), "cSA1", .T., .T.)
		cSA1->(dbGoTop())
		count to nRegs
		cSA1->(dbGoTop())
		nLineasA1 := nRegs
		nTotal += nRegs
	EndIf

	If lFor .and. (lRet .or. lPer)
		cQuery	:= ""
		cQuery := "SELECT A2_COD, A2_LOJA, A2_CGC,A2_NOME"
		cQuery += " FROM " + RetSqlName("SA2")
		cQuery += " WHERE A2_FILIAL = '" + xFilial("SA2") + "'"
		cQuery += " AND A2_CGC <> ''"
		cQuery += " AND D_E_L_E_T_ <> '*'"
		cQuery += " ORDER BY A2_CGC ASC"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), "cSA2", .T., .T.)
		cSA2->(dbGoTop())
		count to nRegs
		nLineasA2 := nRegs
		cSA2->(dbGoTop())
		nTotal += nRegs
	EndIf
	If File(cArqProc)
		lArqValido := CreaTabla(cArqProc)
		If lArqValido
			If lFor .and. lPer
				If (cAliasPdr)->(MsSeek(cCGCEmp))
					lCGC := .T.
					ProvCal(lCGC,Tipo((cAliasPdr)->ACTIECO))
				Else
					lCGC := .F.
					ProvCal(lCGC,"")
				EndIf
			EndIf
			If lCli .and. lPer
				While cSA1->(!EOF())
					If (cAliasPdr)->(MsSeek(cSA1->A1_CGC))
						CliPer(.T.,Tipo((cAliasPdr)->ACTIECO))
					Else
						CliPer(.F.,{"",0})
					EndIf
					cSA1->(dbSkip())
				Enddo
			EndIf
			If lFor .and. lRet
				While cSA2->(!EOF())
					If (cAliasPdr)->(MsSeek(cSA2->A2_CGC))
						ProvCal(.T.,Tipo((cAliasPdr)->ACTIECO))
					Else
						ProvCal(.F.,{"",0})
					EndIf
					cSA2->(dbSkip())
				Enddo
			EndIf
			(cAliasPdr)->(dbCloseArea())
		Else
			cErro	   := STR0023 + cArqProc + STR0024	//"El archivo " +cArqProc+ "No puede abrirse"
			cSolucao   := STR0029 						//"Verifique se foi informado o arquivo correto para importação"
		EndIf
		If lCli .and. lPer
			cSA1->(dbCloseArea())
		EndIf
		If lFor .and. (lRet .or. lPer)
			cSA2->(dbCloseArea())
		EndIf
		If !Empty(cErro)
			xMagHelpFis(cTitulo,cErro,cSolucao)
			lReturn := .F.
		Endif
	EndIf
Return(lReturn)

Static Function CreaTabla(cArqProc)
	Local aInforma	:= {} 		// Array auxiliar com as informacoes da linha lida no arquivo XLS
	Local cMsg		:= STR0019 //"Leyendo archivo. Espere..."
	Local cVersion	:= FwLibVersion()
	Local cBuild	:= TCGetBuild()
	Local nHandle	:= 0		// Numero de referencia atribuido na abertura do arquivo XLS
	Local aStruct 	:= {}
	Local nTotLin 	:= 0
	Local nI 		:= 0
	Local lRetu		:= .T.
	Local oFile

	aAdd( aStruct, { 'CUIT',  'C', 130,0 } )
	aAdd( aStruct, { 'DENOM', 'C', 250,0 } )
	aAdd( aStruct, { 'ACTIECO','C', 250, 0 } )
	aAdd( aStruct, { 'ACTIEXEN','C', 250, 0 } )
	aAdd( aStruct, { 'CERTNO', 'C', 250, 0 } )
	nHandle := FT_FUse(cArqProc)
	If nHandle == -1
		lRetu := .F.
	Else
		nTotLin := FT_FLASTREC()
		FT_FUSE()
		If Select(cAliasPdr) <> 0
			(cAliasPdr)->(dbCloseArea())
		EndIf
		If TCCanOpen(cAliasPdr)
			If TcSqlExec("DROP TABLE " + cAliasPdr) <> 0
				If !TCDelFile(cAliasPdr)
					MsgAlert("Failed to delete table PADRSC")
					lRetu := .F.
				EndIf
			EndIf
		EndIf
		If cBuild  >= "20181212" .and. cVersion >= "20201009"
			FWDBCreate(cAliasPdr, aStruct , 'TOPCONN' , .T.)
			oFile := ZFWReadTXT():New(cArqProc,,_BUFFER)
			If !oFile:Open()
				MsgAlert(STR0023 + cArqProc + STR0024)  //"El archivo " +cArqProc+ "No puede abrirse"
				Return .F.
			EndIf
			oBulk := FwBulk():New(cAliasPdr,600)
			lCanUseBulk := FwBulk():CanBulk() // Este método não depende da classe FWBulk ser inicializada por NEW
			If lCanUseBulk
				oBulk:SetFields(aStruct)
				ProcRegua(nTotLin)
				While oFile:ReadArray(@aInforma,_SEPARADOR)
					If Len(aInforma) == 5
						oBulk:AddData(aInforma)
					ElseIf Len(aInforma) == 4
						oBulk:AddData({aInforma[1],aInforma[2],aInforma[3],aInforma[4],""})
					ElseIf Len(aInforma) == 3
						oBulk:AddData({aInforma[1],aInforma[2],aInforma[3],"",""})
					EndIf
					aSize(aInforma,0)
					nI++
					IncProc(cMsg + str(nI))
				EndDo
				oBulk:Close()
				oBulk:Destroy()
				oBulk := nil
			EndIf
			oFile:Close()	 // Fecha o Arquivo
			If Select(cAliasPdr) == 0
				DbUseArea(.T.,"TOPCONN",cAliasPdr,cAliasPdr,.T.)
				cIndex := cAliasPdr+"1"
				If ( !MsFile(cAliasPdr,cIndex, "TOPCONN") )
					DbCreateInd(cIndex,"CUIT",{|| "CUIT" })
				EndIf
				Set Index to (cIndex)
			EndIf
		Else
			MsCreate(cAliasPdr,aStruct,"TOPCONN")
			DbUseArea(.T.,"TOPCONN",cAliasPdr,cAliasPdr,.T.)
			cIndex := cAliasPdr+"1"
			If ( !MsFile(cAliasPdr,cIndex, "TOPCONN") )
				DbCreateInd(cIndex,"CUIT",{|| "CUIT" })
			EndIf
			Set Index to (cIndex)
			oFile := ZFWReadTXT():New(cArqProc,,_BUFFER)
			If !oFile:Open()
				MsgAlert(STR0023 + cArqProc + STR0024)  //"El archivo " +cArqProc+ "No puede abrirse"
				Return .F.
			EndIf
			ProcRegua(nTotLin)
			dbSelectArea(cAliasPdr)
			While oFile:ReadArray(@aInforma,_SEPARADOR)
				nI ++
				IncProc(cMsg + str(nI))
				If Len(aInforma) == 4
					Aadd(aInforma, "")
				ElseIf Len(aInforma) == 3
					Aadd(aInforma, "")
					Aadd(aInforma, "")
				EndIf
				If Len(aInforma) > 4
					RecLock(cAliasPdr,.T.)
					(cAliasPdr)->CUIT		:= aInforma[1]
					(cAliasPdr)->DENOM	:= aInforma[2]
					(cAliasPdr)->ACTIECO	:= aInforma[3]
					(cAliasPdr)->ACTIEXEN	:= aInforma[4]
					(cAliasPdr)->CERTNO	:= aInforma[5]
					(cAliasPdr)->(MsUnLock())
				EndIf
			End
		EndIf
	EndIf
Return lRetu
