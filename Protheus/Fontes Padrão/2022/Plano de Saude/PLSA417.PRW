#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

#DEFINE ERROR_GEN_B1R "2"
#DEFINE ERROR_GEN_BXX "3"
#DEFINE ERROR_DOWN_XML "4"
#DEFINE ERROR_UPD_HAT "5"
#DEFINE ERROR_DELETE "6"

//-------------------------------------------------------------
/*/{Protheus.doc} PLSA417
Rotina de logs genéricos

@author    Lucas Nonato
@version   V12
@since     19/05/2020
/*/
function PLSA417() 
local oBrwPrinc	:= nil

oBrwPrinc := FWMBrowse():New()
oBrwPrinc:SetDescription( "Protocolos de Transação" )
oBrwPrinc:SetAlias( "B1R" )
oBrwPrinc:SetMenuDef( "PLSA417" )
oBrwPrinc:DisableDetails()
oBrwPrinc:ForceQuitButton()
oBrwPrinc:SetProfileID( '0' )
oBrwPrinc:SetWalkthru( .F. )
oBrwPrinc:SetAmbiente( .F. )

oBrwPrinc:addLegend( "B1R_STATUS == 'Y' .or. B1R_STATUS == 'Z' ", "RED" ,	    "Erro " )
oBrwPrinc:addLegend( "B1R_STATUS == '1'", "BLUE",	"Processado " )
oBrwPrinc:addLegend( "B1R_STATUS == '2'", "BLUE"   ,	"Processado " )

oBrwPrinc:Activate()

return


//-------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menudef - MVC

@author    Lucas Nonato
@version   V12
@since     18/05/2020
/*/
static function MenuDef()
local aRotina	:= {}              

aadd( aRotina, { "Logs"	        ,	"PLSB6HLOG()"     , 0, MODEL_OPERATION_VIEW	    } )
aadd( aRotina, { "Visualizar"	,	"VIEWDEF.PLSA417" , 0, MODEL_OPERATION_VIEW	    } )
//aadd( aRotina, { "Excluir"		, 	"VIEWDEF.PLSA417" , 0, MODEL_OPERATION_DELETE	} )
aadd( aRotina, { "Reprocessar HAT"	,	"PLSA417REP()" , 0, MODEL_OPERATION_VIEW	    } )
aadd( aRotina, { "Tentativas excedidas"	,	"PLSA417LEX" , 0, MODEL_OPERATION_VIEW	    } )

return aRotina

//-----------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    Lucas Nonato
@version   V12
@since     18/05/2020
/*/
static function ModelDef()
local oStruB1R := FWFormStruct( 1,'B1R',/*bAvalCampo*/,/*lViewUsado*/ )
local oModel

//--< DADOS DO LOTE >---
oModel := MPFormModel():New( 'Protocolos de Transação' )
oModel:AddFields( 'MODEL_B1R',,oStruB1R )
	
oModel:SetDescription( "Protocolos de Transação" )
oModel:GetModel( 'MODEL_B1R' ):SetDescription( ".:: Protocolos de Transação ::." )
oModel:SetPrimaryKey( { "B1R_FILIAL","B1R_PROTOC","B1R_ORIGEM" } )
                                                                                                                         
return oModel
 
//-----------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef - MVC

@author    Lucas Nonato
@version   V12
@since     18/05/2020
/*/
static function ViewDef()
local oView     := nil
local oModel	:= FWLoadModel( 'PLSA417' )
	
oView := FWFormView():New()
oView:SetModel( oModel )
return oView

//-----------------------------------------------------------
/*/{Protheus.doc} PLSB6HLOG
Cria os logs
@author    Lucas Nonato
@version   V12
@since     18/05/2020
/*/
function PLSB6HLOG() 
local oBrwLog		:= nil

oBrwLog := FWMBrowse():New()
oBrwLog:SetDescription( "Logs" )
oBrwLog:SetAlias( "B6H" )
oBrwLog:DisableDetails()
oBrwLog:ForceQuitButton()
oBrwLog:SetMenuDef( '' )
oBrwLog:SetProfileID( '1' )
oBrwLog:SetFilterDefault("@B6H_FILIAL = '"+xFilial("B6H")+"' AND B6H_CHAVE = '"+alltrim(B1R->B1R_PROTOC)+"'")
oBrwLog:SetWalkthru( .F. )
oBrwLog:SetAmbiente( .F. )

oBrwLog:Activate()

return

//-----------------------------------------------------------
/*/{Protheus.doc} logpls
Grava log

@author    Lucas Nonato
@version   V12
@since     18/05/2020
/*/
function logpls(cMsg, cChave, cChave2, cNivel, cTipo)
default cMsg    := ''
default cChave  := ''
default cNivel  := '1'
default cTipo   := 'PLSA417'
default cChave2 := ''

If aliasInDic('B6H')
    B6H->(recLock('B6H',.t.))
    B6H->B6H_FILIAL := xfilial('B6H')
    B6H->B6H_CHAVE  := cChave
    B6H->B6H_TIPO   := cTipo
    B6H->B6H_NIVEL  := cNivel
    B6H->B6H_DATA   := date()
    B6H->B6H_HORA   := strtran(time(),':','')
    B6H->B6H_MSG    := cMsg
    B6H->B6H_CHAVE2 := cChave2
    B6H->(msUnlock('B6H',.t.))
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA417REP
Reinicia a contagem de tentativas de reprocessamento de registros da integração PLS x HAT com erro
@author Oscar Zanin
@since 28/01/2022
@version P12
/*/
//-------------------------------------------------------------------
function PLSA417REP()
Local cSql := ""
Local lRet := .F.

if MsgYesNo("Deseja reiniciar a contagem para os registros de origem do HAT que chegaram ao limite de tentativas de reprocessamento?" + ;
            CRLF + "(Registros com status de erro de comunicação continuam sendo reprocessados independente do limite e por isso não são reiniciados)")

    cSql += " Update " + retSqlName("B1R")
    cSql += " Set "
    cSql += " B1R_QTDTRY = 0 "
    cSql += " Where "
    cSql += " B1R_FILIAL = '" + xFilial('B1R') + "' AND "
    cSql += " B1R_STATUS IN ('" + ERROR_GEN_BXX + "', '" + ERROR_DOWN_XML + "', '" + ERROR_DELETE + "') AND "
    cSql += " B1R_HATTIP <> ' ' AND "
    cSql += " B1R_QTDTRY >= 10 AND "
    cSql += " D_E_L_E_T_ = ' ' "

    lRet := PLSCOMMIT(cSql)

    if lRet
        MsgInfo('Processo realizado')
    endif
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA417LEX
Mostra Registros com quantidade de tentativas de reprocesamento excedidas da integração PLS x HAT
@author Oscar Zanin
@since 28/01/2022
@version P12
/*/
//-------------------------------------------------------------------
function PLSA417LEX() 
local oBrwPrinc	:= nil
local cfiltro := "@B1R_QTDTRY >= 10 AND B1R_HATTIP <> ' ' "

oBrwPrinc := FWMBrowse():New()
oBrwPrinc:SetDescription( "Protocolos com limite de tentativas excedida" )
oBrwPrinc:SetAlias( "B1R" )
oBrwPrinc:SetMenuDef( "PLSA417" )
oBrwPrinc:DisableDetails()
oBrwPrinc:ForceQuitButton()
oBrwPrinc:SetFilterDefault(cfiltro)
oBrwPrinc:SetWalkthru( .F. )
oBrwPrinc:SetAmbiente( .F. )

oBrwPrinc:addLegend( "B1R_STATUS == '3'", "RED"   ,	"Erro ao gravar registro do XML" )
oBrwPrinc:addLegend( "B1R_STATUS == '4'", "YELLOW",	"Erro no download do arquivo XML" )
oBrwPrinc:addLegend( "B1R_STATUS == '5'", "GREEN" ,	"Erro na comunicação com o HAT" )
oBrwPrinc:addLegend( "B1R_STATUS == '6'", "BLUE"  ,	"Erro na exclusão do registro" )

oBrwPrinc:Activate()

return
