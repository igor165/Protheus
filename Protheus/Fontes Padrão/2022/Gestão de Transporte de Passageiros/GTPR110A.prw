#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'GTPR110A.CH'
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR110A()
Relatório de vales de funcionários pendentes e/ ou baixados 

@sample GTPR110A()
@return Nil

@author	Renan Ribeiro Brando -  Inovação
@since	08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Function GTPR110A()
Local oReport     := Nil

// Interface de impressao
oReport := ReportDef()
oReport:PrintDialog()

Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()

@sample ReportDef()
@return oReport - Objeto - Objeto TREPORT

@author	Renan Ribeiro Brando -  Inovação
@since	08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
Local oReport
local cAliasGQP  := GetNextAlias()
//---------------------------------------
// Criação do componente de impressão
//---------------------------------------
oReport := TReport():New("GTPR110A", STR0001, "GTPR110A", {|oReport| ReportPrint(oReport, cAliasGQP)}, STR0002 ) // #Vales de Funcionários, #Relatório de vales de funcionários.
oReport:SetTotalInLine(.F.)
Pergunte("GTPR110A", .F.)

oSection := TRSection():New(oReport, STR0001, "GQP", /*{Array com as ordens do relatório}*/, /*Campos do SX3*/, /*Campos do SIX*/) //#Vales de Funcionários
oSection:SetTotalInLine(.F.)

// Campos que serão demonstrados no relatório
TRCell():New(oSection, "GQP_CODIGO", "GQP", STR0004, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #Número do Vale
TRCell():New(oSection, "GQP_CODFUN", "GQP", STR0005, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #Código do Funcionário
TRCell():New(oSection, "GQP_DESCFU", "GQP", STR0006, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #Nome do Funcionário
TRCell():New(oSection, "GQP_CODAGE", "GQP", STR0014, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #Código da Agência
TRCell():New(oSection, "GQP_DESCAG", "GQP", STR0015, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #Descrição da Agência
TRCell():New(oSection, "GQP_TIPO"  , "GQP", STR0007, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #Tipo
TRCell():New(oSection, "GQP_DESFIN", "GQP", STR0008, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #Descrição do Vale
TRCell():New(oSection, "GQP_EMISSA", "GQP", STR0010, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #Data de Emissão
TRCell():New(oSection, "GQP_VIGENC", "GQP", STR0009, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #Data de Vigência
TRCell():New(oSection, "GQP_VALOR" , "GQP", STR0011, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #Valor
TRCell():New(oSection, "GQP_SLDDEV", "GQP", STR0013, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #Saldo Devedor do Vale
TRCell():New(oSection, "GQP_STATUS", "GQP", STR0012, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #Status

// Posiciones dos campos virtuais
oSection:Cell('GQP_DESCFU'):SetBlock({|| POSICIONE('SRA', 1, xFilial('SRA') + (cAliasGQP)->GQP_CODFUN, 'RA_NOME'   )}) 
oSection:Cell('GQP_DESCAG'):SetBlock({|| POSICIONE('GI6', 1, xFilial('GI6') + (cAliasGQP)->GQP_CODAGE, 'GI6_DESCRI')})

Return oReport
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint(oReport, cAliasGQP)

@sample ReportPrint(oReport, cAliasGQP)
@param oReport 
@param cAliasGQP 
@return Nil

@author	Renan Ribeiro Brando -  Inovação
@since	08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport, cAliasGQP)
Local oSection    := oReport:Section(1)
Local cParam1     := cValToChar(MV_PAR01) // Somente vales baixados?
Local cParam2     := cValToChar(MV_PAR02) // Tipos de vale de?
Local cParam3     := cValToChar(MV_PAR03) // Tipos de vale até?
Local cParam4     := cValToChar(MV_PAR04) // Funcionários de?
Local cParam5     := cValToChar(MV_PAR05) // Funcionários até?
Local cParam6     := DTOS(MV_PAR06) // Data de vigência de?
Local cParam7     := DTOS(MV_PAR07) // Data de vigência até?

//---------------------------------------
// Query do relatório da secao 1
//---------------------------------------
oSection:BeginQuery()

BeginSQL Alias cAliasGQP
SELECT *
FROM %table:GQP% GQP
WHERE 
GQP.GQP_FILIAL = %xFilial:GQP%
AND GQP.%NotDel%
AND GQP.GQP_STATUS = %Exp:cParam1%
AND GQP.GQP_TIPO BETWEEN %Exp:cParam2% AND %Exp:cParam3%
AND GQP.GQP_CODFUN BETWEEN %Exp:cParam4% AND %Exp:cParam5%
AND GQP.GQP_VIGENC BETWEEN %Exp:cParam6% AND %Exp:cParam7%      
EndSQL

oSection:EndQuery()
oSection:Print()
Return
