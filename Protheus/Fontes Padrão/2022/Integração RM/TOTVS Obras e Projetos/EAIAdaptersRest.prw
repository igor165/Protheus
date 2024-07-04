#Include "RESTFUL.CH"
#Include "TOTVS.CH"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "FWAdapterEAI.ch"
#Include "COLORS.CH"
#Include "TBICONN.CH"
#Include "COMMON.CH"
#Include "XMLXFUN.CH"
#Include "fileio.ch"
#Include 'FWMVCDEF.CH'
#DEFINE  TAB  CHR ( 13 ) + CHR ( 10 )

/*
{Protheus.doc} 
@Uso    Serviço REST para convers?o dos títulos do Protheus de origem imobiliario
@Autor  William.Prado - TOTVS
*/
WSRESTFUL EaiAdaptersRest DESCRIPTION "Servico REST para configuraracao de Adapter"
  WSMETHOD POST ;
    DESCRIPTION "Servico REST para configuraracao de Adapter";
    WSSYNTAX "/EaiAdaptersRest"
END WSRESTFUL

WSMETHOD POST WSSERVICE EaiAdaptersRest
  LOCAL aAdapter          := {} // adapter a serem incluidos
  LOCAL aEmpresas         := {} // Carrega as informações das filiais disponíveis no arquivo
  LOCAL cCodGrupo         := '' // Código do Grupo de Empresas
  LOCAL cCodFilial        := '' // Código da Filial contendo todos os níveis (Empresa / Unidade de Negócio / Filial)
  LOCAL cDescricaoGrupo   := '' // Descrição do Grupo

/*** inicio Auxiliares ****/
  LOCAL lAdpterCriado := .f.  // controle se adapter foi incluido
  LOCAL nContAdpter:= 0       // variacao de adapter
  LOCAL nPacote    := 0       // variacao de PACOTE
  LOCAL lMetodo    := .t.     // retorno da api
  LOCAL nPosiGrupo := 0       // posicao do grupo no array de empresa
/*** fim Auxiliares  *****/ 


/*** inicio Json ****/
  Local jsRet            := NIL
  LOCAL jsAdapter        := NIL  //json adapter configurados
  LOCAL vetAdapter       := {}   //Vetor de json adapter configurados
  Local vetJsRet         := {}
  Local cCatch           As Character
  LOCAL oReturnJson      As Object
  Local oJson            As Object
  LOCAL cJson            := Self:GetContent()

  oJson                  := JsonObject():New()
  cCatch                 := oJson:FromJSON(cJson)
/*** fim Json  *****/ 
  BEGIN SEQUENCE
    IF cCatch == Nil
      aEmpresas   := FWLoadSM0()
      IF( len(aEmpresas) > 0)
        oReturnJson := JsonObject():new()
        FOR nPacote := 1 to LEN(oJson["PacoteEai"])
          cCodGrupo   := oJson["PacoteEai"][nPacote]["Grupo"]
          aAdapter    := oJson["PacoteEai"][nPacote]["Adapters"]
          nPosiGrupo  := aScan(aEmpresas , {|x| x[1] == cCodGrupo})
          IF (nPosiGrupo > 0)
            cCodFilial      := aEmpresas[nPosiGrupo][02]
            cDescricaoGrupo := aEmpresas[nPosiGrupo][21]
            PrePareContexto( cCodGrupo , cCodFilial)

            jsRet := JsonObject():new()
            jsRet['Grupo']     := cCodGrupo
            jsRet['descricao'] := alltrim(cDescricaoGrupo)

            vetAdapter:={}
            For nContAdpter := 1 to len (aAdapter)
              lAdpterCriado:= AddAdapter(aAdapter[nContAdpter])
              jsAdapter:= JsonObject():new()
              jsAdapter['Adapter'  ] := aAdapter[nContAdpter]["Adapter"]
              jsAdapter['resultado'] := lAdpterCriado
              aadd(vetAdapter,jsAdapter)
            Next
            jsRet['Adapters'] := vetAdapter
            aadd(vetJsRet,jsRet)
          ENDIF
        NEXT

         /*RETORNO REST*/   
        oReturnJson := JsonObject():new()
        oReturnJson['ListaAdapter']  := vetJsRet
        ExportarJson(Self , oReturnJson, "EAIAdaptersRest")
         /*RETORNO REST*/          
      ELSE
        lMetodo := .f.
        SetRestFault(400, "Ocorreu um problema na execucao do servico: Verifique se foi configurado o prepareIn no Protheus.")
      ENDIF
    ELSE
      lMetodo:= .f.
      SetRestFault(400, " Json informado como parametro invalido.!")
    ENDIF
  END SEQUENCE
Return lMetodo

/******************************************/
/*Criacao dos aadpter na base do Protheus */
/******************************************/ 
Static Function AddAdapter(aAdapter)
  Local lRetorno    := .f.
  local cCFilial    := ""
  Local cModel      := aAdapter["Adapter"]                          // O nome da mensagem que e processada por esta rotina. Ex: COSTERCENTER
  Local cVersao     := aAdapter["Versao" ]                          // Versão da mensagem trafegada.
  Local cDescricao  := aAdapter["Descricao"]                        // Descricao da mensagem. Utilizada para facilitar o entendimento do processo;
  Local cIsMsgUnica := "1"                                          // tipo de comunição de Mensagem unica TOTVS
  Local cRotina     := aAdapter["Rotina"]                           // Identifica qual rotina no Protheus e responsavel por realizar o processamento da mensagem.
  Local cIsSender   := IIF(VAL(aAdapter["Modo"] ) != 1 ,"1" , "2")  // Define se o adapter envia mensagens para outro sistema;
  Local cIsReceive  := IIF(VAL(aAdapter["Modo"] ) != 2 ,"1" , "2")  // Define se o adapter pode receber mensagens de outro sistema.
  Local cMetodoSend := "1"                                          // Define o motodo de envio da mensagem.
  Local cTipoOper   := "1"                                          // Indica o tipo de operacao utilizado na mensagem.
  Local cChanal     := "2"                                          // Indica o canal para o qual o EAI Protheus irï¿½ enviar a mensagem.
  Local cAlias      := aAdapter["Alias"]                            // Alias da tabela Protheus

///caso exista, Remove o Adapter
  lRetorno:= DelAdapter(cModel,cRotina)

  RecLock( "XX4", .T. )
  XX4->XX4_FILIAL := cCFilial
  XX4->XX4_ROTINA := cRotina
  XX4->XX4_MODEL  := cModel
  XX4->XX4_DESCRI := cDescricao
  XX4->XX4_SENDER := cIsSender
  XX4->XX4_RECEIV := cIsReceive
  XX4->XX4_METODO := cMetodoSend
  XX4->XX4_TPOPER := cTipoOper
  XX4->XX4_CHANEL := cChanal
  XX4->XX4_UNMESS := cIsMsgUnica
  XX4->XX4_SNDVER := cVersao
  XX4->XX4_ALIASP := cAlias
  XX4->XX4_FORMAT := 'XML'
  MsUnLock()
  lRetorno:= .t.
Return lRetorno

/***********************************/
/*  Deleta o adapter se exitir     */
/***********************************/
Static Function DelAdapter(cAdapter,crotina)
  Local lRetorno := .f.
  Local aArea    := GetArea()
  XX4->(DbSetOrder(2))//"XX4_FILIAL", "XX4_MODEL" , "XX4_ROTINA"
  If XX4->( DBSeek( PadR( xFilial( 'XX4' ), Len( XX4->XX4_FILIAL)) + PadR(cAdapter,Len( XX4_MODEL)) + PadR( crotina, Len( XX4_ROTINA)))) 
    If RecLock("XX4",.F.)
      XX4->(dbDelete())
      XX4->(MsUnlock())
      lRetorno :=.t.
    EndIf
  EndIf
  RestArea( aArea )
Return lRetorno





 /*/{Protheus.doc} ExportarJson
  (Prepara o contexto para empresa logada )
  @type  Function
  @author William.Prado
  @since 13/05/2020
  @version version
  @param Sistema, Empresa, Filial
  @return Prepare Enviromente
*/
Static Function PrePareContexto(cCodGrupo , cCodFilial)
  LOCAL lMetodo     := .f.
  RESET ENVIRONMENT
  RPCSetType(3)
  PREPARE ENVIRONMENT EMPRESA cCodGrupo FILIAL cCodFilial TABLES "XX4" MODULO "CFG"
  lMetodo := .t.
RETURN lMetodo



 /*/{Protheus.doc} ExportarJson
  (Exporta o Json )
  @type  Function
  @author William.Prado
  @since 13/05/2020
  @version version
  @param Contexto, Contexto, Contexto enviado para API
  @return Objeto convertido em Json
/*/
Static Function ExportarJson(Self , oReturnJson, cApi)
  LOCAL	lMetodo := .t.
  LOCAL oJson  As Object
  ::SetContentType("application/json")
  oJson := JsonObject():new()
  oJson := oReturnJson
  IF ValType(oJson) == "J"
    Conout("Api:" + cApi + "-> Json gerado com sucesso. ")
  else
    Conout("Api:" + cApi + "-> Falha ao gerar Json. ")
  ENDIF
  ::SetResponse(oJson:toJson())
Return lMetodo
