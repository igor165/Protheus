#INCLUDE "protheus.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPR006.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPR006
Relatório horário de atendimento
@type function
@author osmar cioni
@since 
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTPR006()
	Local oReport 
	Local cPerg := 'ENCAGEN'
	Pergunte(cPerg,.T.)
	oReport := ReportDef(cPerg) 
	oReport:PrintDialog()	

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

@type function
@author osmar cioni
@since 
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function ReportDef(cPerg)
	Local oReport
	Local oSection

	//Instancia Objeto do Relatorio
	oReport := TReport():New("GTPR006",STR0001,cPerg,{|oReport| PrintReport(oReport)},STR0001)
	oSection := TRSection():New(oReport	,STR0001,{"GI6"})
	
	//Define as Celulas do Relatorio	
	TRCell():New(oSection,"GI6_CODIGO"	,"QRYAUX",RetTitle("GI6_CODIGO"	),PesqPict("GI6","GI6_CODIGO"	),TamSx3("GI6_CODIGO"	)[1],/*lPixel*/,{|| QRYAUX->GI6_CODIGO							},/*cAlign*/,/*lLineBreak*/) 	
	TRCell():New(oSection,"GI6_DESCRI"	,"QRYAUX",RetTitle("GI6_DESCRI"	),PesqPict("GI6","GI6_DESCRI"	),TamSx3("GI6_DESCRI"	)[1],/*lPixel*/,{|| QRYAUX->GI6_DESCRI							},/*cAlign*/,/*lLineBreak*/)
	TRCell():New(oSection,"GI6_TIPO"	,"QRYAUX",RetTitle("GI6_TIPO"	),PesqPict("GI6","GI6_TIPO"		),10					    ,/*lPixel*/,{|| IIf(QRYAUX->GI6_TIPO=='1',STR0002,STR0003)	},/*cAlign*/,/*lLineBreak*/)  
	TRCell():New(oSection,"GI1_DESCRI"	,"QRYAUX",RetTitle("GI6_LOCALI"	),PesqPict("GI1","GI1_DESCRI"	),TamSx3("GI1_DESCRI"	)[1],/*lPixel*/,{|| QRYAUX->GI1_DESCRI							},/*cAlign*/,/*lLineBreak*/) 
	TRCell():New(oSection,"GI6_ENCHRI"	,"QRYAUX",RetTitle("GI6_ENCHRI"	),PesqPict("GI6","GI6_ENCHRI"	),TamSx3("GI6_ENCHRI"	)[1],/*lPixel*/,{|| QRYAUX->GI6_ENCHRI							},/*cAlign*/,/*lLineBreak*/)
	TRCell():New(oSection,"GI6_ENCHRF"	,"QRYAUX",RetTitle("GI6_ENCHRF"	),PesqPict("GI6","GI6_ENCHRF"	),TamSx3("GI6_ENCHRF"	)[1],/*lPixel*/,{|| QRYAUX->GI6_ENCHRF							},/*cAlign*/,/*lLineBreak*/)
	TRCell():New(oSection,"GI6_FILRES"	,"QRYAUX",RetTitle("GI6_NFILRE"	),/**/							 ,50					    ,/*lPixel*/,{|| FWFilialName(cEmpAnt,QRYAUX->GI6_FILRES)	},/*cAlign*/,/*lLineBreak*/) 
	
		
Return oReport

//------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport

@type function
@author osmar cioni
@since 
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function PrintReport(oReport)
	Local oSection  := oReport:Section(1)
	Local cWhere    := ""
	                           	                       
    //Monta a clausula "Where" com os MV_PARs
	cWhere := "% AND GI6.GI6_CODIGO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' %"			//Agencia De Atendimento De/Ate
                 
	//Busca os dados da Secao principal
	oSection:BeginQuery()
	BeginSql alias "QRYAUX"	
		SELECT	GI6_CODIGO,
				GI6_DESCRI,
				GI6_TIPO,
				GI1_DESCRI,
				GI6_ENCHRI,
				GI6_ENCHRF,							
				GI6_FILRES 
		FROM %table:GI6% GI6 
		INNER JOIN %table:GI1% GI1 
			ON GI1.GI1_FILIAL = %xFilial:GI1%
			AND GI1_COD = GI6_LOCALI
			AND GI1.%NotDel%
		WHERE				
			GI6.GI6_FILIAL = %xFilial:GI6%
			AND GI6.GI6_ENCEXP = '1'			
			AND GI6.%NotDel%
			%Exp:cWhere%				
				
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
