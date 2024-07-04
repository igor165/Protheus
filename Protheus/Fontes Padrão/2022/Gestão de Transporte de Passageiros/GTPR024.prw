#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOTVS.ch"

#define DMPAPER_A4 
//------------------------------------------------------------------------------  
/*/{Protheus.doc} GTPR024  
Relatorio Relação de Contratos - Viagens Especiais
@sample 	 GTPR024()  
@return	 Nil  
@author	 fabio.veiga
@since	 13/09/2018  
@version	 P12  
@comments
/*///------------------------------------------------------------------------------
Function GTPR024()
	
	Local cPerg := "GTPR024"
	Private oReport	
	
		If Pergunte(cPerg,.T.)
			
			oReport := ReportDef(  )
			oReport:PrintDialog()
		EndIf
Return
//------------------------------------------------------------------------------  
/*/{Protheus.doc} ReportDef  
Defini‡äes de Relatorio  
@sample 	 ReportDef(cAliasTmp)   
@return	 Nil  
@author	 SI4503 - Marcio Martins Pereira    
@since	 12/02/2016  
@version	 P12  
@comments  
/*///------------------------------------------------------------------------------ 
Static Function ReportDef()
	
	Local oReport
	Local oSecCbEx
	Local oSection1
	Local oSection2
	Local oSection3
	Local oBreak
	Local cPerg := "GTPR024"
	Local cTitulo 	:= "[GTPR024] - Relatorio de Relação de Contratos"
	Local cAliasTmp	 := GetNextAlias()
	Public aFilial	 := {}
	
		QryContratos(@cAliasTmp)

		SX3->(DBSETORDER(1))
		 
		oReport := TReport():New('GTPR024', cTitulo,cPerg, {|oReport| PrintReport(oReport,cAliasTmp)}, "Este relatório ira imprimir a Relação de Contratos",,,.T.  )
		
		oReport:SetTotalInLine(.F.)
		oReport:SetLeftMargin(05)
						
		oSecCbEx := TRSection():New( oReport, "DATAINI" ,{cAliasTmp} )//"Datas"
		TRCell():New(oSecCbEx, "DATAINI"	, cAliasTmp, 'Data de:'  ,"@!",10)
		TRCell():New(oSecCbEx, "DATAFIM"	, cAliasTmp, 'Data até:' ,"@!",10)
		TRCell():New(oSecCbEx, "CLIENTE"	, cAliasTmp, 'Cliente.:' ,"@!",30)
		
		oSection1 := TRSection():New(oReport, "LINHA1"	, 	{cAliasTmp}  , , .F., .T.)
		oSection2 := TRSection():New(oReport, "LINHA2"	, 	{cAliasTmp}  , , .F., .T.)
		oSection3 := TRSection():New(oReport, "TOTAL"	,			 , , .F., .T.)
		
		TRCell():New(oSection1	, "CONTRATO"	, cAliasTmp	, "N° Contrato....:" 				, /*Picture*/			, /*Tamanho*/	, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.T.)
	    TRCell():New(oSection1	, "EMPFILCXA"	, cAliasTmp	, "Empresa/Filial:"					, /*Picture*/			, /*Tamanho*/	, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)
	    TRCell():New(oSection1	, "FORMULARIO"	, cAliasTmp	, "Form.:"							, /*Picture*/			, /*Tamanho*/	, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)
	    TRCell():New(oSection1	, "SERIE"		, cAliasTmp	, "Série:"							, /*Picture*/			, /*Tamanho*/	, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)
	    TRCell():New(oSection1	, "CODFISCAL"	, cAliasTmp	, "Cód. Fiscal:"					, /*Picture*/			, /*Tamanho*/	, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)
	    TRCell():New(oSection1	, "ORCAMENTO"	, cAliasTmp	, "Ref. ao orçamento:"				, /*Picture*/			, 9				, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)
	    TRCell():New(oSection1	, "PRECO_KM"	, cAliasTmp	, "R$/KM:"							, "@E 999,999,999.99"	, /*Tamanho*/	, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)
	    TRCell():New(oSection1	, "INICONTRATO"	, cAliasTmp	, "Ini. Contrato:"					, /*Picture*/			, 16			, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)
	    TRCell():New(oSection1	, "FIMCONTRATO"	, cAliasTmp	, "Fim Contrato:"					, /*Picture*/			, 16			, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)
	    TRCell():New(oSection1	, "QTD_VEIC"	, cAliasTmp	, "N° Carros:"						, /*Picture*/			, /*Tamanho*/	, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)
	    TRCell():New(oSection1	, "VAZIO"		, cAliasTmp	, ""								, /*Picture*/			, 36	, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)	    
    	TRCell():New(oSection2	, "PASSAGEIROS"	, cAliasTmp	, "Passageiros...:"					, /*Picture*/			, /*Tamanho*/	, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.F.			,/*cHeaderAlign */,.F.,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)
	    TRCell():New(oSection2	, "KM_PREVISTA"	, cAliasTmp	, "KM prevista:"					, "@!"/*Picture*/		, 10/*Tamanho*/	, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.F.			,/*cHeaderAlign */,.F.,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)	    
    	TRCell():New(oSection2	, "CLIENTE"		, cAliasTmp	, "Cliente:"						, "@!"			, 50			, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.F.			,/*cHeaderAlign */,.F.,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)
    	TRCell():New(oSection2	, "ITINERARIO"	, cAliasTmp	, "Itinerário:"						, /*Picture*/			, 40			, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.F.			,/*cHeaderAlign */,.F.,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)
    	TRCell():New(oSection2	, "VALOR"		, cAliasTmp	, "Valor:"							, "@E 999,999,999.99"	, 10			, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.F.			,/*cHeaderAlign */,.F.,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,.F.)

		oBreak := TRBreak():New(oSection1,oSection1:Cell("CONTRATO"))
		 
        TRFunction():New(oSection2:Cell("VALOR")		,,"COUNT"	,,"QTd. Contratos.","@!",,.F.,.T.)     	
        TRFunction():New(oSection2:Cell("KM_PREVISTA")	,,"SUM"		,,"KM Total.......",,,.F.,.T.)
        TRFunction():New(oSection2:Cell("VALOR")		,,"SUM"		,,"R$ Total.......",,,.F.,.T.)
    	
            
Return (oReport)

//------------------------------------------------------------------------------  
/*/{Protheus.doc} PrintReport  
ImpressÆo de Relat¢rio   
@sample 	 PrintReport(oReport)  
@return	 Nil  
@author	 SI4503 - Marcio Martins Pereira     
@since	 12/02/2016
@version	 P12  
@comments  
/*///------------------------------------------------------------------------------
Static Function PrintReport( oReport,cAliasTmp, cTmpTaxa, cTmpDesc, cTmpBoni  )
 
	Local oSecCbEx	:= oReport:Section(1)
	Local oSection1 := oReport:Section(2)
	Local oSection2 := oReport:Section(3)
	Local lCabec	:= .T.
	Local cMV_PAR03	:= AllTrim(MV_PAR03)

	DbSelectArea(cAliasTmp)
	(cAliasTmp)->(dbGoTop())
	oReport:SetMeter((cAliasTmp)->(RecCount()))
	oReport:SetLineHeight(30)
	oReport:lUnderLine := .F.
	oReport:SetTotalInLine(.T.)

	oSecCbEx:Init()		
	
	oSecCbEx:Cell("DATAINI")		:SetValue(MV_PAR01)
	oSecCbEx:Cell("DATAINI")		:SetBorder("BOTTOM",0,0,.T.)
	
	oSecCbEx:Cell("DATAFIM")		:SetValue(MV_PAR02)
	oSecCbEx:Cell("DATAFIM")		:SetBorder("BOTTOM",0,0,.T.)
	
	If cMV_PAR03 == ""
		oSecCbEx:Cell("CLIENTE")		:SetValue("TODOS")
	Else
		oSecCbEx:Cell("CLIENTE")		:SetValue(MV_PAR03)
	Endif		
	
	oSecCbEx:Cell("CLIENTE")		:SetBorder("BOTTOM",0,0,.T.)

	oSecCbEx:PrintLine()
	
	While (cAliasTmp)->(!Eof())
		
		If oReport:Cancel()
			Exit
		EndIf
		
		oReport:IncMeter()

		oSection1:init()
		oSection1:lPrintHeader := lCabec
			oSection1:Cell("CONTRATO")		:SetValue((cAliasTmp)->CONTRATO)
			oSection1:Cell("CONTRATO")		:SetBorder("TOP"	,1,0,.T.)				
			oSection1:Cell("CONTRATO")		:SetBorder("BOTTOM"	,0,0,.T.)
			
			oSection1:Cell("EMPFILCXA")		:SetValue((cAliasTmp)->EMPFILCXA)
			oSection1:Cell("EMPFILCXA")		:SetBorder("TOP"	,1,0,.T.)				
			oSection1:Cell("EMPFILCXA")		:SetBorder("BOTTOM"	,0,0,.T.)				
			
			oSection1:Cell("FORMULARIO")	:SetValue((cAliasTmp)->FORMULARIO)
			oSection1:Cell("FORMULARIO")	:SetBorder("TOP"	,1,0,.T.)				
			oSection1:Cell("FORMULARIO")	:SetBorder("BOTTOM"	,0,0,.T.)				
			
			oSection1:Cell("SERIE")			:SetValue((cAliasTmp)->SERIE)
			oSection1:Cell("SERIE")			:SetBorder("TOP"	,1,0,.T.)				
			oSection1:Cell("SERIE")			:SetBorder("BOTTOM"	,0,0,.T.)
							
			oSection1:Cell("CODFISCAL")		:SetValue((cAliasTmp)->CODFISCAL)
			oSection1:Cell("CODFISCAL")		:SetBorder("TOP"	,1,0,.T.)				
			oSection1:Cell("CODFISCAL")		:SetBorder("BOTTOM"	,0,0,.T.)				
			
			oSection1:Cell("ORCAMENTO")		:SetValue((cAliasTmp)->ORCAMENTO)
			oSection1:Cell("ORCAMENTO")		:SetBorder("TOP"	,1,0,.T.)				
			oSection1:Cell("ORCAMENTO")		:SetBorder("BOTTOM"	,0,0,.T.)								
			
			oSection1:Cell("PRECO_KM")		:SetValue((cAliasTmp)->PRECO_KM)
			oSection1:Cell("PRECO_KM")		:SetBorder("TOP"	,1,0,.T.)				
			oSection1:Cell("PRECO_KM")		:SetBorder("BOTTOM"	,0,0,.T.)				
			
			oSection1:Cell("INICONTRATO")	:SetValue((cAliasTmp)->INICONTRATO)
			oSection1:Cell("INICONTRATO")	:SetBorder("TOP"	,1,0,.T.)				
			oSection1:Cell("INICONTRATO")	:SetBorder("BOTTOM"	,0,0,.T.)
							
			oSection1:Cell("FIMCONTRATO")	:SetValue((cAliasTmp)->FIMCONTRATO)
			oSection1:Cell("FIMCONTRATO")	:SetBorder("TOP"	,1,0,.T.)				
			oSection1:Cell("FIMCONTRATO")	:SetBorder("BOTTOM"	,0,0,.T.)				
			
			oSection1:Cell("QTD_VEIC")		:SetValue((cAliasTmp)->QTD_VEIC)
			oSection1:Cell("QTD_VEIC")		:SetBorder("TOP"	,1,0,.T.)				
			oSection1:Cell("QTD_VEIC")		:SetBorder("BOTTOM"	,0,0,.T.)
			
			oSection1:Cell("VAZIO")		:SetValue("")
			oSection1:Cell("VAZIO")		:SetBorder("TOP"	,1,0,.T.)				
			oSection1:Cell("VAZIO")		:SetBorder("BOTTOM"	,0,0,.T.)			
			
		oSection1:PrintLine()
					
		oSection2:init()
		oSection2:lPrintHeader := .T.			
			oSection2:Cell("PASSAGEIROS")	:SetValue((cAliasTmp)->PASSAGEIROS)
			oSection2:Cell("PASSAGEIROS")	:SetBorder("BOTTOM",0,0,.T.)

			oSection2:Cell("KM_PREVISTA")	:SetValue((cAliasTmp)->KM_PREVISTA)
			oSection2:Cell("KM_PREVISTA")	:SetBorder("BOTTOM",0,0,.T.)


				oSection2:Cell("CLIENTE")	:SetValue((cAliasTmp)->CLIENTE)

						
			oSection2:Cell("CLIENTE")		:SetBorder("BOTTOM",0,0,.T.)

			oSection2:Cell("ITINERARIO")	:SetValue((cAliasTmp)->ITINERARIO)
			oSection2:Cell("ITINERARIO")	:SetBorder("BOTTOM",0,0,.T.)
			
			oSection2:Cell("VALOR")			:SetValue((cAliasTmp)->VALOR)
			oSection2:Cell("VALOR")			:SetBorder("BOTTOM",0,0,.T.)
		oSection2:PrintLine()

		(cAliasTmp)->(dbSkip())

	Enddo

	oSection1:Finish()
	oSection2:Finish()
	oSecCbEx:Finish()

Return
/*/{Protheus.doc} QryContratos
Consulta as taxas
@type function
@author crisf
@since 01/12/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------
Static Function QryContratos(cTmpAlias)
 	
Local cMV_PAR03		:= AllTrim(MV_PAR03)
Local cWhere		:= If (cMV_PAR03 <> ''," AND ADY.ADY_CLIENT = '" + MV_PAR03 + "' " , '')
 	
cWhere  := '% '+ cWhere  + ' %'
	 	
BeginSql Alias cTmpAlias
    SELECT	ADY_PROPOS CONTRATO 
	,%exp:AllTrim(cEmpAnt)% + '/' + ADY.ADY_FILIAL EMPFILCXA
	,'1' FORMULARIO
	,'UNICA' SERIE
	,'5331' CODFISCAL
	,ADY.ADY_OPORTU ORCAMENTO
    ,(ADZ.ADZ_TOTAL + GIO.GIO_VALTOT) / GIP.GIP_KMCONT PRECO_KM
    
	,LTRIM(RTRIM(CONVERT(CHAR,CAST(GIN.GIN_DSAIDA AS DATETIME),103))) + ' ' + SUBSTRING(GIN.GIN_HSAIDA,1,2) + ':' + SUBSTRING(GIN.GIN_HSAIDA,3,2) 
	AS INICONTRATO	        

	,LTRIM(RTRIM(CONVERT(CHAR,CAST(     GIN2.GIN_DCHEGA AS DATETIME),103))) + ' ' + SUBSTRING(GIN2.GIN_HCHEGA,1,2) + ':' + SUBSTRING(GIN2.GIN_HCHEGA,3,2)
	AS FIMCONTRATO		

	,GIP.GIP_QUANT QTD_VEIC
	,GIP.GIP_QUANT * GIP.GIP_POLTR PASSAGEIROS
	,GIP.GIP_KMCONT KM_PREVISTA
	,SA1.A1_NOME CLIENTE

	,(SELECT LTRIM(RTRIM(GI1.GI1_DESCRI)) FROM %Table:GI1% GI1 WHERE  GI1.GI1_COD = GIN.GIN_LOCOR ) + ' > ' + (SELECT LTRIM(RTRIM(GI2.GI1_DESCRI)) FROM %Table:GI1% GI2 WHERE  GI2.GI1_COD = GIN.GIN_LOCDES)
	+ ' > ' + (SELECT LTRIM(RTRIM(GI3.GI1_DESCRI)) FROM %Table:GI1% GI3 WHERE  GI3.GI1_COD = GIN.GIN_LOCOR ) ITINERARIO
	
	,ADZ.ADZ_TOTAL + GIO.GIO_VALTOT VALOR		

	FROM %Table:ADY% ADY 
	
	INNER JOIN %Table:GIN% GIN ON 
		GIN.GIN_FILIAL = ADY.ADY_FILIAL  
		AND GIN.GIN_PROPOS = ADY.ADY_PROPOS 
		AND GIN.%NotDel%
	
	INNER JOIN %Table:GIN% GIN2 ON 
		GIN2.GIN_FILIAL = ADY.ADY_FILIAL 
		AND GIN2.GIN_PROPOS = ADY.ADY_PROPOS 
		AND GIN2.%NotDel%
		 
	INNER JOIN %Table:ADZ% ADZ 
		ON ADZ.ADZ_FILIAL = ADY.ADY_FILIAL 
		AND ADZ.ADZ_PROPOS = ADY.ADY_PROPOS
		AND ADZ.%NotDel%
		
	INNER JOIN %Table:GIP% GIP 
		ON GIP.GIP_FILIAL = ADY.ADY_FILIAL 
		AND GIP.GIP_PROPOS = ADY.ADY_PROPOS
		AND GIP.%NotDel%
		 
	INNER JOIN %Table:GIO% GIO 
		ON GIO.GIO_FILIAL = ADY.ADY_FILIAL 
		AND GIO.GIO_PROPOS = ADY.ADY_PROPOS
		AND GIO.%NotDel%
		 
	INNER JOIN %Table:SA1% SA1 
		ON SA1.A1_FILIAL = %xFilial:SA1%
		AND SA1.A1_COD = ADY.ADY_CLIENT
		AND SA1.%NotDel%

	WHERE ADY.ADY_DATA >= %exp:MV_PAR01%
	AND ADY.ADY_DATA <= %exp:MV_PAR02%
	AND ADY.%NotDel%
	%exp:cWhere%		
	 
	GROUP BY ADY_PROPOS, ADY.ADY_FILIAL, ADY.ADY_OPORTU, GIP.GIP_QUANT, GIP.GIP_POLTR, GIP.GIP_KMCONT, SA1.A1_NOME, GIN.GIN_FILIAL, GIN.GIN_LOCOR, GIN.GIN_LOCDES, ADZ.ADZ_TOTAL,GIN.GIN_DSAIDA, GIN.GIN_HSAIDA, GIN2.GIN_DCHEGA, GIN2.GIN_HCHEGA,  GIN.GIN_ITEM, GIO.GIO_VALTOT	        
EndSql
  	
Return
