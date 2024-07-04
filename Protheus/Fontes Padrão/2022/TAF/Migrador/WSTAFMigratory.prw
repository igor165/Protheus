#Include "Protheus.ch"
#Include "RestFul.ch"

// __Dummy Function
Function WSTAFMigratory(); Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} Service - WSTAFMigratory
Serviço para utilização na migração de dados da base on-premise para SMART-eSocial
@author  Victor A. Barbosa
@since   03/10/2018
@version 1
/*/
//-------------------------------------------------------------------
WSRESTFUL WSTAFMigratory DESCRIPTION "Migração de Dados históricos ERP x TAF Smart eSocial"
 
WSMETHOD POST DESCRIPTION "Realiza a inserção dos registros histórico no Smart eSocial" WSSYNTAX "/WSTAFMigratory"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} Method POST - WSTAFMigratory
Faz o post do registro no Smart eSocial
@author  Victor A. Barbosa
@since   03/10/2018
@version 1
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSRECEIVE PARAMS WSSERVICE WSTAFMigratory

    Local cBody      := ""
    Local lRet       := .T.
    Local cFuncIPC   := ""
    Local cEmpTAF    := ""
    Local cFilTAF    := ""
    Local cCnpj      := ""
    Local cFuncREST  := "TafMigPost"
    Local cKeyPOST   := "migpost"
    Local cKeyReturn := "migpostreturn"
    Local cUuid      := ""
    Local cResponse  := ""
    Local aRetorno   := {}
    Local nI         := 0

    Local aVarsCfg  := ""

    If FindFunction("TAFCfgJVarsFil")

        aVarsCfg  := TAFCfgJVarsFil()

        ::SetContentType("application/json")
        cBody := ::GetContent()
        cUuid := FWUUID(AllTrim(Str(Randomize(1,999999))))

        If VarSetUID(cUuid,.T.)
        
            If Empty(cBody)

                SetRestFault(001,"Arquivo vazio. ") 
                lRet := .F.
            Else
    
                cCnpj := getValInBody(cBody,"cnpj")
                
                If filialByCnpj(cCnpj,aVarsCfg,@cFuncIPC,@cEmpTAF,@cFilTAF)
                    TAFCALLIPC(cFuncIPC,cFuncREST,cUuid,cKeyPOST,cKeyReturn,,cBody)
                EndIf 
            
                VarGetAD(cUuId,cKeyReturn,@aRetorno)

                If !Empty(aRetorno)
                    If aRetorno[1]

                        cResponse := "["
                        For nI := 1 To Len(aRetorno[2])

                            If nI > 1
                                cResponse += ","
                            EndIf 
                            cResponse += aRetorno[2][nI]
                        Next nI
                        cResponse += "]"
                        ::SetResponse(EncodeUTF8(cResponse))
                    Else

                        SetRestFault(aRetorno[3],EncodeUTF8(aRetorno[4]))
                        lRet := .F.
                    EndIf
                Else

                    SetRestFault(003,"Time-Out - Excedido o numero de tentativas de encontrar uma thread livre.") 
                EndIf
            EndIf 
        Else

            SetRestFault(004,"Não foi possível criar a seção para as variáveis hashMap.") 
        EndIf 

        aSize(aRetorno,0)
        VarCleanX(cUuId)
    Else

        SetRestFault(005,"Função TAFCfgJVarsFil não encontrada, necessário a atualização do fonte TAF_CFGJOB.")  
    EndIf 

Return(lRet)

Function TafMigPost(cUuId,cKeyPOST,cKeyReturn,aQryParam,cBody)
Return WSDataInsert(cUuId,cKeyPOST,cKeyReturn,cBody)

//-------------------------------------------------------------------
/*/{Protheus.doc} WSDataInsert
Inserção dos registros no Smart eSocial
@author  Victor A. Barbosa
@since   03/10/2018
@version 1
@return Array com objetos para composição do json de retorno
/*/
//-------------------------------------------------------------------
Static Function WSDataInsert(cUuId,cKeyPOST,cKeyReturn,cContent)

    Local oContent      := Nil
    Local lRet          := .T.
    Local nX            := 0
    Local nTotal        := 0
    Local nCodErr       := 0
    Local cMsgErr       := ""
    // Array de objetos de retorno
    Local aResponse     := {}
    Local aRetorno      := Array(4)

    If FWJsonDeserialize(cContent, @oContent)

        nTotal := Len(oContent)

        // Deixa a tabela V2A aberta
        dbSelectArea("V2A")

        For nX := 1 To nTotal
            aAdd( aResponse, WSInsertV2A(oContent[nX]))
        Next nX
    Else

        lRet := .F.
        nCodErr := 002
        cMsgErr := "Estrutura de requisição inválida"
    EndIf

	aRetorno[1] := lRet
	aRetorno[2] := aResponse
	aRetorno[3] := nCodErr
	aRetorno[4] := cMsgErr

	TAFFinishWS(cKeyPOST,cUuId,cKeyReturn,aRetorno ,3)

    aRetorno := {}
    aResponse := {}
    oContent := Nil 
    FreeObj(oContent)

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} WSInsertV2A
Gravação dos registros na tabela V2A
@author  Victor A. Barbosa
@since   03/10/2018
@version 1
@return cResponse - Json de retorno
/*/
//-------------------------------------------------------------------
Static Function WSInsertV2A(oData)

Local cXMLESoc  := oData:xmlSendESocial
Local cRecibo   := oData:receipt
Local cKeyErp   := oData:keyERP
Local cKeyESoc  := oData:keyESocial
Local cEvento   := oData:event
Local cIndRetif := oData:indRetif
Local cDtTrans  := oData:dtTrans
Local cXMLTot   := oData:xmlTotESocial
Local cRecEXC   := oData:reciboS3000
Local cCNPJ     := oData:CNPJ
Local cMessage  := ""
Local cFilDes   := ""
Local cResponse := ""
Local cFilBkp   := ""
Local lInsert   := .T.
Local lSuccess  := .T.

cFilDes := MigrFilTAF(cCNPJ)
cFilBkp := cFilAnt
cFilAnt := cFilDes

V2A->( dbSetOrder(2) )
If V2A->( dbSeek( xFilial("V2A") + cKeyESoc ) )
    lInsert     := .F.
EndIf

// --> Se for alteração, verifica se o registro já foi integrado
If !lInsert
    If V2A->V2A_STATUS == "5"
        cMessage := "Registro já processado"
        lSuccess := .F.
    EndIf
EndIf

If Empty(cFilDes)
    cMessage := "CNPJ " + cCNPJ + " não encontrado na SM0 (SIGAMAT) ou Filial não cadastrada na tabela C1E"
    lSuccess := .F.
EndIf

If lSuccess

    If RecLock("V2A", lInsert)            
        V2A->V2A_FILIAL := xFilial("V2A")
        V2A->V2A_EVENTO := cEvento

        If !Empty(cXMLESoc)
            V2A->V2A_XMLERP := Decode64(cXMLESoc)
        EndIf

        V2A->V2A_RECIBO := cRecibo
        V2A->V2A_CHVERP := cKeyErp
        V2A->V2A_CHVGOV := cKeyESoc
        V2A->V2A_STATUS := Iif( !Empty(cRecibo), "3", "1" ) 
        V2A->V2A_INDEVT := cIndRetif
        V2A->V2A_DHPROC := cDtTrans 
        V2A->V2A_RECEXC := cRecEXC
        V2A->V2A_CNPJ   := cCNPJ
        V2A->V2A_FILDES := cFilDes
        
        If !Empty(cXMLTot)
            V2A->V2A_XMLTOT := Decode64(cXMLTot)
        EndIf

        V2A->( MsUnlock() )

        cMessage := "Registro " + Iif(lInsert, "incluído", "alterado") + " com sucesso."
    Else
        cMessage := "Falha ao reservar registro para atualização, tente novamente."
        lSuccess := .F.
    EndIf
EndIf

cFilAnt := cFilBkp

cResponse := '{'
cResponse += '"keyERP" : "'     + cKeyErp  + '",'
cResponse += '"keyESocial" : "' + cKeyESoc + '",'
cResponse += '"result" : '      + IIf(lSuccess,"true","false") + ","
cResponse += '"message" : "'    + cMessage + '"'
cResponse += '}'

Return(cResponse)

//----------------------------------------------------------------------------
/*/{Protheus.doc} filialByCnpj
Realiza a validação da Filial do ERP e determina qual empresa do TAF
deve executar o processamento utilizado a Thread "startada" a mesma.

@cCNPJFil - Filial do ERP
@aVarsCfg - Variaveis de controle utilizadas no TAFCFGJOB
@cFuncIPC - Função utilizada para preparar o ambiente para a empresa TAF.(retorno por referencia)
@cEmpTAF  - Código de Empresa TAF (retorno por referencia)
@cFilTAF  - Código da Filial do TAF (retorno por referencia)


@author Evandro dos Santos O. Teixeira
@since 10/06/2020
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function filialByCnpj(cCNPJFil,aVarsCfg,cFuncIPC,cEmpTAF,cFilTAF)

    Local nPosEmpTAF
	Local cUUIDFil
	Local cChaveFil
	Local aEmpresas
	Local lValido
    Local nX

	Default cCNPJFil :=	""
	Default cFilTAF	 :=	""
    Default cEmpTAF  := ""
    Default aVarsCfg := TAFCfgJVarsFil()

    nPosEmpTAF := 0
	cUUIDFil   := aVarsCfg[3]
	cChaveFil  := aVarsCfg[4]
	aEmpresas  := {}

	lValido		 := .T.

    If VarGetA(cUUIDFil,cChaveFil, @aEmpresas)

        /*+------------------------------------------------------------+
            | Estrutura do Array de De/Para:  		 				   |
            |											               |
            | aEmpresas[n] - Array						               |
            | aEmpresas[n][1] - Empresa     			               |
            | aEmpresas[n][2] - Array					               |
            | aEmpresas[n][2][n][1] - Filial ERP  		               |
            | aEmpresas[n][2][n][2] - Filial TAF		               |
            | aEmpresas[n][2][n][3] - CNPJ Filial		               |
            +----------------------------------------------------------+*/
        For nX := 1 To Len(aEmpresas)

            nPosEmpTAF := aScan(aEmpresas[nX][2],{|emps|AllTrim(emps[3]) == AllTrim(cCNPJFil)})

            If (nPosEmpTAF > 0)
                cEmpTAF := aEmpresas[nX][1] //Tenho que pegar o Grupo de Empresas pq é o sufixo que
                //está sendo utilizando para identificar as threads.
                cFilTAF := aEmpresas[nX][2][nPosEmpTAF][2] // Filial do TAF
                cFuncIPC := aVarsCfg[1] + "_" + cEmpTAF

                nX := Len(aEmpresas) + 1 //força a saida do laço pq já achei a empresa
                lReturn := .T.
            EndIf
        Next nX

    Else
        TafConOut("Chave de Identificação de filial " + cChaveFil + " não encontrada.")
        lValido := .F.
    EndIf

	aSize(aEmpresas,0)
	aEmpresas := Nil

Return (lValido)

//----------------------------------------------------------------------------
/*/{Protheus.doc} getValInBody
Realiza a validação da Filial do ERP e determina qual empresa do TAF
deve executar o processamento utilizado a Thread "startada" a mesma.

@param - cJasonBody - Filial do ERP
@param - cTagSearch - Variaveis de controle utilizadas no TAFCFGJOB

@return - cValAtt - Valor do atributo informado em cTagSearch

@author Evandro dos Santos O. Teixeira
@since 10/06/2020
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function getValInBody(cJasonBody,cTagSearch)

    Local cValAtt := ""

	Default cJasonBody := ""
    Default cTagSearch := ""
    
    If !Empty(cTagSearch)

        nPos := At(cTagSearch,cJasonBody)
        If nPos == 0
            nPos := At(Upper(cTagSearch),cJasonBody)
        EndIf 

        cValAtt := Substr(cJasonBody,nPos-1)
        nPos := At(",",cValAtt)

        If nPos > 0
            cValAtt := Substr(cValAtt,1,nPos-1)
        Else
            nTamJson := Len(AllTrim(cJasonBody))
            cValAtt := Substr(cValAtt,1,nTamJson-2)
        EndIf

        nPos := At(":",cValAtt)
        cValAtt := Substr(cValAtt,nPos+1)
        cValAtt := StrTran(cValAtt,Chr(9),'')
        cValAtt := StrTran(cValAtt,Chr(10),'')
        cValAtt := StrTran(cValAtt,Chr(13),'')
        cValAtt := StrTran(cValAtt,'"','')
        cValAtt := AllTrim(cValAtt)
    Endif 

Return cValAtt
