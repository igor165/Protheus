#INCLUDE "HSPAHRC0.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HRPAHRC0 บ Autor ณ Cibele Peria       บ Data ณ  30/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorios estatisticos                                    บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบVariaveis ณ __cParam: deve conter o atributo (campo ou comando) que vaiบฑฑ
ฑฑบ          ณ           ser utilizado no SELECT; refere-se ao dado que   บฑฑ
ฑฑบ          ณ           vai ser utilizado no relatorio para agrupar as   บฑฑ
ฑฑบ          ณ           qtdes de atendimentos por mes. Deve ser sempre   บฑฑ
ฑฑบ          ณ           no formato caracter.                             บฑฑ
ฑฑบ          ณ __aJoin:  array que vai conter as tabelas e condicoes para บฑฑ
ฑฑบ          ณ           inclusao de JOIN no SELECT. Sao as tabelas utili-บฑฑ
ฑฑบ          ณ           zadas para a obtencao do dado informado em       บฑฑ
ฑฑบ          ณ           __Param. O array tem duas ocorrencias, podendo   บฑฑ
ฑฑบ          ณ           ter mais de uma linha de ocorrencia:             บฑฑ
ฑฑบ          ณ           1- nome da tabela do JOIN                        บฑฑ
ฑฑบ          ณ           2- condicao do ON do JOIN                        บฑฑ
ฑฑบ          ณ __aParam:  Utilizado no caso de se desejar imprimir dados  บฑฑ
ฑฑบ          ณ            pre-fixados, como no caso dos horarios. Possui  บฑฑ
ฑฑบ          ณ           uma unica linha com duas ocorrencias:            บฑฑ
ฑฑบ          ณ           1 - ocorrencias de busca, com todas as possibili-บฑฑ
ฑฑบ          ณ               dades de resultado do __cParam;              บฑฑ
ฑฑบ          ณ               dades de resultado do __cParam;              บฑฑ
ฑฑบ          ณ           2 - caracteres correspondentes as ocorrencias    บฑฑ
ฑฑบ          ณ               de busca, utilizadas para a impressao.       บฑฑ
ฑฑบ          ณ __cCond:   Utilizado no caso de se desejar acrescentar alguบฑฑ
ฑฑบ          ณ            ma condicao na Clausula WHERE da query.					    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ 
ฑฑบAltera็๕esณ L.Gustavo Caloi 28/03/06 -> Padroniza็ใo da HS_MsgInf()    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPRC001()
 Private __cParam := "GCW.GCW_DESCLI"
 Private __aJoin  := {{"GCW", "GCW.GCW_CODCLI = GCY.GCY_CODCLI"}}
 Private __aParam := {} 
 Private __cCond  := ""
 HSPAHRC0("01", STR0001) //"Clinica"
Return()

Function HSPRC002()
 Private __cParam := "GCY.GCY_CIDINT"
 Private __aJoin  := {}
 Private __aParam := {}
 Private __cCond  := "" 
 HSPAHRC0("02", "CID") 
Return()

Function HSPRC003()
 Private __cParam := "GD0.GD0_DORIPA"
 Private __aJoin  := {{"GD0", "GD0.GD0_ORIPAC = GCY.GCY_ORIPAC"}}
 Private __aParam := {} 
 Private __cCond  := "" 
 HSPAHRC0("03", STR0002)  //"Origem"
Return()

Function HSPRC004()
	Local lGFR := HS_LocTab("GFR", .F.) 
	Private __cParam := IIf(lGFR, "GFR.GFR_DSESPE", "SX5.X5_DESCRI")
 Private __aJoin  := IIf(lGFR, {{"GBJ", "GBJ.GBJ_CRM = GCY.GCY_CODCRM"}, {"GFR", "GFR.GFR_CDESPE = GBJ.GBJ_ESPEC1"}}, {{"GBJ", "GBJ.GBJ_CRM = GCY.GCY_CODCRM"}, {"SX5", "SX5.X5_TABELA = 'EM' AND SX5.X5_CHAVE = GBJ.GBJ_ESPEC1"}})
 Private __aParam := {} 
 Private __cCond  := "" 
 
 HSPAHRC0("04", STR0003) //"Especialidade"
Return()

Function HSPRC005()
 Private __cParam := "GA9.GA9_NREDUZ"
 Private __aJoin  := {{"GA9", "GA9.GA9_CODCON = GCZ.GCZ_CODCON"}}
 Private __aParam := {}
 Private __cCond  := ""  
 HSPAHRC0("05", STR0004) //"Convenio"
Return()

Function HSPRC006()
 Private __cParam := "GCM.GCM_DESPLA"
 Private __aJoin  := {{"GCM", "GCM.GCM_CODPLA = GCZ.GCZ_CODPLA"}}
 Private __aParam := {}
 Private __cCond  := ""  
 HSPAHRC0("06", STR0005)  //"Plano"
Return()

Function HSPRC007()
 Private __cParam := "SRA.RA_NOME"
 Private __aJoin  := {{"SRA", "SRA.RA_CODIGO = GCY.GCY_CODCRM"}}
 Private __aParam := {}
 Private __cCond  := ""  
 HSPAHRC0("07", STR0006) //"Profissional"
Return()

Function HSPRC008()
 Private __cParam := "GCY.GCY_DATATE" 
 Private __aJoin  := {}
 Private __aParam := {{"1", "2", "3", "4", "5", "6", "7"}, {STR0041, STR0042, STR0043, STR0044, STR0045, STR0046, STR0047}} //"Domingo"###"Segunda"###"Terca"###"Quarta"###"Quinta"###"Sexta"###"Sabado"
 Private __cCond  := ""
 HSPAHRC0("08", STR0048) //"Dia da Semana"
Return()

Function HSPRC009()
 Private __cParam := "SUBSTRING(GCY.GCY_HORATE, 1, 2)"
 Private __aJoin  := {}
 Private __aParam := {{"00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"}, ;
                       {"00:00 - 00:59", "01:00 - 01:59", "02:00 - 02:59", "03:00 - 03:59", "04:00 - 04:59", "05:00 - 05:59", ;
                        "06:00 - 06:59", "07:00 - 07:59", "08:00 - 08:59", "09:00 - 09:59", "10:00 - 10:59", "11:00 - 11:59", ;
                        "12:00 - 12:59", "13:00 - 13:59", "14:00 - 14:59", "15:00 - 15:59", "16:00 - 16:59", "17:00 - 17:59", ;
                        "18:00 - 18:59", "19:00 - 19:59", "20:00 - 20:59", "21:00 - 21:59", "22:00 - 22:59", "23:00 - 23:59"}}
 Private __cCond  := ""
 HSPAHRC0("09", STR0007) //"Horario"
Return()
  
Function HSPRC010()
 Private __cParam := "GF4.GF4_DSTPAL"
 Private __aJoin  := {{"GF4", "GF4.GF4_TPALTA = GCY.GCY_TPALTA"}}
 Private __aParam := {} 
 Private __cCond  := "(GCY.GCY_DATSAI <> '"+SPACE(8)+"' OR GCY.GCY_TPALTA IN ('" + STRTRAN(GETMV("MV_TPALTA"),"/","','") + "'))"
 HSPAHRC0("10", STR0049)  //"Tipo de Alta"
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HRPAHRC0 บ Autor ณ Cibele Peria       บ Data ณ  30/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorios estatisticos                                    บฑฑ 
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRC0(cCodRel, cSubTitulo)
 Local   cDesc1      := STR0008 //"Este programa tem como objetivo imprimir relatorio "
 Local   cDesc2      := STR0009 //"de acordo com os parametros informados pelo usuario."
 Local   cDesc3      := STR0010 //"Atendimentos por periodo"
 Local   aOrd        := {}
 
 Private Cabec1      := ""
 Private Cabec2      := "" 
 Private cTitulo     := IIf(cCodRel == "10",STR0050,STR0011) + cSubTitulo //"Estatistica Atendimento por " //"Estatistica Saida por "
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 132
 Private Tamanho     := "M"
 Private NomeProg    := "HSPRC0" + cCodRel
 Private nTipo       := 18
 Private aReturn     := {STR0012, 1, STR0013, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private m_Pag       := 01
 Private wnRel       := NomeProg
 Private nTam        := 132
 
 Private cCodLoc_De  := ""
 Private cCodLoc_Ate := ""
 Private cCodCon_De  := ""
 Private cCodCon_Ate := ""
 Private cCodPla_De  := ""
 Private cCodPla_Ate := ""
 Private cAnoMes     := ""
 Private nAtendi     := 0
 Private nMesesRetr  := 0
 Private nTipRel     := 0
 Private nOrdem      := 0 
 Private nGrafico    := 0 
 Private cCodImp     := ""
 Private nMaxLin     := 0
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                       ณ
 //ณ MV_PAR01	Do setor                                                ณ
 //ณ MV_PAR02	Ate o setor                                             ณ
 //ณ MV_PAR03	Da convenio                                             ณ
 //ณ MV_PAR04	Ate a convenio                                          ณ
 //ณ MV_PAR05	Do plano                                                ณ
 //ณ MV_PAR06	Ate o plano                                             ณ
 //ณ MV_PAR07	Ano/mes referencia                                      ณ
 //ณ MV_PAR08	Tipo de atendimento                                     ณ
 //ณ MV_PAR09	Numero retroativo de meses para calculo da media        ณ
 //ณ MV_PAR10	Tipo do relatorio (1=Analitico/ 2=Resumo)               ณ  
 //ณ MV_PAR11	Ordem de impressao (1=por descricao 2=por qtde total)s  ณ  
 //ณ MV_PAR12	Emite grafico (1=Ultimo Mes 2=Total 3=Media 4=Nenhum    ณ  
 //| MV_PAR13 Impressora                                              |
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If !Pergunte("HSPRC0",.T.)
  Return()
 EndIf
 
 cCodLoc_De  := mv_par01
 cCodLoc_Ate := mv_par02
 cCodCon_De  := mv_par03
 cCodCon_Ate := mv_par04
 cCodPla_De  := mv_par05
 cCodPla_Ate := mv_par06 
 cAnoMes     := Substr(DtoS(cToD("01/" + Substr(mv_par07, 1, 2) + "/" + Substr(mv_par07, 4, 4))) ,1, 6)
 nAtendi     := mv_par08
 nMesesRetr  := mv_par09
 nTipRel     := mv_par10
 nOrdem      := mv_par11
 nGrafico    := mv_par12
 cCodImp     := mv_par13
 nMaxLin     := HS_MaxLin(cCodImp)

 wnrel := SetPrint("GCY", NomeProg, "", @cTitulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif
 SetDefault(aReturn, "GCY")
 If nLastKey == 27
  Return()
 Endif

 nTipo := If(aReturn[4]==1,15,18)
 RptStatus({|| RunReport(cSubTitulo,cCodRel) }, cTitulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Cibele Peria       บ Data ณ  30/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(cSubTitulo,cCodRel)
Local   cSql     := ""
Local   nMes     := 0
Local   nPosPar  := 0
Local   cParam   := "", cParRel := "" 
Local   cCodLoc  := ""
Local   nForJoin := 0
Local   cAlias   := ""
Local   cPref    := ""
Local   aDescMes := {STR0014, STR0015, STR0016, STR0017, STR0018, STR0019, STR0020, STR0021, STR0022, STR0023, STR0024, STR0025} //" Jan"###" Fev"###" Mar"###" Abr"###" Mai"###" Jun"###" Jul"###" Ago"###" Set"###" Out"###" Nov"###" Dez"
Local   aGrafico := {}
Local   cTitGrf  := ""
Local   nPar     := 0
Local   nValGra  := 0
Local   cTitGra  := ""

Private lParam   := IIf(len(__aParam)==0, .F., .T.)
Private aParam   := {}
Private aSetor   := {}
Private aResumo  := {}
Private aGeral   := {}
Private aMesesR  := Array(12)
Private nLin     := nMaxLin + 1
Private nPosC1    := 15
Private nPosC2    := 16

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta array com os meses retroativos ao Ano/Mes informado        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aMesesR     := Array(12)
aMesesR[12] := cAnoMes
For nMes := 11 to 1 Step -1
	aMesesR[nMes] := FS_MesRetr(aMesesR[nMes+1])
Next nMes

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem do cabecalho do relatorio                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Cabec1      := Padr(cSubTitulo, 40)
Cabec2      := Space(Len(Cabec1))
For nMes := 1 to 12
	Cabec1 += Space(02) + aDescMes[Val(Substr(aMesesR[nMes], 5, 2))]
	Cabec2 += Space(02) + Substr(aMesesR[nMes], 1, 4)
Next nMes
Cabec1 += " " + PADR(STR0038, 6) + " " + PADC("(%)", 6) + " " + PADR(STR0039, 5)
Cabec2 += SPACE(15) + PADR("(" + AllTrim(Str(nMesesRetr)) + STR0026 + ")", 5)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Selecao dos dados                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 
cSQL := "SELECT GCS.GCS_NOMLOC NOMLOC, " + __cParam + " PARAMETRO, "
 
If "DB2" $ Upper(TCGETDB()) 
	If cCodRel == "10"
		cSQL += "SUBSTR(GCY.GCY_DATSAI, 1, 6) DATATE,"
	Else
		cSQL += "SUBSTR(GCY.GCY_DATATE, 1, 6) DATATE,"
	EndIf
else
	If cCodRel == "10"
		cSQL += "SUBSTRING(GCY.GCY_DATSAI, 1, 6) DATATE,"
	Else
		cSQL += "SUBSTRING(GCY.GCY_DATATE, 1, 6) DATATE,"
	EndIf
endif 
 
cSQL += "COUNT(*) QTDE "
cSQL += "FROM " + RetSQLName("GCY") + " GCY "
cSQL += "JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GCY.GCY_CODLOC "  
cSQL += "JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "

For nForJoin := 1 to len(__aJoin)
	cAlias := __aJoin[nForJoin, 1]
	cPref  := cAlias + "." + PrefixoCpo(cAlias)
	cSQL += "JOIN " + RetSQLName(cAlias) + " " + cAlias + " ON " + cPref+"_FILIAL = '" + xFilial(cAlias) + "' AND " + cAlias+".D_E_L_E_T_ <> '*' "
	cSQL += "AND " + __aJoin[nForJoin, 2] + " "
Next nForJoin

cSQL += "WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
cSQL += "AND GCZ.GCZ_NRSEQG = (SELECT MIN(GCZ_NRSEQG) FROM " + RetSQLName("GCZ") + " GCZ WHERE GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
cSQL += "AND GCZ_REGATE = GCY.GCY_REGATE) "

If !EMPTY(__cCond) 
	cSQL += "AND "+ __cCond+ " "
EndIf
  
If !Empty(cCodLoc_De)
	cSQL += "AND GCY.GCY_CODLOC >= '" + cCodLoc_De + "' "
Endif 
If !Empty(cCodLoc_Ate)
	cSQL += "AND GCY.GCY_CODLOC <= '" + cCodLoc_Ate + "' "
Endif

If !Empty(cCodCon_De)
	cSQL += "AND GCZ.GCZ_CODCON >= '" + cCodCon_De + "' "
Endif
If !Empty(cCodCon_Ate)
	cSQL += "AND GCZ.GCZ_CODCON <= '" + cCodCon_Ate + "' "
Endif
 
If !Empty(cCodPla_De)
	cSQL += "AND GCZ.GCZ_CODPLA >= '" + cCodPla_De + "' "
Endif
If !Empty(cCodPla_Ate)
	cSQL += "AND GCZ.GCZ_CODPLA <= '" + cCodPla_Ate + "' "
Endif
If "DB2" $ Upper(TCGETDB())   
	If cCodRel == "10"
		cSQL += "AND SUBSTR(GCY.GCY_DATSAI, 1, 6) BETWEEN '" + aMesesR[1] + "' AND '" + aMesesR[12] + "' "
	Else
		cSQL += "AND SUBSTR(GCY.GCY_DATATE, 1, 6) BETWEEN '" + aMesesR[1] + "' AND '" + aMesesR[12] + "' "
	EndIf
else 
	If cCodRel == "10"
		cSQL += "AND SUBSTRING(GCY.GCY_DATSAI, 1, 6) BETWEEN '" + aMesesR[1] + "' AND '" + aMesesR[12] + "' " 
	Else
		cSQL += "AND SUBSTRING(GCY.GCY_DATATE, 1, 6) BETWEEN '" + aMesesR[1] + "' AND '" + aMesesR[12] + "' " 
	EndIf
Endif
 
If nAtendi <> 4
	cSQL += "AND GCY.GCY_ATENDI = '" + Str(nAtendi - 1, 1) + "' "
EndIf
cSQL += ExecFilt()
   
If "DB2" $ Upper(TCGETDB())   
	If cCodRel == "10"
		cSQL += "GROUP BY GCS.GCS_NOMLOC, " + __cParam + ", SUBSTR(GCY.GCY_DATSAI, 1, 6)"
	Else
		cSQL += "GROUP BY GCS.GCS_NOMLOC, " + __cParam + ", SUBSTR(GCY.GCY_DATATE, 1, 6)"
	EndIf
Else
	If cCodRel == "10"
		cSQL += "GROUP BY GCS.GCS_NOMLOC, " + __cParam + ", SUBSTRING(GCY.GCY_DATSAI, 1, 6)" 
	Else
		cSQL += "GROUP BY GCS.GCS_NOMLOC, " + __cParam + ", SUBSTRING(GCY.GCY_DATATE, 1, 6)" 
	EndIf
Endif

cSQL := ChangeQuery(cSQL)
TCQUERY cSQL NEW ALIAS "QRY"
DbSelectArea("QRY")

DbGoTop()
If Eof()
	Hs_MsgInf(STR0027, STR0051, STR0052) //"Nenhum dado foi encontrado para a selecao efetuada."###"Aten็ใo"###"Execu็ใo do Relatorio"
	DbCloseArea()
	Return()
Endif
  
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Emissao do relatorio                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cTitGrf := AllTrim(cTitulo)
cTitulo := AllTrim(cTitulo) + " - " + IIF(nTipRel == 1, STR0028, STR0029)  //"Analitico"###"Sintetico"
cTitulo += " (" +	IIF(nOrdem==1, STR0037, ;
					IIF(nOrdem==2, STR0038, ;
					IIF(nOrdem==3, STR0039, STR0040))) + ")"
aGeral  := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, STR0033, STR0031} //"R E S U M O"###"Total"

SetRegua(1000)
If lParam
	For nPosPar := 1 to len(__aParam[1])
		aAdd(aResumo, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, __aParam[1, nPosPar], __aParam[2, nPosPar]})   
	Next nFor
Endif 

While !Eof()                                                                                
	IncRegua()
  
	If nTipRel == 1 .And. QRY->NOMLOC <> cCodLoc
		If !Empty(cCodLoc)
			FS_Total(cTitulo, aParam, aSetor)
		Endif 
		aParam := {}
		If lParam
			For nPosPar := 1 to len(__aParam[1])
				aAdd(aParam,  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, __aParam[1, nPosPar], __aParam[2, nPosPar]})
			Next nFor
		Endif 
		cCodLoc	:= QRY->NOMLOC   
		aSetor	:= {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, STR0034 + QRY->NOMLOC, STR0030} //"Setor: "###"Total do Setor"
		cParam	:= ""   
	Endif
  
	cParRel := IIF(cCodRel == "08", STR(DOW(STOD(QRY->PARAMETRO)),1), QRY->PARAMETRO)
	If cParam <> cParRel
		cParam := cParRel
		If (nPosPar := aScan(aParam, {|x| x[15] == cParam})) == 0
			aAdd(aParam, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, cParRel, cParRel})
			nPosPar  := len(aParam)
		Endif
		If (nPosRes := aScan(aResumo, {|x| x[15] == cParam})) == 0
			aAdd(aResumo, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, cParRel, cParRel})
			nPosRes  := len(aResumo)
		Endif
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Detalhe - acumular por linha (parametro) e no resumo ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nMes := aScan(aMesesR, QRY->DATATE)  

	If nTipRel == 1  
		aParam[nPosPar, nMes] += QRY->QTDE
		aParam[nPosPar, 13]   += QRY->QTDE
		aSetor[nMes]          += QRY->QTDE
		aSetor[13]            += QRY->QTDE
	Endif 

	aResumo[nPosRes, nMes] += QRY->QTDE
	aResumo[nPosRes, 13]   += QRY->QTDE
	aGeral[nMes]           += QRY->QTDE
	aGeral[13]             += QRY->QTDE

	DbSkip()
End
If nTipRel == 1
	FS_Total(cTitulo, aParam, aSetor)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Impressao do resumo                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
FS_Total(cTitulo, aResumo, aGeral) 
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Emissao do grafico                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nGrafico < 4
	For nPar := 1 To Len(aResumo)
		If nGrafico == 1
			nValGra := aResumo[nPar, 12] //Ultimo mes
			cTitGra := STR0037   //"Ultimo mes"
		ElseIf nGrafico == 2
			nValGra := aResumo[nPar, 13]
			cTitGra := STR0038  //"Total"    
		Else
			nValGra := aResumo[nPar, 14]
			cTitGra := STR0039  //"Media"
		Endif 
		aAdd(aGrafico, {nValGra, Padr(aResumo[nPar, 16], 40)}) 
	Next
	oGraf := HsGRAF():NEW(cTitGrf, cTitGrf, "", STR0032 + " (" + cTitGra + ")", cSubTitulo, "", aGrafico, 1, 1, 0, 0, 2, 17, 6, 6, 25, 20)     //"Quantidade"
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
        
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Cibele Peria       บ Data ณ  30/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec(cTitulo)
 Cabec(cTitulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.)
 nLin := 8
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Total  บ Autor ณ Cibele Peria       บ Data ณ  30/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao das linhas totalizadoras                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Total(cTitulo, aDados, aTotal)
 Local   nFor    := 0
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Calculo da media de cada ocorrencia sobre o total                ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 For nFor := 1 to len(aDados)
  If aDados[nFor, 13] > 0
   aDados[nFor, 14] := FS_Media(aDados[nFor])
  Endif 
 Next nFor

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Classificacao dos dados conforme opcao do usuario nas perguntas  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If len(aDados) > 1
  If nOrdem == 1          //ultimo mes
   aSort(aDados,,,{|x, y| x[12] > y[12]})
  ElseIf nOrdem == 2     //quantidade total
   aSort(aDados,,,{|x, y| x[13] > y[13]})
  ElseIf nOrdem == 3     //media
   aSort(aDados,,,{|x, y| x[14] > y[14]})
  ElseIf !lParam         //descricao
   aSort(aDados,,,{|x, y| x[16] < y[16]})
  Endif 
 Endif 
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Impressao dos totais de detalhe                                  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If aTotal[13] > 0
  aTotal[14] := FS_Media(aTotal)
 Endif  

 FS_Cabec(cTitulo)
 nLin += 1
 @nLin, 000 PSAY aTotal[15]
 nLin += 1
 For nFor := 1 to len(aDados)
  If nLin+1 > nMaxLin
   FS_Cabec(cTitulo)
  Endif
  nLin += 1
  FS_ImpTot(aDados[nFor], .T., aTotal[13])
 Next nFor
  
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Impressao dos totais dos detalhes                                ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If nLin+2 > nMaxLin
  FS_Cabec(cTitulo)
 Endif
 nLin += 2
 FS_ImpTot(aTotal, .F.)
 
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_ImpTot บ Autor ณ Cibele Peria       บ Data ณ  13/12/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao do total                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
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
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_MesRetrบ Autor ณ Cibele Peria       บ Data ณ  29/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Subtrai nMeses de uma data no formato AAAAMM               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_MesRetrบ Autor ณ Cibele Peria       บ Data ณ  29/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Subtrai nMeses de uma data no formato AAAAMM               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VSX1RC0(nPar)
 Local lRet := .T.
 Local Conteudo := &("mv_par"+StrZero(nPar, 2))

 If nPar == 7
  If !Substr(Conteudo, 1, 2) $ "01/02/03/04/05/06/07/08/09/10/11/12"
   HS_MsgInf(STR0035, STR0051, STR0053) //"Mes/Ano referencia invalido"###"Aten็ใo"###"Subtrai Mes(es) de uma data"
   lRet := .F.
  Endif
 
 ElseIf nPar == 9
  If Conteudo < 0 .Or. Conteudo > 12 .Or. Int(Conteudo) <> Conteudo
   HS_MsgInf(STR0036, STR0051, STR0053) //"Numero de meses para media invalido"###"Aten็ใo"###"Subtrai Mes(es) de uma data"
   lRet := .F.
  Endif 
  
 Endif    
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Media  บ Autor ณ Cibele Peria       บ Data ณ  29/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Calcula a media dos ultimos n meses (meses retroativos)    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Media(aQtd)
 Local nMedia  := 0
 Local nMes    := 0

 For nMes := 12 to (12-nMesesRetr+1) Step -1
  nMedia += aQtd[nMes]
 Next nMes
 nMedia := Int((nMedia / nMesesRetr))

Return(nMedia)







