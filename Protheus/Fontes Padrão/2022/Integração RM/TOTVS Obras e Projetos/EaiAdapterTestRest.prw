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
#include "rwmake.ch"


#DEFINE  TAB  CHR ( 13 ) + CHR ( 10 )

/*
{Protheus.doc} 
@Uso   Servico REST para simulação de comunicação de adapter.
@Autor  William.Prado - TOTVS
*/
WSRESTFUL EaiAdapterTestRest DESCRIPTION "Servico REST para simulação de comunicação de adapter."       
  WSDATA Product 						  	AS STRING
	WSDATA CompanyID 							AS STRING
	WSDATA BranchId 							AS STRING
	WSDATA Transaction 						AS STRING
	WSDATA Option						  		AS STRING
  WSMETHOD GET ;
  DESCRIPTION "Servico REST para simulação de comunicação de adapter";
  WSSYNTAX "/EaiAdapterTestRest"
END WSRESTFUL

WSMETHOD GET WSRECEIVE Product, CompanyID, BranchId, Transaction, Option WSSERVICE EaiAdapterTestRest
LOCAL lMetodo               :=.T.  
LOCAL aResult               := {}
LOCAL vetAdapter            := {}
LOCAL jsAdapter             := {}
DEFAULT ::Product				   	:= ""
DEFAULT ::CompanyID					:= ""
DEFAULT ::BranchId					:= ""  
DEFAULT ::Transaction				:= ""    
DEFAULT ::Option 			  	  := ""

BEGIN SEQUENCE
  cProduct         := ::Product
	cCompanyID       := ::companyId
	cBranchId        := ::BranchId 
	cTransaction     := ::Transaction	  
	cOpcao           := ::Option	

  nOpc := GetOption(cOpcao)
  IF UPPER(cTransaction) == "FINANCIALNATURE"
    aResult:= StartJob("FINANCIALNATURE()",GetEnvServer(),.T.,{nOpc,"RM" , cCompanyID , cBranchId}) 
  
  ELSEIF UPPER(cTransaction) == "COSTCENTER"
    aResult:= StartJob("COSTCENTER()",GetEnvServer(),.T.,{nOpc,"RM" , cCompanyID , cBranchId})    
  
  ELSE
     ConOut("Transaction [" + cAdapter + "] informada não implementada ")		     
  ENDIF
   
  jsAdapter:= JsonObject():new()
  jsAdapter['ADAPTER'     ] := aResult[1]
  jsAdapter['OPERACAO'    ] := aResult[2]
  jsAdapter['RESULTADO'   ] := aResult[3]
  jsAdapter['VALORRM'     ] := aResult[4]
  jsAdapter['VALOREXTERNO'] := aResult[5]
  jsAdapter['LOG'         ] := aResult[6]
  aadd(vetAdapter,jsAdapter)   

  oReturnJson := JsonObject():new()
  oReturnJson['Tests']  := vetAdapter

  ExportarJson(Self,oReturnJson,"EaiAdapterTestRest");
 
END SEQUENCE

Return lMetodo 

Function FINANCIALNATURE(parans)		
  LOCAL aResult           := {}
  LOCAL aArray            := {}
  LOCAL aLog              := {}  
  LOCAL cInternalID       := ""
  LOCAL lMsErroAuto       := .F.  
  LOCAL cCodNat           := "91"
  LOCAL nOpc              := parans[1] 
  LOCAL cProduct          := parans[2]
  LOCAL cCompanyID        := parans[3]
  LOCAL cBranchId         := parans[4]
    
  PrePareContexto(cProduct , cCompanyID , cBranchId)

  dbSelectArea("SED")
  If SED->(DbSeek(xFilial("SED") + cCodNat))
     nOpc := 4
     INCLUI :=.F.
     ALTERA :=.T.
  ELSE
     INCLUI :=.T.
     ALTERA :=.F.
     nOpc := 3
  ENDIF 
  aArray := { { "ED_CODIGO"  , cCodNat                                               , NIL },;
              { "ED_FILIAL"  , xFilial("SED")                                        , NIL },;
              { "ED_DESCRIC" , "TESTE EAI " + DTOC(DATE()) + " "+ TIME()             , NIL },;
              { "ED_COND"    , "D"                                                   , NIL },;
              { "ED_CALCIRF" , "N"                                                   , NIL };              
            }  
   MsExecAuto( { |x,y| FINA010(x,y)} , aArray, nOpc ) 
   If lMsErroAuto      
      aLog := GetAutoGRLog()                       
   else
      cInternalID :=  cEmpAnt + '|' + SED->ED_FILIAL + '|' + RTrim(cCodNat)    
   Endif
  aResult:= Result("FINANCIALNATURE", lMsErroAuto, aLog, nOpc, "SED", "ED_CODIGO", cInternalID)
  RpcClearEnv()
return aResult


Function COSTCENTER(parans)		
  LOCAL aResult           := {}
  LOCAL aArray            := {}
  LOCAL aLog              := {}  
  LOCAL cInternalID       := ""
  LOCAL lMsErroAuto       := .F.  
  LOCAL cCodigo           := "9000001"
  LOCAL nOpc              := parans[1] 
  LOCAL cProduct          := parans[2]
  LOCAL cCompanyID        := parans[3]
  LOCAL cBranchId         := parans[4]
    
  PrePareContexto(cProduct , cCompanyID , cBranchId)

  dbSelectArea("CTT")
  If CTT->(DbSeek(xFilial("CTT") + cCodigo))
     nOpc := 4
     INCLUI :=.F.
     ALTERA :=.T.
  ELSE
     INCLUI :=.T.
     ALTERA :=.F.
     nOpc := 3
  ENDIF
  aArray:={{'CTT_CUSTO'  , cCodigo                                    , Nil},; // Especifica qual o Código do Centro de Custo.
           {'CTT_CLASSE' , "2"                                        , Nil},; // Especifica a classe do Centro de Custo, que poderá ser: - Sintética: Centros de Custo totalizadores dos Centros de Custo Analíticos - Analítica: Centros de Custo que recebem os valores dos lançamentos contábeis
           {'CTT_NORMAL' , " "                                        , Nil},; // Indica a classificação do centro de custo. 1-Receita ; 2-Despesa
           {'CTT_DESC01' , "TESTE EAI " + DTOC(DATE()) + " "+ TIME()  , Nil},; // Indica a Nomenclatura do Centro de Custo na Moeda 1
           {'CTT_BLOQ'   , "2"                                        , Nil},; // Indica se o Centro de Custo está ou não bloqueado para os lançamentos contábeis.
           {'CTT_DTEXIS' , CTOD("01/01/80")                           , Nil},; // Especifica qual a Data de Início de Existência para este Centro de Custo
           {'CTT_DTEXSF' , CTOD("31/12/29")                           , Nil},; // Especifica qual a Data final de Existência para este Centro de Custo.
           {'CTT_CCLP'   , cCodigo                                    , Nil},; // Indica o Centro de Custo de Apuração de Resultado.
           {'CTT_CCPON'  , " "                                        , Nil},; // Indica o Centro de Custo Ponte de Apuração de Resultado.
           {'CTT_BOOK'   , " "                                        , Nil},; // Este é o elo de ligação entre o Cadastro Configuração de Livros e a Centro de Custo           
           {'CTT_RES'    , " "                                        , Nil}} // Indica um “apelido” para o Centro de Custo (que poderá conter letras ou números) e que poderá ser utilizado na digitação dos lançamentos contábeis, facilitando essa digitação.
          
  MSExecAuto({|x, y| CTBA030(x, y)},aArray, nOpc)
  If lMsErroAuto      
    aLog := GetAutoGRLog()                       
  else
    cInternalID :=  cEmpAnt + '|' + CTT->CTT_FILIAL + '|' + RTrim(cCodigo)    
  Endif
  aResult:= Result("COSTCENTER", lMsErroAuto, aLog, nOpc, "CTT", "CTT_CUSTO", cInternalID)
  RpcClearEnv()
return aResult

Static Function  Result(cAdapter,lResult,aLog,nOpc,cAlias,cField,cInternalID)  
  LOCAL cValorRM      :=ALLTRIM(GetValorExterno("RM", cAlias,cField, cInternalID))
  LOCAL aResult       := {}
  LOCAL cOperacao     := ""  
  LOCAL i             := 0
  LOCAL cErro         := ""
    
  FOR i := 1 to len(aLog)
    cErro += aLog[i]
  NEXT i

  IF nOpc == 3               
    cOperacao :="INSERT"
  ELSEIF nOpc == 4                
    cOperacao :="UPDATE"       
  ELSEIF nOpc == 5           
    cOperacao :="DELETE"
  ENDIF  

  AADD( aResult,   /* "ADAPTER"      ,*/  cAdapter       )
  AADD( aResult,   /* "OPERACAO"     ,*/  cOperacao      )
  AADD( aResult,   /* "RESULTADO"    ,*/  !lResult       )
  AADD( aResult,   /* "VALORRM"      ,*/  cValorRM       )
  AADD( aResult,   /* "VALOREXTERNO" ,*/  cInternalID    )
  AADD( aResult,   /* "LOG"          ,*/  cErro          )              
Return aResult


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
	   Conout("Api: " + cApi + "-> Json gerado com sucesso. ")
  else		
     Conout("Api: " + cApi + "-> Falha ao gerar Json. ")   	   
  ENDIF  
  ::SetResponse(oJson:toJson())   
Return lMetodo


Function GetValorExterno( cRefer, cAlias, cField, cValInt, cTable )
  local aArea       := GetArea()
	Local aAreaXXF    := XXF->( GetArea() )
	Local cRet        := ''
  Local nAux        := 0
  Local a_XXFFields := NIL
  Local n_TamRef    := 0
  Local n_TamAlias  := 0
  Local n_TamField  := 0
  Local n_TamInVal  := 0
  Local n_TamExVal  := 0 
  Local n_TamTable  := 0

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

	Default cTable := RetSQLName( cAlias )
	
	XXF->( dbSetOrder( 2 ) ) //"XXF_REFER", "XXF_TABLE", "XXF_ALIAS", "XXF_FIELD", "XXF_INTVAL", "XXF_EXTVAL"
	If ( lRet := XXF->( dbSeek( PadR( cRefer, n_TamRef ) + PadR( cTable , n_TamTable ) + PadR( cAlias, n_TamAlias ) +;
								PadR( cField, n_TamField ) + PadR( cValInt, n_TamInVal ))))
		cRet := XXF->XXF_EXTVAL
	EndIf
	
	RestArea( aAreaXXF )
	RestArea( aArea )
Return cRet


Static Function PrePareContexto(cProduct , cCompanyID , cBranchId)
 LOCAL	lMetodo     := .t. 
 aEmpre := FWEAIEMPFIL(cCompanyID, cBranchId, cProduct)
 IF Len (aEmpre) < 1
     SetRestFault(400, "Empresa: " + cCompanyID + " Nao existem para o Sistema: " + cProduct + " !")
	   lMetodo := .f.
  ELSE
     RPCSetType(3) 
     RpcSetEnv( aEmpre[1]	, aEmpre[2]  )	   
 ENDIF	
Return lMetodo


/*
{Protheus.doc} GETOPTIONCRUD
William Prado
@Uso    retorna a opção do crud conforme o parametro informado 
@param  cOpcao  opção do crud
@return	retorna a opção do crud
*/
Static Function GetOption(cOpcao)
    Local nResult   := 0    
    DO CASE
      CASE UPPER(cOpcao) == 'INSERT'      
          nResult := 3
      CASE UPPER(cOpcao) == 'UPDATE'      
          nResult := 4          
      CASE UPPER(cOpcao) == 'DELETE' 
          nResult := 5
      OTHERWISE       
          SetRestFault(400, "Modo de operacao invalido, Informe INSERT,UPDATE ou DELETE " + TAB + oError:Description)	
    END CASE
return nResult
