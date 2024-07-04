#INCLUDE "LOJR902.ch"
#Include "Protheus.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJR902
Relatorio de Pedidos Integrado e-commerce CiaShop
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample LOJR902()
/*/
//-------------------------------------------------------------------
Function LOJR902

local oReport //Objeto Report
local cPerg  := 'LJ902'//Consulta
local cAlias := getNextAlias() //Alias

Pergunte(cPerg, .F.)

oReport := Lj902RDef(cAlias, cPerg)

oReport:printDialog()

return
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj902RDef
Relatorio de Pedidos Integrado e-commerce CiaShop - Criação da estrutura do relatório
@param   	cAlias - Alias
@param   	cPerg - Pergunta
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj902RDef(cAlias,cPerg)
/*/
//-------------------------------------------------------------------
Static Function Lj902RDef(cAlias,cPerg)

local cTitle  := STR0001 //"Relatório de Integração"
local cHelp   := STR0002 //"Permite gerar um relatório para visualizar os valores integrados entre o Protheus e a Loja Virtual."

local oReport := nil
local oSection1 := nil

oReport	:= TReport():New('LOJR902',cTitle,cPerg,{|oReport|Lj902RPrt(oReport,cAlias)},cHelp)

//Primeira seção
oSection1 := TRSection():New(oReport,STR0003,{"MGM","MGU"},{}) //"Pedidos"

TRCell():New(oSection1,"MGM_DATA" , "MGM", STR0004) //"Data"
TRCell():New(oSection1,"MGU_FRETE", "MGU", STR0005) //"Total Frete"
TRCell():New(oSection1,"MGU_TOTAL", "MGU", STR0006)        //"Total Pedido"
TRCell():New(oSection1,"QTDE"    ,      , STR0007, "@E 999999", 13,,,,,"RIGHT") //"Quantidade"

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj902RPrt
Relatorio de Pedidos Integrado e-commerce CiaShop - Montagem dos dados do relatório
@param   	oReport - Objeto Report
@param   	cAlias - Alias
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj905RPrt(oReport,cAlias)
/*/
//+-----------------------------------------------------------------------------------------------+
Static Function Lj902RPrt(oReport,cAlias)

local oSection1b := oReport:Section(1) //Objeto seção

oSection1b:BeginQuery()

BeginSQL Alias cAlias
	
	Column MGM_DATA as Date
	
	SELECT MGM_DATA, SUM(MGU_TOTAL) MGU_TOTAL, SUM(MGU_FRETE) MGU_FRETE, COUNT(*) QTDE

	FROM %Table:MGU% MGU

	INNER JOIN %Table:MGM% MGM
	ON MGM_FILIAL = MGU_FILIAL
	AND MGM_SEQ = MGU_SEQ
	AND MGM_SERVIC = 'LOJA901A'
	AND MGM.%NotDel%

	WHERE MGU_FILIAL = %xFilial:MGU%
	AND MGU_CONFIR = '1'
	AND MGM_DATA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
	AND MGU.%NotDel%

	GROUP BY MGM_DATA

	ORDER BY MGM_DATA
	
EndSQL               

oSection1b:EndQuery()

oReport:SetMeter((cAlias)->(LastRec()))

oSection1b:Print()

return