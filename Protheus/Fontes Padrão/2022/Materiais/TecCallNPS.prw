#INCLUDE "PROTHEUS.CH"

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecNPS

@description Realiza abertura do NPS
@author Augusto Albuquerque
@since  15/12/2021
/*/
//--------------------------------------------------------------------------------
Function TecNPS( oDlg )

Default oDlg := Nil

FWCallApp( "tecnps",  oDlg, , , , "TecCallNPS" )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JsToAdvpl(oWebChannel, cType, cContent)
Chamada do APP dentro da Dialog

@param oWebChannel - WebChannel para enviar informação para o App
@param cType - "Tipo" da chamada na chamada Via App
@param cContent - Conteudo adicional recebido do App

@author Willian Yoshiaki Kazahaya
@since 22/12/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JsToAdvpl(oWebChannel, cType, cContent)
	Do Case
		Case cType == "preLoad"
			appPreLoad(oWebChannel)
	EndCase
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} appPreLoad(oWebChannel)
Passa os parâmetros de PreLoad para o App

@param oWebChannel - WebChannel para enviar informação para o App

@author Willian Yoshiaki Kazahaya
@since 22/12/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function appPreLoad(oWebChannel)
	oWebChannel:AdvPLToJS( "setProdutoNPS", "PrestServTerc")
	oWebChannel:AdvPLToJS( "setURLEndpoint", "TECNPS/gradeclass" )
	oWebChannel:AdvPLToJS( "setProductLabel", "TOTVS Prestadores de Serviços Terceirização" )
Return Nil
