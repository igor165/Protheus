#INCLUDE "PROTHEUS.CH"
#INCLUDE "QMTR310.CH"
#INCLUDE  "REPORT.CH"



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QMTR310  ³ Autor ³ Cicero Cruz           ³ Data ³ 03.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao de instrumentos disponiveis                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMTR310(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QMTR310()

Local oReport        
Private cAliasQM2  := "QM2"  
Private cAliasQN4  := "QN4"  
Private cAliasQN5  := "QN5"  
Private aInstru    := {}     

If TRepInUse()
	// Interface de impressao
	oReport := ReportDef()
 	oReport:PrintDialog()
Else
	QMTR310R3()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Cicero Cruz           ³ Data ³ 03.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QMTR310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()
Local oReport 
Local oSection1
Local aOrdem    := {}
Local cPerg		:="QMT310"

/* Criacao do objeto REPORT
DEFINE REPORT oReport NAME <Nome do relatorio> ;
					  TITLE <Titulo> 		   ;
					  PARAMETER <Pergunte>     ;
					  ACTION <Bloco de codigo que sera executado na confirmacao da impressao> ;
					  DESCRIPTION <Descricao>
*/
DEFINE REPORT oReport NAME "QMTR310" TITLE STR0003 PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION STR0001 // "Relatorio de Instrumentos Disponiveis por Filial" ### "Relatorio de Instrumentos Disponiveis por Filial"
	   
/*aOrdem := {	STR0026,; 	// "Depto.+Data"
			STR0010,;   // "Data"
		    STR0016,;  	// "Instrumento"
		    STR0018} 	// "Familia"*/
/*
Criacao do objeto secao utilizada pelo relatorio                               
DEFINE SECTION  <Nome> OF <Objeto TReport que a secao pertence>  ;
       TITLE  <Descricao da secao>                               ;
       TABLES <Tabelas a ser usadas>                             ;
       ORDERS <Array com as Ordens do relatorio>                 ;
       LOAD CELLS            									 ; // Carrega campos do SX3 como celulas
       TOTAL TEXT //Carrega ordens do Sindex
*/
DEFINE SECTION oSection1 OF oReport   TITLE "S1"    TABLES "QN5", "QN4", "QM2" //ORDERS aOrdem
DEFINE SECTION oSection2 OF oReport   TITLE STR0011 TABLES "QN5"               
DEFINE SECTION oSection3 OF oReport   TITLE STR0013 TABLES "QN5"               

/*
DEFINE CELL NAME <Nome da celula do relatorio>                          ;
            OF <Objeto TSection que a secao pertence>                   ;
            ALIAS <Nome da tabela de referencia da celula>              ;
            TITLE <Titulo da celula>                                    ;
            Picture <Picture>                                           ;
            SIZE <Tamanho> 												;               
            PIXEL 														;//Informe se o tamanho esta em pixel 
            BLOCK <Bloco de codigo para impressao>
*/
DEFINE CELL NAME "QN5_INSTR"   OF oSection1 ALIAS "QN5"              
DEFINE CELL NAME "QN5_REVINS"  OF oSection1 ALIAS "QN5" 	         TITLE STR0015 
DEFINE CELL NAME "QN5_FILINS"  OF oSection1 ALIAS "QN5" 	         TITLE STR0016 
DEFINE CELL NAME "QM2_DESCR"   OF oSection1 ALIAS "QM2" 	         TITLE STR0017 
DEFINE CELL NAME "QM2_TIPO"    OF oSection1 ALIAS "QM2" 
DEFINE CELL NAME "QN4_RESENT"  OF oSection1 ALIAS "QN4" 	         TITLE STR0018 
DEFINE CELL NAME "QN4_FILREN"  OF oSection1 ALIAS "QN4" 	         TITLE STR0016  
DEFINE CELL NAME "QN4_DEPREN"  OF oSection1 ALIAS "QN4" 	         TITLE STR0019  
DEFINE CELL NAME "QM2_VALDAF"  OF oSection1 ALIAS "QM2"
DEFINE CELL NAME "QN4_DTAENT"  OF oSection1 ALIAS "QN4"   

DEFINE BREAK oBreak1 OF oSection1 WHEN {|| QN5_FILIAL }  TITLE OemToAnsi(STR0008) //"Total na Filial "

DEFINE FUNCTION oFunc FROM oSection1:Cell("QN5_INSTR") ;
					OF oSection1 FUNCTION COUNT BREAK oBreak1 TITLE OemToAnsi(STR0007) NO END SECTION NO END REPORT //"Total de Instrumentos Listados  "

DEFINE CELL NAME "FIL"  		OF oSection2             	SIZE  55 TITLE STR0020     // "FILIAL"
DEFINE CELL NAME "DESC"  		OF oSection2         	  	SIZE  55 TITLE STR0021  // "DESCRICAO" 

DEFINE CELL NAME "FIL"  		OF oSection3           		SIZE  55 TITLE STR0020 // "FILIAL"
DEFINE CELL NAME "DEPTO"  		OF oSection3          	  	SIZE  55 TITLE STR0022 // "DEPARTAMENTO"
DEFINE CELL NAME "DESC"  		OF oSection3          	  	SIZE  55 TITLE STR0021 // "DESCRICAO"



Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³PrintRepor³ Autor ³ Cicero Cruz           ³ Data ³ 03.07.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao dos Textos	Reprogramacao R4	 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTR310													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintReport( oReport )
Local oSection1 := oReport:Section(1)    
Local oSection2 := oReport:Section(2)
Local oSection3 := oReport:Section(3)  
Local oFunc     := oReport:Section(1):AFUNCTION[1]  
Local oBreak    := oReport:Section(1):ABREAK[1] 
Local nY := 0
Local cFiltro
Local cPerg		:="QMT310"
Local cInstAnt  := ""

Pergunte(cPerg,.F.)  


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 1                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:BeginQuery()	

cAliasQN5 := GetNextAlias()
//Para SQL me basta um alias entao eu normalizo o Alias
     cAliasQN4  := cAliasQN5  
     cAliasQM2  := cAliasQN5  
    
     cChave := '% 1 %'
   //		QN5.QN5_INSTR  = QM2.QM2_INSTR  AND

BeginSql Alias cAliasQN5
SELECT QN5.QN5_FILIAL, QN5.QN5_INSTR , QN5.QN5_REVINS, QN5.QN5_FILINS, QN4.QN4_RESENT, QN4.QN4_DEPREN, QN4.QN4_FILREN, 
            QN4.QN4_DEPRSA, QN4.QN4_FILRSA, QN4.QN4_DTAENT, QM2.QM2_TIPO  , QM2.QM2_VALDAF, QM2.QM2_DESCR
FROM   %table:QN5% QN5,
       %table:QN4% QN4,
 	  %table:QM2% QM2 	
WHERE  QN5.QN5_FILIAL BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
       QN5.QN5_INSTR  = QM2.QM2_INSTR  AND
	  QN5.QN5_REVINS = QM2.QM2_REVINS AND
	  QN5.QN5_INSTR  = QN4.QN4_INSTR  AND
	  QN5.QN5_REVINS = QN4.QN4_REVINS AND
	  QN5.QN5_FILINS = QN4.QN4_FILINS AND
	  QN5.QN5_STATUS IN ('1','2','3') AND
	  QN4.QN4_ULTMOV = 'S' AND
	  QM2.QM2_TIPO BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% AND
	  QN5.%notDel% AND
	  QN4.%notDel% AND
	  QM2.%notDel%
     ORDER BY %Exp:cChave% 
		
EndSql   
oSection1:EndQuery()	
	
oSection1:SetLineCondition({|| MTR310_CS1(oReport)}) 

oSection1:Print()
oSection1:Finish() 

If MV_PAR05 == 1 .AND. LEN(aInstru)>0
	oSection2:Init()  
	oReport:ThinLine() 
	// Totalizador geral estava  saindo depois da legenda
	oReport:SkipLine()
	oReport:PrintText(STR0007+":"+Str(oFunc:uReport),oReport:Row(),oSection1:Cell("QN5_INSTR"):ColPos())  //"Total de Instrumentos Listados  "
	oReport:SkipLine()           
	oReport:ThinLine() 
	oReport:SkipLine()
	oReport:PrintText(STR0011,oReport:Row(),oSection1:Cell("QN5_INSTR"):ColPos())
	oReport:SkipLine()
	oSection2:PrintLine()

	aSort(aInstru,,,{|x,y| x[1] < y[1]}) 
	cInstAnt:= ""
	For nY := 1 to Len(aInstru)
		If cInstAnt != aInstru[nY,1]
			cInstAnt := aInstru[nY,1]
			oSection2:Cell("FIL"):SetValue(aInstru[nY,1])
			oSection2:Cell("DESC"):SetValue(QA_CHKFIL(aInstru[nY,1],,.T.))  
			oSection2:PrintLine()
		EndIf
	Next
	oSection2:Finish()    

	oSection3:Init()  
	oReport:SkipLine()
	oReport:PrintText(STR0013,oReport:Row(),oSection1:Cell("QN5_INSTR"):ColPos())
	oReport:SkipLine()           
	oSection3:PrintLine()
	aSort(aInstru,,,{|x,y| x[1] < y[1]}) 
	cInstAnt:= ""
	For nY := 1 to Len(aInstru)
		If cInstAnt != aInstru[nY,1]+aInstru[nY,2]
			cInstAnt := aInstru[nY,1]+aInstru[nY,2]
			oSection3:Cell("FIL"):SetValue(aInstru[nY,1])
			oSection3:Cell("DEPTO"):SetValue(aInstru[nY,2])  
			oSection3:Cell("DESC"):SetValue(Posicione("QAD",1,xFilial("QAD")+aInstru[nY,2],"QAD_DESC"))  
			oSection3:PrintLine()
		EndIf
	Next
	oSection3:Finish()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³MTR310_CS1³ Autor ³ Cicero Cruz			³ Data ³ 08.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Condicao de impressão da Linha                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ MTR010_CS1(void)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function MTR310_CS1(oReport)
Local lRet       := .T.      
Local oSection1  := oReport:Section(1)  

If &(cAliasQM2+"->QM2_TIPO") <  MV_PAR03 .OR. &(cAliasQM2+"->QM2_TIPO") > MV_PAR04 
	lRet := .F.
Else
	If !Empty(aInstru)
		If !(Ascan(aInstru, { |x| x[1] == &(cAliasQN4+"->QN4_FILREN") .AND. x[2] == &(cAliasQN4+"->QN4_DEPREN") }) > 0)
			Aadd(aInstru,{ &(cAliasQN4+"->QN4_FILREN"), &(cAliasQN4+"->QN4_DEPREN") })                
		EndIf
		If !(Ascan(aInstru, { |x| x[1] == &(cAliasQN4+"->QN4_FILRSA") .AND. x[2] == &(cAliasQN4+"->QN4_DEPRSA") }) > 0)
			Aadd(aInstru,{ &(cAliasQN4+"->QN4_FILRSA"), &(cAliasQN4+"->QN4_DEPRSA") })	
		EndIf
	Else
		Aadd(aInstru,{ &(cAliasQN4+"->QN4_FILREN"), &(cAliasQN4+"->QN4_DEPREN") })
		If !(Ascan(aInstru, { |x| x[1] == &(cAliasQN4+"->QN4_FILRSA") .AND. x[2] == &(cAliasQN4+"->QN4_DEPRSA") }) > 0)
			Aadd(aInstru,{ &(cAliasQN4+"->QN4_FILRSA"), &(cAliasQN4+"->QN4_DEPRSA") })	
		EndIf
	Endif
EndIf    
		
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QMTR310R3 ³ Autor ³ Cleber Souza          ³ Data ³ 23/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relacao de instrumentos disponiveis                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMTR310R3(void)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cleber    ³Criacao do relatorio                                        ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMTR310R3()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDesc1        :=  STR0001 //"Relatorio de Instrumentos Disponiveis por Filial" 
Local cDesc2        := ""
Local cDesc3        := ""
Local nLin          := 80
Local Cabec1        := STR0002 //" Instr.            Rev. Fil  Descricao              Familia                                  Responsavel  Fil  Departamento    Nome                  Dta Val.Calib   Dta Entrada"
Local Cabec2        := ""
Local aOrd := {}

Private titulo      := STR0003 //"Relatorio de Instrumentos Disponiveis por Filial"
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 132
Private tamanho     := "G"
Private nomeprog    := "QMTR310" 
Private nTipo       := 18
Private aReturn     := { STR0009, 1, STR0010, 2, 2, 1, "", 1} //"Zebrado" //"Administracao"
Private nLastKey    := 0
Private cPerg       := "QMT310"
Private wnrel       := "QMTR310" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString     := "QN5"

dbSelectArea("QN5")
dbSetOrder(1)

pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                  ³
//³ mv_par01   : Filia De			                      ³
//³ mv_par02   : Filial Ate 		                      ³
//³ mv_par03   : Familia da Instrumento De                ³
//³ mv_par04   : Familia da Instrumento Ate               ³
//³ mv_par05   : Imprime Legenda Depto (Sim/Nao)          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ Cleber Souza       º Data ³  23/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTR310				                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local cQuery    := ""   
Local aInstru   := {}  
Local nY        := 0
Local cFilAtu   := "" 
Local nInsFil   := 0
Local nInsTot   := 0
Local lPrimVez  := .T. 
Local cInsAtu   := ""    
Local cCond     := "" 
Local cIndex    := ""
Local cChave    := "" 
Local aFilial   := {}
Local aDepto    := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ+¿
//³Dimensões da Array aInstru      ³
//³                                ³
//³1 - Filial                      ³
//³2 - Instrumento                 ³
//³3 - Revisao do Instrumento      ³
//³4 - Filial do Instrumento       ³
//³5 - Responsavel pelo Instrumento³
//³6 - Departamento do Responsavel ³
//³7 - Filial do Responsavel       ³
//³8 - Data da Entrada             ³
//³9 - Familia do Instrumento      ³
//³10 - Validade da Calibração     ³
//³11 - Descrição do Instrumento   ³
//³                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ+Ù

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := Space(10)
cbcont   := 0
m_pag    := 1

If Empty(MV_PAR01) .or. !IsDigit(MV_PAR01)
	MV_PAR01 := "00"
Endif               

If Empty(MV_PAR02) .or. !IsDigit(MV_PAR02)  
	MV_PAR02 := "99"
Endif               

	
	cQuery := " SELECT QN5.QN5_FILIAL, QN5.QN5_INSTR, QN5.QN5_REVINS, QN5.QN5_FILINS, QN4.QN4_RESENT, QN4.QN4_DEPREN, QN4.QN4_FILREN, QN4.QN4_DTAENT, QM2.QM2_TIPO, QM2.QM2_VALDAF, QM2.QM2_DESCR "
	cQuery += " FROM " + RetSqlName("QN5")+" QN5 ,"
	cQuery += RetSqlName("QM2")+" QM2 ," 
	cQuery += RetSqlName("QN4")+" QN4 "
	cQuery += " WHERE "
	cQuery += "QN5.QN5_FILIAL >= '" +MV_PAR01+ "' AND QN5.QN5_FILIAL <= '" +MV_PAR02 +"' AND "
//	cQuery += "QN5.QN5_FILINS = QM2.QM2_FILIAL AND "
	cQuery += "QN5.QN5_INSTR  = QM2.QM2_INSTR  AND "
	cQuery += "QN5.QN5_REVINS = QM2.QM2_REVINS AND "
	cQuery += "QN5.QN5_INSTR  = QN4.QN4_INSTR  AND "
	cQuery += "QN5.QN5_REVINS = QN4.QN4_REVINS AND "
	cQuery += " QN5.QN5_FILINS = QN4.QN4_FILINS AND "
	cQuery += " QN4.QN4_ULTMOV = 'S' AND "
	cQuery += " QM2.QM2_TIPO >= '"+MV_PAR03+"' AND QM2.QM2_TIPO <= '"+MV_PAR04+"' AND "
	cQuery += " QN5.QN5_STATUS IN ('1','2','3') AND "
	cQuery += " QN5.D_E_L_E_T_= ' ' AND "
	cQuery += " QN4.D_E_L_E_T_= ' ' AND "
	cQuery += " QM2.D_E_L_E_T_= ' ' "
	cQuery += " ORDER BY QN5_FILIAL "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)
	TcSetField("TRB","QM2_VALDAF","D",8,0)
	TcSetField("TRB","QN4_DTAENT","D",8,0)
	
	dbSelectArea( "TRB" )
	TRB->(dbGoTop())
	While TRB->(!Eof())
		Aadd(aInstru,{TRB->QN5_FILIAL,TRB->QN5_INSTR, TRB->QN5_REVINS, TRB->QN5_FILINS,;
		TRB->QN4_RESENT, TRB->QN4_DEPREN, TRB->QN4_FILREN,;
		TRB-> QN4_DTAENT, TRB->QM2_TIPO, TRB->QM2_VALDAF,TRB->QM2_DESCR})
		dbSkip()
	Enddo
	
	TRB->(dbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(Len(aInstru))

For nY:=1 to Len(aInstru)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cancelamento pelo usuario...                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAbortPrint
		@nLin,00 PSAY STR0005 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho do relatorio. . .                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 55
		Cabec(Titulo,Cabec1,"",NomeProg,Tamanho,nTipo)
		nLin := 6
	Endif
	
	If cInsAtu<>aInstru[nY,1]
		If !lPrimVez
			QM310Rodape(cInsAtu,nInsFil,@nLin)
			nLin ++
			@nLin,01 PSAY STR0006+aInstru[nY,1]  //"Relação de Instrumentos Disponiveis para Filial "
			nLin += 2
			nInsFil := 0
			cInsAtu  := aInstru[nY,1]
		Else
			lPrimVez := .f. 
			nLin += 2
			@nLin,01 PSAY STR0006+aInstru[nY,1]  //"Relação de Instrumentos Disponiveis para Filial "
			nLin += 2
			cInsAtu  := aInstru[nY,1]
		EndIf
	EndIf 
	
	//Posiciona no Usuario Responsavel
	dbSelectArea("QAA")
	dbSetOrder(1)
	dbSeek(aInstru[nY,7]+aInstru[nY,5])       

	@ nLin,1   PSAY aInstru[nY,2]
	@ nLin,19  PSAY aInstru[nY,3]
	@ nLin,24  PSAY aInstru[nY,4]  
	@ nLin,29  PSAY Substr(aInstru[nY,11],1,20)
	@ nLin,52  PSAY ALltrim(aInstru[nY,9])+" - "+Substr(Posicione("QM1",1,xFilial("QM1")+aInstru[nY,9],"QM1_DESCR"),1,20)
	@ nLin,93  PSAY aInstru[nY,5] 
	@ nLin,106  PSAY aInstru[nY,7]   
	@ nLin,111  PSAY aInstru[nY,6]   
	@ nLin,127 PSAY Substr(QAA->QAA_NOME,1,20)
	@ nLin,149 PSAY aInstru[nY,10]   
	@ nLin,165 PSAY aInstru[nY,8]   

	nLin := nLin + 1 // Avanca a linha de impressao
	
	If MV_PAR05 == 1 
	
		//Pesquisa as Filiais utilizados
		If aScan(aFilial,{|x|x[1]==aInstru[nY,4]}) == 0
	   		AADD(aFilial,{aInstru[nY,4]})
	   	EndIF	

		If aScan(aFilial,{|x|x[1]==aInstru[nY,7]}) == 0
	   		AADD(aFilial,{aInstru[nY,7]})
	   	EndIF	
        
		//Pesquisa os Departamentos utilizados
   		If aScan(aDepto,{|x|x[1]==aInstru[nY,4]+aInstru[nY,6]}) == 0
	   		AADD(aDepto,{aInstru[nY,4]+aInstru[nY,6]})
	   	EndIF	

	EndIF
	
	nInsFil++
	
Next nY

QM310Rodape(cInsAtu,nInsFil,@nLin)

nLin +=2
@ nLin,1 PSAY STR0007 + Alltrim(Str(Len(aInstru)))  //"Total de Instrumentos Listados : "
nLin++
@ nLin,1 PSAY ""

If MV_PAR05 == 1 .and. Len(aFilial)>0

	nLin +=2
	@nLin,00 PSAY __PrtFatLine()		
	nLin ++ 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho do relatorio. . .                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 55
		Cabec(Titulo,Cabec1,"",NomeProg,Tamanho,nTipo)
		nLin := 6
	Endif
                                 
	@nLin,001 PSAY STR0011  //"LEGENDA DAS FILIAIS"
	nLin +=2                                
	@nLin,001 PSAY STR0012  //"FILIAL     DESCRICAO"
	nLin ++
	 
	For nY:=1 to Len(aFilial)
		@nLin,001 PSAY aFilial[nY,1]
		@nLin,012 PSAY QA_CHKFIL(aFilial[nY,1],,.T.) 
		nLin ++  
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nLin > 55
			Cabec(Titulo,Cabec1,"",NomeProg,Tamanho,nTipo)
			nLin := 6
		Endif
   
    Next nY
   
	nLin +=2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho do relatorio. . .                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 55
		Cabec(Titulo,Cabec1,"",NomeProg,Tamanho,nTipo)
		nLin := 6
	Endif          

	@nLin,001 PSAY STR0013 //"LEGENDA DOS DEPARTAMENTOS POR FILIAL"
	nLin +=2 
	@nLin,001 PSAY STR0014 //"FILIAL  DEPTO             DESCRICAO"
	nLin ++

	For nY:=1 to Len(aDepto)
		@nLin,001 PSAY Substr(aDepto[nY,1],1,2)
		@nLin,009 PSAY Substr(aDepto[nY,1],3,Len(Alltrim(aDepto[nY,1]))-2)
		@nLin,027 PSAY Posicione("QAD",1,aDepto[nY,1],"QAD_DESC") 
		nLin ++  
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nLin > 55
			Cabec(Titulo,Cabec1,"",NomeProg,Tamanho,nTipo)
			nLin := 6
		Endif
   
    Next nY

EndIF
nLin++
@ nLin,1 PSAY ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QM310RodapeºAutor  ³Cleber Souza      º Data ³  04/23/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Impressao do Rodape do Relatorio (Sub Total)             º±±
±±º          ³                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTR310                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QM310Rodape(cInsAtu,nInsFil,nLin)

nLin ++
@nLin,01 PSAY STR0008+cInsAtu+" : " + Alltrim(Str(nInsFil)) //"Total na Filial "
nLin ++
@nLin,01 PSAY __PrtFatLine()
nLin ++

Return  

