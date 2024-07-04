#INCLUDE "protheus.ch"
#include "HSPAHR86.ch"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSPAHR86 º Autor ³ ROGERIO TABOSA     º Data ³  18/02/2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Transferencia de Clinicas                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Modulo Gestao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HSPAHR86()               

Local cDesc1         	:= STR0001 //"Este programa tem como objetivo imprimir o relatorio "
Local cDesc2         	:= STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         	:= STR0003 //"Transferencia de Clinicas"
Local cPict          	:= ""
local  titulo       	:= STR0003 //"Transferencia de Clinicas"
Local nLin         		:= 80
Local Cabec1       		:= STR0010 //"Codigo  Nome    				Data e Hora Atend.   Convenio/Plano   Descrição       CRM     Médico   Clinica Primaria     Dia(s)  Clin. Secund.     Dia(s)    Dias Internado    Alta"	
Local Cabec2       		:= ""
Local imprime      		:= .T.
Local aOrd := {}
Private lEnd         	:= .F.
Private lAbortPrint  	:= .F.
Private cCabAux1     	:= ""
Private cCabAux2     	:= ""
Private oTotaliz
Private limite          := 220
Private tamanho         := "G"
Private nomeprog        := "HSPAHR86" 
Private nTipo           := 15
Private aReturn         := { STR0029, 1, STR0030, 2, 2, 1, "", 1}  //"Zebrado" # "Administracao"
Private nLastKey        := 0
Private cbtxt      		:= Space(10)
Private cbcont     		:= 00
Private CONTFL     		:= 01
Private m_pag      		:= 01
Private wnrel      		:= "HSPAHR86" 
Private nCount		   	:= 0
Private nQtdAtd		   	:= 0
Private nQtdCliP	   	:= 0
Private nQtdCliS	   	:= 0
Private nQtdDMed	   	:= 0
Private nQtdCirS	   	:= 0
Private nQtdCirP	   	:= 0
Private nQtdDCir	   	:= 0
Private nQtdObtS	   	:= 0
Private nQtdObtP	   	:= 0
Private nQtdPedS	   	:= 0
Private nQtdPedP	   	:= 0
Private nQtdPsqS	   	:= 0
Private nQtdPsqP	   	:= 0 
Private cStrPrim		:= ""
Private cStrSecun		:= ""

Private cConv_de    := ""   //Variaveis de Filtro
Private cConv_ate   := ""
Private dDatAte_de
Private dDatAte_ate
Private nAlta     	:= 0
Private lVerif      := .T. // Usado para entrar no R3 ou no R4  
Private nMaxLin		:= 55

 If !HS_ExisDic({{"C", "GCY_CLISEC"}}, .F.) 
	HS_MSGINF(STR0004,STR0007,STR0008) // "Para a execução desta rotina é necessário executar o compatibilizador UPDGH021" # "Atenção" # s"Validação Transferencia de Clinicas"
	return()
 EndIf
 
 /*If FindFunction("TRepInUse") .And. TRepInUse() 
  lVerif := .T.
 EndIf*/
  
If !Pergunte("HSPR86",.T.)
 return
endif

cConv_de		:= mv_par01   //Variaveis de Filtro
cConv_ate  		:= mv_par02
dDatAte_de		:= mv_par03
dDatAte_ate		:= mv_par04
nAlta			:= mv_par05
//nMaxLin      := IIf(Empty(mv_par12), 55, HS_MaxLin(mv_par12))
 
If lVerif
	pergunte("HSPR86",.F.)
	oReport := ReportDef() 
	oReport:PrintDialog() 
Else
	wnrel := SetPrint("GCY",NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho, , .T.)
	If nLastKey == 27
		Return()
	Endif
	SetDefault(aReturn, "GCY")
	If nLastKey == 27
		Return()
	Endif
	aReturn[4] := 2
	nTipo := If(aReturn[4]==1,15,18)
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
EndIf

Return()


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ReportDef ³ Autor ³ Rogerio Tabosa        ³ Data ³ 31/07/08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/   

Static Function ReportDef()
 
 Local oReport 
 Local oSection1,oSection2//,oSection3,oSection4
 Local oCell
 Local oBreak  
 Local oTotaliza
                                                                           
 
 oReport := TReport():New("HSPAHR86",STR0003,"HSPR86",{|oReport| R86IMP(oReport)}, STR0001 + STR0002)
 oReport:SetLandScape()
 oReport:SetTotalInLine(.F.)
 
 oSection1 := TRSection():New(oReport, "GCY_REGATE", "QRYSQL")
 oSection1:SetHeaderPage(.T.)
 oSection1:SetHeaderBreak(.F.)
 oSection1:SetHeaderSection(.T.)
 oSection1:SetTotalInLine(.F.)      

 oCell := TRCell():New(oSection1,"","",STR0005,, 8,,)    //"Codigo"
 oCell := TRCell():New(oSection1,"","",STR0006,, 27,,)   //"Nome"
 oCell := TRCell():New(oSection1,"","",STR0009,, 18,,)   //"Data Atend."
 oCell := TRCell():New(oSection1,"","",STR0011,, 15,,)   //"Convenio/Plano"
 oCell := TRCell():New(oSection1,"","",STR0012,, 24,,)   //"Descricao"
 oCell := TRCell():New(oSection1,"","",STR0013,,32,,)    //"CRM     Medico"  
 oCell := TRCell():New(oSection1,"","",STR0014,, 25,,)   //"Clinica Primaria"
 oCell := TRCell():New(oSection1,"","",STR0015,, 7 ,,)   //"Dia(s)"
 oCell := TRCell():New(oSection1,"","",STR0016,, 25,,)   //"Clin. Secund."
 oCell := TRCell():New(oSection1,"","",STR0015,, 7 ,,)  //"Dia(s)" 
 oCell := TRCell():New(oSection1,"","",STR0017,, 15 ,,) //"Dias Inter."   
 oCell := TRCell():New(oSection1,"","",STR0018,, 7 ,,)   //"Alta"  

 oSection2 := TRSection():New(oSection1, "GCY_REGATE", "QRYSQL")
 oSection2:SetHeaderPage(.F.)
 oSection2:SetHeaderBreak(.F.) 
 oSection2:SetHeaderSection(.F.)  
 oSection2:SetTotalInLine(.F.)              
 
 oCell := TRCell():New(oSection2,"GCY_REGATE","QRYSQL","",, 8,,)    
 oCell := TRCell():New(oSection2,"GCY_NOME",  "QRYSQL","",, 27) 
 oCell := TRCell():New(oSection2,"cDatAte",   "QRYSQL","",, 18,,{|| cDatAte := DTOC(("QRYSQL")->GCY_DATATE) + " " + ("QRYSQL")->GCY_HORATE})  
 oCell := TRCell():New(oSection2,"cCnvPl",    "QRYSQL","",, 15,,{|| cConvPl := Alltrim(("QRYSQL")->GA9_CODCON) + " / " +  Alltrim(("QRYSQL")->GCM_CODPLA)}) 
 oCell := TRCell():New(oSection2,"cDesCon",   "QRYSQL","",, 24,,{|| cDesCon := Alltrim(("QRYSQL")->GA9_NOME) + " - " +  Alltrim(("QRYSQL")->GCM_DESPLA)})  
 oCell := TRCell():New(oSection2,"cCrmMed",   "QRYSQL","",, 32,,{|| cCrmMed := Alltrim(("QRYSQL")->GBJ_CRM) + " - " +  Alltrim(("QRYSQL")->RA_NOME)})   
 oCell := TRCell():New(oSection2,"cDsCliP",   "QRYSQL","",, 25,,{|| cDsCliP := Alltrim(("QRYSQL")->DSCLIP)})   
 oCell := TRCell():New(oSection2,"cDia",      "QRYSQL","",, 7,,{|| cDia := (("QRYSQL")->GCY_DTCLIS - ("QRYSQL")->GCY_DATATE),IIf(cDia == 0 ,"1",Alltrim(Str(cDia)))})    
 oCell := TRCell():New(oSection2,"cDsCliS","QRYSQL","",, 25,,{|| cDsCliS := Alltrim(("QRYSQL")->DSCLIS)})    
 oCell := TRCell():New(oSection2,"cDia","QRYSQL","",, 7,,{|| cDia := IIf(Empty(("QRYSQL")->GCY_DATALT),(dDataBase - ("QRYSQL")->GCY_DTCLIS),(("QRYSQL")->GCY_DATALT - ("QRYSQL")->GCY_DTCLIS)),IIf(cDia == 0 ,"1",Alltrim(Str(cDia)))})     
 oCell := TRCell():New(oSection2,"cDiaInt","QRYSQL","",, 15,,{|| cDiaInt := IIf(Empty(("QRYSQL")->GCY_DATALT),(dDataBase - ("QRYSQL")->GCY_DATATE),(("QRYSQL")->GCY_DATALT - ("QRYSQL")->GCY_DATATE)),IIf(cDiaInt == 0 ,"1",Alltrim(Str(cDiaInt)))})      
 oCell := TRCell():New(oSection2,"cAlt","QRYSQL","",, 7,,{|| cAlt := IIf(Empty(("QRYSQL")->GCY_DATALT),"Não","Sim")})       


Return (oReport)  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R84Imp   ³ Autor ³ Rogerio Tabosa        ³ Data ³ 31/07/08 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/   

Static Function R86IMP(oReport)

 Local oSection1 := oReport:Section(1)
// Local oSection2 := oReport:Section(1):Section(1)
 Local cCondi := "" 
 Local lFilCnv:= .F.

 Private cCond1 := ""
 Private cCond2 := ""
 Private cCond3 := ""
 Private cCond4 := ""
                 
If !Empty(alltrim(cConv_De)) .Or. !Empty(alltrim(cConv_Ate))
	lFilCnv := .T.
	cCondi := " AND GA9.GA9_CODCON BETWEEN '" + cConv_De + "' AND '" + cConv_ate + "'
EndIf
If !Empty(dDatAte_de) .Or. !Empty(dDatAte_ate)
	cCondi += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatAte_de) + "' AND '" + DTOS(dDatAte_ate) + "'"
EndIf

If nAlta == 2
	cCondi += " AND GCY.GCY_DATALT <> '" + Space(TamSx3("GCY_CLISEC")[1]) + "'"
ElseIf nAlta == 3
	cCondi += " AND GCY.GCY_DATALT = '" + Space(TamSx3("GCY_CLISEC")[1]) + "'"
Else
	cCondi += " "
Endif		


 MakeSqlExpr(oReport:uParam)                      
////////////////DBSELECTAREA("GCY") 
 oSection1:BeginQuery() 

cCond1 += "% DISTINCT GCY.GCY_REGATE, GCY.GCY_REGGER,GCY_NOME, GCY.GCY_DATATE,GCY.GCY_HORATE,GCY.GCY_CODCLI,GCY.GCY_CLISEC,GCY.GCY_DATALT, "
cCond1 += " GCW1.GCW_DESCLI DSCLIP,GCW1.GCW_TITISS TICLIP,GCW2.GCW_DESCLI DSCLIS,GCW2.GCW_TITISS TICLIS,  "
cCond1 += " GA9.GA9_CODCON,GA9.GA9_NOME,GCM.GCM_CODPLA,GCM.GCM_DESPLA,GCY.GCY_DTCLIS,GBJ_CRM,RA_NOME %"

cCond2 += "% " + RetSqlName("GCY") + " GCY "
cCond2 += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_REGATE=GCY.GCY_REGATE AND GCZ.GCZ_FILIAL='" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "

cCond2 += " JOIN " + RetSqlName("GA9") + " GA9 ON GA9.GA9_CODCON=GCZ.GCZ_CODCON AND GA9.GA9_FILIAL='" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
cCond2 += " JOIN " + RetSqlName("GCM") + " GCM ON GCM.GCM_CODPLA=GCZ.GCZ_CODPLA AND GCM.GCM_FILIAL='" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
cCond2 += " JOIN " + RetSqlName("GCW") + " GCW1 ON GCW1.GCW_CODCLI=GCY.GCY_CODCLI AND GCW1.GCW_FILIAL='" + xFilial("GCW") + "' AND GCW1.D_E_L_E_T_ <> '*' "
cCond2 += " JOIN " + RetSqlName("GCW") + " GCW2 ON GCW2.GCW_CODCLI=GCY_CLISEC AND GCW2.GCW_FILIAL='" + xFilial("GCW") + "' AND GCW2.D_E_L_E_T_ <> '*' "
cCond2 += " JOIN " + RetSqlName("GBJ") + " GBJ ON GCY.GCY_CODCRM=GBJ.GBJ_CRM AND GBJ.GBJ_FILIAL='" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*' "
cCond2 += " JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_CODIGO=GBJ.GBJ_CRM AND SRA.RA_FILIAL='" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' %"

cCond3 += "% GCY.D_E_L_E_T_ <> '*' " + cCondi + " AND GCY.GCY_CLISEC <> '" + Space(TamSx3("GCY_CLISEC")[1]) + "' AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "'  "
cCond3 += " AND GCZ.GCZ_NRSEQG=(SELECT MAX(GCZ1.GCZ_NRSEQG) FROM  " + RetSqlName("GCZ") + " GCZ1 WHERE GCZ1.GCZ_REGATE=GCY_REGATE " 
cCond3 += " AND GCZ1.GCZ_FILIAL='" + xFilial("GCZ") + "' " + IIf (lFilCnv," AND GCZ1.GCZ_CODCON BETWEEN '" + cConv_De + "' AND '" + cConv_ate + "' ","") + "AND GCZ1.D_E_L_E_T_ <> '*') %"    

cCond4 += "% GCY_DATATE,GCY_NOME,GCY_REGATE %"


BeginSql alias "QRYSQL"
 SELECT   	%Exp:cCond1%
 FROM     	%Exp:cCond2%
 WHERE    	%Exp:cCond3%                                      	
 ORDER BY  %Exp:cCond4% 
EndSql 

oSection1:EndQuery() 
	   
 Fs_CalcTot("2")
	 
 DbSelectArea("QRYSQL")
 DbGoTop()                                                                                                                                

 oSection1:Print() 
 oReport:SetMeter(QRYSQL->(LastRec())) 

 DbSelectArea("QRYSQL")
 DbGoTop()  

If !Eof()
	
	If nQtdObtP > 0 .OR. nQtdObtS > 0 
		cStrPrim += STR0033 + Alltrim(Str(nQtdObtP)) + "  | "
		cStrSecun += STR0034  + Alltrim(Str(nQtdObtS)) + "  | "		
	EndIf
	If nQtdPedS > 0 .OR. nQtdPedP > 0 
		cStrPrim += STR0035 + Alltrim(Str(nQtdPedP)) + "  | "
		cStrSecun += STR0036  + Alltrim(Str(nQtdPedS)) + "  | "		
	EndIf  
	If nQtdPsqP > 0 .OR. nQtdPsqS > 0 
		cStrPrim += STR0037  + Alltrim(Str(nQtdPsqP)) + "  | "
		cStrSecun += STR0038  + Alltrim(Str(nQtdPsqS)) + "  | "		
	EndIf	

	 oReport:SkipLine(2)
	 oReport:PrintText(STR0023 + Alltrim(Str(nQtdAtd)), oReport:Row(), 10) //"Total de Atendimentos: "	 
	 oReport:SkipLine(1) 	 
	 oReport:PrintText(STR0019 + Alltrim(Str(nQtdCliP)), oReport:Row(), 10) //"Total Clin. Prim.: "  
	 oReport:PrintText("|" + STR0021 + Alltrim(Str(nQtdCirP)), oReport:Row(), 430) //"Total Cirur. Primaria: "
	 oReport:PrintText(" |" + cStrPrim + STR0020 + Alltrim(Str(nQtdDMed)), oReport:Row(), 820)//"Total de Diária(s) Médica(s): " 
	 oReport:SkipLine(1) 
	 oReport:PrintText(STR0031 + Alltrim(Str(nQtdCliS)), oReport:Row(), 10) //"Total Clin. Secund.: " 
	 oReport:PrintText("|" + STR0032 + Alltrim(Str(nQtdCirS)), oReport:Row(), 430) //"Total Cirur. Secund: "		
	 oReport:PrintText(" |" + cStrSecun + STR0022 + Alltrim(Str(nQtdDCir)), oReport:Row(), 820)  //"Total de Diária(s) Cirurgica(s): "
	 oReport:SkipLine(1)  
EndIf

Return (Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ Rogerio Tabosa     º Data ³  31/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento. R3            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
          

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local cSql   := ""
Local cCondi := ""
Local nDia	 := 1

If !Empty(alltrim(cConv_De)) .Or. !Empty(alltrim(cConv_Ate))
	cCondi := " AND GA9.GA9_CODCON BETWEEN '" + cConv_De + "' AND '" + cConv_ate + "'
EndIf
If !Empty(dDatAte_de) .Or. !Empty(dDatAte_ate)
	cCondi += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatAte_de) + "' AND '" + DTOS(dDatAte_ate) + "'"
EndIf

If nAlta == 2
	cCondi += " AND GCY.GCY_DATALT <> '" + Space(TamSx3("GCY_CLISEC")[1]) + "'"
ElseIf nAlta == 3
	cCondi += " AND GCY.GCY_DATALT = '" + Space(TamSx3("GCY_CLISEC")[1]) + "'"
Else
	cCondi += " "
Endif

            
cSql := "SELECT GCY.GCY_REGATE, GCY.GCY_REGGER,GCY_NOME, GCY.GCY_DATATE,GCY.GCY_HORATE,GCY.GCY_CODCLI,GCY.GCY_CLISEC,GCY.GCY_DATALT, "
cSql += " GCW1.GCW_DESCLI DSCLIP,GCW1.GCW_TITISS TICLIP,GCW2.GCW_DESCLI DSCLIS,GCW2.GCW_TITISS TICLIS,  "
cSql += " GA9.GA9_CODCON,GA9.GA9_NOME,GCM.GCM_CODPLA,GCM.GCM_DESPLA,GCY.GCY_DTCLIS,GBJ_CRM,RA_NOME "
cSql += " FROM " + RetSqlName("GCY") + " GCY "
cSql += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_REGATE=GCY.GCY_REGATE AND GCZ.GCZ_FILIAL='" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
cSql += " JOIN " + RetSqlName("GA9") + " GA9 ON GA9.GA9_CODCON=GCZ.GCZ_CODCON AND GA9.GA9_FILIAL='" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
cSql += " JOIN " + RetSqlName("GCM") + " GCM ON GCM.GCM_CODPLA=GCZ.GCZ_CODPLA AND GCM.GCM_FILIAL='" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
cSql += " JOIN " + RetSqlName("GCW") + " GCW1 ON GCW1.GCW_CODCLI=GCY.GCY_CODCLI AND GCW1.GCW_FILIAL='" + xFilial("GCW") + "' AND GCW1.D_E_L_E_T_ <> '*' "
cSql += " JOIN " + RetSqlName("GCW") + " GCW2 ON GCW2.GCW_CODCLI=GCY_CLISEC AND GCW2.GCW_FILIAL='" + xFilial("GCW") + "' AND GCW2.D_E_L_E_T_ <> '*' "
cSql += " JOIN " + RetSqlName("GBJ") + " GBJ ON GCY.GCY_CODCRM=GBJ.GBJ_CRM AND GBJ.GBJ_FILIAL='" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*' "
cSql += " JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_CODIGO=GBJ.GBJ_CRM AND SRA.RA_FILIAL='" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "

cSql += " WHERE GCY.D_E_L_E_T_ <> '*' " + cCondi + " AND GCY.GCY_CLISEC <> '" + Space(TamSx3("GCY_CLISEC")[1]) + "' AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "'  "

cSql += " ORDER BY GCY_DATATE,GCY_NOME,GCY_REGATE "

cSql := ChangeQuery(cSql)
TCQUERY cSql NEW ALIAS "QRYSQL" 



//DbSelectArea("QRY")   
dbGotop()

If Eof()     
	HS_MSGINF(STR0025,STR0007,STR0008) // "Nenhum dado foi encontrado para a selecao efetuada!" # "Atenção" # s"Validação relatório Transferencia de Clinicas"
	dbClosearea()
	return()
endif


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

While !EOF()
incRegua()
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica o cancelamento pelo usuario...                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   If lAbortPrint
      @nLin,00 PSAY STR0028 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio. . .                            ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   If nLin > nMaxLin // Salto de Página. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif

   // Coloque aqui a logica da impressao do seu programa...
   // Utilize PSAY para saida na impressora. Por exemplo:
   // @nLin,00 PSAY SA1->A1_COD
   //"Codigo  Nome    				                Data e Hora Atend.   Convenio/Plano   Descrição           CRM     Médico               Clinica Primaria         Dia(s) Clin. Secund.        Dia(s)   Dias Internado    Alta"

	cCabAux2 := ""
	cCabAux3 := ""
	cCabAux4 := ""
	@nLin, 001 Psay "" + QRYSQL->GCY_REGATE
	@nLin, 008 Psay Alltrim(QRYSQL->GCY_NOME)
	@nLin, 037 Psay DTOC(STOD(QRYSQL->GCY_DATATE)) + "  " + QRYSQL->GCY_HORATE 
	@nLin, 058 Psay Alltrim(QRYSQL->GA9_CODCON) + "/"
	@nLin, 062 Psay Alltrim(QRYSQL->GCM_CODPLA)
	@nLin, 071 Psay Alltrim(QRYSQL->GA9_NOME) + " - " + Alltrim(QRYSQL->GCM_DESPLA)
	@nLin, 092 Psay Alltrim(QRYSQL->GBJ_CRM) + " " + Alltrim(QRYSQL->RA_NOME)
	@nLin, 132 Psay Alltrim(QRYSQL->DSCLIP)
	
	nDia := (STOD(QRYSQL->GCY_DTCLIS) - STOD(QRYSQL->GCY_DATATE))
	@nLin, 155 Psay IIf(nDia ==0,1,nDia)
	@nLin, 162 Psay Alltrim(QRYSQL->DSCLIS)
	
	nDia := IIf(Empty(QRYSQL->GCY_DATALT),(dDataBase - STOD(QRYSQL->GCY_DTCLIS)),(STOD(QRYSQL->GCY_DATALT) - STOD(QRYSQL->GCY_DTCLIS)))
	@nLin, 184 Psay IIf(nDia ==0,1,nDia) 
	                                  
	nDia := IIf(Empty(QRYSQL->GCY_DATALT),(dDataBase - STOD(QRYSQL->GCY_DATATE)),(STOD(QRYSQL->GCY_DATALT) - STOD(QRYSQL->GCY_DATATE)))	
	@nLin, 195 Psay IIf(nDia ==0,1,nDia) 
	@nLin, 209 Psay IIf(Empty(QRYSQL->GCY_DATALT),STR0026,STR0027)	// Nao //Sim
	nLin++
	
	dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo         
nLin += 2

Fs_CalcTot("1") 


If nLin < 8
	nLin := 8
EndIf

If nQtdObtP > 0 .OR. nQtdObtS > 0 
	cStrPrim += STR0033 + Alltrim(Str(nQtdObtP)) + "  | "
	cStrSecun += STR0034  + Alltrim(Str(nQtdObtS)) + "  | "		
EndIf
If nQtdPedS > 0 .OR. nQtdPedP > 0 
	cStrPrim += STR0035 + Alltrim(Str(nQtdPedP)) + "  | "
	cStrSecun += STR0036  + Alltrim(Str(nQtdPedS)) + "  | "		
EndIf  
If nQtdPsqP > 0 .OR. nQtdPsqS > 0 
	cStrPrim += STR0037  + Alltrim(Str(nQtdPsqP)) + "  | "
	cStrSecun += STR0038  + Alltrim(Str(nQtdPsqS)) + "  | "		
EndIf	

@nLin, 001 Psay STR0023 + Alltrim(Str(nQtdAtd))//"Total de Atendimentos: "
nLin ++
@nLin, 001 Psay STR0019 + Alltrim(Str(nQtdCliP)) //"Total Clinica Primaria: "  
@nLin, 029 Psay "|" + STR0021 + Alltrim(Str(nQtdCirP))//"Total Cirur. Primaria: " 
@nLin, 056 Psay "|" + cStrPrim + STR0020 + Alltrim(Str(nQtdDMed))//"Total de Diária(s) Médica(s): "	
nLin++
@nLin, 001 Psay STR0031 + Alltrim(Str(nQtdCliS))//"Total Clin. Secund.: " 
@nLin, 029 Psay "|" + STR0032 + Alltrim(Str(nQtdCirS)) //"Total Cirur. Secund: "
@nLin, 056 Psay "|" + cStrSecun + STR0022 + Alltrim(Str(nQtdDCir))//"Total de Diária(s) Cirurgica(s): "	


  
			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("QRYSQL")
DbCloseArea()

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

// CALCULA OS TOTAIS PARA APRESENTACAO NO RELATORIO
Static Function Fs_CalcTot(cRel)                 

Default cRel := "1"

DbSelectArea("QRYSQL")
DbGoTop()

If cRel == "1"
	While QRYSQL->(!Eof())
		nQtdAtd ++
		
		If QRYSQL->TICLIP == "01" .OR. QRYSQL->TICLIP == "04" .OR. QRYSQL->TICLIP == "05" //1=CLINICA,2=CIRURGICA,3=OBSTETRICA,4=PEDIATRICA,5=PSIQUIATRICA
			IIf(QRYSQL->TICLIP == "01",nQtdCliP ++,IIf(QRYSQL->TICLIP == "04",nQtdPedP ++,nQtdPsqP ++))
			nDia := (STOD(QRYSQL->GCY_DTCLIS) - IIF(Empty(QRYSQL->GCY_DATATE),dDataBase,STOD(QRYSQL->GCY_DATATE))) 
			nQtdDMed += IIf(nDia == 0, 1,nDia)
		ElseIf QRYSQL->TICLIP == "02" .OR. QRYSQL->TICLIP == "03"
			IIf(QRYSQL->TICLIP == "02",nQtdCirP ++,nQtdObtP ++)
			nDia := (STOD(QRYSQL->GCY_DTCLIS) - IIF(Empty(QRYSQL->GCY_DATATE),dDataBase,STOD(QRYSQL->GCY_DATATE)))
			nQtdDCir += IIf(nDia == 0, 1,nDia)
		EndIf
		
		If QRYSQL->TICLIS == "01" .OR. QRYSQL->TICLIS == "04" .OR. QRYSQL->TICLIS == "05"
			IIf(QRYSQL->TICLIS == "01",nQtdCliS ++,IIf(QRYSQL->TICLIS == "04",nQtdPedS ++,nQtdPsqS ++))
			nDia := (IIF(Empty(QRYSQL->GCY_DATALT),dDataBase,STOD(QRYSQL->GCY_DATALT)) - STOD(QRYSQL->GCY_DTCLIS))
			nQtdDMed += IIf(nDia == 0, 1,nDia)
		ElseIf QRYSQL->TICLIS == "02" .OR. QRYSQL->TICLIS == "03"
			IIf(QRYSQL->TICLIS == "02",nQtdCirS ++,nQtdObtS ++)
			nDia := (IIF(Empty(QRYSQL->GCY_DATALT),dDataBase,STOD(QRYSQL->GCY_DATALT)) - STOD(QRYSQL->GCY_DTCLIS))
			nQtdDCir += IIf(nDia == 0, 1,nDia)
		EndIf 
		DbSkip()
	End 
Else 
	While QRYSQL->(!Eof())
		nQtdAtd ++
		
		If QRYSQL->TICLIP == "01" .OR. QRYSQL->TICLIP == "04" .OR. QRYSQL->TICLIP == "05" //1=CLINICA,2=CIRURGICA,3=OBSTETRICA,4=PEDIATRICA,5=PSIQUIATRICA
			IIf(QRYSQL->TICLIP == "01",nQtdCliP ++,IIf(QRYSQL->TICLIP == "04",nQtdPedP ++,nQtdPsqP ++))
			nDia := (QRYSQL->GCY_DTCLIS - IIF(Empty(QRYSQL->GCY_DATATE),dDataBase,QRYSQL->GCY_DATATE))
			nQtdDMed += IIf(nDia == 0, 1,nDia)
		ElseIf QRYSQL->TICLIP == "02" .OR. QRYSQL->TICLIP == "03"
			IIf(QRYSQL->TICLIP == "02",nQtdCirP ++,nQtdObtP ++)
			nDia := (QRYSQL->GCY_DTCLIS - IIF(Empty(QRYSQL->GCY_DATATE),dDataBase,QRYSQL->GCY_DATATE))
			nQtdDCir += IIf(nDia == 0, 1,nDia)
		EndIf
		
		If QRYSQL->TICLIS == "01" .OR. QRYSQL->TICLIS == "04" .OR. QRYSQL->TICLIS == "05"
			IIf(QRYSQL->TICLIS == "01",nQtdCliS ++,IIf(QRYSQL->TICLIS == "04",nQtdPedS ++,nQtdPsqS ++))
			nDia := (IIF(Empty(QRYSQL->GCY_DATALT),dDataBase,QRYSQL->GCY_DATALT) - QRYSQL->GCY_DTCLIS)
			nQtdDMed += IIf(nDia == 0, 1,nDia)
		ElseIf QRYSQL->TICLIS == "02" .OR. QRYSQL->TICLIS == "03"
			IIf(QRYSQL->TICLIS == "02",nQtdCirS ++,nQtdObtS ++)
			nDia := (IIF(Empty(QRYSQL->GCY_DATALT),dDataBase,QRYSQL->GCY_DATALT) - QRYSQL->GCY_DTCLIS)
			nQtdDCir += IIf(nDia == 0, 1,nDia)
		EndIf 
		DbSkip()
	End 
EndIf


Return()
