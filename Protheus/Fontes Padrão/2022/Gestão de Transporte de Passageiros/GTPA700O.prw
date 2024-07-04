#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} GTPA700O
(long_description)
@type  Function
@author user
@since 05/07/2022
@version version
@param , param_type, param_descr
@return , return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA700O( )
Local oModel    := NIL
Local oFieldH65	:= NIL
Local cBloque   := ''

    If AliasInDic("H65")
        oModel    := FWLoadModel("GTPA423")
        oFieldH65 := oModel:GetModel('H65MASTER')
        H65->(DBSETORDER(2))
        If !(H65->(DBSEEK(XFILIAL("H65") + G6T->G6T_AGENCI)))
            oModel:SetOperation(MODEL_OPERATION_INSERT)
            
            oModel:Activate()
            oFieldH65:SetValue("H65_AGENCI",G6T->G6T_AGENCI)
            oFieldH65:SetValue("H65_DESAGE",POSICIONE("GI6",1,xFilial('GI6')+ G6T->G6T_AGENCI,'GI6_DESCRI'))
            oFieldH65:SetValue("H65_ORIGEM","GTPA700")
            
            FWExecView('', 'VIEWDEF.GTPA423', MODEL_OPERATION_INSERT, , {|| .T. },,,,{|| GTP700Fech()},,,oModel)
        Else
            oModel:SetOperation(MODEL_OPERATION_UPDATE)
            
            oModel:Activate()
            oFieldH65:SetValue("H65_DATABR",DATE())
            oFieldH65:SetValue("H65_HORABR",SUBSTR(TIME(), 1, 2) + SUBSTR(TIME(), 4, 2))
            oFieldH65:SetValue("H65_ORIGEM","GTPA700")
            
            FWExecView('', 'VIEWDEF.GTPA423', MODEL_OPERATION_UPDATE, , {|| .T. },,,,{|| GTP700Fech()},,,oModel)
        EndIf

        H65->(DBSETORDER(2))
        If H65->(DBSEEK(XFILIAL("H65") + G6T->G6T_AGENCI))
            cBloque := H65->H65_BLOQUE
        EndIf

        If GI6->(FieldPos("GI6_BLOQUE")) > 0
            GI6->(DbSetOrder(1))
            If GI6->(DBSEEK(XFILIAL("GI6") + G6T->G6T_AGENCI))
                RecLock("GI6",.F.)
                GI6->GI6_BLOQUE := cBloque
                GI6->( MsUnlock() )
            EndIf
        EndIf
    Else
        FwAlertHelp("Dicionário desatualizado", "Atualize o dicionário para utilizar esta rotina",)
    EndIf
Return 

/*/{Protheus.doc} GTP700Fech()
 * Inclui o campo fechar 
 * type  Static Function
 * author Eduardo Ferreira
 * since 03/07/2020
 * version 12.1.30
 * param não há
 * return .T.
/*/
Static Function GTP700Fech() 
Local oView	:= FwViewActive()
		
oView:SetModified(.F.)
	
Return .T.
