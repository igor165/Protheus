#INCLUDE "HSPAHR31.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HRPAHR31 º Autor ³ Heimdall           º Data ³  21/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorios estatisticos                                    º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºVariaveis ³ __cParam: deve conter o atributo (campo ou comando) que vaiº±±
±±º          ³           ser utilizado no SELECT; refere-se ao dado que   º±±
±±º          ³           vai ser utilizado no relatorio para agrupar as   º±±
±±º          ³           qtdes de atendimentos por mes. Deve ser sempre   º±±
±±º          ³           no formato caracter.                             º±±
±±º          ³ __aJoin:  array que vai conter as tabelas e condicoes para º±±
±±º          ³           inclusao de JOIN no SELECT. Sao as tabelas utili-º±±
±±º          ³           zadas para a obtencao do dado informado em       º±±
±±º          ³           __Param. O array tem duas ocorrencias, podendo   º±±
±±º          ³           ter mais de uma linha de ocorrencia:             º±±
±±º          ³           1- nome da tabela do JOIN                        º±±
±±º          ³           2- condicao do ON do JOIN                        º±±
±±º          ³ __aParam:  Utilizado no caso de se desejar imprimir dados  º±±
±±º          ³            pre-fixados, como no caso dos horarios. Possui  º±±
±±º          ³           uma unica linha com duas ocorrencias:            º±±
±±º          ³           1 - ocorrencias de busca, com todas as possibili-º±±
±±º          ³               dades de resultado do __cParam;              º±±
±±º          ³               dades de resultado do __cParam;              º±±
±±º          ³           2 - caracteres correspondentes as ocorrencias    º±±
±±º          ³               de busca, utilizadas para a impressao.       º±±
±±º          ³ __cCond:   Utilizado no caso de se desejar acrescentar alguº±±
±±º          ³            ma condicao na Clausula WHERE da query.					    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GESTAO HOSPITALAR.                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HSPR3101()

 Private __cParam := "GBH.GBH_MUN"
 Private __aJoin  := {{"GBH", "GBH.GBH_CODPAC = GM8.GM8_REGGER"}}
 Private __aParam := {} 
 Private __cCond  := ""
 Private __cTitulo  := STR0029
 Private __cAlias := "GM8" 

 Private aMesesR  := Array(12)
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
 Private nTotGeral   := 0
 Private NomeProg    := "HSPR3101"

 If FindFunction("TRepInUse") .And. TRepInUse() 
  pergunte("HSPR31",.F.)
  oReport := ReportDef(1) 
  oReport:PrintDialog()  
 Else  
 
  HSPAHR31R3(1, __cTitulo, __cAlias) //"Município"
 EndIf 
Return()

Function HSPR3102()
 
 Private __cParam := "SRA.RA_NOME"
 Private __aJoin  := {{"SRA", "SRA.RA_CODIGO = GM8.GM8_CODCRM"}}
 Private __aParam := {}
 Private __cCond  := "" 
 Private __cAlias := "GM8"
 Private __cTitulo  := STR0030
 
 Private aMesesR  := Array(12)
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
 Private nTotGeral   := 0
 Private NomeProg    := "HSPR3102"
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
  pergunte("HSPR31",.F.)
  oReport := ReportDef(2) 
  oReport:PrintDialog()  
 Else  
  HSPAHR31R3(2, __cTitulo, __cAlias) //"Médico" 
 EndIf
Return()

Function HSPR3103()  

	Private __cParam := ""
	
 If "MSSQL" $ TcGetDb()
  __cParam := "SUBSTRING(GA7.GA7_DESC,1,40)"
 Else
  __cParam := "SUBSTR(GA7.GA7_DESC,1,40)"
 EndIf
	
 Private __aJoin  := {{"GA7", "GA7.GA7_CODPRO = GM8.GM8_CODPRO"}}
 Private __aParam := {} 
 Private __cCond  := "" 
 Private __cAlias := "GM8"
 Private __cTitulo  := STR0031
  
 Private aMesesR  := Array(12)
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
 Private nTotGeral   := 0       
 Private NomeProg    := "HSPR3103"
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
  pergunte("HSPR31",.F.)
  oReport := ReportDef(3) 
  oReport:PrintDialog()  
 Else  
  HSPAHR31R3(3, __cTitulo, __cAlias)  //"Procedimento"
 EndIf
Return()

Function HSPR3104()
 
 Private __cParam := "GM8.GM8_CODUSU"
 Private __aJoin  := {}
 Private __aParam := {} 
 Private __cCond  := "" 
 Private __cAlias := "GM8"
 Private __cTitulo  := STR0032
 
 Private aMesesR  := Array(12)
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
 Private nTotGeral   := 0    
 Private NomeProg    := "HSPR3104"
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
  pergunte("HSPR31",.F.)
  oReport := ReportDef(4) 
  oReport:PrintDialog()  
 Else  
  HSPAHR31R3(4, __cTitulo, __cAlias) //"Usuário"
 EndIf
Return()

Function HSPR3105()
 
 Private __cParam := "GBH.GBH_MUN"
 Private __aJoin  := {{"GBH", "GBH.GBH_CODPAC = GMJ.GMJ_REGGER"}}
 Private __aParam := {} 
 Private __cCond  := ""
 Private __cAlias := "GMJ" 
 Private __cTitulo  := STR0029
 
 Private aMesesR  := Array(12)
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
 Private nTotGeral   := 0        
 Private NomeProg    := "HSPR3105"
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
  pergunte("HSPR31",.F.)
  oReport := ReportDef(5) 
  oReport:PrintDialog()  
 Else  
  HSPAHR31R3(5, __cTitulo, __cAlias) //"Município"
 EndIf
Return()

Function HSPR3106()                                	
 
 Private __cParam := "SRA.RA_NOME"
 Private __aJoin  := {{"SRA", "SRA.RA_CODIGO = GMJ.GMJ_CODCRM"}}
 Private __aParam := {} 
 Private __cCond  := "" 
 Private __cAlias := "GMJ" 
 Private __cTitulo  := STR0030
 
 Private aMesesR  := Array(12)
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
 Private nTotGeral   := 0        
 Private NomeProg    := "HSPR3106"
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
  pergunte("HSPR31",.F.)
  oReport := ReportDef(6) 
  oReport:PrintDialog()  
 Else  
  HSPAHR31R3(6, __cTitulo, __cAlias) //"Médico"
 EndIf
Return()

Function HSPR3107()

 Private __cParam := ""
	
 If "MSSQL" $ TcGetDb()
  __cParam := "SUBSTRING(GA7.GA7_DESC,1,40)"
 Else
  __cParam := "SUBSTR(GA7.GA7_DESC,1,40)"
 EndIf
	
 Private __aJoin  := {{"GA7" , "GA7.GA7_CODPRO = GMJ.GMJ_CODPRO"}}
 Private __aParam := {} 
 Private __cCond  := "" 
 Private __cAlias := "GMJ"
 Private __cTitulo  := STR0031
 
 Private aMesesR  := Array(12)
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
 Private nTotGeral   := 0        
 Private NomeProg    := "HSPR3107"
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
  pergunte("HSPR31",.F.)
  oReport := ReportDef(7) 
  oReport:PrintDialog()  
 Else  
  HSPAHR31R3(7, __cTitulo, __cAlias) //"Procedimento"
 EndIf
Return()

Function HSPR3108()

 	Private __cParam := "GMJ.GMJ_CODUSU"
  Private __aJoin  := {}
  Private __aParam := {} 
  Private __cCond  := "" 
  Private __cAlias := "GMJ"
 Private __cTitulo  := STR0032
 
 Private aMesesR  := Array(12)
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
 Private nTotGeral   := 0        
 Private NomeProg    := "HSPR3108"

 If FindFunction("TRepInUse") .And. TRepInUse() 
  pergunte("HSPR31",.F.)
  oReport := ReportDef(8) 
  oReport:PrintDialog()  
 Else  
  HSPAHR31R3(8, __cTitulo, __cAlias) //"Usuário"
 EndIf
Return()
         
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHR31  º Autor ³HEIMDALL            º Data ³  17/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Preenchimento dos parametros do relatorio                  º±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Parametros(lPerg)
 
 Local nMes    := 0
 Default lPerg := .T.
 
 If lPerg
  Pergunte("HSPR31",.T.)
 // Return()
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
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Monta array com os meses retroativos ao Ano/Mes informado        ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
 aMesesR[12] := cAnoMes
 For nMes := 11 to 1 Step -1
  aMesesR[nMes] := FS_MesRetr(aMesesR[nMes+1])
 Next nMes

Return ()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³REPORTDEF ³ Autor ³ Heimdal B. Castro     ³ Data ³ 04/09/07 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ReportDef(nCodRel)
 Local oReport 
 Local oSection1, oSection2, oSection3
 Local oCell
 Local oTotaliz1
 Local oBreak
 Local nMes := 0 
 Local aDescMes := {STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0017,STR0018} //" Jan"###" Fev"###" Mar"###" Abr"###" Mai"###" Jun"###" Jul"###" Ago"###" Set"###" Out"###" Nov"###" Dez"
 Local lVerif := .F.

 Parametros(.F.)
 
 oReport := TReport():New("HSPAHR31",IIf(nCodRel < 5, STR0003 + __cTitulo, STR0006 + __cTitulo),"HSPR31",{|oReport| R31IMP(oReport, nCodRel)}, STR0001 + STR0002)
//###"Estatistica Agenda Marcada por "### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."

 oReport:SetTotalInLine(.F.)
 
 oSection1 := TRSection():New(oReport,"")
 oSection1:SetHeaderBreak(.F.)
 oSection1:SetPageBreak(.F.)         
 oSection1:SetHeaderSection(.F.)
// oSection1:SetTotalInLine(.F.)
 oSection1:SetHeaderPage(.F.) 

 oSection2 := TRSection():New(oSection1, "")
 oSection2:SetHeaderPage(.T.)
 oSection2:SetHeaderBreak(.F.)  
 
 oSection3 := TRSection():New(oSection2, "")
 oSection3:SetHeaderPage(.T.)
 oSection3:SetHeaderBreak(.F.)  
             
 oCell := TRCell():New(oSection2,__cTitulo,,__cTitulo,,34)                                                   // 02-Parametro
 oCell := TRCell():New(oSection3,".",,,,34)

 For nMes := 1 to 12
  oCell := TRCell():New(oSection2, aDescMes[Val(Substr(aMesesR[nMes], 5, 2))],,,,6)                   // 03-Mês
  oCell := TRCell():New(oSection3, Substr(aMesesR[nMes], 1, 4),,,,6)                                   // 04-Ano
 Next nMes  
 
 oCell := TRCell():New(oSection2, "Total",,,,6)                   // 05-Total
 oCell := TRCell():New(oSection2, " (%) ",,,,6)                   // 06-Porcentagem
 oCell := TRCell():New(oSection2, "Média",,,,6)                   // 06-Media
 
 oCell := TRCell():New(oSection3, "      ",,,,6)                   // 05-Total
 oCell := TRCell():New(oSection3, "      ",,,,6)                   // 06-Porcentagem
 oCell := TRCell():New(oSection3, "   (" + AllTrim(STR(nMesesRetr)) + "M)",,,,6)                   // 06-Media

 oCell := TRCell():New(oSection1,"PARAMETRO","QRYSQL","",, 30)                                              // 16-Parametro
 
 oCell := TRCell():New(oSection1,"MES" + Substr(aMesesR[01], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection1,"MES" + Substr(aMesesR[02], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection1,"MES" + Substr(aMesesR[03], 5, 2),"QRYSQL","",, 6)                                             
 oCell := TRCell():New(oSection1,"MES" + Substr(aMesesR[04], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection1,"MES" + Substr(aMesesR[05], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection1,"MES" + Substr(aMesesR[06], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection1,"MES" + Substr(aMesesR[07], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection1,"MES" + Substr(aMesesR[08], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection1,"MES" + Substr(aMesesR[09], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection1,"MES" + Substr(aMesesR[10], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection1,"MES" + Substr(aMesesR[11], 5, 2),"QRYSQL","",, 6)                                               
 oCell := TRCell():New(oSection1,"MES" + Substr(aMesesR[12], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection1,"TOTA","QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection1,"nPorc","QRYSQL","","@E 999.99", 6,,{|| nPorc := (("QRYSQL")->TOTA/nTotGeral)*100})                                               
 oCell := TRCell():New(oSection1,"nMedia","QRYSQL","",, 6,,{|| nMedia := FS_Media({("QRYSQL")->&("MES" + Substr(aMesesR[01], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[02], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[03], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[04], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[05], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[06], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[07], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[08], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[09], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[10], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[11], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[12], 5, 2))})})

//	DEFINE FUNCTION FROM oSection1:Cell("TOTA") OF oSection1 FUNCTION COUNT TITLE __cTitulo NO END REPORT    // Totaliza por Medico/Procedimento  ===> 

 oSection1:SetTotalText("TOTAL DO " + __cTitulo)                                                               
                                                                                       
 oTotaliz1 := TRFunction():new(oSection1:Cell("MES" + Substr(aMesesR[01], 5, 2)),,"SUM",,"","@E 999",,.F.,.T.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection1:Cell("MES" + Substr(aMesesR[02], 5, 2)),,"SUM",,"","@E 999",,.F.,.T.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection1:Cell("MES" + Substr(aMesesR[03], 5, 2)),,"SUM",,"","@E 999",,.F.,.T.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection1:Cell("MES" + Substr(aMesesR[04], 5, 2)),,"SUM",,"","@E 999",,.F.,.T.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection1:Cell("MES" + Substr(aMesesR[05], 5, 2)),,"SUM",,"","@E 999",,.F.,.T.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection1:Cell("MES" + Substr(aMesesR[06], 5, 2)),,"SUM",,"","@E 999",,.F.,.T.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection1:Cell("MES" + Substr(aMesesR[07], 5, 2)),,"SUM",,"","@E 999",,.F.,.T.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection1:Cell("MES" + Substr(aMesesR[08], 5, 2)),,"SUM",,"","@E 999",,.F.,.T.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection1:Cell("MES" + Substr(aMesesR[09], 5, 2)),,"SUM",,"","@E 999",,.F.,.T.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection1:Cell("MES" + Substr(aMesesR[10], 5, 2)),,"SUM",,"","@E 999",,.F.,.T.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection1:Cell("MES" + Substr(aMesesR[11], 5, 2)),,"SUM",,"","@E 999",,.F.,.T.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection1:Cell("MES" + Substr(aMesesR[12], 5, 2)),,"SUM",,"","@E 999",,.F.,.T.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection1:Cell("TOTA"),,"SUM",,"","@E 999",,.F.,.T.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection1:Cell("nPorc"),,"SUM",,"","@E 999.99",,.F.,.T.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection1:Cell("nMedia"),,"SUM",,"","@E 999",,.F.,.T.,.F.,,)      	

Return( oReport )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R31Imp   ³ Autor ³ Heimdall B. Castro    ³ Data ³ 04/09/07 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function R31IMP(oReport, nCodRel)
 
 Local oSection1 := oReport:Section(1)
 Local nForJoin  := 0      
 
 Local cSubStrAno := ""
 Local cSubStrMes := ""
 Local cSubStr    := ""

 //-- Transforma parametros Range em expressao SQL
                             
  
 If "MSSQL" $ TcGetDb()
  cSubStrMes := " SUBSTRING(" + __cAlias + "." + __cAlias + "_DATAGE, 5, 2) "
  cSubStrAno := " SUBSTRING(" + __cAlias + "." + __cAlias + "_DATAGE, 1, 4) "
  cSubStr    := " SUBSTRING(" + __cAlias + "." + __cAlias + "_DATAGE, 1, 6) "
 Else
  cSubStrMes := " SUBSTR(" + __cAlias + "." + __cAlias + "_DATAGE, 5, 2) "
  cSubStrAno := " SUBSTR(" + __cAlias + "." + __cAlias + "_DATAGE, 1, 4) "
  cSubStr    := " SUBSTR(" + __cAlias + "." + __cAlias + "_DATAGE, 1, 6) "
 EndIf
                       
 MakeSqlExpr(oReport:uParam)                      
 
 oSection1:BeginQuery()      

cCond1 := "% PARAMETRO, SUM(TOTAL) TOTA, SUM(MES01) MES01, "
cCond1 += " SUM(MES02) MES02,SUM(MES03) MES03,SUM(MES04) MES04,SUM(MES05) MES05,SUM(MES06) MES06, "
cCond1 += " SUM(MES07) MES07,SUM(MES08) MES08,SUM(MES09) MES09,SUM(MES10) MES10,SUM(MES11) MES11, "
cCond1 += " SUM(MES12) MES12 %"

cCond2 := "% (SELECT " + __cParam + " PARAMETRO, " + cSubStrAno + " ANO,  " + cSubStrMes + " MES, " 
cCond2 += IIf(nCodRel < 5, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)") + " TOTAL, "
cCond2 += " CASE " + cSubStrMes
cCond2 += " WHEN '" + Substr(aMesesR[01], 5, 2) + "' THEN "
cCond2 += IIf(nCodRel < 5, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += " ELSE 0     "
cCond2 += " END MES" + Substr(aMesesR[01], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes
cCond2 += " WHEN '" + Substr(aMesesR[02], 5, 2) + "' THEN "
cCond2 += IIf(nCodRel < 5, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += " ELSE 0     "
cCond2 += " END MES" + Substr(aMesesR[02], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes
cCond2 += " WHEN '" + Substr(aMesesR[03], 5, 2) + "' THEN "
cCond2 += IIf(nCodRel < 5, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += " ELSE 0     "
cCond2 += " END MES" + Substr(aMesesR[03], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes
cCond2 += " WHEN '" + Substr(aMesesR[04], 5, 2) + "' THEN " 
cCond2 += IIf(nCodRel < 5, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += " ELSE 0     "
cCond2 += " END MES" + Substr(aMesesR[04], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes
cCond2 += " WHEN '" + Substr(aMesesR[05], 5, 2) + "' THEN "
cCond2 += IIf(nCodRel < 5, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += " ELSE 0     "
cCond2 += " END MES" + Substr(aMesesR[05], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes
cCond2 += " WHEN '" + Substr(aMesesR[06], 5, 2) + "' THEN "
cCond2 += IIf(nCodRel < 5, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += " ELSE 0     "
cCond2 += " END MES" + Substr(aMesesR[06], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes
cCond2 += " WHEN '" + Substr(aMesesR[07], 5, 2) + "' THEN "
cCond2 += IIf(nCodRel < 5, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += " ELSE 0     "
cCond2 += " END MES" + Substr(aMesesR[07], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes
cCond2 += " WHEN '" + Substr(aMesesR[08], 5, 2) + "' THEN "
cCond2 += IIf(nCodRel < 5, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += " ELSE 0     "
cCond2 += " END MES" + Substr(aMesesR[08], 5, 2) + ", " 
cCond2 += " CASE " + cSubStrMes
cCond2 += " WHEN '" + Substr(aMesesR[09], 5, 2) + "' THEN "
cCond2 += IIf(nCodRel < 5, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += " ELSE 0     "
cCond2 += " END MES" + Substr(aMesesR[09], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes
cCond2 += " WHEN '" + Substr(aMesesR[10], 5, 2) + "' THEN "
cCond2 += IIf(nCodRel < 5, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += " ELSE 0     "
cCond2 += " END MES" + Substr(aMesesR[10], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes
cCond2 += " WHEN '" + Substr(aMesesR[11], 5, 2) + "' THEN "
cCond2 += IIf(nCodRel < 5, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += " ELSE 0     "
cCond2 += " END MES" + Substr(aMesesR[11], 5, 2) + ", "
cCond2 += " CASE " + cSubStrMes
cCond2 += " WHEN '" + Substr(aMesesR[12], 5, 2) + "' THEN "
cCond2 += IIf(nCodRel < 5, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += " ELSE 0    "
cCond2 += " END MES" + Substr(aMesesR[12], 5, 2) 
cCond2 += " FROM " + RetSQLName(__cAlias) + " " + __cAlias + " "

For nForJoin := 1 to len(__aJoin)
 cAlias := __aJoin[nForJoin, 1]
 cPref  := cAlias + "." + PrefixoCpo(cAlias)
 cCond2 += " JOIN " + RetSQLName(cAlias) + " " + cAlias + " ON " + cPref+"_FILIAL = '" + xFilial(cAlias) + "' AND " + cAlias+".D_E_L_E_T_ <> '*' "
 cCond2 += " AND " + __aJoin[nForJoin, 2] + " "
Next nForJoin                                                 
             
cCond2 += " %"              
                    
cCond3 := "% " + __cAlias + "." + __cAlias + "_FILIAL = '" + xFilial(__cAlias) + "' "
cCond3 += " AND " + __cAlias + ".D_E_L_E_T_ <> '*' AND " + __cAlias + "." + __cAlias + "_STATUS IN('1','3','4','5') "
cCond3 += " AND " + __cAlias + "." + __cAlias + "_CODLOC BETWEEN '" + cCodLoc_De + "' AND '" + cCodLoc_Ate + "' "
cCond3 += " AND " + __cAlias + "." + __cAlias + "_CODCRM BETWEEN '" + cCodMed_De + "' AND '" + cCodMed_Ate + "' "
cCond3 += " AND " + __cAlias + "." + __cAlias + "_CODPLA BETWEEN '" + cCodPla_De + "' AND '" + cCodPla_Ate + "' " 
cCond3 += " AND " + cSubStr + " BETWEEN '" + aMesesR[1] + "' AND '" + aMesesR[12] + "'%"

cCond4 := "% " + __cParam + ", " + cSubStrAno + ", " + cSubStrMes
cCond4 += " ) DUAL %"

cCond5 := "% PARAMETRO %"
 
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

 oSection1:Print() 
 oReport:SetMeter(QRYSQL->(LastRec()))
 
Return( NIL ) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHR31  º Autor ³Fabricio E. da Costaº Data ³  18/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorios estatisticos                                    º±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHR31R3(nCodRel, cSubTitulo, cTabela)

 Local   cDesc1      := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local   cDesc2      := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local   cDesc3      := IIf(nCodRel < 5, STR0003 + cSubTitulo, STR0006 + cSubTitulo) //"Estatística Agenda Marcada por Município/Médico/Procedimento/Usuário" || "Estatística Reserva Cirurgica por Município/Médico/Procedimento/Usuário"
 Local   aOrd        := {}
 
 Private Cabec1      := ""
 Private Cabec2      := ""
 Private cTitulo     := cDesc3 //"Estatística Agenda Marcada por Município/Médico/Procedimento/Usuário" || "Estatística Reserva Cirurgica por Município/Médico/Procedimento/Usuário"
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 132
 Private Tamanho     := "M"
 Private nTipo       := 18
 Private aReturn     := {STR0004, 1, STR0005, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
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
 Private cTabPrinc   := cTabela
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ PARAMETROS                                                          ³
 //³ MV_PAR01	Do setor                                                   ³  
 //³ MV_PAR02	Ate o setor                                                ³
 //³ MV_PAR03	Do CIDADE                                                  ³
 //³ MV_PAR04	Ate o CIDADE                                               ³
 //³ MV_PAR05	Do plano                                                   ³
 //³ MV_PAR06	Ate o plano                                                ³
 //³ MV_PAR07	Ano/mes referencia                                         ³
 //³ MV_PAR08	Numero retroativo de meses para calculo da media           ³
 //³ MV_PAR09	Ordem de impressao (1=Col Mes Ref. 2= Total 3 = Media)     ³  
 //³ MV_PAR10	Emite grafico (1=Nenhum 2=Mes Referencia 3= Total 4= Media |
 //| MV_PAR11 Impressora                                                 |
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 Parametros()

 wnrel := SetPrint(cTabPrinc, NomeProg, "", @cTitulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
    Return()
 Endif
 SetDefault(aReturn, cTabPrinc)
 If nLastKey == 27
    Return()
 Endif
 
 aReturn[4] := 2
 nTipo := If(aReturn[4]==1,15,18)
// RptStatus({|| RunReport(STR0006) }, cTitulo) //"Estatistica Agenda Marcada por Município"
 RptStatus({|| RunReport(cSubTitulo,nCodRel, cTabPrinc) }, cTitulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³Fabricio E. da Costaº Data ³  18/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Rotina de execucao do relatorio                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                 

Static Function RunReport(cSubTitulo,nCodRel, cTabPrinc)
 Local   cSql     := ""
 Local   nMes     := 0
 Local   nPosPar  := 0
 Local   cParam   := "" 
 Local   cCodMed  := ""
 Local   nForJoin := 0
 Local   cAlias   := ""
 Local   cPref    := ""
 Local   aDescMes := {STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0017,STR0018} //" Jan"###" Fev"###" Mar"###" Abr"###" Mai"###" Jun"###" Jul"###" Ago"###" Set"###" Out"###" Nov"###" Dez"
 Local   aGrafico := {}
 Local   cTitGrf  := ""
 Local   nPar     := 0
 Local   nValGra  := 0
 Local   cTitGra  := ""
 Local 	 cSqlTmp  := ""  
 
 Local cSubStr    := ""

 Private aParam   := {}
 Private aCIDADE  := {}
 Private aResumo  := {}
 Private aGeral   := {}
 Private aMesesR  := Array(12)
 Private nLin     := nMaxLin + 1
 Private nPosC1   := 15
 Private nPosC2   := 16

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Monta array com os meses retroativos ao Ano/Mes informado        ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 aMesesR     := Array(12)
 aMesesR[12] := cAnoMes
 For nMes := 11 to 1 Step -1
     aMesesR[nMes] := FS_MesRetr(aMesesR[nMes+1])
 Next nMes

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Montagem do cabecalho do relatorio                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Cabec1 := PadR(cSubTitulo,40) //"Município"/"Médico"/"Procedimento"/"Usuário"
 Cabec2 := Space(Len(Cabec1))
 For nMes := 1 to 12
    Cabec1 += Space(02) + aDescMes[Val(Substr(aMesesR[nMes], 5, 2))]
    Cabec2 += Space(02) + Substr(aMesesR[nMes], 1, 4)
 Next nMes
 Cabec1 += " " + PADR(STR0019, 6) + " " + PADC("(%)", 6) + " " + PADR(STR0020, 5) //"Total"###"Media"
 Cabec2 += SPACE(15) + PADR("(" + AllTrim(Str(nMesesRetr)) + "M" + ")", 5)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Selecao dos dados                                                ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ           
 
 
 If "MSSQL" $ TcGetDb()
  cSubStr    := " SUBSTRING(" + cTabPrinc + "." + cTabPrinc + "_DATAGE,1,6) "
 Else
  cSubStr    := " SUBSTR(" + cTabPrinc + "." + cTabPrinc + "_DATAGE,1,6) "
 EndIf
 
 
 cSQL := "SELECT " + __cParam + " PARAMETRO, " + cSubStr + " DATAGE, " + IIf(nCodRel < 5, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)") + " VALOR "
 cSQL += "FROM " + RetSQLName(cTabPrinc) + " " + cTabPrinc + " "

 For nForJoin := 1 to len(__aJoin)
  cAlias := __aJoin[nForJoin, 1]
  cPref  := cAlias + "." + PrefixoCpo(cAlias)
  cSQL += "JOIN " + RetSQLName(cAlias) + " " + cAlias + " ON " + cPref+"_FILIAL = '" + xFilial(cAlias) + "' AND " + cAlias+".D_E_L_E_T_ <> '*' "
  cSQL += "AND " + __aJoin[nForJoin, 2] + " "
 Next nForJoin

 cSql+= " WHERE " + cTabPrinc + "." + cTabPrinc + "_FILIAL ='" + xFilial(cTabPrinc) + "' AND " + cTabPrinc + ".D_E_L_E_T_ <> '*' "
 cSql+= "  AND  " + cTabPrinc + "." + cTabPrinc + "_STATUS IN('1','3','4','5') "
 
 If !Empty(cCodLoc_De)
    cSql += "AND " + cTabPrinc + "." + cTabPrinc + "_CODLOC >= '" + cCodLoc_De + "' "
 Endif 
 If !Empty(cCodLoc_Ate)
    cSQL += "AND " + cTabPrinc + "." + cTabPrinc + "_CODLOC <= '" + cCodLoc_Ate + "' "
 Endif
 
 If !Empty(cCodMed_De)
    cSQL += "AND " + cTabPrinc + "." + cTabPrinc + "_CODCRM >= '" + cCodMed_De + "' "
 EndIf
 If !Empty(cCodMed_Ate)
    cSQL += "AND " + cTabPrinc + "." + cTabPrinc + "_CODCRM <= '" + cCodMed_Ate + "' "
 EndIf
  
 If !Empty(cCodPla_De)
    cSQL += "AND " + cTabPrinc + "." + cTabPrinc + "_CODPLA >= '" + cCodPla_De + "' "
 Endif
 If !Empty(cCodPla_Ate)
    cSQL += "AND " + cTabPrinc + "." + cTabPrinc + "_CODPLA <= '" + cCodPla_Ate + "' "
 Endif                       

 cSQL += "AND " + cSubStr + " BETWEEN '" + aMesesR[1] + "' AND '" + aMesesR[12] + "' "
 cSQL += ExecFilt()
 cSQL += " GROUP BY " + __cParam + ", " + cSubStr
 cSQL += " ORDER BY " + __cParam
 
 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")

 DbGoTop()
 If Eof()
    HS_MsgInf(STR0021,STR0022,STR0023) //"Nenhum dado foi encontrado para a selecao efetuada."###"Atenção"###"Relatorios estatisticos"
    DbCloseArea()
    Return()
 Endif
  
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Emissao do relatorio                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 cTitGrf := AllTrim(cTitulo)
 cTitulo := AllTrim(cTitulo) 
 cTitulo += " (" +  IIF(nOrdem==1, STR0024, ; //"Mes Referencia"
                    IIF(nOrdem==2, STR0019,STR0020)) + ")" //"Total"###"Media"
 aGeral  := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, QRY->PARAMETRO, STR0019} //"Total"

 SetRegua(1000)         

 While !Eof()                                                                                
    IncRegua()
  
  	 cParam   := QRY->PARAMETRO
  	 If (nPosRes := aScan(aResumo, {|x| x[15] == cParam})) == 0
  	 	 aAdd(aResumo, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, QRY->PARAMETRO, QRY->PARAMETRO})
  	 	 nPosRes  := len(aResumo)
  	 Endif

  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Detalhe - acumular por linha (parametro) e no resumo ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	 nMes := aScan(aMesesR, QRY->DATAGE)  

  	 aResumo[nPosRes, nMes]+= QRY->VALOR
  	 aResumo[nPosRes, 13]  += QRY->VALOR
  	 aGeral[nMes]          += QRY->VALOR
  	 aGeral[13]            += QRY->VALOR

    DbSkip()
 End
// FS_Total(cTitulo, aParam, aCIDADE)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Impressao do resumo                                  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 FS_Total(cTitulo, aResumo, aGeral) 
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Emissao do grafico (1=Nenhum 2=Mes Referencia 3= Total 4= Media  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If nGrafico > 1
  For nPar := 1 To Len(aResumo)
   If nGrafico == 2
    nValGra := aResumo[nPar, 12] //Ultimo mes
    cTitGra := STR0024 //"Mes Referencia"
   ElseIf nGrafico == 3
    nValGra := aResumo[nPar, 13]
    cTitGra := STR0019 //"Total"
   Else
    nValGra := aResumo[nPar, 14]
    cTitGra := STR0020 //"Media"
   Endif
   aAdd(aGrafico, {nValGra, Padr(aResumo[nPar, 16], 40)})
  Next
  oGraf := HsGRAF():NEW(cTitGrf, cTitGrf, "", STR0028 + " (" + cTitGra + ")", cSubTitulo, "", aGrafico, 1, 1, 0, 0, 2, 17, 6, 6, 25, 20)  //"Quantidade"
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
±±ºFun‡„o    ³FS_MesRetrº Autor ³Fabricio E. da Costaº Data ³  18/07/07   º±±
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
±±ºFun‡„o    ³FS_Media  º Autor ³Fabricio E. da Costaº Data ³  18/07/07   º±±
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
±±ºFun‡„o    ³FS_Total  º Autor ³Fabricio E. da Costaº Data ³  18/07/07   º±±
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

 FS_Cabec(cTitulo)
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
 FS_ImpTot(aTotal, .F.)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³FS_ImpTot º Autor ³Fabricio E. da Costaº Data ³  18/07/07   º±±
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
