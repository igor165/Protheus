#Include "Protheus.ch"
#Include "font.ch"
#Include "colors.ch"
#Include "RSPA090.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CR  CHR(13)+CHR(10)

Static cBlqCV	:= SuperGetMv("MV_BLQCV",,"1")
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RSPA090  ³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a pesquisa sobre os campos selecionados            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³29/07/14³TQENN4³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±³Wag Mobile  ³27/11/14³TQVN25³Ajuste para corrigir errorlog quando for  ³±±
±±³            ³        ³      ³MSSQL7 e para realizar pesquisas que envol³±±
±±³            ³        ³      ³vam cursos corretamente.                  ³±±
±±³Henrique V. ³12/06/15³TSDXCP³Ajuste na função Rs090lEdit para que não  ³±±
±±³            ³        ³      ³gere errorlog no momento de realizar a    ³±±
±±³            ³        ³      ³Pesquisa de Cursos com Nivel              ³±±
±±³Luis Artuso ³24/06/15³TSS021³Ajuste na função A090Processa para corri- ³±±
±±³            ³        ³      ³gir errorlog no momento de realizar a 	  ³±±
±±³            ³        ³      ³pesquisa por texto. 		              ³±±
±±³Allyson M.  ³16/10/15³TTJLKJ³Ajuste no tratamento para o campo de cargo³±±
±±³Gustavo M.  ³30/03/16³TUSJSM³Ajuste para corrigir erro na pesquisa	  ³±±
±±³Oswaldo L.  ³11/05/17³DHRPONTP10³Ajuste ctree Projeto SOYUZ   	      ³±±
±±³Oswaldo L.  ³30/08/17³DHRPONTP- ³Ajuste permitir gerar CSV novas pesqui³±±
±±³            ³        ³1485      ³sas. Mas abrir antigos PES também.    ³±±
±±³            ³        ³          ³Ajuste nomes das extensões de arquivos³±±
±±³Oswaldo L.  ³30/10/17³DRHPAG-   ³Ajuste para ler novas tabelas fisicas ³±±
±±³            ³        ³7555      ³RT0\RT1. Manter tratativas ctree neste³±±
±±³            ³        ³          ³fonte.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function RSPA090()

Local aOfusca		:= IIf(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Local aFldRel		:= {"RA_NOME", "RA_CIC"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa 	 ³
//³ ----------- Elementos contidos por dimensao ------------	 ³
//³ 1. Nome a aparecer no cabecalho 							 ³
//³ 2. Nome da Rotina associada 								 ³
//³ 3. Usado pela rotina										 ³
//³ 4. Tipo de Transa‡„o a ser efetuada 						 ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados			 ³
//³    2 - Simplesmente Mostra os Campos						 ³
//³    3 - Inclui registros no Bancos de Dados					 ³
//³    4 - Altera o registro corrente							 ³
//³    5 - Remove o registro corrente do Banco de Dados 		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
Private oArqTRBTmp  := Nil
Private cCadastro 	:= OemToAnsi(STR0041) //"Efetuar Pesquisa"
Private cNomeArq	:= ""
Private cNomeFpt	:= ""
Private cInd1TRB	:= ""
Private cInd2TRB	:= ""
Private aEstru		:= {}
Private aCabec		:= {}
Private aLbx		:= {}
Private oLbx
Private lNvTab  := TabNovaDic()
Private oNo		:= LoadBitmap( GetResources(), "LBNO" )
Private oOk		:= LoadBitmap( GetResources(), "LBTIK" )

//=========== lNvTab ====================================
Private cPsqEmUso   := ''
Private cTabEmUso   := ''
Private lConsTabAnt := .F.
//=======================================================

If lBlqAcesso
	//"Dados Protegidos- Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Saiba mais em {link documentação centralizadora}"
	Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
	Return
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE 						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SQS")
dbSetOrder(1)

mBrowse( 6, 1, 22, 75, "SQS",,,,"SQS->QS_NRVAGA > SQS->QS_VAGAFEC")

dbSelectArea("SQS")
dbSetOrder(1)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090Nova ³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa uma nova pesquisa sobre os campos selecionados     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A090Nova(cAlias,nReg,nOpcx)
Local oDlg, oGet, oPesquisa
Local aPesquisa	:= {}
Local cPesquisa	:= ""
Local nPesq		:= 0
Local lRet		:= .F.
Local cvar		:= ""
Local aValues   := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

dbSelectArea("SQU")
dbSetOrder(1)
dbGotop()
While !Eof()
	If cPesquisa # SQU->QU_CODIGO
		Aadd(aPesquisa,SQU->QU_CODIGO+" - "+SQU->QU_DESCRIC)
		cPesquisa := SQU->QU_CODIGO
        aAdd(aValues, {SQU->QU_FILIAL, SQU->QU_CODIGO})
	EndIf
	dbSkip()
EndDo

If Len(aPesquisa) == 0
	Help("",1,"A090NAOPESQ")		// Nao existe pesquisa para ser executado
	Rs090DelTmp()
	Return .T.
EndIf

If lNvTab
	lConsTabAnt     := .F.
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize( , .T., 390)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T., .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

SETAPILHA()
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0005) FROM aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL//"Selecione uma pesquisa"

	@ aObjSize[1,1],aObjSize[1,2] LISTBOX oPesquisa VAR cVar FIELDS HEADER OemtoAnsi(STR0006) OF oDlg PIXEL SIZE aObjSize[1,3],aObjSize[1,4]-15; //"Pesquisas:"
	ON CHANGE (nPesq:=oPesquisa:nAt) ON DBLCLICK (lRet := .T.,oDlg:End())
	oPesquisa:SetArray(aPesquisa)
  	oPesquisa:bLine := { || {aPesquisa[oPesquisa:nAt]}}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| lRet:= .T., oDlg:End()  },{|| lRet:=.F. ,oDlg:End()} ) CENTERED
SETAPILHA()

If lRet .And. Len(aValues) > 0 .And. nPesq > 0
	A090Perg(aValues[nPesq],nOpcx)
EndIf

Rs090DelTmp()

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090Cons ³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa uma consulta sobre as pesquisas ja existente       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function A090Cons(cAlias,nReg,nOpcx)
Local cFile			:= ""
Local cFileFPT		:= ""
Local aOK			:= {}
Local nPos			:= 0
Local lArqLocal		:= .F.
Local cPathSrv		:= ""
Local cArquivo		:= ""
Local cArqFPT		:= ""
Local cArqSrv		:= ""
Local cArqSrvFPT	:= ""
Local cIndex		:= ""
Local cChave		:= ""
Local i				:= 0
Local cRDD			:= __LocalDriver
Local nLoop			:= 0
Local nTotLoop		:= 0
Local lSemActRsp	:= SQG->( ColumnPos("QG_ACTRSP") ) == 0
Private cExt		:= ''
Private cCsvFile	:= ''

If lNvTab
	If !TelaSelecao()
		MsgInfo(OemtoAnsi(STR0081) + "." + CRLF + OemtoAnsi(STR0086) )	//"Não existem resultados para consultas em sua Base de Dados.
		// Caso existam arquivos de pesquisa (extensões .RSP, .PES ou .CSV) a serem consultados, utilize a rotina RSPM003 para importação dos dados."
		return .T.
	EndIf

	lConsTabAnt := .T.

	CriaTemporario()

	cPsqEmUso := ''//seta nome
Else
	While .T.
		cFile := cGetFile( STR0053 ,OemToAnsi(STR0007),0,,.T.,GETF_ONLYSERVER+GETF_LOCALFLOPPY) //"Selecione o Arquivo"
		If Empty(cFile)
			Return .T.
		EndIf

		If !File(cFile)
			MsgInfo(OemtoAnsi(STR0008)) //"Nao existe arquivo selecionado"
			cFile := ""
			Loop
		EndIf

		If  AT(".",cFile) # 0
			nPos := AT(".",cFile)-1
		Else
			nPos := Len(cFile)
			cFile := cFile+".PES"//o programa original sempre tenta abrir um PES qdo não acha o caracter ".". Mantivemos desta forma
		EndIf

		If Len(cFile) > 2
			cExt := substr( cFile, Len(cFile)-2,  Len(cFile))
		EndIf

		cFileFPT 	:= Substr(cFile,1,nPos)+".FPT"
		If ( nPos := At(':', cFile) ) > 0	// Drive Local
			lArqLocal := .T.

			IF !Empty ( AllTrim( cPathSrv := GetPvProfString( GetEnvServer(), "StartPath", "", GetADV97() ) ) )
				IF !( Subst( cPathSrv , 1 , 1 ) $ "\/" )
					cPathSrv := "\"+cPathSrv
				EndIF
				IF !( Subst( cPathSrv , -1	) $ "\/" )
					cPathSrv+= "\"
				EndIF

				cArquivo	:= cFile
				cArqFPT		:= cFileFPT
				If ( nPos := At(':', cArquivo) ) > 0
					cArquivo := SubS(cArquivo, nPos+1)
					cArqFPT	:= Subs(cArqFPT, nPos+1)
				EndIf
				Do While At('\', cArquivo) > 0 .Or. At('/', cArquivo)> 0
					If (nPos := At('\', cArquivo)) > 0 .Or. (nPos := At('/', cArquivo)) > 0
						cArquivo := SubS(cArquivo, nPos+1)
						cArqFPT	:= Subs(cArqFPT, nPos+1)
					EndIf
				EndDo

				cArqSrv := RetArq( cRDD , cPathSrv + cArquivo , .T. )
				CpyT2S( cFile , cPathSrv  , .F. )

				If File(cFileFPT)
					cArqSrvFPT 	:= RetArq( cRDD , cPathSrv + cArqFPT , .T. )
					CpyT2S( cFileFPT, cPathSrv, .F. )
				EndIf

				If File(cArqSrv)
					If Upper(cExt) == "CSV"
						cCsvFile := cArqSrv
					Else
						MsOpenDbf( .T. , cRDD , cArqSrv , "TRB" , .F. , .F. )
					EndIf

				Else
					MsgInfo(OemtoAnsi(STR0008))    //"Nao existe arquivo selecionado"
					Loop
				EndIF
			EndIf

		Else	// Servidor
			If Upper(cExt) == "CSV"
				cCsvFile := cFile
			Else
				dbUseArea(.T., cRDD, cFile,"TRB", .F., .F.)
			EndIf
		EndIf

		If NETERR()
			MsgInfo(OemtoAnsi(STR0009)) //"Arquivo esta sendo usado"
			cFile:=""
			Loop
		EndIf


		If Upper(cExt) != "CSV"
			dbselectarea("TRB")
			aOk:=DBSTRUCT()
			If aOk[2][1] # "CURRIC" .And. aOK[3][1] # "NOME"
				MsgInfo(OemtoAnsi(STR0010)) //"Este arquivo nao pertence a pesquisa"
				If Select("TRB") != 0
					dbSelectArea("TRB")
					dbCloseArea()
				EndIf
				cFile:=""
				Loop
			EndIf
		EndIf

		Exit
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Procedimentos para Consulta: 1, 2 e 3                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//1
A090Monta(2)

//2
//Dados da Pesquisa
aLbx := {}

dbSelectArea("TRB")
dbGotop()

cChave  := "CURRIC"

If !lNvTab
	If Upper(cExt) != "CSV"
		IndRegua("TRB",'TRB01',cChave,,,OemToAnsi(STR0031))  //é o arquivo fisico *.PES que ele varre aqui
	EndIf
EndIf

aFields := DBSTRUCT()

While !Eof()
	aAux:=ARRAY(Len(aFields))
	For i:=1 to Len(aFields)
		aAux[i]= &(aFields[i][1])
	Next i
	If SQG->( dbSeek(xFilial()+aAux[2])) .And.;		//Filtrar CV sem consentimento já na abertura da consulta
	( lSemActRsp .Or. SQG->QG_ACTRSP != "1" ) .And.;
	( cBlqCV != "2" .Or. SQG->QG_ACEITE == "2" )
		Aadd(aLbx,aAux)
	EndIf
	dbSelectArea("TRB")
	dbSkip()
EndDo

//3
A090List(1,nOpcx)

If !lNvTab
	If lArqLocal
		Ferase(cArquivo)
		Ferase(cArqFPT)
	EndIf
EndIf

Rs090DelTmp()

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090Perg ³ Autor ³ Cristina Ogura        ³ Data ³03.02.98  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra os campos do SQU                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cPesquisa:= Codigo da pesquisa selecionada                 ³±±
±±³          ³ nOpcx    := Opcao selecionada                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A090Perg(aVal,nOpcx)
Local oOk 		:= LoadBitmap( GetResources(), "Enable" )
Local oNo 		:= LoadBitmap( GetResources(), "LBNO" )
Local oFiltro, oDlg
Local aCampos 	:= {}
Local cArquivo	:= ""
Local cPicture	:= ""
Local nOpca		:= 0
Local nClick	:= 0
Local aAlter	:= {}
Local aGrava	:= {}
Local nEnter	:= 2
Local cTipo		:= ""
Local cFiltro	:= ""
Local cTitulo	:= ""
Local cDesc		:= ""
Local cDescric	:= ""
Local cCampo	:= ""
Local cF3		:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords 	:= {}
Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords 	:= {}
Local cFil          := ""
Local cPesquisa     := ""

// Private da Getdados
Private aHeader	:= {}
Private aCols  	:= {}
Private Continua:= .F.

// Private do ListBox
Private a1List	:= {}
Private a2List	:= {}
Private a3List	:= {}

// Guarda os dados a serem pesquisados
Private aDados 	:= {}

Private o1list, o2List, o3List, o1Get, o2Get, oSay
Private nEstou		:= 1
Private cSay		:= ""
Private cAuxGet		:= ""
Private cGetCargo	:= CriaVar("Q3_CARGO")

Default aVal        := {}

cFil := If (Len(aVal) > 0, aVal[1], "")
cPesquisa := If (Len(aVal) > 1, aVal[2], "")

If lNvTab
	dbselectArea('RT0')
EndIf

// Guarda os campos que podem ser alterados na getdados
Aadd(aAlter,"XX_CAMPO")

dbSelectArea("SQU")
dbSetOrder(1)
dbSeek(cFil+cPesquisa)
cDescric:= SQU->QU_DESCRIC
While !Eof() .And. QU_FILIAL+QU_CODIGO == xFilial("SQU")+cPesquisa

	If !(SubStr(SQU->QU_CAMPO,1,4) == "RS6_")
		dbSelectArea("SX3")
		dbSetOrder(2)
		If dbSeek(SQU->QU_CAMPO)
			cTipo := SQU->QU_TIPO
			cTitulo := ALLTRIM(X3Titulo())

			// Tratamento especial para Campos do SQM - Cursos do Candidato (Formacao/Certificacoes/Idiomas/Cursos)
			cFiltro := ""
			cFiltro := SQU->QU_FILTRO
			If Left(SQU->QU_CAMPO,2) == "QM"	//Cursos
				If !Empty(cFiltro)
					cDesc 	:= AllTrim( FDesc("SQX",cFiltro,"QX_DESC") )
					cTitulo := Alltrim(cTitulo)+"("+cDesc+")"
				EndIf
		   EndIf

			If Alltrim(SQU->QU_CAMPO) == "Q3_CARGO"
				cCampo	:= "QG_CODFUN "
				cF3		:= "SQ3   "
			Else
				cCampo	:= SX3->X3_CAMPO
				cF3		:= SX3->X3_F3
			EndIf

			cPicture := Rs090Picture(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE)
			Aadd(aCampos,{	cTitulo,;
							cCampo,;
							cPicture,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							cF3,;
							SX3->X3_TIPO,;
							cTipo,;
							cFiltro})
		EndIf
	Else
		cCodAux := SubStr(SQU->QU_CAMPO,5)
		DbSelectArea("RS6")
		DbSeek(xFilial("RS6")+cCodAux)
		cTipo := SQU->QU_TIPO
		cTitulo := AllTrim(RS6->RS6_DESC)
		cFiltro := ""
		cCampo	:= SQU->QU_CAMPO
		cF3		:= ""
		cPicture := "@!"
		Aadd(aCampos,{	cTitulo,;
						cCampo,;
						cPicture,;
						100,;
						0,;
						cF3,;
						"C",;
						cTipo,;
						cFiltro})
	EndIf

	dbSelectArea("SQU")
	dbSetOrder(1)
	dbSkip()
EndDo

If Len(aCampos) == 0
	Aviso(STR0033, STR0034, {"Ok"})	// "Atencao"###"Esta pesquisa nao tem nenhum campo definido."

	dbSelectArea("SX3")
	dbSetOrder(1)

	Return Nil
EndIf

dbSelectArea("SX3")
dbSetOrder(1)

If !lNvTab
	cArquivo:= Rs090File(cPesquisa)
EndIf

// Inicializa aHeader do get1 quando for memo
aHeader	:= {	{STR0030,"XX_SEQ","@!",2,0,"","û","C"," "},; 			//"Seq."
				{STR0011,"XX_CAMPO","@!",15,0,"NAOVAZIO","û","C"," "}} 	//"Escreva palavras a serem pesquisadas"

aCols := {{"01",Space(15),.F.},{"02",Space(15),.F.} }

// Inicializa o listbox quando for para selecionar
a1List := {{.F.,Space(10)}}
a2List := {{Space(10),Space(10),Space(10)}}
a3List := {{Space(20),.F.,Space(10)}}

// Verifica e monta os listboxs, getdados a serem selecionados na tela
Rs090Verif(aCampos,cPesquisa)

// Posiciona nos dados do 1o campo da pesquisa
If aCampos[1][8] == "S"
	a1List := aClone(aDados[1][1])
ElseIf aCampos[1][8] == "F"
	a2List := aClone(aDados[1][1])
ElseIf aCampos[1][8] == "P"
	aHeader:= aClone(aDados[1][1])
	aCols	 := aClone(aDados[1][2])
ElseIf aCampos[1][8]== "X"
	a3List 	 := aClone(aDados[1][1])
	cGetCargo := aDados[1][2]
EndIf

cSay  := STR0012 + aCampos[1][1]  //"Campo: "

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize( , .T., 390)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 070 , 000 , .F. , .T., .T. } )
aAdd( aObjCoords , { 001 , 000 , .F. , .T. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords, ,.T. )

aAdv1Size    := aClone(aObjSize[3])
aInfo1AdvSize    := { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 5 , 5 }
aAdd( aObj1Coords , { 000 , 010 , .T. , .F. } )
aAdd( aObj1Coords , { 000 , 000 , .T. , .T., .T. } )
aObj1Size := MsObjSize( aInfo1AdvSize , aObj1Coords )

aAdv2Size    := aClone(aObjSize[3])
aInfo2AdvSize    := { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 5 }
aAdd( aObj2Coords , { 000 , 010 , .T. , .F. } )
aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )
aObj2Size := MsObjSize( aInfo2AdvSize , aObj2Coords )

If lNvTab
	cPsqEmUso := ''
	cTabEmUso := ''
EndIf

SETAPILHA()
DEFINE FONT oFont NAME "Arial Negrito" SIZE 0, -11
DEFINE MSDIALOG oDlg  FROM aAdvSize[7],0 TO aAdvSize[6], aAdvSize[5] TITLE OemToAnsi(STR0013) PIXEL//"Preencha os campos da pesquisa: "

	// Listbox dos campos a serem pesquisados
	@ aObjSize[1,1],aObjSize[1,2] LISTBOX oCampo FIELDS HEADER STR0014 SIZE aObjSize[1,3],aObjSize[1,4] OF oDlg PIXEL;  //"Campos a serem pesquisados"
	ON CHANGE (Rs090Muda(aCampos,oCampo:nAt),oCampo:Refresh())
	oCampo:SetArray(aCampos)
	oCampo:bLine := { || {aCampos[oCampo:nAt,1]}}

	@ aObjSize[3,1],aObjSize[3,2] 		GROUP o1Group  TO aObjSize[3,3],aObjSize[3,4] OF oDlg PIXEL
	@ aObj1Size[1,1],aObj1Size[1,2] 	SAY oSay	PROMPT cSay OF oDlg PIXEL SIZE 70,7

	// ListBox da selecao
	@ aObj1Size[2,1],aObj1Size[2,2] LISTBOX o1List FIELDS HEADER " ", STR0015 SIZE aObj1Size[2,3],aObj1Size[2,4] OF oDlg PIXEL; //"Selecione"
	ON DBLCLICK (A090AtuList(@a1List,o1List:nAt,aCampos,oCampo:nAt), o1List:Refresh(.f.))
	o1List:nFreeze := 1
	o1List:SetArray(a1List)
	o1List:bLine := { || {If(a1List[o1List:nAt,1],oOk,oNo),a1List[o1List:nAt,2]}}

	// ListBox do De/Ate
	@ aObj1Size[2,1],aObj1Size[2,2] LISTBOX o2List FIELDS HEADER " ", STR0016, OemtoAnsi(STR0017) SIZE aObj1Size[2,3],aObj1Size[2,4] OF oDlg PIXEL //"De"###"Ate"
	o2List:bLDblClick := {|| Rs090Key(VK_RETURN,@nEnter,aCampos),o2List:SetFocus() }
	o2List:SetArray(a2List)
	o2List:bLine := { || {a2List[o2list:nAt,1],a2List[o2list:nAt,2],a2List[o2list:nAt,3]}}

	// Get e ListBox do Cargo
	@ aObj2Size[2,1],aObj2Size[2,2] MSGET o2Get VAR cGetCargo F3 "SQ3"		PICTURE "99999" SIZE 150,10 OF oDlg PIXEL
	o2Get:bValid :={||Rs090Cargo(cGetCargo,.T.,{})}

	@ aObj1Size[2,1],aObj1Size[2,2] LISTBOX o3List FIELDS HEADER STR0015, " ", " " SIZE aObj1Size[2,3],aObj1Size[2,4] OF oDlg PIXEL; //"Selecione"
	ON DBLCLICK (a3List[o3List:nAt,2] := !a3List[o3List:nAt,2], o3List:Refresh(.f.))
	o3List:SetArray(a3List)
	o3List:bLine := { || {a3List[o3list:nAt,1],If(a3List[o3list:nAt,2],oOk,oNo),a3List[o3list:nAt,3]}}

	// Controle da Getdados
	o1Get := MSGetDados():New(aObj2Size[2,1],aObj2Size[2,2],aObj2Size[2,3],aObj2Size[2,4],nOpcx,"Rs090linOk","AlwaysTrue","+XX_SEQ",.T.,aAlter,1,,300,,,,,oDlg)

ACTIVATE MSDIALOG oDlg ON INIT (nEstou:=1,Rs090Muda(aCampos,1),;
										 EnchoiceBar(oDlg, {|| nOpca:= 1,oDlg:End() },{||oDlg:End()})) CENTERED

SETAPILHA()

DeleteObject(oOk)
DeleteObject(oNo)

If nOpca == 1
	A090Grava(aCampos,cPesquisa,@aGrava)
	Processa({|lEnd|	A090Processa(aGrava,aCampos)	})
	A090List(2,nOpcx)
EndIf

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090Grava³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a gravacao dos campos dos arquivos selecionados    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ aCampos  := Array com os campos do listbox                 ³±±
±±³          ³ cPesquisa:= Codigo da pesquisa                             ³±±
±±³          ³ aGrava   := Dados a serem gravados                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function A090Grava(aCampos,cPesquisa,aGrava)
Local cPath		:= ""
Local cFile		:= ""
Local cOutroNomeArq	:= ""    //a tela tinha variaveis private e local com o mesmo, nome. Mudei apenas para evidenciar q são variaveis distintas
Local nHdl		:= 0
Local cTexto	:= ""
Local cAuxTexto	:= ""
Local aAux		:= {}
Local nTam		:= 0
Local i			:= 0
Local n			:= 0
Local cAux		:= ""
Local cFator	:= ""

// Guarda o ultimo campo posicionado
If aCampos[nEstou][8] == "S"
	aDados[nEstou][1] := aClone(a1List)
ElseIf aCampos[nEstou][8] == "F"
	aDados[nEstou][1] := aClone(a2List)
ElseIf aCampos[nEstou][8] == "P"
	aDados[nEstou][1]	:= aClone(aHeader)
	aDados[nEstou][2]	:= aClone(aCols)
ElseIf aCampos[nEstou][8] == "X"
	aDados[nEstou][1] := aClone(a3List)
	aDados[nEstou][2] := cGetCargo
EndIf

// Apagar o arquivo se existir e cria-lo novamente
dbSelectArea("SX2")
dbSeek("SQU")

If lNvTab
	FWMsgRun(,{|| GrvTabPsq( cPesquisa , aCampos, aGrava)   },OemtoAnsi(STR0083),OemtoAnsi(STR0084))
Else

	If Found()
		cPath := AllTrim( FWSX2Util():GetPath("SQU") )
		IF !( Subst( cPath , -1	) $ "\/" )
			cPath += "\"
		EndIf
	EndIf

	cOutroNomeArq	:= "Pesq"+cPesquisa+".RSP"
	cFile		:= cPath+cOutroNomeArq


	If !File(cFile)
		nHdl := MSFCREATE(cFile,0)
	Else
		FERASE(cFile)
		nHdl := MSFCREATE(cFile,0)
	EndIf

	For i=1 To Len(aCampos)
		cTexto		:= ""
		cAuxTexto	:= ""

		If aCampos[i][8] == "X"
			cAux:= cGetCargo
		Else
			cAux:= ""
		EndIf

		// Grava os dados dos campos
		cTexto:= "**"+aCampos[i][2]+aCampos[i][8]+cAux+CR
		FWRITE(nHdl,cTexto)

		// Grava os filtros dos campos
		cTexto:= ""
		If aCampos[i][8] == "S"
			If aDados[i][2]
				aAux:= aDados[i][1]
				nTam:= Len(Alltrim(aAux[1][3]))
				For n:=1 To Len(aAux)
					If aAux[n][1]
						If Len(cTexto)+ nTam <= 80
							cTexto += aAux[n][3] + "&"
						Else
							cAuxTexto += cTexto
							cTexto += CR
							FWRITE(nHdl,cTexto)
							cTexto:=""
						EndIf
					EndIf
				Next n
			EndIf
		ElseIf aCampos[i][8] == "F"
			aAux	:= aDados[i][1]
			cTexto:= aAux[1][2] + "&" + aAux[1][3] + "&"
		ElseIf aCampos[i][8] == "P"
			aAux:= aDados[i][2]							// aCols
			For n:=1 To Len(aAux)
				If !aAux[n][Len(aAux[n])] .And.;		// aCols Deletado
					!Empty(aAux[n][2])					// Estiver preenchido
					If Len(cTexto)+ 15 <= 80
						cTexto += AllTrim(aAux[n][2])+"&"
					Else
						cAuxTexto += cTexto
						cTexto += CR
						FWRITE(nHdl,cTexto)
						cTexto:=""
					EndIf
				EndIf
			Next n
		ElseIf aCampos[i][8] == "X"
			aAux:= aDados[i][1]
			For n:=1 To Len(aAux)
				If aAux[n][2]							// Marcado
					If Empty(cFator)					// Cod do Fator
						cFator := aAux[n][4]
						cTexto := cFator+"&"
					EndIf
					If cFator # aAux[n][4]
						cAuxTexto += cTexto
						cTexto += CR
						FWRITE(nHdl,cTexto)
						Rs090Array(@aGrava,aCampos,i,cAuxTexto)
						cAuxTexto:= ""
						cFator 	:= aAux[n][4]
						cTexto	:= cFator+"&"
					EndIf
					If Len(cTexto)+ nTam <= 80
						cTexto += Alltrim(aAux[n][5])+"&"  // Grau
						cTexto += Alltrim(aAux[n][6])+"&"  // Grupo
					Else
						cAuxTexto += cTexto
						cTexto += CR
						FWRITE(nHdl,cTexto)
						Rs090Array(@aGrava,aCampos,i,cAuxTexto)
						cAuxTexto:= ""
						cTexto	:=cFator+"&"
					EndIf
				EndIf
			Next n
		EndIf
		cAuxTexto += cTexto
		cTexto += CR
		FWRITE(nHdl,cTexto)
		Rs090Array(@aGrava,aCampos,i,cAuxTexto)
	Next i
	FCLOSE(nHdl)
EndIf

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090Processa ³ Autor ³ Cristina Ogura    ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a processamento da pesquisa                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ aGrava   := Dados a serem gravados                         ³±±
±±³          ³ aCampos  := Campos a serem gravados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A090Processa(aGrava,aCampos)

Local aAlias	:= {}
Local aProcura	:= {}
Local aAuxAlias	:= {}
Local aGuardaExp:= {}
Local aAuxExp	:= {}
Local cGuarda	:= ""
Local cRegua	:= ""
Local i			:= 0
Local j			:= 0
Local k			:= 0
Local aRet		:= {}
Local aRet1		:= {}
Local lRet		:=.T.
Local cSavAlias	:= ""
Local nSavOrd	:= 0
Local cCurric	:= ""
Local cVar		:= ""
Local cLine		:= ""
Local cAux		:= ""
Local cCond		:= ""

Local nX        := 0
Local ni		:= 0
Local cAliasQry := ""
Local cQrycampo := ""   //Montagem da Query: 'Select Campos'
Local cQryjoin  := ""   //Montagem da Query: 'Join'
Local cQrywhere := ""   //Montagem da Query: 'Where' e da Clausula 'Delete'

Local cQuery    := ""
Local cAliaSQG  := ""
Local aStruArq  := {}  //Estrutura do cAlias
Local nRecnos	:= 0
Local lQueryOpened  := .F.
Local cAuxQry	:= ""
Local aAux      := {}
Local lUsaSql	:= TCGetDb() $ "MSSQL"
Local aAuxX		:={}	// Array para conter as expressoes do tipo X
//Variaveis para filtrar tipos do arquivo SQM (Cursos)
Local aAuxSqx 	:= {}
Local cSqx 		:= ""
Local cCampo	:= ""
Local lSemActRsp	:= SQG->( ColumnPos("QG_ACTRSP") ) > 0
Local lSemAceite	:= SQG->( ColumnPos("QG_ACEITE") ) > 0

aGrava := aSort(aGrava,,,{ |x, y| x[1] < y[1] })

For i:=1 To Len(aGrava)
	If cGuarda # Substr(aGrava[i][1],1,2)
		If !("RS6_" $ aGrava[i][1])
			aAdd(aAlias,"S"+Substr(aGrava[i][1],1,2))
			cGuarda:= Substr(aGrava[i][1],1,2)
		EndIf
	EndIf
Next i

A090Monta(1,aCampos)

aAuxAlias := aClone(aAlias)
aAlias	 := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Troca o alias de SQ3 para procurar no SQI              ³
//³A ordem para pesquisar ‚ sempre o SQG como principal   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aAlias,"SQG")
Aadd(aGuardaExp, A090IFS("SQG",aGrava,lUsaSql))

For i := 1 To Len(aAuxAlias)
	If aAuxAlias[i] # "SQG"
		Aadd(aGuardaExp,A090IFS(aAuxAlias[i],aGrava,lUsaSql))
		If aAuxAlias[i] == "SQ3"
			cAux := "SQI"
		Else
			cAux := aAuxAlias[i]
		EndIf
		Aadd(aAlias,cAux)
	EndIf
Next i


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SQL										              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUsaSql
    aAuxX:={} //Array utilizado na Montagem de Subqueries
	For i:= 1 to Len(aAlias)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem da Query : 'Where'                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to Len(aGuardaExp[i])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Armazenar as expressoes do tipo X, nao colocar na query      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Upper(aGuardaExp[i,nX,4]) == "X"
               aadd(aAuxX,Iif(nx == 1 .and. !Empty(cQrywhere), " AND ", "")+aGuardaExp[i,nX,2])
			ElseIf Upper(aGuardaExp[i,nX,1]) != "M"// Nao adiciona na Query campos Memos						 			.Or. aGuardaExp[i,nx,1] != "M"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Desconsidera AND, pois ja vem preenchido na concatenacao³
				//³anterior quando Alias for SQI                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQrywhere += Iif(nx == 1 .and. !Empty(cQrywhere), " AND ", "")+aGuardaExp[i,nX,2]+ " AND "
				If !Empty(aGuardaExp[i,nX,5])
					cQrywhere += " QX_CODIGO = '"  + Alltrim(aGuardaExp[i,nX,5]) +  "' AND "
				EndIf
			EndIf
		Next nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Desconsidera o ultimo .And. da Query                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cAuxQry := Right(cQrywhere,4)
		If Upper(AllTrim(cAuxQry)) == "AND"
			cQrywhere := Substr(cQrywhere,1,len(cQrywhere)-4)
		EndIf
	Next i

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da Query : 'Select Campos'                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lSemActRsp .AND. lSemAceite
		cQrycampo += "SQG.QG_FILIAL,SQG.QG_CURRIC,SQG.QG_NOME,SQG.QG_FONE,SQG.QG_ACTRSP, SQG.QG_ACEITE"
	Else
		cQrycampo += "SQG.QG_FILIAL,SQG.QG_CURRIC,SQG.QG_NOME,SQG.QG_FONE"
	EndIf

	For nX:= 1 to Len(aGrava)
		If !(AllTrim(aGrava[nX,1]) $ cQrycampo) .and. !("RS6_" $ aGrava[nX,1])
			If Left(aGrava[nX,1],2) != "Q3"
				dbSelectArea("SX3")
				dbSetOrder(2)
				dbSeek(alltrim(aGrava[nX,1]))
				If SX3->X3_CONTEXT != "V"	//Nao adiciona campos Virtuais
					cQrycampo += Iif(!Empty(cQrycampo),',','')+'S'+SubStr(aGrava[nX,1],1,2)+'.'+aGrava[nX,1]
				EndIf
			EndIf
		EndIf
	Next nX

	dbSelectArea("SX3")
	dbSetOrder(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da Query : 'Join'  			                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aAlias)

		If aAlias[nX] != "SQG"
			cAliasQry := aAlias[nX] //Alias corrente
			cQryjoin  += ' LEFT JOIN '+ RetSQLname(cAliasQry)+ ' AS ' + cAliasQry
			cQryjoin  += ' ON SQG.QG_CURRIC = '+cAliasQry+'.'+SubStr(cAliasQry,2,2)+'_CURRIC AND ' + cAliasQry + '.' + "D_E_L_E_T_ = ''"
			cQryjoin  += ' AND ' + cAliasQry + '.' +SubStr(cAliasQry,2,2)+ "_FILIAL = '" + xFilial(cAliasQry) + "'"
		EndIf
	
		If cAliasQry == "SQR"
			cQrycampo += ",SQR.QR_FILIAL,SQR.QR_CURRIC,SQR.QR_TESTE,SQR.QR_TOPICO,SQR.QR_QUESTAO,SQR.QR_ALTERNA"
		ElseIf cAliasQry == "SQM"
			cQryjoin  += ' LEFT JOIN '+ RetSQLname("SQT")+ ' AS ' + "SQT"
			cQryjoin  += ' ON SQM.QM_CURSO = SQT.QT_CURSO AND SQT.D_E_L_E_T_ = ' + "''" + " AND " + FWJoinFilial("SMQ", "SQT")
			cQryjoin  += ' LEFT JOIN '+ RetSQLname("SQX")+ ' AS ' + "SQX"
			cQryjoin  += ' ON SQT.QT_TIPO = SQX.QX_CODIGO AND SQX.D_E_L_E_T_ = ' + "''" + " AND " + FWJoinFilial("SQT", "SQX")
			cQryjoin  += ' LEFT JOIN '+ RetSQLname("RBL")+ ' AS ' + "RBL"
			cQryjoin  += ' ON SQX.QX_NIVEL = RBL.RBL_ESCALA AND  RBL.RBL_ITEM = SQM.QM_NIVEL AND RBL.D_E_L_E_T_ = ' + "''" + " AND " + FWJoinFilial("SQX", "RBL")
		Endif

	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da Query Propriamente Dita                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStruArq  := SQG->(dbStruct())
	cAliaSQG  := "SQG"

	cQuery := "SELECT " + cQrycampo
	cQuery += " FROM " + RetSqlName("SQG") +" AS SQG" + cQryjoin
	cQuery += " WHERE QG_FILIAL = '" + xFilial("SQG")+ "' AND "

	If !Empty(cQrywhere)
		cQuery += cQrywhere + " AND SQG.D_E_L_E_T_ = '' "
	Else
   		cQuery += " SQG.D_E_L_E_T_ = '' "
	EndIf

    If Len(aAuxX)>0
    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consideracao de SubQueries caso haja expressoes do tipo X (2 ou mais campos do tipo X)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	If !Empty(cQrywhere)
    		//Outros campos na Pesquisa, alem das expressoes do tipo X (2 ou mais campos do tipo X)                         ³
    		cQueryAx := cQuery+aAuxX[1]
    	Else
    		//Somente para Expressoes do tipo X (2 ou mais campos do tipo X)
	    	cQueryAx := cQuery+" AND "+aAuxX[1]
	    EndIf

		For nX:=2 to Len(aAuxX)
		    cQueryAx += " AND EXISTS ("
		    cQueryAx += (cQuery+" AND "+aAuxX[nX]+")")
		Next nX

		cQuery := cQueryAx
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ordena Arquivo						                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery += " ORDER BY " + SqlOrder( ("SQG")->( IndexKey() ) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Reorganiza query para reconhecimento em MSSQL          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := ChangeQuery(cQuery)

	dbSelectArea("SQG")
	nRecnos	:= SQG->( RecCount() )	//Numero de Registros do SQG
	dbCloseArea()

  	lQueryOpened := MsOpenDbf(.T., "TOPCONN", TCGenQry(,,cQuery), 'SQG', .T., .T.)
  	If lQueryOpened
		For ni := 1 to Len(aStruArq)
			If aStruArq[ni,2] != 'C' .And. FieldPos(aStruArq[ni,1])>0
				TCSetField("SQG", aStruArq[ni,1], aStruArq[ni,2],aStruArq[ni,3],aStruArq[ni,4])
			Endif
		Next ni
	Else
    	ChkFile( "SQG" )
		DbSelectArea("SQG")
		dbSetOrder(1)
		dbGotop()
	EndIf

Else	//Outros bancos diferente de MSSQL7
   	dbSelectArea( "SQG" )
	dbSetOrder(1)
	dbGotop()
	nRecnos := SQG->( RecCount() )
EndIf

ProcRegua( nRecnos )

dbSelectarea("TRB")
aFields := DBSTRUCT() //Processa Resultados:Monta os dados do listbox


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso faca um reprocessamento da Pesquisa, limpa aLbx   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aLbx := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Utilizado para pesquisa de campo memo criado pelo usuario  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUsaSql
	If lQueryOpened
		ChkFile( "SQG", .F., "SQGNEW" )
	EndIf
EndIf

DbSelectarea("SQG") //Alias da Query qdo for Top

lTemSM6 := .F.

For nX := 1 to Len(aGrava)
	If "RS6_" $ aGrava[nX,1] .and. !Empty(aGrava[nX,4])
		lTemSM6 := .T.
		Exit
	EndIf
Next nX

While !Eof()
		If ( SQG->( ColumnPos("QG_ACTRSP") ) > 0 .And. SQG->QG_ACTRSP == "1" ) .Or.;
	( cBlqCV == "2" .And. SQG->QG_ACEITE <> "2"	)	//Filtrar CV sem consentimento
		SQG->(dbSkip())
		Loop
	EndIf
	IncProc(STR0026+": "+SQG->QG_CURRIC)	//"Curriculo"

	aRet:= aGuardaExp[1]
	If Len(aRet) > 0

		lRet:= A090Retorno(aRet,Alias(),lQueryOpened,lUsaSql)

		If !lRet
			dbSelectArea("SQG")
			dbSkip()
			Loop
		EndIf
	EndIf

	If lTemSM6
		lRet := A090FilSM6(aGrava)

		If !lRet
			dbSelectArea("SQG")
			dbSkip()
			Loop
		EndIf
	EndIf

	cCurric := SQG->QG_CURRIC
	nSavOrd  := SQG->( IndexOrd() )


	For i := 2 To Len(aAlias)

		If aAlias[i] == "SQM" .And. !Empty(aGuardaExp[i]) .And. !Empty(aGuardaExp[i][1][5])

			aGuardaExp[i] := Asort(aGuardaExp[i],,,{|x,y| x[5] < y[5]})

			aRet 	:= {}
			aSQX	:= {}
			cSqx := aGuardaExp[i][1][5]
			For nx := 1 To Len(aGuardaExp[i])

				If cSqx != aGuardaExp[i][nx][5]
				   	Aadd( aRet, aSQX )
				   	cSqx := aGuardaExp[i][nx][5]
				   	aSQX := {}
				EndIf
				//aGuardaExp[i][nx][2]:= ' Eval({|| Posicione("SQT",1 ,xFilial("SQT",QM_FILIAL)  + QM_CURSO ,"QT_DESCRIC" )'+" } )"
				If !( aGuardaExp[i][nx][4] == "P" )
					aGuardaExp[i][nx][2]:= aGuardaExp[i][nx][2] + ' .AND. Eval({||"'+ Alltrim(cSQX) + '" = Posicione("SQT",1 ,xFilial("SQT",QM_FILIAL)  + QM_CURSO ,"QT_TIPO" )'+" } )"
				Else
					aGuardaExp[i][nx][2]:= ' Eval({|| "'+ Alltrim(cSQX) + '" = Posicione("SQT",1 ,xFilial("SQT",QM_FILIAL)  + QM_CURSO ,"QT_DESCRIC" )'+" } 	)"
				EndIf

				Aadd( aSQX, Aclone(aGuardaExp[i][nx]) )


			Next nx
			Aadd( aRet, aSQX )

			For nx := 1 To Len(aRet)

				lRet:= .F.

				dbSelectArea(aAlias[i])
				dbSetOrder(1)
				If dbSeek(cFilial+cCurric)
					cCond:= aAlias[i]+"->"+Substr(aAlias[i],2,2)+"_FILIAL"+"+"+aAlias[i]+"->"+Substr(aAlias[i],2,2)+"_CURRIC"
					While !Eof() .and. cFilial+cCurric == &(cCond)

						lRet:= A090Retorno(aRet[nx],Alias(),lQueryOpened,lUsaSql)

						If lRet
							Exit
						EndIf
						nx := 1
						dbSkip()
					EndDo
				Else
					lRet:= .F.
				EndIf

				If !lRet
					Exit
				EndIf

			Next nx

			If !lRet
				Exit
			EndIf

		Else 	// Diferente de "SQM"

			lRet:= .F.
			aRet:= {}
			aRet:= aGuardaExp[i]
			If Len(aRet) > 0
				dbSelectArea(aAlias[i])
				dbSetOrder(1)
				If dbSeek(cFilial+cCurric)
					cCond:= aAlias[i]+"->"+Substr(aAlias[i],2,2)+"_FILIAL"+"+"+aAlias[i]+"->"+Substr(aAlias[i],2,2)+"_CURRIC"
					While !Eof() .and. cFilial+cCurric == &(cCond)

						lRet:= A090Retorno(aRet,Alias(),lQueryOpened,lUsaSql)

						If lRet
							Exit
						EndIf

						dbSkip()
					EndDo
				Else
					lRet:= .F.
				EndIf

				If !lRet
					Exit
				EndIf
			Else
				lRet := .T.
			EndIf

		EndIf
	Next i

	If !lRet
		dbSelectArea("SQG")
		dbSetOrder(nSavOrd)
		dbSkip()
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona todos arquivos no Curriculo Corrente         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SQL")
	dbSetOrder(1)
	dbSeek(cFilial+cCurric)

	dbSelectArea("SQR")
	dbSetOrder(1)
	dbSeek(cFilial+cCurric)

	dbSelectArea("SQI")
	dbSetOrder(1)
	dbSeek(cFilial+cCurric)

	lRet:= .T.

	dbSelectArea("TRB") //Ordenar arquivo TRB por Curric
	dbSetOrder(1)
	If dbSeek(cCurric)
		lRet:= .F.
	EndIf

	If lRet
		RecLock("TRB",.T.)
		For i:=1 To Len(aEstru)
			If aEstru[i][1] == "CURRIC"
				Replace CURRIC With cCurric
			ElseIf aEstru[i][1] == "NOME"
				Replace NOME With SQG->QG_NOME
			ElseIf aEstru[i][1] == "FONE"
				Replace FONE With SQG->QG_FONE
			ElseIf aEstru[i][1] == "VAGA"
				Replace VAGA With SQS->QS_VAGA
			ElseIf aEstru[i][1] == "SEL"
				Replace SEL With .F.
			Else
				cVar	:= aEstru[i][1]
				If aEstru[i][2] # "M"
					Replace &cVar With &("S"+Substr(aEstru[i][1],1,2)+"->"+cVar)
				Else
					Replace &cVar With "***Memo***"
				EndIf
			EndIf
		Next i
		MsUnlock()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processa os Resultados das Pesquisas                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAux := ARRAY(Len(aFields))
		For i := 1 to Len(aFields)
			aAux[i] := &(aFields[i][1])
		Next i
		Aadd(aLbx,aAux)

	EndIf

	dbSelectArea("SQG")
	dbSetOrder(nSavOrd)
	dbSkip()
EndDo

If lUsaSql
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura o SQG Padrao                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lQueryOpened
		( dbSelectArea( "SQGNEW") , dbCloseArea() )
		( dbSelectArea( "SQG" ) , dbCloseArea() , ChkFile( "SQG" ) )
	EndIf
EndIf

DbSelectArea("SQG")
DbSetOrder(1)

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090Monta³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o arquivo de trabalho e o cabecalho do listbox       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nSelec := opcao selecionada                                ³±±
±±³          ³           1- Nova pesquisa                                 ³±±
±±³          ³           2- Consulta pesquisa                             ³±±
±±³          ³ aCampos := Campos a serem gravados                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A090Monta(nSelec,aCampos)
Local i			:= 0
Local nTamCpo	:= 0
Local cCampo	:= ""
Local aLstIndices := {}

If nSelec == 1			// Nova pesquisa
	// Campos fixos do Arquivo
	aEstru:={}
	Aadd(aEstru, { "SEL"	,"L",01, 0 } )
	Aadd(aEstru, { "CURRIC" ,"C",06, 0 } )
	Aadd(aEstru, { "NOME" 	,"C",40, 0 } )
	Aadd(aEstru, { "FONE"	,"C",40, 0 } )
	Aadd(aEstru, { "VAGA"	,"C",06, 0 } )

	aCabec:={}
	Aadd(aCabec,"")
	Aadd(aCabec,UPPER(STR0026))	//"CURRIC"
	Aadd(aCabec,UPPER(STR0028))	//"NOME"
	Aadd(aCabec,UPPER(STR0027))	//"FONE"
	Aadd(aCabec,UPPER(STR0039))	//"VAGA"

	// Campos diferentes de Memo
	For i:=1 To Len(aCampos)
		If aCampos[i][7] != "M"	.and. !("RS6_" $ aCampos[i][2])	//Separar memos para adicionar no final, devido Linux colocar memos por ultimo no arquivo Temporario TRB

			cCampo := AllTrim(aCampos[i][2])
			If Ascan(aEstru,{|x| AllTrim(x[1]) == cCampo}) == 0
				Aadd(aEstru,{cCampo ,aCampos[i][7],aCampos[i][4],aCampos[i][5]})
				Aadd(aCabec,aCampos[i][1])
			EndIf
		EndIf
	Next i

	// Campos Memos
	For i:=1 To Len(aCampos)
		If aCampos[i][7] == "M" .and. !("RS6_" $ aCampos[i][2])	//Separar memos para adicionar no final, devido Linux colocar memos por ultimo no arquivo Temporario TRB

			cCampo := AllTrim(aCampos[i][2])
			If Ascan(aEstru,{|x| AllTrim(x[1]) == cCampo}) == 0
				Aadd(aEstru,{cCampo ,aCampos[i][7],aCampos[i][4],aCampos[i][5]})
				Aadd(aCabec,aCampos[i][1])
			EndIf
		EndIf
	Next i

    aLstIndices := {}

    AAdd( aLstIndices, {"CURRIC"})
    AAdd( aLstIndices, {"NOME"})
    oArqTRBTmp := RhCriaTrab('TRB', aEstru, aLstIndices)
    TRB->(DbSetOrder(1))

ElseIf nSelec == 2		// Opcao de consultar pesquisa

	If Upper(cExt) != "CSV" .or. lNvTab
		aEstru	:= {}
		aCabec	:= {}

		dbSelectArea("TRB")
		aEstru:= DBSTRUCT()
		For i:=1 To Len(aEstru)
			If aEstru[i][1] $ "CURRIC/NOME/FONE/VAGA"
				Aadd(aCabec,aEstru[i][1])
			Else
				If "RS6_" $ aEstru[i][1]
					DbSelectArea("RS6")
					DbSeek(xFilial("RS6")+SubStr(aEstru[i][i],5))
					aAdd(aCabec,AllTrim(RS6->RS6_DESC))
				Else
					dbSelectArea("SX3")
					dbSetOrder(2)
					dbSeek(aEstru[i][1])
					Aadd(aCabec,Alltrim(X3Titulo()))
				EndIf
			EndIf
		Next i
	Else
		LerCSV()
	EndIf

EndIf

dbSelectArea("SX3")
dbSetOrder(1)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090IFS  ³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta os If's dos filtros existentes para a pesquisa       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cAlias:= Alias em uso                                      ³±±
±±³          ³ aGrava:= Campo a serem gravados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A090Ifs(cAlias,aGrava,lUsaSql)

Local cExpressao:= ""
Local aExpressao:= {}
Local cTipo1	:= ""
Local cTipo2	:= ""
Local cProcura	:= ""
Local i			:= 0
Local nx		:= 0
Local cAux		:= ""
Local nCont		:= 0
Local nPos		:= 0
Local p         := 0
Local cPesqp    := ""
Local cPalavra  := ""

Local cAnd 		:= ".And."
Local cOr       := ".Or."
Local cContido1 := "$"
Local cContido2 := ""

Local cValIni	:= ""
Local cValFim	:= ""
Local cParam    := ""

Local cExprGrau := ""
Local cFator	:= ""
Local cGrau 	:= ""
Local cGrupo 	:= ""
Local aAuxGrava	:= {}

If lUsaSql
	cAnd 		:= " AND "
	cOr       	:= " OR "
	cContido1 	:= " IN ("
	cContido2 	:= ")"
EndIf

For i:=1 To Len(aGrava)
	cExpressao := ""
	c1Expressao:= ""
	If Substr(aGrava[i][1],1,2) # Substr(cAlias,2,2)
		Loop
	EndIf

	// Nao permitir gerar uma expressao quando o parametros estiverem em branco
	If  (aGrava[i][3] == "C" .And. Empty(aGrava[i][4]) .And. Empty(aGrava[i][5])) .Or.;
		(aGrava[i][3] == "D" .And. Empty(CtoD(aGrava[i][4])).And. Empty(CtoD(aGrava[i][5]))) .Or.;
		(aGrava[i][3] == "N" .And. Empty(aGrava[i][4]) .And. Empty(aGrava[i][5])) .Or.;
		(aGrava[i][3] == "M" .And. Empty(aGrava[i][4]) .And. Empty(aGrava[i][5]))
		Loop
	EndIf

	If !lUsaSql
		If aGrava[i][3] == "C"
			cTipo1:= "'"
			cTipo2:= "'"
		ElseIf aGrava[i][3] == "D"
			cTipo1:= "CtoD('"
			cTipo2:=	"')"
		ElseIf aGrava[i][3] == "N"
			cTipo1:= "Val('"
			cTipo2:= "')"
		EndIf
	Else
		If aGrava[i][3] == "C"
			cTipo1:= "'"
			cTipo2:= "'"
		ElseIf aGrava[i][3] == "D"
			cTipo1:= "'"
			cTipo2:= "'"
		ElseIf aGrava[i][3] == "N"
			cTipo1:= " "
			cTipo2:= " "
		EndIf
	EndIf

	If aGrava[i][2] == "P"				// Campo Memo
		If aGrava[i][3] == "M"
			cProcura  := aGrava[i][4]
			If	aGrava[i][1] == "QG_ANALISE" .Or. aGrava[i][1] == "QG_EXPER" .Or. aGrava[i][1] == "QL_ATIVIDA"
				cExpressao:= "MSMM(("+ aGrava[i][1] +"))"
			Else
				cExpressao:= aGrava[i][1]
			EndIf

		ElseIf aGrava[i][3] == "C"
			If lUsaSql
				cTipo1:= ""
				cTipo2:= ""
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Alimenta cPalavra com o conteudo preenchido pelo Usuario³
				//³Ex.: Municipio: 'UBERABA','BELO',de BELO HORIZONTE, etc.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cProcura:= alltrim(Upper(aGrava[i][4]))
				For p:= 1 To Len(cProcura)
					cPesqp:= Substr(cProcura,p,1)
					If cPesqp == "&"
						If Empty(cExpressao)
							cExpressao += " ("+Upper(aGrava[i][1])+cTipo1+" LIKE '%"+cPalavra+"%'"+cTipo2+") "
						Else
							cExpressao += " OR ("+Upper(aGrava[i][1])+cTipo1+" LIKE '%"+cPalavra+"%'"+cTipo2+ ") "
						EndIf
						cPalavra:= ""
					Else
				 	    cPalavra += cPesqp
				 	EndIf
				Next p

				cExpressao := "("+cExpressao+")"
			Else
				cProcura  := Upper(Alltrim(aGrava[i][4]))
				cExpressao:= aGrava[i][1]
			EndIf

		EndIf
	ElseIf aGrava[i][2] == "F"

	    If lUsaSql

    	    If aGrava[i][3] == "C"

			    cExpressao := 	AllTrim(Upper(aGrava[i][1])) +" >="+cTipo1+Alltrim(Upper(aGrava[i][4]))+cTipo2+cAnd+;
								AllTrim(Upper(aGrava[i][1])) +" <="+cTipo1+Alltrim(Upper(aGrava[i][5]))+cTipo2

        	ElseIf aGrava[i][3] == "D"
				cValIni	:= Dtos( Ctod( Alltrim(Upper(aGrava[i][4])) ) )
				cValFim	:= Dtos( Ctod( Alltrim(Upper(aGrava[i][5])) ) )
				cExpressao := 	AllTrim(Upper(aGrava[i][1])) +">="+cTipo1+cValIni+cTipo2+cAnd+;
								AllTrim(Upper(aGrava[i][1])) +"<="+cTipo1+cValFim+cTipo2
			ElseIf aGrava[i][3] == "N"
				cValIni	:= Alltrim(Upper(aGrava[i][4]))
				cValFim	:= Alltrim(Upper(aGrava[i][5]))
				cExpressao := 	AllTrim(Upper(aGrava[i][1])) +">="+cTipo1+cValIni+cTipo2+cAnd+;
								AllTrim(Upper(aGrava[i][1])) +"<="+cTipo1+cValFim+cTipo2
			Else
				cExpressao := 	AllTrim(Upper(aGrava[i][1])) +">="+cTipo1+Alltrim(Upper(aGrava[i][4]))+cTipo2+cAnd+;
								AllTrim(Upper(aGrava[i][1])) +"<="+cTipo1+Alltrim(Upper(aGrava[i][5]))+cTipo2
	   		EndIf

	    Else

		    If aGrava[i][3] == "C"

   				cExpressao := 	"UPPER("+AllTrim(Upper(aGrava[i][1])) +")>="+cTipo1+Alltrim(Upper(aGrava[i][4]))+cTipo2+cAnd+;
								"UPPER("+AllTrim(Upper(aGrava[i][1])) +")<="+cTipo1+Alltrim(Upper(aGrava[i][5]))+cTipo2
			Else
				cExpressao := 	AllTrim(Upper(aGrava[i][1])) +">="+cTipo1+Alltrim(Upper(aGrava[i][4]))+cTipo2+cAnd+;
				  				AllTrim(Upper(aGrava[i][1])) +"<="+cTipo1+Alltrim(Upper(aGrava[i][5]))+cTipo2
			EndIf
	    EndIf

		cProcura	 :=""

	ElseIf aGrava[i][2] == "S"
		nPos := AT("&",aGrava[i][4])
		If nPos > 0
			cAux := Substr(aGrava[i][4],1,nPos-1)
		EndIf
		If Len(cAux) == Len(CriaVar(aGrava[i][1]))

			If lUsaSql
				If aGrava[i][3] == "C"
					cTipo1:= ""
					cTipo2:= ""
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Alimenta cParam com o conteudo selecionado pelo Usuario³
					//³Ex.: Estado Civil: 'C','D','S','V' p/ montar IN        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cParam:= alltrim(Upper(aGrava[i][4]))
					cParam:= StrTran(cParam, "&", "','")
					cParam:= If(Substr(cParam,1,1)<>"","'"+cParam,nil)
	                cParam:= Substr(cParam,1,len(cParam)-2)

					cExpressao += Upper(aGrava[i][1])+cTipo1+cContido1+cParam+cContido2+cTipo2
				Else
					cExpressao += Upper(aGrava[i][1])+cContido1+cTipo1+cContido2+Upper(aGrava[i][4])+cContido2+cTipo2
				EndIf

			Else
				cExpressao += Upper(aGrava[i][1])+cContido1+cTipo1+cContido2+Upper(aGrava[i][4])+cContido2+cTipo2
   			EndIf

		Else
			aAuxGrava :=	StrToArray( aGrava[i][4] , "&")
			nCont := 0
			For nx:=1 To Len(aAuxGrava)
				cAux := aAuxGrava[nx]
				If !Empty(cAux)
					nCont++
					If nCont>1
						cExpressao += cOr
					EndIf

					If lUsaSql

						If aGrava[i][3] == "C" .And. aGrava[i][2] == "X"
							cTipo1:= ""
							cTipo2:= ""
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Alimenta cParam com o conteudo selecionado pelo Usuario³
							//³Ex.: Estado Civil: 'C','D','S','V' p/ montar IN        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cParam:= Upper(aGrava[i][1])
							cParam:= StrTran(cParam, "&", "','")
							cParam:= If(Substr(cParam,1,1)<>"","'"+cParam,nil)
			                cParam:= Substr(cParam,1,len(cParam)-2)
							cExpressao+= cTipo1+cAux+cTipo2+cContido1+Alltrim(Upper(aGrava[i][1]))+cTipo2+cContido2
						Else
							cExpressao+= cTipo1+cAux+cTipo2+cContido1+Alltrim(Upper(aGrava[i][1]))+cContido2
						EndIf

					Else
						cExpressao+= cTipo1+cAux+cTipo2+cContido1+cContido2+Alltrim(Upper(aGrava[i][1]))+cContido2
					EndIf
				EndIf
			Next nx
		EndIf
		cProcura	 :=""
	ElseIf aGrava[i][2] == "X"
		nPos := AT("&",aGrava[i][4])
		If nPos > 0
			cAux := Substr(aGrava[i][4],1,nPos-1)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Acrescentado o campo GRUPO para pesquisa³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cProcura:= alltrim(Upper(aGrava[i][4]))
		cFator	:= Substr(cProcura,1,2)
		cGrau 	:= Substr(cProcura,4,2)
		cGrupo 	:= Substr(cProcura,7,2)

		cProcura := Substr(cProcura,10,Len(cProcura))

		For p:=1 To Len(cProcura) step 6
			cPesqp := Substr(cProcura,p,2)
			If Empty(cExprGrau)
				cExprGrau := cPesqp
			Else
				If !lUsaSql
					cExprGrau += ','+cPesqp
				Else
					cExprGrau += "','"+cPesqp
				EndIf
			EndIf
		Next p

		If !lUsaSql
			cExpressao := "SQI->QI_FATOR =="+cTipo1+cFator+cTipo2

			If !Empty(cExprGrau)
				cExpressao +=".And. SQI->QI_GRAU $"+cTipo1+cGrau
				cExpressao += ',' +cExprGrau+cTipo2
			Else
				cExpressao +=".And. SQI->QI_GRAU $"+cTipo1+cGrau+cTipo2
			EndIf

			cExpressao += ".And. SQI->QI_GRUPO $"+cTipo1+cGrupo+cTipo2

		Else

			cExpressao+= "QI_FATOR IN ('"+cFator+ "')" + " AND "

			If !Empty(cExprGrau)
				cExpressao += "QI_GRAU IN ('" +cGrau +"'" + ","+"'"+cExprGrau + "')" + " AND "

			Else
				cExpressao+= "QI_GRAU IN ('" +cGrau+"')" + " AND "
			EndIf

			cExpressao+= "QI_GRUPO IN ('"+cGrupo+"')"
			cProcura  := ""

		EndIf
	EndIf

	Aadd(aExpressao,{aGrava[i][3],cExpressao,cProcura,aGrava[i][2],aGrava[i][6]})			// Tipo, expressao do IF
Next i

Return aExpressao

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090List ³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lista os curriculos selecionados da pesquisa               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ nPerm:= opcao selecionada                                  ³±±
±±³          ³         1- Consulta pesquisa                               ³±±
±±³          ³         2- Nova pesquisa                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function A090List(nPerm,nOpcx)
Local oDlg, oBtn, oBtn1, oBtn2, oBtn3, oBtn4, oBtnMarcTod, oBtnInverte
Local cLine		:= "{ || { "
Local i			:= 0
Local j			:= 0
Local aFields	:= {}
Local aAux		:= {}
Local nEscol	:= 0
Local nGuarda	:= 1
Local nx		:= 0
Local nPos		:= 0
Local aColsRec	:= {}
Local bSet15
Local bSet24
Local lRS090BTN2	:= ExistBlock("RS090BTN2")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdv15Size		:= {}
Local aInfo15AdvSize	:= {}
Local aObj15Size		:= {}
Local aObj15Coords	:= {}
Local aButtons		:= {}

aAdd(aButtons, { "", { || nEscol:=1,nGuarda:=oLbx:nAt,oDlg:End() } , OemToAnsi( STR0052 ) } ) 	// "Visualizar"
aAdd(aButtons, { "", { || nEscol:=2,nGuarda:=oLbx:nAt,oDlg:End() } , OemToAnsi( STR0048 ) } ) 	// "Relacao"
aAdd(aButtons, { "", { || nEscol:=5,nGuarda:=oLbx:nAt,oDlg:End() } , OemToAnsi( STR0049 ) } ) 	// "Agendar"
aAdd(aButtons, { "", { || nEscol:=6,oDlg:End() }                   , OemToAnsi( STR0050 ) } ) 	// "Ficha"
aAdd(aButtons, { "", { || aLbx:=RspTrocaMarca(oLbx:nAt,aLbx,.F.,500,.T.,"M"),oLbx:nColPos := 1,oLbx:Refresh() } , OemToAnsi( STR0045 ) } ) 		//"Marca Todos"
aAdd(aButtons, { "", { || aLbx:=RspTrocaMarca(oLbx:nAt,aLbx,.F.,500,.T.,"I"),oLbx:nColPos := 1,oLbx:Refresh() } , OemToAnsi( STR0046 ) } ) 		//"Inverte Sele‡„o"

If Len(aLbx) == 0
	MsgInfo(OemtoAnsi(STR0018)) //"Nao ha dados para esta consulta"
	dbSelectArea("TRB")
	dbCloseArea()

	If oArqTRBTmp <> Nil
		oArqTRBTmp:Delete()
		Freeobj(oArqTRBTmp)
	EndIf

	Return .T.
EndIf

// Define o numero de colunas do listbox
For i := 1 To Len(aEstru)

	If aEstru[i][1] == "SEL"
		cLine+= "If(aLbx[oLbx:nAt,"+Alltrim(str(i,2))+"], oOk, oNo)"
    ElseIf aEstru[i][2] == "D"
		cLine+= "DtoC(aLbx[oLbx:nAt,"+Alltrim(str(i,2))+"])"
	ElseIf aEstru[i][2] == "N"
		cLine+= "Str(aLbx[oLbx:nAt,"+Alltrim(str(i,2))+"])"
	Else
		cLine+= "aLbx[oLbx:nAt,"+Alltrim(str(i,2))+"]"
	EndIf
	If i # Len(aEstru)
		cLine+=","
	Else
		cLine+="}"
	EndIf
Next i
cLine += "}"

While .T.

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdv15Size		:= MsAdvSize( , .T., 390)
	aInfo15AdvSize	:= {}	//Necessário limpar o array pois o retorno das opcoes do aButtons diminuia o tamanho do TWBrowse
	aInfo15AdvSize	:= { aAdv15Size[1] , aAdv15Size[2] , aAdv15Size[3] , aAdv15Size[4] , 5 , 5 }
	aObj15Coords	:= {}	//Necessário limpar o array pois o retorno das opcoes do aButtons diminuia o tamanho do TWBrowse
	aAdd( aObj15Coords , { 000 , 000 , .T. , .T., .T. } )
	aObj15Size 	:= {}		//Necessário limpar o array pois o retorno das opcoes do aButtons diminuia o tamanho do TWBrowse
	aObj15Size	:= MsObjSize( aInfo15AdvSize , aObj15Coords )
	nEscol:=0

	DEFINE MSDIALOG oDlg FROM aAdv15Size[7],0 TO aAdv15Size[6],aAdv15Size[5] TITLE OemtoAnsi(STR0019) PIXEL //"Curriculos selecionados"

		oLbx:= TWBrowse():New( aObj15Size[1,1], aObj15Size[1,2], aObj15Size[1,3], aObj15Size[1,4],,aCabec,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F.,,, )//1,2,240,130
		oLbx:SetArray(aLbx)
		oLbx:bLine 		:= &(cline)
		oLbx:bLdblclick	:= {|| Rs090Clk()}
		oLbx:nAt   		:= nGuarda

		If nPerm == 2
			bSet15 := {|| oDlg:End( nEscol:=3,nGuarda:=oLbx:nAt,oDlg:End() )}
		Else
			bSet15 := {|| oDlg:End()}
		EndIf

		bSet24 := {|| nEscol:=4,nGuarda:=oLbx:nAt,oDlg:End()}
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , Nil , aButtons ) CENTERED

	If nEscol == 1					// Visualizar
		A090Visa(aLbx[nGuarda,2])

	ElseIf nEscol == 2				// Imprimir
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Este ponto de Entrada sera executado caso usuario desejar   	  ³
		//³ substituir relatorio padrao por relatorio especifico.			  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF lRS090BTN2
			ExecBlock("RS090BTN2",.F.,.F.)
		Else
			A090Impri("RSPA090")
		EndIf
	ElseIf nEscol == 3				// Salvar
		A090Salva()

	ElseIf nEscol == 4				// Sair
		If Select("TRB") != 0
			dbSelectArea("TRB")
			dbCloseArea()

		EndIf
		Exit

	ElseIf nEscol == 5				// Agendar
		If ( nPos := Ascan(aLbx,{ |x| x[1] == .T. }) ) > 0

			For nX := 1 to Len(aLbx)
				If aLbx[nX,1]
					If SQG->( dbSeek(xFilial()+aLbx[nX,2]))
						Aadd(aColsRec, SQG->( Recno() ) )
					EndIf
				EndIf
			Next
			IF !( GpeLocks( 3 , "SQG" ,aColsRec, 2,.F., xFilial()+aLbx[nGuarda,2]) )
				dbSelectArea("TRB")
				dbCloseArea()
				Exit
			EndIF

			Rs090Agenda(aLbx[nGuarda,2],nOpcx)

			FreeLocks( "SQG" , NIL , .T. )

		Else
			Aviso(STR0033, STR0024, {"Ok"})	// "Atencao"###"Nao existe curriculo selecionado"
		EndIf

	ElseIf nEscol == 6             // Ficha de Candidato
		aCand := {}
		For nx := 1 To Len(aLbx)
			If aLbx[nx,1]
				Aadd(aCand,aLbx[nx,2])
			EndIf
		Next nx

		If Len(aCand) == 0
			Aviso(STR0043, STR0044, {"Ok"})	//"Aviso"###"Nao foi selecionado nenhum Candidato. Marque os candidatos para impressao da(s) Ficha(s)."
		Else
			If ExistBlock("ImprCan")
				ExecBlock( "ImprCan", .F., .F., {aCand} )
			else
				RSPR010(aCand)
			endif
		EndIf
	EndIf
EndDo

Return .T.

// Opcao de escolha depois de pesquisar os curriculos
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090Visa ³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizacao do curriculo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cCurric := Curriculo selecionado                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function A090Visa(cCurric)
// Chama o programa de curriculos RSPA010
dbSelectArea("SQG")

If dbSeek(cFilial+cCurric)
	Rsp010Vis("SQG",RecNo())	// Parametro de visualizacao do curriculo
EndIf
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090Salva³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Salva a pesquisa executada no arquivo com o nome informado ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function A090Salva()
Local cSalva	:= Space(08)
Local cSalvaFPT	:= Space(08)
Local cPathSrv	:= ""
Local lFileExis	:= .F.
Local lRet		:= .T.

// Dados do Arquivo Temporario no Server .DBF
Local cDrv		:= ""
Local cDir		:= ""
Local cFile		:= ""
Local cExten	:= ""

// Dados do Arquivo a ser gerado .PES
Local cDrv1		:= ""
Local cDir1		:= ""
Local cFile1	:= ""
Local cExten1	:= ""

If lNvTab
	If !lConsTabAnt//se estiver apenas consuyltando uma tabela antiga ja existente não há necessidade de re-gravar dados ...pois não há como
	               //modificar os dados consultados no browse, portanto nunca há modificação nesta ocasião, sem necessidade de salvar
		lRet := FazCopyFile(cSalva,"TRB")
	EndIf
Else

	//a partir do projeto Soyuz permitir apenas salvar em CSV. Entretanto, caso desejar abrir uma consulta antiga A090Cons lhe será permitido conultar sim *.PES
	cSalva := cGetFile(STR0054 ,OemToAnsi(STR0007),0,,.F.,GETF_ONLYSERVER+GETF_LOCALFLOPPY) //"Salvar Objeto como"

	If  AT(".",cSalva) == 0
		cSalva := cSalva+".CSV"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Separa os componentes                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SplitPath( cSalva, @cDrv, @cDir, @cFile, @cExten )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Copia do servidor para o terminal                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( cSalva )

		lFileExis := .F.
		If File( cSalva )
			lRet      := Aviso( STR0033, STR0035 + cFile + cExten + STR0036, { STR0037, STR0038 }, 2 ) == 1 //"Atencao"###"O arquivo "###" ja existe. Deseja substitui-lo ?"###"SIM"###"NAO"
			lFileExis := .T.
	 	EndIf
		If lRet
			If lFileExis
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se conseguiu excluir o arquivo anterior                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lRet := Empty( FErase( cSalva ) )
			EndIf
			If lRet
				//Não permitir mais que grave como PES. A partir de agora novas gravações somente em CSV!
				FazCopyFile(cSalva,"TRB")
				lRet := .T.
			EndIf

			If !lRet
				Aviso( STR0033, STR0020 + " "+cFile + cExten , { "Ok" }, 2 ) //"Arquivo nao gravado. Verifique o nome do arquivo."
			EndIf
		Else
			Aviso( STR0033, STR0020 + " "+cFile + cExten , { "Ok" }, 2 ) //"Arquivo nao gravado. Verifique o nome do arquivo."
		EndIf
	Else
		Aviso( STR0033, STR0020 + " "+cFile + cExten , { "Ok" }, 2 ) //"Arquivo nao gravado. Verifique o nome do arquivo."
		lRet := .F.
	EndIf

EndIf

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090Impri³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de impressao dos curriculos selecionados            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function A090Impri(wnRel)

Local cTitulo   := OemtoAnsi(STR0019) //"Curriculos selecionados"
Local cDesc1 	:= STR0021 //"Este programa ira imprimir os curriculos selecionados na pesquisa.,"
Local cDesc2 	:= ""
Local cDesc3 	:= ""
Local cString   := "TRB"
Local cFile		:= ""
Local cFileFPT	:= ""
Local cPathSrv	:= ""
Local cArquivo	:= ""
Local nPos		:= 0
Local lArqLocal	:= .F.
Local cArqSrvFPT:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Este ponto de Entrada sera executado caso usuario desejar   	  ³
//³ substituir relatorio padrao por relatorio especifico.			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock("RS090IMP")
	ExecBlock("RS090IMP",.F.,.F.)
	Return Nil
EndIF

PRIVATE cPerg   := "RSP090"
PRIVATE aReturn := { STR0022, 1,STR0023, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE nLastKey:= 0

nOpc	:= 2
nOpcA	:= 2

//esta funcao 'A090Impri' é chamada direto no rspa090 ou pelo rspr002. Em ambas chamadas sempre o TRB já fora criado anteriormente.

wnRel:= SetPrint(cString,wnrel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,"P",,.F.)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
EndIf

pergunte("RSP090",.F.)

RptStatus({|lEnd| C090Imp(@lEnd,ctitulo,wnRel)},ctitulo)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs090Agenda ³ Autor ³ Cristina Ogura      ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Agenda os candidatos selecionados                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cCurric := Curriculo selecionado                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Rs090Agenda(cCurric,nOpcx)
Local aArea := GetArea()

Private	nTamaCols	:= 0
Private lNvTab      := .F.

Rs150List(7, nOpcx, SQS->QS_VAGA)

RestArea(aArea)
Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C090Imp  ³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime os resultados da pesquisa                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd    := Flag de termino do relatorio                 	  ³±±
±±³          ³ cTitulo := Titulo do relatorio                             ³±±
±±³          ³ WnRel   := nome do programa                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function C090Imp(lEnd,cTitulo,WnRel)
Local cCabec1  	:= OemtoAnsi(STR0004) //"Curriculos"
Local cCabec2  	:= ""
Local cTamanho 	:= "P"
Local cNomeProg	:= "RSPA090"
Local cbtxt    	:= SPACE(10)
Local cbcont   	:= 0
Local x			:= 0
Private oTmpImpressao

li 		:= 80
m_pag	:= 1

cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho)
li++

A090MontImpr()

dbSelectArea("AUXTRB")
dbGoTop()

If Eof()
	@ 10,10 PSay STR0024 //"Nao existe curriculo selecionado"
EndIf

SetRegua(RecCount())            // Total de Elementos da Regua

While !EOF()

   IncRegua()

	IF li > 59
		@ ++li,65 PSay STR0025 //"Continua......."
		cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho)
	EndIF

	// Substituir os caracteres graficos antes da impressao. //
	cCampo:=""
	For x:=1 to Len(LINHA)
		If Subs(LINHA,x,1) $ "Ú¿ÀÙ"
			cCampo += "+"
	   ElseIf Subs(LINHA,x,1) == "Ä"
		   cCampo += "-"
	   ElseIf Subs(LINHA,x,1) == "„"
		   cCampo += "a"
	   ElseIf Subs(LINHA,x,1) == "‡"
		   cCampo += "c"
	   ElseIf Subs(LINHA,x,1) == "³"
		   cCampo += "|"
		Else
			cCampo += Subs(LINHA,x,1)
		Endif
	Next x

	@ li++,01 PSay Alltrim(cCampo)
	dbSkip()

EndDo

If li != 80
	li++
	roda(cbcont,cbtxt,"P")
EndIF

Set Device To Screen

dbSelectArea("AUXTRB")
dbCloseArea()

If oTmpImpressao <> Nil
	oTmpImpressao:Delete()
	Freeobj(oTmpImpressao)
EndIf

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif
MS_FLUSH()

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090MontImpr³ Autor ³ Cristina Ogura     ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta a impressao do relatorio                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function A090MontImpr()
Local aCampos	:= {}
Local aFields	:= {}
Local aImpri	:= {}
Local cFimBloc	:= CHR(192)+Repli(CHR(196),73)+CHR(217)
Local i			:= 0
Local cString	:= ""
Local nString	:= 0
Local nTam		:= 0
Local l1Vez		:= .T.
Local cCurric	:= ""
Local cF3		:= ""
Local cDescri	:= ""
Local cSeek		:= ""
Local aF3		:= {}
Local n			:= 0
Local aBox		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define array para arquivo de trabalho                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aCampos,{"LINHA","C",80,0 } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de Trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTmpImpressao := RhCriaTrab('AUXTRB', aCampos, Nil)

dbSelectArea("TRB")
dbGotop()
aFields:= DBSTRUCT()
For i:=1 To Len(aFields)
	Aadd(aImpri,{aFields[i][1],"",0,"","",""})
Next i

MC090BUSCA(@aImpri)

dbSelectArea("TRB")
dbGotop()
While !Eof()

	If (CURRIC < mv_par01 .Or. CURRIC > mv_par02) .Or.;
		( Upper(NOME) < Upper(mv_par03) .Or. Upper(NOME) > Upper(mv_par04) )
		dbSkip()
		Loop
	EndIf

	If l1Vez
		cString:= ""
		MC090TRB(CHR(218)+cString+Repli(CHR(196),(73-Len(cString)))+CHR(191),Alias())
		l1Vez:= .F.
	EndIf

	cString:="³"
	cCurric:= &(aImpri[2][1])  //Curric
	For n:=2 to Len(aImpri)
		cPicture := aImpri[n][4]
		cF3		 := Alltrim(aImpri[n][6])
		cConteudo:= aImpri[n][1]
		cSeek	 := &cConteudo
		cDescri	 := ""
		aF3		 := {}

		If Len( aBox := Rs090Combo(aImpri[n][1], {}) ) > 0	//Combo Box
			If ( nPos := Ascan(aBox,{ |x| x[3] == cSeek }) ) > 0
				cDescri := Substr(aBox[nPos][2], At("-",aBox[nPos][2])-1, 20)
			EndIf
		EndIf

		If !Empty(cF3)
			Rs090F3(@aF3,cF3,cSeek,@cDescri)
		EndIf

		If aImpri[n][5] $ "ND"
			cConteudo := Transform(&cConteudo,cPicture)
		ElseIf aImpri[n][5]=="C"
			If !Empty(aF3)
				cConteudo := Rs090ImprSx5(aImpri[n][2],cString,aF3,n,cCurric)
				cString	 := "³"
				Loop
			Else
				cConteudo := &cConteudo + cDescri
			EndIf
		ElseIf aImpri[n][5]=="M"
			cConteudo:= A090ImprMemo(cString,aImpri,n,cCurric)
			cString	:= "³"
			Loop
	 	EndIf

		If Alltrim(aImpri[n][2]) != STR0027
			If Len(cString)+Len(Alltrim(aImpri[n][2]))+Len(AllTrim(cConteudo))+3 < 75
				cString   += Alltrim(aImpri[n][2])+": "+cConteudo+" "
			Else
				cString := AllTrim(cString) + Space( ( ( 75-Len(AllTrim(cString)) ) - 1 ) )+"³"
				MC090TRB(cString,Alias())
				cString:="³"
				If Len(cString)+Len(Alltrim(aImpri[n][2]))+aImpri[n][3]+3 < 75
					cString   += Alltrim(aImpri[n][2])+": "+cConteudo+" "
				Else
					nString   := Len(cString) + Len(Alltrim(aImpri[n][2])) + 2
					cString   += Alltrim(aImpri[n][2])+": "+Substr(cConteudo,1,73-nString)+" ³"
				EndIf
			EndIf
		Else
			cString := AllTrim(cString) + Space( ( ( 75-Len(AllTrim(cString)) ) - 1 ) )+"³"
			MC090TRB(cString,Alias())
			cString:="³"
			If Len(cString)+Len(Alltrim(aImpri[n][2]))+aImpri[n][3]+3 < 75
				cString   += Alltrim(aImpri[n][2])+": "+cConteudo+" "
			Else
				nString   := Len(cString) + Len(Alltrim(aImpri[n][2])) + 2
				cString   += Alltrim(aImpri[n][2])+": "+Substr(cConteudo,1,73-nString)+" ³"
			EndIf
		EndIf
	Next n
	If Len(cString) > 1
		cString := AllTrim(cString) + Space( ( ( 75-Len(AllTrim(cString)) ) - 1 ) )+"³"
		MC090TRB(cString,Alias())
	EndIf
	MC090TRB(cFimBloc,Alias())
	dbSkip()
EndDo

Return()

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MC090TRB ³ Autor ³ Cristina Ogura        ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os dados no arquivo de trabalho (AUXTRB)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cVar	:= dados a ser gravada                                ³±±
±±³          ³ cAlias:= alias a ser salvo                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function MC090TRB(cVar,cAlias)

dbSelectArea("AUXTRB")
RecLock("AUXTRB",.T.)
	Replace LINHA with OemToAnsi(cVar)
MsUnLock()
dbSelectArea(cAlias)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MC090Busca³ Autor ³ Cristina Ogura       ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o array com a estrutura da impressao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aImpri := array com dados dos campos de impressao          ³±±
±±³          ³ cArq   :=rray com a estrutura da impressao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function MC090BUSCA(aImpri)
Local cAlias 	:= Alias()
Local n			:= 0
Local cArq		:= ""

For n:=1 To Len(aImpri)
	If aImpri[n][1] == "CURRIC"
		aImpri[n][2] := STR0026 //"Curriculo"
		aImpri[n][3] := 7
		aImpri[n][4] := "@!"
		aImpri[n][5] := "C"
		aImpri[n][6] := ""
	ElseIf aImpri[n][1] == "FONE"
		aImpri[n][2] := STR0027 //"Fone"
		aImpri[n][3] := 21
		aImpri[n][4] := "@!"
		aImpri[n][5] := "C"
		aImpri[n][6] := ""
	ElseIf aImpri[n][1] == "NOME"
		aImpri[n][2] := STR0028 //"Nome"
		aImpri[n][3] := 41
		aImpri[n][4] := "@!"
		aImpri[n][5] := "C"
		aImpri[n][6] := ""
	ElseIf aImpri[n][1] == "VAGA"
		aImpri[n][2] := STR0039 //"Vaga"
		aImpri[n][3] := 7
		aImpri[n][4] := "@!"
		aImpri[n][5] := "C"
		aImpri[n][6] := ""
	Else
		cArq:= "S"+Substr(aImpri[n][1],1,2)
		dbSelectArea("SX3")
		dbSeek(cArq)
		While !Eof() .and. X3_ARQUIVO==cArq
			If AllTrim(X3_CAMPO) == aImpri[n][1]
				aImpri[n][2] := X3Titulo()
				aImpri[n][3] := X3_TAMANHO+X3_DECIMAL+1
				aImpri[n][4] := X3_PICTURE
				aImpri[n][5] := X3_TIPO
				aImpri[n][6] := X3_F3
				Exit
			EndIf
			dbSkip()
		EndDo
	EndIf
	dbSelectArea(cAlias)
Next n

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090ImprMemo³ Autor ³ Cristina Ogura     ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime os resultados da pesquisa                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cString:= String a ser impressa no relatorio               ³±±
±±³          ³ aImpri := Array com os dados da impressao                  ³±±
±±³          ³ n      := posicao do array                                 ³±±
±±³          ³ cCurric:= codigo do curriculo                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function A090ImprMemo(cString,aImpri,n,cCurric)
Local cAlias	:= ""
Local cRet		:= ""
Local cNome		:= ""
Local cLine		:= ""
Local aSaveArea	:= GetArea()
Local j 		:= 0
Local nLinha	:= 0

If alltrim(aImpri[n][1]) == "QG_MEMO1"
	cNome:= "QG_ANALISE"
ElseIf Alltrim(aImpri[n][1]) == "QG_MEMO2"
	cNome:= "QG_EXPER"
ElseIf Alltrim(aImpri[n][1]) == "QL_MEMO1"
	cNome:= "QL_ATIVIDA"
ElseIf Alltrim(aImpri[n][1]) == "QR_MEMO1"
	cNome:= "QR_MRESPOS"
Else
	cNome:=	alltrim(aImpri[n][1])	//Outros campos Memos que nao seja SYP
EndIf

// Finaliza a impressao da linha e comeca uma nova
cString := AllTrim(cString) + Space( ( ( 75-Len(AllTrim(cString)) ) - 1 ) )+"³"
MC090TRB(cString,Alias())

cString:="³"

cAlias:="S"+ Substr(aImpri[n][1],1,2)
dbSelectArea(cAlias)
dbSetOrder(1)
dbSeek(cFilial+cCurric)
If	cNome == "QG_ANALISE" .Or. cNome == "QG_EXPER" .Or. cNome == "QL_ATIVIDA"
	cRet	:= MSMM(&(cNome),,,,3)
Else
	cRet	:= &cNome
EndIf
cRet := AllTrim(cRet)

nLinha	:= MlCount(cRet,70)

If nLinha == 0	//Imprime apenas o Titulo do Campo
	cString:="³"+Alltrim(aImpri[n][2])+": "
	cString := AllTrim(cString) + Space( ( ( 75-Len(AllTrim(cString)) ) - 1 ) )+"³"
	MC090TRB(cString,Alias())
EndIf

For j := 1 To nLinha
	IIF(j#1,	cString:="³", cString:="³"+Alltrim(aImpri[n][2])+": ")
	cLine:= MemoLine(cRet, 70, j, , .T.)
	If Len(cString)+Len(cLine)+3 < 75
		cString += cLine+" "
	Else
		cString := AllTrim(cString) + Space( ( ( 75-Len(AllTrim(cString)) ) - 1 ) )+"³"
		MC090TRB(cString,Alias())
		cString:="³"
		If Len(cString)+Len(cLine)+3 < 75
			cString   += cLine+" "
		Else
			nString   := Len(cString) + 2
			cString   += Substr(cLine,1,70-nString)+" ³"
		EndIf
	EndIf
	cString := AllTrim(cString) + Space( ( ( 75-Len(AllTrim(cString)) ) - 1 ) )+"³"
	MC090TRB(cString,Alias())
Next j

RestArea(aSaveArea)

Return cRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs090ImprSX5³ Autor ³ Cristina Ogura     ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime os resultados da pesquisa do SX5                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cString:= String a ser impressa no relatorio               ³±±
±±³          ³ aImpri := Array com os dados da impressao                  ³±±
±±³          ³ n      := posicao do array                                 ³±±
±±³          ³ cCurric:= codigo do curriculo                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function Rs090ImprSX5(cConteudo,cString,aF3,n,cCurric)
Local aSaveArea	:= GetArea()
Local j  		:= 0

// Finaliza a impressao da linha e comeca uma nova
cString := AllTrim(cString) + Space( ( ( 75-Len(AllTrim(cString)) ) - 1 ) )+"³"
MC090TRB(cString,Alias())

// Inicializa a impressao da linha com a descricao da tabela
cString:="³" + cConteudo
cString := AllTrim(cString) + Space( ( ( 75-Len(AllTrim(cString)) ) - 1 ) )+"³"
MC090TRB(cString,Alias())

For j := 1 To Len(aF3)
	cString:="³"
	cString+= Space(05)+aF3[j]
	cString := AllTrim(cString) + Space( ( ( 75-Len(AllTrim(cString)) ) - 1 ) )+"³"
	MC090TRB(cString,Alias())
Next j

RestArea(aSaveArea)

Return cString

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090Procura ³ Autor ³ Cristina Ogura     ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta array das palavras a serem procuradas no campo Memo  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ cString:= linha a ser procurada a palavra chave            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function A090Procura(cString)
Local nInicio 	:= 1
Local nFim		:= 0
Local nAt		:= 0
Local aProcura	:= {}

cString:= Alltrim(cString)
While Substr(cString,Len(cString),1) == ";"
	cString := Substr(cString,1,Len(cString)-1)
EndDo

While .T.
	cString := Substr(cString,nInicio,Len(cString))
	nAt  := AT("&",Substr(cString,1,Len(cString)))
	If nAt == 0
		Exit
	Else
		nFim := nAt - 1
		Aadd(aProcura,Substr(cString,1,nFim))
		nInicio:= nAt + 1
		nFim 	 := Len(cString)
	EndIf
EndDo

Return aProcura

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090Retorno³ Autor ³ Cristina Ogura      ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa os filtros da pesquisa                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ aRet:= Array com os filtros da pesquisa                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A090Retorno(aRet,cAlias,lQueryOpened,lUsaSql)
Local lRet		:= .T.
Local cRet		:= ""
Local i			:= 0
Local j			:= 0
Local k			:= 0
Local aSaveArea := {}

For i := 1 To Len(aRet)

	If !lRet	//Se condicao anterior for .F. nao testa outras condicoes.
		Exit
	EndIf

	If !lQueryOpened
		If aRet[i][1] # "M"

			If aRet[i][4] == "P"  // Pesquisa por Palavra em campo Caracter
				aProcura := A090Procura(aRet[i][3])

				For k := 1 To Len(aProcura)
					lRet := .F.
	             	If Alltrim(Upper(aProcura[k]))$Upper(&(aRet[i][2]))
						lRet := .T.
						Exit
					EndIf

					If lRet
						Exit
					EndIf
				Next k

			Else	// Diferente de "P" - Palavra

				If cAlias # "SQI"
					If !Empty(aRet[i][2])
						If !(&(aRet[i][2]))
							lRet:= .F.
							Exit
						EndIf
					EndIf
				Else
					If !Empty(aRet[i][2])
						If !(&(aRet[i][2]))
							lRet:= .F.
						Else
							lRet:= .T.
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If aRet[i][1] == "M"

		//Campos MEMO criados pelo usuario - busca informacao no SQG padrao, pois nao consta na Query
		aSaveArea := GetArea()
	    If lQueryOpened .And. !("QG_ANALISE" $ aRet[i][2]) .And. !("QG_EXPER" $ aRet[i][2])  .And. !("QL_ATIVIDA" $ aRet[i][2])
	    	dbSelectarea("SQGNEW")
			dbSetOrder(1)
			dbSeek(SQG->QG_FILIAL+SQG->QG_CURRIC)
		Endif
	    If lQueryOpened .And. Substr(aRet[i][2],1,2) == "QR"
	    	dbSelectarea("SQR")
			dbSetOrder(1)
			dbSeek(SQR->QR_FILIAL+QR_CURRIC+QR_TESTE+QR_TOPICO+QR_QUESTAO+QR_ALTERNA)
		 EndIf

		aProcura := A090Procura(aRet[i][3])

			If	aRet[i][2] == "QR_MEMO1  "
				cNome:= "QR_MRESPOS"
				cRet:=MSMM(&(cNome),,,,3)
			Else
				cRet:= &(aRet[i][2])
			Endif
		lRet:= .F.
		If !Empty(cRet)
			// Se apenas 1 palavra for encontrado
			For k:=1 To Len(aProcura)
				lRet:=.F.
				For j:=1 To MlCount(cRet,70)
					cLine:= MemoLine(cRet,70,j)
					If AT(UPPER(aProcura[k]),UPPER(cLine)) # 0
						lRet:= .T.
						Exit
					EndIf
				Next j
				If lRet
					Exit
				EndIf
			Next k
		EndIf
        RestArea(aSaveArea)

	EndIf

Next i

Return lRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs090LinOK ³ Autor ³Cristina Ogura       ³ Data ³ 06.03.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao da linha OK                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs090LinOk()
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs090Verif ³ Autor ³ Ary Medeiros        ³ Data ³06.03.99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que monta todos os dados da pesquisa                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs090Verif(aCampos,cPesquisa)
Local nx		:= 0
Local cVlCargo	:= CriaVar("Q3_CARGO")
Local nTipo 	:= 0
Local aLer 		:= {}
Local aAux		:= {}
Local nAchou	:= 0

If lNvTab
	LeTabPsq(@aLer,cPesquisa)
Else
	Rs090LePesq(@aLer,cPesquisa)
EndIf

For nx:=1 To Len(aCampos)
	aAux	:= {}

	If RT0->(ColumnPos("RT0_FILTRO")) > 0
		nAchou	:= Ascan(aLer,{|x| x[1]== aCampos[nx][2] .and. alltrim(x[5]) == alltrim(aCampos[nx][9])})
	ELSE
		nAchou	:= Ascan(aLer,{|x| x[1]== aCampos[nx][2]})
	ENDIF

	If nAchou # 0
		If aLer[nAchou][2] == aCampos[nx][8]
			aAux 		:= aLer[nAchou][3]
			cVlCargo	:= aLer[nAchou][4]
		EndIf
	EndIf
	If aCampos[nx][8] == "P"						// Getdados
		Rs0901Monta(aCampos,nx,cPesquisa,aAux)
	Else 													// ListBox
		Rs0902Monta(aCampos,nx,cPesquisa,aAux,cVlCargo)
	EndIf
Next nx

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs090Acols³ Autor ³ Cristina Ogura        ³ Data ³06.03.99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que monta todos os acols das getdados                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs090Acols(aCampos,nx,aAuxHeader,cPesquisa,aAux)
Local nFor		:= 0
Local nUsado	:= Len(aAuxHeader)
Local aAuxCols	:= {}
Local nACols	:= 0

If Len(aAux) == 0
	Aadd(aAuxCols,Array(nUsado+1))
	nAcols := Len(aAuxCols)
	For nFor:=1 To Len(aHeader)
		If aHeader[nFor][2] == "XX_SEQ"
			aAuxCols[nAcols][nFor] := "01"
		Else
			aAuxCols[nAcols][nFor] := Space(aHeader[nFor][4])
		EndIf
	Next nFor
	aAuxCols[nAcols][3] := .F.
Else
	For nFor:= 1 To Len(aAux)
		Aadd(aAuxCols,Array(nUsado+1))
		nAcols := Len(aAuxCols)
		For nx:=1 To nAcols
			aAuxCols[nAcols][1] := StrZero(nx,2)
			aAuxCols[nAcols][2] := aAux[nFor]+Space(15-Len(aAux[nFor]))
		Next nx
		aAuxCols[nAcols][3] := .F.
	Next nFor
EndIf

Return aAuxCols

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RS0901Monta³ Autor ³ Cristina Ogura       ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta o acols e aHeader da getdados                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs0901Monta(aCampos,nx,cPesquisa,aAux)
Local aAuxHeader:= {}
Local aAuxCols	:= {}

Aadd(aAuxHeader,{STR0030,"XX_SEQ","@!",2,0,"","û","C"," "}) //"Seq."
Aadd(aAuxHeader,{STR0011,; //"Escreva palavras a serem pesquisadas"
					  "XX_CAMPO","@!",15,0,"","û","C"," "})

aAuxCols:= Rs090Acols(aCampos,nx,aAuxHeader,cPesquisa,aAux)

Aadd(aDados,{aAuxHeader,aAuxCols})

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RS0902Monta³ Autor ³ Cristina Ogura       ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta o listbox da pesquisa                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs0902Monta(aCampos,nx,cPesquisa,aAux,cVlCargo )
Local aBox		:= {}
Local cAuxF3	:= aCampos[nx][6]
Local cAuxEscal	:= ""
Local cTipo		:= ""
Local cTipo1	:= ""
Local lRet		:= .F.
Local ni		:= 0
Local nSeq		:= 0
Local lOk		:= .T.
Local aSaveArea := GetArea()
Local cCmpo 	:= ""
Local cDesc 	:= ""
Local cPrefix	:= ""
Local cFilAux	:= ""
Local nPos		:= ""
Local cDescAux	:= ""
Local cChave	:= ""
Local cFiltro	:= AllTrim(aCampos[nx][9])
Local lAdic		:= .T.

If aCampos[nX,8] == "S"

	If !("RS6_" $ aCampos[nX,2])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pesquisa atraves de dados que nao tiver em Tabela(SX5)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX5")
		dbSetOrder(1)
		If dbSeek(cFilial+Alltrim(cAuxF3))
			While !Eof() .And. cFilial+Alltrim(cAuxF3) == SX5->X5_FILIAL+Alltrim(SX5->X5_TABELA)

				lRet := .F.
				If Ascan(aAux,ALLTRIM(SX5->X5_CHAVE)) > 0
					lRet := .T.
				EndIf
				Aadd(aBox,{lRet,Alltrim(X5Descri()),ALLTRIM(SX5->X5_CHAVE)})
				dbSkip()
			EndDo
		    // Ordenar aBox pela Descricao
		    aBox := Asort( aBox,,,{|x,y| x[2] < y[2]} )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pesquisa atraves de dados que nao tiver em Tabela(SX5)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf Len(aBox) == 0 .And. !Empty(cAuxF3)
		    cAuxEscal:= "RBL_ESCALA"
		    cCodTes:= SQX->QX_CODIGO
			dbSelectArea("SXB")
			dbSetOrder(1)
			If dbSeek(cAuxF3+'4'+'01'+'01') //--> Codigo
			   cCmpo := XB_CONTEM
			Endif
			If dbSeek(cAuxF3+'4'+'01'+'02') //--> Descricao
			   cDesc := XB_CONTEM
			Endif

			cPrefix	:= PrefixoCpo( cAuxF3 )
			cFilAux	:= cPrefix+"_FILIAL"
			nPos	:= At(">",cDesc)+1
			cDescAux:= Alltrim(Substr(cDesc,nPos))
			cChave	:= '"'+cFilAux+'+'+cAuxEscal+'+'+cDescAux+'"'

			dbSelectArea(Alltrim(cAuxF3))
			nOrdem := RetOrdem( Alltrim(cAuxF3), &cChave )
			dbSetOrder(nOrdem)
			dbGotop()
			While !Eof()
				lRet := .F.
				If Ascan(aAux,ALLTRIM(&(cCmpo))) > 0
					lRet := .T.
				EndIf


				// Quando Alias = "SQM" - Monta lista apenas do tipo de curso escolhido (Formacao/Certificacoes/Idiomas/Cursos)
				lAdic := .T.
				If cPrefix == "QT" .And. !Empty(cFiltro)
					If Val(SQT->QT_TIPO) != Val(cFiltro)
						lAdic := .F.
					EndIf
				EndIf

				cAuxEscal:= RBL->RBL_ESCALA
				If lAdic .And. Alltrim(SQX->QX_NIVEL ) == Alltrim(cAuxEscal)
					Aadd(aBox,{lRet,&(cCmpo)+' - '+&(cDesc),&(cCmpo)})
				EndIf

				dbSelectArea(Alltrim(cAuxF3))
				dbSkip()
			EndDo
			dbSetOrder(1)
		EndIf
	Else
		dbSelectArea("RS7")
		dbSetOrder(1)
		cCodAux := AllTrim(SubStr(aCampos[nX,2],5))
		If dbSeek(xFilial("RS7")+cCodAux)
			nSeq := 0
			While !Eof() .And. xFilial("RS7")+cCodAux == RS7->RS7_FILIAL + RS7->RS7_TIPO
				nSeq++
				lRet := .F.
				If Ascan(aAux,StrZero(nSeq,3)) > 0
					lRet := .T.
				EndIf
				aAdd(aBox,{lRet,AllTrim(RS7->RS7_DESC),StrZero(nSeq,3)})
				RS7->(dbSkip())
			EndDo
		    // Ordenar aBox pela Descricao
		    aBox := Asort( aBox,,,{|x,y| x[2] < y[2]} )
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Pesquisa atraves do Combobox (X3_CBOX)	    		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aBox) == 0
  		aBox 	:= Rs090Combo(aCampos[nx][2], aAux)
  	Endif

	If Len(aBox) == 0
		Aadd(aBox,{.F.,STR0029}) //"Problema na pesquisa. Verifique o Tipo da Pesquisa no cadastro ***"
		lOk:= .F.
	EndIf
	Aadd(aDados,{aBox,lOk})
ElseIf aCampos[nx][8] == "X"
	Rs090Cargo(cVlCargo,.F.,aAux)
Else
	If Len(aAux) > 0
		For ni:=1 To 2
			If aCampos[nx][7] == "D"
				cTipo := aAux[ni]
			ElseIf aCampos[nx][7] == "N"
				cTipo := aAux[ni]
			Else
				cTipo := aAux[ni]
			EndIf
			If ni==1
				cTipo1 := cTipo
			EndIf
		Next ni
	Else
		If aCampos[nx][7] == "D"
			cTipo := "  /  /  "
		ElseIf aCampos[nx][7] == "N"
			cTipo := Space(aCampos[nx][4])
		Else
			cTipo := CriaVar(aCampos[nx][2])
			If lNvTab
				cTipo := Space(aCampos[nx][4])
			EndIf
		EndIf
		cTipo1 := cTipo
	EndIf
	Aadd(aBox,{aCampos[nx][1],cTipo1,cTipo})
	Aadd(aDados,{aBox,lOk})
EndIf

RestArea(aSaveArea)

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RS090File  ³ Autor ³ Cristina Ogura       ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verfico o arquivo da pesquisa                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs090File(cPesquisa)
Local cNome	:= "PESQ"+Alltrim(cPesquisa)+"."+"RSP"
Local nHdl	:=0
If File(cNome)
    nHdl    := FOPEN(cNome,64)
    FSEEK(nHdl,0,0)
    nTamArq := FSEEK(nHdl,0,2)
    FSEEK(nHdl,0,0)
EndIf
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RS090Muda  ³ Autor ³ Cristina Ogura       ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controla a mudanca de campos do 1o listbox                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs090Muda(aCampos,nIndo)
Local oOk := LoadBitmap( GetResources(), "Enable" )
Local oNo := LoadBitmap( GetResources(), "LBNO" )

cSay := STR0012 + aCampos[nIndo][1] //"Campo: "
oSay:Refresh()

If aCampos[nEstou][8] == "S"
	aDados[nEstou][1] := aClone(a1List)
ElseIf aCampos[nEstou][8] == "F"
	aDados[nEstou][1] := aClone(a2List)
ElseIf aCampos[nEstou][8] == "P"
	aDados[nEstou][1]	:= aClone(aHeader)
	aDados[nEstou][2]	:= aClone(aCols)
ElseIf aCampos[nEstou][8] == "X"
	aDados[nEstou][1] := aClone(a3List)
EndIf

If aCampos[nIndo][8] == "S"
	o1Get:oBrowse:hide()
	o2Get:hide()
	o2List:hide()
	o3List:hide()
	a1List		:= {}
	a1List		:= aClone(aDados[nIndo][1])
	o1List:SetArray(a1List)
	o1List:nAt 	:= 1
	o1List:bLine:= { || {If(a1List[o1list:nAt,1],oOk,oNo),a1List[o1list:nAt,2]}}
	o1List:Show()
	o1List:Refresh()
ElseIf aCampos[nIndo][8] == "F"
	o1Get:oBrowse:hide()
	o2Get:hide()
	o1List:hide()
	o3List:hide()
	a2List:={}
	a2List:=aClone(aDados[nIndo][1])
	o2List:SetArray(a2List)
	o2List:bLine := { || {a2List[o2list:nAt,1],a2List[o2list:nAt,2],a2List[o2list:nAt,3]}}
	o2List:Show()
	o2List:Refresh()
ElseIf aCampos[nIndo][8] == "P"
	o2Get:hide()
	o1list:hide()
	o2List:hide()
	o3List:hide()
	aHeader:= {}
	aCols	 := {}
	aHeader:= aClone(aDados[nIndo][1])
	aCols	 := aClone(aDados[nIndo][2])
	n		 := 1
	o1Get:ForceRefresh()
	o1Get:oBrowse:Show()
ElseIf aCampos[nIndo][8] == "X"
	o1Get:oBrowse:hide()
	o2Get:Show()
	o1List:hide()
	o2List:hide()
	a3List:={}
	a3List:=aClone(aDados[nIndo][1])
	o3List:SetArray(a3List)
	o3List:bLine := { || {a3List[o3List:nAt,1],If(a3List[o3List:nAt,2],oOk,oNo),a3List[o3List:nAt,3]}}
	o3List:Show()
	o3List:Refresh()
EndIf

nEstou := nIndo

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RS090lEdit ³ Autor ³ Cristina Ogura       ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controla a edicao do listbox quando for DE/ATE              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs090lEdit(aCampos,oOwner,nRow,nCol)
Local oDlg,oGet,cMacro,oRect,oGet1,oGet2,oBtn,__cReadVar,aSizeCols,cF3
Private cTpCurso := ""

oRect := tRect():New(0,0,0,0) 		// obtem as coordenadas da celula (lugar onde
o2List:GetCellRect(nCol,,oRect)   	// a janela de edicao deve ficar)
aDim  := {oRect:nTop,oRect:nLeft,oRect:nBottom,oRect:nRight}

DEFINE MSDIALOG oDlg OF oOwner  FROM 0, 0 TO 0, 0 STYLE nOR( WS_VISIBLE, WS_POPUP ) PIXEL
	cMacro 	:= "M->"+aCampos[nEstou][2]
	If aCampos[nEstou][7] == "N"
		&cMacro	:= Val(a2List[o2List:nAt][nCol])
	Else
		&cMacro	:= a2List[o2List:nAt][nCol]
	EndIf

	cPict  := aCampos[oCampo:nAt][3]
	cF3	   := aCampos[oCampo:nAt][6]
	cTpCurso := aCampos[oCampo:nAt][9]
	If Empty(cF3)
		If AllTrim(aCampos[oCampo:nAt][2]) == "QG_CURRIC"
			cF3 := "SQG"
		ElseIf AllTrim(aCampos[oCampo:nAt][2]) == "Q3_CARGO"
			cF3 := "SQ3"
		ElseIf AllTrim(aCampos[oCampo:nAt][2]) == "QG_AREA"
			cF3 := "R1"
		EndIf
	EndIf

	If !Empty(cF3)
		@ 1,1 MSGET oGet1 VAR &(cMacro) SIZE 1,1 OF oDlg PIXEL FONT oOwner PICTURE cPict F3 cF3 HASBUTTON
		oGet1:Move(-2,-2, (aDim[ 4 ] - aDim[ 2 ]) - 15, aDim[ 3 ] - aDim[ 1 ] + 4 )
	Else
		@ 1,1 MSGET oGet1 VAR &(cMacro) SIZE 1,1 OF oDlg PIXEL FONT oOwner PICTURE cPict HASBUTTON
		oGet1:Move(-2,-2, (aDim[ 4 ] - aDim[ 2 ]) + 4, aDim[ 3 ] - aDim[ 1 ] + 4 )
	EndIf

	@ 0, 0 BUTTON oBtn PROMPT "ze" SIZE 0,0 OF oDlg
	oBtn:bGotFocus	:= {|| oDlg:nLastKey := VK_RETURN, oDlg:End(0)}
	oGet1:cReadVar	:= cMacro
ACTIVATE MSDIALOG oDlg ON INIT oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])

If aCampos[nEstou][7] == "N"
	a2List[o2List:nAt][nCol] := Str(&(cMacro),aCampos[nEstou][4],aCampos[nEstou][5])
Else
	a2List[o2List:nAt][nCol] := &(cMacro)
EndIf

o2List:SetArray(a2List)
o2List:bLine := { || {a2List[o2list:nAt,1],a2List[o2list:nAt,2],a2List[o2list:nAt,3]}}
o2List:Refresh()

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs090Key   ³ Autor ³ Cristina Ogura       ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controla o enter do listbox quando for DE/ATE               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs090Key(nKey,nEnter,aCampos,oOwner)

Rs090lEdit(aCampos,oOwner,,2)
Rs090lEdit(aCampos,oOwner,,3)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs090Picture³ Autor ³ Cristina Ogura      ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta a picture dos campos                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs090Picture(cTipo,nTamanho,nDecimal,cPicture)
Local nAux	:= 0
If cTipo $ "D/N"
	If cTipo == "D"
		cPicture := "99/99/99"
	Else
		If nDecimal == 0
			cPicture := Replicate("9",nTamanho)
		Else
			nAux := nTamanho - nDecimal - 1
			cPicture := Replicate("9",nAux)+"."+Replicate("9",nDecimal)
		EndIf
	EndIf
EndIf
Return cPicture
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs090LePesq ³ Autor ³ Cristina Ogura      ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Le arquivo de pesquisa existente                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aLe       := Array com os arquivos de leitura              ³±±
±±³          ³ cPesquisa := Codigo da pesquisa                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs090LePesq(aLe,cPesquisa)
Local cPath 	:= ""
Local cOutroNomeArq	:= ""//a tela tinha variaveis private e local com o mesmo, nome. Mudei apenas para evidenciar q são variaveis distintas
Local cFile		:= ""
Local cString	:= ""
Local cBuffer	:= ""
Local nInicio	:= 0
Local nAchei	:= 0

dbSelectArea("SX2")
dbSeek("SQU")
If Found()
	cPath := AllTrim( FWSX2Util():GetPath("SQU") )
	IF !( Subst( cPath , -1	) $ "\/" )
		cPath += "\"
	EndIf
EndIf

cOutroNomeArq	:= "Pesq"+cPesquisa+".RSP"
cFile		:= cPath+cOutroNomeArq

If FILE(cFile)
	cString := MEMOREAD(cFile)
	nInicio := 1
	While .T.
		nAchei	:= AT("**",Substr(cString,nInicio,Len(cString)))
		If nAchei == 1
			nInicio := nAchei + 2
			Loop
		EndIf
		If nAchei >0
			cBuffer 	:= Substr(cString,nInicio,nAchei)
			Rs090GrArq(cBuffer,@aLe)
			nInicio	:= nAchei + 2
			cString 	:= Substr(cString,nInicio,Len(cString))
			nInicio 	:= 1
		Else
			Exit
		EndIf
	EndDo
	cBuffer 	:= Substr(cString,3,Len(cString))
	Rs090GrArq(cBuffer,@aLe)
EndIf

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs090GrArq  ³ Autor ³ Cristina Ogura      ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Le dados gravados na Pesquisa.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs090GrArq(cBuffer,aLe)
Local nAchei	:= 0
Local nAchei1	:= 0
Local nInicio 	:= 0
Local cNomeCpo	:= ""
Local cTipoCpo	:= ""
Local cValorCpo	:= ""
Local aAux		:= {}
Local cAux		:= ""
Local cString	:= ""
Local aAuxLe	:= {}

cNomeCpo	:= Substr(cBuffer,1,10)
cTipoCpo	:= Substr(cBuffer,11,1)

If Alltrim(cNomeCpo) == "Q3_CARGO"
	cValorCpo	:= Substr(cBuffer,12,5)
	cBuffer		:= Substr(cBuffer,19,Len(cBuffer))
	cString  	:= cBuffer
	While .T.
		aAux	:= {}
		nAchei1	:= 0
		nAchei1 := At(CHR(13)+CHR(10),cString)
		If nAchei1 > 0
			cBuffer := Substr(cBuffer,1,nAchei1-1)
			nAchei  := 0
			While .T.
				nAchei := At("&",Substr(cBuffer,1,Len(cBuffer)))
				If nAchei > 0
					cAux:= Substr(cBuffer,1,nAchei-1)
					Aadd(aAux,cAux)
					cBuffer := Substr(cBuffer,nAchei + 1,Len(cBuffer))
				Else
					Exit
				EndIf
			EndDo
			Aadd(aAuxLe,aAux)
			cString := Substr(cString,nAchei1+2,Len(cString))
			cBuffer := cString
		Else
			Exit
		EndIf
	EndDo
	Aadd(aLe,{cNomeCpo,cTipoCpo,aAuxLe,cValorCpo})
Else
	cValorCpo:= ""
	cBuffer	:= Substr(cBuffer,14,Len(cBuffer))
	nInicio := 1
	While .T.
		nAchei := At("&",Substr(cBuffer,1,Len(cBuffer)))
		If nAchei > 0
			cAux:= Substr(cBuffer,1,nAchei-1)
			Aadd(aAux,cAux)
			nInicio := nAchei + 1
			cBuffer := Substr(cBuffer,nInicio,Len(cBuffer))
		Else
			Exit
		EndIf
	EndDo
	Aadd(aLe,{cNomeCpo,cTipoCpo,aAux,cValorCpo})
EndIf
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs090Array  ³ Autor ³ Cristina Ogura      ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava o array da pesquisa		                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs090Array(aGrava,aCampos,nEstou,cTexto)
Local cNome	:= ""
Local cDe	:= ""
Local cAte	:= ""

If aCampos[nEstou][8] == "S"
	cNome	:= aCampos[nEstou][2]
	cDe	:= cTexto
	cAte	:= ""
ElseIf aCampos[nEstou][8] == "F"
	cNome	:= aCampos[nEstou][2]
	nPos := At("&",cTexto)
	If nPos > 0
		cDe := Substr(cTexto,1,nPos-1)
		cAte:= AllTrim(Substr(cTexto,nPos+1,Len(cDe)))
		cDe := Alltrim(cDe)
	EndIf
ElseIf aCampos[nEstou][8] == "P"
	If Alltrim(aCampos[nEstou][2]) == "QG_MEMO1"
		cNome:= "QG_ANALISE"
	ElseIf Alltrim(aCampos[nEstou][2]) == "QG_MEMO2"
		cNome:= "QG_EXPER"
	ElseIf Alltrim(aCampos[nEstou][2]) == "QL_MEMO1"
		cNome:= "QL_ATIVIDA"
	Else
		cNome:= aCampos[nEstou][2]
	EndIf
	cDe	:= cTexto
	cAte:= ""
ElseIf aCampos[nEstou][8] == "X"
	cNome:= aCampos[nEstou][2]
	cDe  := cTexto
	cAte := ""
EndIf

Aadd(aGrava,{cNome,aCampos[nEstou][8],aCampos[nEstou][7],cDe,cAte,aCampos[nEstou][9]})

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs090Cargo  ³ Autor ³ Cristina Ogura      ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preenche o ListBox com os dados do Cargo                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs090Cargo(cAuxCargo,lFaz,aAux)
Local oOk 		:= LoadBitmap( GetResources(), "Enable" )
Local oNo 		:= LoadBitmap( GetResources(), "LBNO" )
Local aSaveArea := GetArea()
Local cDescFat	:= ""
Local cDescGrau	:= ""
Local aBox		:= {}
Local lControl 	:= .T.
Local lMarcado	:= .F.
Local nx		:= 0
Local ny		:= 0

If !Empty(cAuxCargo)
	dbSelectArea("SQ3")
	dbSetOrder(1)
	If dbSeek(xFilial("SQ3")+cAuxCargo)
		dbSelectArea("SQ1")
		dbSetOrder(1)
		If dbSeek(SQ3->Q3_FILIAL+SQ3->Q3_GRUPO)
			While !Eof() .And. SQ3->Q3_FILIAL+SQ3->Q3_GRUPO == ;
									 SQ1->Q1_FILIAL+SQ1->Q1_GRUPO

				lControl := .T.
				cDescFat := RspDesc("SQ1",SQ1->Q1_FILIAL+SQ1->Q1_GRUPO+SQ1->Q1_FATOR,"SQ1->Q1_DESCSUM")

				dbSelectArea("SQ2")
				dbSetOrder(1)
				If dbSeek(SQ1->Q1_FILIAL+SQ1->Q1_GRUPO+SQ1->Q1_FATOR)
					While !Eof() .And. SQ1->Q1_FILIAL+SQ1->Q1_GRUPO+SQ1->Q1_FATOR == ;
											 SQ2->Q2_FILIAL+SQ2->Q2_GRUPO+SQ2->Q2_FATOR

						If lControl
							lControl	:= .F.
						Else
							cDescFat := CriaVar("Q1_DESCSUM")
						EndIf

						cDescGrau:= RspDesc("SQ2",SQ1->Q1_FILIAL+SQ1->Q1_GRUPO+SQ1->Q1_FATOR+SQ2->Q2_GRAU,"SQ2->Q2_DESC")

						// Verifico os fatores e graduacao marcados
						// Guardo o valor do fator no 1o. posicao do array e os fatores nas demais posicoes
						lMarcado:= .F.
						For nx:=1 To Len(aAux)
							For ny:= 1 To Len(aAux[nx])
								If ny==1 .And. aAux[nx][ny] # SQ1->Q1_FATOR
									Exit
								EndIf
								If ny # 1 .And. aAux[nx][ny] == SQ2->Q2_GRAU
									lMarcado := .T.
									Exit
								EndIf
							Next ny
							If lMarcado
								Exit
							EndIf
						Next nx

						Aadd(aBox,{cDescFat,lMarcado,cDescGrau,SQ1->Q1_FATOR,SQ2->Q2_GRAU,SQ1->Q1_GRUPO})
						dbSkip()
					EndDo
				EndIf
				dbSelectArea("SQ1")
				dbSkip()
			EndDo
		EndIf
	EndIf
EndIf

If Len(aBox) ==0
	Aadd(aBox,{Space(10),.F.,Space(10)," "," "," "})
EndIf

If lFaz
	a3List:= aClone(aBox)
	o3List:SetArray(a3List)
	o3List:bLine := { || {a3List[o3List:nAt,1],If(a3List[o3List:nAt,2],oOk,oNo),a3List[o3List:nAt,3]}}
	o3List:Refresh()
	cGetCargo := cAuxCargo
	o2Get:Refresh()
Else
	Aadd(aDados,{aBox,cAuxCargo})
EndIf

RestArea(aSaveArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RspDesc      ³ Autor ³ Cristina Ogura    ³ Data ³ 12.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Traz o retorno da descricao dos campos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias do arquivo                                   ³±±
±±³          ³ ExpN1 : Variavel contendo os dados do Seek                 ³±±
±±³          ³ ExpN2 : Variavel de retorno da descricao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSP           ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function RspDesc(cAuxAlias,cVar,cRetorno)
Local aSaveArea := GetArea()
Local cDescr	:= CriaVar(cRetorno)

dbSelectArea(cAuxAlias)
dbSetOrder(1)
If dbSeek(cVar)
	cDescr:= &(cRetorno)
EndIf

RestArea(aSaveArea)

Return cDescr

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs090F3	  ³ Autor ³ Cristina Ogura      ³ Data ³ 03.02.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array de Pesquisa F3                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias := Alias em uso                                     ³±±
±±³          ³ nReg   := Registro posicionado                             ³±±
±±³          ³ nOpcx  := Opcao selecionada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs090F3(aF3,cF3,cSeek,cDescri)
Local aSaveArea := GetArea()
Local nAte		:= 0
Local nTam		:= 0
Local cAchei	:= ""
Local j     	:= 0
Local cAlias	:= ""
Local cPreAlias	:= ""
Local cDesc		:= ""

dbSelectArea("SX5")
If dbSeek(xFilial("SX5")+cF3+cSeek)
	cDescri:= " - " + Substr(X5Descri(),1,20)
ElseIf dbSeek(xFilial("SX5")+cF3)
	nTam := Len(Alltrim(SX5->X5_CHAVE))
	If nTam # 0
		nAte := Len(Alltrim(cSeek)) / nTam
	EndIf

	For j := 1 To nAte
		cAchei:= Substr(cSeek,j*ntam,nTam)
		If Len(cAchei) == nTam
			dbSeek(xFilial("SX5")+cF3+cAchei)
			Aadd(aF3,cAchei+" - "+Substr(X5Descri(),1,20))
		EndIf
	Next j
Else
   	cAlias		:= Alltrim(cF3)
   	cPreAlias	:= Substr(cAlias,2,2)

	dbSelectArea(cAlias)
	dbSetOrder(1)
	If dbSeek(xFilial(cAlias)+cSeek)
	   	cDesc := cPreAlias+"_DESCRIC"
		If FieldPos(cDesc) > 0
			cDescri := " - "+Substr(&cDesc,1,30)
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Rs090Combo³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 30.08.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna array com ComboBox                   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA1: Codigo + Descricao do Elemento do ComboBox          ³±±
±±³			 ³ ExpA2: Codigo do Elemento do ComboBox                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Campo do SX3                                        ³±±
±±³          ³ ExpC2: Conteudo do Combo                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Rs090Combo(cCampo, aAux)

Local aArea    	:= GetArea()
Local cBox     	:= ""
Local aBox     	:= {}
Local nPosicao1	:= 0
Local nPosicao2	:= 0
Local cElem1	:= ""
Local cElem2	:= ""
Local lBox		:= .F.

dbSelectArea("SX3")
dbSetOrder(2)
If ( MsSeek(cCampo) )
	cBox  := X3Cbox()
	While ( !Empty(cBox) )
		nPosicao1   := At(";",cBox)
		If ( nPosicao1 == 0 )
			nPosicao1 := Len(cBox)+1
		EndIf
		nPosicao2   := At("=",cBox)
		cElem1 := SubStr(cBox,1,nPosicao2-1)
		cElem2 := SubStr(cBox,nPosicao2+1,nPosicao1-nPosicao2-1)
		lBox := .F.
		If Ascan( aAux, cElem1 ) > 0
			lBox := .T.
		EndIf
		aadd(aBox,{lBox,cElem1+' - '+cElem2,cElem1})
		cBox := SubStr(cBox,nPosicao1+1)
	EndDo
EndIf
dbSelectArea("SX3")
dbSetOrder(1)
RestArea(aArea)
Return(aBox)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Rs090DelTmp³ Autor ³ Emerson Grassi Rocha ³ Data ³ 03/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Apaga arquivos Temporarios.                   			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Rs090DelTmp()

If Select('TRB')
	dbSelectArea("TRB")
	dbCloseArea()
EndIf

If oArqTRBTmp <> Nil
	oArqTRBTmp:Delete()
	Freeobj(oArqTRBTmp)
EndIf
Return Nil


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs090Clk ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 12/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao executada no ON CLICK do ListBox.	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                           				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs090Clk()

aLbx[oLbx:nAt][1] := Iif( aLbx[oLbx:nAt][1], .F., .T. )

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090FilSM6³ Autor ³ Leandro Drumond      ³ Data ³ 14/06/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Filtra itens da SM6				  	.	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                           				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A090FilSM6(aGrava)
Local aArea		:= GetArea()
Local aAux		:= {}
Local cCodAux	:= ""
Local nX		:= 0
Local nY		:= 0

DbSelectArea("RS6")
DbSelectArea("SM6")

For nX := 1 to Len(aGrava)
	If "RS6_" $ aGrava[nX,1] .and. !Empty(aGrava[nX,4])
		cCodAux := AllTrim(SubStr(aGrava[nX,1],5))
		RS6->(DbSeek(xFilial("RS6")+cCodAux))
		If SM6->(DbSeek(xFilial("SM6")+SQG->QG_CURRIC + cCodAux))
			If RS6->RS6_RESP == "3"
				If !(lRet := StrTran(aGrava[nX,4],"&","") $ UPPER(SM6->M6_RESP) )
					Return .F.
				EndIf
			Else
				aAux := StrTokArr2(AllTrim(aGrava[nX,4]),"&")
				For nY := 1 to Len(aAux)
					If !(aAux[nY] $ SM6->M6_ALTERNA)
						Return .F.
					EndIf
				Next nY
			EndIf
		Else
			Return .F.
		EndIf
	EndIf
Next nX

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A090AtuList³ Autor ³ Leandro Drumond      ³ Data ³ 14/06/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza seleções	   				  	.	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                           				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA090                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A090AtuList(aList1,nList,aCampos,nCpo)
Local aArea		:= GetArea()
Local nX		:= 0

a1List[nList,1] := !a1List[nList,1]

If a1List[nList,1] .and. "RS6_" $ aCampos[nCpo,2]
	DbSelectARea("RS6")
	DbSeek(xFilial("RS6")+AllTrim(SubStr(aCampos[nCpo,2],5)))
	If RS6->RS6_RESP <> "2"
		For nX := 1 to Len(a1List)
			If nX <> nList
				a1List[nX,1] := .F.
			EndIf
		Next nX
	EndIf
EndIf

RestArea(aArea)

Return .T.

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³27/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³RSPA090                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function MenuDef()

 Local aRotina :=  {	{ STR0001,"AxPesqui", 0 , 1,,.F.},; //"Pesquisa"
                    	{ STR0002,"A090Nova", 0 , 4},; 		//"Nova Pesquisa"
                    	{ STR0003,"A090Cons", 0 , 4},;  	//"Cons.Pesquisa"
                    	{ STR0051,"Rspa100LegBrw", 0 , 4}} 	//"Legenda"
Return aRotina



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FazCopyTo ºAutor  ³Oswaldo L.     º Data ³ 10/04/2017      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³funcao para substituir comando __COPYFILE do ctree          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function FazCopyFile(cNArq, cTabAlias)
Local aStruct
Local nLoop
Local nCount
Local cLinhaReg		:= ''
Local nHandle
Local lRet			:= .T.
Private cNomeSalvo	:= ''

If lNvTab
	lRet := .F.

	If TelaSelecao(.T.)
		FWMsgRun(,{|| GrvDadoTab(cTabAlias)   }, OemtoAnsi(STR0085),OemtoAnsi(STR0084))
		lRet := .T.
	EndIf
Else

	If (!File(cNArq)) .And. (cTabAlias)->(!Eof())

		(cTabAlias)->(DbGoTop())

		aStruct := (cTabAlias)->( dbStruct() )

		nHandle := FCreate(cNArq)

		For nLoop := 1 to Len(aStruct)

			If !Empty(cLinhaReg)
				cLinhaReg += ";"
			EndIf
			cLinhaReg += AllTrim(aStruct[nLoop][1])
		Next

		cLinhaReg += CRLF
		FWrite(nHandle,cLinhaReg)

		For nCount := 1 to Len(aLbx)	// exporta todos + seleção do grid

			cLinhaReg := ''
			For nLoop := 1 to Len(aStruct)
				Do Case
					Case aStruct[nLoop][2] $ "C|M"
						cLinhaReg += AllTrim(aLbx[nCount][nLoop])

					Case aStruct[nLoop][2] == "L"
						If aLbx[nCount][nLoop] == .T.
							cLinhaReg += "1"
						Else
							cLinhaReg += "0"
						EndIf

					Case aStruct[nLoop][2] == "N"
						cLinhaReg +=  AllTrim(STR(aLbx[nCount][nLoop]))

					Case aStruct[nLoop][2] == "D"
						cLinhaReg += dtoc(aLbx[nCount][nLoop])
				EndCase
				cLinhaReg += ";"
			Next nLoop

			cLinhaReg += CRLF
			FWrite(nHandle,cLinhaReg)

		Next nCount

		FClose(nHandle)
	EndIf
EndIf

return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LerCSV        ºAutor  ³Oswaldo L.   º Data ³ 30/08/2017     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ler CSV escolhido. A geração de CSV passou a ser feita apos º±±
±±º          ³Proj.Soyuz com autorização do frame                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function LerCSV ()
Local aLstRegs    := {}
Local cSeparador  := ";"
Local nLinha      := 0
Local nCont       := 1
Local aLstIndices := {}
Local aCampos     := {}
Local cGrvCampo   := ''
Private aCSVCabec := {}

FT_FUse( cCsvFile )//Abre o Arquivo
FT_FGoTop()

while !FT_FEof()
	nLinha += 1

    If nLinha == 1//cabeçalho
    	aCSVCabec :=  Separa( Substr(FT_FReadLn(),1,Len(FT_FReadLn())) ,cSeparador )
    	CriaTempDoCSV()//cria temporario
    Else
    	If oArqTRBTmp <> Nil //insere dados do CSV no temporário
    		aLstRegs :=  Separa( Substr(FT_FReadLn(),1,Len(FT_FReadLn())) ,cSeparador )

    		If Len(aLstRegs) > 0

    			dbselectarea('TRB')

	    		Reclock('TRB',.T.)
		    	For nCont := 1 to Len(aEstru)
					cGrvCampo     := "TRB->("  + AllTrim(aEstru[nCont][1]) + ")"

					If aEstru[nCont][2] $ "L"
						If aLstRegs[nCont] == "0"
							&cGrvCampo    := .F.
						Else
							&cGrvCampo    := .T.
						EndIf
					End

					If aEstru[nCont][2] $ "D"
						&cGrvCampo    := ctod(aLstRegs[nCont])
					EndIf

					If !(aEstru[nCont][2] $ "L|D")

						If (aEstru[nCont][2]) == "N"
							nCont := nCont
							&cGrvCampo    := Val(aLstRegs[nCont])
						Else
							&cGrvCampo    := aLstRegs[nCont]
						EndIf

					EndIf
				Next
		    	MsUnLock()
	    	EndIf
    	EndIf
    EndIf

    FT_FSkip()
End

FT_FUse()

return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CriaTempDoCSV ºAutor  ³Oswaldo L.   º Data ³ 30/08/2017     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria temporaria com base no CSV lido                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function CriaTempDoCSV()
Local nCOnt   := 1
Local i
Local aCampos := {}
For nCont := 1 to Len(aCSVCabec)

	dbSelectArea("SX3")
	dbSetOrder(2)
	If !(aCSVCabec[nCont] $ "SEL|CURRIC|NOME|FONE|VAGA") ; //arquivos da rspa090 tem estes campos sempre fixos no inicio
		.And. dbSeek(aCSVCabec[nCont])
		Aadd(aCampos,{	aCSVCabec[nCont],;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_TIPO})
	EndIf
Next

If Len(aCSVCabec) > 0
	// Campos fixos do Arquivo
	aEstru:={}
	Aadd(aEstru, { "SEL"	,"L",01, 0 } )
	Aadd(aEstru, { "CURRIC" ,"C",06, 0 } )
	Aadd(aEstru, { "NOME" 	,"C",40, 0 } )
	Aadd(aEstru, { "FONE"	,"C",40, 0 } )
	Aadd(aEstru, { "VAGA"	,"C",06, 0 } )

	aCabec:={}
	Aadd(aCabec,"")
	Aadd(aCabec,UPPER(STR0026))	//"CURRIC"
	Aadd(aCabec,UPPER(STR0028))	//"NOME"
	Aadd(aCabec,UPPER(STR0027))	//"FONE"
	Aadd(aCabec,UPPER(STR0039))	//"VAGA"

	// Campos diferentes de Memo
	For i:=1 To Len(aCampos)
		If aCampos[i][4] != "M"	.and. !("RS6_" $ aCampos[i][1])	//Separar memos para adicionar no final, devido Linux colocar memos por ultimo no arquivo Temporario TRB
			cCampo := AllTrim(aCampos[i][1])
			If Ascan(aEstru,{|x| AllTrim(x[1]) == cCampo}) == 0
				Aadd(aEstru,{cCampo ,aCampos[i][4],aCampos[i][2],aCampos[i][3]})
				Aadd(aCabec,aCampos[i][1])
			EndIf
		EndIf
	Next i

	// Campos Memos
	For i:=1 To Len(aCampos)
		If aCampos[i][4] == "M" .and. !("RS6_" $ aCampos[i][1])	//Separar memos para adicionar no final, devido Linux colocar memos por ultimo no arquivo Temporario TRB
			cCampo := AllTrim(aCampos[i][1])
			If Ascan(aEstru,{|x| AllTrim(x[1]) == cCampo}) == 0
				Aadd(aEstru,{cCampo ,aCampos[i][4],aCampos[i][2],aCampos[i][3]})
				Aadd(aCabec,aCampos[i][1])
			EndIf
		EndIf
	Next i

    aLstIndices := {}

    AAdd( aLstIndices, {"CURRIC"})
    AAdd( aLstIndices, {"NOME"})
    oArqTRBTmp := RhCriaTrab('TRB', aEstru, aLstIndices)
    TRB->(DbSetOrder(1))
EndIf

return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GrvTabPsq ³ Autor ³ Oswaldo L            ³ Data ³ 03.10.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava configuracao da pesquisa                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ aGrava   := Dados a serem gravados                         ³±±
±±³          ³ aCampos  := Campos a serem gravados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GrvTabPsq(cNomePerg, aCampos, aGrava)
Local ctexto    := ""
Local cMTexto   := ""
Local cAuxTexto := ""
Local cAux      := ""
Local aAux      := {}
Local nTam      := 0
Local n         := 0
Local i         := 0
Local nContador := 0
Local cMemoAux  := ""
Local cRT0Alias := GetNextAlias()

cPsqEmUso := cNomePerg

Begin Transaction

	BeginSql Alias cRT0Alias
		  SELECT RT0.*  FROM 	%table:RT0% RT0
	       WHERE RT0.RT0_FILIAL  = %Exp:(Fwxfilial('RT0'))%
			 AND RT0.RT0_TELA    = 'RSPA090   '
			 AND RT0.RT0_PERG    = %Exp:(padr(cNomePerg, TamSx3("RT0_PERG")[1] ))%
			 AND RT0.%NotDel%
			 ORDER BY RT0.RT0_SEQ
	EndSql

	If (cRT0Alias)->(!Eof())
		RT0->(Dbgoto( (cRT0Alias)->(R_E_C_N_O_) ))
	Endif

	While (cRT0Alias)->(!Eof())
		RT0->(Dbgoto( (cRT0Alias)->(R_E_C_N_O_) ))

		RHMSMM  (RT0->RT0_CODM,,,,2,,,,,,,"RT0")

		reclock("RT0",.F.)
		RT0->(DbDelete())
		MsUnLock()

		(cRT0Alias)->(DbSkip())
	End

	(cRT0Alias)->(DBCloseArea())

	For i := 1 To Len(aCampos)
		cTexto		:= ""
		cAuxTexto	:= ""
		aAux        := {}
		nTam        := 0
		cAux        := ""
		cMTexto     := ""

		If aCampos[i][8] == "X"
			cAux:= cGetCargo
		Else
			cAux:= ""
		EndIf

		If aCampos[i][8] == "S"
			If aDados[i][2]
				aAux:= aDados[i][1]
				nTam:= Len(Alltrim(aAux[1][3]))
				For n:=1 To Len(aAux)
					If aAux[n][1]

						cMTexto += aAux[n][3] + "&"

						If Len(cTexto)+ nTam <= 80
							cTexto += aAux[n][3] + "&"
						Else
							cAuxTexto += cTexto
							cTexto += CR
							cTexto:=""
						EndIf
					EndIf
				Next n
			EndIf
		ElseIf aCampos[i][8] == "F"
			aAux	:= aDados[i][1]

			dbSelectArea("SX3")
			dbSetOrder(2)
			dbSeek(aCampos[i][2])

			aAux[1][2] := padr ( aAux[1][2], TamSx3(aCampos[i][2])[1] )
			aAux[1][3] := padr ( aAux[1][3], TamSx3(aCampos[i][2])[1] )

			cTexto  := aAux[1][2] + "&" + aAux[1][3] + "&"
			cMTexto += aAux[1][2] + "&" + aAux[1][3] + "&"
		ElseIf aCampos[i][8] == "P"
			aAux:= aDados[i][2]							// aCols
			For n:=1 To Len(aAux)
				If !aAux[n][Len(aAux[n])] .And.;		// aCols Deletado
					!Empty(aAux[n][2])					// Estiver preenchido

					cMTexto += AllTrim(aAux[n][2])+"&"

					If Len(cTexto)+ 15 <= 80
						cTexto += AllTrim(aAux[n][2])+"&"
					Else
						cAuxTexto += cTexto
						cTexto += CR
						cTexto:=""
					EndIf
				EndIf
			Next n
		ElseIf aCampos[i][8] == "X"
			aAux:= aDados[i][1]
			For n:=1 To Len(aAux)
				If aAux[n][2]							// Marcado
					If Empty(cFator)					// Cod do Fator
						cFator := aAux[n][4]
						cTexto := cFator+"&"
					EndIf
					If cFator # aAux[n][4]
						cAuxTexto += cTexto
						cTexto += CR

						Rs090Array(@aGrava,aCampos,i,cAuxTexto)
						cAuxTexto:= ""
						cFator 	:= aAux[n][4]
						cTexto	:= cFator+"&"
					EndIf
					If Len(cTexto)+ nTam <= 80
						cTexto += Alltrim(aAux[n][5])+"&"  // Grau
						cTexto += Alltrim(aAux[n][6])+"&"  // Grupo
					Else
						cAuxTexto += cTexto
						cTexto += CR

						Rs090Array(@aGrava,aCampos,i,cAuxTexto)
						cAuxTexto:= ""
						cTexto	:=cFator+"&"
					EndIf
				EndIf
			Next n
		EndIf

		dbSelectArea("SX3")
		dbSetOrder(2)
		dbSeek(aCampos[i][2])

		nContador += 1

		reclock('RT0',.T.)
		RT0->RT0_FILIAL := Fwxfilial('RT0')
		RT0->RT0_SEQ    := nContador
		RT0->RT0_TELA   := 'RSPA090'
		RT0->RT0_PERG   := cNomePerg
		RT0->RT0_CAMPO  := aCampos[i][2]
		RT0->RT0_TIPO   := aCampos[i][8]
		RT0->RT0_TPCMP  := SX3->X3_TIPO
		If RT0->(ColumnPos("RT0_FILTRO")) > 0
			RT0->RT0_FILTRO := aCampos[i][9]
		ENDIF
		MsUnLock()

		MSMM(RT0->RT0_CODM  ,,,cMTexto,1,,,"RT0","RT0_CODM")//MSMM(M->QG_ANALISE,,,M->QG_MEMO1,1,,,"SQG","QG_ANALISE")

		cAuxTexto += cTexto
		cTexto += CR

		Rs090Array(@aGrava,aCampos,i,cAuxTexto)
	Next i

End Transaction

return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LeTabPsq ³ Autor ³ Oswaldo L            ³ Data ³ 03.10.17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ler a configuracao da pesquisa                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function LeTabPsq (aLe, cNomePerg)
Local cRT0Alias := GetNextAlias()
Local aAux      := {}
Local cMTexto   := ""
Local aArea     := GetArea()
Local nCnt      := 1

BeginSql Alias cRT0Alias
	  SELECT RT0.*  FROM 	%table:RT0% RT0
       WHERE RT0.RT0_FILIAL  = %Exp:(Fwxfilial('RT0'))%
		 AND RT0.RT0_TELA    = 'RSPA090   '
		 AND RT0.RT0_PERG    = %Exp:( padr(cNomePerg, TamSx3("RT0_PERG")[1]) )%
		 AND RT0.%NotDel%
		 ORDER BY RT0.RT0_SEQ
EndSql

While (cRT0Alias)->(!Eof())
	RT0->(Dbgoto( (cRT0Alias)->(R_E_C_N_O_) ))

	cMTexto := RHMSMM(RT0->RT0_CODM,,,,  ,,,,,,, 'RT0')

	If Len(cMTexto) > 0

		dbSelectArea("SX3")
		dbSetOrder(2)
		dbSeek(Alltrim((cRT0Alias)->(RT0_CAMPO)))

		aAux :=StrToArray(cMTexto,"&")

		If SX3->X3_TIPO == "C"
			For nCnt := 1 to Len(aAux)
				aAux[nCnt] := padr(aAux[nCnt], TamSx3(Alltrim((cRT0Alias)->(RT0_CAMPO)))[1])
			Next
		EndIf
		IF RT0->(ColumnPos("RT0_FILTRO")) > 0
			Aadd(aLe,{(cRT0Alias)->(RT0_CAMPO),(cRT0Alias)->(RT0_TIPO),aAux,'', (cRT0Alias)->(RT0_FILTRO)})
		ELSE
			Aadd(aLe,{(cRT0Alias)->(RT0_CAMPO),(cRT0Alias)->(RT0_TIPO),aAux,''})
		ENDIF
	EndIf

	(cRT0Alias)->(DbSkip())
End

(cRT0Alias)->(DbCloseArea())

restArea(aArea)
return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GrvDadoTab  ºAutor  ³Oswaldo L                   ³  19/10/17    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Grava informações na tabela generica                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                                 ³±±
±±³          ³                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                         ³±±
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GrvDadoTab(cTabAlias)
Local nCnt       := 0
Local cCabecalho := ""
Local nContador  := 0
Local cLinhaReg  := ''
Local nLoop      := ''
Local aStruct    := {}

	DelDadoTab(cTabAlias, padr(cNomeSalvo,TamSx3("RT0_PERG")[1] ) )

	(cTabAlias)->(DbGoTop())

	aStruct := (cTabAlias)->( dbStruct() )

	If Len(aStruct) > 0
		For nCnt := 1 to Len(aStruct)
			cCabecalho += Alltrim(aStruct[nCnt][1]) + ";"
		Next

		nContador += 1

		reclock('RT1',.T.)
			RT1->RT1_FILIAL := Fwxfilial('RT1')
			RT1->RT1_TELA   := "RSPA090   "
			RT1->RT1_PERG   := cNomeSalvo
			RT1->RT1_SEQ    := nContador
			RT1->RT1_HEAD   := 'S'
		MsUnLock()

		MSMM(RT1_CODM  ,,,cCabecalho,1,,,"RT1","RT1_CODM")

		For nCnt := 1 to Len(aLbx)	// exporta todos + seleção do grid

			cLinhaReg := ''

			For nLoop := 1 to Len(aStruct)
				Do Case
					Case aStruct[nLoop][2] $ "C|M"
						cLinhaReg += AllTrim(aLbx[nCnt][nLoop])

					Case aStruct[nLoop][2] == "L"
						If aLbx[nCnt][nLoop] == .T.
							cLinhaReg += "1"
						Else
							cLinhaReg += "0"
						EndIf

					Case aStruct[nLoop][2] == "N"
						cLinhaReg +=  AllTrim(STR(aLbx[nCnt][nLoop]))

					Case aStruct[nLoop][2] == "D"
						cLinhaReg += dtoc(aLbx[nCnt][nLoop])
				EndCase

				cLinhaReg += ";"
			Next nLoop

			nContador += 1
			reclock('RT1',.T.)
				RT1->RT1_FILIAL := Fwxfilial('RT1')
				RT1->RT1_TELA   := "RSPA090"
				RT1->RT1_PERG   := cNomeSalvo
				RT1->RT1_SEQ    := nContador
				RT1->RT1_HEAD   := 'N'
			MsUnLock()

			MSMM(RT1_CODM  ,,,cLinhaReg,1,,,"RT1","RT1_CODM")

		Next nCnt

	EndIf

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DelDadoTab ºAutor  ³Oswaldo L                    ³  19/10/17    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Deletar conteúdo da tabela                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                                 ³±±
±±³          ³                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                         ³±±
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DelDadoTab(cTabAlias, cPerg)

Begin Transaction
dbSelectArea('RT1')
RT1->(DbSetOrder(1))
RT1->(DbSeek( Fwxfilial('RT1') + "RSPA090   " + cPerg    ))

While RT1->(!Eof()) .And. AllTrim(RT1->(RT1_FILIAL+RT1_TELA+RT1_PERG)) == AllTrim(Fwxfilial('RT1') + "RSPA090   " + cPerg)

	reclock('RT1',.F.)
	RT1->(DbDelete())
	MsUnLock()

	RHMSMM  (RT1->RT1_CODM,,,,2,,,,,,,"RT1")
	RT1->(DbSkip())
End

End Transaction

return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CriaTemporario ºAutor  ³Oswaldo L                ³  19/10/17    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Criação da tabela temporaria de controle                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                                 ³±±
±±³          ³                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                         ³±±
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaTemporario()
Local   aLstIndices := {}
Local   cCabecalho  := ''
Local   a1Stru      := {}
Local   nCnt        := 0
Local   nTamSx3     := TamSx3("RT1_PERG")[1]

Private a1Stru	    := {}

dbSelectArea('RT1')
RT1->(DbSetOrder(1))
RT1->(DbSeek( Fwxfilial('RT1') + "RSPA090   " + padr (cTabEmUso, nTamSx3) + "S"    ))

If RT1->(!Eof()) .And. AllTrim(RT1->(RT1_FILIAL+RT1_TELA+RT1_PERG+RT1_HEAD)) == AllTrim(Fwxfilial('RT1') + "RSPA090   " + padr (cTabEmUso, nTamSx3) + "S")
	cCabecalho := RHMSMM(RT1->RT1_CODM,,,,  ,,,,,,, 'RT1')
	aCabec := StrToArray(cCabecalho,";")
EndIf

Aadd(a1Stru,{"SEL"	  ,"L",01, 0 } )
Aadd(a1Stru,{"CURRIC" ,"C",06, 0 } )
Aadd(a1Stru,{"NOME"   ,"C",40, 0 } )
Aadd(a1Stru,{"FONE"	  ,"C",40, 0 } )
Aadd(a1Stru,{"VAGA"	  ,"C",06, 0 } )

For nCnt := 6 to Len(aCabec)
	dbSelectArea("SX3")
	dbSetOrder(2)

	If dbSeek(aCabec[nCnt])
		Aadd(a1Stru,{aCabec[nCnt],SX3->X3_TIPO, SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	EndIf
Next

oArq1Tmp := RhCriaTrab('TRB', a1Stru, aLstIndices)

If oArq1Tmp != Nil
	FWMsgRun(,{|| LoadTRB(a1Stru)  },OemtoAnsi(STR0083),OemtoAnsi(STR0084))
EndIf

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TelaSelecao ºAutor  ³Oswaldo L                   ³  19/10/17    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Selecao da tabela existente                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                                 ³±±
±±³          ³                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                         ³±±
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function TelaSelecao (lCriaNovaTab)
	Local oDlgSel
	Local oDlg
	Local oGet1
	Local cGet1    := space(TamSx3("RT1_PERG")[1])
	Local oButMarc1
	Local oButMarc2
	Local lMantem  := .T.
	Local lRet     := .F.
	Local lIniciar := .T.
	Local oGet, oPesquisa
	Local aPesquisa	:= {}
	Local cPesquisa	:= ""
	Local nPesq		:= 0
	Local lRet		:= .F.
	Local cvar		:= ""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de arrays para dimensionar tela		             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local cRT1Alias     := GetNextAlias()

	Default lCriaNovaTab := .F.

	If !lCriaNovaTab
		cTabEmUso  := ''
	Else
		cNomeSalvo := ''
	EndIf

	While lMantem

		If !lCriaNovaTab
			If lIniciar
				lIniciar := .F.

				BeginSql Alias cRT1Alias
					SELECT DISTINCT(RT1.RT1_PERG) FROM %table:RT1% RT1
					WHERE RT1.RT1_FILIAL = %Exp:(Fwxfilial('RT1'))%
					AND RT1.RT1_TELA = 'RSPA090   '
					AND RT1.%NotDel%
					ORDER BY RT1.RT1_PERG
				EndSql

				While (cRT1Alias)->(!Eof())
					Aadd(aPesquisa, (cRT1Alias)->(RT1_PERG)  )//SQU->QU_CODIGO+" - "+SQU->QU_DESCRIC)

					(cRT1Alias)->(dbSkip())
				EndDo

				(cRT1Alias)->(dbCloseArea())

				If Len(aPesquisa) == 0
					Return .F.
				EndIf
			EndIf

			aAdvSize		:= MsAdvSize( , .T., 390)
			aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
			aAdd( aObjCoords , { 000 , 000 , .T. , .T., .T. } )
			aObjSize	    := MsObjSize( aInfoAdvSize , aObjCoords )

			SETAPILHA()
			DEFINE MSDIALOG oDlgSel TITLE  OemtoAnsi(STR0067)  FROM aAdvSize[7],0 To aAdvSize[6],aAdvSize[5]  PIXEL//"Selecione uma pesquisa"

				@ aObjSize[1,1],aObjSize[1,2] LISTBOX oPesquisa VAR cVar FIELDS HEADER OemtoAnsi(STR0068) OF oDlgSel PIXEL SIZE aObjSize[1,3],aObjSize[1,4]-15; //"Pesquisas:"
				ON CHANGE (nPesq:=oPesquisa:nAt) ON DBLCLICK (lRet := .T.,oDlgSel:End())
				oPesquisa:SetArray(aPesquisa)
		  		oPesquisa:bLine := { || {aPesquisa[oPesquisa:nAt]}}

			ACTIVATE MSDIALOG oDlgSel ON INIT EnchoiceBar(oDlgSel, {|| lRet:= .T., oDlgSel:End()  },{|| lRet:=.F. ,oDlgSel:End()} ) CENTERED
			SETAPILHA()

			If nPesq > 0
				cGet1 := aPesquisa[nPesq]
			Else
				cGet1 := ''
			EndIf
		Else
			DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0063) From 3,0 to 150 ,400 PIXEL
				@ 5,5  SAY OemtoAnsi(STR0064)  OF oDlg PIXEL
		   		@ 15,5 MSGET oGet1 VAR cGet1    SIZE 70,3 OF oDlg PIXEL

				@ 60, 165 Button oButMarc1 Prompt OemtoAnsi(STR0066) Size 32, 12 Pixel Action ( lRet := .F. , oDlg:End() )  Of oDlg
				@ 60, 130 Button oButMarc2 Prompt OemtoAnsi(STR0065) Size 32, 12 Pixel Action ( lRet := .T. , oDlg:End() )  Of oDlg
			ACTIVATE MSDIALOG oDlg CENTER
		EndIf

		If lRet
			If Empty(cGet1)

				If !lCriaNovaTab
					MsgInfo(OemtoAnsi(STR0055))	// "Informe o nome da tabela para ser utilizada!"
				Else
					MsgInfo(OemtoAnsi(STR0056))	// "Informe o nome da tabela para salvá-la!"
				EndIf

				lRet := .F.
			Else
				If !lCriaNovaTab
					cTabEmUso  := cGet1
				Else
					cNomeSalvo := cGet1
				EndIf
				lMantem := .F.
			EndIf
		Else
			lMantem := .F.
		EndIf
	EndDo

return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LoadTrb ºAutor  ³Oswaldo L                       ³  19/10/17    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Carga da tabela generica                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                                 ³±±
±±³          ³                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA090                                                         ³±±
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function LoadTRB(a1Stru)
Local cItemReg := {}
Local aRegTab  := {}
Local i        := 0
Local nTamSx3  := TamSx3("RT1_PERG")[1]
dbSelectArea('RT1')
RT1->(DbSetOrder(1))
RT1->(DbSeek( Fwxfilial('RT1') + "RSPA090   " + padr (cTabEmUso, nTamSx3) + "N"    ))

While RT1->(!Eof()) .And. AllTrim(RT1->(RT1_FILIAL+RT1_TELA+RT1_PERG)) == AllTrim(Fwxfilial('RT1') + "RSPA090   " + padr (cTabEmUso, nTamSx3))

	If RT1->RT1_HEAD != "S"
		cItemReg := RHMSMM(RT1->RT1_CODM,,,,  ,,,,,,, 'RT1')
		aRegTab  := StrTokArr2(cItemReg,";",.T.)

		RecLock("TRB",.T.)

		For i:=1 To Len(a1Stru)

			If a1Stru[i][2] # "M"

				If a1Stru[i][2] == "D"
					&("TRB->" + a1Stru[i][1]) := ctod(aRegTab[i])
				EndIf

				If a1Stru[i][2] == "N"
					&("TRB->" + a1Stru[i][1]) := Val(aRegTab[i])
				EndIf

				If a1Stru[i][2] == "L"
					If aRegTab[i] == "0"
						&("TRB->" + a1Stru[i][1]) := .F.
					Else
						&("TRB->" + a1Stru[i][1]) := .T.
					EndIf
				EndIf

				If a1Stru[i][2] == "C"
					&("TRB->" + a1Stru[i][1]) := aRegTab[i]
				EndIf
			Else
				&("TRB->" + a1Stru[i][1]) := "***Memo***"
			EndIf

		Next i

		MsUnlock()

	EndIf

	RT1->(DbSkip())
End

return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TabNovaDic ³ Autor ³ Oswaldo L      ³ Data ³ 03.10.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Testa existência da tabela no dicionario                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           Esta rotina cria a tabela, por isto ela nao existe no banco ³±±
±±³           neste ponto ainda. Entao, verificamos pelo dicionario.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static function TabNovaDic ()
Local lRet := .F.

If TCCanOpen(  RETSQLNAME("RT1")   ) .And. TCCanOpen(  RETSQLNAME("RT0")   )
	lRet := .T.
EndIf

return lRet
