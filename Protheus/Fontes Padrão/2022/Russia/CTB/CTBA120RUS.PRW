#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'

#DEFINE SourceFather "CTBA120" //Pattern Routine

/*/{Protheus.doc} CTBA120RUS
Location of the Apportionment Criteria Routine (CTBA120)

@type  Function
@author Alison Kaique
@since Jan/19
@version P!2
/*/
Function CTBA120RUS()
    Local oBrowse := BrowseDef() //Instance of Browse

    If !(oBrowse == Nil)
        oBrowse:Activate()
    EndIf
Return

/*/{Protheus.doc} BrowseDef
Navigation

@author Alison Kaique
@since Jan/19
@version P12

@return object, Browse Definitions
/*/
Static Function BrowseDef()
    Local oBrowse := FWLoadBrw(SourceFather)
Return oBrowse

/*/{Protheus.doc} MenuDef
Functional Menu

@author Alison Kaique
@since Jan/19
@version P12

@return array, Menu Options
/*/
Static Function MenuDef()
    Local aRoutine := FWLoadMenuDef(SourceFather)
Return aRoutine

/*/{Protheus.doc} ViewDef
Graphical Interface Definitions

@author Alison Kaique
@since Jan/19
@version P12

@return object, Interface Definitions
/*/
Static Function ViewDef()
    Local oView := FWLoadView(SourceFather)
Return oView

/*/{Protheus.doc} ModelDef
Data Model Definitions

@author Alison Kaique
@since Jan/19
@version P12

@return object, Data Nodel
/*/
Static Function ModelDef()
    Local oModel := FWLoadModel(SourceFather)

    /** Pending analysis */
    //Install Russian Event
	//oModel:InstallEvent(SourceFather + "EVRUS",, CTBA120EVRUS():New())
Return oModel