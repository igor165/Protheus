#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#include "PROTHEUS.CH"
#INCLUDE "OFIA410.CH"

static oFIA410ModStru

/*/{Protheus.doc} OFIA410
	Tela de configuração do DTF JD

	@author Jose Luis Silveira Filho
	@since  17/08/2021
/*/
Function OFIA410()
	//Private oModel1   := GetModel01()

	Private oConfig   := OFJDDTFConfig():New()
	Private oCfgAtu   := oConfig:GetConfig()

	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0001)//"Diretorios DTF"
	oExecView:setSource("OFIA410")
	oExecView:setOK({ |oModel| OA410001A_Confirmar(oModel) })
	oExecView:setCancel({ || .T. })
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)
Return .T.

/*/{Protheus.doc} OA410001A_Confirmar
	Salva os dados e fecha janela de configuração
	
	@type function
	@author Jose Luis Silveira Filho
	@since 17/08/2021
/*/
static function OA410001A_Confirmar(oForm)

	Local oDTFConfig      := OFJDDTFConfig():New()
	local oMaster  := oForm:GetModel("MASTER")
	
	oCfgAtu["CGPoll"]                  := AllTrim(oMaster:GetValue("CGPoll"))
	oCfgAtu["Cotacao_Maquina"]         := AllTrim(oMaster:GetValue("Cotacao_Maquina"))
	oCfgAtu["PMMANAGE"]                := AllTrim(oMaster:GetValue("PMMANAGE"))
	oCfgAtu["DPMEXT"]                  := AllTrim(oMaster:GetValue("DPMEXT"))
	oCfgAtu["Warranty"]                := AllTrim(oMaster:GetValue("Warranty"))
	oCfgAtu["Incentivo_Maquina"]       := AllTrim(oMaster:GetValue("Incentivo_Maquina"))
	oCfgAtu["UP_Incentivo_Maquina"]    := AllTrim(oMaster:GetValue("UP_Incentivo_Maquina"))
	oCfgAtu["JDPRISM"]                 := AllTrim(oMaster:GetValue("JDPRISM"))
	oCfgAtu["Parts_Info"]              := AllTrim(oMaster:GetValue("Parts_Info"))
	oCfgAtu["Parts_Locator"]           := AllTrim(oMaster:GetValue("Parts_Locator"))
	oCfgAtu["Authorized_Parts_Returns"]:= AllTrim(oMaster:GetValue("Authorized_Parts_Returns"))
	oCfgAtu["Parts_Surplus_Returns"]   := AllTrim(oMaster:GetValue("Parts_Surplus_Returns"))
	oCfgAtu["Parts_Subs"]              := AllTrim(oMaster:GetValue("Parts_Subs"))
	oCfgAtu["SMManage"]                := AllTrim(oMaster:GetValue("SMManage"))
	oCfgAtu["DFA"]                     := AllTrim(oMaster:GetValue("DFA"))
	oCfgAtu["ELIPS"]                   := AllTrim(oMaster:GetValue("ELIPS"))
	oCfgAtu["NAO_CLASSIFICADOS"]       := AllTrim(oMaster:GetValue("NAO_CLASSIFICADOS"))

	oConfig:SaveConfig(oCfgAtu)

	oDTFConfig:GetConfig()
	oDTFConfig:criaDirDTF()

return .t.

/*/{Protheus.doc} ViewDef
	Definição da tela principal
	
	@type function
	@author Jose Luis Silveira Filho
	@since 17/08/2021
/*/
Static Function ViewDef()
	Local oModel  := Modeldef()
	Local oStr1

	oStr1   := oFIA410ModStru:GetView()

	oStr1:AddFolder("DTF",STR0002)//"DTFAPI"
	
	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:CreateHorizontalBox('TELA', 100)

	oView:AddField('FORM1', oStr1, 'MASTER')
	
	oView:SetOwnerView('FORM1','TELA')

Return oView

/*/{Protheus.doc} ModelDef
	Modelo
	
	@type function
	@author Jose Luis Silveira Filho
	@since 17/08/2021
/*/
Static Function Modeldef()
	Local oModel
	Local oStr1

	if oFIA410ModStru == nil
		oFIA410ModStru := GetModel01()
	endif

	oStr1 := oFIA410ModStru:GetModel()

	oModel := MPFormModel():New('OFIA410')
	oModel:SetDescription(STR0003) // 'Integração John Deere'
	
	oModel:AddFields("MASTER",,oStr1,,,{|| OA410002A_Load01Dados() })

	oModel:getModel("MASTER"):SetDescription(STR0004)//"Configurações - DTF" 

	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} GetModel01
	Dados base do funcionamento
	
	@type function
	@author Jose Luis Silveira Filho
	@since 17/08/2021
/*/
Static Function GetModel01()

	Local oMd1 := OFDMSStruct():New()

	oMd1:AddField({;
		{'cTitulo'     , 'CGPoll'},;
		{'nTamanho'    , 50          },;		
		{'cIdField'    , 'CGPoll'      },;
		{'cFolder'     , 'DTF'      },;
		{'lObrigat'    , .F.        },;
		{'cPicture'    , ''        },;		
		{'cTooltip'    , STR0006} ;//"Diretorio CGPoll" 
	})

	oMd1:AddField({;
		{'cTitulo'     , 'Cotacao_Maquina'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'Cotacao_Maquina'      },;
		{'cFolder'    , 'DTF'      },;
		{'lObrigat'    , .F.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0007} ; //"Diretorio Cotacao_Maquina"
	})

	oMd1:AddField({;
		{'cTitulo'     , 'PMMANAGE'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'PMMANAGE'      },;
		{'cFolder'    , 'DTF'      },;
		{'lObrigat'    , .F.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0008} ; //"Diretorio PMMANAGE"
	})

	oMd1:AddField({;
		{'cTitulo'     , 'DPMEXT'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'DPMEXT'      },;
		{'cFolder'    , 'DTF'      },;
		{'lObrigat'    , .F.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0009} ;//"Diretorio DPMEXT" 
	})

	oMd1:AddField({;
		{'cTitulo'     , 'Warranty'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'Warranty'      },;
		{'cFolder'    , 'DTF'      },;
		{'lObrigat'    , .F.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0010} ;//"Diretorio Warranty" 
	})

	oMd1:AddField({;
		{'cTitulo'     , 'Incentivo_Maquina'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'Incentivo_Maquina'      },;
		{'cFolder'    , 'DTF'      },;
		{'lObrigat'    , .F.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0011} ;//"Diretorio Incentivo_Maquina" 
	})

	oMd1:AddField({;
		{'cTitulo'     , 'UP_Incentivo_Maquina'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'UP_Incentivo_Maquina'      },;
		{'cFolder'    , 'DTF'      },;
		{'lObrigat'    , .F.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0022} ;//"Diretorio Incentivo_Maquina" 
	})

	oMd1:AddField({;
		{'cTitulo'     , 'JDPRISM'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'JDPRISM'      },;
		{'cFolder'    , 'DTF'      },;
		{'lObrigat'    , .F.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0012} ;//"Diretorio JDPRISM" 
	})

	oMd1:AddField({;
		{'cTitulo'     , 'Parts_Info'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'Parts_Info'      },;
		{'cFolder'    , 'DTF'      },;
		{'lObrigat'    , .F.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0013} ;//"Diretorio Parts_Info" 
	})

	oMd1:AddField({;
		{'cTitulo'     , 'Parts_Locator'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'Parts_Locator'      },;
		{'cFolder'    , 'DTF'      },;
		{'lObrigat'    , .F.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0014} ;//"Diretorio Parts_Locator" 
	})

	oMd1:AddField({;
		{'cTitulo'     , 'Authorized_Parts_Returns'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'Authorized_Parts_Returns'      },;
		{'cFolder'    , 'DTF'      },;
		{'lObrigat'    , .F.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0015} ;//"Diretorio Authorized_Parts_Returns" 
	})

	oMd1:AddField({;
		{'cTitulo'     , 'Parts_Surplus_Returns'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'Parts_Surplus_Returns'      },;
		{'cFolder'    , 'DTF'      },;
		{'lObrigat'    , .F.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0016} ;//"Diretorio Parts_Surplus_Returns" 
	})

	oMd1:AddField({;
		{'cTitulo'     , 'Parts_Subs'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'Parts_Subs'      },;
		{'cFolder'    , 'DTF'      },;
		{'lObrigat'    , .F.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0017} ;//"Diretorio Parts_Subs" 
	})

	oMd1:AddField({;
		{'cTitulo'     , 'SMManage'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'SMManage'      },;
		{'cFolder'    , 'DTF'      },;
		{'lObrigat'    , .F.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0018} ;//"Diretorio SMManage" 
	})

	oMd1:AddField({;
		{'cTitulo'     , 'DFA'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'DFA'      },;
		{'cFolder'    , 'DTF'      },;
		{'lObrigat'    , .F.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0019} ;//"Diretorio DFA" 
	})

	oMd1:AddField({;
		{'cTitulo'     , 'ELIPS'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'ELIPS'      },;
		{'cFolder'    , 'DTF'      },;
		{'lObrigat'    , .F.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0020} ;//"Diretorio ELIPS" 
	})

	oMd1:AddField({;
		{'cTitulo'     , 'NAO_CLASSIFICADOS'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'NAO_CLASSIFICADOS'      },;
		{'cFolder'    , 'DTF'      },;
		{'lObrigat'    , .F.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0021} ; //"Diretorio Não Classificados"
	})

return oMd1

/*/{Protheus.doc} OA410002A_Load01Dados
	Dados da entidade principal
	
	@type function5
	@author Jose Luis Silveira Filho
	@since 17/08/2021
/*/
Static function OA410002A_Load01Dados()

//Local oDTFConfig      := OFJDDTFConfig():New()
//
//	oDTFConfig:GetConfig()
//	oDTFConfig:criaDirDTF()

Return {{;
	PadR(oCfgAtu['CGPoll'                  ],50),;
	PadR(oCfgAtu['Cotacao_Maquina'         ],50),;
	PadR(oCfgAtu['PMMANAGE'                ],50),;
	PadR(oCfgAtu['DPMEXT'                  ],50),;
	PadR(oCfgAtu['Warranty'                ],50),;
	PadR(oCfgAtu['Incentivo_Maquina'       ],50),;
	PadR(oCfgAtu['UP_Incentivo_Maquina'    ],50),;
	PadR(oCfgAtu['JDPRISM'                 ],50),;
	PadR(oCfgAtu['Parts_Info'              ],50),;
	PadR(oCfgAtu['Parts_Locator'           ],50),;
	PadR(oCfgAtu['Authorized_Parts_Returns'],50),;
	PadR(oCfgAtu['Parts_Surplus_Returns'   ],50),;
	PadR(oCfgAtu['Parts_Subs'              ],50),;
	PadR(oCfgAtu['SMManage'                ],50),;
	PadR(oCfgAtu['DFA'                     ],50),;
	PadR(oCfgAtu['ELIPS'                   ],50),;
	PadR(oCfgAtu['NAO_CLASSIFICADOS'       ],50);
	} , 0}

