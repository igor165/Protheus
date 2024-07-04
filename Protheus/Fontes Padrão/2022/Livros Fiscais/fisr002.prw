#INCLUDE "FISR002.ch"
/*/

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FISR002   ³ Autor ³ Marcos Kato           ³ Data ³ 22.06.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Emiss„o do Livro de Registro de ISS do Mun. Jundiai         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FISR002(void)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³MOTIVO DA ALTERACAO                     ³±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FISR002()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local titulo	:=	""
Local cDesc1	:=	""
Local cDesc2	:=	""
Local cDesc3	:=	""
Local aLinha	:=	{}
Local nomeprog	:=	"FISR002"
Local cNrLivro	:=	""
Local Tamanho	:=	"P"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cString  :=	"SF3"
Local cabec1   :=	""
Local cabec2   :=	""
Local wnrel    :=   "FISR002" // Nome do Arquivo utilizado no Spool
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
Private cPerg   	:=	"FISR002"
Private nPagina		:= 1
Private lEnd    	:= .F.// Controle de cancelamento do relatorio
Private m_pag   	:= 1  // Contador de Paginas
Private nLastKey	:= 0  // Controla o cancelamento da SetPrint e SetDefault
Private Limite 		:= 132
Private aOrdem  	:= {}  // Ordem do Relatorio
Private aReturn 	:= { STR0005, 1,STR0006, 2, 2, 1, "",0 } //"Zebrado"###"Administracao"
//[1] Reservado para Formulario
//[2] Reservado para N§ de Vias
//[3] Destinatario
//[4] Formato => 1-Comprimido 2-Normal
//[5] Midia   => 1-Disco 2-Impressora
//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
//[7] Expressao do Filtro
//[8] Ordem a ser selecionada
//[9]..[10]..[n] Campos a Processar (se houver)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.f.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                ³
//³ mv_par01             // da Data                                     ³
//³ mv_par02             // ate a Data                                  ³
//³ mv_par03             // Pagina Inicial                              ³
//³ mv_par04             // Livro ou Livro+termos ou Termos             ³
//³ mv_par05             // Livro Selecionado                           ³
//³ mv_par06             // Nro do CCM                                  ³
//³ mv_par07             // Total Diario                                ³
//³ mv_par08             // Tipo Totalizacao(Decendial/Quinzenal/Mensal ³
//³ mv_par09             // Imprime Guias de Recolhimento ?		        ³
//³ mv_par10             // Modelo do Registro                          ³
//³ mv_par11             // Nro Processo Reg. Esp.                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lVerpesssen
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDesc1	:=	STR0002 // "Emissao dos Registros de ISS.
	cDesc2	:=	STR0003 // "Ira imprimir os lancamentos fiscais referentes a Imposto Sobre "
	cDesc3	:=	STR0004 // "Servicos, conforme o periodo informado."
	Titulo  :=	STR0007 // "** REGISTRO NOTAS FISCAIS DE SERVICOS PRESTADOS **"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao de Termo / Livro                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
	Case mv_par04==1
		lImpLivro:=.T.
		lImpTermos:=.F.
	Case mv_par04==2
		lImpLivro:=.T.
		lImpTermos:=.T.
	Case mv_par04==3
		lImpLivro:=.F.
		lImpTermos:=.T.
	EndCase

	If lImpLivro // Impressao do Livro
		If mv_par10 == 1 
			Tamanho := "M"
			Limite  := 132
		Else	
			Tamanho := "G"
			Limite  := 220
		EndIf	
	Endif

	wnrel	:=	SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrdem,,Tamanho)

	nPagina	:=	mv_par03
	nPagina	:=	IIF(nPagina<2,2,nPagina)

	If nLastKey==27
		dbClearFilter()
		Return
	EndIf


	SetDefault(aReturn,cString)
	If nLastKey==27
		dbClearFilter()
		Return
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recebe filtro definido pelo usuario                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilterUser	:=	aReturn[7]

	If lImpLivro // Impressao do Livro
		If mv_par10 == 1
			Tamanho := "M"
			Limite  := 132
		Else	
			Tamanho := "G"
			Limite  := 220
		EndIf	
	Endif

	If lImpLivro // Impressao do Livro
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa relatorio                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RptStatus({|lEnd| R990Livr(@lEnd,wnRel,cString,Tamanho,cPerg)},titulo)

	Else

		If lImpTermos
			R002ITer(cPerg)
		EndIf

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura Ambiente                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("SF3")
	dbSetOrder(1)
	If aReturn[5] == 1
		Set Printer TO
		dbCommitAll()
		Ourspool(wnrel)
	EndIf
EndIf	

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³R990Livr  ³ Autor ³ Thiago Galvao Silveira³ Data ³ 01/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Livro de Registro de ISS                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR990()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function R990Livr(lEnd,wnRel,cString,Tamanho,cPerg)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de Variaveis                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cAliasSF3 := "SF3"
Local cAliasTS3 := ""		
Local cAliasSF6 := "SF6"
Local lQuery    :=	.F.
local nX        := 0
local nY        := 0
local nZ        := 0
Local aLay      := Array(40)
Local nLin		:= 0
Local nMes      := ""
Local cMesAno   := ""
Local nPos      := 0
Local nApuracao := mv_par08
Local nMesRec   := ""
Local lControle := .F. 
Local cDFim     := ""
Local nMfim     := ""
Local nTam		:= 0
Local lJoiSC		:=	SM0->M0_ESTENT == "SC" .And. "JOINVILLE" $ Upper(SM0->M0_CIDENT)
Local nMinRetISS	:=	GetNewPar("MV_VRETISS",0)

Local lMapResumo	:= IIF((SuperGetMV("MV_LJLVFIS",,1) == 2) .AND. mv_par13 == 1,.T.,.F.)
Local aMapaResumo	:= 	{}
Local aGravaMapRes	:= 	{}
Local cArqBkpQry	:= 	""
Local cArqTmpMP		:= 	""
Local aCposTemp		:=	{}
Local nFeixe	    := 0
Local nTamNBanco	:= TamSX3('A6_NREDUZ')[1]

#IFDEF TOP
	Local nSF6		:=	0
#ENDIF	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas no cabecalho.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNome	:=	SM0->M0_NOMECOM
cInscr  :=	InscrEst()
cEnd	:=	ALLTRIM(SM0->M0_ENDENT)
cEnd	+= 	iif(len(ALLTRIM(SM0->M0_ENDENT))>0 .and. len(ALLTRIM(SM0->M0_BAIRENT))>0," - ","")
cEnd	+=	ALLTRIM(SM0->M0_BAIRENT)
cEnd	+=	iIf(len(cEnd)>0 .and. len(ALLTRIM(SM0->M0_CIDENT))>0," - ","")
cEnd	+=	ALLTRIM(SM0->M0_CIDENT)
cEnd	+=	iIf(len(cEnd)>0 .AND. len(ALLTRIM(SM0->M0_ESTENT))>0,"/","")
cEnd	+=	ALLTRIM(SM0->M0_ESTENT)
cCGC	:=	TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99")
cCCM	:=	mv_par06
cCodISS := ""
cNproc  := mv_par11

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas nas informacoes.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nDia        := 01
cDia        := ""
cSerie      := ""
cNumNota    := ""
nBaseCalc   := 0.00
nAliq       := ""
nImpIncid   := 0.00
nImpRet     := 0.00
nValIsen    := 0.00
nValNF      := 0.00
cObserv     := ""
cCNPJ       := ""
cRecISS	  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Totalizacao diaria.                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nBaseCalcT  := 0.00
nImpIncidT  := 0.00
nImpRetT    := 0.00
nValIsenT   := 0.00
nValNFT     := 0.00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas no transporte de valor para proxima pagina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nSBaseCalcT := 0.00
nSImpIncidT := 0.00
nSImpRetT   := 0.00
nSValIsenT  := 0.00
nSValNFT    := 0.00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para armazenar as totalizacoes.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDia        := {}
aApurI      := {0,0,0,0,0}
aApurII     := {0,0,0,0,0}
aApurIII    := {0,0,0,0,0}
aTotMes     := {0,0,0,0,0}
aResumo     := {}
nTotImpDev  := 0.00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Controle                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

lResumo      := .F.
lApuracao    := .T.
lApurI       := .F.
lApurII      := .F.
lApurIII     := .F.
lMudouPag    := .F.
lHouveMov    := .F.
lCancNF		 := .F. 
nNumAliq     := 0
nNumDia      := 1
nContrRes    := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Indice Condicional                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasSF3)	

#IFDEF TOP
	If TcSrvType()<>"AS/400"
		lQuery := .T.
		cAliasSF3 := "TF3"		
		aStru  := SF3->(dbStruct())
		cQuery := "SELECT F3_FILIAL,F3_ENTRADA,F3_DTCANC,F3_CODISS,F3_ALIQICM,F3_NFISCAL,F3_SERIE, F3_VALCONT, F3_BASEICM,F3_ISENICM,F3_OUTRICM,F3_FORMULA,F3_OBSERV,F3_CLIEFOR,F3_LOJA,F3_TIPO,F3_CFO,F3_VALICM,R_E_C_N_O_ SF3RECNO"
		cQuery += ", F3_RECISS "

	 	If lMapResumo
			cQuery += ",F3_ESPECIE,F3_TIPO,F3_DTCANC,F3_NRLIVRO " 	
	 		aCposTemp := MaXRCposQry(cQuery)
	 	EndIf

		cQuery += "FROM "+RetSqlName("SF3")+" "
		cQuery += "WHERE F3_FILIAL='"+xFilial("SF3")+"' AND "
		cQuery += "(F3_TIPO = 'S' OR (F3_TIPO = 'L' AND "
		cQuery += "F3_CODISS <> '" + SPACE(LEN(F3_CODISS)) + "'))  AND "
		cQuery += "F3_CFO >'5"+SPACE(LEN(F3_CFO)-1)+"'AND "
		cQuery += "F3_ENTRADA>='"+Dtos(mv_par01)+"' AND "
		cQuery += "F3_ENTRADA<='"+Dtos(mv_par02)+"' AND "
		If mv_par05<>"*"
			cQuery	+=	"F3_NRLIVRO='"+mv_par05+"' AND "
		EndIf
		cQuery += "D_E_L_E_T_ = ' ' "
		CQuery += "ORDER BY F3_CODISS,F3_ENTRADA,F3_SERIE,F3_NFISCAL,F3_ALIQICM"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
		For nX := 1 To len(aStru)
			If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0
				TcSetField(cAliasSF3,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
			EndIf
		Next nX
		dbSelectArea(cAliasSF3)	
	Else

#ENDIF

	cArqInd	:=	CriaTrab(NIL,.F.)
	cChave	:=	"F3_CODISS+DTOS(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+STR(F3_ALIQICM)"
	cFiltro :=  " F3_FILIAL=='"+xFilial()+"' .AND. ( F3_TIPO=='S' .OR. (F3_TIPO=='L' .AND. F3_CODISS<>'"+Space (Len (SF3->F3_CODISS))+"'))"
	cFiltro	+=	" .AND. F3_CFO >='5'"
	cFiltro	+=	" .AND. dtos(F3_ENTRADA) >='"+dtos(mv_par01)+"' .and. dtos(F3_ENTRADA)<='"+dtos(mv_par02)+"'"

	If mv_par05<>"*"
		cFiltro	+=	".AND.F3_NRLIVRO=='"+mv_par05+"'"
	EndIf

	If lMapResumo
		cFiltro	+=	" .AND. Alltrim(F3_ESPECIE) <> 'CF' "
	EndIf

	IndRegua(cAliasSF3,cArqInd,cChave,,cFiltro,STR0008) //"Selecionando Registros..."

	#IFNDEF TOP
		DbSetIndex(cArqInd+OrdBagExt())
	#ENDIF

	(cAliasSF3)->(dbGotop())
	SetRegua(LastRec())

#IFDEF TOP
	EndIf
#ENDIF

R002Lay(@aLay)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inclui informacoes do Mapa Resumo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMapResumo
	cChave			:=	"F3_CODISS+DTOS(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+STR(F3_ALIQICM)"
	cArqBkpQry 		:= 	cAliasSf3

	aMapaResumo		:= 	MaxRMapRes(mv_par01,mv_par02)
	aGravaMapRes	:= 	MaXRAgrupF3(/*cFilAnt*/,aMapaResumo,"MATR990")
	cArqTmpMP		:= 	MaXRExecArq(1)
	cAliasSf3		:=	MaXRAddArq(	1			,	cArqTmpMP	,	cAliasSf3	,	aCposTemp	,;
									aGravaMapRes,	cChave		)

EndIf

While !(cAliasSF3)->(Eof())  

	nLin      := 0
	nMes      := Month((cAliasSF3)->F3_ENTRADA)
	nMesRec   := Month((cAliasSF3)->F3_ENTRADA)	
	cMesAno   := (MesExtenso(Month((cAliasSF3)->F3_ENTRADA)))+"/"+STRZERO(year((cAliasSF3)->F3_ENTRADA),4)
	cCodISS   := (cAliasSF3)->F3_CODISS
	lHouveMov := .T.
	If !lQuery
		IncRegua()
	Endif

	If Interrupcao(@lEnd)
		Exit
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Considera filtro do usuario                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If !Empty(cFilterUser)
		If lQuery
			SF3->(MsGoto((cAliasSF3)->SF3RECNO))
		EndIf
		If SF3->(!(&cFilterUser))
			(cAliasSF3)->(DbSkip ())
			Loop
		EndIf
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cabecalho                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If ( nLin > 60 .Or. nLin == 0 )
		lResumo := .F.
		nFeixe++
		CabMJund(@nLin,aLay,@nPagina,cNome,cInscr,cCCM,cEnd,cMesAno,cCodISS,lResumo,cNproc,@nFeixe)
	EndIf
	// FAZ O TRATAMENTO PARA IMPRESSAO DO TOTALIZADOR POR DIA QDO OS LANCAMENTOS DIARIOS SAO LANCADOS NA PAGINA ANTERIOR  
	If (cDFim <> StrZero(Day((cAliasSF3)->F3_ENTRADA),2) .AND. cDFim <> "" .AND. nMFim == Month((cAliasSF3)->F3_ENTRADA))  .OR. cCodISS <> (cAliasSF3)->F3_CODISS .Or. nMes<>Month((cAliasSF3)->F3_ENTRADA)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena Totais Diarios                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AADD(aDia,{cDia,nValNFT,nBaseCalcT,nImpIncidT,nImpRetT,nValIsenT})

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena Totais Decendiais ou Quinzenais                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nApuracao == 1
				If nDia <= 10
					aApurI := {aApurI[1]+nValNFT,aApurI[2]+nBaseCalcT,aApurI[3]+nImpIncidT,aApurI[4]+nImpRetT,aApurI[5]+nValIsenT}
				ElseIf nDia >= 11 .AND. nDia <= 20
					aApurII := {aApurII[1]+nValNFT,aApurII[2]+nBaseCalcT,aApurII[3]+nImpIncidT,aApurII[4]+nImpRetT,aApurII[5]+nValIsenT}
				ElseIf nDia >= 21
					aApurIII := {aApurIII[1]+nValNFT,aApurIII[2]+nBaseCalcT,aApurIII[3]+nImpIncidT,aApurIII[4]+nImpRetT,aApurIII[5]+nValIsenT}
				EndIf
			ElseIf nApuracao == 2
				If nDia <= 15
					aApurI := {aApurI[1]+nValNFT,aApurI[2]+nBaseCalcT,aApurI[3]+nImpIncidT,aApurI[4]+nImpRetT,aApurI[5]+nValIsenT}
				ElseIf nDia >= 16
					aApurII := {aApurII[1]+nValNFT,aApurII[2]+nBaseCalcT,aApurII[3]+nImpIncidT,aApurII[4]+nImpRetT,aApurII[5]+nValIsenT}
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena Totais Mensais                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aTotMes := {aTotMes[1]+nValNFT,aTotMes[2]+nBaseCalcT,aTotMes[3]+nImpIncidT,aTotMes[4]+nImpRetT,aTotMes[5]+nValIsenT}
           
	   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Controle de fim de pagina                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nLin >= 57
				If cCodISS == (cAliasSF3)->F3_CODISS
					lMudouPag := .T.
				EndIf
				If nLin == 58
					FmtLin(,aLay[16],,,@nLin)
					If !lMudouPag
						FmtLin({TransForm(aTotMes[1],"@e 9,999,999,999.99"),TransForm(aTotMes[2],"@e 9,999,999,999.99"),TransForm(aTotMes[3],"@e 99,999,999.99"),TransForm(aTotMes[4],"@e 99,999,999.99"),TransForm(aTotMes[5],"@e 99,999,999.99")},aLay[17],,,@nLin)
					Else
						FmtLin({TransForm(nSValNFT,"@e 9,999,999,999.99"),TransForm(nSBaseCalcT,"@e 9,999,999,999.99"),TransForm(nSImpIncidT,"@e 99,999,999.99"),TransForm(nSImpRetT,"@e 99,999,999.99"),TransForm(nSValIsenT,"@e 999,999,999.99")},aLay[27],,,@nLin)
						lMudouPag := .F.
					EndIf
					FmtLin(,aLay[18],,,@nLin)
				EndIf
				nLin:= 0
				nFeixe++
				CabMJund(@nLin,aLay,@nPagina,cNome,cInscr,cCCM,cEnd,cMesAno,cCodISS,lResumo,cNproc,@nFeixe)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Imprime Totais Diarios                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If mv_par07 == 1  
			    FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
				FmtLin({TransForm(aDia[nNumDia][1],"@e 99"),Transform((aDia[nNumDia][2]),"@e 9,999,999,999.99"),Transform((aDia[nNumDia][3]),"@e 9,999,999,999.99"),TransForm((aDia[nNumDia][4]),"@e 99,999,999.99"),TransForm((aDia[nNumDia][5]),"@e 99,999,999.99"),TransForm((aDia[nNumDia][6]),"@e 99,999,999.99")},aLay[26],,,@nLin)
				FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
			ElseIf nApuracao <> 3

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Imprime Totais Decendiais ou Quinzenais                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If nApuracao == 1
					If aApurI[1]+aApurI[2]+aApurI[3]+aApurI[4]+aApurI[5] > 0 .AND. lApurI
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurI[1],"@e 9,999,999,999.99"),TransForm(aApurI[2],"@e 9,999,999,999.99"),TransForm(aApurI[3],"@e 99,999,999.99"),TransForm(aApurI[4],"@e 99,999,999.99"),TransForm(aApurI[5],"@e 99,999,999.99")},aLay[29],,,@nLin)
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurI   := {0,0,0,0,0}
					EndIf
					If aApurII[1]+aApurII[2]+aApurII[3]+aApurII[4]+aApurII[5] > 0 .AND. lApurII
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurII[1],"@e 9,999,999,999.99"),TransForm(aApurII[2],"@e 9,999,999,999.99"),TransForm(aApurII[3],"@e 99,999,999.99"),TransForm(aApurII[4],"@e 99,999,999.99"),TransForm(aApurII[5],"@e 99,999,999.99"),TransForm(aApurII[5],"@e 99,999,999.99")},aLay[30],,,@nLin)
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurII  := {0,0,0,0,0}
					EndIf
					If aApurIII[1]+aApurIII[2]+aApurIII[3]+aApurIII[4]+aApurIII[5] > 0 .AND. lApurIII
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurIII[1],"@e 9,999,999,999.99"),TransForm(aApurIII[2],"@e 9,999,999,999.99"),TransForm(aApurIII[3],"@e 99,999,999.99"),TransForm(aApurIII[4],"@e 99,999,999.99"),TransForm(aApurIII[5],"@e 99,999,999.99"),TransForm(aApurIII[5],"@e 99,999,999.99")},aLay[31],,,@nLin)
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurIII   := {0,0,0,0,0}
					EndIf
				Else
					If aApurI[1]+aApurI[2]+aApurI[3]+aApurI[4]+aApurI[5] > 0 .AND. lApurI
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurI[1],"@e 9,999,999,999.99"),TransForm(aApurI[2],"@e 9,999,999,999.99"),TransForm(aApurI[3],"@e 99,999,999.99"),TransForm(aApurI[4],"@e 99,999,999.99"),TransForm(aApurI[5],"@e 99,999,999.99")},aLay[32],,,@nLin)
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurI   := {0,0,0,0,0}
					EndIf
					If aApurII[1]+aApurII[2]+aApurII[3]+aApurII[4]+aApurII[5] > 0 .AND. lApurII
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurII[1],"@e 9,999,999,999.99"),TransForm(aApurII[2],"@e 9,999,999,999.99"),TransForm(aApurII[3],"@e 99,999,999.99"),TransForm(aApurII[4],"@e 99,999,999.99"),TransForm(aApurII[5],"@e 99,999,999.99")},aLay[33],,,@nLin)						
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurII  := {0,0,0,0,0}
					EndIf
				EndIf
			EndIf
			cDia := StrZero(Day((cAliasSF3)->F3_ENTRADA),2)
			nNumDia    += 1
			nBaseCalcT  := 0.00
			nImpIncidT  := 0.00
			nImpRetT    := 0.00
			nValIsenT   := 0.00
			nValNFT     := 0.00
		EndIf


	While cCodISS == (cAliasSF3)->F3_CODISS .AND. !Eof() .And. nMes==Month((cAliasSF3)->F3_ENTRADA) .And. nLin <= 57

		#IFDEF TOP
			dbSelectArea("SF3")
			dbSetOrder(4)
			dbSeek(xFilial("SF3")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE)
		#ENDIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Considera filtro do usuario                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cFilterUser)
			If lQuery
				SF3->(MsGoto((cAliasSF3)->SF3RECNO))
			EndIf
			If SF3->(!(&cFilterUser))
				(cAliasSF3)->(DbSkip ())
				Loop
			EndIf
		Endif



		nDia := Day((cAliasSF3)->F3_ENTRADA)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Armazena e Totaliza as Informacoes                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty((cAliasSF3)->F3_dtcanc)

			cCNPJ		:= R002Cnpj( (cAliasSF3)->F3_CLIEFOR, (cAliasSF3)->F3_LOJA, (cAliasSF3)->F3_TIPO, (cAliasSF3)->F3_CFO)

			If !Empty  ((cAliasSF3)->F3_RECISS)
				cRecIss :=If((cAliasSF3)->F3_RECISS$"12",If((cAliasSF3)->F3_RECISS=="1","S","N"),(cAliasSF3)->F3_RECISS)
			Else
				cRecIss	:= R002ISS( (cAliasSF3)->F3_CLIEFOR, (cAliasSF3)->F3_LOJA, (cAliasSF3)->F3_TIPO, (cAliasSF3)->F3_CFO)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Para o municipio de Joinville/SC, caso o movimento seja classificado  ³
			//³como ISSQN retido:                                                    ³
			//³ENTRADAS: somente devera ser apresentado no relatorio                 ³
			//³          se o valor realmente tiver sido retido, ou seja,            ³
			//³          caso o valor do ISSQN seja maior que o contido              ³
			//³          no parametro MV_VRETISS                                     ³
			//³SAIDAS:   Quando o valor do ISSQN nao alcancar o minimo               ³
			//³          para retencao (definido no parametro MV_VRETISS),           ³
			//³          devera ser lancado como imposto a pagar, visto que e        ³
			//³          dispensada a retencao de valores menores que R$ 25,00       ³
			//³          para quem esta adquirindo o servico.                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lJoiSC .And. (cAliasSF3)->F3_VALICM < nMinRetISS              
				If cRecIss == "S"
					cRecIss := "N"
				Endif
			Endif
			cDia         := StrZero(Day((cAliasSF3)->F3_ENTRADA),2)
			cSerie       := (cAliasSF3)->F3_SERIE
			cNumNota     := (cAliasSF3)->F3_NFISCAL
			nBaseCalc    := (cAliasSF3)->F3_BASEICM
			nAliq        := (cAliasSF3)->F3_ALIQICM
			If cRecIss == "S"
				nImpRet   := (cAliasSF3)->F3_VALICM
				nImpIncid := 0.00
			Else
				nImpRet   := 0.00
				nImpIncid := IIF(subs((cAliasSF3)->F3_CFO,1,1)>="5",(cAliasSF3)->F3_VALICM,0.00)
			Endif	
			nValIsen     := (cAliasSF3)->F3_ISENICM
			nValNF       := (cAliasSF3)->F3_VALCONT
			cObserv      := IIF (!Empty((cAliasSF3)->F3_FORMULA),Formula((cAliasSF3)->F3_FORMULA),(cAliasSF3)->F3_OBSERV)	


			nBaseCalcT   += (cAliasSF3)->F3_BASEICM
			If cRecIss == "S"
				nImpIncidT   += 0.00
				nImpRetT     += (cAliasSF3)->F3_VALICM
				nSImpIncidT  += 0.00
				nSImpRetT    += (cAliasSF3)->F3_VALICM
			Else
				nImpIncidT   += IIF(subs((cAliasSF3)->F3_CFO,1,1)>="5",(cAliasSF3)->F3_VALICM,0.00)
				nImpRetT     += 0.00
				nSImpIncidT  += IIF(subs((cAliasSF3)->F3_CFO,1,1)>="5",(cAliasSF3)->F3_VALICM,0.00)
				nSImpRetT    += 0.00
			Endif
			nValIsenT    += (cAliasSF3)->F3_ISENICM  
			nValNFT      += (cAliasSF3)->F3_VALCONT

			nSBaseCalcT  += (cAliasSF3)->F3_BASEICM
			nSValIsenT   += (cAliasSF3)->F3_ISENICM
			nSValNFT     += (cAliasSF3)->F3_VALCONT

		Else                                                                          
			cCNPJ		 := R002Cnpj( (cAliasSF3)->F3_CLIEFOR, (cAliasSF3)->F3_LOJA, (cAliasSF3)->F3_TIPO, (cAliasSF3)->F3_CFO)
			lCancNF		 := .F.	
			//Se for a mesma nota cancelada, desconsiderar a impressao da linha 
			If cSerie==(cAliasSF3)->F3_SERIE .And. cNumNota == (cAliasSF3)->F3_NFISCAL
				lCancNF		 := .T. 	
			Endif
			cDia         := StrZero(Day((cAliasSF3)->F3_ENTRADA),2)
			cSerie       := (cAliasSF3)->F3_SERIE
			cNumNota 	 := (cAliasSF3)->F3_NFISCAL	
			nBaseCalc    := 0.00
			nAliq        := 0.00
			nImpIncid    := 0.00
			nImpRet      := 0.00
			nValIsen     := 0.00
			nValNF       := 0.00
			cObserv      := (cAliasSF3)->F3_OBSERV

			nBaseCalcT   += 0.00
			nImpIncidT   += 0.00
			nImpRetT     += 0.00
			nValIsenT    += 0.00
			nValNFT      += 0.00

			nSImpIncidT  += 0.00
			nSImpRetT    += 0.00
			nSBaseCalcT  += 0.00
			nSValIsenT   += 0.00
			nSValNFT     += 0.00
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime as Informacoes                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par10 == 1 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para quebra de linha qdo o campo obs for muito extenso ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			cObserv:= Iif(cObserv<>Nil,ALLTRIM(cObserv)," ")
		//	nlinha := Mlcount(cObserv,30)
			nlinha := Mlcount(cObserv,23)
			If nLinha>0
			    For nZ := 1 To nLinha 
			    //	nTam:= Iif(nZ=1,30,(nZ-1)*30)
			    	nTam:= Iif(nZ=1,23,(nZ-1)*23)
			    	If nLin == 58 .And. nZ<=nLinha  
			       		lControle := .T.                             
				   		cDFim := StrZero(Day((cAliasSF3)->F3_ENTRADA),2) 
			   			nMFim := Month((cAliasSF3)->F3_ENTRADA)
						Exit
					EndIf
					If nZ == 1 
						If !lCancNF
							//Imprime a primeira linha com todos os campos
							FmtLin({cDia,cSerie,cNumNota,TransForm(nValNF,"@e 9,999,999,999.99"),TransForm(nBaseCalc,"@e 9,999,999,999.99"),Transform(nAliq,"@e 99.99"),TransForm(nImpIncid,"@e 99,999,999.99"),TransForm(nImpRet,"@e 99,999,999.99"),TransForm(nValisen,"@e 99,999,999.99"),Substr(cObserv,1,nTam)},aLay[15],,,@nLin)
						Endif
						lCancNF:=.F.					
					Else
						FmtLin({"","","","","","","","","",Substr(cObserv,nTam+1,26)},aLay[15],,,@nLin)					
					Endif					
			    Next nZ
		    Else                   
				FmtLin({cDia,cSerie,cNumNota,TransForm(nValNF,"@e 9,999,999,999.99"),TransForm(nBaseCalc,"@e 9,999,999,999.99"),Transform(nAliq,"@e 99.99"),TransForm(nImpIncid,"@e 99,999,999.99"),TransForm(nImpRet,"@e 99,999,999.99"),TransForm(nValisen,"@e 99,999,999.99"),Substr(cObserv,1,nTam)},aLay[15],,,@nLin)		    
		    Endif
		Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para quebra de linha qdo o campo obs for muito extenso ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			cObserv:= Iif(cObserv<>Nil,cObserv," ")
			nlinha := Mlcount(cObserv,74)
			If nLinha>0
			    For nZ := 1 To nLinha 
			    	nTam:= Iif(nZ=1,74,(nZ-1)*74)
			    	If nLin == 58 .And. nZ<=nLinha  
			       		lControle := .T.  
				   		cDFim := StrZero(Day((cAliasSF3)->F3_ENTRADA),2) 
			   			nMFim := Month((cAliasSF3)->F3_ENTRADA)
					  	Exit
					EndIf
					If nZ == 1 
						If !lCancNF
							//Imprime a primeira linha com todos os campos
							FmtLin({cDia,cSerie,cNumNota,cCnpj,TransForm(nValNF,"@e 9,999,999,999.99"),TransForm(nBaseCalc,"@e 9,999,999,999.99"),Transform(nAliq,"@e 99.99"),TransForm(nImpIncid,"@e 99,999,999.99"),TransForm(nImpRet,"@e 99,999,999.99"),TransForm(nValisen,"@e 99,999,999.99"),Substr(cObserv,1,nTam)},aLay[15],,,@nLin)
						Endif
						lCancNF:=.F.					
					Else
						FmtLin({"","","","","","","","","","",Substr(cObserv,nTam+1,74)},aLay[15],,,@nLin)					
					Endif					
			    Next nZ
			Else
				FmtLin({cDia,cSerie,cNumNota,cCNPJ,TransForm(nValNF,"@e 9,999,999,999.99"),TransForm(nBaseCalc,"@e 9,999,999,999.99"),Transform(nAliq,"@e 99.99"),TransForm(nImpIncid,"@e 99,999,999.99"),TransForm(nImpRet,"@e 99,999,999.99"),TransForm(nValisen,"@e 99,999,999.99"),Substr(cObserv,1,nTam)},aLay[15],,,@nLin)		    
		    Endif
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Armazena Valores para Resumo por Aliquota                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If nAliq <> 0 .And. cRecIss <> "S"
			nPos :=Ascan(aResumo,{|x|x[2]==nAliq})
			If nPos==0
				AADD(aResumo,{nBaseCalc,nAliq,nImpIncid})
				nNumAliq     += 1
			Else
				aResumo[nPos,1] +=nBaseCalc
				aResumo[nPos,3] +=nImpIncid
			Endif
		EndIf

		If nLin == 58 .And. nZ<>nlinha
			lControle := .T.  
			cDFim := StrZero(Day((cAliasSF3)->F3_ENTRADA),2) 
			nMFim := Month((cAliasSF3)->F3_ENTRADA)
			(cAliasSF3)->(DbSkip())
			Exit
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Faz a Impressao do registro na proxima pagina                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nLin == 58
				FmtLin(,aLay[16],,,@nLin)
				If nMes <> Month((cAliasSF3)->F3_ENTRADA) //.Or. cCodISS == (cAliasSF3)->F3_CODISS
					FmtLin({TransForm(aTotMes[1],"@e 9,999,999,999.99"),TransForm(aTotMes[2],"@e 9,999,999,999.99"),TransForm(aTotMes[3],"@e 99,999,999.99"),TransForm(aTotMes[4],"@e 99,999,999.99"),TransForm(aTotMes[5],"@e 99,999,999.99")},aLay[17],,,@nLin)
				Else
					FmtLin({TransForm(nSValNFT,"@e 9,999,999,999.99"),TransForm(nSBaseCalcT,"@e 9,999,999,999.99"),TransForm(nSImpIncidT,"@e 99,999,999.99"),TransForm(nSImpRetT,"@e 99,999,999.99"),TransForm(nSValIsenT,"@e 999,999,999.99")},aLay[27],,,@nLin)
					lMudouPag := .F.
				EndIf
				FmtLin(,aLay[18],,,@nLin)
				nLin:= 0
				nFeixe++
				CabMJund(@nLin,aLay,@nPagina,cNome,cInscr,cCCM,cEnd,cMesAno,cCodISS,lResumo,cNproc,@nFeixe) 
    			
    			If mv_par10 == 1
    			   If nZ == 1 
						//Imprime a primeira linha com todos s campos
    			   		FmtLin({cDia,cSerie,cNumNota,TransForm(nValNF,"@e 9,999,999,999.99"),TransForm(nBaseCalc,"@e 9,999,999,999.99"),Transform(nAliq,"@e 99.99"),TransForm(nImpIncid,"@e 99,999,999.99"),TransForm(nImpRet,"@e 99,999,999.99"),TransForm(nValisen,"@e 99,999,999.99"),Substr(cObserv,1,nTam)},aLay[15],,,@nLin)  
    				Else  
						FmtLin({"","","","","","","","","","",Substr(cObserv,nTam+1,74)},aLay[15],,,@nLin)					
					Endif					
    			Else          
    				If nZ == 1 
	    		   		FmtLin({cDia,cSerie,cNumNota,cCNPJ,TransForm(nValNF,"@e 9,999,999,999.99"),TransForm(nBaseCalc,"@e 9,999,999,999.99"),Transform(nAliq,"@e 99.99"),TransForm(nImpIncid,"@e 99,999,999.99"),TransForm(nImpRet,"@e 99,999,999.99"),TransForm(nValisen,"@e 99,999,999.99"),Substr(cObserv,1,nTam)},aLay[15],,,@nLin)
		    		Else
			    		FmtLin({"","","","","","","","","","",Substr(cObserv,nTam+1,74)},aLay[15],,,@nLin)					
					Endif					
	    		Endif  
	    			
 			EndIf
		EndIf

		(cAliasSF3)->(DbSkip())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³O While abaixo tem como finalidade caso a rotina possua filtro, garantir que os totalizadores finais sejam gerados com valores.          ³
		//³Ocorria que quando possuiamos 3 notas ficais de prestacao de servico no mesmo periodo para o mesmo produto/cliente com series diferentes,³
		//³ e emitissemos o relatorio utilizando filtro para gerar somente 2 dessas 3 notas, os totalizadores sairiam zerados.                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do While !(cAliasSF3)->(Eof ())
			If !(Empty (cFilterUser))
				If (lQuery)
					SF3->(MsGoto ((cAliasSF3)->SF3RECNO))
				EndIf
				If SF3->(!(&cFilterUser))
					(cAliasSF3)->(DbSkip ())
					Loop
				Else
					Exit
				EndIf
			Else
				Exit
			EndIf
			//
			(cAliasSF3)->(DbSkip ())
		EndDo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Controle do periodo da Apuracao                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If nApuracao == 1
			IF Day((cAliasSF3)->F3_ENTRADA) >= 11 .OR. (cCodISS <> (cAliasSF3)->F3_CODISS) .Or. nMes<>Month((cAliasSF3)->F3_ENTRADA)
				lApurI   := .T.
			EndIf
			If Day((cAliasSF3)->F3_ENTRADA) >= 21 .OR. (cCodISS <> (cAliasSF3)->F3_CODISS) .Or. nMes<>Month((cAliasSF3)->F3_ENTRADA)
				lApurII  := .T.
			EndIf
			If cCodISS <> (cAliasSF3)->F3_CODISS .Or. nMes<>Month((cAliasSF3)->F3_ENTRADA)
				lApurIII := .T.
			EndIF
		EndIf
		If nApuracao == 2
			IF Day((cAliasSF3)->F3_ENTRADA) >= 16 .OR. (cCodISS <> (cAliasSF3)->F3_CODISS) .Or. nMes<>Month((cAliasSF3)->F3_ENTRADA)
				lApurI   := .T.
			EndIf
			If cCodISS <> (cAliasSF3)->F3_CODISS .Or. nMes<>Month((cAliasSF3)->F3_ENTRADA)
				lApurII  := .T.
			EndIF
		EndIf

		If cDia <> StrZero(Day((cAliasSF3)->F3_ENTRADA),2) .OR. cCodISS <> (cAliasSF3)->F3_CODISS .Or. nMes<>Month((cAliasSF3)->F3_ENTRADA)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena Totais Diarios                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AADD(aDia,{cDia,nValNFT,nBaseCalcT,nImpIncidT,nImpRetT,nValIsenT})

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena Totais Decendiais ou Quinzenais                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nApuracao == 1
				If nDia <= 10   
				                                                                                                      
					aApurI := {aApurI[1]+nValNFT,aApurI[2]+nBaseCalcT,aApurI[3]+nImpIncidT,aApurI[4]+nImpRetT,aApurI[5]+nValIsenT}
				ElseIf nDia >= 11 .AND. nDia <= 20
					aApurII := {aApurII[1]+nValNFT,aApurII[2]+nBaseCalcT,aApurII[3]+nImpIncidT,aApurII[4]+nImpRetT,aApurII[5]+nValIsenT}
				ElseIf nDia >= 21
					aApurIII := {aApurIII[1]+nValNFT,aApurIII[2]+nBaseCalcT,aApurIII[3]+nImpIncidT,aApurIII[4]+nImpRetT,aApurIII[5]+nValIsenT}
				EndIf
			ElseIf nApuracao == 2
				If nDia <= 15
					aApurI := {aApurI[1]+nValNFT,aApurI[2]+nBaseCalcT,aApurI[3]+nImpIncidT,aApurI[4]+nImpRetT,aApurI[5]+nValIsenT}
				ElseIf nDia >= 16
					aApurII := {aApurII[1]+nValNFT,aApurII[2]+nBaseCalcT,aApurII[3]+nImpIncidT,aApurII[4]+nImpRetT,aApurII[5]+nValIsenT}
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Armazena Totais Mensais                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aTotMes := {aTotMes[1]+nValNFT,aTotMes[2]+nBaseCalcT,aTotMes[3]+nImpIncidT,aTotMes[4]+nImpRetT,aTotMes[5]+nValIsenT}

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Controle de fim de pagina                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nLin >= 57 
				While nLin <= 57
					FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
				EndDo
				If cCodISS == (cAliasSF3)->F3_CODISS
					lMudouPag := .T.
				EndIf
				If nLin == 58
					FmtLin(,aLay[16],,,@nLin)
					If !lMudouPag
						FmtLin({TransForm(aTotMes[1],"@e 9,999,999,999.99"),TransForm(aTotMes[2],"@e 9,999,999,999.99"),TransForm(aTotMes[3],"@e 99,999,999.99"),TransForm(aTotMes[4],"@e 99,999,999.99"),TransForm(aTotMes[5],"@e 99,999,999.99")},aLay[17],,,@nLin)
					Else
						FmtLin({TransForm(nSValNFT,"@e 9,999,999,999.99"),TransForm(nSBaseCalcT,"@e 9,999,999,999.99"),TransForm(nSImpIncidT,"@e 99,999,999.99"),TransForm(nSImpRetT,"@e 99,999,999.99"),TransForm(nSValIsenT,"@e 999,999,999.99")},aLay[27],,,@nLin)
						lMudouPag := .F.
					EndIf
					FmtLin(,aLay[18],,,@nLin)
				EndIf
				nLin:= 0
				nFeixe++
				CabMJund(@nLin,aLay,@nPagina,cNome,cInscr,cCCM,cEnd,cMesAno,cCodISS,lResumo,cNproc,@nFeixe)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Imprime Totais Diarios                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If mv_par07 == 1
				FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
				FmtLin({TransForm(aDia[nNumDia][1],"@e 99"),TransForm((aDia[nNumDia][2]),"@e 9,999,999,999.99"),Transform((aDia[nNumDia][3]),"@e 9,999,999,999.99"),TransForm((aDia[nNumDia][4]),"@e 99,999,999.99"),TransForm((aDia[nNumDia][5]),"@e 99,999,999.99"),TransForm((aDia[nNumDia][6]),"@e 99,999,999.99")},aLay[26],,,@nLin)
				FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)

			ElseIf nApuracao <> 3

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Imprime Totais Decendiais ou Quinzenais                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If nApuracao == 1
					If aApurI[1]+aApurI[2]+aApurI[3]+aApurI[4]+aApurI[5] > 0 .AND. lApurI
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurI[1],"@e 9,999,999,999.99"),TransForm(aApurI[2],"@e 9,999,999,999.99"),TransForm(aApurI[3],"@e 99,999,999.99"),TransForm(aApurI[4],"@e 99,999,999.99"),TransForm(aApurI[5],"@e 99,999,999.99")},aLay[29],,,@nLin)
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurI   := {0,0,0,0,0}
					EndIf
					If aApurII[1]+aApurII[2]+aApurII[3]+aApurII[4]+aApurII[5] > 0 .AND. lApurII
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurII[1],"@e 9,999,999,999.99"),TransForm(aApurII[2],"@e 9,999,999,999.99"),TransForm(aApurII[3],"@e 99,999,999.99"),TransForm(aApurII[4],"@e 99,999,999.99"),TransForm(aApurII[5],"@e 99,999,999.99")},aLay[30],,,@nLin)
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurII  := {0,0,0,0,0}
					EndIf
					If aApurIII[1]+aApurIII[2]+aApurIII[3]+aApurIII[4]+aApurIII[5] > 0 .AND. lApurIII
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurIII[1],"@e 9,999,999,999.99"),TransForm(aApurIII[2],"@e 9,999,999,999.99"),TransForm(aApurIII[3],"@e 99,999,999.99"),TransForm(aApurIII[4],"@e 99,999,999.99"),TransForm(aApurIII[5],"@e 99,999,999.99")},aLay[31],,,@nLin)
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurIII   := {0,0,0,0,0}
					EndIf
				Else
					If aApurI[1]+aApurI[2]+aApurI[3]+aApurI[4]+aApurI[5] > 0 .AND. lApurI
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurI[1],"@e 9,999,999,999.99"),TransForm(aApurI[2],"@e 9,999,999,999.99"),TransForm(aApurI[3],"@e 99,999,999.99"),TransForm(aApurI[4],"@e 99,999,999.99"),TransForm(aApurI[5],"@e 99,999,999.99")},aLay[32],,,@nLin)
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurI   := {0,0,0,0,0}
					EndIf
					If aApurII[1]+aApurII[2]+aApurII[3]+aApurII[4]+aApurII[5] > 0 .AND. lApurII
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						FmtLin({TransForm(aApurII[1],"@e 9,999,999,999.99"),TransForm(aApurII[2],"@e 9,999,999,999.99"),TransForm(aApurII[3],"@e 99,999,999.99"),TransForm(aApurII[4],"@e 99,999,999.99"),TransForm(aApurII[5],"@e 99,999,999.99")},aLay[33],,,@nLin)
						FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
						aApurII  := {0,0,0,0,0}
					EndIf
				EndIf
			EndIf
			cDia := StrZero(Day((cAliasSF3)->F3_ENTRADA),2)
			nNumDia    += 1
			nBaseCalcT  := 0.00
			nImpIncidT  := 0.00
			nImpRetT    := 0.00
			nValIsenT   := 0.00
			nValNFT     := 0.00
		EndIf
	EndDo
	lApurI    := .F.
	lApurII   := .F.
	lApurIII  := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime Total Mensal                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While nLin <= 57
		FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
	EndDo
	If nLin == 58
		FmtLin(,aLay[16],,,@nLin)
		If cCodISS == (cAliasSF3)->F3_CODISS
			// Para controlar a impressao de um mesmo codigo ISS em meses distintos
			If nMes <> Month((cAliasSF3)->F3_ENTRADA)
				lMudouPag := .F.
			Else
				lMudouPag := .T.
			Endif
		Else
			lMudouPag := .F.				
		EndIf		
		If !lMudouPag
			If lControle 
				aTotMes := {aTotMes[1]+nValNFT,aTotMes[2]+nBaseCalcT,aTotMes[3]+nImpIncidT,aTotMes[4]+nImpRetT,aTotMes[5]+nValIsenT}	
				nBaseCalcT	:= 0.00
				nImpIncidT	:= 0.00
				nImpRetT	:= 0.00
				nValIsenT	:= 0.00
				nValNFT	    := 0.00
				lControle	:= .F.
			Endif
			FmtLin({TransForm(aTotMes[1],"@e 9,999,999,999.99"),TransForm(aTotMes[2],"@e 9,999,999,999.99"),TransForm(aTotMes[3],"@e 99,999,999.99"),TransForm(aTotMes[4],"@e 99,999,999.99"),TransForm(aTotMes[5],"@e 99,999,999.99")},aLay[17],,,@nLin)
			aTotMes  := {0,0,0,0,0}
		Else
			FmtLin({TransForm(nSValNFT,"@e 9,999,999,999.99"),TransForm(nSBaseCalcT,"@e 9,999,999,999.99"),TransForm(nSImpIncidT,"@e 99,999,999.99"),TransForm(nSImpRetT,"@e 99,999,999.99"),TransForm(nSValIsenT,"@e 999,999,999.99")},aLay[27],,,@nLin)
			lMudouPag := .F.
		EndIf
		FmtLin(,aLay[18],,,@nLin)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime Resumo                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If cCodISS <> (cAliasSF3)->F3_CODISS
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando mudar o codigo de ISS, os totalizadores de saldo a transportar deverao ser zerados.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nSBaseCalcT	:= 0
		nSImpIncidT	:= 0
		nSImpRetT	:= 0
		nSValIsenT	:= 0
		nSValNFT	:= 0
		cCodISS 	:= ""
	
		If nMes <> Month((cAliasSF3)->F3_ENTRADA)
			lResumo := .T.
			nMes    := Month((cAliasSF3)->F3_ENTRADA)
			nLin    := 0
			@ nLin,000 Psay aValImp(Limite)
			nFeixe++
			CabMJund(@nLin,aLay,@nPagina,cNome,cInscr,cCCM,cEnd,cMesAno,cCodISS,lResumo,cNproc,@nFeixe)
			FmtLin(,aLay[19],,,@nLin)
			FmtLin(,aLay[20],,,@nLin)
			FmtLin(,aLay[21],,,@nLin)
			FmtLin(,aLay[22],,,@nLin)
	
			ASort(aResumo,,,{|x,y|x[2]<y[2]})
	
			While nNumAliq >= nContrRes
				FmtLin({TransForm(aResumo[nContrRes][1],"@e 9,999,999,999.99"),Transform(aResumo[nContrRes][2],"@e 99.99"),TransForm(aResumo[nContrRes][3],"@e 9,999,999,999.99")},aLay[23],,,@nLin)
				nTotImpDev += aResumo[nContrRes][3]
				nContrRes  += 1
			EndDo
			FmtLin(,aLay[24],,,@nLin)
			FmtLin({TransForm(nTotImpDev,"@e 9,999,999,999.99")},aLay[39],,,@nLin)
			FmtLin(,aLay[24],,,@nLin)
			lResumo    := .F.
			nNumAliq   := 0
			nContrRes  := 1
			nTotImpDev := 0.00
			aResumo    := {}
	
			If mv_par09 == 1
				DbSelectArea("SF6")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Guia de Recolhimentos                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				#IFDEF TOP
					If TcSrvType() <> "AS/400"
						cAliasSF6:= "GuiaSF6"
						lQuery    := .T.
						aStruSF6  := SF6->(dbStruct())		
						cQuery := "SELECT *"
						cQuery += "FROM "
						cQuery += RetSqlName("SF6") + " SF6 "
						cQuery += "WHERE "
						cQuery += "SF6.F6_FILIAL = '"+xFilial("SF6")+"' AND "		
						cQuery += "SF6.F6_DTARREC >='"+Dtos(mv_par01)+"' AND SF6.F6_DTARREC <='"+Dtos(mv_par02)+"' AND "
						cQuery += "SF6.F6_TIPOIMP = '2' AND "
					    cQuery += "SF6.D_E_L_E_T_=' ' "
						cQuery += "Order BY SF6.F6_FILIAL,SF6.F6_DTVENC,SF6.F6_NUMERO"
						cQuery := ChangeQuery(cQuery)
	
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF6,.T.,.T.)
	
						For nSF6 := 1 To Len(aStruSF6)
							If aStruSF6[nSF6][2] <> "C" .and. FieldPos(aStruSF6[nSF6][1]) > 0
								TcSetField(cAliasSF6,aStruSF6[nSF6][1],aStruSF6[nSF6][2],aStruSF6[nSF6][3],aStruSF6[nSF6][4])
							EndIf
						Next nSF6
					Else
				#ENDIF  	
					cIndSF6	:=	CriaTrab(NIL,.F.)
					cChave	:=	"F6_FILIAL+Dtos(F6_DTVENC)+F6_NUMERO"
					cFiltro	:=	"SF6->F6_FILIAL == '"+xFilial()+"'"
					cFiltro	+=	" .And. Dtos(SF6->F6_DTARREC) >='"+Dtos(mv_par01)+"' .AND. Dtos(SF6->F6_DTARREC) <='"+Dtos(mv_par02)+"'"
					cFiltro	+=	" .And. SF6->F6_TIPOIMP=='2'"
					IndRegua(cAliasSF6,cIndSF6,cChave,,cFiltro)
					#IFDEF TOP
					EndIf
					#ENDIF	
	
				FmtLin(,aLay[34],,,@nLin)
				FmtLin(,aLay[35],,,@nLin)
				FmtLin(,aLay[36],,,@nLin)
				FmtLin(,aLay[37],,,@nLin)
	
				While !(cAliasSF6)->(Eof())
	
					If nLin == 60
						FmtLin(,aLay[37],,,@nLin)
						nLin    := 0
						lResumo := .T.
						@ nLin,000 Psay aValImp(Limite)
						nFeixe++
						CabMJund(@nLin,aLay,@nPagina,cNome,cInscr,cCCM,cEnd,cMesAno,cCodISS,lResumo,cNproc,@nFeixe)
						FmtLin(,aLay[34],,,@nLin)
						FmtLin(,aLay[35],,,@nLin)
						FmtLin(,aLay[36],,,@nLin)
						FmtLin(,aLay[37],,,@nLin)
					EndIf
	
					dbSelectArea("SX5")
					dbSetOrder(1)
					If nMesRec == (cAliasSF6)->F6_MESREF
						If SX5->(MsSeek(xFilial("SX5")+'0N'+(cAliasSF6)->F6_BANCO))
							FmtLin({(cAliasSF6)->F6_NUMERO,(cAliasSF6)->F6_DTVENC,(cAliasSF6)->F6_BANCO+" "+Substr(X5Descri(),1,nTamNBanco),Substr((cAliasSF6)->F6_OBSERV,1,30)},aLay[38],,,@nLin)
						EndIf
					EndIf
					(cAliasSF6)->(dbSkip())
	
				EndDo
				FmtLin(,aLay[37],,,@nLin)
				nLin := 0
				lResumo := .F.
				If lQuery
					dbSelectArea(cAliasSF6)
					dbCloseArea()
				EndIf
				dbSelectArea("SF6")
				RetIndex("SF6")
			EndIf
			
		EndIf
		
	EndIf
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclui o arquivo temporario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMapResumo
	MaXRExecArq(2,cArqTmpMP)
	cAliasSf3 := cArqBkpQry
	DbSelectArea(cAliasSF3)
EndIf		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime informacao que nao houve movimento                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lHouveMov
	nlin    := 0
	cCodIss := ""
	cMesAno := (MesExtenso(Month(mv_par02)))+"/"+STRZERO(year(mv_par02),4)
	nFeixe++
	CabMJund(@nLin,aLay,@nPagina,cNome,cInscr,cCCM,cEnd,cMesAno,cCodISS,lResumo,cNproc,@nFeixe)
	FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
	FmtLin(,aLay[40],,,@nLin)
	While nLin <= 57
		FmtLin({,,,,,,,,,,},aLay[15],,,@nLin)
	EndDo
	FmtLin(,aLay[16],,,@nLin)
	FmtLin({TransForm(aTotMes[1],"@e 9,999,999,999.99"),TransForm(aTotMes[2],"@e 9,999,999,999.99"),TransForm(aTotMes[3],"@e 99,999,999.99"),TransForm(aTotMes[4],"@e 99,999,999.99"),TransForm(aTotMes[5],"@e 99,999,999.99")},aLay[17],,,@nLin)
	FmtLin(,aLay[18],,,@nLin)

EndIf

RetIndex("SF3")
dbSetOrder(1)
dbClearFilter()

If lImpTermos.and.!lEnd
	R002ITer(cPerg)
EndIf

If lQuery
	dbSelectArea(cAliasSF3)
	dbCloseArea()
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³R002RLay   ³ Autor ³ Thiago Galvao Silveira³ Data ³ 13/07/03³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ LayOut do Registro de Apuração do ISS                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function R002Lay(aLay)
Local cEstad := GetMv("MV_ESTADO")

If mv_par10==1 // 132 colunas (Sem CNPJ)

	aLay[01] := STR0009 // "+----------------------------------------------------------------------------------------------------------------------------------+"
	aLay[02] := STR0010 // "| REGISTRO DE NOTAS FISCAIS DE SERVICOS PRESTADOS                                                                       FOLHA #####|"
	If cEstad == "GO"
		aLay[02] := STR0093 // "| LIVRO REGISTRO DE PRESTAÇÃO DE SERVIÇOS  - Modelo 1                                                                   FOLHA #####|"
	EndIf
	aLay[03] := STR0011 // "| IMPOSTO SOBRE SERVICOS                                                                                                           |"
	If Empty(mv_par11)
		aLay[04] := STR0012 // "|                                                                                                                                  |"
	Else
		aLay[04] := STR0091 // "| REGIME ESPECIAL AUTORIZADO PELO PROCESSO No. ##################                                                                  |"
	Endif
	aLay[05] := STR0013 // "| ###############################################                                                    +----------------+-------------+"
	aLay[06] := STR0014 // "| C.N.P.J.: ##################                                                                       |   Incidência   |Cód Serviço  |"
	aLay[07] := STR0015 // "| I.E.: ############## C.F.M.: ##################                                                       +-------------+-------------+"	
	aLay[08] := STR0016 // "| ###############################################                                                       |############# | ######### |"
	aLay[09] := STR0017 // "+-------------------+-----------------------------------------------------------------------------------+--------------------------+"
	aLay[10] := STR0018 // "|  NOTA FISCAL      |              |              |     |             |             |               |                              |"
	aLay[11] := STR0019 // "|  DE SERVICO       |  VALOR DA    |   BASE DE    |ALI- |   IMPOSTO   |   IMPOSTO   |ISENTAS OU     |         OBSERVACOES          |"
	aLay[12] := STR0020 // "+---+-----+---------+    NOTA      |   CALCULO    |QUOTA|   DEVIDO    |   RETIDO    |NAO TRIBUTAVEIS|                              |"
	aLay[13] := STR0021 // "|DIA|SERIE| NUMERO  |              |              |     |             |             |               |                              |"
	aLay[14] := STR0022 // "+---+-----+---------+--------------+--------------+-----+-------------+-------------+---------------+------------------------------+"
	aLay[15] := STR0023 // "| ##| ### |#########|##############|##############|#####|#############|#############| ##############|##########################    |"
	aLay[16] := STR0024 // "+---+-----+---------+--------------+--------------+-----+-------------+-------------+---------------+------------------------------+"
	aLay[17] := STR0025 // "| TOTAL DO MES      |##############|##############|     |#############|#############| ##############|                              |"
	aLay[18] := STR0026 // "+-------------------+--------------+--------------+-----+-------------+-------------+---------------+------------------------------+"
	aLay[19] := STR0027 // "| RESUMO DO MES POR ALIQUOTA                                                                                                       |"
	aLay[20] := STR0028//  "+-----------------+--------+------------------+------------------------------------------------------------------------------------+"
	aLay[21] := STR0029 // "| BASE DE CALCULO |ALIQUOTA|  IMPOSTO DEVIDO  |                                                                                    |"
	aLay[22] := STR0030 // "+-----------------+--------+------------------+------------------------------------------------------------------------------------+"
	aLay[23] := STR0031 // "| ##############  |   #####|  ##############  |                                                                                    |"
	aLay[24] := STR0032 // "+-----------------+--------+------------------+------------------------------------------------------------------------------------+"
	aLay[25] := STR0033 // "+---------------------------------------------------------------------------------------------------+----------------+-------------+"
	aLay[26] := STR0034 // "|TOTAIS DO DIA ##   |################|################|     |#############|#############| ##############|                          |"
	aLay[27] := STR0035 // "| A TRANSPORTAR     |##############|     |#############|#############| ############# |############# |                              |"
	alay[28] := STR0036 // "|                                                                                                                                  |"
	aLay[29] := STR0037 // "|Tot 1º Decendio    |##############|     |#############|#############| ##############|##############|                              |"
	aLay[30] := STR0038 // "|Tot 2º Decendio    |##############|     |#############|#############| ##############|##############|                              |"
	aLay[31] := STR0039 // "|Tot 3º Decendio    |##############|     |#############|#############| ##############|##############|                              |"
	aLay[32] := STR0040 // "|Tot 1º Quinzenio   |##############|     |#############|#############| ##############|##############|                              |"
	aLay[33] := STR0041 // "|Tot 2º Quinzenio   |##############|     |#############|#############| ##############|##############|                              |"
	aLay[34] := STR0042 // "| Recolhimentos                                                                                                                    |"
	aLay[35] := STR0043 // "+--------------+-----------------+---------------------+---------------------------------------------------------------------------+"
	aLay[36] := STR0044 // "| Guia N.      |Data de Pagamento| Banco               | Informacoes Complementares                                                |"
	aLay[37] := STR0045 // "+--------------+-----------------+---------------------+---------------------------------------------------------------------------+"
	aLay[38] := STR0046 // "| ############ |#################| ################### | #######################################################################   |"
	aLay[39] := STR0047 // "|                 | TOTAL  |  ##############  |                                                                                    |"
	aLay[40] := STR0048 // "|  *** NAO HOUVE MOVIMENTO ***     |     |             |             |               |              |                              |"

Else// 220 colunas

	aLay[01] := STR0049 // "+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[02] := STR0050 // "| REGISTRO DE NOTAS FISCAIS DE SERVICOS PRESTADOS                                                                                                                                                               FOLHA #####|"
	If cEstad == "GO"
		aLay[02] := STR0094 // "| LIVRO REGISTRO DE PRESTAÇÃO DE SERVIÇOS  - Modelo 1                                                                                                                                                           FOLHA #####|"
	EndIf
	aLay[03] := STR0051 // "| IMPOSTO SOBRE SERVICOS                                                                                                                                                                                                   |"
	If Empty(mv_par11)
		aLay[04] := STR0052 // "|                                                                                                                                                                                                                          |"
	Else
		aLay[04] := STR0092//  "| REGIME ESPECIAL AUTORIZADO PELO PROCESSO No.: ##################                                                                                                                                                         |"
	Endif
	aLay[05] := STR0053 // "| ###############################################                                                                                                                                  +-------------------+-------------------+"
	aLay[06] := STR0054 // "| C.N.P.J.: ##################                                                                                                                                                     | Mês de Incidência | Código de Serviço |"
	aLay[07] := STR0055 // "| I.E.: ############## C.C.M.: ##################                                                                                                                                  +-------------------+-------------------+"
	aLay[08] := STR0056 // "| ###############################################                                                                                                                                  |  ###############  |      ############ |"
	aLay[09] := STR0057 // "+-------------------+--------------+--------------+-----+-------------+-------------+---------------+------------------------------+"
	aLay[10] := STR0058 // "|  NOTA FISCAL      |              |              |     |             |             |               |                              |"
	aLay[11] := STR0059 // "|  DE SERVICO       |  VALOR DA    |   BASE DE    |ALI- |   IMPOSTO   |   IMPOSTO   |ISENTAS OU     |         OBSERVACOES          |"
	aLay[12] := STR0060 // "+---+-----+---------+    NOTA      |   CALCULO    |QUOTA|   DEVIDO    |   RETIDO    |NAO TRIBUTAVEIS|                              |"
	aLay[13] := STR0061 // "|DIA|SERIE| NUMERO  |              |              |     |             |             |               |                              |"
	aLay[14] := STR0062 // "+---+-----+---------+--------------+--------------+-----+-------------+-------------+---------------+------------------------------+"
	aLay[15] := STR0063 // "| ##| ### |#########|##############|##############|#####|#############|#############| ##############|##############################|"
	aLay[16] := STR0064 // "+---+-----+---------+--------------+--------------+-----+-------------+-------------+---------------+------------------------------+"
	aLay[17] := STR0065 // "| TOTAL DO MES      |##############|##############|     |#############|#############| ##############|                              |"
	aLay[18] := STR0066 // "+-------------------+--------------+--------------+-----+-------------+-------------+---------------+------------------------------+"
	aLay[19] := STR0067 // "| RESUMO DO MES POR ALIQUOTA                                                                                                                                                                                               |"
	aLay[20] := STR0068 // "+-----------------+--------+------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[21] := STR0069 // "| BASE DE CALCULO |ALIQUOTA|  IMPOSTO DEVIDO  |                                                                                                                                                                            |"
	aLay[22] := STR0070 // "+-----------------+--------+------------------+                                                                                                                                                                            |"
	aLay[23] := STR0071 // "| ##############  |   #####|  ##############  |                                                                                                                                                                            |"
	aLay[24] := STR0072 // "+-----------------+--------+------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[25] := STR0073 // "+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------------+-------------------+"
	aLay[26] := STR0074 // "|TOTAIS DO DIA ##|                    | ##############   |        | ##############   | ##############   | ##############   | ##############   |                                                                            |"
	aLay[27] := STR0075 // "| A TRANSPORTAR  |                    | ##############   |        | ##############   | ##############   | ##############   | ##############   |                                                                            |"
	alay[28] := STR0076 // "|                                                                                                                                                                                                                          |"
	aLay[29] := STR0077 // "|Tot 1º Decendio |                    | ##############   |        | ##############   | ##############   | ##############   | ##############   |                                                                            |"
	aLay[30] := STR0078 // "|Tot 2º Decendio |                    | ##############   |        | ##############   | ##############   | ##############   | ##############   |                                                                            |"
	aLay[31] := STR0079 // "|Tot 3º Decendio |                    | ##############   |        | ##############   | ##############   | ##############   | ##############   |                                                                            |"
	aLay[32] := STR0080 // "|Tot 1º Quinzenio|                    | ##############   |        | ##############   | ##############   | ##############   | ##############   |                                                                            |"
	aLay[33] := STR0081 // "|Tot 2º Quinzenio|                    | ##############   |        | ##############   | ##############   | ##############   | ##############   |                                                                            |"
	aLay[34] := STR0082 // "| Recolhimentos                                                                                                                                                                                                            |"
	aLay[35] := STR0083 // "+--------------+-----------------+---------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[36] := STR0084 // "| Guia N.      |Data de Pagamento| Banco               | Informacoes Complementares                                                                                                                                        |"
	aLay[37] := STR0085 // "+--------------+-----------------+---------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
	aLay[38] := STR0086 // "| ############ |#################| ################### | #######################################################################                                                                                           |"
	aLay[39] := STR0087 // "|                 | TOTAL  |  ##############  |                                                                                                                                                                            |"
	aLay[40] := STR0088 // "|     *** NAO HOUVE MOVIMENTO ***     |                  |        |                  |                  |                  |                  |                                                                            |"
EndIf
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R002Cnpj  ³ Autor ³ Henry Fila            ³ Data ³20/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorno do Cnpj do F3                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ExpC1 : Codigo do Cliente no F3                             ³±±
±±³          ³ExpC2 : Loja do Cliente no F3                               ³±±
±±³          ³ExpC3 : Tipo do F3                                          ³±±
±±³          ³ExpC4 : CFO do F3                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function R002Cnpj(cCliFor, cLoja, cTipo, cCfo)

Local aArea   := GetArea()
Local aAreaSA1:= SA1->(GetArea())
Local aAreaSA2:= SA2->(GetArea())
Local cAliasB := ""
Local cCampo  := ""

If Left( cCfo, 1) >= "5"
	cAliasB := Iif( cTipo $ "DB", "SA2", "SA1" )
	cCampo  := Iif( cTipo $ "DB", "A2_CGC", "A1_CGC" )
Else	
	cAliasB := Iif( cTipo $ "DB", "SA1", "SA2" )
	cCampo  := Iif( cTipo $ "DB", "A1_CGC", "A2_CGC" )
EndIf	

(cAliasB)->(dbSetOrder(1))
If (cAliasB)->(MsSeek(xFilial(cAliasB)+cCliFor+cLoja))
	cCnpj   :=(cAliasB)->(FieldGet(FieldPos(cCampo)))
EndIf

RestArea(aAreaSA1)
RestArea(aAreaSA2)
RestArea(aArea)

Return(cCnpj)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R002ISS ³ Autor ³ Henry Fila           ³ Data ³20/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorno da opcao de Recolhe ISS                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ExpC1 : Codigo do Cliente no F3                             ³±±
±±³          ³ExpC2 : Loja do Cliente no F3                               ³±±
±±³          ³ExpC3 : Tipo do F3                                          ³±±
±±³          ³ExpC4 : CFO do F3                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function R002ISS(cCliFor, cLoja, cTipo, cCfo)

Local aArea   := GetArea()
Local aAreaSA1:= SA1->(GetArea())
Local aAreaSA2:= SA2->(GetArea())
Local cAliasB := ""
Local cCampo2 := ""

If Left( cCfo, 1) >= "5"
	cAliasB := Iif( cTipo $ "DB", "SA2", "SA1" )
	cCampo2 := Iif( cTipo $ "DB", "A2_RECISS", "A1_RECISS" )	
Else	
	cAliasB := Iif( cTipo $ "DB", "SA1", "SA2" )
	cCampo2 := Iif( cTipo $ "DB", "A1_RECISS", "A2_RECISS" )
EndIf	

(cAliasB)->(dbSetOrder(1))
If (cAliasB)->(MsSeek(xFilial(cAliasB)+cCliFor+cLoja))
	cRecIss :=(cAliasB)->(FieldGet(FieldPos(cCampo2)))
	cRecIss :=If(cRecIss$"12",If(cRecIss=="1","S","N"),cRecIss)
EndIf

RestArea(aAreaSA1)
RestArea(aAreaSA2)
RestArea(aArea)

Return(cRecISS)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CabMJund  ³ Autor ³ Thiago Galvao      ³ Data ³25/07/03    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Imp do Cabecaçho do Reg de Apur de ISS            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR990()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CabMJund(nLin,aLay,nPagina,cNome,cInscr,cCCM,cEnd,cMesAno,cCodISS,lResumo,cNproc,nFeixe)
If ( nLin == 60 )
	FmtLin(,aLay[14],,,@nLin)
EndIf
nLin := 0
@ nLin,000 Psay aValImp(Limite)
nLin++
FmtLin(,aLay[01],,,@nLin)
FmtLin({StrZero(nPagina,5)},aLay[02],,,@nLin)
FmtLin(,aLay[03],,,@nLin)
FmtLin({cNproc},aLay[04],,,@nLin)
FmtLin({cNome},aLay[05],,,@nLin)
FmtLin({Transf(SM0->M0_CGC,"@R 99.999.999/9999-99")},aLay[06],,,@nLin)
FmtLin({cInscr,cCCM},aLay[07],,,@nLin)
FmtLin({cEnd,cMesAno,cCodISS},aLay[08],,,@nLin)
IIF(!lResumo,FmtLin(,aLay[09],,,@nLin),FmtLin(,aLay[25],,,@nLin))
If !lResumo
	FmtLin(,aLay[10],,,@nLin)
	FmtLin(,aLay[11],,,@nLin)
	FmtLin(,aLay[12],,,@nLin)
	FmtLin(,aLay[13],,,@nLin)
	FmtLin(,aLay[14],,,@nLin)
EndIf
	If (nFeixe==MV_PAR12)
		nPagina	:=	MV_PAR03
		nFeixe  :=	0
	Else
		nPagina +=1
	Endif
Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R002ITer() ³ Autor ³ Juan Jose Pereira  ³ Data ³20/10/95³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime termos de Abertura e Encerramento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR990, MATRISS                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function R002ITer(cPerg)

Local cArqAbert	:=	GetMv("MV_LISSAB")
Local cArqEncer	:=	GetMv("MV_LISSEN"), aDriver := ReadDriver()
Local aDados    := {}

AADD(aDados,{"D_I_A",Day(dDatabase)})
AADD(aDados,{"M_E_S",MesExtenso(Month(dDatabase))})
AADD(aDados,{"A_N_O",Year(dDatabase)})

F002TERM(cArqAbert,cArqEncer,cPerg,aDriver[4],aDados)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ F002TERM    ³ Autor ³ Thiago Galvao      ³ Data ³ 13/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime termos de abertura e encerramento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA990                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION F002TERM(cArqAbert,cArqEncer,cPerg,cDriver,aOutDad)

LOCAL cSvAlias:=Alias(), aVariaveis:={},i,uConteudo,cConteudo
aadd(aVariaveis,{"VAR_IXB",If(!(Type('VAR_IXB')=='U'),VAR_IXB,'')})
dbSelectArea("SM0")
For i:=1 to FCount()
	If FieldName(i)=="M0_CGC"
		AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 99.999.999/9999-99")})
	ElseIf FieldName(i)=="M0_INSC"
		AADD(aVariaveis,{FieldName(i),InscrEst()})
	Else
		If FieldName(i)=="M0_NOME"
			Loop
		Endif	
		AADD(aVariaveis,{FieldName(i),FieldGet(i)})
	Endif
Next

dbSelectArea( "CVB" )
CVB->(dbSeek( xFilial( "CVB" ) ))
For i:=1 to FCount()
	If FieldName(i)=="CVB_CGC"
		AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 99.999.999/9999-99")})
	ElseIf FieldName(i)=="CVB_CPF"
		AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 999.999.999-99")})
	Else
		AADD(aVariaveis,{FieldName(i),FieldGet(i)})
	Endif
Next

dbSelectArea("SX1")
dbSeek( padr( cPerg , Len( X1_GRUPO ) , ' ' ) + "01" )
While ! Eof() .And. SX1->X1_GRUPO  == padr( cPerg , Len( X1_GRUPO ) , ' ' )
	uConteudo:=&(X1_VAR01)
	If Valtype(uConteudo)=="N"
		cConteudo:=Alltrim(Str(uConteudo))
	Else
		If Valtype(uConteudo)=="C"
			cConteudo:=Alltrim(uConteudo)
		Else
			cConteudo:=uConteudo
		EndIf
	Endif		
	AADD(aVariaveis,{Rtrim(Upper(X1_VAR01)),cConteudo})
	dbSkip()
End

For i:=1 to Len(aOutDad)
	AADD(aVariaveis,{aOutDad[i][1],aOutDad[i][2]})
Next

If cArqAbert#NIL .and. File(cArqAbert)
	ImpTerm(cArqAbert,aVariaveis,&cDriver)
Endif
If cArqEncer#NIL .and. File(cArqEncer)
	ImpTerm(cArqEncer,aVariaveis,&cDriver)
Endif	

RETURN (NIL)
