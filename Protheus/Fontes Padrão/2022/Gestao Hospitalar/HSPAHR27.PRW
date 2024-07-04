#INCLUDE "HSPAHR27.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "Report.ch"
#INCLUDE "Protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR27 บ       ณ Antonio Carlos     บ Data ณ 08/08/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ PACIENTES ATENDIDOS  NO PERIODO                            บฑฑ
ฑฑบ          ณ Conversใo para relatorios personalizaveis                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function HSPAHR27()
Local oReport

Private __cRetStt   := 0
Private cPerg        := PADR("HSPR27", Len(SX1->X1_GRUPO))
Private nTValGui     :=0
Private nqtde :=0
AjustaSXB()

If FindFunction("TRepInUse") .And. TRepInUse()
	Pergunte("HSPR27", .F.)
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	HSPAHR27R3()
EndIf

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Marcelo Jose          ณ Data ณ 08/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()

Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oSection4
Local oSection5
Local oBrake
Local oCell
Local oTotaliz1, oTotaliz2, oTotaliz3, oTotaliz4, oTotaliz5, oTotaliz6, oTotaliz7, oTotaliz8, oTotaliz9
Local cTpAlta 	:= SuperGetMV("MV_TPALTA")
Local cTipAlta	:= ""
Local aSttGuia := {"Controle de Contas", "Faturamento", "Faturado", "Lote Atribuido", "Gerado Faturas", "Associado Extrato Conv๊nio", "Liquidado", "Quitado"}

oReport := TReport():New("HSPAHR27", STR0003, "HSPR27", {|oReport| R27IMP(oReport)}, STR0001 + " " + STR0002)
//"Pacientes Atendidos no Perํodo"###"Este programa tem como objetivo imprimir relat๓rio "###"de acordo com os parโmetros informados pelo usuแrio."

//oReport:SetLandScape()  // Imprimir relatorio em formato retrato
 oReport:SetTotalInLine(.T.)

 oSection1 := TRSection():New(oReport,"")
 oSection1:SetPageBreak(.F.)
 oSection1:SetHeaderPage(.F.)
 oSection1:SetPageBreak(.T.)

 oSection2 := TRSection():New(oSection1,,{"QRYSQL"})
 oSection2:SetHeaderPage(.F.)
 oSection2:SetHeaderSection(.F.)
 oSection2:SetTotalInLine(.T.)

 oSection3 := TRSection():New(oSection2,,{"QRYSQL"})
 oSection3:SetHeaderPage(.F.)
 oSection3:SetHeaderSection(.F.)
 oSection3:SetHeaderBreak(.F.)
 oSection3:SetHeaderPage(.F.)
 oSection3:SetTotalInLine(.T.)

 oSection4 := TRSection():New(oSection3)
 oSection4:SetHeaderPage(.T.)
 oSection4:SetHeaderBreak(.F.)

 oSection5 := TRSection():New(oSection3)
 oSection5:SetHeaderPage(.T.)
 oSection5:SetHeaderBreak(.F.)

 oCell := TRCell():New(oSection1,"cLocal","QRYR27","",, 50,, {|| cLocal := ("QRYR27")->GCY_LOCATE + " - " + HS_IniPadr("GCS", 1, ("QRYR27")->GCY_LOCATE, "GCS_NOMLOC")})

 oCell := TRCell():New(oSection2,"GCY_REGATE","QRYR27","",, 10)
 oCell := TRCell():New(oSection2,"GCY_REGGER","QRYR27","",, 14)
 oCell := TRCell():New(oSection2,"GCY_NOME"  ,"QRYR27","",, 50)
 oCell := TRCell():New(oSection2,"GCY_DATATE","QRYR27","",, 10)
 oCell := TRCell():New(oSection2,"GCY_HORATE","QRYR27","",, 10)
 oCell := TRCell():New(oSection2,"GCY_DATALT","QRYR27","",, 10)
 oCell := TRCell():New(oSection2,"GCY_HORALT","QRYR27","",, 10)

 oCell := TRCell():New(oSection3,"GCZ_NRSEQG","QRYR27","",, 14)
 oCell := TRCell():New(oSection3,"RA_NOME"   ,"QRYR27","",, 40)
 oCell := TRCell():New(oSection3,"GCM_DESPLA","QRYR27","",, 40)
 oCell := TRCell():New(oSection3,"cValGui","QRYR27","",, 20,, {|| cValGui := TRANSFORM(FS_ValGui(("QRYR27")->GCZ_NRSEQG,("QRYR27")->GCZ_STATUS), "999999999.99")})
 oCell := TRCell():New(oSection3,"cStatus","QRYR27","",, 30,, {|| cStatus := aSttGuia[Val(("QRYR27")->GCZ_STATUS)+1]})

 oCell := TRCell():New(oSection4,STR0033,,,, 14)
 oCell := TRCell():New(oSection4,STR0034,,,, 60)
 oCell := TRCell():New(oSection4,STR0035,,,, 20)
 oCell := TRCell():New(oSection4,STR0036,,,, 20)

 oCell := TRCell():New(oSection5,STR0037,,,, 14)
 oCell := TRCell():New(oSection5,STR0038,,,, 40)
 oCell := TRCell():New(oSection5,STR0039,,,, 40)
 oCell := TRCell():New(oSection5,STR0030,,,"@D", 20)
 oCell := TRCell():New(oSection5,STR0031,,,, 15)

 /*RESUMO FINAL*/

 oTotaliz1 := TRFunction():New(oSection3:Cell("cValGui")	,/* cID */,"SUM",,STR0040 + STR0042/*cTitle*/,"@D 999999999.99",/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,,{|| ("QRYR27")->GCZ_STATUS == "0"})
 oTotaliz1 := TRFunction():New(oSection3:Cell("GCZ_NRSEQG")	,/* cID */,"COUNT",,STR0041 + STR0042/*cTitle*/,"999.999",/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,,{|| ("QRYR27")->GCZ_STATUS == "0"})

 oTotaliz2 := TRFunction():New(oSection3:Cell("cValGui")	,/* cID */,"SUM",,STR0040 + STR0043/*cTitle*/,"@D 999999999.99",/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,,{|| ("QRYR27")->GCZ_STATUS == "1"})
 oTotaliz2 := TRFunction():New(oSection3:Cell("GCZ_NRSEQG")	,/* cID */,"COUNT",,STR0041 + STR0043/*cTitle*/,"@D 999.999",/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,,{|| ("QRYR27")->GCZ_STATUS == "1"})

 oTotaliz3 := TRFunction():New(oSection3:Cell("cValGui")	,/* cID */,"SUM",,STR0040 + STR0044/*cTitle*/,"@D 999999999.99",/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,,{|| ("QRYR27")->GCZ_STATUS == "2"})
 oTotaliz3 := TRFunction():New(oSection3:Cell("GCZ_NRSEQG")	,/* cID */,"COUNT",,STR0041 + STR0044/*cTitle*/,"@D 999.999",/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,,{|| ("QRYR27")->GCZ_STATUS == "2"})

 oTotaliz4 := TRFunction():New(oSection3:Cell("cValGui")	,/* cID */,"SUM",,STR0040 + STR0045/*cTitle*/,"@D 999999999.99",/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,,{|| ("QRYR27")->GCZ_STATUS == "3"})
 oTotaliz4 := TRFunction():New(oSection3:Cell("GCZ_NRSEQG")	,/* cID */,"COUNT",,STR0041 + STR0045/*cTitle*/,"@D 999.999",/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,,{|| ("QRYR27")->GCZ_STATUS == "3"})

 oTotaliz5 := TRFunction():New(oSection3:Cell("cValGui")	,/* cID */,"SUM",,STR0040 + STR0046/*cTitle*/,"@D 999999999.99",/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,,{|| ("QRYR27")->GCZ_STATUS == "4"})
 oTotaliz5 := TRFunction():New(oSection3:Cell("GCZ_NRSEQG")	,/* cID */,"COUNT",,STR0041 + STR0046/*cTitle*/,"@D 999.999",/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,,{|| ("QRYR27")->GCZ_STATUS == "4"})

 oTotaliz6 := TRFunction():New(oSection3:Cell("cValGui")	,/* cID */,"SUM",,STR0040 + STR0047/*cTitle*/,"@D 999999999.99",/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,,{|| ("QRYR27")->GCZ_STATUS == "5"})
 oTotaliz6 := TRFunction():New(oSection3:Cell("GCZ_NRSEQG")	,/* cID */,"COUNT",,STR0041 + STR0047/*cTitle*/,"@D 999.999",/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,,{|| ("QRYR27")->GCZ_STATUS == "5"})

 oTotaliz7 := TRFunction():New(oSection3:Cell("cValGui")	,/* cID */,"SUM",,STR0040 + STR0048/*cTitle*/,"@D 999999999.99",/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,,{|| ("QRYR27")->GCZ_STATUS == "6"})
 oTotaliz7 := TRFunction():New(oSection3:Cell("GCZ_NRSEQG")	,/* cID */,"COUNT",,STR0041 + STR0048/*cTitle*/,"@D 999.999",/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,,{|| ("QRYR27")->GCZ_STATUS == "6"})

 oTotaliz8 := TRFunction():New(oSection3:Cell("cValGui")	,/* cID */,"SUM",,STR0040 + STR0049/*cTitle*/,"@D 999999999.99",/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,,{|| ("QRYR27")->GCZ_STATUS == "7"})
 oTotaliz8 := TRFunction():New(oSection3:Cell("GCZ_NRSEQG")	,/* cID */,"COUNT",,STR0041 + STR0049/*cTitle*/,"@D 999.999",/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,,{|| ("QRYR27")->GCZ_STATUS == "7"})
 oTotaliz9 := TRFunction():new(oSection3:Cell("cValGui"),,"ONPRINT",,STR0050,"@D 999999999.99",{||(nTValGui)},.F.,.T.,.F.,,)
 oTotaliz9 := TRFunction():new(oSection3:Cell("GCZ_NRSEQG"),,"ONPRINT",,STR0051,"@D 999.999",{||nqtde },.F.,.T.,.F.,,)

Return( oReport )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ R27Imp   ณ Autor ณ Antonio Carlos        ณ Data ณ 07/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R27IMP(oReport)

Local oSection1      := oReport:Section(1)
Local oSection2      := oReport:Section(1):Section(1)
Local oSection3      := oReport:Section(1):Section(1):Section(1)
Local oSection4      := oReport:Section(1):Section(1):Section(1):Section(1)

Local cCond1         := ""
Local cCond2         := ""
Local cCond3         := ""
Local cCond4         := ""
Local cOrderBy       := ""
Local dDataDe        := MV_PAR01
Local dDataAte       := MV_PAR03
Local cHoraDe        := Alltrim(MV_PAR02)
Local cHoraAte       := Alltrim(MV_PAR04)
Local dDtSdDe        := MV_PAR05
Local dDtSdAte       := MV_PAR06
Local cCompetDe      := SUBSTR(DTOS(MV_PAR07),5, 2)+"/"+SUBSTR(DTOS(MV_PAR07),3, 2)// formata็ใo do paramentro MV_PAR07(00/00)para 00/00/00
Local cCompetAte     := SUBSTR(DTOS(MV_PAR08),5, 2)+"/"+SUBSTR(DTOS(MV_PAR08),3, 2)//formata็ใo do paramentro MV_PAR08(00/00)para 00/00/00
Local cConvenioDe    := MV_PAR09
Local cConvenioAte   := MV_PAR10
Local cPlanoDe       := MV_PAR11
Local cPlanoAte      := MV_PAR12
Local cSetorDe       := MV_PAR13
Local cSetorAte      := MV_PAR14
Local cMedicoDe      := MV_PAR15
Local cMedicoAte     := MV_PAR16
Local nObito         := MV_PAR17
Local nOrdem         := MV_PAR18
Local nTipAtend      := MV_PAR19
Local cSttGui        := MV_PAR20
MakeSqlExpr(oReport:uParam)
oSection1:BeginQuery()

cCond1 := "% GCY.GCY_FILIAL GCY_FILIAL, GCY.GCY_REGATE GCY_REGATE, GCY.GCY_CODEMP GCY_CODEMP,GCY.GCY_REGGER GCY_REGGER, "
cCond1 += " GCY.GCY_NOME   GCY_NOME,   GCY.GCY_DATATE GCY_DATATE, GCY.GCY_HORATE GCY_HORATE, GCY.GCY_LOCATE GCY_LOCATE, "
cCond1 += " GCY.GCY_CODCRM GCY_CODCRM, GCY.GCY_DATALT GCY_DATALT, GCY.GCY_HORALT GCY_HORALT, GCY.GCY_TPALTA GCY_TPALTA, "
cCond1 += " GCZ.GCZ_CODCON GCZ_CODCON, GCZ.GCZ_NRSEQG GCZ_NRSEQG, GCZ.GCZ_VLGUIA GCZ_VLGUIA, GCZ.GCZ_STATUS GCZ_STATUS, "
cCond1 += " SRA.RA_NOME, GAE.GAE_NOME, GA9.GA9_NOME GA9_NOME, GCM.GCM_DESPLA GCM_DESPLA, GBH.GBH_CODEMP GBH_CODEMP %"

cCond2 := "% " + RetSQLName("GCY") + " GCY "
cCond2 += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_REGATE = GCY.GCY_REGATE LEFT "
cCond2 += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO = GCY.GCY_CODCRM "
cCond2 += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' AND GA9.GA9_CODCON = GCZ.GCZ_CODCON "
cCond2 += " JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA "
cCond2 += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' AND GBH.GBH_CODPAC = GCY.GCY_REGGER LEFT "
cCond2 += " JOIN " + RetSQLName("GAE") + " GAE ON GAE.GAE_FILIAL = '" + xFilial("GAE") + "' AND GAE.D_E_L_E_T_ <> '*' AND GAE.GAE_CODEMP = GBH.GBH_CODEMP "
If (!Empty(cCompetDe) .OR. !Empty(cCompetAte))
 cCond2 += " JOIN " + RetSQLName("GAT") + " GAT ON GAT.GAT_FILIAL = '" + xFilial("GAT") + "' AND GAT.GAT_CODCON = GCZ.GCZ_CODCON AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE "
 cCond2 += " AND GAT.GAT_MESREF BETWEEN '" + cCompetDe +"' AND '" + cCompetAte  + "' AND GAT.D_E_L_E_T_ <> '*' %"
Else
 cCond2 += " %"
EndIf

If (Empty(cCompetDe) .AND. Empty(cCompetAte))
 cCond3 := "% GCY.GCY_DATATE BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' AND "
 cCond3 += " GCY.GCY_HORATE BETWEEN '" + cHoraDe + "' AND '" + cHoraAte + "' AND "
Else
 cCond3 := "% "
EndIf
cCond3 += " GCZ.GCZ_CODCON BETWEEN '" + cConvenioDe + "' AND '" + cConvenioAte + "' AND "
cCond3 += " GCZ.GCZ_CODPLA BETWEEN '" + cPlanoDe + "' AND '" + cPlanoAte + "' AND "
cCond3 += " GCY.GCY_LOCATE BETWEEN '" + cSetorDe + "' AND '" + cSetorAte + "' AND "
cCond3 += " GCY.GCY_CODCRM BETWEEN '" + cMedicoDe + "' AND '" + cMedicoAte + "' AND "
If !(Empty(substr(DTOS(dDTSdDe),1,2))) .AND. !Empty(substr(DTOS(dDtSdAte),1,2))
cCond3 += " GCY.GCY_DATSAI BETWEEN '" + DTOS(dDTSdDe) + "' AND '" + DTOS(dDtSdAte) + "' AND "
endif
If (nObito <> 3)
 cCond3 += " GCY.GCY_TPALTA " + IIf(nObito == 2, " NOT ", "") + " IN ('" + GetMV("MV_TPALTA") + "') AND "
EndIf
If !Empty(cSttGui) .AND. cSttGui <> '8'
 cCond3 += " GCZ.GCZ_STATUS = '" + cSttGui + "' AND "
EndIf

If nTipAtend == 1
	cCond3 += " GCY.GCY_ATENDI = '1' AND "
ElseIf nTipAtend == 2
	cCond3 += " GCY.GCY_ATENDI = '2' AND "
ElseIf nTipAtend == 3
	cCond3 += " GCY.GCY_ATENDI = '0' AND "
Else
	cCond3 += " GCY.GCY_ATENDI IN ('0', '1', '2') AND "
EndIf

cCond3 += " GCY.GCY_TPALTA <> '99' AND GCY.D_E_L_E_T_ <> '*' %" //GBH.GBH_CODEMP BETWEEN '" + cEmpIni + "' AND '" + cEmpFim + "' AND

If nOrdem == 1  //ORDENAR POR NOME
	cOrderBy := "% GCY_FILIAL, GCY_LOCATE, GCY_REGATE, GCY_DATATE, GCY_NOME %"
ElseIf nOrdem == 2 //Ordenar por
	cOrderBy := "% GCY_FILIAL, GCY_LOCATE, GCY_REGATE, GCY_DATATE, GCY_HORATE %"
ElseIf nOrdem == 3 //Ordenar por prontuario
	cOrderBy := "% GCY_FILIAL, GCY_LOCATE, GCY_REGATE, GCY_DATATE, GCY_REGGER %"
EndIf

 BeginSql alias "QRYR27"
  SELECT %Exp:cCond1%
  FROM   %Exp:cCond2%
  WHERE  %Exp:cCond3%
  ORDER BY %Exp:cOrderby%
 EndSql

 oSection1:EndQuery()

While !Eof()
 nQtde++
 DbSkip()
End
 oSection2:SetParentQuery()
 oSection2:SetParentFilter({|G| ("QRYR27")->GCY_LOCATE == G }, {|| ("QRYR27")->GCY_LOCATE})

 oSection3:SetParentQuery()
 oSection3:SetParentFilter({|I| ("QRYR27")->GCY_REGATE == I }, {|| ("QRYR27")->GCY_REGATE})

 oSection4:SetParentQuery()
 oSection4:SetParentFilter({|J| ("QRYR27")->GCZ_NRSEQG == J }, {|| ("QRYR27")->GCZ_NRSEQG})

 oSection1:Print() // processa as informacoes da tabela principal
 oReport:SetMeter(GCY->(LastRec()))

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR27 บ       ณ MARCELO JOSE       บ Data ณ 29/03/2005  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ PACIENTES ATENDIDOS  NO PERIODO                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function HSPAHR27R3()
Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relat๓rio "
Local cDesc2         := STR0002 //"de acordo com os parโmetros informados pelo usuแrio."
Local cDesc3         := ""
Local cPict          := ""
Local imprime        := .T.
Local aOrd           := {}
Local nLinTotal      := 60
Local nLin           := 80

Private cTitulo      := STR0003 //"Pacientes Atendidos no Perํodo"
Private cCabec1      := STR0004
Private cCabec2      := STR0032
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private Tamanho      := "M"
Private limite       := 132
Private m_pag        := 01
Private nomeprog     := "HSPAHR27R3"
Private nTipo        := 18
Private aReturn      := {STR0005, 1, STR0006, 2, 2, 1, "", 1}  //"Zebrado"###"Administra็ใo"
Private nLastKey     := 0
Private wnrel        := "HSPAHR27R3"
Private cString      := "GCY"
Private aContas      := {}
Private cPerg        := "HSPR27"
Private cCodImp      := ""
Private nMaxLin      := 0 // quantidade maxima de linhas p/ impressao

If !Pergunte(cPerg, .T.)
	Return()
EndIf

nMaxLin := HS_MaxLin(cCodImp)
nLin    := nMaxLin * 2

wnrel := SetPrint(cString, NomeProg, "", @cTitulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho,, .F.)

If nLastKey == 27
	Return()
EndIf

SetDefault(aReturn, cString)

If nLastKey == 27
	Return()
EndIf

RptStatus({|| RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)}, cTitulo)
Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)

Local dDataDe        := MV_PAR01
Local cHoraDe        := Alltrim(MV_PAR02)
Local dDataAte       := MV_PAR03
Local cHoraAte       := Alltrim(MV_PAR04)
Local dDtSdDe        := MV_PAR05
Local dDtSdAte       := MV_PAR06
Local cCompetDe      := SUBSTR(DTOS(MV_PAR07),5, 2)+"/"+SUBSTR(DTOS(MV_PAR07),3, 2)// formata็ใo do paramentro MV_PAR07(00/00)para 00/00/00
Local cCompetAte     := SUBSTR(DTOS(MV_PAR08),5, 2)+"/"+SUBSTR(DTOS(MV_PAR08),3, 2)//formata็ใo do paramentro MV_PAR08(00/00)para 00/00/00
Local cConvenioDe    := MV_PAR09
Local cConvenioAte   := MV_PAR10
Local cPlanoDe       := MV_PAR11
Local cPlanoAte      := MV_PAR12
Local cSetorDe       := MV_PAR13
Local cSetorAte      := MV_PAR14
Local cMedicoDe      := MV_PAR15
Local cMedicoAte     := MV_PAR16
Local nObito         := MV_PAR17
Local nOrdem         := MV_PAR18
Local nTipAtend      := MV_PAR19
Local cSttGui        := MV_PAR20
Local nQtdG          :=0
Local aSttGuia := {"Controle de Contas", "Faturamento", "Faturado", "Lote Atribuido", "Gerado Faturas", "Associado Extrato Conv๊nio", "Liquidado", "Quitado"}
Local aTotGuia := {{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}}
Local nValor :=0
Private cCodSetor    := ""
Private cRegAte      := ""

//DbSelectArea("GCY")

cQuery := "SELECT GCY.GCY_FILIAL GCY_FILIAL, GCY.GCY_REGATE GCY_REGATE, GCY.GCY_CODEMP GCY_CODEMP,GCY.GCY_REGGER GCY_REGGER, "
cQuery += " GCY.GCY_NOME GCY_NOME, GCY.GCY_DATATE GCY_DATATE,GCY.GCY_HORATE GCY_HORATE, GCY.GCY_LOCATE GCY_LOCATE, "
cQuery += " GCY.GCY_CODCRM GCY_CODCRM, GCY.GCY_DATALT GCY_DATALT, GCY.GCY_HORALT GCY_HORALT, GCY.GCY_TPALTA GCY_TPALTA, "
cQuery += " GCZ.GCZ_CODCON GCZ_CODCON, GCZ.GCZ_NRSEQG GCZ_NRSEQG, GCZ.GCZ_VLGUIA GCZ_VLGUIA, GCZ.GCZ_STATUS GCZ_STATUS, "
cQuery += " SRA.RA_NOME, GAE.GAE_NOME, GA9.GA9_NOME GA9_NOME, GCM.GCM_DESPLA GCM_DESPLA, GBH.GBH_CODEMP GBH_CODEMP "

cQuery += "FROM " + RetSQLName("GCY") + " GCY "
cQuery += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_REGATE = GCY.GCY_REGATE LEFT "
cQuery += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO = GCY.GCY_CODCRM "
cQuery += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' AND GA9.GA9_CODCON = GCZ.GCZ_CODCON "
cQuery += " JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA "
cQuery += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' AND GBH.GBH_CODPAC = GCY.GCY_REGGER LEFT "
cQuery += " JOIN " + RetSQLName("GAE") + " GAE ON GAE.GAE_FILIAL = '" + xFilial("GAE") + "' AND GAE.D_E_L_E_T_ <> '*' AND GAE.GAE_CODEMP = GBH.GBH_CODEMP "
If (!Empty(cCompetDe) .OR. !Empty(cCompetAte))
 cQuery += " JOIN " + RetSQLName("GAT") + " GAT ON GAT.GAT_FILIAL = '" + xFilial("GAT") + "' AND GAT.GAT_CODCON = GCZ.GCZ_CODCON AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE "
 cQuery += " AND GAT.GAT_MESREF BETWEEN '" + cCompetDe +"' AND '" + cCompetAte + "' AND GAT.D_E_L_E_T_ <> '*' "
EndIf
cQuery += "WHERE "
If (Empty(cCompetDe) .AND. Empty(cCompetAte))
 cQuery += " GCY.GCY_DATATE BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' AND "
 cQuery += " GCY.GCY_HORATE BETWEEN '" + cHoraDe + "' AND '" + cHoraAte + "' AND "
EndIf
cQuery += " GCZ.GCZ_CODCON BETWEEN '" + cConvenioDe + "' AND '" + cConvenioAte + "' AND "
cQuery += " GCZ.GCZ_CODPLA BETWEEN '" + cPlanoDe + "' AND '" + cPlanoAte + "' AND "
cQuery += " GCY.GCY_LOCATE BETWEEN '" + cSetorDe + "' AND '" + cSetorAte + "' AND "
cQuery += " GCY.GCY_CODCRM BETWEEN '" + cMedicoDe + "' AND '" + cMedicoAte + "' AND "

If !(Empty(substr(DTOS(dDTSdDe),1,2))) .AND. !Empty(substr(DTOS(dDtSdAte),1,2))
cQuery += " GCY.GCY_DATSAI BETWEEN '" + DTOS(dDTSdDe) + "' AND '" + DTOS(dDtSdAte) + "'  AND "
endif
If (nObito <> 3)
 cQuery += " GCY.GCY_TPALTA " + IIf(nObito == 2, " NOT ", "") + " IN ('" + GetMV("MV_TPALTA") + "') AND "
EndIf
If !Empty(cSttGui) .AND. cSttGui <> '8'
 cQuery += " GCZ.GCZ_STATUS = '" + cSttGui + "' AND "
EndIf

If nTipAtend == 1
	cQuery += " GCY.GCY_ATENDI = '1' AND "
ElseIf nTipAtend == 2
	cQuery += " GCY.GCY_ATENDI = '2' AND "
ElseIf nTipAtend == 3
	cQuery += " GCY.GCY_ATENDI = '0' AND "
Else
	cQuery += " GCY.GCY_ATENDI IN ('0', '1', '2') AND "
EndIf

cQuery += " GCY.GCY_TPALTA <> '99' AND GCY.D_E_L_E_T_ <> '*' " //GBH.GBH_CODEMP BETWEEN '" + cEmpIni + "' AND '" + cEmpFim + "' AND

If nOrdem == 1  //ORDENAR POR NOME
	cQuery += "ORDER BY GCY_FILIAL, GCY_LOCATE, GCY_REGATE, GCY_DATATE, GCY_NOME "
ElseIf nOrdem == 2 //Ordenar por
	cQuery += "ORDER BY GCY_FILIAL, GCY_LOCATE, GCY_REGATE, GCY_DATATE, GCY_HORATE "
ElseIf nOrdem == 3 //Ordenar por prontuario
	cQuery += "ORDER BY GCY_FILIAL, GCY_LOCATE, GCY_REGATE, GCY_DATATE, GCY_REGGER "
EndIf

cQuery := ChangeQuery(cQuery)
TCQUERY cQuery NEW ALIAS "QRY"

DbSelectArea("QRY")

If Eof() //Valida dados
	Hs_MsgInf(STR0020, STR0021, STR0022) //"Nใo hแ dados para a impressใo!"###"Aten็ใo"###"Valida็ใo de Impressใo"
	DbCloseArea()
	Return(Nil)
EndIf

While !Eof()

	If lAbortPrint
		@nLin, 000 PSAY STR0007 //"INTERROMPIDO PELO USUมRIO"
		Exit
	EndIf

	If cCodSetor <> QRY->GCY_LOCATE
  nLin := 1000
		nLin := FS_Cabec(nLin)
		@nLin, 000 Psay "Setor: " + QRY->GCY_LOCATE + " - " + HS_IniPadr("GCS", 1, QRY->GCY_LOCATE, "GCS_NOMLOC")
		cCodSetor := QRY->GCY_LOCATE
		nLin++
	Endif

 If nLin > nMaxLin
	 nLin := FS_Cabec(nLin + 1)
 EndIf

 If cRegAte <> QRY->GCY_REGATE

  nLin++

  @ nLin, 000 Psay QRY->GCY_REGATE
  @ nLin, 010 Psay QRY->GCY_REGGER + " - " + QRY->GCY_NOME
  @ nLin, 074 Psay DTOC(STOD(QRY->GCY_DATATE)) + " - " + QRY->GCY_HORATE
  @ nLin, 094 Psay DTOC(STOD(QRY->GCY_DATALT)) + " - " + QRY->GCY_HORALT
  cRegAte := QRY->GCY_REGATE

  nLin++

 EndIf
	 nValor :=FS_ValGui(QRY->GCZ_NRSEQG,QRY->GCZ_STATUS)
 @ nLin, 002 Psay QRY->GCZ_NRSEQG
 @ nLin, 013 Psay QRY->RA_NOME
 @ nLin, 049 Psay SUBSTR(QRY->GCM_DESPLA, 1, 25)
     @ nLin, 079 Psay TRANSFORM(nValor, "999999999.99")//QRY->GCZ_VLGUIA
 @ nLin, 099 Psay aSttGuia[Val(QRY->GCZ_STATUS)+1]

 nLin++
 aTotGuia[Val(QRY->GCZ_STATUS)+1, 1] +=nValor
 aTotGuia[Val(QRY->GCZ_STATUS)+1, 2] += 1
 nQtdG+=1
	DbSkip()

EndDo

nLin++
	 If nLin > nMaxLin
    nLin := FS_Cabec(nLin + 1)
  Endif

@ nLin++, 002 Psay "-------------------------------------------------------------------------------------------------------------"

nLin++
@ nLin++, 002 Psay STR0040 + STR0042 + ":           " + TRANSFORM(aTotGuia[1, 1], "999999999.99")
@ nLin++, 002 Psay STR0041 + STR0042 + ":          " + ALLTRIM(STR(aTotGuia[1, 2]))
@ nLin++, 002 Psay STR0040 + STR0043 + ":           " + TRANSFORM(aTotGuia[2, 1], "999999999.99")
@ nLin++, 002 Psay STR0041 + STR0043 + ":          " + ALLTRIM(STR(aTotGuia[2, 2]))
@ nLin++, 002 Psay STR0040 + STR0044 + ":              " + TRANSFORM(aTotGuia[3, 1], "999999999.99")
@ nLin++, 002 Psay STR0041 + STR0044 + ":             " + ALLTRIM(STR(aTotGuia[3, 2]))
@ nLin++, 002 Psay STR0040 + STR0045 + ":        " + TRANSFORM(aTotGuia[4, 1], "999999999.99")
@ nLin++, 002 Psay STR0041 + STR0045 + ":       " + ALLTRIM(STR(aTotGuia[4, 2]))
@ nLin++, 002 Psay STR0040 + STR0046 + ":         " + TRANSFORM(aTotGuia[5, 1], "999999999.99")
@ nLin++, 002 Psay STR0041 + STR0046 + ":        " + ALLTRIM(STR(aTotGuia[5, 2]))
@ nLin++, 002 Psay STR0040 + STR0047 + ":  " + TRANSFORM(aTotGuia[6, 1], "999999999.99")
@ nLin++, 002 Psay STR0041 + STR0047 + ": " + ALLTRIM(STR(aTotGuia[6, 2]))
@ nLin++, 002 Psay STR0040 + STR0048 + ":             " + TRANSFORM(aTotGuia[7, 1], "999999999.99")
@ nLin++, 002 Psay STR0041 + STR0048 + ":            " + ALLTRIM(STR(aTotGuia[7, 2]))
@ nLin++, 002 Psay STR0040 + STR0049 + ":               " + TRANSFORM(aTotGuia[8,1], "999999999.99")
@ nLin++, 002 Psay STR0041 + STR0049 + ":              " + ALLTRIM(STR(aTotGuia[8, 2]))
@ nLin++, 002 Psay STR0050            + ":              " + ALLTRIM(STR(nTValGui))
@ nLin++, 002 Psay STR0051            + ":              " + ALLTRIM(STR(nQtdG))

DbCloseArea()

Set Printer To
Set Device To Screen

If aReturn[5] == 1
	DbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
EndIf

MS_FLUSH()

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Cabec  บAutor  ณLuiz Gustavo Caloi  บ Data ณ  30/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprimi Cabe็alho                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_Cabec(nLin, lImprime)
If nLin > nMaxLin
	Cabec(cTitulo, cCabec1, cCabec2, NomeProg, Tamanho, nTipo)
	nLin := 10
Endif
Return(nLin)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ValGui บAutor  ณHeimdall Castro     บ Data ณ  16/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula o valor das GE's para as guias do relat๓rio        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_ValGui(cNrSeqG,Cstatus)
Local nValGui   := 0
Local cSqlVal   := ""
Local aOldArea  := GetArea()

If Cstatus >= "2"
cSqlVal := "SELECT (GE5.GE5_VALDES * GE5.GE5_QTDDES ) VALDES FROM " + RetSqlName("GE5") + " GE5 WHERE GE5_NRSEQG = '" + cNrSeqG + "' AND GE5.D_E_L_E_T_ <> '*' AND GE5_FILIAL = '" + xFilial("GE5") + "'"
cSqlVal += "UNION "
cSqlVal += "SELECT (GE6.GE6_VALDES * GE6.GE6_QTDDES ) VALDES FROM " + RetSqlName("GE6") + " GE6 WHERE GE6_NRSEQG = '" + cNrSeqG + "' AND GE6.D_E_L_E_T_ <> '*' AND GE6_FILIAL = '" + xFilial("GE6") + "'"
cSqlVal += "UNION "
cSqlVal += "SELECT (GE7.GE7_VALDES * GE7.GE7_QTDDES ) VALDES FROM " + RetSqlName("GE7") + " GE7 WHERE GE7_NRSEQG = '" + cNrSeqG + "' AND GE7.D_E_L_E_T_ <> '*' AND GE7_FILIAL = '" + xFilial("GE7") + "'"
else
cSqlVal := "SELECT (GD5.GD5_VALDES * GD5.GD5_QTDDES ) VALDES FROM " + RetSqlName("GD5") + " GD5 WHERE GD5_NRSEQG = '" + cNrSeqG + "' AND GD5.D_E_L_E_T_ <> '*' AND GD5_FILIAL = '" + xFilial("GD5") + "'"
cSqlVal += "UNION "
cSqlVal += "SELECT (GD6.GD6_VALDES * GD6.GD6_QTDDES ) VALDES FROM " + RetSqlName("GD6") + " GD6 WHERE GD6_NRSEQG = '" + cNrSeqG + "' AND GD6.D_E_L_E_T_ <> '*' AND GD6_FILIAL = '" + xFilial("GD6") + "'"
cSqlVal += "UNION "
cSqlVal += "SELECT (GD7.GD7_VALDES * GD7.GD7_QTDDES ) VALDES FROM " + RetSqlName("GD7") + " GD7 WHERE GD7_NRSEQG = '" + cNrSeqG + "' AND GD7.D_E_L_E_T_ <> '*' AND GD7_FILIAL = '" + xFilial("GD7") + "'"
endif

cSqlVal := ChangeQuery(cSqlVal)
TCQUERY cSqlVal NEW ALIAS "QRYVAL"

DBSelectArea("QRYVAL")

While !(QRYVAL->(EOF()))
 nValGui += QRYVAL->VALDES
 QRYVAL->(DBSkip())
End

nTValGui+=nValGui
QRYVAL->(DBCloseArea())

RestArea(aOldArea)

Return(nValGui)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjustaSXB  บAutor  ณMicrosiga           บ Data ณ  08/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AjustaSXB()

SXB->(DbSetOrder(1))
If SXB->(DbSeek("HSP007"+"1"+"01"+"RE")) .and. alltrim(SXB->XB_CONTEM)<>"SX5"
	RecLock("SXB",.F.)
	SXB->XB_CONTEM:= "SX5"
	SXB->(MsUnlock())

EndIf

If SXB->(DbSeek("HSP007"+"5"+"01")) .and. alltrim(SXB->XB_CONTEM)<>"HS_SXBSTT()"
	RecLock("SXB",.F.)
	SXB->XB_CONTEM:= "HS_SXBSTT()"
	SXB->(MsUnlock())

EndIf

Return