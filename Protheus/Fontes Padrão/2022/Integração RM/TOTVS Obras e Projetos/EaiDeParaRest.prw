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
@Uso    ServiÃ§o REST para checagem de De/Para de IntegraÃ§Ã£o
@Autor  William.Prado - TOTVS
*/
WSRESTFUL EAIDEPARAREST  DESCRIPTION "ServiÃ§o REST para checagem de De/Para de IntegraÃ§Ã£o"
  WSMETHOD POST ALL;
    DESCRIPTION "Serviço REST para checagem de De/Para de Integração" ;
    WSSYNTAX "/EAIDEPARAREST";
    PATH  ""

  WSMETHOD POST UPSERT;
    DESCRIPTION " Upsert De-para de empresas e filiais" ;
    WSSYNTAX "/EAIDEPARAEMPFIL";
    PATH  "/EAIDEPARAREST/EAIDEPARAEMPFIL"
END WSRESTFUL

/* Criação de Para de Empresa do Lado do Protheus*/
WSMETHOD POST UPSERT WSSERVICE EAIDEPARAREST
  Local cJson     := Self:GetContent()
  Local lMetodo   := .t.
  Local aVetJson  := {}
  Local vetDePara := {}
  Local nContador := 0
  Local cRefer    := ''
  local cCompany  := ''
  local cBranch   := ''
  local cEmpPro   := ''
  local cFilPro   := ''

  oJson := JsonObject():New()
  cCatch             := oJson:FromJSON(cJson)
  If cCatch == Nil
    oReturnJson := JsonObject():new()
    aVetJson := oJson["depara"]
    dbselectarea('XXD')
    jsRetDePara:= JsonObject():new()
    FOR nContador := 1 to len(aVetJson)
      vetDePara    := {}
      cRefer   := PadR(aVetJson[nContador]["referencia"         ], 15 )
      cCompany := PadR( aVetJson[nContador]["empresa"           ], 12 )
      cBranch  := PadR( aVetJson[nContador]["filial"            ], 12 )
      cEmpPro  := AllTrim(Right(aVetJson[nContador]["grupo"     ], 2 ))
      cFilPro  := AllTrim(Right(aVetJson[nContador]["filialPro" ], 12))

      DelDePara(cRefer,cCompany,cBranch)

      RecLock( 'XXD', .T. )
      XXD->XXD_REFER	:= cRefer
      XXD->XXD_COMPA	:= cCompany
      XXD->XXD_BRANCH	:= cBranch
      XXD->XXD_EMPPRO	:= cEmpPro
      XXD->XXD_FILPRO	:= cFilPro

      XXD->(MsUnlock())
      jsRetDePara['referencia' ] :=AllTrim(cRefer)
      jsRetDePara['empresa' ]    :=AllTrim(cCompany)
      jsRetDePara['filial' ]     :=AllTrim(cBranch)
      jsRetDePara['grupo' ]      :=AllTrim(cEmpPro)
      jsRetDePara['filialPro' ]  :=AllTrim(cFilPro)
      aadd(vetDePara,jsRetDePara)
    NEXT
   /*RETORNO REST*/   
    oReturnJson := JsonObject():new()
    oReturnJson['depara']  := vetDePara
    ExportarJson(Self , oReturnJson, "EaiDeParaRest(UPSERT)")
  /*RETORNO REST*/       

  else
    lMetodo :=.f.
    SetRestFault(400, "Ocorreu um problema na execucao do servico")
  EndIf
Return lMetodo

Static Function DelDePara(cRefer,cCompany,cBranch)
  XXD->(dbSetOrder(1))
  If XXD->(dbSeek( cRefer + cCompany + cBranch))
    If RecLock("XXD",.F.)
      XXD->(dbDelete())
      XXD->(MsUnlock())
    EndIf
  ENDIF
Return .t.

/* Retorno de/para do lado Protheus */

WSMETHOD POST ALL WSSERVICE EAIDEPARAREST
  Local cJson       := Self:GetContent()
  Local lMetodo     := .T.
  Local cCatch      as Character
  Local oJson       as Object
  Local oReturnJson as Object
  LOCAL aEmpresas   := {} // Carrega as informações das filiais disponíveis no arquivo
  Local nContador   := 0
  Local ncont       := 0
  Local aVetJson    := {}
  Local vetDePara   := {}
  Local vetAdapter  := {}
  Local a_XXFFields := NIL
  Local n_TamRef    := 0
  Local n_TamAlias  := 0
  Local n_TamField  := 0
  Local n_TamInVal  := 0
  Local n_TamExVal  := 0
  Local n_TamTable  := 0
  Local cRefer      := 'RM'
  Local cAlias      := ''
  Local cAdapter    := ''
  local cIntVal     := ''
  Local cEmpPro     := ''
  Local cFilPro     := ''

  oJson              := JsonObject():New()
  cCatch             := oJson:FromJSON(cJson)
  If cCatch == Nil
    aVetJson := oJson["depara"]
    aEmpresas :=RetornaEmpresa()

    IF( len(aEmpresas) > 0)
      GetXXFFields(@a_XXFFields,@n_TamRef,@n_TamTable,@n_TamAlias,@n_TamField,@n_TamInVal,@n_TamExVal);

      FOR nContador := 1 to len(aVetJson)
        vetDePara    := {}
        cAdapter     := aVetJson[nContador]["adapter"]
        cAlias       := aVetJson[nContador]["alias"]

        jsRetAdapter := JsonObject():new()
        jsRetAdapter['adapter'  ] := cAdapter

        FOR ncont := 1 to len(aEmpresas)
          cEmpPro :=aEmpresas[ncont][1]
          cFilPro :=aEmpresas[ncont][2]

          PrePareContexto(cEmpPro,cFilPro);

          cTable       := cAlias + cEmpPro + "0"

          cKey := PadR( cRefer, n_TamRef) + PadR( cTable, n_TamTable ) + PadR( cAlias, n_TamAlias )
          XXF->( dbSetOrder( 1 ) )

          IF ( XXF->( dbSeek(cKey )) )
            While !XXF->( EOF() ) .and. ( XXF->XXF_REFER + XXF->XXF_TABLE + XXF->XXF_ALIAS ) == cKey
              cIntVal:= alltrim(XXF->XXF_INTVAL)
              cField := alltrim(XXF->XXF_FIELD)             
              jsStatus:= StatusAdapter(ctable,cAlias,cAdapter,cIntVal,cField)
              IF(jsStatus <> NIL)
                jsRetDePara:= JsonObject():new()
                jsRetDePara['XXF_EXTVAL' ] := alltrim(XXF->XXF_EXTVAL)
                jsRetDePara['XXF_INTVAL' ] := cIntVal
                jsRetDePara['diagnostico'] := jsStatus
                aadd(vetDePara,jsRetDePara)
              ENDIF
              XXF->(dbSkip())
            End
          ENDIF
        NEXT
        jsRetAdapter['depara'  ] :=vetDePara
        aadd(vetAdapter,jsRetAdapter)
      NEXT
    ELSE
      lMetodo := .f.
      SetRestFault(400, "Ocorreu um problema na execucao do servico: Verifique se foi configurado o prepareIn no Protheus.")
    ENDIF
  ENDIF
  /*RETORNO REST*/   
  oReturnJson := JsonObject():new()
  oReturnJson['listadepara']  := vetAdapter
  ExportarJson(Self , oReturnJson, "EaiDeParaRest")
  /*RETORNO REST*/       

Return lMetodo



static Function StatusAdapter(ctable,cAlias,cAdapter,cDePara,cField)
  Local jsStatus  := JsonObject():new()
  Local aInfo     := Separa(cDePara,"|",.t.)  
  Local status    := -1
  local cKey      :=''

  /*CENTRO DE CUSTO*/
  IF(UPPER(cAdapter) == "COSTCENTER")
    cKey    :=PadR(aInfo[2] ,TamSx3("CTT_FILIAL")[1])+ aInfo[3]
    status := RegExiste(ctable,cAlias,cKey)

  /*CLIENTE / FORNECEDOR*/
  ELSEIF(UPPER(cAdapter) == "CUSTOMERVENDOR")
    cKey    := PadR(aInfo[2] ,TamSx3("A1_FILIAL")[1]) + aInfo[3] + aInfo[4] + aInfo[5]
    status := RegExiste(ctable,cAlias,cKey)

  /* MOEDA */
  ELSEIF(UPPER(cAdapter) == "CURRENCY")
    cKey   := PadR(aInfo[2] ,TamSx3("CTO_FILIAL")[1]) +aInfo[3]
    status := RegExiste(ctable,cAlias,cKey)

  /*CLASSVALUE*/
  ELSEIF(UPPER(cAdapter) == "CLASSVALUE")
    cKey   := PadR(aInfo[2] ,TamSx3("CTH_FILIAL")[1]) +aInfo[3]
    status := RegExiste(ctable,cAlias,cKey)

  /*FINANCIALNATURE*/
  ELSEIF(UPPER(cAdapter) == "FINANCIALNATURE")
    cKey   := PadR(aInfo[2] ,TamSx3("ED_FILIAL")[1]) +aInfo[3]
    status := RegExiste(ctable,cAlias,cKey)

  /*CONTA CONTABIL*/  
  ELSEIF(UPPER(cAdapter) == "ACCOUNTANTACCOUNT")
    cKey   := PadR(aInfo[2] ,TamSx3("CT1_FILIAL")[1]) +aInfo[3]
    status := RegExiste(ctable,cAlias,cKey)

  /*CALENDARIO CONTABIL*/
  ELSEIF(UPPER(cAdapter) == "ACCOUNTINGCALENDAR")
    cKey   := PadR(aInfo[2] ,TamSx3("CTG_FILIAL")[1]) +aInfo[3]
    status := RegExiste(ctable,cAlias,cKey)

  /*LANCTO CONTABIL*/
  ELSEIF(UPPER(cAdapter) == "ACCOUNTINGENTRY")
    cKey   := PadR(aInfo[2] ,TamSx3("CT2_FILIAL")[1]) +aInfo[3]
    status := RegExiste(ctable,cAlias,cKey)

  /*ITEM CONTABIL*/
  ELSEIF(UPPER(cAdapter) == "ACCOUNTINGITEM")
    cKey   := PadR(aInfo[2] ,TamSx3("CTD_FILIAL")[1]) +aInfo[3]
    status := RegExiste(ctable,cAlias,cKey)

  /*ITEM CONTABIL*/
  ELSEIF(UPPER(cAdapter) == "BANK")
    cKey   := PadR(aInfo[2] ,TamSx3("A6_FILIAL")[1]) +aInfo[3]
    status := RegExiste(ctable,cAlias,cKey)

  /*VALORES ACESSORIOS*/
  ELSEIF(UPPER(cAdapter) == "LISTOFCOMPLEMENTARYVALUE")
    cKey   := PadR(aInfo[2] ,TamSx3("FKC_FILIAL")[1]) +aInfo[3]
    status := RegExiste(ctable,cAlias,cKey)

  /*COTAÇÃO DE MOEDA*/
  ELSEIF(UPPER(cAdapter) == "CURRENCYQUOTATION")
    cKey   := PadR(aInfo[2] ,TamSx3("CTP_FILIAL")[1]) +aInfo[3]
    status := RegExiste(ctable,cAlias,cKey)

  /*PLANO FINANCIAMENTO*/
  ELSEIF(UPPER(cAdapter) == "FINANCING")
    IF( cField =="E1_NUM" .or. cField =="E2_NUM"  )
      IF(UPPER(cAlias) == 'SE1')
        cfil := PadR(aInfo[2] ,TamSx3("E1_FILIAL")[1])
        cPref:= PadR(aInfo[3] ,TamSX3("E1_PREFIXO")[1])
        cNum := PadR(aInfo[4] ,TamSX3("E1_NUM")[1])
        cParc:= PadR(aInfo[5] ,TamSX3("E1_PARCELA")[1])
        cTipo:= PadR(aInfo[6] ,TamSX3("E1_TIPO")[1])
      ELSEIF(UPPER(cAlias) == 'SE2')
        cfil := PadR(aInfo[2] ,TamSx3("E2_FILIAL")[1])
        cPref:= PadR(aInfo[3] ,TamSX3("E2_PREFIXO")[1])
        cNum := PadR(aInfo[4] ,TamSX3("E2_NUM")[1])
        cParc:= PadR(aInfo[5] ,TamSX3("E2_PARCELA")[1])
        cTipo:= PadR(aInfo[6] ,TamSX3("E2_TIPO")[1])
      ENDIF
      cKey   :=cfil + cPref + cNum +cParc + cTipo
      status := RegExiste(ctable,cAlias,cKey)
    ENDIF
  ENDIF
  jsStatus['status' ] := status
return jsStatus

Static Function PrePareContexto(cGrupo , cfilial)
  LOCAL	lMetodo     := .t.
  RPCSetType(3)
  lMetodo := RpcSetEnv( cGrupo	, cfilial  )
Return lMetodo



Static Function RegExiste(ctable,cAlias,cCodigo)
  Local aAreaAnt := XXF->(GetArea())    
  Local nResult  :=  0
  DbUseArea(.T.,"TOPCONN", ctable,cAlias,.T.,.T.)
  DbSetIndex(ctable+"1")  
  IF ((cAlias)->(MsSeek(cCodigo)))
    nResult:=1
  ENDIF
  DBCloseArea()
  RestArea(aAreaAnt)
Return nResult


static Function RetornaEmpresa()
  LOCAL aEmpresas   := {}
  dbselectarea('XXD')
  XXD->(dbgotop())
  While ! XXD->( Eof() )

    If ( aScan(aEmpresas , {|x| x[1] ==  XXD->XXD_EMPPRO}) == 0 )
      aAdd( aEmpresas,{XXD->XXD_EMPPRO ,XXD->XXD_FILPRO })
    EndIf
    XXD->(dbSkip())
  EndDo
return aEmpresas


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

static Function GetXXFFields(a_XXFFields,n_TamRef,n_TamTable,n_TamAlias,n_TamField,n_TamInVal,n_TamExVal)
  Local nAux        := 0
  If a_XXFFields == NIL
    a_XXFFields := FWXXFFields( .T. )

    If ( nAux  := aScan( a_XXFFields, { | aX | aX[1] == 'XXF_REFER'  } ) ) > 0
      n_TamRef   := a_XXFFields[nAux][4]
    EndIf
    If ( nAux  := aScan( a_XXFFields, { | aX | aX[1] == 'XXF_TABLE' } ) ) > 0
      n_TamTable := a_XXFFields[nAux][4]
    EndIf
    If ( nAux  := aScan( a_XXFFields, { | aX | aX[1] == 'XXF_ALIAS'  } ) ) > 0
      n_TamAlias := a_XXFFields[nAux][4]
    EndIf
    If ( nAux  := aScan( a_XXFFields, { | aX | aX[1] == 'XXF_FIELD'  } ) ) > 0
      n_TamField := a_XXFFields[nAux][4]
    EndIf
    If ( nAux  := aScan( a_XXFFields, { | aX | aX[1] == 'XXF_INTVAL' } ) ) > 0
      n_TamInVal := a_XXFFields[nAux][4]
    EndIf
    If ( nAux  := aScan( a_XXFFields, { | aX | aX[1] == 'XXF_EXTVAL' } ) ) > 0
      n_TamExVal := a_XXFFields[nAux][4]
    EndIf
  EndIf
return .t.
