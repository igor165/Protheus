#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "FwPrintSetup.Ch" 
#Include "RptDef.Ch"  
#Include  "TAFR111.ch"

//-------------------------------------------------------------------------------------------------------------------
/*/TAFR111

Realiza a Emissao do Relatorio de Apuracao de ICMS modelo P9      

Por definicao as apuracoes serao filtradas de acordo com os periodos previamente exibidos nos parametros, ou seja,
caso seja gerada uma apuracao do dia 05/Jan ate 12/Jan ela NUNCA sera listada no relatorio, pois nao se enquadra 
nos tipo de apuracao existentes ( Mensal / Quinzenal / Decendial / Semestral / Anual )

@Retorno ( Nil )

@Author Rodrigo Aguilar
@Since 05/12/2012
@Version 1.0

/*/  
//-------------------------------------------------------------------------------------------------------------------
Function TAFR111()

	TafXDescont(STR0105) // "TAFR111 - Registro de Apuração de ICMS - P9"

Return