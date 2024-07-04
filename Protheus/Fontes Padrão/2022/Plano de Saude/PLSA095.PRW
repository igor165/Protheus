#Include "protheus.CH"
#Include "TopConn.ch"
#Include 'FWMVCDEF.CH'
#Include 'PLSA095.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc}) PLSA095
Cadastro do Rol de Procedimentos

@author  Marco Paulo
@version P12
@since    22.11.01
/*/
//-------------------------------------------------------------------
Function PLSA095()

    Local oBrowse := Nil
     
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("BRW")
    oBrowse:SetDescription("Roll de Procedimentos Ans") // "Roll de Procedimentos Ans"
  
    oBrowse:Activate()
     
Return Nil
 
 
//-------------------------------------------------------------------
/*/{Protheus.doc}) MenuDef
Atualizacao do menu funcional 

@author  Henry Fila
@version P12
@since    02.04.07
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina := {} 

    ADD OPTION aRotina Title STR0005   Action 'VIEWDEF.PLSA095' OPERATION MODEL_OPERATION_VIEW ACCESS 0 //"Visualizar"
    ADD OPTION aRotina Title STR0006   Action 'VIEWDEF.PLSA095' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //"Incluir"
    ADD OPTION aRotina Title STR0007   Action 'VIEWDEF.PLSA095' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //"Alterar"
    ADD OPTION aRotina Title STR0008   Action 'VIEWDEF.PLSA095' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //"Excluir"
    
Return aRotina
 

//-------------------------------------------------------------------
/*/{Protheus.doc}) ModelDef
Modelo de Dados para o cadastro de Roll de Procedimentos

@author Guilherme Carreiro
@version Protheus 12
@since 01/08/2022
/*/
//------------------------------------------------------------------- 
Static Function ModelDef()

    Local oModel := Nil
    Local oStruBRW := FWFormStruct(1, 'BRW')
    Local lGridDUT := PlsAliasExi("BKY")
    Local oStruBKY := Nil
        
    If lGridDUT 
        oStruBKY := FWFormStruct(1, 'BKY')
    EndIf
     
    oModel := MPFormModel():New('PLSA095')
    oModel:AddFields('MASTERBRW', Nil, oStruBRW)
        
    If lGridDUT 
        oModel:AddGrid('DETAILBKY','MASTERBRW',oStruBKY)
         
        oModel:SetRelation('DETAILBKY', {{"BKY_FILIAL", "xFilial('BKY')"},;
                                         {"BKY_CODROL", "BRW_CODROL"},;
                                         {"BKY_TABDUT", "BRW_TABDUT"}},;
                                          BKY->(IndexKey(1)))
    EndIf

    oModel:SetDescription("Roll de Procedimentos Ans")
    oModel:GetModel('MASTERBRW'):SetDescription('Roll de Procedimentos')
    
    If lGridDUT 
        oModel:GetModel('DETAILBKY'):SetDescription('Cadastro de DUTs do Procedimento')

        oModel:GetModel('DETAILBKY'):SetUniqueLine({"BKY_CODDUT", "BKY_DUTSUB"})
        
        oModel:GetModel("DETAILBKY"):SetOptional(.T.)
    EndIf

    oModel:SetPrimaryKey({})
     
Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Tela de Roll de Procedimentos

@author Guilherme Carreiro
@version Protheus 12
@since 01/08/2022
/*/
//------------------------------------------------------------------- 
Static Function ViewDef()

    Local oView := Nil
    Local oModel := FWLoadModel('PLSA095')
    Local oStruBRW := FWFormStruct(2, 'BRW')
    Local lGridDUT := PlsAliasExi("BKY")
    Local oStruBKY := Nil
        
    If lGridDUT
        oStruBKY := FWFormStruct(2, 'BKY')
    EndIf
     
    oView := FWFormView():New()
    
    If lGridDUT
        oStruBRW:RemoveField('BRW_CODDUT')
        oStruBRW:RemoveField('BRW_DUTSUB')

        oStruBKY:RemoveField("BKY_CODROL")
        oStruBKY:RemoveField("BKY_TABDUT")
    EndIf
    
    oView:SetModel(oModel)
     
    oView:AddField('VIEWBRW',oStruBRW,'MASTERBRW')
    
    If lGridDUT
        oView:AddGrid('VIEWBKY',oStruBKY,'DETAILBKY')
        
        oView:CreateHorizontalBox('BOX_ROL',60)
        oView:SetOwnerView('VIEWBRW','BOX_ROL')

        oView:CreateHorizontalBox('GRID',40)
        oView:SetOwnerView('VIEWBKY','GRID')    
        oView:EnableTitleView('VIEWBKY','DUTs do Procedimento') 
    Else
        oView:CreateHorizontalBox('BOX_ROL',100)
        oView:SetOwnerView('VIEWBRW','BOX_ROL')
    EndIf

    If lGridDUT //Cadastro DUT
        oView:AddUserButton(STR0040, 'MAGIC_BMP', {|oModel| PLA095DUT(FWFldGet("BRW_TABDUT"),FWFldGet("BKY_CODDUT"),FWFldGet("BKY_DUTSUB"))} )
    Else
        oView:AddUserButton(STR0040, 'MAGIC_BMP', {|oModel| PLA095DUT(FWFldGet("BRW_TABDUT"),FWFldGet("BRW_CODDUT"),FWFldGet("BRW_DUTSUB"))} )
    EndIF
    
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PL95BTabDUT
Valida se existem itens no grid ao alterar a tabela de DUT

@author  Guilherme Carreiro
@version P12
@since   01/08/2022
/*/
//------------------------------------------------------------------- 
Function PL95BTabDUT()

    Local lRet := .T.
    Local oModel := FWModelActive()
    Local lGridDUT := PlsAliasExi("BKY")
    Local oModelBKY := Nil
    
    If lGridDUT
        
        oModelBKY := oModel:GetModel("DETAILBKY")
        
        If oModelBKY:Length() == 1
            If !Empty(oModelBKY:GetValue("BKY_CODDUT"))
                Help("", 1, "VALID", Nil,  STR0039,  1, 0)
                lRet := .F.
            EndIf
        Else
            Help("", 1, "VALID", Nil,  STR0039,  1, 0) 
            lRet := .F.
        ENdIf
    
    EndIF
    
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLFilDUTAud
Filtra os DUTs do procedimento no parecer da auditoria

@author  Guilherme Carreiro
@version P12
@since   01/08/2022
/*/
//------------------------------------------------------------------- 
Function PLFilDUTAud(cCodAuditoria)

    Local lRet := .T.
    Local nQuant := 0
    Local lGridDUT := PlsAliasExi("BKY")
    
    If lGridDUT
        
        cSql := "SELECT COUNT(BKY.BKY_CODROL) CONTADOR FROM " + RetSQLName("BKY") + " BKY"
        cSql += " INNER JOIN " + RetSQLName("BKK") + " BKK "
        cSql += "    ON BKK.BKK_FILIAL = '" + xFilial("BKK") + "'"
        cSql += "     AND BKK.BKK_CODTAB = BKY.BKY_TABDUT"
        cSql += "     AND BKK.BKK_CODDUT = BKY.BKY_CODDUT"
        cSql += "     AND BKK.BKK_CODSUB = BKY.BKY_DUTSUB"
        cSql += "     AND BKK.D_E_L_E_T_ = ' ' "
        
        cSql += " WHERE BKY.BKY_FILIAL = '" + xFilial("BKY") + "'"
        cSql += "     AND BKY.BKY_CODROL = '" + cCodAuditoria + "'"
        cSql += "     AND BKY.BKY_TABDUT = '" + BKK->BKK_CODTAB + "'"
        cSql += "     AND BKY.BKY_CODDUT = '" + BKK->BKK_CODDUT + "'"
        cSql += "     AND BKY.BKY_DUTSUB = '" + BKK->BKK_CODSUB + "'"
        cSql += "     AND BKY.D_E_L_E_T_ = ' ' "

        nQuant := MPSysExecScalar(cSql, "CONTADOR")
        
        lRet := IIf(nQuant > 0, .T., .F.)
    
    EndIF
    
Return lRet