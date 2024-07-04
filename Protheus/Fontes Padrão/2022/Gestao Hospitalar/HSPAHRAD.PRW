#INCLUDE "HSPAHRAD.ch"
#include "protheus.ch"
#INCLUDE "Report.ch"
#include "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRAD บ Autor ณ HEIMDALL CASTRO    บ Data ณ 10/01/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ ESTATอSTICA OCUPAวรO SALA CIRURGICA                        บฑฑ
ฑฑบ          ณ Conversใo para relatorios personalizaveis                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRAD()

Local oReport
Private cPerg        := "HSPRAD"
Private lTmpR4:=.F.

If !Pergunte(cPerg,.T.)
 return
EndIf          

If FindFunction("TRepInUse") .And. TRepInUse()
	//pergunte("HSPRAD",.F.)
	FS_SQL() // Executa as querys 
	oReport := ReportDef()
	oReport:ParamReadOnly() //Desabilitando Botใo de parโmetros do Relat๓rio.
	oReport:PrintDialog()
ELSE
	HSPAHRADR3()
EndIF

HS_TmpR4()
TMPMED->(DbCloseArea())
TMPSET->(DbCloseArea())	
TMPSAL->(DbCloseArea())	
TMPESP->(DbCloseArea())

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ HEIMDALL CASTRO       ณ Data ณ 10/01/08 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
Local oReport
Local oSection1, 	oSection2, oSection3, oSection4, oSection5
Local oCell
Local oTotaliz1, oTotaliz2, oTotaliz3, oTotaliz4


oReport := TReport():New("HSPAHRAD",STR0001,"HSPRAD",{|oReport| RADIMP(oReport)},STR0007+STR0008)
 //""Estatistica Ocupacao Salas Cirurgica"###"Este programa tem como objetivo imprimir relat๓rio "###"de acordo com os parไmetros informados pelo usuแrio."  
 
oSection1 := TRSection():New(oReport,"SETOR",{"QRYSQL"})
oSection1:SetHeaderPage(.F.)
oSection1:SetHeaderBreak(.F.)
oSection1:SetHeaderSection(.T.)

oCell := TRCell():New(oSection1,"CODLOC","QRYSQL","Setor",,20,, {|| ("QRYSQL")->CODLOC + '-' + ("QRYSQL")->SETOR})

oSection2 := TRSection():New(oSection1,"SALA",{"QRYSQL"})
oSection2:SetHeaderPage(.F.)
oSection2:SetHeaderBreak(.F.)
oSection2:SetHeaderSection(.F.)

oCell := TRCell():New(oSection2,"SALA","QRYSQL","Sala",,10)
oCell := TRCell():New(oSection2,"TOTGERAL","QRYSQL","Sala",,20)
oCell := TRCell():New(oSection2,"TOTSALA","QRYSQL","Sala",,20) 
oCell := TRCell():New(oSection2,"nPorcTOcu","QRYSQL","","@E 999.99", 18,,{|| nPorcTOcu := (("QRYSQL")->TOTSALA/("QRYSQL")->TOTGERAL)*100})
oCell := TRCell():New(oSection2,"nPorcTOci","QRYSQL","","@E 999.99", 20,,{|| nPorcTOci := 100 - ((("QRYSQL")->TOTSALA/("QRYSQL")->TOTGERAL)*100)})

oSection3 := TRSection():New(oSection2,"Especialidade",{"QRYSQL"})
If MV_PAR05 != 2
	oSection3:SetHeaderPage(.F.)
	oSection3:SetHeaderBreak(.F.)
	oSection3:SetHeaderSection(.T.)
	 
	oCell := TRCell():New(oSection3,"NOMESP","QRYSQL","Especialidade",,20)
	oCell := TRCell():New(oSection3,"nqt","","TotEsp",,10,,{||nqt := FS_Espec(QRYSQL->CODESP,QRYSQL->CODLOC+QRYSQL->SALA)})
EndIf

oSection4 := TRSection():New(oSection3,,{"QRYSQL"})
If MV_PAR05 != 1
	oSection4:SetHeaderPage(.F.)
	oSection4:SetHeaderBreak(.F.)
	oSection4:SetHeaderSection(.F.)
	
	oCell := TRCell():New(oSection4,"MEDICO","QRYSQL","MEDICO",,35)
	oCell := TRCell():New(oSection4,"CONT","QRYSQL","Quant",,16)
EndIf	
oSection5 := TRSection():New(oSection4,,)
oSection5:SetHeaderPage(.T.)
oSection5:SetHeaderBreak(.F.)

oSection6 := TRSection():New(oSection5,,)
oSection6:SetHeaderPage(.T.)
oSection6:SetHeaderBreak(.F.)

oCell := TRCell():New(oSection5, "Perํodo",,,,10)
oCell := TRCell():New(oSection5, DTOC(MV_PAR03),,,,10)
oCell := TRCell():New(oSection5, " a ",,,,10)
oCell := TRCell():New(oSection5, DTOC(MV_PAR04),,,,10)

oCell := TRCell():New(oSection6, "Salas",,,,20)
oCell := TRCell():New(oSection6, "Horแrios Gerados",,,,20)
oCell := TRCell():New(oSection6, "Horแrios Ocupados",,,,20)
oCell := TRCell():New(oSection6, "Tx. Ocupa็ใo (%)",,,,20)
oCell := TRCell():New(oSection6, "Tx. Ociosidade (%)",,,,20)
oTotaliz1 :=  TRFunction():new(oSection2:Cell("TOTGERAL"),,"SUM",,    " Total  Gerados.......",,,.T.,.F.,.F.,oSection1) 
oTotaliz2 :=  TRFunction():new(oSection2:Cell("TOTSALA"),,"SUM",,     " Total Ocupados.......",,,.T.,.F.,.F.,oSection1) 
oTotaliz3 :=  TRFunction():new(oSection2:Cell("TOTGERAL"),,"AVERAGE",," %Total Ocupa็ใo......","@E 999.99%",{ || FS_Perc(QRYSQL->CODLOC) },.T.,.F.,.F.,oSection1) 
oTotaliz4 :=  TRFunction():new(oSection2:Cell("TOTSALA"),,"AVERAGE",, " %Total Ociosidade....","@E 999.99%",{ || FS_Perc2(QRYSQL->CODLOC) },.T.,.F.,.F.,oSection1) 

Return( oReport )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
//ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
//ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ RADImp   ณ Autor ณ HEIMDALL CASTRO       ณ Data ณ 10/01/08 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RADIMP(oReport)
 Local oSection1 := oReport:Section(1)
 Local oSection2 := oReport:Section(1):Section(1)
 Local oSection3 := oReport:Section(1):Section(1):Section(1)
 Local oSection4 := oReport:Section(1):Section(1):Section(1):Section(1)
	Local cCond1 := ""
	Local cCond2 := ""
	Local cCond3 := ""
	Local cCond4 := ""

 MakeSqlExpr(oReport:uParam)                  
   
 oSection1:BeginQuery() 
	
	cCond1  := "% COUNT(*) CONT, GMJ.GMJ_CODLOC CODLOC, GCS.GCS_NOMLOC SETOR, GMJ.GMJ_QUARTO SALA, GA7.GA7_CODESP CODESP, "+IIF(MV_PAR05 != 2,"GFR.GFR_DSESPE NOMESP,","")+" GMJ.GMJ_CODCRM CODCRM, SRA.RA_NOME MEDICO, "
	cCond1  += " (SELECT COUNT(*) FROM " + RETSQLNAME("GMJ") + " GMJ1 WHERE GMJ1.GMJ_CODLOC = GMJ.GMJ_CODLOC AND GMJ1.GMJ_QUARTO = GMJ.GMJ_QUARTO AND GMJ1.GMJ_DATAGE BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' AND GMJ1.GMJ_STATUS <> '2' AND GMJ1.GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ1.D_E_L_E_T_ <> '*') TOTGERAL, "
	cCond1  += " (SELECT COUNT(*) FROM " + RETSQLNAME("GMJ") + " GMJ2 WHERE GMJ2.GMJ_CODLOC = GMJ.GMJ_CODLOC AND GMJ2.GMJ_QUARTO = GMJ.GMJ_QUARTO AND (GMJ2.GMJ_STATUS = '1' OR GMJ2.GMJ_STATUS = '3') 	AND GMJ2.GMJ_DATAGE BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' AND GMJ2.GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ2.D_E_L_E_T_ <> '*') TOTSALA %"
	cCond2  := "% " + RETSQLNAME("GMJ") + " GMJ "
	cCond2  += " JOIN " + RETSQLNAME("GAV") + " GAV ON GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' AND GAV.GAV_TIPO = '2' "
	cCond2  += " JOIN " + RETSQLNAME("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GAV.GAV_CODLOC  "
	cCond2  += " JOIN " + RETSQLNAME("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GMJ.GMJ_CODPRO "
	cCond2  += " JOIN " + RETSQLNAME("SRA") + " SRA ON SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO = GMJ.GMJ_CODCRM "
	If MV_PAR05 != 2
		cCond2 += " JOIN " + RETSQLNAME("GFR") + " GFR ON GFR.GFR_FILIAL = '" + xFilial("GFR") + "' AND GFR.D_E_L_E_T_ <> '*' " + IIF(MV_PAR05 != 2," AND GFR.GFR_CDESPE = GA7.GA7_CODESP "," ")
	EndIF
	cCond2 += " %"
	cCond3 := "% GMJ.GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ.D_E_L_E_T_ <> '*' AND (GMJ.GMJ_STATUS = '1' OR GMJ.GMJ_STATUS = '3') AND GMJ.GMJ_CODLOC = GAV.GAV_CODLOC AND GMJ.GMJ_QUARTO = GAV.GAV_QUARTO "
	cCond3 += "		AND GMJ.GMJ_DATAGE BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' %"
	cCond4 := "% GMJ.GMJ_CODLOC, GCS.GCS_NOMLOC, GMJ.GMJ_QUARTO, GA7.GA7_CODESP, "+IIF(MV_PAR05 != 2,"GFR.GFR_DSESPE,","")+" GMJ.GMJ_CODCRM, SRA.RA_NOME %"

 //-- Transforma parametros Range em expressao SQL  
 
 BeginSql alias "QRYSQL"
		SELECT   %Exp:cCond1%
		FROM     %Exp:cCond2%
		WHERE    %Exp:cCond3%
		GROUP BY %Exp:cCond4%
 EndSql 
 
 oSection1:EndQuery()
 
// oSection1:SetParentQuery()
//	oSection1:SetParentFilter( {|G| ("QRYSQL")->SETOR  == G }, {|| ("QRYSQL")->SETOR } )

 oSection2:SetParentQuery()                                                                           
	oSection2:SetParentFilter( {|P| ("QRYSQL")->CODLOC == P }, {|| ("QRYSQL")->CODLOC } )

 oSection3:SetParentQuery()                                                                           
 oSection3:SetParentFilter( {|M| ("QRYSQL")->SALA == M }, {|| ("QRYSQL")->SALA } )
	
	oSection4:SetParentQuery()                                                                           
 oSection4:SetParentFilter( {|Z| ("QRYSQL")->CODESP + ("QRYSQL")->SALA == Z }, {|| ("QRYSQL")->CODESP + ("QRYSQL")->SALA } )
                                       
 oSection1:Print() // processa as informacoes da tabela principal
 oReport:SetMeter(QRYSQL->(LastRec()))
 
Return( NIL )                   
   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRADR3บ Autor ณ Gilson da Silva    บ Data ณ   13/07/05  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ OCUPACAO DE LEITOS                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRADR3()
 Private cTitulo       := STR0001 //"Estatistica Ocupacao Salas Cirurgica"
 Private lEnd         := .F.
 Private CbTxt        := ""
 Private limite       := 80
 Private cTamanho     := "P"
 Private cNomeProg    := "HSPAHRAD"       
 Private cNomeRel     := "HSPAHRAD"
 Private nTipo        := 18
 Private aReturn      := { STR0002, 1,STR0003, 1, 1, 1, "",1 } //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private cbcont       := 00
 Private cbText       := ""
 Private m_pag        := 01
 Private cAlias       := "GAV"            
 Private aOrd         := {}  
 Private Cabec1       := ""
 Private Cabec2       := STR0004 //STR0004 "Salas    Horarios Gerados    Horarios Ocupados    Tx. Ocupacao    Tx. Ociosidade"
 Private nLin         := 80        
 Private cGcsTipLoc := "4" //Definida para somente razer na consulta setores do centro Cirurgico.

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2
 
 Cabec1 := STR0016 + Dtoc(mv_par03) + STR0017 + Dtoc(mv_par04)// "Periodo de " ###" a  " 
 
 If LastKey() == 27
  Return(nil)
 Endif

 cNomeRel := SetPrint(cAlias, cNomeProg,cPerg,@cTitulo,STR0007,STR0008,STR0009,.F.,aOrd,.T.,cTamanho,nil,nil,nil)

 If LastKey() == 27
  Return(nil)
 Endif

 SetDefault(aReturn,cAlias)

 If LastKey() == 27
  Return(nil)
 Endif

 RptStatus({|lEnd| RunReport(@lEnd) },cTitulo)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ GILSON DA SILVA    บ Data ณ  13/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(lEnd)
	Local nPercOcu      := 0     
	Local nSetOcu       := 0
	Local nSetGer       := 0 
 Local cSetor        := ""
 Local cSala         := ""
 Local cEspec        := ""
 Local lInicio       := .T.
 Local lEspec        := .F.
 Local lMedico       := .F.
 Private nLin := nMaxLin * 2
	Private lAbortPrint := .F.                                 

	FS_SQL() // Executa as querys 

 DbSelectArea("TMPMED")
 DbGoTop()
 While !Eof()
	 //SetRegua(len(aRegistro))        
		//IncRegua()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Verifica o cancelamento pelo usuario...                             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lAbortPrint
			@nLin,000 PSAY STR0010 //"*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif      
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 	//ณ Impressao do cabecalho do relatorio. . .                            ณ
	 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 	If nLin > (nMaxLin-2)
 	 nLin := Cabec(cTitulo,Cabec1,Cabec2,cNomeProg,cTamanho,nTipo)   
   nLin++
	 Endif                                                  

		// Pega o setor com o nome
		If cSetor <> TMPMED->CODLOC
   // Imprime totais por setor se nใo for inicio do relat๓rio
			nSetGer := FS_Setor(IIF(lInicio,TMPMED->CODLOC,cSetor))
   If !lInicio
			 nPercOcu := (100*nSetOcu)/nSetGer // HORARIOS OCUPADOS/HORARIOS GERADOS
	   nLin += 2
		 	If nLin > (nMaxLin-2)
		 	 nLin := Cabec(cTitulo,Cabec1,Cabec2,cNomeProg,cTamanho,nTipo)   
		   nLin++
			 Endif                                                  
			 @ nLin,000 PSAY STR0018 //"Total do Setor: " 
				@ nLin,014 PSAY Transform(nSetGer, "@E 999,999,999")
	 		@ nLin,030 PSAY Transform(nSetOcu, "@E 999,999,999") 
		 	@ nLin,057 PSAY Transform(nPercOcu, "@E 999.99")+"%"
	 		@ nLin,074 PSAY Transform(100 - nPercOcu, "@E 999.99")+"%"
	   nLin +=2
//	   nSetGer := 0
	   nSetOcu := 0 
	  Endif      
	  lInicio := .F.
	
   // Imprime Cabe็alho do setor
   @ nLin,000 PSAY STR0015 + TMPMED->CODLOC + ' - ' + TMPMED->SETOR //"Setor: "
			nLin++
 			
		Endif
		cSetor :=TMPMED->CODLOC
		
		// Pega sala e quantidade
		If cSala <> (TMPMED->CODLOC+TMPMED->SALA)
   // Imprime Cabe็alho da Sala
   nSalGer := FS_Sala((TMPMED->CODLOC+TMPMED->SALA))
   nSalOcu := FS_SalaOc((TMPMED->CODLOC+TMPMED->SALA))
 		nLin++
	 	If nLin > (nMaxLin-2)
	 	 nLin := Cabec(cTitulo,Cabec1,Cabec2,cNomeProg,cTamanho,nTipo)   
	   nLin++
		 Endif                                                  
   @ nLin,000 PSAY (TMPMED->CODLOC+' '+TMPMED->SALA)
 		@ nLin,014 PSAY Transform(nSalGer, "@E 99,999,999") //quantidade da sala gerado
 		@ nLin,030 PSAY Transform(nSalOcu, "@E 99,999,999") //quantidade da sala ocupado
		 nPercOcu := (100*nSalOcu)/nSalGer // HORARIOS OCUPADOS/HORARIOS GERADOS
	 	@ nLin,056 PSAY Transform(nPercOcu, "@E 999.99")+"%"
 		@ nLin,073 PSAY Transform(100 - nPercOcu, "@E 999.99")+"%"
			nLin++
	  lMedico := .T.
	  lEspec  := .T.
		Endif
		
		// Pega especialidade e quantidade
  If MV_PAR05 != 2
			If (cEspec+cSala) <> (TMPMED->CODESP+(TMPMED->CODLOC+TMPMED->SALA))
	   // Imprime Cabe็alho da Especialidade
	   If lEspec 
					nLin++
			 	If nLin > (nMaxLin-2)
			 	 nLin := Cabec(cTitulo,Cabec1,Cabec2,cNomeProg,cTamanho,nTipo)   
			   nLin++
				 Endif                                                  
			  @ nLin,000 PSAY STR0026 //"Especialidade(s)"
			  nlin++
			  lEspec := .F.
			 EndIf
	   @ nLin,000 PSAY Left(TMPMED->NOMESP,20)
	 		@ nLin,030 PSAY Transform(FS_Espec(TMPMED->CODESP,(TMPMED->CODLOC+TMPMED->SALA)), "@E 99,999,999") //quantidade da especialidade
				nLin++
		  lMedico := .T.
			Endif
			cEspec = TMPMED->CODESP
		EndIf
		cSala = (TMPMED->CODLOC+TMPMED->SALA)
	  
  // Imprime Medico
  If MV_PAR05 != 1
	  If lMedico 
		 	If nLin > (nMaxLin-2)
		 	 nLin := Cabec(cTitulo,Cabec1,Cabec2,cNomeProg,cTamanho,nTipo)   
		   nLin++
			 Endif                                                  
		  @ nLin,000 PSAY STR0027 //"M้dico(s)"
		  nlin++    
		  lMedico := .F.
		 EndIf
	  @ nLin,000 PSAY Left(TMPMED->MEDICO,20)
			@ nLin,030 PSAY Transform(TMPMED->CONT, "@E 99,999,999")
	 	nLin++ // Avanca a linha de impressao
		 lEspec  := .T.
	 EndIf
	 nSetOcu += TMPMED->CONT

  // Pega pr๓ximo registro
  DbSkip()                                         
  
  // Imprime totais por setor se for fim de arquivo
		If Eof()
			nSetGer := FS_Setor(cSetor)
		 nPercOcu := (100*nSetOcu)/nSetGer // HORARIOS OCUPADOS/HORARIOS GERADOS
	 	nLin++ // Avanca a linha de impressao
		 @ nLin,000 PSAY STR0018 //"Total do Setor: " 
			@ nLin,014 PSAY Transform(nSetGer, "@E 999,999,999")
 		@ nLin,030 PSAY Transform(nSetOcu, "@E 999,999,999") 
	 	@ nLin,057 PSAY Transform(nPercOcu, "@E 999.99")+"%"
 		@ nLin,074 PSAY Transform(100 - nPercOcu, "@E 999.99")+"%"
		Endif
 End    
		
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(cNomeRel)
Endif

MS_FLUSH()
DBSelectArea("GAV")
DbClearFilter()
Return()

// Retorna quantidade por setor
Static Function FS_Setor(cSetor)
	Local nQuant := 0
	DbSelectArea("TMPSET")
	DbGoTop()
	While !eof()
	   If TMPSET->CODLOC == cSetor
					nQuant += TMPSET->CONT
	   EndIf     
 	 DbSkip()
	End
 DbSelectArea("TMPMED")
return(nQuant)

// Retorna quantidade por setor ocupado
Static Function FS_SetorOc(cSetor)
	Local nQuant := 0
	DbSelectArea("TMPSET")
	DbGoTop()
	While !eof()
	   If TMPSET->CODLOC == cSetor  .And. (TMPSET->GMJ_STATUS == '1' .Or. TMPSET->GMJ_STATUS == '3')
					nQuant += TMPSET->CONT
	   EndIf     
 	 DbSkip()
	End
 DbSelectArea("TMPMED")
return(nQuant)

// Retorna quantidade por sala
Static Function FS_Sala(cSala)
	Local nQuant := 0                    
	DbSelectArea("TMPSAL")
	DbGoTop()
	While !eof()
	   If TMPSAL->SALA == cSala 
					nQuant += TMPSAL->CONT
	   EndIf     
 	 DbSkip()
	End
 DbSelectArea("TMPMED")
return(nQuant)              

// Retorna quantidade por sala (ocupados)
Static Function FS_SalaOc(cSala)
	Local nQuant := 0                    
	DbSelectArea("TMPSAL")
	DbGoTop()
	While !eof()
	   If TMPSAL->SALA == cSala .And. (TMPSAL->GMJ_STATUS == '1' .Or. TMPSAL->GMJ_STATUS == '3')
					nQuant += TMPSAL->CONT
	   EndIf     
 	 DbSkip()
	End
 DbSelectArea("TMPMED")
return(nQuant)              

// Retorna quantidade por especialidade
Static Function FS_Espec(cEspec,cSala)
	Local nQuant := 0
	DbSelectArea("TMPESP")
	DbGoTop()
	While !eof()
   If TMPESP->ESPEC == cEspec .And. TMPESP->Sala == cSala
				nQuant += TMPESP->CONT
   EndIf     
 	 DbSkip()
	End
 DbSelectArea("TMPMED")
return(nQuant)              

Static Function FS_SQL()
	//PEGA QUANTIDADE DE ATENDIMENTOS POR SETOR (SETOR E QUANTIDADE):
	cSql := " SELECT COUNT(*) CONT, GMJ_STATUS GMJ_STATUS, GMJ_CODLOC CODLOC"
	cSql += " FROM  " + RETSQLNAME("GAV") + " GAV"
	cSql += " JOIN " + RETSQLNAME("GMJ") + " GMJ ON GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ.D_E_L_E_T_ <> '*'  AND (GMJ_CODLOC = GAV_CODLOC AND GMJ_QUARTO = GAV_QUARTO)
	cSql += "		AND GMJ_DATAGE BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "'"                                                                                                                             
	cSql += " WHERE GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' AND GAV_TIPO = '2' "                                                                                             
 cSql += " GROUP BY   GMJ_CODLOC, GMJ_STATUS "
 cSQL :=  ChangeQuery(cSQL)
 TCQUERY cSql NEW ALIAS "TMPSET"
 
 //	PEGA QUANTIDADE DE ATENDIMENTOS POR SALA E ESPECIALIDADE (ESPECIALIDADE E QUANTIDADE)
	cSql := " SELECT COUNT(*) CONT, GMJ_STATUS GMJ_STATUS, GMJ_CODLOC || GMJ_QUARTO SALA, COALESCE(GA7_CODESP, '') ESPEC"
	cSql += " FROM  " + RETSQLNAME("GAV") + " GAV"
	cSql += " JOIN " + RETSQLNAME("GMJ") + " GMJ ON GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ.D_E_L_E_T_ <> '*'  AND (GMJ_CODLOC = GAV_CODLOC AND GMJ_QUARTO = GAV_QUARTO)"
	cSql += "		AND GMJ_DATAGE BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "'"                                                                                                                             
	cSql += " JOIN " + RETSQLNAME("GCS") + " GCS ON GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS_CODLOC = GAV_CODLOC  "                                                                        
	cSql += /*" LEFT JOIN "*/ " JOIN " + RETSQLNAME("GA7") + " GA7 ON GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7_CODPRO = GMJ_CODPRO"                                                                     
	cSql += " WHERE GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*'  AND GAV_TIPO = '2' "                                                                                             
	cSql += " GROUP BY   GMJ_CODLOC || GMJ_QUARTO, GCS_NOMLOC, GA7_CODESP, GMJ_STATUS"
 cSQL :=  ChangeQuery(cSQL)
 TCQUERY cSql NEW ALIAS "TMPESP"

 // PEGA QUANTIDADE DE ATENDIMENTOS POR SALA (SALA E QUANTIDADE)
	cSql := " SELECT COUNT(*) CONT, GMJ_STATUS GMJ_STATUS, GMJ_CODLOC || GMJ_QUARTO SALA"
 cSql += " FROM " + RETSQLNAME("GAV") + " GAV"
	cSql += " JOIN " + RETSQLNAME("GMJ") + " GMJ ON GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ.D_E_L_E_T_ <> '*'  "+" AND (GMJ_CODLOC = GAV_CODLOC AND GMJ_QUARTO = GAV_QUARTO)"
	cSql += "		AND GMJ_DATAGE BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "'"                                                                                                                             
	cSql += " WHERE GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' AND GAV_TIPO = '2' "                                                                                             
 cSql += " GROUP BY   GMJ_CODLOC || GMJ_QUARTO, GMJ_STATUS"
 cSQL :=  ChangeQuery(cSQL)
 TCQUERY cSql NEW ALIAS "TMPSAL"

 // PEGA LISTA COMPLETA EM ORDEM POR SALA, ESPECIALIDADE E MษDICO (MษDICO E QUANTIDADE)
	cSql  := "SELECT COUNT(*) CONT, GMJ.GMJ_CODLOC CODLOC, GCS.GCS_NOMLOC SETOR, GMJ.GMJ_QUARTO SALA, GA7.GA7_CODESP CODESP, "+IIF(MV_PAR05 != 2,"GFR.GFR_DSESPE NOMESP,","")+" GMJ.GMJ_CODCRM CODCRM, SRA.RA_NOME MEDICO, "
 cSql  += " (SELECT COUNT(*) FROM " + RETSQLNAME("GMJ") + " GMJ1 WHERE GMJ1.GMJ_CODLOC = GMJ.GMJ_CODLOC AND GMJ1.GMJ_QUARTO = GMJ.GMJ_QUARTO AND GMJ1.GMJ_DATAGE BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' AND GMJ1.GMJ_STATUS <> '2' AND GMJ1.GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ1.D_E_L_E_T_ <> '*') TOTGERAL, "
 cSql  += " (SELECT COUNT(*) FROM " + RETSQLNAME("GMJ") + " GMJ2 WHERE GMJ2.GMJ_CODLOC = GMJ.GMJ_CODLOC AND GMJ2.GMJ_QUARTO = GMJ.GMJ_QUARTO AND (GMJ2.GMJ_STATUS = '1' OR GMJ2.GMJ_STATUS = '3') 	AND GMJ2.GMJ_DATAGE BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' AND GMJ2.GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ2.D_E_L_E_T_ <> '*') TOTSALA "
 cSql  += " FROM " + RETSQLNAME("GMJ") + " GMJ "
 cSql  += " JOIN " + RETSQLNAME("GAV") + " GAV ON GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' AND GAV.GAV_TIPO = '2' "
 cSql  += " JOIN " + RETSQLNAME("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GAV.GAV_CODLOC  "
 cSql  += " JOIN " + RETSQLNAME("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GMJ.GMJ_CODPRO "
 cSql  += " JOIN " + RETSQLNAME("SRA") + " SRA ON SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO = GMJ.GMJ_CODCRM "
	If MV_PAR05 != 2
		cSql += " JOIN " + RETSQLNAME("GFR") + " GFR ON GFR.GFR_FILIAL = '" + xFilial("GFR") + "' AND GFR.D_E_L_E_T_ <> '*' " + IIF(MV_PAR05 != 2," AND GFR.GFR_CDESPE = GA7.GA7_CODESP "," ")
	EndIF
 cSql += " WHERE GMJ.GMJ_FILIAL = '" + xFilial("GMJ") + "' AND GMJ.D_E_L_E_T_ <> '*' AND (GMJ.GMJ_STATUS = '1' OR GMJ.GMJ_STATUS = '3') AND GMJ.GMJ_CODLOC = GAV.GAV_CODLOC AND GMJ.GMJ_QUARTO = GAV.GAV_QUARTO "
 cSql += "		AND GMJ.GMJ_DATAGE BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
 cSql += " GROUP BY GMJ.GMJ_CODLOC, GCS.GCS_NOMLOC, GMJ.GMJ_QUARTO, GA7.GA7_CODESP, "+IIF(MV_PAR05 != 2,"GFR.GFR_DSESPE,","")+" GMJ.GMJ_CODCRM, SRA.RA_NOME "
	cSql += " ORDER BY SALA, " + IIF(MV_PAR05 != 2,"CODESP,","")+" CODCRM"
 cSQL :=  ChangeQuery(cSQL)
 TCQUERY cSql NEW ALIAS "TMPMED"

Return

Static Function FS_Perc(cSetor)
Return( FS_SetorOc(cSetor)/FS_Setor(cSetor)*100)
Static Function FS_Perc2(cSetor)
Return( 100-(FS_SetorOc(cSetor)/FS_Setor(cSetor)*100))
