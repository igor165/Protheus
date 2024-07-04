#INCLUDE "PROTHEUS.CH"
#INCLUDE "AVERAGE.CH"
#INCLUDE "EICDU101.CH"

#define FAILED_FETCH "Failed to fetch"
#define DIAG_PROCESSAMENTO "Diagnóstico em processamento"
#define PROC_N_IMPED "PROCESSADO_ERRO_NAO_IMPEDITIVO Não há erros impeditivos para o registro"
#define PROC_S_IMPED "PROCESSADO_SEM_ERRO_IMPEDITIVO"
#define CAPA "CAPA"
#define ITEM "ITEM"
#define DIAGNOSTICO "DIAGNOSTICO"
#define REGISTRO "REGISTRO"
#define VALOR_CALCULADO "VALOR_CALCULADO"
#define II     "201"
#define IPI    "202"
//#define ICMS   "203"
#define PIS    "204"
#define COFINS "205"

// define EV1_STATUS
#define PENDENTE_INTEGRACAO        "1"
#define PROCESSO_PENDENTE_REVISAO  "2"
#define PENDENTE_REGISTRO          "3"
#define DUIMP_REGISTRADA           "4"
#define OBSOLETO                   "5"

// define ENDPOINT Portal Unico
#define URL_AUTENTICAR "/portal/api/autenticar"

static _nQtdeItem := 0
static _aItsDUIMP := {}
static _DIC_22_4  := nil

/*
Função     : DU101PrcInt
Objetivo   : Realiza o processo de integração com o Portal DUIMP
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
function DU101PrcInt(cAlias, nRecno, nOpc, cHawb, cLote)
   local aArea      := getArea()
   local cUrlInteg  := ""
   local bAction    := nil
   local bValid     := {|| getFecha()}

   default cAlias     := "EV1"
   default nRecno     := EV1->(recno())
   default nOpc       := 0
   default cHawb      := EV1->EV1_HAWB
   default cLote      := EV1->EV1_LOTE

   Private lFecha := .F.
   
   aAreaEV1 := EV1->(getArea())
   if nRecno > 0
      EV1->(dbGoTo(nRecno))
   endif

   begin sequence

   if ( nOpc == 3 .or. nOpc == 4 ) //  INCLUIR ou INTEGRAR

      if nOpc == 4 .and. !(EV1->EV1_STATUS == PENDENTE_INTEGRACAO)
         EasyHelp(STR0023, STR0003, "") // "A ação 'Integrar' só pode ser executada para registros com o status '1-Pendente de Integração'" ### "Atenção"
         break
      elseif !MsgYesNo(STR0001 + CRLF + CRLF + STR0002, STR0003) // "Deseja iniciar a integração da Duimp com o Portal Único?" ### "Esta operação iniciará a gravação dos dados no Portal Único, o diagnóstico e o registro da Duimp." ### "Atenção"  
         break
      endif
      bAction := {|x| IntegDuimp(x,cUrlInteg,cHawb,cLote)}

   elseif nOpc == 5 // EXCLUIR

      if EV1->EV1_STATUS $ PENDENTE_INTEGRACAO + "||" + PROCESSO_PENDENTE_REVISAO + "||" + PENDENTE_REGISTRO .and. !empty(EV1->EV1_DI_NUM) .and. !empty(EV1->EV1_VERSAO)
         bAction := {|x| IntDelete(x,cUrlInteg,cHawb,cLote)}
      endif

   elseif nOpc == 6 // REGISTRAR

      if !EV1->EV1_STATUS == PENDENTE_REGISTRO
         EasyHelp( STR0036 , STR0003 , "") // "Ação permitida apenas para o status 'Pendente de Registro'" ### "Atenção" 
         break
      elseif !MsgYesNo(STR0001 + CRLF + CRLF + STR0002, STR0003) // "Deseja iniciar a integração da Duimp com o Portal Único?" ### "Esta operação iniciará a gravação dos dados no Portal Único, o diagnóstico e o registro da Duimp." ### "Atenção"  
         break
      endif

      bAction := {|x| IntRegistro(x,cUrlInteg,cHawb,cLote)}

   endif

   if !( bAction == nil )

      cUrlInteg := AVgetUrl()
      if empty(cUrlInteg)
         easyhelp(STR0026,STR0003,STR0027) // O parâmetro MV_EIC0072 ou MV_EIC0073 não estão preenchidos","ATENÇÃO","Informe o parâmetro MV_EIC0072(Produção) ou MV_EIC0073(Homologação) e tente novamente"
         break
      endif

      Eecview("",STR0003,,,bValid,.F.,.T.,bAction, .T.)

   endif

   end sequence

   restArea(aAreaEV1)
   restArea(aArea)

return nil

/*
Função     : IntegDuimp
Objetivo   : Realiza a integração como portal único e atualiza o eecview
Parâmetro  :
Retorno    :
Autor      : Maurício Frison
Data/Hora  : Abril/2022
Obs.       :
*/
static function IntegDuimp(oLogView,cUrlInteg,cHawb,cLote)
local cURLAuth   := cUrlInteg + URL_AUTENTICAR
local oEasyJS    := EasyJS():New()
local aIntDel    := {.F.,.F.} //1o. Erro de conexão, 2o. Erro da camada de negócio
local aIntCapa   := {.F.,.F.} //1o. Erro de conexão, 2o. Erro da camada de negócio
local aIntItem   := {.F.,.F.} //1o. Erro de conexão, 2o. Erro da camada de negócio
local aIntDiag   := {.F.,.F.,.F.} //1o. Erro de conexão, 2o. Erro da camada de negócio, 3o. Indica se passou pelo erro não impeditivo
local aIntVlr    := {.F.,.F.} //1o. Erro de conexão, 2o. Erro da camada de negócio
local aIntReg    := {.F.,.F.} //1o. Erro de conexão, 2o. Erro da camada de negócio
local aIntVlrIts := {.F.,.f.}

InitInt(@oLogView)

begin sequence

   if EV1->EV1_STATUS == PENDENTE_INTEGRACAO .and. VldCertDig(@oEasyJs,cUrlInteg,cUrlAuth,oLogView)

      aIntDel := IntDelDUIMP(oEasyJs,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)

      if aIntDel[1] 
         aIntCapa := IntegCapa(oEasyJS,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
      else
         break
      endif

      if aIntCapa[1] 
         aIntItem:= IntegItens(oEasyJS,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
      else
         break
      EndIf

      if aIntCapa[1] .And. aIntCapa[2] .And. aIntItem[1] .And. aIntItem[2]
         aIntVlrIts := IntegVlrIts(oEasyJS, cUrlInteg, cHawb, cLote, EV1->(Recno()), oLogView )
      endif

      If aIntCapa[1] .And. aIntCapa[2] .And. aIntItem[1] .And. aIntItem[2] .and. aIntVlrIts[1] //garante que não houve erro de conexao e nem erro da camada de negócio
         aIntDiag := IntegDiagnostico(oEasyJS,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
      else
         break   
      EndIf        

      If aIntDiag[1] .And. aIntDiag[2]
         aIntVlr := IntegVlrCalc(oEasyJS,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
      else
         break   
      EndIf   

      If aIntVlr[1] .And. aIntVlr[2]
         aIntReg := IntegRegistro(oEasyJS,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView,aIntDiag[3])
      EndIf   

   endif

end sequence

FinishInt(@oLogView, @oEasyJS)

Return nil

/*
Função     : IntDelete
Objetivo   : Realiza a integração como portal único enviando o DELETE da DUIMP e atualiza o eecview
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
static function IntDelete(oLogView,cUrlInteg,cHawb,cLote)
   local cURLAuth := cUrlInteg + URL_AUTENTICAR
   local oEasyJS  := nil
   local aIntDel  := {.F.,.F.} 

   if EV1->EV1_STATUS $ PENDENTE_INTEGRACAO + "||" + PROCESSO_PENDENTE_REVISAO + "||" + PENDENTE_REGISTRO .and. !empty(EV1->EV1_DI_NUM) .and. !empty(EV1->EV1_VERSAO)

      oEasyJS := EasyJS():New()

      InitInt(@oLogView)

      begin sequence

      if VldCertDig(@oEasyJs,cUrlInteg,cUrlAuth,@oLogView)

         aIntDel := IntDelDUIMP(@oEasyJs,cUrlAuth,cUrlInteg,cHawb,cLote,@oLogView)

         if aIntDel[1] 
            AtuReg({"EV1_STATUS"}, {OBSOLETO} )
         endif

      endif

      end sequence

      FinishInt(@oLogView, @oEasyJS)

   endif

Return nil

/*
Função     : IntRegistro
Objetivo   : Realiza a integração como portal único enviando o Diagnóstico e Registro da DUIMP e atualiza o eecview
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
static function IntRegistro(oLogView,cUrlInteg,cHawb,cLote)
   local cURLAuth    := cUrlInteg + URL_AUTENTICAR
   local cQrySWV     := nil
   local oEasyJS     := EasyJS():New()
   local aIntDiag    := {.F.,.F., .F.}
   local aIntVlr     := {.F.,.F.}
   local aIntReg     := {.F.,.F.}
   local aIntVlrIts  := {.F.,.F.}

   InitInt(@oLogView)

   begin sequence

   if EV1->EV1_STATUS == PENDENTE_REGISTRO .and. VldCertDig(@oEasyJs,cUrlInteg,cUrlAuth,@oLogView) .and. getItens(@cQrySWV, cHawb, .T.)

      aIntVlrIts := IntegVlrIts(oEasyJS, cUrlInteg, cHawb, cLote, EV1->(Recno()), oLogView)

      if aIntVlrIts[1]
         aIntDiag := IntegDiagnostico(oEasyJS,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
      endif

      If aIntDiag[1] .And. aIntDiag[2]
         aIntVlr := IntegVlrCalc(oEasyJS,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
      else
         break   
      endif   

      if aIntVlr[1] .And. aIntVlr[2]
         aIntReg := IntegRegistro(oEasyJS,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView,aIntDiag[3])
      endif 

   endif

   end sequence

   FinishInt(@oLogView, @oEasyJS)

Return nil

/*
Função     : InitInt
Objetivo   : Início do processamento da integração com Portal Único
Parâmetro  : 
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
static function InitInt(oLogView)
   getLog(dToc(Date()) + '-' + Time() + ' ' + STR0008  + UsrFullName(retCodUsr()) + ' ' + STR0009,oLogView,.F.) // Usuário do sistema:' Início do processamento de integração da Duimp'
   _nQtdeItem := 0
   aSize(_aItsDUIMP, 0)
   _aItsDUIMP := {}
return nil

/*
Função     : FinishInt
Objetivo   : Fim do processamento da integração com Portal Único
Parâmetro  : 
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
static function FinishInt(oLogView, oEasyJS)
   getLog(STR0016 + ENTER + ENTER,oLogView) //Fim do processamento  
   lFecha := .T.
   AtuReg({'EV1_LOGINT'},{EV1->EV1_LOGINT + eval(oLogView:bsetGet)})  
   oEasyJS:Destroy()
return nil

/*
Função     : getFecha
Objetivo   : Retorna a variável indicando se pode fechar a tela da integração ou não 
Parâmetro  : 
Retorno    : 
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function getFecha()
return lFecha

/*
Função     : VldCertDig
Objetivo   : Realiza a validação do certificado digital 
Parâmetro  :
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
Static function VldCertDig(oEasyJs,cUrlInteg,cUrlAuth,oLogView)
   local lRet := .F.

   default oEasyJs   := EasyJS():New()
   default cUrlInteg := ""
   default cUrlAuth  := cUrlInteg + URL_AUTENTICAR

   oEasyJS:cUrl := cUrlInteg
   oEasyJS:AddLib(GetApoRes('ASYNC.JS'))
   oEasyJS:AddLib(DU101Lib(cUrlAuth, cUrlInteg))
   oEasyJS:setTimeOut(30)
   getLog(STR0010,oLogView) //Acessando o certificado digital
   lRet := oEasyJS:Activate(.T.) //Ativa a tela que solicita o certificado
   if !lRet
      getLog(STR0013,oLogView) //"Erro no certificado"
   EndIf

return lRet

/*
Função     : IntegRegistro
Objetivo   : Realiza a integração do registro da DUIMP
Parâmetro  : oEasyJs
Retorno    : a primeira posição .T. se deve continuar a integração e .F. se não deve (erros de conexão ou de formatação do json inválido)
             a segunda posição .T. se deve continuar a integração de diagnóstico e registro e .F. se não deve (erros da camada de negócio)
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function IntegRegistro(oEasyJs,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView,lErroNimp)
local cRet := '', cAtuReg:=''
local cUrlVlrCalc := cUrlInteg + "/duimp-api/api/ext/duimp/"+alltrim(EV1->EV1_DI_NUM)+"/"+alltrim(EV1->EV1_VERSAO)+"/registros"
local aRet := {.T.,.T.}    //[1] erro de conexão, [2] erro da camada de negócio  
local cBody := getRegJson(lErroNimp,cHawb)
Begin Sequence   
      getLog(STR0033 + ' ' + EV1->EV1_DI_NUM + ' ' + STR0012 + ' ' + EV1->EV1_VERSAO,oLogView) // "Solicitando registro da Duimp:"
      //cAtuReg := "AtuReg({'EV1_STATUS'},{'" + PENDENTE_REGISTRO + "'})" Neste caso não precisa alterar o status da duimp em caso de erro no certificado
      getLog(cBody,oLogView)  
      cRet := execEndPoint(oEasyJs,cUrlAuth , cUrlVlrCalc , cBody,'POST',@aRet,oLogView,cAtuReg,.F.)
      getLog(cRet,oLogView)  
      ProcRetDuimp(cRet,@aRet,oLogView,REGISTRO,STR0034)    //"Houve algum problema no registro da DUIMP, verifique a mensagem acima"
End Sequence
Return aRet   


/*
Função     : IntegVlrCalc
Objetivo   : Realiza a integração dos valores calculados da DUIMP
Parâmetro  : oEasyJs
Retorno    : a primeira posição .T. se deve continuar a integração e .F. se não deve (erros de conexão ou de formatação do json inválido)
             a segunda posição .T. se deve continuar a integração de diagnóstico e registro e .F. se não deve (erros da camada de negócio)
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function IntegVlrCalc(oEasyJs,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
local cRet := '', cAtuReg:=''
local cUrlVlrCalc := cUrlInteg + "/duimp-api/api/ext/duimp/"+alltrim(EV1->EV1_DI_NUM)+"/"+alltrim(EV1->EV1_VERSAO)+"/valores-calculados"
local aRet := {.T.,.T.}    //[1] erro de conexão, [2] erro da camada de negócio  
Begin Sequence   
      getLog(STR0032 + ' ' + EV1->EV1_DI_NUM + ' ' + STR0012 + ' ' + EV1->EV1_VERSAO,oLogView) // "Recuperando valores calculados da Duimp"
      cAtuReg := "AtuReg({'EV1_STATUS'},{'" + PENDENTE_REGISTRO + "'})"
      cRet := execEndPoint(oEasyJs,cUrlAuth , cUrlVlrCalc , '','GET',@aRet,oLogView,cAtuReg,.F.)
      getLog(cRet,oLogView)  
      ProcRetDuimp(cRet,@aRet,oLogView,VALOR_CALCULADO,STR0035)    //"Houve algum problema no retorno dos valores dos atributos da DUIMP, verifique a mensagem acima"   
End Sequence
Return aRet   

/*
Função     : IntegDiagnostico
Objetivo   : Realiza a integração do diagnóstico da DUIMP
Parâmetro  : oEasyJs
Retorno    : a primeira posição .T. se deve continuar a integração e .F. se não deve (erros de conexão ou de formatação do json inválido)
             a segunda posição .T. se deve continuar a integração de diagnóstico e registro e .F. se não deve (erros da camada de negócio)
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function IntegDiagnostico(oEasyJs,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
local cRet := '', cAtuReg:=''
local cUrlDiagDuimp := cUrlInteg + "/duimp-api/api/ext/duimp/"+alltrim(EV1->EV1_DI_NUM)+"/"+alltrim(EV1->EV1_VERSAO)+"/diagnosticos"
local aRet := {.T.,.T.,.F.}    //[1] erro de conexão, [2] erro da camada de negócio [3] Se passou pelo erro não impeditivo
local cQtdeItem := '{"totalItem":'+ lTrim(str(_nQtdeItem)) + '}'  
Begin Sequence   
      getLog(STR0025 + ' ' + EV1->EV1_DI_NUM + ' ' + STR0012 + ' ' + EV1->EV1_VERSAO,oLogView) // Solicitando Diagnóstico da Duimp para registro/ retificação
      cAtuReg := "AtuReg({'EV1_STATUS'},{'" + PENDENTE_REGISTRO + "'})"
      cRet := execEndPoint(oEasyJs,cUrlAuth , cUrlDiagDuimp , cQtdeItem,'POST',@aRet,oLogView,cAtuReg)
      getLog(cRet,oLogView)  
      If !ProcRetDuimp(cRet,@aRet,oLogView,DIAGNOSTICO,STR0024) //"Houve algum problema no retorno do diagnóstico da DUIMP, verifique a mensagem acima"
         AtuReg({'EV1_STATUS'},{PENDENTE_REGISTRO}) 
         getLog(STR0028,oLogView) //"Operação de Registro da Duimp abortada pelo usuário" 
         aRet[2]:=.F.
      EndIf   
End Sequence
Return aRet   

/*
Função     : IntDelDUIMP
Objetivo   : Realiza o envio da exclusão da integração DUIMP
Parâmetro  :
Retorno    : a primeira posição .T. se deve continuar a integração e .F. se não deve (erros de conexão ou de formatação do json inválido)
             a segunda posição .T. se deve continuar a integração de diagnóstico e registro e .F. se não deve (erros da camada de negócio)
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
Static function IntDelDUIMP(oEasyJs,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
   local cAtuReg      := ""
   local cRet         := ""
   local cUrlDelDuimp := ""
   local aRet         := {.T.,.T.}

   default cUrlInteg := ""
   default cURLAuth  := cUrlInteg + URL_AUTENTICAR

   begin sequence

   if !empty(EV1->EV1_DI_NUM)
      cUrlDelDuimp := cUrlInteg + "/duimp-api/api/ext/duimp/"+alltrim(EV1->EV1_DI_NUM)+"/"+alltrim(EV1->EV1_VERSAO) 
      //cAtuReg := "AtuReg({'EV1_DI_NUM','EV1_VERSAO'},{'',''})"
      getLog(STR0011 + EV1->EV1_DI_NUM + ' ' + STR0012 + ' ' + EV1->EV1_VERSAO,oLogView) // Iniciando o envio da exclusão da Duimp: XXX versão:
      cRet := execEndPoint(oEasyJs,cUrlAuth , cUrlDelDuimp , '','DELETE',@aRet,oLogView,cAtuReg)
      if aRet[1]
         AtuReg({'EV1_DI_NUM','EV1_VERSAO'},{'',''})
      endif
      getLog(cRet,oLogView)
   endif

   end sequence

return aRet

/*
Função     : IntegCapa
Objetivo   : Realiza a integração da capa da DUIMP
Parâmetro  : oEasyJs
Retorno    : a primeira posição .T. se deve continuar a integração e .F. se não deve (erros de conexão ou de formatação do json inválido)
             a segunda posição .T. se deve continuar a integração de diagnóstico e registro e .F. se não deve (erros da camada de negócio)
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function IntegCapa(oEasyJs,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
local cGeraisTxt := InfGerais(cHawb, cLote)
local oJson      := JsonObject():New()
local cError := oJson:FromJson(cGeraisTxt)
local cRet := '', cAtuReg:=''
local cUrlDuimp   := cUrlInteg + "/duimp-api/api/ext/duimp"
local aRet := {.T.,.T.}  //[1] erro de conexão, [2] erro da camada de negócio         
Begin Sequence
   fwfreeobj(oJson)
   If cError == nil
      getLog(STR0014,oLogView)  //Iniciando o envio dos Dados Gerais da Duimp:      
      getLog(cGeraisTxt,oLogView)    

      cAtuReg := "AtuReg({'EV1_STATUS'},{'" + PENDENTE_INTEGRACAO + "'})"
      cRet := execEndPoint(oEasyJs,cUrlAuth , cUrlDuimp , cGeraisTxt,'POST',@aRet,oLogView,cAtuReg)

      getLog(STR0015,oLogView)  //Retorno da gravação dos Dados Gerais da Duimp:                
      getLog(cRet,oLogView)   
      ProcRetDuimp(cRet,@aRet,oLogView,CAPA,STR0019) //"Houve algum problema no retorno da gravação da DUIMP, verifique a mensagem acima"    
   else
      getLog(STR0020 ,oLogView) //Erro na formatação do json gerado   //atenção advpr ok
      getLog(cError ,oLogView) 
      AtuReg({'EV1_STATUS'},{PENDENTE_INTEGRACAO})         
      aRet[1] := .F. 
   EndIf    
End Sequence   
Return aRet   

/*
Função     : getRegJson
Objetivo   : Gerar o json para envio no registro da duimp
Parâmetro  : lErroNimp - se .T. é pq. teve erros não impeditivos, se .F. é pq. não teve erros não impeditivos
             cHawb - número do processo de importação
Retorno    : Retorna o json para solicitaçaõ do registroda duimp
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
Static function getRegJson(lErroNimp,cHawb)
local cPgtoJson
local cResposta := iif(lErroNimp,"SIM","NA")
local i
Local cSWDFil := xFilial("SWD")
SWD->(DBSETORDER(1))
cPgtoJson := '{"totalItem": '+ lTrim(str(_nQtdeItem)) +','
cPgtoJson += '"pagamentos": ['
for i:= 201 to 205 
   If i <> 203 //pular o 203 que é o icms
      cPgtoJson +=  '{'  
      cPgtoJson +=  '"principal": {'
      cPgtoJson +=  '  "tributo": {'
      cPgtoJson +=  '   "tipo": "' + getNomeImp(i) + '"'
      cPgtoJson +=         '},'
      cPgtoJson +=         '"valor": ' + getValImp(cSWDFil,cHawb,i)
      cPgtoJson +=                '}'
      cPgtoJson += '}'
      cPgtoJson += iif(i<>205,',','')
   EndIf   
Next      
cPgtoJson +=                 '],' 
cPgtoJson +=  '"confirmacaoAlertaErrosNaoImpeditivos": "' + cResposta + '"'
cPgtoJson +='}'   
return cPgtoJson

/*
Função     : getNomeImp
Objetivo   : Retornar o nome do imposto a partir do código
Parâmetro  : nImposto - código numérico do imposto
Retorno    : Retorno do nome do imposto
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function getNomeImp(nImposto)
cRet:=''
Do CASE
   Case nImposto == 201
        cRet := 'II'
   Case nImposto == 202
        cRet := 'IPI'
   //Case nImposto == 203
   //     cRet := 'ICMS'     
   Case nImposto == 204
        cRet := 'PIS'
   Case nImposto == 205
        cRet := 'COFINS'
ENDCASE
Return cRet

/*
Função     : getValImp
Objetivo   : Retornar o valor do imposto que foi recuperado no portal único e salvo na tabela swd
Parâmetro  : cSWDFil - filial da tabela SWD
             cHawb - número do processo de embarque/desembaraço no sigaeic
             nCodigo - código numérico do imposto
Retorno    : Retorno o valor doi imposto como caracter formatdo em duas casas decimais e . decimal
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function getValImp(cSWDFil,cHawb,nImposto)
cRet:=''
SWD->(DBSEEK(cSWDFil + cHawb + str(nImposto,AvSx3('WD_DESPESA',AV_TAMANHO),0))) 
cRet:= lTrim(str(SWD->WD_VALOR_R,AvSx3('WD_VALOR_R',AV_TAMANHO),2))
Return cRet


/*
Função     : AtuReg
Objetivo   : Realiza a atualização dos campos na tabela EV1
Parâmetro  : aCampos  - array com os campos a serem atualizados 
             aValores -array com os valores a serem atualizados
             cAlias   - Alias da tabela 
Retorno    : 
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
Static function AtuReg(aCampos,aValores,cAlias)
local i
local cCampo
Default cAlias := "EV1"
IF cAlias == "SW6"
   SW6->(DBSETORDER(1))
   SW6->(dbSeek( xFilial("SW6") + EV1->EV1_HAWB ))
ENDIF

RecLock(cAlias,.F.)
for i:=1 to len(aCampos)
    cCampo := cAlias + '->' + aCampos[i]
    &cCampo := aValores[i]
Next
(cAlias)->(MsUnlock())
Return

/*
Função     : execEndPoint
Objetivo   : Faz a chamada no portal único
Parâmetro  : oEasyJS : objeto easyjs
             cUrlAuth: url de atutenticação no portal único
             cUrlExec: url a ser utilizada no portal único após a autenticação
             cDados  : informações a serem enviadas ao portal único quando for método post ou put, caso contrário será vazio
             cMetodo : método a ser executado no portal único, ex: post,put,delete
             aRet    : array onde será retornado .f. em caso de erro
             oLogView: objeto para tratamento do eecview
Retorno    : 
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
Static function execEndPoint(oEasyJS,cUrlAuth , cUrlExec , cDados,cMetodo, aRet,oLogView,cAtuReg,lBody)
Local cRet:='', cErros:=''
Default lBody := .T.
oEasyJS:runJSSync( AVAuth( cUrlAuth , cUrlExec , cDados, cMetodo,lBody) ,{|x| cRet := x } , {|x| cErros := x } )                     
If !Empty(cErros)
   getLog(iif(cErros == FAILED_FETCH, STR0013 + ' ' + cErros,cErros),oLogView)  //"Erro no certificado"      
   aRet[1] := .F.           
   if !empty(cAtuReg)  
      &cAtuReg
   endif
   BREAK
EndIf   
Return cRet

/*
Função     : ProcRetDuimp
Objetivo   : Faz a chamada no portal único
Parâmetro  : cRet    : string com o retorno do portal único
             aRet    : array onde será retornado .f. em caso de erro
             oLogView: objeto para tratamento do eecview
             cTipo   : tipo da integração, ex: CAPA, ITEM, DIAGNOSTICO ou REGISTRO
             cMsgErr : mensagem a ser exibida em caso de problema na estrutura do arquivo no retorno do portal único
Retorno    : retorna .T. se quis continuar ou não passou pela pergunta e retorna .F. se o usuário não quis continuar 
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function ProcRetDuimp(cRet,aRet,oLogView,cTipo,cMsgErr)
Local lReturn := .t.
Local cMsg := ''
Local aDuimp := getRetorno(cRet)   
if len(aDuimp) == 0 
    getLog(cMsgErr,oLogView)  //Houve algum problema no retorno ?????? da DUIMP, verifique a mensagem acima
    aRet[2] := .F.  
else
    cMsg := aDuimp[3]
EndIf   
If aRet[2] 
   Do CASE
      Case cTipo == CAPA .AND. Empty(cMsg)
            AtuReg({'EV1_DI_NUM','EV1_VERSAO'},aDuimp)
      Case cTipo == CAPA .AND. !Empty(cMsg)         
            AtuReg({'EV1_DI_NUM','EV1_VERSAO'},aDuimp)
            getLog(STR0022,oLogView) //Erro na camada de negócio, verifique a mensagem acima
            AtuReg({'EV1_STATUS'},{PROCESSO_PENDENTE_REVISAO})
            aRet[2] := .F. 
      Case cTipo == DIAGNOSTICO .AND. cMsg == DIAG_PROCESSAMENTO 
            AtuReg({'EV1_STATUS'},{PENDENTE_REGISTRO})
            aRet[2]:=.F.
      Case cTipo == DIAGNOSTICO .AND. cMsg $ PROC_N_IMPED 
            EECView(STR0029 + cMsg,STR0003,,,,.F.,.T.) //"Retorno do envio de diagnóstico: "
            lREturn := MsgNoYes(STR0030,STR0003) //"Deseja prosseguir com o registro de sua Duimp com alertas ou erros não impeditivos?","ATENCAO"
            aRet[3] := lREturn
      Case cTipo == DIAGNOSTICO .AND. cMsg == PROC_S_IMPED 
            EECView(STR0029 + cMsg,STR0003,,,,.F.,.T.) //"Retorno do envio de diagnóstico: "
            lREturn := MsgNoYes(STR0031,"ATENCAO")   //"Deseja prosseguir com o registro de sua Duimp?","ATENCAO"
      Case cTipo == VALOR_CALCULADO .And. !Empty(cMsg)
            AtuReg({'EV1_STATUS'},{PENDENTE_REGISTRO})
            getLog(STR0022,oLogView) //Erro na camada de negócio, verifique a mensagem acima
            aRet[2] := .F.  
      Case cTipo == VALOR_CALCULADO .And. Empty(cMsg)          
            aRet[2] := gravaDesp(aDuimp[4]) 
      Case cTipo == REGISTRO .And. Empty(cMsg)            
            AtuReg({'EV1_STATUS','EV1_VERSAO'},{DUIMP_REGISTRADA,aDuimp[2]})
            AtuReg({'W6_DI_NUM','W6_VERSAO','W6_DTREG_D'},{aDuimp[1],aDuimp[2],Date()},"SW6")
      Case !Empty(cMsg)
            getLog(STR0022,oLogView) //Erro na camada de negócio, verifique a mensagem acima
            AtuReg({'EV1_STATUS'},{PROCESSO_PENDENTE_REVISAO})  
            aRet[2] := .F.        
   EndCase  
EndIf             
Return lReturn

/*
Função     : IntegItens
Objetivo   : Realiza a integração dos itens da DUIMP
Parâmetro  : oEasyJs
Retorno    : a primeira posição .T. se deve continuar a integração e .F. se não deve (erros de conexão ou de formatação do json inválido)
             a segunda posição .T. se deve continuar a integração de diagnóstico e registro e .F. se não deve (erros da camada de negócio)
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function IntegItens(oEasyJs,cUrlAuth,cUrlInteg,cHawb,cLote,oLogView)
local aItsDUIMP := {}
local aItensTxt := InfItens(cHawb, cLote, @aItsDUIMP)
local nTotItens := 0
local cUrlITDuimp := cUrlInteg + "/duimp-api/api/ext/duimp/"+alltrim(EV1->EV1_DI_NUM)+"/"+alltrim(EV1->EV1_VERSAO)+"/itens"
local cRet := '', cAtuReg:=''
local oJson  := JsonObject():New()
local cError 
local aRet := {.T.,.T.}  //[1] erro de conexão, [2] erro da camada de negócio  
local nQtdItem := 0
local nTotal := 0
local i:=0

Begin Sequence

   nTotal := len(aItensTxt)
   _aItsDUIMP := aClone(aItsDUIMP)
   _nQtdeItem := len(_aItsDUIMP)
   nTotItens := _nQtdeItem
   for i:=1 to nTotal
      nQtdItem := nTotItens
      if i < nTotal 
         nQtdItem := 100
         nTotItens -= 100
      endif
      cError := oJson:FromJson(aItensTxt[i])
      If cError == nil
         cString := StrTran( STR0017, '###', lTrim(str(i)))                   
         cString := StrTran(cString, '@@@',lTrim(str(nQtdItem)))
         getLog(cString,oLogView) //Iniciando o envio dos Dados dos Itens da Duimp para inclusão ### de @@@       
         getLog(aItensTxt[i],oLogView)        
            
         cAtuReg := "AtuReg({'EV1_STATUS'},{'" + PENDENTE_INTEGRACAO + "'})"
         cRet := execEndPoint(oEasyJs,cUrlAuth , cUrlItDuimp , aItensTxt[i],'POST',@aRet,oLogView,cAtuReg)
         getLog(STR0018,oLogView) //Retorno da gravação dos Dados dos Itens da Duimp:               
         getLog(cRet,oLogView)                  
         ProcRetDuimp(cRet,@aRet,oLogView,ITEM,STR0021) //"Houve algum problema no retorno da gravação do item da DUIMP, verifique a mensagem acima"       
      else 
         getLog(STR0020 ,oLogView) //Erro na formatação do json gerado    //atenção advpr OK
         getLog(cError ,oLogView)  
         AtuReg({'EV1_STATUS'},{PENDENTE_INTEGRACAO})         
         aRet[1] := .F.
         exit
      EndIf   
   Next
End Sequence
fwfreeobj(oJson)
Return aRet

/*
Função     : getLog
Objetivo   : gera o log para o eecview e posterior gravação no registro
Parâmetro  :cMsg: Mensagem que será enviada ao log
            oLogView: objeto que receberá o log
            lSpace: se true vai incluir espaços + hora na mensagem, se false não altera a mensagem
Retorno    :
Autor      : Maurício Frison
Data/Hora  : Abril/2022
Obs.       :
*/
static function getLog(cMsg,oLogView,lspace)
Default lspace := .T.
cSpace := iif(lspace,space(10) + '-' + time()+' ','')
oLogView:appendText(cSpace+cMsg+ENTER+ENTER)
oLogView:Refresh()
oLogView:goEnd()
return

/*
Função:    getRetorno
Objetivo:  tratar o json retornado pelo portal e obter o número da D.I. gerada e a Versão
Retorno:   aRet contendo o númerod da D.I. na primeira posição
                           versão na segunda posição
                           erro da camada de negócio se houver na terceira posição
Autor:     Maurício Frison
Data:      Maio/2022
*/
static function getRetorno(cMsg)
Local nj,nje
Local cRet
Local oJson
Local aJson       := {}
Local aJsonErros  := {}, aJsonErr := {}
Local cErros      :=""
Local aResult     :={}
Local aTributos   :={}
Local jIdent
  
   if ! empty(cMsg)
      cRet     := '{"items":['+cMsg+']}'
      oJson    := JsonObject():New()
      cRetJson := oJson:FromJson(cRet)
      if valtype(cRetJson) == "U" .And. valtype(oJson:GetJsonObject("items")) == "A"
            aJson    := oJson:GetJsonObject("items")
            if len(aJson) > 0
               jIdent := aJson[1]:GetJsonObject("identificacao")
               cNumero := jIdent:GetJsonText("numero")
               cVersao := jIdent:GetJsonText("versao")
               cErros  := aJson[1]:GetJsonObject("errors")  //cErros do tipo "A", tipo "C" ou nil
               cSituacao := aJson[1]:GetJsonObject("situacao")
               aTributos  := aJson[1]:getJsonObject("tributosCalculados")  
               
               If !empty(cNumero) .and. !empty(cVersao)
                  aadd(aResult,cNumero)
                  aadd(aResult,cVersao) 
                  If aTributos != nil .And. Valtype(aTributos) == "A"
                     aadd(aResult,'')
                     aadd(aResult,getTributos(aTributos))
                  Else    
                     If cSituacao != nil 
                        If cSituacao != DIAG_PROCESSAMENTO             
                           cErros := cSituacao
                        else
                           aadd(aResult,cSituacao) 
                        EndIf
                     Else      
                        if valtype(aJson[1]:GetJsonObject("errors")) == "A" .or. valtype(aJson[1]:GetJsonObject("multiStatus")) == "A" 
                           aJsonErros := if(valtype(aJson[1]:GetJsonObject("errors")) == "A",aJson[1]:GetJsonObject("errors"), aJson[1]:GetJsonObject("multiStatus"))
                           cErros:="" //tem que deixar a variável cErros com o tipo Caracter, qunado ele é criado como array, é tratado um nível inferior aqui dentro onde tem que ser caracater
                                    // se foi gerado como caracter não vai entrar aqui
                           for nj := 1 to len(aJsonErros)
                              If ValType(aJsonErros[nj]:getJsonObject("errors") ) == "A" 
                                 aJsonErr := aJsonErros[nj]:getJsonObject("errors")                             
                                 For nje := 1 to len(aJsonErr)
                                    cErros += aJsonErr[nje]:getJsonText("message") + ENTER    
                                 Next nje    
                              Else
                                 cErros += aJsonErros[nj]:getJsonText("message") + ENTER
                              EndIF  
                           next
                        endif
                     EndIf   
                  EndIF   
                  aadd(aResult,if(cErros==nil,'',cErros))    
               EndIf   

            endif
         FreeObj(oJson)
      endif
   endif
return aResult

/*
Função     : getTributos
Objetivo   : Pega o json de retorno do portal único dos valores calculados e retorna um array com imposto e valor 
Parâmetro  : aTributos - Array com os tributos vindos do portal único
Retorno    : Retornar um array com o tipo do imposto, o códgio no sistema EIC e o valor
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function getTributos(aTributos)
Local aRet:={}
Local aImpostos := {}
Local i:=0
Local cImposto 
Local nValor
For i:=1 to len(aTributos)
    aImpostos := aTributos[i]:getJsonObject("valoresBRL")  
    cImposto  := aTributos[i]:getJsonText("tipo")
    nValor    := val(aImpostos:getJsonText("calculado"))
    aadd(aRet,{cImposto,nValor})
Next    
return aRet

/*
Função     : gravaDesp
Objetivo   : Grava as despesas 
Parâmetro  : aImpostos - Array com o valor e o tipo do imposto
Retorno    : Retornar .T. se conseguiu gravar e .F. se não conseguiu
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function gravaDesp(aImpostos)
Local lRet:= .T.
Local i:=0
Local cCodImp := ""
Local cSWDFil := xFilial("SWD")
SWD->(DBSETORDER(1))
For i:=1 to len(aImpostos)
    cCodImp := getCodImposto(aImpostos[i][1])
    If !SWD->(DBSEEK( cSWDFil + EV1->EV1_HAWB + cCodImp)) 
        SWD->(RECLOCK("SWD",.T.)) 
        SWD->WD_FILIAL  := cSWDFil 
        SWD->WD_HAWB    := EV1->EV1_HAWB 
        SWD->WD_DESPESA := cCodImp
        SWD->WD_DES_ADI := Date()
        SWD->WD_BASEADI := '2' //ADIANTADO 2-Nao
        SWD->WD_PAGOPOR := '2' //PAGO POR 2-Importador
    else
        SWD->(RECLOCK("SWD",.F.))
    EndIf
    SWD->WD_VALOR_R := aImpostos[i][2]
    SWD->(MSUNLOCK())
Next    
return lRet

/*
Função     : getCodImposto
Objetivo   : Gerar o código do imposto utilizado no SIGAEIC a partir do imposto retornadao pelo portal único
Parâmetro  : Imposto
Retorno    : Retorna o código do imposto utilizado no SIGAEIC
Autor      : Maurício Frison
Data/Hora  : Maio/2022
Obs.       :
*/
static function getCodImposto(cImposto)
cCodImposto:=''
Do Case
   Case cImposto == 'II'
        cCodImposto:=II
   Case cImposto == 'IPI'
        cCodImposto:=IPI
   Case cImposto == 'PIS'
        cCodImposto:=PIS
   Case cImposto == 'COFINS'
        cCodImposto:=COFINS
ENDCASE
Return cCodImposto

/*
Função     : InfGerais
Objetivo   : Realiza a criação dos json dos dados gerais da DUIMP
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function InfGerais(cHawb, cLote)
   local aArea      := getArea()
   local aAreaEV1   := {}
   local cJson      := ""
   local cIdentif   := ""
   local cCarga     := ""
   local cDocs      := ""

   default cHawb      := ""
   default cLote      := ""

   dbSelectArea("EV1")
   aAreaEV1 := EV1->(getArea())
   EV1->(dbSetOrder(2)) // EV1_FILIAL+EV1_LOTE+EV1_HAWB
   EV1->(dbSeek( xFilial("EV1") + cLote + cHawb))

   cJson := '{'

   // Identificação
   cIdentif := getIdent()
   cJson +=    '"identificacao":{'
   cJson +=       cIdentif
   cJson +=    '},'

   // Carga
   cCarga := getCarga()
   cJson +=    '"carga":{'
   cJson +=       cCarga
   cJson +=    '},'

   // Documentos
   cDocs := getDocs(cHawb, cLote)
   cJson +=    '"documentos":{'
   cJson +=       cDocs
   cJson +=    '}'

   cJson += '}'
 
   restArea(aAreaEV1)
   restArea(aArea)

return cJson

/*
Função     : getIdent
Objetivo   : Realiza a criação dos json dos dados da tabela EV1 - identificacao
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getIdent()
   local cIdentif   := ''
   local cNi        := ''
   local cInfComp   := ''

   if EV1->(Found())
      cNi        := alltrim(EV1->EV1_IMPNRO)
      cInfComp   := alltrim(EV1->EV1_INFCOM)
   endif

   cIdentif += '"importador":{'
   cIdentif +=    '"ni":"' + cNi + '"'
   cIdentif +=    '}'
   if !empty(cInfComp)
      cIdentif += ', "informacaoComplementar":"' + cInfComp + '"'
   endif

return cIdentif

/*
Função     : getCarga
Objetivo   : Realiza a criação dos json dos dados da tabela EV1 - carga
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getCarga()
   local cCarga     := ''
   local cIdenCarga := ''
   local cCodCarga  := ''
   local cMoeSeg    := ''
   local cVlrSeg    := '0'
 
   if EV1->(Found())
      cIdenCarga := alltrim(EV1->EV1_COIDM)
      cCodCarga  := alltrim(EV1->EV1_URFDES)
      cMoeSeg    := alltrim(EV1->EV1_SEGMOE)
      cVlrSeg    := StrTransf( StrTransf(alltrim(EV1->EV1_SETOMO), ".","") , ",",".") 
   endif

   cCarga += '"identificacao":"' + cIdenCarga + '",'
   cCarga += '"unidadeDeclarada":{'
   cCarga +=    '"codigo":"' + cCodCarga + '"'
   cCarga +=    '}'
   if !empty(cMoeSeg) .and. val(cVlrSeg) > 0
      cCarga += ', "seguro":{'
      cCarga +=      '"codigoMoedaNegociada":"' + cMoeSeg + '",'
      cCarga +=      '"valorMoedaNegociada": ' + cVlrSeg
      cCarga += '}'
   endif
 
return cCarga

/*
Função     : getDocs
Objetivo   : Realiza a criação dos json dos dados da tabela EV9 - Documentos
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getDocs(cHawb, cLote)
   local aAreaEV9   := {}
   local cDocsInst  := ''
   local cDocs      := ''
   local aAreaSW6   := {}
   local aAreaSW9   := {}
   local aAreaEYZ   := {}
   local aAreaSW2   := {}
   local cValor     := ""
   local cCodVin    := ""
   local cDocTo     := ""
   local aDados     := {}
   local cProcessos := ''
  
   default cHawb      := ""
   default cLote      := ""

   dbSelectArea("EV9")
   aAreaEV9 := EV9->(getArea())

   EV9->(dbSetOrder(2)) // EV9_FILIAL+EV9_LOTE+EV9_HAWB+EV9_CODIN
   if EV9->(dbSeek( xFilial("EV9") + cLote + cHawb))

      dbSelectArea("SW6")
      aAreaSW6 := SW6->(getArea())
      SW6->(dbSetOrder(1)) // W6_FILIAL+W6_HAWB

      dbSelectArea("SW9")
      aAreaSW9 := SW9->(getArea())

      dbSelectArea("EYZ")
      aAreaEYZ := EYZ->(getArea())

      dbSelectArea("SW2")
      aAreaSW2 := SW2->(getArea())

      while EV9->(!eof()) .and. EV9->EV9_FILIAL == xFilial("EV9") .and. EV9->EV9_LOTE == cLote .and. EV9->EV9_HAWB == cHawb

         cCodVin := alltrim(EV9->EV9_CODIN)
         cDocTo := alltrim(EV9->EV9_DOCTO)
         cValor := ""
         aDados := {}

         cDocsInst += '{'
         cDocsInst +=      '"tipo":{'
         cDocsInst +=         '"codigo":"' + cCodVin + '"'
         cDocsInst +=      '},'
         cDocsInst +=      '"palavrasChave":['
         cDocsInst +=         '{'
         cDocsInst +=            '"codigo": 1,'
         cDocsInst +=            '"valor":"' + cDocTo + '"'
         cDocsInst +=         '}'

         do case
            case cCodVin == "30" // Conhecimento de Embarque
               SW6->(dbSeek( xFilial("SW6") + EV9->EV9_HAWB ))
               if !empty(SW6->W6_TIPOCON)
                  aDados := FWGetSX5("47", SW6->W6_TIPOCON)
                  if len(aDados) > 0
                     cDocsInst += ',{'
                     cDocsInst +=   '"codigo": 2,'
                     cDocsInst +=   '"valor":"' + aDados[1][4] + '"'
                     cDocsInst += '}'
                  endif
               endif
               cDocsInst += ',{'
               cDocsInst +=   '"codigo": 10,'
               cDocsInst +=   '"valor":"' + FWTimeStamp(5, SW6->W6_DT_EMB, "00:00:00") + '"'
               cDocsInst += '}'

            case cCodVin == "49" // Fatura Comercial
               aDados := getInfInv(EV9->EV9_HAWB, cDocTo)
               if len(aDados) > 0
                  if !empty(aDados[1])
                     cDocsInst += ',{'
                     cDocsInst +=   '"codigo": 4,'
                     cDocsInst +=   '"valor":"' + FWTimeStamp(5, aDados[1], "00:00:00") + '"'
                     cDocsInst += '}'
                  endif
                  if aDados[2] > 0
                     cDocsInst += ',{'
                     cDocsInst +=   '"codigo": 6,'
                     cDocsInst +=   '"valor":"' +  StrTransf( StrTransf( alltrim(str( aDados[2] )) , ".","") , ",",".") + '"'
                     cDocsInst += '}'
                  endif
               endif

            case cCodVin == "50" // Fatura Proforma
               aDados := getInfProf(EV9->EV9_HAWB, cDocTo)
               if len(aDados) > 0
                  if !empty(aDados[1])
                     cDocsInst += ',{'
                     cDocsInst +=   '"codigo": 4,'
                     cDocsInst +=   '"valor":"' + FWTimeStamp(5, aDados[1], "00:00:00") + '"'
                     cDocsInst += '}'
                  endif
               endif

         end case

         cDocsInst +=      ']'
         cDocsInst += '},'

         EV9->(dbSkip())
      end

      cDocsInst := substr(alltrim(cDocsInst), 1, len(alltrim(cDocsInst))-1 )

      restArea(aAreaSW6)
      restArea(aAreaSW9)
      restArea(aAreaEYZ)
      restArea(aAreaSW2)

   endif

   cDocs += '"documentosInstrucao":['
   cDocs +=    cDocsInst
   cDocs += ']'

   // Processos
   cProcessos := ""
   getProces(cHawb, cLote, @cProcessos)
   if !empty(cProcessos)
      cDocs += ',"processos":['
      cDocs +=    cProcessos
      cDocs += ']'
   endif

   restArea(aAreaEV9)

return cDocs

/*
Função     : getInfInv
Objetivo   : Retorna os dados das invoices do processo
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getInfInv(cHawb, cInvoice)
   local aRet       := {"", 0}
   local cAliasQry  := ""

   default cHawb      := ""
   default cInvoice   := ""

   // Carregando 49 - Fatura Comercial
   cAliasQry := getNextAlias()
   beginSQL Alias cAliasQry
      SELECT SW9.R_E_C_N_O_ RECNO
      FROM %table:SW9% SW9
      WHERE SW9.%notDel%
         AND SW9.W9_FILIAL = %xfilial:SW9%
         AND SW9.W9_HAWB = %Exp:cHawb%
         AND SW9.W9_INVOICE = %Exp:cInvoice%
   endSql

   (cAliasQry)->(dbGoTop())
   if (cAliasQry)->(!eof()) .and. (cAliasQry)->RECNO > 0
      SW9->(dbGoTo( (cAliasQry)->RECNO))
      aRet[1] := SW9->W9_DT_EMIS
      aRet[2] := DI501RetVal("TOT_INV", "TAB", .T.)
   endif

   (cAliasQry)->(DBCloseArea())

return aRet

/*
Função     : getInfProf
Objetivo   : Retorna os dados das proformas do processo
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getInfProf(cHawb, cProforma)
   local aRet       := {""}
   local cAliasQry  := ""
   local lAchouEYZ  := .F.

   default cHawb      := ""
   default cProforma  := ""

   // Carregando 50 - Fatura Proforma
   cAliasQry := getNextAlias()
   beginSQL Alias cAliasQry
      SELECT DISTINCT EYZ.EYZ_DT_PRO 
      FROM %table:SW7% SW7
         INNER JOIN %table:EYZ% EYZ ON EYZ.%notDel% 
            AND EYZ.EYZ_FILIAL = %xfilial:EYZ%
            AND EYZ.EYZ_PO_NUM = SW7.W7_PO_NUM
            AND EYZ.EYZ_NR_PRO = %Exp:cProforma% 
      WHERE SW7.%notDel%  
         AND SW7.W7_FILIAL = %xfilial:SW7%
         AND SW7.W7_HAWB = %Exp:cHawb% 
   endSql

   TCSetField( cAliasQry, "EYZ_DT_PRO", "D", 8, 0 )

   (cAliasQry)->(dbGoTop())
   if (cAliasQry)->(!eof())
      aRet[1] := (cAliasQry)->EYZ_DT_PRO
      lAchouEYZ := .T. 
   endif
   (cAliasQry)->(DBCloseArea())

   if !lAchouEYZ
      cAliasQry := getNextAlias()
      beginSQL Alias cAliasQry
         SELECT DISTINCT W2_DT_PRO
         FROM %table:SW7% SW7
            INNER JOIN %table:SW3% SW3 ON SW3.%notDel% 
               AND SW3.W3_FILIAL = %xfilial:SW3%
               AND SW3.W3_PO_NUM = SW7.W7_PO_NUM
               AND SW3.W3_POSICAO = SW7.W7_POSICAO
            INNER JOIN %table:SW2% SW2 ON SW2.%notDel% 
               AND SW2.W2_FILIAL = %xfilial:SW2%
               AND SW2.W2_PO_NUM = SW3.W3_PO_NUM
               AND SW2.W2_NR_PRO = %Exp:cProforma% 
         WHERE SW7.%notDel%  
            AND SW7.W7_FILIAL = %xfilial:SW7%
            AND SW7.W7_HAWB = %Exp:cHawb% 
      endSql

      TCSetField( cAliasQry, "W2_DT_PRO", "D", 8, 0 )

      (cAliasQry)->(dbGoTop())
      if (cAliasQry)->(!eof())
         aRet[1] := (cAliasQry)->W2_DT_PRO
      endif
      (cAliasQry)->(DBCloseArea())
   endif

return aRet

/*
Função     : getProces
Objetivo   : Realiza a criação dos json dos dados da tabela EVB - processos
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getProces(cHawb, cLote, cProcessos)
   local aArea      := getArea()
   local aAreaEVB   := {}

   default cHawb      := ""
   default cLote      := ""
   default cProcessos := ""

   dbSelectArea("EVB")
   aAreaEVB := EVB->(getArea())

   EVB->(dbSetOrder(2)) // EVB_FILIAL+EVB_LOTE+EVB_HAWB
   if EVB->(dbSeek( xFilial("EVB") + cLote + cHawb))
      while EVB->(!eof()) .and. EVB->EVB_FILIAL == xFilial("EVB") .and. EVB->EVB_LOTE == cLote .and. EVB->EVB_HAWB == cHawb
         cProcessos += '{'
         cProcessos +=     '"identificacao":"' + alltrim(EVB->EVB_DESPV) + '",'
         cProcessos +=     '"tipo":"' + alltrim(EVB->EVB_CODPV) + '"'
         cProcessos += '},'
         EVB->(dbSkip())
      end
      cProcessos := substr(alltrim(cProcessos), 1, len(alltrim(cProcessos))-1 )
   endif
 
   restArea(aAreaEVB)
   restArea(aArea)

return nil

/*
Função     : InfItens
Objetivo   : Realiza a criação dos json dos dados dos itens da DUIMP
Parâmetro  :
Retorno    : aRet: array com os jsons dos itens gerados
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function InfItens(cHawb, cLote, aItsDUIMP)
   local aArea      := getArea()
   local aAreaSWV   := {}
   local aAreaEV2   := {}
   local aRet       := {}
   local cQrySWV    := nil
   local lFoundEV2  := .F.
   local nCountItem := 0
   local cJsonItem  := ''
   local cProduto   := ''
   local cCaracImp  := ''
   local cIndExpFab := ''
   local cInfInd    := ''
   local cInfFab    := ''
   local cFabric    := ''
   local cExport    := ''
   local cIndCompVd := ''
   local cMerc      := ''
   local cCondVenda := ''
   local cLPCOs     := ''
   local cCertMerc  := ''
   local cDocVincs  := ''
   local cDadosCamb := ''
   local cJson      := ''
   local cMsgItens  := ""

   default cHawb      := ""
   default cLote      := ""
   default aItsDUIMP  := {}

   dbSelectArea("SWV")
   aAreaSWV := SWV->(getArea())

   if getItens(@cQrySWV, cHawb)

      dbSelectArea("EV2")
      aAreaEV2 := EV2->(getArea())

      nCountItem := 0
      cMsgItens := ""

      EV2->(dbSetOrder(3)) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI
   
      while (cQrySWV)->(!eof())

         SWV->(dbGoto((cQrySWV)->RECNO))
         lFoundEV2 := EV2->(dbSeek( xFilial("EV2") + cLote + SWV->WV_HAWB + SWV->WV_SEQDUIM))

         nCountItem += 1
         aAdd( aItsDUIMP, { SWV->WV_SEQDUIM, SWV->WV_ID } )
         cInfInd := ''
         cInfFab := ''

         cJsonItem += '{'
         cJsonItem +=      '"identificacao":{'
         cJsonItem +=            '"numeroItem": ' + cValToChar(val(SWV->WV_SEQDUIM)) // Número do item da Duimp.
         cJsonItem +=            '}'

         // "produto"
         cProduto := getProd(lFoundEV2)
         if !empty(cProduto)
            cJsonItem +=   ',"produto":{'
            cJsonItem +=         cProduto
            cJsonItem +=         '}'
         endif

         // "caracterizacaoImportacao"
         cCaracImp := getCaracImp(lFoundEV2)
         if !empty(cCaracImp)
            cJsonItem +=   ',"caracterizacaoImportacao":{'
            cJsonItem +=         cCaracImp
            cJsonItem +=         '}'
         endif

         // "indicadorExportadorFabricante"
         cIndExpFab := getExpFab(lFoundEV2, @cInfInd)
         if !empty(cIndExpFab)
            cJsonItem +=   ',"indicadorExportadorFabricante":{'
            cJsonItem +=         cIndExpFab
            cJsonItem +=         '}'
         endif

         // "fabricante"
         cFabric := getFabric(lFoundEV2, @cInfFab)
         if !empty(cFabric)
            cJsonItem +=   ',"fabricante":{'
            cJsonItem +=         cFabric
            cJsonItem +=         '}'
         endif

         // "exportador"
         cExport := getExport(lFoundEV2, cInfInd, cInfFab)
         if !empty(cExport)
            cJsonItem +=   ',"exportador":{'
            cJsonItem +=         cExport
            cJsonItem +=         '}'
         endif

         // "indicadorCompradorVendedor"
         cIndCompVd := getIndCmpVd(lFoundEV2)
         if !empty(cIndCompVd)
            cJsonItem +=   ',"indicadorCompradorVendedor":{'
            cJsonItem +=         cIndCompVd
            cJsonItem +=         '}'
         endif

         // "mercadoria"
         cMerc := getMercad(lFoundEV2)
         if !empty(cMerc)
            cJsonItem +=   ',"mercadoria":{'
            cJsonItem +=         cMerc
            cJsonItem +=         '}'
         endif

         // "condicaoVenda"
         cCondVenda := getCondVend(lFoundEV2, cLote)
         if !empty(cCondVenda)
            cJsonItem +=   ',"condicaoVenda":{'
            cJsonItem +=         cCondVenda
            cJsonItem +=         '}'
         endif

         // "lpcos"
         cLPCOs := getLPCOS(cLote)
         if !empty(cLPCOs)
            cJsonItem +=   ',"lpcos":['
            cJsonItem +=         cLPCOs
            cJsonItem +=         ']'
         endif

         // "certificadoMercosul"
         cCertMerc := getCertMerc(cLote)
         if !empty(cCertMerc)
            cJsonItem +=   ',"certificadoMercosul":['
            cJsonItem +=         cCertMerc
            cJsonItem +=         ']'
         endif

         // "documentosVinculados"
         cDocVincs := getDocVincs(cLote)
         if !empty(cDocVincs)
            cJsonItem +=   ',"documentosVinculados":['
            cJsonItem +=         cDocVincs
            cJsonItem +=         ']'
         endif

         // "dadosCambiais"
         cDadosCamb := getDadosCam(lFoundEV2)
         if !empty(cDadosCamb)
            cJsonItem +=   ',"dadosCambiais":{'
            cJsonItem +=         cDadosCamb
            cJsonItem +=         '}'
         endif

         cJsonItem += '},'

         (cQrySWV)->(dbSkip())

         if nCountItem == 100 .or. (cQrySWV)->(eof())

            cJsonItem := substr(alltrim(cJsonItem), 1, len(alltrim(cJsonItem))-1 )
            cJson := '['
            cJson += cJsonItem
            cJson += ']'

            AADD(aRet,cJson)

            cJsonItem := ''
            nCountItem := 0

         endif

      end

      restArea(aAreaEV2)

   endif

   (cQrySWV)->(dbCloseArea())

   restArea(aAreaSWV)
   restArea(aArea)

return aRet

/*
Função     : getItens
Objetivo   : Retorna um alias com registros da SWV
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getItens(cAliasQry, cHawb, lGetAll)
   local lRet  := .F.
   local aArea := {}

   default cAliasQry  := getNextAlias()
   default cHawb      := ""
   default lGetAll    := .F.

   cAliasQry := getNextAlias()
   beginSQL Alias cAliasQry
      SELECT SWV.R_E_C_N_O_ RECNO
      FROM %table:SWV% SWV
      WHERE SWV.%notDel%
         AND SWV.WV_FILIAL = %xfilial:SWV%
         AND SWV.WV_HAWB = %Exp:cHawb%
   endSql

   (cAliasQry)->(dbGoTop())
   lRet := (cAliasQry)->(!eof())

   if lRet .and. lGetAll

      aArea := SWV->(getArea())

      while (cAliasQry)->(!eof())
         SWV->(dbGoto( (cAliasQry)->RECNO ))
         if SWV->(recno()) == (cAliasQry)->RECNO
            aAdd( _aItsDUIMP, { SWV->WV_SEQDUIM, SWV->WV_ID } )
         endif
         (cAliasQry)->(dbSkip())
      enddo

      _nQtdeItem := len(_aItsDUIMP)

      restArea(aArea)
      (cAliasQry)->(dbCloseArea())

   endif

return lRet

/*
Função     : getProd
Objetivo   : Retorna os dados para estrutura "produto"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getProd(lFoundEV2)
   local cJson := ''

   default lFoundEV2   := .F.

   /*
   "codigo": 10,
   "versao": "1",
   "cnpjRaiz": "00000000"
   */

   if lFoundEV2

      if !empty(EV2->EV2_IDPTCP) // Código do produto.
         cJson += '"codigo":"' + alltrim(EV2->EV2_IDPTCP) + '"'
      endif

      if !empty(EV2->EV2_VRSACP) // Versão do produto.
         cJson += if(!empty(cJson), ',', '')
         cJson += '"versao":"' + alltrim(EV2->EV2_VRSACP) + '"'
      endif

      if !empty(EV2->EV2_CNPJRZ) // Cnpj raiz do operador estrangeiro.
         cJson += if(!empty(cJson), ',', '')
         cJson += '"cnpjRaiz":"' + alltrim(EV2->EV2_CNPJRZ) + '"'
      endif

   endif

return cJson

/*
Função     : getCaracImp
Objetivo   : Retorna os dados para estrutura "caracterizacaoImportacao"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getCaracImp(lFoundEV2)
   local cJson := ''

   default lFoundEV2   := .F.

   /*
   "indicador": "IMPORTACAO_DIRETA", 
   "ni": "00000000000191"
   */

   if lFoundEV2

      if !empty(EV2->EV2_IMPCO)
         cJson += '"indicador":"' + if(alltrim(EV2->EV2_IMPCO) == "1",'IMPORTACAO_POR_CONTA_E_ORDEM', 'IMPORTACAO_DIRETA') + '"' // Indicador de importação por terceiros. [ 2 = IMPORTACAO_DIRETA, 1 = IMPORTACAO_POR_CONTA_E_ORDEM ]
         if alltrim(EV2->EV2_IMPCO) == "1" .and. !empty(EV2->EV2_CNPJAD)
            cJson += ',"ni":"' + alltrim(EV2->EV2_CNPJAD) + '"' // CNPJ do adquirente. Observação: Este atributo é informado apenas quando selecionada a opção 'IMPORTACAO_POR_CONTA_E_ORDEM'
         endif
      endif

   endif

return cJson

/*
Função     : getExpFab
Objetivo   : Retorna os dados para estrutura "indicadorExportadorFabricante"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getExpFab(lFoundEV2, cIndExpFab)
   local cJson := ''

   default lFoundEV2   := .F.
   default cIndExpFab  := ""

   /*
   "codigo": "EXPORTADOR_DIFERENTE_FABRICANTE"
   */

   if lFoundEV2

      if !empty(EV2->EV2_FABFOR) // 1=Fabricante / Produtor é o Exportador; 2=Fabricante / Produtor não é o Exportador; 3=O Fabricante / Produtor é Desconhecido 
         cIndExpFab :=  if( alltrim(EV2->EV2_FABFOR) == "1" ,'EXPORTADOR_IGUAL_FABRICANTE', 'EXPORTADOR_DIFERENTE_FABRICANTE')
         cJson += '"codigo":"' + cIndExpFab + '"' // Código da relação exportador x fabricante. [ EXPORTADOR_DIFERENTE_FABRICANTE, EXPORTADOR_IGUAL_FABRICANTE ]
      endif

   endif

return cJson

/*
Função     : getFabric
Objetivo   : Retorna os dados para estrutura "fabricante"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getFabric(lFoundEV2, cInfFab)
   local cJson := ''

   default lFoundEV2   := .F.
   default cInfFab     := ""

   /*
   "codigo": "2104",
   "versao": "1",
   "cnpjRaiz": "00000000",
   "pais": {
      "codigo": "BR"
   }
   */

   if lFoundEV2

      if !empty(EV2->EV2_TINFA)
         cJson += '"codigo":"' + alltrim(EV2->EV2_TINFA) + '"' // Código do Fabricante.
      endif

      if !empty(EV2->EV2_VRSFAB)
         cJson += if(!empty(cJson), ',', '')
         cJson += '"versao":"' + alltrim(EV2->EV2_VRSFAB) + '"' // Versão do fabricante.
      endif

      if !empty(EV2->EV2_CNPJRZ)
         cJson += if(!empty(cJson), ',', '')
         cJson += '"cnpjRaiz":"' + alltrim(EV2->EV2_CNPJRZ) + '"' // CNPJ raiz da empresa responsável.
      endif

      if !empty(EV2->EV2_PAIOME)
         cJson += if(!empty(cJson), ',', '')
         cJson += '"pais":{'
         cJson +=    '"codigo":"' + alltrim(EV2->EV2_PAIOME) + '"' // Código do país de origem no formato ISO (3166-1 alfa-2)
         cJson += '}'
      endif

      cInfFab := cJson

   endif

return cJson

/*
Função     : getExport
Objetivo   : Retorna os dados para estrutura "exportador"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getExport(lFoundEV2, cInfInd, cInfFab)
   local cJson := ''

   default lFoundEV2  := .F.
   default cInfInd    := ""
   default cInfFab    := ""

   /*
   "codigo": "CN001",
   "versao": "1",
   "cnpjRaiz": "00000000",
   "pais": {
      "codigo": "BR"
   }
   */

   if lFoundEV2

      // Observação: Quando o atributo "exportadorIndicadorFabricante" for preenchido com o valor "EXPORTADOR_IGUAL_FABRICANTE", os valores informados neste grupo devem ser idênticos aos valores informados no grupo "Fabricante".
      if cInfInd == "EXPORTADOR_IGUAL_FABRICANTE"
         cJson := cInfFab
      else
         if !empty(EV2->EV2_TINFO)
            cJson += '"codigo":"' + alltrim(EV2->EV2_TINFO) + '"' // Código do exportador estrangeiro (TIN).
         endif

         if !empty(EV2->EV2_VRSFOR)
            cJson += if(!empty(cJson), ',', '')
            cJson += '"versao":"' + alltrim(EV2->EV2_VRSFOR) + '"' // Versão do exportador.
         endif

         if !empty(EV2->EV2_CNPJRZ)
            cJson += if(!empty(cJson), ',', '')
            cJson += '"cnpjRaiz":"' + alltrim(EV2->EV2_CNPJRZ) + '"' // CNPJ raiz da empresa responsável.
         endif

         if !empty(EV2->EV2_PAISPR)
            cJson += if(!empty(cJson), ',', '')
            cJson += '"pais":{'
            cJson +=    '"codigo":"' + alltrim(EV2->EV2_PAISPR) + '"' // Código do país de origem no formato ISO (3166-1 alfa-2).
            cJson += '}'
         endif

      endif

   endif

return cJson

/*
Função     : getIndCmpVd
Objetivo   : Retorna os dados para estrutura "indicadorCompradorVendedor"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getIndCmpVd(lFoundEV2)
   local cJson     := ''
   local cVincCO   := ''

   default lFoundEV2 := .F.

   /*
   "codigo": "NAO_HA_VINCULACAO"
   */

   if lFoundEV2

      if !empty(EV2->EV2_VINCCO) // 1=Sem Vinculacao;2=Com vinculacao, sem influencia no preco;3=Com vinculacao, com influencia no preco
         cVincCO := alltrim(EV2->EV2_VINCCO)
         cJson += '"codigo":"' + if( cVincCO == "1" , 'NAO_HA_VINCULACAO', if( cVincCO == "2" , 'VINCULACAO_SEM_INFLUENCIA_PRECO' , 'VINCULACAO_COM_INFLUENCIA_PRECO') ) + '"' // Código de vinculação comprador x vendedor. [ NAO_HA_VINCULACAO, VINCULACAO_SEM_INFLUENCIA_PRECO, VINCULACAO_COM_INFLUENCIA_PRECO ]
      endif

   endif

return cJson

/*
Função     : getMercad
Objetivo   : Retorna os dados para estrutura "mercadoria"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getMercad(lFoundEV2)
   local cJson     := ''
   local cAplME    := ''

   default lFoundEV2 := .F.

   /*
   "tipoAplicacao": {
      "codigo": "CONSUMO"
   },
   "condicao": "NOVA",
   "unidadeComercial": "SACAS",
   "quantidadeComercial": 100.5,
   "quantidadeMedidaEstatistica": 12.12345,
   "pesoLiquido": 100,
   "moedaNegociada": {
      "codigo": "USD"
   },
   "valorUnitarioMoedaNegociada": 10,
   "descricao": "Texto de exemplo."
   */

   if lFoundEV2

      if !empty(EV2->EV2_APLME) // 1=Consumo;2=Revenda 
         cJson += '"tipoAplicacao":{'
         cAplME := alltrim(EV2->EV2_APLME) 
         cJson +=    '"codigo":"' + if( cAplME == "1", 'CONSUMO', if( cAplME == "2", 'REVENDA' , 'OUTRA' ) ) + '"' // Destinação da mercadoria de acordo com o domínio a seguir. [ CONSUMO, INCORPORACAO_ATIVO_FIXO, INDUSTRIALIZACAO, REVENDA, OUTRA ]
         cJson += '}'
      endif

      if !empty(EV2->EV2_MATUSA) // 1=Usado;2=Nao Usado
         cJson += if(!empty(cJson), ',', '')
         cJson += '"condicao":"' + if( alltrim(EV2->EV2_MATUSA) == "1", 'USADA', 'NOVA' ) + '"' // Indica se a mercadoria é nova ou usada. [ NOVA, USADA ]
      endif

      if !empty(EV2->EV2_NMCOM)
         cJson += if(!empty(cJson), ',', '')
         cJson += '"unidadeComercial":"' + alltrim(EV2->EV2_NMCOM) + '"' // Unidade de medida utilizada na comercialização da mercadoria.
      endif

      if val(EV2->EV2_QTCOM) > 0
         cJson += if(!empty(cJson), ',', '')
         cJson += '"quantidadeComercial": ' + StrTransf( StrTransf( alltrim( EV2->EV2_QTCOM ), ".","") , ",",".") + '' // Quantidade da mercadoria na unidade de medida comercial.
      endif

      if val(EV2->EV2_QT_EST) > 0
         cJson += if(!empty(cJson), ',', '')
         cJson += '"quantidadeMedidaEstatistica": ' + StrTransf( StrTransf( alltrim( EV2->EV2_QT_EST ), ".","") , ",",".") + '' // Quantidade na unidade de medida estatística associada à NCM do produto.
      endif

      if val(EV2->EV2_PESOL) > 0
         cJson += if(!empty(cJson), ',', '')
         cJson += '"pesoLiquido": ' + StrTransf( StrTransf( alltrim( EV2->EV2_PESOL ), ".","") , ",",".") + '' // Peso líquido, em quilogramas, que corresponde ao quantitativo total das mercadorias do item.
      endif

      if !empty((EV2->EV2_MOE1))
         cJson += if(!empty(cJson), ',', '')
         cJson += '"moedaNegociada": {
         cJson +=    '"codigo":"' + alltrim(EV2->EV2_MOE1) + '"' // Código da Moeda utilizada para a negociação da mercadoria e usada na expedição da fatura comercial (ISO-4217).
         cJson += '}'
      endif

      if val(EV2->EV2_VLMLE) > 0
         cJson += if(!empty(cJson), ',', '')
         cJson += '"valorUnitarioMoedaNegociada": ' + StrTransf( StrTransf( alltrim( EV2->EV2_VLMLE ), ".","") , ",",".") + '' // Valor unitário da mercadoria na condição de venda.
      endif

      if !empty((EV2->EV2_DSCCIT))
         cJson += if(!empty(cJson), ',', '')
         cJson += '"descricao":"' + alltrim(EV2->EV2_DSCCIT) + '"' // Descrição complementar da mercadoria.
      endif

   endif

return cJson

/*
Função     : getCondVend
Objetivo   : Retorna os dados para estrutura "condicaoVenda"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getCondVend(lFoundEV2, cLote, cHawb, cSeqDui)
   local cJson      := ''
   local cInfAcrDed := ''

   default lFoundEV2  := .F.
   default cLote      := EV1->EV1_LOTE
   default cHawb      := SWV->WV_HAWB
   default cSeqDui    := SWV->WV_SEQDUIM

   /*
   "metodoValoracao": {
      "codigo": 1
   },
   "incoterm": {
      "codigo": "FOB",
      "complemento": "1"
   },
   "acrescimosDeducoes": [
      {
         "tipo": "ACRESCIMO",
         "moeda": {
            "codigo": "USD",
            "valor": 100.12
         },
         "denominacao": {
            "codigo": 1
         }
      }
   ]
   */

   if lFoundEV2

      if !empty(EV2->EV2_METVAL)
         cJson += '"metodoValoracao":{'
         cJson +=    '"codigo":"' + alltrim(EV2->EV2_METVAL) + '"' // Código do método de valoração.
         cJson += '}' 
      endif

      if !empty(EV2->EV2_INCOTE)
         cJson += if(!empty(cJson), ',', '') 
         cJson += '"incoterm":{'
         cJson +=    '"codigo":"' + alltrim(EV2->EV2_INCOTE) + '"' // Código da Condição de Venda
         cJson += '}'
      endif

   endif

   cInfAcrDed := getAcrDed(cLote)
   if !empty(cInfAcrDed)
      cJson += if(!empty(cJson), ',', '') 
      cJson += '"acrescimosDeducoes":['
      cJson +=    cInfAcrDed
      cJson += ']'
   endif

return cJson

/*
Função     : getAcrDed
Objetivo   : Retorna os dados para estrutura "acrescimosDeducoes"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getAcrDed(cLote, cHawb, cSeqDui)
   local cJson := ''
   local cDeducao := ''

   default cLote      := EV1->EV1_LOTE
   default cHawb      := SWV->WV_HAWB
   default cSeqDui    := SWV->WV_SEQDUIM

   cJson := getInfAcDe("EV3", cLote, cHawb, cSeqDui)
   cDeducao := getInfAcDe("EV4", cLote, cHawb, cSeqDui)
   if !empty(cDeducao)
      cJson +=  if(!empty(cJson), ',', '') + cDeducao
   endif

return cJson

/*
Função     : getInfAcDe
Objetivo   : Retorna os dados dos acréscimos ou deduções do item
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getInfAcDe(cAliasTab, cLote, cHawb, cSeqDui)
   local aArea      := {}
   local cJson      := ''

   default cAliasTab  := ""
   default cLote      := EV1->EV1_LOTE
   default cHawb      := SWV->WV_HAWB
   default cSeqDui    := SWV->WV_SEQDUIM

   /*
      {
         "tipo": "ACRESCIMO", // [ ACRESCIMO, DEDUCAO ]
         "moeda": {
            "codigo": "USD",
            "valor": 100.12
         },
         "denominacao": {
            "codigo": 1
         }
      }
   */

   dbSelectArea(cAliasTab)
   aArea := (cAliasTab)->(getArea())

   (cAliasTab)->(dbSetOrder(3)) // EV3_FILIAL+EV3_LOTE+EV3_HAWB+EV3_SEQDUI ou EV4_FILIAL+EV4_LOTE+EV4_HAWB+EV4_SEQDUI
   if (cAliasTab)->(dbSeek( xFilial(cAliasTab)+ cLote + cHawb + cSeqDui ))

      while (cAliasTab)->(!eof()) .and. (cAliasTab)->(&(IndexKey())) == xFilial(cAliasTab) + cLote + cHawb + cSeqDui

         cJson += '{'
         cJson +=    '"tipo":"' + if( cAliasTab == "EV3", 'ACRESCIMO', 'DEDUCAO' ) + '"' // Tipo de Operação (acre?cimo ou dedução).
         if !empty((cAliasTab)->&(cAliasTab + "_MOE")) .or. val((cAliasTab)->&(cAliasTab + "_VLMLE")) > 0 
            cJson += if(!empty(cJson), ',', '') 
            cJson +=    '"moeda":{'
            cJson +=       '"codigo":"' + alltrim((cAliasTab)->&(cAliasTab + "_MOE")) + '",' // Código da Moeda negociada (ISO-4217).
            cJson +=       '"valor": ' + cValToChar(val((cAliasTab)->&(cAliasTab + "_VLMLE"))) + '' // Valor, na moeda negociada, acrescentado no/deduzido do valor da condição de venda.
            cJson +=    '}'
         endif

         if !empty(if( cAliasTab == "EV3", EV3->EV3_ACRES, EV4->EV4_DEDU ))
            cJson += if(!empty(cJson), ',', '') 
            cJson +=    '"denominacao":{'
            cJson +=       '"codigo":"' + alltrim(if( cAliasTab == "EV3", EV3->EV3_ACRES, EV4->EV4_DEDU )) + '"' // Código do acréscimo ou da dedução escolhida.
            cJson +=    '}'
         endif
         cJson += '},'

         (cAliasTab)->(dbSkip())
      end
      cJson := substr(alltrim(cJson), 1, len(alltrim(cJson))-1 )

   endif

   restArea(aArea)

return cJson

/*
Função     : getLPCOS
Objetivo   : Retorna os dados para estrutura "lpcos"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getLPCOS(cLote, cSeqDui)
   local aArea      := {}
   local cJson      := ''

   default cLote      := EV1->EV1_LOTE
   default cSeqDui    := SWV->WV_SEQDUIM

   /*
   {
      "numero": "I2000000063"
   }
   */

   dbSelectArea("EVE")
   aArea := EVE->(getArea())

   EVE->(dbSetOrder(2)) // EVE_FILIAL+EVE_LOTE+EVE_SEQDUI
   if EVE->(dbSeek( xFilial("EVE") + cLote + cSeqDui ))

      while EVE->(!eof()) .and. EVE->(&(IndexKey())) == xFilial("EVE") + cLote + cSeqDui

         if !empty(EVE->EVE_LPCO)
            cJson += '{'
            cJson +=    '"numero":"' + alltrim(EVE->EVE_LPCO) + '"' // Número do um LPCO.
            cJson += '},'
         endif

         EVE->(dbSkip())
      end

      cJson := substr(alltrim(cJson), 1, len(alltrim(cJson))-1 )

   endif

   restArea(aArea)

return cJson

/*
Função     : getCertMerc
Objetivo   : Retorna os dados para estrutura "certificadoMercosul"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getCertMerc(cLote, cHawb, cSeqDui)
   local aArea      := {}
   local cJson      := ''
   local cIdCert    := ''

   default cLote      := EV1->EV1_LOTE
   default cHawb      := SWV->WV_HAWB
   default cSeqDui    := SWV->WV_SEQDUIM

   /*
   {
      "tipo": "CCPTC",
      "numero": "PY-06000AA0000A-0001",
      "quantidade": "1.12345"
   }
   */

   dbSelectArea("EVI")
   aArea := EVI->(getArea())

   EVI->(dbSetOrder(2)) // EVI_FILIAL+EVI_LOTE+EVI_HAWB+EVI_SEQDUI
   if EVI->(dbSeek( xFilial("EVI") + cLote + cHawb + cSeqDui ))

      while EVI->(!eof()) .and. EVI->(&(IndexKey())) == xFilial("EVI") + cLote + cHawb + cSeqDui

         if !empty(EVI->EVI_IDCERT) .or. !empty(EVI->EVI_DEMERC) .or. !empty(EVI->EVI_QTDCER) 

            cJson += '{'

            if !empty(EVI->EVI_IDCERT) // 1=Sem Certificado;2=CCPTC;3=CCROM
               cIdCert := alltrim(EVI->EVI_IDCERT)
               cJson +=    '"tipo":"' + if( cIdCert == "2",'CCPTC', if( cIdCert == "3", 'CCROM', 'SEM_CERTIFICADO'))  + '"' // Tipo de certificado Mercosul. [ SEM_CERTIFICADO, CCPTC, CCROM ]
            endif

            if !empty(EVI->EVI_DEMERC)
               cJson += if(!empty(cJson), ',', '') 
               cJson +=    '"numero":"' + alltrim(EVI->EVI_DEMERC) + '"' // Número do Certificado Mercosul.
            endif

            if !empty(EVI->EVI_QTDCER) 
               cJson += if(!empty(cJson), ',', '') 
               cJson +=    '"quantidade":"' +  StrTransf( StrTransf( alltrim( EVI->EVI_QTDCER), ".","") , ",",".") + '"' // Quantidade da mercadoria na unidade estatística.
            endif

            cJson += '},'

         endif

         EVI->(dbSkip())
      end
      cJson := substr(alltrim(cJson), 1, len(alltrim(cJson))-1 )

   endif

   restArea(aArea)

return cJson

/*
Função     : getDocVincs
Objetivo   : Retorna os dados para estrutura "documentosVinculados"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getDocVincs(cLote, cHawb, cSeqDui)
   local aArea      := {}
   local cJson      := ''
   local cTipVin    := ''

   default cLote      := EV1->EV1_LOTE
   default cHawb      := SWV->WV_HAWB
   default cSeqDui    := SWV->WV_SEQDUIM

	/*
   {
      "tipo": "DUE",
      "numero": "19BR00000004936",
      "numeroItem": 10001
   }
   */

   dbSelectArea("EV6")
   aArea := EV6->(getArea())

   EV6->(dbSetOrder(3)) // EV6_FILIAL+EV6_LOTE+EV6_HAWB+EV6_SEQDUI
   if EV6->(dbSeek( xFilial("EV6") + cLote + cHawb + cSeqDui ))

      while EV6->(!eof()) .and. EV6->(&(IndexKey())) == xFilial("EV6") + cLote + cHawb + cSeqDui

         if !empty(EV6->EV6_TIPVIN) .or. !empty(EV6->EV6_DOCVIN)

            cJson += '{'

            if !empty(EV6->EV6_TIPVIN) // 1=DUIMP;2=DUE;3=DI;4=DE
               cTipVin := alltrim(EV6->EV6_TIPVIN)
               cJson +=    '"tipo":"' + if( cTipVin == "1",'DUIMP', if( cTipVin == "2", 'DUE', if( cTipVin == "3", 'DI', 'DE')))  + '"' // Tipo de declaração vinculada. [ DUIMP, DUE, DI, DE ]
            endif

            if !empty(EV6->EV6_DOCVIN)
               cJson += if(!empty(cJson), ',', '') 
               cJson +=    '"numero":"' + alltrim(EV6->EV6_DOCVIN) + '"' // Número da Declaração.
            endif

            // Campo não existe na estrutura da tabela EIK
            /*if val(EV6->EV6_SEQDUI) > 0
               cJson += if(!empty(cJson), ',', '') 
               cJson +=    '"numeroItem": ' +  cValToChar( val( EV6->EV6_SEQDUI ) ) + '' // Número do item/adição da declaração.
            endif*/

            cJson += '},'

         endif

         EV6->(dbSkip())
      end
      cJson := substr(alltrim(cJson), 1, len(alltrim(cJson))-1 )

   endif

   restArea(aArea)

return cJson

/*
Função     : getDadosCam
Objetivo   : Retorna os dados para estrutura "dadosCambiais"
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function getDadosCam(lFoundEV2)
   local cJson      := ''
   local cCobCamb   := ''

   default lFoundEV2 := .F.

   /*
   "coberturaCambial": {
      "codigo": "ATE_180_DIAS"
   },
   "numeroROF": "180A0A0A",
   "instituicaoFinanciadora": {
      "codigo": 99
   },
   "valorCoberturaCambial": "100.12",
   "motivoSemCobertura": {
      "codigo": 52
   }
   */

   if lFoundEV2

      if !empty(EV2->EV2_TIPCOB) // 1=180 DD;2=De 181 a 360 DD;3=Acima de 360 DD;4=Sem Cobertura
         cJson += '"coberturaCambial":{'
         cCobCamb := alltrim(EV2->EV2_TIPCOB)
         cJson +=    '"codigo":"' + if( cCobCamb == "1", 'ATE_180_DIAS', if( cCobCamb == "2", 'DE_180_ATE_360' , if( cCobCamb == "3", 'ACIMA_360' , 'SEM_COBERTURA' ) ) ) + '"' // Código da cobertura cambial. [ ATE_180_DIAS, DE_180_ATE_360, ACIMA_360, SEM_COBERTURA ]
         cJson += '}'
      endif

      if !empty(EV2->EV2_NRROF)
         cJson += if(!empty(cJson), ',', '')
         cJson += '"numeroROF":"' + alltrim(EV2->EV2_NRROF) + '"' // Número do ROF no BACEN.
      endif

      if !empty(EV2->EV2_INSTFI)
         cJson += if(!empty(cJson), ',', '')
         cJson += '"instituicaoFinanciadora":{'
         cJson +=    '"codigo":"' + alltrim(EV2->EV2_INSTFI) + '"' // Código da instituição financiadora.
         cJson += '}'
      endif

      if val(EV2->EV2_VL_FIN) > 0
         cJson += if(!empty(cJson), ',', '')
         cJson += '"valorCoberturaCambial": ' + StrTransf( StrTransf( alltrim( EV2->EV2_VL_FIN  ), ".","") , ",",".") + '' // Valor da cobertura cambial.
      endif

      if !empty(EV2->EV2_MOTIVO)
         cJson += if(!empty(cJson), ',', '')
         cJson += '"motivoSemCobertura":{'
         cJson +=    '"codigo":"' + alltrim(EV2->EV2_MOTIVO) + '"' // Código do Motivo para ausência de cobertura cambial.
         cJson += '}'
      endif

   endif

return cJson

/*
Função     : IntegVlrIts
Objetivo   : Realiza a integração da recuperação dos impostos por item da DUIMP
Parâmetro  : 
Retorno    : a primeira posição .T. se deve continuar a integração e .F. se não deve (erros de conexão ou de formatação do json inválido)
             a segunda posição .T. se deve continuar a integração de diagnóstico e registro e .F. se não deve (erros da camada de negócio)
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       :
*/
static function IntegVlrIts(oEasyJS, cUrlInteg, cHawb, cLote, nRecEV1, oLogView)
   local aRet       := {}
   local aItsDUIMP  := {}
   local nTotItens  := 0
   local aProcs     := {}
   local lRet       := .T.
   local cErros     := ""
   local aAreaEV1   := {}
   local aAreaEV2   := {}
   local aAreaEIJ   := {}
   local nCount     := 0
   local nSequen    := 0
   local jItemDuimp := nil
   local cItem      := ""
   local lAbortar   := .F.

   default cUrlInteg := AVGetUrl()
   default cHawb     := EV1->EV1_HAWB
   default cLote     := EV1->EV1_LOTE
   default nRecEV1   := EV1->(recno())

   aRet := {.F., .F.} // [1] erro de conexão, [2] erro da camada de negócio

   if DUIMP2310()

      aItsDUIMP := aClone(_aItsDUIMP)
      nTotItens := len(aItsDUIMP)
      lRet := .F.

      getLog(STR0037 + " " + EV1->EV1_DI_NUM + " " + STR0012 + " " + alltrim(EV1->EV1_VERSAO) + " - " + STR0038 + " " + aItsDUIMP[1][1] + " " + STR0039 + " " + aItsDUIMP[nTotItens][1], oLogView) // "Recuperando valores dos impostos calculados dos itens da Duimp" ## versão: ## "Itens da Duimp" ## "até"

      cErros := ""
      oEasyJS:runJSSync( "autenticar(retAdvpl,retAdvplChunk,retAdvplError);", {|x| lRet := DU101RetInt(x) }, {|x| lRet := .F., cErros := x } )

      if lRet

         dbSelectArea("EV1")
         aAreaEV1 := EV1->(getArea())
         EV1->(dbGoTo(nRecEV1))

         dbSelectArea("EV2")
         aAreaEV2 := EV2->(getArea())
         EV2->(dbSetOrder(3)) // EV2_FILIAL + EV2_LOTE + EV2_HAWB + EV2_SEQDUI

         dbSelectArea("EIJ")
         aAreaEIJ := EIJ->(getArea())
         EIJ->(dbSetOrder(3)) // EIJ_FILIAL + EIJ_HAWB + EIJ_IDWV

         aProcs := {}
         oEasyJS:runJS( "IntItemDUIMP(retAdvpl,retAdvplChunk,retAdvplError);", {|x| lRet := DU101RetInt(x,, oLogView, @aProcs) }, {|x| lAbortar := .T. , cErros := x } )

         if lRet

            cErros := ""
            nCount := 0
            for nSequen := 1 to len(aItsDUIMP)
               jItemDuimp := JsonObject():New()
               jItemDuimp['numDuimp'] := EV1->EV1_DI_NUM
               jItemDuimp['versaoDuimp'] := EV1->EV1_VERSAO
               jItemDuimp['seqDuimp'] := aItsDUIMP[nSequen][1]
               jItemDuimp['id'] := aItsDUIMP[nSequen][2]
               cItem := jItemDuimp:toJson()
               oEasyJS:runJS("addItemDUIMP(retAdvpl,'" + cItem + "')" , {|x| if( DU101RetInt(x), nCount += 1 , nil) }, {|x| cErros += x } )
            next

            cErros := ""
            oEasyJS:wait({|| lAbortar .or. ( nTotItens == len(aProcs) .and. nTotItens == nCount ) }, 0 ) 
            oEasyJS:runJS( "lEndFor = true;", , {|x| cErros := x } )

         endif

         restArea(aAreaEV1)
         restArea(aAreaEV2)
         restArea(aAreaEIJ)

      else
         getLog( STR0040 + " " + STR0041 + ": " + if(cErros == FAILED_FETCH, STR0013, cErros) , oLogView) // "Falha ao recuperar os impostos dos itens da DUIMP." ## "Erro" ## "Erro no certificado"

      endif

   endif

   if lAbortar
      getLog( STR0040 + " " + STR0041 + ": " + STR0060, oLogView) // "Falha ao recuperar os impostos dos itens da DUIMP." ## "Erro" ## "Não foi possivel consultar os tributos dos outros itens."
   endif

   aRet := {lRet, .F.}

return aRet

/*
Função     : DU101RetInt
Objetivo   : Função para tratamento do retorno da API de tributos do item da DUIMP
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       : 
*/
static function DU101RetInt(cRetJson, cErros, oLogView, aProcs)
   local lRet    := .F.
   local cRet    := ""
   local cSequen := ""
   local cMsgRet := ""

   default cRetJson   := ""
   default cErros     := ""
   default aProcs := {}

   cRet := Alltrim(lower(cRetJson))
   lRet := cRet == 'processou' .or. cRet == 'autenticou' .or. cRet == 'adicionou'
   if !lRet .and. !empty(cRetJson)
      cSequen := ""
      cMsgRet := ""
      PrcRetIts(oLogView, cRetJson, @cSequen, @cMsgRet )
      aAdd( aProcs, { cSequen, cMsgRet })
      lRet := .T.
   endif

return lRet

/*
Função     : PrcRetIts
Objetivo   : Função para tratamento do retorno da API de tributos do item da DUIMP
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       : 
*/
static function PrcRetIts(oLogView, cResposta, cSequen, cMsgRet)
   local lRetNeg    := .F.
   local cId        := ""
   local jResposta  := nil
   local nRecEIJ    := 0
   local nRecEV2    := 0
   local cError     := ""
   local jRetorno   := nil
   local jItemDUIMP := nil

   default cResposta  := ""
   default cSequen    := ""
   default cMsgRet    := ""

   cMsgRet := STR0042 // "Falha no retorno."
   if !empty(cResposta)
      jResposta := JsonObject():new()
      cMsgRet += if( valtype(cResposta) == "C", " " + STR0043 + ": " + cResposta, "") // "Retorno"
      if valtype(jResposta:fromJson(cResposta)) == "U"

         cError := ""
         jItemDUIMP := jResposta["jItemDUIMP"]
         if valtype(jItemDUIMP) == "J"
            cId := jItemDUIMP["id"]
            cSequen := jItemDUIMP["seqDuimp"]
         endif
         jRetorno := jResposta["ret"]

         nRecEIJ := 0
         if !empty(cId) .and. EIJ->(dbSeek( xFilial("EIJ") + EV1->EV1_HAWB + cId )) 
            nRecEIJ := EIJ->(recno())
         endif

         nRecEV2 := 0
         if !empty(cSequen) .and. EV2->(dbSeek( xFilial("EV2") + EV1->EV1_LOTE + EV1->EV1_HAWB + cSequen ))
            nRecEV2 := EV2->(recno())
         endif

         lRetNeg := PrcRetItem(nRecEIJ, nRecEV2, @cError, jRetorno)
         cMsgRet := if( lRetNeg , STR0044 + ": " + cSequen + ". ", STR0045 + ": " + cSequen + ". " + STR0041 + ": " + cError ) // "Realizado com sucesso a consulta dos tributos da sequência do item" ##  "Inconsistência ao consultar os tributos do item" ## "Erro"

      endif
      getLog( cMsgRet , oLogView)
      fwfreeobj(jResposta)
   endif

return lRetNeg

/*
Função     : PrcRetItem
Objetivo   : Função para tratamento do retorno da API de tributos do item da DUIMP
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       : 
*/
static function PrcRetItem( nRecEIJ, nRecEV2, cError, jResposta)
   local lRet       := .F.
   local aErros     := {}
   local nError     := 0
   local aTributos  := {}
   local nTributos  := 0
   local cTipo      := ""
   local jValores   := nil
   local jMemCal    := nil
   local aCposEIJ   := {}
   local aCposEV2   := {}
   local aValores   := {}

   default nRecEIJ   := 0
   default nRecEV2   := 0
   default cError    := ""

   if jResposta:HasProperty("errors")

      aErros := if(valtype(jResposta["errors"]) == "J", {jResposta["errors"]}, jResposta["errors"])
      for nError := 1 to len(aErros)
         if valtype(aErros[nError]) == "J" .and. aErros[nError]:HasProperty("code") .and. aErros[nError]:HasProperty("message")
            cError += "'" + alltrim(aErros[nError]["code"]) + "' - " + alltrim(aErros[nError]["message"])
         endif
      next
      cError := if(empty(cError), STR0046, cError) // "Erro indefinido."
      aCposEIJ := {}
      aVlrEIJ := {}
      aValores := {}
      aAdd( aCposEIJ, "EIJ_OBSTRB" )
      aAdd( aCposEV2, "EV2_OBSTRB" )
      aAdd( aValores, cError )

   elseif jResposta:HasProperty("tributosCalculados")

      aTributos := if(valtype(jResposta["tributosCalculados"]) == "J", { jResposta["tributosCalculados"]}, jResposta["tributosCalculados"])
      aCposEIJ := {}
      aVlrEIJ := {}
      aValores := {}
      aMemCal := {}
      for nTributos := 1 to len(aTributos)

         cTipo := ""
         jValores := nil
         jMemCal := nil

         if valtype(aTributos[nTributos]) == "J"
            if aTributos[nTributos]:HasProperty("tipo")
               cTipo := alltrim(aTributos[nTributos]["tipo"])
               lRet := lRet .or. cTipo $ "II|IPI|PIS|COFINS"
            endif
            if aTributos[nTributos]:HasProperty("valoresBRL")
               jValores := aTributos[nTributos]["valoresBRL"]
            endif
            if aTributos[nTributos]:HasProperty("memoriaCalculo")
               jMemCal := aTributos[nTributos]["memoriaCalculo"]
            endif
         endif

         if ValType(jMemCal) == "J" .and. cTipo $ "II|IPI|PIS|COFINS"
            aAdd( aMemCal, { cTipo, jMemCal})
         endif

         if ValType(jValores) == "J"
            do case
               case cTipo == "II"
                  aAdd( aCposEIJ, "EIJ_VLCII" ) // Vlr Calculado II
                  aAdd( aCposEIJ, "EIJ_VRDII" ) // Vlr Reduzir II
                  aAdd( aCposEIJ, "EIJ_VLDII" ) // Vlr Devido II
                  aAdd( aCposEIJ, "EIJ_VLSII" ) // Vlr Suspenso II
                  aAdd( aCposEIJ, "EIJ_VRCII" ) // Vlr Recolher II

                  aAdd( aCposEV2, "EV2_VLRCII" ) // Vlr Calculado II
                  aAdd( aCposEV2, "EV2_VRDII"  ) // Vlr Reduzir II
                  aAdd( aCposEV2, "EV2_VLDII"  ) // Vlr Devido II
                  aAdd( aCposEV2, "EV2_VLSII"  ) // Vlr Suspenso II
                  aAdd( aCposEV2, "EV2_VRCII"  ) // Vlr Recolher II

               case cTipo == "IPI"
                  aAdd( aCposEIJ, "EIJ_VLCIPI" ) // Vlr Calculado IPI
                  aAdd( aCposEIJ, "EIJ_VRDIPI" ) // Vlr Reduzir IPI
                  aAdd( aCposEIJ, "EIJ_VDIPI"  ) // Vlr Devido IPI
                  aAdd( aCposEIJ, "EIJ_VLSIPI" ) // Vlr Suspenso IPI
                  aAdd( aCposEIJ, "EIJ_VRCIPI" ) // Vlr Recolher IPI

                  aAdd( aCposEV2, "EV2_VLCIPI" ) // Vlr Calculado IPI
                  aAdd( aCposEV2, "EV2_VRDIPI" ) // Vlr Reduzir IPI
                  aAdd( aCposEV2, "EV2_VDIPI"  ) // Vlr Devido IPI
                  aAdd( aCposEV2, "EV2_VLSIPI" ) // Vlr Suspenso IPI
                  aAdd( aCposEV2, "EV2_VRCIPI" ) // Vlr Recolher IPI

               case cTipo == "PIS"
                  aAdd( aCposEIJ, "EIJ_VLCPIS" ) // Vlr Calculado PIS
                  aAdd( aCposEIJ, "EIJ_VRDPIS" ) // Vlr Reduzir PIS
                  aAdd( aCposEIJ, "EIJ_VDEPIS" ) // Vlr Devido PIS
                  aAdd( aCposEIJ, "EIJ_VLSPIS" ) // Vlr Suspenso PIS
                  aAdd( aCposEIJ, "EIJ_VRCPIS" ) // Vlr Recolher PIS

                  aAdd( aCposEV2, "EV2_VLCPIS" ) // Vlr Calculado PIS
                  aAdd( aCposEV2, "EV2_VRDPIS" ) // Vlr Reduzir PIS
                  aAdd( aCposEV2, "EV2_VDEPIS" ) // Vlr Devido PIS
                  aAdd( aCposEV2, "EV2_VLSPIS" ) // Vlr Suspenso PIS
                  aAdd( aCposEV2, "EV2_VRCPIS" ) // Vlr Recolher PIS

               case cTipo == "COFINS"
                  aAdd( aCposEIJ, "EIJ_VLCCOF" ) // Vlr Calculado COFINS
                  aAdd( aCposEIJ, "EIJ_VRDCOF" ) // Vlr Reduzir COFINS
                  aAdd( aCposEIJ, "EIJ_VDECOF" ) // Vlr Devido COFINS
                  aAdd( aCposEIJ, "EIJ_VLSCOF" ) // Vlr Suspenso COFINS
                  aAdd( aCposEIJ, "EIJ_VRCCOF" ) // Vlr Recolher COFINS

                  aAdd( aCposEV2, "EV2_VLCCOF" ) // Vlr Calculado COFINS
                  aAdd( aCposEV2, "EV2_VRDCOF" ) // Vlr Reduzir COFINS
                  aAdd( aCposEV2, "EV2_VDECOF" ) // Vlr Devido COFINS
                  aAdd( aCposEV2, "EV2_VLSCOF" ) // Vlr Suspenso COFINS
                  aAdd( aCposEV2, "EV2_VRCCOF" ) // Vlr Recolher COFINS

            endcase

            if cTipo $ "II|IPI|PIS|COFINS"
               aAdd( aValores, if( jValores:HasProperty("calculado"), jValores["calculado"], 0) )
               aAdd( aValores, if( jValores:HasProperty("aReduzir") , jValores["aReduzir"] , 0) )
               aAdd( aValores, if( jValores:HasProperty("devido")   , jValores["devido"]   , 0) )
               aAdd( aValores, if( jValores:HasProperty("suspenso") , jValores["suspenso"] , 0) )
               aAdd( aValores, if( jValores:HasProperty("aRecolher"), jValores["aRecolher"], 0) )
            endif

         endif

      next

      if len(aMemCal) > 0
         aAdd( aCposEIJ, "EIJ_OBSTRB" )
         aAdd( aCposEV2, "EV2_OBSTRB" )
         aAdd( aValores, FormatVlCal(aMemCal) )
      endif

   endif

   if len(aValores) > 0
      if nRecEIJ > 0
         EIJ->(dbGoTo(nRecEIJ))
         AtuReg(aCposEIJ,aValores,"EIJ")
      endif

      if nRecEV2 > 0 
         EV2->(dbGoTo(nRecEV2))
         AtuReg(aCposEV2,aValores,"EV2")
      endif
   endif

   cError := if( !lRet .and. empty(cError) .and. !jResposta:HasProperty("tributosCalculados"), STR0047, cError) // "Erro no retorno."
   fwfreeobj(jValores)
   fwfreeobj(jMemCal)

return lRet

/*
Função     : FormatVlCal
Objetivo   : Função para formatação do objeto memoriaCalculo
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       : 
*/
static function FormatVlCal(aDados)
   local cRet     := ""
   local nDados   := 0
   local oJsonTrb := nil

   /*
   "codigoFundamentoLegalNormal" - Código do fundamento legal do regime tributário de importação utilizado na declaração
   "baseCalculoBRL" - Valor da base de cálculo em R$ (Reais).
   "baseCalculoEspecificaBRL" - Valor da base de cálculo específica em R$ (Reais).
   "baseCalculoReduzidaBRL" - Valor da base de cálculo reduzida em R$ (Reais).
   "percentualReducaoBaseCalculo" - Percentual de redução da base de cálculo.
   "tipoAliquota" - Tipo de alíquota do tributo.
   "percentualReducaoAliquotaReduzida" - Percentual de redução da alíquota reduzida (%).
   "valorAliquota" - Valor da alíquota (%).
   "valorAliquotaEspecifica" - Valor da alíquota específica (%).
   "valorAliquotaReduzida" - Valor da alíquota reduzida (%).
   "normal" - Valor normal em R$ (Reais).
   "tributado" - Indicador de tributação
   */

   for nDados := 1 to len(aDados)
      oJsonTrb := aDados[nDados][2]
      if Valtype(oJsonTrb) = "J"
         cRet += "- Imposto '" + aDados[nDados][1] + "'" + CRLF
         if oJsonTrb:HasProperty("codigoFundamentoLegalNormal")
            cRet += "   " + STR0048 + ": " + cValToChar(oJsonTrb["codigoFundamentoLegalNormal"]) + CRLF // "Código do fundamento legal do regime tributário"
         endif
         if oJsonTrb:HasProperty("baseCalculoBRL")
            cRet += "   " + STR0049 + ": " + cValToChar(oJsonTrb["baseCalculoBRL"]) + CRLF // "Valor da base de cálculo em R$ (Reais)"
         endif
         if oJsonTrb:HasProperty("baseCalculoEspecificaBRL")
            cRet += "   " + STR0050 + ": " + cValToChar(oJsonTrb["baseCalculoEspecificaBRL"]) + CRLF // "Valor da base de cálculo específica em R$ (Reais)"
         endif
         if oJsonTrb:HasProperty("baseCalculoReduzidaBRL")
            cRet += "   " + STR0051 + ": " + cValToChar(oJsonTrb["baseCalculoReduzidaBRL"]) + CRLF // "Valor da base de cálculo reduzida em R$ (Reais)"
         endif
         if oJsonTrb:HasProperty("percentualReducaoBaseCalculo")
            cRet += "   " + STR0052 + ": " + cValToChar(oJsonTrb["percentualReducaoBaseCalculo"]) + CRLF //  "Percentual de redução da base de cálculo"
         endif
         if oJsonTrb:HasProperty("tipoAliquota")
            cRet += "   " + STR0053 + ": " + oJsonTrb["tipoAliquota"] + CRLF //  "Tipo de alíquota do tributo"
         endif
         if oJsonTrb:HasProperty("percentualReducaoAliquotaReduzida")
            cRet += "   " + STR0054 + ": " + cValToChar(oJsonTrb["percentualReducaoAliquotaReduzida"]) + CRLF // "Percentual de redução da alíquota reduzida (%)"
         endif
         if oJsonTrb:HasProperty("valorAliquota")
            cRet += "   " + STR0055 + ": " + cValToChar(oJsonTrb["valorAliquota"]) + CRLF //  "Valor da alíquota (%)"
         endif
         if oJsonTrb:HasProperty("valorAliquotaEspecifica")
            cRet += "   " + STR0056 + ": " + cValToChar(oJsonTrb["valorAliquotaEspecifica"]) + CRLF // "Valor da alíquota específica (%)"
         endif
         if oJsonTrb:HasProperty("valorAliquotaReduzida")
            cRet += "   " + STR0057 + ": " + cValToChar(oJsonTrb["valorAliquotaReduzida"]) + CRLF // "Valor da alíquota reduzida (%)"
         endif
         if oJsonTrb:HasProperty("normal")
            cRet += "   " + STR0058 + ": " + cValToChar(oJsonTrb["normal"]) + CRLF // "Valor normal em R$ (Reais)"
         endif
         if oJsonTrb:HasProperty("tributado")
            cRet += "   " + STR0059 + ": " + if( oJsonTrb["tributado"], "Verdadeiro", "Falso") + CRLF // "Indicador de tributação"
         endif
      endif
   next

return cRet

/*
Função     : DU101Lib
Objetivo   : Funções do javascript
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       : 
*/
static function DU101Lib(cPUAuth,cUrl)

   begincontent var cVar
      var XCSRFToken = '';
      var SetToken = '';
      var aItemDUIMPs = [];
      var lEndFor = false;

      function autenticar(retAdvpl,retAdvplChunk,retAdvplError){
         fetch( '%Exp:cPUAuth%', {
            method: 'POST',
            mode: 'cors',
            headers: {
               'Content-Type': 'application/json',
               'Role-Type': 'IMPEXP',
            },
         })
         .then( res => {
            if (res.status == '200') {
               XCSRFToken = res.headers.get('X-CSRF-Token');
               SetToken = res.headers.get('Set-Token');
               retAdvpl('autenticou');
               return res.json();
            }else{
               retAdvplError( res.json() );
            }
         })
         .catch((e) => { retAdvplError(e) });
      }

      function IntItemDUIMP(retAdvpl,retAdvplChunk,retAdvplError){
         if (XCSRFToken && SetToken){
            var cProcItemDUIMP = () => {
               var cItemDUIMP = aItemDUIMPs.shift();
               if(cItemDUIMP){
                  var jItemDUIMP = JSON.parse(cItemDUIMP);
                  var cDuimp = jItemDUIMP.numDuimp;
                  var cVersao = jItemDUIMP.versaoDuimp;
                  var cSeqDUIMP = jItemDUIMP.seqDuimp;
                  fetch( '%Exp:cUrl%/duimp-api/api/ext/duimp/'+cDuimp+'/'+cVersao+'/itens/'+cSeqDUIMP+'/valores-calculados', {
                     method: 'GET',
                     mode: 'cors',                     
                     headers: { 
                        'Content-Type': 'application/json',
                        "Authorization": SetToken,
                        "X-CSRF-Token":  XCSRFToken,
                     }
                  })
                  .then( (res) => res.json() )
                  .then( (json) => { retAdvplChunk({jItemDUIMP, ret:json}) ; cProcItemDUIMP() })
                  .catch( (e)  => { retAdvplError(e) });
               } else {
                     if (lEndFor) {
                        retAdvpl('processou');
                     } else {
                        setTimeout(cProcItemDUIMP,100);
                     }
               }
            }
            cProcItemDUIMP();
         } else {
            retAdvplError("falha de autenticação.");
         }
      }     

      function addItemDUIMP(retAdvpl,cItem){
         aItemDUIMPs.push(cItem);
         retAdvpl('adicionou');
      }

   endcontent

return cVar

/*
Função     : DUIMP2310
Objetivo   : Função para validação do dicionario de dados para DUIMP release 12.1.2310
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       : 
*/
static function DUIMP2310()
   local lRet := .F.

   if _DIC_22_4 == nil
      _DIC_22_4 := AvFlags("DUIMP_12.1.2310-22.4")
   endif

   lRet := _DIC_22_4

return lRet
