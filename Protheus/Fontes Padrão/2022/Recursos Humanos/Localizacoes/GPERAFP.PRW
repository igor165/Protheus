#Include "PROTHEUS.CH"
#INCLUDE "GPERAFP.CH"
#DEFINE   nColMax	2350
#DEFINE   nLinMax  2900
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPERAFP  ³ Autor ³ Erika Kanamori          ³ Data   ³ 03.03.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao do Formulario de Pago de Contribuciones.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPERAFP()                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS      ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Luciana     |28/07/09|18177/2009 |Ajuste na mascara dos valores a serem     |±±
±±|            |        |           |impressos no relatorio.                   |±±
±±|Luciana     |13/08/09|19835/2009 |Ajuste no relatorio para considerar na    |±±
±±|            |        |           |geracao apenas o mes solicitado nos       |±±
±±|            |        |           |parametros.                               |±±
±±|Luciana     |14/10/09|23040/2009 |Ajuste das colunas para adequacao ao novo |±±
±±|            |        |           |modelo do Relatorio.                      |±±
±±|Luciana     |06/11/09|26892/2009 |Tratamento para as Colunas Interes por    |±±
±±|            |        |           |Mora e Interes Incremental. Criacao de    |±±
±±|            |        |           |Query para filtrar as informacoes do SRC e|±±
±±|            |        |           |SRD E ajuste nas condicoes do relatorio.  |±±
±±|Luciana     |04/12/09|28462/2009 |Tratamento para considerar os dias propor-|±±
±±|            |        |           |cionais baseados no campo R9_Desc da tabe-|±±
±±|            |        |           |la SR9 nos casos de admissao e demissao.  |±±
±±|L.Trombini  |20/06/11|06123/2011 |Inclusao e ajustes de colunas de acordo   |±±
±±|            |        |           |com o novo layout do relatorio            |±±
±±|Fabio G.    |26/03/12|     TESJBO|Ajuste p/ tratamento da query QSRC->RC_PD |±±
±±|            |        |           |e CPERIODOS em QSRD para filtrar informa- |±±
±±|			   |		|		    |coes. 									   |±±
±±|R.Berti     |26/04/12|     TEWBQF|Correcao estouro layout e error log:	   |±±
±±|            |        |           |"variable does not exist CPERIODOS" 	   |±±
±±|M.Silveira  |08/04/13|     TGXIM2|Ajuste nas impressao das colunas 21 a 24  |±±
±±|            |        |           |para seguir as validacoes conforme leiaute|±±
±±³            ³        ³           ³                                          ³±±
±±³Jonathan Glz³07/05/15³ PCREQ-4256³Se elimina funcion AjustaSX1T y AjustaHlp ³±±
±±³            ³        ³           ³que realizan modificacion al diccionario  ³±±
±±³            ³        ³           ³de datos(SX1) por motivo de ajuste nueva  ³±±
±±³            ³        ³           ³estructura de SXs para V12                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function GPERAFP()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Locais (Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cDesc1 		:= STR0001		//"Formulário de Pago de Contribuciones"
Local cDesc2 		:= STR0002		//"Se imprimira de acuerdo con los parametros solicitados por el usuario."
Local cDesc3 		:= STR0003		//""Obs.: Debe imprimirse un Formulario Mensual para cada Filial.""
Local cString		:= "SRA"        // alias do arquivo principal (Base)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Private(Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private nomeprog	:= "GPERAFP"
Private aReturn 	:= { , 1,, 2, 2, 1,"",1 }
Private nLastKey 	:= 0
Private cPerg   	:= "GPRAFP"

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis Utilizadas na funcao de Impressao                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private Titulo		:= STR0001		//"Formulário de Pago de Contribuciones" - titulo da janela de pergunte
Private nTamanho	:= "G"
Private nOrdem
Private nTipo
Private cFilialDe   := ""
Private cFilialAte  := ""
Private cMes		:= ""
Private cAno		:= ""
Private cMatDe      := ""
Private cMatAte     := ""
Private cCustoDe    := ""
Private cCustoAte   := ""
Private cNomeDe     := ""
Private cNomeAte    := ""
Private cSit		:= ""
Private cCat		:= ""
Private lEnd
Private nInteres
Private nIncrement
Private nIntViv
Private nIncViv
Private nIntSol
Private nIncSol

Private oPrint
Private oFont06, oFont07, oFont08, oFont09, oFont12, oFont10, oFont10n, oFont14n

    oFont06  := TFont():New("Courier New",6.5,6.5,,.F.,,,,.T.,.F.)
    oFont07  := TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.)
    oFont08  := TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
	oFont09  := TFont():New("Courier New",09,09,,.F.,,,,.T.,.F.)
	oFont12	 := TFont():New("Courier New",12,12,,.F.,,,,.T.,.F.)
	oFont10  := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
	oFont10n := TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.) //Negrito
	oFont14n := TFont():New("Courier New",14,14,,.T.,,,,.T.,.F.)     //Negrito//

nEpoca:= SET(5,1910)
//-- MUDAR ANO PARA 4 DIGITOS
SET CENTURY ON

pergunte("GPRAFP",.F.)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Envia controle para a funcao SETPRINT                        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
wnrel:="GPERAFP"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,nTamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis utilizadas para parametros                         ³
³ mv_par01        //  Tipo do relatorio(Previsión|Futuro Bolívia)|
³ mv_par02        //  Filial De						           ³
³ mv_par03        //  Filial Ate					           ³
³ mv_par04        //  Mes/Ano?     				               |
³ mv_par05        //  Matricula De                             ³
³ mv_par06        //  Matricula Ate                            ³
³ mv_par07        //  Centro de Custo De                       ³
³ mv_par08        //  Centro de Custo Ate                      ³
³ mv_par09        //  Nome De                                  ³
³ mv_par10        //  Nome Ate                                 ³
³ mv_par11        //  Situações a imp?                         ³
³ mv_par12        //  Categorias a imp?                        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nOrdem   	:= aReturn[8]

nTipo		:= mv_par01
cFilialDe 	:= mv_par02
cFilialAte  := mv_par03
cMes 		:= substr( mv_par04, 1, 2 )
cAno 		:= substr( mv_par04, 3, 4 )
cMatDe		:= mv_par05
cMatAte     := mv_par06
cCustoDe    := mv_par07
cCustoAte   := mv_par08
cNomeDe		:= mv_par09
cNomeAte	:= mv_par10
cSit        := mv_par11
cCat        := mv_par12
nInteres	:= mv_par13
nIncrement	:= mv_par14
nIntViv		:= mv_par15
nIncViv		:= mv_par16
nIntSol		:= mv_par17
nIncSol		:= mv_par18


//-- Objeto para impressao grafica
oPrint 	:= TMSPrinter():New( If(nTipo = 1, STR0004, STR0005) ) //"Planilla Previsión" ou
															    //"Planilla Futuro de Bolívia"
oPrint:SetPortrait()

Titulo := If(nTipo = 1, STR0004, STR0005) //"Planilla Previsión" ou "Planilla Futuro de Bolívia"

RptStatus({|lEnd| IMPAFP(@lEnd,wnRel,cString,.F. )},Capital(Titulo))

oPrint:Preview()  							// Visualiza impressao grafica antes de imprimir

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPAFP    ºAutor  ³Erika Kanamori      º Data ³  03/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IMPAFP()

Local cAcessaSRA	:= &( " { || " + ChkRH( "GPERAFP" , "SRA", "2" ) + " } " )

Local nAux
Local nSavRec
Local nSavOrdem
Local cVerCodFol
Local cContrAdic
Local cContrVol

Local nIdade     := 0
Local ntot       := 0
Local nTotFunc   := 0

Local cFilAnt    := ""
Local cCodFolJub := ""
Local cFim       := ""

Local aCodFol    := {}
Local aPerAberto := {}
Local aPerFechado:= {}
Local aPerTodos  := {}

Local lAchou     := .F.
Local lJubilac   := .F.

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis para controle em ambientes TOP.                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cCateg
Local cSitu
Local cQuery
Local cAlias	:= ""
Local cQrySRA	:= "SRA"
Local cQrySRC	:= "SRC"
Local cQrySRD	:= "SRD"
Local aStruct	:= {}
Local lQuery	:= .F.

//Vaviaveis private para impressao
Private nVCol21 	:= 0
Private nVCol22 	:= 0
Private nVCol23 	:= 0
Private nVCol24 	:= 0
Private nVCol25 	:= 0
Private nVCol26 	:= 0
Private nVCol27 	:= 0
Private nVCol28 	:= 0
Private nVCol33 	:= 0
Private nVCol34 	:= 0
Private nVCol35 	:= 0
Private nVCol36 	:= 0
Private nVCol37 	:= 0
Private nVCol38 	:= 0
Private nVCol42 	:= 0
Private nVCol43 	:= 0
Private nVCol47 	:= 0
Private nVCol48 	:= 0
Private nVCol49 	:= 0
Private nVCol50 	:= 0
Private nVCol51 	:= 0
Private nVCol52 	:= 0
Private nCol21Tot	:= 0
Private nCol22Tot	:= 0
Private nCol23Tot	:= 0
Private nCol24Tot	:= 0
Private nCol25Tot	:= 0
Private nCol26Tot	:= 0
Private nCol27Tot	:= 0
Private nCol28Tot	:= 0
Private aInfo		:= {}


#IfDef TOP

	//Filtra do SRA: filial, matricula de/ate, centro de custo de/ate, categoria e situacoes
	cAlias  := "SRA"
	cQrySRA := "QSRA"

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Buscar Situacao e Categoria em formato para SQL              ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cSitu   := "("
	For nAux := 1 To (Len( cSit )-1)
		cSitu += "'" + Substr( cSit, nAux, 1) + "',"
	Next nAux
	cSitu += "'" + Substr( cSit, len(cSit), 1) + "')"

	cCateg   := "("
	For nAux := 1 To (Len( cCat )-1)
		cCateg += "'" + Substr( cCat, nAux, 1) + "',"
	Next nAux
	cCateg	+= "'" + Substr( cCat, len(cCat), 1) + "')"


	//montagem da query
	cQuery := "SELECT "
	cQuery += " RA_FILIAL, RA_MAT,  RA_NOME, RA_CIC, RA_ADMISSA,"
 	cQuery += " RA_SITFOLH, RA_DEMISSA, RA_NASC, RA_NACIONA, RA_TPAFP, RA_AFPOPC, RA_JUBILAC, RA_TPSEGUR"
	cQuery += " FROM " + RetSqlName(cAlias)
	cQuery += " WHERE "
	cQuery += " RA_FILIAL BETWEEN '" + cFilialDe + "' AND '" + cFilialAte + "'"
	cQuery += "  AND "
	cQuery += " RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "'"
	cQuery += "  AND "
	cQuery += " RA_NOME BETWEEN '" + cNomeDe + "' AND '" + cNomeAte + "'"
	cQuery += "  AND "
	cQuery += " RA_CC BETWEEN '" + cCustoDe + "' AND '" + cCustoAte + "'"
	cQuery += "  AND "
	cQuery += " RA_TPAFP = '" + If(nTipo = 1, "1", "2") + "'"
	cQuery += " AND "
   	cQuery += " RA_SITFOLH IN " + cSitu
	cQuery += "  AND "
	cQuery += " RA_CATFUNC IN " + cCateg
	cQuery += "  AND "
	cQuery += " RA_TPAFP = '" + If(nTipo = 1, "1", "2") + "'"
	cQuery += " AND "
	cQuery += " D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY RA_FILIAL, RA_MAT "

	cQuery := ChangeQuery(cQuery)
	aStruct := (cAlias)->(dbStruct())

	If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRA,.T.,.T.)
		For nAux := 1 To Len(aStruct)
			If ( aStruct[nAux][2] <> "C" )
				TcSetField(cQrySRA,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
			EndIf
		Next nAux
	Endif

	lQuery := .T.
	dbSelectArea(cQrySRA)
	(cQrySRA)->(dbGoTop())

#ELSE

	dbSelectArea("SRA")
	nSavRec   := RecNo()
	nSavOrdem := IndexOrd()
	dbSetOrder(1)
	dbSeek( cFilialDe + cMatDe, .T. )

#ENDIF


	cFim     := cFilialAte + cMatAte
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega Regua de Processamento                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	(cQrySRA)->( SetRegua(RecCount()) )
	SetPrc(0,0)


	While (cQrySRA)->(!Eof()) .And. ((cQrySRA)->(RA_FILIAL+RA_MAT) <= cFim )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Movimenta Regua de Processamento                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	    IncRegua()

		If lEnd
			@Prow()+1,0 PSAY cCancel
			Exit
	    Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste Parametrizacao do Intervalo de Impressao            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  !lQuery .And. ;
			((SRA->RA_MAT < cMatDe)   .Or. (SRA->RA_MAT > cMatAte)    .Or. ;
			(SRA->RA_CC  < cCustoDe) .Or. (SRA->RA_CC  > cCustoAte)   .Or. ;
			(SRA->RA_NOME < cNomeDe) .Or. (SRA->RA_NOME > cNomeAte)   .Or. ;
			!(SRA->RA_CATFUNC $ cCat) .Or. !(SRA->RA_SITFOLH $ cSit)) .Or. ;
			!(SRA->RA_TPAFP == If(nTipo=1, "1", "2"))
			SRA->(dbSkip(1))
			Loop
		EndIf

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Consiste Filiais e Acessos                                             ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF !( (cQrySRA)->RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA )
	      	(cQrySRA)->( dbSkip() )
	       	Loop
		Endif

		lJubilac := (cQrySRA)->RA_JUBILAC == "1"

		//se filial eh diferente da anterior, inicia-se nova pagina
		If cFilAnt <> (cQrySRA)->RA_FILIAL

			If nTotFunc <> 0
			    //totaliza campos

			    nVCol33 := (0.1392 * nCol21Tot)
			    nVCol34 := (0.105  * nCol22Tot)
			    nVCol35 := (0.0392 * nCol23Tot)
			    nVCol36 := (0.005  * nCol24Tot)
			    nVCol37 := nCol25Tot
			    nVCol38 := nVCol33 + nVCol34 + nVCol35 + nVCol36 + nVCol37
	  			nVCol42 := nCol26Tot
	  			nVCol43 := (0.02   * nCol26Tot)
	  			nVCol47 := nCol27Tot
	  			nVCol48 := nCol28Tot
	  			nVCol49 := (0.03   * nCol27Tot)
	 			nVCol50 := (0.005  * nCol27Tot)
	  			nVCol51 := (0.02   * nCol28Tot)
 	  			nVCol52 :=  nVCol49 + nVCol50 + nVCol51

				//imprime relatorio
				oPrint:Endpage()
				ImprAFP()
			Endif

			//Zera variaveis para cada filial
			nVCol21  := nVCol22 := nVCol23 := 0
			nVCol24  := nVCol25 := nVCol26 := 0
			nVCol27  := nVCol28 := nVCol33 := 0
			nVCol34  := nVCol35 := nVCol36 := 0
			nVCol37  := nVCol38 := nVCol42 := 0
			nVCol43  := nVCol47 := nVCol48 := 0
			nVCol49  := nVCol50 := nVCol51 := 0
            nVCol52  := 0
			nCol21Tot := nCol22Tot  := nCol23Tot  := 0
			nCol24Tot := nCol25Tot  := nCol26Tot := 0
			nCol27Tot := nCol28Tot  :=0

			fInfo(@aInfo, (cQrySRA)->RA_FILIAL)     //carrega informacoes da filial

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Carrega Variaveis Codigos Da Folha                           ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If !fP_CodFol(@aCodFol,(cQrySRA)->RA_FILIAL)
				Return
			Endif

  			cVerCodFol:= aCodFol[731,1]// armazena verba relacionada a AFP
			cCodFolJub:= aCodFol[737,1]// armazena verba relacionada a AFP para funcionarios jubilados
			cContrAdic:= aCodFol[1112,1] //armazena a verba de Contribuicao Adicional
			cContrVol := aCodFol[1113,1] //armazena a verba de Contribuicao Voluntaria



			//carrega periodo da competencia selecionada
			fRetPerComp( cMes , cAno , , , , @aPerAberto , @aPerFechado , @aPerTodos )

			cFilAnt:= (cQrySRA)->RA_FILIAL

		Endif

		//procura registros do funcionario no SRC
		If !(len(aPerAberto) < 1)

			//zera variaveis para cada funcionario
			nIdade := nTotAux := 0
			//Calcula a idade baseada na data de nascimento e no ultimo dia do periodo
			nIdade := Calc_Idade( aPerAberto[len(aPerAberto)][6] , (cQrySRA)->RA_NASC )
			lMaior := nIdade >= 65

			If lQuery
				cAlias := "SRC"
				cQrySRC := "QSRC"

				//busca periodos para formato Query
				cPeriodos   := "("
				For nAux:= 1 to (len(aPerAberto)-1)
					cPeriodos += "'" + aPerAberto[nAux][1] + "',"
				Next nAux
				cPeriodos += "'" + aPerAberto[len(aPerAberto)][1]+"')"

				//montagem da query
				cQuery := "SELECT "
				cQuery += " RC_FILIAL, RC_MAT, RC_PROCES, RC_ROTEIR, RC_PERIODO,RC_SEMANA, RC_VALOR, RC_PD "
				cQuery += " FROM " + RetSqlName(cAlias)
				cQuery += " WHERE "
				cQuery += " RC_FILIAL = '" + cFilAnt + "'"
				cQuery += " AND "
				cQuery += " RC_MAT = '" + (cQrySRA)->RA_MAT + "'"
				cQuery += " AND "
				cQuery += " RC_PERIODO IN " + cPeriodos
				cQuery += " AND "
				cQuery += " D_E_L_E_T_ <> '*'
				cQuery += " ORDER BY RC_FILIAL, RC_MAT, RC_PROCES, RC_ROTEIR, RC_PERIODO,RC_SEMANA "

				cQuery := ChangeQuery(cQuery)
				aStruct := (cAlias)->(dbStruct())

				If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRC,.T.,.T.)
					For nAux := 1 To Len(aStruct)
						If ( aStruct[nAux][2] <> "C" )
							TcSetField(cQrySRC,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
						EndIf
					Next nAux
				Endif
			Else
				dbSelectArea(cQrySRC)
				dbSetOrder(6)
			Endif

			For nAux:=1 to len(aPerAberto)

		  		(cQrySRC)->(dbGoTop())

				While (cQrySRC)->(!Eof()) .And. (cQrySRA)->(RA_FILIAL+RA_MAT)+ aPerAberto[nAux][7] == (cQrySRC)->(RC_FILIAL+RC_MAT+RC_PROCES)

					lVerba := (cQrySRC)->RC_PD == aCodFol[731,1]

				    If lVerba
						If lJubilac .AND. "1" $ (cQrySRA)->RA_AFPOPC
							If !lMaior
								nVCol23 := (cQrySRC)->RC_VALOR
								lReg	:= .T.
							Elseif lMaior
								nVCol24 := (cQrySRC)->RC_VALOR
								lReg	:= .T.
					        EndIF
					    ElseiF !lJubilac .AND. "2" $ (cQrySRA)->RA_AFPOPC
							If !lMaior
								nVCol21 := (cQrySRC)->RC_VALOR
								lReg	:= .T.
							Elseif lMaior
								nVCol22 := (cQrySRC)->RC_VALOR
								lReg	:= .T.
							EndIf
						EndIf
					EndIf

					If(cQrySRC)->RC_PD == aCodFol[1112,1] .or. (cQrySRC)->RC_PD == aCodFol[1113,1] //armazena a verba de Contribuicao Adicional
						nVCol25 := (cQrySRC)->RC_VALOR
						lReg	:= .T.
					Endif
					If(cQrySRC)->RC_PD == aCodFol[0737,1]       // armazena Vivienda
						nVCol26 := (cQrySRC)->RC_VALOR
						lReg	:= .T.
					Endif
					If(cQrySRC)->RC_PD == aCodFol[1227,1]  .and. (cQrySRA)->RA_TPSEGUR $ "E* "     // armazena Fondo Solidario
						nVCol27 := (cQrySRC)->RC_VALOR
						lReg	:= .T.
					Endif
					If(cQrySRC)->RC_PD == aCodFol[1227,1]  .and. (cQrySRA)->RA_TPSEGUR $ "C*M"     // armazena Fondo Solidario MINEROS
						nVCol28 := (cQrySRC)->RC_VALOR
						lReg	:= .T.
					Endif
					(cQrySRC)->(dbSkip())
				End

			Next nAux

			(cQrySRC)->(dbCloseArea())
		Endif


		//procura registros do funcionario no SRD
		If !(len(aPerFechado) < 1)

			//zera variaveis para cada funcionario
			nIdade := nTotAux := 0
			//Calcula a idade baseada na data de nascimento e no ultimo dia do periodo
			nIdade := Calc_Idade( aPerFechado[len(aPerFechado)][6] , (cQrySRA)->RA_NASC )
			lMaior := nIdade >= 65

			If lQuery
				cAlias := "SRD"
				cQrySRD := "QSRD"
				lAchou := .T.
				//busca periodos para formato Query
				cPeriodos   := "("
				For nAux:= 1 to (len(aPerFechado)-1)
					cPeriodos += "'" + aPerFechado[nAux][1] + "',"
				Next nAux
				cPeriodos += "'" + aPerFechado[len(aPerFechado)][1]+"')"

				//montagem da query
				cQuery := "SELECT "
				cQuery += " RD_FILIAL, RD_MAT, RD_PROCES, RD_ROTEIR, RD_PERIODO,RD_SEMANA, RD_VALOR, RD_PD "
				cQuery += " FROM " + RetSqlName(cAlias)
				cQuery += " WHERE "
				cQuery += " RD_FILIAL = '" + cFilAnt + "'"
				cQuery += " AND "
				cQuery += " RD_MAT = '" + (cQrySRA)->RA_MAT + "'"
				cQuery += " AND "
				cQuery += " RD_PERIODO IN " + cPeriodos
				cQuery += " AND "
				cQuery += " D_E_L_E_T_ <> '*'
				cQuery += " ORDER BY RD_FILIAL, RD_MAT, RD_PROCES, RD_ROTEIR, RD_PERIODO,RD_SEMANA "

				cQuery := ChangeQuery(cQuery)
				aStruct := (cAlias)->(dbStruct())
				If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRD,.T.,.T.)
					For nAux := 1 To Len(aStruct)
						If ( aStruct[nAux][2] <> "C" )
							TcSetField(cQrySRD,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
						EndIf
					Next nAux
				Endif
			Else
					dbSelectArea(cQrySRD)
					dbSetOrder(5)
			Endif

			For nAux:=1 to len(aPerFechado)

				(cQrySRD)->(dbGoTop())

				//Se o Roteiro de calculo vier em branco no array pega o roteiro ordinario
				cRotPer:= fGetRotOrdinar()
			 	If Empty(aPerFechado[nAux][8])
			 		aPerFechado[nAux][8]:=cRotPer
			 	Endif

				If !lQuery
					dbSeek((cQrySRA)->(RA_FILIAL+RA_MAT)+ aPerFechado[nAux][7]+ aPerFechado[nAux][8]+ aPerFechado[nAux][1]+ aPerFechado[nAux][2])
				Else
			   		While (cQrySRD)->(!Eof()) .And. !((cQrySRA)->(RA_FILIAL+RA_MAT)+aPerFechado[nAux][7]+aPerFechado[nAux][8]+aPerFechado[nAux][1]+aPerFechado[nAux][2]== (cQrySRD)->(RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA))
						(cQrySRD)->(dbSkip())
					End
				Endif

			   	While (cQrySRD)->(!Eof()) .And.  (cQrySRA)->(RA_FILIAL+RA_MAT)+aPerFechado[nAux][7]+aPerFechado[nAux][8]+aPerFechado[nAux][1]+aPerFechado[nAux][2]== (cQrySRD)->(RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA)

					lVerba := (cQrySRD)->RD_PD == aCodFol[731,1]

				    If lVerba
						If lJubilac .AND. "1" $ (cQrySRA)->RA_AFPOPC
							If !lMaior
								nVCol23 := (cQrySRD)->RD_VALOR
								lReg	:= .T.
							Elseif lMaior
								nVCol24 := (cQrySRD)->RD_VALOR
								lReg	:= .T.
					        EndIF
					    ElseiF !lJubilac .AND. "2" $ (cQrySRA)->RA_AFPOPC
							If !lMaior
								nVCol21 := (cQrySRD)->RD_VALOR
								lReg	:= .T.
							Elseif lMaior
								nVCol22 := (cQrySRD)->RD_VALOR
								lReg	:= .T.
							EndIf
						EndIf
					EndIf

					If(cQrySRD)->RD_PD == aCodFol[1112,1] .or. (cQrySRD)->RD_PD == aCodFol[1113,1] //armazena a verba de Contribuicao Adicional
						nVCol25 := (cQrySRD)->RD_VALOR
						lReg	:= .T.
					Endif

					If(cQrySRD)->RD_PD == aCodFol[0737,1]       // armazena Vivienda
						nVCol26 := (cQrySRD)->RD_VALOR
						lReg	:= .T.
					Endif
					If(cQrySRD)->RD_PD == aCodFol[1227,1]  .and. (cQrySRA)->RA_TPSEGUR $ "E* "     // armazena Fondo Solidario
						nVCol27 := (cQrySRD)->RD_VALOR
						lReg	:= .T.
					Endif
					If(cQrySRD)->RD_PD == aCodFol[1227,1]  .and. (cQrySRA)->RA_TPSEGUR $ "C*M"      // armazena Fondo Solidario MINEROS
						nVCol28 := (cQrySRD)->RD_VALOR
						lReg	:= .T.
					Endif
					(cQrySRD)->(dbSkip())
				End

			Next nAux
			(cQrySRD)->(dbCloseArea())
		Endif

		//totaliza variaveis
		nTotFunc+= 1

		If nVCol21 <> 0 .OR. nVCol22 <> 0 .OR. nVCol23 <> 0 .OR. nVCol24 <> 0
            nCol21Tot += nVCol21
            nCol22Tot += nVCol22
            nCol23Tot += nVCol23
            nCol24Tot += nVCol24
            nCol25Tot += nVCol25
			nCol26Tot += nVCol26
			nCol27Tot += nVCol27
			nCol28Tot += nVCol28
			nVCol21  := nVCol22 := nVCol23 := 0
			nVCol24  := nVCol25 := nVCol26 := 0
			nVCol27  := nVCol28 :=  0
		Endif

		(cQrySRA)->(dbSkip())
	EndDo

	If !(len(aPerAberto) < 1)
		//montagem da query  para totalizar os funcionarios
		cQuery := "SELECT SUM (RC_VALOR) AS NTOT "
		cQuery += " FROM " + RetSqlName("SRA") + " SRA, " + RetSqlName("SRC") + " SRC "
		cQuery += " WHERE "
		cQuery += " SRC.RC_FILIAL = SRA.RA_FILIAL "
		cQuery += " AND "
		cQuery += " SRC.RC_MAT = SRA.RA_MAT "
		cQuery += " AND "
		cQuery += " RC_FILIAL = '" + cFilAnt + "'"
		cQuery += " AND "
		cQuery += " RC_PD = '" + cCodFolJub + "'"
		cQuery += " AND "
		cQuery += " RC_PERIODO IN " + cPeriodos
		cQuery += " AND "
		cQuery += " RA_TPAFP = '" + If(nTipo = 1, "1", "2") + "'"
		cQuery += " AND "
		cQuery += " SRC.D_E_L_E_T_ <> '*'"
		cQuery += " AND "
		cQuery += " SRA.D_E_L_E_T_ <> '*'"

	ElseIf !(len(aPerFechado) < 1)

		cQuery := "SELECT SUM (RD_VALOR) AS NTOT "
		cQuery += " FROM " + RetSqlName("SRA") + " SRA, " + RetSqlName("SRD") + " SRD "
		cQuery += " WHERE "
		cQuery += " SRD.RD_FILIAL = SRA.RA_FILIAL "
		cQuery += " AND "
		cQuery += " SRD.RD_MAT = SRA.RA_MAT "
		cQuery += " AND "
		cQuery += " RD_FILIAL = '" + cFilAnt + "'"
		cQuery += " AND "
		cQuery += " RD_PD = '" + cCodFolJub + "'"
		cQuery += " AND "
		cQuery += " RD_PERIODO IN " + cPeriodos
		cQuery += " AND "
		cQuery += " RA_TPAFP = '" + If(nTipo = 1, "1", "2") + "'"
		cQuery += " AND "
		cQuery += " SRD.D_E_L_E_T_ <> '*'"
		cQuery += " AND "
		cQuery += " SRA.D_E_L_E_T_ <> '*'"
	Endif

	If !(len(aPerAberto) < 1) .Or. !(len(aPerFechado) < 1)

	   	cQuery	:= ChangeQuery( cQuery )
		IF ( MsOpenDbf(.T.,"TOPCONN",TcGenQry(,,cQuery),"__QRYSUM",.T.,.T.) )
			NTOT := __QRYSUM->NTOT
					__QRYSUM->( dbCloseArea() )
		Endif

		//totaliza campos

		nVCol33 := (0.1392 * nCol21Tot)
		nVCol34 := (0.105  * nCol22Tot)
		nVCol35 := (0.0392 * nCol23Tot)
		nVCol36 := (0.005  * nCol24Tot)
		nVCol37 := nCol25Tot
		nVCol38 := nVCol33 + nVCol34 + nVCol35 + nVCol36 + nVCol37
		nVCol42 := nCol26Tot
		nVCol43 := (0.02   * nCol26Tot)
		nVCol47 := nCol27Tot
		nVCol48 := nCol28Tot
		nVCol49 := (0.03   * nCol27Tot)
		nVCol50 := (0.005  * nCol27Tot)
		nVCol51 := (0.02   * nCol28Tot)
 		nVCol52 :=  nVCol49 + nVCol50 + nVCol51

		//imprime relatorio
		If nTotFunc <> 0
			oPrint:Endpage()
			ImprAFP()
		Endif
	Endif

	If !lQuery
		dbSelectArea(cQrySRA)
		dbSetOrder(nSavOrdem)
		dbGoTo(nSavRec)
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna o alias padrao                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuery
	If Select(cQrySRA) > 0
	 (cQrySRA)->(dbCloseArea())
	Endif
	If Select(cQrySRD) > 0
	 (cQrySRD)->(dbCloseArea())
	Endif
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImprAFP   ºAutor  ³Erika Kanamori      º Data ³  03/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImprAFP()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³FORMULARIO DE PAGO DE CONTRIBUCIONES                                        |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:StartPage() 			//Inicia uma nova pagina

oPrint:say ( 0050, 0030, aInfo[3], oFont09)
oPrint:say ( 0100, 0030, aInfo[5], oFont09)

oPrint:say ( 0150, 0680, STR0006, oFont14n)// "FORMULARIO DE PAGO DE CONTRIBUCIONES"
oPrint:say ( 0200, 0620, STR0007, oFont12)//"Seguro Social Obligatorio y Aportes para Vivienda"


oPrint:say ( 0250, 0800, STR0008, oFont12)//"Período de Cotización: "
oPrint:say ( 0250, 1370, cAno + "/" + cMes, oFont12)

oPrint:say ( 0300, 0900, If(nTipo=1, STR0004, STR0005), oFont12)// "AFP Previsión" ou "AFP Futuro de Bolívia"

oPrint:box ( 0400, 0020, 1100, 2440 ) //box
oPrint:say ( 0400, 0900, "APORTES AL SISTEMA INTEGRAL DE PENSIONES", oFont10n)

oPrint:line ( 0450, 0020, 0450, 2440 )
oPrint:line ( 0500, 0020, 0500, 2440 )
oPrint:line ( 0550, 0020, 0550, 2440 )
oPrint:line ( 0600, 0020, 0600, 2440 )
oPrint:line ( 0650, 0020, 0650, 2440 )
oPrint:line ( 0700, 0020, 0700, 2440 )
oPrint:line ( 0750, 0020, 0750, 2440 )
oPrint:line ( 0800, 0020, 0800, 2440 )
oPrint:line ( 0850, 0020, 0850, 2440 )
oPrint:line ( 0900, 0020, 0900, 2440 )
oPrint:line ( 0950, 0020, 0950, 2440 )
oPrint:line ( 1000, 0020, 1000, 2440 )
oPrint:line ( 1050, 0020, 1050, 2440 )

oPrint:line ( 0450, 2135, 1100, 2135 )     //VERTICAL


   // Os titulos foram definidos diretamente no fonte pois trata-se de formulario legal e nao pode ser alterado.
	oPrint:say ( 0455, 0030, "(29)", oFont07)
  	oPrint:say ( 0455, 2150, Transform(nCol21Tot, "999,999,999.99"), oFont08)
	oPrint:say ( 0463, 0085, "SUMATORIA DEPENDIENTE O ASEGURADO COM PENSION DEL SIP MENOR DE 65 AÑOS QUE DECIDE SEGUIR APORTANDO AL SIP O DEPENDIENTE COM PENSION DE INVALIDEZ SUMA(21)", oFont06)

	oPrint:say ( 0505, 0030, "(30)SUMATORIA DEPENDIENTE MAYOR DE 65 AÑOS O ASEGURADO COM PENSION DEL SIP MAYOR DE 65 AÑOS QUE DECIDE SEGUIR APORTANDO AL SIP SUMA(22)", oFont07)
	oPrint:say ( 0505, 2150, Transform(nCol22Tot, "999,999,999.99"), oFont08)

	oPrint:say ( 0555, 0030, "(31)SUMATORIA ASEGURADO COM PENSION DEL SIP MENOR DE 65 AÑOS QUE DECIDE NO SEGUIR APORTANDO AL SIP SUMA(23)", oFont07)
	oPrint:say ( 0555, 2150, Transform(nCol23Tot, "999,999,999.99"), oFont08)

	oPrint:say ( 0605, 0030, "(32)SUMATORIA ASEGURADO COM PENSION DEL SIP MAYOR DE 65 AÑOS QUE DECIDE NO SEGUIR APORTANDO AL SIP SUMA(24))", oFont07)
	oPrint:say ( 0605, 2150, Transform(nCol24Tot, "999,999,999.99"), oFont08)

	oPrint:say ( 0655, 0030, "(33)", oFont07)
	oPrint:say ( 0655, 2150, Transform(nVCol33, "999,999,999.99"), oFont08)
	oPrint:say ( 0663, 0085, "CONTRIBUCÍON DEPENDIENTE O ASEGURADO COM PENCION DEL SIP MENOR DE 65 AÑOS QUE DECIDE SEGUIR APORTANDO AL SIP O DEPENDIENTE DE INVALIDEZ (FILA 29 X 13,92%)", oFont06)

	oPrint:say ( 0705, 0030, "(34)", oFont07)
	oPrint:say ( 0705, 2150, Transform(nVCol34, "999,999,999.99"), oFont08)
	oPrint:say ( 0713, 0085, "CONTRIBUCÍON DEPENDIENTE MAYOR DE 65 AÑOS O ASEGURADO COM PENSION DEL SIP MAYOR DE 65 AÑOS QUE DECIDE SEGUIR APORTANDO AL SIP(FILA 30 x 10.50%)", oFont06)

	oPrint:say ( 0755, 0030, "(35)CONTRIBUCÍON ASEGURADO COM PENSION DEL SIP MENOR DE 65 AÑOS QUE DECIDE NO SEGUIR APORTANDO AL SIP (FILA 31 x 3.92%)", oFont07)
	oPrint:say ( 0755, 2150, Transform(nVCol35, "999,999,999.99"), oFont08)

	oPrint:say ( 0805, 0030, "(36)CONTRIBUCÍON ASEGURADO COM PENSION DEL SIP MAYOR DE 65 AÑOS QUE DECIDE NO SEGUIR APORTANDO AL SIP (FILA 32 x 0.5%)", oFont07)
	oPrint:say ( 0805, 2150, Transform(nVCol36, "999,999,999.99"), oFont08)

	oPrint:say ( 0855, 0030, "(37)SUMATORIA COTIZACIONES ADICIONALES SUMA(25)", oFont07)
	oPrint:say ( 0855, 2150, Transform(nCol25Tot, "999,999,999.99"), oFont08)

	oPrint:say ( 0905, 0030, "(38)SUB-TOTAL PRIMAS Y CONTRIBUCIONES (33 + 34 + 35 + 36 + 37)", oFont07)
	oPrint:say ( 0905, 2150, Transform(nVCol38, "999,999,999.99"), oFont08)

	oPrint:say ( 0955, 0030, "(39)INTERES POR MORA", oFont07)
	oPrint:say ( 0955, 2150, Transform(nInteres, "999,999,999.99"), oFont08)

	oPrint:say ( 1005, 0030, "(40)INTERES INCREMENTAL", oFont07)
	oPrint:say ( 1005, 2150, Transform(nIncrement, "999,999,999.99"), oFont08)

	oPrint:say ( 1055, 0030, "(41)TOTAL A PAGAR SIP (38 + 39 + 40)", oFont07)
	oPrint:say ( 1055, 2150, Transform(nVCol38+nInteres+nIncrement, "999,999,999.99"), oFont08)


	//MONTAGEM FO FORMULARIO APORTE PATRONAL PARA VIVIENDA

	oPrint:box ( 1200, 0020, 1500, 2440) //box
	oPrint:say ( 1200, 0900, "APORTE PATRONAL PARA VIVIENDA", oFont10n)


	oPrint:line ( 1250, 0020, 1250, 2440 )
	oPrint:line ( 1300, 0020, 1300, 2440 )
	oPrint:line ( 1350, 0020, 1350, 2440 )
	oPrint:line ( 1400, 0020, 1400, 2440 )
	oPrint:line ( 1450, 0020, 1450, 2440 )

	oPrint:line ( 1250, 2135, 1500, 2135 )     //VERTICAL


	oPrint:say ( 1255, 0030, "(42) SUMATORIA DEL TOTAL GANADO SUMA(26)", oFont07)
	oPrint:say ( 1255, 2150, Transform(nVCol42, "999,999,999.99"), oFont08)

	oPrint:say ( 1305, 0030, "(43)CONTRIBUCIONES DE VIVIENDA ( FILA 42 x 2%)", oFont07)
	oPrint:say ( 1305, 2150, Transform(nVCol43, "999,999,999.99"), oFont08)

	oPrint:say ( 1355, 0030, "(44)INTERES POR MORA", oFont07)
	oPrint:say ( 1355, 2150, Transform(nIntViv, "999,999,999.99"), oFont08)

	oPrint:say ( 1405, 0030, "(45)INTERES INCREMENTAL", oFont07)
	oPrint:say ( 1405, 2150, Transform(nIncViv, "999,999,999.99"), oFont08)

	oPrint:say ( 1455, 0030, "(50)TOTAL A PAGAR  ( 43 + 44 + 45 )" , oFont07)
	oPrint:say ( 1455, 2150, Transform(nVcol43+nIntViv+nIncViv, "999,999,999.99"), oFont08)


	//MONTAGEM FORMULARIO APORTE SOLIDARIO PATRONAL Y DEL ASEGURADO

	oPrint:box ( 1700, 0020, 2200, 2440) //box
	oPrint:say ( 1700, 0900, "APORTE SOLIDARIO PATRONAL Y DEL ASEGURADO", oFont10n)


	oPrint:line ( 1750, 0020, 1750, 2440 )  // 2750
	oPrint:line ( 1800, 0020, 1800, 2440 )
	oPrint:line ( 1850, 0020, 1850, 2440 )
	oPrint:line ( 1900, 0020, 1900, 2440 )
	oPrint:line ( 1950, 0020, 1950, 2440 )
	oPrint:line ( 2000, 0020, 2000, 2440 )
	oPrint:line ( 2050, 0020, 2050, 2440 )
	oPrint:line ( 2100, 0020, 2100, 2440 )
	oPrint:line ( 2150, 0020, 2150, 2440 )

	oPrint:line ( 1750, 2135, 2200, 2135 )     //VERTICAL


	oPrint:say ( 1755, 0030, "(47) SUMATORIA DEL TOTAL GANADO SUMA(27)", oFont07)
	oPrint:say ( 1755, 2150, Transform(nVCol47, "999,999,999.99"), oFont08)

	oPrint:say ( 1805, 0030, "(48) SUMATORIA DEL TOTAL GANADO APORTE SOLIDARIO MINERO SUMA(28)", oFont07)
	oPrint:say ( 1805, 2150, Transform(nVCol48, "999,999,999.99"), oFont08)

	oPrint:say ( 1855, 0030, "(49) APORTE PATRONAL SOLIDARIO (FILA 47 * 3%)", oFont07)
	oPrint:say ( 1855, 2150, Transform(nVCol49, "999,999,999.99"), oFont08)

	oPrint:say ( 1905, 0030, "(50) APORTE SOLIDARIO DEL ASEGURADO (FILA 47 * 0.5%)", oFont07)
	oPrint:say ( 1905, 2150, Transform(nVCol50, "999,999,999.99"), oFont08)

	oPrint:say ( 1955, 0030, "(51) APORTE SOLIDARIO MINERO (FILA 48 * 2%)", oFont07)
	oPrint:say ( 1955, 2150, Transform(nVCol51, "999,999,999.99"), oFont08)

	oPrint:say ( 2005, 0030, "(52) SUB-TOTAL PRIMAS Y CONTRIBUCIONES (49 + 50 +51)", oFont07)
	oPrint:say ( 2005, 2150, Transform(nVCol52, "999,999,999.99"), oFont08)

	oPrint:say ( 2055, 0030, "(53)INTERES POR MORA", oFont07)
	oPrint:say ( 2055, 2150, Transform(nIntSol, "999,999,999.99"), oFont08)

	oPrint:say ( 2105, 0030, "(54)INTERES INCREMENTAL", oFont07)
	oPrint:say ( 2105, 2150, Transform(nIncSol, "999,999,999.99"), oFont08)

	oPrint:say ( 2155, 0030, "(55)TOTAL A PAGAR  ( 52 + 53 + 54 )" , oFont07)
	oPrint:say ( 2155, 2150, Transform(nVcol52+nIntViv+nIncViv, "999,999,999.99"), oFont08)


Return
