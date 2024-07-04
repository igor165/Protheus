/*
Funcao      : EECAF202
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
Function EECAF202() 
*------------------*
Return Nil
*----------------------------------*
Function EECWFCAVAR(oEasyWorkFlow)
*----------------------------------*
//Local aOrd := SaveOrd("EEQ")
Private cProcesso := cDtVenc := cINV := ""

WorkQry->(DbGoTop())
Do While WorkQry->(!Eof())
   cProcesso += AllTrim(WorkQry->EEQ_PREEMB) + "<br>"
   cDtVenc   += AllTrim(DtoC(StoD(WorkQry->EEQ_VCT))) + "<br>"
   cINV      += AllTrim(WorkQry->EEQ_NRINVO) + "<br>"
   WorkQry->(DbSkip())
EndDo

/*
cRet:= oEasyWorkFlow:RetChave()
EEQ->(DbSetOrder(1))

If EEQ->(DbSeek(cRet))
   If Empty(EEQ->EEQ_PGT) .AND. EEQ->EEQ_VCT < dDataBase   */
      oEasyWorkFlow:AddVal("PROCESSO", cProcesso )  //EEQ->EEQ_PREEMB )
      oEasyWorkFlow:AddVal("DTVENC"  , cDtVenc   )  //EEQ->EEQ_VCT    )
      oEasyWorkFlow:AddVal("INVOICE" , cINV      )  //EEQ->EEQ_NRINVO )
      oEasyWorkFlow:AddVal("DATA"    , dDataBase )
// EndIf
//EndIf                                               

WorkQry->(DbCloseArea())

//RestOrd(aOrd, .T.)
Return Nil

*-------------------------------*
Function EECWFCAENV(oEasyWorkFlow)
*-------------------------------*

RecLock("EEQ",.F.)
EEQ->EEQ_ID_CB := oEasyWorkFlow:RetID()
MsUnlock()

Return Nil  

*-------------------------------*
Function EECWFCACOND()
*-------------------------------*
Local aChaves := {}
Local cQuery := ""

/*  // Nopado por GFP - 26/09/2012
TMP->(DbGoTop())
Do While TMP->(!Eof()) .AND. EEQ->EEQ_FILIAL == TMP->EEQ_FILIAL .AND. EEQ->EEQ_PREEMB == TMP->EEQ_PREEMB
   If Empty(TMP->EEQ_PGT) .AND. TMP->EEQ_VCT < dDataBase
      aAdd(aChaves,xFilial("EEQ")+AvKey(TMP->EEQ_PREEMB,"EEQ_PREEMB"))
      BREAK
   EndIf
   TMP->(DbSkip())
EndDo   
*/

Begin Sequence

cQuery += "Select EEQ_PREEMB, EEQ_VCT, EEQ_NRINVO From " + RetSqlName("EEQ") + " where "
cQuery += "EEQ_FILIAL = " + xFilial("EEQ") + " and "
cQuery += "EEQ_PGT = '' AND EEQ_VCT <> '' and "
cQuery += "EEQ_VCT < " + DtoS(dDataBase) + " and "
cQuery += "D_E_L_E_T_ = ''"

cQuery := ChangeQuery(cQuery)
DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WorkQry", .T., .T.) 

lRet := !(WorkQry->(Eof()) .AND. WorkQry->(Bof()))   // Caso vazio, retorna .F.

WorkQry->(DbGoTop())
If lRet
   Do While WorkQry->(!Eof())
      aAdd(aChaves,xFilial("EEQ")+AvKey(WorkQry->EEQ_PREEMB,"EEQ_PREEMB"))
      WorkQry->(DbSkip())
   EndDo
EndIf
  
End Sequence

Return aChaves