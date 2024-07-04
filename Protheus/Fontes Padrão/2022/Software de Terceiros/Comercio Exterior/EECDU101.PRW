
#INCLUDE 'TOTVS.CH'
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'topconn.ch'
#INCLUDE 'AVERAGE.CH'
#Include 'EECDU101.CH'
#INCLUDE "EEC.CH"

/*
Funcao      : EECADU101()
Parametros  :
Retorno     : Nil
Objetivos   : Executar FwMarkBrowse de Integração de Status da DUE
Autor       : Ramon/Nilson
Data/Hora   : 29/09/20
Obs.        :
*/
*------------------
Function EECDU101()
   *------------------
   Local cFiltro   := ""
   Local oDlgMrk

   Private aRotina    := MenuDef()
   Private oProcDUE  := tHashMap():New()

   // Instanciamento do classe
   oMark := FWMarkBrowse():New()
   oMark:SetOwner( oDlgMrk )

   // Definição da tabela a ser utilizada
   oMark:SetAlias('EEC')
   EEC->(DBSetOrder(1))

   //Configuração de opções
   oMark:SetMenuDef( "" )
   oMark:SetWalkThru( .F. )
   oMark:SetAmbiente( .F. )

   // Define o campo que sera utilizado para a marcação
   bMark       := {|oMark|SetMark(oMark)}
   bDoubleClic := {|oMark|MarkOne(oMark)}
   bHeaderClic := {|oMark|MarkAll(oMark),oMark:Refresh(.T.)}
   oMark:AddMarkColumns(bMark,bDoubleClic,bHeaderClic)

   //Adicionar o processo posicionado na tabela EEC como marcado, caso este possua DUE (sem data de averbação)
   AutoMark(oMark)
   oMark:Refresh(.T.)

   // Define filtro default para seleção
   cFiltro := "EEC_NRODUE <> ' ' "
   oMark:AddFilter(STR0008, 'Empty(EEC->EEC_DUEAVR)', .F. , .T. ) //#'Processos sem averbação'
   oMark:SetFilterDefault(cFiltro)

   // Ativacao da classe
   oMark:Activate()

Return

/*
Funcao      : MenuDef()
Parametros  :
Retorno     : Nil
Objetivos   : Menu Funcional
Autor       :
Data/Hora   : 29/09/20
Obs.        :
*/
*------------------
Static Function MenuDef()
   *------------------

   Local aRot := {}

   ADD OPTION aRot TITLE STR0009 ACTION 'DU101Cons()' OPERATION 4 ACCESS 0 //OPERATION X   //#"Consultar status"

Return aRot

/*
Funcao      : EECADU101()
Parametros  :
Retorno     : .T.
Objetivos   : Executar FwMarkBrowse de Integração de Status da DUE - Recebera retorno da consulta de status da integração junto ao portal
Autor       :
Data/Hora   : 29/09/20
Obs.        :
*/
*------------------
Function DU101Cons()
   *------------------
   Local aAux := {}
   Local aListDUE := {}
   Local i

   oProcDUE:List(@aAux)

   For i := 1 To Len(aAux)
      aAdd( aListDUE, { aAux[i][1] , aAux[i][2][1] , aAux[i][2][2] } )
   Next i

   //Orderna o array por código do processo
   aSort(aListDUE,,,{|x,y| x[3] < y[3]   })

   //Chama a integração de status
   aProcessos := DU101IntSt(aListDUE)

   //Garantir que o fwmarkbrowse deixa marcado apenas os processos que retornaram da integração

Return .T.

/*
Função   : SetMark
Autor    : Nilson César
Data     : 29/09/2020
Objetivo : Retorna marca de registro conforme avaliação
*/
*-----------------------------
static function SetMark(oMark)
   *-----------------------------
   Local cRet
   Local hashChvDUE := EEC->( RECNO() )

   aBuffDUE := {}
   If !oProcDUE:Get(hashChvDUE, @aBuffDUE)
      cRet := 'LBNO'
   Else
      cRet := 'LBOK'
   EndIf

Return cRet

/*
Função   : AutoMark
Autor    : Nilson César
Data     : 29/09/2020
Objetivo : Marca registros automaticamente conforme condição
*/
*------------------------------
static function AutoMark(oMark)
   *------------------------------
   Local lRet := .T.

   IF !Empty(EEC->EEC_NRODUE) .AND. Empty(EEC->EEC_DUEAVR)
      MarkOne(oMark)
   ENDIF

Return lRet

/*
Função   : MarkOne
Autor    : Nilson César
Data     : 29/09/2020
Objetivo : Habilita/Desabilita registro para marcação conforme condição
           Executa a ação do "DoubleClic"
*/
*------------------------------
static function MarkOne(oMark)
   *------------------------------
   Local lRet := .F.
   Local hashChvDUE := EEC->( Recno() )

   aBuffDUE := {}
   If !oProcDUE:Get(hashChvDUE, @aBuffDUE)
      oProcDUE:Set( hashChvDUE , { EEC->EEC_NRODUE , EEC->EEC_PREEMB } )
      lRet := .T.
   Else
      oProcDUE:Del(hashChvDUE)
      lRet := .F.
   EndIf

return lRet//cRet

/*
Função   : MarkAll
Autor    : Nilson César
Data     : 29/09/2020
Objetivo : Habilita/Desabilita registros para marcação conforme condição
           Executa a ação do "HeaderClic"
*/
*------------------------------
static function MarkAll(oMark)
   Local lRet := .F.
   Local aListDUE := {}
   oProcDUE:List(@aListDUE)
   If Empty(aListDUE)
      EEC->(DbGoTop())
      Do While EEC->(!Eof())
         oProcDUE:Set( EEC->( Recno() ) ,  { EEC->EEC_NRODUE , EEC->EEC_PREEMB } )
         EEC->(DBSkip())
      EndDo
      lRet := .T.
   Else
      oProcDUE:Clean()
      lRet := .F.
   EndIf

return lRet

/*
Função   : DU101GrvEKK
Autor    : Nilson César
Data     : 29/09/2020
Objetivo : Gravar os registros de detalhes de histórico da DUE (Consulta DUE)
*/
Static Function DU101GrvEKK( aDataRet )
   Local i
   Local lRet := .F.
   Local cSeqEKK := '000'
   Local cSeqEK0, lNewReg, cLastStatu,nPosAvbSta

   //Ordena por Data + Hora Evento
   aSort( aDataRet[4],,,{|x,y| DToS(x[1][1]) + x[1][2] < DToS(y[1][1]) + y[1][2] } )

   EEC->( DbGoTo(aDataRet[1]) )
   //busca sequencia do histórico (Tabela EK0)
   cSeqEK0    := DU101SqEK0(EEC->EEC_PREEMB)

   Begin Transaction
      For i:=1 To Len(aDataRet[4])

         cSeqEKK := Soma1(cSeqEKK)

         //Define se atualiza uma sequência existente ou grava uma nova sequência
         If( EKK->(IndexOrd() ) <> 1, EKK->(DbSetOrder(1) ) , )
         lNewReg := !EKK->(DbSeek( xFilial() + EEC->EEC_PREEMB + cSeqEK0 + cSeqEKK  ))

         // Grava detalhe do histórico
         EKK->(Reclock("EKK",lNewReg))
         EKK->EKK_FILIAL   := xFilial("EKK")
         EKK->EKK_PROCES   := EEC->EEC_PREEMB
         EKK->EKK_NUMSEQ   := cSeqEK0
         EKK->EKK_SEQSTA   := cSeqEKK
         EKK->EKK_STATUS   := Upper(Alltrim(aDataRet[4][i][6]))
         EKK->EKK_DATAST   := aDataRet[4][i][1][1]
         EKK->EKK_HORAST   := aDataRet[4][i][1][2]
         EKK->EKK_DETAST   := aDataRet[4][i][5] + ENTER + aDataRet[4][i][2] + ENTER + aDataRet[4][i][3] + ENTER + aDataRet[4][i][4]

         EKK->( msunlock() )

         If i == Len(aDataRet[4])
            cLastStatu := Upper(Alltrim(aDataRet[4][i][6]))
         EndIf

      Next i

      EEC->(RecLock("EEC",.F.))
      EEC->EEC_STPTUN := UPPER( Alltrim( cLastStatu ) )
      //Caso haja o evento de averbação, atualiza a data de averbação do processo.
      If ( nPosAvbSta := aScan(aDataRet[4],{|x| Upper(Alltrim(x[6])) == "AVERBAÇÃO"   }) ) > 0
         EEC->EEC_DUEAVR := aDataRet[4][nPosAvbSta][1][1]
      EndIf
      EEC->(MsUnlock())

      If( !lRet, lRet := .T. , )

      //Deleta as sequências da EKK que não vieram na integração
      cSeqEKK := Soma1(cSeqEKK)
      Do While EKK->(DbSeek( xFilial("EKK") + EEC->EEC_PREEMB + cSeqEK0 + cSeqEKK  ))
         EKK->(RecLock("EKK",.F.))
         EKK->(DbDelete())
         EKK->(MsUnlock())
         cSeqEKK := Soma1(cSeqEKK)
      EndDo

   End Transaction

Return lRet

/*
Função   : LastSeqEK
Autor    : Nilson César
Data     : 29/09/2020
Objetivo : Verificar e retornar a última sequência da tabela EK0
           (Ultima transmissão da DUE)
*/
Function DU101SqEK0(cProc)
   Local aOrd     := {}
   Local cSeq     := "000"
   Local cQry     := ""
   Local cAlias   := GetNextAlias()
   Local nOldArea := Select()

   If TcSrvType()<>"AS/400"
      aOrd := SaveOrd("EK0")
      cQry += "SELECT MAX( EK0_NUMSEQ ) EK0_NUMSEQ FROM "+RetSQLName("EK0")+" WHERE D_E_L_E_T_ <> '*'"
      cQry += " AND EK0_FILIAL = '"+xFilial("EK0")+"' AND EK0_PROCES = '"+cProc+"' "
      DBUseArea(.T., "TOPCONN" , TCGenQry(,, cQry), cAlias , .T., .T.)
      If (cAlias)->(!EOF()) .And. !Empty( (cAlias)->EK0_NUMSEQ )
         cSeq :=  (cAlias)->EK0_NUMSEQ
      EndIf
   else
      EK0->( DbSetOrder(1) , AvSeekLast( xFilial() + cProc  ) )
      If EK0->(!Eof())
         cSeq := EK0->EK0_NUMSEQ
      EndIf
   endif

   If( !Empty(aOrd), RestOrd(aOrd,.T.), )
   If( nOldArea > 0 , DbSelectArea(nOldArea) , )

Return cSeq

/*
Funcao      : DU101ExcHs
Parametros  :
Retorno     : aProcessos
Objetivos   : Função que retira processo DUE ja executado do HashMap
Autor       :
Data/Hora   : 06/10/2020
Obs.        :
*/
*----------------------------------------------------
Function DU101ExcHs(oProcDUE, aProcessos , nPosaProc)
   *----------------------------------------------------
   Local aBuffDUE := {}

   If oProcDUE:Get(aProcessos[1][1], @aBuffDUE)
      oProcDUE:Del(aProcessos[1][1])
   EndIf
   If ValType( aProcessos[nPosaProc] ) == "A"
      aDel(aProcessos,nPosaProc)
      aSize(aProcessos,Len(aProcessos)-1)
   EndIf

Return

/*
Funcao      : DU101IntSt
Parametros  :
Retorno     : aProcessos -
Objetivos   : Função que efetua a consulta de status da Declaração Única de Exportação junto ao Portal
Autor       :
Data/Hora   : 29/09/20
Obs.        :
*/
*------------------
Function DU101IntSt(aProcessos)
   *------------------
   Local cURLTest    := EasyGParam("MV_EIC0073",.F.,"https://val.portalunico.siscomex.gov.br") // Teste integrador localhost:3001 - val.portalunico.siscomex.gov.br
   Local cURLProd    := EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br") // Produção - portalunico.siscomex.gov.br
   Local lIntgProd   := EasyGParam("MV_EIC0074",.F.,"1") == "1"
   Local cErrosDUE   := ""
   Local lRet        := .T.
   Local lEasyProgr  := .F.
   Local cPortal  := ""
   Local oProg

   Default aProcessos  := {}

   Private lProcessou := .F. //ira mudar para True assim que processar tudo ou se o usuario cancelar e ja tiver consultado ao menos um Status
   Private lPrimeira  := .T.


   Begin sequence

      If !lIntgProd
         If ! Msgnoyes( STR0001 + ENTER ; // "O sistema está configurado para integração com a Base de Testes do Portal Único."
               + STR0002 + ENTER ; // "Qualquer integração para a Base de Testes não terá qualquer efeito legal e não deve ser utilizada em um ambiente de produção."
               + STR0003 + ENTER ; // "Para integrar com a Base Oficial (Produção) do Portal Único, altere o parâmetro 'MV_EIC0074' para 1."
               + STR0004 , STR0005 ) // "Deseja Prosseguir?" // "Atenção"
            lRet := .F.
            break
         Else
            cPortal := cURLTest
         Endif
      Else
         cPortal := cURLProd
      EndIf

      lEasyProgr  := Len(aProcessos) > 3
      If lEasyProgr
         oProg   := EasyProgress():New(.T.)
         oProg:SetProcess({|| lRet := DU101Port(aProcessos,cPortal,@cErrosDUE,@oProg)},STR0007) //'Processando Consulta de Integração de Status DUE...'
         oProg:Init()
      Elseif Len(aProcessos) <> 0
         MsAguarde({|| lRet := DU101Port(aProcessos,cPortal,@cErrosDUE,@oProg)},STR0007, STR0016,.T.) //'Processando Consulta de Integração de Status DUE...'##"Processando Consulta"
      Else
         EasyHelp(STR0023) //"Marque ao menos um processo de embarque"
         lRet := .F.
      EndIf

      If lRet
         MsgInfo(STR0019,STR0018) //"Integrado com sucesso" //"Aviso"
      Else
         If !Empty(cErrosDUE)
            EECView(cErrosDUE)
         ElseIf Valtype(oProg) == 'O' .And. oProg:lAbort
            MsgInfo(STR0017,STR0018) //"Cancelado pelo usuário" //"Aviso"
         EndIf
      Endif

   End Sequence

Return aProcessos

/*/{Protheus.doc} DU101Port
   Função que realiza a Consulta de Status da Integração com o Portal para cada item do array aProcessos
   @author Ramon Prado
   @since 30/09/2020
   @version 1
/*/
Function DU101Port(aProcessos,cPortal,cErrosDUE,oProg)
   Local nQtdInt  := Len(aProcessos)
   Local lRet     := .T.
   Local cErros   := ""
   Local cPUAuth  := cPortal+"/portal/api/autenticar"
   Local aBuffProc:= {}

   Private oEasyJS
   Private lErroGrave := .F.

   Begin Sequence

      oEasyJS := EasyJS():New()
      oEasyJS:cUrl := cPUAuth

      oEasyJS:AddLib( DU101Auth(cPUAuth, cPortal, aProcessos))

      oEasyJS:SetTimeout(120)

      If oEasyJS:Activate(.T.)
         oEasyJS:SetTimeout(0)

         oEasyJS:runJSSync( "autenticar(retAdvpl,retAdvplChunk,retAdvplError);" ,{|x| lRet := DU101BUFFER(x, @cErrosDUE,aBuffProc,aProcessos,@oProg) }, {|x|   lErroGrave := .T., cErros := x } ) //Executando um javascript de forma Síncrona

         if lRet .and. ! lErroGrave
            If Valtype(oProg) == 'O'
               oProg:SetRegua(nQtdInt)
               oEasyJS:runJS( "IntStatus(retAdvpl,retAdvplChunk,retAdvplError);" ,{|x| lRet := DU101BUFFER(x, @cErrosDUE,aBuffProc,aProcessos,@oProg) }, {|x|  lErroGrave := .T., cErros := x } ) //Executando um javascript de forma Síncrona
            Else
               oEasyJS:runJSSync( "IntStatus(retAdvpl,retAdvplChunk,retAdvplError);" ,{|x| lRet := DU101BUFFER(x, @cErrosDUE,aBuffProc,aProcessos,@oProg) }, {|x|   lErroGrave := .T., cErros := x } ) //Executando um javascript de forma Síncrona
            EndIf
         Else
            cErros += ENTER + STR0024 //"Não foi possível autenticar no Portal Único Siscomex, verifique o endereço nos parâmetros e verifique se o portal está no ar."
            lRet := .F.
         EndIf
      Else
         EasyHelp(STR0020) //"Falha na integração"
         lRet := .F.
      EndIf

      If Valtype(oProg) == 'O'
         lRet := DU101DescB(aBuffProc,@cErrosDUE,aProcessos,oProg)
      EndIf

      If !Empty(cErros)
         If Alltrim(cErros) == STR0021 //"Failed to fetch"
            EasyHelp(STR0022) //"Falha de conexão com o Portal Siscomex"
            lRet := .F.
         Else
            EasyHelp(cErros) //retorno falha grave
            lRet := .F.
         EndIf
      EndIf

   End Sequence

Return lRet

/*/{Protheus.doc} DU101DescB
   Função que descarrega(chama a função que processa o retorno do JSON do Portal Siscomex) o Buffer
   @author Ramon/Nilson
   @since 30/09/2020
   @version 1
/*/
Function DU101DescB(aBuffProc,cErrosDUE,aProcessos, oProg)
   Local lRet           := .T.
   Local nCont          := 1

   //Processa o JSON de Retorno para salvar o conteudo das tags e chamar a gravação da tabela de status da integração(EKK)
   While (Len(aBuffProc) > 0 .Or. !lProcessou) .And. !lErroGrave
      If Len(aBuffProc) > 0
         If Valtype(oProg) == 'O'
            oProg:IncRegua()
         Else
            MsProcTxt("Processando registro " + cValToChar(nCont) + " de " + cValToChar(Len(aBuffProc)) + "...")
         EndIf
         DU101PROCJ(aBuffProc[1],@cErrosDUE,aProcessos)
         aDel(aBuffProc, 1)
         aSize(aBuffProc,Len(aBuffProc)-1)
      Else
         sleep(100) //milisegundos
      EndIf
      If Valtype(oProg) == 'O'
         oProg:Refresh()
      EndIf
      If Valtype(oProg) == 'O'  .And. oProg:lAbort //houve cancelamento do processo
         lRet := .F.
         //Avisar o Javascript
         oEasyJS:runJS("lFim = true")
         exit
      EndIf
      nCont++
   EndDo

   IF !Empty(cErrosDUE)
      lRet := .F.
   EndIf

Return lRet

/*/{Protheus.doc} DU101BUFFER
   Buffer para processamento
   @author Ramon/Nilson
   @since 02/10/2020
   @version 1
/*/
Function DU101BUFFER(cRetJson, cErrosDUE, aBuffProc, aProcessos, oProg)
   Local lRet := .F.

   If Alltrim(cRetJson) == 'Processou'
      lProcessou := .T.
      lRet := .T.
   elseIf Alltrim(cRetJson) == 'S'
      lRet := .T.
   Else
      aAdd(aBuffProc, cRetJson)
   Endif

   If Valtype(oProg) <> 'O' .And. !IsInCallStack("DU101DescB") .And. lProcessou //uso do msaguarde tera descarga de buffer diferente do EasyProgress
      lRet := DU101DescB(aBuffProc,@cErrosDUE,aProcessos,oProg)
   EndIf

Return lRet

/*/{Protheus.doc} DU101PROCJ
   Processa o retorno(Json) da consulta de status da DUE
   @author Ramon/Nilson
   @since 02/10/2020
   @version 1
/*/
Function DU101PROCJ(cRetJson,cErrosDUE,aProcessos)
   Local nX := 1
   Local nPos := 0
   Local cStatus     := ""
   Local cDatahora   := ""
   Local cInfAdic    := ""
   Local cMotivo     := ""
   Local cDetalhes   := ""
   Local cResponsavel:= ""
   Local cDue        := ""
   Local aDataP      := {}
   Local aAuxP       := {}
   Local aJson    := {}

   // Pega o retorno e converte para json para extrair as informações
   If !Empty(cRetJson)
      oJson    := JsonObject():New()
      xRetJson := oJson:FromJson(cRetJson)
      If valtype(xRetJson) == "U"
         If valtype(oJson:GetJsonObject("ret")) == "J"
            cDue := If(Valtype(oJson:GetJsonObject("due")) == "C", oJson:GetJsonObject("due"), "")
            If valtype(oJson:GetJsonObject("ret"):GetJsonObject("eventosDoHistorico")) == "A"
               aJson    := oJson:GetJsonObject("ret"):GetJsonObject("eventosDoHistorico")
               If len(aJson) > 0
                  for nX := 1 to Len(aJson)
                     aDataP := {}
                     cDatahora  := aJson[nX]:GetJsonText("dataEHoraDoEvento")
                     cInfAdic  := aJson[nX]:GetJsonText("informacoesAdicionais")
                     cMotivo  := aJson[nX]:GetJsonText("motivo")
                     cDetalhes := aJson[nX]:GetJsonText("detalhes")
                     cREsponsavel := aJson[nX]:GetJsonText("responsavel")
                     cStatus  := aJson[nX]:GetJsonText("evento")

                     nPos := aScan(aProcessos,{|x| x[2] == cDue })
                     If nPos > 0
                        If !Empty(cDatahora)
                           aAdd( aDataP , {  StoD( StrTransf(SubStr(cDataHora , 1, At("T", cDataHora)-1 ),"-","") )  , StrTransf(SubStr(cDataHora , At("T", cDataHora)+1 ,5),":","")  } )
                        EndIf
                        If !Empty(cInfAdic)
                           aAdd( aDataP, cInfAdic)
                        EndIf
                        If !Empty(cMotivo)
                           aAdd( aDataP, cMotivo)
                        EndIf
                        If !Empty(cDetalhes)
                           aAdd( aDataP, cDetalhes)
                        EndIf
                        If !Empty(cResponsavel)
                           aAdd( aDataP, cResponsavel)
                        EndIf
                        If !Empty(cStatus)
                           aAdd( aDataP, cStatus)
                        EndIf
                     EndIf
                     aAdd( aAuxP, aDataP)

                  Next nx

                  aAdd( aProcessos[nPos], aAuxP)
                  DU101GrvEKK(aProcessos[nPos]) //função para gravação dos status
                  DU101ExcHs(oProcDUE, aProcessos, nPos ) //função para exclusao do processo ja gravado do THashMap

               Endif
            Else
               cErrosDUE += ENTER + STR0010 + cDue + ENTER //"Falha de Integração para DUE: "
               If Valtype(oJson:GetJsonObject("ret")) == 'J'
                  cErrosDUE += IF(!Empty(oJson:GetJsonObject("ret"):GetJsonText("status")), oJson:GetJsonObject("ret"):GetJsonText("status") + ENTER,"")
                  cErrosDUE += IF(!Empty(oJson:GetJsonObject("ret"):GetJsonText("message")), oJson:GetJsonObject("ret"):GetJsonText("message") + ENTER, "")
                  cErrosDUE += IF(!Empty(oJson:GetJsonObject("ret"):GetJsonText("code")), oJson:GetJsonObject("ret"):GetJsonText("code") + ENTER, "")
                  cErrosDUE += If(!Empty(oJson:GetJsonObject("ret"):GetJsonText("date")) ,oJson:GetJsonObject("ret"):GetJsonText("date") + ENTER , "")
                  cErrosDUE += IF(!Empty(oJson:GetJsonObject("ret"):GetJsonText("severity")) ,oJson:GetJsonObject("ret"):GetJsonText("severity") + ENTER  , "")
                  cErrosDUE += IF(!Empty(oJson:GetJsonObject("ret"):GetJsonText("tag")) ,oJson:GetJsonObject("ret"):GetJsonText("tag") + ENTER, "")
               EndIf
            Endif
         Elseif Valtype(oJson:GetJsonObject("ERROR")) == "C"
            If oJson:GetJsonObject("ERROR") == "Not Found"
               cErrosDUE += STR0011 + oJson:GetJsonObject("ERROR") + ENTER //"Provavelmente a Conexão com o Servidor está indisponível ou houve falha na autenticação "
            Else
               cErrosDUE += STR0012 + oJson:GetJsonObject("ERROR") + ENTER
            EndIf
         EndIf
         FreeObj(oJson)
      Else
         cErrosDUE += STR0013 + cDue + "  " + xRetJson + ENTER //"Falha de Integração para DUE: "
      Endif
   Else
      cErrosDUE += STR0014 + cDue + ENTER //"Não houve retorno de Consulta de Status para DUE: "
   Endif

Return

/*/{Protheus.doc} DU101Auth
   Gera o script para autenticar e consumir o serviço do portal unico através do easyjs
   @author Ramon/Nilson
   @since 30/09/2020
   @version 1
/*/
Static Function DU101Auth(cPUAuth,cUrl,aProcessos)
   Local cVar
   Local cDues := ""

   aEval(aProcessos, {|X| cDues += "'"+X[2]+"'," })
   cDues := Left(cDues,len(cDues)-1)

   begincontent var cVar
      var lFim = false;
      var XCSRFToken = '';
      var SetToken = '';

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
               retAdvpl('S');
               return res.json();
            }else{
               retAdvplError( res.json() );
            }
         })
         .catch((e) => { retAdvplError(e) });
      }

      function IntStatus(retAdvpl,retAdvplChunk,retAdvplError){
         var aDues = [%Exp:cDues%];
         var cProcDue = () => {
            var cDue = aDues.shift();
            if(cDue && !lFim){
               fetch( '%Exp:cUrl%/due/api/ext/due/numero-da-due/'+cDue, {
                  method: 'GET',
                  mode: 'cors',
                  headers: {
                     'Content-Type': 'application/json',
                     "Authorization": SetToken,
                     "X-CSRF-Token":  XCSRFToken,
                  }
               })
               .then( (res) => res.json() )
               .then( (res) => { retAdvplChunk({ret:res,due:cDue}) ; cProcDue() } )
               //.then( (res) => { retAdvplChunk({ret:res,due:cDue}); setTimeout(()=>{cProcDue()},500) } )
               .catch( (e) => retAdvplError(e) )
            } else {
               retAdvpl('Processou');
            }
         }
         cProcDue();
      }
      //retAdvpl();
   endcontent

Return cVar
