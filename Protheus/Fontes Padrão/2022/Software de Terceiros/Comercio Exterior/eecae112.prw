/*
Funcao      : EECAE112
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow de Embarque
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 30/03/2011 17:17
Revisao     :
Obs.        :
*/
*------------------*
Function EECAE112() 
*------------------*
Return Nil
*----------------------------------*
Function EECWFEMVAR(oWorkFlow)
*----------------------------------*
Local aOrdEEC := SaveOrd("EEC")
Local aOrdEE9 := SaveOrd("EE9")
Local aOrdEE6 := SaveOrd("EE6")
Local aOrdSA1 := SaveOrd("SA1")
Local aOrdSA2 := SaveOrd("SA2")
Local aOrdSYQ := SaveOrd("SYQ")
Local i
Private aCposWF := {}  // GFP - 03/09/2013

cRet:= oWorkFlow:RetChave()
If EEC->(DbSetOrder(1),DbSeek(cRet)) 
      SA1->(DbSetOrder(1),DbSeek(xFilial("SA1")+EEC->EEC_IMPORT+EEC->EEC_IMLOJA))
      SA2->(DbSetOrder(1),DbSeek(xFilial("SA2")+EEC->EEC_FORN+EEC->EEC_FOLOJA))
      SYQ->(DbSetOrder(1),DbSeek(xFilial("SYQ")+EEC->EEC_VIA))
      EE6->(DbSetOrder(1),DbSeek(xFilial("EE6")+EEC->EEC_EMBARC+EEC->EEC_VIAGEM )) //EE6_FILIAL+EE6_COD+EE6_VIAGEM

      If cVrs == "1"

         oWorkFlow:AddVal("DATA"    , dtoc(dDataBase))
         oWorkFlow:AddVal("EECEMB"  , Alltrim(EEC->EEC_PREEMB) )
         oWorkFlow:AddVal("EECDAT"  , dtoc(EEC->EEC_DTPROC) )
         oWorkFlow:AddVal("EECNEX"  , Alltrim(EEC->EEC_IMPORT)+"\"+Alltrim(EEC->EEC_IMLOJA)+" - "+Alltrim(SA1->A1_NOME) )
         oWorkFlow:AddVal("EECNIM"  , Alltrim(EEC->EEC_FORN)+"\"+Alltrim(EEC->EEC_FOLOJA)+" - "+Alltrim(SA2->A2_NOME) )
         oWorkFlow:AddVal("RESPON"  , Alltrim(EEC->EEC_RESPON) )
         oWorkFlow:AddVal("NMUSER"  , Alltrim(cUserName) )
         oWorkFlow:AddVal("INCOTE"  , EEC->EEC_INCOTE )
         oWorkFlow:AddVal("MODAL"   , SYQ->YQ_COD_DI )
         oWorkFlow:AddVal("ORIGEM"  , EEC->EEC_ORIGEM + " - " + E_FIELD("EEC_ORIGEM","Y9_DESCR",,,2) )
         oWorkFlow:AddVal("DESTINO" , EEC->EEC_DEST + " - " + E_FIELD("EEC_DEST","Y9_DESCR",,,2) )
         oWorkFlow:AddVal("NNAVIO"  , Alltrim(EEC->EEC_EMBARC) +" "+Alltrim(EE6->EE6_NOME) )
         oWorkFlow:AddVal("VIAGEM"  , Alltrim( EEC_VIAGEM ) )
         oWorkFlow:AddVal("DTETA"   , DtoC( EEC_ETA ) )
         oWorkFlow:AddVal("DTEDT"   , DtoC( EEC_ETD ) )
         oWorkFlow:AddVal("VLRTOT"  , Alltrim(EEC->EEC_MOEDA) + " " + Alltrim(TransForm(EEC->EEC_TOTPED,PesqPict("EEC","EEC_TOTPED")))  )
         oWorkFlow:AddVal("PESTOT"  , Alltrim(TransForm(EEC->EEC_PESBRU,PesqPict("EEC","EEC_PESBRU"))) + " " + Alltrim(EEC->EEC_UNIDAD) )

         EE9->( DbSetOrder(3),DbSeek( EEC->EEC_FILIAL+EEC->EEC_PREEMB ) )    // EE9_FILIAL+EE9_PREEMB+EE9_SEQEMB
         While EE9->( !EOF() ) .and. EEC->EEC_FILIAL+EEC->EEC_PREEMB == EE9->EE9_FILIAL+EE9->EE9_PREEMB
            oWorkFlow:AddVal("i.PRODUTO" , Alltrim(EE9->EE9_COD_I) )
            oWorkFlow:AddVal("i.DESCRI"  , Alltrim(MSMM(EE9->EE9_DESC,TamSx3("EE9_VM_DES")[1],,,3)))
            oWorkFlow:AddVal("i.QUANTI"  , Alltrim(EE9->EE9_UNIDAD) + " " + Alltrim(TransForm(EE9->EE9_SLDINI,PesqPict("EE9","EE9_SLDINI"))) )
            oWorkFlow:AddVal("i.PESOPR"  , Alltrim(EE9->EE9_UNPES ) + " " + Alltrim(TransForm(EE9->EE9_PSBRTO,PesqPict("EE9","EE9_PSBRTO"))) )
            oWorkFlow:AddVal("i.PRCTOT"  , Alltrim(EEC->EEC_MOEDA ) + " " + Alltrim(TransForm(EE9->EE9_PRCTOT,PesqPict("EE9","EE9_PRCTOT"))) )
            oWorkFlow:AddVal("i.PEDIDO"  , Alltrim(EE9->EE9_PEDIDO) )
            EE9->( dbskip() )
         EndDo

         IF(EasyEntryPoint("EECAE112"),ExecBlock("EECAE112",.F.,.F.,"CPOS_WF"),)   // GFP - 03/09/2013
         
         If Len(aCposWF) > 0
            For i := 1 To Len(aCposWF)
               oWorkFlow:AddVal(aCposWF[i][1]  , aCposWF[i][2] )
            Next i
         EndIf

      Elseif cVrs == "2"

         oProcess:oHTML:ValByName("DATA"    , dtoc(dDataBase) )
         oProcess:oHTML:ValByName("EECEMB"  , Alltrim(EEC->EEC_PREEMB) )
         oProcess:oHTML:ValByName("EECDAT"  , dtoc(EEC->EEC_DTPROC) )
         oProcess:oHTML:ValByName("EECNEX"  , Alltrim(EEC->EEC_IMPORT)+"\"+Alltrim(EEC->EEC_IMLOJA)+" - "+Alltrim(SA1->A1_NOME) )
         oProcess:oHTML:ValByName("EECNIM"  , Alltrim(EEC->EEC_FORN)+"\"+Alltrim(EEC->EEC_FOLOJA)+" - "+Alltrim(SA2->A2_NOME) )
         If !Empty(oWorkFlow:RetVal("RESPON"))
            oProcess:oHTML:ValByName("RESPON"  , Alltrim(EEC->EEC_RESPON) )
         EndIf
         oProcess:oHTML:ValByName("NMUSER"  , Alltrim(cUserName) )
         oProcess:oHTML:ValByName("INCOTE"  , EEC->EEC_INCOTE )
         oProcess:oHTML:ValByName("MODAL"   , SYQ->YQ_COD_DI )
         oProcess:oHTML:ValByName("ORIGEM"  , EEC->EEC_ORIGEM + " - " + E_FIELD("EEC_ORIGEM","Y9_DESCR",,,2) )
         oProcess:oHTML:ValByName("DESTINO" , EEC->EEC_DEST + " - " + E_FIELD("EEC_DEST","Y9_DESCR",,,2) )
         oProcess:oHTML:ValByName("NNAVIO"  , Alltrim(EEC->EEC_EMBARC) +" "+Alltrim(EE6->EE6_NOME) )
         oProcess:oHTML:ValByName("VIAGEM"  , Alltrim( EEC_VIAGEM ) )
         oProcess:oHTML:ValByName("DTETA"   , DtoC( EEC_ETA ) )
         oProcess:oHTML:ValByName("DTEDT"   , DtoC( EEC_ETD ) )
         oProcess:oHTML:ValByName("VLRTOT"  , Alltrim(EEC->EEC_MOEDA) + " " + Alltrim(TransForm(EEC->EEC_TOTPED,PesqPict("EEC","EEC_TOTPED")))  )
         oProcess:oHTML:ValByName("PESTOT"  , Alltrim(TransForm(EEC->EEC_PESBRU,PesqPict("EEC","EEC_PESBRU"))) + " " + Alltrim(EEC->EEC_UNIDAD) )

         EE9->( DbSetOrder(3),DbSeek( EEC->EEC_FILIAL+EEC->EEC_PREEMB ) )    // EE9_FILIAL+EE9_PREEMB+EE9_SEQEMB
         While EE9->( !EOF() ) .and. EEC->EEC_FILIAL+EEC->EEC_PREEMB == EE9->EE9_FILIAL+EE9->EE9_PREEMB
            aAdd( oProcess:oHTML:ValByName("i.PRODUTO" ) , Alltrim(EE9->EE9_COD_I) )
            aAdd( oProcess:oHTML:ValByName("i.DESCRI"  ) , Alltrim(MSMM(EE9->EE9_DESC,TamSx3("EE9_VM_DES")[1],,,3)))
            aAdd( oProcess:oHTML:ValByName("i.QUANTI"  ) , Alltrim(EE9->EE9_UNIDAD) + "_" + Alltrim(TransForm(EE9->EE9_SLDINI,PesqPict("EE9","EE9_SLDINI"))) )
            aAdd( oProcess:oHTML:ValByName("i.PESOPR"  ) , Alltrim(EE9->EE9_UNPES ) + "_" + Alltrim(TransForm(EE9->EE9_PSBRTO,PesqPict("EE9","EE9_PSBRTO"))) )
            aAdd( oProcess:oHTML:ValByName("i.PRCTOT"  ) , Alltrim(EEC->EEC_MOEDA ) + "_" + Alltrim(TransForm(EE9->EE9_PRCTOT,PesqPict("EE9","EE9_PRCTOT"))) )
            aAdd( oProcess:oHTML:ValByName("i.PEDIDO"  ) , Alltrim(EE9->EE9_PEDIDO) )
            EE9->( dbskip() )
         EndDo

      EndIf

EndIf

RestOrd(aOrdEEC, .T.)
RestOrd(aOrdEE9, .T.)
RestOrd(aOrdEE6, .T.)
RestOrd(aOrdSA1, .T.)
RestOrd(aOrdSA2, .T.)
RestOrd(aOrdSYQ, .T.)
Return Nil

*-------------------------------*
Function EECWFEMENV(oWorkFlow)
*-------------------------------*

RecLock("EEC",.F.)
EEC->EEC_ID_EMB := oWorkFlow:RetID()
MsUnlock()

Return Nil