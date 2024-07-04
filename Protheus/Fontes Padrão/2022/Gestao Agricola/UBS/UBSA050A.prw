#include 'totvs.ch'
#include 'ubsa050.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} Function UBSA050A()
Painel de reservas do contrato dos contratos de parceri
@author  Lucas Briesemeister    
@since   01/2021
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function UBSA050A()

    Local oBrowse as object

    If !TableInDic('NLP')
        // necess�rio a atualiza��o do sistema para a expedi��o mais recente
        MsgNextRel()
    Else
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias('NLP')
        oBrowse:SetDescription(STR0001)
        oBrowse:AddButton(STR0002,{||UBSA050LOT()},,3)// Vincular lotes
        oBrowse:AddButton('Gera��o TSI',{||UBSA050TSI()},,3)// Vincular lotes

        oBrowse:AddLegend("NLP_TSI == '2'", 'RED', STR0003)
        oBrowse:AddLegend("NLP_TSI == '1'", 'GREEN', STR0004)

        oBrowse:Activate()
    EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Function UBSA050LOT()
Fun��o que abre a tela de sele��o de lotes para a reserva
@author  Lucas Briesemeister    
@since   01/2021
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function UBSA050LOT()

    DBSelectArea('ADA')
    ADA->(DBSetOrder(1))

    If ADA->(DBSeek(NLP->NLP_FILIAL + NLP->NLP_NUMCTR))
        UBSA050(,,NLP->NLP_CODPRO, NLP->NLP_LOCAL, NLP->NLP_ITEM)
    EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Function UBSA050LOT()
Fun��o que abre a tela de sele��o de lotes para a reserva
@author  Lucas Briesemeister    
@since   01/2021
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function UBSA050TSI()

    Local cMovsAx as char

    Private cTm	as char
    Private cMovsai as char

    cMovsAx := Alltrim(GetMv("MV_AGRSD3S"))
    cMovsai	:= cMovsAx+Space(Len(SF5->F5_CODIGO)-Len(cMovsAx))

    cTm := GetMv("MV_AGRTMPS")

    If NLP->NLP_TSI == '2'

        DbSelectArea('NP9')
        NP9->(DbSetOrder(1))

        If NP9->(DbSeek(NLP->NLP_FILIAL+NLP->NLP_CODSAF+NLP->NLP_CODPRO+NLP->NLP_LOTE))    
            AGR840TSI()
        Else        
            MsgInfo(STR0005,STR0006) // 'Lote n�o encontrado', 'Gera��o TSI'
        EndIf   

    Else
        MsgInfo(STR0007,STR0006)// 'Produto j� tratado','Gera��o TSI'
    EndIf

Return