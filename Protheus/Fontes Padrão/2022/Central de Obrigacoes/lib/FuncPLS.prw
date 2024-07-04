#include "TOTVS.CH"
STATIC __ATIPTAB := {}
/*/ Atendimento | Autorizador
    Este fonte deve receber as funcoes do ERP que ainda s�o utilizadas pelo autorizador.
@author everton.mateus
@since 16/02/2018
/*/

/*/{Protheus.doc} setGblVars
    Cria as variaveis globais padroes do protheus
Origem: PLSMFUN.PRW
@type function
@author everton.mateus
@since 16/02/2018
/*/
FUNCTION setGblVars( )

    PUBLIC __TTSINUSE       := nil
    PUBLIC __TTSBREAK       := nil
    Public __lFkInUse       := nil
    PUBLIC __lACENTO        := nil
    PUBLIC lMsFinalAuto     := nil
    PUBLIC __cLogSiga       := nil
    //PUBLIC __Language       := nil
    PUBLIC __LocalDriver    := nil
    PUBLIC __cInternet      := nil
    PUBLIC cEmpAnt          := nil
    PUBLIC cFilAnt          := nil
    PUBLIC __cAliasInTSS    := nil
    PUBLIC cAcesso	        := nil
    PUBLIC __TTSPush        := nil
    PUBLIC aSX8  		    := nil
    PUBLIC __TTSCommit      := nil

    __TTSINUSE       := .T.
    __TTSBREAK       := .f.
    __lFkInUse       := .F.
    __lACENTO        := .F.
    lMsFinalAuto     := .T.
    __cLogSiga       := "NNNNNN"
    // __Language       := 'PORTUGUESE'
    __LocalDriver    := "DBFCDX"
    __cInternet      := "AUTOMATICO"
    cEmpAnt          := "99"
    cFilAnt          := "01"
    __cAliasInTSS    := ""
    cAcesso	         := replicate("S",128)
    __TTSPush        := {}
    aSX8  		     := {}
    __TTSCommit      := nil

    SET DELETED ON
    SET SCOREBOARD OFF
    SET DATE BRITISH
    SET(4,"DD/MM/YYYY")

return