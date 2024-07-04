#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TMSR630.CH"

/*/-----------------------------------------------------------
{Protheus.doc} TMSR630()
Demonstrativo de Agendamento

Uso: SIGATMS

@sample
//TMSR630()

@author Paulo Henrique Corrêa Cardoso.
@since 05/09/2014
@version 1.0
-----------------------------------------------------------/*/

Function TMSR630()

Local oReport
Local aArea := GetArea()

//-- Interface de impressao
oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return

/*/-----------------------------------------------------------
{Protheus.doc} ReportDef

Uso: SIGATMS

@sample
//TMSR630()

@author Paulo Henrique Corrêa Cardoso.
@since 05/09/2014
@version 1.0
-----------------------------------------------------------/*/

Static Function ReportDef()
Local oReport					// Recebe o Objeto do Report
Local oDYX						// Recebe o Objeto da Section 
Local cPergunt := "TMSR630"		// Recebe o Pergunte
Local lAgdEntr     := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)   //-- Agendamento de Entrega.

If lAgdEntr
	
	Pergunte(cPergunt, .F.)

	DEFINE REPORT oReport NAME "TMSR630" TITLE STR0001 PARAMETER cPergunt ACTION {|oReport| ReportPrint(oReport)} //"Demonstrativo de Agendamento" 
	
	oReport:SetLandscape()
	
	DEFINE SECTION oDYX OF oReport TITLE STR0002 TABLES "DT6","DYD" //Itens
	
	DEFINE CELL NAME "DYD_NUMAGD" OF oDYX ALIAS "DYD"
	DEFINE CELL NAME "DYD_DATAGD" OF oDYX ALIAS "DYD"
	DEFINE CELL NAME "DYD_PRDAGD" OF oDYX ALIAS "DYD"
	DEFINE CELL NAME "DYD_INIAGD" OF oDYX ALIAS "DYD"
	DEFINE CELL NAME "DYD_FIMAGD" OF oDYX ALIAS "DYD"
	DEFINE CELL NAME "DYD_FILDOC" OF oDYX ALIAS "DYD"
	DEFINE CELL NAME "DYD_DOC" 	  OF oDYX ALIAS "DYD"
	DEFINE CELL NAME "DYD_SERIE"  OF oDYX ALIAS "DYD"
	DEFINE CELL NAME "DT6_NOMREM" OF oDYX ALIAS "DT6"
	DEFINE CELL NAME "DT6_NOMDES" OF oDYX ALIAS "DT6"
	DEFINE CELL NAME "DT6_FILDES" OF oDYX ALIAS "DT6"
	DEFINE CELL NAME "DYD_TIPAGD" OF oDYX ALIAS "DYD"
	DEFINE CELL NAME "DYD_STATUS" OF oDYX ALIAS "DYD"
	DEFINE CELL NAME "DYD_DIAATR" OF oDYX ALIAS "DYD"
	DEFINE CELL NAME "DT6_DATENT" OF oDYX ALIAS "DT6"
	
	oDYX:Cell("DT6_DATENT"):Disable()
	
	
	// Realiza o Calculo do Dias de Atraso
	oDYX:Cell("DYD_DIAATR"):SetBlock({ || DYD_DIAATR + IIF(!Empty(DYD_DATAGD).AND. !Empty(DT6_DATENT), ( DT6_DATENT - DYD_DATAGD ),0 ) })
	
Else
	Help('', 1,"HELP",, STR0010 ,1)// "Dicionário de dados desatualizado: Avalie execução update TMS11R126 e se a função de Agendamento de entrega (TMSA018) encontra-se no repositório.” 
EndIf

Return oReport


/*/-----------------------------------------------------------
{Protheus.doc} PrintReport()
Imprime o Relatorio

Uso: TMSR630

@sample
//PrintReport(oReport)

@author Paulo Henrique Corrêa Cardoso.
@since 05/09/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function ReportPrint(oReport)
Local cWhere    := ""				// Recebe a condição Where dinamica
Local cQuery    := ""				// Recebe a Query
Local cAliasQry := GetNextAlias()	// Recebe o proximo alias disponivel para a Query do Relatorio

// Cria a Query de Busca do Relatório
BEGIN REPORT QUERY oReport:Section(1)

BeginSql Alias cAliasQry

	SELECT		DYD.DYD_NUMAGD				,
				DYD.DYD_DATAGD              ,
				DYD.DYD_PRDAGD              ,
				DYD.DYD_INIAGD              ,
				DYD.DYD_FIMAGD              ,
				DYD.DYD_DIAATR				,
				DT6.DT6_DATENT 				,
				DYD.DYD_FILDOC				,
				DYD.DYD_DOC					,
				DYD.DYD_SERIE				,
				A1R.A1_NREDUZ     DT6_NOMREM,
				A1D.A1_NREDUZ     DT6_NOMDES,
				DT6.DT6_FILDES              ,
				DYD.DYD_TIPAGD              ,
				DYD.DYD_STATUS				
				
	FROM %table:DYD%  DYD 

		LEFT JOIN %table:DT6%  DT6  ON DT6.DT6_FILIAL = %xFilial:DT6% AND DT6.DT6_NUMAGD = DYD.DYD_NUMAGD AND DT6.%NotDel%
		LEFT JOIN %table:DTC%  DTC  ON DTC.DTC_FILIAL = %xFilial:DTC% AND DTC.DTC_NUMAGD = DYD.DYD_NUMAGD AND DTC.%NotDel%
		LEFT JOIN %table:SA1%  A1R  ON A1R.A1_FILIAL  = %xFilial:SA1% AND A1R.A1_COD     = DT6.DT6_CLIREM AND A1R.A1_LOJA    = DT6.DT6_LOJREM AND A1R.%NotDel%
		LEFT JOIN %table:SA1%  A1D  ON A1D.A1_FILIAL  = %xFilial:SA1% AND A1D.A1_COD     = DT6.DT6_CLIDES AND A1D.A1_LOJA    = DT6.DT6_LOJDES AND A1D.%NotDel%

		WHERE DYD.%NotDel%
		AND DYD.DYD_FILIAL = %xFilial:DYD%
		
		AND (
				(  DTC.%NotDel%
					AND DTC.DTC_FILIAL = %xFilial:DTC%
					AND DTC.DTC_FILDOC <> " "
					AND DTC.DTC_DOC    <> " "
					AND DTC.DTC_SERIE  <> " "
				 )
				OR (DYD.DYD_STATUS = "6" )
			 )
		AND (DYD.DYD_DATAGD BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%  OR (DYD.DYD_STATUS = "5" AND DYD.DYD_DATAGD = " "))
		AND DYD.DYD_STATUS BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR04%
		AND DYD.DYD_DIAATR BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR06%
		
		GROUP BY 
				DYD.DYD_NUMAGD	,
				DYD.DYD_DATAGD  ,
				DYD.DYD_PRDAGD  ,
				DYD.DYD_INIAGD  ,
				DYD.DYD_FIMAGD  ,
				DYD.DYD_DIAATR 	,
				DT6.DT6_DATENT ,
				DYD.DYD_FILDOC	,
				DYD.DYD_DOC		,
				DYD.DYD_SERIE	,
				A1R.A1_NREDUZ  	,
				A1D.A1_NREDUZ  	,
				DT6.DT6_FILDES  ,
				DYD.DYD_TIPAGD  ,
				DYD.DYD_STATUS

		ORDER BY DYD.DYD_DATAGD, DYD.DYD_TIPAGD
EndSql

END REPORT QUERY oReport:Section(1) 


// Totalizador de Controle
TRFunction():New(oReport:Section(1):Cell("DYD_STATUS")	,"QTDGERAL"	,"COUNT",,"QTDGERAL",,,.F.,.F.,,,)

// Cria os Totalizadores de exibição
TRFunction():New(oReport:Section(1):Cell("DYD_STATUS")	,"QtdAberto"	,"COUNT",,STR0005,,,.F.,.T.,,,{||DYD_STATUS == '1'}) //"Em Aberto"
TRFunction():New(oReport:Section(1):Cell("DYD_STATUS")	,"QtdRealiz"	,"COUNT",,STR0003,,,.F.,.T.,,,{||DYD_STATUS == '2'}) //"Realizado"
TRFunction():New(oReport:Section(1):Cell("DYD_STATUS")	,"QtdRealiAtr"	,"COUNT",,STR0004,,,.F.,.T.,,,{||DYD_STATUS == '3'}) //"Realizado com Atraso"
TRFunction():New(oReport:Section(1):Cell("DYD_STATUS")	,"QtdNaoAtend"	,"COUNT",,STR0006,,,.F.,.T.,,,{||DYD_STATUS == '4'}) //"Não Atendido"
TRFunction():New(oReport:Section(1):Cell("DYD_STATUS")	,"QtdCancelad"	,"COUNT",,STR0007,,,.F.,.T.,,,{||DYD_STATUS == '6'}) //"Cancelado"
TRFunction():New(oReport:Section(1):Cell("DYD_STATUS")	,"QtdAguarAgd"	,"COUNT",,STR0008,,,.F.,.T.,,,{||DYD_STATUS == '5'}) //"Aguardando Agendamento"


oReport:Section(1):Print()

// Adiciona os percentuais nos totalizadores
oReport:Section(1):GetFunction("QtdAberto"):uReport := cValToCHar(oReport:Section(1):GetFunction("QtdAberto"):uReport) +;
 "  ("+ cValToChar( Round((oReport:Section(1):GetFunction("QtdAberto"):uReport*100)/oReport:Section(1):GetFunction("QTDGERAL"):uReport,2))+"%)"
 
oReport:Section(1):GetFunction("QtdRealiz"):uReport := cValToCHar(oReport:Section(1):GetFunction("QtdRealiz"):uReport) +;
 "  ("+ cValToChar( Round((oReport:Section(1):GetFunction("QtdRealiz"):uReport*100)/oReport:Section(1):GetFunction("QTDGERAL"):uReport,2))+"%)"
 
oReport:Section(1):GetFunction("QtdNaoAtend"):uReport := cValToCHar(oReport:Section(1):GetFunction("QtdNaoAtend"):uReport) +;
 "  ("+ cValToChar( Round((oReport:Section(1):GetFunction("QtdNaoAtend"):uReport*100)/oReport:Section(1):GetFunction("QTDGERAL"):uReport,2))+"%)"
 
oReport:Section(1):GetFunction("QtdRealiAtr"):uReport := cValToCHar(oReport:Section(1):GetFunction("QtdRealiAtr"):uReport) +; 
"  ("+ cValToChar( Round((oReport:Section(1):GetFunction("QtdRealiAtr"):uReport*100)/oReport:Section(1):GetFunction("QTDGERAL"):uReport,2))+"%)"

oReport:Section(1):GetFunction("QtdCancelad"):uReport := cValToCHar(oReport:Section(1):GetFunction("QtdCancelad"):uReport) +; 
"  ("+ cValToChar( Round((oReport:Section(1):GetFunction("QtdCancelad"):uReport*100)/oReport:Section(1):GetFunction("QTDGERAL"):uReport,2))+"%)"

oReport:Section(1):GetFunction("QtdAguarAgd"):uReport := cValToCHar(oReport:Section(1):GetFunction("QtdAguarAgd"):uReport) +; 
"  ("+ cValToChar( Round((oReport:Section(1):GetFunction("QtdAguarAgd"):uReport*100)/oReport:Section(1):GetFunction("QTDGERAL"):uReport,2))+"%)"

Return
