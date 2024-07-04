#Include "TmsA040.ch"
#Include "Protheus.ch"

#DEFINE CODPASCMP 1
#DEFINE VALPASCMP 2
#DEFINE TIPVALCMP 3
#DEFINE LOTEDICMP 4
#DEFINE FRTCMPCOT 7

Static lTM040CUB	:= ExistBlock("TM040CUB")	//-- Pto que permite a alteração do Peso Cubado, antes do calculo do Frete
Static lTM040GRV	:= ExistBlock("TM040GRV")
Static lTM040FCB	:= ExistBlock("TM040FCB")	//-- Ponto de entrada para alterar Fator de Cubagem.

Static lTM040BLQ	:= ExistBlock("TM040BLQ")	//-- Ponto de entrada para verificar bloqueio da cotação
Static lTM040COL	:= ExistBlock("TM040COL")	//-- Ponto de entrada para atribuir valores na solicitação de coleta
Static lTM040APR	:= ExistBlock("TM040APR")	//-- Ponto de entrada para verificar aprovacao da cotacao
Static lTM040Tok	:= ExistBlock("TM040TOk")
Static lTM040Atz	:= ExistBlock("TM040ATZ")	//-- Ponto de entrada no final do calculo da cotação.

Static lTM040Alt	:= ExistBlock("TM040ALT")	//-- Altera Validacoes Padroes do Sistema
Static lTMA040FOB	:= ExistBlock("TMA040FOB")	//-- Conceito de FOB dirigido
Static lTM040ICM	:= ExistBlock("TM040ICM")	//-- Ponto que permite alterar a Aliquota de ICMS
Static lTM040PRD	:= ExistBlock("TM040PRD")	//-- Ponto que permite alterar o produto de imposto
Static lTM040BICM	:= ExistBlock("TM040BICM")	//-- Alteração da Base de ICMS
Static lTM040DSC	:= ExistBlock("TM040DSC")	//-- Validação na Rotina de Descontos
Static lTM040TES	:= ExistBlock("TM040TES")	//-- Altera codigo da TES
Static lTM040LIB	:= ExistBlock("TM040LIB")	//-- Liberacao da cotacao

Static nKm			:= 0
Static cIncIss	:= ''
Static _cCdrOri	:= ''
Static _cCdrDes	:= ''
Static _cServic	:= ''
Static _cDistIV	:= ''
Static _cContrib	:= ''
Static _cCliDes	:= ''
Static cDT4CLIREM  := ''
Static cDT4LOJREM  := ''
Static cDT4CLIDES  := ''
Static cDT4LOJDES  := ''
Static cDT4CLIDEV  := ''
Static cDT4LOJDEV  := ''
Static lValidSrv	 := .T.
Static lPrcProd
Static aPosicione	:= {}

Static lTmsa029   	:= FindFunction("TMSA029USE") //.And. Tmsa029Use("TMSA040")
Static cMV_TMSINCO	:= SuperGetMv("MV_TMSINCO",.F.,"")
Static cMV_TMSRRE := SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza

Static nRadioAnt  := 0
Static nVlrFecAnt := 0
Static nDesconAnt := 0
Static nAcrescAnt := 0
Static aFrtFecAnt := {}

Static aAutoCab	:= {}
Static aAutoItens	:= {}
Static aAutoCuba	:= {}
Static aAutoVInf	:= {}
Static aAutoTpVei	:= {}
Static cCadastro	:= STR0001 //'Cotacao de Frete'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA040  ³ Autor ³ Alex Egydio           ³ Data ³26.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cotacao de Frete                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Cabecalho da Cotacao de Frete (DT4)                ³±±
±±³          ³ ExpA2 - aCols de Peso Cubado (DTE)                         ³±±
±±³          ³ ExpN1 - Opcao Rotina Automatica (Incl./Alt./Exc./...)      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA040(xAutoCab, xAutoItens, nOpcAuto, cDDDSol, cTelSol, xAutoCuba, XAutoVInf, xAutoTpVei, cCodSol)

//-- Define variaveis
Local cQuery		:= ""
Local aCores		:= {}
Local aSetKey		:= {}

Private l040Auto	:= xAutoCab <> Nil
Private l460Auto	:= xAutoCab <> Nil
Private aRotina		:= {}

Default xAutoItens	:= {}
Default xAutoCab	:= {}
Default xAutoCuba	:= {}
Default XAutoVInf	:= {}
Default xAutoTpVei	:= {}
Default nOpcAuto	:= 3
Default cCodSol		:= ''
Default cDDDSol		:= ''
Default cTelSol		:= ''

aRotina := MenuDef(!Empty(cCodSol)) 

//-- Permite imprimir a coleta apos a inclusao da coleta.
AAdd( aSetKey ,{VK_F12 ,{ || Pergunte("TMA460" ,.T.) } } )

AAdd( aCores ,{"DT4_STATUS=='1'" ,'BR_AMARELO'	})	// Pendente
AAdd( aCores ,{"DT4_STATUS=='2'" ,'BR_VERMELHO'	})	// Bloqueada
AAdd( aCores ,{"DT4_STATUS=='3'" ,'BR_VERDE'	})	// Aprovada
AAdd( aCores ,{"DT4_STATUS=='4'" ,'BR_AZUL'		})	// Encerrada
AAdd( aCores ,{"DT4_STATUS=='5'" ,'BR_BRANCO'	})	// Bloqueada Div. Produtos/RRE
AAdd( aCores ,{"DT4_STATUS=='9'" ,'BR_PRETO'	})	// Cancelada

//--Forca a criacao da tabela DUM que sera utilizada na
//Solicitacao de Coleta chamando atraves da Cotacao de Frete
DbSelectArea("DUM")

//-- Endereca a funcao de BROWSE
If !l040Auto
	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)
	//-- Filtro do Browse por Codigo Solicitante. Ex: Utilizado na integração do TMK x TMS.
	If !Empty(cCodSol)
		cQuery := "DT4_CODSOL = '" + Padr( cCodSol, TamSX3('DT4_CODSOL')[1] ) + "'"
	Else
		//-- Verifica Validade das cotacoes
		aAreaDT4 := DT4->(GetArea())
		DT4->(DbSetOrder(7)) //DT4_FILIAL+DT4_FILORI+DT4_STATUS+DTOS(DT4_PRZVAL)
		If DT4->(MsSeek(xFilial("DT4")+cFilAnt+"1"))
			If DT4->DT4_PRZVAL < dDataBase
				If MsgYesNo( STR0052 ) // "Existem cotacoes pendentes vencidas, deseja cancelar todas ?"
					//-- Processa Canceladas
					MsgRun( STR0053 , STR0054 ,{|| TmsA040Venc() } ) // "Cancelando cotacoes vencidas..." ### "Aguarde..."
				EndIf
			EndIf
		EndIf
		RestArea( aAreaDT4 )
	EndIf
	//-- Endereca a funcao de BROWSE
	mBrowse( 6,1,22,75,'DT4',,,,,,aCores,,,,,,,,cQuery)
	//-- Finaliza Teclas de Atalhos
	TmsKeyOff(aSetKey)
Else
	lMsHelpAuto := .T.
	aAutoCab    := xAutoCab
	aAutoItens  := xAutoItens
	aAutoCuba   := xAutoCuba
	aAutoVInf   := XAutoVInf
	aAutoTpVei  := xAutoTpVei
	MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"DT4")
EndIf
//-- Devolve os indices padroes do SIGA
RetIndex("DT4")

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA040Mnt³ Autor ³ Alex Egydio           ³ Data ³26.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao de cotacoes de frete                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±³          ³ ExpA1 = Este parametro eh utilizado pela tecnologia        ³±±
±±³          ³ ExpA2 = Cotacao por Agendamento (Carga Fechada)            ³±±
±±³          ³ ExpL1 = Executado via Rotina Automatica                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA040Mnt( cAlias, nReg, nOpcx, aVarAux, aCotAge, cSolicit, cCotacao, lMostra, cDDDSol, cTelSol, cNumAtd, cIteAtd, cCodProd, cDescProd, cCodSol, lMntBase )

Local aAreaAnt		:= GetArea()
Local nCntFor		:= 0
Local lTMSCFec		:= TMSCFec() // Carga Fechada
Local nPosProd		:= 0
Local nPosDesc		:= 0
//-- Controle de dimensoes de objetos
Local aSize			:= {}
Local aObjects		:= {}
Local aInfo			:= {}
Local aPosObj		:= {}
//-- Ponto de entrada para adicionar botoes na enchoicebar
Local aSomaButtons	:={}
//-- MSDialog
Local oDlgEsp
//-- EnchoiceBar
Local aButtons		:= {}
Local nOpca			:= 0
//-- Enchoice
Local aVisual		:= {}
//-- Folder
Local aPages		:= {'HEADER'}
Local aTitles		:= { STR0015 } //"Total do Frete"
Local oFolder
Local lRet			:= .T.
Local AColsAux		:= {}
Local nOpcao		:= 0
Local lTM040GRCOL	:= ExistBlock("TM040GRCOL")	//-- Ponto de Entrada para gerar ou nao solicitacao de Coleta
Local lTM040VLD		:= ExistBlock("TM040VLD")	//-- Validacao na Cotacao de Frete
Local lTM040COP		:= ExistBlock("TM040COP")	//-- Ponto de entrada para que o usuario possa limpar os campos desejados na hora da copia
Local lTM040CFA		:= ExistBlock("TM040CFA")	//-- Ponto de entrada para cotacoes de frete aprovadas!
Local lContinua		:= .T.
Local aRotOld		:= {}
//--Ponto de Entrada para desabilitar os botoes
Local aDelButtons	:= {}

Local cNumCot		:= ''
Local cTipoCli		:= ""

Local aHeaderP		:= {} // Utilizado pela rotina de copia
Local aColsProd		:= {} // Utilizado pela rotina de copia
Local cProdCp		:= ""
Local cNumSol		:= ""
Local aRotina050	:= {}
Local aNoFldsDTE    := {"DTE_FILORI","DTE_CLIREM","DTE_LOJREM", "DTE_CODPRO", "DTE_ITESOL" , "DTE_NUMCOT", "DTE_NUMNFC", "DTE_SERNFC" , "DTE_NUMSOL"  }
Local oDTEStru      := FwFormStruct(2,"DTE")
Local nIncDTE       := 1
Local lGrava        := .T.

If Type("l040Auto") == "U"
	Private l040Auto := .F.
	Private l460Auto := .F.
	Private aRotina  := MenuDef(!Empty(cCodSol))
EndIf

//-- Solicitacao de Coleta / Cotacao utilizado na pesquisa do Tipo de Veiculos.
Default cSolicit	:= Nil
Default cCotacao	:= Nil
Default lMostra		:= .T.
Default cCodSol		:= "" //Informação proveniente de integração (rotina automática). Ex: Integração TMK x TMS
Default cDDDSol		:= "" //Informação proveniente de integração (rotina automática). Ex: Integração TMK x TMS
Default cTelSol		:= "" //Informação proveniente de integração (rotina automática). Ex: Integração TMK x TMS
Default cCodProd	:= "" //Informação proveniente de integração (rotina automática). Ex: Integração TMK x TMS
Default cDescProd	:= "" //Informação proveniente de integração (rotina automática). Ex: Integração TMK x TMS
Default lMntBase    := .F.

//-- Rotina executada via integração. Não derivada da rotina principal (TMSA040), por isso a necessidade de carregar o aRotina.
If !Empty(cCodSol)
	l040Auto := .F.
	aRotina  := {}
	aRotina  := MenuDef()
EndIf

//-- Opcao do Browser
nOpcx := aRotina[nOpcx,4]

//--Monta aRotina do TMSA040
If IsInCallStack('TMSA050')
	aRotina050	:= aRotina
	aRotina 	:= {}
	aRotina 	:= MenuDef()
EndIf

//-- Variaveis de controle geral
Private aContrt		:= {}
Private aFrete		:= {}
Private aFrtOri		:= {}
Private aMemos		:= {}
Private aHeadDTE	:= {}						//-- Digitacao da cubagem
Private aCubagem	:= {}						//-- Digitacao da cubagem
Private aValInf		:= {}
Private aValInfBack	:= {}
Private aDesconto	:= {}
Private lAprova		:= ( nOpcx == 6 )
Private lCancela	:= ( nOpcx == 5 )
Private nFatCub		:= 0
Private nTValPas	:= 0
Private nTValImp	:= 0
Private nTValTot	:= 0
Private oTValPas
Private oTValImp
Private oTValTot
//-- Enchoice
Private aAltera		:= {}
Private aTela[0][0]
Private aGets[0]
Private oEnch
//-- GetDados
Private aHeader		:= {}
Private aCols		:= {}
Private aColsBack 	:= {}
Private oGetD
//-- GetDados de Tipos de Veiculo
Private aColsDVTBack:= {}
Private aColsDVT	:= {}
Private aHeaderDVT	:= {}
//-- Controle de coleta
Private lColeta		:= .F. //-- Indica se solicita coleta ou nao

Private lCliGen		:= .T.
Private cCliDev		:= ""
Private cLojDev		:= ""
Private aSetKey		:= {}
Private lAgend		:= .F.
Private lMostraTela	:= lMostra
Private lTMSA040	:= .F.
Private lCopia		:= .F.

//-- Frete por Pais
Private aFrtPais	:= {}
//-- Frete (CIF/FOB) Incoterm DAF
Private aFrtDAF		:= {}

If IsBlind()
	nOpca := 1
EndIf

// Liberar
If nOpcx == 7 .AND. FindFunction("TMSA029USE") .And. Tmsa029Use("TMSA040")
	Help("",1,'TMSA04058',/*Titulo*/, STR0117 + Space(20) /*Mensagem*/,1,0) //-- Utilize a Rotina de Liberação TMSA029.
	Return( nOpca )		
EndIf
If aRotina[nOpcx][4] == 9 //-- Copia
	nOpcx  := 4
	lCopia := .T.
EndIf

//-- Cotacao por Agendamento (Carga Fechada)
If ValType(aCotAge) <> "A"
	aCotAge := {}
Else
	lAgend  := .T.
EndIf

// Ponto de entrada para validar alteracao/exclusao
If nOpcx <> 3
	If lTM040VLD
		lContinua := ExecBlock('TM040VLD',.F.,.F.,{nOpcx})
		If ValType(lContinua) <> "L"
			lContinua := .T.
		EndIf
	EndIf
	If !lContinua
		Return( nOpca )
	EndIf
EndIf

//-- Configura variaveis da Enchoice
RegToMemory(cAlias,nOpcx==3)

If	!TmsA040Ini(aVisual, cAlias, nOpcx, lCopia)
	Return( nOpca )
EndIf

cNumCot := M->DT4_NUMCOT
cNumSol := M->DT4_NUMSOL

If lCopia
	M->DT4_NUMCOT := CriaVar("DT4_NUMCOT",.T.)
	M->DT4_USER   := CriaVar("DT4_USER",.T.)  
	M->DT4_DATCOT := dDataBase
	M->DT4_HORCOT := StrTran(Left(Time(),5),":","")
	
	//--Na copia, traz o tipo do cliente do destinatario
	If !Empty(M->DT4_CLIDES) .And. !Empty(M->DT4_LOJDES)
		cTipoCli := MyPosicione("SA1",1,xFilial("SA1") + M->DT4_CLIDES + M->DT4_LOJDES,"A1_PESSOA")
		If !Empty(cTipoCli) .And. Type("M->DT4_PESSOA") <> "U"
			M->DT4_PESSOA := If( cTipoCli == "F","1","2")
		EndIf
	EndIf

	cNumSol := DT4->DT4_NUMSOL
EndIf

//-- Execucao do ponto de entrada para a limpeza dos campos desejados pelo usuario.
If lTM040COP .And. lCopia
	ExecBlock("TM040COP",.F.,.F.)
EndIf

//-- Botoes da EnchoiceBar
AAdd( aSetKey	,{ VK_F4    ,{|| TmsA040Pm3(nOpcx,cNumCot) } } )
AAdd( aButtons	,{'BALANCA' ,{|| TmsA040Pm3(nOpcx,cNumCot) } , STR0011, STR0011 })  //'Peso Cubado - <F4>'
If nOpcx == 3 .Or. nOpcx == 4
	AAdd( aSetKey  ,{ VK_F5   ,{|| TmsA040Atz()} } )
	AAdd( aButtons ,{'PRECO'  ,{|| TmsA040Atz()} , STR0012 , STR0012 })  //'Atualiza a composicao do frete - <F5>'
	AAdd( aSetKey  ,{ VK_F6   ,{|| TmsA040Dsc()} } )
	AAdd( aButtons ,{'BUDGET' ,{|| TMSA040Dsc()} , STR0066 , STR0066 })  //'Valor Fechado - <F6>'

	If nOpcx == 3
		AAdd( aButtons ,{'CLOCK01' ,{|| TMSPrvEnt(,,,,M->DT4_TIPTRA,M->DT4_CLIDEV,M->DT4_LOJDEV,M->DT4_CDRORI,M->DT4_CDRDES) } , STR0095 , STR0095 })  // 'Previsao Entrega - <F12>'
	EndIf

EndIf
AAdd( aSetKey  ,{ VK_F7    ,{|| TmsA040VFrt() } } )
AAdd( aButtons ,{'BUDGET'  ,{|| TmsA040VFrt() } , STR0068 , STR0068 }) //'Composicao do frete - <F7>'
AAdd( aSetKey  ,{ VK_F8    ,{|| TmsA040Cot()  } } )
AAdd( aButtons ,{'SDUPROP' ,{|| TmsA040Cot()  } , STR0070 , STR0070 }) //'Cotacoes Realizadas - <F8>'
AAdd( aSetKey  ,{ VK_F9    ,{|| TmsA040Tab()  } } )
AAdd( aButtons ,{'BMPORD'  ,{|| TmsA040Tab()  } , STR0072 , STR0072 }) //'Tabela de Frete - <F9>'
AAdd( aSetKey  ,{ VK_F10   ,{|| A040ValInf(If(lAgend,2,nOpcx),GdFieldGet('DVF_CODPRO',n), cNumCot) } } )
AAdd( aButtons ,{'COMPTITL',{|| A040ValInf(If(lAgend,2,nOpcx),GdFieldGet('DVF_CODPRO',n), cNumCot) }, STR0074 , STR0074 }) //'Valor Informado - <F10>'

If nOpcx == 4
	TmsValInf(aValInf,'3',M->DT4_FILORI,cNumCot,,,,,,,,,,nOpcx,,,,,M->DT4_CODNEG)
EndIf

//-- Verifica se o Parametro MV_TMSCFEC (Carga Fechada) esta' habilitado
If lTMSCFec
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Array contendo os Tipos de Veiculo utilizados na Cotacao            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcao := nOpcx
	If nOpcao == 6 //-- Aprovacao
		nOpcao := 4
	EndIf
	If nOpcx <> 3
		a460VerTpVei(nOpcao,M->DT4_FILORI,cNumSol,cNumCot, StrZero(1,Len(DVT->DVT_ORIGEM)))
	EndIf
	AAdd( aSetKey  ,{ VK_F11    ,{|| A460TipVei( nOpcao, cNumSol, cNumCot, lAgend ) } }  )
	AAdd( aButtons ,{'CARGANEW' ,{|| A460TipVei( nOpcao, cNumSol, cNumCot, lAgend )}, STR0076 , STR0076 }) //'Tipos de Veiculo - <F11>'
EndIf

AAdd( aSetKey  ,{ VK_F12 ,{||A040FPais(nOpcx)} })
AAdd( aButtons ,{'WEB'   ,{||A040FPais(nOpcx)} ,"Frete por País" ,"Frete por País" })
AAdd( aButtons ,{'EDIT'  ,{||A040FDAF(nOpcx)}  ,"Frete CIF/FOB"  ,"Frete CIF/FOB"  })

// Ponto de entrada para incluir botao na enchoicebar
If (ExistBlock("TM040BUT"))
	aSomaButtons:=ExecBlock("TM040BUT",.F.,.F.,{nOpcx})
	If ValType(aSomaButtons) == "A"
		For nCntFor := 1 To Len(aSomaButtons)
			AAdd(aButtons,aSomaButtons[nCntFor])
		Next
	EndIf
EndIf

//Ponto de Entrada para desabilitar botoes na enchoice
If (ExistBlock("TM040DSB"))
	aDelButtons := ExecBlock("TM040DSB",.F.,.F.,{aButtons,nOpcx})
	If ValType(aDelButtons) == "A"
		aButtons := aDelButtons
	EndIf
EndIf

//-- Inicializa Cotacao por Agendamento (Carga Fechada)
If !Empty(aCotAge)
	If lTM040CFA
		ExecBlock('TM040CFA',.F.,.F.)
	EndIf
	If !TMSAF05Ini(aCotAge,nOpcx,lMntBase)
		Return( nOpca )
	EndIf
	//-- Armazena as aCols para verificar a necessidade de recalcular o frete.
	aColsBack    := AClone(ACols)
	aValInfBack  := AClone(aValInf)
	aColsDVTBack := AClone(aColsDVT)
	AColsAux     := AClone(ACols)
	//-- Inicializa todas as linhas do ACols como nao deletado, devido a falha na GetDados
	For nCntFor	:= 1 To Len(ACols)
		ACols[nCntFor,Len(aHeader)+1] := .F.
	Next nCntFor
ElseIf nOpcx <> 2 .And. nOpcx <> 3 .And. nOpcx <> 5
	//-- Armazena as aCols para verificar a necessidade de recalcular o frete.
	aColsBack    := AClone(ACols)
	aValInfBack  := AClone(aValInf)
	aColsDVTBack := AClone(aColsDVT)
EndIf

//-- Atualiza variaveis de utilizadas na atualizacao da cotacao de frete.
If nOpcx == 4
	TmsA040VAtu()
EndIf

If lMostraTela .And. !l040Auto
	If !Empty(cCodSol) .And. !Empty(cNumAtd) .And. !Empty(cIteAtd)

		nPosProd      := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DVF_CODPRO'})
		nPosDesc      := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DVF_DESPRO'})

		M->DT4_CODSOL := Padr( cCodSol, TamSX3('DT4_CODSOL')[1] )
		M->DT4_DDD    := Padr( cDDDSol, TamSX3('DT4_DDD')[1] )
		M->DT4_TEL    := Padr( cTelSol, TamSX3('DT4_TEL')[1] )
		M->DT4_NUMATD := cNumAtd
		M->DT4_ITEATD := cIteAtd

		aCols[1][nPosProd] := cCodProd
		aCols[1][nPosDesc] := cDescProd
	EndIf

	If Len(aCotAge) > 0
		TmsA040Atz()
	EndIf
	//-- remonta a aRotina qdo chamada pelo cadastro de notas fiscais
	If Left(FunName(1),7) == "TMSA050"
		aRotOld:= aClone(aRotina)
		aRotina:= {	{ STR0002 ,'AxPesqui'   ,0 ,1},; //'Pesquisar'
					{ STR0003 ,'TMSA040Mnt' ,0 ,2},; //'Visualizar'
					{ STR0004 ,'TMSA040Mnt' ,0 ,3},; //'Incluir'
					{ STR0005 ,'TMSA040Mnt' ,0 ,4},; //'Alterar'
					{ STR0006 ,'TMSA040Mnt' ,0 ,5},; //'Cancelar'
					{ STR0007 ,'TMSA040Mnt' ,0 ,6},; //'Aprovar'
					{ STR0008 ,'TMSA040Mnt' ,0 ,7},; //'Liberar'
					{ STR0056 ,'TMSA040Ret' ,0 ,8},; //'Retomar'
					{ STR0051 ,'ExecBlock("RtmsR10",.F.,.F.,{DT4->DT4_FILORI,DT4->DT4_NUMCOT})',0,8},; //'Imprime Cotacao'
					{ STR0009 ,'TMSA040Leg' ,0 ,9} } //'Legenda'
	EndIf

	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)

	//-- Calcula as dimensoes dos objetos
	aSize  := MsAdvSize(.T.)

	AAdd( aObjects ,{ 100 ,50 ,.T. ,.T. } )
	AAdd( aObjects ,{ 100 ,35 ,.T. ,.T. } )
	AAdd( aObjects ,{ 100 ,15 ,.T. ,.T. } )
	
	aInfo   := { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
	
	DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	//-- Monta a Enchoice DT4 - Header da cotacao de frete
	oEnch := MsMGet():New( cAlias, nReg, Iif( nOpcx==5, 4,Iif( nOpcx==7 .Or. lAgend, 2, nOpcx ) ),,,, aVisual, aPosObj[1], aAltera, 3, , , , , ,.T. )
	//-- Monta a Getdados DVF - Itens da cotacao de frete
	//          MsGetDados(                nT ,               nL,             nB,               nR,                                          nOpc,    cLinhaOk,       cTudoOk,    cIniCpos,lDeleta,    aAlter,nFreeze,lEmpty,                      nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
	oGetD := MSGetDados():New(aPosObj[ 2, 1 ], aPosObj[ 2, 2 ],aPosObj[ 2, 3 ], aPosObj[ 2, 4 ], Iif( nOpcx==5, 4,Iif( nOpcx==7, 2, nOpcx ) ),'TmsA040LinOk','AllWaysTrue','+DVF_ITEM',    .T.,         ,       ,      ,Iif(GetMV('MV_PRDDIV'),,1),        ,         ,       ,      ,    )
	If	lAprova .Or. lCancela .Or. lAgend
		oGetD:oBrowse:bAdd    := { || .f. }     // Nao Permite a inclusao de Linhas
		oGetD:oBrowse:bDelete := { || .f. }     // Nao Permite a deletar Linhas
		oGetD:oBrowse:AAlter  := {}             // Nao Permite a alteracao de campo
	EndIf
	//-- Atualiza ACols corrigindo a falha na GetDados
	If(Len(AColsAux)>0,ACols := AClone(AColsAux),.T.)
	oGetD:Refresh(.T.)
	
	//-- Monta o Objeto Folder
	oFolder:=TFolder():New( aPosObj[3,1], aPosObj[3,2], aTitles, aPages, oDlgEsp,,,,.T.,.T.,aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1])
	
	For nCntFor := 1 To Len( oFolder:aDialogs )
		oFolder:aDialogs[ nCntFor ]:oFont := oDlgEsp:oFont
	Next
	
	@ 5,10 SAY STR0078 SIZE 20,9 OF oFolder:aDialogs[1] PIXEL //'Frete'
	@ 5,30 MSGET oTValPas VAR nTValPas Picture PesqPict('DT8','DT8_VALPAS') WHEN .F. SIZE 70,9 OF oFolder:aDialogs[1] PIXEL
	
	@ 5,130 SAY STR0018 SIZE 20,9 OF oFolder:aDialogs[1] PIXEL //'Imposto'
	@ 5,160 MSGET oTValImp VAR nTValImp Picture PesqPict('DT8','DT8_VALIMP') WHEN .F. SIZE 70,9 OF oFolder:aDialogs[1] PIXEL
	
	@ 5,270 SAY STR0078 + ' + ' + STR0018 SIZE 50,9 OF oFolder:aDialogs[1] PIXEL //Frete + Imposto
	@ 5,320 MSGET oTValTot VAR nTValTot Picture PesqPict('DT8','DT8_VALTOT') WHEN .F. SIZE 70,9 OF oFolder:aDialogs[1] PIXEL
	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| Iif( TmsA040TOk(nOpcx),(nOpca:= 1, lValidSrv:= .F.,oDlgEsp:End()), nOpca:=0 ) }, {|| oDlgEsp:End() },, aButtons)

	//-- Restaura aRotina original
	If !Empty(aRotOld)
		aRotina := aClone(aRotOld)
	EndIf

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validando dados para rotina automatica                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aCotAge) //-- Agendamento nao necessita passar pela validacao da rotina automatica.
		nOpca := 1
	Else
		If	EnchAuto(cAlias,aAutoCab,,nOpcx,aVisual,{|| Obrigatorio(aGets,aTela)}) .And. ;
			MsGetDAuto(aAutoItens ,,{|| TMSA040TOk(nOpcx)},aAutoCab,nOpcx)
			nOpca := 1
			If Len(aAutoCuba) > 0
				TmsA040Pm3(3)
			EndIf
			If Len(aAutoVInf) > 0
				cCodPro	:= GdFieldGet('DVF_CODPRO',n)
				TmsValInf(aValInf,'1',M->DT4_FILORI,cNumCot,,,,,,,,,cCodPro,nOpcx,,/*cTabFre*/,/*cTipTab*/,aAutoVInf,M->DT4_CODNEG)
			EndIf
			If Len(aAutoTpVei) > 0
				A460TipVei(nOpcx, cNumSol, cNumCot, lAgend)
			EndIf
			lGrava := TmsA040Atz()
		EndIf
	EndIf
EndIf


//-- Apos confirmar (ou for possível gerar o cálculo via automação)
If	nOpca == 1 .And. lGrava 
	If	nOpcx != 2
		If	nOpcx == 5				//--  Cancelar
			TmsA040Can()
		ElseIf nOpcx == 6			//--  Aprovar
			//-- O Objetivo deste Ponto de Entrada e' verificar se a Cotacao de Frete 
			//-- devera' gerar ou nao Solicitacao de Coleta
			If lTM040GRCOL
				lRet := ExecBlock('TM040GRCOL',.F.,.F.,{nOpcx})
				If ValType(lRet) <> "L"
					lRet := .T.
				EndIf
			EndIf
			If lRet
				If l040Auto .Or. !Empty(M->DT4_NUMSOL)
					lColeta := .T.
				ElseIf !lAgend .And. Empty(M->DT4_NUMSOL)
					lColeta := Aviso( STR0039, STR0040 ,{STR0029,STR0030}, 2, '' ) == 1 //'Atencao'###'Deseja Solicitar Coleta ?'###'Sim'###'Nao'
				EndIf
			EndIf
			TmsA040Apr(nOpcx)
		ElseIf nOpcx == 7			//--  Liberar
			// Define Se Usa Novo Modelo De Bloqueio Tab. DDU
			If FindFunction("TMSA029USE") .And. Tmsa029Use("TMSA040")
				Help("",1,'TMSA04058',/*Titulo*/, STR0117 + Space(20) /*Mensagem*/,1,0) //-- Utilize a Rotina de Liberação TMSA029.
			Else
				TmsA040Lib()
			EndIf
		Else
			If	! Empty( M->DT4_CLIREM ) .And. ! Empty( M->DT4_LOJREM ) .And.;
				! Empty( M->DT4_CLIDES ) .And. ! Empty( M->DT4_LOJDES ) .And.;
				! Empty( M->DT4_CLIDEV ) .And. ! Empty( M->DT4_LOJDEV ) .And.;
				! Empty( aContrt )
				//-- O Objetivo deste Ponto de Entrada e' verificar se a Cotacao de Frete 
				//-- devera' gerar ou nao Solicitacao de Coleta
				If lTM040GRCOL
					lRet := ExecBlock('TM040GRCOL',.F.,.F.,{nOpcx})
					If ValType(lRet) <> "L"
						lRet := .T.
					EndIf
				EndIf
				If lRet
					If l040Auto .Or. !Empty(M->DT4_NUMSOL)
						lColeta := .T.
					ElseIf !lAgend .And. Empty(M->DT4_NUMSOL)
						lColeta := Aviso( STR0039, STR0040 ,{STR0029,STR0030}, 2, '' ) == 1 //'Atencao'###'Deseja Solicitar Coleta ?'###'Sim'###'Nao'
					EndIf
				EndIf
			EndIf
			If M->DT4_TIPTRA == StrZero(4,Len(DT4->DT4_TIPTRA)) //-- Rodoviario Internacional
				//-- Frete por Pais
				A040FPais(nOpcx,.T.)
				//-- Frete CIF/FOB
				A040FDAF(nOpcx,.T.)
			EndIf

			If lCopia .And. Len(aCubagem) <= 0
				If	Empty(aHeadDTE)

					While nIncDTE <= Len(oDTEStru:aFields)
						If	Ascan(aNoFldsDTE, { |x| x == AllTrim(oDTEStru:aFields[nIncDTE,1]) } ) == 0 
							AAdd(	aHeadDTE, { AllTrim( oDTEStru:aFields[nIncDTE,3])              ,; //| Titulo do Campo
												AllTrim( oDTEStru:aFields[nIncDTE,1])              ,; //| X3_Campo
										     GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_PICTURE"),; //| picture
											 GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_TAMANHO"),; //| tamanho
											 GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_DECIMAL"),; //| decimal
											 GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_VALID")  ,; //| valid
                        					 GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_USADO")  ,; //| usado
											 GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_TIPO")   ,; //| tipo
											 GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_ARQUIVO"),; //| arquivo
											 GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_CONTEXT"),; //| context 
											 GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_CBOX")   ,; //| BOX
											 GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_RELACAO")}) //| Relacao/Ini.Padrao
						EndIf
						nIncDTE++
					EndDo
				EndIf

				aHeaderP:=AClone(aHeadDTE)

				DTE->(DbSetOrder(2))
				//-- Peso Cubado Informado na Cotacao de Frete
				If	DTE->( MsSeek( cSeek := xFilial('DTE') + M->DT4_FILORI + cNumCot ) )
					While DTE->( ! Eof() .And. DTE->DTE_FILIAL + DTE->DTE_FILORI + DTE->DTE_NUMCOT  == cSeek )
						cProdCp := DTE->DTE_CODPRO
						While DTE->( ! Eof() .And. DTE->DTE_FILIAL + DTE->DTE_FILORI + DTE->DTE_NUMCOT + DTE->DTE_CODPRO  == cSeek+cProdCp )
							//-- Preenche o aColsProd com a cubagem de mercadorias.
							AAdd( aColsProd, Array( Len( aHeaderP ) + 1 ) )
							For nCntFor := 1 To Len( aHeaderP )
								aColsProd[ Len( aColsProd ), nCntFor ] := DTE->( FieldGet( FieldPos( aHeaderP[ nCntFor, 2 ] ) ) )
							Next
							aColsProd[ Len( aColsProd ), Len( aHeaderP ) + 1 ] := .F.
							DTE->( DbSkip() )
						Enddo
						AAdd(aCubagem,{cProdCp,AClone(aColsProd)}) // Copiando o Produto Anterior
						DTE->(DbSkip())
					EndDo
				EndIf

			EndIf
			TmsA040Grv( nOpcx, cSolicit, cCotacao )
			TmsGrvInf(aValInf,Iif(IsInCallStack("TMSAF76") .And. !IsInCallStack("TMSF76VIA"),'2','1'),M->DT4_FILORI,M->DT4_NUMCOT,,,,,,,,,,nOpcx)
		EndIf
	EndIf
Else
	If	__lSX8
		RollBackSX8()
	EndIf
EndIf

RestArea( aAreaAnt )

//-- Atualiza tela do lote de notas fiscais quando vindo de lá
If Type("oBrowseUp") = "O" 
	If FindFunction("TMSA170Ref") .And. IsInCallStack('TMSA170')
		TMSA170Ref()
	EndIf
EndIf

//--Retorna aRotina do TMSA050
If IsInCallStack('TMSA050')
    aRotina := aRotina050
EndIf
//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

nRadioAnt  := 0
nVlrFecAnt := 0
nDesconAnt := 0
nAcrescAnt := 0
aFrtFecAnt := {}

Return( nOpca )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA040Leg³ Autor ³ Alex Egydio           ³ Data ³16.10.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a legenda do status da cotacao.                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA040Leg()

BrwLegenda( cCadastro	,STR0020  ,;	//'Status'
	{	{ 'BR_AMARELO'	,STR0021 },;	//'Pendente'
		{ 'BR_VERMELHO'	,STR0022 },;	//'Bloqueada'
		{ 'BR_BRANCO'  	,STR0106 },;	//'Divergência De Produtos / RRE'
		{ 'BR_VERDE'	,STR0023 },;	//'Aprovada'
		{ 'BR_AZUL'		,STR0024 },;	//'Encerrada'
		{ 'BR_PRETO'	,STR0025 }})	//'Cancelada'

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA040Ini³ Autor ³ Alex Egydio           ³ Data ³16.10.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa as Variaveis                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Campos Visualizados na Enchoice                    ³±±
±±³          ³ ExpC1 - Alias                                              ³±± 
±±³          ³ ExpN1 - Opcao Selecionada                                  ³±±
±±³          ³ ExpL1 - Opcao para copiar uma cotacao de frete ja existente³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA040Ini(aVisual, cAlias, nOpcx, lCopia)

Local cCliGen  := GetMV("MV_CLIGEN")
Local nVldCot  := GetMV("MV_VLDCOT",,0)
Local aAreaDF1 := {}
Local lRet     := .F.
Local lRetPE   := .F.
Local oGenStru := FwFormStruct(2,cAlias)
Local nIncStru := 1

Default lCopia := .F.

//-- Avalia se pode efetua manutencao na cotacao
If	Empty( cCliGen )
	Help(' ', 1, 'TMSA04020' )	//-- Informe o codigo/loja do cliente generico no parametro MV_CLIGEN
	Return( .F. )
ElseIf nOpcx == 4
	If lTM040Alt
		lRetPE:=ExecBlock("TM040ALT",.F.,.F.,{DT4->DT4_FILORI,DT4->DT4_NUMCOT,DT4->DT4_STATUS,lCopia})
		If ValType(lRetPE) == "L"
			lRet:= lRetPE
		EndIf
	EndIf
	If !lRet
		If !lCopia .And.;
			DT4->DT4_STATUS != StrZero( 1, Len( DT4->DT4_STATUS ) ) .And.;
			DT4->DT4_STATUS != StrZero( 3, Len( DT4->DT4_STATUS ) ) .And.;
			DT4->DT4_STATUS != StrZero( 5, Len( DT4->DT4_STATUS ) )  //-- Cotacao Pendente ou Aprovada
			Help(' ', 1, 'TMSA04001')   //-- Manutencoes sao permitidas somente em cotacoes de frete Pendentes ou Aprovadas.
			Return( .F. )
		Else
			//-- Somente sera permitido alterar a cotacao relacionada com o agendamento com status diferente de 'A Confirmar' e 'Confirmado'.
			If !lAgend
				aAreaDF1 := DF1->(GetArea())
				DF1->(DbSetOrder(2))
				If DF1->(MsSeek(xFilial("DF1")+DT4->DT4_FILORI+DT4->DT4_NUMCOT)) .And. ;
					( DF1->DF1_STACOL == StrZero(1,Len(DF1->DF1_STACOL)) .Or. DF1->DF1_STACOL == StrZero(2,Len(DF1->DF1_STACOL)) )
					Help(' ',1, 'TMSA04046') // As cotacoes de frete geradas a partir do agendamento nao podem ser alteradas.
					Return( .F. )
				EndIf
				RestArea( aAreaDF1 )
			EndIf
		EndIf
	EndIf
ElseIf nOpcx == 6
	If DT4->DT4_STATUS != StrZero( 1, Len( DT4->DT4_STATUS ) )	//-- Se aprovacao
		Help(' ', 1, 'TMSA04002') //Aprovacao permitida somente para cotacoes de frete pendentes.
		Return( .F. )
	Else
		//-- Verifica se a cotacao esta relacionada com o agendamento. (Carga Fechada)
		If !lAgend
			aAreaDF1 := DF1->(GetArea())
			DF1->(DbSetOrder(2))
			If DF1->(MsSeek(xFilial("DF1")+DT4->DT4_FILORI+DT4->DT4_NUMCOT))
				lAgend := .T.
			EndIf
			RestArea( aAreaDF1 )
		EndIf
	EndIf
ElseIf nOpcx == 5
	If	DT4->DT4_STATUS == StrZero( 9, Len( DT4->DT4_STATUS ) )	//-- Cancelada
		Help(' ', 1, 'TMSA04003') //-- Cotacao de frete ja cancelada.
		Return( .F. )
	ElseIf	DT4->DT4_STATUS != StrZero( 1, Len( DT4->DT4_STATUS ) ) .And.;
			DT4->DT4_STATUS != StrZero( 3, Len( DT4->DT4_STATUS ) ) .And.;
			DT4->DT4_STATUS != StrZero( 5, Len( DT4->DT4_STATUS ) )
		Help(' ', 1, 'TMSA04004') //-- Cancelamento permitido somente para Cotacoes de Frete Pendentes ou Aprovadas.
		Return( .F. )
	EndIf
	// Posiciona o DT5(Solicitacao de Coleta)
	DT5->(DbSetOrder(5))
	DT5->(MsSeek(xFilial("DT5") + DT4->DT4_FILORI+DT4->DT4_NUMCOT ))

	// Posiciona o DUD(Movimento de Viagem) para verificar se a coleta nao esta em viagem.
	DUD->(DbSetOrder(1))
	If DUD->(MsSeek(xFilial("DUD") + DT5->DT5_FILDOC + DT5->DT5_DOC + DT5->DT5_SERIE + cFilAnt))
		If !Empty(DUD->DUD_VIAGEM)
			Help("",1,"TMSA04038",, DUD->DUD_VIAGEM, 4, 1) // Esta cotacao esta sendo utilizada na Viagem.
			Return( .F. )
		EndIf
	EndIf

	//-- Verifica se o status do Agendamento eh 'A Confirmar' ou 'Confirmado' (Carga Fechada)
	aAreaDF1 := DF1->(GetArea())
	DF1->(DbSetOrder(2))
	If DF1->(MsSeek(xFilial("DF1")+DT4->DT4_FILORI+DT4->DT4_NUMCOT))
		If	DF1->DF1_STACOL <> StrZero(1,Len(DF1->DF1_STACOL)) .And. ;	// 'A Confirmar'
			DF1->DF1_STACOL <> StrZero(2,Len(DF1->DF1_STACOL))			// 'Confirmado'
			Help(' ',1, 'TMSA04047') // Cancelamento nao permitido quando exitir relacao com agendamento e o status do agendamento for diferente de 'A Confirmar' e 'Confirmado'.
			Return( .F. )
		EndIf
	EndIf
	RestArea( aAreaDF1 )

ElseIf nOpcx == 7 .And.	!DT4->DT4_STATUS $ (StrZero( 2, Len( DT4->DT4_STATUS )) + StrZero( 5, Len( DT4->DT4_STATUS )))	//-- Se Liberacao
	Help(' ', 1, 'TMSA04034') //-- Liberacao permitida somente para Cotacoes de Frete bloqueadas.
	Return( .F. )
EndIf

//-- Configura variaveis da Enchoice
While nIncStru <= Len(oGenStru:aFields)

		If	Ascan({'DT4_DATCAN','DT4_OBSCAN'}, { |x| AllTrim(x) == AllTrim(oGenStru:aFields[nIncStru,1]) } ) == 0

			AAdd( aVisual, oGenStru:aFields[nIncStru,1] )

			If nOpcx == 6
				If	GetSx3Cache(oGenStru:aFields[nIncStru,1],"X3_FOLDER") $ "3"	//-- Aprovacao
					AAdd( aAltera, oGenStru:aFields[nIncStru,1] )
				EndIf
			Else
				AAdd( aAltera, oGenStru:aFields[nIncStru,1] )
			EndIf

		EndIf
		nIncStru++
EndDo

//-- Configura variaveis para getdados
TMSFillGetDados( Iif( nOpcx==5, 4,Iif( nOpcx==7, 2, nOpcx ) ), 'DVF', 1, xFilial('DVF') + M->DT4_FILORI + M->DT4_NUMCOT, { || DVF->DVF_FILIAL + DVF->DVF_FILORI + DVF->DVF_NUMCOT } )

If	Empty(GDFieldGet('DVF_ITEM',1))
	GDFieldPut( 'DVF_ITEM' ,StrZero(1,Len(DVF->DVF_ITEM)) ,1)
EndIf

//--	Se cancelamento, editar apenas os campos de observacao e data de cancelamento.
If nOpcx == 5 .Or. ( nOpcx == 2 .And. ! Empty( M->DT4_DATCAN ) )
	AAdd( aVisual ,'DT4_OBSCAN' )
	AAdd( aVisual ,'DT4_DATCAN' )

	AAdd( aMemos ,{'DT4_CODOBC' ,'DT4_OBSCAN'} )

	aAltera := {'DT4_OBSCAN','DT4_DATCAN'}
Else
	AAdd( aMemos ,{'DT4_CODOBS' ,'DT4_OBS'} )
EndIf

If Empty( M->DT4_PRZVAL ) .Or. lCopia
	M->DT4_PRZVAL := dDataBase + nVldCot
EndIf

If lCopia .And. !Empty(M->DT4_NUMSOL)
	M->DT4_NUMSOL := Space( Len( DT4->DT4_NUMSOL ) )
EndIf

If Empty( M->DT4_CDRORI )
    xConteudo := SuperGetMv("MV_CDRORI",,.F.,M->DT4_FILORI)
	If ValType(xConteudo) == "C"
        M->DT4_CDRORI := PadR(xConteudo,Len(DT4->DT4_CDRORI))
    Else
        Help('',1,'TMSA04040') //-- Parametro MV_CDRORI nao encontrado na filial de origem informada
		Return( .F. )
    EndIf
EndIf

If ! Empty( M->DT4_CDRORI )
	M->DT4_REGORI := MyPosicione('DUY', 1, xFilial('DUY') + M->DT4_CDRORI, 'DUY_DESCRI')
EndIf

If ! Empty( M->DT4_CDRDES )
	M->DT4_REGDES := MyPosicione('DUY', 1, xFilial('DUY') + M->DT4_CDRDES, 'DUY_DESCRI')
EndIf

//-- Obtem o total do frete da cotacao
aFrete   := {}
nTValPas := 0
nTValImp := 0
nTValTot := 0
//-- Preenche o vetor aFrete com a composicao de frete da cotacao
TmsViewFrt('2',M->DT4_FILORI,M->DT4_NUMCOT, , , , , ,@nTValPas,@nTValImp,@nTValTot)

aFrtOri := AClone(aFrete)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA040Whe³ Autor ³ Alex Egydio           ³ Data ³16.10.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes antes de editar o campo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Campo a ser validado                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA040Whe(cCampo)

Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local aContrat   := {}
Local cOptPesCub := ""
Default cCampo   := ReadVar()
	
TMSA040Cli(@cCliDev,@cLojDev)
If cCampo $ 'M->DT4_SERVIC'
	If Empty(M->DT4_TIPTRA)
		lRet := .F.
	Else
		aContrat := TMSContrat(cCliDev, cLojDev, , ,.F., M->DT4_TIPFRE,,,,,,,,,,,,,,,,M->DT4_CODNEG)
		If Len(aContrat) > 0 .And. aContrat[ 1, 21 ] == StrZero(2, Len(AAM->AAM_SELSER )) // Seleciona Servico Automatico
			lRet := .F.
		EndIf
	EndIf

ElseIf cCampo == "M->DVF_PESOM3"
	//-- Este campo somente sera' editavel quando o campo A7_PERCUB/B5_PERCUB for branco.
	If Empty(GdFieldGet('DVF_CODPRO',n))
		Help("",1,"TMSA05025") //-- Informe o Produto ...
		lRet :=.F.
	Else
		cOptPesCub := TmsPesCub(cCliDev,cLojDev,,M->DT4_CLIREM,M->DT4_LOJREM,M->DT4_CLIDES,M->DT4_LOJDES,cCampo,M->DT4_SERVIC)
		//-- Caso o perfil do cliente de calculo esteja configurado com a opcao "4 - M3"
		//-- habilitar o campo DVF_METRO3 e desabilitar o campo DVF_PESOM3
		If Empty(cOptPesCub) .Or. cOptPesCub == '4'  // Peso Cubado M3
			Return( .F. )
		EndIf
		If cOptPesCub == '2'
			If !Empty(M->DT4_CLIDEV)   // Peso Cubado == Nao
				Help("",1,'TMSA05036') // O Peso Cubado Nao podera ser Informado/ Calculado... Esta Regra foi definida no Perfil do Cliente de Calculo. 
			EndIf
			Return( .F. )
		EndIf
		lRet := Empty(TmsPerCub(GdFieldGet('DVF_CODPRO',n),cCliDev,cLojDev))
	EndIf

ElseIf cCampo == 'M->DVF_METRO3'
	cOptPesCub := TmsPesCub(cCliDev,cLojDev,,M->DT4_CLIREM,M->DT4_LOJREM,M->DT4_CLIDES,M->DT4_LOJDES,cCampo,M->DT4_SERVIC)
	//-- Caso o perfil do cliente de calculo esteja configurado com a opcao "4 - M3"
	//-- habilitar o campo DVF_METRO3 e desabilitar o campo DVF_PESOM3
	If cOptPesCub <> '4'  // Peso Cubado M3
		Return( .F. )
	EndIf
ElseIf cCampo $ 'M->DT4_PESSOA'
	lRet := Empty(M->DT4_CLIDEV) .And. Empty(M->DT4_LOJDEV)
ElseIf AllTrim(cCampo) $ 'M->DT4_INCOTE;M->DT4_MOEDA;M->DT4_ROTA'
	//-- Rodoviario Internacional
	lRet := (M->DT4_TIPTRA == StrZero(4,Len(DT4->DT4_TIPTRA)))
ElseIf cCampo $ 'M->DI8_PERCIF;M->DI8_PERFOB;M->DI8_VALCIF;M->DI8_VALFOB"
	lRet := (GDFieldGet('DI8_CODPAS') != "TF")
ElseIf cCampo $ 'M->DT4_CONTRI'
	If !Empty(M->DT4_CLIDES) .And. !Empty(M->DT4_LOJDES)
		M->DT4_CONTRI:=StrZero(0,Len(DT4->DT4_CONTRI))		//Nao utiliza
		lRet := .F.	
	EndIf	
ElseIf cCampo $ 'M->DT4_CODNEG'
		lRet := .F.
ElseIf cCampo $ 'M->DT4_INVORI'
	//-- Quando o tipo na nota fiscal for 6-devolucao trava o campo Inv.Origem."DT4_INVORI"
	If M->DT4_TIPNFC == StrZero(1,Len(DT4->DT4_TIPNFC))
		lRet := .F.
	EndIf
EndIf

RestArea( aAreaAnt )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA040Vld³ Autor ³ Alex Egydio           ³ Data ³16.10.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes do sistema                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Cotacoes de Frete                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA040Vld(aCotacao)

Local nY         := 0
Local nX         := 0
Local nTF        := 0
Local aAreaDT3	 := {}
Local aAreaSA1   := {}
Local aItContrat := {}
Local aColsOld   := {}
Local cCampo 	 := ReadVar()
Local nCntFor	 := 0
Local nSeek		 := 0
Local IncOld     := Inclui
Local lTMSCFec   := TMSCFec() //-- Carga Fechada
Local nPosProd   := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DVF_CODPRO'})
Local nPosItem   := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DVF_ITEM'})
Local aContrat   := {}
Local nFatCubado := 0
Local nValMetro3 := 0
Local cOptPesCub := ""
Local nTotPas    := 0
Local nValFOB    := 0
Local nValCIF    := 0
Local nPCodPas   := 0
Local nPValCIF   := 0
Local nPValFOB   := 0
Local nFTCub     := 0
Local cCliRem    := ""
Local cLojRem    := ""
Local cCliDes    := ""
Local cLojDes    := ""
Local cCliDev    := ""
Local cLojDev    := ""
Local lRet       := .T.
Local cSeek      := ""
Local cDocTms	 := ""
Local lIdentDoc  := DT4->(ColumnPos("DT4_DOCTMS")) > 0
Local aNoFldsDTE := {"DTE_FILORI","DTE_CLIREM","DTE_LOJREM", "DTE_CODPRO", "DTE_ITESOL" , "DTE_NUMCOT", "DTE_NUMNFC", "DTE_SERNFC" , "DTE_NUMSOL"  }
Local oDTEStru   := FwFormStruct(2,"DTE")
Local nIncDTE    := 1
Local nOpc		 := 0
Local lIsBlind	 := IsBlind()

Local aAreaDUY   := DUY->(GetArea())

DEFAULT aCotacao := {}

If Type('lMostraTela')!='L'
	Private lMostraTela := .T.
EndIf

If Type('l040Auto')!='L'
	Private l040Auto := .F.
EndIf

If Type('cCadastro')!='C'
	Private cCadastro := ''
EndIf

If Type('nPerCub')!='N'
	Private nPerCub := 0
EndIf

If	Type('aMaterial')!='A'
	Private	aMaterial := {}
EndIf

If Type('nFatCub')!='N'
	Private nFatCub := 0
EndIf

If	cCampo == 'M->DT4_FILORI'
    if M->DT4_SELORI == StrZero(1,Len(M->DT4_SELORI))//Alterar regiao origem somente quando selec.Origem = transportadora
        xConteudo := SuperGetMv("MV_CDRORI",,.F.,M->DT4_FILORI)
        If ValType(xConteudo) == "C"
            M->DT4_CDRORI := PadR(xConteudo,Len(DT4->DT4_CDRORI))
            M->DT4_REGORI := MyPosicione('DUY',1,xFilial('DUY')+M->DT4_CDRORI, "DUY_DESCRI")
        Else
            Help('',1,'TMSA04040') //-- Parametro MV_CDRORI nao encontrado na filial de origem informada
            Return( .F. )
        EndIf
    EndIF
ElseIf cCampo == 'M->DT4_CODSOL'

	DUE->( DbSetOrder( 1 ) )
	If DUE->( MsSeek( xFilial('DUE') + M->DT4_CODSOL, .F. ) )
		M->DT4_NOMSOL := DUE->DUE_NOME
		M->DT4_CONTAT := DUE->DUE_CONTAT
	Else
		M->DT4_NOMSOL := Space(Len(DUE->DUE_NOME))
		M->DT4_CONTAT := Space(Len(DUE->DUE_CONTAT))
	EndIf
	//-- Verifica quem sera' o Cliente Devedor da Cotacao
	TMSA040Cli(@cCliDev,@cLojDev)

	
ElseIf	cCampo == 'M->DT4_CLIREM' .Or. cCampo == 'M->DT4_LOJREM'

	cCliRem := IIf( Empty(aCotacao), PadR(M->DT4_CLIREM, Len(SA1->A1_COD)) , aCotacao[1][10] )
	cLojRem := IIf( Empty(aCotacao), PadR(M->DT4_LOJREM, Len(SA1->A1_LOJA)), aCotacao[1][11] )

	If (cCampo == 'M->DT4_CLIREM' .And. Empty( cCliRem )) .Or. (cCampo == 'M->DT4_LOJREM' .And. Empty( cLojRem ))
		M->DT4_CLIREM := CriaVar('DT4_CLIREM')
		M->DT4_LOJREM := CriaVar('DT4_LOJREM')
	ElseIf !Empty( cCliRem ) .And. !Empty( cLojRem )
		cSeek := xFilial('SA1') + cCliRem
		If !Empty( cLojRem ) .Or. ( !Empty( cCliRem ) .And. Empty( cLojRem ) .And. cCampo == 'M->DT4_LOJREM' )
			cSeek += cLojRem
		EndIf

		aAreaSA1 := SA1->( GetArea() )
		SA1->( DbSetOrder(1) )
		If !SA1->( MsSeek( cSeek ) )
			Help('', 1, 'REGNOIS' )
			lRet := .F.
		Else
			cSeek := cCliRem
			If !Empty( cLojRem ) .Or. ( !Empty( cCliRem ) .And. Empty( cLojRem ) .And. cCampo == 'M->DT4_LOJREM' )
				cSeek += cLojRem
			EndIf

			lRet := ExistCpo( "SA1", cSeek, 1 )

			If lRet
				M->DT4_NOMREM := SA1->A1_NOME
			EndIf
		EndIf
		RestArea( aAreaSA1 )

		//--Condicoes para tratar o campo TIPO DO FRETE na aba Dados da Empresa.
		If lRet
			If M->DT4_CLIREM+M->DT4_LOJREM == M->DT4_CLIDES+M->DT4_LOJDES
				If !l040Auto .And. !MsgYesNo(STR0098) //"O Cliente Remetente e Destinario estao Iguais ... Confirma ? "###"Sim"###"Nao"
					Return( .F. )
				EndIf
			EndIf
			If	M->DT4_CLIREM+M->DT4_LOJREM == M->DT4_CLIDEV+M->DT4_LOJDEV .And.;
				M->DT4_CLIREM+M->DT4_LOJREM <> M->DT4_CLIDES+M->DT4_LOJDES
				M->DT4_TIPFRE := '1' //CIF
			EndIf
		EndIf

		If lRet
			If !Empty( cCliRem )
				
				//-- Nao permite selecionar cliente generico.
				lRet := TmsVldCli( cCliRem, cLojRem ) //-- Retorno .F. eh cliente generico
				
				If lRet
					
					//-- Verifica quem sera o Cliente Devedor da Cotacao
					TMSA040Cli(@cCliDev,@cLojDev)
				    
				    //| Limpa os campos servico e sua descricao para que o usuario faça a digitação novamente.
					If !IsInCallStack("TMSAF05") .And. !lAprova .And. !IsInCallStack("TMSAE75") .And. !l040Auto
				     	
						M->DT4_CODNEG := CriaVar('DT4_CODNEG',.F.)
						M->DT4_DESNEG := CriaVar('DT4_DESNEG',.F.)
						M->DT4_SERVIC := CriaVar('DT4_SERVIC',.F.)
						M->DT4_DESSER := CriaVar('DT4_DESSER',.F.)
					
					EndIf
				EndIf
				
			EndIf
		EndIf
	EndIf

ElseIf	cCampo == 'M->DT4_CLIDES' .Or. cCampo == 'M->DT4_LOJDES'

	cCliDes := IIf( Empty(aCotacao), PadR(M->DT4_CLIDES, Len(SA1->A1_COD)) , aCotacao[1][12] )
	cLojDes := IIf( Empty(aCotacao), PadR(M->DT4_LOJDES, Len(SA1->A1_LOJA)), aCotacao[1][13] )

	If (cCampo == 'M->DT4_CLIDES' .And. Empty(cCliDes)) .Or. (cCampo == 'M->DT4_LOJDES' .And. Empty( cLojDes ))
		M->DT4_CLIDES := CriaVar('DT4_CLIDES')
		M->DT4_LOJDES := CriaVar('DT4_LOJDES') 
	ElseIf !Empty( cCliDes ) .And. !Empty( cLojDes )

		cSeek   := xFilial('SA1') + cCliDes
		If !Empty( cLojDes ) .Or. ( !Empty( cCliDes ) .And. Empty( cLojDes ) .And. cCampo == 'M->DT4_LOJDES' )
			cSeek += cLojDes
		EndIf

		aAreaSA1 := SA1->( GetArea() )
		SA1->( DbSetOrder(1) )
		If !SA1->( MsSeek( cSeek ) )
			Help('', 1, 'REGNOIS' )
			lRet := .F.
		Else
			cSeek := cCliDes
			If !Empty( cLojDes ) .Or. ( !Empty( cCliDes ) .And. Empty( cLojDes ) .And. cCampo == 'M->DT4_LOJDES' )
				cSeek += cLojDes
			EndIf

			lRet := ExistCpo( "SA1", cSeek, 1 )

			If lRet
				M->DT4_NOMDES := SA1->A1_NOME
				M->DT4_CDRDES := SA1->A1_CDRDES
				M->DT4_REGDES := Posicione("DUY",1,xFilial("DUY") + SA1->A1_CDRDES,"DUY_DESCRI")
			EndIf
		EndIf
		RestArea( aAreaSA1 )

		//--Condicoes para tratar o campo TIPO DO FRETE na aba Dados da Empresa.
		If lRet
			If	M->DT4_CLIREM+M->DT4_LOJREM == M->DT4_CLIDES+M->DT4_LOJDES
				If !l040Auto .And. !MsgYesNo(STR0098)          	 //"O Cliente Remetente e Destinario estao Iguais ... Confirma ? "###"Sim"###"Nao"
					Return( .F. )
				EndIf
			EndIf
			If	M->DT4_CLIDES+M->DT4_LOJDES == M->DT4_CLIDEV+M->DT4_LOJDEV .And. ;
				M->DT4_CLIDES+M->DT4_LOJDES <> M->DT4_CLIREM+M->DT4_LOJREM
				M->DT4_TIPFRE := '2' //FOB
			EndIf
		EndIf

		If lRet
			If !Empty( cCliDes )
				//-- Nao permite selecionar cliente generico.
				lRet := TmsVldCli( cCliDes, cLojDes ) //-- Retorno .F. eh cliente generico
				If lRet
					//-- Verifica quem sera o Cliente Devedor da Cotacao
					TMSA040Cli(@cCliDev,@cLojDev)
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf	cCampo == 'M->DT4_CLIDEV' .Or. cCampo == 'M->DT4_LOJDEV'

	cCliDev := IIf( Empty(aCotacao), PadR(M->DT4_CLIDEV, Len(SA1->A1_COD)) , aCotacao[1][14] )
	cLojDev := IIf( Empty(aCotacao), PadR(M->DT4_LOJDEV, Len(SA1->A1_LOJA)), aCotacao[1][15] )

	If (cCampo == 'M->DT4_CLIDEV' .And. Empty( cCliDev )) .Or. (cCampo == 'M->DT4_LOJDEV' .And. Empty( cLojDev ))
		M->DT4_CLIDEV := CriaVar('DT4_CLIDEV')
		M->DT4_LOJDEV := CriaVar('DT4_LOJDEV')
		M->DT4_NOMDEV := CriaVar('DT4_NOMDEV')
	ElseIf !Empty( cCliDev ) .And. !Empty( cLojDev )
		cSeek   := xFilial('SA1') + cCliDev
		If !Empty( cLojDev ) .Or. ( !Empty( cCliDev ) .And. Empty( cLojDev ) .And. cCampo == 'M->DT4_LOJDEV' )
			cSeek += cLojDev
		EndIf

		aAreaSA1 := SA1->( GetArea() )
		SA1->( DbSetOrder(1) )
		If !SA1->( MsSeek( cSeek ) )
			Help('', 1, 'REGNOIS' )
			lRet := .F.
		Else
			cSeek := cCliDev
			If !Empty( cLojDev ) .Or. ( !Empty( cCliDev ) .And. Empty( cLojDev ) .And. cCampo == 'M->DT4_LOJDEV' )
				cSeek += cLojDev
			EndIf

			lRet := ExistCpo( "SA1", cSeek, 1 )

			If lRet 
				M->DT4_NOMDEV	:= SA1->A1_NOME
			EndIf
		EndIf
		RestArea( aAreaSA1 )

		//--Condicoes para tratar o campo TIPO DO FRETE na aba Dados da Empresa.
		If	M->DT4_CLIREM+M->DT4_LOJREM == M->DT4_CLIDEV+M->DT4_LOJDEV
			M->DT4_TIPFRE := '1' //CIF
		ElseIf	M->DT4_CLIDES+M->DT4_LOJDES == M->DT4_CLIDEV+M->DT4_LOJDEV
			M->DT4_TIPFRE := '2' //FOB
		ElseIf !l040Auto
			M->DT4_TIPFRE := '2' //FOB
		EndIf

		If lRet
			If !Empty( cCliDev )
				//-- Nao permite selecionar cliente generico.
				lRet := TmsVldCli( cCliDev, cLojDev ) //-- Retorno .F. eh cliente generico
			EndIf
		EndIf
	EndIf

	//| Limpa os campos servico e sua descricao para que o usuario faça a digitação novamente.
	If !IsInCallStack("TMSAF05") .And. !lAprova .And. !IsInCallStack("TMSAE75")
		M->DT4_CODNEG := CriaVar('DT4_CODNEG',.F.)
	   	M->DT4_SERVIC := CriaVar('DT4_SERVIC',.F.)
	   	M->DT4_DESSER := CriaVar('DT4_DESSER',.F.)
	EndIf
    
ElseIf cCampo == 'M->DT4_CDRORI'
	DUY->(DbSetOrder(1))
	If DUY->( ! MsSeek( xFilial('DUY') + M->DT4_CDRORI, .F. ) )
		Help( ' ', 1, 'TMSA04016', , STR0027 + M->DT4_CDRORI , 4, 1 )	//-- Codigo da regiao origem nao encontrado (DUY) // //'Regiao: '
		Return( .F. )
	EndIf

	//-- Verifica se a regiao informada eh de origem.
	If	! TmsTipReg( M->DT4_CDRORI, StrZero( 1, Len( DTN->DTN_TIPREG ) ) )
		Return( .F. )
	EndIf

	//-- Valida se a regiao de Origem esta habilitada para o Servico de Transporte
	//-- e Tipo de Transporte Informados.
	If !TmsChkDTN( M->DT4_SERTMS, M->DT4_TIPTRA, M->DT4_CDRORI )
		Return( .F. )
	EndIf

ElseIf cCampo == 'M->DT4_CDRDES'
	DUY->(DbSetOrder(1))
	If DUY->( ! MsSeek( xFilial('DUY') + M->DT4_CDRDES, .F. ) )
		Help( ' ', 1, 'TMSA04018', , STR0027 + M->DT4_CDRDES , 4, 1 )	//-- Codigo da regiao destino nao encontrado (DUY)  //'Regiao: '
		Return( .F. )
	EndIf

	//-- Verifica se a regiao informada eh de destino.
	If ! TmsTipReg( M->DT4_CDRDES, StrZero( 2, Len( DTN->DTN_TIPREG ) ) )
		Return( .F. )
	EndIf

	//-- Valida se a regiao de Destino esta habilitada para o Servico de Transporte
	//-- e Tipo de Transporte Informados.
	If !TmsChkDTN( M->DT4_SERTMS, M->DT4_TIPTRA, M->DT4_CDRDES )
		Return( .F. )
	EndIf
	
	// Verifica novamente o tipo do documento caso a região de destino seja alterada
	If !Empty(M->DT4_SERVIC) .Or. lCopia 
		DC5->(dbSetOrder(1)) //DC5_FILIAL+DC5_SERVIC
		DC5->(MsSeek(xFilial("DC5")+ M->DT4_SERVIC))
		If lIdentDoc .And. Empty(DC5->DC5_DOCTMS)
			M->DT4_DOCTMS := TMSTipDoc(M->DT4_CDRORI,M->DT4_CDRDES)
			If !Empty(M->DT4_DOCTMS)
				M->DT4_DESDOC := TMSValField("M->DT4_DOCTMS",.F.,"DT4_DESDOC")
			EndIf
		EndIf
		If lIdentDoc .And. !Empty(M->DT4_DOCTMS)
			DUI->( DbSetOrder( 1 ) )
			If	DUI->( ! MsSeek( xFilial('DUI') + M->DT4_DOCTMS ) )
				Help( ' ', 1, 'TMSA20009',, STR0080 + M->DT4_DOCTMS,5,1)	//-- Documento nao encontrado na configuracao de documentos (DUI) ### "Documento"
				lRet := .F. 
			EndIf
		EndIf
	EndIf

ElseIf cCampo == 'M->DT4_SERTMS'
	If M->DT4_SERTMS == StrZero( 1, Len(DT4->DT4_SERTMS))
		Help("",1, "TMSA05002") //Nesta Opcao nao sera possivel utilizar um servico do tipo "Coleta".
		Return( .F. )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se a regiao de Origem esta habilitada para o Servico de Transporte ³
	//³e Tipo de Transporte Informados.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !TmsChkDTN( M->DT4_SERTMS, M->DT4_TIPTRA, M->DT4_CDRORI )
		Return( .F. )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se a regiao de Destino esta habilitada para o Servico de Transporte³
	//³e Tipo de Transporte Informados.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !TmsChkDTN( M->DT4_SERTMS, M->DT4_TIPTRA, M->DT4_CDRDES )
		Return( .F. )
	EndIf

	//-- Executa tratamento do campo Tipo Transp. quando o mesmo esta informado
	If !Empty(M->DT4_TIPTRA) .And. !IsInCallStack("TMSAE75")
		If !(Tmsa040Tip(@cCliDev,@cLojDev,@aContrat,@aItContrat))
			M->DT4_TIPTRA := ' '
		Endif
	Endif
ElseIf cCampo == 'M->DT4_TIPTRA'

	If !IsInCallStack("TMSAE75")
		If !(Tmsa040Tip(@cCliDev,@cLojDev,@aContrat,@aItContrat))
			Return(.F.)
		Endif
	EndIf

ElseIf cCampo == 'M->DT4_SERVIC'
	If lIdentDoc .And. !Empty(aCotacao) .And. IsInCallStack("TMSA050Mnt")
		cDocTms := aCotacao[1][18] 
	ElseIf lIdentDoc .And. !Empty(aCotacao) .And. IsInCallStack("TMSAF05")
		cDocTms := aCotacao[1][20]
	EndIf
	//-- Valida o codigo do servico digitado.
	DC5->( DbSetOrder( 1 ) )
	If DC5->( ! MsSeek( xFilial('DC5') + M->DT4_SERVIC, .F. ) )
		Help(' ', 1, 'TMSA04013', , STR0028 + M->DT4_SERVIC , 4, 1 )	//-- Codigo do servico nao encontrado (DC5).  //'Servico: '
		Return( .F. )
	ElseIf DC5->DC5_DOCTMS == '7' .Or. DC5->DC5_DOCTMS == '8' .Or. DC5->DC5_DOCTMS == 'D' .Or. DC5->DC5_DOCTMS == 'G' //Não permite serviços "7=CTRC Reentrega","8=CTRC Complemento","D=NF Reentrega" e "G=NF Complemento"	
		Help("",1,"TMSA05040") // Servico Invalido ...
		Return( .F. )
	ElseIf lIdentDoc .And. Empty(DC5->DC5_DOCTMS) .And. Empty(cDocTms)
		M->DT4_DOCTMS := TMSTipDoc(M->DT4_CDRORI,M->DT4_CDRDES)
		If !Empty(M->DT4_DOCTMS)
			M->DT4_DESDOC := TMSValField("M->DT4_DOCTMS",.F.,"DT4_DESDOC")
		EndIf
	ElseIf lIdentDoc .And. !Empty(DC5->DC5_DOCTMS) .And. Empty(cDocTms)
		M->DT4_DOCTMS := DC5->DC5_DOCTMS
		If !Empty(M->DT4_DOCTMS)
			M->DT4_DESDOC := TMSValField("M->DT4_DOCTMS",.F.,"DT4_DESDOC")
		EndIf
	ElseIf lIdentDoc .And. !Empty(cDocTms)
		M->DT4_DOCTMS := cDocTms
		M->DT4_DESDOC := TMSValField("M->DT4_DOCTMS",.F.,"DT4_DESDOC")
	EndIf

	If Len(aItConTrat) == 0
		If IsInCallStack("TMSA050Mnt")
			cCliDev := M->DTC_CLIDEV
			cLojDev := M->DTC_LOJDEV
		EndIf
		//-- Verifica quem sera' o Cliente Devedor da Cotacao
		If Empty(cCliDev) .Or. Empty(cLojDev) .Or. !Empty(M->DT4_CLIDEV)
			TMSA040Cli(@cCliDev,@cLojDev)
		EndIf
		//-- Quando o tipo do frete for FOB ( DTC_TIPFRE == 2 ) e o remetente for FOB dirigido ( DUO_FOBDIR == 1 ), a
		//-- tabela de frete do cliente remetente sera utilizada para o calculo.
		If AllTrim(SuperGetMV("MV_CLIGEN",NIL,"")) <> AllTrim(cCliDev + cLojDev)
			cCliCal := cCliDev
			cLojCal := cLojDev
			If !Empty(M->DT4_CLIREM) .And. !Empty(M->DT4_LOJREM) .And. !Empty(M->DT4_CLIDES) .And. !Empty(M->DT4_LOJDES)
				If M->DT4_TIPFRE == StrZero(2,Len(DT4->DT4_TIPFRE))
					aPerfil := TmsPerfil(M->DT4_CLIREM,M->DT4_LOJREM,.F.,.F.)
					If !Empty(aPerfil) .And. aPerfil[4] == StrZero(1,Len(DUO->DUO_FOBDIR))
						lFobDir := .T.
						If lTMA040FOB
							lFobDir := ExecBlock("TMA040FOB",.F.,.F.,{M->DT4_CLIDES,M->DT4_LOJDES,M->DT4_CLIREM,M->DT4_LOJREM})
							If ValType(lFobDir) <> "L"
								lFobDir := .T.
							EndIf
						EndIf
						aContrat := aClone(aContrat)
						If lFobDir
							aContrat := TMSContrat(cCliDev,cLojDev,,M->DT4_SERVIC,.F.,M->DT4_TIPFRE, .F.,,,,,,,,,,,,,,,M->DT4_CODNEG)
							If Empty(aContrat)
								cCliCal := M->DT4_CLIREM
								cLojCal := M->DT4_LOJREM
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			cCliDev := cCliCal
			cLojDev	:= cLojCal
		EndIf
		lRet := TMSPesqServ( 'DT4', cCliDev, cLojDev, M->DT4_SERTMS, M->DT4_TIPTRA, @aItContrat, .F., M->DT4_TIPFRE, (l040Auto .Or. !lMostraTela),,,,,,, M->DT4_CDRORI, M->DT4_CDRDES,,,,,,,, M->DT4_CODNEG )
		If !lRet
			Help("",1,"TMSA05040") // Servico Invalido ...
		EndIf
	Else
		nSeek := Ascan(aItContrat, { |x| x[3] == &(ReadVar()) })
		If nSeek == 0
			Help("",1,"TMSA05040") // Servico Invalido ...
			Return( .F. )
		Else
			//-- Qdo mudar o servico, zera valor informado.
			If Inclui .And. !Empty(aValInf) .And. MsgYesNo( STR0079 ) //'Existe valor informado para a cotacao, deseja limpar o valor informado na mudanca do servico ?'
				aValInf := {}
			EndIf
		EndIf
	Endif
	//-- Posiciona configuracao de documentos para obter a Serie do Documento
	DUI->( DbSetOrder( 1 ) )
	If lIdentDoc
		If	DUI->( ! MsSeek( xFilial('DUI') + M->DT4_DOCTMS ) )
			Help( ' ', 1, 'TMSA20009',, STR0080 + M->DT4_DOCTMS,5,1)	//-- Documento nao encontrado na configuracao de documentos (DUI) ### "Documento"
			lRet := .F. 
		EndIf
	Else
		If	DUI->( ! MsSeek( xFilial('DUI') + DC5->DC5_DOCTMS ) )
			Help( ' ', 1, 'TMSA20009',, STR0080 + DC5->DC5_DOCTMS,5,1)	//-- Documento nao encontrado na configuracao de documentos (DUI) ### "Documento"
			lRet := .F. 
		EndIf
	EndIf

	If !Empty(aContrat)
		M->DT4_NCONTR := aContrat[1,1]
	EndIf

ElseIf cCampo == 'M->DVF_CODPRO'
	//-- Verifica se Codigo do Produto foi alterado.
	If aCols[n][nPosProd] <> M->DVF_CODPRO
		For nCntFor := 1 To Len(aHeader)
			If	AllTrim(aHeader[nCntFor,2])!='DVF_ITEM' .And. AllTrim(aHeader[nCntFor,2])!='DVF_CODPRO' .And. AllTrim(aHeader[nCntFor,2])!='DVF_DESPRO'
				GdFieldPut(aHeader[nCntFor,2],CriaVar(aHeader[nCntFor,2]),n)
			EndIf
		Next nCntFor
		//-- Trocar o codigo do produto se existir valor informado para codigo do produto anterior.
		For nCntFor := 1 To Len(aValInf)
			If	aValInf[nCntFor,6] == aCols[n][nPosProd]
				aValInf[nCntFor,6] := M->DVF_CODPRO
			EndIf
		Next nCntFor
	EndIf
//-- DVQ - Digitacao valor informado x cotacao		(tmsa040)
ElseIf cCampo == 'M->DVQ_CODPAS'
	aAreaDT3:=DT3->(GetArea())
	DT3->(DbSetOrder(1))
	If	DT3->(MsSeek(xFilial('DT3')+M->DVQ_CODPAS))
		If	DT3->DT3_TIPFAI != StrZero(7,Len(DT3->DT3_TIPFAI))
			Help('',1,'TMSA04045')		//-- O campo 'Calcula Sobre' deste componente esta diferente de 'Valor Informado'
			RestArea( aAreaDT3 )
			Return( .F. )
		EndIf
	Else
		Help('',1,'REGNOIS') //Nao existe registro relacionado a este codigo.
		RestArea( aAreaDT3 )
		Return( .F. )
	EndIf
	RestArea( aAreaDT3 )
//-- DVR - Digitacao valor informado x documento	(tmsa050)
ElseIf cCampo == 'M->DVR_CODPAS'
	aAreaDT3:=DT3->(GetArea())
	DT3->(DbSetOrder(1))
	If	DT3->(MsSeek(xFilial('DT3')+M->DVR_CODPAS))
		If	DT3->DT3_TIPFAI != StrZero(7,Len(DT3->DT3_TIPFAI))
			Help('',1,'TMSA04045')		//-- O campo 'Calcula Sobre' deste componente esta diferente de 'Valor Informado'
			RestArea( aAreaDT3 )
			Return( .F. )
		EndIf
	Else
		Help('',1,'REGNOIS') //Nao existe registro relacionado a este codigo.
		RestArea( aAreaDT3 )
		Return( .F. )
	EndIf
	RestArea( aAreaDT3 )
ElseIf cCampo == 'M->DT4_NUMSOL' .And. !lAgend

	DT5->(DbSetOrder(1))
	If DT5->(!MsSeek(xFilial("DT5")+M->DT4_FILORI+M->DT4_NUMSOL))
		HELP('',1,'REGNOIS') //Nao existe registro relacionado a este codigo.
		Return( .F. )
	EndIf

	//-- Se a Solicitacao de Coleta nao pertencer ao Solicitante informado
	If	DT5->(DT5_CODSOL) <> M->(DT4_CODSOL)
		Help("",1,"TMSA04048") //-- Esta Solicitacao de Coleta Nao Pertence ao Solicitante Informado ...
		Return( .F. )
	EndIf

	//-- Verifica o Status da  Solicitacao de Coleta informada
	If	DT5->DT5_STATUS == StrZero(9, Len(DT5->DT5_STATUS)) .Or. ;
		DT5->DT5_STATUS == StrZero(6, Len(DT5->DT5_STATUS)) .Or. ;
		DT5->DT5_STATUS == StrZero(5, Len(DT5->DT5_STATUS))
		Help("",1,"TMSA04050") //-- Status da Solicitacao de Coleta Invalido
		Return( .F. )
	EndIf

	DT5->(DbSetOrder(1))
	If DT5->(MsSeek(cSeek:=xFilial('DT5')+M->DT4_FILORI+M->DT4_NUMSOL)) 
		Do While DT5->(!Eof()) .And. DT5->DT5_FILIAL+DT5->DT5_FILORI+DT5->DT5_NUMSOL == cSeek
			If !Empty(DT5->DT5_NUMCOT) .And. DT5->DT5_STATUS <> StrZero(9, Len(DT5->DT5_STATUS)) // Cancelada 
				Help("",1,"TMSA04049",, DT5->DT5_NUMCOT, 3, 1) //-- Esta Solicitacao de Coleta ja esta sendo utilizada na Cotacao de Frete No. : 
				Return( .F. )
			EndIf
			DT5->(dbSkip())
		EndDo
	EndIf

	DUM->(DbSetOrder(1))
	If DUM->(MsSeek(cSeek:=xFilial('DUM')+M->DT4_FILORI+M->DT4_NUMSOL))
		aCols    := {}
		aCubagem := {} //-- Limpar o aCols de Cubagem dos Produtos
		aFrete   := {} //-- Limpar o aFrete (Composicao de Frete)
		nTValPas := 0
		nTValImp := 0
		nTValTot := 0
		//-- Preenche o vetor aFrete com a composicao de frete da cotacao
		TmsViewFrt('2',M->DT4_FILORI,M->DT4_NUMCOT, , , , , ,@nTValPas,@nTValImp,@nTValTot)
		n := 0
		While DUM->(DUM_FILIAL+DUM_FILORI+DUM_NUMSOL) == cSeek
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz a montagem de uma linha em branco no aCols.              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			n++
			AAdd(aCols,Array(Len(aHeader)+1))
			For ny := 1 to Len(aHeader)
				aCols[n][ny] := CriaVar(aHeader[nY][2])
			Next ny
			aCols[n][Len(aHeader)+1] := .F.

			cDesc := MyPosicione('SB1',1,xFilial('SB1')+DUM->DUM_CODPRO,'B1_DESC')
			GDFieldPut( 'DVF_ITEM'   ,StrZero(n,Len(DVF->DVF_ITEM))	,n)
			GdFieldPut( 'DVF_CODPRO' ,DUM->DUM_CODPRO					,n)
			GdFieldPut( 'DVF_DESPRO' ,cDesc								,n)
			GdFieldPut( 'DVF_CODEMB' ,DUM->DUM_CODEMB					,n)
			GdFieldPut( 'DVF_DESEMB' ,Tabela('MG',DUM->DUM_CODEMB)		,n)
			GdFieldPut( 'DVF_QTDVOL' ,DUM->DUM_QTDVOL					,n)
			GdFieldPut( 'DVF_VALMER' ,DUM->DUM_VALMER					,n)
			GdFieldPut( 'DVF_PESO'   ,DUM->DUM_PESO						,n)
			GdFieldPut( 'DVF_PESOM3' ,DUM->DUM_PESOM3					,n)
			DUM->(dbSkip())
		EndDo
		
		If !lIsBlind
			oGetD:oBrowse:nAt := n
			n := 1
			oGetD:ForceRefresh()
		EndIf
		//-- Se o parametro MV_TMSCFEC (Carga Fechada) estiver habilitado, carrega o aCols e o aHeader
		//-- do Botao de 'Tipos de Veiculo'
		If lTMSCFec
			//-- Alterar o conteudo da Inclui para .F., para que os campos virtuais sejam
			//-- inicializados corretamente
			Inclui := .F.
			//-- Limpar o aCols de Tipos de Veiculo
			aColsDVT := {}

			If !lIsBlind
				nOpc := oGetD:oBrowse:nOpc
			Else 
				nOpc := 3	//Inclusão
			EndIf

			a460VerTpVei( nOpc, M->DT4_FILORI, M->DT4_NUMSOL, CriaVar('DT4_NUMCOT',.F.), StrZero(1,Len(DVT->DVT_ORIGEM)))
			Inclui := IncOld
		EndIf

		aColsOld := AClone(aCols)
		//-- Preenche o aCols de Peso Cubado com o Peso Cubado informado na Solicitacao de Coleta
		For nX:=1 To Len(aColsOld)
			aCols := {}
			DTE->(DbSetOrder(3))
			If DTE->( MsSeek( cSeek := xFilial('DTE') + M->DT4_FILORI + M->DT4_NUMSOL + aColsOld[nX][nPosItem] ) )
				//-- Monta AHeader de Peso Cubado
				If	Empty(aHeadDTE)

					While nIncDTE <= Len(oDTEStru:aFields)
						If	Ascan(aNoFldsDTE, { |x| x == AllTrim(oDTEStru:aFields[nIncDTE,1]) } ) == 0
							AAdd(	aHeadDTE, { AllTrim( oDTEStru:aFields[nIncDTE][3] )		 	      ,; //| X3_TITULO
											 	AllTrim( oDTEStru:aFields[nIncDTE][1])			      ,; //| X3_CAMPO
												GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_PICTURE"),; //| picture
												GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_TAMANHO"),; //| tamanho
												GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_DECIMAL"),; //| decimal
												GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_VALID")  ,; //| valid
												GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_USADO")  ,; //| usado
												GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_TIPO")	  ,; //| tipo
												GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_ARQUIVO"),; //| arquivo
												GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_CONTEXT"),; //| context 
												GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_CBOX")	  ,; //| BOX
												GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_RELACAO")}) //| Relacao/Ini.Padrao
						EndIf
						nIncDTE++
					EndDo
				EndIf
				//-- Monta ACols com o Peso Cubado da Solicit. de Coleta
				While DTE->( ! Eof() .And. DTE->DTE_FILIAL + DTE->DTE_FILORI + DTE->DTE_NUMSOL + DTE->DTE_ITESOL == cSeek )
					//-- Preenche o aCols com a cubagem de mercadorias.
					AAdd( aCols, Array( Len( aHeadDTE ) + 1 ) )
					For nCntFor := 1 To Len( aHeadDTE )
						aCols[ Len( aCols ), nCntFor ] := DTE->( FieldGet( FieldPos( aHeadDTE[ nCntFor, 2 ] ) ) )
					Next
					aCols[ Len( aCols ), Len( aHeadDTE ) + 1 ] := .F.
					DTE->( DbSkip() )
				EndDo
				AAdd(aCubagem,{aColsOld[nX][nPosProd],AClone(aCols)})
			EndIf
		Next nX
		aCols := AClone(aColsOld)
	EndIf

ElseIf cCampo== 'M->DVF_PESOM3' .And. Left(FunName(),7) == "TMSA040"
	//-- Verifica quem sera' o Cliente Devedor da Cotacao
	TMSA040Cli(@cCliDev,@cLojDev)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso o campo A7_PERCUB/B5_PERCUB esteja preenchido, calcular o percentual  ³
	//³a partir do peso digitado e armazenar o valor obtido no campo DTC_PESOM3.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cOptPesCub := TmsPesCub(cCliDev,cLojDev,,M->DT4_CLIREM,M->DT4_LOJREM,M->DT4_CLIDES,M->DT4_LOJDES,,M->DT4_SERVIC)
	If Empty(cOptPesCub) .Or. cOptPesCub == '4'  // Peso cubado por M3
		Return( .F. )
	EndIf
	If cOptPesCub == '2'
		If !Empty(cCliDev) // Peso Cubado == Nao
			Help("",1,'TMSA05036') // O Peso Cubado Nao podera ser Informado/ Calculado... Esta Regra foi definida no Perfil do Cliente de Calculo.
		EndIf
		Return( .F. )
	EndIf

ElseIf cCampo== 'M->DVF_METRO3' .And. Left(FunName(),7) == "TMSA040"
	//-- Verifica quem sera' o Cliente Devedor da Cotacao
	TMSA040Cli(@cCliDev,@cLojDev)
	//-- Apos o preenchimento do campo DVF_METRO3, multiplicar o valor informado pelo fator de cubagem
	//-- do servico e gatilhar o resultado no campo DVF_PESOM3.
	If !Empty(cCliDev) .And. !Empty(cLojDev) .And. ;
		!Empty(M->DT4_SERVIC) .And. !Empty(M->DT4_TIPFRE)
		aContrat   := TMSContrat(cCliDev, cLojDEv,,M->DT4_SERVIC,,M->DT4_TIPFRE,,,,,,,,,,,,,,,,M->DT4_CODNEG)
		If !Empty(aContrat)
			M->DT4_NCONTR := aContrat[1,1]
		EndIf

		nFatCubado := If(Len(aContrat)>0,aContrat[1][2],0)

		If lTM040FCB    //Ponto de entrada para alterar Fator de Cubagem.
			nFTCub := ExecBlock("TM040FCB" ,.F.,.F.,{nFatCubado})
			If ValType(nFTCub) == 'N'
				nFatCubado := nFTCub
			EndIf
		EndIf

		If nFatCubado > 0
			nValMetro3 :=  M->DVF_METRO3 * nFatCubado
			GdFieldPut( 'DVF_PESOM3' ,nValMetro3 ,n)
		EndIf
	EndIf
ElseIf cCampo == 'M->DT4_INCOTE'
	If Empty(M->DT4_INCOTE)
		M->DT4_TIPFRE := CriaVar("DT4_TIPFRE")
	Else
		lRet := ExistCpo('SX5','MP'+M->DT4_INCOTE,1)
		If lRet .And. M->DT4_INCOTE == "DAF"
			M->DT4_TIPFRE := StrZero(3,Len(DT4->DT4_TIPFRE))
		EndIf
	EndIf

ElseIf cCampo == 'M->DT4_ROTA'
	DA8->(DbSetOrder(1))
	If DA8->(!MsSeek(xFilial("DA8")+M->DT4_ROTA))
		Help(" ",1,"REGNOIS")
		Return( .F. )
	EndIf
	If DA8->DA8_SERTMS != M->DT4_SERTMS .Or. DA8->DA8_TIPTRA != M->DT4_TIPTRA
		MsgAlert("Rota inválida para o serviço e ou tipo de transporte informado na cotação")
		Return( .F. )
	EndIf
	If TMSRotDes(M->DT4_CDRDES,M->DT4_ROTA)
		M->DT4_DESROT := DA8->DA8_DESC
	EndIf
ElseIf cCampo == 'M->DT4_TIPFRE' 
	M->DT4_INCOTE := CriaVar('DT4_INCOTE')
ElseIf cCampo == 'M->DI7_PERFRE'
	GDFieldPut( 'DI7_VALTOT' ,((nTValTot * M->DI7_PERFRE) / 100))
ElseIf cCampo == 'M->DI7_VALTOT'
	GDFieldPut( 'DI7_PERFRE' ,((M->DI7_VALTOT / nTValTot) * 100))
ElseIf cCampo $ 'M->DI8_PERCIF;M->DI8_PERFOB;M->DI8_VALCIF;M->DI8_VALFOB'
	If cCampo == 'M->DI8_PERCIF'
		If M->DI8_PERCIF < 0 .Or. M->DI8_PERCIF > 100
			Return( .F. )
		EndIf
		nTotPas := GDFieldGet('DI8_VALCIF')+GDFieldGet('DI8_VALFOB')
		nValCIF := (M->DI8_PERCIF * nTotPas) / 100
		nValFOB := nTotPas - nValCIF
		GDFieldPut( 'DI8_VALCIF' ,nValCIF )
		GDFieldPut( 'DI8_VALFOB' ,nValFOB )
		GDFieldPut( 'DI8_PERFOB' ,(nValFOB / nTotPas) * 100 )
	ElseIf cCampo == 'M->DI8_VALCIF'
		nTotPas := GDFieldGet('DI8_VALCIF')+GDFieldGet('DI8_VALFOB')
		If M->DI8_VALCIF < 0 .Or. M->DI8_VALCIF > nTotPas
			Return( .F. )
		EndIf
		nValFOB := nTotPas - M->DI8_VALCIF
		GDFieldPut( 'DI8_VALCIF' ,M->DI8_VALCIF )
		GDFieldPut( 'DI8_VALFOB' ,nValFOB )
		GDFieldPut( 'DI8_PERCIF' ,(M->DI8_VALCIF / nTotPas) * 100 )
		GDFieldPut( 'DI8_PERFOB' ,(nValFOB / nTotPas) * 100 )
	ElseIf cCampo == 'M->DI8_PERFOB'
		If M->DI8_PERFOB < 0 .Or. M->DI8_PERFOB > 100
			Return( .F. )
		EndIf
		nTotPas := GDFieldGet('DI8_VALCIF')+GDFieldGet('DI8_VALFOB')
		nValFOB := (M->DI8_PERFOB * nTotPas) / 100
		nValCIF := nTotPas - nValFOB
		GDFieldPut( 'DI8_VALCIF' ,nValCIF )
		GDFieldPut( 'DI8_VALFOB' ,nValFOB )
		GDFieldPut( 'DI8_PERCIF' ,(nValCIF / nTotPas) * 100 )
	ElseIf cCampo == 'M->DI8_VALFOB'
		nTotPas := GDFieldGet('DI8_VALCIF')+GDFieldGet('DI8_VALFOB')
		If M->DI8_VALFOB < 0 .Or. M->DI8_VALFOB > nTotPas
			Return( .F. )
		EndIf
		nValCIF := nTotPas - M->DI8_VALFOB
		GDFieldPut( 'DI8_VALCIF' ,nValCIF )
		GDFieldPut( 'DI8_VALFOB' ,M->DI8_VALFOB )
		GDFieldPut( 'DI8_PERCIF' ,(nValCIF / nTotPas) * 100 )
		GDFieldPut( 'DI8_PERFOB' ,(M->DI8_VALFOB / nTotPas) * 100 )
	EndIf
	nValCIF  := 0
	nValFOB  := 0
	nPCodPas := GDFieldPos( 'DI8_CODPAS' )
	nPValCIF := GDFieldPos( 'DI8_VALCIF' )
	nPValFOB := GDFieldPos( 'DI8_VALFOB' )
	Aeval(aCols,{ | e | nValCIF += Iif(e[nPCodPas] != "TF",e[nPValCIF],0), nValFOB += Iif(e[nPCodPas] != "TF",e[nPValFOB],0) })
	nTF := Ascan(aCols,{ | e | e[nPCodPas] == "TF" })
	If nTF > 0
		GDFieldPut( 'DI8_VALCIF' ,nValCIF ,nTF )
		GDFieldPut( 'DI8_VALFOB' ,nValFOB ,nTF )
	EndIf
ElseIf cCampo == "M->DT4_CODNEG"

		TMSA040Cli(@cCliDev,@cLojDev)  
		If Empty(M->DT4_CODNEG)
			Help(' ', 1, 'TMSA04058') //-- Não é permitido que o código da negociação fique em branco.
			lRet := .F.
		ElseIf !Empty(cCliDev) .And. !Empty(cLojDev)
			lRet := TMSPesqServ('DT4', cCliDev, cLojDev, M->DT4_SERTMS, M->DT4_TIPTRA, @aItContrat,,;
							M->DT4_TIPFRE,(l040Auto .Or. !lMostraTela),,,,,,,M->DT4_CDRORI, M->DT4_CDRDES,,,,,,,, M->DT4_CODNEG )

			If lRet
				aContrat := TMSContrat(cCliDev,cLojDev,,,.F.,M->DT4_TIPFRE,,,,,,,,,,,,,,,,M->DT4_CODNEG)
				If Empty(aContrat)
	    		    Help(' ', 1, 'TMSA04059') //-- Negociação e serviço não existem no contrato do cliente.
	    		    lRet := .F.
				Else
					M->DT4_NCONTR := aContrat[1,1]
					DDC->(DbSetOrder(2))//DDC_FILIAL+DDC_NCONTR+DDC_CODNEG 
					If !DDC->( MsSeek( xFilial('DDC') + M->DT4_NCONTR + M->DT4_CODNEG) )
						Help("",1,"TMSA050B0") //Verifique negociação no contrato do cliente.
						lRet := .F.
			   		Endif
				Endif
			EndIf
		EndIf
	
	//-- Identificação do Tipo de Documento
	//-- Com o Item de contrato habilitado. 
	DC5->( DbSetOrder( 1 ) )
	If !Empty(M->DT4_SERVIC) .And. DC5->( ! MsSeek( xFilial('DC5') + M->DT4_SERVIC, .F. ) )
		Help(' ', 1, 'TMSA04013')	//-- Codigo do servico nao encontrado (DC5). 
		Return( .F. )
	ElseIf DC5->DC5_DOCTMS == '7' .Or. DC5->DC5_DOCTMS == '8' .Or. DC5->DC5_DOCTMS == 'D' .Or. DC5->DC5_DOCTMS == 'G' //Não permite serviços "7=CTRC Reentrega","8=CTRC Complemento","D=NF Reentrega" e "G=NF Complemento"	
		Help("",1,"TMSA05040") // Servico Invalido ...
		Return( .F. )
	ElseIf lIdentDoc .And. Empty(DC5->DC5_DOCTMS)
		M->DT4_DOCTMS := TMSTipDoc(M->DT4_CDRORI,M->DT4_CDRDES)
		If !Empty(M->DT4_DOCTMS)
			M->DT4_DESDOC := TMSValField("M->DT4_DOCTMS",.F.,"DT4_DESDOC")
		EndIf
	ElseIf lIdentDoc .And. !Empty(DC5->DC5_DOCTMS)
		M->DT4_DOCTMS := DC5->DC5_DOCTMS
		If !Empty(M->DT4_DOCTMS)
			M->DT4_DESDOC := TMSValField("M->DT4_DOCTMS",.F.,"DT4_DESDOC")
		EndIf 
	EndIf
	If lIdentDoc .And. !Empty(M->DT4_DOCTMS)
		DUI->( DbSetOrder( 1 ) )
		If	DUI->( ! MsSeek( xFilial('DUI') + M->DT4_DOCTMS ) )
			Help( ' ', 1, 'TMSA20009',, STR0035 + M->DT4_DOCTMS,5,1)	//-- Documento nao encontrado na configuracao de documentos (DUI) ### "Documento"
			lRet := .F. 
			M->DT4_DOCTMS := CriaVar('DT4_DOCTMS', .F.)
			M->DT4_DESDOC := CriaVar('DT4_DESDOC', .F.)
		EndIf
	EndIf
	
ElseIf cCampo $ 'M->DT4_DOCTMS'
	If M->DT4_DOCTMS == '7' .Or. M->DT4_DOCTMS == '8' .Or. M->DT4_DOCTMS == 'D' .Or. M->DT4_DOCTMS == 'G' //Não permite serviços "7=CTRC Reentrega","8=CTRC Complemento","D=NF Reentrega" e "G=NF Complemento"	
		Help("",1,"TMSA04063") // Tipo de Documento inválido para Cotação de Frete. Informe um tipo de Documento válido. 
		Return( .F. ) 
	EndIf 
	If lIdentDoc .And. !Empty(M->DT4_DOCTMS)
		DUI->( DbSetOrder( 1 ) )
		If	DUI->( ! MsSeek( xFilial('DUI') + M->DT4_DOCTMS ) )
			Help( ' ', 1, 'TMSA20009',, STR0080 + M->DT4_DOCTMS,5,1)	//-- Documento nao encontrado na configuracao de documentos (DUI) ### "Documento"
			lRet := .F. 
		EndIf
	EndIf

ElseIf cCampo $ 'M->DT4_TIPNFC'
	If lIdentDoc .And. M->DT4_TIPNFC == StrZero(1,Len(DT4->DT4_TIPNFC)) 
		M->DT4_DOCTMS := StrZero(6,Len(DT4->DT4_DOCTMS))
		M->DT4_DESDOC := TMSValField("M->DT4_DOCTMS",.F.,"DT4_DESDOC")
	EndIf	
EndIf

If Type("oEnch") == "O"
	oEnch:Refresh()
EndIf

RestArea(aAreaDUY)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA040Pm3³ Autor ³ Alex Egydio           ³ Data ³01.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Digitacao do peso cubado                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao selecionada                                  ³±±
±±³          ³ ExpC1 - Numero da cotacao                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA040Pm3(nOpcx,cNumCot)

Local cCodPro	:= GdFieldGet('DVF_CODPRO',n)
Local nCntFor	:= 0
Local nPerCub	:= 0
Local nTQtdVol	:= IIF(READVAR() == 'M->DVF_QTDVOL',M->DVF_QTDVOL,GdFieldGet('DVF_QTDVOL',n))
Local nSeek		:= 0
//-- Dialog
Local nOpca		:= 0
Local oDlgEsp
//-- GetDados
Local oGetPm3
Local lRet		:= .F.
Local AColsAux	:= {}
Local cOptPesCub:= ""
Local cCampoDVF := ""
Local oDTEStru  := FwFormStruct(2,"DTE", { |x| !(ALLTRIM(x) $ "DTE_FILORI|DTE_CLIREM|DTE_LOJREM|DTE_CODPRO|DTE_ITESOL|DTE_NUMCOT|DTE_NUMNFC|DTE_SERNFC|DTE_NUMSOL" ) })    
Local nIncDTE   := 1

Default cNumCot:= M->DT4_NUMCOT

If	Empty(cCodPro)
	Help(' ', 1, 'TMSA04010') //-- Informe o produto
	Return( .F. )
EndIf

nPerCub := TmsPerCub(cCodPro,cCliDev,cLojDev)
If !Empty(nPerCub)
	Help(' ', 1, 'TMSA04032',,STR0031 + cCodPro, 4, 1 ) //-- O peso cubado sera calculado pelo percentual de cubagem informado no complemento do produto (SB5).  //'Produto: '
	Return( .F. )
EndIf

If	Empty(nTQtdVol)
	Help(' ', 1, 'TMSA04031') //-- Informe o volume
	Return( .F. )
EndIf

If	Empty( M->DT4_SERVIC )
	Help(' ', 1, 'TMSA04033') //-- Informe o codigo do servico
	Return( .F. )
EndIf

//-- Validacao do Peso Cubado
cCampoDVF  := 'M->DVF_PESOM3'
cOptPesCub := TmsPesCub(cCliDev,cLojDev,,M->DT4_CLIREM,M->DT4_LOJREM,M->DT4_CLIDES,M->DT4_LOJDES,cCampoDVF,M->DT4_SERVIC)

//-- Peso Cubado == Nao   OU   Peso Cubado == M3
If cOptPesCub == '2' .Or. cOptPesCub == '4'
	If !Empty(M->DT4_CLIDEV)   // Peso Cubado == Nao
		Help("",1,'TMSA05036') // O Peso Cubado Nao podera ser Informado/ Calculado... Esta Regra foi definida no Perfil do Cliente de Calculo. 
	EndIf
	Return( .F. )
EndIf

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

SaveInter()
aHeader  := {}
aCols    := {}
cCadastro:= STR0032  //'Peso Cubado'

If	Empty(aCubagem) .Or. AScan(aCubagem,{|x|x[1]==cCodPro})==0
	//-- Configura aHeader/aCols utilizado na digitacao do peso cubado
	If	Empty(aHeadDTE)
		While nIncDTE <= Len(oDTEStru:aFields)
				AAdd( aHeadDTE,{;
				 		TRIM(GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_TITULO")) ,; //| Titulo do campo
						oDTEStru:aFields[nIncDTE][1]						  		,; //| campo
						GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_PICTURE")		,; //| picture
						GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_TAMANHO")		,; //| tamanho
						GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_DECIMAL")		,; //| decimal
						GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_VALID")  		,; //| valid
                        GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_USADO")  		,; //| usado
						GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_TIPO")   		,; //| tipo
						GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_ARQUIVO")		,; //| arquivo
						GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_CONTEXT")		,; //| context 
						GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_CBOX")	  		,; //| BOX
						GetSx3Cache(oDTEStru:aFields[nIncDTE][1],"X3_RELACAO")})	   //| Relacao/Ini.Padrao

				nIncDTE++
		EndDo
	EndIf
	aHeader:=AClone(aHeadDTE)

	DTE->(DbSetOrder(2))
	//-- Peso Cubado Informado na Cotacao de Frete
	If	DTE->( MsSeek( cSeek := xFilial('DTE') + M->DT4_FILORI + cNumCot + cCodPro ) )
		While DTE->( ! Eof() .And. DTE->DTE_FILIAL + DTE->DTE_FILORI + DTE->DTE_NUMCOT + DTE->DTE_CODPRO == cSeek )
			//-- Preenche o aCols com a cubagem de mercadorias.
			AAdd( aCols, Array( Len( aHeader ) + 1 ) )
			For nCntFor := 1 To Len( aHeader )
				aCols[ Len( aCols ), nCntFor ] := DTE->( FieldGet( FieldPos( aHeader[ nCntFor, 2 ] ) ) )
			Next
			aCols[ Len( aCols ), Len( aHeader ) + 1 ] := .F.
			DTE->( DbSkip() )
		EndDo
	Else
		If Empty(aCols)
			//-- Monta uma linha em branco.
			AAdd( aCols, Array( Len( aHeader ) + 1 ) )
			For nCntFor := 1 To Len( aHeader )
				aCols[ 1, nCntFor ] := CriaVar( aHeader[ nCntFor, 2 ] )
			Next
			aCols[1,Len(aHeader)+1] := .F.
		EndIf
	EndIf
Else
	aHeader := AClone(aHeadDTE)
	nSeek   := AScan(aCubagem,{|x|x[1]==cCodPro})
	If	Empty(nSeek)
		//-- Monta uma linha em branco.
		AAdd( aCols, Array( Len( aHeader ) + 1 ) )
		For nCntFor := 1 To Len( aHeader )
			aCols[ 1, nCntFor ] := CriaVar( aHeader[ nCntFor, 2 ] )
		Next
		aCols[1,Len(aHeader)+1] := .F.
	Else
		aCols := AClone(aCubagem[nSeek,2])
		//-- Inicializa todas as linhas do ACols como nao deletado, devido a falha na GetDados
		AColsAux := AClone(ACols)
		For nCntFor := 1 To Len(ACols)
			ACols[nCntFor,Len(aHeader)+1] := .F.
		Next nCntFor
	EndIf
EndIf

If !l040Auto
	DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM 094,104 TO 310,590 PIXEL

	@ 016, 003 SAY Alltrim(GetSx3Cache("DT4_NUMCOT","X3_TITULO")) + "   : " SIZE 56 ,9 OF oDlgEsp PIXEL
	@ 016, 040 SAY M->DT4_NUMCOT SIZE 56 ,9 OF oDlgEsp PIXEL

	@ 016 ,090 SAY Alltrim(GetSx3Cache("DVF_CODPRO", "X3_TITULO")) + " : " SIZE 56 ,9 OF oDlgEsp PIXEL
	@ 016 ,115 SAY alltrim(cCodpro) +" / "+ MyPosicione("SB1",1,xFilial('SB1')+cCodpro,"B1_DESC") OF oDlgEsp PIXEL SIZE 105 ,9

	@ 024, 003 SAY Alltrim(GetSx3Cache("DVF_QTDVOL", "X3_TITULO")) + " : " SIZE 56 ,9 OF oDlgEsp PIXEL
	@ 024, 040 SAY nTQtdVol SIZE 56 ,9 OF oDlgEsp PIXEL

	//             MsGetDados(    nT , nL,  nB,  nR,  nOpc,     cLinhaOk,       cTudoOk,     cIniCpos,lDeleta,    aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
	oGetPm3	:= MSGetDados():New( 30, 02, 105, 243, nOpcx,'PesoM3LOk()','AllWaysTrue',,.T.)
	If lAgend
		oGetPm3:oBrowse:bAdd    := { || .f. } // Nao Permite a inclusao de Linhas
		oGetPm3:oBrowse:bDelete := { || .f. } // Nao Permite a deletar Linhas
		oGetPm3:oBrowse:AAlter  := {}         // Nao Permite a alteracao de campo
	EndIf
	//-- Atualiza ACols corrigindo a falha na GetDados
	If(Len(AColsAux)>0,(ACols := AClone(AColsAux),oGetPm3:Refresh(.T.)),.T.)

	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||Iif( Tmsa040Tm3(nTQtdVol), (nOpca := 1,oDlgEsp:End()), nOpca :=0 )},{||nOpca:=0,oDlgEsp:End()})
Else
	If MsGetDAuto(aAutoCuba,"PesoM3LOk",{|| Tmsa040Tm3(nTQtdVol)},/*aAutoCab*/,nOpcx)
		nOpca := 1
	EndIf
EndIf

If nOpca == 1 .And. ( nOpcx == 3 .Or. nOpcx == 4 )
	If	Empty(aCubagem)
		AAdd(aCubagem,{cCodPro,AClone(aCols)})
	Else
		nSeek := AScan(aCubagem,{|x|x[1]==cCodPro})
		If	Empty(nSeek)
			AAdd(aCubagem,{cCodPro,AClone(aCols)})
		Else
			aCubagem[nSeek,2] := AClone(aCols)
		EndIf
	EndIf
EndIf

RestInter()

If nOpca == 1
	If	( nOpcx == 3 .Or. nOpcx == 4 )
		//-- Calcula a composicao do frete
		lRet := .T.
		TmsA040Atz(,.F.,.F.)
	EndIf
Else
	lRet := .F.
EndIf

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA040Tm3³ Autor ³ Alex Egydio           ³ Data ³01.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a digitacao do peso cubado.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Quantidade de volumes                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA040Tm3(nTQtdVol)

Local nCntFor := 0
Local nQtdVol := 0
Local lRet    := .T.
              
//-- Validacao da Linha Digitada; Esta funcao esta' no programa TMSA050
lRet := PesoM3LOk()
If lRet
	For nCntFor := 1 To Len( aCols )
		//-- Nao avalia linhas deletadas.
		If	! GDDeleted( nCntFor )
			nQtdVol += GDFieldGet( 'DTE_QTDVOL', nCntFor )
		EndIf
	Next

	If nQtdVol > 0 .And. nQtdVol != nTQtdVol
		Help('',1,'TMSA04037') //-- A soma da qtde de volumes esta diferente da qtde de volumes informado na cotacao de frete.
		Return( .F. )
	EndIf
EndIf
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tmsa040Cot³ Autor ³Henry Fila             ³ Data ³11.11.2002  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica e exibe cotacoes validas na digitacao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa040Cot()

Local aAreaAnt	:= GetArea()
Local aAreaDT4	:= DT4->(GetArea())
Local aAreaDVF	:= DVF->(GetArea())
Local aCotacao	:= {}
Local aButtons	:= {}
Local cSeek		:= ''
Local nDiasCot	:= GetMv("MV_VLDCOT")
Local nQtdVol	:= 0
Local nPeso		:= 0
Local nPesoM3	:= 0
Local nValMer	:= 0
Local nTotCot	:= 0
Local nValPas	:= 0
Local nValImp	:= 0

Local oDlgCot
Local oCotacao
Local oAmarelo	:= LoadBitmap( GetResources() ,"BR_AMARELO"  )
Local oVermelho := LoadBitmap( GetResources() ,"BR_VERMELHO" )
Local oVerde	:= LoadBitmap( GetResources() ,"BR_VERDE"    )
Local oAzul		:= LoadBitmap( GetResources() ,"BR_AZUL"     )
Local oPreto	:= LoadBitmap( GetResources() ,"BR_PRETO"    )
Local oBranco	:= LoadBitmap( GetResources() ,"BR_BRANCO"    )
Local oObjCor
Local lSinc		:= TmsSinc() //-- Chamada via Sincronizador
Local aBkpFrete := AClone(aFrete)

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

AAdd(aButtons,	{'PEDIDO' ,{|| Tmsa040VCt(oCotacao,aCotacao) }, STR0041 , STR0081  })	//"Visualiza cotacao"
AAdd(aButtons,	{'PLNPROP',{|| TMSA040Leg() }, STR0009 , STR0009 }) //"Legenda"

If !lSinc .And. !l040Auto .And. !Empty(M->DT4_CODSOL) .And. !Empty(M->DT4_CDRDES)
	//-- Busca se existem cotacoes para a chave
	DT4->(DbSetOrder(6))
	If DT4->(MsSeek(xFilial("DT4")+M->DT4_CODSOL+M->DT4_CDRDES))
		
		While DT4->(!Eof()) .And. DT4->DT4_FILIAL == xFilial("DT4") .And.;
			DT4->DT4_CODSOL == M->DT4_CODSOL .And.;
			DT4->DT4_CDRDES == M->DT4_CDRDES
			nQtdVol	:= 0
			nPeso	:= 0
			nPesoM3	:= 0
			nValMer	:= 0
			//-- Verifica se a data esta valida
			If DT4->DT4_DATCOT > dDataBase-nDiasCot .And. DT4->DT4_STATUS != "9"
				//-- Varre todos os produtos do item da cotacao p/ obter o total de Volume, Peso, PesoM3 e Valor de mercadoria
				DVF->(DbSetOrder(1))
				If	DVF->(MsSeek(cSeek := xFilial('DVF') + DT4->DT4_FILORI + DT4->DT4_NUMCOT))
					While DVF->( ! Eof() .And. DVF->DVF_FILIAL + DVF->DVF_FILORI + DVF->DVF_NUMCOT == cSeek )
						nQtdVol	+= DVF->DVF_QTDVOL
						nPeso	+= DVF->DVF_PESO
						nPesoM3	+= DVF->DVF_PESOM3
						nValMer	+= DVF->DVF_VALMER
						DVF->(DbSkip())
					EndDo
				EndIf
				
				
				//-- Busca cor do status da cotacao
				If	DT4->DT4_STATUS == StrZero(1,Len(DT4->DT4_STATUS))
					oObjCor := oAmarelo
				ElseIf DT4->DT4_STATUS == StrZero(2,Len(DT4->DT4_STATUS))
					oObjCor := oVermelho
				ElseIf DT4->DT4_STATUS == StrZero(3,Len(DT4->DT4_STATUS))
					oObjCor := oVerde
				ElseIf DT4->DT4_STATUS == StrZero(4,Len(DT4->DT4_STATUS))
					oObjCor := oAzul
				ElseIf DT4->DT4_STATUS == StrZero(5,Len(DT4->DT4_STATUS))
					oObjCor := oBranco
				ElseIf DT4->DT4_STATUS == StrZero(9,Len(DT4->DT4_STATUS))
					oObjCor := oPreto
				EndIf
				
				nTotCot := 0
				nValPas := 0
				nValImp := 0
				//-- Preenche o vetor aFrete com a composicao de frete da cotacao
				TmsViewFrt('2',DT4->DT4_FILORI,DT4->DT4_NUMCOT, , , , , ,@nValPas,@nValImp,@nTotCot)
				
				
				AAdd(aCotacao,{oObjCor,;
								DT4->DT4_FILORI,;
								DT4->DT4_NUMCOT,;
								Dtoc(DT4->DT4_DATCOT),;
								TransForm(nQtdVol,PesqPict('DVF','DVF_QTDVOL'	)),;
								Transform(nPeso,PesqPict('DVF','DVF_PESO'		)),;
								Transform(nPesoM3,PesqPict('DVF','DVF_PESOM3'	)),;
								Transform(nValMer,PesqPict('DVF','DVF_VALMER'	)),;
								Transform(nTotCot,PesqPict('DT8','DT8_VALTOT'	)),;
				DT4->(Recno())})
				
			EndIf
			
			DT4->(dbSkip())
			
		Enddo
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Mostra as cotacoes para consulta                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aCotacao) > 0
			
			DEFINE MSDIALOG oDlgCot FROM 009, 000 TO 28,80 TITLE STR0042 OF oMainWnd   //"Cotacoes realizadas"
			
			@ 032,005 LISTBOX oCotacao VAR cVar Fields HEADER " " ,;
														STR0043,;  	//"Filial de Origem"
														STR0044,;  	//"Numero"
														STR0045,;  	//"Data"
														STR0046,;  	//"Qtde. Vol."
														STR0047,; 	//"Peso"
														STR0048,;	//"Peso Cubagem"
														STR0049,;  	//"Valor Mercadoria"
														STR0050 ;  	//"Valor Frete"
														SIZE 300,120 OF oDlgCot PIXEL
			oCotacao:SetArray(aCotacao)
			oCotacao:bLine:={ ||{aCotacao[oCotacao:nAT,1],;
								aCotacao[oCotacao:nAT,2],;
								aCotacao[oCotacao:nAT,3],;
								aCotacao[oCotacao:nAT,4],;
								aCotacao[oCotacao:nAT,5],;
								aCotacao[oCotacao:nAT,6],;
								aCotacao[oCotacao:nAT,7],;
								aCotacao[oCotacao:nAT,8],;
								aCotacao[oCotacao:nAT,9]}}
			
			oCotacao:Refresh()
			
			ACTIVATE MSDIALOG  oDlgCot ON INIT EnchoiceBar( oDlgCot, { || nOpca := 1,oDlgCot:End()}, {||oDlgCot:End()},,aButtons) CENTERED
			
		EndIf
		
	EndIf
EndIf
RestArea( aAreaDVF )
RestArea( aAreaDT4 )
RestArea( aAreaAnt )

//Restaura o Backup do aFrete
aFrete  := AClone(aBkpFrete)

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tmsa040VCt³ Autor ³Henry Fila             ³ Data ³11.11.2002  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Visualiza a cotacao selecionada                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 - Objeto do listbox                                     ³±±
±±³          ³ExpA2 - Array do Listbox                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tmsa040VCt(oCotacao, aCotacao)

Local aColsBk   := aClone(aCols)
Local aArea     := GetArea()
Local aEnchSav  := {}
Local aAreaDT4  := DT4->(GetArea())

Local nRecno    := aCotacao[oCotacao:nAt,10]
Local nEndereco := 0
Local nX        := 0
Local lInclusao := Inclui
Local oDT4Stru  := FwFormStruct(2,"DT4")
Local nIncDT4   := 1

Inclui := .F.

While nIncDT4 <= Len(oDT4Stru:aFields)
	nEndereco := Ascan(aGets,{ |x| Alltrim(Subs(x,9,10)) == Alltrim(oDT4Stru:aFields[nIncDT4,1]) } )
	If nEndereco > 0
		AAdd(aEnchSav,{oDT4Stru:aFields[nIncDT4,1],	M->&(oDT4Stru:aFields[nIncDT4,1])})
	EndIf
	nIncDT4++
Enddo

DT4->(MsGoto(nRecno))

For nX := 1 to Len(aEnchSav)
	M->&(Alltrim(aEnchSav[nX][1])) := Nil
Next

TMSA040Mnt( "DT4", nRecno, 2 )

For nX := 1 to Len(aEnchSav)
	M->&(Alltrim(aEnchSav[nX][1])) := aEnchSav[nX][2]
Next

Inclui := lInclusao

aCols := aColsBk

RestArea( aAreaDT4 )
RestArea( aArea    )

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA040Atz³ Autor ³ Alex Egydio           ³ Data ³27.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza os diversos campos da cotacao.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ExpA1 - Array contendo informacoes da cotacao               ³±±
±±³          ³ExpL2 - Indica de deve recalcular o frete                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA040Atz(aCotAge, lCalcFret, lRecal, lMntBase)

Local aAreaAnt   := GetArea()
Local aFrtAux    := {}
Local aFrtAlt    := {}
Local aFrtBkp    := AClone(aFrete) //-- Utilizado na aprovacao
Local aMsgErr    := {}
Local aTmpEnt    := {}
Local aValAux    := {}
Local aTipVei    := {}
Local aFrtBac    := {}
Local cDocTms    := ''
Local cSeqTab    := StrZero( 0, Len( DT4->DT4_SEQTAB ) )
Local lTMSCFec   := TMSCFec()
Local nCntFor    := 0
Local n1Cnt      := 0
Local nPerCub    := 0
Local nQtdVol    := 0
Local nQtdUni    := 0
Local nPeso      := 0
Local nPesoM3    := 0
Local nValMer    := 0
Local nBasSeg    := 0
Local nSeek      := 0
Local nPQtdVol   := 0
Local nPAltura   := 0
Local nPCompri   := 0
Local nPLargur   := 0
Local nTotFre    := 0
Local nTotAlt    := 0
Local nPosTipVei := 0
Local nPosQtdVei := 0
Local cCodPro    := Space(Len(DVF->DVF_CODPRO))
Local cTabAlt    := ''
Local cTipAlt    := ''
Local cSeqAlt    := ''
Local cFilDes    := ''
Local lTMSCalFre := .F.
Local nKm        := 0
Local nMetro3    := 0
Local lAjuste    := .F.
Local aPesCub    := {}
Local nPesoPto   := 0
Local nCntAtiv   := 0
Local nCntAt2    := 0
Local i          := 0
Local nNewFatCub := 0
Local cExtenso   := ""
Local cRotSpeak  := "HasVVSpeak()"
Local lRemoteLin := GetRemoteType() == 2 //Checa se o Remote = Linux
Local nDelCmp    := 0
Local lAssumeFrt := (!Empty(aCotAge) .And. Len(aCotAge) >= 7 .And. !Empty(aCotAge[FRTCMPCOT]))
Local lCliCot    := SuperGetMV("MV_CLICOT",Nil,.F.) //-- Utiliza o cliente informado no Cadastro de Solicitantes
Local lIdentDoc  := DT4->(ColumnPos("DT4_DOCTMS")) > 0

Local cCliCal    := ""
Local cLojCal    := ""
Local aPerfil    := {}
Local aContrat   := {}
Local lFobDir    := .T.
Local lMoeda	 := Type("M->DT4_MOEDA") == "N"
Local lUltimo    := .F.
Local lInvOri    := .F.
Local lDT4InvOri := (DT4->(ColumnPos("DT4_INVORI"))>0)

Default aCotAge   := {}
Default lCalcFret := .F.
Default lRecal    := .T.
Default lMntBase  := .F.

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

lPrcProd := GetMV('MV_PRCPROD',,.T.)  //-- Calcula Preco do Frete por Produto ?

// Define o Cliente
If Empty(cCliDev) .Or. Empty(cLojDev) .Or. !Empty(M->DT4_CLIDEV)
	TMSA040Cli(@cCliDev,@cLojDev,lMntBase)
EndIf

CursorWait()

If Empty(M->DT4_TIPTRA)    //-- Verifica se o Tipo de transporte foi informado.
	Help(' ', 1, 'TMSA04055')
	TmsKeyOn(aSetKey)
	CursorArrow()
	Return( .F. )
EndIf

If	lAprova
	//-- Na aprovacao calcular impostos baseado na regra de tributacao do cliente devedor
	cCliDev  := M->DT4_CLIDEV
	cLojDev  := M->DT4_LOJDEV
	nTValPas := 0
	nTValImp := 0
	nTValTot := 0
	If lIdentDoc
		cDocTMs  := TMSTipDoc(M->DT4_CDRORI, M->DT4_CDRDES)
	Else
		cDocTms  := MyPosicione('DC5', 1, xFilial('DC5') + M->DT4_SERVIC, 'DC5_DOCTMS')
	EndIf 
	cFilDes  := MyPosicione("DUY", 1, xFilial("DUY") + M->DT4_CDRDES, "DUY_FILDES")
	aContrt  := TMSContrat( cCliDev, cLojDev,, M->DT4_SERVIC, .F., M->DT4_TIPFRE,,,,,,,,,,,,,,,,M->DT4_CODNEG )

	For nCntFor := 1 To Len(aFrtBkp)
		aFrete := {}
		aFrete := AClone(aFrtBkp[nCntFor,2])

		//-- Calcula impostos
		TmsA040Imp( aFrete, cCliDev, cLojDev, cDocTms, M->DT4_TIPFRE, M->DT4_CDRDES, .T., , cFilDes, TMSA040TCli(), , M->DT4_CDRORI, M->DT4_FILORI, Iif(M->DT4_INCISS=="1","S","N"), M->DT4_CLIREM, M->DT4_LOJREM, M->DT4_CLIDES, M->DT4_LOJDES,,,M->DT4_TIPNFC)

		//-- O total do frete eh a soma da linha totalizadora da composicao de frete de todos os produtos da cotacao
		nSeek := Ascan( aFrete,{|x| x[3] == 'TF' })
		If	nSeek > 0

			nTValPas += aFrete[nSeek,2]
			nTValImp += aFrete[nSeek,5]
			nTValTot += aFrete[nSeek,6]

		EndIf
		//--
		AAdd(aFrtAux,{GDFieldGet('DVF_CODPRO',nCntFor),aFrete})
	Next

	If	! Empty(aFrtAux)
		aFrete := {}
		aFrete := AClone(aFrtAux)
		aFrtOri:= AClone(aFrete)
	EndIf

	If ValType(oTValPas) == "O"
		oTValPas:Refresh()
		oTValImp:Refresh()
		oTValTot:Refresh()
	EndIf

Else

	For nCntFor := 1 To Len(aCols)
		If	! GDDeleted( nCntFor )
			nQtdVol	+= GDFieldGet( 'DVF_QTDVOL' ,nCntFor )
			nQtdUni	+= GDFieldGet( 'DVF_QTDUNI' ,nCntFor )
			nPeso	+= GDFieldGet( 'DVF_PESO'   ,nCntFor )
			nPesoM3	+= GDFieldGet( 'DVF_PESOM3' ,nCntFor )
			nValMer	+= GDFieldGet( 'DVF_VALMER' ,nCntFor )
			nBasSeg	+= GDFieldGet( 'DVF_BASSEG' ,nCntFor )
			nMetro3 += GDFieldGet( 'DVF_METRO3' , nCntFor )			
		Else
			If Len(aValInf) > 0
				If (nPos := Ascan(aValInf,{ | e | e[6] == GDFieldGet( 'DVF_CODPRO' ,nCntFor ) })) > 0					
					aValInf[nPos,3]:= .T.
				EndIf
			EndIf	
		EndIf
	Next

	//-- Quando o tipo do frete for FOB ( DTC_TIPFRE == 2 ) e o remetente for FOB dirigido ( DUO_FOBDIR == 1 ), a
	//-- tabela de frete do cliente remetente sera utilizada para o calculo.
	If AllTrim(SuperGetMV("MV_CLIGEN",NIL,"")) <> AllTrim(cCliDev + cLojDev)
		cCliCal := cCliDev
		cLojCal := cLojDev
		If !Empty(M->DT4_CLIREM) .And. !Empty(M->DT4_LOJREM) .And. !Empty(M->DT4_CLIDES) .And. !Empty(M->DT4_LOJDES)
			If M->DT4_TIPFRE == StrZero(2,Len(DT4->DT4_TIPFRE))
				aPerfil := TmsPerfil(M->DT4_CLIREM,M->DT4_LOJREM,.F.,.F.)
				If !Empty(aPerfil) .And. aPerfil[4] == StrZero(1,Len(DUO->DUO_FOBDIR))
					lFobDir := .T.
					If lTMA040FOB
						lFobDir := ExecBlock("TMA040FOB",.F.,.F.,{M->DT4_CLIDES,M->DT4_LOJDES,M->DT4_CLIREM,M->DT4_LOJREM})
						If ValType(lFobDir) <> "L"
							lFobDir := .T.
						EndIf
					EndIf
					aContrat := aClone(aContrat)
					If lFobDir
						aContrat := TMSContrat(cCliDev,cLojDev,,M->DT4_SERVIC,.F.,M->DT4_TIPFRE, .F.,,,,,,,,,,,,,,,M->DT4_CODNEG)
						If Empty(aContrat)
							cCliCal := M->DT4_CLIREM
							cLojCal := M->DT4_LOJREM
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		cCliDev := cCliCal
		cLojDev := cLojCal
	EndIf

	//-- A composicao de frete sera calculada baseada na tabela de frete informada no contrato do cliente generico.
	//-- Na aprovacao, se encontrar contrato para o cliente devedor, o usuario decide se recalcula o frete.
	aContrt := TMSContrat( cCliDev, cLojDev,, M->DT4_SERVIC,, M->DT4_TIPFRE,,,,,,,,,,,,,,,,M->DT4_CODNEG )
	//-- Identifica o Servico (Servico Automatico)
	If Len(aContrt) > 0 .And. aContrt[1][21] == StrZero(2,Len(AAM->AAM_SELSER))
		M->DT4_SERVIC := TmsRetServ( aContrt[1][1], M->DT4_SERTMS, M->DT4_TIPTRA, (M->DT4_CDRORI==M->DT4_CDRDES), nQtdVol, nValMer, nPeso, nPesoM3, M->DT4_CDRORI, M->DT4_CDRDES, , M->DT4_CODNEG )
		aContrt := TMSContrat( cCliDev, cLojDev,, M->DT4_SERVIC,, M->DT4_TIPFRE,,,,,,,,,,,,,,,,M->DT4_CODNEG )
		DC5->(DbSetOrder(1))
		DC5->(MsSeek( xFilial('DC5') + M->DT4_SERVIC ))
		If lIdentDoc .And. Empty(DC5->DC5_DOCTMS)
			M->DT4_DOCTMS := TMSTipDoc(M->DT4_CDRORI, M->DT4_CDRDES)
			M->DT4_DESDOC := TMSValField("M->DT4_DOCTMS",.F.,"DT4_DESDOC")
		Else
			M->DT4_DOCTMS := DC5->DC5_DOCTMS
			M->DT4_DESDOC := TMSValField("M->DT4_DOCTMS",.F.,"DT4_DESDOC")
		EndIf
	EndIf
	If	! Empty( aContrt )
		nFatCub       := aContrt[ 1,  2 ]		
		M->DT4_TABFRE := aContrt[ 1,  3 ]
		M->DT4_TIPTAB := aContrt[ 1,  4 ]
		M->DT4_NCONTR := aContrt[ 1,  1 ]
		If lPrcProd .And. !lAssumeFrt
			lPrcProd  := aContrt[ 1, 24 ] == "1"
		EndIf

		cCliDev := aContrt[ 1, 25 ]
		cLojDev := aContrt[ 1, 26 ]
		aPerfil := TMSPerfil(cCliDev,cLojDev,.T.,.F.)

		If lMoeda //lMoeda retorna .T. caso o tipo do campo M->DT4_MOEDA seja numérico
			M->DT4_MOEDA := MyPosicione("DTL",1,xFilial("DTL")+M->DT4_TABFRE+M->DT4_TIPTAB,"DTL_MOEDA")
			If	M->DT4_MOEDA == 0
				M->DT4_MOEDA := 1
			EndIf
		EndIf

		If lTM040FCB  //Ponto de entrada para alterar Fator de Cubagem.
			nNewFatCub := ExecBlock("TM040FCB" ,.F.,.F.,{nFatCub})
			If ValType(nNewFatCub) == 'N'
				nFatCub := nNewFatCub
			EndIf
		EndIf

		//-- Verifica a Abrangencia do Contrato quando nao e cliente generico
		If !aContrt[ 1,17 ]
			If MyPosicione("AAM",1,xFilial("AAM")+aContrt[ 1, 1 ],"AAM_ABRANG") == "2" .And.;
				Left(FunName(1),7) == "TMSA040"
				cLojDev := AAM->AAM_LOJA
			EndIf
		EndIf
		//-- Verifica se o cliente possue ajuste obrigatorio.
		lAjuste := Iif(aContrt[1,18]=="1",.T.,.F.)
	Else
		//-- Inicializa Teclas de Atalhos
		TmsKeyOn(aSetKey)
		CursorArrow()
		Return( .F. )
	EndIf

	If Empty(M->DT4_CODNEG) .And. !IsInCallStack('TMSAF05') 
		Help(' ', 1, 'TMSA04062', , , 4, 1 )	//-- Codigo da negociação está vazio
		//-- Inicializa Teclas de Atalhos
		TmsKeyOn(aSetKey)
		CursorArrow()
		Return( .F. )
	EndIf

	If lIdentDoc
		If !Empty(M->DT4_DOCTMS)
			cDocTms := M->DT4_DOCTMS
		Else
			cDocTms := TMSTipDoc(M->DT4_CDRORI, M->DT4_CDRDES)
		EndIf
	Else
		DC5->(DbSetOrder(1))
		If	DC5->(MsSeek(xFilial('DC5') + M->DT4_SERVIC))
			cDocTms := DC5->DC5_DOCTMS
		Else
			Help(' ', 1, 'TMSA04013', , STR0028 + M->DT4_SERVIC , 4, 1 )	//-- Codigo do servico nao encontrado (DC5).  //'Servico: '
			//-- Inicializa Teclas de Atalhos
			TmsKeyOn(aSetKey)
			CursorArrow()
			Return( .F. )
		EndIf
	EndIf

	If	Empty(M->DT4_CLIDES) .And. Empty(M->DT4_LOJDES) .And. Empty(M->DT4_CLIDEV) .And. Empty(M->DT4_LOJDEV) .And. M->DT4_CONTRI == StrZero(0,Len(DT4->DT4_CONTRI)) //Nao Utiliza
		Help(' ', 1, 'TMSA04054')		//-- Informe se o cliente e' um Contribuinte  ou Nao Contribuinte
		//-- Inicializa Teclas de Atalhos
		TmsKeyOn(aSetKey)
		CursorArrow()
		Return( .F. )
	EndIf

	//-- Calcula tempo de entrega
	aTmpEnt := TmsTmpEntr( DC5->DC5_TIPTRA, M->DT4_CDRORI, M->DT4_CDRDES, M->DT4_CLIDES, M->DT4_LOJDES , M->DT4_DATCOT, M->DT4_HORCOT, M->DT4_SERVIC, M->DT4_CODNEG)
	If	!Empty( aTmpEnt )
		M->DT4_TMENTI := StrTran(Left(aTmpEnt[ 1 ],Len(DT4->DT4_TMENTI)+1),':','')
		M->DT4_TMENTF := StrTran(Left(aTmpEnt[ 2 ],Len(DT4->DT4_TMENTF)+1),':','')
	EndIf

	//-- Verifica se houve alguma modicacao que afete o calculo do frete.
	If !lCalcFret .And. lRecal
		lCalcFret := TmsA040VAtu()
	EndIf

	If	! Empty( M->DT4_TABFRE ) .And. ! Empty( M->DT4_CDRORI ) .And. ! Empty( M->DT4_CDRDES ) .And.;
		! Empty( M->DT4_SERVIC ) .And. lCalcFret 

		M->DT4_DESC   := 0
		M->DT4_ACRESC := 0
		nTValPas      := 0
		nTValImp      := 0
		nTValTot      := 0
		If M->DT4_DISTIV == '2'
			nKm := M->DT4_KM
		EndIf
		cFilDes  := MyPosicione("DUY",1, xFilial("DUY") + M->DT4_CDRDES,"DUY_FILDES")

		//-- Retorna a distancia por cliente / regiao.
		If	nKm == 0
			nKm := TMSDistRot(,.F.,M->DT4_CDRORI,M->DT4_CDRDES,M->DT4_TIPTRA,DUE->DUE_CODCLI,DUE->DUE_LOJCLI,M->DT4_DISTIV=='1')
			M->DT4_KM := nKm
		EndIf

		aPesCub:= {}

		nCntAtiv :=0
		For I:=1 to Len(aCols)
			If !GDDeleted( i )
				nCntAtiv ++
			EndIf
		Next I
		//-- Verifica se Inverte a Origem no calculo
		If lDT4InvOri
			lInvOri := (M->DT4_INVORI == "1")
		EndIf
		//-- Calcula a composicao do frete
		nCntAt2 := 0
		For nCntFor := 1 To Len(aCols)
			If !GDDeleted( nCntFor ) .And. !Empty(GDFieldGet('DVF_CODPRO',nCntFor))
				nCntAt2 ++
				//-- Calcula o peso cubado pelo percentual de cubagem informado no complemento do produto
				nPerCub := TmsPerCub(GdFieldGet('DVF_CODPRO',nCntFor),cCliDev,cLojDev)
				If	!Empty(nPerCub)
					nPeso := GdFieldGet('DVF_PESO',nCntFor)
					GdFieldPut( 'DVF_FATCUB' ,0,nCntFor)
					GdFieldPut( 'DVF_PESOM3' ,nPeso + ( nPeso * ( nPerCub / 100 ) ),nCntFor)
					//-- Calcula o peso cubado pelo fator de cubagem informado no contrato do cliente
				ElseIf !Empty(nFatCub)
					nSeek := AScan(aCubagem,{|x| x[1]==GDFieldGet('DVF_CODPRO',nCntFor)})
					If	nSeek > 0
						nPQtdVol := AScan(aHeadDTE,{|x|x[2]=='DTE_QTDVOL'})
						nPAltura := AScan(aHeadDTE,{|x|x[2]=='DTE_ALTURA'})
						nPCompri := AScan(aHeadDTE,{|x|x[2]=='DTE_COMPRI'})
						nPLargur := AScan(aHeadDTE,{|x|x[2]=='DTE_LARGUR'})
						nPesoM3  := 0
						If	nPQtdVol>0 .And. nPAltura>0 .And. nPCompri>0 .And. nPLargur>0
							For n1Cnt := 1 To Len(aCubagem[nSeek,2])
								If !aCubagem[nSeek,2,n1Cnt,Len(aCubagem[nSeek,2,n1Cnt])] //--Delete
									nPesoM3 += aCubagem[nSeek,2,n1Cnt,nPQtdVol] * aCubagem[nSeek,2,n1Cnt,nPAltura] * aCubagem[nSeek,2,n1Cnt,nPCompri] * aCubagem[nSeek,2,n1Cnt,nPLargur]

										//-- Formato do vetor aPesCub
										//-- [01] = Fil.Origem
										//-- [02] = No.da Nota Fiscal
										//-- [03] = Serie da Nota Fiscal
										//-- [04] = Cliente Remetente
										//-- [05] = Loja Cliente Remetente
										//-- [06] = Produto
										//-- [07] = Altura
										//-- [08] = Largura
										//-- [09] = Comprimento

										AAdd(aPesCub,{	M->DT4_FILORI,'','',;
														M->DT4_CLIREM,M->DT4_LOJREM,GDFieldGet('DVF_CODPRO',nCntFor),; 
														aCubagem[nSeek,2,n1Cnt,nPAltura], aCubagem[nSeek,2,n1Cnt,nPLargur],aCubagem[nSeek,2,n1Cnt,nPCompri]})							  																						  
								EndIf
							Next
						EndIf
						nPesoM3 := nPesoM3 * nFatCub
										
						aRet := TamSX3("DVF_PESOM3")
						If Len(CValToChar(Int(nPesoM3))) > aRet[1] - (aRet[2] + 1)
							MsgAlert(STR0122 + CValToChar(nPesoM3) + STR0123 + SubStr(PesqPict('DVF','DVF_PESOM3'), 3), STR0032 )
							Return(.F.)
						EndIf
						GdFieldPut( 'DVF_FATCUB' ,nFatCub ,nCntFor )
						GdFieldPut( 'DVF_PESOM3' ,nPesoM3 ,nCntFor )
					EndIf
				EndIf

				aValAux :={}
				For n1Cnt := 1 To Len(aValInf)
					If !aValInf[n1Cnt,3]
						If lPrcProd .And. !lAssumeFrt
							If	aValInf[n1Cnt,6]==GDFieldGet('DVF_CODPRO',nCntFor)
								 AAdd(aValAux,{aValInf[n1Cnt,1],aValInf[n1Cnt,2],.F.,aValInf[n1Cnt,4],aValInf[n1Cnt,5],aValInf[n1Cnt,6]})
							EndIf
						Else
							nSeek := Ascan(aValAux, { |x| x[1] ==  aValInf[n1Cnt,1] })
							If nSeek > 0
								aValAux[nSeek][2] += aValInf[n1Cnt,2]
							Else
								AAdd(aValAux,{aValInf[n1Cnt,1],aValInf[n1Cnt,2],.F.,aValInf[n1Cnt,4],aValInf[n1Cnt,5],aValInf[n1Cnt,6]})
							EndIf
						EndIf
					EndIf
				Next

				If lTMSCFec
					aTipVei := {}
			
					nPosTipVei := Ascan( aHeaderDVT, { |x| AllTrim(x[2]) == 'DVT_TIPVEI' } )
					nPosQtdVei := Ascan( aHeaderDVT, { |x| AllTrim(x[2]) == 'DVT_QTDVEI' } )
					For n1Cnt := 1 To Len(aColsDVT)
						If !aColsDVT[n1Cnt][Len(aColsDVT[n1Cnt])]
							nSeek := AScan(aTipVei,{ |x| x[1] == aColsDVT[n1Cnt][nPosTipVei] })
							If	nSeek > 0
								aTipVei[nSeek,2] += aColsDVT[n1Cnt][nPosQtdVei]
							Else
								AAdd(aTipVei,{ aColsDVT[n1Cnt][nPosTipVei], aColsDVT[n1Cnt][nPosQtdVei] })
							EndIf
						EndIf
					Next
				EndIf


				If lPrcProd .And. !lAssumeFrt //-- Valor do Frete (Preco) por Produto
					nQtdVol	:= GDFieldGet( 'DVF_QTDVOL' ,nCntFor )
					nQtdUni	:= GDFieldGet( 'DVF_QTDUNI' ,nCntFor )
					nPeso	:= GDFieldGet( 'DVF_PESO'   ,nCntFor )
					nPesoM3	:= GDFieldGet( 'DVF_PESOM3' ,nCntFor )
					nValMer	:= GDFieldGet( 'DVF_VALMER' ,nCntFor )
					nBasSeg	:= GDFieldGet( 'DVF_BASSEG' ,nCntFor )
					cCodPro := GDFieldGet( 'DVF_CODPRO' ,nCntFor )
					nMetro3 := GDFieldGet( 'DVF_METRO3' , nCntFor )
					
					lTMSCalFre := .T.
				Else
					If nCntAtiv == nCntAt2
						cCodPro    := Space(Len(DVF->DVF_CODPRO))
						lTMSCalFre := .T.
					EndIf
				EndIf
				
				If lMntBase
					cCodPro := GDFieldGet( 'DVF_CODPRO' ,nCntFor )
				EndIf
				
				//-- Calcula a composicao do frete, baseado na tabela de frete especificada no contrato do cliente.
				If lTmsCalFre
					//--	Ponto de Entrada que possibilita a alteracao do valor do frete.
					//--	Cliente Devedor	- LTCLIDEV
					//--	Loja Devedor	- LTLOJDEV
					//--	Peso Cubado		- LTPESOM3
					If lTM040CUB
						nPesoPto := ExecBlock( "TM040CUB",.F.,.F.,{cCliDev, cLojDev, nPesoM3, nPeso, M->DT4_TIPFRE, M->DT4_SERVIC, M->DT4_TIPTRA, M->DT4_SERTMS,M->DT4_CODNEG } )
						If ValType(nPesoPto) == "N"
							nPesoM3  := nPesoPto
						EndIf
					EndIf

					//-- Calculo do Frete...
					aFrete := {}
					aFrete := TmsCalFret(	M->DT4_TABFRE	,;
											M->DT4_TIPTAB	,;
											@cSeqTab		,;
											M->DT4_CDRORI	,;
											M->DT4_CDRDES	,;
											cCliDev			,;
											cLojDev			,;
											cCodPro			,;
											M->DT4_SERVIC	,;
											M->DT4_SERTMS	,;
											M->DT4_TIPTRA	,;
											aContrt[ 1, 1 ]	,;
											aMsgErr			,;
															,;
											nValMer			,;
											nPeso			,;
											nPesoM3			,;
											0				,;
											nQtdVol			,;
											0				,;
											nBasSeg			,;
											nMetro3			,;
											0				,;
											0				,;
											nKm				,;
											0				,;
											.T.				,;
											lCliGen			,;
											lAjuste			,;
											0				,;
											nQtdUni			,;
											0				,;
											0				,;
											0				,;
											aValAux			,;
											aTipVei			,;
											Iif(lIdentDoc,M->DT4_DOCTMS,cDocTMS),;
											,;
											,;
											,;
											,;
											,;
											,;
											,;
											,;
											,;
											aPesCub			,;
											,;
											M->DT4_CLIDEV	,;
											M->DT4_LOJDEV	,;
											,;
											"",; // Exclui TDA
											IIF(Len(aPerfil)>=49,aPerfil[49],""),; //Paga TDA (1-Coleta, 2-Entrega, 3-Ambas, 4- Coleta ou Entrega)
											MyPosicione("SA1", 1, xFilial("SA1") + M->DT4_CLIREM + M->DT4_LOJREM, "A1_TDA"),;
											MyPosicione("SA1", 1, xFilial("SA1") + M->DT4_CLIDES + M->DT4_LOJDES, "A1_TDA"),;
											,;
											M->DT4_CLIDES,;
											M->DT4_LOJDES,;
											,;
											,;
											,;
											,;
											,;
											M->DT4_CODNEG,;
											{},;
											{},;
											  ,; //lCbrCol
											  ,; //lBlqCol
											lInvOri,;
												   ,;
												   ,;
												   ,;
												   ,;
												   ,If(Len(aContrt[1])>=53,aContrt[ 1, 53 ],''))

					//-- Atualiza a sequencia da tabela de frete retornada pela funcao de calculo.
					M->DT4_SEQTAB := cSeqTab

					nSeek := Ascan( aFrete,{|x| x[3] == 'TF' })

					If	Empty( nSeek ) .Or. Empty( aFrete[ nSeek, 2 ] ) .Or. nSeek != Len(aFrete) .Or. !Empty( aMsgErr)
						If !Empty( nSeek ) .And. Empty( aFrete[ nSeek, 2 ] )
							AAdd(aMsgErr,{ STR0082 ,'00',''}) //Valor do Frete Zerado
						ElseIf nSeek != Len(aFrete)
							AAdd(aMsgErr,{ STR0083 ,'00',''}) //Falha na linha totalizadora da composicao do frete
						EndIf
						If	! Empty( aMsgErr )
							TmsMsgErr( aMsgErr )
						EndIf
						//-- Inicializa Teclas de Atalhos
						TmsKeyOn(aSetKey)
						CursorArrow()
						aFrete := {}
						Return( .F. )
					EndIf

					If nSeek > 0
						nTotFre := aFrete[ nSeek, 2 ]
					EndIf

					//-- Calcula com a tabela alternativa.
					If !Empty( aContrt[ 1, 15 ] )	 .And. !Empty( aContrt[ 1, 16 ]	)
						//--	Ponto de Entrada que possibilita a alteracao do valor do frete.
						//--	Cliente Devedor	- LTCLIDEV 
						//--	Loja Devedor	- LTLOJDEV 
						//--	Peso Cubado		- LTPESOM3
						If lTM040CUB
							nPesoPto := ExecBlock( "TM040CUB",.F.,.F.,{cCliDev, cLojDev, nPesoM3, nPeso, M->DT4_TIPFRE, M->DT4_SERVIC, M->DT4_TIPTRA, M->DT4_SERTMS,M->DT4_CODNEG } )
							If ValType(nPesoPto) == "N"
								nPesoM3  := nPesoPto
							EndIf
						EndIf
						//-- Calculo do Frete...
						aFrtAlt := {}
						cTabAlt := aContrt[ 1, 15 ]
						cTipAlt := aContrt[ 1, 16 ]
						cSeqAlt := StrZero(0,Len( DVC->DVC_SEQTAB ))
						aFrtAlt := TmsCalFret(	cTabAlt	,;
												cTipAlt			,;
												@cSeqAlt		,;
												M->DT4_CDRORI	,;
												M->DT4_CDRDES	,;
												cCliDev			,;
												cLojDev			,;
												cCodPro			,;
												M->DT4_SERVIC	,;
												M->DT4_SERTMS	,;
												M->DT4_TIPTRA	,;
												aContrt[ 1, 1 ]	,;
												aMsgErr			,;
																,;
												nValMer			,;
												nPeso			,;
												nPesoM3			,;
												0				,;
												nQtdVol			,;
												0				,;
												nBasSeg			,;
												nMetro3			,;
												0				,;
												0				,;
												0				,;
												0				,;
												.T.				,;
												lCliGen			,;
												lAjuste			,;
												0				,;
												nQtdUni			,;
												0				,;
												0				,;
												0				,;
												aValAux			,;
												aTipVei			,;
												Iif(lIdentDoc,M->DT4_DOCTMS,cDocTMS) ,;
												,;
												,;
												,;
												,;
												,;
												,;
												,;
												,;
												,;
												aPesCub			,;
												,;
												M->DT4_CLIDEV	,;
												M->DT4_LOJDEV	,;
												,;
												"",; // Exclui TDA
												IIF(Len(aPerfil)>=49,aPerfil[49],""),;
												MyPosicione("SA1", 1, xFilial("SA1") + M->DT4_CLIREM + M->DT4_LOJREM, "A1_TDA"),;
												MyPosicione("SA1", 1, xFilial("SA1") + M->DT4_CLIDES + M->DT4_LOJDES, "A1_TDA"),;
												,;
												M->DT4_CLIDES,;
												M->DT4_LOJDES,;
												,;
												,;
												,;
												,;
												,;
												M->DT4_CODNEG,;
												{},;
												{},;
											  	  ,; //lCbrCol
											  	  ,; //lBlqCol
												lInvOri,;
												   ,;
												   ,;
												   ,;
												   ,;
												   ,If(Len(aContrt[1])>=53,aContrt[ 1, 53 ],''))

						nSeek := Ascan( aFrtAlt,{|x| x[3] == 'TF' })
						//-- Qd for tabela alternativa
						//-- Envia a mensagem somente se a linha totalizadora nao for o ultimo elemento
						//-- ou nao for encontrada no vetor aFrtAlt.
						If	Empty( nSeek ) .Or. nSeek != Len(aFrtAlt)
							If nSeek != Len(aFrtAlt)
								AAdd(aMsgErr,{ STR0083 ,'00',''}) //Falha na linha totalizadora da composicao do frete
							EndIf
							If	!Empty( aMsgErr )
								TmsMsgErr( aMsgErr )
							EndIf
							//-- Inicializa Teclas de Atalhos
							TmsKeyOn(aSetKey)
							CursorArrow()
							Return( .F. )
						EndIf

						If nSeek > 0
							nTotAlt := aFrtAlt[ nSeek, 2 ]
						EndIf

					EndIf

					//-- Considera o maior valor obtido entre as tabelas de frete e alternativa.
					If nTotAlt > nTotFre
						aFrete	:= {}
						aFrete	:= aClone( aFrtAlt )
						M->DT4_TABFRE := cTabAlt
						M->DT4_TIPTAB := cTipAlt
						M->DT4_SEQTAB := cSeqAlt
						If lMoeda //lMoeda retorna .T. caso o tipo do campo M->DT4_MOEDA seja numérico
							M->DT4_MOEDA := MyPosicione("DTL",1,xFilial("DTL")+M->DT4_TABFRE+M->DT4_TIPTAB,"DTL_MOEDA")
							If M->DT4_MOEDA == 0
								M->DT4_MOEDA := 1
							EndIf
						EndIf
					EndIf
				EndIf

				If lAssumeFrt .And. lTmsCalFre
					For n1Cnt := Len(aFrete) To 1 Step -1
						If aFrete[n1Cnt] == NIL .Or. aFrete[n1Cnt,3] == 'TF'
							Loop
						EndIf
						nSeek := Ascan(aCotAge[FRTCMPCOT], { | e | e[CODPASCMP] == aFrete[n1Cnt,3] .And. (Left(FunName(),7) <> "TMSAE75" .Or. !Empty(e[LOTEDICMP]) ) })
						If nSeek > 0
							If aCotAge[FRTCMPCOT,nSeek,TIPVALCMP] == '2' //-- Sem imposto

								If Left(FunName(),7) == "TMSAE75"
									//-- Grava aFrete[n1Cnt,2] em DET
									DET->(dbSetOrder(1))//-- DET_FILIAL+DET_LOTEDI+DET_CODPAS
									DET->(MsSeek(xFilial("DET")+aCotAge[FRTCMPCOT,nSeek,LOTEDICMP]+aCotAge[FRTCMPCOT,nSeek,CODPASCMP]))
									RecLock( "DET", .F. )
									DET->DET_VALCAL := aFrete[n1Cnt,2]
									MsUnLock()
								EndIf
								aFrete[n1Cnt,2] := aCotAge[FRTCMPCOT,nSeek,VALPASCMP]
							EndIf
						Else
							nDelCmp += 1
							Adel(aFrete,n1Cnt)							 
						EndIf
					Next n1Cnt
					If nDelCmp > 0
						ASize(aFrete,Len(aFrete)-nDelCmp)
					EndIf
					
				EndIf

				If lPrcProd .And. !lAssumeFrt
					If (lCliCot .And. !Empty(M->DT4_CLIDEV)) .Or. (!lCliCot .And. !Empty(M->DT4_CLIDEV))
						cCliCal := M->DT4_CLIDEV
						cLojCal := M->DT4_LOJDEV
						//-- Calcula impostos
						TmsA040Imp( aFrete, cCliCal, cLojCal, cDocTms, M->DT4_TIPFRE, M->DT4_CDRDES, .T. , ,cFilDes, Tmsa040TCli(), lAssumeFrt, M->DT4_CDRORI, M->DT4_FILORI, Iif(M->DT4_INCISS=="1","S","N"), M->DT4_CLIREM, M->DT4_LOJREM, M->DT4_CLIDES, M->DT4_LOJDES, , ,M->DT4_TIPNFC , cCodPro )
					Else
						//-- Calcula impostos
						TmsA040Imp( aFrete, cCliDev, cLojDev, cDocTms, M->DT4_TIPFRE, M->DT4_CDRDES, .T. , ,cFilDes, Tmsa040TCli(), lAssumeFrt, M->DT4_CDRORI, M->DT4_FILORI, Iif(M->DT4_INCISS=="1","S","N"), M->DT4_CLIREM, M->DT4_LOJREM, M->DT4_CLIDES, M->DT4_LOJDES, , ,M->DT4_TIPNFC , cCodPro )
					EndIf

					//-- O total do frete eh a soma da linha totalizadora da composicao de frete de todos os produtos da cotacao
					nSeek := Ascan( aFrete,{|x| x[3] == 'TF' })
					If	nSeek > 0
						nTValPas += aFrete[nSeek,2]
						nTValImp += aFrete[nSeek,5]
						nTValTot += aFrete[nSeek,6]
					EndIf
					AAdd(aFrtAux,{GDFieldGet('DVF_CODPRO',nCntFor),aFrete})
				Else
					If lTMSCalFre
						aFrtBac := AClone(aFrete)
						For n1Cnt :=1 To Len(aCols)
							If	! GDDeleted( n1Cnt )
								aFrete := AClone(aFrtBac)

								lUltimo := (n1Cnt == Len(aCols) .Or. aScan(aCols,{|x| !aTail(x)},n1Cnt+1) == 0)

								//-- Fazer Rateio
								TMSA040Rat(aFrete, nPeso, GdFieldGet('DVF_PESO',n1Cnt), lUltimo, aFrtAux )

								If (lCliCot .And. !Empty(M->DT4_CLIDEV)) .Or. (!lCliCot .And. !Empty(M->DT4_CLIDEV))
									cCliCal := M->DT4_CLIDEV
									cLojCal := M->DT4_LOJDEV
									//-- Calcula impostos
									TmsA040Imp( aFrete, cCliCal, cLojCal, cDocTms, M->DT4_TIPFRE, M->DT4_CDRDES, .T. , ,cFilDes, Tmsa040TCli(), , M->DT4_CDRORI, M->DT4_FILORI, Iif(M->DT4_INCISS=="1","S","N"), M->DT4_CLIREM, M->DT4_LOJREM, M->DT4_CLIDES, M->DT4_LOJDES, , ,M->DT4_TIPNFC , cCodPro )
								Else
									//-- Calcula impostos
									TmsA040Imp( aFrete, cCliDev, cLojDev, cDocTms, M->DT4_TIPFRE, M->DT4_CDRDES, .T. , ,cFilDes, Tmsa040TCli(), , M->DT4_CDRORI, M->DT4_FILORI, Iif(M->DT4_INCISS=="1","S","N"), M->DT4_CLIREM, M->DT4_LOJREM, M->DT4_CLIDES, M->DT4_LOJDES, , ,M->DT4_TIPNFC , cCodPro )
								EndIf


								//-- O total do frete eh a soma da linha totalizadora da composicao de frete de todos os produtos da cotacao
								nSeek := Ascan( aFrete,{|x| x[3] == 'TF' })
								If	nSeek > 0
									nTValPas += aFrete[nSeek,2]
									nTValImp += aFrete[nSeek,5]
									nTValTot += aFrete[nSeek,6]
								EndIf
								AAdd(aFrtAux,{GDFieldGet('DVF_CODPRO',n1Cnt),aFrete})
							EndIf
						Next
						Exit
					EndIf
				EndIf
			EndIf
		Next nCntFor
	EndIf

	If lTM040Atz
		ExecBlock('TM040ATZ',.F.,.F.,{nTValPas,nTValImp,nTValTot,nQtdVol,nQtdUni,nPeso,nPesoM3,nValMer,nMetro3})
	Endif

	//-- Funcao para pronunciar o texto "Numero da Cotacao de Frete e Valor + Imposto"
	//-- GetRemoteType - funcao que retorna o tipo do smartclient - valor 5 = identifica que foi executado pelo WebAPP
	If !lRemoteLin .And. ValType(oTValPas) == "O" .And. (GetRemoteType() != 5 .And. &(cRotSpeak))
		cExtenso:= Extenso( nTValTot,.F.,1 )
		cExtenso:= StrTran( cExtenso, ',', '')	//-- Remove o Caracter ','
		FwVSpeak(STR0099 + " " + M->DT4_NUMCOT + STR0019 + " " + cExtenso )
	EndIf

	If	! Empty(aFrtAux)
		aFrete := {}
		aFrete := AClone(aFrtAux)
		aFrtOri:= AClone(aFrete)
	EndIf

	If ValType(oTValPas) == "O"
		oTValPas:Refresh()
		oTValImp:Refresh()
		oTValTot:Refresh()
	EndIf

	If Type("oEnch") == "O"
		oEnch:Refresh()
	EndIf

EndIf

RestArea( aAreaAnt )

CursorArrow()

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA040Imp³ Autor ³ Alex Egydio           ³ Data ³27.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula impostos                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpcx500 - Opcao de Execucao do Menu no TMSA500            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA040Imp(aFrete,  cCliDev, cLojDev, cDocTms,  cTipFre, cCdrDes,;
					lUfDes,  nAlqICM, cFilDes, cTipoCli, lComImp, cCdrOri,;
					cFilOri, cIncISS, cCliRem, cLojRem,  cCliDes, cLojDes,;
					cTipoNF, lHelp,   cTipNFC, cCodPro,  cSeqIns, nOpcx500,;
					cEstVei, nDifal,  cCliCon, cLojCon)

Local nRecno		:= 0
Local aRegra		:= {}
Local aTes			:= {}
Local cPrdImp		:= ''
Local cPrdImpOld	:= ''
Local cTes			:= ''
Local cSerie		:= ''
Local lRet			:= .T.
Local nCntFor		:= 0
Local nSeek			:= 0
Local nTotFre		:= 0
Local nTotImp		:= 0
Local nValTot		:= 0
Local nBasICM		:= 0
Local nValICM		:= 0
Local nTotal		:= 0
Local lMvIncIss		:= GetMV('MV_INCISS',,.T.)
Local cFilBack		:= cFilAnt
Local nAliqISS		:= 0
Local cEstOri		:= Space(Len(DUY->DUY_EST))
Local cEstDes		:= Space(Len(DUY->DUY_EST))
Local lConsig		:= .F.
Local lSolidario	:= .F.
Local lInscr		:= .F.
Local nDescZf		:= 0
Local nAliqAgr    	:= 0
Local lAgreg      	:= .F.
Local cTipDoc		:= '0' // 0=Normal - Solicitar Regra de Tributacao para 0 - Normal
Local nValCOFINS  	:= 0
Local nValPIS     	:= 0
Local cTesEsp		:= ''
Local cMv_Estado	:= SuperGetMV("MV_ESTADO",.F.,"")
Local lAgrISS		:= .F.
Local nAlqICmp	:= 0
Local lCDRORI		:= Type('M->DT4_CDRORI') == 'C'
Local lCDRDES		:= Type('M->DT4_CDRDES') == 'C'
Local cMV_TESAWB 	:= GetMV('MV_TESAWB')
Local lTipNFC		:= Type('M->DT4_TIPNFC') == 'C'
Local lServicNIL	:= Type('M->DT4_SERVIC')=='U'
Local lNILVlrFec	:= Type("nVlrFec") != "U" // nVlrFec é uma variável Private da função TmsA040Dsc()
Local nAliqAgrCo	:= 0
DEFAULT lUfDes		:= .F.
DEFAULT nAlqICM		:= 0
DEFAULT cFilDes		:= ''
DEFAULT lComImp		:= .F.
DEFAULT cTipoCli	:= ''
DEFAULT cCdrOri		:= ''
DEFAULT cFilOri		:= ''
DEFAULT cIncIss		:= Iif(MyPosicione('SA1',1,xFilial('SA1')+cCliDev+cLojDev,'A1_INCISS')=="S","S","N")
DEFAULT cCliRem		:= ''
DEFAULT cLojRem		:= ''
DEFAULT cCliDes		:= ''
DEFAULT cLojDes		:= ''
DEFAULT cTipoNF		:= ''  //-- 'N' (Docto. Normal) / 'I' (Complemento de Imposto)
DEFAULT lHelp		:= .T.
DEFAULT cTipNFC		:= '0' //-- Tipo da Nota Fiscal : '0' (Normal) / '1' (Devoluncao) / '2' (SubContratacao)
DEFAULT cCodPro		:= Space(Len(SB1->B1_COD))
DEFAULT cSeqIns		:= ''
DEFAULT nOpcx500	:= 0
DEFAULT cEstvei		:= ''
DEFAULT cTipFre		:= Iif(Type("M->DT4_TIPFRE") <> "U", M->DT4_TIPFRE, cTipFre)
DEFAULT nDifal 		:= 0
DEFAULT cCliCon		:= ""
DEFAULT cLojCon		:= ""

If Type("lTMSA040")!='L'
	Private lTMSA040 := .F.
EndIf

If ValType(lTM040TES) == "U"
	lTM040TES	:= ExistBlock("TM040TES")
EndIf

If nOpcx500 > 0
	If (nOpcx500 == 6)		// Complemento - Solicitar Regra de Tributacao para 1 = Complemento de Frete
		cTipDoc := '1'
	ElseIf (nOpcx500 == 10)	// Complemento de Impostos - Solicitar Regra de Tributacao para 2 - Complemento de Imposto
		cTipDoc := '2'
	EndIf
EndIf

//-- Pesquisa UF Origem:
If !Empty(cCdrOri)
	cEstOri  := MyPosicione("DUY",1,xFilial('DUY')+cCdrOri,"DUY_EST")
EndIf
//-- Pesquisa UF Destino: verifica se foi informada a aliquota do ISS para regiao
If !Empty(cCdrDes)
	cEstDes  := MyPosicione("DUY",1,xFilial("DUY")+cCdrDes,"DUY_EST")
	nAliqISS := MyPosicione("DUY",1,xFilial("DUY")+cCdrDes,"DUY_ALQISS")
EndIf

//-- Verifica se o tipo do cliente/fornecedor esta preenchido
If Empty(cTipoCli)
	cTipoCli := 'F'
EndIf

If Empty(cTipoNF)
	cTipoNF := 'N'
EndIf

//-- Se esta Funcao estiver sendo chamada pela Cotacao de Frete, alterar o conteudo da variavel cFilAnt
//-- para a Filial de Origem informada pelo usuario (DT4_FILORI); Isto deve ser feito, para que os impostos
//-- utilizados sejam os da Filial informada; 
If !Empty(cFilOri)
	cFilAnt := cFilOri
EndIf

//-- Inicializa a funcao fiscal
MaFisEnd()
If !Empty(cCliDev)
	MaFisIni(cCliDev,;						//-- Codigo Cliente/Fornecedor
			 cLojDev,;					   	//-- Loja do Cliente/Fornecedor
			 Iif(cDocTms=='3','F','C'),;	//-- C=Cliente/F=Fornecedor
			 cTipoNF,;						//-- Tipo da NF
			 cTipoCli,;						//-- Tipo do Cliente/Fornecedor
			 Nil,;
			 Nil,;
			 Nil,;
			 Nil,;
			 'TMSA040')
Else
	MaFisIni(cCliDes,;						//-- Codigo Cliente/Fornecedor
			 cLojDes,;						//-- Loja do Cliente/Fornecedor
			 Iif(cDocTms=='3','F','C'),;	//-- C=Cliente/F=Fornecedor
			 'N',;							//-- Tipo da NF
			 cTipoCli,;						//-- Tipo do Cliente/Fornecedor
			 Nil,;
			 Nil,;
			 Nil,;
			 Nil,;
			 'TMSA040')
EndIf

//-- Posiciona na configuracao de documentos.
DUI->(DbSetOrder(1))
DUI->(MsSeek(xFilial("DUI")+cDocTms))
cSerie := DUI->DUI_SERIE

//-- Verifica se informou serie para origem em outra filial.
If !Empty(DUI->DUI_SEROUT)
	If	cMv_Estado <> cEstOri
		cSerie := DUI->DUI_SEROUT
	EndIf
EndIf

//-- Atualiza a especie do documento.
cEspecie := A460Especie(cSerie)
MaFisAlt('NF_ESPECIE',cEspecie, , , , , , .F./*lRecal*/)

If cTipFre = '2'
	MaFisAlt( "NF_TPFRETE","F" )
Else
	MaFisAlt( "NF_TPFRETE","" )
EndIf

If	lUfDes
	If	cDocTms == '3'  //-- AWB
		//-- Simula uma entrada na filial de destino
		//-- Posiciona na ultima filial da rota utilizada na viagem da AWB
		nRecno := SM0->(Recno())
		SM0->(MsSeek(cEmpAnt+cFilDes))
		//-- Se o destino tem inscricao estadual, considera a aliquota de icms fixado no produto
		//-- Se o destino nao tem inscricao estadual, considera a aliquota inter estadual
		MaFisAlt('NF_LINSCR' ,IIf(Empty(SM0->M0_INSC).Or."ISENT"$SM0->M0_INSC,.T.,.F.), , , , , , .F./*lRecal*/)
		MaFisAlt('NF_UFDEST' ,SM0->M0_ESTENT, , , , , , .F./*lRecal*/)
		MaFisAlt('NF_ESPECIE','CA', , , , , , .F./*lRecal*/)
		SM0->(MsGoto(nRecno))
	Else
		If !Empty(cCdrOri)
			If !Empty(cEstOri)
				MaFisAlt('NF_UFORIGEM',cEstOri, , , , , , .F./*lRecal*/)
			EndIf
		EndIf

		MaFisAlt("NF_UFDEST", cEstDes, , , , , , .F./*lRecal*/)
		
		If !Empty(cCliDes) .And. !Empty(cLojDes)
			//--Tratamento do Cliente Destinatario, como na rotina de calculo de frete
			SA1->(DbSetOrder(1))
			If SA1->(MsSeek(xFilial('SA1')+cCliDes+cLojDes))
				lInscr := IIf((Empty(SA1->A1_INSCR).Or."ISENT"$SA1->A1_INSCR.Or."RG"$SA1->A1_INSCR).Or.SA1->A1_CONTRIB=="2",.T.,.F.)
				//Se a variavel lInscr retornar True, o cliente nao e inscrito, ao contrario e considerado inscrito
			EndIf

		ElseIf Empty(cCliDes) .And. Empty(cLojDes)
			If lTMSA040
				//--Tratamento do Cliente Generico na cotacao de frete
				//--Se 'Nao Contribuinte' o cliente nao e inscrito, ao contrario e' considerado inscrito
				lInscr := IIf(M->DT4_CONTRI == StrZero(2,Len(DT4->DT4_CONTRI)),.T.,.F.)
				MaFisAlt("NF_LINSCR", lInscr, , , , , , .F./*lRecal*/)
			Else
				SA1->(DbSetOrder(1))
				If SA1->(MsSeek(xFilial('SA1')+cCliDev+cLojDev))
					If M->DT4_CONTRI == '0'
						lInscr := IIf((Empty(SA1->A1_INSCR).Or."ISENT"$SA1->A1_INSCR.Or."RG"$SA1->A1_INSCR).Or.SA1->A1_CONTRIB=="2",.T.,.F.)
					Else
						lInscr := IIf(M->DT4_CONTRI == StrZero(2,Len(DT4->DT4_CONTRI)),.T.,.F.)
					EndIf
					MaFisAlt("NF_LINSCR", lInscr, , , , , , .F./*lRecal*/)
				EndIf
			EndIf
		EndIf

		MaFisAlt("NF_PNF_UF" ,MyPosicione('SA1',1,xFilial('SA1')+cCliDev+cLojDev,'A1_EST'), , , , , , .F./*lRecal*/)
		MaFisAlt("NF_PNF_TPCLIFOR",SA1->A1_TIPO, , , , , , .F./*lRecal*/) 
		If MyPosicione('SA1',1,xFilial('SA1')+cCliDes+cLojDes,'A1_EST') == "EX"
			MaFisAlt("NF_TPCLIFOR", MyPosicione('SA1',1,xFilial('SA1')+cCliDev+cLojDev,'A1_TIPO'), , , , , , .F./*lRecal*/)
		EndIf
	EndIf
	MaFisAlt('NF_GRPCLI', MyPosicione('SA1',1,xFilial('SA1')+cCliDev+cLojDev,'A1_GRPTRIB'), , , , , , .F./*lRecal*/)
EndIf

//-- Verifica se o devedor eh o consignatario e nao eh remetente ou destinatario.
If IsIncallstack("TMSA200VPR")	
	If	cCliRem+cLojRem <> cCliCon+cLojcon .And. ;
		cCliDes+cLojDes <> cCliCon+cLojcon .And. ;
		cCliDev+cLojDev == cCliCon+cLojcon
		lConsig := .T.
	EndIf
Else
	lConsig := A040Consig(cCliRem,cLojRem,cCliDes,cLojDes,cCliDev,cLojDev)
EndIf

//-- Calcular impostos baseado na regra de tributacao de cCliDev / cLojDev
//-- Posiciona configuracao de documentos
cPrdImp := DUI->DUI_CODPRO

If lTM040PRD
	cPrdImpOld := ExecBlock("TM040PRD",.F.,.F.,{cPrdImp,cDocTms,cCdrOri,cCdrDes})
	If Valtype(cPrdImpOld) == "C" .And. !Empty(cPrdImpOld)
		cPrdImp := cPrdImpOld
	EndIf
EndIf

If !Empty(DUI->DUI_PRDCIF) .And. cTipFre == '1' //-- CIF
	cPrdImp := DUI->DUI_PRDCIF
EndIf

For nCntFor := 1 To Len(aFrete)
	If	aFrete[ nCntFor, 3 ] != 'TF'
		If Empty(cDocTms) .And. lCDRORI .And. lCDRDES 
		//lCDRORI e lCDRDES retornam .T. caso os campos M->DT4_CDRORI e M->DT4_CDRDES sejam do tipo Caracter.
			cDocTms := TMSTipDoc(M->DT4_CDRORI, M->DT4_CDRDES)
		EndIf
		//-- AWB
		If	cDocTms == '3'
			cTes := cMV_TESAWB
		Else
			If lTipNFC // lTipNFC retorna .T. caso campo M->DT4_TIPNFC seja do tipo Caracter
				cTipNFC := M->DT4_TIPNFC
			EndIf
			If IsInCallStack('TMSA040')
				TMSA040Cli(@cCliDev,@cLojDev, .T.)
			EndIf
			aRegra := TmsRegTrib(cDocTms,cTipFre,aFrete[nCntFor,3],cCliDev,cLojDev,cCdrDes,.F.,cCodPro,,cEstOri,lConsig,cTipNFC,cSeqIns, cEstVei)

			If	!Empty(aRegra)
				If lTM040TES
					cTesEsp := ExecBlock('TM040TES',.F.,.F.,{aRegra, cCliRem, cLojRem, aRegra[ 1 ], aFrete[nCntFor,3], cCliDev, cLojDev })
					If ValType(cTesEsp) == "C" .And. !Empty(cTesEsp)
						aRegra[ 1 ] := cTesEsp
					EndIf
				EndIf
				cTes := aRegra[1]
			EndIf
		EndIf
		SF4->(DbSetOrder(1))
		If !Empty(AllTrim(cTes))
			MyPosicione("SF4",1,xFilial("SF4")+cTes,"F4_CODIGO")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicia a Carga do item nas funcoes MATXFIS  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaFisIniLoad(nCntFor)
			MaFisLoad("IT_PRODUTO" , cPrdImp            , nCntFor )
			MaFisLoad("IT_QUANT"   , 1                  , nCntFor )
			MaFisLoad("IT_PRCUNI"  , aFrete[nCntFor ,2] , nCntFor )
			MaFisLoad("IT_VALMERC" , aFrete[nCntFor ,2] , nCntFor )
			MaFisLoad("IT_TES"     , cTes               , nCntFor )
		
			//-- Adiciona o codigo do componente de frete e o tes
			AAdd(aTes,{aFrete[nCntFor,3],cTes})
			//-- Aliquota do ISS por regiao
			If SF4->F4_ISS == "S"
				lAgrISS := SF4->(FieldPos("F4_AGRISS")) > 0 //Nova Regra para calcula ISS
				If lAgrISS
					If Empty(SF4->F4_AGRISS)
						lAgrISS := .F.
					Else
						lAgrISS := .T.
					EndIf
				EndIf
				If nAliqISS > 0
					MaFisLoad("IT_ALIQISS",	nAliqISS,	nCntFor)					
				EndIf
			//-- Aliquota do ICMS
			ElseIf SF4->F4_ICM == "S"
				If lTM040ICM
					nAliqICM := ExecBlock("TM040ICM",.F.,.F., { cCdrOri, cCdrDes, cCliDev, cLojDev } )
					If ValType(nAliqICM) == "N" .And. nAliqICM > 0
						MaFisLoad("IT_ALIQICM",	nAliqICM,	nCntFor)
					EndIf
				EndIf
			EndIf
		
			MaFisEndLoad(nCntFor,1)
			MaFisRecal("",nCntFor)
			If nAliqISS > 0
				DC5->(dbSetOrder(1)) //DC5_FILIAL+DC5_SERVIC
				If DC5->(MsSeek(xFilial("DC5")+Iif(lServicNIL,aFrete[nCntFor,18],M->DT4_SERVIC))) .And. DC5->DC5_DOCTMS == '5'
					MaFisAlt("IT_ALIQISS", nAliqISS, nCntFor,,,,.T./*lRecal*/)
				EndIf
			EndIf
		Else
			If lHelp
				Help(' ',1,'TMSA04043',,cDocTms+'/'+cTipFre+'/'+aFrete[nCntFor,3]+'/'+cCliDev+'-'+cLojDev+'/'+cCdrDes,4,1)	//-- Regra ou TES nao encontrado para Tipo Documento/Tipo Frete/Componente/Cliente ou Fornecedor/Regiao Destino
			EndIf
			MaFisEnd()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

If	lRet .And. !lAgrISS
	lAgreg := .F.
	For nCntFor := 1 To Len(aFrete)
		If	aFrete[ nCntFor, 3 ] != 'TF'
			nSeek := AScan(aTes,{|x|x[1]==aFrete[nCntFor,3]})
			SF4->(DbSetOrder(1))
			SF4->(MsSeek(xFilial('SF4') + aTes[nSeek,2]))

			nAliqAgr:= 0
			nValCOFINS := 0
			nValPIS := 0

			//-- Indica os valores do cabecalho
			If SF4->F4_ISS <> "S" .And. SF4->F4_ICM == "S"
				nBasICM := MaFisRet( nCntFor ,"IT_BASEICM" )
				nValICM := MaFisRet( nCntFor ,'IT_VALICM'  )
				nAlqICM := MaFisRet( nCntFor ,"IT_ALIQICM" ) //--Aliquota Interstadual (Se UF Destino estiver em MV_NORTE)
				nTotal  := MaFisRet( nCntFor ,"IT_TOTAL"   )
				nDescZf := MaFisRet( nCntFor ,"IT_DESCZF"  ) //--Desconto Zona Franca de Manaus (SUFRAMA)
				nAlqICMP:= MaFisRet( nCntFor ,"IT_ALIQCMP" ) //Aliquota para calculo do ICMS Complementar
				
			If aFrete[nCntFor][2] > 0
				nDifal := 0
				//nDifal += MaFisRet( nCntFor ,"IT_DIFAL" )
				//nDifal += MaFisRet( nCntFor ,"IT_VALCMP" )
			EndIf

			ElseIf SF4->F4_ISS == "S"
				nBasICM := MaFisRet( nCntFor ,"IT_BASEISS" )
				nValICM := MaFisRet( nCntFor ,'IT_VALISS'  )
				nAlqICM := MaFisRet( nCntFor ,"IT_ALIQISS" )
				If !lMvIncIss .And. cIncIss == "N"
					nTotal  := a410Arred(MaFisRet(nCntFor,"IT_TOTAL")/(1-(nAlqICM/100)),"D2_PRCVEN")
					nValICM := nTotal - nBasICM
				Else
					nTotal  := MaFisRet(nCntFor,"IT_TOTAL"  )
				EndIf
			
			ElseIf SF4->F4_ISS == "N" .And. SF4->F4_ICM == "N" .And. SF4->F4_LFICM <> "O"
				nBasICM := MaFisRet( nCntFor ,"IT_BASEICM" )
				nValICM := MaFisRet( nCntFor ,'IT_VALICM'  )
				nAlqICM := MaFisRet( nCntFor ,"IT_ALIQICM" )
				nTotal  := MaFisRet( nCntFor ,"IT_TOTAL"   )
				nDescZf := MaFisRet( nCntFor ,"IT_DESCZF"  ) //--Desconto Zona Franca de Manaus (SUFRAMA)
				nAlqICMP:= MaFisRet( nCntFor ,"IT_ALIQCMP" )
				
			Else //-- Base de Calculo Solidario
				nBasICM := MaFisRet( nCntFor ,"IT_BASESOL" )
				nValICM := MaFisRet( nCntFor ,'IT_VALSOL'  )+ MaFisRet(nCntFor,"LF_CRPRST")
				nAlqICM := MaFisRet( nCntFor ,"IT_ALIQSOL" )
				nTotal  := MaFisRet( nCntFor ,"IT_TOTAL"   )
				nAliqAgr:= 0

				If nBasICM > 0
					lSolidario := .T.
				EndIf
			EndIf

			If lTM040BICM
				nBasICM := ExecBlock("TM040BICM",.F.,.F.,{nBasICM, cCdrOri, cCdrDes, cCliDev, cLojDev })
			EndIf

			If SF4->F4_AGRCOF $ "C/1"
				nAliqAgrCo 	:= MaFisRet(nCntFor,"IT_ALIQCF2")
				nValCOFINS 	:= MaFisRet(nCntFor,"IT_VALCF2") 
				lAgreg := .T.
				If SF4->F4_AGRPIS $ "P/1"
					nAliqAgr    := MaFisRet(nCntFor,"IT_ALIQPS2") 
					nValPIS 	:= MaFisRet(nCntFor,"IT_VALPS2") 
				EndIf
			EndIf

			//-- Valor do imposto
			If aFrete[nCntFor][2] > 0
				aFrete[ nCntFor, 5 ] := nValICM + nValCOFINS + nValPIS + nDifal 
			EndIf

			If cTipoNF <> 'I' //-- Complemento de Imposto  (TMSA500)
				If	! TmsSomaImp(aTes[nSeek,2],cIncISS,lSolidario)
					//-- Icms destacado sem valor contabil ou sem imposto
					aFrete[ nCntFor, 6 ] := aFrete[ nCntFor, 2 ]
					If lAgreg
						aFrete[ nCntFor, 6 ] := Round(aFrete[ nCntFor, 2 ] /( 1 - (nAliqAgr/100)),2)
					EndIf
				Else
					If !(SF4->F4_ISS == "N") .Or. !(SF4->F4_ICM == "N") .Or. (SF4->F4_SITTRIB == "60")
						If	lComImp //-- Valor base digitado com imposto
							aFrete[ nCntFor, 6 ] := aFrete[ nCntFor, 2 ]
							If lAgreg
								aFrete[ nCntFor, 2 ] := aFrete[ nCntFor, 6 ] * ( ( 100 - nAlqICm - nAliqAgr - nAliqAgrCo ) / 100 )
							ElseIf SF4->F4_DIFAL == "1" .And. nDifal > 0 .And. cTipFre = '2'
								aFrete[ nCntFor, 2 ] := aFrete[ nCntFor, 6 ] * ( ( 100 - nAlqICmp ) / 100 )
							Else
								aFrete[ nCntFor, 2 ] := aFrete[ nCntFor, 6 ] * ( ( 100 - nAlqICm ) / 100 )
							EndIf
							aFrete[ nCntFor, 5 ] := aFrete[ nCntFor, 6 ] - aFrete[ nCntFor, 2 ]
						ElseIf lNILVlrFec .And. SF4->F4_INCSOL == "D"
						//-- Caso exista um favor fechado ou
						//-- Caso seja o valor do ICMS solidário deva ser deduzido do valor da duplicata
							aFrete[ nCntFor, 5 ] := (nBasICM * (nAlqICM / 100))
							aFrete[ nCntFor, 6 ] := nBasICM
						ElseIf SF4->F4_ISS == "S"
							aFrete[ nCntFor, 6 ] := nTotal - nDescZf
							aFrete[ nCntFor, 2 ] := (aFrete[ nCntFor, 6 ] + nDescZf )- aFrete[ nCntFor, 5 ]
							aFrete[ nCntFor, 5 ] := (aFrete[ nCntFor, 6 ] + nDescZf )- aFrete[ nCntFor, 2 ]
						Else
							aFrete[ nCntFor, 6 ] := nTotal
						EndIf
					Else
						If (SF4->F4_ISS == "N") .And. (SF4->F4_ICM == "N") .And. aFrete[ nCntFor, 5 ] > 0
							If aFrete[ nCntFor, 2 ] <> 0
								aFrete[ nCntFor, 6 ] := aFrete[ nCntFor, 2 ]
								If SF4->F4_LFICM <> "O" .And. SF4->F4_AGRCOF == "C"//Agrega PIS/COFINS
									aFrete[ nCntFor, 2 ] := aFrete[ nCntFor, 6 ] * ( ( 100 - (nAliqAgrCo + nAliqAgr) ) / 100 )
								ElseIf nValICM == 0 .AND. nValCOFINS > 0 .AND. nValPIS > 0 // Talvez realizar uma logica para verificar o Componente para pois nesse caso o Componente Pedagio não incide ICMS 
									aFrete[ nCntFor, 6 ] := nTotal
									aFrete[ nCntFor, 2 ] := aFrete[ nCntFor, 6 ] - ( nValICM + nValCOFINS + nValPIS )
								Else
									aFrete[ nCntFor, 2 ] := aFrete[ nCntFor, 6 ] * ( ( 100 - nAlqICM ) / 100 )
								EndIf
								aFrete[ nCntFor, 5 ] := aFrete[ nCntFor, 6 ] - aFrete[ nCntFor, 2 ]
							EndIf
						Else
							aFrete[ nCntFor, 6 ] := nTotal
						EndIf
						If (SF4->F4_ISS == "N") .And. (SF4->F4_ICM == "N") .And. aFrete[ nCntFor, 5 ] == 0
							aFrete[ nCntFor, 5 ] := aFrete[ nCntFor, 6 ] - aFrete[ nCntFor, 2 ]
						EndIf
					EndIf
				EndIf
			Else
				aFrete[ nCntFor, 6 ] := aFrete[ nCntFor, 2 ]
				aFrete[ nCntFor, 2 ] := aFrete[ nCntFor, 6 ]
				aFrete[ nCntFor, 5 ] := aFrete[ nCntFor, 6 ]
			EndIf
			nTotFre += aFrete[ nCntFor, 2 ]
			nTotImp += aFrete[ nCntFor, 5 ]
			nValTot += aFrete[ nCntFor, 6 ]
		EndIf
	Next
	//-- Atualiza o total do frete
	nSeek := AScan(aFrete,{|x| x[3]=='TF' })
	If nSeek > 0
		aFrete[ nSeek, 2 ] := nTotFre
		aFrete[ nSeek, 5 ] := nTotImp
		aFrete[ nSeek, 6 ] := nValTot
	EndIf
EndIf

// Nova Maneira para calculo do frete, nos casos de ISS o sistema passa a verificar o novo campo F4_AGRISS
// com isso a variavel nTotal sempre vira com o valor correto de imposto seja para imbutir ou destacar o imposto
// não sendo mais necessário calcular aqui na rotina,
// Obs os casos que ainda deverão ser retirado gradativamente.
If	lRet .And. lAgrISS
	lAgreg := .F.
	For nCntFor := 1 To Len(aFrete)
		If	aFrete[ nCntFor, 3 ] != 'TF'
			nSeek := AScan(aTes,{|x|x[1]==aFrete[nCntFor,3]})
			SF4->(DbSetOrder(1))
			SF4->(MsSeek(xFilial('SF4') + aTes[nSeek,2]))

			nAliqAgr:= 0
			nValCOFINS := 0
			nValPIS := 0

			//-- Indica os valores do cabecalho
			If SF4->F4_ISS <> "S" .And. SF4->F4_ICM == "S"
				nBasICM := MaFisRet( nCntFor ,"IT_BASEICM" )
				nValICM := MaFisRet( nCntFor ,'IT_VALICM'  )
				nAlqICM := MaFisRet( nCntFor ,"IT_ALIQICM" )
				nTotal  := MaFisRet( nCntFor ,"IT_TOTAL"   )
				nDescZf := MaFisRet( nCntFor ,"IT_DESCZF"  ) //--Desconto Zona Franca de Manaus (SUFRAMA)
			ElseIf SF4->F4_ISS == "S" .And. !Empty(SF4->F4_AGRISS)  // Nova Regra para calcula ISS 
				nBasICM := MaFisRet( nCntFor ,"IT_BASEISS" )
				nValICM := MaFisRet( nCntFor ,'IT_VALISS'  )
				nAlqICM := MaFisRet( nCntFor ,"IT_ALIQISS" )
				nTotal  := MaFisRet( nCntFor ,"IT_TOTAL"   )
			Else
				nBasICM := MaFisRet( nCntFor ,"IT_BASESOL" )
				nValICM := MaFisRet( nCntFor ,'IT_VALSOL'  )+ MaFisRet(nCntFor,"LF_CRPRST")
				nAlqICM := MaFisRet( nCntFor ,"IT_ALIQSOL" )
				nTotal  := MaFisRet( nCntFor ,"IT_TOTAL"   )
				nAliqAgr:= 0

				If nBasICM > 0
					lSolidario := .T.
				EndIf
			EndIf

			If lTM040BICM
				nBasICM := ExecBlock("TM040BICM",.F.,.F.,{nBasICM, cCdrOri, cCdrDes, cCliDev, cLojDev })
			EndIf

			If SF4->F4_AGRCOF == "C"
				nAliqAgr += MaFisRet(nCntFor,"IT_ALIQCF2")
				nValCOFINS := Round(nTotal * (MaFisRet(nCntFor,"IT_ALIQCF2")/100),2)
				lAgreg := .T.
				If SF4->F4_AGRPIS == "P"
					nAliqAgr += MaFisRet(nCntFor,"IT_ALIQPS2")
					nValPIS := Round(nTotal * (MaFisRet(nCntFor,"IT_ALIQPS2")/100),2)
				EndIf
			EndIf

			//-- Valor do imposto
			aFrete[ nCntFor, 5 ] := nValICM + nValCOFINS + nValPIS

			If cTipoNF <> 'I' //-- Complemento de Imposto  (TMSA500)
				If	! TmsSomaImp(aTes[nSeek,2],cIncISS,lSolidario)
					//-- Icms destacado sem valor contabil ou sem imposto
					aFrete[ nCntFor, 6 ] := nTotal
					If lAgreg
						aFrete[ nCntFor, 6 ] := Round(aFrete[ nCntFor, 2 ] /( 1 - (nAliqAgr/100)),2)
					EndIf
				Else
					If	lComImp	//-- Valor base digitado com imposto
						aFrete[ nCntFor, 6 ] := nTotal
						If lAgreg
							aFrete[ nCntFor, 2 ] := aFrete[ nCntFor, 6 ] * ( ( 100 - nAlqICm - nAliqAgr ) / 100 )
						Else
							aFrete[ nCntFor, 2 ] := aFrete[ nCntFor, 6 ] * ( ( 100 - nAlqICm ) / 100 )
						EndIf
						aFrete[ nCntFor, 5 ] := aFrete[ nCntFor, 6 ] - aFrete[ nCntFor, 2 ]
					ElseIf lNILVlrFec .And. SF4->F4_INCSOL == "D"
					//-- Caso exista um favor fechado ou
					//-- Caso seja o valor do ICMS solidário deva ser deduzido do valor da duplicata
						aFrete[ nCntFor, 5 ] := (nBasICM * (nAlqICM / 100))
						aFrete[ nCntFor, 6 ] := nBasICM
					ElseIf SF4->F4_ISS == "S"
						aFrete[ nCntFor, 6 ] := nTotal - nDescZf
						aFrete[ nCntFor, 2 ] := (aFrete[ nCntFor, 6 ] + nDescZf )- aFrete[ nCntFor, 5 ]
						aFrete[ nCntFor, 5 ] := (aFrete[ nCntFor, 6 ] + nDescZf )- aFrete[ nCntFor, 2 ]
					Else
						aFrete[ nCntFor, 6 ] := nTotal
					EndIf
				EndIf
			Else
				aFrete[ nCntFor, 6 ] := aFrete[ nCntFor, 2 ]
				aFrete[ nCntFor, 2 ] := aFrete[ nCntFor, 6 ]
				aFrete[ nCntFor, 5 ] := aFrete[ nCntFor, 6 ]
			EndIf
			nTotFre += aFrete[ nCntFor, 2 ]
			nTotImp += aFrete[ nCntFor, 5 ]
			nValTot += aFrete[ nCntFor, 6 ]
		EndIf
	Next
	//-- Atualiza o total do frete
	nSeek := AScan(aFrete,{|x| x[3]=='TF' })
	If nSeek > 0
		aFrete[ nSeek, 2 ] := nTotFre
		aFrete[ nSeek, 5 ] := nTotImp
		aFrete[ nSeek, 6 ] := nValTot
	EndIf
EndIf
cFilAnt := cFilBack
MaFisEnd()

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA040Lin³ Autor ³ Alex Egydio           ³ Data ³22.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes da linha da GetDados                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA040LinOk()

Local lRet       := .T.
Local nI     := 0
Local aProds := {}
Local cCliRRE   := ""
Local cLojRRE   := ""
Local aRetRRE   := {}
Local aDiverg   := {}
Local nPos      := 0
Local aVetCli   := {}
Local aVetRRE   := {}

//-- Nao avalia linhas deletadas
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- Analisa se ha itens duplicados na GetDados.
	lRet := GDCheckKey( { 'DVF_CODPRO' }, 4 )

	//-------------------------------------------------------------------------------------------------
	// Divergencia De Produtos ( Notifica Usuário Sobre Divergências )
	//-------------------------------------------------------------------------------------------------
	If lRet .And. lTmsa029

		For nI := 1 To Len(aCols)

			If !GDdeleted(nI)

				cProd := GdFieldGet("DVF_CODPRO",nI)
				// Carrega Vetor De Produtos Para Testar Incompatibilidade
				If Len(aCols) > 1 .And. ("A" $ cMV_TMSINCO .Or. "F" $ cMV_TMSINCO)
					If aScan(aProds,cProd) == 0
						aAdd(aProds,cProd)
					EndIf
				EndIf
				If "2" $ cMV_TMSRRE 
					cCliRRE:= Iif(Empty(M->DT4_CLIDEV),DUE->DUE_CODCLI,M->DT4_CLIDEV)
					cLojRRE:= Iif(Empty(M->DT4_LOJDEV),DUE->DUE_LOJCLI,M->DT4_LOJDEV)

					If !Empty(cCliRRE) .And. !Empty(cLojRRE)
						nPos:= aScan(aVetRRE, {|x| x[1] + x[2] + x[3] == cCliRRE + cLojRRE+ GdFieldGet('DVF_CODPRO',nI) })
						If nPos > 0
							aVetRRE[nPos][4]+= GdFieldGet('DVF_QTDVOL',nI)
							aVetRRE[nPos][5]+= GdFieldGet('DVF_PESO',nI)
							aVetRRE[nPos][6]+= GdFieldGet('DVF_PESOM3',nI)
							aVetRRE[nPos][7]+= GdFieldGet('DVF_VALMER',nI)
						Else
							Aadd(aVetRRE,{cCliRRE, cLojRRE, GdFieldGet('DVF_CODPRO',nI), GdFieldGet('DVF_QTDVOL',nI), GdFieldGet('DVF_PESO',nI), GdFieldGet('DVF_PESOM3',nI), GdFieldGet('DVF_VALMER',nI),'', 0 })
						EndIf
						//--- Totalizador do Valor da Mercadoria por Cliente
						nPos:= aScan(aVetCli, {|x| x[1] + x[2] == cCliRRE + cLojRRE })
						If nPos > 0
							aVetCli[nPos][3]+= GdFieldGet('DVF_VALMER',nI)
						Else
							Aadd(aVetCli,{cCliRRE, cLojRRE, GdFieldGet('DVF_VALMER',nI)})
						EndIf
					EndIf

				EndIf

			EndIf
		Next nI	

		//--- Verifica Regras de Restricao de Embarque
		If "2" $ cMV_TMSRRE  
			If Len(aVetRRE) > 0
				For nI:= 1 To Len(aVetCli)
					aEval(aVetRRE, {|x| Iif( x[1]+x[2] == aVetCli[nI][1] + aVetCli[nI][2], x[9]+= aVetCli[nI][3], .T.) })  //Atualiza valor total por Cliente
				Next nI

				aRetRRE:= TmsRetRRE(aVetRRE,,,,)
				For nI:= 1 To Len(aRetRRE)
					aAdd(aDiverg,{aRetRRE[nI][4],'RR',/*aRetRRE[nI][1],*/aRetRRE[nI][6]})
				Next nI
			EndIf
		EndIf

		//-- Verifica Divergencia De Produtos
		If Len(aProds) > 1

			aProds  := TmsRtDvP(aProds) // Determina Divergencias entre os Produtos Do Vetor

			// Impede a Repetição De Informação a Cada Linha Do aCols
			// Só Informa Se Produto Posicionado For Um Dos Produtos Divergentes
			If Len(aProds) > 1 
				If Ascan(aProds,{ |x| x[1] == cProd } ) > 0
					For nI := 1 To Len(aProds)
						aAdd(aDiverg,{aProds[nI,1],'CR',aProds[nI,2]})
					Next nI
				EndIf
			EndIf
		Else

			//-- Limpa Bloqueios Antigos Caso Existam
			Tmsa029Blq( 5  ,;		//-- 01 - nOpc
						'TMSA040',;			//-- 02 - cRotina
						Nil  ,;				//-- 03 - cTipBlq
						DT4->DT4_FILORI,;		//-- 04 - cFilOri
						'DT4' ,;				//-- 05 - cTab
						'1' ,;					//-- 06 - cInd
						xFilial('DT4') + DT4->DT4_FILORI + DT4->DT4_NUMCOT,; //-- 07 - cChave
						"" ,;					//-- 08 - cCod
						"" ,;					//-- 09 - cDetalhe
						)						//-- 10 - Opcao da Rotina

		EndIf

		If Len(aDiverg) > 0

			SaveInter()
			//--lRet := TmsListDiv(aDiverg)
			TmsListDiv(aDiverg) //-- Monta Dialog Com RRE e Divergencias de Produtos
			RestInter()

			// Deleta Linha
			/*/-- Removido Pois Foi Removido Da Dialog Os Botões para Confirmar/Recusar (Tratamento Manual Do Usuário.
			If !lRet
				aCols[n,Len(aHeader) + 1] := .t.
				// Atualiza Browse
				If Type("oGetD") == "O"
					oGetD:Refresh()
				EndIf
			EndIf
			/*/
		EndIf
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA040TOk³ Autor ³ Alex Egydio           ³ Data ³01.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a digitacao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA040TOk(nOpcx)

Local lRet		:= .T.
Local aCtrt     := {}
Local lCliCot   := SuperGetMV("MV_CLICOT",Nil,.F.) //-- Utiliza o cliente informado no Cadastro de Solicitantes

If lAprova										//-- Aprovacao
	//-- Analisa se os campos obrigatorios da Enchoice foram informados.
	If ! Obrigatorio( aGets, aTela )
		Return( .F. )
	EndIf
	
	If Empty( M->DT4_CLIREM ) .Or. Empty( M->DT4_LOJREM )
		Help(' ', 1, 'TMSA04007')			//-- Informe o cliente remetente.
		Return( .F. )
	ElseIf Empty( M->DT4_CLIDES ) .Or. Empty( M->DT4_LOJDES )
		Help(' ', 1, 'TMSA04008')			//-- Informe o cliente destinatario.
		Return( .F. )
	ElseIf Empty( M->DT4_CLIDEV ) .Or. Empty( M->DT4_LOJDEV )
		Help(' ', 1, 'TMSA04009')			//-- Informe o cliente devedor.
		Return( .F. )
	EndIf


	//-- Verifica se o Tipo de Frete foi informado
	If Empty(M->DT4_TIPFRE)
		Help(' ', 1, 'TMSA04060') //-- Não é permitido que o tipo de frete fique em branco.
		Return( .F. )
	EndIf
	//-- Verifica se o servico foi informado
	If Empty(M->DT4_SERVIC)
		Help(' ', 1, 'TMSA04061') //-- Não é permitido que o serviço fique em branco.
		Return( .F. )
	EndIf
	//-- Verifica se o codigo da negociacao foi informado
	If Empty(M->DT4_CODNEG)
		Help(' ', 1, 'TMSA04058') //-- Não é permitido que o código da negociação fique em branco.
		Return( .F. )
	EndIf
	
ElseIf lCancela								//-- Cancelamento
	
	If Empty( M->DT4_DATCAN ) .Or. Empty( M->DT4_OBSCAN )
		Help(' ', 1, 'TMSA04006')			//-- Informe a data e motivo do cancelamento.
		Return( .F. )
	EndIf
	Return( .T. )
	
Else
	//-- Analisa se os campos obrigatorios da Enchoice foram informados
	If ! Obrigatorio( aGets, aTela )
		Return( .F. )
	EndIf 
	
	//-- Verifica se existe nao conformidade
	//-- na digitacao dos clientes na guia "Aprovacao"
	If (!Empty( M->DT4_CLIREM ) .And. Empty( M->DT4_LOJREM )) .Or. (Empty( M->DT4_CLIREM ) .And. !Empty( M->DT4_LOJREM ))
		Help(' ', 1, 'TMSA04007')			//-- Informe o cliente remetente.
		Return( .F. )
	ElseIf (!Empty( M->DT4_CLIDES ) .And. Empty( M->DT4_LOJDES )) .Or. (Empty( M->DT4_CLIDES ) .And. !Empty( M->DT4_LOJDES ))
		Help(' ', 1, 'TMSA04008')			//-- Informe o cliente destinatario.
		Return( .F. )
	ElseIf (!Empty( M->DT4_CLIDEV ) .And. Empty( M->DT4_LOJDEV )) .Or. (Empty( M->DT4_CLIDEV ) .And. !Empty( M->DT4_LOJDEV ))
		Help(' ', 1, 'TMSA04009')			//-- Informe o cliente devedor.
		Return( .F. )
	EndIf

	//-- Verifica se o Tipo de Frete foi informado
	If Empty(M->DT4_TIPFRE)
		Help(' ', 1, 'TMSA04060') //-- Não é permitido que o tipo de frete fique em branco.
		Return( .F. )
	EndIf
	//-- Verifica se o servico foi informado
	If Empty(M->DT4_SERVIC)
		Help(' ', 1, 'TMSA04061') //-- Não é permitido que o serviço fique em branco.
		Return( .F. )
	EndIf
	//-- Verifica se o codigo da negociacao foi informado
	If Empty(M->DT4_CODNEG)
		Help(' ', 1, 'TMSA04058') //-- Não é permitido que o código da negociação fique em branco.
		Return( .F. )
	EndIf
	
	//-- Analisa o linha ok
	If	! TmsA040LinOk()
		Return( .F. )
	EndIf
	//-- Analisa se todas os itens da GetDados estao deletados
	If	Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
		Help( ' ', 1, 'OBRIGAT2') //Um ou alguns campos obrigatorios nao foram preenchidos no Browse.
		Return( .F. )
	EndIf
	If	Empty(M->DT4_SERVIC)
		Help('',1,'TMSA05041')  // Informe o Servico ...
		Return( .F. )
	EndIf
	If M->DT4_TIPTRA == StrZero(4,Len(DT4->DT4_TIPTRA)) //-- Rodoviario Internacional
		If Empty(M->DT4_INCOTE)
			MsgAlert("Informe o incoterm...")
			Return( .F. )
		ElseIf Empty(M->DT4_ROTA)
			MsgAlert("Informe a Rota...")
			Return( .F. )
		EndIf
	EndIf
	//-- Valida se a regiao de Origem esta habilitada para o Servico de Transporte
	//-- e Tipo de Transporte
	If !TmsChkDTN( M->DT4_SERTMS, M->DT4_TIPTRA, M->DT4_CDRORI )
		Return( .F. )
	EndIf
	//-- Valida se a regiao de Destino esta habilitada para o Servico de Transporte
	//-- e Tipo de Transporte
	If !TmsChkDTN( M->DT4_SERTMS, M->DT4_TIPTRA, M->DT4_CDRDES )
		Return( .F. )
	EndIf

	If	Empty(M->DT4_CLIDES) .And. Empty(M->DT4_LOJDES) .And. M->DT4_CONTRI == StrZero(0,Len(DT4->DT4_CONTRI)) //Nao Utiliza
		Help(' ', 1, 'TMSA04054')		//-- Informe se o cliente e' um Contribuinte  ou Nao Contribuinte
		Return( .F. )
	EndIf
EndIf

If lTM040TOk
	lRet := ExecBlock('TM040TOK',.F.,.F.,{nOpcx})
EndIf

If lRet .And. !l040Auto
	//-- Calcula a composicao do frete
	lRet := TmsA040Atz()
Endif

If	lRet .And. nOpcx <> 2 .And. ! Empty(M->DT4_CLIDEV) .And. ! Empty(M->DT4_LOJDEV) .And. !lCliCot
	aCtrt := TMSContrat( M->DT4_CLIDEV, M->DT4_LOJDEV,, M->DT4_SERVIC, .F., M->DT4_TIPFRE,,,,,,,,,,,,,,,,M->DT4_CODNEG )
	If	! Empty( aCtrt )
		//-- Na aprovacao se existir contrato para o cliente devedor envia aviso.
		If	! aCtrt[ 1, 17 ]
			If !MsgYesNo( STR0084 +  M->DT4_CLIDEV + '/' + M->DT4_LOJDEV + STR0085 + aCtrt[ 1, 1 ] + STR0086 ) //"Existe Contrato para o Cliente Devedor : " ### ". No do Contrato : " ### "  . Confirma Cotacao ?"
				Return( .F. )
			EndIf
		EndIf
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA040Can³ Autor ³ Alex Egydio           ³ Data ³01.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cancelamento da cotacao de frete.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial Origem                                      ³±±
±±³          ³ ExpC2 - Numero da Cotacao                                  ³±±
±±³          ³ ExpD1 - Data de Cancelamento da Cotacao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA040 / TMSA360                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA040Can(cFilOri,cNumCot,dDatCan)
Local aAreaAnt  := GetArea()
Local cAliasNew := ""
Local cMemo     := ""
Local nCntFor   := 1
Local cQuery    := ""

Default cFilOri := M->DT4_FILORI
Default cNumCot := M->DT4_NUMCOT
Default dDatCan := M->DT4_DATCAN

DT4->(DbSetOrder(1))
If	DT4->( MsSeek( xFilial('DT4') + cFilOri + cNumCot, .F. ) )
	RecLock('DT4',.F.)
	DT4->DT4_DATCAN := dDatCan
	//-- Grava status como 9 - Cancelado.
	DT4->DT4_STATUS := StrZero( 9, Len( DT4->DT4_STATUS ) )
	//-- Grava campos memo.
	If Type('aMemos') == 'A'
		For nCntFor := 1 To Len( aMemos )
			cMemo := aMemos[ nCntFor, 2 ]
			MSMM( &( aMemos[ nCntFor, 1 ] ), TamSx3( aMemos[ nCntFor,2 ] )[ 1 ],, &cMemo, 1,,, 'DT4', aMemos[ nCntFor,1] )
		Next
	EndIf
	MsUnLock()

	DT5->( DbSetOrder( 5 ) )
	If	DT5->( MsSeek( xFilial('DT5') + cFilOri + cNumCot, .F. ) )
		//-- Variaveis para solicitacao de coleta.
		RegToMemory('DT5',.F.)
		M->DT5_DATCAN := dDataBase
		M->DT5_OBSCAN := STR0033 //'Cancelamento automatico.'
		//-- Rotina de cancelamento da solicitacao de coleta.
		TmsA460Grava( 5,,.T. )
	EndIf

	//-- Exclui o relacionamento cotacao x agendamento (Carga Fechada)
	TMSAF05RelC(cFilOri,cNumCot)

	//-- Limpa o relacionamento entre Cotação X Lote EDI ( DET )
	If AliasInDic("DET")
		DET->(dbSetOrder(2)) //DET_FILIAL+DET_FILORI+DET_NUMCOT
		cAliasNew := GetNextAlias()
		cQuery += " SELECT R_E_C_N_O_ DETRECNO "
		cQuery += "  FROM " + RetSqlName("DET")
		cQuery += " WHERE DET_FILIAL = '" + xFilial("DET") + "' "
		cQuery += "   AND DET_FILORI = '" + cFilOri + "' "
		cQuery += "   AND DET_NUMCOT = '" + cNumCot + "' "
		cQuery += "   AND D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
		While (cAliasNew)->(!Eof())
			DET->(dbGoTo((cAliasNew)->(DETRECNO)))
			RecLock('DET',.F.)
			DET->DET_NUMCOT := ""	
			MsUnlock()
			(cAliasNew)->(dbSkip())
		EndDo
		(cAliasNew)->( DbCloseArea() )
	EndIf

	//-------------------------------------------------------------------------------------------------
	//-- Deleta Referencias De Bloqueio Da Tabela DDU Caso Existam
	//-------------------------------------------------------------------------------------------------
	If FindFunction("TMSA029USE") .And. Tmsa029Use("TMSA040")

		Tmsa029Blq( 5  ,;				//-- 01 - nOpc
					'TMSA040',;		//-- 02 - cRotina
					Nil   ,;			//-- 03 - cTipBlq
					cFilOri,;			//-- 04 - cFilOri
					'DT4' ,;			//-- 05 - cTab
					'1' ,;				//-- 06 - cInd
					xFilial('DT4') + cFilOri + cNumCot,; //-- 07 - cChave
					""				,;	//-- 08 - cCod
					"" 				,;	//-- 09 - cDetalhe
					)					//-- 10 - Opcao da Rotina
	EndIf
EndIf

RestArea( aAreaAnt )
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA040Grv³ Autor ³ Alex Egydio           ³ Data ³01.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao de manutencao                                ³±±
±±³          ³ ExpC1 = No. da Solicitacao de Coleta                       ³±±
±±³          ³ ExpC2 = No. da Cotacao de Frete                            ³±±
±±³          ³ ExpL1 = Executado via Rotina Automatica                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA040Grv( nOpcx, cSolicit, cCotacao )

Local bCampo	:= { |nCpo| Field(nCpo) }
Local cMemo		:= ''
Local cNumCot	:= ''
Local nCntFor	:= 0
Local nPQtdVol  := AScan(aHeadDTE,{|x|x[2]=='DTE_QTDVOL'})
Local n1Cnt		:= 0
Local n2Cnt		:= 0
Local nI        := 0
Local nMaxDesc  := 0

If Type('lMostraTela')!='L'
	Private lMostraTela := .T.
EndIf

If	nOpcx == 3 .Or. nOpcx == 4		// Incluir ou Alterar

	If	nOpcx == 3
		cNumCot := TMSVldChav('DT4','DT4_NUMCOT',M->DT4_FILORI,M->DT4_NUMCOT,,1)
		If	cNumCot != M->DT4_NUMCOT
			Help('',1,'TMSA04042',, STR0087 + cNumCot,5,1) //-- O codigo sugerido para a cotacao ja foi utilizado por outra estacao ### 'O novo codigo da cotacao sera : '
			M->DT4_NUMCOT := cNumCot
		EndIf
	EndIf

	//-- Exclui a composicao do frete
	DT8->( DbSetOrder( 1 ) )
	While DT8->( MsSeek( xFilial('DT8') + M->DT4_FILORI + M->DT4_NUMCOT, .F. ) )
		RecLock('DT8',.F.,.T.)
		DT8->( DbDelete() )
		MsUnLock()
	EndDo
	
	//-- Exclui os valores informados
	DVQ->( DbSetOrder( 1 ) )
	While DVQ->( MsSeek( xFilial('DVQ') + M->DT4_FILORI + M->DT4_NUMCOT, .F. ) )
		RecLock('DVQ',.F.,.T.)
		DVQ->( DbDelete() )
		MsUnLock()
	EndDo

	If Len(aCubagem) > 0  // Copiou a Cotacao nao efetuou o preenchimento entao nao pode apagar caso exista	
		//-- Exclui cubagem de mercadorias
		DTE->( DbSetOrder( 2 ) )
		While DTE->( MsSeek( xFilial('DTE') + M->DT4_FILORI + M->DT4_NUMCOT, .F. ) )
			RecLock('DTE',.F.,.T.)
			DTE->( DbDelete() )
			MsUnLock()
		EndDo
	EndIf
	
	Begin Transaction
	DT4->( DbSetOrder( 1 ) )
	If	DT4->( MsSeek( xFilial('DT4') + M->DT4_FILORI + M->DT4_NUMCOT, .F. ) )
		RecLock('DT4',.F.)
	Else
		RecLock('DT4',.T.)
	EndIf
	
	For nCntFor := 1 To FCount()
		If FieldName( nCntFor ) == 'DT4_FILIAL'
			FieldPut( nCntFor, xFilial('DT4') )
		Else
			FieldPut( nCntFor, M->&( Eval( bCampo, nCntFor ) ) )
		EndIf
	Next
	//-- Grava status como 1 - Pendente.
	DT4->DT4_STATUS := StrZero( 1, Len( DT4->DT4_STATUS ) )
	//-- Grava campos memo.
	If Type('aMemos') == 'A'
		For nCntFor := 1 To Len( aMemos )
			cMemo := aMemos[ nCntFor, 2 ]
			If	nOpcx == 3 .Or. nOpcx == 4	//Inclusao ou Copia
				MSMM(,TamSx3( aMemos[ nCntFor, 2 ] )[ 1 ],, &cMemo, 1,,, 'DT4', aMemos[ nCntFor, 1 ] )
			Else
				MSMM( &( aMemos[ nCntFor, 1 ] ), TamSx3( aMemos[ nCntFor, 2 ] )[ 1 ],, &cMemo, 1,,, 'DT4', aMemos[ nCntFor, 1 ] )
			EndIf
		Next
	EndIf
	
	MsUnLock()
	If __lSX8
		ConfirmSX8()
	EndIf

	//-- Grava itens da cotacao de frete
	For nCntFor := 1 To Len( aCols )
		If	!GDDeleted( nCntFor )
			DVF->(DbSetOrder(1))
			If	DVF->(MsSeek(xFilial('DVF') + M->DT4_FILORI + M->DT4_NUMCOT + GDFieldGet('DVF_ITEM',nCntFor) ))
				RecLock('DVF',.F.)
			Else
				RecLock('DVF',.T.)
				DVF->DVF_FILIAL := xFilial('DVF')
				DVF->DVF_FILORI := M->DT4_FILORI
				DVF->DVF_NUMCOT := M->DT4_NUMCOT
			EndIf
			
			For n1Cnt := 1 To Len(aHeader)
				If	aHeader[n1Cnt,10] != 'V'
					FieldPut(FieldPos(aHeader[n1Cnt,2]), aCols[nCntFor,n1Cnt])
				EndIf
			Next
			MsUnLock()
			
		Else
			DVF->(DbSetOrder(1))
			If	DVF->(MsSeek(xFilial('DVF') + M->DT4_FILORI + M->DT4_NUMCOT + GDFieldGet('DVF_ITEM',nCntFor)))
				RecLock('DVF',.F.,.T.)
				DVF->(DbDelete())
				MsUnLock()
			EndIf
		EndIf
	Next
	//-- Grava composicao do frete
	If Len(aFrete) > 0
		//-- Recupera original para EDI Automatico.
		If Left(FunName(),7) == "TMSAE75" .And. Len(aFrtOri) > 0 .And. Len(aFrete[1]) <> Len(aFrtOri[1])
			aFrete := aClone(aFrtOri)
		EndIf
		TmsGrvDT8( 'TMSA040', M->DT4_FILORI, M->DT4_NUMCOT, , , ,aFrete , .T. )
	EndIf
	//-- Grava cubagem de mercadorias
	For nCntFor := 1 To Len(aCubagem)
		For n1Cnt := 1 To Len(aCubagem[nCntFor,2])
			If	! aCubagem[nCntFor,2,n1Cnt,Len(aHeadDTE)+1] .And. ! Empty(aCubagem[nCntFor,2,n1Cnt,nPQtdVol])
				RecLock('DTE',.T.)
				DTE->DTE_FILIAL := xFilial('DTE')
				DTE->DTE_FILORI := M->DT4_FILORI
				DTE->DTE_NUMCOT := M->DT4_NUMCOT
				DTE->DTE_CODPRO := aCubagem[nCntFor,1]
				For n2Cnt := 1 To Len(aHeadDTE)
					If	aHeadDTE[ n2Cnt, 10 ] != 'V'
						FieldPut( FieldPos( aHeadDTE[ n2Cnt, 2 ] ), aCubagem[ nCntFor, 2, n1Cnt, n2Cnt ] )
					EndIf
				Next
				MsUnLock()
			EndIf
		Next
	Next
		
	//-- Aprova a cotacao se os dados de aprovacao estiverem preenchidos.
	If	! Empty( M->DT4_CLIREM ) .And. ! Empty( M->DT4_LOJREM ) .And.;
		! Empty( M->DT4_CLIDES ) .And. ! Empty( M->DT4_LOJDES ) .And.;
		! Empty( M->DT4_CLIDEV ) .And. ! Empty( M->DT4_LOJDEV ) .And.;
		! Empty( aContrt )
		TmsA040Apr(nOpcx)
	Else	
		If (lMostraTela .And. !l040Auto) //.And. TmsA040Blq()

			// Verifica Se Existem Divergencias De Produtos (ONU) e ou RRE
			DT4->( DbSetOrder( 1 ) )
			If	DT4->( MsSeek( xFilial('DT4') + M->DT4_FILORI + M->DT4_NUMCOT ) )
				
				Tmsa040DDU()
				
				// Bloqueio Por Desconto
				If TmsA040Blq(DT4->DT4_STATUS)
	
					DT4->( DbSetOrder( 1 ) )
					If	DT4->( MsSeek( xFilial('DT4') + M->DT4_FILORI + M->DT4_NUMCOT ) )
	
						If DT4->DT4_STATUS <> StrZero( 5, Len( DT4->DT4_STATUS ) )
							RecLock('DT4',.F.)
							//-- Grava status como 2 - Bloqueado se o desconto for maior que os descontos definidos no contrato.
							DT4->DT4_STATUS := StrZero( 2, Len( DT4->DT4_STATUS ) )
							MsUnLock()
						EndIf	
	
						// Define Se Usa Novo Modelo De Bloqueio Tab. DDU
						If FindFunction("TMSA029USE") .And. Tmsa029Use("TMSA040")
	
							nMaxDesc := Max( nMaxDesc ,aContrt[1 ,10] )
							nMaxDesc := Max( nMaxDesc ,aContrt[1 ,11] )
							nMaxDesc := Max( nMaxDesc ,aContrt[1 ,12] )
							nMaxDesc := Max( nMaxDesc ,aContrt[1 ,13] )

							cMotBlq :=	 STR0111 + "#" + Transform(DT4->DT4_DESC,PesqPict("DT4","DT4_DESC")) + "#" +; //-- "Desconto De: "
										 STR0112 + "#" + Transform(nMaxDesc,PesqPict("DT4","DT4_DESC")) + "|" //-- " Maior Que Contrato: "
	
	
							// Gera Bloqueio Por Desconto Maior Que Contrato
							Tmsa029Blq( 3  ,;				//-- 01 - nOpc
							'TMSA040',;		//-- 02 - cRotina
							'DC'  ,;			//-- 03 - cTipBlq
							DT4->DT4_FILORI,;	//-- 04 - cFilOri
							'DT4' ,;			//-- 05 - cTab
							'1' ,;				//-- 06 - cInd
							xFilial('DT4') + DT4->DT4_FILORI + DT4->DT4_NUMCOT,; //-- 07 - cChave
							DT4->DT4_NUMCOT ,;	//-- 08 - cCod
								cMotBlq 		  ,;	//-- 09 - cDetalhe
								)						//-- 10 - Opcao da Rotina
						EndIf
					EndIf
				EndIf	
            EndIf	            
		EndIf

		If 	DT4->DT4_STATUS == StrZero( 1, Len( DT4->DT4_STATUS ) )

			//-- Grava o usuario q liberou o bloqueio
			DT4->( DbSetOrder( 1 ) )
			If	DT4->( MsSeek( xFilial('DT4') + M->DT4_FILORI + M->DT4_NUMCOT ) )
				RecLock('DT4',.F.)
				DT4->DT4_USRAPV := M->DT4_USRAPV
				MsUnLock()
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o arquivo DVT (Tipos de Veiculo Solic. Coleta / Cotacao de Frete)   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aColsDVT) > 0 .And. !l040Auto
	   a460AtuDVT(nOpcx,M->DT4_FILORI, M->DT4_NUMSOL, M->DT4_NUMCOT, StrZero(1,Len(DVT->DVT_ORIGEM)), "1", cSolicit, cCotacao )
	EndIf

	//-- Grava o no. da Cotacao de Frete na Solicitacao de Coleta
	If !Empty(DT4->DT4_NUMSOL)
		DT5->(DbSetOrder(1))
		If DT5->(MsSeek(xFilial('DT5')+M->DT4_FILORI+M->DT4_NUMSOL))
			RecLock('DT5',.F.)
			DT5->DT5_NUMCOT := M->DT4_NUMCOT
			MsUnLock()
		EndIf
	EndIf

	//-- Grava frete por pais
	If Len(aFrtPais) > 0
		DI7->(DbSetOrder(1))
		For nCntFor := 1 To Len(aFrtPais[2])
			If !GdDeleted(nCntFor,aFrtPais[1],aFrtPais[2])
				If DI7->(!MsSeek(xFilial("DI7")+M->DT4_FILORI+M->DT4_NUMCOT+GdFieldGet("DI7_ITEM",nCntFor,,aFrtPais[1],aFrtPais[2])))
					RecLock("DI7",.T.)
					DI7->DI7_FILIAL := xFilial("DI7")
					DI7->DI7_FILORI := M->DT4_FILORI
					DI7->DI7_NUMCOT := M->DT4_NUMCOT
				Else
					RecLock("DI7",.F.)
				EndIf
				For nI := 1 To Len(aFrtPais[1])
					If aFrtPais[1,nI,10] != 'V'
						DI7->(FieldPut(FieldPos(aFrtPais[1,nI,2]),GDFieldGet(aFrtPais[1,nI,2],nCntFor,,aFrtPais[1],aFrtPais[2])))
					EndIf
				Next
				MsUnlock()
			EndIf
		Next nCntFor
	EndIf					
	
	//-- Grava frete CIF/FOB
	If Len(aFrtDAF) > 0
		DI8->(DbSetOrder(1))
		For nCntFor := 1 To Len(aFrtDAF[2])
			If !GdDeleted(nCntFor,aFrtDAF[1],aFrtDAF[2])
				If DI8->(!MsSeek(xFilial("DI8")+M->DT4_FILORI+M->DT4_NUMCOT+GdFieldGet("DI8_CODPAS",nCntFor,,aFrtDAF[1],aFrtDAF[2])))
					RecLock("DI8",.T.)
					DI8->DI8_FILIAL := xFilial("DI8")
					DI8->DI8_FILORI := M->DT4_FILORI
					DI8->DI8_NUMCOT := M->DT4_NUMCOT
				Else
					RecLock("DI8",.F.)
				EndIf
				For nI := 1 To Len(aFrtDAF[1])
					If aFrtDAF[1,nI,10] != 'V'
						DI8->(FieldPut(FieldPos(aFrtDAF[1,nI,2]),GDFieldGet(aFrtDAF[1,nI,2],nCntFor,,aFrtDAF[1],aFrtDAF[2])))
					EndIf
				Next
				MsUnlock()
			EndIf
		Next nCntFor
	EndIf					

	//-- Ponto de Entrada chamado apos a inclusao ou alteracao da Cotacao de Frete
	If lTM040GRV
		ExecBlock('TM040GRV',.F.,.F.,{nOpcx})
	EndIf
	End Transaction
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA040Apr³ Autor ³ Alex Egydio           ³ Data ³01.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Aprovacao da cotacao de frete.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1 - Executado via Rotina Automatica                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA040Apr(nOpcx)

Local nCntFor	:= 0
Local lAprCot  := .T.
Local nMaxDesc := 0
Local lBloqDDU := .T.

If Type('lMostraTela')!='L'
	Private lMostraTela := .T.
EndIf

DT4->( DbSetOrder( 1 ) )
If	DT4->( MsSeek( xFilial('DT4') + M->DT4_FILORI + M->DT4_NUMCOT, .F. ) )
	If lTM040APR
		lAprCot := ExecBlock('TM040APR',.F.,.F.,{ nOpcx })
	EndIf
	RecLock('DT4',.F.)

	For nCntFor := 1 To Len( aAltera )
		If DT4->( FieldPos( aAltera[ nCntFor ] ) ) > 0
			FieldPut( FieldPos( aAltera[ nCntFor ] ), M->&( aAltera[ nCntFor ] ) )
		EndIf
	Next
	//-- Grava status como 3 - Aprovado.
	DT4->DT4_STATUS := Iif(lAprCot,StrZero( 3, Len( DT4->DT4_STATUS ) ),StrZero( 1, Len( DT4->DT4_STATUS ) ))
	MsUnLock()

	If (lMostraTela .And. !l040Auto	) 

		// Define Se Usa Novo Modelo De Bloqueio Tab. DDU
		// Verifica Se Existem Divergencias De Produtos (ONU)		
		DT4->( DbSetOrder( 1 ) )
		If	DT4->( MsSeek( xFilial('DT4') + M->DT4_FILORI + M->DT4_NUMCOT ) )
			If lTmsa029
				If (Tmsa029Cod('RR','DT4',xFilial('DT4') + DT4->DT4_FILORI + DT4->DT4_NUMCOT) .Or.;
					Tmsa029Cod('CR','DT4',xFilial('DT4') + DT4->DT4_FILORI + DT4->DT4_NUMCOT) .Or.;
					Tmsa029Cod('DC','DT4',xFilial('DT4') + DT4->DT4_FILORI + DT4->DT4_NUMCOT)) .And. ;
					DT4->DT4_STATUS == StrZero( 1, Len( DT4->DT4_STATUS ) ) //Pendente
						lBloqDDU:= .F.
				EndIf
			EndIf	
			If lBloqDDU	
				Tmsa040DDU()    
				
				If nOpcx != 6 .And. TmsA040Blq(DT4->DT4_STATUS) 
					DT4->( DbSetOrder( 1 ) )
					If	DT4->( MsSeek( xFilial('DT4') + M->DT4_FILORI + M->DT4_NUMCOT ) )
			
						If DT4->DT4_STATUS <> StrZero( 5, Len( DT4->DT4_STATUS ) )
							RecLock('DT4',.F.)
							//-- Grava status como 2 - Bloqueado se o desconto for maior que os descontos definidos no contrato.
							DT4->DT4_STATUS := StrZero( 2, Len( DT4->DT4_STATUS ) )
							MsUnLock()
						EndIf
						
						// Define Se Usa Novo Modelo De Bloqueio Tab. DDU
						If FindFunction("TMSA029USE") .And. Tmsa029Use("TMSA040")
			
							nMaxDesc := Max( nMaxDesc ,aContrt[1 ,10] )
							nMaxDesc := Max( nMaxDesc ,aContrt[1 ,11] )
							nMaxDesc := Max( nMaxDesc ,aContrt[1 ,12] )
							nMaxDesc := Max( nMaxDesc ,aContrt[1 ,13] )
			
									cMotBlq :=	 STR0111 + "#" + Transform(M->DT4_DESC,PesqPict("DT4","DT4_DESC")) + "#" +; //-- "Desconto De: "
												 STR0112 + "#" + Transform(nMaxDesc,PesqPict("DT4","DT4_DESC"))+ "|" //-- " Maior Que Contrato: "
			
			
							// Gera Bloqueio Por Desconto Maior Que Contrato
							Tmsa029Blq( 3  ,;				//-- 01 - nOpc
										'TMSA040',;		//-- 02 - cRotina
										'DC'  ,;			//-- 03 - cTipBlq
										M->DT4_FILORI,;	//-- 04 - cFilOri
										'DT4' ,;			//-- 05 - cTab
										'1' ,;				//-- 06 - cInd
										xFilial('DT4') + M->DT4_FILORI + M->DT4_NUMCOT,; //-- 07 - cChave
										M->DT4_NUMCOT ,;	//-- 08 - cCod
										cMotBlq )			//-- 09 - cDetalhe
						EndIf
					EndIf
			    EndIf
			EndIf
		EndIf
		    	
		If DT4->DT4_STATUS == StrZero( 3, Len( DT4->DT4_STATUS ))

			//-- Grava o usuario q liberou o bloqueio
			DT4->( DbSetOrder( 1 ) )
			If	DT4->( MsSeek( xFilial('DT4') + M->DT4_FILORI + M->DT4_NUMCOT ) )
				RecLock('DT4',.F.)
				DT4->DT4_USRAPV := M->DT4_USRAPV
				MsUnLock()

				//-- Gera solicitacao de coleta
				If lAprCot
					TmsA040Col(nOpcx)
				EndIf

			EndIf
		EndIf
	ElseIf l040Auto .And. lAprCot
		TmsA040Col(nOpcx)				
	EndIf
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA040Col³ Autor ³ Alex Egydio           ³ Data ³02.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera coleta automatica ao aprovar a cotacao.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA040Col(nOpcx)

Local aHeaOld	:= Iif( Type('aHeader') == 'A', AClone( aHeader ), {} )
Local aColOld	:= Iif( Type('aCols') == 'A', AClone( aCols ), {} )
Local nItem		:= GdFieldPos( 'DVF_ITEM'   )
Local nCodPro	:= GdFieldPos( 'DVF_CODPRO' )
Local nCodEmb	:= GdFieldPos( 'DVF_CODEMB' )
Local nQtdVol	:= GdFieldPos( 'DVF_QTDVOL' )
Local nPeso		:= GdFieldPos( 'DVF_PESO'   )
Local nPesoM3	:= GdFieldPos( 'DVF_PESOM3' )
Local nValMer	:= GdFieldPos( 'DVF_VALMER' )
Local nCntFor	:= 0
Local lExisCol:= .F.
Local cRetSobSer := ""
Local aContrat := {}

//-- Salva Area
SaveInter()
aHeader := {}
aCols   := {}

If	lColeta

	If !Empty(M->DT4_NUMSOL)
		DbSelectArea("DT5")
		DbSetOrder(1)
		If Dbseek(xFilial("DT5")+M->DT4_FILORI+M->DT4_NUMSOL)
			lExisCol := .T.
		EndIf		
	EndIf
	
	//-- Utilizada na alteracao da solicitacao de coleta
	aRotina	:= {	{'' ,"AxPesqui"   ,0 ,1},;
					{'' ,"TMSA460Mnt" ,0 ,2},;
					{'' ,"TMSA460Mnt" ,0 ,3},;
					{'' ,"TMSA460Mnt" ,0 ,4} }
	//-- Variaveis para solicitacao de coleta.
	If lExisCol
		INCLUI := .F.
		RegToMemory('DT5',.F.)
	Else
		INCLUI := .T.
		RegToMemory('DT5',.T.)
	EndIf
	//-- Posiciona o servico.
	DC5->( DbSetOrder( 1 ) )
	DC5->( MsSeek( xFilial('DC5') + M->DT4_SERVIC, .F. ) )
	//-- Posiciona o solicitante.
	DUE->( DbSetOrder( 1 ) )
	DUE->( MsSeek( xFilial('DUE') + M->DT4_CODSOL, .F. ) )
	
	M->DT5_FILORI   := M->DT4_FILORI
	M->DT5_TIPCOL	:= StrZero( 1, Len( DT5->DT5_TIPCOL ) )
	M->DT5_CODSOL   := M->DT4_CODSOL
	M->DT5_DDD		:= M->DT4_DDD
	M->DT5_TEL		:= M->DT4_TEL
	M->DT5_CDRORI	:= M->DT4_CDRORI
	M->DT5_TIPTRA	:= DC5->DC5_TIPTRA
	M->DT5_NUMCOT	:= M->DT4_NUMCOT
	M->DT5_CDRDCA   := M->DT4_CDRDES	
	M->DT5_CLIREM   := M->DT4_CLIREM
	M->DT5_LOJREM   := M->DT4_LOJREM
	M->DT5_CLIDES   := M->DT4_CLIDES
	M->DT5_LOJDES   := M->DT4_LOJDES    
	M->DT5_CLIDEV   := M->DT4_CLIDEV
	M->DT5_LOJDEV   := M->DT4_LOJDEV  

	aContrat := TMSContrat(M->DT4_CLIDEV,M->DT4_LOJDEV,,M->DT4_SERVIC,.F.,M->DT4_TIPFRE, .F.,,,,,,,,,,,,,,,M->DT4_CODNEG)		
	cRetSobSer := TmsSobServ('AGEVIR',.T.,.T.,M->DT4_NCONTR,M->DT4_CODNEG,M->DT4_SERVIC,"0",,.F.)
	If cRetSobSer == '1'			
		If !Empty(aContrat[1,43])
			cSrvCol := aContrat[1,43,1,18] //DDA_SRVCOL
		ElseIf !Empty(aContrat[1,44])
			cSrvCol := aContrat[1,44,1,8] //DDC_SRVCOL
		EndIf			
		If !Empty(cSrvCol)
			M->DT5_SERVIC := cSrvCol
			M->DT5_NCONTR := M->DT4_NCONTR
			M->DT5_CODNEG := M->DT4_CODNEG
			M->DT5_SRVENT := M->DT4_SERVIC
		EndIf	 
	EndIf 
	M->DT5_TIPFRE := M->DT4_TIPFRE

	If lTM040COL
		ExecBlock('TM040COL',.F.,.F.)
	EndIf
	aHeader := {}
	TMSFillGetDados( 3, 'DUM', 1, xFilial('DUM') + M->DT5_FILORI + M->DT5_NUMSOL, { || DUM->DUM_FILIAL + DUM->DUM_FILORI + DUM->DUM_NUMSOL } )

	For nCntFor := 1 To Len(aColOld)
		If	!GdDeleted(nCntFor,aHeaOld,aColOld)
			GDFieldPut( 'DUM_ITEM'   ,aColOld[nCntFor,nItem]	,Len(aCols) )
			GDFieldPut( 'DUM_CODPRO' ,aColOld[nCntFor,nCodPro]	,Len(aCols) )
			GDFieldPut( 'DUM_CODEMB' ,aColOld[nCntFor,nCodEmb]	,Len(aCols) )
			GDFieldPut( 'DUM_QTDVOL' ,aColOld[nCntFor,nQtdVol]	,Len(aCols) )
			GDFieldPut( 'DUM_PESO'   ,aColOld[nCntFor,nPeso]	,Len(aCols) )
			GDFieldPut( 'DUM_PESOM3' ,aColOld[nCntFor,nPesoM3]	,Len(aCols) )
			If nValMer > 0 //Verificacao devido a este campo ser recente
				GDFieldPut( 'DUM_VALMER' ,aColOld[nCntFor,nValMer] ,Len(aCols) )
			EndIf

			AAdd(aCols,Array(Len(aHeader)+1))
			AEval(aHeader,{|x, nI| aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2],.T.) } )
			aCols[Len(aCols),Len(aHeader)+1] := .F.

		EndIf
	Next
	
	//-- Rotina de gravacao da solicitacao de coleta
	If lExisCol
		TmsA460Grava( 4 , l040Auto 	, .T.)
	Else
		TmsA460Grava( 3 , l040Auto 	, .T.)
	EndIf
	
	//-- Exibe a Tela de Solicitacao de Coleta para Alteracao dos Dados
	If !l040Auto .And. !lExisCol .And. !IsInCallStack("TMSA170")
		Tmsa460Mnt('DT5', DT5->(Recno()), 4)
	EndIf
EndIf

//-- Salva Area
RestInter()

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA040Blq³ Autor ³ Alex Egydio           ³ Data ³01.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o desconto informado, foi maior que o desconto ³±±
±±³          ³ maximo permitido                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA040Blq(cStatus)

Local nMaxDesc := 0
Local n1Cnt    := 0
Local n2Cnt    := 0
Local lRet	   := .F.
Local aRet	   := {}
Local cCodUser := __cUserID

Default cStatus := ""

If lTM040BLQ
	lRet := ExecBlock('TM040BLQ',.F.,.F.)
Else
	nMaxDesc := Max( nMaxDesc ,aContrt[1 ,10] )
	nMaxDesc := Max( nMaxDesc ,aContrt[1 ,11] )
	nMaxDesc := Max( nMaxDesc ,aContrt[1 ,12] )
	nMaxDesc := Max( nMaxDesc ,aContrt[1 ,13] )

	lRet := (M->DT4_DESC > nMaxDesc)

	If !lRet //-- Verifica se foi dado Desconto atraves da digitacao do Valor Fechado
		For n1Cnt := 1 To Len(aFrete)
			For n2Cnt := 1 To Len(aFrete[n1Cnt,2])
				If aFrete[n1Cnt,2,n2Cnt,13] > nMaxDesc //-- Se o Desconto dado for maior que o desconto Maximo Permitido
					lRet := .T.
					Exit
				EndIf
			Next
		Next
	EndIf
	//-- Pedir a senha de liberacao de bloqueio
	If lRet .And. !lTmsa029	//-- Nao configurado o Controle de Alçadas
		aRet := TmsSenha()
		If aRet[1]
			lRet := ! TmsAcesso(aRet[2],'TMSA040',@cCodUser,7)
		EndIf
	EndIf
EndIf

If cStatus <> StrZero( 5, Len( DT4->DT4_STATUS ) )
	M->DT4_USRAPV := cCodUser
EndIf	

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA040Lib³ Autor ³ Alex Egydio           ³ Data ³01.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Libera cotacao de frete bloqueada.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA040Lib()

DT4->( DbSetOrder( 1 ) )
If	DT4->( MsSeek( xFilial('DT4') + M->DT4_FILORI + M->DT4_NUMCOT, .F. ) )
	RecLock('DT4',.F.)
	DT4->DT4_STATUS := StrZero( 1, Len( DT4->DT4_STATUS ) )
	MsUnLock()
	//-- Ponto de entrada apos a liberacao da cotacao.
	If lTM040LIB
		ExecBlock("TM040LIB",.F.,.F.)
	EndIf
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA040Dsc³ Autor ³ Alex Egydio           ³ Data ³02.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Aplica desconto / acrescimo ao valor do frete.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Valor Fechado Informado na Nota Fiscal/Agendamento ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA040Dsc(nValFec,lSrvRateio,aCotAge,lMntBase)

Local lFechado		:= GetMv("MV_COTVFEC",,.F.)  //-- Permite a digitacao de Valor Fechado por componente
Local aFrtAnt		:= AClone(aFrete)
Local aFrtAtu		:= {}
Local lAltValFec	:= .T.
Local nSeek			:= 0
Local nPosDsc		:= 0
//-- MsDialog
Local nOpcA			:= 0
Local oDlgDsc
//-- Listbox
Local aDsc			:= {}
Local cLbx			:= ''
//-- Radio
Local oRadio
//-- Folder
Local oFolder
Local oPanel
Local aPages	   	 := { "HEADER" }
Local aTitles	   	 := { STR0036 } //"% Desconto"
//-- Uso geral
Local n1Cnt			:= 0
Local n2Cnt			:= 0
//-- Dimensoes da Tela
Local aSize			:= {}
Local aObjects		:= {}
Local aInfo			:= {}
Local aPosObj		:= {}
//--
Local nTValPasOld	:= nTValPas	
Local nTValImpOld	:= nTValImp	
Local nTValTotOld	:= nTValTot	
Local nDscOri		:= M->DT4_DESC
Local nAscOri		:= M->DT4_ACRESC
Local lAssumeFrt    := (!Empty(aCotAge) .And. Len(aCotAge) >= 7 .And. !Empty(aCotAge[FRTCMPCOT]))
Local aListHead     := {}
Local aCompTES      := {}
Local lConsig       := .F.

Default lSrvRateio:= .F.
Default aCotAge   := {}

Private aFrtFec 	:= Aclone(aFrtFecAnt)
//-- MsGet
Private nRadio		:= nRadioAnt
Private nVlrFec	    := nVlrFecAnt
Private nDescon	    := nDesconAnt
Private nAcresc	    := nAcrescAnt
Private oVlrFec
Private oDescon
Private oAcresc
Private oLbxEsp

Default nValFec		:= 0
Default lMntBase    := .F.

l040Auto := IIf(Type('l040Auto')<>'L', .F., l040Auto)

If !Empty(nValFec) //-- Valor Fechado Informado na Nota Fiscal/Agendamento
	nVlrFec := nValFec
EndIf

aDesconto := {}

If !l040Auto .And. Empty(nTValPas)
	Aviso( STR0039 , STR0088 , { STR0089 } ) //"Atencao" ### "Tecle <F5> para atualizar a Composicao do Frete" ### "OK"
	Return( .F. )
EndIf

// Verifica atraves de ponto de entrada se pode informar o Desconto / Acrescimo
If lTM040DSC
	lAltValFec:=ExecBlock("TM040DSC",.F.,.F.)
	If ValType(lAltValFec) # "L"
		lAltValFec:=.T.
	EndIf
EndIf

If lAltValFec
	//-- Posiciona no servico para obter os percentuais de desconto
	DC5->( DbSetOrder( 1 ) )
	If	Empty( M->DT4_SERVIC ) .Or. DC5->( ! MsSeek( xFilial('DC5') + M->DT4_SERVIC ) )
		Return( .F. )
	EndIf
	AAdd( aDsc ,DC5->DC5_DESC1 )
	AAdd( aDsc ,DC5->DC5_DESC2 )
	AAdd( aDsc ,DC5->DC5_DESC3 )
	AAdd( aDsc ,DC5->DC5_DESC4 )
	//-- Se os percentuais de desconto para o servico estiverem zerados, nao permite desconto
	If	Empty(aDsc[1]+aDsc[2]+aDsc[3]+aDsc[4]) .And. !lSrvRateio
		Help('',1,'TMSA04039',, STR0028 +M->DT4_SERVIC, 4, 1) //"Valor de desconto invalido!" ### "Servico"
		Return( .F. )
	EndIf

	aFrete := {}
	//-- Calcula a Composicao do Frete, antes de efetuar o desconto
	If !TmsA040Atz(aCotAge, (M->DT4_DESC > 0 .Or. M->DT4_ACRESC > 0), , lMntBase)
		Return( .F. )
	EndIf

	If lAgend .Or. Empty(aFrete)
		aFrete := AClone(aFrtOri)
	EndIf

	aFrtAtu := AClone(aFrete)  //-- Salva o array aFrete retornado pela TMSA040Atz()

	//-- Finaliza Teclas de Atalhos
	TmsKeyOff(aSetKey)

	aFrete := {}
	//-- Muda a estrutura do array aFrete retornado pela TMSA040Atz()
	For n1Cnt := 1 To Len(aFrtAtu)
		For n2Cnt := 1 To Len(aFrtAtu[n1Cnt,2])
			nSeek:=ASCan(aFrete,{|x|x[3]==aFrtAtu[n1Cnt,2,n2Cnt,3]})
			If	nSeek<=0
				AAdd(aFrete,{aFrtAtu[n1Cnt,2,n2Cnt,1],;
								aFrtAtu[n1Cnt ,2 ,n2Cnt ,2],;
								aFrtOri[n1Cnt ,2 ,n2Cnt ,3],;
								aFrtAtu[n1Cnt ,2 ,n2Cnt ,4],;
								aFrtAtu[n1Cnt ,2 ,n2Cnt ,5],;
								aFrtAtu[n1Cnt ,2 ,n2Cnt ,6],;
								aFrtAtu[n1Cnt ,2 ,n2Cnt ,7],;
								aFrtAtu[n1Cnt ,2 ,n2Cnt ,8],;
								aFrtAtu[n1Cnt ,2 ,n2Cnt ,9],;
								aFrtAtu[n1Cnt ,2 ,n2Cnt ,10],;
								aFrtAtu[n1Cnt ,2 ,n2Cnt ,11],;
								aFrtAtu[n1Cnt ,2 ,n2Cnt ,12],;
								aFrtOri[n1Cnt ,2 ,n2Cnt ,13],;
								aFrtAtu[n1Cnt ,2 ,n2Cnt ,14],;
								aFrtAtu[n1Cnt ,2 ,n2Cnt ,15]})
			Else
				aFrete[nSeek,2]+=aFrtAtu[n1Cnt ,2 ,n2Cnt ,2]
				aFrete[nSeek,5]+=aFrtAtu[n1Cnt ,2 ,n2Cnt ,5]
				aFrete[nSeek,6]+=aFrtAtu[n1Cnt ,2 ,n2Cnt ,6]
			EndIf
		Next
	Next

	ASort(aFrete,,,{|x,y| x[12] + x[3] < y[12] + y[3] })

	//-- Vetor utilizado pelo listbox de desconto, baseado no vetor aFrete
	If !lAssumeFrt
		TmsA040VDc(aFrete,aDsc,aCotAge)
	EndIf
	If !l040Auto
		//-- Calcula as dimensoes dos objetos
		aSize    := MsAdvSize(.T.)
		aObjects := {}
		AAdd( aObjects, { 100,050,.T.,.T. } )
		AAdd( aObjects, { 100,050,.T.,.T. } )
		aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
		aPosObj:= MsObjSize( aInfo, aObjects, .T. )

		lConsig := A040Consig(M->DT4_CLIREM,M->DT4_LOJREM,M->DT4_CLIDES,M->DT4_LOJDES,M->DT4_CLIDEV,M->DT4_LojDEV)		
		aCompTES := A500TESCmp(M->DT4_DOCTMS,M->DT4_TIPFRE,M->DT4_CLIDEV,M->DT4_LOJDEV,M->DT4_CDRORI, M->DT4_CDRDES,Space(Len(SB1->B1_COD)),lConsig,"0",aDesconto,M->DT4_CLIDES,M->DT4_LOJDES)
		
		DEFINE MSDIALOG oDlgDsc TITLE STR0034 FROM aSize[7],000 TO aSize[6], aSize[5] PIXEL

		If !lFechado
			@ aPosObj[1,1],aPosObj[1,2] LISTBOX oLbxEsp VAR cLbx FIELDS HEADER "INIT" SIZE aPosObj[1,4], aPosObj[1,3] OF oDlgDsc PIXEL //'Composicao'###'Valor sem Desconto'
			
			aListHead := {STR0016,STR0037,Alltrim(Str(aDsc[1])),Alltrim(Str(aDsc[2])),Alltrim(Str(aDsc[3])),Alltrim(Str(aDsc[4])),STR0124,STR0125,STR0126}
			oLbxEsp:aHeaders := aClone(aListHead)

			oLbxEsp:SetArray( aDesconto )
			oLbxEsp:bLine	:= { || {	AllTrim(aDesconto[oLbxEsp:nAT,1]),;
			TransForm(aDesconto[oLbxEsp:nAT, 2],PesqPict('DVF','DVF_VALMER')),;
			TransForm(aDesconto[oLbxEsp:nAT, 3],PesqPict('DVF','DVF_VALMER')),;
			TransForm(aDesconto[oLbxEsp:nAT, 4],PesqPict('DVF','DVF_VALMER')),;
			TransForm(aDesconto[oLbxEsp:nAT, 5],PesqPict('DVF','DVF_VALMER')),;
			TransForm(aDesconto[oLbxEsp:nAT, 6],PesqPict('DVF','DVF_VALMER')),;
			AllTrim(aCompTes[oLbxEsp:nAT,1]) + " - " + AllTrim(aCompTes[oLbxEsp:nAT,2]),;     //| Codigo da TES + Descricao da TES
			AllTrim(aCompTes[oLbxEsp:nAT,3]),;     //| Codigo do CFOP
			AllTrim(aCompTes[oLbxEsp:nAT,4]) + " - " + AllTrim(aCompTes[oLbxEsp:nAt,5]) } }   //| Codigo da Situacao Tributaria + Descricao do Situacao Tributaria
			
		Else
			@ aPosObj[1,1],aPosObj[1,2] LISTBOX oLbxEsp VAR cLbx FIELDS HEADER "INIT" SIZE aPosObj[1,4], aPosObj[1,3] OF oDlgDsc PIXEL ;  //'Composicao'###'Valor sem Desconto'###'Valor Fechado'
				ON DBLCLICK(If(nRadio<>5,.T.,(aDesconto:=TMSA040ShowGet(oLbxEsp:nAT),oLbxEsp:Refresh())))
			
			aListHead := {STR0016,STR0037,Alltrim(Str(aDsc[1])),Alltrim(Str(aDsc[2])),Alltrim(Str(aDsc[3])),Alltrim(Str(aDsc[4])),STR0063,'%Desconto','%Acrescimo',STR0124,STR0125,STR0126}
			oLbxEsp:aHeaders := aClone(aListHead)

			oLbxEsp:SetArray( aDesconto )
			oLbxEsp:bLine	:= { || {	AllTrim(aDesconto[oLbxEsp:nAT,1]),;
			TransForm(aDesconto[oLbxEsp:nAT, 2],PesqPict('DVF','DVF_VALMER')),;
			TransForm(aDesconto[oLbxEsp:nAT, 3],PesqPict('DVF','DVF_VALMER')),;
			TransForm(aDesconto[oLbxEsp:nAT, 4],PesqPict('DVF','DVF_VALMER')),;
			TransForm(aDesconto[oLbxEsp:nAT, 5],PesqPict('DVF','DVF_VALMER')),;
			TransForm(aDesconto[oLbxEsp:nAT, 6],PesqPict('DVF','DVF_VALMER')),;
			TransForm(aDesconto[oLbxEsp:nAT, 8],PesqPict('DVF','DVF_VALMER')),;
			TransForm(aDesconto[oLbxEsp:nAT, 9],PesqPict('DT4','DT4_DESC'  )),; 
			TransForm(aDesconto[oLbxEsp:nAT,10],PesqPict('DT4','DT4_ACRESC')),;
			AllTrim(aCompTes[oLbxEsp:nAT,1]) + " - " + AllTrim(aCompTes[oLbxEsp:nAT,2]),;     //| Codigo da TES + Descricao da TES
			AllTrim(aCompTes[oLbxEsp:nAT,3]),;     //| Codigo do CFOP
			AllTrim(aCompTes[oLbxEsp:nAT,4]) + " - " + AllTrim(aCompTes[oLbxEsp:nAt,5]) } }   //| Codigo da Situacao Tributaria + Descricao do Situacao Tributaria
		EndIf

		oFolder := TFolder():New( aPosObj[2,1], aPosObj[2,2], aTitles, aPages, oDlgDsc,,,,.T.,.f.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
		oPanel  := TPanel():New(0,0, "", oFolder:aDialogs[1],,.T.,.T.,,,0,0,.T.,.T. )
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

		@ 15, 05 SAY STR0017 SIZE 43, 10 OF oPanel PIXEL //"Valor"
		@ 15, 48 MSGET oVlrFec VAR nVlrFec	PICTURE PesqPict('DVF','DVF_VALMER') VALID TmsA040Cal(0,2) SIZE 45, 10 OF oPanel PIXEL

		@ 35, 05 SAY STR0036 SIZE 43, 10 OF oPanel PIXEL //"% Desconto"
		@ 35, 48 MSGET oDescon VAR nDescon	PICTURE PesqPict('DT4','DT4_DESC'  ) WHEN .F. SIZE 45, 10 OF oPanel PIXEL

		@ 55, 05 SAY STR0090 SIZE 43, 10 OF oPanel PIXEL //"% Acrescimo"
		@ 55, 48 MSGET oAcresc VAR nAcresc	PICTURE PesqPict('DT4','DT4_ACRESC') WHEN .F. SIZE 45, 10 OF oPanel PIXEL

		If !lFechado
			@ 10, 101 TO 70, 140 LABEL STR0036 OF oPanel PIXEL //"% Desconto"
			@ 15, 103 RADIO oRadio VAR nRadio;
			PROMPT Alltrim(Str(aDsc[1])) + ' % ', Alltrim(Str(aDsc[2])) + ' % ', Alltrim(Str(aDsc[3])) + ' % ', Alltrim(Str(aDsc[4])) + ' % ';
			OF oPanel ON CLICK {|| TmsA040Cal(nRadio,1) } ;
			PIXEL SIZE 25,10
		Else
			@ 10, 101 TO 70, 200 LABEL STR0036 OF oPanel PIXEL //"% Desconto"
			@ 15, 103 RADIO oRadio VAR nRadio;
			PROMPT Alltrim(Str(aDsc[1])) + ' % ', Alltrim(Str(aDsc[2])) + ' % ', Alltrim(Str(aDsc[3])) + ' % ', Alltrim(Str(aDsc[4])) + ' % ', STR0063 ; //"Valor Fechado por Componente"
			OF oPanel ON CLICK {|| TmsA040Cal(nRadio,If(nRadio==5,3,1)),oVlrFec:lReadOnly := (nRadio == 5),oVlrFec:Refresh() } ;
			PIXEL SIZE 100,10
		EndIf
		
		//31-07-2018 [nao apagar]: será utilizado como melhoria para help da selecao dos radios box.
		//@ 10, 205 TO 70, aPosObj[1,4]-50 LABEL "Descricao" OF oPanel PIXEL //"% Desconto"

		ACTIVATE MSDIALOG oDlgDsc CENTERED ON INIT EnchoiceBar(oDlgDsc,{||nOpcA := 1, oDlgDsc:End()},{||oDlgDsc:End()})
	Else
		If lAssumeFrt
			For n1Cnt := 1 To Len(aCotAge[FRTCMPCOT])
				If aCotAge[FRTCMPCOT,n1Cnt,TIPVALCMP] == '1' //-- Com imposto
					If Len(aDesconto) == 0
						TmsA040VDc(aFrete,aDsc,aCotAge)
					EndIf
					nPosDsc := Ascan(aDesconto,{ | e | e[11] == aCotAge[FRTCMPCOT,n1Cnt,CODPASCMP] .And. (Left(FunName(),7) <> "TMSAE75" .Or. !Empty(aCotAge[FRTCMPCOT,n1Cnt,LOTEDICMP]) )})
					If nPosDsc > 0
						If Left(FunName(),7) == "TMSAE75"
							//-- Grava aDesconto[nPosDsc,8] em DET
							DET->(dbSetOrder(1))//-- DET_FILIAL+DET_LOTEDI+DET_CODPAS
							DET->(MsSeek(xFilial("DET")+aCotAge[FRTCMPCOT,n1Cnt,LOTEDICMP]+aCotAge[FRTCMPCOT,n1Cnt,CODPASCMP]))
							RecLock( "DET", .F. )
							DET->DET_VALCAL := aDesconto[nPosDsc,8]
							MsUnLock()
						EndIf

						aDesconto := TMSA040ShowGet(nPosDsc,aCotAge[FRTCMPCOT,n1Cnt,VALPASCMP])

					EndIf
				Else
					nPosDsc := Ascan(aDesconto,{ | e | e[11] == aCotAge[FRTCMPCOT,n1Cnt,CODPASCMP] .And. (Left(FunName(),7) <> "TMSAE75" .Or. !Empty(aCotAge[FRTCMPCOT,n1Cnt,LOTEDICMP]) ) })
					If nPosDsc > 0
						aDesconto := TMSA040ShowGet(nPosDsc,aCotAge[FRTCMPCOT,n1Cnt,VALPASCMP])
					EndIf
				EndIf
			Next n1Cnt
		Else
			TmsA040Cal(0,2)
		EndIf
		nOpca := 1
	EndIf

	If	nOpca == 1
		If	! Empty(nVlrFec)
			CursorWait()
			M->DT4_DESC   := 0
			M->DT4_ACRESC := 0
			TmsA040Frt(nRadio)
			If	nDescon > 0
				M->DT4_DESC   := nDescon
				M->DT4_ACRESC := 0
			EndIf
			If	nAcresc > 0
				M->DT4_ACRESC := nAcresc
				M->DT4_DESC   := 0
			EndIf
			CursorArrow()
		EndIf
		aColsBack := AClone(aCols)

		nRadioAnt  := nRadio
		nVlrFecAnt := nVlrFec
		nDesconAnt := nDescon
		nAcrescAnt := nAcresc

	EndIf

	//-- Se nao confirmar, retorna todos os Valores que foram alterados pela TMSCalFret()
	If nOpca == 0 .Or. (Empty(nVlrFec) .And. !lAssumeFrt)
		aFrete			:= AClone(aFrtAnt)	//-- Composicao de frete da cotacao
		nTValPas		:= nTValPasOld		//-- Total do Frete sem impostos
		nTValImp		:= nTValImpOld		//-- Total dos Impostos
		nTValTot		:= nTValTotOld		//-- Total do Frete+Impostos
		M->DT4_DESC		:= nDscOri			//-- % Desconto da Cotacao
		M->DT4_ACRESC	:= nAscOri			//-- % Acrescimo da Cotacao
	EndIf

	aFrtFec		:= {}
	nVlrFec		:= 0
	nDescon		:= 0
	nRadio      := 0
EndIf

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA040VDc³ Autor ³ Alex Egydio           ³ Data ³01.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria o vetor aDesconto                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA040VDc(aFrete,aDsc,aCotAge)

Local lAplDes	:= .F.
Local nCntFor	:= 0
Local nTotDsc1	:= 0
Local nTotDsc2	:= 0
Local nTotDsc3	:= 0
Local nTotDsc4	:= 0
Local nTotDsc13	:= 0
Local nTotDsc14	:= 0
Local aAplDes   := {}
Local lCompDes  := .F.
Local nSomaDesc := 0
Local nValTot   := 0

Default aCotAge := {}

//-- Formato do vetor aDesconto
//-- [01] = Descricao do componente
//-- [02] = Total do componente ( valor + imposto )
//-- [03] = Total do componente com 1o desconto
//-- [04] = Total do componente com 2o desconto
//-- [05] = Total do componente com 3o desconto
//-- [06] = Total do componente com 4o desconto
//-- [07] = .T. Determina se o componente aceita desconto
//-- [08] = Total do componente)
//-- [09] = % Desconto  do Componente
//-- [10] = % Acrescimo do Componente
//-- [11] = Codigo      do Componente

For nCntFor := 1 To Len(aFrete)
	lAplDes := MyPosicione('DT3',1,xFilial('DT3') + aFrete[nCntFor,3],'DT3_APLDES')==StrZero( 1, Len( DT3->DT3_APLDES ) )
	If !lAplDes .And. !lCompDes .And. aFrete[nCntFor,3] <> 'TF'
		lCompDes := .T.		
	EndIf
	If !lAplDes .And. aFrete[nCntFor,3] <> 'TF'
		nSomaDesc += aFrete[nCntFor, 6]
	EndIf
	aAdd(aAplDes, { aFrete[nCntFor,3], lAplDes })
Next 

If lCompDes
	 nValTot := aFrete[ Len(aFrete), 6 ] - nSomaDesc
EndIf

For nCntFor := 1 To Len(aFrete)
		If	aFrete[ nCntFor, 3 ] != 'TF'			
			AAdd( aDesconto, { aFrete[ nCntFor, 1 ], aFrete[ nCntFor, 6 ], TmsA040Pct(aAplDes[nCntFor, 2],aFrete[ nCntFor, 6 ],aDsc[1], nValTot, nSomaDesc), ;
				TmsA040Pct(aAplDes[nCntFor, 2], aFrete[ nCntFor, 6 ],aDsc[2], nValTot, nSomaDesc), TmsA040Pct(aAplDes[nCntFor, 2], aFrete[ nCntFor, 6 ],aDsc[3], nValTot, nSomaDesc),;
				TmsA040Pct(aAplDes[nCntFor, 2], aFrete[ nCntFor, 6 ],aDsc[4], nValTot, nSomaDesc), aAplDes[nCntFor, 2],  aFrete[ nCntFor, 6 ], 0, 0, aFrete[ nCntFor, 3 ] } )
				nTotDsc1 += aDesconto[Len(aDesconto),3]
				nTotDsc2 += aDesconto[Len(aDesconto),4]
				nTotDsc3 += aDesconto[Len(aDesconto),5]
				nTotDsc4 += aDesconto[Len(aDesconto),6]
				nTotDsc13 += aDesconto[Len(aDesconto),9]
				nTotDsc14 += aDesconto[Len(aDesconto),10]			
		Else
			AAdd( aDesconto, { aFrete[ nCntFor, 1 ], aFrete[ nCntFor, 6 ], nTotDsc1, nTotDsc2, nTotDsc3, nTotDsc4, .F.,  aFrete[ nCntFor, 6 ],nTotDsc13,nTotDsc14, aFrete[ nCntFor, 3 ] } )
		EndIf
Next

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA040Pct³ Autor ³ Alex Egydio           ³ Data ³01.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Aplica desconto ao valor do frete                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA040Pct(lDsc,nValor,nDsc, nTotFrete, nSomaDesc)

Local nRet := 0

Default nTotFrete := 0
Default nSomaDesc := 0

If ! Empty( nDsc )
	If	lDsc		
		nRet := nValor - NoRound(nValor * ( nDsc / 100 ))
		If nTotFrete > 0
			nRet := (nValor / nTotFrete) * ((aFrete[ Len(aFrete), 6 ] - NoRound(aFrete[ Len(aFrete), 6 ] * ( nDsc / 100 ))) - nSomaDesc)
		EndIf
	Else
		nRet := nValor
	EndIf
EndIf

Return( nRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA040Cal³ Autor ³ Alex Egydio           ³ Data ³01.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula desconto                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA040Cal(nDsc,nAcao)

Local nSeek	   := 0
Local nCntFor  := 0
Local nDifVCVF := 0	//-- Diferenca entre o valor inicial da composicao e o valor fechado
Local nDifVFVC := 0	//-- Diferenca entre o valor Fechado e o Inicial da composicao 
Local nVlCDsc  := 0	//-- Valor total dos componentes que aceitam desconto
Local nVlSDsc  := 0	//-- Valor total dos componentes que nao aceitam desconto
Local nVlCAsc  := 0	//-- Valor total dos componentes com acrescimo

//-- Percentual de desconto
If	nAcao == 1
	If nRadio != 0
		aFrtFec := {}
		nSeek   := Ascan( aFrete,{|x| x[3] == 'TF' })
		If	nSeek > 0
			nVlrFec	:= aDesconto[Len(aDesconto),nDsc+2]
			nDescon	:= ( 1 - ( nVlrFec / aFrete[ nSeek, 6 ] ) ) * 100 //-- nDescon := ( 1 - Round(nVlrFec / aFrete[ nSeek, 6 ],2) ) * 100
			oVlrFec:Refresh()
			oDescon:Refresh()
			If	Type('oAcresc') == 'O'
				//-- zera o percentual de acrescimo
				nAcresc:= 0
				oAcresc:Refresh(.T.)
			EndIf
		EndIf
	EndIf
	//-- Digitacao do valor fechado
ElseIf nAcao == 2
	If nVlrFec == aDesconto[Len(aDesconto),nDsc+2] .Or. nVlrFec == 0
		nRadio  := 0
		nVlrFec := 0
		nDescon := 0
		nAcresc := 0
		oVlrFec:Refresh(.T.)
		oDescon:Refresh(.T.)
		oAcresc:Refresh(.T.)
	ElseIf nVlrFec > aDesconto[Len(aDesconto),nDsc+2]
		nRadio  := 0
		aFrtFec := {}
		//-- Diferenca entre o valor Fechado e o inicial da composicao
		nDifVFVC :=  nVlrFec - aDesconto[Len(aDesconto),nDsc+2]
		//-- Proporcao dos componentes
		For nCntFor := 1 To Len( aDesconto )-1
			AAdd( aFrtFec, aDesconto[nCntFor,nDsc+2] + ( nDifVFVC * (aDesconto[nCntFor,nDsc+2] / aDesconto[Len(aDesconto),nDsc+2]) ))
		Next
		//-- Obtem o total do frete com Acrescimo
		nVlCAsc := 0
		For nCntFor := 1 To Len( aFrtFec )
			nVlCAsc += aFrtFec[nCntFor]
		Next
		//-- Cria a linha totalizadora no vetor
		AAdd( aFrtFec, nVlCAsc)

		If	Type('oAcresc') == 'O' .Or. l040Auto
			//-- Calcula o percentual de desconto
			nAcresc:= ( 100 * (nVlrFec / aDesconto[Len(aDesconto),nDsc+2]) ) - 100
			If !l040Auto
				oAcresc:Refresh(.T.)
			EndIf
		EndIf

		If	Type('oDescon') == 'O'  .Or. l040Auto
			//-- zera o percentual de desconto
			nDescon:= 0
			If !l040Auto
				oDescon:Refresh(.T.)
			EndIf
		EndIf
	Else
		//-- Obtem a somatoria dos componentes que nao aceitam desconto
		nRadio  := 0
		nVlSDsc := 0
		For nCntFor := 1 To Len( aDesconto )-1
			If	! aDesconto[nCntFor,7]
				nVlSDsc += aDesconto[nCntFor,nDsc+2]
			EndIf
		Next
		aFrtFec := {}
		//-- Valor digitado nao pode ser menor que a somatoria dos componentes que nao aceitam desconto
		If	nVlrFec < nVlSDsc
			Return( .F. )
		EndIf
		//-- Diferenca entre o valor inicial da composicao e o valor fechado
		nDifVCVF := aDesconto[Len(aDesconto),nDsc+2] - nVlrFec
		//-- Valor total dos componentes que aceitam desconto
		nVlCDsc := 0
		For nCntFor := 1 To Len( aDesconto )-1
			If	aDesconto[nCntFor,7]
				nVlCDsc += aDesconto[nCntFor,nDsc+2]
			EndIf
		Next
		//-- Proporcao dos componentes que aceitam desconto
		For nCntFor := 1 To Len( aDesconto )-1
			If	aDesconto[nCntFor,7]
				AAdd( aFrtFec, aDesconto[nCntFor,nDsc+2] - ( nDifVCVF * (aDesconto[nCntFor,nDsc+2] / nVlCDsc) ))
			Else
				AAdd( aFrtFec, aDesconto[nCntFor,nDsc+2] )
			EndIf
		Next
		//-- Obtem o total do frete com desconto
		nVlCDsc := 0
		For nCntFor := 1 To Len( aFrtFec )
			nVlCDsc += aFrtFec[nCntFor]
		Next
		//-- Cria a linha totalizadora no vetor
		AAdd( aFrtFec, nVlCDsc )

		If	Type('oDescon') == 'O' .Or. l040Auto
			//-- Calcula o percentual de desconto
			nDescon := ( 1 - ( nVlrFec / aDesconto[Len(aDesconto),nDsc+2] ) ) * 100 //-- ( 1 - Round(nVlrFec / aDesconto[Len(aDesconto),nDsc+2],2) ) * 100
			If !l040Auto
				oDescon:Refresh()
			EndIf
		EndIf

		If	Type('oAcresc') == 'O' .Or. l040Auto
			//-- zera o percentual de acrescimo
			nAcresc:= 0
			If !l040Auto
				oAcresc:Refresh(.T.)
			EndIf
		EndIf
	EndIf
	//-- Valor Fechado (Carga Fechada)
ElseIf nAcao == 3
	aFrtFec := {}
	nVlrFec := 0
	aDesconto[Len(aDesconto),8] := 0
	For nCntFor := 1 To Len( aDesconto )
		If nCntFor <> Len( aDesconto )
			If !aDesconto[nCntFor,7]
				aDesconto[nCntFor,nDsc+3] := aDesconto[nCntFor,2]
			EndIf
			AAdd( aFrtFec, aDesconto[nCntFor,nDsc+3] )
			nVlrFec += aDesconto[nCntFor,nDsc+3]
		Else
			aDesconto[Len(aDesconto),nDsc+3] := nVlrFec
			AAdd( aFrtFec, aDesconto[nCntFor,nDsc+3] )
		EndIf
	Next
	nDescon := 0
	nAcresc := 0
	If !l040Auto
		oLbxEsp:Refresh()
		oVlrFec:Refresh()
	EndIf
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA040Frt³ Autor ³ Alex Egydio           ³ Data ³01.03.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o vetor aFrete com o desconto                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA040Frt(nDsc)

Local aFrtTot	:= AClone(aFrete)
Local nCntFor	:= 0
Local n1Cnt		:= 0
Local nSeek1	:= 0
Local nSeek2	:= 0
Local nSeek3	:= 0
Local nSeek4	:= 0
Local nImposto	:= 0
Local nValPas	:= 0
Local nValImp	:= 0
Local nValTot	:= 0
Local lPrcProd	:= GetMV('MV_PRCPROD',,.T.) //-- Calcula Preco do Frete por Produto ?
Local lIdentDoc	:= DT4->(ColumnPos("DT4_DOCTMS")) > 0
Local lCotacao	:= ("TMSA050" $ AllTrim(FunName())) .Or. (Type("nVlrFec")!= "U")
Local nDifal 	:= 0
Local lNILVlrFec:= Type("nVlrFec") != "U" // nVlrFec é uma variável Private da função TmsA040Dsc()
Local cCliCal := ""
Local cLojCal   := ""
Local lCliCot   := SuperGetMV("MV_CLICOT",Nil,.F.) //-- Utiliza o cliente informado no Cadastro de Solicitantes

//-- A regra de tributacao pode ser definida por componente, entao obtemos o imposto por componente
If	! Empty(aFrtFec)
	aFrtFecAnt := Aclone(aFrtFec)
	For nCntFor := 1 To Len( aFrtFec )-1
		//-- Obtem o imposto
		nImposto := ( aFrete[nCntFor,6] / aFrete[nCntFor,2] ) * 100
		If lNILVlrFec .And. !("TMSA040" $ FunName())
			//-- Caso exista um valor FECHADO não faz o cálculo com nImposto.
			aFrete[nCntFor,2] := Round(aFrtFec[nCntFor],2)
		Else
			//-- Subtrai o valor do imposto da coluna Valor do frete sem imposto
			aFrete[nCntFor,2] := Round(aFrtFec[nCntFor] * Round((100/nImposto),5),2)
		EndIf
		If lCotacao
			aFrete[nCntFor,2] := Round(aFrtFec[nCntFor] * Round((100/nImposto),2),2)
			aFrete[nCntFor,5] := aFrtFec[nCntFor] - aFrete[nCntFor,2]
			aFrete[nCntFor,6] := Round(aFrtFec[nCntFor],2)
		EndIf		
		
		//-- Percentual de Desconto / Percentual de Acrescimo aplicado neste Componente.
		nSeek := Ascan(aDesconto, {|x| Alltrim(x[1]) == AllTrim(aFrete[nCntFor,1]) })
		If nSeek > 0
			aFrete[nCntFor,13] := aDesconto[nSeek, 9]
			aFrete[nCntFor,14] := aDesconto[nSeek, 10]
		EndIf
	Next
ElseIf ! Empty(aDesconto)
	For nCntFor := 1 To Len(aDesconto)-1
		//-- Obtem o imposto
		nImposto := ( aFrete[nCntFor,6] / aFrete[nCntFor,2] ) * 100
		If lNILVlrFec .And. !("TMSA040" $ FunName())
		//-- Caso exista um valor FECHADO não faz o cálculo com nImposto.
			aFrete[nCntFor,2] := Round(aDesconto[nCntFor,nDsc+2],2)
		Else
			//-- Subtrai o valor do imposto da coluna Valor do frete sem imposto
			aFrete[nCntFor,2] := aDesconto[nCntFor,nDsc+2] * Round((100/nImposto),2)
		EndIf		
	Next
EndIf
//-- Calcula impostos
If lIdentDoc
	nDifal := 0
	If !Empty(M->DT4_DOCTMS)
		cDocTms := M->DT4_DOCTMS
	Else
		cDocTms := TMSTipDoc(M->DT4_CDRORI, M->DT4_CDRDES)
	EndIf	
	If (lCliCot .And. !Empty(M->DT4_CLIDEV)) .Or. (!lCliCot .And. !Empty(M->DT4_CLIDEV))
		cCliCal := M->DT4_CLIDEV
		cLojCal := M->DT4_LOJDEV
		//-- Calcula impostos
		TmsA040Imp( aFrete, cCliCal, cLojCal, cDocTms, M->DT4_TIPFRE, M->DT4_CDRDES, .T., ,MyPosicione("DUY",1, xFilial("DUY") + M->DT4_CDRDES,"DUY_FILDES"),Tmsa040TCli(),, M->DT4_CDRORI, M->DT4_FILORI,, M->DT4_CLIREM, M->DT4_LOJREM, M->DT4_CLIDES, M->DT4_LOJDES, , ,M->DT4_TIPNFC , Iif(lPrcProd,GDFieldGet("DVF_CODPRO"),Nil) ,  , ,, @nDifal)
	Else
		TmsA040Imp( aFrete, cCliDev, cLojDev, cDocTms, M->DT4_TIPFRE, M->DT4_CDRDES, .T., ,MyPosicione("DUY",1, xFilial("DUY") + M->DT4_CDRDES,"DUY_FILDES"),Tmsa040TCli(),, M->DT4_CDRORI, M->DT4_FILORI,, M->DT4_CLIREM, M->DT4_LOJREM, M->DT4_CLIDES, M->DT4_LOJDES, , ,M->DT4_TIPNFC , Iif(lPrcProd,GDFieldGet("DVF_CODPRO"),Nil) ,  , ,, @nDifal)
	EndIf
Else
	If IsInCallStack('TMSA040')
		DC5->(DbSetOrder(1))
		DC5->(MsSeek(xFilial('DC5') + M->DT4_SERVIC))
		//-- Calcula impostos
		nDifal := 0
		TmsA040Imp( aFrete, cCliDev, cLojDev, DC5->DC5_DOCTMS, M->DT4_TIPFRE, M->DT4_CDRDES, .T., ,MyPosicione("DUY",1, xFilial("DUY") + M->DT4_CDRDES,"DUY_FILDES"),Tmsa040TCli(),, M->DT4_CDRORI, M->DT4_FILORI,, M->DT4_CLIREM, M->DT4_LOJREM, M->DT4_CLIDES, M->DT4_LOJDES, , ,M->DT4_TIPNFC , Iif(lPrcProd,GDFieldGet("DVF_CODPRO"),Nil) ,  , ,, @nDifal)
	EndIf
EndIf

//-- Variaveis da linha totalizadora da cotacao
nTValPas	:= 0
nTValImp	:= 0
nTValTot	:= 0
//-- Frete com desconto
aFrtFec:=AClone(aFrete)
//-- Faz a proporcao entre os produtos
aFrete := {}
For nCntFor := 1 To Len(aFrtOri)
	nSeek1 := ASCan(aFrete,{|x|x[1]==aFrtOri[nCntFor,1]})
	If Empty(nSeek1)
		AAdd(aFrete,{aFrtOri[nCntFor,1],{}})
		nSeek1 := Len(aFrete)
	EndIf
	nValPas := 0
	nValImp := 0
	nValTot := 0
	For n1Cnt := 1 To Len(aFrtOri[nCntFor,2])
		nSeek2 := AScan(aFrtFec,{|x|x[3]==aFrtOri[nCntFor,2,n1Cnt,3]})
		nSeek3 := AScan(aFrtTot,{|x|x[3]==aFrtOri[nCntFor,2,n1Cnt,3]})
		nSeek4 := AScan(aFrete[nSeek1,2],{|x|x[3]==aFrtOri[nCntFor,2,n1Cnt,3]})

		If	nSeek4 <= 0
			AAdd(aFrete[nSeek1,2],{	aFrtOri[nCntFor,2,n1Cnt, 1],0,aFrtOri[nCntFor,2,n1Cnt, 3],aFrtOri[nCntFor,2,n1Cnt, 4],0,0,aFrtOri[nCntFor,2,n1Cnt,7],;
									aFrtOri[nCntFor,2,n1Cnt, 8],  aFrtOri[nCntFor,2,n1Cnt, 9],aFrtOri[nCntFor,2,n1Cnt,10],	aFrtOri[nCntFor,2,n1Cnt,11],;
									aFrtOri[nCntFor,2,n1Cnt,12],  aFrtOri[nCntFor,2,n1Cnt,13],aFrtOri[nCntFor,2,n1Cnt,14],	aFrtOri[nCntFor,2,n1Cnt,15]})
			nSeek4 := Len(aFrete[nSeek1,2])
		EndIf

		If	aFrtOri[nCntFor,2,n1Cnt,3]<>'TF'
			aFrete[nSeek1,2,nSeek4,2] := (((aFrtOri[nCntFor,2,n1Cnt,2] * 100) / aFrtTot[nSeek3,2]) / 100 ) * (aFrtFec[nSeek2,2]) 
			aFrete[nSeek1,2,nSeek4,5] := (((aFrtOri[nCntFor,2,n1Cnt,5] * 100) / aFrtTot[nSeek3,5]) / 100 ) * (aFrtFec[nSeek2,5]) 

			//-- Valor do componente sem imposto igual ao valor do componente com imposto e valor do imposto diferente de zero
			//-- Icms destacado e nao embutido
			If	(aFrtFec[nSeek2,2] == aFrtFec[nSeek2,6]) .And. (aFrtFec[nSeek2,5] > 0)
				aFrete[nSeek1,2,nSeek4,6] := aFrete[nSeek1,2,nSeek4,2]
			ElseIf nDifal = 0
				aFrete[nSeek1,2,nSeek4,6] := aFrete[nSeek1,2,nSeek4,2] + aFrete[nSeek1,2,nSeek4,5] 
			Else 
				// Devido aos diferenciais de alicota para DIFAL e FECP, pegar o valor já calculado no aFrtFec (Clone do aFrete)
				aFrete[nSeek1,2,nSeek4,6] := aFrtFec[nSeek2,6]
			EndIf
			aFrete[nSeek1,2,nSeek4,13] := aFrtFec[nSeek2,13] // % de Desconto dado ao componente
			aFrete[nSeek1,2,nSeek4,14] := aFrtFec[nSeek2,14] // % de Acrescimo dado ao componente
			nValPas+=aFrete[nSeek1,2,nSeek4,2]
			nValImp+=aFrete[nSeek1,2,nSeek4,5]
			nValTot+=aFrete[nSeek1,2,nSeek4,6]
		Else
			aFrete[nSeek1,2,nSeek4,2]:= nValPas
			aFrete[nSeek1,2,nSeek4,5]:= nValImp
			aFrete[nSeek1,2,nSeek4,6]:= nValTot
			//-- Obtem o total geral dos componentes durante a proporcao entre os produtos
			nTValPas += nValPas
			nTValImp += nValImp
			nTValTot += nValTot
		EndIf
	Next
Next

If !l040Auto
	oTValPas:Refresh()
	oTValImp:Refresh()
	oTValTot:Refresh()
EndIf
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA040VTm³ Autor ³Wellington A Santos    ³ Data ³11/12/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a quantidade de volumes (DT4_QTDVOL)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA040VTm()

Local aAreaAnt := GetArea()
Local cCodPro  := GdFieldGet('DVF_CODPRO')
Local cSeekDTE := ''
Local lRet	   := .T.
Local nCntFor  := 0
Local nPQtdVol := 0
Local nQtdVol  := 0
Local nSeek	   := 0
Local nTQtd	   := M->DVF_QTDVOL

If	Empty(aCubagem) .Or. Empty(AScan(aCubagem,{|x|x[1]==cCodPro}))
	DTE->(DbSetOrder(2))
	//-- Peso Cubado Informado na Cotacao de Frete
	If DTE->(MsSeek(cSeekDTE := xFilial('DTE') + M->DT4_FILORI + M->DT4_NUMCOT + cCodPro))
		While DTE->(! Eof() .And. DTE->DTE_FILIAL + DTE->DTE_FILORI + DTE->DTE_NUMCOT + DTE->DTE_CODPRO == cSeekDTE)
			nQtdVol += DTE->DTE_QTDVOL
			DTE->(DbSkip())
		EndDo

	//-- Peso Cubado Informado na Solicitacao de Coleta
	ElseIf !Empty(M->DT4_NUMSOL) 
		DTE->(DbSetOrder(3))
		DTE->( MsSeek( cSeek := xFilial('DTE') + M->DT4_FILORI + M->DT4_NUMSOL + GdFieldGet('DVF_ITEM',n) ) )		
		While DTE->( ! Eof() .And. DTE->DTE_FILIAL + DTE->DTE_FILORI + DTE->DTE_NUMSOL + DTE->DTE_ITESOL == cSeek )
			nQtdVol += DTE->DTE_QTDVOL
			DTE->(DbSkip())
		EndDo
	EndIf

Else
	nPQtdVol	:= AScan(aHeadDTE,{|x|x[2]=='DTE_QTDVOL'})
	nSeek		:= AScan(aCubagem,{|x|x[1]==cCodPro})
	For nCntFor := 1 To Len(aCubagem[nSeek,2])
		nQtdVol += aCubagem[nSeek,2,nCntFor,nPQtdVol]
	Next
EndIf
If nQtdVol > 0 .And. nQtdVol != nTQtd
	lRet := TmsA040Pm3(4)		//-- chama novamente a rotina de peso cubado para informar corretamente os dados
EndIf
RestArea( aAreaAnt )
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA040Cli  ³ Autor ³ Patricia A. Salomao ³ Data ³20.02.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica quem sera o Cliente Devedor                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA040Cli()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Cliente Devedor                                    ³±±
±±³          ³ ExpC2 - Loja Devedor                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA040Cli(cCliDev, cLojDev, lCliCot)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasNew := GetNextAlias()
Local cQuery    := ""
Local lTMS040Cli:= ExistBlock("TMS040Cli")
Local aCliDev	:= {}
Default cCliDev := ""
Default cLojDev := ""
Default lCliCot := .F.

cCliDev := GetMV('MV_CLIGEN')
lCliGen := .T.

If SuperGetMV("MV_CLICOT",NIL,.F.) .Or. lCliCot
	If !Empty(M->DT4_CLIDEV) .And. !Empty(M->DT4_LOJDEV)	//-- Se a Pasta Aprovacao o Devedor estiver preenchido utilizar ele como cliente 
		cCliDev := M->DT4_CLIDEV+M->DT4_LOJDEV
		lCliGen := .F.
	Else
		//-- Utiliza o cliente informado no Cadastro de Solicitantes
		DUE->( DbSetOrder( 1 ) )
		If DUE->( MsSeek( xFilial('DUE') + M->DT4_CODSOL, .F. ) )
			If !Empty(DUE->DUE_CODCLI) .And. !Empty(DUE->DUE_LOJCLI)
				cQuery += " SELECT 1 "
				cQuery += "   FROM " + RetSqlName("AAM")
				cQuery += "  WHERE AAM_FILIAL = '" + xFilial("AAM")  + "' "
				cQuery += "    AND AAM_CODCLI = '" + DUE->DUE_CODCLI + "' "
				cQuery += "    AND AAM_LOJA   = '" + DUE->DUE_LOJCLI + "' "
				cQuery += "    AND AAM_STATUS = '1' " //-- Verifica se o Contrato Cliente esta com status "Ativo"
				cQuery += "    AND D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery( cQuery )
				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
				
				If (cAliasNew)->(Eof())
					If Select(cAliasNew) > 0
	    				(cAliasNew)->(DbCloseArea())
	  				EndIf
					cAliasNew := GetNextAlias()
					cQuery := " SELECT 1 "
					cQuery += "   FROM " + RetSqlName("AAM")
					cQuery += "  WHERE AAM_FILIAL = '" + xFilial("AAM")  + "' "
					cQuery += "    AND AAM_CODCLI = '" + DUE->DUE_CODCLI + "' "
					cQuery += "    AND AAM_ABRANG <> '1' "
					cQuery += "    AND AAM_STATUS = '1' " //-- Verifica se o Contrato Cliente esta com status "Ativo"
					cQuery += "    AND D_E_L_E_T_ = ' ' "
					cQuery := ChangeQuery( cQuery )
					dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )
				EndIF
				If (cAliasNew)->(!Eof())
					cCliDev := DUE->DUE_CODCLI+DUE->DUE_LOJCLI
					lCliGen := .F.
				EndIf
				(cAliasNew)->( DbCloseArea() )
			EndIf
		EndIf
	EndIf
EndIf

SA1->( DbSetOrder( 1 ) )
If	SA1->( ! MsSeek( xFilial('SA1') + cCliDev, .F. ) )
	Help('',1,'TMSA04005',,STR0026 + cCliDev,4,1)	//-- Cliente generico nao encontrado  (SA1)
	cCliDev := GetMV('MV_CLIGEN')
	lCliGen := .T.
	SA1->( MsSeek( xFilial('SA1') + cCliDev, .F. ) )
	lRet := .F.
EndIf

cCliDev := SA1->A1_COD
cLojDev := SA1->A1_LOJA
If lTMS040Cli
	aCliDev := ExecBlock('TMS040Cli',.F.,.F.,{cCliDev, cLojDev })
	If ValType(aCliDev) == "A" 
		cCliDev := aCliDev[1]
		cLojDev := aCliDev[2]
	EndIf
EndIf
RestArea( aAreaAnt )
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA040Tab ³ Autor ³ Eduardo de Souza     ³ Data ³ 20/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza tabela de Frete                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA040Tab()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA040Tab()

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

TmsVisTabel(M->DT4_FILORI,M->DT4_NUMCOT,,'1',GdFieldGet('DVF_CODPRO',n))

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA040VFrt³ Autor ³ Eduardo de Souza     ³ Data ³ 20/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza componentes de frete                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA040VFrt()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA040VFrt()

If Empty(aFrete)
	Aviso( STR0039 , STR0088 , { STR0089 } ) //"Atencao" ### "Tecle <F5> para atualizar a Composicao do Frete" ### "OK"
	Return( .F. )
EndIF	

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

TmsViewFrt('1')

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA040Venc³ Autor ³ Eduardo de Souza     ³ Data ³ 26/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cancelamento Automatico de cotacoes vencidas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA040Venc()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA040Venc()

Local cMemo := STR0055  // "Cotacao Vencida"

While DT4->(MsSeek(xFilial("DT4")+cFilAnt+"1")) .And. DT4->DT4_PRZVAL < dDataBase
	RecLock("DT4",.F.)
	DT4->DT4_DATCAN := dDataBase
	DT4->DT4_STATUS := StrZero( 9, Len( DT4->DT4_STATUS ) )
	//-- Grava Motivo do Cancelamento
	MSMM(,,,cMemo,1,,,"DT4","DT4_CODOBC")
	MsUnlock()
	DT4->(DbSkip())
EndDo

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TMSA040Ret ³ Autor ³ Eduardo de Souza     ³ Data ³ 26/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retomar Cotacao Cancelada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA040Ret()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA040Ret()

Local oDlg
Local oQtdDias
Local oDtLim
Local nQtdDias := 0
Local dDtLim   := dDataBase
Local nOpcao   := 0
Local cNumSol  := ''

//-- Retomar Cotacao Cancelada
If DT4->DT4_STATUS == StrZero( 9, Len( DT4->DT4_STATUS ) )
	If MsgYesNo( STR0060 ) // "Deseja Retomar Cotacao ?"

		DEFINE MSDIALOG oDlg FROM 000,000 TO 160,205 TITLE STR0059 PIXEL // "Retomar Cotacao"

		@ 001,004 TO 060,100 OF oDlg PIXEL
		@ 020,010 SAY STR0057 SIZE 70,10 OF oDlg PIXEL // "Dias Validade"
		@ 035,010 SAY STR0058 SIZE 70,10 OF oDlg PIXEL // "Dt  Validade"
		
		@ 020,055 	MSGET oQtdDias VAR nQtdDias PICTURE "9999" SIZE 027,008 OF oDlg PIXEL;
		           	VALID If(nQtdDias > 0,;
		           	(dDtLim:= dDataBase+nQtdDias,oDtLim:Refresh()),.F.)
		
		@ 035,055 	MSGET oDtLim VAR dDtLim PICTURE	"@D" SIZE 043,008 OF oDlg PIXEL
		oDtLim:lReadOnly:= .T.
		
		DEFINE SBUTTON FROM 65,40 TYPE 1 ENABLE OF oDlg ACTION (nOpcao:=1,oDlg:End())
		DEFINE SBUTTON FROM 65,70 TYPE 2 ENABLE OF oDlg	ACTION oDlg:End()
		
		ACTIVATE MSDIALOG oDlg CENTERED

		If nOpcao == 1
			cNumSol := DT4->DT4_NUMSOL
			RecLock("DT4",.F.)
			DT4->DT4_PRZVAL := dDtLim
			DT4->DT4_DATCAN := CToD("  /  /  ")
			DT4->DT4_STATUS := StrZero( 1, Len( DT4->DT4_STATUS ) )
			DT4->DT4_NUMSOL := CriaVar("DT4_NUMSOL",.F.)
			//-- Exclui Motivo do Cancelamento
			MSMM(DT4->DT4_CODOBC,,,,2)
			MsUnlock()

			// Limpa relacionamento da solicitacao de coleta
			If !Empty(cNumSol)
				DT5->(DbSetOrder(1))
				If DT5->(MsSeek(xFilial("DT5")+DT4->DT4_FILORI+cNumSol))
					RecLock("DT5",.F.)
					DT5->DT5_NUMCOT := CriaVar("DT5_NUMCOT",.F.)
					MsUnlock()
				EndIf
			EndIf

			// Verifica Se Existem Divergencias De Produtos (ONU)
			Tmsa040DDU()

		EndIf
	EndIf
Else
	Help(" ",1,"TMSA04044") //-- "Manutencoes sao permitidas somente em cotacoes de frete canceladas."
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA040Sho³ Autor ³ Eduardo de Souza      ³ Data ³05/07/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe get para digitacao do valor do fechado               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA040ShowGet(ExpN1)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Item do complemento.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA040ShowGet(nItem,nValFec)

Local cSay       := ''
Local nValor     := 0
Local nOpcA      := 0
Local oDlgGet
Local oPanel
Local oValor
Default nValFec  := 0

//-- Nao exibe o Get para o ultimo elemento do array que refere-se ao total do frete
If nItem == Len(aDesconto)
	Return( aDesconto )
EndIf	

//-- Permite informar o valor somente para componentes que permitem descontos
If !aDesconto[nItem,7]
	Return( aDesconto )
EndIf

If !Empty(nItem) .And. nItem <= Len(aDesconto)
	cSay := AllTrim(aDesconto[nItem, 1]) + ": "
EndIf

If Empty(nValFec)
	DEFINE MSDIALOG oDlgGet FROM 00,00 TO 100,290 PIXEL TITLE STR0062  //"Informe o valor fechado para :"
		oPanel := tPanel():New(03,03,"",oDlgGet,,,,,CLR_WHITE,140, 30, .T.) 
	
		@ 013, 005 SAY cSay SIZE 100,009 OF oPanel PIXEL COLOR CLR_BLUE
		@ 013, 085 MSGET oValor VAR nValor PICTURE PesqPict("DT6", "DT6_VALMER") SIZE 50, 010 OF oDlgGet PIXEL
	
		DEFINE SBUTTON FROM 37,115 TYPE 1 OF oDlgGet ENABLE ACTION (nOpcA := 1, oDlgGet:End())
	ACTIVATE MSDIALOG oDlgGet CENTERED
Else
	nValor := nValFec
	nOpcA  := 1
EndIf

If nOpcA == 1
	aDesconto[ nItem, 8] := nValor
	TmsA040Cal(5,3)
	//-- Se o Valor Informado for MAIOR que o Valor do Componente, calcula o % de Acrescimo do Item
	If	aDesconto[ nItem, 8] > aDesconto[ nItem, 2]
		aDesconto[ nItem, 10] := ( 100 * ( aDesconto[ nItem, 8] / aDesconto[ nItem, 2]) ) - 100 
		aDesconto[ nItem, 9 ] := 0	
	Else  //-- Calcula o % de Desconto do Item
		aDesconto[ nItem, 9 ] := (1 - ( aDesconto[ nItem, 8] / aDesconto[ nItem, 2] ) ) * 100
		aDesconto[ nItem, 10] := 0			
	EndIf
EndIf

Return( aDesconto )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA040Sol³ Autor ³ Patricia A. Salomao   ³ Data ³14.07.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao Chamada pela Consulta SXB (DVM) do campo DT4_NUMSOL; ³±±
±±³          ³Apresentar Tela contendo as Solicitacoes de Coleta do Solici³±±
±±³          ³tante informado                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA040Sol()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA040Sol()

Local cCadastro  := STR0091 //"Solicitacoes de Coleta"
Local aRotOld    := aClone(aRotina)
Local cFiltro1   := ""
Local aRotina    := {}
Local aMemo      := {}
Local nX         := 0
Local aArea      := GetArea()
Private nOpcSel  := 0

DbSelectArea("DT4")
For nX := 1 To FCount()
	AAdd(aMemo, M->&(FieldName(nX)) )
Next nX

aGetOld    := aClone(aGets)
aTelOld    := aClone(aTela)

aRotina	:= {	{ STR0003 , "TMSA460Mnt", 0, 2},;    		//"Visualizar
				{ STR0092 , "TMSConfSel", 0, 2,,,.T.} } 	//"Confirmar"

DT5->(DbSetOrder(2))

If DT5->(MsSeek(xFilial("DT5")+M->DT4_CODSOL))

	cFiltro1 := '"'+xFilial("DT5")+M->DT4_CODSOL+'"'

	MaWndBrowse(0,0,300,600,cCadastro,"DT5",,aRotina,,cFiltro1,cFiltro1,.T.)

Else
	Help('',1,'TMSA04051') //-- Nao existem Solicitacoes de Coleta para este Solicitante ...
EndIf

DbSelectArea("DT4")
For nX := 1 To FCount()
	M->&(FieldName(nX)) := aMemo[nX]
Next

RestArea( aArea )

aRotina := aClone(aRotOld)

Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA040VAtu³ Autor ³ Eduardo de Souza     ³ Data ³ 30/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se houve alguma modicacao q afete o valor do frete.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TmsA040VAtu()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA040                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA040VAtu()

Local aPosicao  := {}
Local lCalcFret := .F.

//-- Total do Frete Zerado
If nTValTot == 0 
	lCalcFret := .T.
EndIf

//-- Servico
If !lCalcFret
	If !Empty(_cServic) .And. _cServic <> M->DT4_SERVIC
		lCalcFret := .T.
	EndIf
EndIf
_cServic := M->DT4_SERVIC

//-- Regiao Origem
If !lCalcFret
	If  !Empty(_cCdrOri) .And. _cCdrOri <> M->DT4_CDRORI
		lCalcFret := .T.
	EndIf
EndIf
_cCdrOri := M->DT4_CDRORI

//-- Regiao Destino
If !lCalcFret
	If !Empty(_cCdrDes) .And. _cCdrDes <> M->DT4_CDRDES
		lCalcFret := .T.
	EndIf
EndIf
_cCdrDes := M->DT4_CDRDES

//-- Quilometragem da Cotacao
If !lCalcFret
	If  !Empty(nKm) .And. nKm <> M->DT4_KM
		lCalcFret := .T.
	EndIf
EndIf
nKm := M->DT4_KM

//-- Distancia Ida/Volta
If !lCalcFret
	If _cDistIV <> M->DT4_DISTIV
		lCalcFret := .T.
	EndIf
EndIf
_cDistIV := M->DT4_DISTIV

//-- ISS no preco
If !lCalcFret
	If !Empty(cIncIss) .And. cIncIss <> M->DT4_INCISS
		lCalcFret := .T.
	EndIf
EndIf
cIncIss := M->DT4_INCISS

//-- Cliente Destino
If !lCalcFret
	If !Empty(_cCliDes) .And. _cClides <> M->DT4_CLIDES
		lCalcFret := .T.
	EndIf
EndIf
_cCliDes := M->DT4_CLIDES

//-- Contribuinte
If !lCalcFret .And. _cContrib <> M->DT4_CONTRI
	lCalcFret := .T.
EndIf
_cContrib := M->DT4_CONTRI

//-- Remetente
If !lCalcFret
	If !Empty(cDT4CLIREM) .And. cDT4CLIREM <> M->DT4_CLIREM
		lCalcFret := .T.
	EndIf
EndIf
cDT4CLIREM := M->DT4_CLIREM

//-- Loja Remetente
If !lCalcFret
	If !Empty(cDT4LOJREM) .And. cDT4LOJREM <> M->DT4_LOJREM
		lCalcFret := .T.
	EndIf
EndIf
cDT4LOJREM := M->DT4_LOJREM

//-- Destinatário
If !lCalcFret
	If !Empty(cDT4CLIDES) .And. cDT4CLIDES <> M->DT4_CLIDES
		lCalcFret := .T.
	EndIf
EndIf
cDT4CLIDES:= M->DT4_CLIDES

//-- Loja Destinatário
If !lCalcFret
	If !Empty(cDT4LOJDES) .And. cDT4LOJDES <> M->DT4_LOJDES
		lCalcFret := .T.
	EndIf
EndIf
cDT4LOJDES:= M->DT4_LOJDES

//-- Devedor
If !lCalcFret
	If !Empty(cDT4CLIDEV) .And. cDT4CLIDEV <> M->DT4_CLIDEV
		lCalcFret := .T.
	EndIf
EndIf
cDT4CLIDEV:= M->DT4_CLIDEV

//-- Loja Devedor
If !lCalcFret
	If !Empty(cDT4LOJDEV) .And. cDT4LOJDEV <> M->DT4_LOJDEV
		lCalcFret := .T.
	EndIf
EndIf
cDT4LOJDEV:= M->DT4_LOJDEV

//-- Produtos da Cotacao
If !lCalcFret
	AAdd( aPosicao ,GdFieldPos( 'DVF_CODPRO' ) )
	AAdd( aPosicao ,GdFieldPos( 'DVF_QTDVOL' ) )
	AAdd( aPosicao ,GdFieldPos( 'DVF_QTDUNI' ) )
	AAdd( aPosicao ,GdFieldPos( 'DVF_PESO'   ) )
	AAdd( aPosicao ,GdFieldPos( 'DVF_PESOM3' ) )
	AAdd( aPosicao ,GdFieldPos( 'DVF_VALMER' ) )
	AAdd( aPosicao ,GdFieldPos( 'DVF_BASSEG' ) )
	AAdd( aPosicao ,Len(aHeader)+1 )
	lCalcFret := TmsCompaCols(aCols,aColsBack,aPosicao)
EndIf
aColsBack := aClone(aCols)

//-- Tipos de Veiculos da Cotacao
If !lCalcFret
	aPosicao := {}
	AAdd( aPosicao ,GdFieldPos( 'DVT_TIPVEI' ,aHeaderDVT ) )
	AAdd( aPosicao ,GdFieldPos( 'DVT_QTDVEI' ,aHeaderDVT ) )
	AAdd( aPosicao, Len(aHeaderDVT)+1 )
	lCalcFret := TmsCompaCols(aColsDVT,aColsDVTBack,aPosicao)
EndIf
aColsDVTBack := aClone(aColsDVT)

//-- Tipos de Veiculos da Cotacao
If !lCalcFret
	aPosicao  := {}
	lCalcFret := TmsCompaCols(aValInf,aValInfBack,,6)
EndIf
aValInfBack := aClone(aValInf)

Return( lCalcFret )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsCompaCols³ Autor ³ Eduardo de Souza    ³ Data ³ 30/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Compara aCols Principal e Backup                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsCompaCols(ExPA1,ExpA2,ExpA3,ExpN1)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - aCols Principal                                    ³±±
±±³          ³ ExpA2 - aCols Anterior                                     ³±±
±±³          ³ ExpA3 - Vetor contendo as posicoes a serem validadas       ³±±
±±³          ³ ExpN1 - Tamanho total do array para validacao de todos cpos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsCompaCols(aPrincipal,aBackup,aPosicao,nTotPos)

Local lRet  := .F.
Local nCnt  := 0
Local nCnt2 := 0
Default aPosicao := {}
Default nTotPos  := 0

//-- Compara o tamanho dos arrays.
If ( Len(aPrincipal) <> Len(aBackup) )
	aBackup := AClone(aPrincipal)
	Return( .T. )
EndIf

//-- Compara os arrays de acordo com as posicoes passadas.
For nCnt := 1 To Len(aPrincipal)
	//-- Valida as posicoes do aCols passadas atraves do parametro.
	If !Empty(aPosicao)
		For nCnt2 := 1 To Len(aPosicao)
			If aPrincipal[nCnt,aPosicao[nCnt2]] <> aBackup[nCnt,aPosicao[nCnt2]]
				aBackup := AClone(aPrincipal)
				lRet    := .T.
				Exit
			EndIf
		Next nCnt2
	Else
		//-- Valida todas posicoes do aCols.
		For nCnt2 := 1 To nTotPos
			If aPrincipal[nCnt,nCnt2] <> aBackup[nCnt,nCnt2]
				aBackup := AClone(aPrincipal)
				lRet    := .T.
				Exit
			EndIf
		Next nCnt2
	EndIf
Next nCnt

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsPesCub ³ Autor ³ Eduardo de Souza      ³ Data ³ 02/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica no perfil do Cliente de Calculo se o Peso Cubado   ³±±
±±³          ³devera nao ser informado                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsPesCub(EXPC1,ExpC2,ExpL1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Cliente                                             ³±±
±±³          ³ExpC2 - Loja                                                ³±±
±±³          ³ExpL1 - Valida se Exibe ou nao Help                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Conteudo do Campo DUO_CUBAGE                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsPesCub(cCliente,cLoja,lHelp,cCliRem,cLojRem,cCliDes,cLojDes,cCampo,cCodServ)

Local aPerfil	 := {}
Local cOptPesCub := ''
Local lIdentDoc  := DT4->(ColumnPos("DT4_DOCTMS")) > 0
Default cCliRem  := ''
Default cLojRem  := ''
Default cCliDes  := ''
Default cLojDes  := ''
Default lHelp    := .T.
Default cCampo   := ReadVar()
Default cCodServ := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O Campo DUO_CUBAGE, controla se devera ou nao informar o Peso Cubado na NF³
//³ 1- Sim                                                                    ³
//³ 2- Nao                                                                    ³
//³ 3- Obrigatorio                                                            ³
//³ 4- M3 (Metro Cubico)                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIdentDoc
	If !Empty(cCodServ) .And. M->DT4_DOCTMS == 'J' //-- CRT
		//-- Se for documento do transporte internacional habilita sempre
		//-- Se for documento do transporte internacional habilita sempre
		If cCampo == "M->DVF_PESOM3"
			cOptPesCub := '1' //-- Sim
		ElseIf cCampo == "M->DVF_METRO3"
			cOptPesCub := '4' //-- Metro Cubico
		EndIf
	Else
		If !Empty(cCliRem) .And. !Empty(cLojRem) .And. !Empty(cCliDes) .And. !Empty(cLojDes)
			aPerfil := TmsPerfil(cCliente,cLoja,,.F.,cCliRem,cLojRem,cCliDes,cLojDes)
		Else
			aPerfil := TmsPerfil(cCliente,cLoja,,.F.)
		EndIf
		If	! Empty(aPerfil)
			cOptPesCub := aPerfil[5]
		EndIf
	
		If Inclui .And. lHelp .And. Empty(cOptPesCub)
			Help(1,'','TMSA05038') // Perfil do Cliente de Calculo Nao Encontrado ... O Peso Cubado nao podera ser informado/calculado ...
		EndIf
	EndIf
Else 
	If !Empty(cCodServ) .And. MyPosicione('DC5',1,xFilial('DC5')+cCodServ,'DC5_DOCTMS') == 'J' //-- CRT
	//-- Se for documento do transporte internacional habilita sempre
		//-- Se for documento do transporte internacional habilita sempre
		If cCampo == "M->DVF_PESOM3"
			cOptPesCub := '1' //-- Sim
		ElseIf cCampo == "M->DVF_METRO3"
			cOptPesCub := '4' //-- Metro Cubico
		EndIf
	Else
		If !Empty(cCliRem) .And. !Empty(cLojRem) .And. !Empty(cCliDes) .And. !Empty(cLojDes)
			aPerfil := TmsPerfil(cCliente,cLoja,,.F.,cCliRem,cLojRem,cCliDes,cLojDes)
		Else
			aPerfil := TmsPerfil(cCliente,cLoja,,.F.)
		EndIf
		If	! Empty(aPerfil)
			cOptPesCub := aPerfil[5]
		EndIf
	
		If Inclui .And. lHelp .And. Empty(cOptPesCub)
			Help(1,'','TMSA05038') // Perfil do Cliente de Calculo Nao Encontrado ... O Peso Cubado nao podera ser informado/calculado ...
		EndIf
	EndIf
EndIf
Return( cOptPesCub )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A040ValInf³ Autor ³ Eduardo de Souza      ³ Data ³ 31/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valor Informado cotacao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040ValInf(ExpN1,ExpC1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±³          ³ ExpC1 - Produto                                            ³±±
±±³          ³ ExpC2 - No. da Cotacao                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A040ValInf(nOpcx,cCodPro,cNumCot)

Local aTabFre   := {}
Local cTabFre   := ''
Local cTipTab   := ''
Local lContinua := .T.

Default cNumCot := M->DT4_NUMCOT

If Empty(cCodPro)
	Help(' ', 1, 'TMSA04052' ) //Para apresentar o valor informado, devera ser digitado o produto da cotacao.
Else

	//-- Verifica quem sera' o Cliente Devedor da Cotacao
	TMSA040Cli(@cCliDev,@cLojDev)

	//-- Pesquisa a tabela de frete do cliente
	If Empty(aValInf)
		lContinua := .F.
		aTabFre := TmsTabFre(cCliDev,cLojDev,M->DT4_SERVIC,M->DT4_TIPFRE,M->DT4_CODNEG)
		If !Empty(aTabFre)
			cTabFre := aTabFre[1]
			cTipTab := aTabFre[2]
		EndIf
		If nOpcx <> 3 .Or. ;
			!Empty(cTabFre) .And. !Empty(cTipTab) .Or. ;
			MsgYesNo( STR0093 ) //Tabela de Frete nao localizada, deseja apresentar todos componentes do tipo valor informado ?
			lContinua := .T.
		EndIf
	EndIf
	
	//-- Valor Informado da nota fiscal
	If lContinua
		TmsValInf(aValInf,'1',M->DT4_FILORI,cNumCot,,,,,,,,,cCodPro,nOpcx,,cTabFre,cTipTab,,M->DT4_CODNEG)
	EndIf
	
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TMA040Cop ³ Autor ³ Patricia A. Salomao   ³ Data ³ 29/11/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Faz a Copia da Cotacao de Frete                      	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA040Cop(cAlias, nReg, nOpcx)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias a ser verificado no dicionario de dados	  ³±±
±±³          ³                                            				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA040Cop(cAlias, nReg, nOpcx)

TMSA040Mnt( cAlias, nReg, nOpcx )

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TMSA040Rat³ Autor ³ Patricia A. Salomao   ³ Data ³ 12/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Efetua o rateio do Frete conforme Peso de cada Produto 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA040Rat(ExpA1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Composicao do Frete do Item                        ³±±
±±³          ³ ExpN1 - Peso Total de Todos os Produtos                    ³±±
±±³          ³ ExpN2 - Peso por Produto                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA040Rat(aFrete, nPeso, nPesoProd, lUltimo, aFrtTot)
Local nValRat := 0
Local nCntFor := 0
Local nTotRat := 0
Local lTaxa   := .F.
Local nValTot := 0
Local nDecVal := TamSx3("DT8_VALPAS")[2]

Default lUltimo := .T.

For nCntFor := 1 To Len(aFrete)
	If aFrete[nCntFor][3] <> 'TF'
		lTaxa := TMSAComTax(aFrete[nCntFor,3])
		If !lTaxa 
			nValRat   := ( aFrete[nCntFor][2] * nPesoProd ) /nPeso
			nValRat   := NoRound(nValRat,nDecVal)
		Else
			If !lUltimo
				nValRat   := 0
			Else
				nValRat   := aFrete[nCntFor][2]
			EndIf
		EndIf
		
		If lUltimo
			nValTot := 0
			aEval(aFrtTot,{|aFrtPrd| aEval(aFrtPrd[2],{|aFrt| Iif(aFrt[3] == aFrete[nCntFor][3], nValTot += aFrt[2], Nil )} )})
			nValRat += aFrete[nCntFor][2] - (nValTot + nValRat)
		EndIf
		
		aFrete[nCntFor][2] := nValRat
		aFrete[nCntFor][6] := nValRat
		nTotRat   += nValRat
	Else
		aFrete[nCntFor][2] := nTotRat
		aFrete[nCntFor][6] := nTotRat
	EndIf
Next
Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef(lVisualiza)

Private aRotina

Default lVisualiza := .F.

If !lVisualiza

	aRotina := {	{ STR0002 ,'AxPesqui'	,0 ,1 ,0, .F.},;  //'Pesquisar'
					{ STR0003 ,'TMSA040Mnt' ,0 ,2 ,0 ,Nil},;  //'Visualizar'
					{ STR0004 ,'TMSA040Mnt' ,0 ,3 ,0 ,Nil},;  //'Incluir'
					{ STR0005 ,'TMSA040Mnt' ,0 ,4 ,0 ,Nil},;  //'Alterar'
					{ STR0006 ,'TMSA040Mnt' ,0 ,5 ,0 ,Nil},;  //'Cancelar'
					{ STR0007 ,'TMSA040Mnt' ,0 ,6 ,0 ,Nil},;  //'Aprovar'
					{ STR0008 ,'TMSA040Mnt' ,0 ,7 ,0 ,Nil},;  //'Liberar'
					{ STR0056 ,'TMSA040Ret' ,0 ,8 ,0 ,Nil},;  //'Retomar'
					{ STR0094 ,'TMSA040Cop' ,0 ,9 ,0 ,Nil},;  //'Copiar'
					{ STR0051 ,'ExecBlock("RtmsR10",.F.,.F.,{DT4->DT4_FILORI,DT4->DT4_NUMCOT})',0,10,0,Nil},;  //'Imprime Cotacao'
					{ STR0097 ,'TMSPRVENT'  ,0 ,12,0 ,Nil},;  //'Previsao de entrega'
					{ STR0009 ,'TMSA040Leg' ,0 ,11,0 ,.F.} }  //'Legenda'
Else

	aRotina := {	{ STR0003 ,'TMSA040Mnt' ,0 ,2 ,0 ,Nil},;  //'Visualizar'
					{ STR0051 ,'ExecBlock("RtmsR10",.F.,.F.,{DT4->DT4_FILORI,DT4->DT4_NUMCOT})',0,10,0,Nil},;  //'Imprime Cotacao'
					{ STR0009 ,'TMSA040Leg' ,0 ,11,0 ,.F.} }  //'Legenda'
EndIf

If ExistBlock("TM040MNU")
	ExecBlock("TM040MNU",.F.,.F.)
EndIf

Return( aRotina )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A040FPais³ Autor ³ Richard Anderson      ³ Data ³24/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Frete por país                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040FPais()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040FPais(nOpcx,lCalc)

Local nUsado    := 0
Local nOpcA     := 0
Local oDlg      := {}
Local nCntFor   := 0
Local aFreteP   := {}
Local nCnt      := 0
Local nSldFrt   := 0
Local nFrtPais  := 0
Local oDI7Stru  := FwFormStruct(2,"DI7",{|x| AllTrim(X) $ "DI7_FILORI|DI7_NUMCOT"})
Local nIncDI7   := 1

Default lCalc   := .F.

If M->DT4_TIPTRA <> StrZero(4,Len(DT4->DT4_TIPTRA)) //-- Rodoviario Internacional
	Help(' ', 1, 'TMSA04057' )	
	Return( .F. )
EndIf

If Empty(M->DT4_ROTA)
	If !lCalc
		MsgAlert("Rota não informada")
	EndIf		
	Return
ElseIf Empty(M->DT4_INCOTE)
	If !lCalc
		MsgAlert("Incoterm não informado")
	EndIf
	Return
EndIf		

SaveInter()

If !Empty(aFrtPais)
	aHeader := AClone(aFrtPais[1])
	aCols   := AClone(aFrtPais[2])
Else	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Array aHeader.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := {}
	aCols   := {}
	
	While nIncDI7 <= Len(oDI7Stru:aFields)

			nUsado += 1
			AAdd(aHeader, { AllTrim( oDI7Stru:aFields[nIncDI7,3])                 ,; //| Titulo do Campo
							AllTrim( oDI7Stru:aFields[nIncDI7,1])                 ,; //| X3_Campo
							GetSx3Cache(oDI7Stru:aFields[nIncDI7][1],"X3_PICTURE"),; //| picture
							GetSx3Cache(oDI7Stru:aFields[nIncDI7][1],"X3_TAMANHO"),; //| tamanho
							GetSx3Cache(oDI7Stru:aFields[nIncDI7][1],"X3_DECIMAL"),; //| decimal
							GetSx3Cache(oDI7Stru:aFields[nIncDI7][1],"X3_VALID")  ,; //| valid
                        	GetSx3Cache(oDI7Stru:aFields[nIncDI7][1],"X3_USADO")  ,; //| usado
							GetSx3Cache(oDI7Stru:aFields[nIncDI7][1],"X3_TIPO")   ,; //| tipo
							GetSx3Cache(oDI7Stru:aFields[nIncDI7][1],"X3_ARQUIVO"),; //| arquivo
							GetSx3Cache(oDI7Stru:aFields[nIncDI7][1],"X3_CONTEXT"),; //| context 
							GetSx3Cache(oDI7Stru:aFields[nIncDI7][1],"X3_CBOX")   ,; //| BOX
							GetSx3Cache(oDI7Stru:aFields[nIncDI7][1],"X3_RELACAO")}) //| Relacao/Ini.Padrao)
			nIncDI7++	
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Array aCols.                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Inclui
		DI7->(DbSetOrder(1))
		DI7->(MsSeek(xFilial("DI7")+M->DT4_FILORI+M->DT4_NUMCOT))
		While DI7->(!Eof()) .And. DI7->(DI7_FILIAL+DI7_FILORI+DI7_NUMCOT) == xFilial("DI7")+M->DT4_FILORI+M->DT4_NUMCOT
			AAdd(aCols,Array(nUsado+1))
			For nCntFor := 1 To nUsado
				If ( aHeader[nCntFor][10] != "V" )
					aCols[Len(aCols)][nCntFor] := DI7->(FieldGet(FieldPos(aHeader[nCntFor][2])))
				Else
					aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
				EndIf
			Next nCntFor
			aCols[Len(aCols)][nUsado+1] := .F.
			DI7->(dbSkip())
		EndDo
	EndIf
	If Empty(aCols) .And. (nOpcx == 3 .Or. nOpcx == 4)
		aFreteP := TMSFrtPais(M->DT4_ROTA,M->DT4_INCOTE)
		If Empty(aFreteP)
			If !lCalc
				MsgAlert("Frete por país não localizado para a rota e incoterm informados")
			EndIf
			RestInter()
			Return( Nil )
		EndIf			
		For nCnt := 1 To Len(aFreteP)
			//-- Nova linha no aCols
			TMSA210Cols()
			GDFieldPut( 'DI7_ITEM'   ,aFreteP[nCnt,1] ,nCnt )
			GDFieldPut( 'DI7_PAIS'   ,aFreteP[nCnt,2] ,nCnt )
			GDFieldPut( 'DI7_DEPAIS' ,aFreteP[nCnt,3] ,nCnt )
			GDFieldPut( 'DI7_PERFRE' ,aFreteP[nCnt,4] ,nCnt )
		Next nCnt			
	EndIf		
EndIf	
//-- Calcula o valor do frete por pais
nSldFrt := nTValTot
For nCnt := 1 To Len(aCols)
	If nTValTot == 0
		nFrtPais := 0
	ElseIf nCnt == Len(aCols) .And. nSldFrt > 0
		nFrtPais := nSldFrt
	Else								
		nFrtPais := (GDFieldGet('DI7_PERFRE',nCnt) * nTValTot) / 100
		nSldFrt  -= nFrtPais
	EndIf
	GDFieldPut( 'DI7_VALTOT' ,nFrtPais ,nCnt )
Next nCnt	

If lCalc
	nOpcA := 1
Else	
	DEFINE MSDIALOG oDlg TITLE 'Frete por País' Of oMainWnd PIXEL  FROM 94 ,104 TO 330,590 //-- Frete por País

		oGetD:= MsGetDados():New(15,2,113,243,nOpcx,"A040FrLOk()","A040FrTOk()","+DI7_ITEM",.T.,,,,99)
		oGetD:nMax := Len(aCols)
		oGetD:oBrowse:bDelete := {|| .F. }  //-- Nao Permite a deletar Linhas
			
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, If(oGetd:TudoOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()})
EndIf	

If nOpcA == 1 .And. nOpcx <> 2
	aFrtPais := { AClone(aHeader), AClone(aCols) }
EndIf	

RestInter()

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A040FrLOk³ Autor ³ Richard Anderson      ³ Data ³22.11.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de digitacao de linha                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA040                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040FrLOk()
Local lRet := .T.
//-- Nao avalia linhas deletadas.
If	!GDDeleted( n )
   If lRet := MaCheckCols(aHeader,aCols,n)
	   //-- Analisa se ha itens duplicados na GetDados.
	   lRet := GDCheckKey( { 'DI7_PAIS' }, 4 )
	EndIf   
EndIf
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A040FrTOk³ Autor ³ Richard Anderson      ³ Data ³22.11.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de confirmacao para gravacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040FrTOk()

Local lRet   := .T.
Local nPPerc := GDFieldPos( 'DI7_PERFRE' )
Local nTPerc := 0

//-- Analisa se os campos obrigatorios da GetDados foram informados.
If	lRet
	lRet := oGetD:ChkObrigat( n )
EndIf

//-- Analisa o linha ok.
If lRet
	lRet := A040FrLOk()
EndIf

//-- Analisa se todas os itens da GetDados estao deletados.
If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
	Help( ' ', 1, 'OBRIGAT2') //Um ou alguns campos obrigatorios nao foram preenchidos no Browse.
	lRet := .F.
EndIf

If lRet
	Aeval(aCols,{ | e | nTPerc += e[nPPerc] })
	If nTPerc <> 100
		MsgAlert("Percentual total diferente de 100%")
		lRet := .F.
	EndIf
EndIf	

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A040FDAF ³ Autor ³ Richard Anderson      ³ Data ³24/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Frete CIF/FOB no Incoterm DAF                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040FDAF()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA040                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040FDAF(nOpcx,lCalc)

Local nUsado    := 0
Local nOpcA     := 0
Local oDlg      := {}
Local nI        := 0
Local nCnt      := 0
Local nCntFor   := 0
Local cCodPas   := ''
Local nTotPas   := 0
Local nValCIF   := 0
Local nValFOB   := 0
Local nPCodPas  := 0
Local oDI8Stru  := FwFormStruct(2,"DI8", {|x| AllTrim(x) == "DI8_FILORI|DI8_NUMCOT"})
Local nIncDI8   := 1

Default lCalc   := .F.

If M->DT4_TIPTRA <> StrZero(4,Len(DT4->DT4_TIPTRA)) //-- Rodoviario Internacional
	Help(' ', 1, 'TMSA04057' )	
	Return( .F. )
EndIf

If M->DT4_INCOTE != "DAF"
	If !lCalc
		MsgAlert("Incoterm inválido")
	EndIf
	Return
EndIf

SaveInter()

If !Empty(aFrtDAF)
	aHeader := AClone(aFrtDAF[1])
	aCols   := AClone(aFrtDAF[2])
Else	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Array aHeader.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := {}
	aCols   := {}
	
	While nIncDI8 <= Len(oDI8Stru:aFields)

			nUsado += 1
			AAdd(aHeader,  { AllTrim( oDI8Stru:aFields[nIncDI8,3])                 ,; //| Titulo do Campo
							AllTrim( oDI8Stru:aFields[nIncDI8,1])                 ,; //| X3_Campo
							GetSx3Cache(oDI8Stru:aFields[nIncDI8][1],"X3_PICTURE"),; //| picture
							GetSx3Cache(oDI8Stru:aFields[nIncDI8][1],"X3_TAMANHO"),; //| tamanho
							GetSx3Cache(oDI8Stru:aFields[nIncDI8][1],"X3_DECIMAL"),; //| decimal
							GetSx3Cache(oDI8Stru:aFields[nIncDI8][1],"X3_VALID")  ,; //| valid
                        	GetSx3Cache(oDI8Stru:aFields[nIncDI8][1],"X3_USADO")  ,; //| usado
							GetSx3Cache(oDI8Stru:aFields[nIncDI8][1],"X3_TIPO")   ,; //| tipo
							GetSx3Cache(oDI8Stru:aFields[nIncDI8][1],"X3_ARQUIVO"),; //| arquivo
							GetSx3Cache(oDI8Stru:aFields[nIncDI8][1],"X3_CONTEXT"),; //| context 
							GetSx3Cache(oDI8Stru:aFields[nIncDI8][1],"X3_CBOX")   ,; //| BOX
							GetSx3Cache(oDI8Stru:aFields[nIncDI8][1],"X3_RELACAO")}) //| Relacao/Ini.Padrao)

			nIncDI8++
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Array aCols.                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Inclui
		DI8->(DbSetOrder(1))
		DI8->(MsSeek(xFilial("DI8")+M->DT4_FILORI+M->DT4_NUMCOT))
		While DI8->(!Eof()) .And. DI8->(DI8_FILIAL+DI8_FILORI+DI8_NUMCOT) == xFilial("DI7")+M->DT4_FILORI+M->DT4_NUMCOT
			AAdd(aCols,Array(nUsado+1))
			For nCntFor := 1 To nUsado
				If ( aHeader[nCntFor][10] != "V" )
					aCols[Len(aCols)][nCntFor] := DI8->(FieldGet(FieldPos(aHeader[nCntFor][2])))
				ElseIf aHeader[nCntFor,2] == "DI8_DESPAS" .And. DI8->DI8_CODPAS == "TF"
					aCols[Len(aCols)][nCntFor] := "TOTAL DO FRETE"
				Else
					aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
				EndIf
			Next nCntFor
			aCols[Len(aCols)][nUsado+1] := .F.
			DI8->(dbSkip())
		EndDo
	EndIf
	If Empty(aCols) .And. (nOpcx == 3 .Or. nOpcx == 4)
		aFreteD := TMSFrtDAF(M->DT4_CLIREM,M->DT4_LOJREM,M->DT4_CLIDES,M->DT4_LOJDES)
		If Empty(aFreteD)
			If !lCalc
				MsgAlert("Pagamento de Frete CIF/FOB não localizado")
			EndIf
			RestInter()
			Return( Nil )
		EndIf
		For nCnt := 1 To Len(aFreteD)
			//-- Nova linha no aCols
			TMSA210Cols()
			GDFieldPut( 'DI8_CODPAS' ,aFreteD[nCnt,1] ,nCnt )
			GDFieldPut( 'DI8_DESPAS' ,aFreteD[nCnt,2] ,nCnt )
			GDFieldPut( 'DI8_PERCIF' ,aFreteD[nCnt,3] ,nCnt )
			GDFieldPut( 'DI8_PERFOB' ,aFreteD[nCnt,4] ,nCnt )
		Next nCnt
	EndIf
EndIf
//-- Calcula o valor do frete CIF/FOB (Incoterm DAF)
For nCnt := 1 To Len(aCols)
	cCodPas := GDFieldGet('DI8_CODPAS',nCnt)
	nTotPas := 0
	If cCodPas == "TF"
		Loop
	EndIf
	For nI := 1 To Len(aFrete)
		nSeek := Ascan( aFrete[nI,2],{|x| x[3] == cCodPas })
		If	nSeek > 0
			nTotPas += aFrete[nI,2,nSeek,6]
		EndIf
	Next nI
	GDFieldPut( 'DI8_VALCIF' ,((GDFieldGet('DI8_PERCIF',nCnt) * nTotPas) / 100) ,nCnt )
	GDFieldPut( 'DI8_VALFOB' ,((GDFieldGet('DI8_PERFOB',nCnt) * nTotPas) / 100) ,nCnt )
	nValCIF += GDFieldGet('DI8_VALCIF',nCnt)
	nValFOB += GDFieldGet('DI8_VALFOB',nCnt)
Next nCnt
If nValCIF > 0 .Or. nValFOB > 0
	nPCodPas := GDFieldPos( 'DI8_CODPAS' )
	nTF := Ascan(aCols,{ | e | e[nPCodPas] == "TF" })
	If nTF > 0
		GDFieldPut( 'DI8_VALCIF' ,nValCIF ,nTF )
		GDFieldPut( 'DI8_VALFOB' ,nValFOB ,nTF )
	EndIf
EndIf

If lCalc
	nOpcA := 1
Else	
	DEFINE MSDIALOG oDlg TITLE 'Frete CIF/FOB' Of oMainWnd PIXEL  FROM 94 ,104 TO 330,825 //-- Frete CIF/FOB

		oGetD:= MsGetDados():New(15,2,113,360,nOpcx,"A040FDLOk()","A040FDTOk()","+DI8_ITEM",.T.,,,,99)
		oGetD:nMax := Len(aCols)
		oGetD:oBrowse:bDelete := {|| .F. }  //-- Nao Permite a deletar Linhas

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, If(oGetd:TudoOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()})
EndIf

If nOpcA == 1 .And. nOpcx <> 2
	aFrtDAF := { AClone(aHeader), AClone(aCols) }
EndIf

RestInter()

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A040FDLOk ³ Autor ³ Richard Anderson     ³ Data ³22.11.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de digitacao de linha                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA040                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040FDLOk()
Local lRet := .T.
//-- Nao avalia linhas deletadas.
If	!GDDeleted( n )
	If lRet := MaCheckCols(aHeader,aCols,n)
		//-- Analisa se ha itens duplicados na GetDados.
		lRet := GDCheckKey( { 'DI8_CODPAS' }, 4 )
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A040FDTOk ³ Autor ³ Richard Anderson     ³ Data ³22.11.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de confirmacao para gravacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040FDTOk()

Local lRet := .T.

//-- Analisa se os campos obrigatorios da GetDados foram informados.
lRet := oGetD:ChkObrigat( n )

//-- Analisa o linha ok.
If lRet
	lRet := A040FDLOk()
EndIf

//-- Analisa se todas os itens da GetDados estao deletados.
If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
	Help( ' ', 1, 'OBRIGAT2') //Um ou alguns campos obrigatorios nao foram preenchidos no Browse.
	lRet := .F.
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tmsa040TCliºAutor  ³Fabricio           º Data ³  29/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para identificar o tipo de cliente, se ele vai      º±±
±±º          ³ considerar o destinatário informado ou o DT4_PESSOA.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tmsa040TCli()

If !Empty(M->DT4_CLIDES) .And. !Empty(M->DT4_LOJDES)
	cTipoC := MyPosicione("SA1",1,xFilial("SA1") + M->DT4_CLIDES + M->DT4_LOJDES,"A1_TIPO")
Else
	cTipoC := "F"
EndIf

Return(cTipoC)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MyPosicione  ºAutor  ³Microsiga        º Data ³  24/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para manter em cache os recnos utilizadas para       º±±
±±º          ³substituir a funcao posicione originalmente chamada         º±±
±±º          ³o cache sera mantido no array STATIC aPosicione             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MyPosicione(cAlias,nOrdem,cChave,cCampoRet)
Local nPos := 0
Local cAuxFil := cEmpAnt+cFilAnt+xFilial(cAlias)
Local nOrdAux := StrZero(nOrdem,2)
Local xRetorno

(cAlias)->( dbSetOrder(nOrdem) )

If ( nPos := aScan(aPosicione,{|x|x[1]+x[2]+x[3]+x[4]==cAuxFil+cAlias+nOrdAux+cChave}) ) > 0
    (cAlias)->( dbGoto(aPosicione[nPos, 5]) )
    xRetorno := &(cAlias+"->("+cCampoRet+")")
Else
	If	(cAlias)->(MsSeek(cChave)) 
		aAdd(aPosicione, { cAuxFil, cAlias, nOrdAux, cChave, (cAlias)->(Recno()) } )
	EndIf
	xRetorno := &(cAlias+"->("+cCampoRet+")")
EndIf

Return(xRetorno)
//-------------------------------------------------------------------
/*/{Protheus.doc} A040WhTpNf
Função utilizada no X3_WHEN do campo DT4_TIPNFC
@author	Rafael Souza 
@version	1.0
@since		15/01/2016
@sample    Se o doctms do servico igual a 6 - devolucao, nao permite
			alterar o conteudo de DT4_TIPNFC.
/*/
//-------------------------------------------------------------------

Function A040WhTpNf()

Local lRet := .T.
Local lIdentDoc  := DT4->(ColumnPos("DT4_DOCTMS")) > 0

If	Posicione('DC5',1,xFilial('DC5')+M->DT4_SERVIC,'DC5_DOCTMS')==StrZero(6,Len(DC5->DC5_DOCTMS))
	lRet := .F.
ElseIf lIdentDoc .And. M->DT4_DOCTMS == StrZero(6,Len(DT4->DT4_DOCTMS))
	lRet := .F. 
EndIf


Return( lRet )
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa040DDU
@autor		: Eduardo Alberti
@descricao	: Define Se Existem Bloqueios Para a Tabela DDU
@since		: Feb./2015
@using		: Atualização De Bloqueios TMS (Tabela DDU).
@review	:

Argumentos	: < Tabela DT4 Deve Estar Posicionada >
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa040DDU()

	Local aArea   := GetArea()
	Local aArDVF  := DVF->(GetArea())
	Local aArSB5  := SB5->(GetArea())
	Local aArDY3  := DY3->(GetArea())
	Local aArSB1  := SB1->(GetArea())
	Local aProds  := {}
	Local cProd   := ''
	Local cMotBlq := ''
	Local nPos    := 0
	Local aVetRRE   := {}
	Local cCliRRE   := ""
	Local cLojRRE   := ""
	Local aRetRRE   := {}
	Local nI        := 0
	Local lBloqDT4  := .F.
	Local aVetCli   := {}

	// Define Se Usa Novo Modelo De Bloqueio Tab. DDU
	If FindFunction("TMSA029USE") .And. Tmsa029Use("TMSA040")

		DbSelectArea("DVF")
		DbSetOrder(1)
		MsSeek(xFilial("DVF") + DT4->DT4_FILORI + DT4->DT4_NUMCOT,.F.)

		aProds := {}

		While DVF->(!Eof()) .And. (DVF->DVF_FILIAL + DVF->DVF_FILORI + DVF->DVF_NUMCOT == xFilial("DVF") + DT4->DT4_FILORI + DT4->DT4_NUMCOT)

			// Carrega Vetor De Produtos Para Testar Incompatibilidade
			If "A" $ cMV_TMSINCO .Or. "F" $ cMV_TMSINCO
				If aScan(aProds,DVF->DVF_CODPRO) == 0
					aAdd(aProds,DVF->DVF_CODPRO)
				EndIf
			EndIf

			// Carrega Vetor para a RRE
			If "2" $ cMV_TMSRRE 
				cCliRRE:= Iif(Empty(M->DT4_CLIDEV),DUE->DUE_CODCLI,M->DT4_CLIDEV)
				cLojRRE:= Iif(Empty(M->DT4_LOJDEV),DUE->DUE_LOJCLI,M->DT4_LOJDEV)

				If !Empty(cCliRRE) .And. !Empty(cLojRRE)
					nPos:= aScan(aVetRRE, {|x| x[1] + x[2] + x[3] == cCliRRE + cLojRRE+ DVF->DVF_CODPRO })
					If nPos > 0
						aVetRRE[nPos][4]+= DVF->DVF_QTDVOL
						aVetRRE[nPos][5]+= DVF->DVF_PESO
						aVetRRE[nPos][6]+= DVF->DVF_PESOM3
						aVetRRE[nPos][7]+= DVF->DVF_VALMER
					Else
						Aadd(aVetRRE,{cCliRRE, cLojRRE, DVF->DVF_CODPRO, DVF->DVF_QTDVOL, DVF->DVF_PESO, DVF->DVF_PESOM3, DVF->DVF_VALMER,'',0 })
					EndIf

					//--- Totalizador do Valor da Mercadoria por Cliente
					nPos:= aScan(aVetCli, {|x| x[1] + x[2] == cCliRRE + cLojRRE })
					If nPos > 0
						aVetCli[nPos][3]+= DVF->DVF_VALMER
					Else
						Aadd(aVetCli,{cCliRRE, cLojRRE, DVF->DVF_VALMER})
					EndIf

				EndIf
			EndIf
			DVF->(DbSkip())
		EndDo

		If Len(aVetRRE) > 0
			For nI:= 1 To Len(aVetCli)
				aEval(aVetRRE, {|x| Iif( x[1]+x[2] == aVetCli[nI][1] + aVetCli[nI][2], x[9]+= aVetCli[nI][3], .T.) })  //Atualiza valor total por Cliente
			Next nI
		EndIf

		//-- Verifica Divergencia De Produtos
		aProds  := TmsRtDvP(aProds) // Determina Divergencias entre os Produtos Do Vetor
		If Len(aVetRRE) > 0
			aRetRRE:= TmsRetRRE(aVetRRE,,,"TMSA040",)
		EndIf

		//-- Monta Mensagem e Notifica Usuario
		If Len(aProds) > 0

			DbSelectArea("DVF")
			DbSetOrder(1)
			MsSeek(xFilial("DVF") + DT4->DT4_FILORI + DT4->DT4_NUMCOT,.F.)

			cMotBlq := ""

			While DVF->(!Eof()) .And. (DVF->DVF_FILIAL + DVF->DVF_FILORI + DVF->DVF_NUMCOT == xFilial("DVF") + DT4->DT4_FILORI + DT4->DT4_NUMCOT)

				cProd 	:= DVF->DVF_CODPRO
				nPos	:= Ascan(aProds,{ |x| x[1] == cProd } )

				DbSelectArea("SB5")
				DbSetOrder(1) //-- B5_FILIAL+B5_COD
				MsSeek(xFilial("SB5") + cProd ,.F.)

				DbSelectArea("DY3")
				DbSetOrder(1) //-- DY3_FILIAL+DY3_ONU+DY3_ITEM
				MsSeek(xFilial("DY3") + SB5->B5_ONU + SB5->B5_ITEM ,.F.)

				//-- Gera String Com Dados Das Divergencias Dos Produtos (Histórico)
				cMotBlq +=	( 	;
					STR0113 + "#" + DY3->DY3_NRISCO + " " + DY3->DY3_GRPEMB					+"#"+; //-- "Risco: "
				STR0102 + "#" + cProd														+"#"+; //-- "Produto:"
				STR0116 + "#" + Posicione("SB1",1,xFilial("SB1") + cProd,"B1_DESC")	+"#"+; //-- "Descrição:"
				STR0103 + "#" + Iif(nPos > 0,aProds[nPos,2],"")							+"|" ) //-- "Divergência"

				DVF->(DbSkip())
			EndDo

			//-- GeraBloqueio Por Divergencia De Produtos
			If Tmsa029Blq( 3  ,;		//-- 01 - nOpc
							'TMSA040',;			//-- 02 - cRotina
							'CR'  ,;				//-- 03 - cTipBlq
							DT4->DT4_FILORI,;		//-- 04 - cFilOri
							'DT4' ,;				//-- 05 - cTab
							'1' ,;					//-- 06 - cInd
							xFilial('DT4') + DT4->DT4_FILORI + DT4->DT4_NUMCOT,; //-- 07 - cChave
							DT4->DT4_NUMCOT ,;	//-- 08 - cCod
				cMotBlq         ,;	//-- 09 - cDetalhe
				)						//-- 10 - Opcao da Rotina

				lBloqDT4:= .T.
			EndIf
		EndIf

		//----Gera Bloqueio por RRE
		If Len(aRetRRE) > 0
			cMotBlq:= ""
			For nI:= 1 To Len(aRetRRE)
				cMotBlq +=	(;
							"RRE: "+ "#" + aRetRRE[nI,1] + " - "  + aRetRRE[nI,2] + " " + aRetRRE[nI,3]	+;
							"#" + STR0102 +;  // "Produto:"
							"#" + aRetRRE[nI,04] +;
							"#" + STR0121  +; //"Detalhes:"
							"#" + aRetRRE[nI,06] + "|" )
			Next nI

			//-- GeraBloqueio 
			If Tmsa029Blq( 3  ,;		//-- 01 - nOpc
							'TMSA040',;			//-- 02 - cRotina
							'RR'  ,;				//-- 03 - cTipBlq
							DT4->DT4_FILORI,;		//-- 04 - cFilOri
							'DT4' ,;				//-- 05 - cTab
							'1' ,;					//-- 06 - cInd
							xFilial('DT4') + DT4->DT4_FILORI + DT4->DT4_NUMCOT,; //-- 07 - cChave
							DT4->DT4_NUMCOT ,;	//-- 08 - cCod
				cMotBlq 		  ,;	//-- 09 - cDetalhe
				)						//-- 10 - Opcao da Rotina

				lBloqDT4:= .T.
			EndIf
		EndIf

		If lBloqDT4
			RecLock('DT4',.F.)
			//-- Grava status como 5 - Divergencia De Produto/RRE
			DT4->DT4_STATUS := StrZero( 5, Len( DT4->DT4_STATUS ) )
			MsUnLock()
		EndIf
	EndIf

	// Restaura Posicionamentos
	RestArea(aArSB1)
	RestArea(aArDY3)
	RestArea(aArSB5)
	RestArea(aArDVF)
	RestArea(aArea)

Return(lBloqDT4)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º    Funcao³Tmsa040Tip  º  Autor³guilherme.eduardo º  Data³16/06/2016   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³Funcao de validacao do campo DT4_TIPTRA                     º±±
±±º          ³Logica concentrada na funcao, pois a mesma eh utilizada em  º±±
±±º          ³dois pontos diferentes                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º       Uso³TMSA040Vld                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tmsa040Tip(cCliDev,cLojDev,aContrat,aItContrat)

Local lSrvDev	:= .F.
Local lFobDir := .T.
Local aPerfil := {}
Local cCliCal := ""
Local cLojCal := ""
Local lIdentDoc  := DT4->(ColumnPos("DT4_DOCTMS")) > 0

If Type('lMostraTela') != 'L'
	Private lMostraTela := .T.
EndIf

If Type('l040Auto') != 'L'
	Private l040Auto := .F.
EndIf

If Type('cDocTms') != 'C'
	Private cDocTms := ""
EndIf

//-- Verifica quem sera o Cliente Devedor da Cotacao
If Empty(cCliDev) .Or. Empty(cLojDev) .Or. !Empty(M->DT4_CLIDEV)
	TMSA040Cli(@cCliDev,@cLojDev)
EndIf
M->DT4_SERVIC := CriaVar('DT4_SERVIC', .F.)

//-- Quando o tipo do frete for FOB ( DTC_TIPFRE == 2 ) e o remetente for FOB dirigido ( DUO_FOBDIR == 1 ), a
//-- tabela de frete do cliente remetente sera utilizada para o calculo.
If AllTrim(SuperGetMV("MV_CLIGEN",NIL,"")) <> AllTrim(cCliDev + cLojDev)
	cCliCal := cCliDev
	cLojCal := cLojDev
	If !Empty(M->DT4_CLIREM) .And. !Empty(M->DT4_LOJREM) .And. !Empty(M->DT4_CLIDES) .And. !Empty(M->DT4_LOJDES)
		If M->DT4_TIPFRE == StrZero(2,Len(DT4->DT4_TIPFRE))
			aPerfil := TmsPerfil(M->DT4_CLIREM,M->DT4_LOJREM,.F.,.F.)
			If !Empty(aPerfil) .And. aPerfil[4] == StrZero(1,Len(DUO->DUO_FOBDIR))
				lFobDir := .T.
				If lTMA040FOB
					lFobDir := ExecBlock("TMA040FOB",.F.,.F.,{M->DT4_CLIDES,M->DT4_LOJDES,M->DT4_CLIREM,M->DT4_LOJREM})
					If ValType(lFobDir) <> "L"
						lFobDir := .T.
					EndIf
				EndIf
				aContrat := aClone(aContrat)
				If lFobDir
					aContrat := TMSContrat(cCliDev,cLojDev,,M->DT4_SERVIC,.F.,M->DT4_TIPFRE, .F.,,,,,,,,,,,,,,,M->DT4_CODNEG)					
					If Empty(aContrat)
						cCliCal := M->DT4_CLIREM
						cLojCal := M->DT4_LOJREM
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	cCliDev := cCliCal
	cLojDev	:= cLojCal
EndIf

//-- Monta uma Tela Contendo os Servicos cadastrados no Contrato do Cliente Generico
TMSPesqServ('DT4', cCliDev, cLojDev, M->DT4_SERTMS, M->DT4_TIPTRA, @aItContrat,,;
				M->DT4_TIPFRE, (l040Auto .Or. !lMostraTela),,,,,,, M->DT4_CDRORI, M->DT4_CDRDES,,,,,,,, M->DT4_CODNEG )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se a regiao de Origem esta habilitada para o Servico de Transporte ³
//³e Tipo de Transporte Informados.                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !TmsChkDTN( M->DT4_SERTMS, M->DT4_TIPTRA, M->DT4_CDRORI )
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se a regiao de Destino esta habilitada para o Servico de Transporte³
//³e Tipo de Transporte Informados.                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !TmsChkDTN( M->DT4_SERTMS, M->DT4_TIPTRA, M->DT4_CDRDES )
	Return(.F.)
EndIf

If !Empty(aContrat)
	M->DT4_NCONTR := aContrat[1,1]
EndIf

If !Empty(aItConTrat)
	//-- Qdo mudar o servico, zera valor informado.
	If Inclui .And. !Empty(aValInf) .And. MsgYesNo( STR0079 ) //'Existe valor informado para a cotacao, deseja limpar o valor informado na mudanca do servico ?'
		aValInf := {}
	EndIf
EndIf

If !Empty(M->DTC_TIPTRA)
	//-- Valida o codigo do servico digitado.
	DC5->( DbSetOrder( 1 ) )
	DC5->( ! MsSeek( xFilial('DC5') + M->DT4_SERVIC, .F. ) )
	If lIdentDoc .And. Empty(DC5->DC5_DOCTMS) .And. Empty(cDocTms)
		M->DT4_DOCTMS := TMSTipDoc(M->DT4_CDRORI,M->DT4_CDRDES)
		If !Empty(M->DT4_DOCTMS)
			M->DT4_DESDOC := TMSValField("M->DT4_DOCTMS",.F.,"DT4_DESDOC")
		EndIf
	ElseIf lIdentDoc .And. !Empty(DC5->DC5_DOCTMS) .And. Empty(cDocTms)
		M->DT4_DOCTMS := DC5->DC5_DOCTMS
		If !Empty(M->DT4_DOCTMS)
			M->DT4_DESDOC := TMSValField("M->DT4_DOCTMS",.F.,"DT4_DESDOC")
		EndIf
	ElseIf lIdentDoc .And. !Empty(cDocTms)
		M->DT4_DOCTMS := cDocTms
		M->DT4_DESDOC := TMSValField("M->DT4_DOCTMS",.F.,"DT4_DESDOC")
	EndIf
EndIf

If SuperGetMV("MV_CLICOT",Nil,.F.)
	//-- Caso o tipo do servico for 'transporte', tipo de frete 'FOB' e houver contrato 'CIF' para o cliente destinatario,
	//-- assume que e' Devolucao  parcial.
	lSrvDev:=TmsA050SDv(M->DT4_TIPFRE,cCliDev,cLojDev,M->DT4_SERTMS,M->DT4_TIPTRA,.F.,M->DT4_CLIREM,M->DT4_LOJREM,;
								cCliDev,cLojDev,cCliDev,cLojDev,"","",M->DT4_CODNEG)							
	If	lSrvDev
		//-- Se refere a uma Devolucao Parcial
		M->DT4_TIPNFC := StrZero(1,Len(DT4->DT4_TIPNFC))
	Else
		//-- Normal
		M->DT4_TIPNFC := StrZero(0,Len(DTC->DTC_TIPNFC))
	EndIf
EndIf

Return(.T.)

/*/{Protheus.doc} A040Consig()
	(long_description)
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function A040Consig(cCliRem,cLojRem,cCliDes,cLojDes,cCliDev,cLojDev)
Local cCliGen := SuperGetMv("MV_CLIGEN",,"")
Local lResult := .F.
	If !Empty(cCliRem+cLojRem) .And. !Empty(cCliDes+cLojDes)
		If	cCliDev+cLojDev <> cCligen .And. ;
			cCliDev+cLojDev <> cCliRem+cLojRem .And. ;
			cCliDev+cLojDev <> cCliDes+cLojDes
			lResult := .T.
		EndIf
	EndIf
Return lResult
