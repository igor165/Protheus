#Include "PROTHEUS.CH"
#Include "VEIXX013.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIXX013 º Autor ³ Andre Luis Almeida º Data ³  04/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Pre-Aprovacao / Aprovacao / Reprovar                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cNroAtend ( Nro do Atendimento )                           º±±
±±º          ³ nTipo  0 = Visualizacao do Mapa                            º±±
±±º          ³        1 = Pre-Aprovacao                                   º±±
±±º          ³        2 = Aprovar                                         º±±
±±º          ³        3 = Aprovacao Previa                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXX013(cNroAtend,nTipo, pXX013Auto, cCodMap, cOrigem)

Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor  := 0
Local nTam     := 0
Local lTela    := .f.
Local nRet     := 0
Local cGruVei  := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Local cChassiV := ""
Local cCombust := ""
Local cFabMod  := ""
Local nPDspFin := 0
Local nVDspFin := 0
Local nVComVde := 0
Local nPComVda := 0
Local cVAIAPROVA := "0"
Local lVV9_APRPUS := ( VV9->(ColumnPos("VV9_APRPUS")) > 0 )

Default pXX013Auto := .f.
Default cCodMap  := GetNewPar("MV_MAPAPR","011")
Default cOrigem := "ATENDIMENTO"

Private lXX013Auto := pXX013Auto
Private cProposta

Private aMapTitul := {}
Private aMapTotal := {}

DEFINE FONT oFLib01 NAME "Arial" SIZE 09,13 BOLD
DEFINE FONT oFLib02 NAME "Arial" SIZE 07,13 BOLD

If cOrigem == "ATENDIMENTO"
	dbSelectArea("VV9")
	dbSetOrder(1)
	dbSeek(xFilial("VV9")+cNroAtend)
	cTitulo := STR0001 // Visualiza Mapa de Avaliacao da Aprovacao (Analise de Custos)
	Do Case
		Case nTipo == 1 // Esta Pedindo para Pre-Aprovar
			cTitulo := STR0002 // Pre-Aprovacao (Analise de Custos)
			If VV9->VV9_STATUS <> "P"
				MsgStop(STR0005,STR0004) // Esta opcao so' e' permitida para Atendimentos PENDENTES DE APROVACAO! / Atencao
				Return 0 // Cancelou automaticamente
			Endif
		Case nTipo == 2 // Esta Pedindo para Aprovar
			cTitulo := STR0003 // Aprovacao (Analise de Custos)
			If !VV9->VV9_STATUS $ "P/O"
				MsgStop(STR0006,STR0004) // Esta opcao so' e' permitida para Atendimentos PENDENTES DE APROVACAO ou PRE-APROVADOS! / Atencao
				Return 0 // Cancelou automaticamente
			Endif
		Case nTipo == 3 // Aprovacao Previa
			cTitulo := STR0037 // Aprovacao Previa
			If VV9->VV9_STATUS $ 'L/F/C' // Não deixa fazer se ja estiver Aprovado, Finalizado ou Cancelado
				MsgStop(STR0035,STR0004) // Status do Atendimento nao permite Aprovacao Previa. Impossivel continuar. / Atencao
				Return 0
			EndIf
			If lVV9_APRPUS .and. !Empty(VV9->VV9_APRPUS) // Ja foi Aprovado Previamente
				MsgStop(STR0036,STR0004) // Ja foi realizada a Aprovacao Previa para este Atendimento. Impossivel continuar. / Atencao
				Return 0
			EndIf
	EndCase
Else

EndIf

////////////////////////////////////////////
If lVV9_APRPUS .and. !Empty(VV9->VV9_APRPUS) // Ja foi Aprovado Previamente
	cVAIAPROVA := "2" // deixa aprovar mesmo que o usuario nao tem permissao
Else // NAO foi Aprovado Previamente
	cVAIAPROVA := FGX_USERVL(xFilial("VAI"),__cUserID,"VAI_APROVA","?")
EndIf
Do Case
	Case cVAIAPROVA == "1" // Usuario Pre-Aprova
		If nTipo == 2 // Esta Pedindo para Aprovar
			Return 0 // Cancelou automaticamente
		EndIf
	Case cVAIAPROVA == "2" .or. cVAIAPROVA == "3" // Usuario Aprova ou faz Aprovacao Previa
		If nTipo == 1 // Esta Pedindo para Pre-Aprovar
			If !VX013VVAVALID()
				Return 0  // Cancelou automaticamente
			EndIf
			//
			VX0130011_EMAIL(2,"",.f.) // Gerar EMAIL na 2-Pre-Aprovação
			//
			Return 1 // Pre-Aprovou automaticamente
		EndIf
	OtherWise // Usuario sem permissao para Pre-Aprovar ou Aprovar ou Aprovacao Previa
		If nTipo <> 0
			Return 0 // Cancelou automaticamente
		EndIf
EndCase

////////////////////////////////////////////
lTela := FGX_USERVL(xFilial("VAI"),__cUserID,"VAI_TELAPR","==","1")
If (!lTela .and. nTipo == 0) .and. ! lXX013Auto // Usuario nao tem permissao para visulizar a Tela do Mapa de Aprovacao
	MsgStop(STR0029,STR0004) // Usuario sem permissao para visulizar Mapa de Aprovacao! / Atencao
EndIf

If lTela
	lTela := ! lXX013Auto
EndIf

If ! VX013VVAVALID()
	Return 0 // Cancelou automaticamente
EndIf

If lVV9_APRPUS .and. !Empty(VV9->VV9_APRPUS) // Ja foi Aprovado Previamente
	lTela := .f. // Nao mostra a tela e faz automaticamente
EndIf

// Monta Mapa de Avaliacao
aAdd(aMapTitul,STR0011) // TOTAL
If cOrigem == 'ATENDIMENTO'
	VX013MAPATEND(cCodMap, @nVComVde, @nPComVda)
Else
//	VX013MAPPVATAC()
EndIf

//////////////////////////////////////////////////////
// Alterar % do TOTAL em relacao a 1a.linha do MAPA //
//////////////////////////////////////////////////////
If len(aMapTotal) > 0
	For nCntFor := 1 to len(aMapTotal[1])
		aMapTotal[1,nCntFor,3] := ( aMapTotal[1,nCntFor,2] / aMapTotal[1,1,2] * 100 ) // Totalizar no Total
	Next
EndIf
//////////////////////////////////////////////////////
If lTela // Visualiza Tela de Pre-Aprovacao / Aprovacao
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+VV9->VV9_CODCLI+VV9->VV9_LOJA)
	cCliente  := SA1->A1_COD+"-"+SA1->A1_LOJA+" "+SA1->A1_NOME

	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 05, 30 , .T., .F. } )  //Cabecalho
	AAdd( aObjects, {  1, 10, .T. , .T. } )  //list box
	AAdd( aObjects, { 10, 14, .T. , .F. } )  //Botoes
	For nCntFor := 1 to Len(aSizeAut)
		aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.8)
	Next
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects,.F.)

	DEFINE MSDIALOG oAprPreApr From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] TITLE cTitulo of oMainWnd PIXEL
	oAprPreApr:lEscClose := .F.
	nTam := ( aPosObj[1,4] / 14) //varaivel que armazena o resutlado da divisao da tela.
	
	@ aPosObj[1,1],aPosObj[1,2]+(nTam*0) TO aPosObj[1,3],nTam*7 LABEL ("") OF oAprPreApr PIXEL
	@ aPosObj[1,1],aPosObj[1,2]+(nTam*7)+002 TO aPosObj[1,3],nTam*14 LABEL ("") OF oAprPreApr PIXEL
	
	// Cliente // 
	@ aPosObj[1,1]+005,aPosObj[1,2]+005+(nTam*0) SAY STR0009 SIZE 70,08 OF oAprPreApr PIXEL COLOR CLR_RED FONT oFLib01 // Cliente
	@ aPosObj[1,1]+004,aPosObj[1,2]+003+(nTam*2) MSGET oCliente VAR cCliente      SIZE (nTam*5)-8,08 OF oAprPreApr PIXEL COLOR CLR_BLUE FONT oFLib02 when .f.

	// Atendimento //
	@ aPosObj[1,1]+017,aPosObj[1,2]+005+(nTam*0) SAY STR0010 SIZE 70,08 OF oAprPreApr PIXEL COLOR CLR_RED FONT oFLib01 // Atendimento
	@ aPosObj[1,1]+016,aPosObj[1,2]+003+(nTam*2) MSGET oAtendimento VAR cProposta SIZE (nTam*5)-8,08 OF oAprPreApr PIXEL COLOR CLR_BLUE FONT oFLib02 when .f.
	
	// Comissao Venda //
	@ aPosObj[1,1]+005,aPosObj[1,2]+007+(nTam*7) SAY STR0012 SIZE 70,08 OF oAprPreApr PIXEL COLOR CLR_RED FONT oFLib01 // Comissao Venda
	@ aPosObj[1,1]+004,aPosObj[1,2]+007+(nTam*9)+((nTam)/2) MSGET oPComVda VAR (Transform(nPComVda,"@E 999.99")+" %") SIZE 05,06 OF oAprPreApr PIXEL COLOR CLR_BLUE FONT oFLib02  when .f.
	
	@ aPosObj[1,1]+005,aPosObj[1,2]+007+(nTam*11)  SAY GetMv("MV_SIMB1") SIZE 10,08 OF oAprPreApr PIXEL COLOR CLR_RED FONT oFLib02
	@ aPosObj[1,1]+004,aPosObj[1,2]+007+(nTam*11)+((nTam)/2) MSGET oVComVde VAR nVComVde Pict "@E 9,999,999.99" SIZE 55,06 OF oAprPreApr PIXEL COLOR CLR_BLUE FONT oFLib02  when .f. HASBUTTON

	//  Despesa Adm  //
	@ aPosObj[1,1]+017,aPosObj[1,2]+007+(nTam*7) SAY STR0013 SIZE 70,08 OF oAprPreApr PIXEL COLOR CLR_RED FONT oFLib01// Despesa Adm
	@ aPosObj[1,1]+016,aPosObj[1,2]+007+(nTam*9)+((nTam)/2) MSGET oPDspFin VAR (Transform(nPDspFin,"@E 999.99")+" %") SIZE 05,06 OF oAprPreApr PIXEL COLOR CLR_BLUE FONT oFLib02  when .f.

	@ aPosObj[1,1]+017,aPosObj[1,2]+007+(nTam*11) SAY GetMv("MV_SIMB1") SIZE 10,08 OF oAprPreApr PIXEL COLOR CLR_RED FONT oFLib02
	@ aPosObj[1,1]+016,aPosObj[1,2]+007+(nTam*11)+((nTam)/2) MSGET oVDspFin VAR nVDspFin Pict "@E 9,999,999.99" SIZE 55,06 OF oAprPreApr PIXEL COLOR CLR_BLUE FONT oFLib02  when .f. HASBUTTON
	// 
	
	oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aMapTitul,{}, oAprPreApr,,,,.t.,.f.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1]) 
	If len(aMapTotal) > 0
		For nCntFor := 1 to len(oFolder:aDialogs)
			&("oLbMap" + AllTrim(Str(nCntFor))) := TWBrowse():New(1,1,1,1,,,,oFolder:aDialogs[nCntFor],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			&("oLbMap" + AllTrim(Str(nCntFor))):nAT := 1
			&("oLbMap" + AllTrim(Str(nCntFor))):SetArray(&("aMapTotal["+AllTrim(Str(nCntFor))+"]"))
			&("oLbMap" + AllTrim(Str(nCntFor))):addColumn( TCColumn():New( STR0016  , &("{ || aMapTotal["+AllTrim(Str(nCntFor))+",oLbMap"+AllTrim(Str(nCntFor))+":nAt,1] }"),,,,"LEFT" ,150,.F.,.F.,,,,.F.,) )	// 01 - Descricao
			&("oLbMap" + AllTrim(Str(nCntFor))):addColumn( TCColumn():New( STR0017  , &("{ || IIF(aMapTotal["+AllTrim(Str(nCntFor))+",oLbMap"+AllTrim(Str(nCntFor))+":nAt,2] == 0, '', Transform(aMapTotal["+AllTrim(Str(nCntFor))+",oLbMap"+AllTrim(Str(nCntFor))+":nAt,2],'@E 9999,999,999.99') ) } "),,,,"Right" ,100,.F.,.F.,,,,.F.,) )	// 02 - Valor
			&("oLbMap" + AllTrim(Str(nCntFor))):addColumn( TCColumn():New( "%"      , &("{ || IIF(aMapTotal["+AllTrim(Str(nCntFor))+",oLbMap"+AllTrim(Str(nCntFor))+":nAt,3] == 0, '', Transform(aMapTotal["+AllTrim(Str(nCntFor))+",oLbMap"+AllTrim(Str(nCntFor))+":nAt,3],        '@E 9999.99') ) } "),,,,"Right" , 30,.F.,.F.,,,,.F.,) )	// 03 - Percentual
			&("oLbMap" + AllTrim(Str(nCntFor))):Align := CONTROL_ALIGN_ALLCLIENT
			&("oLbMap" + AllTrim(Str(nCntFor))):Refresh()
		Next
	EndIf
	@ aPosObj[3,1]+002,aPosObj[3,4]-200 BUTTON oObervAte PROMPT STR0018 OF oAprPreApr SIZE 43,11 PIXEL ACTION FM_OBSMEM(STR0018,VV0->VV0_OBSMEM,"VV0_OBSMEM","VV0_OBSERV",.f.,.t.) // Titulo Janela, Campo Caracter, Nome do Campo Caracter, Campo Memo, Altera (.t./.f.) , Traz Texto existente (.t./.f.) // Observacoes
	Do Case 
		Case nTipo == 1 // Esta Pedindo para Pre-Aprovar
			@ aPosObj[3,1]+002,aPosObj[3,4]-150 BUTTON oReprovar PROMPT STR0019 OF oAprPreApr SIZE 43,11 PIXEL ACTION ( FS_REPROVAR() , nRet := 2 , oAprPreApr:End() ) // Reprovar
			@ aPosObj[3,1]+002,aPosObj[3,4]-100 BUTTON oPreAprov PROMPT STR0020 OF oAprPreApr SIZE 43,11 PIXEL ACTION ( nRet := 1 , oAprPreApr:End() ) // Pre-Aprovar
		Case nTipo == 2 // Esta Pedindo para Aprovar
			@ aPosObj[3,1]+002,aPosObj[3,4]-150 BUTTON oReprovar PROMPT STR0019 OF oAprPreApr SIZE 43,11 PIXEL ACTION ( FS_REPROVAR() , nRet := 2 , oAprPreApr:End() ) // Reprovar
			@ aPosObj[3,1]+002,aPosObj[3,4]-100 BUTTON oAprovar  PROMPT STR0021 OF oAprPreApr SIZE 43,11 PIXEL ACTION IIf(FS_APROVAR(cNroAtend,nTipo),(nRet := 1,oAprPreApr:End()),.f.) // Aprovar
		Case nTipo == 3 // Esta Pedindo Aprovacao Previa
			@ aPosObj[3,1]+002,aPosObj[3,4]-100 BUTTON oAprovar  PROMPT STR0021 OF oAprPreApr SIZE 43,11 PIXEL ACTION IIf(FS_APROVAR(cNroAtend,nTipo),(nRet := 1,oAprPreApr:End()),.f.) // Aprovar
	EndCase
	@ aPosObj[3,1]+002,aPosObj[3,4]-50  BUTTON oSair PROMPT STR0022 OF oAprPreApr SIZE 43,11 PIXEL ACTION oAprPreApr:End() // SAIR
	
	ACTIVATE MSDIALOG oAprPreApr CENTER

	If nTipo == 1 .and. nRet == 1 // Esta Pedindo para Pre-Aprovar e Pre-Aprovou
		//
		VX0130011_EMAIL(2,"",.t.) // Gerar EMAIL na 2-Pre-Aprovação
		//
	EndIf

Else // Executa AUTOMATICAMENTE -> Nao visualiza Tela de Pre-Aprovacao / Aprovacao
	
	If nTipo == 1 // Esta Pedindo para Pre-Aprovar
		nRet := 1
		//
		VX0130011_EMAIL(2,"",.t.) // Gerar EMAIL na 2-Pre-Aprovação
		//
	ElseIf nTipo == 2 .or. nTipo == 3 // Esta Pedindo para Aprovar ou Aprovacao Previa
		If FS_APROVAR(cNroAtend,nTipo)
			nRet := 1
		EndIf
	EndIf
	
EndIf

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_REPROVAR³ Autor ³ Andre Luis Almeida   ³ Data ³ 05/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Reprova o Atendimento de Veiculos                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_REPROVAR()
Local cObsAnt := ""
Local cObserv := ""
cObsAnt := E_MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1])+Chr(13)+Chr(10)+Repl("_",TamSx3("VV0_OBSERV")[1]-10)+Chr(13)+Chr(10)+"***  "+left(Alltrim(UsrRetName(__CUSERID)),15)+"  "+Transform(dDataBase,"@D")+" - "+Transform(time(),"@R 99:99")+"  ***"+Chr(13)+Chr(10)
While Empty(cObserv)
	cObserv := FM_OBSMEM(STR0023,VV0->VV0_OBSMEM,"VV0_OBSMEM","VV0_OBSERV",.t.,.f.) // Titulo Janela, Campo Caracter, Nome do Campo Caracter, Campo Memo, Altera (.t./.f.) , Traz Texto existente (.t./.f.) // Motivo da Reprovacao
EndDo
If !Empty(cObserv)
	DbSelectArea("VV0")
	MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1],,cObsAnt+STR0024+" "+STR0025+":"+CHR(13)+CHR(10)+cObserv,1,,,"VV0","VV0_OBSMEM") // Atendimento REPROVADO! / Motivo
EndIf
//
VX0130011_EMAIL(4,cObserv,.t.) // Gerar EMAIL na 4-Reprovação
//
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_APROVAR ³ Autor ³ Andre Luis Almeida   ³ Data ³ 06/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida Min.Comercial e Aprova o Atendimento (Grava DtAprov)³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_APROVAR(cNroAtend,nTipo)
Local cObsAnt     := ""
Local lVV0_FLUXO  := ( VV0->(ColumnPos("VV0_FLUXO ")) > 0 ) // Fluxo de Caixa
Local lVV9_APRPUS := ( VV9->(ColumnPos("VV9_APRPUS")) > 0 )
Local cObsMCV     := "" // Observacao do Minimo Comercial que sera gravado no MEMO da Aprovacao
Local lValida     := .f. // Validacoes ?
Local lEfetiva    := .f. // Efetiva relacionamento VQ0 ?
Local cUserApr    := ""
Local dDataApr    := ctod("")
Local nHoraApr    := 0
Local cTexto      := ""

dbSelectarea("VV9")
dbSetOrder(1)
dbSeek(xFilial("VV9")+cNroAtend)

///////////////////////////////////////////////////////////////////////////////////////
// Somente Valida e Efetiva relacionamento VQ0 quando for:                           //
// ( Aprovacao Previa ) ou ( Aprovacao Normal sem ter realizado a Aprovacao Previa ) //
///////////////////////////////////////////////////////////////////////////////////////
If lVV9_APRPUS
	If nTipo == 3 .or. ( nTipo == 2 .and. Empty(VV9->VV9_APRPUS) )
		lValida  := .t. // Fazer Validacoes 
		lEfetiva := .t. // Efetiva Relacionamento VQ0
	EndIf
Else
	lValida  := .t. // Fazer Validacoes 
	lEfetiva := .t. // Efetiva Relacionamento VQ0
EndIf

If lValida // Validacoes ?
	//////////////////////////////////////////////////////
	// Validar Minimo Comercial no Momento da Aprovacao //
	//////////////////////////////////////////////////////
	If !VEIXX007( 2 , @aMinCom , , , @cObsMCV , aMapTotal[1,len(aMapTotal[1]),3] ) // 2=Validar / aMinCom := {Chassi Interno,Marca,Modelo,Segmento,Cor,Vlr Negociacao,Vlr Sugerido Vda,% de Vlr de Vda do Min.Comercial,% do Resultado na Negociacao,% do Resultado do Min.Comercial}
		Return .f.
	EndIf
	//////////////////////////////////////////////////////
	// PE para validar a Aprovacao do Atendimento       //
	//////////////////////////////////////////////////////
	If ExistBlock("VXX13VAP")
		If !ExecBlock("VXX13VAP",.f.,.f.,{cNroAtend})
			Return .f.
		EndIf
	EndIf
EndIf
//
dbSelectarea("VV0")
dbSetOrder(1)
If dbSeek(xFilial("VV0")+cNroAtend)

	If lValida // Validacoes ?
		dbSelectarea("VVA")
		dbSetOrder(1) // VVA_FILIAL+VVA_NUMTRA
		dbSeek(xFilial("VVA")+cNroAtend)
		While !Eof() .and. VVA->VVA_FILIAL == xFilial("VVA") .and. VVA->VVA_NUMTRA == cNroAtend
			If !VX013CODPED( VVA->VVA_CODPED , VVA->VVA_FILIAL , VVA->VVA_NUMTRA , VVA->VVA_CHASSI )
				Return .f.
			EndIf
			dbSelectarea("VVA")
			DbSkip()
		EndDo
	EndIf

	dbSelectarea("VVA")
	dbSetOrder(1) // VVA_FILIAL+VVA_NUMTRA
	dbSeek(xFilial("VVA")+cNroAtend)

	If nTipo == 2 // Somente na Aprovacao

		If lVV9_APRPUS .and. !Empty(VV9->VV9_APRPUS) // Ja fez a Aprovacao Previa
			cUserApr := VV9->VV9_APRPUS // Usuario
			dDataApr := VV9->VV9_APRPDT // Data
			nHoraApr := VV9->VV9_APRPHR // Hora
			cTexto   := STR0034 // Atendimento APROVADO PREVIAMENTE!
		Else
			cUserApr := __CUSERID
			dDataApr := dDataBase
			nHoraApr := Val(substr(time(),1,2)+substr(time(),4,2))
			cTexto   := STR0026 // Atendimento APROVADO!
		EndIf

		dbSelectarea("VV0")
		RecLock("VV0",.f.)
		VV0->VV0_DATMOV := dDataApr
		VV0->VV0_DATAPR := dDataApr
		VV0->VV0_USRAPR := cUserApr
		VV0->VV0_STATUS := "L" // Liberado
		If lVV0_FLUXO
			VV0->VV0_FLUXO := "S" // Constar no Fluxo de Caixa quando Aprovar Atendimento
		EndIf
		MsUnLock()
		cObsAnt := E_MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1])
		If !Empty(cObsAnt)
			cObsAnt += Chr(13)+Chr(10)
		EndIf
		cObsAnt += Repl("_",TamSx3("VV0_OBSERV")[1]-10)+Chr(13)+Chr(10)+"***  "+left(Alltrim(UsrRetName(cUserApr)),15)+"  "+Transform(dDataApr,"@D")+" - "+Transform(strzero(nHoraApr,4),"@R 99:99")+"  ***"+Chr(13)+Chr(10)
		MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1],,cObsAnt+cTexto+cObsMCV,1,,,"VV0","VV0_OBSMEM")

	Else // Aprovacao Previa

		If lVV9_APRPUS
			dbSelectarea("VV9")
			RecLock("VV9",.f.)
				VV9->VV9_APRPUS := __CUSERID
				VV9->VV9_APRPDT := dDataBase
				VV9->VV9_APRPHR := Val(substr(time(),1,2)+substr(time(),4,2))
			MsUnLock()
		EndIf

	EndIf
	
	If lEfetiva // Efetiva relacionamento VQ0 ?
		VX0130021_RelacionaVQ0( cNroAtend ) // Relaciona VVA com VQ0
	EndIf

	If nTipo == 2 // Somente na Aprovacao
		
		//////////////////////////////////////////////////////
		// PE executado apos Aprovacao do Atendimento       //
		//////////////////////////////////////////////////////
		If ExistBlock("VXX13DAP")
			ExecBlock("VXX13DAP",.f.,.f.,{cNroAtend})
		EndIf
		//
		VX0130011_EMAIL( 3 , "" , .t. , cUserApr , dDataApr , nHoraApr ) // Gerar EMAIL na 3-Aprovação
		//

	Else // Aprovacao Previa
		
		//////////////////////////////////////////////////////
		// PE executado apos Aprovacao Previa do Atendimento//
		//////////////////////////////////////////////////////
		If ExistBlock("VXX13APP")
			ExecBlock("VXX13APP",.f.,.f.,{cNroAtend})
		EndIf

	EndIf

EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VX003VERAPR³ Autor ³ Andre Luis Almeida   ³ Data ³ 05/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se existe outro Atendimento ja pre-aprovado/apro- ³±±
±±³          ³ vado para o mesmo Veiculo (CHASSI)                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX003VERAPR(_cNumAte,_cChassi)
Local lVV9_APRPUS := ( VV9->(ColumnPos("VV9_APRPUS")) > 0 )
Local lRet       := .t.
Local cQuery     := ""
Local cQAlVV9A   := "SQLVV9A"
Local aFilAtu    := FWArrFilAtu()
Local aSM0       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt := cFilAnt
Local nCntFor    := 0
Local cFilVV9    := xFilial("VV9")
Local cFilOut    := ""
//
If !Empty(_cChassi)
	//
	For nCntFor := 1 to len(aSM0)
		cFilAnt := aSM0[nCntFor]
		If cFilVV9 <> xFilial("VV9")
			cFilOut += "'"+xFilial("VV9")+"',"
		EndIf
	Next
	cFilOut := Iif(Len(cFilOut)>0,left(cFilOut,len(cFilOut)-1),"' '")
	cFilAnt := cBkpFilAnt
	//
	cQuery := "SELECT VV9.VV9_FILIAL,"
	cQuery += "       VV9.VV9_NUMATE"
	cQuery += "  FROM "+RetSqlName("VV9")+" VV9"
	cQuery += "  JOIN "+RetSqlName("VVA")+" VVA ON ( VVA.VVA_FILIAL=VV9.VV9_FILIAL AND VVA.VVA_NUMTRA=VV9.VV9_NUMATE AND VVA.D_E_L_E_T_=' ' ) "
	cQuery += " WHERE ("
	cQuery += "          ( VV9.VV9_FILIAL='"+cFilVV9+"' AND VV9.VV9_NUMATE<>'"+_cNumAte+"' )" // Mesma Filial - Outros Atendimentos
	If ! Empty(cFilOut)
		cQuery += "          OR "
		cQuery += "          ( VV9.VV9_FILIAL IN ("+cFilOut+") )" // Outras Filiais
	EndIf
	cQuery += "       )"
	If lVV9_APRPUS
		cQuery += "   AND ( VV9.VV9_STATUS IN ('L','O') OR ( VV9.VV9_STATUS IN ('A','P') AND VV9.VV9_APRPUS <> ' ' ) )"
	Else
		cQuery += "   AND VV9.VV9_STATUS IN ('L','O')"
	EndIf
	cQuery += "   AND VVA.VVA_CHASSI='"+_cChassi+"'"
	cQuery += "   AND VV9.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV9A , .F., .T. )
	If !( cQAlVV9A )->( Eof() )
		lRet := .f. // Existe outro Atendimento ja Pre-Aprovado/Aprovado para o mesmo Veiculo!
		FMX_HELP("VX013ERR001", STR0027+CHR(13)+CHR(10)+CHR(13)+CHR(10)+( cQAlVV9A )->( VV9_NUMATE )+" - "+ STR0028+": "+( cQAlVV9A )->( VV9_FILIAL )) // Existe outro Atendimento ja Pre-Aprovado/Aprovado para o mesmo Veiculo! / Filial / Atencao
	EndIf
	( cQAlVV9A )->( dbCloseArea() )
	//
EndIf
DbSelectArea("VV9")
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VX013CODPED³ Autor ³ Andre Luis Almeida   ³ Data ³ 11/09/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se existe outro Atendimento para o mesmo PEDIDO   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX013CODPED( _cCodPed , _cFilAte , _cNumAte , _cChassi )
Local lVVA_CODPED := ( VVA->(ColumnPos("VVA_CODPED")) > 0 )
Local oHelperFil  := DMS_FilialHelper():New()
Local aFilTodas   := oHelperFil:GetAllFil( .t. ) // .t. = Retorna todas as Filiais mesmo que o usuario nao tem acesso
Local cFilDemais  := ""
Local cQuery      := ""
Local cQAlAux     := "SQLAUX"
Local nCntFor     := 0
Local lRet        := .t.
If !Empty(_cCodPed)
	If lVVA_CODPED
		For nCntFor := 1 to len(aFilTodas)
			If _cFilAte <> aFilTodas[nCntFor]
				cFilDemais += ",'"+aFilTodas[nCntFor]+"'"
			EndIf
		Next		
		cQuery := "SELECT VVA.VVA_FILIAL , VVA.VVA_NUMTRA "
		cQuery += "  FROM "+RetSqlName("VVA")+" VVA"
		cQuery += "  JOIN "+RetSqlName("VV0")+" VV0 ON VV0.VV0_FILIAL=VVA.VVA_FILIAL AND VV0.VV0_NUMTRA=VVA.VVA_NUMTRA AND VV0.VV0_SITNFI='1' AND VV0.D_E_L_E_T_ = ' '" // Considerar apenas VV0 VALIDOS
		cQuery += "  JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=VVA.VVA_CODTES AND SF4.F4_ESTOQUE='S' AND SF4.D_E_L_E_T_ = ' '"
		cQuery += " WHERE "
		cQuery += "("
		cQuery += "( VVA.VVA_FILIAL = '" + _cFilAte + "' AND VVA.VVA_NUMTRA <> '" + _cNumAte + "' )" // Outros Atendimentos na mesma Filial
		If !Empty(cFilDemais)
			cQuery += " OR VVA.VVA_FILIAL IN (" + substr(cFilDemais,2) + ")" // Outras Filiais
		EndIf
		cQuery += ")"
		If !Empty(_cChassi)
			cQuery += "   AND VVA.VVA_CHASSI = '" + _cChassi + "'"
		EndIf
		cQuery += "   AND VVA.VVA_CODPED = '" + _cCodPed + "'"
		cQuery += "   AND VVA.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
		If !( cQAlAux )->( Eof() )
			lRet := .f. // Existe outro Atendimento ja Pre-Aprovado/Aprovado/Finalizado para o mesmo PEDIDO!
			FMX_HELP("VX013ERR002", STR0030+CHR(13)+CHR(10)+CHR(13)+CHR(10)+( cQAlAux )->( VVA_FILIAL )+" - "+ STR0028+": "+( cQAlAux )->( VVA_NUMTRA )) // Existe outro Atendimento ja Pre-Aprovado/Aprovado/Finalizado para o mesmo PEDIDO! / Filial / Atencao
		EndIf
		( cQAlAux )->( dbCloseArea() )
		DbSelectArea("VVA")
	Else // Antigo - Temporario - apagar apos existir o campo VVA_CODPED
		DbSelectArea("VQ0")
		DbSetOrder(1)
		If DbSeek(xFilial("VQ0")+_cCodPed) .and. !Empty(VQ0->VQ0_FILATE+VQ0->VQ0_NUMATE)
			cQuery := "SELECT VVA.R_E_C_N_O_ AS RECVVA "
			cQuery += "  FROM "+RetSqlName("VVA")+" VVA"
			cQuery += "  JOIN "+RetSqlName("VV0")+" VV0 ON VV0.VV0_FILIAL=VVA.VVA_FILIAL AND VV0.VV0_NUMTRA=VVA.VVA_NUMTRA AND VV0.VV0_SITNFI='1' AND VV0.D_E_L_E_T_ = ' '" // Considerar apenas VV0 VALIDOS
			cQuery += "  JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=VVA.VVA_CODTES AND SF4.F4_ESTOQUE='S' AND SF4.D_E_L_E_T_ = ' '"
			cQuery += " WHERE VVA.VVA_FILIAL = '" + VQ0->VQ0_FILATE + "'"
			cQuery += "   AND VVA.VVA_NUMTRA = '" + VQ0->VQ0_NUMATE + "'"
			If !Empty(_cChassi)
				cQuery += "   AND VVA.VVA_CHASSI = '" + _cChassi + "'"
			EndIf
			cQuery += "   AND VVA.D_E_L_E_T_ = ' '"
			If ( Alltrim(_cFilAte) + _cNumAte ) <> ( Alltrim(VQ0->VQ0_FILATE) + VQ0->VQ0_NUMATE ) .and. ( FM_SQL(cQuery) > 0 ) // Outro Atendimento e TES movimento Estoque
				lRet := .f. // Existe outro Atendimento ja Pre-Aprovado/Aprovado/Finalizado para o mesmo PEDIDO!
				FMX_HELP("VX013ERR002", STR0030+CHR(13)+CHR(10)+CHR(13)+CHR(10)+VQ0->VQ0_NUMATE+" - "+ STR0028+": "+VQ0->VQ0_FILATE) // Existe outro Atendimento ja Pre-Aprovado/Aprovado/Finalizado para o mesmo PEDIDO! / Filial / Atencao
			EndIf
		EndIf
	EndIf
EndIf
Return lRet


/*/{Protheus.doc} VX013VVAVALID
Verifica se pode aprovar atendimento com os veiculos informados no atendimento
@author Rubens
@since 05/02/2019
@version 1.0
@return logical, pode continuar com a validacao

@type function
/*/
Static Function VX013VVAVALID()

	dbSelectarea("VV0")
	dbSetOrder(1)
	dbSeek(xFilial("VV0")+VV9->VV9_NUMATE)
	dbSelectarea("VVA")
	dbSetOrder(4) // VVA_FILIAL+VVA_NUMTRA+VVA_ITETRA
	dbSeek(xFilial("VVA")+VV9->VV9_NUMATE)
	While !Eof() .and. VVA->VVA_FILIAL == xFilial("VVA") .and. VVA->VVA_NUMTRA == VV9->VV9_NUMATE

		If !VX013CODPED( VVA->VVA_CODPED , VVA->VVA_FILIAL , VVA->VVA_NUMTRA , VVA->VVA_CHASSI )
			VVA->(dbSetOrder(1)) // VVA_FILIAL+VVA_NUMTRA
			Return .f.
		EndIf

		If !VX003VERAPR(VV9->VV9_NUMATE,VVA->VVA_CHASSI) // Valida a existencia de outro Atendimento ja Pre-Aprovado/Aprovado para o veiculo
			VVA->(dbSetOrder(1)) // VVA_FILIAL+VVA_NUMTRA
			Return .f.
		EndIf
		DbSelectArea("VVA")
		DbSkip()
	EndDo
	VVA->(dbSetOrder(1)) // VVA_FILIAL+VVA_NUMTRA
	VVA->(dbSeek(xFilial("VVA")+VV9->VV9_NUMATE))

Return .t.


/*/{Protheus.doc} VX013MAPATEND
//TODO Descrição auto-gerada.
@author Rubens
@since 05/02/2019
@version 1.0
@return ${return}, ${return_description}
@param cCodMap, characters, Codigo do mapa
@param nVComVde, numeric, Valor de venda acumulado
@param nPComVda, numeric, Percentual da comissao da venda
@type function
/*/
Static Function VX013MAPATEND(cCodMap, nVComVde, nPComVda)

	Local nCntFor
	Local aMap     := {}

	Local lVVASEGMOD := ( VVA->(ColumnPos("VVA_SEGMOD")) > 0 )

	dbSelectarea("VV0")
	dbSetOrder(1)
	dbSeek(xFilial("VV0")+VV9->VV9_NUMATE)
	dbSelectarea("VVA")
	dbSetOrder(4) // VVA_FILIAL+VVA_NUMTRA+VVA_ITETRA
	dbSeek(xFilial("VVA")+VV9->VV9_NUMATE)
	While !Eof() .and. VVA->VVA_FILIAL == xFilial("VVA") .and. VVA->VVA_NUMTRA == VV9->VV9_NUMATE

		If !Empty(VVA->VVA_CHASSI)
			VV1->(dbSetOrder(2)) 
			VV1->(dbSeek(xFilial("VV1")+VVA->VVA_CHASSI))
			FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)
			aAdd(aMapTitul,Alltrim(VVA->VVA_CHASSI)+" - "+Alltrim(VV1->VV1_CODMAR)+" "+Alltrim(VV2->VV2_DESMOD))
		Else
			FGX_VV2(VVA->VVA_CODMAR, VVA->VVA_MODVEI, IIf( lVVASEGMOD , VVA->VVA_SEGMOD , "" ) )
			aAdd(aMapTitul,Alltrim(VV2->VV2_CODMAR)+" "+Alltrim(VV2->VV2_DESMOD))
		EndIf

		nVComVde += VVA->VVA_COMVDE
		aMap := {}
		FM_MAPAVAL(1,cCodMap,VV9->VV9_NUMATE,.f.,0,@aMap,VVA->VVA_CHAINT) // Monta Mapa de Avaliacao
		If len(aMapTotal) <= 0
			aAdd(aMapTotal,aClone(aMap)) // Total 
			aAdd(aMapTotal,aClone(aMap)) // 1o. Veiculo
		Else
			aAdd(aMapTotal,aClone(aMap)) // Demais Veiculos
			For nCntFor := 1 to len(aMap)
				aMapTotal[1,nCntFor,2] += aMap[nCntFor,2] // Totalizar valores na 1a.aba, referente ao Total
			Next
		EndIf

		DbSelectArea("VVA")
		DbSkip()
	EndDo

	VVA->(dbSetOrder(1)) // VVA_FILIAL+VVA_NUMTRA
	VVA->(dbSeek(xFilial("VVA")+VV9->VV9_NUMATE))

	cProposta := ( VV9->VV9_NUMATE+" - "+Transform(VV0->VV0_DATMOV,"@D") + " - " )
	If VV9->VV9_STATUS == "O"
		cProposta += STR0007 // Pre-Aprovado
	ElseIf VV9->VV9_STATUS == "L"
		cProposta += STR0031 // Aprovado
	ElseIf VV9->VV9_STATUS == "F"
		cProposta += STR0032 // Finalizado
	Else // o restante esta Pendente Aprovacao
		cProposta += STR0008 // Pendente de Aprovacao
	EndIf

	nPComVda := (nVComVde/VV0->VV0_VALTOT)*100
	
	If VV0->VV0_TIPFAT=="1"//USADO
		nPDspFin := GetNewPar("MV_PDSPUSA",0)
	Else //novo
		nPDspFin := GetNewPar("MV_PDSPNOV",0)
	EndIf
	nVDspFin := (nPDspFin*VV0->VV0_VALTOT)/100

Return


/*/{Protheus.doc} VX0130011_EMAIL
	Gerar EMAIL no momento da 2-Pre-Aprovação / 3-Aprovação / 4-Reprovação
	
	@author Andre Luis Almeida
	@since 18/10/2018
/*/
Static Function VX0130011_EMAIL( nTp , cTxtComp , lMapaAval , cUserAux , dDataAux , nHoraAux )
Local oEmailHlp   := DMS_EmailHelper():New()
Local nCntFor     := 0
Local nCntAux     := 0
Local nPosIni     := 1
Local cTitEmail   := ""
Local cEmails     := ""
Local cMensagem   := ""
Local lVV9_APRPUS := ( VV9->(ColumnPos("VV9_APRPUS")) > 0 )
Default nTp       := 2
Default cTxtComp  := ""
Default lMapaAval := .f.
Default cUserAux  := __CUSERID
Default dDataAux  := dDataBase
Default nHoraAux  := Val(substr(time(),1,2)+substr(time(),4,2))
If FindFunction("VA0100011_LevantaEmails")
	Do Case
		Case nTp == 2 // Pre-Aprovação
			cTitEmail := STR0033+" ( "+STR0028+": "+VV0->VV0_FILIAL+" - "+STR0010+": "+VV0->VV0_NUMTRA+" )" // Atendimento PRE-APROVADO! / Filial: / Atendimento:
			cEmails   := VA0100011_LevantaEmails( "2" ) // E-mail's destinatarios ( 2 - Atendimento Pre-Aprovação )
		Case nTp == 3 // Aprovação
			If lVV9_APRPUS .and. !Empty(VV9->VV9_APRPUS)
				cTitEmail := STR0034 // Atendimento APROVADO PREVIAMENTE!
			Else
				cTitEmail := STR0026 // Atendimento APROVADO!
			EndIf
			cTitEmail += " ( "+STR0028+": "+VV0->VV0_FILIAL+" - "+STR0010+": "+VV0->VV0_NUMTRA+" )" // Filial: / Atendimento:
			cEmails   := VA0100011_LevantaEmails( "3" ) // E-mail's destinatarios ( 3 - Atendimento Aprovação )
		Case nTp == 4 // Reprovação
			cTitEmail := STR0024+" ( "+STR0028+": "+VV0->VV0_FILIAL+" - "+STR0010+": "+VV0->VV0_NUMTRA+" )" // Atendimento REPROVADO! / Filial: / Atendimento:
			cEmails   := VA0100011_LevantaEmails( "4" ) // E-mail's destinatarios ( 4 - Atendimento Reprovação )
	EndCase
	//
	If !Empty(cEmails) // Tem E-mail para Enviar
		cMensagem := "<font size=4 face='verdana,arial' Color=#0000cc><b>"+cTitEmail+"<br><br>"+Transform(dDataAux,"@D")+" "+Transform(strzero(nHoraAux,4),"@R 99:99")+" - "+UPPER(UsrRetName(cUserAux))+"</b></font><br><br><br>"
		If !Empty(cTxtComp)
			cMensagem += "<font size=3 face='verdana,arial' Color=red>"+cTxtComp+"</font><br><br><br>"
		EndIf
		If lMapaAval // MAPA DE AVALIACAO no Email ?
			If len(aMapTitul) == 2
				nPosIni := 2 // Quando existir um unico veiculo no Atendimento, nao mostra o Total, mostra apenas o Veiculo
			EndIf
			For nCntFor := nPosIni to len(aMapTitul)
				cMensagem += "<table width=100% border=1>"
				cMensagem += "<tr><td colspan=3 bgcolor=cyan><font size=4 face='verdana,arial' Color=black><b>"+aMapTitul[nCntFor]+"</b></font></td></tr>"
				cMensagem += "<tr>"
				cMensagem += "<td width=55% align=center><font size=2 face='verdana,arial' Color=black><b>"+STR0016+"</b></font></td>" // Descricao
				cMensagem += "<td width=30% align=center><font size=2 face='verdana,arial' Color=black><b>"+STR0017+"</b></font></td>" // Valor
				cMensagem += "<td width=15% align=center><font size=2 face='verdana,arial' Color=black><b>%</b></font></td>" // %
				cMensagem += "</tr>"
				For nCntAux := 1 to len(aMapTotal[nCntFor])
					cMensagem += "<tr>"
					cMensagem += "<td><font size=2 face='verdana,arial' Color=#0000cc>"+aMapTotal[nCntFor,nCntAux,1]+"</font></td>" // Descricao
					cMensagem += "<td align=right><font size=2 face='verdana,arial' Color=#0000cc>"+Transform(aMapTotal[nCntFor,nCntAux,2],'@E 9999,999,999.99')+"</font></td>" // Valor
					cMensagem += "<td align=right><font size=2 face='verdana,arial' Color=#0000cc>"+Transform(aMapTotal[nCntFor,nCntAux,3],'@E 9999.99')+"</font></td>" // Percentual
					cMensagem += "</tr>"
				Next
				cMensagem += "</table><br><br>"
			Next
		EndIf
		oEmailHlp:Send({;
						{'assunto' , cTitEmail },;
						{'mensagem', cMensagem },;
						{'destino' , cEmails   } ;
					})
	EndIf
EndIf
Return

/*/{Protheus.doc} VX0130021_RelacionaVQ0()
	Relaciona VQ0 com VVA
	
	@author Andre Luis Almeida
	@since 16/04/2018
/*/
Function VX0130021_RelacionaVQ0( cNroAtend )
Local lVQ0_ITETRA  := ( VQ0->(ColumnPos("VQ0_ITETRA")) > 0 ) // Item Atendimento
dbSelectarea("VVA")
dbSetOrder(1) // VVA_FILIAL+VVA_NUMTRA
dbSeek(xFilial("VVA")+cNroAtend)
While !Eof() .and. VVA->VVA_FILIAL == xFilial("VVA") .and. VVA->VVA_NUMTRA == cNroAtend
	If !Empty(VVA->VVA_CODPED)
		DbSelectArea("VQ0")
		DbSetOrder(1)
		If DbSeek(xFilial("VQ0")+VVA->VVA_CODPED)
			RecLock("VQ0",.f.)
			VQ0->VQ0_FILATE := VVA->VVA_FILIAL
			VQ0->VQ0_NUMATE := VVA->VVA_NUMTRA
			If lVQ0_ITETRA
				VQ0->VQ0_ITETRA := VVA->VVA_ITETRA
			EndIf
			MsUnLock()
		EndIf
	EndIf
	DbSelectArea("VVA")
	DbSkip()
EndDo
VVA->(dbSetOrder(1)) // VVA_FILIAL+VVA_NUMTRA
VVA->(dbSeek(xFilial("VVA")+cNroAtend))
Return