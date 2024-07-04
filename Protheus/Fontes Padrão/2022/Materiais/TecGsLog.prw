#INCLUDE "PROTHEUS.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GsLog

@description Classe utilizada para gera��o de Logs gen�ricos

Como usar:
1) Instanciar:
--
--  Local oGsLog := GsLog():new()
--
2) Adicionar o conte�do String no log
--
-- oGsLog:addLog('meuId123',"Informa��o que surgir� no log123")
-- oGsLog:addLog('meuId123',"Informa��o que surgir� no log123")
-- oGsLog:addLog('meuId456',"Informa��o que surgir� no log456")
-- oGsLog:addLog('meuId456',"Informa��o que surgir� no log456")
--  //neste momento, dois Logs distintos est�o salvos. O de id meuId123 e o de id meuId456
--
3) Gerar o arquivo de log para o id solicitado
--
-- oGsLog:printLog('meuId123', [cParam_Nome_do_arquivo]) //gera o log de id meuId123
--
4) O log � gerado na pasta /system/gestaoservicos do ambiente
5) O nome do arquivo gerado � por default gslog + id_do_log + "-YYYYMMDD"

@author	boiani
@since	03/07/2020
/*/
//------------------------------------------------------------------------------
class GsLog

Data aLogId AS ARRAY
Data cLogInfo AS CHARACTER
data lLog AS LOGICAL

Method new()
Method addLog()
Method printLog()

endclass
//------------------------------------------------------------------------------
/*/{Protheus.doc} new

@description Construtor da classe GsLog

@author	boiani
@since	03/07/2020
/*/
//------------------------------------------------------------------------------
method new(lExec) class GsLog

Default lExec := .T.

::aLogId := {}
::cLogInfo := ""
::lLog := lExec

return
//------------------------------------------------------------------------------
/*/{Protheus.doc} addLog

@description Adiciona String no log para o id selecionado & cria o ID caso n�o exista

@param cLogId, String, Id do log que ser� criado / atualizado
@param cNewInfo, String, Valor adicionado no Log

@author	boiani
@since	03/07/2020
/*/
//------------------------------------------------------------------------------
method addLog(cLogId,cNewInfo) class GsLog
Local nPos := 0

If ::lLog
    If EMPTY(::aLogId) .OR. (nPos := ASCAN(::aLogId, {|a| a[1] == cLogId})) == 0
        AADD(::aLogId, {cLogId, {}})
        nPos := LEN(::aLogId)
    EndIf
    AADD(::aLogId[nPos][2],cNewInfo)
EndIf

return
//------------------------------------------------------------------------------
/*/{Protheus.doc} printLog

@description Gera o arquivo de LOG conforme par�metro de ID

@param cLogId, String, Id do log que ser� gerado
@param cFileName, String, Par�metro opcional contendo o nome do arquivo

@author	boiani
@since	03/07/2020
/*/
//------------------------------------------------------------------------------
method printLog(cLogId, cFileName) class GsLog
Local nPos := ASCAN(::aLogId, {|a| a[1] == cLogId})
Local nX
Default cFileName := "GsLog"+cLogId + " - " + AllTrim(DToS(Date()))

If ::lLog .AND. nPos > 0
    For nX := 1 To LEN(::aLogId[nPos][2])
        If !EMPTY(::aLogId[nPos][2][nX])
            TxLogFile(cFileName,::aLogId[nPos][2][nX]+CRLF,.F.,.F.,.F.)
        EndIf
    Next nX
EndIf

return