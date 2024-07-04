#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CenCmdB5Q
    Classe abstrata para execução de comandos
    @type  Class
    @author everton.mateus
    @since 20190320
/*/
Class CenCmdB5Q
	
    Data oExecutor
    
    Method New(oExecutor) Constructor
    Method execute()
    
EndClass

Method New(oExecutor) Class CenCmdB5Q
    self:oExecutor := oExecutor
Return self

Method execute() Class CenCmdB5Q
Return _Super:execute()