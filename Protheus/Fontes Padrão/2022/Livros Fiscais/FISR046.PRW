#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

Function Fisr046()
local oReport
local cPerg		:= 'FISR046'
local cAlias	:= getNextAlias()

Pergunte(cPerg, .T.)

oReport := reportDef(cAlias, cPerg)
oReport:printDialog()

return
        
//+-----------------------------------------------------------------------------------------------+
//! Rotina para montagem dos dados do relatório.                                  !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportPrint(oReport,cAlias)
              
Local oSecao1 := oReport:Section(1)
Local cTipo	  := Alltrim(Str(MV_PAR03))

oSecao1:BeginQuery()

BeginSQL Alias cAlias
 
 SELECT F02_FORRAZ, F02_FORCGC, F02_MESREF, F02_ANOREF, F02_VLTOTN, F02_VLDEDU, F02_TIPO
 FROM %Table:F02% F02
 WHERE F02_MESREF = %Exp:MV_PAR01% AND 
	   F02_ANOREF = %Exp:MV_PAR02% AND
	   F02_TIPO = %Exp:cTipo%
EndSQL

oSecao1:EndQuery()
oReport:SetMeter((cAlias)->(RecCount()))
oSecao1:Print() 

return

//+-----------------------------------------------------------------------------------------------+
//! Função para criação da estrutura do relatório.                                                !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportDef(cAlias,cPerg)
local oReport
local oSection1
local cTitle	:= ""

local cHelp		:= "Relatório para consulta de arquivos importados INOVAR-AUTO."

If MV_PAR03 == 1
	cTitle := "Consulta Inovar-Auto (Autodeclaração de Venda a montadora)"
Else
	cTitle := "Consulta Inovar-Auto (Não Informação de Venda a montadora)"	
Endif

oReport := TReport():New('Inovar-Auto',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)

//Primeira seção
oSection1 := TRSection():New(oReport,"Inovar-Auto",{"F02"}) 

TRCell():New(oSection1,"F02_FORRAZ", "", "Fornecedor")
TRCell():New(oSection1,"F02_FORCGC", "", "CNPJ") 
TRCell():New(oSection1,"F02_MESREF", "", "Mês Referência") 
TRCell():New(oSection1,"F02_ANOREF", "", "Ano Referência") 
TRCell():New(oSection1,"F02_VLTOTN", "", "Valor Total Notas") 
If MV_PAR03 == 1
	TRCell():New(oSection1,"F02_VLDEDU", "", "Valor Parcela Dedução") 
Endif
Return(oReport)
