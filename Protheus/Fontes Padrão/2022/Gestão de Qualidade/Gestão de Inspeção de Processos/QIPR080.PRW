#Include "QIPR080.CH"
#Include "PROTHEUS.CH"
#INCLUDE "Report.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QIPR080   ºAutor  ³Leandro Sabino      º Data ³  20/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Instrumento X Lotes			                              º±±
±±º          ³ (Versao Relatorio Personalizavel)                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                            
Function QIPR080()
Local oReport

If  TRepInUse()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01             // Da Data de Medi‡Æo      	         ³
	//³ mv_par02             // At‚ Data de Medi‡Æo                  ³
	//³ mv_par03             // Do Instrumento                       ³
	//³ mv_par04             // At‚ Instrumento                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("QPR080",.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
	Return QIPR080R3()	// Executa versão anterior do fonte
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef()   ³ Autor ³ Leandro Sabino   ³ Data ³ 20/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montar a secao				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDef()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPR080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local cTitulo  	    := STR0003	//"Instrumento x Lote"
Local cDesc1 		:= STR0001	//"SerÆo relacionados os Instrumentos utilizados em cada Lote."
Local oSection1 

DEFINE REPORT oReport NAME "QIPR080" TITLE cTitulo PARAMETER "QPR080" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1)
oReport:SetLandscape(.T.)

DEFINE SECTION oSection1 OF oReport TABLES "TRB" TITLE TitSX3("QPR_PRODUT")[1]
DEFINE CELL NAME "PRODUT" OF oSection1 ALIAS "TRB" TITLE AllTrim(TitSX3("QPR_PRODUT")[1]) SIZE (TamSx3("QPR_PRODUT")[1])
DEFINE CELL NAME "REVI"   OF oSection1 ALIAS "TRB" TITLE AllTrim(TitSX3("QPR_REVI")[1])   SIZE (TamSx3("QPR_REVI")[1])
DEFINE CELL NAME "OP"     OF oSection1 ALIAS "TRB" TITLE AllTrim(TitSX3("QPR_OP")[1])     SIZE (TamSx3("QPR_OP")[1])
DEFINE CELL NAME "DTENTR" OF oSection1 ALIAS "TRB" TITLE AllTrim(TitSX3("QPR_DTENTR")[1]) SIZE (TamSx3("QPR_DTENTR")[1])
DEFINE CELL NAME "LOTE"   OF oSection1 ALIAS "TRB" TITLE AllTrim(TitSX3("QPR_LOTE")[1])   SIZE (TamSx3("QPR_LOTE")[1])
DEFINE CELL NAME "DTMEDI" OF oSection1 ALIAS "TRB" TITLE AllTrim(TitSX3("QPR_DTMEDI")[1]) SIZE (TamSx3("QPR_DTMEDI")[1])

Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PrintReport   ³ Autor ³ Leandro Sabino   ³ Data ³ 20/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Instrumento X Lotes         							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrintReport(ExpO1)  	     	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPR080                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                  
Static Function PrintReport(oReport) 
Local oSection1  := oReport:Section(1)
Local cQPT_INSTR := TitSX3("QPT_INSTR")[1] 
Local cInstr     := ""
Local cChave     := ""
Local aArea	   := GetArea()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho			       				     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

MakeSqlExpr(oReport:uParam)

oSection1:BeginQuery()
		
 	BeginSQL Alias "TRB"  
 
	COLUMN DTENTR AS DATE
	COLUMN DTMEDI AS DATE

 	SELECT 	QPR.QPR_DTENTR DTENTR, QPT.QPT_INSTR INSTR, QPR.QPR_PRODUT PRODUT,
	 	    QPR.QPR_REVI REVI    , QPR.QPR_OP OP      , QPT.QPT_CODMED CODMED, 
	 	    QPR.QPR_DTMEDI DTMEDI, QPR.QPR_LOTE LOTE 
 	FROM  %table:QPT% QPT, %table:QPR% QPR 
	WHERE 
	 QPT.QPT_FILIAL  = %xFilial:QPT%  And QPR.QPR_FILIAL  = %xFilial:QPR%  And 
	 QPR.QPR_DTMEDI Between %Exp:Dtos(mv_par01)% And %Exp:Dtos(mv_par02)% And 
	 QPT.QPT_INSTR  Between %Exp:mv_par03% And %Exp:mv_par04% And 
	 QPT.QPT_CODMED = QPR.QPR_CHAVE And 
	 QPT.%notDel% And QPR.%notDel%
	 
	GROUP BY QPR.QPR_DTENTR,QPT.QPT_INSTR,QPR.QPR_PRODUT,QPR.QPR_REVI,QPR.QPR_OP,QPT.QPT_CODMED,QPR.QPR_DTMEDI,QPR.QPR_LOTE			

	ORDER BY QPR_DTENTR, QPT_INSTR, QPR_PRODUT

   EndSql
   
oSection1:EndQuery()

dbSelectArea("TRB")
dbGoTop()

While !oReport:Cancel() .And. TRB->(!Eof())
	If cChave <> TRB->INSTR+TRB->PRODUT+TRB->REVI+TRB->OP+Dtos(TRB->DTENTR)+TRB->LOTE+Dtos(TRB->DTMEDI)
		If cInstr != TRB->INSTR
			If !Empty(cInstr)
				oSection1:Finish()
			EndIf
			oSection1:Init()
			oReport:SkipLine(1) 
			oReport:ThinLine()
			oReport:PrintText(cQPT_INSTR+": "+TRB->INSTR,oReport:Row(),025) //"Instrumento" 
			oReport:SkipLine(1)	
			oReport:ThinLine()
			cInstr := TRB->INSTR	
	    Endif
		oSection1:PrintLine()
		cChave := TRB->INSTR+TRB->PRODUT+TRB->REVI+TRB->OP+Dtos(TRB->DTENTR)+TRB->LOTE+Dtos(TRB->DTMEDI)	
	Endif
	TRB->(dbSkip())
EndDo

oSection1:Finish()
TRB->(DbCloseArea())

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIPR080R3³ Autor ³ Antonio Aurelio F. C. ³ Data ³ 24.08.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Instrumento X Lotes                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPR080(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQIP                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Paulo Emidio³18/05/00³      ³Retirada da funcao de ajuste do SX1       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIPR080R3()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel
Local cDesc1 		:= STR0001	//"SerÆo relacionados os Instrumentos utilizados em cada Lote."
Local cDesc2 		:= ""
Local cDesc3 		:= ""
Local cString		:= "QPR"
Local cTitulo  	    := STR0003	//"Instrumento x Lote"
Local cTamanho      := "M"
Local cProg     	:= "QIPR080"
Local cAlias        := Alias()

Private aReturn 	:= { STR0004,1,STR0005, 1, 2, 1, "",1}		//"Zebrado"###"Administracao"
Private nLastKey    := 0
Private cPerg   	:= "QPR080"
Private cNomArq		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Da Data de Medi‡Æo      	         ³
//³ mv_par02             // At‚ Data de Medi‡Æo                  ³
//³ mv_par03             // Do Instrumento                       ³
//³ mv_par04             // At‚ Instrumento                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := cProg

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,wnrel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho,cProg)

If nLastKey == 27
	Set Filter To
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| R080Imp(@lEnd,wnrel,cString,cTitulo,cTamanho,cProg)},cTitulo)

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R080IMP  ³ Autor ³ Antonio Aurelio F. C. ³ Data ³ 24.08.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPR080			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R080Imp(lEnd,wnrel,cString,cTitulo,cTamanho,cProg)
Local cbTxt
Local cbCont		:=00
Local cChave		:=""
Local cInstr		:=""
Local Cabec1		:=""
Local Cabec2		:=""
Local cQPT_INSTR	:= TitSX3("QPT_INSTR")[1]
Local cQPR_PRODUT	:= AllTrim(TitSX3("QPR_PRODUT")[1])
Local cQPR_REVI		:= AllTrim(TitSX3("QPR_REVI")[1])
Local cQPR_OP		:= AllTrim(TitSX3("QPR_OP")[1])
Local cQPR_LOTE		:= AllTrim(TitSX3("QPR_LOTE")[1])
Local cQPR_DTMEDI	:= AllTrim(TitSX3("QPR_DTMEDI")[1])

cbTxt := Space(10)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
li       := 80
m_pag    := 1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Funcao para gerar arquivo de Trabalho		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QPR080Trb()
Cabec1:= STR0008+ Dtoc(mv_par01) + STR0009+ Dtoc(mv_par02)		//"Periodo : "###" a "

dbSelectArea("TRB")
dbGoTop()
SetRegua(TRB->(RecCount()))
While !EOF()
	IncRegua()
	If lEnd
		@PRow()+1,001 PSAY STR0007	//"CANCELADO PELO OPERADOR"
		Exit
	Endif
	If Li > 60
		Cabec(cTitulo,Cabec1,Cabec2,cProg,cTamanho,IIF(aReturn[4]==1,15,18))
	EndIf
	
	If cChave <> TRB->INSTR+TRB->PRODUT+TRB->REVI+TRB->OP+Dtos(TRB->DTENTR)+TRB->LOTE+Dtos(TRB->DTMEDI)

		If cInstr != TRB->INSTR
			Li+=2
			@Li,00 PSAY cQPT_INSTR +": " +TRB->INSTR	//"Tag Instrumento : "
			Li+=2
			@Li,00 PSAY cQPR_PRODUT
			@Li,34 PSAY cQPR_REVI
			@Li,44 PSAY cQPR_OP
			@Li,60 PSAY STR0011							//"Data Producao"
			@Li,76 PSAY cQPR_LOTE
			@Li,95 PSAY cQPR_DTMEDI
			Li++
			@ li,000 PSAY __PrtThinLine()
			Li++
			cInstr := TRB->INSTR
		EndIf

		@Li,00 PSAY TRB->PRODUT 
		@Li,34 PSAY TRB->REVI
		@Li,44 PSAY TRB->OP
		@Li,60 PSAY TRB->DTENTR
		@Li,76 PSAY TRB->LOTE
		@Li,95 PSAY TRB->DTMEDI
		Li++
		cChave := TRB->INSTR+TRB->PRODUT+TRB->REVI+TRB->OP+Dtos(TRB->DTENTR)+TRB->LOTE+Dtos(TRB->DTMEDI)
	EndIf
	dbSkip()
EndDo

If Li != 80
	roda(cbCont,cbtxt)
EnDif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QPR")
Set Filter To
RetIndex("QPR")
dbSelectArea("TRB")
dbCloseArea()

Set device to Screen
If aReturn[5] == 1
	Set Printer To 
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()
Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QPR080Trb ³ Autor ³ Marcelo Pimentel      ³ Data ³ 25/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Armazenamento e Tratamento arquivo de trabalho             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso 	 ³ Sigaqip                       				              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function QPR080Trb()
Local cQuery		:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho			       				     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT " + Chr(13)+Chr(10)
cQuery += " QPR.QPR_DTENTR DTENTR, QPT.QPT_INSTR INSTR, QPR.QPR_PRODUT PRODUT,"	+ Chr(13)+Chr(10)
cQuery += " QPR.QPR_REVI REVI, QPR.QPR_OP OP, QPT.QPT_CODMED CODMED, "			+ Chr(13)+Chr(10)
cQuery += " QPR.QPR_DTMEDI DTMEDI, QPR.QPR_LOTE LOTE "							+ Chr(13)+Chr(10)
 	
cQuery += "FROM " 								+ Chr(13)+Chr(10)
cQuery += "	" + RetSQLName("QPT") + " QPT, "	+ Chr(13)+Chr(10)
cQuery += "	" + RetSQLName("QPR") + " QPR "		+ Chr(13)+Chr(10)

cQuery += "WHERE "  + Chr(13)+Chr(10)
cQuery += " QPT.QPT_FILIAL  = '" + xFilial("QPT") +"' and "	+ Chr(13)+Chr(10)
cQuery += " QPR.QPR_FILIAL  = '" + xFilial("QPR") +"' and "	+ Chr(13)+Chr(10)
cQuery += " QPR.QPR_DTMEDI Between '"+Dtos(mv_par01)+"' and '" +  Dtos(mv_par02)+"' and "	+ Chr(13)+Chr(10)
cQuery += " QPT.QPT_INSTR Between '"+mv_par03+"'And '" + mv_par04+"' and "+ Chr(13)+Chr(10)
cQuery += " QPT.QPT_CODMED = QPR.QPR_CHAVE and "
cQuery += " QPT.D_E_L_E_T_ <> '*' and "	+ Chr(13)+Chr(10)
cQuery += " QPR.D_E_L_E_T_ <> '*' "		+ Chr(13)+Chr(10)

cQuery += "GROUP BY QPR.QPR_DTENTR,QPT.QPT_INSTR,QPR.QPR_PRODUT,QPR.QPR_REVI,"	+ Chr(13)+Chr(10)
cQuery += "QPR.QPR_OP,QPT.QPT_CODMED,QPR.QPR_DTMEDI,QPR.QPR_LOTE"				+ Chr(13)+Chr(10)

cQuery += "ORDER BY QPR_DTENTR, QPT_INSTR, QPR_PRODUT"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB", .F., .T.)
TcSetField( "TRB", "DTMEDI"	,"D")
TcSetField( "TRB", "DTENTR"	,"D")
Return(.T.)
