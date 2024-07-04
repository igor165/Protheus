#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#include "PROTHEUS.CH"

#INCLUDE "OFIA280.CH"

static oFIA280ModStru

/*/{Protheus.doc} OFIA280
	Tela de configuração do OKTA John Deere

	@author Vinicius Gati
	@since  17/01/2020
/*/
Function OFIA280()
	//Private oFIA280ModStru   := GetModel01()

	Private oConfig   := OFJDOktaConfig():New()
	Private oCfgAtu   := oConfig:GetConfig()

	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0001) // "Configurações OKTA - John Deere"
	oExecView:setSource("OFIA280")
	oExecView:setOK({ |oModel| OA2800013_Confirmar(oModel) })
	oExecView:setCancel({ || .T. })
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)
Return .T.

/*/{Protheus.doc} OA2800013_Confirmar
	Salva os dados e fecha janela de configuração
	
	@type function
	@author Vinicius Gati
	@since 17/01/2020
/*/
static function OA2800013_Confirmar(oForm)
	local oMaster  := oForm:GetModel("MASTER")
	local nCntFor
	local cPref
	
	oCfgAtu["OKTA_ID"]  := AllTrim(oMaster:GetValue("OKTA_ID"))
	oCfgAtu["OKTA_SEC"] := AllTrim(oMaster:GetValue("OKTA_SEC"))
	oCfgAtu["OKTA_REDURI"] := AllTrim(oMaster:GetValue("OKTA_REDURI"))

	For nCntFor := 1 to 8

		Do Case
			Case nCntFor == 1 ; cPref := "WAR"
			Case nCntFor == 2 ; cPref := "PML"
			Case nCntFor == 3 ; cPref := "JDP"
			Case nCntFor == 4 ; cPref := "QTM"
			Case nCntFor == 5 ; cPref := "QTP"
			Case nCntFor == 6 ; cPref := "NFS"
			Case nCntFor == 7 ; cPref := "DTFG"
			Case nCntFor == 8 ; cPref := "DTFP"
		EndCase

		oCfgAtu[ cPref + 'OKTA'    ] := oMaster:GetValue( cPref + 'OKTA'    )
		oCfgAtu[ cPref + 'URL'     ] := AllTrim(oMaster:GetValue( cPref + 'URL'     ))
		oCfgAtu[ cPref + 'AUTHSRV' ] := AllTrim(oMaster:GetValue( cPref + 'AUTHSRV' ))
		oCfgAtu[ cPref + 'URLAUTH' ] := AllTrim(oMaster:GetValue( cPref + 'URLAUTH' ))
		oCfgAtu[ cPref + 'SCOPE'   ] := AllTrim(oMaster:GetValue( cPref + 'SCOPE'   ))
		oCfgAtu[ cPref + 'URLWS'   ] := AllTrim(oMaster:GetValue( cPref + 'URLWS'   ))

	Next nCntFor

	oConfig:SaveConfig(oCfgAtu)
return .t.

/*/{Protheus.doc} ViewDef
	Definição da tela principal
	
	@type function
	@author Vinicius Gati
	@since 17/01/2020
/*/
Static Function ViewDef()
	Local oModel  := Modeldef()
	Local oStr1
	
	oStr1 := oFIA280ModStru:GetView()

	oStr1:AddFolder("GER",STR0002) // "Geral"
	oStr1:AddFolder("WAR",STR0003) // "Garantia"
	oStr1:AddFolder("JDP","JDPoint")
	oStr1:AddFolder("JDQ","JDQuote2")
	oStr1:AddFolder("NFS",STR0004) // "Nota fiscal de Compra"
	oStr1:AddFolder("DTFG",STR0016)//"DTFGETAPI"
	oStr1:AddFolder("DTFP",STR0017)//"DTFPUTAPI"

	oStr1:AddGroup("PML","PMLink","JDP",2)
	oStr1:AddGroup("ORD","Order Status","JDP",2)
	oStr1:AddGroup("QTM","Maintain Quote","JDQ",2)
	oStr1:AddGroup("QTP","Purchase Order","JDQ",2)
	
	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:CreateHorizontalBox('TELA', 100)

	oView:AddField('FORM1', oStr1, 'MASTER')
	
	oView:SetOwnerView('FORM1','TELA')

Return oView

/*/{Protheus.doc} ModelDef
	Modelo
	
	@type function
	@author Vinicius Gati
	@since 17/01/2020
/*/
Static Function Modeldef()
	Local oModel
	Local oStr1

	if oFIA280ModStru == NIL
		oFIA280ModStru := GetModel01()
	endif
	
	oStr1 := oFIA280ModStru:GetModel()

	oModel := MPFormModel():New('OFIA280')
	oModel:SetDescription(STR0005) // 'Integração John Deere'
	
	oModel:AddFields("MASTER",,oStr1,,,{|| OA2600024_Load01Dados() })

	oModel:getModel("MASTER"):SetDescription(STR0006) // "Configurações - Okta"

	oModel:SetPrimaryKey({})
Return oModel

/*/{Protheus.doc} GetModel01
	Dados base do funcionamento
	
	@type function
	@author Vinicius Gati
	@since 17/01/2020
/*/
Static Function GetModel01()

	Local oMd1 := OFDMSStruct():New()
	Local cPref := ""
	Local nCntFor
	
	oMd1:AddField({;
		{'cTitulo'     , 'Client ID'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'OKTA_ID'      },;
		{'cFolder'    , 'GER'      },;
		{'lObrigat'    , .T.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0007} ; // 'Client ID para obter Token de autenticação.'
	})

	oMd1:AddField({;
		{'cTitulo'     , 'Client Secret'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'OKTA_SEC'      },;
		{'cFolder'    , 'GER'      },;
		{'lObrigat'    , .T.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0008 } ; // 'Client Secret para obter Token de autenticação.'
	})

	oMd1:AddField({;
		{'cTitulo'     , 'Redirect URI'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'OKTA_REDURI'      },;
		{'cFolder'    , 'GER'      },;
		{'lObrigat'    , .T.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0009 } ; // 'URI de redirecionamento.'
	})

	For nCntFor := 1 to 8

		cFolder := ""
		cGroup := ""
		Do Case
			Case nCntFor == 1
				cPref := "WAR"
				cFolder := "WAR"
			Case nCntFor == 2
				cPref := "PML"
				cFolder := "JDP"
				cGroup := "PML"
			Case nCntFor == 3
				cPref := "JDP"
				cFolder := "JDP"
				cGroup := "ORD"
			Case nCntFor == 4
				cPref := "QTM"
				cFolder := "JDQ"
				cGroup := "QTM"
			Case nCntFor == 5
				cPref := "QTP"
				cFolder := "JDQ"
				cGroup := "QTP"
			Case nCntFor == 6
				cPref := "NFS"
				cFolder := "NFS"
			Case nCntFor == 7
				cPref := "DTFG"
				cFolder := "DTFG"
			Case nCntFor == 8
				cPref := "DTFP"
				cFolder := "DTFP"
		EndCase

		oMd1:AddField({;
			{'cTitulo'     , 'OAuth2'},;
			{'nTamanho'    , 1          },;
			{'cIdField'    , cPref + 'OKTA'      },;
			{'cFolder'    , cFolder      },;
			{'cGroup'    , cGroup      },;
			{'lObrigat'    , .T.        },;
			{'aComboValues', {'0=Não', '1=Sim'} },;
			{'cPicture'    , ''        },;
			{'bValid'      , FWBuildFeature( STRUCT_FEATURE_VALID, "Pertence('01')") },;
			{'bInit'       , FWBuildFeature( STRUCT_FEATURE_INIPAD, "'0'") },;
			{'cTooltip'    , STR0010 } ; // 'Utiliza OAuth2 para autenticação com o WebService'
		})

		oMd1:AddField({;
			{'cTitulo'     , 'URL Token'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref + 'URL'      },;
			{'cFolder'    , cFolder      },;
			{'cGroup'    , cGroup      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0011 } ; // 'URL para obtenção do Token'
		})

		oMd1:AddField({;
			{'cTitulo'     , 'Auth Server'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref + 'AUTHSRV'      },;
			{'cFolder'    , cFolder      },;
			{'cGroup'    , cGroup      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0012 } ; // 'ID do servidor de autenticação'
		})

		oMd1:AddField({;
			{'cTitulo'     , 'URL Auth'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref + 'URLAUTH'      },;
			{'cFolder'    , cFolder      },;
			{'cGroup'    , cGroup      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0013 } ; // 'URL de Autenticação'
		})

		oMd1:AddField({;
			{'cTitulo'     , 'Escopo'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref + 'SCOPE'      },;
			{'cFolder'    , cFolder      },;
			{'cGroup'    , cGroup      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0014 } ; // 'Informe o escopo de conexão'
		})

		oMd1:AddField({;
			{'cTitulo'     , 'URL WS'},;
			{'nTamanho'    , 150          },;
			{'cIdField'    , cPref + 'URLWS'      },;
			{'cFolder'    , cFolder      },;
			{'cGroup'    , cGroup      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0015 } ; // 'URL do WebService'
		})

	Next nCntFor

return oMd1

/*/{Protheus.doc} OA2600024_Load01Dados
	Dados da entidade principal
	
	@type function5
	@author Vinicius Gati
	@since 17/01/2020
/*/
static function OA2600024_Load01Dados()
Return {{;
	PadR(oCfgAtu['OKTA_ID'],50)  ,;
	PadR(oCfgAtu['OKTA_SEC'],50) ,;
	PadR(oCfgAtu['OKTA_REDURI'],50) ,;
	oCfgAtu['WAROKTA'] , PadR(oCfgAtu['WARURL'],50) , PadR(oCfgAtu['WARAUTHSRV'],50) , PadR(oCfgAtu['WARURLAUTH'],50) , PadR(oCfgAtu['WARSCOPE'],50) , PadR(oCfgAtu['WARURLWS'],150) ,;
	oCfgAtu['PMLOKTA'] , PadR(oCfgAtu['PMLURL'],50) , PadR(oCfgAtu['PMLAUTHSRV'],50) , PadR(oCfgAtu['PMLURLAUTH'],50) , PadR(oCfgAtu['PMLSCOPE'],50) , PadR(oCfgAtu['PMLURLWS'],150) ,;
	oCfgAtu['JDPOKTA'] , PadR(oCfgAtu['JDPURL'],50) , PadR(oCfgAtu['JDPAUTHSRV'],50) , PadR(oCfgAtu['JDPURLAUTH'],50) , PadR(oCfgAtu['JDPSCOPE'],50) , PadR(oCfgAtu['JDPURLWS'],150) ,;
	oCfgAtu['QTMOKTA'] , PadR(oCfgAtu['QTMURL'],50) , PadR(oCfgAtu['QTMAUTHSRV'],50) , PadR(oCfgAtu['QTMURLAUTH'],50) , PadR(oCfgAtu['QTMSCOPE'],50) , PadR(oCfgAtu['QTMURLWS'],150) ,;
	oCfgAtu['QTPOKTA'] , PadR(oCfgAtu['QTPURL'],50) , PadR(oCfgAtu['QTPAUTHSRV'],50) , PadR(oCfgAtu['QTPURLAUTH'],50) , PadR(oCfgAtu['QTPSCOPE'],50) , PadR(oCfgAtu['QTPURLWS'],150) ,;
	oCfgAtu['NFSOKTA'] , PadR(oCfgAtu['NFSURL'],50) , PadR(oCfgAtu['NFSAUTHSRV'],50) , PadR(oCfgAtu['NFSURLAUTH'],50) , PadR(oCfgAtu['NFSSCOPE'],50) , PadR(oCfgAtu['NFSURLWS'],150) ,;
	oCfgAtu['DTFGOKTA'] , PadR(oCfgAtu['DTFGURL'],50) , PadR(oCfgAtu['DTFGAUTHSRV'],50) , PadR(oCfgAtu['DTFGURLAUTH'],50) , PadR(oCfgAtu['DTFGSCOPE'],50) , PadR(oCfgAtu['DTFGURLWS'],150) ,;
	oCfgAtu['DTFPOKTA'] , PadR(oCfgAtu['DTFPURL'],50) , PadR(oCfgAtu['DTFPAUTHSRV'],50) , PadR(oCfgAtu['DTFPURLAUTH'],50) , PadR(oCfgAtu['DTFPSCOPE'],50) , PadR(oCfgAtu['DTFPURLWS'],150) ;
	} , 0}

