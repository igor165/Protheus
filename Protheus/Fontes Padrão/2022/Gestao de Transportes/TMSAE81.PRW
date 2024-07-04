#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAE81.CH"

Static lTME81MNT := ExistBlock('TME81MNT')

/*/{Protheus.doc} TMSAE81A()
    (Rotina para sincronizar os dados apontados pelo App Meu Checklist manualmente)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function TMSAE81A()
      Processa( { |lEnd| TMSAE81() }, , STR0001, .T. ) //-- ## Transmitindo Documentos
Return Nil

/*/{Protheus.doc} TMSAE81B()
    JOB para realizar a sincronização do Checklist x Comprovante de Entrega TMS
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function TMSAE81B(aParams,cEmp,cFil)
Default cEmp    := ""
Default cFIl    := ""
Default aParams := {}

    If Len(aParams) >= 2
        cEmp := aParams[1]
        cFil := aParams[2]
    EndIf
    RpcSetType(3)
    If RpcSetEnv(cEmp,cFil,,,"TMS","TMSAE81")
        TMSAE81()
        RpcClearEnv()
    EndIf

Return Nil

/*/{Protheus.doc} TMSAE81C()
JOB executando para todas as Filiais que tem relacionamento com Checklist no Foundation 
@author Carlos A. Gomes Jr.
@since 04/03/22
@param  aParams, Vetor com Empresa e Filial inicial do Job
        cEmp, Empresa para inicalizar o Job
        cFil, Filial para inicalizar o Job
/*/
Function TMSAE81C(aParams,cEmp,cFil)
Local lExecAtu := .F.
Local aVetFils := {}
Local nFil     := 0

Default cEmp    := ""
Default cFIl    := ""
Default aParams := {}

    If Len(aParams) >= 2
        cEmp := aParams[1]
        cFil := aParams[2]
    EndIf

    If !Empty(cEmp) .And. !Empty(cFil)
        RpcSetType(3)
        If RpcSetEnv(cEmp,cFil,,,"TMS","TMSAE81")
            DbSelectArea("DVL")
            DbGoTop()
            Do While !DVL->(Eof())
                If !Empty(DVL->DVL_FILEXT)
                    If DVL->DVL_FILALI == cFil
                        lExecAtu := .T.
                    ElseIf AScan( aVetFils, { |aFil| aFil == DVL->DVL_FILALI } ) == 0
                        AAdd( aVetFils, DVL->DVL_FILALI )
                    EndIf
                EndIf
                DVL->(DbSkip())
            EndDo

            If lExecAtu .Or. Empty(aVetFils)
                TMSAE81()
            EndIf
            RpcClearEnv()

            If !Empty(aVetFils)
                For nFil := 1 To Len(aVetFils)
                    If RpcSetEnv(cEmp,aVetFils[nFil],,,"TMS","TMSAE81")
                        TMSAE81()
                    EndIf
                    RpcClearEnv()
                Next
            EndIf

        EndIf
    EndIf

Return Nil

/*/{Protheus.doc} TMSAE81
    Integração do Checklist x Comprovante de Entrega TMS
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function TMSAE81()
Local aArea     := GetArea()
Local aAreaDTQ  := DTQ->(GetArea())
Local oJson   as Object
Local oItems  as Object
Local oResult as Object
Local nCount       := 0
Local nCount3      := 0 
Local cJson        := ""
Local cPathParam   := ""
Local cFilOrigem   := ""
Local cNumViagem   := ""
Local cFilDoc      := ""
Local cDoc         := ""
Local cSerie       := ""
Local cChvCTE      := ""
Local cChkListId   := ""
Local aDocsChk     := {}
Local aVetDLY      := {}
Local aRetEnv      := {}
Local aAnswers     := {}
Local aVetOcor     := {}
Local aImageData   := {}
Local cRecebedor   := "" //-- Nome do Recebedor da mercadoria.
Local cDocRecebe   := "" //-- RG,CPF, CNH da pessoa que recebeu a mercadoria
Local cIdImage     := "" //-- nome do arquivo de imagem
Local cFileExt     := "" //-- extensão do arquivo de imagem
Local cDocEntreg   := ""
Local cDlyStatus   := ""
Local nPesOco      := 0
Local nVolOco      := 0
Local lHasAnswer   := .F.
Local lDM0			:= AliasIndic("DM0")
Local lStaDM0      := If( lDM0, DM0->(ColumnPos("DM0_STATUS")) > 0, .F. )
Local aVetDM0      := {}
Local dDatEnt      := dDataBase
Local cHorEnt      := ""
Local lGravei      := .F.
Local lDocFis      := .T.
Local nRegDLY       := 0
Local aInfImg       := {}
Local lMaxSize      := .F.
Local lHVerao       := SuperGetMv("MV_HVERAO",,.F.)
Local aChvDnf       := {}
Local lDMH          := AliasIndic("DMH") .AND. DMH->(FieldPos("DMH_CHVNFE")) > 0
Local nLatitu       := 0
Local nLongit       := 0
Local cCDRDES       := ""
Local cIdMPOS       := ""
Local lDM0Pos       := DM0->(FieldPos("DM0_IDMPOS")) > 0
Local cVerChk       := ""

    DbSelectArea("DTQ")
    DTQ->(DbSetOrder(1)) // DTQ_FILIAL, DTQ_VIAGEM

    Begin Sequence
            
        //+--------------------------------------------------------------------------------------------
        //| 1. Preparar os dados que serão processados pela tabela DLY
        //+--------------------------------------------------------------------------------------------
        //--1.1 Listar DLY onde que o status é igual a 0-Integrado
        //-- Parametros da Função TMSChkDLY ->  cChaveCTe, cStatusDLY, dDatIni, dDatFim
        If !lStaDM0
            aLista := TMSChkDLY()
        Else
            aLista := TMSChkDM0()
        EndIf
                
        For nCount := 1 To Len(aLista)

                //+-----------------------------------------------
                //| Define valores para as variaveis principais
                //+-----------------------------------------------
                cChkListId  := AllTrim(aLista[nCount][2])
                nRegistro   := aLista[nCount][1]
                nRegDLY     := 0
                cFilOrigem  := aLista[nCount][5]
                cNumViagem  := aLista[nCount][6]
                cFilDoc     := aLista[nCount][9]
                cDoc        := aLista[nCount][10]
                cSerie      := aLista[nCount][11]
                cChvCTE     := aLista[nCount][12]
                aRetEnv     := {}
                aDocsChk    := {}
                cDocEntreg  := ""
                cRecebedor  := ""
                cDocRecebe  := ""
                
                cCDRDES     := If( Len( aLista[nCount] ) > 12, aLista[nCount][13], "" )

                lDocFis := (!Empty(cChvCTE) .And. cSerie != "COL")
                
                //+-------------------------------------------------------------------------------------------
                //-- Triagem do que pode ser processado ou não
                //-- NOTA : Futuramente será considerado o apontamento de documentos nao eletronicos e precisará
                //--        considerar documentos não eletronicos também no processamento.
                If !lStaDM0 .And. Empty(cChvCTE) //--Somente documentos eletrônicos.
                    LOOP
                EndIf
                //-- Posiciona do registro da DLY ou DM0
                If lStaDM0
                    DM0->(DbGoTo(nRegistro))
                    If lDocFis                     
                        nRegDLY := RetRecDLY( cFilOrigem, cNumViagem, cFilDoc, cDoc, cSerie, cChvCTE, cChkListId )
                    EndIf
                Else
                    DLY->(DbGoTo(nRegistro))
                EndIf
                //-- Se não encontrou DLY não processa docFis - (Erro reclock em EOF)
                If lStaDM0 .And. lDocFis .And. Empty(nRegDLY) 
                    LOOP
                EndIf

                If !Empty(cNumViagem) .AND. DTQ->( DbSeek( xFilial('DTQ') + cNumViagem ) ) .AND. DTQ->DTQ_FILORI <> cFilAnt
                    LOOP
                EndIf

                //--1.2 Verificar se o DLY possui o id, o id indica que o DLY foi integrado com o check list.
                // [ 1] - recno
                // [ 2] - DLY_IDINTG
                // [ 3] - DataInicio
                // [ 4] - DataFim
                // [ 5] - Filial Origem Viagem
                // [ 6] - Numero da Viagem
                // [ 7] - Data Inicial de Execução Check List
                // [ 8] - Data Final   de Execução Check List
                // [ 9] - Filial Documento
                // [10] - Numero Documento
                // [11] - Série  Documento
                // [12] - Chave do Documento Eletrônico
                //+--------------------------------------------------------------------------------------------
                //| 2. Envio dos Dados - Criar checklist quando o campo DLY_IDINTG estiver vazio.
                //+--------------------------------------------------------------------------------------------
                If Empty(cChkListId)

                    //-- Quando o campo DLY_IDINTG is Empty:
                    //-- Busca a lista de documentos da viagem:
                    aDocsChk := TMSLstChk( cFilOrigem, cNumViagem, cCHVCTE )
                    //-- Realiza a integração para criar o check list
                    aRetEnv := TMSEnvChk(Aclone(aDocsChk),cFilOrigem,cNumViagem)
                    //-- Executa a função de alteração da DM0
                    If !Empty(aRetEnv)
                        TMSIntChk("6",aClone(aRetEnv))
                    EndIf

                Else
                    //+--------------------------------------------------------------------------------------------
                    //| 3. Atualização dos dados
                    //|   quando o campo DLY_IDINTG is not Empty
                    //+--------------------------------------------------------------------------------------------
                    //-- Realiza GET pelo id do checklist para obter os dados apontados via App mobile e segue para
                    //-- Inicialização das Variáveis
                    //+----------------------------------------
                    //| Verifica se o Script Existe
                    //+----------------------------------------
                    
                    TMSChkVer2( @cVerChk )
                    
                    cPathParam  := cChkListId //--id - hash de identificacao do check list criado.
                    cJSon       := TMSCHKLIST( "GET" ,"checklists", ,, cPathParam, ,,,,,,, cVerChk )

                    If FWJsonDeserialize( cJSon, @oResult )
                        If ValType(oResult) == "O" .AND. ValType(oResult:LATITUDE) <> "U" .AND. ValType(oResult:LONGITUDE) <> "U"
                            nLatitu := oResult:LATITUDE
                            nLongit := oResult:LONGITUDE
                        Else
                            nLatitu := 0
                            nLongit := 0
                        EndIf
                    Else
                        nLatitu := 0
                        nLongit := 0
                    EndIf

                    oJSon := JsonObject():New()
                    oJSon:fromJSon(cJSon)
                    If ValType(oJSon["items"]) == "A"
                        oItems := oJson["items"]
                    Else
                        oItems := oJson
                    EndIf
                    //+----------------------------------------------------------------------------------------------------------------------------
                    //-- Se o status do checklist PENDING não será realizado leitura dos dados por não serem validos ou não existir
                    //-- ainda uma ação apontada pelo APP
                    If oItems["status"]["id"] $ "PENDING"
                        LOOP
                    EndIf
                    //+---------------------------------------------------------------
                    //| Check list com status CANCELED deve ter o DLY correspondente
                    //| excluído da base.
                    //+---------------------------------------------------------------
                    If oItems["status"]["id"] $ "CANCELED"
                        If lStaDM0
                            DelDM0(cChkListId,cFilOrigem,cNumViagem)
                        EndIf

                        If lDocFis
                            aVetDLY := {}
                            Aadd( aVetDLY, { If( lStaDM0, nRegDLY, nRegistro ), {} } )
                            TMSIntChk( "3", aVetDLY )
                        EndIf
                        Loop
                    EndIf

                    //-- Recupera Respostas do checklist 3. somente se houver algum apontamento registrado e finalizado.
                    //-- Retorno da função getAnswers() é um Array de objetos JSon.
                    //-- no formato JSON Object:
                    //-- [x]["status"] //FINISHED, PENDING,CANCELED
                    //-- [x]["excutorId"    ] //HASH - codigo de identifição do utilizador do app para uso exclusivo do checklist
                    //-- [x]["fullName"     ] //Nome do Utilizador/Executor do check list pelo App, aqui usamos o DA4_APPLOG
                    //-- [x]["observation"  ]
                    //-- [x]["fileExtension"] //extensão do arquivo de imagem enviada para o checklist
                    //-- [x]["fileId"       ] //identificador do arquivo gravado no App do checklist - é retornado um Hash
                    //-- [x]["fields"       ] // é uma collection e deve ser acessado os seguintes campos da seguinte forma
                    //-- [x]["fields"       ]["title"] -- titulo do campo configurado pelo roteiro do checklist na fase de definição dos itens.
                    //-- [x]["fields"       ]["type" ] -- tipo do campo BINARY(considere como BOOLEAN);CHECK equivalente a checkbox;TEXT = TEXTO.
                    //-- [x]["fields"       ]["value"] -- Valor retornado pelo apontamento do checklist de acordo com o tipo. Exemplo. Se o tipo é BINARY o retorno será .F. ou .T., TEXT=Sempre será texto e CHECK será um texto selecionado via App checklist
                    aAnswers    := getAnswers(oJson)
                    lHasAnswer  := ( Len( aAnswers ) > 0 )
                    lGravei     := .F.
                    For nCount3 := 1 To Len( aAnswers )

                        //| A principio o campo que indica se o documento foi entregue/não entregue está com o titulo de "CTE ENTREGUE?"
                        If aAnswers[nCount3]["fields"]["type"] == 'BINARY' .And. aAnswers[nCount3]["fields"]["title"] $ "DOCUMENTO ENTREGUE?,CTE ENTREGUE?,COLETA EFETUADA?"
                            //+----------------------------------------------------------------------------------
                            //| Update - Atualiza o registro do DLY com os campos Recebedor da carga, 
                            //| Documento RG,CPF ou CNH de quem recebeu a carga e caminho+.extensão da imagem.
                            //+----------------------------------------------------------------------------------
                            cDocEntreg := ""
                            If aAnswers[nCount3]["fields"]["value"] == .T.
                                cDocEntreg := "S"
                            ElseIf aAnswers[nCount3]["fields"]["value"] == .F.
                                cDocEntreg := "N"
                            EndIf
                        ElseIf aAnswers[nCount3]["fields"]["type"] == 'TEXT'
                            If Upper(aAnswers[nCount3]["fields"]["title"]) $ "RECEBEDOR,EXPEDIDOR"
                                cRecebedor := aAnswers[nCount3]["fields"]["value"]
                            ElseIf Upper(aAnswers[nCount3]["fields"]["title"]) == "DOCUMENTO"
                                cDocRecebe := aAnswers[nCount3]["fields"]["value"]
                            EndIf
                        ElseIf aAnswers[nCount3]["fields"]["type"] == 'NUMBER'
                            If aAnswers[nCount3]["fields"]["title"] == "PESO COLETADO?"
                                nPesOco := aAnswers[nCount3]["fields"]["value"]
                            ElseIf aAnswers[nCount3]["fields"]["title"] == "VOLUME COLETADO?"
                                nVolOco := Int(aAnswers[nCount3]["fields"]["value"])
                            EndIf
                        ElseIf lDMH .AND. aAnswers[nCount3]["fields"]["type"] == "BARCODE_READING"
                            If Upper(aAnswers[nCount3]["fields"]["title"]) == "CHAVES DAS DANFES"
                                AAdd( aChvDnf, Padr( aAnswers[nCount3]["fields"]["value"], TamSx3('DMH_CHVNFE')[1] ) )
                            EndIf
                        EndIf
                        
                        //+------------------------------------------------------------------------------------------
                        //| Atualiza a tabela DLY com os dados do recebedor
                        //+------------------------------------------------------------------------------------------

                        //-- Carrega data de entrega/coleta
                        DateTimeFS( /*cUF*/, lHVerao, @dDatEnt, @cHorEnt)

                        If cDocEntreg == "S" .And. !Empty(cRecebedor) .And. !Empty(cDocRecebe)
                            If lStaDM0
                                aVetDM0 := {}
                                Aadd(aVetDM0,{{"DM0_NOMRES",cRecebedor,Nil},;
                                                {"DM0_DOCRES",cDocRecebe,Nil},;
                                                {"DM0_DATREA",dDatEnt   ,Nil},;
                                                {"DM0_HORREA",cHorEnt   ,Nil}})
                                TMSIntChk("5",{nRegistro,aVetDM0})
                                lGravei := .T.
                            EndIf

                            If lDocFis
                                aVetDLY := {}
                                Aadd( aVetDLY, { If( lStaDM0, nRegDLY, nRegistro ),;
                                                {   { "DLY_RECEBE", cRecebedor, Nil },;
                                                    { "DLY_DOCREC", cDocRecebe, Nil },;
                                                    { "DLY_DIRIMG", "",         Nil } } } )
                                TMSIntCHk( "4", aVetDLY )
                                lGravei := .T.
                            EndIf
                        EndIf

                        //+------------------------------------------------------------------------------------------
                        //| Verifique se existe arquivo de evidencia / no caso a foto do canho do documento entregue.
                        //+-------------------------------------------------------------------------------------------
                        If !Empty(aAnswers[nCount3]["fields"]["fileId"]) .And. !Empty(aAnswers[nCount3]["fields"]["fileExtension"])
                            cIdImage    := aAnswers[nCount3]["fields"]["fileId"]
                            cFileExt    := aAnswers[nCount3]["fields"]["fileExtension"]
                            
                            cPathParam  := cIdImage
                            aInfImg     := {}

                            /*
                                {
                                    "lastModified": "2020-11-23T20:05:50.503Z",
                                    "length": 0,
                                    "name": "string",
                                    "type": "string"
                                }
                            */
                            aInfImg := TMSImgInf( cPathParam )
                            
                            If aInfImg[2] > 0
                                nTamImg     := aInfImg[2]
                                lMaxSize    := RetMxSz( nTamImg )
                            EndIf
                            
                            If !lMaxSize
                                cJSonImg    := TMSCHKLIST("GET","download",,,cPathParam,,,,,,.T.)

                                cJsonImg    := Encode64(cJsonImg)
                                If !Empty(cJsonImg)
                                    // Estrutura aVetImg
                                    // [1]FILDOC
                                    // [2]DOC
                                    // [3]SERIE
                                    // [4]EXTENSAO DA IMAGEM - Ex. ".JPG"
                                    // [5]BINARIO DA IMAGEM
                                    aImageData  := {}
                                    Aadd(aImageData,{cFilDoc,cDoc,cSerie,cFileExt,cJsonImg})
                                EndIf
                            Else
                                TMSGrvErr( nRegistro )
                            EndIf
                        EndIf

                    Next nCount3

                    If lGravei
                        TMSMovImg(aImageData)
                    EndIf

                    //+--------------------------------------------------------------------------------------------
                    //| 4. Apontamento de Ocorrencias quando checklist retornar documento entregue(positivo)
                    //+--------------------------------------------------------------------------------------------
                    /*
                        @param Estrutura aVetOcor
                                        [1]HASH
                                        [2]DATA OCORRENCIA
                                        [3]HORA OCORRENCIA
                                        [4]Filial Orig. Viagem
                                        [5]Numero da Viagem
                        @return Logico
                    /*/

                    If cDocEntreg == "S" .And. lHasAnswer
                        aVetOcor := {}
                        AAdd( aVetOcor, {   cChvCTE, ;
                                            DtoC(dDatEnt), ;
                                            cHorEnt, ;
                                            cFilOrigem, ;
                                            cNumViagem, ;
                                            cFilDoc, ;
                                            cDoc, ;
                                            cSerie, ;
                                            nPesOco, ;
                                            nVolOco } )

                        If ExistFunc("TMSCLOcor") .And. !Empty(aVetOcor)
                            If lDMH .And. Len(aChvDnf) > 0
                                GrvCnfCol( aChvDnf, cFilOrigem, cNumViagem, cFilDoc, cDoc, cSerie )
                            EndIf

                            If nLatitu <> 0 .AND. nLongit <> 0
                                GrvLocal( cFilOrigem, cNumViagem, cFilDoc, cDoc, cSerie, nLatitu, nLongit, dDatEnt, cHorEnt, cCDRDES, @cIdMPOS )
                            EndIf

                            aChvDnf := {}

                            If TMSCLOcor(aVetOcor)
                                
                                If lStaDM0
                                    aVetDM0 := {}
                                    
                                    If lDM0Pos
                                        Aadd( aVetDM0, { { "DM0_STATUS", StrZero(2,Len(DM0->DM0_STATUS)), Nil }, { "DM0_IDMPOS", cIdMPOS, Nil } } )
                                    Else
                                        Aadd( aVetDM0, { { "DM0_STATUS", StrZero(2,Len(DM0->DM0_STATUS)), Nil } } )
                                    EndIf

                                    TMSIntChk( "5", { nRegistro, aVetDM0 } )
                                EndIf
                                
                                If lDocFis
                                    cDlyStatus := Iif(!Empty(cRecebedor) .And. !Empty(cDocRecebe) .And. TMSImgDM0(cFilDoc,cDoc,cSerie),"2","1") //--1=NAO APTO;2=APTO para transmissão do comprovante
                                    aVetDLY := {}
                                    Aadd( aVetDLY,  { If( lStaDM0, nRegDLY, nRegistro ),;
                                                    { { "DLY_STATUS", cDlyStatus, Nil } } } )
                                    TMSIntChk( "4", aVetDLY )
                                EndIf
                            EndIf
                        EndIf
                    EndIf

                    //+----------------------------------------------------------------------------------
                    //| 5. Delete - Remove o registro do DLY para o documento não entregue
                    //+----------------------------------------------------------------------------------
                    If cDocEntreg == "N" .And. lHasAnswer
                        If lStaDM0
                            DelDM0(cChkListId,cFilOrigem,cNumViagem)
                        EndIf

                        If lDocFis
                            aVetDLY := {}
                            Aadd( aVetDLY, { If( lStaDM0, nRegDLY, nRegistro ), {} } )
                            TMSIntChk("3",aVetDLY)
                        EndIf
                    EndIf

                EndIf

                If lTME81MNT
                        ExecBlock('TME81MNT',.F.,.F.,{cFilOrigem,cNumViagem,cFilDoc,cDoc,cSerie,cJSon})
                EndIf

        Next nCount
        
    End Sequence
    
RestArea(aArea)
RestArea(aAreaDTQ)

Return NIL

/*/{Protheus.doc} getAnswers()
    obtem os campos de resposta do check list. Especificamente será o entregue ou não, nome do recebedor e documento do recebedor.
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function getAnswers(oJSon)
 Local nCount       := 1
 Local cExecId      := ""
 Local cExecName    := ""
 Local cStatus      := ""
 Local oAnswer      := Nil
 Local aEvidences   := {}
 Local cSelAnswer   := "" //--qual resposta foi selecionada e registrada pelo App
 Local cAnswerType  := "" //--Tipo de Campo BINARY,CHECK,TEXT etc.
 Local cTxtCampo    := ""
 Local lEntregue    := .F.
 Local aOptions     := {} //--Tipo de opções existentes para os campos do tipo BINARY e CHECK liste
 Local oJResult     := DTOChklist("checklist")
 Local aResult      := {}

        If (Valtype(oJSon["status"]) == "J")
            cStatus := oJson["status"]["id"]
            oJResult["status"   ] := cStatus
        EndIf
        If (ValType(oJson["executor"]) == "J")
            cExecId      := oJson["executor"]["id"]
            cExecName    := oJson["executor"]["fullName"]
            oJResult["excutorId"] := cExecId
            oJResult["fullName" ] := cExecName
        EndIf
        //+-------------------------------------------------------------------------------------------------------
        //| Processa a resposta fornecida peloa App Check List
        //| [ANSWER] JSON OBJECT
        //+-------------------------------------------------------------------------------------------------------
        If(ValType(oJSon["answers"]) == "A")
            oAnswer := oJson["answers"]
            For nCount := 1 To Len(oAnswer)
                
                cSelAnswer := oAnswer[nCount]["answer"] //-- Resposta Selecionada.
                //-- Se não existir uma resposta para o item ignora o seu processamento.
                If Empty(cSelAnswer)
                    LOOP
                EndIf

                //+---------------------------------------------------
                //| Verifica se o campo de resposta é um dos tipos abaixo
                //| Tipos de Campos:
                //|     BINARY = POSITIVO/NEGATIVO(YES/NO)
                //|     CHECK  = Multiplas Opções (Radio Box), apenas 1 opção pode ser selecionada
                //|     TEXT   = Campo Texto (digitado pelo usuário)
                //|     TEXT   = BARCODE_READING
                //+---------------------------------------------------
                If ValType(oAnswer[nCount]["item"]) == "J"
                    //--1.obtem o tipo de campo:
                    If ValType(oAnswer[nCount]["item"]["renderType"]) == "J"
                        cAnswerType := oAnswer[nCount]["item"]["renderType"]["id"]
                    EndIf
                    oJResult["fields"]["title"] := Upper(oAnswer[nCount]["item"]["statement"])
                    oJResult["fields"]["type" ] := cAnswerType

                    //-- 2. Obtenho o valor informado conforme o tipo de campo.
                    //-- Quando o campo é Positivo/Negativo(YESNO)
                    If cAnswerType == "BARCODE_READING"
                        oJResult["fields"]["value"] := cSelAnswer
                    EndIf
                    If cAnswerType == "BINARY"
                        If ValType(oAnswer[nCount]["item"]["options"]) == "A"
                            aOptions := oAnswer[nCount]["item"]["options"]
                            If Len(aOptions) > 0
                                lEntregue := (aOptions[Val(cSelAnswer)]["label"] == "OK")
                                oJResult["fields"]["value"] := lEntregue
                                oJResult["delivered"] := lEntregue
                            EndIf
                        EndIf
                    EndIf
                    If cAnswerType == "CHECK"
                        aOptions := oAnswer[nCount]["item"]["options"]
                        oJResult["fields"]["value"] := aOptions[val(cSelAnswer)]["label"]
                    EndIf
                    If cAnswerType == "TEXT"
                        aOptions := oAnswer[nCount]["item"]["options"]
                        If ValType(oAnswer[nCount]["item"]["statement"]) == "C"
                            cTxtCampo := Upper(oAnswer[nCount]["item"]["statement"])
                            If cTxtCampo $ "RECEBEDOR,EXPEDIDOR"
                                oJResult["fields"]["value"] := AllTrim(cSelAnswer)
                                oJResult["recipientName" ]  := AllTrim(cSelAnswer) //-- Nome do Expedidor ou Recebedor da Mercadoria
                            EndIf
                            If cTxtCampo == "DOCUMENTO"
                                oJResult["fields"]["value"] := AllTrim(cSelAnswer)
                                oJResult["documentId"     ] := AllTrim(cSelAnswer) //-- Documento do Expedidor ou Recebedor
                            EndIf
                        EndIf
                    EndIf
                    If cAnswerType == "NUMBER"
                        oJResult["fields"]["value"] := Val( oAnswer[nCount]["answer"] )
                    EndIf
                EndIf
                //+---------------------------------------------------
                //| Outros Valores informado pelo check list - quando resposta for negativa
                //+---------------------------------------------------
                If(ValType(oAnswer[nCount]["otherValues"]) == "O")
                EndIf
                //-- Obtem as coordenadas se existir
                If ValType(oAnswer[nCount]["coordinate"]) == "J"

                EndIf
                //-- Obtem a Observação se existir
                If ValType(oAnswer[nCount]["observation"]) == "C"
                    cObservation := oAnswer[nCount]["item"]["observation"]
                    oJResult["observation"] := cObservation
                EndIf
                //-- Obtem as imagens de Evidencias do CheckList
                //-- Não é o conteúdo do arquivo propriamente dito, mas uma referência para buscar por outra API.
                If(ValType(oAnswer[nCount]["evidences"]) == "A") .And. Len(oAnswer[nCount]["evidences"]) > 0
                    aEvidences := oAnswer[nCount]["evidences"]
                    If Len(aEvidences) > 0
                        If ValType(aEvidences[1]["evidenceId"]) == "C"
                            oJResult["fileId"] := AllTrim(aEvidences[1]["evidenceId"])
                            oJResult["fields"]["fileId"] := AllTrim(aEvidences[1]["evidenceId"])
                        EndIf
                        If ValType(aEvidences[1]["fileExtension"]) == "C"
                                oJResult["fileExtension"] := AllTrim(aEvidences[1]["fileExtension"])
                                oJResult["fields"]["fileExtension"] := AllTrim(aEvidences[1]["fileExtension"])
                        EndIf
                    EndIf
                EndIf
                //-------------------------------------------------------------------
                //-- Guardo Result em um Array
                Aadd(aResult , oJResult)
                aResult := aClone(aResult)
                //--Reset do oJResult
                oJResult["fields"] := JsonObject():New()
            Next nCount
        EndIf
        FreeObj(oJResult)
Return aResult

/*/{Protheus.doc} DTOCHKList(cDTONAME)
    Função responsável por criar DTO do checklist para cada tipo de retorno.
    função é especifica para as rotinas originais deste fonte.
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
 Static Function DTOCHKList(cDTONAME)
  Local oJResult     := JsonObject():New()

    If lower(cDTONAME) == "checklist"
        oJResult["status"        ] := ""
        oJResult["excutorId"     ] := ""
        oJResult["fullName"      ] := ""
        oJResult["observation"   ] := ""
        oJResult["recipientName" ] := "" //-- Nome do Expedidor ou Recebedor da Mercadoria
        oJResult["documentId"    ] := "" //-- Documento do Expedidor ou Recebedor
        oJResult["delivered"     ] := "" //--Documento foi entregue? "S ou N"
        oJResult["observation"   ] := ""
        oJResult["fileExtension" ] := ""
        oJResult["fileId"        ] := ""
        oJResult["fields"        ] := JsonObject():New()
    Else
    EndIf

Return oJResult

//-------------------------------------------------------------------
/*{Protheus.doc} RetMxSz
Valida o tamanho da imagem com o appserver.ini

@author Rodrigo Pirolo
@since 20/11/2020
@version 1.0
*/
//-------------------------------------------------------------------

Static Function RetMxSz( nTamImg )

    Local cMaxSize  := GetPvProfString( "general", "maxStringSize", "10", GetAdv97() )
    Local nMaxSize  := Val( cMaxSize ) * 1048576
    Local lRet      := .F.

    Default nTamImg := 0

    If nTamImg > nMaxSize
        lRet    := .T.
    EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} RetMxSz
Retorna o Recno da DLY para posteriormente gravar os campos DLY_RECEBE DLY_DOCREC

@author Rodrigo Pirolo
@since 20/11/2020
@version 1.0
*/
//-------------------------------------------------------------------

Static Function RetRecDLY( cFilOrigem, cNumViagem, cFilDoc, cDoc, cSerie, cChvCTE, cChkListId )

    Local cAlias    := ""
    Local cQuery    := ""
    Local nRet      := 0
    Local aArea     := GetArea()
    Local aAreaDLY  := DLY->(GetArea())
    Local aAreaDM0  := DM0->(GetArea())

    Default cFilOrigem  := ""
    Default cNumViagem  := ""
    Default cFilDoc     := ""
    Default cDoc        := ""
    Default cSerie      := ""
    Default cChvCTE     := ""
    Default cChkListId  := ""

    cAlias := GetNextAlias()

    cQuery := " SELECT DLY.R_E_C_N_O_ RECNO "
    cQuery += " FROM " + RetSqlName("DLY") + " DLY "
    cQuery += " WHERE DLY.DLY_FILIAL = '" + xFilial("DLY") + "' "
    cQuery +=       " AND DLY.DLY_IDINTG = '" + cChkListId + "' "
    cQuery +=       " AND DLY.DLY_FILORI = '" + cFilOrigem + "' "
    cQuery +=       " AND DLY.DLY_VIAGEM = '" + cNumViagem + "' "
    cQuery +=       " AND DLY.DLY_FILDOC = '" + cFilDoc + "' "
    cQuery +=       " AND DLY.DLY_DOC = '" + cDoc + "' "
    cQuery +=       " AND DLY.DLY_SERIE = '" + cSerie + "' "
    cQuery +=       " AND DLY.DLY_CHVCTE = '" + cChvCTE + "' "
    cQuery +=       " AND DLY.DLY_RECEBE = '" + Space( TamSX3("DLY_RECEBE")[1] ) + "' "
    cQuery +=       " AND DLY.DLY_DOCREC = '" + Space( TamSX3("DLY_DOCREC")[1] ) + "' "
    cQuery +=       " AND DLY.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)

    DbUseArea( .T., "TOPCONN", TCGENQRY( , , cQuery ), cAlias, .F., .T. )

    While (cAlias)->(!Eof())

        nRet := (cAlias)->(RECNO)
        If nRet > 0
            Exit
        EndIf
        (cAlias)->(DbSkip())
    EndDo
    
    (cAlias)->( DbCloseArea() )

    RestArea(aArea)
    RestArea(aAreaDLY)
    RestArea(aAreaDM0)

Return nRet

//-------------------------------------------------------------------
/*{Protheus.doc} RetMxSz
Retorna o Recno da DLY para posteriormente gravar os campos DLY_RECEBE DLY_DOCREC

@author Rodrigo Pirolo
@since 20/11/2020
@version 1.0
*/
//-------------------------------------------------------------------

Static Function GrvCnfCol( aChvDnf, cFilOrigem, cNumViagem, cFilDoc, cDoc, cSerie )

    Local aArea         := GetArea()
    Local aAreaDF6      := DF6->(GetArea())
    Local aAreaDMH      := DMH->(GetArea())
    Local aAreaDTW      := DTW->(GetArea())
    Local nOperat       := 0
    Local nX            := 0
    Local cSequen       := ""
    Local oModel        := Nil
    Local oFieldDF6     := Nil
    Local oGridDF6      := Nil
    Local oGridDMH      := Nil
    Local lFindDF6      := .F.
    Local cAtivSai      := SuperGetMV( 'MV_ATIVSAI', , '' )
    Local lSaiApo       := .F.
    Local cDtRea        := ""
    Local cHrRea        := ""
    Local lRet          := .F.

    Default aChvDnf     := {}
    Default cFilOrigem  := ""
    Default cNumViagem  := ""
    Default cFilDoc     := ""
    Default cDoc        := ""
    Default cSerie      := ""
    
    DbSelectArea("DF6")
    DF6->( DbSetOrder(1) ) // DF6_FILIAL, DF6_FILORI, DF6_VIAGEM, DF6_SEQUEN
    
    DbSelectArea("DMH")
    DMH->( DbSetOrder(1) ) // DMH_FILIAL, DMH_FILORI, DMH_VIAGEM, DMH_SEQUEN, DMH_SEQNFE

    DbSelectArea("DTW")
    DTW->(DbSetOrder(4))

    If DTW->(MsSeek(xFilial('DTW') + cFilOrigem + cNumViagem + cAtivSai ) )
        lSaiApo := .T.
        cDtRea  := DTW->DTW_DATREA
        cHrRea  := DTW->DTW_HORREA
    EndIf

    If lSaiApo
        If DF6->( DbSeek( xFilial("DF6") + cFilOrigem + cNumViagem ) )
            nOperat := 4
        Else
            nOperat := 3
        EndIf
        
        oModel := FWLoadModel( "TMSA461" )

        oModel:SetOperation( nOperat )
        oModel:Activate()

        oFieldDF6   := oModel:GetModel("TMS461CDF6")
        oGridDF6    := oModel:GetModel("TMS461IDF6")
        oGridDMH    := oModel:GetModel("DMHDET")

        If nOperat == 3
            oFieldDF6:SetValue( "DF6_FILORI", cFilOrigem )
            oFieldDF6:SetValue( "DF6_VIAGEM", cNumViagem )
            
            cSequen := StrZero( 1, Len(DF6->DF6_SEQUEN))

        Else
            
            lFindDF6 := oGridDF6:SeekLine( { { "DF6_FILDOC", cFilDoc }, { "DF6_DOC", cDoc }, { "DF6_SERIE", cSerie } } )
            If !lFindDF6
                If oGridDF6:VldData()
                    oGridDF6:AddLine()
                    cSequen := StrZero( oGridDF6:Length(), Len(DF6->DF6_SEQUEN))
                EndIf
            Else
                cSequen := oGridDF6:GetValue( "DF6_SEQUEN" )
            EndIf
        EndIf

        If !lFindDF6
            oGridDF6:SetValue( "DF6_DATCOL",    cDtRea  )
            oGridDF6:SetValue( "DF6_HORCOL",    cHrRea  )
            oGridDF6:SetValue( "DF6_SEQUEN",    cSequen )
            oGridDF6:SetValue( "DF6_FILDOC",    cFilDoc )
            oGridDF6:SetValue( "DF6_DOC",       cDoc    )
            oGridDF6:SetValue( "DF6_SERIE",     cSerie  )
        EndIf

        For nX := 1 To Len(aChvDnf)
            
            If nOperat == 3 .AND. !(oGridDMH:IsEmpty())
                If !( oGridDMH:SeekLine( { { "DMH_CHVNFE", aChvDnf[nX] } } ) )
                    oGridDMH:AddLine()
                Else
                    Loop
                EndIf
            ElseIf nOperat == 4
                If !( oGridDMH:SeekLine( { { "DMH_FILORI", cFilOrigem }, { "DMH_VIAGEM", cNumViagem }, { "DMH_SEQUEN", cSequen }, { "DMH_CHVNFE", aChvDnf[nX] } } ) ) .AND. !oGridDMH:IsEmpty()
                    oGridDMH:AddLine()
                ElseIf ( oGridDMH:SeekLine( { { "DMH_FILORI", cFilOrigem }, { "DMH_VIAGEM", cNumViagem }, { "DMH_SEQUEN", cSequen }, { "DMH_CHVNFE", aChvDnf[nX] } } ) )
                    Loop
                EndIf
            EndIf
            
            cSeqNfe := StrZero( oGridDMH:Length(), Len(DMH->DMH_SEQNFE) )

            oGridDMH:SetValue( "DMH_FILORI", cFilOrigem  )
            oGridDMH:SetValue( "DMH_VIAGEM", cNumViagem  )
            oGridDMH:SetValue( "DMH_SEQUEN", cSequen     )
            oGridDMH:SetValue( "DMH_SEQNFE", cSeqNfe     )
            oGridDMH:SetValue( "DMH_CHVNFE", aChvDnf[nX] )

        Next nX

        oGridDF6:SetValue( "DF6_QTDENF",    oGridDMH:Length()    )

        If oModel:VldData()
            lRet := oModel:CommitData()
        EndIf

        oModel:DeActivate()
        oModel:Destroy()
        
        FwFreeObj(oModel)
        FwFreeObj(oFieldDF6)
        FwFreeObj(oGridDF6)
        FwFreeObj(oGridDMH)

    EndIf

    FwFreeArray(aChvDnf)

    RestArea(aArea)
    RestArea(aAreaDF6)
    RestArea(aAreaDMH)
    RestArea(aAreaDTW)

Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} RetMxSz
Retorna o Recno da DLY para posteriormente gravar os campos DLY_RECEBE DLY_DOCREC

@author Rodrigo Pirolo
@since 20/11/2020
@version 1.0
*/
//-------------------------------------------------------------------

Static Function GrvLocal( cFilOrigem, cNumViagem, cFilDoc, cDoc, cSerie, nLatitu, nLongit, dDatEnt, cHorEnt, cCDRDES, cIdMPOS )

    Local aArea         := GetArea()
    Local aAreaDTR      := DTR->(GetArea())
    Local aAreaDAV      := DAV->(GetArea())
    Local aAreaDAR      := DAR->(GetArea())

    Local lRet          := .T.
    Local lBlind        := IsBlind()

    Local cCodVei       := ""
    Local cPLat         := 0
    Local cPLon         := 0

    Local nOpcx         := 0

    Local aCabDAV       := {}
    Local aCabDAR       := {}
    
    Private lMsErroAuto     := .F.
    Private lAutoErrNoFile  := .T.

    Default cFilOrigem  := ""
    Default cNumViagem  := ""
    Default cFilDoc     := ""
    Default cDoc        := ""
    Default cSerie      := ""
    Default nLatitu     := 0
    Default nLongit     := 0
    Default dDatEnt     := CToD("  /  /    ")
    Default cHorEnt     := ""
    Default cCDRDES     := ""

    DbSelectArea( "DTR" )
    DTR->( DbSetOrder( 1 ) ) // DTR_FILIAL, DTR_FILORI, DTR_VIAGEM, DTR_ITEM
    If DTR->( DbSeek( xFilial( "DTR" ) + cFilOrigem + cNumViagem + StrZero( 1, Len( DTR->DTR_ITEM ) ) ) )
        cCodVei := DTR->DTR_CODVEI
    EndIf

    If !Empty( cCodVei )
        DbSelectArea( "DAV" )
        DAV->( DbSetOrder( 3 ) ) // DAV_FILIAL, DAV_FILORI, DAV_VIAGEM, DAV_CODVEI

        DbSelectArea( "DAR" )
        DAR->( DbSetOrder( 1 ) ) //DAR_FILIAL, DAR_FILENT, DAR_ENTIDA, DAR_CODENT, DAR_LATITU, DAR_LONGIT

        cPLat   := cValToChar(nLatitu)
        cPLon   := cValToChar(nLongit)

        nOpcx := 3

        // AAdd( aCab, { "DAV_FILIAL", xFilial( "DAV" ) )
        // GetSXEnum oMdlDAV:SetValue( "DAV_IDMPOS", cNumViagem )
        AAdd( aCabDAV, { "DAV_CODVEI", cCodVei,     NIL } )
        AAdd( aCabDAV, { "DAV_FILORI", cFilOrigem,  NIL } )
        AAdd( aCabDAV, { "DAV_VIAGEM", cNumViagem,  NIL } )
        AAdd( aCabDAV, { "DAV_TIPPOS", "3",         NIL } ) // 1=GPRS Memória; 2=GPRS Atual; 3=Satelital
        AAdd( aCabDAV, { "DAV_LATITU", cPLat,       NIL } )
        AAdd( aCabDAV, { "DAV_LONGIT", cPLon,       NIL } )
        AAdd( aCabDAV, { "DAV_STATUS", "3",         NIL } ) // 1=Nao Processado; 2=Processado com erro; 3=Processado
        AAdd( aCabDAV, { "DAV_DATPOS", dDatEnt,     NIL } )
        Aadd( aCabDAV, { "DAV_HORPOS", cHorEnt,     NIL } )
        Aadd( aCabDAV, { "DAV_IGNICA", "2",         NIL } ) // 0=Desligada; 1=Ligada; 2=Não identificada

        lAutoErrNoFile := If( lBlind, .T., .F. )

        MSExecAuto( { | x, y | TMSAO10( x, y ) }, aCabDAV, nOpcx )

        If lMsErroAuto
    
            If !lBlind
                MOSTRAERRO()
            EndIf
            lRet := .F.
        Else
            cIdMPOS := DAV->DAV_IDMPOS
        EndIf
        
        lMsErroAuto := .F.
        
    EndIf
    
    FwFreeArray( aCabDAV )
    FwFreeArray( aCabDAR )

    RestArea(aArea)
    RestArea(aAreaDTR)
    RestArea(aAreaDAV)
    RestArea(aAreaDAR)

Return lRet
