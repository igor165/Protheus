#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"    
#INCLUDE "TMSRO41.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSRO41³ Autor ³Guilherme R. Gaiofatto³ Data ³06/02/13     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Apontamentos de Justificativas                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSRO41()
Local oReport
Local aArea := GetArea()

oReport := ReportDef()
oReport:PrintDialog()

RestArea(aArea)
     
Return    

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSRO41³ Autor ³Guilherme R. Gaiofatto³ Data ³06/02/13     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

Local oReport
Local oApont 
Local oViag
Local oMot
Local cAliasQry   := GetNextAlias()

oReport := TReport():New("TMSRO41",STR0001,"TMSRO41", {|oReport| ReportPrint(oReport,cAliasQry)},STR0002)
oReport:SetTotalInLine(.F.)
oReport:SetLandscape()
Pergunte("TMSRO41",.F.)

oMot := TRSection():New(oReport,STR0003,{"DAX","DAY"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oMot:SetTotalInLine(.F.)  
TRCell():New(oMot,"DAY_CODMOT"	,"DAY",RetTitle("DAY_CODMOT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasQry)->DAY_CODMOT })
TRCell():New(oMot,"DAY_NOMMOT"	,"DAY",RetTitle("DAY_NOMMOT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Posicione("DA4",1,xFilial("DA4")+(cAliasQry)->DAY_CODMOT,"DA4_NOME") })
 
oApont := TRSection():New(oMot,STR0001,{"DAX","DAY"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oApont:SetTotalInLine(.F.)  
TRCell():New(oApont,"DAY_APTJOR"	,"DAY",RetTitle("DAY_APTJOR"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasQry)->DAY_APTJOR }) 
TRCell():New(oApont,"DAY_DESAPT"	,"DAY",RetTitle("DAY_DESAPT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| M->DAY_APTJOR := (cAliasQry)->DAY_APTJOR, TMSVALFIELD("M->DAY_APTJOR",.F.,"DAY_DESAPT") })
TRCell():New(oApont,"DAY_DATAPT"	,"DAY",RetTitle("DAY_DATAPT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasQry)->DAY_DATAPT })
TRCell():New(oApont,"DAY_HORAPT"	,"DAY",RetTitle("DAY_HORAPT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasQry)->DAY_HORAPT })  
TRCell():New(oApont,"DAY_CODJUS"	,"DAY",RetTitle("DAY_CODJUS"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasQry)->DAY_CODJUS }) 
TRCell():New(oApont,"DAY_DESJUS"	,"DAY",RetTitle("DAY_DESJUS"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Posicione("DAX",1,xFilial("DAX")+(cAliasQry)->DAY_CODJUS,"DAX_DESJUS") })
TRCell():New(oApont,"DAY_FILORI"	,"DAY",RetTitle("DAY_FILORI"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasQry)->DAY_FILORI })
TRCell():New(oApont,"DAY_VIAGEM"	,"DAY",RetTitle("DAY_VIAGEM"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasQry)->DAY_VIAGEM })
TRCell():New(oApont,"DAY_MOTAPT" ,"DAY",RetTitle("DAY_MOTAPT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (DAY->(DbGoTo((cAliasQry)->DAYRECNO)),DAY->DAY_MOTAPT) }) 
TRCell():New(oApont,"DAY_OBS"   	,"DAY",RetTitle("DAY_OBS")   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (DAY->(DbGoTo((cAliasQry)->DAYRECNO)),DAY->DAY_OBS)}) 

Return(oReport)  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSRO41³ Autor ³Guilherme R. Gaiofatto³ Data ³06/02/13     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function ReportPrint(oReport,cAliasQry) 

MakeSqlExpr(oReport:uParam)
oReport:Section(1):BeginQuery()

BeginSQL Alias cAliasQry                                                                  

	SELECT DAY.DAY_FILIAL, DAY.DAY_CODMOT, DAY.DAY_FILORI, DAY.DAY_VIAGEM, DAY.DAY_APTJOR, DAY.DAY_CODJUS, DAY.DAY_DATAPT, DAY.DAY_HORAPT,  DAY.R_E_C_N_O_ DAYRECNO
	
	FROM %table:DAY% DAY
	
	JOIN %table:DAX% DAX ON
 		DAX_FILIAL = %xFilial:DAY%
 		AND DAX_CODJUS = DAY_CODJUS
 		AND DAX_TIPJUS = %Exp:mv_par09%
 		AND DAX.%NotDel%  
	
	WHERE DAY.DAY_FILIAL = %xFilial:DAY%
			AND DAY_CODMOT    BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% 
			AND DAY_FILORI	   BETWEEN %Exp:mv_par03% AND %Exp:mv_par05%	
			AND DAY_VIAGEM    BETWEEN %Exp:mv_par04% AND %Exp:mv_par06%
			AND DAY_DATAPT    BETWEEN %Exp:mv_par07% AND %Exp:mv_par08% 
			AND DAY.%NotDel%
	
	ORDER BY DAY_FILIAL, DAY_CODMOT, DAY_APTJOR, DAY_DATAPT, DAY_HORAPT,DAY_FILORI, DAY_VIAGEM, DAYRECNO

EndSQL   

oReport:Section(1):EndQuery()     
oReport:Section(1):Section(1):SetParentQuery()  
oReport:Section(1):Section(1):SetParentFilter({ |cParam| (cAliasQry)->DAY_CODMOT == cParam },{ || (cAliasQry)->DAY_CODMOT})
 
oReport:Section(1):Print()
oReport:SetMeter(DAY->(LastRec()))

Return