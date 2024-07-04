#include "ubar005.ch"
#include "protheus.ch"
#include "report.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} UBAR005
Relatorio Resumo de Produção/Beneficiamento por talhao

@author Aécio Gomes
@since 21/06/2013
@version MP11.8
/*/
//-------------------------------------------------------------------
Function UBAR005(cAliasTRB)
	Local oReport
	Local cPerg := "UBAC007"
	Private cAliasTRB := ""

	Private _lNovSafra 	:= .F.
		
	If NN1->(ColumnPos('NN1_CODSAF' )) > 0
		_lNovSafra := .T.
	EndIf

	If FindFunction("TRepInUse") .And. TRepInUse()
	/**
	 Grupo de perguntas "UBAR007"
		MV_PAR01 - Safra
		MV_PAR02 - Produto
		MV_PAR03 - Produtor
		MV_PAR04 - Loja
		MV_PAR05 - Fazenda
		MV_PAR06 - Talhao
		MV_PAR07 - Variedade
		MV_PAR08 - Status Talhão
		MV_PAR09 - Considera Apenas Beneficiamento
		MV_PAR10 - Unidade Beneficiamento		
	**/
		Pergunte(cPerg,.F.)
	
	//-------------------------
	// Interface de impressão
	//-------------------------
		oReport:= ReportDef(cPerg)
		oReport:PrintDialog()
	EndIf

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Define do layout e formato do relatório

@return oReport	Objeto criado com o formato do relatório
@author Aécio Gomes
@since 21/06/2013
@version MP11.8
/*/
//-------------------------------------------------------------------------------------
Static Function ReportDef(cPerg)
	Local oReport	:= NIL
	Local oSec1		:= NIL
	Local oSec2		:= NIL
	Local oFunc1	:= Nil
	Local oFunc2	:= Nil
	Local oBreak1	:= Nil
	Local oBreak2	:= Nil

	DEFINE REPORT oReport NAME "UBAR005" TITLE STR0001 PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} //"Resumo de Produção/Beneficiamento"
	oReport:lParamPage 	:= .F. 	//Não imprime os parametros
	oReport:nFontBody 	:= 8 	//Aumenta o tamanho da fonte
	oReport:SetCustomText( {|| UBARCabec(oReport, mv_par01) } ) // Cabeçalho customizado

//---------
// Seção 1
//---------
	DEFINE SECTION oSec1 OF oReport TITLE STR0002 TABLES "DXL", "DXI", "NN4" BREAK HEADER AUTO SIZE //"RESUMO POR TALHAO"
	oSec1:SetTotalInLine(.F.)   // Define se imprime o total por linha
	oSec1:SetAutoSize(.T.) 		// Define se as células serão ajustadas automaticamente na seção
	oSec1:SetReadOnly(.T.) 		// Define se o usuário não poderá alterar informações da seção, ou seja, não poderá remover as células pré-definidas.
	
	DEFINE CELL NAME "DXL_FAZ" 		OF oSec1 TITLE STR0003 SIZE TamSX3("NN4_FAZ")[1] //"Fazenda"
	DEFINE CELL NAME "NN4_TALHAO" 	OF oSec1 TITLE STR0004 SIZE TamSX3("NN4_TALHAO")[1] //"TH"
	DEFINE CELL NAME "NN4_DESVAR" 	OF oSec1 TITLE STR0005 SIZE TamSX3("NN4_DESVAR")[1] //"Variedade"
	DEFINE CELL NAME "NN4_HECTAR" 	OF oSec1 TITLE STR0006 SIZE TamSX3("NN4_HECTAR")[1] //"Hectares"
	DEFINE CELL NAME "QTD_FDAO" 	OF oSec1 TITLE STR0007 SIZE 10 PICTURE "@E 9,999,999,999" //"Fardoes"
	DEFINE CELL NAME "PS_FARDAO" 	OF oSec1 TITLE STR0008 SIZE TamSX3("DXS_PSLIQU")[1] PICTURE PesqPict("DXS","DXS_PSLIQU") //"Total(KG)"
	DEFINE CELL NAME "PS_ARROBA" 	OF oSec1 TITLE STR0009 SIZE TamSX3("DXS_PSLIQU")[1] PICTURE PesqPict("DXS","DXS_PSLIQU") //"Total(@)"
	DEFINE CELL NAME "PS_HA" 		OF oSec1 TITLE STR0010 SIZE TamSX3("DXS_PSLIQU")[1] PICTURE PesqPict("DXS","DXS_PSLIQU") //"(@)HA"
	DEFINE CELL NAME "MD_RDMTO"		OF oSec1 TITLE STR0011 SIZE 10 PICTURE PesqPict("DXL","DXL_RDMTO") //"%Rd"
	DEFINE CELL NAME "QTD_FDI" 		OF oSec1 TITLE STR0012 SIZE 10 PICTURE "@E 9,999,999,999" //"Fardos"
	DEFINE CELL NAME "PS_FDI"		OF oSec1 TITLE STR0013 SIZE TamSX3("DXS_PSLIQU")[1] PICTURE PesqPict("DXS","DXS_PSLIQU") //"(KG)Fardos"
	DEFINE CELL NAME "PS_HA_FDI"	OF oSec1 TITLE STR0014 SIZE TamSX3("DXS_PSLIQU")[1] PICTURE PesqPict("DXS","DXS_PSLIQU") //"(@)HA"
	
	oSec1:SetTotalText(STR0015) // Texto da seção tolalizadora //"Total produtor"
	DEFINE BREAK oBreak1 OF oSec1 WHEN oSec1:Cell("DXL_FAZ")
	oBreak1:OnBreak({|a,b| UsrOnBreak(a, b, oBreak1, oReport)})
	
	DEFINE FUNCTION oFunc1 NAME "T1" FROM oSec1:Cell("QTD_FDAO") OF oSec1 FUNCTION SUM  	NO END REPORT BREAK oBreak1
	DEFINE FUNCTION oFunc1 NAME "T2" FROM oSec1:Cell("NN4_HECTAR") OF oSec1 FUNCTION SUM  	NO END REPORT BREAK oBreak1
	DEFINE FUNCTION oFunc1 NAME "T3" FROM oSec1:Cell("PS_FARDAO") OF oSec1 FUNCTION SUM  	NO END REPORT BREAK oBreak1
	DEFINE FUNCTION oFunc1 NAME "T4" FROM oSec1:Cell("PS_ARROBA") OF oSec1 NO END REPORT BREAK oBreak1
	DEFINE FUNCTION oFunc1 NAME "T5" FROM oSec1:Cell("PS_HA") OF oSec1 NO END REPORT BREAK oBreak1
	DEFINE FUNCTION oFunc1 NAME "T6" FROM oSec1:Cell("MD_RDMTO") OF oSec1 NO END REPORT BREAK oBreak1
	DEFINE FUNCTION oFunc1 NAME "T7" FROM oSec1:Cell("QTD_FDI") OF oSec1 FUNCTION SUM  NO END REPORT BREAK oBreak1
	DEFINE FUNCTION oFunc1 NAME "T8" FROM oSec1:Cell("PS_FDI") OF oSec1 FUNCTION SUM NO END REPORT BREAK oBreak1
	DEFINE FUNCTION oFunc1 NAME "T9" FROM oSec1:Cell("PS_HA_FDI") OF oSec1 NO END REPORT BREAK oBreak1
	oFunc1:lEndSection :=  .T.
//---------
// Seção 2
//---------           
	DEFINE SECTION oSec2 OF oReport TITLE STR0016 TABLES "DXL", "DXI", "NN4" BREAK HEADER  //"RESUMO POR VARIEDADE"
	oSec2:SetTotalInLine(.F.)   // Define se imprime o total por linha
	oSec2:SetAutoSize(.T.) 		// Define se as células serão ajustadas automaticamente na seção
	oSec2:SetReadOnly(.T.) 		// Define se o usuário não poderá alterar informações da seção, ou seja, não poderá remover as células pré-definidas.
	
	DEFINE CELL NAME "DXL_FAZ" 		OF oSec2 TITLE STR0003 SIZE TamSX3("NN4_FAZ")[1] //"Fazenda"
	DEFINE CELL NAME "NN4_CODVAR" 	OF oSec2 TITLE STR0017 SIZE TamSX3("NN4_CODVAR")[1] //"Cod. Var"
	DEFINE CELL NAME "NN4_DESVAR" 	OF oSec2 TITLE STR0005 SIZE TamSX3("NN4_DESVAR")[1] //"Variedade"
	DEFINE CELL NAME "NN4_HECTAR" 	OF oSec2 TITLE STR0006 SIZE TamSX3("NN4_HECTAR")[1] //"Hectares"
	DEFINE CELL NAME "QTD_FDAO" 	OF oSec2 TITLE STR0007 SIZE 10 PICTURE "@E 9,999,999,999" //"Fardoes"
	DEFINE CELL NAME "PS_FARDAO" 	OF oSec2 TITLE STR0008 SIZE TamSX3("DXS_PSLIQU")[1] PICTURE PesqPict("DXS","DXS_PSLIQU") //"Total(KG)"
	DEFINE CELL NAME "PS_ARROBA" 	OF oSec2 TITLE STR0009 SIZE TamSX3("DXS_PSLIQU")[1] PICTURE PesqPict("DXS","DXS_PSLIQU") //"Total(@)"
	DEFINE CELL NAME "PS_HA" 		OF oSec2 TITLE STR0010 SIZE TamSX3("DXS_PSLIQU")[1] PICTURE PesqPict("DXS","DXS_PSLIQU") //"(@)HA"
	DEFINE CELL NAME "MD_RDMTO"		OF oSec2 TITLE STR0011 SIZE TamSX3("DXL_RDMTO")[1] PICTURE PesqPict("DXL","DXL_RDMTO") //"%Rd"
	DEFINE CELL NAME "QTD_FDI" 		OF oSec2 TITLE STR0012 SIZE 10 PICTURE "@E 9,999,999,999" //"Fardos"
	DEFINE CELL NAME "PS_FDI"		OF oSec2 TITLE STR0013 SIZE TamSX3("DXS_PSLIQU")[1] PICTURE PesqPict("DXS","DXS_PSLIQU") //"(KG)Fardos"
	DEFINE CELL NAME "PS_HA_FDI"	OF oSec2 TITLE STR0014 SIZE TamSX3("DXS_PSLIQU")[1] PICTURE PesqPict("DXS","DXS_PSLIQU") //"(@)HA"
	
	oSec2:SetTotalText(STR0015) // Texto da seção tolalizadora //"Total produtor"
	DEFINE BREAK oBreak2 OF oSec2 WHEN oSec2:Cell("DXL_FAZ")
	oBreak2:OnBreak({|a,b| UsrOnBreak(a, b, oBreak2, oReport)})
	
	DEFINE FUNCTION oFunc2 NAME "T1" FROM oSec2:Cell("QTD_FDAO") OF oSec2 FUNCTION SUM  	NO END REPORT BREAK oBreak2
	DEFINE FUNCTION oFunc2 NAME "T2" FROM oSec2:Cell("NN4_HECTAR") OF oSec2 FUNCTION SUM  	NO END REPORT BREAK oBreak2
	DEFINE FUNCTION oFunc2 NAME "T3" FROM oSec2:Cell("PS_FARDAO") OF oSec2 FUNCTION SUM  	NO END REPORT BREAK oBreak2
	DEFINE FUNCTION oFunc2 NAME "T4" FROM oSec2:Cell("PS_ARROBA") OF oSec2 NO END REPORT BREAK oBreak2
	DEFINE FUNCTION oFunc2 NAME "T5" FROM oSec2:Cell("PS_HA") OF oSec2 NO END REPORT BREAK oBreak2
	DEFINE FUNCTION oFunc2 NAME "T6" FROM oSec2:Cell("MD_RDMTO") OF oSec2 NO END REPORT BREAK oBreak2
	DEFINE FUNCTION oFunc2 NAME "T7" FROM oSec2:Cell("QTD_FDI") OF oSec2 FUNCTION SUM  NO END REPORT BREAK oBreak2
	DEFINE FUNCTION oFunc2 NAME "T8" FROM oSec2:Cell("PS_FDI") OF oSec2 FUNCTION SUM NO END REPORT BREAK oBreak2
	DEFINE FUNCTION oFunc2 NAME "T9" FROM oSec2:Cell("PS_HA_FDI") OF oSec2 NO END REPORT BREAK oBreak2
	oFunc2:lEndSection :=  .T.
	
Return oReport

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Imprimi os dados no relatorio

@param oReport	Objeto para manipulação das seções, atributos e dados do relatório.
@return 
@author Aécio Ferreira Gomes
@since 21/06/2013
@version MP11.8
/*/
//-------------------------------------------------------------------------------------
Static Function PrintReport(oReport)
	Local oSec1		:= oReport:Section(1)
	Local oSec2		:= oReport:Section(2)
//Local cAliasTRB	:= ""
	Local cFazenda	:= ""
	Local cVariedade:= ""

	If Type("cAliasTRB") = "U"
		cAliasTRB := UBAC007TRB()[1]
	endif

	If Select(cAliasTRB) > 0
		(cAliasTRB)->(dbGotop())
		If (cAliasTRB)->(!Eof())
		//--------------------------------------------------------------
		// Imprime texto antes centralizado antes da impressão da seção
		//--------------------------------------------------------------
			oReport:Skipline(1)
			oReport:PrintText("",oReport:Row())
			oReport:Prtcenter(STR0002) //"RESUMO POR TALHAO"
			oReport:Skipline(1)
		EndIf
	
		While !oReport:Cancel() .And. (cAliasTRB)->(!Eof())
			oSec1:Init()
			oSec1:Cell("DXL_FAZ"):SetValue( (cAliasTRB)->FAZENDA )										// Codigo Fazenda
			oSec1:Cell("NN4_TALHAO"):SetValue( (cAliasTRB)->TALHAO )									// Codigo Talhao
			oSec1:Cell("NN4_DESVAR"):SetValue( (cAliasTRB)->DESCVAR )  									// Descrição da Variedade
			oSec1:Cell("NN4_HECTAR"):SetValue( (cAliasTRB)->HECTARES )  								// Hectares
			oSec1:Cell("QTD_FDAO"):SetValue( (cAliasTRB)->QTD_FDAO )									// Total de fardoes
			oSec1:Cell("PS_FARDAO"):SetValue( (cAliasTRB)->PS_FARDAO )									// Peso Total de Fardoes
			oSec1:Cell("PS_ARROBA"):SetValue( Round( ((cAliasTRB)->PS_FARDAO/15),2))						// Peso total em arroba dos farões do total em hectares da área do talhão
			oSec1:Cell("PS_HA"):SetValue( Round( ( (cAliasTRB)->PS_FARDAO/15)/(cAliasTRB)->HECTARES,2 ))	// Peso em arroba dos fardões por hectar da área do talhão
			oSec1:Cell("MD_RDMTO"):SetValue( ( (cAliasTRB)->PS_FDI/(cAliasTRB)->PS_FARDAO )*100 )			// Média de Rendimento de Pluma
			oSec1:Cell("QTD_FDI"):SetValue( (cAliasTRB)->QTD_FDI )										// Quantidade de Fardos de Pluma
			oSec1:Cell("PS_FDI"):SetValue( (cAliasTRB)->PS_FDI )										// Peso total de Fardos de Pluma
			oSec1:Cell("PS_HA_FDI"):SetValue( ((cAliasTRB)->PS_FDI/15)/(cAliasTRB)->HECTARES ) 					// Peso total em Kgs de fardinhos por hectares da área do talhão
			oSec1:Cell("DXL_FAZ"):Disable()
			oSec1:PrintLine()
			(cAliasTRB)->(dbSkip())
		End
	
		oSec1:Finish() // Finaliza impressão da seção 1
	
		(cAliasTRB)->(dbGoTop())
		(cAliasTRB)->(dbSetOrder(2))
		If (cAliasTRB)->(!Eof())
		//--------------------------------------------------------------
		// Imprime texto antes centralizado antes da impressão da seção
		//--------------------------------------------------------------
			oReport:Skipline(3)
			oReport:Prtcenter(STR0016) //"RESUMO POR VARIEDADE"
			oReport:Skipline(1)
		EndIf
	
		While !oReport:Cancel() .And. (cAliasTRB)->(!Eof())
			cFazenda	:= (cAliasTRB)->FAZENDA
			cVariedade	:= (cAliasTRB)->VARIEDADE
			cDescVar	:= (cAliasTRB)->DESCVAR
			nTotHectar	:= 0
			nQtdFdao 	:= 0
			nPsFdao  	:= 0
			nQtdFdi	:= 0
			nPsFdi		:= 0
			While cFazenda + cVariedade == (cAliasTRB)->(FAZENDA+VARIEDADE)
				nTotHectar	 += (cAliasTRB)->HECTARES
				nQtdFdao 	 += (cAliasTRB)->QTD_FDAO
				nPsFdao  	 += (cAliasTRB)->PS_FARDAO
				nQtdFdi	 += (cAliasTRB)->QTD_FDI
				nPsFdi		 += (cAliasTRB)->PS_FDI
				(cAliasTRB)->(dbSkip())
				If cFazenda + cVariedade # (cAliasTRB)->(FAZENDA+VARIEDADE)
					oSec2:Init()
					oSec2:Cell("DXL_FAZ"):SetValue( cFazenda )								// Codigo Fazenda
					oSec2:Cell("NN4_CODVAR"):SetValue( cVariedade )							// Codigo Variedade
					oSec2:Cell("NN4_DESVAR"):SetValue( cDescVar )  							// Descrição da Variedade
					oSec2:Cell("NN4_HECTAR"):SetValue( nTotHectar )			  				// Hectares
					oSec2:Cell("QTD_FDAO"):SetValue( nQtdFdao )								// Total de fardoes
					oSec2:Cell("PS_FARDAO"):SetValue( nPsFdao )								// Peso Total de Fardoes
					oSec2:Cell("PS_ARROBA"):SetValue( Round( nPsFdao/15,2) )				// Peso total em arroba dos farões do total em hectares da área do talhão
					oSec2:Cell("PS_HA"):SetValue( Round( ( nPsFdao/15 )/nTotHectar,2 ) )	// Peso em arroba dos fardões por hectar da área do talhão
					oSec2:Cell("MD_RDMTO"):SetValue( ( nPsFdi/nPsFdao )*100 )				// Média de Rendimento de Pluma
					oSec2:Cell("QTD_FDI"):SetValue( nQtdFdi )								// Quantidade de Fardos de Pluma
					oSec2:Cell("PS_FDI"):SetValue( nPsFdi )									// Peso total de Fardos de Pluma
					oSec2:Cell("PS_HA_FDI"):SetValue( (nPsFdi/nTotHectar)/15 ) 					// Peso total em Kgs de fardinhos por hectares da área do talhão
					oSec2:Cell("DXL_FAZ"):Disable()
					oSec2:Cell("NN4_CODVAR"):Disable()
					oSec2:PrintLine()
				EndIf
			End
		End

		oSec2:Finish()
	EndIf

Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} UBARCabec
Função para montar cabecalho do relatorio  

@param oReport Objeto para manipulação das seções, atributos e dados do relatório.
@return aCabec  Array com o cabecalho montado
@author Aécio Gomes
@since 21/06/2013
@version MP11.8
/*/
//----------------------------------------------------------------------------------
Static Function UBARCabec(oReport, cSafra)
	Local aCabec := {}
	Local cNmEmp	:= ""
	Local cNmFilial	:= ""
	Local cChar		:= CHR(160)  // caracter dummy para alinhamento do cabeçalho

	Default cSafra := ""

	If SM0->(Eof())
		SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
	Endif

	cNmEmp	 := AllTrim( SM0->M0_NOME )
	cNmFilial:= AllTrim( SM0->M0_FILIAL )

// Linha 1
	AADD(aCabec, "__LOGOEMP__") // Esquerda

// Linha 2 
	AADD(aCabec, cChar) //Esquerda
	aCabec[2] += Space(9) // Meio
	aCabec[2] += Space(9) + RptFolha + TRANSFORM(oReport:Page(),'999999') // Direita

// Linha 3
	AADD(aCabec, "SIGA /" + oReport:ReportName() + "/v." + cVersao) //Esquerda
	aCabec[3] += Space(9) + oReport:cRealTitle // Meio
	aCabec[3] += Space(9) + STR0018 + Dtoc(dDataBase)   // Direita //"Dt.Ref:"

// Linha 4
	AADD(aCabec, RptHora + oReport:cTime) //Esquerda
	aCabec[4] += Space(9) +STR0019 + cNmFilial // Meio //"Filial:"
	aCabec[4] += Space(9) + RptEmiss + oReport:cDate   // Direita

// Linha 5
	AADD(aCabec, STR0020 + cNmEmp) //Esquerda //"Empresa:"
	aCabec[5] += Space(9) // Meio
	If !Empty(cSafra)
		aCabec[5] += Space(9)+ STR0021+cSafra   // Direita //"Safra:"
	EndIf

// Linha 6
	If _lNovSafra
		AADD(aCabec, STR0022 + Posicione("NJ0",1,FWxFilial("NJ0")+mv_par03+mv_par04,"NJ0_NOME")) //Esquerda //"Entidade:"
	Else
		AADD(aCabec, STR0022 + Posicione("NJ0",1,FWxFilial("NJ0")+mv_par02+mv_par03,"NJ0_NOME")) //Esquerda //"Entidade:"
	EndIf	

Return aCabec
                          
//-------------------------------------------------------------------
/*/{Protheus.doc} UsrOnBreak
Tratamento antes da impressão dos totalizadores da quebra

@param uBreakAnt - Quebra anterior
@param uBreakAtu - Quebra atual
@param oBreak - Objeto da quebra
@param oReport - Objeto do relatorio
@author Aécio Gomes
@since 21/07/2013
@version MP11.8
/*/
//-------------------------------------------------------------------
Static Function UsrOnBreak(uBreakAnt,uBreakAtu,oBreak, oReport)
	Local nTHectar 		:= oBreak:GetFunction("T2"):UVALUE 		// Total Hectar da quebra
	Local nTHectarBreak	:= oBreak:GetFunction("T2"):USECTION 	// Total Hectar da seção
	Local nTFdao	 	:= oBreak:GetFunction("T3"):UVALUE 		// Total peso fardao da quebra
	Local nTFdaoBreak	:= oBreak:GetFunction("T3"):USECTION 	// Total peso fardao da seção
	Local nTFdi	 		:= oBreak:GetFunction("T8"):UVALUE 		// Total peso fardinhos da quebra
	Local nTFdiBreak	:= oBreak:GetFunction("T8"):USECTION 	// Total peso fardinhos da seção

//Define o título que será impresso antes da impressão dos totalizadores
	If _lNovSafra
		oBreak:SetTitle(STR0023+Posicione("NN2",3,FWxFilial("NN2")+mv_par03+mv_par04+uBreakAnt,"NN2_NOME")) //"Total Fazenda:"
	Else
		oBreak:SetTitle(STR0023+Posicione("NN2",3,FWxFilial("NN2")+mv_par02+mv_par03+uBreakAnt,"NN2_NOME")) //"Total Fazenda:"
	EndIf
		

// Altera o valor do total da coluna total@
	oBreak:GetFunction("T4"):UVALUE := nTFdao/15 // Altera valor da quebra
	oBreak:GetFunction("T4"):USECTION := nTFdaoBreak/15 // Altera valor total da seção

// Altera o valor do total da coluna @HA
	oBreak:GetFunction("T5"):UVALUE := oBreak:GetFunction("T4"):UVALUE/nTHectar // Altera valor total da quebra
	oBreak:GetFunction("T5"):USECTION := oBreak:GetFunction("T4"):USECTION/nTHectarBreak // Altera valor total da seção

// Altera o valor do total da coluna %RD
	oBreak:GetFunction("T6"):UVALUE := (nTFdi/nTFdao)*100 // Altera valor total da quebra
	oBreak:GetFunction("T6"):USECTION := (nTFdiBreak/nTFdaoBreak)*100 // Altera valor total da seção

// Altera o valor do total da coluna (KG)HA
	oBreak:GetFunction("T9"):UVALUE := (nTFdi/nTHectar)/15 // Altera valor total da quebra
	oBreak:GetFunction("T9"):USECTION := (nTFdiBreak/nTHectarBreak)/15 // Altera valor total da seção

Return
