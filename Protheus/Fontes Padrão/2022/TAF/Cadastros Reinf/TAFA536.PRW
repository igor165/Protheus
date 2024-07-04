#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA536.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} TAFA536
Cadastro MVC SCP

@author Katielly Rezende
@since 21/06/2019
@version 1.0
*/

Function TAFA536

    MsgInfo("Prezado cliente, esta rotina estará disponível após a liberação da REINF 2.0","Aviso - REINF")


/*    
If TAFAlsInDic("V3X")   
    BrowseDef()  
Else
    Aviso( STR0001, STR0002, { STR0005 }, 3 )  //AVISO   
EndIf
*/
Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} browsedef
Browse Pagamentos das Parcelas da fatura/recibo 

@author Henrique Pereira			
@since 11/06/2019
@version 1.0
/*/
/*
Static Function BrowseDef()

Local oBrw := FWMBrowse():New()

DBSelectArea("V3X")
DbSetOrder(1)

oBrw:SetDescription(STR0003) //Sociedade em Conta de Participação
oBrw:SetAlias( 'V3X' ) 
oBrw:SetMenuDef( 'TAFA536' )
oBrw:Activate()

Return oBrw
*/
//-------------------------------------------------------------------
 /*{Protheus.doc} MENUDEF
Funcao generica MVC com as opcoes de menu

@author Katielly Rezende        
@since 21/06/2019
@version 1.0
*/
/*
Static Function MenuDef()
Local aRotina   := {}

aRotina := xFunMnuTAF("TAFA536")

Return( aRotina )
*/
//-------------------------------------------------------------------
 /*{Protheus.doc} ModelDef
Funcao generica MVC do model
@author Katielly Rezende
@since 21/06/2019
@version 1.0
*/
/*
Static Function ModelDef()
Local oStruV3X   := FWFormStruct( 1, 'V3X' )
Local oStruV3Y   := FWFormStruct( 1, 'V3Y' )
Local oModel 	 := MPFormModel():New( 'TAFA536')

oModel:AddFields('MODEL_V3X',, oStruV3X)
oModel:AddGrid('MODEL_V3Y', 'MODEL_V3X', oStruV3Y) 

oModel:GetModel('MODEL_V3X'):SetPrimaryKey( { "V3X_CNPJ" } )
oModel:GetModel('MODEL_V3Y'):SetOptional( .F. )
oModel:GetModel('MODEL_V3Y'):SetUniqueLine( {'V3Y_IDPART'} )

oModel:SetRelation('MODEL_V3Y', { { 'V3Y_FILIAL', 'xFilial( "V3Y" )' } , { 'V3Y_ID' , "V3X_ID" } }, V3Y->( IndexKey( 1 ) ) )

Return (oModel)
*/
//-------------------------------------------------------------------
 /*{Protheus.doc} ViewDef
Funcao generica MVC do View
@author Katielly Rezende
@since 21/06/2019
@version 1.0
*/
/*
Static Function ViewDef()
Local oModel    := FWLoadModel('TAFA536')
Local oStruV3X  := FWFormStruct(2, 'V3X')
Local oStruV3Y 	:= FWFormStruct(2, 'V3Y' )
Local oView     := FWFormView():New()

oStruV3X:RemoveField('V3X_ID')
oStruV3Y:RemoveField('V3Y_ID')
oStruV3Y:RemoveField('V3Y_IDPART')

oView:SetModel(oModel)
oView:AddField              ('VIEW_V3X', oStruV3X, 'MODEL_V3X')
oView:CreateHorizontalBox   ('PAINEL_SUPERIOR', 25 )
oView:CreateFolder          ("FOLDER_SUPERIOR" , "PAINEL_SUPERIOR"     )
oView:AddSheet              ("FOLDER_SUPERIOR" , "ABA01", "SCP"      ) 

oView:AddGrid               ('VIEW_V3Y', oStruV3Y, 'MODEL_V3Y')
oView:EnableTitleView       ("VIEW_V3Y", STR0004) //PARTICIPANTES
oView:CreateHorizontalBox   ("GRIDV3Y" , 65                  ) 
oView:CreateFolder          ("FOLDER1" , "PAINEL_SUPERIOR"   )

oView:SetOwnerView("VIEW_V3X", "PAINEL_SUPERIOR" )
oView:SetOwnerView("VIEW_V3Y", "GRIDV3Y")

Return(oView)
*/
//--------------------------------------------------
 /*{Protheus.doc} SaveModel
Salva o modelo
@author Katielly Rezende
@since 21/06/2019
@version 1.0
*/
/*
Static Function SaveModel(oModel)
FWFormCommit( oModel )
return .t.

Function TAFVld()
Local cCNPJ := M->V3X_CNPJ
Local lOk   := .F.

If CGC(M->V3X_CNPJ)   
    DBSelectArea("V3X")
    DbSetOrder(2)
    If DBSeek(xFilial("V3X") + cCNPJ)
        Help("",1,"Help","Help",STR0006, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0007}) // "Informe outro CNPJ" / "CNPJ já cadastrado na base de dados"
        lOk := .F.
    Else
        lOk := .T.   
    EndIf
EndIf

Return lOk
*/
