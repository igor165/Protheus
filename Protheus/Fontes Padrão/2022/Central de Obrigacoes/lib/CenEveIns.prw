#include "protheus.ch"
#include "totvs.ch"
#include "restful.ch"
#include "fwmvcdef.ch"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

#DEFINE SX5_ID_EVENT_POS    3
#DEFINE SX5_ID_EVENT_SIZE   6

Static __lIsJob := isBlind()

Class CenEveIns

    Data cEventID
    Data cMensagem
    Data cTitulo
    Data cEmp
    Data cFil
    Data lAll
    Data cLevel
    Data cCargo

    Method New() Constructor
    Method SetEventID(cEventID)
    Method SetMensagem(cMensagem)
    Method Settitulo(ctitulo)
    Method SetEmp(cEmp)
    Method SetFil(cFil)
    Method SetCargo(cCargo)
    Method EnvSingle()
    Method EnvAll()
    Method LvWarning()
    Method LvInfo()
    Method LvError()
    Method isJob()
    Method checkSX5()
    Method Execute()
    Method Send()
    Method destroy()

EndClass

/*/{Protheus.doc}
    Classe abstrata para encapsular envio de eventos de mensagens meu protheus
    @type  Class
    @author lima.everton
    @since 20200821
/*/

Method New() Class CenEveIns
    self:cLevel := FW_EV_LEVEL_INFO
    self:cCargo := ""
    self:lAll := .T.
    self:cEventID := ""
    self:cMensagem := "Default Message"
    self:cTitulo := "Default Title"
Return Self

Method SetEventID(cEventID) Class CenEveIns
    self:cEventID := cEventID
Return

Method SetMensagem(cMensagem) Class CenEveIns
    self:cMensagem := cMensagem
Return

Method SetTitulo(cTitulo) Class CenEveIns
    self:cTitulo := cTitulo
Return

Method SetEmp(cEmp) Class CenEveIns
    self:cEmp := cEmp
Return

Method SetFil(cFil) Class CenEveIns
    self:cFil := cFil
Return

Method SetCargo(cCargo) Class CenEveIns
    self:cCargo := cCargo
Return

Method EnvSingle() Class CenEveIns
    self:lAll := .F.
Return

Method EnvAll() Class CenEveIns
    self:lAll := .T.
Return

Method LvWarning() Class CenEveIns
    self:cLevel := FW_EV_LEVEL_WARNING
Return

Method LvInfo() Class CenEveIns
    self:cLevel := FW_EV_LEVEL_INFO
Return

Method LvError() Class CenEveIns
    self:cLevel := FW_EV_LEVEL_ERROR
Return

Method Send() Class CenEveIns
    EventInsert( FW_EV_CHANEL_ENVIRONMENT,;
        FW_EV_CATEGORY_MODULES,;
        self:cEventID,;
        self:cLevel,;
        self:cCargo,;
        self:cTitulo,;
        self:cMensagem,;
        self:lAll)

Return .T.

Method isJob() Class CenEveIns
    If __lIsJob .And. LockByName(GetClassName(self), .F., .F.)
        RPCSetType(3)  //Nao consome licenças
        RpcSetEnv(self:cEmp,self:cFil,,,"CEN",GetClassName(self)) //Abertura do ambiente em rotinas automáticas
    EndIf
Return __lIsJob

Method checkSX5() Class CenEveIns
    Local aSX5_E3 := FWGetSX5( "E3" )
Return !Empty(aScan(aSX5_E3, {|x| x[SX5_ID_EVENT_POS] == padr(self:cEventID,SX5_ID_EVENT_SIZE)}))

Method Execute() Class CenEveIns
Return .T.

Method destroy() Class CenEveIns
    If __lIsJob
        UnLockByName(GetClassName(self),.F.,.F.)
        RpcClearEnv()
    EndIf
Return