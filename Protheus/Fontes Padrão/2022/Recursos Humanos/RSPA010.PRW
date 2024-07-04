#Include "Protheus.ch"
#Include "Folder.ch"
#Include "font.ch"
#Include "colors.ch"
#Include "RSPA010.CH"


Static lRs010ValPE 	:= ExistBlock( "Rs010ValPE" )
Static lRspChkCPF	:= ExistBlock( "RspChkCPF" )
Static lRspAltLeg	:= ExistBlock("RspAltLeg")
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RSPA010  ³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de cadastramento do curriculo                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RSPA010()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA010                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³29/07/14³TQENN4³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±³Emerson Camp³21/08/14³TQGZLH³Ajuste no aHeader e aCols do quinto folder³±±
±±³            ³        ³      ³e troca do MSGETDADOS por MSNEWGETDADOS   ³±±
±±³Everson SP j 04/12/14|TRCXBV|Criada nova chave no SXE e SXF para gerar ³±±
±±³            |        |      |a numeração sequencial da tabela de       ³±±
±±³            |        |      |curriculos corretamente                   ³±±
±±³Emerson Camp³21/05/15³TRHJI0³Apenas para recompilar o fonte no RPO     ³±±
±±³Cícero Alves³05/03/15³TRUFR3³Retirada da função AjustaSx3Bol			  ³±±
±±³Henrique V. ³12/06/15³TSDXCP³Ajuste na função Rs010Nivel para que não  ³±±
±±³            ³        ³      ³gere errorlog no momento de realizar a    ³±±
±±³            ³        ³      ³Pesquisa de Cursos com Nivel              ³±±
±±³Mick  Silva ³12/06/15³TSDXCP³Ajuste para nao ocorrer error.log após    ³±±
±±³            ³        ³      ³emissao de mensagem de validacao de campo.³±±
±±³Marcos Cout.³02/12/16³ 99255³Ajuste para correção de alerta de Help ao ³±±
±±³            ³        ³      ³digitar o conteudo do campo de cargo.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Paulo O     |16/03/17|MRH-8503  		 |Ajustes para correção de Error.Log ao realizar 	 ³±±
±±³Inzonha     |        |      			 |alterações em outra aba após incluir avaliação	 ³±±
±±³M. Silveira ³26/05/17³DRHPONTP-458    ³Incluida a Rsp010ValCpo() para impedir a alteracao ³±±
±±³            ³        ³                ³da alternativa e do resultado.                     ³±±
±±³Oscar G.    ³06/10/20³DMINA-9842      ³Aplicación buenas practicas referentes a SX3. COL  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RSPA010( cAlias , nReg , nOpc, xRotAuto )
Local aCores	:= {}
Local lExistOpc	:= ( ValType( nOpc ) == "N" )
Local cFilSQG	:= ""
Local oMBrowse
Local nI		:= 0

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

Private cCadastro := OemToAnsi(STR0006) //"Curriculos"
Private lAtu
Private aRotAuto
Private lExecAuto := .F.

If xRotAuto <> NIL
	lExecAuto	:= .T.
	aRotAuto	:= aClone(xRotAuto)
EndIf

IF !ValidArqRsp()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³DOCRSP:                                                    	 ³
	//³ 	As cores definidas na mBrowse depende do campo QG_SITUAC.³
	//³   Foram definidas da seguinte maneira:                  	 ³
	//³   001 - VERDE         005 - LARANJA                     	 ³
	//³   002 - VERMELHO      006 - MARROM                      	 ³
	//³   003 - AMARELO       007 - PINK                        	 ³
	//³   004 - CINZA         e acima de 007 - PRETO            	 ³
	//³   					  FUN - AZUL				          	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCores  := { 	{ "SQG->QG_SITUAC=='001'",'BR_VERDE' 	},;
					{ "EMPTY(SQG->QG_SITUAC)",'BR_VERDE' 	},;
					{ "SQG->QG_SITUAC=='002'",'DISABLE' 	},;
					{ "SQG->QG_SITUAC=='003'",'BR_AMARELO' 	},;
					{ "SQG->QG_SITUAC=='004'",'BR_CINZA' 	},;
					{ "SQG->QG_SITUAC=='005'",'BR_LARANJA' 	},;
					{ "SQG->QG_SITUAC=='006'",'BR_MARROM' 	},;
					{ "SQG->QG_SITUAC=='007'",'BR_PINK' 	},;
					{ "SQG->QG_SITUAC=='FUN'",'BR_AZUL' 	},;
					{ "Val(SQG->QG_SITUAC) ==008",'BR_PRETO'} }
	If ( lRspAltLeg )
		aCores := ExecBlock("RspAltLeg" , .F. , .F. , { aCores , {}} )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada para incluir outras opcoes no Menu.                                ³
	//³Variaveis que podem ser Usadas                                                      ³
	//³aRotina = Opcoes menu 															   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("RSP10ROT")
		ExecBlock("RSP10ROT",.F.,.F.)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE 						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SQG")
	DbSetOrder(1)

	If lExecAuto .AND. nOpc <> 5
		mBrowseAuto(nOpc,aRotAuto[1,4],"SQG")
	ElseIf ( lExistOpc ) //Rotina chamada por outro programa (Rspa090)
		Rsp010Rot( cAlias , nReg , nOpc )
	Else
		oMBrowse := FWMBrowse():New()
		oMBrowse:SetAlias("SQG")
		oMBrowse:SetDescription(STR0006)	//Currículos

		If ExistBlock("RSP10FIL")
			cFilSQG	:= ExecBlock("RSP10FIL",.F.,.F.)
			oMBrowse:AddFilter("P.E. RSP10FIL",cFilSQG,.T.,.T.)
		Endif
		If SQG->(ColumnPos("QG_ACEITE")) > 0
			oMBrowse:AddFilter(STR0098, "EMPTY(QG_ACEITE) .OR. QG_ACEITE == '1'",.F.,.F.)	//"Consentimento: Aceites Pendentes"
			oMBrowse:AddFilter(STR0099, "QG_ACEITE == '2'",.F.,.F.)							//"Consentimento: Aceites Em Vigência"
		EndIf

		For nI := 1 to Len(aCores)
			oMBrowse:AddLegend( aCores[nI][1], aCores[nI][2] )
		Next nI

		oMBrowse:Activate()

	EndIf

	DbSelectArea("SQG")
	DbSetOrder(1)

EndIF

//Retorna o SET EPOCH padrao do framework
If(FindFunction( "RetPadEpoch" ))
	RetPadEpoch()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RSP010Rot³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para controle dos dados do curriculo              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RSP010Rot(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo 								  ³±±
±±³ 		 ³ ExpN1 = Numero do registro								  ³±±
±±³ 	 	 ³ ExpN2 = Numero da opcao Selecionada						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RSP010Rot(cAlias1,nReg,nOpcx)
Local bCampo	:= { |nCPO| Field(nCPO) }
Local aSaveArea	:= GetArea()
Local nControl	:= 0
Local aPages	:= {}
Local aTitles	:= {}
Local aVar		:= {}
Local oDlgFolder
Local oNome
Local ni		:= 0
Local oF4
Local cF4 		:= STR0007 //"<F4> Consulta Teste"
Local oSay01
Local oBtn
Local oFont
Local oGrupo
Local oDesc
Local lGetd		:= .F.
Local lVerFat	:= .T.
Local nGrava 	:= 3
Local nOpcFolder:= 0
Local nOpcLbx	:= 0
Local cParada 	:= ""
Local cCodSQG   := ""
Local nCodSQG   := 0

//Variaveis para verificar Duplicidade de Curriculo
Local oDlg1
Local nOpca		:= 0
Local aCpos		:= {"QG_NOME", "QG_RG", "QG_CIC"}
Local lRet		:= .T.
Local nOp		:= 0
Local cCurr2	:= ""
Local cNome2	:= ""
Local cRg2		:= ""
Local cCic2		:= ""
Local cNomVal	:= ""
Local cNomPic	:= ""
Local cRgVal	:= ""
Local cRgPic	:= ""
Local cCicVal	:= ""
Local cCicPic	:= ""

//Variaveis consideradas apenas no Mexico
Local cDat2		:= ""
Local cSex2		:= ""
Local dDatVal	:= ""
Local dDatPic	:= ""
Local cSexVal	:= ""
Local cSexPic	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar 1ª tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdv7Size		:= {}
Local aInfo7AdvSize	:= {}
Local aObj7Size		:= {}
Local aObj7Coords	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Dimensionar 2ª Tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aEnchCoords	:= {}
Local aGetDCoords	:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize3		:= {}
Local aInfoAdvSize3	:= {}
Local aObjSize3		:= {}
Local aObjCoords3	:= {}
Local aGDCoord3		:= {}

Local lOneColumn 	:= .F.

Local aButtons		:= {}	// Armazena os Botoes a serem inclusos na Enchoice
Local aRSP010But	:= {}	// Armazena os Botoes inclusos apartir do Ponto de Entrada
Local nX					// Variavel utilizada no ForNext

Local oPanel				// Variavel para posicionar os objetos da tela
Local oPanel2 				// Variavel para posicionar os objetos da tela
Local bSet15		:= {|| }
Local bSet24		:= {|| }
Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords 	:= {}

Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}
Local aObj2Coords 	:= {}

Local aAdv3Size		:= {}
Local aInfo3AdvSize	:= {}
Local aObj3Size		:= {}
Local aObj3Coords 	:= {}

Local aAdv4Size		:= {}
Local aInfo4AdvSize	:= {}
Local aObj4Size		:= {}
Local aObj4Coords 	:= {}

Local aAdv5Size		:= {}
Local aInfo5AdvSize	:= {}
Local aObj5Size		:= {}
Local aObj5Coords 	:= {}

Local aAdv6Size		:= {}
Local aInfo6AdvSize	:= {}
Local aObj6Size		:= {}
Local aObj6Coords 	:= {}

Local aAdv8Size		:= {}
Local aInfo8AdvSize	:= {}
Local aObj8Size		:= {}
Local aObj8Coords 	:= {}

Local aAreaSQG		:= {}
Local nRecno		:= 0
Local cRetSqlName	:= ""
Local cDriver		:= __cRDD

Local oOk      		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo      		:= LoadBitmap( GetResources(), "LBNO" )

Private cNome		:= ""
Private oFolder
Private aTela[0][0]
Private aGets[0]
Private aCols		:= {}
Private aHeader 	:= {}
Private oFont1
Private oGet01
Private oGet02
Private oGet03
Private oGet04
Private oGet05
Private oLbx
Private oLbx2
Private cLbx		:= ""
Private aLbx		:= {}
Private aLbx2		:= {}
Private nOpcao 		:= nOpcx
Private cVarTopico  := ""
Private cDescGrupo	:= ""
Private cGrupo		:= CriaVar("QG_GRUPO")
Private cAntGrupo	:= CriaVar("QG_GRUPO")
Private lOk			:= .F.
Private oBtnF
Private cSXBFator	:= ""
Private aListPast	:= Array(6)
Private cGetSM6		:= ""
Private oGetSay
Private lRS6Mult	:= .F.
Private lIncLbx		:= .F.
Private aListaSM6 	:= {}
Private aGrvSM6		:= {}
Private oListSM6
Private oPanelC
Private oPanelG

//Rotina proveniente do TCFA040 nao esta com aRotina carregado
If IsInCallStack("TCFA040")
	Private aRotina := MenuDef()
	Private lExecAuto := .F.
EndIf

//	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//	³ Matriz aListPast 					³
//	³									³
//	³- Historico Profissional			³
//	³ [2][1] aHeader GetDados 01		³
//	³ [2][2] aCols GetDados 01			³
//	³									³
//	³- Cursos / Escolaridade			³
//	³ [3][1] aHeader GetDados 02		³
//  ³ [3][2] aCols GetDados 02  	   	³
//	³									³
//	³- Qualificacoes do Curriculo		³
//	³ [4][1] aHeader GetDados 03		³
//	³ [4][2] aCols GetDados 03			³
//	³									³
//	³- Avaliacao do Curriculo			³
//	³ [6][1] aHeader GetDados 04		³
//  ³ [6][2] aCols GetDados 04  	   	³
//	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private aSvGetD		:= {}

//****************************************************************************************************************
//Ponto de Entrada para adicionar Botoes na EnchoiceBar
//****************************************************************************************************************
if ExistBlock("RSP010But") .AND. !lExecAuto
	aRSP010But := ExecBlock("RSP010But",.F.,.F.)
	for nX := 1 to len( aRSP010But )
		aAdd( aButtons, aRSP010But[nX] )
	next nX
endif

Aadd(aSvGetD,{{},{},1,{}})

// Verifica se existem todos os fatores no SQV.
If 	nOpcao == 4 .AND. !lExecAuto
	Processa({||Rs010VerF(@lVerFat,SQG->QG_FILIAL,SQG->QG_CURRIC)},OemToAnsi(STR0040)) //"Aguarde... Verificando Fat. Avaliacao no Cad. Geral Avaliacao"
	If !lVerFat
		MsgAlert(STR0052, STR0047)	// "Na pasta de Qualificacoes do Candidato possui Fatores que nao se encontram no Cadastro de Fatores de Avaliacao Geral. Favor verificar."###"Atencao"
	EndIf
EndIf

// 1 - aHeader
// 2 - aCols
// 3 - n
// 4 - chave

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura‡Æo da Enchoice  - Folder 01				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SQG")
DbSetOrder(1)

If (lExecAuto .AND. nOpcao == 3) .OR. (!lExecAuto .AND. INCLUI )
	// Forca EOF() para nao gravar em memoria o conteudo do curriculum posicionado.
	aAreaSQG	:=	SQG->( GetArea() )
	nRecno		:=	SQG->( LastRec() )
	SQG->( dbGoTo(++nRecno) )
EndIf

cRetSqlName := RetSqlName( "SQG" )+"\3"

For nI := 1 To FCount()
	M->&(Eval(bCampo,nI)) := FieldGet(nI)
	lInit := .F.

	If ( nOpcao == 3 )		// inclusao
		If ( ExistIni(Eval(bCampo,nI)) )

			M->&(Eval(bCampo,nI)) := InitPad(SX3->X3_RELACAO)
			lInit := .T.

			If (  Eval(bCampo,nI) == "QG_CURRIC" )
				nCodSQG:= (Val(GetSXENum("SQG","QG_CURRIC",xFilial('SQG')+cRetSqlName)))
				cCodSQG:= STRZero(nCodSQG,6)
				M->&(Eval(bCampo,nI)):= cCodSQG
			Endif

			If ( ValType(M->&(Eval(bCampo,nI))) == "C" )
				M->&(Eval(bCampo,nI)) := Padr(M->&(Eval(bCampo,nI)),GetSX3Cache(Eval(bCampo,nI),"X3_TAMANHO"))
			Else
				If ( ValType(M->&(Eval(bCampo,nI))) == "D" )
					M->&(Eval(bCampo,nI)) := &(GetSX3Cache(Eval(bCampo,nI),"X3_RELACAO"))
				EndIf
			Endif
			
			If ( M->&(Eval(bCampo,nI)) == NIL )
				lInit := .F.
			EndIf

		EndIf
		If ( ! lInit )
			If ( ValType(M->&(Eval(bCampo,nI))) == "C" )
				M->&(Eval(bCampo,nI)) := Space(Len(M->&(Eval(bCampo,nI))))
			ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "N" )
				M->&(Eval(bCampo,nI)) := 0
			ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "D" )
				M->&(Eval(bCampo,nI)) := Ctod("  /  /  ")
			ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "L" )
				M->&(Eval(bCampo,nI)) := .F.
			EndIf
		EndIf
	EndIf
Next

If (lExecAuto .AND. nOpcao == 3) .OR. (!lExecAuto .AND. INCLUI )
	RestArea(aAreaSQG)
EndIf

If nOpcao # 3			// #Inclusao
	cGrupo	  := SQG->QG_GRUPO
	cAntGrupo := SQG->QG_GRUPO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Evitar duplicidade de Curriculos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf !lExecAuto
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdv7Size		:= MsAdvSize( , .T., 50)
	aInfo7AdvSize	:= { aAdv7Size[1] , aAdv7Size[2] , aAdv7Size[3] , aAdv7Size[4] , 10 , 5 }
	aAdd( aObj7Coords , { 000 , 020 , .T. , .F. } )
	aAdd( aObj7Coords , { 000 , 020 , .T. , .F. } )
	aAdd( aObj7Coords , { 000 , 020 , .T. , .F. } )
	aAdd( aObj7Coords , { 000 , 020 , .T. , .F. } )
	aAdd( aObj7Coords , { 000 , 000 , .T. , .T. } )
	aObj7Size	:= MsObjSize( aInfo7AdvSize , aObj7Coords )

	SETAPILHA()
	DEFINE MSDIALOG oDlg1  FROM aAdv7Size[7],0 TO aAdv7Size[6],aAdv7Size[5] TITLE OemToAnsi(STR0006)OF oMainWnd  PIXEL//"Curriculos"

	cCurr2 := FWX3Titulo("QG_CURRIC")
	
	cNome2 	:= FWX3Titulo("QG_NOME")
	cNomVal	:= GetSX3Cache("QG_NOME", "X3_VALID")
	cNomPic	:= GetSX3Cache("QG_NOME", "X3_PICTURE")
	
	@ aObj7Size[2,1],aObj7Size[2,2] 	SAY cNome2 PIXEL		//"Nome"
	@ aObj7Size[2,1],aObj7Size[2,2]+35 MSGET M->QG_NOME VALID &cNomVal PICTURE cNomPic PIXEL SIZE 100,7

 	If cPaisLoc=="PTG"
		cCic2 	:= FWX3Titulo("QG_CIC")
		cCicVal	:= GetSX3Cache("QG_CIC", "X3_VALID")
		cCicPic	:= GetSX3Cache("QG_CIC", "X3_PICTURE")
		@ aObj7Size[3,1],aObj7Size[3,2] SAY cCic2 PIXEL		//"CPF"
		@ aObj7Size[3,1],aObj7Size[3,2]+35 MSGET M->QG_CIC VALID RSPA010CPF(M->QG_CIC,cCicVal) PICTURE cCicPic PIXEL SIZE 50,7
	Else
		cRg2 	:= FWX3Titulo("QG_RG")
		cRgVal	:= GetSX3Cache("QG_RG", "X3_VALID")
		cRgPic	:= GetSX3Cache("QG_RG", "X3_PICTURE")
		@ aObj7Size[3,1],aObj7Size[3,2] SAY cRg2 PIXEL		//"R.G."
		@ aObj7Size[3,1],aObj7Size[3,2]+35 MSGET M->QG_RG VALID &cRgVal PICTURE cRgPic PIXEL SIZE 50,7

		cCic2 	:= FWX3Titulo("QG_CIC")
		cCicVal	:= If (cPaisloc == "MEX", "", GetSX3Cache("QG_CIC", "X3_VALID"))
		cCicPic	:= If (cPaisLoc <> "COL", GetSX3Cache("QG_CIC", "X3_PICTURE"), PICTNIT())
		@ aObj7Size[4,1],aObj7Size[4,2] SAY cCic2 PIXEL		//"CPF"
		@ aObj7Size[4,1],aObj7Size[4,2]+35 MSGET M->QG_CIC VALID RSPA010CPF(M->QG_CIC,cCicVal) PICTURE cCicPic PIXEL SIZE 50,7
	Endif
	ACTIVATE MSDIALOG oDlg1 ON INIT (EnchoiceBar(oDlg1, {|| nOpca:= 1,oDlg1:End() },{||nOpca:=2,oDlg1:End()})) CENTERED
	SETAPILHA()

	If nOpca == 1

		lRet := .T.
		dbSelectArea("SQG")
		dbSetOrder(3)
		If !Empty(M->QG_CIC) .and. dbSeek(xFilial("SQG")+M->QG_CIC)
			lRet := .F.
	    EndIf

		If lRet
			dbSetOrder(2)
			If !Empty(M->QG_RG) .And. dbSeek(xFilial("SQG")+M->QG_RG)
				lRet := .F.
			EndIf
		EndIf

		If lRet
			dbSetOrder(5)
			If !Empty(M->QG_NOME) .And. dbSeek(xFilial("SQG")+M->QG_NOME)
				lRet := .F.
			EndIf
	    EndIf

		If !lRet

			nOp := Aviso(OemToAnsi(STR0047),;	//"Atencao"
					OemToAnsi(STR0050)+"   "+;	//"Informacoes ja estao cadastradas em outro curriculo: "
					cCurr2+": "	+SQG->QG_CURRIC+"   "+;
					cNome2+": "	+SQG->QG_NOME 	+"   "+;
					cRg2+": "	+SQG->QG_RG 	+"   "+;
					cCic2+": "	+SQG->QG_CIC	,;
					{STR0049,STR0003})  //"Abandonar"###"Incluir"]

			If nOp == 1
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Restaura Arquivos							   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If __lSX8
					RollBackSX8()
				EndIf

				DbSelectArea("SQG")
				DbSetOrder(1)
				RestArea(aSaveArea)
				Return
			EndIf
		EndIf

	Else	// Tecla Cancela
		If __lSX8
			RollBackSX8()
		EndIf

		Return

    EndIf

	DbSelectArea("SQG")
	DbSetOrder(1)

	aTela	:= {}
	aGets	:= {}
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura variaveis do Objeto Folder				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aTitles,OemtoAnsi(STR0008)) //"&Dados Curriculo"
Aadd(aPages,"HEADER")
nControl++

Aadd(aTitles,OemtoAnsi(STR0009)) //"&Hist. Profissional"
Aadd(aPages,"HEADER")
nControl++

Aadd(aTitles,OemtoAnsi(STR0010)) //"&Cursos"
Aadd(aPages,"HEADER")
nControl++

Aadd(aTitles,OemtoAnsi(STR0011)) //"&Qualificacao"
Aadd(aPages,"HEADER")
nControl++

Aadd(aTitles,OemtoAnsi(STR0012)) //"&Avaliacao"
Aadd(aPages,"HEADER")
nControl++

Aadd(aTitles,OemtoAnsi(STR0088)) //"&Características"
Aadd(aPages,"HEADER")
nControl++

If nOpcao == 3			// Inclusao
	cNome 	:=""
EndIf

If nOpcao # 2			// Visual
	lGetD :=.T.
EndIf


Set Key VK_F4 To A010F4()

SETAPILHA()
DEFINE FONT oFont1 NAME "Arial Negrito" SIZE 0, -11

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !lExecAuto
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T., .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )		//Cabeçalho e TFolder

	aAdv1Size		:= MsAdvSize(.F.)
	aInfo1AdvSize	:= { 1 , 1 , aAdv1Size[3] , aAdv1Size[4] , 5 , 5 }
	aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )
	aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords ) 	//MsMGet Inicial

	aAdv2Size    	:= MsAdvSize(.F.)
	aInfo2AdvSize   := { 0 , 0 , aAdv2Size[3] , aAdv2Size[4] , 5 , 5 }
	aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )
	aObj2Size 		:= MsObjSize( aInfo2AdvSize , aObj2Coords ) 	//Segunda e Terceira abas (Hist. Profissional/Cursos)


	aAdv3Size    	:= MsAdvSize(.F.)
	aInfo3AdvSize   := { 0 , 0 , aAdv3Size[3] , aAdv3Size[4] , 5 , 5 }
	aAdd( aObj3Coords , { 000 , 010 , .T. , .F. } )
	aAdd( aObj3Coords , { 000 , 000 , .T. , .T. } )
	aObj3Size 		:= MsObjSize( aInfo3AdvSize , aObj3Coords ) 	//Quarta aba (Qualificacao)

	aAdv4Size    	:= MsAdvSize()
	aInfo4AdvSize   := { 0 , 0 , aAdv4Size[3] , aAdv4Size[4] , 5 , 5 }
	aAdd( aObj4Coords , { 050 , 000 , .T. , .T. } )
	aAdd( aObj4Coords , { 005 , 000 , .F. , .T. } )
	aAdd( aObj4Coords , { 050 , 000 , .T. , .T. } )
	aObj4Size 		:= MsObjSize( aInfo4AdvSize , aObj4Coords, , .T. ) 	//Quinta aba (Avaliacao)

	aAdv5Size    	:= aClone(aObj4Size[1])
	aInfo5AdvSize   := { aAdv5Size[2] , aAdv5Size[1] , aAdv5Size[4] , aAdv5Size[3] , 5 , 5 }
	aAdd( aObj5Coords , { 000 , 000 , .T. , .T., .T. } )
	aAdd( aObj5Coords , { 000 , 010 , .T. , .F. } )
	aObj5Size 		:= MsObjSize( aInfo5AdvSize , aObj5Coords )

	aAdv6Size    	:= aClone(aObj4Size[3])
	aInfo6AdvSize   := { aAdv6Size[2] , aAdv6Size[1] , aAdv6Size[4] , aAdv6Size[3] , 5 , 5 }
	aAdd( aObj6Coords , { 000 , 000 , .T. , .T. } )
	aAdd( aObj6Coords , { 000 , 010 , .T. , .F. } )
	aObj6Size 		:= MsObjSize( aInfo6AdvSize , aObj6Coords )

	aAdv8Size    	:= aClone(aObj4Size[3])
	aInfo8AdvSize   := { aAdv8Size[2] , aAdv8Size[1] , aAdv8Size[4] , aAdv8Size[3] , 5 , 5 }
	aAdd( aObj8Coords , { 000 , 000 , .T. , .T. } )
	aAdd( aObj8Coords , { 000 , 010 , .T. , .F. } )
	aObj8Size 		:= MsObjSize( aInfo8AdvSize , aObj8Coords )

	cNome := OemtoAnsi(STR0021)+M->QG_CURRIC+"     "+OemtoAnsi(STR0022)+M->QG_NOME

	DEFINE MSDIALOG oDlgFolder TITLE cCadastro FROM  aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

	@ aObjSize[1,1],aObjSize[1,2] SAY oNome PROMPT cNome		SIZE 300	,10 OF oPanel PIXEL

	oFolder := TFolder():New(aObjSize[2,1],aObjSize[2,2],aTitles, aPages,oDlgFolder,,,, .T., .T.,aObjSize[2,3] 	,aObjSize[2,4]	,)
	oFolder:bSetOption:={|nAtu| A010Muda(nAtu,oFolder:nOption,oNome)}

	For nI := 1 to Len(oFolder:aDialogs)
		oFolder:aDialogs[nI]:oFont := oDlgFolder:oFont
	Next

	oFolder:aPrompts[1] := STR0008 //"&Dados Curriculo"
	oFolder:aPrompts[2] := STR0009 //"&Hist. Profissional"
	oFolder:aPrompts[3] := STR0010 //"&Cursos"
	oFolder:aPrompts[4] := STR0011 //"&Qualificacao"
	oFolder:aPrompts[5] := STR0012 //"&Avaliacao"
	oFolder:aPrompts[6] := STR0088 //"&Características"

	PUBLIC nLastkey

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configura‡Æo da GetDados - Folder 06				 ³
	//³ *** Características		                  			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader	:= {}
	aCols   := {}
	//aListPast[6]:=	RSP010Fill(7,nOpcx)
	A010SM6(nOpcx)

	n		:= 1
	If !Empty(aLbx2[1][2])
		@ aObj4Size[1,1], aObj4Size[1,2] TO aObj4Size[1,3]-72, aObj4Size[1,4] LABEL "" OF oFolder:aDialogs[6] PIXEL

		@ aObj5Size[1,1], aObj5Size[1,2] LISTBOX oLbx2 VAR cLbx FIELDS HEADER;
					  		OemtoAnsi(STR0089),; 				//1 "Código"
							OemtoAnsi(STR0090);					//2 "Tipo"
						 SIZE aObj5Size[1,3],aObj5Size[1,4]-60 OF oFolder:aDialogs[6];
						ON CHANGE (A010AtuSr6(oLbx2:nAt)) PIXEL

		oLbx2:SetArray(aLbx2)
		oLbx2:bLine := { ||  { aLbx2[oLbx2:nAt,1],aLbx2[oLbx2:nAt,2]}}

		@ aObj4Size[3,1], aObj4Size[3,2] TO aObj4Size[3,3]-72, aObj4Size[3,4]-15 LABEL "" OF oFolder:aDialogs[6] PIXEL

		oPanelC:= tPanel():New(aObj4Size[3,1]+5,aObj4Size[3,2]+5,"",oFolder:aDialogs[6],oFont1,.T.,,,,aObj4Size[1,4]-30,aObj4Size[1,3]-87)

		@ 0, aObj5Size[1,2]-10 LISTBOX oListSM6 VAR cListSM6 FIELDS HEADER "", STR0091 PIXEL SIZE aObj5Size[1,3]-15,aObj5Size[1,4]-60 OF oPanelC;
					ON dblClick(a010CarSM6(),oListSM6:Refresh())

		oListSM6:SetArray( aListaSM6 )

		oListSM6:bLine := {||     {Iif(aListaSM6[oListSM6:nAt,1],oOk,oNo),aListaSM6[oListSM6:nAt,2]}}

		oPanelG:= tPanel():New(aObj4Size[3,1]+5,aObj4Size[3,2]+5,"",oFolder:aDialogs[6],oFont1,.T.,,,,aObj4Size[1,4]-30,aObj4Size[1,3]-87)

		oGetSay := TGet():New( 005, 005,  {|u| If(PCount() == 0, cGetSM6 , cGetSM6 := u)},oPanelG,aObj4Size[1,3]-100, 20, "!@",{|| aGrvSM6[oLbx2:nAt][2] := cGetSM6 ,aGrvSM6[oLbx2:nAt][4] := .T., .T.},,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGetSM6",,,,.T.,,,STR0091,1 ) //Resposta

		If Empty(aListaSM6)
			oPanelC:lVisible := .F.
		Else
			oPanelG:lVisible := .F.
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configura‡Æo da GetDados - Folder 05				 ³
	//³ *** Avaliacao do Curriculo               			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aHeader  := {}
	aCols    := {}

	aListPast[5]:=	RSP010Fill(5,nOpcx)
	A010SQR(nOpcx)

	@ aObj4Size[1,1], aObj4Size[1,2] TO aObj4Size[1,3]-72, aObj4Size[1,4] LABEL "" OF oFolder:aDialogs[5] PIXEL

	@ aObj5Size[1,1], aObj5Size[1,2] LISTBOX oLbx VAR cLbx FIELDS HEADER;
				  		OemtoAnsi(STR0013),; 				//1 "Teste"
						OemtoAnsi(STR0014),; 				//2 "Descricao Teste"
						OemtoAnsi(STR0015),; 				//3 "Topico"
						OemtoAnsi(STR0016),; 				//4 "Descricao Topico"
						OemtoAnsi(STR0017),; 				//5 "Resultado"
						OemtoAnsi(STR0018),;  				//6 "Situacao"
						OemtoAnsi(STR0065),;			    //7 "Vaga"
						OemtoAnsi(STR0066);			        //8 "Data"
					 SIZE aObj5Size[1,3],aObj5Size[1,4]-85 OF oFolder:aDialogs[5];
					ON CHANGE (nPos:=oLbx:nAt,A010AtuGD(nPos,1)) PIXEL

	oLbx:SetArray(aLbx)
	oLbx:bLine := { ||  { aLbx[oLbx:nAt,1],aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4],Str(Val(aLbx[oLbx:nAt,5]),7,2),aLbx[oLbx:nAt,6],aLbx[oLbx:nAt,7],aLbx[oLbx:nAt,8]}}

	If nOpcao == 3 .Or. nOpcao == 4		// Inclusao e Alteracao
		DEFINE SBUTTON FROM aObj5Size[1,4]-60,aObj5Size[1,2]+5  TYPE  4 ENABLE OF oFolder:aDialogs[5] ACTION (lIncLbx := .T., aVar:=A010ListBox(oLbx:nAt,1),IIF(!Empty(aVar),A010Acres(oLbx:nAt,oLbx,aVar),)) PIXEL
		DEFINE SBUTTON FROM aObj5Size[1,4]-60,aObj5Size[1,2]+40 TYPE 11 ENABLE OF oFolder:aDialogs[5] ACTION (lIncLbx := .F., aVar:=A010ListBox(oLbx:nAt,2),IIF(!Empty(aVar),A010Acres(oLbx:nAt,oLbx,aVar),)) PIXEL
		DEFINE SBUTTON FROM aObj5Size[1,4]-60,aObj5Size[1,2]+75 TYPE 3  ENABLE OF oFolder:aDialogs[5] ACTION (lIncLbx := .F., aVar:=A010ListBox(oLbx:nAt,3),IIF(!Empty(aVar),A010Acres(oLbx:nAt,oLbx,aVar),)) PIXEL
	Else		// Visualizacao e Exclusao
		DEFINE SBUTTON FROM aObj5Size[1,4]-60,aObj5Size[1,2]+5  TYPE  4 OF oFolder:aDialogs[5] PIXEL
		DEFINE SBUTTON FROM aObj5Size[1,4]-60,aObj5Size[1,2]+40 TYPE 11 OF oFolder:aDialogs[5] PIXEL
		DEFINE SBUTTON FROM aObj5Size[1,4]-60,aObj5Size[1,2]+75 TYPE  3 OF oFolder:aDialogs[5] PIXEL
	EndIf


	//--Botaão para poder parar na Enchoice
	fBotao(oFolder)

	aHeader 	:= aClone(aSvGetD[1][1])
	aCols		:= aClone(aSvGetD[1][2])
	n			:= aSvGetD[1][3]

	@ aObj4Size[3,1], aObj4Size[3,2] TO aObj4Size[3,3]-72, aObj4Size[3,4]-15	LABEL "" OF oFolder:aDialogs[5] PIXEL
	oGet04		:= MSGetDados():New(aObj6Size[1,1],aObj6Size[1,2],aObj6Size[1,3]-85,aObj6Size[1,4]-15,nOpcao,"A010LinOk","A010TudOk","QR_TESTE",lGetD,,1 , , ,'Rsp010ValCpo(nOpcao,lIncLbx)',,,,oFolder:aDialogs[5])

	oGet04:oBrowse:lDisablePaint := .T.

	oGet04:oBrowse:bValid := {|| A010AtuGD(oLbx:nAt,2,oFolder:nOption) }	// funcao a ser executada qdo. o browse perder o foco.

	@ aObj6Size[1,3]-85, aObj6Size[1,2] SAY oF4 PROMPT cF4 SIZE 70,7 OF oFolder:aDialogs[5] FONT oFont1 COLOR CLR_HRED	PIXEL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder 04 								  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aObj3Size[1,1], aObj3Size[1,2] SAY oSay01 PROMPT STR0019 SIZE 20,8 OF oFolder:aDialogs[4] PIXEL//"Grupo:"
	@ aObj3Size[1,1], aObj3Size[1,2]+25 MSGET oGrupo;
			VAR cGrupo;
			OF oFolder:aDialogs[4];
			F3 "SQ0";
			WHEN (nOpcao==3 .Or. nOpcao==4 );
			VALID R010Grupo(oDesc,cGrupo,@cDescGrupo,oFolder:nOption);
			SIZE 20,8 PIXEL HASBUTTON

	@ aObj3Size[1,1], aObj3Size[1,2]+60 MSGET oDesc VAR cDescGrupo WHEN .F. SIZE 150,8 OF oFolder:aDialogs[4] PIXEL

	@ aObj3Size[1,1], aObj3Size[1,2]+220 BUTTON  STR0020 SIZE 45,11 OF oFolder:aDialogs[4]; //"Pesquisar"
			ACTION A010Pesq(oFolder:nOption);
			WHEN (nOpcao==3 .Or. nOpcao==4 ) PIXEL

	If nOpcao == 2 .or. nOpcao == 5	 // Na Visualizacao nao estava parando no Folder
		@ 10,10 MSGET cParada WHEN .T.
	EndIf

	aHeader	:= {}
	aCols   := {}
	aListPast[4]:=	RSP010Fill(4,nOpcx)
	aHeader := aClone(aListPast[4][1])
	aCols	:= aClone(aListPast[4][2])
	n		:= 1
	oGet03  := MSGetDados():New(aObj3Size[2,1],aObj3Size[2,2],aObj3Size[2,3]-75,aObj3Size[2,4]-15,nOpcao,"A010LinOk","A010TudOk",,lGetD,,1,,,,,,,oFolder:aDialogs[4])
	oGet03:oBrowse:lDisablePaint := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configura‡Æo da GetDados - Folder 03				 ³
	//³ *** Cursos do Curriculo                  			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader	:= {}
	aCols   := {}
	aListPast[3]:=	RSP010Fill(3,nOpcx)
	aHeader := aClone(aListPast[3][1])
	aCols	:= aClone(aListPast[3][2])
	n		:= 1
	oGet02	:= MSGetDados():New(aObj2Size[1,1],aObj2Size[1,2],aObj2Size[1,3]-72,aObj2Size[1,4]-15,nOpcao,"A010LinOk","A010TudOk",,lGetD,,1,,,,,,,oFolder:aDialogs[3])
	oGet02:oBrowse:lDisablePaint := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configura‡Æo da GetDados - Folder 02				 ³
	//³ *** Historico Profissional               			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := {}
	aCols   := {}

	aListPast[2]:=	RSP010Fill(2,nOpcx)
	aHeader := aClone(aListPast[2][1])
	aCols	:= aClone(aListPast[2][2])
	n		:= 1
	oGet01 	:= MSGetDados():New(aObj2Size[1,1],aObj2Size[1,2],aObj2Size[1,3]-72,aObj2Size[1,4]-15,nOpcao,"A010LinOk","A010TudOk",,lGetD,,1,,,,,,,oFolder:aDialogs[2])
	oGet01:oBrowse:lDisablePaint := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder 01								  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Zero()

	MsMGet():New("SQG",nReg,nOpcao,,,,,{aObj1Size[1,1],aObj1Size[1,2], aObj1Size[1,3]-72,aObj1Size[1,4]-15},,,,,,oFolder:aDialogs[1],,,lOneColumn)

		bSet15 := {|| lOk:=.T.,RspA010ValPE() .And. If(oGet04:TudoOk() .And. Iif(nOpcx == 3 .Or. nOpcx == 4, Obrigatorio(aGets,aTela),.T.),(oGet04:oBrowse:lDisablePaint:=.T.,nGrava:=1,nOpcFolder:=oFolder:nOption,nOpcLbx:=oLbx:nAt,oDlgFolder:End()),.F.)}
 		bSet24 := {|| nGrava:= 0,oDlgFolder:End()}
	ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder,bSet15,bSet24,, aButtons ) CENTERED

	SETAPILHA()
EndIf
// Grava os dados dos curriculos
If nGrava == 1
	cGrupo := M->QG_GRUPO	//Atualizar variavel cGrupo para Gravacao
	Begin Transaction
		A010Grava(nOpcFolder,nOpcLbx)
	End Transaction

	If SuperGetMV( "MV_MDTGPE" , .F. , "N" ) == "S" .And. nOpcx == 3 .And. FindFunction("MDTW030")
		MDTW030( "SQG" , M->QG_CIC ) //Executa o W.F. de Aviso do SESMT
	EndIf
ElseIf lExecAuto
	Begin Transaction
		A010Grava()
	End Transaction
EndIf

//****************************************************************************************************************
//Ponto de Entrada para Gravacao.
//****************************************************************************************************************
if ExistBlock("RSP010Grv")
	dbSelectArea("SQG")
	ExecBlock("RSP010Grv",.F.,.F., {nGrava, nOpcx})
endif

If nOpcx == 3 .And. __lSX8
	If nGrava ==1
		ConfirmSX8()
	ElseIf nGrava == 0
		RollBackSX8()
	EndIf
EndIf

Set Key VK_F4 To

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura Arquivos							   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aSaveArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RSP010Exc³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 07/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para Exclusao de curriculos em Grupo.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RSP010Exc(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao Selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RSP010Exc(cAlias1,nReg,nOpcx)

Local aSaveArea	:= GetArea()
Local aSays		:= {}
Local aButtons	:= {}
Local nOpca 	:= 0

Private aFilterExp	:= {}
Private aRetFiltro	:= {}
Private cCadastro 	:= OemToAnsi(STR0043)		//"Processo de Exclusao de Curriculos em Grupo"
Private nSavRec		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("RSP010",.F.)

/* Retorne os Filtros que contenham os Alias Abaixo */
aAdd( aFilterExp , { "FILTRO_ALS" , "SQG"     	, NIL , NIL } )
/* Que Estejam Definidos para a Função */
aAdd( aFilterExp , { "FILTRO_PRG" , FunName() 	, NIL , NIL    } )

AADD(aSays,OemToAnsi(STR0044) )             // "Este programa tem como objetivo a Exclusao de Grupos de Curriculos"
AADD(aSays,OemToAnsi(STR0045) )             // "de acordo com parametros informados pelo usuario."

AADD(aSays,"")
AADD(aSays,"* " +OemToAnsi(STR0078) +" *")  // "Atencao"
AADD(aSays,OemToAnsi(STR0079))              // "Essa funcionalidade de exclusao em grupo, elimina automaticamente todos"
AADD(aSays,OemToAnsi(STR0080))              // "os curriculos selecionados, alem de todo historico de relacionamento com"
AADD(aSays,OemToAnsi(STR0081))              // "agendas e avaliacoes ja realizadas, em qualquer processo seletivo!"

AADD(aButtons, { 17,.T.,{|| aRetFiltro := FilterBuildExpr( aFilterExp ) } } )
AADD(aButtons, { 5,.T.,{|| Pergunte("RSP010",.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(gpconfOK(),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == 1
	Processa({|lEnd| RSP010Proc(),STR0043}) //"Processo de Exclusao de Curriculos em Grupo"

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura Arquivos                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aSaveArea)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RSP010Proc³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 07/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento de Exclusao de Curriculos em Grupo.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RSP010PROC()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPAM010		                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rsp010Proc()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando as Perguntas 									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cCurDe 		:= mv_par01		// Curriculo De
Local cCurAte		:= mv_par02		// Curriculo Ate
Local cSitDe		:= mv_par03		// Situacao De
Local cSitAte		:= mv_par04		// Situacao Ate
Local dDataDe		:= mv_par05 	// Dt.Cadastro De
Local dDataAte		:= mv_par06		// Dt.Cadastro Ate

Local cCurric		:= ""
Local cSqgFilter	:= ""

dbSelectArea("SQG")
dbSetOrder(1)
dbSeek(xFilial("SQG")+cCurDe,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os Filtros                                 	 	     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSqgFilter	:= GpFltAlsGet( aRetFiltro , "SQG" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Regua Processamento	                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua(SQG->(RecCount()))

While ! Eof() .And. SQG->QG_CURRIC >= cCurDe .And. SQG->QG_CURRIC <= cCurAte

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Move Regua Processamento	                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    IncProc(STR0046)		//"Excluindo Curriculos"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste os Parametros 										 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If 	SQG->QG_SITUAC 	< cSitDe	.Or. SQG->QG_SITUAC	> cSitAte	.Or.;
		SQG->QG_DTCAD 	< dDataDe	.Or. SQG->QG_DTCAD		> dDataAte

		dbSelectArea("SQG")
		dbSkip()
		Loop
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aplicacao do filtro na tabela SQG.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( cSqgFilter )
 		If !( &( cSqgFilter ) )
			dbSelectArea("SQG")
			dbSkip()
			Loop
 		EndIf
 	EndIf

    cCurric := SQG->QG_CURRIC

    // Cursos Candidato
    dbSelectArea("SQM")
    dbSetOrder(1)
    dbSeek(xFilial("SQM")+cCurric)
    While !Eof() .And. cCurric == SQM->QM_CURRIC
	    RecLock("SQM",.F.)
	    	dbDelete()
	    MsUnlock()
    	dbSkip()
    EndDo

    // Historico Profissional
    dbSelectArea("SQL")
    dbSetOrder(1)
    dbSeek(xFilial("SQL")+cCurric)
    While !Eof() .And. cCurric == SQL->QL_CURRIC

   		MSMM(QL_ATIVIDA,,,,2,,,,,"RDY")

   		dbSelectArea("SQL")
	    RecLock("SQL",.F.)
	    	dbDelete()
	    MsUnlock()

    	dbSkip()
    EndDo

	// Qualificacoes (Fatores Avaliacao)
    dbSelectArea("SQI")
    dbSetOrder(1)
    dbSeek(xFilial("SQI")+cCurric)
	While !Eof() .And. cCurric == SQI->QI_CURRIC
	    RecLock("SQI",.F.)
	    	dbDelete()
	    MsUnlock()
    	dbSkip()
    EndDo

	// Agenda de Candidatos
    dbSelectArea("SQD")
    dbSetOrder(2)
    dbSeek(xFilial("SQD")+cCurric)
	While !Eof() .And. cCurric == SQD->QD_CURRIC
	    RecLock("SQD",.F.)
	    	dbDelete()
	    MsUnlock()
    	dbSkip()
    EndDo

	// Avaliacoes
    dbSelectArea("SQR")
    dbSetOrder(1)
    dbSeek(xFilial("SQR")+cCurric)
	While !Eof() .And. cCurric == SQD->QD_CURRIC

		MSMM(QR_MRESPOS,,,,2,,,,,"RDY")

	    RecLock("SQR",.F.)
	    	dbDelete()
	    MsUnlock()
    	dbSkip()
    EndDo

    //Candidatos
   	dbSelectArea("SQG")
   	MSMM(QG_ANALISE,,,,2,,,,,"RDY")
	MSMM(QG_EXPER,,,,2,,,,,"RDY")

	dbSelectArea("SQG")
    RecLock("SQG",.F.)
    	dbDelete()
    MsUnlock()

	dbSkip()
EndDo

dbSelectArea("SQG")
dbSetOrder(1)
dbGoTop()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010Muda ³ Autor ³ Cristina Ogura        ³ Data ³ 14.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Checa a mudanca do Folder                 	  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³	A010Muda(ExpN1,ExpN2,ExpO1)                  	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³	ExpN1 = Folder indo                     				  ³±±
±±³			 ³ ExpN2 = Folder estou                     			 	  ³±±
±±³			 ³ ExpO1 = Nome do objeto                   				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A010Muda(nIndo,nEstou,oNome)
Local lRetChg   := .T.
Local nx		:= 0
Local nI		:= 0
Local nPosEmp	:= 0
Local nPosCurso := 0
Local nPosCurFun:= 0
Local nPosFator	:= 0
Local nPosGrau	:= 0

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Salva Ambiente do Folder Atual 								  ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nEstou == 1 )
	If nOpcao != 2 .And. nOpcao != 5
		lRetChg 	:= Obrigatorio(aGets,aTela)
	EndIf
	cNome		:= OemtoAnsi(STR0021)+M->QG_CURRIC+"     "+OemtoAnsi(STR0022)+M->QG_NOME //"Codigo: "###"Nome: "
	cGrupo		:= M->QG_GRUPO
	oNome:Refresh()

ElseIf ( nEstou == 2 )   	//Historico Profissional
	If n > 1 .And. nOpcao # 2 .And. nOpcao # 5
		nPosEmp	:= GdFieldPos("QL_EMPRESA")
		If 	nPosEmp > 0 .And. Empty(aCols[n][nPosEmp]) .And.;
			!aCols[n][Len(aCols[n])]
			Help(" ",1,"A010VZ2")
			Return .F.
		EndIf
	EndIf
	aListPast[2][1] := AClone(aHeader)
	aListPast[2][2] := AClone(aCols)
	aListPast[2][3] := 1
	oGet01:oBrowse:lDisablePaint := .T.

ElseIf ( nEstou == 3 ) // Cursos / Escolaridade
	If n > 1 .And. nOpcao # 2 .And. nOpcao # 5
		nPosCurso := GdFieldPos("QM_CURSO")
		nPosCurFun 	:= GdFieldPos("QM_CDCURSO")
		If nPosCurso > 0 .And. Empty(aCols[n][nPosCurso]) .And.;
			(Empty(aCols[n][nPosCurFun])) .And.;
			!aCols[n][Len(aCols[n])]
			Help(" ",1,"A010VZ3")
			Return .F.
		EndIf
	EndIf
	aListPast[3][1] := AClone(aHeader)
	aListPast[3][2] := AClone(aCols)
	aListPast[3][3] := 1
	oGet02:oBrowse:lDisablePaint := .T.

ElseIf ( nEstou == 4 )    //Qualificacoes do Curriculo
	If n > 1 .And. nOpcao # 2 .And. nOpcao # 5
		nPosFator	:= GdFieldPos("QI_FATOR")
		nPosGrau	:= GdFieldPos("QI_GRAU")
		If(	(nPosFator 	> 0 .And. Empty(aCols[n][nPosFator])) .Or.;
			(nPosGrau 	> 0 .And. Empty(aCols[n][nPosGrau])) ) .And.;
			!aCols[n][Len(aCols[n])]
			Help(" ",1,"A010VZ4")
			Return .F.
		EndIf
	EndIf
	aListPast[4][1] := AClone(aHeader)
	aListPast[4][2] := AClone(aCols)
	aListPast[4][3] := 1
	oGet03:oBrowse:lDisablePaint := .T.

ElseIf ( nEstou == 5 ) // Avaliacao do Curriculo
	For nx := 1 To Len(aSvGetD)
		If aLbx[oLbx:nAt][1] == aSvGetD[nx][4][1][1] .And.;
			aLbx[oLbx:nAt][3] == aSvGetD[nx][4][1][2] .And.;
			aLbx[oLbx:nAt][7] == aSvGetD[nx][4][1][3] .And.;
			aLbx[oLbx:nAt][8] == aSvGetD[nx][4][1][4]

			aSvGetD[nx][1] := aClone(aHeader)
			aSvGetD[nx][2] := aClone(aCols)
			aSvGetD[nx][3] := 1
			Exit
		EndIf
	Next nx
	oGet04:oBrowse:lDisablePaint := .T.

EndIf

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Restaura Configuracoes do Folder Selecionado					  ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nIndo == 2 ) .And. ( lRetChg )     // Historico Profissional
	aHeader 	:= aClone(aListPast[2][1])
	aCols		:= aClone(aListPast[2][2])
	n			:= 1
	oGet01:oBrowse:lDisablePaint := .F.
	oGet01:oBrowse:Refresh(.T.)

ElseIf ( nIndo == 3 ) .And. ( lRetChg ) //Cursos / Escolaridade
	aHeader 	:= aClone(aListPast[3][1])
	aCols		:= aClone(aListPast[3][2])
	n			:= 1
	oGet02:oBrowse:lDisablePaint := .F.
	oGet02:oBrowse:Refresh(.T.)

ElseIf ( nIndo == 4 ) .And. ( lRetChg )  // Qualificacoes do Curriculo
	aHeader 	:= aClone(aListPast[4][1])
	aCols		:= aClone(aListPast[4][2])
	n			:= 1
	oGet03:oBrowse:lDisablePaint := .F.
	oGet03:oBrowse:Refresh(.T.)

ElseIf ( nIndo == 5 ) .And. ( lRetChg )
	aHeader	:={}
	aCols	:={}
	If Len(aSvGetD) ==1 .And. Empty(aSvGetD[1][2][1][1])
		nx := oLbx:nat
		aHeader 	:= aClone(aSvGetD[nx][1])
		aCols		:= aClone(aSvGetD[nx][2])
		n			:= 1
	Else
		For nx := 1 To Len(aSvGetD)
			If aLbx[oLbx:nAt][1] == aSvGetD[nx][4][1][1] .And.;
				aLbx[oLbx:nAt][3] == aSvGetD[nx][4][1][2] .And.;
				aLbx[oLbx:nAt][7] == aSvGetD[nx][4][1][3].And.;
				aLbx[oLbx:nAt][8] == aSvGetD[nx][4][1][4]

				cVarTopico	:= aLbx[oLbx:nAt][3]
				aHeader 	:= AClone(aSvGetD[nx][1])
				aCols		:= AClone(aSvGetD[nx][2])
				n			:= 1
				Exit
			EndIf
		Next nx
		nI += 1
	EndIf
	oGet04:oBrowse:lDisablePaint := .F.
	oGet04:oBrowse:Refresh(.T.)
	//-- carregar a get dados conteudo correto - na 1o. aparecia conteudo da Ultima
	oGet04:oBrowse:Reset()

EndIf

Return(lRetChg)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010Grava³ Autor ³ Cristina Ogura        ³ Data ³ 14.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza os arquivos SQG, SQL, SQM, SQR, SQI	e SM6		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³	A010Grava()						                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A010Grava(nOpcFolder,nOpcLbx)

Local nI			:= 0
Local cCurric   	:= ""
Local aTempo		:= {}
Local nTam  		:= 0
Local nLinha		:= 0
Local nPontos		:= 0
Local cTeste		:= ""
Local nx			:= 0
Local nPosCurso		:= 1
Local lChkDelOk		:= .F.
Local cInicial		:= "001"

If ( nOpcao == 2 )     // Visual
	Return(.T.)
EndIf

If !lExecAuto
	If ( nOpcFolder == 2 )
	aListPast[2][1] := aClone(aHeader)
	aListPast[2][2] := aClone(aCols)
	aListPast[2][3] := 1
ElseIf ( nOpcFolder == 3 )
	aListPast[3][1] := aClone(aHeader)
	aListPast[3][2] := aClone(aCols)
	aListPast[3][3] := 1
	nPosCurso		 := GdFieldPos("QM_CURSO")
ElseIf ( nOpcFolder == 4 )
	aListPast[4][1] := aClone(aHeader)
	aListPast[4][2] := aClone(aCols)
	aListPast[4][3] := 1
EndIf
/*
ElseIf ( nOpcFolder == 5 )
O folder '5' ( aSvGetD[nx][1] := aClone(aHeader) ) está sendo tratado na rotina A010AtuSQR.
O Array deve ser enviado por completo. Pode ocorrer cadastro com ordem invertida. */
	aTempo:= A010Tempo()

	//Atualizar dados do Curriculo - SQG
	dbSelectArea("SQG")
	dbSetOrder(1)
	dbSeek(xFilial("SQG")+M->QG_CURRIC)
EndIf
If nOpcao # 5	//#Diferente de Exclusao

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Nota do Teste no Curriculo. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lExecAuto .AND. (nOpcao == 3 .Or. nOpcao == 4)
		cTeste	:= ""
		nTam	:= Len(aLbx)
		For nx := nTam To 1 Step -1
			If aLbx[nx][6] == "Ativo"
				cTeste 	:= aLbx[nx][1]
				Exit
			EndIf
		Next nx

		nPontos := 0
		For nx := 1 To nTam
			If cTeste == aLbx[nx][1] .And. aLbx[nx][6] == "Ativo"
				nPontos += Val(aLbx[nx][5])
			EndIf
		Next nx
		M->QG_NOTA	:= nPontos
	EndIf

	If !lExecAuto
		RecLock("SQG",IIf(Found(), .F., .T.))
	Else
		If nOpcao == 4 //alteracao
			SQG->(dbSetOrder(aRotAuto[1,2]))
			If SQG->(dbSeek(aRotAuto[1,3]))
				RecLock("SQG",.F.)
			Else
				lMsErroAuto := .T.
				Help( ,,"ExecAuto",, OemToAnsi(STR0095), 1, 0 )
				Return
			EndIf
		Else //inclusao
			If !SQG->(dbSeek(aRotAuto[1,3]))
				RecLock("SQG",.T.)
			Else
				lMsErroAuto := .T.
				Help( ,,"ExecAuto",, OemToAnsi(STR0096), 1, 0 )
				Return
			EndIf
		EndIf
	EndIf
	For nI := 1 To FCount()
		If ( FieldName(nI) == "QG_FILIAL" )
			FieldPut(nI, xFilial("SQG"))
		Else
			If !lExecAuto
				FieldPut(nI, M->&(FieldName(nI)))
			ElseIf (nPos := aScan(aRotAuto[1,4],{|x| x[1] == FieldName(nI)})) > 0
				FieldPut(nI, aRotAuto[1,4,nPos,2])
			EndIf
		EndIf
	Next nI

	If Empty(SQG->QG_SITUAC)
		SQG->QG_SITUAC := cInicial
	EndIf
	If !lExecAuto
		Replace QG_GRUPO	With cGrupo
		Replace	QG_TPTRAB	With aTempo[1]
		Replace	QG_TPEXPER	With aTempo[2]
	EndIf
	MsUnlock()

	If IsMemVar("QG_MEMO1")
		MSMM(M->QG_ANALISE,,,M->QG_MEMO1,1,,,"SQG","QG_ANALISE","RDY")
	EndIf
	If IsMemVar("QG_MEMO2")
		MSMM(M->QG_EXPER  ,,,M->QG_MEMO2,1,,,"SQG","QG_EXPER","RDY")
	EndIf
	cCurric := If(!lExecAuto,M->QG_CURRIC,SQG->QG_CURRIC)
Else
	cCurric := If(!lExecAuto,M->QG_CURRIC,SQG->QG_CURRIC)
	MSMM(QG_ANALISE,,,,2,,,,,"RDY")
	MSMM(QG_EXPER,,,,2,,,,,"RDY")
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Checa o relacionamento da Tabela Pai (SQG) c/ as tabelas-filhas (SQM-SQL-SQI-SQD-SQR) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	If !lExecAuto
	   	lChkDelOk  := ChkDelRegs(	"SQG"				,;	//01 -> Alias do Arquivo Principal
									NIL					,;	//02 -> Registro do Arquivo Principal
									NIL					,;	//03 -> Opcao para a AxDeleta
									NIL					,;	//04 -> Filial do Arquivo principal para Delecao
									NIL					,;	//05 -> Chave do Arquivo Principal para Delecao
									NIL					,;	//06 -> Array contendo informacoes dos arquivos a serem pesquisados
									Nil					,;	//07 -> Mensagem para MsgYesNo
									NIL					,;	//08 -> Titulo do Log de Delecao
									NIL					,;	//09 -> Mensagem para o corpo do Log
									NIL				 	,;	//10 -> Se executa AxDeleta
									NIL					,;	//11 -> Se deve Mostrar o Log
									NIL					,;	//12 -> Array com o Log de Exclusao
									NIL		 			,;	//13 -> Array com o Titulo do Log
									NIL					,;	//14 -> Bloco para Posicionamento no Arquivo
									NIL					,;	//15 -> Bloco para a Condicao While
									NIL					,;	//16 -> Bloco para Skip/Loop no While
									.T.					,;	//17 -> Verifica os Relacionamentos no SX9
									{}				 	;	//18 -> Alias que nao deverao ser Verificados no SX9
						    	)
		If !lChkDelOk
			Return Nil
		Endif
	EndIf
 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui Curriculo do Candidato ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("SQG",.F.)
		DbDelete()
		WriteSx2("SQG")
	MsUnlock()
EndIf

If lExecAuto .AND. nOpcao <> 5
	cGrupo := ''
	aCols	:={}
	aHeader	:={}
	aListPast[2] := RSP010Fill(2,nOpcao) //SQL
	aCols	:={}
	aHeader	:={}
	aListPast[3] := RSP010Fill(3,nOpcao) //SQM
	aCols	:={}
	aHeader	:={}
	aListPast[4] := RSP010Fill(4,nOpcao) //SQI
	aCols	:={}
	aHeader	:={}
	aListPast[5] := RSP010Fill(5,nOpcao) //SQR
	For nX := 2 to 5
		If Len(aRotAuto[nX,2]) > 1
			For nLinha := 2 to Len(aRotAuto[nX,2])
				aAdd(aListPast[nX,2],aClone(aListPast[nX,2,1]))
			Next nLinha
		EndIf
		For nLinha := 1 to Len(aRotAuto[nX,2])
			For nI := 1 to Len(aListPast[nX,1])
				If (nPos := aScan(aRotAuto[nX,1,1],{|x| AllTrim(x) == AllTrim(aListPast[nX,1,nI,2])})) > 0
					aListPast[nX,2,nLinha,nI] := aRotAuto[nX,2,nLinha,nPos]
				EndIf
			Next nI
		Next nLinha
		If nX == 4 .AND. (nPos := aScan(aRotAuto[nX,1,1],{|x| AllTrim(x) == "QI_GRUPO"})) > 0
			cGrupo := aRotAuto[nX,2,1,nPos]
		EndIf
	Next nX
	A010SQR(nOpcao)
	A010SM6(nOpcao) //SM6
EndIf

//Atualizar dados do Historico - SQL
A010Atu("SQL",cCurric,2)

//Atualizar dados do Curso - SQM
A010Atu("SQM",cCurric,3,nPosCurso)

//Atualizar dados da Qualificacao - SQI
A010Atu("SQI",cCurric,4)

//Atualizar dados da Avaliacao - SQR
A010AtuSQR(cCurric)

//Atualizar dados do Perfil - SM6
A010AtuSM6()

IF ChkFile("RI3") .AND. RetOrder( "RI3", "RI3_FILIAL+RI3_USER" ) > 0
	//Atualizar dados do Aceite - RI3
	A010AtuRI3(cCurric)
ENDIF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010Atu  ³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza os dados conforme parametros		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010Atu(ExpC1,ExpC2,ExpN1)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                  				  ³±±
±±³			 ³ ExpC2 = Codigo do curriculo                				  ³±±
±±³			 ³ ExpO1 = Numero do folder                   				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A010Atu(cAlias,cCurric,nFolder,nPosChave)

Local cVar		:= ""
Local nPosRec	:= 0
Local lNDel		:= .F.
Local cFiltro	:= ""
Local lFound	:= .T.
Local cNomeFil 	:= ""
Local cNomeCur	:= ""
Local nI		:= 0
Local nx		:= 0
Local ny		:= 0
Local nPosCod	:= 0
Local nPosAdmSQL:= 0
Local nPosCurSQM:= 0

Default nPosChave := 1
If !(lExecAuto .AND. nOpcao == 5) //se for ExecAuto e exclusao nao entra
	aHeader:={}
	aCols  :={}

	aHeader:= aClone(aListPast[nFolder][1])
	aCols  := aClone(aListPast[nFolder][2])
	nPosCod:= If( cAlias=="SQI", GdFieldPos("QI_FATOR"),0)

	nPosRec :=	GdfieldPos(right(cAlias,2) +"_REC_WT")
EndIf

cFiltro:= Substr(cAlias,2,2)+"_FILIAL + "+Substr(cAlias,2,2)+"_CURRIC"

If nOpcao == 3	.or. nOpcao == 4									// Inclusao   ou Alteracao

	dbSelectArea(cAlias)
	For nx:=1 to Len(aCols)
		If ( !aCols[nx][Len(aCols[nx])] .and. cAlias $ "SQM_SQL" )
			If ( cAlias == "SQM" )
				nPosCurSQM := GdFieldPos("QM_CURSO", aHeader)
				If Empty(aCols[nx,nPosCurSQM])
					nx := Len(aCols)
					Exit
				EndIf
			ElseIf ( cAlias == "SQL" )
				nPosAdmSQL := GdFieldPos("QL_DTADMIS", aHeader)
				If Empty(aCols[nx,nPosAdmSql])
					nx := Len(aCols)
					Exit
				EndIf
			EndIf
		EndIf
		Begin Transaction
			lTravou:= .F.
			If nPosRec > 0 .AND. aCols[nx][nPosRec]> 0
				MsGoto(aCols[nx][nPosRec])
				RecLock(cAlias,.F.,.T.)
				lTravou:=.T.
			Else
				//--Verifica se Nao esta Deletado no aCols e Nao esta vazio o codigo do fator caso(para gravacao na tabela SQI)
				If !aCols[nx][Len(aCols[nx])] .And.  If(cAlias == "SQI",!Empty(aCols[nx][nPosCod]),.T.)
					RecLock(cAlias,.T.,.T.)
					lTravou:=.T.
				EndIf
			EndIf
			If lTravou
				//--Verifica se esta deletado
				If aCols[nx][Len(aCols[nx])]
					If cAlias == "SQL"
						MSMM(QL_ATIVIDA,,,,2,"RDY")
					EndIf
					dbDelete()
				Else
					cNomeFil := Substr(cAlias,2,2) + "_FILIAL"
					cNomeCur := Substr(cAlias,2,2) + "_CURRIC"
					Replace &cNomeFil With xFilial("SQR")
					Replace &cNomeCur With cCurric
				EndIf

				For ny := 1 To Len(aHeader)
					If aHeader[ny][10] # "V"
						(cAlias)->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
					ElseIf aHeader[ny][8] == "M"	// Campo Memo
						MsUnlock()
						If cAlias == "SQL"
							MSMM(QL_ATIVIDA,,,aCols[nx][ny],1,,,"SQL","QL_ATIVIDA","RDY")
						EndIf
						RecLock(cAlias,.F.)

				    EndIf
				Next ny

				If cAlias == "SQI"
					Replace QI_GRUPO 	With cGrupo
				EndIf

				lTravou := .F.
				MsUnlock()
			EndIf
		End	 Transaction
	Next nx

ElseIf nOpcao == 5 	// Exclusao
	dbSelectArea(cAlias)
	dbSetOrder(1)
	dbSeek(xFilial(cAlias)+cCurric)
	While !Eof() .And. cFilial+cCurric == &cFiltro
		If cAlias == "SQL"
			MSMM(QL_ATIVIDA,,,,2,,,,,"RDY")
		EndIf
		RecLock(cAlias,.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	End
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010AtuSQR³ Autor ³ Cristina Ogura       ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza dados do arquivo de avaliacao (SQR)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010AtuSQR(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³	ExpC1 = Codigo do curriculo               				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010AtuSQR(cCurric)
Local nPosQuestao	:= 0
Local nPosAlterna	:= 0
Local nPosResulta	:= 0
Local lFound		:= .T.
Local cVar			:= ""
Local nPosTeste 	:= 0
Local aRecnos 		:= {}
Local nRecno  		:= 0
Local nt			:= 0
Local nx			:= 0
Local ny			:= 0

Local nPosVaga	:= 0
Local nPosData	:= 0
Local lLocaliza	:=	.F.
Local nTemp	:=	0
Local nLen		:=	0
Local cFilSQR	:=	xFilial("SQR")
Local cChave	:=	""
Local lEof	:=	.F.
If !(lExecAuto .AND. nOpcao == 5) //se for ExecAuto e exclusao nao entra
	aHeader		:= {}
	aHeader		:= aClone(aSvGetD[1][1])
	nPosQuestao := GdFieldPos("QR_QUESTAO")
	nPosAlterna := GdFieldPos("QR_ALTERNA")
	nPosResulta := GdFieldPos("QR_RESULTA")
	nPosTeste 	:= GdFieldPos("QR_TESTE")
	nPosVaga	:= GdFieldPos("QR_VAGA")
	nPosData	:= GdFieldPos("QR_DATA")
EndIf

dbSelectArea("SQR")
dbSetOrder(1)
dbSeek(cFilSQR+cCurric)
If nOpcao == 5				// exclusao
	While !Eof() .And. cFilSQR+cCurric == SQR->QR_FILIAL+SQR->QR_CURRIC
		MSMM(QR_MRESPOS,,,,2)
		RecLock("SQR",.F.,.T.)
		dbDelete()
		MsUnlock()
		dbSkip()
	EndDo
Else

	If	!Found()				// inclusao
		If !Empty(aLbx[1][1])

			For ny := 1 To Len(aLbx)
				aCols		:={}
				nLen	:=	LEN( aLbX )
				nTemp	:=	0
				lLocaliza	:=	.F.
				Do While !( lLocaliza ) .AND. ( ++nTemp <= nLen )
					If (aLbx[nY][1] == aSvGetD[nTemp][2][1][1])
						lLocaliza	:=	.T.
					EndIf
				EndDo
				aCols		:= aClone(aSvGetD[nTemp][2])
				For nx := 1 To Len(aCols)
					//--Verifica se Nao e Deletado
					If !aCols[nx][Len(aCols[nx])]
						RecLock("SQR",.T.)
						Replace QR_FILIAL		With xFilial("SQR")
						Replace QR_CURRIC 		With cCurric
						Replace QR_TESTE		With aLbx[ny][1]
						Replace QR_TOPICO		With aLbx[ny][3]
						If Empty(aCols[nx][nPosQuestao])
							Replace QR_RESULTA 	With Val(aLbx[ny][5])
						Else
							Replace QR_RESULTA 	With aCols[nx][nPosResulta]
						EndIf
						For nt := 1 to Len(aHeader)
							If aHeader[nt][10] # "V"
								cVar := Trim(aHeader[nt][2])
								Replace &cVar With aCols[nx][nt]
							EndIf
							If aHeader[nt][8] == "M"	// Campo Memo
								MsUnlock()
								MSMM(QR_MRESPOS,,,aCols[nx][nt],1,,,"SQR","QR_MRESPOS")
								RecLock("SQR",.F.)
							EndIf
						Next nt
					EndIf
				Next nx
			Next ny
		EndIf

	Else								// alteracao
		//-- Grava os Testes do Candidato - Para cada teste um acols

		For ny := 1 To Len(aLbx)
			//--Verifica se Teste+Topico esta ativo - Grava
			If aLbx[ny][6] == "Ativo"

				aCols		:={}
				nTemp	:=	0
				nLen	:=	LEN( aLbX )
				lLocaliza	:=	.F.
				Do While !( lLocaliza ) .AND. ( ++nTemp <= nLen )

					If (aLbx[nY][1] == aSvGetD[nTemp][2][1][1] .And. aLbx[nY][7] == aSvGetD[nTemp][2][1][8])
						lLocaliza	:=	.T.
					EndIf

				EndDo

				aCols := aClone(aSvGetD[nTemp][2])

				dbGoTop()
				cChave	:= cFilSQR + cCurric + aLbx[nY,1] + aLbX[nY,3] //QR_TESTE+QR_TOPICO

				SQR->( dbSeek(cChave) )
				lEof	:=	.F.
				Do While !( lEof )

					lFound	:=	( aLbx[nY,1] + aLbX[nY,3] + aLbx[nY,7] + aLbx[nY,8] == QR_TESTE+QR_TOPICO+QR_VAGA+Dtoc(QR_DATA) )
					If !(lFound)
						SQR->( dbSkip() )
					EndIf
					lEof	:=	(lFound) .OR. !(aLbx[nY,1] + aLbX[nY,3] == QR_TESTE+QR_TOPICO) .OR. (SQR->(EOF()) )

				EndDo

				If ( lFound )
					RecLock("SQR",.F.)
					SQR->( dbDelete() )
		    		SQR->( MsUnlock() )
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se existir o recno entao nao adciona registro, alterando conteudo do registro. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                aRecnos := {}
				If dbSeek(cFilSQR+cCurric+aLbx[ny][1]+aLbx[ny][3])
					Do While !Eof() .And. (cFilSQR+cCurric+aLbx[ny][1]+aLbx[ny][3]) == ;
											(QR_FILIAL+QR_CURRIC+QR_TESTE+QR_TOPICO)

						If ( aLbx[ny][7] == QR_VAGA .And. aLbx[ny][8] == Dtoc(QR_DATA) )
							aAdd(aRecnos, Recno())
						EndIf
						dbSkip()
					EndDo
				EndIf

				dbGoTop()
				dbSeek(cFilial+cCurric)
		    	While !Eof() .And. cFilial+cCurric == QR_FILIAL+QR_CURRIC
		    		If (nPos:= aScan(aLbx,{|x|x[1]+x[3]+x[7]+x[8] == QR_TESTE+QR_TOPICO+QR_VAGA+Dtoc(QR_DATA) })) = 0
		    			RecLock("SQR",.F.)
							dbDelete()
		    			MsUnlock()
		    	    Endif
		    	    dbSkip()
		    	 EndDo

				For nx := 1 To Len(aCols)
					lFound := .T.

					//--Verifica se a linha não esta deletada
					If !aCols[nx][Len(aCols[nx])]
						dbSelectArea("SQR")
						dbSetOrder(1)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Se encontrar o registro entao edita o mesmo. ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  						nRecno := 0
  						If Len(aRecnos) >= nx
  							nRecno := aRecnos[nx]
  						EndIf
  						If nRecno > 0
                  			dbGoto(nRecno)
		                  	lFound := .F.

  						ElseIf dbSeek(cFilSQR+cCurric+aLbx[ny][1]+aLbx[ny][3]+;
							aCols[nx][nPosQuestao]+aCols[nx][nPosAlterna])


							While !Eof() .And.;
								( cFilSQR+cCurric+aLbx[ny][1]+aLbx[ny][3]+aCols[nx][nPosQuestao]+;
							 		aCols[nx][nPosAlterna] ) ==;
								( QR_FILIAL+QR_CURRIC+QR_TESTE+QR_TOPICO+QR_QUESTAO+QR_ALTERNA )

								If aCols[nx][nPosVaga]+Dtoc(aCols[nx][nPosData]) == QR_VAGA+Dtoc(QR_DATA)
									lFound := .F.
									Exit
								EndIf

								dbSkip()
							EndDo


						EndIf

						RecLock("SQR",lFound)

						    Replace QR_FILIAL	With xFilial("SQR")
							Replace QR_CURRIC 	With cCurric
							Replace QR_TOPICO	With aLbx[ny][3]
							If Empty(aCols[nx][nPosQuestao])
								Replace QR_RESULTA 	With Val(aLbx[ny][5])
								Replace QR_TESTE	With aLbx[ny][1]
							Else
								Replace QR_RESULTA 	With aCols[nx][nPosResulta]
								Replace QR_TESTE	With acols[nx][nPosTeste]
							EndIf

							For nt := 1 to Len(aHeader)
								If aHeader[nt][10] # "V"
									cVar := Trim(aHeader[nt][2])
									Replace &cVar. With aCols[nx][nt]
								EndIf
								If aHeader[nt][8] == "M"	// Campo Memo
									MsUnlock()
									MSMM(QR_MRESPOS,,,aCols[nx][nt],1,,,"SQR","QR_MRESPOS","RDY")
									RecLock("SQR",.F.)
								EndIf
							Next nt

						MsUnlock()
					Else 	//--Quando a Linha esta deletada
						dbSelectArea("SQR")
						dbSetOrder(1)
						If dbSeek(cFilSQR+cCurric+aLbx[ny][1]+aLbx[ny][3]+;
							aCols[nx][nPosQuestao]+aCols[nx][nPosAlterna])


								While !Eof() .And. (cFilSQR+cCurric+aLbx[ny][1]+aLbx[ny][3]+;
				  					aCols[nx][nPosQuestao]+aCols[nx][nPosAlterna]) ==;
									( QR_FILIAL+QR_CURRIC+QR_TESTE+QR_TOPICO+QR_QUESTAO+QR_ALTERNA )

									If 	aCols[nx][nPosVaga]+Dtoc(aCols[nx][nPosData]) ==;
										aLbx[ny][7]+aLbx[ny][8]

										MSMM(QR_MRESPOS,,,,2,,,,,"RDY")
										RecLock("SQR",.F.)
											dbDelete()
										MsUnlock()
								        Exit
									EndIf

									dbSkip()
								EndDo
						EndIf
					EndIf
				Next nx
			Else	//--Se Teste+Topico deletado apaga do SQR
				dbSelectArea("SQR")
				dbSetOrder(1)
				dbSeek(cFilSQR+cCurric+aLbx[ny][1]+aLbx[ny][3])
				While !Eof() .And. cFilSQR+cCurric+aLbx[ny][1]+aLbx[ny][3]==;
					QR_FILIAL+QR_CURRIC+QR_TESTE+QR_TOPICO

					If( aLbx[ny][7]+aLbx[ny][8] == QR_VAGA+Dtoc(QR_DATA) )

						MSMM(QR_MRESPOS,,,,2,,,,,"RDY")
						RecLock("SQR",.F.)
							dbDelete()
						MsUnlock()
					EndIf
					dbSkip()
				EndDo
			EndIf
		Next ny
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010Valid³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida se o codigo do curriculo nao foi alterado           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010Valid(cCurric)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A010Valid(cCurric)

If nOpcao == 4 						// Alteracao
	If cCurric # SQG->QG_CURRIC
		Help("",1,"A010CURRIC")
		Return .F.
	EndIf
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010LinOk³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da linha da getdados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A010LinOk()
Local ny			:= 0
Local lEmpty 		:= .T.
Local nPosDtAdmis	:= 0
Local nPosArea		:= 0
Local nPosEmpresa	:= 0
Local nPosFuncao	:= 0
Local nPosDtDemis	:= 0
Local nPosCurso		:= 0
Local nPosCurFun	:= 0
Local nPosFator		:= 0
Local nPosGrau		:= 0
Local nCq 			:= 0

If nOpcao == 2 .Or. nOpcao == 5		// Visual e Exclusao
	Return .T.
EndIf

// Controle da 1a. linha em branco e qdo nao verificar os campos obrigatorios
If Len(aCols) == 1 .And. lOk
	For ny := 1 To Len(aCols[1]) - 3
		If !Empty(aCols[n][ny])
			lEmpty := .F.
			Exit
		EndIf
	Next ny
Else
	lEmpty := .F.
EndIf

If !lEmpty
	If oFolder:nOption == 2 		// Historico Profissional
		nPosDtAdmis	:= GdFieldPos("QL_DTADMIS")
		nPosDtDemis	:= GdFieldPos("QL_DTDEMIS")
		nPosArea	:= GdFieldPos("QL_AREA")
		nPosEmpresa	:= GdFieldPos("QL_EMPRESA")
		nPosFuncao	:= GdFieldPos("QL_FUNCAO")
		If nPosDtAdmis > 0 .And. nPosArea > 0 .And. nPosEmpresa > 0 .And. nPosFuncao > 0
			If (Empty(aCols[n][nPosDtAdmis])  	.Or.;
				Empty(aCols[n][nPosArea])		.Or.;
				Empty(aCols[n][nPosEmpresa])	.Or.;
				Empty(aCols[n][nPosFuncao]))	.And.;
				!aCols[n][Len(aCols[n])]
				Help(" ",1,"A010VZ2")		// Verifique os campos de Data de Admissao,
				Return .F.					// Codigo da area, empresa e funcao nao devem
			EndIf							// estar vazios
		EndIf
		If 	nPosDtAdmis > 0 .And. nPosDtDemis > 0 .And.;
			!Empty(aCols[n][nPosDtDemis]) .And.;
			aCols[n][nPosDtAdmis] > aCols[n][nPosDtDemis]
			Help(" ",1,"A010DATAS")
			Return .F.
		EndIf

	ElseIf oFolder:nOption == 3		// Curso
		nPosCurso 	:= GdFieldPos("QM_CURSO")
		nPosCurFun 	:= GdFieldPos("QM_CDCURSO")
		If	(Empty(aCols[n][nPosCurso])) .And.;
			(Empty(aCols[n][nPosCurFun])) .And.;
			!aCols[n][Len(aCols[n])]
			Help(" ",1,"A010VZ3")		// Verifique os campos de entidade, data,
			Return .F.					// curso e escolaridade nao devem estar
		EndIf							// vazios

	ElseIf oFolder:nOption == 4	// Qualificacao
		nPosFator 	:= GdFieldPos("QI_FATOR")
		nPosGrau	:= GdFieldPos("QI_GRAU")
		If (Empty(aCols[n][nPosFator]) 	.Or.;
			Empty(aCols[n][nPosGrau]))		.And.;
			!aCols[n][Len(aCols[n])]
			Help(" ",1,"A010VZ4")
			Return .F.
		EndIf

		If !aCols[n,Len(aCols[n])]
			For ny:=1 To Len(aCols)
				If 	aCols[n][nPosFator] == aCols[ny][nPosFator] .And.;
					!aCols[ny][Len(aCols[ny])] .And.;
					n # ny
					Aviso(STR0047,STR0067, {"Ok"}) //Atenção # "Esse fator já foi cadastrado anteriormente."
					Return .F.
					Exit
				EndIf
			Next ny
		EndIf

	ElseIf oFolder:nOption == 5	// Avaliacao
		If	aLbx[oLbx:nAt][6]	== "Ativo"
			//--Procura Coluna do Questao
			nCQ := GdFieldPos("QR_QUESTAO")
			//-- Verifica se o Campo Questao esta preenchido.
			If nCQ > 0 .And. Empty(aCols[n][nCQ]) .And.;
				!aCols[n][Len(aCols[n])] .And. n # 1
				Help(" ",1,"A010VZ5")
				Return .F.
			EndIf

			A010CalcPontos(oLbx:nAt)
			oLbx:Refresh()
		EndIf
	EndIf
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010TudOk³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida toda a getdados                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010TudOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A010TudOk()
Local ny			:= 0
Local nx			:= 0
Local lEmpty		:= .T.
Local nPosDtAdmis	:= 0
Local nPosArea		:= 0
Local nPosEmp 		:= 0
Local nPosFuncao	:= 0
Local nPosCurso		:= 0
Local nPosCurFun	:= 0
Local nPosFator		:= 0
Local nPosGrau		:= 0
Local nPosQuestao	:= 0

If nOpcao == 2 .Or. nOpcao == 5		// Visual e Exclusao
	Return .T.
EndIf

If oFolder:nOption == 2 		// Historico Profissional
	aListPast[2][1] := aClone(aHeader)
	aListPast[2][2] := aClone(aCols)
	aListPast[2][3] := 1

ElseIf oFolder:nOption == 3 	// Curso
	aListPast[3][1] := aClone(aHeader)
	aListPast[3][2] := aClone(aCols)
	aListPast[3][3] := 1

ElseIf oFolder:nOption == 4 	// Qualificacao
	aListPast[4][1] := aClone(aHeader)
	aListPast[4][2] := aClone(aCols)
	aListPast[4][3] := 1

EndIf

	// Historico Profissional
	aHeader 	:= aClone(aListPast[2][1])
	aCols		:= aClone(aListPast[2][2])
	n			:= 1

	// Controle da 1a. linha em branco e qdo nao verificar os campos obrigatorios
	If Len(aCols) == 1
		For ny := 1 To Len(aCols[1]) -3
			If !Empty(aCols[n][ny])
				lEmpty := .F.
				Exit
			EndIf
		Next ny
	Else
		lEmpty := .F.
	EndIf

	If !lEmpty
		nPosDtAdmis	:= GdFieldPos("QL_DTADMIS")
		nPosArea	:= GdFieldPos("QL_AREA")
		nPosEmp 	:= GdFieldPos("QL_EMPRESA")
		nPosFuncao	:= GdFieldPos("QL_FUNCAO")

		If nPosDtAdmis>0 .And. nPosArea>0 .And. nPosEmp>0 .And. nPosFuncao>0
			For nx := 1 To Len(aCols)
				If (Empty(aCols[nx][nPosDtAdmis]) .Or.;
					Empty(aCols[nx][nPosArea]) 	.Or.;
					Empty(aCols[nx][nPosEmp]) 		.Or.;
					Empty(aCols[nx][nPosFuncao])) .And. ;
					!aCols[nx][Len(aCols[nx])]
					Help(" ",1,"A010VZ2")	// Verifique os campos de Data de Admissao,
					A010RstPos()
					Return .F.				// Codigo da area, empresa e funcao nao devem
				EndIf						// estar vazios
			Next nx
		EndIf
	EndIf

	// Curso
	aHeader	:= aClone(aListPast[3][1])
	aCols	:= aClone(aListPast[3][2])
	n		:= 1
	lEmpty	:= .T.

	// Controle da 1a. linha em branco e qdo nao verificar os campos obrigatorios
	If Len(aCols) == 1
		For ny := 1 To Len(aCols[1]) - 3
			If !Empty(aCols[n][ny])
				lEmpty := .F.
				Exit
			EndIf
		Next ny
	Else
		lEmpty := .F.
	EndIf

	If !lEmpty
		nPosCurso	:= GdFieldPos("QM_CURSO")
		nPosCurFun 	:= GdFieldPos("QM_CDCURSO")
		If nPosCurso > 0
			For ny := 1 to Len(aCols)
				If	(Empty(aCols[ny][nPosCurso])) 	.And.;
					(Empty(aCols[ny][nPosCurFun])) .And.;
					!aCols[ny][Len(aCols[ny])]
					Help(" ",1,"A010VZ3")
					A010RstPos()
					Return .F.
				EndIf
			Next ny
		EndIf
	EndIf

// Qualificacao
aHeader	:= aClone(aListPast[4][1])
aCols	:= aClone(aListPast[4][2])
n		:= 1
lEmpty	:= .T.

// Controle da 1a. linha em branco e qdo nao verificar os campos obrigatorios
If Len(aCols) == 1
	For ny := 1 To Len(aCols[1]) - 3
		If !Empty(aCols[n][ny])
			lEmpty := .F.
			Exit
		EndIf
	Next ny
Else
	lEmpty := .F.
EndIf

If !lEmpty
	nPosFator	:= GdFieldPos("QI_FATOR")
	nPosGrau	:= GdFieldPos("QI_GRAU")
	If nPosFator >0 .And. nPosGrau >0
		For ny := 1 to Len(aCols)
			If (Empty(aCols[ny][nPosFator]) 	.Or.;
				Empty(aCols[ny][nPosGrau]))	.And.;
				!aCols[ny][Len(aCols[ny])]
				Help(" ",1,"A010VZ4")
				A010RstPos()
				Return .F.
			EndIf
		Next ny
	EndIf

EndIf

// Avaliacao
For nx := 1 To Len(aLbx)
	If	aLbx[nx][6] == "Ativo"
		aHeader 	:= aClone(aSvGetD[nx][1])
		aCols		:= aClone(aSvGetD[nx][2])
		n			:= 1
		nPosQuestao	:= GdFieldPos("QR_QUESTAO")
		If nPosQuestao >0
			For ny := 1 to Len(aCols)
				If Empty(aCols[ny][nPosQuestao]) .And.;
					!aCols[ny][Len(aCols[ny])] .And.;
					n # 1
					Help(" ",1,"A010VZ5")
					A010RstPos()
					Return .F.
				EndIf
			Next ny
		EndIf
	EndIf
Next nx

A010RstPos()

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A010RstPos³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 25/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Restaura acols anterior a validacao		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A010RstPos()

//--Voltar o Acols na Posicao da confirmacao

If oFolder:nOption == 2 		// Historico Profissional
	aHeader := aClone(aListPast[2][1])
	aCols	:= aClone(aListPast[2][2])
	n		:= 1

ElseIf oFolder:nOption == 3 	// Curso
	aHeader := aClone(aListPast[3][1])
	aCols	:= aClone(aListPast[3][2])
	n		:= 1

ElseIf oFolder:nOption == 4 	// Qualificacao
	aHeader := aClone(aListPast[4][1])
	aCols	:= aClone(aListPast[4][2])
	n		:= 1

ElseIf oFolder:nOption == 5 .or. oFolder:nOption == 1 	// Avaliacao // Validação para o carregamento da aba Avaliação pela segunda vez.
	nx := oLbx:nat
	aHeader 	:= aClone(aSvGetD[nx][1])
	aCols		:= aClone(aSvGetD[nx][2])
	n			:= 1
EndIf

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010SQR  ³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o listbox e a getdados do folder 5                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010SQR(nOpcx)
Local aAuxHeader:= {}
Local aAuxCols 	:= {}
Local aChave	:= {}
Local aTemp		:= {}
Local nPosTeste	:= 0
Local nPosQuest	:= 0
Local nPosTopico:= 0
Local nPosAltern:= 0
Local nPosResult:= 0
Local nPosDurac	:= 0
Local nPosResp	:= 0
Local cTeste	:= ""
Local cTopico	:= ""
Local nControl	:= 0
Local nx		:= 0
Local ny		:= 0

Local cVaga		:= ""
Local dData 	:= Ctod("")
Local nPosVaga	:= 0
Local nPosData	:= 0

// Montar o ListBox
aAuxHeader	:= aClone(aListPast[5][1])
aAuxCols	:= aClone(aListPast[5][2])

aCols	:={}
aHeader	:={}
// Retira alguns campos da GetDados
aSvGetD	:={RSP010Fill(6,nOpcx)}
aAdd(aSvGetD[1],{})

nPosTeste 	:= GdFieldPos("QR_TESTE"	,aAuxHeader)
nPosTopico 	:= GdFieldPos("QR_TOPICO"	,aAuxHeader)
nPosQuest	:= GdFieldPos("QR_QUESTAO"	,aAuxHeader)
nPosAltern 	:= GdFieldPos("QR_ALTERNA"	,aAuxHeader)
nPosResult 	:= GdFieldPos("QR_RESULTA"	,aAuxHeader)
nPosResp 	:= GdFieldPos("QR_MEMO1"	,aAuxHeader)
nPosDurac 	:= GdFieldPos("QR_DURACAO"	,aAuxHeader)
nPosVaga 	:= GdFieldPos("QR_VAGA"	,aAuxHeader)
nPosData	:= GdFieldPos("QR_DATA"	,aAuxHeader)

aAuxCols := ASort(aAuxCols,,,{ |x, y| x[nPosTeste]+x[nPosVaga]+Dtos(x[nPosData])+x[nPosTopico]+x[nPosQuest]+x[nPosAltern] < ;
y[nPosTeste]+y[nPosVaga]+Dtos(y[nPosData])+y[nPosTopico]+y[nPosQuest]+y[nPosAltern]})

aLbx :={}
If Empty(aAuxCols[1][1])
	Aadd(aLbx,{"","","","","","","",""})
	aChave:={}
	Aadd(aChave,{"   ", "   ", "      ", "        ", .F.})
	aSvGetD[1][4] := aClone(aChave)
	aCols := Array(1, Len(aHeader) + 1)
Else
	aCols	:= {}
	aHeader := aClone(aSvGetD[1][1])

	If lExecAuto
		aTemp := aClone(aSvGetD[1][2][1])
		For nControl := 1 to Len(aRotAuto[5][2])
			If nControl > 1
				aAdd(aSvGetD[1][2],aClone(aTemp))
			EndIf
			For nY := 1 to Len(aRotAuto[5][1][1])
				If (nX := aScan(aSvGetD[1][1],{|x| AllTrim(x[2]) == AllTrim(aRotAuto[5][1][1][nY])})) > 0
				//aSvGetD[1][1][nX][2] == aRotAuto[5][1][1][nPos]
					aSvGetD[1][2][nControl][nX] := aRotAuto[5][2][nControl][nY]
				EndIf
			Next nY
		Next nControl
	EndIf
	nControl := 0
	aColsSQR := aClone(aSvGetD[1][2]) //Novo
	For nx := 1 To Len(aColsSQR)
		Aadd(aColsSQR[nx],.F.)
	Next nx

	nPos2Teste	:= GdFieldPos("QR_TESTE"	,aHeader)
	nPos2Vaga   := GdFieldPos("QR_VAGA"		,aHeader)
	nPos2Data	:= GdFieldPos("QR_DATA"		,aHeader)
	nPos2Quest  := GdFieldPos("QR_QUESTAO"	,aHeader)
	nPos2Altern := GdFieldPos("QR_ALTERNA"	,aHeader)

	aColsSQR := ASort(aColsSQR,,,{ |x, y| x[nPos2Teste]+x[nPos2Vaga]+Dtos(x[nPos2Data])+x[nPos2Quest]+x[nPos2Altern] < ;
	y[nPos2Teste]+y[nPos2Vaga]+Dtos(y[nPos2Data])+y[nPos2Quest]+y[nPos2Altern]})


	aSvGetD := {}
	For nx := 1 To Len(aAuxCols)
		If cTeste  # aAuxCols[nx][nPosTeste] .Or.;
			cTopico # aAuxCols[nx][nPosTopico] .Or.;
			cVaga # aAuxCols[nx][nPosVaga]  .Or.;
			dData # aAuxCols[nx][nPosData]

			dbSelectArea("SQQ")
			dbSetOrder(1)
			dbSeek(xFilial("SQQ")+aAuxCols[nx][nPosTeste])

			dbSelectArea("SX5")
			dbSetOrder(1)
			dbSeek(xFilial("SX5")+"R2"+aAuxCols[nx][nPosTopico])

			Aadd(aLbx,{;
			aAuxCols[nx][nPosTeste],;
			UPPER(SQQ->QQ_DESCRIC),;
			aAuxCols[nx][nPosTopico],;
			UPPER(Substr(SX5->X5_DESCRI,1,30)),;
			Str(aAuxCols[nx][nPosResult]),;
			"Ativo",;
			aAuxCols[nx][nPosVaga] ,;
			Dtoc(aAuxCols[nx][nPosData]),;
			})

			If nControl # 0					// Verifica a 1a vez
				Aadd(aSvGetD,{{},{},1,{}})
				aChave:={}
				Aadd(aChave,{cTeste,cTopico,cVaga,Dtoc(dData)})

				// Atualiza os pontos do teste no listbox
				If !Empty(aAuxCols[nx-1][nPosQuest])
					A010CalcPontos(Len(aLbx)-1)
				EndIf

				aSvGetD[nControl][1] 	:= aClone(aHeader)
				aSvGetD[nControl][2] 	:= aClone(aCols)
				aSvGetD[nControl][3] 	:= 1
				aSvGetD[nControl][4] 	:= aClone(aChave)
				aCols					:= {}
			EndIf

			Aadd(aCols, Aclone(aColsSQR[nx]))

			cTeste	:= aAuxCols[nx][nPosTeste]
			cTopico	:= aAuxCols[nx][nPosTopico]

			cVaga	:= aAuxCols[nx][nPosVaga]
			dData   := aAuxCols[nx][nPosData]

			nControl++
		Else
			Aadd(aCols, Aclone(aColsSQR[nx]))
		EndIf
	Next nx

	IIF(nControl>=1,nControl,nControl++)
	Aadd(aSvGetD,{{},{},1,{}})
	aChave:={}
	Aadd(aChave,{aAuxCols[Len(aAuxCols)][nPosTeste],aAuxCols[Len(aAuxCols)][nPosTopico],aAuxCols[Len(aAuxCols)][nPosVaga],Dtoc(aAuxCols[Len(aAuxCols)][nPosData])})
	aSvGetD[nControl][1] := aClone(aHeader)
	If Len(aCols) == 0
		aCols := A010Monta(aHeader,"")
	EndIf

	// Atualiza os pontos do teste no listbox
	If !Empty(aAuxCols[Len(aAuxCols)][nPosQuest])
		A010CalcPontos(Len(aLbx))
	EndIf

	aSvGetD[nControl][2] := aClone(aCols)
	aSvGetD[nControl][3] := Len(aCols)
	aSvGetD[nControl][4] := aClone(aChave)
EndIf

For ny := 1 To Len(aSvGetD)
	If aSvGetD[ny][3] > 1 .And. Empty(aSvGetD[ny][2][1][1])
		ADEL(aSvGetD[ny][2],1)
		ASIZE(aSvGetD[ny][2], Len(aSvGetD[ny][2])-1)
		aSvGetD[ny][3]--
	EndIf
Next ny

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010SM6  ³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o listbox e a getdados do folder 6                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010SM6(nOpcx)
Local nLinha	:= 0
Local nPosTipo	:= 0
Local nPosResp	:= 0
Local nPosAlt	:= 0

DbSelectArea("SM6")

DbSelectArea("RS6")
DbGoTop()

aLbx2 	:= {}
aGrvSM6 := {}

While RS6->(!Eof())
	If RS6->RS6_INTERN == "1"
		aAdd(aLbx2,{RS6->RS6_CODIGO,RS6->RS6_DESC})
		If lExecAuto
			nPosTipo := aScan(aRotAuto[6][1][1],{|x| AllTrim(x) == 'M6_TIPO'})
			nPosResp := aScan(aRotAuto[6][1][1],{|x| AllTrim(x) == 'M6_RESP'})
			nPosAlt  := aScan(aRotAuto[6][1][1],{|x| AllTrim(x) == 'M6_ALTERNA'})

			nLinha := aScan(aRotAuto[6][2],{|x| x[nPosTipo] == RS6->RS6_CODIGO})
			If nLinha > 0
				aSeq := {}
				aSeq := StrTokArr2(AllTrim(aRotAuto[6][2][nLinha][nPosAlt]),"*",.T.)
				aAdd(aGrvSM6,{aRotAuto[6][2][nLinha][nPosTipo], aRotAuto[6][2][nLinha][nPosResp], aSeq,.T.})
			EndIf
		Else
			fCargaSM6()
		EndIf
	EndIf
	RS6->(DbSkip())
EndDo

If Empty(aLbx2)
	aAdd(aLbx2,{"",""})
Else
	A010AtuSr6(1)
EndIf

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010SQI  ³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o get com os dados do grupo para avaliacao do curric ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010SQI()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010SQI()
Local aSaveArea := GetArea()

If nOpcao != 3			// Inclusao
	cGrupo := M->QG_GRUPO
	dbSelectArea("SQ0")
	dbSetOrder(1)
	If dbSeek(xFilial("SQ0")+M->QG_GRUPO)
		cDescGrupo := SQ0->Q0_DESCRIC
	EndIf
EndIf

RestArea(aSaveArea)
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A010ListBox³ Autor ³ Cristina Ogura      ³ Data ³ 03.12.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controle dos dados do ListBox                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010ListBox(nPos,nList)	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nPos    = Posicao no ListBox                               ³±±
±±³          ³ nList   = Opcao escolhida atraves dos botoes               ³±±
±±³          ³           1 - inclusao                                     ³±±
±±³          ³           2 - alteracao                                    ³±±
±±³          ³           3 - exclusao                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010ListBox(nPos,nList)
Local oDlg, oDTeste
Local cDTeste	:= ""
Local nResulta	:= 0
Local cTopico	:= Space(3)
Local cDTopico	:= ""
Local cSit		:= ""
Local nOpc1		:= 0
Local aChave	:= {}
Local aAuxHeader:= aClone(aSvGetD[1][1])
Local ny		:= 0
Local nCnt1		:= 0

Local cVaga		:= ""
Local dData		:= Ctod("")
Local cDVaga	:= ""
Local bSet15
Local bSet24
Local aButtons := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Private cTesteList	:= ""
Private oTesteList
Private cAuxTopic	:= ""

Set Key VK_F4 To A010F4()

If Len(aLbx) # 0 .And. Empty(aLbx[1][1]) .And. Empty(aLbx[1][3]) .And. nList # 1
	HELP("",1,"A010VERIF")
	Return
EndIf

If nList = 2 .Or. nList = 3
	cTesteList	:= aLbx[nPos][1]
	cDTeste		:= aLbx[nPos][2]
	nResulta	:= Val(aLbx[nPos][5])
	cSit		:= aLbx[nPos][6]
	cDescTit 	:= If(nList = 2, OemToAnsi(STR0023), OemToAnsi(STR0024)) //"Alteracao"###"Exclusao"
	cVaga   := aLbx[nPos][7]
	dData  	:= Ctod(aLbx[nPos][8])
	cTopico := aLbx[nPos][3]
	cDTopico:= aLbx[nPos][4]
	Rs010Vaga(cVaga, @cDVaga)
Else
	cTesteList 	:= CriaVar("QR_TESTE")
	cDTeste		:= CriaVar("QQ_DESCRIC")
	nResulta	:= 0.00
	cSit		:= "Ativo"
	cDescTit 	:= OemToAnsi(STR0025) //"Inclusao"
	cVaga 	:= Space(06)
	dData 	:= dDataBase
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize( , .T., 100)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 005 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 015 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 015 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 015 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 015 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 005 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*60), (((aObjSize[1,4])/100)*58) }	//1,3 Vertical /1,4 Horizontal

DEFINE MSDIALOG oDlg FROM  aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cDescTit PIXEL
@ aObjSize[1,1], aObjSize[1,2] TO aObjSize[6,3], aObjSize[6,4] OF oDlg  PIXEL

@ aObjSize[2,1], aObjSize[2,2]+25 SAY OemtoAnsi(STR0013) SIZE 25,10 OF oDlg PIXEL //"Teste"
@ aObjSize[2,1], aObjSize[2,2]+60 MSGET oTesteList 	VAR cTesteList F3 "SQQ";
							PICTURE "999";
							WHEN nList==1 .Or. nList==2;
							VALID A010ChkTeste(cTesteList,@cDTeste);
							SIZE 25,10 OF oDlg PIXEL HASBUTTON
@ aObjSize[2,1], aObjSize[2,2]+100 MSGET oDTeste  VAR cDTeste;
							WHEN .F.;
							SIZE 100, 10 OF oDlg PIXEL

@ aObjSize[3,1], aObjSize[3,2]+25 SAY OemtoAnsi(STR0015) SIZE 25,10 OF oDlg PIXEL //"Topico"
@ aObjSize[3,1], aObjSize[3,2]+60 MSGET cTopico F3 "R2"	PICTURE "@!" WHEN nList==1 .Or. nList==2 VALID Rs010ChkTop(cTopico,@cDTopico) SIZE 25,10 OF oDlg PIXEL HASBUTTON
@ aObjSize[3,1], aObjSize[3,2]+100 MSGET cDTopico	WHEN .F. SIZE 100, 10 OF oDlg PIXEL

@ aObjSize[4,1], aObjSize[4,2]+25 SAY OemtoAnsi(STR0065) SIZE 25,10 OF oDlg PIXEL //"Vaga"
@ aObjSize[4,1], aObjSize[4,2]+60 MSGET cVaga  F3 "SQS"	PICTURE "999999" WHEN nList==1 .Or. nList==2 VALID Rs010Vaga(cVaga, @cDVaga) SIZE 25,10 OF oDlg PIXEL HASBUTTON
@ aObjSize[4,1], aObjSize[4,2]+100 MSGET cDVaga	WHEN .F. SIZE 100, 10 OF oDlg PIXEL

@ aObjSize[5,1], aObjSize[5,2]+25 SAY OemtoAnsi(STR0066) SIZE 25,10 OF oDlg PIXEL //"Data"
@ aObjSize[5,1], aObjSize[5,2]+60 MSGET dData  PICTURE "99/99/99" WHEN nList==1 .Or. nList==2 SIZE 40,10 OF oDlg PIXEL HASBUTTON

bSet15 := {|| If(A010Chk(nList,cTesteList,cVaga,dData), ( nOpc1 := 1,oDlg:End() ), Nil)}
bSet24 := {|| nOpc1 := 0,oDlg:End()}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bSet15, bSet24, Nil, aButtons) CENTERED

If nOpc1 = 1
	If Len(aLbx) # 0
		If	Empty(aLbx[1][1]) .And. Empty(aLbx[1][3]) .And. nList # 1
			HELP("",1,"A010LISTVAZIO")
			Return
		EndIf
	EndIf

	If nList = 1    		// Inclusao no ListBox
		If Len(aLbx) == 1 .And. Empty(aLbx[1][1]) .And. Empty(aLbx[1][3])  // Verifica quando esta vazio
			aLbx[1][1] 	:= cTesteList
			aLbx[1][2]	:= cDTeste
			aLbx[1][3] 	:= cTopico
			aLbx[1][4] 	:= cDTopico
			aLbx[1][5] 	:= Str(nResulta,7,2)
			aLbx[1][6] 	:= "Ativo"
			aLbx[1][7]	:= cVaga
			aLbx[1][8]	:= Dtoc(dData)

			aSvGetD[1][2] 	:= A010Monta(aAuxHeader,cTesteList,cVaga,dData)
			aSvGetD[1][3] 	:= 1
			aChave			:= {}
			Aadd(aChave,{cTesteList,cTopico, cVaga ,Dtoc(dData) ,.F.})
			aSvGetD[1][4] 	:= aClone(aChave)
		Else
			Aadd(aLbx,{cTesteList,cDTeste,cTopico,cDTopico,Str(nResulta,7,2),"Ativo",cVaga,Dtoc(dData)})
			Aadd(aSvGetD,{{},{},1,{}})
			aSvGetD[Len(aLbx)][1] 	:= aClone(aSvGetD[1][1])
			aSvGetD[Len(aLbx)][2]	:= A010Monta(aAuxHeader,cTesteList,cVaga,dData)
			aSvGetD[Len(aLbx)][3] 	:= 1
			aChave					:= {}
			Aadd(aChave,{cTesteList,cTopico,cVaga,Dtoc(dData)})
			aSvGetD[Len(aLbx)][4] := aClone(aChave)
		EndIf
	ElseIf nList = 2   	// Alteracao no ListBox
		aLbx[nPos][1]	:= cTesteList
		aLbx[nPos][2]	:= cDTeste
		aLbx[nPos][3]	:= cTopico
		aLbx[nPos][4]	:= cDTopico
		aLbx[nPos][5]	:= Str(nResulta,7,2)
		aLbx[nPos][6]	:= cSit
		aLbx[nPos][7]	:= cVaga
		aLbx[nPos][8]	:= Dtoc(dData)

		aSvGetD[1][2] 	:= A010Monta(aAuxHeader, cTesteList, cVaga, dData)
		aSvGetD[1][3] 	:= 1
		aChave			:= {}
		
		Aadd(aChave, {cTesteList, cTopico, cVaga, Dtoc(dData), .F.})
		aSvGetD[1][4] 	:= aClone(aChave)

	ElseIf nList = 3  	// Exclusao no ListBox
		If aLbx[nPos][6] == "Excluido"
			aLbx[nPos][6] := "Ativo"
		Else
			aLbx[nPos][6] := "Excluido"
		EndIf
		cTesteList:= aLbx[nPos][1]
		cTopico:=aLbx[nPos][3]
		nUsado:=Len(aHeader)

		If Len(aLbx) == 1 .And. Empty(aLbx[1][1])
			aLbx[1][1] 	:= ""
			aLbx[1][2] 	:= ""
			aLbx[1][3] 	:= ""
			aLbx[1][4] 	:= ""
			aLbx[1][5] 	:= ""
			aLbx[1][6] 	:= ""
			aLbx[1][7] := ""
			aLbx[1][8] := ""

			aSvGetD[1][2] 	:= A010Monta(aAuxHeader,"")
			aSvGetD[1][3] 	:= 1
			aChave			:= {}
			Aadd(aChave,{aLbx[1][1],aLbx[1][3],aLbx[1][7],aLbx[1][8]})
			aSvGetD[1][4] 	:= aClone(aChave)
		EndIf
		For nCnt1:= 1 To len(aSvGetD[nPos][2])
				aSvGetD[nPos,2,nCnt1,nUsado+2] := If(aSvGetD[nPos,2,nCnt1,nUsado+2] == .F., .T., .F.)
		Next nCnt1
	EndIf
EndIf

Return {cTesteList,cTopico}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010ChkTeste ³ Autor ³ Cristina Ogura    ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o teste selecionado no folder 5 existe         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010ChkTeste(cTeste,cDTeste)

dbSelectArea("SQQ")
dbSetOrder(1)
If dbSeek(xFilial("SQQ")+cTeste)
	cDTeste:= UPPER(SQQ->QQ_DESCRIC)
Else
	Help(" ",1,"A010NEXISTE")
	Return .F.
EndIf
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Rs010ChkTop  ³ Autor ³ Emerson Grassi    ³ Data ³ 29/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o Topico selecionado no folder 5 existe        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Rs010ChkTop(cTopico,cDTopico)
Local aSaveArea := GetArea()
Local lRet 		:= .T.

dbSelectArea("SX5")
dbSetOrder(1)
If dbSeek(xFilial("SX5")+"R2"+cTopico)
	cDTopico := Substr(SX5->X5_DESCRI,1,30)
Else
	Help(" ",1,"A010NPODE")
	lRet := .F.
EndIf

RestArea(aSaveArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Rs010Vaga    ³ Autor ³ Emerson Grassi    ³ Data ³ 29/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Descricao da Data									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Rs010Vaga(cVaga, cDVaga)
Local aSaveArea := GetArea()
Local lRet 		:= .T.

dbSelectArea("SQS")
dbSetOrder(1)
If dbSeek(xFilial("SQS")+cVaga)
	cDVaga := Substr(SQS->QS_DESCRIC,1,30)
EndIf

RestArea(aSaveArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010Chk  ³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o teste ja foi incluido no listbox             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010Chk(ExpN1,ExpC1,ExpC2)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nList   = Opcao escolhida atraves dos botoes               ³±±
±±³          ³           1 - inclusao                                     ³±±
±±³          ³           2 - alteracao                                    ³±±
±±³          ³           3 - exclusao                                     ³±±
±±³          ³ cTeste  = Codigo do Teste                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010Chk(nList,cTeste,cTopico,cVaga,dData)
Local lRet 	:= .T.
Local ny	:= 0

If nList # 3
	For ny := 1 To Len(aLbx)
		If cTeste == aLbx[ny][1] .And. cTopico == aLbx[ny][3] .And.;
			cVaga == aLbx[ny][7] .And.;
			Dtoc(dData) == aLbx[ny][8]
			Help(" ",1,"A010NPODE")
			If nList == 1
				lRet := .F.
			EndIf
			Exit
		EndIf
	Next ny
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010Acres³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza os arrays do listbox em qual operacao efetuada    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010Acres(ExpN1,ExpO1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nPos = posicao no listbox                                  ³±±
±±³          ³ oLbx = objeto do listbox                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010Acres(nPos,oLbx,aVar)
Local nPosAtu := 0

aVar := IIF(aVar==Nil,{"",""},aVar)
If Len(aLbx) # 0
	aLbx	:= ASort(aLbx,,,{ |x, y| x[1]+x[3]<y[1]+y[3]})
	nPosAtu	:= Ascan(aLbx,{|x| x[1]+x[3] == aVar[1]+aVar[2]})
	nPosAtu := IIF(nPosAtu==0, 1, nPosAtu)
	oLbx:SetArray(aLbx)
	oLbx:bLine 	:= { ||  { aLbx[oLbx:nAt,1],aLbx[oLbx:nAt,2],aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5],aLbx[oLbx:nAt,6],aLbx[oLbx:nAt,7],aLbx[oLbx:nAt,8]}}
	oLbx:nAt 	:= nPosAtu
	EVal(oLbx:bChange)
EndIf
oLbx:Refresh()
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010AtuGD³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta os arrays da getdados qdo selecionar outro teste     ³±±
±±³          ³ no folder 5                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010AtuGd(ExpN1,ExpN2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ nPos = Posicao no listbox                                  ³±±
±±³          ³ nVar = Indica quem chamou a funcao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010AtuGD(nPos,nVar,nEstou)
Local ny 		:= 0
Local lLocaliza	:=	.F.
Local nTemp	:=	0
Local nTamSv	:=	0

nEstou := IIF(nEstou==Nil,1,nEstou)

If Len(aLbx) == 0 .And. nVar == 1
	Return .T.
EndIf

nTamSv	:=	LEN(aSvGetD)
For ny := 1 To nTamSv
	If aLbx[nPos][1] = aSvGetD[ny][4][1][1] .And.; 					//Teste
		aLbx[nPos][3] = aSvGetD[ny][4][1][2] .And.;					//Topico
		aLbx[nPos][7] = aSvGetD[ny][4][1][3] .And.; 					//Vaga
		aLbx[nPos][8] = aSvGetD[ny][4][1][4]					 		//Data

		If nVar == 1
			cVarTopico 	:= aLbx[nPos][3]
			aHeader		:= aClone(aSvGetD[ny][1])
			aCols  		:= aClone(aSvGetD[ny][2])
			n	 		:= 1
		ElseIf nVar == 2

			nTemp	:=	0

			If nEstou == 5
				// Localiza em aSvGetD o item da avaliacao
				Do While !( lLocaliza ) .AND. ( ++nTemp <= nTamSV )
					If (acols[1,1] == aSvGetD[nTemp][2][1][1])
						lLocaliza	:=	.T.
					EndIf

				EndDo

				aSvGetD[nTemp][1] := aClone(aHeader)
				aSvGetD[nTemp][2] := aClone(aCols)
				aSvGetD[nTemp][3]	:= 1
			EndIf
		EndIf
		Exit
	EndIf
Next ny
oGet04:ForceRefresh()
//-- carregar a get dados conteudo correto - na 1o. aparecia conteudo da Ultima
oGet04:oBrowse:Reset()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010Monta³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta array aSvGetD com o aCols zerado qdo inclusao listbox³±±
±±³          ³ do folder 5                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010Monta(ExpA1,ExpC1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ aAuxHeader = aHeader da getdados							  ³±±
±±³			 ³ cTeste     = codigo do teste     						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010Monta(aAuxHeader,cTeste,cVaga,dData)
Local aAuxCols	:= {}
Local ny		:= 0
Local nPosTeste	:= 0
Local nPosVaga	:= 0
Local nPosData	:= 0
Local nPosAlias := 0
Local nPosRecno	:= 0

Default cVaga 	:= ""
Default dData	:= Ctod("")

nPosTeste 	:= GdFieldPos("QR_TESTE",aAuxHeader)
nPosVaga 	:= GdFieldPos("QR_VAGA"	,aAuxHeader)
nPosData	:= GdFieldPos("QR_DATA"	,aAuxHeader)
nPosAlias	:= GdFieldPos("QR_ALI_WT",aAuxHeader)
nPosRecno	:= GdFieldPos("QR_REC_WT",aAuxHeader)

aAuxCols 	:= Array(1, Len(aAuxHeader) + 1)

For ny := 1 To Len(aAuxHeader)
	If ny <> nPosAlias .and. ny <> nPosRecno
		aAuxCols[1][ny]:= CriaVar(aAuxHeader[ny][2])
	EndIf
Next ny

aAuxCols[1][Len(aAuxHeader)+1] := .F.

// Forca o codigo do teste na montagem do acols
If !Empty(cTeste)
	aAuxCols[1][nPosTeste] := cTeste
		If !Empty(cVaga) .And. !Empty(dData)
			aAuxCols[1][nPosVaga] := cVaga
			aAuxCols[1][nPosData] := dData
		EndIf

EndIf

Return aAuxCols

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010Questao³ Autor ³ Cristina Ogura      ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica o dado das questoes e critica caso esteja vazio   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010Questao()
Local aSaveArea	:= GetArea()
Local lRet		:= .T.
Local cVar		:= &(ReadVar())
Local nPosTeste	:= GdFieldPos("QR_TESTE")

dbSelectArea("SQO")
dbSetOrder(1)
If dbSeek(xFilial("SQO")+cVar)
	If Len(aLbx) == 1 .And. Empty(aLbx[1][1])
		Help("",1,"A010FALTA")
		lRet := .F.
	Else
		If aLbx[oLbx:nAt][6] == "Excluido"
			Help(" ",1,"A010EXCLUI")
			lRet := .F.
		EndIf
	EndIf
Else
	Help("",1,"A010NEXISTE")
	lRet:= .F.
EndIf

If lRet .And. nPosTeste > 0
	cTeste := aCols[n][nPosTeste]

	SQQ->( dbSeek(xFilial("SQQ")+cTeste) )
	While ! SQQ->( EOF() ) .And. cTeste == SQQ->QQ_TESTE
	    If SQQ->QQ_QUESTAO == cVar
		    RestArea(aSaveArea)
	    	Return .T.
	    EndIf
		SQQ-> (dbSkip())
	EndDo
    Aviso(STR0047, STR0051, {"Ok"})	//"Atencao"###"Questao nao pertence ao teste."
	lRet := .F.
EndIf
RestArea(aSaveArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010Alterna³ Autor ³ Cristina Ogura      ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Critica o campo alternativa                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010Alterna(cValor)
Local cVar			:= ""
Local nPosQuestao 	:= 0
Local nPosAlterna	:= 0
Local nPosResulta	:= 0
Local ny			:= 0
Local nPosTeste		:= 0
Local nResulta		:= 0
Local lTeste		:= .F.
Local lAlterna    	:= .F.

DEFAULT cValor := ""

If !Empty(cValor)
	cVar := cValor
Else
	cVar := &(ReadVar())
EndIf

nPosQuestao := GdFieldPos("QR_QUESTAO")
nPosAlterna := GdFieldPos("QR_ALTERNA")
nPosResulta := GdFieldPos("QR_RESULTA")
nPosTeste 	:= GdFieldPos("QR_TESTE")

For ny := 1 To Len(aCols)
	If aCols[n][nPosQuestao] == aCols[ny][nPosQuestao] .And.;
		cVar == aCols[ny][nPosAlterna] .And.	n # ny .And.;
		!aCols[ny][Len(aCols[ny])] .And. aCols[n][nPosTeste] == aCols[ny][nPosTeste]
		Help("",1,"A010JAEXISTE")
		Return .F.
	EndIf
Next ny

//Teste
dbSelectArea("SQQ")
dbSetOrder(1)
dbGotop()
dbSeek(xFilial("SQQ")+aLbx[oLbx:nAt][1])
While !Eof() .And. xFilial("SQQ")+aLbx[oLbx:nAt][1] == ;
	QQ_FILIAL+QQ_TESTE
	If QQ_QUESTAO == aCols[n][nPosQuestao]
		lTeste:= .T.
		Exit
	EndIf
	dbSkip()
EndDo

If !lTeste
	Help("",1,"A010NTESTE")		// Nao existe a questao para o teste selecionado
	Return .F.
EndIf

// Questoes
dbSelectArea("SQO")
dbSetOrder(1)
dbGotop()
If !dbSeek(xFilial("SQO")+aCols[n][nPosQuestao])
	Help("",1,"A010NEXISTE")
	Return .F.
EndIf

// Alternativas
If Empty( SQO->QO_ESCALA )	//Busca no Cadastro de Alternativas (SQP)

	dbSelectArea("SQP")
	dbSetOrder(1)
	dbGotop()
	If dbSeek(xFilial("SQP")+aCols[n][nPosQuestao])
		While !Eof() .And. xFilial("SQP")+aCols[n][nPosQuestao] ==;
			SQP->QP_FILIAL+SQP->QP_QUESTAO
			If cVar == SQP->QP_ALTERNA
				lAlterna := .T.
				nResulta := SQP->QP_PERCENT
				Exit
			EndIf
			dbSkip()
		EndDo
	Else
		If Empty(cVar)
			lAlterna := .T.
			nResulta := 100
		EndIf
	EndIf
Else

	dbSelectArea("RBL")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek(xFilial("RBL")+SQO->QO_ESCALA)
		While !Eof() .And. xFilial("RBL")+SQO->QO_ESCALA ==;
						 RBL->RBL_FILIAL+RBL->RBL_ESCALA
			If cVar == RBL->RBL_ITEM
				lAlterna	:= .T.
				nResulta	:= RBL->RBL_VALOR
			EndIf
			dbSkip()
		EndDo
	Else
		If Empty(cVar)
			lAlterna := .T.
			nResulta := 100
		EndIf
	EndIf
EndIf

If !lAlterna
	Help("",1,"A010NALTERN")	// Nao existe a alternativa selecionada. Verifique se a questao nao e descritiva
	Return .F.
EndIf

aCols[n][nPosResulta] := nResulta
oGet04:Refresh()

// Atualiza o resultado com os pontos do teste
A010CalcPontos(oLbx:nAt)
oLbx:Refresh()
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A010F4   ³ Autor ³ Cristina Ogura        ³ Data ³ 16.12.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a consulta das questoes e alternativas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ A120F4(a,b,c,ExpC1,ExpC2,ExpC3)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ a,b,c = parametros padroes quando utiliza-se o Set Key     ³±±
±±³          ³ ExpC1 = Arquivo a pesquisar no SX3                         ³±±
±±³          ³ ExpC2 = Variavel que sera usada para o Seek                ³±±
±±³          ³ ExpC3 = Nome do campo em o cursor deve estar posicionado   ³±±
±±³          ³         para ativar esta rotina.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A010F4()
Local cVar 			:= ReadVar()
Local aArrayF4		:= {}
Local cCadastro		:= OemToAnsi(STR0027) //"Consulta Questoes e Alternativas do Teste"
Local oQual, oDlg
Local cQuestao		:= ""
Local nOpca			:= 0
Local nPosQuestao	:= 0
Local nPosAlterna	:= 0
Local nPosResulta	:= 0
Local nPosTeste		:= 0
Local nPosQual		:= 1
Local ny			:= 0
Local nPosTes		:= 0
Local bSet15
Local bSet24
Local aButtons := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

Set Key VK_F4 To
nPosTes	:= GdFieldPos("QR_TESTE")

If Empty(cVar) .Or. Trim(UPPER(ReadVar()))!= "M->QR_TESTE"
   	Set Key VK_F4 To A010F4()
   	Return .T.
EndIf

dbSelectArea("SQQ")
dbSetOrder(1)
If	dbSeek(xFilial("SQQ")+aLbx[oLbx:nAt][1])
	While !Eof() .And. xFilial("SQQ")+aLbx[oLbx:nAt][1] ==;
		QQ_FILIAL+QQ_TESTE
		dbSelectArea("SQO")
		dbSetOrder(1)
		dbSeek(xFilial("SQO")+SQQ->QQ_QUESTAO)

		cQuestao := Substr(SQO->QO_QUEST,1,30)
		dbSelectArea("SQP")
		dbSetOrder(1)
		If dbSeek(xFilial("SQP")+SQQ->QQ_QUESTAO)
			While !Eof() .And. 	xFilial("SQR")+SQQ->QQ_QUESTAO ==;
				QP_FILIAL+QP_QUESTAO
				AADD(aArrayF4,{SQQ->QQ_ITEM,SQO->QO_QUESTAO,cQuestao,SQP->QP_ALTERNA,SQP->QP_DESCRIC,STR(SQP->QP_PERCENT)})
				cQuestao:=Replicate("°",250)
				dbSkip()
			EndDo
		Else
			// Questoes descritivas
			AADD(aArrayF4,{SQQ->QQ_ITEM,SQO->QO_QUESTAO,cQuestao,Space(02),Space(250),Space(08)})
		EndIf

		dbSelectArea("SQQ")
		dbSetOrder(1)
		dbSkip()
	EndDo
EndIf

If Len(aArrayF4) == 0
   	Help("",1,"A010NAOHA")
   	Set Key VK_F4 To A010F4()
  	Return .T.
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize( , .T., 100)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 015 , .T. , .F. } )
aAdd( aObjCoords , { 000 , 000 , .T. , .T., .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

nOpca:= 0
DEFINE MSDIALOG oDlg TITLE cCadastro From aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
@ aObjSize[1,1],aObjSize[1,2] SAY OemtoAnsi(STR0028)+aLbx[oLbx:nAt][3]+"  -  "+aLbx[oLbx:nAt][4]; //"Topico:   "
FONT oFont1	COLOR CLR_BLUE PIXEL
@ aObjSize[2,1],aObjSize[2,2] LISTBOX oQual VAR cVar FIELDS HEADER	OemToAnsi(STR0029),;            //"Item "
OemToAnsi(STR0030),;            //"Cod.Questao"
OemToAnsi(STR0031),;            //"Descricao Questao"
OemToAnsi(STR0032),;            //"Alternativa"
OemToAnsi(STR0033),;            //"Descricao Alternativa"
OemToAnsi(STR0034) SIZE aObjSize[2,3],aObjSize[2,4]; //"Resultado"
ON DBLCLICK (nOpca := 1,oDlg:End()) PIXEL
oQual:SetArray(aArrayF4)
oQual:bLine := { || {aArrayF4[oQual:nAT][1],aArrayF4[oQual:nAT][2],aArrayF4[oQual:nAT][3],aArrayF4[oQual:nAT][4],aArrayF4[oQual:nAT][5],aArrayF4[oQual:nAT][6]}}

bSet15 := {|| nOpca := 1,nPosQual:=oQual:nAt,oDlg:End()}
bSet24 := {|| oDlg:End()}
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bSet15, bSet24, Nil, aButtons) CENTERED

If nOpca == 1

	nPosQuestao := GdFieldPos("QR_QUESTAO")
	nPosAlterna := GdFieldPos("QR_ALTERNA")
	nPosResulta := GdFieldPos("QR_RESULTA")
	nPosTeste 	:= GdFieldPos("QR_TESTE")


	For ny := 1 To Len(aCols)
		If aArrayF4[nPosQual][2] == aCols[ny][nPosQuestao] .And.;
			aArrayF4[nPosQual][4] == aCols[ny][nPosAlterna] .And.;
			!aCols[ny][Len(aCols[ny])] .And.;
			n # ny
			Help("",1,"A010JAEXISTE")
			Set Key VK_F4 To A010F4()
			Return .F.
		EndIf
	Next ny

	aCols[n][nPosTeste]		:= aLbx[oLbx:nAt][1]
	aCols[n][nPosQuestao] 	:= aArrayF4[nPosQual][2]
	aCols[n][nPosAlterna] 	:= aArrayF4[nPosQual][4]
	aCols[n][nPosResulta] 	:= Val(aArrayF4[nPosQual][6])

	M->QR_TESTE				:= aCols[n][nPosTeste]
	M->QR_QUESTAO 			:= aCols[n][nPosQuestao]
	M->QR_ALTERN			:= aCols[n][nPosAlterna]
	M->QR_RESULTA			:= aCols[n][nPosResulta]

	oGet04:Refresh()
EndIf

Set Key VK_F4 To A010F4()

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A010Tempo³ Autor ³ Cristina Ogura        ³ Data ³ 16.12.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o tempo de experiencia e de trabalho na area do    ³±±
±±³          ³ candidato.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010Tempo()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function A010Tempo()
Local nx 		:= 0
Local nPosAdmis	:= 0
Local nPosDemis	:= 0
Local nPosArea	:= 0
Local nTpTrab	:= 0
Local nTpExper	:= 0
Local nAno		:= 0
Local dAdmissao	:= dDemissao := CtoD("")
Local cArea		:= M->QG_AREA

aHeader		:= {}
aCols  		:= {}
aHeader		:= aClone(aListPast[2][1])
aCols  		:= aClone(aListPast[2][2])
nPosAdmis 	:= GdFieldPos("QL_DTADMIS")		// Data Admissao
nPosDemis 	:= GdFieldPos("QL_DTDEMIS")		// Data Demissao
nPosArea 	:= GdFieldPos("QL_AREA")			// Area do Historico

If nPosAdmis > 0 .And. nPosDemis > 0 .And. nPosArea > 0 // Devido algum campo esteja em desuso
	For nx := 1 to Len(aCols)
		If !aCols[nx][Len(aCols[nx])] .And. !Empty(aCols[nx][nPosAdmis])
			dDemissao := aCols[nx][nPosDemis]
			dAdmissao := aCols[nx][nPosAdmis]

			If Empty(aCols[nx][nPosDemis])
				dDemissao := dDatabase
			EndIf

			nAno:= (dDemissao - dAdmissao) / 365
			If aCols[nx][nPosArea] == cArea
				nTpExper+= nAno
			EndIf
			nTpTrab+= nAno
		EndIf
	Next nx
EndIf


Return {nTpTrab,nTpExper}
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A010CalcP.³ Autor ³ Cristina Ogura        ³ Data ³ 16.12.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula os pontos dos questoes e grava no total do teste    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A010CalcPontos(ExpC2)				                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nPos = posicao a ser atualizado do listbox       			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A010CalcPontos(nPos)
Local nx			:= 0
Local ny            := 0
Local nPontos		:= 0
Local nPercent		:= 0
Local nPosQuestao 	:= 0
Local nPosAlterna	:= 0
Local nPosResulta	:= 0
Local cAux  		:= ""
Local aAuxCols		:= {}
Local nTam			:= 0
Local cTeste		:= ""

aAuxCols:= Aclone(aCols)

nPosQuestao := GdFieldPos("QR_QUESTAO")
nPosAlterna := GdFieldPos("QR_ALTERNA")
nPosResulta := GdFieldPos("QR_RESULTA")

aAuxCols := ASort(aAuxCols,,,{ |x,y| x[nPosQuestao]+x[nPosAlterna] < ;
y[nPosQuestao]+y[nPosAlterna]})

cAux:= aAuxCols[1][nPosQuestao]
For ny := 1 To Len(aAuxCols)
	If !aAuxCols[ny][Len(aAuxCols[ny])]				// Deletado
		If cAux # aAuxCols[ny][nPosQuestao]
			If nPercent > 0
				dbSelectArea("SQO")
				dbSetOrder(1)
				If dbSeek(xFilial("SQO")+cAux)
					nPontos+= ((SQO->QO_PONTOS * nPercent) / 100)
				EndIf
			EndIf

			nPercent := 0
			cAux:= aAuxCols[ny][nPosQuestao]
		EndIf

		If nPercent == 100
			nPercent := 99
		Else
			nPercent += aAuxCols[ny][nPosResulta]
		EndIf
	EndIf

Next ny

If nPercent > 0
	dbSelectArea("SQO")
	dbSetOrder(1)
	If dbSeek(xFilial("SQO")+cAux)
		nPontos+= ((SQO->QO_PONTOS * nPercent) / 100)
	EndIf
EndIf

aLbx[nPos][5]   := Str(nPontos,7,2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava Nota do Teste no Curriculo. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcao == 3 .Or. nOpcao == 4

	nPontos := 0
	nTam	:= Len(aLbx)
	cTeste 	:= aLbx[nTam][1]
	For nx := 1 To nTam
		If cTeste == aLbx[nx][1]
			nPontos += Val(aLbx[nx][5])
		EndIf
	Next nx

	dbSelectArea("SQG")
	dbSetOrder(1)
	If lExecAuto
		dbSeek(xFilial("SQG")+SQG->QG_CURRIC)
		SQG->( RecLock("SQG",.F.) )
			SQG->QG_NOTA	:= nPontos
		SQG->(MsUnlock())
	Else
		dbSeek(xFilial("SQG")+M->QG_CURRIC)
		M->QG_NOTA	:= nPontos
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R010Grupo³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de validacao quando digitar o grupo                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R010Grupo(ExpO1,ExpC1,ExpC2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do grupo                         			  ³±±
±±³          ³ ExpC1 = Codigo do Grupo                         			  ³±±
±±³          ³ ExpC2 = Descricao do Grupo                      			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function R010Grupo(oGrupo,cGrupo,cDesc,nEstou)
Local aSaveArea := GetArea()
Local lFlag		:= .F.

If nEstou # 4
	Return .T.
EndIf

If !Empty(cGrupo)
	dbSelectArea("SQ0")
	dbSetOrder(1)
	If !dbSeek(xFilial("SQ0")+cGrupo)
		Help(" ",1,"A010Grupo")	// Grupo nao cadastrado.
		RestArea(aSaveArea)			// Digite um grupo valido ou selecione outro via F3
		Return .F.
	EndIf
	cDesc 		:= SQ0->Q0_DESCRIC

	// Quando mudar de Grupo limpar o acols
	If nOpcao == 3			// Inclusao
		If (cGrupo # cAntGrupo) .And. !Empty(cAntGrupo)
			lFlag:= .T.
		EndIf
	EndIf

	If lFlag
		aCols	:= {}
		aCols 	:= Array(1, Len(aHeader) + 1)
		a010Header("SQI","QI_CURRIC\QI_GRUPO",@aCols)
		aCols[1][Len(aHeader)+1] := .F.
		n:= 1
		oGet03:oBrowse:lDisablePaint := .F.
		oGet03:oBrowse:CallRefresh(.T.)
	EndIf

	cDesc 		:= SQ0->Q0_DESCRIC
	cAntGrupo	:= cGrupo
	M->QG_GRUPO := cGrupo	//Atualizar campo do SQG qdo. atualizar Grupo na pasta Qualificacoes
	oGrupo:Refresh(.T.)
Else
	cDesc 		:= ""
	cAntGrupo	:= ""
	M->QG_GRUPO := "	//Atualizar campo do SQG qdo. atualizar Grupo na pasta Qualificacoes
	oGrupo:Refresh(.T.)
Endif

RestArea(aSaveArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010Header³ Autor ³ Cristina Ogura       ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o array com os dados do aHeader                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010Header(ExpC1,ExpC2,ExpA1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                        			  ³±±
±±³          ³ ExpC1 = String com campos a ser omitido         			  ³±±
±±³          ³ ExpC2 = Array do acols                          			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010Header(cAlias,cString,aTmpCols)
Local nUsado	:= 0
Local aCampos	:= FWSX3Util():GetAllFields( cAlias , .T. )
Local nX 		:= 0
Local cTipo		:= ""

For nX := 1 To Len(aCampos)
	If X3USO(GetSX3Cache(aCampos[nX],"X3_USADO")) .And. cNivel >= GetSX3Cache(aCampos[nX], "X3_NIVEL") .And. ( ! Trim(aCampos[nX]) $ cString )
		nUsado := Ascan(aHeader,{|X| Trim(X[2]) == aCampos[nX]})
		cTipo := GetSX3Cache(aCampos[nX], "X3_TIPO")
		If cTipo == "C"
			aTmpCols[1][nUsado] := SPACE(TamSX3(aCampos[nX])[1])
		ElseIf cTipo == "N"
			aTmpCols[1][nUsado] := 0
		ElseIf cTipo == "D"
			aTmpCols[1][nUsado] := CTOD("  /  /  ")
		ElseIf cTipo == "M"
			aTmpCols[1][nUsado] := ""
		Else
			aTmpCols[1][nUsado] := .F.
		EndIf
		If GetSX3Cache(aCampos[nX], "X3_CONTEXT") == "V"
			aTmpCols[1][nUsado] := CriaVar(AllTrim(aCampos[nX]))
		EndIf
	EndIf
Next nX

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010Pesq ³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o listbox da pesquisa dos fat e grad da avaliacao    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010Pesq()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010Pesq(nEstou)
Local aSaveArea := GetArea()
Local aArray	:= {}
Local cCadastro	:= OemtoAnsi(STR0035) //"Selecione os Fatores da Avaliacao"
Local nPosFator	:= 0
Local nPosGrau	:= 0
Local nPosDFat 	:= 0
Local nPosRec	:= 0
Local nOpca		:= 0
Local nPos		:= 0
Local oDlg, oQual, oOk, oNo
Local ny		:= 0
Local nx		:= 0
Local cDesc		:= ""
Local cFator	:= ""
Local lExiste	:= .F.
Local lFlag		:= .F.
Local cVar		:= ""
Local bSet15
Local bSet24
Local aButtons := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

If nEstou # 4 .Or. nOpcao == 5 .Or. nOpcao == 2
	Return .T.
EndIf

If Empty(cGrupo)
	Help(" ",1,"A010VAZIO")					// Grupo nao pode estar vazio.
	Return .F.									// Digite um grupo
EndIf

oOk := LoadBitmap( GetResources(), "Enable" )
oNo := LoadBitmap( GetResources(), "LBNO" )

// Fatores Avaliacao
dbSelectArea("SQ1")
dbSetOrder(1)
If	dbSeek(xFilial("SQ1")+cGrupo)
	While !Eof() .And. xFilial("SQ1")+cGrupo == Q1_FILIAL+Q1_GRUPO

		cFator		:= SQ1->Q1_FATOR
		cSXBFator	:= cFator
		cDesc		:= SQ1->Q1_DESCSUM
		// Graduacao Avaliacao
		dbSelectArea("SQ2")
		dbSetOrder(1)
		If dbSeek(xFilial("SQ2")+SQ1->Q1_GRUPO+SQ1->Q1_FATOR)
			While !Eof() .And. xFilial("SQ2")+SQ1->Q1_GRUPO+SQ1->Q1_FATOR ==;
				Q2_FILIAL+Q2_GRUPO+Q2_FATOR

				AADD(aArray,{.F.,cFator,cDesc,SQ2->Q2_GRAU,SQ2->Q2_DESC,SQ1->Q1_FATOR})
				dbSkip()
			EndDo
		EndIf

		dbSelectArea("SQ1")
		dbSetOrder(1)
		dbSkip()
	EndDo
EndIf

// Montar o listbox com ja marcados
If !Empty(aCols[1][1]) .And. !Empty(aCols[1][2])
	A010Marcados(@aArray)
EndIf

If Len(aArray) == 0
	Help("",1,"A010PESQ")		// Nao existem fatores neste grupo para ser pesquisado
	RestArea(aSaveArea)
	Return .T.
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize( , .T., 50)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T., .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )


DEFINE MSDIALOG oDlg TITLE cCadastro From aAdvSize[7],0 To aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
	@ aObjSize[1,1],aObjSize[1,2] LISTBOX oQual VAR cVar FIELDS HEADER	" ",;
	OemToAnsi(STR0036),;	        //"Fator"
	OemToAnsi(STR0037),;           //"Descricao Fator"
	OemToAnsi(STR0038),;           //"Grau"
	OemToAnsi(STR0039) SIZE aObjSize[1,3],aObjSize[1,4] PIXEL //"Descricao Grau"
	oQual:SetArray(aArray)
	oQual:bLine := { || {If(	aArray[oQual:nAt,1],oOk,oNo),;
	aArray[oQual:nAt,2],;
	aArray[oQual:nAt,3],;
	aArray[oQual:nAt,4],;
	aArray[oQual:nAt,5]}}
	oQual:blDblClick := {|a,b,c,Self| a010Mark(a,b,oQual,@aArray) }

	bSet15 := {|| nOpca := 1,oDlg:End()}
	bSet24 := {|| oDlg:End()}
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bSet15,bSet24,Nil,aButtons) CENTERED

If nOpca == 1 			// Confirma
	nPosFator 	:= GdFieldPos("QI_FATOR")
   	nPosDFat 	:= GdFieldPos("QI_DESCFAT")
   	nPosGrau 	:= GdFieldPos("QI_GRAU")
	nPosDGra 	:= GdFieldPos("QI_DESCGRA")
	nPosRec		:= GdfieldPos("QI_REC_WT")
	nPos 		:= 0

	// Controle da 1a vez quando acols vazio
	If Empty(aCols[1][nPosFator]) .And. Empty(aCols[1][nPosGrau])
		For ny := 1 To Len(aArray)
			If aArray[ny][1]
				If nPos # 0
					aAdd(aCols, aClone(aCols[Len(aCols)]))
				EndIf
				nPos := IIf(nPos==0,1,Len(aCols))
				aCols[nPos][nPosFator] := aArray[ny][6]
				aCols[nPos][nPosGrau]  := aArray[ny][4]
				aCols[nPos][nPosDFat]  := aArray[ny][3]
				aCols[nPos][nPosDGra]  := aArray[ny][5]
				aCols[nPos][nPosRec ]  := 0
				aCols[nPos][Len(aCols[nPos])] := .F.
			EndIf
		Next ny
	Else
		// Marcar todos como deletado
		For ny := 1 To Len(aCols)
			aCols[ny][Len(aCols[ny])] := .T.
		Next ny

		For ny := 1 To Len(aArray)
			If aArray[ny][1]				// Marcado
				lFlag := .F.				// Marcar para incluir um novo registro
				For nx := 1 To Len(aCols)
					If aArray[ny][6] == aCols[nx][nPosFator]
						If	aArray[ny][4] == aCols[nx][nPosGrau]
							aCols[nx][Len(aCols[nx])] := .F.
							lFlag 	:= .T.
						Else
							lFlag 	:= .F.
						EndIf
						Exit
					EndIf
				Next nx
				If !lFlag
					aAdd(aCols, aClone(aCols[Len(aCols)]))
					nPos := Len(aCols)
					aCols[nPos][nPosFator] := aArray[ny][6]
					aCols[nPos][nPosGrau]  := aArray[ny][4]
					aCols[nPos][nPosDFat]  := aArray[ny][3]
					aCols[nPos][nPosDGra]  := aArray[ny][5]
					aCols[nPos][nPosRec ]  := 0
					aCols[nPos][Len(aCols[nPos])] := .F.
					lFlag:= .F.
				EndIf
			EndIf
		Next ny

		If lExiste
			Help(" ",1,"A010EXISTE")	// Existe fator do cargo igual ao cargo que esta sendo copiado.
		EndIf							// Verifique pois o fator foi marcado como deletado.
	EndIf
	n		:= 1
EndIf

oGet03:ForceRefresh(.T.)

RestArea(aSaveArea)

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A010Mark ³ Autor ³ Cristina Ogura        ³ Data ³12/08/96  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca e desmarca o campo do SX3                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 := Numero referente a linha                          ³±±
±±³          ³ ExpN2 := Numero referente a coluna                         ³±±
±±³          ³ ExpO1 := Objeto em uso                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A010Mark(nRow,nCol,oUso,aArray)
Local nx	:= 0
Local lFaz	:= .T.
Local cFator:= aArray[oUso:nAt][6]

For nx := 1 To Len(aArray)
	If cFator == aArray[nx][6] .And. aArray[nx][1] .And. nx#oUso:nAt
		Help(" ",1,"A010Marca")		// Este fator ja foi selecionado.
		lFaz:= .F.
		Exit
	EndIf
Next nx

If lFaz
	aArray[oUso:nAt,1] := !aArray[oUso:nAt,1]
	oUso:Refresh()
EndIf

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010Marcados  ³ Autor ³ Cristina Ogura   ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o array com os itens que ja estao marcados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010Marcados(ExpA1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 := Array com todos os itens                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010Marcados(aArray)
Local aSaveArea := GetArea()
Local nx		:= 0
Local ny		:= 0
Local nPosFator	:= 0
Local nPosGrau	:= 0

nPosFator := GdFieldPos("QI_FATOR")
nPosGrau  := GdFieldPos("QI_GRAU")

For ny := 1 To Len(aCols)
	For nx := 1 To Len(aArray)
		If aCols[ny][nPosFator] == aArray[nx][6] .And.;
			aCols[ny][nPosGrau]  == aArray[nx][4] .And.;
			!aCols[ny][Len(aCols[ny])]
			aArray[nx][1] := .T.
			Exit
		EndIf
	Next nx
Next ny

RestArea(aSaveArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010Grau ³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o grau digitado                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010Grau()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010Grau()
Local aSaveArea := GetArea()
Local nPosFator	:= 0
Local lRet		:= .T.

nPosFator := GdFieldPos("QI_FATOR")

dbSelectArea("SQ2")
dbSetOrder(1)
If !dbSeek(xFilial("SQ2")+cGrupo+aCols[n][nPosFator]+&(ReadVar()))
	Help(" ",1,"A010Grau")		// Este grau nao pertence a este fator e grupo
	lRet := .F.
EndIf

RestArea(aSaveArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A010Fator³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o fator digitado                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A010Fator()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A010Fator()
Local ny 		:= 0
Local aSaveArea := GetArea()
Local nPosFator	:= 0

dbSelectArea("SQ1")
dbSetOrder(1)
If !dbSeek(xFilial("SQ1")+cGrupo+&(ReadVar()))
	Help(" ",1,"A010FAT01")						// Codigo do Fator invalido
	RestArea(aSaveArea)
	Return .F.
EndIf

nPosFator := GdFieldPos("QI_FATOR")

For ny := 1 to Len(aCols)
	If	aCols[ny][nPosFator] == &(ReadVar()) .And.;
		n # ny .And. !aCols[ny][Len(aCols[ny])]
		Help(" ",1,"A010FAT02")
		RestArea(aSaveArea)
		Return .F.
	EndIf
Next ny

cSXBFator	:= aCols[n][nPosFator]

RestArea(aSaveArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Rs010Desc ³ Autor ³ Cristina Ogura        ³ Data ³ 27.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Traz descricao do grau e fator na Qualificacao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³RS010DESC()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ RSPA010  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Rs010Desc(cAlias,cCpoRet,cCodPesq,lRelac)
Local aSaveArea := GetArea()
Local cPesq		:= 0
Local nPosHead	:= 0
Local nPos		:= 0
Local cRet		:= ""
Local lRet
Local cContFat 	:= ""

Private cConteudo := ""
cPesq := If (lRelac,cCodPesq,ReadVar())

If IsInGetDados( { cPesq } )
	cConteudo	:= GDFieldGet(cPesq, n)
Else
	If ! lRelac
  		cConteudo := &(ReadVar())
    Else
  	 	cConteudo := &("SQI->"+cPesq)
   	EndIf
EndIf

If "FATOR"$ AllTrim(cPesq)
	If lRelac .And. Empty(cConteudo)
		cConteudo:= SQI->QI_FATOR
	EndIf
	If !Empty(cConteudo)
		cRet 		:= TrmDesc(cAlias,cGrupo+cConteudo,"SQ1->Q1_DESCSUM")
		cSXBFator	:= cConteudo
	Else
		cRet := CriaVar("Q1_DESCSUM")
	EndIf
ElseIf "GRAU"$ AllTrim(cPesq)
	If lRelac .And. Empty(cConteudo)
		cConteudo := SQI->QI_GRAU
	EndIf
	If !Empty(cConteudo)
		If !lRelac
			nPosHead := GdFieldPos("QI_FATOR")
			If nPosHead > 0
			   	cContFat := aCols[n,nPosHead]
			Endif
		EndIf
		cRet := TrmDesc(cAlias,(cGrupo+If(lRelac,SQI->QI_FATOR,cContFat)+cConteudo),"SQ2->Q2_DESC")
	Else
		cRet := CriaVar("Q2_DESC")
	EndIf
EndIf

If ! lRelac
	//--Igualar no Acols o Descricao
	nPos := GdFieldPos(cCpoRet)
	If nPos > 0
		aCols[n,nPos] := cRet
		lRet := .T.
	EndIf
Else
	lRet := cRet
EndIf

RestArea(aSaveArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Rs010Grau ³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o grau digitado				                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Rs010Grau()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³RSPA010  													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Rs010Grau()
Local cGrau 	:= M->QI_GRAU
Local nPosFator := GdFieldPos("QI_FATOR")

If Empty(cGrau)
	cGrau := &(ReadVar())
EndIf

dbSelectArea("SQ2")
dbSetOrder(1)
If !dbSeek(xFilial("SQ2")+cGrupo+aCols[n][nPosFator]+cGrau)
	Help("",1,"TRA020GRAU")		// Grau nao cadastrado para este Grupo/Fator
	Return .F.
EndIf

Return .T.

Function fBotao(oFolder)
//--Botaão para parar na Enchoice
DEFINE SBUTTON oBtnF FROM 5000,5000  TYPE  4 ENABLE OF oFolder:aDialogs[1]
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Rs010VerF ³ Autor ³ Cristina Ogura        ³ Data ³ 13.11.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se existe todos os fatores no SQV.		   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Rs010VerF()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³RSPA010  													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs010VerF(lRet,cAuxFil,cAuxCur)
Local aArea	:= GetArea()
Local aSQI	:= {}

cAuxFil	:= If(xFilial("SQI")=Space(FWGETTAMFILIAL),Space(FWGETTAMFILIAL),cAuxFil)

dbSelectArea("SQI")
dbSetOrder(1)
If 	dbSeek(cAuxFil+cAuxCur)
	ProcRegua(SQI->(Reccount()))
	While !Eof() .And. cAuxFil+cAuxCur == SQI->QI_FILIAL+SQI->QI_CURRIC
		IncProc()
	 	Aadd(aSQI,{SQI->QI_FILIAL,SQI->QI_FATOR,SQI->QI_GRAU})
	 	dbSkip()
	EndDo
EndIf

If !FVerFatG(aSQI)
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Rs010Desc2³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 01/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Descricao de Campos virtuais			                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Rs010Desc2(nOpc)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³RSPA010  													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Rs010Desc2(nOpc)
Local aSaveArea := GetArea()
Local lRet		:= .T.
Local cCod
Local cDescRet
Local cAlias
Local nPosDesc
Local cEscala := ""
Local cIdiom := FWRetIdiom() //Retorna Idioma Atual

If nOpc == 1
 	cCod 	:= M->QM_CURSO
	cAlias	:= "SQT"
	cDescRet:= "SQT->QT_DESCRIC"
	nPosDesc:= GdFieldPos("QM_DCURSO")

ElseIf nOpc == 2
	cCod := M->QM_CDCURSO
	cAlias	:= "RA1"
	cDescRet:= "RA1->RA1_DESC"
	nPosDesc:= GdFieldPos("QM_DCURFUN")

ElseIf nOpc == 3
	cCod := M->QM_CDENTID
	cAlias	:= "RA0"
	cDescRet:= "RA0->RA0_DESC"
	nPosDesc:= GdFieldPos("QM_DENTFUN")

ElseIf nOpc == 4
	cEscala := Rs010Nivel()
	cCod := cEscala + M->QM_NIVEL

	cAlias	:= "RBL"
	cDescRet:= "RBL->RBL_DESCRI"
	nPosDesc:= GdFieldPos("QM_DNIVEL")
EndIf

If cIdiom == "es" //SPANISH
	cOutros := "OTROS"
Elseif cIdiom == 'en' //ENGLISH
	cOutros := "OTHERS"
Else
	cOutros:= "OUTROS"
Endif


dbSelectArea(cAlias)
dbSetOrder(1)
If dbSeek(xFilial(cAlias)+cCod)
	aRetCampo:= ExisteCampo("QM_DCURSO",.F.,.F.,.T.)
	If cDescRet == "SQT->QT_DESCRIC"
		If cOutros <> allTrim(&cDescRet)  //"OUTROS"
			aCols[n][nPosDesc] := &cDescRet
		ElseIf aRetCampo[2] == 0
			aCols[n][nPosDesc] := SQM->QM_DCURSO
		Else
			aCols[n][nPosDesc] := ""
		Endif
	Elseif cDescRet # "SQT->QT_DESCRIC"
		aCols[n][nPosDesc] := &cDescRet
	Endif
Else
	Aviso(STR0047,STR0048,{"OK"})	//"Atencao"#"Codigo nao cadastrado."
	lRet := .F.
EndIf

RestArea(aSaveArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Rs010Init ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 21/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Descricao de Campos virtuais			                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Rs010Init(nOpc)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³RSPA010  	- X3_RELACAO									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Rs010Init(nOpc)
Local aSaveArea := GetArea()
Local cCod		:= ""
Local cDesc 	:= ""
Local cDescRet	:= ""
Local cAlias 	:= ""
Local cEscala 	:= ""

If nOpc == 1
	cEscala := Rs010Nivel(SQM->QM_CURSO)
	cCod := cEscala + SQM->QM_NIVEL

	cAlias	:= "RBL"
	cDescRet:= "RBL->RBL_DESCRI"
EndIf

dbSelectArea(cAlias)
dbSetOrder(1)
If dbSeek(xFilial(cAlias)+cCod)
	cDesc := &cDescRet
EndIf

RestArea(aSaveArea)


Return cDesc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Rsp010Leg     ³ Autor ³Emerson Grassi    ³ Data ³ 07/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Aciona Legenda de cores da Mbrowse.				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Rsp010Leg()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rsp010Leg()

Local aSaveArea	:= GetArea()
Local aCores 	:= {}
Local aCor		:= {}

aCores  := { 	{ "001",'BR_VERDE' 		},;
				{ "   ",'BR_VERDE' 		},;
				{ "002",'DISABLE' 		},;
				{ "003",'BR_AMARELO'	},;
				{ "004",'BR_CINZA'		},;
				{ "005",'BR_LARANJA'	},;
				{ "006",'BR_MARROM' 	},;
				{ "007",'BR_PINK' 		},;
				{ "FUN",'BR_AZUL' 		}}

If ( lRspAltLeg )
	aCores := ExecBlock("RspAltLeg" , .F. , .F. , { {} , aCores } )
EndIf
dbSelectArea("SX5")
dbSetOrder(1)
dbSeek(xFilial("SX5")+"R3")
While !Eof() .And. SX5->X5_TABELA == "R3"
	nX := Ascan(aCores, {|x| x[1] == ALLTRIM(SX5->X5_CHAVE)} )
	If nX > 0
		Aadd(aCor,aCores[nX][2])
	Else
		Aadd(aCor,"BR_PRETO")
	EndIf
	dbSkip()
EndDo

TrmLegenda(0,"R3",aCor)

RestArea(aSaveArea)

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Rsp010Vis     ³ Autor ³Emerson Grassi    ³ Data ³ 13/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza Curriculo atraves da Pesquisa.			          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Rsp010Vis()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rsp010Vis( cAlias , nReg )
Return( Rspa010( cAlias , nReg , 2 ) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RsBoxFont     ³ Autor ³Emerson Grassi    ³ Data ³ 10/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna box de opcoes com as Fontes de Recrutamento.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RsBoxFont()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RsBoxFont()

Local cOpcBox

If Empty(SX3->X3_F3) //Dicionario antigo
	cOpcBox := ( "1=" + OemToAnsi(STR0054) + ";" )	//"Indicação de funcionário"
	cOpcBox += ( "2=" + OemToAnsi(STR0055) + ";" )	//"Indicaçãao de ex-funcionário"
	cOpcBox += ( "3=" + OemToAnsi(STR0056) + ";" )	//"É ex-funcionário"
	cOpcBox += ( "4=" + OemToAnsi(STR0057) + ";" )	//"Indicação de cliente"
	cOpcBox += ( "5=" + OemToAnsi(STR0058) + ";" )	//"Indicação de consultoria"
	cOpcBox += ( "6=" + OemToAnsi(STR0059) + ";" )	//"Anúncio em jornal"
	cOpcBox += ( "7=" + OemToAnsi(STR0060) + ";" )	//"Anúncio em revista especializada"
	cOpcBox += ( "8=" + OemToAnsi(STR0061) + ";" )	//"Anúncio ou feira em Universidades"
	cOpcBox += ( "9=" + OemToAnsi(STR0062) + ";" )	//"Sites de recrutamento"
	cOpcBox += ( "A=" + OemToAnsi(STR0063) + ";" )	//"Espontâneo"
	cOpcBox += ( "B=" + OemToAnsi(STR0064))			//"Outro"
EndIf

Return( cOpcBox )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Rs010Nivel    ³ Autor ³Emerson Grassi    ³ Data ³ 10/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna box de opcoes de Nivel do curso.				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Rs010Nivel()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA010 / CSAA130  - Retorna Escala para o Campo QM_NIVEL  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs010Nivel(cCurso)

Local cTipo		:= ""
Local cEscala	:= Space(2)

Default cCurso	:= GdFieldGet("QM_CURSO")

If !Empty(cCurso)
	dbSelectArea("SQT")
	dbSetOrder(1)
	If dbSeek(xFilial("SQT")+cCurso)
		cTipo 	:= StrZero(Val(SQT->QT_TIPO),3)
		cEscala := Fdesc("SQX", cTipo, "QX_NIVEL ")
	EndIf
Elseif (type("cTpCurso") != "U")
	cEscala := Fdesc("SQX", cTpCurso, "QX_NIVEL ")
EndIf

Return( cEscala )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³RSP010Fill³ Autor ³ Joeudo Santana	    ³ Data ³ 12/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Montagem das Getdados aHeader,aCols com adequaçã à		  ³±±
±±³		     ³ funcionalidade do Walk Trhu                     			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nPasta, nOpcx										      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function RSP010Fill(nPasta,nOpcx)

Local nx
Local cChave	:=""

nx:=If(Type( "n" ) == "U",NIL,n )

If nOpcx <> 3 .OR. lExecAuto	// Diferente de Inclusao
	cChave	:= SQG->QG_FILIAL+SQG->QG_CURRIC
Else
	cChave	:= M->QG_FILIAL+M->QG_CURRIC
EndIf

n:= Nil

 	Do Case
		Case nPasta == 2
		//	Historico Profissional
			cAlias		:="SQL"						 						//2-cAlias - area a ser utilizada;
			nOrder		:=1													//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
   			cSeekKey	:=cChave											//4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
			bSeekWhile	:={|| SQL->QL_FILIAL + SQL->QL_CURRIC}				//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
			aNoFields	:= {"QL_CURRIC"}									//7-aNoFields - array contendo os campos que não estarão no aHeader;

	    Case  nPasta == 3
	    // Cursos / Escolaridade
		   	cAlias		:= "SQM"				 							//2-cAlias - area a ser utilizada;
			nOrder		:= 1  												//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
			cSeekKey	:= cChave							 				//4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
			bSeekWhile	:= {|| SQM->QM_FILIAL + SQM->QM_CURRIC}			//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
			aNoFields	:= {"QM_CURRIC"}
        Case  nPasta == 4
        // Qualificacoes do Curriculo
         	cAlias		:= "SQI"						 				 	//2-cAlias - area a ser utilizada;
			nOrder		:= 1  												//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
			cSeekKey	:= cChave											//4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
			bSeekWhile	:= {|| SQI->QI_FILIAL + SQI->QI_CURRIC}			//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
			aNoFields	:= {"QI_CURRIC","QI_GRUPO"}							//7-aNoFields - array contendo os campos que não estarão no aHeader;	//aHeader	:= {}
            bCriaVar	:= {| cField | CriaVarRh( cField ) }
        Case  nPasta == 5 .or. nPasta == 6
        //Avaliacao do Curriculo
         	cAlias		:= "SQR" 				 							//2-cAlias - area a ser utilizada;
			nOrder		:= 1  												//3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
			cSeekKey	:= xFilial("SQR")+SQG->QG_CURRIC					//4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
			bSeekWhile	:= {|| SQR->QR_FILIAL + SQR->QR_CURRIC} 			//5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
			aNoFields	:= If (nPasta == 5,{"QR_CURRIC","QR_MAT"},{"QR_CURRIC","QR_MAT","QR_TOPICO"})
		Case nPasta == 7
			cAlias		:= "SM6"
			nOrder		:= 1
			cSeekKey	:= xFilial("SM6")+SQG->QG_CURRIC
			bSeekWhile	:= {|| SM6->SM6_FILIAL + SM6->SM6_CURRIC }
			aNoFields	:= {"SM6_FILIAL"}
	EndCase

	FillGetDados(nOpcx					,; //1-nOpcx - número correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
				 cAlias					,; //2-cAlias - area a ser utilizada;
				 nOrder					,; //3-nOrder - ordem correspondente a chave de indice para preencher o  acols;
				 cSeekKey				,; //4-cSeekKey - chave utilizada no posicionamento da area para preencher o acols;
			 	 bSeekWhile				,; //5-bSeekWhile - bloco contendo a expressão a ser comparada com cSeekKey na condição  do While.
				 NIL					,; //6-uSeekFor - pode ser utilizados de duas maneiras:1- bloco-de-código, condição a ser utilizado para executar o Loop no While;2º - array bi-dimensional contendo N.. condições, em que o 1º elemento é o bloco condicional, o 2º é bloco a ser executado se verdadeiro e o 3º é bloco a ser executado se falso, exemplo {{bCondicao1, bTrue1, bFalse1}, {bCondicao2, bTrue2, bFalse2}.. bCondicaoN, bTrueN, bFalseN};
				 aNoFields				,; //7-aNoFields - array contendo os campos que não estarão no aHeader;
				 NIL					,; //8-aYesFields - array contendo somente os campos que estarão no aHeader;
				 NIL					,; //9-lOnlyYes - se verdadeiro, exibe apenas os campos de usuário;
				 NIL					,; //10-cQuery - query a ser executada para preencher o acols(Obs. Nao pode haver MEMO);
				 NIL					,;  //11-bMontCols - bloco contendo função especifica para preencher o aCols; Exmplo:{|| MontaAcols(cAlias)}
				 nOpcx==3 				,; //12-lEmpty       - Caso True ( default é false ), inicializa o aCols com somente uma linha em branco ( como exemplo na inclusão).
				 NIL					,; //13-aHeaderAux   - Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
				 NIL					,; //14-aColsAux     - Caso necessite tratar o aheader e acols como variáveis locais ( várias getdados por exemplo; uso da MSNewgetdados )
				 NIL					,; //15-bAfterAcols  - Bloco de código a ser executado após a inclusão de uma linha no Acols
				 NIL					,; //16-bBeforeCols  - bloco de código contendo expressão para sair do While, é executado antes de inserir nova linha no aCols
				 NIL					,; //17-bAfterHeader - bloco de código a ser executado após o preenchimento do aheader com os campos padrão e antes de incluir os campos reservados para o WalkThru. Ex: {|aHeader| AlterHeader(aHeader) }
				 NIL					,; //18-cAliasQry    - Informe o nome do alias a ser usado na área aberta por cQuery, opcionalmente.
				 NIL					)  //19-bCriaVar     - Bloco que será utilizado na hora de recuperar o valor do campo no loop de preenchimento do aCols. Formato: {| cField | CriaVarRh( cField ) }

// Posiciona no final do arquivo para que o Inicialiazador padrao apresente os campos em branco
dbSelectArea(cAlias)
dbGoBottom()
dbSkip()
n:= nx

Return  {aClone(aHeader), aClone(aCols), 1}

Static Function MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aOfusca := If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1]Acesso; [2]Ofusca
Local aRotina := {	{ STR0001,"AxPesqui" , 0 , 1,,.F.},	;	//"Pesquisa"
					{ STR0002,"RSP010Rot", 0 , 2},		;	//"Visual"
					{ STR0003,"RSP010Rot", 0 , 3},		;	//"Inclui"
					{ STR0004,"RSP010Rot", 0 , 4},		;	//"Altera"
					{ STR0005,"RSP010Rot", 0 , 5},		;	//"Exclui"
					{ STR0042,"RSP010Exc", 0 , 5},		;	//"Excl.&Grupo"
					{ STR0082,"RSP010Sen", 0 , 4},		;	//"Alt. senha"
					{ STR0041,"RSP010Leg",	0 , 2,,.F.}	}	//"Legenda"

	If FindFunction("fRhBanConh") .And. aOfusca[2]
		aAdd(aRotina, {STR0068, "fRhBanConh", 0, 4, , .F.})
	Else
		aAdd(aRotina, {STR0068, "MsDocument", 0, 4})		// "Conhecimento"
	EndIf

Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ChkDtNa	³ Autor ³ Mauricio MR        	³ Data ³ 08.07.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica Data Nascimento  								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
FUNCTION SQGVLDDtNa(dDtBas, dDtNas)
Local lRet  := .T.

If (dDtNas >= dDtBas)
	Help(" ",1,"DATINVALID")
	lRet:= .F.

Endif


Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção   QM_CURSOWHENº Autor:| Érika              º Data ³  04/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para controle do "WHEN" no SX3, campo QM_DCURSO.     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QM_CURSOWHEN()

Local lRet:= .F.
Local nPos:= GdFieldPos("QM_CURSO")

If nPos > 0
	If allTrim(fDesc("SQT", aCols[n][nPos], "QT_DESCRIC")) == STR0069  //outros
		lRet:= .T.
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³RSPA010CPFº Autor: Raphael Zampieri    º Data ³  12/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para verificar se o CPF digitado so possui caracteresº±±
±±º          ³de valor zero.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function RSPA010CPF(cCicChk,cCicVal)
Local lRet:= .T.
Local nSomaCic := 0
Local nI

If ( !Empty(AllTrim(cCicChk)) )
	For nI := 1 To Len(cCicChk)
		nSomaCic :=	nSomaCic + Val(SubStr(cCicChk,nI,01))
	Next nI

	//--- Verifica se o CPF so possui caracteres de valor zero
	If cPaisLoc == "BRA" .And. nSomaCic == 0
		Help(" ",1,"CPFINVALID")
		lRet := .F.
	//--- Se existir o ponto de entrada, realiza a validacao do usuario para o CPF
	ElseIf lRspChkCPF
		lRet := ExecBlock( "RspChkCPF" , .F., .F., { cCicChk } )
	EndIf

	//--- Realiza a validacao do sistema para o CPF
	If ( lRet, 	lRet := &cCicVal, )
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RspA010ValPE³ Autor ³ Allyson Mesashi       ³ Data ³ 22/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao ponto entrada de Inclusao/Alteracao de Curriculos   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rspa010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function RspA010ValPE()

Local lRet	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para checar os dados de inclusao/alteracao  |
//³ de curiculos. O retorno deve ser logico (.T. ou .F.)         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRs010ValPE
	lRet := ExecBlock( "Rs010ValPE", .F., .F. )
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fNomeRFC    ³ Autor ³ Marcelo Silveira      ³ Data ³ 24/02/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preenchimento automatico do campo Nome.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rspa010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fNomeRFC()

If Alltrim(ReadVar() ) $ "M->QG_PRINOME#M->QG_SECNOME#M->QG_PRISOBR#M->QG_SECSOBR"

	M->QG_NOME := ALLTRIM(M->QG_PRINOME)+" "+ALLTRIM(M->QG_SECNOME)+" "+ALLTRIM(M->QG_PRISOBR)+ " "+ALLTRIM(M->QG_SECSOBR)

EndIf

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MsgAnoCheg	 ³ Autor ³ Alceu Pereira    ³ Data ³ 20.12.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mensagens de validacao             						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MsgAnoCheg()

Local cDescNatu := ''
Local cDescNaci := ''
Local lRet 	    := .T.
Local cNaciona  :="10"

If cPaisLoc == "BOL"
	cNaciona := "22"
EndIf

IF ( ReadVar() == "M->QG_NATURAL" ) .OR. ( ReadVar() == "M->QG_NACIONA" ) .OR. ( ReadVar() == "M->QG_ANOCHEG" )
	If AllTrim(M->QG_NATURAL) == "EX" .AND. AllTrim(M->QG_NACIONA) != cNaciona .AND.  AllTrim(M->QG_NACIONA) != ''
		MsgAlert(STR0074, STR0047)
	ElseIf AllTrim(M->QG_NATURAL) == "EX" .AND. AllTrim(M->QG_NACIONA) == cNaciona
		cDescNatu := fDesc("SX5"  ,"12"+"EX"   ,"X5DESCRI()" ,13     ,SRA->RA_FILIAL)
		cDescNaci := fDesc("SX5"  ,"34"+cNaciona   ,"X5DESCRI()" ,13     ,SRA->RA_FILIAL)
		MsgAlert( STR0070 +cDescNatu+ STR0071 +cDescNaci ,STR0047) //Para naturalidade +____+ não e coerente ter a nacionalidade + _____ + , Atencao.
	ElseIf AllTrim(M->QG_NATURAL) != "EX" .AND. AllTrim(M->QG_NACIONA) != cNaciona  .AND. Alltrim(M->QG_NATURAL) != '' .AND. AllTrim(M->QG_NACIONA) != ''
		cDescNatu := fDesc("SX5"  ,"12"+"EX"   ,"X5DESCRI()" ,13     ,SRA->RA_FILIAL)
		cDescNaci := fDesc("SX5"  ,"34"+cNaciona   ,"X5DESCRI()" ,13     ,SRA->RA_FILIAL)
		MsgAlert(STR0072 +cDescNatu+ STR0073 +cDescNaci ,STR0047) 	// Para a naturalidade diferente de +_____+ seria mais coerente ter no campo nacionalidade a nacionalidade +______+, Atencao.
	Elseif AllTrim(M->QG_NATURAL) != "EX" .AND. AllTrim(M->QG_NACIONA) == cNaciona .AND. AllTrim( M->QG_ANOCHEG) != ''
		cDescNatu := fDesc("SX5"  ,"12"+"EX"   ,"X5DESCRI()" ,13     ,SRA->RA_FILIAL)
		cDescNaci := fDesc("SX5"  ,"34"+cNaciona ,"X5DESCRI()" ,13     ,SRA->RA_FILIAL)
		MsgAlert( STR0070 +cDescNatu+ STR0075 +cDescNaci+ STR0076 , STR0047)
	Endif
ENDIF

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³DtNasRFC  ³ Autor ³ Claudinei Soares    	³ Data ³ 22.12.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica Data Nascimento conforme o CFP para o Mexico	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
FUNCTION DtNasRFC(dDtRfc, dDtNas)
Local lRet  := .T.
Local dRFC
Local cAno
Local cMes
Local cDia

cAno := Substr(dDtRfc, 5,2)
cMes := Substr(dDtRfc, 7,2)
cDIA := Substr(dDtRfc, 9,2)

dRFC := ctod(cDia+"/"+cMes+"/"+cAno)

If (dRFC <> dDtNas)
	If !(MsgYesNo(OemToAnsi(STR0077), OemToAnsi(STR0078)))
		Return(.F.)
		lRet:= .F.
	Else
		Return
	Endif

Endif

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  RSP010Sen     ºAutor  ³Allyson M        º Data ³ 19/07/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Opcao para troca de senha.					              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RSP010Sen( cAlias , nRec , nOpc )

Local aSvKeys		:= GetKeys()
Local aArea 		:= GetArea()
Local aAreaSQG		:= SQG->( GetArea() )
Local cSvcCadastro  := cCadastro
Local nOpca			:= 0
Local aRetcoords	:= {}

Local cSenhaAtu		:= SQG->QG_SENHA
Local cSenhaNova	:= Space(6)
Local cSenhaConf	:= Space(6)

aRetcoords := RetCoords(4,3,50,15,1)
DEFINE MSDIALOG oDlg1  FROM 0,0 TO 150,430 TITLE OemToAnsi( STR0006 ) PIXEL //"Curriculos" 10,20 TO 26,80

@ aRetcoords[02][1], aRetcoords[02][2] SAY STR0083 PIXEL		//"Senha Antiga: "
@ aRetcoords[03][1], aRetcoords[03][2] SAY cSenhaAtu PIXEL SIZE 50,7

@ aRetcoords[06][1], aRetcoords[06][2] SAY STR0084 PIXEL		//"Senha Atual: "
@ aRetcoords[07][1], aRetcoords[07][2] MSGET cSenhaNova PASSWORD PIXEL SIZE 50,7

@ aRetcoords[10][1], aRetcoords[10][2] SAY STR0085 PIXEL		//"Confirma Senha: "
@ aRetcoords[11][1], aRetcoords[11][2] MSGET cSenhaConf PASSWORD PIXEL SIZE 50,7

ACTIVATE MSDIALOG oDlg1 CENTERED ON INIT (EnchoiceBar(oDlg1, {|| nOpca:= 1, If( SQGVldSenha(cSenhaNova,cSenhaConf),oDlg1:End(),Nil ) },{||nOpca:=2,oDlg1:End()}))

If nOpca == 1
	cSenha := cSenhaNova
	SQG->( RecLock("SQG",.F.) )
		SQG->QG_SENHA := cSenha
	MsUnlock()

EndIf

cCadastro := cSvcCadastro
RestArea( aAreaSQG )
RestArea( aArea )

RestKeys( aSvKeys , .T. )

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  SQGVldSenha   ºAutor  ³Allyson M        º Data ³ 19/07/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao da troca de senha.					              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SQGVldSenha(cSenha1, cSenha2)
Local lOk	:= .F.

If(cSenha1 == cSenha2) .And. !Empty(cSenha1)
	lOk := .T.
Else
	Aviso(STR0086,STR0087,{"Ok"}) //"Aviso"###"Senha em branco ou Confirmacao diferente da Senha."
EndIf

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ValidCargo³Autor³Gabriel de Souza Almeida³ Data ³ 23/03/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valid do campo QG_CODFUN                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ValidCargo(cCodCar)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodCar = Codigo do cargo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ValidCargo(cCodCar)
Local lRet := .T.
Local aArea := SQ3->(GetArea())

dbSelectArea("SQ3")
dbSetOrder(1)

If !Empty(cCodCar)
	If SQ3->(DbSeek(xFilial("SQ3")+cCodCar))
		M->QG_DESCFUN := SQ3->Q3_DESCSUM
	ElseIf Empty(M->QG_CODFUN) .AND. SQG->(DbSeek(xFilial("SQG")+M->QG_CURRIC))
		M->QG_DESCFUN := SQG->QG_DESCFUN
	Else
		lRet := .F.
		Help(" ",1,"REGNOIS")
	EndIf
Endif
RestArea(aArea)

Return lRet

/*
{Protheus.doc} A010AtuSr6
Carga do LISTBOX
@author Leandro Drumond
@since 31/05/2016
@version 1.0
*/
Static Function A010AtuSr6(nLinha)
Local aArea		:= GetArea()
Local cKeySR6	:= xFilial("RS6") + aLbx2[nLinha,1]
Local cSeq		:= ""
Local nPos		:= 0
Local nX		:= 0
Local lPanel 	:= Type("oPanelC") == "O"

DbSelectArea("RS6")
DbSeek(cKeySR6)
aListaSM6 := {}
If RS6->RS6_INTERN == "1"
	lRS6Mult := RS6->RS6_RESP == "2"
	If RS6->RS6_RESP == "3"
		aListaSM6 := {{.F.,""}}
		If (nPos:= aScan(aGrvSM6,{|x|x[1] == RS6->RS6_CODIGO })) > 0
			cGetSM6 := aGrvSM6[nPos][2]
		Else
			cGetSM6   := Space(300)
		EndIf
		If lPanel
			oPanelC:lVisible := .F.
			oPanelG:lVisible := .T.
			oGetSay:Refresh()
		EndIf
	Else
		cGetSM6   := Space(300)
		DbSelectArea("RS7")
		DbSeek(xFilial("RS7")+RS6->RS6_CODIGO)
		aListaSM6 := {}

		cSeq := ""
		If (nPos:= aScan(aGrvSM6,{|x|x[1] == RS6->RS6_CODIGO })) > 0
			For nX := 1 to Len(aGrvSM6[nPos][3])
				cSeq += aGrvSM6[nPos][3][nX] + "*"
			Next nX
		EndIf

		While RS7->(!Eof() .and. RS7->RS7_FILIAL + RS7->RS7_TIPO == xFilial("RS7") + RS6->RS6_CODIGO)
			aAdd(aListaSM6, {If(RS7->RS7_SEQ $ cSeq, .T.,.F.), AllTrim(RS7->RS7_DESC)})
			RS7->(DbSkip())
		EndDo

		If lPanel
			oListSM6:SetArray(aListaSM6)
			oListSM6:bLine := {||     {Iif(aListaSM6[oListSM6:nAt,1],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )),aListaSM6[oListSM6:nAt,2]}}
			oListSM6:Refresh()
			oPanelG:lVisible := .F.
			oPanelC:lVisible := .T.
			oGetSay:Refresh()
		EndIf
	EndIf
EndIf
RestArea(aArea)

Return .T.

/*
{Protheus.doc} A010CarSm6
Carga do array com dados para gravar da SM6
@author Leandro Drumond
@since 31/05/2016
@version 1.0
*/
Static Function A010CarSm6()
Local nX		:= 0
Local nPosSM6	:= aScan(aGrvSM6,{|x|x[1] == aLbx2[oLbx2:nAt,1] })
Local nPosAux	:= 0
Local cSeq		:= StrZero(oListSM6:nAt,3)

aListaSM6[oListSM6:nAt,1] := !aListaSM6[oListSM6:nAt,1]

If aListaSM6[oListSM6:nAt,1]
	If lRS6Mult
		aAdd(aGrvSM6[nPosSM6][3],cSeq)
	Else
		aGrvSM6[nPosSM6][3][1] := cSeq
	EndIf
	aGrvSM6[nPosSM6][4] := .T.
Else
	If lRS6Mult
		If (nPosAux := aScan(aGrvSM6[nPosSM6][3],{|x| x == cSeq })) > 0
			aGrvSM6[nPosSM6][3][nPosAux] := ""
		EndIf
	Else
		aGrvSM6[nPosSM6][3][1] := ""
	EndIf
	aGrvSM6[nPosSM6][4] := .T.
EndIf

If aListaSM6[oListSM6:nAt,1] .and. !lRS6Mult
	For nX := 1 to Len(aListaSM6)
		If nX <> oListSM6:nAt
			aListaSM6[nX,1] := .F.
		EndIf
	Next nX
EndIf

Return .T.

/*
{Protheus.doc} fCargaSM6
Carrega informações da SM6
@author Leandro Drumond
@since 31/05/2016
@version 1.0
*/
Static Function fCargaSM6()
Local cSeq	:= ""
Local aSeq	:= {""}

If SM6->(DbSeek(xFilial("SM6") + SQG->QG_CURRIC + RS6->RS6_CODIGO))
	cSeq := SM6->M6_ALTERNA
	If Len(cSeq) > 0
		aSeq := StrTokArr2(AllTrim(cSeq),"*",.T.)
	EndIf
	aAdd(aGrvSM6,{RS6->RS6_CODIGO,Padr(SM6->M6_RESP,300),aSeq,.F.})
Else
	aAdd(aGrvSM6,{RS6->RS6_CODIGO,Space(300),aSeq,.F.})
EndIf

Return .T.

/*
{Protheus.doc} fCargaSM6
Grava informações na SM6
@author Leandro Drumond
@since 31/05/2016
@version 1.0
*/
Static Function A010AtuSM6()
Local aArea		:= GetArea()
Local nY 		:= 0
Local nX		:= 0
Local cSeq		:= ""

DbSelectArea("SM6")

If lExecAuto .AND. nOpcao == 5 //delete
	While Dbseek(xFilial("SM6") + SQG->QG_CURRIC)
		RecLock("SM6",.F.,.T.)
		DbDelete()
		MsUnLock()
		SM6->(DbSkip())
	EndDo

Else
	For nX := 1 to Len(aGrvSM6)
		If !aGrvSM6[nX,4] //Não houve alteração
			Loop
		EndIf
		cSeq	:= ""
		If Dbseek(xFilial("SM6") + SQG->QG_CURRIC + aGrvSM6[nX,1])
			RecLock("SM6",.F.)
		Else
			RecLock("SM6",.T.)
			SM6->M6_FILIAL := xFilial("SM6")
			SM6->M6_CURRIC := SQG->QG_CURRIC
			SM6->M6_TIPO   := aGrvSM6[nX,1]
		EndIf

		For nY := 1 to Len(aGrvSM6[nX,3])
			If !Empty(aGrvSM6[nX,3,nY])
				If Len(cSeq) > 0
					cSeq += "*"
				EndIf
				cSeq += aGrvSM6[nX,3,nY]
			EndIf
		Next nY
		SM6->M6_RESP  	:= AllTrim(aGrvSM6[nX,2])
		SM6->M6_ALTERNA	:= cSeq

		MsUnLock()
	Next nX
EndIf

RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Rsp010ValCpo ºAutor  ³Marcelo Silveira º Data ³  25/05/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao dos campos digitados na GetDados.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ RSPA010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rsp010ValCpo( nOpera, lInclui )

Local nPosAlterna	:= 0
Local nPosResulta	:= 0
Local nSaveRes		:= 0
Local cSaveAlt		:= ""
Local lRet  		:= .T.

//O campo Alternativa ou Resultado nao pode ser modificado, exceto na inclusao de um novo teste com novas questoes
If nOpera == 4 .And. !lInclui

	nPosAlterna := GdFieldPos("QR_ALTERNA")
	nPosResulta := GdFieldPos("QR_RESULTA")
	cSaveAlt	:= aCols[n,nPosAlterna]
	nSaveRes	:= aCols[n,nPosResulta]

	If "QR_ALTERNA" $ ReadVar()
		If cSaveAlt # M->QR_ALTERNA
			MsgAlert( OemToAnsi(STR0092) )	//"A alternativa nao pode ser alterada."
			//Restaura o valor do resultado que foi alterado antes da validacao
			A010Alterna( cSaveAlt )
			lRet := .F.
		EndIf
	EndIf

	If "QR_RESULTA" $ ReadVar()
		If nSaveRes # M->QR_RESULTA
			MsgAlert( OemToAnsi(STR0093) )	//"O resultado nao pode ser alterado."
			lRet := .F.
		EndIf
	EndIf

EndIf

Return( lRet )

/*/{Protheus.doc} Rsp010VldMun()
Valida se municipio selecionado corresponde a UF de nascimento
@author Leandro.Drumond
@type function
@since 23/08/2017
@version 12.1.17
/*/
Function Rsp010VldMun()
Local lRet 	:= Vazio()

M->QG_MUNNASC := ""

If !lRet
	If (lRet := ExistCpo("CC2", M->QG_NATURAL + M->QG_CODMUNN))
		M->QG_MUNNASC := CC2->CC2_MUN
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} Rsp010Dem()
Valida data de demissao
@author Flavio
@type function
@since 25/05/18
@version 12.1.17
/*/
Function Rsp010Dem()
Local lRet 		:= Vazio()
Local nPosAdm	:= GdFieldPos("QL_DTADMIS")

If !lRet
	If M->QL_DTDEMIS < aCols[n][nPosAdm]
		lRet := .F.
		Help(" ",1,STR0094)//"Data de demissão não pode ser menor que a data de admissão"
	Else
		lRet := .T.
	EndIf
EndIf

Return lRet


/*/{Protheus.doc} Rsp010JOB()
Atualizacao do aceite de menor de idade
@author Gisele Nuncherino
@type function
@since 30/03/2020
@version 12.1.25
/*/
Function Rsp010JOB(aParam)

	Local cquery 	:= ''
	Local lBlq   	:= ''
	Local cAliasTop := ''
	Local cEmpJob	:= ''
	Local cFilJob	:= ''

	If Len(aParam)>0
		cEmpJob := aParam[1]
		cFilJob := aParam[2]
	else
		cEmpJob := cEmpAnt
		cFilJob := cFilAnt
	EndIf

	RpcSetType(3)
	RPCsetEnv(cEmpJob, cFilJob)

	ConOut(OEMTOANSI( STR0100 ) + cEmpJob + " " + cFilJob)	

	lBlq := SQG->(Columnpos("QG_ACTRSP")) > 0

	IF lBlq
		cAliasTop 	:= GetNextAlias()

		cQuery := "SELECT QG_ACTRSP, QG_DTNASC, R_E_C_N_O_ FROM "
		cQuery += RetSqlTab("SQG") + "  "
		cQuery += "WHERE D_E_L_E_T_ = '' AND "
		cQuery += "QG_FILIAL = '" + XFILIAL("SQG") + "' AND "
		cQuery += "QG_ACTRSP = '1' "  //1- sem aceite e 2-com aceite

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTop,.T.,.T.)
				
		While !(cAliasTop)->(EoF())
			SQG->(DBGOTO((cAliasTop)->R_E_C_N_O_))
				RECLOCK("SQG", .F.)
					IF YearSum(SQG->QG_DTNASC, 18) > dDatabase 
						SQG->QG_ACTRSP := '1' //1-sem aceite
					ELSE
						SQG->QG_ACTRSP := '' //maior de idade 
					ENDIF
				SQG->(MSUNLOCK())
			(cAliasTop)->(DBSKIP())
		ENDDO
		(cAliasTop)->(DBCLOSEAREA())
	ENDIF

	ConOut(OEMTOANSI( STR0101 ) + cEmpJob + " " + cFilJob)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} A010AtuRI3
Rotina para excluir os dados da RI3 - aceite de consentimento
@author  gisele.nuncherino
@since   17/06/2020
/*/
//-------------------------------------------------------------------
Function A010AtuRI3(cCurric)

Local cFilRI3	:=	xFilial("RI3")

dbSelectArea("RI3")
dbSetOrder(3)
dbSeek(cFilRI3 + XFILIAL("SQG") + cCurric)
If nOpcao == 5				// exclusao
	While !Eof() .And. ALLTRIM(cFilRI3 + XFILIAL("SQG") + cCurric) == ALLTRIM(RI3->RI3_FILIAL + RI3->RI3_USER)
		RecLock("RI3",.F.,.T.)
			dbDelete()
		MsUnlock()
		
		dbSkip()
	EndDo
EndIf

Return .T.
