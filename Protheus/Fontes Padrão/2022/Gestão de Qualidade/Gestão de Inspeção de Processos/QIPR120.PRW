#INCLUDE "QIPR120.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Report.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QIPR120   ºAutor  ³Leandro Sabino      º Data ³  01/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Referˆncia Cruzada : NÆo Conformidade X Ensaio             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAQIP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                            
Function QIPR120()
Local oReport
Private lRelR4 := .F.
Private  __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
Private lProduto   := .F.

If TRepInUse()
	lRelR4:= .T.
	Pergunte("QPR120",.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
	Return QIPR120R3()	// Executa versão anterior do fonte
EndIF    

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
±±³ Uso      ³ QIPR120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local cTitulo1	:= OemToAnsi(STR0002) //"Referencia Cruzada : NC x Ensaios"
Local cTitulo2	:= OemToAnsi(STR0005)+Dtoc(mv_par01)+OemToansi(STR0006)+Dtoc(mv_par02)//"Periodo da Producao : "###" a "
Local cDesc1	:= OemToAnsi(STR0001) //"Ser„o relacionadas as Nao Conformidades associadas aos Ensaios."
Local oSection1 

DEFINE REPORT oReport NAME "QIPR120" TITLE (cTitulo1+" "+cTitulo2) PARAMETER "QPR120" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1)
oReport:SetLandscape(.T.)

DEFINE SECTION oSection1 OF oReport TABLES "TRB" TITLE STR0009 //"Ord. Prod."
DEFINE CELL NAME "cOP"     OF oSection1 ALIAS "TRB" TITLE OemtoAnsi(STR0009) SIZE 11  //"Ord. Prod."
DEFINE CELL NAME "cLote"   OF oSection1 ALIAS "TRB" TITLE AllTrim(TitSX3("QPR_LOTE")[1])      SIZE (TamSx3("QPR_LOTE")[1])
DEFINE CELL NAME "cDt"     OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0010)                   SIZE 16 //"Data/Hora Med."
DEFINE CELL NAME "cNAOCON" OF oSection1 ALIAS "TRB" TITLE SubStr(TitSX3("QPU_NAOCON")[1],1,8) SIZE 02
DEFINE CELL NAME "cNCONF"  OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0012)                   SIZE 10  // "No. NCs"
DEFINE CELL NAME "cTEM"    OF oSection1 ALIAS ""    TITLE AllTrim(TitSX3("QPU_TEMCRO")[1])     SIZE 80 

Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PrintReport   ³ Autor ³ Leandro Sabino   ³ Data ³ 01/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Referˆncia Cruzada : NÆo Conformidade X Ensaio       	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrintReport(ExpO1)  	     	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPR120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                  
Static Function PrintReport(oReport) 
Local oTempTable	:= NIL
Local oSection1	:= oReport:Section(1)
Local cEspecie	:= "QIPA210C"
Local cEnsaio		:= ""
Local aCampos		:= {}
Local cArqTemp	 := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho.                          			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTam:=TamSX3("QP6_DESCPO")	;	AADD(aCampos,{"TRB_DESCPO","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_OP")		;	AADD(aCampos,{"TRB_OP"    ,"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_PRODUT")	;	AADD(aCampos,{"TRB_PRODUT","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_REVI")	;	AADD(aCampos,{"TRB_REVI"  ,"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_DTENTR")	;	AADD(aCampos,{"TRB_DTENTR","D",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_LOTE")	;	AADD(aCampos,{"TRB_LOTE"  ,"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_ENSAIO")	;	AADD(aCampos,{"TRB_ENSAIO","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_DTMEDI")	;	AADD(aCampos,{"TRB_DTMEDI","D",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_HRMEDI")	;	AADD(aCampos,{"TRB_HRMEDI","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_NAOCON")	;	AADD(aCampos,{"TRB_NAOCON","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_NUMNC")	;	AADD(aCampos,{"TRB_NUMNC" ,"N",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_CHAVE")	;	AADD(aCampos,{"TRB_CHAVE" ,"C",aTam[1],aTam[2]})

oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("indice1", {"TRB_PRODUT"} )
oTempTable:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da funcao para gerar arquivo de Trabalho.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !GeraTrab(.T.,oReport)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga o arquivo de trabalho                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	oTempTable:Delete()
	Return Nil
EndIf

TRB->(dbGoTop())
While TRB->(!EOF()) 
	If cEnsaio != TRB->TRB_ENSAIO
		cEnsaio := TRB->TRB_ENSAIO

		QP1->(dbSetOrder(1))
		QP1->(dbSeek(xFilial("QP1")+cEnsaio))

		oSection1:Finish()
		oSection1:Init()
		oReport:SkipLine(1) 
		oReport:ThinLine()
		oReport:PrintText(TitSX3("QPR_ENSAIO")[1] +": "+ TRB->TRB_ENSAIO+" "+QP1->QP1_DESCPO,oReport:Row(),025) 
		oReport:SkipLine(1)	
		oReport:ThinLine()
    Endif

    oSection1:CELL("cOP"):SetValue(TRB->TRB_OP)  
	oSection1:CELL("cLote"):SetValue(TRB->TRB_LOTE)
	oSection1:CELL("cDt"):SetValue(Dtoc(TRB->TRB_DTMEDI)+"-"+TRB->TRB_HRMEDI)//Data/Hora Medi‡ao
	oSection1:CELL("cNAOCON"):SetValue(TRB->TRB_NAOCON)
	oSection1:CELL("cNCONF"):SetValue(AllTrim(Str(TRB->TRB_NUMNC)))
	
	oSection1:CELL("cOP"):Show()  
	oSection1:CELL("cLote"):Show()  
	oSection1:CELL("cDt"):Show()  
	oSection1:CELL("cNAOCON"):Show()  
	oSection1:CELL("cNCONF"):Show()  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime o Texto da Cronica.							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QA2->(dbSeek(xFilial("QA2")+cEspecie+TRB->TRB_CHAVE))
		While QA2->(!Eof()) .And. 	QA2->QA2_FILIAL == xFilial("QA2") .And. ;
				QA2->QA2_CHAVE == TRB->TRB_CHAVE  .And. QA2->QA2_ESPEC == cEspecie
				
		  	If !Empty(StrTran(QA2->QA2_TEXTO, "\13\10", ""))
				oSection1:CELL("cTEM"):SetValue(StrTran(QA2->QA2_TEXTO, "\13\10", ""))
			Else
				oSection1:CELL("cTEM"):SetValue("")		
			EndIf
			oSection1:PrintLine()

		    oSection1:CELL("cOP"):Hide()  
			oSection1:CELL("cLote"):Hide()  
			oSection1:CELL("cDt"):Hide()  
			oSection1:CELL("cNAOCON"):Hide()  
			oSection1:CELL("cNCONF"):Hide()  
		
			QA2->(dbSkip())
		EndDo
	Else	
		oSection1:PrintLine()
	EndIf
	
	TRB->(dbSkip())

EndDo
	
oTempTable:Delete()

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QIPR120R3 ³ Autor ³ Marcelo Pimentel      ³      ³ 20/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Referˆncia Cruzada : NÆo Conformidade X Ensaio             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPR120(Void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQIP                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QIPR120R3()

Local wnrel			:= "QIPR120"
Local cDesc1		:= OemToAnsi(STR0001) //"Ser„o relacionadas as Nao Conformidades associadas aos Ensaios."
Local cDesc2		:= ""
Local cDesc3		:= ""
Local cString		:= "QPR"
Local cTitulo		:= OemToAnsi(STR0002) //"Referencia Cruzada : NC x Ensaios"
Local cTamanho		:= "M"
Local cProg			:= "QIPR120"

Private aReturn		:= {OemToAnsi(STR0003),1,OemToAnsi(STR0004),1,2,1,"",1} //"Zebrado"###"Administracao"
Private nLastKey	:= 0
Private cPerg		:= "QPR120"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01            // Da Data da Producao       	         ³
//³ mv_par02            // At‚ Data da Producao      	         ³
//³ mv_par03            // Do  Produto             	             ³
//³ mv_par04            // At‚ Produto              	         ³
//³ mv_par05            // Do  Ensaio               	         ³
//³ mv_par06            // At‚ Ensaio              	             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho)

If nLastKey == 27
	Set Filter To
	Return .F.
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter To
	Return .F.
Endif

RptStatus({|lEnd| R120Imp(@lEnd,wnrel,cString,cTitulo,cProg,cTamanho)},cTitulo)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R120IMP  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 26/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPR120			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R120Imp(lEnd,wnrel,cString,cTitulo,cProg,cTamanho)

Local oTempTable	:= NIL
Local CbTxt     := Space(10)
Local cbCont	:= 0
Local Cabec1	:= OemToAnsi(STR0005)+Dtoc(mv_par01)+OemToansi(STR0006)+Dtoc(mv_par02) //"Periodo da Producao : "###" a "
Local Cabec2	:= ""
Local cEnsaio	:= ""
Local aCampos	:= {}
Local cArqTemp	:= ""
Local nTipo		:= If(aReturn[4] == 1,15,18)
Local cEspecie  := "QIPA210C"

Li    := 80
m_pag := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho.                          			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTam:=TamSX3("QP6_DESCPO")	;	AADD(aCampos,{"TRB_DESCPO","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_OP")		;	AADD(aCampos,{"TRB_OP"    ,"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_PRODUT")	;	AADD(aCampos,{"TRB_PRODUT","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_REVI")	;	AADD(aCampos,{"TRB_REVI"  ,"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_DTENTR")	;	AADD(aCampos,{"TRB_DTENTR","D",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_LOTE")	;	AADD(aCampos,{"TRB_LOTE"  ,"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_ENSAIO")	;	AADD(aCampos,{"TRB_ENSAIO","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_DTMEDI")	;	AADD(aCampos,{"TRB_DTMEDI","D",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_HRMEDI")	;	AADD(aCampos,{"TRB_HRMEDI","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_NAOCON")	;	AADD(aCampos,{"TRB_NAOCON","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_NUMNC")	;	AADD(aCampos,{"TRB_NUMNC" ,"N",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_CHAVE")	;	AADD(aCampos,{"TRB_CHAVE" ,"C",aTam[1],aTam[2]})

oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("indice1", {"TRB_PRODUT"} )
oTempTable:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da funcao para gerar arquivo de Trabalho.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !GeraTrab()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga o arquivo de trabalho                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	oTempTable:Delete()
	Return .T.
EndIf

If TRB->(BOF()) .and. TRB->(EOF())
	HELP(" ",1,"RECNO")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga o arquivo de trabalho                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	dbSelectArea("TRB")
	dbCloseArea()
	Ferase(cArqTemp+GetDBExtension())  
	Return .T.
EndIf

TRB->(dbGoTop())
SetRegua(TRB->(RecCount()))
While TRB->(!EOF())

	IncRegua()

	If LastKey() == 286    //ALT_A
		lEnd := .T.
	EndIf
	
	If lEnd
		@PRow()+1,001 PSAY OemToAnsi(STR0007) //"CANCELADO PELO OPERADOR"
		Exit
	EndIf

	If cEnsaio != TRB->TRB_ENSAIO
		cEnsaio := TRB->TRB_ENSAIO
		If Li > 58
			Cabec(cTitulo,cabec1,cabec2,cProg,cTamanho,nTipo)
		EndIf		
		QP1->(dbSetOrder(1))
		QP1->(dbSeek(xFilial("QP1")+cEnsaio))
		@Li,00 PSAY TitSX3("QPR_ENSAIO")[1] +": "+ TRB->TRB_ENSAIO+" "+QP1->QP1_DESCPO
		Li+=2
		@Li,000 PSAY OemtoAnsi(STR0009) //"Ord. Prod."
		@Li,012 PSAY TitSX3("QPR_LOTE")[1]
		@Li,029 PSAY OemToAnsi(STR0010) //"Data/Hora Med."
		@Li,046 PSAY SubStr(TitSX3("QPU_NAOCON")[1],1,8)
		@Li,058 PSAY OemToAnsi(STR0012) // "No. NCs"
		@Li,066 PSAY TitSX3("QPU_TEMCRO")[1]
		Li++
		@Li,000 PSAY __PrtThinLine()
		Li++
	EndIf

	@Li,000 PSAY AllTrim(TRB->TRB_OP)
	@Li,012 PSAY TRB->TRB_LOTE
	@Li,029 PSAY Dtoc(TRB->TRB_DTMEDI)+"-"+TRB->TRB_HRMEDI   //Data/Hora Medi‡ao
	@Li,048 PSAY TRB->TRB_NAOCON
	@Li,058 PSAY AllTrim(Str(TRB->TRB_NUMNC))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime o Texto da Cronica.							 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QA2->(dbSeek(xFilial("QA2")+cEspecie+TRB->TRB_CHAVE))
		While QA2->(!Eof()) .And. 	QA2->QA2_FILIAL == xFilial("QA2") .And. ;
				QA2->QA2_CHAVE == TRB->TRB_CHAVE  .And. QA2->QA2_ESPEC == cEspecie
				
			If !Empty(StrTran(QA2->QA2_TEXTO, "\13\10", ""))
				@Li,064 PSAY StrTran(QA2->QA2_TEXTO, "\13\10", "")
				Li++
			EndIf
			QA2->(dbSkip())
		EndDo
	EndIf
	Li++
	TRB->(dbSkip())
EndDo

If Li != 80
	Roda(CbCont,cbtxt)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indice e o arquivo de trabalho                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTempTable:Delete()

Set device to Screen
If aReturn[5] == 1
	Set Printer To 
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GeraTrab  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 31.08.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera arquivo de Trabalho                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GeraTrab()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GeraTrab(lR4,oReport )
Local cDesc		:= ""
Local cNomArq1	:= ''
Local cCond		:= ''
Default lR4  			:= .F.
Default oReport			:= Nil

dbSelectArea("QPR")
dbSetOrder(2)

cCond := 'Dtos(QPR->QPR_DTENTR) >= "' + Dtos(mv_par01) 	+ '"'
cCond += '.And. Dtos(QPR->QPR_DTENTR) <= "' + Dtos(mv_par02) 	+ '"'
cCond += '.And. QPR->QPR_PRODUT		>= "' + mv_par03		+ '"'
cCond += '.And. QPR->QPR_PRODUT		<= "' + mv_par04		+ '"'
cCond += '.And. QPR->QPR_ENSAIO		>= "' + mv_par05		+ '"'
cCond += '.And. QPR->QPR_ENSAIO		<= "' + mv_par06		+ '"'

If lR4 
  If !Empty(AllTrim(oReport:Section(1):GetAdvplExp("QPR")))
	cCond += ".AND. "+oReport:Section(1):GetAdvplExp("QPR")
  EndIf
EndIf

cNomArq1 := CriaTrab(NIL,.F.)
IndRegua("QPR",cNomArq1,IndexKey(),,cCond,OemToAnsi(STR0011)) //"Selecionando Registros..."
nIndex := RetIndex("QPR")

dbSetOrder(nIndex+1)
dbGoTop()

If !lRelR4
	SetRegua(QPR->(RecCount()))
Endif
	
While QPR->(!Eof()) .And. xFilial("QPR") == QPR->QPR_FILIAL
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acrescenta na regua ate os registros descartados pela data e ³
	//³  revisao                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If !lRelR4
		IncRegua()
	Endif
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chave de ligacao com o QPU - Nao Conformidade das Producoes  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QPU->(dbSeek(xFilial("QPU")+QPR->QPR_CHAVE))
		While QPU->(!Eof()) .And. xFilial("QPU") == QPU->QPU_FILIAL .And. QPR->QPR_CHAVE == QPU->QPU_CODMED
			cDesc:= " "		
			If QP6->(dbSeek(xFilial("QP6")+QPR->QPR_PRODUT+Inverte(QPR->QPR_REVI)))
				cDesc := QP6->QP6_DESCPO
			EndIf
			RecLock("TRB",.T.)
			TRB->TRB_OP     := QPR->QPR_OP
			TRB->TRB_PRODUT := QPR->QPR_PRODUT
			TRB->TRB_REVI   := QPR->QPR_REVI
			TRB->TRB_DESCPO := cDesc
			TRB->TRB_DTENTR := QPR->QPR_DTENTR
			TRB->TRB_LOTE   := QPR->QPR_LOTE
			TRB->TRB_ENSAIO := QPR->QPR_ENSAIO
			TRB->TRB_DTMEDI := QPR->QPR_DTMEDI
			TRB->TRB_HRMEDI := QPR->QPR_HRMEDI
			TRB->TRB_NAOCON := QPU->QPU_NAOCON
			TRB->TRB_NUMNC  := QPU->QPU_NUMNC
			TRB->TRB_CHAVE  := QPU->QPU_CHAVE
			MsUnLock()
			QPU->(dbSkip())
		EndDo
	EndIf
	QPR->(dbSkip())
EndDo

dbSelectArea("QPR")
dbSetOrder(1)

If !lRelR4
	FErase(cNomArq1+OrdBagExt())
Endif	

Return(.T.)