#Include 'Protheus.ch'

#DEFINE __console   0

Class AutDefaultTestCase FROM FWDefaultTestCase
	
    // Atributos utilizado na criacao do log
    Data nIniSetup
    Data nEndSetup
    Data nIniExec
    Data nEndExec
    Data logType

	// Metodo principal
    Method AutDefaultTestCase()

    // Metodos utilizado na criacao do log
    Method iniSetup()
    Method endSetup()
    Method iniExec()
    Method endExec()
    Method logConsole()
    Method printLog()
    Method clear()

EndClass

Method AutDefaultTestCase() Class AutDefaultTestCase
    _Super:FWDefaultTestCase()
Return self

Method iniSetup() Class AutDefaultTestCase
    self:nIniSetup := microSeconds()
Return

Method endSetup() Class AutDefaultTestCase
    self:nEndSetup := microSeconds()
Return

Method iniExec() Class AutDefaultTestCase
    self:nIniExec := microSeconds()
Return

Method endExec() Class AutDefaultTestCase
    self:nEndExec := microSeconds()
Return

Method logConsole() Class AutDefaultTestCase
    self:logType := __console
Return

Method printLog() Class AutDefaultTestCase

    if self:logType == __console
        conOut("-----" + procName(1) + "-----")
        conOut("Tempo gasto carregando  : " + Str(self:nEndSetup - self:nIniSetup))
        conOut("Tempo gasto na execucao : " + Str(self:nEndExec  - self:nIniExec))
        conOut("Tempo gasto Total       : " + Str(self:nEndExec  - self:nIniSetup))
        conOut("-----" + procName(1) + "-----")
    endif

Return

Method clear() Class AutDefaultTestCase

Return
