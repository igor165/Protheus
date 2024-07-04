#Include 'TOTVS.CH'
#Include 'GTPR285.CH'

/*/
 * {Protheus.doc} GTPR285()
 * Relatorio De Faturamento de Requisições
 * type    Function
 * author  Eduardo Ferreira
 * since   06/01/2020
 * version 12.25
 * param   Não há
 * return  Não há
/*/
Function GTPR285()
Local oReport := NIL
Local cPerg   := 'GTPR285'

If Pergunte(cPerg, .T.)
    oReport := ReportDef(cPerg)
    oReport:PrintDialog()
EndIf 

Return 


/*/
 * {Protheus.doc} ReportDef()
 * Montagem do Relatorio
 * type    Static Function
 * author  Eduardo Ferreira
 * since   06/01/2020
 * version 12.25
 * param   cPerg, cAlias
 * return  oReport
/*/
Static Function ReportDef(cPerg)
Local oReport  := NIL
Local oSection := Nil
Local cAlias  := GetNextAlias()  

MontQuery(@cAlias)

oReport := TReport():New('GTPR285', STR0001, cPerg, {|oReport| ReportPrint(oReport, cAlias)}, '', .F.,, .F.,, .F., .F.,) //Faturamento de Requisições

oSection := TRSection():New(oReport, STR0001, {'GQY', 'SA1'},, .F., .F.,, .F.,,,,,,,,,,,,,,) //'Faturamento de Requisições'

TRCell():New(oSection, "FATURA"    , cAlias, STR0002, X3Picture("GQY_CODIGO"), TamSx3('GQY_CODIGO')[1],,, 'LEFT',,,,, .T.,,,) //Nº FATURA
TRCell():New(oSection, "CLIENTE"   , cAlias, STR0003, X3Picture("GQY_CODCLI"), TamSx3('GQY_CODCLI')[1],,, 'LEFT',,,,, .T.,,,) //CLIENTE
TRCell():New(oSection, "LOJA"      , cAlias, STR0004, X3Picture("A1_LOJA"   ), TamSx3('A1_LOJA'   )[1],,, 'LEFT',,,,, .T.,,,) //LOJA
TRCell():New(oSection, "NOME"      , cAlias, STR0005, X3Picture("A1_NOME"   ), TamSx3('A1_NOME'   )[1],,, 'LEFT',,,,, .T.,,,) //NOME
TRCell():New(oSection, 'BRUTO'     , cAlias, STR0006, X3Picture("GQY_TOTAL" ), TamSx3('GQY_TOTAL' )[1],,, 'LEFT',,,,, .T.,,,) //BRUTO
TRCell():New(oSection, 'DESCONTO'  , cAlias, STR0007, X3Picture("GQY_TOTDES"), TamSx3('GQY_TOTDES')[1],,, 'LEFT',,,,, .T.,,,) //DESCONTO
TRCell():New(oSection, 'LIQUIDO'   , cAlias, STR0008, X3Picture("GQY_TOTAL" ), TamSx3('GQY_TOTAL' )[1],,, 'LEFT',,,,, .T.,,,) //LIQUIDO
TRCell():New(oSection, "EMISSAO"   , cAlias, STR0009, X3Picture("GQY_DTEMIS"), TamSx3('GQY_DTEMIS')[1],,, 'LEFT',,,,, .T.,,,) //LIQUIDO
TRCell():New(oSection, 'FECHAMENTO', cAlias, STR0010, X3Picture("GQY_DTFECH"), TamSx3('GQY_DTFECH')[1],,, 'LEFT',,,,, .T.,,,) //LIQUIDO
TRCell():New(oSection, "STATUS"    , cAlias, STR0011, X3Picture("GQY_STATUS"), TamSx3('GQY_STATUS')[1],,, 'LEFT',,,,, .T.,,,) //STATUS

Return oReport


/*/
 * {Protheus.doc} MontQuery()
 * Busca os dados do Lote de Requisição(GQY)
 * type    Static Function
 * author  Eduardo Ferreira
 * since   06/01/2020
 * version 12.25
 * param   cAlias
 * return  Não há
/*/
Static Function MontQuery(cAlias)
Local cParam1  := MV_PAR01 //Código de?
Local cParam2  := MV_PAR02 //Código até?
Local cParam3  := MV_PAR03 //Cliente de?
Local cParam4  := MV_PAR04 //Cliente até?
Local cParam5  := DTOS(MV_PAR05) //Emissão de?
Local cParam6  := DTOS(MV_PAR06) //Emissão até?   
Local cParam7  := DTOS(MV_PAR07) //Fechamento de?
Local cParam8  := DTOS(MV_PAR08) //Fechamento até?  

BeginSQL Alias cAlias
    SELECT 
        GQY.GQY_CODIGO AS FATURA,
        GQY.GQY_CODCLI AS CLIENTE, 
        GQY.GQY_TOTAL  AS BRUTO ,
        GQY.GQY_TOTDES AS DESCONTO,
        (GQY.GQY_TOTAL - GQY.GQY_TOTDES) AS LIQUIDO,
        GQY.GQY_DTEMIS AS EMISSAO,
        GQY.GQY_DTFECH AS FECHAMENTO, 
        GQY.GQY_STATUS AS STATUS,
        SA1.A1_NOME AS NOME,
        SA1.A1_LOJA AS LOJA
    FROM 
        %table:GQY% GQY JOIN %table:SA1% SA1 
            ON SA1.A1_FILIAL = %xFilial:SA1%
            AND SA1.A1_COD = GQY.GQY_CODCLI
            AND SA1.%NotDel% 
    WHERE 
        GQY.GQY_FILIAL = %xFilial:GQY%
        AND GQY.GQY_CODIGO BETWEEN %Exp:cParam1% AND %Exp:cParam2% 
        AND GQY.GQY_CODCLI BETWEEN %Exp:cParam3% AND %Exp:cParam4% 
        AND GQY.GQY_DTEMIS BETWEEN %Exp:cParam5% AND %Exp:cParam6%
        AND GQY.GQY_DTFECH BETWEEN %Exp:cParam7% AND %Exp:cParam8%
        AND GQY.%NotDel%   
EndSQL
    
Return 


/*/
 * {Protheus.doc} ReportPrint()
 * Seta os valores no Relatorio 
 * type    Static Function
 * author  Eduardo Ferreira
 * since   06/01/2020
 * version 12.25
 * param   oReport, cAlias
 * return  Não há
/*/
Static Function ReportPrint(oReport, cAlias)
Local oSection	:= oReport:Section(1)

DbSelectArea(cAlias)
(cAlias)->(DbGoTop())

oSection:init()	

While (cAlias)->(!Eof())   
    If oReport:Cancel()
        Exit
    EndIf
    
    oReport:IncMeter()
               		
    oSection:Cell("FATURA"    ):SetValue((cAlias)->FATURA)
    oSection:Cell("CLIENTE"   ):SetValue((cAlias)->CLIENTE)
    oSection:Cell("LOJA"      ):SetValue((cAlias)->LOJA)              
    oSection:Cell("NOME"      ):SetValue((cAlias)->NOME)
    oSection:Cell("BRUTO"     ):SetValue((cAlias)->BRUTO)
    oSection:Cell("DESCONTO"  ):SetValue((cAlias)->DESCONTO)
    oSection:Cell("LIQUIDO"   ):SetValue((cAlias)->LIQUIDO)
    oSection:Cell("EMISSAO"   ):SetValue(STOD((cAlias)->EMISSAO))
    oSection:Cell("FECHAMENTO"):SetValue(STOD((cAlias)->FECHAMENTO))
    oSection:Cell("STATUS"    ):SetValue(Iif((cAlias)->STATUS == '1', STR0013, STR0012)) //Baixado, Pendente

    oSection:PrintLine()

    (cAlias)->(DbSkip())
Enddo

oSection:Finish()

(cAlias)->(DbCloseArea())

Return 
