#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"


//-----------------------------------------------------------------
/*/{Protheus.doc} PLMensSchd
 Schedule para atualizar status das guias pendentes na Mensageria
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Function PLMensSchd()
    
    Local cCodOpe := MV_PAR01
    Local oMensageria := PLMensCont():New()

    // Trava para não executar o JOB se ja estiver em execucao
    lOk := LockByName('PLMensSchd' + cCodOpe,.T.,.F.)

    if lOk
        LogCabec(oMensageria,"Iniciando Job PLMensSchd")
        oMensageria:procSchedule() //Processa rotina
        oMensageria:destroy() //Mata objeto do processo        
        UnLockByName('PLMensSchd' + cCodOpe) //Libera semaforo
        
        oMensageria:impLog("")
        oMensageria:impLog("***** Finalizando JobPLMensSchd *****")
        Conout("***** Finalizando JobPLMensSchd *****")
    else 
        LogCabec(oMensageria,'Job PLMensSchd' + cCodOpe + ' - Já está em execução, aguarde o termino do processamento.')
    endIf

Return nil


//-----------------------------------------------------------------
/*/{Protheus.doc} SchedDef
 Schedule para job
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function SchedDef()
Return { "P","PLSATU",,{},""}


//-------------------------------------------------------------------
/*/{Protheus.doc} LogCabec
Monta o cabecalho padrao do log HAT

@author  Renan Sakai
@version P12
@since   24.06.19
/*/
//-------------------------------------------------------------------
Static Function LogCabec(oMensageria,cMsg)

    Default cMsg     := ""

    oMensageria:impLog(Replicate("*",50),.F.)
    oMensageria:impLog(cMsg)
    oMensageria:impLog(Replicate("*",50),.F.)
    Conout(cMsg)

Return