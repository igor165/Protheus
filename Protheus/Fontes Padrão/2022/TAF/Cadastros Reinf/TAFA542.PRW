#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA542.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} TAFA542
Cadastro MVC Pagamentos a Beneficiários não identificados

@author Katielly Rezende
@since 24/07/2019
@version 1.0
*/
Function TAFA542

	MsgInfo("Prezado cliente, esta rotina estará disponível após a liberação da REINF 2.0","Aviso - REINF")
    
/* If TAFAlsInDic("V4K")   
    BrowseDef()  
Else
    Aviso( STR0001, STR0002, { STR0004 }, 3 ) // Aviso / "O ambiente do TAF encontra-se desatualizado. Para utilização desta funcionalidade, será necessário aplicar o dicionário de dados do REINF 2.0."                                                                                                                                                                                                                                                                                                                                                                    
EndIf
*/
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} browsedef
Browse Pagamentos beneficiarios não identificados

@author Katielly Feitosa			
@since 24/07/2019
@version 1.0
/*/
/* Static Function BrowseDef()

Local oBrw := FWMBrowse():New()

DBSelectArea("V4K")
DbSetOrder(1)

oBrw:SetDescription(STR0003) //Pagamentos a beneficiários não identificados
oBrw:SetAlias( 'V4K' ) 
oBrw:SetMenuDef( 'TAFA542' )
oBrw:Activate()

Return oBrw
 */
//-------------------------------------------------------------------
 /*{Protheus.doc} MENUDEF
Funcao generica MVC com as opcoes de menu

@author Katielly Rezende        
@since 24/07/2019
@version 1.0
*/
/* Static Function MenuDef()
Local aRotina   := {}

aRotina := xFunMnuTAF("TAFA542")

Return( aRotina )
 */
//-------------------------------------------------------------------
 /*{Protheus.doc} ModelDef
Funcao generica MVC do model

@author Katielly Rezende
@since 24/07/2019
@version 1.0
*/

/* Static Function ModelDef()
Local oStruV4K   := FWFormStruct( 1, 'V4K' )
Local oModel 	 := MPFormModel():new("TAFA542",,,{|oModel| SaveModel( oModel ) })

oModel:AddFields('MODEL_V4K',, oStruV4K)
oModel:GetModel('MODEL_V4K'):SetPrimaryKey( { "V4K_FILIAL" , "V4K_CODDOC" , "V4K_NATREN" , "V4K_DTPAG" } )

Return (oModel)
 */
//-------------------------------------------------------------------
 /*{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Katielly Rezende
@since 24/07/2019
@version 1.0
*/

/* Static Function ViewDef()
Local oModel    := FWLoadModel('TAFA542')
Local oStruV4K  := FWFormStruct(2, 'V4K')
Local oView     := FWFormView():New()

oStruV4K:RemoveField('V4K_ID')

oView:SetModel( oModel )
oView:AddField( 'VIEW_V4K', oStruV4K, 'MODEL_V4K' )
oView:CreateHorizontalBox( 'FIELDV4K', 100 )
oView:SetOwnerView( 'VIEW_V4K', 'FIELDV4K' )

Return(oView)
 */
//--------------------------------------------------
 /*{Protheus.doc} SaveModel
Salva o modelo
@author Katielly Rezende
@since 24/07/2019
@version 1.0
*/

/* Static Function SaveModel(oModel)
FWFormCommit( oModel )
return .T. */