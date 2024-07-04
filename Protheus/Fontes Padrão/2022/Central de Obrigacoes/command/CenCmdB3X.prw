#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CenCmdB3X
    Classe abstrata para execução de comandos
    @type  Class
    @author everton.mateus
    @since 20190320
/*/
Class CenCmdB3X
	
    Data oExecutor
    
    Method New(oExecutor) Constructor
    Method execute()
    
EndClass

Method New(oExecutor) Class CenCmdB3X
    self:oExecutor := oExecutor
Return self

Method execute() Class CenCmdB3X
Return _Super:execute()