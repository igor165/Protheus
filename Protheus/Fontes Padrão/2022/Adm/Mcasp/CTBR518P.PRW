#INCLUDE "PROTHEUS.CH"
#INCLUDE "CTBR518P.CH"

#DEFINE 	TAM_VALOR 			20
#DEFINE 	VLDDEZ	2
#DEFINE		VLDNOBI 3
#DEFINE		VLDATEB	4
#DEFINE		VLDDESP 3

Static aValores	:= {}
Static aVldDesp := {}

/*/{Protheus.doc} CTBR518P
    DEMONSTRATIVO DAS PARCERIAS PÚBLICO-PRIVADAS
    @type  Function
    @author totvs
    @since 10/11/20
    @version 12.1.30
    @return return, return_type, return_description
    /*/
Function CTBR518P()

Local cPerg	   	:= "CTBR518P" 
Local lRet      := .T.

Private aSelFil	 	:= {}

If !Pergunte(cPerg,.T.) 
	Return .F.
Endif    

/*PERGUNTE
MV_PAR01 - Ano ?                         
MV_PAR02 - Bimestre ?                    
MV_PAR03 - Cod. Config. Livros ?         
MV_PAR04 - Moeda ?                       	
MV_PAR05 - Tipo de Saldo ?               	
MV_PAR06 - Saldos Zerados ?  
MV_PAR07 - Divide por ?            	
MV_PAR08 - Seleciona Filiais ?           
*/

// Faz a validacao das filiais
If lRet .And. mv_par08 == 1 
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		lRet := .F.
	EndIf                             
EndIf

// Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano
// Gerencial -> montagem especifica para impressao)
// faz a validação do livro
If lRet .And. !Empty( mv_par03 ) 
	If !VdSetOfBook( mv_par03 , .F. )
		lRet := .F.
	EndIf
EndIf

If lRet
 
	oReport := ReportDef() 

	oReport:PrintDialog()
	      
EndIf

Return lRet

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Esta funcao tem como objetivo definir as secoes, celulas,
totalizadores do relatorio que poderao ser configurados pelo relatorio.

@author TOTVS
@since 12/06/2020
@version 12.1.30
@return oReport - Objeto da classe TReport
/*/
//---------------------------------------------------------------------------------------
Static Function ReportDef()  
local aArea	   		:= GetArea()   
Local cReport		:= "CTBR518P"
Local cTitulo		:= STR0001 //"Demonstrativo das Parcerias Público-Privadas" 
Local cDESC			:= STR0002 //"Este programa ira imprimir o Demonstrativo das Parcerias Público-Privadas, de acordo com os parâmetros informados pelo usuário."
Local aSetOfBook	:= {}
Local aCtbMoeda		:= {}
Local cDescMoeda 	:= ""
Local cPerg	   	:= "CTBR518P" 
Local oSection1, oSection2
Local oCabec
Local oBorder

If type("aSelFil")=="U"
	Private aSelFil := {}
EndIf

Pergunte(cPerg,.F.) 

//Filtra Filiais
If mv_par08 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil()
EndIf 

If Len( aSelFil ) <= 0
	aSelFil := { cFilAnt }
EndIf

// seta o livro
aSetOfBook := CTBSetOf(mv_par03)
	
// seta a moeda
aCtbMoeda	:= CtbMoeda(MV_PAR04, aSetOfBook[9])

If Empty(aCtbMoeda[1])
	Help(" ",1,"NOMOEDA")
	Return .F.
EndIf	
        
cDescMoeda 	:= AllTrim(aCtbMoeda[3])

oReport	:= TReport():New( cReport,cTitulo,cPerg,;
	{ |oReport| Pergunte(cPerg,.F.), Iif(ReportPrint(oReport), .T., oReport:CancelPrint())}, CDESC)

oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataBase,ctitulo,,,,,oReport) } )                                        		

// Define o tamanho da fonte a ser impressa no relatorio
oReport:nFontBody := 5
oReport:SetLandScape(.T.)       //define q relatorio sera sempre em paisagem
oReport:DisableOrientation()
//somente leitura dos parametros do pergunte
oReport:ParamReadOnly()

//_________________________________________________________________________
// Criacao da secao utilizada pelo relatorio                               |
//                                                                         |
// TRSection():New                                                         |
// ExpO1 : Objeto TReport que a secao pertence                             |
// ExpC2 : Descricao da seçao                                              |
// ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   |
//         sera considerada como principal para a seção.                   |
// ExpA4 : Array com as Ordens do relatório                                |
// ExpL5 : Carrega campos do SX3 como celulas                              |
//         Default : False                                                 |
// ExpL6 : Carrega ordens do Sindex                                        |
//         Default : False                                                 |
//_________________________________________________________________________|

oSection1  := TRSection():New( oReport, STR0003, {"CT1","cArqTmp"},, .F., .F. ) //"ESPECIFIC"

TRCell():New( oSection1, "CONTA"    , , STR0004		/*Titulo*/,/*Picture*/,       50,/*lPixel*/,{||DescCtGer()}/*CodeBlock*/,"LEFT",.T.,"CENTER")  //"Impactos das Contratações de PPP"
TRCell():New( oSection1, "SLDANT"  	, , STR0005		/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||C518PVal(1)}/*CodeBlock*/,"RIGHT",,"RIGHT") //"Saldo Total em"
TRCell():New( oSection1, "NOBI"		, , STR0006		/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||C518PVal(2)}/*CodeBlock*/,"RIGHT",,"RIGHT") //"No Bimestre"
TRCell():New( oSection1, "ATEBI" 	, , STR0007		/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||C518PVal(3)}/*CodeBlock*/,"RIGHT",,"RIGHT") //"Até o Bimestre"


oSection2  := TRSection():New( oReport, STR0008, {"CT1","cArqTmp"},, .F., .F. ) //"DESPESA"

TRCell():New( oSection2, "CONTA"	, , STR0009		/*Titulo*/,/*Picture*/,       70,/*lPixel*/,{||DescCtGer()}/*CodeBlock*/,"LEFT",.T.,"CENTER")  //"Total das Despesas de PPP"
TRCell():New( oSection2, "ANO1"  	, , " "     	/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||C518PVldD(1)}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection2, "ANO2"  	, , " "		    /*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||C518PVldD(2)}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection2, "ANO3"  	, , " "			/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||C518PVldD(3)}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection2, "ANO4"  	, , " "  		/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||C518PVldD(4)}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection2, "ANO5"  	, , " "      	/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||C518PVldD(5)}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection2, "ANO6"  	, , " "      	/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||C518PVldD(6)}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection2, "ANO7"  	, , " "     	/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||C518PVldD(7)}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection2, "ANO8"  	, , " "      	/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||C518PVldD(8)}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection2, "ANO9"  	, , " "      	/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||C518PVldD(9)}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection2, "ANO10" 	, , " "       	/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||C518PVldD(10)}/*CodeBlock*/,"RIGHT",,"RIGHT")
TRCell():New( oSection2, "ANO11" 	, , " "       	/*Titulo*/,/*Picture*/,TAM_VALOR,/*lPixel*/,{||C518PVldD(11)}/*CodeBlock*/,"RIGHT",,"RIGHT")

oSection1:SetTotalInLine(.F.)        

oBorder := TRBorder():New(oReport, 5,, 0)
//Criacao da Secao Cabecalho
oCabec := TRSection():New(oReport, STR0010, {}, /*aOrdem*/)  //"Exercício"
TRCell():New(oCabec, "EXERCICIO",, "",, 120, /*lPixel*/, /*CodeBlock*/,,,,,,,,, .T.)
oCabec:oHBrdBottom := oBorder   //Remove a borda do cabecalho
oCabec:SetLinesBefore(0)

RestArea(aArea)
           
Return(oReport)

//-------------------------------------------------------------------
/*{Protheus.doc} ReportDef
Definicao do objeto do relatorio personalizavel e das secoes que 
serao utilizadas.

@author Totvs
   
@version P12
@since   24/09/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function ReportPrint( oReport )
Local oSection1      := oReport:Section("ESPECIFIC") 
Local oSection2      := oReport:Section("DESPESA")

Local cAno      := MV_PAR01 //Ano ?
Local cBimestre := MV_PAR02 //Bimestre ?

Local dDataFim  := dDataBase //Data inici Bi
Local dDataIni	:= dDataBase //Data fim Bi
Local dSLDAnoA	:= Stod(cAno + "0101") - 1 //31/12 do ano anterior
Local dPriano	:= Stod(cAno + "0101") 
Local dDespIni	:= MonthSub(Stod(cAno + "0101"),12)
Local dDespFim	:= MonthSub(Stod(cAno + "1231"),12) 
Local nPosConta	:= 0		//posiçaõ da conta no array
Local nX := 0
Local cArqTmp := ""

//Armazena Data Final
If cBimestre == "1"
	dDataIni := SToD(cAno + "0101")
    dDataFim := LastDay(SToD(cAno + "0201"))
ElseIf cBimestre == "2"
	dDataIni := SToD(cAno + "0301")
    dDataFim := LastDay(SToD(cAno + "0401"))
ElseIf cBimestre == "3"
	dDataIni := SToD(cAno + "0501")
    dDataFim := LastDay(SToD(cAno + "0601"))
ElseIf cBimestre == "4"
	dDataIni := SToD(cAno + "0701")
    dDataFim := LastDay(SToD(cAno + "0801"))
ElseIf cBimestre == "5"
	dDataIni := SToD(cAno + "0901")
    dDataFim := LastDay(SToD(cAno + "1001"))
ElseIf cBimestre == "6"
	dDataIni := SToD(cAno + "1101")
    dDataFim := LastDay(SToD(cAno + "1201"))
EndIf

//Altera nome das colunas
oSection1:Cell("SLDANT"):SetTitle (STR0011 +CRLF+ STR0012+ cValToChar(YEAR(dDespIni))) //"Saldo Total em " ## " 31 de dezembro "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao	Saldo anterior 31/12   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
C518PRODAGP(dSLDAnoA,dSLDAnoA,.F.)
dbSelectArea("cArqTmp")           
dbGoTop()
While ("cArqTmp")->( ! Eof() )
	aadd(aValores,{("cArqTmp")->CONTA,("cArqTmp")->SALDOATU,0,0})
	("cArqTmp")->( dbSkip() )
End
("cArqTmp")->( dbCloseArea() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao	Saldo no bimestre   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
C518PRODAGP(dDataIni,dDataFim,.T.)
dbSelectArea("cArqTmp")           
dbGoTop()
While ("cArqTmp")->( ! Eof() )
	nPosConta := AScan(aValores,{|x| Alltrim(x[1]) == Alltrim(("cArqTmp")->CONTA)})
	If  nPosConta > 0 
		aValores[nPosConta][VLDDEZ] := ("cArqTmp")->MOVIMENTO
	Else
		aadd(aValores,{("cArqTmp")->CONTA,("cArqTmp")->MOVIMENTO})
	EndIf
	("cArqTmp")->( dbSkip() )
End
("cArqTmp")->( dbCloseArea() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao	Saldo até bimestre   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
C518PRODAGP(dPriano,dDataFim,.T.)
dbSelectArea("cArqTmp")           
dbGoTop()
While ("cArqTmp")->( ! Eof() )
	nPosConta := AScan(aValores,{|x| Alltrim(x[1]) == Alltrim(("cArqTmp")->CONTA)})
	If  (Alltrim( ("cArqTmp")->CONTA ) < "2") .And.  nPosConta > 0 
		aValores[nPosConta][VLDATEB] := ("cArqTmp")->MOVIMENTO
	ElseIf (Alltrim( ("cArqTmp")->CONTA ) < "2")
		aadd(aValores,{("cArqTmp")->CONTA,0,0,("cArqTmp")->MOVIMENTO})
	EndIf
	("cArqTmp")->( dbSkip() )
End
//Impresão das linhas oSection1
dbSelectArea("cArqTmp")           
dbGoTop()
oSection1:Init()
While ("cArqTmp")->( ! Eof() )
	If Alltrim( ("cArqTmp")->CONTA ) == "1"
		oSection1:Cell("SLDANT"):Hide()
		oSection1:Cell("NOBI"):Hide() 
		oSection1:Cell("ATEBI"):Hide() 
	EndIf

	If	Alltrim( ("cArqTmp")->CONTA ) < "2"  //Volta a exibir as colunas 
		oSection1:PrintLine()
	EndIf

	If Alltrim( ("cArqTmp")->CONTA ) == "1" 
		oSection1:Cell("SLDANT"):Show()
		oSection1:Cell("NOBI"):Show()
		oSection1:Cell("ATEBI"):Show()
	EndIf

	("cArqTmp")->( dbSkip() )
End
oSection1:Finish()
("cArqTmp")->( dbCloseArea() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao	Saldo dos anos   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX:= 1 to 11

	If nX > 1
		dDespIni	:= MonthSum(dDespIni,12)
		dDespFim	:= MonthSum(dDespFim,12) 
	EndIf

	//Altera nome das colunas
	oSection2:Cell("ANO"+cValToChar(nX)):SetTitle (cValToChar(YEAR(dDespIni)))

	C518PRODAGP(dDespIni,dDespFim,.T.)
	dbSelectArea("cArqTmp")           
	dbGoTop()
	While ("cArqTmp")->( ! Eof() )
		If Alltrim( ("cArqTmp")->CONTA ) >= "2"  
			aadd(aVldDesp,{nX,("cArqTmp")->CONTA,("cArqTmp")->MOVIMENTO})
		EndIf
		
		("cArqTmp")->( dbSkip() )
	End

	If nX <> 11
		("cArqTmp")->( dbCloseArea() )
	EndIf
Next
//Impresão das linhas oSection2
dbSelectArea("cArqTmp")           
dbGoTop()
oSection2:Init()
While ("cArqTmp")->( ! Eof() )

	If Alltrim( ("cArqTmp")->CONTA ) == "2"
		For nX := 1 to 11
			oSection2:Cell("ANO"+cValToChar(nX)):Hide()
		Next nX
	EndIf

	If Alltrim( ("cArqTmp")->CONTA ) >= "2"  //Volta a exibir as colunas  
		oSection2:PrintLine()
	EndIf

	If Alltrim( ("cArqTmp")->CONTA ) == "2"
		For nX := 1 to 11
			oSection2:Cell("ANO"+cValToChar(nX)):Show()
		Next nX
	EndIf

	("cArqTmp")->( dbSkip() )
End
oSection2:Finish()

//fecha alias da ctgerplan
("cArqTmp")->( dbCloseArea() )

//Limpa variaveis staticas
aValores := {}
aVldDesp := {}

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} DescCtGer
Conta e descrição da conta gerencial

@author Totvs
@version P12
@since  11/11/2020
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function DescCtGer()
Local cDescConta := ""

cDescConta += Alltrim(("cArqTmp")->CONTA)+"-"+Alltrim(("cArqTmp")->DESCCTA)

Return( cDescConta )


//-------------------------------------------------------------------
/*{Protheus.doc} C518PVal
Função para retornar o valor correto em cada coluna

@author Totvs
@version P12
@since  11/11/2020
@return  nRet - valor a ser impresso 
@obs	 
*/
//-------------------------------------------------------------------
Static Function C518PVal(nCol)
Local nRet := 0
Local nPos := 0

nPos := AScan(aValores,{|x| Alltrim(x[1]) == Alltrim(("cArqTmp")->CONTA)})

If nPos > 0 .And. nCol == 1
	nRet := aValores[nPos][VLDDEZ]
ElseIf nPos > 0 .And. nCol == 2
	nRet := aValores[nPos][VLDNOBI]
ElseIf nPos > 0 .And. nCol == 3
	nRet := aValores[nPos][VLDATEB]
EndIf
Return nRet


//-------------------------------------------------------------------
/*{Protheus.doc} C518PRODAGP
Função para chamar ctgerplam e criar arquivo temporario

@author Totvs
@version P12
@since  11/11/2020
@return  nRet - valor a ser impresso 
@obs	 
*/
//-------------------------------------------------------------------
Static Function C518PRODAGP(dDataIni,dDataFim,lMovPeriodo)
Local cLivro    := MV_PAR03 //Cod. Config. Livros ?
Local cMoeda    := MV_PAR04 //Moeda ?	
Local cTpSaldo  := MV_PAR05 //Tipo de Saldo ?
Local lSldZ     := Iif(MV_PAR06==1,.T.,.F.) //Saldos Zerados ?
Local nDvPor	:= MV_PAR07
Local nDivide	:= 0

Local cArqTmp := ""
// seta o livro
Local aSetOfBook := CTBSetOf( cLivro )


Default dDataIni	:= dDataBase
Default dDataFim	:= dDataBase
Default lMovPeriodo	:= .F.

//Divide Por
If nDvPor == 2			// Divide por cem
	nDivide := 100
ElseIf nDvPor == 3		// Divide por mil
	nDivide := 1000
ElseIf nDvPor == 4		// Divide por milhao
	nDivide := 1000000
EndIf	
aSetOfBook[9] := nDivide  //tem que passar para posicao 9 do aSetOfBook - senao não funciona nDivide CTGERPLAN / CTGERCOMP


MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(	oMeter, oText, oDlg, @lEnd, @cArqTmp, dDataIni, dDataFim;
					  , "", "", "", Repl( "Z", Len( CT1->CT1_CONTA )), ""; 
					  , Repl( "Z", Len(CTT->CTT_CUSTO)), "", Repl("Z", Len(CTD->CTD_ITEM));
					  , "", Repl("Z", Len(CTH->CTH_CLVL)), cMoeda, cTpSaldo, aSetOfBook, Space(2);
					  , Space(20), Repl("Z", 20), Space(30),,,,, .F./*lPosAntLP*/, CTOD("  /  /  ")/*dDataLP*/;
					  ,nDivide,lSldZ,,,,,,,,,,,,,,,,,,,,,,,,,cMoeda,lMovPeriodo,/*aSelFil*/,,.T.,.F./*lConsSaldo*/,,,,,,,,,,,)};
			,STR0013, STR0001) //"Criando Arquivo Tempor rio..."##"Demonstrativo das Parcerias Público-Privadas" 

Return

//-------------------------------------------------------------------
/*{Protheus.doc} C518PVldD
Função para retornar os valores de impresão para as despesas por ano

@author Totvs
@version P12
@since  11/11/2020
@return  nRet - valor a ser impresso 
@obs	 
*/
//-------------------------------------------------------------------
 Static Function C518PVldD(nCol)
 Local nRet := 0
 Local nPos	:= 0

 Default nCol := 0

nPos := AScanX(aVldDesp,{|x,y| x[1] == nCol .And. Alltrim(x[2]) == Alltrim(("cArqTmp")->CONTA)})

nRet := aVldDesp[nPos][VLDDESP]

Return nRet