#INCLUDE "VDFR450.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VDFR450  ³ Autor ³ Wagner Mobile Costa   ³ Data ³  26.06.14      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatório da Lotacionograma Word                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VDFR450(void)                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                         ³±±
±±³Silvia Tag  ³18/07/2018³DRHGFP-1034³Upgrade V12-Retirada Ajusta              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³          ³      ³                                              ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function VDFR450()

Local aRegs			:= {}
Local cDir			:= SUBSTR(GetTempPath(),1,3)
Local aSay			:= {}
Local aButton		:= {}
Local nOpc			:= 0
Local cTitulo		:= STR0001
Local aArea			:= GetArea()
Local aAreaSM0		:= SM0->(GetArea())	// 'Lotacionograma Word'
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aMsg			:= aOfusca[3]
Local aFldRel		:= {"RA_NOME", "RA_RACACOR"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )

Private cPerg	:= "VDFR450"

if !lBlqAcesso
	If 	!File(cDir+'LibreOffice\program\swriter.exe')
		MsgInfo(STR0002)	// 'LibreOffice não esta gravado na pasta \LibreOffice\program\.'
		Return()
	Endif

		If ! File("\inicializadores\vdfr450_cab.ini")
			CabWrite()
		EndIf

		If ! File("\inicializadores\vdfr450_rod.ini")
			RodWrite()
		EndIf

		cSXB_SRACAT   := "SRA->RA_FILIAL == mv_par06"

		PtSetAcento(.T.)
		Pergunte(cPerg, .F.)


		Aadd(aSay, STR0003)	// 'Esta opção tem como objetivo a montagem e apresentação de documento no aplicativo'
		Aadd(aSay, STR0004)	// 'Libre Office.'

		Aadd(aButton, { 11, .T., { || CfgHTML() } } )
		Aadd(aButton, { 5, .T., { || Pergunte(cPerg, .T.) } } )
		Aadd(aButton, { 1, .T., { || nOpc := 1, FechaBatch() } })
		Aadd(aButton, { 2, .T., { || PtSetAcento(.F.),FechaBatch() } })

		FormBatch(cTitulo, aSay, aButton)

		If nOpc == 1
			MsAguarde({|| GerData() }, cTitulo,STR0005,.T.)	// 'Montando o documento. Aguarde ...'
		EndIf
		PtSetAcento(.F.)
Else
	Help(" ",1,aMsg[1],,aMsg[2],1,0)
Endif

DbSelectArea("SM0")
Set Filter To
RestArea(aAreaSM0)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ GerData     ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 26.06.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a seleção dos dados do documento e envia para Libre  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GerData                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR450 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GerData()

Local cRA_CATFUN := ""
Local nTRACATFUN := GetSx3Cache( "RA_CATFUNC", "X3_TAMANHO" )
Local nCont      := 0
Local cWhere     := "%"
Local cDir       := SUBSTR(GetTempPath(),1,3)
Local nItens     := 0
Local cDiretorio := cDir+GetMV( "MV_VDFPAST" )
Local cArquivo   := "Lotacionograma"
Local aTxt       := {}
Local cPicture   := PesqPict("SRA", "RA_SALARIO")
Local nEsperaI   := 0

If Empty(mv_par04)
	MsgInfo(STR0006)	// 'Atenção. É obrigatório preencher o periodo de geração do documento !'
	Return
EndIf

DbSelectArea("SRA")
DbSetOrder(1)
DbSeek(mv_par06 + mv_par07)
M->RA_PROC_N := If(! Empty(SRA->RA_NOMECMP), SRA->RA_NOMECMP, SRA->RA_NOME)

M->Q3_DESCS_P := mv_par08
If Empty(mv_par08)
	SQ3->(DbSetOrder(1))
	SQ3->(DbSeek(xFilial() + SRA->RA_CARGO))

	M->Q3_DESCS_P := SQ3->Q3_DESCSUM
EndIf


//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr(cPerg)
If Empty(mv_par01)
	mv_par01 := Left(cFilAnt + Space(Len(SRA->RA_FILIAL)), Len(SRA->RA_FILIAL))
EndIf

DbSelectArea("SM0")
Set Filter to M0_CODIGO == cEmpAnt .And. M0_CODFIL == Left(mv_par01 + Space(Len(SM0->M0_CODFIL)), Len(SM0->M0_CODFIL))
DbGoTop()

cWhere += " AND SRA.RA_FILIAL = '" + MV_PAR01 + "'"

If !Empty(MV_PAR02)		//-- Matriculas
	cWhere += " AND " + MV_PAR02
EndIf

//-- Monta a string com as categorias a serem listadas
If AllTrim( mv_par03 ) <> Replicate("*", Len(AllTrim( mv_par03 )))
	cRA_CATFUN   := ""
	For nCont  := 1 to Len(Alltrim(mv_par03)) Step nTRACATFUN
		If Substr(mv_par03, nCont, nTRACATFUN) <> Replicate("*", Len(Substr(mv_par03, nCont, nTRACATFUN)))
			cRA_CATFUN += "'" + Substr(mv_par03, nCont, nTRACATFUN) + "',"
		EndIf
	Next
	cRA_CATFUN := Substr( cRA_CATFUN, 1, Len(cRA_CATFUN)-1)

	If ! Empty(AllTrim(cRA_CATFUN))
		cWhere += ' AND SRA.RA_CATFUNC IN (' + cRA_CATFUN + ')'
	EndIf
EndIf

cWhere += "%"

BeginSql Alias "QRY"
   COLUMN RA_ADMISSA AS DATE

	SELECT CASE WHEN SRA.RA_CATFUNC IN (%Exp:'0'%, %Exp:'1'%) THEN 0 ELSE 1 END AS CATEGORIA, SRA.RA_MAT, SRA.RA_NOME,
	        SQ3.Q3_DESCSUM, SQB.QB_DESCRIC, SRA.RA_SALARIO
   	  FROM %table:SRA% SRA
      JOIN %table:SQB% SQB ON SQB.%notDel% AND SQB.QB_FILIAL = %Exp:xFilial("SQB")% AND SQB.QB_DEPTO = SRA.RA_DEPTO
      LEFT JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = SRA.RA_CARGO
     WHERE SRA.%notDel% %Exp:cWhere% AND SRA.RA_DEMISSA = %Exp:' '%
     ORDER BY CASE WHEN SRA.RA_CATFUNC IN (%Exp:'0'%, %Exp:'1'%) THEN 0 ELSE 1 END, SRA.RA_MAT
EndSql

Ferase(cDiretorio+"\" + cArquivo + ".HTM")
Ferase(cDiretorio+"\" + cArquivo + ".DOC")

nHandle := FCREATE(cDiretorio+"\" + cArquivo + ".HTM")

WriteHTM(nHandle, "\inicializadores\vdfr450_cab.ini")

M->CATEGORIA := 999

While ! QRY->(Eof())
	MsProcTxt('Lendo a matricula [' + QRY->RA_MAT + '] ...')
	ProcessMessage()

	If M->CATEGORIA <> QRY->CATEGORIA

		If M->CATEGORIA <> 999
			FWrite(nHandle, "</table>" + Chr(13) + Chr(10))
		EndIf

		M->CATEGORIA := QRY->CATEGORIA
		WriteCab(nHandle, .T., If(QRY->CATEGORIA == 0, STR0010, STR0007))

	EndIf

	aTxt := {}
	Aadd(aTxt, '	<TR VALIGN=TOP>')
	Aadd(aTxt, '		<TD WIDTH=46 HEIGHT=15 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
	Aadd(aTxt, '			<P CLASS="western"><FONT FACE="Courier New, monospace"><FONT SIZE=1 STYLE="font-size: 8pt">' + QRY->RA_MAT + '</FONT></FONT></P>')
	Aadd(aTxt, '		</TD>')
	Aadd(aTxt, '		<TD WIDTH=268 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
	Aadd(aTxt, '			<P CLASS="western"><FONT FACE="Courier New, monospace"><FONT SIZE=1 STYLE="font-size: 8pt">' + Capital(QRY->RA_NOME) + '</FONT></FONT></P>')
	Aadd(aTxt, '		</TD>')
	Aadd(aTxt, '		<TD WIDTH=238 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
	Aadd(aTxt, '			<P CLASS="western"><FONT FACE="Courier New, monospace"><FONT SIZE=1 STYLE="font-size: 8pt">' + Capital(QRY->Q3_DESCSUM) + '</FONT></FONT></P>')
	Aadd(aTxt, '		</TD>')
	Aadd(aTxt, '		<TD WIDTH=257 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
	Aadd(aTxt, '			<P CLASS="western"><FONT FACE="Courier New, monospace"><FONT SIZE=1 STYLE="font-size: 8pt">' + Capital(QRY->QB_DESCRIC) + '</FONT></FONT></P>')
	Aadd(aTxt, '		</TD>')
	Aadd(aTxt, '		<TD WIDTH=76 STYLE="border-top: none; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: 1px solid #000000; padding-top: 0cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0.1cm">')
	Aadd(aTxt, '			<P CLASS="western" ALIGN=RIGHT><FONT FACE="Courier New, monospace"><FONT SIZE=1 STYLE="font-size: 8pt">' + Trans(QRY->RA_SALARIO, cPicture)  + '</FONT></FONT></P>')
	Aadd(aTxt, '		</TD>')
	Aadd(aTxt, '	</TR>')

	For nCont := 1 To Len(aTxt)
		FWrite(nHandle, aTxt[nCont] + Chr(13) + Chr(10))
	Next
	nItens ++
	If nItens > 21
		FWrite(nHandle, "</table>" + Chr(13) + Chr(10))
		WriteCab(nHandle, .F.)
		nItens := 0
	EndIf

	QRY->(DbSkip())
EndDo

FWrite(nHandle, "</table>" + Chr(13) + Chr(10))

WriteHTM(nHandle, "\inicializadores\vdfr450_rod.ini")

FClose(nHandle)

Winexec("\LibreOffice\program\swriter.exe --invisible --convert-to doc "+cDiretorio+'\'+cArquivo+".HTM --outdir "+cDiretorio)

//Espera que o Arquivo de Resposta Seja Criado*/
For nEsperaI := 1 To 50000
	If File(cDiretorio+'\'+cArquivo+'.DOC')
		exit
	ElseIf nEsperaI == 50000
		If !MsgYesNo(STR0008)		// 'A abertura está demorando mais do que o esperado. Deseja continuar aguardando ?'
	        exit
	 	Endif
	EndIf
	nEsperaI += 1
Next nEsperaI

shellExecute( "Open", "\LibreOffice\program\soffice.exe", cDiretorio+'\'+cArquivo+".DOC" , cDiretorio, 1 )

Qry->(DbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ WriteHTM    ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 26.06.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Assistente para configuração da estrutura do documento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ WriteHTM                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR450 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function WriteHTM(nHandle, cFile)

Local cData  := Alltrim(STR(DAY(dDataBase))+' de '+ MesExtenso( MONTH(dDataBase) )+' de '+ Alltrim(STR(YEAR(dDataBase)))+'.'), cBuffer := ""

nHdl := FT_FUse(cFile)
FT_FGotop()
While (!FT_FEof())
	cBuffer := FT_FReadLN() + CRLF
	cbuffer := STRTRAN ( cbuffer , "{*[data]*}"   	, cData     , ,)
	cbuffer := STRTRAN ( cbuffer , "{*[assinatura]*}", M->RA_PROC_N, ,)
	cbuffer := STRTRAN ( cbuffer , "{*[assinatura_cargo]*}", M->Q3_DESCS_P, ,)
	cbuffer := VD210Macro(cBuffer)

	FWrite(nHandle, cbuffer)

	FT_FSkip()
EndDo
FClose(nHdl)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ WriteCab    ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 26.06.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gravação do cabeaçalho das informações dos servidores        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ WriteCab                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR450 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function WriteCab(nHandle, lTitle, cTitle)

Local aTxt := {}, nTxt := 0
Default cTitle := ""

If lTitle
	Aadd(aTxt, '<P ALIGN=CENTER STYLE="text-indent: 1.25cm; margin-bottom: 0.28cm; line-height: 105%; widows: 2; orphans: 2">')
	Aadd(aTxt, '<FONT COLOR="#00000a"><FONT FACE="Calibri, sans-serif"><FONT SIZE=2 STYLE="font-size: 11pt"><U><B>' + STR0009) // 'LOTACIONOGRAMA'
	Aadd(aTxt, '&ndash; ' + mv_par04 + '</B></U></FONT></FONT></FONT></P>')
	Aadd(aTxt, '<P ALIGN=CENTER STYLE="text-indent: 1.25cm; margin-bottom: 0.28cm; line-height: 105%; widows: 2; orphans: 2">')
	Aadd(aTxt, '<FONT COLOR="#00000a"><FONT FACE="Calibri, sans-serif"><FONT SIZE=2 STYLE="font-size: 11pt"><U><B>' +;
				cTitle + '</B></U></FONT></FONT></FONT></P>')	// 'MEMBROS'
EndIf
Aadd(aTxt, '<TABLE WIDTH=926 CELLPADDING=4 CELLSPACING=0>')
Aadd(aTxt, '	<COL WIDTH=46>')
Aadd(aTxt, '	<COL WIDTH=268>')
Aadd(aTxt, '	<COL WIDTH=238>')
Aadd(aTxt, '	<COL WIDTH=257>')
Aadd(aTxt, '	<COL WIDTH=76>')
If lTitle
	Aadd(aTxt, '	<TR VALIGN=TOP>')
	Aadd(aTxt, '		<TD WIDTH=46 HEIGHT=14 STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0.1cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
	Aadd(aTxt, '			<P CLASS="western"><FONT SIZE=1 STYLE="font-size: 8pt">' + STR0011 + '</FONT>')	// 'CHAPA'
	Aadd(aTxt, '			</P>')
	Aadd(aTxt, '		</TD>')
	Aadd(aTxt, '		<TD WIDTH=268 STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0.1cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
	Aadd(aTxt, '			<P CLASS="western"><FONT SIZE=1 STYLE="font-size: 8pt">' + STR0012 + '</FONT></P>')	// 'NOME'
	Aadd(aTxt, '		</TD>')
	Aadd(aTxt, '		<TD WIDTH=238 STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0.1cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
	Aadd(aTxt, '			<P CLASS="western"><FONT SIZE=1 STYLE="font-size: 8pt">' + STR0013 + '</FONT></P>')	// CARGO
	Aadd(aTxt, '		</TD>')
	Aadd(aTxt, '		<TD WIDTH=257 STYLE="border-top: 1px solid #000000; border-bottom: 1px solid #000000; border-left: 1px solid #000000; border-right: none; padding-top: 0.1cm; padding-bottom: 0.1cm; padding-left: 0.1cm; padding-right: 0cm">')
	Aadd(aTxt, '			<P CLASS="western"><FONT SIZE=1 STYLE="font-size: 8pt">' + STR0014 + '</FONT></P>')	// 'LOTA&Ccedil;&Atilde;O'
	Aadd(aTxt, '		</TD>')
	Aadd(aTxt, '		<TD WIDTH=76 STYLE="border: 1px solid #000000; padding: 0.1cm">')
	Aadd(aTxt, '			<P CLASS="western" ALIGN=RIGHT><FONT SIZE=1 STYLE="font-size: 8pt">' + STR0015 + '</FONT></P>')	// REMUNERA&Ccedil;&Atilde;O
	Aadd(aTxt, '		</TD>')
	Aadd(aTxt, '	</TR>')
EndIf

For nTxt := 1 To Len(aTxt)
	FWrite(nHandle, aTxt[nTxt] + Chr(13) + Chr(10))
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CfgHTML     ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 26.06.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Assistente para configuração da estrutura do documento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CfgHTML                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VDFR450 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CfgHTML()
Local aAdvSize			:= {}
Local aInfoAdvSize	:= {}
Local aObjSize			:= {}
Local aObjCoords		:= {}
Local lRet 			:= .F., lCateg := .F., nFiles := 0
Local bOk      		:= {|| (lRet := UpdText(oText, aData), oDlg:End()) }
Local bCancel			:= {|| oDlg:End()}, oDlg, aFolder := { 'Cabeçalho', 'Rodapé', '' }, cVar := ""
Local aData            := { "", "" }, nFolder := 1, oText := {}
Local aFiles 			:= { 	"\inicializadores\vdfr450_cab.ini",;
								"\inicializadores\vdfr450_rod.ini" }

For nFolder := 1 To Len(aData)
	If File(aFiles[nFolder])
		aData[nFolder] := LoadFile(aFiles[nFolder])
	EndIf
Next

Begin Sequence

aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

DEFINE MSDIALOG oDlg TITLE STR0016;	// 'Edição Modelo'
		FROM aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

oFolder := TFolder():New( 0, 0, aFolder, aFolder, oDlg,,,, .T.,,oDlg:NCLIENTWIDTH/2,(oDlg:NCLIENTHEIGHT/2))
oFolder:bSetOption := { |x| If(x = Len(aFolder), .F., .T.) }

//nTop, nLeft, nHeight, nWidth , cTitle, cText, nFormat, lShowOkButton, lShowCancelButton, oOwner

For nFolder := 1 To Len(aFolder)
    cVar := ""
	If nFolder <= Len(aData)
		cVar := aData[nFolder]
	EndIf
	Aadd(oText, tSimpEdit():New( , , , , "",  cVar, 2, .F., .F.,oFolder:aDialogs[nFolder]))

	oText[Len(oText)]:oSimpEdit:TextFamily("Courier New")
	oText[Len(oText)]:oSimpEdit:TextSize(12)
	oText[Len(oText)]:oSimpEdit:Load(cVar)
Next

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel)

End Sequence

If lRet
	For nFolder := 1 To Len(aFiles)
		If Empty(aData[nFolder])
			Delete File (aFiles[nFolder])
		Else
			nHandle := FCreate(aFiles[nFolder])
			FWrite(nHandle, aData[nFolder] + CRLF)
			FClose(nHandle)
		EndIf
	Next
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ UpdText  ³ Autor ³ Wagner Mobile Costa   ³ Data ³  13.06.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Atualiza as informações do objeto text para gravação        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ UpdText()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function UpdText(oText, aData)

Local nPos := 1

For nPos := 1 To Len(aData)
	aData[nPos] := oText[nPos]:GetText()
	If oText[nPos]:GetText() == oText[Len(oText)]:GetText()
		aData[nPos] := ""
	EndIf
Next

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LoadFile ³ Autor ³ Wagner Mobile Costa   ³ Data ³  13.06.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Carrega o arquivo de modelo da portaria                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LoadFile()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function LoadFile(cFileOpen)

Local cBuffer := ""

FT_FUSE(cFileOpen)         //ABRIR
FT_FGOTOP()                //PONTO NO TOPO

While !FT_FEOF()
	IncProc()
	cbuffer  := cbuffer+ FT_FREADLN()
	FT_FSKIP()
endDo
FT_FUSE()


Return(cbuffer)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CabWrite * Autor ³ Wagner Mobile Costa   ³ Data ³  01.07.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Gera o arquivo \inicializadores\vdfr450_cab.ini            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CabWrite()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function CabWrite

Local aTxt := {}, nTxt := 0

Aadd(aTxt, '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"><HTML><HEAD>	<META HTTP-EQUIV="CONTENT-TYPE"')
Aadd(aTxt, ' CONTENT="text/html; charset=windows-1252">	<TITLE></TITLE>	<META NAME="GENERATOR" CONTENT="LibreOffice 4.0.1.2 (Windows)">')
Aadd(aTxt, '<META NAME="AUTHOR" CONTENT="Marcos Pereira da Silva">	<META NAME="CREATED" CONTENT="20140701;18320000">	<META NAME="CHANGED" ')
Aadd(aTxt, 'CONTENT="20140701;16383754">	<META NAME="CHANGEDBY" CONTENT="Marcos Pereira da Silva">	<STYLE TYPE="text/css">	')
Aadd(aTxt, '<!--		@page { size: 29.7cm 21cm; margin-left: 2.5cm; margin-right: 2.5cm; margin-top: 1cm; margin-bottom: 1.59cm }')
Aadd(aTxt, '		P { margin-bottom: 0.21cm }		TD P { margin-bottom: 0.28cm; color: #00000a; line-height: 105%; widows: 2; orphans: 2 }		')
Aadd(aTxt, 'TD P.western { font-family: "Calibri", sans-serif; font-size: 11pt }		TD P.cjk { font-family: "SimSun"; font-size: 11pt; ')
Aadd(aTxt, 'so-language: en-US }		TD P.ctl { font-family: "Calibri", sans-serif; font-size: 11pt; so-language: ar-SA }		')
Aadd(aTxt, 'A:link { color: #000080; so-language: zxx; text-decoration: underline }		A:visited { color: #800000; so-language: zxx; ')
Aadd(aTxt, 'text-decoration: underline }	-->	</STYLE></HEAD><BODY LANG="pt-BR" LINK="#000080" VLINK="#800000" DIR="LTR">')
Aadd(aTxt, '<P ALIGN=JUSTIFY STYLE="text-indent: 1.25cm; margin-bottom: 0.28cm; line-height: 105%; widows: 2; orphans: 2; page-break-before: ')
Aadd(aTxt, 'always"><A NAME="_GoBack"></A><FONT COLOR="#00000a"><FONT FACE="Calibri, sans-serif"><FONT SIZE=2 STYLE="font-size: 11pt">')
Aadd(aTxt, 'O<B> PROCURADOR-GERAL DE JUSTI&Ccedil;A</B>, no uso de suas atribui&ccedil;&otilde;es conferidas na Lei Complementar n&ordm; 416, ')
Aadd(aTxt, 'de 22 de dezembro de 2010, e obedecendo as disposi&ccedil;&otilde;es contidas no Art. 148,da Constitui&ccedil;&atilde;o do Estado ')
Aadd(aTxt, 'de Mato Grosso.</FONT></FONT></FONT></P>')

nHandle := FCREATE("\inicializadores\vdfr450_cab.ini")
For nTxt := 1 To Len(aTxt)
	FWrite(nHandle, aTxt[nTxt] + Chr(13) + Chr(10))
Next
FClose(nHandle)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RodWrite * Autor ³ Wagner Mobile Costa   ³ Data ³  01.07.14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Gera o arquivo \inicializadores\vdfr450_rod.ini            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RodWrite()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function RodWrite

Local aTxt := {}
Local nTxt := 0

Aadd(aTxt, '<P ALIGN=CENTER STYLE="text-indent: 1.25cm; margin-bottom: 0.28cm; widows: 0; orphans: 0"><BR><BR></P><P STYLE="')
Aadd(aTxt, 'margin-bottom: 0.28cm; line-height: 105%; widows: 2; orphans: 2"><FONT COLOR="#00000a"><FONT FACE="Calibri, sans-serif">')
Aadd(aTxt, '<FONT SIZE=2 STYLE="font-size: 11pt"><B>Fonte: </B><FONT FACE="Arial, sans-serif"> [{*mv_par05*}]</FONT></FONT></FONT></FONT>')
Aadd(aTxt, '</P><P STYLE="margin-bottom: 0.28cm; line-height: 105%; widows: 2; orphans: 2"><BR><BR></P><P ALIGN=CENTER STYLE="margin-bottom: ')
Aadd(aTxt, '0.28cm; line-height: 105%; widows: 2; orphans: 2"><FONT COLOR="#00000a"><FONT FACE="Calibri, sans-serif"><FONT SIZE=2 STYLE="')
Aadd(aTxt, 'font-size: 11pt"><FONT FACE="Arial, sans-serif"><B>[{*SM0->M0_CIDENT*}]</B>, {*[data]*}</FONT></FONT></FONT></FONT></P>')
Aadd(aTxt, '<P STYLE="margin-bottom: 0.28cm; line-height: 105%; widows: 2; orphans: 2"><BR><BR></P><P ALIGN=CENTER STYLE="margin-bottom: ')
Aadd(aTxt, '0.28cm; line-height: 105%; widows: 2; orphans: 2"><FONT COLOR="#00000a"><FONT FACE="Calibri, sans-serif"><FONT SIZE=2 STYLE="')
Aadd(aTxt, 'font-size: 11pt"><FONT FACE="Arial, sans-serif"><B>{*[assinatura]*}</B></FONT></FONT></FONT></FONT></P><P ALIGN=CENTER STYLE="')
Aadd(aTxt, 'margin-bottom: 0.28cm; line-height: 105%; widows: 2; orphans: 2"><FONT COLOR="#00000a"><FONT FACE="Arial, sans-serif">')
Aadd(aTxt, '<FONT SIZE=2 STYLE="font-size: 11pt">{*[assinatura_cargo]*}</FONT></FONT></FONT></P></BODY></HTML>')

nHandle := FCREATE("\inicializadores\vdfr450_rod.ini")
For nTxt := 1 To Len(aTxt)
	FWrite(nHandle, aTxt[nTxt] + Chr(13) + Chr(10))
Next
FClose(nHandle)

Return
