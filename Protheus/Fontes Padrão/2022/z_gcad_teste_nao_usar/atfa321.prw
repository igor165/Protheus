#INCLUDE "atfa321.ch"
#Include "Protheus.ch"


Static lATF321Aut
Static aAutoCab
Static aAutoItens

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ATFA321  บ Autor ณ Felipe C. Seolin   บ Data ณ  16/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Controle de Bens em Terceiros				              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA321				                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ 
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFA321(cAlias,nReg,nOpc,nOpcAuto,xAutoCab,xAutoItens)
Local alArea		:= GetArea()

Private aRotina		:= MenuDef()
Private cCadastro	:= STR0001 //"Controle de bens em terceiros""

Default	cAlias		:= "SNP"
Default	nReg		:= 0
Default	nOpc		:= 3
Default nOpcAuto	:= 3
Default xAutoCab	:= {}
Default xAutoItens	:= {}

lATF321Aut			:= IIF(Len(xAutoCab)>0,.T.,.F.)

dbSelectArea("SN1")
dbSelectArea("SNP")

IF lATF321Aut
	aAutoCab	:= aClone(xAutoCab)
	aAutoItens	:= aClone(xAutoItens)
	MBrowseAuto(nOpcAuto,aAutoCab,"SNP")
ELSE
	mBrowse(6,1,22,75,"SNP",,,,,,)
ENDIF

RestArea(alArea)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ATF321Cadบ Autor ณ Felipe C. Seolin   บ Data ณ  16/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de Bens em Terceiros				              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA321				                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATF321Cad(cAlias,nReg,nOpc,xAutoCab,xAutoItens,lDireto)
Local olBtn			:= FWButtonBar():New()
Local nlOpcao		:= 0
Local alDms			:= FWGetDialogSize(oMainWnd)
Local alCpoEnch		:= {"NP_CODIGO","NP_CBASE","NP_ITEM","NP_FORNEC","NP_LOJA","NP_TIPCES","NOUSER"}
Local alEdtEnch		:= {}
Local clCpoGD		:= "NP_SEQ,NP_STATUS,NP_VIGINI,NP_VIGFIM,NP_CONTATO"
Local clNPCpoGD		:= "NP_CODIGO,NP_CBASE,NP_ITEM,NP_FORNEC,NP_LOJA,NP_TIPCES"
Local alEdtGD		:= {}
Local llSave		:= .F.
Local nPosBase		:= 0
Local nPosItem		:= 0
Local nMaxCols		:= 0   
Local cCodOri		:= ""
Local aAreaSN1		:= SN1->(GetArea())
Local lRet          := .T.
Local aAuxEdtGD	    := {}	
Local nX			:= 0

Private oFWLayer	:= FWLayer():New()
Private aTela[0][0]
Private aGets[0]
Private oGetSNP

Default xAutoCab	:= {}
Default xAutoItens	:= {}
Default	lDireto		:= .F.  


If !lDireto .And. SNP->(!EOF())
	lRet := AF321VLINI(nOpc,SNP->NP_CODIGO,SNP->NP_CBASE,SNP->NP_ITEM)
EndIf

IF lDireto
	aAutoCab	:= aClone(xAutoCab)
	aAutoItens	:= aClone(xAutoItens)
	nPosBase	:= aScan(aAutoCab,{|x| x[1] == "NP_CBASE"})
	nPosItem	:= aScan(aAutoCab,{|x| x[1] == "NP_ITEM"})
	nPosFornece	:= aScan(aAutoCab,{|x| x[1] == "NP_FORNEC"})
	nPosLojaFor	:= aScan(aAutoCab,{|x| x[1] == "NP_LOJA"})
ENDIF

If lRet
	If nOpc == 2 // Visualizar
		RegToMemory("SNP",.F.)
	ElseIf nOpc == 3 //Incluir
		RegToMemory("SNP",.T.)
		nlOpcao		:= GD_UPDATE
		alEdtEnch	:= {"NP_CBASE","NP_ITEM","NP_FORNEC","NP_LOJA","NP_TIPCES"}
		alEdtGD		:= {"NP_STATUS","NP_VIGINI","NP_VIGFIM","NP_CONTATO"}
		IF lDireto
			alEdtEnch	:= {"NP_FORNEC","NP_LOJA","NP_TIPCES"}
			M->NP_CBASE 	:= aAutoCab[nPosBase][2]
			M->NP_ITEM		:= aAutoCab[nPosItem][2]
			M->NP_FORNEC	:= aAutoCab[nPosFornece][2]
			M->NP_LOJA		:= aAutoCab[nPosLojaFor][2]
		ENDIF
	ElseIf nOpc == 4 //Alterar
		RegToMemory("SNP",.F.)
		nlOpcao		:= GD_UPDATE
		alEdtEnch	:= {"NP_TIPCES"}
		alEdtGD		:= {"NP_STATUS","NP_VIGINI","NP_VIGFIM","NP_CONTATO"}
	ElseIf nOpc == 5  //Excluir
		If !ATF321Del()
			Return()
		EndIf
		RegToMemory("SNP",.F.)
	ElseIf nOpc == 7 //Renovar
		If !AF321VlRen(SNP->NP_CODIGO,SNP->NP_CBASE,SNP->NP_ITEM)
			Return()
		EndIf
		RegToMemory("SNP",.F.)
		nlOpcao := GD_INSERT + GD_UPDATE
		alEdtGD		:= {"NP_STATUS","NP_VIGINI","NP_VIGFIM","NP_CONTATO"}
	ElseIf nOpc == 8 // Transferir
		If !AF321VlPer(SNP->NP_CBASE,SNP->NP_ITEM)
			Return()
		EndIf
		RegToMemory("SNP",.T.)
		cCodOri := SNP->NP_CODIGO
		nlOpcao := GD_UPDATE
		M->NP_CBASE	:= SNP->NP_CBASE
		M->NP_ITEM	:= SNP->NP_ITEM
		alEdtEnch	:= {"NP_FORNEC","NP_LOJA","NP_TIPCES"}
		alEdtGD		:= {"NP_STATUS","NP_VIGINI","NP_VIGFIM","NP_CONTATO"}
	ElseIf nOpc == 9
		RegToMemory("SNP",.F.)
	EndIf
	
	// Ponto de entrada para permitir edi็ใo de campos de usuแrio
	If ExistBlock("AF321EDT")
		aAuxEdtGD := ExecBlock("AF321EDT",.F.,.F.)
	  	If Len(aAuxEdtGD) >= 1
	  		For nX := 1 to Len(aAuxEdtGD)
	  			Aadd(alEdtGD, aAuxEdtGD[nX])
	  		Next nX++
	  	EndIf
	EndIf
	
	//Valida Bem baixado
	If nOpc != 2
		SN1->(dbSetOrder(1)) // N1_FILIAL+N1_CBASE+N1_ITEM
		If SN1->(dbSeek(xFilial("SN1") + M->(NP_CBASE+NP_ITEM) ))
			If !Empty(SN1->N1_BAIXA)
				Help(" ",1,"ATFA321BX",,STR0003,1,0)  //"Nใo ้ possํvel fazer o controle em terceiros de um bem baixado"
				Return Nil
			EndIf
		EndIf
	EndIf
	
	aHeader := ATF321Head(clCpoGD,clNPCpoGD,,"SNP")
	aCols := ATF321Cols(aHeader,"SNP",1,"SNP->NP_CODIGO",nOpc,,"NP_SEQ",,,,@nMaxCols)
	
	oDlg := MSDialog():New(alDms[1],alDms[2],alDms[3],alDms[4],STR0004,,,,nOr(WS_VISIBLE,WS_POPUP),,,,oMainWnd,.T.)  //"Bens em Terceiro"
	oFWLayer:Init(oDlg,.T.)
	oFWLayer:AddCollumn('Col1',100,.F.)
	oFWLayer:AddWindow('Col1','Win1',cCadastro,27,.T.,.T.)  //"Controle de bens em terceiros"
	oFWLayer:AddWindow('Col1','Win2',,73,.T.,.T.)
	oPanel1 := oFWLayer:GetWinPanel('Col1','Win1')
	oPanel1:FreeChildren()
	oPanel2 := oFWLayer:GetWinPanel('Col1','Win2')
	oPanel2:FreeChildren()
	oEnch := MsMGet():New("SNP",nReg,nOpc,,,,alCpoEnch,{0,0,50,50},alEdtEnch,3,,,,oPanel1,,.T.)
	oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	oGetSNP := MsNewGetDados():New(0,0,150,200,nlOpcao,"AllwaysTrue","AllwaysTrue","+NP_SEQ",alEdtGD,000,nMaxCols,"AllwaysTrue","","AllwaysFalse",oPanel2,aHeader,aCols)
	oGetSNP:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	olBtn:Init(oPanel2,015,015,CONTROL_ALIGN_BOTTOM,.T.)
	
	If nOpc == 2
		Activate MsDialog oDlg on Init EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})
	Else
		Activate MsDialog oDlg on Init EnchoiceBar(oDlg,{||Eval({||Iif(Obrigatorio(aGets,aTela) .and. ATFDtVig(nOpc),(llSave := ATF321Grv(nOpc,lDireto,cCodOri,alEdtGD),oDlg:End()),Nil)})},{||oDlg:End()})
	Endif
	If !llSave
		RollBackSX8()
	Else
		ConfirmSX8()
	EndIf
	
Endif

RestArea(aAreaSN1)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFA321   บAutor  ณMicrosiga           บ Data ณ  07/20/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF321VlRen(cCodigo,cCodBase,cItem)
Local lRet 		:= .T.
Local cCodAux	:= ""
Local aArea		:= GetArea()
Local aAreaSNP 	:= SNP->(GetArea())

SNP->(dbSetOrder(2)) //NP_FILIAL+NP_CBASE+NP_ITEM+NP_CODIGO+NP_SEQ
If SNP->(MsSeek( xFilial("SNP") + cCodBase + cItem ) )
	While SNP->(!EOF()) .And. Alltrim( SNP->(NP_FILIAL+NP_CBASE+NP_ITEM) ) == Alltrim( xFilial("SNP") + cCodBase + cItem )
		cCodAux := SNP->NP_CODIGO
		SNP->(dbSkip())
	EndDo
EndIf

If Alltrim(cCodAux) != cCodigo
	lRet := .F.
	Help(" ",1,"ATFA321REN",,STR0005,1,0)  //"Controle do bem jแ foi transferido e nใo pode ser renovado."
EndIf

RestArea(aAreaSNP)
RestArea(aArea)
Return lRet               

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ATF321Grvบ Autor ณ Felipe C. Seolin   บ Data ณ  17/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Manipula็ใo de dados da tabela SNP			              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA321				                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ATF321Grv(nOpc,lDireto,cCodOri,alEdtGD)
Local alCpoEnch	:= {"NP_CODIGO","NP_CBASE","NP_ITEM","NP_FORNEC","NP_LOJA","NP_TIPCES"}
Local alCpoGD	:= {"NP_SEQ","NP_STATUS","NP_VIGINI","NP_VIGFIM","NP_CONTATO"}
Local alValEnch	:= {}
Local alValGD	:= {}
Local nlQuant	:= 0
Local nlPos	:= 0
Local nlI		:= 0
Local nlJ		:= 0
Local nX		:= 0
Local clCod 	:= M->NP_CODIGO
Local clFilial	:= M->NP_FILIAL
Local clCodBase := M->NP_CBASE
Local clItem 	:= M->NP_ITEM
Local cForOri	:= ""
Local cLojOri	:= "" 	   	  
Local lRet		:= .T.
Local nPosArray := 0  

Default lDireto := .F.
Default cCodOri := ""
Default alEdtGD := {}

If Len(alEdtGD) > 4		//Verifica se GetDados obteve campos personalizados do PE AF321EDT
	For nX := 5 to Len(alEdtGD)
	  	Aadd(alCpoGD, alEdtGD[nX])
	Next nX++
EndIf

If nOpc == 3 .or. nOpc == 4 .or. nOpc == 7 .or. nOpc == 8 .and. Obrigatorio(aGets,aTela)
	For nlI := 1 to Len(oGetSNP:aCols)
		aAdd(alValEnch,Array(Len(alCpoEnch)))
		nlPos := Len(alValEnch)
		For nlJ := 1 to Len(alCpoEnch)
			alValEnch[nlPos][nlJ] := M->&(alCpoEnch[nlJ])
		Next nlJ
		aAdd(alValGD,Array(Len(alCpoGD)))
		nlPos := Len(alValGD)
		For nlJ := 1 to Len(alCpoGD)
			alValGD[nlPos][nlJ] := oGetSNP:aCols[nlI][nlJ]
		Next nlJ
		nlQuant ++
	Next nlI
	DBSelectArea("SNP")
	SNP->(DBSetOrder(2))
	For nlI := 1 to nlQuant
		If nOpc == 3
			If DbSeek(xFilial("SNP")+M->NP_CBASE+M->NP_ITEM+M->NP_CODIGO)
				llRecLock := .F.
			Else
				llRecLock := .T.
			EndIf
		ElseIf SNP->(DBSeek(xFilial("SNP") + M->NP_CBASE + M->NP_ITEM + M->NP_CODIGO + oGetSNP:aCols[nlI][1]))
			llRecLock := .F.
		Else
			llRecLock := .T.
		EndIf
		RecLock("SNP",llRecLock)
		SNP->NP_FILIAL := xFilial("SNP")
		For nlJ := 1 to Len(alCpoEnch)
			FieldPut(FieldPos(alCpoEnch[nlJ]),alValEnch[nlI][nlJ])
		Next nlJ
		For nlJ := 1 to Len(alCpoGD)
			nPosArray := aScan( oGetSNP:aHeader, { |x| AllTrim( x[2] ) == Alltrim( alCpoGD[nlJ] ) } )  //busca a posicao no aheader da grade 
			If nPosArray > 0
				If  nPosArray <= Len(alValGD[nlI])
					FieldPut(FieldPos(alCpoGD[nlJ]),alValGD[nlI][nPosArray])
				Else  //senao pega do acols do objeto pois ocorria error log quando cliente nao incluia os campos via PE AF321EDT
					FieldPut(FieldPos(alCpoGD[nlJ]),oGetSNP:aCols[nlI][nPosArray])
				EndIf
			EndIf
		Next nlJ   
		SNP->(MsUnlock())
	Next nlI
	
	If lRet 
		DBSelectArea("SN1")
		SN1->(DBSetOrder(1))
		If SN1->(DBSeek(xFilial("SN1") + clCodBase + clItem))
			RecLock("SN1",.F.)
			SN1->N1_STATUS  := "1"
			SN1->N1_FORNEC	:= SNP->NP_FORNEC
			SN1->N1_LOJA	:= SNP->NP_LOJA
			If !lDireto 
				SN1->N1_TPCTRAT := "3"
			EndIf
			SN1->(MsUnLock())
		EndIf
	EndIf
	
	If nOpc == 8
		ATF321TC(cCodOri)	
	EndIf
		
ElseIf nOpc == 5
	DBSelectArea("SNP")
	SNP->(DBSetOrder(1))
	If SNP->(DBSeek(xFilial("SNP") + clCod))
		While Alltrim(SNP->NP_FILIAL) == Alltrim(clFilial) .and. Alltrim(SNP->NP_CODIGO) == Alltrim(clCod)
			If RecLock("SNP",.F.,.T.)
				DBDelete()
				SNP->(MsUnLock())
			Else
				lRet := .F.
			EndIf
			SNP->(DBSkip())
		EndDo
	EndIf
	If lRet
		DBSelectArea("SN1")
		SN1->(DBSetOrder(1))
		If SN1->(DBSeek(xFilial("SN1") + clCodBase + clItem))
			If !Empty(SN1->N1_NFISCAL)
				AF321NFOR(SN1->N1_CBASE,SN1->N1_NFITEM,@cForOri,@cLojOri)
			EndIf 
			SN1->(RecLock("SN1",.F.))
				SN1->N1_STATUS := "2"
				SN1->N1_TPCTRAT:= "1"
				SN1->N1_FORNEC := cForOri 	 
				SN1->N1_LOJA   := cLojOri
			SN1->(MsUnLock())
		ELSE
			lRet := .F.
		ENDIF
	EndIf
EndIf

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ATFDtVig บ Autor ณ Felipe C. Seolin   บ Data ณ  17/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo de Data de Vig๊ncia				              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA321				                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ATFDtVig(nOpc)
Local aSaveArea	:= GetArea()
Local lRet			:= .T.
Local nlI			:= 0
Local nTamSeq		:= TamSx3("NP_SEQ")[1]
Local dDataIni		:= ""
Local dDataFim		:= ""
Local nPosVigIni 	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "NP_VIGINI" } )
Local nPosVigFim 	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "NP_VIGFIM" } )
Local nPosContato	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "NP_CONTATO" } )
Local aArea
Local aAreaSNP
Local dUltDepr 	:= GetMV("MV_ULTDEPR")
Local cWhileSNP 	:= ""
Default nOpc 		:= 0

DbSelectArea("SNP")
SNP->(DbSetOrder(2)) //NP_FILIAL+NP_CBASE+NP_ITEM+NP_CODIGO+NP_SEQ
If nOpc != 7 .AND. nOpc != 5
	SNP->(MsSeek(xFilial("SNP")+M->(NP_CBASE+NP_ITEM+NP_CODIGO+StrZero(Len(oGetSNP:aCols),nTamSeq))))
Else
	SNP->(MsSeek(xFilial("SNP")+M->(NP_CBASE+NP_ITEM+NP_CODIGO+StrZero((Len(oGetSNP:aCols))-1,nTamSeq))))
EndIf

dDataIni := SNP->NP_VIGINI //atribui a data inicial do contrato em vigencia a variavel
dDataFim := SNP->NP_VIGFIM //atribui a data final do contrato em vigencia a variavel

If nOpc != 5

	If lRet .And. (Empty(oGetSNP:aCols[Len(oGetSNP:aCols)][nPosVigIni]) .Or. Empty(oGetSNP:aCols[Len(oGetSNP:aCols)][nPosVigFim]) )
		lRet := .F.
		Help(" ",1,"ATFA321DEx",,STR0006,1,0)  //"Por favor, preencher os campos de inicio e fim de vigencia"
	EndIf
		
	If lRet .And. Empty(oGetSNP:aCols[Len(oGetSNP:aCols)][nPosContato])
		lRet := .F.
		Help(" ",1,"ATFA321CONT",,STR0007,1,0)  //"Por favor, preencher o nome do contato"
	EndIf
		
	If lRet .And. oGetSNP:aCols[Len(oGetSNP:aCols)][nPosVigIni] <= dDataFIM .AND. nOpc != 4
		lRet := .F.
		Help(" ",1,"ATFA321DINI1",,STR0008,1,0)  //"Data de vig๊ncia inicial menor que a data da vigencia final anterior"
	ElseIf lRet .AND. nOpc == 4 .AND. Len(oGetSNP:aCols)>1
		If oGetSNP:aCols[(Len(oGetSNP:aCols))][nPosVigIni] <= oGetSNP:aCols[(Len(oGetSNP:aCols))-1][nPosVigFim]
			lRet := .F.
			Help(" ",1,"ATFA321DINI2",,STR0008,1,0)  //"Data de vig๊ncia inicial menor que a data da vigencia final anterior"
		EndIf	
	EndIf
		
	If lRet .And. oGetSNP:aCols[Len(oGetSNP:aCols)][nPosVigFim] <= oGetSNP:aCols[Len(oGetSNP:aCols)][nPosVigIni]
		lRet := .F.
		Help(" ",1,"ATFA321DFIM",,STR0009,1,0)  //"Data de vig๊ncia final incorreta"
	EndIf
		
	If lRet .and. (nOpc == 7 .or. nOpc == 8)
		DbSelectArea("SNP")
		aAreaSNP:=SNP -> (GetArea())
		dbsetorder(2)
		If DbSeek(xFilial("SNP")+M->NP_CBASE+M->NP_ITEM)
			If oGetSNP:aCols[Len(oGetSNP:aCols)][nPosVigIni] <= dUltDepr //se data inicial digitada for menor que a data da ultima depreciacao
				lRet := .F.
				Help(" ",1,"ATFA321DINI3",,STR0008,1,0)
			ElseIf oGetSNP:aCols[Len(oGetSNP:aCols)][nPosVigFim] <= dUltDepr //se data final digitada for menor que a data da ultima depreciacao
				lRet := .F.
				Help(" ",1,"ATFA321DFIM",,STR0009,1,0)
			EndIF				
		EndIf
		
		SNP->(Dbskip())
		RestArea(aAreaSNP)
	EndIf
EndIf

RestArea(aSaveArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ATF321TC บ Autor ณ Felipe C. Seolin   บ Data ณ  18/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Encerra Controle para op็ใo de Transfer๊ncia de Controle	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA321				                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ATF321TC(clCod)
Local alArea	:= GetArea()

DBSelectArea("SNP")
SNP->(DBSetOrder(1))
If SNP->(DBSeek(xFilial("SNP") + clCod))
	While Alltrim(SNP->NP_FILIAL) == Alltrim(xFilial("SNP")) .and. Alltrim(SNP->NP_CODIGO) == Alltrim(clCod)
		If RecLock("SNP",.F.)
			SNP->NP_STATUS := "2"
			SNP->(MsUnlock())
		EndIf
		SNP->(DBSkip())
	EndDo
EndIf

RestArea(alArea)
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ATF321Delบ Autor ณ Felipe C. Seolin   บ Data ณ  26/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida exclusใo de Bem de Terceiro			              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA321				                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ATF321Del()
Local alArea	:= GetArea()
Local alAreaSN1	:= SN1->(GetArea())
Local alAreaSN4	:= SN4->(GetArea())
Local lRet		:= .T.

DBSelectArea("SN1")
SN1->(DBSetOrder(1))
If lRet
	If SN1->(DBSeek(SNP->NP_FILIAL + SNP->NP_CBASE + SNP->NP_ITEM))
		If SN1->N1_STATUS == "2"
			lRet := .F.
			Help(" ",1,"ATFA321BLOQ",,STR0010,1,0)  //"Bem estแ bloqueado"
		EndIf
	EndIf
EndIf

DBSelectArea("SN4")
SN4->(DBSetOrder(1)) 
If lRet
	If SN4->(DBSeek(SNP->NP_FILIAL + SNP->NP_CBASE + SNP->NP_ITEM))
		While SN4->(!EOF()) .AND. 	SN4->N4_FILIAL 	== SNP->NP_FILIAL .AND.;
			SN4->N4_CBASE 	== SNP->NP_CBASE .AND.;
			SN4->N4_ITEM	== SNP->NP_ITEM
			
			IF SN4->N4_OCORR != "05" // AQUISICAO
				lRet := .F.
				Help(" ",1,"ATFA321MOV",,STR0011,1,0)  //"Bem possui movimentos"
				Exit
			ENDIF
			SN4->(DbSkip())
		End
	EndIf
EndIf

If lRet
	lRet := AF321VlPer(SNP->NP_CBASE,SNP->NP_ITEM)
EndIf

RestArea(alAreaSN4)
RestArea(alAreaSN1)
RestArea(alArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ATF321Bxaบ Autor ณ Felipe C. Seolin   บ Data ณ  30/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de Baixa do Bem em Terceiro			              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA321				                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/       
Function ATF321Bxa(clAlias,nlReg,nlOpc)

Local aArea			:= GetArea()
Local aAreaSN1		:= SN1->(GetArea())
Local aAreaSN3		:= SN3->(GetArea())
Local cBase			:= SNP->NP_CBASE
Local cItem			:= SNP->NP_ITEM  
Local lRet          := .F.   
Local cForOri		:= ""
Local cLojOri		:= ""

lRet := AF321VLINI(nlOpc,SNP->NP_CODIGO,SNP->NP_CBASE,SNP->NP_ITEM)

//Inserido por Carlos Queiroz em 26/08/11
If lRet
	DbSelectArea("SNP")
	SNP->(dbSetOrder(2))//NP_FILIAL+NP_CBASE+NP_ITEM+NP_CODIGO+NP_SEQ
	If SNP->(dbSeek(xFilial("SNP") + cBase + cItem  ) )
		While SNP->(!Eof()) .And. Alltrim(SNP->(NP_FILIAL+NP_CBASE+NP_ITEM)) == Alltrim(xFilial("SNP") + cBase + cItem )
			RecLock("SNP",.F.)
			SNP->NP_STATUS := '2'
			MsUnLock()
			SNP->(dbSkip())
		EndDo
	EndIf
	
	DBSelectArea("SN1")
	SN1->(DBSetOrder(1))
	If SN1->(DBSeek(xFilial("SN1")  + cBase + cItem ))
		If !Empty(SN1->N1_NFISCAL)
			AF321NFOR(SN1->N1_CBASE,SN1->N1_NFITEM,@cForOri,@cLojOri)
		EndIf 
		SN1->(RecLock("SN1",.F.))
			SN1->N1_TPCTRAT:= "1"
			SN1->N1_FORNEC	:= cForOri
			SN1->N1_LOJA	:= cLojOri
		SN1->(MsUnLock())
	EndIf
EndIf


RestInter()
RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)

Return
         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF321VlPer   บAutor  ณMicrosiga           บ Data ณ  07/20/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se o bem possui um periodo vแlido                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF321VlPer(cBase,cItem) 
Local lRet := .F.
Local aArea:= GetArea()
Local aAreaSNP:= SNP->(GetArea())

SNP->(dbSetOrder(2)) //NP_FILIAL+NP_CBASE+NP_ITEM+NP_CODIGO+NP_SEQ
If SNP->(MsSeek( xFilial("SNP") + cBase + cItem ) )
	While SNP->(!EOF()) .And. Alltrim( SNP->(NP_FILIAL+NP_CBASE+NP_ITEM) ) == Alltrim( xFilial("SNP") + cBase + cItem )
		If SNP->NP_STATUS == '1' // Ativo
			lRet := .T. 
		EndIf
		SNP->(dbSkip())
	EndDo
EndIf

If !lRet 
	Help(" ",1,"ATFA321PVAL",,STR0012,1,0)  //"Bem selecionado jแ estแ classificado como bem em terceiro"
EndIf

RestArea(aAreaSNP)
RestArea(aArea)
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATF321ColsบAutor  ณFelipe C. Seolin    บ Data ณ  02/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que cria aCols                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaHeader : aHeader aonde o aCOls serแ baseado                บฑฑ
ฑฑบ          ณcAlias  : Alias da tabela                                   บฑฑ
ฑฑบ          ณnIndice : Indice da tabela que sera usado para              บฑฑ
ฑฑบ          ณcComp   : Informacao dos Campos para ser comparado no While บฑฑ
ฑฑบ          ณnOpc    : Op็ใo do Cadastro                                 บฑฑ
ฑฑบ          ณaCols   : Opcional caso queira iniciar com algum elemento   บฑฑ
ฑฑบ          ณcCPO_ITEM: Campo de item a ser inicializado com '001'		  บฑฑ
ฑฑบ          ณcINDICE : Chave de compara็ใo da tabela de item             บฑฑ
ฑฑบ          ณcCPOMemo: Opcional Nome do campo de c๓digo do MEMO          บฑฑ
ฑฑบ          ณcMemo   : Nome do campo memo virtual                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA321	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ATF321Cols(aHeader,cAlias,nIndice,cComp,nOpc,aCols,cCPO_ITEM,cINDICE,cCPOMemo,cMemo,nMaxCols)
Local nlI			:= 0
Local nlCols		:= 0
Local alArea		:= GetArea()

Default cCPO_ITEM	:= ""
Default cCPOMemo	:= ""
Default cMemo		:= ""
Default nMaxCols	:= 0

If nOpc == 3
	aCols := {Array(Len(aHeader) + 1)}
	aCols[1,Len(aHeader) + 1] := .F.
	For nlI := 1 to Len(aHeader)
		If AllTrim(aHeader[nlI,2]) == "NP_SEQ"
			aCols[1,nlI] := "001"
		Else
			aCols[1,nlI] := CriaVar(aHeader[nlI,2])
		EndIf
	Next nlI
	nMaxCols++
Else
	aCols := {}
	DBSelectArea(cAlias)
	(cAlias)->(DBSetOrder(nIndice))
	If (cAlias)->(DBSeek(xFilial(cAlias) + M->NP_CODIGO))
		While (cAlias)->(!EOF()) .and. (cAlias)->&cComp == M->NP_CODIGO
			aAdd(aCols,Array(Len(aHeader) + 1))
			For nlI := 1 to Len(aHeader)
				aCols[Len(aCols),nlI] := FieldGet(FieldPos(aHeader[nlI,2]))
			Next nlI
			aCols[Len(aCols),Len(aHeader) + 1] := .F.
			nMaxCols++
			(cAlias)->(DBSkip())
		EndDo
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATF321HeadบAutor  ณFelipe C. Seolin    บ Data ณ  02/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria o aHeader da GetDados                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA321	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ATF321Head(cCampos,cExc,aHeader,cAlias)
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATF321WHENบAutor  ณArnaldo Raymundo Jr.บ Data ณ  02/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se o campo pode ser alterado em funcao da linha     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA321	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATF321WHEN()

Local lRet	:= .T.

If Type("oGetSNP") == "O"
	lRet := oGetSNP:nAT==oGetSNP:nMax
ELSE
	lRet := .F.
ENDIF

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATF321VSN1   บAutor  ณMicrosiga           บ Data ณ  07/18/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza o cadastro no SN1                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATF321VSN1(cAlias,nReg,nOpc)

Local aArea := GetArea()
Local cChave:= ""

dbSelectArea("SN3")
dbSelectArea("SN1")

SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
SN1->(dbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Posiciona o SN1 em funฦo do SN3.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

cChave := SNP->NP_CBASE + SNP->NP_ITEM
If SN1->(dbSeek( xFilial("SN1") + cChave )) .And. SN3->(dbSeek( xFilial("SN3") + cChave ))
	FWExecView( STR0018 , 'ATFA012',1/*nOpc*/,/*oDlg*/,{||.T.},/*bOk*/,/*nPercReducao*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/) //'Visualizar bem'
Else
	HELP( " ",1,"RECNO" )
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Restaura posiฦo do SN3.         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFA321   บAutor  ณMicrosiga           บ Data ณ  07/19/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se o bem selecionado ้ vแlido para incluir a informaบฑฑ
ฑฑบ          ณ็ใo de bens em terceiros                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF321VLBEM(cBase,cItem)
Local lRet := .T.
Local aArea:= GetArea()
Local aAreaSN1 := SN1->(GetArea())
Local aAreaSNP := SNP->(GetArea())  

SN1->(dbSetOrder(1))//N1_FILIAL+N1_CBASE+N1_ITEM
SNP->(dbSetOrder(2))//NP_FILIAL+NP_CBASE+NP_ITEM+NP_CODIGO+NP_SEQ

If !Empty(cBase) .And. !Empty(cItem)
	If lRet .And. !SN1->(dbSeek(xFilial("SN1") + cBase + cItem ))
		lRet := .F.
		HELP(" ",1,"REGNOIS")
	EndIf
	
	If lRet .And. Alltrim(SN1->N1_TPCTRAT) $ '2/3'
		lRet := .F.
		Help(" ",1,"ATFA321BEM",,STR0012,1,0)  //"Bem selecionado jแ estแ classificado como bem em terceiro"
	EndIf
	
	If lRet .And. Alltrim(SN1->N1_STATUS) $ '0'
		lRet := .F.
		Help(" ",1,"ATFA321CLS",,STR0029,1,0)  //"Nใo ้ possํvel fazer o controle em terceiros de um bem nใo classificado"
	EndIf
	
	If lRet .And. !Empty(SN1->N1_BAIXA)
		lRet := .F.
		Help(" ",1,"ATFA321BX",,STR0003,1,0)  //"Nใo ้ possํvel fazer o controle em terceiros de um bem baixado"
	EndIf
	//Informada nOpc = 99 para que a fun็ใo utilize este processo em uma inclusใo mas nใo utilize quando a nOpc for igual a 3.	
	If lRet .And. SNP->(dbSeek(xFilial("SNP") + cBase + cItem ))
		lRet := !AF321VLINI(99,SNP->NP_CODIGO,SNP->NP_CBASE,SNP->NP_ITEM)

		If !lRet
			Help(" ",1,"ATFA321CLA",,STR0012,1,0)  //"Bem selecionado jแ estแ classificado como bem em terceiro"
		Endif
		
	EndIf
EndIf


RestArea(aAreaSNP)
RestArea(aAreaSN1)
RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF321DTINI  บAutor  ณMicrosiga           บ Data ณ  07/19/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a inicializa็ao do campo de data inicial                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF321DTINI()
Local nPosVigIni := 0
Local nPosVigFim := 0
Local nAt := 0
Local dDataIni := STOD("")

If oGetSNP != Nil
	nPosVigIni := aScan( oGetSNP:aHeader, { |x| AllTrim( x[2] ) == "NP_VIGINI" } )
	nPosVigFim := aScan( oGetSNP:aHeader, { |x| AllTrim( x[2] ) == "NP_VIGFIM" } )
	nAt := oGetSNP:nAt
	dDataIni := oGetSNP:aCols[nAt][nPosVigFim] + 1
EndIf

Return dDataIni

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MenuDef  บAutor  ณFelipe C. Seolin    บ Data ณ  02/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria botoes de rotina do Browse                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA321	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := {}

aAdd(aRotina,{STR0013,"AxPesqui"			,0,1})	 //"Pesquisar"
aAdd(aRotina,{STR0014,"ATF321Cad"			,0,2})	 //"Visualizar Dados"
aAdd(aRotina,{STR0015,"ATF321Cad"			,0,3})	 //"Incluir"
aAdd(aRotina,{STR0016,"ATF321Cad"			,0,4})	 //"Atualizar Dados"
aAdd(aRotina,{STR0017,"ATF321Cad"			,0,5})	 //"Excluir Dados"
aAdd(aRotina,{STR0018,"ATF321VSN1"	,0,2})	 //"Visualizar Bem"
aAdd(aRotina,{STR0019,"ATF321Cad"			,0,6})	 //"Renovar Bem"
aAdd(aRotina,{STR0020,"ATF321Cad"			,0,6})	 //"Transferir Controle"
aAdd(aRotina,{STR0023,"ATF321Bxa"			,0,6})   //"Encerrar Controle"
aAdd(aRotina,{STR0021,"ATFR326"				,0,6})	 //"Demonstrativo"
aAdd(aRotina,{STR0022,"MSDOCUMENT"			,0,4})	 //"Conhecimento"
Return(aRotina)      


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AF321VLINI บAutor  ณAlvaro Camillo Neto บ Data ณ  04/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a inicializa็ใo da rotina                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA321	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF321VLINI(nOpc,cCodigo,cBase,cItem)
Local aArea 		:= GetArea()
Local aAreaSNP 	:= SNP->(GetArea())
Local lRet 		:= .T.
Local lAtivo      := .F.
Local lHist       := .F.

If nOpc == 4 .Or.  nOpc == 5 .Or.  nOpc == 7 .Or.  nOpc == 8 .Or.  nOpc == 9 .Or.  nOpc == 10 .Or. nOpc == 99 
	SNP->(dbSetOrder(1))//NP_FILIAL+NP_CODIGO+NP_SEQ 
	If SNP->(MsSeek(xFilial("SNP") + cCodigo))
		While SNP->(!EOF()) .And. SNP->(NP_FILIAL+NP_CODIGO) == xFilial("SNP") + cCodigo
			If SNP->NP_STATUS == '1'
				lAtivo := .T.
				Exit
			EndIf
			SNP->(dbSkip())
		EndDo

		If !lAtivo
		    if nOpc != 99
				Help(" ",1,"ATFA321OP",,STR0026,1,0) //"Essa opera็ใo ้ invalida caso nใo exista sequencia ativa"
			EndIf
			lRet := .F.
		EndIf
	EndIf
EndIf 

If lRet .And. nOpc == 5
	SNP->(dbSetOrder(2))//NP_FILIAL+NP_CBASE+NP_ITEM+NP_CODIGO+NP_SEQ  
	If SNP->(MsSeek(xFilial("SNP") + cBase + cItem))
		While SNP->(!EOF()) .And. SNP->(NP_FILIAL+NP_CBASE+NP_ITEM) == xFilial("SNP") + cBase + cItem
			If SNP->NP_CODIGO != cCodigo
				lHist := .T.
				Exit
			EndIf
			SNP->(dbSkip())
		EndDo
		
		If lHist
			Help(" ",1,"ATFA321HIST",,STR0027,1,0) //"Essa opera็ใo ้ invแlida, pois existe outra transferencia para a ficha de imobilizado"
			lRet := .F.
		EndIf
	EndIf	
EndIf


RestArea(aAreaSNP)
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AF321NFORบAutor  ณDiogo Vieira  		บ Data ณ  30/08/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Encontra o Fornecedor Original no Documento de Entrada     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA321	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF321NFOR(cCbase,cNfItem,cForOri,cLojOri)
Local cAliasAux := GetNextAlias()

Default cCbase	:= ""
Default cNfItem	:= ""
Default cForOri := ""
Default cLojOri	:= ""

BeginSQL Alias cAliasAux
	SELECT 
		D1_FORNECE, D1_LOJA 
		FROM 
			%Table:SD1% 
			WHERE 
				D1_FILIAL   = %xFilial:SD1% AND
				D1_CBASEAF  = %Exp:cCbase+cNfItem% AND
				D1_FORNECE <> %Exp:""% AND
				%NotDel%	
EndSQL

If !(cAliasAux)->(Eof()) 
 	cForOri := (cAliasAux)->D1_FORNECE
 	cLojOri := (cAliasAux)->D1_LOJA 		
EndIf
(cAliasAux)->(dbCloseArea())

Return