#include "PROTHEUS.ch"
#include "TMSAI60.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa   º  TMSAI60   º Autor º Richard Anderson   º Data º 22/11/06 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍ¹±±
±±º             	Nota de Debito/Credito                      		         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe    º  TMSAI60()                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros º                                         			         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno    º NIL                                                       º±±
±±ºÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso        º SIGATMS - Gestao de Transportes                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Comentario º                                                           º±±
±±º            º                                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador º  Data  º BOPS º             Motivo da Alteracao           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            ºxx/xx/02ºxxxxxxº                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAI60()

Local   aCores    := {}
Private cCadastro	:= STR0001 //-- Nota de Débito/Crédito
Private aRotina	:= {{ STR0002  , "AxPesqui"  , 0, 1 },; //"Pesquisar"
				          { STR0003  , "TMAI60Mnt" , 0, 2 },; //"Visualizar"
 				          { STR0004  , "TMAI60Mnt" , 0, 3 },; //"Incluir"
 				          { STR0014  , "TMAI60Mnt" , 0, 5 },; //"Excluir"
				          { STR0007  , "TMAI60Mnt" , 0, 6 },; //"Aprovar"
				          { STR0013  , "U_RTMSR21" , 0, 7 },; //"Imprimir"
							 { STR0008  , "TMAI60Leg" , 0, 8 } } //"Legenda"

Aadd(aCores,{"DIH_STATUS=='1'",'BR_AMARELO'	})		//-- Pendente
Aadd(aCores,{"DIH_STATUS=='2'",'BR_VERDE'		})		//-- Aprovada
Aadd(aCores,{"DIH_STATUS=='9'",'BR_PRETO'		})		//-- Cancelada

DTQ->(dBGobottom()) //-- Forca o Eof da viagem para o F3 DL4 funcionar
DTQ->(dBSkip())
dbSelectArea("DIH")
dbSetOrder(1)
dbGoTop()

mBrowse(06,01,22,75,"DIH",,,,,,aCores)

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI60Mnt ³ Autor ³ Richard Anderson     ³ Data ³19.03.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Interface da Rotina de Nota de Débito/Crédito               ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Alias da tabela                                      ³±±
±±³          ³ ExpN2: Numero do Registro                                   ³±±
±±³          ³ ExpN3: Opcao do aRotina                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAI60Mnt(cAlias, nReg, nOpcx)

Local aAreaAtu    := GetArea()
Local nSeek       := 0
Local aSx3Box     := {}

//-- EnchoiceBar
Local aTmsVisual	:= {}
Local aTmsAltera	:= {}
Local nOpcA			:= 0
Local oTmsEnch    := {}
Local aNoFields   := {}
Local cCampo      := ''
Local aVisual     := {}
Local aAltera     := NIL

//-- Dialog
Local oTmsDlgEsp

//-- Controle de dimensoes de objetos
Local aObjects		:= {}
Local aInfo			:= {}
Local aTmsPosObj  := {}

Local aFldDIH		:= {}
Local nI			:= 0

//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]

nOpcx := aRotina[nOpcx,4]

//--  Nao exibe observacao de cancelamento na inclusão
If nOpcx == 3 //-- Inclui
	aAdd(aNoFields, 'DIH_OBSCAN')
ElseIf nOpcx == 5 //-- Excluir
	If DIH->DIH_STATUS != '1'
		aSx3Box	:= RetSx3Box(Posicione('SX3',2,'DIH_STATUS','X3CBox()'),,,1)
		If	( nSeek := Ascan(aSx3Box,{ | x | x[2] == DIH->DIH_STATUS } ))>0
			MsgAlert(STR0015+Iif(DIH->DIH_TIPNDC == '1',STR0016,STR0017)+STR0018+AllTrim(aSx3Box[nSeek,3])) //-- "Nota de ", "débito", "crédito", " com status: "
			Return NIL
		EndIf
	EndIf
ElseIf nOpcx == 6 //-- Aprovar
	If DIH->DIH_STATUS != '1'
		aSx3Box	:= RetSx3Box(Posicione('SX3',2,'DIH_STATUS','X3CBox()'),,,1)
		If	( nSeek := Ascan(aSx3Box,{ | x | x[2] == DIH->DIH_STATUS } ))>0
			MsgAlert(STR0015+Iif(DIH->DIH_TIPNDC == '1',STR0016,STR0017)+STR0018+AllTrim(aSx3Box[nSeek,3])) //-- "Nota de ", "débito", "crédito", " com status: "
			Return NIL
		EndIf
	EndIf
	aAltera := {}
	Aadd(aAltera,'DIH_OBSCAN')
	Aadd(aAltera,'DIH_STATUS')
EndIf

//-- Configura variaveis da Enchoice
aFldDIH := ApBuildHeader("DIH", aNoFields)
For nI := 1 To Len(aFldDIH)
	aAdd(aVisual, aFldDIH[nI][2])
Next

aSize(aFldDIH, 0)
aFldDIH := Nil

RegToMemory("DIH", INCLUI)

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aTmsPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oTmsDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL

	//-- Monta a enchoice.
	oTmsEnch	:= MsMGet():New( cAlias, nReg, Iif(nOpcx == 3,nOpcx,4),,,,aVisual,aTmsPosObj[1], aAltera, 3,,,,,,.T. )
	
ACTIVATE MSDIALOG oTmsDlgEsp ON INIT EnchoiceBar( oTmsDlgEsp,{|| Iif(TMAI60TOk(nOpcx),(oTmsDlgEsp:End(),nOpcA := 1),nOpcA := 0)},{|| nOpcA := 0, oTmsDlgEsp:End() }) 

If nOpcx != 2 .And. nOpcA == 1
	If __lSX8 
		ConfirmSX8()
	EndIf
	TMAI60Grv(nOpcx)
ElseIf nOpcx != 2
	RollBackSX8()
EndIf

RestArea(aAreaAtu)

Return nOpcA

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI60Vld³ Autor ³ Richard Anderson      ³ Data ³22/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida antes de editar o campo.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI60Vld() 

Local lRet     := .T.
Local cCampo   := ReadVar()
Local cDoc     := ''
Local cFilSE1  := ''
Local cFilSF2  := ''
Local lFatDT6  := .F.
Local cPrefixo := ''
Local cDocTms  := '2/5/B/C/H/I/J'

If cCampo == 'M->DIH_FILDOC' .Or. cCampo == 'M->DIH_DOC' .Or. cCampo == 'M->DIH_SERIE'
	If !Empty(M->DIH_FILDOC) .And. !Empty(M->DIH_DOC) .And. !Empty(M->DIH_SERIE)
		DT6->(dbSetOrder(1))
		If DT6->(!dbSeek(xFilial('DT6')+M->DIH_FILDOC+M->DIH_DOC+M->DIH_SERIE))
			Help('',1,'REGNOIS')
			lRet := .F.
		EndIf
		If lRet .And. !(DT6->DT6_DOCTMS $ cDocTms)
			MsgAlert(STR0019) //-- "Documento inválido !"
			lRet := .F.
		EndIf                        
		If lRet .And. M->DIH_TIPNDC == '1' .And. (DT6->DT6_DOCTMS != 'J')
			MsgAlert(STR0020) //-- "Não é permitida a operação de débito para documetos do transporte nacional !"
			lRet := .F.
		EndIf                        		
		If lRet
			cFilSE1 := Iif(Empty(xFilial('SE1')), xFilial('SE1'), M->DIH_FILDOC)
			cFilSF2 := Iif(Empty(xFilial('SF2')), xFilial('SF2'), M->DIH_FILDOC)
			lFatDT6 := DT6->(FieldPos("DT6_PREFIX")) > 0 
			If lFatDT6 .And. !Empty(DT6->DT6_PREFIX)
			   cPrefixo := DT6->DT6_PREFIX //-- Prefixo da Fatura.	
			   cDoc     := DT6->DT6_NUM    //-- Numero da Fatura.
			Else              
				SF2->(dbSetOrder(1))
				SF2->(MsSeek(cFilSF2+M->DIH_DOC+M->DIH_SERIE))
				cPrefixo := Padr( If(Empty(SF2->F2_PREFIXO),&(GETMV("MV_1DUPREF")),SF2->F2_PREFIXO),  Len( SE1->E1_PREFIXO ) )
				cDoc     := SF2->F2_DUPL
			EndIf
		   SE1->(dbSetOrder(2))
		   If SE1->(MsSeek(cFilSE1+DT6->DT6_CLIDEV+DT6->DT6_LOJDEV+cPrefixo+cDoc)) .And. !Empty(SE1->E1_FATURA)
		   	MsgAlert(STR0021) //-- "Documento já faturado !"
		   	lRet := .F.
			EndIf
		EndIf
	EndIf
ElseIF cCampo == 'M->DIH_TIPNDC' 
	If !Empty(M->DIH_FILDOC) .And. !Empty(M->DIH_DOC) .And. !Empty(M->DIH_SERIE)
		DT6->(dbSetOrder(1))
		If DT6->(!dbSeek(xFilial('DT6')+M->DIH_FILDOC+M->DIH_DOC+M->DIH_SERIE))
			Help('',1,'REGNOIS')
			lRet := .F.
		EndIf
		If lRet .And. M->DIH_TIPNDC == '1' .And. (DT6->DT6_DOCTMS != 'J')
			MsgAlert(STR0020) //-- "Não é permitida a operação de débito para documetos do transporte nacional !"
			lRet := .F.
		EndIf
	EndIf
EndIf	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI60Whe³ Autor ³ Richard Anderson      ³ Data ³22/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Condicao para edicao do campo                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI60Whe(cCampo)

Local   lRet   := .T.
Default cCampo := AllTrim(ReadVar())

Return(lRet)	


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI60TOk ³ Autor ³ Richard Anderson     ³ Data ³22.11.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de confirmacao para gravacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMAI60TOk(nOpcx)

Local lRet 		:= .T.
Local cPrefixo
Local cDoc               
Local nValor	:= 0
Local lFatDT6  := DT6->(FieldPos("DT6_PREFIX")) > 0 
Local cFilSE1	:= Iif(Empty(xFilial('SE1')), xFilial('SE1'), M->DIH_FILDOC)
Local cFilSF2	:= Iif(Empty(xFilial('SF2')), xFilial('SF2'), M->DIH_FILDOC)

lRet := Obrigatorio(aGets,aTela)

If nOpcx == 3 //-- Incluir
	DT6->(dbSetOrder(1))
	DT6->(dbSeek(xFilial('DT6')+M->DIH_FILDOC+M->DIH_DOC+M->DIH_SERIE))
	If lFatDT6 .And. !Empty(DT6->DT6_PREFIX)
		cPrefixo := DT6->DT6_PREFIX //-- Prefixo da Fatura.
		cDoc     := DT6->DT6_NUM    //-- Numero da Fatura.
	Else
		SF2->(dbSetOrder(1))
		SF2->(MsSeek(cFilSF2+M->DIH_DOC+M->DIH_SERIE))
		cPrefixo := Padr( If(Empty(SF2->F2_PREFIXO),&(GETMV("MV_1DUPREF")),SF2->F2_PREFIXO),  Len( SE1->E1_PREFIXO ) )
		cDoc     := SF2->F2_DUPL
	EndIf
	If lFatDT6 .And. Empty(DT6->DT6_PREFIX)
		If M->DIH_TIPNDC == '1' //-- Debito
			If ( DT6->DT6_VALFAT + DT6->DT6_ACRESC  ) < M->DIH_VALOR
				lRet := .F.
			EndIf
		EndIf
	Else
		SE1->(dbSetOrder(2))
		If SE1->(MsSeek(cFilSE1+DT6->DT6_CLIDEV+DT6->DT6_LOJDEV+cPrefixo+cDoc)) .And. Empty(SE1->E1_FATURA)
			If M->DIH_TIPNDC == '1' //-- Debito
				If ( SE1->E1_VALOR + SE1->E1_ACRESC ) < M->DIH_VALOR
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	If !lRet
		MsgAlert(STR0022) //-- "O valor de débito e maior que o permitido"
	EndIf
ElseIf lRet .And. nOpcx == 6 //-- Aprovar
	If M->DIH_STATUS == '1' //-- Pendente
		MsgAlert(STR0023+Iif(DIH->DIH_TIPNDC == '1',STR0016,STR0017)+STR0024) //-- "Informe nova situação da nota de ", "débito", "crédito", " pelo campo [Status]"
		lRet := .F.
	ElseIf M->DIH_STATUS == '9' .And. Empty(M->DIH_OBSCAN)
		MsgAlert(STR0025+Iif(DIH->DIH_TIPNDC == '1',STR0016,STR0017)) //-- "Informe a observação de cancelamento da nota de ", "débito", "crédito"
		lRet := .F.
	EndIf
EndIf


Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMAI60Grv³ Autor ³ Richard Anderson      ³ Data ³22/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de Gravacao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMAI60Grv(nOpcx) 

Local nI       := 0
Local nCntFor	:= 0
Local nCntFo1	:= 0    
Local cPrefixo := ''
Local cDoc     := ''
Local lFatDT6  := DT6->(FieldPos("DT6_PREFIX")) > 0 
Local aAreaDT6 := DT6->(GetArea())
Local aAreaSF2 := SF2->(GetArea())
Local aAreaSE1 := SE1->(GetArea())
Local cFilSE1	:= Iif(Empty(xFilial('SE1')), xFilial('SE1'), M->DIH_FILDOC)
Local cFilSF2	:= Iif(Empty(xFilial('SF2')), xFilial('SF2'), M->DIH_FILDOC)
Local cNumDc	:= ''
Begin Transaction

If nOpcx == 5 //-- Excluir
	RecLock( "DIH", .F. )  
	DBDelete()	
	MsUnlock()
Else
	RecLock( "DIH", nOpcx == 3 )
	For nI := 1 To FCount()
		If "FILIAL" $ Field(nI)
			FieldPut(nI,xFilial("DIH"))
		Else
			If Type("M->"+FieldName(nI)) <> "U"
				FieldPut(nI,M->&(FieldName(nI)))
			EndIf
		EndIf
	Next nI

	If nOpcx == 6 .And. M->DIH_STATUS == '2' //-- Aprovado
		DT6->(dbSetOrder(1))
		DT6->(dbSeek(xFilial('DT6')+M->DIH_FILDOC+M->DIH_DOC+M->DIH_SERIE))
		If lFatDT6 .And. !Empty(DT6->DT6_PREFIX)
		   cPrefixo := DT6->DT6_PREFIX //-- Prefixo da Fatura.	
		   cDoc     := DT6->DT6_NUM    //-- Numero da Fatura.
		Else              
			SF2->(dbSetOrder(1))
			SF2->(MsSeek(cFilSF2+M->DIH_DOC+M->DIH_SERIE))
			cPrefixo := Padr( If(Empty(SF2->F2_PREFIXO),&(GETMV("MV_1DUPREF")),SF2->F2_PREFIXO),  Len( SE1->E1_PREFIXO ) )
			cDoc     := SF2->F2_DUPL
		EndIf
		If lFatDT6 .And. Empty(DT6->DT6_PREFIX)
			RecLock('DT6',.F.)
			If M->DIH_TIPNDC == '1' //-- Debito
				DT6->DT6_ACRESC += M->DIH_VALOR
			Else
				DT6->DT6_DECRES += M->DIH_VALOR
			EndIf
			MsUnLock()
		Else			
		   SE1->(dbSetOrder(2))
		   If SE1->(MsSeek(cFilSE1+DT6->DT6_CLIDEV+DT6->DT6_LOJDEV+cPrefixo+cDoc)) .And. Empty(SE1->E1_FATURA)
				RecLock('SE1',.F.)
				If M->DIH_TIPNDC == '1' //-- Debito
					SE1->E1_ACRESC  += M->DIH_VALOR
				Else
					SE1->E1_DECRESC += M->DIH_VALOR
				EndIf
				MsUnLock()
			EndIf
		EndIf							
	EndIf		
EndIf
															   
If nOpcx == 3 //-- Incluir
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o campo MEMO                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MSMM(DIH->DIH_CODMOT,,,M->DIH_MOTIVO,1,,,"DIH","DIH_CODMOT")
ElseIf nOpcx == 5 //-- Excluir
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui o campo MEMO                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MSMM(DIH->DIH_CODMOT,,,,2)	
ElseIf nOpcx == 6	.And. DIH->DIH_STATUS == '9' //-- Nota de Debito cancelada
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o campo MEMO                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MSMM(DIH->DIH_CODOBC,,,M->DIH_OBSCAN,1,,,"DIH","DIH_CODOBC")
EndIf													   

End Transaction

cNumDc	:= DIH->DIH_NUMNDC

RestArea(aAreaDT6)
RestArea(aAreaSF2)
RestArea(aAreaSE1)

Return ( cNumDc )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA040Leg³ Autor ³ Alex Egydio           ³ Data ³16.10.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a legenda do status da cotacao.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMAI60Leg()

BrwLegenda( cCadastro,  STR0009 	,;  	//'Status'
{	{  'BR_AMARELO'	,  STR0010 	},;  	//'Pendente'
{ 		'BR_VERDE'		,  STR0011 	},;  	//'Aprovada'
{ 		'BR_PRETO'		,  STR0012 	}})  	//'Cancelada'

Return NIL
