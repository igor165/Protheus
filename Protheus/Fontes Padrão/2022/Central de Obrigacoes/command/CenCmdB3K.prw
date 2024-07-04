#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CenCmdB3K
    Classe abstrata para execução de comandos
    @type  Class
    @author everton.mateus
    @since 20190320
/*/
Class CenCmdB3K
	
    Data oExecutor
    
    Method New(oExecutor) Constructor
    Method execute()
    
EndClass

Method New(oExecutor) Class CenCmdB3K
    self:oExecutor := oExecutor
Return self

Method execute() Class CenCmdB3K
Return _Super:execute()