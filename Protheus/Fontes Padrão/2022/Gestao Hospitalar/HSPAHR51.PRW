#INCLUDE "HSPAHR51.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#INCLUDE "Report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR51 บ       ณ Saude              บ Data ณ 22/08/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Censo Ocupacional Diario                                   บฑฑ
ฑฑบ          ณ Conversใo para relatorios personalizaveis                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR51()

Local oReport
Private   nTotLeNEst := 0  
Private   nTotLei    := 0  
Private   nTotLeiEst := 0  
Private   nTotOcuEst :=0 
Private   nPercOcup   :=0
Private   aVetDados  :={} 
Private   nTotOcu   :=0 
Private   nTotOcGEst := 0  
Private   nTotOcuG := 0  
Private   nPercEstatic  := 0     
Private   nGTotLeiEst :=0  
Private   nGTotLei	   :=0
Private   nGTotOcuEst :=0
Private   nGPercEstatic :=0
Private   nGPercOcup    :=0
Private   nGTotOcup     :=0
Private   cCodDp:=""

If FindFunction("TRepInUse") .And. TRepInUse()
	pergunte("HSPR51",.T.)
	oReport := ReportDef()
	oReport:PrintDialog()
ELSE                
	HSPAHR51R3()
EndIF
Return( Nil )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 22/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ReportDef()
Local oReport
Local oSection1, oSection2
Local oCell
Local oTotaliz1, oTotaliz2, oTotaliz3, oTotaliz4, oTotaliz5, oTotaliz6
Local cAliasQry := GetNextAlias()
Local cCod:=0
oReport := TReport():New("HSPAHR51",STR0003,"HSPR51",{|oReport| R51IMP(oReport,cAliasQry)},STR0001 + " " + STR0002)  
 //"Censo Ocupacional Diario"### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."

oReport:SetLandscape()         // Imprimir relatorio em formato paisagem
oReport:TotalInLine(.F.)
oReport:ParamReadOnly() //Desabilitando Botใo de parโmetros do Relat๓rio.

If MV_PAR12 == 2            //Se Quebrar por Setor
 oSection1 := TRSection():New(oReport,"Setor",{"GCY","GCS"}) 
 oSection1:SetPageBreak(.F.)
 oSection1:SetHeaderBreak(.T.)    //Define se cabecalho das celulas sera impresso apos quebra TRBreak.

 oSection1:SetNoFilter({"GCY","GAV","GCS"})
 oCell := TRCell():New(oSection1,"GAV_CODLOC","GCY",) 
 oCell := TRCell():New(oSection1,"GCS_NOMLOC","GCS",) 
 oCell := TRCell():New(oSection1,"GCS_TIPLOC","GCS",,,,,{|| "("+HS_RDescrB("GCS_TIPLOC", ("QRYR51")->GCS_TIPLOC)+")" }) 
 oCell := TRCell():New(oSection1,"  ","  ",,,,,{||oReport,FS_LeiSeto(("QRYR51")->GAV_CODLOC)}) 
 oSection2 := TRSection():New(oSection1,STR0023,{"GAV","SRA","GCW","GCM","GCY"}) //"Leitos"
Else
 oSection2 := TRSection():New(oReport,STR0023,{"GAV","SRA","GCW","GCM","GCY"}) //"Leitos"
 oCell := TRCell():New(oSection2,"  ","  ",,,,,{||oReport,FS_LeiSeto(("QRYR51")->GAV_CODLOC)}) 
EndIf 
oSection2:SetNoFilter({"GCY","GAV","GCW","GCM","SRA"})
oSection2:SetPageBreak(.F.)
oSection2:SetHeaderPage(.T.)
oSection2:SetHeaderBreak(.F.)    //Define se cabecalho das celulas sera impresso apos quebra TRBreak.

oCell := TRCell():New(oSection2,"GAV_QUARTO","GAV",) 
oCell := TRCell():New(oSection2,"GAV_LEITO","GAV",) 
oCell := TRCell():New(oSection2,"cEstatistico","GAV","Estatํsticos",,,,{||IIF(("QRYR51")->GAV_ESTATI == "1", STR0012,STR0013)})
 
oCell := TRCell():New(oSection2,"GCY_NOME","GCY",) 
oCell := TRCell():New(oSection2,"GCY_REGGER","GCY",) 
oCell := TRCell():New(oSection2,"GCY_REGATE","GCY",) 
oCell := TRCell():New(oSection2,"GCY_DATATE","GCY",) 
oCell := TRCell():New(oSection2,"GCY_HORATE","GCY",) 
oCell := TRCell():New(oSection2,"cACOMPA","GCY",STR0018,,,,{||IIF(("QRYR51")->GCY_ACOMPA=="0",STR0012,STR0013)})  //"Acomp."###"Sim"###"Nใo"
oCell := TRCell():New(oSection2,"cPERMAN","GCY",STR0044,,,,{||IIF(Empty(("QRYR51")->GCY_DATATE) ," ",STRZERO(DDATABASE - ("QRYR51")->GCY_DATATE,4))})//"Permanencia"
oCell := TRCell():New(oSection2,"GCM_DESPLA","GCM",STR0019)  //"Conv๋nio"
oCell := TRCell():New(oSection2,"RA_NOME","SRA",STR0020)  //"M้dico Resp."
oCell := TRCell():New(oSection2,"GCW_DESCLI","GCW",STR0021)  //"Clํnica"

If MV_PAR12 == 2 //Se Quebrar por Setor 

  oTotaliz1 := TRFunction():new(oSection2:Cell("GAV_LEITO"),,"ONPRINT",,STR0036,"@E 99,999",{|| aVetDados[1][3] },.T.,.F.,.F.,oSection2) // SECAO DO SETOR : "Ocupados (Estatisticos)"
  oTotaliz1:SetCondition( { ||  ("QRYR51")->GAV_ESTATI=="1" .And. !EMPTY(("QRYR51")->GCY_REGATE) } )

  TRFunction():new(oSection2:Cell("GAV_LEITO"),,"MAX",,STR0042,"@E 999.99",{||aVetDados[1][4]},.T.,.F.,.F.,oSection2)                    // SECAO DO SETOR : "Ocupados % (Estatisticos)" 

  TRFunction():new(oSection2:Cell("GAV_LEITO"),,"MAX",,STR0034,"@E 99,999",{||aVetDados[1][1]},.T.,.F.,.F.,oSection2)                    // SECAO DO SETOR : "Total de Leitos Estatisticos Setor"
   
  oTotaliz2 := TRFunction():new(oSection2:Cell("GAV_LEITO"),,"ONPRINT",,STR0037,"@E 99,999",{||aVetDados[1][7]},.T.,.F.,.F.,oSection2)   // SECAO DO SETOR : "Ocupados"                
  oTotaliz2:SetCondition( { || !EMPTY(("QRYR51")->GCY_REGATE) } )

  TRFunction():new(oSection2:Cell("GAV_LEITO"),,"MAX",,STR0043,"@E 999.99",{|| aVetDados[1][5] },.T.,.F.,.F.,oSection2)                  // SECAO DO SETOR : "Ocupados %"
 
  TRFunction():new(oSection2:Cell("GAV_LEITO"), ,"MAX",,STR0035,"@E 99,999",{||aVetDados[1][2]},.T.,.F.,.F.,oSection2)                   // SECAO DO SETOR : "Total de Leitos no Setor" 

EndIf

 oTotaliz3 := TRFunction():new(oSection2:Cell("GAV_LEITO"),,"ONPRINT",,STR0040,"@E 99,999",{||nGTotOcuEst},.F.,.T.,.F.,oSection2)  // SECAO TOTAL GERAL : "Ocupados Geral (Estatisticos)"
 oTotaliz3:SetCondition( { || ("QRYR51")->GAV_ESTATI=="1" .And. !EMPTY(("QRYR51")->GCY_REGATE) } )

 oTotaliz4 := TRFunction():new(oSection2:Cell("GAV_LEITO"),,"ONPRINT",,STR0042,"@E 999.99",{||nGPercEstatic},.F.,.T.,.F.,oSection2)// SECAO TOTAL GERAL : "Ocupados % (Estatisticos)"
 oTotaliz4:SetCondition( { || ("QRYR51")->GAV_ESTATI=="1"} ) 

 oTotaliz5 := TRFunction():new(oSection2:Cell("GAV_LEITO"),,"ONPRINT",,STR0038,"@E 99,999",{||nGTotLeiEst},.F.,.T.,.F.,oSection2)  // SECAO TOTAL GERAL : "Total Geral Leitos Estatisticos"
oTotaliz5:SetCondition( { || ("QRYR51")->GAV_ESTATI=="1"} ) 

 oTotaliz6 := TRFunction():new(oSection2:Cell("GAV_LEITO"),,"ONPRINT",,STR0041,"@E 99,999",{||nGTotOcup},.F.,.T.,.F.,oSection2)    // SECAO TOTAL GERAL : "Ocupados Geral"
 oTotaliz6:SetCondition( { || !EMPTY(("QRYR51")->GCY_REGATE) } ) 

 TRFunction():new(oSection2:Cell("GAV_LEITO"),,"ONPRINT",,STR0043,"@E 999.99",{||nGPercOcup},.F.,.T.,.F.,oSection2)                // SECAO TOTAL GERAL : "Ocupados %"

 TRFunction():new(oSection2:Cell("GAV_LEITO"),,"ONPRINT",,STR0039,"@E 99,999",{||nGTotLei},.F.,.T.,.F.,oSection2)                  // SECAO TOTAL GERAL : "Total Geral Leitos"

Return( oReport )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
//ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
//ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ R51Imp   ณ Autor ณ Antonio Carlos        ณ Data ณ 22/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R51IMP(oReport,cAliasQry)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local cCondCrm   := "" ,cCondPla := "", cCondCon := ""
Local cGavFilial := "",cGavSetor := "", cCond1 := "% GAV.GAV_STATUS IN ('1', '5', '2') %", cCond2 := "% 1 = 1 %"
Local cOrderBy   := ""
Local cCod:=""
MakeSqlExpr(oReport:uParam)

cCondCrm   := "% GCY.GCY_CODCRM BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' %"
cCondPla   := "% GD4.GD4_CODPLA BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' %"
cCondCon   := "% GD4.GD4_CODCON BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' %"
cGavFilial := "% GAV.GAV_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' %"
cGavSetor  := "% GAV.GAV_CODLOC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' %"

If MV_PAR13 == 2
	cCond1 := "% GAV.GAV_STATUS IN ('0','1', '5','2') %"
EndIf

If MV_PAR14 # 2
	cCond2 := "% GAV.GAV_ESTATI = '1' %"
EndIf

cOrderBy := "%"

If (MV_PAR11 == 1 .AND. MV_PAR12 == 1)
	cOrderBy += "GCY_NOME "
ElseIf (MV_PAR11 == 1 .AND. MV_PAR12 == 2)
	cOrderBy  += " GAV_CODLOC,GCY_NOME "
ElseIf MV_PAR11 == 2
	cOrderBy += " GAV_CODLOC,GAV_QUARTO, GAV_LEITO "
ElseIf (MV_PAR11 == 3 .AND. MV_PAR12 == 1)
	cOrderBy += " RA_NOME "
ElseIf (MV_PAR11 == 3 .AND. MV_PAR12 == 2)
	cOrderBy += " GAV_CODLOC,RA_NOME "
EndIf

cOrderBy += "%"

If MV_PAR13 == 2
	oSection1:BeginQuery()
	
	BeginSql alias "QRYR51"
		SELECT	GCS.GCS_NOMLOC, GCS.GCS_TIPLOC, GAV.GAV_CODLOC, GAV.GAV_QUARTO, GAV.GAV_LEITO, GCY.GCY_NOME, GCY.GCY_REGGER, GCY.GCY_REGATE,
				GCY.GCY_DATATE, GCY.GCY_HORATE, GD4.GD4_CODCON, GD4.GD4_CODPLA, GCY.GCY_ACOMPA, GCM.GCM_DESPLA, GCY.GCY_CODCRM, SRA.RA_NOME,
				GCW.GCW_DESCLI , GCY.GCY_DATALT, GAV.GAV_ESTATI
		FROM %table:GAV% GAV
		JOIN %table:GCS% GCS ON GCS.GCS_CODLOC = GAV.GAV_CODLOC AND GCS.GCS_FILIAL = %xFilial:GCS% AND GCS.%notDel%
		LEFT JOIN %table:GCY% GCY ON GCY.GCY_REGATE = GAV.GAV_REGATE AND GCY.GCY_FILIAL = %xFilial:GCY% AND GCY.%notDel%
									AND (GCY.GCY_DATALT = %Exp:SPACE(8)%  OR (GCY.GCY_DATALT <>%Exp:SPACE(8)% AND   GAV.GAV_STATUS =%Exp:'2'%))       AND %Exp:cCondCrm%
		JOIN %table:GD4% GD4 ON GD4.GD4_REGGER = GCY.GCY_REGGER AND GD4.GD4_FILIAL = %xFilial:GD4% AND GD4.%notDel%
									AND GD4.GD4_IDPADR = %Exp:'1'%  AND %Exp:cCondPla%
									AND %Exp:cCondCon%
		LEFT JOIN %table:GCM% GCM ON GCM.GCM_CODPLA = GD4.GD4_CODPLA AND GCM.GCM_FILIAL = %xFilial:GCM% AND GCM.%notDel%
		LEFT JOIN %table:SRA% SRA ON SRA.RA_CODIGO  = GCY.GCY_CODCRM AND SRA.RA_FILIAL = %xFilial:SRA% AND SRA.%notDel%
		LEFT JOIN %table:GCW% GCW ON GCW.GCW_CODCLI = GCY.GCY_CODCLI AND GCW.GCW_FILIAL = %xFilial:GCW% AND GCW.%notDel%
		WHERE %Exp:cGavFilial% AND GAV.%notDel%
			AND %Exp:cGavSetor%
			AND %Exp:cCond1%
			AND %Exp:cCond2%
		ORDER BY %Exp:cOrderBy%
	EndSql
	
	oSection1:EndQuery()
Else
	oSection1:BeginQuery()
	
	BeginSql alias "QRYR51"
		SELECT	GCS.GCS_NOMLOC, GCS.GCS_TIPLOC, GAV.GAV_CODLOC, GAV.GAV_QUARTO, GAV.GAV_LEITO, GCY.GCY_NOME, GCY.GCY_REGGER, GCY.GCY_REGATE,
				GCY.GCY_DATATE, GCY.GCY_HORATE, GD4.GD4_CODCON, GD4.GD4_CODPLA, GCY.GCY_ACOMPA, GCM.GCM_DESPLA, GCY.GCY_CODCRM, SRA.RA_NOME,
				GCW.GCW_DESCLI , GCY.GCY_DATALT, GAV.GAV_ESTATI
		FROM %table:GAV% GAV
		JOIN %table:GCS% GCS ON GCS.GCS_CODLOC = GAV.GAV_CODLOC AND GCS.GCS_FILIAL = %xFilial:GCS% AND GCS.%notDel%
		JOIN %table:GCY% GCY ON GCY.GCY_REGATE = GAV.GAV_REGATE AND GCY.GCY_FILIAL = %xFilial:GCY% AND GCY.%notDel%
									AND (GCY.GCY_DATALT = %Exp:SPACE(8)%  OR (GCY.GCY_DATALT <>%Exp:SPACE(8)% AND   GAV.GAV_STATUS =%Exp:'2'%))       AND %Exp:cCondCrm%
		JOIN %table:GD4% GD4 ON GD4.GD4_REGGER = GCY.GCY_REGGER AND GD4.GD4_FILIAL = %xFilial:GD4% AND GD4.%notDel%
									AND GD4.GD4_IDPADR = %Exp:'1'%  AND %Exp:cCondPla%
									AND %Exp:cCondCon%
		LEFT JOIN %table:GCM% GCM ON GCM.GCM_CODPLA = GD4.GD4_CODPLA AND GCM.GCM_FILIAL = %xFilial:GCM% AND GCM.%notDel%
		LEFT JOIN %table:SRA% SRA ON SRA.RA_CODIGO  = GCY.GCY_CODCRM AND SRA.RA_FILIAL = %xFilial:SRA% AND SRA.%notDel%
		LEFT JOIN %table:GCW% GCW ON GCW.GCW_CODCLI = GCY.GCY_CODCLI AND GCW.GCW_FILIAL = %xFilial:GCW% AND GCW.%notDel%
		WHERE %Exp:cGavFilial% AND GAV.%notDel%
			AND %Exp:cGavSetor%
			AND %Exp:cCond1%
			AND %Exp:cCond2%
		ORDER BY %Exp:cOrderBy%
	EndSql
	
	oSection1:EndQuery()
EndIf

If MV_PAR12==2
	oSection2:SetParentQuery()
	oSection2:SetParentFilter( {|G| ("QRYR51")->GAV_CODLOC == G }, {|| ("QRYR51")->GAV_CODLOC})
EndIf

oReport:Section(1):Print() // processa as informacoes da tabela principal
oReport:SetMeter(QRYR51->(LastRec()))

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR51R3บ Autor ณ Daniel Peixoto     บ Data ณ  27/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Censo Ocupacional Diario                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR51R3()


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Declaracao de Variaveis                                             ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1        := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3        := ""
Local cPict         := ""
Local titulo        := STR0003 //"Censo Ocupacional Diario"
Local nLin          := 80 
Local Cabec1        := ""
Local Cabec2        := ""
Local imprime       := .T.
Local aOrd 			:= {}    

Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 80
Private tamanho     := "G"
Private nomeprog    := "HSPAHR51" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo       := 18
Private aReturn     := {STR0004 , 1, STR0005, 2, 2, 1, "", 1}     //"Administracao"###"Zebrado"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "HSPAHR51" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cPerg       := "HSPR51"
Private cString     := ""

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ PARAMETROS                                                         ณ
  ณ MV_PAR01	Da Filial                                              ณ
  ณ MV_PAR02	Ate Filial                                             ณ
  ณ MV_PAR03	Do Setor                                               ณ
  ณ MV_PAR04	Ate Setor                                              ณ
  ณ MV_PAR05	Do Plano                                               ณ
  ณ MV_PAR06	Ate Plano                                              ณ
  ณ MV_PAR07	Do Medico                                              ณ
  ณ MV_PAR08	Ate Medico                                             ณ
  ณ MV_PAR09	Do Convenio                                            ณ
  ณ MV_PAR10	Ate Convenio                                           ณ
  ณ MV_PAR11	Ordenar Por   1= Nome Pac. 2=Quarto/Leito              ณ
  ณ MV_PAR12    Quebra por setor                                       ณ 
  | MV_PAR13    Impressora ?                                           |
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/


If !Pergunte(cPerg,.T.)
	return
EndIf

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)


RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Daniel Peixoto     บ Data ณ  27/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local cSQL 	     := "" 
Local cCodLoc   := ""      

cSQL := "SELECT GCS.GCS_NOMLOC, GCS.GCS_TIPLOC, GAV.GAV_CODLOC, GAV.GAV_QUARTO, GAV.GAV_LEITO, GCY.GCY_NOME, GCY.GCY_REGGER, GCY.GCY_REGATE,"
cSQL += " GCY.GCY_DATATE, GCY.GCY_HORATE, GD4.GD4_CODCON, GD4.GD4_CODPLA, GCY.GCY_ACOMPA, GCM.GCM_DESPLA, GCY.GCY_CODCRM, SRA.RA_NOME, "
cSQL += " GCW.GCW_DESCLI , GCY.GCY_DATALT, GAV.GAV_ESTATI "
cSQL += " FROM " + RetSQLName("GAV") + " GAV"
cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GAV.GAV_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
If MV_PAR13 == 2
	cSQL += " LEFT JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GAV.GAV_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' " 
	cSQL += "                                            AND (GCY.GCY_DATALT = '" + SPACE(8) + "' OR (GCY.GCY_DATALT <> '" + SPACE(8) + "' AND   GAV.GAV_STATUS ='2')) AND GCY.GCY_CODCRM BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "           
	cSQL += " LEFT JOIN " + RetSQLName("GD4") + " GD4 ON GD4.GD4_REGGER = GCY.GCY_REGGER AND GD4.GD4_FILIAL = '" + xFilial("GD4") + "' AND GD4.D_E_L_E_T_ <> '*' "
	cSQL += "                                        AND GD4.GD4_IDPADR = '1' AND GD4.GD4_CODPLA BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
	cSQL += "                                        AND GD4.GD4_CODCON BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
Else
	cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GAV.GAV_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' " 
	cSQL += "                                            AND (GCY.GCY_DATALT = '" + SPACE(8) + "' OR (GCY.GCY_DATALT <> '" + SPACE(8) + "' AND   GAV.GAV_STATUS ='2')) AND GCY.GCY_CODCRM BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "           
	cSQL += " JOIN " + RetSQLName("GD4") + " GD4 ON GD4.GD4_REGGER = GCY.GCY_REGGER AND GD4.GD4_FILIAL = '" + xFilial("GD4") + "' AND GD4.D_E_L_E_T_ <> '*' "
	cSQL += "                                        AND GD4.GD4_IDPADR = '1' AND GD4.GD4_CODPLA BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
	cSQL += "                                        AND GD4.GD4_CODCON BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
Endif
cSQL += " LEFT JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GD4.GD4_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
cSQL += " LEFT JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GCY.GCY_CODCRM AND SRA.RA_FILIAL = '" +  xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' " 
cSQL += " LEFT JOIN " + RetSQLName("GCW") + " GCW ON GCW.GCW_CODCLI = GCY.GCY_CODCLI AND GCW.GCW_FILIAL = '" + xFilial("GCW") + "' AND GCW.D_E_L_E_T_ <> '*' "
cSQL += " WHERE GAV.GAV_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND GAV.D_E_L_E_T_ <> '*' "
cSQL += " AND GAV.GAV_CODLOC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
 
cSQL += " AND GAV.GAV_STATUS IN ("+IIF(MV_PAR13 == 1,"'1'"," '0','1' ")+", '5','2')" 
  
If MV_PAR14 # 2  
	cSQL += " AND GAV.GAV_ESTATI = '1' " 
EndIf
 
cSQL += " ORDER BY "
 
If (MV_PAR11 == 1 .AND. MV_PAR12 == 1)
	cSQL += " GCY_NOME "
ElseIf (MV_PAR11 == 1 .AND. MV_PAR12 == 2)
	cSQL += " GAV_CODLOC,GCY_NOME "
ElseIf MV_PAR11 == 2 
	cSQL += " GAV_CODLOC,GAV_QUARTO, GAV_LEITO "
ElseIf (MV_PAR11 == 3 .AND. MV_PAR12 == 1)
	cSQL += " RA_NOME "
ElseIf (MV_PAR11 == 3 .AND. MV_PAR12 == 2)
	cSQL += " GAV_CODLOC,RA_NOME "
EndIf  
 
cSQL :=  ChangeQuery(cSQL)

TCQUERY cSQL NEW ALIAS "QRY"
DbSelectArea("QRY")
DbGoTop()
                                
If Eof()
	HS_MsgInf(STR0006, STR0015, STR0016) //"Nenhum dado foi encontado para a selecao efetuada!"###"Aten็ใo"###"Verifique a sele็ใo"
	QRY->(DbCloseArea())
	Return(Nil)
Endif

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/

SetRegua(500)

While QRY->(!EOF())

	IncRegua()
   
	If lAbortPrint
		@nLin,00 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
   
	If nLin > nMaxLin
		/*              		             1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                			       0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
		Cabec1 := STR0008//"Quarto  Leito Estat Nome                                          Pront.  Atend.  Dt. Ent.  Hr. Ent.  Acomp.  Permanencia  Convenio                      Medico Resp.                    Clinica"
		Cabec2 := "" 
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

	If MV_PAR12 == 2 //Quebra Setor
		If cCodLoc <> QRY->GAV_CODLOC 
			If !EMPTY(cCodLoc)
				FS_LeiSeto(cCodLoc)   	      
				@nLin,007 PSAY STR0028 + TRANSFORM(aVetDados[1][1], "@E 99,999")                    //"Total de Leitos Estatisticos no Setor"
				@nLin,062 PSAY STR0029 + TRANSFORM(nTotOcuEst, "@E 99,999")                         //"Ocupados (Estatisticos)"
				@nLin,110 PSAY STR0030 + TRANSFORM((nTotOcuEst/aVetDados[1][1]) * 100, "@E 999.99") //"% de Ocupacao (Estatisticos)"
				nLin++
				@nLin,007 PSAY STR0010 + TRANSFORM(aVetDados[1][2], "@E 99,999")                    //Total de Leitos no Setor" 
				@nLin,062 PSAY STR0024 + TRANSFORM(nTotOcu, "@E 99,999")                            //"Ocupados"
				@nLin,110 PSAY STR0025 + TRANSFORM((nTotOcu/aVetDados[1][2]) * 100, "@E 999.99")    //"% de Ocupacao"
				nLin +=2
			EndIf         
			@nLin,000 PSAY STR0011 + QRY->GAV_CODLOC + " - " + QRY->GCS_NOMLOC + "("+HS_RDescrB("GCS_TIPLOC", QRY->GCS_TIPLOC)+")" //"Setor..: "
			cCodLoc := QRY->GAV_CODLOC
			nTotOcu := 0
			nTotOcuEst := 0
			nLin +=2
		EndIf
	EndIf 
	If MV_PAR12 <> 2 //Quebra Setor
		If cCodLoc <> QRY->GAV_CODLOC
			cCodLoc := QRY->GAV_CODLOC  
			If !EMPTY(cCodLoc)  
				FS_LeiSeto(cCodLoc) 
			Endif
		Endif
	Endif                   
                  
	@nLin,000 PSAY QRY->GAV_QUARTO
	@nLin,008 PSAY QRY->GAV_LEITO
	@nLin,014 PSAY IIF(QRY->GAV_ESTATI == "1",STR0012,STR0013)
	@nLin,020 PSAY SUBSTR(QRY->GCY_NOME,1,45)
	@nLin,066 PSAY QRY->GCY_REGGER
	@nLin,074 PSAY QRY->GCY_REGATE
	@nLin,082 PSAY DTOC(STOD(QRY->GCY_DATATE)) 
	@nLin,092 PSAY QRY->GCY_HORATE
	DO CASE
		CASE QRY->GCY_ACOMPA == "0"
			@nLin,102 PSAY STR0012//"Sim"
		CASE QRY->GCY_ACOMPA == "1"
			@nLin,102 PSAY STR0013//"Nao"
	END CASE  
	If !EMPTY(QRY->GCY_DATATE)
		@nLin,110 PSAY STRZERO (DDATABASE - STOD(QRY->GCY_DATATE),4)
	Else   
		@nLin,110 PSAY "   "    
	Endif
	@nLin,124 PSAY SUBSTR(QRY->GCM_DESPLA, 1, 28)
	@nLin,154 PSAY SUBSTR(QRY->RA_NOME, 1, 30)
	@nLin,186 PSAY QRY->GCW_DESCLI

	If !EMPTY(QRY->GCY_REGATE)
		nTotOcuEst := nTotOcuEst + IIF(QRY->GAV_ESTATI == "1",1,0)
		nTotOcGEst := nTotOcGEst + IIF(QRY->GAV_ESTATI == "1",1,0)
		nTotOcu ++
		nTotOcuG ++
	EndIf
  
	QRY->(dbSkip()) /* Avanca o ponteiro do registro no arquivo */  
  
	nLin +=2
  
	If QRY->(EOF())
		If MV_PAR12 == 2 //Quebra Setor 
			If cCodLoc <> QRY->GAV_CODLOC 
				If !EMPTY(cCodLoc)
					FS_LeiSeto(cCodLoc)
				EndIf
			EndIf	
			@nLin,007 PSAY STR0028 + TRANSFORM(aVetDados[1][1], "@E 99,999")                   //"Total de Leitos Estatisticos no Setor"
			@nLin,062 PSAY STR0029 + TRANSFORM(nTotOcuEst, "@E 99,999")                        //"Ocupados (Estatisticos) "
			@nLin,110 PSAY STR0030 + TRANSFORM((nTotOcuEst/aVetDados[1][1]) * 100, "@E 999.99")//"% de Ocupacao (Estatisticos)"
			nLin++
			@nLin,007 PSAY STR0010 + TRANSFORM(aVetDados[1][2], "@E 99,999")                   //"Total de Leitos no Setor"
			@nLin,062 PSAY STR0024 + TRANSFORM(nTotOcu, "@E 99,999")                           //"Ocupados "
			@nLin,110 PSAY STR0025 + TRANSFORM((nTotOcu/aVetDados[1][2]) * 100, "@E 999.99")   //"% de Ocupacao" "
		EndIf 
		nLin += 2

		@nLin,000 PSAY STR0031 + TRANSFORM(nGTotLeiEst, "@E 99,999")                      //"Total Geral de Leitos Estatisticos"
		@nLin,062 PSAY STR0032 + TRANSFORM(nGTotOcuEst, "@E 99,999")                      //"Ocupados Geral (Estatisticos)"
		@nLin,110 PSAY STR0033 + TRANSFORM((nGTotOcuEst/nGTotLeiEst) * 100, "@E 999.99")  //"% de Ocupacao Geral (Estatisticos)"
		nLin++ 
		@nLin,000 PSAY STR0014 + TRANSFORM(nGTotLei, "@E 99,999")                         //"Total de Leitos Geral"
		@nLin,062 PSAY STR0026 + TRANSFORM(nGTotOcup, "@E 99,999")                        //"Ocupados Geral"
		@nLin,110 PSAY STR0027 + TRANSFORM((nGTotOcup/nGTotLei) * 100, "@E 999.99")       //"% de Ocupacao Geral"
	EndIf
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
QRY->(DBCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_LeiSetoบAutor  ณMicrosiga           บ Data ณ  01/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para Calculo dos Indices                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_LeiSeto(cCodLoc)

Local  	cSQL1 	   := ""
Local   aArea      := GetArea()
Local   nTotiOcuEst:=0
Local   nTotiOcu   :=0
Static  aVetSetor  :={}

/*
If aScan(aVetSetor, cCodLoc) > 0
	RestArea(aArea)
	return(aVetDados)
endif
*/

cSQL1 := "SELECT GAV.GAV_CODLOC,GAV.GAV_ESTATI,GAV_STATUS,COUNT(*) QTDE"
cSQL1 += " FROM " + RetSQLName("GAV") + " GAV"
cSQL1 += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GAV.GAV_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
cSQL1 += " LEFT JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GAV.GAV_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
cSQL1 += "                                             AND GCY.GCY_CODCRM BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
cSQL1 += " LEFT JOIN " + RetSQLName("GD4") + " GD4 ON GD4.GD4_REGGER = GCY.GCY_REGGER AND GD4.GD4_FILIAL = '" + xFilial("GD4") + "' AND GD4.D_E_L_E_T_ <> '*' "
cSQL1 += "                                        AND GD4.GD4_IDPADR = '1' AND GD4.GD4_CODPLA BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
cSQL1 += "                                        AND GD4.GD4_CODCON BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
cSQL1 += " LEFT JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GD4.GD4_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
cSQL1 += " LEFT JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GCY.GCY_CODCRM AND SRA.RA_FILIAL = '" +  xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
cSQL1 += " LEFT JOIN " + RetSQLName("GCW") + " GCW ON GCW.GCW_CODCLI = GCY.GCY_CODCLI AND GCW.GCW_FILIAL = '" + xFilial("GCW") + "' AND GCW.D_E_L_E_T_ <> '*' "
cSQL1 += " WHERE GAV.GAV_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND GAV.D_E_L_E_T_ <> '*' "
cSQL1 += " AND GAV.GAV_CODLOC ='"+cCodLoc+"' "
cSQL1 += " AND GAV_STATUS NOT IN('4')"
cSQL1 += "GROUP BY GAV.GAV_CODLOC,GAV.GAV_ESTATI,GAV_STATUS "
cSQL1 += " ORDER BY GAV_CODLOC "

cSQL1 :=  ChangeQuery(cSQL1)


TCQUERY cSQL1 NEW ALIAS "QRY_ESTAT"
DbSelectArea("QRY_ESTAT")
DbGoTop()

While QRY_ESTAT->(!Eof())
	
	If QRY_ESTAT->GAV_ESTATI == '1'
		nTotLeiEst +=QRY_ESTAT->QTDE //total de leitos estatico no Setor
	Else
		nTotLeNEst +=QRY_ESTAT->QTDE//total de leitos Nใo estatico no Setor
	Endif
	
	If QRY_ESTAT->GAV_STATUS $ ("125")  .and. QRY_ESTAT->GAV_ESTATI == '1'
		nTotiOcuEst+=QRY_ESTAT->QTDE  //leitos  estaticos ocupados
	Endif
	
	If QRY_ESTAT->GAV_STATUS $ ("125")
		nTotiOcu+=QRY_ESTAT->QTDE   //leitos ocupados
	Endif
	
	nTotLei      := nTotLeNEst + nTotLeiEst     //Total Leitos no setor       (Total leitos nao estaticos no setor + Total leitos estaticos no setor)
	nPercEstatic :=(nTotiOcuEst/nTotLeiEst)*100 //Percentual leitos estaticos (Total leitos estaticos ocupados / Total leitos estaticos no setor)
	nPercOcup    :=(nTotiOcu/nTotLei)*100       //Percentual leitos ocupados  (Total leitos ocupados / Total leitos no setor)
	QRY_ESTAT->( DbSkip())
	
EndDo

QRY_ESTAT->(dbCloseArea())

aVetDados:={}

AADD(aVetDados, {	nTotLeiEst,  ; //Total Setor : Total Leitos Estatisticos Setor
					nTotLei,     ; //Total Setor : Total Leitos no Setor
					nTotiOcuEst, ; //Total Setor : Ocupados (Estatisticos)
					nPercEstatic,; //Total Setor : Ocupados % (EstatIsticos)
					nPercOcup,   ; //Total Setor : Ocupados %
					cCodLoc,     ;
					nTotiOcu})     //Total Setor : Ocupados

if cCodDp <> cCodLoc
  nGTotLeiEst		+= aVetDados[1][1]               //Total Geral : Total Leitos Estatํsticos Setor
  nGTotLei		    += aVetDados[1][2]               //Total Geral : Total Leitos no Setor
  nGTotOcuEst		+= nTotiOcuEst                   //Total Geral : Ocupados Geral (Estatisticos)
  nGPercEstatic 	:= (nGTotOcuEst/nGTotLeiEst)*100 //Total Geral : Ocupados % (Estatisticos)
  nGTotOcup	    	+= nTotiOcu                      //Total Geral : Ocupados Geral
  nGPercOcup		:= (nGTotOcup/nGTotLei)*100      //Total Geral : Ocupados %
EndIf

nTotLeiEst		:=0
nTotLei			:=0
nTotiOcuEst		:=0
nPercEstatic	:=0
nPercOcup		:=0
nTotLeNEst		:=0
nTotiOcu		:=0

cCodDp:=cCodLoc

If aScan(aVetSetor, cCodDp) == 0
	AADD(aVetSetor,cCodDp)
Endif
RestArea(aArea)

return(aVetDados) 
