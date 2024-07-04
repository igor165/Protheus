#INCLUDE "PROTHEUS.CH"
#INCLUDE "CTBA950.CH"
#INCLUDE "SHELL.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBA950   ³ Autor ³ José Lucas           ³ Data ³21.03.2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Instrucao Normativa com limite de registros por arquivo.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA950()
Local aArea		:=  GetArea()
Local cTitulo	:=	STR0001 //"Instrucoes Normativas"
Local cMsg1		:=	STR0002 //"Este programa gera arquivo pr‚-forCTBAdo dos lan‡amentos fiscais"
Local cMsg2		:=	STR0003 //"para entrega as Secretarias da Receita Federal, atendendo ao lay-out"
Local cMsg3		:=	STR0004 //"das Instrucoes Normativas. Dever  ser executado em modo mono-usu rio."
Local cMsg4		:=  STR0019 //"La selección de Sucursales no está habilitado para este tipo de Informes, ¿desea generar el documentos para la actual sucursal?"
Local cMsg5		:=  STR0020 //"Sucursal"
Local nOpcA		:= 0
Local nTotReg   := 0
Local cPerg		:= "CTB950"
Local cNorma	:= ""
Local cDest		:= ""
Local cDir      := ""
Local cVar      := ""
Local aFilsCalc	:= {}
Local cFilBack  := cFilAnt
Local nForFilial:= 0
Local cMsg      := ""
Local cNewFile  := ""
Local cDrive    := ""
Local cExt      := ""
Local cDirRec	:= ""
Local nProcFil	:= 0
Local aProcFil	:= {.F.,cFilAnt}
Local nX		:= 0
Local aTrab		:= {}
Local aNorma    := {}
Local nCount    := 0
Local lFuncFRen	:=	.T.	//Funcao disponivel no binario do ftp. (24/08/2004)
Local cArqAux   := ""

Private dDmainc
Private dDmaFin
Private nMoedTit := 1
Private cNrLivro
Private nMes
Private nAno
Private aReturn  := {}
Private lFirst   := .T.
Private cArqDest := ""
Private aNomArq  := {}
Private cNomArq  // := StrZero(GetMV("MV_FMTCONS")+1,8)

PUBLIC __oTmpFMT

	// Lucas modificou em 21/05/2010.
	If cPaisLoc == "COL"
	 cNomArq  := StrZero(GetMV("MV_FMTCONS")+1,8)
	Else
	 cNomArq  := mv_par04
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da Interface com o usuario                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)

	FormBatch(cTitulo,{OemToAnsi(cMsg1),OemToAnsi(cMsg2),OemToAnsi(cMsg3)},;
		{ { 5,.T.,{|o| Pergunte(cPerg,.T.) }},;
		{ 1,.T.,{|o| nOpcA := 1,o:oWnd:End()}},;
		{ 2,.T.,{|o| nOpcA := 2,o:oWnd:End()}}})

	If ( nOpcA==1 )
		cNorma   := AllTrim(MV_PAR03)+ ".INI"
		cDest    := AllTrim(MV_PAR04)
		cDir     := AllTrim(MV_PAR05)
		dDmainc  := MV_PAR01
		dDmaFin  := MV_PAR02
		dDataIni := MV_PAR01
		dDataFim := MV_PAR02
		nProcFil := MV_PAR06
		cArqAux  := AllTrim(MV_PAR03)
		
		// Rutina de Medios Magneticos solo usa la Filial Actual
		// Se solicita al desea usar la sucursal actual, de lo contario se finaliza el proceso.
		If cPaisLoc == "COL" .and. upper(substr(AllTrim(MV_PAR03),1,3))=='FMT' .and. nProcFil==1
			If MsgYesNo(cMsg4,cMsg5)
				aFilsCalc	:= MatFilCalc( .F. )
				nProcFil	:= 2
			Else
				Return
			EndIf
		Else
			aFilsCalc := MatFilCalc( MV_PAR06 == 1 )
		EndIf

		If Empty( aFilsCalc )
			Return
		EndIf

		For nForFilial := 1 To Len( aFilsCalc )
			If aFilsCalc[ nForFilial, 1 ]
				cFilAnt := aFilsCalc[ nForFilial, 2 ]
				MV_PAR01 := dDataIni
				MV_PAR02 := dDataFim

				cNewFile := cDir + cDest

				SplitPath(cNewFile,@cDrive,@cDir,@cDest,@cExt)

				cDir := cDrive + cDir
				cDest+= cExt

				If nProcFil == 1
					cDirRec := cDir + cFilAnt + "\"
					aProcFil := {.T.,cFilAnt}
				Else
					cDirRec := cDir
					aProcFil := {.F.,cFilAnt}
				EndIf

				Makedir(cDirRec)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Reabre os Arquivos do Modulo desprezando os abertos pela Normativa      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SX3")
				dbSetOrder(1)
				Processa({||ProcNorma(cNorma,cDest,cDirRec,aProcFil,@aTrab)})

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Renomeia o arquivo destino desprezando a diretiva do arquivo .INI       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (lFuncFRen)
					If cPaisLoc == "COL"
						FRenameEx (cDirRec+cDest, cDirRec+Upper(Subs(cArqDest,1,1))+Subs(cArqDest,2,Len(cArqDest)))
					ElseIf cPaisLoc == "VEN"
						FRenameEx (cDirRec+cDest, cDirRec+Upper(cArqDest)+".xml")
					Else
						FRenameEx (cDirRec+cDest, cDirRec+Upper(cArqDest))
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Reabre os Arquivos do Modulo desprezando os abertos pela Normativa      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nCount := 2 To Len(aNomArq)
					lFirst    := .F.
					lAbtMT950 := .F.
					cNomArq := aNomArq[nCount]
					dbSelectArea("SX3")
					dbSetOrder(1)
					Processa({||ProcNorma(cNorma,cDest,cDirRec,aProcFil,@aTrab)})

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Reabre os Arquivos do Modulo desprezando os abertos pela Normativa      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (lFuncFRen)
						If cPaisLoc == "COL"
							FRenameEx (cDirRec+cDest, cDirRec+Upper(Subs(cArqDest,1,1))+Subs(cArqDest,2,20)+cNomArq+".xml")
						ElseIf cPaisLoc == "VEN"
							FRenameEx (cDirRec+cDest, cDirRec+Upper(cArqDest)+".xml")
						Else
							FRenameEx (cDirRec+cDest, cDirRec+Upper(cArqDest))
						EndIf
					EndIf
				Next nCount

				If Select(cArqAux) > 0
					(cArqAux)->(dbClearFilter())
					(cArqAux)->(dbCloseArea())
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Reabre os Arquivos do Modulo desprezando os abertos pela Normativa      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbCloseAll()
				OpenFile(SubStr(cNumEmp,1,2))

			EndIf

		Next nForFilial

		//Atualiza o conteudo do parametro que controla a numeração de arquivos para a Colombia - FMTs
		If cPaisLoc == "COL" .And. "FMT" $ cNorma
			EncInfFMT("","MV_FMTCONS",cNomArq)
		EndIf

	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ferase no array aTrab                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aTrab)
		Ferase(AllTrim(aTrab[nX][1]))
	Next

dbSelectArea("CT2")
dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura area                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilAnt := cFilBack
RestArea(aArea)
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Monta2XML 	³ Autor ³ José Lucas        ³ Data ³20/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao para retornar a linha em formato XML (tags)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1 : linha em xml                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Tag a ser apresentada   				    	      ³±±
±±³          ³ExpC2 : Campo a ser apresentado na Tag (conteudo)           ³±±
±±³          ³ExpC3 : Tipo do campo                                       ³±±
±±³          ³ExpN4 : Tamanho do campo                                    ³±±
±±³          ³ExpN5 : Decimais do campo                                   ³±±
±±³          ³ExpC6 : Mascara do campo                                    ³±±
±±³          ³ExpN7 : Deslocamento inicial da tag (identacao)             ³±±
±±³          ³ExpL8 : Se apresenta a Tag inicial <>                       ³±±
±±³          ³ExpL9 : Se apresenta a Tag final </>                        ³±±
±±³          ³ExpLA : Se inclui a quebra de linha chr(13) + chr(10)       ³±±
±±³          ³ExpLB : Atributo de TAG                                     ³±±
±±³          ³ExpLC : Se apresenta Tag caracter com acentos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Monta2XML(cTag,cCampo,cTipo,nTam,nDec,cMask,nDesloc,lTagIn,lTagInLeft,lTagInRight,lTagFim,lTagFimLeft,lTagFimRight,lQuebra,cAtrib,lAcento)

Local cXML 		:= ""
Local cAuxCampo := ""
Local cAuxTam	:= ""
Local cAuxDec	:= ""
Local cDesloc	:= ""
Local cTagIni	:= ""
Local cTagFim	:= ""

Default cTipo	:= "C"
Default nTam	:= 0
Default	nDec	:= 0
Default	cMask	:= ""
Default nDesloc	:= 0
Default	lTagIn	:= .T.
Default	lTagFim	:= .T.
Default	lQuebra	:= .T.
Default cCampo	:= ""
Default	cAtrib	:= ""
Default lAcento	:=	.F.

cAuxTam	:= Replicate("9",nTam)
cAuxDec	:= Replicate("9",nDec)
cDesloc	:= Space(nDesloc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta as tags³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTagIn
	If lTagInLeft
		cTagIni	:= "<"
	EndIf
	cTagIni	+= Alltrim(cTag)
	If !Empty(cAtrib)
		cTagIni	+= " " + Alltrim(cAtrib)
	EndIf
	If lTagInRight
		cTagIni	+= ">"
	EndIf
Endif
If lTagFim
	If lTagFimLeft
		cTagFim	:= "</" + Alltrim(cTag)
	EndIf
	If !Empty(cTagFim)
		cTagFim	+= " " + Alltrim(cTag)
	EndIf
	If lTagFimRight
		cTagFim += " />"
	EndIf
Endif

cAuxCampo := Alltrim(cCampo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Remove os acentos das strings³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == "C" .And. !lAcento
	cAuxCampo := Alltrim(Upper(NoAcento(AnsiToOem(AllTrim(cAuxCampo)))))
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a mascara passada como parametro ou mascara padrao    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cMask)
	cAuxCampo := Transform(cCampo,cMask)
Else
	If cTipo == "N"
		cAuxCampo := Transform(cCampo,"@E"+cAuxTam+"."+cAuxDec)
	Endif
	If cTipo == "D"
		cAuxCampo := dToS(cCampo)
	Endif
Endif

If Upper(cCampo) == "SPACE"
	cAuxCampo := ""
ElseIf ! Empty(cCampo)
	cAuxCampo := '"'+AllTrim(cAuxCampo)+'"'
Else
	cAuxCampo := '""'
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a linha XML: deslocamento inicial da linha + Tag Inicial + campo a ser apresentado + Tag Final³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cXML := cDesloc + cTagIni + cAuxCampo + cTagFim

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Insere o <enter> para quebrar linha³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuebra
	cXML  	:= cXML + Chr(13) + Chr(10)
Endif
//cXMLStatic	+=	cAuxCampo
Return cXML
