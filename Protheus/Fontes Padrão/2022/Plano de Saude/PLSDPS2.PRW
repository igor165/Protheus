#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSDPS2.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSDPS2
Tela de detalhe das notas.
@since  02/2021
//-------------------------------------------------------------------*/
function PLSDPS2(lAutoma)
local cFiltro   := "@(BQ3_FILIAL = '" + xFilial("BQ3") + "' AND BQ3_CODOPE = '" + BQ2->BQ2_CODOPE + "' AND BQ3_CODSEQ = '" + BQ2->BQ2_CODSEQ + "')"  
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	 

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('BQ3')
oBrowse:SetFilterDefault(cFiltro)
oBrowse:SetMenuDef('PLSDPS2')
oBrowse:SetDescription(STR0001) //Declaração do Plano de Saúde - Detalhes
iif(!lAutoma, oBrowse:Activate(), '')
return 


/*//-------------------------------------------------------------------
{Protheus.doc} MenuDef
MenuDef
@since    01/2020
//-------------------------------------------------------------------*/
static function MenuDef()
Local aRotina := {}

//Add Option aRotina Title STR0003 Action 'VIEWDEF.PLSDPS2' Operation 3 Access 0 //'Incluir'
Add Option aRotina Title STR0005 Action 'VIEWDEF.PLSDPS2' Operation 2 Access 0 //'Visualizar'
Add Option aRotina Title STR0004 Action 'VIEWDEF.PLSDPS2' Operation 4 Access 0 //'Alterar'
return aRotina


/*//-------------------------------------------------------------------
{Protheus.doc} ModelDef
ModelDef
@since    01/2020
//-------------------------------------------------------------------*/
Static function ModelDef()
Local oModel    := nil     
Local oStrBQ3   := FWFormStruct(1,'BQ3')

oModel := MPFormModel():New('PLSDPS2', ,  { || PLSCADOK(oModel) } )

oModel:addFields('MASTERBQ3',,oStrBQ3) 

oStrBQ3:setProperty( "BQ3_CODSEQ", MODEL_FIELD_INIT, { || BQ2->BQ2_CODSEQ} )
oStrBQ3:setProperty( "BQ3_INCIDE", MODEL_FIELD_INIT, { || BQ2->BQ2_INCIDE} )
oStrBQ3:setProperty( "BQ3_SITDOC" , MODEL_FIELD_WHEN , 	{|| .t.} ) //liberar apenas status, para usuário alterar
oStrBQ3:SetProperty( "BQ3_SITDOC" , MODEL_FIELD_VALID,  { || !empty(oModel:getmodel('MASTERBQ3'):getValue("BQ3_SITDOC"))} )

oModel:GetModel('MASTERBQ3'):SetDescription(STR0001) //Declaração do Plano de Saúde - Detalhes
return oModel


/*//-------------------------------------------------------------------
{Protheus.doc} ViewDef
ViewDef
@since    01/2020
//-------------------------------------------------------------------*/
Static function ViewDef()
Local oView     := nil
Local oModel  	:= FWLoadModel( 'PLSDPS2' )
Local oStrBQ3   := FWFormStruct(2, 'BQ3' )

oView := FWFormView():New()
oView:SetModel(oModel)

//oStrBQ3:SetProperty( '*' , MVC_VIEW_CANCHANGE, .f. ) 

oView:AddField('ViewBQ3' , oStrBQ3,'MASTERBQ3' )

oView:CreateHorizontalBox( 'SUPERIOR' , 100 )

oView:SetOwnerView('ViewBQ3','SUPERIOR')

oView:SetCloseOnOK( { || .t. } )

oView:setUpdateMessage(STR0007, STR0006) //Atenção - Status do item alterado manualmente. Mude o status do lote, caso necessário.

oView:SetDescription(STR0001) //Declaração do Plano de Saúde - Detalhes
oView:EnableTitleView('ViewBQ3',STR0002) //Detalhes da NFS-e / NFTS

return oView


/*//-------------------------------------------------------------------
{Protheus.doc} PLSCADOK
Verifica se o campo status foi alterado.
@since   03/2021
//-------------------------------------------------------------------*/
Static Function PLSCADOK(oModel)
local lRet      := .t.
local cMensagem := ""
local oViewTel  := FWViewActive()
local lExsView  := iif( valtype(oViewTel) == "U" .or. !oViewTel:isActive(), .f., .t. )

if ( lExsView .and. oModel:GetOperation() == MODEL_OPERATION_UPDATE .and. oModel:getmodel('MASTERBQ3'):IsFieldUpdated("BQ3_SITDOC") )
    //Valor Antigo: - Valor Novo:
    cMensagem := BQ3->(BQ3_NUMDOC+BQ3_SERIE) + " - " + BQ3->(BQ3_FORNEC+BQ3_LOJA) + " - " + STR0009 + RetcBox("BQ3_SITDOC", BQ3->BQ3_SITDOC) +;
                 STR0008 + RetcBox("BQ3_SITDOC", oModel:getmodel('MASTERBQ3'):getvalue("BQ3_SITDOC"))
    PlAtuBQ4(BQ3->BQ3_CODSEQ, BQ3->BQ3_CODOPE, .t., "M003", STR0006 + CRLF + cMensagem)
endif

return lRet
