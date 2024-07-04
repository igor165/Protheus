#INCLUDE "HSPAHR50.ch"
#INCLUDE "RWMAKE.CH"
#include "TopConn.ch"
#INCLUDE "Report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR50 บ       ณ Antonio Carlos     บ Data ณ 23/08/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ LISTAGEM DE PROFISSIONAIS                                  บฑฑ
ฑฑบ          ณ Conversใo para relatorios personalizaveis                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR50()

Local oReport
If FindFunction("TRepInUse") .And. TRepInUse()
	pergunte("HSPR50",.T.)
	oReport := ReportDef()
	oReport:PrintDialog()
ELSE
	HSPAHR50R3()
EndIF
Return( Nil )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 23/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ReportDef()
Local oReport
Local oSection1, oSection2
Local oCell
Local oTotaliz1, oTotaliz2

oReport := TReport():New("HSPAHR50",STR0003,"HSPR50",{|oReport| R50IMP(oReport)},STR0001 + " " + STR0002)  
 //"Relacao de Profissionais"### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."

oReport:SetPortrait()          // Imprimir relatorio em formato retrato
                   
oReport:ParamReadOnly()//Desabilitando Botใo de parโmetros do Relat๓rio.

If !Empty(MV_PAR04)                     //Se Quebrar por Especialidade
 oSection1 := TRSection():New(oReport,STR0010,{"GFR"}) //"Especialidade "
 oSection1:SetPageBreak(.F.)
 oSection1:SetHeaderBreak(.T.)    //Define se cabecalho das celulas sera impresso apos quebra TRBreak.
 oSection1:SetHeaderPage(.T.) 
 oCell := TRCell():New(oSection1,"cDSESPE","GFR",STR0020,,TamSX3("GFR_DSESPE")[1],,{||HS_INIPADR("GFR", 1, MV_PAR04, "GFR_DSESPE",,.F.)})   //"Especialidade "
Else
 oSection1 := TRSection():New(oReport,STR0014,{"GBJ"}) //"Todos"
 oSection1:SetPageBreak(.F.)
 oSection1:SetHeaderBreak(.T.)    //Define se cabecalho das celulas sera impresso apos quebra TRBreak.
 oSection1:SetHeaderPage(.T.) 
 oCell := TRCell():New(oSection1,"","",STR0010+STR0014,,25)    //"Especialidade"   ###"Todos"
EndIf 

oCell := TRCell():New(oSection1,"cTIPPRO","GBJ",STR0013,,20,,{||IIF(("QRYR50")->GBJ_TIPPRO=="1",STR0006,IIF(("QRYR50")->GBJ_TIPPRO=="2",STR0007,STR0014))})  //"Tipo de Medico "###"Corpo Clinico"###"Eventuais"
oCell := TRCell():New(oSection1,"cSTATUS","GBJ",STR0015,,20,,{||IIF(("QRYR50")->GBJ_STATUS=="1",STR0008,IIF(("QRYR50")->GBJ_STATUS=="2",STR0009,STR0014))})  //"Situa็ใo "###"Ativos"###"Inativos"###"Todos "
oCell := TRCell():New(oSection1,"cCOTIST","GBJ",STR0017,,20,,{||IIF(("QRYR50")->GBJ_COTIST=="1",STR0018,IIF(("QRYR50")->GBJ_COTIST=="2",STR0019,STR0014))})  //"Cotista "###"Sim"###"Nใo"###"Todos "

oSection2 := TRSection():New(oSection1,"Medico",{"GBJ","SRA"})
oSection2:SetPageBreak(.F.)
oSection2:SetHeaderPage(.T.)
oSection2:SetHeaderBreak(.F.)    //Define se cabecalho das celulas sera impresso apos quebra TRBreak.
oCell := TRCell():New(oSection2,"RA_NOME"   ,"SRA",) 
oCell := TRCell():New(oSection2,"GBJ_CRM"   ,"GBJ",) 
oCell := TRCell():New(oSection2,"RA_CIC"    ,"SRA",) 
oCell := TRCell():New(oSection2,"RA_TELEFON","SRA",) 
oCell := TRCell():New(oSection2,"GBJ_TELCOM","GBJ",) 
oCell := TRCell():New(oSection2,"cCATEG"    ,"GBJ",STR0020,,20,,{||HS_RDescrB("GBJ_TIPPRO",("QRYR50")->GBJ_TIPPRO)}) // "Categoria"
oCell := TRCell():New(oSection2,"GBJ_REPAMB","GBJ",STR0021,,12)  //"% AMB.  "
oCell := TRCell():New(oSection2,"GBJ_RAMBUR","GBJ",STR0022,,12)  //"% AMB. U"
oCell := TRCell():New(oSection2,"GBJ_REPINT","GBJ",STR0023,,12)  //"% INT.  "
oCell := TRCell():New(oSection2,"GBJ_RINTUR","GBJ",STR0024,,12)  //"% INT. U"

Return( oReport )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
//ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
//ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ R50Imp   ณ Autor ณ Antonio Carlos        ณ Data ณ 22/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R50IMP(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local cCond1    := "" 
Local cCond2    := "" 
Local cCond3    := "" 
Local cCond4    := "" 

MakeSqlExpr(oReport:uParam)

 If MV_PAR01 == 1                                      
  cCond1 := "% GBJ_TIPPRO <> '0' %"
 ElseIf MV_PAR01 == 2 
  cCond1 := "% GBJ_TIPPRO <> '1' %"
 Else
  cCond1 := "% GBJ_TIPPRO <> '3' %"
 EndIf  

 If MV_PAR02 == 1
  cCond2 := "% GBJ_STATUS <> '1' %"
 ElseIf MV_PAR02 == 2 
  cCond2 := "% GBJ_STATUS <> '0' %"
 Else
  cCond2 := "% GBJ_STATUS <> '3' %"
 EndIf  

 If MV_PAR03 == 1
  cCond3 := "% GBJ_COTIST <> '1' %"
 ElseIf MV_PAR02 == 2 
  cCond3 := "% GBJ_COTIST <> '0' %"
 Else
  cCond3 := "% GBJ_COTIST <> '3' %"
 EndIf  

 If !Empty(MV_PAR04)
  cCond4 := "%GBJ_ESPEC1 = '" + MV_PAR04 + "' OR GBJ_ESPEC2 = '" + MV_PAR04 + "' OR GBJ_ESPEC3 = '" + MV_PAR04 + "'%"
 Else
  cCond4 := "%GBJ_ESPEC1 <> '" + STR(Len(MV_PAR04)) + "' OR GBJ_ESPEC2 <> '" + STR(Len(MV_PAR04)) + "' OR GBJ_ESPEC3 <> '" + STR(Len(MV_PAR04)) + "'%"
 EndIf  

oSection1:BeginQuery()
BeginSql alias "QRYR50"
 SELECT RA_NOME, GBJ_CRM, RA_CIC, RA_TELEFON, GBJ_TELCOM, GBJ_TIPPRO, GBJ_REPAMB, GBJ_RAMBUR, GBJ_REPINT,;
        GBJ_RINTUR, GBJ_STATUS, GBJ_COTIST
 FROM %table:GBJ% GBJ
 JOIN %table:SRA% SRA ON SRA.RA_CODIGO = GBJ.GBJ_CRM AND SRA.RA_FILIAL = %xFilial:SRA% AND SRA.%notDel%
 WHERE GBJ.GBJ_FILIAL = %xFilial:GBJ% AND GBJ.%notDel% 
 AND %Exp:cCond1% 
 AND %Exp:cCond2% 
 AND %Exp:cCond3% 
 AND %Exp:cCond4%
 ORDER BY RA_NOME
EndSql

	oSection1:EndQuery()
	oSection2:SetParentQuery()
 If !Empty(MV_PAR04)
  oSection2:SetParentFilter( {|G| GFR->GFR_DSESPE == G }, {|| GFR->GFR_DSESPE})
 EndIf
 oSection1:Print() // processa as informacoes da tabela principal
 oReport:SetMeter(QRYR50->(LastRec()))
                   
Return( NIL )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR50 บ Autor ณ Rogerio Faro      บ Data ณ Janeiro/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDescricao ณ LISTAGEM DE PROFISSIONAIS                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAltera็ใo ณEduardo Alves - Altera do campo especialidade de X5 para GFRบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR50R3()
 Local cDesc1  := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2  := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3  := ""
 Local cPict   := ""
 Local cTitulo := STR0003 //"Relacao de Profissionais"
 Local nLin    := 80
 Local cCabec1 := ""
 Local cCabec2 := ""
 Local imprime := .T.
 Local aOrd    := {}
 Local nLinTotal := 60

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Declaracao de Variaveis Privadas                                    ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private CbTxt        := "M"
 Private limite       := 132
 Private tamanho      := "M"
 Private nomeprog     := "HSPAHR50"
 Private nTipo        := 18
 Private aReturn      := {STR0004, 1, STR0005, 1, 1, 1, "", 1}   //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private cbcont       := 00
 Private CONTFL       := 01
 Private m_pag        := 01
 Private wnrel        := "HSPAHR50"
 Private cString      := ""
 Private aRegistros   := {}

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

	Private lGFR := HS_LocTab("GFR", .F.) 
 
 cPerg := "HSPR50"

 If !Pergunte(cPerg,.T.)
  return
 EndIf

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2

 If Mv_Par01 == 1
  cTitulo += " - " + STR0006 //"Corpo Clinico"
 ElseIf Mv_Par01 == 2
  cTitulo += " - " + STR0007 //"Eventuais"
 Endif
 
 If Mv_Par02 == 1
  cTitulo += " - " + STR0008 //"Ativos"
 ElseIf Mv_Par02 == 2
  cTitulo += " - " + STR0009 //"Inativos"
 Endif

 If !Empty(MV_PAR04)			            
  If lGFR
  	cCabec1 	:= STR0010 + Posicione("GFR", 1, xFilial("GFR") + MV_PAR04, "GFR_DSESPE") + Iif(Mv_Par03 == 1, STR0011,"") //"Especialidade --> "###" - Cotistas"
  Else
  	cCabec1 	:= STR0010 + Posicione("SX5", 1, xFilial("SX5") + "EM" + MV_PAR04, "X5_DESCRI") + Iif(Mv_Par03 == 1, STR0011,"") //"Especialidade --> "###" - Cotistas"
  EndIf
 Else
  cCabec1 	:= STR0010 + STR0025 + Iif(Mv_Par03 == 1, STR0011,"") //"Especialidade --> "###" - Cotistas" //"Todas"
 EndIf 

 cCabec2 	:= STR0012 //"Nome do Profissional               Cod.CRM CPF         Telefone             Tel.Comercial   Categoria    % AMB. %AMB.U % INT. %INT.U"
                     //           1         2         3         4         5         6         7         8         9        10        11        12        13
       			           // 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
                     // 1234567890123456789012345678901234 1234567 12345678901 12345678901234567890 123456789012345 123456789012 123456 123456 123456 123456

 wnrel := SetPrint(cString,NomeProg,"",@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
 
 If nLastKey == 27
  Return
 Endif
 
 SetDefault(aReturn,cString)
 
 If nLastKey == 27
  Return
 Endif
 
 RptStatus({|| RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)}, cTitulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPREL บ Autor ณ ROGERIO FARO       บ Data ณJaneiro/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)
 
 Local cRegAte 	:= ""
 Local aRegs    := {}
 Local T

 Set Printer to &wNRel
 Set Printer On
 Set Device  to Printer

 DbSelectArea("GBJ")
 DbGoTop()
 SetRegua(RecCount())
 
 While !Eof() .And. GBJ->GBJ_FILIAL == xFilial("GBJ")
  IncRegua()
  If MV_PAR01 # 3
   If MV_PAR01 == 1
    IF GBJ->GBJ_TIPPRO # "0"
     DbSkip()
     loop
    Endif
   Elseif MV_PAR01 == 2
    IF GBJ->GBJ_TIPPRO # "1"
     DbSkip()
     loop
    Endif
   Endif
  Endif

  If MV_PAR02 # 3
   If MV_PAR02 == 1
    IF GBJ->GBJ_STATUS # "1"
     DbSkip()
     loop
    Endif
   Elseif MV_PAR02 == 2
    IF GBJ->GBJ_STATUS # "0"
     DbSkip()
     loop
    Endif
   Endif
  Endif

  If MV_PAR03 # 3
   If MV_PAR03 == 1
    IF GBJ->GBJ_COTIST # "1"
     DbSkip()
     loop
    Endif
   Elseif MV_PAR03 == 2
    IF GBJ->GBJ_COTIST # "0"
     DbSkip()
     loop
    Endif
   Endif
  Endif
  
  If !Empty(MV_PAR04)
   IF !(MV_PAR04 $ HS_REspMed(GBJ->GBJ_CRM))
    DbSkip()
    loop
   Endif
  EndIf
  
  aadd(aRegs,{Posicione("SRA", 11, xFilial("SRA") + GBJ->GBJ_CRM, "RA_NOME"), GBJ->GBJ_CRM, ;
   TRANSFORM(Posicione("SRA", 11, xFilial("SRA") + GBJ->GBJ_CRM, "RA_CIC"), "@R 999.999.999-99"), ;
             Posicione("SRA", 11, xFilial("SRA") + GBJ->GBJ_CRM, "RA_TELEFON"), GBJ->GBJ_TELCOM, ;
             HS_RDescrB("GBJ_TIPPRO",GBJ->GBJ_TIPPRO), ;
             GBJ->GBJ_REPAMB, GBJ->GBJ_RAMBUR, GBJ->GBJ_REPINT, GBJ->GBJ_RINTUR})
  dbskip()
 Enddo
 
 If aRegs # Nil
  aSort(aRegs,,,{|x,y| x[1] < y[1]})
  FOR T = 1 TO Len(aRegs)
   IncRegua()
   If nLin > nMaxLin // Salto de Pแgina. Neste caso o formulario tem 66 linhas...
    nLin := Cabec(cTitulo,cCabec1,cCabec2,NomeProg,Tamanho,nTipo) + 1
   Endif                    

   @ nlin, 000 PSay PadR(aRegs[t, 01], 34)
   @ nlin, 035 PSay PadR(aRegs[t, 02], 07)
   @ nlin, 043 PSay PadR(aRegs[t, 03], 11)
   @ nlin, 055 PSay PadR(aRegs[t, 04], 20)
   @ nlin, 076 PSay PadR(aRegs[t, 05], 15)
   @ nlin, 092 PSay PadR(aRegs[t, 06], 12)
   @ nlin, 105 PSay Transform(aRegs[t, 07], "@E 999.99")
   @ nlin, 112 PSay Transform(aRegs[t, 08], "@E 999.99")
   @ nlin, 119 PSay Transform(aRegs[t, 09], "@E 999.99")
   @ nlin, 126 PSay Transform(aRegs[t, 10], "@E 999.99")
   nLin++
  next
 Endif
 
 Set Printer to
 Set Device  to Screen
 
 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()
Return(Nil)