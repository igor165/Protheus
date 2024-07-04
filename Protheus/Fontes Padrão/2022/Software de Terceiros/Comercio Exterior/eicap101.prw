/*
Funcao      : EICAP101
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow de Cambio
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 25/04/2011 11:08
Revisao     : Guilherme Fernandes Pilan - GFP  
Data/Hora   : 26/09/2012 18:55
Objetivos   : Ajuste para que funções sejam scheduladas.
*/
*------------------*
Function EICAP101() 
*------------------*
Return Nil
*----------------------------------*
Function EICWFCBVAR(oEasyWorkFlow)
*----------------------------------*
//Local aOrd := SaveOrd("SWB")
Private cDtInv := cInv := ""

WorkQry->(DbGoTop())
Do While WorkQry->(!Eof())
   cDtInv += AllTrim(DtoC(StoD(WorkQry->WB_DT_VEN))) + "<br>"
   cInv   += AllTrim(WorkQry->WB_INVOICE) + "<br>"
   WorkQry->(DbSkip())
EndDo

/*
cRet:= oEasyWorkFlow:RetChave()
SWB->(DbSetOrder(1))

If SWB->(DbSeek(cRet))   
   If SWB->WB_DT_VEN < dDataBase .AND. Empty(SWB->WB_CA_DT)  */
      oEasyWorkFlow:AddVal("DTVENC"  , cDtInv     )  //SWB->WB_DT_VEN  )
      oEasyWorkFlow:AddVal("INVOICE" , cInv       )  //SWB->WB_INVOICE )
      oEasyWorkFlow:AddVal("DATA"    , dDataBase  )
//EndIf
//EndIf                                               

WorkQry->(DbCloseArea())

//RestOrd(aOrd, .T.)
Return Nil

*-------------------------------*
Function EICWFCBENV(oEasyWorkFlow)
*-------------------------------*

RecLock("SWB",.F.)
SWB->WB_ID_CB := oEasyWorkFlow:RetID()
MsUnlock()

Return Nil                                                                                     

*-------------------------------*
Function EICWFCBCOND()
*-------------------------------*
Local aChaves := {}
Local cQuery := ""

/*
TRB->(DbGoTop())   
Do While TRB->(!Eof()) .AND. SWB->WB_HAWB == TRB->WB_HAWB
   If TRB->WB_DT_VEN < dDataBase .AND. Empty(TRB->WB_CA_DT)
      aAdd(aChaves,xFilial("SWB")+TRB->(WB_HAWB+WB_PO_DI))
      BREAK
   EndIf
   TRB->(DbSkip())
EndDo
*/
Begin Sequence
   
cQuery += "Select WB_DT_VEN, WB_INVOICE, WB_HAWB, WB_PO_DI From " + RetSqlName("SWB") + " where "
cQuery += "WB_FILIAL = " + xFilial("SWB") + " and "
cQuery += "WB_CA_DT = '' AND WB_DT_VEN <> '' and "
cQuery += "WB_DT_VEN < " + DtoS(dDataBase) + " and "
cQuery += "D_E_L_E_T_ = ''"

cQuery := ChangeQuery(cQuery)
DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WorkQry", .T., .T.) 

lRet := !(WorkQry->(Eof()) .AND. WorkQry->(Bof()))   // Caso vazio, retorna .F.

WorkQry->(DbGoTop())
If lRet
   Do While WorkQry->(!Eof())
      aAdd(aChaves,xFilial("SWB")+AvKey(WorkQry->WB_HAWB,"WB_HAWB")+AvKey(WorkQry->WB_PO_DI,"WB_PO_DI"))
      WorkQry->(DbSkip())
   EndDo
EndIf
   
End Sequence

Return aChaves