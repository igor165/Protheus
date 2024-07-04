#INCLUDE "JURA191.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA191
Relatorio de extrato do correspodente

@author Rafael Tenorio da Costa
@since 08/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA191()

	Local oReport := ReportDef()
	
	oReport:PrintDialog()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definição do relatorio

@author Rafael Tenorio da Costa
@since 08/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

	Local oReport	:= Nil
	Local oSection1	:= Nil
	Local oSection2	:= Nil
	Local oSection3	:= Nil
	Local oSection4	:= Nil
	Local oSection5	:= Nil	
	Local oSection6	:= Nil
	Local oSecComar	:= Nil
	Local oSecArea	:= Nil
	Local cPergunta := "JURA191"
	Local cTabela	:= GetNextAlias()
	Local cTabComar	:= GetNextAlias()
	Local cTabArea	:= GetNextAlias()
	Local oBreak	:= Nil
	Local nEspaco	:= 3
	Local nMargem	:= 3
	
	oReport := TReport():New(	cPergunta, STR0006, cPergunta,;		//"Extrato do Correspondente"
								{ |oReport| ReportPrint(oReport		, @cTabela	, @cTabComar, @cTabArea		,;	
														oSection1	, oSection2	, oSection3	, oSection4		,;
														oSection5	, oSection6 , oSecComar , oSecArea) }	,;
														STR0001)	//"Este programa emitira o extrato do correspondente, imprimindo informações sobre os atos e os valores onde os correspondentes atuarão"
														
	Pergunte ( cPergunta, .F. )
	
	//Limpa dados do correspondente no pergunte
	Ja191LmpCo( cPergunta )	
	
	oSection1 := TRSection():New(oReport, STR0002, {"NZF","SA2"},,, .T.)	//"Dados do Correspondente"
  //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //TRCell():New(/*oSection*/,/*Campo*/		,/*Alias*/	,/*Titulo*/	,/*Picture*/					,/*Tamanho*/						,/*lPixel*/	,/*{|| code-block de impressao }*/, cAlign, lLineBreak, cHeaderAlign, lCellBreak, nColSpace, lAutoSize)
  //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	TRCell():New(oSection1	,"NZF_CCORRE"	,"NZF"		,			,								, TamSX3("NZF_CCORRE")[1] + nEspaco	, .F.	,{|| (cTabela)->NZF_CCORRE +"-"+ (cTabela)->NZF_LCORRE	})
	TRCell():New(oSection1	,"A2_NOME"		,"SA2"		,			,								, TamSX3("A2_NOME")[1] + nEspaco	, .F.	,{|| (cTabela)->A2_NOME	})
	TRCell():New(oSection1	,"NZF_AVISO" 	,"NZF"		,			,								,									, .F.	,{|| 					}, /*cAlign*/, .F./*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/, .T.)
	
	oSecComar := TRSection():New(oSection1, STR0003, {"NU3","NQ6"},,, .T.,,,,,,, nMargem)	//"Dados do Escritório"
	TRCell():New(oSecComar	,"NU3_CCOMAR"	,"NU3"		,			,								, TamSX3("NU3_CCOMAR")[1] + nEspaco	, .F.	,{|| (cTabComar)->NU3_CCOMAR})
	TRCell():New(oSecComar	,"NQ6_DESC"		,"NQ6"		,			,								, TamSX3("NQ6_DESC")[1] + nEspaco	, .F.	,{|| (cTabComar)->NQ6_DESC	}, /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/, .T.)
	
	oSecArea := TRSection():New(oSection1, STR0003, {"NVI","NRB"},,, .T.,,,,,,, nMargem)	//"Dados do Escritório"	
	TRCell():New(oSecArea	,"NVI_CAREA"	,"NVI"		,			,								, TamSX3("NVI_CAREA")[1] + nEspaco	, .F.	,{|| (cTabArea)->NVI_CAREA	})
	TRCell():New(oSecArea	,"NRB_DESC"		,"NRB"		,			,								, TamSX3("NRB_DESC")[1] + nEspaco	, .F.	,{|| (cTabArea)->NRB_DESC	}, /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/, .T.)
	nMargem += nEspaco	
	
	oSection2 := TRSection():New(oSection1, STR0003, {"NZF","NS7"},,, .T.,,,,,,, nMargem)	//"Dados do Escritório"
	TRCell():New(oSection2	,"NZF_CESCRI"	,"NZF"		,			,								, TamSX3("NZF_CESCRI")[1] + nEspaco	, .F.	,{|| (cTabela)->NZF_CESCRI 	})
	TRCell():New(oSection2	,"NS7_NOME"		,"NS7"		,			,								, TamSX3("NS7_NOME")[1] + nEspaco	, .F.	,{|| (cTabela)->NS7_NOME 	}, /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/, .T.)
	nMargem += nEspaco
	
	oSection3 := TRSection():New(oSection2, STR0004, {"NZF","NRB"},,, .T.,,,,,,, nMargem) 	//"Dados da Área"
	TRCell():New(oSection3	,"NZF_CAREA"	,"NZF"		,			,								, TamSX3("NZF_CAREA")[1]  + nEspaco	, .F.	,{|| (cTabela)->NZF_CAREA 	})
	TRCell():New(oSection3	,"NRB_DESC"		,"NRB"		,			,								, TamSX3("NRB_DESC")[1]  + nEspaco	, .F.	,{|| (cTabela)->NRB_DESC 	}, /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/, .T.)
	nMargem += nEspaco	

	oSection4 := TRSection():New(oSection3, STR0005, {"NZF","SA1"},,, .T.,,,,,,, nMargem)	//"Dados do Cliente"	
	TRCell():New(oSection4	,"NZF_CCLIEN"	,"NZF"		,			,								, TamSX3("NZF_CCLIEN")[1] + nEspaco	, .F.	,{|| (cTabela)->NZF_CCLIEN +"-"+ (cTabela)->NZF_LCLIEN	})
	TRCell():New(oSection4	,"A1_NOME"		,"SA1"		,			,								, TamSX3("A1_NOME")[1] + nEspaco	, .F.	,{|| (cTabela)->A1_NOME 	}, /*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/, .T.)
	nMargem += nEspaco

	oSection5 := TRSection():New(oSection4, STR0007, {"NZG","NSZ"},,, .T.,,,,,,, nMargem)	//"Dados do item Extrato do Correspondente"	
	TRCell():New(oSection5	,"NZG_DTAPRO"	,"NZG"		,STR0009		,								, 10						, .F.	,{|| (cTabela)->NZG_DTAPRO 	})	//"Data"
	TRCell():New(oSection5	,"NZG_NUMPRO"	,"NZG"		,				,								, TamSX3("NZG_NUMPRO")[1]	, .F.	,{|| AllTrim( (cTabela)->NZG_NUMPRO ) })
	TRCell():New(oSection5	,""				,"NSZ"		,STR0011		, ""							, 40						, .F.	,{|| AllTrim((cTabela)->NSZ_PATIVO) +" - "+ AllTrim((cTabela)->NSZ_PPASSI)}	, /*cAlign*/, .T./*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/	)	//"Parte"
	TRCell():New(oSection5	,"VLRHONORARIO"	,"NZG"		,STR0012		, "@E 999,999.99"				, 13						, .F.	,{|| IIF(  Empty((cTabela)->NZG_CRESPO), (cTabela)->NZG_VLPAGA, 0) })	//"Vlr Honorário"
	TRCell():New(oSection5	,"VLRPREPOSTO"	,"NZG"		,STR0013		, "@E 999,999.99"				, 13						, .F.	,{|| IIF( !Empty((cTabela)->NZG_CRESPO), (cTabela)->NZG_VLPAGA, 0) })	//"Vlr Preposto"
 	TRCell():New(oSection5	,"NZG_OBSERV"	,"NZG"		,				, ""							, TamSX3("NZG_OBSERV")[1]	, .F.	,{|| AllTrim( (cTabela)->NZG_OBSERV )}										, /*cAlign*/, .T./*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/, .T./*lAutoSize*/	)
	
	nMargem := nEspaco + nEspaco
	oSection6 := TRSection():New(oSection1, STR0008, {"NZF","NS7","NRB","SA1","NZG","NSZ"},,, .T.,,,,,,, nMargem)	//"Dados do Extrato do Correspondente"
	TRCell():New(oSection6	,"NS7_NOME"		,"NS7"		,STR0014		,								, 15 						, .F.	,{|| AllTrim((cTabela)->NS7_NOME) 	}										, /*cAlign*/, .T./*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/, .T./*lAutoSize*/)	//"Escritório"
	TRCell():New(oSection6	,"NRB_DESC"		,"NRB"		,STR0015		,								, 15 						, .F.	,{|| AllTrim((cTabela)->NRB_DESC) 	}										, /*cAlign*/, .T./*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/, .T./*lAutoSize*/)	//"Área"
	TRCell():New(oSection6	,"A1_NOME"		,"SA1"		,STR0016		,								, 20				 		, .F.	,{|| AllTrim((cTabela)->A1_NOME) 	}										, /*cAlign*/, .T./*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/, .T./*lAutoSize*/)	//"Cliente"	
	TRCell():New(oSection6	,"NZG_DTAPRO"	,"NZG"		,				,								, TamSX3("NZG_DTAPRO")[1] 	, .F.	,{|| (cTabela)->NZG_DTAPRO 	})
	TRCell():New(oSection6	,"NZG_NUMPRO"	,"NZG"		,				,								, TamSX3("NZG_NUMPRO")[1] 	, .F.	,{|| (cTabela)->NZG_NUMPRO 	})
	TRCell():New(oSection6	,""				,"NSZ"		,STR0011		, ""							, 25					 	, .F.	,{|| AllTrim((cTabela)->NSZ_PATIVO) +" - "+ AllTrim((cTabela)->NSZ_PPASSI)}	, /*cAlign*/, .T./*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/, .T./*lAutoSize*/)	//"Parte"
	TRCell():New(oSection6	,"VLRHONORARIO"	,"NZG"		,STR0012		, "@E 999,999.99"				, 13						, .F.	,{|| IIF(  Empty((cTabela)->NZG_CRESPO), (cTabela)->NZG_VLPAGA, 0) })	//"Vlr Honorário"
	TRCell():New(oSection6	,"VLRPREPOSTO"	,"NZG"		,STR0013		, "@E 999,999.99"				, 13						, .F.	,{|| IIF( !Empty((cTabela)->NZG_CRESPO), (cTabela)->NZG_VLPAGA, 0) })	//"Vlr Preposto"
	TRCell():New(oSection6	,"NZG_OBSERV"	,"NZG"		,				, ""							, 25						, .F.	,{|| AllTrim( (cTabela)->NZG_OBSERV )}										, /*cAlign*/, .T./*lLineBreak*/, /*cHeaderAlign*/, /*lCellBreak*/, /*nColSpace*/, .T./*lAutoSize*/)
	
	//Alinha cabeçalho a direita
	oSection5:Cell("VLRHONORARIO"):SetHeaderAlign("RIGHT")
	oSection5:Cell("VLRPREPOSTO"):SetHeaderAlign("RIGHT")
  	oSection6:Cell("VLRHONORARIO"):SetHeaderAlign("RIGHT")
	oSection6:Cell("VLRPREPOSTO"):SetHeaderAlign("RIGHT")
	
	//Nao tem quebra automatica de linha toda
	oSection1:SetLineBreak(.F.)		
	oSection6:SetLineBreak(.F.)
	
Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impressão do relatorio

@author Rafael Tenorio da Costa
@since 08/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport, cTabela,  cTabComar, cTabArea, oSection1, oSection2, oSection3, oSection4, oSection5, oSection6, oSecComar , oSecArea)

	Local aArea		:= GetArea()
	Local cWhere 	:= ""	
	Local dDtIni 	:= MV_PAR01		//Periodo De:
	Local dDtFim 	:= MV_PAR02		//Periodo Ate:
	Local cCorDe	:= MV_PAR03		//Correspondente De:
	Local cLojCorDe	:= MV_PAR04		//Loja Correspondente De:
	Local cCodAte 	:= MV_PAR05		//Correspondente Ate:
	Local cLojCorAte:= MV_PAR06		//Loja Correspondente Ate:
	Local cEscDe 	:= MV_PAR07		//Escritorio De:
	Local cEscAte 	:= MV_PAR08		//Escritorio Ate:
	Local cAreaDe 	:= MV_PAR09		//Area De:
	Local cAreaAte 	:= MV_PAR10		//Area Ate:
	Local cCliDe	:= MV_PAR11		//Cliente De:
	Local cLojCliDe	:= MV_PAR12		//Loja Cliente De:
	Local cCliAte	:= MV_PAR13		//Cliente Ate:
	Local cLojCliAte:= MV_PAR14		//Loja Cliente Ate:
	Local cStatus	:= cValToChar( MV_PAR15	)	//1=Pendente;2=Aprovado;3=Nao Aprovado;4=Encerrado;5=Todos
	Local cRevisa	:= cValToChar( MV_PAR16 )	//1=Sim;2=Nao;3=Todos
	Local cEnviado	:= cValToChar( MV_PAR17	)	//1=Sim;2=Nao;3=Todos
	Local cCorresp	:=""
	Local cLojCorres:=""
	Local cEscrito	:=""
	Local cArea		:=""
	Local cCliente	:=""
	Local cLojClient:=""
	Local oBreak1 	:= TRBreak():New(oSection1,{|| (cTabela)->NZF_CCORRE},{|| "T O T A L   C O R R E S P O N D E N T E ----> "	}, /*lTotalInLine*/, /*cName*/, .T./*lPageBreak*/)
	Local oBreak2 	:= TRBreak():New(oSection2,{|| (cTabela)->NZF_CESCRI},{|| "T O T A L   E S C R I T Ó R I O ----> " 			})
	Local oBreak3 	:= TRBreak():New(oSection3,{|| (cTabela)->NZF_CAREA	},{|| "T O T A L   Á R E A ----> "						})
	Local oBreak4 	:= TRBreak():New(oSection4,{|| (cTabela)->NZF_CCLIEN},{|| "T O T A L   C L I E N T E ----> " 				})
	Local oBreak6	:= TRBreak():New(oSection6,{|| (cTabela)->NZF_CCORRE},{|| "T O T A L   C O R R E S P O N D E N T E ----> " 	}, /*lTotalInLine*/, /*cName*/, .T./*lPageBreak*/)  
	Local cAgruEx	:= ""
	Local lFirst	:= .T.		
	Local cCondicao	:= ""
	Local cChave	:= ""	
	Local cEscAnt	:= ""
	Local cAreaAnt	:= ""
	Local cCodCliAnt:= ""
	Local cLojCliAnt:= ""
	Local cAviso	:= ""
	
	//Cria as quebras e totalizadores
	TRFunction():New(oSection5:Cell("VLRHONORARIO")	,"","SUM",oBreak1,,,,.F.,.F.,/*lEndPage*/, oSection1)
	TRFunction():New(oSection5:Cell("VLRPREPOSTO")	,"","SUM",oBreak1,,,,.F.,.F.,/*lEndPage*/, oSection1)
	
	TRFunction():New(oSection5:Cell("VLRHONORARIO")	,"","SUM",oBreak2,,,,.F.,.F.,/*lEndPage*/, oSection2)
	TRFunction():New(oSection5:Cell("VLRPREPOSTO")	,"","SUM",oBreak2,,,,.F.,.F.,/*lEndPage*/, oSection2)

	TRFunction():New(oSection5:Cell("VLRHONORARIO")	,"","SUM",oBreak3,,,,.F.,.F.,/*lEndPage*/, oSection3)
	TRFunction():New(oSection5:Cell("VLRPREPOSTO")	,"","SUM",oBreak3,,,,.F.,.F.,/*lEndPage*/, oSection3)

	TRFunction():New(oSection5:Cell("VLRHONORARIO")	,"","SUM",oBreak4,,,,.F.,.F.,/*lEndPage*/, oSection4)
	TRFunction():New(oSection5:Cell("VLRPREPOSTO")	,"","SUM",oBreak4,,,,.F.,.F.,/*lEndPage*/, oSection4)

	TRFunction():New(oSection6:Cell("VLRHONORARIO")	,"","SUM",oBreak6,,,,.F.,.F.,/*lEndPage*/, oSection6)
	TRFunction():New(oSection6:Cell("VLRPREPOSTO")	,"","SUM",oBreak6,,,,.F.,.F.,/*lEndPage*/, oSection6)
	
	//Verifica se eh diferente de todos
	If cStatus <> "5"
		cWhere += " AND NZF_STATUS = '" +cStatus+ "' "
	EndIf
	
	//Verifica se eh diferente de todos
	If cRevisa <> "3"
		cWhere += " AND NZF_REVISA = '" +cRevisa+ "' "
	EndIf

	//Verifica se eh diferente de todos
	If cEnviado <> "3"
		cWhere += " AND NZF_ENVCOR = '" +cEnviado+ "' "
	EndIf
	cWhere  := "%" + cWhere  + "%"
	
	//Abre tabela para pegar conteudo do campo memo
	DbSelectArea( "NZF" )

	oSection1:BeginQuery()
	BeginSql Alias cTabela
		SELECT	NZI_AGRUEX,
				NZF_CCORRE, NZF_LCORRE, NZF_CESCRI, NZF_CAREA, NZF_CCLIEN, NZF_LCLIEN, NZF_AVISO,
				NZG_DTAPRO, NZG_NUMPRO, NZG_VLPAGA, NZG_CRESPO, NZG_OBSERV, 
				NSZ_PATIVO, NSZ_PPASSI,
				A2_NOME,
				NS7_NOME,
				NRB_DESC,
				A1_NOME
		FROM %table:NZF% NZF
		INNER JOIN %table:NZG% NZG ON
			NZF_FILIAL 	= NZG_FILIAL	AND
			NZF_COD		= NZG_COD		AND
			NZF_CCORRE	= NZG_CCORRE 	AND
			NZF_LCORRE	= NZG_LCORRE	AND
			NZF_CESCRI	= NZG_CESCRI 	AND
			NZF_CAREA	= NZG_CAREA 	AND
			NZF_CCLIEN	= NZG_CCLIEN 	AND
			NZF_LCLIEN	= NZG_LCLIEN
		INNER JOIN %table:NSZ% NSZ ON
			NZG_FILIAL	= NSZ_FILIAL	AND
			NZG_CAJURI	= NSZ_COD
		INNER JOIN %table:NZI% NZI ON
			NZI_FILIAL	= %xFilial:NZI%	AND
			NZF_CCORRE	= NZI_CCORRE	AND
			NZF_LCORRE	= NZI_LCORRE
		LEFT JOIN %table:SA2% SA2 ON
			A2_FILIAL		= %xFilial:SA2%	AND
			NZF_CCORRE		= A2_COD		AND
			NZF_LCORRE		= A2_LOJA		AND
			NZF.D_E_L_E_T_	= SA2.D_E_L_E_T_
		LEFT JOIN %table:NS7% NS7 ON
			NS7_FILIAL		= %xFilial:NS7%	AND
			NZF_CESCRI		= NS7_COD		AND
			NZF.D_E_L_E_T_	= NS7.D_E_L_E_T_
		LEFT JOIN %table:NRB% NRB ON
			NRB_FILIAL		= %xFilial:NRB%	AND
			NZF_CAREA		= NRB_COD		AND
			NZF.D_E_L_E_T_	= NRB.D_E_L_E_T_
		LEFT JOIN %table:SA1% SA1 ON
			A1_FILIAL		= %xFilial:SA1%	AND
			NZF_CCLIEN		= A1_COD		AND
			NZF_LCLIEN		= A1_LOJA		AND
			NZF.D_E_L_E_T_	= SA1.D_E_L_E_T_
		WHERE	NZF_FILIAL	=	%xFilial:NZF%	AND
				NZF_DTINI 	>=	%Exp:dDtIni%	AND
				NZF_DTFIM	<=	%Exp:dDtFim%	AND
				NZF_CCORRE	>= 	%Exp:cCorDe%	AND	NZF_CCORRE 	<= 	%Exp:cCodAte%		AND
				NZF_LCORRE	>= 	%Exp:cLojCorDe%	AND	NZF_LCORRE 	<= 	%Exp:cLojCorAte%	AND
				NZF_CESCRI	>= 	%Exp:cEscDe%	AND	NZF_CESCRI 	<= 	%Exp:cEscAte%		AND
				NZF_CAREA	>= 	%Exp:cAreaDe%	AND	NZF_CAREA	<=	%Exp:cAreaAte%		AND
				NZF_CCLIEN	>= 	%Exp:cCliDe%	AND	NZF_CCLIEN	<=	%Exp:cCliAte%		AND
				NZF_LCLIEN	>= 	%Exp:cLojCliDe%	AND	NZF_LCLIEN	<=	%Exp:cLojCliAte%	AND
				NZF.%NotDel%	AND
				NZG.%NotDel%	AND
				NZI.%NotDel%
				%Exp:cWhere%
		ORDER BY	NZI_AGRUEX,
					NZF_CCORRE, NZF_LCORRE, NZF_CESCRI, NZF_CAREA, NZF_CCLIEN, NZF_LCLIEN,
					NZG_DTAPRO, NZG_NUMPRO
	EndSQL
	oSection1:EndQuery()
	
	oReport:SetMeter( (cTabela)->( LastRec() ) )
	If !(cTabela)->( Eof() )

		While !oReport:Cancel() .And. !(cTabela)->( Eof() )
		
			cChave		:= (cTabela)->( NZF_CCORRE + NZF_LCORRE )
			cCondicao	:= (cTabela)->( NZF_CCORRE + NZF_LCORRE )
			
			oSection1:Init()
			
			//Inicia secao oSecComar
			BuscaComar( cTabela, cTabComar, @oSecComar )
			
			//Inicia secao oSecArea
			BuscaArea( cTabela, cTabArea, @oSecArea )
	
			//-------------------------------------------------
			//Inicializa seções
			//-------------------------------------------------	
			//1=Correspondente/Escritorio/Area/Cliente/Periodo
			If (cTabela)->NZI_AGRUEX == "1"
				
				oSection2:Init()
				oSection3:Init()
				oSection4:Init()
				oSection5:Init()
				
			//2=Correspondente/Periodo			
			Else
				oSection6:Init()
			EndIf
		
			lFirst	:= .T.
			cAviso	:= ""		
			 
			While !oReport:Cancel() .And. !(cTabela)->( Eof() ) .And. cChave == cCondicao
			
				//Incrementar a barra de progresso
				oReport:IncMeter()		
				
				If lFirst
				
					//Pega o campo memo que a query nao retorna
					NZF->( DbGoTo( (cTabela)->NZF_R_E_C_N_O_  ) )
					If !NZF->( Eof() )
						cAviso := AllTrim( NZF->NZF_AVISO )
					EndIf
				
					oSection1:Cell("NZF_AVISO"):SetValue( cAviso )
					oSection1:PrintLine()
					
					//Imprime Comarcas
					ImpLine( cTabComar, oSecComar )
					
					//Imprime Areas
					ImpLine( cTabArea, oSecArea )
				EndIf
			
				//------------------------------------------------
				//Imprime seções
				//------------------------------------------------
				//1=Correspondente/Escritorio/Area/Cliente/Periodo
				If (cTabela)->NZI_AGRUEX == "1"
				
					If lFirst
												
						oSection2:PrintLine()
						oSection3:PrintLine()
						oSection4:PrintLine()
											
					Else
											
						If cEscAnt <> (cTabela)->NZF_CESCRI
							
							oSection5:Finish()
							oSection4:Finish()
							oSection3:Finish()
							oSection2:Finish()
							
							oSection2:Init()
							oSection3:Init()
							oSection4:Init()
							oSection5:Init()
						
							oSection2:PrintLine()
							oSection3:PrintLine()
							oSection4:PrintLine()
							
						ElseIf cAreaAnt <> (cTabela)->NZF_CAREA
						
							oSection5:Finish()
							oSection4:Finish()
							oSection3:Finish()
	
							oSection3:Init()
							oSection4:Init()
							oSection5:Init()
						
							oSection3:PrintLine()
							oSection4:PrintLine()
							
						ElseIf cCodCliAnt <> (cTabela)->NZF_CCLIEN .Or. cLojCliAnt <> (cTabela)->NZF_LCLIEN
						
							oSection4:Finish()
							oSection5:Finish()
							
							oSection4:Init()
							oSection5:Init()
								
							oSection4:PrintLine()
						EndIf
						
					EndIf
					
					oSection5:PrintLine()
					
				//2=Correspondente/Periodo			
				Else
					oSection6:PrintLine()					
				EndIf
				
				lFirst 		:= .F.
				cAgruEx 	:= (cTabela)->NZI_AGRUEX
				cEscAnt		:= (cTabela)->NZF_CESCRI
				cAreaAnt	:= (cTabela)->NZF_CAREA
				cCodCliAnt 	:= (cTabela)->NZF_CCLIEN
				cLojCliAnt 	:= (cTabela)->NZF_LCLIEN
				
				(cTabela)->( DbSkip() )
				
				If !(cTabela)->( Eof() )
					cCondicao	:= (cTabela)->( NZF_CCORRE + NZF_LCORRE )
				EndIf	
			EndDo

			//------------------------------------------------
			//Encerra seções
			//------------------------------------------------
			//1=Correspondente/Escritorio/Area/Cliente/Periodo
			If cAgruEx == "1"
			
				oSection5:Finish()
				oSection4:Finish()
				oSection3:Finish()
				oSection2:Finish()
				oSection1:Finish()
				
			//2=Correspondente/Periodo			
			Else
				oSection6:Finish()					
			EndIf
			
			oSecComar:Finish()
			oSecArea:Finish()
		EndDo
		
	EndIf
	
	If Select(cTabArea)
		(cTabArea)->( DbCloseArea() )
	EndIf
	
	If Select(cTabComar)
		(cTabComar)->( DbCloseArea() )
	EndIf
	
	(cTabela)->( DbCloseArea() )
	RestArea( aArea )
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaComar()
Pega informacoes da comarca do correspondente

@author Rafael Tenorio da Costa
@since 19/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BuscaComar( cTabela, cTabComar, oSecComar )

	Local aArea := GetArea()
	
	If Select(cTabComar)
		(cTabComar)->( DbCloseArea() )
	EndIf
	
	oSecComar:BeginQuery()
	BeginSql Alias cTabComar
		SELECT NU3_CCOMAR, NQ6_DESC
		FROM %table:NU3% NU3 INNER JOIN %table:NQ6% NQ6
			ON NU3_CCOMAR = NQ6_COD
		WHERE	NU3_CCREDE 	= %Exp:(cTabela)->NZF_CCORRE% 
			AND NU3_LOJA 	= %Exp:(cTabela)->NZF_LCORRE%
			AND NU3.%NotDel%	
			AND NQ6.%NotDel%
	EndSQL
	oSecComar:EndQuery()
	
	oSecComar:Init()
	
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaArea()
Pega informacoes da Area do correspondente

@author Rafael Tenorio da Costa
@since 19/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BuscaArea( cTabela, cTabArea, oSecArea )

	Local aArea := GetArea()
	
	If Select(cTabArea)
		(cTabArea)->( DbCloseArea() )
	EndIf
	
	oSecArea:BeginQuery()
	BeginSql Alias cTabArea
		SELECT NVI_CAREA, NRB_DESC
		FROM %table:NVI% NVI INNER JOIN %table:NRB% NRB
			ON NVI_CAREA = NRB_COD
		WHERE	NVI_CCREDE	= %Exp:(cTabela)->NZF_CCORRE% 
			AND NVI_CLOJA	= %Exp:(cTabela)->NZF_LCORRE%
			AND NVI.%NotDel%	
			AND NRB.%NotDel%
	EndSQL
	oSecArea:EndQuery()
	
	oSecArea:Init()
	
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpLine
Imprime informações

@author Rafael Tenorio da Costa
@since 19/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ImpLine( cTabAux, oSecAux )

	While !(cTabAux)->( Eof() )
		oSecAux:PrintLine()
		(cTabAux)->( DbSkip() )
	EndDo

	oSecAux:Finish()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Ja191LmpCo
Limpa os dados do correspondente no pergunte antes de usar.
Necessario, porque na primeira abertura da consulta padrao o filtro não funcinava e trazia registro que não pertencia ao filtro.

@author Rafael Tenorio da Costa
@since 06/08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function Ja191LmpCo(cPergunta)

	If !EMPTY(cPergunta)
		SetMVValue(cPergunta,"MV_PAR03","")
		SetMVValue(cPergunta,"MV_PAR04","")
		SetMVValue(cPergunta,"MV_PAR05","")
		SetMVValue(cPergunta,"MV_PAR06","")
	EndIf

Return Nil