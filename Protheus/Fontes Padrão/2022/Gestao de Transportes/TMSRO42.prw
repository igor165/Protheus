#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH" 
#INCLUDE "TMSRO42.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSRO42³ Autor ³Guilherme R. Gaiofatto³ Data ³06/02/13     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSRO42()
Local oReport
Local aArea := GetArea()

oReport := ReportDef()
oReport:PrintDialog()

RestArea(aArea)
     
Return    

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSRO42³ Autor ³Guilherme R. Gaiofatto³ Data ³06/02/13     º±±
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
Local aJorn 
Local oMot
Local cAliasQry   := GetNextAlias()
Local aSx3Box := RetSx3Box( Posicione('SX3', 2, "DEW_TIPAPT", 'X3CBox()' ),,, 1 )

oReport := TReport():New("TMSRO42",STR0001,"TMSRO42", {|oReport| ReportPrint(oReport,cAliasQry)},STR0002)
oReport:SetTotalInLine(.F.)
oReport:SetLandscape()
Pergunte("TMSRO42",.F.)

oMot := TRSection():New(oReport,STR0003,{"DEW"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oMot:SetTotalInLine(.F.)  
TRCell():New(oMot,"DEW_CODMOT"	,"DEW",RetTitle("DEW_CODMOT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasQry)->DEW_CODMOT })
TRCell():New(oMot,"DEW_NOMMOT"	,"DEW",RetTitle("DEW_NOMMOT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Posicione("DA4",1,xFilial("DA4")+(cAliasQry)->DEW_CODMOT,"DA4_NOME") })
 
aJorn := TRSection():New(oMot,STR0004,{"DEW"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
aJorn:SetTotalInLine(.F.)  
TRCell():New(aJorn,"DEW_DATAPT"	,"DEW",RetTitle("DEW_DATAPT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasQry)->DEW_DATAPT })
TRCell():New(aJorn,"DEW_HORAPT"	,"DEW",RetTitle("DEW_HORAPT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasQry)->DEW_HORAPT })
TRCell():New(aJorn,"DEW_APTJOR"	,"DEW",RetTitle("DEW_APTJOR"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasQry)->DEW_APTJOR }) 
TRCell():New(aJorn,"DEW_DESAPT"	,"DEW",RetTitle("DEW_DESAPT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| M->DEW_APTJOR := (cAliasQry)->DEW_APTJOR, TMSVALFIELD("M->DEW_APTJOR",.F.,"DEW_DESAPT") })
TRCell():New(aJorn,"DEW_TIPAPT"	,"DEW",RetTitle("DEW_TIPAPT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Iif(!Empty((cAliasQry)->DEW_TIPAPT),aSx3Box[VAL((cAliasQry)->DEW_TIPAPT)][3],"") })
TRCell():New(aJorn,"DEW_FILORI"	,"DEW",RetTitle("DEW_FILORI"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasQry)->DEW_FILORI })
TRCell():New(aJorn,"DEW_VIAGEM"	,"DEW",RetTitle("DEW_VIAGEM"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasQry)->DEW_VIAGEM })  
TRCell():New(aJorn,"DEW_OBSAPT"  ,"DEW",RetTitle("DEW_OBSAPT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (DEW->(DbGoTo((cAliasQry)->DEWRECNO)),DEW->DEW_OBSAPT) }) 

Return(oReport)  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSRO42³ Autor ³Guilherme R. Gaiofatto³ Data ³06/02/13     º±±
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

	SELECT DEW.DEW_FILIAL, DEW.DEW_CODMOT, DEW.DEW_FILORI, DEW.DEW_VIAGEM, DEW.DEW_APTJOR, DEW.DEW_DATAPT, DEW.DEW_HORAPT, DEW.DEW_TIPAPT, DEW.R_E_C_N_O_ DEWRECNO
	
	FROM %table:DEW% DEW
	
	WHERE DEW.DEW_FILIAL = %xFilial:DEW%
			AND DEW_CODMOT 	BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
			AND DEW_FILORI    BETWEEN %Exp:mv_par03% AND %Exp:mv_par05%
			AND DEW_VIAGEM    BETWEEN %Exp:mv_par04% AND %Exp:mv_par06%
			AND DEW_DATAPT    BETWEEN %Exp:mv_par07% AND %Exp:mv_par08%  
			
			AND DEW.%NotDel%
	
	ORDER BY DEW.DEW_FILIAL, DEW.DEW_CODMOT, DEW.DEW_DATAPT, DEW.DEW_HORAPT, DEW.DEW_APTJOR, DEW.DEW_TIPAPT,DEW.DEW_FILORI, DEW.DEW_VIAGEM, DEWRECNO

EndSQL   

oReport:Section(1):EndQuery()     
oReport:Section(1):Section(1):SetParentQuery()  
oReport:Section(1):Section(1):SetParentFilter({ |cParam| (cAliasQry)->DEW_CODMOT == cParam },{ || (cAliasQry)->DEW_CODMOT})

oReport:Section(1):Print()
oReport:SetMeter(DEW->(LastRec()))

Return