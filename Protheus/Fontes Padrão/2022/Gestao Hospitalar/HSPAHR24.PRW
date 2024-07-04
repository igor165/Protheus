#INCLUDE "HSPAHR24.ch"
#Include "protheus.ch"
#include "TopConn.ch"     
#include "report.ch"
#define TRACE  repl("_",80)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR24 บAutorณANTONIO CARLOS/Marceloบ Data ณ  18/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Agendas por Medico                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs:      ณ Convertido para relatorios personalizaveis                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPR24AM()
 cAlias:="GM8"
 HSPAHR24("GM8")
Return()

Function HSPR24CI()
 cAlias:="GMJ"
 HSPAHR24("GMJ")
Return()

Static Function HSPAHR24(cAlias)
Local oReport
Private nCtaAge := 0
 If FindFunction("TRepInUse") .And. TRepInUse() 
  IIF(cAlias=="GM8",pergunte("HSR24A",.F.),pergunte("HSR24C",.F.))
  oReport := ReportDef() 
  oReport:PrintDialog()  
 ELSE  
  HSPAHR24R3(cAlias)  
 EndIF    
Return( Nil )     

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos/Marceloณ Data ณ 18/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local cPref := cAlias
 Local oReport 
 Local oSection1
 Local oCell

 oReport := TReport():New("HSPAHR24",HS_MontCabe((IIF(cAlias=="GM8",STR0006+" "+STR0007,STR0006+" "+STR0008)),;
 MV_PAR01,MV_PAR02),(IIF(cAlias=="GM8","HSR24A","HSR24C")),{|oReport| R24IMP(oReport)}, STR0001 + STR0002 + STR0003) 
//"Ag. "###"Amb."###"Cir."### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."
  
 oReport:SetPortrait()          // Imprimir relatorio em formato retrato

 oSection1 := TRSection():New(oReport,STR0014,{"QRYR24","SRA","GM8"})
 oSection1:SetHeaderPage(.T.)
 oSection1:SetHeaderBreak(.F.)
 oSection1:SetNoFilter({"QRYR24"})
 oCell := TRCell():New(oSection1,"CODCRM","QRYR24",STR0029,,6)  //"CRM"
 oCell := TRCell():New(oSection1,"NOMMED","QRYR24",STR0030,,30) //"Nome do Medico"
 oCell := TRCell():New(oSection1,"STAAGE","QRYR24",STR0031,,15,,{|| FS_StAg24(("QRYR24")->STAAGE,("QRYR24")->QTDAGE) }) //"Situa็ใo"
 oCell := TRCell():New(oSection1,"QTDAGE","QRYR24",STR0032,"999999",6 ) //"Qtde"
 oCell := TRCell():New(oSection1,"PERC","QRYR24","( % )","999.99",6,,{|| STR(((("QRYR24")->QTDAGE/nCtaAge)*100),6,2)} )
 
oTotaliz0 := TRFunction():new(oSection1:Cell("QTDAGE"),,"SUM",,STR0013,,,.F.,.T.,.F.,,)  //"Total Geral.......: "

oTotaliz1 := TRFunction():new(oSection1:Cell("STAAGE"),,"SUM",,STR0033,,{|| Str(("QRYR24")->QTDAGE,6,0) },.F.,.T.,.F.,,)  //"Qtde de Liberados"
oTotaliz1:SetCondition( { || ("QRYR24")->STAAGE == "1" } ) 
oTotaliz1 := TRFunction():new(oSection1:Cell("STAAGE"),,"SUM",,STR0034,,{|| Str(((("QRYR24")->QTDAGE/nCtaAge)*100),6,2) },.F.,.T.,.F.,,)  //"( %) de Liberados"
oTotaliz1:SetCondition( { || ("QRYR24")->STAAGE == "1" } )  

oTotaliz2 := TRFunction():new(oSection1:Cell("STAAGE"),,"SUM",,STR0035,,{|| Str(("QRYR24")->QTDAGE,6,0) },.F.,.T.,.F.,,)  //"Qtde de Ocupados"
oTotaliz2:SetCondition( { || ("QRYR24")->STAAGE == "2" } ) 
oTotaliz2 := TRFunction():new(oSection1:Cell("STAAGE"),,"SUM",,STR0036,,{|| Str(((("QRYR24")->QTDAGE/nCtaAge)*100),6,2) },.F.,.T.,.F.,,)  //"( %) de Ocupados"
oTotaliz2:SetCondition( { || ("QRYR24")->STAAGE == "2" } ) 

oTotaliz3 := TRFunction():new(oSection1:Cell("STAAGE"),,"SUM",,STR0037,,{|| Str(("QRYR24")->QTDAGE,6,0) },.F.,.T.,.F.,,)  //"Qtde de Atendidos"
oTotaliz3:SetCondition( { || ("QRYR24")->STAAGE == "3" } ) 
oTotaliz3 := TRFunction():new(oSection1:Cell("STAAGE"),,"SUM",,STR0038,,{|| Str(((("QRYR24")->QTDAGE/nCtaAge)*100),6,2) },.F.,.T.,.F.,,)  //"( %) de Atendidos"
oTotaliz3:SetCondition( { || ("QRYR24")->STAAGE == "3" } ) 
 
oTotaliz4 := TRFunction():new(oSection1:Cell("STAAGE"),,"SUM",,STR0039,,{|| Str(("QRYR24")->QTDAGE,6,0) },.F.,.T.,.F.,,)  //"Qtde de Bloqueados"
oTotaliz4:SetCondition( { || ("QRYR24")->STAAGE == "4" } ) 
oTotaliz4 := TRFunction():new(oSection1:Cell("STAAGE"),,"SUM",,STR0040,,{|| Str(((("QRYR24")->QTDAGE/nCtaAge)*100),6,2) },.F.,.T.,.F.,,)  //"( %) de Bloqueados"
oTotaliz4:SetCondition( { || ("QRYR24")->STAAGE == "4" } ) 

oTotaliz5 := TRFunction():new(oSection1:Cell("STAAGE"),,"SUM",,STR0041,,{|| Str(("QRYR24")->QTDAGE,6,0) },.F.,.T.,.F.,,)  //"Qtde de Confirmados"
oTotaliz5:SetCondition( { || ("QRYR24")->STAAGE == "5" } ) 
oTotaliz5 := TRFunction():new(oSection1:Cell("STAAGE"),,"SUM",,STR0042,,{|| Str(((("QRYR24")->QTDAGE/nCtaAge)*100),6,2) },.F.,.T.,.F.,,)  //"( %) de Confirmados"
oTotaliz5:SetCondition( { || ("QRYR24")->STAAGE == "5" } ) 

oTotaliz6 := TRFunction():new(oSection1:Cell("STAAGE"),,"SUM",,STR0043,,{|| Str(("QRYR24")->QTDAGE,6,0) },.F.,.T.,.F.,,)  //"Qtde de Retornos"
oTotaliz6:SetCondition( { || ("QRYR24")->STAAGE == "6" } ) 
oTotaliz6 := TRFunction():new(oSection1:Cell("STAAGE"),,"SUM",,STR0044,,{|| Str(((("QRYR24")->QTDAGE/nCtaAge)*100),6,2) },.F.,.T.,.F.,,)  //"( %) de Retornos"
oTotaliz6:SetCondition( { || ("QRYR24")->STAAGE == "6" } ) 

Return( oReport )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณR24Imp    ณ Autor ณ Antonio Carlos/Marceloณ Data ณ 17/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R24IMP(oReport)

Local oSection1 := oReport:Section(1)
Local cCond1 := ""

MakeSqlExpr(oReport:uParam)

If MV_PAR03=2
 cCond1:="%RA_NOME, STAAGE%"
Else  
 cCond1:= "%QTDAGE DESC%"
Endif 

oSection1:BeginQuery()

If cAlias=="GM8"
 BeginSql alias "QRYR24"
  SELECT GM8_CODCRM AS CODCRM, RA_NOME NOMMED, GM8_STATUS STAAGE, COUNT(*) AS QTDAGE 
  FROM %table:GM8% GM8 
  JOIN %table:SRA% SRA ON SRA.RA_CODIGO = GM8.GM8_CODCRM AND SRA.RA_FILIAL = %xFilial:SRA% AND SRA.%notDel%
  WHERE GM8.GM8_FILIAL = %xFilial:GM8% AND GM8.%notDel% 
    AND GM8.GM8_DATAGE BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)% 
    AND GM8.GM8_STATUS <> %Exp:'0'% AND GM8.GM8_STATUS <> %Exp:'6'%    
  GROUP BY GM8.GM8_CODCRM, SRA.RA_NOME, GM8.GM8_STATUS
  ORDER BY %Exp:cCond1%
 EndSql
Else
 BeginSql alias "QRYR24"
  SELECT GMJ_CODCRM AS CODCRM, RA_NOME NOMMED, GMJ_STATUS STAAGE, COUNT(*) AS QTDAGE 
  FROM %table:GMJ% GMJ 
  JOIN %table:SRA% SRA ON SRA.RA_CODIGO = GMJ.GMJ_CODCRM AND SRA.RA_FILIAL = %xFilial:SRA% AND SRA.%notDel%
  WHERE GMJ.GMJ_FILIAL = %xFilial:GMJ% AND GMJ.%notDel% 
    AND GMJ.GMJ_DATAGE BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)% 
    AND GMJ.GMJ_STATUS <> %Exp:'0'% AND GMJ.GMJ_STATUS <> %Exp:'6'%    
  GROUP BY GMJ.GMJ_CODCRM, SRA.RA_NOME, GMJ.GMJ_STATUS
  ORDER BY %Exp:cCond1%
 EndSql
EndIf      
oSection1:EndQuery()

DbGotop()
While ("QRYR24")->(!Eof())
 nCtaAge := nCtaAge + ("QRYR24")->QTDAGE
 DbSkip()
End
DbGotop()

oSection1:Print() 
oReport:SetMeter(("QRYR24")->(LastRec()))
 
Return( NIL )
/******************************************************************************************************************/
Static Function FS_StAg24(cPar1,cPar2)
 cRet := ""
 If cPar1 == "1"
  cRet := STR0045       //"Liberado"
 ElseIf cPar1 == "2"
  cRet := STR0018      //"Ocupado"       
 ElseIf cPar1 == "3"
  cRet := STR0020      //"Atendido"    
 ElseIf cPar1 == "4"
  cRet := STR0021      //"Ocup/Bloq"   
 ElseIf cPar1 == "5"
  cRet := STR0022      //"Confirmado"   
 ElseIf cPar1 == "6"
  cRet := STR0046      //"Retorno"
 EndIf 
Return( cRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR24R3บ Autor ณ Mario Arizono      บ Data ณ  17/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Agendas por Medico                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function HSPAHR24R3(cAlias)

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ Declaracao de Variaveis                                             ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := STR0003 //"Agendas por Medico "
Local nLin           := 80 
Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd 				      := {}    
Local aArea          := GetArea()

Private lEnd       := .F.
Private lAbortPrint:= .F.
Private limite     := 80
Private tamanho    := "P"
Private nomeprog   := FunName()/* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo      := 18
Private aReturn    := {STR0004, 1, STR0005, 2, 2, 1, "", 1}       //"Administracao"###"Zebrado"
Private nLastKey   := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "HSPAHR24" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cString    := ""  
Private cCODIMP    := ""
Private nMaxLin    := 0 // quantidade maxima de linhas p/ impressao

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ PARAMETROS                                                          ณ
 ณ MV_PAR01	Data Agenda Inicial                                        ณ
 ณ MV_PAR02	Data Agenda Final                                          ณ
 ณ MV_PAR03	Ordenacao        1=quantidade de agend.   2=Nome Prof.     ณ
 ณ MV_PAR04	Grafico          1=Sim      2=Nao                          ณ     
 | MV_PAR05 Impressora ?                                               |
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

cPerg := IIF(cAlias=="GM8", "HSR24A", "HSR24C")  
If !Pergunte(cPerg,.T.)
	return
EndIf

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)         

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
 Return
Endif

nTipo := If(aReturn[4]==1,15,18)
RptStatus({|| RunReport(cAlias,Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Mario Arizono      บ Data ณ  17/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(cAlias,Cabec1,Cabec2,Titulo,nLin) 

Local cPref      := cAlias + "." + PrefixoCpo(cAlias)  
Local cSQL 	     := ""  
Local aTotSta    := {}
Private nTotGer  := 0   
Private nPerMed  := 0   
Private aVetGraf := {}

 Titulo := STR0006 + IIF(cAlias=="GM8", STR0007, STR0008) + " " + DTOC(MV_PAR01) + " - " + DTOC(MV_PAR02)//"Ag. "###"Amb."###"Cir.
  
 cSQL := "SELECT " + cPref+"_CODCRM AS CODCRM, SRA.RA_NOME NOMMED, " + cPref+"_STATUS STAAGE, COUNT(*) AS QTDAGE "
 cSQL += "FROM " + RetSQLName(cAlias) + " " + cAlias   
 cSQL += " JOIN " +  RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  =" +cPref+"_CODCRM"
 cSQL += " WHERE "
 cSQL += cPref+"_FILIAL = '" + xFilial(cAlias) + "' AND " + cAlias + "." + "D_E_L_E_T_ <> '*' AND "  
 cSQL += " SRA.RA_FILIAL = '" +  xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND "
 cSQL += cPref+"_DATAGE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND " 
 cSQL += cPref+"_STATUS NOT IN ('0','6') "    
 If MV_PAR03=2
  cSQL += "GROUP BY " +cPref+"_CODCRM, SRA.RA_NOME, "+ cPref+"_STATUS "
  cSQL += "ORDER BY RA_NOME, STAAGE"
 Else  
  cSQL += "GROUP BY " +cPref+"_CODCRM, SRA.RA_NOME, "+ cPref+"_STATUS " 
  cSQL += "ORDER BY QTDAGE DESC"
 Endif 
 
 cSQL :=  ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()     
                                  
 If Eof()
  HS_MsgInf(STR0010,STR0023,STR0014)    //"Nenhum dado foi encontrado para a selecao efetuada!" //"Atencao"###"Agendas por Medico"
 Endif     

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

 SetRegua(100)
 
 AADD(aTotSta,{0,0,0,0,0})
 While !EOF()
	 nTotGer += QRY->QTDAGE
	 aTotSta[1,VAL(QRY->STAAGE)]+= QRY->QTDAGE
	 dbSkip()  
 EndDo      
 
 DBGOTOP()
 While !EOF()
 
  IncRegua()
  If lAbortPrint
   @nLin,00 PSAY STR0011 //"*** CANCELADO PELO OPERADOR ***"
   Exit 
  Endif   
     
  If nLin > nMaxLin
 /*                    				       1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                  	     0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
   Cabec1 := STR0012 //"Profissional                                 Status      Quantidade      (%)"
   Cabec2 := "" 
   Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   nLin := 9
  Endif

  @nLin,000 PSAY QRY->CODCRM+" - "+ SUBSTR(QRY->NOMMED,1,33)
  FS_RetStatus(QRY->STAAGE,nLin)
  @nLin,060 PSAY TRANSFORM(QRY->QTDAGE, "@E 999,999") 
  nPerMed:= (QRY->QTDAGE/nTotGer)*100
  If nPos := aScan(aVetGraf,{|x| x[2] $ PADR(QRY->NOMMED,8)}) == 0
   AADD(aVetGraf,{nPerMed,PADR(QRY->NOMMED,8)+" "+STR(nPerMed,6,2)+"%"})
  Else          
   aVetGraf[nPos,1] += nPerMed
  EndIf 
  @nLin,070 PSAY TRANSFORM(nPerMed, "@E 999.99") + "%"
  nLin ++  
 
  DBSkip()
 
  If EOF()
   If nLin < (nMaxLin - 3)
    @nLin,000 PSAY TRACE
    nLin++   
    @nLin,035 PSAY STR0024   //"Total Ocupados....:"
    @nLin,060 PSAY TRANSFORM(aTotSta[1,1], "@E 999,999") 
    @nLin,070 PSAY TRANSFORM(((aTotSta[1,1]/nTotGer)*100), "@E 999.99") + "%"
    nLin++
    @nLin,035 PSAY STR0025   //"Total Bloqueados..:"
    @nLin,060 PSAY TRANSFORM(aTotSta[1,2], "@E 999,999") 
    @nLin,070 PSAY TRANSFORM(((aTotSta[1,2]/nTotGer)*100), "@E 999.99") + "%"
    nLin++
    @nLin,035 PSAY STR0026  //"Total Atendidos...:"
    @nLin,060 PSAY TRANSFORM(aTotSta[1,3], "@E 999,999") 
    @nLin,070 PSAY TRANSFORM(((aTotSta[1,3]/nTotGer)*100), "@E 999.99") + "%"
    nLin++
    If cAlias == "GM8"
     @nLin,035 PSAY STR0027   //"Total Ocup./Bloq..:"
     @nLin,060 PSAY TRANSFORM(aTotSta[1,4], "@E 999,999")   
     @nLin,070 PSAY TRANSFORM(((aTotSta[1,4]/nTotGer)*100), "@E 999.99") + "%"
     nLin++
     @nLin,035 PSAY STR0028   //"Total Confirmados.:"
     @nLin,060 PSAY TRANSFORM(aTotSta[1,5], "@E 999,999") 
     @nLin,070 PSAY TRANSFORM(((aTotSta[1,5]/nTotGer)*100), "@E 999.99") + "%"
     nLin++
    Endif                                                                              
    @nLin,035 PSAY STR0013 //"Total Geral.......: " 
    @nLin,060 PSAY TRANSFORM(nTotGer, "@E 999,999") 
    @nLin,070 PSAY "100,00%" 
   Else
    nlin:=3   
    @nLin,035 PSAY STR0024   //"Total Ocupados....:"
    @nLin,060 PSAY TRANSFORM(aTotSta[1,1], "@E 999,999") 
    @nLin,070 PSAY TRANSFORM(((aTotSta[1,1]/nTotGer)*100), "@E 999.99") + "%"
    nLin++
    @nLin,035 PSAY STR0025   //"Total Bloqueados..:"
    @nLin,060 PSAY TRANSFORM(aTotSta[1,2], "@E 999,999") 
    @nLin,070 PSAY TRANSFORM(((aTotSta[1,2]/nTotGer)*100), "@E 999.99") + "%"
    nLin++
    @nLin,035 PSAY STR0026  //"Total Atendidos...:"
    @nLin,060 PSAY TRANSFORM(aTotSta[1,3], "@E 999,999") 
    @nLin,070 PSAY TRANSFORM(((aTotSta[1,3]/nTotGer)*100), "@E 999.99") + "%"
    nLin++
    If cAlias == "GM8"
     @nLin,035 PSAY STR0027   //"Total Ocup./Bloq..:"
     @nLin,060 PSAY TRANSFORM(aTotSta[1,4], "@E 999,999")   
     @nLin,070 PSAY TRANSFORM(((aTotSta[1,4]/nTotGer)*100), "@E 999.99") + "%"
     nLin++
     @nLin,035 PSAY STR0028   //"Total Confirmados.:"
     @nLin,060 PSAY TRANSFORM(aTotSta[1,5], "@E 999,999") 
     @nLin,070 PSAY TRANSFORM(((aTotSta[1,5]/nTotGer)*100), "@E 999.99") + "%"
     nLin++
    Endif  
    @nLin,035 PSAY STR0013 //"Total Geral.......: " 
    @nLin,060 PSAY TRANSFORM(nTotGer, "@E 999,999") 
    @nLin,070 PSAY "100,00%"
   EndIf 
  
   If MV_PAR04 == 1     
   // CRIA O OBJETO PARA CONSTRUCAO DO GRAFICO CARTEZIANO  
    oGraf := hsGRAF():NEW(STR0014, STR0014, STR0015+Str(nTotGer,8,2), STR0016, STR0017, "", aVetGraf,1,1,0,0,2,17,6,6,25,20)   //"Agendas por Medico"###"Agendas por Medico"###"Total Geral de Agendamentos.......:"###"Percentual %"###"Medicos"
   EndIf    
  Endif
 EndDo
 
/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ Finaliza a execucao do relatorio...                                 ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/

SET DEVICE TO SCREEN

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ Se impressao em disco, chama o gerenciador de impressao...          ณ                                           	
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()
DBCloseArea()

Return 

Static Function FS_RetStatus(nVal,nLin)
 If nVal = '1' 
  @nLin,045 PSAY STR0018 //"Ocupado"
 ElseIf nVal = '2' 
  @nLin,045 PSAY STR0019  //"Bloqueado"
 ElseIf nVal = '3'
  @nLin,045 PSAY STR0020  //"Atendido"
 ElseIf nVal = '4'
  @nLin,045 PSAY STR0021  //"Ocup/Bloq"
 ElseIf nVal = '5'
  @nLin,045 PSAY STR0022  //"Confirmado"
 EndIf  
Return()
