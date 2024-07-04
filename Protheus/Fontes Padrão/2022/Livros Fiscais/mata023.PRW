#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'MATA023.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA023
Cadastro de codigo de Lancamento Cat83

@author Flavio Luiz Vicco
@since 01/07/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function MATA023()
    
    Local oBrw := FWmBrowse():New()
    
    If AliasIndic('CDZ')
        
        CDZ->(DbSetOrder(1)) //CDZ_FILIAL+CDZ_CODLAN
        
        oBrw:SetDescription(STR0001) //Codigo de Lancamento Cat83
        oBrw:SetAlias('CDZ')
        oBrw:SetMenuDef('MATA023')
        oBrw:Activate()
    ELSE
        Alert('Dicionário está desatualizado, por favor verifique atualização das tabelas')
    ENDIF
    
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Flavio Luiz Vicco
@since 01/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.MATA023' OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.MATA023' OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.MATA023' OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.MATA023' OPERATION 5 ACCESS 0 //Excluir

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Flavio Luiz Vicco
@since 01/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStru  := FWFormStruct(1,'CDZ')
Local oModel := MPFormModel():New('MATA023')

oModel:SetDescription(STR0001) //Codigo de Lancamento Cat83
oModel:AddFields('MATA023',/*cOwner*/,oStru)
oModel:SetPrimaryKey({'CDZ_FILIAL','CDZ_CODLAN'})

oStru:SetProperty('CDZ_CODLAN',MODEL_FIELD_WHEN, {||oModel:GetOperation()==3})
oStru:SetProperty('CDZ_CODLAN',MODEL_FIELD_VALID,{||A023TudOk(oModel)})
oStru:SetProperty('CDZ_CODLAN',MODEL_FIELD_OBRIGAT,.T.)
oStru:SetProperty('CDZ_DESCR' ,MODEL_FIELD_OBRIGAT,.T.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Flavio Luiz Vicco
@since 01/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel := FWLoadModel('MATA023')
Local oStru  := FWFormStruct(2,'CDZ',{|cCampo|AllTrim(cCampo)<>'CDZ_FILIAL'})
Local oView  := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEW',oStru,'MATA023')
oView:CreateHorizontalBox('CABECALHO',100)
oView:SetOwnerView('VIEW','CABECALHO')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} A023TudOk
Função de validacao se ja existe o codigo de lancamento informado.

@author Flavio Luiz Vicco
@since 01/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A023TudOk(oModel)

Local cCampo := oModel:GetValue('MATA023','CDZ_CODLAN')
Local lRet   :=.T.

If oModel:GetOperation()==3
	CDZ->(DbSetOrder(1)) //CDZ_FILIAL+CDZ_CODLAN
	If CDZ->(DbSeek(xFilial('CDZ')+cCampo))
		Help('',1,'JAGRAVADO')
		lRet := .F.
	EndIf
EndIf

Return lRet


