#INCLUDE 'TOTVS.CH'
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'topconn.ch'
#INCLUDE 'AVERAGE.CH'
#Include 'EICLP402.CH'
#INCLUDE "EEC.CH"

/*
Funcao      : EICLP402()
Parametros  :
Retorno     : Nil
Objetivos   : Executar Integração da LPCO
Autor       : Maurício/Nilson
Data/Hora   : 09/12/2020
Obs.        :
*/
*-------------------
Function EICLP402()
*-------------------
Local aCoors := FWGetDialogSize( oMainWnd )
Local  oColumn
Private oDlgInt
Private oBrwInLpco
Private oRegLPCO  := tHashMap():New()

      //Cria a tela principal, sem bordas, títulos ou botões
      oDlgInt := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],STR0001,,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,) //"Integração de Solicitações de LPCO"

      //Cria o objeto do browse dos registros de LPCO
      oBrwInLpco := FWmBrowse():New()
      oBrwInLpco:SetOwner(oDlgInt)
      oBrwInLpco:SetDescription(STR0002) //"Integração de LPCO"
      oBrwInLpco:SetAlias("EKO")
      oBrwInLpco:SetMenuDef("EICLP402")
      oBrwInLpco:DisableDetails()//Desabilita a exibição dos detalhes do registro

      //Cria o filtro padrão para o Browse.
      oBrwInLpco:AddFilter (STR0003, "EKO_ATIVO == '1' .AND. EKO_INTEGR <> '1'", .T., .T.)  //"Ativos e não integrados"

      //Cria a coluna do marca/desmarca
      ADD MARKCOLUMN oColumn DATA { || SetMark() } DOUBLECLICK {|| MarkOne() } HEADERCLICK {|| MarkAll(oBrwInLpco) } OF oBrwInLpco

      //Habilita a exibição de visões e gráficos
      oBrwInLpco:SetAttach( .T. )
      //Configura as visões padrão
      oBrwInLpco:SetViewsDefault(LP402GetVs())
      oBrwInLpco:CIDVIEWDEFAULT := If( nModulo == 17,"1","2" ) //View "Importação"(SIGAEIC) e "Exportação"(SIGAEEC)
      oBrwInLpco:ForceQuitButton()
      //Ativa o Browse
      oBrwInLpco:Activate()
      //AutoMark()

      ACTIVATE MSDIALOG oDlgInt CENTERED

Return Nil

/*---------------------------------------------------------------------*
 | Func:  LP402GetVs                                                   |
 | Autor: Nilson César                                                 |
 | Data:  04/11/2020                                                   |
 | Desc:  Montar e retornar as visões Default do Browse                |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
*---------------------------
Static Function LP402GetVs()
*---------------------------
Local aVisions    := {}
Local aColunas    := AvGetCpBrw("EKO")
Local aContextos  := {"IMPORTAÇÃO","EXPORTAÇÃO"}
Local cFiltro     := ""
Local oDSView
Local i

   If aScan(aColunas, "EKO_FILIAL") == 0
      aAdd(aColunas, "EKO_FILIAL")
   EndIf

   For i := 1 To Len(aContextos)
      cFiltro := LP402GetFt(aContextos[i])            
      oDSView    := FWDSView():New()
      oDSView:SetName(AllTrim(Str(i)) + "-" + LP402GetFt(aContextos[i], .T.))
      oDSView:SetPublic(.T.)
      oDSView:SetCollumns(aColunas)
      oDSView:SetOrder(1)
      oDSView:AddFilter(AllTrim(Str(i)) + "-" + LP402GetFt(aContextos[i], .T.), cFiltro)
      oDSView:SetID(AllTrim(Str(i)))
      oDsView:SetLegend(.T.)
      aAdd(aVisions, oDSView)
   Next

Return aVisions

/*---------------------------------------------------------------------------------------------------------*
 | Func:  LP402GetFt                                                                                       |
 | Autor: Nilson César                                                                                     |
 | Data:  04/11/2020                                                                                       |
 | Desc:  Retorna a chave ou nome do filtro da tabela EKO de acordo com o contexto desejado                |
 | Obs.:  /                                                                                                |
 *--------------------------------------------------------------------------------------------------------*/
*---------------------------------------
Static Function LP402GetFt(cTipo, lNome)
*---------------------------------------
Local cRet     := ""
Default lNome  := .F.

   Do Case
      Case cTipo == "IMPORTAÇÃO" .And. !lNome
         cRet := "Upper(Left(EKO->EKO_FRMLPC,1)) = 'I' "
      Case cTipo == "IMPORTAÇÃO" .And. lNome
         cRet := "Importação"

      Case cTipo == "EXPORTAÇÃO" .And. !lNome
         cRet := "Upper(Left(EKO->EKO_FRMLPC,1)) = 'E' "
      Case cTipo == "EXPORTAÇÃO" .And. lNome
         cRet := "Exportação"
   EndCase

Return cRet


/*
Funcao      : MenuDef()
Parametros  :
Retorno     : Nil
Objetivos   : Menu Funcional
Autor       : 
Data/Hora   : 29/09/20
Obs.        :
*/
*------------------------
Static Function MenuDef()
*------------------------

Local aRot := {}

ADD OPTION aRot TITLE STR0004 ACTION 'LP402Integ()' OPERATION 4 ACCESS 0 //OPERATION X   //#"Integrar"

Return aRot

/*
Funcao      : LP402Integ()
Parametros  :
Retorno     : .T.
Objetivos   : Executar FwMarkBrowse de Integração de Status da DUE - Recebera retorno da consulta de status da integração junto ao portal
Autor       : 
Data/Hora   : 29/09/20
Obs.        :
*/
*--------------------
Function LP402Integ()
*--------------------
Local aAux := {}
Local aListLPCO := {}
Local i
Local cLib
GetRemoteType(@cLib)
If 'HTML' $ cLib 
    easyhelp(STR0027,STR0006,STR0028) //"Integração com Portal Único não disponível no smartclientHtml","AVISO","Utilizar o smartclient aplicativo"
Else
   oRegLPCO:List(@aAux)
   If ( lHasReg := Len(aAux) > 0 )
      For i := 1 To Len(aAux)
         aAdd( aListLPCO, { aAux[i][1] , aAux[i][2][1] , aAux[i][2][2] , aAux[i][2][3] , aAux[i][2][4], aAux[i][2][5] } )
      Next i

      //Orderna o array por código do LCPO + Versão
      aSort(aListLPCO,,,{|x,y| x[2] < y[2] .And. x[3] < y[3]   })

      //Chama a integração de status
      aLPCOs := LP402IntSt(aListLPCO) //Garantir que o fwmarkbrowse deixa marcado apenas os processos que retornaram da integração
   Else
      MsgStop(STR0005,STR0006) //"Não há registro(s) marcado(s) para integração!"  # "Aviso"
   EndIf
   oBrwInLpco:Refresh()
EndIf
Return .T.

/*
Função   : SetMark
Autor    : Nilson César
Data     : 29/09/2020
Objetivo : Retorna marca de registro conforme avaliação
*/
*-------------------------
static function SetMark()
*-------------------------
Local cRet
Local hashChLPCO := EKO->( RECNO() )

   aBuffLPCO := {}
   If !oRegLPCO:Get(hashChLPCO, @aBuffLPCO)
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
*--------------------------
static function AutoMark()
*--------------------------
Local lRet := .T.

   IF EKO_INTEGR <> '1'
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
Local hashChLPCO := EKO->( Recno() )

aBuffLPCO := {}
If !oRegLPCO:Get(hashChLPCO, @aBuffLPCO)
   oRegLPCO:Set( hashChLPCO , { EKO->EKO_ID , EKO->EKO_VERSAO, EKO->EKO_FRMLPC, EKO->EKO_INFOAD, EKO->EKO_LPCO } )
   lRet := .T.
Else
   oRegLPCO:Del(hashChLPCO)
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
static function MarkAll(oBrw)
*------------------------------
Local lRet := .F.
Local aListLPCO := {}
oRegLPCO:List(@aListLPCO)
If Empty(aListLPCO)
   EKO->(DbGoTop())
   Do While EKO->(!Eof())
      oRegLPCO:Set( EKO->( Recno() ) , { EKO->EKO_ID , EKO->EKO_VERSAO, EKO->EKO_FRMLPC, EKO->EKO_INFOAD, EKO->EKO_LPCO } )
      EKO->(DBSkip())
   EndDo
   lRet := .T.
Else
   oRegLPCO:Clean()
   lRet := .F.
EndIf
EKO->(DbGoTop())
oBrw:Refresh()

return lRet

/*
Função   : LP401GrvEKO
Autor    : Nilson César
Data     : 29/09/2020
Objetivo : Gravar os registros de detalhes de histórico da DUE (Consulta DUE)
*/
*--------------------------------------
Static Function LP401GrvEKO( aDataRet )
*--------------------------------------
Local lRet := .T.

EKO->( DbGoTo(aDataRet[1]) )

Begin Transaction
   // Grava os dados de retorno do Portal para a LPCO
   EKO->(Reclock("EKO",.F.))
   EKO->EKO_FILIAL   := xFilial("EKO")
   EKO->EKO_DATARG   := aDataRet[7][1][1][1]
   EKO->EKO_HORARG   := aDataRet[7][1][1][2]  
   EKO->EKO_CHVACE   := aDataRet[7][1][2]
   EKO->EKO_LPCO     := aDataRet[7][1][3]
   EKO->EKO_INTEGR   := "1"
   EKO->( MsUnlock() )

End Transaction

Return lRet

/*
Funcao      : LP401ExcHs
Parametros  :
Retorno     : aLPCOs
Objetivos   : Função que retira registro de LPCOs ja integrados do HashMap
Autor       : 
Data/Hora   : 06/10/2020
Obs.        :
*/
*----------------------------------------------------
Function LP401ExcHs(oRegLPCO, aLPCOs , nPosaProc)
*----------------------------------------------------
Local aBuffLPCO := {}

If oRegLPCO:Get(aLPCOs[1][1], @aBuffLPCO)
   oRegLPCO:Del(aLPCOs[1][1])
EndIf
If ValType( aLPCOs[nPosaProc] ) == "A"
   aDel(aLPCOs,nPosaProc)
   aSize(aLPCOs,Len(aLPCOs)-1)
EndIf

Return

/*
Funcao      : LP402IntSt
Parametros  :
Retorno     : aLPCOs - 
Objetivos   : Função que efetua a consulta de status da Declaração Única de Exportação junto ao Portal
Autor       : 
Data/Hora   : 29/09/20
Obs.        :
*/
*--------------------------
Function LP402IntSt(aLPCOs)
*--------------------------
Local cURLTest    := EasyGParam("MV_EIC0073",.F.,"https://val.portalunico.siscomex.gov.br") // Teste integrador localhost:3001 - val.portalunico.siscomex.gov.br
Local cURLProd    := EasyGParam("MV_EIC0072",.F.,"https://portalunico.siscomex.gov.br") // Produção - portalunico.siscomex.gov.br 
Local lIntgProd   := EasyGParam("MV_EIC0074",.F.,"1") == "1"
Local cErrosLPCO  := ""
Local lRet        := .T.
Local lEasyProgr  := .F.
Local cPortal  := ""
Local oProg

Default aLPCOs  := {}

Private lProcessou := .F. //ira mudar para True assim que processar tudo ou se o usuario cancelar e ja tiver consultado ao menos um Status
Private lPrimeira  := .T.


Begin sequence
     
   If Len(aLPCOs) = 0   
      EasyHelp(STR0014) //"Marque ao menos uma solicitação LPCO"  
      lRet := .F.
   else

      If !lIntgProd 
         If ! Msgnoyes( STR0007 + ENTER ;     // "O sistema está configurado para integração com a Base de Testes do Portal Único."
                        + STR0008 + ENTER ;   // "Qualquer integração para a Base de Testes não terá qualquer efeito legal e não deve ser utilizada em um ambiente de produção."
                        + STR0009 + ENTER ;   // "Para integrar com a Base Oficial (Produção) do Portal Único, altere o parâmetro 'MV_EIC0074' para 1."
                        + STR0010 , STR0011 ) // "Deseja Prosseguir?" // "Atenção"
               lRet := .F.
               break
         Else
            cPortal := cURLTest
         Endif
      Else
         cPortal := cURLProd
      EndIf
   
      lEasyProgr  := Len(aLPCOs) > 3
      If lEasyProgr
         oProg   := EasyProgress():New(.T.)
         oProg:SetProcess({|| lRet := LP402Port(aLPCOs,cPortal,@cErrosLPCO,@oProg)},STR0012) //"Processando Integração de LPCO .." 
         oProg:Init()     
      Elseif Len(aLPCOs) <> 0    
         MsAguarde({|| lRet := LP402Port(aLPCOs,cPortal,@cErrosLPCO,@oProg)},STR0012, STR0013,.T.) //"Processando Integração de LPCO .."## "Processando integração"
      EndIf  

      If lRet
         MsgInfo(STR0015,STR0006) //"Integrado com sucesso" //"Aviso"
      Else
         If !Empty(cErrosLPCO)
            EECView(cErrosLPCO) 
         ElseIf Valtype(oProg) == 'O' .And. oProg:lAbort
            MsgInfo(STR0016,STR0006) //"Cancelado pelo usuário" //"Aviso"
         EndIf         
      Endif
   EndIf  

End Sequence

Return aLPCOs

/*
Função que gera o json do lpco para a integracao
@author Maurício Frisons
@since 15/12/2020
*/
Function LP402Json(aLpcos)
   Local cTexto         := ""
   Local oJsonInterno   := JsonObject():New()
   Local oJson          := JsonObject():New()
   Local oListaNCM      := JsonObject():New()
   Local oListaCpsFor   := JsonObject():New()
   Local nPos           := 0
   Local x

      oJson['codigoModelo']            := aLpcos[4]
      oJson['informacaoAdicional']     := allTrim(aLpcos[5])
      oJson['listaCamposFormulario']   := {}
      oJson['listaNCM']                := {}

      // EKO	1	EKO_FILIAL+EKO_ID+EKO_VERSAO
      EKO->(dbgoto(aLpcos[1]))

      // EKP	1	EKP_FILIAL+EKP_ID+EKP_VERSAO+EKP_IDCPOF+EKP_SQCPOF+EKP_CDCPOF
      if EKP->(dbsetorder(1),dbseek( xFilial("EKP")+EKO->EKO_ID+EKO->EKO_VERSAO ))

         while ( EKP->EKP_FILIAL == xFilial("EKP") .and. EKP->EKP_ID+EKP->EKP_VERSAO == EKO->EKO_ID+EKO->EKO_VERSAO )

            if left(EKP->EKP_CDCPOF,4) != "INT_"
               if empty(EKP->EKP_SQCPOF) //alltrim(upper(EKP->EKP_IDCPOF)) == upper("listaCamposFormulario")

                  if ( nPos := ascan( oJson['listaCamposFormulario'], {|x| x['codigo'] == alltrim(EKP->EKP_CDCPOF) } )) == 0

                     oListaCpsFor               := JsonObject():New()
                     oListaCpsFor["codigo"]     := alltrim(EKP->EKP_CDCPOF)
                     oListaCpsFor["listaValor"] := { alltrim(EKP->EKP_VLCPOF) }

                     // oListaCpsFor["valorComposto"] := JsonObject():New()
                     aadd( oJson['listaCamposFormulario'], oListaCpsFor )
                     FreeObj(oListaCpsFor)

                     if alltrim(upper(EKP->EKP_CDCPOF)) == "QTDE_COMERCIALIZADA"
                        nRecAux := EKP->(recno())
                        if EKP->(dbsetorder(1),dbseek(xFilial("EKP")+EKP->EKP_ID+EKP->EKP_VERSAO+EKP->EKP_IDCPOF+EKP->EKP_SQCPOF+avkey("INT_UNID_COMERCIAL","EKP_CDCPOF")))
                           oListaCpsFor                   := JsonObject():New()
                           oListaCpsFor["codigo"]         := alltrim(upper(EKP->EKP_CDCPOF))
                           oListaCpsFor["listaValor"]     := {alltrim(EKP->EKP_VLCPOF)}
                           oListaCpsFor["unidadeMedida"]  := alltrim(EKP->EKP_VLCPOF)
                           aadd( oJson['listaCamposFormulario'], oListaCpsFor )
                           FreeObj(oListaCpsFor)
                        endif
                        EKP->(dbgoto(nRecAux))
                     endif

                  else

                     aadd( oJson['listaCamposFormulario'][nPos]['listaValor'], alltrim(EKP->EKP_VLCPOF) )
                     nPos := 0

                  EndIf

               Else

                  if val(EKP->EKP_SQCPOF) > len(oJson['listaNCM'])
                     if (val(EKP->EKP_SQCPOF) - len(oJson['listaNCM'])) > 1
                        for x := 1 to (val(EKP->EKP_SQCPOF) - len(oJson['listaNCM']))
                           oListaNCM                        := JsonObject():New()
                           oListaNCM["listaAtributosNcm"]   := {}
                           oListaNCM["listaCamposNcm"]      := {}
                           oListaNCM["ncm"]                 := ''
                           aadd( oJson['listaNCM'], oListaNCM )
                           FreeObj(oListaNCM)
                        next
                     else
                        oListaNCM                        := JsonObject():New()
                        oListaNCM["listaAtributosNcm"]   := {}
                        oListaNCM["listaCamposNcm"]      := {}
                        oListaNCM["ncm"]                 := ''
                        aadd( oJson['listaNCM'], oListaNCM )
                        FreeObj(oListaNCM)
                     endif
                  endif

                  If alltrim(upper(EKP->EKP_IDCPOF)) == upper("listaNcm")

                     oJson['listaNCM'][val(EKP->EKP_SQCPOF)][alltrim(EKP->EKP_CDCPOF)] := alltrim(EKP->EKP_VLCPOF)
                        
                  else
            
                     if (nPos := ascan( oJson['listaNCM'][val(EKP->EKP_SQCPOF)][alltrim(EKP->EKP_IDCPOF)], {|x| x["codigo"] == alltrim(upper(EKP->EKP_CDCPOF)) } )) == 0

                        oListaNCM               := JsonObject():New()
                        oListaNCM["codigo"]     := alltrim(upper(EKP->EKP_CDCPOF))
                        oListaNCM["listaValor"] := { alltrim(EKP->EKP_VLCPOF) }

                        if alltrim(upper(EKP->EKP_CDCPOF)) == "QTDE_COMERCIALIZADA"
                           nRecAux := EKP->(recno())
                           if EKP->(dbsetorder(1),dbseek(xFilial("EKP")+EKP->EKP_ID+EKP->EKP_VERSAO+EKP->EKP_IDCPOF+EKP->EKP_SQCPOF+avkey("INT_UNID_COMERCIAL","EKP_CDCPOF")))

                              oListaNCM["unidadeMedida"] := alltrim(EKP->EKP_VLCPOF)

                           endif
                           EKP->(dbgoto(nRecAux))
                        endif
                        
                        if valtype(oListaNCM) == "J"
                           aadd( oJson['listaNCM'][val(EKP->EKP_SQCPOF)][alltrim(EKP->EKP_IDCPOF)], oListaNCM )
                           FreeObj(oListaNCM)
                        EndIf

                     else

                        aadd(oJson['listaNCM'][val(EKP->EKP_SQCPOF)][alltrim(EKP->EKP_IDCPOF)][nPos]["listaValor"] , alltrim(EKP->EKP_VLCPOF) )

                     endif
                  EndIf
               EndIf
            EndIf

            EKP->(dbskip())
         endDo

      endif

   oJsonInterno['recno']      := lTrim(str(aLPCOs[1]))
   oJsonInterno['idLpco']     := aLpcos[2]
   oJsonInterno['versao']     := aLpcos[3]
   oJsonInterno['modeloForm'] := aLpcos[4]
   oJsonInterno['numLpco']    := rTrim(aLpcos[6])
   oJsonInterno['cJson']      := oJson
   FreeObj(oJson)
   cTexto := oJsonInterno:toJson()
   FreeObj(oJsonInterno)


Return cTexto

/*/{Protheus.doc} LP402Portltrim(str(aLPCOs[1]))
   Função que realiza a Consulta de Status da Integração com o Portal para cada item do array aLPCOs
   @author Ramon Prado
   @since 30/09/2020
   @version 1
   /*/
*-------------------------------------------------
Function LP402Port(aLPCOs,cPortal,cErrosLPCO,oProg)
*-------------------------------------------------
Local nQtdInt  := Len(aLPCOs)
Local lRet     := .T.
Local cErros   := ""
Local cPUAuth  := cPortal+"/portal/api/autenticar"
Local aBuffProc:= {}
Local aLPCOProc := {}
Local i:=0
LOcal ctn:=0
Private oEasyJS
Private lErroGrave := .F.

Begin Sequence

   
   oEasyJS := EasyJS():New()
   oEasyJS:cUrl := cPUAuth
   oEasyJS:AddLib( LP402Auth(cPUAuth, cPortal))

   oEasyJS:SetTimeout(120)
      
   If oEasyJS:Activate(.T.)
      oEasyJS:SetTimeout(0)
         
      oEasyJS:runJSSync( "autenticar(retAdvpl,retAdvplChunk,retAdvplError);" ,{|x| lRet := LP402BUFFER(x, @cErrosLPCO,aBuffProc,aLPCOs,@oProg) }, {|x|   lErroGrave := .T., cErros := x } ) //Executando um javascript de forma Síncrona                 
      
      if lRet .and. ! lErroGrave
         If Valtype(oProg) == 'O'
            oProg:SetRegua(nQtdInt)
         EndIf
         oEasyJS:runJS( "IntLpco(retAdvpl,retAdvplChunk,retAdvplError);" ,{|x| lRet := LP402BUFFER(x, @cErrosLPCO,aBuffProc,aLPCOs,@oProg) }, {|x|  lErroGrave := .T., cErros := x } ) //Executando um javascript de forma Síncrona                       
      Else
         cErros += ENTER + STR0026 //"Não foi possível autenticar no Portal Único Siscomex. Verifique o endereço nos parâmetros e verifique se o portal está no ar."
         lRet := .F.
      EndIf   
   Else
      EasyHelp(STR0017) //"Falha na integração"
      lRet := .F.
   EndIf

   ctn:=0
   if lRet 
      For i:=1 to nQtdInt
         aLPCOProc := LP402Json(aLPCOs[i]) 
         oEasyJS:runJS("addLpcos(retAdvpl,'"+aLPCOProc+"')" , {|x| ctn := ctn+1} ,  {|x| cErros := x } )
         If Valtype(oProg) == 'O'
             oProg:Refresh()
         EndIf
      Next
      oEasyJS:wait({|| ctn == nQtdInt }) 
      oEasyJS:runJS( "lEndFor = true; retAdvpl('S');" , , {|x| cErros := x } )
      lRet := LP402DescB(aBuffProc,@cErrosLPCO,aLPCOs,oProg)
   EndIf

   If !Empty(cErros)
      If Alltrim(cErros) == STR0018 //"Failed to fetch"
         EasyHelp(STR0019) //"Falha de conexão com o Portal Siscomex"
         lRet := .F.
      Else
         EasyHelp(cErros) //retorno falha grave
         lRet := .F.
      EndIf
   EndIf
   
  

End Sequence

Return lRet

/*/{Protheus.doc} LP402DescB
   Função que descarrega(chama a função que processa o retorno do JSON do Portal Siscomex) o Buffer
   @author Ramon/Nilson
   @since 30/09/2020
   @version 1
   /*/
*-----------------------------------------------------
Function LP402DescB(aBuffProc,cErrosLPCO,aLPCOs, oProg)
*-----------------------------------------------------
Local lRet           := .T.
Local nCont          := 1

//Processa o JSON de Retorno para salvar o conteudo das tags e chamar a gravação da tabela de status da integração(EKK)

While (Len(aBuffProc) > 0 .Or. !lProcessou) .And. !lErroGrave
   If Len(aBuffProc) > 0
      If Valtype(oProg) == 'O'
         oProg:IncRegua()
      Else
         MsProcTxt(STR0024 + cValToChar(nCont) + STR0025 + cValToChar(Len(aBuffProc)) + "...") //"Processando registro " # " de "
      EndIf           
      LP402PROCJ(aBuffProc[1],@cErrosLPCO,aLPCOs)
      aDel(aBuffProc, 1)
      aSize(aBuffProc,Len(aBuffProc)-1)
   Else
      oEasyJS:wait({|| len(aBuffProc) > 0 .or. lErroGrave .or. lProcessou .or. (Valtype(oProg) == 'O'  .And. oProg:lAbort )}) 
   EndIf
   If Valtype(oProg) == 'O'  .And. oProg:lAbort //houve cancelamento do processo
      lRet := .F.    
      //Avisar o Javascript
       oEasyJS:runJS( "lFim = true; lEndFor = true; retAdvpl('S');" , , {|x| cErros := x } )
      exit
   EndIf 
   nCont++  
EndDo

IF !Empty(cErrosLPCO)
   lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} LP402BUFFER
   Buffer para processamento
   @author Ramon/Nilson
   @since 02/10/2020
   @version 1
   /*/
*------------------------------------------------------------------
Function LP402BUFFER(cRetJson, cErrosLPCO, aBuffProc, aLPCOs, oProg)
*------------------------------------------------------------------
Local lRet := .F.

If Alltrim(cRetJson) == 'Processou'
   lProcessou := .T.
   lRet := .T. 
elseIf Alltrim(cRetJson) == 'S'
   lRet := .T. 
Else
   aAdd(aBuffProc, cRetJson)
Endif

If Valtype(oProg) <> 'O' .And. !IsInCallStack("LP402DescB") .And. lProcessou //uso do msaguarde tera descarga de buffer diferente do EasyProgress
   lRet := LP402DescB(aBuffProc,@cErrosLPCO,aLPCOs,oProg)   
EndIf

Return lRet 

/*/{Protheus.doc} LP402PROCJ
   Processa o retorno(Json) da consulta de status da LPCO
   @author Ramon/Nilson
   @since 02/10/2020
   @version 1
   /*/
*---------------------------------------------
Function LP402PROCJ(cRetJson,cErrosLPCO,aLPCOs)
*---------------------------------------------
Local nPos := 0
Local cLpco       := ""
Local aDataP      := {}
Local aAuxP       := {}
Local cNumLpco     := ""
Local cChave      := ""

 // Pega o retorno e converte para json para extrair as informações
If !Empty(cRetJson)
   oJson    := JsonObject():New()
   xRetJson := oJson:FromJson(cRetJson)
   If valtype(xRetJson) == "U" 
      If valtype(oJson:GetJsonObject("ret")) == "J"
         cLpco := If(Valtype(oJson:GetJsonObject("lpco")) == "C", oJson:GetJsonObject("lpco"), "")
         if Valtype(oJson:GetJsonObject("ret"):GetJsonObject("chaveAcesso")) == "C"
            cChave := If(Valtype(oJson:GetJsonObject("ret"):GetJsonObject("chaveAcesso")) == "C", oJson:GetJsonObject("ret"):GetJsonObject("chaveAcesso"), "")
            cNumLpco := if(Valtype(oJson:GetJsonObject("ret"):GetJsonObject("numero")) == "C", oJson:GetJsonObject("ret"):GetJsonObject("numero"), "")
            cDatahora := if(ValType(oJson:GetJsonObject("ret"):GetJsonObject("dataRegistro")) == "C", oJson:GetJsonObject("ret"):GetJsonObject("dataRegistro"), "")
            nPos := aScan(aLPCOs,{|x| x[2] == cLpco })
            If nPos > 0
               If !Empty(cDatahora)                        
                  aAdd( aDataP , {  StoD( StrTransf(SubStr(cDataHora , 1, At("T", cDataHora)-1 ),"-","") )  , StrTransf(SubStr(cDataHora , At("T", cDataHora)+1 ,5),":","")  } )
               EndIf 
               If !Empty(cChave)
                  aAdd( aDataP, cChave)
               EndIf 
               If !Empty(cNumLpco)
                  aAdd( aDataP, cNumLpco)
               EndIf 
            EndIf
            aAdd( aAuxP, aDataP)

            aAdd( aLPCOs[nPos], aAuxP)
            LP401GrvEKO(aLPCOs[nPos]) //função para gravação dos status
            LP401ExcHs(oRegLPCO, aLPCOs, nPos ) //função para exclusao do processo ja gravado do THashMap
            
         Else
            cErrosLPCO += ENTER + STR0020 + cLpco + ENTER //"Falha de Integração para LPCO: "
            cErrosLPCO += IF(ValType(oJson:GetJsonObject("ret"):GetJsonObject("message")) == "C" .And. !Empty(oJson:GetJsonObject("ret"):GetJsonText("message")), oJson:GetJsonObject("ret"):GetJsonText("message") + ENTER, "")          
            cErrosLPCO += IF(ValType(oJson:GetJsonObject("ret"):GetJsonObject("code")) == "C" .And. !Empty(oJson:GetJsonObject("ret"):GetJsonText("code")), oJson:GetJsonObject("ret"):GetJsonText("code") + ENTER, "")      
            cErrosLPCO += If(ValType(oJson:GetJsonObject("ret"):GetJsonObject("date")) == "C" .And. !Empty(oJson:GetJsonObject("ret"):GetJsonText("date")) ,oJson:GetJsonObject("ret"):GetJsonText("date") + ENTER , "")               
            cErrosLPCO += IF(ValType(oJson:GetJsonObject("ret"):GetJsonObject("severity")) == "C" .And. !Empty(oJson:GetJsonObject("ret"):GetJsonText("severity")) ,oJson:GetJsonObject("ret"):GetJsonText("severity") + ENTER  , "") 
            cErrosLPCO += IF(ValType(oJson:GetJsonObject("ret"):GetJsonObject("tag")) == "C" .And. !Empty(oJson:GetJsonObject("ret"):GetJsonText("tag")) ,oJson:GetJsonObject("ret"):GetJsonText("tag") + ENTER, "")  
            cErrosLPCO += IF(ValType(oJson:GetJsonObject("ret"):GetJsonObject("validacao")) <> "U" .And. ValType(oJson:GetJsonObject("ret"):GetJsonObject("validacao"):GetJsonObject("codigo")) == "C" .And. !Empty(oJson:GetJsonObject("ret"):GetJsonObject("validacao"):GetJsonText("codigo")) ,oJson:GetJsonObject("ret"):GetJsonObject("validacao"):GetJsonText("codigo") + ENTER, "")    
            cErrosLPCO += IF(ValType(oJson:GetJsonObject("ret"):GetJsonObject("validacao")) <> "U" .And. ValType(oJson:GetJsonObject("ret"):GetJsonObject("validacao"):GetJsonObject("Mensagem")) == "C" .And. !Empty(oJson:GetJsonObject("ret"):GetJsonObject("validacao"):GetJsonText("Mensagem")) ,oJson:GetJsonObject("ret"):GetJsonObject("validacao"):GetJsonText("Mensagem") + ENTER, "")           
         Endif
      Elseif Valtype(oJson:GetJsonObject("ERROR")) == "C"
         If oJson:GetJsonObject("ERROR") == "Not Found"
            cErrosLPCO += STR0021 + oJson:GetJsonObject("ERROR") + ENTER //"Provavelmente a Conexão com o Servidor está indisponível ou houve falha na autenticação "  
         Else
            cErrosLPCO += STR0022 + oJson:GetJsonObject("ERROR") + ENTER //"Falha na integração"
         EndIf   
      EndIf
      FreeObj(oJson)
   Else
      cErrosLPCO += STR0020 + cLpco + "  " + xRetJson + ENTER //"Falha de Integração para LPCO: "
   Endif
Else
   cErrosLPCO += STR0023 + cLpco + ENTER //"Não houve retorno para LPCO: "
Endif
  
Return

/*/{Protheus.doc} LP402Auth
   Gera o script para autenticar e consumir o serviço do portal unico através do easyjs
   @author Ramon/Nilson
   @since 30/09/2020
   @version 1
   /*/
*---------------------------------------------
Static Function LP402Auth(cPUAuth,cUrl)
*---------------------------------------------

   begincontent var cVar
      var lFim = false;
      var XCSRFToken = '';
      var SetToken = '';
      var aLpcos = [];
      var lEndFor = false;

      function addLpcos(retAdvpl,aLpco){
         aLpcos.push(aLpco);
         retAdvpl('Processou');
      }

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

      function IntLpco(retAdvpl,retAdvplChunk,retAdvplError){
         var cProcLpco = () => {
            var cLpco = aLpcos.shift();
            if(cLpco && !lFim){
               var jLpco = JSON.parse(cLpco)
               var cLpcoId = jLpco.idLpco;
               var cVersao = jLpco.versao;
               var cNumLpco = jLpco.numLpco;
               var cJson = jLpco.cJson;
               fetch( '%Exp:cUrl%/talpco/api/ext/lpco/'+cNumLpco, {
                  method: (cNumLpco==''?'POST':'PUT'),
                  mode: 'cors',                     
                  headers: { 
                     'Content-Type': 'application/json',
                     "Authorization": SetToken,
                     "X-CSRF-Token":  XCSRFToken,
                  },
                   body: JSON.stringify(cJson),
               })
               .then( (res) => res.json() )
               .then( (json) => { retAdvplChunk({OA:cNumLpco,ret:json,lpco:cLpcoId}) ; cProcLpco() })
               .catch( (e)  => { retAdvplError(e) });
            } else {
                   if (lEndFor) {
                      retAdvpl('Processou');
                   } else {
                      setTimeout(cProcLpco,100);
                   }
            }
         }
         cProcLpco();
      }
      

   endcontent

Return cVar
