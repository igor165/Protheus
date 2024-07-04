#INCLUDE "TOTVS.CH"

Class CenNotifiers

    Data aNotifiers
    Data cEmp
    Data cFil

    Method New(cEmp, cFil) Constructor
    Method Execute()

EndClass

/*/{Protheus.doc}
    Classe que concentra as notificações meu Protheus Central de obrigações.
    @type  Class
    @author lima.everton
    @since 20200821
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=565739643
/*/
Method New(cEmp, cFil) Class CenNotifiers
    Default cEmp    := cEmpAnt
    Default cFil    := cFilAnt
    self:cEmp       := cEmp
    self:cFil       := cFil
    self:aNotifiers := {}
    aAdd(Self:aNotifiers,CenNotiSib():New())
    aAdd(Self:aNotifiers,CenNotVenc():New())
    aAdd(Self:aNotifiers,CenNotNews():New())
Return self

Method Execute() Class CenNotifiers
    Local nI := 1
    Local nCount := Len(self:aNotifiers)
    For nI:= 1 to nCount
        self:aNotifiers[nI]:setEmp(self:cEmp)
        self:aNotifiers[nI]:setFil(self:cFil)
        self:aNotifiers[nI]:isJob()
        If self:aNotifiers[nI]:checkSX5()
            self:aNotifiers[nI]:execute()
        EndIf
        self:aNotifiers[nI]:destroy()
    Next
Return .T.

