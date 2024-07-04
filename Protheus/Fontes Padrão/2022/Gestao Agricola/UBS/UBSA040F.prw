#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'ubsa040.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} UBSA040F(oFolder)
Carrega reservas do lote
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function UBSA040F(oFolder)

    Local oBrowse as object
    Local cFiltro as char

    cFiltro := "NLP_FILIAL == NP9->NP9_FILIAL .and. NLP_LOTE == NP9->NP9_LOTE .and. NLP_CODSAF == NP9->NP9_CODSAF" 
    
    If TableInDic('NLP')

        oFolder:AddItem(STR0038, .T.) // 'Reservas'

        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias('NLP')
        oBrowse:SetDescription(STR0038) // 'Reservas'
        oBrowse:DisableDetails()
        oBrowse:SetFilterDefault(cFiltro)
        oBrowse:AddButton(STR0040,{||UBSA040FCT()},,2)// Vis. Contrato

        oBrowse:AddLegend("NLP_TSI == '1'", 'RED', STR0036) // 'Necessita TSI'
        oBrowse:AddLegend("NLP_TSI == '2'", 'GREEN', STR0037) // 'TSI Realizado'

        oBrowse:Activate(oFolder:aDialogs[Len(oFolder:aDialogs)]) //passo a sequência correta do dialog (sempre o último item)
        
    EndIf

Return oFolder

//-------------------------------------------------------------------
/*/{Protheus.doc} Function UBSA040FCT()
Função para visualização do contrato de parceria da reserva
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function UBSA040FCT()

    Private aRotina as array
    Private cCadastro as char

    cCadastro := STR0039 // Contrato de Parceria - Venda
    aRotina := StaticCall(FATA400, MenuDef)

    DbSelectArea('ADA')
    ADA->(DbSetOrder(1))

    If ADA->(DbSeek(NLP->NLP_FILIAL + NLP->NLP_NUMCTR))
        Ft400Alter('ADA',ADA->(Recno()), 2)
    EndIf

Return