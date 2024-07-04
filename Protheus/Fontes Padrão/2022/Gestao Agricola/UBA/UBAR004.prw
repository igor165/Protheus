#INCLUDE "ubar004.ch"
#include "protheus.ch"
#include "report.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} UBAR004
Relatorio de Beneficiamento

@author Aécio Gomes
@since 21/06/2013 
@version MP11.8
/*/
//-------------------------------------------------------------------
Function UBAR004()
Local oReport 
Local cPerg := "UBAR004"
Private cSafra   
Private cProduto  
Private cProdutor  
Private cLoja                                  
Private cFazenda                                
Private cTalhao                                 
Private cVariedade                                                           
Private cTurno                                  
Private dPeriInic                               
Private dPerifinal 
Private cAliTab := ""

Private _lNovSafra 	:= .F.
	
If NN1->(ColumnPos('NN1_CODSAF' )) > 0
	_lNovSafra := .T.
EndIf

If FindFunction("TRepInUse") .And. TRepInUse()
	                             
	/**                                             
	 Grupo de perguntas UBAR004                     
		MV_PAR01 - Safra
		MV_PAR02 - Produto
		MV_PAR03 - Entidade
		MV_PAR04 - Loja
		MV_PAR05 - Fazenda
		MV_PAR06 - Talhao   
		MV_PAR07 - Variedade
		MV_PAR08 - Turno
		MV_PAR09 - Pediodo Inicial
		MV_PAR10 - Periodo Final
		MV_PAR11 - Unidade Beneficiamento
	**/
	Pergunte(cPerg,.F.)
	cSafra     := MV_PAR01
	
	//-------------------------
	// Interface de impressão
	//-------------------------
	oReport:= ReportDef(cPerg)
	//oReport:lParamPage := .F.
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
Local oBreak	:= Nil
Local oSec1		:= NIL

DEFINE REPORT oReport NAME "UBAR004" TITLE STR0001 PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} //"Relatório de Beneficiamento"
oReport:nFontBody 	:= 8 	//Aumenta o tamanho da fonte
oReport:lParamPage 		:= .F. //Não imprime os parametros
oReport:SetCustomText( {|| UBARCabec(oReport, MV_PAR01) } ) // Cabeçalho customizado
oReport:SetLandscape() // Define orientação de página do relatório como paisagem

//---------
// Seção 1
//---------
DEFINE SECTION oSec1 OF oReport TITLE STR0002 TABLES "DXL","DXI" BREAK HEADER AUTO SIZE //"Beneficiamento"
	oSec1:SetTotalInLine(.F.)   // Define se imprime o total por linha
	oSec1:SetAutoSize(.T.) 		// Define se as células serão ajustadas automaticamente na seção
	oSec1:SetReadOnly(.T.) 		// Define se o usuário não poderá alterar informações da seção, ou seja, não poderá remover as células pré-definidas.
	
	DEFINE CELL NAME "NM_PRDTOR" 	OF oSec1 TITLE STR0003	SIZE TamSX3("NJ0_NOME"  )[1]   PICTURE PesqPict("NJ0","NJ0_NOME") BLOCK{|| Posicione("NJ0",1,FWxFilial("NJ0")+PRODUTOR+LOJA,"NJ0_NOME")} //"Entidade"
	DEFINE CELL NAME "LOJENT"   	OF oSec1 TITLE RetTitSX3("NJ0_LOJENT") SIZE TamSX3("NJ0_LOJENT"  )[1]   PICTURE PesqPict("NJ0","NJ0_LOJENT") BLOCK{|| Posicione("NJ0",1,FWxFilial("NJ0")+PRODUTOR+LOJA,"NJ0_LOJENT")} //"Entidade"
	DEFINE CELL NAME "NM_FAZ" 		OF oSec1 TITLE STR0004 	SIZE TamSX3("NN2_NOME"  )[1]   PICTURE PesqPict("NN2","NN2_NOME") BLOCK{|| Posicione("NN2",3,FWxFilial("NN2")+PRODUTOR+LOJA+FAZENDA,"NN2_NOME")} //"Fazenda"
	DEFINE CELL NAME "DATABN" 		OF oSec1 TITLE STR0005 	SIZE 10                        BLOCK{|| STOD((cAliTab)->DATABN) } //"Data Benef."
	DEFINE CELL NAME "TURNO" 		OF oSec1 TITLE STR0006 	SIZE TamSX3("DXL_CODTUR")[1]   PICTURE PesqPict("DXL","DXL_CODTUR") //"Turno"
	DEFINE CELL NAME "QTD_FDOES" 	OF oSec1 TITLE STR0007 	SIZE 10                        PICTURE "@E 9,999,999" //"Total Fardoes"
	DEFINE CELL NAME "PS_FDOES" 	OF oSec1 TITLE STR0008 	SIZE TamSX3("DXL_PSLIQU")[1]   PICTURE PesqPict("DXL","DXL_PSLIQU") //"Peso Fardoes "
	DEFINE CELL NAME "QTD_FDIS"  	OF oSec1 TITLE STR0009 	SIZE 10                        PICTURE "@E 9,999,999" //"Total Fardos"
	DEFINE CELL NAME "PS_FDIS"		OF oSec1 TITLE STR0010	SIZE TamSX3("DXL_PSLIQU")[1]   PICTURE PesqPict("DXL","DXL_PSLIQU") //"Peso Fardos"
	DEFINE CELL NAME "RD" 			OF oSec1 TITLE "%RD"		SIZE TamSX3("DXL_RDMTO" )[1]   PICTURE PesqPict("DXL","DXL_RDMTO") BLOCK{|| (PS_FDIS/PS_FDOES)*100}

	oSec1:SetTotalText(STR0012) // Texto da seção tolalizadora //"Total Geral"
	DEFINE BREAK oBreak OF oSec1 WHEN cSafra
	oBreak:OnBreak({|a,b| UsrOnBreak(a, b, oBreak)})
	DEFINE FUNCTION oFunc1 NAME "T1" FROM oSec1:Cell("QTD_FDOES") OF oSec1 FUNCTION SUM NO END REPORT BREAK oBreak 
	DEFINE FUNCTION oFunc1 NAME "T2" FROM oSec1:Cell("PS_FDOES" ) OF oSec1 FUNCTION SUM NO END REPORT BREAK oBreak 
	DEFINE FUNCTION oFunc1 NAME "T3" FROM oSec1:Cell("QTD_FDIS" ) OF oSec1 FUNCTION SUM NO END REPORT BREAK oBreak 
	DEFINE FUNCTION oFunc1 NAME "T4" FROM oSec1:Cell("PS_FDIS"  ) OF oSec1 FUNCTION SUM NO END REPORT BREAK oBreak 
	DEFINE FUNCTION oFunc1 NAME "T5" FROM oSec1:Cell("RD"       ) OF oSec1 NO END REPORT BREAK oBreak 

	oFunc1:lEndSection :=  .T.

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
Local cAlias   	:= ""	
Local cWhere		:= ""
Local cWhereDXI  := ""	
Local cGroupBy	:= ""
Local cUN        := ""

If _lNovSafra
	cSafra     := MV_PAR01
	cProduto   := MV_PAR02
	cProdutor  := MV_PAR03
	cLoja      := MV_PAR04 
	cFazenda   := MV_PAR05 
	cTalhao    := MV_PAR06 
	cVariedade := MV_PAR07 
	cTurno     := MV_PAR08
	dPeriInic  := MV_PAR09 
	dPerifinal := MV_PAR10
	cUN 	   := MV_PAR11
Else
	cSafra     := MV_PAR01
	cProdutor  := MV_PAR02
	cLoja      := MV_PAR03 
	cFazenda   := MV_PAR04 
	cTalhao    := MV_PAR05 
	cVariedade := MV_PAR06 
	cTurno     := MV_PAR07
	dPeriInic  := MV_PAR08 
	dPerifinal := MV_PAR09
	cUN 	   := MV_PAR10
EndIf

// Safra
cWhere := " DXL.DXL_SAFRA  = '"+cSafra+"' " 

If !Empty(cUN) 
	cWhere += " AND DXL.DXL_CODUNB = '"+cUN+"'"
Endif

// Produto
If !Empty(cProduto) 
	cWhere += " AND DXL.DXL_CODPRO = '"+cProduto+"' "
EndIf
	
// Entidade
If !Empty(cProdutor) 
	cWhere += " AND DXL.DXL_PRDTOR = '"+cProdutor+"' "
	// Loja
	If !Empty(cLoja) 
		cWhere += " AND DXL.DXL_LJPRO = '"+cLoja+"' "
	EndIf
EndIf
// Fazenda	
If !Empty(cFazenda)	
	cWhere += " AND DXL.DXL_FAZ = '"+cFazenda+"'"
EndIf	          
// Talhao
If !Empty(cTalhao) 
	cWhere += " AND DXL.DXL_TALHAO = '"+cTalhao+"' "
	cGroupBy += ", DXL.DXL_TALHAO"
EndIf
// Variedade
If !Empty(cVariedade)
	cWhere += " AND DXL.DXL_CODVAR = '"+cVariedade+"' "
	cGroupBy += ", DXL.DXL_CODVAR"
EndIf

// Turno
If !Empty(cTurno)
	cWhere += " AND DXL.DXL_CODTUR = '"+cTurno+"' "
	cGroupBy += ", DXL.DXL_CODTUR"
EndIf

If !Empty(dPeriInic) .And. !Empty(dPerifinal) 
	cWhereDXI += " AND DXL.DXL_DTBEN BETWEEN '"+DTos(dPeriInic)+"' AND '"+dTos(dPerifinal)+"'"
EndIf

If !Empty(cUN)
	cWhereDXI += " AND DXI.DXI_CODUNB = '" + cUN + "'"
Endif	

cWhere := "%"+cWhere+"%"
cWhereDXI := "%"+cWhereDXI+"%"

cGroupBy += ", DXL.DXL_DTBEN, DXL.DXL_CODTUR"
cGroupBy := "%"+cGroupBy+"%"

Begin Report Query oSec1

	cAlias:= GetNextAlias()
	cAliTab := cAlias
	BeginSql Alias cAlias

		SELECT A.PRODUTOR
	     	, A.LOJA
	     	, A.FAZENDA
	     	, A.DATABN
	     	, A.TURNO 
	     	, COUNT(A.TOTAL_FARDOES) AS QTD_FDOES
	     	, SUM(A.LIQUIDO_FARDAO) AS PS_FDOES
	     	, SUM(A.TOTAL_FARDINHOS) AS QTD_FDIS
	     	, SUM(A.PESO_LIQUIDO_FARDINHO) AS PS_FDIS
		FROM 
			(SELECT DXL.DXL_PRDTOR AS PRODUTOR
		     	, DXL.DXL_LJPRO AS LOJA
		     	, DXL.DXL_FAZ AS FAZENDA
		     	, DXL.DXL_DTBEN AS DATABN
		     	, DXL.DXL_CODTUR AS TURNO
		     	, COUNT(DISTINCT DXL.DXL_CODIGO) AS TOTAL_FARDOES
				, (SELECT SUM((CASE WHEN DXL2.DXL_PSLIQU = 0 THEN DXL2.DXL_PSESTI Else DXL2.DXL_PSLIQU END))
		          	FROM %table:DXL% DXL2
					WHERE DXL2.%notDel% AND
						DXL2.DXL_FILIAL = DXL.DXL_FILIAL AND
						DXL2.DXL_CODIGO = DXL.DXL_CODIGO AND
						DXL2.DXL_SAFRA  = DXL.DXL_SAFRA  AND
						DXL2.DXL_PRDTOR = DXL.DXL_PRDTOR AND
						DXL2.DXL_LJPRO  = DXL.DXL_LJPRO  AND
		                DXL2.DXL_FAZ    = DXL.DXL_FAZ    AND
		               	%Exp: (StrTran(cWhere,"DXL.","DXL2.")) %) AS LIQUIDO_FARDAO
		     	, COUNT(DISTINCT DXI.DXI_ETIQ) TOTAL_FARDINHOS
		     	, SUM(DXI.DXI_PSLIQU) AS PESO_LIQUIDO_FARDINHO
		
		 	 FROM %table:DXL% DXL		    
		     INNER JOIN %table:DXI% DXI ON DXI.%notDel% AND
		     	(DXI.DXI_FILIAL = %xFilial:DXI% AND
		     	DXI.DXI_FARDAO 	= DXL.DXL_CODIGO AND
		     	DXI.DXI_SAFRA   = DXL.DXL_SAFRA  AND
				DXI.DXI_PRDTOR 	= DXL.DXL_PRDTOR AND
				DXI.DXI_LJPRO 	= DXL.DXL_LJPRO AND
				DXI.DXI_FAZ		= DXL.DXL_FAZ
				%Exp:cWhereDXI%)

			WHERE DXL.%notDel% AND 
		 	 	DXL.DXL_FILIAL = %xFilial:DXL%
		 	 	AND %exp:cWhere%
		 	 GROUP BY DXL.DXL_FILIAL, DXL.DXL_CODIGO, DXL.DXL_SAFRA, DXL.DXL_PRDTOR, DXL.DXL_LJPRO, DXL.DXL_FAZ	
			%Exp:cGroupBy%
			) A
		GROUP BY 
				A.PRODUTOR
				,A.LOJA
				,A.FAZENDA
				,A.DATABN
				,A.TURNO
		ORDER BY 
		     	A.DATABN
   				,A.PRODUTOR
		     	,A.LOJA
		     	,A.FAZENDA
	EndSql 

End Report Query oSec1

oSec1:Print()



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
aCabec[3] += Space(9) + STR0013 + Dtoc(dDataBase)   // Direita //"Dt.Ref:"

// Linha 4
AADD(aCabec, RptHora + oReport:cTime) //Esquerda
aCabec[4] += Space(9) // Meio
aCabec[4] += Space(9) + RptEmiss + oReport:cDate   // Direita

// Linha 5
AADD(aCabec, STR0014 + cNmEmp) //Esquerda //"Empresa:"
aCabec[5] += Space(9) // Meio
If !Empty(MV_PAR01)
	aCabec[5] += Space(9)+ STR0015+MV_PAR01   // Direita //"Safra:"
EndIf	

// Linha 6
AADD(aCabec, STR0016 + cNmFilial) //Esquerda //"Filial:"

Return aCabec

//-------------------------------------------------------------------
/*/{Protheus.doc} UsrOnBreak
Tratamento antes da impressão dos totalizadores da quebra

@param uBreakAnt - Quebra anterior
@param uBreakAtu - Quebra atual
@param oBreak - Objeto da quebra
@author Aécio Gomes
@since 21/07/2013
@version MP11.8
/*/
//-------------------------------------------------------------------
Static Function UsrOnBreak(uBreakAnt,uBreakAtu,oBreak)
Local nTFdao 		:= oBreak:GetFunction("T2"):UVALUE
Local nTFdaoBreak	:= oBreak:GetFunction("T2"):USECTION
Local nTFdi 		:= oBreak:GetFunction("T4"):UVALUE
Local nTFdiBreak 	:= oBreak:GetFunction("T4"):USECTION

// Altera o valor do total da coluna %RD
oBreak:GetFunction("T5"):UVALUE := (nTFdi/nTFdao)*100 // Altera valor total da quebra
oBreak:GetFunction("T5"):USECTION := (nTFdiBreak/nTFdaoBreak)*100 // Altera valor total da seção

Return
