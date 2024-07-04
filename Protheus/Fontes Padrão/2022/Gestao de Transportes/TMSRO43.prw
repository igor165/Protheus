#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH" 
#INCLUDE "TMSRO43.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSRO43³ Autor ³Guilherme R. Gaiofatto³ Data ³06/02/13     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSRO43()
Local oReport
Local aArea := GetArea()

oReport := ReportDef()
oReport:PrintDialog()

RestArea(aArea)
     
Return    

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSRO43³ Autor ³Guilherme R. Gaiofatto³ Data ³06/02/13     º±±
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
Local oSaldo 
Local oMot
Local cAliasQry   := GetNextAlias()  
Local aSx3Box 	  := RetSx3Box( Posicione('SX3', 2, 'DEX_TIPO', 'X3CBox()' ),,, 1 )

oReport := TReport():New("TMSRO43",STR0001,"TMSRO43", {|oReport| ReportPrint(oReport,cAliasQry)},STR0002)
oReport:SetTotalInLine(.F.)
oReport:SetLandscape()
Pergunte("TMSRO43",.F.)

oMot := TRSection():New(oReport,STR0003,{"DEX"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oMot:SetTotalInLine(.F.)  
TRCell():New(oMot,"DEX_CODMOT"	,"DEX",RetTitle("DEX_CODMOT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasQry)->DEX_CODMOT })
TRCell():New(oMot,"DEX_NOMMOT"	,"DEX",RetTitle("DEX_NOMMOT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Posicione("DA4",1,xFilial("DA4")+(cAliasQry)->DEX_CODMOT,"DA4_NOME") })
TRCell():New(oMot,"DEX_MATMOT"	,"DEX",RetTitle("DEX_MATMOT"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Posicione("DA4",1,XFILIAL("DA4")+(cAliasQry)->DEX_CODMOT,"DA4_MAT") })
  
oSaldo := TRSection():New(oMot,STR0004,{"DEX"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSaldo:SetTotalInLine(.F.)  
TRCell():New(oSaldo,"DEX_DATA"	,"DEX",RetTitle("DEX_DATA") ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasQry)->DEX_DATA })
TRCell():New(oSaldo,"DEX_TIPO"	,"DEX",RetTitle("DEX_TIPO") ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Iif(!Empty((cAliasQry)->DEX_TIPO),aSx3Box[Val((cAliasQry)->DEX_TIPO)][3],"") })
TRCell():New(oSaldo,"DEX_SALDO"	,"DEX",RetTitle("DEX_SALDO"),/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasQry)->DEX_SALDO })


Return(oReport)  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSRO43³ Autor ³Guilherme R. Gaiofatto³ Data ³06/02/13     º±±
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

	SELECT DEX.DEX_FILIAL, DEX.DEX_CODMOT, DEX.DEX_DATA, DEX.DEX_TIPO, DEX.DEX_SALDO
	
	FROM %table:DEX% DEX
	
	WHERE DEX.DEX_FILIAL = %xFilial:DEX%
			AND DEX_CODMOT 	BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
			AND DEX_DATA      BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
			AND DEX.%NotDel%
	
	ORDER BY DEX.DEX_FILIAL, DEX.DEX_CODMOT, DEX.DEX_DATA, DEX.DEX_TIPO, DEX.DEX_SALDO

EndSQL   

oReport:Section(1):EndQuery()     
oReport:Section(1):Section(1):SetParentQuery()  
oReport:Section(1):Section(1):SetParentFilter({ |cParam| (cAliasQry)->DEX_CODMOT == cParam },{ || (cAliasQry)->DEX_CODMOT})

oReport:Section(1):Print()
oReport:SetMeter(DEX->(LastRec()))

Return