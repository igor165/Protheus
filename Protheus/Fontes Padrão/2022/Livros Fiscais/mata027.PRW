#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'MATA027.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA027
Cadastro de codigo de enquadramento legal Cat83

@author Flavio Luiz Vicco
@since 01/07/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function MATA027()

Local oBrw := FWmBrowse():New()
    
CCV->(DbSetOrder(1)) //CCV_FILIAL+CCV_CODLEG

oBrw:SetDescription(STR0001) //Codigo de enquadramento legal Cat83
oBrw:SetAlias('CCV')
oBrw:SetMenuDef('MATA027')
oBrw:Activate()

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

ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.MATA027' OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.MATA027' OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.MATA027' OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.MATA027' OPERATION 5 ACCESS 0 //Excluir

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

Local oStru  := FWFormStruct(1,'CCV')
Local oModel := MPFormModel():New('MATA027')

oModel:SetDescription(STR0001) //Codigo de Lancamento Cat83
oModel:AddFields('MATA027',/*cOwner*/,oStru)
oModel:SetPrimaryKey({'CCV_FILIAL','CCV_CODLEG'})

oStru:SetProperty('CCV_CODLEG',MODEL_FIELD_WHEN, {||oModel:GetOperation()==3})
oStru:SetProperty('CCV_CODLEG',MODEL_FIELD_VALID,{||A027TudOk(oModel)})

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

Local oModel := FWLoadModel('MATA027')
Local oStru  := FWFormStruct(2,'CCV')
Local oView  := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEW',oStru,'MATA027')
oView:CreateHorizontalBox('CABECALHO',100)
oView:SetOwnerView('VIEW','CABECALHO')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} A027TudOk
Função de validacao se ja existe o codigo informado.
                                   	
@author Flavio Luiz Vicco
@since 01/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A027TudOk(oModel)

Local cCampo := oModel:GetValue('MATA027','CCV_CODLEG')
Local lRet   := .T.
Local lNum   := .T.
Local nPosi  := 0
Local nX     := 0

nPosi := 1   
For nX := 1 To 4
    If !IsDigit(Substr(cCampo,nPosi,1))
	   	lNum := .F.
        lRet := .F.    
		Help('',1,'A027FICHA')
	   	Exit
	EndIf
	nPosi := nPosi + 1 
Next nX   	    
If lNum
    If oModel:GetOperation()==3    
		If CCV->(dbSeek(xFilial('CCV')+cCampo))
			Help('',1,'JAGRAVADO')
			lRet := .F.
		EndIf
    EndIf
EndIf	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaHlp
Função de ajuste help da rotina

@author Flavio Luiz Vicco
@since 01/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AjustaHlp()

Local aHelpPor := {}
Local aHelpSpa := {}
Local aHelpEng := {}

//ÚÄÄÄÄÄÄÄÄ¿
//³Problema³
//ÀÄÄÄÄÄÄÄÄÙ
aHelpPor:={'Código inválido.'}
aHelpSpa:=aHelpEng:=aHelpPor
PutHelp("PA027FICHA",aHelpPor,aHelpEng,aHelpSpa,.T.)

//ÚÄÄÄÄÄÄÄ¿
//³Solucao³
//ÀÄÄÄÄÄÄÄÙ
aHelpPor:={'Informe um código numérico.'}
aHelpSpa:=aHelpEng:=aHelpPor
PutHelp("SA027FICHA",aHelpPor,aHelpEng,aHelpSpa,.T.)

Return Nil
