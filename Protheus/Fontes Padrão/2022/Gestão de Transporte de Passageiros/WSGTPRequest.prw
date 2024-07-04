#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSGtpForms
Métodos WS do GTP para integração de Geração de Titulos

@author SIGAGTP
@since 07/08/2021
@version 1.0

/*/
//-------------------------------------------------------------------

WSRESTFUL GTPREQUEST DESCRIPTION "WS de Requisição" 

	WSDATA codCli               AS STRING OPTIONAL
	WSDATA codLoj               AS STRING OPTIONAL
	WSDATA valTot               AS STRING OPTIONAL
	WSDATA ped                  AS STRING OPTIONAL
    WSDATA linha                AS STRING OPTIONAL
    WSDATA locOri               AS STRING OPTIONAL
    WSDATA locDes               AS STRING OPTIONAL
    WSDATA status               AS STRING OPTIONAL
    WSDATA filialSelecionada 	AS STRING

	// Métodos GET
	WSMETHOD GET discountTickets DESCRIPTION 'Gera desconto no bilhete da requisição'  PATH "discountTickets" PRODUCES APPLICATION_JSON 
	
    // Métodos POST
	WSMETHOD POST bulkDiscountTickets   DESCRIPTION 'Gera desconto em massa dos bilhetes da requisição' PATH "bulkDiscountTickets" PRODUCES APPLICATION_JSON
    
    // Métodos PUT
    WSMETHOD PUT updateGQW  DESCRIPTION 'Efetua a alteração das requisições quando adicionadas em lote' PATH "updateGQW" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET discountTickets WSRECEIVE codCli,codLoj,valTot,ped,linha,locOri,locDes,status,filialSelecionada WSREST GTPREQUEST
Local lRet  	:= .T.
Local aValDes   := {}
Local oResponse := JsonObject():New()
Local cFilSelect	:= Self:filialSelecionada

If Self:codCli == NIL
    oResponse:setStatusCode( 403 ) // Forbidden
    oResponse["codCli"] := "nao informado cliente"
    lRet := .F.
EndIf

If lRet
    aValDes := CalcDesconto({Self:codCli,Self:codLoj,Self:valTot,Self:ped,Self:linha,Self:locOri,Self:locDes,Self:status,cFilSelect})

    oResponse['status'] := "1"
    oResponse['valTotal'] := Self:valTot
    oResponse['valDesconto'] := aValDes[1]
    oResponse['totalRequisicao'] := aValDes[2]
    oResponse['desconto'] := aValDes[3]

    
EndIf
Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

WSMETHOD POST bulkDiscountTickets WSREST GTPREQUEST
Local lRet  	:= .T.
Local nBilhete  := 0
Local nValDesc  := 0
Local nValTot   := 0
Local aValDes   := {}
Local oRequest	:= JSonObject():New()
Local oResponse := JsonObject():New()
Local cBody     := Self:GetContent()

oRequest:fromJson(cBody)

For nBilhete := 1 To len(oRequest[1])
    
    If oRequest[1][nBilhete]['stateRow'] != 3
        aValDes := CalcDesconto(;
                {;
                    oRequest[2][1],;
                    oRequest[2][2],;
                    oRequest[1][nBilhete]['valorTotal'],;
                    oRequest[1][nBilhete]['pedagio'],;
                    oRequest[1][nBilhete]['codLinha'],;
                    oRequest[1][nBilhete]['locOri'],;
                    oRequest[1][nBilhete]['locDes'],;
                    oRequest[1][nBilhete]['statusBil'],;
                    oRequest[3];
                };
            )

        oRequest[1][nBilhete]['descRequisicao'] = aValDes[1] //desconto da requisição
        oRequest[1][nBilhete]['totalRequisicao'] = aValDes[2] //total da requisição
        nValDesc += aValDes[1]
        nValTot  += aValDes[2]
    EndIf
Next nBilhete

oResponse['ok'] := lRet
oResponse['valTotal'] := nValTot
oResponse['valDesconto'] := nValDesc
oResponse['bilhetes'] := oRequest[1]

Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CalcDesconto()
Função de aplicação de descontos por bilhetes
@author  gtp
@since   
@version P12
/*/
//-------------------------------------------------------------------
Static Function CalcDesconto(aArray)

Local aArea     := GetArea()
Local cAliasGQX := GetNextAlias()
Local cClient   := aArray[1]//oModelGQW:GetValue("GQW_CODCLI")
Local cLoja     := aArray[2]//oModelGQW:GetValue("GQW_CODLOJ")
Local nValorTot := VAL(aArray[3])//oModelGIC:GetValue("GIC_VALTOT")
Local nValor    := VAL(aArray[3])//oModelGIC:GetValue("GIC_VALTOT")
Local nValPed   := VAL(aArray[4])//oModelGIC:GetValue("GIC_PED")
Local cLinha    := aArray[5]//oModelGIC:GetValue("GIC_LINHA")
Local cLocOri   := aArray[6]//oModelGIC:GetValue("GIC_LOCORI")
Local cLocDes   := aArray[7]//oModelGIC:GetValue("GIC_LOCDES")
Local cFilSelc  := aArray[8]//Filial selecionada
Local cFilOldS  := cfilant
Local nValDes   := 0

cfilant := cFilSelc

If !(aArray[8] $ "C|D|I")
    BeginSql Alias cAliasGQX

        SELECT 
            GQV.GQV_COBPED,
            GQX.GQX_TPVAL,
            (CASE 
                WHEN GQX.GQX_TPVAL = '1' THEN GQX.GQX_DSCPER 
                ELSE GQX.GQX_DSCFIX 
            END) AS VALOR
            
        FROM %Table:GQV % GQV 
            LEFT JOIN %Table:GQX% GQX ON 
                GQX.GQX_FILIAL = %xFilial:GQX% AND 
                GQV.GQV_CODIGO = GQX.GQX_CODIGO AND 
                GQV.GQV_CODLOJ = GQX.GQX_CODLOJ AND 
                GQX.GQX_MSBLQL = '2'AND	
                (GQX.GQX_DTVFIN = '' OR (GQX.GQX_DTVINI <= %Exp:dDataBase% AND GQX.GQX_DTVFIN >= %Exp:dDataBase%)) AND
                ((GQX.GQX_DSCTIP = '1') OR	(GQX.GQX_LINHA = %Exp:cLinha%) OR (GQX.GQX_LOCORI = %Exp:cLocOri% AND GQX.GQX_LOCDES = %Exp:cLocDes%)	)	AND
                GQX.%NotDel%
        WHERE  
            GQV.GQV_FILIAL = %xFilial:GQV% AND
            GQV.GQV_CODIGO = %Exp:cClient% AND
            GQV.GQV_CODLOJ = %Exp:cLoja% AND
            GQV.%NotDel% 
        ORDER BY  GQX.GQX_DSCTIP||GQX.GQX_DTVINI||GQX.GQX_DTVFIN

    EndSql

    If (cAliasGQX)->(!Eof())
        nValDes := (cAliasGQX)->VALOR
        If (cAliasGQX)->GQV_COBPED == '2' //Se não cobra pedagio, remover o valor do pedagio
            nValor-=nValPed
        Endif
        IF (cAliasGQX)->GQX_TPVAL == '1' //Se Porcentagem
            nValor := nValor * (1-((cAliasGQX)->VALOR/100))
        ELSE
            nValor := nValor - (cAliasGQX)->VALOR
        Endif
        If nValor < 0 .OR. nValDes == 0
            nValor := 0
        Endif

    Else
        nValor  := 0
        nValDes := 0
    Endif
    (cAliasGQX)->(dbCloseArea())
Endif

RestArea(aArea)
cfilant := cFilOldS
Return {nValor,nValorTot,nValDes}


WSMETHOD PUT updateGQW WSREST GTPREQUEST
Local lRet  	:= .T.
Local nRequisicao  := 0
Local cCodigoLote := ""
Local oRequest	:= JSonObject():New()
Local oResponse := JsonObject():New()
Local cBody     := Self:GetContent()

oRequest:fromJson(cBody)

cCodigoLote := oRequest[1]

For nRequisicao := 1 To len(oRequest[2])
    If oRequest[2][nRequisicao]['stateRow'] == 1 .OR. oRequest[2][nRequisicao]['stateRow'] == 2
        lRet := UpdateRequisicao(cCodigoLote,;
                {;
                    oRequest[2][nRequisicao]['cGQWCODIGO'],;
                    oRequest[2][nRequisicao]['cGQWCODCLI'],;
                    oRequest[2][nRequisicao]['cGQWCODLOJ'],;
                    oRequest[2][nRequisicao]['cGQWCODAGE'];
                };
            )
    ElseIf oRequest[2][nRequisicao]['stateRow'] == 3
        lRet := DeleteRequisicao(;
                {;
                    oRequest[2][nRequisicao]['cGQWCODIGO'],;
                    oRequest[2][nRequisicao]['cGQWCODCLI'],;
                    oRequest[2][nRequisicao]['cGQWCODLOJ'],;
                    oRequest[2][nRequisicao]['cGQWCODAGE'];
                };
            )
    EndIf
Next nRequisicao

lRet := UpdateLote(;
    {;
        oRequest[3]['cGQYCODIGO'],;
        oRequest[3]['cGQYDESCRI'],;
        strtran(oRequest[3]['cGQYDTEMIS'],'-',''),;
        strtran(oRequest[3]['cGQYDTFECH'],'-',''),;
        cValToChar(oRequest[3]['cGQYTOTAL']),;
        cValToChar(oRequest[3]['cGQYTOTDES']);
    };
)

oResponse['ok'] := lRet

Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return lRet

/*/{Protheus.doc} UpdateRequisicao
    (long_description)
    @type  Static Function
    @author user
    @since 06/01/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function UpdateRequisicao(cCodigoLote,aDados)
Local lRet      := .T.
Local cQuery	:= ""
Local nStatus   := 0

cQuery := " UPDATE " + RetSqlName('GQW') "
cQuery += " SET GQW_CODLOT = '" + cCodigoLote + "' "
cQuery += " WHERE GQW_FILIAL = '" + xFilial('GQW') + "'"
cQuery += " AND GQW_CODIGO = '" + aDados[1] + "'" 
cQuery += " AND GQW_CODCLI = '" + aDados[2] + "'" 
cQuery += " AND GQW_CODLOJ = '" + aDados[3] + "'" 
cQuery += " AND GQW_CODAGE = '" + aDados[4] + "'" 
cQuery += " AND D_E_L_E_T_ = ' ' "

nStatus := TcSqlExec(cQuery)

If nStatus < 0 
    lRet := .F.
EndIf

cQuery := ''

Return lRet


/*/{Protheus.doc} DeleteRequisicao
    (long_description)
    @type  Static Function
    @author user
    @since 06/01/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function DeleteRequisicao(aDados)
Local lRet      := .T.
Local cQuery	:= ""
Local nStatus   := 0

cQuery := " UPDATE " + RetSqlName('GQW') "
cQuery += " SET GQW_CODLOT = ' ' "
cQuery += " WHERE GQW_FILIAL = '" + xFilial('GQW') + "'"
cQuery += " AND GQW_CODIGO = '" + aDados[1] + "'" 
cQuery += " AND GQW_CODCLI = '" + aDados[2] + "'" 
cQuery += " AND GQW_CODLOJ = '" + aDados[3] + "'" 
cQuery += " AND GQW_CODAGE = '" + aDados[4] + "'" 
cQuery += " AND D_E_L_E_T_ = ' ' "

nStatus := TcSqlExec(cQuery)

If nStatus < 0 
    lRet := .F.
EndIf

cQuery := ''

Return lRet

/*/{Protheus.doc} UpdateLote
    (long_description)
    @type  Static Function
    @author user
    @since 06/01/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function UpdateLote(aDados)
Local lRet      := .T.
Local cQuery	:= ""
Local nStatus   := 0

cQuery := " UPDATE " + RetSqlName('GQY') "
cQuery += " SET GQY_DESCRI = '" + aDados[2] + "', "
cQuery += "     GQY_DTEMIS = '" + aDados[3] + "', "
cQuery += "     GQY_DTFECH = '" + aDados[4] + "', "
cQuery += "     GQY_TOTAL = '"  + aDados[5] + "', "
cQuery += "     GQY_TOTDES = '" + aDados[6] + "' "
cQuery += " WHERE GQY_FILIAL = '" + xFilial('GQY') + "'"
cQuery += " AND GQY_CODIGO = '" + aDados[1] + "'" 
cQuery += " AND D_E_L_E_T_ = ' ' "

nStatus := TcSqlExec(cQuery)

If nStatus < 0 
    lRet := .F.
EndIf

cQuery := ''

Return lRet
