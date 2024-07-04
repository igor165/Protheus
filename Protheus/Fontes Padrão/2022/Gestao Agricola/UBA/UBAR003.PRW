#INCLUDE "UBAR003.ch"
#include "protheus.ch"
#include "report.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} UBAR003
Função de Relatorio Fardos por Tipo Classificacao
@author Bruna Rocio
@since 16/07/2013
@version MP11.8
/*/
//-------------------------------------------------------------------
Function UBAR003()
	Local oReport
	Local cPerg := "UBAR003"

	//variavel de unidade de beneficiamento
	Private cUserBenf 	:= "" 
	Private lRet		:= .F.

	Private _lNovSafra 	:= .F.
		
	If NN1->(ColumnPos('NN1_CODSAF' )) > 0
		_lNovSafra := .T.
	EndIf

	If FindFunction("TRepInUse") .And. TRepInUse()

		/* Grupo de peguntas UBAR003
		mv_par01 - Safra
		mv_par03 - Classificação de
		mv_par04 - Classificação até
		mv_par05 - Produtor
		mv_par06 - Loja
		mv_par07 - Fazenda 
		mv_par08 - Talhão (inserir logica) 
		mv_par09 - Variedade 
		mv_par10 - Prensa
		mv_par11 - Data Benef. de 
		mv_par12 - Data Benef. Ate
		mv_par13 - Situação? - Pendentes - Entregues - Ambos
		mv_par14 - Unidade de Beneficiamento
		mv_par02 - Codigo Produto
		*/	
		Pergunte(cPerg,.T.)

		//-------------------------
		// Interface de impressão    
		//-------------------------
		oReport:= ReportDef(cPerg)
		oReport:PrintDialog()
	EndIf

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Função de definição do layout e formato do relatório

@return oReport	Objeto criado com o formato do relatório
@author Bruna Rocio
@since 16/07/2013
@version MP11.8
/*/
//-------------------------------------------------------------------------------------
Static Function ReportDef(cPerg)
	Local oReport	:= NIL
	Local oSec1		:= NIL
	Local oSec2		:= NIL
	Local oFunc1	:= NIL
	Local pic		:= "@E 999,999"

	DEFINE REPORT oReport NAME "UBAR003" TITLE STR0001 PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} //"Estoque de Fardos por Tipo Classificação"
	oReport:lParamPage 	:= .F. //Não imprime os parametros
	oReport:nFontBody 	:= 8 //Aumenta o tamanho da fonte
	oReport:SetCustomText( {|| UBARCabec(oReport, mv_par01) } ) // Cabeçalho customizado

	//---------
	// Seção 1
	//---------
	DEFINE SECTION oSec1 OF oReport TITLE STR0002 TABLES "DXI", "DXA" AUTO SIZE //"Estoque de Fardos por Tipo/Produtor"
	oSec1:SetTotalInLine(.F.)   // Define se imprime o total por linha
	oSec1:SetReadOnly(.T.) 		// Define que o usuário não poderá alterar informações da seção, ou seja, não poderá remover as células pré-definidas.
	oSec1:ShowHeader(.T.)			// Define se apresenta titulo da seção

	DEFINE CELL NAME "DXI_PRDTOR"	OF oSec1 TITLE STR0003	//"Produtor"
	DEFINE CELL NAME "DXI_CLACOM"	OF oSec1 TITLE STR0004	//"Tipo"
	DEFINE CELL NAME "DXA_DESCRI" 	OF oSec1 TITLE STR0021	SIZE 22 //"Descrição"
	DEFINE CELL NAME "PERC"			OF oSec1 TITLE STR0005  SIZE 6 PICTURE	"@E 999.999"  //"%Rd"
	DEFINE CELL NAME "QTFARDOS"   	OF oSec1 TITLE STR0006 	PICTURE	pic//"Qt Fardos"
	DEFINE CELL NAME "QTSAIDA" 	   	OF oSec1 TITLE STR0008 	PICTURE	pic//"Qt Saídas"
	DEFINE CELL NAME "QTSALDO" 	   	OF oSec1 TITLE STR0009 	PICTURE pic//"Qt Saldo"
	DEFINE CELL NAME "VLFARDOS" 	OF oSec1 TITLE STR0010	PICTURE 	PESQPICT("DXL","DXL_PSLIQU") //"Fardos (KG)"
	DEFINE CELL NAME "VLSAIDA"	   	OF oSec1 TITLE STR0012 	PICTURE 	PESQPICT("DXL","DXL_PSLIQU") //"Saídas (KG)"
	DEFINE CELL NAME "VLSALDO"     	OF oSec1 TITLE STR0013 	PICTURE 	PESQPICT("DXL","DXL_PSLIQU") //"Saldo (KG)"


	oSec1:SetTotalText(STR0014) // Texto da seção tolalizadora //"Total Geral"

	DEFINE BREAK oBreak OF oSec1 WHEN oSec1:Cell("DXI_PRDTOR")

	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("QTFARDOS")  OF oSec1 FUNCTION SUM  NO END REPORT BREAK oBreak
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("QTSAIDA")   OF oSec1 FUNCTION SUM  NO END REPORT BREAK oBreak
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("QTSALDO")   OF oSec1 FUNCTION SUM  NO END REPORT BREAK oBreak
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("VLFARDOS")  OF oSec1 FUNCTION SUM  NO END REPORT BREAK oBreak
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("VLSAIDA")   OF oSec1 FUNCTION SUM  NO END REPORT BREAK oBreak
	DEFINE FUNCTION oFunc1 FROM oSec1:Cell("VLSALDO")   OF oSec1 FUNCTION SUM  NO END REPORT BREAK oBreak
	oBreak:setTitle(STR0015) //"Total Produtor"

	DEFINE SECTION oSec2 OF oReport TITLE STR0016 TABLES "DXI, DXA" //"Resumo por Tipo Classificação"
	oSec2:SetTotalInLine(.F.)   // Define se imprime o total por linha
	oSec2:SetAutoSize(.T.) 		// Define que as células serão ajustadas automaticamente na seção
	oSec2:SetReadOnly(.T.) 		// Define que o usuário não poderá alterar informações da seção, ou seja, não poderá remover as células pré-definidas.
	oSec2:ShowHeader(.T.)		// Define se apresenta titulo da seção

	DEFINE CELL NAME "DXI_CLACOM" 	OF oSec2 TITLE STR0004 	//"Tipo"
	DEFINE CELL NAME "DXA_DESCRI" 	OF oSec2 TITLE STR0021 	//"Descrição"
	DEFINE CELL NAME "PERC"    	   	OF oSec2 TITLE STR0005  SIZE 6 PICTURE	"@E 999.999"  //"%Rd"
	DEFINE CELL NAME "QTFARDOS"   	OF oSec2 TITLE STR0006 	PICTURE	pic	//"Qt Fardos"
	DEFINE CELL NAME "QTSAIDA" 	   	OF oSec2 TITLE STR0008 	PICTURE	pic//"Qt Saídas"
	DEFINE CELL NAME "QTSALDO" 	   	OF oSec2 TITLE STR0009 	PICTURE	pic//"Qt Saldo"
	DEFINE CELL NAME "VLFARDOS"		OF oSec2 TITLE STR0010 	PICTURE	PESQPICT("DXL","DXL_PSLIQU") //"Fardos (KG)"
	DEFINE CELL NAME "VLSAIDA"	   	OF oSec2 TITLE STR0012 	PICTURE	PESQPICT("DXL","DXL_PSLIQU") //"Saídas (KG)"
	DEFINE CELL NAME "VLSALDO"     	OF oSec2 TITLE STR0013	PICTURE	PESQPICT("DXL","DXL_PSLIQU")  //"Saldo (KG)"
	DEFINE CELL NAME "QTBLOCO"     	OF oSec2 TITLE STR0017 //"Blocos"

	oSec2:SetTotalText(STR0014) // Texto da seção tolalizadora //"Total Geral"

	DEFINE FUNCTION oFunc1 FROM oSec2:Cell("QTFARDOS")  OF oSec2 FUNCTION SUM  NO END REPORT
	DEFINE FUNCTION oFunc1 FROM oSec2:Cell("QTSAIDA")   OF oSec2 FUNCTION SUM  NO END REPORT
	DEFINE FUNCTION oFunc1 FROM oSec2:Cell("QTSALDO")   OF oSec2 FUNCTION SUM  NO END REPORT
	DEFINE FUNCTION oFunc1 FROM oSec2:Cell("VLFARDOS")  OF oSec2 FUNCTION SUM  NO END REPORT
	DEFINE FUNCTION oFunc1 FROM oSec2:Cell("VLSAIDA")   OF oSec2 FUNCTION SUM  NO END REPORT
	DEFINE FUNCTION oFunc1 FROM oSec2:Cell("VLSALDO")   OF oSec2 FUNCTION SUM  NO END REPORT
	DEFINE FUNCTION oFunc1 FROM oSec2:Cell("QTBLOCO")   OF oSec2 FUNCTION SUM  NO END REPORT

Return oReport

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Função para busca das informações que serão impressas no relatório

@param oReport	Objeto para manipulação das seções, atributos e dados do relatório.
@return 
@author Bruna Rocio
@since 16/07/2013
@version MP11.8
/*/
//-------------------------------------------------------------------------------------
Static Function PrintReport(oReport)
	Local oSec1		  := oReport:Section(1)
	Local oSec2		  := oReport:Section(2)
	Local cAlias	  := ""
	Local cQueryAux1  := ""
	Local cQueryAux2  := ""
	Local cQueryAux3  := ""
	Local cQueryAux4  := ""
	Local cQueryAux5  := ""
	Local cQueryAux6  := ""
	Local cQueryAux7  := ""
	Local cQueryAux8  := ""
	Local cQueryAux9  := ""

	#IFDEF TOP

	//----------------------------
	// Query do relatorio secao 1
	//----------------------------

	/*********** Tratamento das Perguntas **********/
	cQueryAux1 := " AND DXI1.D_E_L_E_T_ = ' ' "
	cQueryAux1 += " AND DXI1.DXI_FILIAL = '" + xFilial("DXI")+ "'"
	cQueryAux1 += " AND DXI1.DXI_SAFRA = '" + mv_par01 + "'"
	
	If _lNovSafra
		If  !Empty(mv_par02)
			cQueryAux1 += " AND DXI1.DXI_CODPRO = '" + mv_par02 + "'"
		EndIf
	EndIf
	
	If _lNovSafra	
		cQueryAux1 += " AND DXI1.DXI_CLACOM BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
		cQueryAux1 += " AND DXL1.DXL_DTBEN BETWEEN '" + DTOS(mv_par11) + "' AND '" + DTOS(mv_par12) + "'"
	Else
		cQueryAux1 += " AND DXI1.DXI_CLACOM BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "'"
		cQueryAux1 += " AND DXL1.DXL_DTBEN BETWEEN '" + DTOS(mv_par10) + "' AND '" + DTOS(mv_par11) + "'"
	EndIf	

	//Filtro Talhao
	If _lNovSafra
		If !Empty(mv_par08)
			cQueryAux1 += " AND DXL1.DXL_TALHAO = '" + mv_par08 + "'"
		EndIf
	Else
		If !Empty(mv_par07)
			cQueryAux1 += " AND DXL1.DXL_TALHAO = '" + mv_par07 + "'"
		EndIf
	EndIf	

	cQueryAux8 += " WHERE DXI.D_E_L_E_T_ = ' ' "
	cQueryAux8 += " AND DXI.DXI_FILIAL = '" + xFilial("DXI")+ "'"
	cQueryAux8 += " AND DXI.DXI_SAFRA = '" + mv_par01 + "'"
	
	If _lNovSafra
		If  !Empty(mv_par05)
			cQueryAux8 += " AND DXI.DXI_PRDTOR = '" + mv_par05 + "'"
			If  !Empty(mv_par06)
				cQueryAux8 += " AND DXI.DXI_LJPRO = '" + mv_par06 + "'"
			EndIf
		EndIf
	Else
		If  !Empty(mv_par04)
			cQueryAux8 += " AND DXI.DXI_PRDTOR = '" + mv_par04 + "'"
			If  !Empty(mv_par05)
				cQueryAux8 += " AND DXI.DXI_LJPRO = '" + mv_par05 + "'"
			EndIf
		EndIf
	EndIf
	
	If _lNovSafra	
		If  !Empty(mv_par02)
			cQueryAux8 += " AND DXI.DXI_CODPRO = '" + mv_par02 + "'"
		EndIf
	Endif
	
	If _lNovSafra	
		cQueryAux8 += " AND DXI.DXI_CLACOM BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "'"
		cQueryAux8 += " AND DXL.DXL_DTBEN BETWEEN'" + DTOS(mv_par11) + "' AND '" + DTOS(mv_par12) + "'"
	Else
		cQueryAux8 += " AND DXI.DXI_CLACOM BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "'"
		cQueryAux8 += " AND DXL.DXL_DTBEN BETWEEN'" + DTOS(mv_par10) + "' AND '" + DTOS(mv_par11) + "'"
	Endif	

	//Filtro Talhao
	If _lNovSafra
		If !Empty(mv_par08)
			cQueryAux8 += " AND DXL.DXL_TALHAO = '" + mv_par08 + "'"
		EndIf
	Else
		If !Empty(mv_par07)
			cQueryAux8 += " AND DXL.DXL_TALHAO = '" + mv_par07 + "'"
		EndIf
	EndIf	

	//Filtro de unidade de beneficiamento
	If _lNovSafra
		If !Empty(mv_par14)
			cQueryAux1 += " AND DXI_CODUNB = '" + mv_par14 + "'"
			cQueryAux8 += " AND DXI.DXI_CODUNB = '" + mv_par14 + "'"	 
		EndIf
	Else
		If !Empty(mv_par13)
			cQueryAux1 += " AND DXI_CODUNB = '" + mv_par13 + "'"
			cQueryAux8 += " AND DXI.DXI_CODUNB = '" + mv_par13 + "'"	 
		EndIf
	End if	
	
	If _lNovSafra
		If  !Empty(mv_par07)
			cQueryAux1 += " AND DXI_FAZ = '" + mv_par07 + "'"
			cQueryAux8 += " AND DXI.DXI_FAZ = '" + mv_par07 + "'"
		Endif
	Else
		If  !Empty(mv_par06)
			cQueryAux1 += " AND DXI_FAZ = '" + mv_par06 + "'"
			cQueryAux8 += " AND DXI.DXI_FAZ = '" + mv_par06 + "'"
		Endif
	EndIf	
	
	If _lNovSafra
		If  !Empty(mv_par09)
			cQueryAux1 += " AND DXI_CODVAR = '" + mv_par09 + "'"
			cQueryAux8 += " AND DXI.DXI_CODVAR = '" + mv_par09 + "'"
		Endif
	Else
		If  !Empty(mv_par08)
			cQueryAux1 += " AND DXI_CODVAR = '" + mv_par08 + "'"
			cQueryAux8 += " AND DXI.DXI_CODVAR = '" + mv_par08 + "'"
		Endif
	EndIf	
	
	If _lNovSafra
		If  !Empty(mv_par10)
			cQueryAux1 += " AND DXI_PRENSA = '" + mv_par10 + "'"
			cQueryAux8 += " AND DXI.DXI_PRENSA = '" + mv_par10 + "'"
		Endif
	Else
		If  !Empty(mv_par09)
			cQueryAux1 += " AND DXI_PRENSA = '" + mv_par09 + "'"
			cQueryAux8 += " AND DXI.DXI_PRENSA = '" + mv_par09 + "'"
		Endif
	EndIf	
	
	If _lNovSafra
		If mv_par13 == 1
			cQueryAux4 += " (SELECT COUNT(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI3 "
			cQueryAux4 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL3 ON  DXL3.DXL_FILIAL = DXI3.DXI_FILIAL "
			cQueryAux4 += "		AND DXL3.D_E_L_E_T_  =  ' ' "
			cQueryAux4 += "		AND DXL3.DXL_CODIGO = DXI3.DXI_FARDAO  "
			cQueryAux4 += "		AND DXL3.DXL_SAFRA 	= DXI3.DXI_SAFRA "
			cQueryAux4 += "		AND DXL3.DXL_PRDTOR = DXI3.DXI_PRDTOR "
			cQueryAux4 += "		AND DXL3.DXL_LJPRO  = DXI3.DXI_LJPRO "
			cQueryAux4 += "		AND DXL3.DXL_FAZ 	= DXI3.DXI_FAZ " 
			cQueryAux4 += " WHERE DXI3.D_E_L_E_T_  =  ' ' "
			cQueryAux4 += " AND DXI3.DXI_FILIAL  = '" + xFilial("DXI")+ "'"
			cQueryAux4 += " AND DXI3.DXI_SAFRA   = '" + mv_par01 + "'"
			cQueryAux4 += " AND DXI3.DXI_PRDTOR  = DXI.DXI_PRDTOR "
			If !Empty(mv_par02)
				cQueryAux4 += " AND DXI3.DXI_CODPRO   = '" + mv_par02 + "'"
			EndIf
			cQueryAux4 += " AND DXI3.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux4 += " AND DXL3.DXL_DTBEN BETWEEN'"+ DTOS(mv_par11) + "' AND '"+ DTOS(mv_par12) + "'"
	
			cQueryAux7 += " (SELECT SUM(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI6 "
			cQueryAux7 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL6 ON  DXL6.DXL_FILIAL = '" + xFilial("DXL")+ "'"
			cQueryAux7 += "		AND DXL6.D_E_L_E_T_  =  ' ' "
			cQueryAux7 += "		AND DXL6.DXL_CODIGO = DXI6.DXI_FARDAO  "
			cQueryAux7 += "		AND DXL6.DXL_SAFRA 	= DXI6.DXI_SAFRA "
			cQueryAux7 += "		AND DXL6.DXL_PRDTOR = DXI6.DXI_PRDTOR "
			cQueryAux7 += "		AND DXL6.DXL_LJPRO  = DXI6.DXI_LJPRO "		 
			cQueryAux7 += "		AND DXL6.DXL_FAZ 	= DXI6.DXI_FAZ " 
			cQueryAux7 += " WHERE DXI6.D_E_L_E_T_ = ' ' "
			cQueryAux7 += " AND DXI6.DXI_FILIAL  = '" + xFilial("DXI")+ "'"
			cQueryAux7 += " AND DXI6.DXI_SAFRA   = '" + mv_par01 + "'"
			cQueryAux7 += " AND DXI6.DXI_PRDTOR  = DXI.DXI_PRDTOR "
			If !Empty(mv_par02)
				cQueryAux7 += " AND DXI6.DXI_CODPRO   = '" + mv_par02 + "'"
			EndIf
			cQueryAux7 += " AND DXI6.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux7 += " AND DXL6.DXL_DTBEN BETWEEN '" + DTOS(mv_par11) + "' AND '" + DTOS(mv_par12) + "'"
			If !Empty(mv_par08)
				cQueryAux7 += " AND DXL6.DXL_TALHAO = '" + mv_par08 + "'"
			EndIf 
	
			//Filtro de unidade de beneficiamento
			If !Empty(mv_par14)
				cQueryAux4 += " AND DXI3.DXI_CODUNB = '"+mv_par14+"'"
				cQueryAux7 += " AND DXI6.DXI_CODUNB = '"+mv_par14+"'"	 
			EndIf
	
			If !Empty(mv_par07)
				cQueryAux4 += " AND DXI3.DXI_FAZ = '" + mv_par07 + "'"
				cQueryAux7 += " AND DXI6.DXI_FAZ = '" + mv_par07 + "'"
			Endif
	
			If  !Empty(mv_par09)
				cQueryAux4 += " AND DXI3.DXI_CODVAR = '" + mv_par09 + "'"
				cQueryAux7 += " AND DXI6.DXI_CODVAR = '" + mv_par09 + "'"
			Endif
	
			If  !Empty(mv_par10)
				cQueryAux4 += " AND DXI3.DXI_PRENSA = '" + mv_par10 + "'"
				cQueryAux7 += " AND DXI6.DXI_PRENSA = '" + mv_par10 + "'"
			Endif
	
			cQueryAux4 +=	"  AND DXI3.DXI_ROMSAI  = ' ') AS QTSALDO "
			cQueryAux7 += " AND DXI6.DXI_ROMSAI  = ' ') AS VLSALDO "
	
			cQueryAux1 += " AND DXI_ROMSAI = ' '"
			cQueryAux8 += " AND DXI.DXI_ROMSAI = ' '"
	
			cQueryAux1 := "%"+cQueryAux1+"%"
			cQueryAux2 := "%"+cQueryAux2+cQueryAux3+","+cQueryAux4+"%"
			cQueryAux5 := "%"+cQueryAux5+", 0 AS QTSAIDA "+ cQueryAux6+","+cQueryAux7+"%"
			cQueryAux8 := "%"+cQueryAux8+"%"
	
		Elseif mv_par13 == 2
			cQueryAux3 += ", (SELECT COUNT(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) + " DXI2 "
			cQueryAux3 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL2 ON  DXL2.DXL_FILIAL ='" + xFilial("DXL")+ "'"
			cQueryAux3 += "		AND DXL2.D_E_L_E_T_  =  ' ' "
			cQueryAux3 += "		AND DXL2.DXL_CODIGO = DXI2.DXI_FARDAO  "
			cQueryAux3 += "		AND DXL2.DXL_SAFRA 	= DXI2.DXI_SAFRA "
			cQueryAux3 += "		AND DXL2.DXL_PRDTOR = DXI2.DXI_PRDTOR "
			cQueryAux3 += "		AND DXL2.DXL_LJPRO  = DXI2.DXI_LJPRO "  
			cQueryAux3 += "		AND DXL2.DXL_FAZ 	= DXI2.DXI_FAZ " 
			cQueryAux3 += " WHERE DXI2.D_E_L_E_T_ = ' ' "
			cQueryAux3 += " AND DXI2.DXI_FILIAL  = '" + xFilial("DXI")+ "'"
			cQueryAux3 += " AND DXI2.DXI_SAFRA   = '" + mv_par01 + "'"
			cQueryAux3 += " AND DXI2.DXI_PRDTOR  = DXI.DXI_PRDTOR "
			If !Empty(mv_par02)
				cQueryAux3 += " AND DXI2.DXI_CODPRO   = '" + mv_par02 + "'"
			EndIf
			cQueryAux3 += " AND DXI2.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux3 += " AND DXL2.DXL_DTBEN BETWEEN '" + DTOS(mv_par11) + "' AND '" + DTOS(mv_par12) + "'"
	
	
			cQueryAux6 += ", (SELECT SUM(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) + " DXI5 "
			cQueryAux6 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL5 ON  DXL5.DXL_FILIAL ='" + xFilial("DXL")+ "'"
			cQueryAux6 += "		AND DXL5.D_E_L_E_T_  =  ' ' "
			cQueryAux6 += "		AND DXL5.DXL_CODIGO = DXI5.DXI_FARDAO  "
			cQueryAux6 += "		AND DXL5.DXL_SAFRA 	= DXI5.DXI_SAFRA "
			cQueryAux6 += "		AND DXL5.DXL_PRDTOR = DXI5.DXI_PRDTOR "
			cQueryAux6 += "		AND DXL5.DXL_LJPRO  = DXI5.DXI_LJPRO "  
			cQueryAux6 += "		AND DXL5.DXL_FAZ 	= DXI5.DXI_FAZ " 
			cQueryAux6 += " WHERE DXI5.D_E_L_E_T_ = ' ' "
			cQueryAux6 += " AND DXI5.DXI_FILIAL  = '" + xFilial("DXI")+ "'"
			cQueryAux6 += " AND DXI5.DXI_SAFRA   = '" + mv_par01 + "'"
			cQueryAux6 += " AND DXI5.DXI_PRDTOR  = DXI.DXI_PRDTOR "
			If !Empty(mv_par02)
				cQueryAux6 += " AND DXI5.DXI_CODPRO   = '" + mv_par02 + "'"
			EndIf
			cQueryAux6 += " AND DXI5.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux6 += " AND DXL5.DXL_DTBEN BETWEEN '" + DTOS(mv_par11) + "' AND '" + DTOS(mv_par12) + "'"
	
			If !Empty(mv_par08)
				cQueryAux6 += " AND DXL5.DXL_TALHAO = '" + mv_par08 + "'"
			EndIf 
	
	
			If !Empty(mv_par14)
				cQueryAux3 += " AND DXI2.DXI_CODUNB = '"+mv_par14+"'"
				cQueryAux6 += " AND DXI5.DXI_CODUNB = '"+mv_par14+"'"	
			EndIf
	
			If !Empty(mv_par07)
				cQueryAux3 += " AND DXI2.DXI_FAZ = '" + mv_par07 + "'"
				cQueryAux6 += " AND DXI5.DXI_FAZ = '" + mv_par07 + "'"
			Endif
	
			If  !Empty(mv_par09)
				cQueryAux3 += " AND DXI2.DXI_CODVAR = '" + mv_par09 + "'"
				cQueryAux6 += " AND DXI5.DXI_CODVAR = '" + mv_par09 + "'"
			Endif
	
			If  !Empty(mv_par10)
				cQueryAux3 += " AND DXI2.DXI_PRENSA = '" + mv_par10 + "'"
				cQueryAux6 += " AND DXI5.DXI_PRENSA = '" + mv_par10 + "'"
			Endif
	
			cQueryAux3 += " AND DXI2.DXI_ROMSAI <> ' ') AS QTSAIDA "
			cQueryAux6 += " AND DXI5.DXI_ROMSAI <> ' ') AS VLSAIDA "
	
			cQueryAux1 += " AND DXI_ROMSAI <> ' '"
			cQueryAux8 += " AND DXI.DXI_ROMSAI <> ' '"
	
			cQueryAux1 := "%"+cQueryAux1+"%"
			cQueryAux2 := "%"+cQueryAux2+cQueryAux3+cQueryAux4+"%"
			cQueryAux5 := "%"+cQueryAux5+", 0 AS QTSALDO "+cQueryAux6+cQueryAux7+"%"
	
			cQueryAux8 := "%"+cQueryAux8+"%"
		Else
	
			cQueryAux4 += " (SELECT COUNT(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI3 "
			cQueryAux4 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL3 ON  DXL3.DXL_FILIAL = '" + xFilial("DXL")+ "'"
			cQueryAux4 += "		AND DXL3.D_E_L_E_T_  =  ' ' "
			cQueryAux4 += "		AND DXL3.DXL_CODIGO = DXI3.DXI_FARDAO  "
			cQueryAux4 += "		AND DXL3.DXL_SAFRA 	= DXI3.DXI_SAFRA "
			cQueryAux4 += "		AND DXL3.DXL_PRDTOR = DXI3.DXI_PRDTOR "
			cQueryAux4 += "		AND DXL3.DXL_LJPRO  = DXI3.DXI_LJPRO "  
			cQueryAux4 += "		AND DXL3.DXL_FAZ 	= DXI3.DXI_FAZ " 
			cQueryAux4 += " WHERE DXI3.D_E_L_E_T_ = ' ' "
			cQueryAux4 += " AND DXI3.DXI_FILIAL = '" + xFilial("DXI")+ "'"
			cQueryAux4 += " AND DXI3.DXI_SAFRA = '" + mv_par01 + "'"
			cQueryAux4 += " AND DXI3.DXI_PRDTOR  = DXI.DXI_PRDTOR "
			If !Empty(mv_par02)
				cQueryAux4 += " AND DXI3.DXI_CODPRO = '" + mv_par02 + "'"
			EndIf
			cQueryAux4 += " AND DXI3.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux4 += " AND DXL3.DXL_DTBEN BETWEEN '"+ DTOS(mv_par11) + "' AND '"+ DTOS(mv_par12) + "'"
	
			cQueryAux7 += " (SELECT SUM(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI6 "
			cQueryAux7 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL6 ON  DXL6.DXL_FILIAL = '" + xFilial("DXL")+ "'"
			cQueryAux7 += "		AND DXL6.D_E_L_E_T_  =  ' ' "
			cQueryAux7 += "		AND DXL6.DXL_CODIGO = DXI6.DXI_FARDAO  "
			cQueryAux7 += "		AND DXL6.DXL_SAFRA 	= DXI6.DXI_SAFRA "
			cQueryAux7 += "		AND DXL6.DXL_PRDTOR = DXI6.DXI_PRDTOR "
			cQueryAux7 += "		AND DXL6.DXL_LJPRO  = DXI6.DXI_LJPRO "  
			cQueryAux7 += "		AND DXL6.DXL_FAZ 	= DXI6.DXI_FAZ " 
			cQueryAux7 += " WHERE DXI6.D_E_L_E_T_ = ' ' "
			cQueryAux7 += " AND DXI6.DXI_FILIAL  = '" + xFilial("DXI")+ "'"
			cQueryAux7 += " AND DXI6.DXI_SAFRA   = '" + mv_par01 + "'"
			cQueryAux7 += " AND DXI6.DXI_PRDTOR  = DXI.DXI_PRDTOR "
			If !Empty(mv_par02)
				cQueryAux7 += " AND DXI6.DXI_CODPRO   = '" + mv_par02 + "'"
			EndIf
			cQueryAux7 += " AND DXI6.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux7 += " AND DXL6.DXL_DTBEN BETWEEN '" + DTOS(mv_par11) + "' AND '" + DTOS(mv_par12) + "'"
	
			If !Empty(mv_par08)
				cQueryAux7 += " AND DXL6.DXL_TALHAO = '" + mv_par08 + "'"
			EndIf
	
			If !Empty(mv_par14)
				cQueryAux4 += " AND DXI3.DXI_CODUNB = '"+mv_par14+"'"
				cQueryAux7 += " AND DXI6.DXI_CODUNB = '"+mv_par14+"'"	 
			EndIf
	
			If !Empty(mv_par07)
				cQueryAux4 += " AND DXI3.DXI_FAZ = '" + mv_par07 + "'"
				cQueryAux7 += " AND DXI6.DXI_FAZ = '" + mv_par07 + "'"
			Endif
	
			If  !Empty(mv_par09)
				cQueryAux4 += " AND DXI3.DXI_CODVAR = '" + mv_par09 + "'"
				cQueryAux7 += " AND DXI6.DXI_CODVAR = '" + mv_par09 + "'"
			Endif
	
			If  !Empty(mv_par10)
				cQueryAux4 += " AND DXI3.DXI_PRENSA = '" + mv_par10 + "'"
				cQueryAux7 += " AND DXI6.DXI_PRENSA = '" + mv_par10 + "'"
			Endif
	
	
			cQueryAux4 +=	" and DXI3.DXI_ROMSAI=' ' ) AS QTSALDO, COUNT(DXI.DXI_FARDAO) - ";
			+ cQueryAux4 + " and DXI3.DXI_ROMSAI=' ' ) AS QTSAIDA "
	
	
			cQueryAux7 += " and DXI6.DXI_ROMSAI=' ' ) AS VLSALDO, SUM(DXI.DXI_PSLIQU) - " ;
			+ cQueryAux7 + " and DXI6.DXI_ROMSAI=' ' ) AS VLSAIDA "
	
			cQueryAux1 := "%"+cQueryAux1+"%"
			cQueryAux2 := "%"+cQueryAux2+cQueryAux3+","+cQueryAux4+"%"
			cQueryAux5 := "%"+cQueryAux5+cQueryAux6+","+cQueryAux7+"%"
			cQueryAux8 := "%"+cQueryAux8+"%"
		Endif
	Else
		If mv_par12 == 1
			cQueryAux4 += " (SELECT COUNT(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI3 "
			cQueryAux4 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL3 ON  DXL3.DXL_FILIAL = DXI3.DXI_FILIAL "
			cQueryAux4 += "		AND DXL3.D_E_L_E_T_  =  ' ' "
			cQueryAux4 += "		AND DXL3.DXL_CODIGO = DXI3.DXI_FARDAO  "
			cQueryAux4 += "		AND DXL3.DXL_SAFRA 	= DXI3.DXI_SAFRA "
			cQueryAux4 += "		AND DXL3.DXL_PRDTOR = DXI3.DXI_PRDTOR "
			cQueryAux4 += "		AND DXL3.DXL_LJPRO  = DXI3.DXI_LJPRO "
			cQueryAux4 += "		AND DXL3.DXL_FAZ 	= DXI3.DXI_FAZ " 
			cQueryAux4 += " WHERE DXI3.D_E_L_E_T_  =  ' ' "
			cQueryAux4 += " AND DXI3.DXI_FILIAL  = '" + xFilial("DXI")+ "'"
			cQueryAux4 += " AND DXI3.DXI_SAFRA   = '" + mv_par01 + "'"
			cQueryAux4 += " AND DXI3.DXI_PRDTOR  = DXI.DXI_PRDTOR "
			cQueryAux4 += " AND DXI3.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux4 += " AND DXL3.DXL_DTBEN BETWEEN'"+ DTOS(mv_par10) + "' AND '"+ DTOS(mv_par11) + "'"
	
			cQueryAux7 += " (SELECT SUM(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI6 "
			cQueryAux7 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL6 ON  DXL6.DXL_FILIAL = '" + xFilial("DXL")+ "'"
			cQueryAux7 += "		AND DXL6.D_E_L_E_T_  =  ' ' "
			cQueryAux7 += "		AND DXL6.DXL_CODIGO = DXI6.DXI_FARDAO  "
			cQueryAux7 += "		AND DXL6.DXL_SAFRA 	= DXI6.DXI_SAFRA "
			cQueryAux7 += "		AND DXL6.DXL_PRDTOR = DXI6.DXI_PRDTOR "
			cQueryAux7 += "		AND DXL6.DXL_LJPRO  = DXI6.DXI_LJPRO "		 
			cQueryAux7 += "		AND DXL6.DXL_FAZ 	= DXI6.DXI_FAZ " 
			cQueryAux7 += " WHERE DXI6.D_E_L_E_T_ = ' ' "
			cQueryAux7 += " AND DXI6.DXI_FILIAL  = '" + xFilial("DXI")+ "'"
			cQueryAux7 += " AND DXI6.DXI_SAFRA   = '" + mv_par01 + "'"
			cQueryAux7 += " AND DXI6.DXI_PRDTOR  = DXI.DXI_PRDTOR "
			cQueryAux7 += " AND DXI6.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux7 += " AND DXL6.DXL_DTBEN BETWEEN '" + DTOS(mv_par10) + "' AND '" + DTOS(mv_par11) + "'"
			If !Empty(mv_par08)
				cQueryAux7 += " AND DXL6.DXL_TALHAO = '" + mv_par07 + "'"
			EndIf 
	
			//Filtro de unidade de beneficiamento
			If !Empty(mv_par13)
				cQueryAux4 += " AND DXI3.DXI_CODUNB = '"+mv_par13+"'"
				cQueryAux7 += " AND DXI6.DXI_CODUNB = '"+mv_par13+"'"	 
			EndIf
	
			If !Empty(mv_par06)
				cQueryAux4 += " AND DXI3.DXI_FAZ = '" + mv_par06 + "'"
				cQueryAux7 += " AND DXI6.DXI_FAZ = '" + mv_par06 + "'"
			Endif
	
			If  !Empty(mv_par08)
				cQueryAux4 += " AND DXI3.DXI_CODVAR = '" + mv_par08 + "'"
				cQueryAux7 += " AND DXI6.DXI_CODVAR = '" + mv_par08 + "'"
			Endif
	
			If  !Empty(mv_par09)
				cQueryAux4 += " AND DXI3.DXI_PRENSA = '" + mv_par09 + "'"
				cQueryAux7 += " AND DXI6.DXI_PRENSA = '" + mv_par09 + "'"
			Endif
	
			cQueryAux4 +=	"  AND DXI3.DXI_ROMSAI  = ' ') AS QTSALDO "
			cQueryAux7 += " AND DXI6.DXI_ROMSAI  = ' ') AS VLSALDO "
	
			cQueryAux1 += " AND DXI_ROMSAI = ' '"
			cQueryAux8 += " AND DXI.DXI_ROMSAI = ' '"
	
			cQueryAux1 := "%"+cQueryAux1+"%"
			cQueryAux2 := "%"+cQueryAux2+cQueryAux3+","+cQueryAux4+"%"
			cQueryAux5 := "%"+cQueryAux5+", 0 AS QTSAIDA "+ cQueryAux6+","+cQueryAux7+"%"
			cQueryAux8 := "%"+cQueryAux8+"%"
	
		Elseif mv_par12 == 2
			cQueryAux3 += ", (SELECT COUNT(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) + " DXI2 "
			cQueryAux3 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL2 ON  DXL2.DXL_FILIAL ='" + xFilial("DXL")+ "'"
			cQueryAux3 += "		AND DXL2.D_E_L_E_T_  =  ' ' "
			cQueryAux3 += "		AND DXL2.DXL_CODIGO = DXI2.DXI_FARDAO  "
			cQueryAux3 += "		AND DXL2.DXL_SAFRA 	= DXI2.DXI_SAFRA "
			cQueryAux3 += "		AND DXL2.DXL_PRDTOR = DXI2.DXI_PRDTOR "
			cQueryAux3 += "		AND DXL2.DXL_LJPRO  = DXI2.DXI_LJPRO "  
			cQueryAux3 += "		AND DXL2.DXL_FAZ 	= DXI2.DXI_FAZ " 
			cQueryAux3 += " WHERE DXI2.D_E_L_E_T_ = ' ' "
			cQueryAux3 += " AND DXI2.DXI_FILIAL  = '" + xFilial("DXI")+ "'"
			cQueryAux3 += " AND DXI2.DXI_SAFRA   = '" + mv_par01 + "'"
			cQueryAux3 += " AND DXI2.DXI_PRDTOR  = DXI.DXI_PRDTOR "
			cQueryAux3 += " AND DXI2.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux3 += " AND DXL2.DXL_DTBEN BETWEEN '" + DTOS(mv_par10) + "' AND '" + DTOS(mv_par11) + "'"
	
			cQueryAux6 += ", (SELECT SUM(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) + " DXI5 "
			cQueryAux6 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL5 ON  DXL5.DXL_FILIAL ='" + xFilial("DXL")+ "'"
			cQueryAux6 += "		AND DXL5.D_E_L_E_T_  =  ' ' "
			cQueryAux6 += "		AND DXL5.DXL_CODIGO = DXI5.DXI_FARDAO  "
			cQueryAux6 += "		AND DXL5.DXL_SAFRA 	= DXI5.DXI_SAFRA "
			cQueryAux6 += "		AND DXL5.DXL_PRDTOR = DXI5.DXI_PRDTOR "
			cQueryAux6 += "		AND DXL5.DXL_LJPRO  = DXI5.DXI_LJPRO "  
			cQueryAux6 += "		AND DXL5.DXL_FAZ 	= DXI5.DXI_FAZ " 
			cQueryAux6 += " WHERE DXI5.D_E_L_E_T_ = ' ' "
			cQueryAux6 += " AND DXI5.DXI_FILIAL  = '" + xFilial("DXI")+ "'"
			cQueryAux6 += " AND DXI5.DXI_SAFRA   = '" + mv_par01 + "'"
			cQueryAux6 += " AND DXI5.DXI_PRDTOR  = DXI.DXI_PRDTOR "
			cQueryAux6 += " AND DXI5.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux6 += " AND DXL5.DXL_DTBEN BETWEEN '" + DTOS(mv_par10) + "' AND '" + DTOS(mv_par11) + "'"
	
			If !Empty(mv_par07)
				cQueryAux6 += " AND DXL5.DXL_TALHAO = '" + mv_par07 + "'"
			EndIf 
	
	
			If !Empty(mv_par13)
				cQueryAux3 += " AND DXI2.DXI_CODUNB = '"+mv_par13+"'"
				cQueryAux6 += " AND DXI5.DXI_CODUNB = '"+mv_par13+"'"	
			EndIf
	
			If !Empty(mv_par06)
				cQueryAux3 += " AND DXI2.DXI_FAZ = '" + mv_par06 + "'"
				cQueryAux6 += " AND DXI5.DXI_FAZ = '" + mv_par06 + "'"
			Endif
	
			If  !Empty(mv_par08)
				cQueryAux3 += " AND DXI2.DXI_CODVAR = '" + mv_par08 + "'"
				cQueryAux6 += " AND DXI5.DXI_CODVAR = '" + mv_par08 + "'"
			Endif
	
			If  !Empty(mv_par09)
				cQueryAux3 += " AND DXI2.DXI_PRENSA = '" + mv_par09 + "'"
				cQueryAux6 += " AND DXI5.DXI_PRENSA = '" + mv_par09 + "'"
			Endif
	
			cQueryAux3 += " AND DXI2.DXI_ROMSAI <> ' ') AS QTSAIDA "
			cQueryAux6 += " AND DXI5.DXI_ROMSAI <> ' ') AS VLSAIDA "
	
			cQueryAux1 += " AND DXI_ROMSAI <> ' '"
			cQueryAux8 += " AND DXI.DXI_ROMSAI <> ' '"
	
			cQueryAux1 := "%"+cQueryAux1+"%"
			cQueryAux2 := "%"+cQueryAux2+cQueryAux3+cQueryAux4+"%"
			cQueryAux5 := "%"+cQueryAux5+", 0 AS QTSALDO "+cQueryAux6+cQueryAux7+"%"
	
			cQueryAux8 := "%"+cQueryAux8+"%"
		Else
	
			cQueryAux4 += " (SELECT COUNT(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI3 "
			cQueryAux4 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL3 ON  DXL3.DXL_FILIAL = '" + xFilial("DXL")+ "'"
			cQueryAux4 += "		AND DXL3.D_E_L_E_T_  =  ' ' "
			cQueryAux4 += "		AND DXL3.DXL_CODIGO = DXI3.DXI_FARDAO  "
			cQueryAux4 += "		AND DXL3.DXL_SAFRA 	= DXI3.DXI_SAFRA "
			cQueryAux4 += "		AND DXL3.DXL_PRDTOR = DXI3.DXI_PRDTOR "
			cQueryAux4 += "		AND DXL3.DXL_LJPRO  = DXI3.DXI_LJPRO "  
			cQueryAux4 += "		AND DXL3.DXL_FAZ 	= DXI3.DXI_FAZ " 
			cQueryAux4 += " WHERE DXI3.D_E_L_E_T_ = ' ' "
			cQueryAux4 += " AND DXI3.DXI_FILIAL = '" + xFilial("DXI")+ "'"
			cQueryAux4 += " AND DXI3.DXI_SAFRA = '" + mv_par01 + "'"
			cQueryAux4 += " AND DXI3.DXI_PRDTOR  = DXI.DXI_PRDTOR "
			cQueryAux4 += " AND DXI3.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux4 += " AND DXL3.DXL_DTBEN BETWEEN '"+ DTOS(mv_par10) + "' AND '"+ DTOS(mv_par11) + "'"
	
			cQueryAux7 += " (SELECT SUM(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI6 "
			cQueryAux7 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL6 ON  DXL6.DXL_FILIAL = '" + xFilial("DXL")+ "'"
			cQueryAux7 += "		AND DXL6.D_E_L_E_T_  =  ' ' "
			cQueryAux7 += "		AND DXL6.DXL_CODIGO = DXI6.DXI_FARDAO  "
			cQueryAux7 += "		AND DXL6.DXL_SAFRA 	= DXI6.DXI_SAFRA "
			cQueryAux7 += "		AND DXL6.DXL_PRDTOR = DXI6.DXI_PRDTOR "
			cQueryAux7 += "		AND DXL6.DXL_LJPRO  = DXI6.DXI_LJPRO "  
			cQueryAux7 += "		AND DXL6.DXL_FAZ 	= DXI6.DXI_FAZ " 
			cQueryAux7 += " WHERE DXI6.D_E_L_E_T_ = ' ' "
			cQueryAux7 += " AND DXI6.DXI_FILIAL  = '" + xFilial("DXI")+ "'"
			cQueryAux7 += " AND DXI6.DXI_SAFRA   = '" + mv_par01 + "'"
			cQueryAux7 += " AND DXI6.DXI_PRDTOR  = DXI.DXI_PRDTOR "
			cQueryAux7 += " AND DXI6.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux7 += " AND DXL6.DXL_DTBEN BETWEEN '" + DTOS(mv_par10) + "' AND '" + DTOS(mv_par11) + "'"
	
			If !Empty(mv_par07)
				cQueryAux7 += " AND DXL6.DXL_TALHAO = '" + mv_par07 + "'"
			EndIf
	
			If !Empty(mv_par13)
				cQueryAux4 += " AND DXI3.DXI_CODUNB = '"+mv_par13+"'"
				cQueryAux7 += " AND DXI6.DXI_CODUNB = '"+mv_par13+"'"	 
			EndIf
	
			If !Empty(mv_par06)
				cQueryAux4 += " AND DXI3.DXI_FAZ = '" + mv_par06 + "'"
				cQueryAux7 += " AND DXI6.DXI_FAZ = '" + mv_par06 + "'"
			Endif
	
			If  !Empty(mv_par08)
				cQueryAux4 += " AND DXI3.DXI_CODVAR = '" + mv_par08 + "'"
				cQueryAux7 += " AND DXI6.DXI_CODVAR = '" + mv_par08 + "'"
			Endif
	
			If  !Empty(mv_par09)
				cQueryAux4 += " AND DXI3.DXI_PRENSA = '" + mv_par09 + "'"
				cQueryAux7 += " AND DXI6.DXI_PRENSA = '" + mv_par09 + "'"
			Endif
	
	
			cQueryAux4 +=	" and DXI3.DXI_ROMSAI=' ' ) AS QTSALDO, COUNT(DXI.DXI_FARDAO) - ";
			+ cQueryAux4 + " and DXI3.DXI_ROMSAI=' ' ) AS QTSAIDA "
	
	
			cQueryAux7 += " and DXI6.DXI_ROMSAI=' ' ) AS VLSALDO, SUM(DXI.DXI_PSLIQU) - " ;
			+ cQueryAux7 + " and DXI6.DXI_ROMSAI=' ' ) AS VLSAIDA "
	
			cQueryAux1 := "%"+cQueryAux1+"%"
			cQueryAux2 := "%"+cQueryAux2+cQueryAux3+","+cQueryAux4+"%"
			cQueryAux5 := "%"+cQueryAux5+cQueryAux6+","+cQueryAux7+"%"
			cQueryAux8 := "%"+cQueryAux8+"%"
		Endif
	EndIf	
	/***********************************************/


	Begin Report Query oSec1
		cAlias := GetNextAlias()
		cSemClass := STR0038
		BeginSql Alias cAlias
		SELECT DXI.DXI_PRDTOR,DXI.DXI_LJPRO, DXI.DXI_CLACOM, NVL(LTrim(DXA.DXA_DESCRI),%exp:cSemClass%) AS DXA_DESCRI,
		(COUNT(DXI_PSLIQU) * 100 / (SELECT COUNT(DXI_PSLIQU) FROM %table:DXI% DXI1
		INNER JOIN %table:DXL% DXL1
		ON DXL1.DXL_FILIAL     = %xFilial:DXL%
		AND DXL1.D_E_L_E_T_    = ' '
		AND DXL1.DXL_CODIGO    = DXI1.DXI_FARDAO
		AND DXL1.DXL_SAFRA     = DXI1.DXI_SAFRA
		AND DXL1.DXL_PRDTOR    = DXI1.DXI_PRDTOR
		AND DXL1.DXL_LJPRO     = DXI1.DXI_LJPRO
		AND DXL1.DXL_FAZ       = DXI1.DXI_FAZ
		WHERE DXI1.DXI_PRDTOR  = DXI.DXI_PRDTOR
		%exp:cQueryAux1% )) AS PERC,
		COUNT(DXI.DXI_FARDAO) AS QTFARDOS
		%exp:cQueryAux2%,
		SUM(DXI.DXI_PSLIQU) AS VLFARDOS
		%exp:cQueryAux5%
		FROM %table:DXI% DXI 
		LEFT JOIN  %table:DXA% DXA on DXA.DXA_CODIGO  = DXI.DXI_CLACOM
		AND DXA.%notDel%
		INNER JOIN %table:DXL% DXL ON DXL.DXL_FILIAL = %xFilial:DXL%
		AND DXL.DXL_CODIGO = DXI.DXI_FARDAO 
		AND DXL.DXL_SAFRA = DXI.DXI_SAFRA 
		AND DXL.DXL_PRDTOR = DXI.DXI_PRDTOR
		AND DXL.DXL_LJPRO = DXI.DXI_LJPRO  
		AND DXL.DXL_FAZ = DXI.DXI_FAZ 
		AND DXL.%notDel% 
		%exp:cQueryAux8%

		GROUP BY DXI.DXI_PRDTOR, DXI.DXI_LJPRO, DXI.DXI_CLACOM, DXA.DXA_DESCRI
		ORDER BY DXI.DXI_PRDTOR, DXI.DXI_LJPRO, DXI.DXI_CLACOM, DXA.DXA_DESCRI

		EndSql

	End Report Query oSec1

	/**************************************************************/

	(cAlias)->(dbGoTop())
	If (cAlias)->(!Eof())
		oSec1:Init()
		oSec1:Print()
		oSec1:Finish()
	EndIf

	oSec1:Finish()
	(cAlias)->(dbCloseArea())


	/**************************************************************/
	//----------------------------
	// Query do relatorio secao 2
	//----------------------------

	// cQueryAux8 mantém os valores já registrados pra seção 1

	cQueryAux1  := ""
	cQueryAux2  := ""
	cQueryAux3  := ""
	cQueryAux4  := ""
	cQueryAux5  := ""
	cQueryAux6  := ""
	cQueryAux7  := ""
	cQueryAux9  := ""

	/*********** Tratamento das Perguntas **********/
	If _lNovSafra
		cQueryAux1 += " DXI7.DXI_FILIAL = '" + xFilial("DXI")+ "'"
		cQueryAux1 += " AND DXI7.DXI_SAFRA = '" + mv_par01 + "'"
		If !Empty(mv_par02)
			cQueryAux1 += " AND DXI7.DXI_CODPRO = '" + mv_par02 + "'"
		EndIf
		cQueryAux1 += " AND DXI7.DXI_CLACOM BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
		cQueryAux1 += " AND DXL7.DXL_DTBEN BETWEEN '" + DTOS(mv_par11) + "' AND '" + DTOS(mv_par12) + "'"
	
		If !Empty(mv_par08)
			cQueryAux1 += " AND DXL7.DXL_TALHAO = '" + mv_par08 + "'"
		EndIf
	Else
		cQueryAux1 += " DXI7.DXI_FILIAL = '" + xFilial("DXI")+ "'"
		cQueryAux1 += " AND DXI7.DXI_SAFRA = '" + mv_par01 + "'"
		cQueryAux1 += " AND DXI7.DXI_CLACOM BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "' "
		cQueryAux1 += " AND DXL7.DXL_DTBEN BETWEEN '" + DTOS(mv_par10) + "' AND '" + DTOS(mv_par11) + "'"
	
		If !Empty(mv_par07)
			cQueryAux1 += " AND DXL7.DXL_TALHAO = '" + mv_par07 + "'"
		EndIf
	EndIf	 

	cQueryAux9 += ", (SELECT COUNT(DISTINCT DXI_BLOCO) FROM " + RetSqlName( "DXI" ) + " DXI9 "
	cQueryAux9 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL9 ON  DXL9.DXL_FILIAL = '" + xFilial("DXL")+ "'"
	cQueryAux9 += "		AND DXL9.DXL_CODIGO = DXI9.DXI_FARDAO  "
	cQueryAux9 += "		AND DXL9.DXL_SAFRA 	= DXI9.DXI_SAFRA "
	cQueryAux9 += "		AND DXL9.DXL_PRDTOR = DXI9.DXI_PRDTOR "
	cQueryAux9 += "		AND DXL9.DXL_LJPRO  = DXI9.DXI_LJPRO " 
	cQueryAux9 += "		AND DXL9.DXL_FAZ 	= DXI9.DXI_FAZ " 
	cQueryAux9 += "		AND DXL9.D_E_L_E_T_  =  ' ' "	
	cQueryAux9 += " WHERE DXI9.D_E_L_E_T_ = ' ' "
	cQueryAux9 += " AND DXI9.DXI_FILIAL   = '" + xFilial("DXI")+ "'"
	cQueryAux9 += " AND DXI9.DXI_SAFRA    = '" + mv_par01 + "'"
	cQueryAux9 += " AND DXI9.DXI_CLACOM   = DXI.DXI_CLACOM "
	cQueryAux9 += " AND DXI9.DXI_BLOCO   <> '' "
	
	If _lNovSafra
		If !Empty(mv_par02)
			cQueryAux9 += " AND DXI9.DXI_CODPRO    = '" + mv_par02 + "'"
		EndIf
	
		//Filtro de unidade de beneficiamento
		If !Empty(mv_par14)
			cQueryAux1 += " AND DXI7.DXI_CODUNB = '"+mv_par14+"'"
			cQueryAux9 += " AND DXI9.DXI_CODUNB = '"+mv_par14+"'"	 
		EndIf	
	
		If  !Empty(mv_par07)
			cQueryAux1 += " AND DXI7.DXI_FAZ = '" + mv_par07 + "'"
		Endif
	
		If  !Empty(mv_par09)
			cQueryAux1 += " AND DXI7.DXI_CODVAR = '" + mv_par09 + "'"
			cQueryAux9 += " AND DXI9.DXI_CODVAR = '" + mv_par09 + "'"
		Endif
	
		If  !Empty(mv_par10)
			cQueryAux1 += " AND DXI7.DXI_PRENSA = '" + mv_par10 + "'"
			cQueryAux9 += " AND DXI9.DXI_PRENSA = '" + mv_par10 + "'"
		Endif
	
		cQueryAux9 += ") AS QTBLOCO "
	Else
		//Filtro de unidade de beneficiamento
		If !Empty(mv_par13)
			cQueryAux1 += " AND DXI7.DXI_CODUNB = '"+mv_par13+"'"
			cQueryAux9 += " AND DXI9.DXI_CODUNB = '"+mv_par13+"'"	 
		EndIf	
	
		If  !Empty(mv_par06)
			cQueryAux1 += " AND DXI7.DXI_FAZ = '" + mv_par06 + "'"
		Endif
	
		If  !Empty(mv_par08)
			cQueryAux1 += " AND DXI7.DXI_CODVAR = '" + mv_par08 + "'"
			cQueryAux9 += " AND DXI9.DXI_CODVAR = '" + mv_par08 + "'"
		Endif
	
		If  !Empty(mv_par09)
			cQueryAux1 += " AND DXI7.DXI_PRENSA = '" + mv_par09 + "'"
			cQueryAux9 += " AND DXI9.DXI_PRENSA = '" + mv_par09 + "'"
		Endif
	
		cQueryAux9 += ") AS QTBLOCO "
	EndIf
	
	If _lNovSafra	
		If mv_par13 == 1
			cQueryAux4 += " (SELECT COUNT(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI3 "
			cQueryAux4 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL3 ON  DXL3.DXL_FILIAL = '" + xFilial("DXL")+ "'"
			cQueryAux4 += "		AND DXL3.DXL_CODIGO = DXI3.DXI_FARDAO  "
			cQueryAux4 += "		AND DXL3.DXL_SAFRA 	= DXI3.DXI_SAFRA "
			cQueryAux4 += "		AND DXL3.DXL_PRDTOR = DXI3.DXI_PRDTOR "
			cQueryAux4 += "		AND DXL3.DXL_LJPRO  = DXI3.DXI_LJPRO " 
			cQueryAux4 += "		AND DXL3.DXL_FAZ 	= DXI3.DXI_FAZ " 
			cQueryAux4 += "		AND DXL3.D_E_L_E_T_  =  ' ' "		
			cQueryAux4 += " WHERE DXI3.D_E_L_E_T_ = '' "
			cQueryAux4 += " AND DXI3.DXI_FILIAL = '" + xFilial("DXI")+ "'"
			cQueryAux4 += " AND DXI3.DXI_SAFRA = '" + mv_par01 + "'"
			If !Empty(mv_par02)
				cQueryAux4 += " AND DXI3.DXI_CODPRO = '" + mv_par02 + "'"
			EndIf
			cQueryAux4 += " AND DXI3.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux4 += " AND DXL3.DXL_DTBEN BETWEEN '"+ DTOS(mv_par11) + "' AND '"+ DTOS(mv_par12) + "'"
			
			cQueryAux7 += " (SELECT SUM(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI6 "
			cQueryAux7 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL6 ON  DXL6.DXL_FILIAL = '" + xFilial("DXL")+ "'"
			cQueryAux7 += "		AND DXL6.D_E_L_E_T_  =  ' ' "
			cQueryAux7 += "		AND DXL6.DXL_CODIGO = DXI6.DXI_FARDAO  "
			cQueryAux7 += "		AND DXL6.DXL_SAFRA 	= DXI6.DXI_SAFRA "
			cQueryAux7 += "		AND DXL6.DXL_PRDTOR = DXI6.DXI_PRDTOR "
			cQueryAux7 += "		AND DXL6.DXL_LJPRO  = DXI6.DXI_LJPRO "  
			cQueryAux7 += "		AND DXL6.DXL_FAZ 	= DXI6.DXI_FAZ " 
			cQueryAux7 += " WHERE DXI6.D_E_L_E_T_ = '' "
			cQueryAux7 += " AND DXI6.DXI_FILIAL = '" + xFilial("DXI")+ "'"
			cQueryAux7 += " AND DXI6.DXI_SAFRA = '" + mv_par01 + "'"
			If !Empty(mv_par02)
				cQueryAux7 += " AND DXI6.DXI_CODPRO = '" + mv_par02 + "'"
			EndIf
			cQueryAux7 += " AND DXI6.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux7 += " AND DXL6.DXL_DTBEN BETWEEN '" + DTOS(mv_par11) + "' AND '" + DTOS(mv_par12) + "'"
			
			If !Empty(mv_par08)
				cQueryAux7 += " AND DXL6.DXL_TALHAO = '" + mv_par08 + "'"
			EndIf 		
			
			
			//Filtro de unidade de beneficiamento
			If !Empty(mv_par14)
				cQueryAux4 += " AND DXI3.DXI_CODUNB = '"+mv_par14+"'"
				cQueryAux7 += " AND DXI6.DXI_CODUNB = '"+mv_par14+"'"	 
			EndIf	
	
			If !Empty(mv_par07)
				cQueryAux4 += " AND DXI3.DXI_FAZ = '" + mv_par07 + "'"
				cQueryAux7 += " AND DXI6.DXI_FAZ = '" + mv_par07 + "'"
			Endif
	
			If  !Empty(mv_par09)
				cQueryAux4 += " AND DXI3.DXI_CODVAR = '" + mv_par09 + "'"
				cQueryAux7 += " AND DXI6.DXI_CODVAR = '" + mv_par09 + "'"
			Endif
	
			If  !Empty(mv_par10)
				cQueryAux4 += " AND DXI3.DXI_PRENSA = '" + mv_par10 + "'"
				cQueryAux7 += " AND DXI6.DXI_PRENSA = '" + mv_par10 + "'"
			Endif
	
			cQueryAux4 +=	"  AND DXI3.DXI_ROMSAI  = ' ') AS QTSALDO "
			cQueryAux7 += " AND DXI6.DXI_ROMSAI  = ' ') AS VLSALDO "
	
			cQueryAux7 += " , 0 AS QTSAIDA "
	
			cQueryAux1 += " AND DXI_ROMSAI = ' '"
	
		ElseIf mv_par13 == 2
			cQueryAux4 += " (SELECT COUNT(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI3 "
			cQueryAux4 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL3 ON  DXL3.DXL_FILIAL = '" + xFilial("DXL")+ "'"
			cQueryAux4 += "		AND DXL3.D_E_L_E_T_  =  ' ' "
			cQueryAux4 += "		AND DXL3.DXL_CODIGO = DXI3.DXI_FARDAO  "
			cQueryAux4 += "		AND DXL3.DXL_SAFRA 	= DXI3.DXI_SAFRA "
			cQueryAux4 += "		AND DXL3.DXL_PRDTOR = DXI3.DXI_PRDTOR "
			cQueryAux4 += "		AND DXL3.DXL_LJPRO  = DXI3.DXI_LJPRO "  
			cQueryAux4 += "		AND DXL3.DXL_FAZ 	= DXI3.DXI_FAZ " 
			cQueryAux4 += " WHERE DXI3.D_E_L_E_T_ = '' "
			cQueryAux4 += " AND DXI3.DXI_FILIAL = '" + xFilial("DXI")+ "'"
			cQueryAux4 += " AND DXI3.DXI_SAFRA = '" + mv_par01 + "'"
			If !Empty(mv_par02)
				cQueryAux4 += " AND DXI3.DXI_CODPRO = '" + mv_par02 + "'"
			EndIf
			cQueryAux4 += " AND DXI3.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux4 += " AND DXL3.DXL_DTBEN BETWEEN '"+ DTOS(mv_par11) + "' AND '"+ DTOS(mv_par12) + "'"
			
			cQueryAux7 += " (SELECT SUM(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI6 "
			cQueryAux7 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL6 ON  DXL6.DXL_FILIAL = '" + xFilial("DXL")+ "'"
			cQueryAux7 += "		AND DXL6.D_E_L_E_T_  =  ' ' "
			cQueryAux7 += "		AND DXL6.DXL_CODIGO = DXI6.DXI_FARDAO  "
			cQueryAux7 += "		AND DXL6.DXL_SAFRA 	= DXI6.DXI_SAFRA "
			cQueryAux7 += "		AND DXL6.DXL_PRDTOR = DXI6.DXI_PRDTOR "
			cQueryAux7 += "		AND DXL6.DXL_LJPRO  = DXI6.DXI_LJPRO "  
			cQueryAux7 += "		AND DXL6.DXL_FAZ 	= DXI6.DXI_FAZ " 
			cQueryAux7 += " WHERE DXI6.D_E_L_E_T_ = '' "
			cQueryAux7 += " AND DXI6.DXI_FILIAL  = '" + xFilial("DXI")+ "'"
			cQueryAux7 += " AND DXI6.DXI_SAFRA   = '" + mv_par01 + "'"
			If !Empty(mv_par02)
				cQueryAux7 += " AND DXI6.DXI_CODPRO   = '" + mv_par02 + "'"
			EndIf
			cQueryAux7 += " AND DXI6.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux7 += " AND DXL6.DXL_DTBEN BETWEEN '" + DTOS(mv_par11) + "' AND '" + DTOS(mv_par12) + "'"
			
			If !Empty(mv_par08)
				cQueryAux7 += " AND DXL6.DXL_TALHAO = '" + mv_par08 + "'"
			EndIf
			
			
			//Filtro de unidade de beneficiamento
			If !empty(mv_par14)
				cQueryAux4 += " AND DXI3.DXI_CODUNB = '"+mv_par14+"'"
				cQueryAux7 += " AND DXI6.DXI_CODUNB = '"+mv_par14+"'"	 
			EndIf
	
			If !Empty(mv_par07)
				cQueryAux4 += " AND DXI3.DXI_FAZ = '" + mv_par07 + "'"
				cQueryAux7 += " AND DXI6.DXI_FAZ = '" + mv_par07 + "'"
			Endif
	
			If  !Empty(mv_par09)
				cQueryAux4 += " AND DXI3.DXI_CODVAR = '" + mv_par09 + "'"
				cQueryAux7 += " AND DXI6.DXI_CODVAR = '" + mv_par09 + "'"
			Endif
	
			If  !Empty(mv_par10)
				cQueryAux4 += " AND DXI3.DXI_PRENSA = '" + mv_par10 + "'"
				cQueryAux7 += " AND DXI6.DXI_PRENSA = '" + mv_par10 + "'"
			Endif
	
			cQueryAux4 +=	"  AND DXI3.DXI_ROMSAI  <> ' ') AS QTSAIDA "
			cQueryAux7 += " AND DXI6.DXI_ROMSAI  <> ' ') AS VLSAIDA "
			cQueryAux7 +=	",  0 AS QTSALDO "
	
			cQueryAux1 += " AND DXI_ROMSAI <> ' '"
	
		Else
			cQueryAux4 += " (SELECT COUNT(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI3 "
			cQueryAux4 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL3 ON  DXL3.DXL_FILIAL = '" + xFilial("DXL")+ "'"
			cQueryAux4 += "		AND DXL3.D_E_L_E_T_  =  ' ' "
			cQueryAux4 += "		AND DXL3.DXL_CODIGO = DXI3.DXI_FARDAO  "
			cQueryAux4 += "		AND DXL3.DXL_SAFRA 	= DXI3.DXI_SAFRA "
			cQueryAux4 += "		AND DXL3.DXL_PRDTOR = DXI3.DXI_PRDTOR "
			cQueryAux4 += "		AND DXL3.DXL_LJPRO  = DXI3.DXI_LJPRO "  
			cQueryAux4 += "		AND DXL3.DXL_FAZ 	= DXI3.DXI_FAZ " 
			cQueryAux4 += " WHERE DXI3.D_E_L_E_T_ = '' "
			cQueryAux4 += " AND DXI3.DXI_FILIAL = '" + xFilial("DXI")+ "'"
			cQueryAux4 += " AND DXI3.DXI_SAFRA = '" + mv_par01 + "'"
			If !Empty(mv_par02)
				cQueryAux4 += " AND DXI3.DXI_CODPRO = '" + mv_par02 + "'"
			EndIf
			
			cQueryAux4 += " AND DXI3.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux4 += " AND DXL3.DXL_DTBEN BETWEEN '"+ DTOS(mv_par11) + "' AND '"+ DTOS(mv_par12) + "'"
				
			cQueryAux7 += " (SELECT SUM(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI6 "
			cQueryAux7 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL6 ON  DXL6.DXL_FILIAL = DXI6.DXI_FILIAL "
			cQueryAux7 += "		AND DXL6.D_E_L_E_T_  =  ' ' "
			cQueryAux7 += "		AND DXL6.DXL_CODIGO = DXI6.DXI_FARDAO  "
			cQueryAux7 += "		AND DXL6.DXL_SAFRA 	= DXI6.DXI_SAFRA "
			cQueryAux7 += "		AND DXL6.DXL_PRDTOR = DXI6.DXI_PRDTOR "
			cQueryAux7 += "		AND DXL6.DXL_LJPRO  = DXI6.DXI_LJPRO "  
			cQueryAux7 += "		AND DXL6.DXL_FAZ 	= DXI6.DXI_FAZ " 
			cQueryAux7 += " WHERE DXI6.D_E_L_E_T_ = ' ' "
			cQueryAux7 += " AND DXI6.DXI_FILIAL  = '" + xFilial("DXI")+ "'"
			cQueryAux7 += " AND DXI6.DXI_SAFRA   = '" + mv_par01 + "'"
			
			If !Empty(mv_par02)
				cQueryAux7 += " AND DXI6.DXI_CODPRO   = '" + mv_par02 + "'"
			EndIf
			
			cQueryAux7 += " AND DXI6.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux7 += " AND DXL6.DXL_DTBEN BETWEEN '" + DTOS(mv_par11) + "' AND '" + DTOS(mv_par12) + "'"
			
			If !Empty(mv_par08)
				cQueryAux7 += " AND DXL6.DXL_TALHAO = '" + mv_par08 + "'"
			EndIf		
			
			//Filtro de unidade de beneficiamento
			If !empty(mv_par14)
				cQueryAux4 += " AND DXI3.DXI_CODUNB = '"+mv_par14+"'"
				cQueryAux7 += " AND DXI6.DXI_CODUNB = '"+mv_par14+"'"	
			EndIf
	
			If !Empty(mv_par07)
				cQueryAux4 += " AND DXI3.DXI_FAZ = '" + mv_par07 + "'"
				cQueryAux7 += " AND DXI6.DXI_FAZ = '" + mv_par07 + "'"
			Endif
	
			If  !Empty(mv_par09)
				cQueryAux4 += " AND DXI3.DXI_CODVAR = '" + mv_par09 + "'"
				cQueryAux7 += " AND DXI6.DXI_CODVAR = '" + mv_par09 + "'"
			Endif
	
			If  !Empty(mv_par10)
				cQueryAux4 += " AND DXI3.DXI_PRENSA = '" + mv_par10 + "'"
				cQueryAux7 += " AND DXI6.DXI_PRENSA = '" + mv_par10 + "'"
			Endif
	
			cQueryAux4 +=	" and DXI3.DXI_ROMSAI=' ' ) AS QTSALDO, COUNT(DXI.DXI_FARDAO) - ";
			+ cQueryAux4 + " and DXI3.DXI_ROMSAI=' ' ) AS QTSAIDA "
	
	
			cQueryAux7 += " and DXI6.DXI_ROMSAI=' ' ) AS VLSALDO, SUM(DXI.DXI_PSLIQU) - " ;
			+cQueryAux7 + " and DXI6.DXI_ROMSAI=' ' ) AS VLSAIDA "
	
		Endif
	Else
		If mv_par12 == 1
			cQueryAux4 += " (SELECT COUNT(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI3 "
			cQueryAux4 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL3 ON  DXL3.DXL_FILIAL = '" + xFilial("DXL")+ "'"
			cQueryAux4 += "		AND DXL3.DXL_CODIGO = DXI3.DXI_FARDAO  "
			cQueryAux4 += "		AND DXL3.DXL_SAFRA 	= DXI3.DXI_SAFRA "
			cQueryAux4 += "		AND DXL3.DXL_PRDTOR = DXI3.DXI_PRDTOR "
			cQueryAux4 += "		AND DXL3.DXL_LJPRO  = DXI3.DXI_LJPRO " 
			cQueryAux4 += "		AND DXL3.DXL_FAZ 	= DXI3.DXI_FAZ " 
			cQueryAux4 += "		AND DXL3.D_E_L_E_T_  =  ' ' "		
			cQueryAux4 += " WHERE DXI3.D_E_L_E_T_ = '' "
			cQueryAux4 += " AND DXI3.DXI_FILIAL = '" + xFilial("DXI")+ "'"
			cQueryAux4 += " AND DXI3.DXI_SAFRA = '" + mv_par01 + "'"
			cQueryAux4 += " AND DXI3.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux4 += " AND DXL3.DXL_DTBEN BETWEEN '"+ DTOS(mv_par10) + "' AND '"+ DTOS(mv_par11) + "'"
			
			cQueryAux7 += " (SELECT SUM(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI6 "
			cQueryAux7 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL6 ON  DXL6.DXL_FILIAL = '" + xFilial("DXL")+ "'"
			cQueryAux7 += "		AND DXL6.D_E_L_E_T_  =  ' ' "
			cQueryAux7 += "		AND DXL6.DXL_CODIGO = DXI6.DXI_FARDAO  "
			cQueryAux7 += "		AND DXL6.DXL_SAFRA 	= DXI6.DXI_SAFRA "
			cQueryAux7 += "		AND DXL6.DXL_PRDTOR = DXI6.DXI_PRDTOR "
			cQueryAux7 += "		AND DXL6.DXL_LJPRO  = DXI6.DXI_LJPRO "  
			cQueryAux7 += "		AND DXL6.DXL_FAZ 	= DXI6.DXI_FAZ " 
			cQueryAux7 += " WHERE DXI6.D_E_L_E_T_ = '' "
			cQueryAux7 += " AND DXI6.DXI_FILIAL = '" + xFilial("DXI")+ "'"
			cQueryAux7 += " AND DXI6.DXI_SAFRA = '" + mv_par01 + "'"
			cQueryAux7 += " AND DXI6.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux7 += " AND DXL6.DXL_DTBEN BETWEEN '" + DTOS(mv_par10) + "' AND '" + DTOS(mv_par11) + "'"
			
			If !Empty(mv_par07)
				cQueryAux7 += " AND DXL6.DXL_TALHAO = '" + mv_par07 + "'"
			EndIf 		
			
			//Filtro de unidade de beneficiamento
			If !Empty(mv_par13)
				cQueryAux4 += " AND DXI3.DXI_CODUNB = '"+mv_par13+"'"
				cQueryAux7 += " AND DXI6.DXI_CODUNB = '"+mv_par13+"'"	 
			EndIf	
	
			If !Empty(mv_par06)
				cQueryAux4 += " AND DXI3.DXI_FAZ = '" + mv_par06 + "'"
				cQueryAux7 += " AND DXI6.DXI_FAZ = '" + mv_par06 + "'"
			Endif
	
			If  !Empty(mv_par08)
				cQueryAux4 += " AND DXI3.DXI_CODVAR = '" + mv_par08 + "'"
				cQueryAux7 += " AND DXI6.DXI_CODVAR = '" + mv_par08 + "'"
			Endif
	
			If  !Empty(mv_par09)
				cQueryAux4 += " AND DXI3.DXI_PRENSA = '" + mv_par09 + "'"
				cQueryAux7 += " AND DXI6.DXI_PRENSA = '" + mv_par09 + "'"
			Endif
	
			cQueryAux4 +=	"  AND DXI3.DXI_ROMSAI  = ' ') AS QTSALDO "
			cQueryAux7 += " AND DXI6.DXI_ROMSAI  = ' ') AS VLSALDO "
	
			cQueryAux7 += " , 0 AS QTSAIDA "
	
			cQueryAux1 += " AND DXI_ROMSAI = ' '"
	
		ElseIf mv_par12 == 2
			cQueryAux4 += " (SELECT COUNT(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI3 "
			cQueryAux4 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL3 ON  DXL3.DXL_FILIAL = '" + xFilial("DXL")+ "'"
			cQueryAux4 += "		AND DXL3.D_E_L_E_T_  =  ' ' "
			cQueryAux4 += "		AND DXL3.DXL_CODIGO = DXI3.DXI_FARDAO  "
			cQueryAux4 += "		AND DXL3.DXL_SAFRA 	= DXI3.DXI_SAFRA "
			cQueryAux4 += "		AND DXL3.DXL_PRDTOR = DXI3.DXI_PRDTOR "
			cQueryAux4 += "		AND DXL3.DXL_LJPRO  = DXI3.DXI_LJPRO "  
			cQueryAux4 += "		AND DXL3.DXL_FAZ 	= DXI3.DXI_FAZ " 
			cQueryAux4 += " WHERE DXI3.D_E_L_E_T_ = '' "
			cQueryAux4 += " AND DXI3.DXI_FILIAL = '" + xFilial("DXI")+ "'"
			cQueryAux4 += " AND DXI3.DXI_SAFRA = '" + mv_par01 + "'"
			cQueryAux4 += " AND DXI3.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux4 += " AND DXL3.DXL_DTBEN BETWEEN '"+ DTOS(mv_par10) + "' AND '"+ DTOS(mv_par11) + "'"
			
			cQueryAux7 += " (SELECT SUM(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI6 "
			cQueryAux7 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL6 ON  DXL6.DXL_FILIAL = '" + xFilial("DXL")+ "'"
			cQueryAux7 += "		AND DXL6.D_E_L_E_T_  =  ' ' "
			cQueryAux7 += "		AND DXL6.DXL_CODIGO = DXI6.DXI_FARDAO  "
			cQueryAux7 += "		AND DXL6.DXL_SAFRA 	= DXI6.DXI_SAFRA "
			cQueryAux7 += "		AND DXL6.DXL_PRDTOR = DXI6.DXI_PRDTOR "
			cQueryAux7 += "		AND DXL6.DXL_LJPRO  = DXI6.DXI_LJPRO "  
			cQueryAux7 += "		AND DXL6.DXL_FAZ 	= DXI6.DXI_FAZ " 
			cQueryAux7 += " WHERE DXI6.D_E_L_E_T_ = '' "
			cQueryAux7 += " AND DXI6.DXI_FILIAL  = '" + xFilial("DXI")+ "'"
			cQueryAux7 += " AND DXI6.DXI_SAFRA   = '" + mv_par01 + "'"
			cQueryAux7 += " AND DXI6.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux7 += " AND DXL6.DXL_DTBEN BETWEEN '" + DTOS(mv_par10) + "' AND '" + DTOS(mv_par11) + "'"
			
			If !Empty(mv_par07)
				cQueryAux7 += " AND DXL6.DXL_TALHAO = '" + mv_par07 + "'"
			EndIf
			
			
			//Filtro de unidade de beneficiamento
			If !empty(mv_par13)
				cQueryAux4 += " AND DXI3.DXI_CODUNB = '"+mv_par13+"'"
				cQueryAux7 += " AND DXI6.DXI_CODUNB = '"+mv_par13+"'"	 
			EndIf
	
			If !Empty(mv_par06)
				cQueryAux4 += " AND DXI3.DXI_FAZ = '" + mv_par06 + "'"
				cQueryAux7 += " AND DXI6.DXI_FAZ = '" + mv_par06 + "'"
			Endif
	
			If  !Empty(mv_par08)
				cQueryAux4 += " AND DXI3.DXI_CODVAR = '" + mv_par08 + "'"
				cQueryAux7 += " AND DXI6.DXI_CODVAR = '" + mv_par08 + "'"
			Endif
	
			If  !Empty(mv_par09)
				cQueryAux4 += " AND DXI3.DXI_PRENSA = '" + mv_par09 + "'"
				cQueryAux7 += " AND DXI6.DXI_PRENSA = '" + mv_par09 + "'"
			Endif
	
			cQueryAux4 +=	"  AND DXI3.DXI_ROMSAI  <> ' ') AS QTSAIDA "
			cQueryAux7 += " AND DXI6.DXI_ROMSAI  <> ' ') AS VLSAIDA "
			cQueryAux7 +=	",  0 AS QTSALDO "
	
			cQueryAux1 += " AND DXI_ROMSAI <> ' '"
	
		Else
			cQueryAux4 += " (SELECT COUNT(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI3 "
			cQueryAux4 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL3 ON  DXL3.DXL_FILIAL = '" + xFilial("DXL")+ "'"
			cQueryAux4 += "		AND DXL3.D_E_L_E_T_  =  ' ' "
			cQueryAux4 += "		AND DXL3.DXL_CODIGO = DXI3.DXI_FARDAO  "
			cQueryAux4 += "		AND DXL3.DXL_SAFRA 	= DXI3.DXI_SAFRA "
			cQueryAux4 += "		AND DXL3.DXL_PRDTOR = DXI3.DXI_PRDTOR "
			cQueryAux4 += "		AND DXL3.DXL_LJPRO  = DXI3.DXI_LJPRO "  
			cQueryAux4 += "		AND DXL3.DXL_FAZ 	= DXI3.DXI_FAZ " 
			cQueryAux4 += " WHERE DXI3.D_E_L_E_T_ = '' "
			cQueryAux4 += " AND DXI3.DXI_FILIAL = '" + xFilial("DXI")+ "'"
			cQueryAux4 += " AND DXI3.DXI_SAFRA = '" + mv_par01 + "'"
			cQueryAux4 += " AND DXI3.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux4 += " AND DXL3.DXL_DTBEN BETWEEN '"+ DTOS(mv_par10) + "' AND '"+ DTOS(mv_par11) + "'"
				
			cQueryAux7 += " (SELECT SUM(DXI_PSLIQU) FROM " + RetSqlName( "DXI" ) +  " DXI6 "
			cQueryAux7 += " INNER JOIN "+ RetSqlName( "DXL" ) +" DXL6 ON  DXL6.DXL_FILIAL = DXI6.DXI_FILIAL "
			cQueryAux7 += "		AND DXL6.D_E_L_E_T_  =  ' ' "
			cQueryAux7 += "		AND DXL6.DXL_CODIGO = DXI6.DXI_FARDAO  "
			cQueryAux7 += "		AND DXL6.DXL_SAFRA 	= DXI6.DXI_SAFRA "
			cQueryAux7 += "		AND DXL6.DXL_PRDTOR = DXI6.DXI_PRDTOR "
			cQueryAux7 += "		AND DXL6.DXL_LJPRO  = DXI6.DXI_LJPRO "  
			cQueryAux7 += "		AND DXL6.DXL_FAZ 	= DXI6.DXI_FAZ " 
			cQueryAux7 += " WHERE DXI6.D_E_L_E_T_ = ' ' "
			cQueryAux7 += " AND DXI6.DXI_FILIAL  = '" + xFilial("DXI")+ "'"
			cQueryAux7 += " AND DXI6.DXI_SAFRA   = '" + mv_par01 + "'"
			cQueryAux7 += " AND DXI6.DXI_CLACOM  = DXI.DXI_CLACOM "
			cQueryAux7 += " AND DXL6.DXL_DTBEN BETWEEN '" + DTOS(mv_par10) + "' AND '" + DTOS(mv_par11) + "'"
			
			If !Empty(mv_par07)
				cQueryAux7 += " AND DXL6.DXL_TALHAO = '" + mv_par07 + "'"
			EndIf		
			
			//Filtro de unidade de beneficiamento
			If !empty(mv_par13)
				cQueryAux4 += " AND DXI3.DXI_CODUNB = '"+mv_par13+"'"
				cQueryAux7 += " AND DXI6.DXI_CODUNB = '"+mv_par13+"'"	
			EndIf
	
			If !Empty(mv_par06)
				cQueryAux4 += " AND DXI3.DXI_FAZ = '" + mv_par06 + "'"
				cQueryAux7 += " AND DXI6.DXI_FAZ = '" + mv_par06 + "'"
			Endif
	
			If  !Empty(mv_par08)
				cQueryAux4 += " AND DXI3.DXI_CODVAR = '" + mv_par08 + "'"
				cQueryAux7 += " AND DXI6.DXI_CODVAR = '" + mv_par08 + "'"
			Endif
	
			If  !Empty(mv_par09)
				cQueryAux4 += " AND DXI3.DXI_PRENSA = '" + mv_par09 + "'"
				cQueryAux7 += " AND DXI6.DXI_PRENSA = '" + mv_par09 + "'"
			Endif
	
			cQueryAux4 +=	" and DXI3.DXI_ROMSAI=' ' ) AS QTSALDO, COUNT(DXI.DXI_FARDAO) - ";
			+ cQueryAux4 + " and DXI3.DXI_ROMSAI=' ' ) AS QTSAIDA "
	
	
			cQueryAux7 += " and DXI6.DXI_ROMSAI=' ' ) AS VLSALDO, SUM(DXI.DXI_PSLIQU) - " ;
			+cQueryAux7 + " and DXI6.DXI_ROMSAI=' ' ) AS VLSAIDA "
	
		Endif
	EndIf
		
	cQueryAux1 := "%"+cQueryAux1+"%"
	cQueryAux2 := "%"+cQueryAux2+cQueryAux3+","+cQueryAux4+"%"
	cQueryAux5 := "%"+cQueryAux5+cQueryAux6+","+cQueryAux7+cQueryAux9+"%"

	/***********************************************/

	Begin Report Query oSec2

		cAlias := GetNextAlias()
		cSemClass := STR0038
		BeginSql Alias cAlias

		SELECT DXI.DXI_CLACOM, NVL(LTrim(DXA.DXA_DESCRI),%exp:cSemClass%) AS DXA_DESCRI,
		(COUNT(DXI_PSLIQU) * 100 / (SELECT COUNT(DXI_PSLIQU) FROM %table:DXI% DXI7
		INNER JOIN %table:DXL% DXL7
		ON DXL7.DXL_FILIAL     = %xFilial:DXL%
		AND DXL7.D_E_L_E_T_    = ' '
		AND DXL7.DXL_CODIGO    = DXI7.DXI_FARDAO
		AND DXL7.DXL_SAFRA     = DXI7.DXI_SAFRA
		AND DXL7.DXL_PRDTOR    = DXI7.DXI_PRDTOR
		AND DXL7.DXL_LJPRO     = DXI7.DXI_LJPRO
		AND DXL7.DXL_FAZ       = DXI7.DXI_FAZ
		WHERE %exp:cQueryAux1% )) AS PERC,
		COUNT(DXI.DXI_FARDAO) AS QTFARDOS
		%exp:cQueryAux2%,
		SUM(DXI.DXI_PSLIQU) AS VLFARDOS
		%exp:cQueryAux5%
		FROM %table:DXI% DXI left join  %table:DXA% DXA  on   DXA.DXA_CODIGO  = DXI.DXI_CLACOM
		AND DXA.D_E_L_E_T_ = ' '
		INNER JOIN %table:DXL% DXL ON DXL.%notDel%
		AND DXI.DXI_FILIAL = %xFilial:DXL%
		AND DXL.DXL_CODIGO = DXI.DXI_FARDAO 
		AND DXL.DXL_SAFRA  = DXI.DXI_SAFRA 
		AND DXL.DXL_PRDTOR = DXI.DXI_PRDTOR
		AND DXL.DXL_LJPRO  = DXI.DXI_LJPRO
		AND DXL.DXL_FAZ    = DXI.DXI_FAZ  
		%exp:cQueryAux8%
		GROUP BY DXI.DXI_CLACOM, DXA.DXA_DESCRI
		ORDER BY DXI.DXI_CLACOM
		EndSql

	End Report Query oSec2


	/**************************************************************/

	(cAlias)->(dbGoTop())
	If (cAlias)->(!Eof())
		oSec2:Init()
		oSec2:Print()
		oSec2:Finish()
	EndIf

	oSec2:Finish()
	(cAlias)->(dbCloseArea())
	#ENDIF

	Return Nil

Return


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
	aCabec[3] += Space(9) + "Dt.Ref:" + Dtoc(dDataBase)   // Direita

	// Linha 4
	AADD(aCabec, RptHora + oReport:cTime) //Esquerda
	aCabec[4] += Space(9) // Meio
	aCabec[4] += Space(9) + RptEmiss + oReport:cDate   // Direita

	// Linha 5
	AADD(aCabec, STR0036 + cNmEmp) //Esquerda
	aCabec[5] += Space(9) // Meio
	If !Empty(cSafra)
		aCabec[5] += Space(9)+ "Safra:"+cSafra   // Direita
	EndIf

	// Linha 6
	AADD(aCabec, STR0037 + cNmFilial) //Esquerda

Return aCabec
