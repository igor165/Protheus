#Include "PROTHEUS.CH"
#INCLUDE "GPERSUB.CH"
#DEFINE   nColMax	3200
#DEFINE   nLinMax  2400
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPERSUB    ³ Autor ³ Erika Kanamori          ³ Data ³ 08.02.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Geracao do relatorio de Lactancia/Prenatal.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPERSUB()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³     BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Leandro Dr. |30/10/08|    004841|Ajuste no carregamento das filiais.       |±±
±±|Claudinei S.|23/04/12|    TEWPXP|ImpInfFunc - impressao correta da parcela.|±±
±±|            |        |          |Implac - impressao dos outros meses da RG1|±±
±±|            |        |          |ImpCabec- ajuste titulo invertido.        |±±
±±|Claudinei S.|16/08/12|    TFPDGA|AjustaSX1T-inclusao de Sepelio e Natalidad|±±
±±|            |        |          |nas opcoes das perguntas do relatorio.    |±±
±±|M. Silveira |22/02/13|    TGMABG|Ajustes realizados para adequacao ao novo |±±
±±|            |        |          |formato conforme determinacao legal.      |±±
±±|M. Silveira |28/03/13|    TGXIKL|Corrigido parametros ao chamar a ImpRodape|±±
±±|M. Silveira |26/06/13|    THMAZ7|Incluido totalizador para Montante Base.  |±±
±±|Claudinei S.|07/11/13|    THYUYN|Ajustada a quebra da pagina para a correta|±±
±±|            |        |          |impressao do totalizador.                 |±±
±±|            |        |          |                                          |±±
±±³Jonathan Glz³07/05/15³PCREQ-4256³Se elimina funcion AjustaSX1T que realiza ³±±
±±³            ³        ³          ³modificacion al diccionario de datos(SX1) ³±±
±±³            ³        ³          ³por motivo de ajuste nueva estructura de  ³±±
±±³            ³        ³          ³SXs para V12                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function GPERSUB()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Locais (Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cDesc1 		:= STR0001		//"Planilla de Subsidio Prenatales/Lactancia/Sepelio/Natalidad"
Local cDesc2 		:= STR0002		//"Se imprimira de acuerdo con los parametros solicitados por el usuario."
Local cDesc3 		:= STR0003		//""Obs.: Debe imprimirse un Formulario Mensual para cada Filial.""
Local cString		:= "RG1"        // alias do arquivo principal (Base)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Private(Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private nomeprog	:= "GPERSUB"
Private aReturn 	:= { , 1,, 2, 2, 1,"",1 }
Private nLastKey 	:= 0
Private cPerg   	:= "GPRSUB"

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis Utilizadas na funcao de Impressao                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private Titulo	:= STR0001		//"Planilla de Subsidio Prenatales/Lactancia/Sepelio/Natalidad" - titulo da janela de pergunte
Private nTamanho:= "M"
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
Private cNota		:= ""
Private cPdCodFol   := ""
Private cElaborador	:= ""
Private nEmpresa	:= 0
Private nMunicipio	:= 0
Private nTotCOL1 	:= 0
Private nTotCOL2 	:= 0
Private nTotMtBs 	:= 0
Private lPreLact
Private lEnd
Private oPrint

pergunte("GPRSUB",.F.)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Envia controle para a funcao SETPRINT                        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
wnrel:="GPERSUB"            //Nome Default do relatorio em Disco
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
³ mv_par01        //  Tipo do relatorio(Lactancia | Prenatales)|
³ mv_par02        //  Filial De						           ³
³ mv_par03        //  Filial Ate					           ³
³ mv_par04        //  Mes/Ano?     				               |
³ mv_par05        //  Matricula De                             ³
³ mv_par06        //  Matricula Ate                            ³
³ mv_par07        //  Centro de Custo De                       ³
³ mv_par08        //  Centro de Custo Ate                      ³
³ mv_par09        //  Nota                                     ³
³ mv_par10        //  Empresa                                  ³
³ mv_par11        //  Municipio                                ³
³ mv_par12        //  Elaborado por                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nOrdem   := aReturn[8]

nTipo		:= mv_par01
cFilialDe 	:= mv_par02
cFilialAte  := mv_par03
cMes 		:= substr( mv_par04, 1, 2 )
cAno 		:= substr( mv_par04, 3, 4 )
cMatDe		:= mv_par05
cMatAte     := mv_par06
cCustoDe    := mv_par07
cCustoAte   := mv_par08
cNota		:= mv_par09
nEmpresa	:= mv_par10
nMunicipio	:= mv_par11
cElaborador	:= mv_par12

dDataRef := ctod("01/"+cMes+ "/"+cAno)

//-- Objeto para impressao grafica
oPrint     := TMSPrinter():New( Titulo )
oPrint:SetLandscape()	//Imprimir Somente Paisagem


RptStatus({|lEnd| IMPLAC(@lEnd,wnRel,cString,.F. )},Capital(Titulo))

oPrint:Preview()  							// Visualiza impressao grafica antes de imprimir

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPLAC    ºAutor  ³Erika Kanamori      º Data ³  02/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IMPLAC()

Local aCodFol
Local cFilAnt 		:= ""
Local nLinha		:= 809
Local nBsTotal		:= 0
Local nCOL1 		:= 0
Local nCOL2 		:= 0
Local lAux			:= .F.
Local lPasPri      	:= .F.
Local cAcessaRG1	:= &( " { || " + ChkRH( "GPERSUB" , "RG1" , "2" ) + " } " )
Local nSavRec
Local nSavOrdem
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis para controle em ambientes TOP.                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cAlias   := ""
Local cQuery
Local aStruct  := {}
Local lQuery  := .F.
Local nAux
Private cQryRG1 := "RG1"


Private aInfo:= {}
Private cCidade := ""
Private oFont08, oFont09, oFont10, oFont11n, oFont14n

	oFont08	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
	oFont09	:= TFont():New("Courier New",09,09,,.F.,,,,.T.,.F.)
	oFont10 := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
	oFont11n:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)
	oFont14n:= TFont():New("Courier New",14,14,,.T.,,,,.T.,.F.)     //Negrito//

nEpoca:= SET(5,1910)
//-- MUDAR ANO PARA 4 DIGITOS
SET CENTURY ON

#IFDEF TOP
	lQuery := .T.
#ELSE
    cQryRG1:= "RG1"
    dbSelectArea("RG1")
	nSavRec   := RecNo()
	nSavOrdem := IndexOrd()
	dbSetOrder(2)
	RG1->(dbSeek( cFilialDe + cMatDe, .T.) )
#ENDIF

If lQuery
	//Filtra do RG1: filial, matricula de/ate, centro de custo de/ate
	cAlias := "RG1"
	cQryRG1 := "QRG1"

	//montagem da query
	cQuery := "SELECT "
 	cQuery += " RG1_FILIAL, RG1_MAT, RG1_PD, RG1_CC, RG1_VALOR, RG1_DINIPG, RG1_DFIMPG, RG1_REFER, RG1_TPCALC"
	cQuery += " FROM " + RetSqlName(cAlias)
	cQuery += " WHERE "
	cQuery += " RG1_FILIAL BETWEEN '" + cFilialDe + "' AND '" + cFilialAte + "'"
	cQuery += "  AND "
	cQuery += " RG1_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "'"
	cQuery += "  AND "
	cQuery += " RG1_CC BETWEEN '" + cCustoDe + "' AND '" + cCustoAte + "'"
	cQuery += " AND "
	cQuery += " D_E_L_E_T_ <> '*'
	cQuery += " ORDER BY RG1_FILIAL, RG1_MAT, RG1_PD"

	cQuery := ChangeQuery(cQuery)
	aStruct := (cAlias)->(dbStruct())

	If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQryRG1,.T.,.T.)
		For nAux := 1 To Len(aStruct)
			If ( aStruct[nAux][2] <> "C" )
				TcSetField(cQryRG1,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
			EndIf
		Next nAux
	Endif

	dbSelectArea(cQryRG1)
	(cQryRG1)->(dbGoTop())
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Regua de Processamento                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	(cQryRG1)->( SetRegua(RecCount()) )
	SetPrc(0,0)

If !(fInfo(@aInfo,(cQryRG1)->RG1_FILIAL))			// carrega dados da filial
	Return
EndIf

cCidade := aInfo[5]


While (cQryRG1)->(!Eof() .And. (RG1_FILIAL+RG1_MAT) <= cFilialAte + cMatAte )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Movimenta Regua de Processamento                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IncRegua()

	If lEnd
		@Prow()+1,0 PSAY cCancel
		Exit
	Endif

	nCOL1 := 0
	nCOL2 := 0

	If cFilAnt <> (cQryRG1)->RG1_FILIAL//se a filial eh diferente da q acabou de imprimir, imprime rodape e
		If nLinha <> 809             // seta nLinha para imprimir as informacoes em uma nova folha
			ImpRodape(nLinha,nBsTotal,nTotCOL1,nTotCOL2,nTotMtBs)
			nBsTotal := 0
			nTotCOL1 := 0
			nTotCOL2 := 0
			nTotMtBs := 0
		Endif

		fInfo(@aInfo,(cQryRG1)->RG1_FILIAL)			// carrega dados da filial
		nLinha:= 0810
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Carrega Variaveis Codigos Da Folha                           ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If !fP_CodFol(@aCodFol,(cQryRG1)->RG1_FILIAL)
			Return
		Endif

		If nTipo < 2
			cPdCodFol := aCodFol[740,1] + "|" + aCodFol[738,1]  //Lactancia ou Prenatales
			lPreLact  := .T.
		Else
			cPdCodFol := aCodFol[741,1]	+ "|" + aCodFol[739,1]	//Sepelio ou Natalidad
			lPreLact  := .F.
		Endif

		cFilAnt := (cQryRG1)->RG1_FILIAL

	Endif



	If !lQuery
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste Parametrizacao do Intervalo de Impressao            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  (RG1->RG1_MAT < cMatDe)   .Or. (RG1->RG1_MAT > cMatAte)    .Or. ;
			(RG1->RG1_CC  < cCustoDe) .Or. (RG1->RG1_CC  > cCustoAte)
				RG1->(dbSkip(1))
				Loop
		EndIf
	Endif

	//Consiste se o registro eh do mes selecionado
	If  MESANO((cQryRG1)->RG1_DINIPG) > (cAno+cMes) .OR. If( !Empty((cQryRG1)->RG1_DFIMPG), MESANO((cQryRG1)->RG1_DFIMPG) < (cAno+cMes), .F. )
		(cQryRG1)->(dbSkip())
		Loop
	Endif

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Consiste Filiais e Acessos                                             ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF RG1->( !( RG1_FILIAL $ fValidFil() ) .or. !Eval( cAcessaRG1 ) )
 		dbSelectArea("RG1")
 		RG1->( dbSkip() )
   		Loop
	Endif


	If (cQryRG1)->RG1_PD $ cPdCodFol     //Se houver registros de lactancia, prenatales, sepelio ou natalidad
		dbSelectArea("SRA")               //procura no SRA o funcionário e deixa .T. pra impressão
		dbSetOrder(1)
		dbSeek((cQryRG1)->(RG1_FILIAL+RG1_MAT))
		lAux:= .T.

		If (cQryRG1)->RG1_PD $ ( aCodFol[738,1] + "|" + aCodFol[739,1] )
			nCOL1 := 1 //A Coluna 1 - Preenchida com Pre-Natal ou Natalidade
		Else
			nCOL2 := 1 //A Coluna 2 - Preenchida com Lactancia ou Sepelio
		EndIf
	Endif

 	If lAux
		If nLinha == 810
			ImpCabec()
		Endif

		ImpInfFunc(nLinha, @nBsTotal, nCOL1, nCOL2)
		nLinha+= 100
		lAux:= .F.

		If nLinha > 2150
		    lPasPri := .T.
			oPrint:Endpage()
			nLinha := 810
		Endif
	Endif

	(cQryRG1)->(dbSkip())

End

If nLinha <> 810 .OR. lPasPri
	ImpCabec()
	ImpRodape(nLinha,nBsTotal,nTotCOL1,nTotCOL2,nTotMtBs)
	lPasPri := .F.
Endif

If !lQuery
	dbSelectArea("RG1")
	dbSetOrder(nSavOrdem)
	dbGoTo(nSavRec)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna o alias padrao                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuery
	If Select(cQryRG1) > 0
	 (cQryRG1)->(dbCloseArea())
	Endif
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpCabec  ºAutor  ³Erika Kanamori      º Data ³  02/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ImpCabec()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³PLANILLA DE SUBSIDIO DE LACTANCIA/PRENATALES                                |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cTpEmp   := ""
Local cMunic   := ""
Local cDescMes := ""
Local cSubsid  := ""
Local cColuna1 := ""
Local cColuna2 := ""

oPrint:StartPage() 			//Inicia uma nova pagina


cTpEmp   := If( nEmpresa == 1, 	"PUBLICA(   )      PRIVADA( X )", "PUBLICA( X )      PRIVADA(   )" )
cMunic   := If( nMunicipio == 1, "URBANO( X )      RURAL(   )", "URBANO(   )      RURAL( X )" )
cDescMes := UPPER( MesExtenso(cMes)+" "+cAno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
                                   D O C U M E N T A C A O
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
O relatorio imprime 4 tipos Tipos de subsidios: PreNatal, Lactancia, Natalidad e Sepelio.
No layout padrao a impressao deve ser feita utilizando 2 grupos de subsidios:
* PreNatal e Lactancia (Coluna 1 e 2 respectivamente)
* Natalidad e Sepelio  (Coluna 1 e 2 respectivamente)
As colunas 1 e 2 tratam esta configuracao de acordo com o tipo de relatorio que esta sendo
impresso. A descricao dos campos e dados sao definidos conforme a variavel LPRELACT.
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
If lPreLact
	cColuna1 := "PRENATAL" //STR0033 "PRE NATAL"
	cColuna2 := STR0034 //"LACTANCIA"
	cSubsid  := "SUBSIDIO EN ESPECIE"	//STR0030 "SUBSIDIO EN ESPECIE"
Else
	cColuna1 := "NATALIDAD"				//STR0036 NATALIDAD
	cColuna2 := "SEPELIO"				//STR0037 SEPELIO
	cSubsid  := "SUBSIDIO EN DINERO"	//STR0031 "SUBSIDIO EN DINERO"
EndIf

oPrint:say ( 0080, 1200, "MINISTERIO DA SALUD Y DEPORTES", oFont14n )
oPrint:say ( 0150, 1100, "INSTITUTO NACIONAL DE SEGUROS DE SALUD", oFont14n )

oPrint:box ( 0300, 0030, 0660, 3160)   							//BOX com os dados da empresa

oPrint:say ( 0310, 0050, STR0024, oFont10) 						//Razao social do empregador
oPrint:line( 0300, 2180, 0660, 2180) 							//Linha Vertical
oPrint:line( 0350, 0030, 0350, 2180) 							//Linha horizontal
oPrint:line( 0350, 2780, 0350, 3160) 							//Linha horizontal

oPrint:say ( 0310, 2200, "SUBSIDIO CORRESPONDIENTE", oFont10)  //Subsidio Correpondente
oPrint:line( 0300, 2780, 0660, 2780) 							//Linha Vertical

oPrint:say ( 0310, 2800, STR0039, 		oFont10)				//Elaborado por
oPrint:say ( 0370, 2800, cElaborador, 	oFont10)				//Elaborado por

oPrint:say ( 0360, 2400, "AL MES", 		oFont10)
oPrint:say ( 0370, 0050, aInfo[2], 		oFont10)				//Nome da empresa
oPrint:line( 0420, 0030, 0420, 2780) 							//Linha horizontal
oPrint:say ( 0490, 2200, cDescMes, 		oFont10)				//Mes por extenso do subsidio

oPrint:say ( 0430, 0050, "NIT:", 		oFont10) 				//"NIT"
oPrint:say ( 0430, 0180, aInfo[8], 		oFont10)				//"NIT"
oPrint:line( 0480, 0030, 0480, 2180) 							//Linha horizontal
oPrint:line( 0480, 2780, 0480, 3160) 							//Linha horizontal

oPrint:say ( 0490, 0050, STR0025, 		oFont10) 				//"EMPRESA:"
oPrint:say ( 0490, 0600, cTpEmp, 		oFont10) 				//"EMPRESA:"
oPrint:say ( 0490, 1300, STR0026, 		oFont10)				//"DEPARTAMENTO:"
oPrint:say ( 0490, 1600, aInfo[5], 		oFont10)				//"DEPARTAMENTO"
oPrint:line( 0540, 0030, 0540, 2180) 							//Linha horizontal

oPrint:say ( 0550, 0050, STR0040, 		oFont10) 	   		   	//"MUNICIPIO:"
oPrint:say ( 0550, 1000, cMunic, 		oFont10)   		   		//"MUNICIPIO:"
oPrint:line( 0600, 0030, 0600, 2180) 							//Linha horizontal
oPrint:line( 0600, 2780, 0600, 3160) 			   				//Linha horizontal

oPrint:say ( 0610, 0050, STR0027, 		oFont10) 	   			//"ENDERECO"
oPrint:say ( 0610, 0300, aInfo[4], 		oFont10)				//"ENDERECO"
oPrint:say ( 0610, 1400, STR0028,		oFont10) 				//"TELEFONO/FAX:"
oPrint:say ( 0610, 1700, aInfo[10], 	oFont10)				//"TELEFONO/FAX:"
oPrint:say ( 0610, 2910, STR0029, 		oFont10) 				//"FIRMA"

oPrint:say ( 0700, 1350, cSubsid, 		oFont11n)   			//"SUBSIDIO"


//DADOS DOS FUNCIONARIOS
oPrint:box ( 0760, 0030, 0810, 3160)

oPrint:say ( 0770, 0050, STR0011, oFont10) 		  		//"NOMBRE DEL TRABAJADOR"
oPrint:line( 0760, 0650, 0810, 0650)

oPrint:say ( 0770, 0660, STR0012, oFont10) 		  		//"BENEFICIARIO"
oPrint:line( 0760, 1260, 0810, 1260)

oPrint:say ( 0770, 1270, STR0032, oFont10) 		   		//"FECHA"
oPrint:line( 0760, 1470, 0810, 1470)

oPrint:say ( 0770, 1480, cColuna1, oFont10) 			//"PRE NATAL ou NATALIDADE"
oPrint:line( 0760, 1780, 0810, 1780)

oPrint:say ( 0770, 1790, cColuna2, oFont10) 			//"LACTANCIA ou SEPELIO"
oPrint:line( 0760, 2080, 0810, 2080)

If lPreLact
	//IMPRESSAO DO SUBSIDIO PRE NATAL OU LACTANCIA
	oPrint:say ( 0770, 2090, "No. DE SUBS", oFont10)	//"No. DE SUBS"
	oPrint:line( 0760, 2390, 0810, 2390)
	oPrint:say ( 0770, 2400, "MONTO BASE", oFont10) 	//"MONTO BASE"
	oPrint:line( 0760, 2780, 0810, 2780)
	oPrint:say ( 0770, 2910, STR0016, oFont10) 			//"FIRMAS"

Else
	//IMPRESSAO DO SUBSIDIO NATALIDAD OU SEPELIO
	oPrint:say ( 0770, 2350, "MONTO BASE", oFont10) 	//"MONTO BASE"
	oPrint:line( 0760, 2780, 0810, 2780)
	oPrint:say ( 0770, 2910, STR0016, oFont10) 			//"FIRMAS"
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpInfFuncºAutor  ³Erika Kanamori      º Data ³  02/11/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function ImpInfFunc(nLinha, nBsTotal, nCOL1, nCOL2)

Local nValor := 0

If ( (cQryRG1)->RG1_TPCALC == "1" )
	NVALOR := (cQryRG1)->RG1_VALOR
ElseIf ( (cQryRG1)->RG1_TPCALC == "7" )
	VAL_SALMIN := FTABELA("S005",1,4)
	NVALOR := (cQryRG1)->RG1_REFER * VAL_SALMIN / 100
Else
	NVALOR := 0
EndIf

//IMPRESSAO DO SUBSIDIO LACTANCIA OU PRE NATAL
oPrint:box ( nLinha, 0030, (nLinha+100), 3160)   			//BOX

oPrint:say ( (nLinha+60), 0050, SRA->RA_NOME, oFont08) 	//"NOME"
oPrint:line( nLinha, 0650, (nLinha+100), 0650)				//Linha Vertical

oPrint:say ( (nLinha+60), 0660, SRA->RA_NOME, oFont08) 	//"BENEFICIARIO"
oPrint:line( nLinha, 1260, (nLinha+100), 1260)				//Linha Vertical

oPrint:say ( (nLinha+60), 1270, DtoC(dDataRef), oFont08)	//DATA
oPrint:line( nLinha, 1470, (nLinha+100), 1470) 			//Linha Vertical

oPrint:say( (nLinha+60), 1480, cValToChar(nCOL1), oFont08) //PRE NATAL ou NATALIDAD
oPrint:line( nLinha, 1780, (nLinha+100), 1780)				//Linha Vertical

oPrint:say( (nLinha+60), 1790, cValToChar(nCOL2), oFont08) //LACTANCIA ou SEPELIO
oPrint:line( nLinha, 2080, (nLinha+100), 2080)				//Linha Vertical

If lPreLact
	oPrint:say ( (nLinha+60), 2090,Transform(DateDiffMonth(dDataRef,(cQryRG1)->RG1_DINIPG)+1,"99"),oFont08) //"NUM. SUBSIDIOS"
	oPrint:line( nLinha, 2390, (nLinha+100), 2390)
	oPrint:say ( (nLinha+60), 2400, Transform(NVALOR, "99,999,999.99"), oFont08) //"MONTO BASE"
	oPrint:line( nLinha, 2780, (nLinha+100), 2780)
Else
	oPrint:say ( (nLinha+60), 2300, Transform(NVALOR, "99,999,999.99"), oFont08) //"MONTO BASE"
	oPrint:line( nLinha, 2780, (nLinha+100), 2780)
EndIf

nBsTotal += NVALOR
nTotMtBs += NVALOR
nTotCOL1 += nCOL1
nTotCOL2 += nCOL2

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpRodape ºAutor  ³Erika Kanamori      º Data ³  02/11/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpRodape(nLinha,nBsTotal, nTotCOL1, nTotCOL2, nTotMtBs)

oPrint:box ( nLinha, 1470, (nLinha+100), 2080) 				//Box do Rodape - Numero de Casos

oPrint:say ( nLinha+30, 1100, STR0038, oFont10)					//"NUMERO DE CASOS"

oPrint:say ( nLinha+30, 1480, cValToChar(nTotCOL1), oFont10)	//"TOTAL COLUNA1
oPrint:say ( nLinha+30, 1790, cValToChar(nTotCOL2), oFont10)	//"TOTAL COLUNA1
oPrint:line( nLinha, 1780, nLinha+100, 1780)					//Linha Vertical

If lPreLact
	oPrint:box ( nLinha, 2390, (nLinha+100), 2780) 				//Box do Rodape - Pre-Natal/Lactancia
	oPrint:say ( nLinha+30, 2400, Transform(nTotMtBs, "99,999,999.99"), oFont10) //"TOTAL MONTO BASE"
Else
	oPrint:box ( nLinha, 2080, (nLinha+100), 2780) 				//Box do Rodape - Natalidade/Sepelio
	oPrint:say ( nLinha+30, 2300, Transform(nTotMtBs, "99,999,999.99"), oFont10)	//"TOTAL MONTO BASE
EndIf

oPrint:EndPage()

Return
