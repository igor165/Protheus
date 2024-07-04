#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA060.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA060()
Filial de Referência por UF
 
 @sample	GTPA060()
 @return	oBrowse
 @author	Flavio Martins
@since		14/02/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA060()
Local oBrowse		:= Nil	
Private aRotina 	:= MenuDef()
If GTPxVldDic('GZR')
	
	oBrowse := FwMBrowse():New()
	oBrowse:SetAlias('GZR')
	oBrowse:SetDescription(STR0001)	// "Filial de Referência por UF"
	oBrowse:Activate()
Else
    FwAlertHelp(STR0013, STR0012)//"Atenção"#"Dicionário desatualizado."
EndIf
Return ( oBrowse )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Retorna as opções do Menu
 
@author	Flavio Martins 
@since		14/02/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE STR0002    ACTION 'VIEWDEF.GTPA060' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0003	ACTION 'VIEWDEF.GTPA060' OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0004	ACTION 'VIEWDEF.GTPA060' OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0005	ACTION 'VIEWDEF.GTPA060' OPERATION 5 ACCESS 0 // Excluir

Return ( aRotina )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	Flavio Martins
@since		14/02/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel := nil
Local oStruGZR 
Local bPosValid
If GTPxVldDic('GZR')
    oStruGZR := FWFormStruct(1,'GZR',,.F.)
    bPosValid	:= {|oModel|GTPA060TdOK(oModel)}

    If GZR->(FIELDPOS("GZR_UF"))
        oStruGZR:AddTrigger("GZR_UF","GZR_UF",{ || .T. }, { |oMdl,cField|GA060Trig(oMdl,cField)})
    EndIf

    If GZR->(FIELDPOS("GZR_FILREF"))
        oStruGZR:AddTrigger("GZR_FILREF","GZR_FILREF",{ || .T. }, { |oMdl,cField|GA060Trig(oMdl,cField)})
    EndIf
    If GZR->(FIELDPOS("GZR_CLIENT"))
        oStruGZR:AddTrigger("GZR_CLIENT","GZR_CLIENT",{ || .T. }, { |oMdl,cField|GA060Trig(oMdl,cField)})
    EndIf
    If GZR->(FIELDPOS("GZR_LOJA"))
        oStruGZR:AddTrigger("GZR_LOJA","GZR_LOJA",{ || .T. }, { |oMdl,cField|GA060Trig(oMdl,cField)})
    EndIf
    If GZR->(FIELDPOS("GZR_CLIENT"))
        oStruGZR:SetProperty("GZR_CLIENT", MODEL_FIELD_OBRIGAT, .F.)
    EndIf
    If GZR->(FIELDPOS("GZR_LOJA"))
        oStruGZR:SetProperty("GZR_LOJA"  , MODEL_FIELD_OBRIGAT, .F.)
    EndIf
    If GZR->(FIELDPOS("GZR_CLIENT"))
        oStruGZR:SetProperty('GZR_CLIENT', MODEL_FIELD_VALID ,{|oMdl,cField,cNewValue,cOldValue| Empty(FwFldGet("GZR_CLIENT")) .Or. ExistCpo("SA1",FwFldGet("GZR_CLIENT"))})
    EndIf
    If GZR->(FIELDPOS("GZR_LOJA"))
        oStruGZR:SetProperty('GZR_LOJA', MODEL_FIELD_VALID ,{|oMdl,cField,cNewValue,cOldValue| IIF( !Empty(FwFldGet("GZR_CLIENT")) .AND. !Empty(FwFldGet("GZR_LOJA")), ExistCpo("SA1",FwFldGet("GZR_CLIENT")+FwFldGet("GZR_LOJA")),.T.) }) 
    EndIf 
    oModel := MPFormModel():New('GTPA060', /*bPreValidacao*/, bPosValid, /*bCommit*/, /*bCancel*/)

    oModel:AddFields('GZRMASTER',/*cOwner*/,oStruGZR)

    oModel:SetDescription(STR0001)                          // "Filial de Referência Por UF"
    oModel:GetModel('GZRMASTER'):SetDescription(STR0006)	// "Dados"
    If GZR->(FIELDPOS("GZR_LOJA")) .OR. GZR->(FIELDPOS("GZR_UF"))
        oModel:SetPrimaryKey({"GZR_FILIAL","GZR_UF"})
    EndIf

    If GZR->(FIELDPOS("GZR_UF"))
        oStruGZR:SetProperty('GZR_UF', MODEL_FIELD_VALID ,{|oMdl,cField,cNewValue,cOldValue| GA060Valid(oMdl,cField,cNewValue,cOldValue)})
    EndIf
    If GZR->(FIELDPOS("GZR_FILREF"))
        oStruGZR:SetProperty('GZR_FILREF', MODEL_FIELD_VALID ,{|oMdl,cField,cNewValue,cOldValue| GA060Valid(oMdl,cField,cNewValue,cOldValue)})
    EndIf
Else
    FwAlertHelp(STR0013, STR0012)//"Atenção"#"Dicionário desatualizado."
EndIf
Return ( oModel )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface
 
@sample	ViewDef()
 
@return	oView  Retorna a View
 
@author	Flavio Martins
@since		14/02/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel	
Local oView		
Local oStruGZR	
If GTPxVldDic('GZR')
    oModel	:= ModelDef() 
    oView		:= FWFormView():New()
    oStruGZR	:= FWFormStruct(2, 'GZR')
    If GZR->(FIELDPOS("GZR_UF"))
        oStruGZR:SetProperty("GZR_UF", MVC_VIEW_PICT, '@!')
    EndIf
    If GZR->(FIELDPOS("GZR_FILREF"))
        oStruGZR:SetProperty("GZR_FILREF", MVC_VIEW_PICT, '@!')
    EndIf
    oView:SetModel(oModel)
    oView:SetDescription(STR0001) // "Filial de Referência Por UF"

    oView:AddField('VIEW_GZR' ,oStruGZR,'GZRMASTER')
Else
    FwAlertHelp(STR0013, STR0012)//"Atenção"#"Dicionário desatualizado."
EndIf
Return ( oView )

/*/{Protheus.doc} GA060Trig()
@author flavio.martins
@since 17/02/2020
@version 1.0
@return ${return}, ${return_description}
@param oMdl, object, descricao
@param cField, characters, descricao
@param cNewValue, characters, descricao
@param cOldValue, characters, descricao
@type function
/*/
Static Function GA060Trig(oMdl, cField)
Local lRet := .T.

If cField == 'GZR_UF'
    oMdl:ClearField('GZR_FILREF')
Endif

If cField == 'GZR_FILREF'
    oMdl:SetValue('GZR_NOMFIL',  FwFilialName(,oMdl:GetValue('GZR_FILREF')))
Endif

If cField $ 'GZR_CLIENT|GZR_LOJA' .AND. !Empty( oMdl:GetValue('GZR_CLIENT') ) .AND. !Empty( oMdl:GetValue('GZR_LOJA') )
    oMdl:SetValue('GZR_NOMCLI', Posicione("SA1", 1, xFilial("SA1")+oMdl:GetValue('GZR_CLIENT')+oMdl:GetValue('GZR_LOJA'), "A1_NOME"))                      
Endif

Return lRet

/*/{Protheus.doc} GA060Valid
@author flavio.martins
@since 17/02/2020
@version 1.0
@return ${return}, ${return_description}
@param oMdl, object, descricao
@param cField, characters, descricao
@param cNewValue, characters, descricao
@param cOldValue, characters, descricao
@type function
/*/
Static Function GA060Valid(oMdl,cField,cNewValue,cOldValue)
Local lRet      := .T.
Local cFilAtu   := cFilAnt
Local aAreaGZR := GZR->(GetArea())
Local aAreaSM0 := {}

If cField == 'GZR_UF'

	If !(ExistCpo("SX5","12"+cNewValue))
        lRet := .F.
    Endif
    
    If lRet

        dbSelectArea("GZR")
        GZR->(dbSetOrder(1))

        If GZR->(dbSeek(xFilial('GZR')+cNewValue))
            lRet := .F.
            oMdl:GetModel():SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField, "GA060Vld", STR0009, STR0010) //"UF já cadastrada", "Selecione uma UF diferente" 
        Endif

    Endif

Endif

If cField == 'GZR_FILREF' 

    aAreaSM0 := SM0->(GetArea())

    SM0->(dbSetOrder(1))
    
    If SM0->(dbSeek(cEmpAnt+cNewValue))

        If SM0->M0_ESTENT != oMdl:GetValue('GZR_UF')
            lRet := .F.
            oMdl:GetModel():SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField, "GA060Vld", STR0007, STR0008) //"UF da Filial selecionada difere da UF informada", "Selecione uma filial do estado informado"
        Endif

    Else
        lRet := .F.
        oMdl:GetModel():SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField, "GA060Vld", STR0014, STR0015) // "Filial inexistente", "Selecione uma filial válida"
    Endif

    SM0->(dbSeek(cEmpAnt+cFilAnt))

    RestArea(aAreaSM0)

Endif

RestArea(aAreaGZR)
cFilAnt := cFilAtu

Return lRet

/*/{Protheus.doc} GTPA060TdOK
@author GTP
@since 18/03/2020
@version 1.0
@return ${return}, ${return_description}
@param oMdl, object, descricao
@type function
/*/
Function GTPA060TdOK(oModel)
Local lRet := .T.
Local oMdlGZR	:= oModel:GetModel('GZRMASTER')


If (oMdlGZR:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlGZR:GetOperation() == MODEL_OPERATION_UPDATE)
	If (Empty( oMdlGZR:GetValue('GZR_CLIENT') ) .AND. !Empty( oMdlGZR:GetValue('GZR_LOJA') )) .Or. (!Empty( oMdlGZR:GetValue('GZR_CLIENT') ) .AND. Empty( oMdlGZR:GetValue('GZR_LOJA') )) 
		Help( ,, 'Help',"GTPA060TdOK", STR0011, 1, 0 )   //'Client/Loja inválidos'
       lRet := .F.
    ElseIf !Empty( oMdlGZR:GetValue('GZR_CLIENT') ) .AND. !Empty( oMdlGZR:GetValue('GZR_LOJA') )
        lRet := ExistCpo("SA1",oMdlGZR:GetValue('GZR_CLIENT')+oMdlGZR:GetValue('GZR_LOJA'))
    EndIf
EndIf


Return lRet

