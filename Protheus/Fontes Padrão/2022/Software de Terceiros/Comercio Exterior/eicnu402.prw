#INCLUDE "AVERAGE.CH"
#DEFINE ENTER "<br>"
/*
Funcao      : EICNU402
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow de Solic. Numerario para tomada de decisão.
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 19/01/2016 :: 15:29
*/
*------------------*
Function EICNU402() 
*------------------*
Return Nil
*----------------------------------*
Function EICWFNM2VAR(oEasyWorkFlow) 
*----------------------------------*
Local aOrd := SaveOrd("EIC"), i
Local cDetail := "", cPictValor := AvSx3("EIC_VALOR",AV_PICTURE)
Private aCposWF := {}

cRet:= oEasyWorkFlow:RetChave()
EIC->(DbSetOrder(1))

If EIC->(DbSeek(cRet)) 
    
   oEasyWorkFlow:AddVal("EMBNUM"   , EIC->EIC_HAWB    )
   oEasyWorkFlow:AddVal("DTATUAL"  , dDataBase        )
   
   Do While EIC->(!Eof()) .AND. AllTrim(EIC->EIC_FILIAL+EIC->EIC_HAWB) == AllTrim(cRet)
      If Empty(EIC->EIC_DT_EFE) .AND. Empty(EIC->EIC_ID_APR)
         cDetail += "Despesa : " + AllTrim(EIC->EIC_DESPES) + ENTER
         cDetail += "Valor : "   + AllTrim(TransForm(EIC->EIC_VALOR, cPictValor)) + REPLICATE(ENTER,2)
      EndIf
      EIC->(DbSkip())
   End Do

   oEasyWorkFlow:AddVal("DESPESAS" , cDetail          )

   IF(EasyEntryPoint("EICNU402"),ExecBlock("EICNU402",.F.,.F.,"CPOS_WF"),)
  
   If Len(aCposWF) > 0
      For i := 1 To Len(aCposWF)
         oEasyWorkFlow:AddVal(aCposWF[i][1]  , aCposWF[i][2] )
      Next i
   EndIf   
EndIf                   

RestOrd(aOrd, .T.)
Return Nil

*-------------------------------*
Function EICWFNM2ENV(oEasyWorkFlow)
*-------------------------------*
Local cChave := EIC->EIC_FILIAL+EIC->EIC_HAWB

EIC->(DbSetOrder(1))
If EIC->(DbSeek(cChave)) 
   Do While EIC->(!Eof()) .AND. EIC->EIC_FILIAL+EIC->EIC_HAWB == cChave
      If Empty(EIC->EIC_ID_APR)
         RecLock("EIC",.F.)
         EIC->EIC_ID_APR := oEasyWorkFlow:RetID()
         MsUnlock()
      EndIf
      EIC->(DbSkip())
   EndDo
EndIf

Return Nil

*-------------------------------*
Function EICWFNM2COND(nTipo)
*-------------------------------*
Local aChaves := {}, nRecno

Begin Sequence

If nTipo == 1  
   aAdd(aChaves, xFilial("EIC")+M->EIC_HAWB+M->EIC_DESPES)
ElseIf nTipo == 2
   nRecno := TRB->(Recno())
   TRB->(DbGoTop())
   Do While TRB->(!Eof())
      If Empty(TRB->EIC_ID_APR) .And. Empty(TRB->EIC_DT_EFE)
         aAdd(aChaves, xFilial("EIC")+TRB->EIC_HAWB)//+TRB->EIC_DESPES+DTOS(TRB->EIC_DT_DES)+cValToChar(TRB->EIC_VALOR))
         Exit
      EndIf
      TRB->(DbSkip())
   EndDo
   TRB->(DbGoTo(nRecno))
EndIf

End Sequence

Return aChaves

*-------------------------------*
Function EICWFNM2RET(oProc)
*-------------------------------*
Local aCab := {}
Local bExecFunc := {|| NU400Efetiva()}
oWorkFlow := EasyWorkFlow():New("NM2")
oWorkFlow:LoadChave(oProc:FProcessID)
oWorkFlow:LoadVars()

dbSelectArea("EIC")
EIC->(dbSetOrder(1))
EIC->(dbSeek(oWorkFlow:RetChave()))

aAdd(aCab, {"EIC_HAWB"   , EIC->EIC_HAWB           , Nil})
aAdd(aCab, {"EIC_LIBERA" , oWorkFlow:RetDestinat() , Nil})
aAdd(aCab, {"EIC_ID_APR" , oProc:FProcessID , Nil})

MSExecAuto({|a,b,c| EICNU400(a,b,c)}, aCab, 4, bExecFunc)

Return .T.