#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//-----------------------------------------------------------------
/*/{Protheus.doc} PLSSisPacSc
Schedule para comunicar com o SISPAC
 
@author vinicius.queiros
@since 19/10/2020
@version 1.0
/*/
//-----------------------------------------------------------------
Function PLSSisPacSc()

    Local cCodOpe       := MV_PAR01
    Local cLogSisPac    := "PLSSISPAC.log"

    PlsPtuLog("[Iniciando JOB PLSSisPacSc] " + Time(), cLogSisPac)
    Conout("Iniciando Job PLSSisPacSc.")
  
    BA0->(DbSetOrder(1))
    If Empty(cCodOpe)
        PlsPtuLog("Nao foi informada a Operadora nos parametros da rotina.", cLogSisPac)
        Conout( "Nao foi informada a Operadora nos parametros da rotina" ,, .F. )     
        Return nil

    Elseif !BA0->(DbSeek(xFilial('BA0')+cCodOpe))
        PlsPtuLog("A Operadora informada nao foi encontrada no sistema.", cLogSisPac)
        Conout( "A Operadora informada nao foi encontrada no sistema." ,, .F. )     
        Return nil
    Endif

    // Trava para não executar o JOB se ja estiver em execucao
    If !MayIUseCode( "PLSSisPacSc" + cCodOpe )
        PlsPtuLog("Job PLSSisPacSc" + cCodOpe + " - Já está em execução, aguarde o termino do processamento.")
        Conout( "Job PLSSisPacSc" + cCodOpe + " - Já está em execução, aguarde o termino do processamento." ,, .F. ) 
        Return nil
    EndIf

    PTUONPAC(cCodOpe)

    PlsPtuLog("[Finalizando JOB] " + Time(), cLogSisPac)
    PlsPtuLog(Replicate('*',50),cLogSisPac)
    Conout("Finalizando Job PLSSisPacSc.")

    //Libera semaforo
    FreeUsedCode()

Return(Nil)

//-----------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Schedule para job
 
@author vinicius.queiros
@since 19/10/2020
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function SchedDef()
Return { "P","PLSATU",,{},""}
