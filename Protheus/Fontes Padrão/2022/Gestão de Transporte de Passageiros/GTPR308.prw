#include 'protheus.ch'
#include 'parmtype.ch'
#include 'GTPR308.ch'
#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} GTPR308
Relatório de Quilometragem Estatística por Km x Preço

@type function
@author jacomo.fernandes
@since 16/11/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPR308()
	
	Local oReport
	Local cPerg   := "GTPR308"

	If Pergunte( cPerg, .T. )
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf
	
Return

/*/{Protheus.doc} ReportDef
(long_description)
@type function
@author jacomo.fernandes
@since 16/11/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportDef()

	Local oReport
	Local oSection1 
	Local oSection2
	
	oReport := TReport():New(STR0001,STR0002,"GTPR308",{|oReport| ReportPrint(oReport)},STR0003)//"Prestação de Contas""Relatório de Quilometragem Estatística por KM X Preço""Este relatorio ira imprimir o Relatório de Quilometragem Estatística por KM X Preço."
	oReport:lParamPage := .T. //Exibe a Primeira Pagina Rosto.
	oReport:nFontBody := 6
	
	oSection1:= TRSection():New(oReport, STR0004, {"GI2","GQC"}) //"Quilometragem Estatística por Km x Preço"
	
	TRCell():New(oSection1,"GI2_TIPLIN"	,"GI2", "Código"	,"@!"	,TamSX3("GI2_TIPLIN")[1]) //"Código"
	TRCell():New(oSection1,"GQC_DESCRI"	,"GQC", "Descrição"	,"@!"	,TamSX3("GQC_DESCRI")[1]) //"Descrição"
	
	oSection2:= TRSection():New(oSection1, STR0004, {"GI2", "GI4","GYN","GI1"}) //"Quilometragem Estatística por Km x Preço"
	
	
	TRCell():New(oSection2,"GI2_NUMLIN"	,"GYN", STR0005			,							, TamSX3("GI2_NUMLIN")[1],,,,,,,,,,,.F.) //"Linha"
	TRCell():New(oSection2,"NOMELINHA"	,"GYN", STR0006			, X3Picture("GYN_CODLIN")	, TamSX3("GI3_NLIN")[1]+10 ) //"Descrição"
	TRCell():New(oSection2,"GYN_TIPO"	,"GYN", "Tp Viagem"		, '@!'						, 2  )//"Tipo Viagem" 
	TRCell():New(oSection2,"TOTVIAG"	,"GI4", "Tot Viagem"	,							, 3  )//"Total de Viagem"
	TRCell():New(oSection2,"TOTCOMP"	,"GI4", "Tot Completa"	,							, 3  )//"Total de Viagem"
	TRCell():New(oSection2,"TOTPARC"	,"GI4", "Tot Parcial"	,							, 3  )//"Total de Viagem"
	TRCell():New(oSection2,"KMASFA"		,"GI4", "Km Asfalto"	, "@E 9,999,999"	, TamSX3("GI4_KMASFA")[1]+1  ) //"KM Asfalto"
	TRCell():New(oSection2,"KMTERRA"	,"GI4", "Km Terra"		, "@E 9,999,999"	, TamSX3("GI4_KMTERR")[1]+1 ) //"KM Terra"
	TRCell():New(oSection2,"KMTOTAL"	,"GI4", "Km Total" 		, "@E 9,999,999"	, TamSX3("GI4_KMTERR")[1]+3 )  //"KM Total "
		
	oSection2:SetLeftMargi(5)
	oSection2:SetTotalInLine(.F.)
	
	
	oBreak:= TRBreak():New(oSection1,{||oSection1:Cell("GI2_TIPLIN") },"",.T.)
 
	oBreak:SetPageBreak(.T.)
	
	TRFunction():New(oSection2:Cell("KMTOTAL")		,,"SUM"	,,"Total de KM","@E 9,999,999,999",,.T.,.F.,.T.)     	

	
Return oReport

/*/{Protheus.doc} ReportPrint
(long_description)
@type function
@author jacomo.fernandes
@since 16/11/2018
@version 1.0
@param oReport, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportPrint(oReport)
Local oSection1		:= oReport:Section(1)
Local oSection2		:= oSection1:Section(1)

Local cAliasTemp	:= QryRelatorio()

Local cTpLinha		:= ""
Local cNomeLinha	:= ""
Local lFistPage		:= .T.

If (cAliasTemp)->(!EOF())
	oReport:SetMeter((cAliasTemp)->(RecCount()))
	
	oReport:StartPage()
	oReport:SkipLine()
	
	//Seta o valor do relatório
	While !oReport:Cancel() .AND. (cAliasTemp)->(!Eof())
		If cTpLinha <> (cAliasTemp)->GI2_TIPLIN
			
			oSection1:Cell("GI2_TIPLIN"):SetValue((cAliasTemp)->GI2_TIPLIN)
			oSection1:Cell("GQC_DESCRI"):SetValue((cAliasTemp)->GQC_DESCRI)
			
			If !lFistPage
				oSection2:Finish()
				oSection1:Finish()
			Endif
			
			oSection1:Init()
			oSection1:Printline()
			
			oSection2:Init()
			
			cTpLinha := (cAliasTemp)->GI2_TIPLIN 
			lFistPage:= .F.
			
		Endif
		
		cNomeLinha := Alltrim((cAliasTemp)->LOCORI) + " x " + Alltrim((cAliasTemp)->LOCDES) 
		//oSection2:Cell("GI2_TIPLIN"	):SetValue((cAliasTemp)->GI2_TIPLIN)
		
		oSection2:Cell("GI2_NUMLIN"	):SetValue((cAliasTemp)->GI2_NUMLIN)
		oSection2:Cell("NOMELINHA"	):SetValue(cNomeLinha)
		
		oSection2:Cell("GYN_TIPO"	):SetValue(If((cAliasTemp)->(GYN_TIPO) == '1',"Normal","Extraordinaria"))
		oSection2:Cell("TOTVIAG"	):SetValue((cAliasTemp)->QUANTIDADE_VIAGEM)
		oSection2:Cell("TOTCOMP"	):SetValue((cAliasTemp)->QUANTIDADE_VIAGEM)
		oSection2:Cell("TOTPARC"	):SetValue(0)
		oSection2:Cell("KMASFA"		):SetValue((cAliasTemp)->TOTAL_KM_ASFALTO)
		oSection2:Cell("KMTERRA"	):SetValue((cAliasTemp)->TOTAL_KM_TERRA)
		oSection2:Cell("KMTOTAL"	):SetValue((cAliasTemp)->TOTAL_KM_GERAL)
		oSection2:Printline()
		
		(cAliasTemp)->(DbSkip())
	End
	
	oSection2:Finish()
	oSection1:Finish()
	
Else	
	FwAlertHelp("Não foram encontrados dados para o relatório","Verifique os paramêtros informados","NAOHADADOS")
Endif

(cAliasTemp)->(DbCloseArea())


Return


/*/{Protheus.doc} QryRelatorio
(long_description)
@type function
@author jacomo.fernandes
@since 16/11/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function QryRelatorio()

Local cAliasTemp 	:= GetNextAlias()
Local cTpLinDe		:= MV_PAR01
Local cTpLinAte		:= MV_PAR02
Local dDataDe		:= MV_PAR03
Local dDataAte		:= MV_PAR04
Local cNumLinDe		:= MV_PAR05
Local cNumLinAte	:= MV_PAR06


	BeginSQL alias cAliasTemp

		SELECT 
			GI2.GI2_TIPLIN,
			GQC.GQC_DESCRI,
			GI2.GI2_NUMLIN,
			GYN.GYN_TIPO,
			GI1ORI.GI1_DESCRI AS LOCORI,
			GI1DES.GI1_DESCRI AS LOCDES,
			COUNT(GYN_CODIGO) AS QUANTIDADE_VIAGEM,
			SUM(GI4_KM) TOTAL_KM_GERAL,
			SUM(GI4_KMASFA) AS TOTAL_KM_ASFALTO,
			SUM(GI4.GI4_KMTERR) AS TOTAL_KM_TERRA
		FROM %Table:GI2% GI2
			INNER JOIN %Table:GYN% GYN ON
				GYN.GYN_FILIAL = GI2.GI2_FILIAL
				AND GYN.GYN_LINCOD = GI2.GI2_COD
				AND GYN.GYN_DTINI BETWEEN %Exp:dDataDe% AND %Exp:dDataAte%
				AND GYN.%NotDel%
			INNER JOIN %Table:GI4% GI4 ON
				GI4.GI4_FILIAL = GI2.GI2_FILIAL
				AND GI4.GI4_LINHA = GI2.GI2_COD
				AND GI4.GI4_HIST = '2'
				AND GI4.GI4_LOCORI = GI2_LOCINI
				AND GI4.GI4_LOCDES = GI2_LOCFIM
				AND GI4.%NotDel%
			INNER JOIN %Table:GI1% GI1ORI ON
				GI1ORI.GI1_FILIAL = %xFilial:GI1%
				AND GI1ORI.GI1_COD = (CASE 
										WHEN GI2.GI2_KMIDA > 0 THEN GI2.GI2_LOCINI
										WHEN GI2.GI2_KMVOLT > 0 THEN GI2.GI2_LOCFIM
										ELSE GI2.GI2_LOCINI
									END)
				AND GI1ORI.%NotDel% 
			INNER JOIN %Table:GI1% GI1DES ON
				GI1DES.GI1_FILIAL = %xFilial:GI1%
				AND GI1DES.GI1_COD = (CASE 
										WHEN GI2.GI2_KMIDA > 0 THEN GI2.GI2_LOCFIM
										WHEN GI2.GI2_KMVOLT > 0 THEN GI2.GI2_LOCINI
										ELSE GI2.GI2_LOCFIM
									END)
				AND GI1DES.%NotDel%
			INNER JOIN %Table:GQC% GQC ON
				GQC.GQC_FILIAL = %xFilial:GQC%
				AND GQC.GQC_CODIGO = GI2.GI2_TIPLIN 
				AND GQC.%NotDel%
		WHERE 
			GI2.GI2_FILIAL = %xFilial:GI2%
			AND GI2.GI2_NUMLIN BETWEEN %Exp:cNumLinDe% AND %Exp:cNumLinAte%
			AND GI2.GI2_TIPLIN BETWEEN %Exp:cTpLinDe% AND %Exp:cTpLinAte%
			AND GI2.GI2_HIST = '2'
			AND GI2.%NotDel%
		GROUP BY 
			GI2.GI2_TIPLIN,
			GQC.GQC_DESCRI,
			GI2.GI2_NUMLIN,
			GYN.GYN_TIPO,
			GI1ORI.GI1_DESCRI,
			GI1DES.GI1_DESCRI 
		ORDER BY GI2.GI2_TIPLIN,GI2_NUMLIN
					
	EndSQL

Return cAliasTemp
