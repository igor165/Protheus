#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE CAMPO   01
#DEFINE TIPO    02
#DEFINE TAMANHO 03
#DEFINE DECIMAL 04

Static Function MenuDef()

	Local aRotina := {}
	ADD OPTION aRotina Title 'Detalhar'  Action 'CnDetCriAgr(oTmpTab)'	OPERATION 2 ACCESS 0

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenCritAgr

Exibe um Mark Browse com as críticas agrupadas por código e descrição

@author vinicius.nicolau
@since 15/06/2020
/*/
//--------------------------------------------------------------------------------------------------
Function CenMrkAgr(cWhere)

	Local oTela := CenCritAgr():New()
    Default cWhere := " AND B3F_CODCRI LIKE 'E%' AND B3F_ORICRI IN ('B3K','B3W') "

	oTela:setTitulo("Criticas de Espelho Agrupadas")
	oTela:setRotina("CenMrkAgr")
	oTela:setWhere(cWhere)

	CenBrwAgr(oTela)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenDetCriAgr

Exibe um browse com as o detalhes da crítica selecionada

@author vinicius.nicolau
@since 15/06/2020
/*/
//--------------------------------------------------------------------------------------------------
Function CnDetCriAgr(oTmpTab)

	Local oBrw := Nil
	Local cFiltro := " B3F_FILIAL = '" + xFilial( 'B3F' ) + "' .AND. " +;
			   " B3F_CODCRI = '" + (oTmpTab:getAlias())->B3F_CODCRI + "' "
	
	Default lAuto := .F.

	If(!IsBlind())
		oBrw := CnMBRWCrit(cFiltro)
	EndIf		

Return oBrw