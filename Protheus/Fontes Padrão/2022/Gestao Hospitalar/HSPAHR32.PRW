#INCLUDE "hspahr32.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR32  บ Autor ณ Adriano Orlovski   บ Data ณ  01/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao |Relatorio Estatistico de Atendimentos por Horario"##" -Setorบฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR32()
 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3 := STR0003 //"Atendimentos por Horario"##" - Setor"
 Local cPict  := ""
 Local titulo := STR0003 + STR0008  //"Atendimentos por Horario"##" - Setor :  
 Local nLin   := 80

/*        
          1         2         3         4         5         6         7         8         9        10        11        12        13
012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
 																	Horas:
    Data            01  02  03  04  05  06  07  08  09  10  11  12  13  14  15  16  17  18  19  20  21  22  23  00  Total  Percen
  99/99/99          99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  9.999  999,99
************************************************************************************************************************************
    TOTAL          999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 99.999  999,99
*/
 Local Cabec1        := STR0004 //"              Horas:"
 Local Cabec2        := STR0005 //"    Data        00  02  03  04  05  06  07  08  09  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  Total  Percen"
 Local imprime   	   := .T.
 Local aOrd       	  := {} 
 Private cTitulo     := STR0003 //"Atendimentos por Horario - Setor"
 Private lEnd      	 := .F.
 Private lAbortPrint	:= .F.
 Private limite     	:= 80
 Private tamanho    	:= "M"
 Private nomeprog   	:= "HSPAHR32" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo      	:= 18
 Private aReturn    	:= { STR0006, 1, STR0007, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey   	:= 0
 Private cPerg      	:= "HSPR32"
 Private cbcont     	:= 00
 Private CONTFL     	:= 01
 Private m_pag      	:= 01
 Private wnrel      	:= "HSPAHR32" // Coloque aqui o nome do arquivo usado para impressao em disco
 Private cString    	:= "GCY"
 Private nMaxLin    	:= 0        
 Private lVerif     	:= .F.       // Usado para entrar no R3 ou no R4
 Private aTotGeral   := {}
 Private cCodLoc_De  := ""
 Private cCodLoc_Ate := ""
 Private dData_De    := ""
 Private dData_Ate   := ""
	Private cCodImp     := ""


 
 If FindFunction("TRepInUse") .And. TRepInUse() 
  lVerif := .T.
 EndIf
 
	If !Pergunte("HSPR32",.T.)
		Return()
	EndIf
 
/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPARAMETROS             ณ
//ณ                       ณ
//ณMV_PAR01 do Setor      ณ
//ณMV_PAR02 ate o Setor   ณ
//ณMV_PAR03 da Data       ณ
//ณMV_PAR04 ate a Data    ณ
//ณMV_PAR05 Impressora    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC*/
 
 cCodLoc_De  := MV_PAR01
 cCodLoc_Ate := MV_PAR02
 dData_De    := MV_PAR03
 dData_Ate   := MV_PAR04
	cCodImp     := MV_PAR05
 nMaxLin     := HS_MaxLin(cCodImp)
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
                      
 If lVerif
  oReport := ReportDef() 
  oReport:PrintDialog() 
 Else
  wnrel := SetPrint("GCY", NomeProg, "", @cTitulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
  
  If nLastKey == 27
   Return()
  Endif
  SetDefault(aReturn, "GCY")
  If nLastKey == 27
   Return()
  Endif

  aReturn[4] := 2
  nTipo := If(aReturn[4]==1,15,18)
  
  RptStatus({|| RunReport(Cabec1,Cabec2,nLin) },Titulo)
 EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Return(Nil)                           

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Heimdal B. Castro     ณ Data ณ 04/09/07 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2, oSection3, oSection4, oSection5
 Local oCell
 Local oTotaliz1, oTotaliz2
 Local oBreak
 Local nHora    := 0 
 Local aDescHor := {"00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23"} 

 oReport := TReport():New("HSPAHR32",STR0003,"HSPR32",{|oReport| R32IMP(oReport)}, STR0001 + STR0002)
 //###"Atendimento Diแrio Por Horแrio "### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."

 oReport:SetTotalInLine(.F.)
 
 oSection1:= TRSection():New(oReport, "CODLOC", "QRYSQL")
 oSection1:SetHeaderPage(.F.)
 oSection1:SetHeaderBreak(.F.)
 oSection1:SetPageBreak(.T.)
 oSection1:SetHeaderSection(.T.)
 oSection1:SetTotalInLine(.F.)
 oSection1:SetTotalText("TOTAL DO SETOR")  
 
 oCell := TRCell():New(oSection1,"cLocal","QRYSQL","",, 50,,{|| cLocal := "Setor:" + ("QRYSQL")->CODLOC + "  " + HS_INIPADR("GCS", 1, ("QRYSQL")->CODLOC, "GCS_NOMLOC")})                                                   
  
 oSection2:= TRSection():New(oSection1, "DATATE", "QRYSQL")
 oSection2:SetHeaderPage(.F.)
 oSection2:SetHeaderBreak(.F.)  
 oSection2:SetTotalInLine(.F.)
 oSection2:SetHeaderSection(.F.)    
  
 oCell := TRCell():New(oSection2,"cData","QRYSQL","",, 10,,{|| cData := DToC(SToD(("QRYSQL")->DATATE))})
 oSection2:SetTotalText("TOTAL DO SETOR")  

 For nHora := 1 to 24
  oCell := TRCell():New(oSection2,"HOR" + aDescHor[nHora],"QRYSQL","",, 6)     
 Next nHora                                    
 
 oCell := TRCell():New(oSection2,"TOTA","QRYSQL","",, 6)
 oCell := TRCell():New(oSection2,"nPorc","QRYSQL","","@E 999.99", 6,,{|| nPorc := (("QRYSQL")->TOTA/aTotGeral[aScan(aTotGeral, {|aVet| aVet[1] == ("QRYSQL")->CODLOC }), 2])*100})                                               
 
 oSection3:= TRSection():New(oSection2, "QRYSQL")
 oSection3:SetHeaderPage(.T.)
 oSection3:SetHeaderBreak(.F.)  
 oSection3:SetTotalInLine(.F.)         
 
 oCell := TRCell():New(oSection3, SUBSTR(STR0005,4,6)+"/"+ SUBSTR(STR0004,14,6),,,,14)
 

 For nHora := 1 to 24
  oCell := TRCell():New(oSection3, aDescHor[nHora],,,,6)          // 03-Hora
 Next nHora                        
 
 oCell := TRCell():New(oSection3, "Total",,,,6)                   // 05-Total
 oCell := TRCell():New(oSection3, " (%) ",,,,6)                   // 06-Porcentagem
  
 For nHora := 1 to 24
 	DEFINE FUNCTION FROM oSection2:Cell("HOR" + aDescHor[nHora]) OF oSection1 FUNCTION SUM TITLE "Total do Setor"   NO END REPORT 
 Next nHora           
 
 DEFINE FUNCTION FROM oSection2:Cell("TOTA") OF oSection1 FUNCTION SUM TITLE "Total do Setor"   NO END REPORT 
 DEFINE FUNCTION FROM oSection2:Cell("nPorc") OF oSection1 FUNCTION SUM TITLE "Total do Setor"   NO END REPORT 
 
Return( oReport )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ R32Imp   ณ Autor ณ Heimdall B. Castro    ณ Data ณ 21/09/07 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function R32IMP(oReport)
 
 Local oSection1 := oReport:Section(1)
 Local oSection2 := oReport:Section(1):Section(1)
 Local oSection3 := oReport:Section(1):Section(1):Section(1)
 Local nPos      := 1
 //-- Transforma parametros Range em expressao SQL  
 
 MakeSqlExpr(oReport:uParam)                      
 
 oSection1:BeginQuery()        
 
 cCond1 := "% CODLOC, DATATE, SUM(QUANT) TOTA, SUM(HOR00) HOR00, SUM(HOR01) HOR01, SUM(HOR02) HOR02, SUM(HOR03) HOR03, "
 cCond1 += " SUM(HOR04) HOR04, SUM(HOR05) HOR05, SUM(HOR06) HOR06, SUM(HOR07) HOR07, " 
 cCond1 += " SUM(HOR08) HOR08, SUM(HOR09) HOR09, SUM(HOR10) HOR10, SUM(HOR11) HOR11, " 
 cCond1 += " SUM(HOR12) HOR12, SUM(HOR13) HOR13, SUM(HOR14) HOR14, SUM(HOR15) HOR15, " 
 cCond1 += " SUM(HOR16) HOR16, SUM(HOR17) HOR17, SUM(HOR18) HOR18, SUM(HOR19) HOR19, " 
 cCond1 += " SUM(HOR20) HOR20, SUM(HOR21) HOR21, SUM(HOR22) HOR22, SUM(HOR23) HOR23  %"

 cCond2 := "% (SELECT GCY_CODLOC  CODLOC, GCY_DATATE  DATATE, "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) HORATE, COUNT( GCY_CODLOC) QUANT, " //retirado distinct
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '00' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR00, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '01' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR01, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '02' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR02, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '03' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR03, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '04' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR04, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '05' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR05, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '06' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR06, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '07' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR07, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '08' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR08, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '09' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR09, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '10' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR10, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '11' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR11, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '12' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR12, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '13' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR13, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '14' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR14, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '15' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR15, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '16' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR16, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '17' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR17, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '18' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR18, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '19' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR19, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '20' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR20, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '21' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR21, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '22' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR22, "
 cCond2 += " CASE "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) WHEN '23' THEN COUNT(DISTINCT GCY.GCY_REGATE) ELSE 0 END HOR23  "
 cCond2 += "FROM " + RetSqlName("GCY") + " GCY %"

 cCond3 := "%GCY.GCY_CODLOC BETWEEN '" + AllTrim(cCodLoc_De) + "' AND '" + AllTrim(cCodLoc_Ate) + "' AND GCY.GCY_LOGCAN = ' ' AND "
 cCond3 += " GCY.GCY_DATATE BETWEEN '" + DTOS(dData_De) + "' AND '" + DTOS(dData_Ate) + "'
 cCond3 += " AND GCY.GCY_FILIAL = '" + xFilial("GCY") +"' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_TPALTA <> '99' %"  
   
 cCond4 := "% GCY.GCY_CODLOC, GCY.GCY_DATATE, GCY.GCY_HORATE )  DUAL %"
  
 cCond5 := "% CODLOC, DATATE %"
   
 cCond6 := "% CODLOC %"
 
	BeginSql alias "QRYSQL"
 	SELECT   %Exp:cCond1%
 	FROM     %Exp:cCond2%
 	WHERE    %Exp:cCond3% 
 	GROUP BY %Exp:cCond4%
 	GROUP BY %Exp:cCond5%
 	ORDER BY %Exp:cCond6%
	EndSql         
 
	oSection1:EndQuery()      
	
	DbSelectArea("QRYSQL")
	DbGoTop()

 While !EOF()        
 	AAdd(aTotGeral, {QRYSQL->CODLOC, 0})
  	While QRYSQL->CODLOC ==  aTotGeral[nPos, 1]
   	aTotGeral[nPos, 2] += QRYSQL->TOTA
   	DbSkip()                             
  	EndDo
  nPos++
 EndDo
	
 DbGoTop()     
	
 oSection2:SetParentQuery()
	oSection2:SetParentFilter( {|G| ("QRYSQL")->CODLOC  == G }, {|| ("QRYSQL")->CODLOC } )     // Quebra por local de atendimento
	
 oSection1:Print() 
 oReport:SetMeter(QRYSQL->(LastRec())) 

Return( NIL ) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  07/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,nLin)
 Local cTitulo := "" 
 Local cCodLoc := ""
 Local cDatAte := ""
 Local aDados := {}, aTotal := {}
 Private nLinTot := 0
 
 dbSelectArea("GCS")
 dbSetOrder(1)

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Gera arquivo de Trabalho      ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
                            
 cSQL := "SELECT GCY_CODLOC  CODLOC, GCY_DATATE  DATATE, "+IIF(TcGetDb() == 'MSSQL', 'SUBSTRING','SUBSTR')+"(GCY_HORATE,1, 2) HORATE, COUNT(*) QUANT "
 cSQL += "FROM " + RetSqlName("GCY") + " GCY "
 cSQL += "WHERE GCY.GCY_CODLOC BETWEEN '" + AllTrim(cCodLoc_De) + "' AND '" + AllTrim(cCodLoc_Ate) + "' AND GCY.GCY_LOGCAN = ' ' AND "
 cSQL += "GCY_DATATE BETWEEN '" + DTOS(dData_De) + "' AND '" + DTOS(dData_Ate) +"' AND "
 cSQL += "GCY.GCY_FILIAL = '" + xFilial("GCY") +"' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_TPALTA <> '99' " 
 cSQL += ExecFilt()
 cSQL += "GROUP BY GCY.GCY_CODLOC, GCY.GCY_DATATE, GCY.GCY_HORATE "
 cSQL += "ORDER BY GCY.GCY_CODLOC, GCY.GCY_DATATE, GCY.GCY_HORATE  "
 cSQL := ChangeQuery(cSQL)

 TcQuery cSQL New Alias "QRY"   

 DbSelectArea("QRY")
 DbGoTop()
 
 If Eof()
  HS_MsgInf("Nใo hแ ํtens para impressใo", "Aten็ใo", "Sele็ใo de Registros")
  DbCloseArea()
		Return(Nil)
 EndIf

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 SetRegua(1000)
 nLinTot := 0
 aTotal  := {}
 aDados  := {}
 cCodLoc := ""
 
 While QRY->(!Eof())
  
	 IncRegua()
	 
	 If cCodLoc <> QRY->CODLOC	
 	 cCodLoc := QRY->CODLOC	
 	 AADD(aTotal,{STR0009, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100 }) //"TOTAL"
 	EndIf 
 	
 	If cDatAte <> QRY->DATATE
 	 cDatAte := QRY->DATATE
 	 aAdd(aDados, {DToC(SToD(cDatAte)), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, cCodLoc})
 	EndIf 
	 
	 aDados[len(aDados), Val(QRY->HORATE)+2] += QRY->QUANT
	 aDados[len(aDados), 26] += QRY->QUANT
	 aTotal[len(aTotal), Val(QRY->HORATE)+2] += QRY->QUANT
	 aTotal[len(aTotal), 26] += QRY->QUANT
 	
 	nLinTot++
 	DbSelectArea("QRY")
  DbSkip()
 End
 FS_CalcPerc(aDados, aTotal)
 FS_Imprime(aDados, aTotal, Cabec1, Cabec2, cTitulo)
 QRY->(DbCloseArea())
Return()

	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CalcPercบAutor  ณAdriano Orlovski    บ Data ณ  09/03/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para calcular o percentual que cada horario representaบฑฑ
ฑฑบ          ณno atendimento diario da locacao                             บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CalcPerc(aDados, aTotal)
 Local nLin    := 0
 Local nTotPer := 0
 Local cSql    := ""
 Local nPos    := 0
 Local nCntSet := 0
 
 cSql := "SELECT GCY_CODLOC  CODLOC, COUNT(*) "
 cSQL += "FROM " + RetSqlName("GCY") + " GCY "
 cSQL += "WHERE GCY.GCY_CODLOC BETWEEN '" + AllTrim(cCodLoc_De) + "' AND '" + AllTrim(cCodLoc_Ate) + "' AND GCY.GCY_LOGCAN = ' ' AND "
 cSQL += "GCY_DATATE BETWEEN '" + DTOS(dData_De) + "' AND '" + DTOS(dData_Ate) +"' AND "
 cSQL += "GCY.GCY_FILIAL = '" + xFilial("GCY") +"' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_TPALTA <> '99' "
 cSql += "GROUP BY GCY.GCY_CODLOC "
 cSql += "ORDER BY GCY.GCY_CODLOC "

 cSql := ChangeQuery(cSql)
 
 TcQuery cSql New Alias "TMPPER"

 DbSelectArea("TMPPER")
 DbGotop()

 While !Eof()
  nCntSet++
  nPos := aScan(aDados, {|x| x[28] == TMPPER->CODLOC })
  	While nPos > 0 .And. nPos <= Len(aDados) .And. aDados[nPos, 28] == TMPPER->CODLOC
   	aDados[nPos, 27] := Round((aDados[nPos, 26] / aTotal[nCntSet,26]) * 100, 2)
   	nPos++
  	End
  DbSkip()
 End
 
 DbSelectArea("TMPPER")
 DbCloseArea()
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ImprimeบAutor  ณAdriano Orlovski    บ Data ณ  09/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para impressao do relatorio                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*        
          1         2         3         4         5         6         7         8         9        10        11        12        13
012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
 																	Horas:
     Data           00  01  02  03  04  05  06  07  08  09  10  11  12  13  14  15  16  17  18  19  20  21  22  23  Total  Percen
  99/99/9999*       99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  99  9.999  999,99
************************************************************************************************************************************
     TOTAL         999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 999 99.999  999,99
* A data pode ser impressa com o ano em 2 ou 4 dํgitos, dependendo da parametriza็ใo dos relatorios.
*/

Static Function FS_Imprime(aDados, aTotal, Cabec1, Cabec2, cTitulo)
 Local 		nLin    := 0
 Local 		nCol    := 0
 Local   cCodLoc := ""
 Private nLinImp := 0
 Private nColImp := 0
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica o cancelamento pelo usuario...                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
 nLinTot := 0
	If lAbortPrint
 	@nLin,00 PSAY STR0010 //"*** CANCELADO PELO OPERADOR ***"
  Return()
	EndIf
 
 DbSelectArea("GCS")
 cTitulo  := STR0008 + aDados[1, 28] + " " + HS_INIPADR("GCS", 1, aDados[1, 28], "GCS_NOMLOC") //" - Setor: "
 FS_Cabec(cTitulo, Cabec1, Cabec2)// imprime o cabe็alho do relat๓rio
 For nLin := 1 to Len(aDados)
 	If !(aDados[nLin, 28] = cCodLoc) .And. !Empty(cCodLoc)
 	 cCodLoc := aDados[nLin,28]
   cTitulo := STR0008 + cCodLoc + " " + HS_INIPADR("GCS", 1, cCodLoc, "GCS_NOMLOC") //" - Setor: "
   nLinImp += 2
   nLinTot++
   FS_ImpTotais(aTotal)
 	 FS_Cabec(cTitulo, Cabec1, Cabec2)// imprime o cabe็alho do relat๓rio
 	EndIf 
 	cCodLoc := aDados[nLin,28]
 	@nLinImp, 000 Psay " "
 	nLinImp++
 	Iif (nLinImp > nMaxLin, FS_Cabec(cTitulo, Cabec1, Cabec2),)// formulario com XX linhas --> verifica se nใo estourou o tamanho do formulario, se estourou salta pแgina
 	nColImp := 2
 	For nCol := 1 to 27 
 		If nCol == 1
 		 @nLinImp, nColImp Psay aDados[nLin,nCol]
 		 nColImp := 12
 		ElseIf nCol == 26
 			nColImp := 112
 			@nLinImp, nColImp Psay Transform(aDados[nLin,nCol], "@E 9,999")
 		ElseIf nCol == 27
 		 nColImp := 119
 		 @nLinImp, nColImp Psay Transform(aDados[nLin,nCol], "@E 999.99")
 		Else
 			nColImp += 4
 			@nLinImp, nColImp Psay Transform(aDados[nLin,nCol], "@E 99")
 		EndIf	   
 	Next
 Next
 nLinImp += 2
 Iif (nLinImp > nMaxLin, FS_Cabec(cTitulo, Cabec1, Cabec2),)// formulario com XX linhas --> verifica se nใo estourou o tamanho do formulario, se estourou salta pแgina	
 nLinTot++
 FS_ImpTotais(aTotal)			

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
  	OurSpool(wnrel)
	Endif

	MS_FLUSH()
	
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Adriano Orlovski   บ Data ณ  03/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_Cabec(cTitulo, Cabec1, Cabec2)
 Cabec(cTitulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.F.)
 nLinImp := 8
 nColImp := 2
Return()
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_ImpTotaisบ Autor ณ Adriano Orlovski   บ Data ณ  03/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressใo dos Totais por Setor                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function FS_ImpTotais(aTotal) 
 Local nCol    := 0
 nColImp       := 5

 For nCol := 1 to 27
  If nCol == 1
 	 @nLinImp, nColImp Psay aTotal[nLinTot,nCol]
 	 nColImp := 11
 	ElseIf nCol == 26
 		nColImp := 111
 		@nLinImp, nColImp Psay Transform(aTotal[nLinTot,nCol], "@E 99,999")
 	ElseIf nCol == 27
 	 nColImp := 119
 	 @nLinImp, nColImp Psay Transform(aTotal[nLinTot,nCol], "@E 999.99")
 	Else
 		nColImp += 4
 		@nLinImp, nColImp Psay Transform(aTotal[nLinTot,nCol], "@E 999")
 	EndIf   
 Next
Return()
