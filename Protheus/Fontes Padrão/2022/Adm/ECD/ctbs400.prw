#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CTBS400.CH"

//Compatibilização de fontes 30/05/2018

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS400
Cadastro de Identificacao dos tipos de programas - Registro 0021 do ECF leiaute 3.0


@author Paulo Carnelossi
@since 27-04-2017
@version P12.1.16
/*/
//-------------------------------------------------------------------
Function CTBS400()
    Local oBrowse

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CQL")
    oBrowse:SetDescription(STR0001)  // "Cadastro Identificacao Tipos de Programas - Registro 0021 ECF"
    oBrowse:Activate()
Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.CTBS400" OPERATION 2 ACCESS 0  //"Visualizar" 	
    ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.CTBS400" OPERATION 3 ACCESS 0  //"Incluir"    	
    ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.CTBS400" OPERATION 4 ACCESS 0  //"Alterar"    	
    ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.CTBS400" OPERATION 5 ACCESS 0  //"Excluir"    	
    ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.CTBS400" OPERATION 8 ACCESS 0  //"Imprimir"  	
    ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.CTBS400" OPERATION 9 ACCESS 0  //"Copiar"    	
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
    Local oStru := FWFormStruct(1, "CQL", /*bAvalCampo*/,/*lViewUsado*/)
    Local oModel := MPFormModel():New("CTBS400", /*bPre*/, {|oModel| CTBS400POS(oModel)})

    oModel:AddFields("CQLMASTER", /*cOwner*/, oStru)
    oModel:SetDescription(STR0001 )  //"Cadastro Identificacao Tipos de Programas - Registro 0021 ECF"
    oModel:GetModel("CQLMASTER"):SetDescription(STR0001)  //Cadastro Identificacao Tipos de Programas - Registro 0021 ECF
Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
    Local oView
    Local oModel := FWLoadModel("CTBS400")
    Local oStru := FWFormStruct(2, "CQL")

    // tira o campo da visualizacao
    oStru:RemoveField("CQL_REG")

    oView := FWFormView():New()
    oView:SetCloseOnOk({||.T.})
    oView:SetModel(oModel)

    oView:AddField("VIEW_CQL", oStru, "CQLMASTER")

    oView:CreateHorizontalBox("TELA", 100)
    oView:SetOwnerView("VIEW_CQL", "TELA")
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS400POS
Validacoes do cadastro
 - nao permite que o registro seja incluido com todas opcoes como "nao"

@author Daniel Lira
@since 08-05-2017
@version P12.1.16
@param oModel sera passado 
/*/
//-------------------------------------------------------------------
Function CTBS400POS(oModel)
    Local nI      := 0
    Local lRet    := .F.
    Local oStruct := oModel:GetModelStruct("CQLMASTER")[3]
    Local aFields := oStruct:GetStruct():GetFields()

    // se ao menos um combobox tiver conteudo sim, formulario valido
    For nI := 1 To Len(aFields)
        If !Empty(aFields[nI][9]) .And. oStruct:GetValue(aFields[nI][3]) == "1"
            lRet := .T.
            Exit
        EndIf
    Next nI

    // caso o formulario nao esteja valido
    If ! lRet
        oModel:SetErrorMessage(oStruct:GetId(), /*cIdField*/, oStruct:GetId(), /*cIdFieldErr*/, "TODOSNAO", ;
                STR0011 , ;   //"Todas opcoes estao preenchidas com [ Nao ]"
                STR0012 )     //"Para utilizar o bloco alguma informacao deve ser preenchida com [ Sim ] "
    EndIf
Return lRet
