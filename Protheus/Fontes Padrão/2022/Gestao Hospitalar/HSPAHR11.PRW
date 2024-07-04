#INCLUDE "HSPAHR11.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR11  บ Autor ณ Marcelo/Antonio    บ Data ณ  28/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorios estatisticos                                    บฑฑ 
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs:      ณ Convertido para relatorios personalizaveis                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP7 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSPAHR11()

Local oReport
Private lTmpR4:=.F.

 If FindFunction("TRepInUse") .And. TRepInUse() 
  Private aMesesR    := Array(12),;
          aGeral     := {},;
          aMedico    := {},;
          aParam     := {},;
          aResumo    := {},;
          nMesesRetr := 0,;
          nTotMedia  :=0
  Private cMes1:= "", cMes2:= "", cMes3:= "", cMes4:= "", cMes5:= "", cMes6:= "", cMes7:= "", cMes8:= "", cMes9:= "", cMes10:= "", cMes11:= "", cMes12:= ""
  Private cAno1:= "", cAno2:= "", cAno3:= "", cAno4:= "", cAno5:= "", cAno6:= "", cAno7:= "", cAno8:= "", cAno9:= "", cAno10:= "", cAno11:= "", cAno12:= ""
  Private oTempTRB 
  
  pergunte( "HSPR11",.F. )
  oReport := ReportDef() 
  oReport:PrintDialog()
  
  if( select( "TMPR4" ) > 0 )
  	oTempTRB:Delete()
  endIf
 ELSE  
  HSPAHR11R3()  
 EndIF 
Return( Nil )     


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Marcelo/Antonio       ณ Data ณ 28/09/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2, oSection3
 Local oCell
 Local oTotaliz

 Private cAnoMes := Substr(DtoS(cToD("01/" + Substr(mv_par07, 1, 2) + "/" + Substr(mv_par07, 4, 4))) ,1, 6)
 Private aMesesR[12] := cAnoMes

 fs_meses() // monta o cabecalho dos meses
   
 oReport := TReport():New("HSPAHR11",STR0003,"HSPR11",{|oReport| R11IMP(oReport)}, STR0001 + STR0002) 
 // "Estatistica Agenda Cancelada"###"Este programa tem como objetivo imprimir relatorio"###"de acordo parโmetros informados pelo usuแrio."
  
 oSection1 := TRSection():New(oReport,STR0024,{"TMPR4"})   // "M้dico"

 oSection1:SetHeaderBreak(.T.)   // Indica se cabe็alho da se็ใo serแ impresso em cada quebra (padrใo).
 oSection1:SetPageBreak(.T.)     // Indica quebra de pแgina no final da se็ใo.
 oSection1:SetHeaderPage(.T.)    // Indica que o cabe็alho da se็ใo serแ impresso no topo da pแgina.
 oSection1:SetTotalInLine(.F.)   // Troca impressใo dos totalizadores gerais em linha para coluna.
 oSection1:SetTotalText(STR0023)   //###"R E S U M O"
 oSection1:SetNoFilter({"TMPR4"})
 oCell := TRCell():New(oSection1,"MEDICO","TMPR4",STR0024,,30)                    // "M้dico"
 oCell := TRCell():New(oSection1,"MOTIVO","TMPR4",STR0029,,10)                    // "Motivo"
 oCell := TRCell():New(oSection1,"aCol01","TMPR4",cMes1+"/"+cAno1  ,"999" ,03)
 oCell := TRCell():New(oSection1,"aCol02","TMPR4",cMes2+"/"+cAno2  ,"999" ,03)
 oCell := TRCell():New(oSection1,"aCol03","TMPR4",cMes3+"/"+cAno3  ,"999" ,03)
 oCell := TRCell():New(oSection1,"aCol04","TMPR4",cMes4+"/"+cAno4  ,"999" ,03)
 oCell := TRCell():New(oSection1,"aCol05","TMPR4",cMes5+"/"+cAno5  ,"999" ,03)
 oCell := TRCell():New(oSection1,"aCol06","TMPR4",cMes6+"/"+cAno6  ,"999" ,03)
 oCell := TRCell():New(oSection1,"aCol07","TMPR4",cMes7+"/"+cAno7  ,"999" ,03)
 oCell := TRCell():New(oSection1,"aCol08","TMPR4",cMes8+"/"+cAno8  ,"999" ,03)
 oCell := TRCell():New(oSection1,"aCol09","TMPR4",cMes9+"/"+cAno9  ,"999" ,03)
 oCell := TRCell():New(oSection1,"aCol10","TMPR4",cMes10+"/"+cAno10,"999" ,03)
 oCell := TRCell():New(oSection1,"aCol11","TMPR4",cMes11+"/"+cAno11,"999" ,03)
 oCell := TRCell():New(oSection1,"aCol12","TMPR4",cMes12+"/"+cAno12,"999" ,03)
 oCell := TRCell():New(oSection1,"aCol13","TMPR4",STR0019,"999"  ,03)            // "Total" 
 oCell := TRCell():New(oSection1,"aCol14","TMPR4","( % )" ,"999.99",06)
 oCell := TRCell():New(oSection1,"aCol15","TMPR4",STR0020,"999"  ,03)            //"M้dia" 

 oBreak := TRBreak():New(oSection1,oSection1:Cell("MEDICO"),"",.F.) 
                                                                     
 TRFunction():New(oSection1:Cell("aCol01")	,/* cID */,"SUM",oBreak,/*cTitle*/,"999",/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
 TRFunction():New(oSection1:Cell("aCol02")	,/* cID */,"SUM",oBreak,/*cTitle*/,"999",/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
 TRFunction():New(oSection1:Cell("aCol03")	,/* cID */,"SUM",oBreak,/*cTitle*/,"999",/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
 TRFunction():New(oSection1:Cell("aCol04")	,/* cID */,"SUM",oBreak,/*cTitle*/,"999",/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
 TRFunction():New(oSection1:Cell("aCol05")	,/* cID */,"SUM",oBreak,/*cTitle*/,"999",/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
 TRFunction():New(oSection1:Cell("aCol06")	,/* cID */,"SUM",oBreak,/*cTitle*/,"999",/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
 TRFunction():New(oSection1:Cell("aCol07")	,/* cID */,"SUM",oBreak,/*cTitle*/,"999",/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
 TRFunction():New(oSection1:Cell("aCol08")	,/* cID */,"SUM",oBreak,/*cTitle*/,"999",/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
 TRFunction():New(oSection1:Cell("aCol09")	,/* cID */,"SUM",oBreak,/*cTitle*/,"999",/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
 TRFunction():New(oSection1:Cell("aCol10")	,/* cID */,"SUM",oBreak,/*cTitle*/,"999",/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
 TRFunction():New(oSection1:Cell("aCol11")	,/* cID */,"SUM",oBreak,/*cTitle*/,"999",/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
 TRFunction():New(oSection1:Cell("aCol12")	,/* cID */,"SUM",oBreak,/*cTitle*/,"999",/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
 TRFunction():New(oSection1:Cell("aCol13")	,/* cID */,"SUM",oBreak,/*cTitle*/,"999",/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
 TRFunction():New(oSection1:Cell("aCol15")	,/* cID */,"SUM",oBreak,/*cTitle*/,"999",/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
                                     
 DEFINE COLLECTION OF oSection1 FUNCTION SUM FORMULA oSection1:Cell("MOTIVO") CONTENT oSection1:Cell("aCol13") NO END SECTION
              
Return( oReport )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ R11Imp   ณ Autor ณ Marcelo/Antonio       ณ Data ณ 28/09/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R11IMP(oReport)

 Local oSection1 := oReport:Section(1), aCampos := {}, cCond := "", cCond1 := "", cCond2 := "",; 
       cCond3    := "", nPosPar := 0, cParam := "", cCodMed := "", nMes := 0, nCtaFor := 1, nNovoMed := 0

 For nMes := 11 to 1 Step -1
  aMesesR[nMes] := FS_MesRetr(aMesesR[nMes+1])
 Next nMes

 //-- Transforma parametros Range em expressao SQL
 MakeSqlExpr(oReport:uParam)                      

 If Empty(MV_PAR01) .AND. Empty(MV_PAR02)
  cCond := "% GM8.GM8_CODLOC BETWEEN '" + STR(Len(MV_PAR01)) + "' AND '" + STR(Len(MV_PAR02)) + "' %"
 Else
  cCond := "% GM8.GM8_CODLOC BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' %"
 Endif 
 If Empty(MV_PAR03) .AND. Empty(MV_PAR04) 
  cCond1 := "% GM8.GM8_CODCRM BETWEEN '" + STR(Len(MV_PAR03)) + "' AND '" + STR(Len(MV_PAR04)) + "' %"
 Else
  cCond1 := "% GM8.GM8_CODCRM BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' %"
 EndIf
 If Empty(MV_PAR05) .AND. Empty(MV_PAR06)
  cCond2 := "% GM8.GM8_CODPLA BETWEEN '" + STR(Len(MV_PAR05)) + "' AND '" + STR(Len(MV_PAR06)) + "' %"
 Else
  cCond2 := "% GM8.GM8_CODPLA BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' %"
 Endif

 cCond3 := "% SUBSTRING(GM8.GM8_DATAGE,1,6) BETWEEN '" + aMesesR[1] + "' AND '" + aMesesR[12] + "' %"

 BeginSql alias "QRYR11"
  SELECT SRA.RA_NOME MEDICO, GM7.GM7_DESCAN MOTIVO, SUBSTRING(GM8.GM8_DATAGE, 1, 6) DATAGE, COUNT(*) VALOR
  FROM %table:GM8% GM8
  JOIN %table:SRA% SRA ON SRA.RA_FILIAL  = %xFilial:SRA% AND SRA.%NotDel% AND SRA.RA_CODIGO  = GM8.GM8_CODCRM 
  JOIN %table:GM7% GM7 ON GM7.GM7_FILIAL = %xFilial:GM7% AND GM7.%NotDel% AND GM7.GM7_CODCAN = GM8.GM8_MOTIVO 
  WHERE GM8.GM8_FILIAL = %xFilial:GM8% AND GM8.%NotDel%
  AND %Exp:cCond%
  AND %Exp:cCond1%
  AND %Exp:cCond2%
  AND %Exp:cCond3%
  GROUP BY SRA.RA_NOME, GM7.GM7_DESCAN, SUBSTRING(GM8.GM8_DATAGE, 1, 6)
  ORDER BY MEDICO
 EndSql

 While ("QRYR11")->(!Eof())

  nPosMed  := aScan(aMedico, {|x| x[15] == QRYR11->MEDICO .And. x[16] == QRYR11->MOTIVO } )
  
  If nPosMed <= 0
   aadd(aMedico,{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, QRYR11->MEDICO,QRYR11->MOTIVO} )
   nPosMed := Len(aMedico)
  EndIf
  //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  //ณ Detalhe - acumular por linha (parametro) e no resumo ณ
  //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  nMes := aScan(aMesesR, QRYR11->DATAGE)  
  aMedico[nPosMed, nMes] += QRYR11->VALOR
  aMedico[nPosMed,   13] += QRYR11->VALOR

  DbSkip()
 End 
             
 DbCloseArea()

 // cria os campos da tabela temporaria
 aAdd(aCampos, {"MEDICO", "C",30,0})
 aAdd(aCampos, {"MOTIVO", "C",10,0}) 
 aAdd(aCampos, {"aCol01", "N", 3,0})
 aAdd(aCampos, {"aCol02", "N", 3,0})
 aAdd(aCampos, {"aCol03", "N", 3,0})
 aAdd(aCampos, {"aCol04", "N", 3,0})
 aAdd(aCampos, {"aCol05", "N", 3,0})
 aAdd(aCampos, {"aCol06", "N", 3,0})
 aAdd(aCampos, {"aCol07", "N", 3,0})
 aAdd(aCampos, {"aCol08", "N", 3,0})
 aAdd(aCampos, {"aCol09", "N", 3,0})
 aAdd(aCampos, {"aCol10", "N", 3,0})
 aAdd(aCampos, {"aCol11", "N", 3,0})
 aAdd(aCampos, {"aCol12", "N", 3,0})
 aAdd(aCampos, {"aCol13", "N", 3,0})
 aAdd(aCampos, {"aCol14", "N", 6,2})
 aAdd(aCampos, {"aCol15", "N", 3,0})

//--< Cria็ใo do objeto FWTemporaryTable >---
oTempTRB := FWTemporaryTable():New( "TMPR4" )
oTempTRB:SetFields( aCampos )
oTempTRB:AddIndex( "INDTRB",{ "MEDICO","MOTIVO" } )

if( select( "TMPR4" ) > 0 )
	TMPR4->( dbCloseArea() )
endIf

oTempTRB:Create()

 If Len(aMedico) > 0
   For nCtaFor := 1 to Len(aMedico)
    RecLock("TMPR4", .T.)
    TMPR4->aCol01 := aMedico[nCtaFor,01] 
    TMPR4->aCol02 := aMedico[nCtaFor,02] 
    TMPR4->aCol03 := aMedico[nCtaFor,03] 
    TMPR4->aCol04 := aMedico[nCtaFor,04]
    TMPR4->aCol05 := aMedico[nCtaFor,05]
    TMPR4->aCol06 := aMedico[nCtaFor,06]
    TMPR4->aCol07 := aMedico[nCtaFor,07]
    TMPR4->aCol08 := aMedico[nCtaFor,08]
    TMPR4->aCol09 := aMedico[nCtaFor,09]
    TMPR4->aCol10 := aMedico[nCtaFor,10]
    TMPR4->aCol11 := aMedico[nCtaFor,11]
    TMPR4->aCol12 := aMedico[nCtaFor,12]
    TMPR4->aCol13 := aMedico[nCtaFor,13]
    TMPR4->aCol14 :=(aMedico[nCtaFor,13] / nTotMedia) * 100
    TMPR4->aCol15 := aMedico[nCtaFor,14]
    TMPR4->MEDICO := aMedico[nCtaFor,15] 
    TMPR4->MOTIVO := aMedico[nCtaFor,16] 
    MsUnlock()
   Next
  EndIf 

 DbSelectArea("TMPR4")
 DbGotop()     

 oReport:SetMeter(TMPR4->(LastRec()))
 oSection1:Print() // processa as informacoes da tabela principal

 lTmpR4:=.T.

Return( NIL )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ FS_Meses ณ Autor ณ Antonio / Marcelo Joseณ Data ณ 18/09/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_Meses()

 Local aDescMes := {STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0017,STR0018},;  //" Jan"###" Fev"###" Mar"###" Abr"###" Mai"###" Jun"###" Jul"###" Ago"###" Set"###" Out"###" Nov"###" Dez"
       nMes     := 0 ,;
       cAno     := Substr(cAnoMes, 1, 4),;
       cMesRef  := Substr(cAnoMes, 5, 2),;
       bCabMes  := { |x/*nMes*/| &("cMes"+Alltrim(Str(x,2,0))) := cMes  , Eval(bCabAno, x) },;
       bCabAno  := { |y/*nMes*/| &("cAno"+Alltrim(Str(y,2,0))) := subs(cAno,3,2)}  

 If cMesRef<>"12"
  cAno := Str(Val(cAno)-1, 4)
 EndIf
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Monta array com os meses retroativos ao Ano/Mes informado        ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 For nMes := 11 to 1 Step -1
  aMesesR[nMes] := FS_MesRetr(aMesesR[nMes+1])
 Next nMes

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Montagem do cabecalho do relatorio                               ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 For nMes := 1 to 12
  cMes := Space(02) + aDescMes[Val(Substr(aMesesR[nMes], 5, 2))]
  If cMesRef<>"12"
   If alltrim(cMes) == "Jan"
    cAno := Str(Val(cAno)+1, 4)
   Endif 
  Endif 

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Preenche as variaveis private referentes aos meses do cabecalho. ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 Eval(bCabMes, nMes)
 
 Next nMes
 
return ()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHRPAHR11R3บ Autor ณ Luiz Pereira S. Jr.บ Data ณ  03/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorios estatisticos                                    บฑฑ 
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR11R3()
 Local   cDesc1      := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local   cDesc2      := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local   cDesc3      := STR0003 //"Estatistica Agenda Cancelada"
 Local   aOrd        := {}
 
 Private Cabec1      := ""
 Private Cabec2      := "" 
 Private cTitulo     := STR0003 //"Estatistica Agenda Cancelada"
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 132
 Private Tamanho     := "M"
 Private NomeProg    := "HSPAHR11"
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
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                          ณ
 //ณ MV_PAR01	Do setor                                                   ณ  
 //ณ MV_PAR02	Ate o setor                                                ณ
 //ณ MV_PAR03	Do medico                                                  ณ
 //ณ MV_PAR04	Ate o medico                                               ณ
 //ณ MV_PAR05	Do plano                                                   ณ
 //ณ MV_PAR06	Ate o plano                                                ณ
 //ณ MV_PAR07	Ano/mes referencia                                         ณ
 //ณ MV_PAR08	Numero retroativo de meses para calculo da media           ณ
 //ณ MV_PAR09	Ordem de impressao (1=Col Mes Ref. 2= Total 3 = Media)     ณ  
 //ณ MV_PAR10	Emite grafico (1=Nenhum 2=Mes Referencia 3= Total 4= Media |
 //| MV_PAR11 Impressora                                                 |
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If !Pergunte("HSPR11",.T.)
  Return()
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

 wnrel := SetPrint("GM8", NomeProg, "", @cTitulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif
 SetDefault(aReturn, "GM8")
 If nLastKey == 27
  Return()
 Endif

 nTipo := If(aReturn[4]==1,15,18)
 RptStatus({|| RunReport(STR0006) }, cTitulo) //"Agenda Cancelada"
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Luiz Pereira S. Jr.บ Data ณ  04/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(cSubTitulo)
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

 Private aParam   := {}
 Private aMedico  := {}
 Private aResumo  := {}
 Private aGeral   := {}
 Private aMesesR  := Array(12)
 Private nLin     := nMaxLin + 1
 Private nPosC1   := 15
 Private nPosC2   := 16

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
 Cabec1 := Padr(cSubTitulo, 40)
 Cabec2 := Space(Len(Cabec1))
 For nMes := 1 to 12
  Cabec1 += Space(02) + aDescMes[Val(Substr(aMesesR[nMes], 5, 2))]
  Cabec2 += Space(02) + Substr(aMesesR[nMes], 1, 4)
 Next nMes
 Cabec1 += " " + PADR(STR0019, 6) + " " + PADC("(%)", 6) + " " + PADR(STR0020, 5) //"Total"###"Media"
 Cabec2 += SPACE(15) + PADR("(" + AllTrim(Str(nMesesRetr)) + "M" + ")", 5)

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Selecao dos dados                                                ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 
 cSql:= "SELECT SRA.RA_NOME MEDICO, GM7.GM7_DESCAN MOTIVO, SUBSTRING(GM8.GM8_DATAGE, 1, 6) DATAGE, COUNT(*) VALOR "
 cSql+= "FROM " + RetSqlName("GM8") + " GM8 "
 cSql+= "JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_FILIAL ='" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND  SRA.RA_CODIGO = GM8.GM8_CODCRM "
 cSql+= "JOIN " + RetSqlName("GM7") + " GM7 ON GM7.GM7_FILIAL ='" + xFilial("GM7") + "' AND GM7.D_E_L_E_T_ <> '*' AND  GM7.GM7_CODCAN = GM8.GM8_MOTIVO "
 cSql+= "WHERE GM8.GM8_FILIAL ='" + xFilial("GM8") + "' AND GM8.D_E_L_E_T_ <> '*' "
 If !Empty(cCodLoc_De)
  cSql += "AND GM8.GM8_CODLOC >= '" + cCodLoc_De + "' "
 Endif 
 If !Empty(cCodLoc_Ate)
  cSQL += "AND GM8.GM8_CODLOC <= '" + cCodLoc_Ate + "' "
 Endif
 
 If !Empty(cCodMed_De)
  cSQL += "AND GM8.GM8_CODCRM >= '" + cCodMed_De + "' "
 EndIf
 If !Empty(cCodMed_Ate)
  cSQL += "AND GM8.GM8_CODCRM <= '" + cCodMed_Ate + "' "
 EndIf
  
 If !Empty(cCodPla_De)
  cSQL += "AND GM8.GM8_CODPLA >= '" + cCodPla_De + "' "
 Endif
 If !Empty(cCodPla_Ate)
  cSQL += "AND GM8.GM8_CODPLA <= '" + cCodPla_Ate + "' "
 Endif                       

 cSQL += "AND SUBSTRING(GM8.GM8_DATAGE,1,6) BETWEEN '" + aMesesR[1] + "' AND '" + aMesesR[12] + "' "
 cSQL += "GROUP BY SRA.RA_NOME, GM7.GM7_DESCAN, SUBSTRING(GM8.GM8_DATAGE, 1, 6)"
 
 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")

 DbGoTop()
 If Eof()
  HS_MsgInf(STR0021,STR0027,STR0028) //"Nenhum dado foi encontrado para a selecao efetuada." //"Aten็ใo"###"Relatorios estatisticos"
  DbCloseArea()
  Return()
 Endif
  
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Emissao do relatorio                                             ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cTitGrf := AllTrim(cTitulo)
 cTitulo := AllTrim(cTitulo) //+ " - " + IIF(nTipRel == 1, STR0028, STR0029)  //"Analitico"###"Sintetico"
 cTitulo += " (" +  IIF(nOrdem==1, STR0022, ; //"Mes Referencia"
                    IIF(nOrdem==2, STR0019,STR0020)) + ")" //"Total"###"Media"
 aGeral  := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, STR0023, STR0019} //"R E S U M O"###"Total" //"R E S U M O"###"Total"

 SetRegua(1000)         
  
 While !Eof()                                                                                
  IncRegua()
  
  If QRY->MEDICO <> cCodMed
   If !Empty(cCodMed)
    FS_Total(cTitulo, aParam, aMedico)
   Endif 
   aParam := {}
   
   cCodMed := QRY->MEDICO
   aMedico := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, STR0024 + QRY->MEDICO, STR0025} //"Medico:"###"Total do Medico"
   cParam  := ""   
  Endif

  If cParam <> QRY->MOTIVO
   cParam   := QRY->MOTIVO
   If (nPosPar := aScan(aParam, {|x| x[15] == cParam})) == 0
    aAdd(aParam, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, QRY->MOTIVO, QRY->MOTIVO})
    nPosPar  := len(aParam)
   Endif
   If (nPosRes := aScan(aResumo, {|x| x[15] == cParam})) == 0
    aAdd(aResumo, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, QRY->MOTIVO, QRY->MOTIVO})
    nPosRes  := len(aResumo)
   Endif
  Endif

  //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  //ณ Detalhe - acumular por linha (parametro) e no resumo ณ
  //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  nMes := aScan(aMesesR, QRY->DATAGE)  

  aParam[nPosPar, nMes] += QRY->VALOR
  aParam[nPosPar, 13]   += QRY->VALOR
  aMedico[nMes]         += QRY->VALOR
  aMedico[13]           += QRY->VALOR
  
  aResumo[nPosRes, nMes]+= QRY->VALOR
  aResumo[nPosRes, 13]  += QRY->VALOR
  aGeral[nMes]          += QRY->VALOR
  aGeral[13]            += QRY->VALOR

  DbSkip()
 End
 FS_Total(cTitulo, aParam, aMedico)

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Impressao do resumo                                  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 FS_Total(cTitulo, aResumo, aGeral) 
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Emissao do grafico (1=Nenhum 2=Mes Referencia 3= Total 4= Media  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If nGrafico > 1
  For nPar := 1 To Len(aResumo)
   If nGrafico == 2
    nValGra := aResumo[nPar, 12] //Ultimo mes
    cTitGra := STR0022 //"Mes Referencia"
   ElseIf nGrafico == 3
    nValGra := aResumo[nPar, 13]
    cTitGra := STR0019 //"Total"
   Else
    nValGra := aResumo[nPar, 14]
    cTitGra := STR0020 //"Media"
   Endif
   aAdd(aGrafico, {nValGra, Padr(aResumo[nPar, 16], 40)})
  Next
  oGraf := HsGRAF():NEW(cTitGrf, cTitGrf, "", STR0026 + " (" + cTitGra + ")", cSubTitulo, "", aGrafico, 1, 1, 0, 0, 2, 17, 6, 6, 25, 20) //"Quantidade"
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Luiz Pereira S. Jr บ Data ณ  03/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_Cabec(cTitulo)
 Cabec(cTitulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.)
 nLin := 8
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Total  บ Autor ณ Luiz Pereira S. Jr.บ Data ณ  03/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao das linhas totalizadoras                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
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

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Classificacao dos dados conforme opcao do usuario nas perguntas (1=Col Mes Ref. 2= Total 3 = Media)						ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_ImpTot บ Autor ณ Luiz Pereira S. Jr.บ Data ณ  03/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao do total                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_MesRetrบ Autor ณ Luiz Pereira S. Jr.บ Data ณ  03/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Subtrai nMeses de uma data no formato AAAAMM               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Media  บ Autor ณ Luiz Pereira S. Jr.บ Data ณ  03/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Calcula a media dos ultimos n meses (meses retroativos)    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_Media(aQtd)
 Local nMedia  := 0
 Local nMes    := 0

 For nMes := 12 to (12-nMesesRetr+1) Step -1
  nMedia += aQtd[nMes]
 Next nMes
 nMedia := Int((nMedia / nMesesRetr))

Return(nMedia)