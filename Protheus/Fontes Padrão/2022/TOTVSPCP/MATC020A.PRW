#INCLUDE "MATC020A.ch"
#Include "MsGraphi.ch"
#INCLUDE "PROTHEUS.CH"


//Tamanhos do TREE
#Define TREE_CARGO  060
#Define TREE_PROMPT 050

// Bmp's utilizados no Tree
#Define cBmpCTOk  "PMSEDT3"
#Define cBmpCTOL  "PMSEDT1"
#Define cBmpDtOk  "PMSEDT3"
#Define cBmpDtOL  "PMSEDT1"
#Define cBmpRec   "PMSEDT4"
#Define cBmpOP    "PMSDOC"

// Array que guarda os graficos feitos, para evitar reprocessamento
Static aGraph := {}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATC020A ³ Autor ³ Guilherme C. Leal     ³ Data ³ 20030820 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta de Carga acumulada por Data e/ou Centros de Tra-  ³±±
±±³          ³ balho                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ MATC020A                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ AP8+                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ³        ³      ³                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡…o ³ PLANO DE MELHORIA CONTINUA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ITEM PMC  ³ Responsavel              ³ Data         |BOPS:		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³      01  ³                          ³              |                  ³±±
±±³      02  ³Erike Yuri da Silva       ³20/02/2006    |00000091869       ³±±
±±³      03  ³                          ³              |                  ³±±
±±³      04  ³                          ³              |                  ³±±
±±³      05  ³                          ³              |                  ³±±
±±³      06  ³                          ³              |                  ³±±
±±³      07  ³                          ³              |                  ³±±
±±³      08  ³                          ³              |                  ³±±
±±³      09  ³Erike Yuri da Silva       ³20/02/2006    |00000091869       ³±±
±±³      10  ³                          ³              |                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/	
Function MATC020A()
Local aSizeAut  := MsAdvSize(,.F.)  // Pega tamanho total da tela
Local lFlatMode := FlatMode()
Local oExp      := Nil                   // Objeto Explorer
Local oPanGraph := Nil                   // Panel que suportara os graficos criados
Local oMenuOrd  := Nil                   // Menu para selecionar ordem (Data/Centro de Trabalho)
Local nType     := 1                     // Ordem da consulta
Local aIndices  := {}                    // Array com Filtros do SHH

// Condicao de Filtro
Local bCondicao := { || "HH_FILIAL == '" +  xFilial("SHH") + "' .And. " + ;
			 "DTOS(HH_DATA) >= '" + DTOS(mv_par01) + "' .And. DTOS(HH_DATA) <= '" + DTOS(mv_par02) + "' .And. " + ;
			 "HH_CTRAB >= '" + mv_par03 + "' .And. HH_CTRAB <= '" + mv_par04 + "' .And. " + ;
			 "HH_RECURSO >= '" + mv_par05 + "' .And. HH_RECURSO <= '" + mv_par06 + "' .And. " + ;
			 "HH_OP >= '" + mv_par07 + "' .And. HH_OP <= '" + mv_par08 + "'" }

Local bFilBrw   := {|| FilBrowse( "SHH", @aIndices, Eval(bCondicao) )} // Bloco para executar o filtro
Local oPanOP    := Nil                    // Panel que suportara a Enchoice das OP's
Local oOP       := Nil                    // Objeto Enchoice das OP's
Default lAutoMacao := .F.

If !Pergunte("MTC020",.T.)
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01 // data inicial                                     ³
//³ mv_par02 // data Final                                       ³
//³ mv_par03 // Centro de Trabalho De                            ³
//³ mv_par04 // Centro de Trabalho Ate                           ³
//³ mv_par05 // Recurso De                                       ³
//³ mv_par06 // Recurso Ate                                      ³
//³ mv_par07 // Numero da OP de                                  ³
//³ mv_par08 // Numero da OP ate                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


// Cria Objeto Explorer
IF !lAutoMacao
	oExp := MsExplorer():New(STR0001,000+If(lFlatMode,-10,0),000,aSizeAut[6]+If(lFlatMode,+10,0),aSizeAut[5],,.T.,.F.,.T.,,,,) //"Histograma"
	// Cria Barra de botoes padrao
	oExp:DefaultBar()
	// botoes adicionais
	oExp:AddDefButton("FINAL",STR0002,{|| oExp:DeActivate()}) //"Sair"
	oExp:AddDefButton("SDUSETDEL",STR0003,{|o| oMenuOrd:Activate(o:nLeft,25,oExp:oDlg) }) //"Carga acumulada"
	oExp:AddDefButton("sduprop",STR0004,{|o| If(Pergunte("MTC020",.T.),(EndFilBrw("SHH", @aIndices), aIndices := {},LoadTree(@oExp,nType,bFilBrw),C020Change(@oPanGraph,oExp:oTree:GetCargo(),@oPanOP,@oOP)),) }) //"Parâmetros"
	oExp:AddDefButton("bmpvisual",STR0005,{|o| C020Leg() }) //"Legenda"

	// Seta propriedades de Tree
	oExp:oTree:nLeft   := ( oExp:oTree:nLeft + 10 )
	oExp:oTree:nWidth  := ( ( oExp:oDlg:nClientWidth * 3 ) / 8 ) - 10
	oExp:oTree:bValid  := {|a,b,c,cNewCarg| C020Change(@oPanGraph,cNewCarg,@oPanOP,@oOP,.F.) }

	// Cria Panel que suportara os gráficos
	oPanGraph := oExp:GetPanel( oExp:NewPanel() )
	oPanGraph:align 	 := CONTROL_ALIGN_ALLCLIENT
	// Cria Panel que suportara a enchoice das OP's
	oPanOP := oExp:GetPanel( oExp:NewPanel() ) 
	oPanOP:align 	 := CONTROL_ALIGN_ALLCLIENT


	// Monta Enchoice da OP
	RegToMemory("SC2",.T.)
	oOP := MSMGet():New('SC2',,2,,,,,{0,0,(oPanOP:nHeight/2),(oPanOP:nWidth/2)},,,,,,oPanOP,,,,,,.T.,,,)

	// Monta menu de ordens da consulta
	oMenuOrd := MenuBegin(,,,, .T.,,, )
		MenuAddItem( STR0006,, .F.,,{|oMenuItem| nType := 1, LoadTree(@oExp,nType,bFilBrw),C020Change(@oPanGraph,oExp:oTree:GetCargo(),@oPanOP,@oOP)  },,,,,,, .F.,,, .F. ) //"Por Data"
		MenuAddItem( STR0007,, .F.,,{|oMenuItem| nType := 2, LoadTree(@oExp,nType,bFilBrw),C020Change(@oPanGraph,oExp:oTree:GetCargo(),@oPanOP,@oOP) },,,,,,, .F.,,, .F. ) //"Por Centro de Trabalho"
	MenuEnd()

	// Chama funcao que monta o Tree
	LoadTree(@oExp,nType,bFilBrw)

	// Chama funcao que monta o graphico de acordo com a posicao do Tree
	C020Change(@oPanGraph,oExp:oTree:GetCargo(),@oPanOP,@oOP)
	oExp:oDlg:bInit := {|| oExp:oTree:Refresh(),oPanGraph:Refresh(),oPanOP:Refresh(),SysRefresh()}
	oExp:Activate(.T.)
ENDIF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LoadTree  ºAutor  ³Guilherme C. Leal   º Data ³  20030820   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta MsgRun e chama AuxLoadTree para fazer a carga do     º±±
±±º          ³ Tree.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATC020A                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LoadTree(oExp,nType,bFilBrw)
	MsgRun(STR0008,,{|| AuxLoadTree(@oExp,nType,bFilBrw) } ) //"Carregando Dados ..."
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AuxLoadTreºAutor  ³Guilherme C. Leal   º Data ³  20030820   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta o Tree com base no SHH                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATC020A                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AuxLoadTree(oExp,nType,bFilBrw)
Local dData    := Nil
Local cData    := ""
Local cCTrab   := ""
Local cRecurso := ""

Local nTotDt   := 0
Local nTotCT   := 0
Local nTotRec  := 0

Local cCargoDt  := ""
Local cCargoCT  := ""
Local cCargoRec := ""
Local cCargoOP  := ""

Local cFilOk    := xFilial("SHH")
Local nPerc     := 0
Local lOverCT   := .F.
Local lOverDt   := .F.
Default lAutoMacao := .F.

// Limpa o Tree
IF !lAutoMacao
	oExp:oTree:Reset()
ENDIF

SH1->(DbSetOrder(1))
SHB->(DbSetOrder(1))

// nType = Ordem
// 1 - HH_FILIAL+DTOS(HH_DATA)+HH_CTRAB+HH_RECURSO+HH_OP
// 2 - HH_FILIAL+HH_CTRAB+DTOS(HH_DATA)+HH_RECURSO+HH_OP
DEFAULT nType  := 1

DbSelectArea("SHH")
DbSetOrder(nType)

Eval(bFilBrw) // Filtra SHH
DbSeek(cFilOk)

If nType == 1
	// Data
	While !SHH->(EOF()) .And. cFilOk == SHH->HH_FILIAL
		If cData != DToS(SHH->HH_DATA)
			cData    := DToS(SHH->HH_DATA)
			cCTrab   := ""
			cRecurso := ""
			nTotDt   := 0
			lOverDt  := .F.
			cCargoDt := "11"+StrZero(SHH->(Recno()),10)
			dData    := SHH->HH_DATA

			// Adiciona Node da Data
			IF !lAutoMacao
				oExp:oTree:AddTree( PADR(DTOC(SHH->HH_DATA),TREE_PROMPT), .F., cBmpDtOk,,,, cCargoDt )
			ENDIF

			// Centros de Trabalho
			While !SHH->(EOF()) .And. cFilOk == SHH->HH_FILIAL .And. cData == DToS(SHH->HH_DATA)
				If cCTrab != SHH->HH_CTRAB .And. SHB->(DbSeek(xFilial("SHB")+SHH->HH_CTRAB))
					cCTrab   := SHH->HH_CTRAB
					cRecurso := ""
					nTotCT   := 0
					cCargoCT := "12"+StrZero(SHH->(Recno()),10)

					// Adiciona Node da Data
					IF !lAutoMacao
						oExp:oTree:AddTree( PADR(SHB->HB_NOME,TREE_PROMPT), .F., cBmpCTOk,,,, cCargoCT )
					ENDIF

					// Recursos
					While !SHH->(EOF()) .And. cFilOk == SHH->HH_FILIAL .And. cData == DToS(SHH->HH_DATA) .And. cCTrab == SHH->HH_CTRAB
						If cRecurso != SHH->HH_RECURSO .And. SH1->(DbSeek(xFilial("SH1")+SHH->HH_RECURSO))
							cRecurso := SHH->HH_RECURSO
							nTotRec  := 0
							cCargoRec:= "13"+StrZero(SHH->(Recno()),10)
							
							// Adiciona Node de Recursos
							IF !lAutoMacao
								oExp:oTree:AddTree( PADR(SH1->H1_DESCRI,TREE_PROMPT), .F., cBmpRec,,,, cCargoRec )
							ENDIF

							// OP's
							While !SHH->(EOF()) .And. cFilOk == SHH->HH_FILIAL .And. cData == DToS(SHH->HH_DATA) .And. cCTrab == SHH->HH_CTRAB .And. cRecurso == SHH->HH_RECURSO
								cCargoOP := "14"+StrZero(SHH->(Recno()),10)

								// Adiciona Node da OP
								SC2->(DbSetOrder(1))
								If SC2->(DbSeek(xFilial("SC2")+SHH->HH_OP))
									IF !lAutoMacao
							        	oExp:oTree:AddTreeItem( PADR(SHH->HH_OP,TREE_PROMPT), cBmpOP,, cCargoOP )
									ENDIF
                                EndIf
								nTotRec  += SHH->HH_USO
								SHH->(DbSkip())
							EndDo
							// Encerra Tree de Recursos
							IF !lAutoMacao
					       		oExp:oTree:EndTree()
							ENDIF
					        nTotCT += nTotRec
						Else
							SHH->(DbSkip())
							Loop
						EndIf
					EndDo

					// Encerra Tree de Data
					IF !lAutoMacao
 			        	oExp:oTree:EndTree()
					ENDIF
					nTotDt += nTotCT
					nPerc := CalcLoadCT(SHB->HB_COD,dData,nTotCT)
			        lOverCT := ( nPerc > 100 )
			        If lOverCT
			        	lOverDt := .T.
			        	oExp:oTree:ChangeBMP(cBmpCTOL,cBmpCTOL,,,cCargoCT)
					EndIf
					IF !lAutoMacao
   						oExp:oTree:ChangePrompt(AllTrim(SHB->HB_NOME) + " - (" + AllTrim(Str(nPerc)) + "%)", cCargoCT )
					ENDIF
				Else
					SHH->(DbSkip())
					Loop
				EndIf

			EndDo
			//Encerra Tree de Centros de Trabalho
			IF !lAutoMacao
				oExp:oTree:EndTree()
				If lOverDt
					oExp:oTree:ChangeBMP(cBmpDtOL,cBmpDtOL,,,cCargoDt)
				EndIf
			ENDIF
		Else
			SHH->(DbSkip())
			Loop
		EndIf
	// Data
	EndDo
Else
	// Centros de Trabalho
	While !SHH->(EOF()) .And. cFilOk == SHH->HH_FILIAL
		If cCTrab != SHH->HH_CTRAB .And. SHB->(DbSeek(xFilial("SHB")+SHH->HH_CTRAB))
			cCTrab   := SHH->HH_CTRAB
			cCargoCT := "21"+StrZero(SHH->(Recno()),10)
			cData    := ""
			cRecurso := ""
			nTotCT   := 0
			lOverCT  := .F. 
			// Cria Node do Centro de Trabalho
			oExp:oTree:AddTree( PADR(SHB->HB_NOME,TREE_PROMPT), .F., cBmpCTOk,,,, cCargoCT )

			// Datas
			While !SHH->(EOF()) .And. cFilOk == SHH->HH_FILIAL .And. cCTrab == SHH->HH_CTRAB
				If cData != DToS(SHH->HH_DATA)
					dData    := SHH->HH_DATA
					cData    := DToS(SHH->HH_DATA)
					cCargoDt := "22"+StrZero(SHH->(Recno()),10)
					cRecurso := ""
					nTotDt   := 0
					// Cria Node de Datas
					oExp:oTree:AddTree( Space(TREE_PROMPT), .F., cBmpDtOk,,,, cCargoDt )

					// Recursos
					While !SHH->(EOF()) .And. cFilOk == SHH->HH_FILIAL .And. cCTrab == SHH->HH_CTRAB .And. cData == DToS(SHH->HH_DATA)
						If cRecurso != SHH->HH_RECURSO .And. SH1->(DbSeek(xFilial("SH1")+SHH->HH_RECURSO))
							cRecurso  := SHH->HH_RECURSO
							cCargoRec := "23"+StrZero(SHH->(Recno()),10)
							nTotRec   := 0
							// Cria Node de Recursos
							oExp:oTree:AddTree( PADR(SH1->H1_DESCRI,TREE_PROMPT), .F., cBmpRec,,,, cCargoRec )

							// OP's
							While !SHH->(EOF()) .And. cFilOk == SHH->HH_FILIAL .And. cCTrab == SHH->HH_CTRAB .And. cData == DToS(SHH->HH_DATA) .And. cRecurso == SHH->HH_RECURSO
								cCargoOP := "24"+StrZero(SHH->(Recno()),10)
								// Cria Node de OP's
								SC2->(DbSetOrder(1))
								If SC2->(DbSeek(xFilial("SC2")+SHH->HH_OP))
				 				    oExp:oTree:AddTreeItem( PADR(SHH->HH_OP,TREE_PROMPT), cBmpOP,, cCargoOP )
                                EndIf   
								nTotRec  += SHH->HH_USO
								SHH->(DbSkip())
							// OP's
							EndDo
					        oExp:oTree:EndTree()
					        nTotDt += nTotRec
						Else
							SHH->(DbSkip())
							Loop
						EndIf
					//Recursos
					EndDo
			        oExp:oTree:EndTree()
			        nTotCT += nTotDt

					nPerc := CalcLoadCT(SHB->HB_COD,dData,nTotDt)
			        lOverDt := ( nPerc > 100 )
			        If lOverDt
			        	lOverCT := .T.
			        	oExp:oTree:ChangeBMP(cBmpDtOL,cBmpDtOL,,,cCargoDt)
					EndIf
   					oExp:oTree:ChangePrompt(DTOC(dData) + " - (" + AllTrim(Str(nPerc)) + "%)", cCargoDt )
				Else
					SHH->(DbSkip())
					Loop
				EndIf
			// Data
			EndDo
			oExp:oTree:EndTree()
	        If lOverCT
	        	oExp:oTree:ChangeBMP(cBmpCTOL,cBmpCTOL,,,cCargoCT)
			EndIf
		Else
			SHH->(DbSkip())
			Loop
		EndIf
	// CT
	EndDo
EndIF

IF !lAutoMacao
	oExp:oTree:Refresh()
ENDIF

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CalcLoadCTºAutor  ³Guilherme C. Leal   º Data ³  20030820   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula percentual de carga do Recurso em uma data.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATC020A                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcLoadCT(cCTRAB,dData,nHoras)
Local nPerc   := 0
Local nDay    := Dow(dData)
Local nOrdSHB := SHB->(IndexOrd())
Local nRecSHB := SHB->(Recno())

SHB->(DbSeek(xFilial("SHB")+cCTRAB))

If nDay == 1
	nPerc := nHoras/SHB->HB_HRUTDOM
ElseIf nDay == 7
	nPerc := nHoras/SHB->HB_HRUTSAB
Else
	nPerc := nHoras/SHB->HB_HRUT
EndIf

nPerc := Round(nPerc * 100,2)

SHB->(DbSetOrder(nOrdSHB))
SHB->(DbGoto(nRecSHB))
Return nPerc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³C020ChangeºAutor  ³Guilherme C. Leal   º Data ³  20030820   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula percentual de carga do Recurso em uma data.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATC020A                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C020Change(oPanGraph,cNewCarg,oPanOP,oOP,lRefresh)
Local oGraphic  := Nil   // Objeto de Grafico
Local nSerie    := 0
Local nOrd      := Val(Left(cNewCarg,1))
Local cLevel    := SubStr(cNewCarg,2,1)
Local cKey      := ""
Local nRegSHH   := Val(SubStr(cNewCarg,3))
Local nPos      := 0
Local nPerc     := 0
Local nTot      := 0
Local nTotRec   := 0                     
Local dData     := Nil
Local cCTrab    := Nil
Local cRecurso  := Nil
Local cOP       := Nil
Local aBars     := {}
Local nI        := 0
Local nx		:= 0

Default lRefresh   := .T.  // Indica se o o array aGraph deve ser reiniciado
Default lAutoMacao := .F.

SHH->(DbSetOrder(nOrd))
SHH->(DbGoTo(nRegSHH))

If cLevel == "4" // OP Monta Enchoice
	SC2->(DbSetOrder(1))
	If SC2->(DbSeek(xFilial("SC2")+SHH->HH_OP))
		RegToMemory("SC2",.F.)
		oOP:Refresh()
		oPanGraph:Hide()
		oPanOP:Show()
    EndIf  
	Return .T.
EndIf

// "Esconde" o panel de OP
IF !lAutoMacao
	oPanOP:Hide()
ENDIF

// "Esconde" todos os graphicos
If Len(aGraph) > 0 

	For nx := 1 to len(aGraph) 
		
		IF VALTYPE(aGraph[nx][2]) == "O" 
			AEval(aGraph,{|x| x[2]:Hide() },nx,1) 
		EndIF
	
	Next Nx 
	
EndIF

If lRefresh
	aGraph := {}
EndIf

// Garante que o panel de graphicos esta visivel
IF !lAutoMacao
	oPanGraph:Show()
ENDIF

// Verifica se o graphico já existe no aGraph
If Len(aGraph) == 0 .Or. (nPos := AScan(aGraph,{|x| x[1] == cNewCarg }) ) == 0
	// Cria Grafico
	IF !lAutoMacao
		oGraphic:=TMSGraphic():New( 001, 001, oPanGraph, , , , (oPanGraph:nClientWidth/2)-2, (oPanGraph:nClientHeight/2) - 2 )
		oGraphic:SetMargins(2,6,6,6)
		oGraphic:SetGradient(GDBOTTOMTOP,CLR_HGRAY,CLR_WHITE)
		oGraphic:SetLegenProp(GRP_SCRRIGHT,CLR_WHITE,GRP_AUTO,.T.)
	ENDIF
Else
	// Apresenta o grafico existente
	IF !lAutoMacao
		oGraphic := aGraph[nPos][2]
		oGraphic:Refresh()
		oGraphic:Show()
	ENDIF
	Return .T.
EndIf

If nOrd == 1
	Do Case
		Case cLevel == "1" // Data
			nSerie	:=	oGraphic:CreateSerie( 4 )
			oGraphic:l3D := .T.
			oGraphic:SetTitle(STR0009  , DTOC(SHH->HH_DATA) , CLR_BLACK , A_LEFTJUST , GRP_TITLE ) //"Carga de Centros de Trabalho por Dia"

			dData  := SHH->HH_DATA
			cKey   := SHH->(xFilial("SHH")+DTOS(HH_DATA))
			cCTrab := ""
   
			While !SHH->(EOF()) .And. SHH->(HH_FILIAL+DTOS(HH_DATA)) == cKey
				If cCTrab != SHH->HH_CTRAB
					cCTrab := SHH->HH_CTRAB
					nTot   := 0
					nPerc  := 0
					While !SHH->(EOF()) .And. SHH->(HH_FILIAL+DTOS(HH_DATA)) == cKey .And. cCTrab == SHH->HH_CTRAB
						nTot += SHH->HH_USO
						SHH->(DbSkip())
					EndDo
					SHB->(DbSeek(xFilial("SHB")+cCTrab))
					nPerc := CalcLoadCT(cCTrab,dData,nTot)
					oGraphic:Add(nSerie, nTot, AllTrim(SHB->HB_NOME) + " - (" + AllTrim(Str(nPerc)) + "%)", CLR_BLUE )
					Loop
				EndIf
				SHH->(DbSkip())
			EndDo

		Case cLevel == "2" // Centros de Trabalho
			nSerie	:=	oGraphic:CreateSerie( 10 )
			cKey     := SHH->(xFilial("SHH")+DTOS(HH_DATA)+HH_CTRAB)
			dData    := SHH->HH_DATA
			cCTrab   := SHH->HH_CTRAB
			cRecurso := ""
			nTot     := 0
			SHB->(DbSeek(xFilial("SHB")+SHH->HH_CTRAB))

			While !SHH->(EOF()) .And. SHH->(HH_FILIAL+DTOS(HH_DATA)+HH_CTRAB) == cKey
				If cRecurso != SHH->HH_RECURSO
					cRecurso := SHH->HH_RECURSO
					nTotRec  := 0
					While !SHH->(EOF()) .And. SHH->(HH_FILIAL+DTOS(HH_DATA)+HH_CTRAB) == cKey .And. cRecurso == SHH->HH_RECURSO
						nTotRec += SHH->HH_USO
						nTot    += SHH->HH_USO
						SHH->(DbSkip())
					EndDo
					SH1->(DbSeek(xFilial("SH1")+cRecurso))
					AAdd(aBars,{nTotRec,AllTrim(SHB->HB_NOME), AllTrim(SH1->H1_DESCRI) })
					Loop
				EndIf
				SHH->(DbSkip())
			EndDo
			oGraphic:SetMargins(1,1,1,1)            
			oGraphic:SetTitle(STR0010  , AllTrim(SHB->HB_NOME) + " - (" + AllTrim(Str(nTot)) + " Hrs)" , CLR_BLACK , A_LEFTJUST , GRP_TITLE ) //"Ocupação dos Centros Trabalho por Recurso"
			For nI := 1 To Len(aBars)
				oGraphic:Add(nSerie, aBars[nI][1], aBars[nI][3] + " - (" + AllTRim(Str(Round((aBars[nI][1]*100/nTot),2))) + " %)", GetColor(nI) )
			Next nI

		Case cLevel == "3" // Recursos
			nSerie	:=	oGraphic:CreateSerie( 4 )
			oGraphic:l3D := .T.
			cKey     := SHH->(xFilial("SHH")+DTOS(HH_DATA)+HH_CTRAB+HH_RECURSO)
			SH1->(DbSeek(xFilial("SH1")+SHH->HH_RECURSO))
			oGraphic:SetTitle(STR0011  , SH1->H1_DESCRI , CLR_BLACK , A_LEFTJUST , GRP_TITLE ) //"Ocupação dos Recursos por OP"
			While !SHH->(EOF()) .And. SHH->(HH_FILIAL+DTOS(HH_DATA)+HH_CTRAB+HH_RECURSO) == cKey
				oGraphic:Add(nSerie, SHH->HH_USO, AllTrim(SHH->HH_OP) + " - (" + AllTrim(Str(SHH->HH_USO)) + " Hrs)", CLR_BLUE )
				SHH->(DbSkip())
			EndDo

	EndCase
Else
	Do Case
		Case cLevel == "1" // Centros de Trabalho
			nSerie	:=	oGraphic:CreateSerie( 4 )
			oGraphic:l3D := .T.
			cKey     := SHH->(xFilial("SHH")+HH_CTRAB)
			dData    := CToD("  /  /  ")
			nTot     := 0
			SHB->(DbSeek(xFilial("SHB")+SHH->HH_CTRAB))

			While !SHH->(EOF()) .And. SHH->(HH_FILIAL+HH_CTRAB) == cKey
				If dData != SHH->HH_DATA
					dData := SHH->HH_DATA
					nTotDt:= 0
					While !SHH->(EOF()) .And. SHH->(HH_FILIAL+HH_CTRAB) == cKey .And. dData == SHH->HH_DATA
						nTotDt  += SHH->HH_USO
						nTot    += SHH->HH_USO
						SHH->(DbSkip())
					EndDo
					AAdd(aBars,{nTotDt,DToC(dData)})
					Loop
				EndIf
				SHH->(DbSkip())
			EndDo

			oGraphic:SetTitle(STR0012  , AllTrim(SHB->HB_NOME) + " - (" + AllTrim(Str(nTot)) + " Hrs)" , CLR_BLACK , A_LEFTJUST , GRP_TITLE ) //"Ocupação dos Centros de Trabalho por dia"
			For nI := 1 To Len(aBars)
				oGraphic:Add(nSerie, aBars[nI][1], aBars[nI][2] + " - (" + AllTRim(Str(Round((aBars[nI][1]*100/nTot),2))) + " %)", GetColor(nI) )
			Next nI

		Case cLevel == "2" // Data
			nSerie	:=	oGraphic:CreateSerie( 4 )
			oGraphic:l3D := .T.
			oGraphic:SetTitle(STR0013  , DTOC(SHH->HH_DATA) , CLR_BLACK , A_LEFTJUST , GRP_TITLE ) //"Carga diária de recursos"
			cRecurso := ""
			nTot     := SHH->HH_USO
			cKey     := SHH->(xFilial("SHH")+HH_CTRAB+DTOS(HH_DATA))
			While !SHH->(EOF()) .And. SHH->(HH_FILIAL+HH_CTRAB+DTOS(HH_DATA)) == cKey
				If cRecurso != SHH->HH_RECURSO
					cRecurso := SHH->HH_RECURSO
					nTot     := 0
					While !SHH->(EOF()) .And. SHH->(HH_FILIAL+HH_CTRAB+DTOS(HH_DATA)) == cKey .And. cRecurso == SHH->HH_RECURSO
						nTot += SHH->HH_USO
						SHH->(DbSkip())
					EndDo
					SH1->(DbSeek(xFilial("SH1")+cRecurso))
					oGraphic:Add(nSerie, nTot, AllTrim(SH1->H1_DESCRI) + " - (" + AllTrim(Str(nTot)) + " Hrs)", CLR_BLUE )
					Loop
				EndIf
				SHH->(DbSkip())
			EndDo
		Case cLevel == "3" // Recursos
			nSerie	:=	oGraphic:CreateSerie( 4 )
			oGraphic:l3D := .T.
			cKey     := SHH->(xFilial("SHH")+HH_CTRAB+DTOS(HH_DATA)+HH_RECURSO)
			SH1->(DbSeek(xFilial("SH1")+SHH->HH_RECURSO))
			oGraphic:SetTitle(STR0011  , SH1->H1_DESCRI , CLR_BLACK , A_LEFTJUST , GRP_TITLE ) //"Ocupação dos Recursos por OP"
			While !SHH->(EOF()) .And. SHH->(HH_FILIAL+HH_CTRAB+DTOS(HH_DATA)+HH_RECURSO) == cKey
				oGraphic:Add(nSerie, SHH->HH_USO, AllTrim(SHH->HH_OP) + " - (" + AllTrim(Str(SHH->HH_USO)) + " Hrs)", CLR_BLUE )
				SHH->(DbSkip())
			EndDo

	EndCase

EndIf
IF !lAutoMacao
	oGraphic:Refresh()
ENDIF
// Adiciona o grafico atual no agraph
AAdd(aGraph,{cNewCarg,oGraphic})
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³C020Leg   º Autor ³ Guilherme C. Leal  º Data ³  02/14/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Legenda.                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function C020Leg()
BrwLegenda(STR0005, STR0014,{			{cBmpDtOk   ,STR0015}	,; //"	Legenda"###"Tipos"###"	Data/Centro de Trabalho"
										{cBmpDtOL   ,STR0016}	,; //"	Sobrecarga"
										{cBmpRec    ,STR0017}	,; //"	Recurso"
										{cBmpOP     ,STR0018}	}) //"	Ordem de Produção"
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GetColor ³ Autor ³ Felipe Nunes de Toledo³ Data ³ 19/04/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao de cores de forma aleatoria                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GetColor(nSeed)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nSeed = Semente de geracao da cor aleatoria                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nRet = Numeracao ref. a uma cor aletoria                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ P10                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GetColor(nSeed)
Local nRet 	  := 0
Local nAleat  := 1
Local aColor  := {CLR_BLUE,CLR_GREEN,CLR_CYAN,CLR_RED,CLR_MAGENTA,CLR_BROWN,CLR_GRAY,CLR_HBLUE,CLR_HGRAY,;
			      CLR_HGREEN,CLR_HCYAN,CLR_HRED,CLR_HMAGENTA,CLR_YELLOW,CLR_WHITE,CLR_BLACK}

nAleat  := Aleatorio(Len(aColor),nSeed) 
nRet    := aColor[If(nAleat>0, nAleat, 1)]

Return nRet
