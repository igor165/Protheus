#INCLUDE "RWMAKE.CH" 
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "JSON.CH"
#INCLUDE "AARRAY.CH"
#INCLUDE "TOPCONN.CH"

// User Function MBREST01(); return '20201015'

WSRESTFUL WSPesagem DESCRIPTION "Metodo para receber placa da portaria e fazer reserva na rotina de Pesagens." FORMAT APPLICATION_JSON
   
    WSDATA placa as String

    WSMETHOD GET RESERVAPLACA DESCRIPTION "Envia a placa e o WS retorna os dados do ultimo registro existente na rotina de pesagem." ;
                WSSYNTAX "/WSPesagem/{placa}" //PATH "/WSPesagem/{placa}"
    WSMETHOD POST RESERVAPLACA DESCRIPTION "Inclusão de reserva de placa para futura pesagem." ;
                WSSYNTAX "/WSPesagem/{placa}" //PATH "/WSPesagem/{placa}"
    // WSMETHOD GET DESCRIPTION "Exemplo de retorno de entidade(s)" WSSYNTAX "/WSPesagem || /WSPesagem/{placa}"
    // WSMETHOD PUT DESCRIPTION "Exemplo de alteração de entidade" WSSYNTAX "/WSPesagem/{placa}"
    // WSMETHOD DELETE DESCRIPTION "Exemplo de exclusão de entidade" WSSYNTAX "/WSPesagem/{placa}"

END WSRESTFUL

/*--------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 07.12.2021                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Envia a placa e o WS retorna os dados do ultimo registro existente na|
 |           rotina de pesagem.                                                    |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '--------------------------------------------------------------------------------*/
Class PlacaVeiculo
    Data agendamento_id         as String
    Data agendamento_data       as String
    Data fornecedor_nome        as String
    Data fornecedor_cnpj_cpf    as String
    Data motorista_nome         as String
    Data motorista_cpf          as String
    Data motorista_phone        as String
    Data placa                  as String
    Data produto_id             as String
    Data status                 as String
    Data departamento_id        as String
    Data empresa_id             as String
    Data porteiro_id            as String


    Method New( agendamento_id, agendamento_data, fornecedor_nome, fornecedor_cnpj_cpf, motorista_nome,;
         motorista_cpf, motorista_phone, placa, produto_id, status, departamento_id, empresa_id, porteiro_id) Constructor

EndClass
Method New( agendamento_id, agendamento_data, fornecedor_nome, fornecedor_cnpj_cpf,motorista_nome,;
    motorista_cpf, motorista_phone, placa, produto_id, status, departamento_id, empresa_id, porteiro_id) Class PlacaVeiculo
        
    ::agendamento_id            := agendamento_id        
    ::agendamento_data          := agendamento_data      
    ::fornecedor_nome           := fornecedor_nome 
    ::fornecedor_cnpj_cpf       := fornecedor_cnpj_cpf
    ::motorista_nome            := motorista_nome     
    ::motorista_cpf             := motorista_cpf   
    ::motorista_phone           := motorista_phone      
    ::placa                     := placa     
    ::produto_id                := produto_id     
    ::status                    := status     
    ::departamento_id           := departamento_id     
    ::empresa_id                := empresa_id     
    ::porteiro_id               := porteiro_id     
Return(Self)


WSMETHOD GET RESERVAPLACA WSRECEIVE WSSERVICE WSPesagem

Local aArea        := GetArea()
Local lRet         := .T.
// Local _aMotorista  := {}
Local _nRecnoZPB  := {}
Local oObjeto      := nil
Local cJson        := ""
Private placaTGet := Self:placa

ConOut("Inicio: WSMETHOD: " + Time())

// define o tipo de retorno do método
::SetContentType("application/json")

If Empty(placaTGet)
	
	ConOut("Sem Parametros")
	// ::SetResponse('{"retorno": 9, "descricao": "Codigo da placa nao informado"}')
	SetRestFault(400, "Codigo da placa nao informado")
    lRet := .F.
Else

    ConOut( "Placa: " + placaTGet )

    // _aMotorista := {"", "31039574831", "", "001", "Animal"}
    // _aMotorista := U_UltPesagemXPlaca(placaTGet)
    _nRecnoZPB := U_UltPesagemXPlaca(placaTGet)
    ConOut( "Recno ZPB: " + cValToChar(_nRecnoZPB) )

    // If Empty(_aMotorista) // preenchimento de campos automaticamente de acordo com a ultima pesagem do caminhao
    If Empty( _nRecnoZPB ) // preenchimento de campos automaticamente de acordo com a ultima pesagem do caminhao
       	
           //::SetResponse('{"retorno": 1, "descricao": "Esta placa nao foi encontrada em nossos registros."}')
	    SetRestFault(404, "Esta placa nao foi encontrada em nossos registros.")
        lRet := .F.

    Else
        // ConOut( U_AtoS(_aMotorista) )
        ZPB->(DbGoTo( _nRecnoZPB )) 

        oObjeto := PlacaVeiculo():New( 0,;
                                    placaTGet,;
                                    AllTrim(ZPB->ZPB_),;
                                    AllTrim(ZPB->ZPB_CPFMOT),;
                                    AllTrim(ZPB->ZPB_NOMMOT),;
                                    AllTrim(ZPB->ZPB_  ),;
                                    AllTrim(ZPB->ZPB_DESC  ),;
                                    AllTrim(ZPB->ZPB_DESC  ),;
                                    AllTrim(ZPB->ZPB_DESC  ),;
                                    AllTrim(ZPB->ZPB_DESC  ),;
                                    AllTrim(ZPB->ZPB_DESC  ),;
                                    AllTrim(ZPB->ZPB_DESC  ),;
                                    AllTrim(ZPB->ZPB_DESC  ),;
                                    "",;
                                    "",;
                                    dToC(dDataBase) + ' ' + Time() )

        // oObjeto := PlacaVeiculo():New( 0,;
        //                             placaTGet,;
        //                             AllTrim(_aMotorista[01, 09]),;
        //                             AllTrim(_aMotorista[01, 02]),;
        //                             AllTrim(_aMotorista[01, 03]),;
        //                             AllTrim(_aMotorista[01, 05]),;
        //                             "",;
        //                             "",;
        //                             dToC(dDataBase) + ' ' + Time() )

        // M->ZPB_CODMOT := _aMotorista[01, 01]
        // M->ZPB_CPFMOT := _aMotorista[01, 02]
        // M->ZPB_NOMMOT := _aMotorista[01, 03]
        // M->ZPB_PRODUT := _aMotorista[01, 04]
        // M->ZPB_DESC   := _aMotorista[01, 05]
        // M->ZPB_CLIFOR := _aMotorista[01, 06]
        // M->ZPB_CODFOR := _aMotorista[01, 07]
        // M->ZPB_LOJFOR := _aMotorista[01, 08]
        // M->ZPB_NOMFOR := _aMotorista[01, 09]
        // M->ZPB_LOCAL  := _aMotorista[01, 10]
        // M->ZPB_BAIA   := _aMotorista[01, 11]
        // M->ZPB_OBSERV := _aMotorista[01, 12]

        // --> Transforma o objeto de produtos em uma string json
        // cJson := '{"retorno": "0", "descricao": "Processo finalizado com sucesso."}'
        cJson := FwNoAccent( FWJsonSerialize(oObjeto, .F.) )
        ConOut( cJson )

        // --> Envia o JSON Gerado para a aplicação Client
        ::SetResponse(cJson)
    EndIf
EndIf
ConOut("Fim: WSMETHOD " + Time())
RestArea(aArea)

Return lRet

WSMETHOD POST RESERVAPLACA WSRECEIVE WSSERVICE WSPesagem

Local nI            := 0 // as Integer
Local oParseJson
Local cTextJson     := FwNoAccent( DecodeUtf8( ::GetContent() ) )
// Local cTextJson     := ::GetContent()

ConOut(Replicate("-", 100))
ConOut("inicio RESERVAPLACA: " + Time())

If !U_SetEnvironment()

Else
    // If Len(::aURLParms) > 0
    //     ::SetResponse('{"id":' + ::aURLParms[1] /* + ', "name":"sample"}' */)
    // EndIf

    For nI:=1 to Len(::aURLParms)
        ConOut(cValToChar(nI) + ": " + ::aURLParms[nI] )
    Next nI

    If FWJsonDeserialize(cTextJson, @oParseJson)
            
        ConOut( cTextJson )
        Begin Transaction

            RecLock( "ZWS", .T. )
                ZWS->ZWS_FILIAL := xFilial("ZWS")
                ZWS->ZWS_CODIGO := GetSX8Num('ZWS','ZWS_CODIGO')
                ZWS->ZWS_TABELA := "ZFL"
                ZWS->ZWS_TIPO   := "J"
                ZWS->ZWS_JSON   := cTextJson
                ZWS->ZWS_WSDATA := MsDate()
                ZWS->ZWS_WSHORA := Time()
                ZWS->ZWS_STATUS := "0"
            ZWS->(MsUnlock())
            ConfirmSX8()

		End Transaction

        //  names := oParseJson:GetNames()
        // ConOut("Integrado: " +CRLF+;
        //     "   Placa......: " + oParseJson:placa + Chr(13) + Chr(10) +;
        //     "   Produto....: " + oParseJson:produto + Chr(13) + Chr(10) +;
        //     "   Motorista..: " + oParseJson:motorista )
        ::SetResponse('{"retorno": "001-Reserva realizada com Sucesso."}')

    Else
        SetRestFault(500,'Parser Json Error')
        ::SetResponse('{"retorno": "000-Não foi localizado nenhuma informacao."}')        
    EndIf
EndIf
U_ClearEnvironment()
ConOut("Fim: WSMETHOD " + Time())

Return .T. // lRet


/* Consumir / Ler API Rest */
// U_WSEnviaPlaca( "AAA"+"-"+StrTran(SubS(Time(),1,5),":",""), 'MILHO VERDE', "Miguel " + DtoS(dDataBase) + " " + StrTran(SubS(Time(),1,5),":",""))
User Function WSEnviaPlaca(placa, produto_id, motorista_nome) 
    Local aArea       := GetArea()
    Local aHeader     := {}
    Local oRestClient := FWRest():New("http://192.168.0.250:8099" )
    Local _aJSon      // := {}
    local cTextJson
    Local oParseJson    := NIL

    aAdd(aHeader, "Content-Type: application/json")
    // aadd(aHeader,'Authorization: Basic YmVybmFyZG86YQ==') // bernardo/a => meu usuario no protheus    
    // oRestClient:setPath("/produtos?codproduto=" + produto_id)
    
    oRestClient:setPath("/WSVistaAlegre/WSPesagem")
    // https://jsonformatter.org/json-editor - editor on line
    _aJSon := '{ "placa" : "'+placa+;
             '", "produto": "'+produto_id+;
             '", "motorista": "'+motorista_nome+'" }'
    oRestClient:SetPostParams( _aJSon )
    If oRestClient:Post(aHeader)
        
        cTextJson := oRestClient:GetResult()
        If FWJsonDeserialize(cTextJson, @oParseJson)            
            Alert("Resultado: " + CRLF + oParseJson:retorno)
        EndIf

    Else
        conout(oRestClient:GetLastError())
        Alert( StrTran( oRestClient:GetLastError(), ',"', Chr(13) + Chr(10)+'"') )
    Endif

    FwFreeObj(oRestClient)
    RestArea(aArea)
Return 


/* Consumir / Ler API Rest */
User Function tstWSBalanca( produto_id ) // U_TSTWSBalanca('020015')
// Local produto_id := '020017'
Local oRestClient := FWRest():New("http://192.168.0.250:8099" )

Local aHeader := {}
// aadd(aHeader,'Authorization: Basic YmVybmFyZG86YQ==') // bernardo/a => meu usuario no protheus

// oRestClient:setPath("/produtos?codproduto=" + produto_id)
oRestClient:setPath("/WSVistaAlegre/WSBalanca")
aadd(aHeader, 'CODPRODUTO: ' + produto_id)

If oRestClient:Get(aHeader)
   ConOut(oRestClient:GetResult())
   Alert(StrTran(oRestClient:GetResult(), ',"', Chr(13) + Chr(10)+'"'))
Else
   conout(oRestClient:GetLastError())
	Alert( StrTran( oRestClient:GetLastError(), ',"', Chr(13) + Chr(10)+'"') )
Endif

Return 



User Function SetEnvironment()
Local lRet := .T.
	If Select("SM0") == 0 
		DbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .F. )
		DbSetIndex("SIGAMAT.IND")

		DbSelectArea("SM0")
		DbSetorder(1)
        DbGoTop()

	EndIf
	RpcSetType(3)
	RpcSetEnv(SM0->M0_CODIGO,SM0->M0_CODFIL)
	
	lRet := (Select("SX3") > 0)
Return lRet
			
User Function ClearEnvironment()
   RpcClearEnv()
Return Nil


// /* ############################################################################################################################## */
// WSMETHOD POST ID_2 WSSERVICE WSBalanca
// 
//     ::SetResponse('{"id":"' + ::aURLParms[1] + '", "name":"WSBalanca", "method":"post id","version":"2"}')
// 
// Return .T.
// 
// /* ############################################################################################################################## */
// WSMETHOD PUT V2 PATHPARAM path1, path2 WSSERVICE WSBalanca
// 
//     ::SetResponse('{"path1":"' + ::path1 + '","path2":"' + ::path2 + '", "urlparm1":"' + ::aURLParms[1] + '","urlparm2":"' + ::aURLParms[2] + '","name":"WSBalanca", "method":"put twoparms"')
//     ::SetResponse(',"version":"2"}')
// 
// Return .T.
// 
// /* ############################################################################################################################## */
// WSMETHOD PUT reservaPlaca PATHPARAM placa WSSERVICE WSBalanca
// 
//     ::SetResponse('{"placa":"' + ::placa + '", "urlparm1":"' + ::aURLParms[1] + '","urlparm2":"' + ::aURLParms[2] + '","name":"WSBalanca", "method":"put twoparms"')
//     ::SetResponse(',"version":"2"}')
// 
// Return .T.


/*
BIBLIOTECA

    https://devforum.totvs.com.br/1515-metodo-post-api-rest-em-advpl

    https://jsoneditoronline.org/#left=local.tusuju&right=local.zoluja

    -> https://tdn.totvs.com/pages/viewpage.action?pageId=75269436


Retorno json
{
"retorno": "Não foi localizado nenhuma informacao."
}

*/

