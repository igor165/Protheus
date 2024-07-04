#Include "PROTHEUS.CH"
#INCLUDE "GPERSOL.CH"
#DEFINE   nColMax	2350
#DEFINE   nLinMax  2900

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPERSOL  ³ Autor ³ Luis Trombini           ³ Data   ³ 22/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao do Forumulario de Pago de Contribuciones.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPERSOL()                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS      ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³07/05/15³ PCREQ-4256³Se elimina funcion AjustaSX1T y AjustaHlp ³±±
±±³            ³        ³           ³que realizan modificacion al diccionario  ³±±
±±³            ³        ³           ³de datos(SX1) por motivo de ajuste nueva  ³±±
±±³            ³        ³           ³estructura de SXs para V12                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function GPERSOL()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Locais (Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Local cDesc1 		:= STR0001		//"Formulário de Pago de Contribuciones"
Local cDesc2 		:= STR0002		//"Se imprimira de acuerdo con los parametros solicitados por el usuario."
Local cDesc3 		:= STR0003		//""Obs.: Debe imprimirse un Formulario Mensual para cada Filial.""
Local cString		:= "SRA"        // alias do arquivo principal (Base)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Private(Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private nomeprog	:= "GPERSOL"
Private aReturn 	:= { , 1,, 2, 2, 1,"",1 }
Private nLastKey 	:= 0
Private cPerg   	:= "GPRSOL"

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis Utilizadas na funcao de Impressao                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private Titulo		:= STR0001		//"Formulário de Pago de Contribuciones" - titulo da janela de pergunte
Private nTamanho	:= "M"
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
Private nIntSol
Private nIncSol

Private oPrint
Private oFont07,oFont08, oFont09, oFont12, oFont10, oFont10n, oFont14n

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

pergunte("GPRSOL",.F.)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Envia controle para a funcao SETPRINT                        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
wnrel:="GPERSOL"            //Nome Default do relatorio em Disco
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
nIntSol		:= mv_par13
nIncSol		:= mv_par14


	//-- Objeto para impressao grafica
	oPrint 	:= TMSPrinter():New( If(nTipo = 1, STR0004, STR0005) ) //"Planilla Previsión" ou
																    //"Planilla Futuro de Bolívia"
 	oPrint:SetPortrait()

Titulo := If(nTipo = 1, STR0004, STR0005) //"Planilla Previsión" ou "Planilla Futuro de Bolívia"

RptStatus({|lEnd| IMPSOL(@lEnd,wnRel,cString,.F. )},Capital(Titulo))

	oPrint:Preview()  							// Visualiza impressao grafica antes de imprimir

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPSOL    ºAutor  ³Erika Kanamori      º Data ³  03/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IMPSOL()

Local cAcessaSRA	:= &( " { || " + ChkRH( "GPERSOL" , "SRA", "2" ) + " } " )
Local cFim := ""
Local nSavRec
Local nSavOrdem
Local aPerAberto  := {}
Local aPerFechado := {}
Local aPerTodos   := {}
Local cFilAnt	  := ""
Local aCodFol  	  := {}
Local nAux
Local lAchou      := .F.
Local cVerCodFol
Local cCodFolJub  := ""
Local cContrAdic
Local cContrVol
Local nIdade	  := 0
Local ntot		  := 0
Local nTotFunc    := 0

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis para controle em ambientes TOP.                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cAlias   := ""
Local cQrySRA := "SRA"
Local cQrySRC := "SRC"
Local cQrySRD := "SRD"
Local cQuery
Local aStruct  := {}
Local lQuery  := .F.
Local cCateg
Local cSitu
Local nVlMinSol := 0


//Vaviaveis private para impressao
Private nVCol21 	:= 0
Private nVCol22 	:= 0
Private nVCol23 	:= 0
Private nVCol24 	:= 0
Private nVCol25 	:= 0
Private nVCol26 	:= 0
Private nVCol27 	:= 0
Private nVCol28 	:= 0
Private nVCol29 	:= 0
Private nVCol30 	:= 0
Private nVCol31 	:= 0
Private nVCol32 	:= 0
Private nCol21Tot	:= 0
Private nCol22Tot	:= 0
Private nCol23Tot	:= 0
Private nCol24Tot	:= 0
Private nVDesAp1    := 0
Private nVDesAp2    := 0
Private nVDesAp3    := 0


Private aInfo		:= {}

// Carrega Mneumonico "P_VLMINSOL"
// Valor minimo para contribuição nacional de Solidariedade                            
SetMnemonicos(xFilial("RCA"),NIL,.T.,"P_VLMINSOL")
nVlMinSol := If( Type("P_VLMINSOL") == "U", 0, P_VLMINSOL )

#IfDef TOP

	//Filtra do SRA: filial, matricula de/ate, centro de custo de/ate, categoria e situacoes
		cAlias := "SRA"

		cQrySRA := "QSRA"

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Buscar Situacao e Categoria em formato para SQL              ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cSitu   := "("
		For nAux := 1 To (Len( cSit )-1)
			cSitu += "'" + Substr( cSit, nAux, 1) + "',"
		Next nAux
			cSitu += "'" + Substr( cSit, len(cSit)-1, 1) + "')"

		cCateg   := "("
		For nAux := 1 To (Len( cCat )-1)
			cCateg += "'" + Substr( cCat, nAux, 1) + "',"
		Next nAux
			cCateg	+= "'" + Substr( cCat, len(cCat)-1, 1) + "')"


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
		cQuery += " D_E_L_E_T_ = '' "
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

	NVDESAP1 := FTABELA("S011",1,6)

	NVDESAP2 := FTABELA("S011",2,6)

	NVDESAP3 := FTABELA("S011",3,6)



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


		//se filial eh diferente da anterior, inicia-se nova pagina
		If cFilAnt <> (cQrySRA)->RA_FILIAL

			If nTotFunc <> 0
			    //totaliza campos

			    nVCol25 := nCol21Tot
			    nVCol26 := (0.01   * nCol22Tot)
			    nVCol27 := (0.05   * nCol23Tot)
			    nVCol28 := (0.10   * nCol24Tot)
			    nVCol29 := nVCol26 + nVCol27 + nVCol28


				//imprime relatorio
				oPrint:Endpage()
				ImprSOL()
			Endif

			//Zera variaveis para cada filial
			nVCol21  := nVCol22 := nVCol23 := 0
			nVCol24  := nVCol25 := nVCol26 := 0
			nVCol27  := nVCol28 := nVCol29 := 0
			nCol21Tot := nCol22Tot  := nCol23Tot  := 0
			nCol24Tot := 0

			fInfo(@aInfo, (cQrySRA)->RA_FILIAL)     //carrega informacoes da filial

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Carrega Variaveis Codigos Da Folha                           ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If !fP_CodFol(@aCodFol,(cQrySRA)->RA_FILIAL)
				Return
			Endif

  			cVerCodFol:= aCodFol[731,1]// armazena verba relacionada a SOL
			cCodFolJub:= aCodFol[737,1]// armazena verba relacionada a SOL para funcionarios jubilados
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
			nIdade:= Calc_Idade( aPerAberto[len(aPerAberto)][6] , (cQrySRA)->RA_NASC )

			If lQuery
				cAlias := "SRC"
				cQrySRC := "QSRC"
				lAchou  := .T.
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
				cQuery += " D_E_L_E_T_ = ''
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

					If (cQrySRC)->RC_PD == aCodFol[1227,1]

						nVCol21 := (cQrySRC)->RC_VALOR
						nVCol22 := Max(nVCol21 - NVDESAP1, 0)
						nVCol23 := Max(nVCol21 - NVDESAP2, 0)
						nVCol24 := Max(nVCol21 - NVDESAP3, 0)					
						
						lReg	:= .T.
					Endif

					(cQrySRC)->(dbSkip())
				EndDo
			Next nAux
			(cQrySRC)->(dbCloseArea())
		Endif


		//procura registros do funcionario no SRD
		If !(len(aPerFechado) < 1)

			//zera variaveis para cada funcionario
			nIdade := nTotAux := 0
			//Calcula a idade baseada na data de nascimento e no ultimo dia do periodo
			nIdade:= Calc_Idade( aPerFechado[len(aPerFechado)][6] , (cQrySRA)->RA_NASC )

			If lQuery
				cAlias  := "SRD"
				cQrySRD := "QSRD"
				lAchou  := .T.
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
				cQuery += " D_E_L_E_T_ = ''
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
				//Se o Roteiro de calculo vier em branco no array pega o roteiro ordinario
				(cQrySRD)->(dbGoTop())

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

				If (cQrySRD)->RD_PD == aCodFol[1227,1]

					nVCol21 := (cQrySRD)->RD_VALOR
					nVCol24 := Max(nVCol21 - NVDESAP1, 0)
					nVCol23 := Max(nVCol21 - NVDESAP2, 0)
					nVCol22 := Max(nVCol21 - NVDESAP3, 0)

					lReg	:= .T.
				Endif

				(cQrySRD)->(dbSkip())
			EndDo
			Next nAux
			(cQrySRD)->(dbCloseArea())
		Endif

		// Se o valor for menor que o minimo definido no mnemonico zera variáveis vai para o próximo registro
		If nVCol21 < nVlMinSol
			nVCol21  := nVCol22 := nVCol23  := nVCol24 := 0
			(cQrySRA)->(dbSkip())
			LOOP
		EndIf

		//totaliza variaveis
		nTotFunc+= 1

		If nVCol21 <> 0 .OR. nVCol22 <> 0 .OR. nVCol23 <> 0 .OR. nVCol24 <> 0

            nCol21Tot += nVCol21
            nCol22Tot += nVCol22
            nCol23Tot += nVCol23
            nCol24Tot += nVCol24
			nVCol21  := nVCol22 := 0
			nVCol23  := nVCol24 := 0

		Endif
		(cQrySRA)->(dbSkip())

	EndDo

	If lAchou
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
			cQuery += " SRC.D_E_L_E_T_ = ''"
			cQuery += " AND "
			cQuery += " SRA.D_E_L_E_T_ = ''"

		Else
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
			cQuery += " SRD.D_E_L_E_T_ = ''"
			cQuery += " AND "
			cQuery += " SRA.D_E_L_E_T_ = ''"
		Endif
   		cQuery	:= ChangeQuery( cQuery )
		IF ( MsOpenDbf(.T.,"TOPCONN",TcGenQry(,,cQuery),"__QRYSUM",.T.,.T.) )
			NTOT := __QRYSUM->NTOT
					__QRYSUM->( dbCloseArea() )
		Endif

		//totaliza campos
      	nVCol25 := nCol21Tot
	  	nVCol26 := (0.01   * nCol22Tot)
	  	nVCol27 := (0.05   * nCol23Tot)
	  	nVCol28 := (0.10   * nCol24Tot)
	  	nVCol29 := nVCol26 + nVCol27 + nVCol28

		//imprime relatorio
		If nTotFunc <> 0
			oPrint:Endpage()
			ImprSOL()
		Endif
	EndIf
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
±±ºPrograma  ³ImprSOL   ºAutor  ³Erika Kanamori      º Data ³  03/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImprSOL()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³FORMULARIO DE PAGO DE CONTRIBUCIONES                                        |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:StartPage() 			//Inicia uma nova pagina

oPrint:say ( 0050, 0030, aInfo[3], oFont09)
oPrint:say ( 0100, 0030, aInfo[5], oFont09)

oPrint:say ( 0150, 0580, STR0006, oFont14n)// "FORMULARIO DE PAGO DE CONTRIBUCIONES"
oPrint:say ( 0200, 0800, STR0007, oFont12)//


oPrint:say ( 0250, 0800, STR0008, oFont12)//"Período de Cotización: "
oPrint:say ( 0250, 1490, cAno + "/" + cMes, oFont12)

oPrint:say ( 0300, 0800, If(nTipo=1, STR0004, STR0005), oFont12)// "AFP Previsión" ou "AFP Futuro de Bolívia"

oPrint:box ( 0400, 0020, 0855, 1950) //box
oPrint:say ( 0400, 0600, "RESUMEN DE CONTRIBUCIONES A FONDO SOLIDARIO", oFont10n)

oPrint:line ( 0450, 0020, 0450, 1950 )
oPrint:line ( 0500, 0020, 0500, 1950 )
oPrint:line ( 0550, 0020, 0550, 1950 )
oPrint:line ( 0600, 0020, 0600, 1950 )
oPrint:line ( 0650, 0020, 0650, 1950 )
oPrint:line ( 0700, 0020, 0700, 1950 )
oPrint:line ( 0750, 0020, 0750, 1950 )
oPrint:line ( 0800, 0020, 0800, 1950 )

oPrint:line ( 0450, 1650, 0855, 1650 )     //VERTICAL



   // Os titulos foram definidos diretamente no fonte pois trata-se de formulario legal e nao pode ser alterado.
	oPrint:say ( 0455, 0030, "(25)SUMATORIA TOTAL GANADO SOLIDARIO (SIN TOPE SALARIAL) SUMA(21)", oFont08)
  	oPrint:say ( 0455, 1650, Transform(nCol21Tot, "999,999,999.99"), oFont08)

	oPrint:say ( 0505, 0030, "(26)APORTE NACIONAL SOLIDARIO 1% (SUMA 22 * 1%)", oFont08)
	oPrint:say ( 0505, 1650, Transform(nVCol26, "999,999,999.99"), oFont08)

	oPrint:say ( 0555, 0030, "(27)APORTE NACIONAL SOLIDARIO 1% (SUMA 23 * 5%)", oFont08)
	oPrint:say ( 0555, 1650, Transform(nVCol27, "999,999,999.99"), oFont08)

	oPrint:say ( 0605, 0030, "(28)APORTE NACIONAL SOLIDARIO 1% (SUMA 24 * 10%)", oFont08)
	oPrint:say ( 0605, 1650, Transform(nVCol28, "999,999,999.99"), oFont08)

	oPrint:say ( 0655, 0030, "(29)SUB-TOTAL APORTE NACIONAL SOLIDARIO 1% (26 + 27 + 28)", oFont08)
	oPrint:say ( 0655, 1650, Transform(nVCol29, "999,999,999.99"), oFont08)

	oPrint:say ( 0705, 0030, "(30)INTERES POR MORA", oFont08)
	oPrint:say ( 0705, 1650, Transform(nIntSol, "999,999,999.99"), oFont08)

	oPrint:say ( 0755, 0030, "(31)INTERES INCREMENTAL", oFont08)
	oPrint:say ( 0755, 1650, Transform(nIncSol, "999,999,999.99"), oFont08)

	oPrint:say ( 0805, 0030, "(32)TOTAL A PAGAR SIP (38 + 39 + 40)", oFont08)
	oPrint:say ( 0805, 1650, Transform(nVCol29+nIntSol+nIncSol, "999,999,999.99"), oFont08)


Return
