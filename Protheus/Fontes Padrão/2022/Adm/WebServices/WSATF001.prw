#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WSATF001.CH"

//STATIC LDEBUG := .F. //Para utilizar em debug    

WSRESTFUL WSATF001 DESCRIPTION STR0001 //"Servicos do aplicativo mobile do ATF"
    WSDATA date      AS STRING  OPTIONAL
    WSDATA fields    AS STRING  OPTIONAL
    WSDATA language  AS STRING  OPTIONAL
    WSDATA operation AS STRING  OPTIONAL
    WSDATA page      AS INTEGER OPTIONAL
    WSDATA pageSize  AS INTEGER OPTIONAL
    WSDATA rawimage  AS STRING  OPTIONAL
    WSDATA barcode   AS STRING  OPTIONAL
    WSDATA searchKey AS STRING  OPTIONAL
    WSDATA type      AS INTEGER OPTIONAL
    WSDATA status    AS STRING  OPTIONAL

    WSDATA asset        AS STRING
    WSDATA asset_type   AS STRING
    WSDATA balance_type AS STRING
    WSDATA invoice      AS STRING
    WSDATA entitie      AS STRING
    WSDATA item         AS STRING
    WSDATA sequence     AS STRING
    WSDATA series       AS STRING
    WSDATA supplier     AS STRING
    WSDATA unit         AS STRING
    WSDATA write_off    AS STRING
    WSDATA locations    AS STRING
    WSDATA assets       AS STRING
    

    WSMETHOD GET FldAsset ;
    DESCRIPTION STR0002 ; //"Retorna campos existentes da SN1"
    WSSYNTAX "fields/assets" ;
    PATH "fields/assets"

    WSMETHOD GET FldBalance ;
    DESCRIPTION STR0003 ; //"Retorna campos existentes da SN3"
    WSSYNTAX "fields/balances" ;
    PATH "fields/balances"

    WSMETHOD GET Assets ;
    DESCRIPTION STR0004 ; //"Faz a consulta de um ativo buscando pela chave N1_CBASE (asset) N1_ITEM (item)"
    WSSYNTAX "assets/{asset}/{item}" ;
    PATH "assets/{asset}/{item}"

    WSMETHOD GET Balances ;
    DESCRIPTION STR0005 ; //"Faz a consulta de um saldo pela chave N3_CBASE, N3_ITEM, N3_TIPO, N3_TPSALDO, N3_BAIXA e N3_SEQ"
    WSSYNTAX "assets/{asset}/{item}/balances/{asset_type}/{balance_type}/{write_off}/{sequence}" ;
    PATH "assets/{asset}/{item}/balances/{asset_type}/{balance_type}/{write_off}/{sequence}"

    WSMETHOD GET Image ;
    DESCRIPTION STR0006 ; //"Retorna a imagem de um ativo com imagem cadastrada"
    WSSYNTAX "assets/{asset}/{item}/image" ;
    PATH "assets/{asset}/{item}/image"

    WSMETHOD GET Invoice ;
    DESCRIPTION STR0007 ; //"Faz consulta dos campos da nota fiscal baseado na pesquisa N1_FORNEC, N1_LOJA, N1_NFISCAL, N1_NSERIE"
    WSSYNTAX "invoices/{supplier}/{unit}/{invoice}/{series}" ;
    PATH "invoices/{supplier}/{unit}/{invoice}/{series}"

    // metodos criado pois o parampath nao suporta que o ultimo parametros seja branco
    WSMETHOD GET Invoi1 ;
    DESCRIPTION STR0007 ; //"Faz consulta dos campos da nota fiscal baseado na pesquisa N1_FORNEC, N1_LOJA, N1_NFISCAL, N1_NSERIE"
    WSSYNTAX "invoices/{supplier}/{unit}/{invoice}" ;
    PATH "invoices/{supplier}/{unit}/{invoice}"

    WSMETHOD GET AstInv ;
    DESCRIPTION STR0008 ; //"Faz consulta dos campos da nota fiscal baseado na pesquisa N1_CBASE, N1_ITEM"
    WSSYNTAX "assets/{asset}/{item}/invoice" ;
    PATH "assets/{asset}/{item}/invoice"

    WSMETHOD GET ReqList ;
    DESCRIPTION STR0009 ; //"Pesquisa por requisicoes"
    WSSYNTAX "requests" ;
    PATH "requests"
    
    WSMETHOD GET Entities ;
    DESCRIPTION STR0010 ; //"Retorna a a lista de notas e ativos"
    WSSYNTAX "entities";
    PATH "entities"
    
    WSMETHOD GET Locations ;
    DESCRIPTION STR0011 ; //"Retorna a a lista de locais"
    WSSYNTAX "assets/locations";
    PATH "assets/locations"

    WSMETHOD POST Request ;
    DESCRIPTION STR0012 ; //"Inclui uma nova requisicao"
    WSSYNTAX "assets/request" ;
    PATH "assets/request"
    
    WSMETHOD PUT Image2 ;
    DESCRIPTION STR0013 ; //"Insere uma nova imagem no repositorio de imagens"
    WSSYNTAX "assets/{asset}/{item}/image" ;
    PATH "assets/{asset}/{item}/image"

    WSMETHOD PUT Latlng ;
    DESCRIPTION STR0014 ; //"Altera a latitude e longitude de um ativo"
    WSSYNTAX "assets/{asset}/{item}" ;
    PATH "assets/{asset}/{item}"
END WSRESTFUL

WSMETHOD GET FldAsset WSRECEIVE language WSSERVICE WSATF001
    Local jData   := Nil

    Default Self:language := "pt"

    language := Self:language

    //IIF(LDEBUG, CONOUT(SELF:GETMETHOD() + " " + SELF:GETURL() + SELF:GETPATH() + CRLF + ASSTRING(SELF:GETCONTENT()) + CRLF + CRLF), )

    // joga para eof assim o getfields nao retorna valor
    SN1->(DbGoBottom())
    SN1->(DbSkip())

    // pegando os campos do alias
    jData := JsonObject():New()
    jData["fields"] := GetFields("SN1", language)

    Self:SetContentType("application/json")
    Self:SetResponse(FwJsonSerialize(jData))
Return .T.


WSMETHOD GET FldBalance WSRECEIVE language WSSERVICE WSATF001
    Local jData   := Nil

    Default Self:language := "pt"

    language := Self:language

    //IIF(LDEBUG, CONOUT(SELF:GETMETHOD() + " " + SELF:GETURL() + SELF:GETPATH() + CRLF + ASSTRING(SELF:GETCONTENT()) + CRLF + CRLF), )

    // joga para eof assim o getfields nao retorna valor
    SN3->(DbGoBottom())
    SN3->(DbSkip())

    // pegando os campos do alias
    jData := JsonObject():New()
    jData["fields"] := GetFields("SN3", language)

    Self:SetContentType("application/json")
    Self:SetResponse(FwJsonSerialize(jData))
Return .T.


WSMETHOD GET Assets PATHPARAM asset,item WSRECEIVE fields,language WSSERVICE WSATF001
    Local cTmp    := GetNextAlias()
    Local jData   := JsonObject():New()
    Local jTmp    := Nil
    Local jTmp1    := Nil

    // campos e linguage padrao para a consulta
    Default Self:fields   := "N1_GRUPO,N1_CBASE,N1_ITEM,N1_QUANTD,N1_AQUISIC,N1_DESCRIC,N1_CHAPA,N1_STATUS"
    Default Self:language := "pt" 

    If Empty(Self:fields)
        Self:fields   := "N1_GRUPO,N1_CBASE,N1_ITEM,N1_QUANTD,N1_AQUISIC,N1_DESCRIC,N1_CHAPA,N1_STATUS"
    EndIf

    // ajustando as variaveis locais
    asset    := Self:asset
    item     := Self:item
    language := Self:language
    fields   := "%"+Self:fields+"%"

    //IIF(LDEBUG, CONOUT(SELF:GETMETHOD() + " " + SELF:GETURL() + SELF:GETPATH() + CRLF + ASSTRING(SELF:GETCONTENT()) + CRLF + CRLF), )

    //////////////////////////////////////////////
    // primeira consulta obtem os campos da SN1 //
    //////////////////////////////////////////////
    BEGINSQL ALIAS cTmp
        SELECT %exp:fields%
        FROM %table:SN1%
        WHERE
		%notdel%
        AND N1_FILIAL = %xFilial:SN1%
        AND N1_CBASE  = %exp:asset%
        AND N1_ITEM   = %exp:item%
    ENDSQL

    // nao foi encontrado o ativo, apenas retorna o erro
    If (cTmp)->(Eof())
        jData["error"]    := STR0015 //"Ativo nao existe"
        jData["solution"] := STR0017 + asset + STR0016 + item + STR0018 //" item " //"Ativo " //" nao existe"

        Self:SetContentType("application/json")
        Self:SetResponse(FwJsonSerialize(@jData))
        Return .T.
    EndIf

    // colocando os campos da SN1 no retorno
    jData["fields"] := GetFields(cTmp, language)
    (cTmp)->(DbCloseArea())

    /////////////////////////////////////////////////////////////////////////
    // segunda consulta pega informacoes que tem campos proprios como      //
    // localizacao, imagem e notas                                         //
    /////////////////////////////////////////////////////////////////////////
    BEGINSQL ALIAS cTmp
        SELECT N1_NFISCAL,N1_NSERIE,N1_FORNEC,N1_LOJA,N1_BITMAP,N1_LOCAL,NL_DESCRIC,N1_LAT,N1_LNG,A2_NREDUZ
        FROM %table:SN1% SN1
            LEFT JOIN %table:SNL% SNL
                ON N1_LOCAL = NL_CODIGO
            LEFT JOIN %table:SA2% SA2
                ON  N1_FORNEC = A2_COD
                AND N1_LOJA   = A2_LOJA
        WHERE
		SN1.%notdel%
        AND SN1.N1_FILIAL = %xFilial:SN1%
        AND SN1.N1_CBASE  = %exp:asset%
        AND SN1.N1_ITEM   = %exp:item%
    ENDSQL

    jData["invoices"] := {}

    // colocando os dados da nota (caso tenha dados de nota)
    If ! Empty(AllTrim((cTmp)->(N1_NFISCAL+N1_NSERIE+N1_FORNEC+N1_LOJA)))
        jTmp := JsonObject():New()

        jTmp["supplier"] := AllTrim((cTmp)->(N1_FORNEC))
        jTmp["unit"    ] := (cTmp)->(N1_LOJA)
        jTmp["invoice" ] := (cTmp)->(N1_NFISCAL)
        jTmp["series"  ] := (cTmp)->(N1_NSERIE)
        jTmp["name"    ] := AllTrim((cTmp)->(A2_NREDUZ))

        // apesar de ser um array no ativos temos uma nota por ativo
        jData["invoices"] := {jTmp}
    EndIf

    // logico que informa se possui imagem
    jData["image"] := AllTrim((cTmp)->(N1_BITMAP)) != ""

    // cria um objeto para armazenar o local
    jTmp  := JsonObject():New()
    jTmp1 := JsonObject():New()

    // informacoes da geolocalizacao
    If ! Empty((cTmp)->N1_LAT) .And. ! Empty((cTmp)->N1_LNG)
        jTmp["lat"] := (cTmp)->N1_LAT
        jTmp["lng"] := (cTmp)->N1_LNG
    EndIf
     	jData["location"] := jTmp
     
        // informacoes de localizacao do ativo no sistema  	 
     	jTmp1["code"]              := AllTrim((cTmp)->N1_LOCAL)              
     	jTmp1["description"]       := AllTrim((cTmp)->NL_DESCRIC)
        
     	jData["location"]["local"] := jTmp1
     	
    (cTmp)->(DbCloseArea())

    ////////////////////////////////////////////////////////////
    // terceira consulta pega as informacoes dos saldos a SN3 //
    ////////////////////////////////////////////////////////////
    BEGINSQL ALIAS cTmp
        SELECT N3_TIPO, N3_TPSALDO, N3_HISTOR, N3_BAIXA, N3_SEQ
        FROM %table:SN3%
        WHERE
		%notdel%
        AND N3_FILIAL = %xFilial:SN3%
        AND N3_CBASE  = %exp:asset%
        AND N3_ITEM   = %exp:item%
    ENDSQL

    jData["balances"] := {}

    While ! (cTmp)->(Eof())
        jTmp := JsonObject():New()

        jTmp["asset_type"  ] := (cTmp)->(N3_TIPO)
        jTmp["balance_type"] := (cTmp)->(N3_TPSALDO)
        jTmp["history"     ] := Alltrim((cTmp)->(N3_HISTOR))
        jTmp["write_off"   ] := (cTmp)->(N3_BAIXA)
        jTmp["sequence"    ] := (cTmp)->(N3_SEQ)
        jTmp["description" ] := ""

        Do Case
        Case (cTmp)->(N3_TIPO) == "01"
            jTmp["description"] := STR0019 //"DEPR.FISCAL"
        Case (cTmp)->(N3_TIPO) == "02"
            jTmp["description"] := STR0020 //"REAV.POSITIVA"
        Case (cTmp)->(N3_TIPO) == "03"
            jTmp["description"] := STR0021 //"ADIANTAMENTO"
        Case (cTmp)->(N3_TIPO) == "04"
            jTmp["description"] := STR0022 //"LEI8.200"
        Case (cTmp)->(N3_TIPO) == "05"
            jTmp["description"] := STR0023 //"REAV.NEGATIVA"
        Case (cTmp)->(N3_TIPO) == "06"
            jTmp["description"] := STR0024 //"DEPR.ACEL.ESP."
        Case (cTmp)->(N3_TIPO) == "07"
            jTmp["description"] := STR0025 //"DEPR.ACEL"
        Case (cTmp)->(N3_TIPO) == "08"
            jTmp["description"] := STR0026 //"DEPR.INCE.POSI"
        Case (cTmp)->(N3_TIPO) == "09"
            jTmp["description"] := STR0027 //"DEPR.INCE.REV"
        Case (cTmp)->(N3_TIPO) == "10"
            jTmp["description"] := STR0028 //"DEPR.GERENCIAL"
        Case (cTmp)->(N3_TIPO) == "11"
            jTmp["description"] := STR0029 //"AMPLIACAO"
        Case (cTmp)->(N3_TIPO) == "12"
            jTmp["description"] := STR0030 //"VAL.RECUPERAVEL"
        Case (cTmp)->(N3_TIPO) == "13"
            jTmp["description"] := STR0031 //"ADIANT.GERENCIAL"
        Case (cTmp)->(N3_TIPO) == "14"
            jTmp["description"] := STR0032 //"AVP.IMOBILIZADO"
        Case (cTmp)->(N3_TIPO) == "15"
            jTmp["description"] := STR0033 //"MARG.GERENCIAL"
        Case (cTmp)->(N3_TIPO) == "16"
            jTmp["description"] := STR0034 //"VAL.JUS.POS"
        Case (cTmp)->(N3_TIPO) == "17"
            jTmp["description"] := STR0035 //"VAL.JUS.NEG"
        Otherwise
            jTmp["description"] += AsString((cTmp)->(N3_TIPO))
        EndCase

        Do Case
        Case (cTmp)->(N3_TPSALDO) == "0"
            jTmp["description"] += STR0036 //"/ORCADO"
        Case (cTmp)->(N3_TPSALDO) == "1"
            jTmp["description"] += STR0037 //"/REAL"
        Case (cTmp)->(N3_TPSALDO) == "2"
            jTmp["description"] += STR0038 //"/PREVISTO"
        Case (cTmp)->(N3_TPSALDO) == "3"
            jTmp["description"] += STR0039 //"/GERENCIAL"
        Case (cTmp)->(N3_TPSALDO) == "4"
            jTmp["description"] += STR0040 //"/EMPENHADO"
        Case (cTmp)->(N3_TPSALDO) == "9"
            jTmp["description"] += STR0041 //"/PRE-LANCAMENTO"
        Otherwise
            jTmp["description"] += "/" + AsString((cTmp)->(N3_TPSALDO))
        EndCase

        jTmp["description"] += " - " + AllTrim((cTmp)->(N3_HISTOR))

        AAdd(jData["balances"], jTmp)
        (cTmp)->(DbSkip())
    EndDo

    (cTmp)->(DbCloseArea())

    Self:SetContentType("application/json")
    Self:SetResponse(FwJsonSerialize(jData))
Return .T.


WSMETHOD GET Balances PATHPARAM asset,item,asset_type,balance_type,write_off,sequence WSRECEIVE fields,language WSSERVICE WSATF001
    Local cTmp    := GetNextAlias()
    Local jData   := Nil

    // campos e linguage padrao para a consulta
    Default Self:fields   := "N3_CBASE,N3_ITEM,N3_TIPO,N3_TPSALDO,N3_BAIXA,N3_SEQ,N3_HISTOR,N3_TPDEPR,N3_CCONTAB,N3_CDEPREC,N3_VORIG1,N3_TXDEPR1"
    
    Default Self:language := "pt"

    If Empty(Self:fields)
        Self:fields   := "N3_CBASE,N3_ITEM,N3_TIPO,N3_TPSALDO,N3_BAIXA,N3_SEQ,N3_HISTOR,N3_TPDEPR,N3_CCONTAB,N3_CDEPREC,N3_VORIG1,N3_TXDEPR1"
    EndIf
    
    // ajustando as variaveis locais
    asset        := Self:asset
    asset_type   := Self:asset_type
    balance_type := Self:balance_type
    item         := Self:item
    language     := Self:language
    sequence     := Self:sequence
    write_off    := Self:write_off
    fields       := "%"+Self:fields+"%"

    //IIF(LDEBUG, CONOUT(SELF:GETMETHOD() + " " + SELF:GETURL() + SELF:GETPATH() + CRLF + ASSTRING(SELF:GETCONTENT()) + CRLF + CRLF), )

    BEGINSQL ALIAS cTmp
        SELECT %exp:fields%
        FROM %table:SN3%
        WHERE
        %notdel%
        AND N3_FILIAL  = %xFilial:SN3%
        AND N3_CBASE   = %exp:asset%
        AND N3_ITEM    = %exp:item%
        AND N3_TIPO    = %exp:asset_type%
        AND N3_TPSALDO = %exp:balance_type%
        AND N3_BAIXA   = %exp:write_off%
        AND N3_SEQ     = %exp:sequence%
    ENDSQL

    If (cTmp)->(Eof())
        jData["error"]    := STR0042 //"O ativo nao possui o saldo solicitado"
        jData["solution"] := STR0043 + asset + STR0016 + item + STR0045 + asset_type + ", " + balance_type + STR0044 + sequence + "!" //"Verificar se o ativo " //" item " //" sequencia " //", possui o saldo "

        Self:SetContentType("application/json")
        Self:SetResponse(FwJsonSerialize(@jData))
        Return .T.
    EndIf

    // colocando os campos da SN1 no retorno
    jData := JsonObject():New()
    jData["fields"] := GetFields(cTmp, language)

    (cTmp)->(DbCloseArea())

    Self:SetContentType("application/json")
    Self:SetResponse(FwJsonSerialize(jData))
Return .T.


WSMETHOD GET Image PATHPARAM asset,item WSRECEIVE rawimage WSSERVICE WSATF001
    Local cData     := ""
    Local cTmp      := GetNextAlias()
    Local nFile     := ""
    Local cFile     := ""
    Local cMime     := "image/jpeg"

    asset    := Self:asset
    item     := Self:item
    rawimage := Self:rawimage

    //IIF(LDEBUG, CONOUT(SELF:GETMETHOD() + " " + SELF:GETURL() + SELF:GETPATH() + CRLF + CRLF), )

    BEGINSQL ALIAS cTmp
        SELECT N1_BITMAP
        FROM %table:SN1%
        WHERE
		%notdel%
        AND N1_FILIAL = %xFilial:SN1%
        AND N1_CBASE  = %exp:asset%
        AND N1_ITEM   = %exp:item%
    ENDSQL

    // Tem imagem
    If ! (cTmp)->(Eof())

        // foi possivel extrair a imagem do repositorio
        cFile := AllTrim((cTmp)->N1_BITMAP) + ".jpg"
        If RepExtract(AllTrim((cTmp)->N1_BITMAP), cFile)

            // conseguiu abrir o arquivo e ler o conteudo
            nFile := FOpen(cFile)
            If nFile > -1

                // le o conteudo
                cData := ReadAllFile(nFile)
                FClose(nFile)

                // tenta identificar o mime da imagem
                Do Case
                    Case Left(cData, 2) == Chr(255) + Chr(216)    // jpeg
                        cMime := "image/jpeg"
                    Case Left(cData, 2) == Chr(66) + Chr(77)      // bmp
                        cMime := "image/bmp"
                EndCase

                // ajusta codificacao
                If Empty(rawimage)
                    Self:SetContentType("application/json")
                    cData := '{"content": "data:' + cMime + ';base64,' + Encode64(cData)+ '"}'
                Else
                    Self:SetContentType(cMime)
                EndIf
            EndIf

            // remove o arquivo do servidor
            FErase(cFile)
        EndIf
    EndIf

    (cTmp)->(DbCloseArea())

    Self:SetResponse(cData)
Return .T.


WSMETHOD GET Invoice PATHPARAM supplier,unit,invoice,series WSRECEIVE language,page,pageSize WSSERVICE WSATF001
    Local cTmp    := GetNextAlias()
    Local jData   := JsonObject():New()
    Local jTmp    := Nil

    invoice  := Self:invoice
    series   := Self:series
    supplier := Self:supplier
    unit     := Self:unit

    //IIF(LDEBUG, CONOUT(SELF:GETMETHOD() + " " + SELF:GETURL() + SELF:GETPATH() + CRLF + ASSTRING(SELF:GETCONTENT()) + CRLF + CRLF), )

    // pegando as informacoes da nota
    BEGINSQL ALIAS cTmp
        SELECT F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, A2_NOME, A2_NREDUZ
        FROM %table:SF1% SF1
            INNER JOIN %table:SA2% SA2
                ON F1_FORNECE = A2_COD AND F1_LOJA = A2_LOJA
        WHERE
		SF1.%notdel%
        AND F1_FILIAL  = %xFilial:SF1% 
        AND F1_FORNECE = %exp:supplier%
        AND F1_LOJA    = %exp:unit%
        AND F1_DOC     = %exp:invoice%
        AND F1_SERIE   = %exp:series%
    ENDSQL

    // tem nota pega os dados
    If ! (cTmp)->(Eof())

        // dados da nota
        jData["fields"] := GetFields(cTmp, language)

        (cTmp)->(DbCloseArea())

        // pegando itens da nota
        BEGINSQL ALIAS cTmp
            SELECT D1_FORNECE, D1_LOJA, D1_DOC, D1_SERIE, D1_ITEM, D1_COD, B1_DESC, D1_QUANT, D1_VUNIT, D1_TOTAL
            FROM %table:SD1% SD1
                INNER JOIN %table:SB1% SB1
                    ON D1_COD = B1_COD
            WHERE
            SD1.%notdel%
            AND D1_FILIAL  = %xFilial:SD1% 
            AND D1_FORNECE = %exp:supplier%
            AND D1_LOJA    = %exp:unit%
            AND D1_DOC     = %exp:invoice%
            AND D1_SERIE   = %exp:series%
        ENDSQL

        jData["items"] = {}
        While ! (cTmp)->(Eof())
            jTmp := JsonObject():New()

            jTmp["item"]        := (cTmp)->D1_ITEM
            jTmp["product"]     := (cTmp)->D1_COD
            jTmp["description"] := AllTrim((cTmp)->B1_DESC)
            jTmp["quantity"]    := (cTmp)->D1_QUANT
            jTmp["unity_value"] := (cTmp)->D1_VUNIT
            jTmp["total_value"] := (cTmp)->D1_TOTAL

            AAdd(jData["items"], jTmp)

            (cTmp)->(DbSkip())
        EndDo

        (cTmp)->(DbCloseArea())

        BEGINSQL ALIAS cTmp
            SELECT N1_FILIAL, N1_CBASE, N1_ITEM, N1_DESCRIC
            FROM %table:SN1% SN1
            WHERE
            SN1.%notdel%
            AND N1_FILIAL  = %xFilial:SN1% 
            AND N1_FORNEC  = %exp:supplier%
            AND N1_LOJA    = %exp:unit%
            AND N1_NFISCAL = %exp:invoice%
            AND N1_NSERIE  = %exp:series%
        ENDSQL

        jData["assets"] = {}
        While ! (cTmp)->(Eof())
            jTmp := JsonObject():New()

            jTmp["asset"]       := (cTmp)->N1_CBASE
            jTmp["item"]        := (cTmp)->N1_ITEM
            jTmp["description"] := AllTrim((cTmp)->N1_DESCRIC)

            AAdd(jData["assets"], jTmp)

            (cTmp)->(DbSkip())
        EndDo
    
    // nao foi localizado nenhum registro
    Else
        jData["error"]    := STR0046 //"Nao foi localizado a nota especificada "
		jData["solution"] := STR0047 + invoice + STR0049 + series + STR0048  + supplier  + STR0099  + unit + "!" //"Verifique se o numero de nota " //" existem para o fornecedor " //" e serie "

    EndIf

    (cTmp)->(DbCloseArea())

    Self:SetContentType("application/json")
    Self:SetResponse(FwJsonSerialize(jData))
Return .T.

// metodos criado pois o parampath nao suporta que o ultimo parametros seja branco
WSMETHOD GET Invoi1 PATHPARAM supplier,unit,invoice WSRECEIVE language,page,pageSize WSSERVICE WSATF001
    Default Self:series := ""

    //IIF(LDEBUG, CONOUT(SELF:GETMETHOD() + " " + SELF:GETURL() + SELF:GETPATH() + CRLF + ASSTRING(SELF:GETCONTENT()) + CRLF + CRLF), )
Return Self:GET_INVOICE()


WSMETHOD GET Entities WSRECEIVE searchKey,barcode,type,page,pageSize WSSERVICE WSATF001
    Local cTmp    := GetNextAlias()
    Local jData   := Nil
    Local jTmp    := Nil
    Local nPage   := 0
    Local nSkip   := 0
    Local nI      := 0
    
    Default Self:pageSize  := 10
    Default Self:page      := 1
    Default Self:type      := 0
    Default Self:barcode   := ""
    Default Self:searchKey := ""

    searchKey   := Upper(Self:searchKey)
    barcode     := Upper(Self:barcode)
    type        := Self:type
    page        := Self:page
    pageSize    := Self:pageSize

    //IIF(LDEBUG, CONOUT(SELF:GETMETHOD() + " " + SELF:GETURL() + SELF:GETPATH() + CRLF + ASSTRING(SELF:GETCONTENT()) + CRLF + CRLF), )

    jData := JsonObject():New()
    jData["entities"] := {}
    jData["hasNext"]  := .F.

    If Empty(searchKey)
        searchKey := barcode
    EndIf
    
    searchKey := StrTran(searchKey, " ", "%")
    searchKey := "%'%" + searchKey + "%'%"

    BEGINSQL ALIAS cTmp
        SELECT DISTINCT N1_CBASE, N1_ITEM, N1_DESCRIC, N1_NFISCAL, N1_NSERIE, N1_FORNEC, N1_LOJA, A2_NOME
        FROM %table:SN1% SN1
            LEFT JOIN %table:SD1% SD1 ON
                D1_FILIAL  = %xFilial:SD1%
                AND N1_NFISCAL = D1_DOC
                AND N1_NSERIE = D1_SERIE
                AND N1_FORNEC = D1_FORNECE
                AND N1_LOJA = D1_LOJA
                AND SD1.%notdel%
            LEFT JOIN %table:SA2% SA2 ON
                A2_FILIAL  = %xFilial:SA2%
                AND N1_FORNEC = A2_COD
                AND N1_LOJA = A2_LOJA
                AND SA2.%notdel%
            LEFT JOIN %table:SB1% SB1 ON
                B1_FILIAL  = %xFilial:SB1%
                AND D1_COD = B1_COD
                AND SB1.%notdel%
            INNER JOIN %table:SN3% SN3 ON
                N1_CBASE = N3_CBASE
                AND N1_ITEM = N3_ITEM
                AND SN3.%notdel%
                AND N3_FILIAL  = %xFilial:SN3%
        WHERE
        SN1.%notdel%
        AND N1_FILIAL  = %xFilial:SN1%
        AND (N1_DESCRIC LIKE %exp:searchKey%
            OR  N1_CBASE LIKE %exp:searchKey%
            OR  N1_PLACA LIKE %exp:searchKey%
            OR  N1_CODBAR LIKE %exp:searchKey%
            OR  N1_NFISCAL LIKE %exp:searchKey%
            OR  N3_HISTOR LIKE %exp:searchKey%
            OR  A2_NOME LIKE %exp:searchKey%
            OR  A2_NREDUZ LIKE %exp:searchKey%
            OR  B1_DESC LIKE %exp:searchKey%
            OR  N1_PLACA LIKE %exp:searchKey%
            OR  N1_CHAPA LIKE %exp:searchKey%
            OR  N1_CODBAR LIKE %exp:searchKey%
            OR  N1_NFISCAL LIKE %exp:searchKey%)
        ORDER BY N1_CBASE, N1_ITEM, N1_DESCRIC
    ENDSQL
    
    // TODO:  verificar com framework se skip de n registros funciona e tirar o for
    nSkip := (page - 1) * pageSize
    For nI := 1 To nSkip
        (cTmp)->(DbSkip())
    Next nI

    While ! (cTmp)->(Eof()) .And. nPage < pageSize
        jTmp := Nil

        Do Case
            Case type == 0 // asset
                jTmp := JsonObject():New()
                jTmp["type"]:= type
                jTmp["asset"]:= (cTmp)->N1_CBASE
                jTmp["item"]:= (cTmp)->N1_ITEM
                jTmp["description"]:= AllTrim((cTmp)->N1_DESCRIC)

            Case type == 1 // nota
                If ! Empty((cTmp)->N1_NFISCAL + (cTmp)->N1_NSERIE)
                    jTmp := JsonObject():New()
                    jTmp["type"]:= type
                    jTmp["invoice"]:= (cTmp)->N1_NFISCAL
                    jTmp["series"]:= (cTmp)->N1_NSERIE

                    jTmp["supplier"] := JsonObject():New()
                    jTmp["supplier"]["name"] := AllTrim((cTmp)->A2_NOME)
                    jTmp["supplier"]["id"] := (cTmp)->N1_FORNEC
                    jTmp["unit"]:= (cTmp)->N1_LOJA
                    
                EndIf
        EndCase

        If jTmp != Nil
            AAdd(jData["entities"], jTmp)
            nPage += 1
        EndIf

        (cTmp)->(DbSkip())
    EndDo

    // tenta pegar mais um registro para ver se tem proximo
    (cTmp)->(DbSkip())

    If nPage == pageSize .And. ! (cTmp)->(Eof())
        jData["hasNext"]  := .T.
    Else
        jData["hasNext"]  := .F.
    EndIf

    (cTmp)->(DbCloseArea())

    Self:SetContentType("application/json")
    Self:SetResponse(FwJsonSerialize(jData))
Return .T.


WSMETHOD GET AstInv PATHPARAM asset,item WSRECEIVE language,page,pageSize WSSERVICE WSATF001
    Local cTmp    := GetNextAlias()
    Local jData   := JsonObject():New()

    asset := Self:asset
    item  := Self:item

    //IIF(LDEBUG, CONOUT(SELF:GETMETHOD() + " " + SELF:GETURL() + SELF:GETPATH() + CRLF + ASSTRING(SELF:GETCONTENT()) + CRLF + CRLF), )

    BEGINSQL ALIAS cTmp
        SELECT N1_FORNEC, N1_LOJA, N1_NFISCAL, N1_NSERIE
        FROM %table:SN1% SN1
        WHERE
        SN1.%notdel%
        AND N1_FILIAL = %xFilial:SN1% 
        AND N1_CBASE  = %exp:asset%
        AND N1_ITEM   = %exp:item%
    ENDSQL

    // ativo possui dados de nota
    If ! (cTmp)->(Eof())
        Self:invoice  := (cTmp)->N1_NFISCAL
        Self:series   := (cTmp)->N1_NSERIE
        Self:supplier := (cTmp)->N1_FORNEC
        Self:unit     := (cTmp)->N1_LOJA
        Self:GET_INVOICE()

    // ativo nao possui dados de nota
    Else
        jData["error"]    := STR0015 //"Ativo nao existe"
		jData["solution"] := STR0017 + asset + STR0016 + item + STR0018 //" item " //"Ativo " //" nao existe"

        Self:SetContentType("application/json")
        Self:SetResponse(FwJsonSerialize(@jData))
    EndIf

    (cTmp)->(DbCloseArea())
Return .T.


WSMETHOD GET ReqList WSRECEIVE operation,status,date,page,pageSize WSSERVICE WSATF001
    Local cFilter := "% "
    Local cTmp    := GetNextAlias()
    Local jData   := JsonObject():New()
    Local jTmp    := Nil
    Local nCount  := 0
    Local nSkip   := 0

    Default Self:page     := 1
    Default Self:pageSize := 10

    date      := Self:date
    operation := Self:operation
    page      := Self:page
    pageSize  := Self:pageSize
    status    := Self:status

    //IIF(LDEBUG, CONOUT(SELF:GETMETHOD() + " " + SELF:GETURL() + SELF:GETPATH() + CRLF + ASSTRING(SELF:GETCONTENT()) + CRLF + CRLF), )

    If !Empty(date)
        cFilter += " AND NZ_DATA LIKE '" + date + "%' "
    EndIf

    If !Empty(operation)
        cFilter += " AND NZ_OPER = '" + operation + "' "
    EndIf

    If !Empty(status)
        cFilter += " AND NZ_STATUS = '" + status + "' "
    EndIf

    cFilter += "%"

    BEGINSQL ALIAS cTmp
        SELECT *
        FROM %table:SNZ% SNZ
        WHERE
        SNZ.%notdel%
        %exp:cFilter%
    ENDSQL

    jData["requests"] := {}

    nSkip := (page - 1) * pageSize
    If nSkip > 0
        (cTmp)->(DbSkip(nSkip))
    EndIf

    While ! (cTmp)->(Eof()) .And. nCount < pageSize
        jTmp := JsonObject():New()

        jTmp["operation"] := (cTmp)->NZ_OPER
        jTmp["status"]    := (cTmp)->NZ_STATUS
        jTmp["date"]      := (cTmp)->NZ_DATA
        jTmp["reason"]    := EncodeUTF8(AllTrim((cTmp)->NZ_DESCRI), "cp1252")
        
        If (cTmp)->NZ_OPER == "0"
            jTmp["value"]    := (cTmp)->NZ_VALOR
            jTmp["quantity"] := (cTmp)->NZ_QUANT

            jTmp["balances"] := {JsonObject():New()}
            jTmp["balances"][1]["asset_type"]   := (cTmp)->NZ_TIPO
            jTmp["balances"][1]["balance_type"] := (cTmp)->NZ_TPSALDO
        EndIf

        If (cTmp)->NZ_OPER == "1"
            jTmp["type"]     := (cTmp)->NZ_TRANSF
        EndIf

        If (cTmp)->NZ_OPER == "2"
            jTmp["value"] := (cTmp)->NZ_VALOR
        EndIf

        AAdd(jData["requests"], jTmp)

        (cTmp)->(DbSkip())
        nCount += 1
    EndDo

    If nCount == pageSize
        jData["hasNext"] := .T.
    Else
        jData["hasNext"] := .F.
    EndIf

    (cTmp)->(DbCloseArea())

    Self:SetContentType("application/json")
    Self:SetResponse(FwJsonSerialize(jData))
Return .T.

WSMETHOD GET Locations PATHPARAM asset,locations WSRECEIVE page,pageSize,searchKey  WSSERVICE WSATF001
 
    Local cTmp    := GetNextAlias()
    Local jData   := JsonObject():New()
    Local jTmp    := Nil
    Local nCount  := 0
    Local nSkip   := 0

    Default Self:page     := 1
    Default Self:pageSize := 10
    Default Self:searchKey := ""
    
    searchKey   := Upper(Self:searchKey)
    page      := Self:page
    pageSize  := Self:pageSize

    searchKey := StrTran(searchKey, " ", "%")
    searchKey := "%'%" + searchKey + "%'%"

    //IIF(LDEBUG, CONOUT(SELF:GETMETHOD() + " " + SELF:GETURL() + SELF:GETPATH() + CRLF + ASSTRING(SELF:GETCONTENT()) + CRLF + CRLF), )

    BEGINSQL ALIAS cTmp
        SELECT NL_CODIGO, NL_DESCRIC
        FROM %table:SNL% SNL
        WHERE
        NL_BLOQ  <> "1" // 1 = Bloqueado
        AND SNL.%notdel% 
        AND NL_FILIAL  = %xFilial:SNL%
        AND (NL_CODIGO LIKE %exp:searchKey% 
        OR  NL_DESCRIC LIKE %exp:searchKey%)
        ORDER BY NL_DESCRIC, NL_CODIGO
    ENDSQL

	jData["locations"] := {}
	
	IF !(cTmp)->(Eof()) 
		nSkip := (page - 1) * pageSize
		If nSkip > 0
		    (cTmp)->(DbSkip(nSkip))
		EndIf
		
		While ! (cTmp)->(Eof()) .And. nCount < pageSize
			jTmp := JsonObject():New()
		    jTmp["code"] 			:= AllTrim((cTmp)->NL_CODIGO)
		    jTmp["description"]    := AllTrim((cTmp)->NL_DESCRIC)
		
		    AAdd(jData["locations"], jTmp)
		
		    (cTmp)->(DbSkip())
		    nCount += 1
		EndDo
		
		If nCount == pageSize
		    jData["hasNext"] := .T.
		Else
		    jData["hasNext"] := .F.
		EndIf
	Else	
		jData["hasNext"] := .F.
	EndIf

    (cTmp)->(DbCloseArea())

    Self:SetContentType("application/json")
    Self:SetResponse(FwJsonSerialize(jData))
Return .T.

WSMETHOD POST Request WSSERVICE WSATF001
    Local aError    := {}
    Local jData     := Nil
    Local jResponse := JsonObject():New()
    Local oAF500    := FwLoadModel("ATFA500")
    Local oSNZ      := oAF500:GetModel("MODEL_SNZ")

    //IIF(LDEBUG, CONOUT(SELF:GETMETHOD() + " " + SELF:GETURL() + SELF:GETPATH() + CRLF + ASSTRING(SELF:GETCONTENT()) + CRLF + CRLF), )

    FwJsonDeserialize(Self:GetContent(), @jData)

    oAF500:SetOperation(OP_INCLUIR)
    oAF500:Activate()

    oSNZ:SetValue("NZ_FILIAL", xFilial("SNZ"))
    oSNZ:SetValue("NZ_CBASE" , jData["asset"])
    oSNZ:SetValue("NZ_ITEM"  , jData["item"])
    oSNZ:SetValue("NZ_DATA"  , Date())
    oSNZ:SetValue("NZ_STATUS", "0")
    oSNZ:SetValue("NZ_DESCRI", DecodeUTF8(jData["reason"], "cp1252"))
    oSNZ:SetValue("NZ_OPER"  , jData["operation"])

    Do Case
        // Baixa
        Case jData["operation"] == "0"
            oSNZ:SetValue("NZ_TIPO"   , jData["balance"]["type"])
            oSNZ:SetValue("NZ_TPSALDO", jData["balance"]["balance_type"])
            oSNZ:SetValue("NZ_VALOR"  , Val(jData["value"]))
            oSNZ:SetValue("NZ_QUANT"  , Val(jData["quantity"]))

        // Transferencia
        Case jData["operation"] == "1"
            oSNZ:SetValue("NZ_TRANSF"  , jData["type"])

        // Ampliacao
        Case jData["operation"] == "2"
            oSNZ:SetValue("NZ_VALOR"  , Val(jData["value"]))
    EndCase

    If oAF500:VldData()
        oAF500:CommitData()
        jResponse["sucess"] := STR0100 + jData["operation"] + STR0101 //"Operação " + jData["operation"] + " realizada com sucesso "
    Else
        aError := oAF500:GetErrorMessage()
        jResponse["fieldId"] := aError[4]
        jResponse["errorId"] := aError[5]
        jResponse["error"] := aError[6]
        jResponse["solution"] := aError[7]

        SetRestFault(500, STR0050) //"Erro ao incluir solicitacao"
    EndIf

    oAF500:Deactivate()
    oAF500:Destroy()

    Self:SetContentType("application/json")
    Self:SetResponse(FwJsonSerialize(jResponse))
Return .T.


WSMETHOD PUT Image2 PATHPARAM asset,item WSRECEIVE rawimage WSSERVICE WSATF001
    Local cData      := ""
	Local cFilename  := ""
    Local cFilename2 := ""
    Local cTmp       := GetNextAlias()
    Local jData      := Nil
	Local jResponse  := JsonObject():New()
	Local lSucesso   := .F.
	Local nFile      := -1
    Local nVirgula   := 1
	Local oRep       := FWBmpRep():New()
	
	Default asset := Self:asset
	Default item := Self:item

    //IIF(LDEBUG, CONOUT(SELF:GETMETHOD() + " " + SELF:GETURL() + SELF:GETPATH() + CRLF + CRLF), )
	
	BEGINSQL ALIAS cTmp
        SELECT N1_BITMAP, R_E_C_N_O_
        FROM %table:SN1%
        WHERE
        %notdel% 
        AND N1_FILIAL = %xFilial:SN1%
        AND N1_CBASE  = %exp:asset%
        AND N1_ITEM   = %exp:item%
    ENDSQL
    
    // o ativo que a imagem vai ser salva existe? 
    If ! (cTmp)->(Eof())
    	
    	// exclui a imagem que ja existe
    	If ! Empty(Alltrim((cTmp)->(N1_BITMAP)))
    		oRep:DeleteBmp(Alltrim((cTmp)->(N1_BITMAP)))
    	EndIf
    	
    	// iria utilizar o UUID porem a funcao que grava no repositorio trunca em 20 caracteres
        // logo perco a capacidade de unicidade do nome do arquivo, foi feita uma funcao baseada
        // na data e hora e um numero aleatorio, testa se o arquivo existe para garantir unicidade
    	cFilename := RandomName()
        While oRep:ExistBMP(cFilename)
            cFilename := RandomName()
        EndDo
        
        // adiciona a extensao no arquivo (eh necessario por causa do repositorio auxiliar)
        cFilename += ".jpg"
    	nFile := FCreate(cFilename)
    	
    	// arquivo aberto com sucesso
    	If nFile > -1
            FwJsonDeserialize(Self:GetContent(), @jData)

            // pega o conteudo e remove o cabecalho "data:image/jpeg;base64,"
            cData := jData["CONTENT"]
            nVirgula := At(",", cData) + 1

            // grava arquivo no servidor
    		FWrite(nFile, Decode64(SubStr(cData, nVirgula)))
    		FClose(nFile)
    		
    		// salva o arquivo no repositorio
    		cFilename2 := oRep:InsertBmp(cFilename,, @lSucesso)

    		// deleta o arquivo do servidor
    		FErase(cFilename)
    		
    		// grava o codigo a imagem do repositorio no ativo
    		If lSucesso
		    	SN1->(DbGoto((cTmp)->(R_E_C_N_O_)))
		    	
		    	// trava registro e grava bitmap
		    	SN1->(RecLock("SN1", .F.))
		    		SN1->N1_BITMAP := Alltrim(cFilename2)
		    	SN1->(MsUnlock())
		    	
		    	jResponse["sucess"] := STR0052 + cFilename2 + STR0051 //" gravada com sucesso no repositorio de imagens" //"Imagem "
		    Else
		    	jResponse["error"]    := STR0053 //"Nao foi possivel gravar a imagem no repositorio de imagens"
		        jResponse["solution"] := STR0054 //"Verificar se e possivel gravar arquivos no repositorio de imagem"
                SetRestFault(500, STR0055) //"Erro ao gravar imagem no repositorio"
		    EndIf
		    
		Else
			jResponse["error"]    := STR0056 + AsString(FError()) + ")" //"Nao foi possivel gravar o arquivo no servidor (ferror: "
	        jResponse["solution"] := STR0057 //"Verificar se Fcreate consegue criar arquivos no servidor"
            SetRestFault(500, STR0058) //"Erro ao gravar arquivo temporario"
    	EndIf
    	
    Else
    	jResponse["error"]    := STR0017 + asset + STR0059 + item + STR0060 //" e item " //" nao encontrado" //"Ativo "
        jResponse["solution"] := STR0061 //"Informar ativo e item validos"
        SetRestFault(404, STR0062) //"Erro ativo e item nao encontrado"
    EndIf
    
    oRep:CloseRepository()
    FreeObj(oRep)
    oRep := Nil

    (cTmp)->(DbCloseArea())

    Self:SetContentType("application/json")
    Self:SetResponse(FwJsonSerialize(jResponse))
Return .T.


WSMETHOD PUT Latlng PATHPARAM asset,item WSSERVICE WSATF001
    Local jData     := Nil
    Local jResponse := JsonObject():New()
    Local cTmp       := GetNextAlias()
    
    asset := Self:asset
    item  := Self:item

    //IIF(LDEBUG, CONOUT(SELF:GETMETHOD() + " " + SELF:GETURL() + SELF:GETPATH() + CRLF + ASSTRING(SELF:GETCONTENT()) + CRLF + CRLF), )

    BEGINSQL ALIAS cTmp
        SELECT R_E_C_N_O_
        FROM %table:SN1%
        WHERE
		%notdel%
        AND N1_FILIAL = %xFilial:SN1%
        AND N1_CBASE  = %exp:asset%
        AND N1_ITEM   = %exp:item%
    ENDSQL

    FwJsonDeserialize(Self:GetContent(), @jData)
	If jData["type"] == "local" .OR. jData["type"] == "latlng"  
	    // encontrado o ativo
	    If ! (cTmp)->(Eof())
	
	        // posiciona registro e trava o arquivo
	        SN1->(DbGoto((cTmp)->(R_E_C_N_O_)))
	
	        If SN1->(RecLock("SN1", .F.))
	        
	        	If jData["type"] == "local"
	        	//codigo para local
		            SN1->N1_LOCAL := jData["LOCATION"]["LOCAL"]
                    
                    jResponse["local"]    := jData["LOCATION"]["LOCAL"]
	        	
                ElseIf jData["type"] == "latlng"
	        		SN1->N1_LAT   := jData["LOCATION"]["LAT"]
	        		SN1->N1_LNG   := jData["LOCATION"]["LNG"]

                    jResponse["lat"]    := jData["LOCATION"]["LAT"]
                    jResponse["lng"]    := jData["LOCATION"]["LNG"]
	    		EndIf
	
			    SN1->(MsUnlock())	
	        Else
	            jResponse["error"]    := STR0063 //"Impossivel obter lock para ativo"
	            jResponse["solution"] := STR0043 + asset + STR0059 + item + STR0064  //" e item " //" ja esta sendo utilizado" //"Verificar se o ativo "
	            SetRestFault(500, STR0065) //"Impossivel obter lock para o ativo selecionado"
	        EndIf
	
	    // nao encontrado o arquivo
	    Else
	        jResponse["error"]    := STR0015 //"Ativo nao existe"
	        jResponse["solution"] := STR0017 + asset + STR0016 + item + STR0018 //" item " //" nao existe" //"Ativo "
	        SetRestFault(404, STR0015) //"Ativo nao existe"
	    EndIf
	Else
		jResponse["error"]    := "Type invalido"
		jResponse["solution"] := STR0066 //"Informar type local ou latlng"
		SetRestFault(400, STR0067) //"Type invalido"
	EndIf
    (cTmp)->(DbCloseArea())


    Self:SetContentType("application/json")
    Self:SetResponse(FwJsonSerialize(jResponse))
Return .T.


Static Function GetFields(cAlias, cLanguage)
    Local aFields := {}
    Local aStruct := {}
    Local jField  := Nil
    Local nI      := 0

    aStruct := (cAlias)->(DbStruct())

    For nI := 1 To Len(aStruct)
        jField := JsonObject():New()

        jField["identifier"] := aStruct[nI][1]
        jField["label"     ] := GetTitulo(aStruct[nI][1], cLanguage)
        jField["type"      ] := aStruct[nI][2]

        // Caso tenha algum posicionamento retorna o valor
        If !(cAlias)->(Bof()) .And. !(cAlias)->(Eof())
            jField["value"] := (cAlias)->(&(aStruct[nI][1]))

            // tungada para mandar identificacao inves do codigo
            Do Case
            Case jField["identifier"] == "N3_TIPO"
                jField["type"] := "C"
                Do Case
                Case jField["value"] == "01"
                    jField["value"] := STR0068 //"DEPR. FISCAL"
                Case jField["value"] == "02"
                    jField["value"] := STR0069 //"REAVALIACAO POSITIVA"
                Case jField["value"] == "03"
                    jField["value"] := STR0021 //"ADIANTAMENTO"
                Case jField["value"] == "04"
                    jField["value"] := STR0070 //"LEI 8.200"
                Case jField["value"] == "05"
                    jField["value"] := STR0071 //"REAVALIACAO NEGATIVA"
                Case jField["value"] == "06"
                    jField["value"] := STR0072 //"DEPR. ACELERADA ESPECIFICA"
                Case jField["value"] == "07"
                    jField["value"] := STR0073 //"DEPR. ACELERADA"
                Case jField["value"] == "08"
                    jField["value"] := STR0074 //"DEPR. INCENTIVADA POSITIVA"
                Case jField["value"] == "09"
                    jField["value"] := STR0075 //"DEPR. INCENTIVADA REVERSA"
                Case jField["value"] == "10"
                    jField["value"] := STR0076 //"DEPR. GERENCIAL/CONTABIL"
                Case jField["value"] == "11"
                    jField["value"] := STR0029 //"AMPLIACAO"
                Case jField["value"] == "12"
                    jField["value"] := STR0077 //"VALOR RECUPERAVEL DE ATIVO"
                Case jField["value"] == "13"
                    jField["value"] := STR0078 //"ADIANTAMENTO GERENCIAL"
                Case jField["value"] == "14"
                    jField["value"] := STR0079 //"AVP DE IMOBILIZADO"
                Case jField["value"] == "15"
                    jField["value"] := STR0080 //"MARGEM GERENCIAL"
                Case jField["value"] == "16"
                    jField["value"] := STR0081 //"VALOR JUSTO POSITIVO SOCIETARIO"
                Case jField["value"] == "17"
                    jField["value"] := STR0082 //"VALOR JUSTO NEGATIVO SOCIETARIO"
                EndCase

            Case jField["identifier"] == "N3_TPSALDO"
                jField["type"] := "C"
                Do Case
                Case jField["value"] == "0"
                    jField["value"] := STR0083 //"ORCADO"
                Case jField["value"] == "1"
                    jField["value"] := STR0084 //"REAL"
                Case jField["value"] == "2"
                    jField["value"] := STR0085 //"PREVISTO"
                Case jField["value"] == "3"
                    jField["value"] := STR0086 //"GERENCIAL"
                Case jField["value"] == "4"
                    jField["value"] := STR0087 //"EMPENHADO"
                Case jField["value"] == "9"
                    jField["value"] := STR0088 //"PRE-LANCAMENTO"
                EndCase

            Case jField["identifier"] == STR0089 //"N1_STATUS"
                jField["type"] := "C"
                Do Case
                Case jField["value"] == "0"
                    jField["value"] := STR0090 //"PENDENTE DE CLASSIFICACAO"
                Case jField["value"] == "1"
                    jField["value"] := STR0091 //"EM USO"
                Case jField["value"] == "2"
                    jField["value"] := STR0092 //"BLOQUEADO POR USUARIO"
                Case jField["value"] == "3"
                    jField["value"] := STR0093 //"BLOQUEADO POR LOCAL"
                Case jField["value"] == "4"
                    jField["value"] := STR0094 //"TRANSF. INTERNA ENTRE FILIAIS"

                EndCase

            Case jField["identifier"] == STR0095 //"N3_BAIXA"
                jField["type"] := "C"
                Do Case
                Case jField["value"] == "0"
                    jField["value"] := STR0096 //"ATIVO"
                Case jField["value"] == "1"
                    jField["value"] := STR0097 //"BAIXA NORMAL"
                Case jField["value"] == "2"
                    jField["value"] := STR0098 //"BAIXA ADIANT."
                EndCase
            EndCase
        EndIf

        AAdd(aFields, jField)
    Next nI
Return aFields


Static Function GetTitulo(cField, cLanguage)
    Local aSX3 := SX3->(GetArea())
    Local cTit := ""

    Default cLanguage := "pt"

    SX3->(DbSetOrder(2))
    SX3->(DbSeek(cField))

    Do Case
        Case cLanguage == "pt"
            cTit := SX3->X3_TITULO
        Case cLanguage == "en"
            cTit := SX3->X3_TITENG
        Case cLanguage == "es"
            cTit := SX3->X3_TITSPA
        Otherwise
            cTit := SX3->X3_TITULO
    EndCase

    SX3->(RestArea(aSX3))
Return EncodeUtf8(AllTrim(cTit))


Static Function ReadAllFile(nHandle)
    Local cBuff := Space(2048)
    Local cData := ""
    Local nLido := 0

    While (nLido := FRead(nHandle, @cBuff, Len(cBuff))) > 0
        cData += Left(cBuff, nLido)
    EndDo
Return cData


Static Function RandomName()
    Local aHora     := StrTokArr2(Time(), ":")
    Local cFilename := ""
    Local nTamCamp  := ( TamSx3( "N1_BITMAP" )[1] )
 
    cFilename += StrZero(Randomize(0, 10000), 5)
    cFilename += aHora[3] + aHora[2] + aHora[1]
    cFilename += "_" + DtoS(Date())
    
    If nTamCamp < 20
    	cFilename := SubStr( cFilename, 1, nTamCamp )
    EndIf
    
    cFilename := Alltrim(cFilename)

Return cFilename
