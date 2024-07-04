#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA080.CH'

/*/{Protheus.doc} GTPA080()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 05/07/2022
@version 1.0
@return Nil
@type function
/*/
Function GTPA080()
Local oBrowse   := Nil
Local cMsgErro  := ''

If G080VldDic(@cMsgErro)    
    oBrowse := FwMBrowse():New()
    oBrowse:SetAlias('H63')
    oBrowse:SetDescription(STR0005) //'Perfil de Agências'
    oBrowse:Activate()
Else
    FwAlertHelp(cMsgErro, STR0015) // "Banco de dados desatualizado, não será possível iniciar a rotina"
Endif

Return

/*/{Protheus.doc} MenuDef()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 05/07/2022
@version 1.0
@return aRotina
@type function
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0001 ACTION 'VIEWDEF.GTPA080' OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.GTPA080' OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.GTPA080' OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.GTPA080' OPERATION 5 ACCESS 0 //Excluir
		
Return  aRotina

/*/{Protheus.doc} ModelDef()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 05/07/2022
@version 1.0
@return oModel
@type function
/*/
Static Function ModelDef()
Local oModel 	:= MPFormModel():New('GTPA080', /*bPreValid*/, /*bPosValid*/, /* bCommit */, /*bCancel*/ )
Local oStruH63	:= FwFormStruct(1, 'H63')
Local oStruH64	:= FwFormStruct(1, 'H64')
Local oStruGI6  := FwFormStruct(1, 'GI6')
Local bVldActiv := { |oModel| G080VldAct(oModel)}
Local bCommit   := {|oModel| GA080Commit(oModel)}

SetMdlStruct(oStruH63, oStruH64, oStruGI6)

oModel:AddFields( 'H63MASTER', /*cOwner*/, oStruH63)
oModel:AddGrid('H64DETAIL','H63MASTER',oStruH64,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
oModel:SetRelation('H64DETAIL',{{'H64_FILIAL','xFilial("H64")'},{'H64_CODH63','H63_CODIGO' }}, H64->(IndexKey(1)))

oModel:AddGrid('GI6DETAIL','H63MASTER',oStruGI6,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
oModel:SetRelation('GI6DETAIL',{{'GI6_FILIAL','xFilial("GI6")'},{'GI6_CODH63','H63_CODIGO' }}, GI6->(IndexKey(1)))

If AliasInDic("H64") .AND. H64->(FieldPos("H64_CODGZC")) > 0
    oModel:GetModel("H64DETAIL"):SetUniqueLine({'H64_CODGZC'})	
EndIf

oModel:GetModel("GI6DETAIL"):SetOnlyQuery(.T.)

oModel:GetModel("H64DETAIL"):SetMaxLine(9999)
oModel:GetModel("GI6DETAIL"):SetMaxLine(9999)

oModel:SetDescription(STR0005) //"Perfil de Agências"

oModel:SetVldActivate(bVldActiv)
oModel:SetCommit(bCommit)
	
Return oModel

/*/{Protheus.doc} SetMdlStruct()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 05/07/2022
@version 1.0
@return Nil
@type function
/*/
Static Function SetMdlStruct(oStruH63, oStruH64, oStruGI6)
Local bFieldVld	    := {|oMdl,cField,cNewValue,cOldValue|FieldValid(oMdl,cField,cNewValue,cOldValue)}
Local bFieldTrig    := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}

If ValType(oStruH64) == "O"
    If AliasInDic("H64") .AND. H64->(FieldPos("H64_CODGZC")) > 0
        oStruH64:SetProperty("H64_CODGZC", MODEL_FIELD_VALID, bFieldVld)
        oStruH64:AddTrigger("H64_CODGZC" ,"H64_CODGZC" ,{||.T.}, bFieldTrig)
    EndIf
Endif

If ValType(oStruGI6) == "O"
    oStruGI6:SetProperty("*", MODEL_FIELD_INIT, {||"" })
Endif

Return

/*/{Protheus.doc} G080VldAct
(long_description)
@type  Static Function
@author flavio.martins
@since 06/07/2022
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G080VldAct(oModel)
Local lRet      := .T.
Local cMsgErro  := ''
Local cMsgSol   := ''

If !G080VldDic(@cMsgErro)
    lRet := .F.
    cMsgSol :=  STR0016 //"Atualize o dicionário para utilizar esta rotina"
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G080VldAct", cMsgErro, cMsgSol) 
    Return .F.
Endif

Return lRet


/*/{Protheus.doc} FieldValid()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 05/07/2022
@version 1.0
@return boolean
@type function
/*/
Static Function FieldValid(oMdl, cField, cNewValue, cOldValue)
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cTitulo	:= "FieldVld"
Local cMsgErro	:= ""
Local cMsgSol	:= ""

If cField == 'H64_CODGZC' .And. !(Empty(cNewValue))
    GZC->(dbSetOrder(1))
 	If GZC->(DbSeek(xFilial("GZC")+cNewValue))

        If GZC->GZC_INCMAN != '1'
			lRet	:= .F.
			cMsgErro:= STR0006 // 'Receita ou Despesa inválida'
			cMsgSol	:= STR0007 // 'Apenas receitas e despesas cadastradas como manuais podem ser selecionadas'
        Endif

    Else
        lRet	:= .F.
        cMsgErro:= STR0008 // 'Receita ou Despesa não encontrada'
        cMsgSol	:= STR0009 // 'Informe um código existente para prosseguir'
    Endif

Endif

If !lRet
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,cTitulo,cMsgErro,cMsgSol,cNewValue,cOldValue)
Endif

Return lRet

/*/{Protheus.doc} FieldTrigger()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 05/07/2022
@version 1.0
@return uVal
@type function
/*/
Static Function FieldTrigger(oMdl,cField,uVal)

If cField == 'H64_CODGZC'
    oMdl:SetValue("H64_DSCGZC", Posicione('GZC',1,xFilial('GZC')+uVal,'GZC_DESCRI'))
Endif

Return uVal

/*/{Protheus.doc} ViewDef()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 05/07/2022
@version 1.0
@return oView
@type function
/*/
Static Function ViewDef()
Local oModel	:= FwLoadModel('GTPA080')
Local oView		:= FwFormView():New()
Local cFldsGI6  := 'GI6_CODIGO|GI6_DESCRI|GI6_TIPO|GI6_STATUS|GI6_LOCALI|GI6_DESLOC|'  
Local oStruH63	:= FwFormStruct(2, 'H63')
Local oStruH64	:= FwFormStruct(2, 'H64')
Local oStruGI6  := FWFormStruct(2, 'GI6' , { |x| AllTrim(x)+"|" $ cFldsGI6})

oStruH64:RemoveField("H64_CODH63")
oStruH64:SetProperty("*"            , MVC_VIEW_CANCHANGE, .F.)
oStruGI6:SetProperty("*"            , MVC_VIEW_CANCHANGE, .F.)
oStruH64:SetProperty("H64_CODGZC"   , MVC_VIEW_CANCHANGE, .T.)

oView:SetModel(oModel)
oView:SetDescription(STR0005) // "Perfil de Agências"
oView:AddField('VIEWH63', oStruH63, 'H63MASTER')
oView:AddGrid('VIEWH64'	, oStruH64, 'H64DETAIL')
oView:AddGrid('VIEWGI6'	, oStruGI6, 'GI6DETAIL')
    
oView:CreateHorizontalBox('UPPER' , 30)
oView:CreateHorizontalBox('BOTTOM', 70)

oView:CreateFolder("FOLDER", "BOTTOM")
oView:AddSheet("FOLDER", "ABA01", STR0013) // "Receitas e Despesas do Perfil"
oView:AddSheet("FOLDER", "ABA02", STR0014) // "Agências vinculadas ao Perfil" 
oView:CreateVerticalBox("RECDESP", 100, , , 'FOLDER', 'ABA01')
oView:CreateVerticalBox("AGENCIA",100 , , , 'FOLDER', 'ABA02')

oView:SetOwnerView('VIEWH63','UPPER')
oView:SetOwnerView('VIEWH64','RECDESP')
oView:SetOwnerView('VIEWGI6','AGENCIA')

oView:addUserButton(STR0010, "", {|oView| FwMsgRun(,{|| PesqAgencia(oView) ,oView:Refresh()}, STR0011, STR0012)} ,,,{3 ,4} ) // "Adicionar Agências", "Carregando...", "Aguarde"

Return oView

/*/{Protheus.doc} PesqAgencia(oView)
//TODO Descrição auto-gerada.
@author flavio.martins
@since 06/07/2022
@version 1.0
@return boolean
@type function
/*/
Static Function PesqAgencia(oView)
Local oModel	:= oView:GetModel()
Local oModelGI6 := oModel:GetModel("GI6DETAIL")
Local aGI6Struct:= GI6->(dbStruct())
Local oStruGI6  := oModelGI6:GetStruct()
Local lRet      := .T.
Local aAgencias := {}
Local nX        := 0
Local nY        := 0

aAgencias := GTPA080A()

GI6->(dbSetOrder(1))

For nX := 1 To Len(aAgencias)

    If (!oModelGI6:SeekLine({{"GI6_CODIGO", aAgencias[nX]}}))
                
        If (!Empty(oModelGI6:GetValue("GI6_CODIGO")) .Or. oModelGI6:IsDeleted())
            oModelGI6:AddLine(.T.)
        Endif

        GI6->(dbSeek(xFilial('GI6') + aAgencias[nX]))

        For nY := 1 to Len(aGI6Struct) 
            If oStruGI6:HasField(aGI6Struct[nY][1]) 
                oModelGI6:LdValueByPos(oModelGI6:GetStruct():GetArrayPos({aGI6Struct[nY][1]})[1], GI6->&(aGI6Struct[nY][1]))
            Endif
        Next

        oModelGI6:SetValue("GI6_DESLOC", Posicione('GI1', 1, xFilial("GI1") + oModelGI6:GetValue("GI6_LOCALI"), "GI1_DESCRI"))

    Endif

Next
    
oModelGI6:GoLine(1) 

Return lRet

/*/{Protheus.doc} GA080Commit(oModel)
//TODO Descrição auto-gerada.
@author flavio.martins
@since 06/07/2022
@version 1.0
@return boolean
@type function
/*/
Static Function GA080Commit(oModel)
Local lRet      := .T. 
Local cMsgErro  := ''
Local cMsgSol   := ''
Local nX        := 0

GI6->(dbSetOrder(1))

Begin Transaction

    For nX := 1 To oModel:GetModel('GI6DETAIL'):Length()

        If GI6->(dbSeek(xFilial('GI6') + oModel:GetModel('GI6DETAIL'):GetValue('GI6_CODIGO', nX)))

            If !oModel:GetOperation() != 5 .Or. !oModel:GetModel('GI6DETAIL'):IsDeleted(nX) 
            
                If !Empty(GI6->GI6_CODH63) .And. (GI6->GI6_CODH63 != oModel:GetValue('H63MASTER', 'H63_CODIGO'))

                    cMsgErro := STR0017 + GI6->GI6_CODIGO + ' - '  + GI6->GI6_DESCRI + STR0018 // 'A agência ', ' já consta em outro perfil, o processo será cancelado'
                    cMsgSol  := STR0019 // 'Apenas agências sem o perfil cadastrado podem ser adicionadas'
                    lRet := .F.
                    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G080VldAct", cMsgErro, cMsgSol) 
                    Exit

                Endif

            Endif
        
            Reclock("GI6", .F.)
                If oModel:GetOperation() == MODEL_OPERATION_DELETE .Or. oModel:GetModel('GI6DETAIL'):IsDeleted(nX)
                    GI6->GI6_CODH63 := ''
                Else
                    GI6->GI6_CODH63 := oModel:GetValue('H63MASTER', 'H63_CODIGO')
                Endif
            GI6->(MsUnlock())

        Endif

    Next

    If lRet
        FwFormCommit(oModel)
    Else
        DisarmTransaction()
    Endif

End Transaction

Return lRet

/*/{Protheus.doc} G080VldDic
(long_description)
@type  Static Function
@author flavio.martins
@since 06/07/2022
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G080VldDic(cMsgErro)
Local lRet          := .T.
Local aTables       := {'H63','H64'}
Local aFields       := {}
Local nX            := 0
Default cMsgErro    := ''

aFields := {'H63_CODIGO','H63_DESCRI','H63_MSBLQL',;
            'H64_CODH63','H64_CODGZC'}

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
