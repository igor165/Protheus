#Include "TMSA501.ch"
#Include 'Protheus.ch'

Static cTMSERP := SuperGetMV("MV_TMSERP",," ")	//-- Condição de integração com ERP (0 - Protheus, 1 - Datasul)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TMSA501 ³ Autor ³ Valdemar Roberto       ³ Data ³24.03.2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Insere dados eletronicos no documento fiscal               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA501()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TmsA501()
Local aCores := {}
Local lCont  := .T.

Private cCadastro := STR0001	//-- "Insere dados eletronicos no documento fiscal"
Private aRotina   := MenuDef()

If cTMSERP != "1"
	Help("",1,"TMSA50105")	//-- "Esta funcionalidade somente poderá ser utilizada, com a integração com ERP Datasul ativa."
	lCont := .F.
EndIf

If lCont
	AAdd(aCores,{ "Empty(F3_DTCANC)","BR_VERDE"})	//-- Não Cancelado
	AAdd(aCores,{"!Empty(F3_DTCANC)","BR_VERMELHO"})	//-- Cancelado
	
	Mbrowse(6,1,22,75,"SF3",,,,,,aCores)
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TmsA500Mnt³ Autor ³ Alex Egydio           ³ Data ³22.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manutencao de documentos                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA200Mnt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA501Mnt( cAlias, nReg, nOpcx )
Local aAreas   := {DT6->(GetArea()),SFT->(GetArea()),SF3->(GetArea()),DTC->(GetArea()),GetArea()}
Local aVisual  := {}
Local aAltera  := {}
Local aContAnt := {}
Local lCont    := .T.
Local lTSSOK   := .T.
Local nOpca    := 0
//-- Variaveis da tela
Local cSeekSFT := ""
Local oDlgNFE
Local oEmiNFE
Local oHorNFE
Local oChvNFE
Local oCodNFE
//-- Dimensionamento da tela
Local aButtons := {}
Local aSize    := {}
Local aObjects := {}
Local aInfo    := {}
Local aPosObj  := {}

//-- Variaveis da tela
Private dEmiNFE  := SF3->F3_EMINFE
Private cHorNFE  := SF3->F3_HORNFE
Private cChvNFE  := SF3->F3_NFELETR
Private cCodNFE  := SF3->F3_CODNFE

Private aSetKey := {}
Private oDlgNFE

nOpcx := aRotina[nOpcx,4]

If nOpcx == 2
	AxVisual(cAlias,nReg,nOpcx,,,,,)
	lCont := .F.
EndIf

If lCont .And. AllTrim(SF3->F3_ESPECIE) != "RPS"
	Help("",1,"TMSA50106")	//-- "Documento não é uma nota fiscal."
	lCont := .F.
EndIf
	
If lCont
	If nOpcx == 8	//-- Autenticação
		If !Empty(SF3->F3_DTCANC)
			Help("",1,"TMSA50107")	//-- "Documento está cancelado."
			lCont := .F.
		Else
			DT6->(DbSetOrder(1))
			If !DT6->(DbSeek(xFilial("DT6") + SF3->(F3_FILIAL + F3_NFISCAL + F3_SERIE)))
				Help("",1,"TMSA50108")	//-- "Documento de transporte não localizado."
				lCont := .F.
			Else
				If !Empty(SF3->F3_CODRSEF)
					Help("",1,"TMSA50109")	//-- "Documento já enviado à SEFAZ."
					lCont := .F.
				EndIf
			EndIf
		EndIf
	ElseIf nOpcx == 9	//-- Cancelamento
		If Empty(SF3->F3_DTCANC)
			Help("",1,"TMSA50110")	//-- "Documento não está cancelado."
			lCont := .F.
		Else
			DT6->(DbSetOrder(1))
			If DT6->(DbSeek(xFilial("DT6") + SF3->(F3_FILIAL + F3_NFISCAL + F3_SERIE)))
				Help("",1,"TMSA50111")	//-- "Primeiramente estorne o documento no TMS."
				lCont := .F.
			Else
				If AllTrim(SF3->F3_CODRSEF) == "101"
					Help("",1,"TMSA50112")	//-- "Cancelamento já enviado à SEFAZ."
					lCont := .F.
				ElseIf Empty(SF3->F3_CODRSEF)
					Help("",1,"TMSA50115")	//-- "Não é possível enviar o cancelamento de um documento, sem que sua autenticação tenha sido enviada ao ERP."
					lCont := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If lCont
	//-- Calcula as dimensoes dos objetos.
	aSize  := MsAdvSize(.T.)
	AAdd(aObjects,{100,100,.T.,.T.})
	aInfo  := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj:= MsObjSize(aInfo,aObjects,.T.)

	DEFINE MSDIALOG oDlgNFE TITLE "Informações Fiscais" FROM aSize[7]/2,00 TO aSize[6]/2.5,aSize[5]/1.5 PIXEL
		@ 040,006 Say AllTrim(RetTitle("F3_EMINFE")) Size 030,009 Of oDlgNFE Pixel
		@ 039,038 MsGet oEmiNFE Var dEmiNFE Valid NaoVazio(dEmiNFE) .And. Tmsa501Vld() Size 040,009 When (nOpcx == 8) Of oDlgNFE Pixel

		@ 060,006 Say AllTrim(RetTitle("F3_HORNFE")) Size 030,009 Of oDlgNFE Pixel
		@ 059,038 MsGet oHorNFE Var cHorNFE Valid NaoVazio(cHorNFE) .And. Tmsa501Vld() Size 030,009 Valid Picture AllTrim(X3Picture("F3_HORNFE")) When (nOpcx == 8) Of oDlgNFE Pixel

		@ 080,006 Say AllTrim(RetTitle("F3_NFELETR")) Size 030,009 Of oDlgNFE Pixel
		@ 079,038 MsGet oChvNFE Var cChvNFE Valid NaoVazio(cChvNFE) .And. Tmsa501Vld() Size 080,009 When (nOpcx == 8) Of oDlgNFE Pixel

		@ 100,006 Say AllTrim(RetTitle("F3_CODNFE")) Size 030,009 Of oDlgNFE Pixel
		@ 099,038 MsGet oCodNFE Var cCodNFE Valid Tmsa501Vld() Size 080,009 When (nOpcx == 8) Of oDlgNFE Pixel
	ACTIVATE MSDIALOG oDlgNFE CENTERED ON INIT EnchoiceBar(oDlgNFE,{|| nOpca := 1,oDlgNFE:End()},{|| oDlgNFE:End()},,aButtons)

	If nOpca == 1 .And. nOpcx != 2
		Aadd(aContAnt,SF3->F3_EMINFE)
		Aadd(aContAnt,SF3->F3_HORNFE)
		Aadd(aContAnt,SF3->F3_NFELETR)
		Aadd(aContAnt,SF3->F3_CODNFE)
		Aadd(aContAnt,SF3->F3_CODRSEF)

		RecLock("SF3",.F.)
		SF3->F3_EMINFE  := dEmiNFE
		SF3->F3_HORNFE  := cHorNFE
		SF3->F3_NFELETR := cChvNFE
		SF3->F3_CODNFE  := cCodNFE
		SF3->F3_CODRSEF := Iif(nOpcx == 8,"100","101")
		SF3->(MsUnlock())
		
		DT6->(DbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE                                                                                                                         
		If DT6->(DbSeek(xFilial("DT6") + SF3->(F3_FILIAL + F3_NFISCAL + F3_SERIE)))
			RecLock("DT6",.F.)
			DT6->DT6_NFELET := cChvNFE
			DT6->DT6_EMINFE := dEmiNFE
			DT6->DT6_CODNFE := cCodNFE
			SF3->(MsUnlock())

			DTC->(DbSetOrder(1)) //DTC_FILIAL+DTC_FILORI+DTC_LOTNFC+DTC_CLIREM+DTC_LOJREM+DTC_CLIDES+DTC_LOJDES+DTC_SERVIC+DTC_CODPRO+DTC_NUMNFC+DTC_SERNFC
			If DTC->(MsSeek(xFilial("DTC")+DT6->DT6_FILORI+DT6->DT6_LOTNFC+DT6->DT6_CLIREM+DT6->DT6_LOJREM+DT6->DT6_CLIDES+DT6->DT6_LOJDES+DT6->DT6_SERVIC))
				RecLock("DTC",.F.)
				DTC->DTC_NFELET := cChvNFE
				DTC->DTC_EMINFE := dEmiNFE
				DTC->DTC_CODNFE := cCodNFE
				SF3->(MsUnlock())
			EndIf
		EndIf		

		If nOpcx == 8
			SFT->(DbSetOrder(3))
			If SFT->(DbSeek(cSeekSFT := xFilial("SFT") + "S" + SF3->(F3_CLIEFOR + F3_LOJA + F3_SERIE + F3_NFISCAL)))
				Do While SFT->(!Eof()) .And. SFT->(xFilial("SFT") + FT_TIPOMOV + FT_CLIEFOR + FT_LOJA + FT_SERIE + FT_NFISCAL) == cSeekSFT
					RecLock("SFT",.F.)   						
					SFT->FT_EMINFE  := dEmiNFE
					SFT->FT_HORNFE  := cHorNFE
					SFT->FT_NFELETR := cChvNFE
					SFT->FT_CODNFE  := cCodNFE
					SFT->(MsUnLock ())
					SFT->(DbSkip())
				EndDo
			EndIf
		EndIf
		
		lTssOK := TMSAE76()		
		If !lTssOK 
			RecLock("SF3",.F.)
			SF3->F3_EMINFE  := aContAnt[1]
			SF3->F3_HORNFE  := aContAnt[2]
			SF3->F3_NFELETR := aContAnt[3]
			SF3->F3_CODNFE  := aContAnt[4]
			SF3->F3_CODRSEF := aContAnt[5]
			SF3->(MsUnlock())			
		EndIf		
	EndIf

EndIf

AEval(aAreas,{|x| RestArea(x)})

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Tmsa501Leg³ Autor ³ Valdemar Roberto      ³ Data ³24/03/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Exibe a legenda dos status                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tmsa501Leg()
Local aLegenda := {{"BR_VERDE"   ,STR0007},;	//-- "Não Cancelado"
				   {"BR_VERMELHO",STR0008}}		//-- "Cancelado"

BrwLegenda(cCadastro,STR0009,aLegenda)	//-- "Status"

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Tmsa501Vld³ Autor ³ Valdemar Roberto      ³ Data ³11/04/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Valida digitação                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tmsa501Vld(cCampo)
Local lRet := .T.

Default cCampo := ReadVar()

If Upper(AllTrim(cCampo)) == "DEMINFE"
	If dEmiNFe < SF3->F3_EMISSAO
		Help("",1,"TMSA50113")	//-- "Data de autenticação não pode ser menor que a data de geração do documento."
		lRet := .F.
	ElseIf dEmiNFe > dDataBase
		Help("",1,"TMSA50114")	//-- "Data de autenticação não pode ser maior que hoje."
		lRet := .F.
	EndIf
ElseIf Upper(AllTrim(cCampo)) == "CHORNFE"
	If !AtVldHora(cHorNFe)
		lRet := .F.
	Else
		If !Empty(SubStr(cHorNFe,5,2)) .And. SubStr(cHorNFe,5,2) > "60"
			Help("",1,"VLDHORA")
			lRet := .F.
		Else
			If dEmiNFe == dDataBase
				If cHorNFe > SubStr(Time(),1,2) + SubStr(Time(),4,2) +SubStr(Time(),7,2)
					Help("",1,"TMSA50116")	//-- "Hora da nota fiscal não pode ser maior que a hora atual."
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transacao a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MenuDef(lVisual,lAlianca)
Private aRotina := {{STR0002,"AxPesqui"  ,0,1,0,.F.},;	//-- "Pesquisar"
					{STR0003,"TmsA501Mnt",0,2,0,Nil},;	//-- "Visualizar"
					{STR0006,"Tmsa501Leg",0,7,0,Nil},;	//-- "Legenda"
					{STR0004,"Tmsa501Mnt",0,8,0,Nil},;	//-- "Autenticação"
					{STR0005,"Tmsa501Mnt",0,9,0,Nil}}	//-- "Cancelamento"

Return (aRotina)
