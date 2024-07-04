#include "TOPCONN.CH"
/*
Funcao      : EECAP109
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow do Pedido de Exportacão
Autor       : Miguel Prado Gontijo - MPG
Data/Hora   : 19/07/2018 15:10
Revisao     :
Obs.        :
*/
*------------------*
Function EECAP109()                                  
*------------------*
Return Nil
*----------------------------------*
Function EECWFEXVAR(oWorkFlow)
*----------------------------------*
Local aOrdEE7 := SaveOrd("EE7")
Local aOrdEE8 := SaveOrd("EE8")
Local aOrdSA1 := SaveOrd("SA1")
Local aOrdSA2 := SaveOrd("SA2")
Local aOrdSYQ := SaveOrd("SYQ")
Local i
Private aCposWF := {}

   cRet:= oWorkFlow:RetChave()
   If EE7->(DbSetOrder(1),DbSeek(cRet))
      SA1->(DbSetOrder(1),DbSeek(xFilial("SA1")+EE7->EE7_IMPORT+EE7->EE7_IMLOJA))
      SA2->(DbSetOrder(1),DbSeek(xFilial("SA2")+EE7->EE7_FORN+EE7->EE7_FOLOJA))
      SYQ->(DbSetOrder(1),DbSeek(xFilial("SYQ")+EE7->EE7_VIA))

      If cVrs == "1"

         oWorkFlow:AddVal("DATA"    , dtoc(dDataBase))
         oWorkFlow:AddVal("EE7PED"  , Alltrim(EE7->EE7_PEDIDO) )
         oWorkFlow:AddVal("EE7DAT"  , dtoc(EE7->EE7_DTPEDI) )
         oWorkFlow:AddVal("EE7NIM"  , Alltrim(EE7->EE7_IMPORT)+"\"+Alltrim(EE7->EE7_IMLOJA)+" - "+Alltrim(SA1->A1_NOME) )
         oWorkFlow:AddVal("EE7NEX"  , Alltrim(EE7->EE7_FORN)+"\"+Alltrim(EE7->EE7_FOLOJA)+" - "+Alltrim(SA2->A2_NOME) )
         oWorkFlow:AddVal("RESPON"  , Alltrim(EE7->EE7_RESPON) )
         oWorkFlow:AddVal("NMUSER"  , Alltrim(cUserName) )
         oWorkFlow:AddVal("INCOTE"  , EE7->EE7_INCOTE )
         oWorkFlow:AddVal("MODAL"   , SYQ->YQ_COD_DI )
         oWorkFlow:AddVal("ORIGEM"  , EE7->EE7_ORIGEM + " - " + E_FIELD("EE7_ORIGEM","Y9_DESCR",,,2) )
         oWorkFlow:AddVal("DESTINO" , EE7->EE7_DEST + " - " + E_FIELD("EE7_DEST","Y9_DESCR",,,2) )
         oWorkFlow:AddVal("VLRTOT"  , Alltrim(EE7->EE7_MOEDA) + " " + Alltrim(TransForm(EE7->EE7_TOTPED,PesqPict("EE7","EE7_TOTPED"))))
         oWorkFlow:AddVal("PESTOT"  , Alltrim(TransForm(EE7->EE7_PESBRU,PesqPict("EE7","EE7_PESBRU"))) + " " + Alltrim(EE7->EE7_UNIDAD) )

         EE8->( DbSetOrder(1),DbSeek( EE7->EE7_FILIAL+EE7->EE7_PEDIDO ) )    //EE8_FILIAL+EE8_PEDIDO+EE8_SEQUEN+EE8_COD_I
         While EE8->( !EOF() ) .and. EE7->EE7_FILIAL+EE7->EE7_PEDIDO == EE8->EE8_FILIAL+EE8->EE8_PEDIDO
            oWorkFlow:AddVal("i.PRODUTO" , Alltrim(EE8->EE8_COD_I) )
            oWorkFlow:AddVal("i.DESCRI"  , Alltrim(MSMM(EE8->EE8_DESC,TamSx3("EE8_VM_DES")[1],,,3)))
            oWorkFlow:AddVal("i.QUANTI"  , Alltrim(EE8->EE8_UNIDAD) + " " + Alltrim(TransForm(EE8->EE8_SLDINI,PesqPict("EE8","EE8_SLDINI"))) ) 
            oWorkFlow:AddVal("i.PESOPR"  , Alltrim(EE8->EE8_UNPES ) + " " + Alltrim(TransForm(EE8->EE8_PSBRTO,PesqPict("EE8","EE8_PSBRTO"))) )
            oWorkFlow:AddVal("i.PRCTOT"  , Alltrim(EE7->EE7_MOEDA ) + " " + Alltrim(TransForm(EE8->EE8_PRCTOT,PesqPict("EE8","EE8_PRCTOT"))) )
            EE8->( dbskip() )
         EndDo

         IF(EasyEntryPoint("EECAP109"),ExecBlock("EECAP109",.F.,.F.,"CPOS_WF"),)
         
         If Len(aCposWF) > 0
            For i := 1 To Len(aCposWF)
               oWorkFlow:AddVal(aCposWF[i][1]  , aCposWF[i][2] )
            Next i
         EndIf

      Elseif cVrs == "2"

         oProcess:oHTML:ValByName( "DATA"    , dtoc(dDataBase) )
         oProcess:oHTML:ValByName("EE7PED"  , Alltrim(EE7->EE7_PEDIDO) )
         oProcess:oHTML:ValByName("EE7DAT"  , dtoc(EE7->EE7_DTPEDI) )
         oProcess:oHTML:ValByName("EE7NEX"  , Alltrim(EE7->EE7_IMPORT)+"\"+Alltrim(EE7->EE7_IMLOJA)+" - "+Alltrim(SA1->A1_NOME) )
         oProcess:oHTML:ValByName("EE7NIM"  , Alltrim(EE7->EE7_FORN)+"\"+Alltrim(EE7->EE7_FOLOJA)+" - "+Alltrim(SA2->A2_NOME) )
         If !Empty(oWorkFlow:RetVal("RESPON"))
            oProcess:oHTML:ValByName("RESPON"  , Alltrim(EE7->EE7_RESPON) )
         EndIf
         oProcess:oHTML:ValByName("NMUSER"  , Alltrim(cUserName) )
         oProcess:oHTML:ValByName("INCOTE"  , EE7->EE7_INCOTE )
         oProcess:oHTML:ValByName("MODAL"   , SYQ->YQ_COD_DI )
         oProcess:oHTML:ValByName("ORIGEM"  , EE7->EE7_ORIGEM + " - " + E_FIELD("EE7_ORIGEM","Y9_DESCR",,,2) )
         oProcess:oHTML:ValByName("DESTINO" , EE7->EE7_DEST + " - " + E_FIELD("EE7_DEST","Y9_DESCR",,,2) )
         oProcess:oHTML:ValByName("VLRTOT"  , Alltrim(EE7->EE7_MOEDA) + " " + Alltrim(TransForm(EE7->EE7_TOTPED,PesqPict("EE7","EE7_TOTPED"))))
         oProcess:oHTML:ValByName("PESTOT"  , Alltrim(TransForm(EE7->EE7_PESBRU,PesqPict("EE7","EE7_PESBRU"))) + " " + Alltrim(EE7->EE7_UNIDAD) )

         EE8->( DbSetOrder(1),DbSeek( EE7->EE7_FILIAL+EE7->EE7_PEDIDO ) )    //EE8_FILIAL+EE8_PEDIDO+EE8_SEQUEN+EE8_COD_I
         While EE8->( !EOF() ) .and. EE7->EE7_FILIAL+EE7->EE7_PEDIDO == EE8->EE8_FILIAL+EE8->EE8_PEDIDO
            aAdd( oProcess:oHTML:ValByName("i.PRODUTO") , Alltrim(EE8->EE8_COD_I) )
            aAdd( oProcess:oHTML:ValByName("i.DESCRI" ) , Alltrim(MSMM(EE8->EE8_DESC,TamSx3("EE8_VM_DES")[1],,,3)))
            aAdd( oProcess:oHTML:ValByName("i.QUANTI" ) , Alltrim(EE8->EE8_UNIDAD) + "_" + Alltrim(TransForm(EE8->EE8_SLDINI,PesqPict("EE8","EE8_SLDINI"))) )
            aAdd( oProcess:oHTML:ValByName("i.PESOPR" ) , Alltrim(EE8->EE8_UNPES ) + "_" + Alltrim(TransForm(EE8->EE8_PSBRTO,PesqPict("EE8","EE8_PSBRTO"))) )
            aAdd( oProcess:oHTML:ValByName("i.PRCTOT" ) , Alltrim(EE7->EE7_MOEDA ) + "_" + Alltrim(TransForm(EE8->EE8_PRCTOT,PesqPict("EE8","EE8_PRCTOT"))) )
            EE8->( dbskip() )
         EndDo

      EndIf

   EndIf
   
RestOrd(aOrdEE7, .T.)
RestOrd(aOrdEE8, .T.)
RestOrd(aOrdSA1, .T.)
RestOrd(aOrdSA2, .T.)
RestOrd(aOrdSYQ, .T.)
Return Nil

*-------------------------------*
Function EECWFEXENV(oWorkFlow)
*-------------------------------*

RecLock("EE7",.F.)
EE7->EE7_ID_AP := oWorkFlow:RetID()
EE7->EE7_DTSLCR := dDataBase //Muda data da solicitação de crédito para data atual (pois o email foi enviado)
MsUnlock()

Return Nil