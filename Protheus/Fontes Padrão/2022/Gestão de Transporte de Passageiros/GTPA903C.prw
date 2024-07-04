#Include "GTPA903C.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA903C
Estorno da apuração e envio para medição do contrato CNTA121
@type Function
@author 
@since 06/04/2021
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTPA903C()
Local cCorApura := ""
Local cMsgErro  := ''
Local lRet      := .T.

If ValidaDic(@cMsgErro)
    If GQR->GQR_STATUS == "2"
        IF !IsBlind()
            If MsgYesNo(STR0002,STR0001) //'Atenção!' //'Deseja estornar a medição da apuração'
                cCorApura := GQR->GQR_CODIGO//Deixado assim para testes
                FwMsgRun(,{|| PreparaDados(cCorApura,@lRet) },,STR0003 ) //"Estornando medição..."
                AtualContr(cCorApura,lRet)
            EndIf
        Else
            cCorApura := GQR->GQR_CODIGO//Deixado assim para testes
            FwMsgRun(,{|| PreparaDados(cCorApura,@lRet) },,STR0003 ) //"Estornando medição..."
            AtualContr(cCorApura,lRet)
        EndIf
    Else
        FwAlertHelp(STR0005, STR0004,) //"Atenção" //"Status deve estar com apuração efetivada para estornar a medição"
    EndIf
Else
     FwAlertHelp(cMsgErro, STR0006,) //"Atualize o dicionário para utilizar esta rotina"
EndIf
Return lRet


/*/{Protheus.doc} AtualContr
(long_description)
@type  Static Function
@author user
@since 12/04/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function AtualContr(cCorApura,lRet)
Local aArea := GetArea()

DbSelectArea("GQR")
DbSetOrder(1)
If G9W->(DbSeek(xFilial("GQR") + cCorApura))
    If lRet
        RecLock("GQR",.F.)
        GQR->GQR_STATUS := "1"
        GQR->(MsUnLock())
    EndIf
EndIf
RestArea(aArea)

Return 

/*/{Protheus.doc} PreparaDados
(long_description)
@type  Static Function
@author user
@since 08/04/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function PreparaDados(cCorApura,lRet)
Local cAliasTmp := ""  
Local cCodCTR   := "" 
Local cCodGqr   := ""
Local cNumGy0   := ""
Local cMedErro  := ""

Default cCorApura := ""
Default lRet      := .T.

    cAliasTmp := QueryOrcamento(cCorApura)
    If (cAliasTmp)->(!Eof())
        While (cAliasTmp)->(!Eof())
            
            cCodCTR := (cAliasTmp)->G9W_CONTRA
            cCodGqr := (cAliasTmp)->G9W_CODGQR
            cNumGy0 := (cAliasTmp)->G9W_NUMGY0
            lRet := EstornaMedicao(cCodCTR,@cMedErro)
            If lRet .AND. EMPTY(cMedErro)
                lRet := ExcluiMedicao(cCodCTR,@cMedErro)
            EndIf
            If lRet
                AtualizaContr(cCodGqr,cNumGy0)
            EndIf
            (cAliasTmp)->(DbSkip())
        EndDo

        If !(EMPTY(cMedErro))
            Help(,,"GTPA903CApur",, cMedErro, 1,0)
            lRet := .F.
        EndIf
    Else
        Help(,,"GTPA903CApur",, STR0007, 1,0) //"Não foram encontrados dados"
        lRet := .F.
    EndIf
    (cAliasTmp)->(DbCloseArea())

Return lRet

/*/{Protheus.doc} AtualizaContr
Query para retornar os dados da apuração e orçamento para a medição
@type  Static Function
@author user
@since 08/04/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function AtualizaContr(cCodGqr,cNumGy0)
Local aArea := GetArea()

    DbSelectArea("G9W")
    DbSetOrder(1)
    If G9W->(DbSeek(xFilial("G9W") + cCodGqr + cNumGy0))
        RecLock("G9W",.F.)
        G9W->G9W_CODCND := ""
        G9W->(MsUnLock())
    EndIf

RestArea(aArea)
Return

/*/{Protheus.doc} EstornaMedicao
(long_description)
@type  Static Function
@author user
@since 09/04/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function EstornaMedicao(cCodCTR,cMedErro)
Local lRet      := .F.

Default cCodCTR := ""
      
    CND->(DbSetOrder(1))
        
    If CND->(DbSeek(xFilial("CND") + cCodCTR))//Posicionar na CND para realizar o estorno
        CN121Estorn(.T.,/*lAprRev*/, @cMedErro)
        lRet := Empty(cMedErro) //Vazio caso nao ocorra nenhum erro
    EndIf 
    
Return lRet

/*/{Protheus.doc} ExcluiMedicao
(long_description)
@type  Static Function
@author user
@since 13/04/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ExcluiMedicao(cCodCTR,cMedErro)
Local oModel    := Nil
Local lRet      := .F.
      
    CND->(DbSetOrder(1))
          
    If CND->(DbSeek(xFilial("CND") + cCodCTR))//Posicionar na CND para realizar a exclusão
        oModel := FWLoadModel("CNTA121")
          
        oModel:SetOperation(MODEL_OPERATION_DELETE)
        If(oModel:CanActivate())          
            oModel:Activate()
            If (oModel:VldData()) /*Valida o modelo como um todo*/
                oModel:CommitData()
            EndIf
        EndIf
         
        lRet := !(oModel:HasErrorMessage())
        If(!lRet)
            cMedErro := Alltrim(oModel:GetErrorMessage()[6]) + ". " + Alltrim(oModel:GetErrorMessage()[7])
        EndIf
    EndIf 
Return lRet
/*/{Protheus.doc} QueryOrcamento
Query para retornar os dados da apuração e orçamento para a medição
@type  Static Function
@author user
@since 08/04/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function QueryOrcamento(cCorApura)
Local cAliasAUX := ''

Default cCorApura := ''

cAliasAUX := GetNextAlias()

    BeginSQL alias cAliasAUX


        SELECT
            G9W.G9W_CONTRA, G9W.G9W_CODGQR, G9W.G9W_NUMGY0
        FROM
            %Table:GQR% GQR
            INNER JOIN
                %Table:G9W% G9W
                ON
                    G9W.G9W_FILIAL     = GQR.GQR_FILIAL
                    AND G9W.G9W_CODGQR = GQR.GQR_CODIGO
                    AND G9W.%NotDel%
        WHERE
            GQR.GQR_FILIAL     = %xFilial:GQR%
            AND GQR.GQR_CODIGO = %exp:cCorApura%
            AND GQR.%NotDel%
    EndSql

Return cAliasAUX

/*/{Protheus.doc} ValidDic
//TODO Descrição auto-gerada.
@author flavio.martins
@since 31/03/2021
@version 1.0
@return ${return}, ${return_description}
@param
@type function
/*/
Static Function ValidaDic(cMsgErro)
Local lRet          := .T.
Local aTables       := {'GYD','GQR','G9W','G54'}
Local aFields       := {}
Local nX            := 0
Default cMsgErro    := ''

aFields := {'G9W_CONTRA','G54_PRODUT','G54_PRODNT',;
            'G54_QTDE','GYD_PRECON','GYD_VLRTOT',;
            'GYD_PREEXT','GYD_VLREXT'}

For nX := 1 To Len(aTables)
    If !(GTPxVldDic(aTables[nX], {}, .T., .F., @cMsgErro))
        lRet := .F.
        Exit
    Endif
Next

For nX := 1 To Len(aFields)
    If !(Substr(aFields[nX],1,3))->(FieldPos(aFields[nX]))
        lRet := .F.
        cMsgErro := I18n(STR0008,{aFields[nX]}) //"Campo #1 não se encontra no dicionário"
        Exit
    Endif
Next

Return lRet
