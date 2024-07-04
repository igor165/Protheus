#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA900B.CH"

/*/{Protheus.doc} GTPA900B()
    Rotina para manutenção dos documentos operacionais do contrato
    @type  Static Function
    @author Flavio Martins
    @since 11/08/2022
    @version 1
    @param 
    @return Nil
    @example
    (examples)
    @see (links_or_references)
/*/ 
Function GTPA900B()
Local cMsgErro  := ''

If G900BVlDic(@cMsgErro)    
    FwMsgRun(, {|| FwExecView(STR0001, "VIEWDEF.GTPA900B", MODEL_OPERATION_UPDATE,,{|| .T.},,50)},"", STR0002) // "Documentos X Contrato Fretamento Contínuo","VIEWDEF.GTPA900B", "Carregando documentos..."
Else
    FwAlertHelp(cMsgErro, STR0006) // "Banco de dados desatualizado, não será possível iniciar a rotina"
Endif

Return

/*/{Protheus.doc} ModelDef
    Model Documentos X Orçamento Contrato
    @type  Static Function
    @author Flavio Martins
    @since 11/08/2022
    @version 1
    @param 
    @return oModel, objeto, instância da classe FwFormModel
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ModelDef()
Local oModel	    := Nil
Local oStruGY0	    := FwFormStruct( 1, "GY0",,.F. ) // Orçamento de Contrato
Local oStruH69	    := FwFormStruct( 1, "H69",,.F. ) // Doctos  Vs Contr. Fret. Cont.
Local bFieldTrg     := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bFieldVld     := {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local bVldActiv     := {|oModel| G900BVldAct(oModel)}

oModel := MpFormModel():New("GTPA900B",,,)

oModel:AddFields("GY0MASTER", /*cOwner*/, oStruGY0,,,/*bLoad*/)
oModel:AddGrid("H69DETAIL", "GY0MASTER", oStruH69)

oModel:SetRelation('H69DETAIL', {{'H69_FILIAL', 'xFilial("H69")'}, {'H69_NUMERO', 'GY0_NUMERO'}, {'H69_REVISA', 'GY0_REVISA'} }, H69->(IndexKey(1)))

oModel:SetPrimaryKey({})

oModel:GetModel('H69DETAIL'):SetOptional(.T.)

oStruGY0:SetProperty('*', MODEL_FIELD_WHEN, { ||.F.} )
oStruH69:SetProperty('H69_EXPIRA', MODEL_FIELD_WHEN, { ||.F.} )
oStruH69:SetProperty('H69_EXIGEN', MODEL_FIELD_OBRIGAT, .T.)

oStruH69:AddTrigger("H69_CODG6U", "H69_CODG6U", {||.T.}, bFieldTrg)
oStruH69:AddTrigger("H69_CHKLST", "H69_CHKLST", {||.T.}, bFieldTrg)
oStruH69:AddTrigger("H69_DATAUL", "H69_DATAUL", {||.T.}, bFieldTrg)

oStruH69:SetProperty('H69_CHKLST', MODEL_FIELD_VALID, bFieldVld)

oModel:SetVldActivate(bVldActiv)

Return oModel

/*/{Protheus.doc} G900BVldAct
(long_description)
@type  Static Function
@author flavio.martins
@since 16/08/2022
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G900BVldAct(oModel)
Local lRet      := .T.
Local cMsgErro  := ''
Local cMsgSol   := ''

If !G900BVlDic(@cMsgErro)
    lRet := .F.
    cMsgSol :=  STR0007 //"Atualize o dicionário para utilizar esta rotina"
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G080VldAct", cMsgErro, cMsgSol) 
Endif

Return lRet

/*/{Protheus.doc} FieldTrigger(oMdl,cField,uVal)
    Função para gatilhos de campos do model
    @type  Static Function
    @author Flavio Martins
    @since 16/08/2022
    @version 1
    @param 
    @return uVal
    @example
    (examples)
    @see (links_or_references)
/*/ 
Static Function FieldTrigger(oMdl,cField,uVal)

Do Case

    Case cField == 'H69_CODG6U'
        oMdl:SetValue("H69_DSCG6U", Posicione('G6U',1,xFilial('G6U')+uVal,'G6U_DESCRI'))
    Case cField == 'H69_CHKLST'
        If uVal
            oMdl:SetValue("H69_USUCHK", AllTrim(RetCodUsr()))
            oMdl:SetValue("H69_DTCHK", FwTimeStamp(2))
        Else
            oMdl:ClearField("H69_USUCHK")
            oMdl:ClearField("H69_DTCHK")
        Endif
    Case cField == "H69_DATAUL"
        oMdl:LoadValue("H69_EXPIRA",GetDtVigencia(uVal,oMdl:GetValue('H69_TPPERI'),oMdl:GetValue('H69_QTDPER')))

EndCase

Return uVal

/*/{Protheus.doc} FieldValid(oMdl,cField,uNewValue,uOldValue)
    Função de valid de campos do model
    @type  Static Function
    @author Flavio Martins
    @since 16/08/2022
    @version 1
    @param 
    @return lógico
    @example
    (examples)
    @see (links_or_references)
/*/ 
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue)
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Do Case
    Case cField == "H69_CHKLST"
        If !Empty(oModel:GetValue('H69DETAIL', 'H69_EXPIRA')) .And. oModel:GetValue('H69DETAIL', 'H69_EXPIRA') < dDataBase
            lRet		:= .F.
            cMsgErro	:= STR0008 // "Data de expiração do documento vencida"
            cMsgSol		:= STR0009 // "Verifique ou atualize a validade do documento"
        Endif
EndCase         

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

/*/{Protheus.doc} ViewDef
    View Documentos X Orçamento Contrato
    @type  Static Function
    @author Flavio Martins
    @since 11/08/2022
    @version 1
    @param 
    @return oView, objeto, instância da Classe FWFormView
    @example
    (examples)
    @see (links_or_references)
/*/ 
Static Function ViewDef()
Local oView		:= Nil
Local oModel    := FwLoadModel("GTPA900B")
Local cFldsGY0  := "GY0_NUMERO|GY0_REVISA|GY0_CLIENT|GY0_LOJACL|GY0_DTINIC"
Local aFldsGY0  := StrToKarr(cFldsGY0, "|")
Local oStruGY0	:= FwFormStruct(2, "GY0",{|cCpo| (AllTrim(cCpo))$ cFldsGY0})
Local oStruH69	:= FwFormStruct(2, "H69",{|cCpo| !(AllTrim(cCpo))$ "H69_FILIAL|H69_NUMERO|H69_REVISA|H69_CHKLST|H69_USUCHK|H69_DTCHK"})
Local nX        := 0

// Cria o objeto de View
oView := FwFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

oView:AddField("VIEW_HEADER", oStruGY0, "GY0MASTER")
oView:AddGrid("VIEW_DETAIL", oStruH69, "H69DETAIL")

oView:CreateHorizontalBox("HEADER", 20)
oView:CreateHorizontalBox("DETAIL", 80)

oView:SetOwnerView("VIEW_HEADER", "HEADER")
oView:SetOwnerView("VIEW_DETAIL", "DETAIL")

oView:EnableTitleView('VIEW_HEADER', STR0003) // 'Dados do Contrato' 
oView:EnableTitleView('VIEW_DETAIL', STR0004) // 'Documentos Operacionais'

For nX := 1 To Len(aFldsGY0)
    oStruGY0:SetProperty(aFldsGY0[nX], MVC_VIEW_ORDEM , StrZero(nX, 2))
Next

oView:AddUserButton(STR0005, "", {|oView| GetDocsCli(oView)},, ,) // "Copiar Documentos do Cliente"

Return oView

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
    Case cTpVigen == "1" //Ano
        dDtFim  := YearSum(dDtIni,nTempVig)
    Case cTpVigen == "2" //Mes
        dDtFim  := MonthSum(dDtIni,nTempVig)
    Case cTpVigen == "3" //Dia
        dDtFim  := DaySum(dDtIni,nTempVig)
EndCase

Return dDtFim

/*/{Protheus.doc} GetDocsCli
    Faz a chamada da função para copia dos documentos dos clientes    
    @type  Static Function
    @author Flavio Martins
    @since 15/08/2022
    @version 1
    @param oView
    @return Nil
    @example
    (examples)
    @see (links_or_references)
/*/ 
Static Function GetDocsCli(oView)
Local oModel := oView:GetModel()

G900BCopy(oModel)

Return

/*/{Protheus.doc} G900BCopy
    Realiza da cópia dos documentos do cliente do contrato
    @type  Static Function
    @author Flavio Martins
    @since 15/08/2022
    @version 1
    @param oModel
    @return Nil
    @example
    (examples)
    @see (links_or_references)
/*/ 
Function G900BCopy(oMdl900B)
Local cCliente 	:= oMdl900B:GetValue('GY0MASTER', 'GY0_CLIENT')
Local cLoja 	:= oMdl900B:GetValue('GY0MASTER', 'GY0_LOJACL')
Local cAliasTmp := GetNextAlias()

Default oMdl900B := Nil

If AliasInDic('H6A') .And. AliasInDic('H6B') .And. AliasInDic('H69')

    BeginSql Alias cAliasTmp

        SELECT H6B.H6B_CODG6U,
            H6B.H6B_SEQ,
            H6B.H6B_TPPERI,
            H6B.H6B_QTDPER,
            H6B.H6B_DATAUL,
            H6B.H6B_EXPIRA,
            H6B.H6B_EXIGEN
        FROM %Table:H6A% AS H6A
        INNER JOIN %Table:H6B% AS H6B ON H6B.H6B_FILIAL = %xFilial:H6B%
        AND H6B.H6B_CODIGO = H6A.H6A_CODIGO
        AND H6B.%NotDel%
        WHERE H6A.H6A_FILIAL = %xFilial:H6A%
        AND H6A.H6A_CLIENT = %Exp:cCliente%
        AND H6A.H6A_LOJA   = %Exp:cLoja%
        AND H6A.H6A_STATUS = '1'
        AND H6A.%NotDel%

    EndSql

    If (cAliasTmp)->(!Eof())

        While (cAliasTmp)->(!Eof())
        
            If !(oMdl900B:GetModel('H69DETAIL'):SeekLine({{'H69_CODG6U', (cAliasTmp)->H6B_CODG6U}}))

                If !(oMdl900B:GetModel('H69DETAIL'):IsEmpty())
                    oMdl900B:GetModel('H69DETAIL'):AddLine()
                Endif

                oMdl900B:GetModel('H69DETAIL'):SetValue('H69_CODG6U', (cAliasTmp)->H6B_CODG6U)
                oMdl900B:GetModel('H69DETAIL'):SetValue('H69_TPPERI', (cAliasTmp)->H6B_TPPERI)
                oMdl900B:GetModel('H69DETAIL'):SetValue('H69_QTDPER', (cAliasTmp)->H6B_QTDPER)
                oMdl900B:GetModel('H69DETAIL'):SetValue('H69_DATAUL', StoD((cAliasTmp)->H6B_DATAUL))
                oMdl900B:GetModel('H69DETAIL'):LoadValue('H69_EXPIRA', StoD((cAliasTmp)->H6B_EXPIRA))
                oMdl900B:GetModel('H69DETAIL'):SetValue('H69_EXIGEN', (cAliasTmp)->H6B_EXIGEN)

            Endif

            (cAliasTmp)->(dbSkip())

        EndDo

        oMdl900B:GetModel('H69DETAIL'):GoLine(1)

    Endif

    (cAliasTmp)->(dbCloseArea())

Endif

Return

/*/{Protheus.doc} G900BVlDic
(long_description)
@type  Static Function
@author flavio.martins
@since 16/08/2022
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function G900BVlDic(cMsgErro)
Local lRet          := .T.
Local aTables       := {'H6A','H6B','H69'}
Local aFields       := {}
Local nX            := 0
Default cMsgErro    := ''

aFields := {'H69_NUMERO','H69_REVISA','H69_CODG6U'}

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
