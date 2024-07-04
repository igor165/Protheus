#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"           
#INCLUDE "GTPXVLDREC.CH"

Static aMsgErro := {}

//------------------------------------------------------------------------------
/* /{Protheus.doc} GTPVldDocRec
Função responsavel pela validação dos documentos do recurso
@type Function
@author 
@since 17/07/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTPVldDocRec(cTpRecurso,cCodRec,dData,cIdLinha,lChkDocOrgao,lViagFrete,lViagTurismo,lViagRegular)

Local lRet          := .T.
Local lPergunta     := .T.

Local cMsgYesNo     := ""
Local cAliasTmp     := GetNextAlias()
Local cErro         := ""
Local cSolucao      := ""

Default cIdLinha        := ""
Default lChkDocOrgao    := .F.
Default lViagFrete      := .t.
Default lViagTurismo    := .t.
Default lViagRegular    := .t.

If AliasInDic("H68")
    If ( CreateQuery(@cAliasTmp,cCodRec,dData,cIdLinha,cTpRecurso,lChkDocOrgao,lViagFrete,lViagTurismo,lViagRegular) )

        While (cAliasTmp)->(!Eof())

            If ( "ERROR" $ Alltrim((cAliasTmp)->PROBLEMA) )    

                lRet        := .F.
                lPergunta   := .F.

                If ( "NODOC" $ AllTrim((cAliasTmp)->PROBLEMA) )

                    cErro := "O documento " 
                    cErro += (cAliasTmp)->(Alltrim(ID_DOC) + "-" + Alltrim(DESC_DOC))
                    cErro += " requerido pelo orgão, não é listado no vínculo de Documento x Recurso."

                    cSolucao := "Verifique se é necessário que o citado documento deva ser listado "
                    cSolucao += "(efetuando o ajuste no cadastro de Amarração entre Documento x Recurso) "
                    cSolucao += "ou se é necessário avaliar a documentação obrigatória, "
                    cSolucao += "no cadastro de Orgãos, aba Tipos de Documento."
                Else

                    cErro := "O documento " 
                    cErro += (cAliasTmp)->(Alltrim(ID_DOC) + "-" + Alltrim(DESC_DOC))
                    cErro += " requerido está vencido."

                    If ( !Empty((cAliasTmp)->DOC_DTFIM) )
                        cErro += " Data do vencimento " + DToC((cAliasTmp)->DOC_DTFIM) + "."
                    EndIf

                    cSolucao := "Será necessário efetuar ajustes no cadastro de "
                    
                    If ( "RECURSO" $ Alltrim((cAliasTmp)->PROBLEMA) )
                        cSolucao += "Amarração de Recurso x Documento."
                    Else
                        cSolucao += "Orgãos Concedentes, aba Tipos de Documentos."
                    EndIf

                EndIf

                DocSetMessage(cErro,cSolucao)

            ElseIf Empty(cMsgYesNo)

                lRet        := .F.
                lPergunta   := .T.
            
                cMsgYesNo   := STR0001//"O documento #1 - #2 encontra-se vencido desde o dia #3, porem está dentro da tolerância máxima (#4). Deseja Continuar?"
                cMsgYesNo   := I18n(cMsgYesNo,{ (cAliasTmp)->ID_DOC,;
                                                Alltrim((cAliasTmp)->DESC_DOC),;
                                                (cAliasTmp)->DOC_DTFIM,;
                                                (cAliasTmp)->DOC_DTMAX})
                
                cErro := "O documento "
                cErro += (cAliasTmp)->(Alltrim(ID_DOC) + "-" + Alltrim(DESC_DOC))
                cErro += " está vencido (data: " + DToC((cAliasTmp)->DOC_DTFIM) + ")."

                cSolucao := "Verifique a validade do citado documento pelo cadastro "
                cSolucao += IIf("RECURSO" $ Alltrim((cAliasTmp)->PROBLEMA),"Amarração de Recurso x Documento.","Orgãos Concedentes, aba Tipos de Documentos.")
                
                DocSetMessage(cErro,cSolucao)

            EndIf

            If (!lRet)        
                Exit        
            EndIf
            
            (cAliasTmp)->(DbSkip())

        End While

    EndIf
Else
    BeginSql Alias cAliasTmp
        Column G6W_DTFIM as Date
        Column G6W_DTMAX as Date
        Select 
            (Case
                when G6W_DTMAX < %Exp:dData% then 'ERROR'
                when G6W_DTFIM < %Exp:dData% then 'WARNING'
                ELSE ''
            End) as PROBLEMA,
            G6W.G6W_CODG6U,
            G6U.G6U_DESCRI,
            G6W.G6W_DTFIM,
            G6W.G6W_DTMAX
        From %Table:G6V% G6V
            Inner Join %Table:G6W% G6W on
                G6W.G6W_FILIAL = G6V.G6V_FILIAL
                AND G6W_CODIGO = G6V.G6V_CODIGO
                AND G6W_STATUS <> '2'
                AND G6W_DTFIM < %Exp:dData%
                AND G6W.%NotDel%
            Inner Join %Table:G6U% G6U on
                G6U.G6U_FILIAL = %xFilial:G6U%
                AND G6U.G6U_CODIGO = G6W.G6W_CODG6U
                AND G6U.%NotDel%
        Where
            G6V.G6V_FILIAL = %xFilial:G6V%
            AND G6V_TRECUR = %Exp:cTpRecurso%
            AND G6V_RECURS = %Exp:cCodRec%
            AND G6V_STATUS <> '2'
            AND G6V.%NotDel%
    EndSql

    While (cAliasTmp)->(!Eof())
        If Alltrim((cAliasTmp)->PROBLEMA) == "ERROR"
            lRet        := .F.
            lPergunta   := .F.
            Exit
        ElseIf Empty(cMsgYesNo)
            lRet        := .F.
            lPergunta   := .T.
            cMsgYesNo   := STR0001//"O documento #1 - #2 encontra-se vencido desde o dia #3, porem está dentro da tolerância máxima (#4). Deseja Continuar?"
            cMsgYesNo   := I18n(cMsgYesNo,{(cAliasTmp)->G6W_CODG6U,(cAliasTmp)->G6U_DESCRI,(cAliasTmp)->G6W_DTFIM,(cAliasTmp)->G6W_DTMAX})
        Endif

        (cAliasTmp)->(DbSkip())
    End
EndIf

(cAliasTmp)->(DbCloseArea())

If !lRet .and. lPergunta
    lRet    := FwAlertYesNo(cMsgYesNo,STR0002)//"Atenção!!!"
Endif

Return lRet

Static Function DocSetMessage(cErro,cSolucao,lReset)

    Default lReset  := .T.

    If ( lReset )
        aMsgErro := {}
    Endif

    aAdd(aMsgErro,{cErro,cSolucao})

Return()

Function DocErrorMessage(nWhat)

    Local aErro := {}

    Default nWhat := 2
    
    If LEN(aMsgErro) > 0
        If ( nWhat <= 1 )       //primeiro erro do array
            aAdd(aErro, aClone(aMsgErro[1]) )
        ElseIf ( nWhat == 2 )   //último erro do array
            aAdd(aErro, aClone(aMsgErro[Len(aMsgErro)]) )
        Else                    //todos os erros acumulados no array
            aErro := aClone(aMsgErro)
        EndIf
    EndIf

Return(aErro)

Function ResetErrorMsg()
    aMsgErro := {}
Return()


/*/{Protheus.doc} CreateQuery
description)
    @type  Static Function
    @author user
    @since 22/08/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function CreateQuery(cAlias,cCodRec,dData,cIdLinha,cTpRecurso,lChkDocOrgao,lViagFrete,lViagTurismo,lViagRegular)
    
    Local lRet      := .F.

    Local cObrigDoc := ""
    Local cIdOrgao  := ""
    Local cDescOrgao:= ""
    Local cInRecurso:= ""
    
    cObrigDoc   := "%( "
    cObrigDoc   += "    (G6U.G6U_TRECUR = '3' "
    cObrigDoc   += "    AND H68_VIAFRT "    + Iif(lViagFrete, " = 'T' "," <> 'T' ")
    cObrigDoc   += "    AND H68_VIATUR "  + Iif(lViagTurismo," = 'T' "," <> 'T' ") 
    cObrigDoc   += "    AND H68_VIAREG "  + Iif(lViagRegular," = 'T' "," <> 'T' ") + ")"
    cObrigDoc   += "    OR G6U.G6U_TRECUR <> '3' )%"

    cIdOrgao    := IIf(!Empty(cIdLinha),GI2->(GetAdvFVal("GI2","GI2_ORGAO",XFilial("GI2") + cIdLinha,1,"")),"")
    cDescOrgao  := IIf(!Empty(cIdLinha),GI0->(GetAdvFVal("GI0","GI0_DESCRI",XFilial("GI0") + cIdOrgao,1,"")),"")
    
    cInRecurso := "% ('" + cTpRecurso + IIf( lChkDocOrgao, "','3') ","') ") + "%"

    BeginSQL Alias cAlias

        Column DOC_DTFIM as Date
        Column DOC_DTMAX as Date
        Column VIAGFRETE as Logical
        Column VIAGTURISM as Logical
        Column VIAGREGULA as Logical

        SELECT
            (
                CASE 
                    WHEN 
                        DOCUMENTO.ORIGEM = 'DOC_X_ORG' 
                        AND DOCUMENTO.DOC_TRECUR <> '3' 
                    THEN 
                        'ERROR_NODOC'
                    WHEN 
                        DOCUMENTO.ORIGEM = 'DOC_X_ORG' 
                        AND DOCUMENTO.DOC_TRECUR = '3' 
                        AND DOCUMENTO.DOC_DTMAX < %Exp:dData%
                    THEN 
                        'ERROR_ORGAO'
                    WHEN 
                        DOCUMENTO.ORIGEM = 'DOC_X_ORG' 
                        AND DOCUMENTO.DOC_TRECUR = '3' 
                        AND DOCUMENTO.DOC_DTFIM < %Exp:dData%
                    THEN 
                        'WARNING_ORGAO'
                    ELSE
                        (
                            CASE
                                WHEN 
                                    DOCUMENTO.DOC_DTMAX < %Exp:dData% 
                                THEN 
                                    'ERROR_RECURSO'
                                WHEN 
                                    DOCUMENTO.DOC_DTFIM < %Exp:dData% 
                                THEN 
                                    'WARNING_RECURSO'
                            END
                        )
                    END
            ) AS PROBLEMA,
            DOCUMENTO.*
        FROM
            (
                SELECT
                    (
                        CASE
                            WHEN 
                                DOC_REC.ORIGEM IS NULL 
                            THEN 
                                DOC_ORGAO.ORIGEM
                            ELSE 
                                DOC_REC.ORIGEM
                        END
                    ) ORIGEM,
                    (
                        CASE
                            WHEN 
                                DOC_REC.ID_DOC IS NULL 
                            THEN 
                                DOC_ORGAO.ID_DOC
                            ELSE 
                                DOC_REC.ID_DOC
                        END
                    ) ID_DOC,
                    (
                        CASE
                            WHEN 
                                DOC_REC.DESC_DOC IS NULL 
                            THEN 
                                DOC_ORGAO.DESC_DOC
                            ELSE 
                                DOC_REC.DESC_DOC
                        END
                    ) DESC_DOC,
                    (
                        CASE
                            WHEN 
                                DOC_REC.DOC_DTINI IS NULL 
                            THEN 
                                DOC_ORGAO.DOC_DTINI
                            ELSE 
                                DOC_REC.DOC_DTINI
                        END
                    ) DOC_DTINI,
                    (
                        CASE
                            WHEN 
                                DOC_REC.DOC_DTFIM IS NULL 
                            THEN 
                                DOC_ORGAO.DOC_DTFIM
                            ELSE 
                                DOC_REC.DOC_DTFIM
                        END
                    ) DOC_DTFIM,
                    (
                        CASE
                            WHEN 
                                DOC_REC.DOC_DTMAX IS NULL 
                            THEN 
                                DOC_ORGAO.DOC_DTMAX
                            ELSE 
                                DOC_REC.DOC_DTMAX
                        END
                    ) DOC_DTMAX,
                    (
                        CASE
                            WHEN 
                                DOC_REC.DOC_TRECUR IS NULL 
                            THEN 
                                DOC_ORGAO.DOC_TRECUR
                            ELSE 
                                DOC_REC.DOC_TRECUR
                        END
                    ) DOC_TRECUR
                FROM
                    (	
                        SELECT 
                            'DOC_X_REC'		AS ORIGEM,
                            G6W_CODG6U		AS ID_DOC,
                            G6U_DESCRI		AS DESC_DOC,
                            G6U_TRECUR		AS DOC_TRECUR,
                            G6W.G6W_DTINI	AS DOC_DTINI,
                            G6W.G6W_DTFIM	AS DOC_DTFIM, 
                            G6W.G6W_DTMAX	AS DOC_DTMAX, 
                            'T'				AS VIAGFRETE, 
                            'T'				AS VIAGTURISM, 
                            'T'				AS VIAGREGULA
                        FROM 
                            %Table:G6V% G6V 
                        INNER JOIN 
                            %Table:G6W% G6W 
                        ON 
                            G6W.G6W_FILIAL = G6V.G6V_FILIAL 
                            AND G6W_CODIGO = G6V.G6V_CODIGO 
                            AND G6W_STATUS <> '2' 
                            AND G6W.%NotDel% 
                        INNER JOIN 
                            %Table:G6U% G6U 
                        ON 
                            G6U.G6U_FILIAL = %xFilial:G6U%
                            AND G6U.G6U_CODIGO = G6W.G6W_CODG6U 
                            AND G6U.%NotDel% 
                        WHERE 
                            G6V.G6V_FILIAL = %xFilial:G6V% 
                            AND G6V_TRECUR = %Exp:cTpRecurso%
                            AND G6V_RECURS = %Exp:cCodRec%
                            AND G6V_STATUS <> '2' 
                            AND G6V.%NotDel%    
                    ) DOC_REC
                FULL OUTER JOIN
                    (
                        SELECT
                            'DOC_X_ORG'		AS ORIGEM,
                            H68.H68_CODG6U	AS ID_DOC,
                            G6U_DESCRI		AS DESC_DOC,
                            G6U_TRECUR		AS DOC_TRECUR,
                            H68.H68_DTINI	AS DOC_DTINI,
                            H68.H68_DTFIM	AS DOC_DTFIM, 
                            H68.H68_DTMAX	AS DOC_DTMAX, 
                            H68.H68_VIAFRT	AS VIAGFRETE, 
                            H68.H68_VIATUR	AS VIAGTURISM, 
                            H68.H68_VIAREG	AS VIAGREGULA
                        FROM 
                            %Table:H68% H68 
                        INNER JOIN 
                            %Table:G6U% G6U 
                        ON 
                            G6U.G6U_FILIAL = %xFilial:G6U% 
                            AND G6U.G6U_CODIGO = H68.H68_CODG6U 
                            AND G6U.G6U_TRECUR IN %Exp:cInRecurso%
                            AND G6U.%NotDel%
                        WHERE
                            H68.H68_FILIAL = %xFilial:H68%
                            AND H68.H68_CODGI0 = %Exp:cIdOrgao% 
                            AND 
                            (
                                (
                                    ( 
                                        %Exp:dData% BETWEEN H68.H68_DTINI AND H68.H68_DTFIM 
                                        AND G6U.G6U_TRECUR <> '3'
                                    ) 
                                    OR 
                                    (
                                        H68.H68_DTMAX  < %Exp:dData% 
                                        AND G6U.G6U_TRECUR = '3'
                                    ) 
                                )
                                OR 
                                (
                                    H68.H68_DTINI = '' 
                                    OR H68.H68_DTFIM = ''
                                )
                            )                           
                            AND H68.%NotDel% 
                            AND %Exp:cObrigDoc%    
                ) DOC_ORGAO
                ON
                    DOC_REC.ID_DOC = DOC_ORGAO.ID_DOC
            ) AS DOCUMENTO
        WHERE
	        DOCUMENTO.DOC_DTFIM < %Exp:dData%
        ORDER BY 1
                    
    EndSQL

    (cAlias)->(DbGoTop())

    lRet := (cAlias)->(!Eof())

Return(lRet)
