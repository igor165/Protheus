#include 'protheus.ch'
#include 'parmtype.ch'
#include 'gtpr500.ch'
#INCLUDE "RPTDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR500()

Relatório de Pendências de Arrecadação.

@author  SIGAGTP | Gabriela Naomi Kamimoto|   
@since   28/11/2017
@version P12
/*/
//-------------------------------------------------------------------

Function GTPR500()
Private oReport  := Nil
Private cPerg    := "GTPR500"

If Pergunte( cPerg, .T. )
	oReport := ReportDef()
	oReport:PrintDialog()	
EndIf	

return

//-------------------------------------------------------------------
/*/{Protheus.doc} RptDef(cPerg)

Relatório de Pendências de Arrecadação.
Definição do relatório.

@author  SIGAGTP | Gabriela Naomi Kamimoto|   
@since   28/11/2017
@version P12
/*/
//-------------------------------------------------------------------

Static Function ReportDef()
Local oReport   := Nil
Local oSection1 := Nil
Local oSection2 := Nil
Local cTitulo   := STR0001 //'[GTPR500] - Relatório de Pendências de Arrecadação'
Local cAliasTemp := GetNextAlias() 
Local cConfer    := "2" //Conferido

GetDemons(@cAliasTemp, cConfer)

oReport := TReport():New('GTPR500', cTitulo, , {|oReport| PrintReport(oReport,cAliasTemp)},STR0002) //"Este relatório irá imprimir Pendências de Arrecadação"
oReport:SetTotalInLine(.F.)
oReport:ShowHeader(.F.)

oSection1 := TRSection():New(oReport,STR0003,{cAliasTemp}) //"Passagens"
oSection1:SetTotalInLine(.F.)

TRCell():New(oSection1, "NUMBIL"  , cAliasTemp, STR0004  ,"@!", 50) // Número Bilhete
TRCell():New(oSection1, "STSBIL"  , cAliasTemp, STR0005  ,"@!", 50) // Baixado

oSection2 := TRSection():New(oReport,STR0006,{cAliasTemp}) //"Taxas"
oSection2:SetTotalInLine(.F.)

TRCell():New(oSection2, "NUMTAX"   , cAliasTemp, STR0007	,"@!", 50) //'Código Taxa'
TRCell():New(oSection2, "STSTAX"   , cAliasTemp, STR0005   	,"@!", 50) //'Baixado'

oBreak:= TRBreak():New(oSection1,{||(cAliasTemp)->(GIC_AGENCI)},"")

oBreak:SetPageBreak(.T.)

Return (oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintReport(oReport,cAliasTmp)

Relatório de Pendências de Arrecadação.
Definição do relatório.

@author  SIGAGTP | Gabriela Naomi Kamimoto|   
@since   28/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function PrintReport(oReport,cAliasTemp)
Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(2)
Local cStatus    := ""
	
DbSelectArea(cAliasTemp)
dbGoTop()
oReport:SetMeter((cAliasTemp)->(RecCount()))

If MV_PAR05 == 1
	oSection1:Init()
	
	While (cAliasTemp)->(!Eof())

		If oReport:Cancel()
			Exit
		EndIf
		
		If (cAliasTemp)->(GIC_STATUS) <> "C"
			
			If (cAliasTemp)->(GIC_CONFER) == '1'
				cStatus := STR0008 //"Não Conferido"
			Else
				cStatus := STR0009 //"Rejeitado"
			EndIf
			
			oSection1:Cell("NUMBIL"):SetValue((cAliasTemp)->(GIC_CODIGO))
			oSection1:Cell("STSBIL"):SetValue(cStatus)
		
			oSection1:Printline()
			
		EndIf		
		
		(cAliasTemp)->(DbSkip())
	
	End	
	
	oSection1:Finish()
	oReport:ThinLine()
	oReport:EndPage()

Else
	oSection2:Init()
	
	While (cAliasTemp)->(!Eof())

		If oReport:Cancel()
			Exit
		EndIf
		
		If (cAliasTemp)->(G57_CONFER) == "T"
			cStatus := STR0010 //"Conferido"
		Else
			cStatus := STR0008 //"Não Conferido"
		EndIf
			
		oSection2:Cell("NUMTAX"):SetValue((cAliasTemp)->(G57_CODIGO))
		oSection2:Cell("STSTAX"):SetValue(cStatus)
		
		oSection2:Printline()
		
		(cAliasTemp)->(DbSkip())
	
	End	
	
	oSection2:Finish()
	oReport:ThinLine()
	oReport:EndPage()
	
EndIf
	
If Select(cAliasTemp) > 0
	(cAliasTemp)->(dbCloseArea())
EndIf

Return


/*/{Protheus.doc} GetDemons(@cAliasTemp, cConfer)
(long_description)
@type  Static Function
@author user
@since 21/05/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GetDemons(cAliasTemp, cConfer)

//Pendências de Demonstrativos de Passagens (DAPE)
If MV_PAR05 == 1 
	BeginSql Alias cAliasTemp
		SELECT 
			GIC.GIC_CODIGO,
			GIC.GIC_AGENCI,
			GIC.GIC_STATUS,
			GIC.GIC_CONFER    
		FROM 
			%Table:GIC% GIC 
		WHERE
			GIC.GIC_FILIAL = %xFilial:GIC%
			AND GIC.%NotDel% 
			AND GIC.GIC_CONFER <> %Exp:cConfer%
			AND GIC.GIC_CODGY3 IN (
				SELECT 
					GY3.GY3_CODIGO 
				FROM 
						%Table:GY3% GY3
				WHERE 
					GY3.GY3_FILIAL = %xFilial:GY3%
					AND GY3.%NotDel%
					AND GY3.GY3_CODAG BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% 
					AND GY3.GY3_DTENTR BETWEEN %Exp:DtoS(MV_PAR03)% AND %Exp:DtoS(MV_PAR04)%
					AND GY3.GY3_DTCANC = ''
				)
	EndSql
Else
	//Pendências de Demonstrativos de Taxas	
		BeginSql Alias cAliasTemp
		
			SELECT 
				G57.G57_CODIGO,
				G57.G57_VALOR, 
				G57.G57_VALACE,
				G57.G57_CONFER
			FROM 
				%Table:G57% G57 
			WHERE
				G57.G57_FILIAL = %xFilial:G57%
				AND G57.%NotDel% 
				AND G57.G57_AGENCI BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
				AND G57.G57_NUMMOV IN (
					SELECT 
						G5A.G5A_CODDT 
					FROM 
						%Table:G5A% G5A 
					WHERE 
						G5A.G5A_FILIAL = %xFilial:G5A%
						AND G5A.%NotDel%
						AND G5A.G5A_DTEMIS BETWEEN %Exp:DtoS(MV_PAR03)% AND %Exp:DtoS(MV_PAR04)%
						AND G5A.G5A_DTCANC = ''
				)
	EndSql
	
EndIf

Return cAliasTemp
