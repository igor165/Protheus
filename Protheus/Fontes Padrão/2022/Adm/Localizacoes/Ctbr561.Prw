#INCLUDE "ctbr561.ch"
#Include "PROTHEUS.Ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Ctbr561	³ Autor ³ TOTVS					³ Data ³ 01.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Demonstracao das Alteracoes no Capital Proprio		  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbR561()

PRIVATE cPerg := "CTR561"  
Private aVisao := {}  

CTBR561R4()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CTBR561R4 ³ Autor³ TOTVS					³ Data ³ 01.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Demonstracao das Alteracoes no Capital Proprio - Portugal  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CTBR115R4												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                    				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBR561R4()                           
Local aSetOfBook	
Local aCtbMoeda		:= {}
Local cDescMoeda 	:= ""
Local lRet          := .T.

Private nomeprog	:= "CTBR561"       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            

If ! CtrVld561(cPerg)
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// faz a validação do livro
if ! Empty( mv_par02 ) 
	if ! VdSetOfBook( mv_par02 , .F. )
		lRet := .F.
	endif
Endif

IF lRet
	// seta o livro
	aSetOfBook := CTBSetOf(mv_par02)
	
	// seta a moeda
	aCtbMoeda	:= CtbMoeda(mv_par03, aSetOfBook[9])
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		Return .F.
	EndIf	
        
	oReport := ReportDef(aSetOfBook, aCtbMoeda, cDescMoeda)      

    If ValType(oReport) == 'O'
 	  	oReport :PrintDialog()
	Endif
	      
EndIf
Return                                

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ TOTVS					³ Data ³ 01.12.10 ³±±
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
Static Function ReportDef(aSetOfBook, aCtbMoeda, cDescMoeda)  
local aArea	   		:= GetArea()   
Local cREPORT		:= "CTBR561"
Local cTITULO		:= Capital(STR0001)		// Demonstracao das alteracoes no capital proprio
Local cDESC			:= STR0004 + STR0005
Local aTamDesc		:= TAMSX3("CTS_DESCCG")  
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local nTamAux		:= 10
Local dFinal 		:= CTOD(SPACE(8))  
Local dFinalA       := CTOD(SPACE(8))
Local lMovPeriodo 	:= mv_par12 == 1

cTitulo := If(! Empty(aSetOfBook[10]), aSetOfBook[10], cTitulo )		// Titulo definido SetOfBook  
If Valtype(mv_par15)=="N" .And. (mv_par15 == 1)
	cTitulo := CTBNomeVis( aSetOfBook[5] )
EndIf

If mv_par08 == 1
	// SE DEVE CONSIDERAR TODO O CALENDARIO
	CTG->(DbSeek(xFilial("CTG")+mv_par01))
	dbSelectArea("CTG")
	dbSetOrder(1)
	MsSeek(xFilial("CTG")+mv_par01,.T.)
	
	If Empty(mv_par07)
		While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
			dFinal	:= CTG->CTG_DTFIM
			CTG->(DbSkip())
		EndDo
	Else
		dFinal	:= mv_par07
	EndIf
	dFinalA   	:= Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 1, 4))
	mv_par01    := dFinal
Else
	// SE DEVE CONSIDERAR O PERIODO CONTABIL
	If Empty(mv_par07)
		MsgInfo( STR0011, STR0012 )//"É necessário informar a data de referência !"#"Parametro Considera igual a Periodo."
		Return .F.
	Endif
	dFinal := mv_par07
	
	CTG->(dbSetOrder(1))
	CTG->(DbSeek(xFilial("CTG")+mv_par01))
	While CTG->CTG_FILIAL == xFilial("CTG") .And. CTG->CTG_CALEND == mv_par01
		If dFinal >= CTG->CTG_DTINI .and. dFinal <= CTG->CTG_DTFIM
			dFinalA		:= CTG->CTG_DTINI
			If lMovPeriodo
				dFinalA		:= dFinalA - 1
			EndIf
			Exit
		Endif
		CTG->(DbSkip())
	EndDo
	
	If Empty(dFinalA)
		MsgInfo( STR0013, STR0014 )//"Data fora do calendário !"#"Data de referência."
		Return .F.
	Endif
EndIf

nAno := year(dFinal)

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

oReport	:= TReport():New( cReport,cTitulo,cPerg,;
	{ |oReport| Pergunte(cPerg,.F.), Iif(ReportPrint(oReport,@cTitulo,dFinal), .T., oReport:CancelPrint())}, CDESC)   
	
oReport:SetLandscape(.T.)
//oReport:ParamReadOnly()
//IF GETNEWPAR("MV_CTBPOFF",.T.)
//	oReport:SetEdit(.F.)
//ENDIF	

// Define o tamanho da fonte a ser impressa no relatorio
oReport:nFontBody := 4    

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
oSection1  := TRSection():New( oReport, STR0006, {"cArqTmp"},, .F., .F.,,,,,,,,,1,.F. )      // "Detalhe" 

TRCell():New( oSection1, "DESCCTA", , "DESCRICAO"  /*Titulo*/,/*Picture*/,90/*aTamDesc[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"LEFT",.T.,"CENTER",,,.T.,,,.T.)
TRCell():New( oSection1, "NOTAS"  , , "Notas" /*Titulo*/,/*Picture*/,5  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"LEFT",,"CENTER")
TRCell():New( oSection1, "COLUNA01"  , , "Capital"+CRLF+"Realizado" /*Titulo*/,/*Picture*/,12  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"CENTER",,,,,,.T.)
TRCell():New( oSection1, "COLUNA02"  , , "Accoes"+CRLF+"(Quotas)"+CRLF+"proprias" /*Titulo*/,/*Picture*/,12  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"CENTER",,,,,,.T.)
TRCell():New( oSection1, "COLUNA03"  , , "Prestaçoes"+CRLF+"suplemen"+CRLF+"tares"+CRLF+"e outros"+CRLF+"instrumen"+CRLF+"tos"+CRLF+"de capital"+CRLF+"proprio" /*Titulo*/,/*Picture*/,12  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"CENTER",,,,,,.T.)
TRCell():New( oSection1, "COLUNA04"  , , "Premios"+CRLF+"de"+CRLF+"emissao" /*Titulo*/,/*Picture*/,12  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"CENTER",,,,,,.T.)
TRCell():New( oSection1, "COLUNA05"  , , "Reservas"+CRLF+"legais" /*Titulo*/,/*Picture*/,12  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"CENTER",,,,,,.T.)
TRCell():New( oSection1, "COLUNA06"  , , "Outras"+CRLF+"reservas" /*Titulo*/,/*Picture*/,12  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"CENTER",,,,,,.T.)
TRCell():New( oSection1, "COLUNA07"  , , "Excedentes"+CRLF+" de "+CRLF+"revalori"+CRLF+"zacao" /*Titulo*/,/*Picture*/,12  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"CENTER",,,,,,.T.)
TRCell():New( oSection1, "COLUNA08"  , , "Ajusta"+CRLF+"mentos"+CRLF+"em"+CRLF+"activos"+CRLF+"financei"+CRLF+"ros" /*Titulo*/,/*Picture*/,12  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"CENTER",,,,,,.T.)
TRCell():New( oSection1, "COLUNA09"  , , "Outras"+CRLF+"variacoes"+CRLF+"no"+CRLF+"capital"+CRLF+"proprio" /*Titulo*/,/*Picture*/,12  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"CENTER",,,,,,.T.)
TRCell():New( oSection1, "COLUNA10"  , , "Resulta"+CRLF+"dos"+CRLF+"transita"+CRLF+"dos" /*Titulo*/,/*Picture*/,12  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"CENTER",,,,,,.T.)
TRCell():New( oSection1, "COLUNA11"  , , "Resultado"+CRLF+"liquido"+CRLF+"do"+CRLF+"periodo" /*Titulo*/,/*Picture*/,12  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"CENTER",,,,,,.T.)
TRCell():New( oSection1, "COLUNA12"  , , "Total" /*Titulo*/,/*Picture*/,9  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"CENTER",,,,,,.T.)
TRCell():New( oSection1, "COLUNA13"  , , "Interesses"+CRLF+"minorita"+CRLF+"rios" /*Titulo*/,/*Picture*/,12  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"CENTER",,,,,,.T.)
TRCell():New( oSection1, "COLUNA14"  , , "Total do"+CRLF+"capital"+CRLF+"proprio" /*Titulo*/,/*Picture*/,12  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"RIGHT",,"CENTER",,,,,,.T.)

oSection1:Cell("DESCCTA"):lHeaderSize   := .F.
oSection1:Cell("NOTAS"):lHeaderSize     := .F.
oSection1:Cell("COLUNA01"):lHeaderSize  := .F.
oSection1:Cell("COLUNA02"):lHeaderSize  := .F.
oSection1:Cell("COLUNA03"):lHeaderSize  := .F.
oSection1:Cell("COLUNA04"):lHeaderSize  := .F.
oSection1:Cell("COLUNA05"):lHeaderSize  := .F.
oSection1:Cell("COLUNA06"):lHeaderSize  := .F.
oSection1:Cell("COLUNA07"):lHeaderSize  := .F.
oSection1:Cell("COLUNA08"):lHeaderSize  := .F.
oSection1:Cell("COLUNA09"):lHeaderSize  := .F.
oSection1:Cell("COLUNA10"):lHeaderSize  := .F.
oSection1:Cell("COLUNA11"):lHeaderSize  := .F.
oSection1:Cell("COLUNA12"):lHeaderSize  := .F.
oSection1:Cell("COLUNA13"):lHeaderSize  := .F.
oSection1:Cell("COLUNA14"):lHeaderSize  := .F.

oSection1:SetTotalInLine(.F.)

oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDatabase,cTitulo,,,,,oReport) } )

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³ TOTVS				³ Data ³ 01.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime o relatorio definido pelo usuario de acordo com as  ³±±
±±³          ³secoes/celulas criadas na funcao ReportDef definida acima.  ³±±
±±³          ³Nesta funcao deve ser criada a query das secoes se SQL ou   ³±±
±±³          ³definido o relacionamento e filtros das tabelas em CodeBase.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportPrint(ExpO1,ExpC1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Obj. do relatorio	                              ³±±
±±³          ³ ExpC1 = Titulo do relatorio (sera' atualizado conf. param.)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³EXPO1: Objeto do relatorio                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint( oReport,Titulo, dFinal )  
Local oSection1 	:= oReport:Section(1)  
Local oSection2 	:= oReport:Section(2)  
Local aSetOfBook	:= CTBSetOf(mv_par02)
Local aCtbMoeda		:= {}
Local cArqTmp
Local cPicture
Local aColunas		:= { {}, {} }
Local aMaxCol		:= {	{ "", "", "", 0, 0, 0.00, 0.00, 0.00, 0 },;
							{ "", "", "", 0, 0, 0.00, 0.00, 0.00, 0 } }
Local cTpValor		:= GetMV("MV_TPVALOR")
Local lImpTrmAux	:= (mv_par09 == 1)
Local cArqTrm		:= ""    
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local cMoedaDesc	:= mv_par13 
Local lSaltaLin		:= .T.
Local aLinhas       := {} 
Local nLin			:= 2
Local lImpAntLP		:= Iif(mv_par04 == 1,.T.,.F.)
Local dDataLP		:= mv_par05
Local lMovPeriodo 	:= mv_par12 == 1 
Local nCol			:= 3
Private nX := 0
oReport:SetPageNumber( MV_PAR06 )

If  Empty(CTBSetOf(mv_par02)[5])
	ApMsgAlert(	STR0007) //"Os demonstrativos contabeis obrigatoriamente devem ter um plano gerencial associado ao livro. Verifique a configuracao de livros escolhida !"
	Return .F.
Endif

dFinalA := Ctod(Left(Dtoc(dFinal), 6) + Str(Year(dFinal) - 1, 4))

aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9]) 

If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)
cPicture 	:= aSetOfBook[4]  

lComNivel	:= .T.

m_pag := mv_par06
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(oMeter,oText,oDlg,@lEnd,@cArqTmp,;
						dFinalA+1,dFinal,"","","",Repl("Z", TamSx3("CT1_CONTA")[1]),;
						"",Repl("Z", TamSx3("CTT_CUSTO")[1]),"",Repl("Z", TamSx3("CTD_ITEM")[1]),;
						"",Repl("Z", TamSx3("CTH_CLVL")[1]),mv_par03,;
						mv_par14, aSetOfBook,,"",	Repl("Z", 20),,,,,, lImpAntLP, dDataLP,,,,,,,,,,,,,,,,,,,,,,,,,,,cMoedaDesc,;
						lMovPeriodo,/*59 aSelFil*/,,.T.,mv_par15=1)},STR0003,/*cProcesso*/) //"Criando Arquivo Temporario..."


//IndRegua("cArqTmp",cArqTmp,"CONTA",,,OemToAnsi(STR0006))  //"Selecionando Registros..."

dbSelectArea("cArqTmp") 
dbGoTop()  

oSection1:Init()

oReport:SetLineHeight(35)  
oSection1:SetBorder(2,,,.F.) 
oSection1:SetBorder(3,,,.F.) 
oSection1:SetCellBorder(4,,,.F.) 
oSection1:SetCellBorder(5,,,.T.) 

// Cria os 2 primeiros itens no array que ira compor o saldo inicial e final 
aLinhas := {STR0015,0,0,0,0,0,0,0,0,0,0,0,0,0,0} // Posicao no inicio do periodo 
AADD(aVisao, aLinhas)
aLinhas := {STR0016,0,0,0,0,0,0,0,0,0,0,0,0,0,0} // Posicao no fim do periodo
AADD(aVisao, aLinhas)
aLinhas := {}

While !Eof() // Carrega o array utilizado na impressao com os dados retornados da visao gerencial
     
	If cArqTmp->TIPOCONTA == '1'  
	
		If !Empty(aLinhas)
			AADD(aVisao, aLinhas)
			aLinhas := {}
		Endif
		
		nLin += 1
		AADD(aLinhas, cArqTmp->DESCCTA)  
	Endif
	
	If cArqTmp->TIPOCONTA == '2'
		AADD(aLinhas, ValorCTB(cArqTmp->SALDOATU,,,aTamVal[1],nDecimais,.T.,cPicture,;
							   cArqTmp->NORMAL, cArqTmp->CONTA,,,cTpValor,,,.F. ))  
							   
	  	aVisao[1][Len(aLinhas)] += cArqTmp->SALDOANT 
	  	aVisao[2][Len(aLinhas)] += cArqTmp->SALDOATU + cArqTmp->SALDOANT
	Endif

	dbSkip()
	
EndDo 

AADD(aVisao, aLinhas)    
      
nX := 2

While nX <= 15  // condicao para formatar os valores dos periodos inicial e final
    
	aVisao[1][nX] := ValorCTB(aVisao[1][nX],,,aTamVal[1],nDecimais,.T.,cPicture,;
							   cArqTmp->NORMAL, cArqTmp->CONTA,,,,,,.F. )

	aVisao[2][nX] := ValorCTB(aVisao[2][nX],,,aTamVal[1],nDecimais,.T.,cPicture,;
							   cArqTmp->NORMAL, cArqTmp->CONTA,,,,,,.F. )
							   
	nX++							   
EndDo

oSection1:Cell("DESCCTA"):SetBlock( { || Space(1)+aVisao[nX][1]} )    

nCol := 3 

For nCol := 3 To 16
	oSection1:aCell[nCol]:SetBlock( MontaBlock("{||aVisao[nX]["+Str(nCol-1,2)+"]}") )  
Next

nX := 1

While nX <=  nLin  

    If nX != 2
	   	oSection1:PrintLine()
	Endif
		   	
   	nX++
EndDo    

nX := 2

oSection1:PrintLine() // imprime o saldo final do periodo
 
oSection1:Finish()   
 
dbCloseArea()
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	

If lImpTrmAux  
	oReport:HideHeader()
	oReport:EndPage()
	cArqTRM 	:= mv_par10
	aVariaveis	:= {}

    // Buscando os parâmetros do relatorio (a partir do SX1) para serem impressaos do Termo (arquivos *.TRM)
	SX1->( dbSeek( padr( "CTR561" , Len( X1_GRUPO ) , ' ' ) + "01" ) )

	Do While SX1->X1_GRUPO == padr( "CTR561" , Len( SX1->X1_GRUPO ) , ' ' )
		AADD(aVariaveis,{Rtrim(Upper(SX1->X1_VAR01)),&(SX1->X1_VAR01)})
		SX1->( dbSkip() )
	Enddo
	
	If !File(cArqTRM)
		aSavSet:=__SetSets()
		cArqTRM := CFGX024(cArqTRM,STR0008) // "Responsáveis..."
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqTRM#NIL
		ImpTerm2(cArqTRM,aVariaveis,,,,oReport)
	Endif	 
Endif


Return .T.     

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CtrVld561    ³ Autor ³ Totvs					³ Data ³ 25/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica as perguntas dos relatorios                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Siga                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtrVld561(cPerg)


If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return .F.
EndIf

If ! Pergunte(cPerg,.T.) 
	Return .F.
Endif                    

If Empty(mv_par01)	
	Help(" ",1,"NOEXCONTAB")	
	Return .F.		
Else
	CTG->(dbSetOrder(1))
	If CTG->(! DbSeek(xFilial() + mv_par01))
		Help(" ",1,"NOEXISCALE")
		Return .F.
	EndIf
EndIf

Return .T.

