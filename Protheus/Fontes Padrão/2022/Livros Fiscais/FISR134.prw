#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FWCOMMAND.CH"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} FISR134
 
Relat�rio de demonstrativo de Vendas Fora do Estabelecimento
Estado de Goi�s - (Anexo XII, art. 28, � 4�, III)
 
@author Graziele Mendon�a Paro
@since 09/06/2017

/*/
//-------------------------------------------------------------------
Function FISR134()

Local   oReport
Local	 lProblem := .F.
	
	IF Pergunte('FISR134', .T.)  
        oReport := reportDef('FISR134')
        oReport:printDialog() 
    EndIf      

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
 
Fun��o respons�vel para impress�o do relat�rio, que ir� fazer o la�o nas filiais
imprimindo as se��es pertinentes.
 
@author Graziele Mendon�a Paro
@since 09/06/2017
@return oReport - Objeto - Objeto do relat�rio Treport

/*/	
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)              

local oSecao1   := oReport:Section(1) //Remessas para venda fora do estabelecimento
Local oSecao2   := oReport:Section(2) //Vendas fora do estabelecimento do estado de Goi�s
Local oSecao3   := oReport:Section(3) //Vendas fora do Estabelecimento em Outros Estados
Local oSecao4   := oReport:Section(4) //Imposto Pago em outro Estado
Local oSecao5   := oReport:Section(5) //Nota Fiscal pela entrada de mercadoria n�o entregue.

//APURA��O DO IMPOSTO A CREDITAR // N�o ser� desenvolvido neste momento. Pois n�o temos informa��es suficientes.
Local dDataDe   := MV_PAR01
Local dDataAte  := MV_PAR02
Local aAreaSM0  := SM0->(GetArea())
local aFilial   := {}
Local cAliasSFT := GetNextAlias()
Local nContFil  := 0

aFilial        := GetFilial()

If len(aFilial) ==0
    MsgAlert('Nenhuma filial foi selecionada, o processamento n�o ser� realizado.')
Else
	For nContFil := 1 to Len(aFilial)		
		SM0->(DbGoTop ())
		SM0->(MsSeek (aFilial[nContFil][1]+aFilial[nContFil][2], .T.))	//Pego a filial mais proxima
		cFilAnt := FWGETCODFILIAL
    	
    	PrintRem(oReport,oSecao1, dDataDe,dDataAte)  
    	PrtInterno(oReport,oSecao2, dDataDe, dDataAte)
    	PrtForaEst(oReport,oSecao3, dDataDe, dDataAte)
    	ImpPagoFor(oReport,oSecao4, dDataDe, dDataAte)
    	PrtMercNE(oReport,oSecao5, dDataDe, dDataAte)
    	
    Next nContFil
	
	RestArea (aAreaSM0)
	cFilAnt := FWGETCODFILIAL
Endif


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
 
Fun��o que ir� criar a estrutura do relat�rio, com as defini��es de cada se��o,
quebras, somat�rios etc.
 
@author Graziele Mendon�a Paro
@since 09/06/2017

/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)
    
Local cTitle  := "Demonstrativo de Vendas Fora do Estabelecimento - Estado de Goi�s"
Local cHelp   := "Listagem das vendas realizadas fora do Estabelecimento - DEFO (Anexo XII, art. 28, � 4�, III)"
Local oReport
Local oSecao1
Local oSecao2
Local oSecao3
Local oSecao4
Local oSecao5
    
    oReport := TReport():New('FISR134',cTitle,cPerg,{|oReport|ReportPrint(oReport)},cHelp)
    //Define a orienta��o de p�gina do relat�rio como retrato
    oReport:SetPortrait()
    
    //Primeira se��o: Remessa para venda fora do estabelecimento
     oSecao1 := TRSection():New(oReport)	
    //Define se imprime cabe�alho das c�lulas na quebra de se��o
    oSecao1:SetHeaderSection(.T.)

    //Cria��o das celulas da se��o do relat�rio
    TRCell():New(oSecao1,"FT_FILIAL","",'Filial',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao1,"FT_NFISCAL","",'Documento',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao1,"FT_SERIE"  ,"",'Serie',"!!!",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao1,"FT_EMISSAO","",'Emissao',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao1,"FT_CLIEFOR","",'Cli/Forn',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao1,"FT_LOJA"   ,"",'Loja',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao1,"VALCONT","",'Val. Contabil',"@E 99,999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao1,"VALICM" ,"",'Valor ICMS',"@E 99,999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

    oBreak := TRBreak():New(oSecao1,oSecao1:Cell("FT_FILIAL"),"Totalizadores",.F.,'Totalizadores',.T.)
    TRFunction():New(oSecao1:Cell("VALCONT"),NIL,"SUM",oBreak,'Val.Cont�bil',,,.F.,.F.)
    TRFunction():New(oSecao1:Cell("VALICM"),NIL,"SUM",oBreak,'Val.ICMS',,,.F.,.F.)

    oSecao1:SetHeaderBreak(.T.) //Imprime cabe�alho das c�lulas ap�s quebra
    oSecao1:SetPageBreak(.T.) //Pula de p�gina ap�s quebra
    oSecao1:SetHeaderSection(.T.)
    

    //Segunda se��o: Vendas Fora do Estabelecimento no Estado de Goi�s
    oSecao2 := TRSection():New(oReport)
    //Define se imprime cabe�alho das c�lulas na quebra de se��o
    oSecao2:SetHeaderSection(.T.)

    //Cria��o das celulas da se��o do relat�rio
    TRCell():New(oSecao2,"FT_FILIAL","",'Filial',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao2,"FT_NFISCAL","",'Documento',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao2,"FT_SERIE"  ,"",'Serie',"!!!",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao2,"FT_EMISSAO","",'Emissao',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao2,"FT_CLIEFOR","",'Cli/Forn',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao2,"FT_LOJA"   ,"",'Loja',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao2,"VALCONT","",'Val. Contabil',"@E 99,999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao2,"VALICM" ,"",'Valor ICMS',"@E 99,999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

    oBreak := TRBreak():New(oSecao2,oSecao2:Cell("FT_FILIAL"),"Totalizadores",.F.,'Totalizadores',.T.)
    TRFunction():New(oSecao2:Cell("VALCONT"),NIL,"SUM",oBreak,'Val.Cont�bil',,,.F.,.F.)
    TRFunction():New(oSecao2:Cell("VALICM"),NIL,"SUM",oBreak,'Val.ICMS',,,.F.,.F.)

    oSecao2:SetHeaderBreak(.T.) //Imprime cabe�alho das c�lulas ap�s quebra
    oSecao2:SetPageBreak(.T.) //Pula de p�gina ap�s quebra
    oSecao2:SetHeaderSection(.T.)

    
     //Terceira se��o: Vendas Fora do Estabelecimento em Outros Estados
    oSecao3 := TRSection():New(oReport)
    
    //Define se imprime cabe�alho das c�lulas na quebra de se��o
    oSecao3:SetHeaderSection(.T.)

    //Cria��o das celulas da se��o do relat�rio
    TRCell():New(oSecao3,"FT_FILIAL","",'Filial',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao3,"FT_NFISCAL","",'Documento',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao3,"FT_SERIE"  ,"",'Serie',"!!!",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao3,"FT_EMISSAO","",'Emissao',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao3,"FT_CLIEFOR","",'Cli/Forn',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao3,"FT_LOJA"   ,"",'Loja',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao3,"VALCONT","",'Val. Contabil',"@E 99,999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao3,"VALICM" ,"",'Valor ICMS',"@E 99,999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

    oBreak := TRBreak():New(oSecao3,oSecao3:Cell("FT_FILIAL"),"Totalizadores",.F.,'Totalizadores',.T.)
    TRFunction():New(oSecao3:Cell("VALCONT"),NIL,"SUM",oBreak,'Val.Cont�bil',,,.F.,.F.)
    TRFunction():New(oSecao3:Cell("VALICM"),NIL,"SUM",oBreak,'Val.ICMS',,,.F.,.F.)

    oSecao3:SetHeaderBreak(.T.) //Imprime cabe�alho das c�lulas ap�s quebra
    oSecao3:SetPageBreak(.T.) //Pula de p�gina ap�s quebra
    oSecao3:SetHeaderSection(.T.)	
    
    //Quarta se��o: Imposto Pago em Outro Estado
    
    oSecao4 := TRSection():New(oReport)
    //Define se imprime cabe�alho das c�lulas na quebra de se��o
    oSecao4:SetHeaderSection(.T.)

    //Cria��o das celulas da se��o do relat�rio
    TRCell():New(oSecao4,"F6_FILIAL","",'Filial',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao4,"F6_NUMERO","",'Documento',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao4,"F6_VALOR","",'Valor',"@E 99,999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao4,"F6_EST","",'Estado',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

    oSecao4:SetHeaderBreak(.T.) //Imprime cabe�alho das c�lulas ap�s quebra
    oSecao4:SetPageBreak(.T.) //Pula de p�gina ap�s quebra
    oSecao4:SetHeaderSection(.T.)
    
    //Quinta se��o: Nota Fiscal de Entrada de Mercadoria N�o Entregue
    oSecao5 := TRSection():New(oReport)
    
    //Define se imprime cabe�alho das c�lulas na quebra de se��o
    oSecao5:SetHeaderSection(.T.)

    //Cria��o das celulas da se��o do relat�rio
    TRCell():New(oSecao5,"FT_FILIAL","",'Filial',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao5,"FT_NFISCAL","",'Documento',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao5,"FT_SERIE"  ,"",'Serie',"!!!",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao5,"FT_EMISSAO","",'Emissao',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao5,"FT_CLIEFOR","",'Cli/Forn',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao5,"FT_LOJA"   ,"",'Loja',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao5,"VALCONT","",'Val. Contabil',"@E 99,999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

    oSecao5:SetHeaderBreak(.T.) //Imprime cabe�alho das c�lulas ap�s quebra
    oSecao5:SetPageBreak(.T.) //Pula de p�gina ap�s quebra
    oSecao5:SetHeaderSection(.T.)

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintRem
 
Fun��o que ir� fazer query das Remessesas de mercadorias remetida sem destinat�rio certo.

@param oReport - Objeto - Objeto principal do relat�rio
@param oSecao1 - Objeto - Se��o do Relat�rio
@param dDataDe - Date - Data inicial de processamento
@param dDataAte - Date - Data final de processamento


@author Graziele Mendon�a Paro
@since 12/06/2017

/*/
//-------------------------------------------------------------------
Static Function PrintRem(oReport,oSecao1, dDataDe, dDataAte)
    
Local cFiltro   := ''
Local cAliasSFT := GetNextAlias()

    cFiltro = "%"
    cFiltro += "SFT.FT_FILIAL          = '"    + xFilial('SFT')             + "' AND "
    cFiltro += "SFT.FT_CFOP IN('5904','6904') AND "
    cFiltro += "SFT.FT_EMISSAO      >= '"   + %Exp:DToS (dDataDe)%          + "' AND "
    cFiltro += "SFT.FT_EMISSAO      <= '"   + %Exp:DToS (dDataAte)%         + "' AND "
    cFiltro += "SFT.D_E_L_E_T_      = ' '  AND SFT.FT_DTCANC = ' ' "
    cFiltro += "%"
    
    //Indica que ser� utilizado o Embedded SQL para cria��o de uma nova query que ser� utilizada pela se��o
    oSecao1:BeginQuery()
    
    BeginSql Alias cAliasSFT
        COLUMN FT_EMISSAO AS DATE
        SELECT
        SFT.FT_FILIAL,SFT.FT_EMISSAO, SFT.FT_TIPOMOV,SFT.FT_SERIE,SFT.FT_NFISCAL,SFT.FT_CLIEFOR,SFT.FT_LOJA, SUM(SFT.FT_VALCONT) AS VALCONT , SUM(SFT.FT_BASEICM) AS BASEICM, SUM(SFT.FT_VALICM) AS VALICM
        FROM
        %TABLE:SFT% SFT
        WHERE
        %Exp:cFiltro%
        GROUP BY
        SFT.FT_FILIAL,SFT.FT_EMISSAO, SFT.FT_TIPOMOV,SFT.FT_SERIE,SFT.FT_NFISCAL,SFT.FT_CLIEFOR, SFT.FT_LOJA
    EndSql
    
    //Define o t�tulo do component
    oReport:SetTitle("Remessa para venda fora do estabelecimento")
    //Indica a query criada utilizando o Embedded SQL para a se��o.
    oSecao1:EndQuery()
    //Define o total da regua da tela de processamento do relat�rio.
    oReport:SetMeter((cAliasSFT)->(RecCount()))
    //Inicia impress�o do relat�rio
    oSecao1:Print()
    (cAliasSFT)->( DbCloseArea() )
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PrtInterno
 
Fun��o que ir� fazer query das Vendas das mercadorias fora do estabelecimento 
No Estado de Goi�s.

@param oReport - Objeto - Objeto principal do relat�rio
@param oSecao2 - Objeto - Se��o do relat�rio
@param dDataDe - Date - Data inicial de processamento
@param dDataAte - Date - Data final de processamento

@author Graziele Mendon�a Paro
@since 12/06/2017

/*/
//-------------------------------------------------------------------
Static Function PrtInterno(oReport,oSecao2, dDataDe, dDataAte)
    
Local cFiltro   := ''
Local cMvEstado := GetNewPar("MV_ESTADO")
Local cAliasSFT := GetNextAlias()

    cFiltro = "%"
    cFiltro += "SFT.FT_FILIAL          = '"    + xFilial('SFT')             + "' AND "
    cFiltro += "SFT.FT_CFOP IN('5103','5104') AND SFT.FT_ESTADO = '" + %Exp:cMvEstado% + "' AND "
    cFiltro += "SFT.FT_EMISSAO      >= '"   + %Exp:DToS (dDataDe)%          + "' AND "
    cFiltro += "SFT.FT_EMISSAO      <= '"   + %Exp:DToS (dDataAte)%         + "' AND "
    cFiltro += "SFT.D_E_L_E_T_      = ' '  AND SFT.FT_DTCANC = ' ' "
    cFiltro += "%"
    
    //Indica que ser� utilizado o Embedded SQL para cria��o de uma nova query que ser� utilizada pela se��o
    oSecao2:BeginQuery()
    
    BeginSql Alias cAliasSFT
        COLUMN FT_EMISSAO AS DATE
        SELECT
        SFT.FT_FILIAL,SFT.FT_EMISSAO, SFT.FT_TIPOMOV,SFT.FT_SERIE,SFT.FT_NFISCAL,SFT.FT_CLIEFOR,SFT.FT_LOJA, SUM(SFT.FT_VALCONT) AS VALCONT , SUM(SFT.FT_BASEICM) AS BASEICM, SUM(SFT.FT_VALICM) AS VALICM
        FROM
        %TABLE:SFT% SFT
        WHERE
        %Exp:cFiltro%
        GROUP BY
        SFT.FT_FILIAL,SFT.FT_EMISSAO, SFT.FT_TIPOMOV,SFT.FT_SERIE,SFT.FT_NFISCAL,SFT.FT_CLIEFOR, SFT.FT_LOJA
    EndSql
    
    //Define o t�tulo do component
    oReport:SetTitle("Vendas Fora do Estabelecimento no Estado de Goi�s")
    //Indica a query criada utilizando o Embedded SQL para a se��o.
    oSecao2:EndQuery()
    //Define o total da regua da tela de processamento do relat�rio.
    oReport:SetMeter((cAliasSFT)->(RecCount()))
    //Inicia impress�o do relat�rio
    oSecao2:Print()
    (cAliasSFT)->( DbCloseArea() )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtForaEst
 
Fun��o que ir� fazer query das Vendas das mercadorias fora do estabelecimento 
em outros Estados.

@param oReport - Objeto - Objeto principal do relat�rio
@param oSecao2 - Objeto - Se��o do relat�rio
@param dDataDe - Date - Data inicial de processamento
@param dDataAte - Date - Data final de processamento

@author Graziele Mendon�a Paro
@since 12/06/2017

/*/
//-------------------------------------------------------------------
Static Function PrtForaEst(oReport,oSecao3, dDataDe, dDataAte)
    
Local cFiltro   := ''
Local cMvEstado := GetNewPar("MV_ESTADO")
Local cAliasSFT := GetNextAlias()

    cFiltro = "%"
    cFiltro += "SFT.FT_FILIAL          = '"    + xFilial('SFT')             + "' AND "
    cFiltro += "SFT.FT_CFOP IN('6103','6104') AND SFT.FT_ESTADO <> '" + %Exp:cMvEstado% + "' AND "
    cFiltro += "SFT.FT_EMISSAO      >= '"   + %Exp:DToS (dDataDe)%          + "' AND "
    cFiltro += "SFT.FT_EMISSAO      <= '"   + %Exp:DToS (dDataAte)%         + "' AND "
    cFiltro += "SFT.D_E_L_E_T_      = ' '  AND SFT.FT_DTCANC = ' ' "
    cFiltro += "%"
    
    //Indica que ser� utilizado o Embedded SQL para cria��o de uma nova query que ser� utilizada pela se��o
    oSecao3:BeginQuery()
    
    BeginSql Alias cAliasSFT
        COLUMN FT_EMISSAO AS DATE
        SELECT
        SFT.FT_FILIAL,SFT.FT_EMISSAO, SFT.FT_TIPOMOV,SFT.FT_SERIE,SFT.FT_NFISCAL,SFT.FT_CLIEFOR,SFT.FT_LOJA, SUM(SFT.FT_VALCONT) AS VALCONT , SUM(SFT.FT_BASEICM) AS BASEICM, SUM(SFT.FT_VALICM) AS VALICM
        FROM
        %TABLE:SFT% SFT
        WHERE
        %Exp:cFiltro%
        GROUP BY
        SFT.FT_FILIAL,SFT.FT_EMISSAO, SFT.FT_TIPOMOV,SFT.FT_SERIE,SFT.FT_NFISCAL,SFT.FT_CLIEFOR, SFT.FT_LOJA
    EndSql
    
    //Define o t�tulo do component
    oReport:SetTitle("Vendas Fora do Estabelecimento em Outros Estados")
    //Indica a query criada utilizando o Embedded SQL para a se��o.
    oSecao3:EndQuery()
    //Define o total da regua da tela de processamento do relat�rio.
    oReport:SetMeter((cAliasSFT)->(RecCount()))
    //Inicia impress�o do relat�rio
    oSecao3:Print()
    (cAliasSFT)->( DbCloseArea() )
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PrtMercNE
 
Fun��o que ir� fazer query das Entradas de Mercadorias para fins de recupera��o do ICMS relativo �s mercadorias n�o vendidas

@param oReport - Objeto - Objeto principal do relat�rio
@param oSecao2 - Objeto - Se��o do relat�rio
@param dDataDe - Date - Data inicial de processamento
@param dDataAte - Date - Data final de processamento

@author Graziele Mendon�a Paro
@since 24/07/2017
/*/
//-------------------------------------------------------------------
Static Function ImpPagoFor(oReport,oSecao4, dDataDe, dDataAte)
	
	Local cFiltro   := ''
	Local cAliasSF6 := GetNextAlias()
	Local cMvEstado := GetNewPar("MV_ESTADO")
	
	cFiltro = "%"
	cFiltro += "SFT.FT_FILIAL          = '"    + xFilial('SFT')             + "' AND "
	cFiltro += "SFT.FT_CFOP IN( '6103', '6104' )  AND "
	cFiltro += "SFT.FT_EMISSAO      >= '"   + %Exp:DToS (dDataDe)%          + "' AND "
	cFiltro += "SFT.FT_EMISSAO      <= '"   + %Exp:DToS (dDataAte)%         + "' AND "
	cFiltro += "SFT.D_E_L_E_T_      = ' '  AND SFT.FT_DTCANC = ' ' "
	cFiltro += "%"
	
	//Indica que ser� utilizado o Embedded SQL para cria��o de uma nova query que ser� utilizada pela se��o
	oSecao4:BeginQuery()
	
	BeginSql Alias cAliasSF6
		SELECT  DISTINCT SF6.F6_FILIAL,
			    SF6.F6_NUMERO, 
			    SF6.F6_VALOR,
			    SF6.F6_EST
		FROM %TABLE:SF6% SF6
		INNER JOIN %TABLE:SFT% SFT
		ON (SF6.F6_FILIAL = %xFilial:SF6%
			AND SF6.F6_CLIFOR = SFT.FT_CLIEFOR
			AND SF6.F6_LOJA = SFT.FT_LOJA
			AND SF6.F6_SERIE = SFT.FT_SERIE
			AND SF6.F6_DOC = SFT.FT_NFISCAL
			AND SF6.F6_EST <> %Exp:cMvEstado% 
			AND SF6.D_E_L_E_T_ = '')
		WHERE
		%Exp:cFiltro%
		ORDER BY F6_NUMERO
	EndSql
	
	
	//Define o t�tulo do component
	oReport:SetTitle("Imposto Pago em Outro Estado")
	//Indica a query criada utilizando o Embedded SQL para a se��o.
	oSecao4:EndQuery()
	//Define o total da regua da tela de processamento do relat�rio.
	oReport:SetMeter((cAliasSF6)->(RecCount()))
	//Inicia impress�o do relat�rio
	oSecao4:Print()
	(cAliasSF6)->( DbCloseArea() )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtMercNE
 
Fun��o que ir� fazer query das Entradas de Mercadorias para fins de recupera��o do ICMS relativo �s mercadorias n�o vendidas

@param oReport - Objeto - Objeto principal do relat�rio
@param oSecao2 - Objeto - Se��o do relat�rio
@param dDataDe - Date - Data inicial de processamento
@param dDataAte - Date - Data final de processamento

@author Graziele Mendon�a Paro
@since 24/07/2017
/*/
//-------------------------------------------------------------------
Static Function PrtMercNE(oReport,oSecao5, dDataDe, dDataAte)
    
Local cFiltro   := ''
Local cAliasSFT := GetNextAlias()

    cFiltro = "%"
    cFiltro += "SFT.FT_FILIAL          = '"    + xFilial('SFT')             + "' AND "
    cFiltro += "SFT.FT_CFOP IN('1904','2904') AND "
    cFiltro += "SFT.FT_EMISSAO      >= '"   + %Exp:DToS (dDataDe)%          + "' AND "
    cFiltro += "SFT.FT_EMISSAO      <= '"   + %Exp:DToS (dDataAte)%         + "' AND "
    cFiltro += "SFT.D_E_L_E_T_      = ' '  AND SFT.FT_DTCANC = ' ' "
    cFiltro += "%"
    
    //Indica que ser� utilizado o Embedded SQL para cria��o de uma nova query que ser� utilizada pela se��o
    oSecao5:BeginQuery()
    
    BeginSql Alias cAliasSFT
        COLUMN FT_EMISSAO AS DATE
        SELECT
        SFT.FT_FILIAL,SFT.FT_EMISSAO, SFT.FT_TIPOMOV,SFT.FT_SERIE,SFT.FT_NFISCAL,SFT.FT_CLIEFOR, SFT.FT_LOJA, SUM(SFT.FT_VALCONT) AS VALCONT , SUM(SFT.FT_BASEICM) AS BASEICM, SUM(SFT.FT_VALICM) AS VALICM
        FROM
        %TABLE:SFT% SFT
        WHERE
        %Exp:cFiltro%
        GROUP BY
        SFT.FT_FILIAL,SFT.FT_EMISSAO, SFT.FT_TIPOMOV,SFT.FT_SERIE,SFT.FT_NFISCAL,SFT.FT_CLIEFOR, SFT.FT_LOJA
    EndSql
    
    //Define o t�tulo do component
    oReport:SetTitle("Nota Fiscal de Entrada de Mercadoria N�o Entregue")
    //Indica a query criada utilizando o Embedded SQL para a se��o.
    oSecao5:EndQuery()
    //Define o total da regua da tela de processamento do relat�rio.
    oReport:SetMeter((cAliasSFT)->(RecCount()))
    //Inicia impress�o do relat�rio
    oSecao5:Print()
    (cAliasSFT)->( DbCloseArea() )
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetFilial
 
Fun��o que ir� fazer o mecanismo de sele��o de filiais
 
@author Graziele Mendon�a paro  
@since 09/06/2017
@return aSM0 - Array - Array com as filiais selecionada para processar

/*/
//-------------------------------------------------------------------
Static Function GetFilial()

Local aAreaSM0  := {}
Local aSM0          := {}
local nFil          := 0
Local aSelFil       := {}
Local aRetAuto		:= {}

aAreaSM0 := SM0->(GetArea())
DbSelectArea("SM0")

IF !IsBlind()
	aSelFil := MatFilCalc( .T. )
Else
	If FindFunction("GetParAuto")
		aRetAuto := GetParAuto("FISR134TestCase") 
		aSelFil  := aRetAuto
	EndIf
EndIf	
//--------------------------------------------------------
//Ir� preencher aSM0 somente com as filiais selecionadas
//pelo cliente  
//--------------------------------------------------------
If Len(aSelFil)> 0
    SM0->(DbGoTop())
    If SM0->(MsSeek(cEmpAnt))
        Do While !SM0->(Eof()) 
            nFil := Ascan(aSelFil,{|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL) .And. x[4] == SM0->M0_CGC})
            If nFil > 0 .And. aSelFil[nFil][1] .AND. cEmpAnt == SM0->M0_CODIGO
                Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC})
            EndIf
            SM0->(dbSkip())
        Enddo
    EndIf
    
    SM0->(RestArea(aAreaSM0))
EndIF

Return aSM0



