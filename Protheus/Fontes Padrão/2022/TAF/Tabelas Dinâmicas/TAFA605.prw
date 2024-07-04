#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA605.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA605
@description Tabela 30 - Formas de Tributação para Rendimentos de Beneficiários no Exterior
@type function
@author Melkz Siqueira
@since 12/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA605()
    
    Local oBrw as object

    oBrw := Nil

    If TAFAlsInDic("V9H")
        oBrw := FWmBrowse():New()
        
        oBrw:SetDescription(STR0001) // "Formas de Tributação para Rendimentos de Beneficiários no Exterior"
        oBrw:SetAlias("V9H")
        oBrw:SetMenuDef("TAFA605")
        oBrw:Activate()
    Else
        MsgAlert(STR0002) // "A Tabela V9H não existe na base de dados" 
    EndIf 

Return

//-------------------------------------------------------------------      
/*/{Protheus.doc} MenuDef
@description Função genérica MVC com as opções de menu
@type static function
@author Melkz Siqueira
@since 12/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF("TAFA605")

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@description Funcao generica MVC do model
@type static function
@return oModel - Objeto do Modelo MVC
@author Melkz Siqueira
@since 12/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

    Local oStruV9H as object
    Local oModel   as object

    oStruV9H := FwFormStruct(1, "V9H")
    oModel   := MpFormModel():New("TAFA605")

    oModel:AddFields("MODEL_V9H",, oStruV9H)
    oModel:GetModel("MODEL_V9H"):SetPrimaryKey({"V9H_FILIAL", "V9H_ID"})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@description Funcao generica MVC do View
@type static function
@return oView - Objeto da View MVC
@author Melkz Siqueira
@since 12/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

    Local oModel    as object
    Local oStruV9H  as object
    Local oView     as object

    oModel    := FWLoadModel("TAFA605")
    oStruV9H  := FWFormStruct(2, "V9H")
    oView     := FWFormView():New()

    oView:SetModel(oModel)
    oView:AddField("VIEW_V9H", oStruV9H, "MODEL_V9H")
    oView:EnableTitleView("VIEW_V9H", STR0001) // "Formas de Tributação para Rendimentos de Beneficiários no Exterior"
    oView:CreateHorizontalBox("FIELDSV9H", 100)
    oView:SetOwnerView("VIEW_V9H", "FIELDSV9H")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont
@description Rotina para carga e atualização da tabela autocontida - Tabela 30
@Param  nVerEmp	- Versão corrente na empresa
	    nVerAtu	- Versão atual (passado como referência)
@Return	aRet - Array com estrutura de campos e conteúdo da tabela
@type static function
@author Melkz Siqueira
@since 12/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont(nVerEmp as numeric, nVerAtu as numeric)

	Local aHeader   as array
	Local aBody     as array
	Local aRet      as array

    Default nVerEmp := 0
    Default nVerAtu := 0

    aHeader := {}
	aBody   := {}
	aRet    := {}
    nVerAtu := 1032.09

	If nVerEmp < nVerAtu
		AAdd(aHeader, "V9H_FILIAL")
		AAdd(aHeader, "V9H_ID"    )
		AAdd(aHeader, "V9H_CODIGO")
		AAdd(aHeader, "V9H_DESCRI")
		AAdd(aHeader, "V9H_VALIDA")

        AAdd(aBody, {"", "000001", "10", "RETENÇÃO DO IRRF - ALÍQUOTA PADRÃO"                                           , ""})
        AAdd(aBody, {"", "000002", "11", "RETENÇÃO DO IRRF - ALÍQUOTA DA TABELA PROGRESSIVA"                            , ""})
        AAdd(aBody, {"", "000003", "12", "RETENÇÃO DO IRRF - ALÍQUOTA DIFERENCIADA (PAÍSES COM TRIBUTAÇÃO FAVORECIDA)"  , ""})
        AAdd(aBody, {"", "000004", "13", "RETENÇÃO DO IRRF - ALÍQUOTA LIMITADA CONFORME CLÁUSULA EM CONVÊNIO"           , ""})
        AAdd(aBody, {"", "000005", "30", "RETENÇÃO DO IRRF - OUTRAS HIPÓTESES"                                          , ""})
        AAdd(aBody, {"", "000006", "40", "NÃO RETENÇÃO DO IRRF - ISENÇÃO ESTABELECIDA EM CONVÊNIO"                      , ""})
        AAdd(aBody, {"", "000007", "41", "NÃO RETENÇÃO DO IRRF - ISENÇÃO PREVISTA EM LEI INTERNA"                       , ""})
        AAdd(aBody, {"", "000008", "42", "NÃO RETENÇÃO DO IRRF - ALÍQUOTA ZERO PREVISTA EM LEI INTERNA"                 , ""})
        AAdd(aBody, {"", "000009", "43", "NÃO RETENÇÃO DO IRRF - PAGAMENTO ANTECIPADO DO IMPOSTO"                       , ""})
        AAdd(aBody, {"", "000010", "44", "NÃO RETENÇÃO DO IRRF - MEDIDA JUDICIAL"                                       , ""})
        AAdd(aBody, {"", "000011", "50", "NÃO RETENÇÃO DO IRRF - OUTRAS HIPÓTESES"                                      , ""})

		AAdd(aRet, {aHeader, aBody})
	EndIf

Return aRet
	