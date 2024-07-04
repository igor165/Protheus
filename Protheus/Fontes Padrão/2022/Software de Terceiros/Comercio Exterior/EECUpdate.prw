/*
Programa : EECUpdate
Autor    : Jeferson Barros Jr.    
Data     : 13/12/03 10:16.
Uso      : Funções diversas - Update.
Revisao  :                   
*/

#include "EECRDM.CH"

/*
Funcao      : AgenCom()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Tratamentos para gravação do código do agente recebdor de comissão.
Autor       : Jeferson Barros Jr.
Data        : 10/12/03 11:31.
Revisao     : 
Obs.        :
*/
*----------------*
Function AgenCom()
*----------------*
Local aOrd:=SaveOrd({"EE7","EEC","EEB","EE8","EE9"})
Local lRet:=.t., nLen
Local lUpdatePed:=.t., lUpdateEmb:=.t.
Local nTotComis:=0, nTotFob:=0

#IFDEF TOP
   Local aAlias:={"EE8","EE9"}
   Local cCmd, J:=0
#ENDIF

//TRP - 05/03/2012 - Caso não possua registros na tabela EE7 não continuar a execução.
DbSelectArea("EE7")

IF EE7->(EOF()) .AND. EE7->(BOF())
   Return .T.
ENDIF

Begin sequence

   EEB->(DbSetOrder(1))
   EE8->(DbSetOrder(1))
   EE9->(DbSetOrder(2))

   #IFDEF TOP
      // ** Verifica se existe algum agente preenchido nos itens do pedido e do embarque.
      For j:=1 To Len(aAlias)
         cCmd     := "Select Count(*) NCOUNT From " +;
                     RetSqlName(aAlias[j]) +Space(1)+aAlias[j] +;
                     " Where D_E_L_E_T_ <> '*' And "+; 
                           aAlias[j]+"_FILIAL  = '"+xFilial(aAlias[j])+"' And "+;
                           aAlias[j]+"_CODAGE <> '"+Space(Avsx3(aAlias[j]+"_CODAGE",AV_TAMANHO))+" '"

         cCmd     := ChangeQuery(cCmd)
         nOldArea := Alias()

         DbUseArea(.T., "TOPCONN", TCGENQRY(,,cCmd), "QryUpd", .F., .T.) 

         If aAlias[j] == "EE8"
            lUpdatePed := (QryUpd->NCOUNT = 0)
         Else
            lUpdateEmb := (QryUpd->NCOUNT = 0)
         EndIf
  
         QryUpd->(DbCloseArea())
         DbSelectArea(nOldArea)

         If !lUpdatePed
            Break
         EndIf
      Next
   #ELSE

      // ** Verifica se existe algum agente preenchido nos itens do pedido.
      EE8->(DbSeek(xFilial("EE8")))
      Do While EE8->(!Eof()) .And. EE8->EE8_FILIAL == xFilial("EE8")
         If !Empty(EE8->EE8_CODAGE)
            lUpdatePed := .f.
            Exit
         EndIf
         EE8->(DbSkip())
      EndDo

      If !lUpdatePed
         Break
      EndIf   
   
      // ** Verifica se existe algum agente preenchido nos itens do embarque.
      EE9->(DbSeek(xFilial("EE9")))
      Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == xFilial("EE9")
         If !Empty(EE9->EE9_CODAGE)
            lUpdateEmb := .f.
            Exit
         EndIf
         EE9->(DbSkip())
      EndDo
   #ENDIF

   If !lUpdatePed .Or. !lUpdateEmb
      Break
   EndIf   
   
   // ** Atualiza os pedidos.
   nLen:= EE7->(LastRec())

   EE7->(DbSetOrder(1))
   EE7->(DbSeek(xFilial("EE7")))

   UpdSet01(nLen)
   
   Do While EE7->(!Eof()) .And. EE7->EE7_FILIAL == xFilial("EE7")
      UpdInc01("Agentes Recebedores de Comissão"+ENTER+;
               "Verificando Pedido Nro: "+AllTrim(Transf(EE7->EE7_PEDIDO,AVSX3("EE7_PEDIDO",AV_PICTURE))))

      If Empty(EE7->EE7_VALCOM)
         EE7->(DbSkip())
         Loop                         
      EndIf

      If !Empty(BuscaEmpresa(EE7->EE7_PEDIDO,OC_PE,CD_AGC))
         cCodAg:= EEB->EEB_CODAGE
         If !Empty(cCodAg)

            // ** Calcula o percentual de comissão.
            If (EE7->EE7_TIPCVL == "1")
               nTotComis := EE7->EE7_VALCOM

            ElseIf (EE7->EE7_TIPCVL == "2")
               nTotFob := (EE7->EE7_TOTPED+EE7->EE7_DESCON)-(EE7->EE7_FRPREV+EE7->EE7_FRPCOM+EE7->EE7_SEGPRE+;
                           EE7->EE7_DESPIN+AvGetCpo("EE7->EE7_DESP1")+AvGetCpo("EE7->EE7_DESP2"))

               nTotComis := Round(100*(EE7->EE7_VALCOM/nTotFob),2)

               If nTotComis > 99.99
                  nTotComis := 99.99
               EndIf
            EndIf

            If nTotComis > 0
               EE8->(DbSeek(xFilial("EE8")+EE7->EE7_PEDIDO))
               Do While EE8->(!Eof()) .And. EE8->EE8_FILIAL == xFilial("EE8") .And.;
                                            EE8->EE8_PEDIDO == EE7->EE7_PEDIDO

                  If EE8->(RecLock("EE8",.f.))
                     EE8->EE8_CODAGE := cCodAg // ** Cod. Agente.
                     EE8->EE8_PERCOM := Round(nTotComis,AvSx3("EE8_PERCOM",AV_DECIMAL)) // ** Percentual Comis.
                     EE8->(MsUnLock())
                  EndIf

                  EE8->(DbSkip())
               EndDo
            EndIf
            nTotComis := 0
            cCodAg    := ""
         EndIf               
      EndIf
      EE7->(DbSkip())
   EndDo

   // Atualiza os embarques.
   nLen:= EEC->(LastRec())

   EEC->(DbSetOrder(1))
   EEC->(DbSeek(xFilial("EEC")))

   UpdSet01(nLen)

   Do While EEC->(!Eof()) .And. EEC->EEC_FILIAL == xFilial("EEC")
      UpdInc01("Agentes Recebedores de Comissão"+ENTER+;
               "Verificando Processo de Embarque Nro: "+AllTrim(Transf(EEC->EEC_PREEMB,AVSX3("EEC_PREEMB",AV_PICTURE))))

      If Empty(EEC->EEC_VALCOM)
         EEC->(DbSkip())
         Loop
      EndIf

      If !Empty(BuscaEmpresa(EEC->EEC_PREEMB,OC_EM,CD_AGC))
         cCodAg:= EEB->EEB_CODAGE

         If !Empty(cCodAg)
            // ** Calcula o percentual de comissão.
            If (EEC->EEC_TIPCVL == "1")
               nTotComis := EEC->EEC_VALCOM

            ElseIf (EEC->EEC_TIPCVL == "2")
               nTotFob := (EEC->EEC_TOTPED+EEC->EEC_DESCON)-(EEC->EEC_FRPREV+EEC->EEC_FRPCOM+EEC->EEC_SEGPRE+;
                           EEC->EEC_DESPIN+AvGetCpo("EEC->EEC_DESP1")+AvGetCpo("EEC->EEC_DESP2"))

               nTotComis := Round(100*(EEC->EEC_VALCOM/nTotFob),2)

               If nTotComis > 99.99
                  nTotComis := 99.99
               EndIf
            EndIf

            If nTotComis > 0
               EE9->(DbSeek(xFilial("EE9")+EEC->EEC_PREEMB))
               Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == xFilial("EE9") .And.;
                                            EE9->EE9_PREEMB == EEC->EEC_PREEMB

                  If EE9->(RecLock("EE9",.f.))
                     EE9->EE9_CODAGE := cCodAg
                     EE9->EE9_PERCOM := Round(nTotComis,AvSx3("EE9_PERCOM",AV_DECIMAL)) // ** Percentual Comis.
                     EE9->(MsUnLock())
                  EndIf

                  EE9->(DbSkip())
               EndDo
            EndIf
            nTotComis :=0
            cCodAg    :=""
         EndIf
      EndIf
      EEC->(DbSkip())
   EndDo
 
End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : OrdProcs()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Gravação do campo EE7_KEY (Pedido) e EEC_VLNFC (Embarque) para 
              ordeção decrescente de processos.
Autor       : Jeferson Barros Jr.
Data        : 10/11/03 14:29.
Revisao     : 
Obs.        :
*/
*------------------*
Function OrdProcs()
*------------------*
Local lRet:=.t.

Begin sequence

   If EECFlags("ORD_PROC")
      SetIndexKey()    // ** Grava o campo chave para os pedidos.
      SetIndexKey(.f.) // ** Grava o campo chave para os embarques.
   EndIf

End Sequence

Return lRet

/*
Funcao      : SetIndexKey(lPedido).
Parametros  : lPedido = .t. - Fase de Pedido (Default).
                        .f. - Fase de Embarque.
Retorno     : .t.
Objetivos   : Gravação do campo EE7_KEY (Pedido) e EEC_VLNFC (Embarque) para 
              ordeção decrescente de processos.
Autor       : Jeferson Barros Jr.
Data        : 10/11/03 14:46.
Revisao     : 
Obs.        :
*/
*----------------------------------*
Static Function SetIndexKey(lPedido)
*----------------------------------*
Local lRet:=.t., cAlias, aOrd:=SaveOrd({"EE7","EEC"})
Local nNextKey := 9999999999, nLen

Default lPedido := .t.

Begin Sequence

   cAlias:=If(lPedido,"EE7","EEC")

   nLen := (cAlias)->(LastRec())+1
   UpdSet01(nLen)

   If lPedido

      Begin Transaction

         EE7->(DbSetOrder(2))

         // ** Atualiza os processos com data de solicitação preenchida...
         EE7->(DbSeek(xFilial("EE7")+Dtos(Ctod("01/01/1900")),.t.))
         Do While EE7->(!Eof()) .And. xFilial("EE7") == EE7->EE7_FILIAL .And. !Empty(EE7->EE7_DTSLCR)

            UpdInc01("Atualizando Dados do Processo: "+;
                     AllTrim(Transf(EE7->EE7_PEDIDO,AVSX3("EE7_PEDIDO",AV_PICTURE))))

            EE7->(RecLock("EE7",.f.))
            EE7->EE7_KEY := nNextKey

            nNextKey -= 1
            EE7->(DbSkip())
         EndDo

         // ** Atualiza os processos sem data de solicitação preenchida...
         EE7->(DbSeek(xFilial("EE7")))
         Do While EE7->(!Eof()) .And. xFilial("EE7") == EE7->EE7_FILIAL .And. Empty(EE7->EE7_DTSLCR)

            UpdInc01("Atualizando Dados do Processo: "+;
                     AllTrim(Transf(EE7->EE7_PEDIDO,AVSX3("EE7_PEDIDO",AV_PICTURE))))

            EE7->(RecLock("EE7",.f.))
            EE7->EE7_KEY := nNextKey

            nNextKey -= 1

            EE7->(DbSkip())
         EndDo

      End Transaction
   Else
   
      Begin Transaction
      
         EEC->(DbSetOrder(12))

         // ** Atualiza os processos já embarcados.
         EEC->(DbSeek(xFilial("EEC")+Dtos(Ctod("01/01/1900")),.t.))
         Do While EEC->(!Eof()) .And. xFilial("EEC") == EEC->EEC_FILIAL .And. !Empty(EEC->EEC_DTEMBA)

            UpdInc01("Atualizando Dados do Processo: "+;
                     AllTrim(Transf(EEC->EEC_PREEMB,AVSX3("EEC_PREEMB",AV_PICTURE))))

            EEC->(RecLock("EEC",.f.))
            EEC->EEC_VLNFC := nNextKey
            nNextKey -= 1
            
            EEC->(DbSkip())
         EndDo

         // ** Atualizando os processos sem data de embarque.
         EEC->(DbSeek(xFilial("EEC")))
         Do While EEC->(!Eof()) .And. xFilial("EEC") == EEC->EEC_FILIAL .And. Empty(EEC->EEC_DTEMBA)

            UpdInc01("Atualizando Dados do Processo: "+;
                     AllTrim(Transf(EEC->EEC_PREEMB,AVSX3("EEC_PREEMB",AV_PICTURE))))

            EEC->(RecLock("EEC",.f.))
            EEC->EEC_VLNFC := nNextKey
            nNextKey -= 1

            EEC->(DbSkip())
         EndDo

      End Transaction
   EndIf

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : NavioVg()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Tratamentos para atualização dos cadastros de NAvio/Viagem (EE6) de acordo com os Processo
Autor       : PLB - Pedro Baroni 
Data        : 06/09/06          
Revisao     : 
Obs.        :
*/
*----------------*
Function NavioVg()
*----------------*
Local aOrd    := SaveOrd({"EEC","EE6"})  ,;
      aViagem := {}                      ,;
      cFilEEC := xFilial("EEC")          ,;
      cFilEE6 := xFilial("EE6")          ,;
      ni      := 1                       


   UpdSet01(EEC->(LastRec())+1)

   Begin Transaction
     
      EEC->( DBSetOrder(1) )
      EE6->( DBSetOrder(1) )

      EEC->( DBSeek(cFilEEC) )

      Do While !EEC->( EoF() )  .And.  cFilEEC == EEC->EEC_FILIAL

         UpdInc01("Atualizando Dados do Processo: "+;
                  AllTrim(Transf(EEC->EEC_PREEMB,AVSX3("EEC_PREEMB",AV_PICTURE))))

         If !Empty(EEC->EEC_EMBARC)
            If !Empty(EEC->EEC_VIAGEM)
               If !EE6->( DBSeek(cFilEE6+AvKey(EEC->EEC_EMBARC,"EE6_COD")+AvKey(EEC->EEC_VIAGEM,"EE6_VIAGEM")) )
                  If EE6->( DBSeek(cFilEE6+AvKey(EEC->EEC_EMBARC,"EE6_COD")) )
                     aViagem := Array(EE6->( FCount() ))
                     For ni := 1  to  Len(aViagem)
                        aViagem[ni] := EE6->&( FieldName(ni) )
                     Next ni
                     EE6->( RecLock("EE6",.T.) )
                     For ni := 1  to  Len(aViagem)
                        EE6->&( FieldName(ni) ) := aViagem[ni]
                     Next ni
                     EE6->EE6_VIAGEM := AvKey(EEC->EEC_VIAGEM,"EE6_VIAGEM")
                     EE6->( MSUnLock() )
                  Else
                     EE6->( RecLock("EE6",.T.) )
                     EE6->EE6_FILIAL := cFilEE6
                     EE6->EE6_COD    := AvKey(EEC->EEC_EMBARC,"EE6_COD")
                     EE6->EE6_VIAGEM := AvKey(EEC->EEC_VIAGEM,"EE6_VIAGEM")
                     EE6->( MSUnLock() )
                  EndIf
               EndIf
            ElseIf !EE6->( DBSeek(cFilEE6+AvKey(EEC->EEC_EMBARC,"EE6_COD")) )
               EE6->( RecLock("EE6",.T.) )
               EE6->EE6_FILIAL := cFilEE6
               EE6->EE6_COD    := AvKey(EEC->EEC_EMBARC,"EE6_COD")
               EE6->EE6_VIAGEM := "..."
               EE6->( MSUnLock() )
            EndIf
         EndIf

         EEC->(DbSkip())
      EndDo

   End Transaction

   RestOrd(aOrd)

Return .T.

*--------------------------------------------------------------------------------------------------------------*
*  FIM DO PROGRAMA EECUPDATE
*--------------------------------------------------------------------------------------------------------------*