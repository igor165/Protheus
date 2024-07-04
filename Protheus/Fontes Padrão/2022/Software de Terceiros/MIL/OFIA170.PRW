#include "TBICONN.CH"
#include "FWMVCDEF.CH"
#include "PROTHEUS.CH"
#include "OFIA170.CH"


Static oModel01
Static oModel02

Static oUtil
Static oArrHelper
Static oSqlHlp
Static oDpm
Static oDemDpm
Static aListSM0
Static cFileName
Static oConf

/*/{Protheus.doc} OFIA170
	Tela para novas configurcoes do DPM

	@author Vinicius Gati
	@since  23/04/2019
/*/
function OFIA170()
	FWExecView(STR0001 /**"Configuração DPM" */, "OFIA170", MODEL_OPERATION_UPDATE)
return .t.

/*/{Protheus.doc} ViewDef
	Definicao da view
	
	@type function
	@author Vinicius Gati
	@since 23/04/2019
/*/
static function ViewDef()
	Local oModel  := Modeldef()
	Local oStr1
	Local oStr2

	oStr1   := oModel01:GetView()
	oStr2   := oModel02:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:CreateHorizontalBox('BOX1', 15)
	oView:CreateHorizontalBox('BOX2', 85)

	oView:AddField('BASE', oStr1, 'BASE')

	oView:AddGrid('GRID1', oStr2, 'GRID1')

	oView:SetOwnerView('BASE'  ,'BOX1')
	oView:SetOwnerView('GRID1' ,'BOX2')

	oView:EnableTitleView('BASE'  , STR0001) // Configuração DPM
	oView:EnableTitleView('GRID1' , STR0002) // Filiais Armazém

	// Retira o botão de "Salvar e Criar um Novo"
	oView:SetCloseOnOk({||.T.})
return oView

/*/{Protheus.doc} ModelDef
	Definicao do modelo
	
	@type function
	@author Vinicius Gati
	@since 23/04/2019
/*/
static function ModelDef()
	Local oModel
	Local oStr1
	Local oStr2
	Local aSM0
	Local aSM0Det
	Local ni := 0

	CONOUT("CHAMADA MODEL DEF")

	If oModel01 == NIL

		CONOUT("INICIALIZANDO OMODEL01")

		oUtil      := DMS_Util():New()
		oArrHelper := DMS_ArrayHelper():New()
		oSqlHlp    := DMS_SqlHelper():New()
		oDpm       := DMS_DPM():New()
		oDemDpm    := DMS_DemandaDPM():New()
		aSM0       := FWLoadSm0()
		aListSM0   := {}
		cFileName  := FWCodEmp() + "_dpm_config.json"
		oConf      := oUtil:ParamFileOpen(cFileName)

		For ni := 1 to len(aSM0)
			aSM0Det := aSM0[ni] // Filial Origem (Filial logada)
			if ascan( oDpm:GetFiliais(), {|oFil| oFil[1] == aSM0Det[2]} ) <= 0
				aAdd(aListSM0, aSM0Det[2] + "=" + aSM0Det[7] + "(" + aSM0Det[2] + ")")
			endif
		Next

		oModel01 := GetModel01()
		oModel02 := GetModel02()

	EndIf

	CONOUT(" ")

	oStr1 := oModel01:GetModel()
	oStr2 := oModel02:GetModel()


	oModel := MPFormModel():New('OFIA170',,,{ |oModel| OA1700014_Confirmar(oModel) })
	oModel:SetDescription(STR0001) // Configuração DPM
	
	oModel:AddFields("BASE",,oStr1,,,{|| Load01Dados() })
	oModel:GetModel("BASE"):SetDescription(STR0001) // "Configuração DPM"

	oModel:AddGrid("GRID1","BASE", oStr2,,,,,{|| Load02Dados() })
	oModel:GetModel("GRID1"):SetDescription(STR0002) // Filiais Armazém
	oModel:GetModel("GRID1"):SetOptional(.T.)

	oModel:SetPrimaryKey({})
return oModel

/*/{Protheus.doc} GetModel01
	Definicao da struct usada no filtro
	
	@type function
	@author Vinicius Gati
	@since 23/04/2019
/*/
Static Function GetModel01()
	Local oMd1 := OFDMSStruct():New()
	oMd1:AddField({;
		{'cTitulo'  , STR0003             },; // Debugando
		{'cIdField' , "DEBUGANDO"         },;
		{'nTamanho' , 1                   },;
		{'aComboValues', {"0="+STR0009,"1="+STR0008}},;
		{'lObrigat' , .T.                 },;
		{'cTooltip' , STR0003             } ;
	})
return oMd1

/*/{Protheus.doc} Load01Dados
	default values for the filter
	
	@type function
	@author Vinicius Gati
	@since 23/04/2019
/*/
static function Load01Dados()
return {;
	{;
		oConf:GetValue('DEBUGANDO', '0') ;
	}, 0;
}

/*/{Protheus.doc} GetModel02
	Definicao da struct usada no filtro
	
	@type function
	@author Vinicius Gati
	@since 23/04/2019
/*/
Static Function GetModel02()
	Local oMd2 := OFDMSStruct():New()
	oMd2:AddField({;
		{'cTitulo'  , STR0005             },; // Filial
		{'cIdField' , "CFG_ARM_FILIAL"    },;
		{'nTamanho' , len(xFilial('VS3')) },;
		{'lObrigat' , .F.                 },;
		{'aComboValues', OA1700024_dpmFiliais() },;
		{'cTooltip' , STR0004             } ; // Filial que receberá os dados de outra
	})
	oMd2:AddField({;
		{'cTitulo'  , STR0006             },; // Filial Armazém
		{'cIdField' , "CFG_ARM_FILARM"    },;
		{'nTamanho' , len(xFilial('VS3')) },;
		{'aComboValues', aListSM0         },;
		{'cTooltip' , STR0007             } ; // Filial que será fonte dos dados de armazém de outra
	})
return oMd2

/*/{Protheus.doc} Load02Dados
	default values for the grid
	
	@type function
	@author Vinicius Gati
	@since 23/04/2019
/*/
static function Load02Dados()
	local aData := oArrHelper:Map(oConf:GetValue("FILIAIS_ARMAZEM",{}), {|oEl| {0,{oEl:GetValue('FILIAL', ''), oEl:GetValue('FILIAL_ARM', '')}} })
return aData


/*/{Protheus.doc} OA1700014_Confirmar
	Salva os dados preenchidos na tela
	
	@type function
	@author Vinicius Gati
	@since 31/05/2019
/*/
static function OA1700014_Confirmar(oModel)
	Local nX := 1
	Local aDados   := {}
	Local aFilArms := {}
	Local oBase    := oModel:GetModel("BASE")
	Local oGrid1   := oModel:GetModel("GRID1")
	aadd(aDados, {"DEBUGANDO", oBase:GetValue("DEBUGANDO")})

	for nX := 1 to oGrid1:Length()
		oGrid1:GoLine(nX)
		if ! oGrid1:IsDeleted()
			oFilArm := DMS_DataContainer():New({;
				{'FILIAL'    , oGrid1:GetValue('CFG_ARM_FILIAL') },;
				{'FILIAL_ARM', oGrid1:GetValue('CFG_ARM_FILARM') } ;
			})
			AADD(aFilArms, oFilArm)
		endif
	next
	aadd(aDados, {"FILIAIS_ARMAZEM", aFilArms})

	oDados := DMS_DataContainer():NEW(aDados)
	oUtil:ParamFileSave(cFileName, oDados)
return .t.

/*/{Protheus.doc} OA1700024_dpmFiliais
	returns the branchs that is configured as john deere brand, the parameter is MV_MIL0005

    @author Vinicius Gati
    @since  23/04/2019
/*/
static function OA1700024_dpmFiliais()
	Local aFilis     := oDpm:GetFiliais()
	Local aFilFiltro := {}
	oArrHelper:each(aFilis, {|aFilData| aadd(aFilFiltro,  alltrim(aFilData[1]) + "=" + alltrim(aFilData[1]) + " (" + alltrim(aFilData[2]) + ")")})
return aFilFiltro
