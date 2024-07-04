#include "HSPAHM33.CH"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM33  บ Autor ณ Marcelo Jose       บ Data ณ  01/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ LANCAMENTO DE DIETAS DO PACIENTE                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAlteracao ณAntonio Carlos Damaceno                  Data    21/06/06   บฑฑ
ฑฑบ          ณDietas do Paciente nใo pode ficar em branco ao press <ok>   บฑฑ
ฑฑบ          ณ(Eh Obrigat๓rio o cadastro de uma dieta ao pressionar <ok>  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHM33(cAliasM33, nRegM33, nOpcM33)
Local nOpcA     := 0 , nGDOpc  := GD_INSERT + GD_UPDATE + GD_DELETE, nCont := 0
Local nCntFor   := 1 , aCpoEnc := {"GCY_REGATE","GCY_NOME","GCY_QUAINT","GCY_LEIINT","GCY_DTNASC","GCY_CIDINT","GCY_DCIDIN","GCY_IDADE"}
Local aSize     := {},  aObjects := {},  aInfo, aPObjs
Local aAlterOld := {"GDY_COMPLE"}, aAlterNew := {}
Private aTela   := {}, aGets   := {}, nOpcE := 0, nOpcG := 0, pForACols := 0
Private aCGDY	  := {}, aHGDY   := {}, nUGDY := 0, nLGDY := 0, oGDY
Private aVet    :={}

If !HS_ExisDic({{"C","GDY_SEQPRE"}, {"C","GDY_VOLUME"}})
	Return(Nil)
Endif

If !LockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
	HSPVerFiCo("ExecM24",GAV->GAV_REGATE,.T.) 
	Return(Nil)
Else
    HSPGerFiCo("ExecM24",GAV->GAV_REGATE)
EndIf

If GAV->GAV_STATUS == "2"
	HS_MsgInf(STR0013,STR0009,STR0014)  //"Paciente Esta de Alta...Operacao invalida."###"Atencao"###"Dietas Do Paciente"
	UnLockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)    
	HSPDelFiCo("ExecM24",GAV->GAV_REGATE)
	Return(Nil)
EndIf

DbSelectArea("GCY")
DbSetOrder(1)
DbSeek(xFilial("GCY") + GAV->GAV_REGATE)

RegToMemory("GCY", .F.)

HS_BDados("GDY", @aHGDY, @aCGDY, @nUGDY, 1, M->GCY_REGATE, "'" + M->GCY_REGATE + "' == GDY->GDY_REGATE" )
nGDY_SeqPre := aScan(aHGDY, {| aVet | aVet[2] == "GDY_SEQPRE"})
nGDY_Coddie := aScan(aHGDY, {| aVet | aVet[2] == "GDY_CODDIE"})
nGDY_Desc   := aScan(aHGDY, {| aVet | aVet[2] == "GDY_DESC  "})
nGDY_Observ := aScan(aHGDY, {| aVet | aVet[2] == "GDY_OBSERV"})
nGDY_Comple := aScan(aHGDY, {| aVet | aVet[2] == "GDY_COMPLE"})
nGDY_CTROLE := aScan(aHGDY, {| aVet | aVet[2] == "GDY_CTROLE"})


For nCont := 1 To Len(aHGDY)
	IF aHGDY[nCont, 14] == "A"
		aAdd(aAlterNew, aHGDY[nCont, 2])
	EndIf
Next

aSize    := MsAdvSize(.T.)
AAdd( aObjects, {100, 30, .T., .T. } )
AAdd( aObjects, {100, 70, .T., .T. } )
aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObj    := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7], 000 To aSize[6], aSize[5] PIXEL of oMainWnd

EnChoice("GCY", GCY->(RecNo()), nOpcM33,,,, aCpoEnc, { aPObj[1,1], aPObj[1,2], aPObj[1,3], aPObj[1,4] }, {"GCY_CIDINT"}, 3,,,,,, .F.,,,.T.)
oGDY := MsNewGetDados():New( aPObj[2,1], aPObj[2,2], aPObj[2,3], aPObj[2,4], nGDOpc,,,,,,,,,, oDlg, aHGDY, aCGDY)
oGDY:oBrowse:BChange := {|| HS_CtrlBrw(oGDY, nGDY_SeqPre, aAlterNew, aAlterOld)}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
{ || IIf ( ( nOpcA := FS_Verifica() ) == 1, oDlg:End(), )},;
{ || nOpcA := 0, oDlg:End() } )


If nOpcA == 1
	Begin Transaction
	FS_GrvAA8()
	End Transaction
	
	While __lSx8
		ConfirmSx8()
	End
Else
	While __lSx8
		RollBackSx8()
	End
EndIf

UnLockByName("ExecM24" + GAV->GAV_REGATE,.T.,.T.,.F.)
HSPDelFiCo("ExecM24",GAV->GAV_REGATE)

DbSelectArea(cAliasM33)

Return(Nil)

/******************************************************************
Verifica se a dieta do paciente ficara em branco ao pressionar <ok>*/
Static Function FS_Verifica()
 Local nRet := 0

 If oGDY:TudoOk() .And. Obrigatorio(aGets, aTela) .And. !VAZIO(oGDY:aCols[1,nGDY_Coddie])
 	nRet := 1
 ElseIf VAZIO(oGDY:aCols[1,1]) 
  	HS_MsgInf(STR0015, STR0009, STR0014) //"Por favor, informe a dieta do paciente !"//"###"Aten็ใo"###"Dietas do Paciente" 
 Endif
Return nRet


/*****************************************************************************************************************/
Static Function FS_GrvAA8()
 Local   nItem  := 0, cAliasOld := Alias(), lAchou := .F.
 Local   nOrdem :=0
 Local   cchave :=""

 
 RecLock("GCY", .F.)
	HS_GrvCpo("GCY")
 MsUnLock() 
 
 For nItem := 1 To Len(oGDY:aCols) 
 
			If  !Empty(oGDY:aCols[nItem, nGDY_CTROLE])
							nOrdem:=3
						 cChave:= oGDY:aCols[nItem, nGDY_CTROLE]+M->GCY_REGATE+ oGDY:aCols[nItem, nGDY_Coddie]+ oGDY:aCols[nItem, nGDY_SeqPre]						 
	  Else 
 						nOrdem:=1
						 cChave:= M->GCY_REGATE + oGDY:aCols[nItem, nGDY_Coddie] + oGDY:aCols[nItem, nGDY_SeqPre]
		 EndIf
 
			DbSelectArea("GDY")   	
			GDY->(DbSetOrder(nOrdem))    
  
  	lAchou := DbSeek(xFilial("GDY") + cChave)
  
  If ((!Inclui .And. !Altera) .Or. oGDY:aCols[nItem, Len(oGDY:aCols[nItem])]) .And. lAchou /* exclusao */
  	 		RecLock("GDY", .F., .T.)
  	 		DbDelete()
			   MsUnlock()
   			WriteSx2("GDY")
  Else 

    						If !oGDY:aCols[nItem, Len(oGDY:aCols[nItem])]
      							RecLock("GDY", !lAchou)
					      		HS_GRVCPO("GDY", oGDY:aCols, oGDY:aHeader, nItem)
     					 		GDY->GDY_FILIAL := xFilial("GDY")
					      		GDY->GDY_REGATE := M->GCY_REGATE
     					 		GDY->GDY_LOGARQ := HS_LogArq()
						     		MsUnlock()                  
    						Endif 

  EndIf 
 Next
 
 DbSelectArea(cAliasOld)
Return() 
/************************************************************************************************************/
Function FS_ValM33()
 Local lRet := .T. 
 Local aArea:= GetArea()
 Local nCodigoTx := 0
 

 If ReadVar() == "M->GDY_CODDIE"

  nCodigoTx := aScan(oGdy:aCols, {| aVet | aVet[2] == M->GDY_CODDIE .And. Empty(aVet[1])} )
   DbSelectarea("GDY")
   DbSetOrder(1)
   If  !HS_SeekRet("SX5","'TE'+M->GDY_CODDIE",1,.f.,"GDY_DESC","X5_DESCRI")
   EndIf

  If !lRet
   HS_MsgInf(STR0016,STR0009,STR0014)//"###"Aten็ใo"###"Dietas do Paciente"  //"C๓digo da dieta invแlido."
  Endif
  
 ElseIf ReadVar() == "M->GDY_CDFRQA"
  If !HS_SeekRet("GFZ","M->GDY_CDFRQA",1,.f.,"GDY_DSFRQA","GFZ_DSFRQA")
   HS_MsgInf(STR0017, STR0009,STR0014)   //"###"Aten็ใo"###"Dietas do Paciente"  //"Frequ๊ncia invแlida."
   lRet := .F.
  EndIf  
 ElseIf Readvar() == "M->GDY_CODVIA"  
  If !HS_SeekRet("GFW","M->GDY_CODVIA",1,.f.,"GDY_DESVIA","GFW_DESVIA")
   HS_MsgInf(STR0018, STR0009,STR0014)   //"###"Aten็ใo"###"Dietas do Paciente"  //"Via invแlida."
   lRet := .F.
  EndIf
 ElseIf Readvar() == "M->GDY_CDMINF"  
  If !HS_SeekRet("GFY","M->GDY_CDMINF",1,.f.,"GDY_DSMINF","GFY_DSMINF")
   HS_MsgInf(STR0019, STR0009,STR0014)   //"###"Aten็ใo"###"Dietas do Paciente"  //"Bomba infusora invแlida."
   lRet := .F.
  EndIf
 Endif
 
 RestArea(aArea)
Return(lRet)                                           

/***********************************************************************************************************/
Function HS_M33CID( cRegAte, nTipo )

Local cCodCid := POSICIONE("GCY",1,XFILIAL("GCY")+cRegAte,"GCY_CIDINT")
Local cDesCid := Posicione("GAS",1,xFilial("GAS")+cCodCid,"GAS_PATOLO")

Return( IIF(nTipo == 1, cCodCid, cDesCid) ) 

/***********************************************************************************************************/
Function HS_M33Nasc( cRegAte )

Local dNasc := Posicione("GBH",1,xFilial("GBH")+cRegAte, "GBH_DTNASC")

Return(dNasc)
/***********************************************************************************************************/
Function HS_M33Age( cRegAte , dData)

Local dNasc := HS_IniPadr("GBH", 1, cRegAte, "GBH_DTNASC")
Local aAge  := {}
Local cRetAge := ""

Default dData := DDATABASE

aAge := HS_DIFDATA(dNasc, dData)
                                
cRetAge := Str(aAge[1], 3, 0) + "a" + Str(aAge[2], 2, 0) + "m" + Str(aAge[3], 2, 0) + "d"

Return(cRetAge)
