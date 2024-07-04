#INCLUDE "HSPAHR33.ch"
#include "rwmake.ch"
#include "TopConn.ch"
#INCLUDE "Report.ch"
                          
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR33 บ       ณ Antonio Carlos     บ Data ณ 04/08/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relacao de SAIDA DE PACIENTES NO PERIODO                   บฑฑ
ฑฑบ          ณ Conversใo para relatorios personalizaveis                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR33()

Local oReport
If FindFunction("TRepInUse") .And. TRepInUse()
	pergunte("HSPR33",.T.)
	oReport := ReportDef()
	oReport:PrintDialog()
ELSE                 
	HSPAHR33R3()
EndIF
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 04/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
Local oReport
Local oSection1, oSection2, oSection3
Local oCell
Local oTotaliz1

oReport := TReport():New("HSPAHR33",STR0003,"HSPR33",{|oReport| R33IMP(oReport)},STR0001 + " " + STR0002)  
 //"Saida de Pacientes no Perํodo"### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."

oReport:SetLandscape()         // Imprimir relatorio em formato paisagem
//oReport:SetPortrait()          // Imprimir relatorio em formato retrato
 oReport:SetTotalText(STR0050) // texto impresso antes da somatoria de oTotaliz1 //"Total Geral"
 
 oReport:ParamReadOnly() //Desabilitando Botใo de parโmetros do Relat๓rio.

If MV_PAR09 == 1 /*se ordernar por data utiliza o separador e totalizador*/
 oSection1 := TRSection():New(oReport,STR0051,{"GCY","QRYR33"})                  //"Data da Alta:"
 oSection1:SetHeaderBreak(.F.)   //Retorna se cabecalho das celulas sera impresso apos quebra TRBreak.
 oSection1:SetPageBreak(.T.)     //Retorna se salta a pagina na quebra da secao.
 oSection1:SetNoFilter({"QRYR33"})
 oCell := TRCell():New(oSection1,"GCY_DATALT","GCY",STR0026)                  //"Data da Alta"
 oSection2 := TRSection():New(oSection1,STR0027,{"GCY","SRA","GF4"})          //"Paciente"
ElseIf MV_PAR09 == 2
 oSection2 := TRSection():New(oReport,STR0027,{"GCY","SRA","GF4"})             //"Paciente"
ElseIf MV_PAR09 == 3
 oSection1 := TRSection():New(oReport,STR0054,{"GCY","GF4"})                  //"Tipo da Alta:"
 oSection1:SetHeaderBreak(.F.)   
 oSection1:SetPageBreak(.T.)    
 oCell := TRCell():New(oSection1,"GCY_TPALTA","GCY",STR0054)    //"Tipo da Alta"
 oCell := TRCell():New(oSection1,"cALTA"," "," ",,len(CriaVar("GF4_DSTPAL",.F.)),,{|| HS_INIPADR("GF4", 1, ("QRYR33")->GCY_TPALTA, "GF4_DSTPAL",,.F.)})
 oSection2 := TRSection():New(oSection1,STR0027,{"GCY","SRA","GF4"}) //"Paciente"
EndIf
 
oSection2:SetHeaderBreak(.T.)
oSection2:SetPageBreak(.F.)
oSection2:SetHeaderPage(.T.)
//oSection2:SetHeaderSection(.F.)  //Retorna se cabecalho da celula sera impresso na quebra da secao.
oCell := TRCell():New(oSection2,"GCY_REGGER","GCY",STR0052) //"Prontuแrio"
oCell := TRCell():New(oSection2,"GCY_NOME","GCY",STR0068) //"Nome"
oCell := TRCell():New(oSection2,"GCY_DATATE","GCY",STR0055) //"Data Ent."
oCell := TRCell():New(oSection2,"GCY_HORATE","GCY",STR0056) //"Hora"
oCell := TRCell():New(oSection2,"GCY_DATALT","GCY",STR0057) //"Data Alta"
oCell := TRCell():New(oSection2,"GCY_HORALT","GCY",STR0056) //"Hora"
oCell := TRCell():New(oSection2,"GCY_TPALTA","GCY",STR0058) //"Tipo de Alta"
oCell := TRCell():New(oSection2,"cALTA"," "," ",,len(CriaVar("GF4_DSTPAL",.F.)),,{|| HS_INIPADR("GF4", 1, ("QRYR33")->GCY_TPALTA, "GF4_DSTPAL",,.F.)})
oCell := TRCell():New(oSection2,"nHora","GCY",STR0059,,,,{||nHora:=IIf(	SubtHoras(QRYR33->GCY_DATATE,QRYR33->GCY_HORATE, QRYR33->GCY_DATALT, QRYR33->GCY_HORALT) >= 0,;    //"Perman๋ncia"
     				Str((SubtHoras(QRYR33->GCY_DATATE,QRYR33->GCY_HORATE, QRYR33->GCY_DATALT, QRYR33->GCY_HORALT)/24),4,0)+ STR0036,	0)})  //" dia(s)"
oCell := TRCell():New(oSection2,"GCY_CODCRM","GCY",STR0060) //"M้dico"
oCell := TRCell():New(oSection2,"cNOMMED","SRA","",,TamSX3("RA_NOME")[1],,{||HS_INIPADR("SRA",11, QRYR33->GCY_CODCRM, "RA_NOME")}) 
oCell := TRCell():New(oSection2,"cNOMSET","GCS",STR0067,,TamSX3("GCS_NOMLOC")[1],,{||HS_INIPADR("GCS",1, QRYR33->GCY_CODLOC, "GCS_NOMLOC")}) //"Setor"
                                                      
oSection3 := TRSection():New(oSection2,STR0052,{"GCY","GA9","GCM","GAS"}) //"Prontuแrio"
oSection3:SetHeaderBreak(.T.)
oSection3:SetPageBreak(.F.)
oSection3:SetHeaderPage(.T.)
oCell := TRCell():New(oSection3,"GCZ_CODCON","GCZ",STR0061) //"C๓d -"
oCell := TRCell():New(oSection3,"cCONVENIO","GA9",STR0062,,len(CriaVar("GA9_NOME",.F.)),,{|| HS_INIPADR("GA9", 1, GCZ->GCZ_CODCON, "GA9_NOME",,.F.)}) //"Conv๋nio"
oCell := TRCell():New(oSection3,"cDESPLA","GCM",STR0063,,len(CriaVar("GCM_DESPLA",.F.)),,{|| HS_INIPADR("GCM", 2, GCZ->GCZ_CODPLA, "GCM_DESPLA",,.F.)})  //"Plano"
oCell := TRCell():New(oSection3,"GCY_CIDALT","GCY",STR0064) //"CID Alta"
oCell := TRCell():New(oSection3,"cPATOLO"," ",STR0065,,len(CriaVar("GAS_PATOLO",.F.)),,{|| HS_INIPADR("GAS", 1, ("QRYR33")->GCY_CIDALT, "GAS_PATOLO",,.F.)}) //"Descri็ใo"
oCell := TRCell():New(oSection3,"GCY_DATFEC","GCY",STR0066) //"Data do Fechamento"

If MV_PAR09 == 1 /*se ordernar por data utiliza o separador e totalizador*/
	DEFINE FUNCTION FROM oSection3:Cell("GCY_DATFEC") OF oSection1 FUNCTION COUNT TITLE " ===> " 
ElseIf MV_PAR09 == 2 /*se ordernar por paciente utiliza o separador e totalizador*/
// DEFINE FUNCTION FROM oSection3:Cell("GCY_DATFEC") OF oSection3 FUNCTION COUNT TITLE " ===> "	 
 oTotaliz1 := TRFunction():new(oSection2:Cell("GCY_NOME"),,"COUNT",,STR0053,,,.F.,.T.,.F.,,)   //"Total Emitido: ==>"
ElseIf MV_PAR09 == 3 /*se ordernar por Tipo Alta utiliza o separador e totalizador*/
 DEFINE FUNCTION FROM oSection3:Cell("GCY_DATFEC") OF oSection1 FUNCTION COUNT TITLE " ===> "
EndIf

Return( oReport )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
//ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
//ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ R33Imp   ณ Autor ณ Antonio Carlos        ณ Data ณ 04/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R33IMP(oReport)

Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(1):Section(1)
Local oSection3  := oReport:Section(1):Section(1):Section(1)
Local cCond1     := "%%"
Local cCond2     := "%%"
Local cCond3     := "%%"
Local cCond4     := "%%"

MakeSqlExpr(oReport:uParam)

If !Empty(MV_PAR01) .AND. !Empty(MV_PAR02) 
 cCond1 := "%GCY.GCY_DATALT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' %"
Else
 cCond1 := "%GCY.GCY_DATALT <> '" + STR(Len(MV_PAR01)) + "' %"
EndIf

If !Empty(MV_PAR05) .AND. !Empty(MV_PAR06) 
 cCond2 := "%GCY.GCY_TPALTA BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' %"
Else
 cCond2 := "%GCY.GCY_TPALTA <> '" + STR(Len(MV_PAR05)) + "' %"
EndIf

If !Empty(MV_PAR07) .AND. !Empty(MV_PAR08) 
 cCond3 := "%GCY.GCY_CODLOC BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' %"
Else
 cCond3 := "%GCY.GCY_CODLOC <> '" + STR(Len(MV_PAR07)) + "' %"
EndIf

If MV_PAR10 == 1  // obitos
	cCond4 := "%GCY.GCY_TPALTA IN ('" + STRTRAN(GETMV("MV_TPALTA"),"/","','") + "')%"
ElseIf MV_PAR10 == 2 // nao obitos
	cCond4 := "%GCY.GCY_TPALTA NOT IN ('" + STRTRAN(GETMV("MV_TPALTA"),"/","','") + "')%"
Else
	cCond4 := "%GCY.GCY_TPALTA <> '" + Space(TamSX3("GCY_TPALTA")[1]) + "' %"
EndIf

If MV_PAR09 == 1
 cCond5 := "%GCY.GCY_DATALT%"
ElseIf MV_PAR09 == 2
 cCond5 := "%" + SqlOrder(GCY->(IndexKey(7))) + "%"
ElseIf MV_PAR09 == 3
 cCond5 := "%" + SqlOrder(GCY->(IndexKey(11))) + "%"
EndIf

oSection1:BeginQuery()
BeginSql alias "QRYR33"
SELECT GCY_TPALTA, GCY_REGATE, GCY_REGGER, GCY_NOME, GCY_DATATE, GCY_HORATE, GCY_DATALT, GCY_HORALT, GCY_CODLOC,;
        GCY_CODCRM, GCY_CIDALT, GCY_ATENDI, GCY_DATFEC
 FROM %table:GCY% GCY 
 WHERE GCY.GCY_FILIAL = %xFilial:GCY% AND GCY.%notDel%
 AND GCY.GCY_TPALTA <> %Exp:'99'%
 AND %Exp:cCond4%                           // (Obito/Nao Obito)
 AND GCY.GCY_ATENDI = %Exp:'0'%
 AND %Exp:cCond1%
 AND %Exp:cCond2%
 AND %Exp:cCond3%
 ORDER BY %Exp:cCond5%
EndSql

	oSection1:EndQuery()
	oSection2:SetParentQuery()

 If MV_PAR09 == 1
 	oSection2:SetParentFilter( {|G| ("QRYR33")->GCY_DATALT == G }, {|| ("QRYR33")->GCY_DATALT}) //Quebra P/Data Alta
	 oSection3:SetParentQuery()
	 oSection3:SetParentFilter( {|P| ("QRYR33")->GCY_REGGER + DTOC(("QRYR33")->GCY_DATALT) == P }, {|| ("QRYR33")->GCY_REGGER + DTOC(("QRYR33")->GCY_DATALT)}) 
 ElseIf MV_PAR09 == 2
 	oSection2:SetParentFilter( {|G| ("QRYR33")->GCY_NOME + DTOC(("QRYR33")->GCY_DATFEC) == G }, {|| ("QRYR33")->GCY_NOME + DTOC(("QRYR33")->GCY_DATFEC)}) 
 ElseIf MV_PAR09 == 3
 	oSection2:SetParentFilter( {|G| ("QRYR33")->GCY_TPALTA == G }, {|| ("QRYR33")->GCY_TPALTA}) //Quebra P/Tipo Alta
	 oSection3:SetParentQuery()
	 oSection3:SetParentFilter( {|P| ("QRYR33")->GCY_REGGER + ("QRYR33")->GCY_TPALTA == P }, {|| ("QRYR33")->GCY_REGGER + ("QRYR33")->GCY_TPALTA}) 
 EndIf

 oSection1:Print() // processa as informacoes da tabela principal
 oReport:SetMeter(QRYR33->(LastRec()))
                   
Return( NIL )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR33R3บ       ณ MARCELO JOSE       บ Data ณ 23/03/2005  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relacao de SAIDA DE PACIENTES NO PERIODO                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑบ          ณ Alterado Por Antonio Carlos    Data:03/05/06               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR33R3()

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local cTitulo        := STR0003 //"S A I D A   D E   P A C I E N T E S    N O   P E R I O D O"
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
Private nomeprog     := "HSPAHR33"
Private nTipo        := 18
Private aReturn      := {STR0004, 1, STR0005, 1, 1, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private wnrel        := "HSPAHR33"
Private cString      := ""
Private aContas      := {}
Private cPerg        := "HSPR33"

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

If !Pergunte(cPerg,.T.)
	return
EndIf

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

cCabec1 := STR0008
cCabec2 := STR0029
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


/****************************************************************
MV_PAR01 - Da Data
MV_PAR02 - Ate Data
MV_PAR03 - Do COnvenio
MV_PAR04 - Ate COnvenio
MV_PAR05 - Do Tp ALta
MV_PAR06 - Ate tp Alta
MV_PAR07 - Do Setor
MV_PAR08 - Ate Setor
MV_PAR09 - Ordenar Por  1=Dt Alta;2=Pacientes;3=Tp Alta
MV_PAR10 - Obito  1=Sim;2=Nao
MV_PAR11 - Grafico 1=Sim;2=Nao
/****************************************************************/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)

Local nCtaFor := 0
Local nTotAlt := 0
Local aMovs   := {}
Local nTotMov := 0
Local cDescCC := ""
Local cArqOld, bWhile
Local nHora    := 0
Local nCodVer  := ""
Local nCtaData := 0
Local nCtaTp	  := 0
Local nCtaPac  := 0
Local nSimFec  := 0
Local nNaoFec  := 0
Local cVazio   := ""
Local aVetGraf := {}
Local nContFor := 0
Private cAliasGCY := "GCY"


Set Printer to &wNRel
Set Printer On
Set Device  to Printer

/*===============================================================================================================*/

#IFDEF TOP
	
	If TCSrvType() <> "AS/400"
		bWhile := {||!Eof()}
		cAliasGCY := "R33QRY"
		
		dbSelectArea("GCY")
		dbSetOrder(1)
		cQuery := "SELECT "
		cQuery += "GCY.GCY_TPALTA GCY_TPALTA, "
		cQuery += "GCY.GCY_REGATE GCY_REGATE, "
		cQuery += "GCY.GCY_REGGER GCY_REGGER, "
		cQuery += "GCY.GCY_NOME GCY_NOME, "
		cQuery += "GCY.GCY_DATATE GCY_DATATE, "
		cQuery += "GCY.GCY_HORATE GCY_HORATE, "
		cQuery += "GCY.GCY_DATALT GCY_DATALT, "
		cQuery += "GCY.GCY_HORALT GCY_HORALT, "
		cQuery += "GCY.GCY_CODLOC GCY_CODLOC, "
		cQuery += "GCY.GCY_CODCRM GCY_CODCRM, "
		cQuery += "GCY.GCY_CIDALT GCY_CIDALT, "
		cQuery += "GCY.GCY_ATENDI GCY_ATENDI, "
		cQuery += "GCY.GCY_DATFEC GCY_DATFEC  "
		cQuery += "FROM "+RetSqlName("GCY") + " GCY "
		cQuery += "WHERE "
		cQuery += "GCY.GCY_FILIAL = '" + xFilial( "GCY" ) + "' AND "
		cQuery += "GCY.GCY_TPALTA <> '99' AND "
		If MV_PAR10 == 1  // obitos
			cQuery += "GCY.GCY_TPALTA IN ('"+STRTRAN(GETMV("MV_TPALTA"),"/","','")+"') AND "
		ElseIf MV_PAR10 == 2 // nao obitos
			cQuery += "GCY.GCY_TPALTA NOT IN ('"+STRTRAN(GETMV("MV_TPALTA"),"/","','")+"') AND "
		EndIf
		cQuery += "GCY.GCY_ATENDI = '0' AND "
		If !Empty(MV_PAR01) .AND. !Empty(MV_PAR02)
			cQuery += "GCY.GCY_DATALT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND "
		EndIf
		If !Empty(MV_PAR05) .AND. !Empty(MV_PAR06)
			cQuery += "GCY.GCY_TPALTA BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' AND "
		EndIf
		If !Empty(MV_PAR07) .AND. !Empty(MV_PAR08)
			cQuery += "GCY.GCY_CODLOC BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' AND "
		EndIf
		cQuery += "GCY.D_E_L_E_T_ <> '*' "
		cQuery += "ORDER BY "+SqlOrder(GCY->(IndexKey()))
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasGCY,.T.,.T.)
		
		DbSelectArea(cAliasGCY)
		
		If Eof()
			HS_MsgInf(STR0044,STR0045,STR0046)//"Nenhum dado foi encontrado para a selecao efetuada!" //"Aten็ใo"###"Saida de Pacientes no Perํodo"
			DbCloseArea()
			Return()
		Endif
		
		While (cAliasGCY)->(Eval(bWhile))
			
			cArqOld := Alias()
			
			DbSelectArea("GCZ")
			DbSetOrder(2)
			If DbSeek(xFilial("GCZ") + (cAliasGCY)->GCY_REGATE )
				If !Empty(MV_PAR03) .And. !Empty(MV_PAR04)
					IF GCZ->GCZ_CODCON < MV_PAR03 .Or. GCZ->GCZ_CODCON > MV_PAR04 /* Convenio fora do intervalo */
						DbSelectArea(cArqOld)
						DbSkip()
						Loop
					EndIf
				Endif
			Else /* se nao encontrou o convenio */
				DbSelectArea(cArqOld)
				DbSkip()
				Loop
			EndIf
			
			DbSelectArea(cArqOld)
			
			nTotAlt++
			
			AADD(aContas,{"","","","","","","","","","","","","",""})
			
			aContas[Len(aContas), 1] := (cAliasGCY)->GCY_TPALTA
			aContas[Len(aContas), 2] := (cAliasGCY)->GCY_REGATE
			aContas[Len(aContas), 3] := (cAliasGCY)->GCY_REGGER
			aContas[Len(aContas), 4] := (cAliasGCY)->GCY_NOME
			aContas[Len(aContas), 5] := StoD( (cAliasGCY)->GCY_DATATE )
			aContas[Len(aContas), 6] := (cAliasGCY)->GCY_HORATE
			aContas[Len(aContas), 7] := StoD( (cAliasGCY)->GCY_DATALT )
			aContas[Len(aContas), 8] := (cAliasGCY)->GCY_HORALT
			aContas[Len(aContas), 9] := GCZ->GCZ_CODCON + " - " + POSICIONE("GA9", 1, xFilial("GA9") + GCZ->GCZ_CODCON, "GA9_NOME")
			aContas[Len(aContas),10] := POSICIONE("GCM", 2, xFilial("GCM") + GCZ->GCZ_CODPLA, "GCM_DESPLA")
			aContas[Len(aContas),11] := (cAliasGCY)->GCY_CODLOC
			aContas[Len(aContas),12] := (cAliasGCY)->GCY_CODCRM
			aContas[Len(aContas),13] := (cAliasGCY)->GCY_CIDALT
			aContas[Len(aContas),14] := StoD( (cAliasGCY)->GCY_DATFEC )
			
			DbSkip()
		EndDo
		
	EndIf
	
	DbSelectArea(cAliasGCY)
	dbCloseArea()
	
#ELSE  /*******************/
	
	DbSelectArea("GCY")
	DbSetOrder(1)
	SetRegua(RecCount())
	DbGotop()
	While !Eof() .And. GCY->GCY_FILIAL == xFilial("GCY")
		
		If Empty(GCY->GCY_TPALTA) /* se nao teve alta*/
			DbSkip()
			Loop
		EndIf
		
		If !Empty(MV_PAR01) .And. !Empty(MV_PAR02)
			IF GCY->GCY_DATALT < MV_PAR01 .Or. GCY->GCY_DATALT > MV_PAR02 // Data fora do intervalo
				DbSkip()
				Loop
			EndIf
		EndIf
		
		If !Empty(MV_PAR05) .And. !Empty(MV_PAR06)
			If GCY->GCY_TPALTA < MV_PAR05 .Or. GCY->GCY_TPALTA > MV_PAR06
				DbSkip()
				Loop
			EndIf
		EndIf
		
		If !Empty(MV_PAR07) .And. !Empty(MV_PAR08)
			If GCY->GCY_CODLOC < MV_PAR07 .Or. GCY->GCY_CODLOC > MV_PAR08
				DbSkip()
				Loop
			EndIf
		EndIf
		
		cArqOld := Alias()
		
		DbSelectArea("GCZ")
		DbSetOrder(2)
		If DbSeek(xFilial("GCZ") + GCY->GCY_REGATE )
			If !Empty(MV_PAR03) .And. !Empty(MV_PAR04)
				IF GCZ->GCZ_CODCON < MV_PAR03 .Or. GCZ->GCZ_CODCON > MV_PAR04 // Convenio fora do intervalo
					DbSelectArea(cArqOld)
					DbSetOrder(1)
					DbSkip()
					Loop
				EndIf
			Endif
		Else /* se nao encontrou o convenio */
			DbSelectArea(cArqOld)
			DbSetOrder(1)
			DbSkip()
			Loop
		EndIf
		
		DbSelectArea(cArqOld)
		DbSetOrder(1)
		
		nTotAlt++
		
		IncRegua()
		
		AADD(aContas,{"","","","","","","","","","","","","",""})
		
		aContas[Len(aContas), 1] := GCY->GCY_TPALTA
		aContas[Len(aContas), 2] := GCY->GCY_REGATE
		aContas[Len(aContas), 3] := GCY->GCY_REGGER
		aContas[Len(aContas), 4] := GCY->GCY_NOME
		aContas[Len(aContas), 5] := GCY->GCY_DATATE
		aContas[Len(aContas), 6] := GCY->GCY_HORATE
		aContas[Len(aContas), 7] := GCY->GCY_DATALT
		aContas[Len(aContas), 8] := GCY->GCY_HORALT
		aContas[Len(aContas), 9] := GCZ->GCZ_CODCON + " - " + POSICIONE("GA9", 1, xFilial("GA9") + GCZ->GCZ_CODCON, "GA9_NOME")
		aContas[Len(aContas),10] := POSICIONE("GCM", 2, xFilial("GCM") + GCZ->GCZ_CODPLA, "GCM_DESPLA")
		aContas[Len(aContas),11] := GCY->GCY_CODLOC
		aContas[Len(aContas),12] := GCY->GCY_CODCRM
		aContas[Len(aContas),13] := GCY->GCY_CIDALT
		aContas[Len(aContas),14] := GCY->GCY_DATFEC
		dbSkip()
	Enddo
	
#ENDIF

/*================================================================================================================*/


If len(aContas) > 0
	If MV_PAR09 == 1
		ASort(aContas,,,{|x,y| DTOS(X[7]) + X[4] <  DTOS(Y[7]) + Y[4] })
	ElseIf MV_PAR09 == 2
		ASort(aContas,,,{|x,y| X[4] < Y[4] })
	Else
		ASort(aContas,,,{|x,y| X[1] < Y[1] })
	EndIf
	SetRegua(Len(aContas))
Endif

For nCtaFor = 1 to Len(aContas)
	
	If lAbortPrint
		@nLin,00 PSAY STR0008
		Exit
	Endif
	
	If nLin > nMaxLin
		If (MV_PAR09 == 1 .OR. MV_PAR09 == 3) .And. nLin <= nMaxLin + 2/*se ordernar por data utiliza o separador e totalizador*/
			@ nLin,01 Psay STR0030 //"continua..."
		EndIf
		Cabec(cTitulo,cCabec1,cCabec2,NomeProg,Tamanho,nTipo)
		nLin := 10
		If MV_PAR09 == 1 /*se ordernar por data utiliza o separador e totalizador*/
			If nCodVer == DtoC(aContas[nCtaFor,7])
				@ nLin,00 Psay STR0031 + DtoC(aContas[nCtaFor,7]) //"...continuacao de "
				nLin++
			Endif
		ElseIf MV_PAR09 == 3 /*se ordernar por Tp ALta utiliza o separador e totalizador*/
			If nCodVer == aContas[nCtaFor,1]
				@ nLin,00 Psay STR0031 + aContas[nCtaFor,1] //"...continuacao de "
				nLin++
			Endif
		EndIf
	Endif
	
	If MV_PAR09 == 1 /*se ordernar por data utiliza o separador e totalizador*/
		If Len(aContas) >= 1
			If nCtaFor == 1 .OR. nCodVer != DtoC(aContas[nCtaFor,7])
				If nCtaFor > 1
					nLin++
				Endif
				If nCtaData > 0
					@ nLin,00 Psay STR0032 + Str(nCtaData,4,0)   //"Total do Dia: ===>  "
					AADD(aVetGraf,{nCtaData,DtoC(aContas[nCtaFor-1,7])+" "} )
					nLin +=2
					@ nLin,000 Psay REPLI("-",229)
					nLin +=2
					nCtaData := 0
				EndIf
				@ nLin,00 Psay STR0033 + DtoC(aContas[nCtaFor,7] ) //"Data da Alta: "
				nLin++
				nCodVer := Dtoc(aContas[nCtaFor,7])
				nLin++
			EndIf
		EndIf
	ElseIf MV_PAR09 == 3 /*se ordernar por Tp Alta*/
		If Len(aContas) >= 1
			If nCtaFor == 1 .OR. nCodVer != aContas[nCtaFor,1]
				If nCtaFor > 1
					nLin++
				Endif
				If nCtaTp > 0
					@ nLin,00 Psay STR0034 + Str(nCtaTp,4,0)   //"Total do Tipo: ===>  "
					AADD(aVetGraf,{nCtaTp,aContas[nCtaFor-1,1]+" "} )
					nLin +=2
					@ nLin,000 Psay REPLI("-",229)
					nLin +=2
					nCtaTp := 0
				EndIf

				@ nLin,00 Psay STR0035 + aContas[nCtaFor,1]+" - "+ Posicione("GF4",1,xFilial("GF4")+aContas[nCtaFor,1],"GF4_DSTPAL") //"Tipo da Alta: "
				nLin++
				nCodVer := aContas[nCtaFor,1]
				nLin++
			EndIf
		EndIf
	EndIf
	
	@ nLin,00  Psay aContas[nCtaFor,3]
	@ nLin,11  Psay SUBSTR(aContas[nCtaFor,4],1,40)
	@ nLin,53  Psay DtoC(aContas[nCtaFor,5])
	@ nLin,63  Psay aContas[nCtaFor,6]
	@ nLin,72  Psay DtoC(aContas[nCtaFor,7])
	@ nLin,82  Psay aContas[nCtaFor,8]
	@ nLin,89  Psay aContas[nCtaFor,1]
	@ nLin,93  Psay PADR(Posicione("GF4", 1, xFilial("GF4") + aContas[nCtaFor, 1], "GF4_DSTPAL"),30)
	nHora := SubtHoras(aContas[nCtaFor,5], aContas[nCtaFor,6], aContas[nCtaFor,7], aContas[nCtaFor,8])
	@ nLin,145 Psay Str((nHora/24),4,0) + STR0036 //" dia(s)"
	@ nLin,159 Psay Posicione("SRA",11, xFilial("SRA") + aContas[nCtaFor, 12], "RA_NOME")
	@ nLin,192 Psay PADR(Posicione("GCS", 1, xFilial("GCS") + aContas[nCtaFor, 11], "GCS_NOMLOC"),30)
	nLin++
	@ nLin,013 Psay aContas[nCtaFor, 9]
	@ nLin,062 Psay aContas[nCtaFor,10]
	@ nLin,094 Psay aContas[nCtaFor,13]
	@ nLin,105 Psay Posicione("GAS",1,xFilial("GAS") + aContas[nCtaFor,13],"GAS_PATOLO")
	@ nLin,178 Psay DtoC(aContas[nCtaFor,14])
	If Empty(aContas[nCtaFor,14])
		nNaoFec++
	Else
		nSimFec++
	EndIf
	
	nLin += 2
	nCtaData++
	nCtaTp  ++
	nCtaPac ++
Next

If MV_PAR09 == 1 /*se ordernar por data utiliza o separador e totalizador*/
	If nCtaData > 0
		@ nLin,00 Psay STR0032 + Str(nCtaData,4,0) //"Total do Dia: ===>  "
		AADD(aVetGraf,{nCtaData,DtoC(aContas[nCtaFor-1,7])+" "} )
		nLin +=2
	EndIf
ElseIf MV_PAR09 == 2 /*se ordernar por paciente utiliza o separador e totalizador*/
	If nCtaPac > 0
		@ nLin,00 Psay STR0047 + Str(nCtapac,4,0) //"Total Emitido: ===>  "
		AADD(aVetGraf,{nCtaPac," "+" "} )
		nLin +=2
	EndIf
ElseIf MV_PAR09 == 3 /*se ordernar por data utiliza o separador e totalizador*/
	If nCtaTp > 0
		@ nLin,00 Psay STR0034 + Str(nCtaTp,4,0) //"Total do Tipo: ===>  "
		AADD(aVetGraf,{nCtaTp,aContas[nCtaFor-1,1]+" "} )
		nLin +=2
	EndIf
EndIf

For nContFor:= 1 to Len(aVetGraf) //grava o percentual na 1
	If MV_PAR09 == 1 .OR. MV_PAR09 == 2 .OR. MV_PAR09 == 3
		aVetGraf[nContFor,1] := (aVetGraf[nContFor,1]/nTotAlt)*100
		aVetGraf[nContFor,2] := aVetGraf[nContFor,2]+" - "+ALLTRIM(STR(aVetGraf[nContFor,1],6,2))+"%"
	EndIf
Next

If MV_PAR11 == 1
	/* Monta vetor para o grafico carteziano */
	/* CRIA O OBJETO PARA CONSTRUCAO DO GRAFICO CARTEZIANO  */
	ASORT(aVetGraf,,,{|x,y| x[1] < y[1]})
	If MV_PAR09 == 1
		oGraf := hsGRAF():NEW(STR0037, STR0038, STR0039, STR0040, STR0041, "", aVetGraf,1,1,0,0,2,18,6,6,25,20)  //"RESUMO DAS SAIDAS"###"POR DATA DA ALTA"###"Percentual das Altas"###"Percentual %"###"Datas das Altas"
	ElseIf MV_PAR09 == 2
		oGraf := hsGRAF():NEW(STR0037, STR0048, STR0039, STR0040, STR0049, "", aVetGraf,1,1,0,0,2,18,6,6,25,20)   //"RESUMO DAS SAIDAS"###"Total Geral de Pacientes###"Percentual das Altas"###"Percentual "###"Total de Pacientes Emitidos"
	ElseIf MV_PAR09 == 3
		oGraf := hsGRAF():NEW(STR0037, STR0042, STR0039, STR0040, STR0043 , "", aVetGraf,1,1,0,0,2,17,6,6,25,20)    //"RESUMO DAS SAIDAS"###"POR TIPO DA ALTA"###"Percentual das Altas"###"Percentual %"###"Tipo das Altas"
	EndIf
EndIf

Set Printer to
Set Device  to Screen

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()
Return(Nil)
