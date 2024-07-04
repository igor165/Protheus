#INCLUDE "CTBR530.CH"
#INCLUDE "PROTHEUS.CH"

//Tradução PTG 20080721

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Ctbr530	³ Autor ³ Wagner Mobile Costa	³ Data ³ 15.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Demonstracao das mutacoes do patrimonio liquido     	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbR530()         

PRIVATE titulo	:= STR0003 			//"Demonstracoes das mutacoes do patrimonio liquido"
Private nomeprog	:= "CTBR530"
oFont06	:= TFont():New("Courier New",06,06,,.F.,,,,.T.,.F.)
oCouNew06N	:= TFont():New("Courier New",06,06,,.T.,,,,.T.,.F.)		// Negrito
oCouNew06S	:= TFont():New("Courier New",06,06,,.F.,,,,.T.,.T.)		// SubLinhado

CTBR530R4()

//Limpa os arquivos temporários 
CTBGerClean()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CTBR530R4 ³ Autor³ Daniel Sakavicius		³ Data ³ 12/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Demonstracao das mutacoes do patrimonio liquido - R4  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CTBR530R4												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                    				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBR530R4() 
Local cPerg	  		:= "CTR530"			       

Private cPictVal 		:= PesqPict("CT2","CT2_VALOR")
Private cSayClVl		:= CtbSayApro("CTH")

/*
01 - mv_par01        -> Exercicio Contabil ?          
02 - mv_par02        -> Cod. Config. Livros ?         
03 - mv_par03        -> Moeda ?                       
04 - mv_par04        -> Folha Inicial ?               
05 - mv_par05        -> Imprime Termo Auxiliar ?      
06 - mv_par06        -> Termo Auxil. a ser impresso ? 
07 - mv_par07        -> Tipo de saldo ?               
08 - mv_par08        -> Titulo como nome da visao ?   
09 - mv_par09        -> Seleciona Filial ?            
10 - mv_par10        -> Dem. Periodo Anterior ?       
11 - mv_par11        -> Imprime Saldo Zerado ?        
12 - mv_par12        -> Descrição da Linha ?          

acrescentar 3 perguntas
13 - mv_par13        -> Cons.Periodo ? Calendario / Periodo
14 - mv_par14        -> Data Referencia 
15 - mv_par15        -> Data Periodo Anterior

caso informe periodo a data de referencia se torna obrigatorio e deve estar dentro do range do calendario


*/

If Pergunte(cPerg,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef()      
	
	If ValType( oReport ) == "O"
		If ! Empty( oReport:uParam )
			Pergunte( oReport:uParam, .F. )
		EndIf	
		
		oReport :PrintDialog()      
	Endif
	
	oReport := nil
Endif

Return                                

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Daniel Sakavicius		³ Data ³ 01/09/06 ³±±
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

Local aArea	  		:= GetArea()   
Local CREPORT		:= "CTBR530"
Local CDESC			:= STR0011+;		//"Este programa irá imprimir as Demonstrações das Mutações do " +;
							STR0012			//"Patrimônio Líquido, de acordo com os parâmetros informados pelo usuário."
Local cPerg	  		:= "CTR530"			       
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local nDecimais

Local aSetOfBook	:= CTBSetOf(mv_par02)

Titulo	:= If(! Empty(aSetOfBook[10]), aSetOfBook[10], Titulo)		// Titulo definido SetOfBook
If Valtype(mv_par08)=="N" .And. (mv_par08 == 1)
	Titulo := CTBNomeVis( aSetOfBook[5] )
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
oReport	:= TReport():New( cReport,Titulo,CPERG, { |oReport| If(!ReportPrint( oReport ),oReport:CancelPrint(),.T.) }, CDESC )
oReport:ParamReadOnly()

IF GETNEWPAR("MV_CTBPOFF",.T.)
	oReport:SetEdit(.F.)
ENDIF	                      
oReport:SetLandscape()				// Formato paisagem

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
oSection0  := TRSection():New( oReport, STR0016, {"cArqTmp"},, .F., .F. )		//"Entidade Gerencial"        

TRCell():New( oSection0, "DESC"	  , ,STR0015/*Titulo*/,/*Picture*/,38/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,,.T.,,,,.F.)		//"Descrição"
TRCell():New( oSection0, "VALOR1" , ,STR0014+"1"/*Titulo*/,/*Picture*/,aTamVal[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT") 	//"Valor "
TRCell():New( oSection0, "VALOR2" , ,STR0014+"2"/*Titulo*/,/*Picture*/,aTamVal[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT") 
TRCell():New( oSection0, "VALOR3" , ,STR0014+"3"/*Titulo*/,/*Picture*/,aTamVal[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT") 
TRCell():New( oSection0, "VALOR4" , ,STR0014+"4"/*Titulo*/,/*Picture*/,aTamVal[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT") 
TRCell():New( oSection0, "VALOR5" , ,STR0014+"5"/*Titulo*/,/*Picture*/,aTamVal[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT") 
TRCell():New( oSection0, "VALOR6" , ,STR0014+"6"/*Titulo*/,/*Picture*/,aTamVal[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT") 
TRCell():New( oSection0, "VALOR7" , ,STR0014+"7"/*Titulo*/,/*Picture*/,aTamVal[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT") 
TRCell():New( oSection0, "VALOR8" , ,STR0014+"8"/*Titulo*/,/*Picture*/,aTamVal[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT") 
TRCell():New( oSection0, "VALOR9" , ,STR0014+"9"/*Titulo*/,/*Picture*/,aTamVal[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT")      
TRCell():New( oSection0, "VALORA" , ,STR0008    /*Titulo*/,/*Picture*/,aTamVal[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"RIGHT") 	//"Total"     

oSection0:SetTotalInLine(.F.)          

/*
GESTAO - inicio */
/* Relacao das filiais selecionadas para compor o relatorio */
oSecFil := TRSection():New(oReport,"SECFIL")

TRCell():New(oSecFil,"CODFIL",,"Código",/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecFil,"EMPRESA",,"Empresa",/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecFil,"UNIDNEG",,"Unidade de negócio",/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSecFil,"NOMEFIL",,"Filial",/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)
/* GESTAO - fim
*/             

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³ Daniel Sakavicius	³ Data ³ 01/09/06 ³±±
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
Local oSection0 	:= oReport:Section(1)    
Local aSetOfBook	:= CTBSetOf(mv_par02)
Local aCtbMoeda	:= {}
Local aColunas0 	:= {}
Local aColunasA 	:= {}
Local aColunasF 	:= {}
Local aColunas	:= { }, aColunas2 := {}, aColunasT
Local aCabecalho	:= Array(9)
Local aPosCol		:= { 1610, 1830, 2045, 2260, 2475, 2690, 2905,3120,3335,3550 }
Local cArqTmp		:= ""
Local cPicture	:= ""
Local cDescMoeda	:= ""
Local cArqTrm		:= ""
Local cImpSaldo	:= ""
Local lFirstPage	:= .T.               
Local lImpTrmAux	:= Iif(mv_par05 == 1,.T.,.F.)
Local nColuna		:= 0
Local nlin 			:= 2301
Local nSubtrai		:= 25
Local nPosCol		:= 0
Local nLenPos		:= 0
Local nLenCol		:= 0   
Local nLenCab		:= 0
Local dFinal		:= Ctod("  /  /  ")
Local nContDesc 	:= 0 //Ajuste na impressao da descricao das contas
Local nTotCol       := 0
Local nContCol      := 0 
Local nColTot    	:= 0
Local lContinua 	:= .T.
Local nTamEmp		:= 0
Local nTamUnNeg	:= 0
Local nTamTit		:= 0
Local cFiLSel		:= ""
Local cTitulo		:= ""
Local oSecFil		:= oReport:Section("SECFIL") 
Local aSM0			:= {}    
Local nX  			:= 0
Local lSldAnt 	:= Iif( MV_PAR10 == 1, .T., .F. )
Local lSldZero 	:= Iif( MV_PAR11 == 1, .T., .F. )
Local lDescCtIni 	:= Iif( MV_PAR12 == 1, .T., .F. )
Local cDescEnt	:= ""
Local nMes
Local nAno
Local lMVPAR13 := .F.
Local cFindSX1 := Padr("CTR530", Len(SX1->X1_GRUPO), " ")
Local aDemJson := {}
Local lRelatorio := .T.
Local lArqJson   := .F.

Local cStr_Json := ""
Local cId := ""
Local cNivel := "" 
Local cDescricao := ""
Local cContaPai := ""
Local nValor1 := 0
Local nValor2 := 0
Local nValor3 := 0
Local nTotVal1 := 0
Local nTotVal2 := 0
Local nTotVal3 := 0
Local lIndividual := .T.
Local nDivide 		:= 1
Local cDt1		:= ""
Local cDt2		:= ""
Local cDt3		:= ""

Private aSelFil	:= {}                     

SX1->(dbSetOrder(1))
lMVPAR13 := SX1->(dbSeek(cFindSX1+"13"))

If ValType(mv_par16) == "N" .And. lMVPAR13
	nDivide := mv_par16
Endif

//para verificar por quanto sera dividido e adicionar ao o titulo da moeda.
If nDivide == 2			// Divide por cem
	nDivide := 100
ElseIf nDivide == 3		// Divide por mil
	nDivide := 1000
ElseIf nDivide == 4		// Divide por milhao
	nDivide := 1000000
EndIf

aSetOfBook[9] := nDivide

If mv_par09 == 1 .And. Len( aSelFil ) <= 0  .And. !IsBlind()
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0      
		Return .F.
	EndIf 
EndIf  

/* imprime a lista de filiais selecionadas para o relatorio */
If Len(aSelFil) > 1
	aSM0 := FWLoadSM0()
	nTamEmp := Len(FWSM0LayOut(,1))
	nTamUnNeg := Len(FWSM0LayOut(,2))
	cTitulo := oReport:Title()
	oReport:SetTitle(cTitulo + " (" + "Filiais selecionadas para o relatorio" + ")")
	nTamTit := Len(oReport:Title())
	oSecFil:Init()  
	oSecFil:Cell("CODFIL"):SetBlock({||cFilSel})
	oSecFil:Cell("EMPRESA"):SetBlock({||aSM0[nLinha,SM0_DESCEMP]})
	oSecFil:Cell("UNIDNEG"):SetBlock({||aSM0[nLinha,SM0_DESCUN]})
	oSecFil:Cell("NOMEFIL"):SetBlock({||aSM0[nLinha,SM0_NOMRED]})

	For nX := 1 To Len(aSelFil)
		nLinha := Ascan(aSM0,{|sm0|,sm0[SM0_CODFIL] == aSelFil[nX]})
		If nLinha > 0
			cFilSel := Substr(aSM0[nLinha,SM0_CODFIL],1,nTamEmp)
			cFilSel += " "
			cFilSel += Substr(aSM0[nLinha,SM0_CODFIL],nTamEmp + 1,nTamUnNeg)
			cFilSel += " "
			cFilSel += Substr(aSM0[nLinha,SM0_CODFIL],nTamEmp + nTamUnNeg + 1)
			oSecFil:PrintLine()
		Endif
	Next
	oReport:SetTitle(cTitulo)
	oSecFil:Finish()
	oReport:EndPage()
Endif
/* GESTAO - fim
*/            

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return .F.
EndIf

// faz a validação do livro
if ! VdSetOfBook( mv_par02 , .T. )
   return .F.
endif

If Empty(aSetOfBook[5])
	//"Os demonstrativos contabeis obrigatoriamente devem ter um plano gerencial associado ao livro. Verifique a configuracao de livros escolhida !"
	ApMsgAlert(	STR0010) 
	Return .F.
Endif
//variavel private para uso na funcao ctgerplan no fonte ctbxsal
lTRegCts	:= .T.		// Indica criar campo DESCORIG

If ! lMVPAR13  //Se NAO existe pergunta 13   -> Calendario ou Periodo  --> antes JSON

	CTG->(DbSeek(xFilial() + mv_par01))
	While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
		dFinal	:= CTG->CTG_DTFIM
		CTG->(DbSkip())
	EndDo

	dFinalA   	:= Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 1, 4))
	dPeriodo0 	:= Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 2, 4)) + 1
	mv_par01    := dFinal    //artificio para sair data final na pergunta do calendario 

Else

	If mv_par13 == 1												/// SE DEVE CONSIDERAR TODO O CALENDARIO
		CTG->(DbSeek(xFilial() + mv_par01))
		
		If Empty(mv_par14)
			While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
				dFinal	:= CTG->CTG_DTFIM
				CTG->(DbSkip())
			EndDo
		Else
			dFinal	:= mv_par14
		EndIf
		
		//Data do periodo anterior
		If !Empty(mv_par15)
			If CTG->(DbSeek(xFilial() + mv_par01))
				dFinalA		:= mv_par15
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
		
		dPeriodo0 	:= Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 2, 4)) + 1
		
	Else															/// SE DEVE CONSIDERAR O PERIODO CONTABIL

		If Empty(mv_par14)
			MsgInfo("É necessário informar a data de referência !","Parametro Considera igual a Periodo.") //"É necessário informar a data de referência !"#"Parametro Considera igual a Periodo."
			Return .F.
		Endif
		
		dFinal		:= mv_par14
		dFinalA		:= CTOD("  /  /  ")
		dbSelectArea("CTG")
		dbSetOrder(1)

		//Data do periodo anterior
		If !Empty(mv_par15)
			If MsSeek(xFilial("CTG")+mv_par01)
				dFinalA		:= mv_par15
				dPeriodo0	:= LastDay( MonthSub( dFinalA,Int((dFinal-dFinalA)/30) ) ) + 1
			EndIf         
		Else	
			MsSeek(xFilial("CTG")+mv_par01,.T.)
			While CTG->CTG_FILIAL == xFilial("CTG") .And. CTG->CTG_CALEND == mv_par01
					
				If dFinal >= CTG->CTG_DTINI .and. dFinal <= CTG->CTG_DTFIM

					dFinalA		:= CTG->CTG_DTINI	

						nMes			:= Month(dFinalA)
						nAno			:= Year(dFinalA)
						dPeriodo0	:= CtoD(	StrZero(Day(dFinalA),2)							+ "/" +;
													StrZero( If(nMes==1,12		,nMes-1	),2 )	+ "/" +;
													StrZero( If(nMes==1,nAno-1,nAno		),4 ) )
						dFinalA		:= dFinalA - 1

					Exit
				Endif
				CTG->(DbSkip())
			EndDo
		EndIf
		
		If Empty(dFinalA)
			MsgInfo("Data fora do calendário !","Data de referência.")//"Data fora do calendário !"#"Data de referência."
			Return .F.
		Endif
	Endif
Endif

If lSldAnt
	aColunas0 	:= { "", "", " ", 0, dPeriodo0 - 1, " ", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00 }
Endif				
aColunasA 	:= { "", "", " ", 0, dFinalA, " ", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00 }
aColunasF 	:= { "", "", " ", 0, dFinal, " ", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00 }

Afill(aCabecalho, Space(0))

aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

cDescMoeda 	:= AllTrim(aCtbMoeda[3])
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)

cPicture 	:= aSetOfBook[4]
If Empty(cPicture) .Or. Len(Trans(0, cPicture)) > 17
  	cPicture 	:= "@E 99,999,999,999.99"
Endif

If lMVPAR13
	aDemJson := CTBDEMJSON()
EndIf

oReport:SetPageNumber( mv_par04 )
oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataBase,titulo,,,,,oReport) } )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
			dFinalA+1,dFinal,"","","",Repl("Z", Len(CT1->CT1_CONTA)),;
			"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
			"",Repl("Z", Len(CTH->CTH_CLVL)),mv_par03,;
			MV_PAR07,aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30),;     
				.F.,.F.,2,,.F.,"",nDivide,,,,,,,,,,,,,,,.F.,"",.F.,;
			"","",,,,,,,"",,aSelFil)},;
			STR0007, STR0003) //"Criando Arquivo Temporario..."

#DEFINE C_CONTA			1
#DEFINE C_DESC			2
#DEFINE C_NORMAL  		3
#DEFINE C_COLUNA  		4
#DEFINE C_PERIODO 		5
#DEFINE C_IDENTIFI		6
#DEFINE C_SALDOATU		6

If lMVPAR13
	lRelatorio := Empty(aDemJson) .OR. aDemJson[1] == 1 .OR. aDemJson[1] == 3
	lArqJson   := !Empty(aDemJson) .And. ( aDemJson[1] == 2 .OR. aDemJson[1] == 3)
Else
	lRelatorio := .T.
	lArqJson   := .F.
EndIf

If lRelatorio
	dbSelectArea("cArqTmp")
	oReport:SetMeter(RecCount())
	dbGoTop()
	While !Eof()
		If COLUNA > 0
			nContCol++  // WHILE PARA CONTAGEM DAS COLUNAS DO RELATORIO DE ACORDO COM A VISAO GERENCIAL
			If nContCol > Len(aCabecalho) .OR. COLUNA > Len(aCabecalho)
				lContinua := .F.		
				Aviso(STR0017, StrTran(STR0018,"8","9"),{"Ok"})  //"Atencao"##"Este relatorio somente suporta 8 colunas. Verifique a visão gerencial."
				Exit
			EndIf	
			If COLUNA > 6  .And. oReport:GetOrientation() == 1 //PORTRAIT
				lContinua := .F.		
				Aviso(STR0017, STR0019,{"Ok"})  //"Atencao"##"Esse relatório só pode ser impresso com mais de 6 colunas em modo paisagem"                                                                                                                                                                                                                                                                                                                                                                                                                                        
				Exit
			Endif 			
			aCabecalho[nContCol] := ALLTRIM(DESCCTA) 
			//IF PARA TRATAR A CONTAGEM DAS COLUNAS VALIDAS PARA O RELATORIO.    
			IF !EMPTY(aCabecalho[nContCol])
				nColTot++
			ENDIF
		ENDIF
		DBSKIP()
	Enddo	

	If lContinua
		dbSelectArea("cArqTmp")
		oReport:SetMeter(RecCount())
		dbGoTop()
		
		While !Eof()                
			oReport:IncMeter()
			If COLUNA = 0
				nContDesc++
				
			If lSldAnt
					If nContDesc == 1
						aColunas0[C_DESC]			:= DESCCTA
					EndIf
					aColunas0[C_NORMAL]			:= NORMAL
					aColunas0[C_IDENTIFI]		:= IDENTIFI
					aColunas0[Len(aColunas0)]	:= SALDOPER
				Endif
		
				If nContDesc == 1
					aColunasA[C_DESC]			:= DESCCTA
				EndIf
				aColunasA[C_NORMAL]			:= NORMAL
				aColunasA[C_IDENTIFI]		:= IDENTIFI
				aColunasA[Len(aColunasA)]	:= SALDOANT
		
				If nContDesc == 1
					aColunasF[C_DESC]			:= DESCCTA
				EndIf
				aColunasF[C_NORMAL]			:= NORMAL
				aColunasF[C_IDENTIFI]		:= IDENTIFI
				aColunasF[Len(aColunasA)]	:= SALDOATU
			Else
				If lSldAnt
					aColunas0[C_SALDOATU + COLUNA] += SALDOPER
				Endif
				aColunasA[C_SALDOATU + COLUNA] += SALDOANT
				aColunasF[C_SALDOATU + COLUNA] += SALDOATU
				
				aCabecalho[COLUNA] := ALLTRIM(DESCCTA)
				
				//Se for descrição da conta inicial configurada
				If lDescCtIni
					cDescEnt := DESCORIG				
				Else //Se for descrição configurada no campo "Cont. Descr." na visão gerencial
					cDescEnt := DESCCONT
				Endif 
				
				If (nColuna := Ascan(aColunas, { |x| 	x[C_DESC] = cDescEnt .And. x[C_COLUNA] = COLUNA })) = 0
					Aadd(	aColunas, { 	"", cDescEnt, NORMAL, COLUNA, Ctod(""), IDENTIFI,;
											0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, MOVIMENTO })
					nColuna := Len(aColunas)
				Endif
				aColunas[nColuna,C_SALDOATU + COLUNA] += MOVIMENTO
		
				If (nColuna := Ascan(aColunas2, { |x| 	x[C_DESC] = cDescEnt .And. x[C_COLUNA] = COLUNA })) = 0
					Aadd(	aColunas2, { 	"", cDescEnt, NORMAL, COLUNA, Ctod(""), IDENTIFI,;
											0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, MOVIMPER })
					nColuna := Len(aColunas2)
				Endif			
				aColunas2[nColuna,C_SALDOATU + COLUNA] += MOVIMPER
			Endif
			DbSkip()
		EndDo	
		
		// Define o cabecalho das celulas de valor
		nLenCab	:= Len(aCabecalho)
		For nColuna := 1 To nLenCab 
			IF nColuna > nColTot .AND. ! nColuna == 10
				oSection0:Cell("VALOR"+AllTrim(Str(nColuna))):Disable()    
			Else
				oSection0:Cell("VALOR"+AllTrim(Str(nColuna))):SetTitle(StrTran(Alltrim(aCabecalho[nColuna])," ", CRLF))
			Endif	
		Next nColuna
		
		aColunasT := AClone(aColunas)
		aColunas  := {}
		
		If lSldAnt		
			// Adiciona o saldo anterior a 2 exercicios	
			If Len(aColunas0) > 0
				Aadd(aColunas, aColunas0)
			Endif
			
			// Adiciona a movimentacao anterior a 2 exercicios
			For nColuna := 1 To Len(aColunas2)		
				If lSldZero
					Aadd(aColunas, aColunas2[nColuna])
				Else
					//Só imprime se o total for maior que 0
					If aColunas2[nColuna][Len(aColunas2[nColuna])] > 0
						Aadd(aColunas, aColunas2[nColuna])
					Endif
				Endif			
			Next
		Endif
		
		// Adiciona o saldo anterior ao periodo solicitado	
		If Len(aColunasA) > 0
			Aadd(aColunas, aColunasA)
		Endif
		
		// Adiciona a movimentacao do periodo	
		For nColuna := 1 To Len(aColunasT)
			If lSldZero
				Aadd(aColunas, aColunasT[nColuna])			
			Else
				//Só imprime se o total for maior que 0
				If aColunasT[nColuna][Len(aColunasT[nColuna])] > 0
					Aadd(aColunas, aColunasT[nColuna])
				Endif
			Endif
		Next
		
		// Adiciona o saldo final do periodo	
		If Len(aColunasF) > 0
			Aadd(aColunas, aColunasF)
		Endif
														
		nLenPos	:= Len(aPosCol)
		nLenCol	:= Len(aColunas)
		
		oReport:SetMeter( Len(aColunas) )
		
		oSection0:Init()
		oReport:SkipLine()
		
		For nColuna := 1 To nLenCol
		
			nTotCol := 0
			
			oReport:IncMeter()
			
			If oReport:Cancel()
				Exit
			EndIf  
		
			oSection0:Cell("DESC"):SetTitle(STR0013 + cDescMoeda + ")") 	//"(Em " - Cabecalho da descricao
			oSection0:Cell("DESC"):SetBlock( { || AllTrim(aColunas[nColuna,C_DESC]) +;
							If(aColunas[nColuna,C_COLUNA] = 0, " em " +	Dtoc(aColunas[nColuna,C_PERIODO]), "") } )
		
			If aColunas[nColuna,C_IDENTIFI] < "5"
				For nPosCol := 1 To nLenPos
					cImpSaldo := Transform(	aColunas[nColuna,C_SALDOATU + nPosCol],cPicture)

					If nPosCol < nLenPos   //ultima coluna refere-se a saldo final e nao deve ser somada no total
						nTotCol += aColunas[nColuna,C_SALDOATU + nPosCol]
					EndIf	

					If nPosCol == nLenPos
						If nPosCol == 10
							oSection0:Cell("VALORA"):SetValue(Transform(nTotCol,cPicture))
						Else
							oSection0:Cell("VALOR"+AllTrim(Str(nPosCol))):SetValue(Transform(nTotCol,cPicture))
						EndIf
					ELSE
						oSection0:Cell("VALOR"+AllTrim(Str(nPosCol))):SetValue(cImpSaldo)
					ENDIF	
				Next
			Endif
		
			oSection0:PrintLine()
			oReport:SkipLine()		                  
							
		Next                
		
		If lImpTrmAux
			cArqTRM 	:= mv_par06
			aVariaveis	:= {}
			
			If !File(cArqTRM)
				aSavSet:=__SetSets()
				cArqTRM := CFGX024(cArqTRM,STR0009) // "Responsáveis..."
				__SetSets(aSavSet)
				Set(24,Set(24),.t.)
			Endif
		
			If cArqTRM#NIL
				ImpTerm2(cArqTRM,aVariaveis,,,,oReport)
			Endif	 
		Endif
		
		oSection0:Finish()
	EndIf  

EndIf

If lArqJson

	If DateDiffMonth(dFinalA,dFinal) == 6 		
		cDt1 := "S"+Month2Str(dFinal)+Year2Str(dFinal)
		cDt2 := "S"+Month2Str(dFinalA)+Year2Str(dFinalA)
	Else
		cDt1 := "A"+Month2Str(dFinal)+Year2Str(dFinal)
		cDt2 := "A"+Month2Str(dFinalA)+Year2Str(dFinalA)
	EndIf

	If DateDiffMonth(dPeriodo0-1,dFinalA) == 6 		
		cDt3 := "S"+Month2Str(dPeriodo0-1)+Year2Str(dPeriodo0-1)
	Else
		cDt3 := "A"+Month2Str(dPeriodo0-1)+Year2Str(dPeriodo0-1)
	EndIf
	
	Pergunte( Alltrim(cFindSX1), .F.)   //Garantir carga do pergunte antes de chamar funcao CtLstPerg()
	//geração de arquivo json no diretorio informado
	dbSelectArea("cArqTmp")
	oReport:SetMeter(RecCount())
	dbGoTop()

	cStr_Json := ""
	cStr_Json += " {"+CRLF
	//----------------------------
	cStr_Json += '  "PergunteRel": { "CTBR530": ['+CtLstPerg(Alltrim(cFindSX1))+'] }, '+CRLF
  	cStr_Json += '  "ParametrosJson": { '+CRLF
    cStr_Json += '  "PergunteJson": ['+CtLstPerg("CTBJSON", aDemJson )+'], '+CRLF
    cStr_Json += '  "DatasJson": [{"CTBR530DT1":"'+cDt1+'","CTBR530DT2":"'+cDt2+'","CTBR530DT3":"'+cDt3+'"}]'+CRLF
  	cStr_Json += '  }, '+CRLF
	//----------------------------
 	cStr_Json += ' "DemonstracaoDasMutacoesDoPatrimonioLiquido": { '+CRLF
	If !Eof()
		cStr_Json += '"contas":[ '+CRLF
	EndIf

	lIndividual := ( aDemJson[5] == 1 )

	While !Eof()

		cId := Alltrim( CONTA )
		cNivel := Alltrim( NIVJSON )
		cDescricao := Alltrim( DESCCTA )
		cContaPai := Alltrim( SUPERIOR )
		nValor1 := SALDOATU
		nValor2 := SALDOANT
		nValor3 := SALDOPER

		nTotVal1 += nValor1
		nTotVal2 += nValor2
		nTotVal3 += nValor3

		If nValor1 <> 0 .OR. nValor2 <> 0 .OR. nValor3 <> 0
			/*MODELO CONTAS JSON
				{"@id":"conta1",
				"@nivel":"1",
				"@descricao":"Capital Social",
				"@contaPai":"",
				"valoresIndividualizados":[
				{ "@dtBase":"dt1",
				"@valor":10},
				{ "@dtBase":"dt2",
				"@valor":10},
				{ "@dtBase":"dt3",
				"@valor":10}]},
			*/
			cStr_Json += '{ "@id":"'+cId+'", '+CRLF
			cStr_Json += '  "@nivel":"'+cNivel+'", '+CRLF
			cStr_Json += '  "@descricao":"'+cDescricao+'", '+CRLF
			cStr_Json += '  "@contaPai":"'+cContaPai+'", '+CRLF
			If lIndividual
				cStr_Json += '"valoresIndividualizados":['+CRLF
			Else
				cStr_Json += '"valoresConsolidados":['+CRLF
			EndIf

			If nValor1 <> 0
				cStr_Json += '{ "@dtBase":"CTBR530DT1", '
				cStr_Json += '  "@valor":'+Alltrim(Str(nValor1,16,2))+'} '
			EndIf

			If nValor2 <> 0

				If nValor1 <> 0
					cStr_Json += ', '+CRLF
				EndIf

				cStr_Json += '{ "@dtBase":"CTBR530DT2", '
				cStr_Json += '  "@valor":'+Alltrim(Str(nValor2,16,2))+'} '
			EndIf

			If nValor3 <> 0

				If nValor1 <> 0 .OR. nValor2 <> 0
					cStr_Json += ', '+CRLF
				EndIf

				cStr_Json += '{ "@dtBase":"CTBR530DT3", '
				cStr_Json += '  "@valor":'+Alltrim(Str(nValor3,16,2))+'} '+CRLF
			EndIf
			
			cStr_Json += ' ]} '+CRLF

		EndIf

		oReport:IncMeter()

		dbSkip()

		If Eof()
			//registro totalizador
			cStr_Json += ',{ "@id":"total", '+CRLF
			cStr_Json += '  "@nivel":"9", '+CRLF
			cStr_Json += '  "@descricao":"TOTAL", '+CRLF
			cStr_Json += '  "@contaPai":"", '+CRLF
			If lIndividual
				cStr_Json += '"valoresIndividualizados":['+CRLF
			Else
				cStr_Json += '"valoresConsolidados":['+CRLF
			EndIf
		
			cStr_Json += '{ "@dtBase":"CRBR530DT1", '
			cStr_Json += '  "@valor":'+Alltrim(Str(nTotVal1,16,2))+'} '

			cStr_Json += ', '+CRLF

			cStr_Json += '{ "@dtBase":"CRBR530DT2", '
			cStr_Json += '  "@valor":'+Alltrim(Str(nTotVal2,16,2))+'} '
	
			cStr_Json += ', '+CRLF

			cStr_Json += '{ "@dtBase":"CRBR530DT3", '
			cStr_Json += '  "@valor":'+Alltrim(Str(nTotVal3,16,2))+'} '+CRLF
	
			cStr_Json += ' ]} '+CRLF
			//final do registro totalizador

			cStr_Json += " ] "
		Else
			cStr_Json += ", "
		EndIf

	EndDo
	
	cStr_Json += " } "

	cStr_Json += " } "+CRLF

	MemoWrite( aDemJson[4], cStr_Json)

EndIf


Set Filter To
dbCloseArea() 
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	
dbselectArea("CT2") 

Return .T.
