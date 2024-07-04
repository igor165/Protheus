#INCLUDE "HSPAHR29.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HRPAHR31 º Autor ³ Heimdall           º Data ³  22/08/07   º±±
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

Function HSPR2901()

 Private __cParam01 := "SRA.RA_NOME"  
 Private __cParam02 := ""     
 
 If "MSSQL" $ TcGetDb()
  __cParam02 := "SUBSTRING(GA7.GA7_DESC,1,40)"
 Else
  __cParam02 := "SUBSTR(GA7.GA7_DESC,1,40)"
 EndIf
 
 Private __aJoin    := {}
 Private __aParam   := {} 
 Private __cCond    := ""
 Private __cTitulo  := STR0030
 Private __cAlias   := "GM8" 
 
 Private aMesesR     := Array(12)
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
 Private NomeProg    := "HSPR2901" 
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
  pergunte("HSPR29",.F.)
  oReport := ReportDef(1) 
  oReport:PrintDialog()  
 ELSE 
  HSPAHR29R3(1, STR0031, __cAlias) //"Médico/Procedimento"
 EndIf
Return()

Function HSPR2902()
  
 Private __cParam01 := ""  
 
 If "MSSQL" $ TcGetDb()
  __cParam01 := "SUBSTRING(GA7.GA7_DESC,1,40)"
 Else
  __cParam01 := "SUBSTR(GA7.GA7_DESC,1,40)"
 EndIf
 
 Private __cParam02 := "SRA.RA_NOME"
 Private __aJoin    := {}
 Private __aParam   := {}
 Private __cCond    := ""
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
 Private NomeProg    := "HSPR2902"
  
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPR29",.F.)
  oReport := ReportDef(2) 
  oReport:PrintDialog()  
 ELSE 
   HSPAHR29R3(2, STR0032, __cAlias) //"Procedimento/Médico" 
 EndIf
Return()              

Function HSPR2903()
 
 Private __cParam01 := "SRA.RA_NOME" 
 Private __cParam02 := ""
 
 If "MSSQL" $ TcGetDb()
  __cParam02 := "SUBSTRING(GA7.GA7_DESC,1,40)"
 Else
  __cParam02 := "SUBSTR(GA7.GA7_DESC,1,40)"
 EndIf
 
 Private __aJoin    := {}
 Private __aParam   := {}
 Private __cCond    := ""
 Private __cTitulo  := STR0030
 Private __cAlias := "GMJ"
                          
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
 Private NomeProg    := "HSPR2903"
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPR29",.F.)
  oReport := ReportDef(3) 
  oReport:PrintDialog()  
 ELSE 
  HSPAHR29R3(3, STR0031, __cAlias) //"Médico/Procedimento" 
 EndIf
Return()

Function HSPR2904()     

 Private __cParam01 := "" 
 
 If "MSSQL" $ TcGetDb()
  __cParam01 := "SUBSTRING(GA7.GA7_DESC,1,40)"
 Else
  __cParam01 := "SUBSTR(GA7.GA7_DESC,1,40)"
 EndIf
 
 Private __cParam02 := "SRA.RA_NOME"
 Private __aJoin    := {}
 Private __aParam   := {}
 Private __cCond    := ""
 Private __cTitulo  := STR0029
 Private __cAlias := "GMJ"
                          
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
 Private NomeProg    := "HSPR2904"
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPR29",.F.)
  oReport := ReportDef(4) 
  oReport:PrintDialog()  
 ELSE 
  HSPAHR29R3(4, STR0032, __cAlias) //"Procedimento/Médico" 
 EndIf 
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHR29  º Autor ³HEIMDALL            º Data ³  17/07/07   º±±
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
  Pergunte("HSPR29",.T.)
 // Return()
 EndIf
                    
 cCodLoc_De  := mv_par01
 cCodLoc_Ate := mv_par02
 cCodMed_De  := mv_par03
 cCodMed_Ate := mv_par04
 cCodPla_De  := mv_par05
 cCodPla_Ate := mv_par06 
 cAnoMes     := Substr(DtoS(cToD("01/" + Substr(mv_par07, 1, 2) + "/" + Substr(mv_par07, 4, 4))) ,1, 6)
 if Empty(Alltrim(cAnoMes))
			cAnoMes     := Substr(DtoS(cToD("01/" + Substr(DTOS(DATE()), 5, 2) + "/" + Substr(DTOS(DATE()), 1, 4))) ,1, 6)
	end if
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHR29  º Autor ³Heimdall            º Data ³  17/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorios estatisticos                                    º±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHR29R3(nCodRel, cSubTitulo, cTabela)
 Local   cDesc1      := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local   cDesc2      := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local   cDesc3      := IIf(nCodRel < 3, STR0003 + cSubTitulo, STR0028 + cSubTitulo) //"Estatística Agenda Ambulatorial por " || "Estatística Reserva Cirurgica por "
 Local   aOrd        := {}
 
 Private Cabec1      := ""
 Private Cabec2      := "" 
 Private cTitulo     := cDesc3 //"Estatística Agenda Ambulatorial por " || "Estatística Reserva Cirurgica por "
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
 Private nMaxLin     := 0                     
 Private cTabPrinc   := cTabela 
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ PARAMETROS (Grupo de perguntas)                                     ³
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

 Parametros()

 wnrel := SetPrint(cTabela, NomeProg, "", @cTitulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif
 SetDefault(aReturn, cTabPrinc)
 If nLastKey == 27
  Return()
 Endif

 aReturn[4] := 2
 nTipo := If(aReturn[4]==1,15,18)
 RptStatus({|| RunReport(cSubTitulo,nCodRel, cTabPrinc) }, cTitulo)
Return(Nil)       

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³REPORTDEF ³ Autor ³ HEIMDALL              ³ Data ³ 06/07/06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ReportDef(nCodRel)

 Local oReport 
 Local oSection1, oSection2, oSection3, oSection4, oSection5
 Local oCell
 Local oTotaliz1
 Local oBreak
 Local nMes := 0 
 Local aDescMes := {STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0017} //" Jan"###" Fev"###" Mar"###" Abr"###" Mai"###" Jun"###" Jul"###" Ago"###" Set"###" Out"###" Nov"###" Dez"
 Local lVerif := .F.
 
 Parametros(.F.)
 
 oReport := TReport():New("HSPAHR29",STR0003 + __cTitulo,"HSPR29",{|oReport| R29IMP(oReport, nCodRel)}, STR0001 + STR0002 + STR0003)
//###"Estatistica Agenda Ambulatorial por "### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."

 oSection1 := TRSection():New(oReport,"")
 oSection1:SetHeaderBreak(.F.)
 oSection1:SetPageBreak(.T.)
 oCell := TRCell():New(oSection1,"PARAM01","QRYSQL",__cTitulo,,30)       // 01-Medico/Procedimento

 oSection2 := TRSection():New(oSection1)
 oSection2:SetHeaderPage(.T.)
 oSection2:SetHeaderBreak(.F.)

 oSection3 := TRSection():New(oSection2,,{"SRA","GA7"})
 oSection3:SetHeaderPage(.T.)
 oSection3:SetHeaderBreak(.F.)     
              
 oCell := TRCell():New(oSection2,__cTitulo,,__cTitulo,,34)                                                   // 02-Procedimento/Médico 
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
 
 oSection4 := TRSection():New(oSection3,,{"QRYSQL"})
 oSection4:SetHeaderPage(.F.)
 oSection4:SetHeaderBreak(.F.)
 oSection4:SetHeaderSection(.F.)
 oSection4:SetTotalInLine(.F.)
 oCell := TRCell():New(oSection4,"PARAM02","QRYSQL","",, 30)                                              // 16-Medico/Procedimento

 oCell := TRCell():New(oSection4,"MES" + Substr(aMesesR[01], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection4,"MES" + Substr(aMesesR[02], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection4,"MES" + Substr(aMesesR[03], 5, 2),"QRYSQL","",, 6)                                             
 oCell := TRCell():New(oSection4,"MES" + Substr(aMesesR[04], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection4,"MES" + Substr(aMesesR[05], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection4,"MES" + Substr(aMesesR[06], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection4,"MES" + Substr(aMesesR[07], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection4,"MES" + Substr(aMesesR[08], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection4,"MES" + Substr(aMesesR[09], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection4,"MES" + Substr(aMesesR[10], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection4,"MES" + Substr(aMesesR[11], 5, 2),"QRYSQL","",, 6)                                               
 oCell := TRCell():New(oSection4,"MES" + Substr(aMesesR[12], 5, 2),"QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection4,"TOTA","QRYSQL","",, 6)                                              
 oCell := TRCell():New(oSection4,"nPorc","QRYSQL","","@E 999.99", 6,,{|| nPorc := (("QRYSQL")->TOTA/nTotGeral)*100})                                               
 oCell := TRCell():New(oSection4,"nMedia","QRYSQL","",, 6,,{|| nMedia := FS_Media({("QRYSQL")->&("MES" + Substr(aMesesR[01], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[02], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[03], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[04], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[05], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[06], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[07], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[08], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[09], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[10], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[11], 5, 2)), ("QRYSQL")->&("MES" + Substr(aMesesR[12], 5, 2))})})         
                          
//	DEFINE FUNCTION FROM oSection4:Cell("TOTA") OF oSection1 FUNCTION COUNT TITLE __cTitulo NO END REPORT    // Totaliza por Medico/Procedimento  ===>
                                                               
 oSection4:SetTotalText("TOTAL DO " + __cTitulo)                                                               
                                                                                       
 oTotaliz1 := TRFunction():new(oSection4:Cell("MES" + Substr(aMesesR[01], 5, 2)),,"SUM",,"","@E 999",,.T.,.F.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection4:Cell("MES" + Substr(aMesesR[02], 5, 2)),,"SUM",,"","@E 999",,.T.,.F.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection4:Cell("MES" + Substr(aMesesR[03], 5, 2)),,"SUM",,"","@E 999",,.T.,.F.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection4:Cell("MES" + Substr(aMesesR[04], 5, 2)),,"SUM",,"","@E 999",,.T.,.F.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection4:Cell("MES" + Substr(aMesesR[05], 5, 2)),,"SUM",,"","@E 999",,.T.,.F.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection4:Cell("MES" + Substr(aMesesR[06], 5, 2)),,"SUM",,"","@E 999",,.T.,.F.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection4:Cell("MES" + Substr(aMesesR[07], 5, 2)),,"SUM",,"","@E 999",,.T.,.F.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection4:Cell("MES" + Substr(aMesesR[08], 5, 2)),,"SUM",,"","@E 999",,.T.,.F.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection4:Cell("MES" + Substr(aMesesR[09], 5, 2)),,"SUM",,"","@E 999",,.T.,.F.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection4:Cell("MES" + Substr(aMesesR[10], 5, 2)),,"SUM",,"","@E 999",,.T.,.F.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection4:Cell("MES" + Substr(aMesesR[11], 5, 2)),,"SUM",,"","@E 999",,.T.,.F.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection4:Cell("MES" + Substr(aMesesR[12], 5, 2)),,"SUM",,"","@E 999",,.T.,.F.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection4:Cell("TOTA"),,"SUM",,"","@E 999",,.T.,.F.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection4:Cell("nPorc"),,"SUM",,"","@E 999.99",,.T.,.F.,.F.,,)
 oTotaliz1 := TRFunction():new(oSection4:Cell("nMedia"),,"SUM",,"","@E 999",,.T.,.F.,.F.,,)
	
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ³
 //³ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ³
 //³ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  
Return( oReport )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R29Imp   ³ Autor ³ HEIMDALL              ³ Data ³ 17/07/06 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R29IMP(oReport, nCodRel)
                                    
 Local oSection1 := oReport:Section(1)
 Local oSection2 := oReport:Section(1):Section(1)
 Local oSection3 := oReport:Section(1):Section(1):Section(1)   
 
 Local cSubStrMes := ""
 Local cSubStrAno := ""
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

cCond1 := "% PARAM01, PARAM02, SUM(TOTAL) TOTA, SUM(MES01	) MES01, SUM(MES02) MES02, "
cCond1 += " SUM(MES03) MES03,  SUM(MES04) MES04,  SUM(MES05) MES05,  SUM(MES06) MES06, SUM(MES07) MES07, "
cCond1 += " SUM(MES08) MES08,  SUM(MES09) MES09,  SUM(MES10) MES10,  SUM(MES11) MES11, "
cCond1 += " SUM(MES12) MES12 %"

cCond2 := "% (SELECT " + __cParam01 + " PARAM01, " + cSubStrAno +  " ANO , " + cSubStrMes + " MES, " + __cParam02 + " PARAM02, "  
cCond2 += IIf (nCodRel <3, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)") + " TOTAL, "
cCond2 += "  CASE " + cSubStrMes 
cCond2 += "   WHEN '" + Substr(aMesesR[01], 5, 2) + "' THEN "
cCond2 += IIf (nCodRel <3, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")      
cCond2 += "   ELSE         "
cCond2 += "     0          "
cCond2 += "   END MES" + Substr(aMesesR[01], 5, 2) + ", "
cCond2 += "  CASE " + cSubStrMes
cCond2 += "   WHEN '" + Substr(aMesesR[02], 5, 2) + "' THEN  "
cCond2 += IIf (nCodRel <3, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += "   ELSE        "
cCond2 += "     0         "
cCond2 += "   END MES" + Substr(aMesesR[02], 5, 2) + ", "   
cCond2 += "  CASE " + cSubStrMes
cCond2 += "   WHEN '" + Substr(aMesesR[03], 5, 2) + "' THEN "
cCond2 += IIf (nCodRel <3, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += "   ELSE        "
cCond2 += "     0         "
cCond2 += "   END MES" + Substr(aMesesR[03], 5, 2) + ", "  
cCond2 += "  CASE " + cSubStrMes
cCond2 += "   WHEN '" + Substr(aMesesR[04], 5, 2) + "' THEN  "
cCond2 += IIf (nCodRel <3, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += "   ELSE        "
cCond2 += "     0         "
cCond2 += "   END MES" + Substr(aMesesR[04], 5, 2) + ", "  
cCond2 += "  CASE " + cSubStrMes
cCond2 += "   WHEN '" + Substr(aMesesR[05], 5, 2) + "' THEN  "
cCond2 += IIf (nCodRel <3, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += "   ELSE        "
cCond2 += "     0         "
cCond2 += "   END MES" + Substr(aMesesR[05], 5, 2) + ", "
cCond2 += "  CASE " + cSubStrMes
cCond2 += "   WHEN '" + Substr(aMesesR[06], 5, 2) + "' THEN  "
cCond2 += IIf (nCodRel <3, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += "   ELSE        "
cCond2 += "     0         "
cCond2 += "   END MES" + Substr(aMesesR[06], 5, 2) + ", "
cCond2 += "  CASE " + cSubStrMes
cCond2 += "   WHEN '" + Substr(aMesesR[07], 5, 2) + "' THEN  "
cCond2 += IIf (nCodRel <3, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += "   ELSE        "
cCond2 += "     0         "
cCond2 += "   END MES" + Substr(aMesesR[07], 5, 2) + ", "
cCond2 += "  CASE " + cSubStrMes
cCond2 += "   WHEN '" + Substr(aMesesR[08], 5, 2) + "' THEN  "
cCond2 += IIf (nCodRel <3, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += "   ELSE        "
cCond2 += "     0         "
cCond2 += "   END MES" + Substr(aMesesR[08], 5, 2) + ", "
cCond2 += "  CASE " + cSubStrMes
cCond2 += "   WHEN '" + Substr(aMesesR[09], 5, 2) + "' THEN  "
cCond2 += IIf (nCodRel <3, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += "   ELSE            "
cCond2 += "     0             "
cCond2 += "   END MES" + Substr(aMesesR[09], 5, 2) + ", "
cCond2 += "  CASE " + cSubStrMes
cCond2 += "   WHEN '" + Substr(aMesesR[10], 5, 2) + "' THEN "
cCond2 += IIf (nCodRel <3, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += "   ELSE            "
cCond2 += "     0             "
cCond2 += "   END MES" + Substr(aMesesR[10], 5, 2) + ", "
cCond2 += "  CASE " + cSubStrMes
cCond2 += "   WHEN '" + Substr(aMesesR[11], 5, 2) + "' THEN   "
cCond2 += IIf (nCodRel <3, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += "   ELSE          "
cCond2 += "     0           "
cCond2 += "   END MES" + Substr(aMesesR[11], 5, 2) + ", "                                               
cCond2 += "  CASE " + cSubStrMes
cCond2 += "   WHEN '" + Substr(aMesesR[12], 5, 2) + "' THEN  "
cCond2 += IIf (nCodRel <3, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)")
cCond2 += "   ELSE          "
cCond2 += "     0           "
cCond2 += "   END MES" + Substr(aMesesR[12], 5, 2)  
cCond2 += "   FROM " + RetSqlName(__cAlias) + " " + __cAlias + ", " + RetSqlName("SRA") + " SRA" + ", " + RetSqlName("GA7") + " GA7 %"

cCond3 := "% " + __cAlias + "." + __cAlias + "_FILIAL = '" + xFilial(__cAlias) + "' AND " + __cAlias + ".D_E_L_E_T_ <> '*'  " 
cCond3	+= "	AND   " + __cAlias + "." + __cAlias +  "_STATUS IN('1','3','4','5') " 
cCond3 += " AND   SRA.RA_CODIGO  = " + __cAlias + "." + __cAlias + "_CODCRM "
cCond3 += " AND   GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
cCond3 += " AND   SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
cCond3 += " AND   GA7.GA7_CODPRO = " + __cAlias + "." + __cAlias + "_CODPRO "
cCond3 += " AND   " + __cAlias + "." + __cAlias + "_CODLOC BETWEEN '" + cCodLoc_De + "' AND '" + cCodLoc_Ate + "'"
cCond3 += " AND   " + __cAlias + "." + __cAlias + "_CODCRM BETWEEN '" + cCodMed_De + "' AND '" + cCodMed_Ate + "'"
cCond3 += " AND   " + __cAlias + "." + __cAlias + "_CODPLA BETWEEN '" + cCodPla_De + "' AND '" + cCodPla_Ate + "'" 
cCond3 += " AND " + cSubStr + " BETWEEN '" + aMesesR[1] + "' AND '" + aMesesR[12] + "'%"

cCond4 := "% " + __cParam01 + ", " + cSubStrAno + ", " + cSubStrMes + ", " + __cParam02  
cCond4 += " ) DUAL %"
                                   
cCond5 := "% PARAM01, PARAM02 %"
 
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
	oSection2:SetParentFilter( {|G| ("QRYSQL")->PARAM01  == G }, {|| ("QRYSQL")->PARAM01 } )     // Quebra por procedimento/medico por pagina
	
 oSection3:SetParentQuery()                                                                           
	oSection3:SetParentFilter( {|P| ("QRYSQL")->PARAM02 + ("QRYSQL")->PARAM01  == P }, {|| ("QRYSQL")->PARAM02 + ("QRYSQL")->PARAM01 } )// Quebra por procedimento/medico por medico/procedimento

 oSection1:Print() // processa as informacoes da tabela principal
 oReport:SetMeter(QRYSQL->(LastRec()))
 
Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³Heimdall            º Data ³  17/07/07   º±±
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
 Local   cParam02 := "" 
 Local   cParam01 := ""
 Local   nForJoin := 0
 Local   cAlias   := ""
 Local   cPref    := ""
 Local   aDescMes := {STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0017} //" Jan"###" Fev"###" Mar"###" Abr"###" Mai"###" Jun"###" Jul"###" Ago"###" Set"###" Out"###" Nov"###" Dez"
 Local   aGrafico := {}
 Local   cTitGrf  := ""
 Local   nPar     := 0
 Local   nValGra  := 0
 Local   cTitGra  := ""
 Local   cSubStr  := ""

 Private aParam   := {}
 Private aDados   := {}
 Private aResumo  := {}
 Private aGeral   := {}
 Private nLin     := nMaxLin + 1
 Private nPosC1   := 15
 Private nPosC2   := 16

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Montagem do cabecalho do relatorio                               ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Cabec1 := PadR(__cTitulo,40) //"Médico/Procedimento"
 Cabec2 := Space(Len(Cabec1))
 For nMes := 1 to 12
  Cabec1 += Space(02) + aDescMes[Val(Substr(aMesesR[nMes], 5, 2))]
  Cabec2 += Space(02) + Substr(aMesesR[nMes], 1, 4)
 Next nMes
 Cabec1 += " " + PADR(STR0018, 6) + " " + PADC("(%)", 6) + " " + PADR(STR0023, 5) //"Total" //"Media"
 Cabec2 += SPACE(15) + PADR("(" + AllTrim(Str(nMesesRetr)) + "M" + ")", 5)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Selecao dos dados                                                ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
 
 If "MSSQL" $ TcGetDb()
  cSubStr := " SUBSTRING(" + cTabPrinc + "." + cTabPrinc + "_DATAGE, 1, 6) "
 Else
  cSubStr := " SUBSTR(" + cTabPrinc + "." + cTabPrinc + "_DATAGE, 1, 6) "
 EndIf                                            

 cSql:= "SELECT " + __cParam01 + " PARAM01, " + cSubStr + " DATAGE, "
 cSql+= __cParam02 + " PARAM02, "
 cSql+= IIf (nCodRel <3, "COUNT(*)", "COUNT(DISTINCT GMJ.GMJ_SEQAGE)") + " VALOR "
 cSql+= "FROM " + RetSqlName(cTabPrinc) + " " + cTabPrinc + ", " 
 cSql+=           RetSqlName("SRA") + " SRA , "
 cSql+=           RetSqlName("GA7") + " GA7 "
 cSql+= " WHERE " + cTabPrinc + "." + cTabPrinc + "_FILIAL ='" + xFilial(cTabPrinc) + "' AND " + cTabPrinc + ".D_E_L_E_T_ <> '*' "
 cSql+= "  AND  " + cTabPrinc + "." + cTabPrinc + "_STATUS IN('1','3','4','5') "
 cSql+= "  AND  SRA.RA_CODIGO = " + cTabPrinc + "." + cTabPrinc + "_CODCRM "
 cSql+= "  AND  GA7.GA7_FILIAL ='" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cSql+= "  AND  SRA.RA_FILIAL ='" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
 cSql+= "  AND  GA7.GA7_CODPRO = " + cTabPrinc + "." + cTabPrinc + "_CODPRO "
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
 cSQL += " GROUP BY " + __cParam01 + ", " + cSubStr + ", " + __cParam02
 cSQL += " ORDER BY " + __cParam01 + ", " + __cParam02
 
 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")

 DbGoTop()
 If Eof()
  HS_MsgInf(STR0019,STR0020,STR0021) //"Nenhum dado foi encontrado para a selecao efetuada."###"Atenção"###"Relatorios estatisticos"
  DbCloseArea()
  Return()
 Endif
  
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Emissao do relatorio                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 cTitGrf := AllTrim(cTitulo)
 cTitulo := AllTrim(cTitulo) 
 cTitulo += " (" +  IIF(nOrdem==1, STR0022, ; //"Mes Referencia"
                    IIF(nOrdem==2, STR0018,STR0023)) + ")"  //"Total"###"Media"
 aGeral  := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, STR0024,STR0018} //"R E S U M O"###"Total"

 SetRegua(1000)         

 if !Eof()                                                                                
	 FS_Cabec(cTitulo)
	 nLin += 1
	 @nLin, 000 PSAY __cTitulo + ":" + QRY->PARAM01 //": " 
	 nLin += 1
 endif
   
 While !Eof()                                                                                
  IncRegua()
  
  If QRY->PARAM01 <> cParam01
   If !Empty(cParam01)
	   FS_Total(cTitulo, aParam, aDados)
		nLin += 2
		@nLin, 000 PSAY __cTitulo + ":" + QRY->PARAM01 //": "
		nLin += 1
   Endif 
   aParam := {}
   
   cParam01 := QRY->PARAM01
   aDados   := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, __cTitulo + ":" + QRY->PARAM01, STR0026 + __cTitulo}  //": "###"Total do "
   cParam02 := ""   
  Endif

  If cParam02 <> QRY->PARAM02
   cParam02   := QRY->PARAM02
   If (nPosPar := aScan(aParam, {|x| x[15] == cParam02})) == 0
    aAdd(aParam, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, QRY->PARAM02, QRY->PARAM02})
    nPosPar  := len(aParam)
   Endif
   If (nPosRes := aScan(aResumo, {|x| x[15] == cParam02})) == 0
    aAdd(aResumo, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, QRY->PARAM02, QRY->PARAM02})
    nPosRes  := len(aResumo)
   Endif
  Endif

  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Detalhe - acumular por linha (parametro) e no resumo ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  nMes := aScan(aMesesR, QRY->DATAGE)  

  aParam[nPosPar, nMes] += QRY->VALOR
  aParam[nPosPar, 13]   += QRY->VALOR
  aDados[nMes]          += QRY->VALOR
  aDados[13]            += QRY->VALOR
  
  aResumo[nPosRes, nMes]+= QRY->VALOR
  aResumo[nPosRes, 13]  += QRY->VALOR
  aGeral[nMes]          += QRY->VALOR
  aGeral[13]            += QRY->VALOR

  DbSkip()
 End
 FS_Total(cTitulo, aParam, aDados)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Impressao do resumo                                  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 FS_Cabec(cTitulo)
 nLin += 1
 @nLin, 000 PSAY STR0024 //"R E S U M O"
 nLin += 1
 FS_Total(cTitulo, aResumo, aGeral) 
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Emissao do grafico (1=Nenhum 2=Mes Referencia 3= Total 4= Media  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If nGrafico > 1
  For nPar := 1 To Len(aResumo)
   If nGrafico == 2
    nValGra := aResumo[nPar, 12] //Ultimo mes
    cTitGra := STR0022 //"Mes Referencia"
   ElseIf nGrafico == 3
    nValGra := aResumo[nPar, 13]
    cTitGra := STR0018 //"Total"
   Else
    nValGra := aResumo[nPar, 14]
    cTitGra := STR0023 //"Media"
   Endif
   aAdd(aGrafico, {nValGra, Padr(aResumo[nPar, 16], 40)})
  Next
  oGraf := HsGRAF():NEW(cTitGrf, cTitGrf, "", STR0027 + " (" + cTitGra + ")", cSubTitulo, "", aGrafico, 1, 1, 0, 0, 2, 17, 6, 6, 25, 20)  //"Quantidade"
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
±±ºFun‡„o    ³FS_Cabec  º Autor ³ HEIMDALL           º Data ³  17/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Cabecalho do relatorio                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_Cabec(cTitulo)
 Cabec(cTitulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.)
 nLin := 8
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³FS_Total  º Autor ³HEIMDALL            º Data ³  17/07/07   º±±
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

 //FS_Cabec(cTitulo)
 //nLin += 1
 //@nLin, 000 PSAY aTotal[15]
 //nLin += 1
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
±±ºFun‡„o    ³FS_ImpTot º Autor ³Fabricio E. da Costaº Data ³  17/07/07   º±±
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³FS_MesRetrº Autor ³HEIMDALL            º Data ³  17/07/07   º±±
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
±±ºFun‡„o    ³FS_Media  º Autor ³HEIMDALL            º Data ³  17/07/07   º±±
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
//*******************

Function ExecFilt 
	Local aRetFilt := {}
	Local cRetFilt := ""
 if !Empty(aReturn[7])
 	aRetFilt := aReturn
	 aRetFilt[7] := strtran(upper(aRetFilt[7]),upper(".and.")," and ")
	 aRetFilt[7] := strtran(upper(aRetFilt[7]),upper(".or.")," or ")
	 aRetFilt[7] := strtran(upper(aRetFilt[7]),upper('"'),"'")
	 aRetFilt[7] := strtran(upper(aRetFilt[7]),upper("==")," = ")
	 aRetFilt[7] := strtran(upper(aRetFilt[7]),upper("dToS"),"")
	 aRetFilt[7] := strtran(upper(aRetFilt[7]),upper("$")," IN ")
	 aRetFilt[7] := strtran(upper(aRetFilt[7]),upper("!=")," <> ")
	 aRetFilt[7] := strtran(upper(aRetFilt[7]),upper("!")," NOT ")
	 aRetFilt[7] := strtran(upper(aRetFilt[7]),upper("ALLTRIM")," TRIM")

 	cRetFilt += "AND (" + aRetFilt[7] + ") "
 endif	 
Return(cRetFilt)