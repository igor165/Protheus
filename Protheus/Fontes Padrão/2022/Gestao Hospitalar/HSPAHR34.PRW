#INCLUDE "HSPAHR34.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HRPAHR34R3º Autor ³ Heimdall           º Data ³  04/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorios estatisticos                                    º±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHR34()
 Local   cDesc1      := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local   cDesc2      := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local   cDesc3      := STR0003 //"Estatistica Reserva Médico/Proc./Convênio"
 Local   aOrd        := {}
 Local   nMes        := 0
 
 Private Cabec1      := ""
 Private Cabec2      := "" 
 Private cTitulo     := STR0003 //"Estatistica Reserva Médico/Proc./Convênio"
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 132
 Private Tamanho     := "M"
 Private NomeProg    := "HSPAHR34"
 Private nTipo       := 18
 Private aReturn     := {STR0004, 1, STR0005, 2, 2, 1, "", 1}  //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private m_Pag       := 01
 Private wnRel       := NomeProg
 Private nTam        := 132
 Private cCodLoc_De  := ""
 Private cCodLoc_Ate := ""
 Private cCodMed_De  := ""
 Private cCodMed_Ate := ""
 Private cCodPla_De  := ""
 Private cCodPla_Ate := ""
 Private cAnoMes     := ""
 Private nMesesRetr  := 0
 Private nOrdem      := 0 
 Private nGrafico    := 0 
 Private cCodImp     := ""
 Private nMaxLin     := 0 
 Private lVerif      := .F. // Usado para entrar no R3 ou no R4
 Private aMesesR     := Array(12)
 Private nTotGeral   := 0
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ PARAMETROS                                                          ³
 //³ MV_PAR01	Do setor                                                   ³  
 //³ MV_PAR02	Ate o setor                                                ³
 //³ MV_PAR03	Do medico                                                  ³
 //³ MV_PAR04	Ate o medico                                               ³
 //³ MV_PAR05	Do plano                                                   ³
 //³ MV_PAR06	Ate o plano                                                ³
 //³ MV_PAR07	Ano/mes referencia                                         ³
 //³ MV_PAR08	Numero retroativo de meses para calculo da media           ³
 //³ MV_PAR09	Ordem de impressao (1=Col Mes Ref. 2= Total 3 = Media)     ³  
 //³ MV_PAR10	Emite grafico (1=Nenhum 2=Mes Referencia 3= Total 4= Media |
 //| MV_PAR11 Impressora                                                 |
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
  Pergunte("HSPR34",.F.)
  lVerif := .T.
 Else  
  If !Pergunte("HSPR34",.T.)
   Return()
  EndIf
 EndIf
 
 cCodLoc_De  := mv_par01
 cCodLoc_Ate := mv_par02
 cCodMed_De  := mv_par03
 cCodMed_Ate := mv_par04
 cCodPla_De  := mv_par05
 cCodPla_Ate := mv_par06 
 cAnoMes     := Substr(DtoS(cToD("01/" + Substr(mv_par07, 1, 2) + "/" + Substr(mv_par07, 4, 4))) ,1, 6)
 nMesesRetr  := mv_par08
 nOrdem      := mv_par09
 nGrafico    := mv_par10
 cCodImp     := mv_par11
 nMaxLin     := HS_MaxLin(cCodImp)   
           
 aMesesR     := Array(12)
 aMesesR[12] := cAnoMes
 For nMes := 11 to 1 Step -1
     aMesesR[nMes] := FS_MesRetr(aMesesR[nMes+1])
 Next nMes
 
 If lVerif
  pergunte("HSPR34",.F.)
  oReport := ReportDef() 
  oReport:PrintDialog() 
 Else
  wnrel := SetPrint("GMJ", NomeProg, "", @cTitulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
  If nLastKey == 27
   Return()
  Endif
  SetDefault(aReturn, "GMJ")
  If nLastKey == 27
   Return()
  Endif

  aReturn[4] := 2
  nTipo := If(aReturn[4]==1,15,18)
  RptStatus({|| RunReport(STR0028) }, cTitulo) //"Reserva Médico/Proc./convênio"
 EndIf
 
Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³REPORTDEF ³ Autor ³ Heimdal B. Castro     ³ Data ³ 04/09/07 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2, oSection3, oSection4, oSection5
 Local oCell
 Local oTotaliz1, oTotaliz2
 Local oBreak
 Local nMes := 0 
 Local aDescMes := {STR0006,STR0007,STR0008,STR0008,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0017} //" Jan"###" Fev"###" Mar"###" Abr"###" Mai"###" Jun"###" Jul"###" Ago"###" Set"###" Out"###" Nov"###" Dez"

 oReport := TReport():New("HSPAHR34",STR0003,"HSPR34",{|oReport| R34IMP(oReport)}, STR0001 + STR0002)
//###"Estatistica Agenda Marcada por "### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."

 oReport:SetTotalInLine(.F.)
 
 oSection1 := TRSection():New(oReport, "MEDICO", "QRYSQL")
 oSection1:SetHeaderPage(.F.)
 oSection1:SetHeaderBreak(.F.)
 oSection1:SetHeaderSection(.T.)
 oSection1:SetTotalInLine(.F.)      
 
 oCell := TRCell():New(oSection1,"cMed","QRYSQL","",, 30,,{|| cMed := 'Médico: ' + ("QRYSQL")->MEDICO}) 
 
 oSection2 := TRSection():New(oSection1, "PROCEDIMENTO", "QRYSQL")
 oSection2:SetHeaderPage(.F.)
 oSection2:SetHeaderBreak(.F.) 
 oSection2:SetHeaderSection(.F.)  
 oSection2:SetTotalInLine(.F.)              
 
 oCell := TRCell():New(oSection2,"cProc","QRYSQL","",, 30,,{|| cProc := 'Procedimento: ' + ("QRYSQL")->PROCEDIMENTO}) 
                                  
 oSection3 := TRSection():New(oSection2, "USUARIO", "QRYSQL")
 oSection3:SetHeaderPage(.F.)
 oSection3:SetHeaderBreak(.F.)
 oSection3:SetHeaderSection(.F.)  
 oSection3:SetTotalInLine(.F.)              
 
 oCell := TRCell():New(oSection3,"USUARIO","QRYSQL","",, 30)                                              // 16-Parametro
 
 oCell := TRCell():New(oSection3,"MES" + Substr(aMesesR[01], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection3,"MES" + Substr(aMesesR[02], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection3,"MES" + Substr(aMesesR[03], 5, 2),"QRYSQL","",, 6)                                             
 oCell := TRCell():New(oSection3,"MES" + Substr(aMesesR[04], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection3,"MES" + Substr(aMesesR[05], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection3,"MES" + Substr(aMesesR[06], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection3,"MES" + Substr(aMesesR[07], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection3,"MES" + Substr(aMesesR[08], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection3,"MES" + Substr(aMesesR[09], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection3,"MES" + Substr(aMesesR[10], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection3,"MES" + Substr(aMesesR[11], 5, 2),"QRYSQL","",, 6)                                               
 oCell := TRCell():New(oSection3,"MES" + Substr(aMesesR[12], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection3,"TOTA","QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection3,"nPorc","QRYSQL","","@E 999.99", 6,,{|| nPorc := (("QRYSQL")->TOTA/nTotGeral)*100})                                               
 oCell := TRCell():New(oSection3,"nMedia","QRYSQL","",, 6,,{|| nMedia := FS_Media({("QRYSQL")->&("MES" + Substr(aMesesR[01], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[02], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[03], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[04], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[05], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[06], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[07], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[08], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[09], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[10], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[11], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[12], 5, 2))})})
 
 oSection4 := TRSection():New(oSection3, "")
 oSection4:SetHeaderPage(.T.)
 oSection4:SetHeaderBreak(.F.)  
 oSection4:SetTotalInLine(.F.)              
 
 oSection5 := TRSection():New(oSection4,"")
 oSection5:SetHeaderPage(.T.) 
 oSection5:SetHeaderBreak(.F.)
 oSection5:SetTotalInLine(.F.)
             
 oCell := TRCell():New(oSection4,"",,"",,34)                                                   // 02-Parametro
 oCell := TRCell():New(oSection5,".",,,,34)

 For nMes := 1 to 12
  oCell := TRCell():New(oSection4, aDescMes[Val(Substr(aMesesR[nMes], 5, 2))],,,,6)                   // 03-Mês
  oCell := TRCell():New(oSection5, Substr(aMesesR[nMes], 1, 4),,,,6)                                   // 04-Ano
 Next nMes  
 
 oCell := TRCell():New(oSection4, "Total",,,,6)                   // 05-Total
 oCell := TRCell():New(oSection4, " (%) ",,,,6)                   // 06-Porcentagem
 oCell := TRCell():New(oSection4, "Média",,,,6)                   // 06-Media
 
 oCell := TRCell():New(oSection5, "      ",,,,6)                   // 05-Total
 oCell := TRCell():New(oSection5, "      ",,,,6)                   // 06-Porcentagem
 oCell := TRCell():New(oSection5, "   (" + AllTrim(STR(nMesesRetr)) + "M)",,,,6)                   // 06-Media
                                                             

 oSection2:SetTotalText("TOTAL DO PROCEDIMENTO")  
 oSection1:SetTotalText("TOTAL DO MEDICO")                                                              

For nMes := 1 to 12
	DEFINE FUNCTION FROM oSection3:Cell("MES" + Substr(aMesesR[nMes], 5, 2)) OF oSection2 FUNCTION SUM TITLE "Total do Procedimento"   NO END REPORT 
	DEFINE FUNCTION FROM oSection3:Cell("MES" + Substr(aMesesR[nMes], 5, 2)) OF oSection1 FUNCTION SUM TITLE "Total do Médico"   NO END REPORT
Next nMes                                                                                                                                          

DEFINE FUNCTION FROM oSection3:Cell("TOTA") OF oSection2 FUNCTION SUM TITLE "Total do Procedimento"   NO END REPORT 
DEFINE FUNCTION FROM oSection3:Cell("nMedia") OF oSection2 FUNCTION SUM TITLE "Total do Procedimento"   NO END REPORT 

DEFINE FUNCTION FROM oSection3:Cell("TOTA") OF oSection1 FUNCTION SUM TITLE "Total do Médico"   NO END REPORT 
DEFINE FUNCTION FROM oSection3:Cell("nMedia") OF oSection1 FUNCTION SUM TITLE "Total do Médico"   NO END REPORT 

Return( oReport )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R34Imp   ³ Autor ³ Heimdall B. Castro    ³ Data ³ 04/09/07 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function R34IMP(oReport)
 
 Local oSection1 := oReport:Section(1)
 Local oSection2 := oReport:Section(1):Section(1)
 Local oSection3 := oReport:Section(1):Section(1):Section(1)
 Local oSection4 := oReport:Section(1):Section(1):Section(1):Section(1)
 
 Local cSubStrMes := ""
 Local cSubStrAno := ""
 Local cSubStr    := ""
 Local cSubStrDsc := ""
 
// Local oSection5 := oReport:Section(1):Section(1):Section(1):Section(1):Section(1)

 //-- Transforma parametros Range em expressao SQL  
 
 If "MSSQL" $ TcGetDb()
  cSubStrMes := " SUBSTRING(GMJ.GMJ_DATAGE, 5, 2) "
  cSubStrAno := " SUBSTRING(GMJ.GMJ_DATAGE, 1, 4) "
  cSubStr    := " SUBSTRING(GMJ.GMJ_DATAGE, 1, 6) "
  cSubStrDsc := " SUBSTRING(GA7.GA7_DESC,1,40) "
 Else
  cSubStrMes := " SUBSTR(GMJ.GMJ_DATAGE, 5, 2) "
  cSubStrAno := " SUBSTR(GMJ.GMJ_DATAGE, 1, 4) "
  cSubStr    := " SUBSTR(GMJ.GMJ_DATAGE, 1, 6) "
  cSubStrDsc := " SUBSTR(GA7.GA7_DESC,1,40) "
 EndIf
 
 MakeSqlExpr(oReport:uParam)                      
 
 oSection1:BeginQuery() 
 
cCond1 := "% MEDICO, PROCEDIMENTO, USUARIO, SUM(TOTAL) TOTA,SUM(MES01) MES01,SUM(MES02) MES02, "
cCond1 += " SUM(MES03) MES03,SUM(MES04) MES04,SUM(MES05) MES05,SUM(MES06) MES06,SUM(MES07) MES07, "
cCond1 += " SUM(MES08) MES08,SUM(MES09) MES09,SUM(MES10) MES10,SUM(MES11) MES11,SUM(MES12) MES12 %"

cCond2 := "% (SELECT SRA.RA_NOME MEDICO, " + cSubStrAno + " ANO, "
cCond2 += cSubStrMes + " MES, " + cSubStrDsc + " PROCEDIMENTO, "
cCond2 += " GA9.GA9_NREDUZ USUARIO, COUNT(DISTINCT GMJ.GMJ_SEQAGE) TOTAL, "
cCond2 += " CASE " + cSubStrMes + " WHEN '" + Substr(aMesesR[01], 5, 2) + "' THEN COUNT(DISTINCT GMJ.GMJ_SEQAGE) ELSE 0 END MES" + Substr(aMesesR[01], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes + " WHEN '" + Substr(aMesesR[02], 5, 2) + "' THEN COUNT(DISTINCT GMJ.GMJ_SEQAGE) ELSE 0 END MES" + Substr(aMesesR[02], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes + " WHEN '" + Substr(aMesesR[03], 5, 2) + "' THEN COUNT(DISTINCT GMJ.GMJ_SEQAGE) ELSE 0 END MES" + Substr(aMesesR[03], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes + " WHEN '" + Substr(aMesesR[04], 5, 2) + "' THEN COUNT(DISTINCT GMJ.GMJ_SEQAGE) ELSE 0 END MES" + Substr(aMesesR[04], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes + " WHEN '" + Substr(aMesesR[05], 5, 2) + "' THEN COUNT(DISTINCT GMJ.GMJ_SEQAGE) ELSE 0 END MES" + Substr(aMesesR[05], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes + " WHEN '" + Substr(aMesesR[06], 5, 2) + "' THEN COUNT(DISTINCT GMJ.GMJ_SEQAGE) ELSE 0 END MES" + Substr(aMesesR[06], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes + " WHEN '" + Substr(aMesesR[07], 5, 2) + "' THEN COUNT(DISTINCT GMJ.GMJ_SEQAGE) ELSE 0 END MES" + Substr(aMesesR[07], 5, 2) + ", "
ccond2 += " CASE " + cSubStrMes + " WHEN '" + Substr(aMesesR[08], 5, 2) + "' THEN COUNT(DISTINCT GMJ.GMJ_SEQAGE) ELSE 0 END MES" + Substr(aMesesR[08], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes + " WHEN '" + Substr(aMesesR[09], 5, 2) + "' THEN COUNT(DISTINCT GMJ.GMJ_SEQAGE) ELSE 0 END MES" + Substr(aMesesR[09], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes + " WHEN '" + Substr(aMesesR[10], 5, 2) + "' THEN COUNT(DISTINCT GMJ.GMJ_SEQAGE) ELSE 0 END MES" + Substr(aMesesR[10], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes + " WHEN '" + Substr(aMesesR[11], 5, 2) + "' THEN COUNT(DISTINCT GMJ.GMJ_SEQAGE) ELSE 0 END MES" + Substr(aMesesR[11], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes + " WHEN '" + Substr(aMesesR[12], 5, 2) + "' THEN COUNT(DISTINCT GMJ.GMJ_SEQAGE) ELSE 0 END MES" + Substr(aMesesR[12], 5, 2) + "  "
cCond2 += " FROM " + RetSqlName("GMJ") + " GMJ , " + RetSqlName("SRA") + " SRA , " + RetSqlName("GA7") + " GA7 , " + RetSqlName("GA9") + " GA9 , " + RetSqlName("GCM") + " GCM %"

cCond3 := "% GMJ.GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ.D_E_L_E_T_ <> '*'   AND SRA.RA_CODIGO  = GMJ.GMJ_CODCRM "  
cCond3 += " AND GA7.GA7_CODPRO = GMJ.GMJ_CODPRO   AND GCM.GCM_CODPLA = GMJ.GMJ_CODPLA "  
cCond3 += " AND GA9.GA9_CODCON = GCM.GCM_CODCON   AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "  
cCond3 += " AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*'   AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' "
cCond3 += " AND GA9.D_E_L_E_T_ <> '*'   AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
cCond3 += " AND GMJ.GMJ_CODLOC BETWEEN '" + cCodLoc_De + "' AND '" + cCodLoc_Ate + "' "
cCond3 += " AND GMJ.GMJ_CODCRM BETWEEN '" + cCodMed_De + "' AND '" + cCodMed_Ate + "' "
cCond3 += " AND GMJ.GMJ_CODPLA BETWEEN '" + cCodPla_De + "' AND '" + cCodPla_Ate + "' "
cCond3 += " AND " + cSubStr + " BETWEEN '" + aMesesR[1] + "' AND '" + aMesesR[12] + "' %"    

cCond4 := "% SRA.RA_NOME, " + cSubStrAno + ", " + cSubStrMes + ", "
cCond4 += " " + cSubStrDsc + ", GA9.GA9_NREDUZ) DUAL %"

cCond5 := "% MEDICO, PROCEDIMENTO, USUARIO %"

BeginSql alias "QRYSQL"
 SELECT   %Exp:cCond1%
 FROM     %Exp:cCond2%
 WHERE    %Exp:cCond3% 
 GROUP BY %Exp:cCond4%
 GROUP BY %Exp:cCond5%
EndSql 
 
	oSection1:EndQuery() 
	
 DbSelectArea("QRYSQL")
 DbGoTop()

 While !EOF()
  nTotGeral := nTotGeral + QRYSQL->TOTA
  DbSkip()
 EndDo
	
 DbGoTop()                                                                                                                                
 
 oSection2:SetParentQuery()
	oSection2:SetParentFilter( {|G| ("QRYSQL")->MEDICO  == G }, {|| ("QRYSQL")->MEDICO } )     // Quebra por procedimento/medico por pagina

 oSection3:SetParentQuery()                                                                           
	oSection3:SetParentFilter( {|P| ("QRYSQL")->PROCEDIMENTO + ("QRYSQL")->MEDICO  == P }, {|| ("QRYSQL")->PROCEDIMENTO + ("QRYSQL")->MEDICO } )// Quebra por procedimento/medico por medico/procedimento

 oSection4:SetParentQuery()                                                                           
	oSection4:SetParentFilter( {|M| ("QRYSQL")->USUARIO == M }, {|| ("QRYSQL")->USUARIO } )    // Quebra por procedimento/medico por medico/procedimento

 oSection1:Print() 
 oReport:SetMeter(QRYSQL->(LastRec())) 

Return( NIL ) 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ Luiz Pereira S. Jr.º Data ³  04/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Rotina de execucao do relatorio                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunReport(cSubTitulo)
 Local cSql      := ""
 Local nMes      := 0
 Local nPosPar   := 0
 Local cParam    := "" 
 Local cCodMed   := ""
 Local cCodProc  := ""
 Local nForJoin  := 0
 Local cAlias    := ""
 Local cPref     := ""
 Local aDescMes  := {STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0017} //" Jan"###" Fev"###" Mar"###" Abr"###" Mai"###" Jun"###" Jul"###" Ago"###" Set"###" Out"###" Nov"###" Dez"
 Local aGrafico  := {}
 Local cTitGrf   := ""
 Local nPar      := 0
 Local nValGra   := 0
 Local cTitGra   := ""
 Local cSqlTmp   := ""
 Local aUsuario  := {}  
 
 Local cSubStrMes := ""
 Local cSubStrAno := ""
 Local cSubStr    := ""
 Local cSubStrDsc := ""

 Private aParam   := {}
 Private aParam1  := {}
 Private aMedico  := {}
 Private aProced  := {}
 Private aResumo  := {}
 Private aGeral   := {}
// Private aMesesR  := Array(12)
 Private nLin     := nMaxLin + 1
 Private nPosC1   := 15
 Private nPosC2   := 16

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Monta array com os meses retroativos ao Ano/Mes informado        ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
 aMesesR     := Array(12)
 aMesesR[12] := cAnoMes
 For nMes := 11 to 1 Step -1
     aMesesR[nMes] := FS_MesRetr(aMesesR[nMes+1])
 Next nMes
*/
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Montagem do cabecalho do relatorio                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Cabec1 := Padr(cSubTitulo, 40)
 Cabec2 := Space(Len(Cabec1))
 For nMes := 1 to 12
    Cabec1 += Space(02) + aDescMes[Val(Substr(aMesesR[nMes], 5, 2))]
    Cabec2 += Space(02) + Substr(aMesesR[nMes], 1, 4)
 Next nMes
 Cabec1 += " " + PADR(STR0018, 6) + " " + PADC("(%)", 6) + " " + PADR(STR0019, 5) //"Total"###"Media"
 Cabec2 += SPACE(15) + PADR("(" + AllTrim(Str(nMesesRetr)) + "M" + ")", 5)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Selecao dos dados                                                ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ      
 
 If "MSSQL" $ TcGetDb()
  cSubStrMes := " SUBSTRING(GMJ.GMJ_DATAGE, 5, 2) "
  cSubStrAno := " SUBSTRING(GMJ.GMJ_DATAGE, 1, 4) "
  cSubStr    := " SUBSTRING(GMJ.GMJ_DATAGE, 1, 6) "
  cSubStrDsc := " SUBSTRING(GA7.GA7_DESC,1,40) "
 Else
  cSubStrMes := " SUBSTR(GMJ.GMJ_DATAGE, 5, 2) "
  cSubStrAno := " SUBSTR(GMJ.GMJ_DATAGE, 1, 4) "
  cSubStr    := " SUBSTR(GMJ.GMJ_DATAGE, 1, 6) "
  cSubStrDsc := " SUBSTR(GA7.GA7_DESC,1,40) "
 EndIf
 
 cSql:= "SELECT SRA.RA_NOME MEDICO, " + cSubStr + " DATAGE, "
 cSql+= cSubStrDsc + " PROCEDIMENTO, GA9.GA9_NREDUZ USUARIO, "
 cSql+= "COUNT(DISTINCT GMJ.GMJ_SEQAGE) VALOR "
 cSql+= "FROM " + RetSqlName("GMJ") + " GMJ , " 
 cSql+=           RetSqlName("SRA") + " SRA , "
 cSql+=           RetSqlName("GA7") + " GA7 , "
 cSql+=           RetSqlName("GA9") + " GA9 , "
 cSql+=           RetSqlName("GCM") + " GCM "
 cSql+= "WHERE GMJ.GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ.D_E_L_E_T_ <> '*' "
 cSql+= "  AND SRA.RA_CODIGO  = GMJ.GMJ_CODCRM "
 cSql+= "  AND GA7.GA7_CODPRO = GMJ.GMJ_CODPRO "
 cSQL+= "  AND GCM.GCM_CODPLA = GMJ.GMJ_CODPLA "
 cSql+= "  AND GA9.GA9_CODCON = GCM.GCM_CODCON "
 cSql+= "  AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
 cSql+= "  AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cSql+= "  AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
 cSql+= "  AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
 If !Empty(cCodLoc_De)
    cSql += "AND GMJ.GMJ_CODLOC >= '" + cCodLoc_De + "' "
 Endif 
 If !Empty(cCodLoc_Ate)
    cSQL += "AND GMJ.GMJ_CODLOC <= '" + cCodLoc_Ate + "' "
 Endif
 
 If !Empty(cCodMed_De)
    cSQL += "AND GMJ.GMJ_CODCRM >= '" + cCodMed_De + "' "
 EndIf
 If !Empty(cCodMed_Ate)
    cSQL += "AND GMJ.GMJ_CODCRM <= '" + cCodMed_Ate + "' "
 EndIf
  
 If !Empty(cCodPla_De)
    cSQL += "AND GMJ.GMJ_CODPLA >= '" + cCodPla_De + "' "
 Endif
 If !Empty(cCodPla_Ate)
    cSQL += "AND GMJ.GMJ_CODPLA <= '" + cCodPla_Ate + "' "
 Endif                       

 cSQL += "AND " + cSubStr + " BETWEEN '" + aMesesR[1] + "' AND '" + aMesesR[12] + "' "
 cSQL += ExecFilt()
 cSQL += "GROUP BY SRA.RA_NOME, " + cSubStr + ", " + cSubStrDsc + ", GA9.GA9_NREDUZ"
 cSQL += " ORDER BY SRA.RA_NOME, " + cSubStrDsc

 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")

 DbGoTop()
 If Eof()
    HS_MsgInf(STR0020,STR0026,STR0027) //"Nenhum dado foi encontrado para a selecao efetuada." //"Atenção"###"Relatorios estatisticos"
    DbCloseArea()
    Return()
 Endif
// aUsuario:= ALLUSERS()
 //ascan(aUsuario,cUserName,2)
//    cNomUsu := aUsuario[aScan(aParam, {|x| x[2] == cUserName})][2]
 //__UserID 
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Emissao do relatorio                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 cTitGrf := AllTrim(cTitulo)
 cTitulo := AllTrim(cTitulo) //+ " - " + IIF(nTipRel == 1, STR0027, STR0029)  //"Analitico"###"Sintetico"
 cTitulo += " (" +  IIF(nOrdem==1, STR0021, ; //"Mes Referencia"
                    IIF(nOrdem==2, STR0018,STR0019)) + ")" //"Total"###"Media"
 aGeral  := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, STR0022, STR0018} //"R E S U M O"###"Total" //"R E S U M O"###"Total"

 SetRegua(1000)         

 aProced := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, STR0029 + QRY->PROCEDIMENTO, STR0030} //"Procedimento:"###"Total do Procedimento"
 aMedico := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, STR0023 + QRY->MEDICO, STR0024} //"Medico:"###"Total do Medico"
 FS_Cabec(cTitulo)                                   
 nLin += 1
 @nLin, 000 PSAY Padr(aMedico[15], 40)         
 nLin += 1
 @nLin, 000 PSAY Padr(aProced[15], 40)         
 cCodMed := QRY->MEDICO             
 cCodProc := QRY->PROCEDIMENTO
 While !Eof()                                                                                
    IncRegua()
  
    If QRY->MEDICO <> cCodMed
		 FS_Total(cTitulo, aParam1, aProced)
    @nLin, 000 PSAY Padr(aProced[16], 40)         
    @nLin, 041 PSAY TRANSFORM(aProced[01], "@E 99999")
 		 @nLin, 047 PSAY TRANSFORM(aProced[02], "@E 99999")
 		 @nLin, 053 PSAY TRANSFORM(aProced[03], "@E 99999")
 		 @nLin, 059 PSAY TRANSFORM(aProced[04], "@E 99999")
 		 @nLin, 065 PSAY TRANSFORM(aProced[05], "@E 99999")
 		 @nLin, 071 PSAY TRANSFORM(aProced[06], "@E 99999")
 		 @nLin, 077 PSAY TRANSFORM(aProced[07], "@E 99999")
 		 @nLin, 083 PSAY TRANSFORM(aProced[08], "@E 99999")
 		 @nLin, 089 PSAY TRANSFORM(aProced[09], "@E 99999")
 		 @nLin, 095 PSAY TRANSFORM(aProced[10], "@E 99999")
 		 @nLin, 101 PSAY TRANSFORM(aProced[11], "@E 99999")
 		 @nLin, 107 PSAY TRANSFORM(aProced[12], "@E 99999")
 		 @nLin, 113 PSAY TRANSFORM(aProced[13], "@E 999999")
 		 @nLin, 127 PSAY TRANSFORM(aProced[14], "@E 99999")
  		 nLin += 1
    @nLin, 000 PSAY Padr(aMedico[16], 40)         
    @nLin, 041 PSAY TRANSFORM(aMedico[01], "@E 99999")
 		 @nLin, 047 PSAY TRANSFORM(aMedico[02], "@E 99999")
 		 @nLin, 053 PSAY TRANSFORM(aMedico[03], "@E 99999")
 		 @nLin, 059 PSAY TRANSFORM(aMedico[04], "@E 99999")
 		 @nLin, 065 PSAY TRANSFORM(aMedico[05], "@E 99999")
 		 @nLin, 071 PSAY TRANSFORM(aMedico[06], "@E 99999")
 		 @nLin, 077 PSAY TRANSFORM(aMedico[07], "@E 99999")
 		 @nLin, 083 PSAY TRANSFORM(aMedico[08], "@E 99999")
 		 @nLin, 089 PSAY TRANSFORM(aMedico[09], "@E 99999")
 		 @nLin, 095 PSAY TRANSFORM(aMedico[10], "@E 99999")
 		 @nLin, 101 PSAY TRANSFORM(aMedico[11], "@E 99999")
 		 @nLin, 107 PSAY TRANSFORM(aMedico[12], "@E 99999")
 		 @nLin, 113 PSAY TRANSFORM(aMedico[13], "@E 999999")
 		 @nLin, 127 PSAY TRANSFORM(aMedico[14], "@E 99999")
  		 FS_Cabec(cTitulo)
		 aParam := {}
    	 aParam1 := {}
		 aAdd(aParam, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, QRY->USUARIO, QRY->USUARIO})
		 aAdd(aParam1, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, QRY->USUARIO, QRY->USUARIO})   
    	 cCodProc := QRY->PROCEDIMENTO
    	 aProced := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, STR0029 + QRY->PROCEDIMENTO, STR0030} //"Procedimento:"###"Total do Procedimento"
    	 cCodMed := QRY->MEDICO
    	 aMedico := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, STR0023 + QRY->MEDICO, STR0024} //"Medico:"###"Total do Medico"
  		 nLin += 1
  		 @nLin, 000 PSAY aMedico[15]
  		 nLin += 1
  		 @nLin, 000 PSAY aProced[15]
  		 cParam  := ""
    Endif
       
    If QRY->PROCEDIMENTO <> cCodProc
		 FS_Total(cTitulo, aParam1, aProced)
       @nLin, 000 PSAY Padr(aProced[16], 40)         
       @nLin, 041 PSAY TRANSFORM(aProced[01], "@E 99999")
 		 @nLin, 047 PSAY TRANSFORM(aProced[02], "@E 99999")
 		 @nLin, 053 PSAY TRANSFORM(aProced[03], "@E 99999")
 		 @nLin, 059 PSAY TRANSFORM(aProced[04], "@E 99999")
 		 @nLin, 065 PSAY TRANSFORM(aProced[05], "@E 99999")
 		 @nLin, 071 PSAY TRANSFORM(aProced[06], "@E 99999")
 		 @nLin, 077 PSAY TRANSFORM(aProced[07], "@E 99999")
 		 @nLin, 083 PSAY TRANSFORM(aProced[08], "@E 99999")
 		 @nLin, 089 PSAY TRANSFORM(aProced[09], "@E 99999")
 		 @nLin, 095 PSAY TRANSFORM(aProced[10], "@E 99999")
 		 @nLin, 101 PSAY TRANSFORM(aProced[11], "@E 99999")
 		 @nLin, 107 PSAY TRANSFORM(aProced[12], "@E 99999")
 		 @nLin, 113 PSAY TRANSFORM(aProced[13], "@E 999999")
 		 @nLin, 127 PSAY TRANSFORM(aProced[14], "@E 99999")
   	 aParam1 := {}
		 aAdd(aParam1, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, QRY->USUARIO, QRY->USUARIO})   
   
   	 cCodProc := QRY->PROCEDIMENTO
   	 aProced := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, STR0029 + QRY->PROCEDIMENTO, STR0030} //"Procedimento:"###"Total do Procedimento"
   	 cParam  := ""   
  		 nLin += 2
  		 @nLin, 000 PSAY aProced[15]
    Endif

    If cParam <> QRY->USUARIO
       cParam   := QRY->USUARIO
       If (nPosPar := aScan(aParam, {|x| x[15] == cParam})) == 0
          aAdd(aParam, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, QRY->USUARIO, QRY->USUARIO})
          nPosPar  := len(aParam)
       Endif
       If (nPosPar := aScan(aParam1, {|x| x[15] == cParam})) == 0
          aAdd(aParam1, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, QRY->USUARIO, QRY->USUARIO})
          nPosPar  := len(aParam1)
       Endif
       If (nPosRes := aScan(aResumo, {|x| x[15] == cParam})) == 0
          aAdd(aResumo, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, QRY->USUARIO, QRY->USUARIO})
          nPosRes  := len(aResumo)
       Endif
    Endif

  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Detalhe - acumular por linha (parametro) e no resumo ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    nMes := aScan(aMesesR, QRY->DATAGE)  

    aParam[nPosPar, nMes] += QRY->VALOR
    aParam[nPosPar, 13]   += QRY->VALOR
    aMedico[nMes]         += QRY->VALOR
    aMedico[13]           += QRY->VALOR
  
    aParam1[nPosPar, nMes] += QRY->VALOR
    aParam1[nPosPar, 13]   += QRY->VALOR
    aProced[nMes]          += QRY->VALOR
    aProced[13]            += QRY->VALOR
  
    aResumo[nPosRes, nMes]+= QRY->VALOR
    aResumo[nPosRes, 13]  += QRY->VALOR
    aGeral[nMes]          += QRY->VALOR
    aGeral[13]            += QRY->VALOR

    DbSkip()
 End
 FS_Total(cTitulo, aParam1, aProced)
 @nLin, 000 PSAY Padr(aProced[16], 40)         
 @nLin, 041 PSAY TRANSFORM(aProced[01], "@E 99999")
 @nLin, 047 PSAY TRANSFORM(aProced[02], "@E 99999")
 @nLin, 053 PSAY TRANSFORM(aProced[03], "@E 99999")
 @nLin, 059 PSAY TRANSFORM(aProced[04], "@E 99999")
 @nLin, 065 PSAY TRANSFORM(aProced[05], "@E 99999")
 @nLin, 071 PSAY TRANSFORM(aProced[06], "@E 99999")
 @nLin, 077 PSAY TRANSFORM(aProced[07], "@E 99999")
 @nLin, 083 PSAY TRANSFORM(aProced[08], "@E 99999")
 @nLin, 089 PSAY TRANSFORM(aProced[09], "@E 99999")
 @nLin, 095 PSAY TRANSFORM(aProced[10], "@E 99999")
 @nLin, 101 PSAY TRANSFORM(aProced[11], "@E 99999")
 @nLin, 107 PSAY TRANSFORM(aProced[12], "@E 99999")
 @nLin, 113 PSAY TRANSFORM(aProced[13], "@E 999999")
 @nLin, 127 PSAY TRANSFORM(aProced[14], "@E 99999")
 nLin += 1
 @nLin, 000 PSAY Padr(aMedico[16], 40)         
 @nLin, 041 PSAY TRANSFORM(aMedico[01], "@E 99999")
 @nLin, 047 PSAY TRANSFORM(aMedico[02], "@E 99999")
 @nLin, 053 PSAY TRANSFORM(aMedico[03], "@E 99999")
 @nLin, 059 PSAY TRANSFORM(aMedico[04], "@E 99999")
 @nLin, 065 PSAY TRANSFORM(aMedico[05], "@E 99999")
 @nLin, 071 PSAY TRANSFORM(aMedico[06], "@E 99999")
 @nLin, 077 PSAY TRANSFORM(aMedico[07], "@E 99999")
 @nLin, 083 PSAY TRANSFORM(aMedico[08], "@E 99999")
 @nLin, 089 PSAY TRANSFORM(aMedico[09], "@E 99999")
 @nLin, 095 PSAY TRANSFORM(aMedico[10], "@E 99999")
 @nLin, 101 PSAY TRANSFORM(aMedico[11], "@E 99999")
 @nLin, 107 PSAY TRANSFORM(aMedico[12], "@E 99999")
 @nLin, 113 PSAY TRANSFORM(aMedico[13], "@E 999999")
 @nLin, 127 PSAY TRANSFORM(aMedico[14], "@E 99999")
 nLin += 3

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Impressao do resumo                                  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 FS_Cabec(cTitulo)                                   
 @nLin, 000 PSAY aGeral[15]
 FS_Total(cTitulo, aResumo, aGeral) 
 @nLin, 000 PSAY aGeral[16]
 @nLin, 041 PSAY TRANSFORM(aGeral[01], "@E 99999")
 @nLin, 047 PSAY TRANSFORM(aGeral[02], "@E 99999")
 @nLin, 053 PSAY TRANSFORM(aGeral[03], "@E 99999")
 @nLin, 059 PSAY TRANSFORM(aGeral[04], "@E 99999")
 @nLin, 065 PSAY TRANSFORM(aGeral[05], "@E 99999")
 @nLin, 071 PSAY TRANSFORM(aGeral[06], "@E 99999")
 @nLin, 077 PSAY TRANSFORM(aGeral[07], "@E 99999")
 @nLin, 083 PSAY TRANSFORM(aGeral[08], "@E 99999")
 @nLin, 089 PSAY TRANSFORM(aGeral[09], "@E 99999")
 @nLin, 095 PSAY TRANSFORM(aGeral[10], "@E 99999")
 @nLin, 101 PSAY TRANSFORM(aGeral[11], "@E 99999")
 @nLin, 107 PSAY TRANSFORM(aGeral[12], "@E 99999")
 @nLin, 113 PSAY TRANSFORM(aGeral[13], "@E 999999")
 @nLin, 127 PSAY TRANSFORM(aGeral[14], "@E 99999")
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Emissao do grafico (1=Nenhum 2=Mes Referencia 3= Total 4= Media  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If nGrafico > 1
  For nPar := 1 To Len(aResumo)
   If nGrafico == 2
    nValGra := aResumo[nPar, 12] //Ultimo mes
    cTitGra := STR0021 //"Mes Referencia"
   ElseIf nGrafico == 3
    nValGra := aResumo[nPar, 13]
    cTitGra := STR0018 //"Total"
   Else
    nValGra := aResumo[nPar, 14]
    cTitGra := STR0019 //"Media"
   Endif
   aAdd(aGrafico, {nValGra, Padr(aResumo[nPar, 16], 40)})
  Next
  oGraf := HsGRAF():NEW(cTitGrf, cTitGrf, "", STR0025 + " (" + cTitGra + ")", cSubTitulo, "", aGrafico, 1, 1, 0, 0, 2, 17, 6, 6, 25, 20) //"Quantidade"
 EndIf
 
 SET DEVICE TO SCREEN
 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO                   
  
  OurSpool(wnrel)
 Endif

 MS_FLUSH()
 DBCloseArea()

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³FS_MesRetrº Autor ³ Luiz Pereira S. Jr.º Data ³  03/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Subtrai nMeses de uma data no formato AAAAMM               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_MesRetr(cAnoMes)
 Local cAno := Substr(cAnoMes, 1, 4)
 Local cMes := Substr(cAnoMes, 5, 2)
 
 If cMes == "01"
  cAno := Str(Val(cAno)-1, 4)
  cMes := "12"
 Else
  cMes :=  StrZero(Val(cMes)-1, 2)
 Endif 
Return(cAno+cMes)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³FS_Media  º Autor ³ Luiz Pereira S. Jr.º Data ³  03/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Calcula a media dos ultimos n meses (meses retroativos)    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_Media(aQtd)
 Local nMedia  := 0
 Local nMes    := 0

 For nMes := 12 to (12-nMesesRetr+1) Step -1
  nMedia += aQtd[nMes]
 Next nMes
 nMedia := Int((nMedia / nMesesRetr))

Return(nMedia)        
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³FS_Total  º Autor ³ Luiz Pereira S. Jr.º Data ³  03/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Impressao das linhas totalizadoras                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_Total(cTitulo, aDados, aTotal)
 Local   nFor    := 0
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Calculo da media de cada ocorrencia sobre o total                ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 For nFor := 1 to len(aDados)
  If aDados[nFor, 13] > 0
   aDados[nFor, 14] := FS_Media(aDados[nFor])
  Endif 
 Next nFor

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Classificacao dos dados conforme opcao do usuario nas perguntas (1=Col Mes Ref. 2= Total 3 = Media)						³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 If len(aDados) > 1
  If nOrdem == 1          //ultimo mes
   aSort(aDados,,,{|x, y| x[12] > y[12]})
  ElseIf nOrdem == 2     //quantidade total
   aSort(aDados,,,{|x, y| x[13] > y[13]})
  ElseIf nOrdem == 3     //media
   aSort(aDados,,,{|x, y| x[13] > y[13]})
  Else                   //descricao
   aSort(aDados,,,{|x, y| x[16] > y[16]})
  Endif 
 Endif 
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Impressao dos totais de detalhe                                  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If aTotal[13] > 0
  aTotal[14] := FS_Media(aTotal)
 Endif  

 nLin += 1
 For nFor := 1 to len(aDados)
  If nLin+1 > nMaxLin
  	FS_Cabec(cTitulo)
  Endif
  nLin += 1
  FS_ImpTot(aDados[nFor], .T., aTotal[13])
 Next nFor
  
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Impressao dos totais dos detalhes                                ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If nLin+2 > nMaxLin
  FS_Cabec(cTitulo)
 Endif
 nLin += 2
 
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³FS_ImpTot º Autor ³ Luiz Pereira S. Jr.º Data ³  03/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Impressao do total                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ImpTot(aLinha, lMedia, nTotMedia)

 @nLin, 000 PSAY Padr(aLinha[16], 40)         
 @nLin, 041 PSAY TRANSFORM(aLinha[01], "@E 99999")
 @nLin, 047 PSAY TRANSFORM(aLinha[02], "@E 99999")
 @nLin, 053 PSAY TRANSFORM(aLinha[03], "@E 99999")
 @nLin, 059 PSAY TRANSFORM(aLinha[04], "@E 99999")
 @nLin, 065 PSAY TRANSFORM(aLinha[05], "@E 99999")
 @nLin, 071 PSAY TRANSFORM(aLinha[06], "@E 99999")
 @nLin, 077 PSAY TRANSFORM(aLinha[07], "@E 99999")
 @nLin, 083 PSAY TRANSFORM(aLinha[08], "@E 99999")
 @nLin, 089 PSAY TRANSFORM(aLinha[09], "@E 99999")
 @nLin, 095 PSAY TRANSFORM(aLinha[10], "@E 99999")
 @nLin, 101 PSAY TRANSFORM(aLinha[11], "@E 99999")
 @nLin, 107 PSAY TRANSFORM(aLinha[12], "@E 99999")
 @nLin, 113 PSAY TRANSFORM(aLinha[13], "@E 999999")
 If lMedia
  @nLin, 120 PSAY TRANSFORM((aLinha[13] / nTotMedia) * 100, "@E 999.99")
 Endif
 @nLin, 127 PSAY TRANSFORM(aLinha[14], "@E 99999")

Return()
Static Function FS_Cabec(cTitulo)
 Cabec(cTitulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.)
 nLin := 8
Return()
