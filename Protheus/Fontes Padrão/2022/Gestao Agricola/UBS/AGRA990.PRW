#INCLUDE "AGRA990.CH"
#include "protheus.ch"
#include "fwmvcdef.ch"
/*
+=================================================================================================+
| Progama   : AGRA990                                                                             |
| Descrição : Cadastramento de tipos de tratamentos da semente                                    |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 25/05/2015                                                                          |
+=================================================================================================+ 
*/ 
Function AGRA990()   
Local oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias('NKD')
oMBrowse:SetDescription(AGRSX2NOME("NKD"))
oMBrowse:DisableDetails()
oMBrowse:Activate()
Return (Nil)

/*
+=================================================================================================+
| Função    : ModelDef                                                                            |
| Descrição : Prepara model                                                                       |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 25/05/2015                                                                          |
+=================================================================================================+ 
*/       
Static Function ModelDef()
Local oModel   := Nil
Local oStruNKD := FwFormStruct( 1, "NKD" )

// Instancia o modelo de dados
oModel := MpFormModel():New( 'AGRA990')

// identificador (ID) dado ao componente.
oModel:AddFields("NKDMASTER",Nil,oStruNKD)

//Adicionamos a descrição dos componentes do modelo de dados: 
oModel:GetModel('NKDMASTER'):SetDescription(AGRSX2NOME("NKD"))

Return (oModel)

/*
+=================================================================================================+
| Função    : ViewDef                                                                             |
| Descrição : Prepara Viewmodel                                                                   |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 25/05/2015                                                                          |
+=================================================================================================+ 
*/   
Static Function ViewDef()
Local oView	  := Nil
Local oModel	  := FwLoadModel("AGRA990")
Local oStruNPE := FwFormStruct(2,"NKD") 
               
// Instancia a View
oView := FwFormView():New()

// Seta o modelo de dados
oView:SetModel( oModel )

// Adiciona os atributos da estrutura da view
oView:AddField( 'VIEW_NKD', oStruNPE, 'NKDMASTER' )

// Monta o box horizontal
oView:CreateHorizontalBox( 'TOTAL', 100 )

// Seta Owner da Interface
oView:SetOwnerView( 'VIEW_NKD', 'TOTAL' )

Return oView

/*
+=================================================================================================+
| Função    : MenuDef                                                                             |
| Descrição : Prepara model                                                                       |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 25/05/2015                                                                          |
+=================================================================================================+ 
*/   
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina Title OemToAnsi(STR0001) Action 'VIEWDEF.AGRA990' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title OemToAnsi(STR0002) Action 'VIEWDEF.AGRA990' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title OemToAnsi(STR0003) Action 'VIEWDEF.AGRA990' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title OemToAnsi(STR0004) Action 'VIEWDEF.AGRA990' OPERATION 5 ACCESS 0
Return(aRotina)