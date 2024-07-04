#Include "Protheus.ch"
#Include "ATFA320.ch"

Static lATF320Aut
Static aAutoCab
Static aAutoItens

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ATFA320  º Autor ³ Felipe C. Seolin   º Data ³  16/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Controle de Bens de Terceiros				              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA320				                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFA320(cAlias,nReg,nOpc,nOpcAuto,xAutoCab,xAutoItens)
Local alArea		:= GetArea()

Private aRotina		:= MenuDef()
Private cCadastro	:= STR0001	//"Controle de bens de terceiros"

Default	cAlias		:= "SNO"
Default	nReg		:= 0
Default	nOpc		:= 3
Default nOpcAuto	:= 3
Default xAutoCab	:= {}
Default xAutoItens	:= {}

lATF320Aut			:= IIF(Len(xAutoCab)>0,.T.,.F.)

dbSelectArea("SN1")
dbSelectArea("SNO")

IF lATF320Aut .And. nOpcAuto >= 3 .And. nOpcAuto <= 5 //somente inclusao/alt/exclusao pode ser feito via rotina automatica
	aAutoCab	:= aClone(xAutoCab)
	aAutoItens	:= aClone(xAutoItens)
	//rotina automatica soh faz para inclusao / alteracao ou exclusao
	If (nOpcAuto == 3 .And. Len(aAutoCab) > 0 .And. Len(aAutoItens) > 0 ) .OR. nOpcAuto == 4 .OR. nOpcAuto == 5
		MBrowseAuto(nOpcAuto,aAutoCab,"SNO")
	EndIf
ELSE
	mBrowse(6,1,22,75,"SNO",,,,,,)
ENDIF
RestArea(alArea)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ATF320Cadº Autor ³ Felipe C. Seolin   º Data ³  16/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro de Bens de Terceiros				              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA320				                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATF320Cad(cAlias,nReg,nOpc,xAutoCab,xAutoItens,lDireto)
Local olBtn		:= FWButtonBar():New()
Local nlOpcao		:= 0
Local alDms		:= FWGetDialogSize(oMainWnd)
Local alCpoEnch	:= {"NO_CODIGO","NO_CBASE","NO_ITEM","NO_FORNEC","NO_LOJA","NO_TIPCES","NOUSER"}
Local alEdtEnch	:= {}
Local clCpoGD		:= "NO_SEQ,NO_STATUS,NO_VIGINI,NO_VIGFIM,NO_CONTATO"
Local clNoCpoGD	:= "NO_CODIGO,NO_CBASE,NO_ITEM,NO_FORNEC,NO_LOJA,NO_TIPCES"
Local alEdtGD		:= {}
Local llSave		:= .F.
Local nPosBase		:= 0
Local nPosItem		:= 0
Local nMaxCols		:= 0   
Local cCodOri		:= ""
Local aAreaSN1		:= SN1->(GetArea())
Local aAreaSX3 
Local nX
Local cTitulo     := ""
Local lRet         := .T.
Local aAuxEdtGD	:= {}

Private oFWLayer	:= FWLayer():New()
Private aTela[0][0]
Private aGets[0]
Private oGetSNO
Private aRotina		:= MenuDef()

Default xAutoCab	:= {}
Default xAutoItens	:= {}
Default lDireto		:= .F.

cTitulo := STR0001+ " - " + aRotina[nOpc][1]

If !lDireto .And. SN0->(!EOF())
	lRet := AF320VLINI(nOpc,SNO->NO_CODIGO,SNO->NO_CBASE,SNO->NO_ITEM)
EndIf

If lRet

	IF lDireto
		aAutoCab	:= aClone(xAutoCab)
		aAutoItens	:= aClone(xAutoItens)
		nPosBase	:= aScan(aAutoCab,{|x| x[1] == "NO_CBASE"})
		nPosItem	:= aScan(aAutoCab,{|x| x[1] == "NO_ITEM"})
		nPosFornece	:= aScan(aAutoCab,{|x| x[1] == "NO_FORNEC"})
		nPosLojaFor	:= aScan(aAutoCab,{|x| x[1] == "NO_LOJA"})
	ENDIF

	If nOpc == 2 // Visualizar
		RegToMemory("SNO",.F.)
	ElseIf nOpc == 3 //Incluir
		If ValType(lATF320Aut) != "U" .And. lATF320Aut .And. !lDireto  //se for rotina automatica chamada pela rotina principal
			For nX := 1 TO Len(aAutoCab)
				_SetNamedPrvt(Trim(aAutoCab[nX,1]), aAutoCab[nX,2], ProcName(2))
			Next
		Else
			RegToMemory("SNO",.T.)
			nlOpcao		:= GD_UPDATE
			alEdtEnch	:= {"NO_CBASE","NO_ITEM","NO_FORNEC","NO_LOJA","NO_TIPCES"}
			alEdtGD		:= {"NO_STATUS","NO_VIGINI","NO_VIGFIM","NO_CONTATO"}
			IF lDireto
				alEdtEnch	:= {"NO_FORNEC","NO_LOJA","NO_TIPCES"}
				M->NO_CBASE 	:= aAutoCab[nPosBase][2]
				M->NO_ITEM		:= aAutoCab[nPosItem][2]
				M->NO_FORNEC	:= aAutoCab[nPosFornece][2]
				M->NO_LOJA		:= aAutoCab[nPosLojaFor][2]
			ENDIF
		EndIf
	ElseIf nOpc == 4 //Alterar
		RegToMemory("SNO",.F.)
		nlOpcao		:= GD_UPDATE
		alEdtEnch	:= {"NO_TIPCES"}
		alEdtGD		:= {"NO_STATUS","NO_VIGINI","NO_VIGFIM","NO_CONTATO"}
	ElseIf nOpc == 5  //Excluir
		If !ATF320Del()
			Return()
		EndIf
		RegToMemory("SNO",.F.)
	ElseIf nOpc == 7 //Renovar
		If !AF320VlRen(SNO->NO_CODIGO,SNO->NO_CBASE,SNO->NO_ITEM)
			Return()
		EndIf
		RegToMemory("SNO",.F.)
		nlOpcao := GD_INSERT + GD_UPDATE
		alEdtGD		:= {"NO_STATUS","NO_VIGINI","NO_VIGFIM","NO_CONTATO"}
	ElseIf nOpc == 8 // Transferir
		If !AF320VlPer(SNO->NO_CBASE,SNO->NO_ITEM)
			Return()
		EndIf
		RegToMemory("SNO",.T.)
		cCodOri := SNO->NO_CODIGO
		nlOpcao := GD_UPDATE
		M->NO_CBASE	:= SNO->NO_CBASE
		M->NO_ITEM	:= SNO->NO_ITEM
		alEdtEnch	:= {"NO_FORNEC","NO_LOJA","NO_TIPCES"}
		alEdtGD		:= {"NO_STATUS","NO_VIGINI","NO_VIGFIM","NO_CONTATO"}
	ElseIf nOpc == 9
		RegToMemory("SNO",.F.)
	EndIf
	
	// Ponto de entrada para permitir edição de campos de usuário
	If !lATF320Aut .And. ExistBlock("AF320EDT")
		aAuxEdtGD := ExecBlock("AF320EDT",.F.,.F.,{alEdtGD})
	  	If ValType(aAuxEdtGD) == "A"
	  		alEdtGD := Aclone(aAuxEdtGD)
	  	EndIf
	EndIf

//Valida Bem baixado
	If nOpc != 2
		SN1->(dbSetOrder(1)) // N1_FILIAL+N1_CBASE+N1_ITEM
		If SN1->(dbSeek(xFilial("SN1") + M->(NO_CBASE+NO_ITEM) ))
			If !Empty(SN1->N1_BAIXA)
				Help(" ",1,"ATFA320BX",,STR0024,1,0) //"Não é possível fazer o controle de terceiros de um bem baixado"
				Return Nil
			EndIf
			//nao deixar incluir se bem nao classificado
			If Alltrim(SN1->N1_STATUS) $ '0'
				Help(" ",1,"ATFA320CLS",,STR0034,1,0)  //"Bem nao está classificado. Verifique!"
				Return Nil
			EndIf		
		EndIf
	EndIf

	aHeader := ATF320Head(clCpoGD,clNoCpoGD,,"SNO")
	aCols := ATF320Cols(aHeader,"SNO",1,"SNO->(NO_FILIAL+NO_CODIGO)",nOpc,,"NO_SEQ",,,,@nMaxCols)
	If ValType(lATF320Aut) != "U" .And. lATF320Aut .And. !lDireto .And. nOpc >= 3 .And. nOpc <= 5  //se for rotina automatica chamada pela rotina principal
		lSave := .T.
		If nOpc == 3
			dbSelectArea("SNO")
			dbSetOrder(1)
			lSave := ! dbSeek(xFilial("SNO")+ M->NO_CODIGO)  //somente inclui se nao encontrar na SNO
			If lSave
				aAreaSX3 := SX3->(GetArea())
				SN1->(dbSetOrder(1)) // N1_FILIAL+N1_CBASE+N1_ITEM
				dbSelectArea("SX3")
				dbSetOrder(2)
				For nX := 1 TO Len(aAutoCab)
					If dbSeek(AllTrim(Upper(aAutoCab[nX,1]))) .And. ! Empty(SX3->X3_VALID)
						If Alltrim(SX3->X3_CAMPO) == 'NO_CBASE' .OR. Alltrim(SX3->X3_CAMPO) == 'NO_ITEM'
							lSave := SN1->(dbSeek(xFilial("SN1")+M->NO_CBASE+M->NO_ITEM))
						ElseIf Alltrim(SX3->X3_CAMPO) == 'NO_TIPCES'
							lSave := Upper(aAutoCab[nX,2]) $ "CLP"
						Else
							lSave := &( SX3->X3_VALID )
						EndIf
						If !lSave
							AutoGRLog(Padr(X3TITULO(),20)+'- '+PadR(SX3->X3_VALID,30))
							Exit
						EndIf
					EndIf
				Next
				RestArea(aAreaSX3)
			Else
				Help(" ",1,"JAGRAVADO")
			EndIf
		EndIf
		If lSave .And. ATFDtVig(nOpc)
			llSave := ATF320Grv(nOpc,,,aAutoItens)
		EndIf
	Else
		oDlg 	:= MSDialog():New(alDms[1],alDms[2],alDms[3],alDms[4],STR0013,,,,nOr(WS_VISIBLE,WS_POPUP),,,,oMainWnd,.T.) //"Bens de Terceiro"
		oFWLayer:Init(oDlg,.T.)
		oFWLayer:AddCollumn('Col1',100,.F.)
		oFWLayer:AddWindow('Col1','Win1',cTitulo,27,.T.,.T.)
		oFWLayer:AddWindow('Col1','Win2',,70.5,.T.,.T.)
		oPanel1 := oFWLayer:GetWinPanel('Col1','Win1')
		oPanel1	:FreeChildren()
		oPanel2 := oFWLayer:GetWinPanel('Col1','Win2')
		oPanel2	:FreeChildren()
		oEnch 	:= MsMGet():New("SNO",nReg,nOpc,,,,alCpoEnch,{0,0,50,50},alEdtEnch,3,,,,oPanel1,,.T.)
		oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	
		oGetSNO := MsNewGetDados():New(0,0,150,200,nlOpcao,"AllwaysTrue","AllwaysTrue","+NO_SEQ",alEdtGD,000,nMaxCols,"AllwaysTrue","","AllwaysFalse",oPanel2,aHeader,aCols)
		oGetSNO:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
		If nOpc == 2
			Activate MsDialog oDlg CENTER on Init EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})
		Else
			Activate MsDialog oDlg CENTER on Init EnchoiceBar(oDlg,{||Eval({||Iif(Obrigatorio(aGets,aTela) .and. ATFDtVig(nOpc),(llSave := ATF320Grv(nOpc,lDireto,cCodOri,alEdtGd),oDlg:End()),Nil)})},{||oDlg:End()})
		Endif
			
		If !llSave
			RollBackSX8()
		Else
			ConfirmSX8()
		EndIf
	EndIf
ENdIf

RestArea(aAreaSN1)
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA320   ºAutor  ³Microsiga           º Data ³  07/20/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF320VlRen(cCodigo,cCodBase,cItem)
Local lRet 		:= .T.
Local cCodAux	:= ""
Local aArea		:= GetArea()
Local aAreaSNO 	:= SNO->(GetArea())

SNO->(dbSetOrder(2)) //NO_FILIAL+NO_CBASE+NO_ITEM+NO_CODIGO+NO_SEQ
If SNO->(MsSeek( xFilial("SNO") + cCodBase + cItem ) )
	While SNO->(!EOF()) .And. Alltrim( SNO->(NO_FILIAL+NO_CBASE+NO_ITEM) ) == Alltrim( xFilial("SNO") + cCodBase + cItem )
		cCodAux := SNO->NO_CODIGO
		SNO->(dbSkip())
	EndDo
EndIf

If Alltrim(cCodAux) != cCodigo
	lRet := .F.
	Help(" ",1,"ATFA320REN",,STR0026,1,0) //"Controle do bem já foi transferido e não pode ser renovado."
EndIf

RestArea(aAreaSNO)
RestArea(aArea)
Return lRet               

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ATF320Grvº Autor ³ Felipe C. Seolin   º Data ³  17/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Manipulação de dados da tabela SNO			              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA320				                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ATF320Grv(nOpc,lDireto,cCodOri,alEdtGd)
Local alCpoEnch	:= {"NO_CODIGO","NO_CBASE","NO_ITEM","NO_FORNEC","NO_LOJA","NO_TIPCES"}
Local alCpoGD	:= {"NO_SEQ","NO_STATUS","NO_VIGINI","NO_VIGFIM","NO_CONTATO"}
Local alValEnch	:= {}
Local alValGD	:= {}
Local nlQuant	:= 0
Local nlPos		:= 0
Local nlI		:= 0
Local nlJ		:= 0
Local clCod 	:= M->NO_CODIGO
Local clFilial	:= M->NO_FILIAL
Local clCodBase := M->NO_CBASE
Local clItem 	:= M->NO_ITEM
Local lRet		:= .T.

Local aAuxAcols 

Default lDireto := .F.
Default cCodOri := ""

If !(IsBlind())
	For nlI := 1 to Len(alEdtGd)
		If aScan(alCpoGD, alEdtGd[nlI]) == 0
			aAdd(alCpoGD, alEdtGd[nlI])
		EndIf
	Next
EndIf

If nOpc == 3 .or. nOpc == 4 .or. nOpc == 7 .or. nOpc == 8
	If ValType(lATF320Aut) != "U" .And. lATF320Aut .And. !lDireto .And. nOpc >= 3 .And. nOpc <= 5  //se for rotina automatica chamada pela rotina principal
		aAuxAcols := aCols
	Else
		If Obrigatorio(aGets,aTela)
			aAuxAcols := oGetSNO:aCols
		Else
			Return (lRet)
		EndIf
	EndIf
	For nlI := 1 to Len(aAuxAcols)
		aAdd(alValEnch,Array(Len(alCpoEnch)))
		nlPos := Len(alValEnch)
		For nlJ := 1 to Len(alCpoEnch)
			alValEnch[nlPos][nlJ] := M->&(alCpoEnch[nlJ])
		Next nlJ
		aAdd(alValGD,Array(Len(alCpoGD)))
		nlPos := Len(alValGD)
		For nlJ := 1 to Len(alCpoGD)
			alValGD[nlPos][nlJ] := aAuxAcols[nlI][nlJ]
		Next nlJ
		nlQuant ++
	Next nlI
	DBSelectArea("SNO")
		
	SNO->(DBSetOrder(2))
	For nlI := 1 to nlQuant
		If nOpc == 3
			//SNO->(DBSetOrder(3))
			If DbSeek(xFilial("SNO")+M->NO_CBASE+M->NO_ITEM)
				llRecLock := .F.
			Else
				llRecLock := .T.
			EndIf
		ElseIf SNO->(DBSeek(xFilial("SNO") + M->NO_CBASE + M->NO_ITEM + M->NO_CODIGO + aAuxAcols[nlI][1]))
			llRecLock := .F.
		Else
			llRecLock := .T.
		EndIf
		RecLock("SNO",llRecLock)
		SNO->NO_FILIAL := xFilial("SNO")
		For nlJ := 1 to Len(alCpoEnch)
			FieldPut(FieldPos(alCpoEnch[nlJ]),alValEnch[nlI][nlJ])
		Next nlJ
		For nlJ := 1 to Len(alCpoGD)
			FieldPut(FieldPos(alCpoGD[nlJ]),alValGD[nlI][nlJ])
		Next nlJ
		SNO->(MsUnlock())
	Next nlI
	
	If lRet 
		DBSelectArea("SN1")
		SN1->(DBSetOrder(1))
		If SN1->(DBSeek(xFilial("SN1") + clCodBase + clItem))
			RecLock("SN1",.F.)
			SN1->N1_STATUS  := "1"
			SN1->N1_FORNEC	:= SNO->NO_FORNEC
			SN1->N1_LOJA	:= SNO->NO_LOJA
			If !lDireto 
				SN1->N1_TPCTRAT := "2"
			EndIf
			SN1->(MsUnLock())
		EndIf
	EndIf
	
	If nOpc == 8
		ATF320TC(cCodOri)	
	EndIf
		
ElseIf nOpc == 5
	DBSelectArea("SNO")
	SNO->(DBSetOrder(1))
	If SNO->(DBSeek(xFilial("SNO") + clCod))
		While Alltrim(SNO->NO_FILIAL) == Alltrim(clFilial) .and. Alltrim(SNO->NO_CODIGO) == Alltrim(clCod)
			If RecLock("SNO",.F.,.T.)
				DBDelete()
				SNO->(MsUnLock())
			Else
				lRet := .F.
			EndIf
			SNO->(DBSkip())
		EndDo
	EndIf
	If lRet
		DBSelectArea("SN1")
		SN1->(DBSetOrder(1))
		If SN1->(DBSeek(xFilial("SN1") + clCodBase + clItem))
			RecLock("SN1",.F.)
			SN1->N1_STATUS := "2"
			SN1->N1_TPCTRAT:= "1"
			SN1->N1_FORNEC	:= ''
			SN1->N1_LOJA	:= ''
			SN1->(MsUnLock())
		ELSE
			lRet := .F.
		ENDIF
	EndIf
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ATFDtVig º Autor ³ Felipe C. Seolin   º Data ³  17/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação de Data de Vigência				              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA320				                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ATFDtVig(nOpc)
Local aSaveArea	:= GetArea()
Local lRet 		:= .T.
Local nlI			:= 0
Local nTamSeq		:= TamSx3("NO_SEQ")[1]
Local dDataIni		:= "" 
Local dDataFim		:= "" 
Local nPosVigIni 	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "NO_VIGINI" } )
Local nPosVigFim 	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "NO_VIGFIM" } )
Local nPosContato	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "NO_CONTATO" } )
Local aArea
Local aAreaSNO
Local dUltDepr 	:= GetMV("MV_ULTDEPR")
Local cWhileSNO 	:= ""
Local aAuxCols   

Default nOpc 		:= 0

If ValType(lATF320Aut) != "U" .And. lATF320Aut  //se for rotina automatica chamada pela rotina principal
	aAuxCols := aCols
Else
	aAuxCols := oGetSNO:aCols
EndIF

DbSelectArea("SNO")
SNO->(DbSetOrder(2)) //NO_FILIAL+NO_CBASE+NO_ITEM+NO_CODIGO+NO_SEQ
If nOpc != 7 .AND. nOpc != 5
	SNO->(MsSeek(xFilial("SNO")+M->(NO_CBASE+NO_ITEM+NO_CODIGO+StrZero(Len(aAuxCols),nTamSeq))))
Else
	SNO->(MsSeek(xFilial("SNO")+M->(NO_CBASE+NO_ITEM+NO_CODIGO+StrZero((Len(aAuxCols))-1,nTamSeq))))
EndIf

dDataIni := SNO->NO_VIGINI //atribui a data inicial do contrato em vigencia a variavel
dDataFim := SNO->NO_VIGFIM //atribui a data final do contrato em vigencia a variavel

If lRet .And. (Empty(aAuxCols[Len(aAuxCols)][nPosVigIni]) .Or. Empty(aAuxCols[Len(aAuxCols)][nPosVigFim]) )
	lRet := .F.
	Help(" ",1,"ATFA320DEx",,STR0022,1,0) //"Por favor, preencher os campos de inicio e fim de vigencia"
EndIf

If lRet .And. Empty(aAuxCols[Len(aAuxCols)][nPosContato])
	lRet := .F.
	Help(" ",1,"ATFA320CONT",,STR0021,1,0) //"Por favor, preencher o nome do contato"
EndIf

If lRet .And. aAuxCols[Len(aAuxCols)][nPosVigIni] <= dDataFIM .AND. nOpc != 4
	lRet := .F.
	Help(" ",1,"ATFA320DINI1",,STR0020,1,0) //"Data de vigência inicial menor que a data da vigencia final anterior"
ElseIf lRet .AND. nOpc == 4 .AND. Len(aAuxCols)>1
	If aAuxCols[(Len(aAuxCols))][nPosVigIni] <= aAuxCols[(Len(aAuxCols))-1][nPosVigFim]
		lRet := .F.
		Help(" ",1,"ATFA320DINI2",,STR0020,1,0)  //"Data de vigência inicial menor que a data da vigencia final anterior"
	EndIf	
EndIf
	
If lRet .And. aAuxCols[Len(aAuxCols)][nPosVigFim] <= aAuxCols[Len(aAuxCols)][nPosVigIni]
	lRet := .F.
	Help(" ",1,"ATFA320DFIM",,STR0014,1,0) //"Data de vigência final incorreta"
EndIf
	
If lRet .and. (nOpc == 7 .or. nOpc == 8)
	DbSelectArea("SNO")
	aAreaSNO := SNO -> (GetArea())				
	DbSetOrder(2)
	If DbSeek(xFilial("SNO")+M->NO_CBASE+M->NO_ITEM)
		If aAuxCols[Len(aAuxCols)][nPosVigIni] <= dUltDepr //se data inicial digitada for menor que a data da ultima depreciacao
			lRet := .F.
			Help(" ",1,"ATFA320DINI3",,STR0028+substr(dtos(dUltDepr),7,2)+"/"+substr(dtos(dUltDepr),5,2)+"/"+substr(dtos(dUltDepr),1,4)+").",1,0)
		ElseIf aAuxCols[Len(aAuxCols)][nPosVigFIM] <= dUltDepr //se data final digitada for menor que a data da ultima depreciacao
			lRet := .F.
			Help(" ",1,"ATFA320DFIM",,STR0029+substr(dtos(dUltDepr),7,2)+"/"+substr(dtos(dUltDepr),5,2)+"/"+substr(dtos(dUltDepr),1,4)+").",1,0)
		EndIF
	EndIf
			
	SNO->(Dbskip())
	RestArea(aAreaSNO)
EndIf

RestArea(aSaveArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ATF320TC º Autor ³ Felipe C. Seolin   º Data ³  18/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Encerra Controle para opção de Transferência de Controle	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA320				                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ATF320TC(clCod)
Local alArea	:= GetArea()

DBSelectArea("SNO")
SNO->(DBSetOrder(1))
If SNO->(DBSeek(xFilial("SNO") + clCod))
	While Alltrim(SNO->NO_FILIAL) == Alltrim(xFilial("SNO")) .and. Alltrim(SNO->NO_CODIGO) == Alltrim(clCod)
		If RecLock("SNO",.F.)
			SNO->NO_STATUS := "2"
			SNO->(MsUnlock())
		EndIf
		SNO->(DBSkip())
	EndDo
EndIf

RestArea(alArea)
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ATF320Delº Autor ³ Felipe C. Seolin   º Data ³  26/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida exclusão de Bem de Terceiro			              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA320				                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ATF320Del()
Local alArea	:= GetArea()
Local alAreaSN1	:= SN1->(GetArea())
Local alAreaSN4	:= SN4->(GetArea())
Local lRet		:= .T.

DBSelectArea("SN1")
SN1->(DBSetOrder(1))
If lRet
	If SN1->(DBSeek(SNO->NO_FILIAL + SNO->NO_CBASE + SNO->NO_ITEM))
		If SN1->N1_STATUS == "2"
			lRet := .F.
			Help(" ",1,"ATFA320BLOQ",,STR0015,1,0) //"Bem está bloqueado"
		EndIf
	EndIf
EndIf

DBSelectArea("SN4")
SN4->(DBSetOrder(1))
If lRet
	If SN4->(DBSeek(SNO->NO_FILIAL + SNO->NO_CBASE + SNO->NO_ITEM))
		While SN4->(!EOF()) .AND. 	SN4->N4_FILIAL 	== SNO->NO_FILIAL .AND.;
			SN4->N4_CBASE 	== SNO->NO_CBASE .AND.;
			SN4->N4_ITEM	== SNO->NO_ITEM
			
			IF SN4->N4_OCORR != "05" // AQUISICAO
				lRet := .F.
				Help(" ",1,"ATFA320MOV",,STR0016,1,0) //"Bem possui movimentos"
				Exit
			ENDIF
			SN4->(DbSkip())
		End
	EndIf
EndIf

If lRet
	lRet := AF320VlPer(SNO->NO_CBASE,SNO->NO_ITEM)
EndIf

RestArea(alAreaSN4)
RestArea(alAreaSN1)
RestArea(alArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA320   ºAutor  ³Microsiga           º Data ³  07/20/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A320CanBxa(clAlias,nlReg,nlOpc)
Local clFunBaixa	:= GetNewPar("MV_ATFRTBX","ATFA030")
Local aArea			:= GetArea()
Local aAreaSN1		:= SN1->(GetArea())
Local aAreaSN3		:= SN3->(GetArea())

Local lRetExt		:= .T.
Local cBase			:= SNO->NO_CBASE
Local cItem			:= SNO->NO_ITEM
Local xCab 			:= {}

Local lModAnt		:= .F.

Private lMsErroAuto := .F.
Private lPrimlPad 	:= .T.
Private nTotal 		:= 0
Private nHdlPrv 	:= 0
Private LUSAMNTAT 	:= .F.
Private LAUTO 	 	:= .F.

SaveInter()

SN1->(dbSetOrder(1))
SN3->(dbSetOrder(1))

SN3->(dbSeek(xFilial("SN3") + cBase + cItem  ))


//-------------------------------------------------------------
//Verifica a existencia de dados nas tabelas novas do módulo
// Caso negativo chama as rotina ATFA030 e ATFA035 para cancelamento
//-------------------------------------------------------------
FN6->(DbSetOrder(2))//posiciono pois na execAuto estava deposicionada a Tabela
If FN6->(!MsSeek(SN3->N3_FILIAL + SN3->N3_FILORIG + SN3->N3_CBASE + SN3->N3_ITEM)) 
	lModAnt := .T.
EndIf

If lModAnt
	Pergunte("AFA030",.F.)
	If SN1->(dbSeek(xFilial("SN1") + cBase + cItem ) .And. SN3->(dbSeek(xFilial("SN3") + cBase + cItem  ) ))
		If  !Empty(SN1->N1_BAIXA) .And. AF320VlCan(SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO)
			If AllTrim(clFunBaixa) == "ATFA030"
				AF030Cance("SN3",SN3->(Recno()),5,,,,,@lRetExt)
			ElseIf AllTrim(clFunBaixa) == "ATFA035"  
				AF035Cance("SN3",SN3->(Recno()),5,,,,,@lRetExt)
			Else
				Help(" ",1,"MV_ATFRTBX",,"Conteúdo de parâmetro inválido:" + CRLF + AllTrim(clFunBaixa),1,0) //"Conteúdo de parâmetro inválido:"
			EndIf
		Else
			Help(" ",1,"AF320NAOBAIXA",,"Você esta tentando cancelar a baixa de  um item não baixado.",1,0)//"Você esta tentando cancelar a baixa de  um item não baixado."
		EndIf
	Else
		HELP(" ",1,"REGNOIS")
	EndIf
Else
	FN6->(DbSetOrder(1))//Retorno para o set order padrão
	Pergunte("AFA036",.F.)
	If SN1->(dbSeek(xFilial("SN1") + cBase + cItem ) .And. SN3->(dbSeek(xFilial("SN3") + cBase + cItem  ) ))
	
		If Alltrim(SN1->N1_STATUS) $ '0'
			lRetExt		:= .F.
			Help(" ",1,"ATFA320CLS",,STR0034,1,0)  //"Bem nao está classificado. Verifique!"
		Else
			If  !Empty(SN1->N1_BAIXA) .And. AF320VlCan(SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO)
		
				aCab :={ 	{"FN6_FILIAL"	,xFilial("FN6")		,NIL},;
							{"FN6_CBASE"	,SN3->N3_CBASE		,NIL},;
							{"FN6_CITEM"	,SN3->N3_ITEM		,NIL},;
							{"FN6_MOTIVO"	,"13"				,NIL},;
							{"FN6_DEPREC"	,'0'				,NIL} }
		
				aAtivo:={ 	{"N3_FILIAL"	, xFilial("SN3")	,NIL},;
							{"N3_CBASE"		, SN3->N3_CBASE		,NIL},;
							{"N3_ITEM"		, SN3->N3_ITEM		,NIL},;
							{"N3_TIPO"		, SN3->N3_TIPO		,NIL},;
							{"N3_BAIXA"  	, SN3->N3_BAIXA		,NIL},;
							{"N3_TPSALDO"	, SN3->N3_TPSALDO	,NIL},;
							{"N3_SEQREAV"	, SN3->N3_SEQREAV	,NIL},;
							{"N3_SEQ"		, SN3->N3_SEQ		,NIL},;
							{"N3_FILORIG"	, SN3->N3_FILORIG	,NIL}}
		
				MsExecAuto({|a,b,c,d,e|ATFA036(a,b,c,d,e)},aCab,aAtivo,5,,.F.)
				
				If lMsErroAuto
					MostraErro()
					lRetExc:=  .F.
				Endif
			Else
				Help(" ",1,"AF320NAOBAIXA",,STR0030,1,0)//"Você esta tentando cancelar a baixa de  um item não baixado."
			EndIf
		EndIf
	Else
		HELP(" ",1,"REGNOIS")
	EndIf
EndIf

If lRetExt
	SNO->(dbSetOrder(2))//NO_FILIAL+NO_CBASE+NO_ITEM+NO_CODIGO+NO_SEQ
	If SNO->(dbSeek(xFilial("SNO") + cBase + cItem  ) )
		While SNO->(!Eof()) .And. Alltrim(SNO->(NO_FILIAL+NO_CBASE+NO_ITEM)) == Alltrim(xFilial("SNO") + cBase + cItem )
			SNO->(dbSkip())                                                                                             
			If SNO->(Eof()) .Or. Alltrim(SNO->(NO_FILIAL+NO_CBASE+NO_ITEM)) != Alltrim(xFilial("SNO") + cBase + cItem )
				SNO->(dbSkip(-1)) 
				RecLock("SNO",.F.)
				SNO->NO_STATUS := '1'
				MsUnLock()     
				SNO->(dbSkip()) 
			EndIf
		EndDo
	EndIf
EndIf

RestInter()
RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF320VlCanºAutor  ³Microsiga           º Data ³  07/20/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o cancelamento da baixa apenas de baixas com motivos º±±
±±º          ³de bens de terceiros                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF320VlCan(cBase,cItem,cTipo)
Local lRet := .F.
Local aArea := GetArea()
Local aAreaSN4:= SN4->(GetArea())

SN4->(dbSetOrder(4))//N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_OCORR+DTOS(N4_DATA)
If SN4->(dbSeek(xFilial("SN4") +  cBase + cItem + cTipo + "01" )) .And. SN4->N4_MOTIVO $ '15/16/17'
	lRet := .T.
EndIf 

RestArea(aAreaSN4)
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ATF320Bxaº Autor ³ Felipe C. Seolin   º Data ³  30/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de Baixa do Bem de Terceiro			              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA320				                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATF320Bxa(clAlias,nlReg,nlOpc)
Local clFunBaixa	:= GetNewPar("MV_ATFRTBX","ATFA030")
Local alValidMot	:= {"15","16","17"}
Local aArea			:= GetArea()
Local aAreaSN1		:= SN1->(GetArea())
Local aAreaSN3		:= SN3->(GetArea())
Local lRetExt		:= .F.
Local cBase			:= SNO->NO_CBASE
Local cItem			:= SNO->NO_ITEM
Local xAtivo
Local xCab                 
Local lMsErroAuto :=  .F.

SaveInter()
Pergunte("AFA036",.F.)                        
If AF320VlPer(cBase,cItem)
	If SN1->(dbSeek(xFilial("SN1") + cBase + cItem ) .And. SN3->(dbSeek(xFilial("SN3") + cBase + cItem  ) ))
		If Empty(SN1->N1_BAIXA) 
	
			xCab :={ 		{"FN6_FILIAL"	,xFilial("FN6")			,NIL},;
						{"FN6_CBASE"	,SN3->N3_CBASE		,NIL},;
						{"FN6_CITEM"	,SN3->N3_ITEM			,NIL},;
						{"FN6_MOTIVO"	,"15"					,NIL},; 
						{"FN6_QTDATU"	,SN1->N1_QUANTD		,NIL},; 
						{"FN6_BAIXA"	,100				,NIL},; 
						{"FN6_QTDBX"	,SN1->N1_QUANTD		,NIL},; 
						{"FN6_DTBAIX"	,dDatabase			,NIL},;
						{"FN6_NUMNF"	,SN1->N1_NFISCAL		,NIL},;
						{"FN6_SERIE"	,SN1->N1_NSERIE			,NIL},;
						{"FN6_PERCBX"	,100			  		,NIL},;
						{"FN6_VALNF"	,SN3->N3_VORIG1		,NIL},; 
						{"FN6_DEPREC"	,GETMV('MV_ATFDPBX')	,NIL}	 } 
						
			xAtivo:={ 		{"N3_FILIAL"	,xFilial("SN3")		,NIL},;
						{"N3_CBASE"	,SN3->N3_CBASE	,NIL},;
						{"N3_ITEM"	,SN3->N3_ITEM		,NIL},;
			   	   		{"N3_TIPO"	,SN3->N3_TIPO		,NIL},;
						{"N3_BAIXA"   	,SN3->N3_BAIXA	,NIL},; 
				   	    	{"N3_TPSALDO"	,SN3->N3_TPSALDO	,NIL} }
						
			//³Executa a Baixa do Bem ³
			MsExecAuto({|a,b,c|ATFA036(a,b,c)},xCab,xAtivo,3)
				
			If lMsErroAuto
				MostraErro()
				lRetExt := .F.
			ElseIf !Empty(SN1->N1_BAIXA)
				lRetExt := .T.
			EndIf
		Else
			Help(" ",1,"020BAIXADO")
		EndIf
	Else
		HELP(" ",1,"REGNOIS")
	EndIf
	
	If lRetExt
		SNO->(dbSetOrder(2))//NO_FILIAL+NO_CBASE+NO_ITEM+NO_CODIGO+NO_SEQ
		If SNO->(dbSeek(xFilial("SNO") + cBase + cItem  ) )
			While SNO->(!Eof()) .And. Alltrim(SNO->(NO_FILIAL+NO_CBASE+NO_ITEM)) == Alltrim(xFilial("SNO") + cBase + cItem )
				RecLock("SNO",.F.)
				SNO->NO_STATUS := '2'
				MsUnLock()
				SNO->(dbSkip())
			EndDo
		EndIf
	EndIf
EndIf

RestInter()
RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF320VlPer   ºAutor  ³Microsiga           º Data ³  07/20/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se o bem possui um periodo válido                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF320VlPer(cBase,cItem) 
Local lRet := .F.
Local aArea:= GetArea()
Local aAreaSNO:= SNO->(GetArea())

SNO->(dbSetOrder(2)) //NO_FILIAL+NO_CBASE+NO_ITEM+NO_CODIGO+NO_SEQ
If SNO->(MsSeek( xFilial("SNO") + cBase + cItem ) )
	While SNO->(!EOF()) .And. Alltrim( SNO->(NO_FILIAL+NO_CBASE+NO_ITEM) ) == Alltrim( xFilial("SNO") + cBase + cItem )
		If SNO->NO_STATUS == '1' // Ativo
			lRet := .T. 
		EndIf
		SNO->(dbSkip())
	EndDo
EndIf

If !lRet 
	Help(" ",1,"ATFA320PVAL",,STR0025,1,0) //"Bem selecionado já está classificado como bem de terceiro"
EndIf

RestArea(aAreaSNO)
RestArea(aArea)
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATF320ColsºAutor  ³Felipe C. Seolin    º Data ³  02/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que cria aCols                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aHeader : aHeader aonde o aCOls será baseado                º±±
±±º          ³cAlias  : Alias da tabela                                   º±±
±±º          ³nIndice : Indice da tabela que sera usado para              º±±
±±º          ³cComp   : Informacao dos Campos para ser comparado no While º±±
±±º          ³nOpc    : Opção do Cadastro                                 º±±
±±º          ³aCols   : Opcional caso queira iniciar com algum elemento   º±±
±±º          ³cCPO_ITEM: Campo de item a ser inicializado com '001'		  º±±
±±º          ³cINDICE : Chave de comparação da tabela de item             º±±
±±º          ³cCPOMemo: Opcional Nome do campo de código do MEMO          º±±
±±º          ³cMemo   : Nome do campo memo virtual                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA320	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ATF320Cols(aHeader,cAlias,nIndice,cComp,nOpc,aCols,cCPO_ITEM,cINDICE,cCPOMemo,cMemo,nMaxCols)
Local nlI			:= 0
Local nlCols		:= 0
Local alArea		:= GetArea()
Local nPos
Local nX
Local nY
Local nPosSeq 	:= Ascan(aHeader, { |x| AllTrim( x[2] ) == "NO_SEQ" } )
Local nPosSeqIt := 0
Local nPosCols 	:= 0

Default cCPO_ITEM	:= ""
Default cCPOMemo	:= ""
Default cMemo		:= ""
Default nMaxCols	:= 0

If nOpc == 3
    If ValType(lATF320Aut) != "U" .And. lATF320Aut .And. Len(aAutoItens) > 0 //se for rotina automatica chamada pela rotina principal
    	aCols := {}
    	For nX := 1 TO Len(aAutoItens)
    		aAdd( aCols,Array(Len(aHeader) + 1) )
			aCols[Len(aCols),Len(aHeader) + 1] := .F.
    		For nY := 1 TO Len(aAutoItens[nX])
		    	If ( nPos := Ascan(aHeader, { |x| AllTrim( x[2] ) == aAutoItens[nX,nY,1]} ) ) > 0
			    	aCols[Len(aCols), nPos] := aAutoItens[nX,nY,2]
			    EndIf
	    	Next
    		nMaxCols++
	  	Next
	Else
		aCols := {Array(Len(aHeader) + 1)}
		aCols[1,Len(aHeader) + 1] := .F.
		For nlI := 1 to Len(aHeader)
			If AllTrim(aHeader[nlI,2]) == "NO_SEQ"
				aCols[1,nlI] := "001"
			Else
				aCols[1,nlI] := CriaVar(aHeader[nlI,2])
			EndIf
		Next nlI
		nMaxCols++
	EndIf
Else
	aCols := {}
	DBSelectArea(cAlias)
	(cAlias)->(DBSetOrder(nIndice))
	If (cAlias)->(DBSeek(xFilial(cAlias) + M->NO_CODIGO))
		While (cAlias)->(!EOF()) .and. &cComp == M->(NO_FILIAL+NO_CODIGO)
			aAdd(aCols,Array(Len(aHeader) + 1))
			For nlI := 1 to Len(aHeader)
				aCols[Len(aCols),nlI] := FieldGet(FieldPos(aHeader[nlI,2]))
			Next nlI
			aCols[Len(aCols),Len(aHeader) + 1] := .F.
			nMaxCols++
			(cAlias)->(DBSkip())
		EndDo
	EndIf
	If nOpc == 4  // alteracao
		If ValType(lATF320Aut) != "U" .And. lATF320Aut .And. Len(aAutoItens) > 0 //se for rotina automatica chamada pela rotina principal
            If Len(aAutoItens) > 0
				For nX := 1 TO Len(aAutoItens)
					nPosSeqIt 	:= Ascan(aAutoItens[nX], { |x| AllTrim( x[1] ) == "NO_SEQ" } )
					//se tem campo sequencia no aCols e eh igual a passada no aAutoItens
					If nPosSeq > 0 .And. nPosSeqIt > 0 
						If ( nPosCols := Ascan(aCols, {|x| x[nPosSeq] == aAutoItens[nX,nPosSeqIt,2] }) ) > 0
							For nY := 1 TO Len(aAutoItens[nX])
								If ny != nPosSeqIt .And. ( nPos := Ascan(aHeader, { |x| AllTrim( x[2] ) == aAutoItens[nX,nY,1]} ) ) > 0
						    		aCols[nPosCols, nPos] := aAutoItens[nX,nY,2]
						  		EndIf
					    	Next
						Else
				    		aAdd( aCols,Array(Len(aHeader) + 1) )
							aCols[Len(aCols),Len(aHeader) + 1] := .F.
				    		For nY := 1 TO Len(aAutoItens[nX])
		    					If ( nPos := Ascan(aHeader, { |x| AllTrim( x[2] ) == aAutoItens[nX,nY,1]} ) ) > 0
							    	aCols[Len(aCols), nPos] := aAutoItens[nX,nY,2]
			    				EndIf
					    	Next
				    		nMaxCols++
						EndIf
					EndIf
				Next
			EndIf
		EndIf
	EndIf
	
	If nOpc == 7
		For nlI := 1 to Len(aCols)
			If aCols[nlI][2] == "1"
				aCols[nlI][2] := "2"
			EndIf
		Next nlI
	EndIf
	If nOpc != 4
		nMaxCols++
	EndIf
EndIf
RestArea(alArea)
Return(aCols)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATF320HeadºAutor  ³Felipe C. Seolin    º Data ³  02/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria o aHeader da GetDados                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA320	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ATF320Head(cCampos,cExc,aHeader,cAlias)
Local alArea	:= GetArea()
Default aHeader	:= {}
Default cCampos	:= "" // Campos a serem considerados
Default cExc	:= "" // Campos que nao sao considerados

SX3->(DBSetOrder(1))
SX3->(DBSeek(cAlias))
While SX3->(!EOF()) .and. SX3->X3_ARQUIVO == cAlias
	If (X3Uso(SX3->X3_USADO) .or. (AllTrim(SX3->X3_CAMPO) $ AllTrim(cCampos))) .and. (cNivel >= SX3->X3_NIVEL) .and. !(AllTrim(SX3->X3_CAMPO) $ AllTrim(cExc))
		aAdd(aHeader,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_Picture,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_Valid	,SX3->X3_USADO,SX3->X3_TIPO	,SX3->X3_F3,SX3->X3_CONTEXT	,SX3->X3_CBOX,SX3->X3_RELACAO})
	EndIf
	SX3->(DBSkip())
EndDo
RestArea(alArea)
Return(aHeader)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATF320WHENºAutor  ³Arnaldo Raymundo Jr.º Data ³  02/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se o campo pode ser alterado em funcao da linha     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA320	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATF320WHEN()

Local lRet	:= .T.

If Type("oGetSNO") == "O"
	If ALTERA .AND. aScan( oGetSNO:aHeader, { |x| AllTrim( x[2] ) == "NO_CONTATO" } ) == OGETSNO:OBROWSE:NCOLPOS
		lRet := .T.
	Else
		lRet := oGetSNO:nAT==oGetSNO:nMax
	EndIf
ElseIf Type("oGetSNP") == "O"
	If ALTERA .AND. aScan( oGetSNP:aHeader, { |x| AllTrim( x[2] ) == "NP_CONTATO" } ) == OGETSNP:OBROWSE:NCOLPOS
		lRet := .T.
	Else
		lRet := oGetSNP:nAT==oGetSNP:nMax
	EndIf
ELSE
	lRet := .F.
ENDIF

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATF320VSN1   ºAutor  ³Microsiga           º Data ³  07/18/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Visualiza o cadastro no SN1                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATF320VSN1(cAlias,nReg,nOpc)

Local aArea := GetArea()
Local cChave:= ""

dbSelectArea("SN3")
dbSelectArea("SN1")

SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
SN1->(dbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona o SN1 em fun‡Æo do SN3.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cChave := SNO->NO_CBASE + SNO->NO_ITEM
If SN1->(dbSeek( xFilial("SN1") + cChave )) .And. SN3->(dbSeek( xFilial("SN3") + cChave ))
	FWExecView( STR0007,'ATFA012', 1/*nOpc*/,/*oDlg*/,{|| .T. },/*bOk*/,/*nPercReducao*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/, /*cToolBar*/ ) //"Visualizar bem"
Else
	HELP( " ",1,"RECNO" )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura posi‡Æo do SN3.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA320   ºAutor  ³Microsiga           º Data ³  07/19/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se o bem selecionado é válido para incluir a informaº±±
±±º          ³ção de bens de terceiros                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF320VLBEM(cBase,cItem)
Local lRet := .T.
Local aArea:= GetArea()
Local aAreaSN1 := SN1->(GetArea())
Local aAreaSNO := SNO->(GetArea())

SN1->(dbSetOrder(1))//N1_FILIAL+N1_CBASE+N1_ITEM
SNO->(dbSetOrder(2))//NO_FILIAL+NO_CBASE+NO_ITEM+NO_CODIGO+NO_SEQ

If !Empty(cBase) .And. !Empty(cItem)
	If lRet .And. !SN1->(dbSeek(xFilial("SN1") + cBase + cItem ))
		lRet := .F.
		HELP(" ",1,"REGNOIS")
	EndIf

	If lRet .And. Alltrim(SN1->N1_STATUS) $ '0'
		lRet := .F.
		Help(" ",1,"ATFA320CLS",,STR0034,1,0) //"Bem nao está classificado. Verifique!"
	EndIf
	
	If lRet .And. Alltrim(SN1->N1_TPCTRAT) $ '2/3'
		lRet := .F.
		Help(" ",1,"ATFA320BEM",,STR0019,1,0) //"Bem selecionado já está classificado como bem de terceiro"
	EndIf
	
	If lRet .And. !Empty(SN1->N1_BAIXA)
		lRet := .F.
		Help(" ",1,"ATFA320BX",,STR0024,1,0) //"Não é possível fazer o controle de terceiros de um bem baixado"
	EndIf
	
	If lRet .And. SNO->(dbSeek(xFilial("SNO") + cBase + cItem ))
		lRet := .F.
		Help(" ",1,"ATFA320BEM",,STR0019,1,0) //"Bem selecionado já está classificado como bem de terceiro"
	EndIf
EndIf


RestArea(aAreaSNO)
RestArea(aAreaSN1)
RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF320DTINI  ºAutor  ³Microsiga           º Data ³  07/19/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a inicializaçao do campo de data inicial                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF320DTINI()
Local nPosVigIni := 0
Local nPosVigFim := 0
Local nAt := 0
Local dDataIni := STOD("")

If oGetSNO != Nil
	nPosVigIni := aScan( oGetSNO:aHeader, { |x| AllTrim( x[2] ) == "NO_VIGINI" } )
	nPosVigFim := aScan( oGetSNO:aHeader, { |x| AllTrim( x[2] ) == "NO_VIGFIM" } )
	nAt := oGetSNO:nAt
	dDataIni := oGetSNO:aCols[nAt][nPosVigFim] + 1
EndIf

Return dDataIni

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MenuDef  ºAutor  ³Felipe C. Seolin    º Data ³  02/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria botoes de rotina do Browse                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA320	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {}

aAdd(aRotina,{STR0002,"AxPesqui"			,0,1})	//"Pesquisar"
aAdd(aRotina,{STR0003,"ATF320Cad"			,0,2})	//"Visualizar Dados"
aAdd(aRotina,{STR0004,"ATF320Cad"			,0,3})	//"Incluir"
aAdd(aRotina,{STR0005,"ATF320Cad"			,0,4})	//"Atualizar Dados"
aAdd(aRotina,{STR0006,"ATF320Cad"			,0,5})	//"Excluir Dados"
aAdd(aRotina,{STR0007,"ATF320VSN1"			,0,2})	//"Visualizar Bem"
aAdd(aRotina,{STR0018,"ATF320Cad"			,0,6})	//"Renovar Bem"
aAdd(aRotina,{STR0009,"ATF320Cad"			,0,6})	//"Transferir Controle"
aAdd(aRotina,{STR0010,"ATF320Bxa"			,0,6})	//"Baixar Bem"
aAdd(aRotina,{STR0023,"A320CanBxa"			,0,6})	//"Cancelar Baixa"
aAdd(aRotina,{STR0011,"ATFR325"				,0,6})	//"Demonstrativo"
aAdd(aRotina,{STR0012,"MSDOCUMENT"			,0,4})	//"Conhecimento"

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AF320VLINI ºAutor  ³Alvaro Camillo Neto º Data ³  04/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a inicialização da rotina                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA320	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF320VLINI(nOpc,cCodigo,cBase,cItem)
Local aArea 		:= GetArea()
Local aAreaSNO 	:= SNO->(GetArea())
Local lRet 		:= .T.
Local lAtivo      := .F.
Local lHist       := .F.

If nOpc == 4 .Or.  nOpc == 5 .Or.  nOpc == 7 .Or.  nOpc == 8 .Or.  nOpc == 9 .Or.  nOpc == 10 
	SNO->(dbSetOrder(1))//NO_FILIAL+NO_CODIGO+NO_SEQ 
	If SNO->(MsSeek(xFilial("SNO") + cCodigo))
		While SNO->(!EOF()) .And. SNO->(NO_FILIAL+NO_CODIGO) == xFilial("SNO") + cCodigo
			If SNO->NO_STATUS == '1'
				lAtivo := .T.
				Exit
			EndIf
			SNO->(dbSkip())
		EndDo
		
		If !lAtivo
			Help(" ",1,"ATFA320OP",,STR0031,1,0) //"Essa operação é invalida caso não exista sequencia ativa"
			lRet := .F.
		EndIf
	EndIf
EndIf 

If lRet .And. nOpc == 5
	SNO->(dbSetOrder(2))//NO_FILIAL+NO_CBASE+NO_ITEM+NO_CODIGO+NO_SEQ  
	If SNO->(MsSeek(xFilial("SNO") + cBase + cItem))
		While SNO->(!EOF()) .And. SNO->(NO_FILIAL+NO_CBASE+NO_ITEM) == xFilial("SNO") + cBase + cItem
			If SNO->NO_CODIGO != cCodigo
				lHist := .T.
				Exit
			EndIf
			SNO->(dbSkip())
		EndDo
		
		If lHist
			Help(" ",1,"ATFA320HIST",,STR0032,1,0) //"Essa operação é inválida, pois existe outra transferencia para a ficha de imobilizado"
			lRet := .F.
		EndIf
	EndIf	
EndIf


RestArea(aAreaSNO)
RestArea(aArea)
Return lRet







































