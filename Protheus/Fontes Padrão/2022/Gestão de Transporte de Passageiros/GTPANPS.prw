//-------------------------------------------------------------------
/*/{Protheus.doc} NPSAPP
App de NPS com Dialog

/*/
//-------------------------------------------------------------------
Function GTPANPS()
Local oDlg          := Nil
Local oNPS          := Iif(FindClass('GSNPS'),GsNps():New(), Nil)
Local cCfgAppEnv    := GetPvProfString( "GENERAL", "APP_ENVIRONMENT", "-", GetAdv97() )
				
    If oNPS <> Nil 

		lRet := (cCfgAppEnv != "-") .And. (GetBuild() >= "7.00.170117A-20190628")

		If (lRet .And. FindFunction("CanUseWebUI"))
			lRet := CanUseWebUI()
		EndIf

		If lRet 
			
			oNps:setProductName("GTP_DESENV") // Chave Agrupadora do Produto

			If (oNps:canSendAnswer())
				DEFINE MSDIALOG oDlg FROM 0,0 TO 33, 120 TITLE "NPS" Style 128
				ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( GtpNps( oDlg ) )
			EndIf

		Endif
		
	Endif

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} GtpNps( oDlg )
Chamada do APP dentro da Dialog

@param oDlg - Dialog de destino para App abrir
/*/
//-------------------------------------------------------------------
Static Function GtpNps( oDlg )
	// 1� Param: Nome da Aplica��o. Neste caso sempre s�ra `tecnps`
	// 2� Param: Dialog. Caso vazio, pega a janela inteira
	// 6� Param: Nome do fonte criado
	FWCallApp( "tecnps", oDlg, , , , "GTPANPS")
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JsToAdvpl(oWebChannel, cType, cContent)
Chamada do APP dentro da Dialog

@param oWebChannel - WebChannel para enviar informa��o para o App
@param cType - "Tipo" da chamada na chamada Via App
@param cContent - Conteudo adicional recebido do App
/*/
//-------------------------------------------------------------------
Static Function JsToAdvpl(oWebChannel, cType, cContent)
	Do Case
		Case cType == "preLoad" // O cType Preload � chamado toda vez que o app � inicializado
			appPreLoad(oWebChannel)
	EndCase
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} appPreLoad(oWebChannel)
Passa os par�metros de PreLoad para o App

@param oWebChannel - WebChannel para enviar informa��o para o App
/*/
//-------------------------------------------------------------------
Static Function appPreLoad(oWebChannel)
	// Ao chamar o oWebChannel:AdvPLToJS o Protheus ir� chamar o advpltojs que est� na pasta `assets/preload` e armazenar na SessionStorage.
	oWebChannel:AdvPLToJS( "setProdutoNPS", "GTP_DESENV")
	oWebChannel:AdvPLToJS( "setURLEndpoint", "WsGtpNps/nps" )
	oWebChannel:AdvPLToJS( "setProductLabel", "TOTVS Transporte de Passageiros" )
Return Nil
