#INCLUDE 'FINA762.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*{Protheus.doc} FINA762
Cadastro de Unidade Gestora 

@author Marylly Araújo Silva
@since 13/01/2015
@version P12.1.4
*/
//-------------------------------------------------------------------
Function FINA762()

    Local oBrowse As Object
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("FVO")
    oBrowse:SetDescription(STR0001)//"Unidade Gestora Responsável"
    oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} Menu
Cadastro de Unidade Gestora Responsável

@author Marylly Araújo Silva
@since 13/01/2015
@version P12.1.4
*/
//-------------------------------------------------------------------
Static Function MenuDef() As Array
    
    Local aRotina As Array

    aRotina := {}

    ADD OPTION aRotina TITLE STR0002	ACTION 'VIEWDEF.FINA762' OPERATION 2 ACCESS 0 //'Visualizar'
    ADD OPTION aRotina TITLE STR0003	ACTION 'VIEWDEF.FINA762' OPERATION 3 ACCESS 0 //'Incluir'
    ADD OPTION aRotina TITLE STR0004	ACTION 'VIEWDEF.FINA762' OPERATION 4 ACCESS 0 //'Alterar'
    ADD OPTION aRotina TITLE STR0005	ACTION 'VIEWDEF.FINA762' OPERATION 5 ACCESS 0 //'Excluir'
    ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.FINA762' OPERATION 8 ACCESS 0 //'Imprimir'
    ADD OPTION aRotina TITLE STR0007	ACTION 'VIEWDEF.FINA762' OPERATION 9 ACCESS 0 //'Copiar'

Return aRotina

//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Cadastro de Unidade Gestora Responsável

@author Marylly Araújo Silva]
@since 15/01/2015
@version P12.1.4
*/
//-------------------------------------------------------------------
Static Function ModelDef() As Object

    Local oStruFVO	As Object
    Local oModel	As Object
    Local bFormPos	As CodeBlock

    bFormPos := {|oModel|F762FrmPos(oModel)}

    oStruFVO := FWFormStruct(1,'FVO')
    
    oStruFVO:AddTrigger('FVO_CODORG','FVO_ORGDSC',{ || .T.}/*bPre*/,{ |oModel| Posicione('CPA', 1, xFilial('CPA') + oModel:GetValue("FVO_CODORG"),'CPA_DESORG')})
    oStruFVO:SetProperty( "FVO_CODIGO"	, MODEL_FIELD_KEY , .T. )
    oStruFVO:SetProperty( "FVO_CODORG"	, MODEL_FIELD_KEY , .T. )
    
    oModel := MPFormModel():New('FINA762',/*bPreValid*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)
    oModel:AddFields( 'FVOMASTER', /*cOwner*/, oStruFVO, /*bPreValidacao*/, bFormPos /*bPosValidacao*/,  /*bLoad*/ )
    oModel:SetDescription( STR0001 )//'Unidade Gestora Responsável'
    oModel:GetModel( 'FVOMASTER' ):SetDescription( STR0001 )//'Unidade Gestora Responsável'

    oModel:SetActivate()

Return oModel

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Cadastro de Unidade Gestora Responsável

@author Marylly Araújo Silva
@since 15/01/2015
@version P12.1.4
*/
//-------------------------------------------------------------------
Static Function ViewDef() As Object

    Local oModel	As Object
    Local oStruFVO	As Object
    Local oView		As Object

    oModel := FWLoadModel( 'FINA762' )
    oStruFVO := FWFormStruct( 2, 'FVO' )

    oView := FWFormView():New()
    oView:SetModel( oModel )
    oView:AddField( 'VIEW_FVO', oStruFVO, 'FVOMASTER' )
    oView:CreateHorizontalBox( 'TELA' , 100 )
    oView:SetOwnerView( 'VIEW_FVO', 'TELA' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F762FrmPos()
Pos Validacao de preenchimento do FORM

@author Leonardo Castro
@since	28/01/2020
@version 12
/*/
//-------------------------------------------------------------------
Static Function F762FrmPos(oFVO As Object) As Logical

    Local lRet As Logical
    Local nOper As Numeric
    Local cQryFVO As Character
    Local cAliasFVO As Character
    Local aAreaFVO As Array

    DEFAULT oFVO := Nil

    lRet := .T.
    nOper := oFVO:GetOperation()

    If oFVO != Nil .And. nOper == MODEL_OPERATION_INSERT

        If FVO->(IndexKey(2)) == "FVO_FILIAL+FVO_CODORG"
        
            aAreaFVO := FVO->(GetArea())
            FVO->( DbSetOrder(2) ) // FVO_FILIAL+FVO_CODORG
            If FVO->( DbSeek( xFilial("FVO") + oFVO:GetValue("FVO_CODORG") ) )
                HELP(,,"FA762DUP",,STR0009,1,0,,,,,, {STR0010}) // "O valor informado no campo 'Unidade Gestora' já está vinculado a outro registro de Unidade Gestora Responsável." / "Informe outro valor para o campo de Unidade Gestora."
                lRet := .F.
            EndIf
            RestArea(aAreaFVO)

        Else // Caso o Indice "FVO_FILIAL+FVO_CODORG" não exista, Releases anteriores a 12.1.027

            cAliasFVO := GetNextAlias()
            cQryFVO := "SELECT FVO_CODORG FROM " + RetSqlName("FVO")
            cQryFVO += " WHERE FVO_FILIAL = '" + xFilial("FVO") + "' "
            cQryFVO += " AND FVO_CODORG = '" + oFVO:GetValue("FVO_CODORG") + "' "
            cQryFVO += " AND D_E_L_E_T_ = ' ' "
          
            cQryFVO := ChangeQuery(cQryFVO)
            dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryFVO), cAliasFVO, .F., .T.)

            lRet := (cAliasFVO)->( EOF() )
            (cAliasFVO)->( DbCloseArea() )
            
            If !lRet // Registro ja cadastrado
                HELP(,,"FA762DUP",,STR0009,1,0,,,,,, {STR0010}) // "O valor informado no campo 'Unidade Gestora' já está vinculado a outro registro de Unidade Gestora Responsável." / "Informe outro valor para o campo de Unidade Gestora."
            EndIf

        EndIf

    EndIf

Return lRet