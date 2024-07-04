#Include 'Protheus.ch'
#INCLUDE "AVERAGE.ch"
#INCLUDE "EFFEX103.CH"

/*
Programa        : EFFEX103.PRW
Objetivo        : Lançamentos para Contabilizações 
Autor           : Guilherme Fernandes Pilan - GFP
Data/Hora       : 13/12/2011
*/
Function EFFEX103()

Processa({|| EFFEXCONT()})

Return Nil

/*
Programa        : EFFEXCONT()
Objetivo        : Lançamentos para Contabilizações
Autor           : Guilherme Fernandes Pilan - GFP
Data/Hora       : 13/12/2011
*/
Static Function EFFEXCONT()
Local dDtFim
Local cChaveEF1 := xFilial("EF1")/*+"E"*/, cChaveECE := ""
Local lRet := .T.
Local i := 0
Local aContraECE := {}
Private dDataCont//RMD - 28/11/14
Static cMsgFinal := ""            //NCF - 15/09/2015 - Melhoria no log final da contabilização
Static aContabOK := {}
Static aContabNOK:= {}     

Begin Sequence

   If !Pergunte("EX103",.T.)
      Break
   Endif

   dDtFim:= mv_par01
   dDataApu := If(Type('dDataApu') == "D",dDataApu,dDtFim)  // NCF - 15/08/2014 - Ajuste para uso no Método ""BuscaProvisoes"
   dDataCont := dDtFim//RMD - 28/11/14 - Variável private para considerar a data no Adapter de integração das contabilizações
      
   SYE->(DbSetOrder(1))
   If !SYE->(DbSeek(xFilial()+DTOS(dDtFim)))
      MsgAlert(STR0001,STR0002) //"Sistema não possui Cotação de Moeda cadastrada para a data informada!" ### "Aviso"
      Break
   EndIf

   ProcRegua(EF1->(lastRec()))
   
   EX103GrvMsg(,,.T.)
   
   If !Empty(dDtFim)
      EF1->(DbSetOrder(1)) //EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT+EF3_CODEVE+EF3_PARC+EF3_INVOIC+EF3_INVIMP+EF3_LINHA
      If EF1->(DbSeek(cChaveEF1))
         Do While EF1->(!Eof() .AND. Left(&(IndexKey()),Len(cChaveEF1)) == cChaveEF1) .And. lRet
            //If !Empty(EF1->EF1_DT_JUR) .And. EF1->EF1_DT_CON <= dDtFim //RMD - 27/11/14 - Verifica se a data do contrato não é superior à data final.
            //MFR OSSME-2217 30/01/2019
            If !Empty(EF1->EF1_DT_JUR) .And. EF1->EF1_DT_JUR <= dDtFim
			         IncProc(STR0003+EF1->EF1_CONTRA)  //"Contabilizando contrato: "
               oContra := AvEFFContra():LoadEF1()
               oContra:ApropriaJurosVC(dDtFim)
               If HasEvent2Integ()
                  lRet := AvStAction("075") //Integracao de lote contábil - Contratos Ativos 
               EndIf
			      EndIf
            EF1->(dbSkip())
         EndDo
       EndIf  
  
      SX5->(DbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE
      If SX5->(DbSeek(xFilial("SX5")+"CJ"+"FI"))
         Do While SX5->(!Eof()) .AND. SX5->X5_TABELA == "CJ" .AND. Left(SX5->X5_CHAVE,2) == "FI"
            cChaveECE := xFilial("ECE")+AvKey(SX5->X5_CHAVE, "ECE_TPMODU")+AvKey("","ECE_NR_CON")
  
            ECE->(DbSetOrder(2)) //ECE_FILIAL+ECE_TPMODU+ECE_NR_CON
            If ECE->(DbSeek(cChaveECE))
               Do While ECE->(!Eof()) .AND. ECE->(ECE_FILIAL+ECE_TPMODU+ECE_NR_CON) == cChaveECE
                  If aScan(aContraECE, {|x| x[1] == ECE->ECE_FILIAL .AND.;
            	                               x[2] == ECE->ECE_TPMODU .AND.;
             	                               x[3] == ECE->ECE_CONTRA .AND.;
         	                                   x[4] == ECE->ECE_BANCO  .AND.;
         	                                   x[5] == ECE->ECE_PRACA  .AND.;
         	                                   x[6] == ECE->ECE_SEQCNT }) == 0
                     aAdd(aContraECE, {ECE->ECE_FILIAL,ECE->ECE_TPMODU,ECE->ECE_CONTRA,ECE->ECE_BANCO, ECE->ECE_PRACA, ECE->ECE_SEQCNT})
                  EndIf
                  ECE->(DbSkip())
               EndDo
            EndIf
            SX5->(DbSkip())
         EndDo
      EndIf
      
      For i := 1 To Len(aContraECE)
         ECE->(DbSetOrder(5))  // ECE_FILIAL+ECE_TPMODU+ECE_CONTRA+ECE_BANCO+ECE_PRACA+ECE_SEQCNT+ECE_NR_CON
         If ECE->(DbSeek(aContraECE[i][1]+aContraECE[i][2]+aContraECE[i][3]+aContraECE[i][4]+aContraECE[i][5]+aContraECE[i][6]))
            lRet := AvStAction("080") //Integracao de lote contábil - Contratos Excluidos
         EndIf
      Next i
      
      If lRet
         If Empty(aContabNOK)
		    MsgInfo(STR0004,STR0005)  // "Contratos contabilizados com sucesso!" ### "Conclusão"
		 Else                                                                                                 //NCF - 15/09/2015 - Melhoria no log final da contabilização
		    cMsgFinal += "CONTRATOS NÃO CONTABILIZADOS ("+ cValtoChar(Len(aContabNOK)) +"):" + CHR(13)+CHR(10)
		    cMsgFinal += "-------------------------------------" + CHR(13)+CHR(10)
		    AEval( aContabNOK, {|x| cMsgFinal += x + CHR(13)+CHR(10) },,)
		    cMsgFinal += CHR(13)+CHR(10) + "CONTRATOS CONTABILIZADOS COM SUCESSO ("+ cValtoChar(Len(aContabOK)) +"):" + CHR(13)+CHR(10)
		    cMsgFinal += "---------------------------------------------" + CHR(13)+CHR(10)
		    AEval( aContabOK, {|x| cMsgFinal += x + CHR(13)+CHR(10) },,)
		    AVGetSvLog("LOG DA CONTABILIZAÇÃO",cMsgFinal)
		 EndIf
      Else
         MsgAlert(STR0006,STR0002) //"Não existem contratos para contabilização nesta data." ### "Aviso"
      EndIf
   EndIf
   
If(EasyEntryPoint("EFFEX103"),ExecBlock("EFFEX103",.F.,.F.,"FINAL_CONT"),) //LRS - 03/10/2016
   
End Sequence

Return Nil

Static Function HasEvent2Integ()
Local aOrd := SaveOrd("EF3")
Local lRet := .F.

   EF3->(DbSetOrder(1)) //EF3_FILIAL+EF3_TPMODU+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+EF3_SEQCNT
   lRet := EF3->(DbSeek(xFilial("EF3")+EF1->(EF1_TPMODU+EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+EF1_SEQCNT)))

Restord(aOrd, .T.)
Return lRet


/*
Programa        : EX103GrvMsg()
Objetivo        : Controla Mensagem final da contabilização
Autor           : Nilson César
Data/Hora       : 15/09/2015
*/
Function EX103GrvMsg(lOk,cContrato,lClear)

Default lClear    := .F.
Default lOk       := .T.
Default cContrato := ""

If lClear
   aContabOK  := {}
   aContabNOK := {}   
EndIf

If lOk
   If !Empty(cContrato) .And. aScan(aContabOK,EF1->EF1_CONTRA) == 0
      aAdd(aContabOK, cContrato)
   EndIf
Else
   If !Empty(cContrato) .And. aScan(aContabNOK,EF1->EF1_CONTRA) == 0
      aAdd(aContabNOK, cContrato)
   EndIf   
EndIf

Return

