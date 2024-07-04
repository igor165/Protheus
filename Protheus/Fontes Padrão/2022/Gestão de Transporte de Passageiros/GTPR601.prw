#include 'PROTHEUS.CH'
#include 'PARMTYPE.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR601
Novo relatório de listagem de pedágios

@author Gustavo.lopes   
@since 10/02/2022
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
Function GTPR601()
Local cPerg := "GTPR601"
Private oReport

If Pergunte( cPerg, .T. )
	oReport := ReportDef( cPerg )
	oReport:PrintDialog()
Endif

Return
/*SELECT  G6R_CODIGO,G6R_DTINCL,G6R_SA1COD,G6R_SA1LOJ,A1_NOME,G6R_SA3COD,A3_NOME,G6R_DTIDA,G6R_DTVLTA,G6R_TIPITI,G6R_LOCORI,GI1ORI.GI1_DESCRI,G6R_LOCDES,GI1DES.GI1_DESCRI,G6R_PDTOT,G6R_FILIAL
FROM	G6RT10 G6R 
INNER JOIN SA1T10 SA1 
ON SA1.A1_FILIAL = 'D MG' AND SA1.A1_COD = G6R.G6R_SA1COD AND SA1.A1_LOJA = G6R.G6R_SA1LOJ AND SA1.D_E_L_E_T_ = ''
INNER JOIN SA3T10 SA3
ON SA3.A3_FILIAL = 'D MG' AND SA3.A3_COD = G6R.G6R_SA3COD AND SA3.D_E_L_E_T_=''
INNER JOIN GI1T10 GI1ORI
ON GI1ORI.GI1_FILIAL ='' AND GI1ORI.GI1_COD = G6R.G6R_LOCORI AND GI1ORI.D_E_L_E_T_=''
INNER JOIN GI1T10 GI1DES
ON GI1DES.GI1_FILIAL ='' AND GI1DES.GI1_COD = G6R.G6R_LOCDES AND GI1DES.D_E_L_E_T_=''
WHERE	G6R.G6R_FILIAL = 'D MG 01'
		AND G6R.G6R_DTIDA >= '19000826' AND G6R.G6R_DTVLTA <= '20230826'
		AND G6R.G6R_CODIGO BETWEEN '000298' AND 'GTP002'
		AND G6R.G6R_SA3COD BETWEEN '' AND 'ZZZZZZ' 
		AND G6R.G6R_SA1COD + G6R.G6R_SA1LOJ BETWEEN '' AND 'ZZZZZZZZ' 
		AND G6R.G6R_PDTOT > 0 
		--AND G6R_PDTOT = 0
		AND G6R.D_E_L_E_T_ = ''


*/

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definições do Relatório

@author Gustavo.lopes   
@since 10/02/2022
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)
Local oReport   := Nil
Local oSection1 := Nil

//Ajuste no Layout para apresentar as informações de pedagio.
oReport := TReport():New("GTPR601","listagem de pedágios",cPerg,{|oReport| ReportPrint(oReport)},"texto",.T.) //"Resumo Diário Contratos - Data Viagem"
oReport:nFontBody := 8
oReport:SetTotalInLine(.F.)
oReport:SetLeftMargin(01) 

oSection1:= TRSection():New(oReport,"Dados Filial", {"G6R","SM0"}, , .F., .T.) //
//,G6R_SA1COD,G6R_SA1LOJ,A1_NOME,G6R_SA3COD,A3_NOME,G6R_DTIDA,G6R_DTVLTA,G6R_TIPITI,G6R_LOCORI,GI1ORI.GI1_DESCRI,G6R_LOCDES,GI1DES.GI1_DESCRI,G6R_PDTOT,G6R_FILIAL
TRCell():New(oSection1,"G6R_CODIGO","G6R","Contrato ",,15) //"DT. EMISSÃO"
TRCell():New(oSection1,"G6R_DTINCL","G6R","Data Emissão",,22) //"CONTRATO"
TRCell():New(oSection1,"G6R_SA1COD","G6R","Cliente",,12) //"ITINERARIO"
TRCell():New(oSection1,"G6R_SA1LOJ","G6R","Loja",,5) //"ORIGEM"
TRCell():New(oSection1,"A1_NOME","G6R","Nome",,25) //"DT. INICIO"
TRCell():New(oSection1,"G6R_SA3COD","G6R","Vendedor",,15) //"DESTINO"
TRCell():New(oSection1,"A3_NOME","G6R","Nome",,42) //"DT. FIM"
TRCell():New(oSection1,"G6R_DTIDA","G6R","Data Ida",,20) //"PEDAGIO"
TRCell():New(oSection1,"G6R_DTVLTA","G6R","Data volta",,20) //"KM"
TRCell():New(oSection1,"G6R_TIPITI","G6R","Itinerário",,20) //"VALOR"
TRCell():New(oSection1,"G6R_LOCORI","G6R","Origem",,12) //"STATUS"
TRCell():New(oSection1,"LOCORI","G6R","Descrição",,25) //"STATUS"
TRCell():New(oSection1,"G6R_LOCDES","G6R","Destino",,12) //"STATUS"
TRCell():New(oSection1,"LOCDES","G6R","Descrição",,25) //"STATUS"
TRCell():New(oSection1,"G6R_PDTOT","G6R","Pedágio",,12) //"STATUS"


TRFunction():New(oSection1:Cell("G6R_PDTOT"),"TOTAL PEDÁGIO","SUM",,,,,.F.,.T.)
 	
Return(oReport)


Static Function ReportPrint(oReport)
	Local oSection  := oReport:Section(1)
	Local cWhere    := "%%"

	if MV_PAR11 == 1
		cWhere    := "% AND G6R.G6R_PDTOT > 0 %"

	elseif MV_PAR11 == 2
		cWhere    := "% AND G6R.G6R_PDTOT = 0 %"

	ENDIF 
		
	                           	                
	
	//Busca os dados da Secao principal
	oSection:BeginQuery()
	BeginSql alias "QRYAUX"	
	SELECT  G6R_CODIGO,G6R_DTINCL,G6R_SA1COD,G6R_SA1LOJ,A1_NOME,G6R_SA3COD,A3_NOME,G6R_DTIDA,G6R_DTVLTA,G6R_TIPITI,G6R_LOCORI,GI1ORI.GI1_DESCRI LOCORI,G6R_LOCDES,GI1DES.GI1_DESCRI LOCDES,G6R_PDTOT,G6R_FILIAL
	FROM	%table:G6R% G6R 
	INNER JOIN %table:SA1% SA1 
	ON SA1.A1_FILIAL = %xFilial:SA1% AND SA1.A1_COD = G6R.G6R_SA1COD AND SA1.A1_LOJA = G6R.G6R_SA1LOJ AND SA1.%NotDel%
	INNER JOIN %table:SA3% SA3
	ON SA3.A3_FILIAL = %xFilial:SA3% AND SA3.A3_COD = G6R.G6R_SA3COD AND SA3.%NotDel%
	INNER JOIN %table:GI1% GI1ORI
	ON GI1ORI.GI1_FILIAL = %xFilial:GI1% AND GI1ORI.GI1_COD = G6R.G6R_LOCORI AND GI1ORI.%NotDel%
	INNER JOIN %table:GI1% GI1DES
	ON GI1DES.GI1_FILIAL = %xFilial:GI1% AND GI1DES.GI1_COD = G6R.G6R_LOCDES AND GI1DES.%NotDel%
	WHERE	G6R.G6R_FILIAL = %xFilial:G6R%
			AND G6R.G6R_DTIDA >= %EXP:MV_PAR01% AND G6R.G6R_DTVLTA <= %EXP:MV_PAR02%
			AND G6R.G6R_CODIGO BETWEEN %EXP:MV_PAR03% AND %EXP:MV_PAR04%
			AND G6R.G6R_SA3COD BETWEEN %EXP:MV_PAR05% AND %EXP:MV_PAR06%
			AND G6R.G6R_SA1COD + G6R.G6R_SA1LOJ BETWEEN %EXP:MV_PAR07+MV_PAR08% AND %EXP:MV_PAR09+MV_PAR10% 
			AND G6R.%NotDel%			
			%Exp:cWhere% 
	ORDER BY G6R_SA3COD, G6R_DTINCL
	EndSql	
	oSection:EndQuery()
             
	//Pinta o Relatorio
	While QRYAUX->(!Eof())		
        //Se nivel detalhe
      	oSection:Init()	
		oSection:PrintLine()
		QRYAUX->(dbSkip())						
	EndDo
	//Finaliza a impressão
	oSection:Finish()
	
Return

