#INCLUDE "HSPAHABT.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.ch"

Function HSPAHABT()

 Private aRotina :=	{	{ OemToAnsi(STR0001),	"AxPesqui"  ,	0, 1},; //"Pesquisar" 
 																				 { OemToAnsi(STR0002),	"HS_RotABT" ,	0,	2},; //"Visualizar" 
 																				 {	OemToAnsi(STR0003),	"HS_RotABT" ,	0,	3},; //"Incluir" 
 																				 { OemToAnsi(STR0004),	"HS_RotABT" ,	0,	4},; //"Alterar" 
 																				 {	OemToAnsi(STR0005),	"HS_RotABT" ,	0,	5}	} //"Excluir" 

 Private cCadastro  := OemToAnsi(STR0006) //"Cadastro de funções Anamnese" 
 Private cSx3CodTab := ""
 Private cCpoSX3    := "M->GHO_CPODES"                             
 Private cRetSX3    := ""      

 
 DbSelectArea("GHO")
 DbSelectArea("GHN") 
 DbSetOrder(1)
 mBrowse( 6, 1, 22, 75,"GHN")

Return()

Function HS_RotABT(cAliasABT, nRegABT, nOpcABT) 

 Local nOpcG  := aRotina[nOpcABT, 4]
 Local nOpA 		:= ""
	Local nGDOpc := IIf( Inclui .Or. Altera, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
	Local nLenGD := 0 
 
	Private aTela := {}, aGets := {}
	Private aHGHO := {}, aCGHO := {}, nUGHO := 0
	Private oDlg, oGHO, oEnchoi
	Private nGHOItem := 0, NGHOOrdCam := 0
	
	RegToMemory("GHN", (nOpcG == 3)) 
	
	If nOpcG <> 3 
	 cSx3CodTab := GHN->GHN_ALIASP
	EndIf 
	
	HS_BDados("GHO", @aHGHO, @aCGHO, @nUGHO, 1,, IIf((nOpcG == 3), Nil, "GHO->GHO_CODFUN == '" + M->GHN_CODFUN + "'"))
	
	nGHOItem   := aScan(aHGHO, {| aVet | AllTrim(aVet[2]) == "GHO_ITEM"})
	NGHOOrdCam := aScan(aHGHO, {| aVet | AllTrim(aVet[2]) == "GHO_ORDCAM"})
	
	If Empty(aCGHO[1, nGHOItem])
  aCGHO[1, nGHOItem] := StrZero(1, Len(GHO->GHO_ITEM))
 EndIf
	
 aSize 			:= MsAdvSize(.T.)
 aObjects := {}
 
 AAdd( aObjects, { 100, 040, .T., .T. } )	
 AAdd( aObjects, { 100, 060, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )
 
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd
  
  oEnchoi := MsMGet():New(cAliasABT,nRegABT,nOpcABT, , , , ,{aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]}, , , , , ,oDlg)
  oEnchoi :oBox:align:= CONTROL_ALIGN_TOP    

  oGHO := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc,,,"+GHO_ITEM",,, 99999,,,, oDlg, aHGHO, aCGHO)
  oGHO:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
  oGHO:bLinhaOk := {|| HS_DuplAC(oGHO:oBrowse:nAt, oGHO:aCols, {nGHOOrdCam})}
  
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {	|| nOpA := 1,;
                                                    	IIF(Obrigatorio(aGets, aTela) .And. oGHO:TudoOk(), oDlg:End(), nOpA := 0)},;  
                                                   		{|| nOpA := 0, oDlg:End()})

 If (nOpA == 1) .And. (nOpcG <> 2)
  Begin Transaction
   FS_GrvABT(nOpcG, oGHO)
   While __lSx8
    ConfirmSx8()
   End   
  End Transaction  
  
 ElseIf nOpcG <>2
  While __lSx8
    RollBackSxe()
  End  
 EndIf
Return()

Static Function FS_GrvABT(nOpcG, oGet)

 Local lAchou := .T.
 Local nFor   := 0

 DbselectArea("GHN")
 DbsetOrder(1) //GHN_FILIAL+GHN_CODFUN
 lAchou := DbSeek(xFilial("GHN") + M->GHN_CODFUN)

 If nOpcG == 3 .Or. nOpcG == 4   // INCLUSAO ou ALTERACAO
  RecLock("GHN", !lAchou)
   HS_GRVCPO("GHN")
   GHN->GHN_FILIAL  := xFilial("GHN")
  MsUnlock()         
  
  DbSelectArea("GHO")
		DbSetOrder(1)//GHO_FILIAL+GHO_CODFUN+GHO_ITEM
		
		For nFor :=1 To Len(oGet:aCols)
			lAchou := DbSeek(xFilial("GHO") + M->GHN_CODFUN + oGet:aCols[nFor, nGHOItem] )
			If oGet:aCols[nFor, Len(oGet:aHeader)+1 ]== .T.  // Se a linha esta deletada na get e achou o kra no banco
				If lAchou .And. nOpcG <> 3
					RecLock("GHO", .F., .F. )
					 DbDelete()
					MsUnlock()
					WriteSx2("GHO")
				EndIf
			Else
				RecLock("GHO", !lAchou )
				 HS_GRVCPO("GHO", oGet:aCols, oGet:aHeader, nFor)
				 GHO->GHO_FILIAL := xFilial("GHO")
				 GHO->GHO_CODFUN := M->GHN_CODFUN
				MsUnlock()
			EndIf
		Next
  
 Else // EXCLUSAO
  
  DbSelectArea("GHO")
		DbSetOrder(1)//GHO_FILIAL+GHO_CODFUN+GHO_ITEM
		DbSeek(xFilial("GHO") + M->GHN_CODFUN)
		While !Eof() .And. GHO->GHO_FILIAL = xFilial("GHO") .And. GHO->GHO_CODFUN = M->GHN_CODFUN
			RecLock("GHO", .F., .F. )
			 DbDelete()
			MsUnlock()
			WriteSx2("GHO")
			DbSkip()
		End
		
  RecLock("GHN", .F., .T.)
   DbDelete()
  MsUnlock()
  WriteSx2("GHN") 
 EndIf

Return()

Function HS_VldABT()

 Local lRet     := .T.
 Local cCampo   := ReadVar()
 Local aArea    := GetArea()
 Local aAreaSx3 := SX3->(GetArea())
 Local aAreaSx2 := SX2->(GetArea())
 
 If cCampo == "M->GHN_ALIASP"
  DbSelectArea("SX2")
  DbSetOrder(1)
  If DbSeek(&(cCampo))
   cSx3CodTab := &(cCampo)
  Else
   HS_MsgInf(STR0007, STR0008, STR0009) //"Tabela inexistente no dicionário de dados"###"Atenção"###"validação de Tabela"
   lRet := .F.
  EndIf
 
 ElseIf cCampo == "M->GHO_CPODES"
  DbSelectArea("SX3")
  DbSetOrder(2)
  If !DbSeek(&(cCampo))
   HS_MsgInf(STR0010, STR0008, STR0011) //"Campo inexistente no dicionário de dados"###"Atenção"###"validação de Campo"
   lRet := .F.
  EndIf
  
 ElseIf cCampo == "M->GHO_ORDCAM"
  &(cCampo) := PadL(AllTrim(&(cCampo)), Len(GHO->GHO_ORDCAM), "0")
 EndIf
 
 RestArea(aAreaSx3)
 RestArea(aArea)
Return(lRet)

Function HS_ABTExec(cCodFun)
 
 Local aArea := {}
 
 DbSelectArea("GHO")
 DbSelectArea("GHN")
 DbSetOrder(1)
 If DbSeek(xFilial("GHN") + cCodFun)
  DbSelectArea(GHN->GHN_ALIASP)
  DbSetOrder(Val(GHN->GHN_ORDEMP))
  If DbSeek(&(GHN->GHN_CHAVEP))
   RecLock(GHN->GHN_ALIASP, .F.)   
    GHO->(DbSetOrder(2))//GHO_FILIAL+GHO_CODFUN+GHO_ORDCAM
    GHO->(DbSeek(xFilial("GHO") + cCodFun))
    While !GHO->(Eof()) .And. GHO->GHO_FILIAL == xFilial("GHO") .AND. GHO->GHO_CODFUN == cCodFun
     &(GHN->GHN_ALIASP + "->" + GHO->GHO_CPODES) :=  &(GHO->GHO_CPOORI)
     GHO->(DbSkip())
    End  
   MsUnlock()
  EndIf
 EndIf

Return()