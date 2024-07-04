#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'ubsa040.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} UBSA040B(oFolder)
Carrega a aba de histórico do lote
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
@type function
/*/
//-------------------------------------------------------------------
Function UBSA040B(oFolder)

    Local oBrowse as object
    Local cFiltro as char
    Local nPosLote := TamSx3("NP9_FILIAL")[1] + TamSx3("NP9_CODSAF")[1] + TamSx3("NP9_PROD")[1] + 1 //posição de inicio do lote no filtro

    cFiltro := "NK9_TABLE = 'NP9' .And. SubStr(NK9_CHAVE, 1, Len(NP9->NP9_FILIAL)) == NP9->NP9_FILIAL .and. SubStr(NK9_CHAVE, "+ cValToChar(nPosLote) +", Len(NP9->NP9_LOTE)) == NP9->NP9_LOTE " 
    
    oFolder:AddItem(STR0007, .T.)

    DbSelectArea("NK9")
    If TableInDic('N72')
        NK9->(DbSetOrder(3)) //ordenar por data e hora de inclusão do histórico
    EndIf  

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('NK9')
    oBrowse:SetDescription(STR0007)
    oBrowse:DisableDetails()
    oBrowse:SetColumns(GetColumns())
    oBrowse:SetFilterDefault(cFiltro)

    oBrowse:Activate(oFolder:aDialogs[Len(oFolder:aDialogs)]) //passo a sequência correta do dialog (sempre o último item)

Return oFolder
//-------------------------------------------------------------------
/*/{Protheus.doc} GetColumns()
Retorna colunas extras para o browse de histórico
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
@type function
/*/
//-------------------------------------------------------------------
Static Function GetColumns()

    Local aColumns as array
    Local oColumn as object
    Local nPosProd := TamSx3("NP9_FILIAL")[1] + TamSx3("NP9_CODSAF")[1] + 1 //posição de inicio do produto na NK9_CHAVE

    aColumns := {}

	oColumn := FWBrwColumn():New()
	oColumn:SetType(TamSx3("NP9_PROD")[3])
	oColumn:SetData({|| SubStr(NK9_CHAVE, nPosProd, Len(NP9->NP9_PROD)) })
	oColumn:SetTitle(FWX3Titulo("NP9_PROD"))
	oColumn:SetSize(TamSx3("NP9_PROD")[1])

	aAdd(aColumns, oColumn)

Return aColumns
