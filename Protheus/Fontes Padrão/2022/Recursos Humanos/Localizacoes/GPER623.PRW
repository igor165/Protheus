#Include "PROTHEUS.CH"
#INCLUDE "GPER623.CH"
#DEFINE   nColMax	3050
#DEFINE   nLinMax  2900
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  GPER623     ³ Autor ³ A.Shibao              ³ Data ³ 22.10.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³   Relatorio de Subsidios Por Incapacidad Temporal              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³Cham. ³  Motivo da Alteracao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³06/05/15³PCREQ-4256³Se elimina la funcion AjustaHlp, la cual  ³±±
±±³            ³        ³          ³realiza la modificacion aldiccionario de  ³±±
±±³            ³        ³          ³datos(SX1) por motivo de adecuacion  nueva³±±
±±³            ³        ³          ³estructura de SXs para version 12         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function GPER623()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Locais (Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cDesc1 		:= STR0001		//"Subsidios por Incapacidad Temporal"
Local cDesc2 		:= STR0002		//"Se imprimira de acuerdo con los parametros solicitados por el usuario."
Local cDesc3 		:= STR0003		//"Obs.: Debe imprimirse un Formulario Mensual para cada Filial."
Local cString		:= "SRA"        // alias do arquivo principal (Base)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Private(Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private nomeprog	:= "GPER623"
Private aReturn 	:= { , 1,, 2, 2, 1,"",1 }
Private nLastKey 	:= 0
Private cPerg   	:= "GPR623"

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis Utilizadas na funcao de Impressao                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private Titulo		:= STR0001		//"Subsidios por Incapacidad Temporal"
Private nTamanho	:= "M"
Private nOrdem
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
Private cCajaDe		:= ""
Private cCajaAte	:= ""
Private cProcessos  := ""
Private cRoteiros	:= ""
Private cAnoMes		:= ""
Private dSr8ini		:= cTod("//")
Private dSr8Fim		:= cTod("//")
Private dAdmissa    := ""
Private cConcepto   := ""

Private lEnd

Private oPrint
Private oFont12, oFont10, oFont14n, oFont09,oFont08, oFont06

	oFont12n:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)	//Negrito
	oFont10 := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
	oFont14n:= TFont():New("Courier New",14,14,,.T.,,,,.T.,.F.)  //Negrito
	oFont09	:= TFont():New("Courier New",09,09,,.F.,,,,.T.,.F.)
	oFont08 := TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
	oFont06 := TFont():New("Courier New",06,06,,.F.,,,,.T.,.F.)

nEpoca:= SET(5,1910)
//-- MUDAR ANO PARA 4 DIGITOS
SET CENTURY ON

pergunte("GPR623",.F.)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Envia controle para a funcao SETPRINT                        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
wnrel:="GPER623"            //Nome Default do relatorio em Disco
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
³ mv_par01        //  Filial De						           ³
³ mv_par02        //  Filial Ate					           ³
³ mv_par03        //  Mes/Ano?     				               |
³ mv_par04        //  Matricula De                             ³
³ mv_par05        //  Matricula Ate                            ³
³ mv_par06        //  Centro de Custo De                       ³
³ mv_par07        //  Centro de Custo Ate                      ³
³ mv_par08        //  Nome De                                  ³
³ mv_par09        //  Nome Ate                                 ³
³ mv_par10        //  Situações a imp?                         ³
³ mv_par11        //  Categorias a imp?                        ³
³ mv_par12        //  Caixa De?                                ³
³ mv_par13        //  Caixa Ate?                               ³
| mv_par14		  //  Processos ?							   |
| mv_par15        //  Roteiros ?							   |
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nOrdem   	:= aReturn[8]

cFilialDe 	:= mv_par01
cFilialAte  := mv_par02
cMes 		:= substr( mv_par03, 1, 2 )
cAno 		:= substr( mv_par03, 3, 4 )
cMatDe		:= mv_par04
cMatAte     := mv_par05
cCustoDe    := mv_par06
cCustoAte   := mv_par07
cNomeDe		:= mv_par08
cNomeAte	:= mv_par09
cSit        := mv_par10
cCat        := mv_par11
cCajaDe		:= mv_par12
cCajaAte	:= mv_par13
cProcessos	:= If( Empty(mv_par14),"", ConvQry(alltrim(mv_par14),"RA_PROCES"))
cRoteiros	:= If( Empty(mv_par15),"'FOL'", ConvQry(AllTrim(mv_par15),"RD_ROTEIR"))
cAnoMes		:= cAno+cMes


	//-- Objeto para impressao grafica
	oPrint 	:= TMSPrinter():New( UPPER(STR0001))  //" SUBSIDIO POR INCAPACIDAD TEMPORAL "
    oPrint:SetLandscape()						  //Modo Paisagem

	Titulo := ( STR0001 ) 				    //"SUBSIDIO POR INCAPACIDAD TEMPORAL"

	RptStatus({|lEnd| Imp623(@lEnd,wnRel,cString,.F. )},Capital(Titulo))

	oPrint:Preview()  						// Visualiza impressao grafica antes de imprimir

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Imp623    ºAutor  ³A.Shibao            º Data ³  22/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Imp623()

Local cAcessaSRA	:= &( " { || " + ChkRH( "GPER623" , "SRA", "2" ) + " } " )

Local nSavRec
Local nSavOrdem
Local nAux
Local cVerCodFol
Local nCajaSalud
Local aPerAberto	:= {}
Local aPerFechado	:= {}
Local aPerTodos		:= {}
Local aCodFol		:= {}
Local cFim 			:= ""
Local cFilAnt		:= ""

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis para controle em ambientes TOP.                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cAlias   	:= ""
Local cQuery
Local aStruct  	:= {}
Local lQuery  	:= .F.
Local cSitu
Local cCateg

Local cMnProces	:= ""
Local cMxProces	:= "ZZZZZ"

Local lAllProCs	:= .F.
Local nLin		:= 270
Local nColun	:= 1200


Local cFil		:= ""
Local cMat		:= ""

//Vaviaveis private para impressao

Private aInfo		:= {}
Private cNit
Private cEmplead
Private nTotGan     := 0
Private nTotAfas    := 0
Private nTotRec		:= 0

Private nEnferm     := 0
Private nMatern     := 0
Private nAciden     := 0

Private cQrySRA 	:= "SRA"
Private aEnfer		:={}
Private aMater		:={}
Private aAcide		:={}
Private aGanad		:={}

Private cNome		:= ""
Private lReg1		:= .F.   //consiste se existem lancamentos para o funcionario na competencia selecionada
Private lReg2		:= .F.   //consiste se existem lancamentos para o funcionario na competencia selecionada
Private lReg3		:= .F.   //consiste se existem lancamentos para o funcionario na competencia selecionada

Private cSubTitle	:= ""
Private nPerc		:= 0
Private nDiasIn		:= 0
Private nDiasRec	:= 0

Private	nTrailAfa 	:= 0
Private	nTrailSub 	:= 0
Private	nTrailRec 	:= 0


#IfDef TOP

	//Filtra do SRA: filial, matricula de/ate, centro de custo de/ate, categoria, situacoes e processos
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
		cSitu 	+= "'" + Substr( cSit, len(cSit), 1) + "')"

		cCateg   := "("
		For nAux := 1 To (Len( cCat )-1)
			cCateg += "'" + Substr( cCat, nAux, 1) + "',"
		Next nAux
		cCateg	+= "'" + Substr( cCat, len(cCat), 1) + "')"

    	// Verifica os Processos
		lAllProCs 	:= Iif(AllTrim( cProcessos ) == "*" .Or. Empty(cProcessos), .F., .T.)

		//montagem da query
		cQuery := "SELECT"
        cQuery += " RA_FILIAL,RA_MAT,RA_NOME,RA_CC,RA_ADMISSA,"
        cQuery += " RA_CATFUNC,RA_SITFOLH,RA_CAJSAL,RA_NOMECMP"
		cQuery += " FROM " + RetSqlName(cAlias)
		cQuery += " WHERE"
		cQuery += " RA_FILIAL BETWEEN '" + cFilialDe + "' AND '" + cFilialAte + "'"
		cQuery += " AND RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "'"
		cQuery += " AND RA_NOME BETWEEN '" + cNomeDe + "' AND '" + cNomeAte + "'"
		cQuery += " AND RA_CC BETWEEN '" + cCustoDe + "' AND '" + cCustoAte + "'"
		cQuery += " AND RA_CAJSAL BETWEEN '" + cCajaDe + "' AND '" + cCajaAte + "'"
		cQuery += " AND RA_SITFOLH IN " + cSitu
		cQuery += " AND RA_CATFUNC IN " + cCateg
		If !(lAllProCs)
			cQuery 	+= "AND RA_PROCES BETWEEN '" + cMnProces + "' AND '" + cMxProces + "'"
		Else
			cQuery	+= "AND   RA_PROCES  IN ("	+ cProcessos+") "
		Endif
		cQuery += " AND D_E_L_E_T_ <> '*'"
		cQuery += " ORDER BY RA_FILIAL, RA_MAT"

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
			!(SRA->RA_CATFUNC $ cCat) .Or. !(SRA->RA_SITFOLH $ cSit))
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


	 	//Zera variaveis
		nTotGan  := nTotAfas := nDiasIn	 := nTrailAfa	:= nTrailSub	:= 0
		nEnferm  := nMatern  := nAciden	 := nDiasRec	:= nTrailRec	:= 0

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Carrega Variaveis Codigos Da Folha Logada                    ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If Empty(cFilialDe)
			cFilialDe := FWCodFil()
			fInfo(@aInfo,cFilialDe)
		Else
			fInfo(@aInfo,cFilialDe) //carrega informacoes da filial
        Endif
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Carrega Variaveis Codigos Da Folha                           ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If !fP_CodFol(@aCodFol,(cQrySRA)->RA_FILIAL)
			Return
		Endif

		//carrega periodo da competencia selecionada
		fRetPerComp( cMes , cAno , , , , @aPerAberto , @aPerFechado , @aPerTodos )

		cFilAnt   := (cQrySRA)->RA_FILIAL
	    cNome     := If( !Empty((cQrySRA)->RA_NOMECMP), (cQrySRA)->RA_NOMECMP, (cQrySRA)->RA_NOME )

		//desconsidera funcionarios empregados depois do periodo selecionado
		If !len(aPerAberto) < 1 .And. (cQrySRA)->RA_ADMISSA > aPerAberto[len(aPerAberto)][6]
			(cQrySRA)->(dbSkip(1))
			Loop
		Elseif !len(aPerFechado) < 1 .And. (cQrySRA)->RA_ADMISSA > aPerFechado[len(aPerFechado)][6]
			(cQrySRA)->(dbSkip(1))
			Loop
		Endif

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Procura no SRC registros do funcionario no periodo aberto, se houver   |
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If !(len(aPerAberto) < 1)
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
				cQuery += " RC_FILIAL, RC_MAT, RC_PROCES, RC_ROTEIR, RC_PERIODO,RC_SEMANA, RC_VALOR, RC_VNAOAPL, RC_PD, RC_HORAS "
				cQuery += " FROM " + RetSqlName(cAlias)
				cQuery += " WHERE "
				cQuery += " RC_FILIAL = '" + cFilAnt + "'"
				cQuery += " AND "
				cQuery += " RC_MAT = '" + (cQrySRA)->RA_MAT + "'"
				cQuery += " AND "
				cQuery += " RC_PERIODO IN " + cPeriodos
				cQuery += " AND "
				cQuery += " RC_ROTEIR	IN ("	+ cRoteiros  +") "
				If !(lAllProCs)
					cQuery 	+= "AND RC_PROCES BETWEEN '" + cMnProces + "' AND '" + cMxProces + "'"
				Else
					cQuery	+= "AND   RC_PROCES  IN ("	+ cProcessos + ") "
				Endif
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


			While (cQrySRC)->(!Eof()) .And. (cQrySRA)->(RA_FILIAL+RA_MAT) == (cQrySRC)->(RC_FILIAL+RC_MAT)
				Do Case
					Case (cQrySRC)->RC_PD == aCodFol[747, 1]
						nTotGan 	:= (cQrySRC)->RC_VALOR            // TOTAL GANADO
  				    	Aadd (aGanad,{(cQrySRC)->RC_FILIAL,(cQrySRC)->RC_MAT, cNome, nTotGan,(cQrySRC)->RC_PERIODO,(cQrySRC)->RC_PD,(cQrySRC)->RC_HORAS, (cQrySRA)->RA_ADMISSA})

					Case (cQrySRC)->RC_PD == aCodFol[041, 1]         //751
						nEnferm 	+= 1
						nTotAfas	:= (cQrySRC)->RC_VALOR     		  // ENFERMEDAD
     				    lReg1 	    := .T.
               	    	Aadd (aEnfer,{(cQrySRC)->RC_FILIAL,(cQrySRC)->RC_MAT, cNome, nTotAfas,(cQrySRC)->RC_PERIODO,(cQrySRC)->RC_PD,(cQrySRC)->RC_HORAS, (cQrySRA)->RA_ADMISSA})

					Case (cQrySRC)->RC_PD == aCodFol[040, 1]        //750
						nMatern 	+= 1
						nTotAfas	:= (cQrySRC)->RC_VALOR     		 // MATERNIDAD
     				    lReg2 	    := .T.
               	    	Aadd (aMater,{(cQrySRC)->RC_FILIAL,(cQrySRC)->RC_MAT, cNome, nTotAfas,(cQrySRC)->RC_PERIODO,(cQrySRC)->RC_PD,(cQrySRC)->RC_HORAS, (cQrySRA)->RA_ADMISSA})

					Case (cQrySRC)->RC_PD == aCodFol[042, 1]       //752
						nAciden 	+= 1
						nTotAfas	:= (cQrySRC)->RC_VALOR    		// ACCIDENTE DE TRABAJO
     				    lReg3 		:= .T.
						Aadd (aAcide,{(cQrySRC)->RC_FILIAL,(cQrySRC)->RC_MAT, cNome, nTotAfas,(cQrySRC)->RC_PERIODO,(cQrySRC)->RC_PD,(cQrySRC)->RC_HORAS, (cQrySRA)->RA_ADMISSA})

				EndCase
			(cQrySRC)->(dbSkip())
			End
			(cQrySRC)->(dbCloseArea())
		Endif

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Procura no SRD registros do funcionario no periodo fechado, se houver  |
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If	!(len(aPerFechado) < 1)
			If lQuery
				cAlias := "SRD"
				cQrySRD := "QSRD"

				//busca periodos para formato Query
				cPeriodos   := "("
				For nAux:= 1 to (len(aPerFechado)-1)
					cPeriodos += "'" + aPerFechado[nAux][1] + "',"
				Next nAux
				cPeriodos += "'" + aPerFechado[len(aPerFechado)][1]+"')"

				//montagem da query
				cQuery := "SELECT "
				cQuery += " RD_FILIAL, RD_MAT, RD_PROCES, RD_ROTEIR, RD_PERIODO, RD_SEMANA, RD_VALOR, RD_VNAOAPL, RD_PD, RD_HORAS "
				cQuery += " FROM " + RetSqlName(cAlias)
				cQuery += " WHERE "
				cQuery += " RD_FILIAL = '" + cFilAnt + "'"
				cQuery += " AND "
				cQuery += " RD_MAT = '" + (cQrySRA)->RA_MAT + "'"
				cQuery += " AND "
				cQuery += " RD_PERIODO IN " + cPeriodos
				cQuery += " AND "
				cQuery += " RD_ROTEIR	IN ("	+ cRoteiros  +") "
				If !(lAllProCs)
					cQuery 	+= "AND RD_PROCES BETWEEN '" + cMnProces + "' AND '" + cMxProces + "'"
				Else
					cQuery	+= "AND   RD_PROCES  IN ("	+ cProcessos + ") "
				Endif
				cQuery += " AND "
				cQuery += " D_E_L_E_T_ <> '*'
				cQuery += " ORDER BY RD_FILIAL, RD_MAT, RD_PROCES, RD_ROTEIR, RD_PERIODO,RD_SEMANA"

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

			While (cQrySRD)->(!Eof()) .And.  (cQrySRA)->(RA_FILIAL+RA_MAT) == (cQrySRD)->(RD_FILIAL+RD_MAT)
				Do Case
					Case (cQrySRD)->RD_PD == aCodFol[747, 1]
						nTotGan    := (cQrySRD)->RD_VALOR
						Aadd (aGanad,{(cQrySRD)->RD_FILIAL,(cQrySRD)->RD_MAT, cNome, nTotGan,(cQrySRD)->RD_PERIODO,(cQrySRD)->RD_PD,(cQrySRD)->RD_HORAS, (cQrySRA)->RA_ADMISSA})

					Case (cQrySRD)->RD_PD == aCodFol[041, 1]  //751
						nEnferm 	+= 1
						nTotAfas 	:= (cQrySRD)->RD_VALOR
                        lReg1 		:= .T.
              	    	Aadd (aEnfer,{(cQrySRD)->RD_FILIAL,(cQrySRD)->RD_MAT, cNome, nTotAfas,(cQrySRD)->RD_PERIODO,(cQrySRD)->RD_PD,(cQrySRD)->RD_HORAS, (cQrySRA)->RA_ADMISSA})

					Case (cQrySRD)->RD_PD == aCodFol[040, 1] //750
						nMatern 	+= 1
						nTotAfas	:= (cQrySRD)->RD_VALOR
                        lReg2 		:= .T.
               	    	Aadd (aMater,{(cQrySRD)->RD_FILIAL,(cQrySRD)->RD_MAT, cNome, nTotAfas,(cQrySRD)->RD_PERIODO,(cQrySRD)->RD_PD,(cQrySRD)->RD_HORAS, (cQrySRA)->RA_ADMISSA})

					Case (cQrySRD)->RD_PD == aCodFol[042, 1] //752
						nAciden 	+= 1
						nTotAfas	:= (cQrySRD)->RD_VALOR
                        lReg3 		:= .T.
						Aadd (aAcide,{(cQrySRD)->RD_FILIAL,(cQrySRD)->RD_MAT, cNome, nTotAfas,(cQrySRD)->RD_PERIODO,(cQrySRD)->RD_PD,(cQrySRD)->RD_HORAS, (cQrySRA)->RA_ADMISSA})

				EndCase
				(cQrySRD)->(dbSkip())
			End
			(cQrySRD)->(dbCloseArea())
		Endif


	 (cQrySRA)->(dbSkip())

	EndDo

    // Controla a impressao dos subsidios
	If lReg1 == .T.  .or.  lReg2 == .T.  .or.  lReg3 == .T.

		 //controle de impressao
			If nLin == 270
				ImpTitle()
			Endif

			// ENFERMEDAD PROFESIONAL, ENFERMEDAD O ACIDENTE COMUN
			If lReg1 == .T.
				cSubTitle := UPPER(STR0004) 			//"ENFERMEDAD PROFESIONAL, ENFERMEDAD O ACIDENTE COMUN"
            	nPerc	  := POSALIAS("SRV", aCodFol[751, 1], RCM->RCM_FILIAL, "RV_PERC")
				ImpDetal(@nLin,@nColun)
				For nAux = 1 to Len(aEnfer)
   				    cFil 	 := (aEnfer[nAux][1])
					cMat 	 := (aEnfer[nAux][2])
					cNome    := ltrim(aEnfer[nAux][3])
					cPeriod	 := (aEnfer[nAux][5])		// PERIODO
					cConcepto:= (aEnfer[nAux][6])      // VERBA
					nDiasIn	 := (aEnfer[nAux][7])      // DIAS INCAPACIDAD
					dAdmissa := (aEnfer[nAux][8])      // ADMISSAO
					nTotGan  := (aGanad[nAux][4])      // GANADO
					//Retorna os afastamentos para o relatorio
				   	fBuscaAutrz(cFil, cMat , cAnoMes, @nDiasRec, @cConcepto )
				   	nTotAfas :=  ((nTotGan/nDiasRec) * nPerc ) / 100 // SUBSIDIO %
					nTotRec	 :=  nTotAfas  * nDiasIn     			  // MONTO RECONOCIDO
     				Impr623(@nLin)
					nLin+= 30
					//Totalizadores que sao usados na ImpTrailer
   					nTrailAfa += nTotGan               // TOTAL GANADO
   					nTrailSub += nTotAfas              // TOTAL SUBSIDIO
   					nTrailRec += nTotRec               // TOTAL RECONOCIDO
		   		Next nAux
		   		nLin += 10
		   		// Imprime legenda
		   		If nLin > 270 .and.nLin < 2220
					ImpTrailer(@nLin,@nColun)
				Endif
   				nTrailAfa := 0
   				nTrailSub := 0
   				nTrailRec := 0
			Else
				cSubTitle := UPPER(STR0004)				//"ENFERMEDAD PROFESIONAL, ENFERMEDAD O ACIDENTE COMUN"
				nPerc	  := 90
				ImpDetal(@nLin,@nColun)
				nLin += 30
		   		// Imprime legenda
		   		If nLin > 270 .and.nLin < 2220
					ImpTrailer(@nLin,@nColun)
				Endif
			Endif

			// MATERNIDAD
		   	If lReg2 == .T.
				cSubTitle := UPPER(STR0005)				//"MATERNIDAD"
				nPerc	  := POSALIAS("SRV", aCodFol[750, 1], RCM->RCM_FILIAL, "RV_PERC")
				nColun 	  := 1600
			   	ImpDetal(@nLin,@nColun)
			   	For nAux = 1 to Len(aMater)
				    cFil 	 := (aMater[nAux][1])
					cMat 	 := (aMater[nAux][2])
					cNome    := ltrim(aMater[nAux][3])
					cPeriod	 := (aMater[nAux][5]) 	    // PERIODO
					cConcepto:= (aMater[nAux][6])      // VERBA
					nDiasIn	 := (aMater[nAux][7])      // DIAS INCAPACIDAD
					dAdmissa := (aMater[nAux][8])      // ADMISSAO
					nTotGan  := (aGanad[nAux][4])      // GANADO
					//Retorna os afastamentos para o relatorio
				   	fBuscaAutrz(cFil, cMat , cAnoMes, @nDiasRec, @cConcepto )
				   	nTotAfas :=  ((nTotGan/nDiasRec) * nPerc ) / 100 // SUBSIDIO %
					nTotRec	 :=  nTotAfas  * nDiasIn                 // MONTO RECONOCIDO
   					Impr623(@nLin)
					nLin+= 30
					//Totalizadores que sao usados na ImpTrailer
   					nTrailAfa += nTotGan               // TOTAL GANADO
   					nTrailSub += nTotAfas              // TOTAL SUBSIDIO
   					nTrailRec += nTotRec               // TOTAL RECONOCIDO
		   		Next nAux
				nLin+= 10
				// Imprime legenda
		   		If nLin > 270 .and.nLin < 2220
					ImpTrailer(@nLin,@nColun)
				Endif
   				nTrailAfa := 0
   				nTrailSub := 0
   				nTrailRec := 0
			Else
				cSubTitle := UPPER(STR0005)				//"MATERNIDAD"
				nColun    := 1600
				nPerc	  := 80
				ImpDetal(@nLin,@nColun)
				nLin += 30
		   		// Imprime legenda
		   		If nLin > 270 .and.nLin < 2220
					ImpTrailer(@nLin,@nColun)
				Endif
			Endif


			// ACIDENTES DE TRABAJO
 			If lReg3 == .T.
 				nColun 	  := 1500
				cSubTitle := UPPER(STR0006)				//"ACIDENTES DE TRABAJO"
				nPerc	  := POSALIAS("SRV", aCodFol[752, 1], RCM->RCM_FILIAL, "RV_PERC")
			   	ImpDetal(@nLin,@nColun)
				For nAux = 1 to Len(aAcide)
				    cFil 	 := (aAcide[nAux][1])
					cMat 	 := (aAcide[nAux][2])
					cNome    := ltrim(aAcide[nAux][3])
					cPeriod	 := (aAcide[nAux][5])
					cConcepto:= (aAcide[nAux][6])      // VERBA
					nDiasIn	 := (aAcide[nAux][7])      // DIAS INCAPACIDAD
					dAdmissa := (aAcide[nAux][8])      // ADMISSAO
					nTotGan  := (aGanad[nAux][4])      // GANADO
					//Retorna os afastamentos para o relatorio
				   	fBuscaAutrz(cFil, cMat , cAnoMes, @nDiasRec, @cConcepto )
				   	nTotAfas :=  ((nTotGan/nDiasRec) * nPerc ) / 100 // SUBSIDIO %
					nTotRec	 :=  nTotAfas  * nDiasIn     			  // MONTO RECONOCIDO
					Impr623(@nLin)
					nLin+= 30
					//Totalizadores que sao usados na ImpTrailer
   					nTrailAfa += nTotGan               // TOTAL GANADO
   					nTrailSub += nTotAfas              // TOTAL SUBSIDIO
   					nTrailRec += nTotRec               // TOTAL RECONOCIDO
		   		Next nAux
				nLin+= 10
		   		// Imprime legenda
		   		If nLin > 270 .and.nLin < 2220
					ImpTrailer(@nLin,@nColun)
				Endif
   				nTrailAfa := 0
   				nTrailSub := 0
   				nTrailRec := 0
			Else
				cSubTitle := UPPER(STR0006)				//"ACIDENTES DE TRABAJO"
 				nColun 	  := 1500
				nPerc	  := 70
				ImpDetal(@nLin,@nColun)
				nLin += 30
		   		// Imprime legenda
		   		If nLin > 270 .and.nLin < 2220
					ImpTrailer(@nLin,@nColun)
				Endif
			Endif

			If nLin > 270 .and. nLin < 2200
				//imprime firma
				oPrint:say ( nLin+50, 1500, "__________________________________", oFont08)
				oPrint:say ( nLin+80, 1520, STR0036, oFont08) 								// FIRMA Y SELLO DEL RESPONSABLE
			Endif

	Endif

 	//Zera variaveis
	nTotGan  := nTotAfas := nDiasIn	 := nTrailAfa	:= nTrailSub	:= 0
	nEnferm  := nMatern  := nAciden	 := nDiasRec	:= nTrailRec	:= 0


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
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpTitle  ºAutor  ³A.Shibao            º Data ³  14/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do cabecalho.                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpTitle()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³SUBSIDIOS POR INCAPACIDAD TEMPORAL                                          |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:StartPage() 			//Inicia uma nova pagina

oPrint:say ( 0100, 0055, STR0007 , oFont10)                             //"CAJA DE SALUD DE LA BANCA PRIVADA"
oPrint:say ( 0100, 3030, STR0008 + cMes +"/"+ cAno, oFont10)   	    //"FECHA :"

oPrint:say ( 0130, 0055, STR0009  , oFont10)                          	//"SECCION DE COTIZACIONES"
oPrint:say ( 0130, 1250, STR0001  , oFont14n)	                      	//"SUBSIDIOS POR INCAPACIDAD TEMPORAL"


oPrint:say ( 0235, 0055, STR0010 + aInfo[3], oFont10)   			 	//"EMPRESA : "
oPrint:say ( 0235, 2900, STR0011  + aInfo[8], oFont10) 			 	//"No NIT"

oPrint:say ( 0270, 0055, STR0012+ aInfo[4], oFont10) 					//"DOMICILIO"

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpTitle  ºAutor  ³A.Shibao            º Data ³  14/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do Title    .                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpDetal(nLin,nColun)

nlin += 150

oPrint:say ( nLin, nColun, cSubTitle , oFont12n)
nLin += 30

oPrint:say ( nLin, 0055, STR0013 , oFont08) 			// "EL CALCULO SE EFECTUA SOBRE MES CALENDARIO Y NO COMERCIAL"
nLin += 40

oPrint:say ( nLin, 0055, Replicate("-", 150), oFont10)
nLin += 35

oPrint:say ( nLin, 2100, STR0014 , oFont09)	  			//"DIAS"
oPrint:say ( nLin, 3180, STR0015, oFont09)		    	//"MONTO"
nLin += 10

oPrint:say ( nLin, 0130, STR0016				 , oFont09)		//NOMBRE
//oPrint:say ( nLin, 0800, STR0017	   			 , oFont09)		//FECHA DE
oPrint:say ( nLin, 1260, STR0017       			 , oFont09)		//FECHA DE
oPrint:say ( nLin, 1700, STR0018				 , oFont09)	    //DIAS DE
oPrint:say ( nLin, 2450, STR0019		   	 	 , oFont09)	    //TOTAL
oPrint:say ( nLin, 2750, STR0020+ alltrim(str(nPerc)+"%"), oFont09)		//SUBSIDIO
nLin += 20

oPrint:say ( nLin, 2070, STR0021, oFont09)	            //RECONOCIDO
oPrint:say ( nLin, 3150, STR0021, oFont09)			    //RECONOCIDO
nLin += 10

//oPrint:say ( nLin, 0810, STR0022, oFont09)		   //"INGRESO"
oPrint:say ( nLin, 1280, STR0023, oFont09)			   //"BAJA"
oPrint:say ( nLin, 1660, STR0024, oFont09)	           //"INCAPACIDAD"
oPrint:say ( nLin, 2440, STR0025, oFont09)  		   //"GANADO"
oPrint:say ( nLin, 2710, STR0026, oFont09)            //"(Salário por dia)"
nLin += 20

oPrint:say ( nLin, 2060, STR0027, oFont09)            //"POR LA CAJA"
oPrint:say ( nLin, 3150, STR0028, oFont09)	   		   //"POR C.S.B.P"
nLin += 30

oPrint:say ( nLin, 0055, Replicate("-", 150), oFont10)
nLin += 30

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Impr623   ºAutor  ³A.Shibao	         º Data ³  14/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime funcionarios com afastamentos  		              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpR623(nLin)

oPrint:say ( nLin, 0055, substr(cNome,1,60)    , oFont08)

oPrint:say ( nLin, 1040, STR0029 , oFont08)  							       // DEL

oPrint:say ( nLin, 1160, DtoC(dSr8Ini) + STR0030 + dToc(dSr8Fim) , oFont08)  // AL


oPrint:say ( nLin, 1680, Transform(nDiasIn,"99999")			 	, oFont09)    //DIAS DE INCAPACIDAD
oPrint:say ( nLin, 2110, Transform(nDiasIn,"9999")        	 	, oFont09)    //DIAS RECONOCIDOS
oPrint:say ( nLin, 2350, Transform(nTotGan,"999,999,999.99") 	, oFont09)    //TOTAL GANADO
oPrint:say ( nLin, 2720, Transform(nTotAfas,"999,999,999.99")	, oFont09)    //SUBSIDIO %
oPrint:say ( nLin, 3100, Transform(nTotRec,"999,999,999.99") 	, oFont09)    //MONTO RECONOCIDO


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpTrailerºAutor  ³A.Shibao	         º Data ³  14/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime TOTAL legenda e firma 		 		              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpTrailer(nLin,nColun)

oPrint:say ( nLin, 0200, STR0037 , oFont09)									// TOTAL
oPrint:say ( nLin, 2350, Transform((nTrailAfa),"999,999,999.99"), oFont09) // TOTALIZADOR DO TOTAL GANADO
oPrint:say ( nLin, 2720, Transform((nTrailSub),"999,999,999.99"), oFont09) // TOTALIZADOR DO SUBSIDIO
oPrint:say ( nLin, 3100, Transform((nTrailRec),"999,999,999.99"), oFont09) // TOTALIZADOR DO MONTO RECONOCIDO
nLin+=50
oPrint:say ( nLin, 0055, STR0031, oFont06) 									//"1 - Certificado de Incapacidade Temporal"
nLin+=30
oPrint:say ( nLin, 0055, STR0032, oFont06) 									//"2 - Articulo da D.L. 13214"
nLin+=30
oPrint:say ( nLin, 0055, STR0033, oFont06) 									//"3 - Ingreso Total Funcionaria"
nLin+=30
oPrint:say ( nLin, 0055, STR0034 + alltrim(str(nPerc)+"%"), oFont06)		//"4 - Total Ganado / Dias del Mes (calendario) x "X" %"
nLin+=30
oPrint:say ( nLin, 0055, STR0035, oFont06) 									//"5 - Inciso 2 x Inciso 4"

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ConvQry   ºAutor  ³Microsiga           º Data ³  27/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³Convertir a expreción sql un campo informado con un listbox ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³   ConvQry(cExp,cExp1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³    cExp: Cadena de caracteres que retorna el litbox        ³±±
±±³          ³    cExp1: Campo del diccionario de datos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPEM005COS                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvQry(cLista,cCampo)
Local cTxt:=''
Local nTamReg := TamSX3(cCampo)[1]
Local nCont:=0
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Genera texto para usar  para usar despues en Query             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
cLista:=alltrim(cLista)


For nCont := 1 To Len( cLista ) Step nTamReg
    cTxt+="'"+SubStr( cLista , nCont , nTamReg )+"',"
NEXT
cTxt:=substr(cTxt,1,len(cTxt)-1)
Return ( cTxt )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fBuscaAutrz³ Autor ³ A.Shibao      		³ Data ³ 17.09.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os afastamentos de acordo com a data de autorizacao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                    					 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fBuscaAutrz												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Gen‚rico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fBuscaAutrz(cFil, cMat , cAnoMes, nDiasRec, cConcepto )

Local cAliasAnt  := Alias()
Local cQuery8	 := ""
Local cAliasSr8	 := "SR8"

Local dDtaIni	 := Max( dAdmissa, cTod( "01/"+Substr(cAnoMes,5,2) + '/' + Substr(cAnoMes,1,4) ))
Local dDtaFim	 := cTod(str(f_UltDia(dDtaIni)) + '/' +Substr(cAnoMes,5,2) + '/' + Substr(cAnoMes,1,4))

Private nDiasRec := f_UltDia(dDtaIni)

Static cFilSrm

DEFAULT cFilSrm	 := FwxFilial("RCM")

	cAliasSr8 	:= "QrySR8"
	cQuery8 	:= "SELECT * "
	cQuery8 	+= "FROM "+RetSqlName("SR8")+" SR8 "
	cQuery8 	+= "WHERE SR8.R8_FILIAL='"+ cFil +"' AND "
	cQuery8 	+= "SR8.R8_MAT='"+ cMat +"' AND "
//	cQuery8 	+= "SR8.R8_DTBLEG BETWEEN '" + cDtaIni + "' AND '" + cDtaFim + "'"
	cQuery8 	+= " SR8.D_E_L_E_T_ = ' ' "
	cQuery8 	+= "ORDER BY "+SqlOrder(SR8->(IndexKey()))

	If Select(cAliasSr8) > 0
		(cAliasSr8)->( dbCloseArea() )
	Endif

	cQuery8 		:= ChangeQuery(cQuery8)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery8),cAliasSr8)


	dbSelectArea(cAliasSr8)
	(cAliasSr8)->(dbgotop())

	dbSelectArea( "SR8" )
	dbSeek( cFil + cMat)


	While !Eof() .And. (cAliasSr8)->( R8_FILIAL + R8_MAT ) = cFil + cMat

        DbSelectArea( "RCM" )
        DbSetOrder( RetOrder( "RCM", "RCM_FILIAL+RCM_TIPO" ) )
        DbSeek( cFilSrm + (cAliasSr8)->R8_TIPOAFA, .F. )

        // Condicao para trazer os dados das ausencias no relatorio
   		If ((cAliasSr8)->R8_DATAFIM >= Dtos(dDtaini) .or. empty((cAliasSr8)->R8_DATAFIM)) .And. (cAliasSr8)->R8_DATAINI <= Dtos(dDtaFim)


         	If RCM->RCM_TPIMSS $ "C/A/P/M" .and. cConcepto == (cAliasSr8)->R8_PD
		           	 If (cAliasSr8)->R8_DATAINI <= DtoS(dDtaini)
		           	   	 dSr8Ini		:= dDtaIni
	 		 		 Else
		 		 		 dSr8Ini		:= sTod((cAliasSr8)->R8_DATAINI)
		 		 	 Endif

		           	 If (cAliasSr8)->R8_DATAFIM >= DtoS(dDtaFim) .or. Empty((cAliasSr8)->R8_DATAFIM)
		           	   	 dSr8Fim		:= dDtaFim
	 		 		 Else
		 		 		 dSr8Fim		:= sTod((cAliasSr8)->R8_DATAFIM)
		 		 	 Endif


		    Endif

         Endif
	dbSelectArea(cAliasSr8)
	dbSkip()

	Enddo

	If Select(cAliasSr8) > 0
	 	(cAliasSr8)->( dbCloseArea() )
	Endif


	If !EMPTY(cAliasAnt)
		dbSelectArea(cAliasAnt)
	EndIf

	Return()
