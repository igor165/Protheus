// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 12     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "VEIXC008.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ VEIXC008 ³ Autor ³ Robson Nayland        ³ Data ³ 11/07/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Consulta andamento de Venda de Veiculos ( VIAVEIB29 )       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXC008(cFilAte,cNumAte)
Private	cCadastro	:=	STR0001 // Consulta andamento da Venda
Private aRotina   	:= 	MenuDef()
Private aCores    	:= 	{{'VV9->VV9_STATUS == "A" .AND. VXA018VEIVD()','lbok_ocean'},;  // Em Aberto com Veiculo ja Vendido
{'VV9->VV9_STATUS == "A"','BR_VERDE'},;		// Em Aberto
{'VV9->VV9_STATUS == "P"','BR_AMARELO'},;	// Pendente de Aprovacao
{'VV9->VV9_STATUS == "O"','BR_BRANCO'},;	// Pre-Aprovado
{'VV9->VV9_STATUS == "L"','BR_AZUL'},;		// Aprovado
{'VV9->VV9_STATUS == "R"','BR_LARANJA'},;	// Reprovado
{'VV9->VV9_STATUS == "F"','BR_PRETO'},;		// Finalizado
{'VV9->VV9_STATUS == "C"','BR_VERMELHO'}}	// Cancelado
Default cFilAte := ""
Default cNumAte := ""

//////////////////////////////////////////////////////////////////////////////
// Ponto de Entrada para manipular o aCores ( VV9_STATUS )                  //
//////////////////////////////////////////////////////////////////////////////
If 	( ExistBlock("VM011LEG") )
	aCoresUsr := ExecBlock("VM011LEG",.F.,.F.,{aCores,"C"})
	If ( ValType(aCoresUsr) == "A" )
		aCores := aClone(aCoresUsr)
	EndIf
EndIf

//////////////////////////////////////////////////////////////////////////////
// Ponto de Entrada para manipular o aCores ( VV9_STATUS )                  //
//////////////////////////////////////////////////////////////////////////////
If Empty(cNumAte)
	mBrowse(,,,,"VV9",,,,,,aCores)
Else
	DbSelectArea("VV9")
	DbSetOrder(1)
	DbSeek(cFilAte+cNumAte)
	VXC008()
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³  VXC008      ºAutor  ³Robson Nayland  º Data ³  02/19/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³  ABRE A CONSULTA DO fOLLOW up                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXC008(cAlias,nReg,nOpc)
Local cQuery    := ""
Local oDlg 		:= NIL
Local oFWLayer	:= NIL
Local oPanelTop := NIL
Local oPanelDown:= NIL
Local oMsMGt1   := NIL
Local oMsMGet2  := NIL
Local oFolder   := NIL
Local AliasFold2:= GetNextAlias()
Local AliasFold3:= GetNextAlias()
Local AliasFold5:= GetNextAlias()
Local AliasFold6:= GetNextAlias()
Local AliasFold7:= GetNextAlias()
Local AliasFold8:= GetNextAlias()
Local aCpoFold2 := {}
Local aCpoFold3 := {}
Local aCpoFold4 := {}
Local aCpoFold5 := {}
Local aCpoFold6 := {}
Local aCpoFold7 := {}
Local aCpoFold8 := {}
Local lCloseButt:= .T.
Local cNumTit   := ""
Local cPreTit   := ""
Local cStatus   := ""
Local cTipoVen  := ""
Local nI	    := 1
Local aCoord    := {}
Local oPendente	:= LoadBitmap(GetResources(),"BR_VERMELHO") // Pendente
Local oAprovRest:= LoadBitmap(GetResources(),"BR_AMARELO")  // Aprovado com restricoes
Local oAprovado	:= LoadBitmap(GetResources(),"BR_VERDE")    // Aprovado
Local oRejeitado:= LoadBitmap(GetResources(),"BR_PRETO")    // Rejeitado
Local oDelUsuar	:= LoadBitmap(GetResources(),"BR_LARANJA")  // Deletado usuario
Local oRecebido := LoadBitmap(GetResources(),"BR_PINK")     // Recebido pelo Caixa
Local aTit2     := {}
Local aTit3     := {}
Local aTit4     := {}
Local aTit5     := {}
Local aTit7     := {}
Local aTit8     := {}
Local aDad2     := {}
Local aDad3	    := {}
Local aDad4	    := {}
Local aDad5	    := {}
Local aDad7     := {}
Local aDad8     := {}
Local aTam2     := {}
Local aTam3     := {}
Local aTam4     := {}
Local aTam5     := {}
Local aTam7     := {}
Local aTam8     := {}
Local aRetCpo	:= {}
Local aCpoEnch	:= {}
Local aFolder   := {}
Local cFilVZ7   := xFilial("VZ7")
Local cFilVZX   := xFilial("VZX")
Local cFilVAX   := xFilial("VAX")
Local cFilVAY   := xFilial("VAY")
Local cFilSF2   := xFilial("SF2")
Local cFilVV1   := xFilial("VV1")
Local cFilVVG   := xFilial("VVG")
Local cFilVS9   := xFilial("VS9")
Local cFilVSA   := xFilial("VSA")
Local cFilSE1   := xFilial("SE1")
Local lDFisico  := ( SE1->(FieldPos("E1_DFISICO")) > 0 ) 
nOpc := 2
Private aBotEnc := {}
If !FM_PILHA("VEIXX002") .and. !FM_PILHA("VEIXX030")
	AADD(aBotEnc, {"VERNOTA" ,{|| VEIXX002(NIL,NIL,NIL,2,) },(STR0002)} ) // Visualiza o Atendimento
	AADD(aBotEnc, {"papel_escrito" ,{|| IIf(!Empty(VVA->VVA_CHAINT),VEIVC140(VV1->VV1_CHASSI, VV1->VV1_CHAINT),.t.) },(STR0003)} ) // Rastreamento do Veiculo
EndIf

AAdd( aFolder, STR0004 ) // Dados do Cliente
AAdd( aFolder, STR0005 ) // Tarefas
AAdd( aFolder, STR0006 ) // Outras Vendas
AAdd( aFolder, STR0007 ) // Veiculo
AAdd( aFolder, STR0008 ) // Faturamento
AAdd( aFolder, STR0009 ) // Financeiro
AAdd( aFolder, STR0010 ) // Troco
AAdd( aFolder, STR0011 ) // Cheques Devolvidos

aAdd( aCpoFold2,{"VAY_STATUS","VAY_USUEXE","VAY_USUEXE","VAY_CODTAR","VAX_DESTAR","VAY_DATSOL","VAY_DATEXE","VAY_HOREXE"})
aAdd( aCpoFold3,{"VZ7_ITECAM","VZX_DESCAM","VZ7_VALITE","VZ7_AGRVLR"})
aAdd( aCpoFold4,{"F2_DOC","F2_SERIE","F2_EMISSAO","F2_VALBRUT","VVG_LOCPAD","VVG_LOCALI"})
aAdd( aCpoFold5,{"VAY_STATUS","E1_NUM","E1_PREFIXO","VS9_TIPPAG","VSA_DESPAG","E1_EMISSAO","E1_VENCREA","E1_BAIXA","E1_VALOR","E1_SALDO","Responsável","E1_LOJA","E1_PARCELA"})
aAdd( aCpoFold7,{"VZ7_ITECAM","VZX_DESCAM","VZ7_VALITE"})
aAdd( aCpoFold8,{"EF_ALINEA1","EF_DTALIN1","EF_ALINEA2","EF_DTALIN2"})

//+--------------------------------------------+
//| Captura a coordenada interna da MainWindow |
//+--------------------------------------------+
//aCoord := GetDialogSize(oMainWnd)
aCoord := MsAdvSize(.t.)

DEFINE MSDIALOG oDlg TITLE STR0001 FROM aCoord[7],00 TO aCoord[6],aCoord[5] OF oMainWnd PIXEL // Consulta andamento da Venda

//+-------------------------------+
//| Cria a camada para os painéis |
//+-------------------------------+
oFWLayer := FWLayer():New()
oFWLayer:Init(oDlg,.f.)

oFWLayer:AddLine("UP",50,.F.)
oFWLayer:AddCollumn("ALL",100,.F.,"UP")
oFWLayer:SetLinSplit("UP",CONTROL_ALIGN_BOTTOM)
oFWLayer:AddWindow("ALL","oPanelTop",STR0012,100,.F.,.F.,,"UP",{ || }) // Atendimento
oPanelTop := oFWLayer:GetWinPanel("ALL","oPanelTop","UP")

oFWLayer:AddLine("DOWN",50,.F.)
oFWLayer:AddCollumn("ALL",100,.F.,"DOWN")
oFWLayer:SetLinSplit("DOWN",CONTROL_ALIGN_TOP)
oFWLayer:AddWindow("ALL","oPanelDown","",91,.F.,.F.,,"DOWN",{ || })
oPanelDown := oFWLayer:GetWinPanel("ALL","oPanelDown","DOWN")
INCLUI := .F.
ALTERA := .F.

VV9->(RegToMemory("VV9",.F.))
oMsMGet := MsMGet():New("VV9",	VV9->(RecNo()),2,,,,,{2,2,100,600},,3,,,,oPanelTop,,,.t.)
oMsMGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT

oFolder := TFolder():New(1,1,aFolder,aFolder,oPanelDown,,,,.T.,.F.,100,100)
oFolder:Align:= CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄ¿
//³FOLDER 1³Dados do Cliente
//ÀÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SA1")
While !Eof() .And. SX3->X3_ARQUIVO == "SA1"
	If !(SX3->X3_CAMPO $ "A1_FILIAL") .And. cNivel >= SX3->X3_NIVEL .And.	X3Uso(SX3->X3_USADO) .AND. SX3->X3_FOLDER == "1"
		AADD(aCpoEnch,SX3->X3_CAMPO)
	EndIf
	DbSkip()
End
DbSelectArea("SA1")
dbSetOrder(1)
If DbSeek(xFilial("SA1")+VV9->VV9_CODCLI+VV9->VV9_LOJA)
	SA1->(RegToMemory("SA1",.F.))
	oMsMGt1 := MsMGet():New("SA1",0,2,,,,aCpoEnch,{0,0,90,600},,2,,,,oFolder:aDialogs[1])
    oMsMGt1:oBox:Align := CONTROL_ALIGN_ALLCLIENT
Endif

//ÚÄÄÄÄÄÄÄÄ¿
//³FOLDER 2³Liberação
//ÀÄÄÄÄÄÄÄÄÙ
If !Empty(cFilVAX)
	cFilVAX := VV9->VV9_FILIAL
EndIf
If !Empty(cFilVAY)
	cFilVAY := VV9->VV9_FILIAL
EndIf
cQuery := "SELECT VAY_CODTAR,VAY_STATUS,VAY_USUEXE,VAY_DATSOL,VAY_DATEXE,VAY_HOREXE,VAX_DESTAR "
cQuery += "FROM "+RetSQLName("VAY")+" VAY "
cQuery += "LEFT JOIN "+RetSQLName("VAX")+" VAX ON VAX.VAX_FILIAL='"+cFilVAX+"' AND VAX.VAX_CODTAR=VAY.VAY_CODTAR AND VAX.D_E_L_E_T_=' ' "
cQuery += "WHERE VAY.VAY_FILIAL='"+cFilVAY+"' AND VAY.VAY_NUMIDE='"+VV9->VV9_NUMATE+"' AND VAY.D_E_L_E_T_=' ' ORDER BY VAY.VAY_CODTAR"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), AliasFold2, .F., .T. )
While !(AliasFold2)->(Eof())
	PswOrder(1)
	If !Empty((AliasFold2)->VAY_USUEXE)
		If PswSeek((AliasFold2)->VAY_USUEXE, .T. )
			cUsrFil := PswRet()[1,2] // Retorna vetor com informações do usuário
		EndIf
	Else
		cUsrFil:=""
	Endif
	If (AliasFold2)->VAY_STATUS="0" // Pendente
		cStatus:=oPendente // Vermelho
	ElseIf (AliasFold2)->VAY_STATUS="1" // Aprovado OK
		cStatus:=oAprovado // Verde
	ElseIf (AliasFold2)->VAY_STATUS="2" // Aprovado com restricoes
		cStatus:=oAprovRest // Amarelo
	ElseIf (AliasFold2)->VAY_STATUS="3" // Rejeitado
		cStatus:=oRejeitado // Preto
	ElseIf (AliasFold2)->VAY_STATUS="4" // Deletado pelo usuario
		cStatus:=oDelUsuar // Laranja
	EndIf
	aAdd(aDad2,{cStatus,(AliasFold2)->VAY_USUEXE,cUsrFil,(AliasFold2)->VAY_CODTAR,(AliasFold2)->VAX_DESTAR,StoD((AliasFold2)->VAY_DATSOL),StoD((AliasFold2)->VAY_DATEXE),Transform((AliasFold2)->VAY_HOREXE,"@E 99:99")})
	(AliasFold2)->(DbSkip())
Enddo
(AliasFold2)->( dbCloseArea() )
If Len(aDad2) == 0
	AAdd( aDad2, {"","","","","","","",""})
Endif

dbSelectArea("SX3")
dbSetOrder(2)
For nI:=1 To Len(aCpoFold2[1])
	dbSeek(aCpoFold2[1,nI])
	aAdd( aTit2,  AllTrim(SX3->X3_TITULO  ) )
	aAdd( aTAM2,  CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,SX3->X3_TITULO) )
Next nI
oLbx2 := TwBrowse():New(15,0,(oFolder:nClientWidth/2),(oFolder:nClientHeight/2)-40,,aTit2,,oFolder:aDialogs[2],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbx2:Align := CONTROL_ALIGN_ALLCLIENT
//oLbx2:Align := CONTROL_ALIGN_TOP
oLbx2:SetArray(aDad2)
oLbx2:aColSizes := aTAM2
oLbx2:bLine := {|| aEval( aDad2[oLbx2:nAt],{|z,w| aDad2[oLbx2:nAt,w]})		}

oTPanel := TPanel():New(0,0,"",oFolder:aDialogs[2],NIL,.T.,.F.,NIL,NIL,0,16,.T.,.F.)
oTPanel:Align := CONTROL_ALIGN_TOP // ALLCLIENT

@ 5,001 BITMAP oBmp RESNAME "BR_VERDE" OF oTPanel SIZE 20,20 NOBORDER PIXEL
@ 5,011 SAY STR0013 OF oTPanel SIZE 100,10 PIXEL // Aprovado

@ 5,051 BITMAP oBmp RESNAME "BR_AMARELO" OF oTPanel SIZE 20,20 NOBORDER PIXEL
@ 5,061 SAY STR0014 OF oTPanel SIZE 100,10 PIXEL // Aprovado com restricoes

@ 5,131 BITMAP oBmp RESNAME "BR_PRETO" OF oTPanel SIZE 20,20 NOBORDER PIXEL
@ 5,141 SAY STR0028 OF oTPanel SIZE 100,10 PIXEL // Rejeitado

@ 5,181 BITMAP oBmp RESNAME "BR_VERMELHO"  OF oTPanel SIZE 20,20 NOBORDER PIXEL
@ 5,191 SAY STR0027 OF oTPanel SIZE 100,10 PIXEL // Pendente

@ 5,231 BITMAP oBmp RESNAME "BR_LARANJA"  OF oTPanel SIZE 20,20 NOBORDER PIXEL
@ 5,241 SAY STR0029 OF oTPanel SIZE 100,10 PIXEL // Deletado pelo Usuario

//ÚÄÄÄÄÄÄÄÄ¿
//³FOLDER 3³Outras Vendas
//ÀÄÄÄÄÄÄÄÄÙ
If !Empty(cFilVZ7)
	cFilVZ7 := VV9->VV9_FILIAL
EndIf
If !Empty(cFilVZX)
	cFilVZX := VV9->VV9_FILIAL
EndIf
cQuery := "SELECT VZ7_ITECAM,VZ7_VALITE,VZX_DESCAM,VZ7_AGRVLR "
cQuery += "FROM "+RetSQLName("VZ7")+" VZ7 "
cQuery += "LEFT JOIN "+RetSQLName("VZX")+" VZX ON VZX.VZX_FILIAL='"+cFilVZX+"' AND VZX.VZX_ITECAM=VZ7.VZ7_ITECAM AND VZX.D_E_L_E_T_=' ' "
cQuery += "WHERE VZ7.VZ7_FILIAL='"+cFilVZ7+"' AND VZ7.VZ7_NUMTRA='"+VV9->VV9_NUMATE+"' AND VZ7.VZ7_AGRVLR IN ('1','3') AND VZ7.D_E_L_E_T_=' ' ORDER BY VZ7.VZ7_ITECAM"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), AliasFold3, .F., .T. )
While !(AliasFold3)->(Eof())
	If (AliasFold3)->VZ7_AGRVLR="0"
		cTipoVen := STR0010 // Troco
	ElseIf (AliasFold3)->VZ7_AGRVLR="1"
		cTipoVen := STR0018 // Cortesia
	ElseIf (AliasFold3)->VZ7_AGRVLR="2"
		cTipoVen := STR0019 // Redutor
	Else
		cTipoVen := STR0020 // Venda
	Endif
	aAdd(aDad3,{(AliasFold3)->VZ7_ITECAM,(AliasFold3)->VZX_DESCAM,Transform((AliasFold3)->VZ7_VALITE,"@E 999,999,999.99"),cTipoVen})
	(AliasFold3)->(DbSkip())
Enddo
(AliasFold3)->(dbCloseArea() )
If Len(aDad3) == 0
	AAdd( aDad3, {"","","",""})
Endif

dbSelectArea("SX3")
dbSetOrder(2)
For nI:=1 To Len(aCpoFold3[1])
	dbSeek(aCpoFold3[1,nI])
	aAdd( aTit3,  AllTrim(SX3->X3_TITULO  ) )
	aAdd( aTAM3,  CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,SX3->X3_TITULO) )
Next nI
oLbx3 := TwBrowse():New(0,0,(oFolder:nClientWidth/2),(oFolder:nClientHeight/2)-27,,aTit3,,oFolder:aDialogs[3],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbx3:Align := CONTROL_ALIGN_ALLCLIENT
oLbx3:SetArray(aDad3)
oLbx3:aColSizes := aTAM3
oLbx3:bLine := {|| aEval( aDad3[oLbx3:nAt],{|z,w| aDad3[oLbx3:nAt,w]})		}

//ÚÄÄÄÄÄÄÄÄ¿
//³FOLDER 4³Veículo
//ÀÄÄÄÄÄÄÄÄÙ
DbSelectArea("VVA")
dbSetOrder(1)
dbGoToP()
aCpoEnch:={}
IF DbSeek(xFilial("VVA")+VV9->VV9_NUMATE)
	DbSelectArea("VV1")
	dbSetOrder(1)
	IF DbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
		VV1->(RegToMemory("VV1",.F.))
		oMsMGet2 := MsMGet():New("VV1",,2,,,,,{0,0,90,600},,3,,,,oFolder:aDialogs[4])
		oMsMGet2:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	Endif
Endif
DbSelectArea("SA1")
dbSetOrder(1)
DbSeek(xFilial("SA1")+VV9->VV9_CODCLI+VV9->VV9_LOJA)

//ÚÄÄÄÄÄÄÄÄ¿
//³FOLDER 5³ Faturamento
//ÀÄÄÄÄÄÄÄÄÙ
If !Empty(cFilSF2)
	cFilSF2:= VV9->VV9_FILIAL
EndIf
If !Empty(cFilVV1)
	cFilVV1 := VV9->VV9_FILIAL
EndIf
If !Empty(cFilVVG)
	cFilVVG := VV9->VV9_FILIAL
EndIf
cQuery := "SELECT DISTINCT F2_DOC,F2_SERIE,F2_EMISSAO,F2_VALBRUT,VVG_LOCALI,VVG_LOCPAD "
cQuery += "FROM "+RetSQLName("VV0")+" VV0 "
cQuery += "LEFT JOIN "+RetSQLName("SF2")+" SF2 ON SF2.F2_FILIAL='"+cFilSF2+"' AND SF2.F2_DOC=VV0.VV0_NUMNFI AND SF2.F2_SERIE=VV0.VV0_SERNFI AND SF2.D_E_L_E_T_=' ' "
cQuery += "LEFT JOIN "+RetSQLName("VV1")+" VV1 ON VV1.VV1_FILIAL='"+cFilVV1+"' AND VV1.VV1_FILSAI=VV0.VV0_FILIAL AND VV1.VV1_NUMTRA=VV0.VV0_NUMTRA AND VV1.D_E_L_E_T_=' ' "
cQuery += "LEFT JOIN "+RetSQLName("VVG")+" VVG ON VVG.VVG_FILIAL='"+cFilVVG+"' AND VVG.VVG_CHASSI=VV1.VV1_CHASSI AND VVG.D_E_L_E_T_=' ' "
cQuery += "WHERE VV0.VV0_FILIAL='"+VV9->VV9_FILIAL+"' AND VV0.VV0_NUMTRA='"+VV9->VV9_NUMATE+"' AND VV0.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), AliasFold5, .F., .T. )
While !(AliasFold5)->(Eof())
	aAdd(aDad4,{(AliasFold5)->F2_DOC,FGX_UFSNF( (AliasFold5)->F2_SERIE ),Stod((AliasFold5)->F2_EMISSAO),Transform((AliasFold5)->F2_VALBRUT,"@E 999,999,999.99"),(AliasFold5)->VVG_LOCPAD,(AliasFold5)->VVG_LOCALI})
	(AliasFold5)->(DbSkip())
Enddo
(AliasFold5)->(dbCloseArea() )
If Len(aDad4) == 0
	AAdd( aDad4, {"","","","","","",""})
Endif

dbSelectArea("SX3")
dbSetOrder(2)
For nI:=1 To Len(aCpoFold4[1])
	dbSeek(aCpoFold4[1,nI])
	aAdd( aTit4,  AllTrim(SX3->X3_TITULO  ) )
	aAdd( aTAM4,  CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,SX3->X3_TITULO) )
Next nI
oLbx4 := TwBrowse():New(15,0,(oFolder:nClientWidth/2),(oFolder:nClientHeight/2)-40,,aTit4,,oFolder:aDialogs[5],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbx4:SetArray(aDad4)
oLbx4:aColSizes := aTAM4
oLbx4:bLine := {|| aEval( aDad4[oLbx4:nAt],{|z,w| aDad4[oLbx4:nAt,w]})		}

//ÚÄÄÄÄÄÄÄÄ¿
//³FOLDER 6³Financeiro
//ÀÄÄÄÄÄÄÄÄÙ
cNumTit := "V"+Right(VV0->VV0_NUMTRA,TamSx3("E1_NUM")[1]-1)
cPreTit := ""
If left(GetNewPar("MV_TITATEN","0"),1) == "0" .and. !Empty(VV0->VV0_NUMNFI)
	SF2->(DbSetOrder(1))
	SF2->(DbSeek(cFilSF2+VV0->VV0_NUMNFI+VV0->VV0_SERNFI))
	cNumTit := VV0->VV0_NUMNFI
	cPreTit	:= FGX_MILSNF("SF2", 2, "F2_PREFIXO")
Else
	cPreTit := &(GetNewPar("MV_PTITVEI","''")) // Prefixo dos Titulos de Veiculos
EndIf
cPreTit := PadR(cPreTit+space(10),TamSx3(FGX_MILSNF("SE1", 3, "E1_PREFIXO"))[1]," ") // Prefixo
If !Empty(cFilVS9)
	cFilVS9:= VV9->VV9_FILIAL
EndIf
If !Empty(cFilVSA)
	cFilVSA := VV9->VV9_FILIAL
EndIf
If !Empty(cFilSE1)
	cFilSE1 := VV9->VV9_FILIAL
EndIf
If lDFisico // Data Recebimento Fisico
	cQuery := "SELECT E1_NUM,E1_PREFIXO,E1_TIPO,E1_EMISSAO,E1_VENCREA,E1_BAIXA,E1_VALOR,E1_SALDO,E1_CLIENTE,E1_LOJA,E1_PARCELA,VS9_TIPPAG,VSA_DESPAG,VS9_DATPAG,VS9_VALPAG,VS9_PARCEL,VSA_DESPAG,E1_DFISICO "
Else
	cQuery := "SELECT E1_NUM,E1_PREFIXO,E1_TIPO,E1_EMISSAO,E1_VENCREA,E1_BAIXA,E1_VALOR,E1_SALDO,E1_CLIENTE,E1_LOJA,E1_PARCELA,VS9_TIPPAG,VSA_DESPAG,VS9_DATPAG,VS9_VALPAG,VS9_PARCEL,VSA_DESPAG "
EndIf
cQuery += "FROM "+RetSQLName("VV0")+" VV0 "
cQuery += "LEFT JOIN "+RetSQLName("VS9")+" VS9 ON VS9.VS9_FILIAL='"+cFilVS9+"' AND VS9.VS9_NUMIDE='"+VV9->VV9_NUMATE+"' AND VS9.VS9_TIPOPE='V' AND VS9.D_E_L_E_T_=' ' "
cQuery += "LEFT JOIN "+RetSQLName("VSA")+" VSA ON VSA.VSA_FILIAL='"+cFilVSA+"' AND VSA.VSA_TIPPAG=VS9.VS9_TIPPAG AND VSA.D_E_L_E_T_=' ' "
cQuery += "LEFT JOIN "+RetSQLName("SE1")+" SE1 ON SE1.E1_FILIAL='"+cFilSE1+"' AND SE1.E1_TIPO=VS9.VS9_TIPPAG AND SE1.E1_PARCELA=VS9.VS9_PARCEL AND "
cQuery += "SE1.E1_PREFIXO LIKE '"+cPreTit+"%' AND SE1.E1_NUM='"+cNumTit+"' AND SE1.D_E_L_E_T_=' ' "
cQuery += "WHERE VV0.VV0_FILIAL='"+VV9->VV9_FILIAL+"' AND VV0.VV0_NUMTRA='"+VV9->VV9_NUMATE+"' AND VV0.D_E_L_E_T_=' ' ORDER BY SE1.E1_VENCREA , SE1.E1_PARCELA "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), AliasFold6, .F., .T. )
While !(AliasFold6)->(Eof())
	If !Empty((AliasFold6)->VS9_TIPPAG)
		If lDFisico .and. !Empty((AliasFold6)->E1_DFISICO)
			cStatus:=oRecebido  //recebido
			IF (!Empty((AliasFold6)->E1_BAIXA) .and. (AliasFold6)->E1_SALDO<>(AliasFold6)->E1_VALOR .AND. (AliasFold6)->E1_SALDO>0)
				cStatus:=oAprovRest //amarelo
			ElseIF (!Empty((AliasFold6)->E1_BAIXA) .AND. (AliasFold6)->E1_SALDO=0)
				cStatus:=oPendente  //vermelho
			Endif
		Else
			IF (!Empty((AliasFold6)->E1_BAIXA) .and. (AliasFold6)->E1_SALDO<>(AliasFold6)->E1_VALOR .AND. (AliasFold6)->E1_SALDO>0)
				cStatus:=oAprovRest //amarelo
			ElseIF (!Empty((AliasFold6)->E1_BAIXA) .AND. (AliasFold6)->E1_SALDO=0)
				cStatus:=oPendente  //vermelho
			ElseIF (Empty((AliasFold6)->E1_BAIXA))
				cStatus:=oAprovado   //verde
			Endif
		Endif
		aAdd(aDad5,{cStatus,(AliasFold6)->E1_NUM,(AliasFold6)->E1_PREFIXO,(AliasFold6)->VS9_TIPPAG,(AliasFold6)->VSA_DESPAG,VV9->VV9_DATVIS,Stod((AliasFold6)->VS9_DATPAG),Stod((AliasFold6)->E1_BAIXA),Transform((AliasFold6)->VS9_VALPAG,"@E 999,999,999.99"),Transform((AliasFold6)->E1_SALDO,"@E 999,999,999.99"),VV9->VV9_CODCLI,VV9->VV9_LOJA,(AliasFold6)->E1_PARCELA})
	Endif
	(AliasFold6)->(DbSkip())
Enddo
(AliasFold6)->(dbCloseArea() )
If Len(aDad5) == 0
	AAdd( aDad5, {"","","","","","",""})
Endif

dbSelectArea("SX3")
dbSetOrder(2)
For nI:=1 To Len(aCpoFold5[1])
	If dbSeek(aCpoFold5[1,nI])
		aAdd( aTit5,  AllTrim(SX3->X3_TITULO  ) )
		aAdd( aTAM5,  CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,SX3->X3_TITULO) )
	Else
		aAdd( aTit5,  aCpoFold5[1,nI])
		aAdd( aTAM5,  36 )
	Endif
Next nI


oLbx5 := TwBrowse():New(15,0,(oFolder:nClientWidth/2),(oFolder:nClientHeight/2)-40,,aTit5,,oFolder:aDialogs[6],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
//oLbx5:Align := CONTROL_ALIGN_ALLCLIENT
//oLbx5:Align := CONTROL_ALIGN_TOP
oLbx5:SetArray(aDad5)
oLbx5:aColSizes := aTAM5
oLbx5:bLine := {|| aEval( aDad5[oLbx5:nAt],{|z,w| aDad5[oLbx5:nAt,w]})		}
oLbx5:bLDblClick  := { || {VerTitVei(oLbx5) }}

oTPane2 := TPanel():New(0,0,"",oFolder:aDialogs[6],NIL,.T.,.F.,NIL,NIL,0,16,.T.,.F.)
oTPane2:Align := CONTROL_ALIGN_TOP // ALLCLIENT
@ 5,001 BITMAP oBmp RESNAME "BR_VERDE"    OF oTPane2 SIZE 20,20 NOBORDER PIXEL
@ 5,010 SAY STR0021 OF oTPane2 SIZE 100,10 PIXEL // Titulo em Aberto
@ 5,056 BITMAP oBmp RESNAME "BR_AMARELO" OF oTPane2 SIZE 20,20 NOBORDER PIXEL
@ 5,065 SAY STR0022 OF oTPane2 SIZE 100,10 PIXEL // Baixado Parcialmente
@ 5,131 BITMAP oBmp RESNAME "BR_PINK"     OF oTPane2 SIZE 20,20 NOBORDER PIXEL
@ 5,140 SAY STR0015 OF oTPane2 SIZE 100,10 PIXEL // Titulo Recebido
@ 5,187 BITMAP oBmp RESNAME "BR_VERMELHO" OF oTPane2 SIZE 20,20 NOBORDER PIXEL
@ 5,200 SAY STR0016 OF oTPane2 SIZE 100,10 PIXEL // Titulo Baixado

//ÚÄÄÄÄÄÄÄÄ¿
//³FOLDER 7³Troco
//ÀÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT VZ7_ITECAM,VZ7_VALITE,VZX_DESCAM "
cQuery += "FROM "+RetSQLName("VZ7")+" VZ7 "
cQuery += "LEFT JOIN "+RetSQLName("VZX")+" VZX ON VZX.VZX_FILIAL='"+cFilVZX+"' AND VZX.VZX_ITECAM=VZ7.VZ7_ITECAM AND VZX.D_E_L_E_T_=' ' "
cQuery += "WHERE VZ7.VZ7_FILIAL='"+cFilVZ7+"' AND VZ7.VZ7_NUMTRA='"+VV9->VV9_NUMATE+"' AND VZ7.VZ7_AGRVLR IN ('0','3') AND VZ7.VZ7_COMPAG='2' AND VZ7.D_E_L_E_T_=' ' ORDER BY VZ7.VZ7_ITECAM"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), AliasFold7, .F., .T. )
While !(AliasFold7)->(EOF())
	aAdd(aDad7,{(AliasFold7)->VZ7_ITECAM,(AliasFold7)->VZX_DESCAM,Transform((AliasFold7)->VZ7_VALITE,"@E 999,999,999.99")})
	(AliasFold7)->(DbSkip())
Enddo
(AliasFold7)->(dbCloseArea() )

DbSelectarea("VV0")
DbSetOrder(1)
If DbSeek(xFilial("VV0")+VV9->VV9_NUMATE)
	If VV0->VV0_VALTRO > 0
		aAdd(aDad7,{"000000",STR0017,Transform(VV0->VV0_VALTRO,"@E 999,999,999.99")}) // Devolucao
	EndIf
EndIf
If Len(aDad7) == 0
	AAdd( aDad7, {"","",""})
Endif

dbSelectArea("SX3")
dbSetOrder(2)
For nI:=1 To Len(aCpoFold7[1])
	dbSeek(aCpoFold7[1,nI])
	aAdd( aTit7,  AllTrim(SX3->X3_TITULO  ) )
	aAdd( aTAM7,  CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,SX3->X3_TITULO) )
Next nI
oLbx7 := TwBrowse():New(0,0,(oFolder:nClientWidth/2),(oFolder:nClientHeight/2)-27,,aTit3,,oFolder:aDialogs[7],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbx7:Align := CONTROL_ALIGN_ALLCLIENT
oLbx7:SetArray(aDad7)
oLbx7:aColSizes := aTAM7
oLbx7:bLine := {|| aEval( aDad7[oLbx7:nAt],{|z,w| aDad7[oLbx7:nAt,w]})		}

cQuery := "SELECT SEF.EF_ALINEA1 , SEF.EF_DTALIN1 , SEF.EF_ALINEA2 , SEF.EF_DTALIN2 "
cQuery += "FROM "+RetSQLName("SE1")+" SE1 "
cQuery += "LEFT JOIN "+RetSQLName("SEF")+" SEF ON SEF.EF_FILIAL=SE1.E1_FILIAL AND SEF.EF_PREFIXO=SE1.E1_PREFIXO AND SEF.EF_TITULO=SE1.E1_NUM AND SEF.EF_PARCELA=SE1.E1_PARCELA AND SEF.EF_TIPO=SE1.E1_TIPO AND SEF.D_E_L_E_T_=' ' "
cQuery += "WHERE SE1.E1_FILIAL='"+cFilSE1+"' AND SE1.E1_NUM='"+cNumTit+"' AND SE1.D_E_L_E_T_=' ' AND ( SEF.EF_ALINEA1 <> ' ' OR SEF.EF_ALINEA2 <> ' ' ) "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), AliasFold8, .F., .T. )
While !(AliasFold8)->(Eof())
	aAdd(aDad8,{(AliasFold8)->EF_ALINEA1,Transform(stod((AliasFold8)->EF_DTALIN1),"@D"),(AliasFold8)->EF_ALINEA2,Transform(stod((AliasFold8)->EF_DTALIN2),"@D")})
	(AliasFold8)->(DbSkip())
Enddo
(AliasFold8)->(dbCloseArea() )
If Len(aDad8) == 0
	AAdd( aDad8, {"","","",""})
Endif

dbSelectArea("SX3")
dbSetOrder(2)
For nI:=1 To Len(aCpoFold8[1])
	dbSeek(aCpoFold8[1,nI])
	aAdd( aTit8,  AllTrim(SX3->X3_TITULO  ) )
	aAdd( aTAM8,  CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,SX3->X3_TITULO) )
Next nI
oLbx8 := TwBrowse():New(0,0,(oFolder:nClientWidth/2),(oFolder:nClientHeight/2)-27,,aTit8,,oFolder:aDialogs[8],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbx8:Align := CONTROL_ALIGN_ALLCLIENT
oLbx8:SetArray(aDad8)
oLbx8:aColSizes := aTAM8
oLbx8:bLine := {|| aEval( aDad8[oLbx8:nAt],{|z,w| aDad8[oLbx8:nAt,w]})		}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||(nOpcA:=1,oDlg:End())},{||(nOpcA:=2,oDlg:End())},,aBotEnc)

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VerTitVei ºAutor  ³Robson Nayland      º Data ³  24/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Visualiza os titulo no contas a receber                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function VerTitVei(oLbx5)
SE1->(DbSetOrder(1))
If SE1->(DbSeek(xFilial("SE1")+oLbx5:AARRAY[oLbx5:nAt,3]+oLbx5:AARRAY[oLbx5:nAt,2]+oLbx5:AARRAY[oLbx5:nAt,13]+oLbx5:AARRAY[oLbx5:nAt,04]))
	FINA040(,2)
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Andre Luis Almeida                ³ Data ³ 26/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Consulta andamento de Venda de Veiculos               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := { {STR0023,"AxPesqui",0,1},;			// Pesquisar
{STR0024,"VXC008",0,2},;			// Consultar
{STR0026,"VXA018PESQ()", 0, 1 },;	// Pesq.Avancada
{STR0025,"VXA018LEG"	,0,4,2,.f.}}	// Legenda
Return aRotina