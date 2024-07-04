#INCLUDE "JURA189.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA189
Gera dados do extrato de correspondente NZF \ NZG

@author Rafael Tenorio da Costa
@since 24/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA189()

Local oGrid		:= Nil
Local nRet		:= 0
Local cPergunta	:= "JURA189"

//Limpa dados do correspondente no pergunte
Ja191LmpCo( cPergunta )	

//--------------------------------------------------------
//@param cFunName     Nome da rotina de menu de processamento
//@param cTitle       Titulo da rotina de menu
//@param cDescription Descrição completa da rotina
//@param bProcess     Bloco de código de processamento. O bloco recebe a variavel que informa que a rotina foi cancelada
//@param cPerg        Nome do grupo de perguntas do dicionário de dados
//--------------------------------------------------------
oGrid := FWGridProcess():New("JURA189", STR0001, STR0002, {|lEnd| nRet := ProcessaExt(oGrid, @lEnd)}, cPergunta)	//"Geração de Extrado de Correspondentes"	//"Está rotina tem o objetivo de gerar as tabelas NZF\NZG para o Extrato de Correspondente, para que possa ser possível visualizar e alterar os valores que serão pagos aos correspondentes.""Está rotina tem o objetivo de gerar as tabelas NZF\NZG para o Extrato de Correspondente, para que possa ser possível visualizar e alterar os valores que serão pagos aos correspondentes."

//Indica a quantidade de barras de processo
oGrid:SetMeters(2)		
oGrid:Activate()

If nRet > 0

	If oGrid:IsFinished()
		If nRet == 1
			ApMsgInfo(STR0006)	//"Processamento do extrato finalizado corretamente"
		Else
			ApMsgInfo(STR0007)	//"Não foi possível processar o extrato de correspondente"
		EndIf	
	EndIf
	
ElseIf nRet == 0	
	ApMsgInfo(STR0008)	//"Não existe dados a serem processados com esses parâmetros"				
EndIF

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcessaExt
Processa validações e gera NZF \ NZG

@author Rafael Tenorio da Costa
@since 27/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcessaExt(oGrid, lEnd)

	Local nRet		:= 0
	Local lContinua	:= .F.
	Local nCont		:= 1
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
	
	//------------------------------------------------------------
	// Efetua validações antes de gerar extrato
	//------------------------------------------------------------
	oGrid:SetMaxMeter(2, 1, STR0003)	//"Efetuando validações"
	oGrid:SetIncMeter(1)
	
	lContinua := ValidaExt(	dDtIni		, dDtFim	, cCorDe	, cLojCorDe	, cCodAte	,;
							cLojCorAte	, cEscDe	, cEscAte	, cAreaDe	, cAreaAte	,;
							cCliDe		, cLojCliDe	, cCliAte	, cLojCliAte)
	oGrid:SetIncMeter(1)
	
	If lContinua

		//------------------------------------------------------------
		// Gera extrato de correspondente
		//------------------------------------------------------------
		oGrid:SetMaxMeter(3, 2, STR0004)	//"Gerando extrato de correspondente"
		oGrid:SetIncMeter(2)
		
		nRet := GeraExtrato(dDtIni		, dDtFim	, cCorDe	, cLojCorDe	, cCodAte	,;
							cLojCorAte	, cEscDe	, cEscAte	, cAreaDe	, cAreaAte	,;
							cCliDe		, cLojCliDe	, cCliAte	, cLojCliAte)

		oGrid:SetIncMeter(2)					
	
	EndIf
	
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaExt
Efetua validações antes de efetuar a geração do extrado
 
@param dDtIni		- Periodo De:
@param dDtFim 		- Periodo Ate:
@param cCorDe		- Correspondente De:
@param cLojCorDe	- Loja Correspondente De:
@param cCodAte 		- Correspondente Ate:
@param cLojCorAte	- Loja Correspondente Ate:
@param cEscDe 		- Escritorio De:
@param cEscAte 		- Escritorio Ate:
@param cAreaDe 		- Area De:
@param cAreaAte 	- Area Ate:
@param cCliDe		- Cliente De:
@param cLojCliDe	- Loja Cliente De:
@param cCliAte		- Cliente Ate:
@param cLojCliAte	- Loja Cliente Ate:
@return lRetorno	- Define se foi feito corretamente as validações
@author Rafael Tenorio da Costa
@since 27/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidaExt(	dDtIni		, dDtFim	, cCorDe	, cLojCorDe	, cCodAte	,;
							cLojCorAte	, cEscDe	, cEscAte	, cAreaDe	, cAreaAte	,;
							cCliDe		, cLojCliDe	, cCliAte	, cLojCliAte)

	Local aArea		:= GetArea()
	Local lRetorno 	:= .T.
	Local cTabela	:= GetNextAlias()
	Local cQuery	:= ""
	Local cDtIni	:= DtoS( dDtIni )
	Local cDtFim	:= DtoS( dDtFim )
	Local aCamposNZF:= {}
	Local aAuxNZG	:= {}	
	Local aCamposNZG:= {}
	Local cFilReg 	:= "" 
	Local cExtrato	:= ""
	Local cCodCor 	:= ""
	Local cLojCor 	:= ""
	Local cEscri	:= ""
	Local cArea 	:= ""
	Local cCodCli 	:= "" 
	Local cLojCli 	:= "" 
	Local aRecNT4	:= {}

	//------------------------------------------------------------
	// Verifica se ja foi gerado extrato com os esses parametros
	//------------------------------------------------------------
	cQuery	:= " SELECT NZF_FILIAL, NZF_COD, NZF_CCORRE, NZF_LCORRE, NZF_CESCRI, NZF_CAREA, NZF_CCLIEN, NZF_LCLIEN, NZF_DTINI, NZF_DTFIM, "
	cQuery	+= 		  " NZG_ITEM, NZG_RECNT4 " 
	cQuery	+= " FROM " +RetSqlName("NZF")+ " NZF INNER JOIN " +RetSqlName("NZG")+ " NZG " 
	cQuery	+= 		" ON NZF_FILIAL = NZG_FILIAL AND NZF_COD = NZG_COD AND NZF_CCORRE = NZG_CCORRE AND NZF_LCORRE = NZG_LCORRE AND "
	cQuery	+= 		   " NZF_CESCRI = NZG_CESCRI AND NZF_CAREA = NZG_CAREA AND NZF_CCLIEN = NZG_CCLIEN AND NZF_LCLIEN = NZG_LCLIEN "
	cQuery	+= " WHERE 	NZF_FILIAL 	= '" +xFilial("NZF")+ 	"' AND" 
	
	//Sub-query para pegar todos os extratos que tem registros processados com esse periodo
	cQuery	+= " 		NZF_COD IN (SELECT DISTINCT NZG_COD FROM " +RetSqlName("NZG")+ " NZG_2"
	cQuery	+= 					"	WHERE NZG_FILIAL = '" +xFilial("NZF")+ "' AND"
	cQuery	+= 							" NZG_DTAPRO BETWEEN '" +cDtIni+ "' AND '" +cDtFim+ "' AND"
	cQuery	+= 							" NZG_2.D_E_L_E_T_ = ' ') AND" 
	
	cQuery	+= " 		NZF_CCORRE 	BETWEEN '" +cCorDe+ 	"' AND '" +cCodAte+ 	"' AND" 
	cQuery	+= "		NZF_LCORRE 	BETWEEN '" +cLojCorDe+ 	"' AND '" +cLojCorAte+ 	"' AND"
	cQuery	+= "		NZF_CESCRI  BETWEEN '" +cEscDe+	 	"' AND '" +cEscAte+ 	"' AND"
	cQuery	+= "		NZF_CAREA  	BETWEEN '" +cAreaDe+ 	"' AND '" +cAreaAte+	"' AND"
	cQuery	+= "		NZF_CCLIEN  BETWEEN '" +cCliDe+ 	"' AND '" +cCliAte+ 	"' AND"
	cQuery	+= "		NZF_LCLIEN  BETWEEN '" +cLojCliDe+ 	"' AND '" +cLojCliAte+ 	"' AND"
	cQuery	+= "		NZF_STATUS	<> '4' 	  AND "		//Encerrado
	cQuery	+= "		NZF.D_E_L_E_T_  = ' ' AND "
	cQuery	+= "		NZG.D_E_L_E_T_  = ' ' "
	cQuery	+= " ORDER BY NZF_FILIAL, NZF_COD, NZF_CCORRE, NZF_LCORRE, NZF_CESCRI, NZF_CAREA, NZF_CCLIEN, NZF_LCLIEN, NZG_ITEM" 
	
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTabela, .F., .T.)
	TcSetField(cTabela, "NZF_DTINI", "D", 8, 0)
	TcSetField(cTabela, "NZF_DTFIM", "D", 8, 0)
	
	If !(cTabela)->( Eof() )
	
		If ApMsgYesNo(STR0005) //"Já existe registros de extrato com essees parâmetros, confirma re-processamento de extrato ?"

			While !(cTabela)->( Eof() ) .And. lRetorno

				aCamposNZF 	:= {}
				aCamposNZG	:= {}
				aAuxNZG		:= {}
				aRecNT4		:= {}
				cFilReg 	:= (cTabela)->NZF_FILIAL 
				cExtrato 	:= (cTabela)->NZF_COD
				cCodCor 	:= (cTabela)->NZF_CCORRE
				cLojCor 	:= (cTabela)->NZF_LCORRE
				cEscri 		:= (cTabela)->NZF_CESCRI
				cArea 		:= (cTabela)->NZF_CAREA
				cCodCli 	:= (cTabela)->NZF_CCLIEN 
				cLojCli 	:= (cTabela)->NZF_LCLIEN 

				Aadd( aCamposNZF, {"NZF_COD"	, (cTabela)->NZF_COD	} )
				Aadd( aCamposNZF, {"NZF_CCORRE"	, (cTabela)->NZF_CCORRE	} )
				Aadd( aCamposNZF, {"NZF_LCORRE"	, (cTabela)->NZF_LCORRE	} )
				Aadd( aCamposNZF, {"NZF_CESCRI"	, (cTabela)->NZF_CESCRI	} )
				Aadd( aCamposNZF, {"NZF_CAREA"	, (cTabela)->NZF_CAREA	} )
				Aadd( aCamposNZF, {"NZF_CCLIEN"	, (cTabela)->NZF_CCLIEN	} )
				Aadd( aCamposNZF, {"NZF_LCLIEN"	, (cTabela)->NZF_LCLIEN	} )
				Aadd( aCamposNZF, {"NZF_DTINI"	, (cTabela)->NZF_DTINI	} )
				Aadd( aCamposNZF, {"NZF_DTFIM"	, (cTabela)->NZF_DTFIM	} )
				
				While !(cTabela)->( Eof() ) .And. 	(cTabela)->NZF_FILIAL == cFilReg .And. (cTabela)->NZF_COD == cExtrato 	.And.;
													(cTabela)->NZF_CCORRE == cCodCor .And. (cTabela)->NZF_LCORRE == cLojCor .And.;
													(cTabela)->NZF_CESCRI == cEscri	 .And. (cTabela)->NZF_CAREA == cArea 	.And.; 
													(cTabela)->NZF_CCLIEN == cCodCli .And. (cTabela)->NZF_LCLIEN == cLojCli
				
					aAuxNZG		:= {}
					Aadd( aAuxNZG, {"NZG_COD"		, (cTabela)->NZF_COD	} )
					Aadd( aAuxNZG, {"NZG_CCORRE"	, (cTabela)->NZF_CCORRE	} )
					Aadd( aAuxNZG, {"NZG_LCORRE"	, (cTabela)->NZF_LCORRE	} )
					Aadd( aAuxNZG, {"NZG_CESCRI"	, (cTabela)->NZF_CESCRI	} )
					Aadd( aAuxNZG, {"NZG_CAREA"		, (cTabela)->NZF_CAREA	} )
					Aadd( aAuxNZG, {"NZG_CCLIEN"	, (cTabela)->NZF_CCLIEN	} )
					Aadd( aAuxNZG, {"NZG_LCLIEN"	, (cTabela)->NZF_LCLIEN	} )
					Aadd( aAuxNZG, {"NZG_ITEM"		, (cTabela)->NZG_ITEM	} )

					//Carrega array de itens					
					Aadd(aCamposNZG, aAuxNZG)
					
					//Carrega recnos da NT4
					Aadd(aRecNT4, (cTabela)->NZG_RECNT4) 
					
					(cTabela)->( DbSkip() )
				EndDo
				
				Begin Transaction
				
					//Chama execauto para excluir o extrato	
					lRetorno := J190RotAut( aCamposNZF, aCamposNZG, 5 )
					
					//Atualiza status de processado
					If lRetorno
						AtuNT4( aRecNT4, "2" )
					EndIf
					
				End Transaction
					
			EndDo	
		Else
		
			lRetorno := .F.
		EndIf
	EndIf

	(cTabela)->( DbCloseArea() )
	RestArea( aArea )

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraExtrato
Gera registros do extrato de correspondente NZF\NZG
 
@param dDtIni		- Periodo De:
@param dDtFim 		- Periodo Ate:
@param cCorDe		- Correspondente De:
@param cLojCorDe	- Loja Correspondente De:
@param cCodAte 		- Correspondente Ate:
@param cLojCorAte	- Loja Correspondente Ate:
@param cEscDe 		- Escritorio De:
@param cEscAte 		- Escritorio Ate:
@param cAreaDe 		- Area De:
@param cAreaAte 	- Area Ate:
@param cCliDe		- Cliente De:
@param cLojCliDe	- Loja Cliente De:
@param cCliAte		- Cliente Ate:
@param cLojCliAte	- Loja Cliente Ate:
@return lRetorno	- Define se foi gerado corretamente os registros
@author Rafael Tenorio da Costa
@since 27/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraExtrato(dDtIni		, dDtFim	, cCorDe	, cLojCorDe	, cCodAte	,;
							cLojCorAte	, cEscDe	, cEscAte	, cAreaDe	, cAreaAte	,;
							cCliDe		, cLojCliDe	, cCliAte	, cLojCliAte)

	Local aArea		:= GetArea()
	Local nRet 		:= 0
	Local cTabela	:= GetNextAlias()
	Local cQuery	:= ""
	Local cDtIni	:= DtoS( dDtIni )
	Local cDtFim	:= DtoS( dDtFim )
	Local aExtrato	:= {}
	Local aNegEsp	:= {}
	Local aCtrCor	:= {}
	Local aAux		:= {}
	Local cPreposto	:= ""
	Local cCodCorAnt:= ""
	Local cLojCorAnt:= ""
	Local cEscAnt	:= ""
	Local cAreaAnt	:= ""
	Local cCodCliAnt:= ""
	Local cLojCliAnt:= ""
	Local dDtAndaAnt:= ""
	Local nTotal	:= 0
	Local lPrecifica:= .T.
	Local cAviso	:= ""
	Local lPreposto	:= .T.				//Efetua o controle da geracao do resgistro de preposto
	Local cTipSerAnt:= {}
							
	cQuery := "SELECT	 NT4_COD, NT4_DTANDA, NT4_AUTPGO , NT4_CATO, NT4.R_E_C_N_O_ NT4RECNO " + CRLF 
	cQuery += " 		,NTA_COD, NTA_CCORRE, NTA_LCORRE	, NTA_CPREPO, NTA_CADVCR " + CRLF
	cQuery += " 		,NSZ_COD, NSZ_CESCRI, NSZ_CAREAJ, NSZ_CCLIEN, NSZ_LCLIEN " + CRLF
	cQuery += " 		,NRO_CTPSER " + CRLF
	cQuery += " 		,NZI_QTDRET, NZI.R_E_C_N_O_ AS NZIRECNO, NZI_ENVPAG " + CRLF
	cQuery += " 		,ISNULL(NZB_REEMBO, '') AS NZB_REEMBO, ISNULL(NZB_REEMPR, '') AS NZB_REEMPR " + CRLF
	cQuery += " 		,ISNULL(NUQ_CCOMAR, '') AS COMARCA, ISNULL(NUQ_CLOC2N, '') AS FORO, ISNULL(NUQ_CLOC3N, '') AS VARA " + CRLF
	cQuery += " 		,ISNULL(NUQ_NUMPRO, '') AS NUMPRO " + CRLF
	
	cQuery += "FROM " + CRLF
	cQuery += "	" +RetSqlName("NT4")+ " NT4 INNER JOIN " +RetSqlName("NTA")+ " NTA " + CRLF
	cQuery += "		ON NT4_FILIAL = NTA_FILIAL AND NT4_CFWLP = NTA_COD " + CRLF
	cQuery += "	INNER JOIN " +RetSqlName("NQS")+ " NQS " + CRLF
	cQuery += "		ON NQS_FILIAL = '" + xFilial("NQS") + "' AND NTA_CTIPO = NQS_COD " + CRLF
	cQuery += "	INNER JOIN " +RetSqlName("NSZ")+ " NSZ " + CRLF
	cQuery += "		ON NT4_FILIAL = NSZ_FILIAL AND NT4_CAJURI = NSZ_COD " + CRLF
	cQuery += "	INNER JOIN " +RetSqlName("NRO")+ " NRO " + CRLF
	cQuery += "		ON NRO_FILIAL = '" + xFilial("NRO") + "' AND NT4_CATO = NRO_COD " + CRLF
	cQuery += "	INNER JOIN " +RetSqlName("NZI")+ " NZI " + CRLF
	cQuery += "		ON NZI_FILIAL = '" + xFilial("NZI") + "' AND NTA_CCORRE = NZI_CCORRE AND NTA_LCORRE = NZI_LCORRE " + CRLF
	cQuery += "	LEFT JOIN " +RetSqlName("NZB")+ " NZB " + CRLF
	cQuery += "		ON NZB_FILIAL = '" + xFilial("NZB") + "' AND NSZ_CCLIEN = NZB_CCLIEN AND NSZ_LCLIEN = NZB_LCLIEN AND NRO_CTPSER = NZB_CTPSER AND NSZ.D_E_L_E_T_ = NZB.D_E_L_E_T_ " + CRLF
	cQuery += "	LEFT JOIN " +RetSqlName("NUQ")+ " NUQ " + CRLF
	cQuery += "		ON NSZ_FILIAL = NUQ_FILIAL AND NSZ_COD = NUQ_CAJURI AND NUQ_INSATU = '1' AND NSZ.D_E_L_E_T_ = NUQ.D_E_L_E_T_ " + CRLF
	cQuery += "WHERE	NT4_FILIAL = '" +xFilial("NT4")+ "' " + CRLF
	cQuery += "		AND	NT4_DTANDA BETWEEN '" +cDtIni+ 		"' AND '" +cDtFim+ 		"' " + CRLF
	cQuery += "		AND	NT4_PROEXT = '2' " + CRLF
	cQuery += "		AND	NT4_AUTPGO IN ('1','2') " + CRLF	
	cQuery += "		AND NTA_CCORRE BETWEEN '" +cCorDe+ 		"' AND '" +cCodAte+ 	"' " + CRLF
	cQuery += "		AND NTA_LCORRE BETWEEN '" +cLojCorDe+ 	"' AND '" +cLojCorAte+ 	"' " + CRLF
	cQuery += "		AND NSZ_CESCRI BETWEEN '" +cEscDe+ 		"' AND '" +cEscAte+ 	"' " + CRLF
	cQuery += "		AND NSZ_CAREAJ BETWEEN '" +cAreaDe+ 	"' AND '" +cAreaAte+ 	"' " + CRLF
	cQuery += "		AND NSZ_CCLIEN BETWEEN '" +cCliDe+ 		"' AND '" +cCliAte+ 	"' " + CRLF
	cQuery += "		AND NSZ_LCLIEN BETWEEN '" +cLojCliDe+ 	"' AND '" +cLojCliAte+ 	"' " + CRLF
	cQuery += "		AND NTA_CCORRE <> ' ' " + CRLF	
	cQuery += "		AND NT4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "		AND NTA.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "		AND NSZ.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "		AND NRO.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "		AND NZI.D_E_L_E_T_ = ' ' " + CRLF
	
	cQuery += "ORDER BY NTA_CCORRE, NTA_LCORRE, NSZ_CESCRI, NSZ_CAREAJ, NSZ_CCLIEN, NSZ_LCLIEN, " 
	cQuery += " NRO_CTPSER,"
	cQuery += " NT4_DTANDA,"					
	cQuery += " NTA_CPREPO "

	 						
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTabela, .F., .T.)
	TcSetField(cTabela, "NT4_DTANDA", "D", 8, 0)
	
	While !(cTabela)->( Eof() ) .And. nRet <> 2
	
		aAux		:= {}
		aNegEsp		:= {}
		aCtrCor		:= {}
		cCodCorAnt	:= (cTabela)->NTA_CCORRE
		cLojCorAnt	:= (cTabela)->NTA_LCORRE
		cEscAnt		:= (cTabela)->NSZ_CESCRI
		cAreaAnt	:= (cTabela)->NSZ_CAREAJ
		cCodCliAnt	:= (cTabela)->NSZ_CCLIEN
		cLojCliAnt	:= (cTabela)->NSZ_LCLIEN
		dDtAndaAnt	:= (cTabela)->NT4_DTANDA
		cAviso		:= GetAviso( (cTabela)->NZIRECNO )
		cTipSerAnt	:= (cTabela)->NRO_CTPSER
		
		//Tratamento de preposto para gerar novo registro sem o preposto para pegar o valor do correspondente
		If lPreposto
			cPreposto := (cTabela)->NTA_CPREPO
		EndIf	
		
		//Campos que seram gravados no extrato
		Aadd(aAux, { "NZF_CCORRE"	, "NZG_CCORRE"	, cCodCorAnt			} )	//1 
		Aadd(aAux, { "NZF_LCORRE"	, "NZG_LCORRE"	, cLojCorAnt			} )	//2
		Aadd(aAux, { "NZF_DTINI"		, ""				, dDtIni				} )	//3
		Aadd(aAux, { "NZF_DTFIM"		, ""				, dDtFim				} )	//4
		Aadd(aAux, { "NZF_CESCRI"	, "NZG_CESCRI"	, cEscAnt				} )	//5
		Aadd(aAux, { "NZF_CAREA"		, "NZG_CAREA"		, cAreaAnt				} )	//6
		Aadd(aAux, { "NZF_CCLIEN"	, "NZG_CCLIEN"	, cCodCliAnt			} )	//7
		Aadd(aAux, { "NZF_LCLIEN"	, "NZG_LCLIEN"	, cLojCliAnt			} )	//8
		Aadd(aAux, { ""				, ""				, ""					} )	//9		Pode ser utilizado
		Aadd(aAux, { ""				, ""				, ""					} )	//10	Pode ser utilizado
		Aadd(aAux, { ""				, "NZG_CTPSER"	, cTipSerAnt			} )	//11
		Aadd(aAux, { ""				, "NZG_CRESPO"	, cPreposto				} )	//12
		Aadd(aAux, { ""				, ""				, ""					} )	//13	Pode ser utilizado
	  	Aadd(aAux, { ""				, ""				, ""					} )	//14	Pode ser utilizado
		Aadd(aAux, { ""				, "NZG_VLCALC"	, 0						} )	//15
		Aadd(aAux, { ""				, "NZG_OBSERV"	, ""					} )	//16
		Aadd(aAux, { ""				, "NZG_PRODUT"	, ""					} )	//17
		Aadd(aAux, { ""				, ""				, ""					} )	//18	Pode ser utilizado
		Aadd(aAux, { "NZF_AVISO"		, ""				, cAviso				} )	//19
		Aadd(aAux, { "NZF_DTRET"		, ""				, Date() + (cTabela)->NZI_QTDRET	} )	//20
		Aadd(aAux, { ""				, "NZG_INFO"		, "1"					} )	//21	1=Valor Nao Calculado
		Aadd(aAux, { ""				, "NZG_GERSIS"	, "1"					} )	//22	Define que o registro foi gerado pelo sistema
		Aadd(aAux, { "NZF_TIPPAG"	, ""				,  Trim((cTabela)->NZI_ENVPAG)	} )	//23	1=Titulo Pagar 2=Pedido Compra
		Aadd(aAux, { "NZF_REVISA"	, ""				, "1"					} )	//24	1=Sim 2=Nao
		Aadd(aAux, { ""				, "NZG_VLPAGA"	, 0						} )	//25
		Aadd(aAux, { ""				, "NZG_NUMPRO"	,  Trim((cTabela)->NUMPRO)		} )	//26
		Aadd(aAux, { ""				, "NZG_CANDAM"	,  Trim((cTabela)->NT4_COD)	} )	//27	Codigo do andamento

		//Campos atualizado por gatilhos, por isso vieram para fim
		Aadd(aAux, { ""				, "NZG_CFWLP"		, (cTabela)->NTA_COD	} )	//28	Codigo do follow-up
		Aadd(aAux, { ""				, "NZG_CCOMAR"	,  Trim((cTabela)->COMARCA)	} )	//29
		Aadd(aAux, { ""				, "NZG_CFORO"		,  Trim((cTabela)->FORO)		} )	//30
		Aadd(aAux, { ""				, "NZG_CVARA"		,  Trim((cTabela)->VARA)		} )	//31
		Aadd(aAux, { ""				, "NZG_CAJURI"	,  Trim((cTabela)->NSZ_COD)	} )	//32
		Aadd(aAux, { ""				, "NZG_DTAPRO"	, 	dDtAndaAnt					} )	//33
		Aadd(aAux, { ""				, "NZG_CATO"		,  Trim((cTabela)->NT4_CATO)	} )	//34
		Aadd(aAux, { ""				, "NZG_RECNT4"	, (cTabela)->NT4RECNO	} )	//35
		Aadd(aAux, { ""				, "NZG_STATUS"	, "1"					} )	//36	1=Pendente
		
		//-------------------------------------------------------------------
		//Pagamentos autorizados
		//-------------------------------------------------------------------
		//Busca negociacao especial NZD
		aNegEsp := GetNegEsp( 	cCodCorAnt		, cLojCorAnt		, dDtAndaAnt, cEscAnt				,;
		 						cAreaAnt		, cCodCliAnt		, cLojCliAnt, (cTabela)->COMARCA	,;
		 						(cTabela)->FORO	, (cTabela)->VARA	)
		 					
		If Len( aNegEsp ) > 0  
		 
			aAux[16][03] := aNegEsp[1]	//Observação
			aAux[21][03] := "2"			//2=Negociacao Especial
			aAux[24][03] := "1"			//1=Sim
			
		EndIf
		
		//Busca dados do contrato do correspondente x ato NZC
		aCtrCor := GetCtrCor( 	cCodCorAnt	, cLojCorAnt	, cEscAnt				, cAreaAnt 				,;
								cCodCliAnt	, cLojCliAnt	, (cTabela)->NZB_REEMBO	, cPreposto				,;
								@lPrecifica	, aExtrato		, cTipSerAnt			, (cTabela)->NZB_REEMPR	,;
								dDtAndaAnt	, aAux[36][3]	)
		If Len(aCtrCor) > 0

			//Verifica se tem negociação especial para apenas atualizar o campo valor calculado		
			If Len( aNegEsp ) > 0
			
				aAux[15][03] := aCtrCor[1]	//Valor calculado
			Else
			
				aAux[15][03] := aCtrCor[6]	//Valor calculado
				aAux[16][03] := aCtrCor[2]	//Observação
				aAux[17][03] := aCtrCor[3]	//Codigo do produto
				aAux[21][03] := aCtrCor[4]	//1=Valor Nao Calculado; 3=Valor Calculado;
				aAux[24][03] := aCtrCor[5]	//1=Sim 2=Nao
				aAux[25][03] := aCtrCor[1]	//Valor Pago
				aAux[36][03] := aCtrCor[7]	//Status Item				
			EndIf
			
		EndIf
		
		//-------------------------------------------------------------------
		//Pagamentos nao autorizados
		//-------------------------------------------------------------------
		If (cTabela)->NT4_AUTPGO == "2"
		
			aAux[16][03] := STR0014	//Observação		//"Pagamento Negado"
			aAux[25][03] := 0		//Valor Pago
			aAux[36][03] := "3"		//Status Item		//"Nao Aprovado"
		EndIf
		
		//Acumula valor total
		nTotal += aAux[25][03] 
			
		//Carrega o extrato do correspondente
		Aadd(aExtrato, aAux )
		
		//Se tiver preposto gera o novo registro sem o preposto para pegar o valor do correspondente
		If !Empty( cPreposto )
			cPreposto := ""
			lPreposto := .F.	
			Loop 		
		EndIf
		
		//Atualiza variaveis de controle para o agrupamento do NZC
	 	lPrecifica := .F.
	 	lPreposto  := .T.
		
		//Passa ao proximo registro
		(cTabela)->( DbSkip() )
		
		//Verifica se mudou o tipo de serviço
		If !( cTabela)->( Eof() ) .And. (cTabela)->NRO_CTPSER <> cTipSerAnt
			lPrecifica := .T.		
		EndIf
		
		//Verica mudança de dados do cabeçalho NZF
		If ( cTabela)->( Eof() ) .Or.	(cTabela)->NTA_CCORRE <> cCodCorAnt .Or. (cTabela)->NTA_LCORRE <> cLojCorAnt	.Or.;
										(cTabela)->NSZ_CESCRI <> cEscAnt 	.Or. (cTabela)->NSZ_CAREAJ <> cAreaAnt 		.Or.;
										(cTabela)->NSZ_CCLIEN <> cCodCliAnt	.Or. (cTabela)->NSZ_LCLIEN <> cLojCliAnt
		
			//Grava dados do extrato
			If GravaExt(aExtrato, nTotal)
				nRet := 1
			Else
				nRet := 2
			EndIf
			
			//Carrega inicializadores
			lPrecifica	:= .T.
		 	aExtrato	:= {}
		 	nTotal		:= 0 
		 	lPreposto	:= .T.
		EndIf
	EndDo

	(cTabela)->( DbCloseArea() )
	RestArea( aArea )

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetNegEsp
Busca as informações de negociações especiais NZD.
 
@param 
@return 
@author Rafael Tenorio da Costa
@since 30/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetNegEsp( 	cCodCor	, cLojCor, dDtAnda, cEscri	,;
							cArea	, cCodCli, cLojCli, cComarca,;
							cForo	, cVara	 )

	Local aArea		:= GetArea()
	Local aRetorno 	:= {}
	Local cTabela	:= GetNextAlias()
	Local cQuery	:= ""
	Local cDtAnda	:= DtoS( dDtAnda )
	Local cBanco  	:= Upper( AllTrim( TcGetDb() ) )

	cQuery := " SELECT "
	
	If !( cBanco == "ORACLE" )
		cQuery += " TOP 1 "
	EndIf
		
	cQuery += "		NZD_OBSERV, NZD_DTINI, NZD_DTFIM, " + CRLF
	cQuery += " 	(CASE WHEN NZD_CESCRI = ' ' THEN 0 ELSE 1 END) + " + CRLF
	cQuery += " 	(CASE WHEN NZD_CAREA  = ' ' THEN 0 ELSE 1 END) + " + CRLF
	cQuery += " 	(CASE WHEN NZD_CCOMAR = ' ' THEN 0 ELSE 1 END) + " + CRLF
	cQuery += " 	(CASE WHEN NZD_CFORO  = ' ' THEN 0 ELSE 1 END) + " + CRLF
	cQuery += " 	(CASE WHEN NZD_CVARA  = ' ' THEN 0 ELSE 1 END) + " + CRLF
	cQuery += " 	(CASE WHEN NZD_CCLIEN = ' ' THEN 0 ELSE 1 END) ORDEM " + CRLF
	
	cQuery += " FROM " +RetSqlName("NZD")+ " NZD " + CRLF
	cQuery += " WHERE	NZD_FILIAL	= '" +xFilial("NZD")+ "' " + CRLF
	cQuery += " 	AND NZD_CCORRE	= '" +cCodCor+ 	"' " + CRLF
	cQuery += " 	AND NZD_LCORRE	= '" +cLojCor+ 	"' " + CRLF
	cQuery += " 	AND NZD_DTINI	<= '"+cDtAnda+ 	"' " + CRLF
	cQuery += " 	AND NZD_DTFIM	>= '"+cDtAnda+ 	"' " + CRLF
	cQuery += " 	AND (NZD_CESCRI = '" +cEscri+ 	"' OR NZD_CESCRI = ' ') " + CRLF
	cQuery += " 	AND (NZD_CAREA	= '" +cArea+ 	"' OR NZD_CAREA  = ' ') " + CRLF
	cQuery += " 	AND	(NZD_CCOMAR = '" +cComarca+	"' OR NZD_CCOMAR = ' ') " + CRLF
	cQuery += " 	AND	(NZD_CFORO 	= '" +cForo+ 	"' OR NZD_CFORO  = ' ') " + CRLF
	cQuery += " 	AND	(NZD_CVARA	= '" +cVara+ 	"' OR NZD_CVARA  = ' ') " + CRLF	
	cQuery += " 	AND	(NZD_CCLIEN = '" +cCodCli+ 	"' OR NZD_CCLIEN = ' ') " + CRLF
	cQuery += " 	AND (NZD_LCLIEN = '" +cLojCli+ 	"' OR NZD_LCLIEN = ' ') " + CRLF
	cQuery += " 	AND NZD.D_E_L_E_T_ 	= ' ' " + CRLF
	
	If cBanco == "ORACLE"
		cQuery += " AND ROWNUM = 1 " + CRLF
	EndIf
	
	cQuery += " ORDER BY ORDEM DESC"
							
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTabela, .F., .T.)
	TcSetField(cTabela, "NZD_DTINI", "D", 8, 0)
	TcSetField(cTabela, "NZD_DTFIM", "D", 8, 0)
	
	If !(cTabela)->( Eof() )

		Aadd(aRetorno, STR0009 + DtoC( (cTabela)->NZD_DTINI ) +" a "+ DtoC( (cTabela)->NZD_DTFIM ) +" - "+ AllTrim( (cTabela)->NZD_OBSERV ) )		//"Negociação Especial: "
	EndIf

	(cTabela)->( DbCloseArea() )
	RestArea( aArea )

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCtrCor
Busca as informações do contrato de correspondente x atos NZC.
 
@param 
@return 
@author Rafael Tenorio da Costa
@since 30/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetCtrCor( 	cCodCor		, cLojCor	, cEscri	, cArea		,;
							cCodCli		, cLojCli	, cReemCorre, cPreposto	,;
							lPrecifica	, aExtrato	, cTipSerAnt, cReemPrepo	,;
							dDtAndaAnt	, cStatusIt	)

	Local aArea		:= GetArea()
	Local aRetorno 	:= {}
	Local cTabela	:= GetNextAlias()
	Local cQuery	:= ""
	Local aTamVlr	:= TamSx3("NZC_VLSVRE")
	Local nValor	:= 0
	Local cObserv	:= STR0010	//"Sem Contrato"
	Local cProduto	:= ""
	Local nQdeDias	:= 0
	Local cInfo		:= "1"		//Valor Não Calculado
	Local cRevisa	:= "1"		//Define se deve ser revisado o extrato
	Local cBanco  	:= Upper( AllTrim( TcGetDb() ) )
	Local nVlrCalc	:= 0
	Local bCondicao	:= Nil
							
	cQuery := " SELECT "
	
	If !( cBanco == "ORACLE" )
		cQuery += " TOP 1 "
	EndIf	
	
	cQuery += " 	NZC_VLSVRE, NZC_VLSVRN, NZC_VLPRRE, NZC_VLPRRN, NZC_AGRUVL, NZC_PRODUT, " + CRLF
	cQuery += "  	(CASE WHEN NZC_CESCRI	= ' ' THEN 0 ELSE 1 END) + " + CRLF
	cQuery += " 	(CASE WHEN NZC_CAREA	= ' ' THEN 0 ELSE 1 END) + " + CRLF
	cQuery += " 	(CASE WHEN NZC_CCLIEN	= ' ' THEN 0 ELSE 1 END) ORDEM " + CRLF
	cQuery += " FROM " +RetSqlName("NZC")+ CRLF
	cQuery += " WHERE	NZC_FILIAL  = '" +xFilial("NZC")+ "' " + CRLF
	cQuery += " 	AND NZC_CCORRE	= '" +cCodCor+ 		"' " + CRLF
	cQuery += " 	AND NZC_LCORRE	= '" +cLojCor+ 		"' " + CRLF
	cQuery += " 	AND (NZC_CESCRI = '" +cEscri+ 		"' OR NZC_CESCRI = ' ') " + CRLF
	cQuery += " 	AND (NZC_CAREA	= '" +cArea+ 		"' OR NZC_CAREA  = ' ') " + CRLF
	cQuery += " 	AND	(NZC_CCLIEN = '" +cCodCli+ 		"' OR NZC_CCLIEN = ' ') " + CRLF
	cQuery += " 	AND (NZC_LCLIEN = '" +cLojCli+ 		"' OR NZC_LCLIEN = ' ') " + CRLF
	cQuery += " 	AND NZC_CTPSER  = '" +cTipSerAnt+ 	"' " + CRLF
	cQuery += " 	AND D_E_L_E_T_ 	= ' ' " + CRLF
	
	If cBanco == "ORACLE"
		cQuery += " AND ROWNUM = 1 " + CRLF
	EndIf
	
	cQuery += " ORDER BY ORDEM DESC"
							
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTabela, .F., .T.)
	
	TcSetField(cTabela, "NZC_VLSVRE", "N", aTamVlr[1], aTamVlr[2]) 
	TcSetField(cTabela, "NZC_VLSVRN", "N", aTamVlr[1], aTamVlr[2])
	TcSetField(cTabela, "NZC_VLPRRE", "N", aTamVlr[1], aTamVlr[2])
	TcSetField(cTabela, "NZC_VLPRRN", "N", aTamVlr[1], aTamVlr[2])
		
	If !(cTabela)->( Eof() )
		
		cObserv := ""
		
		//Verifica se eh preposto	
		If !Empty(cPreposto)
		
			//Verifica se cliente reembolsa serviço do preposto
			If cReemPrepo == "1"
				nValor := (cTabela)->NZC_VLPRRE 			
			Else
				nValor := (cTabela)->NZC_VLPRRN			
			EndIf
		Else
		
			//Verifica se cliente reembolsa serviço do correspondente
			If cReemCorre == "1"
				nValor := (cTabela)->NZC_VLSVRE			
			Else
				nValor := (cTabela)->NZC_VLSVRN			
			EndIf
		EndIf
		
		//Carrega valor calculado
		nVlrCalc := nValor
		
		If nValor == 0 
			cObserv	:= STR0011	//"Preço não encontrato"
			cInfo	:= "1"		//Valor Não Calculado
		Else	
			cInfo	:= "3"		//Valor Calculado
		EndIf
		
		//Regras para definir se ira ou nao gerar valor a pagar dependendo do tipo de agrupamento de valor
		If Len(aExtrato) > 0
		
			Do Case
			
				//Validacao para o agrupamento por dia
				Case (cTabela)->NZC_AGRUVL == "1"
				
				 	If Empty(cPreposto)
						//Verifica se ja existe tipo de servico e data				 	
						bCondicao := {|x| x[11][3] == cTipSerAnt .And. Empty(x[12][3]) .And. x[33][3] == dDtAndaAnt}
				 	Else
						//Verifica se ja existe tipo de servico, data e presposto				 	
						bCondicao := {|x| x[11][3] == cTipSerAnt .And. !Empty(x[12][3]) .And. x[33][3] == dDtAndaAnt}  
					EndIf
	
				//Validacao para o agrupamento por ato
				Case (cTabela)->NZC_AGRUVL == "2"
 					//sempre gera registro com valor				 	
					bCondicao := {|x| .F.}
					
				//Validacao para o agrupamento por extrato
				Case (cTabela)->NZC_AGRUVL == "3"
				
				 	If Empty(cPreposto)
						//Verifica se ja existe tipo de servico e data				 	
						bCondicao := {|x| x[11][3] == cTipSerAnt .And. Empty(x[12][3])}
				 	Else
						//Verifica se ja existe tipo de servico, data e presposto				 	
						bCondicao := {|x| x[11][3] == cTipSerAnt .And. !Empty(x[12][3])}  
					EndIf
			End Case
			
			//Define se ira gerar valor a pagar ou nao
			If Ascan(aExtrato, bCondicao) > 0
				lPrecifica := .F.
			Else
				lPrecifica := .T.
			EndIf
		Else
		
		 	lPrecifica := .T.						 	
		EndIf
		
		If lPrecifica
			cStatusIt	:= "2"		//Aprovado
		
		//Agrupamento por dia
		ElseIf (cTabela)->NZC_AGRUVL == "1" .And. !lPrecifica
		 	nValor		:= 0	
			cObserv		:= STR0012	//"Ato agrupado por dia"
			cInfo		:= "3"		//Valor Calculado
			cRevisa 	:= "2"		//2=Não
			cStatusIt	:= "5"		//Agrupado
		
		//Agrupamento por extrato
		ElseIf (cTabela)->NZC_AGRUVL == "3" .And. !lPrecifica
		 	nValor		:= 0	
			cObserv		:= STR0013	//"Ato agrupado por extrato"
			cInfo		:= "3"		//Valor Calculado
			cRevisa 	:= "2"		//2=Não
			cStatusIt	:= "5"		//Agrupado
			 
		EndIf
				
		//Pega Produto
		cProduto := (cTabela)->NZC_PRODUT 
	EndIf
	
	Aadd(aRetorno, nValor 	) //1
	Aadd(aRetorno, cObserv 	) //2
	Aadd(aRetorno, cProduto	) //3
	Aadd(aRetorno, cInfo	) //4
	Aadd(aRetorno, cRevisa	) //5
	Aadd(aRetorno, nVlrCalc	) //6
	Aadd(aRetorno, cStatusIt) //7
	
	(cTabela)->( DbCloseArea() )
	RestArea( aArea )

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaExt
Grava os dados do extrata nas tabelas NZF\NZG
 
@param	aExtrato - Dados que seram gravados nas tabela NZF\NZG 
@return 
@author Rafael Tenorio da Costa
@since 04/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravaExt( aExtrato, nTotal )

	Local aArea			:= GetArea()
	Local aCamposNZF	:= {}
	Local aAuxNZG		:= {}	
	Local aCamposNZG	:= {}
	Local nReg			:= 0
	Local nCont			:= 0
	Local cCodigo		:= GetSxeNum("NZF", "NZF_COD")
	Local aRecNT4		:= {}

	//Carrega campos do extrato
	For nReg:=1 To Len( aExtrato )
	
		Aadd( aCamposNZF, {"NZF_COD"	, cCodigo} )
		Aadd( aCamposNZF, {"NZF_TOTAL"	, nTotal} )
	
		aAuxNZG := {}
		Aadd( aAuxNZG, {"NZG_COD"	, cCodigo} )
		Aadd( aAuxNZG, {"NZG_ITEM"	, StrZero(nReg, TamSx3("NZG_ITEM")[1])} )

		For nCont:=1 To Len( aExtrato[nReg] )
				
			//Carrega cabeçalho
			If nReg == 1 .And. !Empty( aExtrato[nReg][nCont][1] )
				Aadd( aCamposNZF, 	{ aExtrato[nReg][nCont][1], aExtrato[nReg][nCont][3] } )
			EndIf
			
			//Carrega itens
			If !Empty( aExtrato[nReg][nCont][2] )
			
				Aadd( aAuxNZG, 		{ aExtrato[nReg][nCont][2], aExtrato[nReg][nCont][3] } )
				
				//Carrega recno NT4
				If aExtrato[nReg][nCont][2] == "NZG_RECNT4"
					Aadd(aRecNT4, aExtrato[nReg][nCont][3])
				EndIf
			EndIf
			
		Next nCont
		
		If Len(aAuxNZG) > 0
			Aadd( aCamposNZG, aAuxNZG)		
		EndIf 
	
	Next nReg
	
	Begin Transaction

		//Chama execauto para gravar o extrato	
		lRetorno := J190RotAut( aCamposNZF, aCamposNZG, 3 )
		
		//Atualiza status de processado
		If lRetorno
			AtuNT4( aRecNT4, "1" )
		EndIf	
	
		If lRetorno
			ConfirmSX8()
		Else
			RollBackSX8()
		EndIf
	
	End Transaction

	RestArea( aArea )

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuNT4
Atualiza dados na tabela NT4 pelos recnos
 
@param	aRecNT4 - Array com os recno da NT4 que seram atualizados 
@return 
@author Rafael Tenorio da Costa
@since 14/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuNT4( aRecNT4, cStatus )

	Local aArea		:= GetArea()
	Local aAreaNT4	:= NT4->( GetArea() )	
	Local nCont 	:= 1

	DbSelectArea("NT4")
	For nCont:=1 To Len( aRecNT4 )
	
		If aRecNT4[nCont] > 0
		 
			DbGoTo( aRecNT4[nCont] )
			
			If !NT4->( Eof() )
				RecLock("NT4", .F.)
					NT4->NT4_PROEXT := cStatus
				NT4->( MsUnLock() )
			EndIf
		
		EndIf
	Next nCont

	RestArea( aAreaNT4 )
	RestArea( aArea )
	
Return Nil	

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAviso
Retorna o conteudo o campo  NZC_AVISO memo
 
@param	nRecNZI		- Recno da tabela NZI 
@return	cRetorno	- Retorna o conteudo do campo NZI_AVISO 
@author Rafael Tenorio da Costa
@since 15/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetAviso( nRecNZI )

	Local aArea		:= GetArea()
	Local cRetorno 	:= ""
	
	DbSelectArea("NZI")
	NZI->( DbGoto( nRecNZI ) )
	If !NZI->( Eof() )
		cRetorno := AllTrim( NZI->NZI_AVISO )
	EndIf
	
	RestArea( aArea ) 

Return cRetorno	