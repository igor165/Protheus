#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA901A.CH'

/*/{Protheus.doc} GTPA901A
Rotina de importação de passageiros para a litagem
@type  Function
@author user
@since 28/06/2022
@version version
@example
(examples)
@see (links_or_references)
/*/
Function GTPA901A()
    Local aArea      := GetArea()
    Local oModel     := FwModelActive()
    Local cNumero    := ""
    Local cLinha     := ""
    Local nLinhaOrc  := 0

    Private cArqOri := ""
    Private oGtpLog	:= GTPLog():New(STR0001)     //"Importação de passageiros"
     
    cNumero   := oModel:GetModel('GYDDETAIL'):GetValue('GYD_NUMERO')
    cLinha    := oModel:GetModel('GYDDETAIL'):GetValue('GYD_CODGYD')
    nLinhaOrc := oModel:GetModel('GYDDETAIL'):GetLine()

    If MsgYesNo(STR0002 + CRLF +; //"Está rotina irá efetuar o cadastramento da listagem de passageiros, caso já exista uma listagem será apagado a listagem atual para a nova."
            STR0005 + cNumero + STR0004+ cLinha + STR0003 , STR0006) //". Deseja continuar?" //", item da linha: " //"Será realizado a importação para os dados: Orçamento:" //"Importação da listagem de passageiros."
        //Mostra o Prompt para selecionar arquivos
        cArqOri := tFileDialog( "CSV files (*.csv) ", STR0007, , , .F., ) //'Seleção de Arquivos'
        
        //Se tiver o arquivo de origem
        If ! Empty(cArqOri)
            
            //Somente se existir o arquivo e for com a extensão CSV
            If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
                Processa({|| fImporta(cNumero,cLinha) }, STR0008) //"Importando..."
            EndIf
        EndIf
    Else
        MsgStop(STR0009, STR0006) //"Importação da listagem de passageiros." //"Processo abortado."
    EndIf
     
    RestArea(aArea)
Return
 
/*/{Protheus.doc} fImporta
    Função de controle para importação
    @type  Static Function
    @author user
    @since 28/06/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fImporta(cNumero,cLinha)
    Local aArea      := GetArea()
    Local nTotLinhas := 0
    Local cLinAtu    := ""
    Local nLinhaAtu  := 0
    Local aLinha     := {}
    Local oArquivo
    Local aLinhas    := {}
    Local aCabec     := {}
    Local lRet       := .T.
    Local cCabePadr  := "GQB_NOME;GQB_CPF;GQB_CEP;GQB_ENDERE;GQB_COMPLE;GQB_BAIRRO;GQB_MUNICI;GQB_ESTADO"

    Private cLog       := ""
    Private nItem := 1
    
    lRet := fIncGQ8(cNumero,cLinha)
    If lRet
        fDelGQB(GQ8->GQ8_CODIGO)
    EndIf
    oArquivo := FWFileReader():New(cArqOri)
    
    If (oArquivo:Open())

        If !(oArquivo:EoF())

            aLinhas := oArquivo:GetAllLines()
            nTotLinhas := Len(aLinhas)
            ProcRegua(nTotLinhas)
            
            oArquivo:Close()
            oArquivo := FWFileReader():New(cArqOri)
            oArquivo:Open()

            //Enquanto tiver linhas
            While (oArquivo:HasLine())

                //Incrementa na tela a mensagem
                nLinhaAtu++
                IncProc(STR0011 + cValToChar(nLinhaAtu) + STR0010 + cValToChar(nTotLinhas) + "...") //" de " //"Analisando linha "
                
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                If nLinhaAtu != 1
                    aLinha  := StrTokArr(cLinAtu, ";")
                Else
                    aCabec := StrTokArr(cLinAtu, ";")
                EndIf
                //Se não for o cabeçalho (encontrar o texto "Código" na linha atual)
                If !(cCabePadr $ UPPER(cLinAtu)) .AND. nLinhaAtu == 1
                    cLog += "- Lin" + cValToChar(nLinhaAtu) + STR0012 + CRLF //", linha não processada - cabeçalho não corresponde com os campos básicos;"
                    lRet := .F.
                EndIf 

                If LEN(aCabec) != LEN(aLinha) .AND. nLinhaAtu > 1
                    cLog += "- Lin" + cValToChar(nLinhaAtu) + STR0013 + Alltrim(cLinAtu) + "];" + CRLF //",  Não processada por não ter mesma quantidade de campos que a primeira linha do arquivo: ["
                    lRet := .F.
                EndIf
                //Se conseguir posicionar no fornecedor
                If lRet .AND. nLinhaAtu > 1
                    If LEN(aLinha) > 0 .AND. CGC(aLinha[2])

                        cLog += "+ Lin" + cValToChar(nLinhaAtu) + STR0014 + Alltrim(cLinAtu) + "];" + CRLF //", linha incluída com sucesso: ["

                        //Realiza a alteração do fornecedor
                        fIncGQB(aCabec,aLinha)
                    Else
                        cLog += "- Lin" + cValToChar(nLinhaAtu) + STR0015 + Alltrim(cLinAtu) + "];" + CRLF //", linha com CPF inválido: ["
                    EndIf
                EndIf
                
            EndDo

            //Se tiver log, mostra ele
            If ! Empty(cLog)
                cLog := STR0016 + CRLF + cLog //"Processamento finalizado, abaixo as mensagens de log: "
                oGtpLog:SetText(cLog)
            EndIf
        EndIf

        //Fecha o arquivo
        oArquivo:Close()
    EndIf
    
    If oGtpLog:HasInfo()
        oGtpLog:ShowLog()
    Endif

    RestArea(aArea)
Return

/*/{Protheus.doc} fIncGQ8
    Caso não exista GQ8 ele irá criar
    @type  Static Function
    @author user
    @since 28/06/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fIncGQ8(cNumero,cLinha)
Local lRet := .F.
Local aArea := GetArea()

    GQ8->(DbSetOrder(2))
    If GQ8->(DBSEEK(XFILIAL("GQ8")+cNumero+cLinha))
        RECLOCK("GQ8",.F.)
        GQ8->GQ8_DESCRI := STR0018 + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + "" //"Lista passageiros"
        GQ8->GQ8_OBSERV := STR0019 + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + "" //"INCLUSÃO AUTOMATICA"
        GQ8->(MsUnlock())
        lRet := .T.
    EndIf

    If !lRet
        RECLOCK("GQ8",.T.)
        GQ8->GQ8_FILIAL := XFILIAL("GQ8")
        GQ8->GQ8_CODIGO := GETSXENUM("GQ8","GQ8_CODIGO")
        GQ8->GQ8_DESCRI := STR0018 + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + "" //"Lista passageiros"
        GQ8->GQ8_OBSERV := STR0019 + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + "" //"INCLUSÃO AUTOMATICA"
        GQ8->GQ8_CODGY0 := cNumero
        GQ8->GQ8_CODGYD := cLinha
        GQ8->(MsUnlock())

        CONFIRMSX8()
        If GQ8->(DBSEEK(XFILIAL("GQ8")+cNumero+cLinha))
            lRet := .T.
        EndIf
    EndIf
RestArea(aArea)

Return lRet

/*/{Protheus.doc} fDelGQB
    Efetua a deleção da gqb quando existir
    @type  Static Function
    @author user
    @since 28/06/2022
    @version version
    @param , param_type, param_descr
    @return , return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fDelGQB(cCodigoGQ8)
Local cQuery := ""

    If !(EMPTY(cCodigoGQ8))
        cQuery := "UPDATE " + RetSqlName('GQB') "
        cQuery += " SET D_E_L_E_T_ = '*', "
        cQuery += " R_E_C_D_E_L_ = R_E_C_N_O_ "
        cQuery += " WHERE GQB_FILIAL = '" + xFilial('GQB') + "'"
        cQuery += " AND GQB_CODIGO = '" + cCodigoGQ8 + "'" 
        cQuery += " AND D_E_L_E_T_ = ' ' "

        TcSqlExec(cQuery)
    EndIf

Return 

/*/{Protheus.doc} fIncGQB
    Efetua a inclusão da GQB após a deleção caso tenha
    @type  Static Function
    @author user
    @since 28/06/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fIncGQB(aCabec,aItens)
Local lRet  := .F.
Local nX    := 0
Local nPos  := 0
Local aArea := GetArea()

    If LEN(aItens) > 0
        
        RECLOCK("GQB",.T.)
        GQB->GQB_FILIAL := XFILIAL("GQB")
        GQB->GQB_CODIGO := GQ8->GQ8_CODIGO
        GQB->GQB_ITEM   := StrZero(nItem,TamSx3("GQB_ITEM")[1])
        
        For nX := 1 to LEN(aItens)
            nPos := GQB->( FieldPos( aCabec[nX] ) )
            If nPos > 0
                GQB->( FieldPut( nPos, aItens[nX] ) )
            Else
                oGtpLog:SetText(STR0020 + aCabec[nX]) //"Campo não localizado na base "
            EndIf
        Next

        GQB->(MsUnlock())
        nItem++
    EndIf

RestArea(aArea)
Return lRet
