#DEFINE ENTER CHR(13)+CHR(10)

/*
Funcao      : EICSI401
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow da SI
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 17/03/2011 16:44
Revisao     :
Obs.        :
*/
*------------------*
Function EICSI401() 
*------------------*
Return Nil
*----------------------------------*
Function EICWFSIVAR(oEasyWorkFlow)
*----------------------------------*
Local aOrd := SaveOrd("SW0"), i
Private cDetail := ""
Private aCposWF := {}  // GFP - 03/09/2013

cRet:= oEasyWorkFlow:RetChave()
DbSelectArea("SW1")
SW0->(DbSetOrder(1))

If SW0->(DbSeek(cRet))
   oEasyWorkFlow:AddVal("SINUM" , SW0->W0__NUM  )
   oEasyWorkFlow:AddVal("DATA"  , dDataBase     )


   SW1->(DbSetOrder(1))
   SW1->(DbSeek(xFilial("SW1")+SW0->W0__CC+SW0->W0__NUM))
     
   Do While SW1->(!Eof()) .AND.;
            SW1->W1_FILIAL == xFilial("SW1") .AND.;
            SW1->W1_SI_NUM == SW0->W0__NUM   
            
      cDetail += "Código Item: " + SW1->W1_COD_I + "<br>"
      cDetail += "Quantidade: "  + AllTrim(STR(SW1->W1_QTDE)) + "<br><br>"

      SW1->(DbSkip())
   End Do
   
   oEasyWorkFlow:AddVal("ITENS"  , cDetail )
   
   IF(EasyEntryPoint("EICSI401"),ExecBlock("EICSI401",.F.,.F.,"CPOS_WF"),)   // GFP - 03/09/2013
   
   If Len(aCposWF) > 0
      For i := 1 To Len(aCposWF)
         oEasyWorkFlow:AddVal(aCposWF[i][1]  , aCposWF[i][2] )
      Next i
   EndIf                         

EndIf

RestOrd(aOrd, .T.)
Return Nil

*-------------------------------*
Function EICWFSIENV(oEasyWorkFlow)
*-------------------------------*

RecLock("SW0",.F.)
SW0->W0_ID := oEasyWorkFlow:RetID()
MsUnlock()

Return Nil