#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA710.CH'

/*/{Protheus.doc} GTPA710
Função responsavel para trazer o Browse do cadastro de Regras de produtos x Tipos de Bilhetes
@type function
@author jacomo.fernandes
@since 05/09/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPA710()
Local oBrowse  := Nil
Local cMsgErro := ''

If G710VldDic(@cMsgErro)    
    oBrowse := FwMBrowse():New()
    oBrowse:SetAlias('G9O')
    oBrowse:SetDescription(STR0001) //Cadastro de Regras de Produtos x Tipos de Bilhetes
    oBrowse:Activate()
Else
    FwAlertHelp(cMsgErro, STR0007) //"Banco de dados desatualizado, não será possível iniciar a rotina"
Endif

Return Nil

/*/{Protheus.doc} ModelDef
Função responsavel para a definição do modelo
@type function
@author jacomo.fernandes
@since 05/09/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel	:= nil
Local oStruG9O	:= FWFormStruct(1,'G9O')
Local oStruH60	:= FWFormStruct(1,'H60')
Local bPosValid	:= {|oModel|G710PosVld(oModel)}
Local bLinePos  := { |oModelGrid| GTP721LPos(oModelGrid) }

SetModelStruct(oStruG9O, oStruH60)

oModel := MPFormModel():New('GTPA710', /*bPreValidacao*/, bPosValid, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('G9OMASTER',/*cOwner*/,oStruG9O)
oModel:AddGrid('H60DETAIL','G9OMASTER',oStruH60, , bLinePos)
oModel:SetDescription(STR0001) //Cadastro de Regras de Produtos x Tipos de Bilhetes
oModel:GetModel('G9OMASTER'):SetDescription(STR0002)	//Regras de Produtos x Tipos de Bilhetes
oModel:SetVldActivate({|oModel| G710VldAct(oModel)})
oModel:SetPrimaryKey({"G9O_FILIAL","G9O_ORIGEM","G9O_TIPO","G9O_STATUS"})

Return ( oModel )

/*/{Protheus.doc} SetModelStruct
Função responsavel para alteração da estrutura do modelo
@type function
@author jacomo.fernandes
@since 05/09/2018
@version 1.0
@param oStruG9O, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetModelStruct(oStruG9O, oStruH60)

oStruG9O:AddTrigger("G9O_PRDTAR", "G9O_DSCTAR"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('G9O_PRDTAR'),'B1_DESC') } )
oStruG9O:AddTrigger("G9O_PRDTAX", "G9O_DSCTAX"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('G9O_PRDTAX'),'B1_DESC') } )
oStruG9O:AddTrigger("G9O_PRDPED", "G9O_DSCPED"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('G9O_PRDPED'),'B1_DESC') } )
oStruG9O:AddTrigger("G9O_PRDSEG", "G9O_DSCSEG"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('G9O_PRDSEG'),'B1_DESC') } )
oStruG9O:AddTrigger("G9O_PRDOUT", "G9O_DSCOUT"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('G9O_PRDOUT'),'B1_DESC') } )
oStruG9O:AddTrigger("G9O_GQCCOD", "G9O_GQCDES"  ,{ || .T. }, { |oMdl| Posicione('GQC',1,xFilial('GQC')+oMdl:GetValue('G9O_GQCCOD'),'GQC_DESCRI') } )

oStruH60:AddTrigger("H60_PRDTAR", "H60_DSCTAR"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H60_PRDTAR'),'B1_DESC') } )
oStruH60:AddTrigger("H60_PRDTAX", "H60_DSCTAX"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H60_PRDTAX'),'B1_DESC') } )
oStruH60:AddTrigger("H60_PRDPED", "H60_DSCPED"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H60_PRDPED'),'B1_DESC') } )
oStruH60:AddTrigger("H60_PRDSEG", "H60_DSCSEG"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H60_PRDSEG'),'B1_DESC') } )
oStruH60:AddTrigger("H60_PRDOUT", "H60_DSCOUT"  ,{ || .T. }, { |oMdl| Posicione('SB1',1,xFilial('SB1')+oMdl:GetValue('H60_PRDOUT'),'B1_DESC') } )

Return

/*/{Protheus.doc} GTP721LPos(oModel)
@type function
@author flavio.martins
@since 01/04/2022
@version 1.0
@return lógico , ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GTP721LPos(oModelGrid)
Local lRet      :=  .T.
Local oModel 	:= oModelGrid:GetModel()

If Empty(oModelGrid:GetValue('H60_PRDTAR')) 
    lRet := .F.
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(), , "GTP721LPos", STR0012) //"Nenhum produto foi informado para o Estado"
Endif

Return lRet

/*/{Protheus.doc} ViewDef
Função responsavel para a definição da interface
@type function
@author jacomo.fernandes
@since 05/09/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()

Local oModel	:= FwLoadModel('GTPA710') 
Local oView		:= FwFormView():New()
Local oStruG9O	:= FwFormStruct(2, 'G9O')
Local oStruH60  := FwFormStruct(2, 'H60')

SetViewStruct(oStruG9O, oStruH60)

oView:SetModel(oModel)

oView:AddField('VIEW_G9O' ,oStruG9O,'G9OMASTER')
oView:AddGrid('VIEW_H60', oStruH60, 'H60DETAIL')

oView:CreateHorizontalBox('HEADER', 70)
oView:CreateHorizontalBox('DETAIL', 30)

oView:SetOwnerView('VIEW_G9O','HEADER')
oView:SetOwnerView('VIEW_H60','DETAIL')

oView:EnableTitleView('VIEW_H60', STR0008) //'Regras de Produto por Estado'

oView:SetDescription(STR0001) //Cadastro de Regras de Produtos x Tipos de Bilhetes

Return ( oView )

/*/{Protheus.doc} SetViewStruct
Função responsavel para alterar a estrutura da View
@type function
@author jacomo.fernandes
@since 05/09/2018
@version 1.0
@param oStruG9O, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStruct(oStruG9O, oStruH60)
Local aFldsG9O  := StrToKarr('G9O_CODIGO|G9O_ORIGEM|G9O_TIPO|G9O_STATUS|G9O_GQCCOD|G9O_GQCDES|G9O_MSBLQL', "|")
Local nX 		:= 0

oStruG9O:AddGroup('GRP001', STR0009,'', 2) // "Dados do Bilhetes"

oStruG9O:SetProperty( 'G9O_CODIGO'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruG9O:SetProperty( 'G9O_ORIGEM'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruG9O:SetProperty( 'G9O_TIPO'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruG9O:SetProperty( 'G9O_STATUS'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruG9O:SetProperty( 'G9O_GQCCOD'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruG9O:SetProperty( 'G9O_GQCDES'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruG9O:SetProperty( 'G9O_MSBLQL'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')

oStruG9O:AddGroup('GRP002', STR0010,'', 2) // "Produtos"

oStruG9O:SetProperty( 'G9O_PRDTAR', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruG9O:SetProperty( 'G9O_PRDTAX', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruG9O:SetProperty( 'G9O_PRDPED', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruG9O:SetProperty( 'G9O_PRDSEG', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruG9O:SetProperty( 'G9O_PRDOUT', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruG9O:SetProperty( 'G9O_DSCTAR', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruG9O:SetProperty( 'G9O_DSCTAX', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruG9O:SetProperty( 'G9O_DSCPED', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruG9O:SetProperty( 'G9O_DSCSEG', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruG9O:SetProperty( 'G9O_DSCOUT', MVC_VIEW_GROUP_NUMBER, 'GRP002')

oStruH60:RemoveField('H60_CODG9O')

For nX := 1 To Len(aFldsG9O)
    oStruG9O:SetProperty(aFldsG9O[nX], MVC_VIEW_ORDEM , StrZero(nX, 2))
Next

Return 

/*/{Protheus.doc} MenuDef
Função responsavel para definir as operações do browse
@type function
@author jacomo.fernandes
@since 05/09/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.GTPA710' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.GTPA710' OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.GTPA710' OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.GTPA710' OPERATION 5 ACCESS 0 // Excluir

Return ( aRotina )

/*/{Protheus.doc} G710PosVld
Função responsavel para pós validação do modelo (Tudo OK)
@type function
@author jacomo.fernandes
@since 05/09/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function G710PosVld(oModel)
Local lRet	:= .T.
Local oMdlG9O	:= oModel:GetModel('G9OMASTER')

// Se já existir a chave no banco de dados no momento do commit, a rotina 
If (oMdlG9O:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlG9O:GetOperation() == MODEL_OPERATION_UPDATE)
	lRet := ExistChav("G9O", oMdlG9O:GetValue("G9O_ORIGEM") + oMdlG9O:GetValue("G9O_TIPO") + oMdlG9O:GetValue("G9O_STATUS")+ oMdlG9O:GetValue("G9O_GQCCOD"),2 )
EndIf

Return lRet

/*/{Protheus.doc} G710VldAct
(long_description)
@type  Static Function
@author flavio.martins
@since 30/03/2022
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G710VldAct(oModel)
Local lRet      := .T.
Local cMsgErro  := ''
Local cMsgSol   := ''

If !G710VldDic(@cMsgErro)
    lRet := .F.
    cMsgSol :=  STR0011 // "Atualize o dicionário para utilizar esta rotina"
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G710VldAct", cMsgErro, cMsgSol) 
    Return .F.
Endif

Return lRet

/*/{Protheus.doc} G710VldDic
(long_description)
@type  Static Function
@author flavio.martins
@since 30/03/2022
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G710VldDic(cMsgErro)
Local lRet          := .T.
Local aTables       := {'H60'}
Local aFields       := {'H60_CODG9O','H60_UF','H60_PRDTAR','H60_PRDTAX','H60_PRDPED','H60_PRDSEG','H60_PRDOUT'}
Local nX            := 0
Default cMsgErro    := ''

For nX := 1 To Len(aTables)
    If !(GTPxVldDic(aTables[nX], {}, .T., .F., @cMsgErro))
        lRet := .F.
        Exit
    Endif
Next

If Empty(cMsgErro)
	For nX := 1 To Len(aFields)
	    If !(Substr(aFields[nX],1,3))->(FieldPos(aFields[nX]))
	        lRet := .F.
	        cMsgErro := I18n("Campo #1 não se encontra no dicionário",{aFields[nX]})
	        Exit
	    Endif
	Next
EndIf

Return lRet
