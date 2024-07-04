#INCLUDE "QNCR160.CH"
#INCLUDE "Protheus.CH"
#include "report.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQNCR160   บAutor  ณLeandro             บ Data ณ  29/08/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Relatorio de Etapas x FNC Analitico                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QNCR160()
Local oReport
Local cPerg    := "QNC160"

If !QNCHECK()
	Return(NIL)
Endif

Pergunte(cPerg,.F.)
oReport := ReportDef()
oReport:PrintDialog()

Return

Static Function ReportDef()
Local oReport
Local oSection1 
Local oSection2
Local oSection3
Local oTotal 
Local oBreak
Local cTitulo:= OemToAnsi(STR0001)//"Relatorio de Etapas x FNC Analitico"
Local cDesc1 := OemToAnsi(STR0002)//"Este relatorio imprime uma relaoSIG das etapas por produto"
Local wnrel  := "QNCR160"
Local cPerg  := "QNC160"         



DEFINE REPORT oReport NAME wnrel TITLE cTitulo PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1)
oReport:SetLandscape(.T.)


DEFINE SECTION oSection1 OF oReport TITLE STR0012 TABLES "QI2","ADE", "QI5", "SA1" //"Modulo"        
DEFINE CELL NAME "QI2_CODPRO" OF oSection1 ALIAS "QI2"
DEFINE CELL NAME "QI2_NCHAMA" OF oSection1 ALIAS "QI2"  TITLE STR0016                                       
DEFINE CELL NAME "QI2_FNC"    OF oSection1 ALIAS "QI2"  
DEFINE CELL NAME "QI2_REV"    OF oSection1 ALIAS "QI2"  TITLE STR0017
DEFINE CELL NAME "QI3_CODIGO" OF oSection1 ALIAS "QI3"  
DEFINE CELL NAME "QI3_REV"    OF oSection1 ALIAS "QI3"  TITLE STR0017
DEFINE CELL NAME "ADE__ZLCRO" OF oSection1 ALIAS "ADE"  TITLE STR0018
DEFINE CELL NAME "ADE__VERSA" OF oSection1 ALIAS "ADE"  TITLE STR0019
DEFINE CELL NAME "QI2_TPFIC"  OF oSection1 ALIAS "QI2"  
DEFINE CELL NAME "ADE__BASED" OF oSection1 ALIAS "ADE"
DEFINE CELL NAME "ADE_SEVCOD" OF oSection1 ALIAS "ADE"  BLOCK {||QNCDOcor(ADE_SEVCOD)}
DEFINE CELL NAME "QI2_CODCAT" OF oSection1 ALIAS "QI2"  
DEFINE CELL NAME "ADE_DATA"   OF oSection1 ALIAS "ADE"  TITLE STR0014                                        
DEFINE CELL NAME "QI2_OCORRE" OF oSection1 ALIAS "QI2"  TITLE STR0015 
DEFINE CELL NAME "ADE_DTEXPI" OF oSection1 ALIAS "QI5"  
//DEFINE CELL NAME "cNOME"      OF oSection1 ALIAS "QI2"  SIZE 38 TITLE STR0003 BLOCK {||TKENTIDADE(ADE_ENTIDA,ADE_CHAVE,1)}//"Cliente"
DEFINE CELL NAME "cNOME"      OF oSection1 ALIAS "QI2"  SIZE 38 TITLE STR0003 BLOCK {||U_QNC160Ent(ADE_ENTIDA,ADE_CHAVE,1)}//"Cliente"

DEFINE SECTION oSection2 OF oSection1 TITLE STR0013 TABLES "QI2", "QI3" , "ADE"
DEFINE CELL NAME "ADE_CODINC"  OF oSection2 ALIAS "ADE" SIZE 60 TITLE "Incidente" 		BLOCK {||QNCGESP(ADE->ADE_CODINC,1)} 
oSection2:Cell("ADE_CODINC"):SeTLineBREAK(.T.)
DEFINE CELL NAME "QI2_DDETA"  OF oSection2 ALIAS "QI2"  SIZE 60 TITLE "Analise N1" 		BLOCK {||QNCGESP(QI2->QI2_DDETA,2)} 
oSection2:Cell("QI2_DDETA"):SeTLineBREAK(.T.)
DEFINE CELL NAME "QI3_RESESP" OF oSection2 ALIAS "QI3"  SIZE 60 TITLE "Analise N3" 		BLOCK {||QNCGESP(QI3->QI3_RESESP,3)}
oSection2:Cell("QI3_RESESP"):SeTLineBREAK(.T.)
DEFINE CELL NAME "QI3_METODO" OF oSection2 ALIAS "QI3"  SIZE 60 TITLE "Resultado CQ" 	BLOCK {||QNCGESP(QI3->QI3_METODO,4)}
oSection2:Cell("QI3_METODO"):SeTLineBREAK(.T.)


DEFINE SECTION oSection3 OF oSection2 TITLE STR0013 TABLES "QI2", "QI5", "QID" //"Ocorrencia"
DEFINE CELL NAME "QI5_REALIZ" OF oSection3 ALIAS "QI5"  SIZE TamSx3("QI5_REALIZ")[1]+1
DEFINE CELL NAME "QI5_MAT"    OF oSection3 ALIAS "QI5"  SIZE TamSx3("QI5_MAT")[1]+40  BLOCK {|| QI5_MAT +" - "+ QA_NUSR(QI5_FILMAT,QI5_MAT,.F.,"A")}//"Responsavel"
DEFINE CELL NAME "QI5_TPACAO" OF oSection3 ALIAS "QI5"  SIZE TamSx3("QI5_TPACAO")[1]+1 TITLE STR0004 //"Etapa"
DEFINE CELL NAME "cDESCTP"    OF oSection3 ALIAS "QI5"  SIZE TamSx3("QID_DESCTP")[1]+1 TITLE STR0005 BLOCK {||QNCDAcao(QI5_TPACAO)}
DEFINE CELL NAME "QI5_STATUS" OF oSection3 ALIAS "QI5"  SIZE TamSx3("QI5_STATUS")[1]+1 BLOCK {||QNCDExe(QI5_STATUS)}
DEFINE CELL NAME "QI5_TAREFA" OF oSection3 ALIAS "QI5"  SIZE TamSx3("QI5_TAREFA")[1]+1


oTotal := oReport:Section(1)
TRFunction():New(oSection1:Cell("ADE_SEVCOD"),Nil,"COUNT", oBreak ,,"@E 999.99",,.F.,.T.,.F.)

Return oReport

                                         
/*                                                       
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ           
ฑฑบPrograma  ณReportPrinบAutor  ณLeandro             บ Data ณ  29/08/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio Personalizavel                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณQNCR160()                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
                  
Static Function PrintReport(oReport) 
Local cOcorI	:= 0
Local cOcorF 	:= 0
Local cServI    := 0
Local cServF    := 0
Local nCont		:= 0
Local aEtapas	:= {}
Local cEtapas	:= ""
Local cQueryFNC	:= ""
Local cQueryADE	:= ""
Local cQuerySLA	:= ""
Local cQueryVer := ""
Local cReal     := ""
Local cQueryDt  := ""
Local cQueryETP := "" 
Local lAltQry	:= ExistBlock("QNALTQRY")      //Ponto de Entrada para permitir que a query para sele็ใo de dados seja reescrita

Private cAlias  := "QI2"

//"Ocorrencia"
If mv_par09 = 1 //"N Conf. Existente"
	cOcorI := "2"
	cOcorF := "2"
Else
	If mv_par09 == 2 //"N Conf. Potencial"
		cOcorI:= "1"
		cOcorF:= "1"
	Else
		If mv_par09 == 3//"Melhoria"
			cOcorI := "3" 
			cOcorF := "3"
		Else
			cOcorI:= "0"//"Todos"
			cOcorF:= "3" 
		Endif						
	Endif
Endif			

//"Severidade"	 
Do Case
	Case mv_par11 == 1 //"Baixa"
		cServI:= "2"
		cServF:= "2"
	Case mv_par11 == 2 //"Media"
		cServI := "3" 
		cServF := "3"
	Case mv_par11 == 3 //"Alta"
		cServI:= "4" 
		cServF:= "4" 
	Case  mv_par11 == 4 //"Critica"
		cServI:= "5" 
		cServF:= "5" 
	Case mv_par11 == 5	//"Todos"
		cServI:= "1" 
		cServF:= "5" 
EndCase

	                     
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ                             Abaixo segue a classificacao da nao conformidade usada pelo TMK															  ณ
//ณSeveridade do chamado	                        QI2_PRIORI	     QI2_TPFIC	                      QI2_STATUS              ณ
//-----------------------------------------------------------------------------------------------------------------           ณ
//ณRequisi็ใo de altera็ใo de especifica็ใo (1)	     Baixa (1)	     Melhoria (3)	                  Procede (3)             ณ
//ณBaixa (2)	                                     Baixa (1)	   Nใo-Conformidade Existente (2)     Procede (3)             ณ
//ณM้dia (3)	                                     M้dia (2)	   Nใo-Conformidade Existente (2)	  Procede (3)             ณ
//ณAlta (4)	                                         Alta (3)	   Nใo-Conformidade Existente (2)	  Procede (3)             ณ     
//ณCritica (5)	                                     Alta (3)	   Nใo-Conformidade Existente (2)	  Procede (3)             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู



MakeSqlExpr(oReport:GetParam())
			
oReport:Section(1):BeginQuery()
    
cAlias := GetNextAlias()+"QI2"
//----------------------------------------------------------------------------------------------//
cQueryFNC:="% "
If !Empty(mv_par03) .And. !Empty(mv_par04)
	cQueryFNC+= "QI2.QI2_OCORRE BETWEEN '"+DTOS(mv_par03)+"' and '"+DTOS(mv_par04)+"' and "
EndIf
cQueryFNC+=" %"
//----------------------------------------------------------------------------------------------//
cQueryDt:="% "
If !Empty(mv_par05) .And. !Empty(mv_par06)
	cQueryDt+= "QI2.QI2_CONREA BETWEEN '"+DTOS(mv_par05)+"' and '"+DTOS(mv_par06)+"' and "
EndIf
cQueryDt+=" %"
//----------------------------------------------------------------------------------------------//
cReal := "% "
If mv_par10 = 1 //Aberto
	cReal += "QI2.QI2_CONREA = ' ' and QI2.QI2_OBSOL <> 'S'  and "
Else
	If mv_par10 == 2 //Encerrado
		cReal += "QI2.QI2_CONREA <> ' ' and "
	Else
		If mv_par10 == 3 //Rejeitado
			cReal += "QI2.QI2_CONREA <> ' '  and QI2.QI2_OBSOL <> 'S'  AND "
		Endif
	Endif
Endif
cReal += " %"
    //----------------------------------------------------------------------------------------------//
//"Tipo de impressao da etapa"	 
cQueryETP:="% "
Do Case
Case mv_par24 == 1 //"Somente c/ tarefas pendentes"
	cQueryETP += "QI5.QI5_STATUS < '4' and QI5.QI5_TAREFA <> ' ' AND "
Case mv_par24 == 2 //"Somente c/ tarefas encerradas"
	cQueryETP += "QI5.QI5_STATUS = '4' and QI5.QI5_TAREFA <> ' ' AND"
Case mv_par24 == 3 //"Sem tarefas"
	cQueryETP += "QI5.QI5_STATUS <> '4' and QI5.QI5_TAREFA = ' ' AND"
//		Case mv_par24 == 4 //"Todas"
  //			cQueryETP += "QI5.QI5_STATUS <> '5' AND"	   		
EndCase
cQueryETP+=" %"
//----------------------------------------------------------------------------------------------//	
cQueryADE:="% "
If !Empty(mv_par31) .And. !Empty(mv_par32)
	cQueryADE+= "ADE.ADE_DATA BETWEEN '"+DTOS(mv_par31)+"' and '"+DTOS(mv_par32)+"' and "
EndIf
cQueryADE+=" %"
//----------------------------------------------------------------------------------------------//
cQuerySLA:="% "
If !Empty(mv_par35) .And. !Empty(mv_par36)
	cQuerySLA+= "ADE.ADE_DTEXPI BETWEEN '"+DTOS(mv_par35)+"' and '"+DTOS(mv_par36)+"' and "
EndIf
cQuerySLA+=" %"
//----------------------------------------------------------------------------------------------//    
    
cEtapas := ""
cEtapas += "% ("
If !Empty(mv_par46)
	aEtapas := StrTokArr(AllTrim(mv_par46),";")
	For nCont := 1 To Len(aEtapas)
		cEtapas += "QI5.QI5_TPACAO = '" + aEtapas[nCont] + "'"
		If nCont<Len(aEtapas)
			cEtapas += " OR "
		EndIf
	Next nCont
Else
	cEtapas += "QI5.QI5_TPACAO BETWEEN '" + mv_par22 + "' AND '" + mv_par23 + "'"
EndIf
cEtapas += ") %"

If lAltQry   //nใo serแ executada a quety existente no padrใo - ****PE QNALTQRY
	cAlias := ExecBlock("QNALTQRY",.F.,.F.,{cEtapas})
Else
	BeginSql Alias cAlias
	    
		SELECT DISTINCT
		QI2.QI2_CODPRO, QI2.QI2_NCHAMA,QI2.QI2_CODORI,  QI2.QI2_CODEFE, QI2.QI2_CODCAT, QI2.QI2_CODCAU, QI2.QI2_FNC,
		QI2.QI2_REV   , QI2.QI2_TPFIC , QI2.QI2_REGIST, QI2.QI2_OCORRE, QI2.QI2_CODCLI, QI2.QI2_DESCR, QI2.QI2_FILIAL,
		QI5.QI5_CODIGO, QI5.QI5_REV   , QI5.QI5_MAT   , QI5.QI5_REALIZ, QI5.QI5_TPACAO, QI5.QI5_STATUS, QI5.QI5_SEQ,
		ADE.ADE_CHAVE , QI2.QI2_DDETA , ADE.ADE_SEVCOD, ADE.ADE_DATA  , ADE.ADE_GRUPO,  ADE.ADE_ENTIDA, ADE.ADE_FNCFIL,
		ADE.ADE_DTEXPI, QI3.QI3_RESESP, QI3.QI3_METODO, QI5.QI5_FILMAT, QI2.QI2_CONPRE , QI5.QI5_PRAZO, QI3.QI3_FILIAL,
		QI5.QI5_STATUS, QI5.QI5_TAREFA, QI3.QI3_CODIGO, QI3.QI3_REV, ADE.ADE_FNC, ADE.ADE_FNCREV, QI2.QI2_CODACA, QI2.QI2_REVACA,
		QI5.QI5_FILIAL
		FROM %table:QI2% QI2, %table:QI5% QI5, %table:QI9% QI9,%table:QI3% QI3, %table:ADE% ADE
		WHERE QI2.QI2_FILIAL = %xFilial:QI2%  AND
		QI2.QI2_CODACA = QI3.QI3_CODIGO AND
		QI2.QI2_REVACA = QI3.QI3_REV    AND
		QI3.QI3_FILIAL = QI5.QI5_FILIAL AND
		QI3.QI3_CODIGO = QI5.QI5_CODIGO AND
		QI3.QI3_REV    = QI5.QI5_REV    AND
		QI2.QI2_FILIAL = ADE.ADE_FNCFIL AND
		QI2.QI2_FNC    = ADE.ADE_FNC    AND
		QI2.QI2_REV    = ADE.ADE_FNCREV AND
		QI2.QI2_CODPRO BETWEEN %Exp:mv_par01%  AND %Exp:mv_par02% AND
		%Exp:cQueryFNC%
		QI2.QI2_FNC    BETWEEN %Exp:mv_par07%  AND %Exp:mv_par08% AND
		%Exp:cQueryDt%
		QI2.QI2_TPFIC  BETWEEN %Exp:cOcorI%    AND %Exp:cOcorF%   AND
		QI2.QI2_CODORI BETWEEN %Exp:mv_par12%  AND %Exp:mv_par13% AND
		QI2.QI2_CODEFE BETWEEN %Exp:mv_par14%  AND %Exp:mv_par15% AND
		QI2.QI2_CODCAT BETWEEN %Exp:mv_par16%  AND %Exp:mv_par17% AND
		QI2.QI2_CODCAU BETWEEN %Exp:mv_par18%  AND %Exp:mv_par19% AND
		QI2.QI2_DESDEP BETWEEN %Exp:mv_par33%  AND %Exp:mv_par34% AND
		%Exp:cReal%
		QI5.QI5_MAT    BETWEEN %Exp:mv_par20%  AND %Exp:mv_par21% AND
		QI5.QI5_TPACAO BETWEEN %Exp:mv_par22%  AND %Exp:mv_par23% AND
		%Exp:cQueryETP%                                       //CONSIDERAR O TAMANHO TOTAL
		ADE.ADE_CHAVE  BETWEEN %Exp:mv_par25+mv_par26% AND %Exp:mv_par27+mv_par28% AND
		ADE.ADE_SEVCOD BETWEEN %Exp:cServI%    AND %Exp:cServF%   AND
		%Exp:cQueryADE%
		ADE.ADE_CODIGO = QI2.QI2_NCHAMA AND
		%Exp:cQuerySLA%
		ADE.ADE_FNCFIL = QI2.QI2_FILIAL AND ADE.ADE_FNC = QI2.QI2_FNC AND ADE.ADE_FNCREV = QI2.QI2_REV AND
		QI2.%notDel% AND QI5.%notDel%
		Order By ADE.ADE_CHAVE,QI2.QI2_CODPRO, QI2.QI2_NCHAMA,QI2.QI2_FNC, QI2.QI2_REV, QI5.QI5_SEQ, QI5.QI5_TPACAO

	EndSql
Endif
oReport:Section(1):EndQuery( /*Array com os parametros do tipo Range*/)
CTESTE:= oReport:Section(1):CQuery



oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter({|cParam| (cAlias)->QI2_FILIAL+(cAlias)->QI2_FNC+(cAlias)->QI2_REV == cParam },;
	{||        (cAlias)->ADE_FNCFIL+(cAlias)->ADE_FNC+(cAlias)->ADE_FNCREV})


oReport:Section(1):Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):Section(1):SetParentFilter({|cParam|	(cAlias)->QI3_FILIAL+(cAlias)->QI3_CODIGO+(cAlias)->QI3_REV   +(cAlias)->QI5_FILIAL+(cAlias)->QI5_CODIGO+(cAlias)->QI5_REV == cParam },;
	{||                  	(cAlias)->QI2_FILIAL+(cAlias)->QI2_CODACA+(cAlias)->QI2_REVACA+(cAlias)->QI2_FILIAL+(cAlias)->QI2_CODACA+(cAlias)->QI2_REVACA})

oReport:Section(1):Print()


Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQNCDAcao  บAutor  ณLeandro Sabino      บ Data ณ  29/08/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a descricao da acao      						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QNCDAcao(cAcao)                     
Local cDesc := ""
cDesc := Posicione('QID',1,xFilial('QID')+cAcao,'QID_DESCTP')
Return cDesc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQNCDOcor  บAutor  ณLeandro Sabino      บ Data ณ  02/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a descricao da ocorrencia   						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QNCDOcor(cOcorrencia)                     
Local cDesc := ""

DO CASE
CASE cOcorrencia == "1" 
	cDesc := STR0007 //"Requisicao de alteracao de especificacao"
CASE cOcorrencia == "2" 
	cDesc := STR0008 //"Baixa"
CASE cOcorrencia == "3" 
	cDesc := STR0009 //"Media"
CASE cOcorrencia == "4" 
	cDesc := STR0010 //"Alta"
CASE cOcorrencia == "5" 
	cDesc := STR0011 //"Critica"
EndCASE

Return cDesc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQNCDExe   บAutor  ณLeandro Sabino      บ Data ณ  09/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a descricao da porcentagem de execucao da tarefa   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QNCDExe(cStatus)                     
Local cPercExec
    Do case 
       case cStatus = "1"
           cPercExec := " 0% a 25%"       	   
       case cStatus = "2"
        	cPercExec := " 25% a 50%"       	    
       case cStatus = "3"
   		    cPercExec := "50% a 100%"       	    
       case cStatus = "4"
		    cPercExec := "100%"
	   case cStatus = "5"	    
		    cPercExec := "Rejeitado"       	    
    EndCase
Return cPercExec


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQNCGESP   บAutor  ณLeandro Sabino      บ Data ณ  09/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a descricao da analise    						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QNCGESP(cCodigo,nTipo)
Local ctexto := ""

If nTipo == 1  // Descricao do Incidente no chamado
	If mv_par37 = 1
		ctexto := MSMM(cCodigo,,,,3)
	Endif	       

ElseIf nTipo == 2 // Descricao da analise do N1
	If mv_par37 = 1
		ctexto := MSMM(cCodigo,,,,3)
	Endif	       

ElseIf nTipo == 3 // Descricao da analise do N3
	If mv_par38 = 1
		ctexto := MSMM(cCodigo,,,,3)
	Endif	       

ElseIf nTipo == 4 // Descricao do Resultado de CQ
	If mv_par39 = 1
		ctexto := MSMM(cCodigo,,,,3)
	Endif	       
EndIf	

Return  ctexto



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQNCGMET   บAutor  ณLeandro Sabino      บ Data ณ  09/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a descricao do resultado do CQ   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QNCGMET(cCodigo)
Local ctexto := ""
If mv_par38 = 1
	cTexto := MSMM(cCodigo)
Endif
Return  ctexto
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQNCGPRO   บAutor  ณLeandro Sabino      บ Data ณ  16/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a descricao do problema          				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QNCGPRO(cCodigo)
Local ctexto := ""
If mv_par39 = 1
	cTexto := MSMM(cCodigo)
Endif
Return  ctexto
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 QNC160Ent         ณ Autor ณ Vendas Clientes       ณ Data ณ 23/05/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณCarrega os campos da ENTIDADE selecionada				        	 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso   	 ณAP7 Call Center						     				         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function QNC160Ent(cEntidade,cChave,nTipo,nOrdEnt)

/*
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณA ordem dos campos deve seguir a lista abaixo - se for incluido ou alterado algum  ณ
	ณcampo isso sempre deve ser feito para todas as ENTIDADES                           ณ
	ณ                                                                                   ณ
	ณ01 - Nome                                                                          ณ
	ณ02 - Endereco                                                                      ณ
	ณ03 - Municipio                                                                     ณ
	ณ04 - Estado                                                                        ณ
	ณ05 - CEP                                                                           ณ
	ณ06 - Telefone  - Comercial - 1                                                     ณ 
	ณ07 - E-mail                                                                        ณ
	ณ08 - Homepage                                                                      ณ
	ณ09 - DDD				                                                            ณ
	ณ10 - BAIRRO	                                                                    ณ
	ณ11 - Fantasia	                                                                    ณ
	ณ12 - Loja	                                                                    	ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/

Local cCampo:= ""				//Nome do campo da entidade
Local cDesc := ""				//Retorno da funcao

Local aSA1Cpo := {}



Default nOrdent	:= 1

lProspect := .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPara proteger a funcao caso ocorra algum problema de integridadeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(cEntidade).OR. Empty(cChave)
	Return(cDesc)
Endif


If cEntidade == "SA1"  //Cliente

	// Vetor com os campos da SA1 - Clientes
	//              1    ,    2    ,   3    ,  4     ,   5    ,   6    ,     7    ,    8      ,  9    ,     10     ,    11     ,   12
	aSA1Cpo	:= {"A1_NOME","A1_END","A1_MUN","A1_EST","A1_CEP","A1_TEL","A1_EMAIL","A1_HPAGE","A1_DDD","A1_BAIRRO","A1_NREDUZ","A1_LOJA"}
	cCampo := aSA1Cpo[nTipo]

	If !Empty(cCampo)
		cDesc := CRIAVAR(cCampo,.F.)
		cDesc := ALLTRIM(Posicione(cEntidade,nOrdEnt,xFilial(cEntidade) + cChave,cCampo)) 
		
		If Empty(cDesc)
			cDesc := "*ENTIDADE NAO ENCONTRADA*"
		EndIf
	Endif
ElseIf cEntidade == "RD0"  //Cliente	
	cDesc := ALLTRIM(Posicione(cEntidade,nOrdEnt,xFilial(cEntidade) + AllTrim(cChave),"RD0_NOME")) 
	If Empty(cDesc)
		cDesc := "*ENTIDADE NAO ENCONTRADA*"
	EndIf
ElseIf cEntidade == "ADK"  //Cliente	
	cDesc := ALLTRIM(Posicione(cEntidade,nOrdEnt,xFilial(cEntidade) + AllTrim(cChave),"ADK_NOME")) 
	If Empty(cDesc)
		cDesc := "*ENTIDADE NAO ENCONTRADA*"
	EndIf
Else
	cDesc := "*ENTIDADE NAO ENCONTRADA*"
EndIf

Return(cDesc)
