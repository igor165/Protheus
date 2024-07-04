#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'gtpr500a.ch'
#INCLUDE "RPTDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR500A()
Relatório de Divergências Arrecadação x Tesouraria.
@author  SIGAGTP | Gabriela Naomi Kamimoto|   
@since   28/11/2017
@version P12
/*///-------------------------------------------------------------------
Function GTPR500A()
Private oReport
Private cPerg    := "GTPR500A"
		
If Pergunte( cPerg, .T. )

	if Empty(MV_PAR01) .AND. Empty(MV_PAR02) .AND.  Empty(MV_PAR03) .AND. Empty(MV_PAR04)
		Help(,,"Help", cPerg, "Preencha no mínimo os parametros de Data de Movimento De Até." , 1, 0)
		Return GTPR500A()
	EndIf
	
	if  !Empty(MV_PAR03) .AND. MV_PAR03 > MV_PAR04 
		Help(,,"Help", cPerg, "Preencha o intervalo de Datas corretamente." , 1, 0)
		Return GTPR500A()
	EndIf			

	oReport := ReportDef(cPerg)
	oReport:PrintDialog()
Else
	Alert( "Cancelado pelo usuário" )//"Cancelado pelo usuário"		
EndIf
	     
return


//-------------------------------------------------------------------
/*/{Protheus.doc} RptDef(cPerg)

Relatório de Divergências Arrecadação x Tesouraria
Definição do relatório.

@author  SIGAGTP | Gabriela Naomi Kamimoto|   
@since   28/11/2017
@version P12
/*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)
Local oReport
Local oSection1
Local oSection2
Local cTitulo := STR0001 //'[GTPR500A] - Relatório de Divergências Arrecadação x Tesouraria'
Local cAliasPas := GetNextAlias()
Local cAliasTax := GetNextAlias()

GetQuery(@cAliasPas, '1')
GetQuery(@cAliasTax, '2')
 
oReport := TReport():New('GTPR500A', cTitulo, cPerg, {|oReport| PrintReport(oReport,cAliasPas, cAliasTax)},STR0002) //"Este relatório irá imprimir Relatório de Divergências Arrecadação x Tesouraria"
oReport:SetTotalInLine(.F.)
oReport:ShowHeader(.F.)

oSection1 := TRSection():New(oReport,STR0003,{cAliasPas}) //"Divergências - Passagens"
oSection1:SetTotalInLine(.F.)

TRCell():New(oSection1, "NUMBIL"      , cAliasPas, STR0004 ,X3Picture("GIC_CODIGO"), TamSX3("GIC_CODIGO")[1]+1) // Número Bilhete
TRCell():New(oSection1, "VALTOT"      , cAliasPas, STR0005 ,X3Picture("GIC_VALTOT"), TamSX3("GIC_VALTOT")[1]+4) // Valor Total Ficha
TRCell():New(oSection1, "ACEARRECAD"  , cAliasPas, STR0006 ,X3Picture("GIC_VALTOT"), TamSX3("GIC_VALTOT")[1]+4) // Acerto Arrecadação
TRCell():New(oSection1, "DIVERGPASS"  , cAliasPas, STR0007 ,X3Picture("GIC_VALTOT"), TamSX3("GIC_VALTOT")[1]+4) // Divergência
TRCell():New(oSection1, "DTVENDA" 	  , cAliasPas, "Data Movimento" ,X3Picture("GIC_DTVEND"), TamSX3("GIC_DTVEND")[1]+4) // 

oSection2 := TRSection():New(oReport,STR0008,{cAliasTax}) //"Divergencias - Taxas"
oSection2:SetTotalInLine(.F.)

TRCell():New(oSection2, "NUMTAX"      , cAliasTax, STR0009 ,X3Picture("GIC_CODIGO"), TamSX3("GIC_CODIGO")[1]+1) // Número Bilhete
TRCell():New(oSection2, "TIPOTAX"     , cAliasTax, STR0010 ,X3Picture("GYA_DESCRI"), TamSX3("GYA_DESCRI")[1]+1) // Número Bilhete
TRCell():New(oSection2, "VALTOT"      , cAliasTax, STR0005 ,X3Picture("GIC_VALTOT"), TamSX3("GIC_VALTOT")[1]+4) // Valor Total Ficha
TRCell():New(oSection2, "ACEARRECAD"  , cAliasTax, STR0006 ,X3Picture("GIC_VALTOT"), TamSX3("GIC_VALTOT")[1]+4) // Acerto Arrecadação
TRCell():New(oSection2, "DIVERGTAX"   , cAliasTax, STR0007 ,X3Picture("GIC_VALTOT"), TamSX3("GIC_VALTOT")[1]+4) // Divergência
TRCell():New(oSection2, "DTEMISSA"    , cAliasTax, "Data Emissão" ,X3Picture("G57_EMISSA"), TamSX3("G57_EMISSA")[1]+4)  
 
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
Static Function PrintReport(oReport,cAliasPas, cAliasTax)
 
Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(2)
Local nDivergen  := 0
Local cTipo      := ""

DbSelectArea(cAliasPas)
dbGoTop()
oReport:SetMeter((cAliasPas)->(RecCount()))


While (cAliasPas)->(!Eof())
	
	oSection1:Init()
	
	If oReport:Cancel()
		Exit
	EndIf
		
	If (cAliasPas)->(GIC_CONFER) == '2' .And. (cAliasPas)->(GIC_VLACER) > 0
	
		nDivergen := (cAliasPas)->(GIC_VLACER) - (cAliasPas)->(GIC_VALTOT)
			
		oSection1:Cell("NUMBIL"):SetValue((cAliasPas)->(GIC_CODIGO))
		oSection1:Cell("VALTOT"):SetValue((cAliasPas)->(GIC_VALTOT))
		oSection1:Cell("ACEARRECAD"):SetValue((cAliasPas)->(GIC_VLACER))
		oSection1:Cell("DIVERGPASS"):SetValue(nDivergen)
		oSection1:Cell("DTVENDA"):SetValue(Stod((cAliasPas)->(GIC_DTVEND)))
		
		oSection1:Printline()

	EndIf
		
	(cAliasPas)->(DbSkip())
		
	oSection1:Finish()
	oReport:ThinLine()
	oReport:EndPage()
	
End

oSection2:Init()
	
While (cAliasTax)->(!Eof())

	If oReport:Cancel()
		Exit
	EndIf
		
	If (cAliasTax)->(G57_CONFER) == "2"
			
		nDivergen := (cAliasTax)->(G57_VALOR) - (cAliasTax)->(G57_VALACE)
			
		cTipo := Posicione("GYA",1, xFilial("GYA")+(cAliasTax)->(G57_TIPO),"GYA_DESCRI")
			
		oSection2:Cell("NUMTAX"):SetValue((cAliasTax)->(G57_CODIGO))
		oSection2:Cell("TIPOTAX"):SetValue(cTipo)
		oSection2:Cell("VALTOT"):SetValue((cAliasTax)->(G57_VALOR))
		oSection2:Cell("ACEARRECAD"):SetValue((cAliasTax)->(G57_VALACE))
		oSection2:Cell("DIVERGTAX"):SetValue(nDivergen)
		oSection2:Cell("DTEMISSA"):SetValue(Stod((cAliasTax)->(G57_EMISSA)))	
		
		oSection2:Printline()
		
	EndIf
	
	(cAliasTax)->(DbSkip())
	
End
	
oSection2:Finish()
oReport:ThinLine()
oReport:EndPage()

If Select(cAliasPas) > 0
	(cAliasPas)->(dbCloseArea())
EndIf

If Select(cAliasTax) > 0
	(cAliastax)->(dbCloseArea())
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} RptDef(cPerg)

Retorna a query 
Definição do relatório.

@author  SIGAGTP   
@since   05/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function GetQuery(cAlias, cQuery)
Local cAndG6X	:= ''
Local cAndG57	:= ''

if !Empty(MV_PAR01) 
	cAndG6X	:= " G6X.G6X_NUMFCH = '"+MV_PAR01+"' "
	cAndG57	:= " G57.G57_NUMFCH =  '"+MV_PAR01+"' "
EndIf

if  !Empty(MV_PAR02) 
	if !Empty(cAndG6X)
		cAndG6X	+= " AND "
		cAndG57	+= " AND "
	EndIf
	
	cAndG6X	+= " G6X.G6X_AGENCI = '"+MV_PAR02+"' "
	cAndG57	+= " G57.G57_AGENCI = '"+MV_PAR02+"' "			
EndIf

if !Empty(MV_PAR03) 
	if !Empty(cAndG6X)

		cAndG6X	+= " AND "
		cAndG57	+= " AND "
	EndIf
	
	cAndG6X	+= " '"+Dtos(MV_PAR03)+"' > = G6X.G6X_DTINI "
	cAndG6X	+= " AND '"+Dtos(MV_PAR04)+"' <= G6X.G6X_DTFIN "			
	cAndG57	+= " G57.G57_EMISSA BETWEEN '"+Dtos(MV_PAR03)+"' AND '"+Dtos(MV_PAR04)+"'  "	
EndIf

cAndG6X	:= '%'+cAndG6X+'%'
cAndG57	:= '%'+cAndG57+'%'

if cQuery = '1'		
	BeginSql Alias cAlias
		SELECT 
			GIC.GIC_CODIGO, 
			GIC.GIC_NUMFCH, 
			GIC.GIC_AGENCI, 
			GIC.GIC_STATUS, 
			GIC.GIC_VALTOT,
			GIC.GIC_VLACER,	
			GIC.GIC_CONFER, 
			GIC.GIC_DTVEND, 
			GIC.GIC_DTVIAG   
		FROM 
			%Table:GIC% GIC
		WHERE 
			GIC.GIC_FILIAL = %xFilial:GIC%
			AND GIC.%NotDel%
			AND GIC.GIC_NUMFCH IN ( SELECT G6X.G6X_NUMFCH
								FROM %Table:G6X% G6X
								WHERE G6X.G6X_FILIAL = %xFilial:G6X%
								AND G6X.%NotDel%
								AND %exp:cAndG6X%
								AND G6X.G6X_STATUS = '3'
								)
	EndSql
Else
	BeginSql Alias cAlias
		SELECT 
			G57.G57_CODIGO, 
			G57.G57_TIPO, 
			G57.G57_VALOR, 
			G57.G57_VALACE, 
			G57.G57_CONFER, 
			G57.G57_EMISSA
		FROM 
			%Table:G57% G57
		WHERE 
			G57.G57_FILIAL = %xFilial:G57%
			AND G57.%NotDel%
			AND %exp:cAndG57%
		
	EndSql
EndIf
	
Return
