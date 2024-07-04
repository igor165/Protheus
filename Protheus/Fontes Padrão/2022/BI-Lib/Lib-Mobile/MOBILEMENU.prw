#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MOBILEMENU
@type			function
@description	Assistente de configuração Mobile.
@author			Robson Santos
@since			21/05/2021
@version		1.0
/*/
//---------------------------------------------------------------------
Function MOBILEMENU()

If (GetBuild() >= "7.00.170117A-20190628") 	
	FWCallApp( "MOBILEMENU")
Else
	MsgAlert("Para utilizar as funcionalidades do Assistente de Configuração Mobile você deve atualizar o seu sistema para uma build 64 bits (Lobo Guará).")
EndIf

Return(.T.)

//---------------------------------------------------------------------
/*/{Protheus.doc} JsToAdvpl
@type			function
@description	Bloco de código que receberá as chamadas JavaScript.
@author			Robson Santos
@since			21/05/2021
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function JsToAdvpl( oWebChannel, cType, cContent )

Local aJResult		:= {}
Local nX 			:= 0
Local aFontes		:= {}

AAdd(aFontes, {"ATFA500.PRW",  	"20190104"})
AAdd(aFontes, {"FINA677.PRW",  	"20210730"})
AAdd(aFontes, {"WSATF001.PRW", 	"20201009"})
AAdd(aFontes, {"WSFIN677.PRW", 	"20210621"})
AAdd(aFontes, {"ACDCFGMOB.PRW",	"20201030"})
AAdd(aFontes, {"ACDM010.PRW",  	"20210804"})
AAdd(aFontes, {"ACDM020.PRW",  	"20210730"})
AAdd(aFontes, {"ACDV035.PRG",  	"20201230"})
AAdd(aFontes, {"ACDV120.PRG",  	"20210226"})
AAdd(aFontes, {"ACDV166.PRG",  	"20210727"})
AAdd(aFontes, {"ACDV170.PRG",	"20190606"})
AAdd(aFontes, {"CRMM010.PRW",	"20181229"})
AAdd(aFontes, {"CRMM020.PRW",	"20191114"})
AAdd(aFontes, {"CRMM030.PRW",	"20181229"})
AAdd(aFontes, {"CRMM040.PRW",	"20181229"})
AAdd(aFontes, {"CRMM050.PRW",	"20191121"})
AAdd(aFontes, {"CRMM060.PRW",	"20181229"})
AAdd(aFontes, {"CRMM070.PRW",	"20181229"})
AAdd(aFontes, {"CRMM080.PRW",	"20191121"})
AAdd(aFontes, {"CRMM090.PRW",	"20190114"})
AAdd(aFontes, {"CRMM100.PRW",	"20190114"})
AAdd(aFontes, {"CRMM110.PRW",	"20190124"})
AAdd(aFontes, {"CRMM120.PRW",	"20190114"})
AAdd(aFontes, {"CRMMOBILE.PRW",	"20190116"})
AAdd(aFontes, {"CRMXFUNGEN.PRW","20210212"})
AAdd(aFontes, {"CRMXFUNPERM.PRW","20210309"})
AAdd(aFontes, {"CNTA300R.PRW","20210716"})
AAdd(aFontes, {"CNTM121.PRW","20190819"})
AAdd(aFontes, {"CNTM300.PRW","20200820"})
AAdd(aFontes, {"CNTMNAT.PRX","20210728"})
AAdd(aFontes, {"PURCHASEORDERAPPROVAL.PRW","20210730"})
AAdd(aFontes, {"WSLEGALPROCESS.PRW","20210723"})
AAdd(aFontes, {"WSLEGALTASK.PRW","20210714"})
AAdd(aFontes, {"TECM010.PRW"," 20210715"})
AAdd(aFontes, {"TECM020.PRW"," 20201130"})

Do Case

	Case cType == "preLoad"
		
		For nX := 1 To Len(aFontes)

			aRetFont := {}

			aRetFont := GetAPOInfo(aFontes[nX][1])

			If Empty(aRetFont) .OR. (aRetFont[4] < SToD(aFontes[nX][2]))

				AAdd( aJResult,  JsonObject():New() )

				aJResult[Len(aJResult)]["name"] 					:= aFontes[nX][1]
				aJResult[Len(aJResult)]["expeditionContinuesDate"] 	:= DToC(SToD(aFontes[nX][2]))

				If Len(aRetFont) > 1
					aJResult[Len(aJResult)]["currentDate"]  := aRetFont[4]
				Else
					aJResult[Len(aJResult)]["currentDate"]  := ""
				EndIf
				
			EndIf

		Next nX
		
		oResponse :=  JsonObject():New()
		oResponse[ "outdatedFonts" ] := aJResult

		cOutdatedFonts := oResponse:TOJSON()

		oWebChannel:AdvPLToJS( "setOutdatedFonts", cOutdatedFonts )

EndCase


Return()

