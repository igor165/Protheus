#INCLUDE "HSPAHR35.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#INCLUDE "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHR35  º Autor ³ AP6 IDE            º Data ³  28/10/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Posição de Produção e Glosa.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHR35()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0003 //"Posição de Produção e Glosas"
Local cPict          := ""
Local imprime      := .T.
Local aOrd := {}

Private titulo       := STR0004 //"Posição de Produção e Glosas "

Private Cabec1       := STR0005 //"Procedimento"
Private Cabec2       := STR0006 //"Paciente                       Guia                 Data Aten. Cd.Atd    Vl.Fatura %Repa.   Vl.Repasse     Vl.Glosa    Vl.Liquido St"
//Paciente                       Guia                 Data Aten. Cd.Atd    Vl.Fatura %Repa.   Vl.Repasse     Vl.Glosa    Vl.Liquido St
//012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//         10        20        30        40        50        60        70        80        90       100       110       120       130
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 99999999999999999999 99/99/9999 999999 9.999.999,99 999,99 9.999.999,99   999.999,99    999.999,99 AA
//                                                                     99.999.999,99       99.999.999,99 9.999.999,99  9.999.999,99
Private nLin         := 80
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite           := 132
Private tamanho          := "M"
Private nomeprog         := "HSPAHR35" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { STR0007, 1, STR0008, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey        := 0
Private cPerg       := "HSPR35"
Private CbTxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "HSPAHR35" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "GE7"

dbSelectArea("GE7")
dbSetOrder(1)

dbSelectArea("GMC")
dbSetOrder(1)

if !Pergunte(cPerg, .T.)
	Return
endif

if MV_PAR14 == 1
	titulo := titulo + STR0009 //"- Analítico "
else
	titulo := titulo + STR0010 //"- Sintético "
endif

if MV_PAR13 == 2
	titulo := titulo + STR0011 //"(Faturados)"
elseif MV_PAR13 == 3
	titulo := titulo + STR0012 //"(Ext.Conv.)"
elseif MV_PAR13 == 4
	titulo := titulo + STR0013 //"(Ext.Prof)"
elseif MV_PAR13 == 5
	titulo := titulo + STR0014 //"(Quitados)"
endif

if MV_PAR14 == 2
	Cabec1       := STR0015 //"Convênio"
	Cabec2       := STR0016 //"Procedimento                                                             Vl.Fatura          Vl.Repasse     Vl.Glosa    Vl.Liquido   "
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

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
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  22/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local cSQL := ""
Local nVlFatSit := {}
Local nVlRepSit := {}
Local nVlGloSit := {}
Local nVlLiqSit := {}
Local nVlGFatSit := {}
Local nVlGRepSit := {}
Local nVlGGloSit := {}
Local nVlGLiqSit := {}

Private nQtAto,nQtMed,nQtCon,nQtPro,nQtGer := 0
Private nVlDesAto,nVlDesMed,nVlDesCon,nVlDesPro := 0
Private nVlRepAto,nVlRepMed,nVlRepCon,nVlRepPro := 0
Private nVlGloAto,nVlGloMed,nVlGloCon,nVlGloPro := 0
Private nVlLiqAto,nVlLiqMed,nVlLiqCon,nVlLiqPro := 0
Private nVlDesGer,nVlRepGer,nVlGloGer,nVlLiqGer := 0
Private cMed,cCon,cPro,cAto := ""
Private cSituacao := ""
Private cTotalizaAto := "N"
Private nVlLiqRep := 0
Private nVlCoefCH := 0

ASize( nVlFatSit, 4 )
ASize( nVlRepSit, 4 )
ASize( nVlGloSit, 4 )
ASize( nVlLiqSit, 4 )
ASize( nVlGFatSit, 4 )
ASize( nVlGRepSit, 4 )
ASize( nVlGGloSit, 4 )
ASize( nVlGLiqSit, 4 )
 
afill(nVlFatSit,0)
afill(nVlRepSit,0)
afill(nVlGloSit,0)
afill(nVlLiqSit,0)
afill(nVlGFatSit,0)
afill(nVlGRepSit,0)
afill(nVlGGloSit,0)
afill(nVlGLiqSit,0)


dbSelectArea(cString)
dbSetOrder(1)

cSQL := "SELECT SRA.RA_NOME NOMEF,"
cSQL += "       SRA.RA_CODIGO CODIGO,"
cSQL += "       GA9.GA9_NREDUZ NREDUZ,"
cSQL += "       GA9.GA9_CODCON CODCON,"
cSQL += " 		 GA7.GA7_DESC DESCRICAO,"
cSQL += " 		 GA7.GA7_CODPRO CODPRO,"
cSQL += " 		 GCY.GCY_NOME NOMEPAC,"
cSQL += " 		 GCZ.GCZ_NRGUIA NRGUIA,"
cSQL += " 		 GCY.GCY_DATATE DATATE,"
cSQL += " 		 GCY.GCY_REGATE REGATE,"
cSQL += HS_FVALDES("GE7") + " VALDES,"
cSQL += " 	  GE7.GE7_VALREP VALREP,"
cSQL += " 		 GE7.GE7_VLRGLO VLRGLO,"
cSQL += " 		 GE7.GE7_REPAMB REPAMB,"
cSQL += " 		 GE7.GE7_COECHP COECHP,"
cSQL += " 		 GE7.GE7_NREXTM NREXTM,"
cSQL += " 		 GE7.GE7_NREXTC NREXTC,"
cSQL += " 		 GE7.GE7_CODATO CODATO,"
cSQL += " 		 SE2.E2_BAIXA BAIXA"
cSQL += " FROM "+ RetSQLName("GE7") + " GE7"
cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO = GE7.GE7_CODCRM AND SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GE7.GE7_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRLOTE BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GE7.GE7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*'"
cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GE7.GE7_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' AND GA9.GA9_CODCON BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GE7.GE7_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_DATATE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'"
If empty(MV_PAR15) .And. empty(MV_PAR16) // se não estiver filtrando por data do extrato médico
	cSQL += " LEFT "                        // despreza verificação da GDX
Endif
cSQL += " JOIN " + RetSQLName("GDX") + " GDX ON GDX.GDX_NREXTM = GE7.GE7_NREXTM AND GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.D_E_L_E_T_ <> '*' AND GDX.GDX_DATLAN BETWEEN '" + DTOS(MV_PAR15) + "' AND '" + DTOS(MV_PAR16) + "'"

if MV_PAR13 < 4      // Se Não for Extrato de Médico e nem Pago
 	cSQL += " LEFT "   // despreza verficação do Contas a Pagar
endif
cSQL += "  JOIN " + RetSQLName("SE2") + " SE2 ON SE2.E2_NUM = GDX.GDX_CODCPG  AND SE2.E2_FILIAL = '" + xFilial("SE2") + "' AND SE2.D_E_L_E_T_ <> '*' AND SE2.E2_PREFIXO = '"+AllTrim(GetMV("MV_PREFCPH"))+"'"
If MV_PAR13 == 5 // Se for Pago
	cSQL += " AND SE2.E2_BAIXA <> '"+ ("  /  /    ") + "'"
EndIf

cSQL += " WHERE GE7.GE7_PGTMED <> '0' AND GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*'"

If MV_PAR13 == 3 // Se for Extrato de Convenio
	cSQL += " AND GE7.GE7_NREXTC BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "'"  //Filtra pelo intervalo de extratos do convenio
	cSQL += " AND GE7.GE7_NREXTC <> '"+SPACE(LEN(GE7->GE7_NREXTC))+"'" // Somente os que tem extrato convenio
ElseIf MV_PAR13 == 4 // Se for Extrato Médico 
	cSQL += " AND GE7.GE7_NREXTM <> '"+SPACE(LEN(GE7->GE7_NREXTM))+"'" // Somente os que tem extrato médico
Endif

// ********* UNION 1
cSQL +=" UNION ALL "
// ******************

cSQL += "SELECT SRA.RA_NOME NOMEF,"
cSQL += "       SRA.RA_CODIGO CODIGO,"
cSQL += "       GA9.GA9_NREDUZ NREDUZ,"
cSQL += "       GA9.GA9_CODCON CODCON,"
cSQL += " 		 '' DESCRICAO,"
cSQL += " 		 '' CODPRO,"
cSQL += " 		 GCY.GCY_NOME NOMEPAC,"
cSQL += " 		 GCZ.GCZ_NRGUIA NRGUIA,"
cSQL += " 		 GCY.GCY_DATATE DATATE,"
cSQL += " 		 GCY.GCY_REGATE REGATE,"
cSQL += HS_FVALDES("GE6") + " VALDES,"
cSQL += " 	  GE6.GE6_VALREP VALREP,"
cSQL += " 		GE6.GE6_VLRGLO VLRGLO,"
cSQL += " 		GE6.GE6_REPAMB REPAMB,"
cSQL += " 		0 COECHP,"
cSQL += " 		GE6.GE6_NREXTM NREXTM,"
cSQL += " 		GE6.GE6_NREXTC NREXTC,"
cSQL += " 		 '' CODATO," 
cSQL += " 		SE2.E2_BAIXA BAIXA"
cSQL += " FROM "+ RetSQLName("GE6") + " GE6"
cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO = GE6.GE6_CODCRM AND SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GE6.GE6_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRLOTE BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' " 
cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' AND GA9.GA9_CODCON BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GE6.GE6_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_DATATE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' " 
If empty(MV_PAR15) .And. empty(MV_PAR16) // se não estiver filtrando por data do extrato médico
	cSQL += " LEFT "                        // despreza verificação da GDX
Endif
cSQL += " JOIN " + RetSQLName("GDX") + " GDX ON GDX.GDX_NREXTM = GE6.GE6_NREXTM AND GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.D_E_L_E_T_ <> '*' AND GDX.GDX_DATLAN BETWEEN '" + DTOS(MV_PAR15) + "' AND '" + DTOS(MV_PAR16) + "'"

if MV_PAR13 < 4      // Se Não for Extrato de Médico e nem Pago
 	cSQL += " LEFT "   // despreza verficação do Contas a Pagar
endif
cSQL += "  JOIN " + RetSQLName("SE2") + " SE2 ON SE2.E2_NUM = GDX.GDX_CODCPG  AND SE2.E2_FILIAL = '" + xFilial("SE2") + "' AND SE2.D_E_L_E_T_ <> '*' AND SE2.E2_PREFIXO = '"+AllTrim(GetMV("MV_PREFCPH"))+"'"
If MV_PAR13 == 5 // Se for Pago
	cSQL += " AND SE2.E2_BAIXA <> '"+ ("  /  /    ") + "'"
EndIf

cSQL += " WHERE GE6.GE6_PGTMED <> '0' AND GE6.GE6_FILIAL = '" + xFilial("GE6") + "' AND GE6.D_E_L_E_T_ <> '*'"

If MV_PAR13 == 3 // Se for Extrato de Convenio
	cSQL += " AND GE6.GE6_NREXTC BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "'"  //Filtra pelo intervalo de extratos do convenio
	cSQL += " AND GE6.GE6_NREXTC <> '"+SPACE(LEN(GE6->GE6_NREXTC))+"'" // Somente os que tem extrato convenio
ElseIf MV_PAR13 == 4 // Se for Extrato Médico 
	cSQL += " AND GE6.GE6_NREXTM <> '"+SPACE(LEN(GE6->GE6_NREXTM))+"'" // Somente os que tem extrato médico
Endif

// ********* UNION 2
cSQL +=" UNION ALL "
// ******************

cSQL += "SELECT SRA.RA_NOME NOMEF,"
cSQL += "       SRA.RA_CODIGO CODIGO,"
cSQL += "       GA9.GA9_NREDUZ NREDUZ,"
cSQL += "       GA9.GA9_CODCON CODCON,"
cSQL += " 		 '' DESCRICAO,"
cSQL += " 		 '' CODPRO,"
cSQL += " 		 GCY.GCY_NOME NOMEPAC,"
cSQL += " 		 GCZ.GCZ_NRGUIA NRGUIA,"
cSQL += " 		 GCY.GCY_DATATE DATATE,"
cSQL += " 		 GCY.GCY_REGATE REGATE,"
cSQL += HS_FVALDES("GE5") + " VALDES,"
cSQL += " 	  GE5.GE5_VALREP VALREP,"
cSQL += " 		GE5.GE5_VLRGLO VLRGLO,"
cSQL += " 		GE5.GE5_REPAMB REPAMB,"
cSQL += " 		0 COECHP,"
cSQL += " 		GE5.GE5_NREXTM NREXTM,"
cSQL += " 		GE5.GE5_NREXTC NREXTC,"
cSQL += " 		 '' CODATO," 
cSQL += " 		SE2.E2_BAIXA BAIXA"
cSQL += " FROM "+ RetSQLName("GE5") + " GE5"
cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO = GE5.GE5_CODCRM AND SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GE5.GE5_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRLOTE BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' " 
cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' AND GA9.GA9_CODCON BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GE5.GE5_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_DATATE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' " 
If empty(MV_PAR15) .And. empty(MV_PAR16) // se não estiver filtrando por data do extrato médico
	cSQL += " LEFT "                        // despreza verificação da GDX
Endif
cSQL += " JOIN " + RetSQLName("GDX") + " GDX ON GDX.GDX_NREXTM = GE5.GE5_NREXTM AND GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.D_E_L_E_T_ <> '*' AND GDX.GDX_DATLAN BETWEEN '" + DTOS(MV_PAR15) + "' AND '" + DTOS(MV_PAR16) + "'"

if MV_PAR13 < 4      // Se Não for Extrato de Médico e nem Pago
 	cSQL += " LEFT "   // despreza verficação do Contas a Pagar
endif
cSQL += "  JOIN " + RetSQLName("SE2") + " SE2 ON SE2.E2_NUM = GDX.GDX_CODCPG  AND SE2.E2_FILIAL = '" + xFilial("SE2") + "' AND SE2.D_E_L_E_T_ <> '*' AND SE2.E2_PREFIXO = '"+AllTrim(GetMV("MV_PREFCPH"))+"'"
If MV_PAR13 == 5 // Se for Pago
	cSQL += " AND SE2.E2_BAIXA <> '"+ ("  /  /    ") + "'"
EndIf

cSQL += " WHERE GE5.GE5_PGTMED <> '0' AND GE5.GE5_FILIAL = '" + xFilial("GE5") + "' AND GE5.D_E_L_E_T_ <> '*'"

If MV_PAR13 == 3 // Se for Extrato de Convenio
	cSQL += " AND GE5.GE5_NREXTC BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "'"  //Filtra pelo intervalo de extratos do convenio
	cSQL += " AND GE5.GE5_NREXTC <> '"+SPACE(LEN(GE5->GE5_NREXTC))+"'" // Somente os que tem extrato convenio
ElseIf MV_PAR13 == 4 // Se for Extrato Médico 
	cSQL += " AND GE5.GE5_NREXTM <> '"+SPACE(LEN(GE5->GE5_NREXTM))+"'" // Somente os que tem extrato médico
Endif

cSQL += " ORDER BY NOMEF, NREDUZ, DESCRICAO, CODATO, NOMEPAC"

cSql := ChangeQuery(cSql)

TCQUERY cSQL NEW ALIAS "QRY"

DbSelectArea("QRY")
DbGoTop()

If Eof()
	HS_MsgInf(STR0017,STR0018,STR0019) //"Nenhum dado foi encontrado para a selecao efetuada!"###"Atenção"###"Produção e Glosa"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetRegua(RecCount())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicionamento do primeiro registro e loop principal. Pode-se criar ³
//³ a logica da seguinte maneira: Posiciona-se na filial corrente e pro ³
//³ cessa enquanto a filial do registro for a filial corrente. Por exem ³
//³ plo, substitua o dbGoTop() e o While !EOF() abaixo pela sintaxe:    ³
//³                                                                     ³
//³ dbSeek(xFilial())                                                   ³
//³ While !EOF() .And. xFilial() == A1_FILIAL                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O tratamento dos parametros deve ser feito dentro da logica do seu  ³
//³ relatorio. Geralmente a chave principal e a filial (isto vale prin- ³
//³ cipalmente se o arquivo for um arquivo padrao). Posiciona-se o pri- ³
//³ meiro registro pela filial + pela chave secundaria (codigo por exem ³
//³ plo), e processa enquanto estes valores estiverem dentro dos parame ³
//³ tros definidos. Suponha por exemplo o uso de dois parametros:       ³
//³ mv_par01 -> Indica o codigo inicial a processar                     ³
//³ mv_par02 -> Indica o codigo final a processar                       ³
//³                                                                     ³
//³ dbSeek(xFilial()+mv_par01,.T.) // Posiciona no 1o.reg. satisfatorio ³
//³ While !EOF() .And. xFilial() == A1_FILIAL .And. A1_COD <= mv_par02  ³
//³                                                                     ³
//³ Assim o processamento ocorrera enquanto o codigo do registro posicio³
//³ nado for menor ou igual ao parametro mv_par02, que indica o codigo  ³
//³ limite para o processamento. Caso existam outros parametros a serem ³
//³ checados, isto deve ser feito dentro da estrutura de laço (WHILE):  ³
//³                                                                     ³
//³ mv_par01 -> Indica o codigo inicial a processar                     ³
//³ mv_par02 -> Indica o codigo final a processar                       ³
//³ mv_par03 -> Considera qual estado?                                  ³
//³                                                                     ³
//³ dbSeek(xFilial()+mv_par01,.T.) // Posiciona no 1o.reg. satisfatorio ³
//³ While !EOF() .And. xFilial() == A1_FILIAL .And. A1_COD <= mv_par02  ³
//³                                                                     ³
//³     If A1_EST <> mv_par03                                           ³
//³         dbSkip()                                                    ³
//³         Loop                                                        ³
//³     Endif                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbGoTop()

cMed := QRY->CODIGO
cCon := QRY->CODCON
cPro := QRY->CODPRO
cAto := QRY->CODATO
nQtAto := 0
nQtMed := 0
nQtCon := 0
nQtPro := 0
nQtGer := 0
nVlDesCon := 0
nVlDesPro := 0
nVlDesMed := 0
nVlDesAto := 0
nVlLiqCon := 0
nVlLiqPro := 0
nVlLiqMed := 0
nVlLiqAto := 0
nVlRepCon := 0
nVlRepPro := 0
nVlRepMed := 0
nVlRepAto := 0
nVlGloMed := 0
nVlGloAto := 0
nVlGloCon := 0
nVlGloPro := 0
nVlDesGer := 0
nVlRepGer := 0
nVlGloGer := 0
nVlLiqGer := 0
nVlLiqRep := 0



While !EOF()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cancelamento pelo usuario...                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If lAbortPrint
		@nLin,00 PSAY STR0020 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho do relatorio. . .                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	nLin := EmitCabec(0,nLin,.t.)
	
	if ((MV_PAR13 == 1) .and. (MV_PAR14 == 1))
		cSituacao := "01"
		if !empty(QRY->NREXTC) .and. empty(QRY->NREXTM) .and. cSituacao = "01"
			cSituacao := "02"
		endif
		if !empty(QRY->NREXTM) .and. empty(QRY->BAIXA) .and. cSituacao = "01"
			cSituacao := "03"
		endif
		if !empty(QRY->BAIXA) .and. cSituacao = "01"
			cSituacao := "04"
		endif
	endif
	
	if MV_PAR14 == 1
		While (cCon == QRY->CODCON) .and. ;
			(cMed == QRY->CODIGO)  .and. !EOF()
			
			if GMC->(dbseek(xFilial("GMC")+QRY->CODATO))
				if QRY->CODATO > "01"
					@nLin,000 PSAY alltrim(QRY->DESCRICAO) + "  (" + alltrim(GMC->GMC_DESATO) + ")"
					cTotalizaAto := "S"
				else
					@nLin,000 PSAY alltrim(QRY->DESCRICAO)
					cTotalizaAto := "N"
				endif
			else
				@nLin,000 PSAY alltrim(QRY->DESCRICAO)
				cTotalizaAto := "N"
			endif
			nLin += 1
			nLin := EmitCabec(1,nLin,.t.)
			While (cPro == QRY->CODPRO) .and. ;
				(cAto == QRY->CODATO) .and. ;
				(cMed == QRY->CODIGO)  .and. ;
				(cCon == QRY->CODCON) .and. !EOF()
				nVlLiqRep := 0
				nVlLiqRep := (QRY->VALREP - QRY->VLRGLO)
				
				@nLin,000 PSAY substr(QRY->NOMEPAC,1,30)
				@nLin,031 PSAY QRY->NRGUIA
				@nLin,052 PSAY substr(QRY->DATATE,7,2)+"/"+substr(QRY->DATATE,5,2)+"/"+substr(QRY->DATATE,1,4)
				@nLin,063 PSAY QRY->REGATE
				@nLin,070 PSAY QRY->VALDES picture "@E 9,999,999.99"
				if (QRY->REPAMB == 0 .and. QRY->VALREP > 0)
					@nLin,083 PSAY QRY->COECHP picture "@E 99.999"
				elseif (QRY->REPAMB > 0)
					@nLin,083 PSAY QRY->REPAMB picture "@E 999"
				else
					@nLin,083 PSAY 0 picture "@E 999,99"
				endif
				@nLin,090 PSAY QRY->VALREP picture "@E 9,999,999.99"
				@nLin,105 PSAY QRY->VLRGLO picture "@E 999,999.99"
				@nLin,119 PSAY if(nVlLiqRep < 0,0,nVlLiqRep) picture "@E 999,999.99"
				if MV_PAR13 == 1
					@nLin,130 PSAY cSituacao
					nVlFatSit[val(cSituacao)] += QRY->VALDES
					nVlRepSit[val(cSituacao)] += QRY->VALREP
					nVlGloSit[val(cSituacao)] += QRY->VLRGLO
					nVlLiqSit[val(cSituacao)] += if(nVlLiqRep < 0 ,0,nVlLiqRep)
					nVlGFatSit[val(cSituacao)] += QRY->VALDES
					nVlGRepSit[val(cSituacao)] += QRY->VALREP
					nVlGGloSit[val(cSituacao)] += QRY->VLRGLO
					nVlGLiqSit[val(cSituacao)] += if(nVlLiqRep < 0 ,0,nVlLiqRep)
				endif
				nLin := EmitCabec(1,nLin,.t.)
				nQtAto += 1
				nQtMed += 1
				nQtCon += 1
				nQtPro += 1
				nQtGer += 1
				
				nVlDesAto += QRY->VALDES
				nVlDesMed += QRY->VALDES
				nVlDesCon += QRY->VALDES
				nVlDesPro += QRY->VALDES
				
				nVlLiqAto += if(nVlLiqRep < 0 ,0,nVlLiqRep)
				nVlLiqCon += if(nVlLiqRep < 0 ,0,nVlLiqRep)
				nVlLiqPro += if(nVlLiqRep < 0 ,0,nVlLiqRep)
				nVlLiqMed += if(nVlLiqRep < 0 ,0,nVlLiqRep)
				
				nVlRepAto += QRY->VALREP
				nVlRepCon += QRY->VALREP
				nVlRepPro += QRY->VALREP
				nVlRepMed += QRY->VALREP
				
				nVlGloAto += QRY->VLRGLO
				nVlGloMed += QRY->VLRGLO
				nVlGloCon += QRY->VLRGLO
				nVlGloPro += QRY->VLRGLO
				
				nVlDesGer += QRY->VALDES
				nVlRepGer += QRY->VALREP
				nVlGloGer += QRY->VLRGLO
				nVlLiqGer += if(nVlLiqRep < 0 ,0,nVlLiqRep)
				dbskip()
			enddo
			cPro := QRY->CODPRO
			cAto := QRY->CODATO
		enddo
	else
		@nLin,000 PSAY QRY->NREDUZ
		nLin := EmitCabec(1,nLin,.t.)
		While (cCon == QRY->CODCON) .and. ;
			(cMed == QRY->CODIGO)  .and. !EOF()
			
			if GMC->(dbseek(xFilial("GMC")+QRY->CODATO))
				if QRY->CODATO > "01"
					@nLin,000 PSAY alltrim(QRY->DESCRICAO) + "  (" + alltrim(GMC->GMC_DESATO) + ")"
					cTotalizaAto := "S"
				else
					@nLin,000 PSAY alltrim(QRY->DESCRICAO)
					cTotalizaAto := "N"
				endif
			else
				@nLin,000 PSAY alltrim(QRY->DESCRICAO)
				cTotalizaAto := "N"
			endif
			While (cCon == QRY->CODCON) .and. ;
				(cPro == QRY->CODPRO) .and. ;
				(cMed == QRY->CODIGO)  .and. ;
				(cAto == QRY->CODATO) .and. !EOF()
				nVlLiqRep := 0
				nVlLiqRep := (QRY->VALREP - QRY->VLRGLO)
				if cTotalizaAto = "S"
					nQtAto += 1
					nVlDesAto += QRY->VALDES
					nVlLiqAto += if(nVlLiqRep < 0 ,0,nVlLiqRep)
					nVlRepAto += QRY->VALREP
					nVlGloAto += QRY->VLRGLO
				endif
				nQtMed += 1
				nQtCon += 1
				nQtPro += 1
				nQtGer += 1
				
				nVlDesMed += QRY->VALDES
				nVlDesCon += QRY->VALDES
				nVlDesPro += QRY->VALDES
				
				nVlLiqCon += if(nVlLiqRep < 0 ,0,nVlLiqRep)
				nVlLiqPro += if(nVlLiqRep < 0 ,0,nVlLiqRep)
				nVlLiqMed += if(nVlLiqRep < 0 ,0,nVlLiqRep)
				
				nVlRepCon += QRY->VALREP
				nVlRepPro += QRY->VALREP
				nVlRepMed += QRY->VALREP
				
				nVlGloMed += QRY->VLRGLO
				nVlGloCon += QRY->VLRGLO
				nVlGloPro += QRY->VLRGLO
				
				nVlDesGer += QRY->VALDES
				nVlRepGer += QRY->VALREP
				nVlGloGer += QRY->VLRGLO
				nVlLiqGer += if(nVlLiqRep < 0 ,0,nVlLiqRep)
				dbskip()
			enddo
			@nLin,069 PSAY nVlDesPro picture "@E 99,999,999.99"
			@nLin,089 PSAY nVlRepPro picture "@E 99,999,999.99"
			@nLin,103 PSAY nVlGloPro picture "@E 9,999,999.99"
			@nLin,117 PSAY nVlLiqPro picture "@E 9,999,999.99"
			nVlDesPro := 0
			nVlRepPro := 0
			nVlGloPro := 0
			nVlLiqPro := 0
			nLin := EmitCabec(1,nLin,.t.)
			//dbskip()
			cPro := QRY->CODPRO
			cAto := QRY->CODATO
		enddo
	endif
	
	nLin := EmitCabec(1,nLin,.t.) // Avanca a linha de impressao
	
	//dbSkip() // Avanca o ponteiro do registro no arquivo
	
	if ((cMed <> QRY->CODIGO) .and. (!eof()))
		if MV_PAR14 == 1
			if cTotalizaAto = "S"
				@nLin,010 PSAY STR0021 //"Total Ato -------------------->>>>"
				@nLin,050 PSAY nQtAto picture "99999"
				@nLin,069 PSAY nVlDesAto picture "@E 99,999,999.99"
				@nLin,089 PSAY nVlRepAto picture "@E 99,999,999.99"
				@nLin,103 PSAY nVlGloAto picture "@E 9,999,999.99"
				@nLin,117 PSAY nVlLiqAto picture "@E 9,999,999.99"
				nLin := EmitCabec(1,nLin,.t.)
			endif
			nVlDesAto := 0
			nVlRepAto := 0
			nVlGloAto := 0
			nVlLiqAto := 0
			nQtAto := 0
			cAto := QRY->CODATO
			@nLin,010 PSAY STR0022 //"Total Procedimento ----------->>>>"
			@nLin,050 PSAY nQtPro picture "99999"
			@nLin,069 PSAY nVlDesPro picture "@E 99,999,999.99"
			@nLin,089 PSAY nVlRepPro picture "@E 99,999,999.99"
			@nLin,103 PSAY nVlGloPro picture "@E 9,999,999.99"
			@nLin,117 PSAY nVlLiqPro picture "@E 9,999,999.99"
			nVlDesPro := 0
			nVlRepPro := 0
			nVlGloPro := 0
			nVlLiqPro := 0
			nQtPro := 0
			cPro := QRY->CODPRO
			nLin := EmitCabec(1,nLin,.t.)
		else
			cPro := QRY->CODPRO
			cAto := QRY->CODATO
		endif
		@nLin,010 PSAY STR0023 //"Total Convênio --------------->>>>"
		@nLin,050 PSAY nQtCon picture "99999"
		@nLin,069 PSAY nVlDesCon picture "@E 99,999,999.99"
		@nLin,089 PSAY nVlRepcon picture "@E 99,999,999.99"
		@nLin,103 PSAY nVlGloCon picture "@E 9,999,999.99"
		@nLin,117 PSAY nVlLiqCon picture "@E 9,999,999.99"
		nVlDesCon := 0
		nVlRepCon := 0
		nVlGloCon := 0
		nVlLiqCon := 0
		nQtCon := 0
		nLin := EmitCabec(1,nLin,.t.)
		@nLin,010 PSAY STR0024 //"Total Médico ----------------->>>>"
		@nLin,050 PSAY nQtMed picture "99999"
		@nLin,069 PSAY nVlDesMed picture "@E 99,999,999.99"
		@nLin,089 PSAY nVlRepMed picture "@E 99,999,999.99"
		@nLin,103 PSAY nVlGloMed picture "@E 9,999,999.99"
		@nLin,117 PSAY nVlLiqMed picture "@E 9,999,999.99"
		nVlDesMed := 0
		nVlRepMed := 0
		nVlGloMed := 0
		nVlLiqMed := 0
		nQtMed := 0
		
		if (MV_PAR13 == 1)
			nLin := EmitCabec(2,nLin,.t.)
			@nLin,010 PSAY STR0025 //"Total Faturados -------------->>>>"
			@nLin,069 PSAY nVlFatSit[1] picture "@E 99,999,999.99"
			@nLin,089 PSAY nVlRepSit[1] picture "@E 99,999,999.99"
			@nLin,103 PSAY nVlGloSit[1] picture "@E 9,999,999.99"
			@nLin,117 PSAY nVlLiqSit[1] picture "@E 9,999,999.99"
			
			nLin := EmitCabec(1,nLin,.t.)
			@nLin,010 PSAY STR0026 //"Total Extrato Convênio ------->>>>"
			@nLin,069 PSAY nVlFatSit[2] picture "@E 99,999,999.99"
			@nLin,089 PSAY nVlRepSit[2] picture "@E 99,999,999.99"
			@nLin,103 PSAY nVlGloSit[2] picture "@E 9,999,999.99"
			@nLin,117 PSAY nVlLiqSit[2] picture "@E 9,999,999.99"
			
			nLin := EmitCabec(1,nLin,.t.)
			@nLin,010 PSAY STR0027 //"Total Extrato Médico --------->>>>"
			@nLin,069 PSAY nVlFatSit[3] picture "@E 99,999,999.99"
			@nLin,089 PSAY nVlRepSit[3] picture "@E 99,999,999.99"
			@nLin,103 PSAY nVlGloSit[3] picture "@E 9,999,999.99"
			@nLin,117 PSAY nVlLiqSit[3] picture "@E 9,999,999.99"
			
			nLin := EmitCabec(1,nLin,.t.)
			@nLin,010 PSAY STR0028 //"Total QuitadO ---------------->>>>"
			@nLin,069 PSAY nVlFatSit[4] picture "@E 99,999,999.99"
			@nLin,089 PSAY nVlRepSit[4] picture "@E 99,999,999.99"
			@nLin,103 PSAY nVlGloSit[4] picture "@E 9,999,999.99"
			@nLin,117 PSAY nVlLiqSit[4] picture "@E 9,999,999.99"
			
			afill(nVlFatSit,0)
			afill(nVlRepSit,0)
			afill(nVlGloSit,0)
			afill(nVlLiqSit,0)
		endif
		nLin := EmitCabec(2,61,.t.)
		cMed := QRY->CODIGO
		cCon := QRY->CODCON
	endif
	if ((cCon <> QRY->CODCON) .and. (!eof()))
		if MV_PAR14 == 1
			if cTotalizaAto = "S"
				@nLin,010 PSAY STR0021 //"Total Ato -------------------->>>>"
				@nLin,050 PSAY nQtAto picture "99999"
				@nLin,069 PSAY nVlDesAto picture "@E 99,999,999.99"
				@nLin,089 PSAY nVlRepAto picture "@E 99,999,999.99"
				@nLin,103 PSAY nVlGloAto picture "@E 9,999,999.99"
				@nLin,117 PSAY nVlLiqAto picture "@E 9,999,999.99"
				nLin := EmitCabec(1,nLin,.t.)
			endif
			nVlDesAto := 0
			nVlRepAto := 0
			nVlGloAto := 0
			nVlLiqAto := 0
			nQtAto := 0
			cAto := QRY->CODATO
			@nLin,010 PSAY STR0022 //"Total Procedimento ----------->>>>"
			@nLin,050 PSAY nQtPro picture "99999"
			@nLin,069 PSAY nVlDesPro picture "@E 99,999,999.99"
			@nLin,089 PSAY nVlRepPro picture "@E 99,999,999.99"
			@nLin,103 PSAY nVlGloPro picture "@E 9,999,999.99"
			@nLin,117 PSAY nVlLiqPro picture "@E 9,999,999.99"
			nVlDesPro := 0
			nVlRepPro := 0
			nVlGloPro := 0
			nVlLiqPro := 0
			nQtPro := 0
			nVlDesAto := 0
			nVlRepAto := 0
			nVlGloAto := 0
			nVlLiqAto := 0
			nQtAto := 0
			cPro := QRY->CODPRO
			nLin := EmitCabec(1,nLin,.t.)
		else
			cPro := QRY->CODPRO
			cAto := QRY->CODATO
		endif
		@nLin,010 PSAY STR0023 //"Total Convênio --------------->>>>"
		@nLin,050 PSAY nQtCon picture "99999"
		@nLin,069 PSAY nVlDesCon picture "@E 99,999,999.99"
		@nLin,089 PSAY nVlRepcon picture "@E 99,999,999.99"
		@nLin,103 PSAY nVlGloCon picture "@E 9,999,999.99"
		@nLin,117 PSAY nVlLiqCon picture "@E 9,999,999.99"
		nVlDesCon := 0
		nVlRepCon := 0
		nVlGloCon := 0
		nVlLiqCon := 0
		nQtCon := 0
		nLin := EmitCabec(2,nLin,.t.)
		cCon := QRY->CODCON
		if MV_PAR14 == 1
			@nLin,00 PSAY STR0029 + QRY->NREDUZ //"Convênio: "
			nLin := EmitCabec(2,nLin,.t.)
		endif
	endif
	if ((cPro <> QRY->CODPRO) .and. (!eof()))
		if MV_PAR14 == 1
			if cTotalizaAto = "S"
				@nLin,010 PSAY STR0021 //"Total Ato -------------------->>>>"
				@nLin,050 PSAY nQtAto picture "99999"
				@nLin,069 PSAY nVlDesAto picture "@E 99,999,999.99"
				@nLin,089 PSAY nVlRepAto picture "@E 99,999,999.99"
				@nLin,103 PSAY nVlGloAto picture "@E 9,999,999.99"
				@nLin,117 PSAY nVlLiqAto picture "@E 9,999,999.99"
				nLin := EmitCabec(1,nLin,.t.)
			endif
			nVlDesAto := 0
			nVlRepAto := 0
			nVlGloAto := 0
			nVlLiqAto := 0
			nQtAto := 0
			cAto := QRY->CODATO
			@nLin,010 PSAY STR0022 //"Total Procedimento ----------->>>>"
			@nLin,050 PSAY nQtPro picture "99999"
			@nLin,069 PSAY nVlDesPro picture "@E 99,999,999.99"
			@nLin,089 PSAY nVlRepPro picture "@E 99,999,999.99"
			@nLin,103 PSAY nVlGloPro picture "@E 9,999,999.99"
			@nLin,117 PSAY nVlLiqPro picture "@E 9,999,999.99"
			nVlDesPro := 0
			nVlRepPro := 0
			nVlGloPro := 0
			nVlLiqPro := 0
			nQtPro := 0
			nVlDesAto := 0
			nVlRepAto := 0
			nVlGloAto := 0
			nVlLiqAto := 0
			nQtAto := 0
			nLin := EmitCabec(2,nLin,.t.)
			cPro := QRY->CODPRO
		else
			cPro := QRY->CODPRO
			cAto := QRY->CODATO
		endif
	endif
	if ((cAto <> QRY->CODATO) .and. (!eof()))
		if MV_PAR14 == 1
			if cTotalizaAto = "S"
				@nLin,010 PSAY STR0021 //"Total Ato -------------------->>>>"
				@nLin,050 PSAY nQtAto picture "99999"
				@nLin,069 PSAY nVlDesAto picture "@E 99,999,999.99"
				@nLin,089 PSAY nVlRepAto picture "@E 99,999,999.99"
				@nLin,103 PSAY nVlGloAto picture "@E 9,999,999.99"
				@nLin,117 PSAY nVlLiqAto picture "@E 9,999,999.99"
				nLin := EmitCabec(1,nLin,.t.)
			endif
			nVlDesAto := 0
			nVlRepAto := 0
			nVlGloAto := 0
			nVlLiqAto := 0
			nQtAto := 0
			cAto := QRY->CODATO
		else
			cAto := QRY->CODATO
		endif
	endif
EndDo

DbGoTop()
If !Eof()
	if MV_PAR14 == 1
		if cTotalizaAto = "S"
			@nLin,010 PSAY STR0021 //"Total Ato -------------------->>>>"
			@nLin,050 PSAY nQtAto picture "99999"
			@nLin,069 PSAY nVlDesAto picture "@E 99,999,999.99"
			@nLin,089 PSAY nVlRepAto picture "@E 99,999,999.99"
			@nLin,103 PSAY nVlGloAto picture "@E 9,999,999.99"
			@nLin,117 PSAY nVlLiqAto picture "@E 9,999,999.99"
			nLin := EmitCabec(1,nLin,.t.)
		endif
		nVlDesAto := 0
		nVlRepAto := 0
		nVlGloAto := 0
		nVlLiqAto := 0
		nQtAto := 0
		@nLin,010 PSAY STR0022 //"Total Procedimento ----------->>>>"
		@nLin,050 PSAY nQtPro picture "99999"
		@nLin,069 PSAY nVlDesPro picture "@E 99,999,999.99"
		@nLin,089 PSAY nVlRepPro picture "@E 99,999,999.99"
		@nLin,103 PSAY nVlGloPro picture "@E 9,999,999.99"
		@nLin,117 PSAY nVlLiqPro picture "@E 9,999,999.99"
		nVlDesPro := 0
		nVlRepPro := 0
		nVlGloPro := 0
		nVlLiqPro := 0
		nLin := EmitCabec(1,nLin,.t.)
	endif
	@nLin,010 PSAY STR0023 //"Total Convênio --------------->>>>"
	@nLin,050 PSAY nQtCon picture "99999"
	@nLin,069 PSAY nVlDesCon picture "@E 99,999,999.99"
	@nLin,089 PSAY nVlRepcon picture "@E 99,999,999.99"
	@nLin,103 PSAY nVlGloCon picture "@E 9,999,999.99"
	@nLin,117 PSAY nVlLiqCon picture "@E 9,999,999.99"
	nVlDesCon := 0
	nVlRepCon := 0
	nVlGloCon := 0
	nVlLiqCon := 0
	nLin := EmitCabec(1,nLin,.t.)
	@nLin,010 PSAY STR0024 //"Total Médico ----------------->>>>"
	@nLin,050 PSAY nQtMed picture "99999"
	@nLin,069 PSAY nVlDesMed picture "@E 99,999,999.99"
	@nLin,089 PSAY nVlRepMed picture "@E 99,999,999.99"
	@nLin,103 PSAY nVlGloMed picture "@E 9,999,999.99"
	@nLin,117 PSAY nVlLiqMed picture "@E 9,999,999.99"
	nVlDesMed := 0
	nVlRepMed := 0
	nVlGloMed := 0
	nVlLiqMed := 0
	if (MV_PAR13 == 1)
		nLin := EmitCabec(2,nLin,.t.)
		@nLin,010 PSAY STR0025 //"Total Faturados -------------->>>>"
		@nLin,069 PSAY nVlFatSit[1] picture "@E 99,999,999.99"
		@nLin,089 PSAY nVlRepSit[1] picture "@E 99,999,999.99"
		@nLin,103 PSAY nVlGloSit[1] picture "@E 9,999,999.99"
		@nLin,117 PSAY nVlLiqSit[1] picture "@E 9,999,999.99"
		
		nLin := EmitCabec(1,nLin,.t.)
		@nLin,010 PSAY STR0026 //"Total Extrato Convênio ------->>>>"
		@nLin,069 PSAY nVlFatSit[2] picture "@E 99,999,999.99"
		@nLin,089 PSAY nVlRepSit[2] picture "@E 99,999,999.99"
		@nLin,103 PSAY nVlGloSit[2] picture "@E 9,999,999.99"
		@nLin,117 PSAY nVlLiqSit[2] picture "@E 9,999,999.99"
		
		nLin := EmitCabec(1,nLin,.t.)
		@nLin,010 PSAY STR0027 //"Total Extrato Médico --------->>>>"
		@nLin,069 PSAY nVlFatSit[3] picture "@E 99,999,999.99"
		@nLin,089 PSAY nVlRepSit[3] picture "@E 99,999,999.99"
		@nLin,103 PSAY nVlGloSit[3] picture "@E 9,999,999.99"
		@nLin,117 PSAY nVlLiqSit[3] picture "@E 9,999,999.99"
		
		nLin := EmitCabec(1,nLin,.t.)
		@nLin,010 PSAY STR0028 //"Total QuitadO ---------------->>>>"
		@nLin,069 PSAY nVlFatSit[4] picture "@E 99,999,999.99"
		@nLin,089 PSAY nVlRepSit[4] picture "@E 99,999,999.99"
		@nLin,103 PSAY nVlGloSit[4] picture "@E 9,999,999.99"
		@nLin,117 PSAY nVlLiqSit[4] picture "@E 9,999,999.99"
		
		afill(nVlFatSit,0)
		afill(nVlRepSit,0)
		afill(nVlGloSit,0)
		afill(nVlLiqSit,0)
	endif
	if (MV_PAR13 == 1)
		nLin := EmitCabec(2,61,.f.)
		@nLin,010 PSAY STR0030 //"Total Geral Faturados -------->>>>"
		@nLin,069 PSAY nVlGFatSit[1] picture "@E 99,999,999.99"
		@nLin,089 PSAY nVlGRepSit[1] picture "@E 99,999,999.99"
		@nLin,103 PSAY nVlGGloSit[1] picture "@E 9,999,999.99"
		@nLin,117 PSAY nVlGLiqSit[1] picture "@E 9,999,999.99"
		
		nLin := EmitCabec(1,nLin,.f.)
		@nLin,010 PSAY STR0031 //"Total Geral Extrato Convênio ->>>>"
		@nLin,069 PSAY nVlGFatSit[2] picture "@E 99,999,999.99"
		@nLin,089 PSAY nVlGRepSit[2] picture "@E 99,999,999.99"
		@nLin,103 PSAY nVlGGloSit[2] picture "@E 9,999,999.99"
		@nLin,117 PSAY nVlGLiqSit[2] picture "@E 9,999,999.99"
		
		nLin := EmitCabec(1,nLin,.f.)
		@nLin,010 PSAY STR0032 //"Total Geral Extrato Médico --->>>>"
		@nLin,069 PSAY nVlGFatSit[3] picture "@E 99,999,999.99"
		@nLin,089 PSAY nVlGRepSit[3] picture "@E 99,999,999.99"
		@nLin,103 PSAY nVlGGloSit[3] picture "@E 9,999,999.99"
		@nLin,117 PSAY nVlGLiqSit[3] picture "@E 9,999,999.99"
		
		nLin := EmitCabec(1,nLin,.f.)
		@nLin,010 PSAY STR0033 //"Total Geral Quitado ---------->>>>"
		@nLin,069 PSAY nVlGFatSit[4] picture "@E 99,999,999.99"
		@nLin,089 PSAY nVlGRepSit[4] picture "@E 99,999,999.99"
		@nLin,103 PSAY nVlGGloSit[4] picture "@E 9,999,999.99"
		@nLin,117 PSAY nVlGLiqSit[4] picture "@E 9,999,999.99"
		
		afill(nVlGFatSit,0)
		afill(nVlGRepSit,0)
		afill(nVlGGloSit,0)
		afill(nVlGLiqSit,0)
	endif
	nLin := EmitCabec(2,nLin,.f.)
	@nLin,010 PSAY STR0034 //"Total Geral ------------------>>>>"
	@nLin,050 PSAY nQtGer picture "99999"
	@nLin,069 PSAY nVlDesGer picture "@E 99,999,999.99"
	@nLin,089 PSAY nVlRepGer picture "@E 99,999,999.99"
	@nLin,103 PSAY nVlGloGer picture "@E 9,999,999.99"
	@nLin,117 PSAY nVlLiqGer picture "@E 9,999,999.99"
	nLin := EmitCabec(2,nLin,.f.)
	
	if ((MV_PAR13 == 1) .and. (MV_PAR14 == 1) .and. (nLin < 80))
		nLin := 63
		@nLin,000 PSAY STR0035 //"Status : 001 - Faturados, 002 - Extrato Convênio, 003 - Extrato Médico, 004 - Quitado"
	endif
endif
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
DBCloseArea()

Return

Static Function EmitCabec(nLinhas,nLinha,lEmitCvMd)
If nLinha > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
	if ((MV_PAR13 == 1) .and. (MV_PAR14 == 1) .and. (nLinha < 80))
		nLinha := 65
		@nLinha,000 PSAY STR0035 //"Status : 001 - Faturados, 002 - Extrato Convênio, 003 - Extrato Médico, 004 - Quitado"
	endif
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLinha := 9
	if lEmitCvMd
		@nLinha,00 PSAY STR0036 + QRY->NOMEF //"Profissional: "
		nLinha := nLinha + 2
		if MV_PAR14 == 1
			@nLinha,00 PSAY STR0029 + QRY->NREDUZ //"Convênio: "
			nLinha := nLinha + 2
		endif
	endif
Endif

return(nLinha + nLinhas)
