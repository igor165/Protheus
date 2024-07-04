#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TMSRB11.CH"

/*/-----------------------------------------------------------
{Protheus.doc} TMSRB11()
Relacao de Controle de Diarias

Uso: SIGATMS

@sample
//TMSRB11()

@author Paulo Henrique Corrêa Cardoso.
@since 27/01/2014
@version 1.0
-----------------------------------------------------------/*/
User Function TMSRB11()
Local oReport					// Recebe o Objeto do Report
Local oDYX						// Recebe o Objeto da Section 
Local cPergunt := "TMSRB11"		// Recebe o Pergunte

Pergunte(cPergunt,.T.)

IIf(ExistFunc('FwPdLogUser'),FwPdLogUser(cPergunt),)

DEFINE REPORT oReport NAME "TMSRB11" TITLE STR0001 PARAMETER cPergunt ACTION {|oReport| PrintReport(oReport)}//"Relacao de Controle de Diarias" 

DEFINE SECTION oDYX OF oReport TITLE STR0002 TABLES "DYX","DYV","DA4","DUT","SX5" //"Diarias"

DEFINE CELL NAME "DYX_TIPDIA" OF oDYX ALIAS "DYX"
DEFINE CELL NAME "DYX_STATUS" OF oDYX ALIAS "DYX"
DEFINE CELL NAME "DYX_TIPVIA" OF oDYX ALIAS "DYX"
DEFINE CELL NAME "DYX_DATDIA" OF oDYX ALIAS "DYX"
DEFINE CELL NAME "DYV_CODMOT" OF oDYX ALIAS "DYV"
DEFINE CELL NAME "DA4_NOME"   OF oDYX ALIAS "DA4"
DEFINE CELL NAME "DYX_CONDUT" OF oDYX ALIAS "DYX"
DEFINE CELL NAME "DUT_DESCRI" OF oDYX ALIAS "DUT"
DEFINE CELL NAME "X5_DESCRI"  OF oDYX ALIAS "SX5"
DEFINE CELL NAME "DYX_ORIGEM" OF oDYX ALIAS "DYX"
DEFINE CELL NAME "DYX_QTDE"   OF oDYX ALIAS "DYX" PICTURE "@E 999.99"
DEFINE CELL NAME "DYX_VLRUNI" OF oDYX ALIAS "DYX"
DEFINE CELL NAME "DYX_VLRTOT" OF oDYX ALIAS "DYX"

oReport:PrintDialog()

Return


/*/-----------------------------------------------------------
{Protheus.doc} PrintReport()
Imprime o Relatorio

Uso: TMSRB11

@sample
//PrintReport(oReport)

@author Paulo Henrique Corrêa Cardoso.
@since 27/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function PrintReport(oReport)
Local cAliasBusc := GetNextAlias()	// Recebe o proximo alias disponivel 
Local cFilOriIni := ""				// Recebe a Filial de Origem Inicial 	
Local cFilOriFim := ""				// Recebe a Filial de Origem Final
Local cViagemIni := ""				// Recebe a Viagem Inicial
Local cViagemFim := ""				// Recebe a Viagem Final	
Local cDataIni	 := ""				// Recebe a Data Inicial
Local cDataFim	 := ""				// Recebe a Data Final
Local cMotIni	 :=	""  			// Recebe o Motorista Inicial
Local cMotFim	 := ""  			// Recebe o Motorista Final
Local cStatus    := ""				// Recebe o Status
Local oBrkStaMot   					// Recebe a quebra por Motorista + Status
	
cFilOriIni 	:=  ALLTRIM(MV_PAR01)
cFilOriFim 	:=  ALLTRIM(MV_PAR03)
cViagemIni 	:=  ALLTRIM(MV_PAR02)
cViagemFim 	:=  ALLTRIM(MV_PAR04)
cDataIni	:=  ALLTRIM(DTOS(MV_PAR05))
cDataFim	:=  ALLTRIM(DTOS(MV_PAR06))
cMotIni	 	:=	ALLTRIM(MV_PAR07)
cMotFim	 	:=  ALLTRIM(MV_PAR08)



If MV_PAR09 == 1						    // Se for todos os Status
	cStatus 	:= "1','2','3','4','5"
ElseIf MV_PAR09 == 2					    // Se for Status de Pendencia
	cStatus 	:= "1','2"
Else 										// Outro Status
	cStatus 	:=  cValToChar(MV_PAR09)
EndIf

// Cria a Query de Busca do Relatório
BEGIN REPORT QUERY oReport:Section(1)

BeginSql alias cAliasBusc
	SELECT DYX_TIPDIA,DYX_STATUS,DYX_TIPVIA,DYX_DATDIA,DYV_CODMOT,DA4_NOME,DYX_CONDUT,
		DUT_DESCRI,X5_DESCRI,DYX_ORIGEM,DYX_QTDE,DYX_VLRUNI,DYX_VLRTOT
	
	FROM %table:DYV% DYV
	INNER JOIN %table:DYX% DYX ON DYV_FILIAL = DYX_FILIAL AND DYV_IDCDIA = DYX_IDCDIA
	INNER JOIN %table:DA4% DA4 ON DA4_COD = DYV_CODMOT
	INNER JOIN %table:DUT% DUT ON  DUT_TIPVEI = DYX_TIPVEI
	INNER JOIN %table:SX5% SX5 ON  X5_TABELA = 'MS' AND X5_CHAVE = DYX_TIPVAL
	
	WHERE  DYV.%NotDel% 
		   AND DYX.%NotDel% 
		   AND DA4.%NotDel% 
		   AND DUT.%NotDel% 
		   AND SX5.%NotDel% 
		   AND DYV_FILIAL = %Exp:FWxFilial('DYV')%
		   AND DYX_FILIAL = %Exp:FWxFilial('DYX')%
		   AND DA4_FILIAL = %Exp:FWxFilial('DA4')%
		   AND DUT_FILIAL = %Exp:FWxFilial('DUT')%
		   AND X5_FILIAL =  %Exp:FWxFilial('SX5')%
		   AND DYV_FILORI BETWEEN %Exp:cFilOriIni% AND %Exp:cFilOriFim%
		   AND DYV_VIAGEM BETWEEN %Exp:cViagemIni% AND %Exp:cViagemFim%
		   AND DYX_DATDIA BETWEEN %Exp:cDataIni%   AND %Exp:cDataFim%
		   AND DYV_CODMOT BETWEEN %Exp:cMotIni%    AND %Exp:cMotFim%
		   AND DYX_STATUS IN (%Exp:cStatus%)
		   
	ORDER BY DYV_CODMOT,DYX_STATUS,DYX_TIPDIA,DYV_IDCDIA,DYX_TIPVIA
EndSql

END REPORT QUERY oReport:Section(1) 

// Quebra por Motorista + Status
oBrkStaMot  := TRBreak():New(oReport:Section(1),{||oReport:Section(1):Cell("DYV_CODMOT"):GetText()+oReport:Section(1):Cell("DYX_STATUS"):GetText()},STR0026,.T.,,.F.) //"Total por Status"

// Quebra de Pagina por Motorista
oBreak2 := TRBreak():New(oReport:Section(1),oReport:Section(1):Cell("DYV_CODMOT"),STR0027,.T.,,.T.) //"Total Geral do Motorista"


// Cria os Totalizadores

//Total por Status
TRFunction():New(oReport:Section(1):Cell("DYX_QTDE"),"QTDEMOTSTAT","SUM",oBrkStaMot,,,,.F.,.F.,,,)
TRFunction():New(oReport:Section(1):Cell("DYX_VLRTOT"),"VLREMOTSTAT","SUM",oBrkStaMot,,,,.F.,.F.,,,)

// Total Geral
TRFunction():New(oReport:Section(1):Cell("DYX_QTDE"),"QTDEGERAL","SUM",oBreak2,,,,.F.,.F.,,,)
TRFunction():New(oReport:Section(1):Cell("DYX_VLRTOT"),"VLRGERAL","SUM",oBreak2,,,,.F.,.F.,,,)



oReport:Section(1):Print()

Return
