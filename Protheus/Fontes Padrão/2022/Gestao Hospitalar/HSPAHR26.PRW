#INCLUDE "HSPAHR26.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "Report.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR26 บ       ณAntonio Carlos/Marcelo บDataณ 07/08/2006 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Relacao DE PACIENTES ADMITIDOS NO PERIODO                  บฑฑ
ฑฑบ          ณ Conversใo para relatorios personalizaveis                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function HSPAHR26()

 Local oReport

 Private nMvpar7  := 1
 Private lImpTotD := .T.

 If FindFunction("TRepInUse") .And. TRepInUse()
  pergunte("HSPR26",.T.)
  nMvpar7  := MV_PAR07  
  lImpTotD := MV_PAR08 == 1
 	oReport := ReportDef()
 	oReport:PrintDialog()
 ELSE          
 	HSPAHR26R3()
 EndIF

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos/Marceloณ Data ณ 07/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local oReport
 Local oSection1, oSection2
 Local oCell
 Local oTotaliz0,oTotaliz1,oTotaliz2,oTotaliz3,oTotaliz4,oTotaliz5

 oReport := TReport():New("HSPAHR26",STR0003,"HSPR26",{|oReport| R26IMP(oReport)},STR0001 + " " + STR0002)   //"Pacientes admitidos no periodo"### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."
 /*oReport:SetLandscape()           // Imprimir relatorio em formato paisagem
   A op็ใo de imprimir paisagem nใo estava funcionando corretamente 
   entใo foi alterado para retrato pois assim ele estแ correto. */
 oReport:SetPortrait() 
 
 oReport:ParamReadOnly()//Desabilitando Botใo de parโmetros do Relat๓rio.
 
 oSection0 := TRSection():New(oReport,IIF(nMvpar7 == 1, STR0052, STR0044),{"QRYR26"})      //"Data"###"Convenio"
 oSection0:SetHeaderPage(.F.)
 oSection0:SetNoFilter({"QRYR26"})     
  
 oCell := TRCell():New(oSection0,"cQuebra","QRYR26", IIF(nMvpar7 == 1, STR0053, STR0044),,,, {|| IIF(nMvpar7 == 1, ("QRYR26")->GCY_DATATE, ("QRYR26")->GCZ_CODCON + "-" + HS_INIPADR("GA9", 1, ("QRYR26")->GCZ_CODCON, "GA9_NOME",,.F.))} )  //"Dat. Atend."###"Convenio"

 oSection1 := TRSection():New(oSection0,STR0032,{"QRYR26","GF4","GCS","SRA", "GCY", "GCW"})     //"Prontuแrio" 
 
 oSection1:SetHeaderPage(.T.)
 oSection1:SetNoFilter({"QRYR26"})

 oCell := TRCell():New(oSection1,"GCY_REGGER","QRYR26",STR0032)    //"Prontuแrio"
 oCell := TRCell():New(oSection1,"GCY_NOME"   ,"QRYR26",,, 40)
 oCell := TRCell():New(oSection1,"GCY_HORATE","QRYR26",STR0035)    //"Hora"
 oCell := TRCell():New(oSection1,"GCY_DATALT","QRYR26",STR0036)    //"Data Alta"
 oCell := TRCell():New(oSection1,"GCY_HORALT","QRYR26",STR0035)    //"Hora"
 oCell := TRCell():New(oSection1,"GF4_DSTPAL"," "     ,STR0038,,30) //"Tipo de Alta"
 oCell := TRCell():New(oSection1,"nHora"     ,"QRYR26",STR0039,,,,{||nHora:=IIf(	SubtHoras(("QRYR26")->GCY_DATATE,("QRYR26")->GCY_HORATE, ("QRYR26")->GCY_DATALT, ("QRYR26")->GCY_HORALT) >= 0,;   //"Perman๋ncia"
                                                                           					Str((SubtHoras(("QRYR26")->GCY_DATATE,("QRYR26")->GCY_HORATE, ("QRYR26")->GCY_DATALT, ("QRYR26")->GCY_HORALT)/24),4,0)+ STR0015,	"   0" + STR0015)}) //" dia(s)" //" dia(s)"
 oCell := TRCell():New(oSection1,"RA_NOME"   ," "     ,STR0040,,30) //"M้dico"
 oCell := TRCell():New(oSection1,"GCS_NOMLOC"," "     ,STR0041,,30) //"Setor"
 
 oSection2 := TRSection():New(oSection1,STR0042,{"QRYR26","GA9","GCM","GAS"}) //"Cod Conv๋nio"
 oSection2:SetHeaderPage(.T.)
 oSection2:SetNoFilter({"QRYR26"})
 oSection2:SetTotalInLine(.F.)               
 If MV_PAR07 == 1 //Data + Conv.
  oCell := TRCell():New(oSection2,"GCZ_CODCON","QRYR26",STR0043)   //"C๓d -"    
  oCell := TRCell():New(oSection2,"GA9_NOME" ," "   ,STR0044,,TamSX3("GA9_NOME")[1]) //"Conv๊nio"
 EndIf
 oCell := TRCell():New(oSection2,"GCM_DESPLA"," "   ,STR0045,,TamSX3("GCM_DESPLA")[1]) //"Plano"
 oCell := TRCell():New(oSection2,"GCY_CIDALT","QRYR26",STR0046)   //"CID Alta"
 oCell := TRCell():New(oSection2,"GCW_DESCLI","QRYR26",STR0048,,TamSX3("GCW_DESCLI")[1])  //"Clํnica"
 oCell := TRCell():New(oSection2,"GCY_DATFEC","QRYR26",STR0049)  

 oSection2:SetParentRecno()
 If lImpTotD
  oTotaliz3:= TRFunction():new(oSection1:Cell("GCY_REGGER"),,"COUNT",,IIF(nMvpar7 == 1, STR0011, STR0054),,,.T.,.F.,.F.,oSection0)   //"Total Do Dia" //"Total do Conv๊nio"
 EndIf

 oTotaliz1 := TRFunction():new(oSection2:Cell("GCY_DATFEC"),,"COUNT",,STR0016,,,.F.,.T.,.F.)  //"Total de Atendimentos no Perํodo
 oTotaliz2 := TRFunction():new(oSection2:Cell("GCY_DATFEC"),,"COUNT",,STR0017,,,.F.,.T.,.F.)  //"Total de Saํdas no Perํodo
 oTotaliz2:SetCondition({ ||!EMPTY(("QRYR26")->GCY_DATALT)})

 oTotaliz4 := TRFunction():new(oSection2:Cell("GCY_DATFEC"),,"COUNT",,STR0020,,,.F.,.T.,.F.)  //"Total de Contas c/Alta em Aberto"
 oTotaliz4:SetCondition({ ||(!EMPTY(("QRYR26")->GCY_DATALT)) .And. (EMPTY(("QRYR26")->GCY_DATFEC))})

 oTotaliz5 := TRFunction():new(oSection2:Cell("GCY_DATFEC"),,"COUNT",,STR0021,,,.F.,.T.,.F.)  //"Total de Contas c/Alta Fechadas"
 oTotaliz5:SetCondition({ ||(!EMPTY(("QRYR26")->GCY_DATALT)) .And. (!EMPTY(("QRYR26")->GCY_DATFEC))})

Return( oReport )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ R26Imp   ณ Autor ณ Antonio Carlos/Marceloณ Data ณ 07/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R26IMP(oReport)

Local	cCond1 := "%%",;
      cCond2 := "%%",;
      cCond3 := "%%",;
      cCond4 := "%%",;
      oSection1,oSection2,oSection3

 oSection1 := oReport:Section(1)
 oSection2 := oReport:Section(1):Section(1)
 oSection3 := oReport:Section(1):Section(1):Section(1)

If !Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
 cCond1 := "%GCY.GCY_DATATE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' %"
Else
 cCond1 := "%GCY.GCY_DATATE <> '" + Len(MV_PAR01) + "' %"
EndIf

If !Empty(MV_PAR03) .Or. !Empty(MV_PAR04) 
 cCond2 := "%GCZ.GCZ_CODCON BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' %"
Else
 cCond2 := "%GCZ.GCZ_CODCON <> '" + STR(Len(MV_PAR03)) + "' %"
EndIf

If !Empty(MV_PAR05) .Or. !Empty(MV_PAR06) 
 cCond3 := "%GCY.GCY_LOCATE BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' %"
Else
 cCond3 := "%GCY.GCY_LOCATE <> '" + STR(Len(MV_PAR05)) + "' %"
EndIf

If nMvpar7 == 1
 cCond4 := "%GCY.GCY_DATATE, GCZ.GCZ_CODCON%" 
 ElseIf nMvpar7 == 2
 cCond4 := "%GCZ.GCZ_CODCON, GCY.GCY_NOME%"
EndIf

MakeSqlExpr(oReport:uParam)
oSection1:BeginQuery()

BeginSql alias "QRYR26"
 SELECT DISTINCT GCY_FILIAL, GCY_REGATE, GCY_TPALTA, GCY_REGGER, GCY_NOME, GCY_DATATE, GCY_HORATE, GCY_DATALT,; 
                 GCY_HORALT, GCY_LOCATE, GCY_CODLOC, GCY_CODCRM, GCY_CIDALT, GCY_ATENDI, GCY_DATFEC, GCZ_CODCON,; 
                 GCZ_CODPLA, GCW_DESCLI, GA9_NOME, GCM_DESPLA, GF4_DSTPAL, RA_NOME, GCS_NOMLOC  
 FROM %table:GCY% GCY 
	JOIN %table:GCZ% GCZ 	ON GCZ.GCZ_FILIAL	= %xFilial:GCZ% AND GCZ.%NotDel% AND GCZ.GCZ_REGATE	= GCY.GCY_REGATE 
 JOIN %table:GCW% GCW 	ON GCW.GCW_FILIAL	= %xFilial:GCW% AND GCW.%NotDel% AND GCW.GCW_CODCLI = GCY.GCY_CODCLI 
 JOIN %table:GA9% GA9 	ON GA9.GA9_FILIAL	= %xFilial:GA9% AND GA9.%NotDel% AND GA9.GA9_CODCON	= GCZ.GCZ_CODCON 
 JOIN %table:GCM% GCM 	ON GCM.GCM_FILIAL	= %xFilial:GCM% AND GCM.%NotDel% AND GCM.GCM_CODPLA	= GCZ.GCZ_CODPLA  
 LEFT JOIN %table:GF4% GF4 	ON GF4.GF4_FILIAL	= %xFilial:GF4% AND GF4.%NotDel% AND GF4.GF4_TPALTA	= GCY.GCY_TPALTA  
 JOIN %table:SRA% SRA 	ON SRA.RA_FILIAL 	= %xFilial:SRA% AND SRA.%NotDel% AND SRA.RA_CODIGO 	= GCY.GCY_CODCRM  
 JOIN %table:GCS% GCS 	ON GCS.GCS_FILIAL	= %xFilial:GCS% AND GCS.%NotDel% AND GCS.GCS_CODLOC	= GCY.GCY_LOCATE   
 WHERE GCY.GCY_FILIAL = %xFilial:GCY% AND GCY.%notDel%
 AND GCY.GCY_TPALTA <> %Exp:'99'%
 AND GCY.GCY_ATENDI = %Exp:'0'%
 AND %Exp:cCond1%
 AND %Exp:cCond2%
 AND %Exp:cCond3%
 ORDER BY %Exp:cCond4%
EndSql

oSection1:EndQuery()
oSection2:SetParentQuery()

oSection2:SetParentFilter({|G| IIF(nMvpar7 == 1, ("QRYR26")->GCY_DATATE, ("QRYR26")->GCZ_CODCON)  == G }, {|| IIF(nMvpar7 == 1, ("QRYR26")->GCY_DATATE, ("QRYR26")->GCZ_CODCON) })
oSection3:SetParentQuery()
oSection3:SetParentFilter({|G| IIF(nMvpar7 == 1, ("QRYR26")->GCY_DATATE, ("QRYR26")->GCZ_CODCON)  == G }, {|| IIF(nMvpar7 == 1, ("QRYR26")->GCY_DATATE, ("QRYR26")->GCZ_CODCON) })

oSection1:Print() // processa as informacoes da tabela principal
oReport:SetMeter(QRYR26->(LastRec()))

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR26 บ       ณ MARCELO JOSE       บ Data ณ 28/03/2005  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relacao DE PACIENTES ADMITIDOS NO PERIODO                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR26R3()
 Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3         := ""
 Local cPict          := ""
 Local cTitulo        := STR0003 //"P A C I E N T E S    A D M I T I D O S    N O   P E R I O D O"
 Local nLin           := 80
 Local cCabec1        := ""
 Local cCabec2        := ""
 Local imprime        := .T.
 Local aOrd           := {}
 Local nLinTotal      := 60

 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private tamanho      := "G"
 Private limite       := 132
 Private m_pag        := 01
 Private nomeprog     := "HSPAHR26"
 Private nTipo        := 18
 Private aReturn      := {STR0004, 1, STR0005, 1, 1, 1, "", 1}  //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private wnrel        := "HSPAHR26"
 Private cString      := ""
 Private aContas      := {}
 Private cPerg        := "HSPR26"

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 If !Pergunte(cPerg,.T.)
  return
 EndIf          
 
 lImpTotD := MV_PAR08 == 1
 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2
          /*                     1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                       0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
 cCabec1 := STR0006 //"Prontuario Nome------------------------------------  Data Ent. Hora  -  Data Alta Hora   Tipo de alta------------------------------------------  Permanencia   Medico------------------------   Setor------------------------"
 If MV_PAR07 == 1 //Data + Conv.
  cCabec2 := STR0007 //"             Cod - Convenio--------------------------------   Plano------------------------   CID alta   Clํnica----------------------------------------------------------------   Data do Fechamento"
 Else
  cCabec2 :=          STR0055  //"              Plano------------------------   CID alta   Clํnica----------------------------------------------------------------   Data do Fechamento"
 EndIf
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
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)
 
 Local nCtaFor := 0 
 Local nTotAlt := 0
 Local nTotGer := 0
 Local nHora    := 0
 Local cQuebra  := ""
 Local nTotal := 0  
 Local nSimFec  := 0
 Local nNaoFec  := 0

 Private cAliasGCY := "GCY"

 Set Printer to &wNRel
 Set Printer On
 Set Device  to Printer

		 cAliasGCY := "R26QRY"

		 dbSelectArea("GCY")
		 dbSetOrder(1)   
		 cQuery := " SELECT DISTINCT GCY.GCY_FILIAL GCY_FILIAL, GCY.GCY_REGATE GCY_REGATE, GCY.GCY_TPALTA GCY_TPALTA, "
		 cQuery += "        GCY.GCY_REGGER GCY_REGGER, GCY.GCY_NOME GCY_NOME, GCY.GCY_DATATE GCY_DATATE, GCY.GCY_HORATE GCY_HORATE, "
		 cQuery += "        GCY.GCY_DATALT GCY_DATALT, GCY.GCY_HORALT GCY_HORALT, GCY.GCY_LOCATE GCY_LOCATE, GCY.GCY_CODCRM GCY_CODCRM, "
   cQuery += "        GCY.GCY_CIDALT GCY_CIDALT, GCY.GCY_ATENDI GCY_ATENDI, GCY.GCY_DATFEC GCY_DATFEC, GCZ.GCZ_CODCON GCZ_CODCON, "
		 cQuery += "        GCZ.GCZ_CODPLA GCZ_CODPLA, GCW.GCW_DESCLI GCW_DESCLI, GA9.GA9_NOME GA9_NOME, GCM.GCM_DESPLA GCM_DESPLA, "
		 cQuery += "        GF4.GF4_DSTPAL GF4_DSTPAL, SRA.RA_NOME RA_NOME, GCS.GCS_NOMLOC GCS_NOMLOC"
		 cQuery += "  FROM "+RetSqlName("GCY") + " GCY "
		 cQuery += "  JOIN "+RetSQLName("GCZ") + " GCZ 	ON GCZ.GCZ_FILIAL  	= '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ 		<> '*' AND GCZ.GCZ_REGATE	= GCY.GCY_REGATE "
   cQuery += "  JOIN "+RetSQLName("GCW") + " GCW 	ON GCW.GCW_FILIAL  	= '" + xFilial("GCW") + "' AND GCW.D_E_L_E_T_ 		<> '*' AND GCW.GCW_CODCLI = GCY.GCY_CODCLI "
   cQuery += "  JOIN "+RetSQLName("GA9") + " GA9 	ON GA9.GA9_FILIAL  	= '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ 		<> '*' AND GA9.GA9_CODCON = GCZ.GCZ_CODCON "
   cQuery += "  JOIN "+RetSQLName("GCM") + " GCM 	ON GCM.GCM_FILIAL  	= '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ 		<> '*' AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA "
   cQuery += "  LEFT JOIN "+RetSQLName("GF4") + " GF4 	ON GF4.GF4_FILIAL  	= '" + xFilial("GF4") + "' AND GF4.D_E_L_E_T_ 		<> '*' AND GF4.GF4_TPALTA = GCY.GCY_TPALTA "
   cQuery += "  JOIN "+RetSQLName("SRA") + " SRA 	ON SRA.RA_FILIAL  	 = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ 		<> '*' AND SRA.RA_CODIGO = GCY.GCY_CODCRM "
   cQuery += "  JOIN "+RetSQLName("GCS") + " GCS 	ON GCS.GCS_FILIAL  	= '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ 		<> '*' AND GCS.GCS_CODLOC = GCY.GCY_LOCATE "
		 cQuery += " WHERE GCY.GCY_FILIAL = '" + xFilial( "GCY" ) + "' "
		 cQuery += "   AND GCY.GCY_TPALTA <> '99' "
		 cQuery += "   AND GCY.GCY_ATENDI = '0' "
		 cQuery += "   AND GCZ.GCZ_CODCON BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
   If !Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
    cQuery += "  AND GCY.GCY_DATATE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
	  EndIf
   If !Empty(MV_PAR05) .Or. !Empty(MV_PAR06) 
    cQuery += "  AND GCY.GCY_LOCATE BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
 		EndIf
		 cQuery += "   AND GCY.D_E_L_E_T_ <> '*' "           

   If MV_PAR07 == 1 //Data Atend. + Conv
    cQuery += " ORDER BY GCY_DATATE, GCZ_CODCON"
   Else //Conv + Paciente
    cQuery += " ORDER BY GCZ_CODCON, GCY_NOME"
   EndIf 

 	 cQuery := ChangeQuery(cQuery)

		 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasGCY,.T.,.T.)

   DbSelectArea(cAliasGCY)
 
			While !Eof()
           
    If !Empty((cAliasGCY)->GCY_DATALT)
     nTotAlt++
    EndIf
    nTotGer++
    AADD(aContas,{"","","","","","","","","","","","","","","","","",""})
    aContas[Len(aContas), 1] := (cAliasGCY)->GCY_TPALTA
    aContas[Len(aContas), 2] := (cAliasGCY)->GCY_REGATE
    aContas[Len(aContas), 3] := (cAliasGCY)->GCY_REGGER 
    aContas[Len(aContas), 4] := (cAliasGCY)->GCY_NOME
    aContas[Len(aContas), 5] := DTOC(StoD( (cAliasGCY)->GCY_DATATE ))
    aContas[Len(aContas), 6] := (cAliasGCY)->GCY_HORATE
    aContas[Len(aContas), 7] := DTOC(StoD( (cAliasGCY)->GCY_DATALT ))
    aContas[Len(aContas), 8] := (cAliasGCY)->GCY_HORALT
    aContas[Len(aContas), 9] := (cAliasGCY)->GCZ_CODCON + " - " + (cAliasGCY)->GA9_NOME
    aContas[Len(aContas),10] := (cAliasGCY)->GCM_DESPLA
    aContas[Len(aContas),11] := (cAliasGCY)->GCY_LOCATE 
    aContas[Len(aContas),12] := (cAliasGCY)->GCY_CODCRM
    aContas[Len(aContas),13] := (cAliasGCY)->GCY_CIDALT
    aContas[Len(aContas),14] := StoD( (cAliasGCY)->GCY_DATFEC ) 
    aContas[Len(aContas),15] := (cAliasGCY)->GCW_DESCLI // Nome da Clinica
    aContas[Len(aContas),16] := (cAliasGCY)->GF4_DSTPAL
    aContas[Len(aContas),17] := (cAliasGCY)->RA_NOME
    aContas[Len(aContas),18] := (cAliasGCY)->GCS_NOMLOC
    
    DbSkip()
	  EndDo

  DbSelectArea(cAliasGCY)
 	dbCloseArea()

/*================================================================================================================*/

 	
 nLin := 1000  // forca a entrada no codigo de cabecalho.
 SetRegua(Len(aContas)) 
 For nCtaFor = 1 to Len(aContas)     	

  If lAbortPrint
   @nLin,00 PSAY STR0008 //"INTERROMPIDO PELO USUARIO"
   Exit
  Endif     

  If nLin > nMaxLin
   If m_pag > 1
    @ nLin,01 Psay STR0009 //"continua..."
   Endif
   Cabec(cTitulo,cCabec1,cCabec2,NomeProg,Tamanho,nTipo)
   nLin := 10     
   If m_pag > 1
    If cQuebra == IIF(MV_PAR07 == 1, aContas[nCtaFor, 5], SUBSTR(aContas[nCtaFor, 9], 1, 3))
    	@ nLin,00 Psay STR0010 + IIF(MV_PAR07 == 1, aContas[nCtaFor, 5], aContas[nCtaFor, 9]) //"...continuacao de "
 	   nLin++
    Endif
   Endif
  EndIf

  If Len(aContas) >= 1
   If nCtaFor == 1 .OR. cQuebra <> IIF(MV_PAR07 == 1, aContas[nCtaFor, 5], SUBSTR(aContas[nCtaFor, 9], 1, 3))
    If nCtaFor > 1
     nLin++
    Endif
    If nTotal > 0 .And. lImpTotD
     @ nLin,00 Psay IIF(MV_PAR07 == 1, STR0011, STR0050) + "===>  " + Str(nTotal,4,0)   //"Total do Dia: " //"Total do Conv๊nio: "
     nLin +=2
     nTotal := 0
    EndIf     
  	 @ nLin,00 Psay IIF(MV_PAR07 == 1, STR0013, STR0051) + IIF(MV_PAR07 == 1, aContas[nCtaFor, 5], aContas[nCtaFor, 9]) //"Data da Admissao: " //"Conv๊nio: "
  	 nLin++
  	 @ nLin,00 Psay STR0014 //"---- -- ---------"
    cQuebra := IIF(MV_PAR07 == 1, aContas[nCtaFor, 5], SUBSTR(aContas[nCtaFor, 9], 1, 3))
    nLin++
   EndIf
  EndIf
                
  @ nLin,00  Psay aContas[nCtaFor,3]
  @ nLin,11  Psay SUBSTR(aContas[nCtaFor,4],1,40)
  @ nLin,53  Psay aContas[nCtaFor, 5]
  @ nLin,63  Psay aContas[nCtaFor,6]
  @ nLin,72  Psay aContas[nCtaFor, 7]
  @ nLin,82  Psay aContas[nCtaFor,8]
  @ nLin,89  Psay PADR(aContas[nCtaFor, 16],30)
  nHora := SubtHoras(CTOD(aContas[nCtaFor, 5]), aContas[nCtaFor,6], CTOD(aContas[nCtaFor, 7]), aContas[nCtaFor,8])    
  If nHora >= 0
   @ nLin,145 Psay Str((nHora/24),4,0) + STR0015 //" dia(s)"
  EndIf
  @ nLin,159 Psay aContas[nCtaFor, 17]
  @ nLin,192 Psay PADR(aContas[nCtaFor, 18],30)
  nLin++
  
  If MV_PAR07 == 1 //Data + Conv.
   @ nLin,013 Psay aContas[nCtaFor, 9]
  EndIf 
  @ nLin, IIF(MV_PAR07 == 1, 062, 013) Psay aContas[nCtaFor,10]
  @ nLin, IIF(MV_PAR07 == 1, 094, 046) Psay aContas[nCtaFor,13]
  @ nLin, IIF(MV_PAR07 == 1, 105, 057) Psay aContas[nCtaFor,15]
  @ nLin, IIF(MV_PAR07 == 1, 178, 131) Psay DtoC(aContas[nCtaFor,14])
  IF !EMPTY(aContas[nCtaFor, 7])
   If Empty(aContas[nCtaFor,14])
    nNaoFec++
   Else      
    nSimFec++
   EndIf
  EndIf
  nLin += 2
  nTotal++
 Next

 If (MV_PAR07 == 1 .Or. MV_PAR07 == 2) .And. lImpTotD /*se ordernar por data utiliza o separador e totalizador*/
  If nTotal > 0
   @ nLin,00 Psay IIF(MV_PAR07 == 1, STR0011, STR0050) + "===>  " + Str(nTotal,4,0) //"Total do Dia: " //"Total do Conv๊nio: "
   nLin +=2
  EndIf     
 EndIf
    
 @ nLin,000 Psay REPLI("_",229)
 nLin++
 @ nLin,000 Psay STR0016 + Transform(nTotGer, "@E 999,999") //" Total de Atendimentos no periodo ...: "
 nLin++
 @ nLin,000 Psay STR0017 + Transform(nTotAlt, "@E 999,999") //" Total de Saidas no periodo .........: "
 nLin++
 @ nLin,000 Psay STR0018 + Transform((nTotAlt/nTotGer * 100), "@E 999.99") + STR0019 //" Percentual de Saidas x Atendimentos : "###" %"
 nLin += 2
 @ nLin,000 Psay STR0020 + Transform(nNaoFec, "@E 999,999") //" Total de Contas Com alta em Aberto .: "
 nLin++
 @ nLin,000 Psay STR0021 + Transform(nSimFec, "@E 999,999") //" Total de Contas Com alta e Fechadas : "
 Set Printer to
 Set Device  to Screen
 
 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()
Return(Nil)
