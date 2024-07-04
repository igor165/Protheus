#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA460.CH'

/*/{Protheus.doc} GTPA460
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
@version 1.0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA460()
Local oBrowse   := Nil
Local cMsgErro  := ''
	
If G460VldDic(@cMsgErro)    
    oBrowse := FwMBrowse():New()
    oBrowse:SetAlias('GYV')
    oBrowse:SetDescription(STR0001) //"Depósito de Terceiros"
    oBrowse:Activate()
Else
    FwAlertHelp(cMsgErro, STR0012) //"Banco de dados desatualizado, não será possível iniciar a rotina"
Endif

Return Nil

/*/{Protheus.doc} MenuDef
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
@version 1.0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function MenuDef()
Local aRotina := {}
	
ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.GTPA460' OPERATION 2 ACCESS 0	//'Visualizar'
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.GTPA460' OPERATION 3 ACCESS 0	//'Incluir'
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.GTPA460' OPERATION 4 ACCESS 0	//'Alterar'
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.GTPA460' OPERATION 5 ACCESS 0	//'Excluir'
	    
Return aRotina

/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
@version 1.0@param , param_type, param_descr
@return oModel, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel	:= Nil
Local oStruGYV	:= FwFormStruct(1,'GYV')
Local oStruGIC	:= FwFormStruct(1,'GIC')
Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bFldValid	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local bPosValid	:= {|oModel| G460PosVld(oModel)}
Local bCommit   := {|oModel| G460Commit(oModel) }

oStruGYV:AddTrigger("GYV_AGENCI", "GYV_AGENCI" ,{ ||.T.}, bTrig)

oModel := MPFormModel():New('GTPA460', /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/)
oModel:SetVldActivate({|oModel| G460VldAct(oModel)})
oModel:SetCommit(bCommit)	

oModel:AddFields('GYVMASTER',/*cOwner*/,oStruGYV)
oModel:AddGrid('GICDETAIL','GYVMASTER',oStruGIC, /*bLinePre*/, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )

oModel:AddCalc('CALC', 'GYVMASTER', 'GICDETAIL' , 'GIC_VALTOT', 'CALC_VALOR', 'SUM', { | | .T.},, "Valor Total") //"Vlr. Total"

oModel:SetRelation('GICDETAIL', {{ 'GIC_FILIAL', 'xFilial( "GIC" )' }, {'GIC_CODGYV', 'GYV_CODIGO'}}, GIC->(IndexKey(1)))

oModel:GetModel('GICDETAIL'):SetMaxLine(999999)
oModel:GetModel("GICDETAIL"):SetUniqueLine({"GIC_CODIGO"})
oModel:GetModel('GICDETAIL'):SetOptional(.T.)
oModel:GetModel("GICDETAIL"):SetOnlyQuery(.T.) 

oStruGYV:SetProperty("GYV_DATMOV", MODEL_FIELD_VALID, bFldValid)

oStruGIC:SetProperty("*", MODEL_FIELD_INIT      , {||"" })
oStruGIC:SetProperty('*', MODEL_FIELD_VALID     , {||.T.})
oStruGIC:SetProperty("*", MODEL_FIELD_OBRIGAT   , .F.)

oModel:SetDescription(STR0001) //"Depósito de Terceiros"
oModel:GetModel('GYVMASTER'):SetDescription(STR0001) //"Depósito de Terceiros"

oModel:GetModel("GICDETAIL"):SetNoInsertLine(.T.)
		
Return oModel

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
@version 1.0@param , param_type, param_descr
@return oView, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oModel	:= ModelDef()
Local oView		:= FwFormView():New()
Local cFldsGIC  := 'GIC_CODIGO|GIC_BILHET|GIC_DTVEND|GIC_VALTOT|GIC_CHVBPE|GIC_LINHA|GIC_NLINHA|GIC_LOCORI|GIC_NLOCOR|GIC_LOCDES|GIC_NLOCDE'
Local aFldsGIC  := StrToKarr(cFldsGIC, "|")
Local oStruGYV	:= FwFormStruct(2, 'GYV')
Local oStruGIC	:= FwFormStruct(2, 'GIC', { |x| AllTrim(x) $ cFldsGIC})
Local oStruCalc := FwCalcStruct( oModel:GetModel('CALC') )
Local nX        := 0

oView:SetModel(oModel)

oView:SetDescription(STR0001) //"Depósito de Terceiros"

oView:AddField('VIEW_GYV', oStruGYV,'GYVMASTER')
oView:AddGrid('VIEW_GIC', oStruGIC,'GICDETAIL')
oView:AddField('VIEW_CALC', oStruCalc, 'CALC')

oView:CreateHorizontalBox('TELA', 30)
oView:CreateHorizontalBox('GRID', 55)
oView:CreateHorizontalBox('CALC', 15)

oView:SetOwnerView('VIEW_GYV', 'TELA')
oView:SetOwnerView('VIEW_GIC', 'GRID')
oView:SetOwnerView('VIEW_CALC','CALC')

oView:EnableTitleView("VIEW_GYV", STR0013)  // "Dados do Depósito"
oView:EnableTitleView("VIEW_GIC", STR0014)  // "Bilhetes"
oView:EnableTitleView("VIEW_CALC",STR0015)  // "Valor Total de Bilhetes"

For nX := 1 To Len(aFldsGIC)
    oStruGIC:SetProperty(aFldsGIC[nX], MVC_VIEW_ORDEM , StrZero(nX, 2))
Next

oStruGIC:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
oStruGIC:SetProperty("GIC_CODIGO", MVC_VIEW_LOOKUP, "GICDEP")

oView:addUserButton(STR0006, "", {|oView| FwMsgRun(,{|| PesqBilhete(oView) ,oView:Refresh()}, STR0007, STR0008)} ,,,{3 ,4} ) // "Carregar bilhetes", "Carregando Bilhetes", "Aguarde" 

Return oView

/*/{Protheus.doc} G460VldAct
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G460VldAct(oModel)
Local lRet      := .T.
Local cMsgErro  := ''
Local cMsgSol   := ''

If !G460VldDic(@cMsgErro)
    lRet := .F.
    cMsgSol :=  STR0016 //"Atualize o dicionário para utilizar esta rotina"
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"GA460PosVld", cMsgErro, cMsgSol) 
    Return .F.
Endif

If (oModel:GetOperation() == MODEL_OPERATION_DELETE .Or.;
     oModel:GetOperation() == MODEL_OPERATION_UPDATE) .And.;
     !(Empty(GYV->GYV_NUMFCH))
    lRet := .F.
    cMsgErro :=  STR0021 // "Depósito já consta em uma ficha de remessa"
    cMsgSol  :=  STR0022 // "Exclua a ficha de remessa para alterar as informações do depósito"
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"GA460PosVld", cMsgErro, cMsgSol) 
    Return .F.
Endif

Return lRet

/*/{Protheus.doc} FieldTrigger
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
@version 1.0@param , param_type, param_descr
@return uVal, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldTrigger(oMdl,cField,uVal)
Local oModel := oMdl:GetModel()

Do Case
	Case cField == "GYV_AGENCI"
		oMdl:SetValue("GYV_NOMAGE",Posicione("GI6", 1, xFilial("GI6") + uVal, "GI6_DESCRIC"))
		oModel:GetModel('GICDETAIL'):ClearData()
EndCase

Return uVal

/*/{Protheus.doc} FieldValid
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue) 
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

If cField == 'GYV_DATMOV' 

    If !(ValidaData(oModel))
        lRet := .F.
        cMsgErro := STR0017 // "Data informada já consta em uma ficha de remessa fechada"
        cMsgSol  := STR0018 // "Verifique a data informada ou estorne a ficha de remessa"
        oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"FieldValid", cMsgErro, cMsgSol) 
    Endif

Endif

Return lRet

/*/{Protheus.doc} ValidaData
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ValidaData(oModel)
Local lRet      := .T.
Local cAliasTmp := GetNextAlias()
Local cAgencia  := oModel:GetValue('GYVMASTER', 'GYV_AGENCI')
Local cDataMov  := DtoS(oModel:GetValue('GYVMASTER', 'GYV_DATMOV'))

BeginSql Alias cAliasTmp
    SELECT G6X_CODIGO
    FROM %Table:G6X%
    WHERE G6X_FILIAL =  %xFilial:G6X%
      AND G6X_AGENCI = %Exp:cAgencia%
      AND %Exp:cDataMov% BETWEEN G6X_DTINI AND G6X_DTFIN
      AND G6X_STATUS IN ('2','3','4')
      AND %NotDel%

EndSql

    If (cAliasTmp)->(!Eof())
        lRet := .F.
    Endif

(cAliasTmp)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} G460PosVld
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
@version 1.0@param , param_type, param_descr
@return logico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G460PosVld(oModel)
Local lRet      := .T.
Local cMsgErro  := ''
Local cMsgSol   := ''

If oModel:GetValue('CALC', 'CALC_VALOR') > oModel:GetValue('GYVMASTER', 'GYV_VLRDEP')
    lRet        :=  .F.
    cMsgErro    := STR0019 // "Valor total de bilhetes maior que o valor total informado para o depósito"
    cMsgSol     := STR0020 // "Verifique os bilhetes selecionados"

    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"GA117PosVld", cMsgErro, cMsgSol) 
Endif

Return lRet

/*/{Protheus.doc} PesqBilhete
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
@version 1.0@param , param_type, param_descr
@return logico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function PesqBilhete(oView)
Local oModel	:= oView:GetModel()
Local oMdlGIC 	:= oModel:GetModel("GICDETAIL")
Local lRet      := .T.
Local cAgencia  := oModel:GetModel('GYVMASTER'):GetValue('GYV_AGENCI')
Local dDataMov  := oModel:GetModel('GYVMASTER'):GetValue('GYV_DATMOV')
Local aBilhetes := {}
Local nX        := 0

If Empty(cAgencia)
    FwAlertHelp(STR0009, STR0010, STR0011) //"Agência não informada", "Informe uma agência antes de selecionar os bilhetes","Atenção" 
    Return
Endif

If Empty(dDataMov)
    FwAlertHelp(STR0023, STR0024, STR0011) //"Data de movimento não encontrada", "Informe a data de movimento", "Atenção" 
    Return
Endif

aBilhetes := GTPA460A(cAgencia, dDataMov)

For nX := 1 To Len(aBilhetes)
    AddBilhete(oModel, aBilhetes[nX])
Next
    
oMdlGIC:GoLine(1) 

Return lRet

/*/{Protheus.doc} AddBilhete
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
@version 1.0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function AddBilhete(oModel, cCodBil)
Local oMdlGIC   := oModel:GetModel('GICDETAIL')
Local aAreaGIC  := GIC->(GetArea())

GIC->(DbSetOrder(1))

If (!oMdlGIC:SeekLine({{"GIC_CODIGO", cCodBil}}))
    
    If GIC->(dbSeek(xFilial('GIC')+cCodBil))

        If (!Empty(oMdlGIC:GetValue("GIC_CODIGO")) .Or. oMdlGIC:IsDeleted())
            oMdlGIC:AddLine(.T.)
        Endif

        oMdlGIC:SetValue("GIC_CODIGO", GIC->GIC_CODIGO)   
        oMdlGIC:SetValue("GIC_BILHET", GIC->GIC_BILHET)   
        oMdlGIC:SetValue("GIC_DTVEND", GIC->GIC_DTVEND)   
        oMdlGIC:SetValue("GIC_VALTOT", GIC->GIC_VALTOT)   
        oMdlGIC:SetValue("GIC_CHVBPE", GIC->GIC_CHVBPE)   
        oMdlGIC:SetValue("GIC_LINHA",  GIC->GIC_LINHA)   
        oMdlGIC:SetValue("GIC_NLINHA", TpNomeLinh(GIC->GIC_LINHA)                                                           )   
        oMdlGIC:SetValue("GIC_LOCORI", GIC->GIC_LOCORI)  
        oMdlGIC:SetValue("GIC_NLOCOR", Posicione("GI1", 1, xFilial("GI1")+GIC->GIC_LOCORI, "GI1_DESCRI"))  
        oMdlGIC:SetValue("GIC_LOCDES", GIC->GIC_LOCORI)  
        oMdlGIC:SetValue("GIC_NLOCDE", Posicione("GI1", 1, xFilial("GI1")+GIC->GIC_LOCDES, "GI1_DESCRI"))

    Endif    

Endif

RestArea(aAreaGIC)

Return

/*/{Protheus.doc} G460Commit
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G460Commit(oModel)
Local lRet      := .T. 
Local oModelGIC := FwLoadModel("GTPA115")
Local oGridGIC  := oModel:GetModel('GICDETAIL')
Local cCodDep   := oModel:GetModel("GYVMASTER"):GetValue("GYV_CODIGO")
Local nX        := 1

GIC->(dbSetOrder(1))

oModelGIC:SetOperation(MODEL_OPERATION_UPDATE)

Begin Transaction

    For nX := 1 To oGridGIC:Length()
        
        If GIC->(dbSeek(xFilial("GIC") + oGridGIC:GetValue("GIC_CODIGO", nX)))

            oModelGIC:Activate()

            If !oGridGIC:IsDeleted(nX) .AND. oModel:GetOperation() <> 5
                oModelGIC:GetModel("GICMASTER"):SetValue("GIC_CODGYV", cCodDep)
            Else
                oModelGIC:GetModel("GICMASTER"):SetValue("GIC_CODGYV",  "")
            Endif

            If !(oModelGIC:VldData() .and. oModelGIC:CommitData())
                lRet := .F.
                oModel:GetModel():SetErrorMessage(oModel:GetId(),,oModel:GetId(),, oModelGIC:GetErrormessage()[5], oModelGIC:GetErrormessage()[6])
                DisarmTransaction()
                Break
            Endif    

            oModelGIC:DeActivate()

        Endif

    Next nX

End Transaction

oModelGIC:Destroy()

If (lRet)
    FwFormCommit(oModel)
Endif

Return lRet

/*/{Protheus.doc} G460VldDic
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G460VldDic(cMsgErro)
Local lRet          := .T.
Local aTables       := {'GYV'}
Local aFields       := {}
Local nX            := 0
Default cMsgErro    := ''

aFields := {'GYV_CODIGO','GYV_AGENCI','GYV_DATMOV',;
            'GYV_VLRDEP','GYV_IDTDEP','GYV_NUMFCH',;
			'GIC_CODGYV'}

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
