#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA538.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} TAFA539
Cadastro de Plano de saúde 

@author Katielly Rezende
@since 08/07/2019
@version 1.0
*/

Function TAFA538

	MsgInfo("Prezado cliente, esta rotina estará disponível após a liberação da REINF 2.0","Aviso - REINF")

/*    
If TAFAlsInDic("V4A")   
    BrowseDef()  
Else
    Aviso( STR0001, STR0002, { STR0003 }, 3 ) //AVISO //"O ambiente do TAF encontra-se desatualizado. Para utilização desta funcionalidade, será necessário aplicar o dicionário de dados do REINF 2.0."
EndIf
*/

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} browsedef
Browse

@author Katielly Rezende
@since 08/07/2019
@version 1.0
*/
/*
Static Function BrowseDef()

Local oBrw := FWMBrowse():New()

DBSelectArea("V4A")
DbSetOrder(1)

oBrw:SetDescription(STR0004) //"Plano de Saúde"
oBrw:SetAlias( 'V4A' ) 
oBrw:SetMenuDef( 'TAFA538' )
oBrw:Activate()

Return oBrw
*/
//-------------------------------------------------------------------
 /*{Protheus.doc} MENUDEF
Funcao generica MVC com as opcoes de menu

@author Katielly Rezende
@since 08/07/2019
@version 1.0
*/
/*
Static Function MenuDef()
Local aRotina   := {}

aRotina := xFunMnuTAF("TAFA538")

Return( aRotina )
*/
//-------------------------------------------------------------------
 /*{Protheus.doc} ModelDef
Funcao generica MVC do model
@author Katielly Rezende
@since 08/07/2019
@version 1.0
*/
/*
Static Function ModelDef()
Local oStruV4A   := FWFormStruct( 1, 'V4A' )
Local oModel 	 := MPFormModel():New( 'TAFA538')

oModel:AddFields('MODEL_V4A',, oStruV4A)
oModel:GetModel('MODEL_V4A'):SetPrimaryKey( { "V4A_CNPJ" } )

Return (oModel)
*/
//-------------------------------------------------------------------
 /*{Protheus.doc} ViewDef
Funcao generica MVC do View
@author Katielly Rezende
@since 08/07/2019
@version 1.0
*/
/*
Static Function ViewDef()
Local oModel    := FWLoadModel('TAFA538')
Local oStruV4A  := FWFormStruct(2, 'V4A')
Local oView     := FWFormView():New()

oStruV4A:RemoveField('V4A_ID')

oView:SetModel( oModel )
oView:AddField( 'VIEW_V4A', oStruV4A, 'MODEL_V4A' )
oView:EnableTitleView( 'VIEW_V4A', STR0004 ) //Plano de Saúde  
oView:CreateHorizontalBox( 'FIELDV4A', 100 )
oView:SetOwnerView( 'VIEW_V4A', 'FIELDV4A' )
    
Return(oView)
*/
//--------------------------------------------------
 /*{Protheus.doc} SaveModel
Salva o modelo
@author Katielly Rezende
@since 08/07/2019
@version 1.0
*/
/*
Static Function SaveModel(oModel)
FWFormCommit( oModel )
return .T.

Function TAFVldCNPJ()
Local cCNPJ := M->V4A_CNPJ
Local lOk   := .F.


If CGC(M->V4A_CNPJ)   
    DBSelectArea("V4A")
    DbSetOrder(2)
    If DBSeek(xFilial("V4A") + cCNPJ)
        Help("",1,"Help","Help",STR0005, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0006}) // "Informe outro CNPJ" / "CNPJ já cadastrado na base de dados"
        lOk := .F.
    Else
        lOk := .T.   
    EndIf
EndIf

IF lOK
    Begin Transaction
        If nOperation == MODEL_OPERATION_UPDATE
            TAFAltStat( "V4A", " " )
        EndIf
        If FwFormCommit( oModel )
            If FindFunction('TafEndGRV') 
                
                If TAFColumnPos("V4A_PRID40" )
                    TafEndGRV( "V4A","V4A_PRID40", '', V4A->(Recno())  )
                ENDIF
            EndIf
        EndIf
    End Transaction
EndIf

Return lOk 
*/