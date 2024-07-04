#Include "Protheus.ch"
#Include "REPORT.ch"
#Include "FISR026.ch"
//-------------------------------------------------------------------
/*/ {Protheus.doc} FISR026
Relatorio CAT207

@author Flavio Luiz Vicco
@since 03/02/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Function FISR026()
Local oReport
Local lProcessa := .T.
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

If lVerpesssen
	If !TRepInUse()
		Alert(STR0001) //"A impressão em TREPORT deverá estar habilitada. Favor verificar o parâmetro MV_TREPORT."
		lProcessa := .F.
	EndIf

	If lProcessa
		oReport:= ReportDef()
		oReport:PrintDialog()
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/ {Protheus.doc} ReportDef
Interface de impressao

@author Flavio Luiz Vicco
@since 03/02/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oReport
Local oEmpresa
Local oPrcMd1
Local oPrcMd2
Local oPrcMd3
Local oPrcMd4
Local oPrcMd5
Local oPrcMd6
Local oEnqLeg
Local oLivros
Local cAliasSFT := GetNextAlias()
Local cAliasPr1 := GetNextAlias()
Local cAliasPr2 := GetNextAlias()
Local cAliasPr3 := GetNextAlias()
Local cAliasPr4 := GetNextAlias()
Local cAliasPr5 := GetNextAlias()
Local cAliasPr6 := GetNextAlias()

/*Private VALICMENT := 0
Private VALICMSAI := 0
Private VALCONTENT:= 0
Private BASEICMENT:= 0
Private VALCONTSAI:= 0
Private BASEICMSAI:= 0
*/
oReport:=TReport():New("FISR026","CAT207","FISR026",{|oReport| ReportPrint(oReport,cAliasSFT,cAliasPr1,cAliasPr2,cAliasPr3,cAliasPr4,cAliasPr5,cAliasPr6)},STR0002) //"Este relatório tem como objetivo apresentar os dados gerados para conferencia da CAT207."
oReport:SetTotalInLine(.F.)
oReport:SetLandscape()
oReport:HideParamPage()
oReport:DisableOrientation()
oReport:SetUseGC(.T.)

Pergunte(oReport:uParam,.F.)

oEmpresa:= TRSection():New(oReport,"Informações da empresa",{"SM0"})
oEmpresa:SetReadOnly()
oEmpresa:SetNoFilter("SM0")

oPrcMd1:=TRSection():New(oReport,"A. ICMS Entradas",{cAliasPr1})
oPrcMd1:SetTotalInLine(.F.)
oPrcMd1:SetReadOnly()
TRCell():New(oPrcMd1,"FT_NFISCAL","SFT","Doc. NF",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd1,"FT_SERIE"  ,"SFT","Serie"  ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd1,"FT_ITEM"   ,"SFT","Item NF",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd1,"FT_CLIEFOR","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd1,"FT_LOJA"   ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd1,"FT_ENTRADA","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd1,"FT_CFOP"   ,"SFT","CFOP"   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd1,"FT_TIPO"   ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd1,"A2_NOME"   ,"SA2",/*Title*/,/*Picture*/,         20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd1,"A2_CGC"    ,"SA2",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd1,"A2_INSCR"  ,"SA2",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd1,"A2_EST"    ,"SA2","UF"     ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd1,"A2_CEP"    ,"SA2",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd1,"A2_CODPAIS","SA2","Pais"   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd1,"DESC"      ,     ,/*Title*/,/*Picture*/,         15,/*lPixel*/,  {|| Posicione("SYA",1,xFilial("SYA")+SA2->A2_PAIS,"YA_DESCR") })
TRCell():New(oPrcMd1,"FT_BASEICM","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd1,"FT_ALIQICM","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd1,"FT_VALICM" ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd1,"FT_VALCONT","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oBreak1 := TRBreak():New(oPrcMd1,{|| },"A. ICMS Entradas",.F.)
TRFunction():New(oPrcMd1:Cell("FT_VALICM"),"VALICMENT","SUM",oBreak1,/*cTitulo*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

oPrcMd2:=TRSection():New(oReport,"B. ICMS Saidas",{cAliasPr2})
oPrcMd2:SetTotalInLine(.F.)
oPrcMd2:SetReadOnly()
TRCell():New(oPrcMd2,"FT_NFISCAL","SFT","Doc. NF",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd2,"FT_SERIE"  ,"SFT","Serie"  ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd2,"FT_ITEM"   ,"SFT","Item NF",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd2,"FT_CLIEFOR","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd2,"FT_LOJA"   ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd2,"FT_ENTRADA","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd2,"FT_CFOP"   ,"SFT","CFOP"   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd2,"FT_TIPO"   ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd2,"A1_NOME"   ,"SA1",/*Title*/,/*Picture*/,         20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd2,"A1_CGC"    ,"SA1",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd2,"A1_INSCR"  ,"SA1",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd2,"A1_EST"    ,"SA1","UF"     ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd2,"A1_CEP"    ,"SA1",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd2,"A1_CODPAIS","SA1","Pais"   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd2,"DESC"      ,     ,/*Title*/,/*Picture*/,         15,/*lPixel*/,  {|| Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR") })
TRCell():New(oPrcMd2,"FT_BASEICM","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd2,"FT_ALIQICM","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd2,"FT_VALICM" ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd2,"FT_VALCONT","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oBreak2 := TRBreak():New(oPrcMd2,{|| },"B. ICMS Saidas",.F.)
TRFunction():New(oPrcMd2:Cell("FT_VALICM" ),"VALICMSAI","SUM",oBreak2,/*cTitulo*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

oPrcMd3:=TRSection():New(oReport,"C. Valor Contabil Entradas",{cAliasPr3})
oPrcMd3:SetTotalInLine(.F.)
oPrcMd3:SetReadOnly()
TRCell():New(oPrcMd3,"FT_NFISCAL","SFT","Doc. NF",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd3,"FT_SERIE"  ,"SFT","Serie"  ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd3,"FT_ITEM"   ,"SFT","Item NF",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd3,"FT_CLIEFOR","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd3,"FT_LOJA"   ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd3,"FT_ENTRADA","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd3,"FT_CFOP"   ,"SFT","CFOP"   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd3,"FT_TIPO"   ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd3,"A2_NOME"   ,"SA2",/*Title*/,/*Picture*/,         20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd3,"A2_CGC"    ,"SA2",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd3,"A2_INSCR"  ,"SA2",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd3,"A2_EST"    ,"SA2","UF"     ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd3,"A2_CEP"    ,"SA2",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd3,"A2_CODPAIS","SA2","Pais"   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd3,"DESC"      ,     ,/*Title*/,/*Picture*/,         15,/*lPixel*/,  {|| Posicione("SYA",1,xFilial("SYA")+SA2->A2_PAIS,"YA_DESCR") })
TRCell():New(oPrcMd3,"FT_BASEICM","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd3,"FT_ALIQICM","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd3,"FT_VALICM" ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd3,"FT_VALCONT","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oBreak3 := TRBreak():New(oPrcMd3,{|| },"C. Valor Contabil Entradas",.F.)
TRFunction():New(oPrcMd3:Cell("FT_VALCONT"),"VALCONTENT","SUM",oBreak3,/*cTitulo*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

oPrcMd4:=TRSection():New(oReport,"D. Base calculo Entradas",{cAliasPr4})
oPrcMd4:SetTotalInLine(.F.)
oPrcMd4:SetReadOnly()
TRCell():New(oPrcMd4,"FT_NFISCAL","SFT","Doc. NF",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd4,"FT_SERIE"  ,"SFT","Serie"  ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd4,"FT_ITEM"   ,"SFT","Item NF",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd4,"FT_CLIEFOR","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd4,"FT_LOJA"   ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd4,"FT_ENTRADA","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd4,"FT_CFOP"   ,"SFT","CFOP"   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd4,"FT_TIPO"   ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd4,"A2_NOME"   ,"SA2",/*Title*/,/*Picture*/,         20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd4,"A2_CGC"    ,"SA2",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd4,"A2_INSCR"  ,"SA2",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd4,"A2_EST"    ,"SA2","UF"     ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd4,"A2_CEP"    ,"SA2",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd4,"A2_CODPAIS","SA2","Pais"   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd4,"DESC"      ,     ,/*Title*/,/*Picture*/,         15,/*lPixel*/,  {|| Posicione("SYA",1,xFilial("SYA")+SA2->A2_PAIS,"YA_DESCR") })
TRCell():New(oPrcMd4,"FT_BASEICM","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd4,"FT_ALIQICM","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd4,"FT_VALICM" ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd4,"FT_VALCONT","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oBreak4 := TRBreak():New(oPrcMd4,{|| },"D. Base calculo Entradas",.F.)
TRFunction():New(oPrcMd4:Cell("FT_BASEICM"),"BASEICMENT","SUM",oBreak4,/*cTitulo*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

oPrcMd5:=TRSection():New(oReport,"E. Valor Contabil Saidas",{cAliasPr5})
oPrcMd5:SetTotalInLine(.F.)
oPrcMd5:SetReadOnly()
TRCell():New(oPrcMd5,"FT_NFISCAL","SFT","Doc. NF",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd5,"FT_SERIE"  ,"SFT","Serie"  ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd5,"FT_ITEM"   ,"SFT","Item NF",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd5,"FT_CLIEFOR","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd5,"FT_LOJA"   ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd5,"FT_ENTRADA","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd5,"FT_CFOP"   ,"SFT","CFOP"   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd5,"FT_TIPO"   ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd5,"A1_NOME"   ,"SA1",/*Title*/,/*Picture*/,         20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd5,"A1_CGC"    ,"SA1",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd5,"A1_INSCR"  ,"SA1",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd5,"A1_EST"    ,"SA1","UF"     ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd5,"A1_CEP"    ,"SA1",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd5,"A1_CODPAIS","SA1","Pais"   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd5,"DESC"      ,     ,/*Title*/,/*Picture*/,         15,/*lPixel*/,  {|| Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR") })
TRCell():New(oPrcMd5,"FT_BASEICM","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd5,"FT_ALIQICM","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd5,"FT_VALICM" ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd5,"FT_VALCONT","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oBreak5 := TRBreak():New(oPrcMd5,{|| },"E. Valor Contabil Saidas",.F.)
TRFunction():New(oPrcMd5:Cell("FT_VALCONT"),"VALCONTSAI","SUM",oBreak5,/*cTitulo*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

oPrcMd6:=TRSection():New(oReport,"F. Base calculo saidas",{cAliasPr6})
oPrcMd6:SetTotalInLine(.F.)
oPrcMd6:SetReadOnly()
TRCell():New(oPrcMd6,"FT_NFISCAL","SFT","Doc. NF",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd6,"FT_SERIE"  ,"SFT","Serie"  ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd6,"FT_ITEM"   ,"SFT","Item NF",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd6,"FT_CLIEFOR","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd6,"FT_LOJA"   ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd6,"FT_ENTRADA","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd6,"FT_CFOP"   ,"SFT","CFOP"   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd6,"FT_TIPO"   ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd6,"A1_NOME"   ,"SA1",/*Title*/,/*Picture*/,         20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd6,"A1_CGC"    ,"SA1",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd6,"A1_INSCR"  ,"SA1",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd6,"A1_EST"    ,"SA1","UF"     ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd6,"A1_CEP"    ,"SA1",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd6,"A1_CODPAIS","SA1","Pais"   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd6,"DESC"      ,     ,/*Title*/,/*Picture*/,         15,/*lPixel*/,  {|| Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR") })
TRCell():New(oPrcMd6,"FT_BASEICM","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd6,"FT_ALIQICM","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd6,"FT_VALICM" ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oPrcMd6,"FT_VALCONT","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oBreak6 := TRBreak():New(oPrcMd6,{|| },"F. Base calculo saidas",.F.)
TRFunction():New(oPrcMd6:Cell("FT_BASEICM"),"BASEICMSAI","SUM",oBreak6,/*cTitulo*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

oEnqLeg:=TRSection():New(oReport,"Enq.Legal",{cAliasSFT})
oEnqLeg:SetReadOnly()
oEnqLeg:SetLineStyle()
TRCell():New(oEnqLeg,"CFF_CODLEG","CFF",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnqLeg,"CFF_CODIGO","CFF",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnqLeg,"CFF_ANEXO" ,"CFF",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnqLeg,"CFF_ART"   ,"CFF",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnqLeg,"CFF_INC"   ,"CFF",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnqLeg,"CFF_ALIN"  ,"CFF",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnqLeg,"CFF_PRG"   ,"CFF",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnqLeg,"CFF_ITM"   ,"CFF",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnqLeg,"CFF_LTR"   ,"CFF",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oEnqLeg,"CFF_OBS"   ,"CFF",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
  
oLivros:=TRSection():New(oEnqLeg,"Livros Fiscais",{cAliasSFT})
oLivros:SetTotalInLine(.F.)
oLivros:SetReadOnly()
TRCell():New(oLivros,"FT_NFISCAL","SFT","Doc. NF",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLivros,"FT_SERIE"  ,"SFT","Serie"  ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLivros,"FT_ITEM"   ,"SFT","Item NF",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLivros,"FT_CLIEFOR","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLivros,"FT_LOJA"   ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLivros,"FT_ENTRADA","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLivros,"FT_CFOP"   ,"SFT","CFOP"   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLivros,"FT_TIPO"   ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLivros,"A1_NOME"   ,"SA1",/*Title*/,/*Picture*/,         20,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLivros,"A1_CGC"    ,"SA1",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLivros,"A1_INSCR"  ,"SA1",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLivros,"A1_EST"    ,"SA1","UF"     ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLivros,"A1_CEP"    ,"SA1",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLivros,"A1_CODPAIS","SA1","Pais"   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLivros,"YA_DESCR"  ,"SYA",/*Title*/,/*Picture*/,         15,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLivros,"FT_BASEICM","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLivros,"FT_ALIQICM","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLivros,"FT_VALICM" ,"SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oLivros,"FT_VALCONT","SFT",/*Title*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRFunction():New(oLivros:Cell("FT_BASEICM"),/*cID*/,"SUM",/*oBreak*/,/*cTitulo*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oLivros:Cell("FT_VALICM" ),/*cID*/,"SUM",/*oBreak*/,/*cTitulo*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)

Return(oReport)

//-------------------------------------------------------------------
/*/ {Protheus.doc} ReportPrint
Impressao do relatorio

@author Flavio Luiz Vicco
@since 03/02/2015
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasSFT,cAliasPr1,cAliasPr2,cAliasPr3,cAliasPr4,cAliasPr5,cAliasPr6)
Local oEmpresa  := oReport:Section(1)
Local oPrcMd1   := oReport:Section(2)
Local oPrcMd2   := oReport:Section(3)
Local oPrcMd3   := oReport:Section(4)
Local oPrcMd4   := oReport:Section(5)
Local oPrcMd5   := oReport:Section(6)
Local oPrcMd6   := oReport:Section(7)
Local oEnqLeg   := oReport:Section(8)
Local oLivros   := oReport:Section(8):Section(1)
Local oTFont    := TFont():New('Arial',,11,,.T.)
Local cFilBak   := cFilAnt
Local aFilsCalc := {}
Local nForFilial:= 0
Local aAreaSM0  := SM0->(GetArea())
Local dDataDe   := ctod("01/"+substr(MV_PAR01,1,2)+"/"+substr(MV_PAR01,3,4))
Local dDataAte  := LastDate(dDataDe)
Local cNrLivro  := MV_PAR02
Local cPic      := PesqPict("SFT","FT_VALICM")
Local nPercMed  := 0
Local cCFOPSom  := "1101','1102','1116','1117','1118','1120','1121','1122','1126','1917','1151','1152','1153','1154','1251','1252','1253','1254','1255','1256','1257','1301','1302','1303','1304','1305','1306','1351','1352','1353','1354','1355','1356','1360','1931','1932','1401','1403','1651','1652','1408','1409','1658','1659','1653','1910','1124','1125','2101','2102','2116','2117','2118','2120','2121','2122','2126','2917','2151','2152','2153','2154','2251','2252','2253','2254','2255','2256','2257','2301','2302','2303','2304','2305','2306','2351','2352','2353','2354','2355','2356','2931','2932','2401','2403','2651','2652','2408','2409','2658','2659','2653','2910','2124','2125','3101','3102','3126','3127','3651','3652','3251','3301','3351','3352','3353','3354','3355','3356','3653','3930"
Local cCFOPSub  := "5201','5202','5205','5206','5207','5208','5209','5210','5918','5410','5411','5660','5661','5662','6201','6202','6205','6206','6207','6208','6209','6210','6918','6410','6411','6660','6661','6662','7201','7202','7205','7206','7207','7210','7211','7930"
Local cValContEn:= "1101','1102','1116','1117','1118','1120','1121','1122','1126','1917','1151','1152','1153','1154','1351','1352','1353','1354','1355','1356','1360','1931','1932','1401','1403','1651','1652','1408','1409','1658','1659','1910','1124','1125','2101','2102','2116','2117','2118','2120','2121','2122','2126','2917','2151','2152','2153','2154','2351','2352','2353','2354','2355','2356','2931','2932','2401','2403','2651','2652','2408','2409','2658','2659','2910','2124','2125','3101','3102','3126','3127','3651','3652','3351','3352','3353','3354','3355','3356','3930"
Local cBasCalcEn:= "1251','1252','1253','1254','1255','1256','1257','1301','1302','1303','1304','1305','1306','1653','2251','2252','2253','2254','2255','2256','2257','2301','2302','2303','2304','2305','2306','2653','3251','3301','3653"
Local cValContSa:= "5201','5202','5205','5206','5207','5208','5209','5210','5918','5410','5411','5660','5661','6201','6202','6205','6206','6207','6208','6209','6210','6918','6410','6411','6660','6661','7201','7202','7205','7206','7207','7210','7211','7930"
Local cBasCalcSa:= "5662','6662"
Local dDtIni    := dDataDe
Local dDtFin    := dDataAte
Local VALICMENT := 0
Local VALICMSAI := 0
Local VALCONTENT:= 0
Local BASEICMENT:= 0
Local VALCONTSAI:= 0
Local BASEICMSAI:= 0
Local cCFFJoin  := Iif(CFF->(FieldPos('CFF_TIPO')) > 0, "% AND ((SFT.FT_TIPO = CFF.CFF_TIPO) OR (CFF.CFF_TIPO = 'N' AND SFT.FT_TIPO = '')) AND SFT.FT_TIPOMOV = CFF.CFF_TPMOV %", "")
/*
Consultoria Tributaria - TRBQAU
Entendemos que para obter os valores de "Saida" e "Entrada" aplicadas nas formulas de obtencao do Percentual Medio de Credito devera obedecer a regra determinada no o item 7,item 2o, art. 30 da DDTT do RICMS SP conforme descrito a seguir:
Para a geracao do credito acumulado do imposto deverao ser consideradas as operacoes de:
Se o pedido de apropriacao do credito for solicitado no ano posterior, de Janeiro a Dezembro do ano da apropriacao.
Se o pedido de apropriacao do credito for solicitado ate  junho,       de Janeiro a Dezembro do ano anterior.
Se o pedido de apropriacao do credito for solicitado apos junho,       de Janeiro a mes anterior do ano da apropriacao.
*/
If Year(dDataBase) > Year(dDataDe)
	dDtIni := ctod("01/01/"+StrZero(Year(dDataAte),4))
	dDtFin := ctod("31/12/"+StrZero(Year(dDataAte),4))
Else
	If Month(dDataBase) <= 6
		dDtIni := ctod("01/01/"+StrZero(Year(dDataAte)-1,4))
		dDtFin := ctod("31/12/"+StrZero(Year(dDataAte)-1,4))
	Else
		dDtIni := ctod("01/01/"+StrZero(Year(dDataAte),4))
		dDtFin := LastDate(ctod("01/"+StrZero(Month(dDataAte)-1,2)+"/"+StrZero(Year(dDataAte),4)))
	EndIf
EndIf

SFT->(DbSetOrder(2))

//-- Seleciona Filiais
If MV_PAR03==1
	aFilsCalc := MatFilCalc(.T.)
Else
	aFilsCalc := {{.T.,cFilAnt}}
EndIf

For nForFilial := 1 To Len(aFilsCalc)
	If aFilsCalc[ nForFilial, 1 ]
		cFilAnt := aFilsCalc[ nForFilial, 2 ]
		SM0->(DbSetOrder(1))
		SM0->(DbSeek(cEmpAnt + cFilAnt))
		MakeSqlExpr(oReport:uParam)
		//-- ICMS Entradas
		oPrcMd1:BeginQuery()
		BeginSql Alias cAliasPr1
			SELECT
				SFT.FT_FILIAL,  SFT.FT_ENTRADA, SFT.FT_ESPECIE, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_ITEM,
				SFT.FT_CLIEFOR, SFT.FT_LOJA,    SFT.FT_DTCANC,  SFT.FT_TIPO,    SFT.FT_ESTADO,
				SFT.FT_BASEICM, SFT.FT_ALIQICM, SFT.FT_VALICM,  SFT.FT_VALCONT, SFT.FT_CFOP,
				SA2.A2_NOME , SA2.A2_CGC, SA2.A2_INSCR, SA2.A2_EST, SA2.A2_CEP, SA2.A2_CODPAIS, SA2.A2_PAIS,
				SYA.YA_CODGI, SYA.YA_DESCR
			FROM 
				%Table:SFT% SFT 
				INNER JOIN %Table:SA2% SA2 ON SA2.A2_FILIAL = %xFilial:SA2% AND SFT.FT_CLIEFOR = SA2.A2_COD AND SFT.FT_LOJA = SA2.A2_LOJA AND SA2.%NotDel%
				LEFT OUTER JOIN %Table:SYA% SYA ON SYA.YA_FILIAL = %xFilial:SYA% AND SYA.%NotDel% AND SYA.YA_CODGI = SA2.A2_PAIS				
			WHERE 
				SFT.FT_FILIAL=%xFilial:SFT% AND 
				SFT.FT_ENTRADA>=%Exp:dDtIni% AND
				SFT.FT_ENTRADA<=%Exp:dDtFin% AND
				SFT.FT_DTCANC = %Exp:Dtos(Ctod(''))% AND  
				SFT.FT_CFOP IN(%Exp:cCFOPSom%) AND
				SFT.%NotDel%
		EndSql
		oPrcMd1:EndQuery()
		//-- ICMS Saidas
		oPrcMd2:BeginQuery()
		BeginSql Alias cAliasPr2
			SELECT
				SFT.FT_FILIAL,  SFT.FT_ENTRADA, SFT.FT_ESPECIE, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_ITEM,
				SFT.FT_CLIEFOR, SFT.FT_LOJA,    SFT.FT_DTCANC,  SFT.FT_TIPO,    SFT.FT_ESTADO,
				SFT.FT_BASEICM, SFT.FT_ALIQICM, SFT.FT_VALICM,  SFT.FT_VALCONT, SFT.FT_CFOP,
				SA1.A1_NOME , SA1.A1_CGC, SA1.A1_INSCR, SA1.A1_EST, SA1.A1_CEP, SA1.A1_CODPAIS, SA1.A1_PAIS,
				SYA.YA_CODGI, SYA.YA_DESCR				
			FROM 
				%Table:SFT% SFT 
				LEFT OUTER JOIN %Table:SA1% SA1 ON SA1.A1_FILIAL = %xFilial:SA1% AND SFT.FT_CLIEFOR = SA1.A1_COD AND SFT.FT_LOJA = SA1.A1_LOJA AND SA1.%NotDel%
				LEFT OUTER JOIN %Table:SYA% SYA ON SYA.YA_FILIAL = %xFilial:SYA% AND SYA.%NotDel% AND SYA.YA_CODGI = SA1.A1_PAIS					
			WHERE 
				SFT.FT_FILIAL=%xFilial:SFT% AND 
				SFT.FT_ENTRADA>=%Exp:dDtIni% AND
				SFT.FT_ENTRADA<=%Exp:dDtFin% AND
				SFT.FT_DTCANC = %Exp:Dtos(Ctod(''))% AND  
				SFT.FT_CFOP IN(%Exp:cCFOPSub%) AND
				SFT.%NotDel%
		EndSql
		oPrcMd2:EndQuery()
		//-- Valor Contabil Entradas
		oPrcMd3:BeginQuery()
		BeginSql Alias cAliasPr3
			SELECT
				SFT.FT_FILIAL,  SFT.FT_ENTRADA, SFT.FT_ESPECIE, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_ITEM,
				SFT.FT_CLIEFOR, SFT.FT_LOJA,    SFT.FT_DTCANC,  SFT.FT_TIPO,    SFT.FT_ESTADO,
				SFT.FT_BASEICM, SFT.FT_ALIQICM, SFT.FT_VALICM,  SFT.FT_VALCONT, SFT.FT_CFOP,
				SA2.A2_NOME , SA2.A2_CGC, SA2.A2_INSCR, SA2.A2_EST, SA2.A2_CEP, SA2.A2_CODPAIS, SA2.A2_PAIS,
				SYA.YA_CODGI, SYA.YA_DESCR				
			FROM 
				%Table:SFT% SFT 
				INNER JOIN %Table:SA2% SA2 ON SA2.A2_FILIAL = %xFilial:SA2% AND SFT.FT_CLIEFOR = SA2.A2_COD AND SFT.FT_LOJA = SA2.A2_LOJA AND SA2.%NotDel%
				LEFT OUTER JOIN %Table:SYA% SYA ON SYA.YA_FILIAL = %xFilial:SYA% AND SYA.%NotDel% AND SYA.YA_CODGI = SA2.A2_PAIS					
			WHERE 
				SFT.FT_FILIAL=%xFilial:SFT% AND 
				SFT.FT_ENTRADA>=%Exp:dDtIni% AND
				SFT.FT_ENTRADA<=%Exp:dDtFin% AND
				SFT.FT_DTCANC = %Exp:Dtos(Ctod(''))% AND  
				SFT.FT_CFOP IN(%Exp:cValContEn%) AND
				SFT.%NotDel%
		EndSql
		oPrcMd3:EndQuery()
		//-- Base calculo Entradas
		oPrcMd4:BeginQuery()
		BeginSql Alias cAliasPr4
			SELECT
				SFT.FT_FILIAL,  SFT.FT_ENTRADA, SFT.FT_ESPECIE, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_ITEM,
				SFT.FT_CLIEFOR, SFT.FT_LOJA,    SFT.FT_DTCANC,  SFT.FT_TIPO,    SFT.FT_ESTADO,
				SFT.FT_BASEICM, SFT.FT_ALIQICM, SFT.FT_VALICM,  SFT.FT_VALCONT, SFT.FT_CFOP,
				SA2.A2_NOME , SA2.A2_CGC, SA2.A2_INSCR, SA2.A2_EST, SA2.A2_CEP, SA2.A2_CODPAIS, SA2.A2_PAIS,
				SYA.YA_CODGI, SYA.YA_DESCR				
			FROM 
				%Table:SFT% SFT 
				INNER JOIN %Table:SA2% SA2 ON SA2.A2_FILIAL = %xFilial:SA2% AND SFT.FT_CLIEFOR = SA2.A2_COD AND SFT.FT_LOJA = SA2.A2_LOJA AND SA2.%NotDel%
				LEFT OUTER JOIN %Table:SYA% SYA ON SYA.YA_FILIAL = %xFilial:SYA% AND SYA.%NotDel% AND SYA.YA_CODGI = SA2.A2_PAIS						
			WHERE 
				SFT.FT_FILIAL=%xFilial:SFT% AND 
				SFT.FT_ENTRADA>=%Exp:dDtIni% AND
				SFT.FT_ENTRADA<=%Exp:dDtFin% AND
				SFT.FT_DTCANC = %Exp:Dtos(Ctod(''))% AND  
				SFT.FT_CFOP IN(%Exp:cBasCalcEn%) AND
				SFT.%NotDel%
		EndSql
		oPrcMd4:EndQuery()
		//-- Valor Contabil Saidas
		oPrcMd5:BeginQuery()
		BeginSql Alias cAliasPr5
			SELECT
				SFT.FT_FILIAL,  SFT.FT_ENTRADA, SFT.FT_ESPECIE, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_ITEM,
				SFT.FT_CLIEFOR, SFT.FT_LOJA,    SFT.FT_DTCANC,  SFT.FT_TIPO,    SFT.FT_ESTADO,
				SFT.FT_BASEICM, SFT.FT_ALIQICM, SFT.FT_VALICM,  SFT.FT_VALCONT, SFT.FT_CFOP,
				SA1.A1_NOME, SA1.A1_CGC, SA1.A1_INSCR, SA1.A1_EST, SA1.A1_CEP, SA1.A1_CODPAIS, SA1.A1_PAIS,
				SYA.YA_CODGI, SYA.YA_DESCR				
			FROM 
				%Table:SFT% SFT 
				INNER JOIN %Table:SA1% SA1 ON SA1.A1_FILIAL = %xFilial:SA1% AND SFT.FT_CLIEFOR = SA1.A1_COD AND SFT.FT_LOJA = SA1.A1_LOJA AND SA1.%NotDel%
				LEFT OUTER JOIN %Table:SYA% SYA ON SYA.YA_FILIAL = %xFilial:SYA% AND SYA.%NotDel% AND SYA.YA_CODGI = SA1.A1_PAIS					
			WHERE 
				SFT.FT_FILIAL=%xFilial:SFT% AND 
				SFT.FT_ENTRADA>=%Exp:dDtIni% AND
				SFT.FT_ENTRADA<=%Exp:dDtFin% AND
				SFT.FT_DTCANC = %Exp:Dtos(Ctod(''))% AND  
				SFT.FT_CFOP IN(%Exp:cValContSa%) AND
				SFT.%NotDel%
		EndSql
		oPrcMd5:EndQuery()
		//-- Base calculo saidas
		oPrcMd6:BeginQuery()
		BeginSql Alias cAliasPr6
			SELECT
				SFT.FT_FILIAL,  SFT.FT_ENTRADA, SFT.FT_ESPECIE, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_ITEM,
				SFT.FT_CLIEFOR, SFT.FT_LOJA,    SFT.FT_DTCANC,  SFT.FT_TIPO,    SFT.FT_ESTADO,
				SFT.FT_BASEICM, SFT.FT_ALIQICM, SFT.FT_VALICM,  SFT.FT_VALCONT, SFT.FT_CFOP,
				SA1.A1_NOME, SA1.A1_CGC, SA1.A1_INSCR, SA1.A1_EST, SA1.A1_CEP, SA1.A1_CODPAIS, SA1.A1_PAIS,
				SYA.YA_CODGI, SYA.YA_DESCR				
			FROM 
				%Table:SFT% SFT 
				INNER JOIN %Table:SA1% SA1 ON SA1.A1_FILIAL = %xFilial:SA1% AND SFT.FT_CLIEFOR = SA1.A1_COD AND SFT.FT_LOJA = SA1.A1_LOJA AND SA1.%NotDel%
				LEFT OUTER JOIN %Table:SYA% SYA ON SYA.YA_FILIAL = %xFilial:SYA% AND SYA.%NotDel% AND SYA.YA_CODGI = SA1.A1_PAIS					
			WHERE 
				SFT.FT_FILIAL=%xFilial:SFT% AND 
				SFT.FT_ENTRADA>=%Exp:dDtIni% AND
				SFT.FT_ENTRADA<=%Exp:dDtFin% AND
				SFT.FT_DTCANC = %Exp:Dtos(Ctod(''))% AND  
				SFT.FT_CFOP IN(%Exp:cBasCalcSa%) AND
				SFT.%NotDel%
		EndSql
		oPrcMd6:EndQuery()
		//-- Doctos Fiscais por Codigo Enquadramento Legal
		oEnqLeg:BeginQuery()
		BeginSql Alias cAliasSFT

			SELECT
				SFT.FT_FILIAL,  SFT.FT_ENTRADA, SFT.FT_ESPECIE, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_ITEM,
				SFT.FT_CLIEFOR, SFT.FT_LOJA,    SFT.FT_DTCANC,  SFT.FT_TIPO,    SFT.FT_ESTADO, SFT.FT_TIPOMOV,
				SFT.FT_BASEICM, SFT.FT_ALIQICM, SFT.FT_VALICM,  SFT.FT_CFOP,     SFT.FT_VALCONT, 
				CFF_FILIAL,     CFF.CFF_CODLEG, CFF.CFF_CODIGO, CFF.CFF_ANEXO,  CFF.CFF_ART,
				CFF.CFF_INC,    CFF.CFF_ALIN,   CFF.CFF_PRG,    CFF.CFF_ITM,    CFF.CFF_LTR,
				CFF.CFF_OBS,
				SA1.A1_NOME A1_NOME, SA1.A1_CGC, SA1.A1_INSCR, SA1.A1_EST, SA1.A1_CEP, SA1.A1_CODPAIS, SA1.A1_PAIS,
				SYA.YA_CODGI, SYA.YA_DESCR
			FROM %Table:SFT% SFT
			
			INNER JOIN	%Table:CFF% CFF	ON CFF.CFF_NUMDOC=SFT.FT_NFISCAL AND CFF.CFF_SERIE =SFT.FT_SERIE AND CFF.CFF_CLIFOR=SFT.FT_CLIEFOR AND CFF.CFF_LOJA  =SFT.FT_LOJA AND SFT.FT_ITEM = CFF.CFF_ITEMNF %Exp:cCFFJoin% AND CFF.%NotDel%
			iNNER JOIN %Table:SA1% SA1 ON SA1.A1_FILIAL = %xFilial:SA1% AND SFT.FT_CLIEFOR = SA1.A1_COD AND SFT.FT_LOJA = SA1.A1_LOJA AND SA1.%NotDel%
			LEFT OUTER JOIN %Table:SYA% SYA ON SYA.YA_FILIAL = %xFilial:SYA% AND SYA.%NotDel% AND SYA.YA_CODGI = SA1.A1_PAIS
			WHERE
				SFT.FT_FILIAL=%xFilial:SFT% AND
				SFT.FT_ENTRADA>=%Exp:dDataDe% AND
				SFT.FT_ENTRADA<=%Exp:dDataAte% AND
				SFT.FT_DTCANC = %Exp:Dtos(Ctod(''))% AND
				SFT.FT_TIPO<>"D" AND
				SFT.%NotDel% AND
				SFT.FT_TIPOMOV = 'S'

				UNION ALL

				SELECT
				SFT.FT_FILIAL,  SFT.FT_ENTRADA, SFT.FT_ESPECIE, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_ITEM,
				SFT.FT_CLIEFOR, SFT.FT_LOJA,    SFT.FT_DTCANC,  SFT.FT_TIPO,    SFT.FT_ESTADO, SFT.FT_TIPOMOV,
				SFT.FT_BASEICM, SFT.FT_ALIQICM, SFT.FT_VALICM,  SFT.FT_CFOP,     SFT.FT_VALCONT,
				CFF_FILIAL,     CFF.CFF_CODLEG, CFF.CFF_CODIGO, CFF.CFF_ANEXO,  CFF.CFF_ART,
				CFF.CFF_INC,    CFF.CFF_ALIN,   CFF.CFF_PRG,    CFF.CFF_ITM,    CFF.CFF_LTR,
				CFF.CFF_OBS,
				SA2.A2_NOME A1_NOME, SA2.A2_CGC A1_CGC, SA2.A2_INSCR A1_INSC, SA2.A2_EST A1_EST, SA2.A2_CEP A1_CEP, SA2.A2_CODPAIS A1_CODPAIS, SA2.A2_PAIS A1_PAIS,
				SYA.YA_CODGI, SYA.YA_DESCR
			FROM %Table:SFT% SFT
			
			INNER JOIN	%Table:CFF% CFF	ON CFF.CFF_NUMDOC=SFT.FT_NFISCAL AND CFF.CFF_SERIE =SFT.FT_SERIE AND CFF.CFF_CLIFOR=SFT.FT_CLIEFOR AND CFF.CFF_LOJA = SFT.FT_LOJA  AND SFT.FT_ITEM = CFF.CFF_ITEMNF %Exp:cCFFJoin% AND CFF.%NotDel%
			INNER JOIN %Table:SA2% SA2 ON SA2.A2_FILIAL = %xFilial:SA2% AND SFT.FT_CLIEFOR = SA2.A2_COD AND SFT.FT_LOJA = SA2.A2_LOJA AND SA2.%NotDel%
			LEFT OUTER JOIN %Table:SYA% SYA ON SYA.YA_FILIAL = %xFilial:SYA% AND SYA.%NotDel% AND SYA.YA_CODGI = SA2.A2_PAIS
			WHERE
				SFT.FT_FILIAL=%xFilial:SFT% AND
				SFT.FT_ENTRADA>=%Exp:dDataDe% AND
				SFT.FT_ENTRADA<=%Exp:dDataAte% AND
				SFT.FT_DTCANC = %Exp:Dtos(Ctod(''))% AND
				SFT.FT_TIPO<>"D" AND
				SFT.%NotDel% AND
				SFT.FT_TIPOMOV = 'E'

			ORDER BY CFF.CFF_CODLEG

		EndSql
		oEnqLeg:EndQuery()
		oLivros:SetParentQuery()
		oLivros:SetParentFilter({|cParam| xFilial("CFF")+CFF_CODLEG == cParam },{|| (cAliasSFT)->(CFF_FILIAL+CFF_CODLEG)})
		//-- Tabela Livros Fiscais (SFT) -> Relac Tabela Compl.Enq.Legal (CFF)
		oEmpresa:Init()
		oReport:EndPage() //Reinicia Paginas
		oReport:Say(300,20,"Razão Social: "+SM0->M0_NOMECOM,oTFont)
		oReport:Say(350,20,"Endereco: "+AllTrim(SM0->M0_ENDENT)+" Cidade: "+AllTrim(SM0->M0_CIDENT)+" - UF: "+SM0->M0_ESTENT,oTFont)
		oReport:Say(400,20,"CNPJ: "+Transform(SM0->M0_CGC,"@R 99.999.999./9999-99"),oTFont)
		oReport:Say(450,20,"Inscr. Estadual: "+SM0->M0_INSC,oTFont)
		oEmpresa:Finish()
		oReport:SkipLine(10)
		oReport:FatLine()
		oReport:SkipLine(01)
		oPrcMd1:Print()
		oReport:EndPage()
		//
		oPrcMd2:Print()
		oReport:EndPage()
		//
		oPrcMd3:Print()
		oReport:EndPage()
		//
		oPrcMd4:Print()
		oReport:EndPage()
		//
		oPrcMd5:Print()
		oReport:EndPage()
		//
		oPrcMd6:Print()
		oReport:EndPage()
		//
		oReport:SkipLine(01)
		oReport:PrintText( "Percentual medio = ((A - B) / (C + D) - (E + F)) * 100 " )
		oReport:SkipLine(01)
		VALICMENT := oPrcMd1:GetFunction("VALICMENT" ):SectionValue()
		VALICMSAI := oPrcMd2:GetFunction("VALICMSAI" ):SectionValue()
		VALCONTENT:= oPrcMd3:GetFunction("VALCONTENT"):SectionValue()
		BASEICMENT:= oPrcMd4:GetFunction("BASEICMENT"):SectionValue()
		VALCONTSAI:= oPrcMd5:GetFunction("VALCONTSAI"):SectionValue()
		BASEICMSAI:= oPrcMd6:GetFunction("BASEICMSAI"):SectionValue()
		nPercMed := (((VALICMENT) - (VALICMSAI)) / (((VALCONTENT) +(BASEICMENT)) - ((VALCONTSAI) + (BASEICMSAI)))) * 100
		oReport:PrintText(	"((("+AllTrim(Transform(VALICMENT, cPic))+") - ("+AllTrim(Transform(VALICMSAI, cPic))+")) / "+;
		 					"((("+AllTrim(Transform(VALCONTENT,cPic))+") + ("+AllTrim(Transform(BASEICMENT,cPic))+")) - "+;
		 					" (("+AllTrim(Transform(VALCONTSAI,cPic))+") + ("+AllTrim(Transform(BASEICMSAI,cPic))+")))) * 100 = "+AllTrim(Transform(nPercMed,cPic)))
		oReport:EndPage() //Reinicia Paginas
		oEnqLeg:Print()
	EndIf
Next nForFilial

cFilAnt := cFilBak
RestArea(aAreaSM0)
Return
