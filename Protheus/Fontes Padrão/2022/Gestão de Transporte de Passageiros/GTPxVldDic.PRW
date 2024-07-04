#INCLUDE 'PROTHEUS.CH'


//------------------------------------------------------------------------------
/* /{Protheus.doc} GTPxVldDic
FunÃ§Ã£o responsavel pela validaÃ§Ã£o de estrutura
@type Function
@author jacomo.fernandes
@since 15/01/2020
@version 1.0
@param cAliasAux, character, (DescriÃ§Ã£o do parÃ¢metro)
@return lRet, return_description
/*/
//------------------------------------------------------------------------------
Function GTPxVldDic(cAliasAux,aFields,lVldAlias,lVldCampos,cMsgErro)
Local lRet  := .T.
Local n1    := 0
Local aArea := nil

Default cAliasAux   := ""
Default aFields     := {}
Default lVldAlias   := .T.
Default lVldCampos  := .T.
Default cMsgErro    := ""

If !Empty(cAliasAux)
    If lVldAlias .and. !AliasInDic(cAliasAux)
        lRet := .F.
        cMsgErro := I18n("Tabela #1 não se encontra no dicionário",{cAliasAux})
    Endif
Else
    lRet := .F.
    cMsgErro := "Tabela não informada"
Endif

If lRet .and. lVldCampos
    If Len(aFields) > 0
        If TCCanOpen(RetSqlName(cAliasAux)) .AND. CHKFILE(cAliasAux)
            DbSelectArea(cAliasAux)
            aArea   := (cAliasAux)->(GetArea())

            For n1 := 1 to Len(aFields)
                If (cAliasAux)->(ColumnPos(aFields[n1])) == 0
                    lRet        := .F.
                    cMsgErro    := I18n("Campo #1 não se encontra no dicionário",{aFields[n1]})
                    Exit
                Endif
            Next

            RestArea(aArea)
        Else
            lRet        := .F.
            cMsgErro    := I18n("Alias #1 não se encontra no dicionário",{cAliasAux})
        EndIf

    Else
        If !VldFields(cAliasAux,@cMsgErro)
            lRet := .F.
        Endif

    Endif
Endif

GtpDestroy(aFields)
GtpDestroy(aArea)

Return lRet


//------------------------------------------------------------------------------
/* /{Protheus.doc} VldFields(cAliasAux,cMsgErro)

@type Static Function
@author jacomo.fernandes
@since 15/01/2020
@version 1.0
@param cAliasAux, character, (DescriÃ§Ã£o do parÃ¢metro)
@param cMsgErro, character, (DescriÃ§Ã£o do parÃ¢metro)
@return lRet, return_description
/*/
//------------------------------------------------------------------------------
Static Function VldFields(cAliasAux,cMsgErro)
Local lRet      := .T.
Local aFields   := {}
Do Case 
    Case cAliasAux == "GQ6"
        aAdd(aFields,"GQ6_VTENCO")//12.1.27 - pacote 006885
        aAdd(aFields,"GQ6_TPCOMI")//12.1.27 - pacote 006885

    Case cAliasAux == "GQ7"
        aAdd(aFields,"GQ7_CODGYG")//12.1.27 - pacote 006885
        aAdd(aFields,"GQ7_QTDBIL")//12.1.27 - pacote 006885
        
    Case cAliasAux == "GQ9"
        aAdd(aFields,"GQ9_CODGYG")//12.1.27 - pacote 006885
        aAdd(aFields,"GQ9_QTDBIL")//12.1.27 - pacote 006885

    Case cAliasAux == "GIV"
        aAdd(aFields,"GIV_CODGQ6")//12.1.27 - pacote 006885
        aAdd(aFields,"GIV_SIMULA")//12.1.27 - pacote 006885
        aAdd(aFields,"GIV_CODGYG")//12.1.27 - pacote 006885
        
    Case cAliasAux == "GIX"
        aAdd(aFields,"GIX_CODGQ6")//12.1.27 - pacote 006885
        aAdd(aFields,"GIX_SIMULA")//12.1.27 - pacote 006885

    Case cAliasAux == "GIZ"
        aAdd(aFields,"GIZ_CODGQ6")//12.1.27 - pacote 006885
        aAdd(aFields,"GIZ_SIMULA")//12.1.27 - pacote 006885

    Case cAliasAux == "GZL"
        aAdd(aFields,"GZL_CODGYG")//12.1.27 - pacote 006885
        aAdd(aFields,"GZL_QTDTXA")//12.1.27 - pacote 006885

    Case cAliasAux == "GYF" //12.1.25
        aAdd(aFields,"GYF_PARAME")
        aAdd(aFields,"GYF_TIPO")

    Case cAliasAux == "GYK" //12.1.25
        aAdd(aFields,"GYK_CODIGO")
        aAdd(aFields,"GYK_DESCRI")

    Case cAliasAux == "G53" //12.1.25
        aAdd(aFields,"G53_GRUPO")
        aAdd(aFields,"G53_CAMPO")
        aAdd(aFields,"G53_DESCCP")

EndCase

If Len(aFields) > 0
    lRet := GTPxVldDic(cAliasAux,aFields,.F.,.T.,@cMsgErro)
Endif

Return lRet

