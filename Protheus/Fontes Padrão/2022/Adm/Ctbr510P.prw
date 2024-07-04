#INCLUDE "CTBR510P.CH"
#INCLUDE "PROTHEUS.CH"


Static _aNotaExplic := {}
Static _cCodVisao 	:= ""
Static _dRefIni   := ""
Static _dRefFim   := ""

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±
±±³Fun‡…o	 ³ Ctbr510P	³ Autor ³ Wagner Mobile Costa	 ³ Data ³ 15.10.01 ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±
±±³Descri‡…o ³ Demonstracao de Resultados                 			  	   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Retorno	 ³ Nenhum       											   ³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±
±±³Parametros³ Nenhum													   ³±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbR510P()          

Private dFinalA
Private dFinal
Private nomeprog	:= "CTBR510P"    
Private dPeriodo0
Private cRetSX5SL 	:= ""
Private aSelFil	 	:= {}
 
CTBR510PR4()

//Limpa os arquivos temporários 
CTBGerClean()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CTBR510PR4 ³ Autor³ Daniel Sakavicius		³ Data ³ 17/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Demostrativo de balancos patrimoniais - R4		          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CTBR115R4												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                    				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBR510PR4()                           

PRIVATE CPERG	   	:= "CTR510P"        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            

Pergunte( CPERG, .T. )

// faz a validação do livro
if ! VdSetOfBook( mv_par02 , .T. )
   return .F.
endif

oReport := ReportDef()      

If VALTYPE( oReport ) == "O"
	oReport :PrintDialog()      
EndIf

oReport := nil

Return                                

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Daniel Sakavicius		³ Data ³ 17/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Esta funcao tem como objetivo definir as secoes, celulas,   ³±±
±±³          ³totalizadores do relatorio que poderao ser configurados     ³±±
±±³          ³pelo relatorio.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                    				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß    
/*/          
Static Function ReportDef()     

Local aSetOfBook	:= CTBSetOf(mv_par02)
Local aCtbMoeda		:= {}
Local cDescMoeda 	:= ""
local aArea	   		:= GetArea()   
Local CREPORT		:= "CTBR510P"
Local CTITULO		:= OemToAnsi(STR0001)				// DEMONSTRACAO DE RESULTADOS
Local CDESC			:= OemToAnsi(STR0014) + ; 			//"Este programa irá imprimir a Demonstração de Resultados, "
	   					OemToAnsi(STR0015) 				//"de acordo com os parâmetros informados pelo usuário."

Local aTamContaG   	:= TAMSX3("CTS_CONTAG")
Local aTamDesc		:= TAMSX3("CTS_DESCCG")
Local aTamVal		:= TAMSX3("CT2_VALOR")                       
Local aTamCompl     := TAMSX3("CTS_DETHCG")
                 
aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
cDescMoeda 	:= AllTrim(aCtbMoeda[3])

If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif


//Filtra Filiais
If mv_par19 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil()
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)				  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ct040Valid(mv_par02)
	Return
EndIf	
             
lMovPeriodo	:= (mv_par13 == 1)

If mv_par09 == 1												/// SE DEVE CONSIDERAR TODO O CALENDARIO
	CTG->(DbSeek(xFilial() + mv_par01))
	
	If Empty(mv_par08)
		While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
			dFinal	:= CTG->CTG_DTFIM
			CTG->(DbSkip())
		EndDo
	Else
		dFinal	:= mv_par08
	EndIf
	
	//Data do periodo anterior
	If !Empty(MV_PAR20)
		If CTG->(DbSeek(xFilial() + mv_par01))
			dFinalA		:= MV_PAR20
		EndIf         
	Else	
		dFinalA   	:= Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 1, 4))
		If Empty ( dFinalA )
			If MONTH(dFinal) == 2
				If Day(dFinal) > 28 .and. Day(dFinal) == 29
					dFinalA := Ctod(Left( STRTRAN ( Dtoc(dFinal) , "29" , "28" ), 6) + Str(Year(dFinal) - 1, 4))
				EndIf
			EndIf
		EndIf	
	EndIf
	
	mv_par01    := dFinal
	If lMovPeriodo
		dPeriodo0 	:= Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 2, 4)) + 1
	EndIf
Else															/// SE DEVE CONSIDERAR O PERIODO CONTABIL
	If Empty(mv_par08)
		MsgInfo(STR0008,STR0009)//"É necessário informar a data de referência !"#"Parametro Considera igual a Periodo."
		Return
	Endif
    
	dFinal		:= mv_par08
	dFinalA		:= CTOD("  /  /  ")
	dbSelectArea("CTG")
	dbSetOrder(1)

	//Data do periodo anterior
	If !Empty(MV_PAR20)
		If MsSeek(xFilial("CTG")+mv_par01)
			dFinalA		:= MV_PAR20
		EndIf         
	Else	
		MsSeek(xFilial("CTG")+mv_par01,.T.)
		While CTG->CTG_FILIAL == xFilial("CTG") .And. CTG->CTG_CALEND == mv_par01
			//dFinalA		:= CTG->CTG_DTINI		
			If dFinal >= CTG->CTG_DTINI .and. dFinal <= CTG->CTG_DTFIM
				dFinalA		:= CTG->CTG_DTINI	
				If lMovPeriodo
					nMes			:= Month(dFinalA)
					nAno			:= Year(dFinalA)
					dPeriodo0	:= CtoD(	StrZero(Day(dFinalA),2)							+ "/" +;
												StrZero( If(nMes==1,12		,nMes-1	),2 )	+ "/" +;
												StrZero( If(nMes==1,nAno-1,nAno		),4 ) )
					dFinalA		:= dFinalA - 1
				EndIf
				Exit
			Endif
			CTG->(DbSkip())
		EndDo
	EndIf
    
	If Empty(dFinalA)
		MsgInfo(STR0010,STR0011)//"Data fora do calendário !"#"Data de referência."
		Return
	Endif
Endif

CTITULO		:= If(! Empty(aSetOfBook[10]), aSetOfBook[10], CTITULO)		// Titulo definido SetOfBook
If Valtype(mv_par16)=="N" .And. (mv_par16 == 1)
	cTitulo := CTBNomeVis( aSetOfBook[5] )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport	:= TReport():New( CREPORT,CTITULO,CPERG, { |oReport| ReportPrint( oReport ) }, CDESC ) 
oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataBase,ctitulo,,,,,oReport,,,,,,,,,,mv_par08) } )                                        
oReport:ParamReadOnly()

IF GETNEWPAR("MV_CTBPOFF",.T.)
	oReport:SetEdit(.F.)
ENDIF	

oReport:nFontBody := 6
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ           
	
oSection1  := TRSection():New( oReport, STR0012, {"cArqTmp"},, .F., .F. )        //"Contas/Saldos"

TRCell():New( oSection1, "CONTAG"	,"","Cod.Conta"	/*Titulo*/,/*Picture*/,aTamContaG[1]	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,,,,,,.T.)

TRCell():New( oSection1, "NE"	,"",	STR0025	/*Titulo*/,/*Picture*/,6	/*Tamanho*/,/*lPixel*/,{||CodeNota()}/*CodeBlock*/,"LEFT",.T.,"CENTER")	//"NE"
TRCell():New( oSection1, "ATIVO"	,"",STR0013+cDescMoeda+")"	/*Titulo*/,/*Picture*/,aTamDesc[1]+10	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,,.T.,,,,.T.)	//"(Em "
TRCell():New( oSection1, "SALDOATU"	,"",						/*Titulo*/,/*Picture*/,aTamVal[1]+5	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"CENTER",,,.T.)
TRCell():New( oSection1, "SALDOANT"	,"",						/*Titulo*/,/*Picture*/,aTamVal[1]+5   /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"CENTER",,,.T.)

	
//Criacao da Secao Nota Explicativa
oNotExplic := TRSection():New(oReport, STR0011, {}, /*aOrdem*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ , /*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<lHeaderPage>*/ , /*<lHeaderBreak>*/ , /*<lPageBreak>*/ , /*<lLineBreak>*/ , /*<nLeftMargin>*/ , .T./*<lLineStyle>*/ , /*<nColSpace>*/ , /*<lAutoSize>*/ , /*<cCharSeparator>*/ , 0 /*<nLinesBefore>*/ , 1/*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore>*/ , /*<nPercentage>*/ ) //"Nota Explicativa"
TRCell():New(oNotExplic, "CODNOT"		,, STR0026	,,  10, /*lPixel*/, {|| Code_NE() }/*CodeBlock*/,,,,,,,,, .T.)  //"Código NE"
TRCell():New(oNotExplic, "DATNOT"		,, STR0027	,,  10, /*lPixel*/, {|| Data_NE() }/*CodeBlock*/,,,,,,,,,)  //"Data NE"
TRCell():New(oNotExplic, "OBSNOT"		,, STR0028	,, 140, /*lPixel*/, {|| Observ_NE() }/*CodeBlock*/,"LEFT",.T.,"CENTER",,,,,,)  //"Observ.NE"


oSection1:SetTotalInLine(.F.) 

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³ Daniel Sakavicius	³ Data ³ 17/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime o relatorio definido pelo usuario de acordo com as  ³±±
±±³          ³secoes/celulas criadas na funcao ReportDef definida acima.  ³±±
±±³          ³Nesta funcao deve ser criada a query das secoes se SQL ou   ³±±
±±³          ³definido o relacionamento e filtros das tabelas em CodeBase.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportPrint(oReport)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³EXPO1: Objeto do relatório                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint( oReport )  

Local oSection1 	:= oReport:Section(1) 
Local oNotExplic    := oReport:Section(2)
Local aSetOfBook	:= CTBSetOf(mv_par02)
Local aCtbMoeda	:= {}
Local lin 			:= 3001
Local cArqTmp
Local cTpValor		:= GetMV("MV_TPVALOR")
Local cPicture
Local cDescMoeda
Local lFirstPage	:= .T.               
Local nTraco		:= 0
Local nSaldo
Local nTamLin		:= 2350
Local aPosCol		:= { 1740, 2045 }
Local nPosCol		:= 0
Local lImpTrmAux	:= Iif(mv_par10 == 1,.T.,.F.)
Local cArqTrm		:= ""
Local lImp2TrAux	:= Iif(mv_par21 == 1,.T.,.F.)
Local cArq2Trm		:= ""
Local lVlrZerado	:= Iif(mv_par12==1,.T.,.F.)
Local lMovPeriodo
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local cMoedaDesc	:= iif( empty( mv_par14 ) , mv_par03 , mv_par14 )
Local lPeriodoAnt 	:= (mv_par06 == 1)
Local cSaldos     	:= CT510PTRTSL() 
Local lAutomato   := FWIsInCallStack("UTSTARTRPT") .And. cPerg == "CTR510P"
Local nAumentativa := 0
Local nDiminutiva := 0
Local nAumentAnt := 0
Local nDiminutAnt := 0
Local lIniciaRel := .T.
Local bSepTitle := {|lSaltPag| 	oReport:FatLine(), ;
								If(lSaltPag,oReport:EndPage(),NIL),;
								oReport:SkipLine() ;
					}
Local nCont	:= 0
Local nTAument	 := 0
Local lQuadroPag := .F.
Local nHandle	 := 0
Local lRet       := .T.

If lImpTrmAux
	If Empty(mv_par11)
		MsgAlert(STR0029) //"O Arquivo de termo não informado. Verifique! "
		lRet := .F.
	EndIf
	If lRet .And. (nHandle:= FOpen( mv_par11,3)) < 0
		MsgAlert(STR0030) //"O Arquivo de termo (.TRM) não pode estar como somente leitura."
		lRet := .F.
	ElseIf lRet
		FClose(nHandle)
	EndIf
EndIf

If lImp2TrAux
	If Empty(mv_par22)
		MsgAlert(STR0031) //"O Arquivo de termo-2 não informado. Verifique! "
		lRet := .F.
	EndIf
	If lRet .And. (nHandle:= FOpen( mv_par22,3)) < 0
		MsgAlert(STR0032) //"O Arquivo de termo-2 (.TRM) não pode estar como somente leitura."
		lRet := .F.
	ElseIf lRet
		FClose(nHandle)
	EndIf
EndIf

If !lRet  //caso termo nao seja encontrado ou esteja com atributo somente leitura retorna 
    Return
Endif

If Valtype(MV_PAR23) == "N" .And. MV_PAR23 == 1
	lQuadroPag := .T.
EndIf

aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

cDescMoeda 	:= AllTrim(aCtbMoeda[3])
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)
cPicture 	:= aSetOfBook[4]
//variaveis static utilizadas na busca da nota explicativa
_cCodVisao := aSetOfBook[5]
_dRefIni   := STOD(cvaltochar(Year(dFinal))+"0101")
_dRefFim   := dFinal

If ! Empty(cPicture) .And. Len(Trans(0, cPicture)) > 17
	cPicture := ""
Endif

lMovPeriodo	:= (mv_par13 == 1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(	oMeter, oText, oDlg, @lEnd, @cArqTmp, dFinalA+1, dFinal;
					  , "", "", "", Repl( "Z", Len( CT1->CT1_CONTA )), ""; 
					  , Repl( "Z", Len(CTT->CTT_CUSTO)), "", Repl("Z", Len(CTD->CTD_ITEM));
					  , "", Repl("Z", Len(CTH->CTH_CLVL)), mv_par03, /*MV_PAR15*/cSaldos, aSetOfBook, Space(2);
					  , Space(20), Repl("Z", 20), Space(30),,,,, mv_par04=1, mv_par05;
					  , ,lVlrZerado,,,,,,,,,,,,,,,,,,,,,,,,,cMoedaDesc,lMovPeriodo,aSelFil,,.T.,MV_PAR17==1,,,,,,,,,,!Empty(MV_PAR20),dFinalA)};
			,STR0006, STR0001) //"Criando Arquivo Temporario..."

dbSelectArea("cArqTmp")           
dbGoTop()

oReport:SetPageNumber(mv_par07) //mv_par07 - Pagina Inicial

oSection1:Cell("CONTAG"   ):lHeaderSize := .F.
oSection1:Cell("ATIVO"   ):lHeaderSize := .F.
oSection1:Cell("SALDOANT"):lHeaderSize := .F.
oSection1:Cell("SALDOATU"):lHeaderSize := .F.

oSection1:Init()
While ! Eof()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³indica se a entidade gerencial sera impressa/visualizada em ³
	//³um relatorio ou consulta apos o processamento da visao      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cArqTmp->VISENT == "2"
		cArqTmp->( DbSkip() )
		Loop
	EndIf

    //Imprime cabeçalho saldo atual e anterior
	oSection1:Cell("SALDOATU"     ):SetTitle(Dtoc(dFinal)) 
	If lPeriodoAnt
		oSection1:Cell("SALDOANT" ):SetTitle(Dtoc(dFinalA))
	Else
		oSection1:Cell("SALDOANT" ):Disable()
	EndIf


	If Alltrim(cArqTmp->CONTA) == "6.3" .OR. Alltrim(cArqTmp->CONTA) == "6.2"  //tratamento Incorp./Desincorp. ativo
		If Alltrim(cArqTmp->CONTA) == "6.2"
			Eval(bSepTitle,.F.)
		EndIf
		oSection1:Cell("CONTAG"):Hide()
	EndIf

	If lIniciaRel
		oSection1:Cell("CONTAG"   ):Hide()
		oSection1:Cell("SALDOANT"):Hide()
		oSection1:Cell("SALDOATU"):Hide()

		oSection1:Cell("ATIVO"):SetBlock( { || STR0021 } )	//"VARIACOES PATRIMONIAIS QUANTITATIVAS"
		Eval(bSepTitle,.F.)
		//imprime a linha de titulo do relatorio
		oSection1:PrintLine()
		Eval(bSepTitle,.F.)
		
		oSection1:Cell("ATIVO"):SetBlock( { || STR0022 } )	// "VARIACOES PATRIMONIAIS AUMENTATIVAS" 
		Eval(bSepTitle,.F.)
		//imprime a linha de titulo do relatorio
		oSection1:PrintLine()
		Eval(bSepTitle,.F.)
		
		oSection1:Cell("CONTAG"   ):Show()
		oSection1:Cell("SALDOANT"):Show()
		oSection1:Cell("SALDOATU"):Show()
	
		lIniciaRel := .F.
		Loop //apos impressao dos titulos voltar e imprimir relatorio normal
		
	ElseIf "QUALITATIVA" $ UPPER( cArqTmp->DESCCTA )
		oSection1:Cell("CONTAG"   ):Hide()
		oSection1:Cell("SALDOANT"):Hide()
		oSection1:Cell("SALDOATU"):Hide()
		
	EndIf


	oSection1:Cell("CONTAG"):SetBlock( { || cArqTmp->CONTA } )		
	oSection1:Cell("ATIVO"):SetBlock( { || Iif(cArqTmp->COLUNA<2,Iif(cArqTmp->TIPOCONTA=="2",cArqTmp->DESCCTA,cArqTmp->DESCCTA),AllTrim(cArqTmp->DESCCTA)+AllTrim(Posicione("CTS",1,xFilial("CTS")+aSetOfBook[5]+cArqTmp->ORDEM,"CTS_DETHCG")))} )		

  	//Imprime Saldo para as contas diferentes de Linha sem Valor
  	If cArqTmp->IDENTIFI < "5"
		oSection1:Cell("SALDOATU"     ):SetBlock( { || ValorCTB( If(lMovPeriodo,cArqTmp->(SALDOATU-SALDOANT),cArqTmp->SALDOATU),,,aTamVal[1],nDecimais,.T.,cPicture,;
    	                                                 cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F. ) } )

		If lPeriodoAnt
			oSection1:Cell("SALDOANT" ):SetBlock( { || ValorCTB( If(lMovPeriodo,cArqTmp->MOVPERANT,cArqTmp->SALDOANT),,,aTamVal[1],nDecimais,.T.,cPicture,;
														 cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F. ) } )
		EndIf
	//Somente para Linha Sem Valor
	ElseIf cArqTmp->IDENTIFI == "5"
		oSection1:Cell("SALDOATU"     ):SetBlock( { || " " } )

		If lPeriodoAnt
			oSection1:Cell("SALDOANT" ):SetBlock( { || " " } )
		EndIf	
	EndIf

	
    //imprime a linha de detalhe do relatorio
	oSection1:PrintLine()
	
	If Alltrim(cArqTmp->CONTA) == "6.3" .OR. Alltrim(cArqTmp->CONTA) == "6.2"
		Eval(bSepTitle,.F.)
		oSection1:Cell("CONTAG"):Show()
	
	EndIf

	If cArqTmp->NIVEL1  //somente para fechar totalizador
		
		If "AUMENTATIV" $ UPPER( cArqTmp->DESCCTA )
			Eval(bSepTitle,lQuadroPag)
			oSection1:Cell("CONTAG"   ):Hide()
			oSection1:Cell("SALDOANT"):Hide()
			oSection1:Cell("SALDOATU"):Hide()

			oSection1:Cell("ATIVO"):SetBlock( { || STR0023 } )	//"VARIACÕES PATRIMONIAIS DIMINUTIVAS"
			Eval(bSepTitle,.F.)
			//imprime a linha de titulo do relatorio
			oSection1:PrintLine()
			Eval(bSepTitle,.F.)

			oSection1:Cell("CONTAG"   ):Show()
			oSection1:Cell("SALDOANT"):Show()
			oSection1:Cell("SALDOATU"):Show()

		ElseIf "DIMINUTIVA" $ UPPER( cArqTmp->DESCCTA )
			Eval(bSepTitle,.F.)
			
			oSection1:Cell("CONTAG"):Hide()	
			oSection1:Cell("ATIVO"):SetBlock( { || STR0024 } )		//"RESULTADO DO EXERCICIO              ----------------------->"

			//Imprime Saldo para as contas diferentes de Linha sem Valor
			If cArqTmp->IDENTIFI < "5"
				oSection1:Cell("SALDOATU"     ):SetBlock( { || ValorCTB( nAumentativa-ABS(nDiminutiva),,,aTamVal[1],nDecimais,.T.,cPicture,;
																cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F. ) } )

				If lPeriodoAnt
					oSection1:Cell("SALDOANT" ):SetBlock( { || ValorCTB( nAumentAnt-ABS(nDiminutAnt),,,aTamVal[1],nDecimais,.T.,cPicture,;
																cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F. ) } )
				EndIf
			EndIf

			oSection1:PrintLine()

			Eval(bSepTitle,lQuadroPag)
	

		ElseIf "QUALITATIVA" $ UPPER( cArqTmp->DESCCTA )
			oSection1:Cell("CONTAG"   ):Show()
			oSection1:Cell("SALDOANT"):Show()
			oSection1:Cell("SALDOATU"):Show()

		EndIf

	EndIF

	dbSkip()

	If cArqTmp->NIVEL1 
		Eval(bSepTitle,.F.)
		
		If "AUMENTATIV" $ UPPER( cArqTmp->DESCCTA )
			nAumentativa := If(lMovPeriodo,cArqTmp->(SALDOATU-SALDOANT),cArqTmp->SALDOATU)
			If lPeriodoAnt
				nAumentAnt := If(lMovPeriodo,cArqTmp->MOVPERANT,cArqTmp->SALDOANT)
			EndIf
		
		ElseIf "DIMINUTIVA" $ UPPER( cArqTmp->DESCCTA )
			nDiminutiva := If(lMovPeriodo,cArqTmp->(SALDOATU-SALDOANT),cArqTmp->SALDOATU)
			If lPeriodoAnt
				nDiminutAnt := If(lMovPeriodo,cArqTmp->MOVPERANT,cArqTmp->SALDOANT)
			EndIf

		EndIf
	EndIF

EndDo             

Eval(bSepTitle,.F.)
  
oSection1:Finish()


If Len(_aNotaExplic) > 0
	oReport:EndPage()
	oReport:ThinLine()
	oReport:PrintText("** NOTAS EXPLICATIVAS **")
	oReport:ThinLine()

	oNotExplic:Init()
	For nCont := 1 TO Len(_aNotaExplic)
		QLQ->( dbGoto( _aNotaExplic[nCont] ) )
		oNotExplic:PrintLine()
	Next
	oNotExplic:Finish()
EndIf

If !lAutomato

	If lImpTrmAux
		cArqTRM 	:= mv_par11
	    aVariaveis  := {}
		
	    // Buscando os parâmetros do relatorio (a partir do SX1) para serem impressaos do Termo (arquivos *.TRM)
		SX1->( dbSeek("CTR510P"+"01") )
		SX1->( dbSeek( padr( "CTR510P" , Len( X1_GRUPO ) , ' ' ) + "01" ) )
		While SX1->X1_GRUPO == padr( "CTR510P" , Len( SX1->X1_GRUPO ) , ' ' )
			AADD(aVariaveis,{Rtrim(Upper(SX1->X1_VAR01)),&(SX1->X1_VAR01)})
			SX1->( dbSkip() )
		End
	
		If !File(cArqTRM)
			aSavSet:=__SetSets()
			cArqTRM := CFGX024(cArqTRM,STR0007) // "Responsáveis..."
			__SetSets(aSavSet)
			Set(24,Set(24),.t.)
		Endif
	
		If cArqTRM#NIL
			ImpTerm2(cArqTRM,aVariaveis,,,,oReport)
		Endif	 
	
	Endif

	//segundo termo para notas explicativas DVP
	If lImp2TrAux
		cArq2TRM 	:= mv_par22
	    aVariaveis  := {}
		
	    // Buscando os parâmetros do relatorio (a partir do SX1) para serem impressaos do Termo (arquivos *.TRM)
		SX1->( dbSeek("CTR510P"+"01") )
		SX1->( dbSeek( padr( "CTR510P" , Len( X1_GRUPO ) , ' ' ) + "01" ) )
		While SX1->X1_GRUPO == padr( "CTR510P" , Len( SX1->X1_GRUPO ) , ' ' )
			AADD(aVariaveis,{Rtrim(Upper(SX1->X1_VAR01)),&(SX1->X1_VAR01)})
			SX1->( dbSkip() )
		End
	
		If !File(cArq2TRM)
			aSavSet:=__SetSets()
			cArq2TRM := CFGX024(cArq2TRM,STR0007) // "Responsáveis..."
			__SetSets(aSavSet)
			Set(24,Set(24),.t.)
		Endif
	
		If cArq2TRM#NIL
			ImpTerm2(cArq2TRM,aVariaveis,,,,oReport)
		Endif	 
	
	Endif

EndIf

DbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
 
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	

//Atribui valores default para variaveis static
_aNotaExplic   := {}
_cCodVisao		:= ""

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ fTrataSlds³ Autor ³Elton da Cunha Santana       ³ 13.10.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tratamento do retorno do parametro                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CT510PTRTSL                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CT510PTRTSL()

Local cRet := ""

If MV_PAR17 == 1
	cRet := MV_PAR18
Else
	cRet := MV_PAR15
EndIf

Return(cRet)

//-------------------------------------------------------------------
/*{Protheus.doc} Code_NE()
Retorna o codigo da nota explicativa - tabela QLQ

@author Totvs
   
@version P12
@since   26/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function CodeNota()
Local cContaGer := ""
Local cCodeNota := ""
Local nRegQLQ := 0


//tem que estar posicionado na tabela de saida da visao gerencial
cContaGer := ("cArqTmp")->CONTA

//busca pela codigo da conta gerencial por query
//indice 1 -> QLQ_FILIAL+QLQ_CODPLA+QLQ_CODIGO+QLQ_CONTAG
//indice 2 -> QLQ_FILIAL+QLQ_CODPLA+QLQ_CONTAG+DTOS(QLQ_DATA)
QLQ->( dbSetOrder(2) )

//primeiro busca na data
If QLQ->( dbSeek( xFilial("QLQ")+_cCodVisao+cContaGer+DtoS(_dRefFim) ) )
	cCodeNota := QLQ->QLQ_CODIGO
	If AScan(_aNotaExplic,QLQ->( Recno() )) == 0
		aAdd( _aNotaExplic, QLQ->( Recno() ) )
	EndIf

ElseIf QLQ->( dbSeek( xFilial("QLQ")+_cCodVisao+cContaGer) )
	
	//laco para percorrer todas as notas explicativas para visao / conta gerencial
	While QLQ->( ! Eof() .And. QLQ_FILIAL+QLQ_CODPLA+QLQ_CONTAG == xFilial("QLQ")+_cCodVisao+cContaGer )

		If QLQ->QLQ_DATA >= _dRefIni .And. QLQ->QLQ_DATA <= _dRefFim
			cCodeNota := QLQ->QLQ_CODIGO
			nRegQLQ   := QLQ->( Recno() )
		EndIf

		QLQ->( dbSkip() )

	EndDo

	If ! Empty( cCodeNota )  //carrega o Recno no array
		aAdd( _aNotaExplic,  nRegQLQ )
	EndIf

EndIf

Return( cCodeNota )

//-------------------------------------------------------------------
/*{Protheus.doc} Code_NE()
Retorna o codigo da nota explicativa - tabela QLQ

@author Totvs
   
@version P12
@since   26/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function Code_NE()
Return( QLQ->QLQ_CODIGO )

//-------------------------------------------------------------------
/*{Protheus.doc} Data_NE()
Retorna a data da nota explicativa - tabela QLQ

@author Totvs
   
@version P12
@since   26/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function Data_NE()
Return( DtoC( QLQ->QLQ_DATA ) )

//-------------------------------------------------------------------
/*{Protheus.doc} Observ_NE()
Retorna as observações da nota explicativa - tabela QLQ

@author Totvs
   
@version P12
@since   26/10/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function Observ_NE()
Return( QLQ->QLQ_DESCNE )
