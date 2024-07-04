#include 'totvs.ch'

/*/{Protheus.doc} SvcNotify()
    (Schedule das Notificações via Aplicativo Meu Protheus)
    @author david.juan
    @since 20200925
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=566463747
/*/
Function SvcNotify()
    Local cEmp := cEmpAnt
    Local cFil := cFilAnt
    StartJob("CenJobNoti", GetEnvServer(), .F., cEmp, cFil)
Return

Function CenJobNoti(cEmp, cFil)
    local oCenNotifiers := NIL
    Default cEmp := cEmpAnt
    Default cFil := cFilAnt
    oCenNotifiers := CenNotifiers():New(cEmp, cFil)
    oCenNotifiers:execute()
Return