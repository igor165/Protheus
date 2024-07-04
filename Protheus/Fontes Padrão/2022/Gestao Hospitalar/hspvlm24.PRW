#INCLUDE "hspvlm24.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

Function HS_VldMM()
 Local lRet      := .T.
 Local cCampo    := ReadVar()
 Local cCodCrm   := "", cCodLoc := "", cVldCrm := "", cVldUsr := "", cOldReadVar := ""
 Local lMVAtCrMd := GetMV("MV_ATCRMD") == "S"
 Local aAreaMM   := &(cAliasMM)->(GetArea())
  
 cCodLoc := HS_RetSet(cAliasMM, nMMSeqDes, nMMCodLoc, cLctCodLoc, oGDMM:nAt, oGDMM:aCols)
 cCodCrm := HS_RetCrm(oGDMM:aCols, oGDMM:nAt, nMMCodCrm, M->GCY_CODCRM)

 If cCampo == "M->" + cAliasMM + "_QTDDES"
  lRet := HS_VQtdMM(&cCampo).And. IIf(!Empty(&__cRCodDes),HS_VMatMed(cGczCodPla,&__cRCodDes,cGcsArmSet,,,{.F.,&cCampo},/*lMsg*/,/*dVigencia*/, cCodLoc, cCodCrm, oGDMM:aCols[oGDMM:nAt, nMMHorDes], {cGcyAtendi, M->GCY_CARATE}),.T.)
 ElseIf cCampo == "M->"+ cAliasMM + "_CODDES"
  
  lRet := HS_VMatMed(cGczCodPla, &cCampo, cGcsArmSet,,, {.F., __MMQtdDe},/*lMsg*/,/*dVigencia*/, cCodLoc, cCodCrm, oGDMM:aCols[oGDMM:nAt, nMMHorDes], {cGcyAtendi, M->GCY_CARATE})

  If lRet .And. !Empty(cCodCrm)
   cVldCrm := HS_CfgSx3(cAliasMM + "_CODCRM")[SX3->(FieldPos("X3_VALID"))]
   cVldUsr := HS_CfgSx3(cAliasMM + "_CODCRM")[SX3->(FieldPos("X3_VLDUSER"))]
   
   cOldReadVar := ReadVar()
   __ReadVar := "M->" + cAliasMM + "_CODCRM"
   &("M->" + cAliasMM + "_CODCRM") := cCodCrm
   lRet := IIf(!Empty(cVldCrm), &(cVldCrm), .T.) .And. IIf(!Empty(cVldUsr), &(cVldUsr), .T.)
   __ReadVar := cOldReadVar
  EndIf
  
 EndIf
 
 
Return(lRet)     


Function HS_VldTISS()
Private lRet := .T.

 If ReadVar() == "M->GCZ_TEDVLR" .and. !Empty(oGDGcz:aCols[oGDGcz:nAt, nGCZTedUnd]) .and. Empty(M->GCZ_TEDVLR)
  	HS_MsgInf(STR0001, STR0002, STR0003)  //"Unidade de tempo de evolução da doença não deve estar preenchida!"###"Atenção"###"Guias de atendimento"
   oGDGcz:aCols[oGDGcz:nAt, nGCZTedUnd]:=""			
			lRet:=.F.	
 EndIf

 If ReadVar() == "M->GCZ_TEDUND"
  If !Empty(oGDGcz:aCols[oGDGcz:nAt, nGCZTedVlr]) .and. Empty(M->GCZ_TEDUND)
  	HS_MsgInf(STR0004, STR0002, STR0003)  //"Unidade de tempo de evolução da doença deve estar preenchido!"###"Atenção"###"Guias de atendimento"
			lRet:=.F.
		EndIf	
  If !Empty(M->GCZ_TEDUND) .and. oGDGcz:aCols[oGDGcz:nAt, nGCZTedVlr] == 0
   	HS_MsgInf(STR0001, STR0002, STR0003)  //"Unidade de tempo de evolução da doença não deve estar preenchida!"###"Atenção"###"Guias de atendimento"
    M->GCZ_TEDUND := "" 
	  	lRet:=.F.
  EndIf
 EndIf                            
Return(lRet)

Function HS_RetCrm(aCols, nAt, nGDPosCrm, cCRMDef)
 Local cCodCrm   := ""
 Local lMVAtCrMd := GetMV("MV_ATCRMD") == "S"
 
 Default nGDPosCrm := 0
 
 If nGDPosCrm > 0 .And. !Empty(aCols[nAt, nGDPosCrm])
  cCodCrm := aCols[nAt, nGDPosCrm]
 ElseIf lMVAtCrMd .And. !Empty(cCRMDef)
  cCodCrm := cCRMDef
 EndIf 
 
Return(cCodCrm)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_VExtMedºAutor  ³Luiz Pereira S. Jr. º Data ³  05/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o extrato médico já foi gerado e retorna .T. ou º±±
±±º          ³.F.                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_VExtMed(cAlias, cSeqDes)
 Local aArea := GetArea()
 Local aAliasArea := &(cAlias)->(GetArea())
 Local lRet := .F.
 
 DbSelectArea(cAlias)
 DbSetOrder(1) //GD5_FILIAL+GD5_SEQDES ### GD6_FILIAL+GD6_SEQDES ### GD7_FILIAL+GD7_SEQDES ### GE5_FILIAL+GE5_SEQDES ### GE6_FILIAL+GE6_SEQDES ### GE7_FILIAL+GE7_SEQDES
 If DbSeek(xFilial(cAlias) + cSeqDes)
  lRet := !Empty(&(cAlias + "_NREXTM"))
 EndIf
 
 RestArea(aAliasArea)
 RestArea(aArea)
Return(lRet)
