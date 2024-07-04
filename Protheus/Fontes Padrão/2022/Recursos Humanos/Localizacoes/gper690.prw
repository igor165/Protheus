#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER690.CH"
#DEFINE   nColMax	2350
#DEFINE   nLinMax  2900
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER690   ºAutor  ³Erika Kanamori         º Data ³  01/31/08          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Geracao do Formulario Trimestral de Planillas de Sueldos y            º±±
±±º          ³Salarios y Accidentes de Trabajo.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                                   º±±
±±ÇÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶±±
±±º         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                       º±±
±±ÇÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶±±
±±ºProgramador ³ Data   ³ BOPS ³  Motivo da Alteracao                               º±±
±±ÇÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶±±
±±º            ajuste para versao 10                                                º±±
±±ÇÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶±±
±±ºClaudinei S.³16/02/12³00000002663/2012³Ajuste na IMPBOL para que os Eventuales e º±±
±±º      	   ³        ³          TELMJY³Permanentes sejam definidos no RA_TPCONTR.º±±
±±ºR.Berti     ³07/03/12³TEPKFE          ³Nao emite caso nao hajam periodos ab/fech.º±±
±±º      	   ³        ³                ³Ajuste no acesso RCH em amb.c/Gestao Corp.º±±
±±ºR.Berti     ³11/05/12³TEYYPN          ³Logos Minist.Trabalho e incluido campo RUCº±±
±±ºLeandro Dr. ³05/06/12³TFDEFJ          ³Ajuste para totalizar por empresa.        º±±
±±ºLeandro Dr. ³06/06/12³TFDMJ4          ³Ajuste na totalizacao de funcionarios.    º±±
±±ºM. Silveira ³20/08/12³TFMBKS          ³Ajuste p/ imprimir no box3 somente valoresº±±
±±º      	   ³        ³                ³do ultimo mes do trimestre.               º±±
±±ºM. Silveira ³06/05/12³TFQHN5          ³Ajuste p/demonstrar separados os descontosº±±
±±º      	   ³        ³                ³I, J e K.                                 º±±
±±ºClaudinei S.³13/11/12³00000026290/2012³Inclusao de help quando a S007 nao estiverº±±
±±º      	   ³        ³TFXBHE          ³preenchida.                               º±±
±±ºM. Silveira ³07/01/14³TIEBXB          ³Diversos ajustes realizados:              º±±
±±º      	   ³        ³                ³-Dados de Ausencias conforme a SR8 e RCM  º±±
±±º      	   ³        ³                ³-Retirada linha Fundo Solidario do item 3 º±±
±±º      	   ³        ³                ³-Corrigida a verificacao da tabela S006.  º±±
±±º      	   ³        ³                ³-Uso da Tab.S007 p/ definir o responsavel.º±±
±±º      	   ³        ³                ³-Checa atualizacoes obrigatorias.         º±±
±±ºR.Berti     ³28/07/12³TILTNZ          ³Ajustes e continuacao da MIT de TIEBXB:   º±±
±±º      	   ³        ³                ³-Inclusao perguntas: Processos e Roteiros,º±±
±±º      	   ³        ³                ³-Ajustes:RCM,SR8 e nova cons.padrao S06BOLº±±
±±³            ³        ³                ³                                          ³±±
±±³Jonathan Glz³06/05/15³      PCREQ-4256³Se elimina la funcion AjustaHlp, la cual  ³±±
±±³            ³        ³                ³realiza la modificacion aldiccionario de  ³±±
±±³            ³        ³                ³datos(SX1) por motivo de adecuacion  nueva³±±
±±³            ³        ³                ³estructura de SXs para version 12         ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER690()
Local cMes
Local cAno
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Locais (Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cDesc1 		:= STR0001		//"Formulario Trimestral de Planillas de Sueldos y Salarios y Accidentes de Trabajo"
Local cDesc2 		:= STR0002		//"Se imprimira de acuerdo con los parametros solicitados por el usuario."
Local cDesc3 		:= STR0003		//"Obs.: Debe imprimirse un Formulario Trimestral para cada Filial."
Local cString		:= "SRA"        // alias do arquivo principal (Base)
Local cMsgDic		:= ""			//Mensagem para validacao de dicionario de dados

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Private(Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private nomeprog	:= "GPER690"
Private aReturn 	:={ , 1,, 2, 2, 1,"",1 }
Private nLastKey 	:= 0
Private cPerg   	:= "GPR690"

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis Utilizadas na funcao IMPR                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private Titulo	    := STR0004		//Formulário Trimestral de Planillas de Sueldos y Salarios y Accidentes de Trabajo - Declaración Jurada
Private nTamanho    := "M"
Private cFilialDe   := ""
Private cFilialAte  := ""
Private cMatDe      := ""
Private cMatAte     := ""
Private cCustoDe    := ""
Private cCustoAte   := ""
Private cNomeDe     := ""
Private cNomeAte    := ""
Private cSit        := ""
Private cCat        := ""
Private cProcessos  := ""
Private cProcedi	:= ""
Private cEmpregNome := ""
Private cEmpregCIC  := ""
Private cFilTot		:= ""
Private lTotFil		:= .T.
Private dDataRef
Private oPrint

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao checa alguma atualizacao obrigatoria que impede a   ³
//³geracao do relatorio Trimestral.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
fChkUpd( @cMsgDic )
If !Empty(cMsgDic)
	MsgAlert( cMsgDic )
	Return()
EndIf

pergunte("GPR690",.F.)
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Envia controle para a funcao SETPRINT                        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
wnrel:="GPER690"            //Nome Default do relatorio em Disco
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
³ mv_par03        //  Mes/Ano Competencia Inicial?             |
³ mv_par04        //  Matricula De                             ³
³ mv_par05        //  Matricula Ate                            ³
³ mv_par06        //  Centro de Custo De                       ³
³ mv_par07        //  Centro de Custo Ate                      ³
³ mv_par08        //  Nome De                                  ³
³ mv_par09        //  Nome Ate                                 ³
³ mv_par10        //  Situacoes a Imp?                         ³
³ mv_par11        //  Categorias a Imp?                        ³
³ mv_par12        //  Impressao por filial ou empresa          ³
³ mv_par13        //  Matriz. Usada na impressao por empresa   ³
³ mv_par14        //  Processos ?              				   ³
³ mv_par15        //  Roteiro ?                          	   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nOrdem   := aReturn[8]

cFilialDe 	:= mv_par01
cFilialAte  := mv_par02
cMes 		:= Left(mv_par03,02)
cAno 		:= Right(mv_par03,04)
cMatDe		:= mv_par04
cMatAte     := mv_par05
cCustoDe    := mv_par06
cCustoAte   := mv_par07
cNomeDe     := mv_par08
cNomeAte    := mv_par09
cSit        := mv_par10
cCat        := mv_par11
lTotFil		:= mv_par12 == 1
cFilTot		:= mv_par13
cProcessos	:= If( Empty(mv_par14),"", ConvQry(alltrim(mv_par14),"RA_PROCES"))
cProcedi	:= If( Empty(mv_par15),"'FOL'", ConvQry(AllTrim(mv_par15),"RD_ROTEIR"))
dDataRef 	:= cToD( "01/" + cMes + "/" + cAno)


cEmpregNome	:= fTabela("S007",1,10 )
cEmpregCIC	:= fTabela("S007",1,11 )

	//-- Objeto para impressao grafica
	oPrint 	:= TMSPrinter():New( STR0004 ) //"Formulário Único de Prestación Trimestral de Planillas de Sueldos y
											//Salarios y Accidentes de Trabajo - Declaración Jurada"
	oPrint:SetPortrait()


Titulo := STR0004//Formulário Trimestral de Planillas de Sueldos y Salarios y Accidentes de Trabajo - Declaración Jurada


RptStatus({|lEnd| IMPBOL(@lEnd,wnRel,cString,.F., cMes, cAno )},Capital(Titulo))

	oPrint:Preview()  							// Visualiza impressao grafica antes de imprimir

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPBOL    ºAutor  ³Erika Kanamori      º Data ³  01/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function IMPBOL(lEnd,wnRel,cString,lGeraLanc, cMes, cAno )

Local cAcessaSRA	:= &( " { || " + ChkRH( "GPER690" , "SRA", "2" ) + " } " )
Local cFim := cFilAnt:= ""
Local cCajaNac := ""
Local cFilAux
Local nA := nB := nC := nD := nE := 0
Local nF := nH := nI := nJ := nK := 0
Local nQtdPer 	:= 0
Local nReg 		:= 0
Local nSavRec
Local nSavOrdem
Local nCont
Local nAux
Local lAux		:= .T.
Local lAllProCs := .F.
Local lSomaSRD  := .T.
Local aPerAberto:= aPerFechado:= aPerTodos:= {}
Local aCodFol   := aTnoTrab := {}
Local lMsgS007	:= .F.

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis para controle em ambientes TOP.                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cAlias  := ""
Local cQrySRA := "SRA"
Local cQrySRC := "SRC"
Local cQrySRD := "SRD"
Local cQrySR8
Local cQuery
Local dDtAus1
Local dDtAus2
Local aStruct := {}
Local aDtAfas := {}
Local aTabS006:= {}
Local lQuery  := .F.

//Vaviaveis private para impressao
Private aInfo:= {}
Private cNSegSocial
Private cNEmpMTrab
Private cNNit
Private cNRuc
Private cActividad
Private cCorrElectr
Private nFuncAdmissa:= nFuncDemissa := 0
Private nTotA		:= nTotB		:= nTotC		:= 0
Private nTotD		:= nTotE		:= nTotF		:= 0
Private nTotH		:= nTotI		:= nTotJ		:= 0
Private nTotK		:= 0
Private nTotTnoTrab	:= nTemporal	:= nPermParc	:= 0
Private nPermTotal	:= nMuerte		:= nEnfermedad	:= 0
Private nAccidTrim	:= nCajaNac 	:= nOtrasCajas	:= 0
Private nAFPPrevis	:= nAFPFutBol	:= nMonCajaNac  := 0
Private nMonOtrCajas:= nMonAFPPrev  := nMonFutBol 	:= 0
Private nEventuales	:= nPermanentes := 0
Private nAtivos := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Objetos para Impressao Grafica - Declaracao das Fontes Utilizadas.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oFont07, oFont08, oFont09, oFont10n, oFont12n

oFont07	:= TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.)
oFont08	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
oFont09	:= TFont():New("Courier New",09,09,,.F.,,,,.T.,.F.)
oFont08n:= TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.)     //Negrito//
oFont10n:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)     //Negrito//
oFont12n:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)     //5o.Negrito//9o.   /10o.Underline

nEpoca:= SET(5,1910)
//-- MUDAR ANO PARA 4 DIGITOS
SET CENTURY ON

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
		cSitu 	+= "'" + Substr( cSit, len(cSit)-1, 1) + "')"

	cCateg   := "("
	For nAux := 1 To (Len( cCat )-1)
		cCateg += "'" + Substr( cCat, nAux, 1) + "',"
	Next nAux
	cCateg	+= "'" + Substr( cCat, len(cCat)-1, 1) + "')"

    // Verifica el Proceso
	lAllProCs 	:= Iif(AllTrim( cProcessos ) == "*" .Or. Empty(cProcessos), .T., .F.)

	//montagem da query
	cQuery := "SELECT "
 	cQuery += " RA_FILIAL, RA_MAT, RA_CC, RA_NOME, RA_ADMISSA, RA_DEMISSA, "
  	cQuery += " RA_TNOTRAB, RA_CATFUNC, RA_TPAFP, RA_CAJSAL, RA_SITFOLH, RA_TPCONTR"
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
	cQuery += " RA_SITFOLH IN " + cSitu
	cQuery += "  AND "
	cQuery += " RA_CATFUNC IN " + cCateg
	cQuery += "  AND "
	If !(lAllProCs)
		cQuery	+= "RA_PROCES  IN (" + cProcessos + ") AND "
	EndIf
	cQuery += " D_E_L_E_T_=' ' "
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
	SetPrc(0,0)

	SetRegua((cQrySRA)->(RecCount()))

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
			(SRA->RA_CC  < cCustoDe) .Or. (SRA->RA_CC  > cCustoAte)  .Or. ;
			(SRA->RA_NOME < cNomeDe) .Or. (SRA->RA_NOME > cNomeAte)  .Or. ;
			!(SRA->RA_CATFUNC $ cCat) .Or. !(SRA->RA_SITFOLH $ cSit) .Or. ;
			!(lAllProCs .And. !(SRA->RA_PROCES $ cProcessos)))
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

		If cFilAnt <> (cQrySRA)->RA_FILIAL       //se filial eh diferente da anterior

			If lTotFil // Se NAO totaliza por filial
				If nTotTnoTrab <> 0
					//imprime relatorio
					oPrint:Endpage()
					GeraImpBol(cMes, cAno)
				Endif

				//zera variaveis
				nFuncAdmissa:= nFuncDemissa := nMonAFPPrev := nMonFutBol := 0
				nTotA		:= nTotB		:= nTotC	   := nTotD		  := nTotE := 0
				nTotF		:= nTotH		:= nTotI	   := nTotJ		  := nTotK := 0
				nAtivos     := nEventuales	:= nPermanentes:= nTotTnoTrab := 0
				nTemporal   := nPermParc  	:= nPermTotal  := nMuerte     := 0
				nCajaNac    := nAccidTrim 	:= nEnfermedad := nOtrasCajas := 0
				nAFPPrevis  := nAFPFutBol 	:= nMonCajaNac := nMonOtrCajas:= 0
				aTnoTrab:= {}
			EndIf

			//Carrega os periodos abertos e fechados do trimestre
			cFilAux:= (cQrySRA)->RA_FILIAL
			PerCompTri(cFilAux, @aPerAberto, @aPerFechado, @aPerTodos, cMes, cAno )
			If len(aPerFechado) < 1 .And. FWModeAccess('RCH') == 'C'
				cFilAux:= xFilial('RCH')
				PerCompTri(cFilAux, @aPerAberto, @aPerFechado, @aPerTodos, cMes, cAno )
			Endif

			//Carrega as informacoes sobre as caixas de saude cadastradas
			aTabS006 := Array(0)
			cCajaNac := ""
			fCarrTab ( @aTabS006, "S006", dDataRef, .T.)
			If !Empty(aTabS006)
				For nReg := 1 To Len(aTabS006)
					If aTabS006[nReg][7] == "S"
						cCajaNac += aTabS006[nReg][5] + "/"
					EndIf
				Next nReg
			EndIf

	    	//busca campos que nao existem em SM0 para preencher o "Datos Generales de la empresa..."

			cNSegSocial := IF( FTABELA("S007",1,4,) <> NIL, FTABELA("S007",1,4,), lMsgS007:=.T.)
			cNEmpMTrab  := IF( FTABELA("S007",1,5,) <> NIL, FTABELA("S007",1,5,), lMsgS007:=.T.)
			cNRuc       := IF( FTABELA("S007",1,6,) <> NIL, FTABELA("S007",1,6,), lMsgS007:=.T.)
			cNNit       := IF( FTABELA("S007",1,7,) <> NIL, FTABELA("S007",1,7,), lMsgS007:=.T.)
			cActividad  := IF( FTABELA("S007",1,8,) <> NIL, FTABELA("S007",1,8,), lMsgS007:=.T.)
			cCorrElectr := IF( FTABELA("S007",1,9,) <> NIL, FTABELA("S007",1,9,), lMsgS007:=.T.)

			If lMsgS007
				Help(" ",1,"GPR690S007")
				Return (.F.)
		  	EndIf


			fInfo(@aInfo, (cQrySRA)->RA_FILIAL)

			cFilAnt	:= (cQrySRA)->RA_FILIAL

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Carrega Variaveis Codigos Da Folha                           ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If !fP_CodFol(@aCodFol,(cQrySRA)->RA_FILIAL)
				Return
			Endif

		Endif

		 //consiste se o funcionario foi empregado depois do trimestre em questao
		If (cQrySRA)->RA_ADMISSA <> NIL
			If !len(aPerAberto) < 1 .And. (cQrySRA)->RA_ADMISSA > aPerAberto[len(aPerAberto)][6]
				(cQrySRA)->(dbSkip(1))
				Loop
			Endif
		Endif

		//se funcionario foi demitido, considera-se somente se foi demitido no periodo em questao.
	    If (cQrySRA)->RA_SITFOLH == "D"
	    	If !len(aPerFechado) < 1 .And. (cQrySRA)->RA_DEMISSA < aPerFechado[1][5]
		    	(cQrySRA)->(dbSkip(1))
		    	Loop
			EndIf
	    Endif

  		//zera variaveis para cada funcionario
		nA:= nB:= nC:= nD:= nE:= 0
		nF:= nH:= nI:= nJ:= nK:= 0
		lAux:= .T.

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Procura no SRC registros do funcionario no periodo aberto, se houver   |
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		nQtdPer := Len(aPerAberto)
		If !(nQtdPer < 1)
			lSomaSRD := .F. //Se pesquisar o movimento mensal nao considera valores acumulados
			If lQuery
				cAlias := "SRC"
				cQrySRC := "QSRC"

			    //busca periodos para formato Query
				cPeriodos   := "("
				For nAux:= 1 to (nQtdPer-1)
					cPeriodos += "'" + aPerAberto[nAux][1] + "',"
					aAdd( aDtAfas, { aPerAberto[nAux][5], aPerAberto[nAux][6] } )
				Next nAux
				aAdd( aDtAfas, { aPerAberto[nQtdPer][5], aPerAberto[nQtdPer][6] } )
				cPeriodos += "'" + aPerAberto[nQtdPer][1]+"')"

				//montagem da query
				cQuery := "SELECT "
				cQuery += " RC_FILIAL, RC_MAT, RC_PROCES, RC_ROTEIR, RC_PERIODO,RC_SEMANA, RC_VALOR, RC_PD "
				cQuery += " FROM " + RetSqlName(cAlias)
				cQuery += " WHERE "
				cQuery += " RC_FILIAL = '" + (cQrySRA)->RA_FILIAL + "' AND "
				cQuery += " RC_MAT ='" + (cQrySRA)->RA_MAT + "' AND "
			  	cQuery += " RC_PERIODO IN " + cPeriodos + " AND "
				If !(lAllProCs)
					cQuery	+= " RC_PROCES  IN (" + cProcessos + ") AND "
				EndIf
				cQuery += " RC_ROTEIR IN ("	+ cProcedi +") AND "
				cQuery += " D_E_L_E_T_=' ' "
				cQuery += " ORDER BY RC_FILIAL, RC_MAT, RC_PERIODO, RC_SEMANA"

				cQuery := ChangeQuery(cQuery)
				aStruct := (cAlias)->(dbStruct())

				If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRC,.T.,.T.)
					For nAux := 1 To Len(aStruct)
						If ( aStruct[nAux][2] <> "C" )
							TcSetField(cQrySRC,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
						EndIf
					Next nAux
				Endif
			Endif

			If !lQuery
				dbSelectArea(cQrySRC)
				dbSetOrder(7)  // RC_FILIAL+RC_MAT+RC_PERIODO+RC_SEMAN+...
			Endif

			For nAux:=1 to len(aPerAberto)

  			 If lAllProCs .Or. aPerAberto[nAux][7] $ cProcessos

				(cQrySRC)->(dbGoTop())
				If !lQuery
					dbSeek( (cQrySRA)->(RA_FILIAL+RA_MAT)+ aPerAberto[nAux][1]+ aPerAberto[nAux][2])
				Else
					While (cQrySRC)->(!Eof()) .And. !((cQrySRA)->(RA_FILIAL+RA_MAT)+ aPerAberto[nAux][1]+ aPerAberto[nAux][2] == (cQrySRC)->(RC_FILIAL+RC_MAT+RC_PERIODO+RC_SEMANA))
						(cQrySRC)->(dbSkip())
					End
				Endif

				While (cQrySRC)->(!Eof()) .And. (cQrySRA)->(RA_FILIAL+RA_MAT)+ aPerAberto[nAux][1]+ aPerAberto[nAux][2] == (cQrySRC)->(RC_FILIAL+RC_MAT+RC_PERIODO+RC_SEMANA)

					If ( ( !lAllProCs .And. aPerAberto[nAux][7] <> (cQrySRC)->(RC_PROCES) ) .Or.;
						 (!(cQrySRC)->(RC_ROTEIR) $ cProcedi) )
				   		(cQrySRC)->(dbSkip())
			   			Loop
					EndIf

					//**************************************************************************
					//* Somente o ultimo mes deve ser considerado para composicao dos valores  *
					//* Esta alteracao foi ratificada pela consultoria da Bolivia em 07/2012   *
					//**************************************************************************
					If aPerAberto[len(aPerAberto)][1]+aPerAberto[len(aPerAberto)][2] == (cQrySRC)->(RC_PERIODO+RC_SEMANA)
						Do Case
							Case PosSRV((cQrySRC)->RC_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "A"
								nA+=(cQrySRC)->RC_VALOR
					    	Case PosSRV((cQrySRC)->RC_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "B"
					    		nB+=(cQrySRC)->RC_VALOR
					   		Case PosSRV((cQrySRC)->RC_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "C"
					    		nC+=(cQrySRC)->RC_VALOR
					  		Case PosSRV((cQrySRC)->RC_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "D"
					    		nD+=(cQrySRC)->RC_VALOR
					  		Case PosSRV((cQrySRC)->RC_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "E"
					    		nE+=(cQrySRC)->RC_VALOR
					    	Case PosSRV((cQrySRC)->RC_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "F"
					    		nF+=(cQrySRC)->RC_VALOR
					    	Case PosSRV((cQrySRC)->RC_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "H"
					    		nH+=(cQrySRC)->RC_VALOR
					    	Case PosSRV((cQrySRC)->RC_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "I"
					    		nI+=(cQrySRC)->RC_VALOR
					    	Case PosSRV((cQrySRC)->RC_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "J"
					    		nJ+=(cQrySRC)->RC_VALOR
							Case PosSRV((cQrySRC)->RC_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "K"
					    		nK+=(cQrySRC)->RC_VALOR
					   EndCase
					EndIf
					/*
					//A pesquisa pelos afastamentos e enfermidades sera feita diretamente na SR8
					Do Case
					    Case (cQrySRC)->RC_PD == aCodFol[439,1]
					    	nTemporal  += 1
					    	nAccidTrim += 1
					    Case (cQrySRC)->RC_PD == aCodFol[770,1]
					    	nPermParc  += 1
					    	nAccidTrim += 1
					    Case (cQrySRC)->RC_PD == aCodFol[771,1]
					    	nPermTotal += 1
					    	nAccidTrim += 1
					    Case (cQrySRC)->RC_PD == aCodFol[772,1]
					    	nMuerte    += 1
					    	nAccidTrim += 1
					    Case (cQrySRC)->RC_PD == aCodFol[041,1]
					    	nEnfermedad+= 1
					EndCase
					*/
			   		(cQrySRC)->(dbSkip())
				End
			 EndIf
			Next nAux
			(cQrySRC)->(dbCloseArea())
		Endif


		//procura registros do funcionario no SRD
		nQtdPer := Len(aPerFechado)
		If !( nQtdPer < 1)
			If lQuery
				cAlias := "SRD"
				cQrySRD := "QSRD"

				//busca periodos para formato Query
				cPeriodos   := "("
				For nAux:= 1 to (nQtdPer-1)
					cPeriodos += "'" + aPerFechado[nAux][1] + "',"
					aAdd( aDtAfas, { aPerFechado[nAux][5], aPerFechado[nAux][6] } )
				Next nAux
				aAdd( aDtAfas, { aPerFechado[nQtdPer][5], aPerFechado[nQtdPer][6] } )
				cPeriodos += "'" + aPerFechado[nQtdPer][1]+"')"

				//montagem da query
				cQuery := "SELECT "
				cQuery += " RD_FILIAL, RD_MAT, RD_PROCES, RD_ROTEIR, RD_PERIODO, RD_SEMANA, RD_VALOR, RD_PD "
				cQuery += " FROM " + RetSqlName(cAlias)
				cQuery += " WHERE "
				cQuery += " RD_FILIAL = '" + (cQrySRA)->RA_FILIAL + "' AND "
				cQuery += " RD_MAT ='" + (cQrySRA)->RA_MAT + "' AND "
				cQuery += " RD_PERIODO IN " + cPeriodos + " AND "
				If !(lAllProCs)
					cQuery	+= " RD_PROCES  IN (" + cProcessos + ") AND "
				EndIf
				cQuery += " RD_ROTEIR IN ("	+ cProcedi  +") AND "
				cQuery += " D_E_L_E_T_=' ' "
				cQuery += " ORDER BY RD_FILIAL, RD_MAT, RD_PERIODO, RD_SEMANA"

				cQuery := ChangeQuery(cQuery)
				aStruct := (cAlias)->(dbStruct())
				If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRD,.T.,.T.)
					For nAux := 1 To Len(aStruct)
						If ( aStruct[nAux][2] <> "C" )
							TcSetField(cQrySRD,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
						EndIf
					Next nAux
				Endif
			Endif

			If !lQuery
				dbSelectArea(cQrySRD)
				dbSetOrder(3)  // RD_FILIAL+RD_MAT+RD_PERIODO+...
			Endif

			For nAux:=1 to Len(aPerFechado)

  			 If lAllProCs .Or. aPerFechado[nAux][7] $ cProcessos

				(cQrySRD)->(dbGoTop())
				If !lQuery
					dbSeek((cQrySRA)->(RA_FILIAL+RA_MAT)+ aPerFechado[nAux][1])
				Else
					While (cQrySRD)->(!Eof()) .And. !((cQrySRA)->(RA_FILIAL+RA_MAT)+aPerFechado[nAux][1]+aPerFechado[nAux][2]== (cQrySRD)->(RD_FILIAL+RD_MAT+RD_PERIODO+RD_SEMANA))
						(cQrySRD)->(dbSkip())
					End
				Endif

				While (cQrySRD)->(!Eof()) .And. (cQrySRA)->(RA_FILIAL+RA_MAT)+aPerFechado[nAux][1]+If(lQuery,aPerFechado[nAux][2],"") == (cQrySRD)->(RD_FILIAL+RD_MAT+RD_PERIODO+If(lQuery,RD_SEMANA,""))

					If ( ( !lAllProCs .And. aPerFechado[nAux][7] <> (cQrySRD)->(RD_PROCES) ) .Or.;
						 (!(cQrySRD)->(RD_ROTEIR) $ cProcedi ) .Or.;
						 (lQuery .And. aPerFechado[nAux][2] <> (cQrySRD)->(RD_SEMANA)) )
				   		(cQrySRD)->(dbSkip())
			   			Loop
					EndIf

					//**************************************************************************
					//* Somente o ultimo mes deve ser considerado para composicao dos valores  *
					//* Esta alteracao foi ratificada pela consultoria da Bolivia em 07/2012   *
					//**************************************************************************
					If lSomaSRD .And. aPerFechado[len(aPerFechado)][1]+aPerFechado[len(aPerFechado)][2] == (cQrySRD)->(RD_PERIODO+RD_SEMANA)
			 			Do Case
							Case PosSRV((cQrySRD)->RD_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "A"
								nA+=(cQrySRD)->RD_VALOR
							Case PosSRV((cQrySRD)->RD_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "B"
								nB+=(cQrySRD)->RD_VALOR
							Case PosSRV((cQrySRD)->RD_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "C"
								nC+=(cQrySRD)->RD_VALOR
							Case PosSRV((cQrySRD)->RD_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "D"
								nD+=(cQrySRD)->RD_VALOR
							Case PosSRV((cQrySRD)->RD_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "E"
								nE+=(cQrySRD)->RD_VALOR
							Case PosSRV((cQrySRD)->RD_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "F"
								nF+=(cQrySRD)->RD_VALOR
							Case PosSRV((cQrySRD)->RD_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "H"
								nH+=(cQrySRD)->RD_VALOR
							Case PosSRV((cQrySRD)->RD_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "I"
								nI+=(cQrySRD)->RD_VALOR
							Case PosSRV((cQrySRD)->RD_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "J"
								nJ+=(cQrySRD)->RD_VALOR
							Case PosSRV((cQrySRD)->RD_PD, (cQrySRA)->RA_FILIAL,"RV_INFSAL" ) == "K"
								nK+=(cQrySRD)->RD_VALOR
						End	Case
					EndIf
					/*
					//A pesquisa pelos afastamentos e enfermidades sera feita diretamente na SR8
					Do Case
						Case (cQrySRD)->RD_PD == aCodFol[439,1]
							nTemporal  += 1
							nAccidTrim += 1
						Case (cQrySRD)->RD_PD == aCodFol[770,1]
							nPermParc  += 1
							nAccidTrim += 1
						Case (cQrySRD)->RD_PD == aCodFol[771,1]
							nPermTotal += 1
							nAccidTrim += 1
						Case (cQrySRD)->RD_PD == aCodFol[772,1]
							nMuerte    += 1
							nAccidTrim += 1
						Case (cQrySRD)->RD_PD == aCodFol[041,1]
							nEnfermedad+= 1
					 EndCase
					 */
		           	 (cQrySRD)->(dbSkip())
		      	End
			 EndIf
		    Next nAux
		    (cQrySRD)->(dbCloseArea())
		Endif


		//Obtem os dados referentes a acidentes e enfermidades
		If !Empty( aDtAfas )
			dDtAus1 := DTOS( aDtAfas[1,1] )
			dDtAus2 := DTOS( aDtAfas[Len(aDtAfas),2] )

			cQrySR8 := GetNextAlias()

			BeginSql alias cQrySR8

				SELECT SR8.R8_FILIAL, SR8.R8_MAT, SR8.R8_PD, SR8.R8_RESINC, RCM.RCM_TPIMSS
				FROM %table:SR8% SR8
				INNER JOIN %table:RCM% RCM
				ON SR8.R8_TIPOAFA = RCM.RCM_TIPO
				WHERE	R8_FILIAL = %exp:(cQrySRA)->(RA_FILIAL)% AND
						R8_MAT = %exp:(cQrySRA)->(RA_MAT)% AND
						R8_DTBLEG BETWEEN %exp:dDtAus1% AND %exp:dDtAus2%
			EndSql

			Do While (cQrySR8)->(!Eof())

				Do Case
					Case (cQrySR8)->RCM_TPIMSS == "A"
						nAccidTrim += 1
					Case (cQrySR8)->RCM_TPIMSS == "P"
						nEnfermedad += 1
				 EndCase

				Do Case
					Case (cQrySR8)->R8_RESINC == "1"
						nTemporal += 1
					Case (cQrySR8)->R8_RESINC == "2"
						nPermParc += 1
					Case (cQrySR8)->R8_RESINC == "3"
						nPermTotal += 1
					Case (cQrySR8)->R8_RESINC == "4"
						nMuerte += 1
				 EndCase

				(cQrySR8)->(dbSkip())

			Enddo

			(cQrySR8)->(dbCloseArea())

		EndIf

		//totaliza variaveis
		nTotA+=nA
		nTotB+=nB
		nTotC+=nC
		nTotD+=nD
		nTotE+=nE
		nTotF+=nF
		nTotH+=nH
		nTotI+=nI
		nTotJ+=nJ
		nTotK+=nK

		//consiste data de admissao e demissao
		If !(len(aPerAberto) < 1 )
			If (cQrySRA)->RA_ADMISSA >= aPerAberto[1][5] .And. (cQrySRA)->RA_ADMISSA <= aPerAberto[len(aPerAberto)][6]
			   nFuncAdmissa += 1
			Endif
			If (cQrySRA)->RA_SITFOLH == "D"
				If (cQrySRA)->RA_DEMISSA >= aPerAberto[1][5] .And. (cQrySRA)->RA_DEMISSA <= aPerAberto[len(aPerAberto)][6]
				   nFuncDemissa += 1
				Endif
			Endif

		ElseIf !(len(aPerFechado) < 1)

			If (cQrySRA)->RA_ADMISSA >= aPerFechado[1][5] .And. (cQrySRA)->RA_ADMISSA <= aPerFechado[len(aPerFechado)][6]
			 	nFuncAdmissa += 1
			 Endif
			 If (cQrySRA)->RA_SITFOLH == "D"
				If (cQrySRA)->RA_DEMISSA >= aPerFechado[1][5] .And. (cQrySRA)->RA_DEMISSA <= aPerFechado[len(aPerFechado)][6]
				   nFuncDemissa += 1
				Endif
		     Endif
		Endif

		If (cQrySRA)->RA_SITFOLH $ cSit
	   		nAtivos+= 1
	   		If (cQrySRA)->RA_TPCONTR == '2'
		   		nEventuales+=1
		   	Else
		   		nPermanentes+=1
		   	Endif
	   	Endif

		If Empty((cQrySRA)->RA_TNOTRAB)
			lAux:= .F.
		Else
		   	For nAux:=1 to len(aTnoTrab)
		   		If (cQrySRA)->RA_TNOTRAB == aTnoTrab[nAux]
		   			lAux:=.F.
		   			nAux:=len(aTnoTrab)
		   		Endif
		   	Next nAux
		Endif

	   	If lAux .And. ( len(aPerAberto) > 0 .Or. len(aPerFechado) > 0 )
	   		aAdd(aTnoTrab, (cQrySRA)->RA_TNOTRAB)
	   		nTotTnoTrab+= 1
		Endif

		If nH > 0
			If (cQrySRA)->RA_TPAFP == "1"
				nAFPPrevis += 1
				nMonAFPPrev+= nH
			Elseif (cQrySRA)->RA_TPAFP == "2"
				nAFPFutBol += 1
				nMonFutBol += nH
			EndIf
		EndIf

		If (nA + nB + nC + nD + nE + nF) > 0
			If (cQrySRA)->RA_CAJSAL $ cCajaNac
				nCajaNac+= 1
				nMonCajaNac+= nA + nB + nC + nD + nE + nF
			Else
				nOtrasCajas+= 1
				nMonOtrCajas+= nA + nB + nC + nD + nE + nF
			EndIf
		EndIf

		(cQrySRA)->(dbSkip())
	End

	If nTotTnoTrab <> 0
		//imprime relatorio
		oPrint:Endpage()
		GeraImpBol(cMes, cAno)
	Endif

	If !lQuery
		dbSelectArea(cQrySRA)
		dbSetOrder(nSavOrdem)
		dbGoTo(nSavRec)
	Endif

If lQuery
	If Select(cQrySRA) > 0
	 (cQrySRA)->(dbCloseArea())
	Endif
	If Select(cQrySRC) > 0
	 (cQrySRC)->(dbCloseArea())
	Endif
EndIf


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GERAIMPBOLºAutor  ³Erika Kanamori      º Data ³  12/20/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraImpBol(cMes, cAno)

Local cDireccion  := " "
Local cNum        := " "
Local cFileLogo1  := ""
Local cFileLogo2  := ""
Local cStartPath  := GetSrvProfString("Startpath","")
Local aNSegSocial := {}
Local aNEmpMTrab  := {}
Local nCont
Local nTotG
Local nTotL

//totaliza campos "CONCEPTOS" restantes
nTotG := nTotA+nTotB+nTotC+nTotD+nTotE+nTotF
nTotL := nTotH+nTotI+nTotJ

If !lTotFil //Se totalização for por empresa, pega os dados da matriz informada
	fInfo(@aInfo, cFilTot)
EndIf

//separa endereco do numero
If aInfo[4] <>  ""
	If "Nr." $ aInfo[4]
		cDireccion := Left(aInfo[4], (Rat("Nr.", aInfo[4]))-2)
		cNum	   := Right(aInfo[4], (Len(aInfo[4]) - Len(cDireccion)-5))
	Else
		cDireccion:= Left(aInfo[4], (Rat(",", aInfo[4]))-1)
		cNum      := Right(aInfo[4], (Len(aInfo[4])- Len(cDireccion)-1))
    Endif
Endif


//separa os digitos dos campos nº seguro patronal e nº empleador ministerio de trabajo
For nCont:=1 to 10
	aAdd(aNSegSocial, Left(cNSegSocial,1))
	 cNSegSocial:=Right(cNSegSocial, len(cNSegSocial)-1)
Next nCont

For nCont:=1 to 10
	aAdd(aNEmpMTrab, Left(cNEmpMTrab,1))
	cNEmpMTrab:=Right(cNEmpMTrab, len(cNEmpMTrab)-1)
Next nCont


//calcula o ultimo mes do trimestre para impressao da data
For nCont:= 1 to 2
	If cMes == "12"
		cAno:= Right(StrZero((Val(cAno)+1)),4)
		cMes := "0"
	Endif
	cMes:= Right(StrZero((Val(cMes)+1)),2)
Next nCont


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³FORMULARIO UNICO DE PRESENTACION TRIMESTRAL DE PLANILLA DE SUELDOS Y        |
//|Y SALARIOS Y ACCIDENTES DE TRABAJO - DECLARACION JURADA                     |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:StartPage() 			//Inicia uma nova pagina

oPrint:Box ( 0020, 0035, 3150, nColMax )
oPrint:Box ( 0027, 0045, 3138, nColMax-7 )

cFileLogo1 	:= cStartPath+ "BOL_140A.BMP"	// Logo: REPÚBLICA DE BOLIVIA MINISTERIO DE TRABAJO
cFileLogo2 	:= cStartPath+ "BOL_140B.BMP"	// Logo: DIRECCION GENERAL DE TRABAJO

If File( cFileLogo1 )
	oPrint:SayBitmap(050,180, cFileLogo1,245,210)
EndIf
If File( cFileLogo2 )
	oPrint:SayBitmap(085,2060, cFileLogo2,210,150)
EndIf

oPrint:say(255,110,"REPÚBLICA DE BOLIVIA",oFont08n)
oPrint:say(240,1970,"MINISTERIO DE TRABAJO",oFont08n)

oPrint:say ( 0075, 0500, STR0005, oFont12n )   //"FORMULARIO ÚNICO DE PRESENTACIÓN TRIMESTRAL DE PLANILLAS"
oPrint:say ( 0125, 0650, STR0006, oFont12n )   //"DE SUELDOS Y SALARIOS Y ACCIDENTES DE TRABAJO"
oPrint:say ( 0175, 1000, STR0032, oFont12n )   //"DECLARACIÓN JURADA"

oPrint:say ( 0305, 1390, STR0007 +" "+ AllTrim(MesExtenso(cMes)), oFont09)		//"CORRESPONDIENTE AL MES"
oPrint:say ( 0305, 2150, STR0008 +" "+ Transform(cAno,"9999") + ".", oFont09)	//"DE"

oPrint:box ( 0375, 0060, 0441, nColMax-21 )
oPrint:box ( 0376, 0061, 0440, nColMax-22 )
oPrint:say ( 0393, 0075, STR0009, oFont10n )   //"1.- DATOS GENERALES DE LA EMPRESA O INSTITUICIÓN"

oPrint:say ( 0496, 0075, STR0010, oFont09 )   //"Nº PATRONAL"
oPrint:say ( 0536, 0055, STR0012, oFont09 )   //"SEGURO SOCIAL"
oPrint:box  ( 0480, 0320, 0589, 0820 )     //box nº patronal seguro social
oPrint:line ( 0480, 0370, 0589, 0370 )     //linhas verticais
oPrint:line ( 0480, 0420, 0589, 0420 )
oPrint:line ( 0480, 0470, 0589, 0470 )
oPrint:line ( 0480, 0520, 0589, 0520 )
oPrint:line ( 0480, 0570, 0589, 0570 )
oPrint:line ( 0480, 0620, 0589, 0620 )
oPrint:line ( 0480, 0670, 0589, 0670 )
oPrint:line ( 0480, 0720, 0589, 0720 )
oPrint:line ( 0480, 0770, 0589, 0770 )
oPrint:say ( 0510, 0340, aNSegSocial[1], oFont08)   //campos do nº patronal seguro social
oPrint:say ( 0510, 0390, aNSegSocial[2], oFont08)
oPrint:say ( 0510, 0440, aNSegSocial[3], oFont08)
oPrint:say ( 0510, 0490, aNSegSocial[4], oFont08)
oPrint:say ( 0510, 0540, aNSegSocial[5], oFont08)
oPrint:say ( 0510, 0590, aNSegSocial[6], oFont08)
oPrint:say ( 0510, 0640, aNSegSocial[7], oFont08)
oPrint:say ( 0510, 0690, aNSegSocial[8], oFont08)
oPrint:say ( 0510, 0740, aNSegSocial[9], oFont08)
oPrint:say ( 0510, 0790, aNSegSocial[10], oFont08)

oPrint:say ( 0485, 0862, STR0011, oFont09 )   //"Nº EMPLEADOR"
oPrint:say ( 0520, 0855, STR0013, oFont09 )   //"MINISTERIO DE"
oPrint:say ( 0555, 0917, STR0015, oFont09 )   //"TRABAJO"
oPrint:box  ( 0480, 1120, 0589, 1620 )     //box nº empleador ministerio de trabajo
oPrint:line ( 0480, 1170, 0589, 1170 )     //linhas verticais
oPrint:line ( 0480, 1220, 0589, 1220 )
oPrint:line ( 0480, 1270, 0589, 1270 )
oPrint:line ( 0480, 1320, 0589, 1320 )
oPrint:line ( 0480, 1370, 0589, 1370 )
oPrint:line ( 0480, 1420, 0589, 1420 )
oPrint:line ( 0480, 1470, 0589, 1470 )
oPrint:line ( 0480, 1520, 0589, 1520 )
oPrint:line ( 0480, 1570, 0589, 1570 )
oPrint:say ( 0510, 1140, aNEmpMTrab[1], oFont08)		//campos do nº empleador ministerio de trabajo
oPrint:say ( 0510, 1190, aNEmpMTrab[2], oFont08)
oPrint:say ( 0510, 1240, aNEmpMTrab[3], oFont08)
oPrint:say ( 0510, 1290, aNEmpMTrab[4], oFont08)
oPrint:say ( 0510, 1340, aNEmpMTrab[5], oFont08)
oPrint:say ( 0510, 1390, aNEmpMTrab[6], oFont08)
oPrint:say ( 0510, 1440, aNEmpMTrab[7], oFont08)
oPrint:say ( 0510, 1490, aNEmpMTrab[8], oFont08)
oPrint:say ( 0510, 1540, aNEmpMTrab[9], oFont08)
oPrint:say ( 0510, 1590, aNEmpMTrab[10], oFont08)

oPrint:box ( 0480, 1830, 0589, 2320 )	//box nº de NIT
oPrint:say ( 0490, 1652, "Nºde RUC", oFont09 )
oPrint:line ( 0532, 1830, 0532, 2320 )  // Linha separadora RUC / NIT
oPrint:say ( 0545, 1652, "Nºde NIT", oFont09 )

oPrint:say ( 0490, 1940, cNRuc, oFont08)		// nº RUC
oPrint:say ( 0545, 1940, cNNit, oFont08)		// nº NIT

oPrint:say ( 0648, 0055, STR0016, oFont09 )   //"NOMBRE O RAZON SOCIAL"
oPrint:say ( 0648, 1390, STR0017, oFont09 )   //"ACTIVIDAD ECONOMICA PRINCIPAL"
oPrint:say ( 0726, 0170, STR0018, oFont09 )   //"DIRECCION"
oPrint:say ( 0726, 1400, STR0019, oFont09 )   //"Nº"
oPrint:say ( 0726, 1750, STR0020, oFont09 )   //"ZONA"
oPrint:say ( 0800, 0150, STR0021, oFont09 )   //"TELEFONO(S)"
oPrint:say ( 0800, 1030, STR0022, oFont09 )   //"FAX"
oPrint:say ( 0800, 1400, STR0023, oFont09 )   //"CORREO ELECTRONICO"
oPrint:box ( 0634, 0480, 0694, 1355 )		  //box nombre o razon social
oPrint:say ( 0648, 0490, aInfo[3],oFont08)   		//campo razon social
oPrint:box ( 0634, 1975, 0694, nColMax-30 )	  //box actividad economica principal
oPrint:say ( 0645, 1985, cActividad, oFont08)      //campo actividad economica principal
oPrint:box ( 0714, 0480, 0774, 1355 )		  //box direccion
oPrint:say ( 0726, 0490, cDireccion,oFont08)			//campo direccion
oPrint:box ( 0714, 1450, 0774, 1700 )		  //box nº
oPrint:say ( 0726, 1460, cNum, oFont08)					//campo nº
oPrint:box ( 0714, 1850, 0774, nColMax-30 )  //box zona
oPrint:say ( 0726, 1860, aInfo[13],oFont08)		//campo zona
oPrint:box ( 0789, 0480, 0849, 0735 )        //boxes telefonos
oPrint:box ( 0789, 0755, 0849, 1005 )
oPrint:say ( 0800, 0490, aInfo[10],oFont08)		//campo telefono (1)
oPrint:box ( 0789, 1105, 0849, 1355 )        //box fax
oPrint:say ( 0800, 1115, aInfo[11],oFont08)		//campo fax
oPrint:box ( 0789, 1800, 0849, nColMax-30 )  //box correo electronico
oPrint:say ( 0800, 1810, cCorrElectr, oFont08)		//campo correo electronico

//box personal asegurado y aportes
oPrint:box ( 0879, 0059, 0944, nColMax-21 )
oPrint:box ( 0880, 0060, 0945, nColMax-22 )
oPrint:say ( 0895, 0075, STR0024, oFont10n)			 //"2.- PERSONAL ASEGURADO Y APORTES"

oPrint:box ( 0965, 0060, 1330, nColMax-22 )
oPrint:say ( 1014, 0110, STR0025, oFont09)		//"Nº DE ASEGURADOS"
oPrint:say ( 1054, 0130, STR0027, oFont09)		//"CAJA NACIONAL"
oPrint:say ( 1094, 0180, STR0030, oFont09)		//"DE SALUD"
oPrint:box ( 1005, 0450, 1112, 0575 )  		// box nº de asegurados caja social de salud
oPrint:say ( 1040, 0480, cValToChar(nCajaNac), oFont08)		//campo nº de asegurados caja social de salud

oPrint:say ( 1014, 0695, STR0026, oFont09)		//"MONTO"
oPrint:say ( 1054, 0665, STR0028, oFont09)		//"APORTADO"
oPrint:say ( 1094, 0695, STR0031, oFont09)		//"(Bs.)"
oPrint:box ( 1005, 0850, 1112, 1120 )  		// box monto aportado (bs.)
oPrint:say ( 1040, 0860, Transform((nMonCajaNac*0.1), "999,999,999.99"), oFont08)

oPrint:say ( 1019, 1200, STR0025, oFont09)		//"Nº DE ASEGURADOS"
oPrint:say ( 1059, 1240, STR0029, oFont09)		//"OTRAS CAJAS"
oPrint:box ( 1005, 1550, 1112, 1675 )  		// box nº de asegurados otras cajas
oPrint:say ( 1040, 1600, cValToChar(nOtrasCajas), oFont08)

oPrint:say ( 1014, 1820, STR0026, oFont09)		//"MONTO"
oPrint:say ( 1054, 1795, STR0028, oFont09)		//"APORTADO"
oPrint:say ( 1094, 1820, STR0031, oFont09)		//"(Bs.)"
oPrint:box ( 1005, 2000, 1112, nColMax-60 )// box monto aportado (bs.)
oPrint:say ( 1040, 2010, Transform((nMonOtrCajas*0.1), "999,999,999.99"), oFont08)

oPrint:say ( 1200, 0120, STR0033, oFont09)		//"Nº DE AFILIADOS"
oPrint:say ( 1240, 0130, STR0034, oFont09)		//"AFP PREVISIÓN"
oPrint:box ( 1186, 0450, 1293, 0575 )  		// box nº de afiliados AFP Prevision
oPrint:say ( 1230, 0480, cValToChar(nAFPPrevis), oFont08)

oPrint:say ( 1195, 0695, STR0026, oFont09)		//"MONTO"
oPrint:say ( 1235, 0665, STR0028, oFont09)		//"APORTADO"
oPrint:say ( 1275, 0695, STR0031, oFont09)		//"(Bs.)"
oPrint:box ( 1186, 0850, 1293, 1120 )  		// box monto aportado (bs.)
oPrint:say ( 1230, 0860, Transform(nMonAFPPrev, "999,999,999.99"), oFont08)

oPrint:say ( 1200, 1210, STR0033, oFont09)		//"Nº DE AFILIADOS"
oPrint:say ( 1240, 1175, STR0035, oFont09)		//"AFP FUTURO BOLIVIA"
oPrint:box ( 1186, 1550, 1293, 1675 )  		// box nº de asegurados AFP futuro bolivia
oPrint:say ( 1230, 1600, cValToChar(nAFPFutBol), oFont08)

oPrint:say ( 1195, 1820, STR0026, oFont09)		//"MONTO"
oPrint:say ( 1235, 1795, STR0028, oFont09)		//"APORTADO"
oPrint:say ( 1275, 1820, STR0031, oFont09)		//"(Bs.)"
oPrint:box ( 1186, 2000, 1293, nColMax-60 )// box monto aportado (bs.)
oPrint:say ( 1230, 2010, Transform(nMonFutBol, "999,999,999.99"), oFont08)


//box composicion salarial
oPrint:box ( 1359, 0059, 2221, 1221 )		//box composición salarial
oPrint:box ( 1360, 0060, 2220, 1220 )
oPrint:say ( 1371, 00075, STR0036, oFont10n)		//"3.- COMPOSICIÓN SALARIAL"
oPrint:line( 1419, 0060, 1419, 1220 )
oPrint:line( 1420, 0061, 1420, 1221 )

oPrint:box ( 1439, 0060, 2200, 1200 )	    	//box concepto
oPrint:line( 1439, 0765, 2200, 0765 )			//linha vertical
oPrint:say ( 1480, 0300, STR0037, oFont09)		//"CONCEPTO"
oPrint:say ( 1460, 0870, STR0038, oFont09)		//"MONTO PAGADO"
oPrint:say ( 1490, 0850, STR0039, oFont09)		//"(En Bolivianos)"

oPrint:line( 1550, 0060, 1550, 1200 )
oPrint:say ( 1570, 0075, STR0040, oFont09)								//"HABER BASICO (A)"
oPrint:say ( 1570, 0900, Transform(nTotA, "999,999,999.99"), oFont08)	//campo haber basico (A)

oPrint:line( 1615, 0060, 1615, 1200 )
oPrint:say ( 1635, 0075, STR0041, oFont09)								//"BONO DE ANTIGUEDAD (B)"
oPrint:say ( 1635, 0900, Transform(nTotB, "999,999,999.99"), oFont08)	//campo bono de antiguedad (B)

oPrint:line( 1680, 0060, 1680, 1200 )
oPrint:say ( 1700, 0075, STR0042, oFont09)								//"PAGO POR HORAS EXTRAORDINARIAS (C)"
oPrint:say ( 1700, 0900, Transform(nTotC, "999,999,999.99"), oFont08)  //campo pago por horas extraordinarias (C)

oPrint:line( 1745, 0060, 1745, 1200 )
oPrint:say ( 1765, 0075, STR0043, oFont09)											//"OTROS BONOS (D+E+F)"
oPrint:say ( 1765, 0900, Transform(nTotD+nTotE+nTotF, "999,999,999.99"), oFont08)	//campo otros bonos (D+E+F)

oPrint:line( 1810, 0060, 1810, 1200 )
oPrint:say ( 1830, 0075, STR0044, oFont09)								//"TOTAL GANADO (G)"
oPrint:say ( 1830, 0900, Transform(nTotG, "999,999,999.99"), oFont08)	//campo total ganado (G)

oPrint:line( 1875, 0060, 1875, 1200 )
oPrint:say ( 1895, 0075, STR0045, oFont09)								//"A.F.P. (H)"
oPrint:say ( 1895, 0900, Transform(nTotH, "999,999,999.99"), oFont08)	//campo A.F.P (H)

oPrint:line( 1940, 0060, 1940, 1200 )
oPrint:say ( 1960, 0075, STR0046, oFont09)								//"R.C. - I.V.A. (I)"
oPrint:say ( 1960, 0900, Transform(nTotI, "999,999,999.99"), oFont08)	//campo R.C. - I.V.A(I)

oPrint:line( 2005, 0060, 2005, 1200 )
oPrint:say ( 2025, 0075, STR0047, oFont09)								//"OTROS DESCUENTOS (J)"
oPrint:say ( 2025, 0900, Transform(nTotJ, "999,999,999.99"), oFont08)

oPrint:line( 2070, 0060, 2070, 1200 )
oPrint:say ( 2090, 0075, STR0048, oFont09)								//"TOTAL DESCUENTOS (K)"
oPrint:say ( 2090, 0900, Transform(nTotL, "999,999,999.99"), oFont08)

oPrint:line( 2135, 0060, 2135, 1200 )
oPrint:say ( 2155, 0075, STR0049, oFont09)								//"TOTAL DESCUENTOS (L)"
oPrint:say ( 2155, 0900, Transform(nTotG-nTotL, "999,999,999.99"), oFont08)

oPrint:box ( 1359, 1250, 2221, nColMax-21 )		//box accidentes y enfermedades de trabajo
oPrint:box ( 1360, 1251, 2220, nColMax-22 )

oPrint:say ( 1371, 1265, STR0050, oFont10n)		//"4.- ACCIDENTES Y ENFERMEDADES DE TRABAJO"
oPrint:line( 1419, 1251, 1419, nColMax-22 )
oPrint:line( 1420, 1251, 1420, nColMax-22 )

oPrint:say ( 1470, 1400, STR0051, oFont09)		//"NUMERO DE ACCIDENTES"
oPrint:say ( 1510, 1440, STR0052, oFont09)		//"EN EL TRIMESTRE"
oPrint:box ( 1459, 1850, 1558, 2050 )
oPrint:say ( 1500, 1950, cValToChar(nAccidTrim), oFont08)

oPrint:box ( 1590, 1270, 1890, 2300 )           //tabela
oPrint:say ( 1598, 1450, STR0053, oFont09)		//"N DE TRABAJADORES POR TIPO DE LESIÓN"
oPrint:line( 1640, 1270, 1640, 2300 )
oPrint:say ( 1650, 1555, STR0054, oFont09)		//"INCAPACIDAD"
oPrint:line( 1690, 1270, 1690, 2125 )
oPrint:say ( 1705, 1305, STR0055, oFont09)		//"TEMPORAL"
oPrint:say ( 1800, 1350, cValToChar(nTemporal), oFont08)
oPrint:say ( 1705, 1560, STR0056, oFont09)		//"PERMANENTE"
oPrint:say ( 1735, 1580, STR0058, oFont09)		//"PARCIAL"
oPrint:say ( 1800, 1650, cValToChar(nPermParc), oFont08)
oPrint:say ( 1705, 1865, STR0056, oFont09)		//"PERMANENTE"
oPrint:say ( 1735, 1910, STR0059, oFont09)		//"TOTAL"
oPrint:say ( 1800, 1950, cValToChar(nPermTotal), oFont08)
oPrint:say ( 1685, 2150, STR0057, oFont09)		//"MUERTE"
oPrint:say ( 1800, 2240, cValToChar(nMuerte), oFont08)
oPrint:line( 1780, 1270, 1780, 2300 )
oPrint:line( 1690, 1500, 1890, 1500 )          //linha vertical
oPrint:line( 1690, 1810, 1890, 1810 )          //linha vertical
oPrint:line( 1640, 2125, 1890, 2125 )          //linha vertical

oPrint:say ( 1931, 1400, STR0060, oFont09)		//"Nº DE ENFERMEDADES"
oPrint:say ( 1971, 1465, STR0062, oFont09)		//"DE TRABAJO"
oPrint:box ( 1920, 1850, 2020, 2050 )
oPrint:say ( 1950, 1950, cValToChar(nEnfermedad), oFont08)

oPrint:say ( 2081, 1450, STR0061, oFont09)		//"Nº DE TURNOS"
oPrint:say ( 2121, 1465, STR0062, oFont09)		//"DE TRABAJO"
oPrint:box ( 2070, 1850, 2170, 2050 )
oPrint:say ( 2100, 1950, cValToChar(nTotTnoTrab), oFont08)

//Box personal ocupado
oPrint:box ( 2250, 0060, 2310, 1020 )
oPrint:box ( 2251, 0059, 2311, 1021 )
oPrint:say ( 2264, 0075, STR0063, oFont10n)		//"5.- PERSONAL OCUPADO"
oPrint:box ( 2330, 0060, 2500, 1020 )

oPrint:line( 2415, 0060, 2415, 1020 )
oPrint:line( 2330, 0470, 2500, 0470 )          //linha vertical
oPrint:line( 2330, 0720, 2500, 0720 )          //linha vertical

oPrint:box ( 2250, 1050, 2310, nColMax-20 )
oPrint:box ( 2251, 1049, 2311, nColMax-21 )

oPrint:say ( 2342, 0070, STR0065, oFont09)		//"Nº TOTAL DE PERSONAS"
oPrint:say ( 2375, 0150, STR0070, oFont09)		//"OCUPADAS"
oPrint:say ( 2440, 0250, cValToChar(nAtivos), oFont08)  //campo nº total de personas ocupadas
oPrint:say ( 2342, 0500, STR0066, oFont09)		//"EVENTUALES"
oPrint:say ( 2440, 0550, cValToChar(nEventuales), oFont08)	//campo eventuales
oPrint:say ( 2342, 0760, STR0067, oFont09)		//"PERMANENTES"
oPrint:say ( 2440, 0830, cValToChar(nPermanentes), oFont08) //campo permanentes

//box personal contratado y retirado en el trimestre
oPrint:box ( 2330, 1050, 2500, nColMax-21 )
oPrint:say ( 2264, 1060, STR0064, oFont10n)		//"6.- PERSONAL CONTRATADO Y RETIRADO EN EL TRIMESTRE"

oPrint:say ( 2342, 1110, STR0068, oFont09)		//"Nº DE PERSONAS CONTRATADAS"
oPrint:say ( 2375, 1200, STR0071, oFont09)		//"EN EL TRIMESTRE"
oPrint:say ( 2342, 1780, STR0069, oFont09)		//"Nº DE PERSONAS RETIRADAS"
oPrint:say ( 2375, 1850, STR0071, oFont09)		//"EN EL TRIMESTRE"

oPrint:line( 2415, 1050, 2415, nColMax-21 )
oPrint:say ( 2440, 1270, CValToChar(nFuncAdmissa), oFont08)  //campo n de personas contratadas
oPrint:line( 2330, 1680, 2500, 1680 )          //linha vertical
oPrint:say ( 2440, 2000, CValToChar(nFuncDemissa), oFont08)  //campo n de personas retiradas

oPrint:say ( 2520, 0065, STR0072, oFont08)		//"NOTA: En mi condición de empleador y/o representante legal de acuerdo al Art. 1322 del Código Civil, declaro expresamente que los"
oPrint:say ( 2550, 0065, STR0073, oFont08)		//"datos incluidos en el presente formulario son verídicos y fidedignos; por lo cual el Ministerio de Trabajo en uso de sus específicas"
oPrint:say ( 2580, 0065, STR0074, oFont08)		//"funciones y atribuciones establecidas por Ley, pueda proceder a las inspecciones, verificaciones y otras medidas necesarias para"
oPrint:say ( 2610, 0065, STR0075, oFont08)		//"precautelar el cuplimiento de las normas en materia laboral."

oPrint:say ( 2850, 0080, Replicate("_",53), oFont09)
oPrint:say ( 2900, 0120, STR0076, oFont09)		//"NOMBRE DEL EMPLEADOR Y/O REPRESENTANTE LEGAL"
oPrint:say ( 2847, 0100, cEmpregNome, oFont08)     //campo nombre del empleador y/o representante legal
oPrint:say ( 2850, 1200, Replicate("_",53), oFont09)

oPrint:say ( 2900, 1300, STR0077, oFont09)		//"FIRMA DEL EMPLEADOR Y/O REPRESENTANTE LEGAL"
oPrint:say ( 2950, 1210, STR0078, oFont09)		//"NºDE DOCUMENTO DE INDENTIDAD:_____________________"
oPrint:say ( 2947, 1800, cEmpregCIC, oFont08)		//campo nº de docuento de identidad

oPrint:say ( 3080, 0065, STR0079+":  "+aInfo[5], oFont09)		//"LUGAR DE PRESENTACIÓN"
oPrint:say ( 3080, 0900, ",  "+StrZero(Day(Date()),2)+"  "+STR0008+"  "+Upper(AllTrim(MesExtenso(Month(Date()))))+"  "+STR0008+"  "+Transform(Year(Date()),"9999")+".", oFont09)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PerCompTriºAutor  ³Erika Kanamori      º Data ³  01/31/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna Periodos abertos e fechados do trimestre, contando  º±±
±±º          ³a partir da data de competencia inicial.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPER690                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PerCompTri(cFilAux, aPerAberto, aPerFechado, aPerTodos, cMes, cAno)

Local nCont
Local nAux
Local aPerAb  := {}
Local aPerFech:= {}

aPerAberto  := {}
aPerFechado := {}
aPerTodos   := {}

For nCont := 1 to 3
	fRetPerComp( cMes , cAno , cFilAux, , , @aPerAb , @aPerFech , @aPerTodos )

	//guarda o conteudo de aPerAb e aPerFech, pois a cada chamada a funcao fRetPerComp zera os arrays
	If !len(aPerAb)<1
		For nAux:=1 to len(aPerAb)
			If( Empty(aPerAb[nAux,8]) .Or. aPerAb[nAux,8] == "FOL" )
				aAdd(aPerAberto, aPerAb[nAux])
				Exit
			EndIf
		Next nAux
	Endif

	If !len(aPerFech)<1
		For nAux:= 1 to len(aPerFech)
			If( Empty(aPerFech[nAux,8]) .Or. aPerFech[nAux,8] == "FOL" )
				aAdd(aPerFechado, aPerFech[nAux])
				Exit
			EndIf
		Next nAux
	Endif

	If cMes == "12"
		cAno:= Right(StrZero((Val(cAno)+1)),4)
		cMes := "0"
	Endif
	cMes:= Right(StrZero((Val(cMes)+1)),2)
Next nCont

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fChkUpd   ³ Autor ³ Marcelo Silveira	    ³ Data ³ 07/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa se atualizacoes foram processadas no ambiente        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Impedir a execucao da rotina caso falte alguma atualizacao. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fChkUpd( cMsg )

DEFAULT cMsg := ""

	If !CpoUsado( "RCM_TPIMSS" ) .Or. !CpoUsado( "R8_RESINC" )
		cMsg := "fRhUpdMsg( 229 )" // Funcion fRhUpdMsg no compilada en el RPO
	EndIf

Return(cMsg)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ConvQry   ºAutor  ³Microsiga           º Data ³  27/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³ Convertir a expreción sql un campo informado con un listbox³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ConvQry(cExp1,cExp2)    									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1: Cadena de caracteres que retorna el listbox		  ³±±
±±³          ³ cExp2: Campo del diccionario de datos					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER690  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvQry(cLista,cCampo)
Local cTxt		:=''
Local nTamReg	:= TamSX3(cCampo)[1]
Local nCont		:=0
/*	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Genera texto para usar  para usar despues en Query             ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cLista:=AllTrim(cLista)

For nCont := 1 To Len( cLista ) Step nTamReg
	cTxt+="'"+SubStr( cLista , nCont , nTamReg )+"',"
Next
cTxt:=substr(cTxt,1,len(cTxt)-1)
Return ( cTxt )
