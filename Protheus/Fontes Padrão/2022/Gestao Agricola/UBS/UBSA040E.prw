#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'ubsa040.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} UBSA040B(oFolder)
Descartes do lote
@author  Lucas Briesemeister
@since   12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function UBSA040E(oFolder)

    Local cQuery as char

    cQuery := GetDataQuery()

    SetupBrw(cQuery, oFolder)

Return oFolder
//-------------------------------------------------------------------
/*/{Protheus.doc} GetDataQuery()
Retorna query que será utilizada pelo browse de descartes
@author  Lucas Briesemeister
@since   12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function GetDataQuery()

    Local cQuery as char

    BeginContent Var cQuery
        SELECT
            SD3.D3_EMISSAO,
            SD3.D3_COD AS PROD_ORIG,
            SD3.D3_LOTECTL AS LOTE_ORIG,
            SD3.D3_LOCAL AS LOCAL_ORIG,
            SD3.D3_UM AS UM_ORIG,
            SD3.D3_QUANT AS QUANT_ORIG,
            SD31.D3_COD AS PROD_DEST,
            SD31.D3_LOTECTL AS LOTE_DEST,
            SD31.D3_LOCAL AS LOCAL_DEST,
            SD31.D3_UM AS UM_DEST,
            SD31.D3_QUANT AS QUANT_DEST

        FROM %Exp:RetSqlName("SD3")% SD3

        INNER JOIN %Exp:RetSqlName("SD3")% SD31 ON SD3.D3_FILIAL = SD31.D3_FILIAL
            AND SD3.D3_NUMSEQ = SD31.D3_NUMSEQ
            AND SD3.D_E_L_E_T_ = SD31.D_E_L_E_T_

        WHERE SD3.D_E_L_E_T_ = ''
            AND SD3.D3_FILIAL = %Exp:UBSA040DSQ(xFilial("SD3"))%
            AND SD3.D3_LOTECTL = %Exp:UBSA040DSQ(NP9->NP9_LOTE)%
            AND SD3.D3_FATHER = 'F'
            AND SD3.D3_TM = '999'
            AND SD31.D3_TM = '499'

    EndContent

Return cQuery
//-------------------------------------------------------------------
/*/{Protheus.doc} SetupBrw(cQuery, oFolder)
Realiza a contrução do browse da tela de descartes
@author  Lucas Briesemeister
@since   12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function SetupBrw(cQuery, oFolder)

    Local oBrowse as object
    Local aColumns as array
    Local cAliasBRW as char

    cAliasBRW := GetNextAlias()
    aColumns := GetColumns(cAliasBRW)
    aFilter := UBSA040DFL(aColumns)

    oFolder:AddItem(STR0021, .T.)

    oBrowse := FWFormBrowse():New()
    oBrowse:SetDescription(STR0021)//Descartes
    oBrowse:DisableDetails()
    oBrowse:SetDataQuery(.T.)
    oBrowse:SetTemporary(.T.)
    oBrowse:SetQuery(cQuery)
    oBrowse:SetAlias(cAliasBrw)
    oBrowse:SetColumns(aColumns)
    oBrowse:SetUseFilter(.T.)
    oBrowse:SetFieldFilter(aFilter)
    oBrowse:Activate(oFolder:aDialogs[Len(oFolder:aDialogs)])

Return oFolder
//-------------------------------------------------------------------
/*/{Protheus.doc} GetColumns(cAliasBRW)
Retorna colunas para o browse de descartes
@author  Lucas Briesemeister
@since   12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function GetColumns(cAliasBRW)

    Local aColumns as array
    Local oColumn as object

    aColumns := {}
    oColumn := FWBrwColumn():New()
    oColumn:SetType(TamSx3('D3_EMISSAO')[3])
    oColumn:SetData({|| SToD((cAliasBRW)->D3_EMISSAO) })
    oColumn:SetTitle(STR0022)// Dt. Descarte
    oColumn:SetPicture(PesqPict("SD3", "D3_EMISSAO"))
    oColumn:SetSize(TamSx3('D3_EMISSAO')[1])

    Aadd(aColumns, oColumn)
    //--------------- PRODUTO ORIGEM -----------------
    oColumn := FWBrwColumn():New()
    oColumn:SetType(TamSx3('D3_COD')[3])
    oColumn:SetData({|| (cAliasBRW)->PROD_ORIG })
    oColumn:SetTitle(STR0023)// Produto. Orig.
    oColumn:SetPicture(PesqPict("SD3", "D3_COD"))
    oColumn:SetSize(TamSx3('D3_COD')[1])

    Aadd(aColumns, oColumn)

    oColumn := FWBrwColumn():New()
    oColumn:SetType(TamSx3('D3_LOTECTL')[3])
    oColumn:SetData({|| (cAliasBRW)->LOTE_ORIG })
    oColumn:SetTitle(STR0024)// 'Lote Orig.'
    oColumn:SetPicture(PesqPict("SD3", "D3_LOTECTL"))
    oColumn:SetSize(TamSx3('D3_LOTECTL')[1])
    
    Aadd(aColumns, oColumn)

    oColumn := FWBrwColumn():New()
    oColumn:SetType(TamSx3('D3_LOCAL')[3])
    oColumn:SetData({|| (cAliasBRW)->LOCAL_ORIG })
    oColumn:SetTitle(STR0025)// 'Local Orig.'
    oColumn:SetPicture(PesqPict("SD3", "D3_LOCAL"))
    oColumn:SetSize(TamSx3('D3_LOCAL')[1])

    Aadd(aColumns, oColumn)

    oColumn := FWBrwColumn():New()
    oColumn:SetType(TamSx3('D3_UM')[3])
    oColumn:SetData({|| (cAliasBRW)->UM_ORIG })
    oColumn:SetTitle(STR0026)// 'UM Orig.'
    oColumn:SetPicture(PesqPict("SD3", "D3_UM"))
    oColumn:SetSize(TamSx3('D3_UM')[1])

    Aadd(aColumns, oColumn)

    oColumn := FWBrwColumn():New()
    oColumn:SetType(TamSx3('D3_QUANT')[3])
    oColumn:SetData({|| (cAliasBRW)->QUANT_ORIG })
    oColumn:SetTitle(STR0027)// 'Quant. Orig.'
    oColumn:SetPicture(PesqPict("SD3", "D3_QUANT"))
    oColumn:SetSize(TamSx3('D3_QUANT')[1])

    Aadd(aColumns, oColumn)
    //--------------- PRODUTO DESTINO -----------------
    oColumn := FWBrwColumn():New()
    oColumn:SetType(TamSx3('D3_COD')[3])
    oColumn:SetData({|| (cAliasBRW)->PROD_DEST })
    oColumn:SetTitle(STR0028)// 'Produto Dest.'
    oColumn:SetPicture(PesqPict("SD3", "D3_COD"))
    oColumn:SetSize(TamSx3('D3_COD')[1])

    Aadd(aColumns, oColumn)

    oColumn := FWBrwColumn():New()
    oColumn:SetType(TamSx3('D3_LOTECTL')[3])
    oColumn:SetData({|| (cAliasBRW)->LOTE_DEST })
    oColumn:SetTitle(STR0029)// 'Lote Dest.'
    oColumn:SetPicture(PesqPict("SD3", "D3_LOTECTL"))
    oColumn:SetSize(TamSx3('D3_LOTECTL')[1])

    Aadd(aColumns, oColumn)

    oColumn := FWBrwColumn():New()
    oColumn:SetType(TamSx3('D3_LOCAL')[3])
    oColumn:SetData({|| (cAliasBRW)->LOCAL_DEST })
    oColumn:SetTitle(STR0030)// 'Local Dest.'
    oColumn:SetPicture(PesqPict("SD3", "D3_LOCAL"))
    oColumn:SetSize(TamSx3('D3_LOCAL')[1])

    Aadd(aColumns, oColumn)

    oColumn := FWBrwColumn():New()
    oColumn:SetType(TamSx3('D3_UM')[3])
    oColumn:SetData({|| (cAliasBRW)->UM_DEST })
    oColumn:SetTitle(STR0031)// 'UM Dest.'
    oColumn:SetPicture(PesqPict("SD3", "D3_UM"))
    oColumn:SetSize(TamSx3('D3_UM')[1])

    Aadd(aColumns, oColumn)

    oColumn := FWBrwColumn():New()
    oColumn:SetType(TamSx3('D3_QUANT')[3])
    oColumn:SetData({|| (cAliasBRW)->QUANT_DEST })
    oColumn:SetTitle(STR0032)// 'Quant. Dest.'
    oColumn:SetPicture(PesqPict("SD3", "D3_QUANT"))
    oColumn:SetSize(TamSx3('D3_QUANT')[1])

    Aadd(aColumns, oColumn)

Return aColumns