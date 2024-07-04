#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FWCOMMAND.CH"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} FISR134
 
Relatório de demonstrativo de Vendas Fora do Estabelecimento
Estado de Goiás - (Anexo XII, art. 28, § 4º, III)
 
@author Graziele Mendonça Paro
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
 
Função responsável para impressão do relatório, que irá fazer o laço nas filiais
imprimindo as seções pertinentes.
 
@author Graziele Mendonça Paro
@since 09/06/2017
@return oReport - Objeto - Objeto do relatório Treport

/*/	
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)              

local oSecao1   := oReport:Section(1) //Remessas para venda fora do estabelecimento
Local oSecao2   := oReport:Section(2) //Vendas fora do estabelecimento do estado de Goiás
Local oSecao3   := oReport:Section(3) //Vendas fora do Estabelecimento em Outros Estados
Local oSecao4   := oReport:Section(4) //Imposto Pago em outro Estado
Local oSecao5   := oReport:Section(5) //Nota Fiscal pela entrada de mercadoria não entregue.

//APURAÇÃO DO IMPOSTO A CREDITAR // Não será desenvolvido neste momento. Pois não temos informações suficientes.
Local dDataDe   := MV_PAR01
Local dDataAte  := MV_PAR02
Local aAreaSM0  := SM0->(GetArea())
local aFilial   := {}
Local cAliasSFT := GetNextAlias()
Local nContFil  := 0

aFilial        := GetFilial()

If len(aFilial) ==0
    MsgAlert('Nenhuma filial foi selecionada, o processamento não será realizado.')
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
 
Função que irá criar a estrutura do relatório, com as definições de cada seção,
quebras, somatórios etc.
 
@author Graziele Mendonça Paro
@since 09/06/2017

/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)
    
Local cTitle  := "Demonstrativo de Vendas Fora do Estabelecimento - Estado de Goiás"
Local cHelp   := "Listagem das vendas realizadas fora do Estabelecimento - DEFO (Anexo XII, art. 28, § 4º, III)"
Local oReport
Local oSecao1
Local oSecao2
Local oSecao3
Local oSecao4
Local oSecao5
    
    oReport := TReport():New('FISR134',cTitle,cPerg,{|oReport|ReportPrint(oReport)},cHelp)
    //Define a orientação de página do relatório como retrato
    oReport:SetPortrait()
    
    //Primeira seção: Remessa para venda fora do estabelecimento
     oSecao1 := TRSection():New(oReport)	
    //Define se imprime cabeçalho das células na quebra de seção
    oSecao1:SetHeaderSection(.T.)

    //Criação das celulas da seção do relatório
    TRCell():New(oSecao1,"FT_FILIAL","",'Filial',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao1,"FT_NFISCAL","",'Documento',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao1,"FT_SERIE"  ,"",'Serie',"!!!",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao1,"FT_EMISSAO","",'Emissao',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao1,"FT_CLIEFOR","",'Cli/Forn',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao1,"FT_LOJA"   ,"",'Loja',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao1,"VALCONT","",'Val. Contabil',"@E 99,999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao1,"VALICM" ,"",'Valor ICMS',"@E 99,999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

    oBreak := TRBreak():New(oSecao1,oSecao1:Cell("FT_FILIAL"),"Totalizadores",.F.,'Totalizadores',.T.)
    TRFunction():New(oSecao1:Cell("VALCONT"),NIL,"SUM",oBreak,'Val.Contábil',,,.F.,.F.)
    TRFunction():New(oSecao1:Cell("VALICM"),NIL,"SUM",oBreak,'Val.ICMS',,,.F.,.F.)

    oSecao1:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
    oSecao1:SetPageBreak(.T.) //Pula de página após quebra
    oSecao1:SetHeaderSection(.T.)
    

    //Segunda seção: Vendas Fora do Estabelecimento no Estado de Goiás
    oSecao2 := TRSection():New(oReport)
    //Define se imprime cabeçalho das células na quebra de seção
    oSecao2:SetHeaderSection(.T.)

    //Criação das celulas da seção do relatório
    TRCell():New(oSecao2,"FT_FILIAL","",'Filial',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao2,"FT_NFISCAL","",'Documento',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao2,"FT_SERIE"  ,"",'Serie',"!!!",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao2,"FT_EMISSAO","",'Emissao',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao2,"FT_CLIEFOR","",'Cli/Forn',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao2,"FT_LOJA"   ,"",'Loja',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao2,"VALCONT","",'Val. Contabil',"@E 99,999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao2,"VALICM" ,"",'Valor ICMS',"@E 99,999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

    oBreak := TRBreak():New(oSecao2,oSecao2:Cell("FT_FILIAL"),"Totalizadores",.F.,'Totalizadores',.T.)
    TRFunction():New(oSecao2:Cell("VALCONT"),NIL,"SUM",oBreak,'Val.Contábil',,,.F.,.F.)
    TRFunction():New(oSecao2:Cell("VALICM"),NIL,"SUM",oBreak,'Val.ICMS',,,.F.,.F.)

    oSecao2:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
    oSecao2:SetPageBreak(.T.) //Pula de página após quebra
    oSecao2:SetHeaderSection(.T.)

    
     //Terceira seção: Vendas Fora do Estabelecimento em Outros Estados
    oSecao3 := TRSection():New(oReport)
    
    //Define se imprime cabeçalho das células na quebra de seção
    oSecao3:SetHeaderSection(.T.)

    //Criação das celulas da seção do relatório
    TRCell():New(oSecao3,"FT_FILIAL","",'Filial',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao3,"FT_NFISCAL","",'Documento',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao3,"FT_SERIE"  ,"",'Serie',"!!!",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao3,"FT_EMISSAO","",'Emissao',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao3,"FT_CLIEFOR","",'Cli/Forn',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao3,"FT_LOJA"   ,"",'Loja',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao3,"VALCONT","",'Val. Contabil',"@E 99,999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao3,"VALICM" ,"",'Valor ICMS',"@E 99,999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

    oBreak := TRBreak():New(oSecao3,oSecao3:Cell("FT_FILIAL"),"Totalizadores",.F.,'Totalizadores',.T.)
    TRFunction():New(oSecao3:Cell("VALCONT"),NIL,"SUM",oBreak,'Val.Contábil',,,.F.,.F.)
    TRFunction():New(oSecao3:Cell("VALICM"),NIL,"SUM",oBreak,'Val.ICMS',,,.F.,.F.)

    oSecao3:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
    oSecao3:SetPageBreak(.T.) //Pula de página após quebra
    oSecao3:SetHeaderSection(.T.)	
    
    //Quarta seção: Imposto Pago em Outro Estado
    
    oSecao4 := TRSection():New(oReport)
    //Define se imprime cabeçalho das células na quebra de seção
    oSecao4:SetHeaderSection(.T.)

    //Criação das celulas da seção do relatório
    TRCell():New(oSecao4,"F6_FILIAL","",'Filial',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao4,"F6_NUMERO","",'Documento',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao4,"F6_VALOR","",'Valor',"@E 99,999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao4,"F6_EST","",'Estado',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

    oSecao4:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
    oSecao4:SetPageBreak(.T.) //Pula de página após quebra
    oSecao4:SetHeaderSection(.T.)
    
    //Quinta seção: Nota Fiscal de Entrada de Mercadoria Não Entregue
    oSecao5 := TRSection():New(oReport)
    
    //Define se imprime cabeçalho das células na quebra de seção
    oSecao5:SetHeaderSection(.T.)

    //Criação das celulas da seção do relatório
    TRCell():New(oSecao5,"FT_FILIAL","",'Filial',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao5,"FT_NFISCAL","",'Documento',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao5,"FT_SERIE"  ,"",'Serie',"!!!",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao5,"FT_EMISSAO","",'Emissao',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao5,"FT_CLIEFOR","",'Cli/Forn',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao5,"FT_LOJA"   ,"",'Loja',/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSecao5,"VALCONT","",'Val. Contabil',"@E 99,999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

    oSecao5:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
    oSecao5:SetPageBreak(.T.) //Pula de página após quebra
    oSecao5:SetHeaderSection(.T.)

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintRem
 
Função que irá fazer query das Remessesas de mercadorias remetida sem destinatário certo.

@param oReport - Objeto - Objeto principal do relatório
@param oSecao1 - Objeto - Seção do Relatório
@param dDataDe - Date - Data inicial de processamento
@param dDataAte - Date - Data final de processamento


@author Graziele Mendonça Paro
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
    
    //Indica que será utilizado o Embedded SQL para criação de uma nova query que será utilizada pela seção
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
    
    //Define o título do component
    oReport:SetTitle("Remessa para venda fora do estabelecimento")
    //Indica a query criada utilizando o Embedded SQL para a seção.
    oSecao1:EndQuery()
    //Define o total da regua da tela de processamento do relatório.
    oReport:SetMeter((cAliasSFT)->(RecCount()))
    //Inicia impressão do relatório
    oSecao1:Print()
    (cAliasSFT)->( DbCloseArea() )
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PrtInterno
 
Função que irá fazer query das Vendas das mercadorias fora do estabelecimento 
No Estado de Goiás.

@param oReport - Objeto - Objeto principal do relatório
@param oSecao2 - Objeto - Seção do relatório
@param dDataDe - Date - Data inicial de processamento
@param dDataAte - Date - Data final de processamento

@author Graziele Mendonça Paro
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
    
    //Indica que será utilizado o Embedded SQL para criação de uma nova query que será utilizada pela seção
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
    
    //Define o título do component
    oReport:SetTitle("Vendas Fora do Estabelecimento no Estado de Goiás")
    //Indica a query criada utilizando o Embedded SQL para a seção.
    oSecao2:EndQuery()
    //Define o total da regua da tela de processamento do relatório.
    oReport:SetMeter((cAliasSFT)->(RecCount()))
    //Inicia impressão do relatório
    oSecao2:Print()
    (cAliasSFT)->( DbCloseArea() )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtForaEst
 
Função que irá fazer query das Vendas das mercadorias fora do estabelecimento 
em outros Estados.

@param oReport - Objeto - Objeto principal do relatório
@param oSecao2 - Objeto - Seção do relatório
@param dDataDe - Date - Data inicial de processamento
@param dDataAte - Date - Data final de processamento

@author Graziele Mendonça Paro
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
    
    //Indica que será utilizado o Embedded SQL para criação de uma nova query que será utilizada pela seção
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
    
    //Define o título do component
    oReport:SetTitle("Vendas Fora do Estabelecimento em Outros Estados")
    //Indica a query criada utilizando o Embedded SQL para a seção.
    oSecao3:EndQuery()
    //Define o total da regua da tela de processamento do relatório.
    oReport:SetMeter((cAliasSFT)->(RecCount()))
    //Inicia impressão do relatório
    oSecao3:Print()
    (cAliasSFT)->( DbCloseArea() )
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PrtMercNE
 
Função que irá fazer query das Entradas de Mercadorias para fins de recuperação do ICMS relativo às mercadorias não vendidas

@param oReport - Objeto - Objeto principal do relatório
@param oSecao2 - Objeto - Seção do relatório
@param dDataDe - Date - Data inicial de processamento
@param dDataAte - Date - Data final de processamento

@author Graziele Mendonça Paro
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
	
	//Indica que será utilizado o Embedded SQL para criação de uma nova query que será utilizada pela seção
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
	
	
	//Define o título do component
	oReport:SetTitle("Imposto Pago em Outro Estado")
	//Indica a query criada utilizando o Embedded SQL para a seção.
	oSecao4:EndQuery()
	//Define o total da regua da tela de processamento do relatório.
	oReport:SetMeter((cAliasSF6)->(RecCount()))
	//Inicia impressão do relatório
	oSecao4:Print()
	(cAliasSF6)->( DbCloseArea() )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrtMercNE
 
Função que irá fazer query das Entradas de Mercadorias para fins de recuperação do ICMS relativo às mercadorias não vendidas

@param oReport - Objeto - Objeto principal do relatório
@param oSecao2 - Objeto - Seção do relatório
@param dDataDe - Date - Data inicial de processamento
@param dDataAte - Date - Data final de processamento

@author Graziele Mendonça Paro
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
    
    //Indica que será utilizado o Embedded SQL para criação de uma nova query que será utilizada pela seção
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
    
    //Define o título do component
    oReport:SetTitle("Nota Fiscal de Entrada de Mercadoria Não Entregue")
    //Indica a query criada utilizando o Embedded SQL para a seção.
    oSecao5:EndQuery()
    //Define o total da regua da tela de processamento do relatório.
    oReport:SetMeter((cAliasSFT)->(RecCount()))
    //Inicia impressão do relatório
    oSecao5:Print()
    (cAliasSFT)->( DbCloseArea() )
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetFilial
 
Função que irá fazer o mecanismo de seleção de filiais
 
@author Graziele Mendonça paro  
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
//Irá preencher aSM0 somente com as filiais selecionadas
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



