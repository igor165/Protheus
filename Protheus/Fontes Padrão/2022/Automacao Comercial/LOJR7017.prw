#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJR7017.CH"

Static lGestao   := IIf( FindFunction("FWCodFil"), FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Static lACVComp  := FWModeAccess("ACV",3)== "C" 								// Verifica se ACV ้ compartilhada

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJR7017  บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio de impressao dos indicadores de Prevencao de Perdasบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Prevencao de Perdas                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LOJR7017(oExplorer,aRelatorio)
Local nI 		:= 0 			//Contador

For nI := 1 To Len(aRelatorio)
	If alltrim(aRelatorio[nI][2]) == alltrim(oExplorer:cGetTree)
		&(aRelatorio[nI][3]) //executa o relat๓rio passado como referencia 
		Exit
	Endif
Next nI

Return .T.

//-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-Prevencao de Perdas\Estoque\Produtos com maior devolu็ใo-=-=-=--=-=-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณ LJR70171 ณ Autor ณ TOTVS               ณ Data ณ 24/07/2013 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณPrevencao de Perdas\Produtos com maior devolu็ใo            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณRelatorio Personalizavel									  ณฑฑ
ฑฑศออออออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LJR70171(lCatProd,cTitulo,nOrdem,aGPFilial)
Local oReport 	:= NIL				// Objeto para geracao do relatorio
Local aArea 	:= GetArea() 		// Salva a area

Default aGPFilial := {} 			// Grupo de Filiais

Pergunte("LJ7017",.F.)//O pergunte deve estar desabilitado 

oReport := LJR70171Def(lCatProd,cTitulo,nOrdem,aGPFilial)
oReport:PrintDialog()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a areaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea( aArea )
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70171Def บAutor  ณTOTVS             บ Data ณ  24/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao das celulas que irao compor o relatorio           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR100                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR70171Def(lCatProd,cTitulo,nOrdem,aGPFilial)
Local oReport	:= NIL									// Objeto do relatorio
Local oSection1	:= NIL									// Objeto da secao 1
Local cAlias1	:= GetNextAlias()						// Pega o proximo Alias Disponivel
Local oTotaliz 	:= NIL									// Objeto totalizador
Local oBreak	:= NIL									// Objeto de Quebra

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera a tela com os dados para a confirma็ใo da geracao do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If !Empty(aGPFilial)
	oReport := TReport():New("LOJR70171",STR0001+" - "+cTitulo,"",{|oReport| LJR701710Prt(oReport, cAlias1,lCatProd)},STR0002 )//Relat๓rio Analitico##"Prevencao de Perdas"
Else
	oReport := TReport():New("LOJR70171",STR0001+" - "+cTitulo,"",{|oReport| LJR70171Prt(oReport, cAlias1,lCatProd,nOrdem )},STR0002 )//Relat๓rio Analitico##"Prevencao de Perdas"
Endif	


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine a secao1 do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1 := TRSection():New( oReport,"",{ "SD1","ACV","ACU","SBM" } )	

oSection1:SetHeaderBreak(.T.)		//Indica se cabecalho da secao sera impresso em cada quebra 
oSection1:SetHeaderPage(.T.)		//Indica que cabecalho da secao sera impresso no topo da pagina

oReport:SetLandscape(.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine as celulas que irao aparecer na secao1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOrdem <> 2
	TRCell():New(oSection1,"D1_FILIAL","SD1",STR0004, ) //"Filial"
Endif

If nOrdem <> 5
	TRCell():New(oSection1,"D1_SERIE","SD1","Serie" ) 
	TRCell():New(oSection1,"D1_DOC","SD1","Documento" ) 
	
	TRCell():New(oSection1,"D1_COD"	  ,"SD1",STR0005 ) //"Cod.Produto"
	TRCell():New(oSection1,"cDESC"    ,"",STR0006,,30) //"Produto"
Endif	

If lCatProd
	If nOrdem <>  3
		TRCell():New(oSection1,"ACV_CATEGO"	,"ACV",STR0007 ) //"Cod.Categ."
		TRCell():New(oSection1,"cACUDESC"   ,"",STR0008,,30) //"Categoria"
	Endif	
	If nOrdem <> 4 
		TRCell():New(oSection1,"ACV_GRUPO"	,"ACV",STR0009 ) //"Cod.Grupo"
		TRCell():New(oSection1,"cBMDESC"    ,"",STR0010,,30) //"Grupo"
	Endif	
Endif

TRCell():New(oSection1,"D1_QUANT"	,"SD1",STR0011,"@E 99,999.99" )  		//"Qtde"
TRCell():New(oSection1,"D1_VUNIT"	,"SD1",STR0012,"@E 999,999,999.99",20 )	//"Valor" 
TRCell():New(oSection1,"cTotal"	    ,"",STR0014,"@E 999,999,999.99",20 ) 	//"Total"

oBreak := TRBreak():New(oSection1,oSection1:Cell("D1_QUANT"),STR0013,.F.) //"Totalizador"

oTotaliz  := TRFunction():new(oSection1:Cell("D1_QUANT"),,"SUM",,"Quantidade"	,"@E 999,999,999.99", ) 
oTotaliz  := TRFunction():new(oSection1:Cell("cTotal")	,,"SUM" ,,"Total"  		,"@E 999,999,999.99", ) 

Return oReport
                                                                                                                   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70170Prt บAutor  ณTOTVS               บ Data ณ  01/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel-GP Filial   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR70171                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR701710Prt( oReport, cAlias1,lCatProd)
Local oSection1	:= oReport:Section(1)	// Objeto da secao 1
Local cQryGroup	:= ""                  	// Query do group by
Local cFiltro	:= ""                  	// Filtro
Local cCompara 	:= ""                  	// Variavel de Comparacao
Local cFilACV	:= ""                  	// Filial Query ACV
Local cFilSD1  	:= ""                  	// Filial Query SD1
Local nQuant    := 0                   	// Quantidade
Local nSubTotal := 0                   	// Sub Total
Local nTotal    := 0                   	// Total

If !lCatProd
   cQryGroup:= "% SAU.AU_CODGRUP, SAU.AU_DESCRI,D1_FILIAL, D1_DOC, D1_SERIE, D1_COD, D1_QUANT, D1_VUNIT %"
Else	
   cQryGroup:= "% SAU.AU_CODGRUP, SAU.AU_DESCRI,D1_FILIAL, D1_DOC, D1_SERIE, D1_COD, ACV_GRUPO, ACV_CATEGO,  D1_QUANT, D1_VUNIT %"
Endif	

If lGestao .AND. lACVComp  		// Se a tabela ACV for compartilhada aceito a filial corrente
	cFilACV := "% ACV.ACV_FILIAL = '" + xFilial("ACV") + "' %"
Else 					   		// Se a tabela ACV for exclusiva comparo as Filiais
	cFilACV := "% ACV.ACV_FILIAL = SD1.D1_FILIAL %"
EndIf 
cFilSD1 := "% ("+LJ7017QryFil(.F.,"SD1")[2]+") %"

	DbSelectArea("SD1")
	DbSetOrder(1) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MakeSqlExpr("LJ7017")

	oReport:Section(1):BeginQuery()	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializa a secao 1ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lCatProd
		BEGIN REPORT QUERY oSection1
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณQuery da secao 1ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			BeginSql alias cAlias1
		
		         SELECT DISTINCT SAU.AU_CODGRUP, SAU.AU_DESCRI, SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_COD, SD1.D1_QUANT , ACV.ACV_GRUPO, ACV. ACV_CATEGO, D1_VUNIT
		                                                         
				 FROM %table:SD1% SD1 LEFT JOIN %table:ACV% ACV on ACV.ACV_CODPRO  = SD1.D1_COD
		
		         INNER JOIN %table:SAU%  SAU ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SD1.D1_FILIAL 
		         INNER JOIN %table:SD2%  SD2 ON SD2.D_E_L_E_T_ = ' ' AND SD2.D2_FILIAL = SD1.D1_FILIAL 
					AND SD2.D2_DOC = SD1.D1_NFORI  AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_QTDEDEV <> 0 
					AND SD2.D2_ITEM = SD1.D1_ITEMORI
		         WHERE 	ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM %table:ACU% ACU WHERE  ACU_CODPAI >= %exp:mv_par11% AND ACU_CODPAI <= %exp:mv_par12% AND ACU.%notDel%) 
					AND %exp:cFilSD1%
					AND %exp:cFilACV%
					AND ACV.ACV_GRUPO >= %exp:mv_par13%
				    AND ACV.ACV_GRUPO <= %exp:mv_par14%
					AND D1_COD >= %exp:mv_par15%
	                AND D1_COD <= %exp:mv_par16%
	     			AND D1_QUANT <> 0 
	 	         	AND D1_EMISSAO >= %exp:DToS(mv_par09)%
				    AND D1_EMISSAO <= %exp:DToS(mv_par10)%
	     		    AND ACV.%notDel%  
	     		    AND SD1.%notDel%
	
	   			 GROUP BY %Exp:cQryGroup% 

			EndSql
		
		END REPORT QUERY oSection1
	Else
		BEGIN REPORT QUERY oSection1
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณQuery da secao 1ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			BeginSql alias cAlias1
		
		         SELECT DISTINCT SAU.AU_CODGRUP, SAU.AU_DESCRI,SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE,SD1.D1_COD, D1_QUANT, D1_VUNIT 
		                                                         
				 FROM %table:SD1% SD1
				 INNER JOIN %table:SAU%  SAU ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SD1.D1_FILIAL  
				 INNER JOIN %table:SD2%  SD2  ON SD2.D_E_L_E_T_ = ' ' AND SD2.D2_FILIAL = SD1.D1_FILIAL 
					AND SD2.D2_DOC = SD1.D1_NFORI  AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_QTDEDEV <> 0 
					AND SD2.D2_ITEM = SD1.D1_ITEMORI
		         WHERE %exp:cFilSD1%
					AND D1_COD >= %exp:mv_par15%
					AND D1_COD <= %exp:mv_par16%
					AND D1_QUANT <> 0 
					AND D1_EMISSAO >= %exp:DToS(mv_par09)%
					AND D1_EMISSAO <= %exp:DToS(mv_par10)%
					AND SD1.%notDel%
	
				 GROUP BY %Exp:cQryGroup% 
			    	
			EndSql
		
		END REPORT QUERY oSection1
	Endif	

cCompara := cAlias1+"->AU_CODGRUP"

oSection1:Init()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a impressao dos dados, de acordo com o filtro ou queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cAlias1)
While !oReport:Cancel() .And. !(cAlias1)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

    If !Empty(cFiltro) 
		If alltrim(cFiltro) <> alltrim(&(cCompara))      
  			oReport:PrintText(str(nQuant),oReport:Row(),500) //Total de quantidade
			oReport:PrintText(str(nSubTotal),oReport:Row(),600) //Total de valor unitario
			oReport:SkipLine()
	   		oSection1:Finish()
			oReport:SkipLine()  
			oReport:PrintText(STR0003+(cAlias1)->AU_CODGRUP+" - "+(cAlias1)->AU_DESCRI,oReport:Row(),025)
			oReport:SkipLine()
			oReport:FatLine()
			cFiltro := &(cCompara)
			oSection1:Init()
		Endif	
	Else
		oReport:PrintText(STR0003+": "+(cAlias1)->AU_CODGRUP+" - "+(cAlias1)->AU_DESCRI,oReport:Row(),025) //"Grupo Filial"
		cFiltro  := &(cCompara)
	Endif
 	
	dbSelectArea("SB1")
	DbSetOrder(1) //B1_FILIAL+B1_COD
    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->D1_COD))
       	oSection1:Cell("cDESC"):SetValue(SB1->B1_DESC)
    Endif

	If lCatProd
		dbSelectArea("ACU")
		DbSetOrder(1) //ACU_FILIAL+ACU_COD
	    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
	       	oSection1:Cell("cACUDESC"):SetValue(ACU->ACU_DESC)
	    Endif
		
		If EMPTY((cAlias1)->ACV_GRUPO)
    		dbSelectArea("SB1")
			DbSetOrder(1) //B1_FILIAL+B1_COD
		    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->D1_COD))
		    	dbSelectArea("SBM")
				DbSetOrder(1) //BM_FILIAL+BM_GRUPO
	   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
				oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
			Else
				oSection1:Cell("cBMDESC"):SetValue("")
		    Endif
		Else 
	   		dbSelectArea("SBM")
			DbSetOrder(1) //BM_FILIAL+BM_GRUPO
		    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
			    oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
		    Endif
	 	EndIf
	Endif

	oSection1:Cell("cTotal"):SetValue((cAlias1)->D1_QUANT * (cAlias1)->D1_VUNIT)
	oSection1:PrintLine()
	(cAlias1)->( DbSkip() )
EndDo

oSection1:Finish()
(cAlias1)->(DbCloseArea())

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70171Prt บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR70171                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR70171Prt( oReport, cAlias1,lCatProd,nOrdem )
Local oSection1	:= oReport:Section(1)	// Objeto da secao 1
Local cQryGroup	:= ""                  	// Query do group by
Local cFiltro	:= ""                  	// Filtro
Local cCompara 	:= ""                  	// Variavel de Comparacao
Local cFilSD1  	:= ""                  	// Filial Query SD1
Local cTit    	:= ""                  	// Titulo
Local cSelect 	:= ""                 	// Select da Query

If !lCatProd
	Do Case
		Case nOrdem == 1 //Grupo de filial
		    cQryGroup:= "% D1_FILIAL, D1_DOC, D1_SERIE, D1_COD, D1_QUANT, D1_VUNIT %"
		Case nOrdem == 2 //Filial
		    cQryGroup:= "% D1_FILIAL, D1_DOC, D1_SERIE, D1_COD, D1_QUANT, D1_VUNIT %" 
	    Case nOrdem == 5 //Produtos
		    cQryGroup:= "% D1_FILIAL, D1_DOC, D1_SERIE, D1_COD, D1_QUANT, D1_VUNIT %"
	EndCase    
Else	
	Do Case
		Case nOrdem == 1 //Grupo de filial
		    cQryGroup:= "% D1_FILIAL, D1_DOC, D1_SERIE, D1_COD, ACV_CATEGO, ACV_GRUPO, D1_QUANT, D1_VUNIT %"
		Case nOrdem == 2 //Filial
		    cQryGroup:= "% D1_FILIAL, D1_DOC, D1_SERIE, D1_COD, ACV_CATEGO, ACV_GRUPO, D1_QUANT, D1_VUNIT %"
	    Case nOrdem == 3 //Categoria de produtos
		    cQryGroup:= "% D1_FILIAL, ACV_CATEGO, D1_DOC, D1_SERIE, D1_COD, ACV_GRUPO, D1_QUANT, D1_VUNIT %"
	    Case nOrdem == 4 //Grupo de produtos
		    cQryGroup:= "% D1_FILIAL, ACV_GRUPO, D1_DOC, D1_SERIE, D1_COD, ACV_CATEGO, D1_QUANT, D1_VUNIT %"
	    Case nOrdem == 5 //Produtos
		    cQryGroup:= "% D1_FILIAL, D1_COD, D1_DOC, D1_SERIE, D1_DOC, D1_SERIE, D1_QUANT, D1_VUNIT %"
	EndCase    
Endif	

If lGestao .AND. lACVComp  		// Se a tabela ACV for compartilhada aceito a filial corrente
	cFilACV := "% ACV.ACV_FILIAL = '" + xFilial("ACV") + "' %"
Else 					   		// Se a tabela ACV for exclusiva comparo as Filiais
	cFilACV := "% ACV.ACV_FILIAL = SD1.D1_FILIAL %"
EndIf 
cFilSD1 := "% ("+LJ7017QryFil(.F.,"SD1")[2]+") %"

If lCatProd
	If nOrdem <> 5
		cSelect  := "% SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_COD, ACV_GRUPO, SD1.D1_QUANT , ACV_CATEGO, D1_VUNIT %"
    Else
		cSelect  := "% SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_COD, SD1.D1_QUANT, SD1.D1_VUNIT %"
	Endif
Else
	cSelect  := "% SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_COD, SD1.D1_QUANT , SD1.D1_VUNIT %"
Endif

	DbSelectArea("SD1")
	DbSetOrder(1) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MakeSqlExpr("LJ7017")

	oReport:Section(1):BeginQuery()	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializa a secao 1ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lCatProd
		BEGIN REPORT QUERY oSection1
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณQuery da secao 1ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			BeginSql alias cAlias1
		
		         SELECT DISTINCT %exp:cSelect%
		                                                         
				 FROM %table:SD1% SD1 LEFT JOIN %table:ACV% ACV ON ACV.ACV_CODPRO  = SD1.D1_COD
				 INNER JOIN %table:SD2%  SD2  ON SD2.D_E_L_E_T_ = ' ' AND SD2.D2_FILIAL = SD1.D1_FILIAL 
					AND SD2.D2_DOC = SD1.D1_NFORI  AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_QTDEDEV <> 0 
					AND SD2.D2_ITEM = SD1.D1_ITEMORI
		         WHERE 	ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	%table:ACU% ACU WHERE  ACU_CODPAI >= %exp:mv_par11% AND ACU_CODPAI <= %exp:mv_par12% AND ACU.%notDel%) 
					AND %exp:cFilSD1%
					AND %exp:cFilACV%
					AND ACV.ACV_GRUPO >= %exp:mv_par13% 
					AND ACV.ACV_GRUPO <= %exp:mv_par14%			
					AND D1_COD >= %exp:mv_par15%
					AND D1_COD <= %exp:mv_par16%
					AND D1_QUANT <> 0 
					AND D1_EMISSAO >= %exp:DToS(mv_par09)%
					AND D1_EMISSAO <= %exp:DToS(mv_par10)%
					AND ACV.%notDel%  
					AND SD1.%notDel%
	
	   			 GROUP BY %Exp:cQryGroup% 
			    	
			EndSql
		
		END REPORT QUERY oSection1
	Else
		BEGIN REPORT QUERY oSection1
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณQuery da secao 1ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			BeginSql alias cAlias1
		
		         SELECT DISTINCT SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_COD, D1_QUANT, D1_VUNIT
		                                                         
				 FROM %table:SD1% SD1 
				 INNER JOIN %table:SD2%  SD2  ON SD2.D_E_L_E_T_ = ' ' AND SD2.D2_FILIAL = SD1.D1_FILIAL 
					AND SD2.D2_DOC = SD1.D1_NFORI  AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_QTDEDEV <> 0 
					AND SD2.D2_ITEM = SD1.D1_ITEMORI
		         WHERE %exp:cFilSD1%
					AND D1_COD >= %exp:mv_par15%
					AND D1_COD <= %exp:mv_par16%
					AND D1_QUANT <> 0 
					AND D1_EMISSAO >= %exp:DToS(mv_par09)%
					AND D1_EMISSAO <= %exp:DToS(mv_par10)%
					AND SD1.%notDel%
	
				 GROUP BY %Exp:cQryGroup% 
			    	
			EndSql
		
		END REPORT QUERY oSection1
	Endif
	oSection1:Init()

Do Case
	Case nOrdem == 1 //Grupo de filial
	    cCompara := cAlias1+"->D1_FILIAL"
	Case nOrdem == 2 //Filial
	    cCompara := cAlias1+"->D1_FILIAL
    Case nOrdem == 3 //Categoria de produtos
	    cCompara := cAlias1+"->D1_FILIAL+"+cAlias1+"->ACV_CATEGO"
    Case nOrdem == 4 //Grupo de produtos
	    cCompara := cAlias1+"->D1_FILIAL+"+cAlias1+"->ACV_GRUPO"
    Case nOrdem == 5 //Produtos
	    cCompara := cAlias1+"->D1_FILIAL+"+cAlias1+"->D1_COD"    
EndCase    

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a impressao dos dados, de acordo com o filtro ou queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cAlias1)
While !oReport:Cancel() .And. !(cAlias1)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

	If !Empty(cFiltro) 
		If alltrim(cFiltro) <> alltrim(&(cCompara))   
            
			If nOrdem == 2 //Filial
			    cTit  := STR0004+": " + (cAlias1)->D1_FILIAL //"Filial"
		    Endif
		    
		    If lCatProd
			    If nOrdem == 3 //Categoria de produtos
			   		dbSelectArea("ACU")
					DbSetOrder(1) //ACU_FILIAL+ACU_COD
				    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
					    cTit  := STR0066+": " +(cAlias1)->ACV_CATEGO+" - "+ACU->ACU_DESC //"Categoria de Produtos"
				    Endif
			    Endif
			    If nOrdem == 4 //Grupo de produtos
				    If EMPTY((cAlias1)->ACV_GRUPO)
			    		dbSelectArea("SB1")
						DbSetOrder(1) //B1_FILIAL+B1_COD
					    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->D1_COD))
					    	dbSelectArea("SBM")
							DbSetOrder(1) //BM_FILIAL+BM_GRUPO
				   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
							cTit  := STR0067+": " +SB1->B1_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
						Else
							cTit  := STR0067+": "
					    Endif
					Else 
				   		dbSelectArea("SBM")
						DbSetOrder(1) //BM_FILIAL+BM_GRUPO
					    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
						    cTit  := STR0067+": " +(cAlias1)->ACV_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
					    Endif
				 	EndIf
			    Endif
		    Endif
		    
		    If nOrdem == 5 //Produtos
		    	dbSelectArea("SB1")
				DbSetOrder(1) //B1_FILIAL+B1_COD
			    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->D1_COD))
		   		    cTit  := STR0006+": " +(cAlias1)->D1_COD+" - "+SB1->B1_DESC //"Produto"	    
			    Endif
		    Endif    			
            
			oSection1:Finish()
			oReport:SkipLine()
			oReport:PrintText(cTit,oReport:Row(),025)
			oReport:SkipLine()
			oReport:FatLine()
			cFiltro := &(cCompara)
			oSection1:Init()
			
		Endif    
	Else
		    
		If nOrdem == 2 //Filial
		    cTit  := STR0004+": " + (cAlias1)->D1_FILIAL //"Filial"
	    Endif
	    
	    If lCatProd
		    If nOrdem == 3 //Categoria de produtos
		   		dbSelectArea("ACU")
				DbSetOrder(1) //ACU_FILIAL+ACU_COD
			    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
				    cTit  := STR0066+": " +(cAlias1)->ACV_CATEGO+" - "+ACU->ACU_DESC //"Categoria de Produtos"
			    Endif
		    Endif
		    If nOrdem == 4 //Grupo de produtos
		    	If EMPTY((cAlias1)->ACV_GRUPO)
		    		dbSelectArea("SB1")
					DbSetOrder(1) //B1_FILIAL+B1_COD
				    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->D1_COD))
				    	dbSelectArea("SBM")
						DbSetOrder(1) //BM_FILIAL+BM_GRUPO
			   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
						cTit  := STR0067+": " +SB1->B1_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
					Else
						cTit  := STR0067+": "
				    Endif
				Else 
			   		dbSelectArea("SBM")
					DbSetOrder(1) //BM_FILIAL+BM_GRUPO
				    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
					    cTit  := STR0067+": " +(cAlias1)->ACV_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
				    Endif
			 	EndIf
		    Endif
	    Endif
	    
	    If nOrdem == 5 //Produtos
	    	dbSelectArea("SB1")
			DbSetOrder(1) //B1_FILIAL+B1_COD
		    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->D1_COD))
	   		    cTit  := STR0006+": " +(cAlias1)->D1_COD+" - "+SB1->B1_DESC //"Produto"	    
		    Endif
		Endif    			

		oReport:PrintText(cTit,oReport:Row(),025)
		cFiltro := &(cCompara)
	Endif
	
	
	If lCatProd
		If nOrdem <> 3 .And. nOrdem <> 5  //Categoria de produtos e Produtos
	   		dbSelectArea("ACU")
			DbSetOrder(1) //ACU_FILIAL+ACU_COD
		    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
	           	oSection1:Cell("cACUDESC"):SetValue(ACU->ACU_DESC)
		    Endif
	    Endif
	
	    If  nOrdem <> 4 .And. nOrdem <> 5 //Grupo de produtos e Produtos
		    If EMPTY((cAlias1)->ACV_GRUPO)
	    		dbSelectArea("SB1")
				DbSetOrder(1) //B1_FILIAL+B1_COD
			    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->D1_COD))
			    	dbSelectArea("SBM")
					DbSetOrder(1) //BM_FILIAL+BM_GRUPO
		   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
					oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
				Else
					oSection1:Cell("cBMDESC"):SetValue("")
			    Endif
			Else 
		   		dbSelectArea("SBM")
				DbSetOrder(1) //BM_FILIAL+BM_GRUPO
			    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
				    oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
			    Endif
		 	EndIf
	    Endif
	Endif
	    
    If nOrdem <> 5 //Produtos
    	dbSelectArea("SB1")
		DbSetOrder(1) //B1_FILIAL+B1_COD
	    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->D1_COD))
           	oSection1:Cell("cDESC"):SetValue(SB1->B1_DESC)
	    Endif
 	Endif
 		
	oSection1:Cell("cTotal"):SetValue((cAlias1)->D1_QUANT * (cAlias1)->D1_VUNIT)
	oSection1:PrintLine()
	(cAlias1)->( DbSkip() )
EndDo

oSection1:Finish()
(cAlias1)->(DbCloseArea())

Return NIL


//-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-Prevencao de Perdas\Estoque\Produtos Cancelados-=-=-=--=-=-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณ LJR70172 ณ Autor ณ TOTVS               ณ Data ณ 24/07/2013 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณPrevencao de Perdas\Produtos Cancelados                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณRelatorio Personalizavel									  ณฑฑ
ฑฑศออออออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LJR70172(lCatProd,cTitulo,nOrdem,aGPFilial)
Local oReport 	:= NIL				// Objeto para geracao do relatorio
Local aArea 	:= GetArea() 		// Salva a area

Default aGPFilial := {} 			// Grupo de Filiais

Pergunte("LJ7017",.F.)//O pergunte deve estar desabilitado 

oReport := LJR70172Def(lCatProd,cTitulo,nOrdem,aGPFilial)
oReport:PrintDialog()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a areaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea( aArea )
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70172Def บAutor  ณTOTVS             บ Data ณ  24/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao das celulas que irao compor o relatorio           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR70172                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR70172Def(lCatProd,cTitulo,nOrdem,aGPFilial)
Local oReport	:= NIL						// Objeto do relatorio
Local oSection1	:= NIL						// Objeto da secao 1
Local cAlias1	:= GetNextAlias()			// Pega o proximo Alias Disponivel
Local oTotaliz 	:= NIL						// Objeto totalizador
Local oBreak	:= NIL						// Objeto de Quebra

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera a tela com os dados para a confirma็ใo da geracao do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(aGPFilial)
	oReport := TReport():New("LOJR70172",STR0001+" "+cTitulo,"",{|oReport| LJR701720Prt(oReport, cAlias1,lCatProd,nOrdem,aGPFilial )},STR0002 )//Relat๓rio Analitico##"Prevencao de Perdas"
Else
	oReport := TReport():New("LOJR70172",STR0001+" "+cTitulo,"",{|oReport| LJR70172Prt(oReport, cAlias1,lCatProd,nOrdem )},STR0002 )//Relat๓rio Analitico##"Prevencao de Perdas"
Endif	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine a secao1 do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1 := TRSection():New( oReport,"",{ "SLX","ACV","ACU" } )	
oSection1:SetHeaderBreak(.T.)		//Indica se cabecalho da secao sera impresso em cada quebra 
oSection1:SetHeaderPage(.T.)		//Indica que cabecalho da secao sera impresso no topo da pagina

oReport:SetLandscape(.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine as celulas que irao aparecer na secao1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
If nOrdem <> 2
	TRCell():New(oSection1,"LX_FILIAL"	,"SLX",STR0004, ) //"Filial"
Endif	

TRCell():New(oSection1,"LX_PDV","SLX","PDV" ) 
TRCell():New(oSection1,"LX_SERIE","SLX","Serie" ) 
TRCell():New(oSection1,"LX_CUPOM","SLX","Documento" ) 

If nOrdem <> 5
	TRCell():New(oSection1,"LX_PRODUTO" ,"SLX",STR0005 ) //"Cod.Produto"
	TRCell():New(oSection1,"cDESC"      ,"",STR0006,,30) //"Produto" 
Endif	
If lCatProd
	If nOrdem <> 3
		TRCell():New(oSection1,"ACV_CATEGO"	,"ACV",STR0007 ) //"Cod.Categ."
		TRCell():New(oSection1,"cACUDESC"   ,"",STR0008,,30) //"Categoria"
	Endif
	If nOrdem <> 4
		TRCell():New(oSection1,"ACV_GRUPO"	,"ACV",STR0009 ) //"Cod.Grupo" 
		TRCell():New(oSection1,"cBMDESC"    ,"",STR0010,,30) //"Grupo"
	Endif	
Endif	
TRCell():New(oSection1,"LX_QTDE"	,"SLX"	,STR0011 ) 	//"Qtde"
TRCell():New(oSection1,"LX_VALOR"	,"SLX"	,STR0012,"@E 999,999,999.99",20 ) //"Valor"
TRCell():New(oSection1,"cTotal"	    ,    	,STR0014,"@E 999,999,999.99",20 ) //"Total"

oBreak := TRBreak():New(oSection1,oSection1:Cell("LX_QTDE") ,STR0011,.F.) //"Qtde"
oBreak := TRBreak():New(oSection1,oSection1:Cell("LX_VALOR"),STR0012,.F.) //"Valor"

oTotaliz := TRFunction():new(oSection1:Cell("LX_QTDE")  ,,"SUM",,STR0011  ,"@E 999,999,999.99") //"Qtde"
oTotaliz  := TRFunction():new(oSection1:Cell("LX_VALOR"),,"SUM",,STR0012  ,"@E 999,999,999.99") //"Valor"
oTotaliz  := TRFunction():new(oSection1:Cell("cTotal")  ,,"SUM",,STR0014  ,"@E 999,999,999.99") //"Total"

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70170Prt บAutor  ณTOTVS               บ Data ณ  01/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑบ          ณProdutos Cancelados - GP Filial                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR70172                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR701720Prt( oReport, cAlias1,lCatProd,nOrdem )
Local oSection1	:= oReport:Section(1)	// Objeto da secao 1
Local cQryGroup	:= ""                  	// Query do group by
Local cFilSLX  	:= ""                  	// Filial da query
Local cFiltro	:= ""                  	// Filtro
Local cCompara 	:= ""                  	// Variavel de Comparacao

If lCatProd
   cQryGroup:= "% AU_CODGRUP, AU_DESCRI,LX_FILIAL, LX_PDV,LX_CUPOM, LX_SERIE, LX_PRODUTO, ACV_CATEGO, ACV_GRUPO, LX_QTDE, LX_VALOR %"
Else	
   cQryGroup:= "% AU_CODGRUP, AU_DESCRI,LX_FILIAL, LX_PDV,LX_CUPOM, LX_SERIE, LX_PRODUTO, LX_QTDE, LX_VALOR %"
Endif	

If lGestao .AND. lACVComp  		// Se a tabela ACV for compartilhada aceito a filial corrente
	cFilACV := "% ACV.ACV_FILIAL = '" + xFilial("ACV") + "' %"
Else 					   		// Se a tabela ACV for exclusiva comparo as Filiais
	cFilACV := "% ACV.ACV_FILIAL = SLX.LX_FILIAL %"
EndIf 
cFilSLX := "% ("+LJ7017QryFil(.F.,"SLX")[2]+") %"

	DbSelectArea("SLX")
	DbSetOrder(1) //LX_FILIAL+LX_PDV+LX_CUPOM+LX_SERIE+LX_ITEM+LX_HORA
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MakeSqlExpr("LJ7017")

	oReport:Section(1):BeginQuery()	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializa a secao 1ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
     If lCatProd
     	BEGIN REPORT QUERY oSection1

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณQuery da secao 1ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			BeginSql alias cAlias1
		
				   SELECT DISTINCT SAU.AU_CODGRUP, SAU.AU_DESCRI,SLX.LX_FILIAL, SLX.LX_PDV, SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_PRODUTO,SLX.LX_QTDE, ACV.ACV_CATEGO,  ACV.ACV_GRUPO, SLX.LX_VALOR
	  			   FROM %table:SLX% SLX LEFT JOIN %table:ACV% ACV on ACV.ACV_CODPRO  = SLX.LX_PRODUTO 
	  			   INNER JOIN %table:SAU%  SAU ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SLX.LX_FILIAL 
	  			   WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	%table:ACU% ACU WHERE  ACU_CODPAI >= %exp:mv_par11% AND ACU_CODPAI <= %exp:mv_par12% AND ACU.%notDel%) 			   	
						AND %exp:cFilSLX%
						AND %exp:cFilACV%
						AND ACV.ACV_GRUPO >= %exp:mv_par13%
						AND ACV.ACV_GRUPO <= %exp:mv_par14%  
						AND LX_PRODUTO >= %exp:mv_par15%
						AND LX_PRODUTO <= %exp:mv_par16%
						AND LX_QTDE <> 0
						AND LX_TPCANC <> 'D'
						AND LX_PDV >= %exp:mv_par07%
						AND LX_PDV <= %exp:mv_par08%
						AND LX_DTMOVTO >= %exp:DToS(mv_par09)%
						AND LX_DTMOVTO <= %exp:DToS(mv_par10)%
						AND ACV.%notDel%                                                                                       
						AND SLX.%notDel%
	
			  	GROUP BY %Exp:cQryGroup% 
		    EndSql
		 END REPORT QUERY oSection1
	 Else
		BEGIN REPORT QUERY oSection1
			BeginSql alias cAlias1
			   SELECT DISTINCT SAU.AU_CODGRUP, SAU.AU_DESCRI,SLX.LX_FILIAL, SLX.LX_PDV, SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_PRODUTO,SLX.LX_QTDE, SLX.LX_VALOR
	  		   FROM %table:SLX% SLX 
	           INNER JOIN %table:SAU%  SAU ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SLX.LX_FILIAL
	  		   WHERE %exp:cFilSLX%
					 AND LX_PRODUTO >= %exp:mv_par15%
		             AND LX_PRODUTO <= %exp:mv_par16%
		     		 AND LX_QTDE <> 0
					 AND LX_TPCANC <> 'D'
		             AND LX_PDV >= %exp:mv_par07%
			         AND LX_PDV <= %exp:mv_par08%
		    		 AND LX_DTMOVTO >= %exp:DToS(mv_par09)%
					 AND LX_DTMOVTO <= %exp:DToS(mv_par10)%                                                                                      
		     		 AND SLX.%notDel%   
		     		 
				GROUP BY %Exp:cQryGroup% 		     		 
		   	EndSql
		END REPORT QUERY oSection1
	 Endif  

cCompara := cAlias1+"->AU_CODGRUP"

oSection1:Init()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a impressao dos dados, de acordo com o filtro ou queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cAlias1)
While !oReport:Cancel() .And. !(cAlias1)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

	If !Empty(cFiltro) 
		If alltrim(cFiltro) <> alltrim(&(cCompara))      
	   		oSection1:Finish()
			oReport:SkipLine()  
			oReport:PrintText(STR0003+": "+(cAlias1)->AU_CODGRUP+" - "+(cAlias1)->AU_DESCRI,oReport:Row(),025) //"Grupo Filial"
			oReport:SkipLine()
			oReport:FatLine()
			cFiltro := &(cCompara)
			oSection1:Init()   
		Endif	
	Else
		oReport:PrintText(STR0003+": "+(cAlias1)->AU_CODGRUP+" - "+(cAlias1)->AU_DESCRI,oReport:Row(),025) //"Grupo Filial"
		cFiltro := &(cCompara)
	Endif	

	dbSelectArea("SB1")
	DbSetOrder(1) //B1_FILIAL+B1_COD
    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->LX_PRODUTO))
       	oSection1:Cell("cDESC"):SetValue(SB1->B1_DESC)
    Endif
	
	If lCatProd
		dbSelectArea("ACU")
		DbSetOrder(1) //ACU_FILIAL+ACU_COD
	    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
	       	oSection1:Cell("cACUDESC"):SetValue(ACU->ACU_DESC)
	    Endif
		
		If EMPTY((cAlias1)->ACV_GRUPO)
    		dbSelectArea("SB1")
			DbSetOrder(1) //B1_FILIAL+B1_COD
		    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->LX_PRODUTO))
		    	dbSelectArea("SBM")
				DbSetOrder(1) //BM_FILIAL+BM_GRUPO
	   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
				oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
			Else
				oSection1:Cell("cBMDESC"):SetValue("")
		    Endif
		Else 
	   		dbSelectArea("SBM")
			DbSetOrder(1) //BM_FILIAL+BM_GRUPO
		    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
			    oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
		    Endif
	 	EndIf
	Endif		       	
	oSection1:Cell("cTotal"):SetValue((cAlias1)->LX_QTDE * (cAlias1)->LX_VALOR)	
	oSection1:PrintLine()
	(cAlias1)->( DbSkip() )
EndDo

oSection1:Finish()

(cAlias1)->(DbCloseArea())

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70172Prt บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR70172                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR70172Prt( oReport, cAlias1,lCatProd,nOrdem )
Local oSection1	:= oReport:Section(1)	// Objeto da secao 1
Local cFiltro	:= ""                  	// Filtro
Local cQryGroup	:= ""                  	// Query do group by
Local cCompara 	:= ""                  	// Variavel de Comparacao
Local cFilSLX	:= ""                  	// Filial da query
Local cTit    	:= ""                  	// Titulo
Local cSelect 	:= ""                 	// Select da Query

If lGestao .AND. lACVComp  		// Se a tabela ACV for compartilhada aceito a filial corrente
	cFilACV := "% ACV.ACV_FILIAL = '" + xFilial("ACV") + "' %"
Else 					   		// Se a tabela ACV for exclusiva comparo as Filiais
	cFilACV := "% ACV.ACV_FILIAL = SLX.LX_FILIAL %"
EndIf 
cFilSLX := "% ("+LJ7017QryFil(.F.,"SLX")[2]+") %"

If lCatProd
	Do Case
		Case nOrdem == 1 //Grupo de filial
		    cQryGroup:= "% LX_FILIAL, LX_PDV, LX_CUPOM, LX_SERIE, LX_PRODUTO, ACV_CATEGO, ACV_GRUPO, LX_QTDE, LX_VALOR %"
		Case nOrdem == 2 //Filial
		    cQryGroup:= "% LX_FILIAL, LX_PDV, LX_CUPOM, LX_SERIE, LX_PRODUTO, ACV_CATEGO, ACV_GRUPO, LX_QTDE, LX_VALOR %"
	    Case nOrdem == 3 //Categoria de produtos
		    cQryGroup:= "% LX_FILIAL, LX_PDV, LX_CUPOM, LX_SERIE, ACV_CATEGO, LX_PRODUTO, ACV_GRUPO, LX_QTDE, LX_VALOR %"
	    Case nOrdem == 4 //Grupo de produtos
		    cQryGroup:= "% LX_FILIAL, LX_PDV, LX_CUPOM, LX_SERIE, ACV_GRUPO, LX_PRODUTO, ACV_CATEGO, LX_QTDE, LX_VALOR %"
	    Case nOrdem == 5 //Produtos
		    cQryGroup:= "% LX_FILIAL, LX_PDV, LX_CUPOM, LX_SERIE, LX_PRODUTO, ACV_CATEGO, ACV_GRUPO, LX_QTDE, LX_VALOR %"
	EndCase    
Else
	Do Case
		Case nOrdem == 1 //Grupo de filial
		    cQryGroup:= "% LX_FILIAL, LX_PDV, LX_CUPOM, LX_SERIE,LX_PRODUTO, LX_QTDE, LX_VALOR %"
		Case nOrdem == 2 //Filial
		    cQryGroup:= "% LX_FILIAL, LX_PDV, LX_CUPOM, LX_SERIE,LX_PRODUTO, LX_QTDE, LX_VALOR  %"
	    Case nOrdem == 5 //Produtos
		    cQryGroup:= "% LX_FILIAL, LX_PDV, LX_CUPOM, LX_SERIE,LX_PRODUTO, LX_QTDE, LX_VALOR  %"
	EndCase    
Endif	

If lCatProd
	If nOrdem <> 5
		cSelect  := "% SLX.LX_FILIAL, SLX.LX_PRODUTO,SLX.LX_QTDE, ACV.ACV_CATEGO, ACV.ACV_GRUPO, SLX.LX_PDV, SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_VALOR %"
    Else
		cSelect  := "% SLX.LX_FILIAL, SLX.LX_PRODUTO,SLX.LX_QTDE, ACV.ACV_CATEGO, ACV.ACV_GRUPO, SLX.LX_PDV, SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_VALOR %"
	Endif
Else
	cSelect  := "% SLX.LX_FILIAL, SLX.LX_PRODUTO,SLX.LX_QTDE, SLX.LX_PDV, SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_VALOR %"
Endif

	DbSelectArea("SLX")
	DbSetOrder(1) //LX_FILIAL+LX_PDV+LX_CUPOM+LX_SERIE+LX_ITEM+LX_HORA
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MakeSqlExpr("LJ7017")

	oReport:Section(1):BeginQuery()	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializa a secao 1ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
     If lCatProd
     	BEGIN REPORT QUERY oSection1

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณQuery da secao 1ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			BeginSql alias cAlias1
		
				   SELECT DISTINCT %exp:cSelect%  
	  			   FROM %table:SLX% SLX LEFT JOIN %table:ACV% ACV on ACV.ACV_CODPRO  = SLX.LX_PRODUTO 	
	  			   WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	%table:ACU% ACU WHERE  ACU_CODPAI >= %exp:mv_par11% AND ACU_CODPAI <= %exp:mv_par12% AND ACU.%notDel%) 			   	
						AND %exp:cFilSLX%
						AND %exp:cFilACV%
						AND ACV.ACV_GRUPO >= %exp:mv_par13%
						AND ACV.ACV_GRUPO <= %exp:mv_par14%
						AND LX_PRODUTO >= %exp:mv_par15%
						AND LX_PRODUTO <= %exp:mv_par16%
						AND LX_QTDE <> 0
						AND LX_TPCANC <> 'D'
						AND LX_PDV >= %exp:mv_par07%
						AND LX_PDV <= %exp:mv_par08%
						AND LX_DTMOVTO >= %exp:DToS(mv_par09)%
						AND LX_DTMOVTO <= %exp:DToS(mv_par10)%
						AND ACV.%notDel%
						AND SLX.%notDel%
						
			  	GROUP BY %Exp:cQryGroup% 
		    EndSql
		 END REPORT QUERY oSection1
	 Else
		BEGIN REPORT QUERY oSection1
			BeginSql alias cAlias1
			   SELECT DISTINCT SLX.LX_FILIAL, SLX.LX_PRODUTO,SLX.LX_QTDE, SLX.LX_PDV, SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_VALOR
	  		   FROM %table:SLX% SLX 
	  		   WHERE %exp:cFilSLX%
					 AND LX_PRODUTO >= %exp:mv_par15%
		             AND LX_PRODUTO <= %exp:mv_par16%
		     		 AND LX_QTDE <> 0
		     		 AND LX_TPCANC <> 'D'
		             AND LX_PDV >= %exp:mv_par07%
			         AND LX_PDV <= %exp:mv_par08%
		    		 AND LX_DTMOVTO >= %exp:DToS(mv_par09)%
					 AND LX_DTMOVTO <= %exp:DToS(mv_par10)%                                                                                      
		     		 AND SLX.%notDel%   
		     		 
				GROUP BY %Exp:cQryGroup% 		     		 
		   	EndSql
		END REPORT QUERY oSection1
	 Endif
		
	oSection1:Init()

Do Case
	Case nOrdem == 1 //Grupo de filial
	    cCompara := cAlias1+"->LX_FILIAL"
	Case nOrdem == 2 //Filial
	    cCompara := cAlias1+"->LX_FILIAL
    Case nOrdem == 3 //Categoria de produtos
	    cCompara := cAlias1+"->LX_FILIAL+"+cAlias1+"->ACV_CATEGO"
    Case nOrdem == 4 //Grupo de produtos
	    cCompara := cAlias1+"->LX_FILIAL+"+cAlias1+"->ACV_GRUPO"
    Case nOrdem == 5 //Produtos
	    cCompara := cAlias1+"->LX_FILIAL+"+cAlias1+"->LX_PRODUTO"
EndCase    

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a impressao dos dados, de acordo com o filtro ou queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cAlias1)
While !oReport:Cancel() .And. !(cAlias1)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

  	If !Empty(cFiltro) 
		If alltrim(cFiltro) <> alltrim(&(cCompara))      
				
			If nOrdem == 2 //Filial
		   	    cTit := STR0004+": " + (cAlias1)->LX_FILIAL //"Filial"
		    Endif
		    
		    If lCatProd
			    If nOrdem == 3 //Categoria de produtos
			   		dbSelectArea("ACU")
					DbSetOrder(1) //ACU_FILIAL+ACU_COD
				    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
					    cTit  := STR0066+": " +(cAlias1)->ACV_CATEGO+" - "+ACU->ACU_DESC //"Categoria de Produtos"
				    Endif
			    Endif
			    If nOrdem == 4 //Grupo de produtos
			    	If EMPTY((cAlias1)->ACV_GRUPO)
			    		dbSelectArea("SB1")
						DbSetOrder(1) //B1_FILIAL+B1_COD
					    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->LX_PRODUTO))
					    	dbSelectArea("SBM")
							DbSetOrder(1) //BM_FILIAL+BM_GRUPO
				   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
							cTit  := STR0067+": " +SB1->B1_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
						Else
							cTit  := STR0067+": "
					    Endif
					Else 
				   		dbSelectArea("SBM")
						DbSetOrder(1) //BM_FILIAL+BM_GRUPO
					    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
						    cTit  := STR0067+": " +(cAlias1)->ACV_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
					    Endif
				 	EndIf
				 Endif   
		    Endif
		    
		    If nOrdem == 5 //Produtos
			    dbSelectArea("SB1")
				DbSetOrder(1) //B1_FILIAL+B1_COD
			    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->LX_PRODUTO))
		   		    cTit  := STR0006+": " +(cAlias1)->LX_PRODUTO+" - "+SB1->B1_DESC //"Produto"
			    Endif
		    Endif
		    
		    oSection1:Finish()
			oReport:SkipLine()
			oReport:PrintText(cTit,oReport:Row(),025)
			oReport:SkipLine()
			oReport:FatLine()
			cFiltro := &(cCompara)
			oSection1:Init()
			    
		Endif	
	Else
		If nOrdem == 2 //Filial
	   	    cTit := STR0004+": " + (cAlias1)->LX_FILIAL //"Filial"
	    Endif
	    
	    If lCatProd
		    If nOrdem == 3 //Categoria de produtos
		   		dbSelectArea("ACU")
				DbSetOrder(1) //ACU_FILIAL+ACU_COD
			    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
				    cTit  := STR0066+": " +(cAlias1)->ACV_CATEGO+" - "+ACU->ACU_DESC //"Categoria de Produtos"
			    Endif
		    Endif
		    If nOrdem == 4 //Grupo de produtos
		    	If EMPTY((cAlias1)->ACV_GRUPO)
		    		dbSelectArea("SB1")
					DbSetOrder(1) //B1_FILIAL+B1_COD
				    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->LX_PRODUTO))
				    	dbSelectArea("SBM")
						DbSetOrder(1) //BM_FILIAL+BM_GRUPO
			   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
						cTit  := STR0067+": " +SB1->B1_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
					Else
						cTit  := STR0067+": "
				    Endif
				Else 
			   		dbSelectArea("SBM")
					DbSetOrder(1) //BM_FILIAL+BM_GRUPO
				    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
					    cTit  := STR0067+": " +(cAlias1)->ACV_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
				    Endif
			 	EndIf
			 Endif
	    Endif
	    
	    If nOrdem == 5 //Produtos
		    dbSelectArea("SB1")
			DbSetOrder(1) //B1_FILIAL+B1_COD
		    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->LX_PRODUTO))
	   		    cTit  := STR0006+": " +(cAlias1)->LX_PRODUTO+" - "+SB1->B1_DESC //"Produto"
		    Endif
	    Endif    

		oReport:PrintText(cTit,oReport:Row(),025)
		cFiltro := &(cCompara)
	Endif
	
    If lCatProd
	    If nOrdem <> 3 //Categoria de produtos
	   		dbSelectArea("ACU")
			DbSetOrder(1) //ACU_FILIAL+ACU_COD
		    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
	   	       	oSection1:Cell("cACUDESC"):SetValue(ACU->ACU_DESC)
		    Endif
	    Endif
	    
	    If nOrdem <> 4 //Grupo de produtos
			If EMPTY((cAlias1)->ACV_GRUPO)
	    		dbSelectArea("SB1")
				DbSetOrder(1) //B1_FILIAL+B1_COD
			    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->LX_PRODUTO))
			    	dbSelectArea("SBM")
					DbSetOrder(1) //BM_FILIAL+BM_GRUPO
		   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
					oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
				Else
					oSection1:Cell("cBMDESC"):SetValue("")
			    Endif
			Else 
		   		dbSelectArea("SBM")
				DbSetOrder(1) //BM_FILIAL+BM_GRUPO
			    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
				    oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
			    Endif
		 	EndIf
	    Endif
	Endif
	
    If nOrdem <> 5 //Produtos
	    dbSelectArea("SB1")
		DbSetOrder(1) //B1_FILIAL+B1_COD
	    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->LX_PRODUTO))
   		    oSection1:Cell("cDESC"):SetValue(SB1->B1_DESC)
	    Endif
    Endif
	oSection1:Cell("cTotal"):SetValue((cAlias1)->LX_QTDE * (cAlias1)->LX_VALOR)	
	oSection1:PrintLine()
	(cAlias1)->( DbSkip() )
EndDo

oSection1:Finish()
(cAlias1)->(DbCloseArea())

Return NIL


//-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-Prevencao de Perdas\Estoque\Venda Perdida-=-=-=--=-=-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณ LJR70173 ณ Autor ณ TOTVS               ณ Data ณ 24/07/2013 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณPrevencao de Perdas\Venda Perdida                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณRelatorio Personalizavel									  ณฑฑ
ฑฑศออออออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LJR70173(lCatProd,cTitulo,nOrdem,aGPFilial)
Local oReport 	:= NIL				// Objeto para geracao do relatorio
Local aArea 	:= GetArea() 		// Salva a area

Default aGPFilial := {} 			// Grupo de Filiais

Pergunte("LJ7017",.F.)//O pergunte deve estar desabilitado 

oReport := LJR70173Def(lCatProd,cTitulo,nOrdem,aGPFilial)
oReport:PrintDialog()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a areaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea( aArea )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70173Def บAutor  ณTOTVS             บ Data ณ  24/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao das celulas que irao compor o relatorio           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR100                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR70173Def(lCatProd,cTitulo,nOrdem,aGPFilial)
Local oReport	:= NIL									// Objeto do relatorio
Local oSection1	:= NIL									// Objeto da secao 1
Local cAlias1	:= GetNextAlias()						// Pega o proximo Alias Disponivel
Local oTotaliz	:= NIL									// Objeto totalizador
Local oBreak	:= NIL									// Objeto de Quebra

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera a tela com os dados para a confirma็ใo da geracao do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If !Empty(aGPFilial)
	oReport := TReport():New("LOJR70171",STR0001+" "+cTitulo,"",{|oReport| LJR701730Prt(oReport, cAlias1, lCatProd, nOrdem,aGPFilial )},STR0002 )//Relat๓rio Analitico##"Prevencao de Perdas"
Else
	oReport := TReport():New("LOJR70171",STR0001+" "+cTitulo,"",{|oReport| LJR70173Prt(oReport, cAlias1, lCatProd, nOrdem )},STR0002 )//Relat๓rio Analitico##"Prevencao de Perdas"
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine a secao1 do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1 := TRSection():New( oReport,"",{ "MBR","ACU","ACV" } )	

oSection1:SetHeaderBreak(.T.)		//Indica se cabecalho da secao sera impresso em cada quebra 
oSection1:SetHeaderPage(.T.)		//Indica que cabecalho da secao sera impresso no topo da pagina

oReport:SetLandscape(.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine as celulas que irao aparecer na secao1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOrdem <> 2 
	TRCell():New(oSection1,"MBR_FILIAL" ,"MBR",STR0004 ) //"Filial"
Endif

If nOrdem <> 6 
	TRCell():New(oSection1,"MBR_PROD"  	,"MBR",STR0005)  //"Cod.Produto"
	TRCell():New(oSection1,"cDESC"    	,"",STR0006,,30) //"Produto"
	TRCell():New(oSection1,"MBR_SERIE"	,"MBR",STR0015 ) //"Serie"
	TRCell():New(oSection1,"MBR_DOC"   	,"MBR",STR0063 ) //Documento 
	TRCell():New(oSection1,"MBR_NUMORC"	,"MBR",STR0033 ) //Numero Movimento 
Endif	

TRCell():New(oSection1,"MBR_EMISSA"	,"MBR",STR0017,,12) //"Dt.Emissao"
TRCell():New(oSection1,"MBR_PDV"	,"MBR",STR0018 ) //"PDV"

TRCell():New(oSection1,"MBR_ESTACA" ,"MBR","Esta็ใo" ) 

If lCatProd
	If nOrdem <> 4 
		TRCell():New(oSection1,"ACV_CATEGO"	,"ACV",STR0007 ) //"Cod.Categ."
		TRCell():New(oSection1,"cACUDESC"   ,"",STR0008,,30) //"Categoria"
	Endif
	If nOrdem <> 5 
		TRCell():New(oSection1,"ACV_GRUPO"	,"ACV",STR0009 ) //"Cod.Grupo"
		TRCell():New(oSection1,"cBMDESC"   ,"",STR0010,,30) //"Grupo"
	Endif
Endif

If nOrdem <> 3 
	TRCell():New(oSection1,"MBR_MOTIVO"	,"MBR",STR0023) //"Cod.Motivo"
Endif	

TRCell():New(oSection1,"MBR_QUANT"	,"MBR",STR0019,"@E 999,999.99" ) 		//"Quantidade"
TRCell():New(oSection1,"cTotal"	    ,"",STR0014,"@E 999,999,999.99",20 )  	//"Total"

oBreak := TRBreak():New(oSection1,oSection1:Cell("MBR_QUANT"),STR0013,.F.) //"Totalizador"

oTotaliz := TRFunction():new(oSection1:Cell("MBR_QUANT"),	,"SUM",,STR0014,"@E 999,999.99") //"Total"
oTotaliz  := TRFunction():new(oSection1:Cell("cTotal"),   	,"SUM",,"Total"  ,"@E 999,999,999.99", ) 

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70170Prt บAutor  ณTOTVS               บ Data ณ  01/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑบ          ณVenda Perdida - GP Filial                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR70171                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR701730Prt( oReport, cAlias1,lCatProd,nOrdem )
Local oSection1	:= oReport:Section(1)	// Objeto da secao 1
Local cQryGroup	:= ""                  	// Query do group by
Local cFilMBR  	:= ""                  	// Filial da query
Local nY 		:= 1					// Contador
Local cFiltro	:= ""                  	// Filtro
Local cCompara 	:= ""                  	// Variavel de Comparacao
Local nPrecoTab := 0

If lCatProd
   cQryGroup:= "% SAU.AU_CODGRUP,SAU.AU_DESCRI,MBR.MBR_FILIAL,MBR.MBR_PROD,ACV.ACV_CATEGO,ACV.ACV_GRUPO,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC,MBR.MBR_ITEM,MBR.MBR_PDV,MBR.MBR_EMISSA,MBR.MBR_MOTIVO,MBR_ESTACA %"
Else	
   cQryGroup:= "% SAU.AU_CODGRUP,SAU.AU_DESCRI,MBR.MBR_FILIAL,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC,MBR.MBR_ITEM,MBR.MBR_PDV,MBR.MBR_EMISSA,MBR.MBR_MOTIVO,MBR.MBR_ESTACA %"
Endif	

If lGestao .AND. lACVComp  		// Se a tabela ACV for compartilhada aceito a filial corrente
	cFilACV := "% ACV.ACV_FILIAL = '" + xFilial("ACV") + "' %"
Else 					   		// Se a tabela ACV for exclusiva comparo as Filiais
	cFilACV := "% ACV.ACV_FILIAL = MBR.MBR_FILIAL %"
EndIf 
cFilMBR := "% ("+LJ7017QryFil(.F.,"MBR")[2]+") %"
	
	DbSelectArea("ACV")
	DbSetOrder(1) //ACV_FILIAL+ACV_CATEGO+ACV_GRUPO+ACV_CODPRO
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MakeSqlExpr("LJ7017")

	oReport:Section(1):BeginQuery()	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializa a secao 1ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If lCatProd
		BEGIN REPORT QUERY oSection1
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณQuery da secao 1ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			BeginSql alias cAlias1
	
				 SELECT DISTINCT %exp:cQryGroup%
				 FROM %table:MBR% MBR 
				 LEFT JOIN %table:ACV% ACV on ACV.ACV_CODPRO  = MBR.MBR_PROD
				 INNER JOIN %table:SAU%  SAU ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = MBR.MBR_FILIAL 
	  			 WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	%table:ACU% ACU WHERE  ACU_CODPAI >= %exp:mv_par11% AND ACU_CODPAI <= %exp:mv_par12% AND ACU.%notDel%)
                    AND %exp:cFilMBR%
					AND %exp:cFilACV%
					AND ACV.ACV_GRUPO >= %exp:mv_par13% AND ACV.ACV_GRUPO <= %exp:mv_par14%
					AND MBR_PROD >= %exp:mv_par15% AND MBR_PROD <= %exp:mv_par16%  
					AND MBR_PDV >= %exp:mv_par07% AND MBR_PDV <= %exp:mv_par08%
					AND MBR_MOTIVO >= %exp:mv_par19% AND MBR_MOTIVO <= %exp:mv_par20%
					AND MBR_ESTACA >= %exp:mv_par05% AND MBR_ESTACA <= %exp:mv_par06%
					AND MBR_EMISSA >= %exp:DToS(mv_par09)% AND MBR_EMISSA <= %exp:DToS(mv_par10)% 
					AND ACV.%notDel%
					AND MBR.%notDel%
	   			GROUP BY %exp:cQryGroup%
		EndSql
	
		END REPORT QUERY oSection1
    Else
		BEGIN REPORT QUERY oSection1

			BeginSql alias cAlias1
		
				 SELECT DISTINCT %exp:cQryGroup%
				 FROM %table:MBR% MBR
 				 INNER JOIN %table:SAU%  SAU ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = MBR.MBR_FILIAL 
					WHERE %exp:cFilMBR%
					AND MBR_PROD >= %exp:mv_par15% AND MBR_PROD <= %exp:mv_par16% 
					AND MBR_PDV >= %exp:mv_par07% AND MBR_PDV <= %exp:mv_par08%
					AND MBR_MOTIVO >= %exp:mv_par19% AND MBR_MOTIVO <= %exp:mv_par20%
					AND MBR_ESTACA >= %exp:mv_par05% AND MBR_ESTACA <= %exp:mv_par06%
					AND MBR_EMISSA >= %exp:DToS(mv_par09)% AND MBR_EMISSA <= %exp:DToS(mv_par10)% 
					AND MBR.%notDel%
	   			GROUP BY %Exp:cQryGroup% 
			EndSql
	
		END REPORT QUERY oSection1

    Endif
	
oSection1:Init()
cCompara := cAlias1+"->AU_CODGRUP"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a impressao dos dados, de acordo com o filtro ou queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cAlias1)
While !oReport:Cancel() .And. !(cAlias1)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

	If !Empty(cFiltro) 
		If alltrim(cFiltro) <> alltrim(&(cCompara))      
	   		oSection1:Finish()
			oReport:SkipLine()  
			oReport:PrintText(STR0003+": "+(cAlias1)->AU_CODGRUP+" - "+(cAlias1)->AU_DESCRI,oReport:Row(),025)//"Grupo Filial"
			oReport:SkipLine()
			oReport:FatLine()
			cFiltro := &(cCompara)
			oSection1:Init()   
		Endif	
	Else
		oReport:PrintText(STR0003+": "+(cAlias1)->AU_CODGRUP+" - "+(cAlias1)->AU_DESCRI,oReport:Row(),025) //"Grupo Filial"
		cFiltro := &(cCompara)
	Endif


	dbSelectArea("SB1")
	DbSetOrder(1) //B1_FILIAL+B1_COD
    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->MBR_PROD))
       	oSection1:Cell("cDESC"):SetValue(SB1->B1_DESC)
    Endif

	If lCatProd
		dbSelectArea("ACU")
		DbSetOrder(1) //ACU_FILIAL+ACU_COD
	    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
	       	oSection1:Cell("cACUDESC"):SetValue(ACU->ACU_DESC)
	    Endif
	
		If nOrdem == 0
			If EMPTY((cAlias1)->ACV_GRUPO)
	    		dbSelectArea("SB1")
				DbSetOrder(1) //B1_FILIAL+B1_COD
			    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->MBR_PROD))
			    	dbSelectArea("SBM")
					DbSetOrder(1) //BM_FILIAL+BM_GRUPO
		   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
					oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
				Else
					oSection1:Cell("cBMDESC"):SetValue("")
			    Endif
			Else 
		   		dbSelectArea("SBM")
				DbSetOrder(1) //BM_FILIAL+BM_GRUPO
			    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
				    oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
			    Endif
		 	EndIf
	    Endif     
	    
    Endif
    nPrecoTab := LJ7017Prec((cAlias1)->MBR_PROD)
	oSection1:Cell("cTotal"):SetValue((cAlias1)->MBR_QUANT * nPrecoTab)
	oSection1:PrintLine()
	(cAlias1)->( DbSkip() )
EndDo

oSection1:Finish()
oReport:SkipLine()
oReport:SkipLine()

(cAlias1)->(DbCloseArea())
	
oSection1:Finish()

Return NIL 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70173Prt บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR70171                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR70173Prt( oReport, cAlias1, lCatProd,nOrdem )
Local oSection1	:= oReport:Section(1)	// Objeto da secao 1
Local cFiltro	:= ""                  	// Filtro
Local cQryGroup	:= ""                  	// Query do group by
Local cSelect 	:= ""                 	// Select da Query
Local cCompara 	:= ""                  	// Variavel de Comparacao
Local cFilMBR	:= ""                  	// Filial da query
Local cTit    	:= ""                  	// Titulo
Local nPrecoTab := 0

cSelect  := "% DISTINCT ACV.ACV_CATEGO,ACV.ACV_GRUPO,MBR.MBR_FILIAL,MBR.MBR_PROD,MBR.MBR_QUANT,MBR_DOC,MBR_SERIE,MBR_NUMORC,MBR_ITEM,MBR_PDV,MBR_EMISSA,MBR_MOTIVO,MBR_DOC,MBR_ESTACA %"

If lCatProd
	Do Case
		Case nOrdem == 1 //Grupo de filial
		    cQryGroup:= "% MBR_FILIAL,MBR.MBR_PROD,ACV_GRUPO,ACV_CATEGO,MBR_QUANT,MBR_DOC,MBR_SERIE,MBR_NUMORC,MBR_ITEM,MBR_PDV,MBR_EMISSA,MBR_MOTIVO,MBR_DOC,MBR_ESTACA  %"
		Case nOrdem == 2 //Filial
		    cQryGroup:= "% MBR_FILIAL,MBR.MBR_PROD,ACV_GRUPO,ACV_CATEGO,MBR_QUANT,MBR_DOC,MBR_SERIE,MBR_NUMORC,MBR_ITEM,MBR_PDV,MBR_EMISSA,MBR_MOTIVO,MBR_DOC,MBR_ESTACA %"
	    Case nOrdem == 3 //Motivo
		    cQryGroup:= "% MBR_FILIAL,MBR.MBR_PROD,ACV_GRUPO,ACV_CATEGO,MBR_QUANT,MBR_DOC,MBR_SERIE,MBR_NUMORC,MBR_ITEM,MBR_PDV,MBR_EMISSA,MBR_MOTIVO,MBR_DOC,MBR_ESTACA %"
	    Case nOrdem == 4 //Categoria
		    cQryGroup:= "% MBR_FILIAL,ACV_CATEGO,ACV.ACV_GRUPO,MBR.MBR_PROD,MBR_QUANT,MBR_DOC,MBR_SERIE,MBR_NUMORC,MBR_ITEM,MBR_PDV,MBR_EMISSA,MBR_MOTIVO,MBR_DOC,MBR_ESTACA %"
	    Case nOrdem == 5 //Grupo de produtos
		    cQryGroup:= "% MBR.MBR_FILIAL,ACV_GRUPO,ACV_CATEGO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC,MBR.MBR_ITEM,MBR.MBR_PDV,MBR.MBR_EMISSA,MBR.MBR_MOTIVO,MBR.MBR_ESTACA %"
		    cSelect  := "% DISTINCT MBR.MBR_FILIAL,ACV_GRUPO,ACV_CATEGO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC,MBR.MBR_ITEM,MBR.MBR_PDV,MBR.MBR_EMISSA,MBR.MBR_MOTIVO,MBR.MBR_ESTACA %"
	    Case nOrdem == 6 //Produtos
		    cQryGroup:= "% MBR.MBR_FILIAL,MBR.MBR_PROD,ACV_GRUPO,ACV_CATEGO,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC,MBR.MBR_ITEM,MBR.MBR_PDV,MBR.MBR_EMISSA,MBR.MBR_MOTIVO,MBR.MBR_ESTACA %"
		    cSelect  := "% DISTINCT MBR.MBR_FILIAL,MBR.MBR_PROD,ACV_GRUPO,ACV_CATEGO,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC,MBR.MBR_ITEM,MBR.MBR_PDV,MBR.MBR_EMISSA,MBR.MBR_MOTIVO,MBR.MBR_ESTACA %"
	EndCase    
Else
	Do Case
		Case nOrdem == 1 //Grupo de filial
		    cQryGroup:= "% MBR_FILIAL,MBR_PROD,MBR_QUANT,MBR_DOC,MBR_SERIE,MBR_NUMORC,MBR_DOC,MBR_ITEM,MBR_PDV,MBR_EMISSA,MBR_MOTIVO,MBR_DOC,MBR_ESTACA %"
		Case nOrdem == 2 //Filial
		    cQryGroup:= "% MBR_FILIAL,MBR_PROD,MBR_QUANT,MBR_DOC,MBR_SERIE,MBR_NUMORC,MBR_DOC,MBR_ITEM,MBR_PDV,MBR_EMISSA,MBR_MOTIVO,MBR_DOC,MBR_ESTACA %"
	    Case nOrdem == 3 //Motivo
		    cQryGroup:= "% MBR_FILIAL,MBR_MOTIVO,MBR_PROD,MBR_QUANT,MBR_DOC,MBR_SERIE,MBR_NUMORC,MBR_DOC,MBR_ITEM,MBR_PDV,MBR_EMISSA,MBR_DOC,MBR_ESTACA %"
	    Case nOrdem == 6 //Produtos
   		    cSelect  := "% DISTINCT MBR.MBR_FILIAL,MBR.MBR_PROD,MBR.MBR_QUANT,MBR_DOC,MBR_SERIE,MBR_NUMORC,MBR_ITEM,MBR_PDV,MBR_EMISSA,MBR_MOTIVO,MBR_DOC,MBR_ESTACA %"
		    cQryGroup:= "% MBR_FILIAL,MBR_PROD,MBR_QUANT,MBR_DOC,MBR_SERIE,MBR_NUMORC,MBR_DOC,MBR_ITEM,MBR_PDV,MBR_EMISSA,MBR_MOTIVO,MBR_DOC,MBR_ESTACA %"
	EndCase    
Endif

If lGestao .AND. lACVComp  		// Se a tabela ACV for compartilhada aceito a filial corrente
	cFilACV := "% ACV.ACV_FILIAL = '" + xFilial("ACV") + "' %"
Else 					   		// Se a tabela ACV for exclusiva comparo as Filiais
	cFilACV := "% ACV.ACV_FILIAL = MBR.MBR_FILIAL %"
EndIf 
cFilMBR := "% ("+LJ7017QryFil(.F.,"MBR")[2]+") %"

	DbSelectArea("MBR")
	DbSetOrder(1) //MBR_FILIAL+MBR_CODIGO+MBR_NUMORC+MBR_DOC+MBR_SERIE+MBR_PROD+MBR_ITEM
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MakeSqlExpr("LJ7017")

	oReport:Section(1):BeginQuery()	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializa a secao 1ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lCatProd
		BEGIN REPORT QUERY oSection1
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณQuery da secao 1ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			BeginSql alias cAlias1
	
				 SELECT %exp:cSelect% 
				 FROM %table:MBR% MBR 
				 LEFT JOIN %table:ACV% ACV on ACV.ACV_CODPRO  = MBR.MBR_PROD
					WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	%table:ACU% ACU WHERE  ACU_CODPAI >= %exp:mv_par11% AND ACU_CODPAI <= %exp:mv_par12% AND ACU.%notDel%)
                    AND %exp:cFilMBR%
					AND %exp:cFilACV%
					AND ACV.ACV_GRUPO >= %exp:mv_par13% AND ACV.ACV_GRUPO <= %exp:mv_par14%
					AND MBR_PROD >= %exp:mv_par15% AND MBR_PROD <= %exp:mv_par16%  
					AND MBR_PDV >= %exp:mv_par07% AND MBR_PDV <= %exp:mv_par08%
					AND MBR_MOTIVO >= %exp:mv_par19% AND MBR_MOTIVO <= %exp:mv_par20%
					AND MBR_ESTACA >= %exp:mv_par05% AND MBR_ESTACA <= %exp:mv_par06%
					AND MBR_EMISSA >= %exp:DToS(mv_par09)% AND MBR_EMISSA <= %exp:DToS(mv_par10)% 
					AND ACV.%notDel%
					AND MBR.%notDel%
	   			GROUP BY %Exp:cQryGroup% 
		EndSql
	
		END REPORT QUERY oSection1
    Else
		BEGIN REPORT QUERY oSection1

			BeginSql alias cAlias1
		
				 SELECT DISTINCT MBR.MBR_FILIAL,MBR.MBR_PROD,MBR.MBR_QUANT,MBR_DOC,MBR_SERIE,MBR_NUMORC,MBR_ITEM,MBR_PDV,MBR_EMISSA,MBR_MOTIVO 
				 FROM %table:MBR% MBR
					WHERE %exp:cFilMBR%
					AND MBR_PROD >= %exp:mv_par15% AND MBR_PROD <= %exp:mv_par16%
					AND MBR_PDV >= %exp:mv_par07% AND MBR_PDV <= %exp:mv_par08%
					AND MBR_MOTIVO >= %exp:mv_par19% AND MBR_MOTIVO <= %exp:mv_par20%
					AND MBR_ESTACA >= %exp:mv_par05% AND MBR_ESTACA <= %exp:mv_par06%
					AND MBR_EMISSA >= %exp:DToS(mv_par09)% AND MBR_EMISSA <= %exp:DToS(mv_par10)% 
					AND MBR.%notDel%
	   			GROUP BY %Exp:cQryGroup% 
			EndSql
	
		END REPORT QUERY oSection1

    Endif
	oSection1:Init()

Do Case
	Case nOrdem == 1 //Grupo de filial
	    cCompara := cAlias1+"->MBR_FILIAL"
	Case nOrdem == 2 //Filial
	    cCompara := cAlias1+"->MBR_FILIAL"
    Case nOrdem == 3 //Motivo
	    cCompara := cAlias1+"->MBR_FILIAL+"+cAlias1+"->MBR_MOTIVO"
    Case nOrdem == 4 //Categoria
	    cCompara := cAlias1+"->MBR_FILIAL+"+cAlias1+"->ACV_CATEGO"
    Case nOrdem == 5 //Grupo
	    cCompara := cAlias1+"->MBR_FILIAL+"+cAlias1+"->ACV_GRUPO"
    Case nOrdem == 6 //Produtos
	    cCompara := cAlias1+"->MBR_FILIAL+"+cAlias1+"->MBR_PROD"
EndCase    

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a impressao dos dados, de acordo com o filtro ou queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cAlias1)
While !oReport:Cancel() .And. !(cAlias1)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

	If !Empty(cFiltro) 
		If alltrim(cFiltro) <> alltrim(&(cCompara))      
            
			If nOrdem == 2 //Filial
			    cTit  := STR0004+": " + (cAlias1)->D1_FILIAL //"Filial"
		    Endif
		    
		    If lCatProd
			    If nOrdem == 4 //Categoria de produtos
			   		dbSelectArea("ACU")
					DbSetOrder(1) //ACU_FILIAL+ACU_COD
				    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
					    cTit  := STR0066+": " +(cAlias1)->ACV_CATEGO+" - "+ACU->ACU_DESC //"Categoria de Produtos"
				    Endif
			    Endif
			    If nOrdem == 5 //Grupo de produtos
			    	If EMPTY((cAlias1)->ACV_GRUPO)
			    		dbSelectArea("SB1")
						DbSetOrder(1) //B1_FILIAL+B1_COD
					    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->MBR_PROD))
					    	dbSelectArea("SBM")
							DbSetOrder(1) //BM_FILIAL+BM_GRUPO
				   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
							cTit  := STR0067+": " +SB1->B1_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
						Else
							cTit  := STR0067+": "
					    Endif
					Else 
				   		dbSelectArea("SBM")
						DbSetOrder(1) //BM_FILIAL+BM_GRUPO
					    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
						    cTit  := STR0067+": " +(cAlias1)->ACV_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
					    Endif
				 	EndIf
			    Endif
		    Endif
		    
		    If nOrdem == 6 //Produtos
		    	dbSelectArea("SB1")
				DbSetOrder(1) //B1_FILIAL+B1_COD
			    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->MBR_PROD))
		   		    cTit  := STR0006+": " +(cAlias1)->MBR_PROD+" - "+SB1->B1_DESC //"Produto"
			    Endif
		    Endif
		    
		    oSection1:Finish()
			oReport:SkipLine()
			oReport:PrintText(cTit,oReport:Row(),025)
			oReport:SkipLine()
			oReport:FatLine()
			cFiltro := &(cCompara)
			oSection1:Init()
			    			
		Endif	
	Else
		If nOrdem == 2 //Filial
		    cTit  := STR0004+": " + (cAlias1)->MBR_FILIAL //"Filial"
	    Endif
	    
	    If nOrdem == 3 //Motivo
		    dbSelectArea("MBQ")
			DbSetOrder(1) //MBQ_FILIAL+MBQ_CODVEP
		    If MBQ->(DbSeek(xFilial("MBQ")+(cAlias1)->MBR_MOTIVO))
			    cTit  := STR0024+": " + (cAlias1)->MBR_MOTIVO+" - "+MBQ->MBQ_DSCVEP //"Motivo"
			Else
			    cTit  := STR0024+": " + (cAlias1)->MBR_MOTIVO //"Motivo"
		    Endif
	    Endif
	    
	    If lCatProd
		    If nOrdem == 4 //Categoria de produtos
		   		dbSelectArea("ACU")
				DbSetOrder(1) //ACU_FILIAL+ACU_COD
			    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
				    cTit  := STR0066+": " +(cAlias1)->ACV_CATEGO+" - "+ACU->ACU_DESC //"Categoria de Produtos"
			    Endif
		    Endif
		    If nOrdem == 5 //Grupo de produtos
		   		If EMPTY((cAlias1)->ACV_GRUPO)
		    		dbSelectArea("SB1")
					DbSetOrder(1) //B1_FILIAL+B1_COD
				    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->MBR_PROD))
				    	dbSelectArea("SBM")
						DbSetOrder(1) //BM_FILIAL+BM_GRUPO
			   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
						cTit  := STR0067+": " +SB1->B1_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
					Else
						cTit  := STR0067+": "
				    Endif
				Else 
			   		dbSelectArea("SBM")
					DbSetOrder(1) //BM_FILIAL+BM_GRUPO
				    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
					    cTit  := STR0067+": " +(cAlias1)->ACV_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
				    Endif
			 	EndIf
		    Endif
	    Endif
	    
	    If nOrdem == 6 //Produtos
	    	dbSelectArea("SB1")
			DbSetOrder(1) //B1_FILIAL+B1_COD
		    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->MBR_PROD))
	   		    cTit  := STR0006+": " +(cAlias1)->MBR_PROD+" - "+SB1->B1_DESC //"Produto"
		    Endif
		Endif    			

		oReport:PrintText(cTit,oReport:Row(),025)

		cFiltro := &(cCompara)
	Endif
	   
	If lCatProd
		If nOrdem <> 4 //Categoria
			dbSelectArea("ACU")
			DbSetOrder(1) //ACU_FILIAL+ACU_COD
		    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
		       	oSection1:Cell("cACUDESC"):SetValue(ACU->ACU_DESC)
		    Endif
		Endif
	  	If nOrdem <> 5 //Grupo de Produtos
			If EMPTY((cAlias1)->ACV_GRUPO)
		    		dbSelectArea("SB1")
				DbSetOrder(1) //B1_FILIAL+B1_COD
			    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->MBR_PROD))
			    	dbSelectArea("SBM")
					DbSetOrder(1) //BM_FILIAL+BM_GRUPO
		   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
					oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
				Else
					oSection1:Cell("cBMDESC"):SetValue("")
			    Endif
			Else 
		   		dbSelectArea("SBM")
				DbSetOrder(1) //BM_FILIAL+BM_GRUPO
			    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
				    oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
			    Endif
		 	EndIf  
	    EndIf
	Endif
	
	If nOrdem <> 6 //Produtos
		dbSelectArea("SB1")
		DbSetOrder(1) //B1_FILIAL+B1_COD
	    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->MBR_PROD))
	       	oSection1:Cell("cDESC"):SetValue(SB1->B1_DESC)
	    Endif
    Endif     
    nPrecoTab := LJ7017Prec((cAlias1)->MBR_PROD)
	oSection1:Cell("cTotal"):SetValue((cAlias1)->MBR_QUANT * nPrecoTab)
	oSection1:PrintLine()
	(cAlias1)->( DbSkip() )
EndDo

oSection1:Finish()
(cAlias1)->(DbCloseArea())


Return NIL 

//-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-Prevencao de Perdas\Estoque\Produtos com diverg๊ncia de inventแrio-=-=-=--=-=-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณ LJR70174 ณ Autor ณ TOTVS               ณ Data ณ 24/07/2013 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณPrevencao de Perdas\Produtos com diverg๊ncia de inventแrio  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณRelatorio Personalizavel									  ณฑฑ
ฑฑศออออออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LJR70174(lCatProd,cTiulo,nOrdem,aGPFilial)
Local oReport 	:= NIL				// Objeto para geracao do relatorio
Local aArea 	:= GetArea() 		// Salva a area

Default aGPFilial := {} 			// Grupo de Filiais

Pergunte("LJ7017",.F.)//O pergunte deve estar desabilitado 

oReport := LJR70174Def(lCatProd,cTiulo,nOrdem,aGPFilial)
oReport:PrintDialog()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a areaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea( aArea )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70174Def บAutor  ณTOTVS             บ Data ณ  24/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao das celulas que irao compor o relatorio           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR100                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR70174Def(lCatProd,cTitulo,nOrdem,aGPFilial)
Local oReport	:= NIL									// Objeto do relatorio
Local oSection1	:= NIL									// Objeto da secao 1
Local cAlias1	:= GetNextAlias()						// Pega o proximo Alias Disponivel
Local oTotaliz	:= NIL									// Objeto totalizador 
Local oBreak	:= NIL									// Objeto de Quebra

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera a tela com os dados para a confirma็ใo da geracao do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If !Empty(aGPFilial)
	oReport := TReport():New("LOJR70174",STR0001+" "+cTitulo,"",{|oReport| LJR701740Prt(oReport, cAlias1,lCatProd,nOrdem,aGPFilial )},STR0002 )//Relat๓rio Analitico##"Prevencao de Perdas"
Else
	oReport := TReport():New("LOJR70174",STR0001+" "+cTitulo,"",{|oReport| LJR70174Prt(oReport, cAlias1,lCatProd,nOrdem )},STR0002 )//Relat๓rio Analitico##"Prevencao de Perdas"
Endif	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine a secao1 do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1 := TRSection():New( oReport,"",{ "SB7", "SD2", "ACV", "ACU"} )	
oSection1:SetHeaderBreak(.T.)		//Indica se cabecalho da secao sera impresso em cada quebra 
oSection1:SetHeaderPage(.T.)		//Indica que cabecalho da secao sera impresso no topo da pagina

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine as celulas que irao aparecer na secao1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOrdem <> 2
	TRCell():New(oSection1,"B7_FILIAL"	,"SB7",STR0004 ) //"Filial"
Endif
TRCell():New(oSection1,"B7_DATA"	,"SB7",STR0028) //"Data"
If nOrdem <> 5
	TRCell():New(oSection1,"B7_COD"		,"SB7",STR0005 ) 	//"Cod.Produto"
	TRCell():New(oSection1,"cDESC"		,"",STR0006,,30) 	//"Produto"
Endif
If nOrdem <> 6
	TRCell():New(oSection1,"B7_LOCAL"	,"SB7",STR0068 ) //"Armazem"
Endif
If lCatProd
	If nOrdem <> 3
		TRCell():New(oSection1,"ACV_CATEGO"	,"ACV",STR0007 ) //"Cod.Categ."
		TRCell():New(oSection1,"cACUDESC"  	,"",STR0008,,30) //"Categoria"
	Endif
	
	If nOrdem <> 4
		TRCell():New(oSection1,"ACV_GRUPO"	,"ACV",STR0009 ) //"Cod.Grupo"
		TRCell():New(oSection1,"cBMDESC"	,"",STR0010,,30) //"Grupo"
	Endif	
Endif
TRCell():New(oSection1,"B7_DOC"		,"SB7",STR0063 ) 	//"Documento"

TRCell():New(oSection1,"cQtde"		,"SB7",STR0011,"@E 999,999.99" ) 		//"Qtde"
TRCell():New(oSection1,"B1_CUSTD"	,"SB1",STR0020,"@E 999,999,999.99",20 ) 	//"Preco"
TRCell():New(oSection1,"cTotal"	    ,"SB7",STR0014,"@E 999,999,999.99",20 ) 	//"Total"

oBreak := TRBreak():New(oSection1,oSection1:Cell("cQtde")	,STR0013,.F.) //"Totalizador"

oTotaliz  := TRFunction():new(oSection1:Cell("cQtde") ,,"SUM" ,,STR0019   ,"@E 999,999,999.99") //"Quantidade"
oTotaliz  := TRFunction():new(oSection1:Cell("cTotal"),,"SUM" ,,STR0014   ,"@E 999,999,999.99") //"Total" 

Return oReport


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR701740Prt บAutor  ณTOTVS              บ Data ณ  01/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑบ          ณProdutos com divergencia de inventario - GP Filial            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR70171                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR701740Prt( oReport, cAlias1,lCatProd,nOrdem )
Local oSection1	:= oReport:Section(1)	// Objeto da secao 1
Local cQryGroup	:= ""                  	// Query do group by
Local nY 		:= 1					// Contador
Local cFilSB7  	:= ""                  	// Filial da query
Local cFiltro	:= ""                  	// Filtro
Local cCompara 	:= ""                  	// Variavel de Comparacao
Local aSaldo	:= {}					// Saldo em Estoque
Local nDifInv	:= 0					// Diferen็a de Iventแrio

If lCatProd
   cQryGroup:= "% SAU.AU_CODGRUP,SAU.AU_DESCRI,SB7.B7_FILIAL,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,ACV.ACV_CATEGO,ACV.ACV_GRUPO,SB1.B1_CUSTD %"
Else	
   cQryGroup:= "% SAU.AU_CODGRUP,SAU.AU_DESCRI,SB7.B7_FILIAL,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD %"
Endif	

If lGestao .AND. lACVComp  		// Se a tabela ACV for compartilhada aceito a filial corrente
	cFilACV := "% ACV.ACV_FILIAL = '" + xFilial("ACV") + "' %"
Else 					   		// Se a tabela ACV for exclusiva comparo as Filiais
	cFilACV := "% ACV.ACV_FILIAL = SB7.B7_FILIAL %"
EndIf 
cFilSB7 := "% ("+LJ7017QryFil(.F.,"SB7")[2]+") %"

	DbSelectArea("SB7")
	DbSetOrder(1) //B7_FILIAL+DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE+B7_CONTAGE
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MakeSqlExpr("LJ7017")

	oReport:Section(1):BeginQuery()	
    
	If lCatProd
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializa a secao 1ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		BEGIN REPORT QUERY oSection1
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณQuery da secao 1ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			BeginSql alias cAlias1
						  
					 SELECT DISTINCT %Exp:cQryGroup%
					 FROM 	%table:SB1% SB1, %table:SB7% SB7 
					 LEFT JOIN 	%table:ACV% ACV ON ACV.ACV_CODPRO  = SB7.B7_COD 
			         INNER JOIN %table:SAU%  SAU ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SB7.B7_FILIAL
					 WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	%table:ACU% ACU WHERE  ACU_CODPAI >= %exp:mv_par11% AND ACU_CODPAI <= %exp:mv_par12% AND ACU.%notDel% )
						AND %exp:cFilSB7%
						AND %exp:cFilACV%
						AND ACV.ACV_GRUPO >= %exp:mv_par13%
						AND ACV.ACV_GRUPO <= %exp:mv_par14%
						AND B7_FILIAL = B1_FILIAL 
						AND B7_COD = B1_COD
						AND B7_LOCAL = B1_LOCPAD  
						AND B7_STATUS = '1'
						AND B7_DATA >= %exp:DToS(mv_par09)%
						AND B7_DATA <= %exp:DToS(mv_par10)%
						AND B7_COD >= %exp:mv_par15%
						AND B7_COD <= %exp:mv_par16%
						AND B7_LOCAL >= %exp:mv_par17%
						AND B7_LOCAL <= %exp:mv_par18%
						AND ACV.%notDel%
						AND SB1.%notDel%
						AND SB7.%notDel%
  		     
	 	  		GROUP BY %Exp:cQryGroup%          
				  
		    EndSql
		
		END REPORT QUERY oSection1
	Else
		BEGIN REPORT QUERY oSection1
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณQuery da secao 1ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			BeginSql alias cAlias1
						  
					 SELECT DISTINCT %Exp:cQryGroup%
					 FROM 	%table:SB1% SB1, %table:SB7% SB7 
			         INNER JOIN %table:SAU%  SAU ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SB7.B7_FILIAL
					 WHERE %exp:cFilSB7%
			   	       	 AND B7_FILIAL = B1_FILIAL  
						 AND B7_COD = B1_COD
						 AND B7_LOCAL = B1_LOCPAD
						 AND B7_STATUS = '1'
					     AND B7_DATA >= %exp:DToS(mv_par09)%
					     AND B7_DATA <= %exp:DToS(mv_par10)%
					     AND B7_COD >= %exp:mv_par15%
		                 AND B7_COD <= %exp:mv_par16%
						 AND B7_LOCAL >= %exp:mv_par17%
				         AND B7_LOCAL <= %exp:mv_par18%
						 AND SB1.%notDel%
		     		     AND SB7.%notDel%
	     		     
	 	  		GROUP BY %Exp:cQryGroup%
				  
		    EndSql
		
		END REPORT QUERY oSection1	
	Endif

oSection1:Init()

cCompara := cAlias1+"->AU_CODGRUP"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a impressao dos dados, de acordo com o filtro ou queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cAlias1)
While !oReport:Cancel() .And. !(cAlias1)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

    If !Empty(cFiltro) 
		If alltrim(cFiltro) <> alltrim(&(cCompara))      
	   		oSection1:Finish()
			oReport:SkipLine()  
			oReport:PrintText(STR0003+": "+(cAlias1)->AU_CODGRUP+" - "+(cAlias1)->AU_DESCRI,oReport:Row(),025) //"Grupo Filial"
			oReport:SkipLine()
			oReport:FatLine()
			cFiltro := &(cCompara)
			oSection1:Init()   
		Endif	
	Else
		oReport:PrintText(STR0003+": "+(cAlias1)->AU_CODGRUP+" - "+(cAlias1)->AU_DESCRI,oReport:Row(),025) //"Grupo Filial"
		cFiltro := &(cCompara)
	Endif
 	
	dbSelectArea("SB1")
	DbSetOrder(1) //B1_FILIAL+B1_COD
    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->B7_COD))
       	oSection1:Cell("cDESC"):SetValue(SB1->B1_DESC)
    Endif

	If lCatProd
		dbSelectArea("ACU")
		DbSetOrder(1) //ACU_FILIAL+ACU_COD
	    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
	       	oSection1:Cell("cACUDESC"):SetValue(ACU->ACU_DESC)
	    Endif
	
		If EMPTY((cAlias1)->ACV_GRUPO)
    		dbSelectArea("SB1")
			DbSetOrder(1) //B1_FILIAL+B1_COD
		    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->B7_COD))
		    	dbSelectArea("SBM")
				DbSetOrder(1) //BM_FILIAL+BM_GRUPO
	   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
				oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
			Else
				oSection1:Cell("cBMDESC"):SetValue("")
		    Endif
		Else 
	   		dbSelectArea("SBM")
			DbSetOrder(1) //BM_FILIAL+BM_GRUPO
		    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
			    oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
		    Endif
	 	EndIf
	
	Endif
	
	aSaldo  := CalcEst((cAlias1)->B7_COD,(cAlias1)->B7_LOCAL,(cAlias1)->B7_DATA)
	nDifInv := Round(NoRound(aSaldo[1],3),2) - (cAlias1)->B7_QUANT
	
	oSection1:Cell("cQtde"):SetValue(nDifInv)
	oSection1:Cell("cTotal"):SetValue(nDifInv * (cAlias1)->B1_CUSTD)		
	oSection1:PrintLine()
	(cAlias1)->( DbSkip() )
EndDo

oSection1:Finish()
oReport:SkipLine()
oReport:SkipLine()

(cAlias1)->(DbCloseArea())

oSection1:Finish()

Return NIL 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70174Prt บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR70174                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR70174Prt( oReport, cAlias1, lCatProd,nOrdem )
Local oSection1	:= oReport:Section(1)	// Objeto da secao 1
Local cFiltro	:= ""                  	// Filtro
Local cQryGroup	:= ""                  	// Query do group by
Local cCompara 	:= ""                  	// Variavel de Comparacao
Local cFilSB7	:= ""                  	// Filial da query
Local cTit    	:= ""                  	// Titulo
Local cSelect 	:= ""                 	// Select da Query
Local aSaldo	:= {}					// Saldo em Estoque
Local nDifInv	:= 0					// Diferen็a de Iventแrio

If lGestao .AND. lACVComp  		// Se a tabela ACV for compartilhada aceito a filial corrente
	cFilACV := "% ACV.ACV_FILIAL = '" + xFilial("ACV") + "' %"
Else 					   		// Se a tabela ACV for exclusiva comparo as Filiais
	cFilACV := "% ACV.ACV_FILIAL = SB7.B7_FILIAL %"
EndIf 
cFilSB7 := "% ("+LJ7017QryFil(.F.,"SB7")[2]+") %"

If lCatProd
	Do Case
		Case nOrdem == 1 //Grupo de filial
		    cQryGroup:= "% SB7.B7_FILIAL,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,ACV.ACV_CATEGO,ACV.ACV_GRUPO,SB1.B1_CUSTD %"
		Case nOrdem == 2 //Filial
		    cQryGroup:= "% SB7.B7_FILIAL,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,ACV.ACV_CATEGO,ACV.ACV_GRUPO,SB1.B1_CUSTD %"
	    Case nOrdem == 3 //Categoria de produtos
		    cQryGroup:= "% SB7.B7_FILIAL,ACV.ACV_CATEGO,ACV.ACV_GRUPO,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD %"						    
	    Case nOrdem == 4 //Grupo de produtos
		    cQryGroup:= "% SB7.B7_FILIAL,ACV.ACV_GRUPO,ACV.ACV_CATEGO,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD %"
	    Case nOrdem == 5 //Produtos
		    cQryGroup:= "% SB7.B7_FILIAL,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_DATA,SB7.B7_QUANT,SB7.B7_DOC,ACV.ACV_CATEGO,ACV.ACV_GRUPO,SB1.B1_CUSTD %"		                   
	    Case nOrdem == 6 //Armazem                                                                                       
	       cQryGroup:= "% SB7.B7_FILIAL,SB7.B7_LOCAL,SB7.B7_COD,SB7.B7_DATA,SB7.B7_QUANT,SB7.B7_DOC,ACV.ACV_CATEGO,ACV.ACV_GRUPO,SB1.B1_CUSTD %"
	EndCase    
Else
	Do Case
		Case nOrdem == 1 //Grupo de filial
		    cQryGroup:= "% SB7.B7_FILIAL,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD %"
		Case nOrdem == 2 //Filial
		    cQryGroup:= "% SB7.B7_FILIAL,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD %"
	    Case nOrdem == 5 //Produtos
		    cQryGroup:= "% SB7.B7_FILIAL,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_DATA,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD %"
	    Case nOrdem == 6 //Armazem                                                                                       
	       	cQryGroup:= "% SB7.B7_FILIAL,SB7.B7_LOCAL,SB7.B7_COD,SB7.B7_DATA,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD %"
	EndCase    
Endif	

DbSelectArea("SB7")
DbSetOrder(1) //B7_FILIAL+DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE+B7_CONTAGE
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
MakeSqlExpr("LJ7017")

oReport:Section(1):BeginQuery()	

If lCatProd
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa a secao 1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	BEGIN REPORT QUERY oSection1

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณQuery da secao 1ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		BeginSql alias cAlias1
					  
				 SELECT DISTINCT %Exp:cQryGroup%
				 FROM 	%table:SB1% SB1, %table:SB7% SB7 
				 LEFT JOIN %table:ACV% ACV ON ACV.ACV_CODPRO  = SB7.B7_COD
				 WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	%table:ACU% ACU WHERE  ACU_CODPAI >= %exp:mv_par11% AND ACU_CODPAI <= %exp:mv_par12% AND ACU.%notDel% )
					AND %exp:cFilSB7%
					AND %exp:cFilACV%
					AND ACV.ACV_GRUPO >= %exp:mv_par13%
					AND ACV.ACV_GRUPO <= %exp:mv_par14%
					AND B7_FILIAL = B1_FILIAL
					AND B7_COD = B1_COD
					AND B7_LOCAL = B1_LOCPAD
					AND B7_STATUS = '1'
					AND B7_DATA >= %exp:DToS(mv_par09)%
					AND B7_DATA <= %exp:DToS(mv_par10)%
					AND B7_COD >= %exp:mv_par15%
					AND B7_COD <= %exp:mv_par16%
					AND B7_LOCAL >= %exp:mv_par17%
					AND B7_LOCAL <= %exp:mv_par18%
					AND ACV.%notDel%
					AND SB1.%notDel%
					AND SB7.%notDel%  		     
				 GROUP BY %Exp:cQryGroup%
			  
	    EndSql
	
	END REPORT QUERY oSection1
Else
	BEGIN REPORT QUERY oSection1

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณQuery da secao 1ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		BeginSql alias cAlias1
					  
				 SELECT DISTINCT %Exp:cQryGroup%
				 FROM 	%table:SB1% SB1, %table:SB7% SB7 
				 WHERE %exp:cFilSB7%
		   	       	 AND B7_FILIAL = B1_FILIAL 
					 AND B7_COD = B1_COD
					 AND B7_LOCAL = B1_LOCPAD
					 AND B7_STATUS = '1'
				     AND B7_DATA >= %exp:DToS(mv_par09)%
				     AND B7_DATA <= %exp:DToS(mv_par10)%
				     AND B7_COD >= %exp:mv_par15%
	                 AND B7_COD <= %exp:mv_par16%
					 AND B7_LOCAL >= %exp:mv_par17%
			         AND B7_LOCAL <= %exp:mv_par18%
					 AND SB1.%notDel%
	     		     AND SB7.%notDel%
     		     
				 GROUP BY %Exp:cQryGroup%
			  
	    EndSql
	
	END REPORT QUERY oSection1	
Endif

oSection1:Init()

Do Case
	Case nOrdem == 1 //Grupo de filial
	    cCompara := cAlias1+"->B7_FILIAL"
	Case nOrdem == 2 //Filial
	    cCompara := cAlias1+"->B7_FILIAL"
    Case nOrdem == 3 //Categoria de produtos
	    cCompara := cAlias1+"->B7_FILIAL+"+cAlias1+"->ACV_CATEGO"
    Case nOrdem == 4 //Grupo de produtos
	    cCompara := cAlias1+"->B7_FILIAL+"+cAlias1+"->ACV_GRUPO"
    Case nOrdem == 5 //Produtos
	    cCompara := cAlias1+"->B7_FILIAL+"+cAlias1+"->B7_COD"
    Case nOrdem == 6 //Armazem                                
	    cCompara := cAlias1+"->B7_FILIAL+"+cAlias1+"->B7_LOCAL"
EndCase    

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a impressao dos dados, de acordo com o filtro ou queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cAlias1)
While !oReport:Cancel() .And. !(cAlias1)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

	If !Empty(cFiltro) 
		If alltrim(cFiltro) <> alltrim(&(cCompara))      
			
			If nOrdem == 2 //Filial
			    cTit  := STR0004+": " + (cAlias1)->B7_FILIAL //"Filial"
		    Endif
		    
		    If lCatProd
			    If nOrdem == 3 //Categoria de produtos
			   		dbSelectArea("ACU")
					DbSetOrder(1) //ACU_FILIAL+ACU_COD
				    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
					    cTit  := STR0066+": " +(cAlias1)->ACV_CATEGO+" - "+ACU->ACU_DESC //"Categoria de Produtos"
				    Endif
			    Endif
			    If nOrdem == 4 //Grupo de produtos
				    If EMPTY((cAlias1)->ACV_GRUPO)
			    		dbSelectArea("SB1")
						DbSetOrder(1) //B1_FILIAL+B1_COD
					    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->B7_COD))
					    	dbSelectArea("SBM")
							DbSetOrder(1) //BM_FILIAL+BM_GRUPO
				   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
							cTit  := STR0067+": " +SB1->B1_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
						Else
							cTit  := STR0067+": "
					    Endif
					Else 
				   		dbSelectArea("SBM")
						DbSetOrder(1) //BM_FILIAL+BM_GRUPO
					    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
						    cTit  := STR0067+": " +(cAlias1)->ACV_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
					    Endif
				 	EndIf
			    Endif
		    Endif
		    
		    If nOrdem == 5 //Produtos
		    	dbSelectArea("SB1")
				DbSetOrder(1) //B1_FILIAL+B1_COD
			    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->B7_COD))
		   		    cTit  := STR0006+": " +alltrim((cAlias1)->B7_COD)+" - "+SB1->B1_DESC //"Produto"
			    Endif
		    Endif    			
            
		    If nOrdem == 6 //Armazem 
		        cTit  := STR0068+": " +(cAlias1)->B7_LOCAL //"Armazem"
		    Endif    			
            
			oSection1:Finish()
			oReport:SkipLine()
			oReport:PrintText(cTit,oReport:Row(),025)
			oReport:SkipLine()
			oReport:FatLine()
			cFiltro := &(cCompara)
			oSection1:Init()
			
		Endif	
	Else
		If nOrdem == 2 //Filial
		    cTit  := STR0004+": " + (cAlias1)->B7_FILIAL //"Filial"
	    Endif
	    
	    If lCatProd
		    If nOrdem == 3 //Categoria de produtos
		   		dbSelectArea("ACU")
				DbSetOrder(1) //ACU_FILIAL+ACU_COD
			    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
				    cTit  := STR0066+": " +(cAlias1)->ACV_CATEGO+" - "+ACU->ACU_DESC //"Categoria de Produtos"
			    Endif
		    Endif
		    If nOrdem == 4 //Grupo de produtos
		    	If EMPTY((cAlias1)->ACV_GRUPO)
		    		dbSelectArea("SB1")
					DbSetOrder(1) //B1_FILIAL+B1_COD
				    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->B7_COD))
				    	dbSelectArea("SBM")
						DbSetOrder(1) //BM_FILIAL+BM_GRUPO
			   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
						cTit  := STR0067+": " +SB1->B1_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
					Else
						cTit  := STR0067+": "
				    Endif
				Else 
			   		dbSelectArea("SBM")
					DbSetOrder(1) //BM_FILIAL+BM_GRUPO
				    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
					    cTit  := STR0067+": " +(cAlias1)->ACV_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
				    Endif
			 	EndIf
		    Endif
	    Endif
	    
	    If nOrdem == 5 //Produtos
	    	dbSelectArea("SB1")
			DbSetOrder(1) //B1_FILIAL+B1_COD
		    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->B7_COD))
	   		    cTit  := STR0006+": " +alltrim((cAlias1)->B7_COD)+" - "+SB1->B1_DESC //"Produto"
		    Endif
		Endif
		
	    If nOrdem == 6 //Armazem 
	        cTit  := STR0068+": " +(cAlias1)->B7_LOCAL //"Armazem"
	    Endif    			
		
		oReport:PrintText(cTit,oReport:Row(),025)

		cFiltro := &(cCompara)
	Endif


	If lCatProd
		If nOrdem <> 3 .And. nOrdem <> 5//categoria
			dbSelectArea("ACU")
			DbSetOrder(1) //ACU_FILIAL+ACU_COD
		    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
		       	oSection1:Cell("cACUDESC"):SetValue(ACU->ACU_DESC)
		    Endif
	    Endif
	    
		If nOrdem <> 4 .And. nOrdem <> 5//grupo
			If EMPTY((cAlias1)->ACV_GRUPO)
	    		dbSelectArea("SB1")
				DbSetOrder(1) //B1_FILIAL+B1_COD
			    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->B7_COD))
			    	dbSelectArea("SBM")
					DbSetOrder(1) //BM_FILIAL+BM_GRUPO
		   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
					oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
				Else
					oSection1:Cell("cBMDESC"):SetValue("")
			    Endif
			Else 
		   		dbSelectArea("SBM")
				DbSetOrder(1) //BM_FILIAL+BM_GRUPO
			    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
				    oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
			    Endif
		 	EndIf
		Endif
		
	Endif

	If nOrdem <> 5 //produtos
		dbSelectArea("SB1")
		DbSetOrder(1) //B1_FILIAL+B1_COD
	    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->B7_COD))
	       	oSection1:Cell("cDESC"):SetValue(SB1->B1_DESC)
	    Endif
	Endif
	
	aSaldo  := CalcEst((cAlias1)->B7_COD,(cAlias1)->B7_LOCAL,(cAlias1)->B7_DATA)
	nDifInv := Round(NoRound(aSaldo[1],3),2) - (cAlias1)->B7_QUANT
	
	oSection1:Cell("cQtde"):SetValue(nDifInv)
	oSection1:Cell("cTotal"):SetValue(nDifInv * (cAlias1)->B1_CUSTD)		
	oSection1:PrintLine()
	(cAlias1)->( DbSkip() )
EndDo

oSection1:Finish()
(cAlias1)->(DbCloseArea())

Return NIL 

//-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-Prevencao de Perdas\Estoque\Produtos com maior devolu็ใo\Quebra Operacional-=-=-=--=-=-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณ LJR70175 ณ Autor ณ TOTVS               ณ Data ณ 24/07/2013 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณPrevencao de Perdas\Quebra Operacional                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณRelatorio Personalizavel									  ณฑฑ
ฑฑศออออออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LJR70175(lCatProd,cTitulo,nOrdem,aGPFilial)
Local oReport 	:= NIL				// Objeto para geracao do relatorio
Local aArea 	:= GetArea() 		// Salva a area

Default aGPFilial := {} 			// Grupo de Filiais

Pergunte("LJ7017",.F.)//O pergunte deve estar desabilitado 

oReport := LJR70175Def(lCatProd,cTitulo, nOrdem,aGPFilial)
oReport:PrintDialog()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a areaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea( aArea )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70175Def บAutor  ณTOTVS             บ Data ณ  24/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao das celulas que irao compor o relatorio           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR100                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR70175Def(lCatProd,cTitulo,nOrdem,aGPFilial)
Local oReport	:= NIL									// Objeto do relatorio
Local oSection1	:= NIL									// Objeto da secao 1
Local cAlias1	:= GetNextAlias()						// Pega o proximo Alias Disponivel
Local oTotaliz	:= NIL									// Objeto totalizador
Local oBreak	:= NIL									// Objeto de Quebra

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera a tela com os dados para a confirma็ใo da geracao do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(aGPFilial)
	oReport := TReport():New("LOJR70175",STR0001+" "+ cTitulo,"",{|oReport| LJR701750Prt(oReport, cAlias1, lCatProd,nOrdem,aGPFilial )},STR0002 )//Relat๓rio Analitico##"Prevencao de Perdas"
Else
	oReport := TReport():New("LOJR70175",STR0001+" "+ cTitulo,"",{|oReport| LJR70175Prt(oReport, cAlias1, lCatProd,nOrdem )},STR0002 )//Relat๓rio Analitico##"Prevencao de Perdas"
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine a secao1 do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1 := TRSection():New( oReport,"",{ "MFJ", "ACV"} )	
oSection1:SetHeaderBreak(.T.)		//Indica se cabecalho da secao sera impresso em cada quebra 
oSection1:SetHeaderPage(.T.)		//Indica que cabecalho da secao sera impresso no topo da pagina

oReport:SetLandscape(.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine as celulas que irao aparecer na secao1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOrdem <> 2
	TRCell():New(oSection1,"MFJ_FILIAL"	,"MFJ",STR0004,,9 ) //"Filial"
Endif
If nOrdem <> 5
	TRCell():New(oSection1,"MFJ_PRODUT" ,"MFJ",STR0005 ) //"Cod.Produto"
	TRCell():New(oSection1,"cDESC"      ,"",STR0006,,30) //"Produto"
Endif
If nOrdem <> 8
	TRCell():New(oSection1,"MFJ_CODOCO"	,"MFJ",STR0021 ) //"Cod.Ocorrencia"
	TRCell():New(oSection1,"cCODOCO"	,""   ,STR0022,,30 ) //"Ocorrencia"
Endif
If nOrdem <> 6	
	TRCell():New(oSection1,"MFJ_CODMOT"	,"MFJ",STR0023 ) //"Cod.Motivo"
	TRCell():New(oSection1,"cCODMOT"	,""   ,STR0024,,30 ) //"Motivo"
Endif
If nOrdem <> 7
	TRCell():New(oSection1,"MFJ_CODORI"	,"MFJ",STR0025 ) //"Cod.Origem"
	TRCell():New(oSection1,"cCODORI"	,""   ,STR0026,,30 ) //"Origem"
Endif
If lCatProd
    If nOrdem <>  3
		TRCell():New(oSection1,"ACV_CATEGO"	,"ACV",STR0027 ) //"Cod.Categoria"
		TRCell():New(oSection1,"cACUDESC"	,"",STR0008,,20 ) //"Categoria"
    Endif
    If nOrdem <> 4
		TRCell():New(oSection1,"ACV_GRUPO"	,"ACV",STR0009 ) //"Cod.Grupo"
		TRCell():New(oSection1,"cBMDESC"	,"",STR0010,,20 ) //"Grupo"
	Endif	
Endif

TRCell():New(oSection1,"MFJ_DATA"	,"MFJ",STR0028,"@D",12) //"Data"

TRCell():New(oSection1,"MFJ_QUANT"  ,"MFJ",STR0011) 						//"Qtde."
TRCell():New(oSection1,"MFJ_VUNIT"  ,"MFJ",STR0012,"@E 9,999,999.99",20 ) 	//"Valor"
TRCell():New(oSection1,"cTotal"     ,""   ,STR0014,"@E 9,999,999.99",20 ) 	//"Total"

oBreak := TRBreak():New(oSection1,oSection1:Cell("MFJ_QUANT"),STR0013,.F.) //"Totalizador"
oBreak := TRBreak():New(oSection1,oSection1:Cell("MFJ_VUNIT"),STR0012,.F.) //"Valor"

oTotaliz := TRFunction():new(oSection1:Cell("MFJ_QUANT"),,"SUM",,STR0014,"@E 999,999,999.99")   //"Total"
oTotaliz := TRFunction():new(oSection1:Cell("MFJ_VUNIT"),,"SUM",,"Valores unitarios"  ,"@E 999,999,999.99")
oTotaliz := TRFunction():new(oSection1:Cell("cTotal")   ,,"SUM",,STR0014 ,"@E 999,999,999.99", ) //"Total" 

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70170Prt บAutor  ณTOTVS               บ Data ณ  01/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑบ          ณQuebra Operacional - GP Filial                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR70171                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR701750Prt( oReport, cAlias1,lCatProd,nOrdem )
Local oSection1	:= oReport:Section(1)	// Objeto da secao 1
Local cQryGroup	:= ""                  	// Query do group by
Local nY 		:= 1					// Contador
Local cFilMFJ 	:= ""                  	// Filial da query
Local cFiltro	:= ""                  	// Filtro
Local cCompara 	:= ""                  	// Variavel de Comparacao

If lGestao .AND. lACVComp  		// Se a tabela ACV for compartilhada aceito a filial corrente
	cFilACV := "% ACV.ACV_FILIAL = '" + xFilial("ACV") + "' %"
Else 					   		// Se a tabela ACV for exclusiva comparo as Filiais
	cFilACV := "% ACV.ACV_FILIAL = MFJ.MFJ_FILIAL %"
EndIf 
cFilMFJ := "% ("+LJ7017QryFil(.F.,"MFJ")[2]+") %"

If lCatProd
   cQryGroup:= "% SAU.AU_CODGRUP,SAU.AU_DESCRI,MFJ_FILIAL,MFJ_CODIGO,MFJ_PRODUT,MFJ_CODOCO,MFJ_CODMOT,MFJ_CODORI,ACV_CATEGO,ACV_GRUPO,MFJ_QUANT,MFJ_DATA,MFJ_VUNIT %"
Else	
   cQryGroup:= "% SAU.AU_CODGRUP,SAU.AU_DESCRI,MFJ_FILIAL,MFJ_CODIGO,MFJ_PRODUT,MFJ_CODOCO,MFJ_CODMOT,MFJ_CODORI,MFJ_QUANT,MFJ_DATA,MFJ_VUNIT %"
Endif	

	DbSelectArea("SLX")
	DbSetOrder(1) //LX_FILIAL+LX_PDV+LX_CUPOM+LX_SERIE+LX_ITEM+LX_HORA
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MakeSqlExpr("LJ7017")

	oReport:Section(1):BeginQuery()	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializa a secao 1ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 	If lCatProd
		BEGIN REPORT QUERY oSection1
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณQuery da secao 1ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			BeginSql alias cAlias1
	
				 SELECT DISTINCT SAU.AU_CODGRUP,SAU.AU_DESCRI,MFJ_FILIAL,MFJ_CODIGO,MFJ_PRODUT,MFJ.MFJ_CODOCO,MFJ_CODMOT,MFJ_CODORI,ACV_CATEGO,ACV_GRUPO,MFJ_QUANT,MFJ_DATA,MFJ_VUNIT	
			     FROM 	%table:MFJ% MFJ  LEFT JOIN 	%table:ACV% ACV on ACV.ACV_CODPRO  = MFJ.MFJ_PRODUT
		         INNER JOIN %table:SAU%  SAU ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = MFJ.MFJ_FILIAL
	    	     WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	%table:ACU% ACU WHERE  ACU_CODPAI >= %exp:mv_par11% AND ACU_CODPAI <= %exp:mv_par12% AND ACU.%notDel% )
					AND %exp:cFilMFJ%
					AND %exp:cFilACV%
					AND ACV.ACV_GRUPO >= %exp:mv_par13%
					AND ACV.ACV_GRUPO <= %exp:mv_par14%				
					AND MFJ_PRODUT >= %exp:mv_par15%
					AND MFJ_PRODUT <= %exp:mv_par16%
					AND MFJ_QUANT <> '0'  
					AND MFJ_CODMOT BETWEEN %exp:mv_par19% and %exp:mv_par20%
					AND MFJ_CODORI BETWEEN %exp:mv_par21% and %exp:mv_par22%
					AND MFJ_CODOCO BETWEEN %exp:mv_par23% and %exp:mv_par24%
					AND MFJ_DATA >= %exp:DToS(mv_par09)%
					AND MFJ_DATA <= %exp:DToS(mv_par10)%
					AND ACV.%notDel%
					AND MFJ.%notDel%             
	
	   			GROUP BY %Exp:cQryGroup% 

		    EndSql
		
		END REPORT QUERY oSection1
	Else
		BEGIN REPORT QUERY oSection1
		
			BeginSql alias cAlias1
	
				 SELECT DISTINCT SAU.AU_CODGRUP, SAU.AU_DESCRI,MFJ_FILIAL,MFJ_CODIGO, MFJ_PRODUT, MFJ_CODOCO, MFJ_CODMOT, MFJ_CODORI, MFJ_QUANT, MFJ_DATA, MFJ_VUNIT	
			     FROM %table:MFJ% MFJ  
		         INNER JOIN %table:SAU%  SAU ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = MFJ.MFJ_FILIAL	
	    	     WHERE %exp:cFilMFJ%
					 AND MFJ_PRODUT >= %exp:mv_par15%
		             AND MFJ_PRODUT <= %exp:mv_par16%
		     		 AND MFJ_QUANT <> '0'  
		     		 AND MFJ_CODMOT BETWEEN %exp:mv_par19% and %exp:mv_par20%
		     		 AND MFJ_CODORI BETWEEN %exp:mv_par21% and %exp:mv_par22%
	                 AND MFJ_CODOCO BETWEEN %exp:mv_par23% and %exp:mv_par24%
	                 AND MFJ_DATA >= %exp:DToS(mv_par09)%
	                 AND MFJ_DATA <= %exp:DToS(mv_par10)%
		     		 AND MFJ.%notDel%    

	 	  		GROUP BY %Exp:cQryGroup%          
	
	    	EndSql
	
		END REPORT QUERY oSection1
	
    Endif

oSection1:Init()
cCompara := cAlias1+"->AU_CODGRUP"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a impressao dos dados, de acordo com o filtro ou queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cAlias1)
While !oReport:Cancel() .And. !(cAlias1)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

    If !Empty(cFiltro) 
		If alltrim(cFiltro) <> alltrim(&(cCompara))      
	   		oSection1:Finish()
			oReport:SkipLine()  
			oReport:PrintText(STR0003+": "+(cAlias1)->AU_CODGRUP+" - "+(cAlias1)->AU_DESCRI,oReport:Row(),025) //"Grupo Filial"
			oReport:SkipLine()
			oReport:FatLine()
			cFiltro := &(cCompara)
			oSection1:Init()   
		Endif	
	Else
		oReport:PrintText(STR0003+": "+(cAlias1)->AU_CODGRUP+" - "+(cAlias1)->AU_DESCRI,oReport:Row(),025) //"Grupo Filial"
		cFiltro := &(cCompara)
	Endif

	dbSelectArea("SB1")
	DbSetOrder(1) //B1_FILIAL+B1_COD
    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->MFJ_PRODUT))
       	oSection1:Cell("cDESC"):SetValue(SB1->B1_DESC)
    Endif

	dbSelectArea("MFN")
	DbSetOrder(1) //MFN_FILIAL+MFN_CODIGO
    If MFN->(DbSeek(xFilial("MFN")+(cAlias1)->MFJ_CODOCO))
       	oSection1:Cell("cCODOCO"):SetValue(MFN->MFN_DESCR)
    Endif

	dbSelectArea("MFM")
	DbSetOrder(1) //MFM_FILIAL+MFM_CODIGO
    If MFM->(DbSeek(xFilial("MFM")+(cAlias1)->MFJ_CODMOT))
       	oSection1:Cell("cCODMOT"):SetValue(MFM->MFM_DESCR)
    Endif

	dbSelectArea("MFK")
	DbSetOrder(1) //MFK_FILIAL+MFK_CODIGO
    If MFK->(DbSeek(xFilial("MFK")+(cAlias1)->MFJ_PRODUT))
       	oSection1:Cell("cCODORI"):SetValue(MFK->MFK_DESCR)
    Endif

	If lCatProd
		dbSelectArea("ACU")
		DbSetOrder(1) //ACU_FILIAL+ACU_COD
	    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
	       	oSection1:Cell("cACUDESC"):SetValue(ACU->ACU_DESC)
	    Endif
	
		If EMPTY((cAlias1)->ACV_GRUPO)
    		dbSelectArea("SB1")
			DbSetOrder(1) //B1_FILIAL+B1_COD
		    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->MFJ_PRODUT))
		    	dbSelectArea("SBM")
				DbSetOrder(1) //BM_FILIAL+BM_GRUPO
	   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
				oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
			Else
				oSection1:Cell("cBMDESC"):SetValue("")
		    Endif
		Else 
	   		dbSelectArea("SBM")
			DbSetOrder(1) //BM_FILIAL+BM_GRUPO
		    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
			    oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
		    Endif
	 	EndIf
	Endif
	oSection1:Cell("cTotal"):SetValue(val((cAlias1)->MFJ_QUANT) * (cAlias1)->MFJ_VUNIT)		
	oSection1:PrintLine()
	(cAlias1)->( DbSkip() )
EndDo

oSection1:Finish()
oReport:SkipLine()
oReport:SkipLine()

(cAlias1)->(DbCloseArea())
	
oSection1:Finish()

Return NIL 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70175Prt บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR70175                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR70175Prt( oReport, cAlias1, lCatProd, nOrdem )
Local oSection1	:= oReport:Section(1)	// Objeto da secao 1
Local cFiltro	:= ""                  	// Filtro
Local cQryGroup	:= ""                  	// Query do group by
Local cCompara 	:= ""                  	// Variavel de Comparacao
Local cFilMFJ	:= ""                  	// Filial da query
Local cTit    	:= ""                  	// Titulo
Local cSelect 	:= ""                 	// Select da Query

If lGestao .AND. lACVComp  		// Se a tabela ACV for compartilhada aceito a filial corrente
	cFilACV := "% ACV.ACV_FILIAL = '" + xFilial("ACV") + "' %"
Else 					   		// Se a tabela ACV for exclusiva comparo as Filiais
	cFilACV := "% ACV.ACV_FILIAL = MFJ.MFJ_FILIAL %"
EndIf 
cFilMFJ := "% ("+LJ7017QryFil(.F.,"MFJ")[2]+") %"

	DbSelectArea("SB7")
	DbSetOrder(1) //B7_FILIAL+DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE+B7_CONTAGE
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MakeSqlExpr("LJ7017")

	oReport:Section(1):BeginQuery()	

	If lCatProd
		Do Case
			Case nOrdem == 1 //Grupo de filial
			    cQryGroup:= "% MFJ_FILIAL,MFJ_PRODUT,MFJ_CODORI,ACV_CATEGO,ACV_GRUPO,MFJ.MFJ_CODOCO,MFJ_CODMOT,MFJ_QUANT,MFJ_DATA,MFJ_CODIGO,MFJ_VUNIT %"
			Case nOrdem == 2 //Filial
			    cQryGroup:= "% MFJ_FILIAL,MFJ_PRODUT,MFJ_CODORI,ACV_CATEGO,ACV_GRUPO,MFJ.MFJ_CODOCO,MFJ_CODMOT,MFJ_QUANT,MFJ_DATA,MFJ_CODIGO,MFJ_VUNIT %"
		    Case nOrdem == 3 //Categoria de produtos
			    cQryGroup:= "% MFJ_FILIAL,ACV_CATEGO,MFJ_CODORI,ACV_GRUPO,MFJ_PRODUT,MFJ.MFJ_CODOCO,MFJ_CODMOT,MFJ_QUANT,MFJ_DATA,MFJ_CODIGO,MFJ_VUNIT %"
		    Case nOrdem == 4 //Grupo de produtos
			    cQryGroup:= "% MFJ_FILIAL,ACV_GRUPO,MFJ_CODORI,ACV_CATEGO,MFJ_PRODUT,MFJ.MFJ_CODOCO,MFJ_CODMOT,MFJ_QUANT,MFJ_DATA,MFJ_CODIGO,MFJ_VUNIT %"
		    Case nOrdem == 5 //Produtos
			    cQryGroup:= "% MFJ_FILIAL,MFJ_PRODUT,MFJ_CODORI,MFJ.MFJ_CODOCO,MFJ_CODMOT,MFJ_QUANT,MFJ_DATA,MFJ_CODIGO,MFJ_VUNIT,ACV_CATEGO %"
		    Case nOrdem == 6 //Motivo
			    cQryGroup:= "% MFJ_FILIAL,MFJ_CODMOT,MFJ_CODORI,ACV_CATEGO,ACV_GRUPO,MFJ_PRODUT,MFJ_CODOCO,MFJ_CODMOT,MFJ_QUANT,MFJ_DATA,MFJ_CODIGO,MFJ_VUNIT %"
		    Case nOrdem == 7 //Origem
			    cQryGroup:= "% MFJ_FILIAL,MFJ_CODORI,ACV_CATEGO,ACV_GRUPO,MFJ_PRODUT,MFJ.MFJ_CODOCO,MFJ_CODMOT,MFJ_QUANT,MFJ_DATA,MFJ_CODIGO,MFJ_VUNIT %"
	   	    Case nOrdem == 8 //Ocorrencia
	   	        cQryGroup:= "% MFJ_FILIAL,MFJ_CODOCO,MFJ_CODORI,ACV_CATEGO,ACV_GRUPO,MFJ_PRODUT,MFJ_CODMOT,MFJ_QUANT,MFJ_DATA,MFJ_CODIGO,MFJ_VUNIT %"
		EndCase    
	Else
		Do Case
		Case nOrdem == 1 //Grupo de filial
		    cQryGroup:= "% MFJ_FILIAL,MFJ_PRODUT, MFJ_CODORI, MFJ.MFJ_CODOCO, MFJ_CODMOT,MFJ_QUANT, MFJ_DATA,MFJ_CODIGO, MFJ_VUNIT %"
		Case nOrdem == 2 //Filial
		    cQryGroup:= "% MFJ_FILIAL,MFJ_PRODUT, MFJ_CODORI, MFJ.MFJ_CODOCO, MFJ_CODMOT,MFJ_QUANT, MFJ_DATA,MFJ_CODIGO, MFJ_VUNIT %"
	    Case nOrdem == 5 //Produtos
		    cQryGroup:= "% MFJ_FILIAL,MFJ_PRODUT, MFJ_CODORI, MFJ.MFJ_CODOCO, MFJ_CODMOT, MFJ_QUANT, MFJ_DATA,MFJ_CODIGO, MFJ_VUNIT %"
	    Case nOrdem == 6 //Motivo
		    cQryGroup:= "% MFJ_FILIAL,MFJ_CODMOT, MFJ_CODORI, MFJ_PRODUT, MFJ_CODOCO, MFJ_CODMOT,MFJ_QUANT, MFJ_DATA,MFJ_CODIGO, MFJ_VUNIT %"
	    Case nOrdem == 7 //Origem
		    cQryGroup:= "% MFJ_FILIAL,MFJ_CODORI, MFJ_PRODUT, MFJ.MFJ_CODOCO, MFJ_CODMOT,MFJ_QUANT, MFJ_DATA,MFJ_CODIGO, MFJ_VUNIT %"
   	    Case nOrdem == 8 //Ocorrencia
   	        cQryGroup:= "% MFJ_FILIAL,MFJ_CODOCO, MFJ_CODORI, MFJ_PRODUT,  MFJ_CODMOT,MFJ_QUANT, MFJ_DATA,MFJ_CODIGO, MFJ_VUNIT %"
		EndCase    
	
	Endif	
	
	If lCatProd
		If nOrdem <> 5
			cSelect  := "% MFJ.MFJ_FILIAL,MFJ_CODIGO,MFJ_PRODUT,MFJ.MFJ_CODOCO,MFJ_CODMOT,MFJ_CODORI,ACV_CATEGO,ACV_GRUPO,MFJ_QUANT,MFJ_DATA,MFJ_VUNIT %"
	    Else
			cSelect  := "% MFJ.MFJ_FILIAL,MFJ_CODIGO,MFJ_PRODUT,MFJ.MFJ_CODOCO,MFJ_CODMOT,MFJ_CODORI,MFJ_QUANT,MFJ_DATA,MFJ_VUNIT,ACV_CATEGO %"
		Endif
	Else
		cSelect  := "% MFJ.MFJ_FILIAL,MFJ_CODIGO, MFJ_PRODUT, MFJ.MFJ_CODOCO, MFJ_CODMOT, MFJ_CODORI,  MFJ_QUANT, MFJ_DATA, MFJ_VUNIT %"
	Endif
			
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializa a secao 1ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lCatProd
		BEGIN REPORT QUERY oSection1
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณQuery da secao 1ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			BeginSql alias cAlias1
	
				 SELECT DISTINCT %exp:cSelect% 
	
			     FROM 	%table:MFJ% MFJ  LEFT JOIN 	%table:ACV% ACV on ACV.ACV_CODPRO  = MFJ.MFJ_PRODUT
	
	    	     WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	%table:ACU% ACU WHERE  ACU_CODPAI >= %exp:mv_par11% AND ACU_CODPAI <= %exp:mv_par12% AND ACU.%notDel% )
					AND %exp:cFilMFJ%
					AND %exp:cFilACV%
					AND ACV.ACV_GRUPO >= %exp:mv_par13%
					AND ACV.ACV_GRUPO <= %exp:mv_par14%				
					AND MFJ_PRODUT >= %exp:mv_par15%
					AND MFJ_PRODUT <= %exp:mv_par16%
					AND MFJ_QUANT <> '0'  
					AND MFJ_CODMOT BETWEEN %exp:mv_par19% and %exp:mv_par20%
					AND MFJ_CODORI BETWEEN %exp:mv_par21% and %exp:mv_par22%
					AND MFJ_CODOCO BETWEEN %exp:mv_par23% and %exp:mv_par24%
					AND MFJ_DATA >= %exp:DToS(mv_par09)%
					AND MFJ_DATA <= %exp:DToS(mv_par10)%
					AND ACV.%notDel%
					AND MFJ.%notDel%             
	
	   			GROUP BY %Exp:cQryGroup% 

		    EndSql
		
		END REPORT QUERY oSection1
	Else
		BEGIN REPORT QUERY oSection1
		
			BeginSql alias cAlias1
	
				 SELECT DISTINCT MFJ.MFJ_FILIAL,MFJ_CODIGO, MFJ_PRODUT, MFJ.MFJ_CODOCO, MFJ_CODMOT, MFJ_CODORI, MFJ_QUANT, MFJ_DATA, MFJ_VUNIT
	
			     FROM %table:MFJ% MFJ  
	
	    	     WHERE %exp:cFilMFJ%
					 AND MFJ_PRODUT >= %exp:mv_par15%
		             AND MFJ_PRODUT <= %exp:mv_par16%
		     		 AND MFJ_QUANT <> '0'  
		     		 AND MFJ_CODMOT BETWEEN %exp:mv_par19% and %exp:mv_par20%
		     		 AND MFJ_CODORI BETWEEN %exp:mv_par21% and %exp:mv_par22%
	                 AND MFJ_CODOCO BETWEEN %exp:mv_par23% and %exp:mv_par24%
	                 AND MFJ_DATA >= %exp:DToS(mv_par09)%
	                 AND MFJ_DATA <= %exp:DToS(mv_par10)%
		     		 AND MFJ.%notDel%    

	 	  		GROUP BY %Exp:cQryGroup%          
	
	    	EndSql
	
		END REPORT QUERY oSection1
	
	Endif

	oSection1:Init()     

//o Case abaixo nao pode juntar com o acima porque ้ preciso saber o valor do cAlias1 apos execucao da query
Do Case
	Case nOrdem == 1 //Grupo de filial
	    cCompara := cAlias1+"->MFJ_FILIAL+"+cAlias1+"->MFJ_CODORI"
	Case nOrdem == 2 //Filial
	    cCompara := cAlias1+"->MFJ_FILIAL
    Case nOrdem == 3 //Categoria de produtos
	    cCompara := cAlias1+"->MFJ_FILIAL+"+cAlias1+"->ACV_CATEGO"
    Case nOrdem == 4 //Grupo de produtos
	    cCompara := cAlias1+"->MFJ_FILIAL+"+cAlias1+"->ACV_GRUPO"
    Case nOrdem == 5 //Produtos
	    cCompara := cAlias1+"->MFJ_FILIAL+"+cAlias1+"->MFJ_PRODUT"
    Case nOrdem == 6 //Motivo
	    cCompara := cAlias1+"->MFJ_FILIAL+"+cAlias1+"->MFJ_CODMOT"
    Case nOrdem == 7 //Origem
	    cCompara := cAlias1+"->MFJ_FILIAL+"+cAlias1+"->MFJ_CODORI"
    Case nOrdem == 8 //Ocorrencia
	    cCompara := cAlias1+"->MFJ_FILIAL+"+cAlias1+"->MFJ_CODOCO"
EndCase    


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a impressao dos dados, de acordo com o filtro ou queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cAlias1)
While !oReport:Cancel() .And. !(cAlias1)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

	If !Empty(cFiltro) 
		If alltrim(cFiltro) <> alltrim(&(cCompara))      
	   		If nOrdem == 2 //Filial
			    cTit  := STR0004+": " + (cAlias1)->MFJ_FILIAL //"Filial"
		    Endif
            	    
		    If lCatProd
			    If nOrdem == 3 //Categoria de produtos
			   		dbSelectArea("ACU")
					DbSetOrder(1) //ACU_FILIAL+ACU_COD
				    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
					    cTit  := STR0066+": " +(cAlias1)->ACV_CATEGO+" - "+ACU->ACU_DESC //"Categoria de Produtos"
				    Endif
			    Endif
			    If nOrdem == 4 //Grupo de produtos
			    	If EMPTY((cAlias1)->ACV_GRUPO)
			    		dbSelectArea("SB1")
						DbSetOrder(1) //B1_FILIAL+B1_COD
					    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->MFJ_PRODUT))
					    	dbSelectArea("SBM")
							DbSetOrder(1) //BM_FILIAL+BM_GRUPO
				   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
							cTit  := STR0067+": " +SB1->B1_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
						Else
							cTit  := STR0067+": "
					    Endif
					Else 
				   		dbSelectArea("SBM")
						DbSetOrder(1) //BM_FILIAL+BM_GRUPO
					    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
						    cTit  := STR0067+": " +(cAlias1)->ACV_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
					    Endif
				 	EndIf
			    Endif
		    Endif
		    		    
		    If nOrdem == 5 //Produtos
			   	dbSelectArea("SB1")
				DbSetOrder(1) //B1_FILIAL+B1_COD
			    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->MFJ_PRODUT))
		   		    cTit  := STR0006+": " +(cAlias1)->MFJ_PRODUT+" - "+SB1->B1_DESC //"Produto"
			    Endif
	  		Endif
		    
		    If nOrdem == 6 //Motivo
				dbSelectArea("MFM")
				DbSetOrder(1) //MFM_FILIAL+MFM_CODIGO
			    If MFM->(DbSeek(xFilial("MFM")+(cAlias1)->MFJ_CODMOT))
			       	cTit  := STR0024+": " +(cAlias1)->MFJ_CODMOT+" - "+MFM->MFM_DESCR //"Motivo"
			    Endif
		  	Endif
		    
		    If nOrdem == 7 //Origem
				dbSelectArea("MFK")
				DbSetOrder(1) //MFK_FILIAL+MFK_CODIGO
			    If MFK->(DbSeek(xFilial("MFK")+(cAlias1)->MFJ_PRODUT))
					cTit  := STR0026+": " +(cAlias1)->MFJ_PRODUT+" - "+MFK->MFK_DESCR //"Origem"
			    Endif
		  	Endif
	   	    
	   	    If nOrdem == 8 //Ocorrencia
				dbSelectArea("MFN")
				DbSetOrder(1) //MFN_FILIAL+MFN_CODIGO
			    If MFN->(DbSeek(xFilial("MFN")+(cAlias1)->MFJ_CODOCO))
			       	cTit  := STR0022+": " +(cAlias1)->MFJ_CODOCO+" - "+MFN->MFN_DESCR //"Ocorrencia"
			    Endif	    		
			Endif
			
			oSection1:Finish()
			oReport:SkipLine()
			oReport:SkipLine()
			oReport:PrintText(cTit,oReport:Row(),025)
			oReport:SkipLine()
			oReport:FatLine()
			cFiltro := &(cCompara)
			oSection1:Init()   
		Endif	
	Else
		If nOrdem == 2 //Filial
		    cTit  := STR0004+": " + (cAlias1)->MFJ_FILIAL //"Filial"
	    Endif
            	    
	    If lCatProd
		    If nOrdem == 3 //Categoria de produtos
		   		dbSelectArea("ACU")
				DbSetOrder(1) //ACU_FILIAL+ACU_COD
			    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
				    cTit  := STR0066+": " +(cAlias1)->ACV_CATEGO+" - "+ACU->ACU_DESC //"Categoria de Produtos"
			    Endif
		    Endif
		    If nOrdem == 4 //Grupo de produtos
		    	If EMPTY((cAlias1)->ACV_GRUPO)
		    		dbSelectArea("SB1")
					DbSetOrder(1) //B1_FILIAL+B1_COD
				    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->MFJ_PRODUT))
				    	dbSelectArea("SBM")
						DbSetOrder(1) //BM_FILIAL+BM_GRUPO
			   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
						cTit  := STR0067+": " +SB1->B1_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
					Else
						cTit  := STR0067+": "
				    Endif
				Else 
			   		dbSelectArea("SBM")
					DbSetOrder(1) //BM_FILIAL+BM_GRUPO
				    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
					    cTit  := STR0067+": " +(cAlias1)->ACV_GRUPO+" - "+SBM->BM_DESC //"Grupo de Produtos"
				    Endif
			 	EndIf
		    Endif
	    Endif
	    		    
	    If nOrdem == 5 //Produtos
		   	dbSelectArea("SB1")
			DbSetOrder(1) //B1_FILIAL+B1_COD
		    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->MFJ_PRODUT))
	   		    cTit  := STR0006+": " +(cAlias1)->MFJ_PRODUT+" - "+SB1->B1_DESC //"Produto"
		    Endif
  		Endif
	    
	    If nOrdem == 6 //Motivo
			dbSelectArea("MFM")
			DbSetOrder(1) //MFM_FILIAL+MFM_CODIGO
		    If MFM->(DbSeek(xFilial("MFM")+(cAlias1)->MFJ_CODMOT))
		       	cTit  := STR0024+": " +(cAlias1)->MFJ_CODMOT+" - "+MFM->MFM_DESCR //"Motivo"
		    Endif
	  	Endif
	    
	    If nOrdem == 7 //Origem
			dbSelectArea("MFK")
			DbSetOrder(1) //MFK_FILIAL+MFK_CODIGO
		    If MFK->(DbSeek(xFilial("MFK")+(cAlias1)->MFJ_PRODUT))
				cTit  := STR0026+": " +(cAlias1)->MFJ_PRODUT+" - "+MFK->MFK_DESCR //"Origem"
		    Endif
	  	Endif
   	    
   	    If nOrdem == 8 //Ocorrencia
			dbSelectArea("MFN")
			DbSetOrder(1) //MFN_FILIAL+MFN_CODIGO
		    If MFN->(DbSeek(xFilial("MFN")+(cAlias1)->MFJ_CODOCO))
		       	cTit  := STR0022+": " +(cAlias1)->MFJ_CODOCO+" - "+MFN->MFN_DESCR //"Ocorrencia"
		    Endif	    		
		Endif
		
		oReport:PrintText(cTit,oReport:Row(),025)
		cFiltro := &(cCompara)
	Endif
	
	If lCatProd
		If nOrdem <> 3 .And. nOrdem <> 5
			dbSelectArea("ACU")
			DbSetOrder(1) //ACU_FILIAL+ACU_COD
		    If ACU->(DbSeek(xFilial("ACU")+(cAlias1)->ACV_CATEGO))
		       	oSection1:Cell("cACUDESC"):SetValue(ACU->ACU_DESC)
		    Endif
	    Endif
	    
		If nOrdem <>  4 .And. nOrdem <> 5
			If EMPTY((cAlias1)->ACV_GRUPO)
	    		dbSelectArea("SB1")
				DbSetOrder(1) //B1_FILIAL+B1_COD
			    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->MFJ_PRODUT))
			    	dbSelectArea("SBM")
					DbSetOrder(1) //BM_FILIAL+BM_GRUPO
		   		    SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
					oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
				Else
					oSection1:Cell("cBMDESC"):SetValue("")
			    Endif
			Else 
		   		dbSelectArea("SBM")
				DbSetOrder(1) //BM_FILIAL+BM_GRUPO
			    If SBM->(DbSeek(xFilial("SBM")+(cAlias1)->ACV_GRUPO))
				    oSection1:Cell("cBMDESC"):SetValue(SBM->BM_DESC)
			    Endif
		 	EndIf
	    Endif
	Endif

	If nOrdem <> 5
		dbSelectArea("SB1")
		DbSetOrder(1) //B1_FILIAL+B1_COD
	    If SB1->(DbSeek(xFilial("SB1")+(cAlias1)->MFJ_PRODUT))
	       	oSection1:Cell("cDESC"):SetValue(SB1->B1_DESC)
	    Endif
	Endif
	
	If nOrdem <>   6
		dbSelectArea("MFM")
		DbSetOrder(1) //MFM_FILIAL+MFM_CODIGO
	    If MFM->(DbSeek(xFilial("MFM")+(cAlias1)->MFJ_CODMOT))
	       	oSection1:Cell("cCODMOT"):SetValue(MFM->MFM_DESCR)
	    Endif
    Endif

	If nOrdem <>  7
		dbSelectArea("MFK")
		DbSetOrder(1) //MFK_FILIAL+MFK_CODIGO
	    If MFK->(DbSeek(xFilial("MFK")+(cAlias1)->MFJ_PRODUT))
	       	oSection1:Cell("cCODORI"):SetValue(MFK->MFK_DESCR)
	    Endif
    Endif
    
	If nOrdem <>  8
		dbSelectArea("MFN")
		DbSetOrder(1) //MFN_FILIAL+MFN_CODIGO
	    If MFN->(DbSeek(xFilial("MFN")+(cAlias1)->MFJ_CODOCO))
	       	oSection1:Cell("cCODOCO"):SetValue(MFN->MFN_DESCR)
	    Endif
    Endif 
	oSection1:Cell("cTotal"):SetValue(val((cAlias1)->MFJ_QUANT) * (cAlias1)->MFJ_VUNIT)		
	oSection1:PrintLine()
	(cAlias1)->( DbSkip() )
EndDo

oSection1:Finish()

(cAlias1)->(DbCloseArea())

Return NIL
 
//-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-Prevencao de Perdas\Financeira\Quebra Conf.Caixa-=-=-=--=-=-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณ LJR70176 ณ Autor ณ TOTVS               ณ Data ณ 29/07/2013 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณPrevencao de Perdas\Financeira\Quebra Conf.Caixa            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณRelatorio Personalizavel									  ณฑฑ
ฑฑศออออออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LJR70176(cTiulo,nOrdem,aGPFilial)
Local oReport 	:= NIL				// Objeto para geracao do relatorio
Local aArea 	:= GetArea() 		// Salva a area

Default aGPFilial := {} 			// Grupo de Filiais

Pergunte("LJ7017",.F.)//O pergunte deve estar desabilitado 

oReport := LJR70176Def(cTiulo,nOrdem,aGPFilial)
oReport:PrintDialog()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a areaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea( aArea )      

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70176Def บAutor  ณTOTVS             บ Data ณ  29/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao das celulas que irao compor o relatorio           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR100                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR70176Def(cTitulo,nOrdem,aGPFilial)
Local oReport	:= NIL									// Objeto do relatorio
Local oSection1	:= NIL									// Objeto da secao 1
Local cAlias1	:= GetNextAlias()						// Pega o proximo Alias Disponivel
Local oTotaliz	:= NIL									// Objeto totalizador
Local oBreak	:= NIL									// Objeto de Quebra

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera a tela com os dados para a confirma็ใo da geracao do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If !Empty(aGPFilial)
	oReport := TReport():New("LOJR70176",STR0001+""+cTitulo,"",{|oReport| LJR701760Prt(oReport, cAlias1 )},STR0002 )//Relat๓rio Analitico##"Prevencao de Perdas"
Else
	oReport := TReport():New("LOJR70176",STR0001+" "+cTitulo,"",{|oReport| LJR70176Prt(oReport, cAlias1,nOrdem )},STR0002 )//Relat๓rio Analitico##"Prevencao de Perdas"
Endif	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine a secao1 do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1 := TRSection():New( oReport,"",{ "SLW", "SLT", "MBH", "MBI"} )	
oSection1:SetHeaderBreak(.T.)		//Indica se cabecalho da secao sera impresso em cada quebra 
oSection1:SetHeaderPage(.T.)		//Indica que cabecalho da secao sera impresso no topo da pagina

oReport:SetLandscape(.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine as celulas que irao aparecer na secao1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOrdem <> 2 
	TRCell():New(oSection1,"LW_FILIAL"	,"SLW",STR0004) //"Filial"
Endif

TRCell():New(oSection1,"MBI_CODACA" ,"MBI",STR0029) //"Acao"
TRCell():New(oSection1,"cMBIDESCRI" ,""   ,STR0030,,20 ) //"Desc.Acao"
TRCell():New(oSection1,"LW_OPERADO" ,"SLW",STR0031) //"Operador"

If nOrdem <> 3 
	TRCell():New(oSection1,"LW_PDV"	    ,"SLW",STR0018 ) //"PDV"
Endif

TRCell():New(oSection1,"MBH_ESTACA"	,"MBH",STR0032 ) //"Estacao"
TRCell():New(oSection1,"LW_SERIE"	,"SLW",STR0015 ) //"Serie"
TRCell():New(oSection1,"LW_NUMMOV"	,"SLW",STR0033 ) //"Num.Mov"
TRCell():New(oSection1,"MBH_FORMPG"	,"MBH",STR0034 ) //"Pgto."
TRCell():New(oSection1,"cDESC"     	,"",STR0035,,25) //"Forma PGTO"
TRCell():New(oSection1,"LW_DTABERT"	,"SLW",STR0036 ) //"Dt.Abertura"
TRCell():New(oSection1,"LW_HRABERT"	,"SLW",STR0037 ) //"Hr.Abertura" 
TRCell():New(oSection1,"LT_VLRAPU"	,"SLT",STR0072 ) //"Vl.Apurado"
TRCell():New(oSection1,"LT_VLRDIG"	,"SLT",STR0071 ) //"Vl.Digitado"
TRCell():New(oSection1,"VLRDIF"		,"SLT",STR0012,"@E 9,999,999.99" ) //"Valor"

oBreak := TRBreak():New(oSection1,oSection1:Cell("LT_VLRDIG"),"Valor",.F.) //"Totalizador"

If nOrdem <> 3 
	oTotaliz := TRFunction():new(oSection1:Cell("LW_NUMMOV")	,,"COUNT",,"Quant.","@E 999,999,999.99") //"Total"
Else
	oTotaliz := TRFunction():new(oSection1:Cell("MBH_ESTACA")	,,"COUNT",,"Quant.","@E 999,999,999.99") //"Total"
Endif		

oTotaliz  := TRFunction():new(oSection1:Cell("VLRDIF"),,"SUM"  ,,STR0014  ,"@E 999,999,999.99", ) //"Total"

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70170Prt บAutor  ณTOTVS               บ Data ณ  01/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel-GP Filial   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR70171 -Grupo de Filial                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR701760Prt( oReport, cAlias1)
Local oSection1	:= oReport:Section(1)	// Objeto da secao 1
Local cQryGroup	:= ""                  	// Query do group by
Local cFiltro	:= ""                  	// Filtro
Local cCompara 	:= ""                  	// Variavel de Comparacao
Local cFilSLW 	:= ""                  	// Filial da query

cQryGroup:= "% SAU.AU_CODGRUP, SAU.AU_DESCRI,LW_FILIAL, MBI_CODACA,  LW_OPERADO, MBH_FORMPG, LW_PDV, LW_NUMMOV, MBH_ESTACA, LW_DTABERT,LW_DTFECHA,LW_SERIE,LW_HRABERT,LW_HRFECHA,LT_VLRAPU,LT_VLRDIG %"

cFilSLW := "% ("+LJ7017QryFil(.F.,"SLW")[2]+") %"

	DbSelectArea("SLW")
	DbSetOrder(1) //LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_NUMMOV
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MakeSqlExpr("LJ7017")

	oReport:Section(1):BeginQuery()	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializa a secao 1ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	BEGIN REPORT QUERY oSection1

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณQuery da secao 1ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		BeginSql alias cAlias1

	        SELECT SAU.AU_CODGRUP, SAU.AU_DESCRI,LW_FILIAL, MBI_CODACA,  LW_OPERADO, MBH_FORMPG, LW_PDV, LW_NUMMOV, MBH_ESTACA, LW_DTABERT,LW_DTFECHA,LW_SERIE,LW_HRABERT,LW_HRFECHA, LT_VLRAPU,LT_VLRDIG,LT_VLRAPU-LT_VLRDIG VLRDIF
			FROM %table:SLT% SLT, %table:MBH% MBH, %table:MBI% MBI, %table:SLW% SLW
		    INNER JOIN %table:SAU%  SAU ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SLW.LW_FILIAL
		    WHERE %exp:cFilSLW%
			 AND LW_OPERADO >= %exp:mv_par05%
			 AND LW_OPERADO <= %exp:mv_par06%
			 AND LW_DTFECHA >= %exp:DToS(mv_par09)%
			 AND LW_DTFECHA <= %exp:DToS(mv_par10)%
			 AND LT_FILIAL = LW_FILIAL
			 AND LT_DTFECHA = LW_DTFECHA 
			 AND LW_NUMMOV = LT_NUMMOV   
			 AND LW_OPERADO = LT_OPERADO  
			 AND LW_ESTACAO  = LT_ESTACAO 
			 AND LW_PDV = LT_PDV  
			 AND LT_CONFERE = '1' 
			 AND LT_VLRDIG <> 0
			 AND MBH_FILIAL = LW_FILIAL  
			 AND MBH_OPERAD = LW_OPERADO 
			 AND MBH_DATA  = LT_DTFECHA 
			 AND MBH_FORMPG = LT_FORMPG 
			 AND MBH_PDV= LW_PDV 
			 AND MBH_NUMMOV= LW_NUMMOV  
			 AND MBI_FILIAL = MBH_FILIAL 
			 AND MBI_CODACA  = MBH_ACAO 
			 AND MBI.%notDel%
			 AND MBH.%notDel%
			 AND SLW.%notDel%

 	  		GROUP BY %Exp:cQryGroup%          				  
	    EndSql
	
	END REPORT QUERY oSection1

	oSection1:Init()

cCompara := cAlias1+"->AU_CODGRUP"

oSection1:Init()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a impressao dos dados, de acordo com o filtro ou queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cAlias1)
While !oReport:Cancel() .And. !(cAlias1)->(Eof())


	If !Empty(cFiltro) 
		If alltrim(cFiltro) <> alltrim(&(cCompara))      
	   		oSection1:Finish()
			oReport:SkipLine()
			oReport:PrintText(STR0003+": "+(cAlias1)->AU_CODGRUP+" - "+(cAlias1)->AU_DESCRI,oReport:Row(),025) //"Grupo Filial"
			oReport:SkipLine()
			cFiltro := &(cCompara)
			oSection1:Init()   
		Endif	
	Else
		oReport:PrintText(STR0003+": "+(cAlias1)->AU_CODGRUP+" - "+(cAlias1)->AU_DESCRI,oReport:Row(),025) //"Grupo Filial"
		cFiltro := &(cCompara)
	Endif


	dbSelectArea("MBI")
	DbSetOrder(1) //MBI_FILIAL+MBI_CODACA
    If MBI->(DbSeek(xFilial("MBI")+(cAlias1)->MBI_CODACA))
       	oSection1:Cell("cMBIDESCRI"):SetValue(MBI->MBI_DESCRI)
    Endif

	dbSelectArea("SX5")
	DbSetOrder(1) //X5_FILIAL+X5_TABELA+X5_CHAVE
    If SX5->(DbSeek(xFilial("SX5")+"24"+(cAlias1)->MBH_FORMPG))
       	oSection1:Cell("cDESC"):SetValue(SX5->X5_DESCRI)
    Endif
	
	oSection1:Cell("cTotal"):SetValue((cAlias1)->LT_VLRDIG)
	
	oSection1:PrintLine()
	(cAlias1)->( DbSkip() )
EndDo

oSection1:Finish()
oReport:SkipLine()
oReport:SkipLine()

(cAlias1)->(DbCloseArea())

oSection1:Finish()

Return NIL 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70176Prt บAutor  ณTOTVS               บ Data ณ  29/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR70176                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR70176Prt( oReport, cAlias1,nOrdem )
Local oSection1	:= oReport:Section(1)	// Objeto da secao 1
Local cFiltro	:= ""                  	// Filtro
Local cQryGroup	:= ""                  	// Query do group by
Local cCompara 	:= ""                  	// Variavel de Comparacao
Local cFilSLW   := ""                   // Filial da query
Local cTit    	:= ""                  	// Titulo

cFilSLW := "% ("+LJ7017QryFil(.F.,"SLW")[2]+") %"

Do Case
	Case nOrdem == 1 //Grupo de filial
	    cQryGroup:= "% LW_FILIAL, MBI_CODACA,  LW_OPERADO, MBH_FORMPG, LW_PDV, LW_NUMMOV, MBH_ESTACA, LW_DTABERT,LW_DTFECHA,LW_SERIE,LW_HRABERT,LW_HRFECHA,LT_VLRAPU,LT_VLRDIG %"
   	Case nOrdem == 2 //Filial
	    cQryGroup:= "% LW_FILIAL, MBI_CODACA,  LW_OPERADO, MBH_FORMPG, LW_PDV, LW_NUMMOV, MBH_ESTACA, LW_DTABERT,LW_DTFECHA,LW_SERIE,LW_HRABERT,LW_HRFECHA,LT_VLRAPU,LT_VLRDIG %"
    Case nOrdem == 3 //Caixa
	    cQryGroup:= "% LW_FILIAL, LW_PDV, MBH_ESTACA, LW_OPERADO, MBI_CODACA,  MBH_FORMPG, LW_NUMMOV, LW_DTABERT,LW_DTFECHA,LW_SERIE,LW_HRABERT,LW_HRFECHA,LT_VLRAPU,LT_VLRDIG %"
EndCase    

	DbSelectArea("SLW")
	DbSetOrder(1) //LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_NUMMOV
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MakeSqlExpr("LJ7017")

	oReport:Section(1):BeginQuery()	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInicializa a secao 1ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	BEGIN REPORT QUERY oSection1

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณQuery da secao 1ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		BeginSql alias cAlias1

	        SELECT LW_FILIAL, MBI_CODACA,  LW_OPERADO, MBH_FORMPG, LW_PDV, LW_NUMMOV, MBH_ESTACA, LW_DTABERT,LW_DTFECHA,LW_SERIE,LW_HRABERT,LW_HRFECHA,LT_VLRAPU,LT_VLRDIG,LT_VLRAPU-LT_VLRDIG VLRDIF			
			FROM %table:SLW% SLW, %table:SLT% SLT, %table:MBH% MBH, %table:MBI% MBI				
			WHERE %exp:cFilSLW%
			 AND LW_OPERADO >= %exp:mv_par05%
			 AND LW_OPERADO <= %exp:mv_par06%
			 AND LW_DTFECHA >= %exp:DToS(mv_par09)%
			 AND LW_DTFECHA <= %exp:DToS(mv_par10)%
			 AND LT_FILIAL = LW_FILIAL
			 AND LT_DTFECHA = LW_DTFECHA 
			 AND LW_NUMMOV = LT_NUMMOV   
			 AND LW_OPERADO = LT_OPERADO  
			 AND LW_ESTACAO  = LT_ESTACAO 
			 AND LW_PDV = LT_PDV  
			 AND LT_CONFERE = '1' 
			 AND LT_VLRDIG <> 0
			 AND MBH_FILIAL = LW_FILIAL  
			 AND MBH_OPERAD = LW_OPERADO 
			 AND MBH_DATA  = LT_DTFECHA 
			 AND MBH_FORMPG = LT_FORMPG 
			 AND MBH_PDV= LW_PDV 
			 AND MBH_NUMMOV= LW_NUMMOV  
			 AND MBI_FILIAL = MBH_FILIAL 
			 AND MBI_CODACA  = MBH_ACAO 
			 AND MBI.%notDel%
			 AND MBH.%notDel%
			 AND SLW.%notDel%

 	  		GROUP BY %Exp:cQryGroup%          				  
	    EndSql
	
	END REPORT QUERY oSection1

	oSection1:Init()

Do Case
	Case nOrdem == 2 //Filial
	    cCompara := cAlias1+"->LW_FILIAL"
    Case nOrdem == 3 //Caixa
	    cCompara := cAlias1+"->LW_FILIAL+"+cAlias1+"->LW_PDV"
EndCase    


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a impressao dos dados, de acordo com o filtro ou queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cAlias1)
While !oReport:Cancel() .And. !(cAlias1)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

	If !Empty(cFiltro) 
		If alltrim(cFiltro) <> alltrim(&(cCompara))  
			
			If nOrdem == 2 //Filial
			    cTit  := STR0004+": " + (cAlias1)->LW_FILIAL //"Filial"
		    Endif
		    
			If nOrdem == 3 //Caixa
			    cTit  := STR0018+": " + (cAlias1)->LW_PDV //"PDV"
		    Endif
			
			oSection1:Finish()
			oReport:SkipLine()
			oReport:PrintText(cTit,oReport:Row(),025)
			oReport:SkipLine()
			oReport:FatLine()
			cFiltro := &(cCompara)
			oSection1:Init() 
			
		Endif	
	Else
		If nOrdem == 2 //Filial
		    cTit  := STR0004+": " + (cAlias1)->LW_FILIAL //"Filial"
	    Endif
	    
		If nOrdem == 3 //Caixa
		    cTit  := STR0018+": " + (cAlias1)->LW_PDV //"PDV"
	    Endif
		oReport:PrintText(cTit,oReport:Row(),025)
		cFiltro := &(cCompara)
	Endif

	dbSelectArea("MBI")
	DbSetOrder(1) //MBI_FILIAL+MBI_CODACA
    If MBI->(DbSeek(xFilial("MBI")+(cAlias1)->MBI_CODACA))
       	oSection1:Cell("cMBIDESCRI"):SetValue(MBI->MBI_DESCRI)
    Endif

	dbSelectArea("SX5")
	DbSetOrder(1) //X5_FILIAL+X5_TABELA+X5_CHAVE
    If SX5->(DbSeek(xFilial("SX5")+"24"+(cAlias1)->MBH_FORMPG))
       	oSection1:Cell("cDESC"):SetValue(SX5->X5_DESCRI)
    Endif
	
	oSection1:PrintLine()
	(cAlias1)->( DbSkip() )
EndDo

oSection1:Finish()
(cAlias1)->(DbCloseArea())

Return NIL

//-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-Prevencao de Perdas\Financeira\Cheques devolvidos-=-=-=--=-=-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณ LJR70177 ณ Autor ณ TOTVS               ณ Data ณ 29/07/2013 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณPrevencao de Perdas\Financeira\Cheques devolvidos           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณRelatorio Personalizavel									  ณฑฑ
ฑฑศออออออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LJR70177(cTitulo,nOrdem,aGPFilial)
Local oReport 	:= NIL				// Objeto para geracao do relatorio
Local aArea 	:= GetArea() 		// Salva a area

Default aGPFilial := {} 			// Grupo de Filiais

Pergunte("LJ7017",.F.)//O pergunte deve estar desabilitado 

oReport := LJR70177Def(cTitulo,nOrdem,aGPFilial)
oReport:PrintDialog()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a areaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea( aArea )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70177Def บAutor  ณTOTVS             บ Data ณ  29/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao das celulas que irao compor o relatorio           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR100                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR70177Def(cTitulo,nOrdem,aGPFilial)
Local oReport	:= NIL									// Objeto do relatorio
Local oSection1	:= NIL									// Objeto da secao 1
Local cAlias1	:= GetNextAlias()						// Pega o proximo Alias Disponivel

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera a tela com os dados para a confirma็ใo da geracao do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(aGPFilial)
	oReport := TReport():New("LOJR70177",STR0001+" "+cTitulo,"",{|oReport| LJR701770Prt(oReport, cAlias1 )},STR0002 )//Relat๓rio Analitico##"Prevencao de Perdas"
Else
	oReport := TReport():New("LOJR70177",STR0001+" "+cTitulo,"",{|oReport| LJR70177Prt(oReport, cAlias1, nOrdem )},STR0002 )//Relat๓rio Analitico##"Prevencao de Perdas"
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine a secao1 do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                          
oSection1 := TRSection():New( oReport,"",{ "SEF"} )	
oSection1:SetHeaderBreak(.T.)		//Indica se cabecalho da secao sera impresso em cada quebra 
oSection1:SetHeaderPage(.T.)		//Indica que cabecalho da secao sera impresso no topo da pagina

oReport:SetLandscape(.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine as celulas que irao aparecer na secao1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOrdem <> 2 
	TRCell():New(oSection1,"EF_FILIAL"	,"SEF",STR0004 ) //"Filial"
Endif
TRCell():New(oSection1,"EF_SERIE"	,"SEF",STR0015 ) //"Serie"
TRCell():New(oSection1,"EF_NUMNOTA"	,"SEF",STR0041 ) //"Numero da Nota"
TRCell():New(oSection1,"EF_PREFIXO"	,"SEF",STR0042 ) //"Prefixo"
TRCell():New(oSection1,"EF_TITULO"	,"SEF",STR0069 ) //"Titulo"
TRCell():New(oSection1,"EF_CLIENTE"	,"SEF",STR0046 ) //"Cliente"
TRCell():New(oSection1,"EF_LOJA"	,"SEF",STR0040 ) //"Loja"

TRCell():New(oSection1,"EF_BANCO"	,"SEF","Banco" ) //"Loja"
TRCell():New(oSection1,"EF_AGENCIA"	,"SEF","Agencia" ) //"Loja"
TRCell():New(oSection1,"EF_CONTA"	,"SEF","Conta" ) //"Loja"
TRCell():New(oSection1,"EF_NUM"		,"SEF","Numero" ) //"Loja"

TRCell():New(oSection1,"EF_VALOR"	,"SEF",STR0012 ) //"Valor"

TRCell():New(oSection1,"EF_DATA"	,"SEF",STR0028 ) //"Data"
TRCell():New(oSection1,"EF_BENEF"	,"","Beneficiแrio" ) 

oTotaliz := TRFunction():new(oSection1:Cell("EF_NUM"),,"COUNT",,"Quant.","@E 999,999,999.99") 
oTotaliz := TRFunction():new(oSection1:Cell("EF_VALOR"),,"SUM"  ,,"Total" ,"@E 999,999,999.99" ) 

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70170Prt บAutor  ณTOTVS               บ Data ณ  01/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel-GP Filial   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR70171                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR701770Prt( oReport, cAlias1)
Local oSection1	:= oReport:Section(1)	// Objeto da secao 1
Local cQryGroup	:= ""                  	// Query do group by
Local cFiltro	:= ""                  	// Filtro
Local cCompara 	:= ""                  	// Variavel de Comparacao
Local cFilSEF	:= ""                  	// Filial da query
Local cTit    	:= ""                  	// Titulo

cQryGroup:= "% SAU.AU_CODGRUP,SAU.AU_DESCRI,SEF.EF_FILIAL,SEF.EF_PREFIXO,SEF.EF_TITULO,SEF.EF_NUMNOTA,SEF.EF_SERIE,SEF.EF_VALOR,SEF.EF_CLIENTE,SEF.EF_LOJACLI,SEF.EF_DATA,SEF.EF_BENEF,SEF.EF_BANCO,SEF.EF_AGENCIA,SEF.EF_CONTA,SEF.EF_NUM %"
 
cFilSEF := "% ("+LJ7017QryFil(.F.,"SEF")[2]+") %"

	DbSelectArea("SEF")
	DbSetOrder(1) //EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MakeSqlExpr("LJ7017")

	oReport:Section(1):BeginQuery()	
		
		BEGIN REPORT QUERY oSection1
		
			BeginSql alias cAlias1
	   	
 			  SELECT %Exp:cQryGroup% 
              FROM %table:SE1% SE1 , %table:SEF% SEF
	          INNER JOIN %table:SAU%  SAU ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SEF.EF_FILIAL
              WHERE %exp:cFilSEF%
		 	  AND SEF.EF_CHDEVOL <> ' '
		      AND SEF.EF_FILIAL = SE1.E1_FILIAL
              AND SEF.EF_PREFIXO = SE1.E1_PREFIXO
              AND SEF.EF_TITULO = SE1.E1_NUM
              AND SEF.EF_SERIE = SE1.E1_SERIE
              AND SEF.EF_NUMNOTA = SE1.E1_NUMNOTA
              AND SEF.EF_CLIENTE = SE1.E1_CLIENTE 
              AND SEF.EF_LOJACLI = SE1.E1_LOJA 
              AND SEF.EF_DATA  >= %exp:DToS(mv_par09)%
			  AND SEF.EF_DATA  <= %exp:DToS(mv_par10)%
              AND SE1.E1_PORTADO >= %exp:mv_par05%
		 	  AND SE1.E1_PORTADO <= %exp:mv_par06%
		 	  AND SEF.%notDel%
 		 	  AND SE1.%notDel%
              GROUP BY %Exp:cQryGroup% 
	       		    				
	    	EndSql
	
		END REPORT QUERY oSection1
	
		oSection1:Init()     	

cCompara := cAlias1+"->AU_CODGRUP"

oSection1:Init()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a impressao dos dados, de acordo com o filtro ou queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cAlias1)
While !oReport:Cancel() .And. !(cAlias1)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

	If !Empty(cFiltro) 
		If alltrim(cFiltro) <> alltrim(&(cCompara))      
	   		oSection1:Finish()
			oReport:SkipLine()  
			oReport:PrintText(STR0003+": "+(cAlias1)->AU_CODGRUP+" - "+(cAlias1)->AU_DESCRI,oReport:Row(),025) //"Grupo Filial"
			oReport:SkipLine()
			oReport:FatLine()
			cFiltro := &(cCompara)
			oSection1:Init()   
		Endif	
	Else
		oReport:PrintText(STR0003+": "+(cAlias1)->AU_CODGRUP+" - "+(cAlias1)->AU_DESCRI,oReport:Row(),025) //"Grupo Filial"
		oReport:PrintText(cTit,oReport:Row(),025)
		cFiltro := &(cCompara)
	Endif
      	
	oSection1:PrintLine()
	(cAlias1)->( DbSkip() )
EndDo

oSection1:Finish()
oReport:SkipLine()
oReport:SkipLine()

(cAlias1)->(DbCloseArea())

oSection1:Finish()

Return NIL 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70177Prt บAutor  ณTOTVS               บ Data ณ  29/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR70177                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR70177Prt( oReport, cAlias1, nOrdem )
Local oSection1	:= oReport:Section(1)	// Objeto da secao 1
Local cFiltro	:= ""                  	// Filtro
Local cQryGroup	:= ""                  	// Query do group by
Local cCompara 	:= ""                  	// Variavel de Comparacao
Local cFilSEF	:= ""                  	// Filial da query
Local cTit    	:= ""                  	// Titulo

cFilSEF := "% ("+LJ7017QryFil(.F.,"SEF")[2]+") %"

Do Case
	Case nOrdem == 1 //Grupo de filial
	    cQryGroup:= "% SAU.AU_CODGRUP,SAU.AU_DESCRI,SEF.EF_FILIAL,SEF.EF_PREFIXO,SEF.EF_TITULO,SEF.EF_NUMNOTA,SEF.EF_SERIE,SEF.EF_VALOR,SEF.EF_CLIENTE,SEF.EF_LOJACLI,SEF.EF_DATA,SEF.EF_BENEF,SEF.EF_BANCO,SEF.EF_AGENCIA,SEF.EF_CONTA,SEF.EF_NUM %"
	Case nOrdem == 2 //Filial
	    cQryGroup:= "% SEF.EF_FILIAL,SEF.EF_PREFIXO,SEF.EF_TITULO,SEF.EF_NUMNOTA,SEF.EF_SERIE,SEF.EF_VALOR,SEF.EF_CLIENTE,SEF.EF_LOJACLI,SEF.EF_DATA,SEF.EF_BENEF,SEF.EF_BANCO,SEF.EF_AGENCIA,SEF.EF_CONTA,SEF.EF_NUM %"
EndCase    

	DbSelectArea("SLW")
	DbSetOrder(1) //LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_NUMMOV
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MakeSqlExpr("LJ7017")

	oReport:Section(1):BeginQuery()	
	
	
		BEGIN REPORT QUERY oSection1
		
			BeginSql alias cAlias1
	   	
 			  SELECT %Exp:cQryGroup% 
             
              FROM %table:SEF% SEF,%table:SE1% SE1 
              
              WHERE %exp:cFilSEF%
              AND SEF.EF_CHDEVOL <> ' ' 
		      AND SEF.EF_FILIAL = SE1.E1_FILIAL 
              AND SEF.EF_PREFIXO = SE1.E1_PREFIXO
              AND SEF.EF_TITULO = SE1.E1_NUM   
              AND SEF.EF_SERIE = SE1.E1_SERIE
              AND SEF.EF_NUMNOTA = SE1.E1_NUMNOTA
              AND SEF.EF_CLIENTE = SE1.E1_CLIENTE 
              AND SEF.EF_LOJACLI = SE1.E1_LOJA 
              AND SEF.EF_DATA  >= %exp:DToS(mv_par09)%
			  AND SEF.EF_DATA  <= %exp:DToS(mv_par10)%                 
              AND SE1.E1_PORTADO >= %exp:mv_par05%
		 	  AND SE1.E1_PORTADO <= %exp:mv_par06%
		 	  AND SEF.%notDel%
 		 	  AND SE1.%notDel%
              GROUP BY %Exp:cQryGroup% 
	       		    				
	    	EndSql
	
		END REPORT QUERY oSection1
	
		oSection1:Init()     	

Do Case
	Case nOrdem == 1 //Grupo de filial
	    cCompara := cAlias1+"->AU_CODGRUP"
	Case nOrdem == 2 //Filial
	    cCompara := cAlias1+"->EF_FILIAL"
EndCase    


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a impressao dos dados, de acordo com o filtro ou queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cAlias1)
While !oReport:Cancel() .And. !(cAlias1)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

	If !Empty(cFiltro) 
		If alltrim(cFiltro) <> alltrim(&(cCompara))
            
			If nOrdem == 2 //Filial
			    cTit  := STR0004+": " + (cAlias1)->EF_FILIAL //"Filial"
		    Endif
		    
		    oSection1:Finish()
			oReport:SkipLine()
			oReport:PrintText(cTit,oReport:Row(),025)
			oReport:SkipLine()
			oReport:FatLine()
			cFiltro := &(cCompara)
			oSection1:Init()
		   
		Endif	
	Else
		If nOrdem == 2 //Filial
		    cTit  := STR0004+": " + (cAlias1)->EF_FILIAL //"Filial"
	    Endif
 
		oReport:PrintText(cTit,oReport:Row(),025)

		cFiltro := &(cCompara)
	Endif

	oSection1:PrintLine()
	(cAlias1)->( DbSkip() )
EndDo

oSection1:Finish()

(cAlias1)->(DbCloseArea())

Return NIL 
         

//-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-Prevencao de Perdas\Financeira\Titulos em atraso-=-=-=--=-=-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณ LJR70178 ณ Autor ณ TOTVS               ณ Data ณ 29/07/2013 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณPrevencao de Perdas\Financeira\Titulos em atraso            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณRelatorio Personalizavel									  ณฑฑ
ฑฑศออออออออออออออฯออออออออฯออออออฯออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LJR70178(cTitulo,nOrdem,aGPFilial)
Local oReport 	:= NIL				// Objeto para geracao do relatorio
Local aArea 	:= GetArea() 		// Salva a area

Default aGPFilial := {} 			// Grupo de Filiais

Pergunte("LJ7017",.F.)//O pergunte deve estar desabilitado 

oReport := LJR70178Def(cTitulo,nOrdem,aGPFilial)
oReport:PrintDialog()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a areaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea( aArea )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70178Def บAutor  ณTOTVS             บ Data ณ  29/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao das celulas que irao compor o relatorio           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR100                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR70178Def(cTitulo,nOrdem,aGPFilial)
Local oReport	:= NIL									// Objeto do relatorio
Local oSection1	:= NIL									// Objeto da secao 1
Local cAlias1	:= GetNextAlias()						// Pega o proximo Alias Disponivel
Local oTotaliz	:= NIL									// Objeto totalizador
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera a tela com os dados para a confirma็ใo da geracao do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If !Empty(aGPFilial)
	oReport := TReport():New("LOJR70178",STR0001+" " + cTitulo,"",{|oReport| LJR701780Prt(oReport, cAlias1 )},STR0002 )//Relat๓rio Analitico##"Prevencao de Perdas"
Else
	oReport := TReport():New("LOJR70178",STR0001+" " + cTitulo,"",{|oReport| LJR70178Prt(oReport, cAlias1,nOrdem )},STR0002 )//Relat๓rio Analitico##"Prevencao de Perdas"
Endif	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine a secao1 do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                          
oSection1 := TRSection():New( oReport,"",{ "SE1"} )	
oSection1:SetHeaderBreak(.T.)		//Indica se cabecalho da secao sera impresso em cada quebra 
oSection1:SetHeaderPage(.T.)		//Indica que cabecalho da secao sera impresso no topo da pagina

oReport:SetLandscape(.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine as celulas que irao aparecer na secao1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOrdem <> 2
	TRCell():New(oSection1,"E1_FILIAL"	,"SE1",STR0004 ) //"Filial"
Endif

TRCell():New(oSection1,"E1_LOJA"	,"SE1",STR0040 ) //"Loja"
TRCell():New(oSection1,"E1_PORTADO"	,"SE1",STR0043 ) //"Portador"
TRCell():New(oSection1,"E1_PREFIXO"	,"SE1",STR0042 ) //"Prefixo"
TRCell():New(oSection1,"E1_SERIE"	,"SE1",STR0015 ) //"Serie"
TRCell():New(oSection1,"E1_NUM"	    ,"SE1",STR0041 ) //"Numero da Nota"
TRCell():New(oSection1,"E1_PARCELA"	,"SE1",STR0044 ) //"Parcela"

If nOrdem <> 3
	TRCell():New(oSection1,"E1_CLIENTE"	,"SE1",STR0045 ) //"Cod.Cliente"
	TRCell():New(oSection1,"cCLIENTE"	,""   ,STR0046 ) //"Cliente"
Endif

TRCell():New(oSection1,"E1_VALOR"	,"SE1",STR0012 ) //"Valor"
TRCell():New(oSection1,"E1_EMISSAO"	,"SE1","Emissao" ) 
TRCell():New(oSection1,"E1_VENCREA"	,"SE1","Venc.Real") 
TRCell():New(oSection1,"cDias"	    ,"","Dias atraso", ,,,{||(cAlias1)->E1_VENCREA - (cAlias1)->E1_EMISSAO })

oTotaliz := TRFunction():new(oSection1:Cell("E1_NUM")	,,"COUNT",,"Quant.","@E 999,999,999.99") 
oTotaliz := TRFunction():new(oSection1:Cell("E1_VALOR")	,,"SUM",,STR0014,"@E 999,999,999.99") //"Total"

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70170Prt บAutor  ณTOTVS               บ Data ณ  01/08/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel-GP Filial   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR70171                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR701780Prt( oReport, cAlias1)
Local oSection1	:= oReport:Section(1)	// Objeto da secao 1
Local cQryGroup	:= ""                  	// Query do group by
Local cFiltro	:= ""                  	// Filtro
Local cCompara 	:= ""                  	// Variavel de Comparacao
Local cFilSE1  	:= ""                  	// Filial da query

cQryGroup:= "% SAU.AU_CODGRUP, SAU.AU_DESCRI,E1_FILIAL, E1_LOJA, E1_PORTADO,E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE,E1_VALOR,E1_EMISSAO,E1_VENCREA   %"
 
cFilSE1 := "% ("+LJ7017QryFil(.F.,"SE1")[2]+") %"   

	DbSelectArea("SE1")
	DbSetOrder(1) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MakeSqlExpr("LJ7017")

	oReport:Section(1):BeginQuery()		
	
		BEGIN REPORT QUERY oSection1
		
			BeginSql alias cAlias1
	   	
			   SELECT SAU.AU_CODGRUP, SAU.AU_DESCRI,E1_FILIAL, E1_LOJA, E1_PORTADO,E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE,E1_VALOR , E1_EMISSAO,E1_VENCREA 
               FROM %table:SE1% SE1 
	           INNER JOIN %table:SAU%  SAU ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SE1.E1_FILIAL 
               WHERE %exp:cFilSE1%
	  			  AND E1_VENCREA >= %exp:DToS(mv_par09)%
	 			  AND E1_VENCREA <= %exp:DToS(mv_par10)%
	 			  AND E1_SALDO <> 0 
	              AND E1_BAIXA = ' '
				  AND E1_TIPO <> 'PIS' 
	 			  AND E1_TIPO <> 'COF' 
	 			  AND E1_TIPO <> 'CSL'
		   		  AND E1_PORTADO >= %exp:mv_par05%
			 	  AND E1_PORTADO <= %exp:mv_par06%
			 	  AND SE1.%notDel%
	   			GROUP BY %Exp:cQryGroup% 
	    	EndSql
	
		END REPORT QUERY oSection1
	
	oSection1:Init()

cCompara := cAlias1+"->AU_CODGRUP"

oSection1:Init()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a impressao dos dados, de acordo com o filtro ou queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cAlias1)
While !oReport:Cancel() .And. !(cAlias1)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

    If !Empty(cFiltro) 
		If alltrim(cFiltro) <> alltrim(&(cCompara))      
	   		oSection1:Finish()
			oReport:SkipLine()  
			oReport:PrintText(STR0003+": "+(cAlias1)->AU_CODGRUP+" - "+(cAlias1)->AU_DESCRI,oReport:Row(),025) //"Grupo Filial"
			oReport:SkipLine()
			oReport:FatLine()
			cFiltro := &(cCompara)
			oSection1:Init()   
		Endif	
	Else
		
		oReport:PrintText(STR0003+": "+(cAlias1)->AU_CODGRUP+" - "+(cAlias1)->AU_DESCRI,oReport:Row(),025) //"Grupo Filial"
		cFiltro := &(cCompara)
	Endif
       	
	dbSelectArea("SA1")
	DbSetOrder(1) //A1_FILIAL+A1_COD+A1_LOJA
    If SA1->(DbSeek(xFilial("SA1")+(cAlias1)->E1_CLIENTE+(cAlias1)->E1_LOJA))
       	oSection1:Cell("cCLIENTE"):SetValue(Substr(A1_NOME,1,30))
    Endif

	oSection1:PrintLine()
	(cAlias1)->( DbSkip() )
EndDo

oSection1:Finish()
oReport:SkipLine()
oReport:SkipLine()

(cAlias1)->(DbCloseArea())

oSection1:Finish()

Return NIL 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJR70178Prt บAutor  ณTOTVS               บ Data ณ  29/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJR70178                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LJR70178Prt( oReport, cAlias1, nOrdem )
Local oSection1	:= oReport:Section(1)	// Objeto da secao 1
Local cFiltro	:= ""                  	// Filtro
Local cQryGroup	:= ""                  	// Query do group by
Local cCompara 	:= ""                  	// Variavel de Comparacao
Local cFilSE1	:= ""                  	// Filial da query
Local cTit    	:= ""                  	// Titulo

cFilSE1 := "% ("+LJ7017QryFil(.F.,"SE1")[2]+") %"   

Do Case
	Case nOrdem == 1 //Grupo de filial
	    cQryGroup:= "% E1_FILIAL, E1_LOJA, E1_PORTADO,E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE,E1_VALOR, E1_EMISSAO,E1_VENCREA %"
	Case nOrdem == 2 //Filial
	    cQryGroup:= "% E1_FILIAL, E1_LOJA, E1_PORTADO,E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE,E1_VALOR, E1_EMISSAO,E1_VENCREA %"
    Case nOrdem == 3 //Cliente 
	    cQryGroup:= "% E1_FILIAL, E1_LOJA, E1_CLIENTE, E1_PORTADO,E1_PREFIXO, E1_NUM, E1_PARCELA, E1_VALOR, E1_EMISSAO,E1_VENCREA %"
EndCase    

	DbSelectArea("SE1")
	DbSetOrder(1) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MakeSqlExpr("LJ7017")

	oReport:Section(1):BeginQuery()	
	
	
		BEGIN REPORT QUERY oSection1
		
			BeginSql alias cAlias1
	   	
			   SELECT E1_FILIAL, E1_LOJA, E1_PORTADO,E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE,E1_VALOR, E1_EMISSAO,E1_VENCREA  
               FROM %table:SE1% SE1 
               WHERE %exp:cFilSE1%
	  			  AND E1_VENCREA >= %exp:DToS(mv_par09)%
	 			  AND E1_VENCREA <= %exp:DToS(mv_par10)%
	 			  AND E1_SALDO <> 0 
	              AND E1_BAIXA = ' '
				  AND E1_TIPO <> 'PIS' 
	 			  AND E1_TIPO <> 'COF' 
	 			  AND E1_TIPO <> 'CSL'
		   		  AND E1_PORTADO >= %exp:mv_par05%
			 	  AND E1_PORTADO <= %exp:mv_par06%
			 	  AND SE1.%notDel%
	   			GROUP BY %Exp:cQryGroup% 
	    	EndSql
	
		END REPORT QUERY oSection1
	
	oSection1:Init()

Do Case
	Case nOrdem == 1 //Grupo de filial
	    cCompara := cAlias1+"->E1_FILIAL"
	Case nOrdem == 2 //Filial
	    cCompara := cAlias1+"->E1_FILIAL
    Case nOrdem == 3 //Cliente
	    cCompara := cAlias1+"->E1_FILIAL+"+cAlias1+"->E1_CLIENTE"
EndCase    


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExecuta a impressao dos dados, de acordo com o filtro ou queryณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cAlias1)
While !oReport:Cancel() .And. !(cAlias1)->(Eof())

	If oReport:Cancel()
		Exit
	EndIf

	If !Empty(cFiltro) 
		If alltrim(cFiltro) <> alltrim(&(cCompara))      
            
			If nOrdem == 2 //Filial
			    cTit  := STR0004+": " + (cAlias1)->E1_FILIAL //"Filial"
		    Endif
		    
   			If nOrdem == 3 //Cliente
			   	dbSelectArea("SA1")
				DbSetOrder(1) //A1_FILIAL+A1_COD+A1_LOJA
			    If SA1->(DbSeek(xFilial("SA1")+(cAlias1)->E1_CLIENTE+(cAlias1)->E1_LOJA))
				    cTit  := STR0046+": " + alltrim((cAlias1)->E1_CLIENTE) +" - "+Substr(A1_NOME,1,30) //"Cliente"
			    Endif
		    Endif
		    
		    oSection1:Finish()
			oReport:SkipLine()
			oReport:PrintText(cTit,oReport:Row(),025)
			oReport:SkipLine()
			oReport:FatLine()
			cFiltro := &(cCompara)
			oSection1:Init()

		Endif	
	Else
		If nOrdem == 2 //Filial
		    cTit  := STR0004+": " + (cAlias1)->E1_FILIAL //"Filial"
	    Endif

		If nOrdem == 3 //Cliente
		   	dbSelectArea("SA1")
			DbSetOrder(1) //A1_FILIAL+A1_COD+A1_LOJA
		    If SA1->(DbSeek(xFilial("SA1")+(cAlias1)->E1_CLIENTE+(cAlias1)->E1_LOJA))
			    cTit  := STR0046+": " + alltrim((cAlias1)->E1_CLIENTE) +" - "+Substr(A1_NOME,1,30) //"Cliente"
		    Endif
	    Endif

		oReport:PrintText(cTit,oReport:Row(),025)

		cFiltro := &(cCompara)
	Endif

    
	If nOrdem <> 3
		dbSelectArea("SA1")
		DbSetOrder(1) //A1_FILIAL+A1_COD+A1_LOJA
	    If SA1->(DbSeek(xFilial("SA1")+(cAlias1)->E1_CLIENTE+(cAlias1)->E1_LOJA))
	       	oSection1:Cell("cCLIENTE"):SetValue(Substr(A1_NOME,1,30))
	    Endif
	Endif
	
	oSection1:PrintLine()
	(cAlias1)->( DbSkip() )
EndDo

oSection1:Finish()
(cAlias1)->(DbCloseArea())

Return NIL 


//-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-Prevencao de Perdas\Comercial\Qtde. Consulta Pre็os\...-=-=-=--=-=-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LR7017311  บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrevencao de Perdas\Comercial\Qtde. Consulta Pre็os\...       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณRelatorio Personalizavel                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

/*/
Function LR7017311(cTitulo,lGrpFil,nTipo)
Local oReport 	:= NIL				// Objeto para geracao do relatorio
Local aArea 	:= GetArea() 		// Salva a area

Pergunte("LJ7017",.F.) 		// O pergunte deve estar desabilitado 

oReport := L7017311Def(cTitulo,lGrpFil,nTipo)
oReport:PrintDialog()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a areaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea( aArea )
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณL7017311Def บAutor  ณTOTVS             บ Data ณ  24/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao das celulas que irao compor o relatorio           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LR7017311                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L7017311Def(cTit,lGrpFil,nTipo)
Local oReport	:= NIL									// Objeto do relatorio
Local oSection1	:= NIL									// Objeto da secao 1
Local oSection2	:= NIL									// Objeto da secao 2
Local oCell		:= NIL									// Objeto Cell TReport
Local oTotaliz	:= NIL									// Objeto totalizador
Local cAlias1	:= GetNextAlias()						// Pega o proximo Alias Disponivel
Local cTitulo	:= ""				                  	// Titulo
Local aFiliais 	:= Lj7017Fil()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera a tela com os dados para a confirma็ใo da geracao do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oReport := TReport():New("LR701731"+AllTrim(STR(nTipo)),STR0002+" - "+STR0047+" - "+STR0048+" - "+cTit,"",{|oReport| L7017311Prt(oReport,cAlias1,lGrpFil,nTipo)},STR0002 )//##"Prevencao de Perdas"##"Comercial"##"Qtde. Consulta Pre็os"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine a secao1 do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1 := TRSection():New( oReport,STR0002,{ "MFL" } )	//##"Prevencao de Perdas"
oSection1:SetHeaderBreak(.T.)		//Indica se cabecalho da secao sera impresso em cada quebra 
oSection1:SetHeaderPage(.T.)		//Indica que cabecalho da secao sera impresso no topo da pagina

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cabecalho                                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGrpFil .AND. nTipo == 1	// Grupo de Filiais
	oCell := TRCell():New(oSection1,"cGrpF",,""	,,60,,{||cGrpF:=STR0003+": "	+&(cAlias1)->(AU_CODGRUP)+"-"+&(cAlias1)->(AU_DESCRI) })//Grupo Filial

ElseIf nTipo == 2  			// Filiais
	oCell := TRCell():New(oSection1,"cFilial",,""  ,,60,,{||cFilial:=STR0004+": "+LR7017FilNo(&(cAlias1)->(MFL_FILIAL),aFiliais) })//Filial

ElseIf nTipo == 3  			// Caixas
	oCell := TRCell():New(oSection1,"cCaixa",,""	,,60,,{||cCaixa:=STR0049+": "+&(cAlias1)->(A6_COD)+"-"+&(cAlias1)->(A6_NREDUZ) })//"Caixa"

Else   			   			// PDVs
	oCell := TRCell():New(oSection1,"cPDV",,""  	,,60,,{||cPDV:=STR0018+": "+&(cAlias1)->(LG_PDV)+"-"+&(cAlias1)->(LG_NOME) })//"PDV"

EndIf

oSection2 := TRSection():New(oSection1,cTitulo,{"cAlias1"})
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderPage(.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine as celulas que irao aparecer na secao2ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nTipo <> 2
	oCell := TRCell():New(oSection2,"MFL_FILIAL"	,cAlias1,STR0004 )////Filial
Endif
If lGrpFil .AND. nTipo <> 1
	oCell := TRCell():New(oSection2,"AU_CODGRUP"	,cAlias1,STR0003 )  
	oCell := TRCell():New(oSection2,"AU_DESCRI"		,cAlias1,STR0050 )//"Descr. Grupo Filial"
EndIf
If nTipo <> 3
	oCell := TRCell():New(oSection2,"A6_COD"		,cAlias1,STR0049 )////"Caixa"
	oCell := TRCell():New(oSection2,"A6_NREDUZ"		,cAlias1,STR0051 )//"Nome Caixa"
Endif
If nTipo <> 4
	oCell := TRCell():New(oSection2,"LG_PDV"		,cAlias1,STR0018 )//"PDV"
	oCell := TRCell():New(oSection2,"LG_NOME"		,cAlias1,STR0052 )//Nome PDV
Endif
oCell := TRCell():New(oSection2,"MFL_DATA"		,cAlias1,STR0028,,12 )//"Data"
oCell := TRCell():New(oSection2,"MFL_HORA"		,cAlias1,STR0053,,14 )//Hora
oCell := TRCell():New(oSection2,"MFL_PRODUT"	,cAlias1,STR0005,,25 )
oCell := TRCell():New(oSection2,"B1_DESC"  		,cAlias1,STR0054 ) //"Descr. Produto" 


If nTipo == 2
	oTotaliz := TRFunction():new(oSection2:Cell("AU_CODGRUP")	,,"COUNT",,STR0014	,"@E 9,999,999") 	//"Total" 
Else
	oTotaliz := TRFunction():new(oSection2:Cell("MFL_FILIAL")	,,"COUNT",,STR0014	,"@E 9,999,999") 	//"Total"
EndIf

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณL7017311Prt บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LR7017311                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L7017311Prt( oReport, cAlias1, lGrpFil, nTipo )
Local oSection1	:= oReport:Section(1)  				// Objeto da secao 1
Local oSection2	:= oReport:Section(1):Section(1)	// Objeto da secao 2
Local cFilAux 	:= "%" + LJ7017QryFil(.F.,"MFL")[2] + "%" // Filial da query

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
MakeSqlExpr("LJ7017")

oReport:Section(1):BeginQuery()	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa a secao 1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGrpFil
	BEGIN REPORT QUERY oSection1	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณQuery da secao 1ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		BeginSql alias cAlias1

			SELECT MFL.MFL_FILIAL,SAU.AU_CODGRUP,SAU.AU_DESCRI,SA6.A6_COD,SA6.A6_NREDUZ,SLG.LG_PDV,SLG.LG_NOME,MFL.MFL_DATA,MFL.MFL_HORA,
				MFL.MFL_PRODUT,SB1.B1_DESC
			FROM 	%table:MFL% MFL
			INNER JOIN %table:SAU% SAU ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = MFL.MFL_FILIAL
			INNER JOIN %table:SA6% SA6 ON SA6.D_E_L_E_T_ = ' ' AND SA6.A6_COD = MFL.MFL_CAIXA
			INNER JOIN %table:SLG% SLG ON SLG.D_E_L_E_T_ = ' ' AND SLG.LG_FILIAL = MFL.MFL_FILIAL AND SLG.LG_PDV = MFL.MFL_PDV
			INNER JOIN %table:SB1% SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = MFL.MFL_FILIAL AND SB1.B1_COD = MFL.MFL_PRODUT 
			WHERE %exp:cFilAux%
				AND MFL.MFL_CAIXA BETWEEN 	%exp:mv_par05% 			AND %exp:mv_par06% 
				AND MFL.MFL_PDV BETWEEN 	%exp:mv_par07% 			AND %exp:mv_par08% 
				AND MFL.MFL_DATA BETWEEN 	%exp:DToS(mv_par09)% 	AND %exp:DToS(mv_par10)% 
				AND MFL.%notDel%
			ORDER BY SLG.LG_FILIAL,SA6.A6_COD,SLG.LG_PDV,MFL.MFL_DATA,MFL.MFL_HORA
   			
	    EndSql		
	END REPORT QUERY oSection1
Else
	BEGIN REPORT QUERY oSection1
	
		BeginSql alias cAlias1

			SELECT MFL.MFL_FILIAL,SA6.A6_COD,SA6.A6_NREDUZ,SLG.LG_PDV,SLG.LG_NOME,MFL.MFL_DATA,MFL.MFL_HORA,MFL.MFL_PRODUT,SB1.B1_DESC
			FROM 	%table:MFL% MFL
			INNER JOIN %table:SA6% SA6 ON SA6.D_E_L_E_T_ = ' ' AND SA6.A6_COD = MFL.MFL_CAIXA
			INNER JOIN %table:SLG% SLG ON SLG.D_E_L_E_T_ = ' ' AND SLG.LG_FILIAL = MFL.MFL_FILIAL AND SLG.LG_PDV = MFL.MFL_PDV
			INNER JOIN %table:SB1% SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = MFL.MFL_FILIAL AND SB1.B1_COD = MFL.MFL_PRODUT 
			WHERE %exp:cFilAux%
				AND MFL.MFL_CAIXA BETWEEN 	%exp:mv_par05% 			AND %exp:mv_par06% 
				AND MFL.MFL_PDV BETWEEN 	%exp:mv_par07% 			AND %exp:mv_par08% 
				AND MFL.MFL_DATA BETWEEN 	%exp:DToS(mv_par09)% 	AND %exp:DToS(mv_par10)% 
				AND MFL.%notDel%
			ORDER BY SLG.LG_FILIAL,SA6.A6_COD,SLG.LG_PDV,MFL.MFL_DATA,MFL.MFL_HORA
   			
    	EndSql

	END REPORT QUERY oSection1

Endif

oSection2:SetParentQuery()
If lGrpFil .AND. nTipo == 1	// Grupo de Filiais
	oSection2:SetParentFilter( {|G|(cAlias1)->AU_CODGRUP == G }, 	{||(cAlias1)->AU_CODGRUP} )
ElseIf nTipo == 2			// Filiais
	oSection2:SetParentFilter( {|G|(cAlias1)->MFL_FILIAL == G },	{||(cAlias1)->MFL_FILIAL} )
ElseIf nTipo == 3	  		// Caxias
	oSection2:SetParentFilter( {|G|(cAlias1)->A6_COD == G }, 		{||(cAlias1)->A6_COD} )
ElseIf nTipo == 4			// PDVs
	oSection2:SetParentFilter( {|G|(cAlias1)->MFL_FILIAL+(cAlias1)->LG_PDV == G }, {||(cAlias1)->MFL_FILIAL+(cAlias1)->LG_PDV} )
EndIf

oSection1:Print() // processa as informacoes da tabela principal
oReport:SetMeter(&(cAlias1)->(LastRec()))

Return NIL

//-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-Prevencao de Perdas\Comercial\Cancelamento Cupom\...-=-=-=--=-=-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LR7017321  บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrevencao de Perdas\Comercial\Cancelamento Cupom\...          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณRelatorio Personalizavel                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

/*/
Function LR7017321(cTitulo,lGrpFil,nTipo)
Local oReport 	:= NIL				// Objeto para geracao do relatorio
Local aArea 	:= GetArea() 		// Salva a area

Pergunte("LJ7017",.F.) 		// O pergunte deve estar desabilitado 

oReport := L7017321Def(cTitulo,lGrpFil,nTipo)
oReport:PrintDialog()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a areaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea( aArea )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณL7017321Def บAutor  ณTOTVS             บ Data ณ  24/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao das celulas que irao compor o relatorio           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LR7017321                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L7017321Def(cTit,lGrpFil,nTipo)
Local oReport	:= NIL									// Objeto do relatorio
Local oSection1	:= NIL									// Objeto da secao 1
Local oSection2	:= NIL									// Objeto da secao 2
Local oCell		:= NIL									// Objeto Cell TReport
Local oTotaliz	:= NIL									// Objeto totalizador
Local cAlias1	:= GetNextAlias()						// Pega o proximo Alias Disponivel
Local cTitulo	:= ""				                  	// Titulo
Local aFiliais 	:= Lj7017Fil()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera a tela com os dados para a confirma็ใo da geracao do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oReport := TReport():New("LR701732"+AllTrim(STR(nTipo)),STR0002+" - "+STR0047+" - "+STR0055+" - "+cTit,"",{|oReport| L7017321Prt(oReport,cAlias1,lGrpFil,nTipo)},STR0002 )//##"Prevencao de Perdas"##"Comercial"##Cancelamento Cupom

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine a secao1 do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1 := TRSection():New( oReport,STR0002,{ "SLX" } )	//##"Prevencao de Perdas"
oSection1:SetHeaderBreak(.T.)		//Indica se cabecalho da secao sera impresso em cada quebra 
oSection1:SetHeaderPage(.T.)		//Indica que cabecalho da secao sera impresso no topo da pagina

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cabecalho                                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGrpFil .AND. nTipo == 1 // Grupo de Filiais
	oCell := TRCell():New(oSection1,"cGrpF",,""	,,60,,{||cGrpF:=STR0003+": "	+&(cAlias1)->(AU_CODGRUP)+"-"+&(cAlias1)->(AU_DESCRI) })//Grupo Filial

ElseIf nTipo == 2			// Filiais
	oCell := TRCell():New(oSection1,"cFilial",,""  ,,60,,{||cFilial:=STR0004+": "+LR7017FilNo(&(cAlias1)->(LX_FILIAL),aFiliais) })////Filial

ElseIf nTipo == 3			// Caixas
	oCell := TRCell():New(oSection1,"cCaixa",,""	,,60,,{||cCaixa:=STR0049+": "+&(cAlias1)->(A6_COD)+"-"+&(cAlias1)->(A6_NREDUZ) })//"Caixa"

Else   						// PDVs
	oCell := TRCell():New(oSection1,"cPDV",,""  	,,60,,{||cPDV:=STR0018+": "+&(cAlias1)->(LX_PDV)+"-"+&(cAlias1)->(LG_NOME) })//"PDV"

EndIf

oSection2 := TRSection():New(oSection1,cTitulo,{"cAlias1"})
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderPage(.T.) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine as celulas que irao aparecer na secao2ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nTipo <> 2
	oCell := TRCell():New(oSection2,"LX_FILIAL"		,cAlias1,STR0004 )//Filial
Endif
If lGrpFil .AND. nTipo <> 1
	oCell := TRCell():New(oSection2,"AU_CODGRUP"	,cAlias1,STR0003 )  
	oCell := TRCell():New(oSection2,"AU_DESCRI"		,cAlias1,STR0050 )//"Descr. Grupo Filial"
EndIf
If nTipo <> 3
	oCell := TRCell():New(oSection2,"A6_COD"		,cAlias1,STR0049 )//"Caixa"
	oCell := TRCell():New(oSection2,"A6_NREDUZ"		,cAlias1,STR0051 )//"Nome Caixa"
Endif
If nTipo <> 4
	oCell := TRCell():New(oSection2,"LX_PDV"		,cAlias1,STR0018 )//"PDV"
	oCell := TRCell():New(oSection2,"LG_NOME"		,cAlias1,STR0052 )//Nome PDV
Endif
oCell := TRCell():New(oSection2,"LX_DTMOVTO"		,cAlias1,STR0028,,10)//"Data"
oCell := TRCell():New(oSection2,"LX_HORA" 			,cAlias1,STR0053 )//"Hora"
oCell := TRCell():New(oSection2,"LX_SERIE"  		,cAlias1,STR0015 )//"Serie"
oCell := TRCell():New(oSection2,"LX_CUPOM"  		,cAlias1,STR0063 )//"Documento"


If nTipo == 2
	oTotaliz := TRFunction():new(oSection2:Cell("AU_CODGRUP")	,,"COUNT",,STR0014	,"@E 9,999,999") 	//"Total"  
Else
	oTotaliz := TRFunction():new(oSection2:Cell("LX_FILIAL")	,,"COUNT",,STR0014	,"@E 9,999,999") 	//"Total"
EndIf

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณL7017321Prt บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LR7017321                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L7017321Prt( oReport, cAlias1, lGrpFil, nTipo )
Local oSection1	:= oReport:Section(1)  				// Objeto da secao 1
Local oSection2	:= oReport:Section(1):Section(1)	// Objeto da secao 2		
Local cFilAux 	:= "%" + LJ7017QryFil(.F.,"SLX")[2] + "%" // Filial da query

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
MakeSqlExpr("LJ7017")

oReport:Section(1):BeginQuery()	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa a secao 1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGrpFil
	BEGIN REPORT QUERY oSection1	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณQuery da secao 1ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		BeginSql alias cAlias1

			SELECT SLX.LX_FILIAL,SAU.AU_CODGRUP,SAU.AU_DESCRI,SA6.A6_COD,SA6.A6_NREDUZ,SLX.LX_PDV,SLG.LG_NOME,SLX.LX_DTMOVTO,SLX.LX_HORA,SLX.LX_CUPOM,SLX.LX_SERIE
			FROM 	%table:SLX% SLX
			INNER JOIN %table:SAU% SAU ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SLX.LX_FILIAL
			INNER JOIN %table:SA6% SA6 ON SA6.D_E_L_E_T_ = ' ' AND SA6.A6_COD = SLX.LX_OPERADO
			INNER JOIN %table:SLG% SLG ON SLG.D_E_L_E_T_ = ' ' AND SLG.LG_FILIAL = SLX.LX_FILIAL AND SLG.LG_PDV = SLX.LX_PDV
			WHERE %exp:cFilAux%
				AND SLX.LX_OPERADO BETWEEN 	%exp:mv_par05% 			AND %exp:mv_par06% 
				AND SLX.LX_PDV BETWEEN	 	%exp:mv_par07% 			AND %exp:mv_par08% 
				AND SLX.LX_DTMOVTO BETWEEN	%exp:DToS(mv_par09)% 	AND %exp:DToS(mv_par10)% 
				AND SLX.%notDel%
			GROUP BY SLX.LX_FILIAL,SAU.AU_CODGRUP,SAU.AU_DESCRI,SA6.A6_COD,SA6.A6_NREDUZ,SLX.LX_PDV,SLG.LG_NOME,SLX.LX_DTMOVTO,SLX.LX_HORA,SLX.LX_CUPOM,SLX.LX_SERIE
   			ORDER BY SLX.LX_FILIAL,SA6.A6_COD,SLX.LX_PDV,SLX.LX_DTMOVTO,SLX.LX_HORA
   			
	    EndSql		
	END REPORT QUERY oSection1
Else
	BEGIN REPORT QUERY oSection1
	
		BeginSql alias cAlias1

			SELECT SLX.LX_FILIAL,SA6.A6_COD,SA6.A6_NREDUZ,SLX.LX_PDV,SLG.LG_NOME,SLX.LX_DTMOVTO,SLX.LX_HORA,SLX.LX_CUPOM,SLX.LX_SERIE
			FROM 	%table:SLX% SLX
			INNER JOIN %table:SA6% SA6 ON SA6.D_E_L_E_T_ = ' ' AND SA6.A6_COD = SLX.LX_OPERADO
			INNER JOIN %table:SLG% SLG ON SLG.D_E_L_E_T_ = ' ' AND SLG.LG_FILIAL = SLX.LX_FILIAL AND SLG.LG_PDV = SLX.LX_PDV
			WHERE %exp:cFilAux%
				AND SLX.LX_OPERADO BETWEEN 	%exp:mv_par05% 			AND %exp:mv_par06% 
				AND SLX.LX_PDV BETWEEN	 	%exp:mv_par07% 			AND %exp:mv_par08% 
				AND SLX.LX_DTMOVTO BETWEEN	%exp:DToS(mv_par09)% 	AND %exp:DToS(mv_par10)% 
				AND SLX.%notDel%
			GROUP BY SLX.LX_FILIAL,SA6.A6_COD,SA6.A6_NREDUZ,SLX.LX_PDV,SLG.LG_NOME,SLX.LX_DTMOVTO,SLX.LX_HORA,SLX.LX_CUPOM,SLX.LX_SERIE
   			ORDER BY SLX.LX_FILIAL,SA6.A6_COD,SLX.LX_PDV,SLX.LX_DTMOVTO,SLX.LX_HORA
   			
    	EndSql

	END REPORT QUERY oSection1

Endif

oSection2:SetParentQuery()
If lGrpFil .AND. nTipo == 1	// Grupo de Filiais
	oSection2:SetParentFilter( {|G|(cAlias1)->AU_CODGRUP == G }, 	{||(cAlias1)->AU_CODGRUP} )
ElseIf nTipo == 2			// Filiais
	oSection2:SetParentFilter( {|G|(cAlias1)->LX_FILIAL == G },	{||(cAlias1)->LX_FILIAL} )
ElseIf nTipo == 3  			// Caxias
	oSection2:SetParentFilter( {|G|(cAlias1)->A6_COD == G }, 		{||(cAlias1)->A6_COD} )
ElseIf nTipo == 4 			// PDVs
	oSection2:SetParentFilter( {|G|(cAlias1)->LX_FILIAL+(cAlias1)->LX_PDV == G }, {||(cAlias1)->LX_FILIAL+(cAlias1)->LX_PDV} )
EndIf

oSection1:Print() // processa as informacoes da tabela principal
oReport:SetMeter(&(cAlias1)->(LastRec()))

Return NIL

//-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-Prevencao de Perdas\Comercial\Entrada de Troco\...-=-=-=--=-=-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LR7017331  บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrevencao de Perdas\Comercial\Entrada de Troco\...            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณRelatorio Personalizavel                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

/*/
Function LR7017331(cTitulo,lGrpFil,nTipo)
Local oReport 	:= NIL				// Objeto para geracao do relatorio
Local aArea 	:= GetArea() 		// Salva a area

Pergunte("LJ7017",.F.) 		// O pergunte deve estar desabilitado 

oReport := L7017331Def(cTitulo,lGrpFil,nTipo)
oReport:PrintDialog()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a areaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea( aArea )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณL7017331Def บAutor  ณTOTVS             บ Data ณ  24/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao das celulas que irao compor o relatorio           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LR7017331                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L7017331Def(cTit,lGrpFil,nTipo)
Local oReport	:= NIL									// Objeto do relatorio
Local oSection1	:= NIL									// Objeto da secao 1
Local oSection2	:= NIL									// Objeto da secao 2
Local oCell		:= NIL									// Objeto Cell TReport
Local oTotaliz	:= NIL									// Objeto totalizador
Local cAlias1	:= GetNextAlias()						// Pega o proximo Alias Disponivel
Local cTitulo	:= ""				                  	// Titulo
Local aFiliais 	:= Lj7017Fil()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera a tela com os dados para a confirma็ใo da geracao do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oReport := TReport():New("LR701733"+AllTrim(STR(nTipo)),STR0002+" - "+STR0047+" - "+STR0057+" - "+cTit,"",{|oReport| L7017331Prt(oReport,cAlias1,lGrpFil,nTipo)},STR0002 )//##"Prevencao de Perdas"##"Comercial"//Entrada de Troco

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine a secao1 do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1 := TRSection():New( oReport,STR0002,{ "SE5" } )	//##"Prevencao de Perdas"
oSection1:SetHeaderBreak(.T.)		//Indica se cabecalho da secao sera impresso em cada quebra 
oSection1:SetHeaderPage(.T.)		//Indica que cabecalho da secao sera impresso no topo da pagina

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cabecalho                                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGrpFil .AND. nTipo == 1 // Grupo de Filiais
	oCell := TRCell():New(oSection1,"cGrpF",,""	,,60,,{||cGrpF:=STR0003+": "	+&(cAlias1)->(AU_CODGRUP)+"-"+&(cAlias1)->(AU_DESCRI) })//Grupo Filial

ElseIf nTipo == 2  			// Filiais
	oCell := TRCell():New(oSection1,"cFilial",,""  ,,60,,{||cFilial:=STR0004+": "+LR7017FilNo(&(cAlias1)->(E5_FILIAL),aFiliais) })//Filial

ElseIf nTipo == 3 			// Caixas
	oCell := TRCell():New(oSection1,"cCaixa",,""	,,60,,{||cCaixa:=STR0049+": "+&(cAlias1)->(A6_COD)+"-"+&(cAlias1)->(A6_NREDUZ) })//"Caixa"

Else   			  			// PDVs
	oCell := TRCell():New(oSection1,"cPDV",,""  	,,60,,{||cPDV:=STR0018+": "+&(cAlias1)->(LG_PDV)+"-"+&(cAlias1)->(LG_NOME) })//"PDV"

EndIf

oSection2 := TRSection():New(oSection1,cTitulo,{"cAlias1"})
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderPage(.T.) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine as celulas que irao aparecer na secao2ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nTipo <> 2
	oCell := TRCell():New(oSection2,"E5_FILIAL"		,cAlias1,STR0004 )//Filial
Endif
If lGrpFil .AND. nTipo <> 1
	oCell := TRCell():New(oSection2,"AU_CODGRUP"	,cAlias1,STR0003 )  
	oCell := TRCell():New(oSection2,"AU_DESCRI"		,cAlias1,STR0050 )//"Descr. Grupo Filial"
EndIf
If nTipo <> 3
	oCell := TRCell():New(oSection2,"A6_COD"		,cAlias1,STR0049 )//"Caixa"
	oCell := TRCell():New(oSection2,"A6_NREDUZ"		,cAlias1,STR0051 )//"Nome Caixa"
Endif
If nTipo <> 4
	oCell := TRCell():New(oSection2,"LG_PDV"		,cAlias1,STR0018 )//"PDV"
	oCell := TRCell():New(oSection2,"LG_NOME"		,cAlias1,STR0052 )//Nome PDV
Endif
oCell := TRCell():New(oSection2,"E5_DATA"	   		,cAlias1,STR0028,,10)//"Data"
oCell := TRCell():New(oSection2,"E5_PREFIXO" 		,cAlias1,STR0042 )//"Prefixo"
oCell := TRCell():New(oSection2,"E5_NUMERO"  		,cAlias1,STR0069 )//"Titulo"
oCell := TRCell():New(oSection2,"E5_VALOR"  		,cAlias1,STR0012 )//"Valor"

oTotaliz := TRFunction():new(oSection2:Cell("E5_VALOR")	,,"SUM",,STR0014	,"@E 999,999,999.99") 	//"Total"

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณL7017331Prt บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LR7017331                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L7017331Prt( oReport, cAlias1, lGrpFil, nTipo )
Local oSection1	:= oReport:Section(1)  				// Objeto da secao 1
Local oSection2	:= oReport:Section(1):Section(1)	// Objeto da secao 23		
Local cFilAux 	:= "%" + LJ7017QryFil(.F.,"SE5")[2] + "%" // Filial da query

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
MakeSqlExpr("LJ7017")

oReport:Section(1):BeginQuery()	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa a secao 1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGrpFil
	BEGIN REPORT QUERY oSection1	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณQuery da secao 1ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		BeginSql alias cAlias1

			SELECT SE5.E5_FILIAL,SAU.AU_CODGRUP,SAU.AU_DESCRI,SA6.A6_COD,SA6.A6_NREDUZ,SLG.LG_PDV,SLG.LG_NOME,SE5.E5_DATA,SE5.E5_PREFIXO,SE5.E5_NUMERO,SE5.E5_VALOR
			FROM 	%table:SE5% SE5
			INNER JOIN %table:SLW% SLW ON SLW.D_E_L_E_T_ = ' ' AND SE5.E5_FILIAL = SLW.LW_FILIAL AND (SE5.E5_NUMERO >= SLW.LW_NUMINI AND SE5.E5_NUMERO < SLW.LW_NUMFIM)
				AND SE5.E5_BANCO = SLW.LW_OPERADO AND SE5.E5_DATA >= SLW.LW_DTABERT AND SE5.E5_DATA <= SLW.LW_DTFECHA
			INNER JOIN %table:SAU% SAU ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SE5.E5_FILIAL 
			INNER JOIN %table:SA6% SA6 ON SA6.D_E_L_E_T_ = ' ' AND SA6.A6_COD = SE5.E5_BANCO AND SA6.A6_AGENCIA = SE5.E5_AGENCIA AND SA6.A6_NUMCON = SE5.E5_CONTA
			INNER JOIN %table:SLG% SLG ON SLG.D_E_L_E_T_ = ' ' AND SLG.LG_FILIAL = SE5.E5_FILIAL AND SLG.LG_CODIGO = SLW.LW_ESTACAO AND SLG.LG_PDV = SLW.LW_PDV
			WHERE %exp:cFilAux%
				AND SE5.E5_BANCO BETWEEN 	%exp:mv_par05% 			AND %exp:mv_par06% 
				AND SLW.LW_PDV BETWEEN	 	%exp:mv_par07% 			AND %exp:mv_par08% 
				AND SE5.E5_DATA BETWEEN		%exp:DToS(mv_par09)% 	AND %exp:DToS(mv_par10)% 
				AND SE5.E5_MOEDA = 'TC' AND SE5.E5_NATUREZ = 'TROCO' AND SE5.E5_RECPAG = 'R'
				AND SE5.%notDel%
   			ORDER BY SE5.E5_FILIAL,SA6.A6_COD,SLG.LG_PDV,SE5.E5_DATA,SE5.E5_PREFIXO,SE5.E5_NUMERO 
   			
	    EndSql		
	END REPORT QUERY oSection1
Else
	BEGIN REPORT QUERY oSection1
	
		BeginSql alias cAlias1
			
			SELECT SE5.E5_FILIAL,SA6.A6_COD,SA6.A6_NREDUZ,SLG.LG_PDV,SLG.LG_NOME,SE5.E5_DATA,SE5.E5_PREFIXO,SE5.E5_NUMERO,SE5.E5_VALOR
			FROM 	%table:SE5% SE5
			INNER JOIN %table:SLW% SLW ON SLW.D_E_L_E_T_ = ' ' AND SE5.E5_FILIAL = SLW.LW_FILIAL AND (SE5.E5_NUMERO >= SLW.LW_NUMINI)
				AND SE5.E5_BANCO = SLW.LW_OPERADO AND SE5.E5_DATA >= SLW.LW_DTABERT AND SE5.E5_DATA <= SLW.LW_DTFECHA
			INNER JOIN %table:SA6% SA6 ON SA6.D_E_L_E_T_ = ' ' AND SA6.A6_COD = SE5.E5_BANCO AND SA6.A6_AGENCIA = SE5.E5_AGENCIA AND SA6.A6_NUMCON = SE5.E5_CONTA
			INNER JOIN %table:SLG% SLG ON SLG.D_E_L_E_T_ = ' ' AND SLG.LG_FILIAL = SE5.E5_FILIAL AND SLG.LG_CODIGO = SLW.LW_ESTACAO AND SLG.LG_PDV = SLW.LW_PDV
			WHERE %exp:cFilAux%
				AND SE5.E5_BANCO BETWEEN 	%exp:mv_par05% 			AND %exp:mv_par06% 
				AND SLW.LW_PDV BETWEEN	 	%exp:mv_par07% 			AND %exp:mv_par08% 
				AND SE5.E5_DATA BETWEEN		%exp:DToS(mv_par09)% 	AND %exp:DToS(mv_par10)% 
				AND SE5.E5_MOEDA = 'TC' AND SE5.E5_NATUREZ = 'TROCO' AND SE5.E5_RECPAG = 'R'
				AND SE5.%notDel%
   			ORDER BY SE5.E5_FILIAL,SA6.A6_COD,SLG.LG_PDV,SE5.E5_DATA,SE5.E5_PREFIXO,SE5.E5_NUMERO 
   			
    	EndSql

	END REPORT QUERY oSection1

Endif

oSection2:SetParentQuery()
If lGrpFil .AND. nTipo == 1	// Grupo de Filiais
	oSection2:SetParentFilter( {|G|(cAlias1)->AU_CODGRUP == G }, 	{||(cAlias1)->AU_CODGRUP} )
ElseIf nTipo == 2  			// Filiais
	oSection2:SetParentFilter( {|G|(cAlias1)->E5_FILIAL == G },	{||(cAlias1)->E5_FILIAL} )
ElseIf nTipo == 3  			// Caxias
	oSection2:SetParentFilter( {|G|(cAlias1)->A6_COD == G }, 		{||(cAlias1)->A6_COD} )
ElseIf nTipo == 4  			// PDVs
	oSection2:SetParentFilter( {|G|(cAlias1)->E5_FILIAL+(cAlias1)->LG_PDV == G }, {||(cAlias1)->E5_FILIAL+(cAlias1)->LG_PDV} )
EndIf

oSection1:Print() // processa as informacoes da tabela principal
oReport:SetMeter(&(cAlias1)->(LastRec()))

Return NIL


//-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-Prevencao de Perdas\Comercial\Sangria\...-=-=-=--=-=-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LR7017341  บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrevencao de Perdas\Comercial\Sangria\...                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณRelatorio Personalizavel                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

/*/
Function LR7017341(cTitulo,lGrpFil,nTipo)
Local oReport 	:= NIL				// Objeto para geracao do relatorio
Local aArea 	:= GetArea() 		// Salva a area

Pergunte("LJ7017",.F.) 		// O pergunte deve estar desabilitado 

oReport := L7017341Def(cTitulo,lGrpFil,nTipo)
oReport:PrintDialog()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a areaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea( aArea )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณL7017341Def บAutor  ณTOTVS             บ Data ณ  24/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao das celulas que irao compor o relatorio           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LR7017341                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L7017341Def(cTit,lGrpFil,nTipo)
Local oReport	:= NIL									// Objeto do relatorio
Local oSection1	:= NIL									// Objeto da secao 1
Local oSection2	:= NIL									// Objeto da secao 2
Local oCell		:= NIL									// Objeto Cell TReport
Local oTotaliz	:= NIL									// Objeto totalizador
Local cAlias1	:= GetNextAlias()						// Pega o proximo Alias Disponivel
Local cTitulo	:= ""				                  	// Titulo
Local aFiliais 	:= Lj7017Fil()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera a tela com os dados para a confirma็ใo da geracao do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oReport := TReport():New("LR701733"+AllTrim(STR(nTipo)),STR0002+" - "+STR0047+" - "+STR0058+" - "+cTit,"",{|oReport| L7017341Prt(oReport,cAlias1,lGrpFil,nTipo)},STR0002 )//##"Prevencao de Perdas"##"Comercial"//"Sangria"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine a secao1 do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1 := TRSection():New( oReport,STR0002,{ "SE5" } )	//##"Prevencao de Perdas"
oSection1:SetHeaderBreak(.T.)		//Indica se cabecalho da secao sera impresso em cada quebra 
oSection1:SetHeaderPage(.T.)		//Indica que cabecalho da secao sera impresso no topo da pagina

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cabecalho                                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGrpFil .AND. nTipo == 1 // Grupo de Filiais
	oCell := TRCell():New(oSection1,"cGrpF",,""	,,60,,{||cGrpF:=STR0003+": "	+&(cAlias1)->(AU_CODGRUP)+"-"+&(cAlias1)->(AU_DESCRI) })//Grupo Filial

ElseIf nTipo == 2			// Filiais
	oCell := TRCell():New(oSection1,"cFilial",,""  ,,60,,{||cFilial:=STR0004+": "+LR7017FilNo(&(cAlias1)->(E5_FILIAL),aFiliais) })//Filial

ElseIf nTipo == 3			// Caixas
	oCell := TRCell():New(oSection1,"cCaixa",,""	,,60,,{||cCaixa:=STR0049+": "+&(cAlias1)->(A6_COD)+"-"+&(cAlias1)->(A6_NREDUZ) })//"Caixa"

Else   						// PDVs
	oCell := TRCell():New(oSection1,"cPDV",,""  	,,60,,{||cPDV:=STR0018+": "+&(cAlias1)->(LG_PDV)+"-"+&(cAlias1)->(LG_NOME) })//"PDV"

EndIf

oSection2 := TRSection():New(oSection1,cTitulo,{"cAlias1"})
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderPage(.T.) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine as celulas que irao aparecer na secao2ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nTipo <> 2
	oCell := TRCell():New(oSection2,"E5_FILIAL"		,cAlias1,STR0004 )//Filial
Endif
If lGrpFil .AND. nTipo <> 1
	oCell := TRCell():New(oSection2,"AU_CODGRUP"	,cAlias1,STR0003 )  
	oCell := TRCell():New(oSection2,"AU_DESCRI"		,cAlias1,STR0050 )//"Descr. Grupo Filial"
EndIf
If nTipo <> 3
	oCell := TRCell():New(oSection2,"A6_COD"		,cAlias1,STR0049 )//"Caixa"
	oCell := TRCell():New(oSection2,"A6_NREDUZ"		,cAlias1,STR0051 )//"Nome Caixa"
Endif
If nTipo <> 4
	oCell := TRCell():New(oSection2,"LG_PDV"		,cAlias1,STR0018 )//"PDV"
	oCell := TRCell():New(oSection2,"LG_NOME"		,cAlias1,STR0052 )//Nome PDV
Endif
oCell := TRCell():New(oSection2,"E5_DATA"	   		,cAlias1,STR0028,,10)//"Data"
oCell := TRCell():New(oSection2,"E5_PREFIXO" 		,cAlias1,STR0042 )//"Prefixo"
oCell := TRCell():New(oSection2,"E5_NUMERO"  		,cAlias1,STR0069 )//"Titulo"
oCell := TRCell():New(oSection2,"E5_VALOR"  		,cAlias1,STR0012 )//"Valor"

oTotaliz := TRFunction():new(oSection2:Cell("E5_VALOR")	,,"SUM",,STR0014	,"@E 999,999,999.99") 	//"Total"

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณL7017341Prt บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LR7017341                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L7017341Prt( oReport, cAlias1, lGrpFil, nTipo )
Local oSection1	:= oReport:Section(1)  				// Objeto da secao 1
Local oSection2	:= oReport:Section(1):Section(1)	// Objeto da secao 2		
Local cFilAux 	:= "%" + LJ7017QryFil(.F.,"SE5")[2] + "%" // Filial da query

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
MakeSqlExpr("LJ7017")

oReport:Section(1):BeginQuery()	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa a secao 1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGrpFil
	BEGIN REPORT QUERY oSection1	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณQuery da secao 1ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		BeginSql alias cAlias1

			SELECT SE5.E5_FILIAL,SAU.AU_CODGRUP,SAU.AU_DESCRI,SA6.A6_COD,SA6.A6_NREDUZ,SLG.LG_PDV,SLG.LG_NOME,SE5.E5_DATA,SE5.E5_PREFIXO,SE5.E5_NUMERO,SE5.E5_VALOR
			FROM 	%table:SE5% SE5
			INNER JOIN %table:SLW% SLW ON SLW.D_E_L_E_T_ = ' ' AND SE5.E5_FILIAL = SLW.LW_FILIAL AND (SE5.E5_NUMERO >= SLW.LW_NUMINI AND SE5.E5_NUMERO < SLW.LW_NUMFIM)
				AND SE5.E5_BANCO = SLW.LW_OPERADO AND SE5.E5_DATA >= SLW.LW_DTABERT AND SE5.E5_DATA <= SLW.LW_DTFECHA
			INNER JOIN %table:SAU% SAU ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SE5.E5_FILIAL
			INNER JOIN %table:SA6% SA6 ON SA6.D_E_L_E_T_ = ' ' AND SA6.A6_COD = SE5.E5_BANCO AND SA6.A6_AGENCIA = SE5.E5_AGENCIA AND SA6.A6_NUMCON = SE5.E5_CONTA 
			INNER JOIN %table:SLG% SLG ON SLG.D_E_L_E_T_ = ' ' AND SLG.LG_FILIAL = SE5.E5_FILIAL AND SLG.LG_CODIGO = SLW.LW_ESTACAO AND SLG.LG_PDV = SLW.LW_PDV
			WHERE %exp:cFilAux%
				AND SE5.E5_BANCO BETWEEN 	%exp:mv_par05% 			AND %exp:mv_par06% 
				AND SLW.LW_PDV BETWEEN	 	%exp:mv_par07% 			AND %exp:mv_par08% 
				AND SE5.E5_DATA BETWEEN		%exp:DToS(mv_par09)% 	AND %exp:DToS(mv_par10)% 
				AND SE5.E5_NATUREZ = 'SANGRIA' AND SE5.E5_TIPODOC IN ('SG','TR','TE') AND SE5.E5_RECPAG = 'P'
				AND (SE5.E5_SITUACA <> 'C') AND (SE5.E5_MOEDA <> 'ES') AND SE5.E5_TIPODOC <> 'LJ'
				AND SE5.%notDel%
   			ORDER BY SE5.E5_FILIAL,SA6.A6_COD,SLG.LG_PDV,SE5.E5_DATA,SE5.E5_PREFIXO,SE5.E5_NUMERO
   			
	    EndSql		
	END REPORT QUERY oSection1
Else
	BEGIN REPORT QUERY oSection1
	
		BeginSql alias cAlias1

			SELECT SE5.E5_FILIAL,SA6.A6_COD,SA6.A6_NREDUZ,SLG.LG_PDV,SLG.LG_NOME,SE5.E5_DATA,SE5.E5_PREFIXO,SE5.E5_NUMERO,SE5.E5_VALOR
			FROM 	%table:SE5% SE5
			INNER JOIN %table:SLW% SLW ON SLW.D_E_L_E_T_ = ' ' AND SE5.E5_FILIAL = SLW.LW_FILIAL AND SE5.E5_NUMERO >= SLW.LW_NUMINI
				AND SE5.E5_BANCO = SLW.LW_OPERADO AND SE5.E5_DATA >= SLW.LW_DTABERT AND SE5.E5_DATA <= SLW.LW_DTFECHA
			INNER JOIN %table:SA6% SA6 ON SA6.D_E_L_E_T_ = ' ' AND SA6.A6_COD = SE5.E5_BANCO AND SA6.A6_AGENCIA = SE5.E5_AGENCIA AND SA6.A6_NUMCON = SE5.E5_CONTA 
			INNER JOIN %table:SLG% SLG ON SLG.D_E_L_E_T_ = ' ' AND SLG.LG_FILIAL = SE5.E5_FILIAL AND SLG.LG_CODIGO = SLW.LW_ESTACAO AND SLG.LG_PDV = SLW.LW_PDV
			WHERE %exp:cFilAux%
				AND SE5.E5_BANCO BETWEEN 	%exp:mv_par05% 			AND %exp:mv_par06% 
				AND SLW.LW_PDV BETWEEN	 	%exp:mv_par07% 			AND %exp:mv_par08% 
				AND SE5.E5_DATA BETWEEN		%exp:DToS(mv_par09)% 	AND %exp:DToS(mv_par10)% 
				AND SE5.E5_NATUREZ = 'SANGRIA' AND SE5.E5_TIPODOC IN ('SG','TR','TE') AND SE5.E5_RECPAG = 'P'
				AND (SE5.E5_SITUACA <> 'C') AND (SE5.E5_MOEDA <> 'ES') AND SE5.E5_TIPODOC <> 'LJ'
				AND SE5.%notDel%
   			ORDER BY SE5.E5_FILIAL,SA6.A6_COD,SLG.LG_PDV,SE5.E5_DATA,SE5.E5_PREFIXO,SE5.E5_NUMERO
   			
    	EndSql

	END REPORT QUERY oSection1

Endif

oSection2:SetParentQuery()
If lGrpFil .AND. nTipo == 1	// Grupo de Filiais
	oSection2:SetParentFilter( {|G|(cAlias1)->AU_CODGRUP == G }, 	{||(cAlias1)->AU_CODGRUP} )
ElseIf nTipo == 2			// Filiais
	oSection2:SetParentFilter( {|G|(cAlias1)->E5_FILIAL == G },	{||(cAlias1)->E5_FILIAL} )
ElseIf nTipo == 3			// Caxias
	oSection2:SetParentFilter( {|G|(cAlias1)->A6_COD == G }, 		{||(cAlias1)->A6_COD} )
ElseIf nTipo == 4			// PDVs
	oSection2:SetParentFilter( {|G|(cAlias1)->E5_FILIAL+(cAlias1)->LG_PDV == G }, {||(cAlias1)->E5_FILIAL+(cAlias1)->LG_PDV} )
EndIf

oSection1:Print() // processa as informacoes da tabela principal
oReport:SetMeter(&(cAlias1)->(LastRec()))

Return NIL

//-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-Prevencao de Perdas\Produtividade\M้dia Atendendimento de Vendas\...-=-=-=--=-=-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LR7017411  บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrevencao P.\Produtividade\M้dia Atendendimento de Vendas\... บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณRelatorio Personalizavel                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

/*/
Function LR7017411(cTitulo,lGrpFil,nTipo)
Local oReport 	:= NIL				// Objeto para geracao do relatorio
Local aArea 	:= GetArea() 		// Salva a area

Pergunte("LJ7017",.F.) 		// O pergunte deve estar desabilitado 

oReport := L7017411Def(cTitulo,lGrpFil,nTipo)
oReport:PrintDialog()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a areaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea( aArea )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณL7017411Def บAutor  ณTOTVS             บ Data ณ  24/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao das celulas que irao compor o relatorio           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LR7017411                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L7017411Def(cTit,lGrpFil,nTipo)
Local oReport	:= NIL									// Objeto do relatorio
Local oSection1	:= NIL									// Objeto da secao 1
Local oSection2	:= NIL									// Objeto da secao 2
Local oCell		:= NIL									// Objeto Cell TReport
Local oTotaliz	:= NIL									// Objeto totalizador
Local cAlias1	:= GetNextAlias()						// Pega o proximo Alias Disponivel
Local cTitulo	:= ""				                  	// Titulo
Local aFiliais 	:= Lj7017Fil()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera a tela com os dados para a confirma็ใo da geracao do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oReport := TReport():New("LR701741"+AllTrim(STR(nTipo)),STR0002+" - "+STR0059+" - "+STR0060+" - "+cTit,"",{|oReport| L7017411Prt(oReport,cAlias1,lGrpFil,nTipo)},STR0002 )//##"Prevencao de Perdas"//Produtividade//M้dia Atend. de Vendas

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine a secao1 do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1 := TRSection():New( oReport,STR0002,{ "SL1" } )	//##"Prevencao de Perdas"
oSection1:SetHeaderBreak(.T.)		//Indica se cabecalho da secao sera impresso em cada quebra 
oSection1:SetHeaderPage(.T.)		//Indica que cabecalho da secao sera impresso no topo da pagina

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cabecalho                                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGrpFil .AND. nTipo == 1 // Grupo de Filiais
	oCell := TRCell():New(oSection1,"cGrpF",,""	,,60,,{||cGrpF:=STR0003+": "	+&(cAlias1)->(AU_CODGRUP)+"-"+&(cAlias1)->(AU_DESCRI) })//Grupo Filial

ElseIf nTipo == 2			// Filiais
	oCell := TRCell():New(oSection1,"cFilial",,""  ,,60,,{||cFilial:=STR0004+": "+LR7017FilNo(&(cAlias1)->(L1_FILIAL),aFiliais) })//Filial

ElseIf nTipo == 3			// Caixas
	oCell := TRCell():New(oSection1,"cCaixa",,""	,,60,,{||cCaixa:=STR0049+": "+&(cAlias1)->(A6_COD)+"-"+&(cAlias1)->(A6_NREDUZ) })//"Caixa"

Else   						// PDVs
	oCell := TRCell():New(oSection1,"cPDV",,""  	,,60,,{||cPDV:=STR0018+": "+&(cAlias1)->(LG_PDV)+"-"+&(cAlias1)->(LG_NOME) })//"PDV"

EndIf

oSection2 := TRSection():New(oSection1,cTitulo,{"cAlias1"})
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderPage(.T.) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine as celulas que irao aparecer na secao2ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nTipo <> 2
	oCell := TRCell():New(oSection2,"L1_FILIAL"		,cAlias1,STR0004 )//Filial
Endif
If lGrpFil .AND. nTipo <> 1
	oCell := TRCell():New(oSection2,"AU_CODGRUP"	,cAlias1,STR0003 )//Grupo Filial  
	oCell := TRCell():New(oSection2,"AU_DESCRI"		,cAlias1,STR0050 )//"Descr. Grupo Filial"
EndIf
If nTipo <> 3
	oCell := TRCell():New(oSection2,"A6_COD"		,cAlias1,STR0049 )//"Caixa"
	oCell := TRCell():New(oSection2,"A6_NREDUZ"		,cAlias1,STR0051 )//"Nome Caixa"
Endif
If nTipo <> 4
	oCell := TRCell():New(oSection2,"LG_PDV"		,cAlias1,STR0018 )//"PDV"
	oCell := TRCell():New(oSection2,"LG_NOME"		,cAlias1,STR0052 )//Nome PDV
Endif
oCell := TRCell():New(oSection2,"L1_EMISSAO"   		,cAlias1,STR0061,,10) //Emissao
oCell := TRCell():New(oSection2,"L1_SERIE" 			,cAlias1,STR0015 )//"Serie"
oCell := TRCell():New(oSection2,"L1_DOC" 			,cAlias1,STR0063 )//Documento
oCell := TRCell():New(oSection2,"cMinutos",,STR0062,,15,,{||cMinutos:=LJ7017CvHrs("",&(cAlias1)->(L1_TIMEATE)) })//Horas
oCell := TRCell():New(oSection2,"L1_TIMEATE"  		,cAlias1,STR0064,"@E 999,999,999" ) //Tempo(Seg)

oTotaliz := TRFunction():new(oSection2:Cell("L1_TIMEATE")	,,"AVERAGE",,STR0065	,"@E 999,999,999") 	//M้dia

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณL7017411Prt บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LR7017411                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L7017411Prt( oReport, cAlias1, lGrpFil, nTipo )
Local oSection1	:= oReport:Section(1)  				// Objeto da secao 1
Local oSection2	:= oReport:Section(1):Section(1)	// Objeto da secao 2		
Local cFilAux 	:= "%" + LJ7017QryFil(.F.,"SL1")[2] + "%" // Filial da query

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
MakeSqlExpr("LJ7017")

oReport:Section(1):BeginQuery()	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa a secao 1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGrpFil
	BEGIN REPORT QUERY oSection1	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณQuery da secao 1ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		BeginSql alias cAlias1

			SELECT SL1.L1_FILIAL,SAU.AU_CODGRUP,SAU.AU_DESCRI,SA6.A6_COD,SA6.A6_NREDUZ,SLG.LG_PDV,SLG.LG_NOME,SL1.L1_EMISSAO,
				SL1.L1_NUM,SL1.L1_SERIE,SL1.L1_DOC,SL1.L1_TIMEATE
			FROM 	%table:SL1% SL1
			INNER JOIN %table:SLW% SLW ON SLW.D_E_L_E_T_ = ' ' AND SL1.L1_FILIAL = SLW.LW_FILIAL AND SL1.L1_NUMMOV = SLW.LW_NUMMOV
				AND SL1.L1_PDV = SLW.LW_PDV AND SL1.L1_DOC >= SLW.LW_NUMINI
				AND SL1.L1_EMISSAO >= SLW.LW_DTABERT AND SL1.L1_EMISSAO <= SLW.LW_DTFECHA
			INNER JOIN %table:SAU% SAU ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SL1.L1_FILIAL
			INNER JOIN %table:SA6% SA6 ON SA6.D_E_L_E_T_ = ' ' AND SA6.A6_COD = SLW.LW_OPERADO
			INNER JOIN %table:SLG% SLG ON SLG.D_E_L_E_T_ = ' ' AND SLG.LG_FILIAL = SL1.L1_FILIAL AND SLG.LG_CODIGO = SLW.LW_ESTACAO AND SLG.LG_PDV = SLW.LW_PDV
			WHERE %exp:cFilAux%
				AND SLW.LW_OPERADO BETWEEN 	%exp:mv_par05% 			AND %exp:mv_par06% 
				AND SL1.L1_PDV BETWEEN	 	%exp:mv_par07% 			AND %exp:mv_par08% 
				AND SL1.L1_EMISSAO BETWEEN	%exp:DToS(mv_par09)% 	AND %exp:DToS(mv_par10)% 
				AND SL1.L1_IMPRIME <> ' ' AND SL1.L1_STATUS = ' '
				AND SL1.%notDel%
   			GROUP BY SL1.L1_FILIAL,SAU.AU_CODGRUP,SAU.AU_DESCRI,SA6.A6_COD,SA6.A6_NREDUZ,SLG.LG_PDV,SLG.LG_NOME,SL1.L1_EMISSAO,SL1.L1_NUM,SL1.L1_SERIE,SL1.L1_DOC,SL1.L1_TIMEATE
   			ORDER BY SL1.L1_FILIAL,SA6.A6_COD,SLG.LG_PDV,SL1.L1_EMISSAO
   			
	    EndSql		
	END REPORT QUERY oSection1
Else
	BEGIN REPORT QUERY oSection1
	
		BeginSql alias cAlias1

			SELECT SL1.L1_FILIAL,SA6.A6_COD,SA6.A6_NREDUZ,SLG.LG_PDV,SLG.LG_NOME,SL1.L1_EMISSAO,SL1.L1_NUM,SL1.L1_SERIE,SL1.L1_DOC,SL1.L1_TIMEATE
			FROM 	%table:SL1% SL1
			INNER JOIN %table:SLW% SLW ON SLW.D_E_L_E_T_ = ' ' AND SL1.L1_FILIAL = SLW.LW_FILIAL AND SL1.L1_NUMMOV = SLW.LW_NUMMOV
				AND SL1.L1_PDV = SLW.LW_PDV AND SL1.L1_DOC >= SLW.LW_NUMINI
				AND SL1.L1_EMISSAO >= SLW.LW_DTABERT AND SL1.L1_EMISSAO <= SLW.LW_DTFECHA
			INNER JOIN %table:SA6% SA6 ON SA6.D_E_L_E_T_ = ' ' AND SA6.A6_COD = SLW.LW_OPERADO
			INNER JOIN %table:SLG% SLG ON SLG.D_E_L_E_T_ = ' ' AND SLG.LG_FILIAL = SL1.L1_FILIAL AND SLG.LG_CODIGO = SLW.LW_ESTACAO AND SLG.LG_PDV = SLW.LW_PDV
			WHERE %exp:cFilAux%
				AND SLW.LW_OPERADO BETWEEN 	%exp:mv_par05% 			AND %exp:mv_par06% 
				AND SL1.L1_PDV BETWEEN	 	%exp:mv_par07% 			AND %exp:mv_par08% 
				AND SL1.L1_EMISSAO BETWEEN	%exp:DToS(mv_par09)% 	AND %exp:DToS(mv_par10)% 
				AND SL1.L1_IMPRIME <> ' ' AND SL1.L1_STATUS = ' '
				AND SL1.%notDel%
   			GROUP BY SL1.L1_FILIAL,SA6.A6_COD,SA6.A6_NREDUZ,SLG.LG_PDV,SLG.LG_NOME,SL1.L1_EMISSAO,SL1.L1_NUM,SL1.L1_SERIE,SL1.L1_DOC,SL1.L1_TIMEATE
   			ORDER BY SL1.L1_FILIAL,SA6.A6_COD,SLG.LG_PDV,SL1.L1_EMISSAO
   			
    	EndSql

	END REPORT QUERY oSection1

Endif

oSection2:SetParentQuery()
If lGrpFil .AND. nTipo == 1	// Grupo de Filiais
	oSection2:SetParentFilter( {|G|(cAlias1)->AU_CODGRUP == G }, 	{||(cAlias1)->AU_CODGRUP} )
ElseIf nTipo == 2			// Filiais
	oSection2:SetParentFilter( {|G|(cAlias1)->L1_FILIAL == G },	{||(cAlias1)->L1_FILIAL} )
ElseIf nTipo == 3			// Caxias
	oSection2:SetParentFilter( {|G|(cAlias1)->A6_COD == G }, 		{||(cAlias1)->A6_COD} )
ElseIf nTipo == 4			// PDVs
	oSection2:SetParentFilter( {|G|(cAlias1)->L1_FILIAL+(cAlias1)->LG_PDV == G }, {||(cAlias1)->L1_FILIAL+(cAlias1)->LG_PDV} )
EndIf

oSection1:Print() // processa as informacoes da tabela principal
oReport:SetMeter(&(cAlias1)->(LastRec()))

Return NIL

//-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-Prevencao de Perdas\Produtividade\M้dia Registro Item\...-=-=-=--=-=-=--=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-=-

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LR7017421  บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrevencao P.\Produtividade\M้dia Registro Item\...            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณRelatorio Personalizavel                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

/*/
Function LR7017421(cTitulo,lGrpFil,nTipo)
Local oReport 	:= NIL				// Objeto para geracao do relatorio
Local aArea 	:= GetArea() 		// Salva a area

Pergunte("LJ7017",.F.) 		// O pergunte deve estar desabilitado 

oReport := L7017421Def(cTitulo,lGrpFil,nTipo)
oReport:PrintDialog()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRestaura a areaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea( aArea )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณL7017421Def บAutor  ณTOTVS             บ Data ณ  24/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao das celulas que irao compor o relatorio           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LR7017421                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L7017421Def(cTit,lGrpFil,nTipo)
Local oReport	:= NIL									// Objeto do relatorio
Local oSection1	:= NIL									// Objeto da secao 1
Local oSection2	:= NIL									// Objeto da secao 2
Local oCell		:= NIL									// Objeto Cell TReport
Local oTotaliz	:= NIL									// Objeto totalizador
Local cAlias1	:= GetNextAlias()						// Pega o proximo Alias Disponivel
Local cTitulo	:= ""				                  	// Titulo
Local aFiliais 	:= Lj7017Fil()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera a tela com os dados para a confirma็ใo da geracao do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oReport := TReport():New("LR701742"+AllTrim(STR(nTipo)),STR0002+" - "+STR0059+" - "+STR0070+" - "+cTit,"",{|oReport| L7017421Prt(oReport,cAlias1,lGrpFil,nTipo)},STR0002 )//##"Prevencao de Perdas"//"Produtividade"//"M้dia Registro Item"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine a secao1 do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1 := TRSection():New( oReport,STR0002,{ "SL1" } )	//##"Prevencao de Perdas"
oSection1:SetHeaderBreak(.T.)		//Indica se cabecalho da secao sera impresso em cada quebra 
oSection1:SetHeaderPage(.T.)		//Indica que cabecalho da secao sera impresso no topo da pagina

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cabecalho                                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGrpFil .AND. nTipo == 1 // Grupo de Filiais
	oCell := TRCell():New(oSection1,"cGrpF",,""	,,60,,{||cGrpF:=STR0003+": "	+&(cAlias1)->(AU_CODGRUP)+"-"+&(cAlias1)->(AU_DESCRI) })//Grupo Filial

ElseIf nTipo == 2			// Filiais
	oCell := TRCell():New(oSection1,"cFilial",,""  ,,60,,{||cFilial:=STR0004+": "+LR7017FilNo(&(cAlias1)->(L1_FILIAL),aFiliais) })//Filial

ElseIf nTipo == 3			// Caixas
	oCell := TRCell():New(oSection1,"cCaixa",,""	,,60,,{||cCaixa:=STR0049+": "+&(cAlias1)->(A6_COD)+"-"+&(cAlias1)->(A6_NREDUZ) })//"Caixa"

Else   						// PDVs
	oCell := TRCell():New(oSection1,"cPDV",,""  	,,60,,{||cPDV:=STR0018+": "+&(cAlias1)->(LG_PDV)+"-"+&(cAlias1)->(LG_NOME) })//"PDV"

EndIf

oSection2 := TRSection():New(oSection1,cTitulo,{"cAlias1"})
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderPage(.T.) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine as celulas que irao aparecer na secao2ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nTipo <> 2
	oCell := TRCell():New(oSection2,"L1_FILIAL"		,cAlias1,STR0004 )//Filial
Endif
If lGrpFil .AND. nTipo <> 1
	oCell := TRCell():New(oSection2,"AU_CODGRUP"	,cAlias1,STR0003 )//Grupo Filial
	oCell := TRCell():New(oSection2,"AU_DESCRI"		,cAlias1,STR0050 )//"Descr. Grupo Filial"
EndIf
If nTipo <> 3
	oCell := TRCell():New(oSection2,"A6_COD"		,cAlias1,STR0049 )//"Caixa"
	oCell := TRCell():New(oSection2,"A6_NREDUZ"		,cAlias1,STR0051 )//"Nome Caixa"
Endif
If nTipo <> 4
	oCell := TRCell():New(oSection2,"LG_PDV"		,cAlias1,STR0018 )//"PDV"
	oCell := TRCell():New(oSection2,"LG_NOME"		,cAlias1,STR0052 )//Nome PDV
Endif
oCell := TRCell():New(oSection2,"L1_EMISSAO"   		,cAlias1,STR0061,,10) //Emissao
oCell := TRCell():New(oSection2,"L1_SERIE" 			,cAlias1,STR0015 )//"Serie"
oCell := TRCell():New(oSection2,"L1_DOC" 			,cAlias1,STR0063 )//Documento
oCell := TRCell():New(oSection2,"cMinutos",,STR0062,,15,,{||cMinutos:=LJ7017CvHrs("",&(cAlias1)->(L1_TIMEITE)) })//Horas
oCell := TRCell():New(oSection2,"L1_TIMEITE"  		,cAlias1,STR0064,"@E 999,999,999" ) //Tempo(Seg)

oTotaliz := TRFunction():new(oSection2:Cell("L1_TIMEITE")	,,"AVERAGE",,STR0065	,"@E 999,999,999") 	//M้dia

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณL7017421Prt บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LR7017421                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L7017421Prt( oReport, cAlias1, lGrpFil, nTipo )
Local oSection1	:= oReport:Section(1)  				// Objeto da secao 1
Local oSection2	:= oReport:Section(1):Section(1)	// Objeto da secao 2		
Local cFilAux 	:= "%" + LJ7017QryFil(.F.,"SL1")[2] + "%" // Filial da query

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTransforma parametros do tipo Range em expressao SQL para ser utilizada na query ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
MakeSqlExpr("LJ7017")

oReport:Section(1):BeginQuery()	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa a secao 1ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGrpFil
	BEGIN REPORT QUERY oSection1	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณQuery da secao 1ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		BeginSql alias cAlias1

			SELECT SL1.L1_FILIAL,SAU.AU_CODGRUP,SAU.AU_DESCRI,SA6.A6_COD,SA6.A6_NREDUZ,SLG.LG_PDV,SLG.LG_NOME,SL1.L1_EMISSAO,
				SL1.L1_NUM,SL1.L1_SERIE,SL1.L1_DOC,SL1.L1_TIMEITE
			FROM 	%table:SL1% SL1
			INNER JOIN %table:SLW% SLW ON SLW.D_E_L_E_T_ = ' ' AND SL1.L1_FILIAL = SLW.LW_FILIAL AND SL1.L1_NUMMOV = SLW.LW_NUMMOV
				AND SL1.L1_PDV = SLW.LW_PDV AND SL1.L1_DOC >= SLW.LW_NUMINI
				AND SL1.L1_EMISSAO >= SLW.LW_DTABERT AND SL1.L1_EMISSAO <= SLW.LW_DTFECHA
			INNER JOIN %table:SAU% SAU ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SL1.L1_FILIAL
			INNER JOIN %table:SA6% SA6 ON SA6.D_E_L_E_T_ = ' ' AND SA6.A6_COD = SLW.LW_OPERADO
			INNER JOIN %table:SLG% SLG ON SLG.D_E_L_E_T_ = ' ' AND SLG.LG_FILIAL = SL1.L1_FILIAL AND SLG.LG_CODIGO = SLW.LW_ESTACAO AND SLG.LG_PDV = SLW.LW_PDV
			WHERE %exp:cFilAux%
				AND SLW.LW_OPERADO BETWEEN 	%exp:mv_par05% 			AND %exp:mv_par06% 
				AND SL1.L1_PDV BETWEEN	 	%exp:mv_par07% 			AND %exp:mv_par08% 
				AND SL1.L1_EMISSAO BETWEEN	%exp:DToS(mv_par09)% 	AND %exp:DToS(mv_par10)% 
				AND SL1.L1_IMPRIME <> ' ' AND SL1.L1_STATUS = ' '
				AND SL1.%notDel%
   			GROUP BY SL1.L1_FILIAL,SAU.AU_CODGRUP,SAU.AU_DESCRI,SA6.A6_COD,SA6.A6_NREDUZ,SLG.LG_PDV,SLG.LG_NOME,SL1.L1_EMISSAO,SL1.L1_NUM,SL1.L1_SERIE,SL1.L1_DOC,SL1.L1_TIMEITE
   			ORDER BY SL1.L1_FILIAL,SA6.A6_COD,SLG.LG_PDV,SL1.L1_EMISSAO
   			
	    EndSql		
	END REPORT QUERY oSection1
Else
	BEGIN REPORT QUERY oSection1
	
		BeginSql alias cAlias1

			SELECT SL1.L1_FILIAL,SA6.A6_COD,SA6.A6_NREDUZ,SLG.LG_PDV,SLG.LG_NOME,SL1.L1_EMISSAO,SL1.L1_NUM,SL1.L1_SERIE,SL1.L1_DOC,SL1.L1_TIMEITE
			FROM 	%table:SL1% SL1
			INNER JOIN %table:SLW% SLW ON SLW.D_E_L_E_T_ = ' ' AND SL1.L1_FILIAL = SLW.LW_FILIAL AND SL1.L1_NUMMOV = SLW.LW_NUMMOV
				AND SL1.L1_PDV = SLW.LW_PDV AND SL1.L1_DOC >= SLW.LW_NUMINI
				AND SL1.L1_EMISSAO >= SLW.LW_DTABERT AND SL1.L1_EMISSAO <= SLW.LW_DTFECHA
			INNER JOIN %table:SA6% SA6 ON SA6.D_E_L_E_T_ = ' ' AND SA6.A6_COD = SLW.LW_OPERADO
			INNER JOIN %table:SLG% SLG ON SLG.D_E_L_E_T_ = ' ' AND SLG.LG_FILIAL = SL1.L1_FILIAL AND SLG.LG_CODIGO = SLW.LW_ESTACAO AND SLG.LG_PDV = SLW.LW_PDV
			WHERE %exp:cFilAux%
				AND SLW.LW_OPERADO BETWEEN 	%exp:mv_par05% 			AND %exp:mv_par06% 
				AND SL1.L1_PDV BETWEEN	 	%exp:mv_par07% 			AND %exp:mv_par08% 
				AND SL1.L1_EMISSAO BETWEEN	%exp:DToS(mv_par09)% 	AND %exp:DToS(mv_par10)% 
				AND SL1.L1_IMPRIME <> ' ' AND SL1.L1_STATUS = ' '
				AND SL1.%notDel%
   			GROUP BY SL1.L1_FILIAL,SA6.A6_COD,SA6.A6_NREDUZ,SLG.LG_PDV,SLG.LG_NOME,SL1.L1_EMISSAO,SL1.L1_NUM,SL1.L1_SERIE,SL1.L1_DOC,SL1.L1_TIMEITE
   			ORDER BY SL1.L1_FILIAL,SA6.A6_COD,SLG.LG_PDV,SL1.L1_EMISSAO
   			
    	EndSql

	END REPORT QUERY oSection1

Endif

oSection2:SetParentQuery()
If lGrpFil .AND. nTipo == 1	// Grupo de Filiais
	oSection2:SetParentFilter( {|G|(cAlias1)->AU_CODGRUP == G }, 	{||(cAlias1)->AU_CODGRUP} )
ElseIf nTipo == 2			// Filiais
	oSection2:SetParentFilter( {|G|(cAlias1)->L1_FILIAL == G },	{||(cAlias1)->L1_FILIAL} )
ElseIf nTipo == 3			// Caxias
	oSection2:SetParentFilter( {|G|(cAlias1)->A6_COD == G }, 		{||(cAlias1)->A6_COD} )
ElseIf nTipo == 4			// PDVs
	oSection2:SetParentFilter( {|G|(cAlias1)->L1_FILIAL+(cAlias1)->LG_PDV == G }, {||(cAlias1)->L1_FILIAL+(cAlias1)->LG_PDV} )
EndIf

oSection1:Print() // processa as informacoes da tabela principal
oReport:SetMeter(&(cAlias1)->(LastRec()))

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLR7017FilNo บAutor  ณTOTVS               บ Data ณ  24/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para impressao do relatorio personalizavel             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LR7017                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LR7017FilNo(cFil,aFil)
Local cRet := ""
Local nPos := aScan( aFil, {|xVar| AllTrim(xVar[1]) == AllTrim(cFil)})

cRet := AllTrim(cFil) +" - "+ AllTrim(aFil[nPos][2])
Return cRet
