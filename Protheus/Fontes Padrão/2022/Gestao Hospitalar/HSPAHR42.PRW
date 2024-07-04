#INCLUDE "HSPAHR42.ch"
#Include "protheus.ch"
#include "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR42 บ Autor ณ Monica/Wiliam        บ Data ณ 28/08/07  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescricao ณ Faturamento Bruto por M้dicos                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR42()
/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Declaracao de Variaveis                                             ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */


Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relat๓rio "
Local cDesc2         := STR0002 //"de acordo com os parโmetros informados pelo usuแrio."
Local cDesc3         := STR0003 //"Faturamento Janeiro a Dezembro"
Local cPict          := ""
Local titulo       := STR0004 //"Faturamento Janeiro a Dezembro de "
Local nLin         := 80
Local Cabec1       := STR0005//"     %Conv๊nio" //"Conv๊nio                               Janeiro     Fevereiro        Mar็o        Abril         Maio        Junho        Julho       Agosto     Setembro      Outubro     Novembro     Dezembro  Total Conv๊nio"
Local Cabec2       := ""
// AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA    9,999,999.99  9,999,999.99 9,999,999.99 9,999,999.99 9,999,999.99 9,999,999.99 9,999,999.99 9,999,999.99 9,999,999.99 9,999,999.99 9,999,999.99 9,999,999.99  999,999,999.99  9,999,999.99
//          10        20        30        40        50        60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220
// 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
Local imprime      := .T.
Local aOrd := {}
Local CabecConv    := STR0005//"     %Conv๊nio" //"Conv๊nio                               Janeiro     Fevereiro        Mar็o        Abril         Maio        Junho        Julho       Agosto     Setembro      Outubro     Novembro     Dezembro  Total Conv๊nio"
Local CabecProf    := STR0006//"       %M้dico" //"M้dico                                 Janeiro     Fevereiro        Mar็o        Abril         Maio        Junho        Julho       Agosto     Setembro      Outubro     Novembro     Dezembro    Total M้dico"
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite           := 220
Private tamanho          := "G"
Private nomeprog         := "HSPAHR42" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo            := 18
Private aReturn          := { STR0007, 1, STR0008, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey        := 0
Private cPerg        := "HSPR42"
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private cString := "GAT"
Private wnrel        := "HSPAHR42" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao
Private oTempTRB

If !Pergunte(cPerg,.T.)
	return
EndIf

cFilTab   := MV_PAR01 //"Filial ?                      "
cAnoRef   := MV_PAR02 //"Ano para emissใo ?            "
nTpoRel   := MV_PAR03 //"Tipo do relat๓rio ?           " CONVENIO OU MEDICO
nPartic   := MV_PAR04 //"Emitir % de participa็ใo ?    "
nCresc    := MV_PAR05 //"Emitir % de crescimento ?     "
nConsRec  := MV_PAR06 //"Considerar recebido ?         "
nConsRep  := MV_PAR07 //"Considerar repasse ?          "

if nTpoRel == 1
	Cabec1 := CabecConv
	if (nPartic == 2) .and. (nCresc == 2)
		Cabec1 :=  alltrim(Cabec1) + STR0009 //"     %Conv๊nio"
		titulo := alltrim(titulo) + " " + cAnoRef + STR0010 //" por Conv๊nio"
	else
		Cabec1 :=  alltrim(Cabec1) + STR0011 //"         M้dia"
		titulo := STR0012 + cAnoRef //"Planilha do Crescimento dos Conv๊nios em "
	endif
else
	Cabec1 := CabecProf
	if (nPartic == 2) .and. (nCresc == 2)
		Cabec1 :=  alltrim(Cabec1) + STR0013 //"       %M้dico"
		titulo := alltrim(titulo) + " " + cAnoRef + STR0014 //" por M้dico"
	else
		Cabec1 :=  alltrim(Cabec1) + STR0011 //"         M้dia"
		titulo := STR0015 + cAnoRef //"Planilha do Crescimento dos M้dicos em "
	endif
endif

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)


RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Monica/Wiliam      บ Data ณ  28/08/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local cSQL 	   := ""
Local nRegistro:= 0
Local cArqTmp:=""
Local aVRMes     := array(12) // Valor do mes por linha
Local aTotMesFil := array(12) // Total por mes/filial
Local aMesVlTt   := array(12) // Total do m๊s total
Local	cFilialTmp := ""
Local	cCodigo    := ""
Local	cNome      := ""
Local nVRTotal   := 0 // Total da Linha
Local nQtMeses   := 0 // Para media
Local i          := 0
Local nVltotal	  := 0 // Total por filial
Local nVltotalG	 := 0 // Total Geral
afill(aMesVlTt,0)
afill(aTotMesFil,0)

// Local aCampos:= array(5,4)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Tabela Temporแria de Trabalho ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCampos:={	{"FILIAL"   , "C" , FWGETTAMFILIAL,0},;
{"NOME"     , "C" , 040,0},;
{"CODIGO"   , "C" , 006,0},;
{"MESREF"   , "C" , 005,0},;
{"VALOR"    , "N" , 012,2}}

//--< Cria็ใo do objeto FWTemporaryTable >---
oTempTRB := FWTemporaryTable():New( "cArqTmp" )
oTempTRB:SetFields( aCampos )
oTempTRB:AddIndex( "INDTRB",{ "FILIAL","CODIGO","MESREF" } )

if( select( "cArqTmp" ) > 0 )
	cArqTmp->( dbCloseArea() )
endIf

oTempTRB:Create()

DbSelectArea("SM0")
If !Empty(cFilTab)
	nRegistro := Recno()
	DbGoTop()
endif
While !eof()
	
	// Query dividida por "Union" para otimiza็ใo
	cSQL 	   := ""
	cSQL +="SELECT"
	If nTpoRel == 1 // Se for Conv๊nio
		cSQL +="		GA9.GA9_NREDUZ NOME,"
		cSQL +="		GCZ.GCZ_CODCON CODIGO, "
	Else // Se for M้dico
		cSQL +="		SRA.RA_NOME NOME,	"
		cSQL +="		SRA.RA_CODIGO CODIGO,	"
	Endif
	cSQL +="		GAT.GAT_MESREF MESREF, "
	If nConsRep == 2
		If nConsRec <> 1
			cSQL +="		SUM(((GE7.GE7_VALDES * GE7.GE7_COEFAM) * GE7.GE7_QTDDES)- GE7.GE7_VALREP) "
		Else
			cSQL +="		SUM(GF7.GF7_VALAPR - GE7.GE7_VALREP) "
		Endif
	Else
		If nConsRec <> 1
			cSQL +="		SUM((GE7.GE7_VALDES * GE7.GE7_COEFAM) * GE7.GE7_QTDDES) "
		Else
			cSQL +="		SUM(GF7.GF7_VALAPR) "
		EndIf
	Endif
	cSQL +="		VALOR "
	cSQL +="FROM	"
	cSQL +=RetSQLName("GAT") + " GAT "
	cSQL +=" JOIN "
	cSQL +=RetSQLName("GCZ") + " GCZ ON  GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE 	AND	GCZ.GCZ_STATUS >= '4' AND GCZ.D_E_L_E_T_ <> '*'"
	If !Empty(cFilTab)
		cSQL += " AND GCZ.GCZ_FILIAL = '" + IIF(Empty(xFilial("GCZ")), xFilial("GCZ"), cFilTab)  + "' "
	Else
		cSQL += " AND GCZ.GCZ_FILIAL = '" + IIF(Empty(xFilial("GCZ")), xFilial("GCZ"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
	Endif
	cSQL +=" JOIN "
	cSQL +=RetSQLName("GE7") + " GE7 ON GCZ.GCZ_NRSEQG = GE7.GE7_NRSEQG  AND GE7.D_E_L_E_T_ <> '*'"
	If !Empty(cFilTab)
		cSQL += " AND GE7.GE7_FILIAL = '" + IIF(Empty(xFilial("GE7")), xFilial("GE7"), cFilTab)  + "' "
	Else
		cSQL += " AND GE7.GE7_FILIAL = '" + IIF(Empty(xFilial("GE7")), xFilial("GE7"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
	Endif
	If nTpoRel == 1 // Se for Conv๊nio
		cSQL +=" JOIN "
		cSQL +=RetSQLName("GA9") + " GA9 ON GAT.GAT_CODCON = GA9.GA9_CODCON AND GA9.D_E_L_E_T_ <> '*'"
		If !Empty(cFilTab)
			cSQL += " AND GA9.GA9_FILIAL = '" + IIF(Empty(xFilial("GA9")), xFilial("GA9"), cFilTab)  + "' "
		Else
			cSQL += " AND GA9.GA9_FILIAL = '" + IIF(Empty(xFilial("GA9")), xFilial("GA9"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
		Endif
	Else // Se for M้dico
		cSQL +=" JOIN "
		cSQL +=RetSQLName("SRA") + " SRA ON GE7.GE7_CODCRM = SRA.RA_CODIGO  AND SRA.D_E_L_E_T_ <> '*'"
		If !Empty(cFilTab)
			cSQL += " AND SRA.RA_FILIAL = '" + IIF(Empty(xFilial("SRA")), xFilial("SRA"), cFilTab)  + "' "
		Else
			cSQL += " AND SRA.RA_FILIAL = '" + IIF(Empty(xFilial("SRA")), xFilial("SRA"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
		Endif
	Endif
	If nConsRec == 1// Se Considerar Recebido
		cSQL +=" JOIN "
		cSQL +=RetSQLName("GF7") + " GF7 ON GF7.GF7_NREXTC = GCZ.GCZ_NREXTC AND GCZ.GCZ_NRSEQG = GF7.GF7_NRSEQG AND GF7.D_E_L_E_T_ <> '*'"

		// Estas instru็๕es somente selecionam registros que estใo faturados e recebidos
		// Sequencia da despesa e codigo do procedimento 
 	cSQL +=  " AND GE7.GE7_SEQDES = GF7.GF7_SEQDES AND	LTRIM(GE7.GE7_CODDES) = LTRIM(GF7.GF7_CODDES) " 

		If !Empty(cFilTab)
			cSQL += " AND GF7.GF7_FILIAL = '" + IIF(Empty(xFilial("GF7")), xFilial("GF7"), cFilTab)  + "' "
		Else
			cSQL += " AND GF7.GF7_FILIAL = '" + IIF(Empty(xFilial("GF7")), xFilial("GF7"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
		Endif
	Endif
	cSQL +=" WHERE	"
	cSQL +="			   "+Iif(TcGetDb() == "MSSQL", "SUBSTRING","SUBSTR")+"(GAT.GAT_MESREF,4,2) = '"+Substr(cAnoRef,3,2)+"' AND GAT.D_E_L_E_T_ <> '*'"
//	cSQL += " AND GAT.GAT_NUMLOT = '000029' "
	If !Empty(cFilTab)
		cSQL += " AND GAT.GAT_FILIAL = '" + IIF(Empty(xFilial("GAT")), xFilial("GAT"), cFilTab)  + "' "
	Else
		cSQL += " AND GAT.GAT_FILIAL = '" + IIF(Empty(xFilial("GAT")), xFilial("GAT"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
	Endif
	cSQL +=" GROUP BY"
	cSQL +="		GAT.GAT_MESREF,"
	If nTpoRel == 1 // Se for Conv๊nio
		cSQL +="		GA9.GA9_NREDUZ, "
		cSQL +="		GCZ.GCZ_CODCON "
	Else
		cSQL +="		SRA.RA_NOME,	"
		cSQL +="		SRA.RA_CODIGO	"
	Endif
	If nTpoRel == 1 // Se for Conv๊nio
		
		// ********* UNION 1
		cSQL +="UNION ALL "
		// ******************
		
		cSQL +="	SELECT"
		cSQL +="		GA9.GA9_NREDUZ NOME,"
		cSQL +="		GCZ.GCZ_CODCON CODIGO, "
		cSQL +="		GAT.GAT_MESREF MESREF, "
		If nConsRec <> 1
			cSQL +="		SUM(GE5.GE5_VALDES * GE5.GE5_QTDDES) "
		Else
			cSQL +="		SUM(GF5.GF5_VALAPR) "
		Endif
		cSQL +="		VALOR "
		cSQL +="FROM	"
		cSQL +=RetSQLName("GAT") + " GAT "
		cSQL +=" JOIN "
		cSQL +=RetSQLName("GCZ") + " GCZ ON  GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE 	AND	GCZ.GCZ_STATUS >= '4' AND GCZ.D_E_L_E_T_ <> '*'"
		If !Empty(cFilTab)
			cSQL += " AND GCZ.GCZ_FILIAL = '" + IIF(Empty(xFilial("GCZ")), xFilial("GCZ"), cFilTab)  + "' "
		Else
			cSQL += " AND GCZ.GCZ_FILIAL = '" + IIF(Empty(xFilial("GCZ")), xFilial("GCZ"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
		Endif
		cSQL +=" JOIN "
		cSQL +=RetSQLName("GA9") + " GA9 ON GAT.GAT_CODCON = GA9.GA9_CODCON AND GA9.D_E_L_E_T_ <> '*'"
		If !Empty(cFilTab)
			cSQL += " AND GA9.GA9_FILIAL = '" + IIF(Empty(xFilial("GA9")), xFilial("GA9"), cFilTab)  + "' "
		Else
			cSQL += " AND GA9.GA9_FILIAL = '" + IIF(Empty(xFilial("GA9")), xFilial("GA9"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
		Endif
		If nConsRec == 1 // Se Considerar Recebido
			cSQL +=" JOIN "
			cSQL +=RetSQLName("GF5") + " GF5 ON GCZ.GCZ_NRSEQG = GF5.GF5_NRSEQG AND GF5.D_E_L_E_T_ <> '*'"
			If !Empty(cFilTab)
				cSQL += " AND GF5.GF5_FILIAL = '" + IIF(Empty(xFilial("GF5")), xFilial("GF5"), cFilTab)  + "' "
			Else
				cSQL += " AND GF5.GF5_FILIAL = '" + IIF(Empty(xFilial("GF5")), xFilial("GF5"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
			Endif
		Else
			cSQL +=" JOIN "
			cSQL +=RetSQLName("GE5") + " 	GE5 ON GCZ.GCZ_NRSEQG = GE5.GE5_NRSEQG  AND GE5.D_E_L_E_T_ <> '*'"
			If !Empty(cFilTab)
				cSQL += " AND GE5.GE5_FILIAL = '" + IIF(Empty(xFilial("GE5")), xFilial("GE5"), cFilTab)  + "' "
			Else
				cSQL += " AND GE5.GE5_FILIAL = '" + IIF(Empty(xFilial("GE5")), xFilial("GE5"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
			Endif
		Endif
		cSQL +=" WHERE	"
		cSQL +="			   "+Iif(TcGetDb() == "MSSQL", "SUBSTRING","SUBSTR")+"(GAT.GAT_MESREF,4,2) = '"+Substr(cAnoRef,3,2)+"' AND GAT.D_E_L_E_T_ <> '*'"
	 //cSQL += " AND GAT.GAT_NUMLOT = '000029' "
		If !Empty(cFilTab)
			cSQL += " AND GAT.GAT_FILIAL = '" + IIF(Empty(xFilial("GAT")), xFilial("GAT"), cFilTab)  + "' "
		Else
			cSQL += " AND GAT.GAT_FILIAL = '" + IIF(Empty(xFilial("GAT")), xFilial("GAT"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
		Endif
		cSQL +=" GROUP BY"
		cSQL +="		GAT.GAT_MESREF,"
		cSQL +="		GA9.GA9_NREDUZ, "
		cSQL +="		GCZ.GCZ_CODCON "
		
		// ********* UNION 2
		cSQL +="UNION ALL "
		// ******************
		
		cSQL +="	SELECT"
		cSQL +="		GA9.GA9_NREDUZ NOME,"
		cSQL +="		GCZ.GCZ_CODCON CODIGO, "
		cSQL +="		GAT.GAT_MESREF MESREF, "
		If nConsRec <> 1
			cSQL +="		SUM(GE6.GE6_VALDES * GE6.GE6_QTDDES) "
		Else
			cSQL +="		SUM(GF6.GF6_VALAPR) "
		Endif
		cSQL +="		VALOR "
		cSQL +="FROM	"
		cSQL +=RetSQLName("GAT") + " GAT "
		cSQL +=" JOIN "
		cSQL +=RetSQLName("GCZ") + " GCZ ON  GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE 	AND	GCZ.GCZ_STATUS >= '4' AND GCZ.D_E_L_E_T_ <> '*'"
		If !Empty(cFilTab)
			cSQL += " AND GCZ.GCZ_FILIAL = '" + IIF(Empty(xFilial("GCZ")), xFilial("GCZ"), cFilTab)  + "' "
		Else
			cSQL += " AND GCZ.GCZ_FILIAL = '" + IIF(Empty(xFilial("GCZ")), xFilial("GCZ"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
		Endif
		cSQL +=" JOIN "
		cSQL +=RetSQLName("GA9") + " GA9 ON GAT.GAT_CODCON = GA9.GA9_CODCON AND GA9.D_E_L_E_T_ <> '*'"
		If !Empty(cFilTab)
			cSQL += " AND GA9.GA9_FILIAL = '" + IIF(Empty(xFilial("GA9")), xFilial("GA9"), cFilTab)  + "' "
		Else
			cSQL += " AND GA9.GA9_FILIAL = '" + IIF(Empty(xFilial("GA9")), xFilial("GA9"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
		Endif
		If nConsRec == 1 // Se Considerar Recebido
			cSQL +=" JOIN "
			cSQL +=RetSQLName("GF6") + " GF6 ON GCZ.GCZ_NRSEQG = GF6.GF6_NRSEQG AND GF6.D_E_L_E_T_ <> '*'"
			If !Empty(cFilTab)
				cSQL += " AND GF6.GF6_FILIAL = '" + IIF(Empty(xFilial("GF6")), xFilial("GF6"), cFilTab)  + "' "
			Else
				cSQL += " AND GF6.GF6_FILIAL = '" + IIF(Empty(xFilial("GF6")), xFilial("GF6"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
			Endif
		Else
			cSQL +=" JOIN "
			cSQL +=RetSQLName("GE6") + " 	GE6 ON GCZ.GCZ_NRSEQG = GE6.GE6_NRSEQG  AND GE6.D_E_L_E_T_ <> '*'"
			If !Empty(cFilTab)
				cSQL += " AND GE6.GE6_FILIAL = '" + IIF(Empty(xFilial("GE6")), xFilial("GE6"), cFilTab)  + "' "
			Else
				cSQL += " AND GE6.GE6_FILIAL = '" + IIF(Empty(xFilial("GE6")), xFilial("GE6"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
			Endif
		Endif
		cSQL +=" WHERE	"
		cSQL +="			   "+Iif(TcGetDb() == "MSSQL", "SUBSTRING","SUBSTR")+"(GAT.GAT_MESREF,4,2) = '"+Substr(cAnoRef,3,2)+"' AND GAT.D_E_L_E_T_ <> '*'"
	 //cSQL += " AND GAT.GAT_NUMLOT = '000029' "
		If !Empty(cFilTab)
			cSQL += " AND GAT.GAT_FILIAL = '" + IIF(Empty(xFilial("GAT")), xFilial("GAT"), cFilTab)  + "' "
		Else
			cSQL += " AND GAT.GAT_FILIAL = '" + IIF(Empty(xFilial("GAT")), xFilial("GAT"), IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))  + "' "
		Endif
		cSQL +=" GROUP BY"
		cSQL +="		GAT.GAT_MESREF,"
		cSQL +="		GA9.GA9_NREDUZ, "
		cSQL +="		GCZ.GCZ_CODCON "
	Endif // FIM DO UNION
	cSQL +=" ORDER BY NOME,CODIGO "
	
	cSQL :=  ChangeQuery(cSQL)
 // HS_MsgInf(cSQL)
	TCQUERY cSQL NEW ALIAS "QRY"
	DbSelectArea("QRY")
	DbGoTop()
	// Preenche o arquivo temporario com os dados da filial
	While !EOF()
		DbSelectArea("cArqTmp")
		RecLock("cArqTmp",.T.)
		cArqTmp->FILIAL   := IIF(!Empty(cFilTab), cFilTab, IIF(FindFunction("FWCodFil"),FWGETCODFILIAL,SM0->M0_CODFIL))
		cArqTmp->NOME     := 	QRY->NOME
		cArqTmp->CODIGO   := 	QRY->CODIGO
		cArqTmp->MESREF   := 	QRY->MESREF
		cArqTmp->VALOR    := 	QRY->VALOR
		MSUNLOCK()
		aMesVlTt[val(substr(cArqTmp->MESREF,1,2))] += cArqTmp->valor
		DbSelectArea("QRY")
		DbSkip()
	End
	QRY->(DbCloseArea())
	If !Empty(cFilTab)
		Exit // Sai se for selecionada a filial
	Endif
	DbSelectArea("SM0")
	dbSkip() /* Avanca o ponteiro do registro no arquivo */
End

// Recupera posi็ใo do registro de Filial
DbSelectArea("SM0")
If !Empty(cFilTab)
	DbGoTo(nRegistro)
endif

// Imprime relatorio

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

SetRegua(100)

dbSelectArea("cArqTmp")   
dbgotop()
// pega o total da filial     
nVltotal := 0
cFilialTmp := cArqTmp->FILIAL
While cFilialTmp == cArqTmp->FILIAL .AND. !EOF()
	nVltotal += cArqTmp->valor
	dbSkip() /* Avanca o ponteiro do registro no arquivo */
End        
nVltotalG :=nVltotal
dbgotop()

While !EOF()
	
	IncRegua()
	
	If lAbortPrint
		@nLin,00 PSAY STR0017 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If nLin > nMaxLin
		Cabec(Titulo+" (Filial: "+cArqTmp->FILIAL+") ",Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif
	
	cCodigo := cArqTmp->CODIGO
	cNome   := cArqTmp->NOME
	afill(aVRMes,0)
	nVRTotal := 0
	// Acumula o total por mes/nome
	While 	cCodigo == cArqTmp->CODIGO .AND. cFilialTmp == cArqTmp->FILIAL .AND. !EOF()
		aVRMes[val(substr(cArqTmp->MESREF,1,2))] += cArqTmp->valor
		nVRTotal += cArqTmp->valor
		dbSkip() /* Avanca o ponteiro do registro no arquivo */
	End
	nQtMeses := 0
	For i = 1 to 12
		nQtMeses += Iif(aVRMes[i] > 0, 1,0)
	Next
	@nLin,000 PSAY Substr(cNome,1,30)
	@nLin,034 PSAY aVRMes[01] Picture("@E 9,999,999.99")
	@nLin,048 PSAY aVRMes[02] Picture("@E 9,999,999.99")
	@nLin,061 PSAY aVRMes[03] Picture("@E 9,999,999.99")
	@nLin,074 PSAY aVRMes[04] Picture("@E 9,999,999.99")
	@nLin,087 PSAY aVRMes[05] Picture("@E 9,999,999.99")
	@nLin,100 PSAY aVRMes[06] Picture("@E 9,999,999.99")
	@nLin,113 PSAY aVRMes[07] Picture("@E 9,999,999.99")
	@nLin,126 PSAY aVRMes[08] Picture("@E 9,999,999.99")
	@nLin,139 PSAY aVRMes[09] Picture("@E 9,999,999.99")
	@nLin,152 PSAY aVRMes[10] Picture("@E 9,999,999.99")
	@nLin,165 PSAY aVRMes[11] Picture("@E 9,999,999.99")
	@nLin,178 PSAY aVRMes[12] Picture("@E 9,999,999.99")
	@nLin,192 PSAY nVRTotal   Picture("@E 999,999,999.99")

 For i = 1 to 12
		aTotMesFil[i] += aVRMes[i] // Total por m๊s 
	Next

	if (nPartic == 2) .and. (nCresc == 2)
			@nLin,208 PSAY iif(nVltotal <> 0,(nVRTotal / nVltotal) * 100,0) Picture("@E 9,999,999.99")
	else
		@nLin,208 PSAY (nVRTotal / nQtMeses) Picture("@E 9,999,999.99")
		if (nPartic == 1)
			nLin := nLin + 1
			@nLin,000 PSAY STR0018 //"% Participa็ใo"
			@nLin,034 PSAY iif(aMesVlTt[01] > 0,(aVRMes[01] / aMesVlTt[01])* 100,0) Picture("@E 9,999,999.99")
			@nLin,048 PSAY iif(aMesVlTt[02] > 0,(aVRMes[02] / aMesVlTt[02])* 100,0) Picture("@E 9,999,999.99")
			@nLin,061 PSAY iif(aMesVlTt[03] > 0,(aVRMes[03] / aMesVlTt[03])* 100,0) Picture("@E 9,999,999.99")
			@nLin,074 PSAY iif(aMesVlTt[04] > 0,(aVRMes[04] / aMesVlTt[04])* 100,0) Picture("@E 9,999,999.99")
			@nLin,087 PSAY iif(aMesVlTt[05] > 0,(aVRMes[05] / aMesVlTt[05])* 100,0) Picture("@E 9,999,999.99")
			@nLin,100 PSAY iif(aMesVlTt[06] > 0,(aVRMes[06] / aMesVlTt[06])* 100,0) Picture("@E 9,999,999.99")
			@nLin,113 PSAY iif(aMesVlTt[07] > 0,(aVRMes[07] / aMesVlTt[07])* 100,0) Picture("@E 9,999,999.99")
			@nLin,126 PSAY iif(aMesVlTt[08] > 0,(aVRMes[08] / aMesVlTt[08])* 100,0) Picture("@E 9,999,999.99")
			@nLin,139 PSAY iif(aMesVlTt[09] > 0,(aVRMes[09] / aMesVlTt[09])* 100,0) Picture("@E 9,999,999.99")
			@nLin,152 PSAY iif(aMesVlTt[10] > 0,(aVRMes[10] / aMesVlTt[10])* 100,0) Picture("@E 9,999,999.99")
			@nLin,165 PSAY iif(aMesVlTt[11] > 0,(aVRMes[11] / aMesVlTt[11])* 100,0) Picture("@E 9,999,999.99")
			@nLin,178 PSAY iif(aMesVlTt[12] > 0,(aVRMes[12] / aMesVlTt[12])* 100,0) Picture("@E 9,999,999.99")
			@nLin,192 PSAY (nVRTotal / ;
			(aMesVlTt[01] + aMesVlTt[02] + aMesVlTt[03] + aMesVlTt[04] + aMesVlTt[05] + aMesVlTt[06] + aMesVlTt[07] + ;
			aMesVlTt[08] + aMesVlTt[09] + aMesVlTt[10] + aMesVlTt[11] + aMesVlTt[12]) * 100) Picture("@E 999,999,999.99")
		endif
		if (nCresc == 1)
			nLin := nLin + 1
			@nLin,000 PSAY STR0019 //"% Crescimento"
			@nLin,034 PSAY 0 Picture("@E 9,999,999.99")
			i := 2
			@nLin,048 PSAY iif( aVRMes[i] > 0,iif(aVRMes[i-1] > 0,(((aVRMes[i]/aVRMes[i-1])*100)-100),100),0) Picture("@E 9,999,999.99")
			i ++
			@nLin,061 PSAY iif( aVRMes[i] > 0,iif(aVRMes[i-1] > 0,(((aVRMes[i]/aVRMes[i-1])*100)-100),100),0) Picture("@E 9,999,999.99")
			i ++
			@nLin,074 PSAY iif( aVRMes[i] > 0,iif(aVRMes[i-1] > 0,(((aVRMes[i]/aVRMes[i-1])*100)-100),100),0) Picture("@E 9,999,999.99")
			i ++
			@nLin,087 PSAY iif( aVRMes[i] > 0,iif(aVRMes[i-1] > 0,(((aVRMes[i]/aVRMes[i-1])*100)-100),100),0) Picture("@E 9,999,999.99")
			i ++
			@nLin,100 PSAY iif( aVRMes[i] > 0,iif(aVRMes[i-1] > 0,(((aVRMes[i]/aVRMes[i-1])*100)-100),100),0) Picture("@E 9,999,999.99")
			i ++
			@nLin,113 PSAY iif( aVRMes[i] > 0,iif(aVRMes[i-1] > 0,(((aVRMes[i]/aVRMes[i-1])*100)-100),100),0) Picture("@E 9,999,999.99")
			i ++
			@nLin,126 PSAY iif( aVRMes[i] > 0,iif(aVRMes[i-1] > 0,(((aVRMes[i]/aVRMes[i-1])*100)-100),100),0) Picture("@E 9,999,999.99")
			i ++
			@nLin,139 PSAY iif( aVRMes[i] > 0,iif(aVRMes[i-1] > 0,(((aVRMes[i]/aVRMes[i-1])*100)-100),100),0) Picture("@E 9,999,999.99")
			i ++
			@nLin,152 PSAY iif( aVRMes[i] > 0,iif(aVRMes[i-1] > 0,(((aVRMes[i]/aVRMes[i-1])*100)-100),100),0) Picture("@E 9,999,999.99")
			i ++
			@nLin,165 PSAY iif( aVRMes[i] > 0,iif(aVRMes[i-1] > 0,(((aVRMes[i]/aVRMes[i-1])*100)-100),100),0) Picture("@E 9,999,999.99")
			i ++
			@nLin,178 PSAY iif( aVRMes[i] > 0,iif(aVRMes[i-1] > 0,(((aVRMes[i]/aVRMes[i-1])*100)-100),100),0) Picture("@E 9,999,999.99")
			i ++
		endif
	endif
	nLin++
	
	if cFilialTmp <> cArqTmp->FILIAL
		@nLin,000 PSAY replicate("-",220)
		nLin++
		@nLin,000 PSAY STR0020 //"Total Mensal"
		@nLin,034 PSAY aTotMesFil[01] Picture("@E 9,999,999.99")
		@nLin,048 PSAY aTotMesFil[02] Picture("@E 9,999,999.99")
		@nLin,061 PSAY aTotMesFil[03] Picture("@E 9,999,999.99")
		@nLin,074 PSAY aTotMesFil[04] Picture("@E 9,999,999.99")
		@nLin,087 PSAY aTotMesFil[05] Picture("@E 9,999,999.99")
		@nLin,100 PSAY aTotMesFil[06] Picture("@E 9,999,999.99")
		@nLin,113 PSAY aTotMesFil[07] Picture("@E 9,999,999.99")
		@nLin,126 PSAY aTotMesFil[08] Picture("@E 9,999,999.99")
		@nLin,139 PSAY aTotMesFil[09] Picture("@E 9,999,999.99")
		@nLin,152 PSAY aTotMesFil[10] Picture("@E 9,999,999.99")
		@nLin,165 PSAY aTotMesFil[11] Picture("@E 9,999,999.99")
		@nLin,178 PSAY aTotMesFil[12] Picture("@E 9,999,999.99")
		@nLin,192 PSAY nVltotal       Picture("@E 999,999,999.99")
		afill(aTotMesFil,0)
		if !EOF()
			nLin := nMaxLin	+ 1 // Obriga saltar pแgina
			// pega o total da filial     
			nRegistro := Recno()
			nVltotal := 0
			cFilialTmp := cArqTmp->FILIAL
			dbgotop()
			While cFilialTmp == cArqTmp->FILIAL .AND. !EOF()
				nVltotal += cArqTmp->valor
				dbSkip() /* Avanca o ponteiro do registro no arquivo */
			End
			nVltotalG +=nVltotal
			nRegistro := Recno()
		Endif
	Endif
	
End   
If Empty(cFilTab)
	nLin++
	@nLin,000 PSAY replicate("-",220)
	nLin++
	@nLin,000 PSAY STR0021 //"Total Geral"
	@nLin,034 PSAY aMesVlTt[01] Picture("@E 9,999,999.99")
	@nLin,048 PSAY aMesVlTt[02] Picture("@E 9,999,999.99")
	@nLin,061 PSAY aMesVlTt[03] Picture("@E 9,999,999.99")
	@nLin,074 PSAY aMesVlTt[04] Picture("@E 9,999,999.99")
	@nLin,087 PSAY aMesVlTt[05] Picture("@E 9,999,999.99")
	@nLin,100 PSAY aMesVlTt[06] Picture("@E 9,999,999.99")
	@nLin,113 PSAY aMesVlTt[07] Picture("@E 9,999,999.99")
	@nLin,126 PSAY aMesVlTt[08] Picture("@E 9,999,999.99")
	@nLin,139 PSAY aMesVlTt[09] Picture("@E 9,999,999.99")
	@nLin,152 PSAY aMesVlTt[10] Picture("@E 9,999,999.99")
	@nLin,165 PSAY aMesVlTt[11] Picture("@E 9,999,999.99")
	@nLin,178 PSAY aMesVlTt[12] Picture("@E 9,999,999.99")
	@nLin,192 PSAY nVltotalG    Picture("@E 999,999,999.99")
	nLin++
	@nLin,000 PSAY replicate("-",220)
Endif
	
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Finaliza a execucao do relatorio...                                 ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

SET DEVICE TO SCREEN

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

if( select( "cArqTmp" ) > 0 )
 	oTempTRB:Delete()
endIf

Return

