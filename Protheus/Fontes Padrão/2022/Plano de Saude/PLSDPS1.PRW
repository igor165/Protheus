#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSDPS1.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSDPS1
Tela inicial do Lote de DPS.
@since  02/2021
//-------------------------------------------------------------------*/
function PLSDPS1(lAutoma)
local cFiltro   := "@(BQ2_FILIAL = '" + xFilial("BQ2") + "') "
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	 

if PlVerTabDPS()
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('BQ2')
    oBrowse:SetFilterDefault(cFiltro)
    oBrowse:SetDescription(STR0001) //Declaração do Plano de Saúde - Incidências
    iif(!lAutoma, oBrowse:Activate(),  '')
endif
return 


/*//-------------------------------------------------------------------
{Protheus.doc} MenuDef
MenuDef
@since    02/2021
//-------------------------------------------------------------------*/
static function MenuDef()
Local aRotina := {}

Add Option aRotina Title STR0005 Action 'VIEWDEF.PLSDPS1' Operation 2 Access 0 //'Visualizar'
Add Option aRotina Title STR0004 Action 'VIEWDEF.PLSDPS1' Operation 4 Access 0 //'Alterar'
Add Option aRotina Title STR0006 Action 'PLSDPS2(.f.)' Operation 9 Access 0 //Selecionar
Add Option aRotina Title STR0010 Action 'staticCall(PLSDPS1, PergIniProc, .f.,{})' Operation 3 Access 0 //Processar...
Add Option aRotina Title STR0014 Action 'PergDPStxt(.f.,{})' Operation 9 Access 0 //Gerar DPS txt
Add Option aRotina Title STR0020 Action 'PLSDPS3(.f.)' Operation 9 Access 0 //Histórico

return aRotina


/*//-------------------------------------------------------------------
{Protheus.doc} ModelDef
ModelDef
@since    02/2021
//-------------------------------------------------------------------*/
Static function ModelDef()
Local oModel    := nil     
Local oStrBQ2   := FWFormStruct(1,'BQ2')

oModel := MPFormModel():New('PLSDPS1', ,  { || PLSCADOK(oModel) } )

oModel:addFields('MASTERBQ2',,oStrBQ2)

oStrBQ2:setProperty( "BQ2_TIPARQ" , MODEL_FIELD_WHEN , 	{ || .t.} ) //liberar apenas status, para usuário alterar
oStrBQ2:SetProperty( "BQ2_TIPARQ" , MODEL_FIELD_VALID,  { || !empty(oModel:getmodel('MASTERBQ2'):getValue("BQ2_TIPARQ"))} )

oModel:GetModel('MASTERBQ2'):SetDescription(STR0001) //Declaração do Plano de Saúde - Incidências
return oModel


/*//-------------------------------------------------------------------
{Protheus.doc} ViewDef
ViewDef
@since    02/2021
//-------------------------------------------------------------------*/
Static function ViewDef()
Local oView     := nil
Local oModel  	:= FWLoadModel( 'PLSDPS1' )
Local oStrBQ2   := FWFormStruct(2, 'BQ2' )

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('ViewBQ2' , oStrBQ2,'MASTERBQ2' )

oView:CreateHorizontalBox( 'SUPERIOR' , 100 )

oView:SetOwnerView('ViewBQ2','SUPERIOR')

oView:SetCloseOnOK( { || .t. } )
oView:setUpdateMessage(STR0011, STR0007) //Atenção - Status do Lote foi alterado. Lembre-se de alterar os itens também, caso necessário.

oView:SetDescription(STR0001) //Declaração do Plano de Saúde - Incidências
oView:EnableTitleView('ViewBQ2',STR0002) //Detalhes do Lote

return oView


/*//-------------------------------------------------------------------
{Protheus.doc} PLSCADOK
Verifica se o campo status foi alterado.
@since   02/2021
//-------------------------------------------------------------------*/
Static Function PLSCADOK(oModel)
local cMensagem := ""
local lRet      := .t.
local oViewTel  := FWViewActive()
local lExsView  := iif( valtype(oViewTel) == "U" .or. !oViewTel:isActive(), .f., .t. )

if ( lExsView .and. oModel:GetOperation() == MODEL_OPERATION_UPDATE .and. oModel:getmodel('MASTERBQ2'):IsFieldUpdated("BQ2_TIPARQ") )
    //Valor Antigo: - Valor Novo: 
    cMensagem := STR0022 + RetcBox("BQ2_TIPARQ", BQ2->BQ2_TIPARQ) + STR0021 + RetcBox("BQ2_TIPARQ", oModel:getmodel('MASTERBQ2'):getvalue("BQ2_TIPARQ"))
    PlAtuBQ4(BQ2->BQ2_CODSEQ, BQ2->BQ2_CODOPE, .t., "M002", STR0007 + CRLF + cMensagem)
endif

return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} PergIniProc
Grava histórico da ALTERAÇ
@since   02/2021
//-------------------------------------------------------------------*/
static function PergIniProc(lAuto, aDadAuto)
local aPergs 		:= {}
local aRetPerg		:= {}
local lExecuta		:= .t.
default lAuto		:= .f.
default aDadAuto	:= {}

aadd(aPergs,{ 1, STR0008, Space(6), "@R 99/9999",'PlDPSVldDt(MV_PAR01)',,'.t.',60,.t. } ) //"Incidência"
 
if lAuto
	aRetPerg := aDadAuto     
elseIf !paramBox( aPergs,STR0009,aRetPerg,,,.t.,,,,'PLSDPS1',.t.,.t. ) //"Informe a Incidência
	lExecuta := .f.
endIf

if lExecuta .and. !empty(aRetPerg[1])
    PLSDPSCnGr(.f., aRetPerg[1], PlsIntpad(), lAuto)
endif

return


/*//-------------------------------------------------------------------
{Protheus.doc} PlDPSVldDt
Valida a data do pergunte, se tem o tamanho correto e se é maio que a database.
@since   03/2021
//-------------------------------------------------------------------*/
function PlDPSVldDt(cData)
local lRet      := .f.
local dDatTmp   := ""

if ( len(alltrim(cData)) == 6 )
    dDatTmp := ctod(transform("01"+ cData, "@R !!/!!/!!!!"))
    if ( !empty(dDatTmp)  .and. !( dDatTmp > Date() ) )
        lRet := .t.
    endif
endif 
if !lRet
    //Atenção - Data Inválida - Informe o mês e ano da incidência - atual ou passada. Incidência futura não aceita.
    Help(nil, nil , STR0011, nil, STR0012, 1, 0, nil, nil, nil, nil, nil, {STR0013} ) 
endif
return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} PergDPStxt
Gera o arquivo txt com os dados
@since   03/2021
//-------------------------------------------------------------------*/
function PergDPStxt(lAuto, aDadAuto)
local aPergs 		:= {}
local aRetPerg		:= {}
local cNomeArq      := ""
local lExecuta		:= .t.
local lAtuData      := .f.
default lAuto		:= .f.
default aDadAuto	:= {}

aadd(aPergs,{ 2, STR0015, Space(1), { STR0016, STR0017, }, 100,, .t. } ) //"Tipo do txt: " / 1=Parcial / 2=Total
aadd(aPergs,{ 5, STR0024, .f., 100,,.f. } ) //"Apenas Conferência ?"

if lAuto
	aRetPerg := aDadAuto     
elseIf !paramBox( aPergs,STR0014,aRetPerg,,,.t.,,,,'PLSDPS1txt',.t.,.t. ) //"Gerar DPS txt
	lExecuta := .f.
endIf

if lExecuta 

    cNomeArq := "dps_" + BQ2->BQ2_INCIDE + "_" + strtran(strtran(strtran(fwtimestamp(2),"/",""), "-", ""), ":", "") + ".txt"
    
    if !lAuto
        if !aRetPerg[2] //definitivo
            //Ao gerar o arquivo, o sistema irá realizar os controles de status do lote e itens, para conferência e integridade dos dados.
            //"Use apenas se realmente for enviar o arquivo para a prefeitura. Caso contrário, marque a opção 'Apenas conferência'."
            if MsgYesNo(STR0025 + CRLF + STR0026)
                lAtuData := .t.
            else
                lExecuta := .f.
            endif
        else //conferencia
            cNomeArq := "conferencia_" + cNomeArq
            lAtuData := .f.
        endif
        If lExecuta
            Processa( {|| PLSDPSTXT(BQ2->BQ2_CODOPE, BQ2->BQ2_CODSEQ, BQ2->BQ2_INCIDE, aRetPerg[1], cNomeArq, lAuto, lAtuData) }, STR0011, STR0023 ,.F.)
        endif

    else
        PLSDPSTXT(BQ2->BQ2_CODOPE, BQ2->BQ2_CODSEQ, BQ2->BQ2_INCIDE, aRetPerg[1], cNomeArq, lAuto, .f., aRetPerg[3])
    endif
endif

return


/*//-------------------------------------------------------------------
{Protheus.doc} PlVerTabDPS
Verifica se existem as tabelas no ambiente, antes de abrir a rotina.
@since   03/2021
//-------------------------------------------------------------------*/
static function PlVerTabDPS()
local lRet  := .t.
if !FWAliasInDic("BQ2") .or. !FWAliasInDic("BQ3") 
    //A rotina não pode ser utilizada - Deve existir as tabelas BQ2/BQ3
    MsgAlert(STR0018, STR0019) 
    lRet := .f.
endif
return lRet
