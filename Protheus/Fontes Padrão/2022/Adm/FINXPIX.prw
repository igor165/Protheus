#Include "Protheus.ch"
#Include "Totvs.ch"
#Include 'FWMVCDef.ch'
#Include "FINXPIX.ch"

Static __oStatus  := Nil
Static __lTemF71  := Nil
Static __lFINA890 := Nil
Static __lFKFPIX  := Nil
Static __oRecEnv  := Nil
Static __oObjImpo := Nil
Static __nTituPai := Nil
Static __nCasaDec := Nil
Static __lPccBaix := Nil
Static __oSeqMax  := NIl
Static __lCnabImp := Nil
Static __nCasasDc := Nil

/*/{Protheus.doc} FINXPIX
Funcoes genericas da funcionalidade PIX dentro do Financeiro
@version 12.1.27
/*/

/*/{Protheus.doc} TitTemPIX
    Verifica se titulo CR esta configurado como PIX

    @return: lRecPix, Logical, True =  Indica que o título será pago/recebido via pix,
    False = Indica que o título terá outra forma de pagamento

    @author Pedro Castro
    @since 26/10/2020
    @version 1.0
/*/
Function TitTemPIX() As Logical
    Local cChave  As Character
    Local cIdDoc  As Character
    Local lRecPix As Logical
    Local aFKF 	  As Array
    Local aArea   As Array
    
    //Inicializa variáveis.
    cChave  := ""
    cIdDoc  := ""
    lRecPix := .F.
    aFKF    := {}
    aArea   := {}
    
    If cPaisLoc == "BRA" .And. FKF->(FieldPos("FKF_RECPIX")) > 0
        aArea := GetArea()
        aFKF := FKF->(GetArea())
        FKF->(DbSetorder(1))            
        
        cChave := SE1->E1_FILIAL+"|"+SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA
        cIdDoc := FinBuscaFK7(cChave, "SE1", SE1->E1_FILORIG)
        
        If !Empty(cIdDoc)
            lRecPix := (FKF->(DbSeek(xFilial("FKF", SE1->E1_FILORIG)+cIdDoc)) .And. FKF->FKF_RECPIX == "1")
        EndIf        
        
        RestArea(aFKF)
        RestArea(aArea)
        FwFreeArray(aFKF)
        FwFreeArray(aArea)
    EndIf
Return lRecPix

/*/{Protheus.doc} PIXCancel
    Solicita a retirada de um titulo do PIX

    @type logical
    @param cBranch - Filial do titulo
    @param cID - ID do titulo na FK7 ou TransactionID (IDcnab do PIX)
    @param lCNAB - Se a baixa esta sendo feita via retorno do CNAB
    @return lRet - .T. se nao houve erro na operacao, .F. se houve erro
    @version 12.1.27
    @since   21/10/2020
    @author Igor Nascimento
/*/
Function PIXCancel(cBranch As Character, cID As Character) As Logical
    Local lRet      As Logical
    Local lSolCan   As Logical    
    Local aArea     As Array
    Local oModelAnt As Object
    Local oModel    As Object

    Default cBranch := FWxFilial("FKF")
    Default cID     := ""

    //Inicializa variáveis.    
    lRet  := .T.
    lSolCan := .F.
    aArea   := GetArea()

    DbSelectArea("FKF")    

    __lFKFPIX  := IIf(__lFKFPIX == Nil, FKF->(ColumnPos("FKF_RECPIX")) > 0, __lFKFPIX)    
    __lFINA890 := IIf(__lFINA890 == Nil, FindFunction("FINA890"), __lFINA890)
    __lTemF71  := IIf(__lTemF71 == Nil, AliasInDic("F71"), __lTemF71) 
    
    If __lFKFPIX
        FKF->(DbSetOrder(1))
        
        If FKF->(DbSeek(cBranch+cID)) .And. FKF->FKF_RECPIX == "1"
            oModelAnt := FWModelActive()
            
            If oModelAnt <> Nil .And. !oModelAnt:IsActive()
                oModelAnt := Nil
            EndIf
            
            oModel := FWLoadModel("FINA986")
            oModel:SetOperation(MODEL_OPERATION_UPDATE)
            oModel:Activate()
            oModel:SetValue("FKFMASTER","FKF_RECPIX","2")
            
            If oModel:VldData()
                oModel:CommitData()
            Else
                VarInfo("", oModel:GetErrorMessage())
                lRet := .F.
            EndIf
            
            oModel:DeActivate()
            oModel:Destroy()
            oModel:= Nil
            
            If __lTemF71 .And. __lFINA890 .And. lRet 
                DbSelectArea("F71")
                F71->(dbSetOrder(1))
                
                If F71->(DbSeek(cBranch + cID))
                    While F71->(F71_FILIAL + F71_IDDOC) == cBranch + cID
                        
                        If ((F71->F71_SOLCAN == "1") .Or. (F71->F71_STATUS $ "5|6|7|8"))
                            F71->(DbSkip())
                            Loop
                        EndIf
                        
                        lSolCan := .T.
                        Exit
                    EndDo
                    
                    If lSolCan
                        RecLock("F71")
                        F71->F71_SOLCAN := "1"
                        F71->F71_STATUS := IIf(F71->F71_STATUS == "1", "7", F71->F71_STATUS)
                        F71->(MsUnlock())
                    EndIf
                EndIf
                
                If oModelAnt <> Nil 
                    oModelAnt:Activate()
                EndIf
            EndIf
        EndIf
    EndIf

    RestArea(aArea)
Return lRet

/*{Protheus.doc} FinQRCode
    Retorna informaçoes do qr code Pix passado
    @params: Considera titulo posicionado
    @return: T ou F e dados do
    @author Nagy

    @since 25/10/2020
    @version 1.0
*/
Function FinQRCode(cString As Character, lMsg As Logical, lRet As Logical)

    Local cGui      As Character 
    Local cURL      As Character 
    Local cChavePix As Character 
    Local c27Gui    As Character
    Local c27id     As Character
    Local cCateg    As Character
    Local cMoeda    As Character
    Local cPais     As Character
    Local cBenef    As Character
    Local cCidade   As Character
    Local cCEP      As Character
    Local cCRC      As Character
    Local cTipo     As Character

    Local nTamanho  As Numeric
    Local nPosicao  As Numeric
    Local nValor    As Numeric
    Local nCount    As Numeric

    Default cString := ''
    Default lMsg    := .F.
    Default lRet    := .F.

    cGui      := ''
    cURL      := ''
    cChavePix := ''
    c27Gui    := ''
    c27id     := ''
    cCateg    := ''
    cMoeda    := ''
    nValor    := 0
    cPais     := ''
    cBenef    := ''
    cCidade   := ''
    cCEP      := ''
    cCRC      := ''
    nPosicao  := 1
    nTamanho  := 0
    nCount    := 0

    If Substr(cString,1,6) == '000201'

        While len(cString) > nPosicao
            cTipo := Substring(cString,nPosicao,2)
            nCount++
            Do Case 
                Case cTipo == "00"  // Payload Format Indicator
                    nPosicao += 2
                    nTamanho := Val(Substring(cString,nPosicao,2))
                    nPosicao += 2
                    nPosicao += nTamanho
                Case cTipo == "01"  // Point of Initiation Method
                    nPosicao += 2
                    nTamanho := Val(Substring(cString,nPosicao,2))
                    nPosicao += 2
                    nPosicao += nTamanho
                Case cTipo == "04"  // Merchant Account Information - Cartoes
                    nPosicao += 2
                    nTamanho := Val(Substring(cString,nPosicao,2))
                    nPosicao += 2
                    nPosicao += nTamanho
                Case cTipo == "26"  // Merchant Account Information
                    nPosicao += 2   // desconsidera o tamanho do ID
                    nPosicao += 2   // desconsidera o tamanho do grupo (melhorar para controlar o arranjo)

                    If Substring(cString,nPosicao,2) == '00'    // GUI
                        nPosicao    += 2
                        nTamanho    := Val(Substring(cString,nPosicao,2))
                        nPosicao    += 2
                        cGUI        := Substring(cString,nPosicao,nTamanho)
                        nPosicao    += nTamanho
                    Endif

                    If Substring(cString,nPosicao,2) == '01'    // Chave PIX
                        nPosicao    += 2
                        nTamanho    := Val(Substring(cString,nPosicao,2))
                        nPosicao    += 2
                        cChavePIX   := Substring(cString,nPosicao,nTamanho)
                        nPosicao    += nTamanho
                    Endif

                    If Substring(cString,nPosicao,2) == '25'    // URL
                        nPosicao    += 2
                        nTamanho    := Val(Substring(cString,nPosicao,2))
                        nPosicao    += 2
                        cUrl        := Substring(cString,nPosicao,nTamanho)
                        nPosicao    += nTamanho
                    Endif 

                Case cTipo == "27"  // Merchant Account Information - Outro
                    nPosicao += 2   // desconsidera o tamanho do ID
                    nPosicao += 2   // desconsidera o tamanho do grupo (melhorar para controlar o arranjo)

                    If Substring(cString,nPosicao,2) == '00'    // GUI
                        nPosicao    += 2
                        nTamanho    := Val(Substring(cString,nPosicao,2))
                        nPosicao    += 2
                        c27GUI      := Substring(cString,nPosicao,nTamanho)
                        nPosicao    += nTamanho

                    Endif

                    If Substring(cString,nPosicao,2) == '01'    // IdConta
                        nPosicao    += 2
                        nTamanho    := Val(Substring(cString,nPosicao,2))
                        nPosicao    += 2
                        c27Id       := Substring(cString,nPosicao,nTamanho)
                        nPosicao    += nTamanho
                    Endif 
                Case cTipo == "52"  // Merchant Category Code
                    nPosicao    += 2
                    nTamanho    := Val(Substring(cString,nPosicao,2))
                    nPosicao    += 2
                    cCateg      := Substring(cString,nPosicao,nTamanho)
                    nPosicao    += nTamanho
                Case cTipo == "53"  // Transaction Currency
                    nPosicao    += 2
                    nTamanho    := Val(Substring(cString,nPosicao,2))
                    nPosicao    += 2
                    cMoeda      := Substring(cString,nPosicao,nTamanho)
                    nPosicao    += nTamanho
                Case cTipo == "54"  // Transaction Amount
                    nPosicao    += 2
                    nTamanho    := Val(Substring(cString,nPosicao,2))
                    nPosicao    += 2
                    nValor      := Val(Substring(cString,nPosicao,nTamanho))
                    nPosicao    += nTamanho
                Case cTipo == "58"  // Country Code
                    nPosicao    += 2
                    nTamanho    := Val(Substring(cString,nPosicao,2))
                    nPosicao    += 2
                    cPais       := Substring(cString,nPosicao,nTamanho)
                    nPosicao    += nTamanho
                Case cTipo == "59"  // Merchant Name
                    nPosicao    += 2
                    nTamanho    := Val(Substring(cString,nPosicao,2))
                    nPosicao    += 2
                    cBenef      := Substring(cString,nPosicao,nTamanho)
                    nPosicao    += nTamanho
                Case cTipo == "60"  // Merchant City
                    nPosicao    += 2
                    nTamanho    := Val(Substring(cString,nPosicao,2))
                    nPosicao    += 2
                    cCidade     := Substring(cString,nPosicao,nTamanho)
                    nPosicao    += nTamanho
                Case cTipo == "61"  // Postal Code
                    nPosicao    += 2
                    nTamanho    := Val(Substring(cString,nPosicao,2))
                    nPosicao    += 2
                    cCEP        := Substring(cString,nPosicao,nTamanho)
                    nPosicao    += nTamanho
                Case cTipo == "62"  // Addition Data Field Template - Desconsidera
                    nPosicao    += 2
                    nTamanho    := Val(Substring(cString,nPosicao,2))
                    nPosicao    += 2
                    nPosicao    += nTamanho
                Case cTipo == "63"  // CRC
                    nPosicao    += 2
                    nTamanho    := Val(Substring(cString,nPosicao,2))
                    nPosicao    += 2
                    cCRC        := Substring(cString,nPosicao,nTamanho)
                    nPosicao    += nTamanho
                Case cTipo $ "02|03|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|55|56|57|64|65|66|67|68|69|70|71|72|73|74|75|76|77|78|79|80|81|82|83|84|85|86|87|88|89|90|91|92|93|94|95|96|97|98|99"	// unreseved templates - Desconsidera
                    nPosicao    += 2
                    nTamanho    := Val(Substring(cString,nPosicao,2))
                    nPosicao    += 2
                    nPosicao    += nTamanho
            EndCase
            If nCount > 1000
                Exit
            EndIf
        Enddo

        If lMsg

            cMsg := STR0001 + Chr(13)+Chr(10)+Chr(13)+Chr(10) // "Informações Identificadas no QR Code"
            cMsg += Iif(cBenef  <> '', STR0002 + cBenef + Chr(13)+Chr(10),"") // "Beneficiario : "
            cMsg += Iif(nValor  <> 0 , STR0003 + Str(nValor) + Chr(13)+Chr(10),"") // "Valor : "
            cMsg += Iif(cMoeda  <> '', STR0004 + iif(cMoeda=="986","R$",cMoeda) + Chr(13)+Chr(10),"") // "Moeda : " 
            cMsg += Iif(cCep    <> '', STR0005 + cCep    + Chr(13)+Chr(10),"")  // "CEP : "
            cMsg += Iif(cCidade <> '', STR0006 + cCidade + Chr(13)+Chr(10),"") // "Cidade : "
            cMsg += Iif(cPais   <>'' , STR0007 + cPais + Chr(13)+Chr(10),"") // "Pais : "

            MsgInfo(cMsg)

        Endif
    EndIf

Return(Iif(lRet,{cGui,cUrl,cChavePix},.T.))

/*/{Protheus.doc}FinRecPix
    Valida gravação dos campos que definem se os 
    novos títulos a receber terão a forma de pagamento 
    pix e o email que receberá o pix.

    @Param oModel, Object, modelo de dados do cadastro de cliente
    @Param lCMRA980, Logical, .T. = indica que o modelo é do cadastro mvc do crm
    @return lRret, Logical, indica que os campos foram preenchidos corretamente.

    @author Sivaldo Oliveira
    @since  30/10/2020
    @version 12
/*/
Function FinRecPix (oModel As Object, lCMRA980 As Logical) As Logical
	Local lRet      As Logical
	Local cRecPix   As Char
	Local cMailPix  As Char
	Local cMsgAlert As Char
	Local cModelo   As Char
	
    //Inicializa variáveis.
	lRet      := .T.
	cRecPix   := ""
	cMailPix  := ""
	cMsgAlert := ""
	cModelo   := ""
    
    If AI0->(FieldPos('AI0_RECPIX')) > 0
        Default oModel   := Nil
        Default lCMRA980 := .F.
        
        If oModel != Nil .And. (cModelo := AllTrim(oModel:CID)) == "MATA030A"
            cModelo := AllTrim(oModel:GetModel("AI0MASTER"):CID)
        EndIf
        
        If cModelo $ "AI0CHILD|AI0MASTER"
            If cModelo == "AI0CHILD"
                lCMRA980 := .T.
                cRecPix  := oModel:GetValue("AI0_RECPIX")
                cMailPix := AllTrim(oModel:GetValue("AI0_EMAPIX"))
            Else
                cRecPix  := oModel:GetModel(cModelo):GetValue("AI0_RECPIX")
                cMailPix := AllTrim(oModel:GetModel(cModelo):GetValue("AI0_EMAPIX"))
            EndIf	
            
            If !Empty(cMailPix) .And. !IsEmail(Alltrim(cMailPix))
                cMsgAlert := STR0009
                lRet := .F.
            ElseIf Empty(cMailPix) .And. cRecPix == "2" 
                cMsgAlert := STR0008
                lRet := .F.
            EndIf
            
            If !lRet
                If lCMRA980
                    Help(" ", 1, "EMAILPIX", Nil, cMsgAlert, 2, 0,,,,,, {STR0010})
                Else
                    oModel:SetErrorMessage("AI0MASTER", Nil, "AI0MASTER", Nil, Nil, cMsgAlert, STR0010, Nil,Nil)
                EndIf
            EndIf
        Endif
    EndIf
Return lRet

/*/{Protheus.doc} PixStatus
    Status atual do titulo no monitor PIX

    @param cBranch, Char, Filial do titulo
    @param cID, Char, Identificador do titulo na FK7  
    @param lDelSt, Logical, Indica se o objeto statement sera deletado
    @return cStatus, Char, Retorna o status atual do registro no monitor pix

    @version 12.1.27
    @since   17/11/2020
    @author Ana Nascimento
/*/
Function PixStatus(cBranch As Char, cID As Char, lDelSt As Logical) As Char    
    Local cQuery  As Char
    Local cStatus As Char
    Local cSeq    As Char
    Local nTamSeq   As Numeric
    Local aArea   As Array
    
    //Inicializa variáveis.    
    cQuery  := "" 
    cStatus := ""
    cSeq    := ""  
    nTamSeq := 0
    aArea   := {}

    //Valores default dos parâmetros
    Default cBranch := FWxFilial("F71")
    Default cID     := ""
    Default lDelSt  := .F.
    
    If !Empty(cID)
        nTamSeq := TamSX3("F71_SEQ")[1]
        
        If __oStatus == NIL 
            cQuery := "SELECT MAX(F71_SEQ) MAXSEQ "
            cQuery += "FROM " + RetSqlName("F71") + " F71 "
            cQuery += "WHERE F71.F71_FILIAL= ? AND "
            cQuery += "F71.F71_IDDOC= ? AND "
            cQuery += "F71.D_E_L_E_T_ = ' ' "
            
            cQuery    := ChangeQuery(cQuery)
            __oStatus := FWPreparedStatement():New(cQuery)
        EndIf
       
        __oStatus:SetString(1, cBranch)
        __oStatus:SetString(2, cID)
        cQuery := __oStatus:GetFixQuery()
        cSeq := Left(MpSysExecScalar(cQuery, "MAXSEQ"), nTamSeq)    
        
        If !Empty(cSeq)
            aArea := GetArea()
            dbSelectArea("F71")
            F71->(dbSetOrder(1))    // Filial+IdDoc+Seq
            
            If F71->(DbSeek(cBranch+cID+cSeq))
                cStatus := F71->F71_STATUS
            EndIf
            
            RestArea(aArea)
            FwFreeArray(aArea)
        EndIf
        
        If lDelSt
            __oStatus:Destroy()
            __oStatus:= Nil
        EndIf
    EndIf
Return cStatus

/*/{Protheus.doc} PixDelStmt
    Destroi o objeto criado na PixStatus

    @version 12.1.27
    @since   17/11/2020
    @author Ana Nascimento
/*/
Function PixDelStmt()
    If __oStatus != NIL
        __oStatus:Destroy()
        __oStatus := NIL
    Endif
Return

/*/{Protheus.doc} PIXIsActiv()
    Função retorna se o PIX do título posicionado está ATIVO.
    Necessário que o SE1 esteja posicionado.

    @version    12.1.23/12.1.25/12.1.27
    @author     Edson Melo
    @return     lRet, Logical, .T. PIX ativo, .F. PIX cancelado
    @since      13/11/2020
/*/
Function PIXIsActiv() As Logical
    Local cChave  As Char
    Local cIdDoc  As Char
    Local cStatus As Char
    Local lRet    As Logical
	
	//Inicializa variáveis.
    cChave  := ""
    cIdDoc  := ""
    cStatus := ""
    lRet    := .F.
	
	If cPaisLoc == "BRA"
		If AliasInDic("F71") .And. TitTemPIX() 
            cChave  := SE1->E1_FILIAL + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + ;
                    SE1->E1_TIPO   + "|" +  SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
            cIdDoc  := FinBuscaFK7(cChave, "SE1", SE1->E1_FILORIG)
            cStatus := PixStatus(SE1->E1_FILIAL, cIdDoc, .F.)
            lRet    := cStatus $ '2|3|4|5|6'
        Endif
	EndIf
Return lRet

/*/{Protheus.doc}FinCnabPix
    Faz a leitura do layout do arquivo de configurção
    modelo pix.

    @Param nHdlConf, Numeric, handle/numero do arquivo aberto
    @Param nTamArq, Numeric, Tamanho do arquivo de configuraçao
    @return aPosicoes, Array, matriz com as posições do arquivo de 
    de configuração

    @author Sivaldo Oliveira
    @since  13/09/2021
    @version 12
/*/
Function FinCnabPix(nHdlConf As Numeric, nTamArq As Numeric) As Array
    Local lRet        As Logical
    Local lConteudo   As Logical
    Local cIdPasta    As Char
    Local cIdHeader   As Char
    Local cIdDetalhes As Char
    Local cIdQrCodPix As Char
    Local cBuffer     As Char
    Local cPosicao    As Char
    Local nQtdLidos   As Numeric
    Local nTamanho    As Numeric
    Local nPosIni     As Numeric
    Local nPosFim     As Numeric
    Local aPosicoes   As Array
    
    Default nTamArq  := 0
    Default nHdlConf := 0
    
    //Inicializa variáveis
    nQtdLidos := 0
    aPosicoes := {{},{}}
    
    If (lRet := (nHdlConf >= 0 .And. nTamArq > nQtdLidos))
        lConteudo   := .F.
        cIdPasta    := ""
        cIdHeader   := CHR(1)
        cIdDetalhes := CHR(2)
        cIdQrCodPix := CHR(5)
        cBuffer     := ""
        cPosicao    := ""
        nQtdLidos   := 0
        nTamanho    := 0
        nPosIni     := 0
        nPosFim     := 0
    EndIf
    
    While lRet .And. nQtdLidos <= nTamArq
        cBuffer := Space(85)
        FREAD(nHdlConf, @cBuffer, 85)
        cIdPasta := SubStr(cBuffer, 1, 1)
        
        //header do arquivo
        If cIdPasta == cIdHeader
            nQtdLidos += 85
            Loop
        EndIf
        
        lConteudo := .F.        
        nTamanho  := 0
        nPosIni   := 0
        nPosFim   := 0
        cPosicao  := AllTrim(Substr(cBuffer, 17, 10))
        
        If (lConteudo := (!Empty(cPosicao)))
            nPosIni  := Int(Val(SubStr(cPosicao, 1, 3)))
            nPosFim  := Int(Val(SubStr(cPosicao, 4, 3))) 
            nTamanho := ((nPosFim + 1) - nPosIni)
        EndIf
        
        //Posições da Pasta detalhes
        If cIdPasta == cIdDetalhes
            Aadd(aPosicoes[1], {nPosIni, nTamanho, lConteudo})
        ElseIf cIdPasta == cIdQrCodPix //Posições da Pasta Qr Code Pix
            Aadd(aPosicoes[2], {nPosIni, nTamanho, lConteudo})
        EndIf
        
        nQtdLidos += 85
    EndDo
Return aPosicoes

/*/{Protheus.doc}BorderoImp
    Valida se o título está em borderô de impostos

    @param cFilOriTit, Char, Filial origem de inclusão do título.
    @param cBordero,   Char, Número do borderô no qual o título foi incluído.
    @param cCarteira,  Char, Carteira do título (R = Receber, P = Pagar)
    @param cPrefTit,   Char, Prefixo do título
    @param cNumTit,    Char, Número do título.
    @param cParcTit,   Char, Parcela do título.
    @Param cTipoTit,   Char, Tipo do título.
    @param cCliFor,    Char, Cliente/Fornecedor do título.
    @Param cLoja,      Char, Loja do Cliente/Fornecedor.
    @Return, lRet, Logical, Retorno que indica se o título está em borderô de 
    impostos (.T. = Está em borderô de impostos, .F. Não está borderô de impostos)

    @author Sivaldo Oliveira
    @since  23/09/2021
    @version 12
/*/
Function BorderoImp(cFilOrig As Char, cBordero As Char, cCarteira As Char, cPrefTit As Char, cNumTit As Char,;
                    cParcTit As Char, cTipoTit As Char, cCliFor As Char, cLoja As Char) As Logical
	Local lRet       As Logical
	Local lEaOrigem  As Logical
    Local cSE1E2     As Char
    Local cChaveSEA  As Char
    Local cQuery     As Char
    Local aAreaSEA   As Array
    Local aAreaAtual As Array
    
    //Parâmetros da função
    Default cFilOrig   := cFilAnt
    Default cBordero   := ""
    Default cCarteira  := "R"
    Default cPrefTit   := ""
    Default cNumTit    := ""
    Default cParcTit   := ""
    Default cTipoTit   := ""
    Default cCliFor    := ""
    Default cLoja      := ""
    
    //Inicializa variáveis.
    lRet       := .F.
    lEaOrigem  := SEA->(FieldPos("EA_ORIGEM")) > 0
    cSE1E2     := ""
    cChaveSEA  := ""    
    cQuery     := ""
    aAreaSEA   := {}
    aAreaAtual := GetArea()    
    
    If lEaOrigem .And. !Empty(cBordero) .And. !Empty(cCarteira := AllTrim(cCarteira))
        aAreaAtual := GetArea() 
        aAreaSEA   := SEA->(GetArea())
        cChaveSEA  := (cFilOrig+cBordero+cCarteira+cPrefTit+cNumTit+cParcTit+cTipoTit)
        
        If cCarteira != "R" 
            cChaveSEA += (cCliFor+cLoja)
        EndIf     
        
        SEA->(DbSetOrder(4))
        If SEA->(DbSeek(cChaveSEA))
            lRet := AllTrim(SEA->EA_ORIGEM) $ "FINA241|FINA061|FINA590|FINA590S|FINA590I"
        EndIf
        
        RestArea(aAreaSEA)
        RestArea(aAreaAtual)
        FwFreeArray(aAreaSEA)    
        FwFreeArray(aAreaAtual)
    EndIf
Return lRet

/*/{Protheus.doc} EnviadoBco
    Valida se o título foi enviado 
    ao banco pelo processo do cnab pix.
    
    @author Sivaldo Oliveira
    @since 13/04/2022
    
    @param cChaveTit, Char, Chave do título com os campos separados por |
    @param cFilOriTit, Char, Filial de inclusão do título
    @param cTabela, Char, Tabela de cadastro do título
    @return lRetorno, logical, retorna um verdadeiro ou falso,
    Verdadeiro - Título foi enviado ao banco
    Falso - Título não foi enviado ao banco
    /*/
Function EnviadoBco (cChaveTit As Char, cFilOriTit As Char, cTabela As Char) As Logical
    Local lRetorno   As Logical
    Local cIdTitulo  As Char
    Local cChaveF71  As Char
    Local aAreaAtual As Array
    Local aAreaSE1   As Array
    Local aAreaF71   As Array
    
    Default cChaveTit  := ""
    Default cFilOriTit := cFilAnt
    Default cTabela    := "SE1"
    
    //Inicializa variáveis
    lRetorno   := .F.
    cIdTitulo  := ""
    cChaveF71  := ""
    aAreaAtual := {}
    aAreaSE1   := {}
    aAreaF71   := {}
    
    If cPaisLoc == "BRA" .And. !Empty(cChaveTit) .And. FKF->(FieldPos("FKF_RECPIX")) > 0
        aAreaAtual := GetArea()
        aAreaSE1   := SE1->(GetArea())
        aAreaF71   := F71->(GetArea()) 
        
        If !Empty(cIdTitulo  := (FinBuscaFK7(cChaveTit, cTabela, cFilOriTit)))            
            DbSelectArea("F71")
            F71->(DbSetOrder(1))
            cChaveF71 := (xFilial("F71", cFilOriTit) + cIdTitulo)
            
            If F71->(DbSeek(cChaveF71))
                While !F71->(EOf()) .And. cChaveF71 == F71->(F71_FILIAL+F71_IDDOC)
                    If F71->F71_STATUS $ "5|6|7|8"
                        F71->(DbSkip())
                        Loop
                    EndIf
                    
                    If F71->F71_STATUS == "1" .And. F71->F71_SOLCAN == "2"
                        Exit
                    ElseIf (lRetorno :=  (F71->F71_SOLCAN == "2" .And. F71->F71_STATUS $ "2|3|4"))
                        Exit
                    EndIf
                    
                    F71->(DbSkip())
                EndDo
            EndIf
        EndIf
       
       RestArea(aAreaSE1)
       RestArea(aAreaF71)
       RestArea(aAreaAtual)
       FwFreeArray(aAreaSE1)
       FwFreeArray(aAreaF71)
       FwFreeArray(aAreaAtual)
    EndIf
Return lRetorno

/*/{Protheus.doc} LibTitPix
	Retira o título da situação de cobrança pix,
	para permitir a inclusão de novo registro
    do título no monitor pix (F71)
	
	@author Sivaldo Oliveira
	@since 27/04/2022
	@version P12
	
	@Param IdDocF71, Char, Identificador do 
	documento na complemento de título
    @Param nRecnoSE1, Numeric, Recno do cadastro do título
	/*/
Function LibTitPix(IdDocF71 As Char, nRecnoSE1 As Numeric)
    Local cSituaCob  As Character
    Local aAreaAtual As Array
	Local aAreaSE1   As Array
	
    Default IdDocF71  := "" 
	Default nRecnoSE1 := 0
	
    //Inicializa variáveis
	cSituaCob  := "0"
    aAreaAtual := {}
	aAreaSE1   := {}
	
    If !Empty(IdDocF71) 
		aAreaAtual := GetArea()
		aAreaSE1   := SE1->(GetArea())
		
        DbSelectArea("FKF")
		FKF->(DbSetOrder(1))
		SE1->(DbGoto(nRecnoSE1))
		
        If FKF->(DbSeek(xFilial("FKF")+IdDocF71)) 
			FKF->(RecLock("FKF"))
			FKF->FKF_RECPIX	:= "2"
			FKF->(MsUnlock())
            
            If nRecnoSE1 > 0
                If !Empty(SE1->E1_NUMBOR)
                    cSituaCob := SitCobBord(SE1->E1_FILORIG, SE1->E1_NUMBOR, "R", SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
                EndIf
                
                RecLock("SE1")
                SE1->E1_SITUACA := cSituaCob
                SE1->(MsUnlock())               
            EndIf
        Endif
        
        RestArea(aAreaSE1)                   
        RestArea(aAreaAtual)
		FwFreeArray(aAreaSE1)
        FwFreeArray(aAreaAtual)
	EndIf
Return Nil

/*/{Protheus.doc} BaseImpPix
	Refaz a base de cálculo/retenção do(s) 
    imposto(s) do título.
	
    @author Sivaldo Oliveira
	@since 13/05/2022
	@version P12
    
    @Param nRecnoSE1, Numeric, Recno do cadastro do título
    @Param nVASoma, Numeric, somatório dos valores acessórios de juros/multa
    @Param nVASubtra, Numeric, somatório dos valores acessórios de desconto
    @Param nAbatiment, Numeric, somatório dos valores de abatimentos do título
    @Param nTxMoeda, Numeric, Taxa da moeda para conversão.
    @Return nBaseImpos, Numeric, Base de cálculo dos impostos 
	/*/
Function BaseImpPix(nRecnoSE1 As Numeric, nVASoma As Numeric, nVASubtra As Numeric, nAbatImpos As Numeric, nTxMoeda As Numeric, nOutrosAba As Numeric) As Numeric
	Local lJurMulDes As Logical
	Local lBQ10925   As Logical
	Local lConsiACDC As Logical
	Local lConsiVA 	 As Logical
	Local lConsiImp  As Logical
    Local cMVFINPIX4 As Character    
    Local cTblTmp    As Character
    Local nBaseImpos As Numeric
    Local nAcrescimo As Numeric
    Local nDecrescim As Numeric
    Local nCasasDec  As Numeric
    Local nVlrBaixa  As Numeric
    Local nVlrTotBx  As Numeric
    Local nTotImpos  As Numeric
    Local nMoedaBx   As Numeric
    Local aAreaSE1   As Array
    Local aReaAtual  As Array   
    Local aAbatimen  As Array
    
    Default nRecnoSE1  := 0 
    Default nVASoma    := 0 
    Default nVASubtra  := 0 
    Default nAbatImpos := 0 
    Default nTxMoeda   := 0
    Default nOutrosAba := 0
    
    //Inicializa variáveis.
    nBaseImpos := 0    
    
    If nRecnoSE1 > 0
        aReaAtual  := GetArea()
        aAreaSE1   := SE1->(GetArea())
        SE1->(DbGoto(nRecnoSE1))
        
        cMVFINPIX4 := SuperGetMV("MV_FINPIX4", .F., 'SSS')
        cTblTmp    := ""
        lJurMulDes := SuperGetMV("MV_IMPBAIX", .F., .F.) == "1"
        lBQ10925   := SuperGetMV("MV_BQ10925", .F., "2") == "1"
        lConsiACDC := Substr(cMVFINPIX4, 1, 1) == "S"
        lConsiVA   := Substr(cMVFINPIX4, 2, 1) == "S"
        lConsiImp  := Substr(cMVFINPIX4, 3, 1) == "S"
        nBaseImpos := 0
        nAcrescimo := 0
        nDecrescim := 0
        nCasasDec  := TamSx3("FK1_TXMOED")[2]
        nVlrBaixa  := 0
        nVlrTotBx  := 0
        nTotImpos  := 0
        nMoedaBx   := 0
        aAbatimen  := {}
        
        TotalValAC("R", nRecnoSE1, @nVASoma, @nVASubtra)
        
        nBaseImpos := IIf(SE1->E1_MOEDA == 1, SE1->E1_SALDO, xMoeda(SE1->E1_SALDO, SE1->E1_MOEDA, 1, dDataBase, nCasasDec, nTxMoeda, 0))
        nVASubtra  := IIf(SE1->E1_MOEDA == 1, nVASubtra, xMoeda(nVASubtra, SE1->E1_MOEDA, 1, dDataBase, nCasasDec, nTxMoeda, 0))
        nVASoma    := IIf(SE1->E1_MOEDA == 1, nVASoma, xMoeda(nVASoma, SE1->E1_MOEDA, 1, dDataBase, nCasasDec, nTxMoeda, 0))
        nAcrescimo := SE1->(E1_SDACRES+E1_SDDECRE) 
        
        If nAcrescimo > 0
            nAcrescimo := IIf(SE1->E1_MOEDA == 1, nAcrescimo, xMoeda(nAcrescimo, SE1->E1_MOEDA, 1, dDataBase, nCasasDec, nTxMoeda, 0))
            
            If SE1->E1_SDDECRE > 0
                nDecrescim := nAcrescimo
                nAcrescimo := 0 
            EndIf 
        EndIf
        
        If Len(aAbatimen := AbatimentR(nRecnoSE1, nTxMoeda, 1, Nil, Nil, "|")) >= 2
            nAbatImpos := aAbatimen[1,1] 
            nOutrosAba := aAbatimen[2,1]
        EndIf
        
        FwFreeArray(aAbatimen)
        
        //Impostos retidos em baixas anteriores.
        If lBQ10925 .And. (SE1->E1_SALDO != SE1->E1_VALOR .Or. !Empty(SE1->E1_BAIXA))
            nBaseImpos += ImpostosBx(SE1->E1_FILORIG, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
        EndIf
        
        If lJurMulDes
            nBaseImpos := ((nBaseImpos+Round(nVASoma,2)+nAcrescimo) - (Abs(Round(nVASubtra,2))+nOutrosAba+nDecrescim))
        EndIf
        
        RestArea(aAreaSE1)
        RestArea(aReaAtual)
        FwFreeArray(aAreaSE1)
        FwFreeArray(aReaAtual)
    EndIf 
Return nBaseImpos

/*/{Protheus.doc} TotalValAC
	Faz o somatório individual dos valores acessórios 
    do título, separando-os pelo tipo de valor
    acessório: Soma e subtração
	
	@author Sivaldo Oliveira
	@since 13/05/2022
	@version P12
	
    @Param cCarteira, Character, Indica qual a carteira do título (P = Pagar, R = Receber).
    @Param nRecnoTit, Numeric, Recno do cadastro do título
    @Param nVASoma, Numeric, somatório de valores acessórios de juros/multa
    @Param nVASubtra, Numeric, somatório de valores acessórios de desconto 
	/*/
Function TotalValAC(cCarteira As Character, nRecnoTit As Numeric, nVASoma As Numeric, nVASubtra As Numeric)
	Local cTabela    As Character
	Local Quantidade As Numeric
	Local nContador  As Numeric	    
    Local aValores   As Array
    Local aSE1SE2    As Array
    Local aAreaAtual As Array
	
	//Parâmetros default da função
	Default cCarteira := ""
	Default nRecnoTit := 0
    Default nVASoma   := 0
	Default nVASubtra := 0
    
    //Inicializa variáveis
	cTabela    := ""
    Quantidade := 0
	nContador  := 0
	aValores   := {}
	aSE1SE2    := {}
    aAreaAtual := {}
    
    If nRecnoTit > 0 .And. (cCarteira  := AllTrim(cCarteira)) $ "R|P"
		cTabela    := IIf(cCarteira == "R", "SE1", "SE2")
		aAreaAtual := GetArea()
        aSE1SE2    := (cTabela)->(GetArea()) 
        
        (cTabela)->(DbGoto(nRecnoTit))
        
        If cCarteira == "R"
			nTotalVa := FValAcess(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_NATUREZ,; 
			.F., "", "R", dDataBase, aValores, SE1->E1_MOEDA, SE1->E1_MOEDA, 0, "", .F.)
		Else
			nTotalVa := FValAcess(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NATUREZ,;
			.F., "", "P", dDataBase, aValores, SE2->E2_MOEDA, SE2->E2_MOEDA, 0, "", .F.)
		EndIf
		
		If (Quantidade := Len(aValores)) > 0
            For nContador := 1 To Quantidade
                If aValores[nContador,3] > 0
                    nVASoma += aValores[nContador,3]
                Else
                    nVASubtra += aValores[nContador,3]
                EndIf 
            Next
            
            FwFreeArray(aValores)		
		EndIf
        
        RestArea(aSE1SE2)
        RestArea(aAreaAtual)
        FwFreeArray(aSE1SE2)
        FwFreeArray(aAreaAtual)
    EndIf
Return Nil

/*/{Protheus.doc} HistPagEnv
    Valida se o título possui histórico de pagamento/retorno
    ou remessa de cobrança por meio do pix 
    
    @author Sivaldo Oliveira
    @since 13/05/2022
    
    @param FilialOrig, Char, Filial origem de inclusão do título.
    @Param cChaveTit, Char, Chave do título separada cada campo por |
    @return lRet, Logical, Retorna verdadeiro ou falso.
    Retornará verdadeiro quando existir histórico de recebimento 
    ou envio/remessa de cobrança por meio do pix.
/*/
Static Function HistPagEnv(FilialOrig As Character, cChaveTit As Character) As Logical
    Local lRet      As Logical
    Local cQuery    As Character
    Local cIdDocF71 As Character 
    
    //Parâmetros de função
    Default FilialOrig := cFilAnt
    Default cChaveTit  := ""
    
    //Inicializa variáveis
    lRet      := .F.
    cQuery    := ""
    cIdDocF71 := ""
    
    If !Empty(cChaveTit)
        cIdDocF71 := FinBuscaFK7(cChaveTit, "SE1", FilialOrig) 
        
        If __oRecEnv == Nil
            cQuery := "SELECT COUNT(F71.F71_FILIAL) TOTALREG FROM ? F71 WHERE "
            cQuery += "F71.F71_FILIAL = ? AND F71.F71_IDDOC = ? AND F71.D_E_L_E_T_ = ' ' "
            cQuery += "AND F71.F71_STATUS IN ('2', '3', '4', '5', '8') AND F71_SOLCAN = '2'"
            cQuery := ChangeQuery(cQuery)
            __oRecEnv := FWPreparedStatement():New(cQuery)        
        EndIf
        
        __oRecEnv:SetNumeric(1, RetSqlName("F71"))
        __oRecEnv:SetString(2, xFilial("F71", FilialOrig))
        __oRecEnv:SetString(3, cIdDocF71)
        cQuery := __oRecEnv:GetFixQuery()
        lRet := (MpSysExecScalar(cQuery, "TOTALREG") > 0)
    EndIf
Return lRet

/*/{Protheus.doc} SitCobBord
    Retorna a situação de cobrança do borderô.

    @param cFilOrig,   Char, Filial origem de inclusão do título.
    @param cBordero,   Char, Número do borderô no qual o título foi incluído.
    @param cCarteira,  Char, Carteira do título (R = Receber, P = Pagar)
    @param cPrefTit,   Char, Prefixo do título
    @param cNumTit,    Char, Número do título.
    @param cParcTit,   Char, Parcela do título.
    @Param cTipoTit,   Char, Tipo do título.
    @param cCliFor,    Char, Cliente/Fornecedor do título.
    @Param cLoja,      Char, Loja do Cliente/Fornecedor.
    @Return cSituaCob, Char, Retorna a situação de cobrança do borderô.
    
    @author Sivaldo Oliveira
    @since  23/05/2022
    /*/
Function SitCobBord(cFilOrig As Char, cBordero As Char, cCarteira As Char, cPrefTit As Char, cNumTit As Char,;
                    cParcTit As Char, cTipoTit As Char, cCliFor As Char, cLoja As Char) As Char
    Local lIndice4   As Logical
    Local cSituaCob  As Char
    Local cChaveSEA  As Char
    Local nIndice    As Numeric
    Local aAreaAtual As Array
    Local aAreaSEA   As Array
    
    //Parâmetros de entrada da função.
    Default cFilOrig   := cFilAnt
    Default cBordero   := ""
    Default cCarteira  := "R"
    Default cPrefTit   := ""
    Default cNumTit    := ""
    Default cParcTit   := ""
    Default cTipoTit   := ""
    Default cCliFor    := ""
    Default cLoja      := ""
    
    //Inicializa variáveis.
    cSituaCob := "0"
    
    If !Empty(cBordero)
        lIndice4   := !Empty(SEA->(IndexKey(4)))
        nIndice    := IIf(lIndice4, 4, 1) 
        cChaveSEA  := xFilial("SEA")+cBordero+cPrefTit+cNumTit+cParcTit+cTipoTit
        aAreaAtual := GetArea()
        aAreaSEA   := SEA->(GetArea())
        
        If lIndice4
            cChaveSEA := (cFilOrig+cBordero+cCarteira+cPrefTit+cNumTit+cParcTit+cTipoTit)
        EndIf
        
        If cCarteira != "R" 
            cChaveSEA += (cCliFor+cLoja)
        EndIf     
        
        DbSelectArea("SEA")
        SEA->(DbSetOrder(nIndice))
        If SEA->(DbSeek(cChaveSEA))
            cSituaCob := SEA->EA_SITUACA
        EndIf
        
        RestArea(aAreaSEA)
        RestArea(aAreaAtual)
        FwFreeArray(aAreaSEA)
        FwFreeArray(aAreaAtual)
    EndIf
Return cSituaCob

/*/{Protheus.doc} ImpostosBx
    Retorna o somatório dos impostos da baixa que já foram retidos.
    @since 25/05/2022
    @version P12
    
    @param cFilOrig, Char, Filial origem de inclusão do título.
    @param cPrefTit, Char, Prefixo do título
    @param cNumTit,  Char, Número do título.
    @param cParcTit, Char, Parcela do título.
    @Param cTipoTit, Char, Tipo do título.
    @Return nImposto, Numeric, Total de impostos retidos no título
/*/
Static Function ImpostosBx(cFilOri As Char, cPreTit As Char, cNumTit As Char, cParTit As Char, cTipTit As Char) As Numeric
	Local cQuery   As Char
	Local cQryEst    As Char
	Local cWhere     As Char
	Local cTblSE5    As Char
	Local cTblTmp    As Char
	Local nImposto   As Numeric
    
    //Inicializa variáveis.
	cQuery     := ""
	cQryEst    := ""
	cWhere     := ""
	cTblSE5    := ""
	cTblTmp    := ""
	nImposto   := 0
    
    //Valores default dos parâmetros.
	Default cFilOri   := cFilAnt
	Default cPreTit   := ""
	Default cNumTit   := ""
	Default cParTit   := ""
	Default cTipTit   := ""
	
    If !Empty(cFilOri) .And. !Empty(cNumTit) .And. !Empty(cTipTit)
		aAreaAtual := GetArea()
        cTblSE5    := RetSqlName("SE5")
        cTblTmp    := "TblTmp"
        
        If __oObjImpo == Nil			
            cQuery := "SELECT SUM(SE5.E5_VRETPIS+SE5.E5_VRETCOF+SE5.E5_VRETCSL+E5_VRETIRF) IMPRETIDO FROM ? SE5 "
            cWhere += "WHERE SE5.E5_FILORIG = ? AND SE5.E5_PREFIXO = ? AND SE5.E5_NUMERO = ? AND SE5.E5_PARCELA = ? "
            cWhere += "AND SE5.E5_TIPO = ? AND (SE5.E5_VRETPIS > 0 OR SE5.E5_VRETCOF > 0 OR SE5.E5_VRETCSL > 0 "
            cWhere += "OR SE5.E5_VRETIRF > 0) AND SE5.E5_MOTBX NOT IN ('PCC', 'IRF', 'IMR') "            
			
            //Filtro dos estornos
			cQryEst := "SELECT SE5EST.E5_SEQ FROM ? SE5EST "
			cQryEst += StrTran(cWhere, "SE5.", "SE5EST.")
			cQryEst += "AND SE5EST.E5_TIPODOC = 'ES' AND SE5EST.D_E_L_E_T_ = ' ' "
			
            //Filtro da query de baixas
            cWhere += "AND SE5.E5_TIPODOC <> 'ES' AND SE5.D_E_L_E_T_ = ' ' "
			cQuery += cWhere + "AND SE5.E5_SEQ NOT IN (" + cQryEst + " )"
			cQuery := ChangeQuery(cQuery)
			__oObjImpo := FWPreparedStatement():New(cQuery)
		EndIf
        
        __oObjImpo:SetNumeric(1, cTblSE5)
        __oObjImpo:SetString(2, cFilOri)
		__oObjImpo:SetString(3, cPreTit)
		__oObjImpo:SetString(4, cNumTit)
		__oObjImpo:SetString(5, cParTit)
		__oObjImpo:SetString(6, cTipTit)
		
        //Parâmetros do estorno
		__oObjImpo:SetNumeric(7, cTblSE5)
        __oObjImpo:SetString(8, cFilOri)
		__oObjImpo:SetString(9, cPreTit)
		__oObjImpo:SetString(10, cNumTit)
		__oObjImpo:SetString(11, cParTit)
		__oObjImpo:SetString(12, cTipTit)
		
        cQuery   := __oObjImpo:GetFixQuery()
		nImposto := MpSysExecScalar(cQuery, "IMPRETIDO")
	EndIf 
Return nImposto

/*/{Protheus.doc} Abatimento
    Retorna uma matriz de duas linhas e uma colunas
    com o somatório dos abatimentos de impostos e os abatimentos
    que não são impostos Ex: Ab-
    
    @since 31/05/2022
    @version P12
    
    @param nRecTitPai, Numeric, Recno do cadastro do título
    @Param nTxMoeda,   Numeric, Taxa da moeda para conversão.
    @Param cListaAb,   Char,    lista dos abatimentos que não são impostos
    @Param oObjAb,     Object,  Consulta prepada para listar os abatimentos
    @Param cSeparador  Char,    Caracter separador dos abatimentos
    @Return aVetAbatim, Numeric, Matriz 2X1, com o somatório dos abatimentos, 
    impostos e não impostos.
    aVetAbatim[1,1] = Somatório dos abatimentos de impostos 
    aVetAbatim[2,1] = Somatório dos abatimentos que não são de impostos
/*/
Function AbatimentR(nRecTitPai As Numeric, nTxMoeda As Numeric, nMoedaDest As Numeric, cListaAb As Char, oObjAb As Object, cSeparador As Char) As Array
	Local lAbatImpos As Logical
    Local nVlrAb     As Numeric
	Local nLinha     As Numeric
    Local nTxIncAbat As Numeric
    Local cQry       As Char
	Local cChaTitPai As Char
    Local aVetAbatim As Array
    Local cLstAbImpo As Char
    Local aAreaAtual As Array
    Local aAreaSE1   As Array
	
    Default nRecnoSE1  := 0
	Default nTxMoeda   := 1
    Default nMoedaDest := 1
    Default cListaAb   := MVABATIM 
    Default oObjAb     := Nil
	Default cSeparador := "|"
    
    //Inicializa variáveis.
	lAbatImpos := .T.
    nVlrAb     := 0
	cQry       := ""
	aVetAbatim := {{0},{0}}
	
    If nRecTitPai > 0
        aAreaAtual := GetArea()
        aAreaSE1   := SE1->(GetArea())
        DbSelectArea("SE1")        
        SE1->(DbGoto(nRecTitPai))        
        
        __nTituPai := IIf(__nTituPai == Nil, TamSx3("E1_TITPAI")[1], __nTituPai)
        __nCasaDec := IIf(__nCasaDec == Nil, TamSX3("FK1_TXMOED")[2], __nCasaDec)
        cChaTitPai := PadR(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA), __nTituPai, "")
        cLstAbImpo := (MVPIABT+"|"+MVCFABT+"|"+MVCSABT+"|"+MVIRABT+"|"+MVINABT+"|"+MVISABT+"|"+MVFUABT+"|"+MVI2ABT)
        
        If oObjAb == Nil 
            cQry := "SELECT E1_TIPO, E1_VALOR, ISNULL(E1_TXMOEDA, 0) E1_TXMOEDA FROM ? "
            cQry += "WHERE E1_TITPAI = ? AND E1_FILORIG = ? AND E1_TIPO IN (?) "
            cQry += "AND D_E_L_E_T_ = ' ' "
            cQry := ChangeQuery(cQry)
            oObjAb := FwPreparedStatement():New(cQry)
        EndIf
		
        oObjAb:SetNumeric(1, RetSqlName("SE1"))
		oObjAb:SetString(2, cChaTitPai)
		oObjAb:SetString(3, SE1->E1_FILORIG)
		oObjAb:SetIn(4, FinSetIn(cListaAb, cSeparador))
		cQry := oObjAb:GetFixQuery()
		cTblTmp := MpSysOpenQuery(cQry)
		
		While (cTblTmp)->(!Eof())			
            nVlrAb     := (cTblTmp)->E1_VALOR
            lAbatImpos := ((cTblTmp)->E1_TIPO $ cLstAbImpo)
            nLinha     := IIf(lAbatImpos, 1, 2)
            
            If SE1->E1_MOEDA != nMoedaDest
                nTxIncAbat := IIf(lAbatImpos, nTxMoeda, (cTblTmp)->E1_TXMOEDA)
                
                If SE1->E1_MOEDA == 1
                    nVlrAb := Round(xMoeda(nVlrAb, SE1->E1_MOEDA, nMoedaDest, dDataBase, __nCasaDec, 0, nTxMoeda), 2)
                Else
                    nVlrAb := Round(xMoeda(nVlrAb, SE1->E1_MOEDA, nMoedaDest, dDataBase, __nCasaDec, nTxMoeda, Nil), 2)
                EndIf                     
            EndIf
            
            aVetAbatim[nLinha,1] += nVlrAb            
            (cTblTmp)->(DbSkip())
		EndDo
		
		(cTblTmp)->(DbCloseArea())
        RestArea(aAreaSE1)
        RestArea(aAreaAtual)
        FwFreeArray(aAreaSE1)
        FwFreeArray(aAreaAtual)
	EndIf
Return aVetAbatim

/*/{Protheus.doc} ExcluiImpo
    Função responsável por refazer o saldo do título e excluir os 
    tributos destacados na integração de envio do título para situação 
    de cobrança pix ou dos tributos destacados no borderô de impostos desde
    que o o título esteja em situação de cobrança pix e o borderô tenha sido 
    cancelado.
    
    @author Sivaldo Oliveira
    @since 06/06/2022
    @version P12
    
    @param cE1Fil,     Char, Filial do cadastro do título  (SE1)
    @param cE1Pref,    Char, Prefixo do cadastro do título (SE1) 
    @param cE1Num,     Char, Número do cadastro do título  (SE1) 
    @param cE1Parc,    Char, Parcela do cadastro do título (SE1) 
    @param cE1Tipo,    Char, Tipo do cadastro do título    (SE1) 
    @param cE1Cliente, Char, Cliente do cadastro do título (SE1) 
    @param cE1Cliente, Char, Loja do cadastro do título.   (SE1)
    @param nRecnoF71,  Char, Registro passível de cancelamento no monitor pix
    @Return lRetorno, Logical, Retorna um verdadeiro (.T.) ou falso (.F.)
    (.T.) Quando encontrar o cadastro do título (SE1), um registro ativo no 
    monitor pix (F71) e consiga processar o estornos dos impostos caso o título 
    possua impostos.
    (.F.) Caso não encontre o cadastro do título, ou não registro ativo no monitor
    pix.
/*/
Function ExcluiImpo(cE1Fil As Char, cE1Pref As Char, cE1Num As Char, cE1Parc As Char, cE1Tipo As Char, cE1Cliente As Char, cE1Loja As Char, nRecnoF71 As Numeric)
    Local lExcluiImp As Logical
    Local lF71Ativa  As Logical
    Local lRetorno   As Logical
    Local cLstSeqBx  As Char
    Local cTempSE1   As Char
    Local cChaveTit  As Char
    Local cSeeKSE1   As Char
    Local cTempFK1   As Char
    Local cChaveF71  As Char
    Local cLstAbImpo As Char
    Local nRegPaiSE1 As Numeric
    Local nTxMoeda   As Numeric
    Local nValorImp  As Numeric
    Local aAreaAtual As Array
    Local aAreaF71   As Array
    Local aAreaSE1   As Array
    
    //Valores default, parâmetros da função.
    Default cE1Fil     := cFilAnt
    Default cE1Pref    := ""
    Default cE1Num     := ""
    Default cE1Parc    := ""
    Default cE1Tipo    := ""
    Default cE1Cliente := ""
    Default cE1Loja    := ""
    Default nRecnoF71  := 0
    
    //Inicializa variáveis
    lExcluiImp := .F.
    lF71Ativa  := (nRecnoF71 > 0)
    lRetorno   := .T.
    cLstSeqBx  := ""
    cTempSE1   := ""
    cChaveTit  := ""
    cSeeKSE1   := ""
    cTempFK1   := ""
    cLstAbImpo := ""
    nRegPaiSE1 := 0
    nValorImp  := 0
    __lCnabImp := IIf(__lCnabImp == Nil, SuperGetMV("MV_CNABIMP", .F., .F.), __lCnabImp)
    __nCasasDc := IIf(__nCasasDc == Nil, TamSX3("FK1_TXMOED")[2], __nCasasDc)
    
    If !__lCnabImp .And. !Empty(cE1Num) .And. !Empty(cE1Tipo)
        aAreaAtual := GetArea()        
        aAreaSE1   := SE1->(GetArea())
        cSeeKSE1   := (cE1Fil+cE1Pref+cE1Num+cE1Parc+cE1Tipo) 
        cLstAbImpo := (MVPIABT+"|"+MVCFABT+"|"+MVCSABT+"|"+MVIRABT+"|"+MVINABT+"|"+MVISABT+"|"+MVFUABT+"|"+MVI2ABT)
        
        DbSelectArea("SE1")
        SE1->(DbSetOrder(1))
        lRetorno := SE1->(DbSeek(cSeeKSE1))
        
        If lRetorno
            If !Empty(cTempSE1 := ImposEmBx(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA), SE1->E1_FILORIG, Nil))
                aAreaF71 := F71->(GetArea())
                DbSelectArea("F71")                
                
                If !lF71Ativa
                    aAreaF71 := F71->(GetArea())
                    DbSelectArea("F71")
                    F71->(DbSetOrder(2))                
                    
                    If F71->(DbSeek(SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))
                        cChaveF71 := F71_FILIAL+F71_IDDOC                    
                        
                        While F71->(F71_FILIAL+F71_IDDOC) == cChaveF71
                            If F71->F71_STATUS $ "1|5|6|7|8"
                                F71->(DbSkip())
                                Loop
                            EndIf
                            
                            lF71Ativa := .T.
                            Exit
                        EndDo
                    EndIf
                Else
                    F71->(DbGoto(nRecnoF71))
                    lF71Ativa := F71->F71_STATUS $ "2|3|4
                EndIf
                
                lRetorno := lF71Ativa 
                RestArea(aAreaF71)
                FwFreeArray(aAreaF71)                 
                
                If lF71Ativa
                    If (lExcluiImp := !BorderoImp(SE1->E1_FILORIG, SE1->E1_NUMBOR, "R", SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA))
                        cChaveTit  := FwXFilial("SE1",SE1->E1_FILORIG)+"|"+(SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA)
                        
                        If (lExcluiImp := !HistPagPix(SE1->E1_FILORIG, cChaveTit))
                            cTempFK1 := MovGerImp(SE1->E1_FILORIG, cChaveTit, Nil)
                        EndIf
                    EndIf
                    
                    If lExcluiImp                        
                        nRegPaiSE1 := SE1->(Recno())
                        nTxMoeda   := SE1->E1_TXMOEDA
                        
                        If SE1->E1_MOEDA > 1 .And. (Empty(nTxMoeda) .Or. !Empty(SE1->E1_DTVARIA))
                            nTxMoeda := RecMoeda(IIf(Empty(SE1->E1_DTVARIA), dDataBase, SE1->E1_DTVARIA), SE1->E1_MOEDA)
                        EndIf                        

                        Begin Transaction
                            If !Empty(cTempFK1)
                                SE5->(DbSetOrder(21))
                                
                                While (cTempFK1)->(!Eof())
                                    cLstSeqBx := IIf(Empty(cLstSeqBx), (cTempFK1)->FK1_SEQ, (cLstSeqBx + "|" + (cTempFK1)->FK1_SEQ))
                                    
                                    If SE5->(DbSeek((cTempFK1)->(FK1_FILIAL+FK1_IDFK1+FK1_TPDOC)))
                                        If !(lRetorno := EstornoImp((cTempFK1)->FK1_IDFK1, (cTempFK1)->FK1_ORIGEM))
                                            DisarmTransaction()
                                            Break
                                        EndIf
                                    EndIf
                                    
                                    (cTempFK1)->(DbSkip())
                                EndDo
                                
                                (cTempFK1)->(DbCloseArea())
                            EndIf
                            
                            While (cTempSE1)->(!Eof())
                                If ((cTempSE1)->E1_TIPO $ MVABATIM .Or. Empty((cTempSE1)->E1_SEQBX)) 
                                    (cTempSE1)->(DbSkip())
                                    Loop
                                EndIf                                
                                
                                If !(cTempSE1)->E1_SEQBX $ cLstSeqBx
                                    (cTempSE1)->(DbSkip())
                                    Loop
                                EndIf
                                
                                nValorImp := (cTempSE1)->E1_VALOR 
                                
                                If SE1->E1_MOEDA > 1
                                    nValorImp := Round(xMoeda(nValorImp, 1, SE1->E1_MOEDA, CToD((cTempSE1)->E1_EMISSAO), __nCasasDc, 0, nTxMoeda), 2)    
                                EndIf 
                                
                                RecLock("SE1")
                                SE1->E1_SALDO += nValorImp
                                
                                If SE1->E1_VALOR == SE1->E1_SALDO
                                    SE1->E1_VALLIQ  := 0
                                    SE1->E1_BAIXA   := CToD("  /  /    ")
                                    SE1->E1_STATUS  := "A"
                                EndIf
                                SE1->(MsUnlock())
                                
                                SE1->(DbGoto((cTempSE1)->REGIMPSE1))
                                RecLock("SE1")
                                SE1->(DbDelete())
                                SE1->(MsUnlock())
                                SE1->(DbGoto(nRegPaiSE1))
                                
                                (cTempSE1)->(DbSkip())
                            EndDo
                            
                            (cTempSE1)->(DbCloseArea())
                        End Transaction
                    EndIf
                EndIf
            EndIf
        EndIf
        
        RestArea(aAreaSE1)
        RestArea(aAreaAtual)
        FwFreeArray(aAreaSE1)
        FwFreeArray(aAreaAtual)
    EndIf
Return lRetorno

/*/{Protheus.doc} ImposEmBx
    Quando encontrado alguma linha, retorna o nome de uma tabela 
    temporária com o conjunto de resultado filtrado. Caso não encontre 
    nenhuma linha, o retorno é vazio.
    
    @since 06/06/2022
    @version P12
    
    @param cChaTitPai, Char, Chave do título pai
    @param cFilOrig,   Char, Filial origem de inclusão do título.
    @Param oImpEmBx,   Object, Consulta prepada para listar os tributos gerados na emissão e baixa
    @Return cTempSE1,  Char, Nome da tabela temporária com o resultado da consulta de tributos 
    gerados na emissão e baixa
/*/
Static Function ImposEmBx(cChaTitPai As Char, cFilOrig As Char, oImpEmBx As Object) As Char
    Local cQuery     As Char
	Local cTempSE1   As Char
    Local aAreaAtual As Array
    
    Default cChaTitPai := ""
    Default cFilOrig   := cFilAnt
    Default oImpEmBx   := Nil
    
    //Inicializa variáveis.
	cQuery   := ""	
    cTempSE1 := ""
    
    If !Empty(cChaTitPai)
        aAreaAtual := GetArea()
        
        __nTituPai := IIf(__nTituPai == Nil, TamSx3("E1_TITPAI")[1], __nTituPai)
        cChaTitPai := PadR(cChaTitPai, __nTituPai, "")        
        
        If oImpEmBx == Nil
            cQuery := "SELECT E1_TIPO, E1_VALOR, E1_SEQBX, R_E_C_N_O_ REGIMPSE1, E1_EMISSAO FROM ? "
            cQuery += "WHERE E1_TITPAI = ? AND E1_FILORIG = ? "
            cQuery += "AND D_E_L_E_T_ = ' ' "
            cQuery := ChangeQuery(cQuery)
            oImpEmBx := FwPreparedStatement():New(cQuery)
        EndIf
		
        oImpEmBx:SetNumeric(1, RetSqlName("SE1"))
		oImpEmBx:SetString(2, cChaTitPai)
		oImpEmBx:SetString(3, cFilOrig)
		cQuery := oImpEmBx:GetFixQuery()
		cTempSE1 := MpSysOpenQuery(cQuery)
		
        If (cTempSE1)->(Eof())
            (cTempSE1)->(DbCloseArea())
            cTempSE1 := ""
        EndIf
        
        RestArea(aAreaAtual)
        FwFreeArray(aAreaAtual)
	EndIf
Return cTempSE1

/*/{Protheus.doc} HistPagPix
    Valida se o título possui histórico de pagamento/retorno
    por meio do pix. 
    
    @author Sivaldo Oliveira
    @since 06/06/2022
    
    @param FilialOrig, Char, Filial origem de inclusão do título.
    @Param cChaveTit, Char, Chave do título separada cada campo por |
    @return lRet,     Logical, Retorna verdadeiro (.T.) ou falso (.F.)
/*/
Function HistPagPix(cFilOrig As Character, cChaveTit As Character, oPagPix As Object) As Logical
    Local aArea     As Array
    Local lRet      As Logical
    Local cQuery    As Character
    Local cIdDocF71 As Character 
    
    //Parâmetros de função
    Default cFilOrig   := cFilAnt
    Default cChaveTit  := ""
    Default oPagPix    := Nil
    
    //Inicializa variáveis
    lRet      := .F.
    cQuery    := ""
    cIdDocF71 := ""
    aArea     := GetArea()
    
    If !Empty(cChaveTit)
        cIdDocF71 := FinBuscaFK7(cChaveTit, "SE1", cFilOrig) 
        
        If oPagPix == Nil
            cQuery := "SELECT COUNT(F71.F71_FILIAL) TOTALREG FROM ? F71 WHERE "
            cQuery += "F71.F71_FILIAL = ? AND F71.F71_IDDOC = ? AND F71.D_E_L_E_T_ = ' ' "
            cQuery += "AND F71.F71_STATUS IN ('5', '8') AND F71_SOLCAN = '2'"
            cQuery := ChangeQuery(cQuery)
            oPagPix := FWPreparedStatement():New(cQuery)        
        EndIf
        
        oPagPix:SetNumeric(1, RetSqlName("F71"))
        oPagPix:SetString(2, xFilial("F71", cFilOrig))
        oPagPix:SetString(3, cIdDocF71)
        cQuery := oPagPix:GetFixQuery()
        lRet := (MpSysExecScalar(cQuery, "TOTALREG") > 0)
    EndIf
    RestArea(aArea)
    FwFreeArray(aArea)
Return lRet

/*/{Protheus.doc} MovGerImp
    Retorna a última sequência de baixa que 
    destacou impostos
    
    @param cMotBxImpo, Char, Motivo de baixa do imposto.
    @Param cChaveTit,  Char, Chave do título separada cada campo por |
    @param cFilOrig,   Char, Filial origem de inclusão do título.
    @Return cSequencBx, Char, Última sequência de baixa que destacou o imposto   
/*/
Function MovGerImp(cFilOrig As Char, cChaveTit As Char, aVetMotBx As Array)
    Local cTempFK1   As Char
    Local cTblFK1    As Char
    Local cFilFK1    As Char
    Local cQuery     As Char
    Local cWhere     As Char
    Local cQryEst    As Char
    Local aAreaAtual As Array
    
    Default cFilOrig   := cFilAnt
    Default cChaveTit  := ""
    Default aVetMotBx  := {'PCC', 'IRF'}    
    
    //Inicializa variáveis
    cTempFK1   := "" 
    cTblFK1    := ""
    cFilFK1    := ""
    cQuery     := ""
    cWhere     := ""
    cQryEst    := ""
    
    If !Empty(cChaveTit) .And. Len(aVetMotBx) > 0
        If !Empty(cIdDocFK1 := FinBuscaFK7(cChaveTit, "SE1", cFilOrig))
            aAreaAtual := GetArea()
            cTblFK1    := RetSqlName("FK1") 
            cFilFK1    := xFilial("FK1", cFilOrig)
            
            If __oSeqMax == Nil			
                cQuery  := "SELECT FK1.FK1_FILIAL, FK1.FK1_IDFK1, FK1.FK1_TPDOC, FK1.FK1_SEQ, FK1_ORIGEM FROM ? FK1 "
                cWhere  := "WHERE FK1.FK1_FILIAL = ? AND FK1.FK1_IDDOC = ? AND FK1.FK1_FILORI = ? "
                cWhere  += "AND FK1.FK1_MOTBX IN (?) "
                
                //Filtro dos movimentos de estornos
                cQryEst += "SELECT FK1EST.FK1_SEQ SEQEST FROM ? FK1EST " 
                cQryEst += StrTran(cWhere, "FK1.", "FK1EST.")
                cQryEst += "AND FK1EST.FK1_TPDOC = 'ES' AND FK1EST.FK1_RECPAG = 'P' " 
                cQryEst += "AND FK1EST.D_E_L_E_T_ = ' ' "
                
                //Filtro da query de geração do imposto
                cWhere += "AND FK1.FK1_TPDOC = 'BA' AND FK1.FK1_RECPAG = 'R' " 
                cQuery += cWhere + "AND FK1.D_E_L_E_T_ = ' ' AND FK1.FK1_SEQ NOT IN (" + cQryEst + " )"
                cQuery := ChangeQuery(cQuery)
                __oSeqMax := FWPreparedStatement():New(cQuery)
            EndIf
                
            __oSeqMax:SetNumeric(1, cTblFK1)
            __oSeqMax:SetString(2, cFilFK1)
            __oSeqMax:SetString(3, cIdDocFK1)
            __oSeqMax:SetString(4, cFilOrig)
            __oSeqMax:SetIn(5, aVetMotBx)
            __oSeqMax:SetNumeric(6, cTblFK1)
            __oSeqMax:SetString(7, cFilFK1)
            __oSeqMax:SetString(8, cIdDocFK1)
            __oSeqMax:SetString(9, cFilOrig)
            __oSeqMax:SetIn(10, aVetMotBx)
            
            cQuery := __oSeqMax:GetFixQuery()
            cTempFK1 := MpSysOpenQuery(cQuery)
            
            If (cTempFK1)->(Eof())
                (cTempFK1)->(DbCloseArea())
                cTempFK1 := ""
            EndIf
            
            RestArea(aAreaAtual)
            FwFreeArray(aAreaAtual)
        EndIf
    EndIf
Return cTempFK1

/*/{Protheus.doc} EstornoImp
    Faz o estorno dos impostos calculados (FK3), retidos(FK4),
    estorna os registros de baixas dos impostos (FK1) e exclui
    os movimentos de baixas (SE5)

   
    @author Sivaldo Oliveira
    @since 06/06/2022
    @version P12
    
    @param cIdBaixFK1, Char, Identificador do movimento de baixa (FK1_IDFK1)
    @Param cOrigBxMov, Char, Rotina que gerou os impostos (FK1_ORIGEM)
    @return lRetorno, Logical, verdadeiro (.T.) ou falso (.F.).
    (.T.) Quando conseguir fazer o estornos dos impostos
    (.F.) Quando não conseguir fazer o estorno dos impostos
/*/
Static Function EstornoImp(cIdBaixFK1 As Char, cOrigBxMov As Char)
	Local lRetorno   As Logical
    Local cHistorico As Char
	Local aAreaAtual As Array
	Local oModeloMov As Object
	Local oSubModelo As Object
    Local oObjAtual  As Object

	Default cIdBaixFK1 := ""
    Default cOrigBxMov := ""
    
    //Inicializa variáveis
	lRetorno   := .T.
    cHistorico := Iif(AllTrim(cOrigBxMov) $ "FINA891|FINI892", STR0011, STR0012)
	oModeloMov := Nil
	oSubModelo := Nil
	
    If (lRetorno := !Empty(cIdBaixFK1))
        aAreaAtual := GetArea()        
        oObjAtual  := FWModelActive() 
        
        If oObjAtual != Nil .And. !oObjAtual:IsActive()
            oObjAtual := Nil
        EndIf
        
        oModeloMov := FWLoadModel("FINM010")
		oModeloMov:SetOperation(MODEL_OPERATION_UPDATE)
		oModeloMov:Activate()
		oModeloMov:SetValue("MASTER", "E5_GRV", .T.)
		oModeloMov:SetValue("MASTER", "HISTMOV", cHistorico)
		oModeloMov:SetValue("MASTER", "E5_OPERACAO", 3)
		oSubModelo := oModeloMov:GetModel("FKADETAIL")
		
        If (lRetorno := oSubModelo:SeekLine({{"FKA_IDORIG", cIdBaixFK1}}))
			If oModeloMov:VldData()
				oModeloMov:CommitData()
			Else
				lRetorno := .F.
				cLog     := cValToChar(oModeloMov:GetErrorMessage()[4]) + " - "
                cLog     += cValToChar(oModeloMov:GetErrorMessage()[5]) + " - "
				cLog     += cValToChar(oModeloMov:GetErrorMessage()[6])
				Help(Nil, Nil, "M030VALID", Nil, cLog, 1, 0)
			Endif
		Endif
		
        oModeloMov:DeActivate()
		oModeloMov:Destroy()
		oModeloMov := Nil
		oSubModelo := Nil
        RestArea(aAreaAtual)
        FwFreeArray(aAreaAtual)
        
        If oObjAtual != Nil
            oObjAtual:Activate()
        EndIf
    EndIf
Return lRetorno

/*/{Protheus.doc}MsgTtBxPix
    Caso possua algum título em PIX com impostos retidos, exibe pergunta se deseja marcar ou continuar o processo. 

    @param nRecSE1, Numerico, Recno do SE1 
    @param lMarkAll, Logico, Define se está marcando um registro ou vários.
    @param lExbCheck, Logico, Define se 
    @param lNExbMsg, Logico, Define se ira exibir

    @return lRet,Logico, indica se o titulo a receber posicionado está em PIX e tem imposto retido.    

    @author Simone Mie Sato Kakinoana
    @since  06/06/2022
    @version 12
/*/
Function MsgTtBxPix(lLoad As Logical, lMarkAll As Logical, lExbCheck As Logical, lNExbMsg As Logical)    
    Local lRet      As Logical    
    Local cMsg      As Char
    Local cTitMsg   As Char
    Local cMsgCheck As Char
    
    //Parâmetros de entrada da função.
    Default lLoad     := .F.
    Default lMarKAll  := .F.
    Default lExbCheck := .F.
    Default lNExbMsg  := .F.
    
    //Inicializa variáveis.
    cMsgCheck := STR0025 //"Caso deseje continuar com a marcação dos títulos, não exibir essa mensagem novamente? Se for na carga da tela
    cMsg      := STR0013 + CRLF  //"De acordo com os filtros informados, localizamos títulos que possuem impostos retidos por estarem no PIX. "
    cMsg      += STR0014 + CRLF  //"Caso deseje prosseguir com a marcação desses títulos, os mesmos serão "
    cMsg      += STR0015 + CRLF  //"removidos do PIX e seus impostos serão excluídos."
    cMsg      += STR0016         //"Deseja continuar ?"
    
    If !lLoad
        If lMarkAll //Se for marcação de vários titulos                
            cMsg := STR0017 + CRLF //"Existe pelo menos um título que possui impostos retidos por estar no PIX."
            cMsg += STR0018 + CRLF //"Caso deseje prosseguir com a marcação destes, eles serão removidos do PIX e seus impostos serão excluídos." 
            cMsg += STR0019         //"Deseja continuar com a seleção ?"
        Else    //Mensagem de marcação individual ou baixa manual            
            cMsg := STR0020 + CRLF  //"Esse título possui PIX gerado com impostos retidos. " 
            cMsg += STR0021 + CRLF  //"Caso selecionado, este será removido do PIX e seus impostos serão excluídos. " 
            cMsg += STR0016         //"Deseja continuar ?""
        EndIf
    EndIf    
    
    cTitMsg := STR0022            //"Cobrança PIX"  
    lRet    := YesNoCheck(cTitMsg, cMsg, lExbCheck, @lNExbMsg, cMsgCheck)
Return lRet

/*/{Protheus.doc}TtBxImpPix
    Verifica se na baixa do título, o título está em PIX e possui impostos retidos.

    @param nRecSE1, Numerico, Recno do SE1 

    @return lRet,Logico, indica se o titulo a receber posicionado está em PIX e tem imposto retido.    

    @author Simone Mie Sato Kakinoana
    @since  06/06/2022
    @version 12
/*/
Function TtBxImpPix(nRecSE1 As Numeric)
    Local lRet       As Logical
    Local cTitPai    As Char
    Local cChaveTit  As Char
    Local aAreaAtual As Array
    Local aAreaSE1   As Array    
    
    Default nRecSE1 := 0
    
    //Inicializa variáveis
    lRet      := .F.
    cTitPai   := ""
    cChaveTit := "" 
    
    If nRecSE1 > 0
        aAreaAtual := GetArea()
        aAreaSE1   := SE1->(GetArea())
        SE1->(MsGoto(nRecSE1))
        
        cTitPai   := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
        cChaveTit := xFilial("SE1", SE1->E1_FILORIG)+ "|" + SE1->(E1_PREFIXO + "|" + E1_NUM + "|" + E1_PARCELA + "|" + E1_TIPO + "|" + E1_CLIENTE + "|" + E1_LOJA)
        lRet      := ImpRetPix(SE1->E1_FILORIG, cChaveTit)
        
        RestArea(aAreaSE1)
        RestArea(aAreaAtual)
        FwFreeArray(aAreaSE1)        
        FwFreeArray(aAreaAtual)
    EndIf
Return lRet

/*/{Protheus.doc}ImpRetPix
    Verificar se o título a receber poisicionado tem imposto retido

    @param FilialOrig, Char, Filial Origem do título
    @param cTitPai, Char, Título Pai 

    @return lRet, Logico, indica se tem imposto retido para o titulo a receber posicionado

    @author Simone Mie Sato Kakinoana
    @since  06/06/2022
    @version 12
/*/
Static Function ImpRetPix(FilialOrig  As Character, cChaveTit As Character) As Logical
    Local lRet      As Logical       
    Local cTabela   As Character 
    
    //Parâmetros de entrada da função.
    Default FilialOrig  := cFilAnt
    Default cChaveTit   := ""
    
    //Inicializa variáveis    
    lRet      := .F.     
    cTabela   := ""
    
    If !Empty(cChaveTit) .And. !Empty(cTabela  := MovGerImp(FilialOrig, cChaveTit, Nil))
        (cTabela)->(DbCloseArea())
        
        If !(lRet := HistPagPix(FilialOrig, cChaveTit))
            lRet := EnviadoBco(cChaveTit, FilialOrig, "SE1")
        EndIf
    EndIf
Return lRet           

/*/{Protheus.doc} YesNOCheck
	Apresenta uma tela informando 

	@type  Function
	@author Simone Mie Sato Kakinoana
	@since 09/06/2022
	@version 1.0	
    @param cTitulo, caracter, título a ser exibido na mensagem
	@param cMsg,    caracter, descriçãopdo título a ser exibido na mensagem	
	@return lCheck, logico, Verdadeiro se foi escolhido para desabilitar a mensagem por 3O dias
/*/
Static Function YesNoCheck(cTitulo As character, cMsg As character, lExbCheck As logical, lNExbMsg As logical, cMsgCheck As character)
    Local oSay   As object
    Local oCheck As object
    Local oModal As object
    Local bYes 	 As codeblock	
    Local bNo 	 As codeblock	
    Local lRet   As Logical
    
    //Parâmetros de entrada da função
    Default cTitulo   := ""
    Default cMsg      := ""
    Default lExbCheck := .F.
    Default lNExbMsg  := .F.
    Default cMsgCheck := ""
    
    //Iniciliza variáveis
    lRet := .T.
    bYes := {||((lRet := .T., oModal:Deactivate() ))}
    bNo  := {||((lRet := .F., oModal:Deactivate() ))}
    
    oModal := FWDialogModal():New()
    oModal:SetCloseButton( .F. )
    oModal:SetEscClose( .F. )
    oModal:setTitle(cTitulo) 
    
    //define a altura e largura da janela em pixel    
    oModal:setSize(130, 250)
    oModal:createDialog()
    oModal:AddButton(STR0023, bYes, STR0023, Nil, .T., .F., .T., )    //"Sim"
    oModal:AddButton(STR0024, bNo, STR0024, Nil, .T., .F., .T., )     //"Não"

    oContainer := TPanel():New(Nil, Nil, Nil, oModal:getPanelMain())
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT
    
    oSay := TSay():New(15, 15, {||cMsg}, oContainer, Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil, 200, 50, Nil, Nil, Nil, Nil, Nil, .T.)
    
    If lExbCheck
        lNExbMsg := .F.
        oCheck   := TCheckBox():New(65, 10, cMsgCheck, {|x| IIf(Pcount() == 0, lNExbMsg, lNExbMsg := x)}, oContainer, 300, 21,,,,,,,,.T.,,,) 
    EndIf
    
    oModal:Activate()
Return lRet
