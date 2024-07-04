#Include "GTPA904.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} GTPA904
(long_description)
@type  Function
@author user
@since 02/08/2022
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA904()
Local oBrowse    := FWMBrowse():New()
Local aFieldsH6A := {'H6A_CODIGO','H6A_CLIENT','H6A_LOJA','H6A_STATUS'}
Local aFieldsH6B := {'H6B_CODIGO','H6B_SEQ','H6B_CODG6U','H6B_TPPERI','H6B_QTDPER','H6B_DATAUL','H6B_EXPIRA','H6B_EXIGEN'}
Local cMsgErro   := ""

If GTPxVldDic("H6A",aFieldsH6A,.T.,.T.,@cMsgErro) .AND. GTPxVldDic("H6B",aFieldsH6B,.T.,.T.,@cMsgErro)
    oBrowse:SetAlias('H6A')
    //isso é fretamento continuo
    oBrowse:SetDescription(STR0001) //"Parâmetro cliente Fretamento contínuo"
    
    If H6A->(FIELDPOS("H6A_STATUS")) > 0
        oBrowse:AddLegend("H6A_STATUS == '1'"   ,"GREEN"   ,STR0002    ) //'Ativo'
        oBrowse:AddLegend("H6A_STATUS == '2'"   ,"RED"     ,STR0003  ) //'Inativo'
    EndIf

    oBrowse:Activate()
    oBrowse:Destroy()
EndIf

If !(EMPTY(cMsgErro))
    FwAlertWarning(cMsgErro)
EndIf

Return oBrowse

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author henrique.toyada
@since 09/07/2019
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

    ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.GTPA904' OPERATION OP_VISUALIZAR  ACCESS 0 //"Visualizar"
    ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.GTPA904' OPERATION OP_INCLUIR	   ACCESS 0 //"Incluir"
    ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.GTPA904' OPERATION OP_ALTERAR	   ACCESS 0 //"Alterar"
    ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.GTPA904' OPERATION OP_EXCLUIR	   ACCESS 0 //"Excluir"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author henrique.toyada
@since 02/08/2022
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local oStrH6A	:= FWFormStruct(1,'H6A')
Local oStrH6B	:= FWFormStruct(1,'H6B')

SetModelStruct(oStrH6A,oStrH6B)

oModel := MPFormModel():New('GTPA904', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('H6AMASTER',/*cOwner*/,oStrH6A)
oModel:AddGrid('H6BDETAIL','H6AMASTER',oStrH6B,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)

oModel:SetRelation('H6BDETAIL',{{ 'H6B_FILIAL','xFilial("H6B")'},{'H6B_CODIGO','H6A_CODIGO' }},H6B->(IndexKey(1)))

oModel:SetDescription(STR0001) //"Parâmetro cliente Fretamento contínuo"

oModel:SetPrimaryKey({'H6A_FILIAL','H6A_CODIGO'})

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetModelStruct
Função responsavel pela estrutura de dados do modelo
@type Static Function
@author henrique.toyada
@since 02/08/2022
@version 1.0
@param oStrH6A, object, (Descrição do parâmetro)
@param oStrH6B, object, (Descrição do parâmetro)
@return nil, retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStrH6A,oStrH6B)
Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bInit		:= {|oMdl,cField,uVal,nLine,uOldValue| FieldInit(oMdl,cField,uVal,nLine,uOldValue)}
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }

If oStrH6A:HasField("H6A_DESCRI")//H6A->(FIELDPOS("H6A_DESCRI")) > 0
    oStrH6A:SetProperty('H6A_DESCRI', MODEL_FIELD_INIT, bInit )
EndIf

If H6B->(FIELDPOS("H6B_CODIGO")) > 0
    oStrH6B:SetProperty('H6B_CODIGO', MODEL_FIELD_INIT, bInit )
EndIf

If oStrH6B:HasField("H6B_DESG6U")//H6B->(FIELDPOS("H6B_DESG6U")) > 0
    oStrH6B:SetProperty('H6B_DESG6U', MODEL_FIELD_INIT, bInit )
EndIf

If oStrH6B:HasField("H6B_EXIGEN")
    oStrH6B:SetProperty('H6B_EXIGEN', MODEL_FIELD_OBRIGAT, .T.)
EndIf

If H6A->(FIELDPOS("H6A_CLIENT")) > 0
    oStrH6A:AddTrigger('H6A_CLIENT', 'H6A_CLIENT',  { || .T. }, bTrig ) 
EndIf

If H6A->(FIELDPOS("H6A_LOJA")) > 0
    oStrH6A:AddTrigger('H6A_LOJA'  , 'H6A_LOJA'  ,  { || .T. }, bTrig ) 
    oStrH6A:SetProperty('H6A_LOJA'    ,MODEL_FIELD_VALID	    ,bFldVld)
EndIf

If H6B->(FIELDPOS("H6B_CODG6U")) > 0
    oStrH6B:AddTrigger('H6B_CODG6U', 'H6B_CODG6U',  { || .T. }, bTrig ) 
EndIf

If H6B->(FIELDPOS("H6B_DATAUL")) > 0
    oStrH6B:AddTrigger('H6B_DATAUL', 'H6B_DATAUL',  { || .T. }, bTrig ) 
EndIf

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} FieldInit

@type Function
@author henrique.toyada 
@since 02/08/2022
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldInit(oMdl,cField,uVal,nLine,uOldValue)

Local uRet      := nil
Local oModel	:= oMdl:GetModel()
Local lInsert	:= oModel:GetOperation() == MODEL_OPERATION_INSERT 
Local aArea     := GetArea()

Do Case 
    Case cField == "H6A_DESCRI"
        uRet := If(!lInsert,Posicione('SA1',1,xFilial('SA1') + H6A->H6A_CLIENT + H6A->H6A_LOJA,'A1_NOME'),'')
    Case cField == "H6B_CODIGO"
		uRet := If(!lInsert,M->H6A_CODIGO,H6B->H6B_CODIGO)
    Case cField == "H6B_DESG6U"
        uRet := If(!lInsert,SUBSTR(Posicione('G6U',1,xFilial('G6U') + H6B->H6B_CODG6U,'G6U_DESCRI'),0,TamSX3("G6U_DESCRI")[1]),'')
EndCase 

RestArea(aArea)

Return uRet

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger
Função que preenche trigger

@sample	GA850ATrig()

@author henrique.toyada
@since 02/08/2022
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)

	Do Case 
		Case cField == 'H6A_CLIENT'
			oMdl:SetValue("H6A_LOJA" ,Posicione('SA1',1,xFilial('SA1')+uVal,"A1_LOJA" ))
			oMdl:SetValue("H6A_DESCRI" ,SUBSTR(Posicione('SA1',1,xFilial('SA1')+uVal+Posicione('SA1',1,xFilial('SA1')+uVal,"A1_LOJA" ),"A1_NOME" ),0,TamSX3("H6A_DESCRI")[1]))
		Case cField == 'H6A_LOJA'
			oMdl:SetValue("H6A_DESCRI" ,SUBSTR(Posicione('SA1',1,xFilial('SA1')+oMdl:GetValue('H6A_CLIENT')+uVal,"A1_NOME" ),0,TamSX3("H6A_DESCRI")[1]))
        Case cField == "H6B_CODG6U"
            SetFieldG6U(oMdl,uVal)
        Case cField == "H6B_DATAUL"
            oMdl:SetValue("H6B_EXPIRA",GetDtVigencia(uVal,oMdl:GetValue('H6B_TPPERI'),oMdl:GetValue('H6B_QTDPER')))
	EndCase 

Return uVal

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldValid(oMdl,cField,uNewValue,uOldValue)
Função responsavel pela validação dos campos
@type Static Function
@author henrique.toyada
@since 09/07/2019
@version 1.0
@param oMdl, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uNewValue, character, (Descrição do parâmetro)
@param uOldValue, character, (Descrição do parâmetro)
@return lRet, retorno logico dizendo se a validação é com sucesso ou erro
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue)
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Do Case
    Case Empty(uNewValue)
		lRet := .T.
    Case cField == "H6A_LOJA"
        If GTPExistCpo('H6A',oMdl:GetValue('H6A_CLIENT') + uNewValue,2)
            lRet		:= .F.
            cMsgErro	:= STR0009//"Cliente e loja já cadastrado"
            cMsgSol		:= STR0010//"Verifique se o mesmo se encontra cadastrado e ativo para uso"
        Endif
EndCase        

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} GetDtVigencia
Função responsavel para calcular a proxima data
@type Static Function
@author henrique.toyada
@since 08/07/2019
@version 1.0
@param dDtIni, date, (Descrição do parâmetro)
@param cTpVigen, character, (Descrição do parâmetro)
@param nTempVig, numeric, (Descrição do parâmetro)
@return dDtFim, retorna a proxima data de acordo com os parametros informados
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function GetDtVigencia(dDtIni,cTpVigen,nTempVig)
Local dDtFim    := dDtIni

Do Case
    Case cTpVigen == "1" //Dia
        dDtFim  := DaySum(dDtIni,nTempVig)
    Case cTpVigen == "2" //Mes
        dDtFim  := MonthSum(dDtIni,nTempVig)
    Case cTpVigen == "3" //Ano
        dDtFim  := YearSum(dDtIni,nTempVig)
EndCase

Return dDtFim

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetFieldG6U
Função responsavel pelo preenchimento dos campos do tipo de documento
@type Static Function
@author henrique.toyada
@since 02/08/2022
@version 1.0
@param oMdl, object, (Descrição do parâmetro)
@param cCodG6U, character, (Descrição do parâmetro)
@return nil, retorna nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetFieldG6U(oMdl,cCodG6U)
Local aAreaG6U  := G6U->(GetArea())

G6U->(DbSetOrder(1))//G6U_FILIAL+G6U_CODIGO
If G6U->(DbSeek(xFilial('G6U')+cCodG6U))

    oMdl:SetValue('H6B_TPPERI',G6U->G6U_TPVIGE)
    oMdl:SetValue('H6B_QTDPER',G6U->G6U_TEMPVI)
    oMdl:SetValue("H6B_DESG6U",SUBSTR(G6U->G6U_DESCRI,0,TamSX3("G6U_DESCRI")[1]))
Endif

RestArea(aAreaG6U)
GtpDestroy(aAreaG6U)
Return nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author henrique.toyada
@since 02/08/2022
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA904')
Local oStrH6A	:= FWFormStruct(2, 'H6A')
Local oStrH6B	:= FWFormStruct(2, 'H6B')

SetViewStruct(oStrH6A,oStrH6B)

oView:SetModel(oModel)

oView:AddField('VIEW_H6A'   ,oStrH6A,'H6AMASTER')
oView:AddGrid('VIEW_H6B'    ,oStrH6B,'H6BDETAIL')

oView:CreateHorizontalBox('UPPER'   , 20)
oView:CreateHorizontalBox('BOTTOM'  , 80)

oView:SetOwnerView('VIEW_H6A','UPPER')
oView:SetOwnerView('VIEW_H6B','BOTTOM')

If H6B->(FIELDPOS("H6B_SEQ")) > 0
    oView:AddIncrementField('VIEW_H6B','H6B_SEQ')
EndIf

oView:SetDescription(STR0008) //"Parâmetro cliente encomendas"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetViewStruct
Função responsavel pela estrutura de dados da view
@type Static Function
@author henrique.toyada
@since 02/08/2022
@version 1.0
@param oStrH6A, object, (Descrição do parâmetro)
@param oStrH6B, object, (Descrição do parâmetro)
@return nil, retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStrH6A,oStrH6B)

If H6A->(FIELDPOS("H6A_CODIGO")) > 0
    oStrH6A:RemoveField('H6A_CODIGO')
EndIf

If H6B->(FIELDPOS("H6B_CODIGO")) > 0
    oStrH6B:RemoveField('H6B_CODIGO')
EndIf

Return
