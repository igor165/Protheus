#INCLUDE 'TMSAE15.CH'
#INCLUDE 'PROTHEUS.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAE15  ³ Autor ³ Eduardo de Souza      ³ Data ³ 11/11/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Registros Complementares                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE15()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                  ATUALIZACOES - VIDE SOURCE SAFE                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE15()

Local aHlpPor1    :=  {"O registro complementar não deverá ser"," preenchido para layout de recebimento"}
Local aHlpIng1    :=  {"Complementary record must not be "," filled out for reception layout "}
Local aHlpEsp1    :=  {"O registro complementar não deverá ser"," preenchido para layout de recebimento"}
Local aHlpPor2    :=  {"Não foi encontrado no layout o ","registro informado"}
Local aHlpIng2    :=  {"Not found in layout the ","record entered"}
Local aHlpEsp2    :=  {"Não foi encontrado no layout o ","registro informado"}
Local aHlpPor3    :=  {"O identificador do registro atual não ","pode ser maior que o identificador ","do registro complementar"}
Local aHlpIng3    :=  {"The identifier of the current records does not","can be higher than the identifier  ","of complementary record "}
Local aHlpEsp3    :=  {"O identificador do registro atual não ","pode ser maior que o identificador ","do registro complementar"}
Local aHlpPor4    :=  {"O Registro complementar já está ","informado no configurador do layout"}
Local aHlpIng4    :=  {"Complementary record is already ","entered in the layout configurator "}
Local aHlpEsp4    :=  {"O Registro complementar já está ","informado no configurador do layout"}
Local aHlpPor5    :=  {"Não foi encontrado no layout o ","registro complementar informado"}
Local aHlpIng5    :=  {"Not found in layout the ","complementary record entered "}
Local aHlpEsp5    :=  {"Não foi encontrado no layout o ","registro complementar informado"}
Local aHlpPor6    :=  {"O identificador do registro atual não ","pode ser maior que o identificador do ","registro complementar"}
Local aHlpIng6    :=  {"Identifier of the current record does not","can be higher than the identifier  ","complementary record "}
Local aHlpEsp6    :=  {"O identificador do registro atual não ","pode ser maior que o identificador do ","registro complementar"}

//Ajuste de Novos Helps
PutHelp("PTMSAE1501",aHlpPor1,aHlpIng1,aHlpEsp1,.F.)
PutHelp("PTMSAE1502",aHlpPor2,aHlpIng2,aHlpEsp2,.F.)
PutHelp("PTMSAE1503",aHlpPor3,aHlpIng3,aHlpEsp3,.F.)
PutHelp("PTMSAE1504",aHlpPor4,aHlpIng4,aHlpEsp4,.F.)
PutHelp("PTMSAE1505",aHlpPor5,aHlpIng5,aHlpEsp5,.F.)
PutHelp("PTMSAE1506",aHlpPor6,aHlpIng6,aHlpEsp6,.F.)

Private cCadastro := STR0001 //"Registros Complementares"
Private aRotina   := MenuDef()

DE8->( DbSetOrder( 1 ) )

mBrowse( 6,1,22,75,"DE8",, )

RetIndex("DE8")

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE15Mnt³ Autor ³ Eduardo de Souza      ³ Data ³04.03.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcoes de Atualizacao do Cadastro                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE15Mnt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSEA15                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE15Mnt( cAlias, nReg, nOpcx )

Local aAreaAnt		:= GetArea()
Local aAreaDE8      := DE8->( GetArea() )
Local nCntFor		:= 0
Local aVisual		:= {}
Local aAltera		:= {}
Local aButtons		:= {}
Local nOpca			:= 0
Local oEnch
Local oDlgEsp
Local aNoFields		:= {}
Local aYesFields	:= {}
Local aObjects		:= {}
Local aInfo			:= {}

Private aTela[0][0]
Private aGets[0]
Private aHeader := {}
Private aCols	:= {}
Private oGetD
Private aPosObj:= {}
Private cCodAnt

//-- Configura variaveis da Enchoice
RegToMemory( cAlias, nOpcx==3 )

Aadd( aVisual,   'DE8_CODLAY') 
Aadd( aVisual,   'DE8_DSCLAY')

Aadd( aNoFields, 'DE8_CODLAY')
Aadd( aNoFields, 'DE8_DSCLAY')

//-- Configura variaveis da GetDados
TMSFillGetDados(nOpcx,'DE8', 1,xFilial('DE8')+M->DE8_CODLAY, { || DE8->DE8_FILIAL + DE8->DE8_CODLAY },{ || .T. }, aNoFields,	aYesFields )
//-- Se for copia, zera o codigo para obrigar a alteracao.

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 20, .T., .T. } )
AAdd( aObjects, { 100, 80, .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
oEnch	:= MsMGet():New( cAlias, nReg, nOpcx,,,,aVisual,aPosObj[1],, 3,,,,,,.T. )
oGetD := MSGetDados():New(aPosObj[ 2, 1 ], aPosObj[ 2, 2 ],aPosObj[ 2, 3 ], aPosObj[ 2, 4 ], nOpcx,'TMSAE15LOk','TMSAE15TOk',,.T.)
ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||nOpca:=1, If( oGetD:TudoOk(),oDlgEsp:End(),nOpca := 0)},{||oDlgEsp:End()},, aButtons ) 

If nOpcx != 2 .And. nOpcA == 1
	TMSAE15Grv( nOpcx )  //Gravacao dos registros
EndIf

DeleteObject( oDlgEsp )
DeleteObject( oEnch )
DeleteObject( oGetD )

RestArea( aAreaDE8 )
RestArea( aAreaAnt )

Return(nOpca)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE15LOk³ Autor ³ Eduardo de Souza      ³ Data ³ 14/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes da linha da GetDados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE15LOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSEA15                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE15LOk()

Local lRet := .T.

//-- Nao avalia linhas deletadas.
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- Analisa se ha itens duplicados na GetDados.
	lRet := GDCheckKey( { 'DE8_CODRCP' }, 4 )
EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE15TOk  ³ Autor ³ Eduardo de Souza    ³ Data ³ 14/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao Geral                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE15TOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSEA15                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE15TOk()

Local lRet := .T.

//-- Analisa se os campos obrigatorios da Enchoice foram informados.
lRet := Obrigatorio( aGets, aTela )

//-- Analisa o linha ok.
If lRet
	lRet := TMSAE15LOk()
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAE15Grv ³ Autor ³ Eduardo de Souza     ³ Data ³ 14/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravar dados                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE15GrV(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSEA15                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSAE15Grv( nOpcx )

Local aAreaAnt	:= GetArea()
Local aAreaDE8	:= DE8->( GetArea() )
Local bCampo	:= { |nCpo| Field(nCpo) }
Local nCntFor	:= 0
Local nCntFo1	:= 0

If nOpcx == 5 //-- Excluir
	Begin Transaction
		// Exclui todos os itens do DE8
		DE8->( DbSetOrder( 1 ) )
		DE8->(MsSeek(xFilial('DE8')+M->DE8_CODLAY))
		While DE8->(!Eof()) .And. DE8->(MsSeek(xFilial('DE8')+M->DE8_CODLAY))
			RecLock('DE8',.F.,.T.)
			DE8->(DbDelete())
			DE8->(DbSkip())
			MsUnLock()
		EndDo
		EvalTrigger()
	End Transaction
EndIf

If nOpcx == 3 .Or. nOpcx == 4 //-- Incluir ou Alterar

	Begin Transaction
		// Se ja existir o registro apaga pra incluir novamente
		DE8->(DbSetOrder(1))
		If DE8->(MsSeek(xFilial('DE8') + M->DE8_CODLAY))
			While DE8->(!Eof()) .And. DE8->DE8_FILIAL + DE8->DE8_CODLAY == xFilial('DE8') + M->DE8_CODLAY
				RecLock('DE8',.F.,.T.)
				DE8->(DbDelete())
				MsUnLock()
				DE8->(DbSkip())
			EndDo
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravacao dos Dados                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCntFor := 1 To Len( aCols )
			If !GDDeleted(nCntFor)
				RecLock('DE8',.T.)
				For nCntFo1 := 1 To Len(aHeader)
					If	aHeader[nCntFo1,10] != 'V'
						FieldPut(FieldPos(aHeader[nCntFo1,2]), aCols[nCntFor,nCntFo1])
					EndIf
				Next
				DE8->DE8_FILIAL := xFilial('DE8')
				DE8->DE8_CODLAY := M->DE8_CODLAY
				MsUnLock()
			EndIf
		Next
		EvalTrigger()
	End Transaction
EndIf

RestArea( aAreaDE8 )
RestArea( aAreaAnt )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSAE15Vld ³ Autor ³Eduardo de Souza      ³ Data ³ 30/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacoes                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAE15Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAE15                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE15Vld()

Local cCampo   := ReadVar()
Local lRet     := .T.
Local cIdtReg  := ""
Local cCodRCP  := ""
Local aAreaDE8 := DE8->(GetArea())

If cCampo == "M->DE8_CODREG"
	If !Empty(M->DE8_CODREG)
		//-- Nao permite informar complemento para o recebimento.
		If Posicione("DE9",1,xFilial("DE9")+M->DE8_CODLAY,"DE9_TIPLAY") == StrZero(2,Len(DE9->DE9_TIPLAY)) //-- Recebimento
			Help(" ",1,"TMSAE1501") //"O registro complementar nao devera ser preenchido para layout de recebimento !!!"
			lRet := .F.
		EndIf
		//-- Verifica se o registro existe.
		If lRet
			lRet := ExistCpo("DE3")
		EndIf
		//-- Verifica se o registro atual eh menor que o complementar.
		If lRet
			cIdtReg := Posicione("DE0",1,xFilial("DE0")+M->DE8_CODLAY+M->DE8_CODREG,"DE0_IDTREG")
			If Empty(cIdtReg)
				Help(" ",1,"TMSAE1502") //"Nao foi encontrado no layout o registro informado"
				lRet := .F.
			Else
				If !Empty(cCodRCP := GdFieldGet("DE8_CODRCP",n))
					If cIdtReg >= Posicione("DE0",1,xFilial("DE0")+M->DE8_CODLAY+cCodRCP,"DE0_IDTREG")
						Help(" ",1,"TMSAE1503") //"O identificador do registro atual nao pode ser maior que o identificador do registro complementar"
						lRet := .F.
					EndIf
				EndIf
			EndIf
			//-- Verifica se o registro complementar esta preenchido no configurador do layout.
			If !Empty(DE0->DE0_CODRCP)
				Help(" ",1,"TMSAE1504") //"O Registro complementar ja esta informado no configurador do layout"
				lRet := .F.
			EndIf
		EndIf
	EndIf
ElseIf cCampo == "M->DE8_CODRCP"
	If !Empty(M->DE8_CODRCP)
		//-- Verifica se o registro existe.
		If lRet
			lRet := ExistCpo("DE3")
		EndIf
		//-- Verifica se o registro atual eh menor que o complementar.
		If lRet
			cIdtReg := Posicione("DE0",1,xFilial("DE0")+M->DE8_CODLAY+M->DE8_CODRCP,"DE0_IDTREG")
			If Empty(cIdtReg)
				Help(" ",1,"TMSAE1505") //"Nao foi encontrado no layout o registro complementar informado"
				lRet := .F.
			Else
				If Posicione("DE0",1,xFilial("DE0")+M->DE8_CODLAY+GdFieldGet("DE8_CODREG",n),"DE0_IDTREG") >= cIdtReg
					Help(" ",1,"TMSAE1506") //"O identificador do registro atual nao pode ser maior que o identificador do registro complementar"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea( aAreaDE8 )

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
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
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()

Private aRotina   := {	{ STR0002,'AxPesqui'  ,0,1,0,.F.},; //'Pesquisar'
								{ STR0003,'TMSAE15Mnt',0,2,0,NIL},; //'Visualizar'
								{ STR0004,'TMSAE15Mnt',0,3,0,NIL},; //'Incluir'
								{ STR0005,'TMSAE15Mnt',0,4,0,NIL},; //'Alterar'
								{ STR0006,'TMSAE15Mnt',0,5,0,NIL}}  //'Excluir'

If ExistBlock("TME15MNU")
	ExecBlock("TME15MNU",.F.,.F.)
EndIf

Return(aRotina)
