#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFVOMigr
Classe que reprenta o VO (Value Object) utilizado pelo Migrador
@author  Victor A. Barbosa
@since   11/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Class TAFVOMigr From LongNameClass


    Data cReceipt
    Data cXMLErp
    Data cEvent
    Data cFileXML
    Data cIdXML
    Data cStatus
    Data cTypeEvent
    Data cTimeProc
    Data cTagMain
    Data cIndEvent
    Data cCNPJ
    Data cAliasEvt
    Data cBranch
    Data cDelReceipt
    Data cCNPJXML

    Method New() Constructor
    
    // Setters
    Method SetReceipt()
    Method SetXML()
    Method SetEvent()
    Method SetFileXML()
    Method SetID()
    Method SetStatus()
    Method SetTypeEvent()
    Method SetTimeProc()
    Method SetTagMain()
    Method SetIndEvent()
    Method SetCNPJ()
    Method SetAliasEvent()
    Method SetBranch()
    Method SetDelReceipt()
    Method SetCNPJXml()

    // Getters
    Method GetReceipt()
    Method GetXML()
    Method GetEvent()
    Method GetFileXML()
    Method GetID()
    Method GetStatus()
    Method GetTypeEvent()
    Method GetTimeProc()
    Method GetTagMain()
    Method GetCNPJ()
    Method GetAliasEvent()
    Method GetBranch()
    Method GetDelReceipt()
    Method GetCNPJXml()

    Method Clear()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método Construtor
@author  Victor A. Barbosa
@since   15/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Method New() Class TAFVOMigr
Return( self )

//Setters
Method SetReceipt(cReceipt)         Class TAFVOMigr; self:cReceipt      := cReceipt;        Return
Method SetXML(cXMLErp)              Class TAFVOMigr; self:cXMLErp       := cXMLErp;         Return
Method SetEvent(cEvent)             Class TAFVOMigr; self:cEvent        := cEvent;          Return
Method SetFileXML(cFileXML)         Class TAFVOMigr; self:cFileXML      := cFileXML;        Return
Method SetID(cIdXML)                Class TAFVOMigr; self:cIdXML        := cIdXML;          Return
Method SetStatus(cStatus)           Class TAFVOMigr; self:cStatus       := cStatus;         Return
Method SetTypeEvent(cTypeEvent)     Class TAFVOMigr; self:cTypeEvent    := cTypeEvent;      Return
Method SetTimeProc(cTimeProc)       Class TAFVOMigr; self:cTimeProc     := cTimeProc;       Return
Method SetTagMain(cTagMain)         Class TAFVOMigr; self:cTagMain      := cTagMain;        Return
Method SetCNPJ(cCNPJ)               Class TAFVOMigr; self:cCNPJ         := cCNPJ;           Return
Method SetAliasEvent(cAliasEvt)     Class TAFVOMigr; self:cAliasEvt     := cAliasEvt;       Return
Method SetBranch(cBranch)           Class TAFVOMigr; self:cBranch       := cBranch;         Return
Method SetDelReceipt(cDelReceipt)   Class TAFVOMigr; self:cDelReceipt   := cDelReceipt;     Return
Method SetCNPJXml(cCNPJXml)         Class TAFVOMigr; self:cCNPJXml      := cCnpjXML;        Return

//Getters
Method GetReceipt()         Class TAFVOMigr;    Return(self:cReceipt)
Method GetXML()             Class TAFVOMigr;    Return(self:cXMLErp)
Method GetEvent()           Class TAFVOMigr;    Return(self:cEvent)
Method GetFileXML()         Class TAFVOMigr;    Return(self:cFileXML)
Method GetID()              Class TAFVOMigr;    Return(self:cIdXML)
Method GetStatus()          Class TAFVOMigr;    Return(self:cStatus)
Method GetTypeEvent()       Class TAFVOMigr;    Return(self:cTypeEvent)
Method GetTimeProc()        Class TAFVOMigr;    Return(self:cTimeProc)
Method GetTagMain()         Class TAFVOMigr;    Return(self:cTagMain)
Method GetCNPJ()            Class TAFVOMigr;    Return(self:cCNPJ)
Method GetAliasEvent()      Class TAFVOMigr;    Return(self:cAliasEvt)
Method GetBranch()          Class TAFVOMigr;    Return(self:cBranch)
Method GetDelReceipt()      Class TAFVOMigr;    Return(self:cDelReceipt)
Method GetCNPJXml()         Class TAFVOMigr;    Return(self:cCnpjXML)

//-------------------------------------------------------------------
/*/{Protheus.doc} Method - Clear
Limpa os atributos da Classe
@author  Victor A. Barbosa
@since   15/10/2018
@version 1
/*/
//-------------------------------------------------------------------
Method Clear() Class TAFVOMigr

self:SetReceipt("")
self:SetXML("")
self:SetEvent("")
self:SetFileXML("")
self:SetID("")
self:SetStatus("")
self:SetTypeEvent("")
self:SetTimeProc("")
self:SetTagMain("")
self:SetCNPJ("")
self:SetAliasEvent("")
self:SetBranch("")
self:SetDelReceipt("")
self:SetCNPJXml("")

Return