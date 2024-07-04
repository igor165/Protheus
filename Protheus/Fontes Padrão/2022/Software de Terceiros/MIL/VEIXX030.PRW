// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 38     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "VEIXX030.CH"

Static nAVEIMAX := IIf(GetVersao(.f.)=="P10",1,GetNewPar("MV_AVEIMAX",1))	// Quantidade Maxima de veiculos no atendimento

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIXX030 º Autor ³ Andre Luis Almeida  º Data ³ 23/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Faturamento Direto                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXX030(xAutoCab,xAutoItens,xAutoCP,nOpc,aRecInter)

Private lVVASEGMOD := ( VVA->(ColumnPos("VVA_SEGMOD")) > 0 ) // Utilizado no VEIXX002 - existem chamadas de funcoes

Default aRecInter  := {} // RecNo's dos Interesses da Oportunidade de Vendas

// Na integracao as variaveis abaixo nao existirao,
// por isso precisamos carrega-las manualmente
VISUALIZA := ( nOpc == 2 )
INCLUI 	  := ( nOpc == 3 )
ALTERA 	  := ( nOpc == 4 )
EXCLUI 	  := ( nOpc == 5 )
//

//////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar os modulos de Veiculos //
//////////////////////////////////////////////////////////////////////////////
If !FMX_AMIIN({"VEIXA018","VEIXA019","VEIXA030","VEIXA040","VEIVA620","VEICC500","VEIVC080","VEIVC110","VEIVC140","VEIVC170","VEIVC200","VEIVC210","VEIVC220","VEIVM130","VEIXC002","VEIXC008","VEICC610","VEIVC250","OFIOC500","VEICM680","VEICC680","VEIVM190"})
	Return()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se e' possivel ALTERAR/CANCELAR Atendimento atraves do VV9_STATUS ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 4 // Alteracao
	If VV9->VV9_STATUS == "F"
		MsgStop(STR0003,STR0002) // Impossivel ALTERAR Atendimento Finalizado! / Atencao
		Return()
	ElseIf VV9->VV9_STATUS == "C"
		MsgStop(STR0004,STR0002) // Impossivel ALTERAR Atendimento Cancelado! / Atencao
		Return()
	EndIf
ElseIf nOpc == 5 // Cancelar
	If VV9->VV9_STATUS == "C"
		MsgStop(STR0006,STR0002) // Impossivel CANCELAR Atendimento Cancelado! / Atencao
		Return()
	EndIf
EndIf

DBSelectArea("VV9")
VX030EXEC(alias(),Recno(),nOpc,@aRecInter)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX030EXEC º Autor ³ Andre Luis Almeida  º Data ³ 23/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Faturamento Direto ( TELA )                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX030EXEC(cAlias,nReg,nOpc,aRecInter)
Local aObjects    := {} , aPos := {} , aInfo := {}
Local aSizeAut    := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor     := 0
Local lOkTela     := .F. // Ok da TELA
Local lAlt        := .F. // Altera dados ?
Local lVen        := .F. // Altera vendedor ?
Local cNomeVVA    := RetSQLName("VVA")
Local xAux
Local nAux        := 0
Local aAux        := {}
Local aAuxCpo     := {}
Local aRet        := {}
Local aCpo        := {}
Local aObr        := {}
Local cQuery      := ""
Local cSQLAlias   := "SQLVVA"
Local aCATVEN     := X3CBOXAVET("VV0_CATVEN","0")
Local aParamBoxC  := {}
Local aBotEncFtD  := {}
Local cObsAnt     := ""
Local cChaInt     := ""
Local nRet        := 0
Local lInterrompe := .f.
Local cOpcFab     := ""
Local cPict       := ""

Local aVS9        := {{},{}} // Entradas VS9
Local aVSE        := {{},{}} // Entradas VSE

Private aVSETotal := {{},{}} // Vetor com todos os VSE correspondentes ao Atendimento, vetor utilizado nos VEIXX...
Private aParEnt   := {"",0}  // Parametros Entradas

Private nLenaCpo  := 0
Private aVVA      := {}
Private aVVACust  := {}
Private aDelVVA   := {}
Private nVVATot   := 0 // Soma Total dos Veiculos VVA_VALTAB
Private lAvanca   := .f. // Avanca Atendimento ?
Private lFases    := ( VAI->(FieldPos("VAI_FASEFD")) > 0 ) // Possui Fases o Faturamento Direto?
Private aParOpc	  := {"","",""}	 // Opcionais do Veiculo
Private aMinCom   := {}
//
Private oMapaBom  // Botao com Mapa de Avaliacao - VERDE
Private oMapaMed  // Botao com Mapa de Avaliacao - AMARELO
Private oMapaRui  // Botao com Mapa de Avaliacao - VERMELHO
//
Private lCadVei   := .f.
//
Private cCdCliAt := ""
Private cLjCliAt := ""
//
Default aRecInter := {} // RecNo's dos Interesses da Oportunidade de Vendas
//
AAdd( aObjects, { 100 , 100 , .T. , .T. } ) // TELA
aAdd( aObjects, {   0 ,  12 , .T. , .F. } ) // Botoes / Totais
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPos  := MsObjSize (aInfo, aObjects,.F.)
//
If ExistBlock("VXX30VVA")
//	aAdd(aVVACust,{ "VVA_XDTLRC" , 50 , .t. , ctod("")  }) // { Nome campo do VVA , Tamanho na Tela , Mostra na Grid de Itens , Inicializador Padrão }
//	aAdd(aVVACust,{ "VVA_XCDORI" , 60 , .f. , space(30) }) // { Nome campo do VVA , Tamanho na Tela , Mostra na Grid de Itens , Inicializador Padrão }
//	aAdd(aVVACust,{ "VVA_XVLTAB" , 55 , .f. , 0         }) // { Nome campo do VVA , Tamanho na Tela , Mostra na Grid de Itens , Inicializador Padrão }
	aVVACust := ExecBlock("VXX30VVA",.f.,.f.) // PE para preenchimento de campos do VVA no Faturamento Direto
EndIf
//
VAI->(dbSetOrder(4))
VAI->(MsSeek(xFilial("VAI")+__cUserID))
//
If nOpc == 3 .or. ( nOpc == 4 .and. VV9->VV9_STATUS == "A" ) // Incluir ou Alterar com Status Em Aberto
	lAlt := .T. // Altera dados ?
	If VAI->VAI_ATEOUT == "2" // Visualiza/Inclui/Altera Atendimentos de outros vendedores
		lVen := .T. // Altera Vendedor ?
	EndIf
EndIf
If lFases
	lFases := .f.
	If VAI->VAI_FASEFD == "1" // Trabalha com Fases ???
		lFases := .t.
	EndIf
EndIf
//
VXA030F12(.f.) // .f. = NAO mostra Pergunte e NAO seta F12
lCadVei := ( MV_PAR01 == 1 )
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Vetor com os CAMPOS e definicoes da PARAMBOX ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aCpo,{"VV9","VV9_NUMATE",RetTitle("VV9_NUMATE"),"C",1,"@!",""                                                   ,""      ,".F."             ,45,.F.})
aAdd(aCpo,{"VV9","VV9_CODCLI",RetTitle("VV9_CODCLI"),"C",1,"@!",'VX030CLI(1,@aRet)'                                  ,"VSA"   ,IIf(lAlt,"",".F."),40,.T.})
aAdd(aCpo,{"VV9","VV9_LOJA"  ,RetTitle("VV9_LOJA")  ,"C",1,"@!",'VX030CLI(1,@aRet)'                                  ,""      ,IIf(lAlt,"",".F."),15,.T.})
aAdd(aCpo,{"VV9","VV9_NOMVIS",RetTitle("A1_NOME")   ,"C",1,"@!",""                                                   ,""      ,".F."             ,90,.F.})
aAdd(aCpo,{"VV9","VV9_FILNEG",RetTitle("VV9_FILNEG"),"C",1,"@!",""                                                   ,"SM0_01",IIf(lAlt,"",".F."),60,.F.})
aAdd(aCpo,{"VV0","VV0_CLIFTD",RetTitle("VV0_CLIFTD"),"C",1,"@!",'VX030CLI(2,@aRet)'                                  ,"SA1"   ,IIf(lAlt,"",".F."),40,.T.})
aAdd(aCpo,{"VV0","VV0_LOJFTD",RetTitle("VV0_LOJFTD"),"C",1,"@!",'VX030CLI(2,@aRet)'                                  ,""      ,IIf(lAlt,"",".F."),15,.T.})
aAdd(aCpo,{"VV0","VV0_NNFFDI",RetTitle("VV0_NNFFDI"),"C",1,"@!",""                                                   ,""      ,IIf(lAlt,"",".F."),50,.F.})
aAdd(aCpo,{"VV0",FGX_MILSNF("VV0", 3, "VV0_SNFFDI"),FGX_MILSNF("VV0", 7, "VV0_SNFFDI"),"C",1,"@!",""                 ,""      ,IIf(lAlt,"",".F."),20,.F.})
aAdd(aCpo,{"VV0","VV0_DATEMI",RetTitle("VV0_DATEMI"),"D",1,"@D",""                                                   ,""      ,IIf(lAlt,"",".F."),50,.F.})
aAdd(aCpo,{"VV0","VV0_MODVDA",RetTitle("VV0_MODVDA"),"C",1,"@!",'VAZIO() .or. FG_Seek("SX5","'+"'V4'"+'+MV_PAR11",1)',"V4"    ,IIf(lAlt,"",".F."),25,.T.})
aAdd(aCpo,{"VV0","VV0_CATVEN",RetTitle("VV0_CATVEN"),"C",2,""  ,'Pertence("345670")'                                 ,aCATVEN ,"",90,.T.})
aAdd(aCpo,{"VV0","VV0_TIPVEN",RetTitle("VV0_TIPVEN"),"C",1,"@!",'FG_Seek("VV3","MV_PAR13",1,.f.)'                    ,"VV3"   ,IIf(lAlt,"",".F."),30,.T.})
aAdd(aCpo,{"VV0","VV0_CODVEN",RetTitle("VV0_CODVEN"),"C",1,"@!",'VAZIO() .or. FG_Seek("SA3","MV_PAR14",1,.f.)'       ,"SA3"   ,IIf(lVen,"",".F."),40,.T.})
aAdd(aCpo,{"VV0","VV0_CLIALI",RetTitle("VV0_CLIALI"),"C",1,"@!",'VX030CLI(3,@aRet)'                                  ,"SA1"   ,IIf(lAlt,"",".F."),40,.F.})
aAdd(aCpo,{"VV0","VV0_LOJALI",RetTitle("VV0_LOJALI"),"C",1,"@!",'VX030CLI(3,@aRet)'                                  ,""      ,IIf(lAlt,"",".F."),15,.F.})
If ExistBlock("VXX30CPO")
	aAuxCpo :=  ExecBlock("VXX30CPO",.f.,.f.,{ aClone(aCpo) }) // PE para manipular os campos na Tela do Fat.Direto
	If ValType(aAuxCpo) == "A"
		aCpo := aClone(aAuxCpo)
	EndIf
EndIf
nLenaCpo := len(aCpo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregar variaveis de memoria M->                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3 // Incluir
	//
	For nCntFor := 1 to nLenaCpo
		If aCpo[nCntFor,4] == "C"
			&("M->"+aCpo[nCntFor,2]) := Space(TamSX3(aCpo[nCntFor,2])[1])
		ElseIf aCpo[nCntFor,4] == "D"
			&("M->"+aCpo[nCntFor,2]) := ctod("")
		ElseIf aCpo[nCntFor,4] == "N"
			&("M->"+aCpo[nCntFor,2]) := 0
		EndIf
	Next
	//
	M->VV9_FILNEG := xFilial("VV9")		// Filial Negociacao
	M->VV0_CATVEN := "0"				// Categoria Venda
	M->VV0_CODVEN := VAI->VAI_CODVEN	// Vendedor
	//
	If len(aRecInter) > 0 // Oportunidades/Interesses - carregar automaticamente Cliente/Loja/Nome
		VDM->(DbGoTo(aRecInter[1]))
		VDL->(DbSetOrder(1))
		If VDL->(MsSeek(VDM->VDM_FILIAL+VDM->VDM_CODOPO))
			M->VV9_CODCLI := VDL->VDL_CODCLI
			M->VV9_LOJA   := VDL->VDL_LOJCLI
			SA1->(DbSetOrder(1))
			If SA1->(MsSeek(xFilial("SA1")+M->VV9_CODCLI+M->VV9_LOJA))
				M->VV9_NOMVIS := SA1->A1_NOME
			EndIf
		EndIf
		For nCntFor := 1 to len(aRecInter)
			If aRecInter[nCntFor] > 0
				VDM->(DbGoTo(aRecInter[nCntFor]))
				VV2->(DbSetOrder(1))
				VV2->(MsSeek(xFilial("VV2")+VDM->VDM_CODMAR+VDM->VDM_MODVEI))
				VVC->(DbSetOrder(1))
				VVC->(MsSeek(xFilial("VVC")+VDM->VDM_CODMAR+VDM->VDM_CORVEI))
				VXX0300011_CriaVetorVVA()
				nAux := len(aVVA)
				aVVA[nAux,02] := VDM->VDM_CODMAR
				aVVA[nAux,03] := VDM->VDM_MODVEI
				aVVA[nAux,04] := VDM->VDM_CORVEI
				aVVA[nAux,05] := FS_VLRVEI(VDM->VDM_CORVEI)
				aVVA[nAux,10] := VV2->VV2_DESMOD
				aVVA[nAux,11] := VVC->VVC_DESCRI
			EndIf
		Next
	EndIf
	//
Else // nOpc <> 3
	//
	VV0->(DbSetOrder(1))
	VV0->(MsSeek(xFilial("VV0")+VV9->VV9_NUMATE))
	//
	aParEnt[1] := VV9->VV9_NUMATE
	//
	For nCntFor := 1 to nLenaCpo
		&("M->"+aCpo[nCntFor,2]) := &(aCpo[nCntFor,1]+"->"+aCpo[nCntFor,2])
	Next
	cCdCliAt := VV9->VV9_CODCLI
	cLjCliAt := VV9->VV9_LOJA
	//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Vetor dos Veiculos ( VVA ) do Fatur.Direto   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT VVA.R_E_C_N_O_ RECVVA , VV2.VV2_DESMOD , VVC.VVC_DESCRI "
	cQuery += "FROM "+cNomeVVA+" VVA "
	cQuery += "LEFT JOIN "+RetSQLName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VVA.VVA_CODMAR AND VV2.VV2_MODVEI=VVA.VVA_MODVEI AND VV2.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSQLName("VVC")+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VVA.VVA_CODMAR AND VVC.VVC_CORVEI=VVA.VVA_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VVA.VVA_FILIAL='"+xFilial("VVA")+"' AND VVA.VVA_NUMTRA='"+VV9->VV9_NUMATE+"' AND VVA.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->(Eof())
		DbSelectArea("VVA")
		DbGoTo((cSQLAlias)->( RECVVA ))
		cChaInt := VVA->VVA_CHAINT
		cOpcFab := E_MSMM(VVA->VVA_OBSMEM,TamSx3("VVA_OBSERV")[1])
		If nOpc == 4 .and. Empty(cChaInt) .and. !Empty(VVA->VVA_CHASSI)
			VV1->(DbSetOrder(2))
			If VV1->(DbSeek(xFilial("VV1")+VVA->VVA_CHASSI))
				cChaInt := VV1->VV1_CHAINT
				cOpcFab := VV1->VV1_OPCFAB
				DbSelectArea("VVA")
				RecLock("VVA",.f.)
					VVA->VVA_CHAINT := cChaInt
					MSMM(VVA->VVA_OBSMEM,TamSx3("VVA_OBSERV")[1],,cOpcFab,1,,,"VVA","VVA_OBSMEM") // Opcionais Temporario
				MsUnLock()
			EndIf
		EndIf
		VXX0300011_CriaVetorVVA()
		nAux := len(aVVA)
		aVVA[nAux,01] := (cSQLAlias)->( RECVVA )
		aVVA[nAux,02] := VVA->VVA_CODMAR
		aVVA[nAux,03] := VVA->VVA_MODVEI
		aVVA[nAux,04] := VVA->VVA_CORVEI
		aVVA[nAux,05] := VVA->VVA_VALTAB
		aVVA[nAux,06] := VVA->VVA_CODPED
		aVVA[nAux,07] := VVA->VVA_NUMPED
		aVVA[nAux,08] := VVA->VVA_CHASSI
		aVVA[nAux,09] := cChaInt
		aVVA[nAux,10] := (cSQLAlias)->( VV2_DESMOD )
		aVVA[nAux,11] := (cSQLAlias)->( VVC_DESCRI )
		aVVA[nAux,12] := VVA->VVA_VALASS
		aVVA[nAux,13] := VVA->VVA_DTLIBF
		aVVA[nAux,14] := VVA->VVA_DTEPRV
		aVVA[nAux,15] := VVA->VVA_HREPRV
		aVVA[nAux,16] := VVA->VVA_FIEPRV
		aVVA[nAux,17] := VVA->VVA_BOEPRV
		aVVA[nAux,18] := VVA->VVA_USEPRV
		aVVA[nAux,19] := cOpcFab
		aVVA[nAux,20] := VVA->VVA_NUMTRA
		aVVA[nAux,21] := VVA->VVA_FILENT
		aVVA[nAux,22] := VVA->VVA_TRACPA
		//
		For nCntFor := 1 to len(aVVACust)
			aVVA[nAux,23,nCntFor] := &("VVA->"+aVVACust[nCntFor,1])
		Next
		//
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
	DbSelectArea("VVA")
	//
EndIf
If len(aVVA) <= 0
	VXX0300011_CriaVetorVVA()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Vetor da PARAMBOX                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRet := array(nLenaCpo) // Retorno do Parambox
For nCntFor := 1 to nLenaCpo
	xAux := &("M->"+aCpo[nCntFor,2])
	If aCpo[nCntFor,5] == 1 // GetNormal
		aAdd(aParamBoxC,{1,aCpo[nCntFor,3],xAux,aCpo[nCntFor,6],aCpo[nCntFor,7],aCpo[nCntFor,8],aCpo[nCntFor,9],aCpo[nCntFor,10],aCpo[nCntFor,11]})
	ElseIf aCpo[nCntFor,5] == 2 // ComboBox
		If lAlt
			aAux := aClone(aCpo[nCntFor,8])
		Else
			For nAux := 1 to len(aCpo[nCntFor,8])
				If xAux == left(aCpo[nCntFor,8,nAux],1)
					aAux := {aCpo[nCntFor,8,nAux]}
				EndIf
			Next
		EndIf
		aAdd(aParamBoxC,{2,aCpo[nCntFor,3],xAux,aAux,aCpo[nCntFor,10],aCpo[nCntFor,7],aCpo[nCntFor,11]})
	EndIf
	aRet[nCntFor] := xAux // Inicializador padrao dos campos
	&("MV_PAR"+strzero(nCntFor,2)) := xAux
	If aCpo[nCntFor,len(aCpo[nCntFor])]
		aAdd(aObr,nCntFor) // Variaveis obrigatorios
	EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Matrizes com Tabelas Acessorias ao Atendimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VX002X3LOAD( "VS9" , .t. , @aVS9 , 1 , "VS9_FILIAL+VS9_NUMIDE+VS9_TIPOPE", xFilial("VS9")+PadR(M->VV9_NUMATE,TamSX3("VS9_NUMIDE")[1]," ")+"V")
VX002X3LOAD( "VSE" , .t. , @aVSE )
VX002X3LOAD( "VSE" , .t. , @aVSETotal , 1 , "VSE_FILIAL+VSE_NUMIDE+VSE_TIPOPE" , xFilial("VSE")+PadR(M->VV9_NUMATE,TamSX3("VSE_NUMIDE")[1]," ")+"V" )
//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Adiciona Botoes na Enchoice              |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aBotEncFtD, {"CHAVE2"    ,{|| VXX0300031_EntradasVS9(nOpc,@aParEnt,@aVS9,@aVSE) },(STR0092)} ) // Entradas
AADD(aBotEncFtD, {"MAQFOTO"   ,{|| VX030FOTO(nOpc)   },("<F4> "  + STR0026 )} ) // Foto(s)/Video(s) do Veiculo
AADD(aBotEncFtD, {"E5"        ,{|| VX030OPCOES(nOpc) },("<F10> " + STR0027 )} ) // Opcoes
AADD(aBotEncFtD, {"PARAMETROS",{|| VX030OPCFAB(nOpc) },( STR0087 )} ) // Incluir Opcionais do Veiculo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| SetKey das teclas  <F4>  <F10>           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(VK_F4,{|| VX030FOTO(nOpc) })
SetKey(VK_F10,{|| VX030OPCOES(nOpc) })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Totaliza Veiculos ( VVA )                |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FS_TOTALVVA(.f.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Tela                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgFatDir FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL
	oTPanelFatDir := TPanel():New(aPos[1,1] , aPos[1,2],"",oDlgFatDir,NIL,.T.,.F.,NIL,NIL,210,aPos[2,3]-aPos[1,1],.T.,.F.)
	ParamBox(aParamBoxC,"",@aRet,,,,1,1,oTPanelFatDir,,.f.)
	//
	oLbVVA := TWBrowse():New(aPos[1,1],214,aPos[1,4]-211,aPos[1,3]-aPos[1,1],,,,oDlgFatDir,,,,,{ || IIf( ( lAlt .and. ( nOpc == 3 .or. nOpc == 4 ) ),VX030VVA(4,oLbVVA:nAt,STR0008),.t.) },,,,,,,.F.,,.T.,,.F.,,,)
	oLbVVA:addColumn( TCColumn():new( STR0010 , { || aVVA[oLbVVA:nAt,2] }                                    ,,,,"LEFT" , 22,.F.,.F.,,,,.F.,) )
	oLbVVA:addColumn( TCColumn():new( STR0011 , { || Alltrim(aVVA[oLbVVA:nAt,3])+" - "+aVVA[oLbVVA:nAt,10] } ,,,,"LEFT" ,110,.F.,.F.,,,,.F.,) )
	oLbVVA:addColumn( TCColumn():new( STR0012 , { || aVVA[oLbVVA:nAt,11] }                                   ,,,,"LEFT" , 45,.F.,.F.,,,,.F.,) )
	oLbVVA:addColumn( TCColumn():new( STR0013 , { || Transform(aVVA[oLbVVA:nAt,5],"@E 99,999,999.99") }      ,,,,"RIGHT", 40,.F.,.F.,,,,.F.,) )
	oLbVVA:addColumn( TCColumn():new( STR0014 , { || aVVA[oLbVVA:nAt,7] }                                    ,,,,"LEFT" , 45,.F.,.F.,,,,.F.,) )
	oLbVVA:addColumn( TCColumn():new( STR0015 , { || aVVA[oLbVVA:nAt,8] }                                    ,,,,"LEFT" ,100,.F.,.F.,,,,.F.,) )
	For nCntFor := 1 to len(aVVACust) // Campos Customizados para serem preenchidos nos Itens do Faturamento Direto
		If aVVACust[nCntFor,3] // Mostrar no ListBox da Tela principal
			cPict := VVA->(X3PICTURE(aVVACust[nCntFor,1]))
			If !Empty(cPict)
				oLbVVA:addColumn( TCColumn():new( RetTitle(aVVACust[nCntFor,1]) , &("{ || Transform(aVVA[oLbVVA:nAt,23,"+Alltrim(str(nCntFor))+"],'"+cPict+"') }") ,,,,"LEFT" ,aVVACust[nCntFor,2],.F.,.F.,,,,.F.,) )
			Else
				oLbVVA:addColumn( TCColumn():new( RetTitle(aVVACust[nCntFor,1]) , &("{ || aVVA[oLbVVA:nAt,23,"+Alltrim(str(nCntFor))+"] }") ,,,,"LEFT" ,aVVACust[nCntFor,2],.F.,.F.,,,,.F.,) )
			EndIf
		EndIf
	Next
	oLbVVA:nAT := 1
	oLbVVA:SetArray(aVVA)
	//
	DEFINE SBUTTON FROM aPos[2,1],215 TYPE 15 ACTION VX030VVA(2,oLbVVA:nAt,STR0065) ENABLE ONSTOP STR0065 OF oDlgFatDir WHEN !Empty(Alltrim(aVVA[oLbVVA:nAt,2]+aVVA[oLbVVA:nAt,3]+aVVA[oLbVVA:nAt,4])) // Visualizar
	DEFINE SBUTTON FROM aPos[2,1],245 TYPE  4 ACTION VX030VVA(3,len(aVVA) ,STR0007) ENABLE ONSTOP STR0007 OF oDlgFatDir WHEN ( lAlt .and. ( nOpc == 3 .or. nOpc == 4 ) ) .and. ( ( len(aVVA) < nAVEIMAX ) .or. ( len(aVVA) == 1 .and. Empty(Alltrim(aVVA[1,2]+aVVA[1,3]+aVVA[1,4])) ) ) // Incluir
	DEFINE SBUTTON FROM aPos[2,1],275 TYPE 11 ACTION VX030VVA(4,oLbVVA:nAt,STR0008) ENABLE ONSTOP STR0008 OF oDlgFatDir WHEN ( lAlt .and. ( nOpc == 3 .or. nOpc == 4 ) ) // Editar
	DEFINE SBUTTON FROM aPos[2,1],305 TYPE  3 ACTION VX030VVA(5,oLbVVA:nAt,STR0009) ENABLE ONSTOP STR0009 OF oDlgFatDir WHEN ( lAlt .and. ( nOpc == 3 .or. nOpc == 4 ) ) // Excluir
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botoes de Visualizacao de Mapa de Avaliacao                    ³
	//³ Visualizar MAPA somente se usuario tiver permissao             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FGX_USERVL( xFilial("VAI"),__cUserID, "VAI_MAPVEI", "==" ,"1") // Usuario ver Mapa de Avaliacao
		oMapaBom := TBtnBmp2():New( aPos[2,1] * 2 , (aPos[2,4]-130) * 2 ,20,20,'BR_VERDE',,,,{|| FM_MAPAVAL(1,,VV9->VV9_NUMATE,.t.,80,,) },oDlgFatDir,STR0066,,.T.) // qmt_ok // Visualiza o Mapa de Avaliacao de Resultado
		oMapaMed := TBtnBmp2():New( aPos[2,1] * 2 , (aPos[2,4]-130) * 2 ,20,20,'BR_AMARELO',,,,{|| FM_MAPAVAL(1,,VV9->VV9_NUMATE,.t.,80,,) },oDlgFatDir,STR0066,,.T.) // qmt_cond // Visualiza o Mapa de Avaliacao de Resultado
		oMapaRui := TBtnBmp2():New( aPos[2,1] * 2 , (aPos[2,4]-130) * 2 ,20,20,'BR_VERMELHO',,,,{|| FM_MAPAVAL(1,,VV9->VV9_NUMATE,.t.,80,,) },oDlgFatDir,STR0066,,.T.) // qmt_no // Visualiza o Mapa de Avaliacao de Resultado
	Else
		oMapaBom := TBtnBmp2():New( aPos[2,1] * 2 , (aPos[2,4]-130) * 2 ,20,20,'BR_VERDE',,,,{|| MsgStop(STR0067,STR0002) },oDlgFatDir,STR0066,,.T.) // qmt_ok // Usuario sem permissao! / Atencao / Visualiza o Mapa de Avaliacao de Resultado
		oMapaMed := TBtnBmp2():New( aPos[2,1] * 2 , (aPos[2,4]-130) * 2 ,20,20,'BR_AMARELO',,,,{|| MsgStop(STR0067,STR0002) },oDlgFatDir,STR0066,,.T.) // qmt_cond // Usuario sem permissao! / Atencao / Visualiza o Mapa de Avaliacao de Resultado
		oMapaRui := TBtnBmp2():New( aPos[2,1] * 2 , (aPos[2,4]-130) * 2 ,20,20,'BR_VERMELHO',,,,{|| MsgStop(STR0067,STR0002) },oDlgFatDir,STR0066,,.T.) // qmt_no // Usuario sem permissao! / Atencao / Visualiza o Mapa de Avaliacao de Resultado
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Roda o Mapa para ver a caretinha atual... ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc <> 3
		VX030MAPAV()
	EndIf
	@ aPos[2,1]+1,aPos[2,4]-120 SAY STR0039 SIZE 40,10 OF oDlgFatDir PIXEL COLOR CLR_RED // TOTAL
	@ aPos[2,1]+0,aPos[2,4]-098 MSGET oVVATot VAR nVVATot PICTURE "@E 99,999,999,999.99" SIZE 70,10 OF oDlgFatDir PIXEL HASBUTTON WHEN .f.
	DEFINE SBUTTON FROM aPos[2,1],aPos[2,4]-025 TYPE 13 ACTION VX030TOK(nOpc,aCpo,aObr,.f.,@aRet,@aRecInter,@aVS9,@aVSE) ENABLE ONSTOP STR0037 OF oDlgFatDir WHEN ( lAlt .and. ( nOpc == 3 .or. nOpc == 4 ) ) // Salvar
ACTIVATE MSDIALOG oDlgFatDir CENTER ON INIT EnchoiceBar(oDlgFatDir,{|| IIF(VX030TOK(nOpc,aCpo,aObr,.t.,@aRet,@aRecInter,@aVS9,@aVSE),(lOkTela:=.t.,oDlgFatDir:End()),.t.) },{|| oDlgFatDir:End() },,aBotEncFtD)

SetKey(VK_F4, Nil )
SetKey(VK_F10, Nil )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ OK Tela  e  nao esta visualizando o Fatur.Direto   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lOkTela .and. nOpc <> 2

	If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verificar se o Cliente esta BLOQUEADO              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !VXI001VLCLI()
			Return()
		EndIf
		
		If lAvanca

			If VV9->VV9_STATUS == "A"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pendende Aprovacao                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Begin Transaction
					VEIVM130TAR(VV9->VV9_NUMATE,"4","2",VV9->VV9_FILIAL) // Tarefas: 4-Pendente Aprovacao / 2-Faturamento Direto
					// Reserva do Veiculo na Fase 2-Pendente Aprovacao
					For nCntFor := 1 to len(aVVA)
						If !Empty(aVVA[nCntFor,9]) // Possui VVA_CHAINT
							VEIXX004(nOpc,VV9->VV9_NUMATE,aVVA[nCntFor,9],"2") 
						EndIf
					Next
					VXX030021_FaseAutomaticaInteresse( VV9->VV9_FILIAL , VV9->VV9_NUMATE , "P" ) // Altera automaticamente a Fase do Interesse
					VXI001ATU(VV9->VV9_NUMATE,"P") // Atualiza Status
				End Transaction
				//
				VXX030011_EMAIL(1,"") // Gerar EMAIL no 1-Pendente Aprovação
				//
			EndIf

			If VV9->VV9_STATUS == "R"
				VXI001ATU(VV9->VV9_NUMATE,"P") // se 'Reprovado' passar para 'Pendente Aprovacao'
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pre-Aprovacao                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If VV9->VV9_STATUS == "P"
				If lFases
					nRet := VEIXX013(VV9->VV9_NUMATE,1) // Pre-Aprovacao
				Else
					nRet := 1
				EndIf
				If nRet > 0
					Begin Transaction
					If nRet == 1 // Pre-Aprovou
						VEIVM130TAR(VV9->VV9_NUMATE,"5","2",VV9->VV9_FILIAL) // Tarefas: 5-Pre-Aprovado / 2-Faturamento Direto
						// Reserva do Veiculo na Fase 3-Pre-Aprovado
						For nCntFor := 1 to len(aVVA)
							If !Empty(aVVA[nCntFor,9]) // Possui VVA_CHAINT
								VEIXX004(nOpc,VV9->VV9_NUMATE,aVVA[nCntFor,9],"3")
							EndIf
						Next
					Else // Reprovou a Pre-Aprovacao
						VXX030021_FaseAutomaticaInteresse( VV9->VV9_FILIAL , VV9->VV9_NUMATE , "R" ) // Altera automaticamente a Fase do Interesse
						VXI001ATU(VV9->VV9_NUMATE,"R") // Atualiza Status
						lInterrompe := .t.
					EndIf
					If !lInterrompe
						VXX030021_FaseAutomaticaInteresse( VV9->VV9_FILIAL , VV9->VV9_NUMATE , "O" ) // Altera automaticamente a Fase do Interesse
						VXI001ATU(VV9->VV9_NUMATE,"O") // Atualiza Status
					EndIf
					End Transaction
					If lInterrompe
						Return()
					EndIf
				Else // Cancelou a Pre-Aprovacao
					Return()
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verificar/Validar TAREFAS                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !VEIVM130TAR(VV9->VV9_NUMATE,"0A","2",VV9->VV9_FILIAL) // 0A-Verifica/Valida na Aprovacao / 2-Faturamento Direto
				Return()
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aprovacao                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If VV9->VV9_STATUS == "O"
				If lFases
					nRet := VEIXX013(VV9->VV9_NUMATE,2) // Aprovacao
				Else
					nRet := 1
				EndIf
				If nRet > 0
					Begin Transaction
					If nRet == 1 // Aprovou
						VEIVM130TAR(VV9->VV9_NUMATE,"6","2",VV9->VV9_FILIAL) // Tarefas: 6-Aprovado / 2-Faturamento Direto
						// Reserva do Veiculo na Fase 4-Aprovado
						For nCntFor := 1 to len(aVVA)
							If !Empty(aVVA[nCntFor,9]) // Possui VVA_CHAINT
								VEIXX004(nOpc,VV9->VV9_NUMATE,aVVA[nCntFor,9],"4")
							EndIf
						Next
						// 
					Else // Reprovou a Aprovacao
						VXX030021_FaseAutomaticaInteresse( VV9->VV9_FILIAL , VV9->VV9_NUMATE , "R" ) // Altera automaticamente a Fase do Interesse
						VXI001ATU(VV9->VV9_NUMATE,"R") // Atualiza Status
						lInterrompe := .t.
					EndIf
					If !lInterrompe
						VXX030021_FaseAutomaticaInteresse( VV9->VV9_FILIAL , VV9->VV9_NUMATE , "L" ) // Altera automaticamente a Fase do Interesse
						VXI001ATU(VV9->VV9_NUMATE,"L") // Atualiza Status
					EndIf
					End Transaction
					If lInterrompe
						Return()
					EndIf
				Else // Cancelou a Aprovacao
					Return()
				EndIf
	        EndIf
	        
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verificar/Validar TAREFAS                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !VEIVM130TAR(VV9->VV9_NUMATE,"0F","2",VV9->VV9_FILIAL) // 0F-Verifica/Valida na Finalizacao / 2-Faturamento Direto
				Return()
			EndIf
			
			If !lFases .or. MsgYesNo(STR0024,STR0002) // Deseja Finalizar Atendimento de Faturamento Direto? / Atencao

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Finalizar Atendimento de Faturamento Direto        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				VX030FIN()
				
			EndIf
			
		EndIf

	ElseIf nOpc == 5 // Excluir/Cancelar

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cancelar Atendimento de Faturamento Direto         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VX030CAN()

	EndIf

EndIf

If lAvanca
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| PE apos "Finalizacao do Faturamento Direto"                      |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("VX030FIM")
		ExecBlock("VX030FIM",.f.,.f.,)
	EndIf
EndIf

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VXX030GRVº Autor ³ Andre Luis Almeida  º Data ³ 06/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gravacao                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aCpo - Campos da Parambox Principal VV9 / VV0              º±±
±±º          ³ aRet - Retorno da Parambox Principal VV9 / VV0             º±±
±±º          ³ aRecInter - RecNo das Oportunidades/Interesses do Cliente  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXX030GRV(aCpo,aRet,aRecInter,aVS9,aVSE)
Local oCliente := DMS_Cliente():New()
Local lInc     := .f.
Local nCntFor  := 0
Local ni       := 0
Local lVVA     := .T. // Cria VVA ?
Local cNomeVVA := RetSQLName("VVA")
Local lTIPMOV  := ( VV0->(FieldPos("VV0_TIPMOV")) > 0 ) // Tipo de Movimento ( Normal / Agregacao / Desagregacao )
Local lHORVIS  := ( VV9->(FieldPos("VV9_HORVIS")) > 0 ) // Hora Visita
Local aIteTra  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregar variaveis de memoria  ( M-> )             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(MV_PAR01) // Incluir
	//
	DbSelectArea("VV9")
	RegToMemory("VV9",.t.,.f.,.t.)
	DbSelectArea("VV0")
	RegToMemory("VV0",.t.,.f.,.t.)
	ConfirmSX8()
	lInc := .t.
	//
Else // Alterar
	//
	DbSelectArea("VV9")
	RegToMemory("VV9",.f.,.f.)
	DbSelectArea("VV0")
	RegToMemory("VV0",.f.,.f.)
	//
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregar M-> com parametros da TELA                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCntFor := 1 to nLenaCpo
	&("M->"+aCpo[nCntFor,2]) := &("MV_PAR"+strzero(nCntFor,2))
Next

If !Empty(M->VV0_CLIFTD+M->VV0_LOJFTD) // Cliente Faturamento Direto
	If oCliente:Bloqueado( M->VV0_CLIFTD , M->VV0_LOJFTD , .T. ) // Cliente Bloqueado ?
		Return .f.
	EndIf
EndIf

If !Empty(M->VV0_CLIALI+M->VV0_LOJALI) // Cliente Alienacao
	If oCliente:Bloqueado( M->VV0_CLIALI , M->VV0_LOJALI , .T. ) // Cliente Bloqueado ?
		Return .f.
	EndIf
EndIf

SA1->(DbSetOrder(1))
If SA1->(MsSeek(xFilial("SA1")+M->VV9_CODCLI+M->VV9_LOJA)) // Cliente do Atendimento
	If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
		Return .f.
	Else
		M->VV9_TELVIS := SA1->A1_TEL
	EndIf
EndIf

Begin Transaction

If lInc // Incluir
	M->VV9_NUMATE := M->VV0_NUMTRA
	If Empty(M->VV9_NUMATE) .or. FM_SQL("SELECT R_E_C_N_O_ FROM "+RetSQLName("VV9")+" WHERE VV9_FILIAL='"+xFilial("VV9")+"' AND VV9_NUMATE='"+M->VV9_NUMATE+"'") > 0
		M->VV9_NUMATE := GetSXENum("VV0","VV0_NUMTRA") // Nro do Atendimento ("VV0")
		ConfirmSX8()
	EndIf
	aRet[1] := MV_PAR01 := M->VV9_NUMATE // Nro do Atendimento
	aParEnt[1] := M->VV9_NUMATE 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravar VV9                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nAVEIMAX <= 1
	M->VV9_CODMAR := aVVA[1,02]
	M->VV9_MODVEI := aVVA[1,03]
EndIf
DbSelectArea("VV9")
RecLock("VV9",lInc)
	FG_GRAVAR("VV9")
	If lInc
		VV9->VV9_FILIAL := xFilial("VV9")
		VV9->VV9_DATVIS := dDataBase
		If lHORVIS
			VV9->VV9_HORVIS := val(left(time(),2)+substr(time(),4,2)) // Hora Visita
		EndIf
		VV9->VV9_STATUS := "A" 
	EndIf
	VV9->VV9_VEND1  := M->VV0_CODVEN    
MsUnLock()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desposicionar, para considerar em SELECT no meio da transacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VV9->(dbGoTo(VV9->(Recno())))

VXX030004_GravaEntradasVS9VSE( @aVS9 , @aVSE )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravar VV0                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nAVEIMAX <= 1
	VV2->(DbSetOrder(1))
	VV2->(MsSeek(xFilial("VV2")+aVVA[1,02]+aVVA[1,03]))
	M->VV0_CODMAR := aVVA[1,02]
	M->VV0_MODVEI := aVVA[1,03]
	M->VV0_CORVEI := aVVA[1,04]
	M->VV0_GRUMOD := VV2->VV2_GRUMOD
EndIf
//
M->VV0_VALTAB := nVVATot
M->VV0_VALNEG := nVVATot
M->VV0_VALMOV := nVVATot
M->VV0_VALTOT := nVVATot
M->VV0_VALNEG := nVVATot
DbSelectArea("VV0")
RecLock("VV0",lInc)
	FG_GRAVAR("VV0")
	If lInc
		VV0->VV0_FILIAL := VV9->VV9_FILIAL
		VV0->VV0_NUMTRA := VV9->VV9_NUMATE
		VV0->VV0_TIPFAT := "2" // Faturamento Direto
		VV0->VV0_OPEMOV := "0" // 0 = Venda
		If lTIPMOV
			VV0->VV0_TIPMOV := "0" // 0 = Normal
		EndIf		
		VV0->VV0_VDAFUT := "0" // 0 = Nao eh Venda Futura
		VV0->VV0_SIMVDA := "V" // V = Venda
		VV0->VV0_TIPO   := "N" // VV0_TIPO = 'N' ( SA1 -> Cliente )
		VV0->VV0_DTHEMI := left(Dtoc(dDataBase),6) + right(Dtoc(dDataBase),2) + "/" + Time() // Dia/Mes/Ano(2 posicoes)/Hora:Minuto:Segundo 
	EndIf
	VV0->VV0_FORPAG := RetCondVei() // Sempre é Condicao Negociada
	VV0->VV0_CODCLI := VV9->VV9_CODCLI
	VV0->VV0_LOJA   := VV9->VV9_LOJA
	VV0->VV0_DATMOV := dDataBase
MsUnLock()
If lInc
	cObsAnt := E_MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1])
	If !Empty(cObsAnt)
		cObsAnt += Chr(13)+Chr(10)
	EndIf
	cObsAnt += Repl("_",TamSx3("VV0_OBSERV")[1])+Chr(13)+Chr(10)+"***  "+left(Alltrim(UsrRetName(__CUSERID)),15)+"  "+Transform(dDataBase,"@D")+" - "+Transform(time(),"@R 99:99")+"  ***"+Chr(13)+Chr(10)
	MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1],,cObsAnt+STR0040,1,,,"VV0","VV0_OBSMEM") // Atendimento ABERTO!
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desposicionar, para considerar em SELECT no meio da transacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VV0->(dbGoTo(VV0->(Recno())))
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VVA deletado - reutilizar VVA e/ou excluir VVA     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If len(aDelVVA) > 0
	For nCntFor := 1 to len(aVVA)
		If aVVA[nCntFor,1] <= 0 // registro novo
			For ni := 1 to len(aDelVVA)
				If aDelVVA[ni] > 0
					aVVA[nCntFor,01] := aDelVVA[ni] // Reutilizar registro do VVA
					aDelVVA[ni] := 0
					Exit
				EndIf
			Next
		EndIf
	Next
	DbSelectArea("VVA")
	For ni := 1 to len(aDelVVA)
		If aDelVVA[ni] > 0
			DbGoTo(aDelVVA[ni])
			RecLock("VVA",.F.,.T.)
			VVA->(dbDelete()) // Excluir VVA
			MsUnLock()
		EndIf
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravar VVA                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCntFor := 1 to len(aVVA)
	//
	VV2->(DbSetOrder(1))
	VV2->(MsSeek(xFilial("VV2")+aVVA[nCntFor,02]+aVVA[nCntFor,03]))
	DbSelectArea("VVA")
	If aVVA[nCntFor,01] > 0
		DbGoTo(aVVA[nCntFor,01]) // RecNo("VVA")
		RegToMemory("VVA",.f.,.f.)
		lVVA := .f. // RecLock("VVA",.f.) -> Alterar VVA
	Else
		RegToMemory("VVA",.t.,.f.,.t.)
		M->VVA_FILIAL := VV9->VV9_FILIAL
		M->VVA_NUMTRA := VV9->VV9_NUMATE
		M->VVA_TRACPA := "FATDIR"
		M->VVA_SIMVDA := "V" // V=Venda
		M->VVA_ITETRA := FM_SQL("SELECT MAX(VVA_ITETRA) FROM "+cNomeVVA+" WHERE VVA_FILIAL='"+VV9->VV9_FILIAL+"' AND VVA_NUMTRA='"+VV9->VV9_NUMATE+"'")
		M->VVA_ESTVEI := "0" // Veiculo Novo ...
		M->VVA_CODORI := "0" // Fabrica ...
		If !Empty(aVVA[nCntFor,09])
			VV1->(DbSetOrder(1))
			If VV1->(MsSeek(xFilial("VV1")+aVVA[nCntFor,09]))
				If !Empty(VV1->VV1_ESTVEI)
					M->VVA_ESTVEI := VV1->VV1_ESTVEI
				EndIf
				If !Empty(VV1->VV1_CODORI)
					M->VVA_CODORI := VV1->VV1_CODORI
				EndIf
			EndIf
		EndIf
		If !Empty(M->VVA_ITETRA)
			M->VVA_ITETRA := Soma1(M->VVA_ITETRA)
		Else
			M->VVA_ITETRA := StrZero(1,TamSX3("VVA_ITETRA")[1])
		EndIf
		lVVA := .t. // RecLock("VVA",.t.) -> Incluir VVA
	EndIf
	//
	M->VVA_CODMAR := aVVA[nCntFor,02]
	M->VVA_MODVEI := aVVA[nCntFor,03]
	M->VVA_CORVEI := aVVA[nCntFor,04]
	M->VVA_GRUMOD := VV2->VV2_GRUMOD
	M->VVA_VALTAB := aVVA[nCntFor,05] // Valor
	M->VVA_VALVDA := aVVA[nCntFor,05] // Valor
	M->VVA_VALMOV := aVVA[nCntFor,05] // Valor
	M->VVA_FATTOT := aVVA[nCntFor,05] // Valor
	M->VVA_CODPED := aVVA[nCntFor,06]
	M->VVA_NUMPED := aVVA[nCntFor,07]
	M->VVA_CHASSI := aVVA[nCntFor,08]
	M->VVA_CHAINT := aVVA[nCntFor,09]
	M->VVA_VALASS := aVVA[nCntFor,12]
	M->VVA_DTLIBF := aVVA[nCntFor,13]
	M->VVA_DTEPRV := aVVA[nCntFor,14]
	M->VVA_HREPRV := aVVA[nCntFor,15]
	M->VVA_FIEPRV := aVVA[nCntFor,16]
	M->VVA_BOEPRV := aVVA[nCntFor,17]
	M->VVA_USEPRV := aVVA[nCntFor,18]
	M->VVA_DESVEI := FGX_DRECVEI(aVVA[nCntFor,09],"0",,.t.) // Levanta Despesas do Veiculo VVD
	M->VVA_RECVEI := FGX_DRECVEI(aVVA[nCntFor,09],"1",,.t.) // Levanta Receitas do Veiculo VVD
	//
	For ni := 1 to len(aVVACust) // Campos do VVA customizados
		&("M->"+aVVACust[ni,1]) := aVVA[nCntFor,23,ni]
	Next
	//
	RecLock("VVA",lVVA)
		FG_GRAVAR("VVA")
		MSMM(VVA->VVA_OBSMEM,TamSx3("VVA_OBSERV")[1],,aVVA[nCntFor,19],1,,,"VVA","VVA_OBSMEM") // Opcionais Temporario
	MsUnLock()
	//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desposicionar, para considerar em SELECT no meio da transacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	VVA->(dbGoTo(VVA->(Recno())))
	//
	If lVVA
		aVVA[nCntFor,01] := VVA->(Recno())
	EndIf
	//
	aAdd(aIteTra,VVA->VVA_ITETRA+"="+Alltrim(VVA->VVA_CODMAR)+" "+Alltrim(VVA->VVA_MODVEI)+" "+Alltrim(VVA->VVA_CORVEI))
	//
Next

If ExistBlock("VXX030DGR") // Ponto de Entrada para gravação de campos customizáveis
	ExecBlock("VXX030DGR", .f., .f.)
EndIf

End Transaction

If lInc .and. len(aRecInter) > 0
	VX030GRVOPO(@aRecInter,aIteTra) // Selecionar quais Oportunidades/Interesses foram atendidos
EndIf

VX030MAPAV() // Mapa de Avaliacao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Solicitar TAREFAS                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VEIVM130TAR(VV9->VV9_NUMATE,"1","2",VV9->VV9_FILIAL) // Tarefas: 1-Gravacao / 2-Faturamento Direto

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX030CLI º Autor ³ Andre Luis Almeida  º Data ³ 01/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Posicionamento nos Clientes                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aRet - Retorno da Parambox Principal VV9 / VV0             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX030CLI(nTp,aRet)
Local oCliente := DMS_Cliente():New()
Local lRet := .f.
Do Case

	Case nTp == 1 // Cliente do Atendimento
		cCdCliAt := MV_PAR02
		cLjCliAt := MV_PAR03
		MV_PAR04 := ""
		If !Empty(MV_PAR02)
			SA1->(DbSetOrder(1))
			If SA1->(MsSeek(xFilial("SA1")+MV_PAR02+MV_PAR03))
				If !oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
					MV_PAR04 := SA1->A1_NOME
					lRet := .t.
				EndIf
			ElseIf SA1->(MsSeek(xFilial("SA1")+MV_PAR02))
				If !oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
					MV_PAR03 := SA1->A1_LOJA
					MV_PAR04 := SA1->A1_NOME
					lRet := .t.
				EndIf
			EndIf
		Else
			MV_PAR03 := space(TamSX3("A1_LOJA")[1])
			lRet := .t.
		EndIf
		aRet[3] := MV_PAR03
		aRet[4] := MV_PAR04

	Case nTp == 2 // Cliente Faturamento Direto
		If !Empty(MV_PAR06)
			SA1->(DbSetOrder(1))
			If SA1->(MsSeek(xFilial("SA1")+MV_PAR06+MV_PAR07))
				If !oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
					lRet := .t.
				EndIf
			ElseIf SA1->(MsSeek(xFilial("SA1")+MV_PAR06))
				If !oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
					MV_PAR07 := SA1->A1_LOJA
					lRet := .t.
				EndIf
			EndIf
		Else
			MV_PAR07 := space(TamSX3("A1_LOJA")[1])
			lRet := .t.
		EndIf
		aRet[07] := MV_PAR07
		
	Case nTp == 3 // Cliente Alienação ( Banco )
		If !Empty(MV_PAR15)
			SA1->(DbSetOrder(1))
			If SA1->(MsSeek(xFilial("SA1")+MV_PAR15+MV_PAR16))
				If !oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
					lRet := .t.
				EndIf
			ElseIf SA1->(MsSeek(xFilial("SA1")+MV_PAR15))
				If !oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
					MV_PAR16 := SA1->A1_LOJA
					lRet := .t.
				EndIf
			EndIf
		Else
			MV_PAR16 := space(TamSX3("A1_LOJA")[1])
			lRet := .t.
		EndIf
		aRet[16] := MV_PAR16

EndCase
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX030TOK º Autor ³ Andre Luis Almeida  º Data ³ 25/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tudo OK da TELA                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpc - nOpc da Rotina                                      º±±
±±º          ³ aCpo - Campos da Parambox Principal VV9 / VV0              º±±
±±º          ³ aObr - Campos Obrigatorios                                 º±±
±±º          ³ lPergAva - Pergunta se Finaliza ?                          º±±
±±º          ³ aRet - Retorno da Parambox Principal VV9 / VV0             º±±
±±º          ³ aRecInter - RecNo das Oportunidades/Interesses do Cliente  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX030TOK(nOpc,aCpo,aObr,lPergAva,aRet,aRecInter,aVS9,aVSE)
Local nCntFor := 0
Local lRet    := .t.
Local cQuery  := ""
//
lAvanca := .f. // NAO AVANCA
//
If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
	For nCntFor := 1 to Len(aObr)
		If Empty(&("MV_PAR"+strzero(aObr[nCntFor],2)))
			lRet := .f.
			MsgStop(STR0018+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
					'" '+Alltrim(aCpo[aObr[nCntFor],3])+' "'+space(5)+;
					"( "+Alltrim(str(aObr[nCntFor]))+"º."+" "+STR0019+" )",STR0002) // Campo obrigatorio nao esta preenchido! / Atencao
			Exit
		EndIf
	Next
	For nCntFor := 1 to Len(aVVA)
		If aVVA[nCntFor,5] <= 0
			lRet := .f.
			MsgStop(STR0018+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
					'" '+Alltrim(STR0013)+' "'+space(5)+;
					"( "+Alltrim(aVVA[nCntFor,2])+" "+Alltrim(aVVA[nCntFor,3])+" "+Alltrim(aVVA[nCntFor,4])+" )",STR0002) // Campo obrigatorio nao esta preenchido! / Atencao
			Exit
		EndIf
	Next
	If lRet .and. !Empty(MV_PAR08+MV_PAR09)
		cQuery := "SELECT R_E_C_N_O_ AS RECVV0 FROM "+RetSQLName("VV0")+" WHERE VV0_FILIAL='"+xFilial("VV0")+"' AND "
		If !Empty(MV_PAR01)
			cQuery += "VV0_NUMTRA<>'"+MV_PAR01+"' AND "
		EndIf
		cQuery += "VV0_NNFFDI='"+MV_PAR08+"' AND VV0_SNFFDI='"+MV_PAR09+"' AND D_E_L_E_T_=' '"
		If FM_SQL(cQuery) > 0
			lRet := .f.
			MsgStop(STR0020+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
						Alltrim(RetTitle("VV0_NNFFDI"))+": "+MV_PAR08+CHR(13)+CHR(10)+;
						Alltrim(RetTitle("VV0_SNFFDI"))+": "+MV_PAR09,STR0002) // NF/Serie ja existente! / Atencao
		EndIf
	EndIf
	If lRet .and. lPergAva
		If VV9->VV9_STATUS == "L" .or. ( lFases .and. MsgYesNo(STR0064,STR0002) ) .or. ( !lFases .and. MsgYesNo(STR0024,STR0002) ) // Avanca a Fase do Atendimento de Faturamento Direto? / Atencao // Deseja Finalizar Atendimento de Faturamento Direto? / Atencao
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Validar VVA_CHASSI                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nCntFor := 1 to len(aVVA)
				If Empty(aVVA[nCntFor,08]) // NAO TEM CHASSI
					If !Empty(aVVA[nCntFor,09]) // TEM CHAINT
						VV1->(DbSetOrder(1))
						If VV1->(MsSeek(xFilial("VV1")+aVVA[nCntFor,09]))
							aVVA[nCntFor,08] := VV1->VV1_CHASSI
						EndIf
					Else // NAO TEM CHASSI E NAO TEM CHAINT
		 				MsgStop(STR0025,STR0002) // Para finalizar, e necessario informar o CHASSI. / Atencao
						lRet := .f.
						Exit
					EndIf
				EndIf
			Next
			lAvanca := lRet
		EndIf
	EndIf
	If lRet
		If ExistBlock("VXX30TOK")
			lRet :=  ExecBlock("VXX30TOK",.f.,.f.,{nOpc,lAvanca,aClone(aVVA)}) // PE no OK da Tela do Fat.Direto
		EndIf
	EndIf
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravar Atendimento de Faturamento Direto           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet := VXX030GRV(aCpo,@aRet,@aRecInter,@aVS9,@aVSE)
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX030FIN º Autor ³ Andre Luis Almeida  º Data ³ 31/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Finaliza Atendimento                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX030FIN()
Local nCntFor := 0
Local lVV1    := .T. // Cria VV1 ?
Local cObsAnt := ""
Local lVV1_DTUVEN := ( VV1->(FieldPos("VV1_DTUVEN")) > 0 ) // Data da Ultima Venda
Local lVV0_FLUXO  := ( VV0->(FieldPos("VV0_FLUXO ")) > 0 ) // Fluxo de Caixa

Begin Transaction

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validar/Gravar VVA_CHASSI  /  Inluir/Alterar VV1   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCntFor := 1 to len(aVVA)
		//
		lVV1 := .T.
		If !Empty(aVVA[nCntFor,09]) // TEM CHAINT
			VV1->(DbSetOrder(1))
			If VV1->(MsSeek(xFilial("VV1")+aVVA[nCntFor,09]))
				lVV1 := .F.
			EndIf
		EndIf
		//
		DbSelectArea("VV1")
		RecLock("VV1",lVV1)
			If lVV1
				VV1->VV1_FILIAL := xFilial("VV1")
				VV1->VV1_CHAINT := GetSXENum("VV1","VV1_CHAINT")
				ConfirmSx8("VV1")
				VV1->VV1_VEIACO := "0"
				VV1->VV1_CODORI := "2"
				VV1->VV1_PROVEI := " "
				VV1->VV1_INDCAL := " "
			EndIf
			VV1->VV1_CHASSI := aVVA[nCntFor,08]
			VV1->VV1_CODMAR := aVVA[nCntFor,02]
			VV1->VV1_MODVEI := aVVA[nCntFor,03]
			VV1->VV1_CORVEI := aVVA[nCntFor,04]
			VV1->VV1_PROATU := VV9->VV9_CODCLI
			VV1->VV1_LJPATU := VV9->VV9_LOJA
			VV1->VV1_TRACPA := "FATDIR"
			VV1->VV1_ULTMOV := "S"
			VV1->VV1_FILSAI := VV9->VV9_FILIAL
			VV1->VV1_NUMTRA := VV9->VV9_NUMATE
			VV1->VV1_DATVEN := dDatabase // Data da 1a.Venda
			If lVV1_DTUVEN
				VV1->VV1_DTUVEN := dDatabase // Data da Ultima Venda
    		EndIf
			VV1->VV1_SITVEI := "1" // Vendido
			VV1->VV1_OPCFAB := aVVA[nCntFor,19]
		MsUnlock()
		//
		VO5->(DbSetOrder(1))
		If VO5->(DbSeek(xFilial("VO5")+VV1->VV1_CHAINT))
			DbSelectArea("VO5")
			RecLock("VO5",.f.)
			VO5->VO5_DATVEN := dDatabase
			MsUnlock()
		EndIf
		//
		If Empty(aVVA[nCntFor,08]) .or. Empty(aVVA[nCntFor,09]) // Chassi ou ChaInt 
			//
			DbSelectArea("VVA")
			DbGoTo(aVVA[nCntFor,01]) // RecNo("VVA")
			RecLock("VVA",.f.)
				VVA->VVA_CHASSI := VV1->VV1_CHASSI
				VVA->VVA_CHAINT := VV1->VV1_CHAINT
			MsUnLock()
			aVVA[nCntFor,08] := VV1->VV1_CHASSI
			aVVA[nCntFor,09] := VV1->VV1_CHAINT
			//
		EndIf
		//
		VX002VC3("F",VV9->VV9_NUMATE,VVA->VVA_CHASSI) // Inserir VC3 - Frota do Cliente
		//
	Next
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza VV9                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectarea("VV9")
	RecLock("VV9",.f.)
	VV9->VV9_STATUS := "F"
	VV9->VV9_MOTIVO := ""
	VV9->VV9_DATCAN := ctod("")
	MsUnlock()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza VV0                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectarea("VV0")
	RecLock("VV0",.f.)
	VV0->VV0_STATUS := "F"
	VV0->VV0_DTHEMI := left(Dtoc(dDataBase),6) + right(Dtoc(dDataBase),2) + "/" + Time() // Dia/Mes/Ano(2 posicoes)/Hora:Minuto:Segundo 
	VV0->VV0_DATAPR := dDataBase
	VV0->VV0_USRAPR := __CUSERID
	If lVV0_FLUXO
		VV0->VV0_FLUXO := "S" // Constar no Fluxo de Caixa quando Aprovar Atendimento
	EndIf
	MsUnlock()
	cObsAnt := E_MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1])
	If !Empty(cObsAnt)
		cObsAnt += Chr(13)+Chr(10)
	EndIf
	cObsAnt += Repl("_",TamSx3("VV0_OBSERV")[1])+Chr(13)+Chr(10)+"***  "+left(Alltrim(UsrRetName(__CUSERID)),15)+"  "+Transform(dDataBase,"@D")+" - "+Transform(time(),"@R 99:99")+"  ***"+Chr(13)+Chr(10)
	MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1],,cObsAnt+STR0041,1,,,"VV0","VV0_OBSMEM") // Atendimento FINALIZADO!

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Geracao do CEV ( Pos-Venda )                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	VX002CEV("F",VV9->VV9_NUMATE)

End Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Solicitar TAREFAS                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VEIVM130TAR(VV9->VV9_NUMATE,"2","2",VV9->VV9_FILIAL) // Tarefas: 2-Finalizacao / 2-Faturamento Direto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Levanta e grava Incentivos automaticamente na Finalização do Fat.Direto  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetNewPar("MV_MIL0163","0") == "1" // ( 0=Não / 1=Sim )
	VEIVM180( VV9->(RecNo()) , .f. , .t. )
EndIf

//
VXX030011_EMAIL(5,"") // Gerar EMAIL no 5-Atendimento Finalizado
//

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX030CAN º Autor ³ Andre Luis Almeida  º Data ³ 31/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cancelamento Atendimento                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX030CAN()
Local cQuery      := ""
Local cSQLAlias   := "SQLVVA"
Local nCntFor     := 0
Local cMsg        := STR0044 // Usuario sem permissao para Cancelar/Voltar Atendimento!
Local cObsAnt     := ""
Local cObsMot     := ""
Local cCancVAI    := VAI->VAI_CANVEI // Permissao: ( 0=Nao faz nada / 1=Volta / 2=Cancela/Volta )
Local lCancVAI    := .t.
Local aMotCancel  := {}
Local cFasePrx    := ""
Local nOpcao      := 0
Local aVQ2        := {}
Local lVQ0_ITETRA := ( VQ0->(FieldPos("VQ0_ITETRA")) > 0 )
Local lVV1_DTUVEN := ( VV1->(FieldPos("VV1_DTUVEN")) > 0 ) // Data da Ultima Venda

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificar STATUS do Atendimento e Permissao do Usuario no VAI    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If VV9->VV9_STATUS == "A" // Aberto
	If substr(cCancVAI,1,1) == "2" // VAI - Permite Cancelar/Voltar
		cFasePrx := "C" // Cancelar o Atendimento
	Else
		lCancVAI := .f. // Usuario sem permissao
		If substr(cCancVAI,1,1) == "1" // VAI - Permite Voltar
			cMsg := STR0045 // Impossivel Voltar o Atendimento, pois o mesmo se encontra Aberto!
		EndIf
	EndIf
ElseIf VV9->VV9_STATUS $ "POLR" // Pendente Aprovacao / Pre-Aprovado / Aprovado / Reprovado
	If ( VV9->VV9_STATUS=="P" .and. substr(cCancVAI,2,1) == "2" ) .or. ; // VAI - Permite Cancelar/Voltar
		( VV9->VV9_STATUS=="O" .and. substr(cCancVAI,3,1) == "2" ) .or. ;
		( VV9->VV9_STATUS=="L" .and. substr(cCancVAI,4,1) == "2" ) .or. ;
		( VV9->VV9_STATUS=="R" .and. substr(cCancVAI,5,1) == "2" )
		nOpcao := Aviso(STR0046,"- "+STR0047+CHR(13)+CHR(10)+"- "+STR0048, { STR0049 , STR0050 } ) // Cancelamento do Atendimento / Voltar Atendimento para Aberto / Cancelar Total o Atendimento / Voltar / Cancelar
		If nOpcao == 1 // Voltar para Aberto
			cFasePrx := "A" // Voltar o Atendimento para Aberto
		ElseIf nOpcao == 2 // Cancelar
			cFasePrx := "C" // Cancelar o Atendimento
		EndIf
	ElseIf ( VV9->VV9_STATUS=="P" .and. substr(cCancVAI,2,1) == "1" ) .or. ; // VAI - Permite Voltar
		( VV9->VV9_STATUS=="O" .and. substr(cCancVAI,3,1) == "1" ) .or. ;
		( VV9->VV9_STATUS=="L" .and. substr(cCancVAI,4,1) == "1" ) .or. ;
		( VV9->VV9_STATUS=="R" .and. substr(cCancVAI,5,1) == "1" )
		nOpcao   := 1   // Voltar para Aberto
		cFasePrx := "A" // Voltar o Atendimento para Aberto
	Else
		lCancVAI := .f. // Usuario sem permissao
	EndIf
ElseIf VV9->VV9_STATUS == "F" // Finalizado
	If substr(cCancVAI,6,1) == "2" // VAI - Permite Cancelar/Voltar
		If lFases
			nOpcao := Aviso(STR0046,"- "+STR0078+CHR(13)+CHR(10)+"- "+STR0048, { STR0049 , STR0050 } ) // Cancelamento do Atendimento / Voltar Atendimento para Aprovado / Cancelar Total o Atendimento / Voltar / Cancelar
			If nOpcao == 1 // Voltar para Aprovado
				cFasePrx := "L" // Voltar o Atendimento para Aprovado
			ElseIf nOpcao == 2 // Cancelar
				cFasePrx := "C" // Cancelar o Atendimento
			EndIf
		Else
			nOpcao := Aviso(STR0046,"- "+STR0047+CHR(13)+CHR(10)+"- "+STR0048, { STR0049 , STR0050 } ) // Cancelamento do Atendimento / Voltar Atendimento para Aberto / Cancelar Total o Atendimento / Voltar / Cancelar
			If nOpcao == 1 // Voltar para Aberto
				cFasePrx := "A" // Voltar o Atendimento para Aberto
			ElseIf nOpcao == 2 // Cancelar
				cFasePrx := "C" // Cancelar o Atendimento
			EndIf
		EndIf
	ElseIf substr(cCancVAI,6,1) == "1" // VAI - Permite Voltar
		nOpcao   := 1   // Voltar para Aprovado
		cFasePrx := "L" // Voltar o Atendimento para Aprovado
	Else
		lCancVAI := .f. // Usuario sem permissao
	EndIf
EndIf
If !lCancVAI
	MsgStop(cMsg,STR0002) // Atencao
	Return()
EndIf

If ( cFasePrx == "C" .or. cFasePrx == "L" .or. cFasePrx == "A" ) // "Cancelar" ou "Voltar para Aprovado" ou "Voltar para Aberto"

	cQuery := "SELECT VQ2.R_E_C_N_O_ RECVQ2 , VQ2.VQ2_STATUS FROM "+RetSQLName("VQ2")+" VQ2 WHERE "
	cQuery += "VQ2.VQ2_FILATE='"+VV9->VV9_FILIAL+"' AND VQ2.VQ2_NUMATE='"+VV9->VV9_NUMATE+"' AND VQ2.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F., .T. )
	While !( cSQLAlias )->( Eof() )
		aAdd(aVQ2,{ ( cSQLAlias )->( RECVQ2 ) , ( cSQLAlias )->( VQ2_STATUS ) })
		( cSQLAlias )->( DbSkip() )
	EndDo	
	( cSQLAlias )->( DbCloseArea() )
	If len(aVQ2) > 0
		For nCntFor := 1 to len(aVQ2)
		    If aVQ2[nCntFor,2] == "3" // Gerada NF
	    		MsgStop(STR0051,STR0002) // Impossivel continuar! Existe(m) NF(s) gerada(s) referente(s) a comissão(ões)/incentivo(s) de Faturamento Direto. / Atencao
	    		Return()
		    EndIf
		Next
		If cFasePrx == "L" .or. cFasePrx == "A"
			If !MsgYesNo(STR0052,STR0002) // Deseja excluir a(s) comissão(ões)/incentivo(s) de Faturamento Direto referente a esse Atendimento? / Atencao
		    	Return()
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Perguntar se deseja realmente CANCELAR Atendimento               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cFasePrx == "C"
		nOpcao := 0
		If MsgYesNo(STR0053,STR0002) // Deseja realmente CANCELAR o Atendimento? / Atencao
			nOpcao := 1
		EndIf
	EndIf

	If nOpcao > 0

		If cFasePrx == "C" // Cancelar
			If ExistBlock("VLDEXC011")
				If !ExecBlock("VLDEXC011",.f.,.f.)
					Return()
				EndIf
			EndIf
		EndIf

		Begin Transaction

		If ExistBlock("VXI01ACA")
			If !ExecBlock("VXI01ACA",.f.,.f.,{VV9->VV9_NUMATE,cFasePrx})
				DisarmTransaction()
				Return()
			EndIf
		EndIf


		If cFasePrx == "C" // Cancelar
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Motivo do Cancelamento do Atendimento                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aMotCancel := OFA210MOT("000001","1",VV9->VV9_FILIAL,VV9->VV9_NUMATE,.t.) // Filtro da consulta do motivo de Cancelamentos ( 000001 = Atendimento de Veiculos )
			If len(aMotCancel) <= 0
				DisarmTransaction()
				Return()
			EndIf
		EndIf


		If len(aVQ2) > 0
			For nCntFor := 1 to len(aVQ2)
				DbSelectArea("VQ2")
				DbGoTo(aVQ2[nCntFor,1])
				If cFasePrx == "L" .or. cFasePrx == "A" // Caso o Atendimento for voltar para Aprovado ou Aberto, excluir comissoes e incentivos
					RecLock("VQ2",.f.,.t.)
						DbDelete()
					MsUnLock()
				Else // Caso o Atendimento for Cancelado, serao canceladas as comissoes e incentivos
					RecLock("VQ2",.f.)
						VQ2->VQ2_STATUS := "4"
					MsUnLock()
			    EndIf
			Next
		EndIf
		
		If cFasePrx == "C" // Cancelar o Atendimento
    	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Solicitar TAREFAS                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			VEIVM130TAR(VV9->VV9_NUMATE,"9","2",VV9->VV9_FILIAL) // Tarefas: 9-Cancelamento / 2-Faturamento Direto

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Deletar TAREFAS que deverao ser executadas novamente ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VEIVM130DEL(VV9->VV9_NUMATE,cFasePrx,VV9->VV9_FILIAL) // "Deleta" Tarefas que deverao ser executadas novamente.

		For nCntFor := 1 to len(aVVA)

			VVA->(dbGoTo(aVVA[nCntFor,01]))

			VEIXX004(5,VV9->VV9_NUMATE,VVA->VVA_CHAINT,"0") // Reserva ( Cancela Reserva do Veiculo )

			If !Empty(VVA->VVA_CODPED)
				DbSelectArea("VQ0")
				DbSetOrder(1)
				If DbSeek(xFilial("VQ0")+VVA->VVA_CODPED) // Limpar campos: Filial e Nro Atendimento
					RecLock("VQ0",.f.)
						VQ0->VQ0_FILATE := ""
						VQ0->VQ0_NUMATE := ""
						If lVQ0_ITETRA
							VQ0->VQ0_ITETRA := ""
						EndIf
					MsUnLock()
				EndIf
				DbSelectArea("VVA")
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Excluir VC3 - Frota do Cliente                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			VX002VC3("C",VV9->VV9_NUMATE,VVA->VVA_CHASSI)
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Limpar DATA de VENDA do Veiculo                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("VV1")
			DbSetOrder(1)
			If DbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
				RecLock("VV1",.f.)
				VV1->VV1_SITVEI := " "
				VV1->VV1_DATVEN := ctod("") // Data da 1a.Venda
				If lVV1_DTUVEN
					VV1->VV1_DTUVEN := ctod("") // Data da Ultima Venda
				EndIf
				MsUnlock()
				DbSelectArea("VO5")
				DbSetOrder(1)
				If DbSeek(xFilial("VO5")+VV1->VV1_CHAINT)
					RecLock("VO5",.f.)
					VO5->VO5_DATVEN := ctod("")
					MsUnlock()
				EndIf
			EndIf
				
		Next

		If cFasePrx == "C" // Cancelar o Atendimento
    	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravar CEV no Cancelamento do Atendimento                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aMotCancel[3] // Motivo do Cancelamento GERA CEV ?
				VX002CEV("CT",VV9->VV9_NUMATE) // Geracao do CEV ( CT - Cancelamento Total do Atendimento )
			EndIf
			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Levantar o Motivo do Cancelamento do Atendimento              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cObsMot := STR0022+" "+aMotCancel[2] // Atendimento CANCELADO! Motivo:
			For nCntFor := 1 to len(aMotCancel[4])
				If !Empty(aMotCancel[4,nCntFor,1])
					cObsMot += CHR(13)+CHR(10)+" - "+Alltrim(aMotCancel[4,nCntFor,1])+": "+Transform(aMotCancel[4,nCntFor,2],aMotCancel[4,nCntFor,6])
				EndIf
			Next

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravar VV9                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("VV9")
			RecLock("VV9",.f.)
				VV9->VV9_STATUS := "C"
				VV9->VV9_MOTIVO := aMotCancel[1]
				VV9->VV9_DATCAN := dDataBase
			MsUnLock()
			cObsAnt := E_MSMM(VV9->VV9_OBSMEM,TamSx3("VV9_OBSERV")[1])
			If !Empty(cObsAnt)
				cObsAnt += Chr(13)+Chr(10)
			EndIf
			cObsAnt += Replicate("-",TamSx3("VV9_OBSERV")[1])+CHR(13)+CHR(10)
			cObsAnt += cObsMot
			MSMM(VV9->VV9_OBSMEM,TamSx3("VV9_OBSERV")[1],,cObsAnt,1,,,"VV9","VV9_OBSMEM")
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravar VV0                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("VV0")
			cObsAnt := E_MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1])
			If !Empty(cObsAnt)
				cObsAnt += Chr(13)+Chr(10)
			EndIf
			cObsAnt += Repl("_",TamSx3("VV0_OBSERV")[1])+Chr(13)+Chr(10)+"***  "+left(Alltrim(UsrRetName(__CUSERID)),15)+"  "+Transform(dDataBase,"@D")+" - "+Transform(time(),"@R 99:99")+"  ***"+Chr(13)+Chr(10)
			cObsAnt += cObsMot
			MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1],,cObsAnt,1,,,"VV0","VV0_OBSMEM")

		Else // Voltar Atendimento para Aprovado ou Aberto

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravar VV9                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("VV9")
			RecLock("VV9",.f.)
				VV9->VV9_STATUS :=  cFasePrx // "L" - Aprovado / "A" - Aberto
			MsUnlock()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Geracao do CEV ( CP - Cancelamento Parcial )       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			VX002CEV("CP",VV9->VV9_NUMATE)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravar Observacoes ( MEMOS )                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("VV0")
			cObsAnt := E_MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1])
			If !Empty(cObsAnt)
				cObsAnt += Chr(13)+Chr(10)
			EndIf
			cObsAnt += Repl("_",TamSx3("VV0_OBSERV")[1])+Chr(13)+Chr(10)+"***  "+left(Alltrim(UsrRetName(__CUSERID)),15)+"  "+Transform(dDataBase,"@D")+" - "+Transform(time(),"@R 99:99")+"  ***"+Chr(13)+Chr(10)
			If cFasePrx == "A" // Atendimento Aberto
				cObsAnt += STR0042 // Atendimento voltou para ABERTO!
			ElseIf cFasePrx == "L" // Atendimento Aprovado
				cObsAnt += STR0077 // Atendimento voltou para APROVADO!
			EndIf
			MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1],,cObsAnt,1,,,"VV0","VV0_OBSMEM")

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravar VV0                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("VV0")
		RecLock("VV0",.f.)
			VV0->VV0_NUMNFI := ""
			VV0->VV0_SERNFI := ""
			if fieldpos("VV0_SDOC") > 0
				VV0->VV0_SDOC := ""
			EndIf
			VV0->VV0_NUMPED := ""
			VV0->VV0_NNFFDI := ""
			VV0->VV0_SNFFDI := ""
			if FieldPos("VV0_SDOCFD") > 0
				VV0->VV0_SDOCFD := ""
			EndIf
			If cFasePrx == "A" // Voltar o Atendimento para Aberto
				VV0->VV0_STATUS := "I" // Inicializado
				VV0->VV0_DATAPR := cTod("")
				VV0->VV0_USRAPR := ""
			ElseIf cFasePrx == "L" // Voltar Atendimento para Aprovado
				VV0->VV0_STATUS := "L" // Liberado
			Else // Cancelar Atendimento
				VV0->VV0_DATAPR := cTod("")
				VV0->VV0_USRAPR := ""
				VV0->VV0_SITNFI := "0" // Cancelada
				VV0->VV0_STATUS := "C" // Cancelado
			EndIf
		MsUnlock()

		If ExistBlock("VXI01DCA")
			If !ExecBlock("VXI01DCA",.f.,.f.,{VV9->VV9_NUMATE,cFasePrx})
				DisarmTransaction()
				Return()
			EndIf
		EndIf

		End Transaction

		If cFasePrx == "C" // Proxima Fase "C" - Cancelar
			//
			VXX030011_EMAIL(6,cObsMot) // Gerar EMAIL no 6-Atendimento Cancelado
			//
		EndIf

	EndIf

EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX030VVA º Autor ³ Andre Luis Almeida  º Data ³ 25/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Incluir / Editar / Excluir - VVA                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpcVVA - nOpc dos VVA ( veiculos )                        º±±
±±º          ³ nLinVet - Linha do Vetor dos VVA ( veiculos )              º±±
±±º          ³ cTitTela - Titulo da Tela de Manutencao do VVA             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX030VVA(nOpcVVA,nLinVet,cTitTela)
Local nCntFor := 0
Local lIncVVA := .f.
Local cCadBkp := cCadastro // Salvar Titulo Janela ( cCadastro )
Local aMV_PAR := {}
Local aParVVA := {}
Local aRetVVA := {}
Local aParDef := {}
Local aAux    := {}
Local lAlt    := .F. // Altera dados ?
Local lOkPar  := .F.
Private aMV_PARBkp := {"","",""} // { MV_PAR04 , MV_PAR05 , MV_PAR06 } - Backup dos MV_PAR ( Marca / Modelo / Cor )
If nOpcVVA == 3 .or. nOpcVVA == 4 // Incluir ou Alterar
	lAlt := .T. // Altera dados ?
EndIf
//
cCadastro := STR0001 // Faturamento Direto
//
//////////////////////
// SALVAR MV_PAR... //
//////////////////////
For nCntFor := 1 to nLenaCpo
	aAdd(aMV_PAR,&("MV_PAR"+strzero(nCntFor,2)))
Next
//
If nOpcVVA == 3 // Incluir VVA
	If len(aVVA) == 1 .and. Empty(Alltrim(aVVA[1,2]+aVVA[1,3]+aVVA[1,4]))
		nLinVet := 1
	Else
		lIncVVA := .t.
	EndIf
	aadd(aParDef,{ Space(TamSX3("VVA_CODMAR")[1]) , Space(TamSX3("VVA_MODVEI")[1]) , Space(TamSX3("VVA_CORVEI")[1]) , 0 , Space(TamSX3("VVA_CODPED")[1]) , Space(TamSX3("VVA_NUMPED")[1]) , Space(TamSX3("VVA_CHASSI")[1]) , 0 , array(len(aVVACust)) })
	For nCntFor := 1 to len(aVVACust)
		aParDef[1,9,nCntFor] := aVVACust[nCntFor,4]
	Next
Else
	aadd(aParDef,{ aVVA[nLinVet,2] , aVVA[nLinVet,3] , aVVA[nLinVet,4] , aVVA[nLinVet,5] , aVVA[nLinVet,6] , aVVA[nLinVet,7] , aVVA[nLinVet,8] , aVVA[nLinVet,12] , aClone(aVVA[nLinVet,23]) })
EndIf
//
aMV_PARBkp := { aParDef[1,1] , aParDef[1,2] , aParDef[1,3] } // Marca / Modelo / Cor
//
//////////////
// Parambox //
//////////////
If GetNewPar("MV_MIL0014","0") == "0" // Utiliza Central de Pedido? (0=Não;1=Sim)
	AADD(aParVVA,{1,STR0016,aParDef[1,5],"@!","VX030VVAVL(1,"+IIf(nOpcVVA==3,"0",Alltrim(str(nLinVet)))+")","VQ0",".f.", 60,.f.}) // Codigo Pedido
Else
	AADD(aParVVA,{1,STR0016,aParDef[1,5],"@!","VX030VVAVL(1,"+IIf(nOpcVVA==3,"0",Alltrim(str(nLinVet)))+")","VQ0",IIf(lAlt,"",".F."), 60,.f.}) // Codigo Pedido
EndIf
AADD(aParVVA,{1,STR0017,aParDef[1,6],"@!"              ,"VX030VVAVL(2,"+IIf(nOpcVVA==3,"0",Alltrim(str(nLinVet)))+")",""                   ,IIf(lAlt,"",".F.")             , 60,.f.}) // Numero Pedido
AADD(aParVVA,{1,STR0015,aParDef[1,7],"@!"              ,"VX030VVAVL(3,"+IIf(nOpcVVA==3,"0",Alltrim(str(nLinVet)))+")",IIf(lCadVei,"VV1",""),IIf(lAlt,"",".F.")             ,120,.f.}) // Chassi
AADD(aParVVA,{1,STR0010,aParDef[1,1],"@!"              ,"VX030VVAVL(4,"+IIf(nOpcVVA==3,"0",Alltrim(str(nLinVet)))+")","VE1"                ,IIf(lAlt.and.!lCadVei,"",".F."), 30,.t.}) // Marca
AADD(aParVVA,{1,STR0011,aParDef[1,2],"@!"              ,"VX030VVAVL(5,"+IIf(nOpcVVA==3,"0",Alltrim(str(nLinVet)))+")","VX3"                ,IIf(lAlt.and.!lCadVei,"",".F."),120,.t.}) // Modelo
AADD(aParVVA,{1,STR0012,aParDef[1,3],"@!"              ,"VX030VVAVL(6,"+IIf(nOpcVVA==3,"0",Alltrim(str(nLinVet)))+")","VVC"                ,IIf(lAlt.and.!lCadVei,"",".F."), 60,.t.}) // Cor
AADD(aParVVA,{1,STR0013,aParDef[1,4],"@E 99,999,999.99","VX030VVAVL(7,"+IIf(nOpcVVA==3,"0",Alltrim(str(nLinVet)))+")",""                   ,IIf(lAlt,"",".F.")             , 60,.t.}) // Valor
AADD(aParVVA,{1,STR0057,aParDef[1,8],"@E 99,999,999.99","VX030VVAVL(8,"+IIf(nOpcVVA==3,"0",Alltrim(str(nLinVet)))+")",""                   ,IIf(lAlt,"",".F.")             , 60,.f.}) // Vlr.Associacao
//
For nCntFor := 1 to len(aVVACust)
	AADD(aParVVA,{ 1 , RetTitle(aVVACust[nCntFor,1]) , aParDef[1,9,nCntFor] , VVA->(X3PICTURE(aVVACust[nCntFor,1])) , "VX030VVAVL("+Alltrim(str(8+nCntFor))+","+IIf(nOpcVVA==3,"0",Alltrim(str(nLinVet)))+")" , "" , IIf(lAlt,"",".F.") , aVVACust[nCntFor,2] , X3Obrigat(aVVACust[nCntFor,1]) })
Next
//
While .t.
	If ParamBox(aParVVA,cTitTela,@aRetVVA,,,,,,,,.f.)
		If !ExistBlock("VX030VLD") .or. ExecBlock("VX030VLD",.f.,.f.,{ "MV_PAR00" }) // Chamada do Ponto de Entrada para o Tudo OK na tela Parambox
			lOkPar := .t. 
			Exit
		EndIf
	Else
		Exit
	EndIf
	For nCntFor := 1 to len(aParVVA)
		aParVVA[nCntFor,3] := aRetVVA[nCntFor] // Carregar conteudos digitados pelo usuario
	Next
	aRetVVA := {}
EndDo
//
If lOkPar
	If nOpcVVA == 3 .or. nOpcVVA == 4 // Incluir ou Alterar VVA
		If lIncVVA
			VXX0300011_CriaVetorVVA()
			nLinVet := len(aVVA)
		EndIf
		aVVA[nLinVet,02] := aRetVVA[04] // Marca
		aVVA[nLinVet,03] := aRetVVA[05] // Modelo
		aVVA[nLinVet,04] := aRetVVA[06] // Cor
		aVVA[nLinVet,05] := aRetVVA[07] // Valor
		aVVA[nLinVet,06] := aRetVVA[01] // Codigo Pedido
		aVVA[nLinVet,07] := aRetVVA[02] // Numero Pedido
		aVVA[nLinVet,08] := aRetVVA[03] // Chassi
		aVVA[nLinVet,09] := ""
		If !Empty(aVVA[nLinVet,6]) // Pedido
			VQ0->(DbSetOrder(1))
			If VQ0->(MsSeek(xFilial("VQ0")+aVVA[nLinVet,6]))
				aVVA[nLinVet,09] := VQ0->VQ0_CHAINT
			EndIf
		ElseIf !Empty(aVVA[nLinVet,8]) // Chassi
			VV1->(DbSetOrder(2))
			If VV1->(MsSeek(xFilial("VV1")+aVVA[nLinVet,8]))
				aVVA[nLinVet,09] := VV1->VV1_CHAINT
				aVVA[nLinVet,19] := VV1->VV1_OPCFAB
			EndIf
			VV1->(DbSetOrder(1))
		EndIf
		VV2->(DbSetOrder(1))
		VV2->(MsSeek(xFilial("VV2")+aVVA[nLinVet,02]+aVVA[nLinVet,03]))
		aVVA[nLinVet,10] := VV2->VV2_DESMOD
		VVC->(DbSetOrder(1))
		VVC->(MsSeek(xFilial("VVC")+aVVA[nLinVet,02]+aVVA[nLinVet,04]))
		aVVA[nLinVet,11] := VVC->VVC_DESCRI
		aVVA[nLinVet,12] := aRetVVA[08] // Vlr.Associacao
		//
		For nCntFor := 1 to len(aVVACust)
			aVVA[nLinVet,23,nCntFor] := aRetVVA[08+nCntFor] // Campos do VVA customizados
		Next
		//
	ElseIf nOpcVVA == 5 // Excluir VVA
		aAux := aClone(aVVA)
		aVVA := {}
		For nCntFor := 1 to len(aAux)
			If nCntFor <> nLinVet
				aAdd(aVVA,aAux[nCntFor])
			Else
				If aAux[nCntFor,1] > 0
					aAdd(aDelVVA,aAux[nCntFor,1])
				EndIf
			EndIf
		Next
	EndIf
EndIf
If len(aVVA) <= 0
	VXX0300011_CriaVetorVVA()
EndIf
//
oLbVVA:nAt := 1
oLbVVA:SetArray(aVVA)
oLbVVA:Refresh()
//
FS_TOTALVVA(.t.)// Totaliza Veiculos ( VVA )
//
//////////////////////
// VOLTAR MV_PAR... //
//////////////////////
For nCntFor := 1 to nLenaCpo
	&("MV_PAR"+strzero(nCntFor,2)) := aMV_PAR[nCntFor]
Next
cCadastro := cCadBkp // Voltar Titulo Janela ( cCadastro )
//
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX030VVAVL º Autor ³ Andre Luis Almeida º Data ³ 28/10/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacoes na PARAMBOX - Incluir / Editar / Excluir - VVA  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nPar - Qual parametro validar da Parambox do VVA ?         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX030VVAVL(nPar,nLinhaVVA)
Local lRet      := .f.
Local nRecVQ0   := 0
Local aEUltMov  := {} // Entrada por Compra
Local aSUltMov  := {} // Saida por Venda
Local nCntFor   := 0
Local oVeiculos := DMS_Veiculo():New()

Do Case

	Case nPar == 1 // Codigo Pedido
		If Empty(MV_PAR01)
			lRet := .t.
		Else
			For nCntFor := 1 to len(aVVA)
				If nLinhaVVA == 0 .or. nLinhaVVA <> nCntFor
					If Alltrim(aVVA[nCntFor,6]) == Alltrim(MV_PAR01) // Codigo do Pedido
						MsgStop(STR0086,STR0002) // Veiculo ja existente neste Faturamento Direto. Impossivel continuar! / Atencao
						Return .f.
					EndIf
				EndIf
			Next
			DbSelectArea("VQ0")
			DbSetOrder(1)
			If MsSeek(xFilial("VQ0")+MV_PAR01)
				MV_PAR02 := VQ0->VQ0_NUMPED
				MV_PAR03 := VQ0->VQ0_CHASSI
				VV1->(DbSetOrder(1))
				VV1->(MsSeek(xFilial("VV1")+VQ0->VQ0_CHAINT))
				MV_PAR04 := aMV_PARBkp[1] := VV1->VV1_CODMAR
				MV_PAR05 := aMV_PARBkp[2] := VV1->VV1_MODVEI
				MV_PAR06 := aMV_PARBkp[3] := VV1->VV1_CORVEI
				lRet := .t.
			EndIf
		EndIf

	Case nPar == 2 // Numero Pedido
		If Empty(MV_PAR02)
			lRet := .t.
		Else
			nRecVQ0 := 0
			If !Empty(MV_PAR01)
				DbSelectArea("VQ0")
				DbSetOrder(1)
				If MsSeek(xFilial("VQ0")+MV_PAR01)
					nRecVQ0 := VQ0->(RecNo())
					If MV_PAR02 <> VQ0->VQ0_NUMPED
						nRecVQ0 := 0
						DbSelectArea("VQ0")
						DbSetOrder(2)
						If !Empty(MV_PAR02) .and. MsSeek(xFilial("VQ0")+MV_PAR02)
							nRecVQ0 := VQ0->(RecNo())
						EndIf
						DbSetOrder(1)
					EndIf
				EndIf
			EndIf
			If nRecVQ0 > 0
				VQ0->(DbGoTo(nRecVQ0))
				MV_PAR01 := VQ0->VQ0_CODIGO
				MV_PAR03 := VQ0->VQ0_CHASSI
				VV1->(DbSetOrder(1))
				VV1->(MsSeek(xFilial("VV1")+VQ0->VQ0_CHAINT))
				MV_PAR04 := aMV_PARBkp[1] := VV1->VV1_CODMAR
				MV_PAR05 := aMV_PARBkp[2] := VV1->VV1_MODVEI
				MV_PAR06 := aMV_PARBkp[3] := VV1->VV1_CORVEI
			Else
				MV_PAR01 := Space(TamSX3("VQ0_CODIGO")[1])
			EndIf
			lRet := .t.
		EndIf

	Case nPar == 3 // Chassi
		If Empty(MV_PAR03)
			lRet := .t.
		Else
			If lCadVei
				If !FG_POSVEI("MV_PAR03",)
					MsgStop(STR0056,STR0002) // Veiculo não encontrado. Impossivel continuar! / Atencao
					Return .f.
				EndIf
			EndIf
			lRet := .t.

			// Chassi Bloqueado
			If oVeiculos:Bloqueado("", MV_PAR03)
				Return .f. // A mensagem já é exibida dentro da função Bloqueado()
			EndIf

			For nCntFor := 1 to len(aVVA)
				If nLinhaVVA == 0 .or. nLinhaVVA <> nCntFor
					If Alltrim(aVVA[nCntFor,8]) == Alltrim(MV_PAR03) // Chassi
						MsgStop(STR0086,STR0002) // Veiculo ja existente neste Faturamento Direto. Impossivel continuar! / Atencao
						Return .f.
					EndIf
				EndIf
			Next

			DbSelectArea("VQ0")
			DbSetOrder(1)
			If !Empty(MV_PAR01) .and. MsSeek(xFilial("VQ0")+MV_PAR01)
				If MV_PAR03 <> VQ0->VQ0_CHASSI
					MV_PAR01 := Space(TamSX3("VVA_CODPED")[1])
				Else
					For nCntFor := 1 to len(aVVA)
						If nLinhaVVA == 0 .or. nLinhaVVA <> nCntFor
							If Alltrim(aVVA[nCntFor,6]) == Alltrim(MV_PAR01) // Codigo do Pedido
								MsgStop(STR0086,STR0002) // Veiculo ja existente neste Faturamento Direto. Impossivel continuar! / Atencao
								Return .f.
							EndIf
						EndIf
					Next
				EndIf
			EndIf

			DbSelectArea("VV1")
			DbSetOrder(2)
			If MsSeek(xFilial("VV1")+MV_PAR03)
				aEUltMov := FGX_VEIMOVS( VV1->VV1_CHASSI , "E" , "0" ) // Entrada por Compra
				aSUltMov := FGX_VEIMOVS( VV1->VV1_CHASSI , "S" , "0" ) // Saida por Venda
				If len(aEUltMov) > 0 .or. len(aSUltMov) > 1 .or. ( len(aSUltMov) == 1 .and. ( aSUltMov[1,2]+aSUltMov[1,3] <> xFilial("VV0")+VV0->VV0_NUMTRA ) )
					MsgStop(STR0054,STR0002) // Veiculo ja possui movimentação de Entrada e/ou Saida. Impossivel continuar! / Atencao
					Return .f.
				Else
					If ( Empty(MV_PAR04) .or. MV_PAR04 == VV1->VV1_CODMAR ) .and. ;
					   ( Empty(MV_PAR05) .or. MV_PAR05 == VV1->VV1_MODVEI ) .and. ;
					   ( Empty(MV_PAR06) .or. MV_PAR06 == VV1->VV1_CORVEI )
						If lCadVei .or. MsgYesNo(STR0022,STR0002) // Veiculo ja cadastrado! Deseja continuar? / Atencao
							lRet := .t.
							DbSelectArea("VQ0")
							DbSetOrder(3)
							If MsSeek(xFilial("VQ0")+VV1->VV1_CHAINT)
								If Alltrim(MV_PAR03) == Alltrim(VQ0->VQ0_CHASSI)
									MV_PAR01 := VQ0->VQ0_CODIGO
									MV_PAR02 := VQ0->VQ0_NUMPED
								EndIf
							EndIf
							DbSelectArea("VQ0")
							DbSetOrder(1)
						Else
							Return .f.
						EndIf
					ElseIf ( MV_PAR04 <> VV1->VV1_CODMAR ) .or. ( MV_PAR05 <> VV1->VV1_MODVEI ) .or. ( MV_PAR06 <> VV1->VV1_CORVEI )
						If MsgYesNo(STR0023,STR0002) // Veiculo ja cadastrado com MARCA/MODELO/COR diferente do informado! Deseja continuar? / Atencao
							lRet := .t.
							DbSelectArea("VQ0")
							DbSetOrder(3)
							If MsSeek(xFilial("VQ0")+VV1->VV1_CHAINT)
								If Alltrim(MV_PAR03) == Alltrim(VQ0->VQ0_CHASSI)
									MV_PAR01 := VQ0->VQ0_CODIGO
									MV_PAR02 := VQ0->VQ0_NUMPED
								EndIf
							EndIf
							DbSelectArea("VQ0")
							DbSetOrder(1)
						Else
							Return .f.
						EndIf
					EndIf

					If lRet
						MV_PAR04 := aMV_PARBkp[1] := VV1->VV1_CODMAR
						MV_PAR05 := aMV_PARBkp[2] := VV1->VV1_MODVEI
						MV_PAR06 := aMV_PARBkp[3] := VV1->VV1_CORVEI
					EndIf
				EndIf
			Else
				lRet := .t.
			EndIf

			DbSelectArea("VV1")
			DbSetOrder(1)
		EndIf

	Case nPar == 4 // Marca
		DbSelectArea("VE1")
		DbSetOrder(1)
		If !Empty(MV_PAR04) .and. DbSeek(xFilial("VE1")+MV_PAR04)
			lRet := .t.
		EndIf
		If Empty(MV_PAR04) .or. ( lRet .and. MV_PAR04 <> aMV_PARBkp[1] )
			lRet := .t.
			MV_PAR01 := Space(TamSX3("VVA_CODPED")[1])
			MV_PAR02 := Space(TamSX3("VVA_NUMPED")[1])
			MV_PAR03 := Space(TamSX3("VVA_CHASSI")[1])
			MV_PAR05 := Space(TamSX3("VVA_MODVEI")[1])
			MV_PAR06 := Space(TamSX3("VVA_CORVEI")[1])
		EndIf
		If lRet
			aMV_PARBkp[1] := MV_PAR04
		EndIf

	Case nPar == 5 // Modelo
		DbSelectArea("VV2")
		DbSetOrder(1)
		If !Empty(MV_PAR05) .and. DbSeek(xFilial("VV2")+MV_PAR04+MV_PAR05)
			lRet := .t.
		EndIf
		If Empty(MV_PAR05) .or. ( lRet .and. MV_PAR05 <> aMV_PARBkp[2] )
			lRet := .t.
			MV_PAR01 := Space(TamSX3("VVA_CODPED")[1])
			MV_PAR02 := Space(TamSX3("VVA_NUMPED")[1])
			MV_PAR03 := Space(TamSX3("VVA_CHASSI")[1])
		EndIf
		If lRet
			aMV_PARBkp[2] := MV_PAR05
			If MV_PAR07 <= 0 .and. !Empty(MV_PAR05)
				MV_PAR07 := FS_VLRVEI(MV_PAR06) // Carregar Valor do Veiculo
		 	EndIf
		EndIf

	Case nPar == 6 // Cor
		DbSelectArea("VVC")
		DbSetOrder(1)
		If !Empty(MV_PAR06) .and. DbSeek(xFilial("VVC")+MV_PAR04+MV_PAR06)
			lRet := .t.
		EndIf
		If Empty(MV_PAR06) .or. ( lRet .and. MV_PAR06 <> aMV_PARBkp[3] )
			lRet := .t.
			MV_PAR01 := Space(TamSX3("VVA_CODPED")[1])
			MV_PAR02 := Space(TamSX3("VVA_NUMPED")[1])
			MV_PAR03 := Space(TamSX3("VVA_CHASSI")[1])
		EndIf
		If lRet
			aMV_PARBkp[3] := MV_PAR06
			If MV_PAR07 <= 0 .and. !Empty(MV_PAR06)
				DbSelectArea("VV2")
				DbSetOrder(1)
				If !Empty(MV_PAR05) .and. DbSeek(xFilial("VV2")+MV_PAR04+MV_PAR05)
					MV_PAR07 := FS_VLRVEI(MV_PAR06) // Carregar Valor do Veiculo
				EndIf
			EndIf
		EndIf

	Case nPar == 7 // Valor
		If MV_PAR07 >= 0
			lRet := .t.
		EndIf

	Case nPar == 8 // Vlr.Associacao
		If MV_PAR08 >= 0
			lRet := .t.
		EndIf

	OtherWise
		lRet := .t.

EndCase

If lRet .and. ExistBlock("VX030VLD")
	lRet := ExecBlock("VX030VLD",.f.,.f.,{ "MV_PAR"+strzero(nPar,2) })
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_TOTALVVAº Autor ³ Andre Luis Almeida º Data ³ 30/10/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Totalizador dos Veiculos ( soma VVA )                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ lRefresh - Refresh no TOTAL do VVA ?                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function	FS_TOTALVVA(lRefresh)
Local nCntFor := 0
aMinCom := {}
nVVATot := 0
For nCntFor := 1 to len(aVVA)
	nVVATot += aVVA[nCntFor,5]
	If !Empty(aVVA[nCntFor,9]) // Possui VVA_CHAINT
		VV2->(dbSetOrder(1))
		VV2->(dbSeek(xFilial("VV2")+aVVA[nCntFor,2]+aVVA[nCntFor,3]))
		aAdd(aMinCom,{aVVA[nCntFor,9],aVVA[nCntFor,2],aVVA[nCntFor,3],VV2->VV2_SEGMOD,aVVA[nCntFor,4],aVVA[nCntFor,5],0,0,0,0})
	EndIf
Next
If lRefresh
	oVVATot:Refresh()
	VX030MAPAV()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_VLRVEI  º Autor ³ Andre Luis Almeida º Data ³ 29/10/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Carregar Valor para o Veiculo                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function	FS_VLRVEI(cCor)
Local aComboT   := {} // Texto do Combo
Local aComboV   := {} // Valor do Combo
Local nValor    := 0
Local cQuery    := ""
Local cSQLAlias := "SQLALIAS"
Local aRetVlr   := {}
Local aParamBox := {}
Local BKP_PAR01 := MV_PAR01 // Salva o MV_PAR01
If VV2->VV2_UTIPVD <> "0" // Utiliza Percentual de Venda Direta ( Faturamento Direto )
	cQuery := "SELECT SX5.X5_DESCRI , VZP.VZP_VALVEN , VZP.VZP_DESCON , VZP.VZP_TIPO , VZP.VZP_SEQUEN "
	cQuery += "FROM "+RetSQLName("VZP")+" VZP "
	cQuery += "JOIN "+RetSQLName("SX5")+" SX5 ON ( SX5.X5_FILIAL='"+xFilial("SX5")+"' AND SX5.X5_TABELA='77' AND SX5.X5_CHAVE=VZP.VZP_TIPO AND SX5.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VZP.VZP_FILIAL='"+xFilial("VZP")+"' AND "
	cQuery += "VZP.VZP_CODMAR='"+VV2->VV2_CODMAR+"' AND VZP.VZP_MODVEI='"+VV2->VV2_MODVEI+"' AND VZP.VZP_SEGMOD='"+VV2->VV2_SEGMOD+"' AND VZP.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F., .T. )
	While !( cSQLAlias )->( Eof() )
		nValor := ( cSQLAlias )->( VZP_VALVEN )-(( cSQLAlias )->( VZP_VALVEN )*(( cSQLAlias )->( VZP_DESCON )/100))
		aAdd(aComboT,FG_AlinVlrs(left(( cSQLAlias )->( X5_DESCRI ),15),"E")+FG_AlinVlrs(Transform(nValor,"@E 99,999,999.99")))
		aAdd(aComboV,nValor)
		( cSQLAlias )->( DbSkip() )
	EndDo	
	( cSQLAlias )->( DbCloseArea() )
	nValor := 0
	If len(aComboT) == 1
		nValor := aComboV[1]
	ElseIf len(aComboT) > 1 // Selecionar Tipo de Faturamento Direto
		aAdd(aParamBox,{3,FG_AlinVlrs(left(STR0001+space(22),22),"E")+FG_AlinVlrs(left(STR0013+space(13),13)),1,aComboT,180,"",.F.}) // Faturamento Direto / Valor
		If ParamBox(aParamBox,STR0001,@aRetVlr,,,,,,,,.f.) // Faturamento Direto
			nValor := aComboV[aRetVlr[1]]
		EndIf
	Else
		MsgAlert(STR0021,STR0002) // Valor de Venda para Faturamento Direto nao informado no Cadastro de Modelos. / Atencao
	EndIf
Else // Nao utiliza Percentuais de Venda Direta ( Faturamento Direto )
	If !Empty(cCor)
		nValor := FGX_VLRSUGV( "" , VV2->VV2_CODMAR , VV2->VV2_MODVEI , VV2->VV2_SEGMOD , cCor , .t. , cCdCliAt , cLjCliAt )
	EndIf
EndIf
MV_PAR01 := BKP_PAR01 // Volta o MV_PAR01
Return(nValor)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX030FOTO º Autor ³ Andre Luis Almeira º Data ³ 30/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exibe Fotos/Videos de um veículo                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpc - nOpc da Rotina                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX030FOTO(nOpc)

SetKey(VK_F4, Nil )
SetKey(VK_F10, Nil )
//
VEIXC003(aVVA[oLbVVA:nAt,9],aVVA[oLbVVA:nAt,2],aVVA[oLbVVA:nAt,3])
//
SetKey(VK_F4,{|| VX030FOTO(nOpc) })
SetKey(VK_F10,{|| VX030OPCOES(nOpc) })

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |VX030OPCOESºAutor³ Andre Luis Almeida  º Data ³  30/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Montagem do menu de opcoes                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpc - nOpc da Rotina                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX030OPCOES(nOpc)
Local nQtdeBot1, nQtdeBot2, nQtdeBot3, nQtdeBot4, nQtdeSep, nLinha, nDist, nLargura, nAltura, nBloco, nColuna
Local cVeiculo   := ""
Local lImprAtend := ExistBlock("ATENDVEI")   // Impressao do Atendimento do Veiculo ( Proposta )
Local lMapaAprov := .f.
Local lBonusVeic := .f.
Local lBotOut    := .f.
Local aBotOut    := {}
Local ni         := 0

VAI->(dbSetOrder(4))
VAI->(MsSeek(xFilial("VAI")+__cUserID))
If VAI->VAI_APROVA $ "1/2/3" // 1=Pre-Aprova / 2=Aprova / 3=Aprovacao Previa
	lMapaAprov := .t.
EndIf
If VAI->VAI_DESREC <> "2" // Despesa/Receita - Visualiza
	lDesRecVei := .t.
EndIf
If VAI->(FieldPos("VAI_BONUSV")) > 0
	If VAI->VAI_BONUSV <> "2" // Bonus - Visualiza
		lBonusVeic := .t.
	EndIf
Else
	If VAI->VAI_TIPTEC <= "3"  // 1=Diretor;2=Gerente;3=Supervisor
		lBonusVeic := .t.
	EndIf
EndIf

If ExistBlock("VX030F10")
	lBotOut := .t.
	aBotOut := ExecBlock("VX030F10",.f.,.f.,{nOpc})
EndIf

If !Empty(aVVA[oLbVVA:nAt,8])
	cVeiculo += Alltrim(aVVA[oLbVVA:nAt,8])+" - "
EndIf
VV2->(DbSetOrder(1))
VV2->(DbSeek(xFilial("VV2")+aVVA[oLbVVA:nAt,2]+aVVA[oLbVVA:nAt,3]))
cVeiculo += Alltrim(VV2->VV2_CODMAR)+" "+Alltrim(VV2->VV2_DESMOD)

/////////////////////////////////////////////////////////
nQtdeSep  :=   0 // Qtde de Separacoes entre os blocos //
nQtdeBot1 :=   1 // Qtde de Botoes na altura (bloco 1) //
nQtdeSep++	     // separa 1                           //
nQtdeBot2 :=   4 // Qtde de Botoes na altura (bloco 2) //
nQtdeSep++	     // separa 2                           //
nQtdeBot3 :=   3 // Qtde de Botoes na altura (bloco 3) //
nQtdeBot4 :=   0 // Qtde de Botoes na altura (bloco 4) //
If lBotOut .and. len(aBotOut) > 0                      //
	nQtdeSep++   // separa 3                           //
	nQtdeBot4 := int(( len(aBotOut) / 3 )) + 1        //
EndIf                                                  //
/////////////////////////////////////////////////////////
nDist     :=   2 // Distancia entre os botoes          //
nAltura   :=  12 // Altura de cada botao               //
nBloco    :=  10 // Distancia entre os blocos          //
nLinha    :=   2 // Linha atual para criar o botao     //
nColuna   :=   3 // Coluna para criar o botao          //
nLargura  := 118 // Largura de cada botao              //
/////////////////////////////////////////////////////////

SetKey(VK_F4,{|| Nil })
SetKey(VK_F10,{|| Nil })

DEFINE MSDIALOG oDlgOpcoes TITLE (STR0027+" - <F10>") From 0,0 TO ( ( nQtdeBot1 + nQtdeBot2 + nQtdeBot3 + nQtdeBot4 + nQtdeSep ) * (nDist+nAltura) * 2 )+2,( ( ( nLargura * 3 ) + 9 ) * 2 )+1 of oDlgFatDir PIXEL // Opcoes
oDlgOpcoes:lEscClose := .T.

nLinha += ( nBloco / 1.2 )
nLinha -= 3
//////////////////
// Cliente      //
//////////////////
@ nLinha-( nBloco / 1.4 ),001 TO nLinha+((( nAltura + nDist ) * nQtdeBot1 )+(nBloco/7)),( ( nLargura * 3 ) + 11 ) LABEL STR0028 OF oDlgOpcoes PIXEL // Cliente
nLinha++
tButton():New(nLinha,nColuna,STR0028,oDlgOpcoes, { || VX030BOTOPC(01,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || !Empty(MV_PAR02+MV_PAR03)  })		// Cliente
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0029,oDlgOpcoes, { || VX030BOTOPC(02,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || !Empty(MV_PAR02+MV_PAR03)  })		// Veiculos do Cliente
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0030,oDlgOpcoes, { || VX030BOTOPC(03,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || .t.  })		// Registro de Abordagem/Reclamacao

nLinha += nAltura + nDist + ( nBloco / 1.2 )
nColuna := 3
//////////////////
// Veiculo      //
//////////////////
@ nLinha-( nBloco / 1.4 ),001 TO nLinha+((( nAltura + nDist ) * nQtdeBot2 )+(nBloco/7)),( ( nLargura * 3 ) + 11 ) LABEL (STR0034+" "+cVeiculo) OF oDlgOpcoes PIXEL 					// Veiculo
nLinha++
tButton():New(nLinha,nColuna,STR0035,oDlgOpcoes, { || VX030BOTOPC(04,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || !Empty(aVVA[oLbVVA:nAt,8])  })	   								// Rastreamento do Veiculo
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0036,oDlgOpcoes, { || VX030BOTOPC(05,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || !Empty(aVVA[oLbVVA:nAt,9])  })					   				// Visualiza Cadastro do Veiculo
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0026,oDlgOpcoes, { || VX030FOTO(nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || !Empty(aVVA[oLbVVA:nAt,9]+aVVA[oLbVVA:nAt,2]+aVVA[oLbVVA:nAt,3]) })	// Foto(s)/Video(s) do Veiculo
nLinha += nAltura + nDist
nColuna := 3
tButton():New(nLinha,nColuna,STR0073,oDlgOpcoes, { || VX030BOTOPC(15,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || !Empty(aVVA[oLbVVA:nAt,9])  })									// Opcionais do Veiculo
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0072,oDlgOpcoes, { || VX030BOTOPC(14,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || !Empty(aVVA[oLbVVA:nAt,9]) .and. lBonusVeic })					// Bonus de Veiculo
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0058,oDlgOpcoes, { || VX030BOTOPC(08,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || !Empty(aVVA[oLbVVA:nAt,9]) .and. lDesRecVei })					// Despesas/Receitas com o Veiculo
nLinha += nAltura + nDist
nColuna := 3
tButton():New(nLinha,nColuna,STR0059,oDlgOpcoes, { || VX030BOTOPC(09,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || !Empty(aVVA[oLbVVA:nAt,9]) })									// Custo com Vendas
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0063,oDlgOpcoes, { || VX030BOTOPC(10,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || !Empty(aVVA[oLbVVA:nAt,9]) })									// Previsao de Faturamento/Entrega
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0074,oDlgOpcoes, { || VX030BOTOPC(16,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || !Empty(aVVA[oLbVVA:nAt,9])  })									// Configuracao de veiculos
nLinha += nAltura + nDist
nColuna := 3
tButton():New(nLinha,nColuna,STR0071,oDlgOpcoes, { || VX030BOTOPC(12,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || !Empty(aVVA[oLbVVA:nAt,9]) })										// Banco de Conhecimento do Veiculo

nLinha += nAltura + nDist + ( nBloco / 1.2 )
nColuna := 3
//////////////////
// Atendimento  //
//////////////////
@ nLinha-( nBloco / 1.4 ),001 TO nLinha+((( nAltura + nDist ) * nQtdeBot3 )+(nBloco/7)),( ( nLargura * 3 ) + 11 ) LABEL STR0031 OF oDlgOpcoes PIXEL		// Atendimento
nLinha++
tButton():New(nLinha,nColuna,STR0055,oDlgOpcoes, { || VX030BOTOPC(06,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || !Empty(MV_PAR01) })					// Solicitar Tarefas para o Atendimento
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0005,oDlgOpcoes, { || VX030BOTOPC(07,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || !Empty(MV_PAR01) })					// Visualizar Tarefas do Atendimento
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0033,oDlgOpcoes, { || FM_OBSMEM(STR0033,VV0->VV0_OBSMEM,"VV0_OBSMEM","VV0_OBSERV",.f.,.t.) } , nLargura , nAltura ,,,,.T.,,,,{ || !Empty(MV_PAR01) })	// Historico de Manutencao do Atendimento
nLinha += nAltura + nDist
nColuna := 3
tButton():New(nLinha,nColuna,STR0075,oDlgOpcoes, { || VX030BOTOPC(17,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || .t.  })								// Valor do Minimo Comercial de Venda
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0068,oDlgOpcoes, { || VX030BOTOPC(11,nOpc) } , nLargura , nAltura ,,,,.T.,,,,{ || lMapaAprov })							// Mapa de Avaliacao - Aprovacao
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0069,oDlgOpcoes, { || ExecBlock("ATENDVEI",.f.,.f.,{ VV9->VV9_FILIAL , VV9->VV9_NUMATE }) } , nLargura , nAltura ,,,,.T.,,,,{ || lImprAtend }) // Impressao do Atendimento ( Proposta )
nLinha += nAltura + nDist
nColuna := 3
tButton():New(nLinha,nColuna,STR0070,oDlgOpcoes, { || VX030BOTOPC(13,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || .t. })	// Banco de Conhecimento do Atendimento

//////////////////
// Customizados //
//////////////////
If lBotOut
	nLinha += nAltura + nDist + ( nBloco / 1.2 )
	nColuna := 3
	// Outros
	@ nLinha-( nBloco / 1.4 ),001 TO nLinha+((( nAltura + nDist ) * nQtdeBot4 )+(nBloco/7)),( ( nLargura * 3 ) + 11 ) LABEL STR0062 OF oDlgOpcoes PIXEL // Outros
	nLinha++
	For ni := 1 to len(aBotOut)
		tButton():New(nLinha,nColuna,aBotOut[ni,1],oDlgOpcoes, &("{ || "+aBotOut[ni,2]+" }") , nLargura , nAltura ,,,,.T.,,,,{ || .t.  })
		nColuna += nLargura + 003
		If int( ni / 3 ) == ( ni / 3 )
			nLinha += nAltura + nDist
			nColuna := 3
		EndIf
	Next
EndIf

ACTIVATE MSDIALOG oDlgOpcoes CENTER

SetKey(VK_F4,{|| VX030FOTO(nOpc) })
SetKey(VK_F10,{|| VX030OPCOES(nOpc) })

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX030BOTOPCºAutor³ Andre Luis Almeida  º Data ³  30/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Clique no Menu de Opcoes da Tela                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nBot - nro do Botao que foi clickado pelo usuario          º±±
±±º          ³ nOpc - nOpc da Rotina                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX030BOTOPC(nBot,nOpc)
Local aMV_PAR := {}
Local cCadBkp := cCadastro // Salvar Titulo Janela ( cCadastro )
Local nCntFor := 0
Local nSlvOpc := nOpc
If VV9->VV9_STATUS $ "POLFC"
	nOpc := 2
EndIf

//////////////////////
// SALVAR MV_PAR... //
//////////////////////
For nCntFor := 1 to nLenaCpo
	aAdd(aMV_PAR,&("MV_PAR"+strzero(nCntFor,2)))
Next

Do Case
	
	Case nBot == 1 // Cliente
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+MV_PAR02+MV_PAR03))
		FC010CON() // Tela de Consulta -> Posicao do Cliente

	Case nBot == 2 // Veiculos do Cliente
		VEIVC090(MV_PAR02,MV_PAR03,.t.)
		
	Case nBot == 3 // Registro de Abordagem/Reclamacao
		ML500A()

	Case nBot == 4 // Rastreamento do Veiculo
		If !FM_PILHA("VEIVC140")
			VEIVC140(aVVA[oLbVVA:nAt,8], aVVA[oLbVVA:nAt,9])
		EndIf
	Case nBot == 5 // Visualiza Cadastro do Veiculo
		VX002VV1(aVVA[oLbVVA:nAt,9])

	Case nBot == 6 // Solicitar Tarefas para o Atendimento
		If nOpc == 3 .or. nOpc == 4 // Incluir / Alterar
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Solicitar TAREFAS                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			VEIVM130TAR(MV_PAR01,"3","2",VV9->VV9_FILIAL) // Tarefas: 3-Solicitado pelo Usuario / 2-Faturamento Direto
		Else
			MsgStop(STR0055+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0038,STR0002) // Solicitar Tarefas para o Atendimento / Opcao disponivel apenas na Inclusao ou Alteracao do Atendimento! / Atencao
		EndIf

	Case nBot == 7 // Visualizar Tarefas do Atendimento
		If !FM_PILHA("VEIVM130")
			VEIVM130(MV_PAR01,VV9->VV9_FILIAL)
		EndIf

	Case nBot == 8 // Despesas/Receitas do Veiculo
		dbSelectArea("VV1")
		dbSetOrder(1)
		dbSeek(xFilial("VV1")+aVVA[oLbVVA:nAt,9])
		If !Empty(aVVA[oLbVVA:nAt,9])
			If !Empty( VV1->VV1_FILENT + VV1->VV1_TRACPA )
				If nOpc <> 3 .and. nOpc <> 4 // Diferente de Incluir e Alterar
					nOpc := 2
				EndIf        
				VEIVM040(nOpc,aVVA[oLbVVA:nAt,9],aVVA[oLbVVA:nAt,20],aVVA[oLbVVA:nAt,21],aVVA[oLbVVA:nAt,22])
				nOpc := nSlvOpc
			Else
				MsgStop(STR0058+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0076,STR0002) // Despesas/Receitas com o Veiculo / Veiculo não possui movimentação de entrada! / Atencao
			EndIf
		Else
			MsgStop(STR0058+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0060,STR0002) // Despesas/Receitas com o Veiculo / Favor selecionar um Veiculo! / Atencao
		EndIf

	Case nBot == 9 // Custo FIXO com Vendas
		If !Empty(MV_PAR01) .and. !Empty(aVVA[oLbVVA:nAt,9]) .and. aVVA[oLbVVA:nAt,1] > 0
			VVA->(DbGoTo(aVVA[oLbVVA:nAt,1]))
			VEIXX017( MV_PAR01 , nOpc , .t. , 0 , aVVA[oLbVVA:nAt,9] , VVA->VVA_ITETRA )
		Else
			MsgStop(STR0059+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0061,STR0002) // Custo com Vendas / Favor selecionar um Veículo e salvar o Atendimento! / Atencao
		EndIf

	Case nBot == 10 // Previsao de Faturamento/Entrega
		If !Empty(MV_PAR01) .and. aVVA[oLbVVA:nAt,1] > 0
			nOpc := nSlvOpc
			aVVA := VXX006FD( nOpc , aVVA , oLbVVA:nAt )
		Else
			MsgStop(STR0063+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0061,STR0002) // Previsao de Faturamento/Entrega / Favor selecionar um Veículo e salvar o Atendimento! / Atencao
		EndIf

	Case nBot == 11 // Mapa de Avaliacao - Aprovacao
		If !Empty(MV_PAR01)
			VEIXX013(MV_PAR01,0)
		Else
			MsgStop(STR0068+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0061,STR0002) // Mapa de Avaliacao - Aprovacao / Favor selecionar um Veículo e salvar o Atendimento! / Atencao
		EndIf

	Case nBot == 12 // Banco de Conhecimento do Veiculo
		If !Empty(aVVA[oLbVVA:nAt,9]) 
			dbSelectArea("VV1")
			dbSetOrder(1)
			dbSeek(xFilial("VV1")+aVVA[oLbVVA:nAt,9])
			nReg := VV1->(RecNo())
			FGX_MSDOC("VV1",nReg,4)
		Else
			MsgStop(STR0071+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0061,STR0002) // Banco de Conhecimento do Veiculo / Favor selecionar um Veículo e salvar o Atendimento! / Atencao
		EndIf

	Case nBot == 13 // Banco de Conhecimento do Atendimento
		If !Empty(MV_PAR01)
			nReg := VV0->(RecNo())
			FGX_MSDOC("VV0",nReg,4)
		Else
			MsgStop(STR0070+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0061,STR0002) // Banco de Conhecimento do Atendimento / Favor selecionar um Veículo e salvar o Atendimento! / Atencao
		EndIf

	Case nBot == 14 // Bonus de Veiculos
		If !Empty(MV_PAR01) .and. aVVA[oLbVVA:nAt,1] > 0
			If VV9->VV9_STATUS $ "PO"
				nOpc := nSlvOpc
			EndIf
			VV2->(dbSetOrder(1))
			VV2->(dbSeek(xFilial("VV2")+aVVA[oLbVVA:nAt,2]+aVVA[oLbVVA:nAt,3]))
			VEIXX014( MV_PAR01 , aVVA[oLbVVA:nAt,2] , VV2->VV2_GRUMOD , aVVA[oLbVVA:nAt,3] , nOpc , .T. , "2" , aVVA[oLbVVA:nAt,1] )
		Else
			MsgStop(STR0072+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0061,STR0002) // Bonus de Veiculo / Favor selecionar um Veículo e salvar o Atendimento! / Atencao
		EndIf

	Case nBot == 15 // Opcionais do Veiculo
		If !Empty(aVVA[oLbVVA:nAt,9]) .or. !Empty(aVVA[oLbVVA:nAt,3]) // Verifica se ja tem um Chaint ou Modelo do veiculo ...
			aParOpc := {"","",""}
			aParOpc[01] := aVVA[oLbVVA:nAt,9]	// Chassi Interno (CHAINT)
			aParOpc[02] := aVVA[oLbVVA:nAt,2]	// Marca do Veiculo
			aParOpc[03] := aVVA[oLbVVA:nAt,3]	// Modelo do Veiculo
			VEIXC005(@aParOpc,aVVA[oLbVVA:nAt,19])
		Else
			MsgStop(STR0073+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0061,STR0002) // Opcionais do Veiculo / Favor selecionar um Veículo e salvar o Atendimento! / Atencao
		EndIf

	Case nBot == 16 // Configuração
		If !Empty(aVVA[oLbVVA:nAt,9])
			VA380CFGVEI(aVVA[oLbVVA:nAt,9])
		Else
			MsgStop(STR0074+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0061,STR0002) // Configuração // Favor selecionar Veículo e salvar o Atendimento!/ Atencao
		EndIf

	Case nBot == 17 // Valor do Minimo Comercial de Venda
		If !VEIXX007(1,@aMinCom)
			MsgStop(STR0075+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0061,STR0002) // Valor do Minimo Comercial de Venda / Favor selecionar um Veículo e salvar o Atendimento! / Atencao
		EndIf


EndCase
nOpc := nSlvOpc

//////////////////////
// VOLTAR MV_PAR... //
//////////////////////
For nCntFor := 1 to nLenaCpo
	&("MV_PAR"+strzero(nCntFor,2)) := aMV_PAR[nCntFor]
Next
cCadastro := cCadBkp // Voltar Titulo Janela ( cCadastro )

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX030MAPAV º Autor ³ Andre Luis Almeida º Data ³ 09/03/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Roda Mapa de Avaliacao e Atualiza o Semaforo do atendimentoº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX030MAPAV()
Local aRetMapa := {0,0,{}}
Local nCntFor  := 0
Local nAuxPos  := 0
//
aRetMapa[1] := 2
If VV9->VV9_NUMATE == M->VV9_NUMATE // Atendimento Salvo
	aRetMapa := FM_MAPAVAL(1,,VV9->VV9_NUMATE,.f.,0,,)
EndIf
//
oMapaBom:lVisible := ( aRetMapa[1] ==  1 ) // Bom
oMapaMed:lVisible := ( aRetMapa[1] ==  0 ) // Medio
oMapaRui:lVisible := ( aRetMapa[1] == -1 ) // Ruim
//
If len(aMinCom) > 0
	For nCntFor := 1 to Len(aRetMapa[3])
		VVA->(DbGoTo(aRetMapa[3,nCntFor,1]))
		nAuxPos := aScan(aMinCom, {|x| x[1] == VVA->VVA_CHAINT } )
	    If nAuxPos > 0
		    aMinCom[nAuxPos,9] := aRetMapa[3,nCntFor,2] // % de Resultado
		EndIf
	Next
EndIf
//
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX030GRVOPOº Autor ³ Andre Luis Almeida º Data ³ 10/06/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gravar Filial e Nro do Atendimento no Interesse do Cliente º±±
±±º          ³ na Oportunidade de Negocio                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX030GRVOPO(aRecInter,aIteTra)
Local nCntFor     := 0
Local aObjects    := {} , aPos := {} , aInfo := {} 
Local aSizeHalf   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cFasFim     := ""
Local nQtdFas     := 0
Local nOpcao      := 0
Local cQuery      := ""
Local cQAlias     := "SQLALIAS"
Local lVAI_VABAON := ( VAI->(FieldPos("VAI_VABAON")) > 0 )
Local lVDM_OPCFAB := ( VDM->(FieldPos("VDM_OPCFAB")) > 0 )
Local lVDM_ITETRA := ( VDM->(FieldPos("VDM_ITETRA")) > 0 )
Private aVerOport := {}
Private oOkTik    := LoadBitmap( GetResources() , "LBTIK" )
Private oNoTik    := LoadBitmap( GetResources() , "LBNO" )
// Fator de reducao 80%
For nCntFor := 1 to Len(aSizeHalf)
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.8)
Next   
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0,  0, .T. , .T. } ) // Interesses
aPos := MsObjSize( aInfo, aObjects )
VAI->(DbSetOrder(4))
VAI->(DbSeek(xFilial("VAI")+__cUserID))
cQuery := "SELECT DISTINCT VDK.VDK_CODFAS FROM "+RetSqlName("VDK")+" VDK WHERE VDK.VDK_FILIAL='"+xFilial("VDK")+"' AND VDK.VDK_FIMFAS='1' AND VDK.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
Do While !( cQAlias )->( Eof() )
	cFasFim += "'"+( cQAlias )->( VDK_CODFAS )+"',"
	nQtdFas++
	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )
If !Empty(cFasFim)
	cFasFim := left(cFasFim,len(cFasFim)-1)
	cQuery := "SELECT VDM.R_E_C_N_O_ AS RECVDM , VDM.VDM_CAMPOP , VDM.VDM_CODMAR , VDM.VDM_MODVEI , VDM.VDM_CORVEI , VDM.VDM_QTDINT , VDM.VDM_DATINT , VDM.VDM_DATLIM "
	If lVDM_OPCFAB
		cQuery += ", VDM.VDM_OPCFAB "
	EndIf
	If lVDM_ITETRA
		cQuery += ", VDM.VDM_ITETRA "
	EndIf
	cQuery += "FROM "+RetSqlName("VDM")+" VDM "
	cQuery += "JOIN "+RetSqlName("VDL")+" VDL ON ( VDL.VDL_FILIAL=VDM.VDM_FILIAL AND VDL.VDL_CODOPO=VDM.VDM_CODOPO AND VDL.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VDM.VDM_FILIAL='"+xFilial("VDM")+"' AND "
	cQuery += "VDL.VDL_CODCLI='"+VV9->VV9_CODCLI+"' AND "
	cQuery += "VDL.VDL_LOJCLI='"+VV9->VV9_LOJA+"' AND "
	If nQtdFas == 1
		cQuery += "VDM.VDM_CODFAS="+cFasFim+" AND "
	Else
		cQuery += "VDM.VDM_CODFAS IN ("+cFasFim+") AND "
	EndIf
	cQuery += "VDM.VDM_MOTCAN=' ' AND "
	cQuery += "( ( VDM.VDM_FILATE=' ' AND VDM.VDM_NUMATE=' ' ) OR ( VDM.VDM_FILATE='"+VV9->VV9_FILIAL+"' AND VDM.VDM_NUMATE='"+VV9->VV9_NUMATE+"' ) ) AND "
	If lVAI_VABAON
		If VAI->VAI_VABAON == "1" // 1=Somente do Vendedor
			cQuery += "VDM.VDM_CODVEN='"+VAI->VAI_CODVEN+"' AND "
		EndIf
	Else
		cQuery += "( VDM.VDM_CODVEN=' ' OR VDM.VDM_CODVEN='"+VAI->VAI_CODVEN+"' ) AND "
	EndIf
	cQuery += "VDM.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	Do While !( cQAlias )->( Eof() )
		aAdd(aVerOport,{ ( aScan(aRecInter,( cQAlias )->( RECVDM )) > 0 ) ,;
						( cQAlias )->( VDM_CAMPOP ) , ( cQAlias )->( VDM_CODMAR ) , ( cQAlias )->( VDM_MODVEI ) , ( cQAlias )->( VDM_CORVEI ) ,;
						( cQAlias )->( VDM_QTDINT ) , stod(( cQAlias )->( VDM_DATINT )) , stod(( cQAlias )->( VDM_DATLIM )) , ;
						( cQAlias )->( RECVDM ) , IIf(lVDM_OPCFAB,( cQAlias )->( VDM_OPCFAB ),"") , IIf(lVDM_ITETRA,( cQAlias )->( VDM_ITETRA ),"") })
		If aVerOport[len(aVerOport),1] .and. Empty(aVerOport[len(aVerOport),11]) .and. len(aItetra) > 0
			For nCntFor := 1 to len(aIteTra) // Achar a posicao do ITETRA
				If ( Alltrim(( cQAlias )->( VDM_CODMAR ))+" "+Alltrim(( cQAlias )->( VDM_MODVEI ))+" "+Alltrim(( cQAlias )->( VDM_CORVEI ))) $ aIteTra[nCntFor]
					Exit
				EndIf
			Next			
			If nCntFor <= 0 .or. nCntFor > len(aIteTra)
				nCntFor := 1 // Caso nao encontre... utrilizar 1a. posicao 
			EndIf
			aVerOport[len(aVerOport),11] := left(aIteTra[nCntFor],TamSX3("VVA_ITETRA")[1])
		EndIf
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
EndIf
DbSelectArea("VV9")
If len(aVerOport) <= 0
	Return()
EndIf
DEFINE MSDIALOG oTelaOpo TITLE STR0079 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Selecione quais interesses do Cliente foram atendidos neste Atendimento.
	oTelaOpo:lEscClose := .F.
	@ aPos[1,1],aPos[1,2] LISTBOX oLbVerOpo FIELDS HEADER (""),;
			STR0080,; // Campanha
			STR0010,; // Marca
			STR0011,; // Modelo
			STR0012,; // Cor
			STR0073,; // Opcionais do Veiculo
			STR0081,; // Qtd.
			STR0082,; // Data Interesse
			STR0083,; // Data Limite
			STR0085; // Item do Atendimento
			COLSIZES 10,50,25,70,50,70,30,43,43,45 SIZE aPos[1,4]-2,aPos[1,3]-aPos[1,1] OF oTelaOpo PIXEL ON DBLCLICK FS_ITETRA(aIteTra)
			oLbVerOpo:SetArray(aVerOport)
			oLbVerOpo:bLine := { || {	IIf(aVerOport[oLbVerOpo:nAt,01],oOkTik,oNoTik),;
										aVerOport[oLbVerOpo:nAt,02],;
										aVerOport[oLbVerOpo:nAt,03],aVerOport[oLbVerOpo:nAt,04],aVerOport[oLbVerOpo:nAt,05],;
										Alltrim(aVerOport[oLbVerOpo:nAt,10]),;
										FG_AlinVlrs(Transform(aVerOport[oLbVerOpo:nAt,06],"@E 999,999")),;
										Transform(aVerOport[oLbVerOpo:nAt,07],"@D"),;
										Transform(aVerOport[oLbVerOpo:nAt,08],"@D"),;
										IIf(!Empty(aVerOport[oLbVerOpo:nAt,11]),aIteTra[ascan(aIteTra,aVerOport[oLbVerOpo:nAt,11])],"") }}
ACTIVATE MSDIALOG oTelaOpo CENTER ON INIT (EnchoiceBar(oTelaOpo,{|| nOpcao:=1 , oTelaOpo:End()},{ || oTelaOpo:End()},,))
If nOpcao == 1 // OK Tela
	DbSelectArea("VDM")
	For nCntFor := 1 to len(aVerOport)
		If aVerOport[nCntFor,1]
			DbGoTo(aVerOport[nCntFor,9])
			RecLock("VDM",.f.)
				VDM->VDM_FILATE := xFilial("VV9")
				VDM->VDM_NUMATE := VV9->VV9_NUMATE
				If lVDM_ITETRA
					VDM->VDM_ITETRA := aVerOport[nCntFor,11]
				EndIf
			MsUnLock()
		EndIf
	Next nCntFor
    If ExistBlock("VX030OPO")
       	ExecBlock("VX030OPO",.f.,.f.,{ VV9->VV9_FILIAL , VV9->VV9_NUMATE })
    EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_ITETRA º Autor ³ Andre Luis Almeida º Data ³ 11/06/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Selecao do VVA_ITETRA em relacao ao Interesse do Cliente   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ITETRA(aIteTra)
Local aPBoxIteTra := {}
Local aRetIteTra  := {}
Local cSlvMVPAR01 := MV_PAR01 // Salvar MV_PAR01
aVerOport[oLbVerOpo:nAt,01] := !aVerOport[oLbVerOpo:nAt,01]
If aVerOport[oLbVerOpo:nAt,01]
	If len(aIteTra) == 1
		aVerOport[oLbVerOpo:nAt,11] := left(aIteTra[1],TamSX3("VVA_ITETRA")[1])
	ElseIf len(aIteTra) > 1
		aAdd(aPBoxIteTra,{2,STR0084,aVerOport[oLbVerOpo:nAt,11],aIteTra,80,"",.f.}) // Item
		If ParamBox(aPBoxIteTra,STR0085,@aRetIteTra,,,,,,,,.f.) // Item do Atendimento
			aVerOport[oLbVerOpo:nAt,11] := aRetIteTra[1]
		EndIf	
	EndIf
EndIf
MV_PAR01 := cSlvMVPAR01 // Volta MV_PAR01
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX030OPCFABº Autor ³ Andre Luis Almeida º Data ³ 15/08/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gravação do Opcional de Fabrica                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX030OPCFAB(nOpc)
M->VV1_OPCFAB := aVVA[oLbVVA:nAt,19]
DbSelectArea("VV1")
DbSetOrder(1)
If !Empty(aVVA[oLbVVA:nAt,9])
	DbSeek(xFilial("VV1")+aVVA[oLbVVA:nAt,9])
	// Variaveis utilizadas na Funcao 
	M->VV1_CODMAR := VV1->VV1_CODMAR
	M->VV1_MODVEI := VV1->VV1_MODVEI
Else
	// Variaveis utilizadas na Funcao 
	M->VV1_CODMAR := aVVA[oLbVVA:nAt,02]
	M->VV1_MODVEI := aVVA[oLbVVA:nAt,03]
EndIf
VXA010OPC(nOpc)
// Retorno da Funcao
aVVA[oLbVVA:nAt,19] := M->VV1_OPCFAB
Return()

/*/{Protheus.doc} VXX0300011_CriaVetorVVA

Cria linha em branco no Vetor aVVA ( Itens do Faturamento Direto )

@author Andre Luis Almeida
@since 17/07/2018

/*/
Static Function VXX0300011_CriaVetorVVA()
Local nCntFor := 0
Local nAux    := 0
aadd(aVVA,{	0 ,;
			Space(TamSX3("VVA_CODMAR")[1]) ,;
			Space(TamSX3("VVA_MODVEI")[1]) ,;
			Space(TamSX3("VVA_CORVEI")[1]) ,;
			0 ,;
			Space(TamSX3("VVA_CODPED")[1]) ,;
			Space(TamSX3("VVA_NUMPED")[1]) ,;
			Space(TamSX3("VVA_CHASSI")[1]) ,;
			"" ,;
			"" ,;
			"" ,;
			0 ,;
			ctod("") ,;
			ctod("") ,;
			0 ,;
			Space(TamSX3("VVA_FIEPRV")[1]) ,;
			Space(TamSX3("VVA_BOEPRV")[1]) ,;
			Space(TamSX3("VVA_USEPRV")[1]) ,;
			Space(TamSX3("VV1_OPCFAB")[1]) ,;
			"" ,;
			"" ,;
			"" ,;
			array(len(aVVACust)) })
//
nAux := len(aVVA)
//
For nCntFor := 1 to len(aVVACust)
	aVVA[nAux,23,nCntFor] := aVVACust[nCntFor,4]
Next
//
Return

/*/{Protheus.doc} VXX030011_EMAIL
	Gerar EMAIL no momento do 1-Pendente Aprovação / 5-Finaliza Atendimento / 6-Cancela Atendimento
	
	@author Andre Luis Almeida
	@since 18/10/2018
/*/
Static Function VXX030011_EMAIL(nTp,cTxtComp)
Local oEmailHlp  := DMS_EmailHelper():New()
Local cTitEmail  := ""
Local cEmails    := ""
Local cMensagem  := ""
Default nTp      := 5
Default cTxtComp := ""
If FindFunction("VA0100011_LevantaEmails")
	Do Case
		Case nTp == 1 // Pendente Aprovação 
			cTitEmail := STR0088+" ( "+STR0091+": "+VV0->VV0_FILIAL+" - "+STR0031+": "+VV0->VV0_NUMTRA+" )" // Atendimento PENDENTE APROVAÇÃO! / Filial: / Atendimento:
			cEmails   := VA0100011_LevantaEmails( "1" ) // E-mail's destinatarios ( 1 - Atendimento Pendente Aprovação )
		Case nTp == 5 // Atendimento Finalizado
			cTitEmail := STR0089+" ( "+STR0091+": "+VV0->VV0_FILIAL+" - "+STR0031+": "+VV0->VV0_NUMTRA+" )" // Atendimento FINALIZADO! / Filial: / Atendimento:
			cEmails   := VA0100011_LevantaEmails( "5" ) // E-mail's destinatarios ( 5 - Atendimento Finalizado )
		Case nTp == 6 // Atendimento Cancelado
			cTitEmail := STR0090+" ( "+STR0091+": "+VV0->VV0_FILIAL+" - "+STR0031+": "+VV0->VV0_NUMTRA+" )" // Atendimento PRE-APROVADO! / Filial: / Atendimento:
			cEmails   := VA0100011_LevantaEmails( "6" ) // E-mail's destinatarios ( 6 - Atendimento Cancelado )
	EndCase
	If !Empty(cEmails) // Tem E-mail para Enviar
		cMensagem := "<font size=4 face='verdana,arial' Color=#0000cc><b>"+cTitEmail+"<br><br>"+Transform(dDataBase,"@D")+" "+left(time(),5)+" - "+UPPER(UsrRetName(__CUSERID))+"</b></font><br><br><br>"
		If !Empty(cTxtComp)
			cMensagem += "<font size=3 face='verdana,arial' Color=red>"+cTxtComp+"</font><br><br><br>"
		EndIf
		oEmailHlp:Send({;
						{'assunto' , cTitEmail },;
						{'mensagem', cMensagem },;
						{'destino' , cEmails   } ;
					})
	EndIf
EndIf
Return

/*/{Protheus.doc} VXX030021_FaseAutomaticaInteresse()
	Altera automaticamente a Fase do Interesse relacionado ao Status do Atendimento
	
	@author Andre Luis Almeida
	@since 23/10/2018
/*/
Static Function VXX030021_FaseAutomaticaInteresse( cFilAte , cNumAte , cStaAte )
If FindFunction("VCM680011_FaseAutomaticaInteresse")
	VCM680011_FaseAutomaticaInteresse( cFilAte , cNumAte , cStaAte )
EndIf
Return

/*/{Protheus.doc} VXX0300031_EntradasVS9
	Entradas - Preencher as Parcelas VS9 ( apenas documentacional )
	
	@author Andre Luis Almeida
	@since 23/01/2020
/*/
Static Function VXX0300031_EntradasVS9( nOpc , aPar1 , aPar2 , aPar3 )
Local nOpcEnt := 2
Private aCols := {} // Compatibilidade com o VEIXX011 ( Entradas )
If Empty(aParEnt[1])
	MsgAlert(STR0093,STR0002) // Necessário SALVAR antes o Faturamento Direto. / Atencao
Else
	If nOpc == 3 .or. ( nOpc == 4 .and. VV9->VV9_STATUS == "A" )
		nOpcEnt := nOpc
	EndIf
	VEIXX011(nOpcEnt,@aPar1,@aPar2,@aPar3)	// ( nOpc / aParEnt / aVS9 / aVSE )
EndIf
Return

/*/{Protheus.doc} VXX030004_GravaEntradasVS9VSE
	Entradas - Gravacao do VS9 e VSE ( apenas documentacional )
	
	@author Andre Luis Almeida
	@since 24/01/2020
/*/
Static Function VXX030004_GravaEntradasVS9VSE( aVS9 , aVSE )
Local nCntLinha := 0
Local nCntCampo := 0
If len(aVS9[2]) > 0 // Entradas VS9
	VX0020021_GravaVS9( @aVS9 ) // Chama Gravacao do VS9
	VS9->(dbGoTo(VS9->(Recno()))) // Desposicionar, para considerar em SELECT no meio da transacao
	VX002X3LOAD( "VS9" , .t. , @aVS9 , 1 , "VS9_FILIAL+VS9_NUMIDE+VS9_TIPOPE", xFilial("VS9")+PadR(M->VV9_NUMATE,TamSX3("VS9_NUMIDE")[1]," ")+"V") // Levanta novamente todos os VS9 correspondentes ao Atendimento
EndIf
If len(aVSE[2]) > 0 // Complemento Entradas VSE
	VX0020031_GravaVSE( @aVSE ) // Chama Gravacao do VSE
	VSE->(dbGoTo(VSE->(Recno()))) // Desposicionar, para considerar em SELECT no meio da transacao
	VX002X3LOAD( "VSE" , .t. , @aVSETotal , 1 , "VSE_FILIAL+VSE_NUMIDE+VSE_TIPOPE" , xFilial("VSE")+PadR(M->VV9_NUMATE,TamSX3("VSE_NUMIDE")[1]," ")+"V" ) // Levanta novamente todos os VSE correspondentes ao Atendimento
EndIf
Return