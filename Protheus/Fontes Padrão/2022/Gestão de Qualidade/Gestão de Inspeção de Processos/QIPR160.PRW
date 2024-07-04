#INCLUDE "QIPR160.ch"
#Include "PROTHEUS.CH"              
#INCLUDE "Report.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QIPR160   ºAutor  ³Leandro Sabino      º Data ³  04/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relacao Das Ordens de Producao                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAQIP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                            
Function QIPR160()
Local oReport
Local cPerg     := "QPR160 "

Private  __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
Private lProduto   := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        	// Da OP                                 ³
//³ mv_par02        	// Ate a OP                              ³
//³ mv_par03        	// Do Produto                            ³
//³ mv_par04        	// Ate o Produto                         ³
//³ mv_par05        	// Da data                               ³
//³ mv_par06        	// Ate a data                            ³
//³ mv_par07        	// 1-ENCERRADAS  2-SUSPENSAS 3-TODAS     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If  TRepInUse()
	Pergunte(cPerg,.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
	Return QIPR160R3()	// Executa versão anterior do fonte
EndIf


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef()   ³ Autor ³ Leandro Sabino   ³ Data ³ 04/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montar a secao				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDef()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPR160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local cTitulo1	:= STR0001 //"Relacao das Ordens de Producao Indisponiveis"
Local cDesc1	:= STR0002 //"Este programa ira imprimir a Rela‡„o das Ordens de Produ‡„o Indisponiveis."
Local nTamOp	:= ( TamSx3("C2_NUM")[1] + TamSx3("C2_ITEM")[1] + TamSx3("C2_SEQUEN")[1] )
Local cPerg     := "QPR160 "
Local oSection1 

DEFINE REPORT oReport NAME "QIPR160" TITLE cTitulo1 PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1)
oReport:SetPortrait(.T.)

DEFINE SECTION oSection1 OF oReport TABLES "SC2"  TITLE STR0010//Ordem de Producao
DEFINE CELL NAME "OP"         OF oSection1             TITLE OemToAnsi(STR0010) SIZE nTamOp //"Ordem de Produção"
DEFINE CELL NAME "C2_PRODUTO" OF oSection1 ALIAS "SC2"  
DEFINE CELL NAME "cDESCR"     OF oSection1 ALIAS "SC2" TITLE OemToAnsi(STR0008) SIZE 20 //"Descricao"
DEFINE CELL NAME "C2_QUANT"   OF oSection1 ALIAS "SC2"  
DEFINE CELL NAME "C2_EMISSAO" OF oSection1 ALIAS "SC2"  
DEFINE CELL NAME "cStatus"    OF oSection1 ALIAS "SC2" TITLE OemToAnsi(STR0009) SIZE 10//"STATUS da OP"

Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PrintReport   ³ Autor ³ Leandro Sabino   ³ Data ³ 04/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relacao Das Ordens de Producao                       	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrintReport(ExpO1)  	     	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPR160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                  
Static Function PrintReport(oReport) 
Local oSection1	:= oReport:Section(1)
Local cAlias	:= "SC2"
Local cCond     := ""

Local cOrder := ""
Local cCondR4:= ""
                   
dbSelectArea("SC2")
dbSetOrder(1)


MakeSqlExpr(oReport:uParam)

	If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		// Sinal de concatencao nesses ambientes
		mv_par01 := StrTran( mv_par01, "C2_NUM", "C2_NUM||C2_ITEM||C2_SEQUEN" )
        Else
		mv_par01 := StrTran( mv_par01, "C2_NUM", "C2_NUM+C2_ITEM+C2_SEQUEN" )
	EndIf
	 	
    cOrder := "%C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN%"
	
	cAlias := GetNextAlias()

	BeginSQL Alias cAlias

	SELECT SC2.C2_FILIAL,SC2.C2_NUM,SC2.C2_ITEM,SC2.C2_SEQUEN,SC2.C2_PRODUTO,
	       SC2.C2_REVI,SC2.C2_ROTEIRO,SC2.C2_QUANT,SC2.C2_EMISSAO,SC2.C2_STATUS,
	       SC2.C2_DATRF,SC2.C2_QUJE,SC2.C2_PERDA
	
	FROM %table:SC2% SC2

	WHERE C2_FILIAL = %xFilial:SC2% 
	 	AND C2_NUM    >=%Exp:Substr(mv_par01,1,6)%
	 	AND C2_ITEM   >=%Exp:Substr(mv_par01,7,2)%
	    AND C2_SEQUEN >=%Exp:Substr(mv_par01,9,3)%
	
	    AND C2_NUM    <=%Exp:Substr(mv_par02,1,6)%
	    AND C2_ITEM   <=%Exp:Substr(mv_par02,7,2)%
		AND C2_SEQUEN <=%Exp:Substr(mv_par02,9,3)%
	
	 	AND C2_PRODUTO>=%Exp:mv_par03%
	 	AND C2_PRODUTO<=%Exp:mv_par04%
	
		AND C2_EMISSAO>=%Exp:Dtos(mv_par05)%
		AND C2_EMISSAO<=%Exp:Dtos(mv_par06)%
	
	    AND SC2.%notDel% 
	    
	    ORDER BY %Exp:cOrder%       
	    
	EndSql
    
		oSection1:EndQuery()
                    

oSection1:Init()

If !Empty(AllTrim(oSection1:GetSqlExp("SC2")))
	cCondR4 += oSection1:GetSqlExp("SC2")
EndIf

dbSelectArea(cAlias)
While !oReport:Cancel() .And. (cAlias)->(!Eof())	

	If !Empty(cCondR4)
		If !(cAlias)->(&(cCondR4))
			(cAlias)->(DbSkip())
			loop
		Endif
	Endif				

	
	cStatus := ""
	If mv_par07 == 1 //O.P.S ENCERRADAS
		cStatus := STR0006 //"Encerrada"
		If aSC2Sld() > 0 .And. Empty((cAlias)->C2_DATRF)
			(cAlias)->(dbSkip())
			Loop
		Endif
			
	ElseIf mv_par07	== 2 //O.P.S SUSPENSAS
		cStatus := STR0007 //"Suspensa"
		If (cAlias)->C2_STATUS <> "U"
			(cAlias)->(dbSkip())
			Loop
		Endif
	Else
		If (cAlias)->C2_STATUS == "U"
			cStatus := STR0007 //"Suspensa"
		Else
			If Empty((cAlias)->C2_DATRF)
				(cAlias)->(dbSkip())
				Loop
			EndIf	
			cStatus := STR0006 //"Encerrada"
		EndIf
	EndIf

	    
	cRevi := Iif(Empty((cAlias)->C2_REVI),Inverte(QA_UltRevEsp((cAlias)->C2_PRODUTO,,,,"QIP")),Inverte((cAlias)->C2_REVI))  
	oSection1:Cell("OP"):SetValue((cAlias)->(C2_NUM+C2_ITEM+C2_SEQUEN))
	oSection1:Cell("cDESCR"):SetValue(Posicione("QP6",1,xFilial("QP6")+(cAlias)->C2_PRODUTO+cRevi,"QP6_DESCPO")) 
	oSection1:Cell("cStatus"):SetValue(cStatus)
	oSection1:PrintLine()

	(cAlias)->(dbSkip())
	
EndDo

oSection1:Finish()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIPR160R3³ Autor ³ Marcelo Pimentel      ³ Data ³ 30.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relacao Das Ordens de Producao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ QIPR160(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function QIPR160R3()
LOCAL titulo 	:= STR0001  //"Relacao das Ordens de Producao Indisponiveis"
LOCAL cString	:= "SC2"
LOCAL wnrel		:="QIPR160"
LOCAL cDesc		:= STR0002 //"Este programa ira imprimir a Rela‡„o das Ordens de Produ‡„o Indisponiveis."
LOCAL tamanho	:= "M"
PRIVATE aReturn	:= {STR0003,1,STR0004, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE cPerg	:="QPR160 "
PRIVATE nLastKey:= 0
PRIVATE	nomeprog := "QIPR160"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("QPR160 ",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        	// Da OP                                 ³
//³ mv_par02        	// Ate a OP                              ³
//³ mv_par03        	// Do Produto                            ³
//³ mv_par04        	// Ate o Produto                         ³
//³ mv_par05        	// Da data                               ³
//³ mv_par06        	// Ate a data                            ³
//³ mv_par07        	// 1-ENCERRADAS  2-SUSPENSAS 3-TODAS     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc  ,""	 ,""	,.F.,"",,Tamanho)

If nLastKey = 27
   Set Filter To
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
   Set Filter To
   Return
Endif

RptStatus({|lEnd| R160Imp(@lEnd,wnRel,titulo,tamanho)},titulo)

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R160Imp  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 30.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relat¢rio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPR160	    	                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R160Imp(lEnd,wnRel,titulo,tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ]
LOCAL oTempTable	:= NIL
LOCAL CbTxt
LOCAL CbCont
LOCAL cabec1	:= ""
LOCAL cabec2	:= ""
LOCAL nTipo    := 0 
LOCAL aCampos	:= {}

LOCAL aTam		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

nTipo := IIF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Cabecalho                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cabec1 := "ORDEM PRODUCAO PRODUTO                        DESCRICAO                           QUANTIDADE  DT EMISSAO  STATUS DA OP"
//   	   1234567890123  123456789012345123456789012345 1234567890123456789012345678901234567890 999999999.99    99/99/9999  1234567890123 
//                  1         2         3         4         5         6         7         8         9        10        11
//         01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho  									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTam:=TamSX3("C2_NUM")		;AADD(aCampos,{"NUM"		,"C",aTam[1],aTam[2]})
aTam:=TamSX3("C2_ITEM")	    ;AADD(aCampos,{"ITEM"		,"C",aTam[1],aTam[2]})
aTam:=TamSX3("C2_SEQUEN")	;AADD(aCampos,{"SEQUEN"		,"C",aTam[1],aTam[2]})
aTam:=TamSX3("QP6_PRODUT")	;AADD(aCampos,{"PRODUTO"	,"C",aTam[1],aTam[2]})
aTam:=TamSX3("QP6_DESCPO")	;AADD(aCampos,{"DESCR"		,"C",aTam[1],aTam[2]})
aTam:=TamSX3("C2_QUANT")	;AADD(aCampos,{"QUANT"		,"N",aTam[1],aTam[2]})
aTam:=TamSX3("C2_EMISSAO")	;AADD(aCampos,{"EMISSAO"	,"D",aTam[1],aTam[2]})
aTam:=TamSX3("C2_STATUS")	;AADD(aCampos,{"STATUS"		,"C",aTam[1],aTam[2]})
aTam:=TamSX3("C2_DATRF")	;AADD(aCampos,{"DATRF"		,"D",aTam[1],aTam[2]})
							 AADD(aCampos,{"DESCSTAT"	,"C",20,0})

oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("indice1", {"NUM","ITEM","SEQUEN"} )
oTempTable:Create()

dbSelectArea("SC2")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Funcao para gerar arquivo de Trabalho			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QP160Trab()
dbSelectArea("TRB")
If BOF() .and. EOF()
	HELP(" ",1,"RECNO")
	oTempTable:Delete()
	Return .T.
Endif

TRB->(dbGoTop())
SetRegua(RecCount())
While TRB->(!Eof())
	If lEnd
		@ Prow()+1,001 PSay "CANCELADO PELO OPERADOR"
		Exit
	EndIF
	
	IF li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	EndIF
	@Li ,000 PSay TRB->NUM+TRB->ITEM+TRB->SEQUEN
	@Li ,015 PSay TRB->PRODUTO
	@Li ,046 PSay TRB->DESCR
	@Li ,080 PSay TRB->QUANT Picture PesqPictQt("C2_QUANT",15)
	@Li ,095 PSay TRB->EMISSAO
	@Li ,106 PSay TRB->DESCSTAT
	Li++
	IncRegua()
	TRB->(dbSkip())
EndDo

IF  LI != 80
	roda(cbcont,cbtxt)
EndIF

oTempTable:Delete()

If aReturn[5] = 1
   Set Printer To
   Commit
   ourspool(wnrel)
Endif

MS_FLUSH()
Return NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³QP160Trab ³ Autor ³ Marcelo Pimentel 	  	³ Data ³ 03.09.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera arquivo de Trabalho 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QP160Trab()												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QP160Trab()

Local cQuery			:= ''
Local cCond				:= ''
Local aTam				:= {}
Local cRevi				:= ''

dbSelectArea("SC2")
dbSetOrder(1)

cQuery := "SELECT C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,C2_REVI,C2_ROTEIRO,C2_QUANT,C2_EMISSAO,C2_STATUS,C2_DATRF,C2_QUJE,C2_PERDA"
cQuery += " FROM "+	RetSqlName("SC2")
cQuery += " WHERE C2_FILIAL = '" + xFilial("SC2") + "'"
cQuery += " AND C2_NUM>='"		+Substr(mv_par01,1,6) + "'"
cQuery += " AND C2_ITEM>='"		+Substr(mv_par01,7,2) + "'"
cQuery += " AND C2_SEQUEN>='"	+Substr(mv_par01,9,3) + "'"

cQuery += " AND C2_NUM<='"		+Substr(mv_par02,1,6) + "'"
cQuery += " AND C2_ITEM<='"		+Substr(mv_par02,7,2) + "'"
cQuery += " AND C2_SEQUEN<='"	+Substr(mv_par02,9,3) + "'"

cQuery += " AND C2_PRODUTO>='"  +mv_par03+"'"
cQuery += " AND C2_PRODUTO<='"  +mv_par04+"'"

cQuery += " AND C2_EMISSAO>='"  +Dtos(mv_par05)+"'"
cQuery += " AND C2_EMISSAO<='"  +Dtos(mv_par06)+"'"

cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY " + SqlOrder(SC2->(IndexKey()))

cQuery := ChangeQuery(cQuery)
dbSelectAre("SC2")
dbCloseArea()
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"SC2", .F., .T.)
aTam := TamSx3("C2_QUANT")
TcSetField( "SC2", "C2_QUANT","N",aTam[1],aTam[2])
TcSetField( "SC2", "C2_EMISSAO","D")
TcSetField( "SC2", "C2_DATRF","D")
cCond	:='!Eof()'



While &cCond

	cStatus := ""
	If mv_par07 == 1 //O.P.S ENCERRADAS
		cStatus := STR0006 //"Encerrada"
		If aSC2Sld() > 0 .And. Empty(SC2->C2_DATRF)
			dbSkip()
			Loop
		Endif	
			
	ElseIf mv_par07	== 2 //O.P.S SUSPENSAS
		cStatus := STR0007 //"Suspensa"
		If SC2->C2_STATUS <> "U"
			dbSkip()
			Loop
		Endif
	Else
		If SC2->C2_STATUS == "U"
			cStatus := STR0007 //"Suspensa"
		Else
			If Empty(SC2->C2_DATRF)
				dbSkip()
				Loop
			EndIf	
			cStatus := STR0006 //"Encerrada"
		EndIf
	EndIf
		
	RecLock("TRB",.T.)
	TRB->NUM		:= SC2->C2_NUM
	TRB->ITEM		:= SC2->C2_ITEM
	TRB->SEQUEN		:= SC2->C2_SEQUEN
	TRB->PRODUTO   	:= SC2->C2_PRODUTO
	cRevi			:= Iif(Empty(SC2->C2_REVI),Inverte(QA_UltRevEsp(SC2->C2_PRODUTO,,,,"QIP")),Inverte(SC2->C2_REVI))  
	TRB->DESCR		:= Posicione("QP6",1,xFilial("QP6")+SC2->C2_PRODUTO+cRevi,"QP6_DESCPO")
	TRB->QUANT		:= SC2->C2_QUANT
	TRB->EMISSAO	:= SC2->C2_EMISSAO
	TRB->DESCSTAT	:= cStatus
	TRB->DATRF		:= SC2->C2_DATRF
	MsUnlock()
	dbSelectArea("SC2")
	dbSkip()
EndDo

dbSelectArea("SC2")
dbCloseArea()
ChKFile("SC2")
dbSelectArea("SC2")
dbSetOrder(1)
Return .T.
