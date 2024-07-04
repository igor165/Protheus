#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'GTPR110A.CH'
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR110A()
Relat�rio de vales de funcion�rios pendentes e/ ou baixados 

@sample GTPR110A()
@return Nil

@author	Renan Ribeiro Brando -  Inova��o
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

@author	Renan Ribeiro Brando -  Inova��o
@since	08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
Local oReport
local cAliasGQP  := GetNextAlias()
//---------------------------------------
// Cria��o do componente de impress�o
//---------------------------------------
oReport := TReport():New("GTPR110A", STR0001, "GTPR110A", {|oReport| ReportPrint(oReport, cAliasGQP)}, STR0002 ) // #Vales de Funcion�rios, #Relat�rio de vales de funcion�rios.
oReport:SetTotalInLine(.F.)
Pergunte("GTPR110A", .F.)

oSection := TRSection():New(oReport, STR0001, "GQP", /*{Array com as ordens do relat�rio}*/, /*Campos do SX3*/, /*Campos do SIX*/) //#Vales de Funcion�rios
oSection:SetTotalInLine(.F.)

// Campos que ser�o demonstrados no relat�rio
TRCell():New(oSection, "GQP_CODIGO", "GQP", STR0004, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #N�mero do Vale
TRCell():New(oSection, "GQP_CODFUN", "GQP", STR0005, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #C�digo do Funcion�rio
TRCell():New(oSection, "GQP_DESCFU", "GQP", STR0006, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #Nome do Funcion�rio
TRCell():New(oSection, "GQP_CODAGE", "GQP", STR0014, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #C�digo da Ag�ncia
TRCell():New(oSection, "GQP_DESCAG", "GQP", STR0015, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #Descri��o da Ag�ncia
TRCell():New(oSection, "GQP_TIPO"  , "GQP", STR0007, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #Tipo
TRCell():New(oSection, "GQP_DESFIN", "GQP", STR0008, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #Descri��o do Vale
TRCell():New(oSection, "GQP_EMISSA", "GQP", STR0010, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #Data de Emiss�o
TRCell():New(oSection, "GQP_VIGENC", "GQP", STR0009, /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/) // #Data de Vig�ncia
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

@author	Renan Ribeiro Brando -  Inova��o
@since	08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport, cAliasGQP)
Local oSection    := oReport:Section(1)
Local cParam1     := cValToChar(MV_PAR01) // Somente vales baixados?
Local cParam2     := cValToChar(MV_PAR02) // Tipos de vale de?
Local cParam3     := cValToChar(MV_PAR03) // Tipos de vale at�?
Local cParam4     := cValToChar(MV_PAR04) // Funcion�rios de?
Local cParam5     := cValToChar(MV_PAR05) // Funcion�rios at�?
Local cParam6     := DTOS(MV_PAR06) // Data de vig�ncia de?
Local cParam7     := DTOS(MV_PAR07) // Data de vig�ncia at�?

//---------------------------------------
// Query do relat�rio da secao 1
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
