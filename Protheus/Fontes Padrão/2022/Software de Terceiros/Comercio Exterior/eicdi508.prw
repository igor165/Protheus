/*
Funcao      : EICDI508
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funções responsáveis pelo WorkFlow de Previsão de Entrega
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 28/03/2011 15:32
Revisao     : Guilherme Fernandes Pilan - GFP  
Data/Hora   : 27/09/2012 10:00
Objetivos   : Ajuste para que funções sejam scheduladas.
*/
*------------------*
Function EICDI508() 
*------------------*
Return Nil
*----------------------------------*
Function EICWFPVVAR(oEasyWorkFlow)
*----------------------------------*
//Local aOrd := SaveOrd("SW6")
Private cHawb := cDtPrev := ""

WorkQry->(DbGoTop())
Do While WorkQry->(!Eof())
   cHawb    += AllTrim(WorkQry->W6_HAWB) + "<br>"
   cDtPrev  += AllTrim(DtoC(StoD(WorkQry->W6_PRVENTR))) + "<br>"
   WorkQry->(DbSkip())
EndDo

/*
cRet:= oEasyWorkFlow:RetChave()
SW6->(DbSetOrder(1))

If SW6->(DbSeek(cRet)) 
   If !Empty(SW6->W6_PRVENTR)    */
      oEasyWorkFlow:AddVal("EMBNUM"   , cHawb     )  //SW6->W6_HAWB    )
      oEasyWorkFlow:AddVal("DTPRV"    , cDtPrev   )  //SW6->W6_PRVENTR )  
      oEasyWorkFlow:AddVal("DATA"     , dDataBase )
//EndIf
//EndIf                                              

WorkQry->(DbCloseArea())

//RestOrd(aOrd, .T.)
Return Nil

*-------------------------------*
Function EICWFPVENV(oEasyWorkFlow)
*-------------------------------*

RecLock("SW6",.F.)
SW6->W6_ID_PRV := oEasyWorkFlow:RetID()
MsUnlock()

Return Nil

*-------------------------------*
Function EICWFPVCOND()
*-------------------------------*
Local aChaves := {}
Local cQuery := ""

/*
SW6->(DbSetOrder(1))
If SW6->(DbSeek(xFilial("SW6")+M->W6_HAWB))
   If !Empty(M->W6_PRVENTR) .AND. M->W6_PRVENTR < dDataBase .AND. M->W6_PRVENTR <> SW6->W6_PRVENTR 
      aAdd(aChaves,xFilial("SW6")+M->W6_HAWB)
   EndIf
EndIf         
*/
Begin Sequence

cQuery += "Select W6_HAWB, W6_PRVENTR From " + RetSqlName("SW6") + " where "
cQuery += "W6_FILIAL = " + xFilial("SW6") + " and "
cQuery += "W6_PRVENTR <> '' and "
cQuery += "W6_PRVENTR < " + DtoS(dDataBase) + " and "
cQuery += "D_E_L_E_T_ = ''"

cQuery := ChangeQuery(cQuery)
DBUseArea(.T., "TopConn", TCGenQry(,, cQuery), "WorkQry", .T., .T.) 

lRet := !(WorkQry->(Eof()) .AND. WorkQry->(Bof()))   // Caso vazio, retorna .F.

WorkQry->(DbGoTop())
If lRet
   Do While WorkQry->(!Eof())
      aAdd(aChaves,xFilial("SW6")+AvKey(WorkQry->W6_HAWB,"W6_HAWB"))
      WorkQry->(DbSkip())
   EndDo
EndIf
   
End Sequence

Return aChaves