#INCLUDE "FISR050.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "REPORT.CH"

#DEFINE ENTER CHR(13)+CHR(10)
 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISR050()

FUNCAO PARA CRIACAO DE RELATORIO DE APURACAO DE IMPOSTOS RETIDOS  POR NATUREZA
  
@author    Robson de Souza Moura
@version   12.1.3
@since     01/04/2015

/*/
//------------------------------------------------------------------------------------------
Function FISR050()        

Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

Private oReport := Nil
Private nAliqIns := 0
 

If lVerpesssen
	ReportDef()
	oReport:PrintDialog()
EndIf
        
Return Nil   

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISR050()

REPORTDEF() - Definições do Relatório  

@author    Robson de Souza Moura
@version   12.1.3
@since     01/04/2015

/*/
//------------------------------------------------------------------------------------------
Static Function ReportDef()

Private oSecCab := Nil

Pergunte( "FISR050" , .F. ) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // Natureza Inicial                             ³
//³ mv_par02     // Natureza Final                               ³
//³ mv_par03     // Data Vencimento Inicial                      ³
//³ mv_par04     // Data Vencimento Final                        ³
//³ mv_par05     // Imprime Abertos/Baixados/Ambos               ³
//³ mv_par06     // Ordem de Impressao Por Titulo / Data Emissao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SE2") 

oReport := TReport():New("FISR050",STR0001,"FISR050",{|oReport| PrintReport(oReport)},STR0002)

oReport:SetUseGC(.T.) 

oSection1 := TRSection():New(oReport,STR0001,{"TMP","SE2","SM0","SA2","SF1"}) 

oReport:SetLandscape() 

TRCell():New(oSection1,"E2_NUM"      ,"TMP",STR0003)//PREFIXO DO TÍTULO
TRCell():New(oSection1,"E2_PREFIXO"  ,"TMP",STR0004)//PREFIXO DO TÍTULO
TRCell():New(oSection1,"E2_TIPO"     ,"TMP",STR0005)//TIPO
TRCell():New(oSection1,"A2_COD"      ,"TMP",STR0006)//CODIGO DO FORNECEDOR
TRCell():New(oSection1,"TMP_NOME"    ,"TMP",STR0007,,TamSx3("A2_NOME")[1])//RAZÃO SOCIAL
TRCell():New(oSection1,"TMP_CGC"     ,"TMP",STR0008,,TamSx3("A2_CGC")[1])//CNPJ
TRCell():New(oSection1,"E2_EMISSAO"  ,"TMP",STR0009)//EMISSAO
TRCell():New(oSection1,"E2_VENCTO"   ,"TMP",STR0010)//VENCIMENTO
TRCell():New(oSection1,"E2_VENCREA"  ,"TMP",STR0011)//VENCIMENTO REAL
TRCell():New(oSection1,"TMP_BRUTO"   ,"TMP",STR0012, X3PIcture("E2_VALOR"),TamSx3("E2_VALOR")[1],,,"CENTER",,"CENTER")//VALOR BRUTO
TRCell():New(oSection1,"TMP_BASE"	 ,"TMP",STR0013, X3PIcture("E2_VALOR"),TamSx3("E2_VALOR")[1],,,"CENTER",,"CENTER")//BASE 
TRCell():New(oSection1,"TMP_ALIQ"    ,"TMP",STR0014)//ALIQUOTA
TRCell():New(oSection1,"E2_VALOR"    ,"TMP",STR0015)//IMPOSTO
TRCell():New(oSection1,"E2_NATUREZ"  ,"TMP",STR0016,,TamSx3("E2_NATUREZ")[1])//NATUREZA

TRFunction():New(oSection1:Cell("E2_VALOR"),/*cId*/,"SUM"     ,,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.           ,.T.           ,.F.        ,oSecCab)  

Return oReport 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISR050()
IMPRESSÃO  
@author    Robson de Souza Moura
@version   12.1.33
@since     01/04/2015
/*/
//------------------------------------------------------------------------------------------
Static Function PrintReport(oReport)

Local oSection1  := oReport:Section(1)
Local cQuery    := ""
Local nPrefixo  := TamSx3("E2_PREFIXO")[1]
Local nNumTit   := TamSx3("E2_NUM")[1]
Local nTipo     := TamSx3("E2_TIPO")[1]
Local nParcela  := TamSx3("E2_PARCELA")[1]
Local nFornece  := TamSx3("E2_FORNECE")[1]
Local nLoja     := TamSx3("E2_LOJA")[1]
Local nCliente  := TamSx3("E1_CLIENTE")[1]
Local aStruSE2  := SE2->(dbStruct()) 
Local nX        := 0
Local cFiltro   :=  oSection1:GetSqlExp()
Local cNatPis   := SuperGetMV("MV_PISNAT",,"PIS")
Local cNatCof   := SuperGetMV("MV_COFINS",,"COFINS")
Local cNatCsl   := SuperGetMV("MV_CSLL",,"CSLL") 
Local cNatIrf   := SuperGetMV("MV_IRF",,"IRF")
Local cNatISS   := SuperGetMV("MV_ISS",,"ISS")
Local cTipoDB   := AllTrim(Upper(TcGetDb()))
Local cGrpQuery := ""


dbSelectArea("SE2") 

//³ Quebra de secoes e totalizadores do Relatorio ³

oBreak01 := TRBreak():New(oSection1,oSection1:Cell("E2_NATUREZ"),STR0017,.F.)

TRFunction():New(oSection1:Cell("E2_VALOR"),"TOTNAT","SUM",oBreak01,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)

TRPosition():New(oSection1,"SA2",1,{|| xFilial("SA1") + TMP->A2_COD + TMP->A2_LOJA})
TRPosition():New(oSection1,"SF1",1,{|| xFilial("SF1") + TMP->F1_DOC + TMP->F1_SERIE + TMP->F1_FORNECE + TMP->F1_LOJA })

	
cQuery := " SELECT				" + ENTER
cQuery += " 	SE2.E2_PARCELA,	" + ENTER
cQuery += " 	SE2.E2_NUM,		" + ENTER
cQuery += " 	SE2.E2_PREFIXO,	" + ENTER
cQuery += " 	SE2.E2_TIPO,	" + ENTER
cQuery += " 	SA2.A2_COD,	    " + ENTER
cQuery += " 	SA2.A2_LOJA,    " + ENTER
cQuery += " 	SA2.A2_TIPO,    " + ENTER
cQuery += " 	F1_DOC,   		" + ENTER
cQuery += " 	F1_SERIE,   	" + ENTER
cQuery += " 	F1_FORNECE,   	" + ENTER
cQuery += " 	F1_LOJA,    	" + ENTER
cQuery += " 	CASE	
cQuery += " 		WHEN F2_VALBRUT IS NOT NULL THEN F2_BASEISS  												" + ENTER
cQuery += " 		WHEN F2_VALBRUT IS NOT NULL AND SE2.E2_NATUREZ = '" + &(cNatISS) + "' THEN SE1B.E1_VALOR	" + ENTER
cQuery += " 		WHEN F1_VALBRUT IS NULL THEN TITPAI.E2_VALOR 												" + ENTER
cQuery += " 	ELSE F1_VALBRUT 																				" + ENTER
cQuery += " 	END AS TMP_BRUTO, 									" + ENTER
cQuery += " 	CASE 												" + ENTER
cQuery += " 		WHEN (TITPAI.E2_NUM IS NULL) THEN SA1.A1_NOME	" + ENTER
cQuery += " 		ELSE SA2.A2_NOME								" + ENTER
cQuery += " 	END AS TMP_NOME,									" + ENTER
cQuery += " 	CASE 												" + ENTER
cQuery += " 		WHEN (TITPAI.E2_NUM IS NULL) THEN SA1.A1_CGC	" + ENTER
cQuery += " 		ELSE SA2.A2_CGC 								" + ENTER
cQuery += " 	END AS TMP_CGC,										" + ENTER
cQuery += "   SE2.E2_EMISSAO,										" + ENTER
cQuery += "   SE2.E2_VENCTO,										" + ENTER
cQuery += "   SE2.E2_VENCREA,										" + ENTER
cPartQuery := " FROM "+RetSqlName("SFT")+" SFT WHERE SFT.FT_FILIAL = '"+xFilial("SFT")+"'			                                                                             		"	+ ENTER	
cPartQuery += "																AND SFT.FT_NFISCAL	= SF1.F1_DOC	                                                                 		"	+ ENTER
cPartQuery += "																AND	SFT.FT_SERIE	= SF1.F1_SERIE	                                                                 		"	+ ENTER
cPartQuery += "																AND SFT.FT_CLIEFOR	= SF1.F1_FORNECE                                                                 		"	+ ENTER
cPartQuery += "																AND SFT.FT_LOJA		= SF1.F1_LOJA	                                                                 		"	+ ENTER
cPartQuery += "																AND SFT.FT_TIPOMOV  = 'E'			                                                                 		"	+ ENTER
cPartQuery += "																AND SFT.D_E_L_E_T_  = ''			                                                                 		"	+ ENTER
cGrpQuery  := "																GROUP BY FT_ALIQINS					                                                                 		"	+ ENTER
cQuery += " 	CASE  WHEN SE2.E2_TIPO = 'INS' AND (" + TopSele("FT_ALIQINS",cPartQuery,1,cTipoDB,cGrpQuery) + " ) IS NULL                                              		 		"   + ENTER
cQuery += "																						THEN ROUND((SE2.E2_VALOR/TITPAI.E2_BASEINS)*100,2)								 		"	+ ENTER
cQuery += " 	    WHEN SE2.E2_TIPO = 'INS' THEN ("+ TopSele("FT_ALIQINS",cPartQuery,1,cTipoDB,cGrpQuery) + " )										                 		 		"   + ENTER
cQuery += " 		WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + cNatPis + "' THEN ROUND((SE2.E2_VALOR/TITPAI.E2_BASEPIS)*100,2)											 		"	+ ENTER	
cQuery += " 		WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + cNatCof + "' AND SF1.F1_BASCOFI IS NOT NULL THEN ROUND((SUM(F1_VALCOFI) * 100) / SUM(F1_BASCOFI),2)		 		"	+ ENTER
cQuery += " 		WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + cNatCof + "' THEN ROUND((SE2.E2_VALOR/TITPAI.E2_BASECOF)*100,2)											 		"	+ ENTER
cQuery += " 		WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + cNatCsl + "' AND SF1.F1_BASCSLL IS NOT NULL THEN ROUND((SUM(F1_VALCSLL) * 100) / SUM(F1_BASCSLL),2)		 		"	+ ENTER
cQuery += " 		WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + cNatCsl + "' THEN ROUND((SE2.E2_VALOR/TITPAI.E2_BASECOF)*100,2)											 		"	+ ENTER
cPartQuery := " FROM "+RetSqlName("SFT")+" SFT WHERE SFT.FT_FILIAL = '"+xFilial("SFT")+"'			                                                                             		"	+ ENTER	
cPartQuery += "																AND SFT.FT_NFISCAL	= SF1.F1_DOC	                                                                 		"	+ ENTER
cPartQuery += "																AND	SFT.FT_SERIE	= SF1.F1_SERIE	                                                                 		"	+ ENTER
cPartQuery += "																AND SFT.FT_CLIEFOR	= SF1.F1_FORNECE                                                                 		"	+ ENTER
cPartQuery += "																AND SFT.FT_LOJA		= SF1.F1_LOJA	                                                                 		"	+ ENTER
cPartQuery += "																AND SFT.FT_TIPOMOV  = 'E'			                                                                 		"	+ ENTER
cPartQuery += "																AND SFT.FT_ALIQIRR  > 0				                                                                 		"	+ ENTER
cPartQuery += "																AND SFT.D_E_L_E_T_  = ''			                                                                 		"	+ ENTER
cGrpQuery  := "																GROUP BY FT_ALIQIRR					                                                                 		"	+ ENTER
cQuery += " 		WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + &(cNatIrf) +  "' AND ("+ TopSele("FT_ALIQIRR",cPartQuery,1,cTipoDB,cGrpQuery) + " ) IS NULL				 		"	+ ENTER
cQuery += "																				THEN ROUND((SE2.E2_VALOR/TITPAI.E2_BASEIRF)*100,2)										 		"	+ ENTER
cQuery += " 		WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + &(cNatIrf) +  "' AND SE2.E2_ORIGEM = 'MATA460' THEN ROUND((SF2.F2_VALIRRF/SF2.F2_BASEIRR)*100,2)			 		"	+ ENTER
cQuery += " 		WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + &(cNatIrf) +  "' AND SF1.F1_VALIRF IS NOT NULL 																	"	+ ENTER
cQuery += "																			   AND ("+ TopSele("FT_ALIQIRR",cPartQuery,1,cTipoDB,cGrpQuery) + " ) IS NOT NULL				    "	+ ENTER
cQuery += " 																		   THEN ("+ TopSele("FT_ALIQIRR",cPartQuery,1,cTipoDB,cGrpQuery) + " )								"	+ ENTER
cQuery += " 		WHEN SE2.E2_TIPO = 'ISS' AND SE2.E2_NATUREZ = '" + &(cNatISS) + "' AND TITPAI.E2_BASEISS > 0 THEN ROUND((SE2.E2_VALOR/TITPAI.E2_BASEISS)*100,2)				 		"	+ ENTER
cQuery += " 		WHEN SE2.E2_TIPO = 'TX'  AND SE2.E2_NATUREZ = '" + &(cNatISS) + "' THEN ROUND((SE2.E2_VALOR/SF2.F2_BASEISS)*100,2)		 									 		"	+ ENTER
cQuery += " 		WHEN (SE2.E2_VALOR >= F1_VALBRUT) THEN  0 ELSE  ((SE2.E2_VALOR * 100)/F1_VALBRUT) END AS TMP_ALIQ, 															 		"	+ ENTER
cQuery += " 	CASE  WHEN SE2.E2_TIPO = 'INS' THEN SUM(TITPAI.E2_BASEINS)																			"	+ ENTER
cQuery += "			WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + cNatPis + "' THEN SUM(TITPAI.E2_BASEPIS) 										"	+ ENTER
cQuery += " 		WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + cNatCof + "' THEN SUM(TITPAI.E2_BASECOF) 										"	+ ENTER
cQuery += " 		WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + cNatCsl + "' THEN SUM(TITPAI.E2_BASECSL)  									"	+ ENTER
cQuery += " 		WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + &(cNatIrf) +"' AND SE2.E2_ORIGEM = 'MATA460' THEN SUM(SF2.F2_BASEIRR)			"	+ ENTER
cQuery += " 		WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + &(cNatIrf) +"' THEN SUM(TITPAI.E2_BASEIRF)									"	+ ENTER
cQuery += " 		WHEN SE2.E2_TIPO = 'ISS' AND SE2.E2_NATUREZ = '" + &(cNatISS) + "' THEN SUM(TITPAI.E2_BASEISS)									"	+ ENTER
cQuery += " 		WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + &(cNatISS) + "' THEN SUM(SF2.F2_BASEISS)		 								"	+ ENTER
cQuery += "		ELSE SF1.F1_VALBRUT END AS TMP_BASE 	" + ENTER
cQuery += "		, SE2.E2_VALOR		 					" + ENTER
cQuery += "		, SE2.E2_NATUREZ 						" + ENTER
cQuery += "		, SF1.R_E_C_N_O_ AS RECNO				" + ENTER
cQuery += " FROM										" + ENTER
cQuery += " "+ RetSqlName("SE2")+ " SE2					" + ENTER
cQuery += " LEFT JOIN									" + ENTER
cQuery += " "+RetSqlName("SE2")+" TITPAI 				" + ENTER
cQuery += " ON 											" + ENTER
cQuery += " 	TITPAI.E2_FILIAL = '"+xFilial("SE2")+"' " + ENTER					
cQuery += " 		AND TITPAI.E2_FILORIG = SE2.E2_FILORIG"																		 								+ ENTER
cQuery += " 		AND TITPAI.E2_PREFIXO	= SUBSTRING(SE2.E2_TITPAI,1,"+Alltrim(Str(nPrefixo))+") "								 							+ ENTER
cQuery += " 		AND TITPAI.E2_NUM		= SUBSTRING(SE2.E2_TITPAI,"+Alltrim(Str(nPrefixo+1))+","+Alltrim(Str(nNumTit))+") " 								+ ENTER
cQuery += " 		AND TITPAI.E2_PARCELA	= SUBSTRING(SE2.E2_TITPAI,"+Alltrim(Str(nPrefixo+nNumTit+1))+","+Alltrim(Str(nParcela))+") " 						+ ENTER
cQuery += " 		AND TITPAI.E2_TIPO		= SUBSTRING(SE2.E2_TITPAI,"+Alltrim(Str(nPrefixo+nNumTit+nParcela+1))+","+Alltrim(Str(nTipo))+") " 					+ ENTER
cQuery += " 		AND TITPAI.E2_FORNECE	= SUBSTRING(SE2.E2_TITPAI,"+Alltrim(Str(nPrefixo+nNumTit+nParcela+nTipo+1))+","+Alltrim(Str(nFornece))+") " 		+ ENTER
cQuery += " 		AND TITPAI.E2_LOJA		= SUBSTRING(SE2.E2_TITPAI,"+Alltrim(Str(nPrefixo+nNumTit+nParcela+nTipo+nFornece+1))+","+Alltrim(Str(nLoja))+") " 	+ ENTER
cQuery += " 		AND TITPAI.E2_TITPAI = ' ' 			" + ENTER
cQuery += " 		AND TITPAI.D_E_L_E_T_ = ' '			" + ENTER
cQuery += " INNER JOIN									" + ENTER
cQuery += " 	"+RetSqlName("SA2")+" SA2				" + ENTER
cQuery += " ON											" + ENTER
cQuery += " 	SA2.A2_FILIAL = '"+xFilial("SA2")+"'	" + ENTER
cQuery += " 	AND SA2.A2_COD = SUBSTRING(SE2.E2_TITPAI,"+Alltrim(Str(nPrefixo+nNumTit+nTipo+nParcela+1))+","+Alltrim(Str(nFornece))+") 			" + ENTER
cQuery += " 	AND SA2.A2_LOJA = SUBSTRING(SE2.E2_TITPAI,"+Alltrim(Str(nPrefixo+nNumTit+nTipo+nParcela+nFornece+1))+", "+Alltrim(Str(nLoja))+")	" + ENTER
cQuery += " 	AND SA2.D_E_L_E_T_ = ' '				" + ENTER
cQuery += " LEFT JOIN "+RetSqlName("SE1")+" SE1B		" + ENTER
cQuery += " ON											" + ENTER
cQuery += " 	SE1B.E1_FILIAL = '"+xFilial("SE1")+  "'	" + ENTER
cQuery += " 	AND SE1B.E1_FILORIG = SE2.E2_FILORIG"																		 							+ ENTER
cQuery += " 	AND SE1B.E1_PREFIXO	= SUBSTRING(SE2.E2_TITPAI,1,"+Alltrim(Str(nPrefixo))+") "								 							+ ENTER
cQuery += " 	AND SE1B.E1_NUM		= SUBSTRING(SE2.E2_TITPAI,"+Alltrim(Str(nPrefixo+1))+","+Alltrim(Str(nNumTit))+") " 								+ ENTER
cQuery += " 	AND SE1B.E1_PARCELA	= SUBSTRING(SE2.E2_TITPAI,"+Alltrim(Str(nPrefixo+nNumTit+1))+","+Alltrim(Str(nParcela))+") " 						+ ENTER
cQuery += " 	AND SE1B.E1_TIPO	= SUBSTRING(SE2.E2_TITPAI,"+Alltrim(Str(nPrefixo+nNumTit+nParcela+1))+","+Alltrim(Str(nTipo))+") " 					+ ENTER
cQuery += " 	AND SE1B.E1_CLIENTE	= SUBSTRING(SE2.E2_TITPAI,"+Alltrim(Str(nPrefixo+nNumTit+nParcela+nTipo+1))+","+Alltrim(Str(nCliente))+") " 		+ ENTER
cQuery += " 	AND SE1B.E1_LOJA	= SUBSTRING(SE2.E2_TITPAI,"+Alltrim(Str(nPrefixo+nNumTit+nParcela+nTipo+nCliente+1))+","+Alltrim(Str(nLoja))+") " 	+ ENTER
cQuery += " 	AND SE2.E2_ORIGEM 	= 'MATA460'			" + ENTER
cQuery += " 	AND SE1B.D_E_L_E_T_ = ' '				" + ENTER
cQuery += " LEFT JOIN									" + ENTER
cQuery += " 	"+RetSqlName("SA1")+" SA1				" + ENTER
cQuery += " ON											" + ENTER
cQuery += " 	SA1.A1_FILIAL = '"+xFilial("SA1")+"'	" + ENTER
cQuery += " 	AND SA1.A1_COD = SUBSTRING(SE2.E2_TITPAI,"+Alltrim(Str(nPrefixo+nNumTit+nTipo+nParcela+1))+","+Alltrim(Str(nFornece))+") 			" + ENTER
cQuery += " 	AND SA1.A1_LOJA	= SUBSTRING(SE2.E2_TITPAI,"+Alltrim(Str(nPrefixo+nNumTit+nTipo+nParcela+nFornece+1))+", "+Alltrim(Str(nLoja))+")	" + ENTER
cQuery += " 	AND SA1.D_E_L_E_T_ = ' '				" + ENTER
cQuery += " LEFT JOIN									" + ENTER
cQuery += " 	"+RetSqlName("SF1")+" SF1 				" + ENTER
cQuery += " ON											" + ENTER
cQuery += " 	SF1.F1_FILIAL = '"+xFilial("SF1")+ "'	" + ENTER
cQuery += " 	AND SF1.F1_DOC = TITPAI.E2_NUM			" + ENTER
cQuery += " 	AND SF1.F1_FORNECE = TITPAI.E2_FORNECE	" + ENTER
cQuery += " 	AND SF1.F1_LOJA = TITPAI.E2_LOJA		" + ENTER
cQuery += " 	AND SF1.F1_EMISSAO = TITPAI.E2_EMISSAO	" + ENTER
cQuery += " 	AND SF1.D_E_L_E_T_= ' '					" + ENTER
cQuery += " 	AND SF1.F1_SERIE = TITPAI.E2_PREFIXO	" + ENTER
cQuery += " LEFT JOIN									" + ENTER
cQuery += " 	"+RetSqlName("SF2")+" SF2				" + ENTER
cQuery += " ON											" + ENTER
cQuery += " 	SF2.F2_FILIAL = '"+xFilial("SF2")+ "'	" + ENTER
cQuery += " 	AND SF2.F2_DOC = SE2.E2_NUM				" + ENTER
cQuery += " 	AND SF2.F2_SERIE = SE2.E2_PREFIXO		" + ENTER
cQuery += " 	AND SF2.F2_EMISSAO = SE2.E2_EMISSAO		" + ENTER
cQuery += " 	AND SF2.D_E_L_E_T_= ' '					" + ENTER
If MV_PAR05     == 1 
    cQuery += " WHERE SE2.E2_FILIAL='" +xFilial("SE2")+ "' AND SE2.E2_NATUREZ BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND SE2.E2_VENCTO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND SE2.E2_BAIXA=' ' AND   SE2.D_E_L_E_T_=' ' "   + ENTER
ElseIf MV_PAR05 == 2
	cQuery += " WHERE SE2.E2_FILIAL='" +xFilial("SE2")+ "' AND SE2.E2_NATUREZ BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND SE2.E2_VENCTO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND SE2.E2_BAIXA <>' ' AND SE2.D_E_L_E_T_=' ' " + ENTER
ElseIf MV_PAR05 == 3 
    cQuery += " WHERE SE2.E2_FILIAL='" +xFilial("SE2")+ "' AND SE2.E2_NATUREZ BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND SE2.E2_VENCTO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND SE2.D_E_L_E_T_=' ' "   + ENTER    
Endif
If !Empty(cFiltro)
	cFiltro := ValFilt(cFiltro)
	cQuery += "AND" + cFiltro + "" + ENTER
EndIf
cQuery += "GROUP BY				"+ ENTER
cQuery += "   SE2.E2_ORIGEM		"+ ENTER
cQuery += " , SE2.E2_PARCELA	"+ ENTER
cQuery += " , SE2.E2_FILIAL		"+ ENTER
cQuery += " , SE2.E2_NUM		"+ ENTER
cQuery += " , SE2.E2_PREFIXO	"+ ENTER
cQuery += " , SE2.E2_TIPO		"+ ENTER
cQuery += " , SE2.E2_EMISSAO	"+ ENTER
cQuery += " , SE2.E2_VENCTO		"+ ENTER
cQuery += " , SE2.E2_VENCREA	"+ ENTER
cQuery += " , SE2.E2_VALOR		"+ ENTER
cQuery += " , SE2.E2_NATUREZ	"+ ENTER
cQuery += " , TITPAI.E2_BASEPIS	"+ ENTER
cQuery += " , TITPAI.E2_BASECOF	"+ ENTER
cQuery += " , TITPAI.E2_BASEIRF	"+ ENTER
cQuery += " , TITPAI.E2_BASEISS	"+ ENTER
cQuery += " , TITPAI.E2_BASEINS	"+ ENTER
cQuery += " , TITPAI.E2_VALOR	"+ ENTER
cQuery += " , TITPAI.E2_NUM		"+ ENTER
cQuery += " , F1_VALBRUT		"+ ENTER
cQuery += " , F1_BASCOFI		"+ ENTER
cQuery += " , F1_BASCSLL		"+ ENTER
cQuery += " , F1_VALCOFI		"+ ENTER
cQuery += " , F1_BASCSLL		"+ ENTER
cQuery += " , F1_BASPIS			"+ ENTER
cQuery += " , F1_VALPIS			"+ ENTER
cQuery += " , F1_VALIRF			"+ ENTER
cQuery += " , A2_NOME			"+ ENTER
cQuery += " , A2_CGC			"+ ENTER
cQuery += " , A1_NOME			"+ ENTER
cQuery += " , A1_CGC			"+ ENTER
cQuery += " , SA2.A2_LOJA		"+ ENTER
cQuery += " , SA2.A2_COD		"+ ENTER
cQuery += " , SA2.A2_TIPO		"+ ENTER
cQuery += " , F1_DOC			"+ ENTER
cQuery += " , F1_SERIE			"+ ENTER
cQuery += " , F1_FORNECE		"+ ENTER
cQuery += " , F1_LOJA			"+ ENTER
cQuery += " , F2_VALBRUT		"+ ENTER
cQuery += " , F2_BASEISS		"+ ENTER
cQuery += " , F2_VALIRRF		"+ ENTER
cQuery += " , F2_BASEIRR		"+ ENTER
cQuery += " , E1_VALOR			"+ ENTER
cQuery += " , TITPAI.E2_PREFIXO	"+ ENTER
cQuery += " , TITPAI.E2_NUM		"+ ENTER
cQuery += " , TITPAI.E2_FORNECE	"+ ENTER
cQuery += " , TITPAI.E2_LOJA	"+ ENTER
cQuery += " , SF1.F1_ISS		"+ ENTER
cQuery += " , SF1.R_E_C_N_O_	"+ ENTER


If MV_PAR06  == 1
	cQuery += " ORDER BY SE2.E2_NATUREZ,SE2.E2_NUM ASC "
ElseIf MV_PAR06 == 2
	cQuery += " ORDER BY SE2.E2_NATUREZ,SE2.E2_EMISSAO ASC"
Endif

cQuery := ChangeQuery(cQuery) 

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"TMP",.F.,.T.) //"Seleccionado registros"

For nX := 1 To len(aStruSE2)
		If aStruSE2[nX][2] <> "C" .And. FieldPos(aStruSE2[nX][1])<>0
			TcSetField("TMP",aStruSE2[nX][1],aStruSE2[nX][2],aStruSE2[nX][3],aStruSE2[nX][4])
		EndIf
Next nX

//Desabilitando o filtro que já foi usado na Query 
//para que não seja usado novamente na composição do oSection
oReport:NoUserFilter()
//-------------------------------------------------

oSection1:Cell("TMP_BASE"):SetSize(oSection1:Cell("E2_VALOR"):getSize())

oReport:SetMeter(RecCount())

DbSelectArea("TMP")
TMP->(DbGoTop())

ProcRegua(0)

While !TMP->(Eof())

	IncProc(STR0018) //"Aguarde, Gerando Relatório...."
	
	

	If oReport:Cancel()
		Exit
	EndIf	
	 
   	oSection1:Init() 
	oSection1:PrintLine() 
	
	oSection1:Cell("E2_NUM")	    :Show()
	oSection1:Cell("E2_PREFIXO")	:Show()
	oSection1:Cell("E2_TIPO")		:Show()
	oSection1:Cell("A2_COD")     	:Show()
	oSection1:Cell("TMP_NOME")		:Show()
	oSection1:Cell("TMP_CGC") 		:Show()
	oSection1:Cell("E2_EMISSAO")	:Show()
	oSection1:Cell("E2_VENCTO") 	:Show()
	oSection1:Cell("E2_VENCREA")	:Show()
	oSection1:Cell("TMP_BRUTO")		:Show()
	oSection1:Cell("TMP_BASE")		:Show()
	oSection1:Cell("TMP_ALIQ")  	:Show()
	oSection1:Cell("E2_VALOR")		:Show()
	oSection1:Cell("E2_NATUREZ")	:Show()

	TMP->(DbSkip())
Enddo         


oSection1:Finish()
oReport:SkipLine()
oReport:IncMeter()
TMP->(dbCloseArea())

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISR050()
Valida o filtro personalizado pelo Usuário para evitar ambiguidade de campos 
@author    Yuri Gimenes da Costa
@version   12.1.33
@since     17/12/2021
/*/
//------------------------------------------------------------------------------------------

Static Function ValFilt(cFiltro)

cFiltro := STRTRAN(cFiltro,"E2_","SE2.E2_")
cFiltro := STRTRAN(cFiltro,"A2_","SA2.A2_")
cFiltro := STRTRAN(cFiltro,"F1_","SF1.F1_")

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} SPDTopSele
@description Função que permite a montagem de QUERY de retorno de TOP n registros de um determinado SELECT, com sintaxe distinta entre os 
SGBD'S: DB2|INFORMIX|ORACLE|MYSQL|POSTGRES\MSSQL - Sendo que, salvo os outros bancos mencionados, a sintaxe padrao sera a mesma do MSSQL - "SELECT TOP 1 " + cCampoFil + cQueryPart
@Parameters cCampoFil  - Campos do SELECT
			cQueryPart - FROM e WHERE da Query.
			nTop       - Quantidade maxima de registros de retorno
			cTipoDB    - Tipo do Banco de Dados
@Retorno cQuery - Query montada com a clausula de TOP referente ao banco.
@author Thiago Yoshiaki Miyabara Nascimento - Shiny
@since 28/10/2021
@version 12.1.27
/*/

STATIC Function TopSele(cCampoFil, cQueryPart, nTop, cTipoDB, cGrpBy)

Local cQuery := ""

Default cCampoFil	:=  ""
Default cQueryPart	:=  ""
Default nTop		:=  1
Default cTipoDB		:= AllTrim(Upper(TcGetDb()))// Tipo do banco de dados

If !Empty(cCampoFil+cQueryPart)
	If !(cTipoDB $ ('ORACLE|POSTGRES'))
		cQuery := "SELECT TOP " + cValToChar(nTop) + cCampoFil + cQueryPart + cGrpBy
	ElseIf cTipoDB == 'ORACLE'
		cQuery := "SELECT "+ cCampoFil + cQueryPart + " AND ROWNUM < " + cValToChar(nTop + 1) + cGrpBy
	ElseIf cTipoDB == 'POSTGRES'
		cQuery := "SELECT "+ cCampoFil + cQueryPart + cGrpBy + " LIMIT " + cValToChar(nTop)	
	EndIf
EndIf

Return(cQuery)


