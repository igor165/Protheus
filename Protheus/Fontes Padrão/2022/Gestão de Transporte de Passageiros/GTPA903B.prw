#Include "GTPA903B.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA903B
Efetivação da apuração e envio para medição do contrato CNTA121
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
Function GTPA903B()
Local cCorApura := ""
Local cMsgErro  := ''
Local lRet      := .T.

If ValidaDic(@cMsgErro)
    If GQR->GQR_STATUS != "2"
        If !IsBlind()
            If MsgYesNo(STR0001,STR0002) //'Deseja gerar a medição da apuração' //'Atenção!'
                cCorApura := GQR->GQR_CODIGO//Deixado assim para testes

                If ValidDocs(GQR->GQR_CODIGO)
                    FwMsgRun(,{|| PreparaDados(cCorApura,@lRet) },,STR0003 ) //"Gerando medição..."
                    AtualContr(cCorApura,lRet)
                Endif

            EndIf
        Else
            cCorApura := GQR->GQR_CODIGO//Deixado assim para testes
            FwMsgRun(,{|| PreparaDados(cCorApura,@lRet) },,STR0003 ) //"Gerando medição..."
            AtualContr(cCorApura,lRet)
        EndIf
    Else
        FwAlertHelp(STR0005, STR0004,) //"Atenção" //"Status deve estar em apuração para gerar a medição"
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
        GQR->GQR_STATUS := "2"
        GQR->(MsUnLock())
    Else
        RecLock("GQR",.F.)
        GQR->GQR_STATUS := "3"
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
Local cNumMed   := ""
Local aDados    := {}

Default cCorApura := ""
Default lRet      := .T.
     
    cAliasTmp := QueryOrcamento(cCorApura)
    If (cAliasTmp)->(!Eof())

        Begin Transaction
            While (cAliasTmp)->(!Eof())
                If !(EMPTY(cCodCTR)) .AND. cCodCTR != (cAliasTmp)->G9W_CONTRA
                    cNumMed := GeraMedicao(cCodCTR,aDados)
                    If !(Empty(cNumMed))
                        AtualizaContr(cNumMed,aDados)
                    Else
                        DisarmTransaction()
                        FwAlertHelp('Atenção','Erro ao gerar medição')
                        lRet := .F.
                        //Return lRet
                    Endif
                    aDados := {}
                    cNumMed := ""
                EndIf
                cCodCTR := (cAliasTmp)->G9W_CONTRA
                AADD(aDados,{(cAliasTmp)->G54_PRODNT,;//1
                        (cAliasTmp)->G54_PRECON,; //2
                        (cAliasTmp)->G54_VLRCON,; //3
                        (cAliasTmp)->G54_QTDCON,; //4
                        (cAliasTmp)->G54_PREEXT,; //5
                        (cAliasTmp)->G54_VLREXT,; //6
                        (cAliasTmp)->G54_QTDEXT,; //7
                        (cAliasTmp)->G9W_CODGQR,; //8
                        (cAliasTmp)->G9W_NUMGY0,; //9
                        (cAliasTmp)->G9W_TIPCNR,; //10
                        (cAliasTmp)->G9W_TPCMPO,; //11
                        (cAliasTmp)->G9W_DESCRI,; //12
                        (cAliasTmp)->G9W_PORCEN,; //13
                        (cAliasTmp)->G9W_VLFIXO,; //14
                        (cAliasTmp)->G54_TIPCNR,; //15
                        (cAliasTmp)->G54_TPCMPO,; //16
                        (cAliasTmp)->G54_DESCRI,; //17
                        (cAliasTmp)->G54_PORCEN,; //18
                        (cAliasTmp)->G54_VLFIXO}) //19
                (cAliasTmp)->(DbSkip())
            EndDo
            If !(EMPTY(cCodCTR)) .AND. Len(aDados) > 0
                cNumMed := GeraMedicao(cCodCTR,aDados)
                If !(Empty(cNumMed))
                    AtualizaContr(cNumMed,aDados)
                Else
                    DisarmTransaction()
                    FwAlertHelp('Atenção','Erro ao gerar medição')
                    lRet := .F.
                    //Return lRet
                Endif

                aDados := {}
                cNumMed := ""
            EndIf
        End Transaction        
    Else
        Help(,,"GTPA903BApur",, STR0007, 1,0) //"Não foram encontrados dados"
        lRet := .F.
    EndIf
    (cAliasTmp)->(DbCloseArea())
Return lRet

/*/{Protheus.doc} GeraMedicao
Função para gerar a medição com base na apuração passada
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
Static Function GeraMedicao(cCodCTR,aDados)
Local oModel    := Nil
Local cNumMed   := ""
Local nX        := 0
Local nY        := 0
Local aMsgDeErro:= {}
Local lRet      := .F. 

//Default cCorApura := ""
CN9->(DbSetOrder(1))
If CN9->(DbSeek(xFilial("CN9") + cCodCTR))//Posicionar na CN9 para realizar a inclusão
    oModel := FWLoadModel("CNTA121")
    
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    If(oModel:CanActivate())           
        oModel:Activate()
        oModel:SetValue("CNDMASTER","CND_CONTRA"    ,CN9->CN9_NUMERO)
        oModel:SetValue("CNDMASTER","CND_RCCOMP"    ,"1")//Selecionar competência
        
        For nX := 1 To oModel:GetModel("CXNDETAIL"):Length() //Marca todas as planilhas
            If Len(aDados[nX]) > 0
                oModel:GetModel("CXNDETAIL"):GoLine(nX)
                oModel:SetValue("CXNDETAIL","CXN_CHECK" , .T.)
                nY++

                oModel:GetModel('CNRDETAIL1'):GoLine(1)//<CNRDETAIL1> é o submodelo das multas da planilha(CXN)
                oModel:SetValue("CNRDETAIL1","CNR_TIPO"     , aDados[nX,15])//1=Multa/2=Bonificação
                oModel:SetValue("CNRDETAIL1","CNR_DESCRI"   , aDados[nX,17])
                oModel:SetValue("CNRDETAIL1","CNR_VALOR"    , aDados[nX,19])
                
                If !oModel:GetModel('CNEDETAIL'):IsEmpty() 
                    oModel:GetModel('CNEDETAIL'):AddLine()
                EndIf
                oModel:GetModel('CNEDETAIL'):LoadValue('CNE_ITEM', PadL(nY, CNE->(Len(CNE_ITEM)), "0"))//Adiciona um item a planilha           
                oModel:SetValue( 'CNEDETAIL' , 'CNE_PRODUT' , aDados[nX,1])
                oModel:SetValue( 'CNEDETAIL' , 'CNE_QUANT'  , aDados[nX,4])
                oModel:SetValue( 'CNEDETAIL' , 'CNE_VLUNIT' , aDados[nX,3])

                If !(EMPTY(aDados[nX,6]))//Quando tiver valor extra adicionar mais uma linha com o mesmo produto
                    nY++
                    oModel:GetModel('CNEDETAIL'):AddLine()
                    oModel:GetModel('CNEDETAIL'):LoadValue('CNE_ITEM', PadL(ny, CNE->(Len(CNE_ITEM)), "0"))//Adiciona um item a planilha           
                    oModel:SetValue( 'CNEDETAIL' , 'CNE_PRODUT' ,  aDados[nX,1])
                    oModel:SetValue( 'CNEDETAIL' , 'CNE_QUANT'  , aDados[nX,7])
                    oModel:SetValue( 'CNEDETAIL' , 'CNE_VLUNIT' ,aDados[nX,6])
                EndIf
            EndIf
        Next nX
        
        If (oModel:VldData()) /*Valida o modelo como um todo*/
            oModel:CommitData()
        EndIf
    EndIf
    

    If(oModel:HasErrorMessage())
        aMsgDeErro := oModel:GetErrorMessage()
        FwAlertHelp(aMsgDeErro[5], aMsgDeErro[6])
    Else
        cNumMed := CND->CND_NUMMED
        //Adicionar o código da medição no contrato          
        oModel:DeActivate()        
        lRet := CN121Encerr(.T.) //Realiza o encerramento da medição                   
    EndIf
EndIf  

Return cNumMed

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
Static Function AtualizaContr(cNumMed,aDados)
Local aArea := GetArea()
Local nCnt  := 0

If Len(aDados) > 0 
    DbSelectArea("G9W")
    DbSetOrder(1)
    For nCnt := 1 To Len(aDados)
        //G9W_FILIAL, G9W_CODGQR, G9W_NUMGY0, R_E_C_N_O_, D_E_L_E_T_
        If G9W->(DbSeek(xFilial("G9W") + aDados[nCnt,8] + aDados[nCnt,9]))
            RecLock("G9W",.F.)
            G9W->G9W_CODCND := cNumMed
            G9W->(MsUnLock())
        EndIf
    Next nCnt
EndIf

RestArea(aArea)
Return

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
            G9W.G9W_CONTRA
            , G9W.G9W_CODGQR
            , G9W.G9W_NUMGY0
            , G9W.G9W_REVISA
            , G9W.G9W_TIPCNR
            , G9W.G9W_TPCMPO
            , G9W.G9W_DESCRI
            , G9W.G9W_PORCEN
            , G9W.G9W_VLFIXO
            , G54.G54_PRODUT
            , G54.G54_PRODNT
            , G54.G54_QTDE
            , G54.G54_TIPCNR
            , G54.G54_TPCMPO
            , G54.G54_DESCRI
            , G54.G54_PORCEN
            , G54.G54_VLFIXO
            , G54.G54_PRECON
            , G54.G54_VLRCON
            , G54.G54_QTDCON
            , G54.G54_VLRTOT
            , G54.G54_PREEXT
            , G54.G54_VLREXT
            , G54.G54_QTDEXT
        FROM
            %Table:GQR% GQR
            INNER JOIN
                %Table:G9W% G9W
                ON
                    G9W.G9W_FILIAL     = GQR.GQR_FILIAL
                    AND G9W.G9W_CODGQR = GQR.GQR_CODIGO
                    AND G9W.%NotDel%
            INNER JOIN
                %Table:G54% G54
                ON
                    G54.G54_FILIAL     = GQR.GQR_FILIAL
                    AND G54.G54_CODGQR = G9W.G9W_CODGQR
                    AND G54.G54_NUMGY0 = G9W.G9W_NUMGY0
                    AND G54.G54_REVISA = G9W.G9W_REVISA
                    AND G54.%NotDel%
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

aFields := {'GQR_VLACRE','GQR_VLDESC','GQR_USUAPU',;
            'GQR_TOTAPU','GQR_TOTCAL','G9W_CODGQR',;
            'G9W_VLACRE','G9W_VLDESC','G9W_NUMGY0',;
            'G9W_CONTRA','G9W_DTINIA','G9W_TPCTO',;
            'G9W_TIPPLA','G9W_TABPRC','G9W_VLACRE',;
            'G9W_VLDESC','G9W_TOTAPU','G9W_TOTCAL',;
            'G9W_MOTIVO','G54_NUMGY0','G54_CODGQR',;
            'G54_PRODUT','G54_CODGI2','G54_QTDE',;
            'G54_VLRTOT','G54_VLREXT','G54_SUBTOT',;
            'G54_TOTADI','G54_CUSOPE','G54_TOTAL',;
            'G9W_TIPCNR','G9W_TPCMPO','G9W_DESCRI',;
            'G9W_PORCEN','G9W_VLFIXO','G54_TIPCNR',;
            'G54_TPCMPO','G54_DESCRI','G54_PORCEN',;
            'G54_VLFIXO','G54_PRECON','G54_PREEXT',;
            'G54_CODGYD','G54_QVCFIN','G54_QVCNFI',;
            'G54_QVEFIN','G54_QVENFI','G54_QTDCON',;
            'G54_QTDEXT','G54_VLRCON','G54_TOTCON',;
            'G54_TOTEXT','G54_REVISA','G9W_REVISA'}

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

/*/{Protheus.doc} ValidDocs(codApura)	
Valida pendência de checklist dos documentos operacionais do contrato
@author flavio.martins
@since 30/08/2022
@version 1.0
@return lógico
@type function
/*/
Static Function ValidDocs(codApura)
Local lRet 	:= .T.

Default codApura := ''

If ExistDocs(codApura)

	If FwAlertYesNo(STR0009, STR0004) // "Encontrado documentos obrigatórios para a apuração. Deseja realizar o checklist agora ? ", "Atenção"
		GTPA903D()
	Endif

	If ExistDocs(codApura)
		lRet := .F.
		FwAlertWarning(STR0010) // "A medição não poderá ser realizada até que os documentos exigidos sejam validados.", "Atenção"
	Endif

Endif

Return lRet

/*/{Protheus.doc} ExistDocs(codApura)	
Verifica se existem documentos pendentes de checklist
@author flavio.martins
@since 30/08/2022
@version 1.0
@return lógico
@type function
/*/
Static Function ExistDocs(codApura)
Local lRet 		:= .T.
Local cAliasTmp	:= GetNextAlias()

Default codApura := ''

BeginSql Alias cAliasTmp 

    SELECT COALESCE(COUNT(H69_NUMERO), 0) AS TOTREG
    FROM %Table:G9W% G9W
    INNER JOIN %Table:H69% H69 ON H69.H69_FILIAL = %xFilial:H69%
    AND H69.H69_NUMERO = G9W.G9W_NUMGY0
    AND H69.H69_REVISA = G9W.G9W_REVISA
    AND H69.H69_EXIGEN IN ('2','3')
    AND H69.H69_CHKLST = 'F'
    AND H69.%NotDel%
    WHERE G9W.G9W_FILIAL = %xFilial:G9W%
      AND G9W.G9W_CODGQR = %Exp:codApura%
      AND G9W.%NotDel%

EndSql

lRet := (cAliasTmp)->TOTREG > 0

(cAliasTmp)->(dbCloseArea())

Return lRet
