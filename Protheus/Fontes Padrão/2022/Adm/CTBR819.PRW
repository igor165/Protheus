#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "CTBR819.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBR819
Relatório para realização da conciliação contábil.
Relacionando faturamento + financeiro + contábil + suprimentos

@author TOTVS
@since 25/05/2019
@version P12.1.25
/*/
//-------------------------------------------------------------------

Function CTBR819()

Aviso(STR0098,STR0099,{STR0100})

/*
Local cQry := ""
Local aRelato :={}     
Local oExcel := FWMSEXCEL():New()  
Local nX

If ( GetRPORelease() == "12.1.030" )

	If Pergunte("CTBR819",.T.) //"CTBR819"
	 
		If Select("TMSC") > 0
			TMSC->(DBCLOSEAREA())
		EndIf
		
		cQry := " SELECT FT_FILIAL,FT_EMISSAO,FT_NFISCAL,FT_NFORI,FT_SERIE,FT_CLIEFOR,FT_LOJA,FT_CLIENT,FT_LOJENT,FT_CFOP,FT_TES,FT_QUANT,FT_PRCUNIT,FT_DESCONT,FT_TOTAL,FT_VALCONT,FT_DTCANC,FT_PRODUTO," 
		//ISS
		cQry += " FT_CODISS, "
		//ICMS
		cQry += " FT_BASEICM,FT_ALIQICM,FT_VALICM,FT_ISENICM,FT_OUTRICM,FT_OBSERV,"
		//ICMS ST
		cQry += " SUM(FT_BASERET) AS FT_BASERET,SUM(FT_ICMSRET) AS FT_ICMSRET,SUM(FT_SOLTRIB) AS FT_SOLTRIB,SUM(FT_ICMAUTO) AS FT_ICMAUTO, "
		//IPI
		cQry += " SUM(FT_VALIPI) AS FT_VALIPI,SUM(FT_OUTRIPI) AS FT_OUTRIPI, "
		//Impostos livres para utilização do usuário
		cQry += " SUM(FT_BASIMP1) AS FT_BASIMP1,FT_ALQIMP1,SUM(FT_VALIMP1) AS FT_VALIMP1,SUM(FT_RETIMP1) AS FT_RETIMP1, "
		cQry += " SUM(FT_BASIMP2) AS FT_BASIMP2,FT_ALQIMP2,SUM(FT_VALIMP2) AS FT_VALIMP2,SUM(FT_RETIMP2) AS FT_RETIMP2, "
		cQry += " SUM(FT_BASIMP3) AS FT_BASIMP3,FT_ALQIMP3,SUM(FT_VALIMP3) AS FT_VALIMP3,SUM(FT_RETIMP3) AS FT_RETIMP3, "
		cQry += " SUM(FT_BASIMP4) AS FT_BASIMP4,FT_ALQIMP4,SUM(FT_VALIMP4) AS FT_VALIMP4,SUM(FT_RETIMP4) AS FT_RETIMP4, "
		//COFINS Apuração
		cQry += " SUM(FT_BASIMP5) AS FT_BASIMP5,FT_ALQIMP5,SUM(FT_VALIMP5) AS FT_VALIMP5,SUM(FT_RETIMP5) AS FT_RETIMP5, "
		//PIS Apuração
		cQry += " SUM(FT_BASIMP6) AS FT_BASIMP6,FT_ALQIMP6,SUM(FT_VALIMP6) AS FT_VALIMP6,SUM(FT_RETIMP6) AS FT_RETIMP6, "
		//IRRF
		cQry += " SUM(FT_BASEIRR) AS FT_BASEIRR,FT_ALIQIRR,SUM(FT_VALIRR) AS FT_VALIRR, "
		//INSS
		cQry += " SUM(FT_BASEINS) AS FT_BASEINS,FT_ALIQINS,SUM(FT_VALINS) AS FT_VALINS, "
		//PIS Retenção
		cQry += " SUM(FT_BASEPIS) AS FT_BASEPIS,FT_ALIQPIS,SUM(FT_VALPIS) AS FT_VALPIS,SUM(FT_VRETPIS) AS FT_VRETPIS,SUM(FT_ARETPIS) AS FT_ARETPIS, "
		//Cofins Retenção
		cQry += " SUM(FT_BASECOF) AS FT_BASECOF,FT_ALIQCOF,SUM(FT_VALCOF) AS FT_VALCOF,SUM(FT_VRETCOF) AS FT_VRETCOF,SUM(FT_ARETCOF) AS FT_ARETCOF, "
		//CSLL Retenção
		cQry += " SUM(FT_BASECSL) AS FT_BASECSL,FT_ALIQCSL,SUM(FT_VALCSL) AS FT_VALCSL,SUM(FT_VRETCSL) AS FT_VRETCSL,SUM(FT_ARETCSL) AS FT_ARETCSL,  "
		//FISCAL
		cQry += " FT_MARGEM,   "
		//Financeiro
		cQry += " E1_BAIXA,E1_CLIENTE,E1_NATUREZ,SUM(E1_VALOR) AS VALOR,SUM(E1_SALDO) AS SALDO,SUM(E1_DESCFIN) AS DESC_FIN,SUM(E1_ACRESC) AS ACRESCIMO,SUM(E1_DECRESC) AS DECRESCIMO,SUM(E1_MULTA) AS MULTA,SUM(E1_JUROS) AS JUROS,SUM(E1_VALLIQ) AS VAL_LIQ, "
		//IRRF Financeiro
		cQry += " SUM(E1_IRRF) AS IRRF,SUM(E1_VRETIRF) AS VRETIRF, "
		//ISS Financeiro
		cQry += " SUM(E1_ISS) AS ISS,SUM(E1_VRETISS) AS VRETISS, "
		//INSS Financeiro
		cQry += " SUM(E1_INSS) AS INSS, "
		//PCC
		cQry += " SUM(E1_CSLL) AS CSLL,SUM(E1_COFINS) AS COFINS,SUM(E1_PIS) AS PIS"
		
		cQry += " FROM " + RetSqlName("SFT") + " SFT "
		
		//Financeiro
		cQry += " LEFT JOIN "  + RetSqlName("SE1") + " SE1 "
		cQry += " ON SE1.E1_FILIAL = SFT.FT_FILIAL "
		cQry += " AND SE1.E1_NUM = SFT.FT_NFISCAL "
		cQry += " AND SE1.E1_CLIENTE = SFT. FT_CLIEFOR "
		cQry += " AND SE1.E1_EMISSAO = SFT.FT_EMISSAO "
		cQry += " AND SE1.E1_NATUREZ NOT IN ('COFINS', 'CSLL', 'IRF', 'PIS') "
		cQry += " AND SE1.D_E_L_E_T_ = ' ' "
		
		cQry += " LEFT JOIN "  + RetSqlName("SE5") + " SE5 "
		cQry += " ON  SE5.E5_FILIAL = SFT.FT_FILIAL "
		cQry += " AND SE5.E5_NUMERO = SFT.FT_NFISCAL "
		cQry += " AND SE5.E5_CLIENTE = SFT.FT_CLIEFOR "
		cQry += " AND SE5.E5_DATA = SE1.E1_BAIXA "
		cQry += " AND SE5.D_E_L_E_T_ = ' ' "
		
		cQry += " WHERE FT_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) +"' "
		cQry += " AND SFT.D_E_L_E_T_ = ' ' "
		cQry += " AND SFT.FT_TIPOMOV = 'S' "
		
		cQry += " GROUP BY FT_FILIAL,FT_EMISSAO,FT_NFISCAL,FT_NFORI,FT_SERIE,FT_CLIEFOR,FT_LOJA,FT_CLIENT,FT_LOJENT,FT_CFOP,FT_TES,FT_QUANT,FT_PRCUNIT,FT_DESCONT,FT_TOTAL,FT_VALCONT,FT_DTCANC,FT_PRODUTO,FT_CODISS,FT_BASEICM,FT_ALIQICM,FT_VALICM,FT_ISENICM,FT_OUTRICM,FT_OBSERV, FT_ALQIMP1,FT_ALQIMP2,FT_ALQIMP3,FT_ALQIMP4,FT_ALQIMP5,FT_ALQIMP6,FT_ALIQIRR,FT_ALIQINS,FT_ALIQPIS,FT_ALIQCOF,FT_ALIQCSL,FT_MARGEM,E1_NATUREZ,E1_BAIXA,E1_CLIENTE  "
		
		cQry += " ORDER BY  FT_FILIAL, FT_EMISSAO, FT_NFISCAL, FT_PRCUNIT "
		   
		cQry := changeQuery(cQry)
		TcQuery cQry New Alias "TMSC" 
		
		While !TMSC->(EOF()) 
			nValPCC	:= (TMSC->FT_VALPIS + TMSC->FT_VALCOF + TMSC->FT_VALCSL)
			
			aAdd(aRelato ,{ TMSC->FT_FILIAL, TMSC->FT_EMISSAO, TMSC->FT_NFISCAL, TMSC->FT_NFORI, TMSC->FT_SERIE, TMSC->FT_CLIEFOR, ;	
				POsicione("SA1",1,xFilial("SA1")+TMSC->FT_CLIEFOR ,"A1_NREDUZ" ), TMSC->FT_LOJA, TMSC->FT_CLIENT, TMSC->FT_LOJENT,; 
				TMSC->FT_PRODUTO, TMSC->FT_CFOP, TMSC->FT_TES, TMSC->FT_QUANT, TMSC->FT_PRCUNIT, TMSC->FT_DESCONT, TMSC->FT_TOTAL, TMSC->FT_VALCONT,;
				TMSC->FT_DTCANC, ;			
				TMSC->FT_CODISS,;						
				TMSC->FT_BASEICM, TMSC->FT_ALIQICM, TMSC->FT_VALICM, TMSC->FT_ISENICM, TMSC->FT_OUTRICM, TMSC->FT_BASERET, TMSC->FT_ICMSRET, TMSC->FT_SOLTRIB,; 
				TMSC->FT_ICMAUTO, TMSC->FT_OBSERV,;
				TMSC->FT_VALIPI,TMSC->FT_OUTRIPI, ;
				TMSC->FT_BASEIRR, TMSC->FT_ALIQIRR, TMSC->FT_VALIRR, ;
				TMSC->FT_BASEINS, TMSC->FT_ALIQINS, TMSC->FT_VALINS,;
				TMSC->FT_BASEPIS, TMSC->FT_ALIQPIS, TMSC->FT_VALPIS, TMSC->FT_VRETPIS, TMSC->FT_ARETPIS,;
				TMSC->FT_BASECOF, TMSC->FT_ALIQCOF, TMSC->FT_VALCOF, TMSC->FT_VRETCOF, TMSC->FT_ARETCOF,;
				TMSC->FT_BASECSL, TMSC->FT_ALIQCSL, TMSC->FT_VALCSL, TMSC->FT_VRETCSL, TMSC->FT_ARETCSL,; 			
				TMSC->FT_BASIMP1, TMSC->FT_ALQIMP1, TMSC->FT_VALIMP1, TMSC->FT_RETIMP1,;
				TMSC->FT_BASIMP2, TMSC->FT_ALQIMP2, TMSC->FT_VALIMP2, TMSC->FT_RETIMP2,;   
				TMSC->FT_BASIMP3, TMSC->FT_ALQIMP3, TMSC->FT_VALIMP3, TMSC->FT_RETIMP3,;
				TMSC->FT_BASIMP4, TMSC->FT_ALQIMP4, TMSC->FT_VALIMP4, TMSC->FT_RETIMP4,; 
				TMSC->FT_BASIMP5, TMSC->FT_ALQIMP5, TMSC->FT_VALIMP5, TMSC->FT_RETIMP5,;
				TMSC->FT_BASIMP6, TMSC->FT_ALQIMP6, TMSC->FT_VALIMP6, TMSC->FT_RETIMP6,; 
				TMSC->FT_MARGEM,;
				TMSC->E1_NATUREZ, TMSC->VALOR, TMSC->SALDO, TMSC->DESC_FIN, TMSC->ACRESCIMO, TMSC->DECRESCIMO, TMSC->MULTA, TMSC->JUROS,;
				TMSC->VAL_LIQ,; 
				TMSC->IRRF, TMSC->VRETIRF,;
				TMSC->ISS, TMSC->VRETISS,;
				TMSC->INSS,;
				TMSC->CSLL,;
				TMSC->COFINS,; 
				TMSC->PIS,;
				TMSC->E1_BAIXA,;
				nValPCC, } )    
		
			TMSC->(DbSkip())
		
		EndDo
		
		oExcel:AddworkSheet(STR0002) //"Conciliação Contábil"
		oExcel:AddTable (STR0002,STR0002 )   //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0003,1,1) //"Filial" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0004,1,4) //"Emissão" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0005,1,1) //"NF" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002 ,STR0006,1,1) //"NF Origem" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0007,1,1) //"Série" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0008,1,1) //"Cliente/Fornecedor" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0008,1,1) //"Cliente/Fornecedor" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0009,1,2,.T.) //"Loja" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0010,1,2,.T.)  //"Cliente ent" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0011,1,4) //"Loja Ent" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0012,1,1)	 //"Produto" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002 ,STR0013,1,4) //"CFOP" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0014,1,2) //"TES" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002 ,STR0015,1,1) //"Quantidade" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0016,1,2) //"Preço Unitário" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0017,1,2) //"Desconto" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0018,1,2) //"Total" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0019,1,2) //"ValCont" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0020,1,4) //"DT Canc" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0021,1,1)   //"Cod ISS" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0022,1,2) //"BC ICMS" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0023,1,1) //"Aliq ICMS" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0024,1,2) //"Val ICMS" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0025,1,2) //"ICMS Isento" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0026,1,2) //"ICMS Outros" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0027,1,2) //"BC ICMS Ret" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0028,1,2) //"ICMS Retido" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0029,1,2) //"ICMS ST" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0030,1,2) //"ICMS Auto" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0031,1,2) //"ICMS Obs" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0032,1,2) //"Val IPI" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0033,1,2)	 //"IPI Outros" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0034,1,2) //"BC IRRF" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0035,1,1) //"Aliq IR" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0036,1,2) //"Val IRRF" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0037,1,2) //"BC INSS" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0038,1,1) //"Aliq INSS" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0039,1,2) //"Val INSS" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0040,1,2) //"BC PIS" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0041,1,1) //"Aliq PIS" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0042,1,2) //"Val PIS" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0043,1,2) //"Val Ret PIS" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0044,1,2) //"Val ARetPIS" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0045,1,2) //"BC COFINS" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0046,1,1) //"Aliq COFINS" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0047,1,2) //"Val COFINS" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0048,1,2) //"Val Ret COFINS" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0049,1,2) //"Val ARetCOFINS" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0050,1,2) //"BC CSLL" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0051,1,1) //"Aliq CSLL" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0052,1,2) //"Val CSLL" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0053,1,2) //"Val Ret CSLL" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0054,1,2)	 //"Val ARetCSLL" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0055,1,2) //"BC IMP1" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0056,1,2) //"Aliq IMP1" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0057,1,2) //"Val IMP1" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0058,1,2) //"Val Ret IMP1" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0059,1,2) //"BC IMP2" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0060,1,2) //"Aliq IMP2" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0061,1,2) //"Val IMP2" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0062,1,2) //"Val Ret IMP2" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0063,1,2) //"BC IMP3" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0064,1,2) //"Aliq IMP3" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0065,1,2) //"Val IMP3" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0066,1,2) //"Val Ret IMP3" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0067,1,2) //"BC IMP4" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0068,1,2) //"Aliq IMP4" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0069,1,2) //"Val IMP4" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0070,1,2) //"Val Ret IMP4" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0071,1,2) //"BC IMP5" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0072,1,2) //"Aliq IMP5" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0073,1,2) //"Val IMP5" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0074,1,2) //"Val Ret IMP5" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0075,1,2) //"BC IMP6" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0076,1,2) //"Aliq IMP6" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0077,1,2) //"Val IMP6" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0078,1,2)	 //"Val Ret IMP6" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0079,1,2) //"Margem" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0080,1,2) //"Natureza" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0081,1,2) //"Valor SE1" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0082,1,2) //"Saldo Financeiro" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0017,1,2) //"Desconto" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0083,1,2) //"Acréscrimo" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0084,1,2) //"Decréscimo" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0085,1,2) //"Multa" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0086,1,2) //"Juros" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0087,1,2) //"Valor Liquido Recebido" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0088,1,2) //"IRRF Financeiro" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0089,1,2) //"IR Ret Finan" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0090,1,2) //"ISS Finan" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0091,1,2) //"ISS Ret Finan" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0092,1,2) //"INSS Financeiro" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0093,1,2) //"CSLL Financeiro" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0094,1,2) //"COFINS Financeiro" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0095,1,2) //"PIS Financeiro" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0096,1,4) //"DT Baixa" //"Conciliação Contábil"
		oExcel:AddColumn(STR0002,STR0002,STR0097,1,2) //"PCC" //"Conciliação Contábil"
		
		For nX := 1 to Len(aRelato) 
			oExcel:AddRow(STR0002,STR0002,; //"Conciliação Contábil"
					{ 	aRelato[nx][1]	,	aRelato[nx][2]	,	aRelato[nx][3]	,	aRelato[nx][4]	,	aRelato[nx][5]	,;
						aRelato[nx][6]	,	aRelato[nx][7]	,	aRelato[nx][8]	,	aRelato[nx][9]	,	aRelato[nx][10]	,;
						aRelato[nx][11]	,	aRelato[nx][12]	,	aRelato[nx][13]	,	aRelato[nx][14]	,	aRelato[nx][15]	,;
						aRelato[nx][16]	,	aRelato[nx][17],	aRelato[nx][18]	, 	aRelato[nx][19]	,	aRelato[nx][20]	,;
						aRelato[nx][21]	,	aRelato[nx][22]	,	aRelato[nx][23]	,	aRelato[nx][24]	,	aRelato[nx][25]	,;
						aRelato[nx][26]	,	aRelato[nx][27]	,	aRelato[nx][28] ,	aRelato[nx][29]	,	aRelato[nx][30]	,;
						aRelato[nx][31]	,	aRelato[nx][32]	,	aRelato[nx][33] ,	aRelato[nx][34]	,	aRelato[nx][35]	,;
						aRelato[nx][36]	,	aRelato[nx][37]	,	aRelato[nx][38] ,	aRelato[nx][39]	,	aRelato[nx][40]	,;
						aRelato[nx][41]	,	aRelato[nx][42]	,	aRelato[nx][43] ,	aRelato[nx][44]	,	aRelato[nx][45]	,;
						aRelato[nx][46]	,	aRelato[nx][47]	,	aRelato[nx][48] ,	aRelato[nx][49]	,	aRelato[nx][50]	,;
						aRelato[nx][51]	,	aRelato[nx][52]	,	aRelato[nx][53] ,	aRelato[nx][54]	,	aRelato[nx][55]	,;
						aRelato[nx][56]	,	aRelato[nx][57]	,	aRelato[nx][58] ,	aRelato[nx][59]	,	aRelato[nx][60]	,;
						aRelato[nx][61]	,	aRelato[nx][62]	,	aRelato[nx][63] ,	aRelato[nx][64]	,	aRelato[nx][65]	,;
						aRelato[nx][66]	,	aRelato[nx][67]	,	aRelato[nx][68] ,	aRelato[nx][69]	,	aRelato[nx][70]	,;
						aRelato[nx][71]	,	aRelato[nx][72]	,	aRelato[nx][73] ,	aRelato[nx][74]	,	aRelato[nx][75]	,;
						aRelato[nx][76]	,	aRelato[nx][77]	,	aRelato[nx][78] ,	aRelato[nx][79]	,	aRelato[nx][80]	,;
						aRelato[nx][81]	,	aRelato[nx][82]	,	aRelato[nx][83] ,	aRelato[nx][84]	,	aRelato[nx][85]	,;
						aRelato[nx][86]	,	aRelato[nx][87]	,	aRelato[nx][88] ,	aRelato[nx][89]	,	aRelato[nx][90]	,;
						aRelato[nx][91]	, 	aRelato[nx][92]	, 	aRelato[nx][93]	,	aRelato[nx][94]	,	aRelato[nx][95]	,;
						aRelato[nx][96]	,	aRelato[nx][97] } )
		Next
		
		oExcel:Activate()
		oExcel:GetXMLFile("CTBR819.xml")
	
	EndIf

	cfile := GetTempPath()+ "CTBR819.xml"    
	__CopyFile( "CTBR819.xml" , cFile   )
	oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open( cFile )
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy() 

Endif
 */ 
Return 