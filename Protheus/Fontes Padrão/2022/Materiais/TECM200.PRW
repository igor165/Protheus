#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TECM200.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} meutecnico

Serviços utilizados pelo app meu tecnico

@author     Luiz Gabriel
@since      14/08/2020
/*/
//------------------------------------------------------------------------------
WSRESTFUL meutecnico DESCRIPTION STR0001 //"meutecnico"

WSDATA cPswd        AS STRING
WSDATA cAttendant   AS STRING
WSDATA cDate        AS STRING
WSDATA cEquipament  AS STRING
WSDATA cID          AS STRING
WSDATA cNumOS       AS STRING 
WSDATA cItemOS      AS STRING
WSDATA nPage        AS INTEGER
WSDATA nPageSize    AS INTEGER
WSDATA cSearchTerm  AS STRING
WSDATA cStartDt     AS STRING
WSDATA cEndDt       AS STRING
WSDATA nPerHist     AS INTEGER
WSDATA cAlias       AS STRING
WSDATA cLaudo       AS STRING
WSDATA cChave       AS STRING
WSDATA recPhoto          AS INTEGER

WSMETHOD GET getAttendant       DESCRIPTION STR0005 PATH "getAttendant"     PRODUCES APPLICATION_JSON //"Retorna as identidades do tecnico"
WSMETHOD GET getSchedule        DESCRIPTION STR0002 PATH "getSchedule"      PRODUCES APPLICATION_JSON //"Retorna as agendas do técnico para o dia selecionado"
WSMETHOD GET getProduct         DESCRIPTION STR0020 PATH "getProduct"       PRODUCES APPLICATION_JSON //"Retorna os produtos para atendimento da ordem de serviço"
WSMETHOD GET getService         DESCRIPTION STR0021 PATH "getService"       PRODUCES APPLICATION_JSON //"Retorna os serviços utilizados no atendimento da ordem de serviço"
WSMETHOD GET productsPages      DESCRIPTION STR0037 PATH 'productsPages'    PRODUCES APPLICATION_JSON 
WSMETHOD GET getHistoric        DESCRIPTION STR0028 PATH "getHistoric"      PRODUCES APPLICATION_JSON //"Retorna o historico do equipamento"
WSMETHOD GET getDetail          DESCRIPTION STR0029 PATH "getDetail"        PRODUCES APPLICATION_JSON //"Retorna os detalhes do atendimento para a ordem de serviço selecionada"
WSMETHOD PUT putStatus          DESCRIPTION STR0012 PATH "putStatus"        PRODUCES APPLICATION_JSON //"Atualização do Status da Ordem de Serviço"
WSMETHOD PUT putEnceramento     DESCRIPTION STR0017 PATH "putEnceramento"   PRODUCES APPLICATION_JSON //"Atendimento da Ordem de serviço"
WSMETHOD PUT putRequest         DESCRIPTION STR0024 PATH "putRequest"       PRODUCES APPLICATION_JSON //"serviço para fazer requisição no estoque"
WSMETHOD POST postsolicitation  DESCRIPTION STR0026 PATH "postsolicitation" PRODUCES APPLICATION_JSON //"Atualiza a solicitação de peça e encerra a mesma"
WSMETHOD GET photos             DESCRIPTION STR0170 PATH "photos"           PRODUCES APPLICATION_JSON //"Obter fotos dos apontamentos "
WSMETHOD PUT laudo              DESCRIPTION STR0171 PATH "laudo"            PRODUCES APPLICATION_JSON //"Realiza a alteração do laudo de uma OS" 
WSMETHOD GET checkAtt           DESCRIPTION STR0172 PATH "ckatt"            PRODUCES APPLICATION_JSON //"Verifica se um item possui atendimento" 
WSMETHOD GET pagesPhoto         DESCRIPTION STR0173 PATH 'pagesphoto'       PRODUCES APPLICATION_JSON //'Paginação da api de fotos'
WSMETHOD POST file              DESCRIPTION STR0174 PATH "file"             PRODUCES APPLICATION_JSON //'Enviar arquivos'

END WSRESTFUL

//------------------------------------------------------------------------------
/*/{Protheus.doc} getAttendant

Serviços para selecionar o atendente

@author     Luiz Gabriel
@since      14/08/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD GET getAttendant WSRECEIVE cAttendant, cPswd WSREST meutecnico
Local lRet              := .T.
Local cTemp             := GetNextAlias()
Local cResponse		    := '{ "attendant":[], "count": 0 }'
Local cMessage          := "Internal Server Error"
Local nStatusCode       := 500
Local cDescExp          := ""

// define o tipo de retorno do método
::SetContentType("application/json")

If Empty(Self:cAttendant)
    lRet := .F.
    cMessage := STR0006 //"Informe o usuario"
EndIf

If lRet .And. Empty(Self:cPswd)
    lRet := .F.
    cMessage := STR0007 //"Informe a senha paara o usuario"
EndIf

If !Empty(Self:cAttendant) .And. !Empty(Self:cPswd)

    BeginSQL Alias cTemp
        
        SELECT 
            AA1_CODTEC, AA1_NOMTEC
        FROM 	
            %Table:AA1% AA1
        WHERE 
            AA1.AA1_FILIAL = %Exp:xFilial("AA1")% AND
            AA1.AA1_NREDUZ = %Exp:Self:cAttendant% AND
            AA1.AA1_SENHA = %Exp:Self:cPswd% AND
            AA1.%NotDel%
    EndSql

    If ( cTemp )->( !Eof() )

        lRet := .T.

        //-------------------------------------------------------------------
        // Posiciona no primeiro registro.
        //-------------------------------------------------------------------
        ( cTemp )->( DBGoTop() )

        cResponse	:= ""
        cResponse	+= '{ "attendant": '

        cResponse += '{"codtec":"' + ( cTemp )->AA1_CODTEC + '",'
        If CaracEsp(EncodeUTF8(( cTemp )->AA1_NOMTEC),@cDescExp)
            cResponse += '"nomtec":"' + cDescExp + '"}'
        Else
            cResponse += '"nomtec":"' + EncodeUTF8(( cTemp )->AA1_NOMTEC) + '"}'
        EndIf    
        cResponse += ' } '

        nStatusCode	:= 200
    Else
        lRet := .T.
        nStatusCode := 200
        cMessage 	:= STR0018 //"Usuário ou senha inválidos"
    EndIf
    (cTemp)->(dbCloseArea())
Else
    nStatusCode	:= 400
    cMessage 	:= STR0009 //"Necessario informar os parametros de usuario e senha do atendente"
EndIf

If lRet
    Self:SetResponse( cResponse )
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} getSchedule

Serviços para retornar as ordens de serviço do atendente para o dia selecionado

@author     Luiz Gabriel
@since      14/08/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD GET getSchedule WSRECEIVE cAttendant, cDate WSREST meutecnico
Local aLocal            := {}
Local lRet              := .T.
Local cTemp             := GetNextAlias()
Local cResponse         := '{ "schedule":[], "count": 0 }'
Local cMessage          := "Internal Server Error"
Local nStatusCode       := 500
Local nRecord           := 0
Local cCompartilha      := ""
Local cOcorrencia       := ""
Local aItens            := {}
Local nX                := 0
Local nY                := 0
Local cStatus           := ""
Local aOsAppoint        := {}
Local cOsAppoint        := ''
Local aOsFotos          := {}
Local cOsFotos          := ''
Local aItDetail         := {}
Local cItDetail         := ''
Local cLaudo            := ""
Local cProd             := ""
Local cAssinatura       := ""
Local cResponsavel      := ""

// define o tipo de retorno do método
::SetContentType("application/json;charset=UTF-8")

If Empty(Self:cAttendant)
    lRet := .F.
    cMessage := STR0003 //"Informe um atendente para consulta"
EndIf

If Empty(Self:cDate)
    lRet := .F.
    cMessage := STR0010 //"Informe uma data para realizar a consulta"
EndIf

If lRet 

    BeginSQL Alias cTemp
            COLUMN ABB_DTINI AS DATE
            SELECT ABB.ABB_ENTIDA,
                ABB.ABB_NUMOS,
                ABB.ABB_DTINI,
                AB6.AB6_CODCLI,
                AB6.AB6_LOJA,
                AB6.AB6_APPSTA,
                AB6.AB6_APPDTI,
                AB6.AB6_APPHRI,
                AB6.AB6_APPDCH,
                AB6.AB6_APPHCH,
                AB6.AB6_FILIAL,
                SA1.A1_NOME,
                SA1.A1_END,
                SA1.A1_BAIRRO,
                SA1.A1_EST,
                SA1.A1_CEP,
                SA1.A1_MUN,
                SA1.A1_DDD,
                SA1.A1_TEL,
                SA1.A1_CONTATO,
                SA1.A1_EMAIL,
                MIN(ABB.ABB_HRINI) ABB_HRINI,
                MAX(ABB.ABB_HRFIM) ABB_HRFIM
        FROM %Table:ABB% ABB
        INNER JOIN %Table:AB6% AB6 ON AB6.AB6_FILIAL = %Exp:xFilial("AB6")%
            AND AB6.AB6_NUMOS = ABB.ABB_NUMOS
            AND ABB.ABB_ENTIDA <> ''
            AND AB6.%NotDel%
        INNER JOIN %Table:SA1% SA1 ON SA1.A1_FILIAL = %Exp:xFilial("SA1")%   
            AND SA1.A1_COD = AB6.AB6_CODCLI
            AND SA1.A1_LOJA = AB6.AB6_LOJA
            AND SA1.%NotDel%
        WHERE 
            ABB.ABB_FILIAL = %Exp:xFilial("ABB")%
            AND ABB.ABB_CODTEC = %Exp:Self:cAttendant%
            AND ABB.ABB_DTINI = %Exp:Self:cDate%
            AND ABB.ABB_CHEGOU = 'N'
            AND ABB.ABB_ATENDE = '2'
            AND ABB.%NotDel% 
        GROUP BY 
            ABB.ABB_ENTIDA,
            ABB.ABB_NUMOS,
            ABB.ABB_DTINI,
            AB6.AB6_CODCLI,
            AB6.AB6_LOJA,
            AB6.AB6_APPSTA,
            AB6.AB6_APPDTI,
            AB6.AB6_APPHRI,
            AB6.AB6_APPDCH,
            AB6.AB6_APPHCH,
            AB6.AB6_FILIAL,
            SA1.A1_NOME,
            SA1.A1_END,
            SA1.A1_BAIRRO,
            SA1.A1_EST,
            SA1.A1_CEP,
            SA1.A1_MUN,
            SA1.A1_DDD,
            SA1.A1_TEL,
            SA1.A1_CONTATO,
            SA1.A1_EMAIL
        ORDER BY
            ABB_HRINI,
            ABB_HRFIM        
    EndSql

    If ( cTemp )->( !Eof() )
        ( cTemp )->( DBGoTop() )

        cResponse := ''
        cResponse := '{"schedule":['
        While ( cTemp )->( !Eof() )
            cAssinatura := ""
            cResponsavel := ""
            nRecord++
            If nRecord > 1
                cResponse += ','
            EndIf
            aItens := {}
            If ( cTemp )->ABB_ENTIDA == 'AB6'
                cStatus := X3Combo("AB6_APPSTA", Alltrim(( cTemp )->AB6_APPSTA))
                if cStatus == ""
                    cStatus = "Aberto"
                EndIf
                //verifica os detalhes da ordem de serviço
                cOcorrencia := OsDetalhe((cTemp)->ABB_NUMOS,@aItens,( cTemp )->ABB_DTINI,( cTemp )->ABB_ENTIDA,::cAttendant, , @aLocal)

                //verifica se a ordem de serviço está sendo atendida por mais de 1 atendente
                If OsCompartilha(( cTemp )->ABB_NUMOS,::cAttendant)
                    cCompartilha := "true"
                Else
                    cCompartilha := "false"
                EndIf
            
                cResponse += '{"horaIni":"' + Alltrim(( cTemp )->ABB_HRINI) + '",'
                cResponse += '"horaFim":"' + Alltrim(( cTemp )->ABB_HRFIM) + '",'
                cResponse += '"numOS":"' + Alltrim(( cTemp )->ABB_NUMOS) + '",'
                cResponse += '"filialOS":"' + Alltrim(( cTemp )->AB6_FILIAL) + '",'
                cResponse += '"cliente":"' + EncodeUTF8(Alltrim(( cTemp )->A1_NOME)) + '",'

                cResponse += '"endereco":'
                
                If Len(aLocal) > 0
                    cResponse += '{"logradouro":"' + EncodeUTF8(Alltrim(aLocal[1])) + '",'
                    cResponse += '"bairro":"' + EncodeUTF8(Alltrim(aLocal[2])) + '",'
                    cResponse += '"cidade":"' + EncodeUTF8(Alltrim(aLocal[3])) + '",'
                    cResponse += '"uf":"' + EncodeUTF8(Alltrim(aLocal[4])) + '",'
                    cResponse += '"cep":"' + EncodeUTF8(Alltrim(aLocal[5])) + '",'
                    cResponse += '"contato":"' + EncodeUTF8(Alltrim(aLocal[6])) + '",'
                    cResponse += '"email":"' + EncodeUTF8(Alltrim(aLocal[9])) + '",'
                    cResponse += '"tel":"' + EncodeUTF8(Alltrim(aLocal[7] + " - " + aLocal[8])) + '"}'
                Else
                    cResponse += '{"logradouro":"' + EncodeUTF8(Alltrim(( cTemp )->A1_END)) + '",'
                    cResponse += '"bairro":"' + EncodeUTF8(Alltrim(( cTemp )->A1_BAIRRO)) + '",'
                    cResponse += '"cidade":"' + EncodeUTF8(Alltrim(( cTemp )->A1_MUN)) + '",'
                    cResponse += '"uf":"' + EncodeUTF8(Alltrim(( cTemp )->A1_EST)) + '",'
                    cResponse += '"cep":"' + EncodeUTF8(Alltrim(( cTemp )->A1_CEP)) + '",'
                    cResponse += '"contato":"' + EncodeUTF8(Alltrim(( cTemp )->A1_CONTATO)) + '",'
                    cResponse += '"email":"' + EncodeUTF8(Alltrim(( cTemp )->A1_EMAIL)) + '",'
                    cResponse += '"tel":"' + EncodeUTF8(Alltrim(( cTemp )->A1_DDD + " - " + ( cTemp )->A1_TEL)) + '"}'
                EndIf
                cResponse += ', '

                cResponse += '"statusOs":"' + Alltrim(cStatus) + '",'
                cResponse += '"enviado":"' + "true" + '",'
                cResponse += '"tipoOs":"' + EncodeUTF8(cOcorrencia) +  '",'
                cResponse += '"entida":"' + EncodeUTF8( UPPER( ( cTemp )->ABB_ENTIDA) ) + '",'
                cResponse += '"ab7item":"",'
                cResponse += '"itensOs":['
                For nX := 1 To Len(aItens)
                    cLaudo := ""
                    cItDetail := '"laudo":""'
                    aItDetail := OsDetail((cTemp)->ABB_NUMOS, aItens[nX][1])
                    If(!EMPTY(aItDetail))
                        CaracEsp(aItDetail[5],@cLaudo)
                        cItDetail := '"laudo":"' + cLaudo + '"'  
                        If(!EMPTY(aItDetail[6]))
                            cAssinatura := aItDetail[6]
                        EndIf 
                        If(!EMPTY(aItDetail[7]))
                            cResponsavel := aItDetail[7]
                        EndIf          
                    EndIf
                    aOsAppoint := OsAponta((cTemp)->ABB_NUMOS+aItens[nX][1],::cAttendant)
                                     
                    //Produtos do apontamento
                    cOsAppoint := '"produtos":['
                    If(!EMPTY(aOsAppoint))
                        For nY := 1 to Len(aOsAppoint)
                            If nY > 1
                                cOsAppoint += ","
                            EndIf
                            cProd := ""
                            CaracEsp( EncodeUtf8(ALLTRIM(aOsAppoint[nY][2])), @cProd )
                            cOsAppoint += '{"codigo":"' + ALLTRIM(aOsAppoint[nY][1]) + '",'
                            cOsAppoint += '"codprodtroca":"' + ALLTRIM(aOsAppoint[nY][8]) + '",'
                            cOsAppoint += '"nome":"' + cProd + '",'
                            cOsAppoint += '"nomeprodtroca":"' + EncodeUtf8(ALLTRIM(aOsAppoint[nY][7])) + '",'
                            cOsAppoint += '"quant":' + cValToChar(aOsAppoint[nY][4]) + ','
                            cOsAppoint += '"troca":"' + aOsAppoint[nY][6] + '",'
                            cOsAppoint += '"servico":{"codigo":"","nome":""}}' 
                        Next nY
                    EndIf
                    cOsAppoint += '],'
                    cOsFotos := '"fotos":['
                    cOsFotos += '],'

                    If nX > 1
                        cResponse += ','
                    EndIf
                    cProd := ""
                    CaracEsp( EncodeUTF8( Alltrim( aItens[nX][2] ) ), @cProd ) 
                    cResponse += '{"numeroItem":"' + Alltrim(aItens[nX][1]) + '",'
                    cResponse += '"produto":"' + cProd + '",'
                    cResponse += '"codProd":"' + Alltrim(aItens[nX][9]) + '",'
                    cResponse += '"ID":"' + Alltrim(aItens[nX][3]) + '",'
                    cResponse += '"atendido":"' + Alltrim(aItens[nX][4]) + '",'
                    cResponse += '"dataAgend":"' + AllToChar(aItens[nX][5]) + '",'
                    cResponse += '"solicitaPeca":"' + AllToChar(aItens[nX][6]) + '",'
                    cResponse += '"PecaBaixada":"' + AllToChar(aItens[nX][7]) + '",'
                    cResponse += '"pecaRecebida":"' + ALLToChar(aItens[nX][8]) + '",'
                    cResponse += '"detailItem":"' + EncodeUTF8(ALLToChar(aItens[nX][10])) + '",'
                    cResponse += '"fullDetail":"' + EncodeUTF8(ALLToChar(aItens[nX][11])) + '",' 
                    cResponse += '"expandItem":"0",'
                    cResponse += '"apontamento": {'+cOsAppoint+cOsFotos+'"requisicao": "", '+cItDetail+'}}'
                Next nX
                cResponse += ' ], '
                cResponse += '"assinatura":"' + cAssinatura + '",'
                cResponse += '"responsavel":"' + cResponsavel + '",'
                cResponse += '"dtIniVisita":"' + Alltrim(( cTemp )->AB6_APPDTI) + '",'
                cResponse += '"hrIniVisita":"' + Alltrim(( cTemp )->AB6_APPHRI) + '",'
                cResponse += '"dtIniChegada":"' + Alltrim(( cTemp )->AB6_APPDCH) + '",'
                cResponse += '"hrIniChegada":"' + Alltrim(( cTemp )->AB6_APPHCH) + '",'
                cResponse += '"compartilhado":"' + cCompartilha + '"}'
            Else


                cOcorrencia := OsDetalhe((cTemp)->ABB_NUMOS,@aItens,( cTemp )->ABB_DTINI,( cTemp )->ABB_ENTIDA,::cAttendant,@cStatus)
                
                If OsCompartilha(( cTemp )->ABB_NUMOS,::cAttendant)
                    cCompartilha := "true"
                Else
                    cCompartilha := "false"
                EndIf
                For nX := 1 To Len(aItens)
                    cLaudo := ""
                    cItDetail := '"laudo":""'
                    aItDetail := OsDetail((cTemp)->ABB_NUMOS, aItens[nX][1])
                    If(!EMPTY(aItDetail))
                        CaracEsp(aItDetail[5],@cLaudo)
                        cItDetail := '"laudo":"' + cLaudo +'"' 
                        If(!EMPTY(aItDetail[6]))
                            cAssinatura := aItDetail[6]
                        EndIf 
                        If(!EMPTY(aItDetail[7]))
                            cResponsavel := aItDetail[7]
                        EndIf                  
                    EndIf
                    
                    aOsAppoint := OsAponta((cTemp)->ABB_NUMOS+aItens[nX][1],::cAttendant)

                    //Produtos do apontamento
                    cOsAppoint := '"produtos":['
                    For nY := 1 to Len(aOsAppoint)
                        If nY > 1
                            cOsAppoint += ","
                        EndIf
                        cProd := ""
                        CaracEsp( EncodeUtf8(ALLTRIM( aOsAppoint[nY][2] ) ), @cProd )
                        cOsAppoint += '{"codigo":"' + ALLTRIM(aOsAppoint[nY][1]) + '",'
                        cOsAppoint += '"codprodtroca":"' + ALLTRIM(aOsAppoint[nY][8]) + '",'
                        cOsAppoint += '"nome":"' + cProd + '",'
                        cOsAppoint += '"nomeprodtroca":"' + EncodeUtf8(ALLTRIM(aOsAppoint[nY][7])) + '",'
                        cOsAppoint += '"quant":' + cValToChar(aOsAppoint[nY][4]) + ','
                        cOsAppoint += '"troca":"' + aOsAppoint[nY][6] + '",'
                        cOsAppoint += '"servico":{"codigo":"","nome":""}}' 
                    Next nY
                    cOsAppoint += '],'
                    cOsFotos := '"fotos":['
                    cOsFotos += '],'
                    cResponse += '{"horaIni":"' + Alltrim(aItens[nX][11][5]) + '",'
                    cResponse += '"horaFim":"' + Alltrim(aItens[nX][11][6]) + '",'
                    cResponse += '"numOS":"' + Alltrim(( cTemp )->ABB_NUMOS) + '",'
                    cResponse += '"filialOS":"' + Alltrim(( cTemp )->AB6_FILIAL) + '",'
                    cResponse += '"cliente":"' + EncodeUTF8(Alltrim(( cTemp )->A1_NOME)) + '",'
                    cResponse += '"endereco":'
                    If aItens[nX][11][9]
                        cResponse += '{"logradouro":"' + EncodeUTF8(Alltrim(aItens[nX][11][10][1])) + '",'
                        cResponse += '"bairro":"' + EncodeUTF8(Alltrim(aItens[nX][11][10][2])) + '",'
                        cResponse += '"cidade":"' + EncodeUTF8(Alltrim(aItens[nX][11][10][3])) + '",'
                        cResponse += '"uf":"' + EncodeUTF8(Alltrim(aItens[nX][11][10][4])) + '",'
                        cResponse += '"cep":"' + EncodeUTF8(Alltrim(aItens[nX][11][10][5])) + '",'
                        If aItens[nX][11][10][10]                            
                            cResponse += '"contato":"' + EncodeUTF8(Alltrim(aItens[nX][11][10][6])) + '",'
                            cResponse += '"email":"' + EncodeUTF8(Alltrim(aItens[nX][11][10][9])) + '",'
                            cResponse += '"tel":"' + EncodeUTF8(Alltrim(aItens[nX][11][10][7] + " - " + aItens[nX][11][10][8])) + '"}'
                        Else
                            cResponse += '"contato":"' + EncodeUTF8(Alltrim(( cTemp )->A1_CONTATO)) + '",'
                            cResponse += '"email":"' + EncodeUTF8(Alltrim(( cTemp )->A1_EMAIL)) + '",'
                            cResponse += '"tel":"' + EncodeUTF8(Alltrim(( cTemp )->A1_DDD + " - " + ( cTemp )->A1_TEL)) + '"}'
                        EndIf
                    Else 
                        cResponse += '{"logradouro":"' + EncodeUTF8(Alltrim(( cTemp )->A1_END)) + '",'
                        cResponse += '"bairro":"' + EncodeUTF8(Alltrim(( cTemp )->A1_BAIRRO)) + '",'
                        cResponse += '"cidade":"' + EncodeUTF8(Alltrim(( cTemp )->A1_MUN)) + '",'
                        cResponse += '"uf":"' + EncodeUTF8(Alltrim(( cTemp )->A1_EST)) + '",'
                        cResponse += '"cep":"' + EncodeUTF8(Alltrim(( cTemp )->A1_CEP)) + '",'
                        cResponse += '"contato":"' + EncodeUTF8(Alltrim(( cTemp )->A1_CONTATO)) + '",'
                        cResponse += '"email":"' + EncodeUTF8(Alltrim(( cTemp )->A1_EMAIL)) + '",'
                        cResponse += '"tel":"' + EncodeUTF8(Alltrim(( cTemp )->A1_DDD + " - " + ( cTemp )->A1_TEL)) + '"}'
                    EndIf
                    cResponse += ', '
                    cResponse += '"statusOs":"' + Alltrim(aItens[nX][11][8]) + '",'
                    cResponse += '"enviado":"' + "true" + '",'
                    cResponse += '"tipoOs":"' + EncodeUTF8(aItens[nX][11][11]) +  '",'
                    cResponse += '"entida":"' + EncodeUTF8( UPPER( ( cTemp )->ABB_ENTIDA) ) + '",'
                    cResponse += '"ab7item":"' + aItens[nX][11][7] + '",'
                    cProd := ""
                    CaracEsp( EncodeUTF8( Alltrim( aItens[nX][2] ) ) , @cProd )
                    cResponse += '"itensOs":['
                    cResponse +=    '{"numeroItem":"' + Alltrim(aItens[nX][1]) + '",'
                    cResponse +=        '"produto":"' + cProd + '",'
                    cResponse +=        '"codProd":"' + Alltrim(aItens[nX][9]) + '",'
                    cResponse +=        '"ID":"' + Alltrim(aItens[nX][3]) + '",'
                    cResponse +=        '"atendido":"' + Alltrim(aItens[nX][4]) + '",'
                    cResponse +=        '"dataAgend":"' + AllToChar(aItens[nX][5]) + '",'
                    cResponse +=        '"solicitaPeca":"' + AllToChar(aItens[nX][6]) + '",'
                    cResponse +=        '"PecaBaixada":"' + AllToChar(aItens[nX][7]) + '",'
                    cResponse +=        '"pecaRecebida":"' + ALLToChar(aItens[nX][8]) + '",'
                    cResponse +=        '"detailItem":"' + EncodeUTF8(ALLToChar(aItens[nX][10])) + '",'
                    cResponse +=        '"fullDetail":"' + EncodeUTF8(ALLToChar(aItens[nX][12])) + '",'
                    cResponse +=        '"expandItem":"0",' 
                    cResponse += '"apontamento":{'
                    cResponse += cOsAppoint
                    cResponse += cOsFotos
                    cResponse += '"requisicao":"",'
                    cResponse += cItDetail //laudo
                    cResponse += '}}'
                    cResponse +=  ' ], '
                    cResponse += '"assinatura":"' + cAssinatura + '",'
                    cResponse += '"responsavel":"' + cResponsavel + '",'
                    cResponse += '"dtIniVisita":"' + Alltrim(aItens[nX][11][1]) + '",'
                    cResponse += '"hrIniVisita":"' + Alltrim(aItens[nX][11][2]) + '",'
                    cResponse += '"dtIniChegada":"' + Alltrim(aItens[nX][11][3]) + '",'
                    cResponse += '"hrIniChegada":"' + Alltrim(aItens[nX][11][4]) + '",'
                    cResponse += '"compartilhado":"' + cCompartilha + '"}'
                    If nX < Len(aItens)
                        cResponse += ','
                    EndIf
                Next nX
            EndIf
            ( cTemp )->( DBSkip() )
        EndDo

        cResponse += ' ], '
        cResponse += '"count": ' +cBIStr( nRecord ) + ' } '
        nStatusCode	:= 200
    Else
        nStatusCode	:= 204
        cMessage := STR0036 //"Não há ordens de serviço para esse dia"
    EndIf
(cTemp)->(dbCloseArea())
EndIf

If lRet
    Self:SetResponse( cResponse)
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

Return lRet

WSMETHOD GET productsPages WSRECEIVE nPageSize WSREST meutecnico

Local cTemp             := GetNextAlias()
Local cResponse		    := '{ "pages": 0 }'
Local cMessage          := ""
Local nPageSize         := 10
Local cQuery            := ""
Local nQtdReg           := 0
Local nPages            := 0
Local nStatusCode       := 500

::SetContentType("application/json")

If VALTYPE(Self:nPageSize) <> NIL .AND. Self:nPageSize > 10
     nPageSize := Self:nPageSize
EndIf  

cQuery := "SELECT COUNT(1) TOTAL "
cQuery += "FROM " + retSqlName('SB1') + " SB1 "
cQuery += "WHERE SB1.B1_FILIAL = '"+xFilial("SB1") + "' "
cQuery += "AND SB1.D_E_L_E_T_ = ' ' "

cAliasQry := GetNextAlias()
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTemp, .F., .T.)

If ( cTemp )->( !Eof() )
    nPages := (cTemp)->TOTAL
EndIf

If nPages == Nil
    nStatusCode := 500
    cMessage := 'Erro ao realizar a requisição de produtos'
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )  
Else
    cResponse := '{"pages":'+cValToChar(CEILING(nPages/nPageSize))+'}'
    Self:SetResponse( cResponse )
EndIf

Return .T.
//------------------------------------------------------------------------------
/*/{Protheus.doc} getProduct

Serviços para selecionar os produtos utilizados no atendimento da ordem de serviço

@author     Luiz Gabriel
@since      14/08/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD GET getProduct WSRECEIVE cSearchTerm, nPage, nPageSize WSREST meutecnico
Local lRet              := .T.
Local cTemp             := GetNextAlias()
Local cResponse		    := '{ "Produto":[], "count": 0 }'
Local cMessage          := "Internal Server Error"
Local nStatusCode       := 500
Local nRecord           := 0
Local nPage             := 1
Local nPageSize         := 10
Local nQtdRegIni        := 0
Local nQtdRegFim        := 0
Local nQtdReg           := 0
Local lHasNext          := .F.
Local cSearchTerm       := ""
Local cQuery            := ""
Local cDescExp          := ""
Local lProduct          := SB1->(ColumnPos("B1_TECAPP")) > 0

// define o tipo de retorno do método
::SetContentType("application/json")

If VALTYPE(Self:nPage) <> NIL .AND. Self:nPage > 1
     nPage := Self:nPage
EndIf

If VALTYPE(Self:nPageSize) <> NIL .AND. Self:nPageSize > 10
     nPageSize := Self:nPageSize
EndIf  

If VALTYPE(Self:cSearchTerm) <> NIL
    cSearchTerm = Self:cSearchTerm
EndIf

nQtdRegIni := (nPage-1) * nPageSize
nQtdRegFim := nPage * nPageSize

cQuery := "SELECT B1_COD, B1_DESC "
cQuery += "FROM " + retSqlName('SB1') + " SB1 "
cQuery += "WHERE SB1.B1_FILIAL = '"+xFilial("SB1") + "' "

If lProduct
    cQuery += "AND  SB1.B1_TECAPP != '2' " 
EndIf 

If !Empty(cSearchTerm)
    cQuery += "AND B1_DESC LIKE '%"+cSearchTerm+"%' "
EndIf

cQuery += " AND SB1.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

cAliasQry := GetNextAlias()
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTemp, .F., .T.)

If ( cTemp )->( !Eof() )
    ( cTemp )->( DBGoTop() )

    lRet := .T.

    cResponse := ''
    cResponse := '{"Produto":['
    While ( cTemp )->( !Eof() )
        nQtdReg++
            If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
            nRecord++

            If nRecord > 1
                cResponse += ','
            EndIf

            cResponse += '{"codigo":"' + Alltrim(( cTemp )->B1_COD) + '",'
            If CaracEsp(EncodeUTF8(Alltrim(( cTemp )->B1_DESC)),@cDescExp)
                cResponse += '"nome":"' + cDescExp + '"}'
            Else
                cResponse += '"nome":"' + EncodeUTF8(Alltrim(( cTemp )->B1_DESC)) + '"}'
            EndIf    
        ElseIf  (nQtdReg == nQtdRegFim + 1)
            lHasNext := .T.
            Exit   
        EndIf
        ( cTemp )->( DBSkip() )
    EndDo
        If lHasNext
            cResponse += ' ],"hasNext": "true", '
        Else
            cResponse += ' ], "hasNext": "false", '
        EndIf
        cResponse += '"count": ' +cBIStr( nRecord ) + ' } '
        nStatusCode	:= 200
Else
    lRet := .F.
    nStatusCode := 401
    cMessage 	:= STR0022 //"Nenhum produto encontrado"
EndIf

(cTemp)->(dbCloseArea())

If lRet
        cResponse := StrTran( cResponse, '\', '\\' )
        cResponse := StrTran( cResponse, '\\n', '\n' ) 
    Self:SetResponse( cResponse )
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} getService

Serviços para selecionar os serviços utilizados no atendimento da ordem de serviço

@author     Luiz Gabriel
@since      14/08/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD GET getService WSREST meutecnico
Local lRet              := .T.
Local cTemp             := GetNextAlias()
Local cResponse		    := '{ "Service":[], "count": 0 }'
Local cMessage          := "Internal Server Error"
Local nStatusCode       := 500
Local nRecord           := 0
Local cDescExp          := ""

// define o tipo de retorno do método
::SetContentType("application/json")

BeginSQL Alias cTemp
        
    SELECT 
        AA5_CODSER, AA5_DESCRI
    FROM 	
        %Table:AA5% AA5
    WHERE 
        AA5.AA5_FILIAL = %Exp:xFilial("AA5")% AND
        AA5.%NotDel%
EndSql

If ( cTemp )->( !Eof() )
    ( cTemp )->( DBGoTop() )

    lRet := .T.

    cResponse := ''
    cResponse := '{"Service":['
    While ( cTemp )->( !Eof() )

        nRecord++

        If nRecord > 1
            cResponse += ','
        EndIf

        cResponse += '{"codigo":"' + Alltrim(( cTemp )->AA5_CODSER) + '",'
        If CaracEsp(EncodeUTF8(Alltrim(( cTemp )->AA5_DESCRI)),@cDescExp)
            cResponse += '"nome":"' + cDescExp + '"}'
        Else
            cResponse += '"nome":"' + EncodeUTF8(Alltrim(( cTemp )->AA5_DESCRI)) + '"}'
        EndIf    
        ( cTemp )->( DBSkip() )
    EndDo

        cResponse += ' ], '
        cResponse += '"count": ' +cBIStr( nRecord ) + ' } '
        nStatusCode	:= 200
Else
    lRet := .F.
    nStatusCode := 401
    cMessage 	:= STR0023 //"Nenhum serviço encontrado"
EndIf

(cTemp)->(dbCloseArea())

If lRet
    Self:SetResponse( cResponse )
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} getHistoric

Serviços para retornar as ordens de serviço de um determinado equipamento

@author     Luiz Gabriel
@since      14/08/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD GET getHistoric WSRECEIVE cEquipament, cID, cStartDt, cEndDt, nPerHist WSREST meutecnico
Local lRet              := .T.
Local cTemp             := GetNextAlias()
Local cResponse		    := '{ "Historic":[], "count": 0 }'
Local cMessage          := "Internal Server Error"
Local nStatusCode       := 500
Local nRecord           := 0
Local cDtIni            := ''
Local cDtFim            := ''
Local nPeriodo          := 60

// define o tipo de retorno do método
::SetContentType("application/json;charset=UTF-8")

If !Empty(Self:nPerHist)
    nPeriodo := Self:nPerHist
EndIf

If Empty(Self:cStartDt)
    cDtIni := DTOS(dDataBase - nPeriodo)
Else
    cDtIni := Self:cStartDt
EndIf

If Empty(Self:cEndDt)
    cDtFim := DTOS(dDataBase)
Else
    cDtFim := Self:cEndDt
EndIf

If Empty(Self:cEquipament)
    lRet            := .F.
    nStatusCode     := 400
    cMessage        := STR0030 //"Informe um equipamento para a consulta"
EndIf

If Empty(Self:cID)
    lRet            := .F.
    nStatusCode     := 400
    cMessage        := STR0031 //"Informe o Id Unico do equipamento para a consulta"
EndIf

If lRet
    BeginSQL Alias cTemp
            
        SELECT 
            AB6.AB6_EMISSA,
	        AB6.AB6_APPSTA,
	        AB7.AB7_NUMOS,
            AB7.AB7_ITEM,
	        AB7.AB7_CODPRO,
	        AB7.AB7_NUMSER,
	        AB7.AB7_CODPRB
	    FROM %Table:AB7% AB7 
	        INNER JOIN %Table:AB6% AB6 ON
	            AB6.AB6_FILIAL = %Exp:xFilial("AB6")% AND 
	            AB6_NUMOS = AB7_NUMOS AND 
	            AB6.%NotDel% 
	    WHERE
            AB7.AB7_FILIAL = %Exp:xFilial("AB7")% AND 
	        AB7.AB7_CODPRO = %Exp:Self:cEquipament% AND 
            AB6.AB6_EMISSA BETWEEN %Exp:cDtIni% AND %Exp:cDtFim% AND
	        AB7.AB7_NUMSER = %Exp:Self:cID% AND
            AB7.%NotDel%
        ORDER BY AB6.AB6_EMISSA DESC

    EndSql

    If ( cTemp )->( !Eof() )
        ( cTemp )->( DBGoTop() )

        lRet := .T.

        cResponse := ''
        cResponse := '{"Historic":['
        While ( cTemp )->( !Eof() )

            nRecord++

            If nRecord > 1
                cResponse += ','
            EndIf

            cResponse += '{"dataAbertura":"' + Alltrim(( cTemp )->AB6_EMISSA) + '",'
            cResponse += '"statusOs":"' + X3Combo("AB6_APPSTA", Alltrim(( cTemp )->AB6_APPSTA)) + '",'
            cResponse += '"numOs":"' + Alltrim(( cTemp )->AB7_NUMOS) + '",'
            cResponse += '"itemOS":"' + Alltrim(( cTemp )->AB7_ITEM) + '",'
            cResponse += '"equipamento":"' + StrTran(Alltrim(( cTemp )->AB7_CODPRO),'\','\\') + '",'
            cResponse += '"nomeEquipamento":"' + StrTran(EncodeUTF8(Alltrim( Posicione("SB1",1,xFilial("SB1")+( cTemp )->AB7_CODPRO,"B1_DESC") )),'\','\\') + '",'
            cResponse += '"idUnico":"' + Alltrim(( cTemp )->AB7_NUMSER) + '",'
            cResponse += '"ocorrencia":"' + EncodeUTF8(Alltrim(Alltrim( Posicione("AAG",1,xFilial("AAG")+( cTemp )->AB7_CODPRB,"AAG_DESCRI") ))) + '"}'

            ( cTemp )->( DBSkip() )
        EndDo

            cResponse += ' ], '
            cResponse += '"count": ' +cBIStr( nRecord ) + ' } '
            nStatusCode	:= 200
    Else
        lRet := .F.
        nStatusCode := 204
        cMessage 	:= STR0032 //"Nenhuma ordem de serviço foi encontrada para esse equipamento"
    EndIf

EndIf

(cTemp)->(dbCloseArea())

If lRet
    Self:SetResponse( cResponse )
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} getDetail

Serviços para listar os detalhes de atendimento das ordens de serviço

@author     Luiz Gabriel
@since      14/08/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD GET getDetail WSRECEIVE cNumOS, cItemOS WSREST meutecnico
Local lRet              := .T.
Local cTemp             := GetNextAlias()
Local cResponse		    := '{ "Detail":[], "count": 0 }'
Local cMessage          := "Internal Server Error"
Local nStatusCode       := 500
Local nRecord           := 0
Local aItens            := {}
Local nX                := 0
Local cChave            := ""
Local cLaudo            := ""

// define o tipo de retorno do método
::SetContentType("application/json;charset=UTF-8")

If Empty(Self:cNumOS)
    lRet            := .F.
    nStatusCode     := 400
    cMessage        := STR0033 //"Informe uma ordem de serviço para ser detalhada"
EndIf

If Empty(Self:cItemOS)
    lRet            := .F.
    nStatusCode     := 400
    cMessage        := STR0034 //"Informe o item da ordem de serviço a ser pesquisada"
EndIf

If lRet
    cChave := Self:cNumOS+Self:cItemOS
    BeginSQL Alias cTemp
            
        SELECT 
            AB9.AB9_NUMOS,
            AB9.AB9_CODTEC,
            AB9.AB9_DTINI,
            AB9.AB9_HRINI,
            AB9.AB9_DTFIM,
            AB9.AB9_HRFIM,
            AB9.AB9_MEMO1,
            AB9.AB9_CODPRB
        FROM %Table:AB9% AB9 
        WHERE
            AB9.AB9_FILIAL = %Exp:xFilial("AB9")% AND 
	        AB9.AB9_NUMOS = %Exp:cChave% AND 
            AB9.%NotDel%

    EndSql

    If ( cTemp )->( !Eof() )
        ( cTemp )->( DBGoTop() )

        lRet := .T.

        cResponse := ''
        cResponse := '{"Detail":['
        While ( cTemp )->( !Eof() )
            cLaudo := ""
            nRecord++

            If nRecord > 1
                cResponse += ','
            EndIf

            aItens := {}
            //verifica os itens apontados para o atendimento da ordem de serviço
            aItens := OsAponta((cTemp)->AB9_NUMOS,(cTemp)->AB9_CODTEC)
            CaracEsp(EncodeUtf8(LerMemo(( cTemp )->AB9_MEMO1)),@cLaudo)
            cResponse += '{"atendente":"' + EncodeUTF8(Alltrim(Posicione("AA1",1,xFilial("AA1")+( cTemp )->AB9_CODTEC,"AA1_NOMTEC"))) + '",'
            cResponse += '"dtInicio":"' + Alltrim(( cTemp )->AB9_DTINI) + '",'
            cResponse += '"hrInicio":"' + Alltrim(( cTemp )->AB9_HRINI) + '",'
            cResponse += '"dtFim":"' + Alltrim(( cTemp )->AB9_DTFIM) + '",'
            cResponse += '"hrFim":"' + Alltrim(( cTemp )->AB9_HRFIM) + '",'
            cResponse += '"laudo":"' + cLaudo + '",'
            cResponse += '"itensApontados":['
            For nX := 1 To Len(aItens)
                If nX > 1
                    cResponse += ','
                EndIf
                cResponse += '{"produto":"' + EncodeUtf8(Alltrim(aItens[nX][1])) + '",'
                cResponse += '"nomeProduto":"' + EncodeUtf8(Alltrim(aItens[nX][2])) + '",'
                cResponse += '"id":"' + Alltrim(aItens[nX][3]) + '",'
                cResponse += '"quantidade":"' + Alltrim(AllToChar(aItens[nX][4])) + '",'
                cResponse += '"houveTroca":"' + Alltrim(aItens[nX][6]) + '",'
                cResponse += '"produtoTroca":"' + EncodeUtf8(Alltrim(aItens[nX][7])) + '",'
                cResponse += '"nomeProdutoTroca":"' + EncodeUTF8(Alltrim( Posicione("SB1",1,xFilial("SB1")+aItens[nX][7],"B1_DESC") )) + '",'
                cResponse += '"IdTroca":"' + Alltrim(aItens[nX][8]) + '",'
                cResponse += '"servico":"' + EncodeUtf8(AllTrim(Posicione("AA5",1,xFilial("AA5")+aItens[nX][5],"AA5_DESCRI"))) + '"}'
            Next nX
            cResponse += ' ], '
            cResponse += '"ocorrencia":"' + Alltrim( EncodeUtf8(Posicione("AAG",1,xFilial("AAG")+( cTemp )->AB9_CODPRB,"AAG_DESCRI") )) + '"}'

            ( cTemp )->( DBSkip() )
        EndDo

            cResponse += ' ], '
            cResponse += '"count": ' +cBIStr( nRecord ) + ' } '
            nStatusCode	:= 200
    Else
        lRet := .F.
        nStatusCode := 204
        cMessage 	:= STR0035 //"Nenhum atendimento para a ordem de serviço foi encontrado"
    EndIf

EndIf

(cTemp)->(dbCloseArea())

If lRet
    Self:SetResponse( cResponse )
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} putStatus

Serviços para atualizar o status da ordem de serviço

@author     Luiz Gabriel
@since      14/08/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD PUT putStatus WSREST meutecnico
Local lRet          := .T.
Local cBody	        := ""
Local oOppJson      := Nil
Local nStatusCode	:= 500
Local cMessage	    := "Internal Server Error"

cBody := Self:GetContent()

If !Empty( cBody )

    FWJsonDeserialize(cBody,@oOppJson)

    If !Empty( oOppJson )
        If !Empty(oOppJson:STATUS:numOs) .And. !Empty(oOppJson:STATUS:statusOs)
            If AtualizaOS(oOppJson:STATUS:numOs,oOppJson:STATUS:statusOs,;
                    oOppJson:STATUS:dtIniVisita,oOppJson:STATUS:hrIniVisita,;
                    oOppJson:STATUS:dtIniChegada,oOppJson:STATUS:hrIniChegada,oOppJson:STATUS:entida,oOppJson:STATUS:ab7item)
                cResponse		:= '{"sucessCode":200,"sucessMessage": "' + STR0013 + '"}' //Ordem de Serviço Atualizado com sucesso
            Else
                lRet		:= .F.
                nStatusCode := 400
                cMessage	:= STR0014 //"Ordem de Serviço não encontrada"
            EndIf
        Else
            cMessage	:= STR0015 //"Parametro não encontrados, verique o corpo da requisição"
            nStatusCode	:= 400
        EndIf
    EndIf
Else
    cMessage	:= STR0016 //"Dados não encontrados no corpo da requisicao."
    nStatusCode	:= 400
EndIf

If 	lRet
    Self:SetResponse( EncodeUTF8(cResponse) )
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} putEnceramento

Serviços para atualizar o status da ordem de serviço

@author     Luiz Gabriel
@since      14/08/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD PUT putEnceramento WSREST meutecnico
Local lRet          := .T.
Local cBody	        := ""
Local oOppJson      := Nil
Local nStatusCode	:= 500
Local cMessage	    := "Internal Server Error"
Local cResponse     := ""
Local nX            := 0
Local cErrorMsg     := ""

cBody := Self:GetContent()

If !Empty( cBody )

    FWJsonDeserialize(cBody,@oOppJson)

    If !Empty( oOppJson )
        If CheckParam( oOppJson, @cMessage )
            //Incluindo requisições
            For nX := 1 To Len(oOppJson:ITENSOS)
                IF VALTYPE(oOppJson:ITENSOS[nX]:APONTAMENTO) == "O" .AND. VALTYPE(oOppJson:ITENSOS[nX]:APONTAMENTO:REQUISICAO) == "O"
                    IncReqOS(oOppJson:CODTEC, oOppJson:NUMOS, oOppJson:ITENSOS[nX]:NUMEROITEM, oOppJson:ITENSOS[nX]:APONTAMENTO:REQUISICAO:PRODUTOS )
                ENDIF
            Next nX
            If EncerraOs( oOppJson, @cErrorMsg )
                cResponse		:= '{"sucessCode":200,"sucessMessage": "' + STR0013 + '"}' //Ordem de Serviço Atualizado com sucesso
            Else
                lRet		:= .F.
                nStatusCode := 400
                cMessage	:= STR0162+CRLF+cErrorMsg //"Erro ao encerrar a ordem de serviço"
            EndIf
        Else
            nStatusCode	:= 400
            cMessage	:= STR0162+CRLF+cMessage //"Erro ao encerrar a ordem de serviço"
        EndIf
    EndIf
Else
    lRet    := .F.
    cMessage	:= STR0016 //"Dados não encontrados no corpo da requisicao."
    nStatusCode	:= 400
EndIf

If 	lRet
    Self:SetResponse( EncodeUTF8(cResponse) )
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} putRequest

Serviços para realizar requisição na ordem de serviço

@author     Luiz Gabriel
@since      14/08/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD PUT putRequest WSREST meutecnico
Local lRet          := .T.
Local cBody	        := ""
Local oOppJson      := Nil
Local nStatusCode	:= 500
Local cMessage	    := "Internal Server Error"

cBody := Self:GetContent()

If !Empty( cBody )

    FWJsonDeserialize(cBody,@oOppJson)

    If !Empty( oOppJson )
        If IncRequisicao( oOppJson )
            cResponse		:= '{"sucessCode":200,"sucessMessage": "' + STR0025 + '"}' //"Requisição da Ordem de Serviço Atualizado com sucesso"
        Else
            lRet		:= .F.
            nStatusCode := 400
            cMessage	:= STR0014 //"Ordem de Serviço não encontrada"
        EndIf
    EndIf
Else
    lRet    := .F.
    cMessage	:= STR0016 //"Dados não encontrados no corpo da requisicao."
    nStatusCode	:= 400
EndIf

If 	lRet
    Self:SetResponse( EncodeUTF8(cResponse) )
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} postsolicitation

Atualizar o atendimento e informar o produto solicitado

@author     Luiz Gabriel
@since      14/08/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD POST postsolicitation WSREST meutecnico
Local lRet          := .T.
Local cBody	        := ""
Local oOppJson      := Nil
Local nStatusCode	:= 500
Local cMessage	    := "Internal Server Error"

cBody := Self:GetContent()

If !Empty( cBody )

    FWJsonDeserialize(cBody,@oOppJson)

    If !Empty( oOppJson )
        If AtuRequisicao( oOppJson )
            cResponse		:= '{"sucessCode":200,"sucessMessage": "' + STR0025 + '"}' //"Requisição Atualizado com sucesso"
        Else
            lRet		:= .F.
            nStatusCode := 400
            cMessage	:= STR0027 //"requisição não encontrada"
        EndIf
    EndIf
Else
    lRet    := .F.
    cMessage	:= STR0016 //"Dados não encontrados no corpo da requisicao."
    nStatusCode	:= 400
EndIf

If 	lRet
    Self:SetResponse( EncodeUTF8(cResponse) )
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} OsCompartilha

Função para verificar se mais de 1 atendente está alocado para a mesma O.S

@author     Luiz Gabriel
@since      14/08/2020
/*/
//------------------------------------------------------------------------------
Static Function OsCompartilha(cCodOS,cCodAtend)
Local lRet  := .F.
Local cTemp := GetNextAlias()

BeginSQL Alias cTemp
    SELECT
        ABB_CODTEC
    FROM %Table:ABB% ABB
    WHERE
        ABB.ABB_FILIAL = %Exp:xFilial("ABB")%
        AND ABB.ABB_CODTEC <> %Exp:cCodAtend%
        AND ABB.ABB_NUMOS = %Exp:cCodOS%
        AND ABB.%NotDel%        
EndSQL

If ( cTemp )->( !Eof() )
    lRet := .T.
EndIf

(cTemp)->(dbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} OsDetalhe

Retorna os detalhes dos itens da ordem de serviço

@author     Luiz Gabriel
@since      14/08/2020
/*/
//------------------------------------------------------------------------------
Static Function OsDetalhe(cCodOs, aItens, dData,cEntida,cAttendant,cStatus, aLocal)
Local cOcorrencia   := ""
Local cCodOcor      := ""
Local nOcor         := 0
Local cTemp         := GetNextAlias()
Local cData         := ""
Local aReq          := {}
Local cAtendido     := ""
Local cMemo         := ""  // Campo memo cortado (...)
Local cMemoF        := ""  // Campo memo completo
Local aAb7Fld       := {}
Local lEndCli       := .T.
Local lLocIg        := .T.
Local cLocal        := ""
Local aEndBase      := {}
Default cStatus     := ""

If Upper(cEntida) == "AB6"
    BeginSQL Alias cTemp
    SELECT
        AB7_NUMOS,
        AB7_ITEM,
        AB7_TIPO,
        B1_DESC,
        AB7_CODPRB,
        AB7_CODPRO,
        AB7_MEMO1,
        AB7_NUMSER,
        AA3.AA3_CODLOC
    FROM %Table:AB7% AB7
        INNER JOIN %Table:AA3% AA3 ON 
            AA3.AA3_FILIAL = %Exp:xFilial("AA3")%
            AND AA3.AA3_NUMSER = AB7.AB7_NUMSER
            AND AA3.AA3_CODPRO = AB7.AB7_CODPRO
            AND AA3.%NotDel% 
        INNER JOIN %Table:SB1% SB1 ON
            AB7.AB7_CODPRO = B1_COD 
            AND SB1.B1_FILIAL =  %Exp:xFilial("SB1")%
            AND SB1.%NotDel%
    WHERE
        AB7.AB7_FILIAL = %Exp:xFilial("AB7")%
        AND AB7.AB7_NUMOS = %Exp:cCodOS%
        AND AB7.%NotDel%
        ORDER BY AB7.AB7_ITEM ASC        
    EndSQL

    If ( cTemp )->( !Eof() )

        While ( cTemp )->AB7_NUMOS == cCodOS

            If Empty(cLocal)
                cLocal := ( cTemp )->AA3_CODLOC
                cNumSer := ( cTemp )->AB7_NUMSER
                cCodProd := ( cTemp )->AB7_CODPRO
            ElseIf cLocal <> ( cTemp )->AA3_CODLOC
                lLocIg := .F.                     
            EndIf

            cMemo   := ""
            cMemoF  := ""
            If !Empty(( cTemp )->AB7_MEMO1)      
                CaracEsp(LerMemo(( cTemp )->AB7_MEMO1,256),@cMemo)
                CaracEsp(LerMemo(( cTemp )->AB7_MEMO1),@cMemoF)
            EndIf
            If Empty(cCodOcor)
                cCodOcor := ( cTemp )->AB7_CODPRB
            EndIf
            If ( cTemp )->AB7_TIPO == "4"
                cAtendido := "true"
            Else
                cAtendido := "false"
            EndIf    
            cData   := Left(DToC(dData), 6) + cValtoChar(Year(dData))
            aReq    := ChecaReq(( cTemp )->AB7_NUMOS,( cTemp )->AB7_ITEM,cAttendant,cAtendido)
            aAdd(aItens,{( cTemp )->AB7_ITEM,;
                            ( cTemp )->B1_DESC,;
                            ( cTemp )->AB7_NUMSER,;
                            cAtendido,;
                            cData,;
                            aReq[1],;
                            aReq[2],;
                            aReq[3],;
                            ( cTemp )->AB7_CODPRO,;
                            cMemo,;
                            cMemoF;
                        })
            If cCodOcor == ( cTemp )->AB7_CODPRB
                nOcor := 1
                cCodOcor := ( cTemp )->AB7_CODPRB
            Else
                nOcor := 2
                cCodOcor := ( cTemp )->AB7_CODPRB
            EndIf
            ( cTemp )->( DBSkip() )
        EndDo
        If lLocIg  
            aLocal := BaseDetail( cNumSer,cCodProd, @lEndCli)
        EndIf
    EndIf
    (cTemp)->(dbCloseArea())
ElseIf Upper(cEntida) == "AB7"
    BeginSQL Alias cTemp
    SELECT
        ABB.ABB_HRINI,
        ABB.ABB_HRFIM,
        ABB.ABB_DTINI,
        ABB.ABB_ENTIDA,
        ABB.ABB_NUMOS,
        ABB.ABB_CHAVE,
        AB7.AB7_NUMOS,
        AB7.AB7_ITEM,
        AB7.AB7_CODPRB,
        AB7.AB7_CODPRO,
        AB7.AB7_MEMO1,
        AB7.AB7_APPSTA,
        AB7.AB7_APPDTI,
        AB7.AB7_APPHRI,
        AB7.AB7_APPDCH,
        AB7.AB7_APPHCH,
        AB7.AB7_TIPO,
        AB7.AB7_NUMSER,
        B1_DESC
    FROM %Table:ABB% ABB
    INNER JOIN %Table:AB7% AB7 ON
        AB7.AB7_FILIAL = %Exp:xFilial("AB7")%
        AND AB7.AB7_NUMOS = ABB.ABB_NUMOS
        AND AB7.AB7_NUMOS + AB7.AB7_ITEM = ABB_CHAVE
        AND AB7.%NotDel% 
    INNER JOIN %Table:SB1% SB1 ON
        AB7.AB7_CODPRO = B1_COD 
        AND SB1.B1_FILIAL = %Exp:xFilial("SB1")%
        AND SB1.%NotDel%
    WHERE
        ABB.ABB_FILIAL = %Exp:xFilial("ABB")%
        AND ABB.ABB_NUMOS = %Exp:cCodOS%
        AND ABB.ABB_DTINI = %Exp:dToS(dData)%
        AND ABB.ABB_CODTEC = %Exp:cAttendant%
        AND ABB.%NotDel% 
    EndSQL

    If ( cTemp )->( !Eof() )
        cStatus := X3Combo("AB7_APPSTA", Alltrim(( cTemp )->AB7_APPSTA))
        if cStatus == ""
            cStatus = "Aberto"
        EndIf
        
        While ( cTemp )->ABB_NUMOS == cCodOS
            aEndBase := BaseDetail( ( cTemp )->AB7_NUMSER,( cTemp )->AB7_CODPRO, @lEndCli)
            cStatus := X3Combo("AB7_APPSTA", Alltrim(( cTemp )->AB7_APPSTA))
            if cStatus == ""
                cStatus = "Aberto"
            EndIf
            cMemo   := ""
            cMemoF  := ""
            aAb7Fld := {}
            AADD(aAb7Fld,( cTemp )->AB7_APPDTI)         //1
            AADD(aAb7Fld,( cTemp )->AB7_APPHRI)         //2
            AADD(aAb7Fld,( cTemp )->AB7_APPDCH)         //3
            AADD(aAb7Fld,( cTemp )->AB7_APPHCH)         //4
            AADD(aAb7Fld,( cTemp )->ABB_HRINI)          //5
            AADD(aAb7Fld,( cTemp )->ABB_HRFIM)          //6
            AADD(aAb7Fld,ALLTrim(( cTemp )->AB7_ITEM))  //7
            AADD(aAb7Fld,cStatus)                       //8
            AADD(aAb7Fld,lEndCli)                       //9
            AADD(aAb7Fld,aEndBase)                      //10
            AADD(aAb7Fld,Alltrim( Posicione("AAG",1,xFilial("AAG")+( cTemp )->AB7_CODPRB,"AAG_DESCRI") ))                      //11
            If !Empty(( cTemp )->AB7_MEMO1)      
                CaracEsp(LerMemo(( cTemp )->AB7_MEMO1,256),@cMemo)
                CaracEsp(LerMemo(( cTemp )->AB7_MEMO1),@cMemoF)
            EndIf

            If ( cTemp )->AB7_TIPO == "4"
                cAtendido := "true"
            Else
                cAtendido := "false"
            EndIf   

            If Empty(cCodOcor)
                cCodOcor := ( cTemp )->AB7_CODPRB
            EndIf
            cData := Left(DToC(dData), 6) + cValtoChar(Year(dData))
            aReq  := ChecaReq(( cTemp )->AB7_NUMOS,( cTemp )->AB7_ITEM,cAttendant,cAtendido)
            aAdd(aItens,;
                    {( cTemp )->AB7_ITEM,; // 1
                        ( cTemp )->B1_DESC,; // 2
                        ( cTemp )->AB7_NUMSER,; // 3
                        "false",; // 4
                        cData,; // 5
                        aReq[1],; // 6
                        aReq[2],; // 7
                        aReq[3],; // 8
                        ( cTemp )->AB7_CODPRO,; // 9
                        cMemo,;     // 10
                        aAb7Fld,;   // 11
                        cMemoF;     // 12
                    })

            If cCodOcor == ( cTemp )->AB7_CODPRB
                nOcor := 1
                cCodOcor := ( cTemp )->AB7_CODPRB
            Else
                nOcor := 2
                cCodOcor := ( cTemp )->AB7_CODPRB
            EndIf
            ( cTemp )->( DBSkip() )
        EndDo
    EndIf

    (cTemp)->(dbCloseArea())
EndIf

If nOcor == 1
    cOcorrencia := Alltrim( Posicione("AAG",1,xFilial("AAG")+cCodOcor,"AAG_DESCRI") )
Else
    cOcorrencia := Upper(STR0004) //"Multiplas Ocorrencias"
EndIf

Return cOcorrencia

//------------------------------------------------------------------------------
/*/{Protheus.doc} AtualizaOS

Atualiza o status da ordem de serviço

@author     Luiz Gabriel
@since      14/08/2020
/*/
//------------------------------------------------------------------------------
Static Function AtualizaOS(cNumOS, cStatus, cDtIni, cHrIni, cDtCheg, cHrCheg, cEntida, cAb7Item)
Local lRet          := .T.
Local aArea         := ""
Local lHVerao		:= SuperGetMv("MV_HVERAO",.F.,.F.) 	// Verifica se o local fisico do servidor está em Horário de Verão  .F. Não / .T. Sim
Local aTimeUf       := {} 
Local aAreaSM0	    := SM0->(GetArea())

Default cDtIni      := ""
Default cHrIni      := ""
Default cDtCheg     := ""
Default cHrCheg     := ""
Default cAb7Item    := ""

dbSelectArea("SM0")
SM0->(dbSetOrder(1))
If SM0->(dbSeek(cEmpAnt+cFilAnt))
	aTimeUf := FwTimeUF(SM0->M0_ESTENT,,lHVerao,DTOS(dDataBase))
EndIf
RestArea(aAreaSM0)

If cEntida == 'AB6'
    aArea := AB6->(GetArea())
    DbSelectArea("AB6")
    AB6->(DbSetOrder(1))
    If AB6->(MSSEEK(xFilial("AB6")+cNumOS))
        RecLock("AB6", .F.)

            If !Empty(cStatus)
                AB6->AB6_APPSTA := cStatus
            EndIf
            If !Empty(cDtIni)
                AB6->AB6_APPDTI := StoD(aTimeUF[1])
            EndIf
            if !Empty(cHrini) 
                AB6->AB6_APPHRI := SubStr(aTimeUF[2],1,5)
            EndIf 
            If !Empty(cHrCheg)
                AB6->AB6_APPHCH := SubStr(aTimeUF[2],1,5) 
            EndIf
            If !Empty(cDtCheg)
                AB6->AB6_APPDCH := StoD(aTimeUF[1])
            EndIf
        AB6->( MsUnlock() )
    Else
        lRet := .F.
    EndIf
Else
    aArea := AB7->(GetArea())
    DbSelectArea("AB7")
    AB7->(DbSetOrder(1))
    If AB7->(MSSEEK(xFilial("AB7")+cNumOS))
        RecLock("AB7", .F.)
     
        If !Empty(cStatus)
            AB7->AB7_APPSTA := cStatus
        EndIf
        If !Empty(cDtIni)
            AB7->AB7_APPDTI := StoD(aTimeUF[1])
        EndIf
        if !Empty(cHrini) 
            AB7->AB7_APPHRI := SubStr(aTimeUF[2],1,5)
        EndIf 
        If !Empty(cHrCheg)
            AB7->AB7_APPHCH := SubStr(aTimeUF[2],1,5)
        EndIf
        If !Empty(cDtCheg)
            AB7->AB7_APPDCH := StoD(aTimeUF[1])
        EndIf
        AB7->( MsUnlock() )
    Else
        lRet := .F.
    EndIf
EndIf

RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CheckParam

Verifica se os parametros obrigatorios foram passados para o body

@author     Luiz Gabriel
@since      14/08/2020
/*/
//------------------------------------------------------------------------------
Static Function CheckParam(oParams, cMessage)
Local lRet      := .T.

If Empty(oParams:CodTec) .Or. Empty(oParams:numOS) .Or. Empty(oParams:statusOs)
    lRet := .F.
    cMessage := STR0019 //"Os paramentros de Tecnico ou Ordem de serviço não foram preenchidos"
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EncerraOs()

Inclui o Atendimento da O.S via ExecAuto(Teca460)

@param ExpO: Objeto com os dados do put para encerramento da ordem de serviço

@return ExpL: Retorna .T. quando houve sucesso na execução da execauto 
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function EncerraOs(oParams, cErrorMsg)
Local lRet      := .F.
Local cNumOS    := oParams:numOS
Local aArea     := {}
Local aAtende   := {}
Local aItAten   := {}
Local nX        := 0
Local nZ        := 0
Local nTamItem	:= TamSX3("ABA_ITEM")[1]
Local cChave    := ""
Local cStatus   := "1"
Local aRet      := {}
Local lNotPend  := .T.
Local cItem     := ""
Local lAB9      := .F.

Default cErrorMsg := ""

BEGIN TRANSACTION

    DbSelectArea("TXM")
    TXM->(DbSetOrder(1))

    aArea := AB6->(GetArea())
    DbSelectArea("AB6")
    AB6->(DbSetOrder(1))
    If AB6->(MSSEEK(xFilial("AB6")+cNumOS))

        DbSelectArea("AB7")
        AB7->(DbSetOrder(1))

        For nX := 1 To Len(oParams:ITENSOS)

            cItem  := oParams:ITENSOS[nX]:numeroItem
            cChave := cNumOS+oParams:ITENSOS[nX]:numeroItem
            lAB9 := findAb9(cChave)
            aRet := ChecaReq(cNumOS,oParams:ITENSOS[nX]:numeroItem,oParams:codTec,"false")
            If oParams:STATUSOS == "4" .And. oParams:ITENSOS[nX]:SOLICITAPECA == "true" 
                cStatus := "2"
            Else
                cStatus := "1"
            EndIf 

            lNotPend := lNotPend .AND. !(aRet[1] == "true" .AND. aRet[3] == "false" .AND. aRet[3] == "false" )

            If AB7->(MSSEEK(xFilial("AB7")+cChave))
                aAtende :=	{cChave,;      // Numero da O.S + Item
                    GetSeqOs(cChave),;							        // Sequencia de Atendimento
                    oParams:CodTec,;				        // Codigo do Técnico
                    sToD(oParams:dtIniChegada),;			// Data de Chegada
                    oParams:hrIniChegada,;					// Hora de Chegada
                    sToD(oParams:dtIniEncerra),;					// Data de Saida
                    oParams:hrIniEncerra,;					// Hora de Saida
                    sToD(oParams:dtIniChegada),;					// Data de Inicio
                    oParams:hrIniChegada,;					// Hora de Inicio
                    sToD(oParams:dtIniEncerra),;					// Data de Fim
                    oParams:hrIniEncerra,;					// Hora de Fim
                    DecodeUtf8(oParams:ITENSOS[nX]:APONTAMENTO:LAUDO),;  //Laudo da ordem de serviço
                    cStatus}									// Tipo(1= Encerrado,2=Aberta)					            
                
                    aItAten := {}

                For nZ := 1 To Len(oParams:ITENSOS[nX]:APONTAMENTO:PRODUTOS)

                    aItem := {}

                    aItem :=	{StrZero(nZ,nTamItem),;				                     // Item (ABA)
                        oParams:ITENSOS[nX]:APONTAMENTO:PRODUTOS[nZ]:PRODUTO,;		     // Cod. Prod (ABA)
                        oParams:ITENSOS[nX]:APONTAMENTO:PRODUTOS[nZ]:ID,;                // Id Unico
                        oParams:ITENSOS[nX]:APONTAMENTO:PRODUTOS[nZ]:QUANTIDADE,;		 // Quantidade
                        oParams:ITENSOS[nX]:APONTAMENTO:PRODUTOS[nZ]:SERVICO,;		     // Servico Padrao
                        oParams:ITENSOS[nX]:APONTAMENTO:PRODUTOS[nZ]:PRODUTOANT,;        // Produto Anterior, utilizado para troca
                        oParams:ITENSOS[nX]:APONTAMENTO:PRODUTOS[nZ]:IDANT  }            // Id anterior, utilizado para troca

                        aAdd(aItAten,aItem)

                Next nZ            
                If IncAtend(aAtende,aItAten,3,oParams, @cErrorMsg, lAB9)
                    IncFoto(cNumOS,cItem,cStatus,oParams:ITENSOS[nX]:APONTAMENTO:FOTO)     
                    lRet := .T.
                EndIf 
            EndIf 

        Next nX 

        If lRet 
            If oParams:entida == "AB6"
                If lNotPend
                    UPDATEAB6(cNumOS, '3')
                Else
                    UPDATEAB6(cNumOS, '4')
                EndIf
            Else
                If lNotPend
                    UPDATEAB7(cNumOS, oParams:ab7item, '3')
                Else
                    UPDATEAB7(cNumOS, oParams:ab7item, '4')
                EndIf
            EndIf
        EndIf
    EndIf
END TRANSACTION	

RestArea(aArea)
    

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IncAtend()

Inclui o Atendimento da O.S via ExecAuto(Teca460)

@param ExpA:Array com os dados da ABB para a execAuto
@param ExpC:Sequencia que será utilizada na geração do atendimento
@param ExpN:Nopc para inclusão do atendimento da O.S (3 - Inclusão)

@return ExpL: Retorna .T. quando houve sucesso na execução da execauto 
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function IncAtend(aAtende,aItAten,nOpcx,oParams,cErrorMsg, lAB9)

Local aCabec   		:= {}		//Array para o cabeçalho do atendimento		
Local aItem    		:= {}		//Array auxiliar para os itens da O.S
Local aItens   		:= {}		//Array para o item da O.S
Local lRet			:= .F.		//Retorno da função
Local nX			:= 0
Local aAutoErro     := {}

Default lAB9       := .F.
Default cErroMsg      := ""
Default nOpcx 		:= 3

Private lMsHelpAuto 	:= .T.		// Controle interno do ExecAuto
Private lMsErroAuto 	:= .F.		// Informa a ocorrência de erros no ExecAuto
Private lAutoErrNoFile	:= .T.		// Loga Erros do Execauto na array
Private INCLUI 			:= .T.		// Variavel necessária para o ExecAuto identificar que se trata de uma inclusão
Private ALTERA 			:= .F.		// Variavel necessária para o ExecAuto identificar que se trata de uma inclusão

If (nOpcx == 3 .Or. nOpcx == 4) .AND. !lAB9

    //Adiciona itens para o cabeçalho do Atendimento
    aAdd(aCabec,{"AB9_NUMOS"	, aAtende[1] , Nil })       	// Numero da O.S + Item
    aAdd(aCabec,{"AB9_SEQ"		, aAtende[2] , Nil })			// Sequencia de Atendimento
    aAdd(aCabec,{"AB9_CODTEC"  	, aAtende[3] , Nil })			// Codigo do Técnico
    aAdd(aCabec,{"AB9_DTCHEG"	, aAtende[4] , Nil })			// Data de Chegada
    aAdd(aCabec,{"AB9_HRCHEG" 	, aAtende[5] , Nil })			// Hora de Chegada
    aAdd(aCabec,{"AB9_DTSAID"	, aAtende[6] , Nil })			// Data de Saida	
    aAdd(aCabec,{"AB9_HRSAID"  	, aAtende[7] , Nil })			// Hora de Saida
    aAdd(aCabec,{"AB9_DTINI"  	, aAtende[8] , Nil })			// Data de Inicio
    aAdd(aCabec,{"AB9_HRINI"  	, aAtende[9] , Nil })			// Hora de Inicio
    aAdd(aCabec,{"AB9_DTFIM"  	, aAtende[10], Nil })			// Data de Fim
    aAdd(aCabec,{"AB9_HRFIM"  	, aAtende[11], Nil })			// Hora de Fim
    aAdd(aCabec,{"AB9_MEMO2"  	, aAtende[12], Nil })       	// Codigo da Ocorrencia
    aAdd(aCabec,{"AB9_TIPO"  	, aAtende[13], Nil })			// Tipo(1= Encerrado,2=Aberta)	

    If !Empty(oParams:ASSINATURA)
        aAdd(aCabec,{"AB9_APPASS"  	, oParams:ASSINATURA, Nil })			// Assinatura	
        If !Empty(oParams:RESPONSAVEL)
            aAdd(aCabec,{"AB9_APPRES"  	, oParams:RESPONSAVEL, Nil })			// Responsavel Assinatura
        EndIf     
    EndIf 

    For nX := 1 To Len(aItAten)
        aItem := {}
        //Itens do Atendimento da O.S
        aAdd(aItem, {"ABA_ITEM"			, aItAten[nX][1]	, Nil}) 		// Item 
        aAdd(aItem, {"ABA_CODPRO"		, aItAten[nX][2]	, Nil}) 		// Cod. do Produto	

        If !Empty(aItAten[nX][3])
            aAdd(aItem, {"ABA_NUMSER"		, aItAten[nX][3]	, Nil}) 		// Numero de Serie				
        EndIf
        
        aAdd(aItem, {"ABA_QUANT"		, Val(aItAten[nX][4])	, Nil}) 		// Quantidade usada
        aAdd(aItem, {"ABA_CODSER"		, aItAten[nX][5]	, Nil}) 		// Cod. do servico
        //campos utilizados para ordem de serviço que houve troca
        If !Empty(aItAten[nX][6])
            aAdd(aItem, {"ABA_ANTPRO"		, aItAten[nX][6]	, Nil}) 		// Produto anterior
            aAdd(aItem, {"ABA_ANTSER"		, aItAten[nX][7]	, Nil}) 		// id anterior
        EndIf    
        aAdd(aItens,aItem)		
    Next nX

    //Executa ExecAuto
    TECA460(aCabec,aItens,nOpcx)

    If !lMsErroAuto
        lRet := .T.	
    Else
        aAutoErro := GETAUTOGRLOG() 
        if Len(aAutoErro) > 0
            cErrorMsg := aAutoErro[1]
        EndIf   
    EndIf

    aCabec := {}
    aItem  := {}
    aItens := {}
Else
    updateAB9(aAtende[1], aAtende[12], oParams:ASSINATURA, @cErrorMsg)
    lRet := .T.
EndIf

Return ( lRet )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IncFoto()

Inclui a foto na tabela TXM e relaciona a mesma com a ordem de serviço e item

@param ExpC:Numero da ordem de serviço
@param ExpC:Item da ordem de serviço
@param ExpC:status da ordem de serviço
@param ExpA:array com as fotos em base64
@param ExpC:assinatura da ordem de serviço em base64

@return .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function IncFoto(cNumOS,cItem,cStatus,aFotos)
Local nTamItem	:= TamSX3("TXM_ITFOTO")[1]
Local nX        := 0
Local lFotoDescri := TXM->(ColumnPos("TXM_DESCRI")) > 0

DbSelectArea("TXM")

For nX := 1 To Len(aFotos)
    If !Empty(aFotos[nX]:BASE64)
        RecLock("TXM",.T.)
            TXM->TXM_FILIAL := xFilial('TXM')
            TXM->TXM_NUMOS  := cNumOS
            TXM->TXM_ITEM   := cItem
            TXM->TXM_ITFOTO := StrZero(nX,nTamItem)
            TXM->TXM_FOTO   := aFotos[nX]:BASE64
            If(lFotoDescri)
                TXM->TXM_DESCRI := DECODEUTF8(aFotos[nX]:DESCRIPTION)
            EndIf
        TXM->(MsUnlock())
    EndIf    
Next nX

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} UPDATEAB7()

Atualiza o status de uma ordem de serviço por item

@Author Diego Bezerra
@param cNumOS, número da ordem de serviço
@param cItem, Item da ordem de serviço
@param cStatus, status da ordem de serviço

@return .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
STATIC FUNCTION UPDATEAB7(cNumOS, cItem, cStatus)
Local aAreaAB6  := AB7->(GetArea())
    DbSelectArea("AB7")
    AB7->(DbSetOrder(1))
    If AB7->(MSSEEK(xFilial("AB7")+cNumOS+cItem))
        RecLock("AB7", .F.)
            AB7->AB7_APPSTA := cStatus
        AB7->( MsUnlock() )
    Else
        lRet := .F.
    EndIf
    RestArea(aAreaAB6)
Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} UPDATEAB6()

Atualiza o status de uma ordem de serviço

@Author Diego Bezerra
@param cNumOS, número da ordem de serviço
@param cStatus, status da ordem de serviço

@return .T.
/*/
//--------------------------------------------------------------------------------------------------------------------
STATIC FUNCTION UPDATEAB6(cNumOS, cStatus)
Local aAreaAB6  := AB6->(GetArea())
    DbSelectArea("AB6")
    AB6->(DbSetOrder(1))
    If AB6->(MSSEEK(xFilial("AB6")+cNumOS))
        RecLock("AB6", .F.)
            AB6->AB6_APPSTA := cStatus
        AB6->( MsUnlock() )
    Else
        lRet := .F.
    EndIf
    RestArea(aAreaAB6)
Return .T.
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IncRequisicao()

Inclui a requisição de ordem de serviço

@param ExpO: Objeto com os dados do put para encerramento da ordem de serviço

@return ExpL: Retorna .T. quando houve sucesso na execução da execauto 
/*/
//--------------------------------------------------------------------------------------------------------------------
Function IncRequisicao(oParams)
Local nX        := 0
Local nZ        := 0       
Local aCabec    := {}
Local aItem     := {}
Local aItens    := {}
Local lRet      := .F.

PRIVATE lMsErroAuto := .F.

For nX := 1 To Len(oParams:ITENSOS)

    aadd(aCabec,{"ABF_EMISSA",dDataBase,Nil})
    aadd(aCabec,{"ABF_NUMOS",oParams:numOS+oParams:ITENSOS[nX]:numeroItem,Nil})
    aadd(aCabec,{"ABF_ITEMOS",oParams:ITENSOS[nX]:numeroItem,Nil})
    aadd(aCabec,{"ABF_SEQRC",GetSeqReq(oParams:numOS+oParams:ITENSOS[nX]:numeroItem),Nil})
    aadd(aCabec,{"ABF_CODTEC",oParams:CodTec,Nil})

    For nZ := 1 To Len(oParams:ITENSOS[nX]:REQUISICAO:PRODUTOS)
        aItem := {}

        aadd(aItem,{"ABG_ITEM"  ,StrZero(nZ,2),Nil})
        aadd(aItem,{"ABG_CODPRO",oParams:ITENSOS[nX]:REQUISICAO:PRODUTOS[nZ]:CODIGO,Nil})
        aadd(aItem,{"ABG_QUANT",oParams:ITENSOS[nX]:REQUISICAO:PRODUTOS[nZ]:QUANTIDADE,Nil})
        aadd(aItem,{"ABG_CODSER", oParams:ITENSOS[nX]:REQUISICAO:PRODUTOS[nZ]:CODSERVICE,Nil})
        aadd(aItens,aItem)
    Next nZ         

    TECA470(aCabec,aItens,3)
    If !lMsErroAuto
        ConOut("Inclusao com sucesso! ")
        lRet := .T.
    Else
        ConOut("Erro na inclusao!")
    EndIf

    aCabec    := {}
    aItem     := {}
    aItens    := {}

Next nX    


Return(lRet)	


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IncRequisicao()

Inclui a requisição de ordem de serviço

@param ExpO: Objeto com os dados do put para encerramento da ordem de serviço

@return ExpL: Retorna .T. quando houve sucesso na execução da execauto 
/*/
//--------------------------------------------------------------------------------------------------------------------
static Function IncReqOS(cCodTec, cNumOs, cNumItem, aProdut )
Local nX        := 0
Local aCabec    := {}
Local aItem     := {}
Local aItens    := {}
Local lRet      := .F.

PRIVATE lMsErroAuto := .F.

aadd(aCabec,{"ABF_EMISSA",dDataBase,Nil})
aadd(aCabec,{"ABF_NUMOS",cNumOs+cNumItem,Nil})
aadd(aCabec,{"ABF_ITEMOS",cNumItem,Nil})
aadd(aCabec,{"ABF_SEQRC",GetSeqReq(cNumOs+cNumItem),Nil})
aadd(aCabec,{"ABF_CODTEC",cCodTec,Nil})

For nX := 1 To Len(aProdut)
    aItem := {}

    aadd(aItem,{"ABG_ITEM"  ,StrZero(nX,2),Nil})
    aadd(aItem,{"ABG_CODPRO",aProdut[nX]:CODIGO,Nil})
    aadd(aItem,{"ABG_QUANT",aProdut[nX]:QUANTIDADE,Nil})
    aadd(aItem,{"ABG_CODSER", aProdut[nX]:CODSERVICE,Nil})
    aadd(aItens,aItem)
Next nX         

TECA470(aCabec,aItens,3)
If !lMsErroAuto
    ConOut("Inclusao com sucesso! ")
    lRet := .T.
Else
    ConOut("Erro na inclusao!")
EndIf

aCabec    := {}
aItem     := {}
aItens    := {}

Return(lRet)
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChecaReq()

Verifica se o item da ordem de serviço possui requisição e se a mesma foi baixada

@param ExpC: Numero da ordem de serviço
@param ExpC: Item da ordem de serviço
@param ExpC: codigo do técnico

@return ExpA: Array, sendo na primeira posição se possui requisição e na segunda se a mesma foi baixada 
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ChecaReq(cNumOS,cItemOS,cCodTec,cAtendido)
Local aRet      := {}
Local cTemp    := GetNextAlias()

If cAtendido == "false"
    //verifica se o item possui requisição e se o mesmo foi baixado
    BeginSQL Alias cTemp
        SELECT
            ABG.ABG_NUMOS,
            ABG.ABG_ITEMOS,
            ABG.ABG_NUMSA,
            ABG.ABG_ITEMSA,
            ABF.ABF_NUMOS,
            ABF.ABF_ITEMOS,
            SCP.CP_STATUS,
            CASE WHEN SD3.D3_NUMSA IS NULL THEN ' '
                ELSE SD3.D3_NUMSA END AS D3_NUMSA,
            CASE WHEN SD3.D3_ITEMSA IS NULL THEN ' '
                ELSE SD3.D3_ITEMSA END AS D3_ITEMSA,
            CASE WHEN SD3.D3_OSTEC IS NULL THEN ' '
                ELSE SD3.D3_OSTEC END AS D3_OSTEC,
            CASE WHEN ABA.ABA_ITEMRC <> '' THEN 1
                ELSE 2 END AS HASABA      
        FROM %Table:ABF% ABF
            INNER JOIN %Table:ABG% ABG ON
                ABG.ABG_FILIAL = %xFilial:ABG%
                AND ABG.ABG_NUMOS = ABF.ABF_NUMOS
                AND ABG.ABG_ITEMOS = ABF.ABF_ITEMOS
                AND ABG.%NotDel%
            LEFT JOIN %Table:SD3% SD3 ON
                SD3.D3_FILIAL = %xFilial:SD3%
                AND SD3.D3_NUMSA = ABG.ABG_NUMSA
                AND SD3.D3_ITEMSA = ABG.ABG_ITEMSA
                AND SD3.D3_OSTEC = ABF.ABF_NUMOS+ABF_ITEMOS
                AND SD3.%NotDel%
            LEFT JOIN %Table:SCP% SCP ON
                SCP.CP_FILIAL = %xFilial:SCP%
                AND SCP.CP_NUMOS = ABG.ABG_NUMOS+ABG_ITEMOS
                AND SCP.CP_PRODUTO = ABG.ABG_CODPRO
            LEFT JOIN %Table:ABA% ABA ON
                ABA.ABA_FILIAL = %xFilial:ABA%
                AND ABA.ABA_NUMOS = ABG.ABG_NUMOS+ABG_ITEMOS
                AND ABA.ABA_CODPRO = ABG.ABG_CODPRO    
                AND ABA.ABA_ITEMRC <> ''      
        WHERE
            ABF.ABF_FILIAL = %Exp:xFilial("ABF")%
            AND ABF.ABF_NUMOS = %Exp:cNumOS%
            AND ABF.ABF_ITEMOS = %Exp:cItemOS%
            AND ABF.ABF_CODTEC = %Exp:cCodTec%
            AND ABF.%NotDel%        
    EndSQL

        If ( cTemp )->( !Eof() )
            Aadd(aRet,"true")
            If !Empty(( cTemp )->D3_NUMSA) .And. !Empty(( cTemp )->D3_ITEMSA) .And. !Empty(( cTemp )->D3_OSTEC)
                Aadd(aRet,"true")
            Else
                Aadd(aRet,"false")
            EndIf

            If ( cTemp )->HASABA == 1
                Aadd(aRet,"true")
            Else
                Aadd(aRet,"false")
            EndIf
        Else
            Aadd(aRet,"false")
            Aadd(aRet,"false")
            Aadd(aRet,"false")
        EndIf
        (cTemp)->(dbCloseArea())
Else
    Aadd(aRet,"false")
    Aadd(aRet,"false")
    Aadd(aRet,"false")
EndIf 

Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetSeqOs()

Retorna a sequencia para o atendimento da ordem de serviço

@param ExpC: Caracter contendo numero da ordem de serviço e item da ordem de serviço

@return ExpC: Retorna a sequencia para o atendimento da ordem de serviço
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetSeqOs(cChave)
Local cItem := ""
Local cTemp	:= GetNextAlias()

BeginSQL Alias cTemp
		
	SELECT MAX(AB9_SEQ) AB9_SEQ FROM %Table:AB9% AB9
	WHERE AB9_FILIAL = %Exp:xFilial("AB9")% AND
		AB9_NUMOS = %Exp:cChave% AND		
		AB9.%NotDel%
EndSql

If ( cTemp )->( !Eof() )
	cItem := Soma1(( cTemp )->AB9_SEQ)  
Else
	cItem := Soma1(Replicate("0", (TamSx3('AB9_SEQ')[1]))) 
EndIf

(cTemp)->(dbCloseArea())

Return cItem

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetSeqReq()

Retorna a sequencia para a requisição da ordem de serviço

@param ExpC: Caracter contendo numero da ordem de serviço e item da ordem de serviço

@return ExpC: Retorna a sequencia para o atendimento da ordem de serviço
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetSeqReq(cChave)
Local cItem := ""
Local cTemp	:= GetNextAlias()

BeginSQL Alias cTemp
		
	SELECT MAX(ABF_SEQRC) ABF_SEQRC FROM %Table:ABF% ABF
	WHERE ABF_FILIAL = %Exp:xFilial("ABF")% AND
		ABF_NUMOS + ABF_ITEMOS = %Exp:cChave% AND		
		ABF.%NotDel%
EndSql

If ( cTemp )->( !Eof() )
	cItem := Soma1(( cTemp )->ABF_SEQRC)  
Else
	cItem := Soma1(Replicate("0", (TamSx3('ABF_SEQRC')[1]))) 
EndIf

(cTemp)->(dbCloseArea())

Return cItem

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetItemABA()

Retorna a sequencia para a requisição da ordem de serviço

@param ExpC: Caracter contendo numero da ordem de serviço e item da ordem de serviço

@return ExpC: Retorna a sequencia para o atendimento da ordem de serviço
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function GetItemABA(cChave)
Local cItem := ""
Local cTemp	:= GetNextAlias()

BeginSQL Alias cTemp
		
	SELECT MAX(ABA_ITEM) ABA_ITEM FROM %Table:ABA% ABA
	WHERE ABA_FILIAL = %Exp:xFilial("ABA")% AND
		ABA_NUMOS + ABA_CODTEC + ABA_SEQ = %Exp:cChave% AND		
		ABA.%NotDel%
EndSql

If ( cTemp )->( !Eof() )
	cItem := Soma1(( cTemp )->ABA_ITEM)  
Else
	cItem := Soma1(Replicate("0", (TamSx3('ABA_ITEM')[1]))) 
EndIf

(cTemp)->(dbCloseArea())

Return cItem

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuRequisicao()

Realiza a atualização da requisição e a baixa de recebimento de peça e 
encerra o atendimento da ordem de serviço

@param ExpO: oParams - Objeto JSON 

@return ExpL: Retorna se foi realizado a baixa e encerramento do atendimento da O.S
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AtuRequisicao( oParams )
Local lRet      := .T.
Local cSeekAB9  := oParams:NUMOS+oParams:ITEMOS
Local aAreaAB9  := {}

DbSelectArea("AB9")
AB9->(DbSetOrder(1))
If AB9->(DbSeek(xFilial("AB9")+cSeekAB9+oParams:CODTEC+"01"))
	aAreaAB9 := AB9->(GetArea())

    lRet := AtendReq( oParams:NUMOS, oParams:ITEMOS, "01" )
    If lRet
        RecLock("AB9",.F.)
            AB9->AB9_TIPO = "1"
        AB9->(MsUnlock())
    EndIf 
    RestArea(aAreaAB9)
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtendReq()

Realiza a baixa das peças requisitadas

@param ExpC: Caracter contendo numero da ordem de serviço
@param ExpC: Caracter contendo item da ordem de serviço
@param ExpC: Caracter contendo a sequencia da requisição

@return ExpL: Retorna se foi realizado a baixa
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AtendReq( cNumOs, cItemOs, cSeqRC )
Local cSeekABG
Local lRet     := .T.
Local nQuant   := 0
Local nQuje    := 0

Local cFilialSCQ := xFilial("SCQ")
Local cFilialSD3 := xFilial("SD3")
Local cFilialSCP := xFilial("SCP")
Local cFilialSB1 := xFilial("SB1")

Local cPItem   := ""
Local cPCodPro := ""
Local nPQuant  := 0
Local cPLocal  := ""
Local cPCodSer := ""
Local cPDescri := ""
Local cPItemRC := ""
Local cPSeqRC  := ""
Local cPNumSer  := ""
Local cPLocali  := ""
Local cSeekABA	:= xFilial("ABA")+AB9->AB9_NUMOS+AB9->AB9_CODTEC+AB9->AB9_SEQ
Local aArea     := {}
Local aAreaABG  := {}
Local aAreaSCP  := {}
Local aAreaSB1  := {}
Local aAreaSCQ  := {}
Local aAreaSD3  := {}


cSeekABG := xFilial("ABG") + cNumOS + cItemOS + cSeqRC

aArea := GetArea()

dbSelectArea("ABG")
aAreaABG := ABG->(GetArea())
dbSetOrder( 1 )
If ABG->( dbSeek( cSeekABG ) )

	nQuje   := 0
	nQuant  := 0

	dbSelectArea("SD3")
	aAreaSD3 := SD3->(GetArea())
	dbSelectArea("SCQ")
	aAreaSCQ := SCQ->(GetArea())
	dbSelectArea("SB1")
	aAreaSB1 := SB1->(GetArea())
	dbSelectArea("SCP")
	aAreaSCP := SCP->(GetArea())

	While ( !ABG->( Eof() ) .And. cSeekABG == ABG->ABG_FILIAL + ABG->ABG_NUMOS + ;
			ABG->ABG_ITEMOS + ABG->ABG_SEQRC )

		If  ( Empty( ABG->ABG_SEQ ) .And. Empty( ABG->ABG_CODTEC )) .Or. ;
				( ABG->ABG_SEQ == AB9->AB9_SEQ .And. ABG->ABG_CODTEC == AB9->AB9_CODTEC )

			SCP->( dbSetOrder( 1 ) )
			If SCP->( dbSeek( cFilialSCP + ABG->ABG_NUMSA + ABG->ABG_ITEMSA ) )

				nQuje   += SCP->CP_QUJE
				nQuant  += SCP->CP_QUANT

				If !Empty( SCP->CP_QUJE )

					dbSelectArea("SB1")
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(cFilialSB1+ABG->ABG_CODPRO))

					cPItem := GetItemABA(cSeekABA)

					cPCodPro    := ABG->ABG_CODPRO
					nPQuant     := SCP->CP_QUJE
					cPLocal     := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
					cPCodSer    := ABG->ABG_CODSER
					cPDescri    := SB1->B1_DESC
					cPItemRC    := ABG->ABG_ITEM
					cPSeqRC     := ABG->ABG_SEQRC

					// Busca na pre-requisicao para conseguir achar
					// qual movimento interno foi gerado com o produto para a OS
					dbSelectArea("SCQ")
					SCQ->(dbSetOrder(1))
					If SCQ->(dbSeek(cFilialSCQ+SCP->CP_NUM+SCP->CP_ITEM))
						If !Empty(CQ_NUMREQ)
							SD3->(dbSetOrder(4))
							If SD3->(dbSeek(cFilialSD3+SCQ->CQ_NUMREQ+"E0"+SCQ->CQ_PRODUTO))
								If SD3->D3_ESTORNO == " " .AND. SD3->D3_OSTEC==ABG->(ABG_NUMOS+ABG_ITEMOS)
									cPNumSer := SD3->D3_NUMSERI
									cPLocali := SD3->D3_LOCALIZ
								EndIf
							EndIf
						EndIf
					EndIf
                    RecLock("ABA", .T.)
                        //popula os item da ABA para o atendimento
                        ABA->ABA_FILIAL := xFilial("ABA")
                        ABA->ABA_ITEM   := SOMA1(CheckABA(AB9->AB9_NUMOS, AB9->AB9_CODTEC))
                        ABA->ABA_CODPRO := cPCodPro
                        ABA->ABA_NUMOS  := AB9->AB9_NUMOS
                        ABA->ABA_CODTEC := AB9->AB9_CODTEC
                        ABA->ABA_SEQ    := AB9->AB9_SEQ
                        ABA->ABA_QUANT  := nPQuant 
                        ABA->ABA_LOCAL  := cPLocal
                        ABA->ABA_CODSER := cPCodSer
                        ABA->ABA_DESCRI := cPDescri
                        ABA->ABA_ITEMRC := cPItemRC
                        ABA->ABA_SEQRC  := cPSeqRC
                        ABA->ABA_NUMSER := cPNumSer
                        ABA->ABA_LOCALI := cPLocali
                    ABA->( MsUnlock() )   
				EndIf    
			EndIf
		EndIf

		ABG->( dbskip() )

	End

	RestArea(aAreaSD3)
	RestArea(aAreaSCQ)
	RestArea(aAreaSB1)
	RestArea(aAreaSCP)

EndIf

RestArea(aAreaABG)
RestArea(aArea)

Return( lRet )

Static Function CheckABA(cNumOS, cCodTec)

Local cItem := '00'
Local cTemp := GetNextAlias()

BeginSQL Alias cTemp
    SELECT
        ABA.ABA_ITEM
    FROM %Table:ABA% ABA
    WHERE
        ABA.ABA_FILIAL = %Exp:xFilial("ABA")%
        AND ABA.ABA_NUMOS = %Exp:cNumOS%
        AND ABA.ABA_CODTEC = %Exp:cCodTec%
        AND ABA.%NotDel%        
EndSQL
While ( cTemp )->( !Eof() )
    cItem := ( cTemp )->ABA_ITEM
    ( cTemp )->( DBSkip() )
EndDo

Return cItem
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} OsAponta()

Retorna os apontamentos para os atendimentos listados

@param ExpC: Caracter contendo numero da ordem de serviço
@param ExpC: Caracter contendo o codigo do atendente

@return ExpL: Retorna se foi realizado a baixa
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function OsAponta(cNumOS,cAttendant)
Local aRet      := {}
Local cTemp     := GetNextAlias()
Local cTroca    := "" 

BeginSQL Alias cTemp
    SELECT
        ABA.ABA_NUMOS,
        ABA.ABA_CODPRO,
        ABA.ABA_DESCRI,
        ABA.ABA_NUMSER,
        ABA.ABA_QUANT,
        ABA.ABA_CODSER,
        ABA.ABA_ANTPRO,
        ABA.ABA_ANTSER
    FROM %Table:ABA% ABA
    WHERE
        ABA.ABA_FILIAL = %Exp:xFilial("ABA")%
        AND ABA.ABA_NUMOS = %Exp:cNumOS%
        AND ABA.ABA_CODTEC = %Exp:cAttendant%
        AND ABA.%NotDel%        
EndSQL

If ( cTemp )->( !Eof() )
    While ( cTemp )->ABA_NUMOS == cNumOS
        
        If !EMPTY(( cTemp )->ABA_ANTPRO)
            cTroca := "true"
        Else
            cTroca := "false"
        EndIf 

        aAdd(aRet,{( cTemp )->ABA_CODPRO,;
                ( cTemp )->ABA_DESCRI,;
                ( cTemp )->ABA_NUMSER,;
                ( cTemp )->ABA_QUANT,;
                ( cTemp )->ABA_CODSER,;
                cTroca,;
                ( cTemp )->ABA_ANTPRO,;
                ( cTemp )->ABA_ANTSER})

        ( cTemp )->( DBSkip() )
    EndDo
EndIf
    
(cTemp)->(dbCloseArea())

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} LerMemo

Realiza a leitura da tabela SYP, retornando os valores de um campo memo informado

@param      cChave, string, chave do campo na SYP
@author     Diego Bezerra
@since      22/04/2021
/*/
//------------------------------------------------------------------------------
Static Function LerMemo(cChave, nMaxLen)
    Local nPos    := 0
    Local nTam       := Len(Space(TamSx3("YP_TEXTO")[1]))
    Local cLine      := ""
    Local cString := ""
    Default nMaxLen := -1
    DbSelectArea("SYP")
    SYP->(DbSetOrder(1))
    SYP->(DbGoTop())
    If(SYP->(DbSeek(xFilial("SYP") + cChave, .T.)))
        While SYP->(!Eof()) .And. ( cChave == SYP->YP_CHAVE ) .And. ( xFilial("SYP") == SYP->YP_FILIAL )
            cLine := RTrim(Subs(SYP->YP_TEXTO,1,nTam))
            
            if( At(char(9), cLine ) ) > 0
                cLine := StrTran( cLine, char(9), Space(5) )
            EndIf
            If( AT(char(13), cLine ) ) > 0
                cLine := StrTran( cLine, char(13), char(10) )
            EndIf
            
            If( AT(char(10), cLine ) ) > 0
                cLine := StrTran( cLine, char(10), '\n' )
            EndIf
            cString += cLine
            SYP->(DbSkip())
        End While
        SYP->(DbCloseArea())
    Endif
    if At("\13\10", cString )  > 0 .OR. At("\14\10", cString )  > 0
        cString := StrTran( cString, "\13\10", Space(2))
        cString := StrTran( cString, "\14\10", Space(2))
    EndIf

    if nMaxLen > 0 .AND. Len(cString) > nMaxLen
        cString := Left(cString, nMaxLen)
        cString += "..."
    EndIf
    
Return(cString)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CaracEsp

Verifica a existencia de alguns caracteres especiais na descrição

@param cExp: Expressão que será avaliada para a existencia de caracter especial
@param cDescExp: Expressão já corrigida 

@return ExpL: Retorna .T. se achou algum caracter especial
/*/
//--------------------------------------------------------------------------------------------------------------------
Function CaracEsp(cExp,cDescExp)
Local lRet      := .F.
Local aCarac    := {"'",'"',"{","}","[","]","(",")"}
Local nI        := 0

cDescExp := cExp

For nI := 1 To Len(aCarac)
    If At(aCarac[nI] ,cExp) > 0
        lRet := .T.
        If aCarac[nI] == '"'
            cDescExp := StrTran( cExp, aCarac[nI], CHR(96)+CHR(96) )
            Exit
        Else
            cDescExp := cExp
        EndIf
    EndIf
Next nI
cDescExp := StrTran( cDescExp, '\', '\\' )
cDescExp := StrTran( cDescExp, '\\n', '\n' )

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BaseDetail

Obtem o endereço da base de atendimento, para agendas que utilizam entidade AB7

@param cNumSer: Id único da base de atendimento
@param cCodProd: Código do produto utilizado na AB7
@PARAM lData:  Indica se existe endereço cadastrado na base de atendimento. true == sim; false == não
@return ExpL: aDetail Array com as informações do endereço do local de atendimento
--- [1] = Endereço
--- [2] = Bairro
--- [3] = Municipio
--- [4] = Estado
--- [5] = Cep

@author     Diego Bezerra
@since      07/12/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function BaseDetail(cNumSer, cCodProd, lData)

Local cTmp          := GetNextAlias()
Local cTmpAa3       := GetNextAlias()
Local aDetail       := {}
Local cCodLoc       := ""
Local aColumns      := ColumnsBase()
Local aAbsCol       := aColumns[1]
Local cAbsCol       := aColumns[2]
Local nX            := 1

cAbsCol := '%' + cAbsCol + '%'

BeginSQL Alias cTmpAa3
SELECT 
    AA3.AA3_CODLOC
FROM %Table:AA3% AA3
WHERE 
    AA3.AA3_NUMSER = %Exp:cNumSer%
    AND AA3.AA3_CODPRO = %Exp:cCodProd%
    AND AA3.AA3_CODLOC <> ''
    AND AA3.AA3_FILIAL = %Exp:xFilial("AA3")%
    AND AA3.%NotDel%
EndSQL

If ( cTmpAa3 )->( !Eof())
    cCodLoc:= (cTmpAa3)->AA3_CODLOC
    BeginSQL Alias cTmp
    SELECT
        ABS.ABS_CONTAT,
        COALESCE(U5.U5_CONTAT, ' ') U5_CONTAT,
		COALESCE(U5.U5_DDD, ' ') U5_DDD,
		COALESCE(U5.U5_CELULAR, ' ') U5_CELULAR,
		COALESCE(U5.U5_EMAIL, ' ')	U5_EMAIL,
        %Exp:cAbsCol%
    FROM %Table:ABS% ABS 
    INNER JOIN %Table:AA3% AA3 
        ON AA3.AA3_CODLOC = ABS.ABS_LOCAL AND AA3.AA3_FILIAL = %Exp:xFilial("AA3")%
        AND AA3.%NotDel%
    LEFT JOIN %Table:SU5% U5 ON 
        U5.U5_FILIAL =  %Exp:xFilial("SU5")%
		AND U5.U5_CODCONT = ABS.ABS_CONTAT
		AND U5.%NotDel%    
    WHERE
        ABS.ABS_LOCAL = %Exp:cCodLoc% AND AA3.AA3_CODPRO = %Exp:cCodProd%
        AND ABS.ABS_FILIAL = %Exp:xFilial("ABS")%
        AND ABS.%NotDel% 
    EndSQL

    If ( cTmp )->( !Eof())
        If !Empty(( cTmp )->ABS_END)
            For nX = 1 to Len(aAbsCol)
                AADD(aDetail,( cTmp )->&(aAbsCol[nX]))
                /*  
                    #############################################
                        AADD(aDetail, ( cTmp )->ABS_END )
                        AADD(aDetail, ( cTmp )->ABS_BAIRRO )
                        AADD(aDetail, ( cTmp )->ABS_MUNIC )
                        AADD(aDetail, ( cTmp )->ABS_ESTADO )
                        AADD(aDetail, ( cTmp )->ABS_CEP )
                    #############################################
                */
            Next nX
            
            AADD(aDetail,( cTmp )->U5_CONTAT)
            AADD(aDetail,( cTmp )->U5_DDD)
            AADD(aDetail,( cTmp )->U5_CELULAR)
            AADD(aDetail,( cTmp )->U5_EMAIL)                
            AADD(aDetail,!Empty(( cTmp )->ABS_CONTAT))
            
        Else 
            lData := .F.
        EndIf
    Else 
        lData := .F.
    EndIf
    (cTmp)->(DbCloseArea())
Else
    lData := .F.
EndIf
(cTmpAa3)->(DbCloseArea())
Return aDetail

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ColumnsBase

Retorna as colunas que armazenam os dados de endereço da Base de Atendimento (ABS)

@author     Diego Bezerra
@since      09/12/2021
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function ColumnsBase()

Local aColumns := {}
Local aAux := {}
Local nX := 1
Local nPos := 0
Local aRet := {}
Local cColumn := ""

AADD(aColumns,'ABS_END')
AADD(aColumns,'ABS_BAIRRO')
AADD(aColumns,'ABS_MUNIC')
AADD(aColumns,'ABS_ESTADO')
AADD(aColumns,'ABS_CEP')
AADD(aColumns,'ABS_DCONTA')
AADD(aColumns,'ABS_EMAIL')
AADD(aColumns,'ABS_TEL')

aAux := FWSX3Util():GetAllFields("ABS" , .F.)
AADD(aRet,{})
If Len(aAux) > 0
    For nX := 1 To Len(aColumns)
        nPos := aScan(aAux,{|x| AllTrim(x) == AllTrim(aColumns[nX])})
        If nPos >0 
            AADD(aRet[1],aAux[nPos])
            cColumn += aAux[nPos] + ','
        EndIf
    Next nX
    cColumn := Left(cColumn, Len(cColumn)-1 )
EndIf
AADD(aRet,cColumn)
Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} txmFotos

Retorna as fotos dos apontamentos
@param      cNumOs, string, número da ordem de serviço
@param      cItem, string, número do item de uma ordem de serviço
@param      cEntida, string, código da entidade utilizada (AB6==Ordem de serviço; AB7== Item da ordem de serviço)
@author     Diego Bezerra
@since      20/04/2022
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function txmFotos(nRec)

Local aRet       := {}

DBSELECTAREA('TXM')
DBSETORDER(1)
DBGOTO(nRec)

AADD(aRet, TXM->TXM_NUMOS)
AADD(aRet, TXM->TXM_ITEM)
AADD(aRet, TXM->TXM_ITFOTO)
AADD(aRet, TXM->TXM_DESCRI)
AADD(aRet, TXM->TXM_FOTO)

TXM->(DBCLOSEAREA())

Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} OsDetail

Retorna os detalhes do apontamento, para uma determinada ordem de serviço.
@param      cNumOs, string, número da ordem de serviço
@param      cItem, string, número do item de uma ordem de serviço
@author     Diego Bezerra
@since      25/04/2022
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function OsDetail(cNumOs, cItemOs)

Local cTemp             := GetNextAlias()
Local cChave            := ""
Local aRet              := {}
Default cItemOs         := ""

cChave := cNumOs + cItemOs
BeginSQL Alias cTemp
        
    SELECT 
        AB9.AB9_NUMOS,
        AB9.AB9_CODTEC,
        AB9.AB9_DTINI,
        AB9.AB9_HRINI,
        AB9.AB9_DTFIM,
        AB9.AB9_HRFIM,
        AB9.AB9_MEMO1,
        AB9.AB9_CODPRB,
        CASE WHEN AB9.AB9_APPRES IS NULL THEN ' '
            ELSE AB9.AB9_APPRES END AS AB9_APPRES, 
        CASE WHEN AB9.AB9_APPASS IS NULL THEN ' '
            ELSE AB9.AB9_APPASS END AS AB9_APPASS
    FROM %Table:AB9% AB9 
    WHERE
        AB9.AB9_FILIAL = %Exp:xFilial("AB9")% AND 
        AB9.AB9_NUMOS = %Exp:cChave% AND 
        AB9.%NotDel%
EndSql

If ( cTemp )->( !Eof() )
    While ( cTemp )->( !Eof() )
        AADD(aRet,( cTemp )->( AB9_DTINI )) //-1 - data de inicio do atendimento
        AADD(aRet,( cTemp )->( AB9_HRINI )) //-2 - horário de início do atendimento
        AADD(aRet,( cTemp )->( AB9_DTFIM )) //-3 - data de término do atendimento
        AADD(aRet,( cTemp )->( AB9_HRFIM )) //-4 - horário de término do atendimento
        AADD(aRet, EncodeUTF8( AllTrim(LerMemo((cTemp)->AB9_MEMO1))) ) //-5 - Laudo 
        AADD(aRet, ( cTemp )->( AB9_APPASS )) //6 - assinatura
        AADD(aRet, ALLTRIM(( cTemp )->( AB9_APPRES )))
        ( cTemp )->( DBSkip() )
    EndDo
EndIf

( cTemp )->(dbCloseArea())

Return aRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} photos

Obtem as fotos apontadas em uma determinada ordem de serviço
@param      cAlias, string, AB6 == Apontamentos de todos os itens da ordem de serviço - AB7 == Apontamentos de um item específico da ordem de serviço
@param      cNumOS, string, número da ordem de serviço
@param      cItemOs, string, item da ordem de serviço. Considerando o campo cAlias == AB7
@author     Diego Bezerra
@since      25/04/2022
/*/
//--------------------------------------------------------------------------------------------------------------------
WSMETHOD GET photos WSRECEIVE recPhoto WSREST meutecnico
Local lRet              := .T.
Local cResponse		    := '{"foto":{}}'
Local cMessage          := ""
Local nStatusCode       := 200
Local aRet              := {}
Local cDescri           := ""    

Self:SetContentType("application/json;charset=UTF-8")

If(!EMPTY(Self:recPhoto))
    aRet := txmFotos(Self:recPhoto)
    if !EMPTY(aRet)
        cDescri := ""
        cResponse := '{"foto":{'
        if !Empty(aRet)
            CaracEsp(ENCODEUTF8(aRet[4], @cDescri))
            cDescri := StrTran( cDescri, '\', '\\' )
            cDescri := StrTran( cDescri, '\\n', '\n' )
            cDescri := RTrim(cDescri)
            cResponse += '"numOs": "' + aRet[1] + '", '
            cResponse += '"itemOs": "' + aRet[2] + '", '
            cResponse += '"itemFoto": "' + aRet[3] + '", '
            cResponse += '"description": "' + cDescri + '",'
            cResponse += '"base64": "' + ENCODEUTF8(aRet[5]) + '" }}'
        EndIf
    EndIf
Else
    cMessage := STR0163 //"Um ou mais parâmetros obrigatórios não foram preenchidos"
    nStatusCode := 400
    lRet := .F.
EndIf

If lRet
    Self:SetResponse( cResponse )
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} changeLaudo

Responsável pela alteração do laudo da ordem de serviço
@param      cNumOS, string, número da ordem de serviço
@param      cItemOs, string, item da ordem de serviço. 
@param      cNewLaudo, string, laudo da ordem de serviço
@param      cErrorMsg, string, mensagem de erro, passada por referência
@return     lRet, booleana
@author     Diego Bezerra
@since      04/07/2022
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function changeLaudo(cNumOs, cItemOs, cNewLaudo, cErrorMsg, lAdd)

Local lRet := .F.
Local cAlias := getNextAlias()
Local cChave := cNumOs + cItemOs
Local cOldValue := ""
Default lAdd := .F.

BeginSQL Alias cAlias
    SELECT AB9.AB9_MEMO1
    FROM %Table:AB9% AB9
    WHERE   AB9.AB9_FILIAL = %Exp:xFilial("AB9")% AND 
            AB9.AB9_NUMOS = %Exp:cChave% AND
            AB9.%NotDel%

EndSql

If ( cAlias )->( !Eof() )
    lRet := .T.
    If lAdd
        cOldValue := LerMemo((cAlias)->AB9_MEMO1)
        cNewLaudo := 'Laudo do técnico: \n' + cNewLaudo + '\n' + cOldValue
        MSMM(( cAlias )->AB9_MEMO1,,,cNewlaudo,1,,,"AB9","AB9_MEMO1")
    Else
        MSMM(( cAlias )->AB9_MEMO1,,,DECODEUTF8(cNewlaudo),1,,,"AB9","AB9_MEMO1")
    EndIf
Else 
    cErroMsg := STR0164 //"Ordem de serviço não encontrada"
EndIf

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} laudo

Endpoint utilizado para chamar a alteração do laudo
@param body:{"cNumOs":"numero da os","cItemOs":"numero do item","cNewLaudo":"novo laudo"}
@since      05/07/2022
/*/
//--------------------------------------------------------------------------------------------------------------------
WSMETHOD PUT laudo WSREST meutecnico
Local lRet          := .T.
Local cBody	        := ""
Local oOppJson      := Nil
Local nStatusCode	:= 500
Local cMessage	    := "Internal Server Error"
Local cResponse     := ""
Local cErrorMsg     := ""

cBody := Self:GetContent()

FWJsonDeserialize(cBody,@oOppJson)

If !Empty( oOppJson:cNumOs )
    If changeLaudo( oOppJson:cNumOs, oOppJson:cItemOs, oOppJson:cNewLaudo, @cErrorMsg )
        cResponse		:= '{"sucessCode":200,"sucessMessage": "' + STR0167 + '"}' //"Laudo alterado com sucesso" 
    Else
        lRet		:= .F.
        nStatusCode := 400
        cMessage	:= STR0165//"Não foi possível alterar o laudo da OS especificada"
    EndIf 
EndIf

If 	lRet
    Self:SetResponse( EncodeUTF8(cResponse) )
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} checkAtt

Endpoint utilizado para saber se uma determinda ordem de serviço possui atendimento registrado 
@return {"haveAtt":0} == não possui atendimento registrado na tabela AB9
@return {"haveAtt":1} == possui atendimento registrado na tabela AB9
@since      05/07/2022
/*/
//--------------------------------------------------------------------------------------------------------------------
WSMETHOD GET checkAtt WSRECEIVE cChave WSREST meutecnico
Local lRet              := .T.
Local cAlias            := GetNextAlias()
Local cResponse		    := '{ "haveAtt": 0 }'
Local cMessage          := STR0169 //"Erro interno"
Local nStatusCode       := 200
Local cChave            := Self:cChave

// define o tipo de retorno do método
::SetContentType("application/json;charset=UTF-8")

BeginSQL Alias cAlias
    SELECT AB9.AB9_NUMOS
    FROM %Table:AB9% AB9
    WHERE   AB9.AB9_FILIAL = %Exp:xFilial("AB9")% AND
            AB9.AB9_NUMOS = %Exp:cChave% AND
            AB9.%NotDel%
EndSql

If ( cAlias )->( !Eof() )
    cResponse := '{ "haveAtt": 1 }'
    nStatusCode := 200
EndIf

(cAlias)->(dbCloseArea())

If lRet
    Self:SetResponse( cResponse )
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} file

@author Diego Bezerra
@description Endpoint utilizado para fazer upload de arquivos 
@body {cNumOs:string,cBase64:string,cDescri:string,cFileType:string}
@since 2022
/*/
//--------------------------------------------------------------------------------------------------------------------

WSMETHOD POST file WSREST meutecnico
Local lRet          := .T.
Local cBody	        := ""
Local oOppJson      := Nil
Local nStatusCode	:= 500
Local cError        := ""
Local cResponse     := ""

cBody := Self:GetContent()

If !Empty( cBody )
    FWJsonDeserialize(cBody,@oOppJson)
    If !Empty( oOppJson )
        addFile( oOppJson:cNumOs, oOppJson:cItemOs, oOppJson:cBase64, oOppJson:cDescri, oOppJson:cFileType, @cError)
        cResponse		:= '{"sucessCode":200,"sucessMessage": "Sucesso na inclusão do arquivo."}'
    EndIf
EndIf

If 	lRet
    Self:SetResponse( EncodeUTF8(cResponse) )
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} addFile

@author Diego Bezerra
@description Endpoint utilizado para saber se uma determinda ordem de serviço possui atendimento registrado 
@param cNumOs, string, número da ordem de serviço
@param cItemOs, string, item da ordem de serviço
@param cDescri, string, descrição do arquivo
@param cFileType, string, tipo do arquivo
@since 2022
/*/
//--------------------------------------------------------------------------------------------------------------------
Static function addFile(cNumOs, cItemOs, cBase64, cDescri, cFileType, cErrorMsg)

Local nNextItem     := ckNextFile(cNumOs, cItemOs, cFileType, @cErrorMsg)
Local lRet          := .T.

DbSelectArea('TXM')
RecLock("TXM", .T.) 

TXM->TXM_FILIAL     := xFilial('TXM')
TXM->TXM_NUMOS      := cNumOS 
TXM->TXM_ITEM       := cItemOs
TXM->TXM_ITFOTO     := PadL(cValToChar(nNextItem),2,'0')
TXM->TXM_FOTO       := cBase64
TXM->TXM_DESCRI     := cDescri

TXM->( MsUnlock() )
TXM->( DbCloseArea() )
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} addAssinatura

@author Diego Bezerra
@description Endpoint utilizado para saber se uma determinda ordem de serviço possui atendimento registrado 
@param cNumOs, string, número da ordem de serviço
@param cBase64, string, base64 da assinatura

@since 2022
/*/
//--------------------------------------------------------------------------------------------------------------------

Static function addAssinatura(cNumOs, cBase64)

DbSelectArea('AB9')
AB9->(DbSeek(xFilial("AB9")+cNumOs))
RecLock('AB9',.F.)
AB9->AB9_APPASS := cBase64
AB9->( MsUnlock() )
AB9->( DbCloseArea() )

Return .T.
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ckNextFile

@author Diego Bezerra
@description Utilizada para obter o próximo número de item sequencial valido, para o arquivo na tabela TXM
@param cNumOs, string, número da ordem de serviço
@param cItemOs, string, número do item da ordem de serviço
@param cType, string, tipo do arquivo
@param cErrorMsg, string, mensagem de erro
@since 2022
/*/
//--------------------------------------------------------------------------------------------------------------------
Static function ckNextFile(cNumOs, cItemOs, cType, cErrorMsg )

Local lRet          := .T.
Local cAlias        := getNextAlias()
Local nextItFoto    := 1

BeginSQL Alias cAlias
    SELECT COUNT(1) ITEM FROM %Table:TXM% TXM
    WHERE 
        TXM.TXM_NUMOS = %Exp:cNumOs% 
        AND TXM.TXM_ITEM = %Exp:cItemOs%
        AND TXM.TXM_FILIAL = %Exp:xFilial('TXM')%
        AND TXM.%NotDel%
EndSQL

If ( cAlias )->ITEM > 0
    nextItFoto := ( cAlias )->ITEM
Else
    lRet := .F.
    cErrorMsg := 'Não existem fotos registradas para essa ordem de serviço'
EndIf

Return nextItFoto

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} pagesPhoto

@author Diego Bezerra
@description retorna o recno de cada arquivo, gravado na tabela TXM
@param cNumOS, string, número da ordem de serviço
@param cItemOS, string, código do item da ordem de serviço
@since 2022
/*/
//--------------------------------------------------------------------------------------------------------------------
WSMETHOD GET pagesPhoto WSRECEIVE cNumOS, cItemOS WSREST meutecnico

Local cTemp             := GetNextAlias()
Local cResponse		    := '{ "registers": [] }'
Local cQuery            := ""
Local nCtrReg           := 0
Local cItemOS           := ""
::SetContentType("application/json")

if !Empty(Self:cItemOS)
  cItemOS   := Self:cItemOS
EndIf

cQuery := "SELECT R_E_C_N_O_ rec "
cQuery += "FROM " + retSqlName('TXM') + " TXM "
cQuery += "WHERE TXM.TXM_FILIAL = '"+xFilial("TXM") + "' "
cQuery += "AND TXM.TXM_NUMOS = '" + Self:cNumOS + "' "
if !Empty(cItemOS)
    cQuery += "AND TXM.TXM_ITEM = '" + cItemOS + "' "
EndIf
cQuery += "AND TXM.D_E_L_E_T_ = ' ' "  

cAliasQry := GetNextAlias()
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTemp, .F., .T.)

If ( cTemp )->( !Eof() )
    cResponse := '{"registers":['
    While ( cTemp )->( !Eof() )
        nCtrReg ++
        If nCtrReg > 1
            cResponse += ','
        EndIf
        cResponse += cValToChar(( cTemp )->rec)
    
    ( cTemp )->( dbskip() )
    EndDo   
    cResponse += ']}'  

Else
    cResponse := '{"registers":[]}'
EndIf

Self:SetResponse( cResponse )


Return .T. 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} updateAB9

@author Diego Bezerra
@description Utilizada para atualizar um atendimento específico para uma OS
@param cNumOS, string, número da ordem de serviço
@param cLaudo, string, laudo do atendimento
@param cAssinatura, string, base64 da assinatura
@param cErrorMsg, string, mensagem de erro, obtida via passagem por referência
@since 2022
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function updateAB9(cNumOs, cLaudo, cAssinatura, cErrorMsg)

Default cErrorMsg := ""

addAssinatura(cNumOs, cAssinatura)
lRet := changeLaudo(cNumOs, "", cLaudo, @cErrorMsg, .T.)

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} findAb9

@author Diego Bezerra
@description Verifica a existência de atendimento para uma determinada ordem de serviço
@param cNumOs, string, número da ordem de serviço
@since 2022
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function findAb9(cNumOs)

DbSelectArea("AB9")
AB9->(DbSetOrder(1))
lRet := AB9->(DbSeek(xFilial("AB9")+cNumOS))

Return lRet
