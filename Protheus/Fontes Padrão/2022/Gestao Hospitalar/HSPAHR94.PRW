#INCLUDE "HSPAHR94.ch"
#include "rwmake.ch"
#include "TopConn.ch"
#Include "protheus.ch"
#include "report.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR94 บAutorณ	 SAUDE	    		 Data ณ  26/01/11     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Clinicas  Agendamento por Profissional                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs:      ณ Convertido para relatorios personalizaveis                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR94()
Local oReport
Private nCtaAge := 0
Private aVetdados :={}
Private nPosMed:=0 
Private cGcsTipLoc := "I" 

If FindFunction("TRepInUse") /*.And. TRepInUse()*/
	pergunte("HSPR94A   ",.F.)
	oReport := ReportDef()
	oReport:PrintDialog()
EndIF
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Saudeณ 				  Data ณ 26/01/1 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()

Local oReport
Local oSection1,oSection2
Local oCell
Local ni:=1

oReport := TReport():New("HSPAHR94",HS_MontCabe((STR0001),; //"Agendamento Por Profissional"
MV_PAR01,MV_PAR02),("HSPR94A   "),{|oReport| R94IMP(oReport)}, STR0002 + STR0003 +  STR0004) //"Agendamento X Profissional"###"Este programa tem como objetivo imprimir relatorio"###"de acordo com os parametros informados pelo usuario."


oReport:SetPortrait()          // Imprimir relatorio em formato retrato

oSection1 := TRSection():New(oReport,STR0005,{"QRYR94","SRA","GM8"}) //"Agenda Medico"
oSection1:SetHeaderPage(.T.)
oSection1:SetHeaderBreak(.F.)
oSection1:SetNoFilter({"QRYR94"})

oCell := TRCell():New(oSection1,"GM8_DATAGE","QRYR94",STR0006,,,,{|| ("QRYR94")->GM8_DATAGE}) //"Data"                                                         
oCell := TRCell():New(oSection1,"GM8_HORAGE","QRYR94",STR0014,,,,{|| ("QRYR94")->GM8_HORAGE}) //"Data"  

oCell := TRCell():New(oSection1,"GM8_CODLOC","QRYR94",STR0007,,2) //"Setor Agend."
oCell := TRCell():New(oSection1,"cNOMSET","GCS",STR0008,,TamSX3("GCS_NOMLOC")[1],,{||HS_INIPADR("GCS",1, QRYR94->GM8_CODLOC, "GCS_NOMLOC")})  //"Descricใo"


oCell := TRCell():New(oSection1,"CODCRM","QRYR94",STR0009,,12)  //"CRM" //"CRM"
oCell := TRCell():New(oSection1,"NOMMED","QRYR94",STR0010,,30) //"Profissional"

oCell := TRCell():New(oSection1,"NOMPAC","QRYR94",STR0011,,40) //"Nome Paciente."
oCell := TRCell():New(oSection1,"TELPAC","QRYR94",STR0012,,15) //"Tel. Paciente."



oSection2 := TRSection():New(oReport,,{"QRYR94A"})
oSection2:SetHeaderPage(.F.)
oSection2:SetHeaderBreak(.F.)
oSection2:SetNoFilter({"QRYR94A"})

oCell := TRCell():New(oSection2,"cDataSo"   ,"QRYR94A" ,STR0006,, 10,,{|| cDataSo :=  DTOC(STOD(("QRYR94A")->GM8_DATAGE))}) //"data"

oCell := TRCell():New(oSection2,"QTDE","QRYR94A",STR0013,, 10,, ) //"Quantidade"
oCell := TRCell():New(oSection2,"RA_NOME","QRYR94A",STR0010,,30) //"Profissional"






Return( oReport )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณR94Imp    ณ Autor ณ SAUDE                 ณ Data ณ 26/01/11 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R94IMP(oReport)
Local oSection1,oSection2
Local cCondi := ""
Local cCondC := ""
Local cCondC2 := ""
Local cCondF := ""
Local cCondW := ""
Local cCondO := ""

oSection1 := oReport:Section(1)
oSection2 := oReport:Section(2)
//MakeSqlExpr(oReport:uParam)


If !Empty(MV_PAR01) .Or. !Empty(MV_PAR02)
	cCondi := " GM8.GM8_DATAGE BETWEEN '" + DTOS(MV_PAR01)+ "' AND '" +DTOS(MV_PAR02)+ "' AND "		
Endif

If !Empty(MV_PAR03)
	cCondi+=" GM8.GM8_LOCAGE = '" +MV_PAR03+ "' AND "
Endif

If !Empty(MV_PAR04)
	cCondi+=" GM8.GM8_CODCRM = '" +MV_PAR04 +"' AND "
Endif


MakeSqlExpr(oReport:uParam)  
oSection1:BeginQuery() 

cCondC += "%GM8.GM8_DATAGE,GM8.GM8_HORAGE,GM8.GM8_CODCRM,GM8.GM8_CODLOC,GM8.GM8_CODCRM CODCRM, SRA.RA_NOME NOMMED, GBH.GBH_NOME  NOMPAC, GBH.GBH_TEL  TELPAC%"


cCondF += "% " + RetSqlName("GM8") + " GM8 "
cCondF += " JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_CODIGO = GM8.GM8_CODCRM  AND SRA.RA_FILIAL='" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*'  "
cCondF += "	JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GM8.GM8_REGGER AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*'  "
cCondF += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GM8.GM8_LOCAGE AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_TIPLOC = 'I' %"
  
cCondW := "% " + cCondi + "  GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.D_E_L_E_T_ <> '*' "
cCondW += "  AND GM8_STATUS IN ('1','3','4','5','6') %"
cCondO :="%GM8_DATAGE%"


BeginSql alias "QRYR94"
 SELECT		%Exp:cCondC%
 FROM     	%Exp:cCondF%
 WHERE    	%Exp:cCondW%                                      	
 ORDER BY	%Exp:cCondO% 
EndSql 


oSection1:EndQuery()

DbSelectArea("QRYR94")
DbGoTop()
 
oSection1:Print()
oReport:SetMeter(("QRYR94")->(LastRec()))

cCondC2 += "%GM8_DATAGE,COUNT(*) QTDE,GM8_CODCRM, RA_NOME%"
cCondG :="%GM8_DATAGE,GM8_CODCRM,RA_NOME%"


BeginSql alias "QRYR94A"
 SELECT		%Exp:cCondC2%
 FROM     	%Exp:cCondF%
 WHERE    	%Exp:cCondW%  
 GROUP BY   %Exp:cCondG%                                    	
 ORDER BY	%Exp:cCondO%

EndSql 


oSection2:EndQuery()
DbSelectArea("QRYR94A")
DbGoTop()
oSection2:Print()
oReport:SetMeter(("QRYR94A")->(LastRec()))

Return( NIL )






